package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/reservas")
public class ReservasServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List < Map < String, Object > > reservas = new ArrayList < > ();
        List < Map < String, Object > > solicitantes = new ArrayList < > ();

        try (Connection conn = DatabaseConfig.getConnection()) {
            String sql = "SELECT r.*, s.nombre_completo, s.codigo, " +
                         "(SELECT GROUP_CONCAT(e.codigo_inventario SEPARATOR ', ') FROM reserva_equipo re JOIN equipo e ON re.id_equipo=e.id_equipo WHERE re.id_reserva=r.id_reserva) AS equipos_asignados " +
                         "FROM reserva r JOIN solicitante s ON r.id_solicitante=s.id_solicitante ORDER BY r.id_reserva DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id_reserva"));
                    m.put("solicitante", rs.getString("codigo") + " - " + rs.getString("nombre_completo"));
                    m.put("inicio", rs.getString("fecha_inicio"));
                    m.put("fin", rs.getString("fecha_fin"));
                    m.put("tipo", rs.getString("tipo_equipo"));
                    m.put("cantidad", rs.getInt("cantidad"));
                    m.put("ram", rs.getObject("ram_minima"));
                    m.put("estrategia", rs.getString("estrategia"));
                    m.put("estado", rs.getString("estado"));
                    m.put("equipos", rs.getString("equipos_asignados"));
                    m.put("comentarios", rs.getString("comentarios"));
                    reservas.add(m);
                }
            }

            try (PreparedStatement ps = conn.prepareStatement("SELECT id_solicitante, codigo, nombre_completo FROM solicitante WHERE estado='activo'");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> s = new HashMap<>();
                    s.put("id", rs.getInt("id_solicitante"));
                    s.put("label", rs.getString("codigo") + " - " + rs.getString("nombre_completo"));
                    solicitantes.add(s);
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", e.getMessage());
        }

        req.setAttribute("reservas", reservas);
        req.setAttribute("solicitantes", solicitantes);
        req.getRequestDispatcher("reservas.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");

        try (Connection conn = DatabaseConfig.getConnection()) {
            if ("crear".equals(accion)) {
                int idSolicitante = Integer.parseInt(req.getParameter("id_solicitante"));
                String inicio = req.getParameter("fecha_inicio").replace("T", " ") + ":00";
                String fin = req.getParameter("fecha_fin").replace("T", " ") + ":00";
                String tipo = req.getParameter("tipo_equipo");
                int cantidad = Integer.parseInt(req.getParameter("cantidad"));
                String ramStr = req.getParameter("ram_minima");
                int ramMin = ("computadora".equals(tipo) && ramStr != null && !ramStr.isEmpty()) ? Integer.parseInt(ramStr) : 0;
                String motivo = req.getParameter("motivo_uso");
                String comentarios = req.getParameter("comentarios");
                String estrategia = req.getParameter("estrategia");
                if (!"computadora".equals(tipo)) {
                    estrategia = "menor_uso";
                }

                if (Timestamp.valueOf(fin).compareTo(Timestamp.valueOf(inicio)) <= 0) {
                    req.getSession().setAttribute("msgError", "La fecha/hora de fin debe ser posterior al inicio.");
                    resp.sendRedirect("reservas");
                    return;
                }

                String orderClause = "ajuste_capacidad".equals(estrategia)
                        ? "ORDER BY e.ram_gb ASC, e.codigo_inventario ASC"
                        : "ORDER BY horas_uso ASC, e.codigo_inventario ASC";

                String queryDisponibles =
                    "SELECT e.id_equipo, e.codigo_inventario, " +
                    "COALESCE((SELECT SUM(TIMESTAMPDIFF(HOUR, r2.fecha_inicio, r2.fecha_fin)) FROM reserva_equipo re2 JOIN reserva r2 ON re2.id_reserva=r2.id_reserva WHERE re2.id_equipo=e.id_equipo AND r2.estado IN ('confirmada','finalizada')), 0) AS horas_uso " +
                    "FROM equipo e " +
                    "WHERE e.estado = 'activo' AND e.tipo = ? " +
                    ("computadora".equals(tipo) ? "AND e.ram_gb >= ? " : "") +
                    "AND e.id_equipo NOT IN (SELECT m.id_equipo FROM mantenimiento m WHERE m.estado != 'anulado' AND (? < m.fecha_fin AND ? > m.fecha_inicio)) " +
                    "AND e.id_equipo NOT IN (SELECT re.id_equipo FROM reserva_equipo re JOIN reserva r ON re.id_reserva=r.id_reserva WHERE r.estado = 'confirmada' AND (? < r.fecha_fin AND ? > r.fecha_inicio)) " +
                    "AND e.id_equipo NOT IN (SELECT pe.id_equipo FROM prestamo_equipo pe JOIN prestamo p ON pe.id_prestamo=p.id_prestamo WHERE p.estado = 'abierto' AND pe.fecha_devolucion_real IS NULL) " +
                    orderClause;

                List<Integer> seleccionados = new ArrayList<>();
                List<String> codigosSeleccionados = new ArrayList<>();

                try (PreparedStatement ps = conn.prepareStatement(queryDisponibles)) {
                    int idx = 1;
                    ps.setString(idx++, tipo);
                    if ("computadora".equals(tipo)) {
                        ps.setInt(idx++, ramMin);
                    }
                    ps.setString(idx++, inicio);
                    ps.setString(idx++, fin);
                    ps.setString(idx++, inicio);
                    ps.setString(idx++, fin);

                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next() && seleccionados.size() < cantidad) {
                            seleccionados.add(rs.getInt("id_equipo"));
                            codigosSeleccionados.add(rs.getString("codigo_inventario"));
                        }
                    }
                }

                if (seleccionados.size() < cantidad) {
                    req.getSession().setAttribute("msgError",
                        "Asignación Rechazada: Se solicitaron " + cantidad + " equipo(s) tipo " + tipo +
                        ", pero solo hay " + seleccionados.size() + " disponible(s) sin conflictos en ese horario.");
                    resp.sendRedirect("reservas");
                    return;
                }

                conn.setAutoCommit(false);
                try {
                    String insRes = "INSERT INTO reserva (id_solicitante, fecha_inicio, fecha_fin, tipo_equipo, cantidad, ram_minima, motivo_uso, comentarios, estrategia, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'confirmada')";
                    int idReserva = 0;
                    try (PreparedStatement ps = conn.prepareStatement(insRes, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setInt(1, idSolicitante);
                        ps.setString(2, inicio);
                        ps.setString(3, fin);
                        ps.setString(4, tipo);
                        ps.setInt(5, cantidad);
                        if (ramMin > 0) {
                            ps.setInt(6, ramMin);
                        } else {
                            ps.setNull(6, Types.INTEGER);
                        }
                        ps.setString(7, motivo);
                        ps.setString(8, (comentarios != null && !comentarios.trim().isEmpty()) ? comentarios.trim() : null);
                        ps.setString(9, estrategia);
                        ps.executeUpdate();
                        ResultSet keys = ps.getGeneratedKeys();
                        if (keys.next()) {
                            idReserva = keys.getInt(1);
                        }
                    }

                    String insDet = "INSERT INTO reserva_equipo (id_reserva, id_equipo) VALUES (?, ?)";
                    try (PreparedStatement psDet = conn.prepareStatement(insDet)) {
                        for (Integer idEq : seleccionados) {
                            psDet.setInt(1, idReserva);
                            psDet.setInt(2, idEq);
                            psDet.addBatch();
                        }
                        psDet.executeBatch();
                    }
                    conn.commit();
                    req.getSession().setAttribute("msgSuccess", "Reserva #" + idReserva + " CONFIRMADA. Equipos asignados automáticamente: " + String.join(", ", codigosSeleccionados));
                } catch (SQLException ex) {
                    conn.rollback();
                    throw ex;
                } finally {
                    conn.setAutoCommit(true);
                }

            } else if ("cancelar".equals(accion)) {
                int idRes = Integer.parseInt(req.getParameter("id"));
                try (PreparedStatement psChk = conn.prepareStatement("SELECT COUNT(*) FROM prestamo WHERE id_reserva=? AND estado='abierto'")) {
                    psChk.setInt(1, idRes);
                    ResultSet rs = psChk.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        req.getSession().setAttribute("msgError", "No se puede cancelar: la reserva tiene un préstamo abierto.");
                        resp.sendRedirect("reservas");
                        return;
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement("UPDATE reserva SET estado='cancelada' WHERE id_reserva=?")) {
                    ps.setInt(1, idRes);
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Reserva cancelada y equipos liberados.");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("msgError", "Error en reserva: " + e.getMessage());
        }
        resp.sendRedirect("reservas");
    }
}