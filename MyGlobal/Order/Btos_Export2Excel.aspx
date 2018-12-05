<%@ Page Language="VB" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim tb As System.Data.DataTable = Me.GetTable()
        If Not IsNothing(tb) AndAlso tb.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(tb, "Config_info.xls")
        End If
    End Sub
    
    Function GetTable() As System.Data.DataTable
        Dim table As New System.Data.DataTable
        Dim QTY As Integer = 0
        Dim list_price As Decimal = 0.0
        Dim unit_price As Decimal = 0.0
        Dim disc As String = ""
        Dim total As Decimal = 0
      
        table.Columns.Add("No", GetType(System.String))
        table.Columns.Add("Model No.", GetType(System.String))
        table.Columns.Add("Part No.", GetType(System.String))
        table.Columns.Add("Description", GetType(System.String))
        table.Columns.Add("Due Date", GetType(System.String))
        table.Columns.Add("Inventory", GetType(System.String))
        table.Columns.Add("List Price", GetType(System.String))
        table.Columns.Add("Disc.", GetType(System.String))
        table.Columns.Add("Unit Price", GetType(System.String))
        table.Columns.Add("QTY", GetType(System.String))
        table.Columns.Add("Sub Total", GetType(System.String))
        Dim dr As DataRow = table.NewRow()
        
        Dim TB As String = "CONFIGURATION_CATALOG_CATEGORY"
        Dim strSql = "select category_id, category_qty from " & tb & " where catalog_id='" & Session("g_CATALOG_ID") & "' and category_type='component' and parent_category_id='root'"
        
        Dim dtRoot As System.Data.DataTable = dbUtil.dbGetDataTable("B2B", strSql)
        If dtRoot.Rows.Count > 0 Then
            dr.Item("No") = "100"
            dr.Item("Model No.") = ""
            dr.Item("Part No.") = dtRoot.Rows(0).Item("category_id")
            dr.Item("Description") = Me.GetDescription(dtRoot.Rows(0).Item("category_id"))
            dr.Item("Due Date") = Now.Date.ToString
            dr.Item("Inventory") = "0"
            dr.Item("List Price") = "0"
            dr.Item("Disc.") = "0%"
            dr.Item("Unit Price") = "0"
            dr.Item("QTY") = dtRoot.Rows(0).Item("category_qty")
            dr.Item("Sub Total") = "0"
        End If
        table.Rows.Add(dr)
        Dim dtComponent As System.Data.DataTable = dbUtil.dbGetDataTable("B2B", "select category_id, category_qty from " & TB & " where catalog_id='" & Session("g_CATALOG_ID") & "' and category_type='component' and parent_category_id<>'root'")
        Dim maxDueDate As String = ""
           
       
        Dim partStr As String = ""
        For Each r As DataRow In dtComponent.Rows
            partStr &= r.Item("category_id") & "|"
        Next
        Dim dtPrice_new As New System.Data.DataTable
        SAPtools.getSAPPriceByTable(partStr, 1, Session("org_id"), Session("company_id"), "", dtPrice_new)
        
        If dtComponent.Rows.Count > 0 Then
            For i As Integer = 101 To dtComponent.Rows.Count + 100
                dr = table.NewRow()
                dr.Item("No") = i.ToString()
                dr.Item("Model No.") = Me.GetModule(dtComponent.Rows(i - 101).Item("category_id"))
                dr.Item("Part No.") = dtComponent.Rows(i - 101).Item("category_id")
                dr.Item("Description") = Me.GetDescription(dtComponent.Rows(i - 101).Item("category_id"))
               
                If dtComponent.Rows(i - 101).Item("category_id").ToString.ToUpper.StartsWith("AGS-EW-") Then
                    Dim dtnew As System.Data.DataTable = dbUtil.dbGetDataTable("B2B", "select category_price from " & TB & " where catalog_id='" & Session("g_CATALOG_ID") & "' and category_type='component' and parent_category_id<>'root' and category_id='" & dtComponent.Rows(i - 101).Item("category_id").ToString.Trim & "'")
                    If dtnew.Rows.Count > 0 Then
                        list_price = Convert.ToDecimal(dtnew.Rows(0).Item("category_price"))
                        unit_price = Convert.ToDecimal(dtnew.Rows(0).Item("category_price"))
                    End If
                Else
                    If (i - 101) >= 0 And (i - 101) < dtComponent.Rows.Count Then
                        If dtPrice_new.Columns.Contains("Matnr") Then
                            Dim dr_news As System.Data.DataRow() = dtPrice_new.Select("Matnr='" + dtComponent.Rows(i - 101).Item("category_id") + "'")
                            If dr_news IsNot Nothing AndAlso dr_news.Length > 0 Then
                                Dim dr_new As DataRow = dr_news(0)
                                list_price = Convert.ToDecimal(dr_new("Kzwi1").ToString.Trim)
                                unit_price = Convert.ToDecimal(dr_new("Netwr").ToString.Trim)
                            End If
                        End If
                    End If
                End If
                
                
                Dim due_date As String = ""
                Dim inventory As Integer = 0
                
                SAPtools.getInventoryAndATPTable(dtComponent.Rows(i - 101).Item("category_id"), OrderUtilities.getPlant(), dtComponent.Rows(i - 101).Item("category_qty"), due_date, inventory)
                
                If due_date > maxDueDate Then
                    maxDueDate = due_date
                End If
               
                If list_price > 0 Then
                    disc = CDbl((1.0 - CDbl(unit_price / list_price)) * 100.0).ToString() & "%"
                Else
                    disc = "0%"
                End If
                ''''''''

                total = CInt(dtComponent.Rows(i - 101).Item("category_qty")) * unit_price
                dr.Item("List Price") = list_price.ToString("#,##0.00")
                dr.Item("Disc.") = disc
                dr.Item("Due Date") = due_date
                dr.Item("Unit Price") = unit_price.ToString("#,##0.00")
                dr.Item("Sub Total") = total.ToString("#,##0.00")
                dr.Item("QTY") = dtComponent.Rows(i - 101).Item("category_qty")
                dr.Item("Inventory") = inventory
                table.Rows.Add(dr)
            Next
            table.Rows(0).Item("due date") = maxDueDate
        End If
        Return table
    End Function
    
    Function GetModule(ByVal part_no As String) As String
        Dim strSql = "select isnull(Model_No,'') as model_no from sap_product where Part_No = '" & part_no & "'"
        Dim dt As System.Data.DataTable = dbUtil.dbGetDataTable("B2B", strSql)
        If dt.Rows.Count = 0 Then
            GetModule = part_no.ToUpper()
        Else
            If dt.Rows(0).Item("Model_No") = "" Then
                GetModule = ""
            ElseIf Left(UCase(dt.Rows(0).Item("Model_No").ToString()), 2) <> Left(UCase(part_no), 2) Then
                GetModule = ""
            Else
                'GetModule = "<a target=""_blank"" href=""http://partner.advantech.com.tw/Search_Product.asp?TxtSearch=" & part_no & """>" & dt.Rows(0).Item("Model_No").ToString().ToUpper() & "</a>"
                GetModule = dt.Rows(0).Item("Model_No").ToString().ToUpper()
            End If
        End If
       
    End Function
    
    Function GetDescription(ByVal part_no As String) As String
        Dim strSql = "select product_desc,status from sap_product where part_no  = '" & part_no & "'"
        
        If dbUtil.dbGetDataTable("B2B", strSql).Rows.Count > 0 Then
            Return dbUtil.dbGetDataTable("B2B", strSql).Rows(0).Item("product_desc").ToString()
        Else
            Return ""
        End If
    End Function
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
<script type="text/javascript">
//self.close()
//window.close()
</script>