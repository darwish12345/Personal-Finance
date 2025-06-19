package controller;

import dao.UserDAO;
import model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class UserController extends HttpServlet {
    private UserDAO userDao;
    
    @Override
    public void init() {
        userDao = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("register".equals(action)) {
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            
            if (userDao.isUsernameTaken(username)) {
                request.setAttribute("error", "Username already taken");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            if (userDao.isEmailTaken(email)) {
                request.setAttribute("error", "Email already registered");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            User user = new User(username, password, email);
            if (userDao.registerUser(user)) {
                request.setAttribute("success", "Registration successful! Please login.");
                request.getRequestDispatcher("index.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Registration failed. Please try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
        }
    }
}
