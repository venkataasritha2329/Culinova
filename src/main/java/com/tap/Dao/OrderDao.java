package com.tap.Dao;

import java.util.List;
import com.tap.model.Orders;

public interface OrderDao {

    void addOrder(Orders order);

    Orders getOrder(int orderId);

    List<Orders> getAllOrders();

    List<Orders> getOrdersByUserId(int userId);

    void updateOrder(Orders order);

    void deleteOrder(int orderId);
}