package com.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import com.utils.DBConnection;

// iText PDF imports
import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

@WebServlet("/DownloadInvoiceServlet")
public class DownloadInvoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer customerId = (Integer) session.getAttribute("customerId");

        if (customerId == null) {
            response.sendRedirect("customerLogin.jsp?msg=loginfirst");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        if(orderIdStr == null) {
            response.sendRedirect("myOrders.jsp");
            return;
        }
        int orderId = Integer.parseInt(orderIdStr);

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnection.getConnection();

            // Fetch order, customer, shop info
            String orderQuery = "SELECT o.*, c.name AS customer_name, c.phone AS customer_phone, c.address AS customer_address, " +
                                "s.shop_name, s.owner_name, s.phone AS shop_phone, s.shop_address " +
                                "FROM orders o " +
                                "LEFT JOIN customers c ON o.customer_id=c.customer_id " +
                                "LEFT JOIN shops s ON o.shop_id=s.shop_id " +
                                "WHERE o.order_id=? AND o.customer_id=?";
            ps = con.prepareStatement(orderQuery);
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            rs = ps.executeQuery();

            if (!rs.next()) {
                response.sendRedirect("myOrders.jsp?msg=invalid");
                return;
            }

            // PDF Configuration
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=Invoice_Order_" + orderId + ".pdf");

            Document document = new Document(PageSize.A4);
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();

            // Custom Branding Color (Sunset Pink #ee0979)
            BaseColor themeColor = new BaseColor(238, 9, 121);
            
            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, themeColor);
            Font subHeaderFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.GRAY);
            Font boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
            Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 11);

            // Invoice Header
            Paragraph title = new Paragraph(rs.getString("shop_name").toUpperCase(), titleFont);
            title.setAlignment(Element.ALIGN_LEFT);
            document.add(title);
            
            document.add(new Paragraph("Order Invoice #" + orderId, subHeaderFont));
            document.add(new Paragraph("Date: " + new java.util.Date().toString(), normalFont));
            document.add(new Chunk(new com.itextpdf.text.pdf.draw.LineSeparator()));
            document.add(new Paragraph("\n"));

            // Information Table (Shop vs Customer)
            PdfPTable infoTable = new PdfPTable(2);
            infoTable.setWidthPercentage(100);
            
            // Shop Side
            PdfPCell shopCell = new PdfPCell();
            shopCell.setBorder(Rectangle.NO_BORDER);
            shopCell.addElement(new Paragraph("FROM:", boldFont));
            shopCell.addElement(new Paragraph(rs.getString("shop_name"), normalFont));
            shopCell.addElement(new Paragraph(rs.getString("shop_address"), normalFont));
            shopCell.addElement(new Paragraph("Phone: " + rs.getString("shop_phone"), normalFont));
            
            // Customer Side
            PdfPCell customerCell = new PdfPCell();
            customerCell.setBorder(Rectangle.NO_BORDER);
            customerCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
            customerCell.addElement(new Paragraph("BILL TO:", boldFont));
            customerCell.addElement(new Paragraph(rs.getString("customer_name"), normalFont));
            customerCell.addElement(new Paragraph(rs.getString("customer_address"), normalFont));
            customerCell.addElement(new Paragraph("Phone: " + rs.getString("customer_phone"), normalFont));

            infoTable.addCell(shopCell);
            infoTable.addCell(customerCell);
            document.add(infoTable);
            document.add(new Paragraph("\n\n"));

            // Items Table
            PdfPTable table = new PdfPTable(5);
            table.setWidthPercentage(100);
            table.setWidths(new float[] {1f, 4f, 1.5f, 2f, 2f});

            // Table Header Styling
            String[] headers = {"#", "Item Description", "Qty", "Unit Price", "Total"};
            for (String h : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(h, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, BaseColor.WHITE)));
                cell.setBackgroundColor(themeColor);
                cell.setPadding(8f);
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(cell);
            }

            // Fetch order items
            ps = con.prepareStatement(
                "SELECT oi.*, si.item_name FROM order_items oi " +
                "LEFT JOIN shop_items si ON oi.item_id=si.item_id " +
                "WHERE oi.order_id=?"
            );
            ps.setInt(1, orderId);
            ResultSet rsItems = ps.executeQuery();

            int sno = 1;
            while (rsItems.next()) {
                int qty = rsItems.getInt("quantity");
                double price = rsItems.getDouble("price");
                double rowTotal = qty * price;

                // S.No
                PdfPCell c1 = new PdfPCell(new Phrase(String.valueOf(sno++), normalFont));
                c1.setHorizontalAlignment(Element.ALIGN_CENTER);
                c1.setPadding(5f);
                table.addCell(c1);

                // Name
                PdfPCell c2 = new PdfPCell(new Phrase(rsItems.getString("item_name"), normalFont));
                c2.setPadding(5f);
                table.addCell(c2);

                // Qty
                PdfPCell c3 = new PdfPCell(new Phrase(String.valueOf(qty), normalFont));
                c3.setHorizontalAlignment(Element.ALIGN_CENTER);
                table.addCell(c3);

                // Price
                PdfPCell c4 = new PdfPCell(new Phrase("INR " + String.format("%.2f", price), normalFont));
                c4.setHorizontalAlignment(Element.ALIGN_RIGHT);
                table.addCell(c4);

                // Total
                PdfPCell c5 = new PdfPCell(new Phrase("INR " + String.format("%.2f", rowTotal), normalFont));
                c5.setHorizontalAlignment(Element.ALIGN_RIGHT);
                table.addCell(c5);
            }

            // Grand Total Row
            PdfPCell totalLabel = new PdfPCell(new Phrase("GRAND TOTAL", boldFont));
            totalLabel.setColspan(4);
            totalLabel.setPadding(8f);
            totalLabel.setHorizontalAlignment(Element.ALIGN_RIGHT);
            totalLabel.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(totalLabel);

            PdfPCell totalVal = new PdfPCell(new Phrase("INR " + String.format("%.2f", rs.getDouble("total_amount")), boldFont));
            totalVal.setHorizontalAlignment(Element.ALIGN_RIGHT);
            totalVal.setPadding(8f);
            totalVal.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(totalVal);

            document.add(table);
            
            // Footer
            document.add(new Paragraph("\n\n"));
            Paragraph footer = new Paragraph("This is a computer generated document. No signature required.", 
                                            FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 9, BaseColor.GRAY));
            footer.setAlignment(Element.ALIGN_CENTER);
            document.add(footer);

            document.close();

        } catch (Exception e) {
            e.printStackTrace();
            if(!response.isCommitted()) response.sendRedirect("myOrders.jsp?msg=error");
        } finally {
            try { if(rs != null) rs.close(); } catch(Exception e){}
            try { if(ps != null) ps.close(); } catch(Exception e){}
            try { if(con != null) con.close(); } catch(Exception e){}
        }
    }
}