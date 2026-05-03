package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/ApproveOrderServlet")
public class ApproveOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String orderIdStr = request.getParameter("id");

        if(orderIdStr == null){
            response.sendRedirect("viewOrders.jsp?msg=invalid");
            return;
        }

        int orderId = Integer.parseInt(orderIdStr);

        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Start transaction

            // 1. Fetch order items
            String fetchItems = "SELECT item_id, quantity FROM order_items WHERE order_id=?";
            try (PreparedStatement psFetch = con.prepareStatement(fetchItems)) {
                psFetch.setInt(1, orderId);
                try (ResultSet rsItems = psFetch.executeQuery()) {

                    boolean stockAvailable = true;

                    // Check stock availability first
                    while(rsItems.next()){
                        int itemId = rsItems.getInt("item_id");
                        int orderQty = rsItems.getInt("quantity");

                        String checkStockSql = "SELECT quantity FROM shop_items WHERE item_id=? FOR UPDATE";
                        try (PreparedStatement psCheck = con.prepareStatement(checkStockSql)) {
                            psCheck.setInt(1, itemId);
                            try (ResultSet rsCheck = psCheck.executeQuery()) {
                                if(rsCheck.next()){
                                    int currentQty = rsCheck.getInt("quantity");
                                    if(currentQty < orderQty){
                                        stockAvailable = false;
                                        break;
                                    }
                                } else {
                                    stockAvailable = false;
                                    break;
                                }
                            }
                        }
                    }

                    if(!stockAvailable){
                        con.rollback();
                        response.sendRedirect("viewOrders.jsp?msg=nostock");
                        return;
                    }
                }
            }

            // 2. Deduct quantity from shop_items
            try (PreparedStatement psFetch2 = con.prepareStatement(fetchItems)) {
                psFetch2.setInt(1, orderId);
                try (ResultSet rsItems2 = psFetch2.executeQuery()) {
                    while(rsItems2.next()){
                        int itemId = rsItems2.getInt("item_id");
                        int orderQty = rsItems2.getInt("quantity");

                        String updateQtySql = "UPDATE shop_items SET quantity = quantity - ? WHERE item_id=?";
                        try (PreparedStatement psUpdate = con.prepareStatement(updateQtySql)) {
                            psUpdate.setInt(1, orderQty);
                            psUpdate.setInt(2, itemId);
                            psUpdate.executeUpdate();
                        }
                    }
                }
            }

            // 3. Update order status to approved
            String updateOrderSql = "UPDATE orders SET status='approved' WHERE order_id=?";
            try (PreparedStatement psUpdateOrder = con.prepareStatement(updateOrderSql)) {
                psUpdateOrder.setInt(1, orderId);
                psUpdateOrder.executeUpdate();
            }

            con.commit();
            response.sendRedirect("viewOrders.jsp?msg=approved");

        } catch(Exception e){
            e.printStackTrace();
            try { if(con != null) con.rollback(); } catch(Exception ex) { ex.printStackTrace(); }
            response.sendRedirect("viewOrders.jsp?msg=error");
        } finally {
            try { if(con != null) con.setAutoCommit(true); con.close(); } catch(Exception ex) { ex.printStackTrace(); }
        }
    }
}
