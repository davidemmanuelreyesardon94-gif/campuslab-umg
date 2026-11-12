package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/solicitantes")
public class SolicitantesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String filtro = req.getParameter("q") != null ? req.getParameter("q").trim() : "";
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT * FROM solicitante WHERE codigo LIKE ? OR nombre_completo LIKE ? ORDER BY id_solicitante DESC";
        try (Connection conn = DatabaseConfig.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + filtro + "%");
            ps.setString(2, "%" + filtro + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id_solicitante"));
                    m.put("codigo", rs.getString("codigo"));
                    m.put("nombre", rs.getString("nombre_completo"));
                    m.put("correo", rs.getString("correo"));
                    m.put("departamento", rs.getString("departamento"));
                    m.put("estado", rs.getString("estado"));
                    lista.add(m);
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", "Error al consultar: " + e.getMessage());
        }
        req.setAttribute("lista", lista);
        req.setAttribute("q", filtro);
        req.getRequestDispatcher("solicitantes.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accion = req.getParameter("accion");
        try (Connection conn = DatabaseConfig.getConnection()) {
            if ("crear".equals(accion)) {
                String sql = "INSERT INTO solicitante (codigo, nombre_completo, correo, departamento, estado) VALUES (?, ?, ?, ?, 'activo')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, req.getParameter("codigo"));
                    ps.setString(2, req.getParameter("nombre"));
                    ps.setString(3, req.getParameter("correo"));
                    ps.setString(4, req.getParameter("departamento"));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Solicitante registrado correctamente.");
                }
            } else if ("editar".equals(accion)) {
                String sql = "UPDATE solicitante SET nombre_completo=?, correo=?, departamento=?, estado=? WHERE id_solicitante=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, req.getParameter("nombre"));
                    ps.setString(2, req.getParameter("correo"));
                    ps.setString(3, req.getParameter("departamento"));
                    ps.setString(4, req.getParameter("estado"));
                    ps.setInt(5, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Solicitante actualizado.");
                }
            } else if ("baja".equals(accion)) {
                String sql = "UPDATE solicitante SET estado='inactivo' WHERE id_solicitante=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Solicitante desactivado (Baja lógica aplicada).");
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", "Error en operación (verifique código único): " + e.getMessage());
        }
        resp.sendRedirect("solicitantes");
    }
}
