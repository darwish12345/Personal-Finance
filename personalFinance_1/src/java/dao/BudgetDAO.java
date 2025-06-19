package dao;

import model.Budget;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BudgetDAO {

    public boolean addBudget(Budget budget) {
        String sql = "INSERT INTO budgets (user_id, category, amount, month_year) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, budget.getUserId());
            stmt.setString(2, budget.getCategory());
            stmt.setDouble(3, budget.getAmount());
            stmt.setString(4, budget.getMonthYear());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Budget> getUserBudgets(int userId) {
        List<Budget> budgets = new ArrayList<>();
        String sql = "SELECT * FROM budgets WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Budget budget = new Budget();
                budget.setBudgetId(rs.getInt("budget_id"));
                budget.setUserId(rs.getInt("user_id"));
                budget.setCategory(rs.getString("category"));
                budget.setAmount(rs.getDouble("amount"));
                budget.setMonthYear(rs.getString("month_year"));
                budgets.add(budget);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return budgets;
    }

    public double getMonthlyBudget(int userId, String category, String monthYear) {
        String sql = "SELECT amount FROM budgets WHERE user_id = ? AND category = ? AND month_year = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setString(2, category);
            stmt.setString(3, monthYear);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getDouble("amount");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean updateBudget(Budget budget) {
        String sql = "UPDATE budgets SET category = ?, amount = ?, month_year = ? WHERE budget_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, budget.getCategory());
            stmt.setDouble(2, budget.getAmount());
            stmt.setString(3, budget.getMonthYear());
            stmt.setInt(4, budget.getBudgetId());

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteBudget(int budgetId) {
        String sql = "DELETE FROM budgets WHERE budget_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, budgetId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Budget getBudgetById(int budgetId) {
        String sql = "SELECT * FROM budgets WHERE budget_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, budgetId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Budget budget = new Budget();
                budget.setBudgetId(rs.getInt("budget_id"));
                budget.setUserId(rs.getInt("user_id"));
                budget.setCategory(rs.getString("category"));
                budget.setAmount(rs.getDouble("amount"));
                budget.setMonthYear(rs.getString("month_year"));
                return budget;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
