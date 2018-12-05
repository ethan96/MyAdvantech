<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        'Dim ws As New MYSAPDAL, errorMsg As String = ""
        ''Dim _result As List(Of MYSAPDAL.PNDetail) = ws.GetProductCost("AIMB-212D-S6A1E", "ATH", errorMsg)
        'Dim _result As List(Of MYSAPDAL.PNDetail) = ws.GetProductCost("AIMB-212D-S6A1E", "", errorMsg)
        'Me.gv1.DataSource = _result
        'Me.gv1.DataBind()
        
        'Dim a As String = Trim(Request("a"))
        
        Dim sql As New StringBuilder
        
        sql.AppendLine(" select a.quoteNo, a.Revision_Number, a.quoteToErpId as SoldToCompany, a.quoteToName, a.siebelRBU, a.quoteToRowId as account_row_id, b.partNo, a.quoteId, a.quoteDate, sum(b.qty) as quote_qty, ")
        sql.AppendLine(" IsNull(( ")
        sql.AppendLine(" select sum(z2.ORDER_QTY)  ")
        sql.AppendLine(" from eQuotation.dbo.QUOTE_TO_ORDER_LOG z1 inner join MyAdvantechGlobal.dbo.SAP_ORDER_HISTORY z2 on z1.SO_NO=z2.SO_NO  ")
        sql.AppendLine(" where z1.QUOTEID=a.quoteId and b.partNo=z2.PART_NO ")
        sql.AppendLine(" ),0) as order_qty, (case when e.SO_NO is null then 0 else 1 end ) as FlippedOrders ")
        sql.AppendLine(" from eQuotation.dbo.QuotationMaster a inner join eQuotation.dbo.QuotationDetail b on a.quoteId=b.quoteId inner join SAP_PRODUCT c on b.partNo=c.PART_NO  ")
        sql.AppendLine(" left join eQuotation.dbo.QUOTE_TO_ORDER_LOG e on a.quoteId=e.QUOTEID ")
        sql.AppendLine(" where a.createdDate>='2014-01-01' and a.createdDate<='2014-06-06' and c.MODEL_NO<>'' and c.MATERIAL_GROUP in ('PRODUCT','BTOS') ")
        sql.AppendLine(" and (a.quoteNo like 'AUSQ%' or a.quoteNo like 'AMXQ%') ")
        sql.AppendLine(" group by a.quoteNo, a.Revision_Number,a.siebelRBU, a.quoteToErpId, a.quoteToName, a.quoteToRowId, b.partNo, a.quoteId, a.quoteDate,e.SO_NO ")
        sql.AppendLine(" order by a.quoteDate ")
        'sql.AppendLine("  ")
        'sql.AppendLine("  ")
        'sql.AppendLine("  ")
        'sql.AppendLine("  ")
        
        Dim _dt As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString)
        
        DataTable2PivotExcelDownload(_dt, "partNo|SoldToCompany", "", "quote_qty|quoteNo|order_qty|FlippedOrders", "test.xls")
        
    End Sub
    
    
    Public Shared Sub DataTable2PivotExcelDownload( _
ByVal dt As DataTable, ByVal RowFields As String, ByVal ColumnFields As String, _
ByVal DataFields As String, ByVal FileName As String)
        Util.SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        For i As Integer = 0 To dt.Columns.Count - 1
            wb.Worksheets(1).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
        Next
        For i As Integer = 0 To dt.Rows.Count - 1
            For j As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(1).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j))
            Next
        Next
        Dim pivotTables As Aspose.Cells.PivotTables = wb.Worksheets(0).PivotTables
        Dim index As Integer = pivotTables.Add("=Sheet2!A1:" + Util.GetAlphabetBySeq(dt.Columns.Count - 1) + (dt.Rows.Count + 1).ToString(), "A1", "Sheet1")
        Dim pivotTable As Aspose.Cells.PivotTable = pivotTables(index)
        With pivotTable
            Dim RowFieldsSet() As String = Split(RowFields, "|"), ColFieldsSet() As String = Split(ColumnFields, "|"), DataFieldsSet() As String = Split(DataFields, "|")
            For Each f As String In RowFieldsSet
                If String.IsNullOrEmpty(f) Then Continue For
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Row, f)
            Next
            For Each f As String In ColFieldsSet

                .AddFieldToArea(Aspose.Cells.PivotFieldType.Data, "data")

                If String.IsNullOrEmpty(f) Then Continue For

                .AddFieldToArea(Aspose.Cells.PivotFieldType.Column, f)

                'Dim _fy As Aspose.Cells.PivotField
                '_fy.
                ''.AddFieldToArea(Aspose.Cells.PivotFieldType.Column, f)
            Next
            For Each f As String In DataFieldsSet
                If String.IsNullOrEmpty(f) Then Continue For
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Data, f)
            Next
            For i As Integer = 0 To .RowFields.Count - 1
                Dim d = 1

                '.RowFields(i).AutoSortField = True
                '.RowFields(i).IsAscendSort = True
            Next
            For i As Integer = 0 To .ColumnFields.Count - 1
                '.ColumnFields(i).AutoSortField = True
                .ColumnFields(i).IsAscendSort = True
            Next
            '.ColumnFields.
        End With
        'pivotTable.Move()
        'pivotTable.RowFields(2).Drag = True
        'pivotTable.ColumnGrand = False
        'pivotTable.RowGrand = False
        'pivotTable.DataFields(3).Function = Aspose.Cells.ConsolidationFunction.CountNums
        pivotTable.ColumnFields.Add(pivotTable.DataField)


        With HttpContext.Current.Response
            If FileName.StartsWith("AEUIT") = False Then FileName = "AEUIT_" + FileName
            .Clear()
            .ContentType = "application/vnd.ms-excel"
            .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", FileName))
            Try
                .BinaryWrite(wb.SaveToStream().ToArray)
            Catch ex As Exception
                .End()
            End Try
        End With
        'End If
    End Sub
    
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:GridView ID="gv1" runat="server">
        </asp:GridView>
    </div>
    </form>
</body>
</html>
