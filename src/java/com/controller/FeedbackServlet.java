package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import com.utils.DBConnection;

@WebServlet("/FeedbackServlet")
public class FeedbackServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            response.sendRedirect("customerLogin.jsp?msg=loginfirst");
            return;
        }

        int orderId = Integer.parseInt(request.getParameter("orderId"));

        try (Connection con = DBConnection.getConnection()) {

            // Fetch all order items for this order
            PreparedStatement psCheck = con.prepareStatement(
                "SELECT order_item_id FROM order_items WHERE order_id=?"
            );
            psCheck.setInt(1, orderId);
            ResultSet rs = psCheck.executeQuery();

            // Prepare insert/update for feedback
            PreparedStatement psInsert = con.prepareStatement(
                "INSERT INTO feedback(customer_id, order_id, order_item_id, rating, comments) " +
                "VALUES(?,?,?,?,?) " +
                "ON DUPLICATE KEY UPDATE rating=?, comments=?"
            );

            while (rs.next()) {
                int orderItemId = rs.getInt("order_item_id");

                String ratingStr = request.getParameter("rating_" + orderItemId);
                String comment = request.getParameter("comment_" + orderItemId);

                if (ratingStr != null && !ratingStr.isEmpty()) {
                    int rating = Integer.parseInt(ratingStr);

                    psInsert.setInt(1, customerId);
                    psInsert.setInt(2, orderId);
                    psInsert.setInt(3, orderItemId);
                    psInsert.setInt(4, rating);
                    psInsert.setString(5, comment);

                    psInsert.setInt(6, rating); // for ON DUPLICATE KEY UPDATE
                    psInsert.setString(7, comment);

                    psInsert.addBatch();
                }
            }

            psInsert.executeBatch();

            rs.close();
            psCheck.close();
            psInsert.close();

            response.sendRedirect("myOrders.jsp?msg=feedbackSuccess");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("myOrders.jsp?msg=feedbackError");
        }
    }
}
