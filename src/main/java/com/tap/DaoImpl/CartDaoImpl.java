package com.tap.DaoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.Dao.CartDao;
import com.tap.model.Cart;
import com.tap.util.DBConnection;

public class CartDaoImpl implements CartDao {

    @Override
    public void addCart(Cart cart) {
        String sql = "INSERT INTO cart (user_id, restaurant_id, menu_id, quantity, total_amount) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cart.getUserId());
            ps.setInt(2, cart.getRestaurantId());
            ps.setInt(3, cart.getMenuId());
            ps.setInt(4, cart.getQuantity());
            ps.setDouble(5, cart.getTotalAmount());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public Cart getCart(int cartId) {
        String sql = "SELECT * FROM cart WHERE cart_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cartId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractCart(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Cart> getAllCarts() {
        List<Cart> carts = new ArrayList<>();
        String sql = "SELECT * FROM cart";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                carts.add(extractCart(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return carts;
    }

    @Override
    public List<Cart> getCartsByUserId(int userId) {
        List<Cart> carts = new ArrayList<>();
        String sql = "SELECT * FROM cart WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    carts.add(extractCart(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return carts;
    }

    @Override
    public void updateCart(Cart cart) {
        String sql = "UPDATE cart SET user_id = ?, restaurant_id = ?, menu_id = ?, "
                   + "quantity = ?, total_amount = ? WHERE cart_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cart.getUserId());
            ps.setInt(2, cart.getRestaurantId());
            ps.setInt(3, cart.getMenuId());
            ps.setInt(4, cart.getQuantity());
            ps.setDouble(5, cart.getTotalAmount());
            ps.setInt(6, cart.getCartId());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteCart(int cartId) {
        String sql = "DELETE FROM cart WHERE cart_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cartId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private Cart extractCart(ResultSet rs) throws SQLException {
        Cart cart = new Cart();

        cart.setCartId(rs.getInt("cart_id"));
        cart.setUserId(rs.getInt("user_id"));
        cart.setRestaurantId(rs.getInt("restaurant_id"));
        cart.setMenuId(rs.getInt("menu_id"));
        cart.setQuantity(rs.getInt("quantity"));
        cart.setTotalAmount(rs.getDouble("total_amount"));

        return cart;
    }
}