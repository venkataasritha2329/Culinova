
package com.tap.Dao;

import java.util.List;
import com.tap.model.Restaurant;

public interface RestaurantDao {

    void addRestaurant(Restaurant restaurant);

    Restaurant getRestaurant(int restaurantId);

    List<Restaurant> getAllRestaurants();

    void updateRestaurant(Restaurant restaurant);

    void deleteRestaurant(int restaurantId);
}
