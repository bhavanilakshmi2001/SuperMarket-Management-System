<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shop Registration - MartSmart</title>

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

        /* --- REGISTRATION CARD --- */
        .register-card {
            background: rgba(255, 255, 255, 0.95);
            border: none;
            border-radius: 25px;
            padding: 40px;
            width: 100%;
            max-width: 600px; /* Wider for registration */
            margin: 40px auto;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            animation: slideInUp 0.8s cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- FORM STYLING --- */
        .form-label {
            font-size: 0.85rem;
            font-weight: 700;
            color: #555;
            margin-left: 12px;
        }

        .form-control {
            border-radius: 12px;
            padding: 10px 18px;
            border: 1px solid #eee;
            background: #fdfdfd;
            transition: 0.3s;
        }

        .form-control:focus {
            border-color: #ff6a00;
            box-shadow: 0 0 0 0.25rem rgba(255, 106, 0, 0.15);
            background: #fff;
        }

        .input-group-text {
            background: transparent;
            border: none;
            color: #ee0979;
        }

        /* --- BUTTON STYLING --- */
        .btn-submit {
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            border: none;
            border-radius: 15px;
            padding: 14px;
            color: #fff;
            font-weight: 700;
            letter-spacing: 1px;
            transition: 0.3s;
            text-transform: uppercase;
            margin-top: 20px;
        }

        .btn-submit:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(238, 9, 121, 0.4);
            color: #fff;
        }

        .section-header {
            color: #ee0979;
            font-weight: 800;
            margin-bottom: 5px;
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
                <a class="nav-link text-white fw-semibold" href="shopLogin.jsp">
                    Already a Member? <span style="text-decoration: underline;">Login</span>
                </a>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="register-card">
            <div class="text-center mb-4">
                <h2 class="section-header">Partner With Us</h2>
                <p class="text-muted small">Register your shop and reach thousands of customers</p>
            </div>

            <form action="ShopRegisterServlet" method="post" enctype="multipart/form-data">
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Shop Name</label>
                        <input type="text" name="shopName" class="form-control" placeholder="Global Traders" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Owner Name</label>
                        <input type="text" name="ownerName" class="form-control" placeholder="John Doe" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Official Email</label>
                        <input type="email" name="email" class="form-control" placeholder="shop@email.com" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Phone Number</label>
                        <input type="text" name="phone" class="form-control" placeholder="+1 234 567 890">
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">City</label>
                        <input type="text" name="city" class="form-control" placeholder="New York">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Set Password</label>
                        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Full Business Address</label>
                    <textarea name="address" class="form-control" rows="2" placeholder="Street, Building, Area..."></textarea>
                </div>

                <div class="mb-4">
                    <label class="form-label">Shop Logo/Image</label>
                    <div class="input-group">
                        <input type="file" name="image" class="form-control" id="inputGroupFile02" accept="image/*">
                    </div>
                    <div class="form-text text-center mt-1" style="font-size: 0.75rem;">Upload a clear photo of your storefront.</div>
                </div>

                <button type="submit" class="btn btn-submit w-100">
                    Submit Registration Request <i class="fas fa-paper-plane ms-2"></i>
                </button>

                <p class="text-center mt-3 small text-muted">
                    By registering, you agree to our Terms of Service.
                </p>
            </form>
        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>