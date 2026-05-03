<%@ page import="java.sql.*, com.utils.DBConnection" %>
<%
    Integer orderId = Integer.parseInt(request.getParameter("orderId"));
    Connection con = DBConnection.getConnection();
    PreparedStatement ps = null;
    ResultSet rs = null;

    // 1. Reduce stock
    ps = con.prepareStatement("SELECT item_id, quantity FROM order_items WHERE order_id=?");
    ps.setInt(1, orderId);
    rs = ps.executeQuery();
    while(rs.next()){
        int itemId = rs.getInt("item_id");
        int qty = rs.getInt("quantity");

        ps = con.prepareStatement("UPDATE shop_items SET quantity = quantity - ? WHERE item_id=?");
        ps.setInt(1, qty);
        ps.setInt(2, itemId);
        ps.executeUpdate();
    }

    // 2. Mark order as paid
    ps = con.prepareStatement("UPDATE orders SET payment_status='paid' ,status='Delivered',agent_id='null' WHERE order_id=?");
    ps.setInt(1, orderId);
    ps.executeUpdate();

    response.sendRedirect("printInvoice.jsp?msg=Payment successful!");
%>
