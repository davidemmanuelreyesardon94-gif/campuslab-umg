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
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/equipos")
public class EquiposServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String filtro = req.getParameter("q") != null ? req.getParameter("q").trim() : "";
        List < Map < String, Object > > lista = new ArrayList < > ();
        String sql = "SELECT * FROM equipo WHERE codigo_inventario LIKE ? OR descripcion LIKE ? OR tipo LIKE ? ORDER BY id_equipo DESC";
        try (Connection conn = DatabaseConfig.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + filtro + "%");
            ps.setString(2, "%" + filtro + "%");
            ps.setString(3, "%" + filtro + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map < String, Object > m = new HashMap < > ();
                    m.put("id", rs.getInt("id_equipo"));
                    m.put("codigo", rs.getString("codigo_inventario"));
                    m.put("descripcion", rs.getString("descripcion"));
                    m.put("tipo", rs.getString("tipo"));
                    m.put("marca", rs.getString("marca"));
                    m.put("modelo", rs.getString("modelo"));
                    m.put("ram", rs.getObject("ram_gb"));
                    m.put("ubicacion", rs.getString("ubicacion"));
                    m.put("estado", rs.getString("estado"));
                    lista.add(m);
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", e.getMessage());
        }
        req.setAttribute("lista", lista);
        req.setAttribute("q", filtro);
        req.getRequestDispatcher("equipos.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String accion = req.getParameter("accion");
        try (Connection conn = DatabaseConfig.getConnection()) {
            if ("crear".equals(accion)) {
                String tipo = req.getParameter("tipo");
                if ("otro".equals(tipo)) {
                    String tipoOtro = req.getParameter("tipo_otro");
                    if (tipoOtro == null || tipoOtro.trim().isEmpty()) {
                        req.getSession().setAttribute("msgError", "Debe especificar el nombre del nuevo tipo de equipo.");
                        resp.sendRedirect("equipos");
                        return;
                    }
                    tipo = tipoOtro.trim().toLowerCase();
                }

                String ramStr = req.getParameter("ram");
                Integer ram = ("computadora".equals(tipo) && ramStr != null && !ramStr.isEmpty()) ? Integer.parseInt(ramStr) : null;
                if ("computadora".equals(tipo) && (ram == null || ram <= 0)) {
                    req.getSession().setAttribute("msgError", "Las computadoras deben tener una RAM válida mayor a 0.");
                    resp.sendRedirect("equipos");
                    return;
                }

                String sql = "INSERT INTO equipo (codigo_inventario, descripcion, tipo, marca, modelo, ram_gb, ubicacion, estado) VALUES (?, ?, ?, ?, ?, ?, ?, 'activo')";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, req.getParameter("codigo"));
                    ps.setString(2, req.getParameter("descripcion"));
                    ps.setString(3, tipo);
                    ps.setString(4, req.getParameter("marca"));
                    ps.setString(5, req.getParameter("modelo"));
                    if (ram != null) {
                        ps.setInt(6, ram);
                    } else {
                        ps.setNull(6, Types.INTEGER);
                    }
                    ps.setString(7, req.getParameter("ubicacion"));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Equipo agregado al inventario.");
                }
            } else if ("editar".equals(accion)) {
                String ramStr = req.getParameter("ram");
                Integer ram = (ramStr != null && !ramStr.isEmpty()) ? Integer.parseInt(ramStr) : null;
                String sql = "UPDATE equipo SET descripcion=?, marca=?, modelo=?, ram_gb=?, ubicacion=?, estado=? WHERE id_equipo=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, req.getParameter("descripcion"));
                    ps.setString(2, req.getParameter("marca"));
                    ps.setString(3, req.getParameter("modelo"));
                    if (ram != null) {
                        ps.setInt(4, ram);
                    } else {
                        ps.setNull(4, Types.INTEGER);
                    }
                    ps.setString(5, req.getParameter("ubicacion"));
                    ps.setString(6, req.getParameter("estado"));
                    ps.setInt(7, Integer.parseInt(req.getParameter("id")));
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Equipo modificado.");
                }
            } else if ("baja".equals(accion)) {
                int idEquipo = Integer.parseInt(req.getParameter("id"));
                String checkSql = "SELECT COUNT(*) FROM prestamo_equipo pe JOIN prestamo p ON pe.id_prestamo=p.id_prestamo WHERE pe.id_equipo=? AND p.estado='abierto'";
                try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                    psCheck.setInt(1, idEquipo);
                    ResultSet rs = psCheck.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        req.getSession().setAttribute("msgError", "No puede desactivarse: el equipo tiene un préstamo abierto.");
                        resp.sendRedirect("equipos");
                        return;
                    }
                }
                String sql = "UPDATE equipo SET estado='inactivo' WHERE id_equipo=?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, idEquipo);
                    ps.executeUpdate();
                    req.getSession().setAttribute("msgSuccess", "Equipo desactivado del inventario.");
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("msgError", "Error SQL: " + e.getMessage());
        }
        resp.sendRedirect("equipos");
    }
}