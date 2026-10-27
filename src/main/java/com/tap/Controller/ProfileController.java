
package com.tap.Controller;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

import com.tap.Dao.UserDao;
import com.tap.DaoImpl.UserDaoImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");
        User user = userDao.getUserById(sessionUser.getUserId());

        if (user == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Keep the session synchronized with the latest database details.
        session.setAttribute("user", user);
        request.setAttribute("user", user);

        if ("true".equals(request.getParameter("updated"))) {
            request.setAttribute("profileMessage",
                    "Your profile has been updated successfully.");
        }

        request.getRequestDispatcher("/profile.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) session.getAttribute("user");

        // Always reload the persisted user; do not trust a submitted user ID.
        User user = userDao.getUserById(sessionUser.getUserId());

        if (user == null) {
            session.invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            String username = value(request, "username");
            String email = value(request, "email");
            String phoneText = value(request, "phone");
            String alternatePhone = value(request, "alternatePhone");
            String dobText = value(request, "dob");
            String address = value(request, "address");
            String landmark = value(request, "landmark");
            String city = value(request, "city");
            String state = value(request, "state");
            String pincode = value(request, "pincode");
            String instructions = value(request, "deliveryInstructions");

            if (username.isEmpty() || email.isEmpty() || phoneText.isEmpty()
                    || address.isEmpty() || city.isEmpty()
                    || state.isEmpty() || pincode.isEmpty()) {
                throw new IllegalArgumentException(
                        "Please complete all required fields.");
            }

            if (username.length() > 100 || email.length() > 150
                    || address.length() > 500 || landmark.length() > 150
                    || city.length() > 100 || state.length() > 100
                    || pincode.length() > 10 || instructions.length() > 500
                    || alternatePhone.length() > 20) {
                throw new IllegalArgumentException(
                        "One or more fields exceed the allowed length.");
            }

            if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                throw new IllegalArgumentException(
                        "Please enter a valid email address.");
            }

            if (!phoneText.matches("^[0-9]{7,15}$")) {
                throw new IllegalArgumentException(
                        "Enter a phone number containing 7 to 15 digits.");
            }

            if (!alternatePhone.isEmpty()
                    && !alternatePhone.matches("^[0-9+() -]{7,20}$")) {
                throw new IllegalArgumentException(
                        "Please enter a valid alternate phone number.");
            }

            if (!pincode.matches("^[A-Za-z0-9 -]{3,10}$")) {
                throw new IllegalArgumentException(
                        "Please enter a valid PIN code.");
            }

            long phone;
            try {
                phone = Long.parseLong(phoneText);
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(
                        "Please enter a valid phone number.");
            }

            Date dob = null;

            if (!dobText.isEmpty()) {
                try {
                    dob = Date.valueOf(dobText);
                } catch (IllegalArgumentException e) {
                    throw new IllegalArgumentException(
                            "Please enter a valid date of birth.");
                }

                if (dob.after(new Date(System.currentTimeMillis()))) {
                    throw new IllegalArgumentException(
                            "Date of birth cannot be in the future.");
                }
            }

            user.setUsername(username);
            user.setEmail(email);
            user.setPhone(phone);
            user.setAlternatePhone(emptyToNull(alternatePhone));
            user.setDob(dob);
            user.setAddress(address);
            user.setLandmark(emptyToNull(landmark));
            user.setCity(city);
            user.setState(state);
            user.setPincode(pincode);
            user.setDeliveryInstructions(emptyToNull(instructions));

            // Preserve the database user's ID, password and role.
            boolean updated = userDao.updateUser(user);

            if (!updated) {
                showError(request, response, user,
                        "No profile changes were saved. Please try again.");
                return;
            }

            session.setAttribute("user", user);

            response.sendRedirect(request.getContextPath()
                    + "/profile?updated=true");

        } catch (IllegalArgumentException e) {
            showError(request, response, user, e.getMessage());

        } catch (SQLException e) {
            log("Could not update user profile", e);

            if ("23000".equals(e.getSQLState())) {
                showError(request, response, user,
                        "That email or another unique value is already in use.");
            } else {
                showError(request, response, user,
                        "Database error while saving your profile. Please try again.");
            }
        }
    }

    private String value(HttpServletRequest request, String name) {
        String result = request.getParameter(name);
        return result == null ? "" : result.trim();
    }

    private String emptyToNull(String value) {
        return value == null || value.trim().isEmpty()
                ? null : value.trim();
    }

    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           User user,
                           String message)
            throws ServletException, IOException {

        request.setAttribute("user", user);
        request.setAttribute("profileError", message);
        request.getRequestDispatcher("/profile.jsp")
               .forward(request, response);
    }
}
