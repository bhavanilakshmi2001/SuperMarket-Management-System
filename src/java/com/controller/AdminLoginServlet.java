package com.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String uname = request.getParameter("username");
        String pass = request.getParameter("password");

        response.setContentType("text/html;charset=UTF-8");
        java.io.PrintWriter out = response.getWriter();

        if (uname.equals("admin") && pass.equals("admin")) {

            // SUCCESS
            HttpSession session = request.getSession();
            session.setAttribute("adminId", "admin");

            out.println("<script type='text/javascript'>");
            out.println("alert('Login Successful!');");
            out.println("window.location='adminDashboard.jsp';");
            out.println("</script>");

        } else {

            // FAILURE
            out.println("<script type='text/javascript'>");
            out.println("alert('Invalid Username or Password!');");
            out.println("window.location='adminLogin.jsp';");
            out.println("</script>");
        }
    }
}
