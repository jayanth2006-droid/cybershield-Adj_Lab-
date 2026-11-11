
package com.cybershield.servlet;

import com.cybershield.dao.IncidentDao;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/update-incident-status")
public class UpdateIncidentStatusServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // Check user session
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        // Get logged-in user ID
        int userId;

        try {
            Object sessionUserId = session.getAttribute("userId");

            if (!(sessionUserId instanceof Number)) {
                response.sendError(
                        HttpServletResponse.SC_UNAUTHORIZED,
                        "Invalid user session.");
                return;
            }

            userId = ((Number) sessionUserId).intValue();

        } catch (Exception e) {
            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Unable to identify logged-in user.");
            return;
        }

        // Get incident ID
        int incidentId;

        try {
            incidentId = Integer.parseInt(
                    request.getParameter("incidentId"));

            if (incidentId <= 0) {
                throw new NumberFormatException();
            }

        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid incident ID.");
            return;
        }

        // Get and validate status
        String status = request.getParameter("status");

        if (!IncidentDao.isValidStatus(status)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid incident status.");
            return;
        }

        // Update incident status
        try {

            IncidentDao incidentDao = new IncidentDao();

            boolean updated = incidentDao.updateStatus(
                    incidentId,
                    status,
                    null,
                    userId,
                    false,
                    userId
            );

            if (updated) {

                response.sendRedirect(
                        request.getContextPath()
                        + "/incident-history?updated=1"
                );

            } else {

                response.sendError(
                        HttpServletResponse.SC_NOT_FOUND,
                        "Incident not found or not owned by this user."
                );
            }

        } catch (SQLException e) {

            throw new ServletException(
                    "Unable to update incident status.", e);
        }
    }
}
