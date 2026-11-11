<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.util.CsrfUtil" %>
<%
    String pageTitle = "Sign in";
    String ctx = request.getContextPath();
    Object loginUserId = session.getAttribute("userId");
    if (loginUserId != null) {
        String loginRole = String.valueOf(session.getAttribute("role"));
        response.sendRedirect(ctx + ("ADMIN".equalsIgnoreCase(loginRole)
                ? "/admin/dashboard" : "/dashboard"));
        return;
    }

    String loginError = request.getParameter("error");
    boolean loginRegistered = "1".equals(request.getParameter("registered"));
    boolean loginLoggedOut = "1".equals(request.getParameter("logout"));
    boolean loginTimedOut = "1".equals(request.getParameter("timeout"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="WEB-INF/includes/head.jspf" %>
</head>
<body>
<div class="auth-shell">
    <aside class="auth-hero">
        <a class="brand" href="<%= ctx %>/">
            <span class="brand-mark" aria-hidden="true">
                <svg viewBox="0 0 24 24">
                    <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                    <path d="M9 12l2 2 4-4"/>
                </svg>
            </span>
            <span class="brand-text">
                <strong>CyberShield</strong>
                <span>Security operations</span>
            </span>
        </a>

        <div>
            <h1>One console.<br><span>Every incident.</span></h1>
            <p>
                Sign in to review the threat queue, report new incidents and track
                response progress across your workspace.
            </p>
            <div class="auth-features">
                <div class="auth-feature">
                    <span class="af-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                            <path d="M9 12l2 2 4-4"/>
                        </svg>
                    </span>
                    <span>Role-aware workspaces for analysts and administrators.</span>
                </div>
                <div class="auth-feature">
                    <span class="af-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M4 7h16M4 12h10M4 17h7"/>
                            <circle cx="18" cy="16" r="3"/>
                        </svg>
                    </span>
                    <span>Structured intake with severity and category controls.</span>
                </div>
                <div class="auth-feature">
                    <span class="af-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M12 3v18M5 8l7-5 7 5"/>
                            <path d="M5 8v8l7 5 7-5V8"/>
                        </svg>
                    </span>
                    <span>CSRF-protected forms and BCrypt password hashing.</span>
                </div>
            </div>
        </div>

        <div class="auth-foot">CyberShield · SOC console · Authorised access only</div>
    </aside>

    <main class="auth-main">
        <div class="auth-card">
            <div class="auth-top">
                <a class="brand mobile-brand" href="<%= ctx %>/">
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

            <h2>Sign in to the console</h2>
            <p class="auth-sub">Use your username or email address to authenticate.</p>

            <% if (loginRegistered) { %>
            <div class="alert alert-success" data-autohide role="status">
                <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 6L9 17l-5-5"/></svg>
                <span>Account created successfully. Sign in to open your workspace.</span>
            </div>
            <% } else if (loginLoggedOut) { %>
            <div class="alert alert-info" data-autohide role="status">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
                <span>You have been signed out of the SOC console.</span>
            </div>
            <% } else if (loginTimedOut) { %>
            <div class="alert alert-warning" data-autohide role="status">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
                <span>Your session expired. Please sign in again to continue.</span>
            </div>
            <% } else if (loginError != null) { %>
            <div class="alert alert-error" role="alert">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
                <span>
                    <% if ("required".equals(loginError)) { %>
                    Enter both your username/email and password.
                    <% } else { %>
                    Invalid username/email or password. Please try again.
                    <% } %>
                </span>
            </div>
            <% } %>

            <form action="<%= ctx %>/login" method="post" class="form-stack">
                <input type="hidden" name="csrfToken"
                       value="<%= CsrfUtil.getToken(session) %>">

                <div class="field">
                    <label for="username">Username or email</label>
                    <input id="username" name="username" type="text"
                           maxlength="100" autocomplete="username" required
                           placeholder="analyst@cybershield.io">
                </div>

                <div class="field">
                    <label for="password">Password</label>
                    <input id="password" name="password" type="password"
                           autocomplete="current-password" required
                           placeholder="Enter your password">
                </div>

                <button class="btn btn-primary btn-block" type="submit">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <path d="M5 11h14v9H5z"/>
                        <path d="M8 11V8a4 4 0 018 0v3"/>
                    </svg>
                    Sign in securely
                </button>
            </form>

            <div class="auth-switch">
                New to CyberShield? <a href="<%= ctx %>/register.jsp">Create an account</a>
            </div>
            <div class="auth-note">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <circle cx="12" cy="12" r="9"/>
                    <path d="M12 8v5M12 16.5v.5"/>
                </svg>
                <span>Authorised access only. Activity in this console may be monitored for security purposes.</span>
            </div>
        </div>
    </main>
</div>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
