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
    double totalAmount = 0.0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Cart - MartSmart</title>

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

        /* --- CART CONTAINER --- */
        .cart-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 25px;
            border: none;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .table thead {
            background: #333;
            color: white;
            text-transform: uppercase;
            font-size: 0.8rem;
            letter-spacing: 1px;
        }

        .item-img {
            width: 70px;
            height: 70px;
            border-radius: 12px;
            object-fit: cover;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        /* --- QUANTITY UPDATE --- */
        .qty-input {
            width: 60px;
            border-radius: 10px;
            border: 2px solid #eee;
            text-align: center;
            font-weight: bold;
        }

        .btn-update {
            background: #333;
            color: white;
            border-radius: 10px;
            border: none;
            padding: 5px 12px;
            font-size: 0.8rem;
            transition: 0.3s;
        }
        .btn-update:hover { background: #000; }

        /* --- REMOVE BUTTON --- */
        .btn-remove {
            color: #dc3545;
            background: rgba(220, 53, 69, 0.1);
            border: none;
            padding: 8px 15px;
            border-radius: 12px;
            font-weight: 600;
            transition: 0.3s;
        }
        .btn-remove:hover {
            background: #dc3545;
            color: white;
        }

        /* --- FOOTER SECTION --- */
        .cart-summary {
            background: #f8f9fa;
            padding: 30px;
            border-top: 1px solid #eee;
        }

        .total-label { font-size: 1.1rem; color: #666; }
        .total-value { 
            font-size: 2rem; 
            font-weight: 800; 
            color: #ee0979;
        }

        .btn-checkout {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            color: white;
            border: none;
            border-radius: 15px;
            padding: 15px 40px;
            font-weight: 700;
            font-size: 1.1rem;
            box-shadow: 0 10px 20px rgba(238, 9, 121, 0.3);
            transition: 0.3s;
        }
        .btn-checkout:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(238, 9, 121, 0.4);
            color: white;
        }

        .empty-cart-state {
            padding: 100px 20px;
            text-align: center;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="customerDashboard.jsp">
            <i class="fas fa-shopping-basket me-2"></i>MARTSMART
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
    <div class="cart-card">
        <div class="p-4 border-bottom bg-white">
            <h4 class="m-0 fw-bold text-dark"><i class="fas fa-shopping-cart me-2 text-danger"></i>Review Your Cart</h4>
        </div>

        <div class="table-responsive">
            <table class="table align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-4">Product</th>
                        <th>Price</th>
                        <th>Quantity</th>
                        <th>Subtotal</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    boolean itemsExist = false;
                    try {
                        con = DBConnection.getConnection();
                        ps = con.prepareStatement(
                             "SELECT c.cart_id, c.quantity, i.item_id, i.item_name, i.price, i.item_image " +
                             "FROM cart c JOIN shop_items i ON c.item_id = i.item_id " +
                             "WHERE c.customer_id=?"
                        );
                        ps.setInt(1, customerId);
                        rs = ps.executeQuery();

                        while(rs.next()){
                            itemsExist = true;
                            double price = rs.getDouble("price");
                            int qty = rs.getInt("quantity");
                            double itemTotal = price * qty;
                            totalAmount += itemTotal;
                %>
                <tr>
                    <td class="ps-4">
                        <div class="d-flex align-items-center">
                            <img src="uploads/<%= rs.getString("item_image") %>" class="item-img me-3" alt="item">
                            <div>
                                <h6 class="mb-0 fw-bold"><%= rs.getString("item_name") %></h6>
                                <small class="text-muted">Item ID: #<%= rs.getInt("item_id") %></small>
                            </div>
                        </div>
                    </td>
                    <td>₹<%= price %></td>
                    <td>
                        <form action="UpdateCartQuantityServlet" method="post" class="d-flex align-items-center">
                            <input type="hidden" name="cartId" value="<%= rs.getInt("cart_id") %>">
                            <input type="number" name="quantity" value="<%= qty %>" min="1" class="qty-input me-2">
                            <button type="submit" class="btn-update">Update</button>
                        </form>
                    </td>
                    <td class="fw-bold">₹<%= itemTotal %></td>
                    <td class="text-center">
                        <a href="RemoveCartItemServlet?cartId=<%= rs.getInt("cart_id") %>" 
                           class="btn-remove" 
                           onclick="return confirm('Remove this item from cart?');">
                            <i class="fas fa-trash-alt"></i>
                        </a>
                    </td>
                </tr>
                <%
                        }
                    } catch(Exception e) { e.printStackTrace(); }
                %>
                </tbody>
            </table>
        </div>

        <% if(itemsExist) { %>
            <div class="cart-summary">
                <div class="row align-items-center">
                    <div class="col-md-6 text-center text-md-start mb-3 mb-md-0">
                        <a href="customerDashboard.jsp" class="text-decoration-none text-muted fw-bold">
                            <i class="fas fa-arrow-left me-2"></i> Add more items
                        </a>
                    </div>
                    <div class="col-md-6 text-center text-md-end">
                        <div class="mb-3">
                            <span class="total-label me-3">Estimated Total:</span>
                            <span class="total-value">₹<%= totalAmount %></span>
                        </div>
                        <a href="placeOrder.jsp" class="btn btn-checkout">
                            CHECKOUT NOW <i class="fas fa-chevron-right ms-2"></i>
                        </a>
                    </div>
                </div>
            </div>
        <% } else { %>
            <div class="empty-cart-state">
                <i class="fas fa-shopping-basket fa-5x text-muted mb-4 opacity-25"></i>
                <h2 class="fw-bold text-dark">Your cart is empty</h2>
                <p class="text-muted mb-4">Looks like you haven't added anything to your cart yet.</p>
                <a href="customerDashboard.jsp" class="btn btn-checkout">START SHOPPING</a>
            </div>
        <% } %>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>