
package com.tap.Controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.tap.util.DBConnection;

@WebServlet("/reset-password")
public class ResetPasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(
                request.getContextPath() + "/reset-password.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String ctx = request.getContextPath();
        HttpSession session = request.getSession(false);

        if (session == null
                || !Boolean.TRUE.equals(
                        session.getAttribute("passwordResetVerified"))) {

            response.sendRedirect(ctx + "/forgot-password.jsp");
            return;
        }

        String email = (String) session.getAttribute("passwordResetEmail");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (email == null || password == null || confirmPassword == null
                || password.length() < 8) {

            request.setAttribute("error",
                    "Enter a password containing at least 8 characters.");
            request.getRequestDispatcher("/reset-password.jsp")
                   .forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/reset-password.jsp")
                   .forward(request, response);
            return;
        }

        String hashedPassword = BCrypt.hashpw(
                password, BCrypt.gensalt());

        String sql = "UPDATE user SET password = ? WHERE email = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, hashedPassword);
            ps.setString(2, email);

            int rowsUpdated = ps.executeUpdate();

            if (rowsUpdated > 0) {
                session.removeAttribute("passwordResetVerified");
                session.removeAttribute("passwordResetEmail");
                session.removeAttribute("passwordResetOtp");
                session.removeAttribute("passwordResetOtpExpiry");

                session.setAttribute("passwordResetSuccess",
                        "Password updated successfully. Please log in.");

                response.sendRedirect(ctx + "/login.jsp");
            } else {
                request.setAttribute("error",
                        "Unable to update the password. Please try again.");
                request.getRequestDispatcher("/reset-password.jsp")
                       .forward(request, response);
            }

        } catch (Exception e) {
            getServletContext().log("Password reset failed.", e);
            request.setAttribute("error",
                    "An error occurred while updating your password.");
            request.getRequestDispatcher("/reset-password.jsp")
                   .forward(request, response);
        }
    }
}
