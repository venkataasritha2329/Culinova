
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="java.util.List" %>
<%@ page import="com.tap.model.CartItem" %>

<%
    String contextPath = request.getContextPath();
    boolean loggedIn = session.getAttribute("user") != null;

    int cartCount = 0;

    List<CartItem> cartItems =
        (List<CartItem>) session.getAttribute("cartItems");

    if (cartItems != null) {
        for (CartItem item : cartItems) {
            cartCount += item.getQuantity();
        }
    }
%>
<style>
:root {
    color-scheme: light;
    --nav-bg: #FFFFFF;
    --nav-text: #342820;
    --nav-border: #EEE5DC;
    --nav-accent: #B85F3B;
    --nav-hover: #F8EAE1;
    --profile-bg: #F8EAE1;
    --profile-text: #8D3F24;
    --toggle-bg: #F5EEE7;
    --toggle-text: #60422E;
}

html[data-theme="dark"] {
    color-scheme: dark;
    --nav-bg: #211C18;
    --nav-text: #F8F0E8;
    --nav-border: #45372D;
    --nav-accent: #F3A17C;
    --nav-hover: #3B2921;
    --profile-bg: #F3A17C;
    --profile-text: #24150F;
    --toggle-bg: #3B2921;
    --toggle-text: #FFE0A3;
}

.navbar,
.navbar * {
    box-sizing: border-box;
}

.navbar {
    position: relative;
    z-index: 1000;
    width: 100%;
    min-height: 88px;
    padding: 15px 5%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    background: var(--nav-bg);
    color: var(--nav-text);
    border-bottom: 1px solid var(--nav-border);
    transition: background-color .25s, color .25s;
}

/* LOGO */
.navbar-brand {
    display: inline-flex;
    align-items: center;
    gap: 11px;
    flex-shrink: 0;
    text-decoration: none;
}

.navbar-brand img {
    display: block;
    width: 46px;
    height: 46px;
    object-fit: contain;
}

.navbar-brand span {
    color: var(--nav-accent);
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 29px;
    font-weight: 700;
}

/* NAVIGATION */
.nav-links {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 22px;
}

.nav-links > a {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    color: var(--nav-text);
    font-family: 'DM Sans', Arial, sans-serif;
    font-size: 14px;
    font-weight: 600;
    text-decoration: none;
    white-space: nowrap;
    transition: color .2s;
}

.nav-icon {
    font-size: 17px;
    line-height: 1;
}

.nav-links > a:hover,
.nav-links > a.active {
    color: var(--nav-accent);
}

/* THEME TOGGLE */
.theme-toggle {
    min-width: 90px;
    height: 38px;
    padding: 0 10px;
    flex-shrink: 0;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 5px;
    border: 1px solid var(--nav-border);
    border-radius: 24px;
    background: var(--toggle-bg);
    color: var(--toggle-text);
    font-family: 'DM Sans', Arial, sans-serif;
    font-size: 12px;
    font-weight: 600;
    line-height: 1;
    white-space: nowrap;
    cursor: pointer;
    transition: background-color .25s, color .25s,
                border-color .25s, transform .2s;
}

.theme-toggle:hover {
    border-color: var(--nav-accent);
}

.theme-toggle #themeIcon {
    display: inline-block;
    font-size: 20px;
    line-height: 1;
}

.theme-toggle:focus-visible,
.navbar a:focus-visible,
.profile-trigger:focus-visible {
    outline: 2px solid var(--nav-accent);
    outline-offset: 4px;
}

/* LOGIN */
.login-link {
    padding: 11px 18px;
    border-radius: 24px;
    background: var(--nav-accent);
    color: #FFFFFF !important;
}

/* PROFILE DROPDOWN */
.profile-dropdown {
    position: relative;
    display: inline-block;
    flex-shrink: 0;
    z-index: 10000;
}

.profile-trigger {
    width: 44px;
    height: 44px;
    padding: 0;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border: 1px solid var(--nav-border);
    border-radius: 50%;
    background: var(--profile-bg);
    color: var(--profile-text);
    font-size: 23px;
    line-height: 1;
    cursor: pointer;
}

.profile-trigger:hover {
    outline: 2px solid var(--nav-accent);
    outline-offset: 2px;
}

