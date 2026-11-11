
package com.cybershield.servlet;

import com.cybershield.dao.UserDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.SQLException;
import java.util.regex.Pattern;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile(
                "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
            );

    private static final Pattern USERNAME_PATTERN =
            Pattern.compile("^[A-Za-z0-9._-]{3,50}$");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/register.jsp"
        );
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Get registration details
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Check required fields
        if (fullName == null || email == null
                || username == null || password == null) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=required"
            );
            return;
        }

        // Remove unnecessary spaces
        fullName = fullName.trim();
        email = email.trim();
        username = username.trim();

        // Validate registration information
        if (fullName.isEmpty()
                || email.isEmpty()
                || username.isEmpty()
                || password.length() < 8
                || password.length() > 72
                || fullName.length() > 100
                || email.length() > 100
                || username.length() > 50
                || !EMAIL_PATTERN.matcher(email).matches()
                || !USERNAME_PATTERN.matcher(username).matches()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=validation"
            );
            return;
        }

        // Hash password using BCrypt
        String passwordHash;

        try {
            passwordHash = BCrypt.hashpw(
                    password,
                    BCrypt.gensalt(12)
            );
        } catch (IllegalArgumentException e) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=validation"
            );
            return;
        }

        // Save user information in database
        try {

            UserDao userDao = new UserDao();

            userDao.create(
                    fullName,
                    email,
                    username,
                    passwordHash
            );

            // Registration successful
            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?registered=1"
            );

        } catch (SQLException e) {

            if ("23000".equals(e.getSQLState())) {

                // Duplicate email or username
                response.sendRedirect(
                        request.getContextPath()
                        + "/register.jsp?error=duplicate"
                );

            } else {

                getServletContext().log(
                        "CyberShield registration failed.",
                        e
                );

                response.sendRedirect(
                        request.getContextPath()
                        + "/register.jsp?error=server"
                );
            }
        }
    }
}
