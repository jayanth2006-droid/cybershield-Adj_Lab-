
package com.cybershield.servlet;

import com.cybershield.model.Incident;
import com.cybershield.model.User;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

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

        String userSql =
                "SELECT id, full_name, username, email, role " +
                "FROM users WHERE id = ?";

        String statsSql =
                "SELECT COUNT(*) AS total, " +
                "SUM(CASE WHEN status = 'OPEN' THEN 1 ELSE 0 END) AS open_count, " +
                "SUM(CASE WHEN status = 'IN_PROGRESS' THEN 1 ELSE 0 END) AS progress_count, " +
                "SUM(CASE WHEN status = 'RESOLVED' THEN 1 ELSE 0 END) AS resolved_count " +
                "FROM incidents WHERE reported_by = ?";

        String recentSql =
                "SELECT id, title, description, incident_type, " +
                "severity, status, reported_by, created_at " +
                "FROM incidents WHERE reported_by = ? " +
                "ORDER BY created_at DESC LIMIT 6";

        String severitySql =
                "SELECT severity, COUNT(*) AS total " +
                "FROM incidents WHERE reported_by = ? " +
                "GROUP BY severity";

        try (Connection con = DBConnection.getConnection()) {

            // Load logged-in user
            User dashboardUser = new User();

            try (PreparedStatement ps = con.prepareStatement(userSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (!rs.next()) {
                        session.invalidate();
                        response.sendRedirect(
                                request.getContextPath() + "/login.jsp");
                        return;
                    }

                    dashboardUser.setId(rs.getInt("id"));
                    dashboardUser.setFullName(rs.getString("full_name"));
                    dashboardUser.setUsername(rs.getString("username"));
                    dashboardUser.setEmail(rs.getString("email"));
                    dashboardUser.setRole(rs.getString("role"));
                }
            }

            request.setAttribute("user", dashboardUser);

            session.setAttribute("role", dashboardUser.getRole());
            session.setAttribute("fullName", dashboardUser.getFullName());

            // Load dashboard statistics
            int[] stats = new int[4];

            try (PreparedStatement ps = con.prepareStatement(statsSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    if (rs.next()) {
                        stats[0] = rs.getInt("total");
                        stats[1] = rs.getInt("open_count");
                        stats[2] = rs.getInt("progress_count");
                        stats[3] = rs.getInt("resolved_count");
                    }
                }
            }

            request.setAttribute("stats", stats);

            // Load recent incidents
            List<Incident> recentIncidents = new ArrayList<>();

            try (PreparedStatement ps = con.prepareStatement(recentSql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {

                        Incident incident = new Incident();

                        incident.setId(rs.getInt("id"));
                        incident.setTitle(rs.getString("title"));
                        incident.setDescription(rs.getString("description"));
                        incident.setIncidentType(rs.getString("incident_type"));
                        incident.setSeverity(rs.getString("severity"));
                        incident.setStatus(rs.getString("status"));
                        incident.setReportedBy(rs.getInt("reported_by"));
                        incident.setCreatedAt(rs.getTimestamp("created_at"));

                        recentIncidents.add(incident);
                    }
                }
            }

            request.setAttribute("recentIncidents", recentIncidents);

            // Load severity distribution
            Map<String, Integer> severityDistribution =
                    new LinkedHashMap<>();

            try (PreparedStatement ps = con.prepareStatement(severitySql)) {

                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {

                    while (rs.next()) {
                        severityDistribution.put(
                                rs.getString("severity"),
                                rs.getInt("total"));
                    }
                }
            }

            request.setAttribute(
                    "severityDistribution", severityDistribution);

            // Forward to dashboard JSP
            request.getRequestDispatcher("/dashboard.jsp")
                    .forward(request, response);

        } catch (SQLException e) {

            getServletContext().log(
                    "Unable to load CyberShield dashboard.", e);

            throw new ServletException(
                    "Unable to load CyberShield dashboard.", e);
        }
    }
}
