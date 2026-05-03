<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // SHOP SESSION CHECK
    Integer shopId = (Integer) session.getAttribute("shopId");
    String shopName = (String) session.getAttribute("shopName");

    if (shopId == null) {
        response.sendRedirect("shopLogin.jsp?msg=loginfirst");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    int totalOrders = 0;
    int pendingOrders = 0;
    int deliveredOrders = 0;

    try {
        con = DBConnection.getConnection();

        // Total Orders
        ps = con.prepareStatement("SELECT COUNT(*) AS total FROM orders WHERE shop_id=?");
        ps.setInt(1, shopId);
        rs = ps.executeQuery();
        if(rs.next()) totalOrders = rs.getInt("total");

        // Pending Orders
        ps = con.prepareStatement("SELECT COUNT(*) AS pending FROM orders WHERE shop_id=? AND status='Pending'");
        ps.setInt(1, shopId);
        rs = ps.executeQuery();
        if(rs.next()) pendingOrders = rs.getInt("pending");

        // Delivered Orders
        ps = con.prepareStatement("SELECT COUNT(*) AS delivered FROM orders WHERE shop_id=? AND status='Delivered'");
        ps.setInt(1, shopId);
        rs = ps.executeQuery();
        if(rs.next()) deliveredOrders = rs.getInt("delivered");

    } catch(Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= shopName %> - Shop Manager</title>

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
        }

        /* --- GLASS NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }
        .nav-link:hover { color: #ffd1d1 !important; }

        /* --- STAT CARDS --- */
        .dashboard-container { padding: 40px 20px; }

        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            border: none;
            border-radius: 20px;
            padding: 30px;
            transition: all 0.3s ease;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            height: 100%;
        }

        .stat-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }

        .stat-card i {
            font-size: 3rem;
            background: -webkit-linear-gradient(#ee0979, #ff6a00);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 15px;
        }

        .card-title {
            color: #666;
            text-transform: uppercase;
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 1px;
        }

        .card-count {
            font-size: 2.5rem;
            font-weight: 800;
            color: #333;
        }

        /* --- QUICK ACTIONS --- */
        .action-btn {
            background: rgba(255, 255, 255, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.4);
            color: white;
            border-radius: 15px;
            padding: 20px;
            text-decoration: none;
            display: block;
            transition: 0.3s;
            text-align: center;
            font-weight: 600;
        }

        .action-btn:hover {
            background: white;
            color: #ee0979;
            transform: scale(1.05);
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp">
            <i class="fas fa-store-alt me-2"></i><%= shopName.toUpperCase() %>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#shopMenu">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="shopMenu">
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

<div class="container dashboard-container">
    <div class="row g-4 mb-5">
        <div class="col-md-4">
            <div class="stat-card text-center">
                <i class="fas fa-shopping-bag"></i>
                <div class="card-title">Lifetime Orders</div>
                <div class="card-count"><%= totalOrders %></div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card text-center">
                <i class="fas fa-clock"></i>
                <div class="card-title">Awaiting Prep</div>
                <div class="card-count"><%= pendingOrders %></div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="stat-card text-center">
                <i class="fas fa-check-double text-success"></i>
                <div class="card-title">Completed</div>
                <div class="card-count text-success"><%= deliveredOrders %></div>
            </div>
        </div>
    </div>

    <h4 class="text-white fw-bold mb-4">Quick Actions</h4>
    <div class="row g-3">
        <div class="col-6 col-md-3">
            <a href="manageItems.jsp" class="action-btn">
                <i class="fas fa-plus-circle d-block mb-2 fs-3"></i> Add Product
            </a>
        </div>
        <div class="col-6 col-md-3">
            <a href="viewOrders.jsp" class="action-btn">
                <i class="fas fa-stream d-block mb-2 fs-3"></i> View Orders
            </a>
        </div>
        <div class="col-6 col-md-3">
            <a href="viewFeedback.jsp" class="action-btn">
                <i class="fas fa-star d-block mb-2 fs-3"></i> Reviews
            </a>
        </div>
        <div class="col-6 col-md-3">
            <a href="manageCategory.jsp" class="action-btn">
                <i class="fas fa-tags d-block mb-2 fs-3"></i> Categories
            </a>
        </div>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>