<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer customerId = (Integer) session.getAttribute("customerId");
    String customerName = (String) session.getAttribute("customerName");

    if(customerId == null){
        response.sendRedirect("customerLogin.jsp?msg=loginfirst");
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
    <title>Order History - MartSmart</title>
    
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

        /* --- NAVIGATION --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        /* --- ORDER CARDS --- */
        .order-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 25px;
            padding: 30px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            margin-bottom: 30px;
            border: none;
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
            padding-bottom: 15px;
            margin-bottom: 15px;
        }

        .status-badge {
            padding: 5px 15px;
            border-radius: 50px;
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
        }

        /* Status Colors */
        .status-delivered { background: #d4edda; color: #155724; }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-shipped { background: #cce5ff; color: #004085; }

        .item-table { font-size: 0.9rem; }
        .item-table thead { color: #888; border-bottom: 1px solid #f0f0f0; }

        /* --- BUTTONS --- */
        .btn-pay {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            color: white; border: none; font-weight: 700; border-radius: 10px;
        }
        .btn-invoice { background: #333; color: white; border: none; font-weight: 600; border-radius: 10px; }
        .btn-feedback { border: 2px solid #ee0979; color: #ee0979; background: transparent; font-weight: 700; border-radius: 10px; }
        .btn-feedback:hover { background: #ee0979; color: white; }

        .empty-state { color: white; text-align: center; padding: 100px 0; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="customerDashboard.jsp">
            <i class="fas fa-history me-2"></i>MARTSMART
        </a>
        <div class="ms-auto d-flex align-items-center">
           <ul class="navbar-nav ms-auto align-items-center">
    
    <li class="nav-item">
        <a class="nav-link" href="customerDashboard.jsp">
            <i class="fas fa-home me-1"></i> Home
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="cart.jsp">
            <i class="fas fa-shopping-cart me-1"></i> Cart
        </a>
    </li>

    <li class="nav-item">
        <a class="nav-link" href="myOrders.jsp">
            <i class="fas fa-box-open me-1"></i> My Orders
        </a>
    </li>

    <li class="nav-item mx-lg-3 my-2 my-lg-0">
        <div class="bg-white rounded-pill px-3 py-1 text-dark small fw-bold">
            <i class="fas fa-user-circle me-1 text-primary"></i> <%= customerName %>
        </div>
    </li>

    <li class="nav-item">
        <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="LogoutServlet">
            <i class="fas fa-sign-out-alt me-1"></i> Logout
        </a>
    </li>

</ul>

        </div>
    </div>
</nav>

<div class="container mt-5 pb-5">
    <h2 class="text-white fw-bold mb-4"><i class="fas fa-box-open me-2"></i>My Order History</h2>

    <%
        boolean hasOrders = false;
        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(
                "SELECT o.*, s.shop_name FROM orders o " +
                "LEFT JOIN shops s ON o.shop_id = s.shop_id " +
                "WHERE o.customer_id = ? ORDER BY o.order_date DESC"
            );
            ps.setInt(1, customerId);
            rs = ps.executeQuery();

            while(rs.next()){
                hasOrders = true;
                int orderId = rs.getInt("order_id");
                String status = rs.getString("status");
                String payStatus = rs.getString("payment_status");
                double total = rs.getDouble("total_amount");
                String shopName = rs.getString("shop_name");
                
                // Determine Badge Class
                String statusClass = "status-pending";
                if("delivered".equalsIgnoreCase(status)) statusClass = "status-delivered";
                if("shipped".equalsIgnoreCase(status)) statusClass = "status-shipped";
    %>
    
    <div class="order-container">
        <div class="order-header">
            <div>
                <span class="text-muted small">ORDER ID</span>
                <h5 class="fw-bold mb-0">#<%= orderId %> <span class="ms-2 text-dark opacity-50">| <%= shopName %></span></h5>
            </div>
            <div class="text-end">
                <span class="status-badge <%= statusClass %>"><%= status %></span>
                <div class="small fw-bold mt-1 <%= "paid".equalsIgnoreCase(payStatus) ? "text-success" : "text-danger" %>">
                    <i class="fas <%= "paid".equalsIgnoreCase(payStatus) ? "fa-check-circle" : "fa-clock" %>"></i> 
                    <%= payStatus.toUpperCase() %>
                </div>
            </div>
        </div>

        <div class="table-responsive">
            <table class="table item-table table-borderless align-middle">
                <thead>
                    <tr>
                        <th width="50%">Item Description</th>
                        <th>Qty</th>
                        <th>Price</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    PreparedStatement psItems = con.prepareStatement(
                        "SELECT oi.*, si.item_name FROM order_items oi " +
                        "LEFT JOIN shop_items si ON oi.item_id = si.item_id " +
                        "WHERE oi.order_id = ?"
                    );
                    psItems.setInt(1, orderId);
                    ResultSet rsItems = psItems.executeQuery();

                    while(rsItems.next()){
                        int orderItemId = rsItems.getInt("order_item_id");
                %>
                    <tr>
                        <td class="fw-bold text-dark"><%= rsItems.getString("item_name") %></td>
                        <td>x<%= rsItems.getInt("quantity") %></td>
                        <td>₹<%= rsItems.getDouble("price") %></td>
                        <td class="text-end">
                            <% if("paid".equalsIgnoreCase(payStatus)) { 
                                // Check for feedback
                                PreparedStatement psF = con.prepareStatement("SELECT feedback_id FROM feedback WHERE order_item_id=?");
                                psF.setInt(1, orderItemId);
                                ResultSet rsF = psF.executeQuery();
                                if(rsF.next()) { %>
                                    <span class="badge rounded-pill bg-light text-success border"><i class="fas fa-check me-1"></i>Rated</span>
                                <% } else { %>
                                    <a href="feedback.jsp?orderId=<%= orderId %>&orderItemId=<%= orderItemId %>" class="btn btn-feedback btn-sm">Rate Product</a>
                                <% } 
                                rsF.close(); psF.close();
                            } %>
                        </td>
                    </tr>
                <% } rsItems.close(); psItems.close(); %>
                </tbody>
            </table>
        </div>

        <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
            <div>
                <span class="text-muted small">GRAND TOTAL</span>
                <h4 class="fw-extrabold mb-0">₹<%= total %></h4>
            </div>
            <div class="d-flex gap-2">
                <% if("delivered".equalsIgnoreCase(status) && "unpaid".equalsIgnoreCase(payStatus)) { %>
                    <form action="PayNowServlet" method="post">
                        <input type="hidden" name="orderId" value="<%= orderId %>">
                        <input type="hidden" name="amount" value="<%= total %>">
                        <button type="submit" class="btn btn-pay px-4 py-2">Pay ₹<%= total %></button>
                    </form>
                <% } %>
                
                <% if("paid".equalsIgnoreCase(payStatus)) { %>
                    <a href="DownloadInvoiceServlet?orderId=<%= orderId %>" class="btn btn-invoice px-3 py-2">
                        <i class="fas fa-file-invoice me-1"></i> Invoice
                    </a>
                <% } %>
            </div>
        </div>
    </div>

    <% 
            } // end while
            if(!hasOrders) { %>
                <div class="empty-state">
                    <i class="fas fa-box-open fa-5x mb-4 opacity-25"></i>
                    <h3>No orders yet!</h3>
                    <p>When you buy items, they will appear here.</p>
                    <a href="customerDashboard.jsp" class="btn btn-light rounded-pill px-4 mt-3">Start Shopping</a>
                </div>
            <% }
        } catch(Exception e){ e.printStackTrace(); }
        finally {
            if(rs != null) rs.close();
            if(ps != null) ps.close();
            if(con != null) con.close();
        }
    %>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>