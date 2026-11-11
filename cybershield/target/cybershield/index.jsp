<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String pageTitle = "Security Operations";
    String ctx = request.getContextPath();
    Object landingUserId = session.getAttribute("userId");
    boolean landingLoggedIn = landingUserId != null;
    String landingRole = String.valueOf(session.getAttribute("role"));
    String consoleHref = "ADMIN".equalsIgnoreCase(landingRole)
            ? ctx + "/admin/dashboard" : ctx + "/dashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/includes/head.jspf" %>
</head>
<body>
<div class="landing">
    <nav class="landing-nav" aria-label="Primary">
        <a class="brand" href="<%= ctx %>/">
            <span class="brand-mark" aria-hidden="true">
                <svg viewBox="0 0 24 24">
                    <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                    <path d="M9 12l2 2 4-4"/>
                </svg>
            </span>
            <span class="brand-text">
                <strong>CyberShield</strong>
                <span>Security operations</span>
            </span>
        </a>
        <div class="spacer"></div>
        <button class="icon-btn" type="button" data-theme-toggle aria-label="Toggle colour theme">
            <svg class="moon" viewBox="0 0 24 24" aria-hidden="true">
                <path d="M20 14.5A8 8 0 019.5 4a8 8 0 1010.5 10.5z"/>
            </svg>
            <svg class="sun" viewBox="0 0 24 24" aria-hidden="true">
                <circle cx="12" cy="12" r="4"/>
                <path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>
            </svg>
        </button>
        <% if (landingLoggedIn) { %>
        <a class="btn btn-primary btn-sm" href="<%= consoleHref %>">Open console</a>
        <% } else { %>
        <a class="btn btn-ghost btn-sm" href="<%= ctx %>/login.jsp">Sign in</a>
        <a class="btn btn-primary btn-sm" href="<%= ctx %>/register.jsp">Get started</a>
        <% } %>
    </nav>

    <main class="landing-hero">
        <div>
            <div class="eyebrow">Incident response platform</div>
            <h1>Detect, report and <span>neutralise</span> security incidents.</h1>
            <p class="lead">
                CyberShield gives security teams a single operations console for
                intake, triage and resolution. Report threats, track ownership and
                measure response performance without losing context.
            </p>
            <div class="landing-cta">
                <% if (landingLoggedIn) { %>
                <a class="btn btn-primary" href="<%= consoleHref %>">Return to console</a>
                <% } else { %>
                <a class="btn btn-primary" href="<%= ctx %>/register.jsp">Create an account</a>
                <a class="btn btn-ghost" href="<%= ctx %>/login.jsp">Sign in to console</a>
                <% } %>
            </div>
            <div class="landing-stats">
                <div class="landing-stat">
                    <strong>8</strong>
                    <span>Incident categories</span>
                </div>
                <div class="landing-stat">
                    <strong>3</strong>
                    <span>Response states</span>
                </div>
                <div class="landing-stat">
                    <strong>4</strong>
                    <span>Severity levels</span>
                </div>
                <div class="landing-stat">
                    <strong>RBAC</strong>
                    <span>Role-based access</span>
                </div>
            </div>
        </div>

        <aside class="hero-panel" aria-label="Console preview">
            <div class="hp-head">
                <span class="hp-title">Live queue preview</span>
                <span class="badge status-in-progress no-dot">Monitoring</span>
            </div>
            <div class="hp-row danger">
                <span class="hp-dot"></span>
                <span class="hp-label">Unauthorized access attempt
                    <span>Edge gateway · critical</span>
                </span>
                <span class="hp-value">13:58</span>
            </div>
            <div class="hp-row warn">
                <span class="hp-dot"></span>
                <span class="hp-label">Phishing campaign reported
                    <span>Mail security · high</span>
                </span>
                <span class="hp-value">13:42</span>
            </div>
            <div class="hp-row">
                <span class="hp-dot"></span>
                <span class="hp-label">Malware sample contained
                    <span>Endpoint · resolved</span>
                </span>
                <span class="hp-value">13:25</span>
            </div>
            <div class="hp-row warn">
                <span class="hp-dot"></span>
                <span class="hp-label">Password attack mitigated
                    <span>Identity provider · medium</span>
                </span>
                <span class="hp-value">13:09</span>
            </div>
            <div class="hp-row">
                <span class="hp-dot"></span>
                <span class="hp-label">Network scan detected
                    <span>Perimeter · in progress</span>
                </span>
                <span class="hp-value">12:54</span>
            </div>
        </aside>
    </main>

    <section class="feature-grid" aria-label="Platform capabilities">
        <article class="card feature-card">
            <div class="fc-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M12 3l7 3v5c0 4.5-2.9 8.3-7 10-4.1-1.7-7-5.5-7-10V6l7-3z"/>
                    <path d="M9 12l2 2 4-4"/>
                </svg>
            </div>
            <h3>Structured incident intake</h3>
            <p>Capture category, severity and evidence in a consistent format so every report is actionable.</p>
        </article>
        <article class="card feature-card">
            <div class="fc-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M4 7h16M4 12h10M4 17h7"/>
                    <circle cx="18" cy="16" r="3"/>
                    <path d="M20.5 18.5L23 21"/>
                </svg>
            </div>
            <h3>Triage and investigation</h3>
            <p>Move cases through open, in-progress and resolved states while keeping investigation notes attached.</p>
        </article>
        <article class="card feature-card">
            <div class="fc-icon">
                <svg viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/>
                </svg>
            </div>
            <h3>SOC analytics</h3>
            <p>Track severity mix, case status and category trends from the administration analytics workspace.</p>
        </article>
    </section>

    <footer class="landing-footer">
        CyberShield · Security operations console · Built on Jakarta EE
    </footer>
</div>
<script src="<%= ctx %>/js/cybershield.js"></script>
</body>
</html>
