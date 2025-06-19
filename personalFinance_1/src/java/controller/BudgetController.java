package controller;

import dao.BudgetDAO;
import model.Budget;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

public class BudgetController extends HttpServlet {
    private BudgetDAO budgetDao;
    
    @Override
    public void init() {
        budgetDao = new BudgetDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("add".equals(action)) {
            String category = request.getParameter("category");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String monthYear = new SimpleDateFormat("MM-yyyy").format(new Date());
            
            Budget budget = new Budget(user.getUserId(), category, amount, monthYear);
            if (budgetDao.addBudget(budget)) {
                response.sendRedirect("BudgetController?success=Budget added successfully");
            } else {
                response.sendRedirect("BudgetController?error=Failed to add budget");
            }
        } else if ("update".equals(action)) {
            int budgetId = Integer.parseInt(request.getParameter("budgetId"));
            String category = request.getParameter("category");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String monthYear = request.getParameter("monthYear");
            
            Budget budget = new Budget();
            budget.setBudgetId(budgetId);
            budget.setUserId(user.getUserId()); 
            budget.setCategory(category);
            budget.setAmount(amount);
            budget.setMonthYear(monthYear);
            
            if (budgetDao.updateBudget(budget)) {
                response.sendRedirect("BudgetController?success=Budget updated successfully");
            } else {
                response.sendRedirect("BudgetController?error=Failed to update budget");
            }
        } else if ("delete".equals(action)) {
            int budgetId = Integer.parseInt(request.getParameter("budgetId"));
            
            Budget budget = budgetDao.getBudgetById(budgetId);
            if (budget != null && budget.getUserId() == user.getUserId()) {
                if (budgetDao.deleteBudget(budgetId)) {
                    response.sendRedirect("BudgetController?success=Budget deleted successfully");
                } else {
                    response.sendRedirect("BudgetController?error=Failed to delete budget");
                }
            } else {
                response.sendRedirect("BudgetController?error=Budget not found or unauthorized");
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        request.setAttribute("budgets", budgetDao.getUserBudgets(user.getUserId()));
        request.getRequestDispatcher("set-budget.jsp").forward(request, response);
    }
}