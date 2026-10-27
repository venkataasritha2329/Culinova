
package com.tap.Controller;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.time.Duration;
import java.time.LocalDate;
import java.util.Base64;
import java.util.List;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.tap.Dao.OrderDao;
import com.tap.Dao.OrderItemDao;
import com.tap.DaoImpl.OrderDaoImpl;
import com.tap.DaoImpl.OrderItemDaoImpl;
import com.tap.model.CartItem;
import com.tap.model.Menu;
import com.tap.model.OrderItem;
import com.tap.model.Orders;
import com.tap.model.User;
import com.tap.util.RazorpayConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/verify-razorpay-payment")
public class RazorpayVerifyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDao orderDao = new OrderDaoImpl();
    private final OrderItemDao orderItemDao = new OrderItemDaoImpl();

    private static final HttpClient CLIENT = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        try {
            if (session == null) {
                sendJson(response, 401, false,
                        "Session expired. Please log in again.");
                return;
            }

            Object userObject = session.getAttribute("user");

            if (!(userObject instanceof User)) {
                userObject = session.getAttribute("loggedInUser");
            }

            if (!(userObject instanceof User)) {
                sendJson(response, 401, false,
                        "Please log in again.");
                return;
            }

            User user = (User) userObject;

            String razorpayOrderId =
                    request.getParameter("razorpay_order_id");
            String paymentId =
                    request.getParameter("razorpay_payment_id");
            String signature =
                    request.getParameter("razorpay_signature");

            if (isBlank(razorpayOrderId)
                    || isBlank(paymentId)
                    || isBlank(signature)) {
                sendJson(response, 400, false,
                        "Payment verification details are missing.");
                return;
            }

            // Match the payment to the Razorpay order created
            // for this user's current checkout session.
            String savedRazorpayOrderId =
                    (String) session.getAttribute("razorpayOrderId");

            Object savedAmountObject =
                    session.getAttribute("razorpayOrderAmount");

            Object paymentAmountObject =
                    session.getAttribute("paymentAmount");

            if (savedRazorpayOrderId == null
                    || !savedRazorpayOrderId.equals(razorpayOrderId)
                    || !(savedAmountObject instanceof Number)
                    || !(paymentAmountObject instanceof Number)) {
                sendJson(response, 400, false,
                        "Payment does not match the current checkout.");
                return;
            }

            long expectedPaise =
                    ((Number) savedAmountObject).longValue();

            long checkoutPaise = Math.round(
                    ((Number) paymentAmountObject).doubleValue() * 100);

            if (expectedPaise <= 0 || expectedPaise != checkoutPaise) {
                sendJson(response, 400, false,
                        "Payment amount validation failed.");
                return;
            }

            // Verify Razorpay's HMAC signature.
            String secret = RazorpayConfig.getKeySecret();

            if (isBlank(secret)) {
                sendJson(response, 500, false,
                        "Razorpay Test Mode secret is missing.");
                return;
            }

            String generatedSignature = generateHmacSHA256(
                    razorpayOrderId + "|" + paymentId,
                    secret.trim());

            if (!constantTimeEquals(generatedSignature, signature)) {
                sendJson(response, 400, false,
                        "Payment signature verification failed.");
                return;
            }

            // Confirm the payment status directly with Razorpay.
            String keyId = RazorpayConfig.getKeyId();

            if (isBlank(keyId)) {
                sendJson(response, 500, false,
                        "Razorpay Test Mode key ID is missing.");
                return;
            }

            String credentials = keyId.trim() + ":" + secret.trim();

            String basicAuth = Base64.getEncoder().encodeToString(
                    credentials.getBytes(StandardCharsets.UTF_8));

            HttpRequest paymentRequest = HttpRequest.newBuilder()
                    .uri(URI.create(
                            "https://api.razorpay.com/v1/payments/"
                                    + paymentId))
                    .timeout(Duration.ofSeconds(30))
                    .header("Authorization", "Basic " + basicAuth)
                    .GET()
                    .build();

            HttpResponse<String> paymentResponse = CLIENT.send(
                    paymentRequest,
                    HttpResponse.BodyHandlers.ofString(
                            StandardCharsets.UTF_8));

            if (paymentResponse.statusCode() < 200
                    || paymentResponse.statusCode() >= 300) {
                getServletContext().log(
                        "Razorpay payment lookup failed. HTTP status: "
                                + paymentResponse.statusCode());

                sendJson(response, 502, false,
                        "Could not confirm payment with Razorpay.");
                return;
            }

            JsonObject payment = JsonParser
                    .parseString(paymentResponse.body())
                    .getAsJsonObject();

            String apiOrderId = payment.has("order_id")
                    && !payment.get("order_id").isJsonNull()
                    ? payment.get("order_id").getAsString()
                    : "";

            String paymentStatus = payment.has("status")
                    && !payment.get("status").isJsonNull()
                    ? payment.get("status").getAsString()
                    : "";

            long actualPaise = payment.has("amount")
                    ? payment.get("amount").getAsLong()
                    : -1;

            String currency = payment.has("currency")
                    && !payment.get("currency").isJsonNull()
                    ? payment.get("currency").getAsString()
                    : "";

            if (!razorpayOrderId.equals(apiOrderId)
                    || actualPaise != expectedPaise
                    || !"INR".equals(currency)) {
                sendJson(response, 400, false,
                        "Payment details do not match the checkout.");
                return;
            }

            // Do not create a paid order for an authorized-but-not-
            // captured payment. Configure Razorpay to capture payments,
            // or implement a capture step before reaching this point.
            if (!"captured".equalsIgnoreCase(paymentStatus)) {
                sendJson(response, 400, false,
                        "Payment has not been captured yet.");
                return;
            }

            // Prevent the same checkout session from saving the order
            // again if the browser repeats the verification request.
            if (Boolean.TRUE.equals(
                    session.getAttribute("paymentVerified"))
                    && paymentId.equals(
                    session.getAttribute("razorpayPaymentId"))
                    && session.getAttribute("lastSuccessfulOrder")
                    instanceof Orders) {

                Orders previousOrder =
                        (Orders) session.getAttribute("lastSuccessfulOrder");

                if (previousOrder.getOrderId() > 0) {
                    sendSuccess(response, previousOrder.getOrderId());
                    return;
                }
            }

            Object cartObject = session.getAttribute("cartItems");

            if (!(cartObject instanceof List<?>)) {
                sendJson(response, 400, false,
                        "Your cart is empty. Please contact support if payment was taken.");
                return;
            }

            List<CartItem> cartItems = (List<CartItem>) cartObject;

            if (cartItems.isEmpty()) {
                sendJson(response, 400, false,
                        "Your cart is empty. Please contact support if payment was taken.");
                return;
            }

            int restaurantId = -1;
            double subtotal = 0.0;

            for (CartItem item : cartItems) {
                if (item == null || item.getMenu() == null
                        || item.getQuantity() <= 0) {
                    sendJson(response, 400, false,
                            "Your cart contains an invalid item.");
                    return;
                }

                Menu menu = item.getMenu();

                if (restaurantId == -1) {
                    restaurantId = menu.getRestaurantId();
                } else if (restaurantId != menu.getRestaurantId()) {
                    sendJson(response, 400, false,
                            "Your cart contains items from different restaurants.");
                    return;
                }

                if (!Double.isFinite(menu.getPrice())
                        || menu.getPrice() < 0) {
                    sendJson(response, 400, false,
                            "An item has an invalid price.");
                    return;
                }

                subtotal += menu.getPrice() * item.getQuantity();
            }

            double expectedTotal = Math.round(
                    (subtotal + 40.0 + subtotal * 0.05) * 100.0) / 100.0;

            double checkoutTotal =
                    ((Number) paymentAmountObject).doubleValue();

            if (Math.round(expectedTotal * 100)
                    != Math.round(checkoutTotal * 100)) {
                sendJson(response, 400, false,
                        "The cart total has changed. Please contact support if payment was taken.");
                return;
            }

            // Save the order only after verifying the captured payment.
            Orders order = new Orders();
            order.setUserId(user.getUserId());
            order.setRestaurantId(restaurantId);
            order.setOrderDate(Date.valueOf(LocalDate.now()));
            order.setTotalAmount(checkoutTotal);
            order.setStatus("PLACED");
            order.setPaymentMode("ONLINE");

            orderDao.addOrder(order);

            if (order.getOrderId() <= 0) {
                throw new IllegalStateException(
                        "Database did not return a valid order ID.");
            }

            for (CartItem item : cartItems) {
                OrderItem orderItem = new OrderItem();

                orderItem.setOrderId(order.getOrderId());
                orderItem.setMenuId(item.getMenu().getMenuId());

                double itemTotal = Math.round(
                        item.getMenu().getPrice()
                                * item.getQuantity() * 100.0) / 100.0;

                orderItem.setTotalAmount(itemTotal);
                orderItemDao.addOrderItem(orderItem);
            }

            // Store success details and clear the cart only after inserts.
            session.setAttribute("orderId", order.getOrderId());
            session.setAttribute("lastOrderId", order.getOrderId());
            session.setAttribute("lastSuccessfulOrder", order);
            session.setAttribute("razorpayPaymentId", paymentId);
            session.setAttribute("paymentVerified", true);

            session.removeAttribute("cartItems");
            session.removeAttribute("cart");
            session.removeAttribute("paymentAmount");

            sendSuccess(response, order.getOrderId());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            getServletContext().log(
                    "Razorpay payment verification was interrupted.", e);
            sendJson(response, 500, false,
                    "Payment verification was interrupted. Please check your order history.");

        } catch (Exception e) {
            getServletContext().log(
                    "Error while verifying payment and saving the order.", e);
            sendJson(response, 500, false,
                    "Payment could not be completed in the order system. Please check your order history before retrying.");
        }
    }

    private String generateHmacSHA256(String message, String secret)
            throws Exception {

        Mac mac = Mac.getInstance("HmacSHA256");
        SecretKeySpec key = new SecretKeySpec(
                secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");

        mac.init(key);

        byte[] hash = mac.doFinal(
                message.getBytes(StandardCharsets.UTF_8));

        StringBuilder result = new StringBuilder();

        for (byte b : hash) {
            result.append(String.format("%02x", b & 0xff));
        }

        return result.toString();
    }

    private boolean constantTimeEquals(String first, String second) {
        if (first == null || second == null) {
            return false;
        }

        return java.security.MessageDigest.isEqual(
                first.getBytes(StandardCharsets.UTF_8),
                second.getBytes(StandardCharsets.UTF_8));
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void sendSuccess(HttpServletResponse response, int orderId)
            throws IOException {

        response.setStatus(HttpServletResponse.SC_OK);

        JsonObject result = new JsonObject();
        result.addProperty("success", true);
        result.addProperty("orderId", orderId);
        result.addProperty("message", "Payment verified and order saved.");

        response.getWriter().write(result.toString());
    }

    private void sendJson(HttpServletResponse response,
                          int status,
                          boolean success,
                          String message) throws IOException {

        response.setStatus(status);

        JsonObject result = new JsonObject();
        result.addProperty("success", success);
        result.addProperty("error", message);

        response.getWriter().write(result.toString());
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        sendJson(response, 405, false,
                "GET is not supported. Use POST for payment verification.");
    }
}
