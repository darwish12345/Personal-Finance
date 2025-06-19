package controller;

import dao.BudgetDAO;
import dao.TransactionDAO;
import model.Transaction;
import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.User;

public class TransactionController extends HttpServlet {
    private TransactionDAO transactionDao;
    private BudgetDAO budgetDao;
    
    @Override
    public void init() {
        transactionDao = new TransactionDAO();
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
        String errorPage = "add-transaction.jsp";
        
        try {
            if ("add".equals(action)) {
                handleAddTransaction(request, response, user);
            } else if ("update".equals(action)) {
                handleUpdateTransaction(request, response, user);
                errorPage = "dashboard.jsp";
            } else if ("delete".equals(action)) {
                handleDeleteTransaction(request, response);
                errorPage = "dashboard.jsp";
            }
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", "Invalid input: " + e.getMessage());
            request.getRequestDispatcher(errorPage).forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher(errorPage).forward(request, response);
        }
    }
    
    private void handleAddTransaction(HttpServletRequest request, HttpServletResponse response, User user)
            throws Exception {
        String category = request.getParameter("category");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String type = request.getParameter("type");
        String description = request.getParameter("description");
        String dateStr = request.getParameter("transactionDate");
        
        if (dateStr == null || dateStr.isEmpty()) {
            throw new IllegalArgumentException("Transaction date is required");
        }
        Date transactionDate = Date.valueOf(dateStr);
        
        // Check if this is an expense that would exceed budget
        if ("expense".equals(type)) {
            String monthYear = new SimpleDateFormat("MM-yyyy").format(transactionDate);
            double monthlyBudget = budgetDao.getMonthlyBudget(user.getUserId(), "expense", monthYear);
            
            if (monthlyBudget > 0) {
                double monthlyExpenses = transactionDao.getMonthlyExpenses(user.getUserId(), "expense", monthYear);
                
                if (monthlyExpenses + amount > monthlyBudget) {
                    // Budget will be exceeded - ask for confirmation
                    request.setAttribute("exceedWarning", true);
                    request.setAttribute("category", category);
                    request.setAttribute("amount", amount);
                    request.setAttribute("description", description);
                    request.setAttribute("transactionDate", dateStr);
                    request.setAttribute("currentSpent", monthlyExpenses);
                    request.setAttribute("budgetLimit", monthlyBudget);
                    request.setAttribute("exceedAmount", (monthlyExpenses + amount) - monthlyBudget);
                    request.getRequestDispatcher("add-transaction.jsp").forward(request, response);
                    return;
                }
            }
        }
        
        // If no budget or not exceeded, proceed with adding
        Transaction transaction = new Transaction(
            user.getUserId(), category, amount, type, description, transactionDate);
        
        if (transactionDao.addTransaction(transaction)) {
            response.sendRedirect("dashboard.jsp");
        } else {
            throw new Exception("Failed to add transaction");
        }
    }
    
    private void handleUpdateTransaction(HttpServletRequest request, HttpServletResponse response, User user)
            throws Exception {
        int transactionId = Integer.parseInt(request.getParameter("transactionId"));
        String category = request.getParameter("category");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String type = request.getParameter("type");
        String description = request.getParameter("description");
        String dateStr = request.getParameter("transactionDate");
        
        if (dateStr == null || dateStr.isEmpty()) {
            throw new IllegalArgumentException("Transaction date is required");
        }
        Date transactionDate = Date.valueOf(dateStr);
        
        Transaction transaction = new Transaction();
        transaction.setTransactionId(transactionId);
        transaction.setUserId(user.getUserId());
        transaction.setCategory(category);
        transaction.setAmount(amount);
        transaction.setType(type);
        transaction.setDescription(description);
        transaction.setTransactionDate(transactionDate);
        
        if (transactionDao.updateTransaction(transaction)) {
            response.sendRedirect("dashboard.jsp?success=Transaction updated successfully");
        } else {
            throw new Exception("Failed to update transaction");
        }
    }
    
    private void handleDeleteTransaction(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        int transactionId = Integer.parseInt(request.getParameter("transactionId"));
        
        if (transactionDao.deleteTransaction(transactionId)) {
            response.sendRedirect("dashboard.jsp?success=Transaction deleted successfully");
        } else {
            throw new Exception("Failed to delete transaction");
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
        
        try {
            String monthYear = new SimpleDateFormat("MM-yyyy").format(new java.util.Date());
            
            double totalIncome = transactionDao.getTotalIncome(user.getUserId(), monthYear);
            double totalExpenses = transactionDao.getTotalExpenses(user.getUserId(), monthYear);
            double savings = totalIncome - totalExpenses;
            
            request.setAttribute("transactions", transactionDao.getUserTransactions(user.getUserId()));
            request.setAttribute("totalIncome", totalIncome);
            request.setAttribute("totalExpenses", totalExpenses);
            request.setAttribute("savings", savings);
            
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "An error occurred while loading dashboard: " + e.getMessage());
            request.getRequestDispatcher("dashboard.jsp").forward(request, response);
        }
    }
}