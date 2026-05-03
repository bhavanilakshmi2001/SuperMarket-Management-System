<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String adminId = (String) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("adminLogin.jsp?msg=loginfirst");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    int totalShops = 0, totalCustomers = 0, totalAgents = 0, totalFeedback = 0;

    try {
        con = DBConnection.getConnection();

        ps = con.prepareStatement("SELECT COUNT(*) FROM shops");
        rs = ps.executeQuery();
        if (rs.next()) totalShops = rs.getInt(1);

        ps = con.prepareStatement("SELECT COUNT(*) FROM customers");
        rs = ps.executeQuery();
        if (rs.next()) totalCustomers = rs.getInt(1);

        ps = con.prepareStatement("SELECT COUNT(*) FROM agents");
        rs = ps.executeQuery();
        if (rs.next()) totalAgents = rs.getInt(1);

        ps = con.prepareStatement("SELECT COUNT(*) FROM feedback");
        rs = ps.executeQuery();
        if (rs.next()) totalFeedback = rs.getInt(1);

    } catch(Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Platform Analytics - MartSmart</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        body {
            background: linear-gradient(-45deg, #ee0979, #ff6a00, #e63946, #f77f00);
            background-size: 400% 400%;
            animation: gradientShift 15s ease infinite;
            min-height: 100vh;
            font-family: 'Segoe UI', sans-serif;
        }

        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        .chart-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            height: 100%;
        }

        h4 { color: #333; font-weight: 700; margin-bottom: 25px; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="adminDashboard.jsp"><i class="fa fa-chart-pie me-2"></i>ADMIN ANALYTICS</a>
        <div class="collapse navbar-collapse">
             <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link text-dark" href="adminDashboard.jsp"><i class="fas fa-tachometer-alt me-1"></i>Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link text-dark" href="viewShops.jsp"><i class="fas fa-store me-1"></i>Shops</a></li>
                    <li class="nav-item"><a class="nav-link text-dark" href="viewAgents.jsp"><i class="fas fa-users me-1"></i>Agents</a></li>
                    <li class="nav-item"><a class="nav-link text-dark" href="viewCustomers.jsp"><i class="fas fa-user me-1"></i>Customers</a></li>
                    <li class="nav-item"><a class="nav-link text-dark" href="adminViewOrders.jsp"><i class="fas fa-receipt me-1"></i>Orders</a></li>
                    <li class="nav-item"><a class="nav-link text-dark" href="adminCharts.jsp"><i class="fas fa-chart-bar me-1"></i>Charts</a></li>
                    <li class="nav-item"><a class="nav-link text-dark" href="LogoutServlet"><i class="fas fa-sign-out-alt me-1"></i>Logout</a></li>
                </ul>
        </div>
    </div>
</nav>

<div class="container py-5">
    <div class="row g-4">
        
        <div class="col-lg-5">
            <div class="chart-card text-center">
                <h4>User Distribution</h4>
                <div style="max-width: 300px; margin: 0 auto;">
                    <canvas id="userDonutChart"></canvas>
                </div>
                <div class="mt-4 small text-muted">
                    Ratio of Partners, Delivery Fleet, and Shoppers
                </div>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="chart-card">
                <h4>Platform Growth Metrics</h4>
                <canvas id="growthBarChart"></canvas>
            </div>
        </div>

    </div>
</div>

<script>
    // --- 1. USER DISTRIBUTION (DONUT) ---
    const donutCtx = document.getElementById('userDonutChart').getContext('2d');
    new Chart(donutCtx, {
        type: 'doughnut',
        data: {
            labels: ['Shops', 'Agents', 'Customers'],
            datasets: [{
                data: [<%= totalShops %>, <%= totalAgents %>, <%= totalCustomers %>],
                backgroundColor: ['#ee0979', '#ff6a00', '#4cc9f0'],
                borderWidth: 0,
                hoverOffset: 15
            }]
        },
        options: {
            plugins: {
                legend: { position: 'bottom' }
            },
            cutout: '70%'
        }
    });

    // --- 2. GROWTH METRICS (BAR) ---
    const barCtx = document.getElementById('growthBarChart').getContext('2d');
    new Chart(barCtx, {
        type: 'bar',
        data: {
            labels: ['Partners', 'Customers', 'Delivery Team', 'Reviews'],
            datasets: [{
                label: 'Total Registered Units',
                data: [<%= totalShops %>, <%= totalCustomers %>, <%= totalAgents %>, <%= totalFeedback %>],
                backgroundColor: [
                    'rgba(238, 9, 121, 0.8)',
                    'rgba(255, 106, 0, 0.8)',
                    'rgba(76, 201, 240, 0.8)',
                    'rgba(67, 97, 238, 0.8)'
                ],
                borderRadius: 10,
                borderWidth: 0
            }]
        },
        options: {
            scales: {
                y: { beginAtZero: true, grid: { display: false } },
                x: { grid: { display: false } }
            },
            plugins: {
                legend: { display: false }
            }
        }
    });
</script>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>