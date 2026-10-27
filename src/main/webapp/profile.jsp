
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="com.tap.model.User" %>

<%!
    private String safe(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    String contextPath = request.getContextPath();
    User user = (User) request.getAttribute("user");

    if (user == null) {
        response.sendRedirect(contextPath + "/profile");
        return;
    }

    boolean hasError = request.getAttribute("profileError") != null;

    String username = user.getUsername() == null ? "" : user.getUsername();
    String email = user.getEmail() == null ? "" : user.getEmail();
    String phone = user.getPhone() == 0 ? "" : String.valueOf(user.getPhone());
    String alternatePhone = user.getAlternatePhone() == null
            ? "" : user.getAlternatePhone();
    String dob = user.getDob() == null ? "" : user.getDob().toString();
    String address = user.getAddress() == null ? "" : user.getAddress();
    String landmark = user.getLandmark() == null ? "" : user.getLandmark();
    String city = user.getCity() == null ? "" : user.getCity();
    String state = user.getState() == null ? "" : user.getState();
    String pincode = user.getPincode() == null ? "" : user.getPincode();
    String instructions = user.getDeliveryInstructions() == null
            ? "" : user.getDeliveryInstructions();

    String role = user.getRole() == null || user.getRole().isBlank()
            ? "Customer" : user.getRole();

    String initial = username.isBlank()
            ? "U" : username.substring(0, 1).toUpperCase();
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>My Profile | Culinova</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap"
      rel="stylesheet">

<style>
:root {
    --page-bg: #FAF7F2;
    --card-bg: #FFFFFF;
    --text: #342820;
    --muted: #827469;
    --accent: #B85F3B;
    --accent-hover: #984727;
    --accent-soft: #F8EAE1;
    --border: #EAE0D6;
    --input-bg: #FFFFFF;
    --disabled-bg: #F8F6F3;
    --success-bg: #E9F7ED;
    --success-text: #24683B;
    --error-bg: #FFF0ED;
    --error-text: #A33D2D;
    --shadow: 0 8px 30px rgba(62, 43, 28, 0.055);
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    margin: 0;
    background: var(--page-bg);
    color: var(--text);
    font-family: 'DM Sans', Arial, sans-serif;
    font-size: 14px;
    line-height: 1.6;
}

a {
    color: inherit;
    text-decoration: none;
}

button,
input,
textarea {
    font: inherit;
}

button {
    cursor: pointer;
}

/* MAIN PAGE LAYOUT */

.page-layout {
    width: min(1440px, 100%);
    min-height: calc(100vh - 88px);
    margin: 0 auto;
    padding: 34px 5%;
    display: grid;
    grid-template-columns: 250px minmax(0, 1fr);
    align-items: start;
    gap: 28px;
}

.main-content {
    min-width: 0;
}

/* LEFT SIDEBAR */

.sidebar {
    position: sticky;
    top: 24px;
    padding: 22px 15px;
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
}

.sidebar-profile {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 0 8px 8px;
}

.sidebar-avatar {
    width: 46px;
    height: 46px;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 14px;
    background: var(--accent-soft);
    color: var(--accent);
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 22px;
    font-weight: 700;
    text-transform: uppercase;
}

.sidebar-user-info {
    min-width: 0;
}

.sidebar-user-info h3 {
    margin: 0;
    overflow-wrap: anywhere;
    font-size: 14px;
    font-weight: 700;
}

.sidebar-user-info p {
    margin: 3px 0 0;
    color: var(--muted);
    font-size: 11px;
    text-transform: capitalize;
}

.sidebar-heading {
    padding: 0 10px;
    margin: 17px 0 10px;
    color: var(--muted);
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 1.2px;
    text-transform: uppercase;
}

.side-link {
    display: flex;
    align-items: center;
    gap: 11px;
    padding: 12px 11px;
    margin-bottom: 4px;
    border-radius: 10px;
    color: var(--text);
    font-size: 12px;
    font-weight: 600;
    transition: background .2s ease, color .2s ease;
}

.side-link .side-icon {
    width: 22px;
    flex-shrink: 0;
    text-align: center;
    font-size: 17px;
}

.side-link:hover,
.side-link.active {
    background: var(--accent-soft);
    color: var(--accent);
}

.sidebar-divider {
    height: 1px;
    margin: 15px 8px;
    background: var(--border);
}

.sidebar-note {
    padding: 14px;
    margin-top: 20px;
    border: 1px solid var(--border);
    border-radius: 12px;
    background: var(--page-bg);
    color: var(--muted);
    font-size: 11px;
}

.sidebar-note strong {
    color: var(--accent);
    font-size: 12px;
}

.sidebar-note p {
    margin: 6px 0 0;
    line-height: 1.6;
}

/* BREADCRUMB */

.breadcrumb {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 9px;
    margin: 0 0 23px;
    color: var(--muted);
    font-size: 13px;
}

.breadcrumb a:hover {
    color: var(--accent);
}

.breadcrumb-current {
    color: var(--text);
    font-weight: 600;
}

/* PAGE HEADING */

.page-heading {
    margin-bottom: 24px;
}

.eyebrow {
    margin: 0 0 6px;
    color: var(--accent);
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
}

.page-heading h1 {
    margin: 0;
    font-family: 'Playfair Display', Georgia, serif;
    font-size: clamp(28px, 3vw, 37px);
    line-height: 1.25;
}

.page-heading p {
    margin: 10px 0 0;
    color: var(--muted);
    font-size: 14px;
}

/* NOTIFICATIONS */

.notice {
    padding: 13px 16px;
    margin-bottom: 20px;
    border: 1px solid transparent;
    border-radius: 10px;
    font-size: 13px;
}

.notice.success {
    border-color: #CDE8D4;
    background: var(--success-bg);
    color: var(--success-text);
}

.notice.error {
    border-color: #F1C9C1;
    background: var(--error-bg);
    color: var(--error-text);
}

/* PROFILE SUMMARY */

.profile-card {
    overflow: hidden;
    margin-bottom: 24px;
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
}

.profile-cover {
    height: 95px;
    background:
        radial-gradient(circle at 85% 20%,
            rgba(255,255,255,.35), transparent 24%),
        linear-gradient(120deg, #8D472D, #B85F3B 60%, #D99B78);
}

.profile-overview {
    display: flex;
    align-items: center;
    gap: 18px;
    padding: 0 26px 25px;
}

.avatar {
    width: 88px;
    height: 88px;
    flex: 0 0 88px;
    margin-top: -42px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 5px solid var(--card-bg);
    border-radius: 50%;
    background: var(--accent-soft);
    color: var(--accent);
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 34px;
    font-weight: 700;
    text-transform: uppercase;
}

.profile-summary {
    flex: 1;
    min-width: 0;
    padding-top: 13px;
}

.profile-summary h2 {
    margin: 0;
    overflow-wrap: anywhere;
    font-size: 21px;
    font-weight: 700;
}

.profile-summary p {
    margin: 3px 0 10px;
    color: var(--muted);
    overflow-wrap: anywhere;
}

.role-badge {
    display: inline-flex;
    align-items: center;
    padding: 5px 11px;
    border-radius: 20px;
    background: var(--accent-soft);
    color: var(--accent);
    font-size: 11px;
    font-weight: 700;
    text-transform: capitalize;
}

/* BUTTONS */

.edit-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    min-height: 42px;
    padding: 0 17px;
    border: 1px solid var(--accent);
    border-radius: 9px;
    background: var(--accent);
    color: #FFFFFF;
    font-weight: 700;
    transition: background .2s, transform .2s;
}

.edit-button:hover {
    background: var(--accent-hover);
    transform: translateY(-1px);
}

.edit-button.secondary {
    background: var(--card-bg);
    color: var(--text);
    border-color: var(--border);
}

.edit-button.secondary:hover {
    background: var(--page-bg);
}

/* PROFILE FORM */

.details-card {
    padding: 27px;
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
}

.section-heading {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 16px;
    padding-bottom: 20px;
    margin-bottom: 23px;
    border-bottom: 1px solid var(--border);
}

.section-heading h2 {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
}

.section-heading p {
    margin: 5px 0 0;
    color: var(--muted);
    font-size: 12px;
}

.status-label {
    flex-shrink: 0;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 10px;
    border-radius: 7px;
    background: var(--page-bg);
    color: var(--muted);
    font-size: 11px;
    font-weight: 700;
}

.status-dot {
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: #7B9C65;
}

.form-section-title {
    display: flex;
    align-items: center;
    gap: 10px;
    margin: 26px 0 18px;
    font-size: 14px;
    font-weight: 700;
    scroll-margin-top: 24px;
}

.section-number {
    width: 28px;
    height: 28px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    border-radius: 8px;
    background: var(--accent-soft);
    color: var(--accent);
    font-size: 12px;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 21px 20px;
}

.form-group {
    min-width: 0;
    scroll-margin-top: 24px;
}

.form-group.full-width {
    grid-column: 1 / -1;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    color: var(--text);
    font-size: 12px;
    font-weight: 700;
}

.required-mark {
    color: var(--accent);
}

.form-group input,
.form-group textarea {
    display: block;
    width: 100%;
    min-width: 0;
    padding: 12px 14px;
    border: 1px solid #DED4CA;
    border-radius: 9px;
    outline: none;
    background: var(--input-bg);
    color: var(--text);
    font-size: 13px;
    transition: border-color .2s, box-shadow .2s, background .2s;
}

.form-group input {
    height: 45px;
}

.form-group textarea {
    min-height: 90px;
    resize: vertical;
}

.form-group input:disabled,
.form-group textarea:disabled {
    border-color: transparent;
    background: var(--disabled-bg);
    color: var(--text);
    opacity: 1;
    cursor: default;
}

.form-group input:focus,
.form-group textarea:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(184, 95, 59, .12);
}

