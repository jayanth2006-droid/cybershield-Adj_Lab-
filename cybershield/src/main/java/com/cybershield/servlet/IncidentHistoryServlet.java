
package com.cybershield.servlet;

import com.cybershield.model.Incident;
import com.cybershield.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/incident-history")
public class IncidentHistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

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

        int userId;

        try {
            userId = Integer.parseInt(
                    session.getAttribute("userId").toString());
        } catch (NumberFormatException e) {
            session.invalidate();
            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        String search = trim(request.getParameter("q"));
        String status = trim(request.getParameter("status"));
        String severity = trim(request.getParameter("severity"));

        // Validate status
        if (!status.isEmpty()
                && !status.equals("OPEN")
                && !status.equals("IN_PROGRESS")
                && !status.equals("RESOLVED")) {
            status = "";
        }

        // Validate severity
        if (!severity.isEmpty()
                && !severity.equals("LOW")
                && !severity.equals("MEDIUM")
                && !severity.equals("HIGH")
                && !severity.equals("CRITICAL")) {
            severity = "";
        }

        String userSql =
                "SELECT id, full_name, username, email, role " +
                "FROM users WHERE id = ?";

        StringBuilder sql = new StringBuilder(
                "SELECT id, title, description, incident_type, " +
                "severity, status, reported_by, created_at, resolved_at " +
                "FROM incidents WHERE reported_by = ?");

        if (!search.isEmpty()) {
            sql.append(" AND (title LIKE ? OR description LIKE ? OR incident_type LIKE ?)");
        }

        if (!status.isEmpty()) {
            sql.append(" AND status = ?");
        }

        if (!severity.isEmpty()) {
            sql.append(" AND severity = ?");
        }

        sql.append(" ORDER BY created_at DESC");

        try (Connection con = DBConnection.getConnection()) {

            // Verify user
            try (PreparedStatement ps = con.prepareStatement(userSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        session.invalidate();
                        response.sendRedirect(
                                request.getContextPath() + "/login.jsp");
                        return;
                    }

                    Map<String, Object> user = new HashMap<>();

                    user.put("id", rs.getInt("id"));
                    user.put("fullName", rs.getString("full_name"));
                    user.put("username", rs.getString("username"));
                    user.put("email", rs.getString("email"));
                    user.put("role", rs.getString("role"));

                    request.setAttribute("user", user);
                }
            }

            // Retrieve incidents as Incident objects
            List<Incident> incidents = new ArrayList<>();

            try (PreparedStatement ps =
                         con.prepareStatement(sql.toString())) {

                int index = 1;

                ps.setInt(index++, userId);

                if (!search.isEmpty()) {
                    String like = "%" + escapeLike(search) + "%";
                    ps.setString(index++, like);
                    ps.setString(index++, like);
                    ps.setString(index++, like);
                }

                if (!status.isEmpty()) {
                    ps.setString(index++, status);
                }

                if (!severity.isEmpty()) {
                    ps.setString(index++, severity);
                }

                try (ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {

                        Incident incident = new Incident();

                        incident.setId(rs.getInt("id"));
                        incident.setTitle(rs.getString("title"));
                        incident.setDescription(
                                rs.getString("description"));
                        incident.setIncidentType(
                                rs.getString("incident_type"));
                        incident.setSeverity(
                                rs.getString("severity"));
                        incident.setStatus(
                                rs.getString("status"));
                        incident.setReportedBy(
                                rs.getInt("reported_by"));
                        incident.setCreatedAt(
                                rs.getTimestamp("created_at"));
                        incident.setResolvedAt(
                                rs.getTimestamp("resolved_at"));

                        incidents.add(incident);
                    }
                }
            }

            request.setAttribute("incidents", incidents);
            request.setAttribute("search", search);
            request.setAttribute("statusFilter", status);
            request.setAttribute("severityFilter", severity);

            request.getRequestDispatcher("/incident-history.jsp")
                    .forward(request, response);

        } catch (SQLException e) {

            getServletContext().log(
                    "Failed to retrieve incident history.", e);

            throw new ServletException(
                    "Unable to load incident history.", e);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String escapeLike(String value) {
        return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }
}
