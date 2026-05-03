<%@ page import="java.util.*, java.sql.*, com.utils.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer orderId = (Integer) session.getAttribute("invoiceOrderId");
    if(orderId==null){ response.sendRedirect("walkinInvoice.jsp"); return; }

    String shopName = (String) session.getAttribute("invoiceShopName");
    String shopPhone = (String) session.getAttribute("invoiceShopPhone");
    String shopAddress = (String) session.getAttribute("invoiceShopAddress");

    String customerName = (String) session.getAttribute("invoiceCustomerName");
    String customerPhone = (String) session.getAttribute("invoicePhone");
    List<Map<String,Object>> orderItems = (List<Map<String,Object>>) session.getAttribute("invoiceOrderItems");
    double totalAmount = (Double) session.getAttribute("invoiceTotal");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Invoice #<%=orderId%> - MartSmart</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <link rel="stylesheet" href="css/all.min.css">
    <style>
        :root {
            --sunset-start: #ee0979;
            --sunset-end: #ff6a00;
        }

        body {
            background-color: #f4f7f6;
            font-family: 'Inter', 'Segoe UI', sans-serif;
        }

        /* --- INVOICE CONTAINER --- */
        .invoice-wrapper {
            max-width: 800px;
            margin: 40px auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .invoice-header {
            background: linear-gradient(90deg, var(--sunset-start), var(--sunset-end));
            color: white;
            padding: 30px;
        }

        .invoice-body {
            padding: 40px;
        }

        /* --- DASHED DIVIDER --- */
        .receipt-divider {
            border-top: 2px dashed #eee;
            margin: 25px 0;
            position: relative;
        }

        /* --- TABLE STYLING --- */
        .table thead th {
            background-color: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
            text-transform: uppercase;
            font-size: 0.8rem;
            letter-spacing: 1px;
        }

        .grand-total-box {
            background: #fdf2f8;
            border: 1px solid #fbcfe8;
            padding: 20px;
            border-radius: 10px;
            color: var(--sunset-start);
        }

        /* --- BUTTONS --- */
        .btn-print {
            background: #334155;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-paid {
            background: linear-gradient(90deg, var(--sunset-start), var(--sunset-end));
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 700;
        }

        /* --- PRINT MEDIA QUERIES --- */
        @media print {
            body { background: white; }
            .no-print, .btn-print, .btn-paid, form { display: none !important; }
            .invoice-wrapper { box-shadow: none; margin: 0; width: 100%; max-width: 100%; }
            .invoice-header { background: white !important; color: black !important; border-bottom: 2px solid #333; }
            .invoice-body { padding: 20px 0; }
            .grand-total-box { border: 2px solid #000; background: white !important; }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="invoice-wrapper">
        <div class="invoice-header d-flex justify-content-between align-items-center">
            <div>
                <h2 class="fw-bold mb-0"><%=shopName.toUpperCase()%></h2>
                <p class="mb-0 opacity-75"><i class="fas fa-map-marker-alt me-1"></i> <%=shopAddress%></p>
                <p class="mb-0 opacity-75"><i class="fas fa-phone me-1"></i> <%=shopPhone%></p>
            </div>
            <div class="text-end">
                <h4 class="mb-0">INVOICE</h4>
                <p class="mb-0">#INV-<%=orderId%></p>
            </div>
        </div>

        <div class="invoice-body">
            <div class="row mb-4">
                <div class="col-6">
                    <p class="text-muted small mb-1">BILLED TO:</p>
                    <h5 class="fw-bold mb-0"><%=customerName%></h5>
                    <p class="text-muted"><%=customerPhone%></p>
                </div>
                <div class="col-6 text-end">
                    <p class="text-muted small mb-1">DATE ISSUED:</p>
                    <h5 class="fw-bold"><%= new java.text.SimpleDateFormat("dd MMM yyyy").format(new java.util.Date()) %></h5>
                </div>
            </div>

            <div class="receipt-divider"></div>

            <div class="table-responsive">
                <table class="table table-borderless">
                    <thead>
                        <tr>
                            <th width="50%">Item Description</th>
                            <th class="text-center">Price</th>
                            <th class="text-center">Qty</th>
                            <th class="text-end">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for(Map<String,Object> o: orderItems){ %>
                            <tr class="border-bottom">
                                <td class="py-3">
                                    <span class="fw-bold text-dark"><%=o.get("itemName")%></span>
                                </td>
                                <td class="py-3 text-center">₹<%=o.get("price")%></td>
                                <td class="py-3 text-center">x<%=o.get("qty")%></td>
                                <td class="py-3 text-end fw-bold">₹<%=o.get("itemTotal")%></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="row mt-4 align-items-center">
                <div class="col-md-7">
                    <p class="small text-muted italic">Note: This is a computer-generated invoice and does not require a signature.</p>
                </div>
                <div class="col-md-5">
                    <div class="grand-total-box d-flex justify-content-between align-items-center">
                        <span class="fw-bold">GRAND TOTAL</span>
                        <h3 class="fw-bold mb-0">₹<%=totalAmount%></h3>
                    </div>
                </div>
            </div>

            <div class="mt-5 d-flex gap-2 no-print">
                <button class="btn btn-print flex-grow-1" onclick="window.print()">
                    <i class="fas fa-print me-2"></i> Print Invoice
                </button>
                <form method="post" action="markPaid.jsp" class="flex-grow-1">
                    <input type="hidden" name="orderId" value="<%=orderId%>">
                    <button type="submit" class="btn btn-paid w-100">
                        <i class="fas fa-check-circle me-2"></i> Mark as Paid
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

</body>
</html>