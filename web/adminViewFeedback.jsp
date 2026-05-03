<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
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
    <title>Admin - View Feedback</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body { background: #f2f7ff; }

        .navbar {
            background: linear-gradient(90deg, #0cebeb 0%, #20e3b2 50%, #29ffc6 100%);
        }

        .navbar-brand { font-weight: 700; color: black; }

        .card {
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.15);
        }

        .table thead {
            background: linear-gradient(90deg, #0cebeb, #20e3b2, #29ffc6);
            color: black;
        }

        .search-box input {
            border-radius: 20px;
            padding: 8px 20px;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-expand-lg shadow-sm">
    <div class="container">
        <a class="navbar-brand" href="adminDashboard.jsp">
            <i class="fa fa-user-shield me-2"></i>Admin Panel
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminMenu">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="adminMenu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link text-dark" href="adminDashboard.jsp">
                        <i class="fas fa-tachometer-alt me-1"></i>Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="viewShops.jsp">
                        <i class="fas fa-store me-1"></i>Shops
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="viewAgents.jsp">
                        <i class="fas fa-users me-1"></i>Agents
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="viewCustomers.jsp">
                        <i class="fas fa-user me-1"></i>Customers
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="adminViewOrders.jsp">
                        <i class="fas fa-receipt me-1"></i>Orders
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="adminViewFeedback.jsp">
                        <i class="fas fa-comment-dots me-1"></i>Feedback
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="adminCharts.jsp">
                        <i class="fas fa-chart-bar me-1"></i>Charts
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-dark" href="LogoutServlet">
                        <i class="fas fa-sign-out-alt me-1"></i>Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<div class="container mt-4">

    <div class="card">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="fw-bold mb-0">Customer Feedback</h4>

            <div class="search-box">
                <input type="text" id="searchInput" class="form-control" placeholder="Search feedback...">
            </div>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle" id="feedbackTable">
                <thead>
                <tr>
                    <th>#ID</th>
                    <th>Customer Name</th>
                    <th>Shop Name</th>
                    <th>Item Name</th>
                    <th>Rating</th>
                    <th>Feedback</th>
                    <th>Date</th>
                </tr>
                </thead>
                <tbody>
                <%
                    try {
                        con = DBConnection.getConnection();
                        String sql = "SELECT f.id, c.name AS customer_name, s.shop_name, f.item_name, f.rating, f.feedback_text, f.created_at " +
                                "FROM feedback f " +
                                "LEFT JOIN customers c ON f.customer_id = c.id " +
                                "LEFT JOIN shops s ON f.shop_id = s.id " +
                                "ORDER BY f.created_at DESC";

                        ps = con.prepareStatement(sql);
                        rs = ps.executeQuery();

                        while (rs.next()) {
                %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getString("customer_name") %></td>
                    <td><%= rs.getString("shop_name") %></td>
                    <td><%= rs.getString("item_name") %></td>
                    <td><%= rs.getInt("rating") %>/5</td>
                    <td><%= rs.getString("feedback_text") %></td>
                    <td><%= rs.getString("created_at") %></td>
                </tr>
                <%
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    // Search filter
    document.getElementById("searchInput").addEventListener("keyup", function () {
        let filter = this.value.toLowerCase();
        document.querySelectorAll("#feedbackTable tbody tr").forEach(row => {
            let text = row.innerText.toLowerCase();
            row.style.display = text.includes(filter) ? "" : "none";
        });
    });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>

</body>
</html>
