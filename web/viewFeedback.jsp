<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // SHOP SESSION CHECK
    Integer shopId = (Integer) session.getAttribute("shopId");
    String shopName = (String) session.getAttribute("shopName");

    if(shopId == null){
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
    <title>Customer Reviews - <%= shopName %></title>

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

        /* --- GLASS NAVIGATION --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
        .navbar-brand, .nav-link { color: white !important; font-weight: 600; }

        /* --- CONTENT CARD --- */
        .card {
            border: none;
            border-radius: 20px;
            background: rgba(255, 255, 255, 0.98);
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            overflow: hidden;
        }

        .card-header-custom {
            background: #fff;
            padding: 25px;
            border-bottom: 2px solid #f8f9fa;
        }

        /* --- TABLE & REVIEW STYLING --- */
        .table thead th {
            background: #f8f9fa;
            border: none;
            color: #888;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 15px;
        }

        .customer-name {
            font-weight: 700;
            color: #333;
            margin-bottom: 2px;
        }

        .customer-email {
            font-size: 0.8rem;
            color: #999;
        }

        /* --- RATING STARS --- */
        .star-container {
            color: #ffc107;
            white-space: nowrap;
        }
        
        .comment-text {
            font-style: italic;
            color: #555;
            max-width: 400px;
            line-height: 1.5;
        }

        .timestamp {
            font-size: 0.8rem;
            color: #bbb;
        }

        .feedback-badge {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            color: white;
            padding: 5px 15px;
            border-radius: 50px;
            font-size: 0.8rem;
            font-weight: 600;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp">
            <i class="fas fa-comment-alt me-2"></i><%= shopName.toUpperCase() %>
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

<div class="container mt-5 pb-5">
    <div class="card">
        <div class="card-header-custom d-flex justify-content-between align-items-center">
            <div>
                <h4 class="fw-bold m-0" style="color: #ee0979;">Customer Insights</h4>
                <p class="text-muted small m-0">What shoppers are saying about <%= shopName %></p>
            </div>
            <span class="feedback-badge"><i class="fas fa-chart-line me-1"></i> Shop Feedback</span>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-4">Customer</th>
                        <th>Experience Rating</th>
                        <th>Comments</th>
                        <th class="text-end pe-4">Date Submitted</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        con = DBConnection.getConnection();
                        ps = con.prepareStatement(
                            "SELECT f.feedback_id, f.rating, f.comments, f.created_at, " +
                            "c.name AS customer_name, c.email " +
                            "FROM feedback f " +
                            "JOIN orders o ON f.order_id = o.order_id " +
                            "JOIN customers c ON f.customer_id = c.customer_id " +
                            "WHERE o.shop_id = ? " +
                            "ORDER BY f.feedback_id DESC"
                        );
                        ps.setInt(1, shopId);
                        rs = ps.executeQuery();

                        boolean hasData = false;
                        while(rs.next()){
                            hasData = true;
                %>
                    <tr>
                        <td class="ps-4">
                            <div class="customer-name"><%= rs.getString("customer_name") %></div>
                            <div class="customer-email"><%= rs.getString("email") %></div>
                        </td>
                        <td>
                            <div class="star-container">
                                <% 
                                    int rating = rs.getInt("rating");
                                    for(int i=0; i<5; i++){ 
                                        if(i < rating) { %>
                                            <i class="fas fa-star"></i>
                                        <% } else { %>
                                            <i class="far fa-star text-muted opacity-25"></i>
                                        <% } 
                                    } 
                                %>
                                <span class="ms-1 text-dark fw-bold small">(<%= rating %>/5)</span>
                            </div>
                        </td>
                        <td>
                            <div class="comment-text">
                                "<%= rs.getString("comments") %>"
                            </div>
                        </td>
                        <td class="text-end pe-4">
                            <div class="timestamp">
                                <i class="far fa-clock me-1"></i><%= rs.getString("created_at") %>
                            </div>
                        </td>
                    </tr>
                <%
                        }
                        if(!hasData) {
                            out.println("<tr><td colspan='4' class='text-center py-5 text-muted'>No feedback received yet.</td></tr>");
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