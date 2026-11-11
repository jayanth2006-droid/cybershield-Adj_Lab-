package com.cybershield.filter;

import com.cybershield.dao.UserDao;
import com.cybershield.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

/**
 * Defence-in-depth role check for every /admin/* request. The role is always
 * read from the database, never trusted from a URL or form value.
 */
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath()
                    + "/login.jsp?timeout=1");
            return;
        }

        try {
            int userId = (Integer) session.getAttribute("userId");
            User user = new UserDao().findById(userId);

            if (user == null || !user.isAdmin()) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Administrator access is required.");
                return;
            }

            session.setAttribute("role", user.getRole());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("username", user.getUsername());
            request.setAttribute("currentUser", user);

            httpResponse.setHeader("Cache-Control",
                    "no-store, no-cache, must-revalidate, max-age=0");
            httpResponse.setHeader("Pragma", "no-cache");
            chain.doFilter(request, response);
        } catch (SQLException e) {
            throw new ServletException("Unable to verify administrator role", e);
        }
    }
}