.form-group input:disabled:focus,
.form-group textarea:disabled:focus {
    box-shadow: none;
}

.field-hint {
    display: block;
    margin-top: 6px;
    color: var(--muted);
    font-size: 11px;
}

/* FORM FOOTER */

.form-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 15px;
    padding-top: 24px;
    margin-top: 28px;
    border-top: 1px solid var(--border);
}

.form-footer-note {
    max-width: 300px;
    color: var(--muted);
    font-size: 12px;
}

.form-actions {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}

.form-actions button {
    min-height: 43px;
}

#saveButton,
#cancelButton {
    display: none;
}

.editing #saveButton,
.editing #cancelButton {
    display: inline-flex;
}

.editing #editButton {
    display: none;
}

/* BOTTOM LINKS */

.bottom-navigation {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 12px;
    padding: 20px 2px 0;
}

.bottom-navigation a {
    color: var(--muted);
    font-size: 12px;
    font-weight: 600;
}

.bottom-navigation a:hover {
    color: var(--accent);
}

/* RESPONSIVE DESIGN */

@media (max-width: 1000px) {
    .page-layout {
        grid-template-columns: 220px minmax(0, 1fr);
        gap: 18px;
        padding: 25px 3%;
    }

    .details-card {
        padding: 22px;
    }

    .profile-overview {
        padding-right: 20px;
        padding-left: 20px;
    }
}

