<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.cybershield.util.CsrfUtil" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
    String pageTitle = "Report incident";
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
                    <div class="eyebrow">Workspace / Intake</div>
                    <h1>Report a security incident</h1>
                    <p class="page-sub">
                        Capture what happened while the details are fresh. Reports are
                        linked to your account and enter the queue with an open status.
                    </p>
                </div>
                <div class="page-actions">
                    <a class="btn btn-ghost" href="<%= ctx %>/dashboard">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M19 12H5M11 18l-6-6 6-6"/>
                        </svg>
                        Back to dashboard
                    </a>
                </div>
            </div>

            <div class="detail-grid">
                <section class="card">
                    <div class="card-head">
                        <div>
                            <div class="card-title">Incident details</div>
                            <div class="card-sub">Fields marked required must be completed</div>
                        </div>
                        <span class="badge status-open no-dot">New report</span>
                    </div>

                    <form action="<%= ctx %>/report-incident" method="post" class="card-pad">
                        <input type="hidden" name="csrfToken"
                               value="<%= CsrfUtil.getToken(session) %>">

                        <div class="form-grid">
                            <div class="field span-2">
                                <label for="title">Incident title *</label>
                                <input id="title" name="title" type="text"
                                       maxlength="150" required
                                       placeholder="e.g. Suspicious login attempts from unknown region">
                                <span class="help">Use a short, specific summary an analyst can scan quickly.</span>
                            </div>

                            <div class="field">
                                <label for="incidentType">Incident type *</label>
                                <select id="incidentType" name="incidentType" required>
                                    <option value="">Select a category</option>
                                    <option value="Phishing">Phishing</option>
                                    <option value="Malware">Malware</option>
                                    <option value="Unauthorized Access">Unauthorized Access</option>
                                    <option value="Password Attack">Password Attack</option>
                                    <option value="Data Breach">Data Breach</option>
                                    <option value="Network Attack">Network Attack</option>
                                    <option value="Suspicious Activity">Suspicious Activity</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>

                            <div class="field">
                                <label for="severity">Severity *</label>
                                <select id="severity" name="severity" required>
                                    <option value="LOW">Low</option>
                                    <option value="MEDIUM" selected>Medium</option>
                                    <option value="HIGH">High</option>
                                    <option value="CRITICAL">Critical</option>
                                </select>
                                <span class="help">Critical incidents should also be escalated through your normal on-call process.</span>
                            </div>

                            <div class="field span-2">
                                <label for="description">Description *</label>
                                <textarea id="description" name="description"
                                          maxlength="5000" required
                                          placeholder="Explain what happened, when it happened, which systems or accounts were involved, and what you observed. Do not include passwords, tokens or secret keys."></textarea>
                                <span class="help">Up to 5,000 characters. Include evidence references where possible.</span>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button class="btn btn-primary" type="submit">
                                <svg viewBox="0 0 24 24" aria-hidden="true">
                                    <path d="M22 2L11 13"/>
                                    <path d="M22 2l-7 20-4-9-9-4 20-7z"/>
                                </svg>
                                Submit report
                            </button>
                            <a class="btn btn-ghost" href="<%= ctx %>/incident-history">Cancel</a>
                        </div>
                    </form>
                </section>

                <aside class="stack">
                    <section class="card">
                        <div class="card-head">
                            <div class="card-title">Reporting guidance</div>
                        </div>
                        <div class="card-pad">
                            <div class="timeline">
                                <div class="timeline-item">
                                    <div class="t-label">Be specific</div>
                                    <div class="t-value">Name the systems, accounts and time window involved.</div>
                                </div>
                                <div class="timeline-item">
                                    <div class="t-label">Preserve evidence</div>
                                    <div class="t-value">Reference log sources, screenshots or alert IDs without copying secrets.</div>
                                </div>
                                <div class="timeline-item">
                                    <div class="t-label">Choose severity carefully</div>
                                    <div class="t-value">Use critical for active compromise or confirmed data exposure.</div>
                                </div>
                                <div class="timeline-item">
                                    <div class="t-label">No secrets</div>
                                    <div class="t-value">Never paste passwords, API keys or private tokens into a report.</div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="card">
                        <div class="card-head">
                            <div class="card-title">What happens next</div>
                        </div>
                        <div class="card-pad">
                            <div class="timeline">
                                <div class="timeline-item">
                                    <div class="t-label">Logged as open</div>
                                    <div class="t-value">Your report enters the queue immediately.</div>
                                </div>
                                <div class="timeline-item">
                                    <div class="t-label">Triage and investigation</div>
                                    <div class="t-value">Severity is reviewed and the case moves to in progress.</div>
                                </div>
                                <div class="timeline-item">
                                    <div class="t-label">Resolution</div>
                                    <div class="t-value">The case is closed with a resolution timestamp and responder.</div>
                                </div>
                            </div>
                        </div>
                    </section>
                </aside>
            </div>
        </main>
    </div>
</div>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
