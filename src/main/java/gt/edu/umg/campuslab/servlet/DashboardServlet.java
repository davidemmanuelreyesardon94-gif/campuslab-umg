package gt.edu.umg.campuslab.servlet;

import gt.edu.umg.campuslab.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try (Connection conn = DatabaseConfig.getConnection(); Statement st = conn.createStatement()) {
            req.setAttribute("totalEquipos", getCount(st, "SELECT COUNT(*) FROM equipo WHERE estado='activo'"));
            req.setAttribute("totalSolicitantes", getCount(st, "SELECT COUNT(*) FROM solicitante WHERE estado='activo'"));
            req.setAttribute("reservasActivas", getCount(st, "SELECT COUNT(*) FROM reserva WHERE estado='confirmada'"));
            req.setAttribute("prestamosAbiertos", getCount(st, "SELECT COUNT(*) FROM prestamo WHERE estado='abierto'"));
            req.setAttribute("mantenimientosProg", getCount(st, "SELECT COUNT(*) FROM mantenimiento WHERE estado='programado'"));
            req.setAttribute("incidenciasAbiertas", getCount(st, "SELECT COUNT(*) FROM incidencia WHERE estado IN ('abierta','en_atencion')"));
        } catch (SQLException e) {
            req.setAttribute("error", e.getMessage());
        }
        req.getRequestDispatcher("dashboard.jsp").forward(req, resp);
    }

    private int getCount(Statement st, String sql) throws SQLException {
        try (ResultSet rs = st.executeQuery(sql)) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
}
