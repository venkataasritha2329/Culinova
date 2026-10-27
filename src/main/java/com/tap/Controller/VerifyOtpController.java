
package com.tap.Controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;


import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;

@WebServlet("/verify-otp")
public class VerifyOtpController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null
                || session.getAttribute("passwordResetEmail") == null
                || session.getAttribute("passwordResetOtp") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/forgot-password.jsp");
            return;
        }

        request.getRequestDispatcher("/verify-otp.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String enteredOtp = request.getParameter("otp");
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect(
                    request.getContextPath() + "/forgot-password.jsp");
            return;
        }

        String storedOtp =
                (String) session.getAttribute("passwordResetOtp");

        Long expiryTime =
                (Long) session.getAttribute("passwordResetOtpExpiry");

        String email =
                (String) session.getAttribute("passwordResetEmail");

        if (storedOtp == null || expiryTime == null || email == null) {
            session.removeAttribute("passwordResetOtp");
            session.removeAttribute("passwordResetOtpExpiry");

            response.sendRedirect(
                    request.getContextPath() + "/forgot-password.jsp");
            return;
        }

        if (System.currentTimeMillis() > expiryTime) {
            session.removeAttribute("passwordResetOtp");
            session.removeAttribute("passwordResetOtpExpiry");

            request.setAttribute("error",
                    "Your OTP has expired. Please request a new one.");

            request.getRequestDispatcher("/forgot-password.jsp")
                   .forward(request, response);
            return;
        }

        if (enteredOtp == null || !storedOtp.equals(enteredOtp.trim())) {
            request.setAttribute("error",
                    "Invalid OTP. Please enter the correct six-digit OTP.");

            request.getRequestDispatcher("/verify-otp.jsp")
                   .forward(request, response);
            return;
        }

        // OTP is correct and has not expired.
        session.setAttribute("passwordResetVerified", Boolean.TRUE);

        // Prevent the same OTP from being reused.
        session.removeAttribute("passwordResetOtp");
        session.removeAttribute("passwordResetOtpExpiry");

        response.sendRedirect(
                request.getContextPath() + "/reset-password.jsp");
    }
}
