<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer shopId = (Integer) session.getAttribute("shopId");
    String shopName = (String) session.getAttribute("shopName");
    if(shopId == null){
        response.sendRedirect("shopLogin.jsp?msg=loginfirst");
        return;
    }

    int itemId = Integer.parseInt(request.getParameter("id"));
    Connection con = DBConnection.getConnection();
    PreparedStatement ps = con.prepareStatement(
        "SELECT * FROM shop_items WHERE item_id=? AND shop_id=?"
    );
    ps.setInt(1, itemId);
    ps.setInt(2, shopId);
    ResultSet rs = ps.executeQuery();
    if(!rs.next()){
        response.sendRedirect("manageItems.jsp?msg=Item not found");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Item | <%= shopName %></title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">
    <style>
        :root {
            --sunset-start: #ee0979;
            --sunset-end: #ff6a00;
        }

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

       
        .navbar .navbar-brand, .navbar .nav-link {
            color: white !important;
            font-weight: 600;
        }

        /* --- EDIT CARD --- */
        .edit-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-top: 50px;
        }

        .image-preview-section {
            background: #f8f9fa;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px;
            border-right: 1px solid #eee;
        }

        .current-img-frame {
            width: 250px;
            height: 250px;
            object-fit: cover;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            border: 5px solid white;
        }

        .form-section {
            padding: 40px;
        }

        .form-label {
            font-weight: 600;
            color: #555;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-control {
            border-radius: 10px;
            padding: 12px;
            border: 1px solid #ddd;
        }

        .form-control:focus {
            border-color: var(--sunset-start);
            box-shadow: 0 0 0 0.25rem rgba(238, 9, 121, 0.1);
        }

        /* --- BUTTONS --- */
        .btn-update {
            background: linear-gradient(90deg, var(--sunset-start), var(--sunset-end));
            border: none;
            color: white;
            font-weight: 700;
            padding: 12px 30px;
            border-radius: 10px;
            transition: 0.3s;
        }

        .btn-update:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(238, 9, 121, 0.3);
            color: white;
        }

        .btn-cancel {
            background: #f1f1f1;
            color: #666;
            border: none;
            padding: 12px 30px;
            border-radius: 10px;
            font-weight: 600;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp">
            <i class="fas fa-store me-2"></i><%= shopName.toUpperCase() %>
        </a>
        <div class="ms-auto">
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

<div class="container">
    <div class="row justify-content-center">
        <div class="col-lg-10">
            <div class="edit-container">
                <form action="EditItemServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="itemId" value="<%= rs.getInt("item_id") %>">
                    
                    <div class="row g-0">
                        <div class="col-md-5 image-preview-section text-center">
                            <h5 class="mb-4 fw-bold">Item Visual</h5>
                            <% if(rs.getString("item_image") != null){ %>
                                <img src="uploads/<%= rs.getString("item_image") %>" class="current-img-frame" id="imgPreview">
                            <% } else { %>
                                <div class="current-img-frame d-flex align-items-center justify-content-center bg-secondary text-white">
                                    <i class="fas fa-box-open fa-4x"></i>
                                </div>
                            <% } %>
                            
                            <div class="mt-3 w-100 px-4">
                                <label class="form-label">Replace Image</label>
                                <input type="file" name="itemImage" class="form-control form-control-sm" accept="image/*" onchange="previewFile()">
                                <small class="text-muted mt-2 d-block">Recommended: 500x500px JPG/PNG</small>
                            </div>
                        </div>

                        <div class="col-md-7 form-section">
                            <h4 class="fw-bold mb-4">Product Details</h4>
                            
                            <div class="mb-3">
                                <label class="form-label">Item Name</label>
                                <input type="text" name="itemName" class="form-control" value="<%= rs.getString("item_name") %>" required>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Price (₹)</label>
                                    <input type="number" name="price" class="form-control" value="<%= rs.getDouble("price") %>" step="0.01" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Stock Quantity</label>
                                    <input type="number" name="quantity" class="form-control" value="<%= rs.getInt("quantity") %>" required>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label">Category</label>
                                <select name="categoryId" class="form-select form-control" required>
                                    <%
                                        PreparedStatement ps2 = con.prepareStatement("SELECT * FROM shop_categories WHERE shop_id=?");
                                        ps2.setInt(1, shopId);
                                        ResultSet rs2 = ps2.executeQuery();
                                        while(rs2.next()){
                                            int cid = rs2.getInt("category_id");
                                            String cname = rs2.getString("category_name");
                                            String selected = cid == rs.getInt("category_id") ? "selected" : "";
                                    %>
                                    <option value="<%= cid %>" <%= selected %>><%= cname %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="d-flex gap-2 pt-2">
                                <button type="submit" class="btn btn-update flex-grow-1">
                                    <i class="fas fa-save me-2"></i> Save Changes
                                </button>
                                <a href="manageItems.jsp" class="btn btn-cancel">Cancel</a>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    // Live Image Preview Function
    function previewFile() {
        const preview = document.getElementById('imgPreview');
        const file = document.querySelector('input[type=file]').files[0];
        const reader = new FileReader();

        reader.addEventListener("load", function () {
            preview.src = reader.result;
        }, false);

        if (file) {
            reader.readAsDataURL(file);
        }
    }
</script>
<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>