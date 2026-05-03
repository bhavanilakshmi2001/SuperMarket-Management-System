<%@ page import="java.sql.*, java.util.*, com.utils.DBConnection" %>
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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Management - MartSmart</title>
    
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">
    
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

        /* --- ORDER CARDS --- */
        .order-card {
            border: none;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.98);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            margin-bottom: 30px;
            overflow: hidden;
            transition: 0.3s;
        }

        .order-card:hover { transform: translateY(-5px); }

        .order-header {
            background: #f8f9fa;
            padding: 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .customer-info { color: #555; font-size: 0.9rem; }
        .order-id-badge {
            background: #ee0979;
            color: white;
            padding: 5px 15px;
            border-radius: 50px;
            font-weight: 700;
        }

        /* --- INTERNAL TABLES --- */
        .item-table { margin: 0; }
        .item-table th { font-size: 0.75rem; text-transform: uppercase; color: #999; border: none; }
        .item-table td { font-weight: 600; color: #333; }

        /* --- STATUS BADGES --- */
        .status-pill {
            padding: 6px 16px;
            border-radius: 50px;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .status-pending { background: #fff4e5; color: #ff9800; }
        .status-approved { background: #e7fbf3; color: #2ecc71; }
        .status-rejected { background: #ffebee; color: #e74c3c; }

        /* --- ACTIONS --- */
        .btn-action {
            border-radius: 12px;
            padding: 8px 20px;
            font-weight: 700;
            font-size: 0.85rem;
            transition: 0.3s;
        }
        .btn-approve-alt { background: #2ecc71; color: white; border: none; }
        .btn-reject-alt { background: #e74c3c; color: white; border: none; }
        .btn-assign-alt { background: #3498db; color: white; border: none; }
        
        .btn-action:hover { opacity: 0.9; transform: scale(1.05); color: white; }

        .agent-select {
            border-radius: 10px;
            border: 1px solid #ddd;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp">
            <i class="fas fa-receipt me-2"></i><%= shopName.toUpperCase() %> ORDERS
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

<div class="container mt-5">
<%
    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement(
            "SELECT o.order_id, o.customer_id, o.total_amount, o.status, o.payment_status, o.agent_id, " +
            "c.name AS customer_name, c.address, c.city, s.city AS shop_city " +
            "FROM orders o " +
            "LEFT JOIN customers c ON o.customer_id=c.customer_id " +
            "JOIN shops s ON o.shop_id=s.shop_id " +
            "WHERE o.shop_id=? ORDER BY o.order_id DESC"
        );
        ps.setInt(1, shopId);
        rs = ps.executeQuery();

        while(rs.next()){
            int orderId = rs.getInt("order_id");
            String status = rs.getString("status").toLowerCase();
            String payment = rs.getString("payment_status");
            String shopCity = rs.getString("shop_city");
%>

    <div class="order-card">
        <div class="order-header">
            <div>
                <span class="order-id-badge">ID: #ORD-<%= orderId %></span>
              <div class="customer-info mt-2">
    <i class="fas fa-user-circle me-1"></i> <b><%= rs.getString("customer_name") %></b> 
    <span class="mx-2">|</span> 
    <i class="fas fa-map-marker-alt me-1"></i> 
    <% 
        String addr = rs.getString("address");
        String cty = rs.getString("city");
        String pStatus = rs.getString("payment_status");
        String ordStatus = rs.getString("status");
        Object agentObj = rs.getObject("agent_id");

        if (agentObj == null || addr == null || addr.trim().isEmpty() || cty == null || cty.trim().isEmpty()) { 
    %>
        <span class="badge rounded-pill bg-light text-dark border px-3" style="font-size: 0.75rem; font-weight: 500;">
            <i class="fas fa-store me-1 text-warning"></i> 
            <% 
                if ("delivered".equalsIgnoreCase(ordStatus)) {
                    out.print("Completed / In-Store Pickup");
                } else if ("paid".equalsIgnoreCase(pStatus)) {
                    out.print("Invoice Generated / Walk-in");
                } else {
                    out.print("In-Store / Walk-in");
                }
            %>
        </span>
    <% } else { %>
        <span class="text-primary fw-bold"><%= addr %>, <%= cty %></span>
    <% } %>
</div>
            </div>
            <div class="text-end">
                <span class="status-pill status-<%= status %>"><%= status %></span>
            </div>
        </div>

        <div class="card-body p-4">
            <div class="row">
                <div class="col-md-7 border-end">
                    <table class="table table-sm item-table">
                        <thead>
                            <tr>
                                <th>Product Name</th>
                                <th class="text-center">Qty</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            PreparedStatement psItem = con.prepareStatement(
                                "SELECT i.item_name, oi.quantity " +
                                "FROM order_items oi " +
                                "JOIN shop_items i ON oi.item_id = i.item_id " +
                                "WHERE oi.order_id=?"
                            );
                            psItem.setInt(1, orderId);
                            ResultSet rsItem = psItem.executeQuery();
                            while(rsItem.next()){
                        %>
                            <tr>
                                <td><%= rsItem.getString("item_name") %></td>
                                <td class="text-center"><%= rsItem.getInt("quantity") %></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="col-md-5 ps-md-4">
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted small">Payment Mode:</span>
                        <span class="fw-bold"><%= payment.toUpperCase() %></span>
                    </div>
                    <div class="d-flex justify-content-between mb-3">
                        <span class="text-muted small">Total Billing:</span>
                        <span class="fs-5 fw-bold text-dark">₹<%= rs.getDouble("total_amount") %></span>
                    </div>

                    <hr>

<div class="agent-section">
    <% 
        String custAddress = rs.getString("address");
        String custCity = rs.getString("city");
        String payStatus = rs.getString("payment_status");
        int agentId = rs.getInt("agent_id");
        
        // 1. Check if it's a walk-in (Missing address/city)
        boolean isWalkIn = (custAddress == null || custAddress.trim().isEmpty() || custCity == null || custCity.trim().isEmpty());
        
        // 2. New Logic: Show Invoice box if (Walk-in OR No Agent Assigned) AND Payment is Paid
        boolean showInvoiceBox = (isWalkIn || agentId <= 0) && "paid".equalsIgnoreCase(payStatus);
        
        if (showInvoiceBox) { 
    %>
        <div class="p-3 border rounded-3 text-center bg-light">
            <i class="fas fa-file-invoice-dollar mb-2" style="color: #ee0979; font-size: 1.5rem;"></i>
            <div class="small fw-bold text-uppercase" style="color: #ee0979;">Invoice Generated Billing</div>
            <div class="text-muted x-small" style="font-size: 0.75rem;">
                <% if(isWalkIn) { %>
                    Walk-in Customer / In-Store Pickup
                <% } else { %>
                    Delivery Order / Payment Received
                <% } %>
            </div>
        </div>
    <% } else { %>
        <label class="small fw-bold text-muted mb-1">DELIVERY AGENT</label>
        <div class="d-flex align-items-center">
            <%
                if(agentId > 0){
                    PreparedStatement psAgentName = con.prepareStatement("SELECT name FROM agents WHERE agent_id=?");
                    psAgentName.setInt(1, agentId);
                    ResultSet rsAgentName = psAgentName.executeQuery();
                    if(rsAgentName.next()){
            %>
                <div class="text-primary fw-bold"><i class="fas fa-truck me-2"></i><%= rsAgentName.getString("name") %></div>
            <%
                    }
                } else {
            %>
                <span class="text-muted italic small">
                    <i class="fas fa-hourglass-half me-1"></i>
                    <%= "paid".equalsIgnoreCase(payStatus) ? "Processing Assignment..." : "Awaiting Payment..." %>
                </span>
            <% } %>
        </div>
    <% } %>
</div>

<div class="mt-4 d-flex gap-2">
    <% if("pending".equals(status)){ %>
        <a href="ApproveOrderServlet?id=<%= orderId %>" class="btn btn-action btn-approve-alt w-100">APPROVE</a>
        <a href="RejectOrderServlet?id=<%= orderId %>" class="btn btn-action btn-reject-alt w-100">REJECT</a>
    <% } else if("approved".equals(status) && agentId <= 0 && !isWalkIn){ %>
        <form action="AssignAgentServlet" method="post" class="w-100 d-flex gap-2">
            <input type="hidden" name="orderId" value="<%= orderId %>">
            <select name="agentId" class="form-select agent-select" required>
                <option value="">Choose Agent</option>
                <%
                    PreparedStatement psAgent = con.prepareStatement(
                        "SELECT a.agent_id, a.name FROM agents a " +
                        "WHERE a.city=? AND a.status='approved'"
                    );
                    psAgent.setString(1, shopCity);
                    ResultSet rsAgent = psAgent.executeQuery();
                    while(rsAgent.next()){
                %>
                    <option value="<%= rsAgent.getInt("agent_id") %>"><%= rsAgent.getString("name") %></option>
                <% } %>
            </select>
            <button type="submit" class="btn btn-action btn-assign-alt">ASSIGN</button>
        </form>
    <% } %>
</div>
    </div>

<%
        }
    } catch(Exception e){ e.printStackTrace(); }
%>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>