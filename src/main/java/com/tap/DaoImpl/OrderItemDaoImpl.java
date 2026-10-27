
package com.tap.DaoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.Dao.OrderItemDao;
import com.tap.model.OrderItem;
import com.tap.util.DBConnection;

public class OrderItemDaoImpl implements OrderItemDao {

    @Override
    public void addOrderItem(OrderItem orderItem) {

        String sql = "INSERT INTO orderitem "
                + "(order_id, menu_id, total_amount) "
                + "VALUES (?, ?, ?)";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderItem.getOrderId());
            ps.setInt(2, orderItem.getMenuId());
            ps.setDouble(3, orderItem.getTotalAmount());

            int rows = ps.executeUpdate();

            if (rows == 0) {
                throw new SQLException("Order item was not inserted.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error while adding order item.", e);
        }
    }

    @Override
    public OrderItem getOrderItem(int orderItemId) {

        String sql = "SELECT * FROM orderitem WHERE order_item_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderItemId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractOrderItem(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                "Error while retrieving order item.", e
            );
        }

        return null;
    }

    @Override
    public List<OrderItem> getAllOrderItems() {

        List<OrderItem> orderItems = new ArrayList<>();

        String sql = "SELECT * FROM orderitem "
                   + "ORDER BY order_item_id DESC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                orderItems.add(extractOrderItem(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                "Error while retrieving order items.", e
            );
        }

        return orderItems;
    }

    @Override
    public List<OrderItem> getOrderItemsByOrderId(int orderId) {

        List<OrderItem> orderItems = new ArrayList<>();

        String sql = "SELECT * FROM orderitem "
                   + "WHERE order_id = ? "
                   + "ORDER BY order_item_id ASC";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orderItems.add(extractOrderItem(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                "Error while retrieving items for order ID: " + orderId, e
            );
        }

        return orderItems;
    }

    @Override
    public void updateOrderItem(OrderItem orderItem) {

        String sql = "UPDATE orderitem "
                   + "SET order_id = ?, menu_id = ?, total_amount = ? "
                   + "WHERE order_item_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderItem.getOrderId());
            ps.setInt(2, orderItem.getMenuId());
            ps.setDouble(3, orderItem.getTotalAmount());
            ps.setInt(4, orderItem.getOrderItemId());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                "Error while updating order item.", e
            );
        }
    }

    @Override
    public void deleteOrderItem(int orderItemId) {

        String sql = "DELETE FROM orderitem WHERE order_item_id = ?";

        try (
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, orderItemId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(
                "Error while deleting order item.", e
            );
        }
    }

    private OrderItem extractOrderItem(ResultSet rs)
            throws SQLException {

        OrderItem orderItem = new OrderItem();

        orderItem.setOrderItemId(rs.getInt("order_item_id"));
        orderItem.setOrderId(rs.getInt("order_id"));
        orderItem.setMenuId(rs.getInt("menu_id"));
        orderItem.setTotalAmount(rs.getDouble("total_amount"));

        return orderItem;
    }
}
