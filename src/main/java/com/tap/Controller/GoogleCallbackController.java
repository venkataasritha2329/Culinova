
package com.tap.Controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.tap.Dao.UserDao;
import com.tap.DaoImpl.UserDaoImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/google-callback")
public class GoogleCallbackController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String REDIRECT_URI =
            "http://localhost:8080/Culinova/google-callback";

    private static final String TOKEN_URL =
            "https://oauth2.googleapis.com/token";

    private static final String TOKEN_INFO_URL =
            "https://oauth2.googleapis.com/tokeninfo?id_token=";

    private UserDao userDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (session == null) {
            response.sendRedirect(contextPath + "/login?error=google");
            return;
        }

        String expectedState =
                (String) session.getAttribute("googleOAuthState");

        String receivedState = request.getParameter("state");
        String code = request.getParameter("code");
        String googleError = request.getParameter("error");

        if (googleError != null) {
            session.removeAttribute("googleOAuthState");
            response.sendRedirect(contextPath + "/login?error=google");
            return;
        }

        if (expectedState == null
                || receivedState == null
                || !expectedState.equals(receivedState)
                || code == null
                || code.isBlank()) {

            session.removeAttribute("googleOAuthState");
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid Google OAuth response.");
            return;
        }

        session.removeAttribute("googleOAuthState");

        // Read credentials from the environment.
        String clientId = "97639880534-3j30st0qd54p002dl40bk2do9c0o3705.apps.googleusercontent.com";
        String clientSecret = "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";
        
//        String clientId = "key";
//        String clientSecret ="value";

        
        
        if (clientId == null || clientId.isBlank()
                || clientSecret == null || clientSecret.isBlank()) {

            log("Google OAuth credentials are missing from Tomcat.");
            response.sendRedirect(contextPath + "/login?error=google");
            return;
        }

        try {
            // Exchange authorization code for tokens.
            String tokenResponse =
                    exchangeCode(code, clientId, clientSecret);

            String idToken =
                    extractJsonString(tokenResponse, "id_token");

            if (idToken == null || idToken.isBlank()) {
                throw new IOException("Google did not return an ID token.");
            }

            // Verify the Google ID token.
            String tokenInfo = verifyIdToken(idToken);

            String audience = extractJsonString(tokenInfo, "aud");
            String issuer = extractJsonString(tokenInfo, "iss");
            String email = extractJsonString(tokenInfo, "email");
            String name = extractJsonString(tokenInfo, "name");
            String emailVerified =
                    extractJsonString(tokenInfo, "email_verified");
            String expiry = extractJsonString(tokenInfo, "exp");

            if (audience == null || issuer == null
                    || email == null || email.isBlank()
                    || emailVerified == null || expiry == null) {
                throw new IOException("Required Google identity data is missing.");
            }

            long expiryTime = Long.parseLong(expiry);

            boolean validIssuer =
                    "accounts.google.com".equals(issuer)
                    || "https://accounts.google.com".equals(issuer);

            if (!clientId.equals(audience)
                    || !validIssuer
                    || !"true".equalsIgnoreCase(emailVerified)
                    || expiryTime <= System.currentTimeMillis() / 1000) {

                throw new IOException(
                        "Google identity token validation failed.");
            }

            // Find the user in the Culinova database.
            User user = userDao.getUserByEmailOrPhone(email);

            if (user == null) {
                response.sendRedirect(
                        contextPath + "/login?error=google_account_not_found");
                return;
            }

            // Establish the same login session as LoginController.
            request.changeSessionId();

            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("role", user.getRole());

            session.setAttribute("googleEmail", email);
            session.setAttribute("googleName", name == null ? "" : name);
            session.setAttribute("loginMethod", "GOOGLE");

            // Redirect according to the user's role.
            String homeUrl = response.encodeURL(
                    contextPath + "/restaurant?view=restaurants"
            );

            response.setContentType("text/html");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Cache-Control", "no-store");

            response.getWriter().println(
                "<!DOCTYPE html>" +
                "<html><head><title>Culinova Login</title></head><body>" +
                "<p>Login successful. Redirecting to Culinova...</p>" +
                "<script>" +
                "const homeUrl = " +
                "'" + homeUrl.replace("\\", "\\\\").replace("'", "\\'") + "';" +
                "if (window.opener && !window.opener.closed) {" +
                "   window.opener.location.replace(homeUrl);" +
                "   window.close();" +
                "} else {" +
                "   window.location.replace(homeUrl);" +
                "}" +
                "</script>" +
                "</body></html>"
            );

        } catch (Exception e) {
            log("Google OAuth authentication failed.", e);
            response.sendRedirect(contextPath + "/login?error=google");
        }
    }

    private String exchangeCode(String code,
                                String clientId,
                                String clientSecret)
            throws IOException {

        String formData =
                "code=" + encode(code)
                + "&client_id=" + encode(clientId)
                + "&client_secret=" + encode(clientSecret)
                + "&redirect_uri=" + encode(REDIRECT_URI)
                + "&grant_type=authorization_code";

        HttpURLConnection connection = (HttpURLConnection)
                URI.create(TOKEN_URL).toURL().openConnection();

        connection.setRequestMethod("POST");
        connection.setDoOutput(true);
        connection.setConnectTimeout(10000);
        connection.setReadTimeout(10000);
        connection.setRequestProperty(
                "Content-Type",
                "application/x-www-form-urlencoded");

        try {
            connection.getOutputStream().write(
                    formData.getBytes(StandardCharsets.UTF_8));

            int status = connection.getResponseCode();

            if (status != HttpURLConnection.HTTP_OK) {
                throw new IOException(
                        "Google token exchange failed. HTTP " + status);
            }

            return readResponse(connection.getInputStream());

        } finally {
            connection.disconnect();
        }
    }

    private String verifyIdToken(String idToken)
            throws IOException {

        String url = TOKEN_INFO_URL + encode(idToken);

        HttpURLConnection connection = (HttpURLConnection)
                URI.create(url).toURL().openConnection();

        connection.setRequestMethod("GET");
        connection.setConnectTimeout(10000);
        connection.setReadTimeout(10000);

        try {
            int status = connection.getResponseCode();

            if (status != HttpURLConnection.HTTP_OK) {
                throw new IOException(
                        "Google ID token verification failed.");
            }

            return readResponse(connection.getInputStream());

        } finally {
            connection.disconnect();
        }
    }

    private String readResponse(InputStream input)
            throws IOException {

        StringBuilder result = new StringBuilder();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(input, StandardCharsets.UTF_8))) {

            String line;

            while ((line = reader.readLine()) != null) {
                result.append(line);
            }
        }

        return result.toString();
    }

    private String extractJsonString(String json, String key) {

        Pattern pattern = Pattern.compile(
                "\"" + Pattern.quote(key)
                + "\"\\s*:\\s*(?:\"((?:\\\\.|[^\"\\\\])*)\""
                + "|(true|false|[0-9]+))");

        Matcher matcher = pattern.matcher(json);

        if (!matcher.find()) {
            return null;
        }

        return matcher.group(1) != null
                ? matcher.group(1)
                : matcher.group(2);
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
