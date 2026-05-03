package com.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

@WebServlet("/AgentLoginServlet")
public class AgentLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM agents WHERE email=? AND password=?"
            );
            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if(rs.next()) {
                String status = rs.getString("status");
                if("approved".equalsIgnoreCase(status)) {
                    // Set session attributes
                    HttpSession session = request.getSession();
                    session.setAttribute("agentId", rs.getInt("agent_id"));
                    session.setAttribute("agentName", rs.getString("name"));
                    session.setAttribute("agentCity", rs.getString("city"));

                    response.sendRedirect("agentDashboard.jsp"); // Redirect to agent dashboard
                } else if("pending".equalsIgnoreCase(status)) {
                    response.sendRedirect("agentLogin.jsp?msg=invalid"); // Not approved yet
                } else { // rejected
                    response.sendRedirect("agentLogin.jsp?msg=invalid"); 
                }
            } else {
                response.sendRedirect("agentLogin.jsp?msg=invalid"); // Invalid credentials
            }

        } catch(Exception e){
            e.printStackTrace();
            response.sendRedirect("agentLogin.jsp?msg=invalid");
        }
    }
}
