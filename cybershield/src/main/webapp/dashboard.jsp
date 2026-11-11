<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.model.Incident" %>
<%@ page import="com.cybershield.model.User" %>
<%@ page import="com.cybershield.util.FormatUtil" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Object statsObject = request.getAttribute("stats");
    if (!(statsObject instanceof int[])) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    String ctx = request.getContextPath();
    String pageTitle = "Dashboard";
    int[] stats = (int[]) statsObject;
    int total = stats[0];
    int open = stats[1];
    int inProgress = stats[2];
    int resolved = stats[3];
    int resolutionRate = total == 0 ? 0 : (int) Math.round(resolved * 100.0 / total);

    User dashboardUser = (User) request.getAttribute("user");
    String dashboardName = dashboardUser == null ? "Analyst" : dashboardUser.getFullName();
    String firstName = dashboardName == null || dashboardName.trim().isEmpty()
            ? "Analyst" : dashboardName.trim().split("\\s+")[0];

    List<Incident> recentIncidents = (List<Incident>) request.getAttribute("recentIncidents");
    Map<String, Integer> severityMix = (Map<String, Integer>) request.getAttribute("severityDistribution");
    boolean dashboardIsAdmin = dashboardUser != null && dashboardUser.isAdmin();
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
                    <div class="eyebrow">Workspace / Overview</div>
                    <h1>Welcome back, <%= HtmlUtil.escape(firstName) %></h1>
                    <p class="page-sub">
                        Here is the current state of the incidents you have reported.
                        Keep cases moving and close the loop on every threat.
                    </p>
                </div>
                <div class="page-actions">
                    <a class="btn btn-ghost" href="<%= ctx %>/incident-history">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M12 7v5l3 2"/>
                        </svg>
                        My incidents
                    </a>
                    <a class="btn btn-primary" href="<%= ctx %>/report-incident">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="M12 8v8M8 12h8"/>
                        </svg>
                        Report incident
                    </a>
                </div>
            </div>

            <section class="stat-grid" aria-label="Incident statistics">
                <article class="stat-card accent-cyan">
                    <div class="stat-top">
                        <span class="stat-label">Total reported</span>
                        <span class="stat-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M12 3l9 5-9 5-9-5 9-5z"/>
                                <path d="M3 12l9 5 9-5"/>
                                <path d="M3 16l9 5 9-5"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-value"><%= total %></div>
                    <div class="stat-meta">All incidents linked to your account</div>
                </article>

                <article class="stat-card accent-amber">
                    <div class="stat-top">
                        <span class="stat-label">Open</span>
                        <span class="stat-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <circle cx="12" cy="12" r="9"/>
                                <path d="M12 8v5M12 16.5v.5"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-value"><%= open %></div>
                    <div class="stat-meta">Awaiting first triage action</div>
                </article>

                <article class="stat-card accent-blue">
                    <div class="stat-top">
                        <span class="stat-label">In progress</span>
                        <span class="stat-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <circle cx="12" cy="12" r="9"/>
                                <path d="M12 7v5l3 2"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-value"><%= inProgress %></div>
                    <div class="stat-meta">Under active investigation</div>
                </article>

                <article class="stat-card accent-green">
                    <div class="stat-top">
                        <span class="stat-label">Resolved</span>
                        <span class="stat-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M20 6L9 17l-5-5"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-value"><%= resolved %></div>
                    <div class="stat-meta"><strong><%= resolutionRate %>%</strong> resolution rate</div>
                </article>
            </section>

            <div class="dash-grid">
                <section class="card">
                    <div class="card-head">
                        <div>
                            <div class="card-title">Recent incidents</div>
                            <div class="card-sub">Latest six reports from your workspace</div>
                        </div>
                        <a class="btn btn-ghost btn-sm" href="<%= ctx %>/incident-history">View all</a>
                    </div>

                    <% if (recentIncidents != null && !recentIncidents.isEmpty()) { %>
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
                            </tr>
                            </thead>
                            <tbody>
                            <% for (Incident incident : recentIncidents) {
                                String severityToken = FormatUtil.cssToken(incident.getSeverity());
                                String statusToken = FormatUtil.cssToken(incident.getStatus());
                            %>
                            <tr>
                                <td class="mono nowrap">#<%= incident.getId() %></td>
                                <td>
                                    <div class="table-title">
                                        <a href="<%= ctx %>/incident-history"><%= HtmlUtil.escape(incident.getTitle()) %></a>
                                    </div>
                                    <div class="table-sub"><%= HtmlUtil.escape(FormatUtil.shortText(incident.getDescription(), 72)) %></div>
                                </td>
                                <td><span class="badge type no-dot"><%= HtmlUtil.escape(incident.getIncidentType()) %></span></td>
                                <td><span class="badge severity-<%= severityToken %>"><%= HtmlUtil.escape(incident.getSeverity()) %></span></td>
                                <td><span class="badge status-<%= statusToken %>"><%= HtmlUtil.escape(FormatUtil.statusLabel(incident.getStatus())) %></span></td>
                                <td class="mono nowrap"><%= FormatUtil.dateTime(incident.getCreatedAt()) %></td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } else { %>
                    <div class="empty">
                        <span class="empty-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                                <path d="M9 12l2 2 4-4"/>
                            </svg>
                        </span>
                        <h3>No incidents reported yet</h3>
                        <p>Your workspace is clear. Report your first incident to start tracking response activity.</p>
                        <a class="btn btn-primary btn-sm" href="<%= ctx %>/report-incident">Report incident</a>
                    </div>
                    <% } %>
                </section>

                <div class="stack">
                    <section class="card">
                        <div class="card-head">
                            <div>
                                <div class="card-title">Severity mix</div>
                                <div class="card-sub">Distribution across your incidents</div>
                            </div>
                        </div>
                        <% if (severityMix != null && !severityMix.isEmpty()) { %>
                        <div class="legend">
                            <% for (Map.Entry<String, Integer> entry : severityMix.entrySet()) {
                                String severityToken = FormatUtil.cssToken(entry.getKey());
                            %>
                            <div class="legend-row">
                                <span class="badge severity-<%= severityToken %>"><%= HtmlUtil.escape(entry.getKey()) %></span>
                                <span class="legend-label"></span>
                                <span class="legend-value"><%= entry.getValue() %></span>
                            </div>
                            <% } %>
                        </div>
                        <div class="card-pad" style="padding-top:0">
                            <div class="info-grid">
                                <div class="info-tile">
                                    <div class="it-label">Open cases</div>
                                    <div class="it-value"><%= open %></div>
                                </div>
                                <div class="info-tile">
                                    <div class="it-label">Resolution rate</div>
                                    <div class="it-value"><%= resolutionRate %>%</div>
                                </div>
                            </div>
                        </div>
                        <% } else { %>
                        <div class="empty">
                            <h3>No severity data</h3>
                            <p>Report an incident to see the severity distribution.</p>
                        </div>
                        <% } %>
                    </section>

                    <section class="card">
                        <div class="card-head">
                            <div class="card-title">Quick actions</div>
                        </div>
                        <div class="quick-list">
                            <a class="quick-link accent-cyan" href="<%= ctx %>/report-incident">
                                <span class="ql-icon">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <circle cx="12" cy="12" r="9"/>
                                        <path d="M12 8v8M8 12h8"/>
                                    </svg>
                                </span>
                                <span>
                                    <strong>Report an incident</strong>
                                    <span>Log a new security event</span>
                                </span>
                            </a>
                            <a class="quick-link accent-blue" href="<%= ctx %>/profile">
                                <span class="ql-icon">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <circle cx="12" cy="8" r="3.4"/>
                                        <path d="M5 20c.7-3.4 3.5-5.4 7-5.4s6.3 2 7 5.4"/>
                                    </svg>
                                </span>
                                <span>
                                    <strong>Profile settings</strong>
                                    <span>Update your name and email</span>
                                </span>
                            </a>
                            <% if (dashboardIsAdmin) { %>
                            <a class="quick-link accent-purple" href="<%= ctx %>/admin/dashboard">
                                <span class="ql-icon">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                                        <path d="M9 12l2 2 4-4"/>
                                    </svg>
                                </span>
                                <span>
                                    <strong>Administration console</strong>
                                    <span>Review all incidents and users</span>
                                </span>
                            </a>
                            <% } %>
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
