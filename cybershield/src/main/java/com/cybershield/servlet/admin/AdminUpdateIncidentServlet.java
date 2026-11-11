package com.cybershield.servlet.admin;

import com.cybershield.dao.IncidentDao;
import com.cybershield.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

public class AdminUpdateIncidentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

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

        int incidentId;
        try {
            incidentId = Integer.parseInt(request.getParameter("incidentId"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid incident ID.");
            return;
        }

        String status = request.getParameter("status");
        String notes = request.getParameter("investigationNotes");

        if (!IncidentDao.isValidStatus(status)) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/incident?id=" + incidentId + "&error=status");
            return;
        }
        if (notes != null && notes.length() > 5000) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/incident?id=" + incidentId + "&error=notes");
            return;
        }

        try {
            boolean updated = new IncidentDao().updateStatus(
                    incidentId, status, notes, admin.getId(), true, admin.getId());

            if (updated) {
                response.sendRedirect(request.getContextPath()
                        + "/admin/incident?id=" + incidentId + "&updated=1");
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Incident not found.");
            }
        } catch (SQLException e) {
            throw new ServletException(
                    "Unable to update the incident.", e);
        }
    }
}
