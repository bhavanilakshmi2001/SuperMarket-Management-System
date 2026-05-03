package com.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/MarkDeliveredServlet")
public class MarkDeliveredServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer agentId = (Integer) session.getAttribute("agentId");

        if (agentId == null) {
            response.sendRedirect("agentLogin.jsp?msg=loginfirst");
            return;
        }

        String orderIdParam = request.getParameter("orderId");

        if (orderIdParam == null || orderIdParam.isEmpty()) {
            response.sendRedirect("assignedOrders.jsp?msg=invalidorder");
            return;
        }

        int orderId = Integer.parseInt(orderIdParam);

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();

            // Update only if the logged-in agent is assigned to this order
            String sql = "UPDATE orders SET status='delivered' WHERE order_id=? AND agent_id=?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.setInt(2, agentId);

            int updated = ps.executeUpdate();

            if (updated > 0) {
                response.sendRedirect("assignedOrders.jsp?msg=delivered");
            } else {
                response.sendRedirect("assignedOrders.jsp?msg=notauthorized");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("assignedOrders.jsp?msg=error");
        } finally {
            try { if(ps!=null) ps.close(); } catch(Exception e) {}
            try { if(con!=null) con.close(); } catch(Exception e) {}
        }
    }
}
