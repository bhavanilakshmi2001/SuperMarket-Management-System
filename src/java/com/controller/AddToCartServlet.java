package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            resp.sendRedirect("customerLogin.jsp?msg=loginfirst");
            return;
        }

        int itemId = Integer.parseInt(req.getParameter("itemId"));
        int shopId = Integer.parseInt(req.getParameter("shopId"));

        Connection con = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;

        try {
            con = DBConnection.getConnection();

            // Check if item already exists in cart
            psCheck = con.prepareStatement(
                "SELECT * FROM cart WHERE customer_id=? AND item_id=?"
            );
            psCheck.setInt(1, customerId);
            psCheck.setInt(2, itemId);

            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                // Increase quantity
                int currentQty = rs.getInt("quantity");

                psInsert = con.prepareStatement(
                    "UPDATE cart SET quantity=? WHERE customer_id=? AND item_id=?"
                );
                psInsert.setInt(1, currentQty + 1);
                psInsert.setInt(2, customerId);
                psInsert.setInt(3, itemId);

                psInsert.executeUpdate();
            } 
            else {
                // Insert new item into cart
                psInsert = con.prepareStatement(
                    "INSERT INTO cart (customer_id, shop_id, item_id, quantity) VALUES (?, ?, ?, ?)"
                );
                psInsert.setInt(1, customerId);
                psInsert.setInt(2, shopId);
                psInsert.setInt(3, itemId);
                psInsert.setInt(4, 1);

                psInsert.executeUpdate();
            }

            resp.sendRedirect("cart.jsp?msg=added");

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("viewShopDetails.jsp?shopId=" + shopId + "&msg=error");
        }
    }

}
