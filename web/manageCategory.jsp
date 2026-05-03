<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // SHOP SESSION CHECK
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
    <title>Manage Categories - MartSmart</title>

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

        /* --- GLASS NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        /* --- CARDS & FORMS --- */
        .card {
            border: none;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.98);
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .add-category-card {
            max-width: 500px;
            margin: 40px auto;
            padding: 30px;
            animation: fadeInUp 0.6s ease-out;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .form-control {
            border-radius: 10px;
            padding: 12px;
            border: 1px solid #eee;
        }

        .form-control:focus {
            border-color: #ee0979;
            box-shadow: 0 0 0 0.25rem rgba(238, 9, 121, 0.1);
        }

        /* --- BUTTONS --- */
        .btn-add {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            border: none;
            color: white;
            font-weight: 700;
            border-radius: 50px;
            padding: 10px 30px;
            transition: 0.3s;
        }
        .btn-add:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(238, 9, 121, 0.4);
            color: white;
        }

        .btn-delete {
            background: #fff;
            border: 1px solid #ff4d4d;
            color: #ff4d4d;
            border-radius: 50px;
            padding: 5px 15px;
            font-size: 0.85rem;
            transition: 0.3s;
        }
        .btn-delete:hover {
            background: #ff4d4d;
            color: white;
        }

        /* --- TABLE --- */
        .table-container { padding: 20px; }
        .table thead th {
            background: #f8f9fa;
            border: none;
            color: #666;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 1px;
        }
        .category-name {
            font-weight: 600;
            color: #333;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp">
            <i class="fas fa-store me-2 text-white"></i><%= shopName.toUpperCase() %>
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
    <div class="add-category-card card">
        <h4 class="fw-bold mb-4" style="color: #ee0979;">Create New Category</h4>
        <form action="AddCategoryServlet" method="post">
            <div class="mb-4">
                <label class="form-label text-muted small fw-bold">CATEGORY TITLE</label>
                <input type="text" name="categoryName" class="form-control" placeholder="e.g. Fresh Vegetables, Dairy, etc." required>
            </div>
            <div class="text-end">
                <button type="submit" class="btn btn-add">
                    SAVE CATEGORY <i class="fas fa-plus-circle ms-2"></i>
                </button>
            </div>
        </form>
    </div>

    <div class="card">
        <div class="p-4 border-bottom bg-light d-flex justify-content-between align-items-center">
            <h5 class="m-0 fw-bold">Organized Categories</h5>
            <span class="badge bg-secondary rounded-pill">Shop ID: <%= shopId %></span>
        </div>
        
        <div class="table-container">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th width="15%">ID</th>
                            <th>Category Title</th>
                            <th width="20%" class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                con = DBConnection.getConnection();
                                ps = con.prepareStatement("SELECT * FROM shop_categories WHERE shop_id=? ORDER BY category_id DESC");
                                ps.setInt(1, shopId);
                                rs = ps.executeQuery();

                                boolean hasData = false;
                                while(rs.next()){
                                    hasData = true;
                        %>
                        <tr>
                            <td class="text-muted small">#CAT-<%= rs.getInt("category_id") %></td>
                            <td class="category-name"><%= rs.getString("category_name") %></td>
                            <td class="text-center">
                                <a href="DeleteCategoryServlet?id=<%= rs.getInt("category_id") %>" 
                                   class="btn btn-delete" 
                                   onclick="return confirm('Are you sure? This may affect items linked to this category.');">
                                   <i class="fas fa-trash-alt me-1"></i> REMOVE
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                if(!hasData) {
                                    out.println("<tr><td colspan='3' class='text-center py-4 text-muted'>No categories found. Start by adding one above!</td></tr>");
                                }
                            } catch(Exception e) { e.printStackTrace(); }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>