<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shop Login - MartSmart</title>

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
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        /* --- MODERN NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        /* --- LOGIN CARD STYLING --- */
        .login-card {
            background: rgba(255, 255, 255, 0.95);
            border: none;
            border-radius: 25px;
            padding: 45px 35px;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            text-align: center;
            position: relative;
            animation: fadeInUp 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .icon-box {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: -85px auto 20px;
            box-shadow: 0 10px 25px rgba(238, 9, 121, 0.3);
            font-size: 2.2rem;
        }

        /* --- FORM ELEMENTS --- */
        .form-control {
            border-radius: 12px;
            padding: 12px 18px;
            border: 1px solid #eee;
            transition: all 0.3s ease;
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
            letter-spacing: 1px;
            transition: 0.3s;
            text-transform: uppercase;
        }

        .btn-login:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(238, 9, 121, 0.4);
            color: #fff;
        }

        .shop-title {
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 800;
        }

        .alert-custom {
            border-radius: 10px;
            font-size: 0.9rem;
            margin-bottom: 20px;
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

    <div class="container d-flex justify-content-center align-items-center flex-grow-1 py-5">
        <div class="login-card mt-5">
            <div class="icon-box">
                <i class="fas fa-store"></i>
            </div>
            
            <h3 class="shop-title mb-1">Shop Login</h3>
            <p class="text-muted small mb-4">Manage your inventory and orders</p>

           

            <form action="ShopLoginServlet" method="post">
                <div class="mb-3 text-start">
                    <label class="form-label small fw-bold text-secondary ps-2">Email Address</label>
                    <div class="input-group">
                        <input type="email" name="email" class="form-control" placeholder="shop@example.com" required>
                    </div>
                </div>

                <div class="mb-3 text-start">
                    <label class="form-label small fw-bold text-secondary ps-2">Password</label>
                    <div class="input-group">
                        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>

                <div class="mb-4 text-center">
                    <a href="shopRegister.jsp" class="text-decoration-none small" style="color: #ee0979;">
                        Don't have an account? <strong>Register here</strong>
                    </a>
                </div>

                <button type="submit" class="btn btn-login w-100">
                    Login to Dashboard <i class="fas fa-arrow-right ms-2"></i>
                </button>
            </form>
        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>