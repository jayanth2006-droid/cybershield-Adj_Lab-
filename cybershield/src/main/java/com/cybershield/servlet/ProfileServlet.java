
package com.cybershield.servlet;

import com.cybershield.dao.UserDao;
import com.cybershield.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.SQLException;
import java.util.regex.Pattern;

public class ProfileServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = resolveUserId(session);

        if (userId <= 0) {
            session.invalidate();
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            User user = new UserDao().findById(userId);
            if (user == null) {
                session.invalidate();
                response.sendRedirect(
                        request.getContextPath() + "/login.jsp");
                return;
            }
            request.setAttribute("user", user);
            request.getRequestDispatcher("/profile.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            getServletContext().log("Unable to load profile.", e);
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load the profile right now.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = resolveUserId(session);

        if (userId <= 0) {
            session.invalidate();
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        if ("password".equals(trim(request.getParameter("action")))) {
            changePassword(request, response, session, userId);
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));

        if (fullName.isEmpty() || fullName.length() > 100
                || email.isEmpty() || email.length() > 100
                || !EMAIL_PATTERN.matcher(email).matches()) {
            response.sendRedirect(
                    request.getContextPath() + "/profile?error=validation");
            return;
        }

        try {
            UserDao dao = new UserDao();
            if (dao.emailBelongsToOther(email, userId)) {
                response.sendRedirect(
                        request.getContextPath() + "/profile?error=duplicate");
                return;
            }

            if (dao.updateProfile(userId, fullName, email)) {
                session.setAttribute("fullName", fullName);
                response.sendRedirect(
                        request.getContextPath() + "/profile?saved=1");
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/profile?error=server");
            }
        } catch (SQLException e) {
            getServletContext().log("Unable to update profile.", e);
            response.sendRedirect(
                    request.getContextPath() + "/profile?error=server");
        }
    }

    private void changePassword(HttpServletRequest request,
                                HttpServletResponse response,
                                HttpSession session, int userId)
            throws IOException {

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (currentPassword == null || newPassword == null
                || confirmPassword == null || currentPassword.isEmpty()
                || newPassword.isEmpty() || confirmPassword.isEmpty()) {
            response.sendRedirect(
                    request.getContextPath() + "/profile?error=required");
            return;
        }

        if (newPassword.length() < 8 || newPassword.length() > 72) {
            response.sendRedirect(
                    request.getContextPath() + "/profile?error=password");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            response.sendRedirect(
                    request.getContextPath() + "/profile?error=password_match");
            return;
        }

        try {
            UserDao dao = new UserDao();
            User user = dao.findById(userId);

            if (user == null) {
                session.invalidate();
                response.sendRedirect(
                        request.getContextPath() + "/login.jsp");
                return;
            }

            String storedHash = user.getPasswordHash();
            boolean currentMatches = storedHash != null
                    && storedHash.startsWith("$2")
                    && BCrypt.checkpw(currentPassword, storedHash);

            if (!currentMatches) {
                response.sendRedirect(
                        request.getContextPath() + "/profile?error=password_current");
                return;
            }

            String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
            if (dao.updatePassword(userId, newHash)) {
                request.changeSessionId();
                response.sendRedirect(
                        request.getContextPath() + "/profile?passwordChanged=1");
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/profile?error=server");
            }
        } catch (SQLException | IllegalArgumentException e) {
            getServletContext().log("Unable to update password.", e);
            response.sendRedirect(
                    request.getContextPath() + "/profile?error=server");
        }
    }

    private int resolveUserId(HttpSession session) {
        Object sessionUserId = session.getAttribute("userId");
        if (sessionUserId instanceof Number) {
            return ((Number) sessionUserId).intValue();
        }
        return -1;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}