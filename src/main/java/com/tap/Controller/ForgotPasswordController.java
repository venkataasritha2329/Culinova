
package com.tap.Controller;

import java.io.IOException;
import java.security.SecureRandom;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.DaoImpl.UserDaoImpl;
import com.tap.model.User;
import com.tap.util.EmailUtil;

@WebServlet("/forgot-password")
public class ForgotPasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final long OTP_EXPIRY_MILLIS = 5 * 60 * 1000L;

    private UserDaoImpl userDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/forgot-password.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error",
                    "Please enter your registered email address.");

            request.getRequestDispatcher("/forgot-password.jsp")
                   .forward(request, response);
            return;
        }

        email = email.trim();

        try {
            // Check whether the email is registered.
            User user = userDao.getUserByEmail(email);

            if (user == null) {
                request.setAttribute("error",
                        "No account was found for that email address.");

                request.getRequestDispatcher("/forgot-password.jsp")
                       .forward(request, response);
                return;
            }

            // Generate a six-digit OTP.
            SecureRandom random = new SecureRandom();
            String otp = String.format("%06d",
                    random.nextInt(1_000_000));

            // Send the OTP to the registered email.
            EmailUtil.sendEmail(user.getEmail(), otp);

            // Store OTP details in the session.
            HttpSession session = request.getSession();

            session.setAttribute("passwordResetEmail", user.getEmail());
            session.setAttribute("passwordResetOtp", otp);
            session.setAttribute("passwordResetOtpExpiry",
                    System.currentTimeMillis() + OTP_EXPIRY_MILLIS);

            // Redirect after the email is sent successfully.
            response.sendRedirect(
            	    request.getContextPath() + "/verify-otp.jsp");
            	return;

        } catch (Exception e) {
            getServletContext().log(
                    "Failed to process forgot-password request.", e);

            request.setAttribute("error",
                    "Unable to send the OTP. Please try again later.");

            request.getRequestDispatcher("/forgot-password.jsp")
                   .forward(request, response);
        }
    }
}
