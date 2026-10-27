
package com.tap.Controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/logout")
public class LogOutController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        String referer = request.getHeader("Referer");
        String contextPath = request.getContextPath();

        HttpSession session = request.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        // Return to the page where Logout was clicked.
        if (referer != null && referer.startsWith(
                request.getScheme() + "://" + request.getServerName())) {

            response.sendRedirect(referer);
        } else {
            response.sendRedirect(contextPath + "/");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}
