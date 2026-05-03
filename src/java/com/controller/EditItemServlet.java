package com.controller;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import com.utils.DBConnection;
import javax.servlet.annotation.WebServlet;
@WebServlet("/EditItemServlet")
@MultipartConfig
public class EditItemServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer shopId = (Integer) request.getSession().getAttribute("shopId");
        if(shopId == null) {
            response.sendRedirect("shopLogin.jsp?msg=loginfirst");
            return;
        }

        int itemId = Integer.parseInt(request.getParameter("itemId"));
        String itemName = request.getParameter("itemName");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        double price = Double.parseDouble(request.getParameter("price"));
        int quantity = Integer.parseInt(request.getParameter("quantity"));

        Part filePart = request.getPart("itemImage");
        String fileName = null;
        if(filePart != null && filePart.getSize() > 0){
            fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
            String uploadPath = getServletContext().getRealPath("") + "uploads";
            File uploadDir = new File(uploadPath);
            if(!uploadDir.exists()) uploadDir.mkdir();
            filePart.write(uploadPath + File.separator + fileName);
        }

        try(Connection con = DBConnection.getConnection()){
            String sql = "UPDATE shop_items SET category_id=?, item_name=?, price=?, quantity=?";
            if(fileName != null) sql += ", item_image=?";
            sql += " WHERE item_id=? AND shop_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, categoryId);
            ps.setString(2, itemName);
            ps.setDouble(3, price);
            ps.setInt(4, quantity);
            int index = 5;
            if(fileName != null){
                ps.setString(index++, fileName);
            }
            ps.setInt(index++, itemId);
            ps.setInt(index, shopId);
            ps.executeUpdate();
            response.sendRedirect("manageItems.jsp?msg=Item updated successfully");
        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("manageItems.jsp?msg=Error updating item");
        }
    }
}
