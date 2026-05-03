<%@ page import="java.sql.*, java.time.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Integer shopId = (Integer) session.getAttribute("shopId");
    String shopName = (String) session.getAttribute("shopName");

    if(shopId == null){
        response.sendRedirect("shopLogin.jsp?msg=loginfirst");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    double todayAmount = 0;
    double[] monthlyAmounts = new double[12];

    try {
        con = DBConnection.getConnection();

        // Today's amount
        ps = con.prepareStatement(
            "SELECT SUM(total_amount) AS today_total FROM orders " +
            "WHERE shop_id=? AND DATE(order_date)=CURDATE() AND status='Delivered'"
        );
        ps.setInt(1, shopId);
        rs = ps.executeQuery();
        if(rs.next()) todayAmount = rs.getDouble("today_total");

        // Monthly amount for current year
        int currentYear = LocalDate.now().getYear();
        ps = con.prepareStatement(
            "SELECT MONTH(order_date) AS month, SUM(total_amount) AS monthly_total " +
            "FROM orders WHERE shop_id=? AND YEAR(order_date)=? AND status='Delivered' " +
            "GROUP BY MONTH(order_date)"
        );
        ps.setInt(1, shopId);
        ps.setInt(2, currentYear);
        rs = ps.executeQuery();
        while(rs.next()){
            int month = rs.getInt("month");
            monthlyAmounts[month-1] = rs.getDouble("monthly_total");
        }

    } catch(Exception e){ e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Analytics - <%= shopName %></title>

    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* --- BRANDED SUNSET THEME --- */
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

        /* --- GLASS NAVIGATION --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        /* --- ANALYTICS CARDS --- */
        .card {
            border: none;
            border-radius: 24px;
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            padding: 30px;
            transition: 0.3s;
        }

        .stat-label {
            font-size: 0.8rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: #888;
            font-weight: 700;
        }

        .stat-value {
            font-size: 2.8rem;
            font-weight: 800;
            background: -webkit-linear-gradient(#ee0979, #ff6a00);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .chart-container {
            position: relative;
            height: 350px;
            width: 100%;
        }

        .chart-card-title {
            color: #333;
            font-weight: 700;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
        }

        .chart-card-title i { color: #ee0979; margin-right: 12px; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp">
            <i class="fas fa-chart-pie me-2"></i><%= shopName.toUpperCase() %> ANALYTICS
        </a>
        <div class="collapse navbar-collapse">
                 <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link text-dark" href="shopDashboard.jsp">
                        <i class="fas fa-home me-1"></i>Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="manageCategory.jsp">
                        <i class="fas fa-list me-1"></i>Categories
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="manageItems.jsp">
                        <i class="fas fa-boxes me-1"></i>Items
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="viewOrders.jsp">
                        <i class="fas fa-receipt me-1"></i>Orders
                    </a>
                </li>
                 <li class="nav-item">
                    <a class="nav-link text-dark" href="walkInInvoice.jsp">
                        <i class="fas fa-coins me-1"></i>Generate Invoice
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="viewFeedback.jsp">
                        <i class="fas fa-comment-dots me-1"></i>Feedback
                    </a>
                </li>
                <li class="nav-item"><a class="nav-link text-dark" href="shopCharts.jsp"><i class="fas fa-chart-bar me-1"></i>Charts</a></li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="LogoutServlet">
                        <i class="fas fa-sign-out-alt me-1"></i>Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<div class="container mt-5 pb-5">
    <div class="row g-4">
        <div class="col-md-4">
            <div class="card h-100 d-flex flex-column justify-content-center text-center">
                <span class="stat-label mb-2">Today's Revenue</span>
                <div class="stat-value">₹<%= String.format("%.2f", todayAmount) %></div>
                <p class="text-muted small mt-2">Successful Deliveries Only</p>
            </div>
        </div>

        <div class="col-md-8">
            <div class="card h-100">
                <h5 class="chart-card-title">
                    <i class="fas fa-chart-line"></i> Annual Performance Summary
                </h5>
                <div class="chart-container">
                    <canvas id="monthlyChart"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const ctx = document.getElementById('monthlyChart').getContext('2d');
    
    // Create a beautiful gradient for the bars
    const gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, '#ee0979');
    gradient.addColorStop(1, '#ff6a00');

    const monthlyChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'],
            datasets: [{
                label: 'Revenue (₹)',
                data: [<%= monthlyAmounts[0] %>, <%= monthlyAmounts[1] %>, <%= monthlyAmounts[2] %>, <%= monthlyAmounts[3] %>,
                       <%= monthlyAmounts[4] %>, <%= monthlyAmounts[5] %>, <%= monthlyAmounts[6] %>, <%= monthlyAmounts[7] %>,
                       <%= monthlyAmounts[8] %>, <%= monthlyAmounts[9] %>, <%= monthlyAmounts[10] %>, <%= monthlyAmounts[11] %>],
                backgroundColor: gradient,
                borderRadius: 8,
                borderSkipped: false,
                hoverBackgroundColor: '#333'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { display: false },
                    ticks: {
                        callback: function(value) { return '₹' + value; },
                        font: { weight: 'bold' }
                    }
                },
                x: {
                    grid: { display: false },
                    ticks: { font: { weight: 'bold' } }
                }
            },
            plugins: {
                legend: { display: false },
                tooltip: {
                    backgroundColor: '#333',
                    titleFont: { size: 14 },
                    bodyFont: { size: 16, weight: 'bold' },
                    padding: 15,
                    displayColors: false
                }
            }
        }
    });
</script>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>