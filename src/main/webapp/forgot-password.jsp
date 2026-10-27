
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String contextPath = request.getContextPath();
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
    String email = request.getParameter("email");
    if (email == null) {
        email = "";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Culinova | Forgot Password</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap" rel="stylesheet">

<style>
:root {
    --page-bg: #f5eee5;
    --text: #352319;
    --muted: #806e60;
    --accent: #b87542;
    --accent-dark: #89512e;
    --shadow-light: #ffffff;
    --shadow-dark: #dfd3c6;
    --danger: #b42318;
    --success: #217346;
}

* {
    box-sizing: border-box;
}

html,
body {
    width: 100%;
    min-height: 100%;
    margin: 0;
    padding: 0;
}

body {
    min-height: 100vh;
    min-height: 100dvh;
    overflow-x: hidden;
    background: var(--page-bg);
    color: var(--text);
    font-family: 'DM Sans', sans-serif;
}

.page-layout {
    display: grid;
    grid-template-columns: 1fr 1fr;
    width: 100%;
    min-height: 100vh;
    min-height: 100dvh;
}

/* LEFT IMAGE */

.welcome {
    position: relative;
    display: flex;
    align-items: flex-end;
    min-width: 0;
    min-height: 100vh;
    min-height: 100dvh;
    padding: 55px;
    overflow: hidden;
    color: #fff;
    background:
        linear-gradient(
            180deg,
            rgba(25, 16, 10, 0.12) 10%,
            rgba(25, 16, 10, 0.80) 100%
        ),
        url("https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1800&q=85")
        center / cover no-repeat;
}

.brand {
    position: absolute;
    top: 38px;
    left: 42px;
    display: flex;
    align-items: center;
    gap: 12px;
    color: #fff;
    font-family: 'Playfair Display', serif;
    font-size: 29px;
    font-weight: 700;
}

.brand-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 43px;
    height: 43px;
    border: 1px solid rgba(255,255,255,0.45);
    border-radius: 14px;
    background: rgba(255,255,255,0.12);
    font-family: 'DM Sans', sans-serif;
    font-size: 23px;
    backdrop-filter: blur(8px);
}

.welcome-content {
    max-width: 520px;
}

.eyebrow {
    margin: 0 0 15px;
    color: #f4c79c;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 3px;
    text-transform: uppercase;
}

.welcome h1 {
    margin: 0 0 18px;
    font-family: 'Playfair Display', serif;
    font-size: clamp(38px, 4.2vw, 64px);
    font-weight: 600;
    line-height: 1.12;
}

.welcome p {
    max-width: 440px;
    margin: 0;
    color: rgba(255,255,255,0.85);
    font-size: 15px;
    line-height: 1.9;
}

/* RIGHT FORM */

.reset-panel {
    display: flex;
    align-items: center;
    justify-content: center;
    min-width: 0;
    min-height: 100vh;
    min-height: 100dvh;
    padding: 45px 28px;
    background: var(--page-bg);
}

.reset-card {
    width: 100%;
    max-width: 430px;
    padding: 42px 38px;
    border: 1px solid rgba(255,255,255,0.75);
    border-radius: 28px;
    background: var(--page-bg);
    box-shadow:
        14px 14px 35px var(--shadow-dark),
        -14px -14px 35px var(--shadow-light);
}

.form-eyebrow {
    margin: 0 0 10px;
    color: var(--accent-dark);
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 2.5px;
    text-transform: uppercase;
}

.reset-card h2 {
    margin: 0 0 12px;
    font-family: 'Playfair Display', serif;
    font-size: 36px;
    font-weight: 600;
    line-height: 1.2;
}

.subtitle {
    margin: 0 0 28px;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.8;
}

.status-message {
    margin: 0 0 20px;
    padding: 12px 14px;
    border-radius: 12px;
    font-size: 12px;
    line-height: 1.6;
    overflow-wrap: anywhere;
}

.status-error {
    color: var(--danger);
    background: #f9e7e3;
    border: 1px solid #f0c9c1;
}

.status-success {
    color: var(--success);
    background: #e6f3e9;
    border: 1px solid #c3e4cc;
}

.form-group {
    margin-bottom: 22px;
}

.form-group label {
    display: block;
    margin-bottom: 9px;
    font-size: 12px;
    font-weight: 700;
}

.form-group input {
    display: block;
    width: 100%;
    height: 52px;
    padding: 0 15px;
    border: 1px solid transparent;
    border-radius: 14px;
    outline: none;
    background: var(--page-bg);
    color: var(--text);
    font-family: inherit;
    font-size: 13px;
    box-shadow:
        inset 5px 5px 10px var(--shadow-dark),
        inset -5px -5px 10px var(--shadow-light);
    transition: box-shadow 0.2s, border-color 0.2s;
}

.form-group input:focus {
    border-color: rgba(184, 117, 66, 0.6);
    box-shadow:
        inset 3px 3px 6px var(--shadow-dark),
        inset -3px -3px 6px var(--shadow-light),
        0 0 0 3px rgba(184, 117, 66, 0.10);
}

