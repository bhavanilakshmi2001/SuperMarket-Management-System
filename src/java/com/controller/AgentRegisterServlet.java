package com.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/AgentRegisterServlet")
public class AgentRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String city = request.getParameter("city");
        String address = request.getParameter("address");
        String password = request.getParameter("password");

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO agents(name, phone, email, city, address, password, status) VALUES (?, ?, ?, ?, ?, ?, 'pending')"
            );
            ps.setString(1, name);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setString(4, city);
            ps.setString(5, address);
            ps.setString(6, password);

            int i = ps.executeUpdate();
            if(i > 0){
                response.sendRedirect("agentLogin.jsp?msg=registered");
            } else {
                response.sendRedirect("agentRegister.jsp?msg=error");
            }

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("agentRegister.jsp?msg=error");
        }
    }
}
