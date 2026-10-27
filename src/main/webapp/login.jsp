
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    String contextPath = request.getContextPath();

    String error = request.getParameter("error");
    String message = request.getParameter("message");
    String savedIdentifier = request.getParameter("identifier");

    if (savedIdentifier == null) {
        savedIdentifier = "";
    }

    String safeIdentifier = savedIdentifier
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Culinova | Login</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap"
      rel="stylesheet">

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    --page-bg: #f7f2eb;
    --card-bg: #f7f2eb;
    --text: #302720;
    --muted: #88796e;
    --accent: #b85f3b;
    --border: #e6dbce;
}

body {
    min-height: 100vh;
    background: var(--page-bg);
    color: var(--text);
    font-family: 'DM Sans', sans-serif;
}

/* NAVBAR */

.navbar {
    height: 76px;
    width: 100%;
    padding: 0 6%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #f7f2eb;
    border-bottom: 1px solid rgba(90, 65, 45, 0.08);
}

.brand {
    text-decoration: none;
    color: var(--text);
    font-family: 'Playfair Display', serif;
    font-size: 29px;
    font-weight: 700;
    letter-spacing: -1px;
}

.brand span {
    color: var(--accent);
}

.explore-link {
    text-decoration: none;
    color: var(--text);
    font-size: 13px;
    font-weight: 600;
    padding: 12px 19px;
    border-radius: 30px;
    background: #f7f2eb;
    box-shadow: 5px 5px 12px #e4dacf,
                -5px -5px 12px #ffffff;
    transition: 0.25s;
}

.explore-link:hover {
    color: var(--accent);
    transform: translateY(-2px);
}

/* MAIN LAYOUT */

.page-layout {
    display: grid;
    grid-template-columns: 1fr 1fr;
    min-height: calc(100vh - 76px);
}

/* LEFT IMAGE */

.welcome {
    position: relative;
    min-height: calc(100vh - 76px);
    display: flex;
    align-items: flex-end;
    overflow: hidden;
    background-image:
        linear-gradient(
            to top,
            rgba(23, 16, 12, 0.88) 0%,
            rgba(23, 16, 12, 0.57) 38%,
            rgba(23, 16, 12, 0.08) 100%
        ),
        url("https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1600&q=85");
    background-size: cover;
    background-position: center;
}

.welcome-content {
    position: relative;
    z-index: 1;
    width: 100%;
    padding: clamp(28px, 5vw, 66px);
    color: #fffaf4;
}

.eyebrow {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 22px;
    color: #f0c2a5;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 3px;
    text-transform: uppercase;
}

.eyebrow::before {
    content: "";
    width: 28px;
    height: 1px;
    background: #d98b65;
}

.welcome h1 {
    max-width: 520px;
    font-family: 'Playfair Display', serif;
    font-size: clamp(34px, 4.1vw, 58px);
    font-weight: 600;
    line-height: 1.17;
    letter-spacing: -1.5px;
}

.welcome h1 span {
    color: #efb28e;
    font-style: italic;
}

.welcome-text {
    max-width: 390px;
    margin-top: 22px;
    color: rgba(255, 250, 244, 0.85);
    font-size: 14px;
    line-height: 1.9;
}

.decorative-line {
    width: 65px;
    height: 3px;
    margin: 28px 0 22px;
    border-radius: 5px;
    background: #d17a54;
}

.welcome-note {
    display: flex;
    align-items: center;
    gap: 13px;
    color: rgba(255, 250, 244, 0.85);
    font-size: 12px;
    line-height: 1.8;
}

.welcome-note strong {
    color: #fffaf4;
    font-size: 13px;
}

.note-icon {
    width: 42px;
    height: 42px;
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid rgba(255, 255, 255, 0.35);
    border-radius: 50%;
    color: #efb28e;
    font-size: 20px;
}

/* LOGIN SECTION */

.login-panel {
    min-width: 0;
    padding: 45px 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--page-bg);
}

.login-card {
    width: 100%;
    max-width: 440px;
    padding: clamp(26px, 4vw, 42px);
    border-radius: 25px;
    background: var(--card-bg);
    box-shadow: 12px 12px 28px #e4dacf,
                -12px -12px 28px #ffffff;
}

.card-label {
    margin-bottom: 13px;
    color: var(--accent);
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 2.3px;
    text-transform: uppercase;
}

.login-card h2 {
    font-family: 'Playfair Display', serif;
    font-size: clamp(32px, 3vw, 42px);
    font-weight: 600;
    letter-spacing: -1px;
}

.subtitle {
    margin-top: 12px;
    margin-bottom: 30px;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.8;
}

/* ALERTS */

.alert {
    margin-bottom: 20px;
    padding: 12px 14px;
    border-radius: 10px;
    font-size: 12px;
    line-height: 1.6;
}

.error-alert {
    color: #a22d2d;
    background: #f8e4df;
}

