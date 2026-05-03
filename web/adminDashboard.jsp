<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // Admin Session Check
    String adminId = (String) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("adminLogin.jsp?msg=loginfirst");
        return;
    }

    // Database Counters
    Connection con = DBConnection.getConnection();
    int shopCount = 0, customerCount = 0, agentCount = 0, feedbackCount = 0, orderCount = 0;

    try {
        PreparedStatement ps1 = con.prepareStatement("SELECT COUNT(*) FROM shops");
        ResultSet rs1 = ps1.executeQuery();
        if (rs1.next()) shopCount = rs1.getInt(1);

        PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) FROM customers");
        ResultSet rs2 = ps2.executeQuery();
        if (rs2.next()) customerCount = rs2.getInt(1);

        PreparedStatement ps3 = con.prepareStatement("SELECT COUNT(*) FROM agents");
        ResultSet rs3 = ps3.executeQuery();
        if (rs3.next()) agentCount = rs3.getInt(1);

        PreparedStatement ps4 = con.prepareStatement("SELECT COUNT(*) FROM feedback");
        ResultSet rs4 = ps4.executeQuery();
        if (rs4.next()) feedbackCount = rs4.getInt(1);

        PreparedStatement ps5 = con.prepareStatement("SELECT COUNT(*) FROM orders");
        ResultSet rs5 = ps5.executeQuery();
        if (rs5.next()) orderCount = rs5.getInt(1);

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Command Center - MartSmart</title>

    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">

    <style>
        /* --- ANIMATED BACKGROUND --- */
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
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            color: #333;
        }

        /* --- DASHBOARD COMPONENTS --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .navbar-brand, .nav-link {
            color: white !important;
            font-weight: 600;
        }

        .nav-link:hover {
            color: #ffd1d1 !important;
        }

        .dashboard-container {
            margin-top: 40px;
            animation: fadeIn 1s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- STAT CARDS --- */
        .card-stats {
            background: rgba(255, 255, 255, 0.9);
            border: none;
            border-radius: 20px;
            padding: 25px;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            height: 100%;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            position: relative;
            overflow: hidden;
        }

        .card-stats:hover {
            transform: translateY(-10px);
            background: white;
            box-shadow: 0 15px 40px rgba(0,0,0,0.2);
        }

        .icon-box {
            font-size: 2.5rem;
            width: 70px;
            height: 70px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 15px;
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            color: white;
            box-shadow: 0 5px 15px rgba(238, 9, 121, 0.3);
        }

        .stat-label {
            color: #666;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 700;
        }

        .stat-value {
            font-size: 2.2rem;
            font-weight: 800;
            color: #222;
        }

        .section-title {
            color: white;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
            font-weight: 800;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand fs-4" href="adminDashboard.jsp">
            <i class="fa fa-user-shield me-2"></i>ADMIN CENTER
        </a>
        <button class="navbar-toggler border-white" type="button" data-bs-toggle="collapse" data-bs-target="#adminMenu">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="adminMenu">
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

<div class="container dashboard-container mb-5">
    <div class="d-flex justify-content-between align-items-center mb-5">
        <div>
            <h1 class="section-title mb-0">Platform Overview</h1>
            <p class="text-white-50">Manage your supermarket ecosystem</p>
        </div>
        <div class="text-end text-white">
            <span class="badge bg-white text-danger px-3 py-2 rounded-pill shadow-sm fw-bold">ADMIN ACTIVE</span>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-md-4">
            <div class="card-stats d-flex flex-column justify-content-between">
                <div class="d-flex justify-content-between">
                    <div>
                        <p class="stat-label mb-1">Total Shops</p>
                        <h2 class="stat-value mb-0"><%= shopCount %></h2>
                    </div>
                    <div class="icon-box"><i class="fas fa-store"></i></div>
                </div>
                <hr class="my-3 opacity-10">
                <a href="viewShops.jsp" class="text-decoration-none text-danger small fw-bold">View Detail <i class="fas fa-arrow-right ms-1"></i></a>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card-stats d-flex flex-column justify-content-between">
                <div class="d-flex justify-content-between">
                    <div>
                        <p class="stat-label mb-1">Active Users</p>
                        <h2 class="stat-value mb-0"><%= customerCount %></h2>
                    </div>
                    <div class="icon-box"><i class="fas fa-users"></i></div>
                </div>
                <hr class="my-3 opacity-10">
                <a href="viewCustomers.jsp" class="text-decoration-none text-danger small fw-bold">Manage Users <i class="fas fa-arrow-right ms-1"></i></a>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card-stats d-flex flex-column justify-content-between">
                <div class="d-flex justify-content-between">
                    <div>
                        <p class="stat-label mb-1">Delivery Fleet</p>
                        <h2 class="stat-value mb-0"><%= agentCount %></h2>
                    </div>
                    <div class="icon-box"><i class="fas fa-shipping-fast"></i></div>
                </div>
                <hr class="my-3 opacity-10">
                <a href="viewAgents.jsp" class="text-decoration-none text-danger small fw-bold">Agent Registry <i class="fas fa-arrow-right ms-1"></i></a>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card-stats">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <p class="stat-label mb-1">Lifetime Orders</p>
                        <h2 class="stat-value mb-0"><%= orderCount %></h2>
                    </div>
                    <div class="icon-box" style="background: #222;"><i class="fas fa-shopping-bag"></i></div>
                </div>
                <p class="mt-3 text-muted small"><i class="fas fa-clock me-1"></i> Updated in real-time from DB</p>
            </div>
        </div>

        <div class="col-md-6">
            <div class="card-stats">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <p class="stat-label mb-1">Total Feedbacks</p>
                        <h2 class="stat-value mb-0"><%= feedbackCount %></h2>
                    </div>
                    <div class="icon-box" style="background: #222;"><i class="fas fa-comments"></i></div>
                </div>
                <p class="mt-3 text-muted small"><i class="fas fa-star me-1"></i> Customer satisfaction logs</p>
            </div>
        </div>
    </div>

    <div class="mt-5 text-center">
        <a href="adminCharts.jsp" class="btn btn-light rounded-pill px-5 py-3 shadow fw-bold text-danger">
            <i class="fas fa-chart-pie me-2"></i> GO TO ANALYTICS ENGINE
        </a>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>