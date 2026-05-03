package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/CustomerLoginServlet")
public class CustomerLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Changed parameter name to match the multi-purpose input
        String identifier = request.getParameter("loginIdentifier"); 
        String password = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();
            
            // Updated SQL: Checks if identifier matches either email OR phone
            String sql = "SELECT * FROM customers WHERE (email=? OR phone=?) AND password=?";
            ps = con.prepareStatement(sql);
            
            ps.setString(1, identifier); // For email column
            ps.setString(2, identifier); // For phone column
            ps.setString(3, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // SESSION CREATION
                HttpSession session = request.getSession();
                session.setAttribute("customerId", rs.getInt("customer_id"));
                session.setAttribute("customerName", rs.getString("name"));
                session.setAttribute("customerEmail", rs.getString("email"));

                response.sendRedirect("customerDashboard.jsp");
            } else {
                response.sendRedirect("customerLogin.jsp?msg=invalid");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("customerLogin.jsp?msg=error");
        } finally {
            // Good practice: close resources
            try { if(ps != null) ps.close(); if(con != null) con.close(); } catch(SQLException e) { e.printStackTrace(); }
        }
    }
}