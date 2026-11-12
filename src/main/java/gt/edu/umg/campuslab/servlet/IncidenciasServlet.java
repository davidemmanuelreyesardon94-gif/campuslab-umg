package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/incidencias")
public class IncidenciasServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Map<String, Object>> lista = new ArrayList<>();
        List<Map<String, Object>> equipos = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            String sql = "SELECT i.*, e.codigo_inventario, e.descripcion AS eq_desc FROM incidencia i JOIN equipo e ON i.id_equipo=e.id_equipo ORDER BY i.id_incidencia DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id_incidencia"));
                    m.put("equipo", rs.getString("codigo_inventario") + " - " + rs.getString("eq_desc"));
                    m.put("fecha", rs.getString("fecha_registro"));
                    m.put("descripcion", rs.getString("descripcion"));
                    m.put("prioridad", rs.getString("prioridad"));
                    m.put("responsable", rs.getString("responsable"));
                    m.put("estado", rs.getString("estado"));
                    m.put("solucion", rs.getString("solucion"));
                    lista.add(m);
                }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT id_equipo, codigo_inventario, descripcion FROM equipo");
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
        req.getRequestDispatcher("incidencias.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accion = req.getParameter("accion");
        try (Connection conn = DatabaseConfig.getConnection()) {
            if ("crear".equals(accion)) {
                String sql = "INSERT INTO incidencia (id_equipo, descripcion, prioridad, responsable, estado) VALUES (?, ?, ?, ?, 'abierta')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(req.getParameter("id_equipo")));
                    ps.setString(2, req.getParameter("descripcion"));
                    ps.setString(3, req.getParameter("prioridad"));
                    ps.setString(4, req.getParameter("responsable"));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Incidencia registrada.");
                }
            } else if ("resolver".equals(accion)) {
                String solucion = req.getParameter("solucion");
                if (solucion == null || solucion.trim().isEmpty()) {
                    req.getSession().setAttribute("msgError", "Debe ingresar la solución aplicada.");
                    resp.sendRedirect("incidencias");
                    return;
                }
                String sql = "UPDATE incidencia SET estado='resuelta', solucion=?, fecha_resolucion=NOW() WHERE id_incidencia=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, solucion);
                    ps.setInt(2, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Incidencia marcada como resuelta.");
                }
            } else if ("anular".equals(accion)) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE incidencia SET estado='anulada' WHERE id_incidencia=?")) {
                    ps.setInt(1, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Incidencia anulada.");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("msgError", "Error: " + e.getMessage());
        }
        resp.sendRedirect("incidencias");
    }
}
