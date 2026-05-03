<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer shopId = (Integer) session.getAttribute("shopId");
    String shopName = (String) session.getAttribute("shopName");

    if (shopId == null) {
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
    <title>Inventory Management - MartSmart</title>

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

        /* --- FORMS & CARDS --- */
        .card {
            border: none;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.98);
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
        }

        .add-item-card {
            max-width: 800px;
            margin: 30px auto;
            padding: 30px;
            animation: slideUp 0.6s ease-out;
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .form-label { font-weight: 700; font-size: 0.75rem; color: #666; letter-spacing: 1px; }
        .form-control, .form-select { border-radius: 10px; border: 1px solid #eee; padding: 10px; }

        /* --- TABLE STYLING --- */
        .item-img { 
            width: 60px; height: 60px; 
            border-radius: 12px; 
            object-fit: cover;
            border: 2px solid #f0f0f0;
        }

        .price-tag { color: #ee0979; font-weight: 800; }
        .stock-badge { font-weight: 600; padding: 5px 12px; border-radius: 50px; }

        /* --- BUTTONS --- */
        .btn-gradient {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            border: none; color: white; font-weight: 700;
            border-radius: 50px; padding: 12px 25px;
        }
        .btn-gradient:hover { transform: scale(1.03); color: white; box-shadow: 0 5px 15px rgba(238, 9, 121, 0.3); }

        .action-icon {
            width: 35px; height: 35px;
            display: inline-flex; align-items: center; justify-content: center;
            border-radius: 10px; transition: 0.3s;
        }
        .btn-edit-alt { background: #e7f1ff; color: #0d6efd; }
        .btn-delete-alt { background: #fff5f5; color: #ff4d4d; }
        .btn-edit-alt:hover { background: #0d6efd; color: white; }
        .btn-delete-alt:hover { background: #ff4d4d; color: white; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp">
            <i class="fas fa-boxes me-2"></i><%= shopName.toUpperCase() %>
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

<div class="container pb-5">
    <div class="add-item-card card">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold m-0" style="color: #ee0979;">Stock New Product</h4>
            <i class="fas fa-plus-circle fa-2x opacity-25"></i>
        </div>
        
        <form action="AddItemServlet" method="post" enctype="multipart/form-data">
            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">DEPARTMENT / CATEGORY</label>
                    <select name="categoryId" class="form-select" required>
                        <option value="">Select Category</option>
                        <%
                            try {
                                con = DBConnection.getConnection();
                                ps = con.prepareStatement("SELECT * FROM shop_categories WHERE shop_id=?");
                                ps.setInt(1, shopId);
                                rs = ps.executeQuery();
                                while(rs.next()){
                        %>
                        <option value="<%= rs.getInt("category_id") %>"><%= rs.getString("category_name") %></option>
                        <%
                                }
                            } catch(Exception e){ e.printStackTrace(); }
                        %>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">PRODUCT NAME</label>
                    <input type="text" name="itemName" class="form-control" placeholder="e.g. Organic Apples" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">PRICE (₹)</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white border-end-0">₹</span>
                        <input type="number" name="price" class="form-control border-start-0" placeholder="0.00" step="0.01" required>
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="form-label">STOCK QTY</label>
                    <input type="number" name="quantity" class="form-control" placeholder="Units" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">IMAGE UPLOAD</label>
                    <input type="file" name="itemImage" class="form-control" accept="image/*">
                </div>
                <div class="col-12 text-end mt-4">
                    <button type="submit" class="btn btn-gradient px-5">ADD TO INVENTORY</button>
                </div>
            </div>
        </form>
    </div>

    <div class="card overflow-hidden">
        <div class="bg-light p-4 border-bottom d-flex justify-content-between align-items-center">
            <h5 class="m-0 fw-bold"><i class="fas fa-list-ul me-2 text-muted"></i>Current Inventory</h5>
            <div class="search-box">
                </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="bg-white text-muted small fw-bold">
                    <tr>
                        <th class="ps-4">PRODUCT</th>
                        <th>CATEGORY</th>
                        <th>PRICE</th>
                        <th>STOCK STATUS</th>
                        <th class="text-end pe-4">ACTIONS</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        ps = con.prepareStatement(
                            "SELECT i.*, c.category_name FROM shop_items i " +
                            "LEFT JOIN shop_categories c ON i.category_id = c.category_id " +
                            "WHERE i.shop_id=? ORDER BY i.item_id DESC"
                        );
                        ps.setInt(1, shopId);
                        rs = ps.executeQuery();
                        while(rs.next()){
                            int stock = rs.getInt("quantity");
                %>
                    <tr>
                        <td class="ps-4">
                            <div class="d-flex align-items-center">
                                <% if(rs.getString("item_image") != null){ %>
                                    <img src="uploads/<%= rs.getString("item_image") %>" class="item-img me-3">
                                <% } else { %>
                                    <div class="item-img me-3 bg-light d-flex align-items-center justify-content-center text-muted">
                                        <i class="fas fa-image"></i>
                                    </div>
                                <% } %>
                                <div>
                                    <div class="fw-bold text-dark"><%= rs.getString("item_name") %></div>
                                    <small class="text-muted">ID: #<%= rs.getInt("item_id") %></small>
                                </div>
                            </div>
                        </td>
                        <td><span class="badge bg-light text-dark border"><%= rs.getString("category_name") %></span></td>
                        <td><span class="price-tag">₹<%= rs.getDouble("price") %></span></td>
                        <td>
                            <% if(stock > 10) { %>
                                <span class="stock-badge bg-success-subtle text-success"><%= stock %> in stock</span>
                            <% } else if(stock > 0) { %>
                                <span class="stock-badge bg-warning-subtle text-warning">Low: <%= stock %></span>
                            <% } else { %>
                                <span class="stock-badge bg-danger-subtle text-danger">Out of Stock</span>
                            <% } %>
                        </td>
                        <td class="text-end pe-4">
                            <a href="editItems.jsp?id=<%= rs.getInt("item_id") %>" class="action-icon btn-edit-alt mx-1" title="Edit">
                                <i class="fas fa-pen"></i>
                            </a>
                            <a href="DeleteItemServlet?id=<%= rs.getInt("item_id") %>" 
                               class="action-icon btn-delete-alt mx-1" 
                               onclick="return confirm('Delete this product? This cannot be undone.');">
                                <i class="fas fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                <%
                        }
                    } catch(Exception e){ e.printStackTrace(); }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>