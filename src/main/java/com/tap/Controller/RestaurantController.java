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

@WebServlet("/restaurant")
public class RestaurantController extends HttpServlet {

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

        List<Restaurant> restaurants = restaurantDao.getAllRestaurants();

        request.setAttribute("restaurants", restaurants);

        request.getRequestDispatcher("/restaurant.jsp")
               .forward(request, response);
    }
}