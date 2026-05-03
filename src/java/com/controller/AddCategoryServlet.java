package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/AddCategoryServlet")
public class AddCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer shopId = (Integer) session.getAttribute("shopId");

        if (shopId == null) {
            response.sendRedirect("shopLogin.jsp?msg=loginfirst");
            return;
        }

        String categoryName = request.getParameter("categoryName");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("INSERT INTO shop_categories (shop_id, category_name) VALUES (?, ?)")) {

            ps.setInt(1, shopId);
            ps.setString(2, categoryName);
            ps.executeUpdate();

            response.sendRedirect("manageCategory.jsp?msg=added");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("manageCategory.jsp?msg=error");
        }
    }
}
