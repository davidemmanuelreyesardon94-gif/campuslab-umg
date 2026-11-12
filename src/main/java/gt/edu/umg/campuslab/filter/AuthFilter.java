package gt.edu.umg.campuslab.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String uri = req.getRequestURI();

        boolean isLoginPage = uri.endsWith("login.jsp") || uri.endsWith("/login");
        boolean isStaticResource = uri.contains("/assets/") || uri.contains("/img/")
                || uri.endsWith(".css") || uri.endsWith(".js")
                || uri.endsWith(".png") || uri.endsWith(".jpg");

        HttpSession session = req.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("usuario") != null);

        if (isLoggedIn || isLoginPage || isStaticResource) {
            chain.doFilter(request, response);
        } else {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }
}