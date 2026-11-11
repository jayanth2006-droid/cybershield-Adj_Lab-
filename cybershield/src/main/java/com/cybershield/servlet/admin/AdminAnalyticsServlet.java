package com.cybershield.servlet.admin;

import com.cybershield.dao.IncidentDao;
import com.cybershield.dao.UserDao;
import com.cybershield.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

public class AdminAnalyticsServlet extends HttpServlet {

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
            IncidentDao dao = new IncidentDao();
            request.setAttribute("adminUser", admin);
            request.setAttribute("stats", dao.getStats(null));
            request.setAttribute("severityDistribution",
                    dao.distribution("severity", null));
            request.setAttribute("statusDistribution",
                    dao.distribution("status", null));
            request.setAttribute("typeDistribution",
                    dao.distribution("incident_type", null));
            request.setAttribute("userCount", new UserDao().countAll());

            request.getRequestDispatcher("/WEB-INF/views/admin/analytics.jsp")
                   .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Unable to load analytics.", e);
        }
    }
}