@media (max-width: 760px) {
    .page-layout {
        grid-template-columns: 1fr;
        padding: 22px 4%;
    }

    .sidebar {
        position: static;
        padding: 14px;
    }

    .sidebar-heading,
    .sidebar-note,
    .sidebar-divider {
        display: none;
    }

    .sidebar-profile {
        margin-bottom: 10px;
    }

    .sidebar nav {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
    }

    .side-link {
        margin: 0;
        padding: 10px 12px;
        font-size: 12px;
    }

    .profile-overview {
        flex-wrap: wrap;
    }

    .profile-summary {
        flex-basis: calc(100% - 110px);
    }

    .profile-overview > .edit-button {
        margin-left: auto;
    }
}

@media (max-width: 520px) {
    .page-layout {
        padding: 18px 14px;
    }

    .page-heading h1 {
        font-size: 29px;
    }

    .profile-cover {
        height: 75px;
    }

    .profile-overview {
        padding: 0 16px 20px;
        gap: 12px;
    }

    .avatar {
        width: 72px;
        height: 72px;
        flex-basis: 72px;
        margin-top: -34px;
        font-size: 28px;
    }

    .profile-summary h2 {
        font-size: 17px;
    }

    .profile-summary p {
        font-size: 12px;
        overflow-wrap: anywhere;
    }

    .profile-overview > .edit-button {
        width: 100%;
    }

    .details-card {
        padding: 18px 15px;
    }

    .section-heading {
        flex-direction: column;
    }

    .form-grid {
        grid-template-columns: 1fr;
        gap: 17px;
    }

    .form-group.full-width {
        grid-column: auto;
    }

    .form-footer {
        align-items: stretch;
        flex-direction: column;
    }

    .form-actions {
        width: 100%;
    }

    .form-actions button {
        flex: 1;
    }

    .side-link {
        padding: 9px;
    }

    .side-link .side-icon {
        display: none;
    }
}



