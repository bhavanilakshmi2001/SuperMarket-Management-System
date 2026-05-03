<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agent Login - MartSmart</title>

    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">

    <style>
        /* --- ANIMATED GRADIENT BACKGROUND --- */
        @keyframes gradientShift {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        body {
            background: linear-gradient(-45deg, #ee0979, #ff6a00, #e63946, #f77f00);
            background-size: 400% 400%;
            animation: gradientShift 12s ease infinite;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            font-family: 'Segoe UI', sans-serif;
        }

        /* --- MODERN NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        /* --- LOGIN CARD --- */
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            border: none;
            border-radius: 25px;
            padding: 40px 30px;
            width: 100%;
            max-width: 400px;
            margin: auto;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            text-align: center;
            position: relative;
            animation: slideInUp 0.8s cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .icon-box {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: -75px auto 20px;
            box-shadow: 0 10px 20px rgba(238, 9, 121, 0.3);
            font-size: 1.8rem;
        }

        /* --- FORM ELEMENTS --- */
        .form-label {
            font-size: 0.85rem;
            font-weight: 700;
            color: #555;
            display: block;
            text-align: left;
            margin-left: 5px;
        }

        .form-control {
            border-radius: 12px;
            padding: 12px 18px;
            border: 1px solid #eee;
            transition: 0.3s;
        }

        .form-control:focus {
            border-color: #ff6a00;
            box-shadow: 0 0 0 0.25rem rgba(255, 106, 0, 0.15);
        }

        .btn-login {
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            border: none;
            border-radius: 12px;
            padding: 12px;
            color: #fff;
            font-weight: 700;
            width: 100%;
            transition: 0.3s;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(238, 9, 121, 0.4);
            color: #fff;
        }

        .reg-link {
            color: #ee0979;
            font-weight: 700;
            text-decoration: none;
        }

        .alert-custom {
            border-radius: 12px;
            font-size: 0.85rem;
            border: none;
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>

    <nav class="navbar navbar-expand-lg navbar-dark shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="index.html">
                <i class="fas fa-shopping-basket me-2"></i> MartSmart
            </a>
            <div class="ms-auto">
                <a class="btn btn-outline-light btn-sm rounded-pill px-4" href="index.html">
                    <i class="fas fa-home me-1"></i> Home
                </a>
            </div>
        </div>
    </nav>

    <div class="container d-flex flex-grow-1 align-items-center justify-content-center py-5">
        <div class="login-card">
            <div class="icon-box">
                <i class="fas fa-shipping-fast"></i>
            </div>
            
            <h3 class="fw-bold mb-1" style="color: #333;">Agent Portal</h3>
            <p class="text-muted small mb-4">Manage your deliveries and routes</p>

            <% 
                String msg = request.getParameter("msg"); 
                if(msg != null){ 
                    String alertType = "alert-warning";
                    String icon = "fa-info-circle";
                    String text = "";
                    
                    if("loginfirst".equals(msg)) { text = "Please login to access the dashboard."; }
                    else if("registered".equals(msg)) { alertType = "alert-success"; icon = "fa-check-circle"; text = "Registration successful! Please login."; }
                    else if("invalid".equals(msg)) { alertType = "alert-danger"; icon = "fa-exclamation-triangle"; text = "Invalid credentials or pending approval."; }
            %>
                <div class="alert <%= alertType %> alert-custom d-flex align-items-center justify-content-center mb-4" role="alert">
                    <i class="fas <%= icon %> me-2"></i>
                    <div><%= text %></div>
                </div>
            <% } %>

            <form action="AgentLoginServlet" method="post">
                <div class="mb-3">
                    <label class="form-label">Email Address</label>
                    <input type="email" name="email" class="form-control" placeholder="agent@martsmart.com" required>
                </div>

                <div class="mb-4">
                    <label class="form-label">Password</label>
                    <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>

                <button type="submit" class="btn btn-login mb-3">
                    Sign In <i class="fas fa-sign-in-alt ms-2"></i>
                </button>
            </form>

            <p class="mt-2 mb-0 small text-muted">
                New agent? <a href="agentRegister.jsp" class="reg-link">Register Here</a>
            </p>
        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>