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
    <title>Assigned Orders - MartSmart Agent</title>

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

        /* --- ORDER CARD --- */
        .order-card {
            background: rgba(255, 255, 255, 0.98);
            border-radius: 20px;
            padding: 25px;
            margin-bottom: 30px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            border: none;
        }

        .order-badge {
            background: #fff0f5;
            color: #ee0979;
            font-weight: 800;
            padding: 5px 15px;
            border-radius: 50px;
            font-size: 0.9rem;
        }

        .delivery-slip {
            background: #fdfdfd;
            border-left: 5px solid #ff6a00;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.02);
        }

        .btn-delivered {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            border: none;
            border-radius: 50px;
            padding: 12px 40px;
            color: white;
            font-weight: 700;
            letter-spacing: 1px;
            transition: 0.3s;
        }
        .btn-delivered:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(238, 9, 121, 0.4);
            color: white;
        }

        .table thead th {
            border: none;
            background-color: #f8f9fa;
            color: #666;
            font-size: 0.8rem;
            text-transform: uppercase;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="agentDashboard.jsp">
            <i class="fas fa-truck-loading me-2"></i> <%= agentName.toUpperCase() %>
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
    <h2 class="text-white fw-bold mb-4">Pending Deliveries</h2>

    <%
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(
                "SELECT o.order_id, o.order_date, o.total_amount, o.status, o.payment_status, " +
                "s.shop_name, s.shop_address, " +
                "c.name AS customer_name, c.phone AS customer_phone, " +
                "c.address AS customer_address, c.city AS customer_city " +
                "FROM orders o " +
                "LEFT JOIN shops s ON o.shop_id = s.shop_id " +
                "LEFT JOIN customers c ON o.customer_id = c.customer_id " +
                "WHERE o.agent_id = ? AND o.status = 'assigned' " +
                "ORDER BY o.order_date DESC"
            );
            ps.setInt(1, agentId);
            rs = ps.executeQuery();

            boolean hasOrders = false;
            while(rs.next()){
                hasOrders = true;
                int orderId = rs.getInt("order_id");
    %>

    <div class="order-card">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <span class="order-badge">#ORD-<%= orderId %></span>
            <span class="text-muted small"><i class="far fa-calendar-alt me-1"></i> <%= rs.getString("order_date") %></span>
        </div>

        <div class="row">
            <div class="col-md-6">
                <div class="delivery-slip">
                    <h6 class="text-uppercase fw-bold text-muted small"><i class="fas fa-arrow-up me-2"></i>Pickup From</h6>
                    <div class="fw-bold text-dark"><%= rs.getString("shop_name") %></div>
                    <div class="small text-muted"><%= rs.getString("shop_address") %></div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="delivery-slip" style="border-left-color: #ee0979;">
                    <h6 class="text-uppercase fw-bold text-muted small"><i class="fas fa-map-marker-alt me-2"></i>Deliver To</h6>
                    <div class="fw-bold text-dark"><%= rs.getString("customer_name") %></div>
                    <div class="small text-muted"><%= rs.getString("customer_address") %>, <%= rs.getString("customer_city") %></div>
                    <div class="mt-2 fw-bold text-primary"><i class="fas fa-phone-alt me-1"></i> <%= rs.getString("customer_phone") %></div>
                </div>
            </div>
        </div>

        <div class="table-responsive mt-3">
            <table class="table align-middle">
                <thead>
                    <tr>
                        <th>Item Description</th>
                        <th class="text-center">Qty</th>
                        <th class="text-end">Price</th>
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
                        <td><%= rsItems.getString("item_name") %></td>
                        <td class="text-center fw-bold"><%= rsItems.getInt("quantity") %></td>
                        <td class="text-end">₹<%= rsItems.getDouble("price") %></td>
                    </tr>
                <%
                    }
                    rsItems.close();
                    psItems.close();
                %>
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="2" class="text-end fw-bold">Total Collection:</td>
                        <td class="text-end fw-bold text-danger fs-5">₹<%= rs.getDouble("total_amount") %></td>
                    </tr>
                </tfoot>
            </table>
        </div>

        <div class="text-center mt-4">
            <form action="MarkDeliveredServlet" method="post">
                <input type="hidden" name="orderId" value="<%= orderId %>">
                <button type="submit" class="btn btn-delivered" 
                        onclick="return confirm('Please confirm you have delivered Order #<%= orderId %>');">
                    COMPLETE DELIVERY <i class="fas fa-check-circle ms-2"></i>
                </button>
            </form>
        </div>
    </div>

    <%
            }
            if(!hasOrders){
    %>
        <div class="text-center text-white py-5">
            <i class="fas fa-box-open fa-4x mb-3 opacity-50"></i>
            <h3>All caught up!</h3>
            <p>No pending orders assigned to you right now.</p>
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