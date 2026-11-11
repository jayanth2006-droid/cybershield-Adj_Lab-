package com.cybershield.servlet;

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

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/report-incident")
public class IncidentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Set<String> ALLOWED_TYPES =
            new HashSet<>(Arrays.asList(
                    "Phishing",
                    "Malware",
                    "Unauthorized Access",
                    "Password Attack",
                    "Data Breach",
                    "Network Attack",
                    "Suspicious Activity",
                    "Other"
            ));

    private static final Set<String> ALLOWED_SEVERITIES =
            new HashSet<>(Arrays.asList(
                    "LOW", "MEDIUM", "HIGH", "CRITICAL"
            ));

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

        request.getRequestDispatcher("/report-incident.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Verify login
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

        // Read form data
        String title = trim(request.getParameter("title"));
        String description = trim(request.getParameter("description"));
        String incidentType = trim(request.getParameter("incidentType"));
        String severity = trim(request.getParameter("severity"))
                .toUpperCase();

        // Validate input
        if (title.isEmpty()
                || title.length() > 150
                || description.isEmpty()
                || description.length() > 5000
                || !ALLOWED_TYPES.contains(incidentType)
                || !ALLOWED_SEVERITIES.contains(severity)) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/report-incident.jsp?error=validation");
            return;
        }

        String sql =
                "INSERT INTO incidents " +
                "(title, description, incident_type, severity, status, reported_by) " +
                "VALUES (?, ?, ?, ?, 'OPEN', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, title);
            ps.setString(2, description);
            ps.setString(3, incidentType);
            ps.setString(4, severity);
            ps.setInt(5, userId);

            int rows = ps.executeUpdate();

            if (rows > 0) {

                try (ResultSet rs = ps.getGeneratedKeys()) {

                    if (rs.next()) {
                        int incidentId = rs.getInt(1);

                        response.sendRedirect(
                                request.getContextPath()
                                + "/report-success.jsp?id=" + incidentId);
                        return;
                    }
                }
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/report-incident.jsp?error=server");

        } catch (SQLException e) {

            getServletContext().log(
                    "CyberShield: Failed to save incident.", e);

            response.sendRedirect(
                    request.getContextPath()
                    + "/report-incident.jsp?error=server");
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}