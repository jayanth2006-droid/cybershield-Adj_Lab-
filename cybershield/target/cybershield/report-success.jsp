<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.util.HtmlUtil" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
    String pageTitle = "Report submitted";
    String referenceParam = request.getParameter("id");
    String reference = referenceParam != null && referenceParam.matches("\\d{1,9}")
            ? referenceParam : null;
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
                    <div class="eyebrow">Workspace / Intake</div>
                    <h1>Report submitted</h1>
                    <p class="page-sub">Your incident has been recorded and added to the response queue.</p>
                </div>
            </div>

            <section class="card" style="max-width:720px;margin:0 auto">
                <div class="empty" style="padding:48px 28px">
                    <span class="empty-icon" style="color:var(--green);background:rgba(52,211,153,.10);border-color:rgba(52,211,153,.26)">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M20 6L9 17l-5-5"/>
                        </svg>
                    </span>
                    <h3 style="font-size:1.2rem">Incident logged successfully</h3>
                    <p>
                        CyberShield has stored your report with an open status. You can
                        update its progress at any time from your incident history.
                    </p>
                    <% if (reference != null) { %>
                    <div class="info-tile" style="min-width:220px">
                        <div class="it-label">Incident reference</div>
                        <div class="it-value mono">#<%= HtmlUtil.escape(reference) %></div>
                    </div>
                    <% } %>
                    <div class="page-actions" style="justify-content:center;margin-top:8px">
                        <a class="btn btn-ghost" href="<%= ctx %>/incident-history">View my incidents</a>
                        <a class="btn btn-primary" href="<%= ctx %>/report-incident">Report another</a>
                    </div>
                    <a href="<%= ctx %>/dashboard" style="font-size:.82rem;font-weight:600">Back to dashboard</a>
                </div>
            </section>
        </main>
    </div>
</div>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
