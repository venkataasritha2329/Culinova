
package com.tap.model;

public class Restaurant {

    private int restaurantId;
    private String name;
    private String cuisineType;
    private String deliveryTime;
    private String address;
    private int adminUserId;
    private double rating;
    private boolean isActive;
    private String imagePath;

    public Restaurant() {
    }

    public Restaurant(int restaurantId, String name, String cuisineType,
            String deliveryTime, String address, int adminUserId,
            double rating, boolean isActive, String imagePath) {

        this.restaurantId = restaurantId;
        this.name = name;
        this.cuisineType = cuisineType;
        this.deliveryTime = deliveryTime;
        this.address = address;
        this.adminUserId = adminUserId;
        this.rating = rating;
        this.isActive = isActive;
        this.imagePath = imagePath;
    }

    public int getRestaurantId() {
        return restaurantId;
    }

    public void setRestaurantId(int restaurantId) {
        this.restaurantId = restaurantId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCuisineType() {
        return cuisineType;
    }

    public void setCuisineType(String cuisineType) {
        this.cuisineType = cuisineType;
    }

    public String getDeliveryTime() {
        return deliveryTime;
    }

    public void setDeliveryTime(String deliveryTime) {
        this.deliveryTime = deliveryTime;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getAdminUserId() {
        return adminUserId;
    }

    public void setAdminUserId(int adminUserId) {
        this.adminUserId = adminUserId;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        this.isActive = active;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    @Override
    public String toString() {
        return "Restaurant [restaurantId=" + restaurantId
                + ", name=" + name
                + ", cuisineType=" + cuisineType
                + ", deliveryTime=" + deliveryTime
                + ", address=" + address
                + ", adminUserId=" + adminUserId
                + ", rating=" + rating
                + ", isActive=" + isActive
                + ", imagePath=" + imagePath + "]";
    }
}
