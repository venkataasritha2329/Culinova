
package com.tap.Controller;

import java.io.IOException;
import java.util.List;

import com.tap.Dao.RestaurantDao;
import com.tap.DaoImpl.RestaurantDaoImpl;
import com.tap.model.Restaurant;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/home")
public class HomeController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RestaurantDao restaurantDao;

    @Override
    public void init() throws ServletException {
        restaurantDao = new RestaurantDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Restaurant> restaurants =
                    restaurantDao.getAllRestaurants();

            if (restaurants == null) {
                throw new ServletException(
                        "Restaurant list returned null from DAO");
            }

            System.out.println("Restaurants count: " + restaurants.size());

            request.setAttribute("restaurants", restaurants);

            request.getRequestDispatcher("/home.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            throw new ServletException(
                    "Failed to retrieve restaurant details", e);
        }
    }
}
