package com.tap.model;

public class OrderItem {

    private int orderItemId;
    private int orderId;
    private int menuId;
    private double totalAmount;

    public OrderItem() {
    }

    public OrderItem(int orderItemId, int orderId, int menuId, double totalAmount) {
        this.orderItemId = orderItemId;
        this.orderId = orderId;
        this.menuId = menuId;
        this.totalAmount = totalAmount;
    }

    public int getOrderItemId() {
        return orderItemId;
    }

    public void setOrderItemId(int orderItemId) {
        this.orderItemId = orderItemId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getMenuId() {
        return menuId;
    }

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    @Override
    public String toString() {
        return "OrderItem [orderItemId=" + orderItemId
                + ", orderId=" + orderId
                + ", menuId=" + menuId
                + ", totalAmount=" + totalAmount + "]";
    }
}