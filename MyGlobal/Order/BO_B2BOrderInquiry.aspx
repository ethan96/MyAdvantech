<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- B2B Order Inquiry" %>

<%@ Register TagPrefix="NaviOrderTracking" TagName="Inc" Src="~/Includes/OrderTrackingNavi_Inc.ascx" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>
<script runat="server">


    Protected Function getstr() As String
        Dim sso_no As String = Me.so_no.Text.Trim, c1 As String = "", c2 As String = "", spo_no As String = Me.po_no.Text.Trim
        Dim tmpFrom As Date = Date.MinValue, tmpTo As Date = Date.MaxValue, fdate As String = "", tdate As String = ""
        If Util.IsValidDateFormat(orderdate_from.Text) = True Then fdate = CDate(orderdate_from.Text).ToString("yyyyMMdd")
        If Util.IsValidDateFormat(orderdate_to.Text) = True Then tdate = CDate(orderdate_to.Text).ToString("yyyyMMdd")
        Dim c3 As String = "", c4 As String = ""

        If sso_no.Trim <> "" Then
            c1 = "a.vbeln like '%" & UCase(Util.ReplaceSQLStringFunc(sso_no)) & "'"
        End If
        If spo_no.Trim <> "" Then
            c2 = "a.bstnk like '%" & UCase(Util.ReplaceSQLStringFunc(spo_no)) & "'"
        End If
        If fdate.Trim <> "" Then
            c3 = "a.erdat>'" & fdate.Replace("/", "") & "'"
        End If
        If tdate.Trim <> "" Then
            c4 = "a.erdat<'" & tdate.Replace("/", "") & "'"
        End If

        Dim C As String = ""
        If c1 <> "" Then
            C = c1
        End If

        If c2 <> "" Then
            If C <> "" Then
                C = C & " AND " & c2
            Else
                C = c2
            End If
        End If

        If c3 <> "" Then
            If C <> "" Then
                C = C & " AND " & c3
            Else
                C = c3
            End If
        End If

        If c4 <> "" Then
            If C <> "" Then
                C = C & " AND " & c4
            Else
                C = c4
            End If
        End If

        If C <> "" Then
            C = " and " & C
        End If

        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select a.vbeln as SO_NO, a.bstnk as PO_NO, (select kunnr from saprdp.vbpa where vbpa.vbeln=a.vbeln and vbpa.parvw='WE' and rownum=1) AS SHIPTO_ID, ")
            .AppendFormat("a.KUNNR as BILLTO_ID, '' as PLACED_BY, '' as SALES_ID, a.erdat as order_date, " + _
                          " (select VBEP.EDATU from SAPRDP.VBEP where VBEP.VBELN=a.VBELN and rownum=1) as DUE_DATE, ")
            .AppendFormat("a.waerk as currency from saprdp.vbak a where a.mandt='168' ")
            If Session("company_id") <> "EKGBEC01" Then
                .AppendFormat(" and a.kunnr='{0}' ", UCase(Session("company_id")))
            Else
                If LCase(Session("user_id")) = "freya.huggard@ecauk.com" Then
                    .AppendFormat(" and (a.KUNNR in ('EKGBEC01','EKGBEC02','EKGBEC03','EKGBEC04')) ")
                Else
                    .AppendFormat(" and (a.KUNNR = '{0}') ", UCase(Session("company_id")))
                End If
            End If
            .AppendFormat(" and rownum<=500 {0} ", C)
            .AppendFormat(" order by a.vbeln ")
        End With
        'Response.Write(sb.ToString)
        Return sb.ToString
    End Function

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
        e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(1).Text = e.Row.Cells(1).Text
            Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", "select * from order_master where order_id='" & e.Row.Cells(1).Text & "'")
            If dt.Rows.Count > 0 Then
                e.Row.Cells(5).Text = dt.Rows(0).Item("Created_by")
                'e.Row.Cells(8).Text = Global_Inc.FormatDate(dt.Rows(0).Item("due_date"))
                e.Row.Cells(10).Text = "<a target='_blank' href='pi.aspx?NO=" & e.Row.Cells(1).Text & "&SO_NO=" & e.Row.Cells(1).Text & "'>P.I. Review</a>"
            Else
                e.Row.Cells(5).Text = "N/A"
                'e.Row.Cells(8).Text = "N/A"
                e.Row.Cells(10).Text = "N/A"
            End If
            e.Row.Cells(7).Text = Global_Inc.FormatDate(e.Row.Cells(7).Text)
            e.Row.Cells(8).Text = Global_Inc.FormatDate(e.Row.Cells(8).Text)
            e.Row.Cells(11).Text = "<a target='_blank' href='BO_OrderTracking.aspx?ORDER_NO=" & e.Row.Cells(1).Text & "&SO_NO=" & e.Row.Cells(1).Text & "'>SAP Order</a>"
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(6).Visible = False

            'Ryan 20170517 Show Add2Cart Column only for AJP
            If Not Session("org_id").ToString.ToUpper.Equals("JP01") AndAlso
               Not (Util.IsTesting AndAlso Not Session("org_id").ToString.ToUpper.StartsWith("CN")) AndAlso
               Not (Util.IsTesting AndAlso Not SAPDOC.IsATWCustomer(Session("company_id").ToString.ToUpper)) Then
                e.Row.Cells(12).Visible = False
            End If
        End If
    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", getstr())
        Util.DataTable2ExcelDownload(dt, "MyB2BOrders.xls")
    End Sub

    Protected Sub submit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", getstr())
        Me.gv1.DataSource = dt : Me.gv1.DataBind()
    End Sub


    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.gv1.PageIndex = e.NewPageIndex
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", getstr())
        Me.gv1.DataSource = dt : Me.gv1.DataBind()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            submit_Click(Nothing, New ImageClickEventArgs(1, 1))
        End If
    End Sub

    Protected Sub btnAdd2Cart_Click(sender As Object, e As EventArgs)
        Dim btn As Button = sender
        Dim row As GridViewRow = CType(btn.NamingContainer, GridViewRow)
        Dim SONO As String = row.Cells(1).Text
        Dim Tax As Decimal = 0
        Dim ErrMsg As String = String.Empty

        If Session("org_id").ToString.ToUpper.StartsWith("CN") Then
            Tax = 0.17
        End If

        If Advantech.Myadvantech.Business.OrderBusinessLogic.CopySAPOrder2Cart(SONO, Session("CART_ID").ToString, Session("company_id").ToString, Session("org_id").ToString, Session("Company_currency").ToString, ErrMsg, Tax) Then
            If SONO.ToUpper.StartsWith("CBN") Then
                HttpContext.Current.Session("ACN_StorageLocation") = "2000"
            Else
                HttpContext.Current.Session("ACN_StorageLocation") = "1000"
            End If

            Response.Redirect("~/Order/Cart_listV2.aspx")
        Else
            Util.JSAlert(Me.Page, "Add to cart failed, please kindly contact MyAdvantech IT for more information.\nError Message: " + ErrMsg + "")
            Exit Sub
        End If
    End Sub

