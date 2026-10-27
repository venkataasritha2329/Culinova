
package com.tap.Controller;

import java.io.IOException;
import java.util.List;

import com.tap.Dao.MenuDao;
import com.tap.DaoImpl.MenuDaoImpl;
import com.tap.model.Menu;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/menu")
public class MenuController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private MenuDao menuDao;

    @Override
    public void init() throws ServletException {
        menuDao = new MenuDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String restaurantIdParam =
                request.getParameter("restaurantId");

        if (restaurantIdParam == null
                || restaurantIdParam.trim().isEmpty()) {

            response.sendRedirect(
                request.getContextPath()
                + "/restaurant?view=restaurants"
            );
            return;
        }

        try {
            int restaurantId = Integer.parseInt(restaurantIdParam);

            if (restaurantId <= 0) {
                response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid restaurant ID"
                );
                return;
            }

            List<Menu> menuList =
                    menuDao.getMenusByRestaurantId(restaurantId);

            request.setAttribute("menuList", menuList);
            request.setAttribute("restaurantId", restaurantId);

            request.getRequestDispatcher("/menu.jsp")
                   .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(
                HttpServletResponse.SC_BAD_REQUEST,
                "Invalid restaurant ID"
            );
        }
    }
}
