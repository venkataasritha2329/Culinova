package com.tap.Controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tap.Dao.OrderDao;
import com.tap.Dao.OrderItemDao;
import com.tap.DaoImpl.OrderDaoImpl;
import com.tap.DaoImpl.OrderItemDaoImpl;
import com.tap.model.OrderItem;
import com.tap.model.Orders;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/orders")
public class OrdersController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private OrderDao orderDao;
    private OrderItemDao orderItemDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        orderItemDao = new OrderItemDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");

        if (user == null) {
            user = (User) session.getAttribute("loggedInUser");
        }

        if (user == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<Orders> orders =
                    orderDao.getOrdersByUserId(user.getUserId());

            Map<Integer, List<OrderItem>> orderItemsByOrder =
                    new HashMap<Integer, List<OrderItem>>();

            for (Orders order : orders) {
                List<OrderItem> items =
                        orderItemDao.getOrderItemsByOrderId(
                            order.getOrderId());

                orderItemsByOrder.put(order.getOrderId(), items);
            }

            request.setAttribute("orders", orders);
            request.setAttribute(
                "orderItemsByOrder", orderItemsByOrder);

            request.getRequestDispatcher("/orders.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();

            response.sendError(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                "Unable to load order history.");
        }
    }
}