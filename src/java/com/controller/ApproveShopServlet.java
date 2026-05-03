package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/ApproveShopServlet")
public class ApproveShopServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("UPDATE shops SET status='approved' WHERE shop_id=?");
            ps.setInt(1, id);
            ps.executeUpdate();

            response.sendRedirect("viewShops.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
