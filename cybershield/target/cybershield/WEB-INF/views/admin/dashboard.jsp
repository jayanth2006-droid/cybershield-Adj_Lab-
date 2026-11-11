<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.model.Incident" %>
<%@ page import="com.cybershield.model.User" %>
<%@ page import="com.cybershield.util.FormatUtil" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    Object adminObject = request.getAttribute("adminUser");
    if (!(adminObject instanceof User)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Administrator access is required.");
        return;
    }
    User adminUser = (User) adminObject;
    String ctx = request.getContextPath();
    String pageTitle = "SOC overview";

    int[] stats = (int[]) request.getAttribute("stats");
    if (stats == null) {
        stats = new int[]{0, 0, 0, 0};
    }
    int total = stats[0];
    int open = stats[1];
    int inProgress = stats[2];
    int resolved = stats[3];
    int resolutionRate = total == 0 ? 0 : (int) Math.round(resolved * 100.0 / total);
    int activeWorkload = open + inProgress;

    List<Incident> recentIncidents = (List<Incident>) request.getAttribute("recentIncidents");
    Map<String, Integer> severityMix = (Map<String, Integer>) request.getAttribute("severityDistribution");
    Object userCountObject = request.getAttribute("userCount");
    int userCount = userCountObject instanceof Number ? ((Number) userCountObject).intValue() : 0;
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
                    <div class="eyebrow">Administration / Overview</div>
                    <h1>SOC overview</h1>
                    <p class="page-sub">
                        A consolidated view of every incident in CyberShield. Use this
                        workspace to triage, investigate and close cases across all analysts.
                    </p>
                </div>
                <div class="page-actions">
                    <a class="btn btn-ghost" href="<%= ctx %>/admin/analytics">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>
                        </svg>
                        Analytics
                    </a>
                    <a class="btn btn-primary" href="<%= ctx %>/admin/incidents">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M12 3l9 5-9 5-9-5 9-5z"/>
                            <path d="M3 12l9 5 9-5"/>
                        </svg>
                        Manage incidents
                    </a>
                </div>
            </div>

            <section class="stat-grid" aria-label="Organisation incident statistics">
                <article class="stat-card accent-cyan">
                    <div class="stat-top">
                        <span class="stat-label">Total incidents</span>
                        <span class="stat-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <path d="M12 3l9 5-9 5-9-5 9-5z"/>
                                <path d="M3 12l9 5 9-5"/>
                                <path d="M3 16l9 5 9-5"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-value"><%= total %></div>
                    <div class="stat-meta">Across <strong><%= userCount %></strong> registered users</div>
                </article>

                <article class="stat-card accent-amber">
                    <div class="stat-top">
                        <span class="stat-label">Open queue</span>
                        <span class="stat-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <circle cx="12" cy="12" r="9"/>
                                <path d="M12 8v5M12 16.5v.5"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-value"><%= open %></div>
                    <div class="stat-meta">Awaiting triage</div>
                </article>

                <article class="stat-card accent-blue">
                    <div class="stat-top">
                        <span class="stat-label">Under investigation</span>
                        <span class="stat-icon">
                            <svg viewBox="0 0 24 24" aria-hidden="true">
                                <circle cx="12" cy="12" r="9"/>
                                <path d="M12 7v5l3 2"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-value"><%= inProgress %></div>
                    <div class="stat-meta">Active workload</div>
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
                            <div class="card-title">Latest incidents</div>
                            <div class="card-sub">Most recent reports across the organisation</div>
                        </div>
                        <a class="btn btn-ghost btn-sm" href="<%= ctx %>/admin/incidents">View all</a>
                    </div>

                    <% if (recentIncidents != null && !recentIncidents.isEmpty()) { %>
                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Incident</th>
                                <th>Reporter</th>
                                <th>Severity</th>
                                <th>Status</th>
                                <th>Reported</th>
                                <th></th>
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
                                        <a href="<%= ctx %>/admin/incident?id=<%= incident.getId() %>"><%= HtmlUtil.escape(incident.getTitle()) %></a>
                                    </div>
                                    <div class="table-sub"><%= HtmlUtil.escape(FormatUtil.shortText(incident.getDescription(), 64)) %></div>
                                </td>
                                <td>
                                    <div><%= HtmlUtil.escape(incident.getReporterName() == null ? "Unknown" : incident.getReporterName()) %></div>
                                    <div class="table-sub mono">@<%= HtmlUtil.escape(incident.getReporterUsername() == null ? "unknown" : incident.getReporterUsername()) %></div>
                                </td>
                                <td><span class="badge severity-<%= severityToken %>"><%= HtmlUtil.escape(incident.getSeverity()) %></span></td>
                                <td><span class="badge status-<%= statusToken %>"><%= HtmlUtil.escape(FormatUtil.statusLabel(incident.getStatus())) %></span></td>
                                <td class="mono nowrap"><%= FormatUtil.dateTime(incident.getCreatedAt()) %></td>
                                <td class="text-right">
                                    <a class="btn btn-ghost btn-sm" href="<%= ctx %>/admin/incident?id=<%= incident.getId() %>">Open</a>
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
                                <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                                <path d="M9 12l2 2 4-4"/>
                            </svg>
                        </span>
                        <h3>No incidents in the queue</h3>
                        <p>The organisation has no incident reports yet.</p>
                    </div>
                    <% } %>
                </section>

                <div class="stack">
                    <section class="card">
                        <div class="card-head">
                            <div>
                                <div class="card-title">Queue health</div>
                                <div class="card-sub">Active workload and severity mix</div>
                            </div>
                        </div>
                        <div class="card-pad">
                            <div class="info-grid">
                                <div class="info-tile">
                                    <div class="it-label">Active workload</div>
                                    <div class="it-value"><%= activeWorkload %></div>
                                </div>
                                <div class="info-tile">
                                    <div class="it-label">Resolution rate</div>
                                    <div class="it-value"><%= resolutionRate %>%</div>
                                </div>
                                <div class="info-tile">
                                    <div class="it-label">Registered users</div>
                                    <div class="it-value"><%= userCount %></div>
                                </div>
                                <div class="info-tile">
                                    <div class="it-label">Signed in as</div>
                                    <div class="it-value">@<%= HtmlUtil.escape(adminUser.getUsername()) %></div>
                                </div>
                            </div>
                        </div>
                        <% if (severityMix != null && !severityMix.isEmpty()) { %>
                        <div class="legend" style="padding-top:0">
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
                        <% } %>
                    </section>

                    <section class="card">
                        <div class="card-head">
                            <div class="card-title">Administration shortcuts</div>
                        </div>
                        <div class="quick-list">
                            <a class="quick-link accent-amber" href="<%= ctx %>/admin/incidents">
                                <span class="ql-icon">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M12 3l9 5-9 5-9-5 9-5z"/>
                                        <path d="M3 12l9 5 9-5"/>
                                    </svg>
                                </span>
                                <span>
                                    <strong>Incident queue</strong>
                                    <span>Filter, open and resolve cases</span>
                                </span>
                            </a>
                            <a class="quick-link accent-purple" href="<%= ctx %>/admin/users">
                                <span class="ql-icon">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <circle cx="9" cy="8" r="3"/>
                                        <path d="M3.5 19c.6-2.8 2.8-4.4 5.5-4.4s4.9 1.6 5.5 4.4"/>
                                        <path d="M16 5.5a3 3 0 010 5.4"/>
                                    </svg>
                                </span>
                                <span>
                                    <strong>User directory</strong>
                                    <span>Review accounts and roles</span>
                                </span>
                            </a>
                            <a class="quick-link accent-green" href="<%= ctx %>/admin/analytics">
                                <span class="ql-icon">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>
                                    </svg>
                                </span>
                                <span>
                                    <strong>Analytics</strong>
                                    <span>Severity, status and category trends</span>
                                </span>
                            </a>
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
