
package com.cybershield.servlet;

import com.cybershield.dao.UserDao;
import com.cybershield.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/login.jsp"
        );
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String identifier = request.getParameter("username");
        String password = request.getParameter("password");

        if (identifier == null || password == null
                || identifier.isBlank() || password.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?error=required"
            );
            return;
        }

        try {

            User user = new UserDao().findByLogin(identifier.trim());

            String storedHash =
                    user == null ? null : user.getPasswordHash();

            boolean passwordMatches = false;

            if (storedHash != null && storedHash.startsWith("$2")) {
                try {
                    passwordMatches = BCrypt.checkpw(
                            password, storedHash
                    );
                } catch (IllegalArgumentException e) {
                    passwordMatches = false;
                }
            }

            if (!passwordMatches) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/login.jsp?error=1"
                );
                return;
            }

            // Prevent session fixation
            HttpSession oldSession = request.getSession(false);

            if (oldSession != null) {
                oldSession.invalidate();
            }

            // Create a new session
            HttpSession session = request.getSession(true);

            session.setAttribute("userId", user.getId());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("role", user.getRole());

            session.setMaxInactiveInterval(20 * 60);

            // Role-based redirection
            String target = user.isAdmin()
                    ? "/admin/dashboard"
                    : "/dashboard";

            response.sendRedirect(
                    request.getContextPath() + target
            );

        } catch (SQLException e) {

            getServletContext().log(
                    "CyberShield login database error.", e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Login is temporarily unavailable."
            );
        }
    }
}
