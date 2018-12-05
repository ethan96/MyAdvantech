<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Order History Inquiry" %>

<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Register TagPrefix="NaviOrderTracking" TagName="Inc" Src="~/Includes/OrderTrackingNavi_Inc.ascx" %>

<script runat="server">
    'Dim boDt As DataTable
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

    Private Sub GetBackOrderC()
        Try
            Dim kunnr As String = UCase(Session("company_id")), vkorg As String = UCase(Session("org_id"))
            If kunnr = "" Or vkorg = "" Then Exit Sub
            Dim matnr As String = Server.HtmlEncode(Me.txtPart_NO.Text.Trim().ToUpper())
            Dim vbeln As String = Server.HtmlEncode(Me.txtSO_NO.Text.Trim().ToUpper())
            Dim bstnk As String = Server.HtmlEncode(Me.txtPO_NO.Text.Trim().ToUpper())
            Dim FromDate As String = DateAdd(DateInterval.Month, -3, Now).ToString("yyyyMMdd")
            Dim ToDate As String = Now.ToString("yyyyMMdd")
            Dim tmpFrom As Date = Date.MinValue, tmpTo As Date = Date.MaxValue
            If Date.TryParseExact(Me.txtOrderDateFrom.Text, "yyyy/MM/dd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, tmpFrom) Then
                FromDate = tmpFrom.ToString("yyyyMMdd")
            End If
            If Date.TryParseExact(Me.txtOrderDateTo.Text, "yyyy/MM/dd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, tmpTo) Then
                ToDate = tmpTo.ToString("yyyyMMdd")
            End If
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.BSTNK AS PONO, VBAK.KUNNR as BILLTOID, ")
                .AppendFormat(" (select kunnr from saprdp.vbpa where vbpa.vbeln=vbak.vbeln and vbpa.parvw='WE' and rownum=1) AS SHIPTOID, ")
                .AppendFormat(" VBAK.AUDAT AS ORDERDATE, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS ORDERLINE, ")
                .AppendFormat(" VBAP.MATNR AS ProductId, VBAP.KWMENG AS SchdLineConfirmQty, ")
                .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, VBAP.NETPR AS UNITPRICE, ")
                .AppendFormat(" VBAP.NETWR AS TOTALPRICE, VBUP.LFSTA AS DOC_STATUS, VBEP.EDATU AS DUEDATE, VBEP.EDATU AS OriginalDD, VBAP.ZZ_GUARA AS ExWarranty, ")
                .AppendFormat(" (select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1) as SchedLineShipedQty, ")
                .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
                .AppendFormat(" nvl((select count(*) as n from SAPRDP.VBRP where VBRP.AUBEL = VBAK.VBELN and VBRP.AUPOS=VBAP.POSNR),0) as DLV_QTY ")
                .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
                .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
                .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
                .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND (VBUP.MANDT = '168')  AND ")
                .AppendFormat(" (VBAK.VKORG = '{0}') AND (VBAK.KUNNR='{1}') AND ", vkorg, kunnr)
                .AppendFormat(" (VBAK.AUDAT between '{0}' and '{1}') and VBUP.LFSTA ='C' ", FromDate, ToDate)
                If matnr <> "" Then .AppendFormat(" and VBAP.MATNR like '%{0}%' ", matnr)
                If vbeln <> "" Then .AppendFormat(" and VBAK.VBELN like '%{0}%' ", vbeln)
                If bstnk <> "" Then .AppendFormat(" and VBAK.BSTNK like '%{0}%' ", bstnk)
                .AppendFormat(" and VBAP.ABGRU = ' ' ")
                .AppendFormat(" ORDER BY ORDERLINE asc, DUEDATE desc")
            End With
            'Response.Write(sb.ToString())
            'If Session("user_id") = "rudy.wang@advantech.com.tw" Then Response.Write(sb.ToString)
            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
            For Each r As DataRow In dt.Rows
                If CInt(r.Item("DLV_QTY")) = 0 Then
                    r.Delete()
                End If
            Next
            'dt.AcceptChanges()

            Dim BRs() As DataRow = dt.Select("ORDERLINE >= 100", "OrderNo asc, ORDERLINE desc")
            If BRs.Length > 0 Then
                Dim btoUnitSum As Double = 0, btoAllSum As Double = 0, btoOrderLine As Integer = 0
                For Each sch As DataRow In BRs
                    If CInt(sch.Item("ORDERLINE")) <> btoOrderLine Then
                        btoOrderLine = CInt(sch.Item("ORDERLINE"))
                        If CInt(sch.Item("ORDERLINE")) > 100 Then
                            btoUnitSum += sch.Item("UNITPRICE") : btoAllSum += sch.Item("TOTALPRICE")
                            sch.Delete()
                        Else
                            sch.Item("UNITPRICE") = btoUnitSum : sch.Item("TOTALPRICE") = btoAllSum
                            btoUnitSum = 0 : btoAllSum = 0
                        End If
                    Else
                        sch.Delete()
                    End If
                Next
            End If
            dt.AcceptChanges()

            CType(ViewState("boDt"), DataTable).Merge(dt)
        Catch ex As Exception
            Response.Write(ex.ToString())
        End Try
    End Sub
    Private Sub GetBO()
        If ViewState("boDt") Is Nothing Then
            ViewState("boDt") = New DataTable
        Else
            CType(ViewState("boDt"), DataTable).Clear()
        End If
        GetBackOrderC()
        If CType(ViewState("boDt"), DataTable).Rows.Count > 0 Then CType(ViewState("boDt"), DataTable).DefaultView.Sort = "ORDERDATE desc"
        ViewState("boDt") = CType(ViewState("boDt"), DataTable).DefaultView.ToTable()
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("txtOrderDateFrom") <> "" Then txtOrderDateFrom.Text = Request("txtOrderDateFrom")
            If Request("txtPN") <> "" Then txtPart_NO.Text = Request("txtPN")
            GetBO() : gv1.DataSource = ViewState("boDt") : gv1.DataBind()
        End If
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txtOrderDateFrom.Text = DateAdd(DateInterval.Month, -3, Now).ToString("yyyy/MM/dd")
            Me.txtOrderDateTo.Text = Now.ToString("yyyy/MM/dd")
        End If
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gv1.Sorting
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gv1.PageIndex
        gv1.DataSource = SortDataTable(ViewState("boDt"), False)
        gv1.DataBind()
        gv1.PageIndex = pageIndex
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gv1.PageIndexChanging
        gv1.PageIndex = e.NewPageIndex : gv1.DataSource = ViewState("boDt") : gv1.DataBind()
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


    Protected Sub submit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        CType(ViewState("boDt"), DataTable).Clear()
        GetBO() : gv1.DataSource = ViewState("boDt") : gv1.DataBind()
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            e.Row.Cells(5).Text = Replace(Date.ParseExact(e.Row.Cells(5).Text, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd"), "-", "/")
            e.Row.Cells(7).Text = CInt(e.Row.Cells(7).Text)
            Dim fdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select isnull(factor,'') from SAP_TCURX where currency='{0}'", e.Row.Cells(6).Text))
            If fdt.Rows.Count > 0 Then
                Dim factor As String = fdt.Rows(0).Item(0).ToString
                e.Row.Cells(12).Text = Util.FormatMoney(CDbl(e.Row.Cells(12).Text) * Math.Pow(10, (2 - IIf(factor = "", 2, CInt(factor)))), e.Row.Cells(6).Text.ToUpper)
                e.Row.Cells(13).Text = Util.FormatMoney(CDbl(e.Row.Cells(13).Text) * Math.Pow(10, (2 - IIf(factor = "", 2, CInt(factor)))), e.Row.Cells(6).Text.ToUpper)
            End If

            e.Row.Cells(8).Text = Global_Inc.DeleteZeroOfStr(e.Row.Cells(8).Text)
            Dim oriDD As String = dbUtil.dbExecuteScalar("B2B", String.Format("select isnull(a.due_date,'') as due_date from order_detail a left join order_master b on a.order_id=b.order_id where b.order_no='{0}' and a.line_no='{1}'", e.Row.Cells(1).Text, e.Row.Cells(7).Text))
            If oriDD <> "" Then
                e.Row.Cells(15).Text = CDate(oriDD).ToString("yyyy/MM/dd")
            Else
                e.Row.Cells(15).Text = Replace(Date.ParseExact(e.Row.Cells(15).Text, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd"), "-", "/")
            End If
            If CInt(e.Row.Cells(16).Text) = 0 Then
                e.Row.Cells(14).Text = e.Row.Cells(15).Text
                e.Row.Cells(16).Text = e.Row.Cells(10).Text
            Else
                e.Row.Cells(14).Text = Replace(Date.ParseExact(e.Row.Cells(14).Text, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd"), "-", "/")
            End If
            'e.Row.Cells(15).Text = Replace(Date.ParseExact(e.Row.Cells(15).Text, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd"), "-", "/")
            If e.Row.Cells(17).Text.Trim = "&nbsp;" Or e.Row.Cells(17).Text.Trim = "" Or e.Row.Cells(17).Text.Trim = "0" Or e.Row.Cells(17).Text.Trim = "00" Then
                e.Row.Cells(17).Text = ""
            Else
                e.Row.Cells(17).Text = e.Row.Cells(17).Text.Trim & "&nbsp;" & "M(s)"
            End If
            e.Row.Cells(1).Text = "<a target='_blank' href='/Order/BO_OrderTracking.aspx?SO_NO=" & e.Row.Cells(1).Text & "&PO_No=" & e.Row.Cells(2).Text & "'>" & e.Row.Cells(1).Text & "</a>"
            If Integer.TryParse(e.Row.Cells(9).Text, 0) = True Then
                e.Row.Cells(9).Text = CInt(e.Row.Cells(9).Text)
            End If
            e.Row.Cells(16).Visible = False
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(8).Visible = False : e.Row.Cells(11).Visible = False
            If Util.IsAEUIT() Or _
                Util.IsInternalUser2() Then
                e.Row.Cells(15).Visible = True
            Else
                e.Row.Cells(15).Visible = False
            End If
            e.Row.Cells(16).Visible = False
        End If

    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Util.DataTable2ExcelFile(ViewState("boDt"), "BackOrder.xls")
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <div class="root"><asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" /> > <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx" Text="Order Tracking" /> > My Back Order</div>
    <table width="100%">
        <tr>
            <td valign="top">
                <div class="left" style="width:170px;">
                  <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                      <td height="10"></td>
                    </tr>
                    <tr>
                      <td height="24" class="menu_title">Order Tracking</td>
                    </tr>
                    <tr>
                      <td>
                      <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                          <tr>
                            <td height="10"></td>
                            <td></td>
                          </tr>
                          <tr>
                            <td width="5%" height="25"></td>
                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                              <tr>
                                <td width="8%" valign="top"><img src="../images/point.gif" width="7" height="14"/></td>
                                <td class="h2" style="font-size:12px;">Back Order</td>
                                </tr>
                              </table></td>
                          </tr>
                          <tr>
                            <td height="25"></td>
                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                  <td width="8%" valign="top"><img src="../images/point_02.gif" alt="" width="7" height="14"/></td>
                                  <td class="menu_title02"><a href="ARInquiry_WS.aspx">Account Payable</a></td>
                                </tr>
                            </table></td>
                          </tr>

                          <tr>
                            <td height="25"></td>
                            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                  <td width="8%" valign="top"><img src="../images/point_02.gif" alt="" width="7" height="14"/></td>
                                  <td class="menu_title02"><a href="ShippingCalendar.aspx">Shipping Calendar</a></td>
                                </tr>
                            </table></td>
                          </tr>
                           <tr>
                                <td height="25"></td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="8%" valign="top"><img src="../images/point_02.gif" alt="" width="7" height="14"/></td>
                                            <td class="menu_title02"><a href="BO_ForwarderTracking.aspx">Forwarder Number Tracking</a></td>
                                        </tr>
                                    </table>
                                </td>
                          </tr>
                          <tr>
                            <td height="15"></td>
                            <td></td>
                          </tr>
                        </table>      </td>
                    </tr>
                  </table>
                </div>
            </td>
            <td>
                <div class="right" style="width:707px;">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                          <td height="9"></td>
                        </tr>
                        <tr>    
                          <td height="24" class="h2">
                              <table border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                  <td width="12" valign="top"><img src="../images/point.gif" width="7" height="14"/></td>
                                  <td>Buy Order</td>
                                </tr>
                              </table>
                          </td>
                        </tr>
                        <tr>
                            <td>
                              <table width="100%" border="0" cellspacing="0" cellpadding="0" class="rightcontant3">
                                <tr>
                                  <td colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">

                                  </table></td>
                                </tr>
                                <tr><td height="20" colspan="3"></td></tr>        
        
                                <tr>
                                  <td colspan="3"></td>
                                </tr>
        
                                 <tr>
                                   <td width="3%"></td>
                                   <td >
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td class="h5" height="30">SO Number:</td>
                                                <td>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"                                             
                                                        ServiceMethod="GetSO" TargetControlID="txtSO_NO" ServicePath="~/Services/AutoComplete.asmx" 
                                                        MinimumPrefixLength="0" CompletionInterval="1000" />
                                                    <asp:TextBox ID="txtSO_NO" runat="server" Width="86px"></asp:TextBox>  
                                                </td>
                                                <td ></td>
                                                <td class="h5">Order Date:</td>
                                                <td>
                                                    <asp:TextBox ID="txtOrderDateFrom" runat="server" Width="86px"></asp:TextBox>&nbsp;~&nbsp;
                                                    <asp:TextBox ID="txtOrderDateTo" runat="server" Width="86px"></asp:TextBox>
									                <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtOrderDateFrom" Format="yyyy/MM/dd" />
									                <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtOrderDateTo" Format="yyyy/MM/dd" />
                                                    <span class="date_word">yyyy/mm/dd</span>
                                                </td>
                                                </tr>
                                            <tr>
                                                <td class="h5" height="30">PO Number:</td>
                                                <td>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace2"                                             
                                                        ServiceMethod="GetPO" TargetControlID="txtPO_NO" ServicePath="~/Services/AutoComplete.asmx" 
                                                        MinimumPrefixLength="0" CompletionInterval="1000" />
                                                    <asp:TextBox ID="txtPO_NO" runat="server" Width="86px"></asp:TextBox>
                                                </td>
                                                <td ></td>
                                                <td class="h5"></td>
                                                <td></td>
                                                </tr>
                                            <tr>
                                                <td class="h5" height="30">Part Number:</td>
                                                <td>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace3"                                             
                                                        ServiceMethod="GetPartNo" TargetControlID="txtPart_No" ServicePath="~/Services/AutoComplete.asmx" 
                                                        MinimumPrefixLength="1" FirstRowSelected="true" CompletionInterval="1000" />
                                                    <asp:TextBox ID="txtPart_NO" runat="server" Width="86px"></asp:TextBox>
                                                </td>
                                                <td ></td>
                                                <td class="h5"></td>
                                                <td align="right"><asp:Label runat="server" ID="SearchFlag" Text="NO" Visible="false"></asp:Label>
									            <asp:ImageButton runat="server" ID="submit" ImageUrl="~/Images/search1.gif" OnClick="submit_Click" /></td>
                                       </table>
                            
                                   </td>
                                   <td width="3%"></td>
                                 </tr>
                                 <tr>
                                  <td height="20" colspan="3"></td>
                                </tr>
                              </table> 
                            </td>
                        </tr>
                        <tr><td></td></tr>
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
                          <td height="10" colspan="2"><img src="../images/line3.gif" width="889" height="1" /></td>
                      </tr>
                      <tr height="30">
                          <td>
                            <table>  
                                <tr>
                                    <td width="20px"><asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="~/images/excel.gif" OnClick="btnToXls_Click" /></td>    
                                    <td><asp:LinkButton runat="server" ID="btnToXls" Text="Export To Excel" Font-Size="12px" ForeColor="#f29702" Font-Bold="true" OnClick="btnToXls_Click" /></td>
                                </tr>
                            </table>
                          </td>
                      </tr>
                      <tr>
                            <td>
                                <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowSorting="true" AllowPaging="true" PageSize="50" Width="100%"
                                     EnableTheming="false" RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" 
                                    BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="#311e90" HeaderStyle-Font-Size="10px" RowStyle-Font-Size="10px" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                    PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnRowDataBound="gv1_RowDataBound">
						            <Columns>
							            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                            <headertemplate>
                                                No.
                                            </headertemplate>
                                            <itemtemplate>
                                                <%# Container.DataItemIndex + 1 %>
                                            </itemtemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="Order NO." DataField="OrderNo" SortExpression="OrderNo" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="PO NO." DataField="PONO" SortExpression="PONO" />
                                        <asp:BoundField HeaderText="Ship To" DataField="SHIPTOID" SortExpression="SHIPTOID" />
                                        <asp:BoundField HeaderText="Bill To" DataField="BILLTOID" SortExpression="BILLTOID" />
                                        <asp:BoundField HeaderText="Order Date" DataField="ORDERDATE" SortExpression="ORDERDATE" ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Currency" DataField="CURRENCY" SortExpression="CURRENCY" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="Order Line" DataField="OrderLine" SortExpression="OrderLine" />
                                        <asp:BoundField HeaderText="Ln_Partial" DataField="SchdLineNo" SortExpression="SchdLineNo" />
                                        <asp:BoundField HeaderText="Part NO" DataField="ProductId" SortExpression="ProductId" />
                                        <asp:BoundField HeaderText="Order QTY" DataField="SchdLineConfirmQty" SortExpression="SchdLineConfirmQty" ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Shipped Qty" DataField="SchedLineShipedQty" SortExpression="SchedLineShipedQty" ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Unit Price" DataField="UNITPRICE" SortExpression="UNITPRICE" ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Total Price" DataField="TOTALPRICE" SortExpression="TOTALPRICE" ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Shipping Date" DataField="DUEDATE" SortExpression="DUEDATE" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="Original DD" DataField="OriginalDD" SortExpression="OriginalDD" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="Open QTY" DataField="SchdLineOpenQty" SortExpression="SchdLineOpenQty" ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Extended Warranty Months" DataField="ExWarranty" SortExpression="ExWarranty" ItemStyle-HorizontalAlign="Right" />
                                    </Columns>
                                    <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
					            </asp:GridView>
                            </td>
                      </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
    
    
</asp:Content>
