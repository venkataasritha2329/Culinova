
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String ctx = request.getContextPath();
    String signupError = (String) request.getAttribute("signupError");
    String registered = request.getParameter("registered");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Culinova | Sign Up</title>

<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600;700&display=swap"
      rel="stylesheet">

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    --bg: #eeeae4;
    --text: #292722;
    --muted: #89847b;
    --accent: #b85f3b;
    --light: #ffffff;
    --dark: #d0ccc6;
}

body {
    min-height: 100vh;
    padding: 35px 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--bg);
    color: var(--text);
    font-family: 'DM Sans', sans-serif;
}

.signup {
    width: 100%;
    max-width: 650px;
    padding: 38px;
    border-radius: 28px;
    background: var(--bg);
    box-shadow: 12px 12px 28px var(--dark),
                -12px -12px 28px var(--light);
}

.brand {
    text-align: center;
    margin-bottom: 30px;
}

.brand h1 {
    font-family: 'Playfair Display', serif;
    font-size: 36px;
}

.brand h1 span {
    color: var(--accent);
}

.brand p {
    margin-top: 6px;
    color: var(--muted);
    font-size: 14px;
}

.message {
    margin-bottom: 20px;
    padding: 12px;
    border-radius: 12px;
    font-size: 13px;
    text-align: center;
    overflow-wrap: anywhere;
}

.error {
    color: #a52c2c;
    background: #f4e0dc;
}

.success {
    color: #27633a;
    background: #deeddf;
}

.form-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px 16px;
}

.field {
    min-width: 0;
}

.field.full {
    grid-column: 1 / -1;
}

.field label {
    display: block;
    margin: 0 0 8px 4px;
    font-size: 13px;
    font-weight: 600;
}

.field input,
.field select,
.field textarea {
    width: 100%;
    min-width: 0;
    border: none;
    outline: none;
    border-radius: 12px;
    background: var(--bg);
    color: var(--text);
    font-family: inherit;
    font-size: 14px;
    box-shadow: inset 5px 5px 9px var(--dark),
                inset -5px -5px 9px var(--light);
    transition: box-shadow 0.2s ease;
}

.field input,
.field select {
    height: 47px;
    padding: 0 13px;
}

.field textarea {
    min-height: 82px;
    padding: 13px;
    resize: vertical;
}

.field input:focus,
.field select:focus,
.field textarea:focus {
    box-shadow: inset 3px 3px 6px var(--dark),
                inset -3px -3px 6px var(--light),
                0 0 0 2px rgba(184, 95, 59, 0.18);
}

.field input::placeholder,
.field textarea::placeholder {
    color: #aaa49b;
}

.password-wrap {
    position: relative;
}

.password-wrap input {
    padding-right: 60px;
}

.toggle-password {
    position: absolute;
    top: 50%;
    right: 12px;
    transform: translateY(-50%);
    border: none;
    background: transparent;
    color: var(--accent);
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
}

.submit-btn {
    width: 100%;
    min-height: 50px;
    margin-top: 25px;
    border: none;
    border-radius: 13px;
    background: var(--accent);
    color: white;
    font-family: inherit;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    box-shadow: 5px 5px 10px #d0b9ad,
                -4px -4px 9px var(--light);
    transition: transform 0.2s ease;
}

.submit-btn:hover {
    transform: translateY(-1px);
}

.login-link {
    margin-top: 23px;
    text-align: center;
    color: var(--muted);
    font-size: 13px;
}

.login-link a {
    color: var(--accent);
    font-weight: 700;
    text-decoration: none;
}

@media (max-width: 560px) {
    .signup {
        padding: 27px 20px;
        border-radius: 22px;
    }

    .form-grid {
        grid-template-columns: 1fr;
    }

    .field.full {
        grid-column: auto;
    }

    .brand h1 {
        font-size: 32px;
    }
}
</style>
</head>

<body>

