
package com.tap.Controller;
import com.tap.model.User;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.tap.Dao.OrderDao;
import com.tap.Dao.OrderItemDao;
import com.tap.DaoImpl.OrderDaoImpl;
import com.tap.DaoImpl.OrderItemDaoImpl;
import com.tap.model.CartItem;
import com.tap.model.Menu;
import com.tap.model.OrderItem;
import com.tap.model.Orders;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/checkout")
public class CheckOutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final OrderDao orderDao = new OrderDaoImpl();
    private final OrderItemDao orderItemDao = new OrderItemDaoImpl();

    private static final double DELIVERY_FEE = 40.0;
    private static final double TAX_RATE = 0.05;

    private final Gson gson = new Gson();




    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        String contextPath = request.getContextPath();

        boolean loggedIn = session != null
                && (session.getAttribute("user") instanceof User
                || session.getAttribute("loggedInUser") instanceof User);

        if (loggedIn) {
            response.sendRedirect(contextPath + "/checkout.jsp");
        } else {
            response.sendRedirect(contextPath + "/login?redirect=checkout");
        }
    }



    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null) {
            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_UNAUTHORIZED,
                "Your session has expired. Please log in again.",
                "/login.jsp"
            );
            return;
        }

        Object loggedInObject = session.getAttribute("user");

        if (!(loggedInObject instanceof User)) {
            loggedInObject = session.getAttribute("loggedInUser");
        }

        if (!(loggedInObject instanceof User)) {
            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_UNAUTHORIZED,
                "Please log in before checking out.",
                "/login.jsp"
            );
            return;
        }

        User user = (User) loggedInObject;

        Object cartObject = session.getAttribute("cartItems");

        if (!(cartObject instanceof List<?>)) {
            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Your cart is empty.",
                "/cart.jsp"
            );
            return;
        }

        List<CartItem> cartItems = (List<CartItem>) cartObject;

        if (cartItems.isEmpty()) {
            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Your cart is empty.",
                "/cart.jsp"
            );
            return;
        }

        String paymentMode = request.getParameter("paymentMode");

        if (paymentMode == null ||
            (!"COD".equalsIgnoreCase(paymentMode) &&
             !"ONLINE".equalsIgnoreCase(paymentMode))) {

            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Please select a payment method.",
                "/checkout.jsp?error=payment"
            );
            return;
        }

        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String landmark = request.getParameter("landmark");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String pincode = request.getParameter("pincode");

        // Matches the field name in checkout.jsp.
        String instructions = request.getParameter("instructions");

        if (isBlank(fullName) ||
            isBlank(phone) ||
            isBlank(email) ||
            isBlank(address) ||
            isBlank(city) ||
            isBlank(state) ||
            isBlank(pincode)) {

            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Please complete all required delivery details.",
                "/checkout.jsp?error=address"
            );
            return;
        }

        if (!phone.trim().matches("[0-9]{10}") ||
            !pincode.trim().matches("[0-9]{6}")) {

            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_BAD_REQUEST,
                "Enter a valid 10-digit phone number and 6-digit PIN code.",
                "/checkout.jsp?error=address"
            );
            return;
        }

        double subtotal = 0.0;
        int restaurantId = -1;

        // Validate the cart and calculate the subtotal.
        for (CartItem cartItem : cartItems) {

            if (cartItem == null ||
                cartItem.getMenu() == null ||
                cartItem.getQuantity() <= 0) {

                sendErrorResponse(
                    request, response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Your cart contains an invalid item.",
                    "/cart.jsp"
                );
                return;
            }

            Menu menu = cartItem.getMenu();

            if (restaurantId == -1) {
                restaurantId = menu.getRestaurantId();
            } else if (restaurantId != menu.getRestaurantId()) {

                sendErrorResponse(
                    request, response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Please order from one restaurant at a time.",
                    "/cart.jsp?error=differentRestaurant"
                );
                return;
            }

            if (menu.getPrice() < 0) {
                sendErrorResponse(
                    request, response,
                    HttpServletResponse.SC_BAD_REQUEST,
                    "An item has an invalid price.",
                    "/cart.jsp"
                );
                return;
            }

            subtotal += menu.getPrice() * cartItem.getQuantity();
        }

        double tax = subtotal * TAX_RATE;

        double totalAmount = Math.round(
            (subtotal + DELIVERY_FEE + tax) * 100.0
        ) / 100.0;

        // Store delivery details for the payment flow.
        session.setAttribute("checkoutFullName", fullName.trim());
        session.setAttribute("checkoutPhone", phone.trim());
        session.setAttribute("checkoutEmail", email.trim());
        session.setAttribute("checkoutAddress", address.trim());
        session.setAttribute(
            "checkoutLandmark",
            landmark == null ? "" : landmark.trim()
        );
        session.setAttribute("checkoutCity", city.trim());
        session.setAttribute("checkoutState", state.trim());
        session.setAttribute("checkoutPincode", pincode.trim());
        session.setAttribute(
            "checkoutInstructions",
            instructions == null ? "" : instructions.trim()
        );
        session.setAttribute("paymentMode", paymentMode.toUpperCase());
        session.setAttribute("paymentAmount", totalAmount);

        // ONLINE: retain the existing payment handoff.
        if ("ONLINE".equalsIgnoreCase(paymentMode)) {

            if (isAjaxRequest(request)) {
                response.setContentType("application/json");

                response.getWriter().write(
                    gson.toJson(Map.of(
                        "success", true,
                        "message", "Checkout details saved.",
                        "amount", totalAmount
                    ))
                );
            } else {
                response.sendRedirect(
                    request.getContextPath() + "/payment.jsp");
            }

            return;
        }

        // COD: save the order and order items before redirecting.
        try {
            Orders order = new Orders();

            order.setUserId(user.getUserId());
            order.setRestaurantId(restaurantId);
            order.setOrderDate(Date.valueOf(LocalDate.now()));
            order.setTotalAmount(totalAmount);
            order.setStatus("PLACED");
            order.setPaymentMode("COD");

            orderDao.addOrder(order);

            if (order.getOrderId() <= 0) {
                throw new IllegalStateException(
                    "The database did not return a valid order ID."
                );
            }

            for (CartItem cartItem : cartItems) {

                Menu menu = cartItem.getMenu();

                OrderItem orderItem = new OrderItem();

                orderItem.setOrderId(order.getOrderId());
                orderItem.setMenuId(menu.getMenuId());

                double itemTotal = Math.round(
                    menu.getPrice() * cartItem.getQuantity() * 100.0
                ) / 100.0;

                orderItem.setTotalAmount(itemTotal);

                // The existing orderitems DAO saves the item total.
                // Quantity is not stored separately by that DAO.
                orderItemDao.addOrderItem(orderItem);
            }

            // Save the order information for the success page.
            session.setAttribute("orderId", order.getOrderId());
            session.setAttribute("lastOrderId", order.getOrderId());
            session.setAttribute("lastSuccessfulOrder", order);

            // Clear the cart after all inserts succeed.
            session.removeAttribute("cartItems");
            session.removeAttribute("cart");
            session.removeAttribute("paymentAmount");

            // COD success redirect.
            response.sendRedirect(
                request.getContextPath() + "/order-success.jsp"
            );
            return;

        } catch (Exception e) {

            getServletContext().log(
                "Failed to place Culinova COD order.", e
            );

            e.printStackTrace();

            sendErrorResponse(
                request, response,
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "We couldn't place your order. Please try again.",
                "/checkout.jsp?error=order"
            );
            return;
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        return "XMLHttpRequest".equalsIgnoreCase(
            request.getHeader("X-Requested-With")
        );
    }

    private void sendErrorResponse(
            HttpServletRequest request,
            HttpServletResponse response,
            int status,
            String message,
            String redirectPath) throws IOException {

        if (isAjaxRequest(request)) {
            response.setStatus(status);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            response.getWriter().write(
                gson.toJson(Map.of(
                    "success", false,
                    "error", message
                ))
            );

        } else {
            response.sendRedirect(
                request.getContextPath() + redirectPath
            );
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
