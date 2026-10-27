
package com.tap.Controller;

import java.io.IOException;
import java.util.List;

import com.tap.Dao.OrderItemDao;
import com.tap.DaoImpl.OrderItemDaoImpl;
import com.tap.model.OrderItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/order-items")
public class OrderItemController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderItemDao orderItemDao;

    @Override
    public void init() throws ServletException {
        orderItemDao = new OrderItemDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderIdValue = request.getParameter("orderId");

        if (orderIdValue == null || orderIdValue.trim().isEmpty()) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Order ID is required.");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdValue);

            if (orderId <= 0) {
                response.sendError(
                        HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid order ID.");
                return;
            }

            List<OrderItem> orderItems =
                    orderItemDao.getOrderItemsByOrderId(orderId);

            request.setAttribute("orderItems", orderItems);
            request.setAttribute("orderId", orderId);

            request.getRequestDispatcher("/order-items.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid order ID.");
        }
    }
}
