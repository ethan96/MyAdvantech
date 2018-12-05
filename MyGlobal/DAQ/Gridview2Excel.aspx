<%@ Page Language="VB" EnableEventValidation="false" %>

<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Microsoft.Office.Interop.Excel" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Protected Function getFullCategoryPath(ByVal cid As String) As String
        Dim full_category_path As String = "", parentid As String = cid
        Do
            Dim sql As String = "SELECT CATEGORY, CATEGORYID, PARENTID FROM DAQ_func_categories WHERE CATEGORYID = '" + parentid + "'"
            Dim dt As System.Data.DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
            If dt.Rows.Count > 0 Then
                full_category_path = dt.Rows(0)("category").ToString.Trim + "/" + full_category_path
                parentid = dt.Rows(0)("parentid").ToString.Trim
            End If
        Loop While parentid <> "0"
        Return full_category_path
    End Function
    Protected Function get_spec_class(ByVal proid As String) As String
        Dim dt2 As System.Data.DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT  spec_classes FROM  daq_product_spec WHERE productid = '" + proid + "'")
        Dim returnvalue As String = ""
        Dim p() As String = {}
        If dt2.Rows.Count > 0 Then
            p = Split(dt2.Rows(0)("spec_classes").ToString.Trim, "|")
            For J As Integer = 0 To p.Length - 1
                returnvalue = returnvalue + p(J) + "<br>"
            Next
        End If
        Return returnvalue
    End Function
    Protected Function get_AI(ByVal proid As String, ByVal classid As String) As String
        Dim returnvalue As String = ""
        Dim sql As String = "SELECT  c.*, (select OPTION_NAME from daq_spec_options where OPTIONID =c.OPTIONID) as OPTIONID_name," & _
                            "(select OPTION_TYPE from daq_spec_options where OPTIONID =c.OPTIONID) as OPTIONID_type " & _
                            " FROM  DAQ_product_spec_values as c WHERE c.productid = '" + proid + "' and c.OPTIONID in ( select OPTIONID  from DAQ_spec_options  " & _
                            " where  classid = '" + classid + "' AND ENABLE =  'y' )"
        Dim dt As System.Data.DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                returnvalue += get_option_value(dt.Rows(i)("OPTIONID_name").ToString(), dt.Rows(i)("option_values").ToString(), dt.Rows(i)("OPTIONID_type").ToString()) + (ChrW(10)).ToString()
            Next
        End If
       
       
        Return returnvalue
    End Function
    
    Protected Function get_option_value(ByRef pp As String, ByVal option_valuesid As String, ByVal OPTIONID_type As String) As String
        Dim returnvalue As String = ""
        If OPTIONID_type = "m" Then
            Dim p() As String = {}
            p = Split(option_valuesid.ToString.Trim, "|")
               returnvalue = pp + ":"
            For i As Integer = 0 To p.Length - 1
                Dim sql As String = "SELECT  OPTION_VALUE  FROM DAQ_spec_options_values WHERE OPTION_valueid =  '" + p(i) + "' AND  option_value <> '-' ORDER BY ORDER_BY ASc"
             
                Dim values As Object = Nothing
                values = dbUtil.dbExecuteScalar("MYLOCAL", sql)
                If values IsNot Nothing Then
                    returnvalue = returnvalue + values + ";"
                End If
             
            Next
            
        Else
            Dim sql As String = "SELECT  OPTION_VALUE  FROM DAQ_spec_options_values WHERE OPTION_valueid =  '" + option_valuesid + "' AND  option_value <> '-' ORDER BY ORDER_BY ASc"
            Dim values As Object = Nothing
            values = dbUtil.dbExecuteScalar("MYLOCAL", sql)
            If values IsNot Nothing Then
                returnvalue = pp + ":" + values
            End If
        
        End If
        'returnvalue = Replace(returnvalue, "±", "<>")
        Return returnvalue
    End Function
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
               
            
            '   GV1.DataSource = getdt()
            '     GV1.DataBind()
         
        End If
    End Sub
    'Public Overrides Sub VerifyRenderingInServerForm(ByVal control As Control)
    'End Sub
    Public Function getdt() As System.Data.DataTable
        Dim sql As String = "SELECT   a.PRODUCTID, a.SKU, a.PRODUCTNAME, a.DESCRIPTION,c.CATEGORYID, a.ENABLE , '' as category ,'' as spec" & _
                ",'' as AI,''as AO,'' as DI,'' as DO,''as Counter,'' as Support_Software,'' as Comm_Protocol ,'' AS Bus" & _
                                       " FROM DAQ_products  as a Inner Join DAQ_products_categories as b ON a.PRODUCTID = b.PRODUCTID  " & _
                                       "  Inner Join DAQ_func_categories as c ON b.CATEGORYID = c.CATEGORYID  WHERE " & _
                                       " b.MAIN =  '0' 	ORDER BY   a.PRODUCTID ASC ,b.CATEGORYID ASC"
        Dim dt As System.Data.DataTable = dbUtil.dbGetDataTable("MYLOCAL", sql)
        
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                dt.Rows(i).Item("category") = getFullCategoryPath(dt.Rows(i).Item("categoryid").ToString.Trim)
                dt.Rows(i).Item("spec") = get_spec_class(dt.Rows(i).Item("PRODUCTID").ToString.Trim)
                
                dt.Rows(i).Item("AI") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "1")
                dt.Rows(i).Item("AO") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "2")
                dt.Rows(i).Item("DI") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "3")
                dt.Rows(i).Item("DO") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "4")
                dt.Rows(i).Item("Counter") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "5")
                dt.Rows(i).Item("Support_Software") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "6")
                dt.Rows(i).Item("Comm_Protocol") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "7")
                dt.Rows(i).Item("Bus") = get_AI(dt.Rows(i).Item("PRODUCTID").ToString.Trim, "8")
            Next
            dt.Columns.Remove(dt.Columns(7))
            dt.AcceptChanges()
            For i As Integer = 0 To dt.Rows.Count - 1
                For J As Integer = 0 To dt.Columns.Count - 1
                    If IsDBNull(dt.Rows(i).Item(J)) Then
                        dt.Rows(i).Item(J) = ""
                    End If
                Next
                
            Next
            
            dt.AcceptChanges()
        
        End If
        Return dt
    End Function
    Protected Sub excel_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        
        Dim ExcelApp As New ApplicationClass()
        If ExcelApp Is Nothing Then
            '  SunValley.BarCode.Com.MsgBox.PromptInfo("请确定是否安装了Excel");
            Exit Sub
        End If
        ExcelApp.Visible = True
        Dim wb As Workbook = ExcelApp.Workbooks.Add(True)
        Dim ws As Worksheet = DirectCast(wb.ActiveSheet, Worksheet)
        ws.Name = "Products List"
        Dim dt As System.Data.DataTable = getdt()
        Dim count As Integer = 1
        For i As Integer = 0 To dt.Columns.Count - 1       
            ws.Cells(1, count) = dt.Columns(i).ColumnName.ToString
            count += 1
        Next
        
        count = 2
        For i As Integer = 0 To dt.Rows.Count - 1
            
            For j As Integer = 1 To dt.Columns.Count
                ws.Cells(count, j) = dt.Rows(i)(j - 1).ToString()
            Next          
            count += 1
        Next
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("H" & ":" & "L").ToString()}), Microsoft.Office.Interop.Excel.Range).ColumnWidth = 60
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("M" & ":" & "P").ToString()}), Microsoft.Office.Interop.Excel.Range).ColumnWidth = 20
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("B" & ":" & "B").ToString()}), Microsoft.Office.Interop.Excel.Range).ColumnWidth = 20
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("G" & ":" & "G").ToString()}), Microsoft.Office.Interop.Excel.Range).ColumnWidth = 50
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("H" & ":" & "L").ToString()}), Microsoft.Office.Interop.Excel.Range).WrapText = True
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("M" & ":" & "P").ToString()}), Microsoft.Office.Interop.Excel.Range).WrapText = True
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("B" & ":" & "B").ToString()}), Microsoft.Office.Interop.Excel.Range).WrapText = True
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("G" & ":" & "G").ToString()}), Microsoft.Office.Interop.Excel.Range).WrapText = True
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("H" & ":" & "L").ToString()}), Microsoft.Office.Interop.Excel.Range).HorizontalAlignment = Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignLeft
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("M" & ":" & "P").ToString()}), Microsoft.Office.Interop.Excel.Range).HorizontalAlignment = Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignLeft
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("B" & ":" & "B").ToString()}), Microsoft.Office.Interop.Excel.Range).HorizontalAlignment = Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignLeft
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("G" & ":" & "G").ToString()}), Microsoft.Office.Interop.Excel.Range).HorizontalAlignment = Microsoft.Office.Interop.Excel.XlHAlign.xlHAlignLeft
        'System.Drawing.Color.Blue
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("H" & ":" & "H").ToString()}), Microsoft.Office.Interop.Excel.Range).Interior.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.LightSkyBlue)
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("J" & ":" & "J").ToString()}), Microsoft.Office.Interop.Excel.Range).Interior.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.LightSkyBlue)
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("L" & ":" & "L").ToString()}), Microsoft.Office.Interop.Excel.Range).Interior.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.LightSkyBlue)
        DirectCast(ws.Columns.[GetType]().InvokeMember("Item", System.Reflection.BindingFlags.GetProperty, Nothing, ws.Columns, New Object() {("N" & ":" & "N").ToString()}), Microsoft.Office.Interop.Excel.Range).Interior.Color = System.Drawing.ColorTranslator.ToOle(System.Drawing.Color.LightSkyBlue)     
        ws.Range(ws.Cells(1, 1), ws.Cells(1, 15)).Font.Bold = True              
        Dim path As String = Server.MapPath("/") & "daq\download\" + System.DateTime.Now.ToString("yyyyMMddhhmmss") + ".xls"
        wb.SaveAs(path)
        mDispose(ws, wb, ExcelApp)
        If File.Exists(path) Then
            Response.Clear()
            Response.ContentType = "application/octet-stream"
            Response.AddHeader("Content-Disposition", "attachment; filename=" + DateTime.Now.Ticks.ToString() & ".xls")
            Response.Flush()
            Response.WriteFile(path)
            Response.End()
        End If
    End Sub
    Public Sub mDispose(ByVal CurSheet As Microsoft.Office.Interop.Excel._Worksheet, ByVal CurBook As Microsoft.Office.Interop.Excel._Workbook, ByVal CurExcel As Microsoft.Office.Interop.Excel._Application)
        Try
            System.Runtime.InteropServices.Marshal.ReleaseComObject(CurSheet)
            CurSheet = Nothing
            CurBook.Close(False, System.Reflection.Missing.Value, System.Reflection.Missing.Value)
            System.Runtime.InteropServices.Marshal.ReleaseComObject(CurBook)
            CurBook = Nothing

            CurExcel.Quit()
            System.Runtime.InteropServices.Marshal.ReleaseComObject(CurExcel)
            CurExcel = Nothing

            GC.Collect()
            GC.WaitForPendingFinalizers()
        Catch ex As System.Exception
            Throw New Exception(ex.Message)
        Finally
            For Each pro As System.Diagnostics.Process In System.Diagnostics.Process.GetProcessesByName("Excel")
                'if (pro.StartTime < DateTime.Now)
                pro.Kill()
            Next
        End Try
        System.GC.SuppressFinalize(Me)

    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
  <asp:ImageButton runat="server" AlternateText="Export Excel" id="excel" 
        ImageUrl="~/Images/excel.gif" OnClick="excel_Click" ImageAlign="Left"  />
    <asp:GridView runat="server" ID="GV1" AutoGenerateColumns="false">
    <Columns>
    <asp:BoundField HeaderText="PRODUCTID" DataField="PRODUCTID" />
     <asp:BoundField HeaderText="SKU" DataField="SKU" />
      <asp:BoundField HeaderText="PRODUCTNAME" DataField="PRODUCTNAME" />
       <asp:BoundField HeaderText="DESCRIPTION" DataField="DESCRIPTION" />
        <asp:BoundField HeaderText="category" DataField="category" />
      
     <asp:TemplateField HeaderText="AI">
         <ItemTemplate >
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("AI") %>'></asp:Label>
         </ItemTemplate>  
         <ItemStyle  Width="200px"/>       
     </asp:TemplateField>
      <asp:TemplateField HeaderText="AO">
         <ItemTemplate>
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("AO") %>'></asp:Label>
         </ItemTemplate>         
     </asp:TemplateField>
      <asp:TemplateField HeaderText="DI">
         <ItemTemplate>
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("DI") %>'></asp:Label>
         </ItemTemplate>         
     </asp:TemplateField>
      <asp:TemplateField HeaderText="DO">
         <ItemTemplate>
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("DO") %>'></asp:Label>
         </ItemTemplate>         
     </asp:TemplateField >
      <asp:TemplateField HeaderText="Counter">
         <ItemTemplate>
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("Counter") %>'></asp:Label>
         </ItemTemplate>         
     </asp:TemplateField>
      <asp:TemplateField  HeaderText="Support Software">
         <ItemTemplate>
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("Support_Software") %>'></asp:Label>
         </ItemTemplate>         
     </asp:TemplateField>
       <asp:TemplateField  HeaderText="Comm Protocol">
         <ItemTemplate>
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("Comm_Protocol") %>'></asp:Label>
         </ItemTemplate>         
     </asp:TemplateField>
       <asp:TemplateField HeaderText="Bus">
         <ItemTemplate>
             <asp:Label ID="Label1" runat="server" Text='<%# Eval("Bus") %>'></asp:Label>
         </ItemTemplate>         
     </asp:TemplateField>
    </Columns>
    </asp:GridView>
    </form>
</body>
</html>