</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <script type="text/javascript" src="../Includes/jquery-latest.min.js"></script>

    <script type="text/javascript">
        function CheckEOLItems(sender) {
            var flag = true;

            var postData = {
                _SONo: $(sender).attr("data-so"),
                _ORGID: "<%=Session("ORG_ID").ToString%>"
            };
            $.ajax({
                url: "<%= Util.GetRuntimeSiteUrl()%>/Services/MyServices.asmx/CheckEOLItems",
                type: "POST",
                dataType: 'json',
                async: false,
                data: postData,
                success: function (retData) {
                    if (retData.length > 0) {
                        // has EOL items
                        var EOLItems = "This order contains EOL items as below:" + "\n\n";
                        for (i = 0; i < retData.length; i++) {
                            EOLItems += retData[i] + "\n";
                        }
                        EOLItems += "\n" + "Please pay attention to these items and manually add them back if necessary.";
                        if (confirm(EOLItems) == true) {
                            flag = true;
                        }
                        else {
                            flag = false;
                        }
                    }
                    else {
                        // no EOL items
                        alert("Please check if extended warranty is needed and add it manually later in cart.\n")
                        flag = true;
                    }
                },
                error: function (msg) {

                }                
            });
            return flag;
        }
    </script>
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        >
        <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx"
            Text="Order Tracking" />
        > B2B Order Inquiry
    </div>
    <table width="100%">
        <tr>
            <td valign="top">
                <div class="left" style="width: 170px;">
                    <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="BO_B2BOrderInquiry" />
                </div>
            </td>
            <td>
                <div class="right" style="width: 707px;">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td height="9"></td>
                        </tr>
                        <tr>
                            <td height="24" class="h2">
                                <table border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="12" valign="top">
                                            <img src="../images/point.gif" width="7" height="14" />
                                        </td>
                                        <td>B2B Order
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
                                        <td height="20" colspan="3"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="3"></td>
                                    </tr>
                                    <tr>
                                        <td width="3%"></td>
                                        <td>
                                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td class="h5" height="30">SO Number:
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" ServiceMethod="GetSO"
                                                            TargetControlID="so_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                            CompletionInterval="1000" />
                                                        <asp:TextBox ID="so_no" runat="server" Width="95px"></asp:TextBox>
                                                    </td>
                                                    <td></td>
                                                    <td class="h5">Order Date:
                                                    </td>
                                                    <td>
                                                        <asp:TextBox ID="orderdate_from" runat="server" Width="76px"></asp:TextBox>&nbsp;~&nbsp;
                                                        <asp:TextBox ID="orderdate_to" runat="server" Width="76px"></asp:TextBox>
                                                        <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="orderdate_from"
                                                            Format="yyyy/MM/dd" />
                                                        <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="orderdate_to"
                                                            Format="yyyy/MM/dd" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="h5" height="30">PO Number:
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" ServiceMethod="GetPO"
                                                            TargetControlID="po_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                            CompletionInterval="1000" />
                                                        <asp:TextBox ID="po_no" runat="server" Width="95px"></asp:TextBox>
                                                    </td>
                                                    <td></td>
                                                    <td class="h5"></td>
                                                    <td></td>
                                                </tr>
                                                <tr>
                                                    <td class="h5" height="30"></td>
                                                    <td></td>
                                                    <td></td>
                                                    <td class="h5"></td>
                                                    <td align="right">
                                                        <asp:Label runat="server" ID="SearchFlag" Text="NO" Visible="false"></asp:Label>
                                                        <asp:ImageButton runat="server" ID="submit" ImageUrl="~/Images/search1.gif" OnClick="submit_Click" />
                                                    </td>
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
                        <tr>
                            <td></td>
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
                                <asp:GridView runat="server" ID="gv1" ShowWhenEmpty="true" AutoGenerateColumns="false"
                                    AllowPaging="true" PageSize="50" Width="100%" EnableTheming="true" OnRowDataBound="gv1_RowDataBound"
                                    OnPageIndexChanging="gv1_PageIndexChanging">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                            <HeaderTemplate>
                                                No.
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <%# Container.DataItemIndex + 1 %>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="SO NO." DataField="SO_NO" />
                                        <asp:BoundField HeaderText="PO NO." DataField="PO_NO" />
                                        <asp:BoundField HeaderText="Ship To" DataField="SHIPTO_ID" />
                                        <asp:BoundField HeaderText="Bill To" DataField="BILLTO_ID" />
                                        <asp:BoundField HeaderText="Placed By" DataField="PLACED_BY" />
                                        <asp:BoundField HeaderText="Sales ID" DataField="SALES_ID" />
                                        <asp:BoundField HeaderText="Order Date" DataField="ORDER_DATE" />
                                        <asp:BoundField HeaderText="Due Date" DataField="DUE_DATE" />
                                        <asp:BoundField HeaderText="Currency" DataField="CURRENCY" />
                                        <asp:BoundField HeaderText="B2B PI" />
                                        <asp:BoundField HeaderText="ERP Status" />
                                        <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <asp:Button ID="btnAdd2Cart" runat="server" Text="Add2Cart" data-so='<%#Eval("SO_NO") %>' OnClick="btnAdd2Cart_Click" OnClientClick="return CheckEOLItems(this);" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
</asp:Content>
