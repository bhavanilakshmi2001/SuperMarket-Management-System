<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    // SESSION CHECK
    Integer customerId = (Integer) session.getAttribute("customerId");
    String customerName = (String) session.getAttribute("customerName");

    if(customerId == null){
        response.sendRedirect("customerLogin.jsp?msg=loginfirst");
        return;
    }

    // PARAMETER CHECK
    String shopIdParam = request.getParameter("shopId");
    if(shopIdParam == null) {
        response.sendRedirect("customerDashboard.jsp");
        return;
    }
    int shopId = Integer.parseInt(shopIdParam);

    Connection con = null;
    PreparedStatement psCat = null;
    PreparedStatement psItems = null;
    ResultSet rsCat = null;
    ResultSet rsItems = null;

    try {
        con = DBConnection.getConnection();

        // Fetch categories for filtering
        psCat = con.prepareStatement("SELECT category_name FROM shop_categories WHERE shop_id=?");
        psCat.setInt(1, shopId);
        rsCat = psCat.executeQuery();

        // Fetch items + analytics
        psItems = con.prepareStatement(
            "SELECT i.*, c.category_name, " +
            "IFNULL(AVG(f.rating),0) AS avg_rating, " +
            "COUNT(f.feedback_id) AS feedback_count " +
            "FROM shop_items i " +
            "LEFT JOIN shop_categories c ON i.category_id = c.category_id " +
            "LEFT JOIN order_items oi ON i.item_id = oi.item_id " +
            "LEFT JOIN feedback f ON oi.order_item_id = f.order_item_id " +
            "WHERE i.shop_id=? " +
            "GROUP BY i.item_id"
        );
        psItems.setInt(1, shopId);
        rsItems = psItems.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Store - MartSmart</title>

    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/all.min.css" rel="stylesheet">

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

        /* --- FILTER BAR --- */
        .filter-section {
            background: rgba(255, 255, 255, 0.98);
            padding: 20px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            margin-bottom: 30px;
        }

        .btn-pill {
            border-radius: 50px;
            padding: 6px 18px;
            font-size: 0.85rem;
            font-weight: 700;
            transition: 0.3s;
            border: 2px solid #ee0979;
            color: #ee0979;
            background: transparent;
        }

        .btn-pill.active, .btn-pill:hover {
            background: #ee0979;
            color: white;
        }

        /* --- PRODUCT CARDS --- */
        .item-card-wrapper {
            border: none;
            border-radius: 20px;
            background: #fff;
            overflow: hidden;
            transition: 0.3s;
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
            height: 100%;
        }

        .item-card-wrapper:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.2);
        }

        .item-img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }

        .price-text {
            font-size: 1.5rem;
            font-weight: 800;
            color: #333;
        }

        .rating-stars { color: #ffc107; font-size: 0.9rem; }

        .btn-add {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            border: none;
            color: white;
            font-weight: 700;
            border-radius: 12px;
            padding: 10px;
            width: 100%;
        }
        
        .fab-cart {
            position: fixed;
            bottom: 30px;
            right: 30px;
            width: 60px;
            height: 60px;
            background: #333;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            z-index: 1000;
            text-decoration: none;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="customerDashboard.jsp">
            <i class="fas fa-arrow-left me-2"></i> EXPLORE STORES
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

<div class="container mt-4 pb-5">

    <div class="filter-section">
        <div class="row g-3 align-items-center">
            <div class="col-md-8">
                <div class="d-flex flex-wrap gap-2">
                    <button class="btn btn-pill active" onclick="filterCategory('all', this)">All Items</button>
                    <% while(rsCat.next()){ 
                        String cName = rsCat.getString("category_name");
                    %>
                        <button class="btn btn-pill" onclick="filterCategory('<%=cName%>', this)">
                            <%=cName%>
                        </button>
                    <% } %>
                </div>
            </div>
            <div class="col-md-4">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="fas fa-search"></i></span>
                    <input type="text" id="searchInput" class="form-control border-start-0 shadow-none" placeholder="Search products...">
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4" id="itemsContainer">
        <%
            boolean noItems = true;
            // No .beforeFirst() needed here; we iterate once.
            while(rsItems.next()){
                noItems = false;
                String itemName = rsItems.getString("item_name");
                double price = rsItems.getDouble("price");
                double rating = rsItems.getDouble("avg_rating");
                int count = rsItems.getInt("feedback_count");
        %>

        <div class="col-md-6 col-lg-4 item-card"
             data-category="<%=rsItems.getString("category_name")%>"
             data-name="<%=itemName.toLowerCase()%>"
             data-price="<%=price%>">

            <div class="item-card-wrapper">
                <img src="uploads/<%=rsItems.getString("item_image")%>" class="item-img" alt="<%=itemName%>">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-start mb-2">
                        <h5 class="fw-bold m-0"><%=itemName%></h5>
                        <span class="badge bg-light text-muted small"><%=rsItems.getString("category_name")%></span>
                    </div>

                    <div class="rating-stars mb-3">
                        <% for(int i=1; i<=5; i++){ %>
                            <i class="<%= i <= Math.round(rating) ? "fas fa-star" : "far fa-star opacity-25" %>"></i>
                        <% } %>
                        <span class="text-muted small ms-1">(<%=count%> reviews)</span>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mt-auto">
                        <div class="price-text">₹<%=price%></div>
                        <form action="AddToCartServlet" method="post" class="w-50">
                            <input type="hidden" name="itemId" value="<%=rsItems.getInt("item_id")%>">
                            <input type="hidden" name="shopId" value="<%=shopId%>">
                            <button type="submit" class="btn btn-add">
                                <i class="fas fa-cart-plus me-1"></i> ADD
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <% } %>

        <% if(noItems){ %>
            <div class="col-12 text-center text-white py-5">
                <i class="fas fa-shopping-basket fa-4x mb-3 opacity-50"></i>
                <h3>Store is empty</h3>
                <p>This shop hasn't listed any products yet. Check back later!</p>
            </div>
        <% } %>
    </div>
</div>

<a href="cart.jsp" class="fab-cart shadow">
    <i class="fas fa-shopping-bag fa-lg"></i>
</a>

<%
    } catch(Exception e) { 
        e.printStackTrace(); 
    } finally {
        if(rsCat != null) rsCat.close();
        if(rsItems != null) rsItems.close();
        if(psCat != null) psCat.close();
        if(psItems != null) psItems.close();
        if(con != null) con.close();
    }
%>

<script>
function filterCategory(cat, btn){
    document.querySelectorAll('.btn-pill').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    document.querySelectorAll('.item-card').forEach(c => {
        c.style.display = (cat === 'all' || c.dataset.category === cat) ? '' : 'none';
    });
}

document.getElementById('searchInput').addEventListener('keyup', function(){
    const q = this.value.toLowerCase();
    document.querySelectorAll('.item-card').forEach(c => {
        const n = c.dataset.name;
        c.style.display = n.includes(q) ? '' : 'none';
    });
});
</script>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>