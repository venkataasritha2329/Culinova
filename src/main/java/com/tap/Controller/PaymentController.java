
package com.tap.Controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/payment")
public class PaymentController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
            session.getAttribute("paymentAmount") == null) {

            response.sendRedirect(
                request.getContextPath() + "/checkout.jsp"
            );
            return;
        }

        double paymentAmount;

        try {
            paymentAmount = Double.parseDouble(
                session.getAttribute("paymentAmount").toString()
            );
        } catch (NumberFormatException e) {
            response.sendRedirect(
                request.getContextPath() + "/checkout.jsp"
            );
            return;
        }

        if (!Double.isFinite(paymentAmount) || paymentAmount <= 0) {
            response.sendRedirect(
                request.getContextPath() + "/checkout.jsp"
            );
            return;
        }

        request.getRequestDispatcher("/payment.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
