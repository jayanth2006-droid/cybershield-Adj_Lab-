package com.cybershield.servlet.admin;

import com.cybershield.dao.UserDao;
import com.cybershield.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class AdminUsersServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        User admin = (User) request.getAttribute("currentUser");
        if (admin == null || !admin.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access is required.");
            return;
        }

        try {
            List<User> users = new UserDao().findAll();
            request.setAttribute("adminUser", admin);
            request.setAttribute("users", users);
            request.setAttribute("userCount", users.size());

            request.getRequestDispatcher("/WEB-INF/views/admin/users.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Unable to load users.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        User admin = (User) request.getAttribute("currentUser");
        if (admin == null || !admin.isAdmin()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access is required.");
            return;
        }

        int targetId;
        try {
            targetId = Integer.parseInt(request.getParameter("userId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(
                    request.getContextPath() + "/admin/users?error=role");
            return;
        }

        String role = request.getParameter("role");
        role = role == null ? "" : role.trim().toUpperCase();
        if (!"ADMIN".equals(role) && !"USER".equals(role)) {
            response.sendRedirect(
                    request.getContextPath() + "/admin/users?error=role");
            return;
        }

        if (targetId == admin.getId()) {
            response.sendRedirect(
                    request.getContextPath() + "/admin/users?error=self");
            return;
        }

        try {
            UserDao dao = new UserDao();
            User target = dao.findById(targetId);
            if (target == null) {
                response.sendRedirect(
                        request.getContextPath() + "/admin/users?error=missing");
                return;
            }

            if (role.equalsIgnoreCase(target.getRole())) {
                response.sendRedirect(
                        request.getContextPath() + "/admin/users?roleUpdated=1");
                return;
            }

            if (target.isAdmin() && "USER".equals(role)
                    && dao.countAdmins() <= 1) {
                response.sendRedirect(
                        request.getContextPath() + "/admin/users?error=last_admin");
                return;
            }

            if (dao.updateRole(targetId, role)) {
                response.sendRedirect(
                        request.getContextPath() + "/admin/users?roleUpdated=1");
            } else {
                response.sendRedirect(
                        request.getContextPath() + "/admin/users?error=server");
            }
        } catch (SQLException e) {
            getServletContext().log("Unable to update user role.", e);
            response.sendRedirect(
                    request.getContextPath() + "/admin/users?error=server");
        }
    }
}