/* =========================================
   CULINOVA — NEUMORPHIC PROFILE DESIGN
   Add at the end of the existing style block
========================================= */

:root {
    --page-bg: #F1EBE3;
    --card-bg: #F5F0E9;
    --text: #342820;
    --muted: #827469;
    --accent: #B85F3B;
    --accent-hover: #984727;
    --accent-soft: #F2E3D8;
    --border: #E9DFD4;
    --input-bg: #F3EDE5;
    --disabled-bg: #F1EBE3;
    --success-bg: #E9F7ED;
    --success-text: #24683B;
    --error-bg: #FFF0ED;
    --error-text: #A33D2D;

    --neu-raised:
        7px 7px 16px rgba(151, 130, 108, 0.18),
        -7px -7px 16px rgba(255, 255, 255, 0.85);

    --neu-raised-small:
        4px 4px 9px rgba(151, 130, 108, 0.16),
        -4px -4px 9px rgba(255, 255, 255, 0.8);

    --neu-inset:
        inset 4px 4px 8px rgba(151, 130, 108, 0.14),
        inset -4px -4px 8px rgba(255, 255, 255, 0.8);

    --shadow: var(--neu-raised);
}

/* Page background */

body {
    background: var(--page-bg);
}

/* Sidebar and main cards */

.sidebar,
.profile-card,
.details-card {
    background: var(--card-bg);
    border: 1px solid rgba(255, 255, 255, 0.65);
    border-radius: 22px;
    box-shadow: var(--neu-raised);
}

/* Sidebar */

.sidebar {
    padding: 24px 17px;
}

.sidebar-avatar {
    border-radius: 50%;
    background: var(--card-bg);
    box-shadow: var(--neu-raised-small);
}

.sidebar-divider {
    background: rgba(174, 153, 131, 0.22);
}

.side-link {
    border: 1px solid transparent;
    border-radius: 12px;
    transition: all 0.22s ease;
}

.side-link:hover {
    background: var(--card-bg);
    color: var(--accent);
    box-shadow: var(--neu-raised-small);
    transform: translateX(2px);
}

.side-link.active {
    background: var(--accent-soft);
    color: var(--accent);
    box-shadow: var(--neu-inset);
    border-color: rgba(184, 95, 59, 0.08);
}

.sidebar-note {
    background: var(--page-bg);
    border: 1px solid rgba(255, 255, 255, 0.7);
    border-radius: 15px;
    box-shadow: var(--neu-inset);
}

