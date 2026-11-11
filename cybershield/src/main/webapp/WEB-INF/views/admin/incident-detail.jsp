
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="jakarta.servlet.http.HttpServletResponse" %>
<%@ page import="com.cybershield.model.Incident" %>
<%@ page import="com.cybershield.model.User" %>
<%@ page import="com.cybershield.util.CsrfUtil" %>
<%@ page import="com.cybershield.util.FormatUtil" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>

<%
    Object adminObject = request.getAttribute("adminUser");
    Object incidentObject = request.getAttribute("incident");

    if (!(adminObject instanceof User) || !(incidentObject instanceof Incident)) {
        response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Administrator access is required.");
        return;
    }

    User adminUser = (User) adminObject;
    Incident incident = (Incident) incidentObject;

    String ctx = request.getContextPath();
    String pageTitle = "Incident #" + incident.getId();

    String severityToken = FormatUtil.cssToken(incident.getSeverity());
    String statusToken = FormatUtil.cssToken(incident.getStatus());

    String notes = incident.getInvestigationNotes() == null
            ? "" : incident.getInvestigationNotes();

    boolean resolved = "RESOLVED".equals(incident.getStatus())
            || incident.getResolvedAt() != null;

    String resolvedAtLabel = incident.getResolvedAt() == null
            ? "Not recorded"
            : FormatUtil.dateTime(incident.getResolvedAt());

    String resolverLabel;

    if (incident.getResolverName() != null) {
        resolverLabel = incident.getResolverName();
    } else if (incident.getResolvedBy() != null) {
        resolverLabel = "User #" + incident.getResolvedBy();
    } else {
        resolverLabel = "Not recorded";
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

            <div class="page-head">

                <div>
                    <div class="eyebrow">
                        Administration / Incident #<%= incident.getId() %>
                    </div>

                    <h1><%= HtmlUtil.escape(incident.getTitle()) %></h1>

                    <p class="page-sub">
                        Review the report, record investigation notes and move the case
                        through the response workflow.
                    </p>
                </div>

                <div class="page-actions">

                    <a class="btn btn-ghost" href="<%= ctx %>/admin/incidents">

                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M19 12H5M11 18l-6-6 6-6"/>
                        </svg>

                        Back to queue

                    </a>

                </div>

            </div>

            <div class="detail-grid">

                <div class="stack">

                    <!-- Incident report -->

                    <section class="card">

                        <div class="card-head">

                            <div>
                                <div class="card-title">Incident report</div>

                                <div class="card-sub">
                                    Submitted <%= FormatUtil.dateTime(incident.getCreatedAt()) %>
                                </div>
                            </div>

                            <div class="detail-meta" style="margin-top:0">

                                <span class="badge type no-dot">
                                    <%= HtmlUtil.escape(incident.getIncidentType()) %>
                                </span>

                                <span class="badge severity-<%= severityToken %>">
                                    <%= HtmlUtil.escape(incident.getSeverity()) %>
                                </span>

                                <span class="badge status-<%= statusToken %>">
                                    <%= HtmlUtil.escape(FormatUtil.statusLabel(incident.getStatus())) %>
                                </span>

                            </div>

                        </div>

                        <div class="card-pad">

                            <div class="prose">
                                <%= HtmlUtil.escape(incident.getDescription()) %>
                            </div>

                        </div>

                    </section>

                    <!-- Investigation form -->

                    <section class="card">

                        <div class="card-head">

                            <div>
                                <div class="card-title">Investigation</div>
                                <div class="card-sub">
                                    Notes are visible to administrators only
                                </div>
                            </div>

                        </div>

                        <form class="card-pad"
                              action="<%= ctx %>/admin/incident/update"
                              method="post">

                            <input type="hidden"
                                   name="csrfToken"
                                   value="<%= CsrfUtil.getToken(session) %>">

                            <input type="hidden"
                                   name="incidentId"
                                   value="<%= incident.getId() %>">

                            <div class="form-grid">

                                <div class="field span-2">

                                    <label for="status">Response status</label>

                                    <select id="status" name="status" required>

                                        <option value="OPEN"
                                            <%= "OPEN".equals(incident.getStatus()) ? "selected" : "" %>>
                                            Open
                                        </option>

                                        <option value="IN_PROGRESS"
                                            <%= "IN_PROGRESS".equals(incident.getStatus()) ? "selected" : "" %>>
                                            In Progress
                                        </option>

                                        <option value="RESOLVED"
                                            <%= "RESOLVED".equals(incident.getStatus()) ? "selected" : "" %>>
                                            Resolved
                                        </option>

                                    </select>

                                    <span class="help">
                                        Resolving a case records a resolution timestamp and your account as resolver.
                                    </span>

                                </div>

                                <div class="field span-2">

                                    <label for="investigationNotes">
                                        Investigation notes
                                    </label>

                                    <textarea id="investigationNotes"
                                              name="investigationNotes"
                                              maxlength="5000"
                                              placeholder="Record evidence reviewed, containment actions, root cause and next steps."><%= HtmlUtil.escape(notes) %></textarea>

                                    <span class="help">
                                        Up to 5,000 characters. Existing notes are kept if this field is left unchanged.
                                    </span>

                                </div>

                            </div>

                            <div class="form-actions">

                                <button class="btn btn-primary" type="submit">

                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path d="M5 4h11l3 3v13H5z"/>
                                        <path d="M8 4v5h7V4M8 20v-6h8v6"/>
                                    </svg>

                                    Save investigation

                                </button>

                                <a class="btn btn-ghost"
                                   href="<%= ctx %>/admin/incidents">
                                    Cancel
                                </a>

                            </div>

                        </form>

                    </section>

                </div>

                <div class="stack">

                    <!-- Reporter details -->

                    <section class="card">

                        <div class="card-head">
                            <div class="card-title">Reporter</div>
                        </div>

                        <div class="card-pad">

                            <div class="meta-list"
                                 style="margin-top:0;padding-top:0;border-top:0">

                                <div class="meta-row">
                                    <span>Name</span>
                                    <strong>
                                        <%= HtmlUtil.escape(incident.getReporterName() == null
                                                ? "Unknown" : incident.getReporterName()) %>
                                    </strong>
                                </div>

                                <div class="meta-row">
                                    <span>Username</span>
                                    <strong class="mono">
                                        @<%= HtmlUtil.escape(incident.getReporterUsername() == null
                                                ? "unknown" : incident.getReporterUsername()) %>
                                    </strong>
                                </div>

                                <div class="meta-row">
                                    <span>Email</span>
                                    <strong>
                                        <%= HtmlUtil.escape(incident.getReporterEmail() == null
                                                ? "—" : incident.getReporterEmail()) %>
                                    </strong>
                                </div>

                                <div class="meta-row">
                                    <span>User ID</span>
                                    <strong class="mono">
                                        #<%= incident.getReportedBy() %>
                                    </strong>
                                </div>

                            </div>

                        </div>

                    </section>

                    <!-- Case metadata -->

                    <section class="card">

                        <div class="card-head">
                            <div class="card-title">Case metadata</div>
                        </div>

                        <div class="card-pad">

                            <div class="info-grid">

                                <div class="info-tile">
                                    <div class="it-label">Incident</div>
                                    <div class="it-value mono">
                                        #<%= incident.getId() %>
                                    </div>
                                </div>

                                <div class="info-tile">
                                    <div class="it-label">Category</div>
                                    <div class="it-value">
                                        <%= HtmlUtil.escape(incident.getIncidentType()) %>
                                    </div>
                                </div>

                                <div class="info-tile">
                                    <div class="it-label">Severity</div>
                                    <div class="it-value">
                                        <%= HtmlUtil.escape(incident.getSeverity()) %>
                                    </div>
                                </div>

                                <div class="info-tile">
                                    <div class="it-label">Status</div>
                                    <div class="it-value">
                                        <%= HtmlUtil.escape(FormatUtil.statusLabel(incident.getStatus())) %>
                                    </div>
                                </div>

                            </div>

                        </div>

                    </section>

                    <!-- Timeline -->

                    <section class="card">

                        <div class="card-head">
                            <div class="card-title">Timeline</div>
                        </div>

                        <div class="card-pad">

                            <div class="timeline">

                                <div class="timeline-item">
                                    <div class="t-label">Reported</div>
                                    <div class="t-value">
                                        <%= FormatUtil.dateTime(incident.getCreatedAt()) %>
                                    </div>
                                </div>

                                <div class="timeline-item">
                                    <div class="t-label">Last updated</div>
                                    <div class="t-value">
                                        <%= FormatUtil.dateTime(incident.getUpdatedAt()) %>
                                    </div>
                                </div>

                                <% if (resolved) { %>

                                    <div class="timeline-item">
                                        <div class="t-label">Resolved</div>
                                        <div class="t-value">
                                            <%= resolvedAtLabel %>
                                        </div>
                                    </div>

                                    <div class="timeline-item">
                                        <div class="t-label">Resolved by</div>
                                        <div class="t-value">
                                            <%= HtmlUtil.escape(resolverLabel) %>
                                        </div>
                                    </div>

                                <% } else { %>

                                    <div class="timeline-item">
                                        <div class="t-label">Resolution</div>
                                        <div class="t-value">
                                            Not resolved yet
                                        </div>
                                    </div>

                                <% } %>

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
