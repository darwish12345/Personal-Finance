<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.Budget, java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Personal Finance - Set Budget</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="style.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="#">Personal Finance</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="TransactionController">Home</a></li>
                    <li class="nav-item"><a class="nav-link active" href="BudgetController">Set Budget</a></li>
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

    <div class="container mt-4">
        <% if (request.getParameter("success") != null) { %>
            <div class="alert alert-success"><%= request.getParameter("success") %></div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
            <div class="alert alert-danger"><%= request.getParameter("error") %></div>
        <% } %>

        <h2>Set Your Budget</h2>

        <!-- Add Budget Form -->
        <div class="card mt-4">
            <div class="card-header"><h4>Add New Budget</h4></div>
            <div class="card-body">
                <form action="BudgetController" method="POST">
                    <input type="hidden" name="action" value="add">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="category" class="form-label">Category</label>
                            <select class="form-select" id="category" name="category" required>
                                <option value="">Select a category</option>
                                <option value="expense">Expense</option>
                                <option value="saving">Saving</option>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="amount" class="form-label">Amount</label>
                            <input type="number" step="0.01" class="form-control" id="amount" name="amount" required>
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary">Add Budget</button>
                </form>
            </div>
        </div>

        <!-- Budget List Table -->
        <div class="card mt-4">
            <div class="card-header"><h4>Your Budgets</h4></div>
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th>Amount</th>
                            <th>Month/Year</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        List<Budget> budgets = (List<Budget>) request.getAttribute("budgets");
                        if (budgets != null) {
                            for (Budget b : budgets) { %>
                                <tr>
                                    <td><%= b.getCategory() %></td>
                                    <td>RM<%= b.getAmount() %></td>
                                    <td><%= b.getMonthYear() %></td>
                                    <td>
                                        <!-- Edit Button -->
                                        <button class="btn btn-sm btn-warning" data-bs-toggle="modal" 
                                                data-bs-target="#editBudgetModal" 
                                                data-id="<%= b.getBudgetId() %>"
                                                data-category="<%= b.getCategory() %>"
                                                data-amount="<%= b.getAmount() %>"
                                                data-month="<%= b.getMonthYear() %>">
                                            Edit
                                        </button>

                                        <!-- Delete Button with Confirmation -->
                                        <form action="BudgetController" method="POST" style="display:inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="budgetId" value="<%= b.getBudgetId() %>">
                                            <button type="submit" class="btn btn-sm btn-danger" 
                                                    onclick="return confirm('Are you sure you want to delete this budget?')">
                                                Delete
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Edit Budget Modal -->
    <div class="modal fade" id="editBudgetModal" tabindex="-1" aria-labelledby="editBudgetModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <form action="BudgetController" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="budgetId" id="editBudgetId">
                    <div class="modal-header">
                        <h5 class="modal-title" id="editBudgetModalLabel">Edit Budget</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="editCategory" class="form-label">Category</label>
                            <select class="form-select" id="editCategory" name="category" required>
                                <option value="expense">Expense</option>
                                <option value="saving">Saving</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="editAmount" class="form-label">Amount</label>
                            <input type="number" step="0.01" class="form-control" id="editAmount" name="amount" required>
                        </div>
                        <div class="mb-3">
                            <label for="editMonthYear" class="form-label">Month/Year (MM-YYYY)</label>
                            <input type="text" class="form-control" id="editMonthYear" name="monthYear" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Save changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-fill modal with budget data
        var editBudgetModal = document.getElementById('editBudgetModal');
        editBudgetModal.addEventListener('show.bs.modal', function (event) {
            var button = event.relatedTarget;
            document.getElementById('editBudgetId').value = button.getAttribute('data-id');
            document.getElementById('editCategory').value = button.getAttribute('data-category');
            document.getElementById('editAmount').value = button.getAttribute('data-amount');
            document.getElementById('editMonthYear').value = button.getAttribute('data-month');
        });
    </script>
</body>
</html>

