
package com.tap.util;

import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.http.HttpSession;

public class OtpUtil {

    private OtpUtil() {
        // Prevent object creation.
    }

    public static boolean verifyOtp(HttpSession session, String enteredOtp) {

        if (session == null || enteredOtp == null
                || enteredOtp.trim().isEmpty()) {
            return false;
        }

        Object otpHashObject = session.getAttribute("resetOtpHash");
        Object expiryObject = session.getAttribute("resetOtpExpiry");
        Object attemptsObject = session.getAttribute("resetOtpAttempts");

        if (!(otpHashObject instanceof String)
                || !(expiryObject instanceof Number)) {
            return false;
        }

        String storedOtpHash = (String) otpHashObject;
        long expiryTime = ((Number) expiryObject).longValue();

        int attempts = attemptsObject instanceof Number
                ? ((Number) attemptsObject).intValue()
                : 0;

        // Allow a maximum of 5 verification attempts.
        if (attempts >= 5) {
            clearOtpData(session);
            return false;
        }

        // Reject an expired OTP.
        if (System.currentTimeMillis() >= expiryTime) {
            clearOtpData(session);
            return false;
        }

        // Count this verification attempt.
        session.setAttribute("resetOtpAttempts", attempts + 1);

        try {
            if (!BCrypt.checkpw(enteredOtp.trim(), storedOtpHash)) {
                return false;
            }
        } catch (IllegalArgumentException e) {
            clearOtpData(session);
            return false;
        }

        // Mark the OTP as verified.
        session.setAttribute("resetOtpVerified", Boolean.TRUE);

        // Prevent reuse of the OTP.
        session.removeAttribute("resetOtpHash");
        session.removeAttribute("resetOtpAttempts");

        return true;
    }

    private static void clearOtpData(HttpSession session) {
        session.removeAttribute("resetOtpHash");
        session.removeAttribute("resetOtpExpiry");
        session.removeAttribute("resetOtpAttempts");
        session.removeAttribute("resetOtpVerified");
    }
}
