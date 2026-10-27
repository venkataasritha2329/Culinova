package com.tap.model;

public class Cart {

    private int cartId;
    private int userId;
    private int restaurantId;
    private int menuId;
    private int quantity;
    private double totalAmount;

    public Cart() {
    }

    public Cart(int cartId, int userId, int restaurantId,
            int menuId, int quantity, double totalAmount) {
        this.cartId = cartId;
        this.userId = userId;
        this.restaurantId = restaurantId;
        this.menuId = menuId;
        this.quantity = quantity;
        this.totalAmount = totalAmount;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public int getMenuId() {
        return menuId;
    }

    public void setMenuId(int menuId) {
        this.menuId = menuId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    @Override
    public String toString() {
        return "Cart [cartId=" + cartId
                + ", userId=" + userId
                + ", restaurantId=" + restaurantId
                + ", menuId=" + menuId
                + ", quantity=" + quantity
                + ", totalAmount=" + totalAmount + "]";
    }
}