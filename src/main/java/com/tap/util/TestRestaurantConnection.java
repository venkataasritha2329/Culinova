package com.tap.util;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.tap.util.DBConnection;

public class TestRestaurantConnection {
    public static void main(String[] args) {

        String sql = "SELECT restaurant_id, name FROM restaurant";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            System.out.println("Database connection successful!");

            while (rs.next()) {
                System.out.println(
                    rs.getInt("restaurant_id") + " - " +
                    rs.getString("name")
                );
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}