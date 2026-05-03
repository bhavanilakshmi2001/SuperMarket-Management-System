<%@ page import="java.sql.*, java.util.*, com.utils.DBConnection" %>
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

    String customerAddress = "";
    String customerCity = "";

    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement("SELECT address, city FROM customers WHERE customer_id=?");
        ps.setInt(1, customerId);
        rs = ps.executeQuery();

        if(rs.next()){
            customerAddress = rs.getString("address") != null ? rs.getString("address") : "";
            customerCity = rs.getString("city") != null ? rs.getString("city") : "";
        }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - MartSmart</title>

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

        /* --- NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        /* --- CHECKOUT CARDS --- */
        .order-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            margin-bottom: 30px;
            border: none;
        }

        .section-header {
            border-bottom: 2px solid #eee;
            padding-bottom: 15px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }

        .section-icon {
            width: 40px;
            height: 40px;
            background: #ee0979;
            color: white;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
        }

        .section-title {
            font-size: 1.25rem;
            font-weight: 800;
            color: #333;
            margin: 0;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-control {
            border-radius: 12px;
            border: 2px solid #eee;
            padding: 12px;
        }

        .form-control:focus {
            border-color: #ff6a00;
            box-shadow: none;
        }

        /* --- ITEM LIST --- */
        .item-row {
            border-bottom: 1px solid #f0f0f0;
            padding: 15px 0;
        }
        .item-row:last-child { border: none; }

        .item-img {
            width: 50px;
            height: 50px;
            border-radius: 8px;
            object-fit: cover;
        }

        /* --- BUTTONS --- */
        .btn-update {
            background: #333;
            color: white;
            border-radius: 10px;
            font-weight: 600;
            padding: 8px 20px;
            border: none;
        }

        .btn-confirm {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            color: white;
            border: none;
            border-radius: 12px;
            padding: 12px 25px;
            font-weight: 700;
            width: 100%;
            transition: 0.3s;
            box-shadow: 0 5px 15px rgba(238, 9, 121, 0.3);
        }

        .btn-confirm:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(238, 9, 121, 0.4);
            color: white;
        }

        .shop-badge {
            background: #fff0f5;
            color: #ee0979;
            padding: 5px 15px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 0.8rem;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="customerDashboard.jsp">
            <i class="fas fa-shopping-bag me-2"></i>MARTSMART
        </a>
        <div class="ms-auto">
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
    <div class="row">
        <div class="col-lg-5">
            <div class="order-card">
                <div class="section-header">
                    <div class="section-icon"><i class="fas fa-map-marked-alt"></i></div>
                    <h4 class="section-title">Shipping Details</h4>
                </div>
                
                <form action="UpdateAddressServlet" method="post">
                    <div class="mb-3">
                        <label class="form-label fw-bold small text-muted">DELIVERY ADDRESS</label>
                        <textarea name="address" class="form-control" rows="4" placeholder="House No, Building, Street..." required><%= customerAddress %></textarea>
                    </div>

                    <div class="mb-4">
                        <label class="form-label fw-bold small text-muted">CITY / AREA</label>
                        <input type="text" name="city" class="form-control" value="<%= customerCity %>" placeholder="Enter city name" required>
                    </div>

                    <button type="submit" class="btn btn-update w-100">
                        <i class="fas fa-sync-alt me-2"></i>Update Shipping Info
                    </button>
                </form>
            </div>
            
            <div class="alert alert-warning border-0 rounded-4 shadow-sm small">
                <i class="fas fa-info-circle me-2"></i>
                Orders are processed per shop. If you have items from multiple shops, you will confirm them separately.
            </div>
        </div>

        <div class="col-lg-7">
            <%
                // Grouping Logic
                Map<Integer, List<Map<String,Object>>> shopGroups = new LinkedHashMap<>();
                ps = con.prepareStatement(
                    "SELECT c.cart_id, c.shop_id, s.shop_name, i.item_id, i.item_name, i.price, c.quantity, i.item_image " +
                    "FROM cart c " +
                    "JOIN shop_items i ON c.item_id = i.item_id " +
                    "JOIN shops s ON c.shop_id = s.shop_id " +
                    "WHERE c.customer_id=?"
                );
                ps.setInt(1, customerId);
                rs = ps.executeQuery();

                while(rs.next()){
                    int shopId = rs.getInt("shop_id");
                    Map<String,Object> item = new HashMap<>();
                    item.put("item_name", rs.getString("item_name"));
                    item.put("price", rs.getDouble("price"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("item_image", rs.getString("item_image"));
                    item.put("shop_name", rs.getString("shop_name"));
                    
                    shopGroups.computeIfAbsent(shopId, k -> new ArrayList<>()).add(item);
                }

                if(shopGroups.isEmpty()) {
            %>
                <div class="order-card text-center py-5">
                    <i class="fas fa-receipt fa-4x text-muted mb-3 opacity-25"></i>
                    <h4>Nothing to checkout!</h4>
                    <a href="customerDashboard.jsp" class="btn btn-confirm mt-3">Browse Shops</a>
                </div>
            <%
                }

                for(Integer sId : shopGroups.keySet()){
                    List<Map<String,Object>> items = shopGroups.get(sId);
                    String sName = (String) items.get(0).get("shop_name");
                    double shopTotal = 0;
            %>
            <div class="order-card">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold m-0"><i class="fas fa-store text-danger me-2"></i><%= sName %></h5>
                    <span class="shop-badge"><%= items.size() %> Items</span>
                </div>

                <div class="item-list mb-4">
                    <% for(Map<String,Object> item : items) {
                        double price = (double) item.get("price");
                        int qty = (int) item.get("quantity");
                        double rowTotal = price * qty;
                        shopTotal += rowTotal;
                    %>
                    <div class="item-row d-flex align-items-center">
                        <img src="uploads/<%= item.get("item_image") %>" class="item-img me-3">
                        <div class="flex-grow-1">
                            <div class="fw-bold text-dark"><%= item.get("item_name") %></div>
                            <div class="small text-muted">₹<%= price %> x <%= qty %></div>
                        </div>
                        <div class="fw-bold text-dark">₹<%= rowTotal %></div>
                    </div>
                    <% } %>
                </div>

                <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                    <div>
                        <div class="small text-muted">SHOP TOTAL</div>
                        <div class="h4 fw-extrabold text-danger mb-0">₹<%= shopTotal %></div>
                    </div>
                    <form action="PlaceOrderServlet" method="post">
                        <input type="hidden" name="shopId" value="<%= sId %>">
                        <button type="submit" class="btn btn-confirm">
                            CONFIRM ORDER <i class="fas fa-chevron-right ms-2"></i>
                        </button>
                    </form>
                </div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<%
    } catch(Exception e) { e.printStackTrace(); }
    finally {
        if(rs != null) rs.close();
        if(ps != null) ps.close();
        if(con != null) con.close();
    }
%>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>