<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agent Registration - MartSmart</title>

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
            background: rgba(255, 255, 255, 0.96);
            border: none;
            border-radius: 25px;
            padding: 40px;
            width: 100%;
            max-width: 550px;
            margin: 40px auto;
            box-shadow: 0 20px 40px rgba(0,0,0,0.2);
            animation: slideInUp 0.8s cubic-bezier(0.2, 0.8, 0.2, 1);
        }

        @keyframes slideInUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* --- FORM ELEMENTS --- */
        .form-label {
            font-size: 0.85rem;
            font-weight: 700;
            color: #555;
            margin-left: 5px;
        }

        .form-control {
            border-radius: 12px;
            padding: 10px 18px;
            border: 1px solid #eee;
            transition: 0.3s;
            background: #fdfdfd;
        }

        .form-control:focus {
            border-color: #ff6a00;
            box-shadow: 0 0 0 0.25rem rgba(255, 106, 0, 0.15);
            background: #fff;
        }

        .btn-submit {
            background: linear-gradient(135deg, #ee0979, #ff6a00);
            border: none;
            border-radius: 12px;
            padding: 14px;
            color: #fff;
            font-weight: 700;
            width: 100%;
            transition: 0.3s;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-top: 10px;
        }

        .btn-submit:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(238, 9, 121, 0.4);
            color: #fff;
        }

        .agent-header {
            color: #ee0979;
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
                <a class="btn btn-outline-light btn-sm rounded-pill px-4" href="agentLogin.jsp">
                    <i class="fas fa-user-check me-1"></i> Already an Agent?
                </a>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="register-card">
            <div class="text-center mb-4">
                <i class="fas fa-truck-loading fa-3x mb-3" style="color: #ff6a00;"></i>
                <h3 class="agent-header mb-1">Join the Fleet</h3>
                <p class="text-muted small">Register to become a MartSmart delivery partner</p>
            </div>

            <form action="AgentRegisterServlet" method="post">
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Full Name</label>
                        <input type="text" name="name" class="form-control" placeholder="John Doe" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Phone Number</label>
                        <input type="text" name="phone" class="form-control" placeholder="10-digit number" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-12 mb-3">
                        <label class="form-label">Email Address</label>
                        <input type="email" name="email" class="form-control" placeholder="agent@martsmart.com" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Operating City</label>
                        <input type="text" name="city" class="form-control" placeholder="e.g. New York" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Set Password</label>
                        <input type="password" name="password" class="form-control" placeholder="••••••••" required>
                    </div>
                </div>

                <div class="mb-4">
                    <label class="form-label">Home/Base Address</label>
                    <textarea name="address" class="form-control" rows="2" placeholder="Full street address..." required></textarea>
                </div>

                <div class="text-center">
                    <button type="submit" class="btn btn-submit">
                        Apply to Join <i class="fas fa-paper-plane ms-2"></i>
                    </button>
                    <p class="mt-4 small text-muted">
                        By applying, you agree to our <a href="#" class="text-decoration-none" style="color: #ee0979;">Partnership Terms</a>.
                    </p>
                </div>
            </form>
        </div>
    </div>

    <script src="js/bootstrap.bundle.min.js"></script>
</body>
</html>