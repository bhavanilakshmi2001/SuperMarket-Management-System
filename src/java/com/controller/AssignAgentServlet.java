package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/AssignAgentServlet")
public class AssignAgentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String orderIdStr = request.getParameter("orderId");
        String agentIdStr = request.getParameter("agentId");

        if(orderIdStr != null && agentIdStr != null && !agentIdStr.isEmpty()){
            int orderId = Integer.parseInt(orderIdStr);
            int agentId = Integer.parseInt(agentIdStr);

            Connection con = null;
            PreparedStatement psCount = null;
            PreparedStatement psAssign = null;
            ResultSet rs = null;

            try {
                con = DBConnection.getConnection();
                con.setAutoCommit(false); // Start transaction

                // 1. Check how many active/pending orders this agent already has
                String countSql = "SELECT COUNT(*) AS cnt FROM orders WHERE agent_id=? AND status='assigned'";
                psCount = con.prepareStatement(countSql);
                psCount.setInt(1, agentId);
                rs = psCount.executeQuery();
                int activeOrders = 0;
                if(rs.next()) activeOrders = rs.getInt("cnt");
                rs.close();
                psCount.close();

                if(activeOrders >= 5){
                    response.sendRedirect("viewOrders.jsp?msg=agentlimit");
                    return;
                }

                // 2. Assign agent AND update status to 'assigned'
                String assignSql = "UPDATE orders SET agent_id=?, status='assigned' WHERE order_id=?";
                psAssign = con.prepareStatement(assignSql);
                psAssign.setInt(1, agentId);
                psAssign.setInt(2, orderId);
                psAssign.executeUpdate();
                psAssign.close();

                con.commit();
                response.sendRedirect("viewOrders.jsp?msg=assigned");

            } catch(Exception e){
                e.printStackTrace();
                try { if(con != null) con.rollback(); } catch(Exception ex) {}
                response.sendRedirect("viewOrders.jsp?msg=error");
            } finally {
                try { if(rs != null) rs.close(); } catch(Exception e) {}
                try { if(psCount != null) psCount.close(); } catch(Exception e) {}
                try { if(psAssign != null) psAssign.close(); } catch(Exception e) {}
                try { if(con != null) con.close(); } catch(Exception e) {}
            }

        } else {
            response.sendRedirect("viewOrders.jsp?msg=invalid");
        }
    }
}
