<%@ page import="java.sql.*, java.util.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer shopId = (Integer) session.getAttribute("shopId");
    if(shopId==null){ response.sendRedirect("shopLogin.jsp"); return; }

    Connection con = DBConnection.getConnection();
    PreparedStatement ps = null;
    ResultSet rs = null;
    String msg="";

    // Fetch shop details for the header
    ps = con.prepareStatement("SELECT shop_name, shop_address, phone FROM shops WHERE shop_id=?");
    ps.setInt(1, shopId);
    rs = ps.executeQuery();
    String shopName="", shopPhone="", shopAddress="";
    if(rs.next()){
        shopName = rs.getString("shop_name");
        shopPhone = rs.getString("phone");
        shopAddress = rs.getString("shop_address");
    }

    if(request.getParameter("submit")!=null){
        String phone = request.getParameter("phone");
        String nameInput = request.getParameter("custName");
        String[] itemIds = request.getParameterValues("itemId[]");
        String[] quantities = request.getParameterValues("quantity[]");

        int customerId = 0;
        String customerName = (nameInput!=null && !nameInput.isEmpty())? nameInput:"Walk-in Customer";

        ps = con.prepareStatement("SELECT customer_id, name FROM customers WHERE phone=?");
        ps.setString(1, phone);
        rs = ps.executeQuery();
        if(rs.next()){
            customerId = rs.getInt("customer_id");
            customerName = rs.getString("name");
        } else {
            ps = con.prepareStatement(
                "INSERT INTO customers(name,phone,password) VALUES(?,?,?)",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, customerName);
            ps.setString(2, phone);
            ps.setString(3, "default123");
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if(rs.next()) customerId = rs.getInt(1);
        }

        double totalAmount = 0;
        List<Map<String,Object>> orderItems = new ArrayList<>();
        for(int i=0; i < (itemIds != null ? itemIds.length : 0); i++){
            int itemId = Integer.parseInt(itemIds[i]);
            int qty = Integer.parseInt(quantities[i]);
            ps = con.prepareStatement("SELECT item_name, price, quantity FROM shop_items WHERE item_id=? AND shop_id=?");
            ps.setInt(1, itemId);
            ps.setInt(2, shopId);
            rs = ps.executeQuery();
            if(rs.next()){
                String itemName = rs.getString("item_name");
                double price = rs.getDouble("price");
                int stock = rs.getInt("quantity");
                if(qty > stock) qty = stock;
                double itemTotal = price * qty;
                totalAmount += itemTotal;

                Map<String,Object> map = new HashMap<>();
                map.put("itemId", itemId);
                map.put("itemName", itemName);
                map.put("price", price);
                map.put("qty", qty);
                map.put("itemTotal", itemTotal);
                orderItems.add(map);
            }
        }

        ps = con.prepareStatement("INSERT INTO orders(customer_id, shop_id, total_amount) VALUES(?,?,?)", Statement.RETURN_GENERATED_KEYS);
        ps.setInt(1, customerId);
        ps.setInt(2, shopId);
        ps.setDouble(3, totalAmount);
        ps.executeUpdate();
        rs = ps.getGeneratedKeys();
        int orderId = 0; if(rs.next()) orderId = rs.getInt(1);

        for(Map<String,Object> o: orderItems){
            ps = con.prepareStatement("INSERT INTO order_items(order_id,item_id,quantity,price) VALUES(?,?,?,?)");
            ps.setInt(1, orderId);
            ps.setInt(2, (Integer)o.get("itemId"));
            ps.setInt(3, (Integer)o.get("qty"));
            ps.setDouble(4, (Double)o.get("price"));
            ps.executeUpdate();

            ps = con.prepareStatement("UPDATE shop_items SET quantity=quantity-? WHERE item_id=?");
            ps.setInt(1, (Integer)o.get("qty"));
            ps.setInt(2, (Integer)o.get("itemId"));
            ps.executeUpdate();
        }

        session.setAttribute("invoiceCustomerName", customerName);
        session.setAttribute("invoicePhone", phone);
        session.setAttribute("invoiceOrderItems", orderItems);
        session.setAttribute("invoiceTotal", totalAmount);
        session.setAttribute("invoiceOrderId", orderId);
        session.setAttribute("invoiceShopName", shopName);
        session.setAttribute("invoiceShopPhone", shopPhone);
        session.setAttribute("invoiceShopAddress", shopAddress);

        response.sendRedirect("printInvoice.jsp");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>POS | Walk-in Invoice</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">
    <style>
        :root { --sunset-start: #ee0979; --sunset-end: #ff6a00; }
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
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            color: #333;
        }

        /* --- DASHBOARD COMPONENTS --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1) !important;
            backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .navbar-brand, .nav-link {
            color: white !important;
            font-weight: 600;
        }

        .nav-link:hover {
            color: #ffd1d1 !important;
        }


        .pos-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            padding: 30px;
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }
        
        .section-title i { color: var(--sunset-start); margin-right: 10px; }

        .item-row { transition: all 0.2s; border-bottom: 1px solid #f1f1f1; }
        .item-row:hover { background-color: #fff9fb; }

        .remove-item {
            color: #dc3545;
            cursor: pointer;
            width: 35px;
            height: 35px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            transition: 0.2s;
        }
        .remove-item:hover { background: #fee2e2; }

        .grand-total-display {
            background: #2d3436;
            color: #fff;
            padding: 20px;
            border-radius: 12px;
            text-align: right;
        }

        .btn-add-item {
            border: 2px dashed #dee2e6;
            color: #6c757d;
            font-weight: 600;
            width: 100%;
            padding: 10px;
            border-radius: 10px;
            transition: 0.3s;
        }
        .btn-add-item:hover { border-color: var(--sunset-start); color: var(--sunset-start); background: #fff5f8; }

        .btn-generate {
            background: linear-gradient(90deg, var(--sunset-start), var(--sunset-end));
            border: none;
            color: white;
            font-weight: 700;
            padding: 15px;
            border-radius: 12px;
            width: 100%;
            font-size: 1.1rem;
            box-shadow: 0 10px 20px rgba(238, 9, 121, 0.2);
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg shadow-sm mb-4">
    <div class="container">
        <a class="navbar-brand" href="shopDashboard.jsp"><i class="fas fa-cash-register me-2"></i><%= shopName %> POS</a>
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

<div class="container pb-5">
    <form method="post" id="invoiceForm">
        <div class="row">
            <div class="col-lg-8">
                <div class="pos-card">
                    <div class="section-title"><i class="fas fa-user-circle"></i> Customer Information</div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label small fw-bold">Phone Number</label>
                            <input type="text" name="phone" class="form-control" placeholder="Enter mobile number" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label small fw-bold">Customer Name (Optional)</label>
                            <input type="text" name="custName" class="form-control" placeholder="Guest Customer">
                        </div>
                    </div>
                </div>

                <div class="pos-card">
                    <div class="section-title"><i class="fas fa-shopping-cart"></i> Billing Items</div>
                    <div class="table-responsive">
                        <table class="table align-middle" id="itemsTable">
                            <thead>
                                <tr class="text-muted small">
                                    <th width="45%">PRODUCT</th>
                                    <th width="15%">PRICE</th>
                                    <th width="15%">QTY</th>
                                    <th width="15%">TOTAL</th>
                                    <th width="10%"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr class="item-row">
                                    <td>
                                        <select name="itemId[]" class="form-select item-select" required>
                                            <option value="">Select Item</option>
                                            <%
                                                ps = con.prepareStatement("SELECT item_id,item_name,price,quantity FROM shop_items WHERE shop_id=? AND quantity > 0");
                                                ps.setInt(1, shopId);
                                                rs = ps.executeQuery();
                                                while(rs.next()){
                                            %>
                                            <option value="<%=rs.getInt("item_id")%>" 
                                                    data-price="<%=rs.getDouble("price")%>"
                                                    data-stock="<%=rs.getInt("quantity")%>">
                                                <%=rs.getString("item_name")%> (Stock: <%=rs.getInt("quantity")%>)
                                            </option>
                                            <% } %>
                                        </select>
                                    </td>
                                    <td><span class="fw-bold">₹</span><span class="item-price">0.00</span></td>
                                    <td><input type="number" name="quantity[]" class="form-control qty-input" value="1" min="1"></td>
                                    <td><span class="fw-bold text-dark">₹</span><span class="item-total fw-bold text-dark">0.00</span></td>
                                    <td class="text-end"><div class="remove-item"><i class="fas fa-times"></i></div></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <button type="button" class="btn btn-add-item mt-2" id="addItemBtn">
                        <i class="fas fa-plus-circle me-1"></i> Add Another Product
                    </button>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="pos-card sticky-top" style="top: 100px;">
                    <div class="section-title"><i class="fas fa-file-invoice-dollar"></i> Order Summary</div>
                    
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Subtotal</span>
                        <span class="fw-bold">₹<span id="subTotal">0.00</span></span>
                    </div>
                    <div class="d-flex justify-content-between mb-4">
                        <span class="text-muted">Tax (GST 0%)</span>
                        <span class="fw-bold">₹0.00</span>
                    </div>
                    
                    <div class="grand-total-display mb-4">
                        <div class="small opacity-75">Payable Amount</div>
                        <div class="display-6 fw-bold">₹<span id="grandTotal">0.00</span></div>
                    </div>

                    <button type="submit" name="submit" class="btn btn-generate">
                        PROCEED TO PRINT <i class="fas fa-chevron-right ms-2"></i>
                    </button>
                    
                    <div class="text-center mt-3">
                        <a href="shopDashboard.jsp" class="text-decoration-none text-muted small">Cancel Transaction</a>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
function updateTotals(row){
    var selected = row.find(".item-select option:selected");
    var price = parseFloat(selected.data("price") || 0);
    var stock = parseInt(selected.data("stock") || 0);
    var qtyInput = row.find(".qty-input");
    var qty = parseInt(qtyInput.val() || 1);

    if(qty > stock) {
        alert("Only " + stock + " items available in stock!");
        qtyInput.val(stock);
        qty = stock;
    }

    row.find(".item-price").text(price.toFixed(2));
    row.find(".item-total").text((price*qty).toFixed(2));
    
    var grandTotal=0;
    $("#itemsTable tbody tr").each(function(){
        grandTotal += parseFloat($(this).find(".item-total").text())||0;
    });
    $("#grandTotal, #subTotal").text(grandTotal.toFixed(2));
}

$(document).ready(function(){
    $("#itemsTable").on("change",".item-select,.qty-input",function(){ 
        updateTotals($(this).closest("tr")); 
    });

    $("#addItemBtn").click(function(){
        var newRow = $("#itemsTable tbody tr:first").clone();
        newRow.find("select").val(""); 
        newRow.find(".item-price,.item-total").text("0.00");
        newRow.find(".qty-input").val(1);
        $("#itemsTable tbody").append(newRow);
    });

    $("#itemsTable").on("click",".remove-item",function(){
        if($("#itemsTable tbody tr").length > 1) {
            $(this).closest("tr").remove();
            updateTotals($("#itemsTable tbody tr:first"));
        }
    });
});
</script>
</body>
</html>