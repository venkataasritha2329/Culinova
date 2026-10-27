
package com.tap.Dao;

import java.sql.SQLException;
import com.tap.model.User;

public interface UserDao {

    void addUser(User user) throws SQLException;

    User getUserById(int userId);

    User getUserByEmail(String email);

    User getUserByUsername(String username);

    User getUserByEmailOrPhone(String login);

    boolean updateUser(User user) throws SQLException;

    
    boolean updatePasswordByUserId(int userId, String newPassword)
            throws SQLException;

    
    void deleteUser(int userId);
}
