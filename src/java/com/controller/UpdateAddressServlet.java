package com.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.utils.DBConnection;

@WebServlet("/UpdateAddressServlet")
public class UpdateAddressServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Integer customerId = (Integer) session.getAttribute("customerId");
        if (customerId == null) {
            response.sendRedirect("customerLogin.jsp?msg=loginfirst");
            return;
        }

        String address = request.getParameter("address");
        String city = request.getParameter("city");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();

            String sql = "UPDATE customers SET address=?, city=? WHERE customer_id=?";
            ps = con.prepareStatement(sql);
            ps.setString(1, address);
            ps.setString(2, city);
            ps.setInt(3, customerId);

            int rows = ps.executeUpdate();

            if (rows > 0) {
                // Update session values also
                session.setAttribute("customerAddress", address);
                session.setAttribute("customerCity", city);

                response.sendRedirect("placeOrder.jsp?msg=addressUpdated");
            } else {
                response.sendRedirect("placeOrder.jsp?msg=updateFailed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("placeOrder.jsp?msg=error");
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
