<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer customerId = (Integer) session.getAttribute("customerId");
    String customerName = (String) session.getAttribute("customerName");
    if(customerId == null){
        response.sendRedirect("customerLogin.jsp?msg=loginfirst");
        return;
    }

    String orderIdStr = request.getParameter("orderId");
    if(orderIdStr == null) {
        response.sendRedirect("myOrders.jsp");
        return;
    }
    int orderId = Integer.parseInt(orderIdStr);

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rate Your Experience - MartSmart</title>
    
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">

    <style>
        /* --- SUNSET ANIMATED BACKGROUND --- */
        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        body {
            background: linear-gradient(-45deg, #ee0979, #ff6a00, #e63946, #f77f00);
            background-size: 400% 400%;
            animation: gradientShift 15s ease infinite;
            color: white;
            min-height: 100vh;
            font-family: 'Segoe UI', sans-serif;
        }

        /* --- GLASS EFFECT CARDS --- */
        .feedback-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 25px;
            padding: 30px;
            margin-bottom: 25px;
            color: #333; /* Dark text for readability on white glass */
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            border: none;
        }

        .item-preview-img {
            width: 90px;
            height: 90px;
            object-fit: cover;
            border-radius: 15px;
            border: 3px solid #f8f9fa;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        /* --- STAR RATING (SUNSET YELLOW) --- */
        .star-rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: flex-end;
        }

        .star-rating input { display: none; }

        .star-rating label {
            font-size: 2.2rem;
            color: #ddd;
            cursor: pointer;
            transition: 0.3s;
            padding: 0 5px;
        }

        /* Hover and Checked states using the theme's orange */
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label {
            color: #ff6a00;
            text-shadow: 0 0 10px rgba(255, 106, 0, 0.3);
        }

        /* --- INPUTS --- */
        .form-control-custom {
            background: #f8f9fa;
            border: 2px solid #eee;
            border-radius: 12px;
            padding: 12px;
        }

        .form-control-custom:focus {
            border-color: #ee0979;
            box-shadow: none;
            background: #fff;
        }

        /* --- SUBMIT BUTTON --- */
        .btn-submit-feedback {
            background: linear-gradient(90deg, #ee0979, #ff6a00);
            border: none;
            color: white;
            font-weight: 700;
            border-radius: 12px;
            padding: 15px 50px;
            transition: 0.3s;
            box-shadow: 0 10px 20px rgba(238, 9, 121, 0.3);
        }

        .btn-submit-feedback:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 25px rgba(238, 9, 121, 0.4);
            color: white;
        }

        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold text-white" href="customerDashboard.jsp">
            <i class="fas fa-history me-2"></i>MARTSMART
        </a>
        <a href="myOrders.jsp" class="btn btn-light btn-sm rounded-pill px-3 fw-bold">
            <i class="fas fa-times me-1"></i> Cancel
        </a>
    </div>
</nav>

<div class="container mt-5 pb-5">
    <div class="text-center mb-5">
        <h2 class="fw-bold text-white text-uppercase tracking-wide">Share Your Experience</h2>
        <p class="opacity-75">Tell us what you think about Order #<%= orderId %></p>
    </div>

    <form action="FeedbackServlet" method="post" id="feedbackForm">
        <input type="hidden" name="orderId" value="<%= orderId %>">

        <%
            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement(
                    "SELECT oi.order_item_id, si.item_name, si.item_image " +
                    "FROM order_items oi " +
                    "LEFT JOIN shop_items si ON oi.item_id=si.item_id " +
                    "WHERE oi.order_id=?"
                );
                ps.setInt(1, orderId);
                rs = ps.executeQuery();
                
                while(rs.next()){
                    int itemId = rs.getInt("order_item_id");
        %>
        
        <div class="feedback-card animate__animated animate__fadeInUp">
            <div class="row align-items-center">
                <div class="col-md-2 text-center">
                    <img src="uploads/<%= rs.getString("item_image") %>" class="item-preview-img mb-3">
                </div>
                <div class="col-md-10">
                    <h5 class="fw-bold mb-1"><%= rs.getString("item_name") %></h5>
                    <p class="text-muted small mb-3">How would you rate this item?</p>
                    
                    <div class="star-rating mb-4">
                        <input type="radio" id="star5_<%= itemId %>" name="rating_<%= itemId %>" value="5" required />
                        <label for="star5_<%= itemId %>" title="5 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star4_<%= itemId %>" name="rating_<%= itemId %>" value="4" />
                        <label for="star4_<%= itemId %>" title="4 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star3_<%= itemId %>" name="rating_<%= itemId %>" value="3" />
                        <label for="star3_<%= itemId %>" title="3 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star2_<%= itemId %>" name="rating_<%= itemId %>" value="2" />
                        <label for="star2_<%= itemId %>" title="2 stars"><i class="fas fa-star"></i></label>
                        
                        <input type="radio" id="star1_<%= itemId %>" name="rating_<%= itemId %>" value="1" />
                        <label for="star1_<%= itemId %>" title="1 star"><i class="fas fa-star"></i></label>
                    </div>

                    <div class="form-group">
                        <label class="fw-bold small text-muted mb-2">ADD A COMMENT</label>
                        <textarea name="comment_<%= itemId %>" class="form-control form-control-custom" rows="2" placeholder="Tell us more about the product..."></textarea>
                    </div>
                </div>
            </div>
        </div>

        <%
                }
            } catch(Exception e){ e.printStackTrace(); }
            finally {
                if(rs != null) rs.close(); if(ps != null) ps.close(); if(con != null) con.close();
            }
        %>

        <div class="text-center mt-5">
            <button type="submit" class="btn btn-submit-feedback text-uppercase">
                Submit Feedback <i class="fas fa-arrow-right ms-2"></i>
            </button>
        </div>
    </form>
</div>

<script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>