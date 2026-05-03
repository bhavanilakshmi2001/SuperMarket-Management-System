package com.controller;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/PlaceOrderServlet")
public class PlaceOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private class CartItem {
        int itemId, quantity;
        double price;
        CartItem(int itemId, int quantity, double price){
            this.itemId = itemId;
            this.quantity = quantity;
            this.price = price;
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");

        if(customerId == null){
            response.sendRedirect("customerLogin.jsp?msg=loginfirst");
            return;
        }

        int shopId = Integer.parseInt(request.getParameter("shopId"));

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement ps2 = null;
        PreparedStatement ps3 = null;
        ResultSet rs = null;

        try{
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Transaction begin

            // 1. Fetch cart items for this shop
            String cartQuery = "SELECT c.item_id, c.quantity, i.price " +
                               "FROM cart c JOIN shop_items i ON c.item_id = i.item_id " +
                               "WHERE c.customer_id=? AND c.shop_id=?";
            ps = con.prepareStatement(cartQuery);
            ps.setInt(1, customerId);
            ps.setInt(2, shopId);
            rs = ps.executeQuery();

            List<CartItem> items = new ArrayList<>();
            double totalAmount = 0;

            while(rs.next()){
                int itemId = rs.getInt("item_id");
                int qty = rs.getInt("quantity");
                double price = rs.getDouble("price");
                totalAmount += qty * price;
                items.add(new CartItem(itemId, qty, price));
            }

            if(items.isEmpty()){
                response.sendRedirect("placeOrder.jsp?msg=empty");
                return;
            }

            // 2. Insert into orders table
            String insertOrder = "INSERT INTO orders (customer_id, shop_id, total_amount, status, payment_status) " +
                                 "VALUES (?, ?, ?, 'pending', 'unpaid')";
            ps2 = con.prepareStatement(insertOrder, Statement.RETURN_GENERATED_KEYS);
            ps2.setInt(1, customerId);
            ps2.setInt(2, shopId);
            ps2.setDouble(3, totalAmount);
       
            ps2.executeUpdate();

            rs = ps2.getGeneratedKeys();
            int orderId = 0;
            if(rs.next()){
                orderId = rs.getInt(1);
            }

            // 3. Insert order_items
            String insertItems = "INSERT INTO order_items (order_id, item_id, quantity, price) VALUES (?, ?, ?, ?)";
            ps3 = con.prepareStatement(insertItems);
            for(CartItem ci : items){
                ps3.setInt(1, orderId);
                ps3.setInt(2, ci.itemId);
                ps3.setInt(3, ci.quantity);
                ps3.setDouble(4, ci.price);
                ps3.addBatch();
            }
            ps3.executeBatch();

            // 4. Delete cart items for this shop
            PreparedStatement ps4 = con.prepareStatement("DELETE FROM cart WHERE customer_id=? AND shop_id=?");
            ps4.setInt(1, customerId);
            ps4.setInt(2, shopId);
            ps4.executeUpdate();

            con.commit();
            response.sendRedirect("myOrders.jsp?msg=success&orderId=" + orderId);

        }catch(Exception e){
            e.printStackTrace();
            try { if(con != null) con.rollback(); } catch(Exception ex){}
            response.sendRedirect("placeOrder.jsp?msg=error");
        }finally{
            try { if(rs != null) rs.close(); } catch(Exception e){}
            try { if(ps != null) ps.close(); } catch(Exception e){}
            try { if(ps2 != null) ps2.close(); } catch(Exception e){}
            try { if(ps3 != null) ps3.close(); } catch(Exception e){}
            try { if(con != null) con.close(); } catch(Exception e){}
        }
    }
}
