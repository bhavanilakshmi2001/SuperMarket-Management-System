<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Login - MartSmart</title>

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
            background: linear-gradient(-45deg, #ee0979, #ff6a00, #ff0080, #ff8c00);
            background-size: 400% 400%;
            animation: gradientShift 10s ease infinite;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
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
            width: 100%;
            max-width: 400px;
            margin: auto;
            padding: 40px 30px;
            border-radius: 25px;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.2);
            animation: slideInUp 0.7s cubic-bezier(0.17, 0.67, 0.83, 0.67);
        }

        @keyframes slideInUp {
            from { transform: translateY(50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .icon-header {
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
            font-size: 2rem;
        }

        /* --- FORM STYLING --- */
        .form-control {
            border-radius: 12px;
            padding: 12px 18px;
            border: 1px solid #eee;
            transition: 0.3s ease-in-out;
        }

        .form-control:focus {
            border-color: #ff6a00;
            box-shadow: 0 0 0 0.25rem rgba(255, 106, 0, 0.2);
        }

        .btn-login {
            width: 100%;
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            border: none;
            color: #fff;
            border-radius: 12px;
            padding: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: 0.3s;
        }

        .btn-login:hover {
            transform: scale(1.03);
            box-shadow: 0 8px 15px rgba(238, 9, 121, 0.4);
            color: #fff;
        }

        .reg-link {
            color: #ee0979;
            font-weight: 700;
            text-decoration: none;
        }

        .reg-link:hover {
            text-decoration: underline;
        }

        .alert {
            border-radius: 12px;
            font-size: 0.9rem;
            font-weight: 500;
        }
    </style>
</head>

<body>

    <nav class="navbar navbar-expand-lg navbar-dark shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold fs-4" href="index.html">
                <i class="fas fa-shopping-basket me-2"></i> MartSmart
            </a>
            <div class="ms-auto">
                <a class="btn btn-outline-light btn-sm rounded-pill px-4" href="index.html">
                    <i class="fas fa-home me-1"></i> Home
                </a>
            </div>
        </div>
    </nav>


    <div class="container d-flex flex-grow-1">
        <div class="login-card mt-5 mb-5">
            <div class="icon-header">
                <i class="fas fa-user"></i>
            </div>

            <h3 class="text-center mb-1 fw-bold" style="color:#333;">Welcome Back!</h3>
            <p class="text-center text-muted small mb-4">Login to start shopping</p>

            <%
                String msg = request.getParameter("msg");
                if ("success".equals(msg)) {
            %>
                <div class="alert alert-success text-center border-0 shadow-sm"><i class="fas fa-check-circle me-1"></i> Account created! Login below.</div>
            <% } else if ("invalid".equals(msg)) { %>
                <div class="alert alert-danger text-center border-0 shadow-sm"><i class="fas fa-times-circle me-1"></i> Invalid Email or Password!</div>
            <% } else if ("logout".equals(msg)) { %>
                <div class="alert alert-info text-center border-0 shadow-sm"><i class="fas fa-info-circle me-1"></i> You have been logged out.</div>
            <% } else if ("loginfirst".equals(msg)) { %>
                <div class="alert alert-warning text-center border-0 shadow-sm"><i class="fas fa-exclamation-triangle me-1"></i> Access denied. Please login.</div>
            <% } %>

            <form action="CustomerLoginServlet" method="post">

               <div class="mb-3 text-start">
    <label class="form-label ms-1 small fw-bold">Email or Phone Number</label>
    <div class="input-group">
        <span class="input-group-text bg-white border-end-0" style="border-radius: 12px 0 0 12px;">
            <i class="fas fa-user-tag text-muted"></i>
        </span>
        <input type="text" 
               name="loginIdentifier" 
               class="form-control border-start-0" 
               placeholder="Enter Email or Phone" 
               style="border-radius: 0 12px 12px 0;" 
               required>
    </div>
</div>

                <div class="mb-4 text-start">
                    <label class="form-label ms-1 small fw-bold">Password</label>
                    <div class="input-group">
                        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>

                <button type="submit" class="btn btn-login mb-3">
                    Login <i class="fas fa-sign-in-alt ms-2"></i>
                </button>

                <p class="text-center mt-3 small text-muted">
                    New to MartSmart? 
                    <a href="customerRegister.jsp" class="reg-link">Create Account</a>
                </p>
            </form>
        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>

</html>