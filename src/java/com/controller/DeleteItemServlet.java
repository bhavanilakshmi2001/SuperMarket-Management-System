package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import com.utils.DBConnection;

public class DeleteItemServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer shopId = (Integer) request.getSession().getAttribute("shopId");
        if(shopId == null) {
            response.sendRedirect("shopLogin.jsp?msg=loginfirst");
            return;
        }

        int itemId = Integer.parseInt(request.getParameter("id"));

        try(Connection con = DBConnection.getConnection()){
            PreparedStatement ps = con.prepareStatement("DELETE FROM shop_items WHERE item_id=? AND shop_id=?");
            ps.setInt(1, itemId);
            ps.setInt(2, shopId);
            ps.executeUpdate();
            response.sendRedirect("manageItems.jsp?msg=Item deleted successfully");
        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("manageItems.jsp?msg=Error deleting item");
        }
    }
}
