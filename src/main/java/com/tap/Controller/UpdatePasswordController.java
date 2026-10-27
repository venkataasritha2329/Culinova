
package com.tap.Controller;

import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

import com.tap.Dao.UserDao;
import com.tap.DaoImpl.UserDaoImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/create-password")
public class UpdatePasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UserDao userDao;

    @Override
    public void init() throws ServletException {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
            request.getContextPath() + "/create-password.jsp"
        );
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        String contextPath = request.getContextPath();

        HttpSession session = request.getSession(false);

        // Check whether the user has an active password-reset session.
        if (session == null) {
            response.sendRedirect(
                contextPath + "/forgot-password.jsp?error=expired"
            );
            return;
        }

        Object verifiedObject = session.getAttribute("resetOtpVerified");
        Object userIdObject = session.getAttribute("resetUserId");
        Object expiryObject = session.getAttribute("resetOtpExpiry");

        boolean otpVerified =
            Boolean.TRUE.equals(verifiedObject);

        // The OTP must have been verified before changing the password.
        if (!otpVerified || !(userIdObject instanceof Number)) {
            response.sendRedirect(
                contextPath + "/forgot-password.jsp?error=expired"
            );
            return;
        }

        // Check the reset session expiry.
        if (!(expiryObject instanceof Number)
                || ((Number) expiryObject).longValue()
                    <= System.currentTimeMillis()) {

            clearResetSession(session);

            response.sendRedirect(
                contextPath + "/forgot-password.jsp?error=expired"
            );
            return;
        }

        int userId = ((Number) userIdObject).intValue();

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Check for missing values.
        if (password == null || confirmPassword == null
                || password.trim().isEmpty()
                || confirmPassword.isEmpty()) {

            response.sendRedirect(
                contextPath + "/create-password.jsp?error=invalid"
            );
            return;
        }

        // Check password length.
        if (password.length() < 8 || password.length() > 72) {
            response.sendRedirect(
                contextPath + "/create-password.jsp?error=invalid"
            );
            return;
        }

        // Both password fields must match.
        if (!password.equals(confirmPassword)) {
            response.sendRedirect(
                contextPath + "/create-password.jsp?error=mismatch"
            );
            return;
        }

        try {
            // Hash the password before saving it in the database.
            String hashedPassword =
                BCrypt.hashpw(password, BCrypt.gensalt(12));

            boolean updated = userDao.updatePasswordByUserId(
                userId,
                hashedPassword
            );

            if (updated) {

                // Clear reset-related session data after success.
                clearResetSession(session);

                response.sendRedirect(
                    contextPath + "/login?passwordUpdated=success"
                );

            } else {

                response.sendRedirect(
                    contextPath + "/create-password.jsp?error=failed"
                );
            }

        } catch (Exception e) {

            log("Unable to update the user's password.", e);

            response.sendRedirect(
                contextPath + "/create-password.jsp?error=failed"
            );
        }
    }

    private void clearResetSession(HttpSession session) {
        session.removeAttribute("resetUserId");
        session.removeAttribute("resetOtpHash");
        session.removeAttribute("resetOtpExpiry");
        session.removeAttribute("resetOtpAttempts");
        session.removeAttribute("resetOtpVerified");
    }
}
