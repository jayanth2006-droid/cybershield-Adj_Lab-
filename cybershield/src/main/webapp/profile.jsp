<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.model.User" %>
<%@ page import="com.cybershield.util.CsrfUtil" %>
<%@ page import="com.cybershield.util.FormatUtil" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Object profileObject = request.getAttribute("user");
    if (!(profileObject instanceof User)) {
        response.sendRedirect(request.getContextPath() + "/profile");
        return;
    }

    String ctx = request.getContextPath();
    String pageTitle = "Profile";
    User profileUser = (User) profileObject;

    String profileName = profileUser.getFullName() == null ? "Analyst" : profileUser.getFullName();
    String profileInitials = "CS";
    String[] profileParts = profileName.trim().split("\\s+");
    if (profileParts.length > 0 && !profileParts[0].isEmpty()) {
        profileInitials = profileParts[0].substring(0, 1).toUpperCase();
        if (profileParts.length > 1 && !profileParts[profileParts.length - 1].isEmpty()) {
            profileInitials += profileParts[profileParts.length - 1].substring(0, 1).toUpperCase();
        }
    }
    boolean profileAdmin = profileUser.isAdmin();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="WEB-INF/includes/head.jspf" %>
</head>
<body>
<div class="app-shell">
    <%@ include file="WEB-INF/includes/sidebar.jspf" %>
    <div class="main-area">
        <%@ include file="WEB-INF/includes/topbar.jspf" %>
        <main class="content">
            <%@ include file="WEB-INF/includes/alerts.jspf" %>

            <div class="page-head">
                <div>
                    <div class="eyebrow">Account / Profile</div>
                    <h1>Your profile</h1>
                    <p class="page-sub">
                        Review your account identity and keep your contact details current.
                        Your username is fixed after registration.
                    </p>
                </div>
            </div>

            <div class="profile-grid">
                <section class="card profile-card">
                    <span class="avatar lg"><%= HtmlUtil.escape(profileInitials) %></span>
                    <h2><%= HtmlUtil.escape(profileName) %></h2>
                    <div class="handle">@<%= HtmlUtil.escape(profileUser.getUsername()) %></div>
                    <div class="role-line">
                        <span class="badge <%= profileAdmin ? "role-admin" : "role-user" %>">
                            <%= HtmlUtil.escape(profileUser.getRole()) %>
                        </span>
                    </div>

                    <div class="meta-list">
                        <div class="meta-row">
                            <span>Email</span>
                            <strong><%= HtmlUtil.escape(profileUser.getEmail()) %></strong>
                        </div>
                        <div class="meta-row">
                            <span>User ID</span>
                            <strong class="mono">#<%= profileUser.getId() %></strong>
                        </div>
                        <div class="meta-row">
                            <span>Member since</span>
                            <strong><%= FormatUtil.date(profileUser.getCreatedAt()) %></strong>
                        </div>
                        <div class="meta-row">
                            <span>Access scope</span>
                            <strong><%= profileAdmin ? "All incidents and users" : "Own incidents" %></strong>
                        </div>
                    </div>
                </section>

                <div class="stack">
                    <section class="card">
                        <div class="card-head">
                            <div>
                                <div class="card-title">Account details</div>
                                <div class="card-sub">Changes apply immediately across the console</div>
                            </div>
                        </div>
                        <form class="card-pad" action="<%= ctx %>/profile" method="post">
                            <input type="hidden" name="csrfToken"
                                   value="<%= CsrfUtil.getToken(session) %>">

                            <div class="form-grid">
                                <div class="field span-2">
                                    <label for="fullName">Full name</label>
                                    <input id="fullName" name="fullName" type="text"
                                           maxlength="100" required
                                           value="<%= HtmlUtil.escape(profileUser.getFullName()) %>">
                                </div>
                                <div class="field span-2">
                                    <label for="email">Email address</label>
                                    <input id="email" name="email" type="email"
                                           maxlength="100" required
                                           value="<%= HtmlUtil.escape(profileUser.getEmail()) %>">
                                    <span class="help">Used for sign-in and account notifications.</span>
                                </div>
                                <div class="field span-2">
                                    <label for="username">Username</label>
                                    <input id="username" type="text" disabled
                                           value="<%= HtmlUtil.escape(profileUser.getUsername()) %>">
                                    <span class="help">Usernames are immutable. Contact an administrator if a change is required.</span>
                                </div>
                            </div>

                            <div class="form-actions">
                                <button class="btn btn-primary" type="submit">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M5 4h11l3 3v13H5z"/>
                                        <path d="M8 4v5h7V4M8 20v-6h8v6"/>
                                    </svg>
                                    Save changes
                                </button>
                                <a class="btn btn-ghost" href="<%= ctx %>/dashboard">Cancel</a>
                            </div>
                        </form>
                    </section>

                    <section class="card">
                        <div class="card-head">
                            <div>
                                <div class="card-title">Password</div>
                                <div class="card-sub">Rotate credentials with a fresh BCrypt hash</div>
                            </div>
                        </div>
                        <form class="card-pad" action="<%= ctx %>/profile" method="post">
                            <input type="hidden" name="csrfToken" value="<%= CsrfUtil.getToken(session) %>">
                            <input type="hidden" name="action" value="password">

                            <div class="form-grid">
                                <div class="field span-2">
                                    <label for="currentPassword">Current password</label>
                                    <input id="currentPassword" name="currentPassword" type="password" autocomplete="current-password" required>
                                </div>
                                <div class="field">
                                    <label for="newPassword">New password</label>
                                    <input id="newPassword" name="newPassword" type="password" minlength="8" maxlength="72" autocomplete="new-password" required>
                                    <span class="help">Use 8-72 characters. A new BCrypt hash is stored automatically.</span>
                                </div>
                                <div class="field">
                                    <label for="confirmPassword">Confirm new password</label>
                                    <input id="confirmPassword" name="confirmPassword" type="password" minlength="8" maxlength="72" autocomplete="new-password" required>
                                </div>
                            </div>

                            <div class="form-actions">
                                <button class="btn btn-primary" type="submit">Update password</button>
                                <a class="btn btn-ghost" href="<%= ctx %>/profile">Cancel</a>
                            </div>
                        </form>
                    </section>
                    <section class="card">
                        <div class="card-head">
                        </div>
                        <div class="card-pad">
                            <div class="info-grid">
                                <div class="info-tile">
                                    <div class="it-label">Role</div>
                                    <div class="it-value"><%= HtmlUtil.escape(profileUser.getRole()) %></div>
                                </div>
                                <div class="info-tile">
                                    <div class="it-label">Password storage</div>
                                    <div class="it-value">BCrypt hash</div>
                                </div>
                                <div class="info-tile">
                                    <div class="it-label">Session</div>
                                    <div class="it-value">20 minute inactivity timeout</div>
                                </div>
                                <div class="info-tile">
                                    <div class="it-label">Request protection</div>
                                    <div class="it-value">CSRF token on every form</div>
                                </div>
                            </div>
                        </div>
                    </section>
                </div>
            </div>
        </main>
    </div>
</div>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
