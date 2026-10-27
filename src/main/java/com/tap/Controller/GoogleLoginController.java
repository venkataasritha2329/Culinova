
package com.tap.Controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/google-login")
public class GoogleLoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String CLIENT_ID =
            "97639880534-3j30st0qd54p002dl40bk2do9c0o3705.apps.googleusercontent.com";

    private static final String REDIRECT_URI =
            "http://localhost:8080/Culinova/google-callback";

    private static final String GOOGLE_AUTH_URL =
            "https://accounts.google.com/o/oauth2/v2/auth";

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // Protect the OAuth flow against CSRF.
        String state = UUID.randomUUID().toString();
        session.setAttribute("googleOAuthState", state);

        String scope = URLEncoder.encode(
                "openid email profile",
                StandardCharsets.UTF_8);

        String redirectUri = URLEncoder.encode(
                REDIRECT_URI,
                StandardCharsets.UTF_8);

        String clientId = URLEncoder.encode(
                CLIENT_ID,
                StandardCharsets.UTF_8);

        String encodedState = URLEncoder.encode(
                state,
                StandardCharsets.UTF_8);

        String googleUrl = GOOGLE_AUTH_URL
                + "?client_id=" + clientId
                + "&redirect_uri=" + redirectUri
                + "&response_type=code"
                + "&scope=" + scope
                + "&state=" + encodedState;

        response.sendRedirect(googleUrl);
    }
}
