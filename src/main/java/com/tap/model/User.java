package com.tap.model;

import java.sql.Date;

public class User {

    private int userId;
    private String username;
    private String password;
    private String email;
    private long phone;
    private String address;
    private String role;
    private String landmark;
    private String city;
    private String state;
    private String pincode;
    private Date dob;
    private String alternatePhone;
    private String deliveryInstructions;

    public User() {
    }

    public User(int userId, String username, String password, String email, long phone,
                String address, String role, String landmark, String city, String state,
                String pincode, Date dob, String alternatePhone, String deliveryInstructions) {

        this.userId = userId;
        this.username = username;
        this.password = password;
        this.email = email;
        this.phone = phone;
        this.address = address;
        this.role = role;
        this.landmark = landmark;
        this.city = city;
        this.state = state;
        this.pincode = pincode;
        this.dob = dob;
        this.alternatePhone = alternatePhone;
        this.deliveryInstructions = deliveryInstructions;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public long getPhone() {
        return phone;
    }

    public void setPhone(long phone) {
        this.phone = phone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getLandmark() {
        return landmark;
    }

    public void setLandmark(String landmark) {
        this.landmark = landmark;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPincode() {
        return pincode;
    }

    public void setPincode(String pincode) {
        this.pincode = pincode;
    }

    public Date getDob() {
        return dob;
    }

    public void setDob(Date dob) {
        this.dob = dob;
    }

    public String getAlternatePhone() {
        return alternatePhone;
    }

    public void setAlternatePhone(String alternatePhone) {
        this.alternatePhone = alternatePhone;
    }

    public String getDeliveryInstructions() {
        return deliveryInstructions;
    }

    public void setDeliveryInstructions(String deliveryInstructions) {
        this.deliveryInstructions = deliveryInstructions;
    }

    @Override
    public String toString() {
        return "User [userId=" + userId +
                ", username=" + username +
                ", email=" + email +
                ", phone=" + phone +
                ", address=" + address +
                ", role=" + role +
                ", landmark=" + landmark +
                ", city=" + city +
                ", state=" + state +
                ", pincode=" + pincode +
                ", dob=" + dob +
                ", alternatePhone=" + alternatePhone +
                ", deliveryInstructions=" + deliveryInstructions + "]";
    }
}