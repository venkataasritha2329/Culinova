
package com.tap.DaoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.tap.Dao.OrderDao;
import com.tap.model.Orders;
import com.tap.util.DBConnection;

public class OrderDaoImpl implements OrderDao {

    @Override
    public void addOrder(Orders order) {

        String sql = "INSERT INTO orders "
                + "(user_id, restaurant_id, order_date, total_amount, status, payment_mode) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                sql, Statement.RETURN_GENERATED_KEYS
            )
        ) {
            ps.setInt(1, order.getUserId());
            ps.setInt(2, order.getRestaurantId());
            ps.setDate(3, order.getOrderDate());
            ps.setDouble(4, order.getTotalAmount());
            ps.setString(5, order.getStatus());
            ps.setString(6, order.getPaymentMode());

            int rows = ps.executeUpdate();

            if (rows == 0) {
                throw new SQLException("Order was not inserted.");
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    order.setOrderId(rs.getInt(1));
                } else {
                    throw new SQLException("Order ID was not generated.");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error while adding order.", e);
        }
    }

    @Override
    public Orders getOrder(int orderId) {

        String sql = "SELECT * FROM orders WHERE order_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractOrder(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error while retrieving order.", e);
        }

        return null;
    }

    @Override
    public List<Orders> getAllOrders() {

        List<Orders> orders = new ArrayList<>();

        String sql = "SELECT * FROM orders ORDER BY order_date DESC, order_id DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                orders.add(extractOrder(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error while retrieving all orders.", e);
        }

        return orders;
    }

    @Override
    public List<Orders> getOrdersByUserId(int userId) {

        List<Orders> orders = new ArrayList<>();

        String sql = "SELECT * FROM orders "
                + "WHERE user_id = ? "
                + "ORDER BY order_date DESC, order_id DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(extractOrder(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error while retrieving user orders.", e);
        }

        return orders;
    }

    @Override
    public void updateOrder(Orders order) {

        String sql = "UPDATE orders SET "
                + "user_id = ?, "
                + "restaurant_id = ?, "
                + "order_date = ?, "
                + "total_amount = ?, "
                + "status = ?, "
                + "payment_mode = ? "
                + "WHERE order_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, order.getUserId());
            ps.setInt(2, order.getRestaurantId());
            ps.setDate(3, order.getOrderDate());
            ps.setDouble(4, order.getTotalAmount());
            ps.setString(5, order.getStatus());
            ps.setString(6, order.getPaymentMode());
            ps.setInt(7, order.getOrderId());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error while updating order.", e);
        }
    }

    @Override
    public void deleteOrder(int orderId) {

        String sql = "DELETE FROM orders WHERE order_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error while deleting order.", e);
        }
    }

    private Orders extractOrder(ResultSet rs) throws SQLException {

        Orders order = new Orders();

        order.setOrderId(rs.getInt("order_id"));
        order.setUserId(rs.getInt("user_id"));
        order.setRestaurantId(rs.getInt("restaurant_id"));
        order.setOrderDate(rs.getDate("order_date"));
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setStatus(rs.getString("status"));
        order.setPaymentMode(rs.getString("payment_mode"));

        return order;
    }
}
