package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/RemoveCartItemServlet")
public class RemoveCartItemServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int cartId = Integer.parseInt(request.getParameter("cartId"));

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement("DELETE FROM cart WHERE cart_id=?");
            ps.setInt(1, cartId);

            ps.executeUpdate();

            response.sendRedirect("cart.jsp?msg=removed");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("cart.jsp?msg=error");
        }
    }
}
