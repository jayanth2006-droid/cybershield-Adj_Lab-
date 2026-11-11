/* CyberShield shared UI behaviour */
(function () {
    "use strict";

    var root = document.documentElement;

    function applyTheme(theme) {
        if (theme === "light") {
            root.setAttribute("data-theme", "light");
        } else {
            root.removeAttribute("data-theme");
        }
    }

    try {
        var saved = localStorage.getItem("cs-theme");
        if (saved) {
            applyTheme(saved);
        }
    } catch (e) {
        /* storage may be unavailable */
    }

    document.addEventListener("click", function (event) {
        var themeButton = event.target.closest("[data-theme-toggle]");
        if (themeButton) {
            var next = root.getAttribute("data-theme") === "light" ? "dark" : "light";
            applyTheme(next);
            try {
                localStorage.setItem("cs-theme", next);
            } catch (e) {
                /* ignore */
            }
            return;
        }

        var sidebarToggle = event.target.closest("[data-sidebar-toggle]");
        var sidebar = document.getElementById("appSidebar");
        var overlay = document.getElementById("sidebarOverlay");

        if (sidebarToggle && sidebar) {
            sidebar.classList.toggle("open");
            if (overlay) {
                overlay.classList.toggle("show");
            }
            return;
        }

        if (overlay && event.target === overlay && sidebar) {
            sidebar.classList.remove("open");
            overlay.classList.remove("show");
        }
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape") {
            var sidebar = document.getElementById("appSidebar");
            var overlay = document.getElementById("sidebarOverlay");
            if (sidebar) {
                sidebar.classList.remove("open");
            }
            if (overlay) {
                overlay.classList.remove("show");
            }
        }
    });

    document.querySelectorAll("[data-confirm]").forEach(function (form) {
        form.addEventListener("submit", function (event) {
            var message = form.getAttribute("data-confirm");
            if (message && !window.confirm(message)) {
                event.preventDefault();
            }
        });
    });

    window.setTimeout(function () {
        document.querySelectorAll(".alert[data-autohide]").forEach(function (alert) {
            alert.style.transition = "opacity .35s ease, transform .35s ease";
            alert.style.opacity = "0";
            alert.style.transform = "translateY(-6px)";
            window.setTimeout(function () {
                alert.remove();
            }, 400);
        });
    }, 6500);
})();
