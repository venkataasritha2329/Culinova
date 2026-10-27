
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<%
    String ctx = request.getContextPath();

    String error = request.getParameter("error");

    if (error == null || error.isEmpty()) {
        if (request.getParameter("mismatch") != null) {
            error = "mismatch";
        } else if (request.getParameter("invalid") != null) {
            error = "invalid";
        } else if (request.getParameter("failed") != null) {
            error = "failed";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Culinova - Create Password</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap"
          rel="stylesheet">

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
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            font-family: 'DM Sans', sans-serif;
            background: var(--page-bg);
            color: var(--text);
        }

        .page-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            min-height: 100vh;
        }

        /* LEFT SIDE */

        .brand-panel {
            position: relative;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 42px 50px;
            color: #ffffff;
            overflow: hidden;

            background:
                linear-gradient(
                    180deg,
                    rgba(25, 17, 11, 0.35),
                    rgba(25, 17, 11, 0.78)
                ),
                url("https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1800&q=85");

            background-size: cover;
            background-position: center;
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 12px;
            position: relative;
            z-index: 1;
        }

        .brand-logo img {
            width: 48px;
            height: 48px;
            object-fit: contain;
            border-radius: 12px;
        }

        .brand-name {
            font-family: 'Playfair Display', serif;
            font-size: 30px;
            font-weight: 700;
            letter-spacing: 0.3px;
        }

        .brand-content {
            position: relative;
            z-index: 1;
            max-width: 490px;
            padding-bottom: 35px;
        }

        .brand-content h1 {
            font-family: 'Playfair Display', serif;
            font-size: clamp(42px, 4.2vw, 64px);
            font-weight: 600;
            line-height: 1.12;
            margin-bottom: 20px;
        }

        .brand-content p {
            max-width: 420px;
            color: rgba(255, 255, 255, 0.87);
            font-size: 15px;
            line-height: 1.9;
        }

        .brand-footer {
            position: relative;
            z-index: 1;
            color: rgba(255, 255, 255, 0.72);
            font-size: 12px;
        }

        /* RIGHT SIDE */

        .reset-panel {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 45px 35px;
            background: var(--page-bg);
        }

        .reset-card {
            width: 100%;
            max-width: 460px;
            padding: 42px 38px;
            border-radius: 28px;

            background: var(--page-bg);

            box-shadow:
                14px 14px 35px var(--shadow-dark),
                -14px -14px 35px var(--shadow-light);
        }

        .form-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--accent-dark);
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 15px;
        }

        .eyebrow-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--accent);
        }

        .reset-card h2 {
            font-family: 'Playfair Display', serif;
            font-size: clamp(30px, 3vw, 38px);
            line-height: 1.2;
            font-weight: 600;
            margin-bottom: 13px;
        }

        .subtitle {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.8;
            margin-bottom: 27px;
        }

        /* MESSAGES */

        .message {
            padding: 13px 15px;
            border-radius: 12px;
            font-size: 12px;
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .error-message {
            color: var(--danger);
            background: #fff0ed;
            border: 1px solid #f5c9c2;
        }

        .success-message {
            color: var(--success);
            background: #edf8f0;
            border: 1px solid #c6e7d0;
        }

        /* FORM */

        .form-group {
            margin-bottom: 21px;
        }

        .form-group label {
            display: block;
            color: var(--text);
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap input {
            display: block;
            width: 100%;
            height: 52px;
            padding: 0 76px 0 17px;

            border: 1px solid transparent;
            border-radius: 14px;
            outline: none;

            background: var(--page-bg);
            color: var(--text);

            font-family: 'DM Sans', sans-serif;
            font-size: 13px;

            box-shadow:
                inset 5px 5px 10px var(--shadow-dark),
                inset -5px -5px 10px var(--shadow-light);

            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .input-wrap input::placeholder {
            color: #a69688;
        }

        .input-wrap input:focus {
            border-color: rgba(184, 117, 66, 0.65);

            box-shadow:
                inset 3px 3px 7px var(--shadow-dark),
                inset -3px -3px 7px var(--shadow-light),
                0 0 0 3px rgba(184, 117, 66, 0.10);
        }

        .password-toggle {
            position: absolute;
            top: 50%;
            right: 14px;
            transform: translateY(-50%);

            border: none;
            background: transparent;
            color: var(--accent-dark);

            font-family: 'DM Sans', sans-serif;
            font-size: 11px;
            font-weight: 700;

            cursor: pointer;
            padding: 6px;
        }

        .password-toggle:hover {
            color: var(--accent);
        }

        /* PASSWORD REQUIREMENTS */

        .password-requirements {
            margin: -3px 0 23px;
            padding: 15px 17px;
            border-radius: 15px;

            background: var(--page-bg);

            box-shadow:
                inset 4px 4px 8px var(--shadow-dark),
                inset -4px -4px 8px var(--shadow-light);
        }

        .password-requirements p {
            color: var(--accent-dark);
            font-size: 11px;
            font-weight: 700;
            margin-bottom: 7px;
        }

        .password-requirements ul {
            padding-left: 17px;
            color: var(--muted);
            font-size: 11px;
            line-height: 1.9;
        }

        /* SUBMIT BUTTON */

        .submit-button {
            width: 100%;
            min-height: 53px;
            margin-top: 2px;
            border: none;
            border-radius: 15px;

            background: var(--accent);
            color: #ffffff;

            font-family: 'DM Sans', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 0.3px;

            cursor: pointer;

            box-shadow:
                6px 6px 13px rgba(137, 81, 46, 0.20),
                -4px -4px 10px rgba(255, 255, 255, 0.75);

            transition: background 0.2s, transform 0.2s,
                        box-shadow 0.2s;
        }

        .submit-button:hover {
            background: var(--accent-dark);
            transform: translateY(-1px);

            box-shadow:
                8px 8px 16px rgba(137, 81, 46, 0.22),
                -4px -4px 10px rgba(255, 255, 255, 0.75);
        }

        .submit-button:active {
            transform: translateY(0);
        }

        /* BACK LINK AND SECURITY NOTE */

        .back-link {
            display: block;
            width: fit-content;
            margin: 23px auto 0;

            color: var(--accent-dark);
            text-decoration: none;
            font-size: 12px;
            font-weight: 700;

            transition: color 0.2s;
        }

        .back-link:hover {
            color: var(--accent);
        }

        .security-note {
            display: flex;
            align-items: flex-start;
            justify-content: center;
            gap: 8px;

            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid rgba(128, 110, 96, 0.18);

            color: var(--muted);
            font-size: 10px;
            line-height: 1.7;
            text-align: center;
        }

        .security-icon {
            flex-shrink: 0;
            font-size: 13px;
        }

        .password-toggle:focus-visible,
        .submit-button:focus-visible,
        .back-link:focus-visible {
            outline: 2px solid var(--accent);
            outline-offset: 4px;
        }

        /* RESPONSIVE DESIGN */

        @media (max-width: 900px) {
            .page-container {
                grid-template-columns: 0.85fr 1fr;
            }

            .brand-panel {
                padding: 32px;
            }

            .brand-name {
                font-size: 25px;
            }

            .reset-panel {
                padding: 30px 24px;
            }

            .reset-card {
                padding: 34px 27px;
            }
        }

        @media (max-width: 680px) {
            .page-container {
                grid-template-columns: 1fr;
            }

            .brand-panel {
                min-height: 300px;
                padding: 25px 26px;
            }

            .brand-logo img {
                width: 40px;
                height: 40px;
            }

            .brand-name {
                font-size: 25px;
            }

            .brand-content {
                padding-top: 50px;
                padding-bottom: 12px;
            }

            .brand-content h1 {
                font-size: 38px;
                margin-bottom: 12px;
            }

            .brand-content p {
                font-size: 13px;
                line-height: 1.7;
            }

            .brand-footer {
                display: none;
            }

            .reset-panel {
                min-height: auto;
                padding: 38px 20px 45px;
            }

            .reset-card {
                max-width: 460px;
                padding: 30px 24px;
                border-radius: 23px;
            }

            .reset-card h2 {
                font-size: 32px;
            }
        }

        @media (max-width: 380px) {
            .reset-card {
                padding: 26px 19px;
            }

            .input-wrap input {
                height: 49px;
            }
        }
    </style>
</head>

<body>

<div class="page-container">

    <!-- LEFT SIDE: BRANDING AND BACKGROUND IMAGE -->

    <aside class="brand-panel">

        <div class="brand-logo">
            <img src="<%= ctx %>/images/logo1.png"
                 alt="Culinova logo"
                 onerror="this.style.display='none';">

            <span class="brand-name">Culinova</span>
        </div>

        <div class="brand-content">
            <h1>Make it<br>secure.</h1>

            <p>
                A great account deserves a strong password.
                Create a secure password to protect your Culinova
                account and continue enjoying your favourite food.
            </p>
        </div>

        <div class="brand-footer">
            © Culinova. Made with care for your food journey.
        </div>

    </aside>


    <!-- RIGHT SIDE: CREATE PASSWORD FORM -->

    <main class="reset-panel">

        <section class="reset-card">

            <p class="form-eyebrow">
                <span class="eyebrow-dot"></span>
                Account Security
            </p>

            <h2>Update Password</h2>

            <p class="subtitle">
                Set a new password for your Culinova account.
                Enter your password below and confirm it to
                complete the password update.
            </p>


            <% if ("mismatch".equals(error)) { %>

                <div class="message error-message" role="alert">
                    Your passwords do not match. Please enter the
                    same password in both fields.
                </div>

            <% } else if ("invalid".equals(error)) { %>

                <div class="message error-message" role="alert">
                    Please enter a valid password. Use at least
                    8 characters.
                </div>

            <% } else if ("failed".equals(error)) { %>

                <div class="message error-message" role="alert">
                    Your password could not be updated.
                    Please try again.
                </div>

            <% } else if ("expired".equals(error)) { %>

                <div class="message error-message" role="alert">
                    Your password-reset session has expired.
                    Please request a new verification code.
                </div>

            <% } else if ("success".equals(request.getParameter("status"))) { %>

                <div class="message success-message" role="status">
                    Your password has been updated successfully.
                    You can now log in using your new password.
                </div>

            <% } %>


            <form action="<%= ctx %>/create-password"
                  method="post"
                  id="createPasswordForm">

                <div class="form-group">

                    <label for="password">New Password</label>

                    <div class="input-wrap">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            placeholder="Enter your new password"
                            minlength="8"
                            maxlength="72"
                            autocomplete="new-password"
                            required
                            aria-describedby="passwordRequirements">

                        <button
                            type="button"
                            class="password-toggle"
                            data-target="password"
                            aria-label="Show new password"
                            aria-pressed="false">
                            Show
                        </button>
                    </div>

                </div>


                <div class="password-requirements"
                     id="passwordRequirements">

                    <p>Password requirements</p>

                    <ul>
                        <li>Use at least 8 characters.</li>
                        <li>Choose a strong, unique password.</li>
                        <li>Avoid sharing your password with anyone.</li>
                    </ul>

                </div>


                <div class="form-group">

                    <label for="confirmPassword">
                        Confirm New Password
                    </label>

                    <div class="input-wrap">
                        <input
                            type="password"
                            id="confirmPassword"
                            name="confirmPassword"
                            placeholder="Re-enter your new password"
                            minlength="8"
                            maxlength="72"
                            autocomplete="new-password"
                            required>

                        <button
                            type="button"
                            class="password-toggle"
                            data-target="confirmPassword"
                            aria-label="Show confirm password"
                            aria-pressed="false">
                            Show
                        </button>
                    </div>

                </div>


                <button type="submit" class="submit-button">
                    Update Password
                </button>

            </form>


            <a class="back-link" href="<%= ctx %>/login">
                &#8592; Back to Login
            </a>


            <p class="security-note">
                <span class="security-icon" aria-hidden="true">
                    &#128274;
                </span>

                <span>
                    Your password is an important part of protecting
                    your Culinova account. Never share it with others.
                </span>
            </p>

        </section>

    </main>

</div>


<script>
    "use strict";

    // Show or hide the password fields.
    document.querySelectorAll(".password-toggle").forEach(function (button) {

        button.addEventListener("click", function () {

            const input = document.getElementById(this.dataset.target);
            const isVisible = input.type === "text";

            input.type = isVisible ? "password" : "text";
            this.textContent = isVisible ? "Show" : "Hide";

            this.setAttribute(
                "aria-label",
                isVisible ? "Show password" : "Hide password"
            );

            this.setAttribute(
                "aria-pressed",
                String(!isVisible)
            );

        });

    });


    // Validate the password fields before submitting the form.
    const passwordForm = document.getElementById("createPasswordForm");

    passwordForm.addEventListener("submit", function (event) {

        const password = document.getElementById("password").value;
        const confirmPassword =
            document.getElementById("confirmPassword").value;

        if (password.length < 8) {
            event.preventDefault();

            alert("Password must contain at least 8 characters.");

            document.getElementById("password").focus();
            return;
        }

        if (password !== confirmPassword) {
            event.preventDefault();

            alert("Passwords do not match. Please try again.");

            document.getElementById("confirmPassword").focus();
        }

    });
</script>

</body>
</html>
