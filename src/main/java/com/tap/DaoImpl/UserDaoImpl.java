
package com.tap.DaoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

import com.tap.Dao.UserDao;
import com.tap.model.User;
import com.tap.util.DBConnection;

public class UserDaoImpl implements UserDao {

    @Override
    public void addUser(User user) throws SQLException {

        String sql = "INSERT INTO user "
                + "(username, password, email, phone, address, role, landmark, city, state, "
                + "pincode, dob, alternate_phone, delivery_instructions) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getEmail());
            ps.setLong(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getRole());
            ps.setString(7, user.getLandmark());
            ps.setString(8, user.getCity());
            ps.setString(9, user.getState());
            ps.setString(10, user.getPincode());

            if (user.getDob() == null) {
                ps.setNull(11, Types.DATE);
            } else {
                ps.setDate(11, user.getDob());
            }

            ps.setString(12, user.getAlternatePhone());
            ps.setString(13, user.getDeliveryInstructions());

            int rowsInserted = ps.executeUpdate();

            if (rowsInserted != 1) {
                throw new SQLException("User registration was not successful.");
            }
        }
    }

    @Override
    public User getUserById(int userId) {

        String sql = "SELECT * FROM user WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public User getUserByEmail(String email) {

        String sql = "SELECT * FROM user WHERE email = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public User getUserByUsername(String username) {

        String sql = "SELECT * FROM user WHERE username = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public User getUserByEmailOrPhone(String login) {

        String sql = "SELECT * FROM user WHERE email = ? OR phone = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, login);

            try {
                ps.setLong(2, Long.parseLong(login));
            } catch (NumberFormatException e) {
                ps.setLong(2, -1L);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractUser(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean updateUser(User user) throws SQLException {

        String sql = "UPDATE user SET username=?, email=?, phone=?, address=?, role=?, "
                + "landmark=?, city=?, state=?, pincode=?, dob=?, alternate_phone=?, "
                + "delivery_instructions=? WHERE user_id=?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setLong(3, user.getPhone());
            ps.setString(4, user.getAddress());
            ps.setString(5, user.getRole());
            ps.setString(6, user.getLandmark());
            ps.setString(7, user.getCity());
            ps.setString(8, user.getState());
            ps.setString(9, user.getPincode());

            if (user.getDob() == null) {
                ps.setNull(10, Types.DATE);
            } else {
                ps.setDate(10, user.getDob());
            }

            ps.setString(11, user.getAlternatePhone());
            ps.setString(12, user.getDeliveryInstructions());
            ps.setInt(13, user.getUserId());

            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public void deleteUser(int userId) {

        String sql = "DELETE FROM user WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    

@Override
public boolean updatePasswordByUserId(int userId, String newPassword)
        throws SQLException {

    String sql = "UPDATE users SET password = ? WHERE user_id = ?";

    try (java.sql.Connection con =
                 com.tap.util.DBConnection.getConnection();
         java.sql.PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, newPassword);
        ps.setInt(2, userId);

        return ps.executeUpdate() == 1;
    }
}


    private User extractUser(ResultSet rs) throws SQLException {

        User user = new User();

        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getLong("phone"));
        user.setAddress(rs.getString("address"));
        user.setRole(rs.getString("role"));
        user.setLandmark(rs.getString("landmark"));
        user.setCity(rs.getString("city"));
        user.setState(rs.getString("state"));
        user.setPincode(rs.getString("pincode"));
        user.setDob(rs.getDate("dob"));
        user.setAlternatePhone(rs.getString("alternate_phone"));
        user.setDeliveryInstructions(rs.getString("delivery_instructions"));

        return user;
    }
}
