<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Agent session check
    Integer agentId = (Integer) session.getAttribute("agentId");
    String agentName = (String) session.getAttribute("agentName");

    if(agentId == null){
        response.sendRedirect("agentLogin.jsp?msg=loginfirst");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    int totalOrders = 0;
    int completedOrders = 0;
    int pendingOrders = 0;

    try {
        con = DBConnection.getConnection();

        // Total orders assigned
        ps = con.prepareStatement("SELECT COUNT(*) FROM orders WHERE agent_id=?");
        ps.setInt(1, agentId);
        rs = ps.executeQuery();
        if(rs.next()) totalOrders = rs.getInt(1);

        // Completed orders
        ps = con.prepareStatement("SELECT COUNT(*) FROM orders WHERE agent_id=? AND status='Delivered'");
        ps.setInt(1, agentId);
        rs = ps.executeQuery();
        if(rs.next()) completedOrders = rs.getInt(1);

        // Pending orders
        ps = con.prepareStatement("SELECT COUNT(*) FROM orders WHERE agent_id=? AND status!='Delivered'");
        ps.setInt(1, agentId);
        rs = ps.executeQuery();
        if(rs.next()) pendingOrders = rs.getInt(1);

    } catch(Exception e){ e.printStackTrace(); }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agent Dashboard - MartSmart</title>

    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">

    <style>
        /* --- DYNAMIC SUNSET BACKGROUND --- */
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
            color: #fff;
        }

        /* --- NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }
        .nav-link:hover { color: #ffd1d1 !important; }

        /* --- DASHBOARD CARDS --- */
        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            text-align: center;
            transition: 0.3s ease;
            border: none;
            height: 100%;
        }
        .stat-card:hover { transform: translateY(-10px); }
        .stat-card h4 { font-size: 0.9rem; text-transform: uppercase; letter-spacing: 1px; color: #666; font-weight: 700; }
        .stat-card .display-4 { font-weight: 800; color: #ee0979; }

        .performance-container {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 25px;
            margin-top: 40px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .progress { height: 12px; border-radius: 10px; background: rgba(0,0,0,0.1); }
        .progress-bar { background: linear-gradient(90deg, #fff, #ffd1d1); }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="agentDashboard.jsp">
            <i class="fas fa-shipping-fast me-2"></i> AGENT: <%= agentName.toUpperCase() %>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#agentMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="agentMenu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="agentDashboard.jsp"><i class="fas fa-th-large me-1"></i> Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="assignedOrders.jsp"><i class="fas fa-box-open me-1"></i> New Tasks</a></li>
                <li class="nav-item"><a class="nav-link" href="completedOrders.jsp"><i class="fas fa-history me-1"></i> History</a></li>
                <li class="nav-item ms-lg-3"><a class="btn btn-light btn-sm fw-bold px-3 rounded-pill text-danger" href="LogoutServlet">Logout</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container py-5">
    <div class="row g-4">
        <div class="col-md-4">
            <div class="stat-card">
                <div class="mb-3"><i class="fas fa-list-ul fa-2x text-muted opacity-50"></i></div>
                <h4>Total Assigned</h4>
                <div class="display-4"><%= totalOrders %></div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card">
                <div class="mb-3"><i class="fas fa-check-double fa-2x text-success"></i></div>
                <h4>Success Deliveries</h4>
                <div class="display-4"><%= completedOrders %></div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card">
                <div class="mb-3"><i class="fas fa-spinner fa-spin fa-2x text-warning"></i></div>
                <h4>Pending Tasks</h4>
                <div class="display-4"><%= pendingOrders %></div>
            </div>
        </div>
    </div>

    <% 
        double percentage = (totalOrders > 0) ? ((double)completedOrders / totalOrders) * 100 : 0; 
    %>
    <div class="performance-container text-center">
        <h5 class="mb-3"><i class="fas fa-medal me-2"></i> Delivery Completion Rate</h5>
        <div class="progress mb-2">
            <div class="progress-bar" role="progressbar" style="width: <%= percentage %>%"></div>
        </div>
        <small class="fw-bold"><%= String.format("%.1f", percentage) %>% of your goals achieved!</small>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>