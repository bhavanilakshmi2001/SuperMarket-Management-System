<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Integer agentId = (Integer) session.getAttribute("agentId");
    String agentName = (String) session.getAttribute("agentName");

    if(agentId == null){
        response.sendRedirect("agentLogin.jsp?msg=loginfirst");
        return;
    }

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery History - MartSmart Agent</title>

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

        /* --- NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        /* --- HISTORY CARD --- */
        .history-card {
            background: rgba(255, 255, 255, 0.98);
            border-radius: 20px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            border: none;
            position: relative;
            overflow: hidden;
        }

        .history-card::before {
            content: "";
            position: absolute;
            top: 0; left: 0; width: 5px; height: 100%;
            background: #28a745; /* Success Green for completed */
        }

        .success-badge {
            background: #d4edda;
            color: #155724;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 50px;
            text-transform: uppercase;
        }

        .info-label {
            font-size: 0.7rem;
            text-transform: uppercase;
            font-weight: 700;
            color: #999;
            margin-bottom: 2px;
        }

        .data-text {
            font-weight: 600;
            color: #333;
            font-size: 0.95rem;
        }

        .receipt-table {
            font-size: 0.85rem;
            border-top: 1px dashed #ddd;
            margin-top: 15px;
        }
        
        .total-row {
            border-top: 2px solid #eee;
            font-size: 1.1rem;
            color: #ee0979;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="agentDashboard.jsp">
            <i class="fas fa-history me-2"></i> <%= agentName.toUpperCase() %>
        </a>
        <div class="collapse navbar-collapse">
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
    <div class="d-flex justify-content-between align-items-center mb-4 text-white">
        <h2 class="fw-bold m-0">Delivery History</h2>
        <i class="fas fa-clipboard-check fa-2x opacity-50"></i>
    </div>

    <%
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(
                "SELECT o.order_id, o.order_date, o.total_amount, o.status, " +
                "s.shop_name, c.name AS customer_name, c.address AS customer_address, c.city " +
                "FROM orders o " +
                "LEFT JOIN shops s ON o.shop_id = s.shop_id " +
                "LEFT JOIN customers c ON o.customer_id = c.customer_id " +
                "WHERE o.agent_id = ? AND o.status = 'delivered' " +
                "ORDER BY o.order_date DESC"
            );
            ps.setInt(1, agentId);
            rs = ps.executeQuery();

            boolean hasHistory = false;
            while(rs.next()){
                hasHistory = true;
                int orderId = rs.getInt("order_id");
    %>

    <div class="history-card">
        <div class="d-flex justify-content-between align-items-start mb-3">
            <div>
                <span class="fw-bold text-dark fs-5">#ORD-<%= orderId %></span><br>
                <small class="text-muted"><%= rs.getString("order_date") %></small>
            </div>
            <span class="success-badge"><i class="fas fa-check-circle me-1"></i> Delivered</span>
        </div>

        <div class="row g-3">
            <div class="col-md-4">
                <div class="info-label">Vendor</div>
                <div class="data-text"><%= rs.getString("shop_name") %></div>
            </div>
            <div class="col-md-4">
                <div class="info-label">Customer</div>
                <div class="data-text"><%= rs.getString("customer_name") %></div>
            </div>
            <div class="col-md-4 text-md-end">
                <div class="info-label">Revenue Collected</div>
                <div class="data-text text-success">₹<%= rs.getDouble("total_amount") %></div>
            </div>
        </div>

        <div class="receipt-table pt-3">
            <table class="table table-sm table-borderless mb-0">
                <thead>
                    <tr class="text-muted">
                        <th>Item Description</th>
                        <th class="text-center">Qty</th>
                        <th class="text-end">Subtotal</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    PreparedStatement psItems = con.prepareStatement(
                        "SELECT oi.quantity, oi.price, si.item_name " +
                        "FROM order_items oi " +
                        "JOIN shop_items si ON oi.item_id = si.item_id " +
                        "WHERE oi.order_id = ?"
                    );
                    psItems.setInt(1, orderId);
                    ResultSet rsItems = psItems.executeQuery();
                    while(rsItems.next()){
                %>
                    <tr>
                        <td class="text-muted"><%= rsItems.getString("item_name") %></td>
                        <td class="text-center"><%= rsItems.getInt("quantity") %></td>
                        <td class="text-end">₹<%= rsItems.getInt("quantity") * rsItems.getDouble("price") %></td>
                    </tr>
                <%
                    }
                    rsItems.close();
                    psItems.close();
                %>
                    <tr class="total-row fw-bold">
                        <td colspan="2" class="text-end">Paid in Full</td>
                        <td class="text-end">₹<%= rs.getDouble("total_amount") %></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <%
            }
            if(!hasHistory){
    %>
        <div class="text-center text-white py-5">
            <i class="fas fa-history fa-4x mb-3 opacity-50"></i>
            <h3>No history found</h3>
            <p>You haven't completed any deliveries yet. Get started with your assigned tasks!</p>
            <a href="assignedOrders.jsp" class="btn btn-light rounded-pill mt-3 px-4 fw-bold">View Assigned Tasks</a>
        </div>
    <%
            }
        } catch(Exception e){ e.printStackTrace(); }
        finally {
            try{ if(rs!=null) rs.close(); } catch(Exception e){}
            try{ if(ps!=null) ps.close(); } catch(Exception e){}
            try{ if(con!=null) con.close(); } catch(Exception e){}
        }
    %>

</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>