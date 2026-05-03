package com.controller;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;

import com.utils.DBConnection;
import javax.servlet.annotation.WebServlet;
@WebServlet("/AddItemServlet")
@MultipartConfig(fileSizeThreshold=1024*1024*2, // 2MB
                 maxFileSize=1024*1024*10,      // 10MB
                 maxRequestSize=1024*1024*50)   // 50MB
public class AddItemServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer shopId = (Integer) session.getAttribute("shopId");
        if(shopId == null) {
            response.sendRedirect("shopLogin.jsp?msg=loginfirst");
            return;
        }

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
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO shop_items (shop_id, category_id, item_name, price, quantity, item_image) VALUES (?, ?, ?, ?, ?, ?)"
            );
            ps.setInt(1, shopId);
            ps.setInt(2, categoryId);
            ps.setString(3, itemName);
            ps.setDouble(4, price);
            ps.setInt(5, quantity);
            ps.setString(6, fileName);
            ps.executeUpdate();
            response.sendRedirect("manageItems.jsp?msg=Item added successfully");
        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("manageItems.jsp?msg=Error adding item");
        }
    }
}
