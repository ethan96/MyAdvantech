<%@ Page Title="eQuotation - Quote to Order Popular Part Number Analysis" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" EnableEventValidation="false" AutoEventWireup="true" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            txtQFrom.Text = DateAdd(DateInterval.Month, -3, Now).ToShortDateString()
            txtQTo.Text = Now.ToShortDateString()
        End If
    End Sub

    Protected Sub gvMainQuoteReport_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim gvRowPNQuoteInfo As GridView = e.Row.FindControl("gvPNQuoteInfo")
            Dim RowPn As String = CType(e.Row.FindControl("hdRowPn"), HiddenField).Value
            Dim listEq As List(Of QuoteList) = ViewState("Quote Main List")
            Dim ListQuote2Order As List(Of Quote2Order) = ViewState("Quote To Order")
            Dim FilterLisEqByPN = From q In listEq Where q.partNo = RowPn

            Dim query = FilterLisEqByPN.GroupBy(Function(g) New With {Key .quoteToErpId = g.quoteToErpId}).Select( _
                Function(group) New With {.quoteToErpId = group.Key.quoteToErpId,
                                          .QuoteQty = group.Sum(Function(c) c.qty),
                                          .NumOfQuote = group.Select(Function(value) value.quoteId).Distinct().Count(),
                                          .ConvertedQty = (From sq In ListQuote2Order
                                                           Where sq.COMPANY_ID = group.Key.quoteToErpId And sq.PART_NO = RowPn).
                                                       Sum(Function(v) v.ORDER_QTY),
                                          .NumOfOrder = (From sq In ListQuote2Order
                                                         Where sq.COMPANY_ID = group.Key.quoteToErpId And sq.PART_NO = RowPn).
                                                       Select(Function(v) v.QUOTEID).Distinct().Count()})



            gvRowPNQuoteInfo.DataSource = query
            gvRowPNQuoteInfo.DataBind()

            Dim ExcelDT As DataTable = New DataTable()
            If Session("ExcelDT") IsNot Nothing Then
                ExcelDT = CType(Session("ExcelDT"), DataTable)
            Else
                ExcelDT.Columns.Add("PartNo")
                ExcelDT.Columns.Add("Sold-To Company")
                ExcelDT.Columns.Add("Quoted quantity", GetType(Integer))
                ExcelDT.Columns.Add("# of quotation", GetType(Integer))
                ExcelDT.Columns.Add("Converted quantity", GetType(Integer))
                ExcelDT.Columns.Add("# of flipped orders", GetType(Integer))
            End If

            If query.Count > 0 Then
                Dim n As Integer = 0, _QuoteQty As Integer = 0, _NumOfQuote As Integer = 0, _ConvertedQty As Integer = 0, _NumOfOrder As Integer = 0
                For Each i In query
                    Dim dr As DataRow = ExcelDT.NewRow()
                    If n = 0 Then
                        dr.Item("PartNo") = RowPn
                    Else
                        dr.Item("PartNo") = ""
                    End If
                    dr.Item("Sold-To Company") = i.quoteToErpId
                    dr.Item("Quoted quantity") = i.QuoteQty : _QuoteQty += i.QuoteQty
                    dr.Item("# of quotation") = i.NumOfQuote : _NumOfQuote += i.NumOfQuote
                    dr.Item("Converted quantity") = i.ConvertedQty : _ConvertedQty += i.ConvertedQty
                    dr.Item("# of flipped orders") = i.NumOfOrder : _NumOfOrder += i.NumOfOrder
                    ExcelDT.Rows.Add(dr)
                    n = n + 1
                Next
                Dim drSubtotal As DataRow = ExcelDT.NewRow()
                drSubtotal.Item("PartNo") = ""
                drSubtotal.Item("Sold-To Company") = "Subtotal"
                drSubtotal.Item("Quoted quantity") = _QuoteQty
                drSubtotal.Item("# of quotation") = _NumOfQuote
                drSubtotal.Item("Converted quantity") = _ConvertedQty
                drSubtotal.Item("# of flipped orders") = _NumOfOrder
                ExcelDT.Rows.Add(drSubtotal)
                ExcelDT.AcceptChanges()
                Session("ExcelDT") = ExcelDT

                'gvtest.DataSource = CType(Session("ExcelDT"), DataTable)
                'gvtest.DataBind()
            End If
        End If
    End Sub

    Public Sub GetData()
        Dim FromDate As Date = CDate(txtQFrom.Text), ToDate As Date = CDate(txtQTo.Text)
        Dim strPNPrefix As String = Replace(Replace(Trim(txtPNPrefix.Text), "'", "''"), "*", "") + "%"


        Dim sqlMain As String = _
             " select a.quoteId, a.quoteNo,  a.createdBy, a.salesEmail, a.createdDate, a.quoteToErpId, b.partNo,  " + _
             " b.qty, c.MODEL_NO, c.EGROUP, c.EDIVISION, c.PRODUCT_LINE, c.MATERIAL_GROUP  " + _
             " from eQuotation.dbo.QuotationMaster a inner join eQuotation.dbo.QuotationDetail b on a.quoteId=b.quoteId  " + _
             " inner join MyAdvantechGlobal.dbo.SAP_PRODUCT c on b.partNo=c.PART_NO   " + _
             " where a.createdDate>='" + FromDate.ToString("yyyy-MM-dd") + "' and a.createdDate<='" + ToDate.ToString("yyyy-MM-dd") + "' and (a.quoteNo like 'AUSQ%' or a.quoteNo like 'AMXQ%') " + _
             " and c.MATERIAL_GROUP in ('PRODUCT','BTOS','CTOS') and c.MODEL_NO<>'' and b.PartNo like '" + strPNPrefix + "' "
        Dim EqApt As New SqlClient.SqlDataAdapter(sqlMain, ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
        Dim dtEqList As New DataTable
        EqApt.Fill(dtEqList)

        Dim sqlQuote2Order As String = _
            " select a.QUOTEID, a.SO_NO, a.ORDER_DATE, a.ORDER_BY, b.COMPANY_ID, b.PART_NO, b.UNIT_PRICE, b.CURRENCY, b.US_AMT, b.ORDER_QTY  " + _
            " from eQuotation.dbo.QUOTE_TO_ORDER_LOG a inner join MyAdvantechGlobal.dbo.SAP_ORDER_HISTORY b on a.SO_NO=b.SO_NO  " + _
            " where a.QUOTEID in " + _
            " ( " + _
            " 	 " + _
            " 	select distinct a.quoteId " + _
            "     from eQuotation.dbo.QuotationMaster a inner join eQuotation.dbo.QuotationDetail b on a.quoteId=b.quoteId   " + _
            "     inner join MyAdvantechGlobal.dbo.SAP_PRODUCT c on b.partNo=c.PART_NO    " + _
            "     where a.createdDate>='" + FromDate.ToString("yyyy-MM-dd") + "' and a.createdDate<='" + ToDate.ToString("yyyy-MM-dd") + "' and (a.quoteNo like 'AUSQ%' or a.quoteNo like 'AMXQ%')  " + _
            "     and c.MATERIAL_GROUP in ('PRODUCT','BTOS','CTOS') and c.MODEL_NO<>'' and b.PartNo like '" + strPNPrefix + "' " + _
            " ) "

        EqApt = New SqlClient.SqlDataAdapter(sqlQuote2Order, ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
        Dim dtQuote2Order As New DataTable
        EqApt.Fill(dtQuote2Order)
        EqApt.SelectCommand.Connection.Close()


        Dim listEq As New List(Of QuoteList)
        For Each r As DataRow In dtEqList.Rows
            Dim QuoteList1 As New QuoteList()
            Dim props() As Reflection.PropertyInfo = QuoteList1.GetType().GetProperties()
            For Each p As Reflection.PropertyInfo In props
                If r.Item(p.Name) IsNot DBNull.Value Then
                    p.SetValue(QuoteList1, r.Item(p.Name), Nothing)
                End If
            Next
            listEq.Add(QuoteList1)
        Next

        Dim PNList = (From a In listEq Select a.partNo, a.MODEL_NO Order By partNo).Distinct().Take(100)
        ViewState("Quote Main List") = listEq


        Dim ListQuote2Order As New List(Of Quote2Order)
        For Each r As DataRow In dtQuote2Order.Rows
            Dim Quote2Order1 As New Quote2Order
            Dim props() As Reflection.PropertyInfo = Quote2Order1.GetType().GetProperties()
            For Each p As Reflection.PropertyInfo In props
                If r.Item(p.Name) IsNot DBNull.Value Then
                    p.SetValue(Quote2Order1, r.Item(p.Name), Nothing)
                End If
            Next
            ListQuote2Order.Add(Quote2Order1)
        Next
        ViewState("Quote To Order") = ListQuote2Order

        gvMainQuoteReport.DataSource = PNList
        gvMainQuoteReport.DataBind()
        'ExcelDT.Columns.Add("PartNo")
        'If PNList.Count > 1 Then
        '    For Each i In PNList
        '        Dim dr As DataRow = ExcelDT.NewRow()
        '        dr.Item("PartNo") = i.partNo
        '        ExcelDT.Rows.Add(dr)
        '    Next
        '    ExcelDT.AcceptChanges()
        'End If
        'gvtest.DataSource = ExcelDT
        'gvtest.DataBind()
        hdFromToDate.Value = FromDate.ToString("yyyyMMdd") + "-" + ToDate.ToString("yyyyMMdd")
        ScriptManager.RegisterStartupScript(up1, up1.GetType(), "calcSubTotal", "calcSubTotal();gridviewScroll();", True)
    End Sub

    Protected Sub btnRun_Click(sender As Object, e As System.EventArgs)
        lbMsg.Text = ""
        If String.IsNullOrEmpty(txtQFrom.Text) OrElse String.IsNullOrEmpty(txtQTo.Text) OrElse _
            Not Date.TryParse(txtQFrom.Text, Now) OrElse Not Date.TryParse(txtQTo.Text, Now) Then
            lbMsg.Text = "Date format is incorrect" : Exit Sub
        End If
        Try
            Session.Remove("ExcelDT")
            GetData()
        Catch ex As Exception
            lbMsg.Text = ex.ToString()
        End Try
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetQuoteDetail(pn As String, DateRange As String) As String
        Dim dates() As String = Split(DateRange, "-")
        Dim FromDate As Date = Date.ParseExact(dates(0), "yyyyMMdd", New System.Globalization.CultureInfo("en-US"))
        Dim ToDate As Date = Date.ParseExact(dates(1), "yyyyMMdd", New System.Globalization.CultureInfo("en-US"))
        'Return String.Format("pn:{0},drange:{1},now:{2}", pn, DateRange, Now.ToString("yyyyMMddHHmmss"))
        Dim sql As String = _
       " select a.quoteNo, a.Revision_Number, b.partNo, a.quoteId, a.quoteDate, sum(b.qty) as quote_qty,  " + _
        " IsNull(( " + _
        " 	select sum(z2.ORDER_QTY)  " + _
        " 	from eQuotation.dbo.QUOTE_TO_ORDER_LOG z1 inner join MyAdvantechGlobal.dbo.SAP_ORDER_HISTORY z2 on z1.SO_NO=z2.SO_NO  " + _
        " 	where z1.QUOTEID=a.quoteId and b.partNo=z2.PART_NO " + _
        " ),0) as order_qty " + _
        " from eQuotation.dbo.QuotationMaster a inner join eQuotation.dbo.QuotationDetail b on a.quoteId=b.quoteId " + _
        " where a.createdDate>='" + FromDate.ToString("yyyy-MM-dd") + "' and a.createdDate<='" + ToDate.ToString("yyyy-MM-dd") + "' " + _
        " and b.partNo='" + Replace(Trim(pn), "'", "''") + "' and (a.quoteNo like 'AUSQ%' or a.quoteNo like 'AMXQ%') " + _
        " group by a.quoteNo, a.Revision_Number, b.partNo, a.quoteId, a.quoteDate " + _
        " order by a.quoteDate "
        Dim aptEq As New SqlClient.SqlDataAdapter(sql, ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
        Dim dtQuote2Order As New DataTable
        aptEq.Fill(dtQuote2Order)
        aptEq.SelectCommand.Connection.Close()
        With dtQuote2Order.Columns
            .Remove("partNo") : .Remove("quoteId")
        End With

        Return Util.DataTableToJSON(dtQuote2Order)
    End Function

    Protected Sub gvMainQuoteReport_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)

    End Sub
    Public Overrides Sub VerifyRenderingInServerForm(control As Control)
        'base.VerifyRenderingInServerForm(control);
    End Sub
    Protected Sub ImageButton1_Click(sender As Object, e As ImageClickEventArgs)
        Dim FromDate As Date = CDate(txtQFrom.Text), ToDate As Date = CDate(txtQTo.Text)
        Dim sql As New StringBuilder

        sql.AppendLine(" select a.quoteNo as QuotationNumber, a.Revision_Number, a.quoteToErpId as SoldToCompany, a.quoteToName, a.siebelRBU, a.quoteToRowId as account_row_id, b.partNo, a.quoteId, a.quoteDate, sum(b.qty) as QuotedQuantity, ")
        sql.AppendLine(" IsNull(( ")
        sql.AppendLine(" select sum(z2.ORDER_QTY)  ")
        sql.AppendLine(" from eQuotation.dbo.QUOTE_TO_ORDER_LOG z1 inner join MyAdvantechGlobal.dbo.SAP_ORDER_HISTORY z2 on z1.SO_NO=z2.SO_NO  ")
        sql.AppendLine(" where z1.QUOTEID=a.quoteId and b.partNo=z2.PART_NO ")
        sql.AppendLine(" ),0) as OrderQuantity, (case when e.SO_NO is null then 0 else 1 end ) as FlippedOrders ")
        sql.AppendLine("  ,f.ABC_INDICATOR ")
        sql.AppendLine(" from eQuotation.dbo.QuotationMaster a inner join eQuotation.dbo.QuotationDetail b on a.quoteId=b.quoteId inner join SAP_PRODUCT c on b.partNo=c.PART_NO  ")
        sql.AppendLine(" left join eQuotation.dbo.QUOTE_TO_ORDER_LOG e on a.quoteId=e.QUOTEID ")
        'sql.AppendLine(" left join SAP_PRODUCT_ABC f on b.partNo=f.PART_NO and b.deliveryPlant=f.PLANT ")
        sql.AppendLine(" left join SAP_PRODUCT_ABC f on b.partNo=f.PART_NO ")
        sql.AppendLine(" where a.createdDate>='" + FromDate.ToString("yyyy-MM-dd") + "' and a.createdDate<='" + ToDate.ToString("yyyy-MM-dd") + "' and c.MODEL_NO<>'' and c.MATERIAL_GROUP in ('PRODUCT','BTOS') ")
        sql.AppendLine(" and (a.quoteNo like 'AUSQ%' or a.quoteNo like 'AMXQ%') ")
        sql.AppendLine(" and f.PLANT='USH1' ")
        sql.AppendLine(" group by a.quoteNo, a.Revision_Number,a.siebelRBU, a.quoteToErpId, a.quoteToName, a.quoteToRowId, b.partNo, a.quoteId, a.quoteDate,e.SO_NO,f.ABC_INDICATOR ")
        sql.AppendLine(" order by a.quoteDate ")


        Dim _dt As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString)

        DataTable2PivotExcelDownload(_dt, "partNo|ABC_INDICATOR|SoldToCompany", "", "QuotedQuantity|QuotationNumber|OrderQuantity|FlippedOrders", "test.xls")



        'If Session("ExcelDT") IsNot Nothing Then
        '    Dim dt As DataTable = CType(Session("ExcelDT"), DataTable)
        '    If dt.Rows.Count > 0 Then
        '        Util.DataTable2ExcelDownload(dt, "Quote_to_Order_Popular_Part_Number_Analysis.xls")
        '    End If
        'End If

        ' Dim dt As DataTable = CType(gvMainQuoteReport.DataSource, DataTable)
        'OrderUtilities.showDT(dt)
        'Response.ClearContent()
        'Response.AddHeader("content-disposition", "attachment; filename=MyExcelFile.xls")
        'Response.ContentType = "application/excel"
        'Dim sw As New System.IO.StringWriter()
        'Dim htw As New HtmlTextWriter(sw)
        'gvMainQuoteReport.RenderControl(htw)
        'Response.Write(sw.ToString())
        'Response.End()
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
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" href='<%=Util.GetRuntimeSiteUrl() %>/Includes/jquery-ui.css' />
    <link href='<%=Util.GetRuntimeSiteUrl() %>/Includes/GridViewScroll/GridviewScroll.css'
        rel="stylesheet" />
    <script type="text/javascript" src='<%=Util.GetRuntimeSiteUrl() %>/Includes/jquery-latest.min.js'></script>
    <script type="text/javascript" src='<%=Util.GetRuntimeSiteUrl() %>/Includes/jquery-ui.js'></script>
    <script type="text/javascript" src='<%=Util.GetRuntimeSiteUrl() %>/Includes/json2.js'></script>
    <script type="text/javascript" src='<%=Util.GetRuntimeSiteUrl() %>/Includes/SiteUtilV5.js'></script>
    <script type="text/javascript" src='<%=Util.GetRuntimeSiteUrl() %>/Includes/GridViewScroll/gridviewScroll.min.js'></script>
    <asp:Panel runat="server" ID="PanelQuery" DefaultButton="btnRun">
        <table width="100%">
            <tr>
                <td>
                    <table>
                        <tr>
                            <th align="left">
                                Quote Date:
                            </th>
                            <td>
                                <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" TargetControlID="txtQFrom" />
                                <asp:TextBox runat="server" ID="txtQFrom" />
                            </td>
                            <td>
                                ~
                            </td>
                            <td>
                                <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" TargetControlID="txtQTo" />
                                <asp:TextBox runat="server" ID="txtQTo" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table>
                        <tr>
                            <th align="left">
                                Part No. Prefix:
                            </th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="txtPNPrefix"
                                    MinimumPrefixLength="1" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetSAPPN" />
                                <asp:TextBox runat="server" ID="txtPNPrefix" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnRun" Text="Run" OnClick="btnRun_Click" UseSubmitBehavior="false"
                                    OnClientClick="this.disabled=true;" />
                                <script type="text/javascript">
                                    var prm = Sys.WebForms.PageRequestManager.getInstance();
                                    if (prm != null) {
                                        prm.add_endRequest(enableQueryButton);
                                    }

                                    function enableQueryButton() {
                                        document.getElementById('<%=btnRun.ClientId %>').disabled = false;
                                    }
                                </script>
                            </td>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Label runat="server" ID="lbMsg" ForeColor="Tomato" Font-Bold="true" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="btnRun" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </td>
                            <td>
                                <asp:ImageButton ID="ImageButton1" runat="server" ImageUrl="~/images/excel.gif" OnClick="ImageButton1_Click" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </asp:Panel>
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <%--   <asp:GridView ID="gvtest" runat="server"></asp:GridView>--%>
            <asp:HiddenField runat="server" ID="hdFromToDate" />
            <asp:GridView runat="server" ID="gvMainQuoteReport" Width="100%" AutoGenerateColumns="false"
                OnRowDataBound="gvMainQuoteReport_RowDataBound" AllowSorting="false" OnSorting="gvMainQuoteReport_Sorting">
                <Columns>
                    <asp:TemplateField HeaderText="Part No." ItemStyle-Width="30%" SortExpression="PartNo">
                        <ItemTemplate>
                            <%#Eval("PartNo")%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-Width="70%">
                        <HeaderTemplate>
                            <table width="100%">
                                <tr>
                                    <th style="width: 20%">
                                        Sold-To Company
                                    </th>
                                    <th style="width: 20%">
                                        Quoted quantity
                                    </th>
                                    <th style="width: 20%">
                                        # of quotation
                                    </th>
                                    <th style="width: 20%">
                                        Converted quantity
                                    </th>
                                    <th style="width: 20%">
                                        # of flipped orders
                                    </th>
                                </tr>
                            </table>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:HiddenField runat="server" ID="hdRowPn" Value='<%#Eval("PartNo") %>' />
                            <input type="hidden" class="hdPn" value='<%#Eval("PartNo") %>' />
                            <asp:GridView runat="server" ID="gvPNQuoteInfo" Width="100%" AutoGenerateColumns="false"
                                ShowHeader="false" ShowFooter="true">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <table width="100%" class="tbData">
                                                <tr>
                                                    <td align="center" style="width: 20%">
                                                        <%#Eval("quoteToErpId")%>
                                                    </td>
                                                    <td align="center" style="width: 20%">
                                                        <a href="javascript:void(0);" onclick="showDetail(this)" class="qq">
                                                            <%#Eval("QuoteQty")%></a>
                                                    </td>
                                                    <td align="center" style="width: 20%" class="nq">
                                                        <%#Eval("NumOfQuote")%>
                                                    </td>
                                                    <td align="center" style="width: 20%" class="oq">
                                                        <%#Eval("ConvertedQty")%>
                                                    </td>
                                                    <td align="center" style="width: 20%" class="no">
                                                        <%#Eval("NumOfOrder")%>
                                                    </td>
                                                </tr>
                                            </table>
                                        </ItemTemplate>
                                        <FooterTemplate>
                                            <table width="100%" class="tbSubtotal">
                                                <tr>
                                                    <td align="center" style="width: 20%; font-weight: bold">
                                                        Subtotal
                                                    </td>
                                                    <td align="center" style="width: 20%">
                                                        <a href="javascript:void(0);" onclick="showDetail(this)" class="tqq"></a>
                                                    </td>
                                                    <td align="center" style="width: 20%" class="tnq">
                                                    </td>
                                                    <td align="center" style="width: 20%" class="toq">
                                                    </td>
                                                    <td align="center" style="width: 20%" class="tno">
                                                    </td>
                                                </tr>
                                            </table>
                                        </FooterTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnRun" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
    <div id="divDetail" style="display: none">
        <table width="100%">
            <thead>
                <tr>
                    <th>
                        Quotation #
                    </th>
                    <th>
                        Rev.
                    </th>
                    <th>
                        Quantity
                    </th>
                    <th>
                        Converted
                    </th>
                </tr>
            </thead>
            <tbody id="divBody" />
        </table>
    </div>
    <script type="text/javascript">
        function calcSubTotal() {
            var subTotals = $(".tbSubtotal");
            $.each(subTotals,
                function (idx, item) {
                    var rootCell = $(item).parent().parent().parent().parent();
                    var tqqSum = 0; var tnqSum = 0; var toqSum = 0; var tnoSum = 0;
                    rootCell.find(".qq").filter(function (index) { tqqSum += parseInt($(this).text()); }); rootCell.find(".tqq").text(tqqSum);
                    rootCell.find(".nq").filter(function (index) { tnqSum += parseInt($(this).text()); }); rootCell.find(".tnq").text(tnqSum);
                    rootCell.find(".oq").filter(function (index) { toqSum += parseInt($(this).text()); }); rootCell.find(".toq").text(toqSum);
                    rootCell.find(".no").filter(function (index) { tnoSum += parseInt($(this).text()); }); rootCell.find(".tno").text(tnoSum);
                }
            );
        }

        function gridviewScroll() {
            var imgPath = "<%=Util.GetRuntimeSiteUrl() %>" + "/Includes/GridViewScroll/Images/";
            gridView1 = $('#<%=gvMainQuoteReport.ClientId %>').gridviewScroll({
                width: $(window).width() * 0.8, height: $(window).height() * 0.65,
                railcolor: "#F0F0F0", barcolor: "#CDCDCD", barhovercolor: "#606060", bgcolor: "#F0F0F0",
                freezesize: 1, arrowsize: 30, varrowtopimg: imgPath + "arrowvt.png", varrowbottomimg: imgPath + "arrowvb.png",
                harrowleftimg: imgPath + "arrowhl.png", harrowrightimg: imgPath + "arrowhr.png",
                headerrowcount: 1, railsize: 16, barsize: 8
            });
        }

        function showDetail(btn) {
            $("#divBody").empty();
            var btnCss = $(btn).attr("class");
            var dateRange = $("#<%=hdFromToDate.ClientId %>").val();
            var Pn = $(btn).parent().parent().parent().parent().parent().parent().parent().parent().parent().parent().find(".hdPn").val();
            if (!Pn) Pn = $(btn).parent().parent().parent().parent().parent().parent().parent().parent().parent().parent().parent().parent().find(".hdPn").val();
            var postData = JSON.stringify({ pn: Pn, DateRange: dateRange });
            $.ajax(
                {
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetQuoteDetail", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        var result = $.parseJSON(retData.d);
                        var tbHtml = "";
                        $.each(result,
                            function (idx, item) {
                                tbHtml +=
                                "<tr><td align='center'>" + item.quoteNo + "</td><td align='center'>" + item.Revision_Number + "</td>" +
                                "<td align='center'>" + item.quote_qty + "</td><td align='center'>" + item.order_qty + "</td></tr>";
                            }
                        );
                        $("#divBody").html(tbHtml);
                        $("#divDetail").dialog({ modal: true, width: $(window).width() * 0.8, title: Pn });
                    },
                    error: function (msg) {
                        //console.log("call GetQuoteDetail err:" + msg.d);
                    }
                });
        }
    </script>
</asp:Content>
