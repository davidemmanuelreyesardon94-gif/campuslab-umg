package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String user = req.getParameter("username");
        String pass = req.getParameter("password");

        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM usuario WHERE username = ? AND password_hash = ? AND activo = 1")) {
            ps.setString(1, user);
            ps.setString(2, pass);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    HttpSession session = req.getSession();
                    session.setAttribute("usuario", rs.getString("username"));
                    session.setAttribute("nombreCompleto", rs.getString("nombre_completo"));
                    session.setAttribute("rol", rs.getString("rol"));
                    resp.sendRedirect("dashboard");
                    return;
                }
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error de conexión a MySQL: " + e.getMessage());
            req.getRequestDispatcher("login.jsp").forward(req, resp);
            return;
        }
        req.setAttribute("error", "Credenciales incorrectas o usuario inactivo.");
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("logout".equals(req.getParameter("action"))) {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
        }
        resp.sendRedirect("login.jsp");
    }
}
