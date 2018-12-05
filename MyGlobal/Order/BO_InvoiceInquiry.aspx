<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Invoice Inquiry" %>
<%@ Register TagPrefix="NaviOrderTracking" TagName="Inc" Src="~/Includes/OrderTrackingNavi_Inc.ascx" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>

<script runat="server">
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("txtinvdate_from") = "" Then
                Me.txtinvdate_from.Text = FormatDate_SAP(Date.Now.AddDays(-30))
            Else
                Me.txtinvdate_from.Text = FormatDate_SAP(Request("txtinvdate_from"))
            End If
            If Request("txtinvdate_to") = "" Then
                Me.txtinvdate_to.Text = FormatDate_SAP(Date.Now)
            Else
                Me.txtinvdate_to.Text = FormatDate_SAP(Request("txtinvdate_to"))
            End If
         
            GetO() : gv1.DataSource = ViewState("dov") : gv1.DataBind()
         
        End If
    
       
      
        If Not Page.IsPostBack Or Me.SearchFlag.Text = "YES" Then Me.SearchFlag.Text = "NO"
             
    End Sub
    
    Private Sub GetO()
        If ViewState("dov") Is Nothing Then
            ViewState("dov") = New DataTable
        Else
            CType(ViewState("dov"), DataTable).Clear()
        End If
        getorder()
        If Not IsNothing(CType(ViewState("dov"), DataTable)) Then CType(ViewState("dov"), DataTable).DefaultView.Sort = "INVOICE_DATE desc  , INVOICE_NO desc   ,LINE_NO  asc"
        
        ViewState("dov") = CType(ViewState("dov"), DataTable).DefaultView.ToTable()
        
    End Sub
    
    Private Sub getorder()
        Dim strCompanyId As String
        strCompanyId = Session("COMPANY_ID")
        If Me.txtinv_no.Text.Trim = "" Then Me.txtinv_no.Text = Request("inv_no")
        If Me.txtpart_no.Text.Trim = "" Then Me.txtpart_no.Text = Request("part_no")
        If Me.txtso_no.Text.Trim = "" Then Me.txtso_no.Text = Request("so_no")
        If Me.txtpo_no.Text.Trim = "" Then Me.txtpo_no.Text = Request("po_no")
        If Me.txtdn_no.Text.Trim = "" Then Me.txtdn_no.Text = Request("dn_no")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat(" select b.vbeln as INVOICE_NO, ")
            .AppendFormat("(SELECT VBAK.BSTNK FROM saprdp.vbak WHERE VBAK.VBELN=b.AUBEL AND ROWNUM=1 and VBAK.MANDT='168') as PO_NO, ")
            .AppendFormat("b.aubel AS SO_NO,")
            .AppendFormat("b.vgbel as DN_NO,")
            .AppendFormat("a.WAERK as CURRENCY,")
            .AppendFormat("(SELECT MARA.PRDHA FROM SAPRDP.MARA WHERE MARA.MATNR=b.matnr AND ROWNUM=1 AND MARA.MANDT='168') as P_GROUP, ")
            .AppendFormat("b.posnr AS LINE_NO, b.matnr AS PART_NO, b.fkimg as INVOICE_QTY, b.kzwi2 As TOTAL_PRICE, a.fkdat AS INVOICE_DATE, '' as UNIT_PRICE ")
            .AppendFormat("from saprdp.vbrk a inner join saprdp.vbrp b on a.vbeln=b.vbeln inner join saprdp.vbak c on b.aubel=c.vbeln ")
            .AppendFormat("where a.mandt='168' and b.mandt='168' and c.mandt='168' and c.auart in ('ZOR','ZOR2','ZOR6') ", strCompanyId)
            If strCompanyId <> "EKGBEC01" Then
                .AppendFormat(" and a.kunag ='{0}' ", strCompanyId)
            Else
                If LCase(Session("user_id")) = "freya.huggard@ecauk.com" Then
                    .AppendFormat(" and (a.kunag in ('EKGBEC01','EKGBEC02','EKGBEC03','EKGBEC04')) ")
                Else
                    .AppendFormat(" and a.kunag ='{0}' ", strCompanyId)
                End If
            End If
            .AppendFormat(" and a.fkdat BETWEEN '{0}' AND '{1}'", Replace(Me.txtinvdate_from.Text.Trim, "/", ""), Replace(Me.txtinvdate_to.Text.Trim, "/", ""))
                        
            Dim inv_no As String = "00" & Me.txtinv_no.Text.Trim
            If Me.txtinv_no.Text.Trim <> "" Then .AppendFormat(" and  a.vbeln ='{0}'", inv_no) '00" & Me.txtinv_no.Text.Trim & "' "
            If Me.txtso_no.Text.Trim <> "" Then .AppendFormat(" and b.aubel ='{0}'", Global_Inc.Format2SAPItem2(Me.txtso_no.Text.Trim.Replace("'", "''")))
            If Me.txtdn_no.Text.Trim <> "" Then .AppendFormat(" and b.vgbel like '%{0}%'", Me.txtdn_no.Text.Trim)
            If Me.txtpart_no.Text.Trim <> "" Then .AppendFormat(" and b.matnr like '%{0}%'", Me.txtpart_no.Text.Trim)
            
            'Frank 2012/03/01:Resultset do not exclude numeral part_no
            '.AppendFormat(" and b.matnr not like '0%'")
        End With
        'Response.Write(sb.ToString())
        'Response.End()
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        If Me.txtpo_no.Text.Trim <> "" Then
            For Each r As DataRow In dt.Rows
                If r.Item("PO_NO") <> Me.txtpo_no.Text.Trim Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()
        End If
      
        CType(ViewState("dov"), DataTable).Merge(dt)
    End Sub

    Function FormatDate(ByVal xDate) As String
        Dim xYear As String = "0000"
        Dim xMonth As String = "00"
        Dim xDay As String = "00"
        
        If IsDate(xDate) = True Then
            xYear = Year(xDate).ToString
            xMonth = Month(xDate).ToString
            xDay = Day(xDate).ToString
        Else
            Dim ArrDate() As String = xDate.Split("/")
        
            If ArrDate(0).Length = 4 Then
                xYear = ArrDate(0) : xMonth = ArrDate(1) : xDay = ArrDate(2)
            Else
                xYear = ArrDate(2) : xMonth = ArrDate(0) : xDay = ArrDate(1)
            End If
        End If
        
        If xMonth.Length = 1 Then
            xMonth = "0" & xMonth
        End If
        If xDay.Length = 1 Then
            xDay = "0" & xDay
        End If
        FormatDate = xMonth & "/" & xDay & "/" & xYear
    End Function
    
    Function FormatDate_SAP(ByVal xDate) As String
        Dim xYear As String = "0000", xMonth As String = "00", xDay As String = "00"
        Try
            If IsDate(xDate) = True Then
                xYear = Year(xDate).ToString : xMonth = Month(xDate).ToString : xDay = Day(xDate).ToString
            Else
                Dim ArrDate() As String = xDate.Split("/")
        
                If ArrDate(0).Length = 4 Then
                    xYear = ArrDate(0) : xMonth = ArrDate(1) : xDay = ArrDate(2)
                Else
                    xYear = ArrDate(2) : xMonth = ArrDate(0) : xDay = ArrDate(1)
                End If
            End If
        
            If xMonth.Length = 1 Then xMonth = "0" & xMonth
            If xDay.Length = 1 Then
                xDay = "0" & xDay
            End If
        Catch ex As Exception
            Response.Write(xDate) : Response.End()
        End Try
        FormatDate_SAP = xYear & "/" & xMonth & "/" & xDay
    End Function
    
    Protected Sub submit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Me.SearchFlag.Text = "YES"
        CType(ViewState("dov"), DataTable).Clear()
        GetO() : gv1.DataSource = ViewState("dov") : gv1.DataBind()
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            e.Row.Cells(1).Text = Global_Inc.DeleteZeroOfStr(e.Row.Cells(1).Text)
            e.Row.Cells(6).Text = CInt(e.Row.Cells(6).Text)
            e.Row.Cells(8).Text = e.Row.Cells(8).Text.Split("-")(0)
            If CInt(e.Row.Cells(9).Text) > 0 Then
                e.Row.Cells(10).Text = Session("COMPANY_CURRENCY_SIGN") & FormatNumber(CDbl(e.Row.Cells(11).Text) / CDbl(e.Row.Cells(9).Text), 2)
            Else
                e.Row.Cells(10).Text = Session("COMPANY_CURRENCY_SIGN") & "0"
            End If
            
            e.Row.Cells(11).Text = Session("COMPANY_CURRENCY_SIGN") & FormatNumber(e.Row.Cells(11).Text, 2)
            e.Row.Cells(12).Text = Global_Inc.FormatDate(e.Row.Cells(12).Text)
        End If
    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'gv1.AllowPaging = False 'gv1.DataSource = ViewState("dov") : gv1.DataBind() : gv1.Export2Excel("Invoice.xls")
        Util.DataTable2ExcelDownload(ViewState("dov"), "Invoice.xls")
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gv1.Sorting
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gv1.PageIndex
        gv1.DataSource = SortDataTable(ViewState("dov"), False) : gv1.DataBind() : gv1.PageIndex = pageIndex
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gv1.PageIndexChanging
        gv1.PageIndex = e.NewPageIndex : gv1.DataSource = SortDataTable(ViewState("dov"), True) : gv1.DataBind()
    End Sub
    
    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GetSortDirection())
                End If
            End If
            Return dataView
        Else
            Response.Write("no gv source!")
            Return New DataView()
        End If
    End Function
    
    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") = Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property

    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") = Nothing, String.Empty, ViewState("SortExpression"))
        End Get
        Set(ByVal value As String)
            ViewState("SortExpression") = value
        End Set
    End Property
    
    Private Function GetSortDirection() As String
        Select Case GridViewSortDirection
            Case "ASC"
                GridViewSortDirection = "DESC"
            Case "DESC"
                GridViewSortDirection = "ASC"
        End Select
        Return GridViewSortDirection
    End Function
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <asp:Panel ID="Panel_Form" runat="server" DefaultButton="submit">
        <div class="root">
            <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
            >
            <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx"
                Text="Order Tracking" />
            > My Invoice</div>
        <table width="100%">
            <tr>
                <td valign="top">
                    <div class="left" style="width: 170px;">
                        <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="BO_InvoiceInquiry" />
                    </div>
                </td>
                <td>
                    <div class="right" style="width: 707px;">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td height="9">
                                </td>
                            </tr>
                            <tr>
                                <td height="24" class="h2">
                                    <table border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="12" valign="top">
                                                <img src="../images/point.gif" width="7" height="14" />
                                            </td>
                                            <td>
                                                Invoice
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="rightcontant3">
                                        <tr>
                                            <td colspan="3">
                                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="20" colspan="3">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="3%">
                                            </td>
                                            <td>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td class="h5" height="30">
                                                            Invoice Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" ServiceMethod="GetInvoiceNo"
                                                                TargetControlID="txtinv_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtinv_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                        </td>
                                                        <td class="h5">
                                                            Part Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace2" ServiceMethod="GetPartNo"
                                                                TargetControlID="txtpart_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="1"
                                                                FirstRowSelected="true" CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtpart_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30">
                                                            SO Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace3" ServiceMethod="GetSO"
                                                                TargetControlID="txtso_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtso_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                        </td>
                                                        <td class="h5" height="30">
                                                            PO Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace4" ServiceMethod="GetPO"
                                                                TargetControlID="txtpo_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtpo_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30">
                                                            DN Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace5" ServiceMethod="GetDN"
                                                                TargetControlID="txtdn_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtdn_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                        </td>
                                                        <td class="h5" height="30">
                                                            Invoice Date:
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txtinvdate_from" runat="server" Width="76px"></asp:TextBox>&nbsp;~&nbsp;
                                                            <asp:TextBox ID="txtinvdate_to" runat="server" Width="76px"></asp:TextBox>
                                                            <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtinvdate_from"
                                                                Format="yyyy/MM/dd" />
                                                            <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtinvdate_to"
                                                                Format="yyyy/MM/dd" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" />
                                                        <td />
                                                        <td />
                                                        <td class="h5" />
                                                        <td align="right">
                                                            <asp:Label runat="server" ID="SearchFlag" Text="NO" Visible="false"></asp:Label>
                                                            <asp:ImageButton runat="server" ID="submit" ImageUrl="~/Images/search1.gif" OnClick="submit_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td width="3%">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="20" colspan="3">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <table>
            <tr>
                <td>
                    <div>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td height="10" colspan="2">
                                    <img src="../images/line3.gif" width="889" height="1" />
                                </td>
                            </tr>
                            <tr height="30">
                                <td>
                                    <table>
                                        <tr>
                                            <td width="20px">
                                                <asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="~/images/excel.gif" OnClick="btnToXls_Click" />
                                            </td>
                                            <td>
                                                <asp:LinkButton runat="server" ID="btnToXls" Text="Export To Excel" Font-Size="12px"
                                                    ForeColor="#f29702" Font-Bold="true" OnClick="btnToXls_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="true"
                                        AllowSorting="true" Width="100%" PageSize="50" OnRowDataBound="gv1_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    No.
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <%# Container.DataItemIndex + 1 %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="Invoice NO." DataField="INVOICE_NO" SortExpression="INVOICE_NO" />
                                            <asp:BoundField HeaderText="PO NO." DataField="PO_NO" SortExpression="PO_NO" />
                                            <asp:BoundField HeaderText="SO NO." DataField="SO_NO" SortExpression="SO_NO" />
                                            <asp:BoundField HeaderText="DN NO." DataField="DN_NO" SortExpression="SO_NO" />
                                            <asp:BoundField HeaderText="Currency" DataField="CURRENCY" SortExpression="CURRENCY"
                                                ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Line" DataField="LINE_NO" SortExpression="LINE_NO" />
                                            <asp:BoundField HeaderText="Part NO." DataField="PART_NO" SortExpression="PART_NO" />
                                            <asp:BoundField HeaderText="Product Group" DataField="P_GROUP" SortExpression="P_GROUP" />
                                            <asp:BoundField HeaderText="Invoice QTY" DataField="INVOICE_QTY" SortExpression="INVOICE_QTY"
                                                ItemStyle-HorizontalAlign="Right" />
                                            <asp:BoundField HeaderText="Unit Price" DataField="UNIT_PRICE" SortExpression="UNIT_PRICE"
                                                ItemStyle-HorizontalAlign="Right" />
                                            <asp:BoundField HeaderText="Total Price" DataField="TOTAL_PRICE" SortExpression="TOTAL_PRICE"
                                                ItemStyle-HorizontalAlign="Right" />
                                            <asp:BoundField HeaderText="Invoice Date" DataField="INVOICE_DATE" SortExpression="INVOICE_DATE"
                                                ItemStyle-HorizontalAlign="Center" />
                                        </Columns>
                                    </sgv:SmartGridView>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>
