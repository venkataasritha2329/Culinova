
package com.tap.Controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

import com.tap.Dao.MenuDao;
import com.tap.DaoImpl.MenuDaoImpl;
import com.tap.model.CartItem;
import com.tap.model.Menu;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/cart")
public class CartController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MenuDao menuDAO;

    @Override
    public void init() throws ServletException {
        menuDAO = new MenuDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/cart.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();

        @SuppressWarnings("unchecked")
        List<CartItem> sessionCart =
                (List<CartItem>) session.getAttribute("cartItems");

        List<CartItem> cartItems = sessionCart;

        if (cartItems == null) {
            cartItems = new ArrayList<>();
        }

        String action = request.getParameter("action");
        String source = request.getParameter("source");

        boolean ajaxRequest =
                "XMLHttpRequest".equalsIgnoreCase(
                        request.getHeader("X-Requested-With"));

        boolean menuRequest = "menu".equalsIgnoreCase(source);

        boolean clearCart =
                "true".equalsIgnoreCase(request.getParameter("clearCart"));

        int menuId = 0;
        int restaurantId = 0;

        try {
            String menuValue = request.getParameter("menuId");
            String restaurantValue = request.getParameter("restaurantId");

            if (menuValue != null && !menuValue.isBlank()) {
                menuId = Integer.parseInt(menuValue);
            }

            if (restaurantValue != null && !restaurantValue.isBlank()) {
                restaurantId = Integer.parseInt(restaurantValue);
            }
        } catch (NumberFormatException e) {
            respondOrRedirect(
                    request, response, ajaxRequest, menuRequest,
                    HttpServletResponse.SC_BAD_REQUEST,
                    false, false, "Invalid menu or restaurant ID.",
                    menuId, restaurantId, cartItems);
            return;
        }

        if (action == null || action.isBlank()) {
            respondOrRedirect(
                    request, response, ajaxRequest, menuRequest,
                    HttpServletResponse.SC_BAD_REQUEST,
                    false, false, "Cart action is required.",
                    menuId, restaurantId, cartItems);
            return;
        }

        boolean success = true;
        boolean conflict = false;
        String message = "";

        switch (action) {

            case "add":
            case "replaceCart": {

                if (menuId <= 0) {
                    success = false;
                    message = "Invalid menu item.";
                    break;
                }

                Menu menu = menuDAO.getMenu(menuId);

                if (menu == null) {
                    success = false;
                    message = "Menu item not found.";
                    break;
                }

                if (!menu.isAvailable()) {
                    success = false;
                    message = "This menu item is currently unavailable.";
                    break;
                }

                int actualRestaurantId = menu.getRestaurantId();

                if (restaurantId > 0
                        && restaurantId != actualRestaurantId) {
                    success = false;
                    message =
                            "The selected item does not belong to this restaurant.";
                    break;
                }

                int cartRestaurantId = getCartRestaurantId(cartItems);

                boolean differentRestaurant =
                        cartRestaurantId > 0
                        && cartRestaurantId != actualRestaurantId;

                // Do not modify the existing cart until the user confirms.
                if (differentRestaurant
                        && !clearCart
                        && !"replaceCart".equals(action)) {

                    success = false;
                    conflict = true;
                    message =
                            "Your cart contains items from another restaurant. "
                            + "Clear the existing cart and add this item?";
                    break;
                }

                // The user confirmed replacing the cart.
                if (clearCart || "replaceCart".equals(action)) {
                    cartItems.clear();
                }

                CartItem existingItem = findCartItem(cartItems, menuId);

                if (existingItem != null) {
                    existingItem.setQuantity(
                            existingItem.getQuantity() + 1);
                } else {
                    cartItems.add(new CartItem(menu, 1));
                }

                session.removeAttribute("cartMessage");
                break;
            }

            case "increment": {

                CartItem item = findCartItem(cartItems, menuId);

                if (menuId <= 0 || item == null) {
                    success = false;
                    message = "This item is not in your cart.";
                } else {
                    item.setQuantity(item.getQuantity() + 1);
                }

                break;
            }

            case "decrement": {

                if (menuId <= 0) {
                    success = false;
                    message = "Invalid menu item.";
                    break;
                }

                Iterator<CartItem> iterator = cartItems.iterator();
                boolean found = false;

                while (iterator.hasNext()) {
                    CartItem item = iterator.next();

                    if (item != null
                            && item.getMenu() != null
                            && item.getMenu().getMenuId() == menuId) {

                        found = true;

                        if (item.getQuantity() <= 1) {
                            iterator.remove();
                        } else {
                            item.setQuantity(item.getQuantity() - 1);
                        }

                        break;
                    }
                }

                if (!found) {
                    success = false;
                    message = "This item is not in your cart.";
                }

                break;
            }

            case "remove": {

                Iterator<CartItem> iterator = cartItems.iterator();

                while (iterator.hasNext()) {
                    CartItem item = iterator.next();

                    if (item != null
                            && item.getMenu() != null
                            && item.getMenu().getMenuId() == menuId) {
                        iterator.remove();
                        break;
                    }
                }

                break;
            }

            case "clear": {
                cartItems.clear();
                session.removeAttribute("cartMessage");
                break;
            }

            default: {
                success = false;
                message = "Unknown cart action.";
                break;
            }
        }

        session.setAttribute("cartItems", cartItems);

        if (ajaxRequest && menuRequest) {
            int status = success
                    ? HttpServletResponse.SC_OK
                    : conflict
                        ? HttpServletResponse.SC_CONFLICT
                        : HttpServletResponse.SC_BAD_REQUEST;

            writeJson(
                    response, status, success, conflict,
                    message, menuId, cartItems);
            return;
        }

        if (!success && !message.isEmpty()) {
            session.setAttribute("cartMessage", message);
        }

        if (menuRequest) {
            if (restaurantId <= 0 && !cartItems.isEmpty()
                    && cartItems.get(0) != null
                    && cartItems.get(0).getMenu() != null) {
                restaurantId =
                        cartItems.get(0).getMenu().getRestaurantId();
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/menu?restaurantId=" + restaurantId);
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private int getCartRestaurantId(List<CartItem> cartItems) {
        for (CartItem item : cartItems) {
            if (item != null && item.getMenu() != null) {
                return item.getMenu().getRestaurantId();
            }
        }

        return 0;
    }

    private CartItem findCartItem(List<CartItem> cartItems, int menuId) {
        for (CartItem item : cartItems) {
            if (item != null
                    && item.getMenu() != null
                    && item.getMenu().getMenuId() == menuId) {
                return item;
            }
        }

        return null;
    }

    private void respondOrRedirect(
            HttpServletRequest request,
            HttpServletResponse response,
            boolean ajaxRequest,
            boolean menuRequest,
            int status,
            boolean success,
            boolean conflict,
            String message,
            int menuId,
            int restaurantId,
            List<CartItem> cartItems) throws IOException {

        request.getSession().setAttribute("cartItems", cartItems);

        if (ajaxRequest && menuRequest) {
            writeJson(
                    response, status, success, conflict,
                    message, menuId, cartItems);
            return;
        }

        request.getSession().setAttribute("cartMessage", message);

        if (menuRequest) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/menu?restaurantId=" + restaurantId);
        } else {
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private void writeJson(
            HttpServletResponse response,
            int status,
            boolean success,
            boolean conflict,
            String message,
            int menuId,
            List<CartItem> cartItems) throws IOException {

        int cartCount = 0;
        int quantity = 0;
        double cartTotal = 0.0;

        for (CartItem item : cartItems) {
            if (item == null || item.getMenu() == null) {
                continue;
            }

            cartCount += item.getQuantity();
            cartTotal += item.getSubtotal();

            if (item.getMenu().getMenuId() == menuId) {
                quantity = item.getQuantity();
            }
        }

        String json =
                "{"
                + "\"success\":" + success + ","
                + "\"conflict\":" + conflict + ","
                + "\"message\":\"" + escapeJson(message) + "\","
                + "\"menuId\":" + menuId + ","
                + "\"quantity\":" + quantity + ","
                + "\"cartCount\":" + cartCount + ","
                + "\"cartTotal\":"
                + String.format(Locale.ROOT, "%.2f", cartTotal)
                + "}";

        response.setStatus(status);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.getWriter().write(json);
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
