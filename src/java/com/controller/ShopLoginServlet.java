package com.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/ShopLoginServlet")
public class ShopLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Connection con = DBConnection.getConnection();
            String sql = "SELECT * FROM shops WHERE email=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String status = rs.getString("status");

                if ("approved".equals(status)) {
                    // Set session
                    HttpSession session = request.getSession();
                    session.setAttribute("shopId", rs.getInt("shop_id"));
                    session.setAttribute("shopName", rs.getString("shop_name"));

                    // Redirect to shop dashboard
                    response.sendRedirect("shopDashboard.jsp");
                } else if ("pending".equals(status)) {
                    response.sendRedirect("shopLogin.jsp?msg=pending");
                } else {
                    response.sendRedirect("shopLogin.jsp?msg=rejected");
                }

            } else {
                response.sendRedirect("shopLogin.jsp?msg=invalid");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("shopLogin.jsp?msg=invalid");
        }
    }
}
