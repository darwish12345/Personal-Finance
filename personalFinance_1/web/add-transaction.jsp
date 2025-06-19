<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Budget Setter - Add Transaction</title>
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
                    <li class="nav-item">
                        <a class="nav-link" href="TransactionController">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="BudgetController">Set Budget</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="add-transaction.jsp">Add Transaction</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="reports.jsp">Reports</a>
                    </li>
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
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <h2>Add Transaction</h2>
        
        <% if (request.getAttribute("exceedWarning") != null && (Boolean) request.getAttribute("exceedWarning")) { %>
            <div class="card mt-4">
                <div class="card-header bg-warning text-dark">
                    <h4>Budget Exceeded Warning</h4>
                </div>
                <div class="card-body">
                    <p>You are about to exceed your budget for <strong><%= request.getAttribute("category") %></strong> by 
                       $<%= request.getAttribute("exceedAmount") %>.</p>
                    <p>Current spent: $<%= request.getAttribute("currentSpent") %> of $<%= request.getAttribute("budgetLimit") %> limit.</p>
                    
                    <div class="d-flex justify-content-between mt-4">
                        <form action="TransactionController" method="POST" class="d-inline">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="category" value="<%= request.getAttribute("category") %>">
                            <input type="hidden" name="amount" value="<%= request.getAttribute("amount") %>">
                            <input type="hidden" name="type" value="expense">
                            <input type="hidden" name="description" value="<%= request.getAttribute("description") %>">
                            <input type="hidden" name="transactionDate" value="<%= request.getAttribute("transactionDate") %>">
                            <button type="submit" class="btn btn-danger">Proceed Anyway</button>
                        </form>
                        <a href="add-transaction.jsp" class="btn btn-primary">Cancel</a>
                    </div>
                </div>
            </div>
        <% } else { %>
            <div class="card mt-4">
                <div class="card-body">
                    <form action="TransactionController" method="POST">
                        <input type="hidden" name="action" value="add">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="type" class="form-label">Type</label>
                                <select class="form-select" id="type" name="type" required>
                                    <option value="income">Income</option>
                                    <option value="expense">Expense</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="category" class="form-label">Category</label>
                                <input type="text" class="form-control" id="category" name="category" required>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="amount" class="form-label">Amount</label>
                                <input type="number" step="0.01" class="form-control" id="amount" name="amount" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="transactionDate" class="form-label">Date</label>
                                <input type="date" class="form-control" id="transactionDate" name="transactionDate" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="description" class="form-label">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">Add Transaction</button>
                    </form>
                </div>
            </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // tarikh harini
        document.getElementById('transactionDate').valueAsDate = new Date();
    </script>
</body>
</html>