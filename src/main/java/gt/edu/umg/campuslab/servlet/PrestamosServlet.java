package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/prestamos")
public class PrestamosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Map<String, Object>> prestamos = new ArrayList<>();
        List<Map<String, Object>> reservasConfirmadas = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            String sql = "SELECT p.*, r.motivo_uso, s.nombre_completo, " +
                         "(SELECT GROUP_CONCAT(e.codigo_inventario SEPARATOR ', ') FROM prestamo_equipo pe JOIN equipo e ON pe.id_equipo=e.id_equipo WHERE pe.id_prestamo=p.id_prestamo) AS equipos " +
                         "FROM prestamo p JOIN reserva r ON p.id_reserva=r.id_reserva JOIN solicitante s ON r.id_solicitante=s.id_solicitante ORDER BY p.id_prestamo DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id_prestamo"));
                    m.put("idReserva", rs.getInt("id_reserva"));
                    m.put("solicitante", rs.getString("nombre_completo"));
                    m.put("recibidoPor", rs.getString("recibido_por"));
                    m.put("entrega", rs.getString("fecha_entrega"));
                    m.put("prevista", rs.getString("fecha_devolucion_prevista"));
                    m.put("estado", rs.getString("estado"));
                    m.put("equipos", rs.getString("equipos"));
                    prestamos.add(m);
                }
            }
            String sqlRes = "SELECT r.id_reserva, s.nombre_completo, r.fecha_inicio, r.fecha_fin FROM reserva r JOIN solicitante s ON r.id_solicitante=s.id_solicitante " +
                            "WHERE r.estado='confirmada' AND r.id_reserva NOT IN (SELECT id_reserva FROM prestamo WHERE estado != 'anulado')";
            try (PreparedStatement ps = conn.prepareStatement(sqlRes); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> r = new HashMap<>();
                    r.put("id", rs.getInt("id_reserva"));
                    r.put("label", "Reserva #" + rs.getInt("id_reserva") + " - " + rs.getString("nombre_completo") + " (" + rs.getString("fecha_inicio") + ")");
                    reservasConfirmadas.add(r);
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", e.getMessage());
        }
        req.setAttribute("prestamos", prestamos);
        req.setAttribute("reservasConfirmadas", reservasConfirmadas);
        req.getRequestDispatcher("prestamos.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accion = req.getParameter("accion");
        try (Connection conn = DatabaseConfig.getConnection()) {
            if ("entregar".equals(accion)) {
                int idReserva = Integer.parseInt(req.getParameter("id_reserva"));
                String recibidoPor = req.getParameter("recibido_por");
                String obs = req.getParameter("observaciones");

                conn.setAutoCommit(false);
                try {
                    String fechaFinRes = null;
                    try (PreparedStatement psR = conn.prepareStatement("SELECT fecha_fin FROM reserva WHERE id_reserva=?")) {
                        psR.setInt(1, idReserva);
                        ResultSet rs = psR.executeQuery();
                        if (rs.next()) fechaFinRes = rs.getString("fecha_fin");
                    }

                    int idPrestamo = 0;
                    String insP = "INSERT INTO prestamo (id_reserva, fecha_entrega, recibido_por, fecha_devolucion_prevista, observaciones, estado) VALUES (?, NOW(), ?, ?, ?, 'abierto')";
                    try (PreparedStatement psP = conn.prepareStatement(insP, Statement.RETURN_GENERATED_KEYS)) {
                        psP.setInt(1, idReserva);
                        psP.setString(2, recibidoPor);
                        psP.setString(3, fechaFinRes);
                        psP.setString(4, obs);
                        psP.executeUpdate();
                        ResultSet keys = psP.getGeneratedKeys();
                        if (keys.next()) idPrestamo = keys.getInt(1);
                    }

                    try (PreparedStatement psEq = conn.prepareStatement("SELECT id_equipo FROM reserva_equipo WHERE id_reserva=?");
                         PreparedStatement psInsEq = conn.prepareStatement("INSERT INTO prestamo_equipo (id_prestamo, id_equipo) VALUES (?, ?)")) {
                        psEq.setInt(1, idReserva);
                        ResultSet rsEq = psEq.executeQuery();
                        while (rsEq.next()) {
                            psInsEq.setInt(1, idPrestamo);
                            psInsEq.setInt(2, rsEq.getInt("id_equipo"));
                            psInsEq.addBatch();
                        }
                        psInsEq.executeBatch();
                    }
                    conn.commit();
                    req.getSession().setAttribute("msgSuccess", "Entrega física registrada (Préstamo #" + idPrestamo + ").");
                } catch (SQLException ex) {
                    conn.rollback();
                    throw ex;
                } finally {
                    conn.setAutoCommit(true);
                }
            } else if ("devolver".equals(accion)) {
                int idPrestamo = Integer.parseInt(req.getParameter("id"));
                String condicion = req.getParameter("condicion");
                conn.setAutoCommit(false);
                try {
                    try (PreparedStatement ps1 = conn.prepareStatement("UPDATE prestamo_equipo SET fecha_devolucion_real=NOW(), condicion_devolucion=? WHERE id_prestamo=? AND fecha_devolucion_real IS NULL")) {
                        ps1.setString(1, condicion != null ? condicion : "Buen estado");
                        ps1.setInt(2, idPrestamo);
                        ps1.executeUpdate();
                    }
                    try (PreparedStatement ps2 = conn.prepareStatement("UPDATE prestamo SET estado='devuelto' WHERE id_prestamo=?")) {
                        ps2.setInt(1, idPrestamo);
                        ps2.executeUpdate();
                    }
                    try (PreparedStatement ps3 = conn.prepareStatement("UPDATE reserva SET estado='finalizada' WHERE id_reserva=(SELECT id_reserva FROM prestamo WHERE id_prestamo=?)")) {
                        ps3.setInt(1, idPrestamo);
                        ps3.executeUpdate();
                    }
                    conn.commit();
                    req.getSession().setAttribute("msgSuccess", "Equipos devueltos y reserva finalizada correctamente.");
                } catch (SQLException ex) {
                    conn.rollback();
                    throw ex;
                } finally {
                    conn.setAutoCommit(true);
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("msgError", "Error en préstamo: " + e.getMessage());
        }
        resp.sendRedirect("prestamos");
    }
}
