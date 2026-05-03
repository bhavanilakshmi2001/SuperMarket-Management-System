package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/CustomerRegisterServlet")
public class CustomerRegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String city = request.getParameter("city");
        String address = request.getParameter("address");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnection.getConnection();

            // CHECK IF EMAIL ALREADY EXISTS
            ps = con.prepareStatement("SELECT * FROM customers WHERE email=?");
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                response.sendRedirect("customerRegister.jsp?msg=exists");
                return;
            }

            // INSERT CUSTOMER
            ps = con.prepareStatement(
                "INSERT INTO customers(name, email, phone, password, city, address) VALUES (?,?,?,?,?,?)"
            );

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, password);
            ps.setString(5, city);
            ps.setString(6, address);
      

            int i = ps.executeUpdate();

            if (i > 0) {
                response.sendRedirect("customerLogin.jsp?msg=success");
            } else {
                response.sendRedirect("customerRegister.jsp?msg=failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("customerRegister.jsp?msg=error");
        }
    }
}
