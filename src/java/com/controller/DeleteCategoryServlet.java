package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/DeleteCategoryServlet")
public class DeleteCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer shopId = (Integer) session.getAttribute("shopId");

        if (shopId == null) {
            response.sendRedirect("shopLogin.jsp?msg=loginfirst");
            return;
        }

        int categoryId = Integer.parseInt(request.getParameter("id"));

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM shop_categories WHERE category_id=? AND shop_id=?")) {

            ps.setInt(1, categoryId);
            ps.setInt(2, shopId);
            ps.executeUpdate();

            response.sendRedirect("manageCategory.jsp?msg=deleted");

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("manageCategory.jsp?msg=error");
        }
    }
}
