package model;

public class Budget {
    private int budgetId;
    private int userId;
    private String category; // Will be either "expense" or "saving"
    private double amount;
    private String monthYear;
    
    public Budget() {}
    
    public Budget(int userId, String category, double amount, String monthYear) {
        this.userId = userId;
        this.category = category;
        this.amount = amount;
        this.monthYear = monthYear;
    }
    
    // Getters and Setters
    public int getBudgetId() { return budgetId; }
    public void setBudgetId(int budgetId) { this.budgetId = budgetId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public String getMonthYear() { return monthYear; }
    public void setMonthYear(String monthYear) { this.monthYear = monthYear; }
}