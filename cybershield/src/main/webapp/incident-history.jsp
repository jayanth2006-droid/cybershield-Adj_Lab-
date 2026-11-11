<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.model.Incident" %>
<%@ page import="com.cybershield.util.CsrfUtil" %>
<%@ page import="com.cybershield.util.FormatUtil" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Object historyObject = request.getAttribute("incidents");
    if (!(historyObject instanceof List)) {
        response.sendRedirect(request.getContextPath() + "/incident-history");
        return;
    }

    String ctx = request.getContextPath();
    String pageTitle = "My incidents";
    List<Incident> incidents = (List<Incident>) historyObject;
    String search = (String) request.getAttribute("search");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String severityFilter = (String) request.getAttribute("severityFilter");
    if (search == null) search = "";
    if (statusFilter == null) statusFilter = "";
    if (severityFilter == null) severityFilter = "";

    boolean hasFilters = !search.isEmpty() || !statusFilter.isEmpty() || !severityFilter.isEmpty();
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
                    <div class="eyebrow">Workspace / Case history</div>
                    <h1>My incidents</h1>
                    <p class="page-sub">
                        Every incident you have reported, with its current response
                        state. Update the status as your investigation progresses.
                    </p>
                </div>
                <div class="page-actions">
                    <a class="btn btn-primary" href="<%= ctx %>/report-incident">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M12 8v8M8 12h8"/>
                        </svg>
                        Report incident
                    </a>
                </div>
            </div>

            <section class="card">
                <form class="filters" action="<%= ctx %>/incident-history" method="get">
                    <div class="field grow">
                        <label for="q">Search</label>
                        <input id="q" name="q" type="search" maxlength="100"
                               value="<%= HtmlUtil.escape(search) %>"
                               placeholder="Search title, description or category">
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
                    <a class="btn btn-ghost" href="<%= ctx %>/incident-history">Reset</a>
                    <% } %>
                </form>

                <% if (incidents != null && !incidents.isEmpty()) { %>
                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>ID</th>
                            <th>Incident</th>
                            <th>Type</th>
                            <th>Severity</th>
                            <th>Status</th>
                            <th>Reported</th>
                            <th>Update status</th>
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
                                <div class="table-title"><%= HtmlUtil.escape(incident.getTitle()) %></div>
                                <div class="table-sub"><%= HtmlUtil.escape(FormatUtil.shortText(incident.getDescription(), 90)) %></div>
                                <% if (incident.getResolvedAt() != null) { %>
                                <div class="table-sub">Resolved <%= FormatUtil.dateTime(incident.getResolvedAt()) %></div>
                                <% } %>
                            </td>
                            <td><span class="badge type no-dot"><%= HtmlUtil.escape(incident.getIncidentType()) %></span></td>
                            <td><span class="badge severity-<%= severityToken %>"><%= HtmlUtil.escape(incident.getSeverity()) %></span></td>
                            <td><span class="badge status-<%= statusToken %>"><%= HtmlUtil.escape(FormatUtil.statusLabel(incident.getStatus())) %></span></td>
                            <td class="mono nowrap"><%= FormatUtil.dateTime(incident.getCreatedAt()) %></td>
                            <td>
                                <form class="status-form"
                                      action="<%= ctx %>/update-incident-status" method="post">
                                    <input type="hidden" name="csrfToken"
                                           value="<%= CsrfUtil.getToken(session) %>">
                                    <input type="hidden" name="incidentId"
                                           value="<%= incident.getId() %>">
                                    <select name="status" aria-label="Status for incident <%= incident.getId() %>" required>
                                        <option value="OPEN" <%= "OPEN".equals(incident.getStatus()) ? "selected" : "" %>>Open</option>
                                        <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(incident.getStatus()) ? "selected" : "" %>>In Progress</option>
                                        <option value="RESOLVED" <%= "RESOLVED".equals(incident.getStatus()) ? "selected" : "" %>>Resolved</option>
                                    </select>
                                    <button class="btn btn-ghost btn-sm" type="submit">Save</button>
                                </form>
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
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M12 7v5l3 2"/>
                        </svg>
                    </span>
                    <h3><%= hasFilters ? "No incidents match your filters" : "No incidents reported yet" %></h3>
                    <p>
                        <%= hasFilters
                                ? "Try clearing the search or choosing a different status and severity."
                                : "Report your first security incident to begin building a response history." %>
                    </p>
                    <% if (hasFilters) { %>
                    <a class="btn btn-ghost btn-sm" href="<%= ctx %>/incident-history">Clear filters</a>
                    <% } else { %>
                    <a class="btn btn-primary btn-sm" href="<%= ctx %>/report-incident">Report incident</a>
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
