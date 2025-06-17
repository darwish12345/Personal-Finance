<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User, java.util.List, model.Transaction, java.text.SimpleDateFormat, dao.BudgetDAO" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Budget Setter - Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="style.css" rel="stylesheet">
    <style>
        .transaction-table {
            max-height: 500px;
            overflow-y: auto;
        }
        .income {
            color: green;
        }
        .expense {
            color: red;
        }
        .over-budget {
            color: red;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="#">Personal Finance</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link active" href="TransactionController">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="BudgetController">Set Budget</a></li>
                    <li class="nav-item"><a class="nav-link" href="add-transaction.jsp">Add Transaction</a></li>
                    <li class="nav-item"><a class="nav-link" href="reports.jsp">Reports</a></li>
                    <li class="nav-item">
                        <form action="AuthController" method="POST">
                            <input type="hidden" name="action" value="logout">
                            <button type="submit" class="nav-link btn btn-link">Logout</button>
                        </form>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Content -->
    <div class="container mt-4">
        <h2>Welcome, ${sessionScope.user.username}</h2>

        <div class="row mt-4">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5>Recent Transactions</h5>
                        <a href="add-transaction.jsp" class="btn btn-primary btn-sm">Add New Transaction</a>
                    </div>
                    <div class="card-body">
                        <div class="transaction-table">
                            <table class="table table-striped table-hover">
                                <thead class="sticky-top bg-light">
                                    <tr>
                                        <th>ID</th>
                                        <th>Description</th>
                                        <th>Amount (RM)</th>
                                        <th>Type</th>
                                        <th>Category</th>
                                        <th>Date</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                    BudgetDAO budgetDao = new BudgetDAO();
                                    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
                                    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

                                    if (transactions != null && !transactions.isEmpty()) {
                                        for (Transaction t : transactions) { 
                                            String monthYear = new SimpleDateFormat("MM-yyyy").format(t.getTransactionDate());
                                            double budgetLimit = budgetDao.getMonthlyBudget(t.getUserId(), t.getCategory(), monthYear);
                                            boolean isOverBudget = t.getType().equals("expense") && 
                                                                    budgetLimit > 0 && 
                                                                    t.getAmount() > budgetLimit;
                                    %>
                                    <tr>
                                        <td><%= t.getTransactionId() %></td>
                                        <td><%= t.getDescription() != null ? t.getDescription() : "-" %></td>
                                        <td class="<%= t.getType().equals("income") ? "income" : "expense" %> <%= isOverBudget ? "over-budget" : "" %>">
                                            <%= t.getType().equals("income") ? "+" : "-" %><%= String.format("%.2f", t.getAmount()) %>
                                        </td>
                                        <td>
                                            <span class="badge bg-<%= t.getType().equals("income") ? "success" : "danger" %>">
                                                <%= t.getType() %>
                                            </span>
                                        </td>
                                        <td><%= t.getCategory() != null ? t.getCategory() : "N/A" %></td>
                                        <td><%= dateFormat.format(t.getTransactionDate()) %></td>
                                        <td>
                                            <button type="button" 
                                                    class="btn btn-sm btn-warning" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#editTransactionModal"
                                                    data-id="<%= t.getTransactionId() %>"
                                                    data-description="<%= t.getDescription() %>"
                                                    data-amount="<%= t.getAmount() %>"
                                                    data-type="<%= t.getType() %>"
                                                    data-category="<%= t.getCategory() %>"
                                                    data-date="<%= dateFormat.format(t.getTransactionDate()) %>">
                                                Edit
                                            </button>

                                            <form action="TransactionController" method="POST" style="display:inline;">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="transactionId" value="<%= t.getTransactionId() %>">
                                                <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this transaction?')">Delete</button>
                                            </form>
                                        </td>
                                    </tr>
                                    <% 
                                        }
                                    } else { 
                                    %>
                                    <tr>
                                        <td colspan="7" class="text-center">No transactions found</td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Modal -->
    <div class="modal fade" id="editTransactionModal" tabindex="-1" aria-labelledby="editTransactionModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <form action="TransactionController" method="POST" class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="editTransactionModalLabel">Edit Transaction</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="transactionId" id="editTransactionId">

            <div class="mb-3">
              <label for="editDescription" class="form-label">Description</label>
              <input type="text" class="form-control" id="editDescription" name="description" required>
            </div>

            <div class="mb-3">
              <label for="editAmount" class="form-label">Amount (RM)</label>
              <input type="number" step="0.01" class="form-control" id="editAmount" name="amount" required>
            </div>

            <div class="mb-3">
              <label for="editType" class="form-label">Type</label>
              <select class="form-select" id="editType" name="type" required>
                <option value="income">Income</option>
                <option value="expense">Expense</option>
              </select>
            </div>

            <div class="mb-3">
              <label for="editCategory" class="form-label">Category</label>
              <input type="text" class="form-control" id="editCategory" name="category" required>
            </div>

            <div class="mb-3">
              <label for="editDate" class="form-label">Date</label>
              <input type="date" class="form-control" id="editDate" name="date" required>
            </div>
          </div>

          <div class="modal-footer">
            <button type="submit" class="btn btn-primary">Update</button>
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Script: Bootstrap + Modal Handler -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
      const editTransactionModal = document.getElementById('editTransactionModal');
      editTransactionModal.addEventListener('show.bs.modal', function (event) {
        const button = event.relatedTarget;
        document.getElementById('editTransactionId').value = button.getAttribute('data-id');
        document.getElementById('editDescription').value = button.getAttribute('data-description');
        document.getElementById('editAmount').value = button.getAttribute('data-amount');
        document.getElementById('editType').value = button.getAttribute('data-type');
        document.getElementById('editCategory').value = button.getAttribute('data-category');
        document.getElementById('editDate').value = button.getAttribute('data-date');
      });
    </script>
</body>
</html>

