package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/mantenimientos")
public class MantenimientosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Map<String, Object>> lista = new ArrayList<>();
        List<Map<String, Object>> equipos = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            String sql = "SELECT m.*, e.codigo_inventario, e.descripcion FROM mantenimiento m JOIN equipo e ON m.id_equipo=e.id_equipo ORDER BY m.id_mantenimiento DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id_mantenimiento"));
                    m.put("equipo", rs.getString("codigo_inventario") + " - " + rs.getString("descripcion"));
                    m.put("inicio", rs.getString("fecha_inicio"));
                    m.put("fin", rs.getString("fecha_fin"));
                    m.put("motivo", rs.getString("motivo"));
                    m.put("observaciones", rs.getString("observaciones"));
                    m.put("estado", rs.getString("estado"));
                    lista.add(m);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT id_equipo, codigo_inventario, descripcion FROM equipo WHERE estado='activo'");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> e = new HashMap<>();
                    e.put("id", rs.getInt("id_equipo"));
                    e.put("label", rs.getString("codigo_inventario") + " - " + rs.getString("descripcion"));
                    equipos.add(e);
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", e.getMessage());
        }
        req.setAttribute("lista", lista);
        req.setAttribute("equipos", equipos);
        req.getRequestDispatcher("mantenimientos.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accion = req.getParameter("accion");
        try (Connection conn = DatabaseConfig.getConnection()) {
            if ("crear".equals(accion)) {
                int idEquipo = Integer.parseInt(req.getParameter("id_equipo"));
                String inicio = req.getParameter("fecha_inicio").replace("T", " ") + ":00";
                String fin = req.getParameter("fecha_fin").replace("T", " ") + ":00";

                if (Timestamp.valueOf(fin).compareTo(Timestamp.valueOf(inicio)) <= 0) {
                    req.getSession().setAttribute("msgError", "La fecha de finalización debe ser posterior al inicio.");
                    resp.sendRedirect("mantenimientos");
                    return;
                }

                // Verificar traslape con reservas confirmadas
                String checkRes = "SELECT COUNT(*) FROM reserva_equipo re JOIN reserva r ON re.id_reserva=r.id_reserva " +
                                  "WHERE re.id_equipo=? AND r.estado='confirmada' AND (? < r.fecha_fin AND ? > r.fecha_inicio)";
                try (PreparedStatement ps = conn.prepareStatement(checkRes)) {
                    ps.setInt(1, idEquipo);
                    ps.setString(2, inicio);
                    ps.setString(3, fin);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        req.getSession().setAttribute("msgError", "Conflicto: El equipo tiene una reserva confirmada en ese horario.");
                        resp.sendRedirect("mantenimientos");
                        return;
                    }
                }

                String sql = "INSERT INTO mantenimiento (id_equipo, fecha_inicio, fecha_fin, motivo, observaciones, estado) VALUES (?, ?, ?, ?, ?, 'programado')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, idEquipo);
                    ps.setString(2, inicio);
                    ps.setString(3, fin);
                    ps.setString(4, req.getParameter("motivo"));
                    ps.setString(5, req.getParameter("observaciones"));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Mantenimiento programado exitosamente.");
                }
            } else if ("finalizar".equals(accion)) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE mantenimiento SET estado='finalizado' WHERE id_mantenimiento=?")) {
                    ps.setInt(1, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Mantenimiento marcado como finalizado.");
                }
            } else if ("anular".equals(accion)) {
                String motivoAnulacion = req.getParameter("motivo_anulacion");
                try (PreparedStatement ps = conn.prepareStatement("UPDATE mantenimiento SET estado='anulado', observaciones=CONCAT(IFNULL(observaciones,''), ' | ANULADO: ', ?) WHERE id_mantenimiento=?")) {
                    ps.setString(1, motivoAnulacion != null ? motivoAnulacion : "Sin motivo");
                    ps.setInt(2, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Mantenimiento anulado conservando historial.");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("msgError", "Error: " + e.getMessage());
        }
        resp.sendRedirect("mantenimientos");
    }
}
