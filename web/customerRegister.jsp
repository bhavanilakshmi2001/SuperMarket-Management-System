<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join MartSmart - Customer Registration</title>

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
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        /* --- MODERN NAVBAR --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        /* --- REGISTRATION CARD --- */
        .reg-card {
            width: 100%;
            max-width: 500px;
            background: rgba(255, 255, 255, 0.96);
            border: none;
            border-radius: 25px;
            padding: 40px;
            box-shadow: 0 20px 50px rgba(0,0,0,0.2);
            animation: riseUp 0.8s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
            margin: 40px 0;
        }

        @keyframes riseUp {
            from { opacity: 0; transform: translateY(40px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- FORM STYLING --- */
        .form-label {
            font-size: 0.85rem;
            font-weight: 700;
            color: #444;
            margin-bottom: 6px;
        }

        .form-control {
            border-radius: 12px;
            padding: 10px 15px;
            border: 1px solid #eee;
            transition: all 0.3s ease;
            background: #fdfdfd;
        }

        .form-control:focus {
            border-color: #ff6a00;
            box-shadow: 0 0 0 0.25rem rgba(255, 106, 0, 0.15);
            background: #fff;
        }

        /* --- BUTTON STYLING --- */
        .btn-register {
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            color: white;
            font-weight: 700;
            border-radius: 15px;
            padding: 12px 30px;
            border: none;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: 0.3s;
        }

        .btn-register:hover {
            transform: scale(1.03);
            box-shadow: 0 8px 20px rgba(238, 9, 121, 0.4);
            color: white;
        }

        .reg-title {
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 800;
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


    <div class="container d-flex justify-content-center align-items-center flex-grow-1">
        <div class="reg-card">

            <div class="text-center mb-4">
                <h3 class="reg-title mb-1">Create Account</h3>
                <p class="text-muted small">Join our community and enjoy smart shopping</p>
            </div>

            <form action="CustomerRegisterServlet" method="post">

                <div class="row">
                    <div class="col-md-12 mb-3">
                        <label class="form-label"><i class="fas fa-user-circle me-1"></i> Full Name</label>
                        <input type="text" name="name" class="form-control" placeholder="Enter full name" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label"><i class="fas fa-envelope me-1"></i> Email</label>
                        <input type="email" name="email" class="form-control" placeholder="john@example.com" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label"><i class="fas fa-phone me-1"></i> Phone</label>
                        <input type="text" name="phone" class="form-control" placeholder="10-digit number" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label"><i class="fas fa-lock me-1"></i> Password</label>
                        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label"><i class="fas fa-city me-1"></i> City</label>
                        <input type="text" name="city" class="form-control" placeholder="Enter city" required>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label"><i class="fas fa-map-marker-alt me-1"></i> Delivery Address</label>
                    <textarea name="address" class="form-control" rows="2" placeholder="House no, Street, Landmark..." required></textarea>
                </div>

                <div class="text-center">
                    <button type="submit" class="btn btn-register w-100">
                        Create My Account <i class="fas fa-check-circle ms-2"></i>
                    </button>
                </div>

                <p class="text-center mt-4 small text-muted">
                    Already a member? 
                    <a href="customerLogin.jsp" style="color:#ee0979; font-weight:700; text-decoration: none;">Login Now</a>
                </p>

            </form>
        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>