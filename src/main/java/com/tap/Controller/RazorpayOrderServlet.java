
package com.tap.Controller;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.UUID;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonParseException;
import com.tap.util.RazorpayConfig;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/create-razorpay-order")
public class RazorpayOrderServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final HttpClient CLIENT = HttpClient.newBuilder()
            .connectTimeout(java.time.Duration.ofSeconds(15))
            .build();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // 1. Check the logged-in user session.
            HttpSession session = request.getSession(false);

            if (session == null
                    || (session.getAttribute("user") == null
                    && session.getAttribute("loggedInUser") == null)) {

                sendJson(response, HttpServletResponse.SC_UNAUTHORIZED,
                        false, "Please log in again.");
                return;
            }

            // 2. Get the payment amount saved during checkout.
            Object amountObject = session.getAttribute("paymentAmount");

            if (amountObject == null) {
                sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                        false, "Payment amount is missing. Reopen checkout.");
                return;
            }

            double paymentAmount;

            try {
                paymentAmount = Double.parseDouble(
                        amountObject.toString().trim());
            } catch (NumberFormatException e) {
                sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                        false, "Invalid payment amount.");
                return;
            }

            if (!Double.isFinite(paymentAmount) || paymentAmount <= 0) {
                sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                        false, "Payment amount must be greater than zero.");
                return;
            }

            // 3. Convert rupees into paise.
            long amountInPaise = Math.round(paymentAmount * 100);

            if (amountInPaise <= 0) {
                sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                        false, "Invalid payment amount.");
                return;
            }

            // 4. Load Razorpay credentials.
            String keyId = RazorpayConfig.getKeyId();
            String keySecret = RazorpayConfig.getKeySecret();

            if (keyId == null || keyId.isBlank()
                    || keySecret == null || keySecret.isBlank()) {

                System.err.println(
                        "Razorpay configuration error: Key ID or Secret is missing.");

                sendJson(response,
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        false, "Razorpay Test Mode configuration is missing.");
                return;
            }

            keyId = keyId.trim();
            keySecret = keySecret.trim();

            // 5. Prepare the Razorpay order request.
            JsonObject orderRequest = new JsonObject();
            orderRequest.addProperty("amount", amountInPaise);
            orderRequest.addProperty("currency", "INR");
            orderRequest.addProperty(
                    "receipt", "CULINOVA_" + UUID.randomUUID());

            String credentials = keyId + ":" + keySecret;

            String encodedCredentials = Base64.getEncoder()
                    .encodeToString(
                            credentials.getBytes(StandardCharsets.UTF_8));

            HttpRequest httpRequest = HttpRequest.newBuilder()
                    .uri(URI.create(
                            "https://api.razorpay.com/v1/orders"))
                    .timeout(java.time.Duration.ofSeconds(30))
                    .header("Authorization",
                            "Basic " + encodedCredentials)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(
                            orderRequest.toString(),
                            StandardCharsets.UTF_8))
                    .build();

            // 6. Send the order request to Razorpay.
            HttpResponse<String> razorpayResponse =
                    CLIENT.send(httpRequest,
                            HttpResponse.BodyHandlers.ofString(
                                    StandardCharsets.UTF_8));

            int statusCode = razorpayResponse.statusCode();
            String responseBody = razorpayResponse.body();

            // 7. Handle errors returned by Razorpay.
            if (statusCode < 200 || statusCode >= 300) {

                // Log the API response for debugging, but never log credentials.
                System.err.println(
                        "Razorpay order creation failed. HTTP status: "
                                + statusCode);

                try {
                    JsonObject errorJson = JsonParser
                            .parseString(responseBody)
                            .getAsJsonObject();

                    if (errorJson.has("error")
                            && errorJson.get("error").isJsonObject()) {

                        JsonObject error = errorJson.getAsJsonObject("error");

                        String code = error.has("code")
                                && !error.get("code").isJsonNull()
                                ? error.get("code").getAsString()
                                : "UNKNOWN";

                        String description = error.has("description")
                                && !error.get("description").isJsonNull()
                                ? error.get("description").getAsString()
                                : "No description supplied";

                        System.err.println(
                                "Razorpay error code: " + code);
                        System.err.println(
                                "Razorpay error description: " + description);
                    }
                } catch (RuntimeException parseException) {
                    System.err.println(
                            "Razorpay returned an unreadable error response.");
                }

                if (statusCode == 401) {
                    sendJson(response, HttpServletResponse.SC_BAD_GATEWAY,
                            false,
                            "Razorpay authentication failed. Check your Test Mode keys.");
                } else if (statusCode == 400) {
                    sendJson(response, HttpServletResponse.SC_BAD_GATEWAY,
                            false,
                            "Razorpay rejected the order details. Check the server Console.");
                } else {
                    sendJson(response, HttpServletResponse.SC_BAD_GATEWAY,
                            false,
                            "Razorpay could not create the order. Check the server Console.");
                }

                return;
            }

            // 8. Parse the successful Razorpay response.
            JsonObject razorpayOrder;

            try {
                razorpayOrder = JsonParser.parseString(responseBody)
                        .getAsJsonObject();

                if (!razorpayOrder.has("id")
                        || !razorpayOrder.has("amount")
                        || !razorpayOrder.has("currency")
                        || razorpayOrder.get("id").isJsonNull()
                        || razorpayOrder.get("amount").isJsonNull()
                        || razorpayOrder.get("currency").isJsonNull()) {

                    throw new IllegalStateException(
                            "Required fields are missing from the Razorpay response.");
                }
            } catch (RuntimeException e) {
                System.err.println(
                        "Could not parse the successful Razorpay order response.");
                e.printStackTrace();

                sendJson(response,
                        HttpServletResponse.SC_BAD_GATEWAY,
                        false, "Invalid response received from Razorpay.");
                return;
            }

            String orderId = razorpayOrder.get("id").getAsString();
            String currency = razorpayOrder.get("currency").getAsString();
            long amount = razorpayOrder.get("amount").getAsLong();

            if (orderId.isBlank()
                    || !"INR".equals(currency)
                    || amount != amountInPaise) {

                System.err.println(
                        "Razorpay order response did not match the requested amount or currency.");

                sendJson(response,
                        HttpServletResponse.SC_BAD_GATEWAY,
                        false, "Razorpay returned unexpected order details.");
                return;
            }

            // 9. Save order details in the session for verification.
            session.setAttribute("razorpayOrderId", orderId);
            session.setAttribute("razorpayOrderAmount", amount);
            session.setAttribute("paymentMode", "ONLINE");

            // 10. Send the order details to checkout.jsp.
            JsonObject result = new JsonObject();
            result.addProperty("success", true);
            result.addProperty("orderId", orderId);
            result.addProperty("keyId", keyId);
            result.addProperty("amount", amount);
            result.addProperty("currency", currency);

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(result.toString());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();

            System.err.println(
                    "Razorpay order request was interrupted.");

            sendJson(response,
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    false, "Order creation was interrupted. Please try again.");

        } catch (java.net.http.HttpTimeoutException e) {
            System.err.println(
                    "Timed out while communicating with Razorpay.");

            sendJson(response,
                    HttpServletResponse.SC_GATEWAY_TIMEOUT,
                    false, "Razorpay request timed out. Please try again.");

        } catch (java.net.ConnectException e) {
            System.err.println(
                    "Could not connect to the Razorpay API.");

            sendJson(response,
                    HttpServletResponse.SC_BAD_GATEWAY,
                    false, "Could not connect to Razorpay. Check your network.");

        } catch (Exception e) {
            // The Console contains the actual exception for debugging.
            System.err.println(
                    "Unexpected error while creating Razorpay order: "
                            + e.getClass().getName());
            e.printStackTrace();

            if (!response.isCommitted()) {
                sendJson(response,
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        false, "Unexpected error while creating Razorpay order. "
                                + "Check the Eclipse Console.");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        sendJson(response,
                HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                false, "GET is not supported. Use POST to create a Razorpay order.");
    }

    private void sendJson(HttpServletResponse response,
                          int status,
                          boolean success,
                          String message) throws IOException {

        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        JsonObject result = new JsonObject();
        result.addProperty("success", success);
        result.addProperty("error", message);

        response.getWriter().write(result.toString());
    }
}