<main class="signup">

    <header class="brand">
        <h1>Culinova<span>.</span></h1>
        <p>Create your account</p>
    </header>

    <% if (signupError != null) { %>
        <div class="message error" role="alert">
            <%= escapeHtml(signupError) %>
        </div>
    <% } %>

    <% if ("true".equals(registered)) { %>
        <div class="message success" role="status">
            Registration successful. Please log in.
        </div>
    <% } %>

    <form action="<%= ctx %>/signup"
          method="post"
          onsubmit="return validateForm()">

        <div class="form-grid">

            <div class="field">
                <label for="username">Username *</label>
                <input type="text" id="username" name="username"
                       placeholder="Enter username" required
                       maxlength="100" autocomplete="username">
            </div>

            <div class="field">
                <label for="email">Email *</label>
                <input type="email" id="email" name="email"
                       placeholder="Enter email address" required
                       maxlength="150" autocomplete="email">
            </div>

            <div class="field">
                <label for="phone">Phone *</label>
                <input type="tel" id="phone" name="phone"
                       placeholder="10-digit phone number" required
                       pattern="[0-9]{10}" maxlength="10"
                       inputmode="numeric" autocomplete="tel">
            </div>

            <div class="field">
                <label for="alternatePhone">Alternate phone</label>
                <input type="tel" id="alternatePhone"
                       name="alternatePhone"
                       placeholder="Alternate phone number"
                       pattern="[0-9]{10}" maxlength="10"
                       inputmode="numeric">
            </div>

            <div class="field">
                <label for="dob">Date of birth</label>
                <input type="date" id="dob" name="dob">
            </div>

            <div class="field">
                <label for="city">City *</label>
                <input type="text" id="city" name="city"
                       placeholder="Enter city" required maxlength="100">
            </div>

            <div class="field">
                <label for="state">State *</label>
                <input type="text" id="state" name="state"
                       placeholder="Enter state" required maxlength="100">
            </div>

            <div class="field">
                <label for="pincode">Pincode *</label>
                <input type="text" id="pincode" name="pincode"
                       placeholder="6-digit pincode" required
                       pattern="[0-9]{6}" maxlength="6"
                       inputmode="numeric">
            </div>

            <div class="field full">
                <label for="address">Address *</label>
                <textarea id="address" name="address"
                          placeholder="House number, street and area"
                          required maxlength="500"></textarea>
            </div>

            <div class="field full">
                <label for="landmark">Landmark</label>
                <input type="text" id="landmark" name="landmark"
                       placeholder="Nearby landmark" maxlength="200">
            </div>

            <div class="field">
                <label for="password">Password *</label>
                <div class="password-wrap">
                    <input type="password" id="password" name="password"
                           placeholder="Create password" required
                           minlength="8" autocomplete="new-password">
                    <button class="toggle-password" type="button"
                            onclick="togglePassword('password', this)">
                        SHOW
                    </button>
                </div>
            </div>

            <div class="field">
                <label for="confirmPassword">Confirm password *</label>
                <div class="password-wrap">
                    <input type="password" id="confirmPassword"
                           name="confirmPassword"
                           placeholder="Re-enter password" required
                           minlength="8" autocomplete="new-password">
                    <button class="toggle-password" type="button"
                            onclick="togglePassword('confirmPassword', this)">
                        SHOW
                    </button>
                </div>
            </div>

            <div class="field full">
                <label for="deliveryInstructions">
                    Delivery instructions
                </label>
                <textarea id="deliveryInstructions"
                          name="deliveryInstructions"
                          placeholder="Any special delivery instructions?"
                          maxlength="500"></textarea>
            </div>

        </div>

        <button type="submit" class="submit-btn">
            Create Account
        </button>

    </form>

    <p class="login-link">
        Already have an account?
        <a href="<%= ctx %>/login">Log in</a>
    </p>

</main>

<script>
function togglePassword(id, button) {
    const input = document.getElementById(id);
    const visible = input.type === "password";

    input.type = visible ? "text" : "password";
    button.textContent = visible ? "HIDE" : "SHOW";
}

function validateForm() {
    const password = document.getElementById("password").value;
    const confirmPassword =
        document.getElementById("confirmPassword").value;

    if (password !== confirmPassword) {
        alert("Passwords do not match.");
        return false;
    }

    return true;
}
</script>

</body>
</html>

<%!
private String escapeHtml(String value) {
    if (value == null) {
        return "";
    }

    return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
}
%>