.success-alert {
    color: #276b45;
    background: #e2f1e5;
}

/* FORM */

.form-group {
    margin-bottom: 21px;
}

.form-group label {
    display: block;
    margin-bottom: 10px;
    color: #493b31;
    font-size: 12px;
    font-weight: 700;
}

.input-wrap {
    position: relative;
}

.form-group input {
    width: 100%;
    height: 51px;
    padding: 0 15px;
    border: 1px solid transparent;
    outline: none;
    border-radius: 12px;
    background: var(--card-bg);
    color: var(--text);
    font-family: 'DM Sans', sans-serif;
    font-size: 13px;
    box-shadow: inset 5px 5px 10px #e5dbd0,
                inset -5px -5px 10px #ffffff;
    transition: border 0.2s;
}

.form-group input:focus {
    border-color: #c78363;
}

.form-group input::placeholder {
    color: #aa9b8e;
}

.password-input {
    padding-right: 67px !important;
}

.toggle-password {
    position: absolute;
    top: 50%;
    right: 14px;
    transform: translateY(-50%);
    border: none;
    background: transparent;
    color: var(--accent);
    font-family: inherit;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
}

.form-options {
    display: flex;
    justify-content: flex-end;
    margin-top: -5px;
    margin-bottom: 25px;
}

.forgot-link {
    color: var(--accent);
    font-size: 12px;
    font-weight: 600;
    text-decoration: none;
}

.forgot-link:hover,
.signup-link:hover {
    text-decoration: underline;
}

/* SIGN-IN BUTTON */

.login-button {
    width: 100%;
    min-height: 51px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    border: none;
    border-radius: 12px;
    background: var(--accent);
    color: #fffaf5;
    font-family: 'DM Sans', sans-serif;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 0 8px 17px rgba(184, 95, 59, 0.23);
    transition: 0.25s;
}

.login-button:hover {
    background: #a64f2e;
    transform: translateY(-2px);
    box-shadow: 0 11px 20px rgba(184, 95, 59, 0.3);
}

.login-button span {
    font-size: 17px;
}

/* GOOGLE BUTTON */

.google-login-button {
    width: 100%;
    min-height: 50px;
    margin-top: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    border: 1px solid #e1d8ce;
    border-radius: 12px;
    background: #fffdf9;
    color: #302720;
    font-family: 'DM Sans', sans-serif;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    cursor: pointer;
    transition: 0.25s;
}

.google-login-button:hover {
    background: #ffffff;
    border-color: #b85f3b;
    transform: translateY(-1px);
}

.google-logo {
    width: 19px;
    height: 19px;
    object-fit: contain;
}

/* SIGN-UP */

.signup-divider {
    display: flex;
    align-items: center;
    gap: 14px;
    margin: 27px 0 20px;
    color: #a29487;
    font-size: 9px;
    font-weight: 700;
    letter-spacing: 1.5px;
}

.signup-divider::before,
.signup-divider::after {
    content: "";
    flex: 1;
    height: 1px;
    background: var(--border);
}

.signup-text {
    color: var(--muted);
    text-align: center;
    font-size: 12px;
    line-height: 1.8;
}

.signup-link {
    color: var(--accent);
    font-weight: 700;
    text-decoration: none;
}

/* RESPONSIVE */

@media (max-width: 900px) {
    .page-layout {
        grid-template-columns: 0.9fr 1.1fr;
    }

    .welcome-content {
        padding: 30px;
    }

    .welcome h1 {
        font-size: clamp(30px, 4vw, 42px);
    }

    .login-panel {
        padding: 30px 22px;
    }

    .login-card {
        padding: 28px 24px;
    }
}

@media (max-width: 700px) {
    .navbar {
        height: 68px;
        padding: 0 20px;
    }

    .brand {
        font-size: 25px;
    }

    .explore-link {
        padding: 10px 13px;
        font-size: 11px;
    }

    .page-layout {
        grid-template-columns: 1fr;
    }

    .welcome {
        min-height: 390px;
        background-position: center 55%;
    }

    .welcome-content {
        padding: 30px 25px;
    }

    .welcome h1 {
        font-size: clamp(35px, 9vw, 48px);
    }

    .welcome-text {
        margin-top: 15px;
        font-size: 13px;
    }

    .decorative-line {
        margin: 20px 0 15px;
    }

    .login-panel {
        padding: 35px 20px 45px;
    }

    .login-card {
        max-width: 480px;
        padding: 30px 24px;
    }
}

@media (max-width: 360px) {
    .welcome {
        min-height: 350px;
    }

    .welcome-content {
        padding: 24px 20px;
    }

    .welcome h1 {
        font-size: 32px;
    }

    .login-card {
        padding: 25px 19px;
    }
}
</style>
</head>

<body>

<!-- NAVBAR -->


