
package com.cybershield.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest =
                (HttpServletRequest) request;

        HttpServletResponse httpResponse =
                (HttpServletResponse) response;

        String contextPath = httpRequest.getContextPath();
        String path = httpRequest.getRequestURI()
                .substring(contextPath.length());

        // Allow public pages and authentication endpoints
        if (isPublicPath(path)) {

            chain.doFilter(request, response);
            return;
        }

        // Check existing session
        HttpSession session = httpRequest.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            httpResponse.sendRedirect(
                    contextPath + "/login.jsp?timeout=1"
            );
            return;
        }

        // Prevent browser caching of protected pages
        httpResponse.setHeader("Cache-Control",
                "no-store, no-cache, must-revalidate, max-age=0");

        httpResponse.setHeader("Pragma", "no-cache");

        chain.doFilter(request, response);
    }

    private boolean isPublicPath(String path) {
        if (path == null || path.isEmpty()) {
            return true;
        }
        if (path.equals("/") || path.equals("/index.jsp")
                || path.equals("/error")) {
            return true;
        }
        if (path.equals("/login") || path.equals("/login.jsp")
                || path.equals("/register") || path.equals("/register.jsp")
                || path.equals("/logout")) {
            return true;
        }
        return path.startsWith("/css/")
                || path.startsWith("/js/")
                || path.startsWith("/images/")
                || path.startsWith("/error");
    }
}