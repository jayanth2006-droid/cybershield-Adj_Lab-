<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%
    String ctx = request.getContextPath();
    Object statusObject = request.getAttribute("jakarta.servlet.error.status_code");
    int errorStatus = statusObject instanceof Integer
            ? ((Integer) statusObject).intValue() : response.getStatus();
    if (errorStatus < 400) {
        errorStatus = 500;
    }

    String errorHeading;
    String errorMessage;
    if (errorStatus == 403) {
        errorHeading = "Access denied";
        errorMessage = "Your account does not have permission to view this resource.";
    } else if (errorStatus == 404) {
        errorHeading = "Page not found";
        errorMessage = "The page you requested does not exist or may have moved.";
    } else if (errorStatus == 400) {
        errorHeading = "Invalid request";
        errorMessage = "The request could not be processed. Check the details and try again.";
    } else {
        errorHeading = "Something went wrong";
        errorMessage = "CyberShield could not complete this request. Please try again shortly.";
    }

    String pageTitle = errorHeading;
    Object errorUserId = session.getAttribute("userId");
    boolean errorLoggedIn = errorUserId != null;
    String errorRole = String.valueOf(session.getAttribute("role"));
    String errorConsole = "ADMIN".equalsIgnoreCase(errorRole)
            ? ctx + "/admin/dashboard" : ctx + "/dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="WEB-INF/includes/head.jspf" %>
</head>
<body>
<main class="auth-main" style="min-height:100vh">
    <div class="auth-card" style="max-width:520px">
        <div class="auth-top">
            <a class="brand" href="<%= ctx %>/">
                <span class="brand-mark" aria-hidden="true">
                    <svg viewBox="0 0 24 24">
                        <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                        <path d="M9 12l2 2 4-4"/>
                    </svg>
                </span>
                <span class="brand-text">
                    <strong>CyberShield</strong>
                    <span>SOC console</span>
                </span>
            </a>
            <button class="icon-btn" type="button" data-theme-toggle aria-label="Toggle colour theme">
                <svg class="moon" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M20 14.5A8 8 0 019.5 4a8 8 0 1010.5 10.5z"/>
                </svg>
                <svg class="sun" viewBox="0 0 24 24" aria-hidden="true">
                    <circle cx="12" cy="12" r="4"/>
                    <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>
                </svg>
            </button>
        </div>

        <div class="card">
            <div class="empty" style="padding:42px 26px">
                <span class="empty-icon" style="width:72px;height:72px;font-family:var(--font-mono);font-size:1.1rem;font-weight:800">
                    <%= errorStatus %>
                </span>
                <h3 style="font-size:1.25rem"><%= errorHeading %></h3>
                <p><%= errorMessage %></p>
                <div class="page-actions" style="justify-content:center;margin-top:8px">
                    <% if (errorLoggedIn) { %>
                    <a class="btn btn-primary" href="<%= errorConsole %>">Back to console</a>
                    <% } else { %>
                    <a class="btn btn-primary" href="<%= ctx %>/login.jsp">Sign in</a>
                    <% } %>
                    <a class="btn btn-ghost" href="<%= ctx %>/">Home</a>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
