<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.util.CsrfUtil" %>
<%
    String pageTitle = "Create account";
    String ctx = request.getContextPath();
    Object regUserId = session.getAttribute("userId");
    if (regUserId != null) {
        String regRole = String.valueOf(session.getAttribute("role"));
        response.sendRedirect(ctx + ("ADMIN".equalsIgnoreCase(regRole)
                ? "/admin/dashboard" : "/dashboard"));
        return;
    }

    String regError = request.getParameter("error");
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
            <h1>Your response<br><span>workspace starts here.</span></h1>
            <p>
                Create an analyst account to report incidents, follow their
                resolution and build a reliable record of your security posture.
            </p>
            <div class="auth-features">
                <div class="auth-feature">
                    <span class="af-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M12 8v8M8 12h8"/>
                        </svg>
                    </span>
                    <span>Report incidents in seconds with guided intake fields.</span>
                </div>
                <div class="auth-feature">
                    <span class="af-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M12 7v5l3 2"/>
                        </svg>
                    </span>
                    <span>Track status changes and resolution history over time.</span>
                </div>
                <div class="auth-feature">
                    <span class="af-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                            <path d="M9 12l2 2 4-4"/>
                        </svg>
                    </span>
                    <span>Your account is scoped to your own incident records.</span>
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

            <h2>Create your analyst account</h2>
            <p class="auth-sub">Set up access to the CyberShield security operations console.</p>

            <% if ("required".equals(regError)) { %>
            <div class="alert alert-error" role="alert">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
                <span>All fields are required.</span>
            </div>
            <% } else if ("validation".equals(regError)) { %>
            <div class="alert alert-error" role="alert">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
                <span>Enter a valid email, a username of 3-50 letters, numbers, dots,
                    dashes or underscores, and a password of 8-72 characters.</span>
            </div>
            <% } else if ("duplicate".equals(regError)) { %>
            <div class="alert alert-error" role="alert">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
                <span>That username or email is already registered. Try another.</span>
            </div>
            <% } else if ("server".equals(regError)) { %>
            <div class="alert alert-error" role="alert">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
                <span>Registration failed because of a server problem. Please try again.</span>
            </div>
            <% } %>

            <form action="<%= ctx %>/register" method="post" class="form-stack">
                <input type="hidden" name="csrfToken"
                       value="<%= CsrfUtil.getToken(session) %>">

                <div class="field">
                    <label for="fullName">Full name</label>
                    <input id="fullName" name="fullName" type="text"
                           maxlength="100" autocomplete="name" required
                           placeholder="Jayanth Viswanadham">
                </div>

                <div class="field">
                    <label for="email">Work email</label>
                    <input id="email" name="email" type="email"
                           maxlength="100" autocomplete="email" required
                           placeholder="analyst@cybershield.io">
                </div>

                <div class="field">
                    <label for="username">Username</label>
                    <input id="username" name="username" type="text"
                           minlength="3" maxlength="50"
                           pattern="[A-Za-z0-9._-]{3,50}"
                           title="3-50 letters, numbers, dots, dashes or underscores"
                           autocomplete="username" required
                           placeholder="analyst01">
                    <span class="help">3-50 characters. Letters, numbers, dots, dashes and underscores only.</span>
                </div>

                <div class="field">
                    <label for="password">Password</label>
                    <input id="password" name="password" type="password"
                           minlength="8" maxlength="72"
                           autocomplete="new-password" required
                           placeholder="At least 8 characters">
                    <span class="help">Use 8-72 characters. Passwords are hashed with BCrypt.</span>
                </div>

                <button class="btn btn-primary btn-block" type="submit">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="9" cy="8" r="3"/>
                        <path d="M3.5 19c.6-2.8 2.8-4.4 5.5-4.4s4.9 1.6 5.5 4.4"/>
                        <path d="M18 8v6M15 11h6"/>
                    </svg>
                    Create account
                </button>
            </form>

            <div class="auth-switch">
                Already have an account? <a href="<%= ctx %>/login.jsp">Sign in</a>
            </div>
        </div>
    </main>
</div>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
