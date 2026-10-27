
package com.tap.DaoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.Dao.MenuDao;
import com.tap.model.Menu;
import com.tap.util.DBConnection;

public class MenuDaoImpl implements MenuDao {

    @Override
    public void addMenu(Menu menu) {

        String sql = "INSERT INTO menu "
                + "(restaurant_id, item_name, description, price, is_available, image_path) "
                + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, menu.getRestaurantId());
            ps.setString(2, menu.getItemName());
            ps.setString(3, menu.getDescription());

            if (menu.getPrice() == 0.0) {
                ps.setNull(4, java.sql.Types.DOUBLE);
            } else {
                ps.setDouble(4, menu.getPrice());
            }

            ps.setBoolean(5, menu.isAvailable());
            ps.setString(6, menu.getImagePath());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public Menu getMenu(int menuId) {

        String sql = "SELECT * FROM menu WHERE menu_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, menuId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractMenu(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public List<Menu> getAllMenus() {

        List<Menu> menus = new ArrayList<>();
        String sql = "SELECT * FROM menu";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                menus.add(extractMenu(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menus;
    }

    @Override
    public List<Menu> getMenusByRestaurantId(int restaurantId) {

        List<Menu> menus = new ArrayList<>();

        String sql = "SELECT * FROM menu WHERE restaurant_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, restaurantId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    menus.add(extractMenu(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return menus;
    }

    @Override
    public void updateMenu(Menu menu) {

        String sql = "UPDATE menu SET restaurant_id = ?, item_name = ?, "
                + "description = ?, price = ?, is_available = ?, image_path = ? "
                + "WHERE menu_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, menu.getRestaurantId());
            ps.setString(2, menu.getItemName());
            ps.setString(3, menu.getDescription());

            if (menu.getPrice() == 0.0) {
                ps.setNull(4, java.sql.Types.DOUBLE);
            } else {
                ps.setDouble(4, menu.getPrice());
            }

            ps.setBoolean(5, menu.isAvailable());
            ps.setString(6, menu.getImagePath());
            ps.setInt(7, menu.getMenuId());

            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void deleteMenu(int menuId) {

        String sql = "DELETE FROM menu WHERE menu_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, menuId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private Menu extractMenu(ResultSet rs) throws SQLException {

        Menu menu = new Menu();

        menu.setMenuId(rs.getInt("menu_id"));
        menu.setRestaurantId(rs.getInt("restaurant_id"));
        menu.setItemName(rs.getString("item_name"));
        menu.setDescription(rs.getString("description"));

        double price = rs.getDouble("price");
        if (rs.wasNull()) {
            menu.setPrice(0.0);
        } else {
            menu.setPrice(price);
        }

        menu.setAvailable(rs.getBoolean("is_available"));
        menu.setImagePath(rs.getString("image_path"));

        return menu;
    }
}
