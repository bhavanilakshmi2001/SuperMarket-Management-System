package com.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/RejectOrderServlet")
public class RejectOrderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String orderIdStr = request.getParameter("id");

        if(orderIdStr != null){
            int orderId = Integer.parseInt(orderIdStr);
            try (Connection con = DBConnection.getConnection()) {
                String sql = "UPDATE orders SET status='rejected' WHERE order_id=?";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setInt(1, orderId);
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("viewOrders.jsp?msg=rejected");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("viewOrders.jsp?msg=error");
            }
        } else {
            response.sendRedirect("viewOrders.jsp?msg=invalid");
        }
    }
}
