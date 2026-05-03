package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/PayNowServlet")
public class PayNowServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ========================
        // 1. Fetch Data from JSP
        // ========================
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        double amount = Double.parseDouble(request.getParameter("amount"));
        // Optional: you can fetch payment mode if you have multiple modes
        String paymentMode = request.getParameter("paymentMode") != null ? request.getParameter("paymentMode") : "ONLINE";

        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            response.sendRedirect("customerLogin.jsp?msg=loginfirst");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false); // Start transaction

            // ===========================
            // 2. Update orders table
            // ===========================
            String updateOrder = "UPDATE orders SET payment_status='paid' WHERE order_id=? AND customer_id=?";
            ps = con.prepareStatement(updateOrder);
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);

            int rows = ps.executeUpdate();

            if(rows > 0){
                

                con.commit(); // Commit transaction

                response.sendRedirect("myOrders.jsp?msg=paid");
            } else {
                con.rollback();
                response.sendRedirect("myOrders.jsp?msg=error");
            }

        } catch(Exception e){
            e.printStackTrace();
            try { if(con != null) con.rollback(); } catch(Exception ex){}
            response.sendRedirect("myOrders.jsp?msg=error");
        } finally {
            try { if(ps != null) ps.close(); } catch(Exception e){}
            try { if(con != null) con.close(); } catch(Exception e){}
        }
    }
}