<main class="page-layout">

    <!-- LEFT: IMAGE AND WELCOME TEXT -->
    <section class="welcome">
        <div class="welcome-content">

            <div class="eyebrow">A seat at our table</div>

            <h1>
                Every craving.<br>
                Every occasion.<br>
                <span>One lovely table.</span>
            </h1>

            <p class="welcome-text">
                Great food brings people together.
                Let Culinova bring a little restaurant magic
                straight to your doorstep.
            </p>

            <div class="decorative-line"></div>

            <div class="welcome-note">
                <div class="note-icon">&hearts;</div>
                <div>
                    <strong>Something special awaits.</strong><br>
                    Discover flavours from places you'll love.
                </div>
            </div>

        </div>
    </section>

    <!-- RIGHT: LOGIN FORM -->
    <section class="login-panel">
        <div class="login-card">

            <div class="card-label">Welcome to Culinova</div>

            <h2>Sign in<span style="color:#b85f3b;">.</span></h2>

            <p class="subtitle">
                Enter your email or username and password
                to continue your food journey.
            </p>

            <% if ("invalid".equals(error)) { %>
                <div class="alert error-alert">
                    Invalid email, username, or password.
                    Please try again.
                </div>
            <% } else if ("empty".equals(error)) { %>
                <div class="alert error-alert">
                    Please enter your email or username and password.
                </div>
            <% } else if ("true".equals(error)) { %>
                <div class="alert error-alert">
                    Something went wrong. Please try again.
                </div>
            <% } else if ("loginRequired".equals(error)) { %>
                <div class="alert error-alert">
                    Please sign in to continue.
                </div>
            <% } else if ("google".equals(error)) { %>
                <div class="alert error-alert">
                    Google sign-in failed. Please try again.
                </div>
            <% } else if ("google_account_not_found".equals(error)) { %>
                <div class="alert error-alert">
                    No Culinova account is registered with that Google email.
                    Please create an account first.
                </div>
            <% } %>

            <% if ("registered".equals(message)) { %>
                <div class="alert success-alert">
                    Registration successful! Please sign in.
                </div>
            <% } else if ("passwordReset".equals(message)) { %>
                <div class="alert success-alert">
                    Your password has been reset. Please sign in.
                </div>
            <% } %>

            <form action="<%= contextPath %>/login" method="post">

                <div class="form-group">
                    <label for="identifier">Email or username</label>

                    <div class="input-wrap">
                        <input
                            type="text"
                            id="identifier"
                            name="identifier"
                            placeholder="Enter your email or username"
                            value="<%= safeIdentifier %>"
                            autocomplete="username"
                            required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>

                    <div class="input-wrap">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            class="password-input"
                            placeholder="Enter your password"
                            autocomplete="current-password"
                            required>

                        <button
                            type="button"
                            class="toggle-password"
                            id="togglePassword">Show</button>
                    </div>
                </div>

                <div class="form-options">
                    <a href="<%= contextPath %>/forgot-password"
                       class="forgot-link">Forgot password?</a>
                </div>

                <button type="submit" class="login-button">
                    Sign in to your account <span>&rarr;</span>
                </button>

                <!-- Opens Google sign-in in a separate popup -->
                <button type="button"
                        class="google-login-button"
                        id="googleLoginButton">
                    <img
                        src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg"
                        alt="Google"
                        class="google-logo">
                    Sign in with Google
                </button>

            </form>

            <div class="signup-divider">NEW TO CULINOVA?</div>

            <p class="signup-text">
                Don't have an account?
                <a href="<%= contextPath %>/signup"
                   class="signup-link">Create an account</a>
            </p>

        </div>
    </section>

</main>

<script>
document.addEventListener("DOMContentLoaded", function () {

    // Show or hide the password
    const password = document.getElementById("password");
    const togglePassword = document.getElementById("togglePassword");

    togglePassword.addEventListener("click", function () {
        if (password.type === "password") {
            password.type = "text";
            togglePassword.textContent = "Hide";
        } else {
            password.type = "password";
            togglePassword.textContent = "Show";
        }
    });

    // Open Google sign-in in a popup instead of the current tab
    const googleLoginButton =
        document.getElementById("googleLoginButton");

    googleLoginButton.addEventListener("click", function () {

        const width = 500;
        const height = 600;

        const left = Math.max(
            0,
            Math.round((screen.width - width) / 2)
        );

        const top = Math.max(
            0,
            Math.round((screen.height - height) / 2)
        );

        const popup = window.open(
            "<%= contextPath %>/google-login",
            "CulinovaGoogleLogin",
            "width=" + width +
            ",height=" + height +
            ",left=" + left +
            ",top=" + top +
            ",resizable=yes,scrollbars=yes"
        );

        if (!popup) {
            alert("Your browser blocked the Google sign-in popup. Please allow popups for localhost and try again.");
        } else {
            popup.focus();
        }
    });

});
</script>

</body>
</html>
