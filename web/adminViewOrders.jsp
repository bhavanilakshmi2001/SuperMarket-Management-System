<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // =====================================
    // ADMIN SESSION CHECK
    // =====================================
    String adminId = (String) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect("adminLogin.jsp?msg=loginfirst");
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
    <title>Order Management - MartSmart Admin</title>
    
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
            font-family: 'Segoe UI', sans-serif;
        }

        /* --- NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        /* --- SEARCH BOX --- */
        .search-box {
            border-radius: 50px;
            padding-left: 20px;
            border: none;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        /* --- ORDER CARD --- */
        .order-card {
            background: rgba(255, 255, 255, 0.98);
            border-radius: 20px;
            border: none;
            margin-bottom: 30px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            transition: 0.3s;
        }
        .order-card:hover { transform: translateY(-5px); }

        .order-header {
            background: #f8f9fa;
            padding: 15px 25px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .order-id { font-weight: 800; color: #ee0979; font-size: 1.1rem; }
        
        .section-title {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #999;
            margin-bottom: 10px;
            font-weight: 700;
        }

        /* --- ITEM ROWS --- */
        .item-list { background: #fff; padding: 15px 25px; border-top: 1px dashed #ddd; }
        .item-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #f8f9fa;
        }
        .item-row:last-child { border-bottom: none; }

        .feedback-box {
            background: #fff9e6;
            border-radius: 10px;
            padding: 10px 15px;
            margin-top: 5px;
            font-size: 0.85rem;
            border-left: 4px solid #ffc107;
        }
        .star-active { color: #ffc107; }
        .star-inactive { color: #dee2e6; }
        
        .status-pill {
            padding: 5px 15px;
            border-radius: 50px;
            font-size: 0.75rem;
            font-weight: 700;
            background: #e3f2fd;
            color: #1976d2;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="adminDashboard.jsp">
            <i class="fa fa-user-shield me-2"></i>ADMIN PANEL
        </a>
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
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-center mb-5">
        <h2 class="text-white fw-bold mb-3 mb-md-0">Order Tracking Central</h2>
        <div style="width: 300px;">
            <input type="text" id="searchInput" class="form-control search-box" placeholder="Search by ID, Shop or Customer...">
        </div>
    </div>

    <%
        try {
            con = DBConnection.getConnection();
            String sql = "SELECT o.order_id, o.order_date, o.total_amount, o.status, o.payment_status, " +
                         "s.shop_name, s.shop_address, " +
                         "c.name AS customer_name, c.address AS customer_address, c.city, c.phone AS customer_phone, " +
                         "a.name AS agent_name, " +
                         "si.item_name, oi.quantity, oi.price, oi.order_item_id, f.rating, f.comments AS feedback_comments " +
                         "FROM orders o " +
                         "LEFT JOIN shops s ON o.shop_id = s.shop_id " +
                         "LEFT JOIN customers c ON o.customer_id = c.customer_id " +
                         "LEFT JOIN agents a ON o.agent_id = a.agent_id " +
                         "LEFT JOIN order_items oi ON o.order_id = oi.order_id " +
                         "LEFT JOIN shop_items si ON oi.item_id = si.item_id " +
                         "LEFT JOIN feedback f ON oi.order_item_id = f.order_item_id " +
                         "ORDER BY o.order_id DESC";

            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            int lastOrderId = -1;
            boolean firstCard = true;

            while(rs.next()) {
                int currentOrderId = rs.getInt("order_id");

                if(currentOrderId != lastOrderId) {
                    if(!firstCard) { %>
                            </div> </div> <% }
                    firstCard = false;
                    lastOrderId = currentOrderId;
    %>
    <div class="order-card search-block">
        <div class="order-header">
            <div>
                <span class="order-id">#ORD-<%= currentOrderId %></span>
                <span class="ms-3 text-muted small"><i class="far fa-calendar-alt me-1"></i> <%= rs.getString("order_date") %></span>
            </div>
            <div>
                <span class="status-pill text-uppercase"><%= rs.getString("status") %></span>
                <span class="fw-bold ms-3 text-dark">₹<%= rs.getDouble("total_amount") %></span>
            </div>
        </div>

    <div class="p-4 row">
    <div class="col-md-4 mb-3 mb-md-0">
        <div class="section-title">Merchant</div>
        <div class="fw-bold text-dark"><%= (rs.getString("shop_name") != null) ? rs.getString("shop_name") : "---" %></div>
        <div class="small text-muted"><%= (rs.getString("shop_address") != null) ? rs.getString("shop_address") : "---" %></div>
    </div>

    <div class="col-md-4 mb-3 mb-md-0">
        <div class="section-title">Recipient</div>
        <div class="fw-bold text-dark"><%= (rs.getString("customer_name") != null) ? rs.getString("customer_name") : "---" %></div>
        <div class="small text-muted">
            <% 
                String cAddr = rs.getString("customer_address");
                String cCity = rs.getString("city");
                if ((cAddr == null || cAddr.trim().isEmpty()) && (cCity == null || cCity.trim().isEmpty())) {
                    out.print("---");
                } else {
                    out.print((cAddr != null ? cAddr : "---") + ", " + (cCity != null ? cCity : "---"));
                }
            %>
            <br>
            <i class="fas fa-phone-alt me-1"></i> <%= (rs.getString("customer_phone") != null) ? rs.getString("customer_phone") : "---" %>
        </div>
    </div>

    <div class="col-md-4">
        <div class="section-title">Logistics</div>
        <% 
            String aName = rs.getString("agent_name");
            if(aName != null && !aName.trim().isEmpty()) { 
        %>
            <div class="fw-bold text-dark"><i class="fas fa-truck me-1"></i> <%= aName %></div>
            <div class="small text-success">Agent Assigned</div>
        <% } else { %>
            <div class="text-muted fw-bold small"><i class="fas fa-minus me-1"></i> ---</div>
            <div class="x-small text-muted">No Logistics Data</div>
        <% } %>
    </div>
</div>

        <div class="item-list">
            <div class="section-title mb-2">Order Content & Feedback</div>
    <% } %>

            <div class="item-row">
                <div class="text-dark">
                    <span class="fw-bold"><%= rs.getInt("quantity") %>x</span> <%= rs.getString("item_name") %>
                </div>
                <div class="fw-bold text-muted">₹<%= rs.getDouble("price") %></div>
            </div>

            <% 
                int rating = rs.getInt("rating");
                if(!rs.wasNull() && rating > 0) { 
            %>
                <div class="feedback-box">
                    <div class="mb-1">
                        <% for(int i=1; i<=5; i++) { %>
                            <i class="fas fa-star <%= (i <= rating) ? "star-active" : "star-inactive" %>"></i>
                        <% } %>
                        <span class="ms-2 fw-bold text-dark"><%= rating %>/5</span>
                    </div>
                    <div class="text-muted italic">"<%= rs.getString("feedback_comments") %>"</div>
                </div>
            <% } %>

    <%
            } // end while
            if(!firstCard) { %> </div></div> <% } // Close last card
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            try { if(rs != null) rs.close(); } catch(Exception e) {}
            try { if(ps != null) ps.close(); } catch(Exception e) {}
            try { if(con != null) con.close(); } catch(Exception e) {}
        }
    %>
</div>

<script>
    document.getElementById("searchInput").addEventListener("keyup", function() {
        let filter = this.value.toLowerCase();
        document.querySelectorAll(".search-block").forEach(card => {
            let text = card.innerText.toLowerCase();
            card.style.display = text.includes(filter) ? "" : "none";
        });
    });
</script>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>