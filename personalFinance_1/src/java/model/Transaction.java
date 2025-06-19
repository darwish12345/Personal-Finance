package model;

import java.sql.Date;

public class Transaction {
    private int transactionId;
    private int userId;
    private String category;
    private double amount;
    private String type;
    private String description;
    private Date transactionDate;
    
    public Transaction() {}
    
    public Transaction(int userId, String category, double amount, String type, 
                      String description, Date transactionDate) {
        this.userId = userId;
        this.category = category;
        this.amount = amount;
        this.type = type;
        this.description = description;
        this.transactionDate = transactionDate;
    }
    
    // Getters and Setters
    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Date getTransactionDate() { return transactionDate; }
    public void setTransactionDate(Date transactionDate) { this.transactionDate = transactionDate; }
}