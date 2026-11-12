package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/reportes")
public class ReportesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tipo = req.getParameter("tipo");
        List<Map<String, Object>> configs = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement("SELECT * FROM configuracion_reporte ORDER BY id_config DESC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> c = new HashMap<>();
                    c.put("id", rs.getInt("id_config"));
                    c.put("nombre", rs.getString("nombre"));
                    c.put("tipo", rs.getString("tipo_reporte"));
                    c.put("filtros", rs.getString("filtros_json"));
                    configs.add(c);
                }
            }

            if (tipo != null && !tipo.isEmpty()) {
                String sql = switch (tipo) {
                    case "inventario" -> "SELECT codigo_inventario AS Código, descripcion AS Descripción, tipo AS Tipo, marca AS Marca, IFNULL(CONCAT(ram_gb,' GB'),'N/A') AS RAM, ubicacion AS Ubicación, estado AS Estado FROM equipo";
                    case "reservas" -> "SELECT r.id_reserva AS ID, s.nombre_completo AS Solicitante, r.tipo_equipo AS Tipo, r.cantidad AS Cant, r.fecha_inicio AS Inicio, r.fecha_fin AS Fin, r.estrategia AS Estrategia, r.estado AS Estado FROM reserva r JOIN solicitante s ON r.id_solicitante=s.id_solicitante";
                    case "uso_equipos" -> "SELECT e.codigo_inventario AS Equipo, e.descripcion AS Descripción, COALESCE(SUM(TIMESTAMPDIFF(HOUR, r.fecha_inicio, r.fecha_fin)),0) AS Horas_Reservadas FROM equipo e LEFT JOIN reserva_equipo re ON e.id_equipo=re.id_equipo LEFT JOIN reserva r ON re.id_reserva=r.id_reserva AND r.estado IN ('confirmada','finalizada') GROUP BY e.id_equipo, e.codigo_inventario, e.descripcion";
                    case "mantenimientos" -> "SELECT m.id_mantenimiento AS ID, e.codigo_inventario AS Equipo, m.fecha_inicio AS Inicio, m.fecha_fin AS Fin, m.motivo AS Motivo, m.estado AS Estado FROM mantenimiento m JOIN equipo e ON m.id_equipo=e.id_equipo";
                    case "prestamos" -> "SELECT p.id_prestamo AS ID, s.nombre_completo AS Solicitante, p.recibido_por AS Recibió, p.fecha_entrega AS Entrega, p.fecha_devolucion_prevista AS Devolución_Prevista, p.estado AS Estado FROM prestamo p JOIN reserva r ON p.id_reserva=r.id_reserva JOIN solicitante s ON r.id_solicitante=s.id_solicitante";
                    case "incidencias" -> "SELECT i.id_incidencia AS ID, e.codigo_inventario AS Equipo, i.prioridad AS Prioridad, i.descripcion AS Falla, i.responsable AS Responsable, i.estado AS Estado, IFNULL(i.solucion,'Pendiente') AS Solución FROM incidencia i JOIN equipo e ON i.id_equipo=e.id_equipo";
                    default -> "";
                };
                if (!sql.isEmpty()) {
                    try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                        ResultSetMetaData meta = rs.getMetaData();
                        int colCount = meta.getColumnCount();
                        List<String> columnas = new ArrayList<>();
                        for (int i = 1; i <= colCount; i++) columnas.add(meta.getColumnLabel(i));

                        List<List<String>> filas = new ArrayList<>();
                        while (rs.next()) {
                            List<String> fila = new ArrayList<>();
                            for (int i = 1; i <= colCount; i++) fila.add(rs.getString(i));
                            filas.add(fila);
                        }
                        req.setAttribute("columnas", columnas);
                        req.setAttribute("filas", filas);
                        req.setAttribute("reporteActual", tipo.toUpperCase().replace("_", " "));
                    }
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", e.getMessage());
        }
        req.setAttribute("configs", configs);
        req.getRequestDispatcher("reportes.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accion = req.getParameter("accion");
        try (Connection conn = DatabaseConfig.getConnection()) {
            if ("guardar".equals(accion)) {
                try (PreparedStatement ps = conn.prepareStatement("INSERT INTO configuracion_reporte (nombre, tipo_reporte, filtros_json) VALUES (?, ?, ?)")) {
                    ps.setString(1, req.getParameter("nombre"));
                    ps.setString(2, req.getParameter("tipo_reporte"));
                    ps.setString(3, req.getParameter("filtros"));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Configuración de reporte guardada.");
                }
            } else if ("eliminar".equals(accion)) {
                try (PreparedStatement ps = conn.prepareStatement("DELETE FROM configuracion_reporte WHERE id_config=?")) {
                    ps.setInt(1, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Configuración eliminada.");
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", e.getMessage());
        }
        resp.sendRedirect("reportes");
    }
}