/* Profile cover */

.profile-card {
    overflow: hidden;
}

.profile-cover {
    height: 110px;
    background:
        radial-gradient(
            circle at 82% 25%,
            rgba(255, 255, 255, 0.35),
            transparent 22%
        ),
        radial-gradient(
            circle at 65% 100%,
            rgba(255, 224, 203, 0.18),
            transparent 35%
        ),
        linear-gradient(125deg, #8D472D, #B85F3B 58%, #D99B78);
}

/* Main profile avatar */

.avatar {
    border: 6px solid var(--card-bg);
    background: var(--card-bg);
    box-shadow:
        6px 6px 12px rgba(111, 74, 51, 0.17),
        -5px -5px 12px rgba(255, 255, 255, 0.9);
}

.role-badge {
    border: 1px solid rgba(184, 95, 59, 0.1);
    box-shadow: var(--neu-inset);
}

/* Main buttons */

.edit-button {
    border: 1px solid var(--accent);
    border-radius: 12px;
    box-shadow:
        4px 4px 9px rgba(151, 91, 62, 0.18),
        -3px -3px 8px rgba(255, 255, 255, 0.48);
    transition: all 0.2s ease;
}

.edit-button:hover {
    box-shadow:
        2px 2px 5px rgba(151, 91, 62, 0.18),
        -2px -2px 5px rgba(255, 255, 255, 0.4);
    transform: translateY(-1px);
}

.edit-button:active {
    transform: translateY(0);
    box-shadow: var(--neu-inset);
}

.edit-button.secondary {
    background: var(--card-bg);
    border-color: var(--border);
    color: var(--text);
    box-shadow: var(--neu-raised-small);
}

.edit-button.secondary:hover {
    background: var(--card-bg);
    box-shadow: var(--neu-inset);
}

/* Details card */

.details-card {
    padding: 30px;
}

.section-heading {
    border-bottom-color: rgba(174, 153, 131, 0.24);
}

.status-label {
    border: 1px solid rgba(255, 255, 255, 0.75);
    background: var(--card-bg);
    box-shadow: var(--neu-inset);
    border-radius: 10px;
}

.section-number {
    border-radius: 9px;
    background: var(--card-bg);
    box-shadow: var(--neu-raised-small);
}

/* Inputs — recessed neumorphic effect */

.form-group input,
.form-group textarea {
    background: var(--input-bg);
    border: 1px solid rgba(220, 207, 192, 0.65);
    border-radius: 12px;
    box-shadow: var(--neu-inset);
    transition:
        border-color 0.2s ease,
        box-shadow 0.2s ease,
        background 0.2s ease;
}

.form-group input:focus,
.form-group textarea:focus {
    background: #F8F2EB;
    border-color: rgba(184, 95, 59, 0.65);
    box-shadow:
        inset 3px 3px 6px rgba(151, 130, 108, 0.1),
        inset -3px -3px 6px rgba(255, 255, 255, 0.65),
        0 0 0 3px rgba(184, 95, 59, 0.12);
}

.form-group input:disabled,
.form-group textarea:disabled {
    background: var(--page-bg);
    border-color: transparent;
    box-shadow: none;
    color: var(--text);
    opacity: 1;
}

.form-group input:disabled:focus,
.form-group textarea:disabled:focus {
    box-shadow: none;
}

/* Form footer */

.form-footer {
    border-top-color: rgba(174, 153, 131, 0.24);
}

.bottom-navigation a {
    transition: color 0.2s ease;
}

/* Breadcrumb */

.breadcrumb a {
    transition: color 0.2s ease;
}

/* Notices retain clear success/error contrast */

.notice {
    border-radius: 12px;
    box-shadow: var(--neu-raised-small);
}

/* Keyboard accessibility */

.side-link:focus-visible,
.edit-button:focus-visible,
.breadcrumb a:focus-visible {
    outline: 2px solid var(--accent);
    outline-offset: 4px;
}

/* Responsive refinements */

@media (max-width: 760px) {
    .sidebar,
    .profile-card,
    .details-card {
        border-radius: 18px;
    }

    .sidebar {
        box-shadow: var(--neu-raised-small);
    }
}

@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        scroll-behavior: auto !important;
        transition-duration: 0.01ms !important;
        animation-duration: 0.01ms !important;
    }
}



