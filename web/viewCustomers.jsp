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
    <title>Customer Registry - MartSmart Admin</title>
    
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

        /* --- DATA CARD --- */
        .data-card {
            background: rgba(255, 255, 255, 0.98);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- SEARCH BOX --- */
        .search-container {
            position: relative;
            max-width: 400px;
        }
        .search-container i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #ee0979;
        }
        .search-box {
            border-radius: 50px;
            padding-left: 45px;
            border: 2px solid #eee;
            transition: 0.3s;
        }
        .search-box:focus {
            border-color: #ff6a00;
            box-shadow: 0 0 0 0.25rem rgba(255, 106, 0, 0.1);
        }

        /* --- TABLE STYLING --- */
        .table thead th {
            background: #f8f9fa;
            border: none;
            color: #666;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 1px;
            padding: 15px;
        }
        .table td { vertical-align: middle; padding: 15px; border-bottom: 1px solid #f1f1f1; }
        
        .customer-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #fff0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #ee0979;
            font-weight: bold;
            border: 1px solid #ffd1d1;
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
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4">
        <div class="mb-3 mb-md-0">
            <h2 class="text-white fw-bold mb-0">Customer Directory</h2>
            <p class="text-white-50 small mb-0">Viewing all registered shoppers</p>
        </div>
        
        <div class="search-container w-100">
            <i class="fas fa-search"></i>
            <input type="text" id="searchInput" class="form-control search-box" placeholder="Filter by name, email or city...">
        </div>
    </div>

    <div class="data-card">
        <div class="table-responsive">
            <table class="table" id="customerTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Customer</th>
                        <th>Contact Info</th>
                        <th>Location</th>
                        <th>Join Date</th>
                        <th class="text-center">Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        con = DBConnection.getConnection();
                        ps = con.prepareStatement("SELECT * FROM customers ORDER BY customer_id DESC");
                        rs = ps.executeQuery();

                        while(rs.next()) {
                %>
                   <tr>
    <td class="text-muted fw-bold">#<%= rs.getInt("customer_id") %></td>
    <td>
        <div class="d-flex align-items-center">
            <div class="customer-avatar me-3">
                <% 
                    String name = rs.getString("name");
                    out.print((name != null && !name.isEmpty()) ? name.substring(0,1).toUpperCase() : "?");
                %>
            </div>
            <div class="fw-bold text-dark"><%= (name != null) ? name : "Unknown Customer" %></div>
        </div>
    </td>
    <td>
        <%-- Email Check --%>
        <div class="small text-dark">
            <i class="far fa-envelope me-1 opacity-50"></i> 
            <%= (rs.getString("email") != null && !rs.getString("email").isEmpty()) ? rs.getString("email") : "---" %>
        </div>
        <%-- Phone Check --%>
        <div class="small text-muted">
            <i class="fas fa-phone-alt me-1 opacity-50"></i> 
            <%= (rs.getString("phone") != null && !rs.getString("phone").isEmpty()) ? rs.getString("phone") : "---" %>
        </div>
    </td>
    <td>
        <%-- City Check --%>
        <span class="badge bg-light text-dark border">
            <%= (rs.getString("city") != null && !rs.getString("city").isEmpty()) ? rs.getString("city") : "---" %>
        </span>
        <%-- Address Check --%>
        <div class="extra-small text-muted mt-1" style="font-size: 0.7rem;">
            <%= (rs.getString("address") != null && !rs.getString("address").isEmpty()) ? rs.getString("address") : "---" %>
        </div>
    </td>
    <td class="small text-muted">
        <%= (rs.getString("created_at") != null) ? rs.getString("created_at") : "---" %>
    </td>
    <td class="text-center">
        <span class="text-success small fw-bold"><i class="fas fa-circle me-1" style="font-size: 8px;"></i> Active</span>
    </td>
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
    // CLIENT-SIDE REAL-TIME SEARCH
    document.getElementById("searchInput").addEventListener("keyup", function () {
        let filter = this.value.toLowerCase();
        let rows = document.querySelectorAll("#customerTable tbody tr");
        rows.forEach(row => {
            let text = row.innerText.toLowerCase();
            row.style.display = text.includes(filter) ? "" : "none";
        });
    });
</script>

<script src="js/bootstrap.bundle.min.js"></script>

</body>
</html>