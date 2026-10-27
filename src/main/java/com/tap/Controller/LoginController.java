
package com.tap.Controller;

import java.io.IOException;

import com.tap.Dao.UserDao;
import com.tap.DaoImpl.UserDaoImpl;
import com.tap.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginController extends HttpServlet {

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

        String contextPath = request.getContextPath();
        String redirect = request.getParameter("redirect");

        HttpSession session = request.getSession(false);

        if (session != null
                && session.getAttribute("user") instanceof User) {

            User user = (User) session.getAttribute("user");

            if ("admin".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(contextPath + "/admin");
            } else if ("checkout".equals(redirect)) {
                response.sendRedirect(contextPath + "/checkout");
            } else {
                response.sendRedirect(contextPath + "/home");
            }

            return;
        }

        request.getRequestDispatcher("/login.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String identifier = request.getParameter("identifier");
        String password = request.getParameter("password");
        String redirect = request.getParameter("redirect");

        String contextPath = request.getContextPath();

        boolean checkoutRequested = "checkout".equals(redirect);

        String redirectParameter =
                checkoutRequested ? "&redirect=checkout" : "";

        if (identifier == null || identifier.trim().isEmpty()
                || password == null || password.isEmpty()) {

            response.sendRedirect(contextPath
                    + "/login?error=empty" + redirectParameter);
            return;
        }

        identifier = identifier.trim();

        try {
            User user = userDao.getUserByEmailOrPhone(identifier);

            if (user == null) {
                user = userDao.getUserByUsername(identifier);
            }

            if (user == null || user.getPassword() == null) {
                response.sendRedirect(contextPath
                        + "/login?error=invalid" + redirectParameter);
                return;
            }

            if (!org.mindrot.jbcrypt.BCrypt.checkpw(
                    password, user.getPassword())) {

                response.sendRedirect(contextPath
                        + "/login?error=invalid" + redirectParameter);
                return;
            }

            HttpSession session = request.getSession(true);

            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("role", user.getRole());

            if ("admin".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(contextPath + "/admin");
                return;
            }

            if (checkoutRequested) {
                response.sendRedirect(contextPath + "/checkout");
                return;
            }

            response.sendRedirect(contextPath + "/cart");

        } catch (Exception e) {
            log("Error during login", e);

            response.sendRedirect(contextPath
                    + "/login?error=true" + redirectParameter);
        }
    }
}