</style>
</head>

<body>

<!-- EXISTING TOP NAVBAR -->
<jsp:include page="/navbar.jsp" />

<div class="page-layout">

    <!-- LEFT SIDEBAR -->
    <aside class="sidebar">

        <div class="sidebar-profile">
            <div class="sidebar-avatar">
                <%= safe(initial) %>
            </div>

            <div class="sidebar-user-info">
                <h3><%= safe(username) %></h3>
                <p><%= safe(role) %> Account</p>
            </div>
        </div>

        <div class="sidebar-divider"></div>

        <p class="sidebar-heading">My Account</p>

        <nav aria-label="Profile navigation">

            <a class="side-link active"
               href="<%= contextPath %>/profile"
               aria-current="page">
                <span class="side-icon">◉</span>
                <span>Account Overview</span>
            </a>

            <a class="side-link" href="#basicDetails">
                <span class="side-icon">♙</span>
                <span>Personal Information</span>
            </a>

            <a class="side-link" href="#deliveryAddress">
                <span class="side-icon">⌖</span>
                <span>Delivery Addresses</span>
            </a>

            <a class="side-link" href="<%= contextPath %>/orders">
                <span class="side-icon">▤</span>
                <span>Order History</span>
            </a>

            <a class="side-link"
               href="<%= contextPath %>/favourites.jsp">
                <span class="side-icon">♡</span>
                <span>Favourite Restaurants</span>
            </a>

            <div class="sidebar-divider"></div>

            <p class="sidebar-heading">Preferences</p>

            <a class="side-link" href="#deliveryInstructions">
                <span class="side-icon">♨</span>
                <span>Delivery Preferences</span>
            </a>

            <a class="side-link"
               href="<%= contextPath %>/settings.jsp">
                <span class="side-icon">⚙</span>
                <span>Account Settings</span>
            </a>

            <a class="side-link"
               href="<%= contextPath %>/forgot-password.jsp">
                <span class="side-icon">♧</span>
                <span>Security &amp; Password</span>
            </a>

            <div class="sidebar-divider"></div>

            <p class="sidebar-heading">Support</p>

            <a class="side-link"
               href="<%= contextPath %>/contact.jsp">
                <span class="side-icon">✉</span>
                <span>Help &amp; Support</span>
            </a>

        </nav>

        <div class="sidebar-note">
            <strong>Made for food lovers</strong>
            <p>
                Keep your profile updated for a smoother
                Culinova experience.
            </p>
        </div>

    </aside>

    <!-- MAIN PROFILE CONTENT -->
    <main class="main-content">

        <div class="breadcrumb">
            <a href="<%= contextPath %>/home">Home</a>
            <span>/</span>
            <span class="breadcrumb-current">My Profile</span>
        </div>

        <header class="page-heading">
            <p class="eyebrow">Your Account</p>
            <h1>My Profile</h1>
            <p>
                View and manage your personal information
                and delivery details.
            </p>
        </header>

        <% if (request.getAttribute("profileMessage") != null) { %>
            <div class="notice success" role="status">
                <%= safe(String.valueOf(
                    request.getAttribute("profileMessage"))) %>
            </div>
        <% } %>

        <% if (request.getAttribute("profileError") != null) { %>
            <div class="notice error" role="alert">
                <%= safe(String.valueOf(
                    request.getAttribute("profileError"))) %>
            </div>
        <% } %>

        <!-- PROFILE SUMMARY CARD -->
        <section class="profile-card" aria-label="Profile summary">

            <div class="profile-cover"></div>

            <div class="profile-overview">

                <div class="avatar" aria-label="Profile initial">
                    <%= safe(initial) %>
                </div>

                <div class="profile-summary">
                    <h2><%= safe(username) %></h2>
                    <p><%= safe(email) %></p>

                    <span class="role-badge">
                        <%= safe(role) %>
                    </span>
                </div>

                <button type="button"
                        class="edit-button"
                        id="editButton">
                    <span aria-hidden="true">✎</span>
                    Edit Details
                </button>

            </div>
        </section>

        <!-- PROFILE DETAILS FORM -->
        <form id="profileForm"
              class="<%= hasError ? "editing" : "" %>"
              action="<%= contextPath %>/profile"
              method="post">

            <section class="details-card">

                <div class="section-heading">
                    <div>
                        <h2>Personal Information</h2>
                        <p>
                            Select Edit Details to update your
                            personal and delivery information.
                        </p>
                    </div>

                    <span class="status-label">
                        <span class="status-dot"></span>
                        <span id="statusText">
                            <%= hasError ? "Editing details" : "View only" %>
                        </span>
                    </span>
                </div>

                <!-- BASIC DETAILS -->
                <h3 class="form-section-title" id="basicDetails">
                    <span class="section-number">01</span>
                    Basic Details
                </h3>

                <div class="form-grid">

                    <div class="form-group">
                        <label for="username">
                            Full Name <span class="required-mark">*</span>
                        </label>

                        <input type="text"
                               id="username"
                               name="username"
                               value="<%= safe(username) %>"
                               maxlength="100"
                               autocomplete="name"
                               required
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                    <div class="form-group">
                        <label for="email">
                            Email Address <span class="required-mark">*</span>
                        </label>

                        <input type="email"
                               id="email"
                               name="email"
                               value="<%= safe(email) %>"
                               maxlength="150"
                               autocomplete="email"
                               required
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                    <div class="form-group">
                        <label for="phone">
                            Phone Number <span class="required-mark">*</span>
                        </label>

                        <input type="tel"
                               id="phone"
                               name="phone"
                               value="<%= safe(phone) %>"
                               maxlength="10"
                               minlength="10"
                               pattern="[0-9]{10}"
                               title="Enter exactly 10 digits."
                               inputmode="numeric"
                               autocomplete="tel"
                               required
                               <%= hasError ? "" : "disabled" %>>

                        <span class="field-hint">
                            Enter exactly 10 digits.
                        </span>
                    </div>

                    <div class="form-group">
                        <label for="alternatePhone">
                            Alternate Phone Number
                        </label>

                        <input type="tel"
                               id="alternatePhone"
                               name="alternatePhone"
                               value="<%= safe(alternatePhone) %>"
                               maxlength="10"
                               minlength="10"
                               pattern="[0-9]{10}"
                               title="Enter exactly 10 digits or leave empty."
                               inputmode="numeric"
                               autocomplete="tel"
                               <%= hasError ? "" : "disabled" %>>

                        <span class="field-hint">
                            Optional. If provided, enter 10 digits.
                        </span>
                    </div>

                    <div class="form-group">
                        <label for="dob">Date of Birth</label>

                        <input type="date"
                               id="dob"
                               name="dob"
                               value="<%= safe(dob) %>"
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                </div>

                <!-- DELIVERY ADDRESS -->
                <h3 class="form-section-title" id="deliveryAddress">
                    <span class="section-number">02</span>
                    Delivery Address
                </h3>

                <div class="form-grid">

                    <div class="form-group full-width">
                        <label for="address">
                            House / Street Address
                            <span class="required-mark">*</span>
                        </label>

                        <input type="text"
                               id="address"
                               name="address"
                               value="<%= safe(address) %>"
                               maxlength="500"
                               autocomplete="street-address"
                               required
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                    <div class="form-group full-width">
                        <label for="landmark">Landmark</label>

                        <input type="text"
                               id="landmark"
                               name="landmark"
                               value="<%= safe(landmark) %>"
                               maxlength="150"
                               placeholder="Nearby landmark"
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                    <div class="form-group">
                        <label for="city">
                            City <span class="required-mark">*</span>
                        </label>

                        <input type="text"
                               id="city"
                               name="city"
                               value="<%= safe(city) %>"
                               maxlength="100"
                               autocomplete="address-level2"
                               required
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                    <div class="form-group">
                        <label for="state">
                            State <span class="required-mark">*</span>
                        </label>

                        <input type="text"
                               id="state"
                               name="state"
                               value="<%= safe(state) %>"
                               maxlength="100"
                               autocomplete="address-level1"
                               required
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                    <div class="form-group">
                        <label for="pincode">
                            PIN Code <span class="required-mark">*</span>
                        </label>

                        <input type="text"
                               id="pincode"
                               name="pincode"
                               value="<%= safe(pincode) %>"
                               maxlength="10"
                               autocomplete="postal-code"
                               required
                               <%= hasError ? "" : "disabled" %>>
                    </div>

                    <div class="form-group full-width"
                         id="deliveryInstructionsGroup">
                        <label for="deliveryInstructions">
                            Delivery Instructions
                        </label>

                        <textarea id="deliveryInstructions"
                                  name="deliveryInstructions"
                                  maxlength="500"
                                  placeholder="Instructions for your delivery partner"
                                  <%= hasError ? "" : "disabled" %>><%= safe(instructions) %></textarea>
                    </div>

                </div>

                <!-- FORM FOOTER -->
                <div class="form-footer">

                    <div class="form-footer-note">
                        Fields marked with
                        <span class="required-mark">*</span>
                        are required. Your account role and password
                        are not changed through this form.
                    </div>

                    <div class="form-actions">

                        <button type="button"
                                class="edit-button secondary"
                                id="cancelButton">
                            Cancel
                        </button>

                        <button type="submit"
                                class="edit-button"
                                id="saveButton">
                            Save Changes
                        </button>

                    </div>

                </div>

            </section>

        </form>

    </main>

