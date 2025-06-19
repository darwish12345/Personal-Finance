<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="dao.TransactionDAO, dao.BudgetDAO, model.User, java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Personal Finance - Reports</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="style.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
        <div class="container">
            <a class="navbar-brand" href="#">Personal Finance</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="TransactionController">Home</a></li>
                    <li class="nav-item"><a class="nav-link" href="BudgetController">Set Budget</a></li>
                    <li class="nav-item"><a class="nav-link" href="add-transaction.jsp">Add Transaction</a></li>
                    <li class="nav-item"><a class="nav-link active" href="reports.jsp">Reports</a></li>
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
        <h2>Financial Reports</h2>

<div class="card mt-4">
    <div class="card-header"><h4>Select Month</h4></div>
    <div class="card-body">
        <form method="GET" action="reports.jsp" class="row" onsubmit="return validateMonthYear()">
            <div class="col-md-6">
                <label for="monthYear" class="form-label">Month and Year (MM-YYYY)</label>
                <input type="text" class="form-control" id="monthYear" name="monthYear"
                       pattern="(0[1-9]|1[0-2])-20[2-9][0-9]" 
                       title="Please enter a valid month and year in MM-YYYY format (e.g., 06-2023)"
                       placeholder="MM-YYYY" required
                       value="<%= request.getParameter("monthYear") != null ?
                              request.getParameter("monthYear") :
                              new SimpleDateFormat("MM-yyyy").format(new Date()) %>">
                <div class="invalid-feedback" id="monthYearFeedback">
                    Please enter a valid month and year in MM-YYYY format (e.g., 06-2023)
                </div>
            </div>
            <div class="col-md-6 d-flex align-items-end">
                <button type="submit" class="btn btn-primary">Generate Report</button>
            </div>
        </form>
    </div>
</div>

<script>
function validateMonthYear() {
    const input = document.getElementById('monthYear');
    const feedback = document.getElementById('monthYearFeedback');
    const pattern = /^(0[1-9]|1[0-2])-20[2-9][0-9]$/;
    
    if (!pattern.test(input.value)) {
        input.classList.add('is-invalid');
        feedback.style.display = 'block';
        return false;
    }
    
    input.classList.remove('is-invalid');
    feedback.style.display = 'none';
    return true;
}

// Validate on input change
document.getElementById('monthYear').addEventListener('input', function() {
    validateMonthYear();
});
</script>

        <%
            User user = (User) session.getAttribute("user");
            if (user == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            String monthYear = request.getParameter("monthYear") != null ?
                               request.getParameter("monthYear") :
                               new SimpleDateFormat("MM-yyyy").format(new Date());

            BudgetDAO budgetDao = new BudgetDAO();
            TransactionDAO transactionDao = new TransactionDAO();

            double budgetAmount = budgetDao.getMonthlyBudget(user.getUserId(), "expense", monthYear);
            double totalExpenses = transactionDao.getTotalExpenses(user.getUserId(), monthYear);
            double totalIncome = transactionDao.getTotalIncome(user.getUserId(), monthYear);

            double netSpending = totalExpenses - totalIncome;
            double remainingBudget = budgetAmount - netSpending;

            // Values for chart (ensuring no negatives)
            double chartSpent = Math.min(Math.max(0, netSpending), budgetAmount);
            double chartRemaining = Math.max(0, budgetAmount - chartSpent);
        %>

        <div class="row mt-4">
            <!-- Budget Summary -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header"><h5>Budget Summary - <%= monthYear %></h5></div>
                    <div class="card-body">
                        <p><strong>Budget:</strong> RM<%= String.format("%.2f", budgetAmount) %></p>
                        <p><strong>Total Expenses:</strong> RM<%= String.format("%.2f", totalExpenses) %></p>
                        <p><strong>Total Income:</strong> RM<%= String.format("%.2f", totalIncome) %></p>
                        <p><strong>Net Spending:</strong> RM<%= String.format("%.2f", netSpending) %></p>
                        <p>
                            <strong>Remaining:</strong>
                            <span class="<%= remainingBudget < 0 ? "text-danger" : "text-success" %>">
                                RM<%= String.format("%.2f", remainingBudget) %>
                            </span>
                        </p>
                        <% if (remainingBudget < 0) { %>
                            <div class="alert alert-danger">
                                You exceeded your budget by RM<%= String.format("%.2f", -remainingBudget) %>.
                            </div>
                        <% } else { %>
                            <div class="alert alert-success">
                                You have RM<%= String.format("%.2f", remainingBudget) %> left in your budget.
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Pie Chart -->
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header"><h5>Budget Visualization</h5></div>
                    <div class="card-body">
                        <canvas id="budgetChart" width="400" height="400"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- JS Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const chartSpent = <%= chartSpent %>;
        const chartRemaining = <%= chartRemaining %>;

        const ctx = document.getElementById('budgetChart').getContext('2d');
        const budgetChart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: ['Net Spending', 'Remaining Budget'],
                datasets: [{
                    data: [chartSpent, chartRemaining],
                    backgroundColor: [
                        'rgba(255, 99, 132, 0.7)',
                        'rgba(54, 162, 235, 0.7)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'right' },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.raw || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = Math.round((value / total) * 100);
                                return `${label}: RM${value.toFixed(2)} (${percentage}%)`;
                            }
                        }
                    }
                }
            }
        });
    </script>
</body>
</html>

