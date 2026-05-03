package com.controller;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/ShopRegisterServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,   // 1MB
    maxFileSize = 5 * 1024 * 1024,     // 5MB
    maxRequestSize = 10 * 1024 * 1024  // 10MB
)
public class ShopRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Form parameters
        String shopName = request.getParameter("shopName");
        String ownerName = request.getParameter("ownerName");
        String email = request.getParameter("email"); // <-- Added email
        String phone = request.getParameter("phone");
        String city = request.getParameter("city");
        String shopAddress = request.getParameter("address");
        String password = request.getParameter("password");

        // File upload (shop image)
        Part imagePart = request.getPart("image");
        String fileName = "";
        if (imagePart != null && imagePart.getSize() > 0) {
            fileName = new File(imagePart.getSubmittedFileName()).getName();

            String uploadPath = getServletContext().getRealPath("") + File.separator + "shop_images";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }

            imagePart.write(uploadPath + File.separator + fileName);
        }

        // Insert into database
        try {
            Connection con = DBConnection.getConnection();

            String sql = "INSERT INTO shops (shop_name, shop_address, phone, owner_name, email, city, password, shop_image, status) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending')";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, shopName);
            ps.setString(2, shopAddress);
            ps.setString(3, phone);
            ps.setString(4, ownerName);
            ps.setString(5, email); // <-- set email
            ps.setString(6, city);
            ps.setString(7, password);
            ps.setString(8, fileName);

            int row = ps.executeUpdate();

            if (row > 0) {
                response.sendRedirect("shopLogin.jsp?msg=registered");
            } else {
                response.sendRedirect("shopRegister.jsp?msg=error");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("shopRegister.jsp?msg=exception");
        }
    }
}
