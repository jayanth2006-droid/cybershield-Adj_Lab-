<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="jakarta.servlet.http.HttpServletResponse" %>
<%@ page import="com.cybershield.model.User" %>
<%@ page import="com.cybershield.util.FormatUtil" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
<%@ page import="com.cybershield.util.CsrfUtil" %>
<%@ page import="java.util.List" %>


<%
    Object adminObject = request.getAttribute("adminUser");

    if (!(adminObject instanceof User)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Administrator access is required.");
        return;
    }

    User adminUser = (User) adminObject;
    String ctx = request.getContextPath();
    String pageTitle = "Users";

    List<User> users = (List<User>) request.getAttribute("users");

    Object countObject = request.getAttribute("userCount");

    int userCount = countObject instanceof Number
            ? ((Number) countObject).intValue()
            : (users == null ? 0 : users.size());

    int admins = 0;
    int analysts = 0;

    if (users != null) {
        for (User user : users) {
            if (user.isAdmin()) {
                admins++;
            } else {
                analysts++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <%@ include file="/WEB-INF/includes/head.jspf" %>
</head>

<body>

<div class="app-shell">

    <%@ include file="/WEB-INF/includes/sidebar.jspf" %>

    <div class="main-area">

        <%@ include file="/WEB-INF/includes/topbar.jspf" %>

        <main class="content">

            <%@ include file="/WEB-INF/includes/alerts.jspf" %>

            <!-- Page heading -->

            <div class="page-head">

                <div>

                    <div class="eyebrow">
                        Administration / Directory
                    </div>

                    <h1>User directory</h1>

                    <p class="page-sub">
                        <%= userCount %> registered accounts. Roles control access to the
                        administration workspace and organisation-wide incident queue.
                    </p>

                </div>

                <div class="page-actions">

                    <a class="btn btn-ghost"
                       href="<%= ctx %>/admin/dashboard">
                        SOC overview
                    </a>

                </div>

            </div>

            <!-- User statistics -->

            <section class="card" style="margin-bottom:18px">

                <div class="card-pad">

                    <div class="info-grid">

                        <div class="info-tile">
                            <div class="it-label">Total accounts</div>
                            <div class="it-value">
                                <%= userCount %>
                            </div>
                        </div>

                        <div class="info-tile">
                            <div class="it-label">Administrators</div>
                            <div class="it-value">
                                <%= admins %>
                            </div>
                        </div>

                        <div class="info-tile">
                            <div class="it-label">Analysts</div>
                            <div class="it-value">
                                <%= analysts %>
                            </div>
                        </div>

                        <div class="info-tile">
                            <div class="it-label">Signed in as</div>
                            <div class="it-value">
                                @<%= HtmlUtil.escape(adminUser.getUsername()) %>
                            </div>
                        </div>

                    </div>

                </div>

            </section>

            <!-- Registered accounts -->

            <section class="card">

                <div class="card-head">

                    <div>

                        <div class="card-title">
                            Registered accounts
                        </div>

                        <div class="card-sub">
                            Newest accounts first
                        </div>

                    </div>

                </div>

                <% if (users != null && !users.isEmpty()) { %>

                    <div class="table-wrap">

                        <table>

                            <thead>

                                <tr>
                                    <th>User</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Access scope</th>
                                    <th>Joined</th>
                                    <th></th>
                                </tr>

                            </thead>

                            <tbody>

                                <% for (User user : users) {

                                    String userName = user.getFullName() == null
                                            ? "Analyst"
                                            : user.getFullName();

                                    String initials = "CS";

                                    String[] parts = userName.trim().split("\\s+");

                                    if (parts.length > 0 && !parts[0].isEmpty()) {

                                        initials = parts[0]
                                                .substring(0, 1)
                                                .toUpperCase();

                                        if (parts.length > 1
                                                && !parts[parts.length - 1].isEmpty()) {

                                            initials += parts[parts.length - 1]
                                                    .substring(0, 1)
                                                    .toUpperCase();
                                        }
                                    }

                                    boolean isSelf =
                                            user.getId() == adminUser.getId();

                                %>

                                    <tr>

                                        <!-- User details -->

                                        <td>

                                            <div style="display:flex;align-items:center;gap:11px">

                                                <span class="avatar sm">
                                                    <%= HtmlUtil.escape(initials) %>
                                                </span>

                                                <div>

                                                    <div class="table-title">

                                                        <%= HtmlUtil.escape(userName) %>

                                                        <% if (isSelf) { %>

                                                            <span class="badge role-user no-dot"
                                                                  style="margin-left:6px">
                                                                You
                                                            </span>

                                                        <% } %>

                                                    </div>

                                                    <div class="table-sub mono">
                                                        @<%= HtmlUtil.escape(user.getUsername()) %>
                                                    </div>

                                                </div>

                                            </div>

                                        </td>

                                        <!-- Email -->

                                        <td>
                                            <%= HtmlUtil.escape(user.getEmail()) %>
                                        </td>

                                        <!-- Role -->

                                        <td>

                                            <span class="badge <%= user.isAdmin()
                                                    ? "role-admin"
                                                    : "role-user" %>">

                                                <%= HtmlUtil.escape(user.getRole()) %>

                                            </span>

                                        </td>

                                        <!-- Access scope -->

                                        <td class="text-muted">

                                            <%= user.isAdmin()
                                                    ? "All incidents and users"
                                                    : "Own incidents" %>

                                        </td>

                                        <!-- Registration date -->

                                        <td class="mono nowrap">
                                            <%= FormatUtil.date(user.getCreatedAt()) %>
                                        </td>

                                        <td class="text-right">
                                            <form class="status-form"
                                                  action="<%= ctx %>/admin/users"
                                                  method="post">
                                                <input type="hidden" name="csrfToken"
                                                       value="<%= CsrfUtil.getToken(session) %>">
                                                <input type="hidden" name="userId"
                                                       value="<%= user.getId() %>">
                                                <select name="role"
                                                        aria-label="Role for <%= user.getUsername() %>">
                                                    <option value="USER"
                                                        <%= !"ADMIN".equalsIgnoreCase(user.getRole()) ? "selected" : "" %>>
                                                        User
                                                    </option>
                                                    <option value="ADMIN"
                                                        <%= "ADMIN".equalsIgnoreCase(user.getRole()) ? "selected" : "" %>>
                                                        Administrator
                                                    </option>
                                                </select>
                                                <button class="btn btn-ghost btn-sm" type="submit">Update</button>
                                            </form>
                                        </td>

                                <% } %>

                            </tbody>

                        </table>

                    </div>

                <% } else { %>

                    <!-- Empty state -->

                    <div class="empty">

                        <span class="empty-icon">

                            <svg viewBox="0 0 24 24" aria-hidden="true">

                                <circle cx="9" cy="8" r="3"/>

                                <path d="M3.5 19c.6-2.8 2.8-4.4 5.5-4.4s4.9 1.6 5.5 4.4"/>

                            </svg>

                        </span>

                        <h3>No users found</h3>

                        <p>
                            Registered accounts will appear here.
                        </p>

                    </div>

                <% } %>

            </section>

        </main>

    </div>

</div>

<script src="<%= ctx %>/js/cybershield.js"></script>

</body>
</html>
