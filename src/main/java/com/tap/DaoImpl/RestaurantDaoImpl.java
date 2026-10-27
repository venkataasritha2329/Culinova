
package com.tap.DaoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.Dao.RestaurantDao;
import com.tap.model.Restaurant;
import com.tap.util.DBConnection;

public class RestaurantDaoImpl implements RestaurantDao {

    @Override
    public void addRestaurant(Restaurant restaurant) {

        String sql = "INSERT INTO restaurant "
                + "(name, cuisine_type, delivery_time, address, admin_user_id, "
                + "rating, is_active, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setString(3, restaurant.getDeliveryTime());
            ps.setString(4, restaurant.getAddress());

            if (restaurant.getAdminUserId() == 0) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, restaurant.getAdminUserId());
            }

            ps.setDouble(6, restaurant.getRating());
            ps.setBoolean(7, restaurant.isActive());
            ps.setString(8, restaurant.getImagePath());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public Restaurant getRestaurant(int restaurantId) {

        String sql = "SELECT * FROM restaurant WHERE restaurant_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractRestaurant(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Restaurant> getAllRestaurants() {
        List<Restaurant> restaurants = new ArrayList<>();

        String query = "SELECT * FROM restaurant";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(query);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Restaurant restaurant = new Restaurant();

                restaurant.setRestaurantId(rs.getInt("restaurant_id"));
                restaurant.setName(rs.getString("name"));
                restaurant.setCuisineType(rs.getString("cuisine_type"));
                restaurant.setDeliveryTime(rs.getString("delivery_time"));
                restaurant.setAddress(rs.getString("address"));
                restaurant.setAdminUserId(rs.getInt("admin_user_id"));
                restaurant.setRating(rs.getDouble("rating"));
                restaurant.setActive(rs.getBoolean("is_active"));
                restaurant.setImagePath(rs.getString("image_path"));

                restaurants.add(restaurant);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        System.out.println("Restaurants retrieved: " + restaurants.size());

        return restaurants;
    }

    @Override
    public void updateRestaurant(Restaurant restaurant) {

        String sql = "UPDATE restaurant SET name = ?, cuisine_type = ?, "
                + "delivery_time = ?, address = ?, admin_user_id = ?, "
                + "rating = ?, is_active = ?, image_path = ? "
                + "WHERE restaurant_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, restaurant.getName());
            ps.setString(2, restaurant.getCuisineType());
            ps.setString(3, restaurant.getDeliveryTime());
            ps.setString(4, restaurant.getAddress());

            if (restaurant.getAdminUserId() == 0) {
                ps.setNull(5, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, restaurant.getAdminUserId());
            }

            ps.setDouble(6, restaurant.getRating());
            ps.setBoolean(7, restaurant.isActive());
            ps.setString(8, restaurant.getImagePath());
            ps.setInt(9, restaurant.getRestaurantId());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteRestaurant(int restaurantId) {

        String sql = "DELETE FROM restaurant WHERE restaurant_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private Restaurant extractRestaurant(ResultSet rs) throws SQLException {

        Restaurant restaurant = new Restaurant();

        restaurant.setRestaurantId(rs.getInt("restaurant_id"));
        restaurant.setName(rs.getString("name"));
        restaurant.setCuisineType(rs.getString("cuisine_type"));
        restaurant.setDeliveryTime(rs.getString("delivery_time"));
        restaurant.setAddress(rs.getString("address"));

        int adminUserId = rs.getInt("admin_user_id");
        if (rs.wasNull()) {
            restaurant.setAdminUserId(0);
        } else {
            restaurant.setAdminUserId(adminUserId);
        }

        restaurant.setRating(rs.getDouble("rating"));
        restaurant.setActive(rs.getBoolean("is_active"));
        restaurant.setImagePath(rs.getString("image_path"));

        return restaurant;
    }
}
