<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Integer customerId = (Integer) session.getAttribute("customerId");
    String customerName = (String) session.getAttribute("customerName");

    if(customerId == null){
        response.sendRedirect("customerLogin.jsp?msg=loginfirst");
        return;
    }

    Connection con = DBConnection.getConnection();
    PreparedStatement psCity = null, psShops = null;
    ResultSet rsCity = null, rsShops = null;

    // Fetch all city list
    psCity = con.prepareStatement("SELECT DISTINCT city FROM shops ORDER BY city ASC");
    rsCity = psCity.executeQuery();

    // Fetch all shops
    String cityFilter = request.getParameter("city");
    if(cityFilter != null && !cityFilter.equals("")) {
        psShops = con.prepareStatement("SELECT * FROM shops WHERE city = ?");
        psShops.setString(1, cityFilter);
    } else {
        psShops = con.prepareStatement("SELECT * FROM shops ORDER BY shop_id DESC");
    }
    rsShops = psShops.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Explore Shops - MartSmart</title>

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
        .cart-badge { background: #fff; color: #ee0979; font-weight: bold; }

        /* --- SEARCH SECTION --- */
        .search-container {
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 40px;
        }

        /* --- SHOP CARDS --- */
        .shop-card {
            border: none;
            border-radius: 20px;
            background: #fff;
            transition: all 0.3s ease;
            overflow: hidden;
            height: 100%;
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }

        .shop-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
        }

        .shop-img-wrapper {
            position: relative;
            overflow: hidden;
        }

        .shop-img {
            width: 100%;
            height: 200px;
            object-fit: center;
            transition: transform 0.5s ease;
        }

        .shop-card:hover .shop-img {
            transform: scale(1.1);
        }

        .city-tag {
            position: absolute;
            top: 15px;
            right: 15px;
            background: rgba(238, 9, 121, 0.9);
            color: white;
            padding: 4px 12px;
            border-radius: 50px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        .shop-title { color: #333; font-weight: 800; font-size: 1.25rem; }
        .info-text { color: #666; font-size: 0.85rem; margin-bottom: 5px; }
        .info-text i { color: #ff6a00; width: 20px; }

        .btn-view {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            border: none;
            color: white;
            font-weight: 700;
            border-radius: 12px;
            padding: 10px;
            width: 100%;
            transition: 0.3s;
        }

        .btn-view:hover {
            opacity: 0.9;
            color: white;
            letter-spacing: 1px;
        }

        .empty-state {
            color: white;
            text-align: center;
            padding: 50px;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="customerDashboard.jsp">
            <i class="fas fa-shopping-bag me-2"></i>MARTSMART
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#custNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="custNav">
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

<div class="container mt-5">
    <div class="text-center text-white mb-5">
        <h1 class="display-5 fw-bold">Welcome back, <%= customerName %>!</h1>
        <p class="lead opacity-75">Find the best local shops and get essentials delivered to your doorstep.</p>
    </div>

    <div class="search-container">
        <form method="get" action="customerDashboard.jsp" class="row g-3 align-items-center">
            <div class="col-md-9">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted">
                        <i class="fas fa-map-marker-alt"></i>
                    </span>
                    <select name="city" class="form-select border-start-0 py-2 shadow-none" style="font-size: 1.1rem;">
                        <option value="">All Cities - Browse Everywhere</option>
                        <%
                            while(rsCity.next()) {
                                String city = rsCity.getString("city");
                        %>
                        <option value="<%=city%>" <%= city.equals(cityFilter) ? "selected" : "" %>><%=city%></option>
                        <% } %>
                    </select>
                </div>
            </div>
            <div class="col-md-3">
                <button type="submit" class="btn btn-dark w-100 py-2 fw-bold rounded-3">
                    FIND SHOPS
                </button>
            </div>
        </form>
    </div>

    <div class="row g-4">
        <%
            boolean noShops = true;
            while(rsShops.next()) {
                noShops = false;
        %>
        <div class="col-md-6 col-lg-4">
            <div class="shop-card">
                <div class="shop-img-wrapper">
                    <img src="shop_images/<%=rsShops.getString("shop_image")%>" class="shop-img" alt="Store Image">
                    <span class="city-tag"><%=rsShops.getString("city")%></span>
                </div>
                <div class="card-body p-4">
                    <h5 class="shop-title mb-3"><%=rsShops.getString("shop_name")%></h5>
                    
                    <div class="info-text">
                        <i class="fas fa-location-arrow"></i> <%=rsShops.getString("shop_address")%>
                    </div>
                    <div class="info-text mb-4">
                        <i class="fas fa-phone-alt"></i> <%=rsShops.getString("phone")%>
                    </div>

                    <a href="viewShopDetails.jsp?shopId=<%=rsShops.getInt("shop_id")%>" class="btn btn-view">
                        VISIT STORE <i class="fas fa-arrow-right ms-2"></i>
                    </a>
                </div>
            </div>
        </div>
        <% } %>

        <% if(noShops){ %>
        <div class="col-12 empty-state">
            <i class="fas fa-store-slash fa-4x mb-3 opacity-50"></i>
            <h3>No Shops Found</h3>
            <p>We couldn't find any shops in "<%= cityFilter %>" yet. Try another city!</p>
            <a href="customerDashboard.jsp" class="btn btn-light mt-3">Browse All Cities</a>
        </div>
        <% } %>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>