</div>

<script>
(function () {
    "use strict";

    const form = document.getElementById("profileForm");
    const editButton = document.getElementById("editButton");
    const cancelButton = document.getElementById("cancelButton");
    const statusText = document.getElementById("statusText");

    const fields = form.querySelectorAll("input[name], textarea[name]");

    function setEditing(editing) {
        fields.forEach(function (field) {
            field.disabled = !editing;
        });

        form.classList.toggle("editing", editing);

        statusText.textContent = editing
            ? "Editing details"
            : "View only";

        if (editing) {
            const firstField = document.getElementById("username");

            if (firstField) {
                firstField.focus();
            }
        }
    }

    editButton.addEventListener("click", function () {
        setEditing(true);
    });

    cancelButton.addEventListener("click", function () {
        // Restore the original values rendered by the server.
        form.reset();
        setEditing(false);
    });

    // Restrict phone fields to numeric characters and at most 10 digits.
    ["phone", "alternatePhone"].forEach(function (fieldId) {
        const field = document.getElementById(fieldId);

        field.addEventListener("input", function () {
            field.value = field.value.replace(/\D/g, "").slice(0, 10);
        });
    });

    // Prevent selecting a future date of birth.
    const dobField = document.getElementById("dob");
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, "0");
    const day = String(today.getDate()).padStart(2, "0");

    dobField.max = year + "-" + month + "-" + day;

    // On validation/database errors, keep the form in editing mode.
    setEditing(<%= hasError ? "true" : "false" %>);

    // Sidebar section links enable editing before moving to the fields.
    document.querySelectorAll(
        '.side-link[href="#basicDetails"],' +
        '.side-link[href="#deliveryAddress"],' +
        '.side-link[href="#deliveryInstructions"]'
    ).forEach(function (link) {
        link.addEventListener("click", function () {
            setEditing(true);
        });
    });

})();
</script>

</body>
</html>
