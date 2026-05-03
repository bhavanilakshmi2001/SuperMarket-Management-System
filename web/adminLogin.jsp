<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - MartSmart</title>

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
            height: 100vh;
            display: flex;
            flex-direction: column;
            font-family: 'Segoe UI', sans-serif;
        }

        /* --- NAVBAR BLUR EFFECT --- */
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
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            animation: slideUpFade 0.8s cubic-bezier(0.4, 0, 0.2, 1);
        }

        @keyframes slideUpFade {
            from { opacity: 0; transform: translateY(30px); }
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
            margin: -60px auto 20px;
            box-shadow: 0 10px 20px rgba(238, 9, 121, 0.3);
            font-size: 2rem;
        }

        /* --- FORM CONTROLS --- */
        .form-control {
            border-radius: 10px;
            padding: 12px 15px;
            border: 1px solid #ddd;
        }

        .form-control:focus {
            border-color: #ff6a00;
            box-shadow: 0 0 0 0.25rem rgba(255, 106, 0, 0.25);
        }

        .input-group-text {
            background-color: #f8f9fa;
            border-radius: 10px 0 0 10px;
            color: #ee0979;
        }

        .btn-login {
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            border: none;
            border-radius: 12px;
            padding: 12px;
            color: white;
            font-weight: bold;
            transition: 0.3s;
        }

        .btn-login:hover {
            transform: scale(1.02);
            box-shadow: 0 5px 15px rgba(238, 9, 121, 0.4);
            color: white;
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
                <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="index.html">
                    <i class="fas fa-arrow-left me-1"></i> Back to Home
                </a>
            </div>
        </div>
    </nav>

    <div class="container d-flex justify-content-center align-items-center flex-grow-1">
        <div class="card p-4 login-card" style="max-width: 420px; width: 100%; margin-top: 50px;">
            
            <div class="icon-box">
                <i class="fas fa-user-shield"></i>
            </div>

            <h3 class="text-center mb-1 fw-bold" style="color: #333;">Admin Portal</h3>
            <p class="text-center text-muted mb-4 small">Please enter your credentials to manage the system</p>

            <form action="AdminLoginServlet" method="post">

                <div class="mb-3">
                    <label class="form-label fw-semibold small">Username</label>
                    <div class="input-group shadow-sm">
                        <span class="input-group-text"><i class="fas fa-user"></i></span>
                        <input type="text" name="username" class="form-control" placeholder="admin_user" required>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label fw-semibold small">Password</label>
                    <div class="input-group shadow-sm">
                        <span class="input-group-text"><i class="fas fa-lock"></i></span>
                        <input type="password" name="password" class="form-control" placeholder="....." required>
                    </div>
                </div>

                <button type="submit" class="btn btn-login w-100 mb-3">
                    SIGN IN <i class="fas fa-sign-in-alt ms-2"></i>
                </button>
                
                <div class="text-center">
                    <a href="#" class="text-decoration-none small text-muted">Forgot Password?</a>
                </div>
            </form>

        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>

</body>
</html>