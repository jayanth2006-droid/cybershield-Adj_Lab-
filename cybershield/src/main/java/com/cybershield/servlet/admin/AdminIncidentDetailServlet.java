package com.cybershield.servlet.admin;

import com.cybershield.dao.IncidentDao;
import com.cybershield.model.Incident;
import com.cybershield.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

public class AdminIncidentDetailServlet extends HttpServlet {

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

        int incidentId;
        try {
            incidentId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid incident ID.");
            return;
        }

        try {
            Incident incident = new IncidentDao().findById(incidentId);
            if (incident == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Incident not found.");
                return;
            }

            request.setAttribute("adminUser", admin);
            request.setAttribute("incident", incident);
            request.getRequestDispatcher(
                    "/WEB-INF/views/admin/incident-detail.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to load incident details.", e);
        }
    }
}