.profile-menu {
    display: none;
    position: absolute;
    top: calc(100% + 10px);
    right: 0;
    min-width: 190px;
    padding: 8px;
    background: var(--nav-bg);
    color: var(--nav-text);
    border: 1px solid var(--nav-border);
    border-radius: 12px;
    box-shadow: 0 8px 24px rgba(65, 39, 25, 0.18);
    z-index: 10001;
}

.profile-menu.show {
    display: block;
}

.profile-menu a {
    display: block;
    padding: 12px 14px;
    color: var(--nav-text);
    text-decoration: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    white-space: nowrap;
}

.profile-menu a:hover {
    background: var(--nav-hover);
    color: var(--nav-accent);
}

/* RESPONSIVE */
@media (max-width: 900px) {
    .navbar {
        padding: 15px 4%;
        gap: 15px;
    }

    .navbar-brand span {
        font-size: 25px;
    }

    .navbar-brand img {
        width: 40px;
        height: 40px;
    }

    .nav-links {
        gap: 14px;
    }

    .nav-links > a {
        font-size: 13px;
    }
}

@media (max-width: 700px) {
    .navbar {
        flex-wrap: wrap;
        justify-content: center;
    }

    .navbar-brand {
        width: 100%;
        justify-content: center;
    }

    .nav-links {
        width: 100%;
        justify-content: center;
        flex-wrap: wrap;
        gap: 14px;
    }
}

@media (max-width: 400px) {
    .nav-links {
        gap: 10px;
    }

    .nav-links > a {
        gap: 4px;
        font-size: 12px;
    }

    .nav-icon {
        font-size: 15px;
    }

    .theme-toggle {
        min-width: 84px;
        padding: 0 8px;
        font-size: 11px;
    }

    .theme-toggle #themeIcon {
        font-size: 19px;
    }
}


.cart-link {
    display: inline-flex;
    align-items: center;
    gap: 7px;
}

.cart-icon-wrapper {
    position: relative;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}

.cart-count {
    position: absolute;
    top: -10px;
    right: -12px;
    min-width: 19px;
    height: 19px;
    padding: 0 5px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50px;
    background: #B85F3B;
    color: #FFFFFF;
    border: 2px solid var(--nav-bg);
    font-size: 10px;
    font-weight: 700;
    line-height: 1;
}


/* CULINOVA LOGO */
.navbar-brand {
    display: inline-flex;
    align-items: center;
    gap: 11px;
    flex-shrink: 0;
    text-decoration: none;
}

.navbar-brand img {
    display: block;
    width: 48px;
    height: 48px;
    object-fit: contain;
    flex-shrink: 0;
}

.navbar-brand .brand-name {
    display: inline-flex;
    align-items: center;
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 29px;
    font-weight: 700;
    line-height: 1.2;
    white-space: nowrap;
}

.navbar-brand .brand-culi {
    color: var(--nav-text);
}

.navbar-brand .brand-nova {
    color: var(--nav-accent);
}

.navbar-brand:hover .brand-nova {
    filter: brightness(1.1);
}

@media (max-width: 900px) {
    .navbar-brand img {
        width: 42px;
        height: 42px;
    }

    .navbar-brand .brand-name {
        font-size: 25px;
    }
}




</style>

<nav class="navbar" aria-label="Main navigation">

    <!-- LOGO -->
    <!-- LOGO -->
<a class="navbar-brand"
   href="<%= contextPath %>/home"
   aria-label="Culinova home">

    <img
        src="<%= contextPath %>/images/logo.png"
        alt="Culinova logo"
        onerror="this.style.display='none';">

    <span class="brand-name">
        <span class="brand-culi">Culi</span><span class="brand-nova">nova</span>
    </span>

</a>

    <div class="nav-links">

        <a href="<%= contextPath %>/home">
            <span class="nav-icon" aria-hidden="true">🏠</span>
            <span>Home</span>
        </a>

        <a href="<%= contextPath %>/restaurant">
            <span class="nav-icon" aria-hidden="true">🍽️</span>
            <span>Restaurants</span>
        </a>

        <a href="<%= contextPath %>/orders">
            <span class="nav-icon" aria-hidden="true">🚚</span>
            <span>Orders</span>
        </a>

        <a href="<%= contextPath %>/cart" class="cart-link" aria-label="Cart">
    <span class="cart-icon-wrapper">
        <span class="nav-icon" aria-hidden="true">🛒</span>

        <% if (cartCount > 0) { %>
            <span class="cart-count"><%= cartCount %></span>
        <% } %>
    </span>

    
