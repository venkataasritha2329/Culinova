package com.tap.Dao;

import java.util.List;
import com.tap.model.OrderItem;

public interface OrderItemDao {

    void addOrderItem(OrderItem orderItem);

    OrderItem getOrderItem(int orderItemId);

    List<OrderItem> getAllOrderItems();

    List<OrderItem> getOrderItemsByOrderId(int orderId);

    void updateOrderItem(OrderItem orderItem);

    void deleteOrderItem(int orderItemId);
}