.form-group input::placeholder {
    color: #a59688;
}

.submit-button {
    width: 100%;
    min-height: 52px;
    padding: 13px 18px;
    border: none;
    border-radius: 14px;
    background: linear-gradient(135deg, #c98c59, #a96636);
    color: #fff;
    font-family: inherit;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 0 8px 18px rgba(169, 102, 54, 0.20);
    transition: transform 0.2s, box-shadow 0.2s;
}

.submit-button:hover {
    transform: translateY(-2px);
    box-shadow: 0 11px 22px rgba(169, 102, 54, 0.28);
}

.submit-button:active {
    transform: translateY(0);
}

.back-link {
    display: block;
    margin-top: 25px;
    color: var(--accent-dark);
    font-size: 12px;
    font-weight: 700;
    text-align: center;
    text-decoration: none;
}

.back-link:hover {
    text-decoration: underline;
}

.security-note {
    margin: 23px 0 0;
    color: var(--muted);
    font-size: 11px;
    line-height: 1.7;
    text-align: center;
}

/* RESPONSIVE */

@media (max-width: 900px) {
    .welcome {
        padding: 38px;
    }

    .brand {
        top: 28px;
        left: 28px;
        font-size: 25px;
    }

    .reset-panel {
        padding: 30px 22px;
    }

    .reset-card {
        padding: 34px 27px;
    }

    .reset-card h2 {
        font-size: 31px;
    }
}

@media (max-width: 650px) {
    .page-layout {
        grid-template-columns: 1fr;
        min-height: 100vh;
        min-height: 100dvh;
    }

    .welcome {
        min-height: 280px;
        padding: 35px 25px;
        background-position: center;
    }

    .brand {
        top: 20px;
        left: 22px;
        font-size: 23px;
    }

    .brand-icon {
        width: 38px;
        height: 38px;
        font-size: 20px;
    }

    .welcome-content {
        margin-top: 85px;
    }

    .welcome h1 {
        font-size: 35px;
    }

    .welcome p {
        font-size: 13px;
        line-height: 1.7;
    }

    .reset-panel {
        min-height: auto;
        padding: 35px 20px 45px;
    }

    .reset-card {
        max-width: 460px;
        padding: 32px 24px;
    }

    .reset-card h2 {
        font-size: 32px;
    }
}

@media (max-width: 360px) {
    .reset-card {
        padding: 27px 18px;
    }

    .reset-card h2 {
        font-size: 29px;
    }
}
</style>
</head>

<body>
<div class="page-layout">

    <section class="welcome">
        <div class="brand">
            <span class="brand-icon">C</span>
            <span>Culinova</span>
        </div>

        <div class="welcome-content">
            <p class="eyebrow">A fresh start</p>
            <h1>Forgot your password?</h1>
            <p>
                No worries. Enter the email address linked to your
                Culinova account and follow the instructions to regain
                access to your account.
            </p>
        </div>
    </section>

    <main class="reset-panel">
        <section class="reset-card">
            <p class="form-eyebrow">Account recovery</p>
            <h2>Reset Password</h2>
            <p class="subtitle">
                Enter your registered email address. If your account is
                registered, we'll send you the next recovery instructions.
            </p>

            <% if ("true".equals(error)) { %>
                <div class="status-message status-error" role="alert">
                    Something went wrong. Please try again.
                </div>
            <% } else if (error != null && !error.isEmpty()) { %>
                <div class="status-message status-error" role="alert">
                    <%= error.replace("&", "&amp;")
                              .replace("<", "&lt;")
                              .replace(">", "&gt;")
                              .replace("\"", "&quot;")
                              .replace("'", "&#39;") %>
                </div>
            <% } %>

            <% if (message != null && !message.isEmpty()) { %>
                <div class="status-message status-success" role="status">
                    <%= message.replace("&", "&amp;")
                               .replace("<", "&lt;")
                               .replace(">", "&gt;")
                               .replace("\"", "&quot;")
                               .replace("'", "&#39;") %>
                </div>
            <% } %>

            <form action="<%= contextPath %>/forgot-password" method="post">
                <div class="form-group">
                    <label for="email">Registered email address</label>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        placeholder="Enter your email address"
                        value="<%= email.replace("&", "&amp;")
                                        .replace("<", "&lt;")
                                        .replace(">", "&gt;")
                                        .replace("\"", "&quot;")
                                        .replace("'", "&#39;") %>"
                        autocomplete="email"
                        maxlength="254"
                        required>
                </div>

                <button type="submit" class="submit-button">
                    Send Reset Instructions
                </button>
            </form>

            <a class="back-link" href="<%= contextPath %>/login">
                &#8592; Back to Login
            </a>

            <p class="security-note">
                For your security, never share your verification code
                or password with anyone.
            </p>
        </section>
    </main>

</div>
</body>
</html>