</a>

        <!-- THEME BUTTON -->
        <button
            type="button"
            class="theme-toggle"
            id="themeToggle"
            aria-label="Switch theme"
            title="Switch light or dark theme">

            <span id="themeIcon" aria-hidden="true">☾</span>
            <span id="themeLabel">Dark Mode</span>
        </button>

        <!-- PROFILE OR LOGIN -->
        <% if (loggedIn) { %>

            <div class="profile-dropdown" id="profileDropdown">

                <button
                    type="button"
                    class="profile-trigger"
                    id="profileTrigger"
                    aria-label="Open profile menu"
                    aria-expanded="false"
                    aria-controls="profileMenu">
                    👤
                </button>

                <div class="profile-menu" id="profileMenu">

                    <a href="<%= contextPath %>/profile">
                        My Profile
                    </a>

                    <a href="<%= contextPath %>/settings.jsp">
                        Settings
                    </a>

                    <a href="<%= contextPath %>/favourites.jsp">
                        Favourite
                    </a>

                    <a href="<%= contextPath %>/logout"
                       class="logout-link">
                        Logout
                    </a>

                </div>
            </div>

        <% } else { %>

            <a
                class="login-link"
                href="<%= contextPath %>/login">
                Login
            </a>

        <% } %>

    </div>
</nav>

<script>
(function () {
    "use strict";

    const root = document.documentElement;
    const toggle = document.getElementById("themeToggle");
    const icon = document.getElementById("themeIcon");
    const label = document.getElementById("themeLabel");
    const storageKey = "culinova-theme";

    /* THEME HANDLING */
    function applyTheme(theme) {
        const selectedTheme = theme === "dark" ? "dark" : "light";

        root.setAttribute("data-theme", selectedTheme);

        if (icon) {
            icon.textContent = selectedTheme === "dark" ? "☼" : "⏾";
        }

        if (label) {
            label.textContent =
                selectedTheme === "dark" ? "Light Mode" : "Dark Mode";
        }

        if (toggle) {
            toggle.setAttribute(
                "aria-label",
                "Current theme: " + selectedTheme +
                ". Click to switch theme."
            );

            toggle.setAttribute("title", "Switch light or dark theme");
        }
    }

    let savedTheme = "light";

    try {
        const saved = localStorage.getItem(storageKey);

        if (saved === "light" || saved === "dark") {
            savedTheme = saved;
        }
    } catch (error) {
        // Use the default theme if browser storage is unavailable.
    }

    applyTheme(savedTheme);

    if (toggle) {
        toggle.addEventListener("click", function () {
            const currentTheme =
                root.getAttribute("data-theme") || "light";

            const nextTheme =
                currentTheme === "dark" ? "light" : "dark";

            applyTheme(nextTheme);

            try {
                localStorage.setItem(storageKey, nextTheme);
            } catch (error) {
                // The theme still changes on the current page.
            }
        });
    }

    /* PROFILE DROPDOWN */
    const profileTrigger = document.getElementById("profileTrigger");
    const profileMenu = document.getElementById("profileMenu");

    if (profileTrigger && profileMenu) {

        profileTrigger.addEventListener("click", function (event) {
            event.preventDefault();
            event.stopPropagation();

            const isOpen = profileMenu.classList.toggle("show");

            profileTrigger.setAttribute(
                "aria-expanded",
                isOpen ? "true" : "false"
            );
        });

        profileMenu.addEventListener("click", function (event) {
            event.stopPropagation();
        });

        document.addEventListener("click", function () {
            profileMenu.classList.remove("show");
            profileTrigger.setAttribute("aria-expanded", "false");
        });

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                profileMenu.classList.remove("show");
                profileTrigger.setAttribute("aria-expanded", "false");
            }
        });
    }

    /* HIGHLIGHT CURRENT NAVIGATION PAGE */
    const currentPath = window.location.pathname;

    document.querySelectorAll(".nav-links > a").forEach(function (link) {
        const linkPath = new URL(link.href).pathname;

        if (linkPath === currentPath) {
            link.classList.add("active");
            link.setAttribute("aria-current", "page");
        }
    });

})();
</script>
