package com.cybershield.servlet.admin;

import com.cybershield.dao.IncidentDao;
import com.cybershield.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

public class AdminIncidentsServlet extends HttpServlet {

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

        String search = trim(request.getParameter("q"));
        String status = trim(request.getParameter("status"));
        String severity = trim(request.getParameter("severity"));

        try {
            IncidentDao dao = new IncidentDao();
            request.setAttribute("adminUser", admin);
            request.setAttribute("incidents",
                    dao.findAll(search, status, severity));
            request.setAttribute("search", search);
            request.setAttribute("statusFilter", status);
            request.setAttribute("severityFilter", severity);
            request.setAttribute("stats", dao.getStats(null));

            request.getRequestDispatcher("/WEB-INF/views/admin/incidents.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load all incidents.", e);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
