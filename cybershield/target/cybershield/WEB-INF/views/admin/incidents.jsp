<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.model.Incident" %>
<%@ page import="com.cybershield.model.User" %>
<%@ page import="com.cybershield.util.FormatUtil" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
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
    String pageTitle = "All incidents";

    Object listObject = request.getAttribute("incidents");
    List<Incident> incidents = listObject instanceof List
            ? (List<Incident>) listObject : null;
    String search = (String) request.getAttribute("search");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String severityFilter = (String) request.getAttribute("severityFilter");
    if (search == null) search = "";
    if (statusFilter == null) statusFilter = "";
    if (severityFilter == null) severityFilter = "";

    int[] stats = (int[]) request.getAttribute("stats");
    int total = stats == null ? 0 : stats[0];
    int visibleCount = incidents == null ? 0 : incidents.size();
    boolean hasFilters = !search.isEmpty() || !statusFilter.isEmpty() || !severityFilter.isEmpty();
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

            <div class="page-head">
                <div>
                    <div class="eyebrow">Administration / Incident queue</div>
                    <h1>All incidents</h1>
                    <p class="page-sub">
                        <%= visibleCount %> of <%= total %> incidents shown. Open a case to
                        review evidence, record investigation notes and update its response state.
                    </p>
                </div>
                <div class="page-actions">
                    <a class="btn btn-ghost" href="<%= ctx %>/admin/analytics">Analytics</a>
                    <a class="btn btn-primary" href="<%= ctx %>/admin/dashboard">SOC overview</a>
                </div>
            </div>

            <section class="card">
                <form class="filters" action="<%= ctx %>/admin/incidents" method="get">
                    <div class="field grow">
                        <label for="q">Search</label>
                        <input id="q" name="q" type="search" maxlength="100"
                               value="<%= HtmlUtil.escape(search) %>"
                               placeholder="Search title, description, category or reporter">
                    </div>
                    <div class="field">
                        <label for="status">Status</label>
                        <select id="status" name="status">
                            <option value="">All statuses</option>
                            <option value="OPEN" <%= "OPEN".equals(statusFilter) ? "selected" : "" %>>Open</option>
                            <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(statusFilter) ? "selected" : "" %>>In Progress</option>
                            <option value="RESOLVED" <%= "RESOLVED".equals(statusFilter) ? "selected" : "" %>>Resolved</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="severity">Severity</label>
                        <select id="severity" name="severity">
                            <option value="">All severities</option>
                            <option value="LOW" <%= "LOW".equals(severityFilter) ? "selected" : "" %>>Low</option>
                            <option value="MEDIUM" <%= "MEDIUM".equals(severityFilter) ? "selected" : "" %>>Medium</option>
                            <option value="HIGH" <%= "HIGH".equals(severityFilter) ? "selected" : "" %>>High</option>
                            <option value="CRITICAL" <%= "CRITICAL".equals(severityFilter) ? "selected" : "" %>>Critical</option>
                        </select>
                    </div>
                    <button class="btn btn-ghost" type="submit">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="11" cy="11" r="7"/>
                            <path d="M16 16l4 4"/>
                        </svg>
                        Apply
                    </button>
                    <% if (hasFilters) { %>
                    <a class="btn btn-ghost" href="<%= ctx %>/admin/incidents">Reset</a>
                    <% } %>
                </form>

                <% if (incidents != null && !incidents.isEmpty()) { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Incident</th>
                            <th>Reporter</th>
                            <th>Type</th>
                            <th>Severity</th>
                            <th>Status</th>
                            <th>Reported</th>
                            <th></th>
                        </tr>
                        </thead>
                        <tbody>
                        <% for (Incident incident : incidents) {
                            String severityToken = FormatUtil.cssToken(incident.getSeverity());
                            String statusToken = FormatUtil.cssToken(incident.getStatus());
                        %>
                        <tr>
                            <td class="mono nowrap">#<%= incident.getId() %></td>
                            <td>
                                <div class="table-title">
                                    <a href="<%= ctx %>/admin/incident?id=<%= incident.getId() %>"><%= HtmlUtil.escape(incident.getTitle()) %></a>
                                </div>
                                <div class="table-sub"><%= HtmlUtil.escape(FormatUtil.shortText(incident.getDescription(), 76)) %></div>
                            </td>
                            <td>
                                <div><%= HtmlUtil.escape(incident.getReporterName() == null ? "Unknown" : incident.getReporterName()) %></div>
                                <div class="table-sub mono">@<%= HtmlUtil.escape(incident.getReporterUsername() == null ? "unknown" : incident.getReporterUsername()) %></div>
                            </td>
                            <td><span class="badge type no-dot"><%= HtmlUtil.escape(incident.getIncidentType()) %></span></td>
                            <td><span class="badge severity-<%= severityToken %>"><%= HtmlUtil.escape(incident.getSeverity()) %></span></td>
                            <td><span class="badge status-<%= statusToken %>"><%= HtmlUtil.escape(FormatUtil.statusLabel(incident.getStatus())) %></span></td>
                            <td class="mono nowrap"><%= FormatUtil.dateTime(incident.getCreatedAt()) %></td>
                            <td class="text-right">
                                <a class="btn btn-ghost btn-sm" href="<%= ctx %>/admin/incident?id=<%= incident.getId() %>">Manage</a>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="empty">
                    <span class="empty-icon">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="11" cy="11" r="7"/>
                            <path d="M16 16l4 4"/>
                        </svg>
                    </span>
                    <h3><%= hasFilters ? "No incidents match your filters" : "No incidents in the queue" %></h3>
                    <p>
                        <%= hasFilters
                                ? "Try a different search term, status or severity."
                                : "Incident reports will appear here as analysts submit them." %>
                    </p>
                    <% if (hasFilters) { %>
                    <a class="btn btn-ghost btn-sm" href="<%= ctx %>/admin/incidents">Clear filters</a>
                    <% } %>
                </div>
                <% } %>
            </section>
        </main>
    </div>
</div>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
