<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.model.User" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
<%@ page import="java.util.Map" %>

<%!
    private String renderBars(Map<String, Integer> values,
                              String color,
                              boolean prettifyStatus) {

        if (values == null || values.isEmpty()) {
            return "<div class=\"empty\" style=\"padding:30px\"><h3>No data yet</h3>"
                    + "<p>Incident activity will populate this chart.</p></div>";
        }

        int max = 0;

        for (Integer value : values.values()) {
            if (value != null && value > max) {
                max = value;
            }
        }

        StringBuilder html = new StringBuilder("<div class=\"bars\">");

        for (Map.Entry<String, Integer> entry : values.entrySet()) {

            int count = entry.getValue() == null ? 0 : entry.getValue();

            int pct = max == 0 ? 0 :
                    (int) Math.round(count * 100.0 / max);

            String label = entry.getKey() == null ? "Unknown" : entry.getKey();

            if (prettifyStatus) {
                label = com.cybershield.util.FormatUtil.statusLabel(label);
            }

            String safeLabel = com.cybershield.util.HtmlUtil.escape(label);

            html.append("<div class=\"bar-row\">")
                .append("<span class=\"bar-label\" title=\"")
                .append(safeLabel)
                .append("\">")
                .append(safeLabel)
                .append("</span>")
                .append("<div class=\"bar-track\"><div class=\"bar-fill\" style=\"width:")
                .append(pct)
                .append("%;background:")
                .append(color)
                .append(";color:")
                .append(color)
                .append("\"></div></div>")
                .append("<span class=\"bar-value\">")
                .append(count)
                .append("</span>")
                .append("</div>");
        }

        return html.append("</div>").toString();
    }
%>

<%
    Object adminObject = request.getAttribute("adminUser");

    if (!(adminObject instanceof User)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Administrator access is required.");
        return;
    }

    User adminUser = (User) adminObject;

    String ctx = request.getContextPath();
    String pageTitle = "Analytics";

    int[] stats = (int[]) request.getAttribute("stats");

    if (stats == null) {
        stats = new int[]{0, 0, 0, 0};
    }

    int total = stats[0];
    int open = stats[1];
    int inProgress = stats[2];
    int resolved = stats[3];

    int resolutionRate = total == 0 ? 0 :
            (int) Math.round(resolved * 100.0 / total);

    int activeWorkload = open + inProgress;

    Map<String, Integer> severityDistribution =
            (Map<String, Integer>) request.getAttribute("severityDistribution");

    Map<String, Integer> statusDistribution =
            (Map<String, Integer>) request.getAttribute("statusDistribution");

    Map<String, Integer> typeDistribution =
            (Map<String, Integer>) request.getAttribute("typeDistribution");

    Object userCountObject = request.getAttribute("userCount");

    int userCount = userCountObject instanceof Number
            ? ((Number) userCountObject).intValue() : 0;

    int categoryCount = typeDistribution == null
            ? 0 : typeDistribution.size();
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

            <div class="page-head">

                <div>
                    <div class="eyebrow">Administration / Insights</div>

                    <h1>Analytics</h1>

                    <p class="page-sub">
                        Understand incident pressure across severity, response state and
                        attack category. Use the queue to act on the cases behind these numbers.
                    </p>
                </div>

                <div class="page-actions">

                    <a class="btn btn-ghost"
                       href="<%= ctx %>/admin/dashboard">
                        SOC overview
                    </a>

                    <a class="btn btn-primary"
                       href="<%= ctx %>/admin/incidents">
                        Open queue
                    </a>

                </div>
            </div>

            <section class="stat-grid" aria-label="Analytics summary">

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
                    <div class="stat-meta"><%= categoryCount %> categories in use</div>

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
                    <div class="stat-meta">Awaiting triage</div>

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
                    <div class="stat-meta">Active investigation</div>

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

                    <div class="stat-meta">
                        <strong><%= resolutionRate %>%</strong> resolution rate
                    </div>

                </article>

            </section>

            <section class="chart-card-grid" aria-label="Incident distributions">

                <article class="card">

                    <div class="card-head">
                        <div>
                            <div class="card-title">Severity distribution</div>
                            <div class="card-sub">Share of incidents by severity</div>
                        </div>
                    </div>

                    <%= renderBars(severityDistribution, "var(--orange)", false) %>

                </article>

                <article class="card">

                    <div class="card-head">
                        <div>
                            <div class="card-title">Response status</div>
                            <div class="card-sub">Case state across the queue</div>
                        </div>
                    </div>

                    <%= renderBars(statusDistribution, "var(--cyan)", true) %>

                </article>

                <article class="card">

                    <div class="card-head">
                        <div>
                            <div class="card-title">Incident categories</div>
                            <div class="card-sub">Most reported attack types</div>
                        </div>
                    </div>

                    <%= renderBars(typeDistribution, "var(--purple)", false) %>

                </article>

            </section>

            <section class="card mt-18">

                <div class="card-head">
                    <div>
                        <div class="card-title">Response performance</div>
                        <div class="card-sub">
                            Operational snapshot for the current queue
                        </div>
                    </div>
                </div>

                <div class="card-pad">

                    <div class="info-grid">

                        <div class="info-tile">
                            <div class="it-label">Resolution rate</div>
                            <div class="it-value"><%= resolutionRate %>%</div>
                        </div>

                        <div class="info-tile">
                            <div class="it-label">Active workload</div>
                            <div class="it-value"><%= activeWorkload %></div>
                        </div>

                        <div class="info-tile">
                            <div class="it-label">Registered users</div>
                            <div class="it-value"><%= userCount %></div>
                        </div>

                        <div class="info-tile">
                            <div class="it-label">Categories tracked</div>
                            <div class="it-value"><%= categoryCount %></div>
                        </div>

                    </div>

                </div>

            </section>

        </main>

    </div>

</div>

<script src="<%= ctx %>/js/cybershield.js"></script>

</body>
</html>