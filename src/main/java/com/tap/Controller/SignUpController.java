
package com.tap.Controller;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.DaoImpl.UserDaoImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/signup")
public class SignUpController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDaoImpl userDao;

    @Override
    public void init() {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/signup.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String phoneText = request.getParameter("phone");
            String alternatePhoneText =
                    request.getParameter("alternatePhone");

            String password = request.getParameter("password");
            String confirmPassword =
                    request.getParameter("confirmPassword");

            String address = request.getParameter("address");
            String dobText = request.getParameter("dob");
            String landmark = request.getParameter("landmark");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String pincode = request.getParameter("pincode");
            String deliveryInstructions =
                    request.getParameter("deliveryInstructions");

            // Validate required fields
            if (isBlank(username) || isBlank(email)
                    || isBlank(phoneText) || isBlank(password)
                    || isBlank(confirmPassword) || isBlank(address)
                    || isBlank(city) || isBlank(state)
                    || isBlank(pincode)) {

                showError(request, response,
                        "Please fill in all required fields.");
                return;
            }

            // Validate email format
            if (!email.trim().matches(
                    "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {

                showError(request, response,
                        "Please enter a valid email address.");
                return;
            }

            // Validate passwords
            if (!password.equals(confirmPassword)) {
                showError(request, response,
                        "Passwords do not match.");
                return;
            }

            if (password.length() < 8) {
                showError(request, response,
                        "Password must contain at least 8 characters.");
                return;
            }

            // Validate phone numbers
            if (!phoneText.matches("[0-9]{10}")) {
                showError(request, response,
                        "Enter a valid 10-digit phone number.");
                return;
            }

            if (!isBlank(alternatePhoneText)
                    && !alternatePhoneText.matches("[0-9]{10}")) {

                showError(request, response,
                        "Enter a valid 10-digit alternate phone number.");
                return;
            }

            // Validate pincode
            if (!pincode.matches("[0-9]{6}")) {
                showError(request, response,
                        "Enter a valid 6-digit pincode.");
                return;
            }

            // Convert phone number
            long phone = Long.parseLong(phoneText);

            // Create user object
            User user = new User();

            user.setUsername(username.trim());
            user.setEmail(email.trim());
            user.setPhone(phone);

            // Store a BCrypt-hashed password
            user.setPassword(
                    BCrypt.hashpw(password, BCrypt.gensalt()));

            user.setAddress(address.trim());
            user.setLandmark(landmark);
            user.setCity(city.trim());
            user.setState(state.trim());
            user.setPincode(pincode);

            user.setAlternatePhone(
                    isBlank(alternatePhoneText)
                            ? null
                            : alternatePhoneText.trim());

            user.setDeliveryInstructions(deliveryInstructions);

            // Date is optional
            if (!isBlank(dobText)) {
                user.setDob(Date.valueOf(dobText));
            }

            // Assign the default customer role on the server
            user.setRole("customer");

            // Save user in database
            try {
                userDao.addUser(user);

                // Redirect after successful registration
                response.sendRedirect(
                        request.getContextPath()
                                + "/login?registered=true");
                return;

            } catch (SQLException e) {
                log("Failed to save signup details to database.", e);

                showError(request, response,
                        "Unable to create your account. "
                        + "The email, username, or phone number "
                        + "may already be registered.");
                return;
            }

        } catch (IllegalArgumentException e) {
            showError(request, response,
                    "Please check the entered details.");

        } catch (Exception e) {
            log("Signup failed.", e);

            showError(request, response,
                    "Signup failed. Please try again.");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private void showError(HttpServletRequest request,
                           HttpServletResponse response,
                           String message)
            throws ServletException, IOException {

        request.setAttribute("signupError", message);

        request.getRequestDispatcher("/signup.jsp")
               .forward(request, response);
    }
}
