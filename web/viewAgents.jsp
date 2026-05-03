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

    // =====================================
    // DATABASE FETCH
    // =====================================
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = DBConnection.getConnection();
        ps = con.prepareStatement("SELECT * FROM agents ORDER BY agent_id DESC");
        rs = ps.executeQuery();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Agents - MartSmart Admin</title>

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
            background: rgba(255, 255, 255, 0.96);
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- TABLE STYLING --- */
        .table { border-collapse: separate; border-spacing: 0 12px; }
        .table thead th {
            background: #f8f9fa;
            border: none;
            color: #666;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 1px;
            padding: 15px;
        }

        .table tbody tr {
            background: white;
            transition: 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.03);
        }

        .table tbody tr:hover {
            transform: scale(1.01);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .table td { vertical-align: middle; border: none; padding: 15px; font-size: 0.9rem; }

        /* --- STATUS BADGES --- */
        .status-badge {
            padding: 6px 14px;
            border-radius: 50px;
            font-size: 0.75rem;
            font-weight: 700;
        }
        .approved { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .rejected { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .pending   { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }

        .btn-action {
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 700;
            padding: 6px 14px;
            transition: 0.2s;
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="text-white fw-bold mb-0">Delivery Agents</h2>
            <span class="badge bg-white text-danger px-3 py-2 rounded-pill shadow-sm fw-bold">FLEET MANAGEMENT</span>
        </div>

        <div class="data-card">
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Agent Identity</th>
                            <th>Contact Info</th>
                            <th>Location</th>
                            <th>Status</th>
                            <th class="text-center">Manage</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (rs != null) {
                                while (rs.next()) {
                                    String status = rs.getString("status");
                                    int id = rs.getInt("agent_id");
                        %>
                        <tr>
                            <td class="fw-bold text-muted">#<%= id %></td>
                            <td>
                                <div class="d-flex align-items-center">
                                    <div class="rounded-circle bg-light d-flex align-items-center justify-content-center me-3" style="width: 45px; height: 45px; color: #ff6a00;">
                                        <i class="fas fa-user-ninja"></i>
                                    </div>
                                    <div class="fw-bold text-dark"><%= rs.getString("name") %></div>
                                </div>
                            </td>
                            <td>
                                <div class="small"><i class="fas fa-envelope text-muted me-1"></i> <%= rs.getString("email") %></div>
                                <div class="small"><i class="fas fa-phone text-muted me-1"></i> <%= rs.getString("phone") %></div>
                            </td>
                            <td>
                                <div class="text-capitalize fw-bold small"><%= rs.getString("city") %></div>
                                <div class="text-muted extra-small" style="font-size: 0.75rem;"><%= rs.getString("address") %></div>
                            </td>
                            <td>
                                <% if ("approved".equalsIgnoreCase(status)) { %>
                                    <span class="status-badge approved"><i class="fas fa-check-circle me-1"></i>Approved</span>
                                <% } else if ("rejected".equalsIgnoreCase(status)) { %>
                                    <span class="status-badge rejected"><i class="fas fa-times-circle me-1"></i>Rejected</span>
                                <% } else { %>
                                    <span class="status-badge pending"><i class="fas fa-clock me-1"></i>Pending</span>
                                <% } %>
                            </td>
                            <td class="text-center">
                                <% if ("pending".equalsIgnoreCase(status)) { %>
                                    <a href="ApproveAgentServlet?id=<%= id %>" class="btn btn-success btn-action me-1 shadow-sm">
                                        Approve
                                    </a>
                                    <a href="RejectAgentServlet?id=<%= id %>" class="btn btn-outline-danger btn-action shadow-sm">
                                        Reject
                                    </a>
                                <% } else { %>
                                    <span class="text-muted small">Action Taken</span>
                                <% } %>
                            </td>
                        </tr>
                        <% 
                                }
                            } 
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>