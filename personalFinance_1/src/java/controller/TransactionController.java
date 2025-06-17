package controller;

import dao.BudgetDAO;
import dao.TransactionDAO;
import model.Transaction;
import model.User;

import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

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

        if ("add".equals(action)) {
            String category = request.getParameter("category");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String type = request.getParameter("type");
            String description = request.getParameter("description");
            Date transactionDate = Date.valueOf(request.getParameter("transactionDate"));

            // Check budget limit if it's an expense
            if ("expense".equals(type)) {
                String monthYear = new SimpleDateFormat("MM-yyyy").format(transactionDate);
                double monthlyBudget = budgetDao.getMonthlyBudget(user.getUserId(), "expense", monthYear);

                if (monthlyBudget > 0) {
                    double monthlyExpenses = transactionDao.getMonthlyExpenses(user.getUserId(), "expense", monthYear);

                    if (monthlyExpenses + amount > monthlyBudget) {
                        request.setAttribute("exceedWarning", true);
                        request.setAttribute("category", category);
                        request.setAttribute("amount", amount);
                        request.setAttribute("description", description);
                        request.setAttribute("transactionDate", transactionDate);
                        request.setAttribute("currentSpent", monthlyExpenses);
                        request.setAttribute("budgetLimit", monthlyBudget);
                        request.setAttribute("exceedAmount", (monthlyExpenses + amount) - monthlyBudget);
                        request.getRequestDispatcher("add-transaction.jsp").forward(request, response);
                        return;
                    }
                }
            }

            // Proceed to add transaction
            Transaction transaction = new Transaction(user.getUserId(), category, amount, type, description, transactionDate);

            if (transactionDao.addTransaction(transaction)) {
                response.sendRedirect("TransactionController");
            } else {
                request.setAttribute("error", "Failed to add transaction");
                request.getRequestDispatcher("add-transaction.jsp").forward(request, response);
            }

        } else if ("update".equals(action)) {
            int transactionId = Integer.parseInt(request.getParameter("transactionId"));
            String category = request.getParameter("category");
            double amount = Double.parseDouble(request.getParameter("amount"));
            String type = request.getParameter("type");
            String description = request.getParameter("description");
            Date transactionDate = Date.valueOf(request.getParameter("transactionDate"));

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
                response.sendRedirect("dashboard.jsp?error=Failed to update transaction");
            }

        } else if ("delete".equals(action)) {
            int transactionId = Integer.parseInt(request.getParameter("transactionId"));

            if (transactionDao.deleteTransaction(transactionId)) {
                response.sendRedirect("dashboard.jsp?success=Transaction deleted successfully");
            } else {
                response.sendRedirect("dashboard.jsp?error=Failed to delete transaction");
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

        String monthYear = new SimpleDateFormat("MM-yyyy").format(new java.util.Date());

        double totalIncome = transactionDao.getTotalIncome(user.getUserId(), monthYear);
        double totalExpenses = transactionDao.getTotalExpenses(user.getUserId(), monthYear);
        double savings = totalIncome - totalExpenses;

        request.setAttribute("transactions", transactionDao.getUserTransactions(user.getUserId()));
        request.setAttribute("totalIncome", totalIncome);
        request.setAttribute("totalExpenses", totalExpenses);
        request.setAttribute("savings", savings);

        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }
}
