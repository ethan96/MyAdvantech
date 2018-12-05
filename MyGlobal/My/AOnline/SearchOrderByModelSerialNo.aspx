<%@ Page Title="MyAdvantech AOnline Sales Portal - Search Order History by Model or Serial Number"
    Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Function GetOrderHistoryBySNPrModel(ByVal key As String) As DataTable
        'Frank 20120611 sap_invoice_sn was broken
        'Dim strSql As String = _
        '    " Select top 100 a.SO_NO as OrderNo, a.DN_NO as DN, a.PART_NO as MaterialNo, d.PRODUCT_DESC, b.Qty, " + _
        '    " c.currency, cast(b.Us_amt/b.us_ex_rate as numeric(18,2)) as Amount, a.PO_NO as PONo, " + _
        '    " b.Customer_ID as SOLDTO, a.INVOICE_NO as InvoiceNo, a.SERIAL_NUMBER, b.order_date, " + _
        '    " b.efftive_date, c.COMPANY_NAME, c.ADDRESS, d.MODEL_NO, d.PRODUCT_HIERARCHY, c.ACCOUNT_STATUS " + _
        '    " From SAP_INVOICE_SN a inner join EAI_ORDER_LOG b on a.SO_NO=b.order_no and a.PART_NO=b.item_no and a.INVOICE_NO=b.BillingDoc  " + _
        '    " inner join SAP_DIMCOMPANY c on b.Customer_ID=c.COMPANY_ID and b.org=c.ORG_ID inner join SAP_PRODUCT d on b.item_no=d.PART_NO  " + _
        '    " where b.org='" + Session("org_id") + "' "
        Dim strSql As String = _
            " Select top 100 a.SO_NO as OrderNo, a.DN_NO as DN, a.PART_NO as MaterialNo, d.PRODUCT_DESC, b.Qty, " + _
            " c.currency, cast(b.Us_amt/b.us_ex_rate as numeric(18,2)) as Amount, a.PO_NO as PONo, " + _
            " b.Customer_ID as SOLDTO, a.INVOICE_NO as InvoiceNo, a.SERIAL_NUMBER, b.order_date, " + _
            " b.efftive_date, dateadd(month,(case when t.extended_month is null then 24 else 24+t.extended_month end),b.efftive_date) as ex_due_date, " + _
            " c.COMPANY_NAME, c.ADDRESS, d.MODEL_NO, d.PRODUCT_HIERARCHY, c.ACCOUNT_STATUS " + _
            " From SAP_INVOICE_SN_V2 a inner join EAI_ORDER_LOG b on a.SO_NO=b.order_no and a.PART_NO=b.item_no and a.INVOICE_NO=b.BillingDoc  " + _
            " inner join SAP_DIMCOMPANY c on b.Customer_ID=c.COMPANY_ID and b.org=c.ORG_ID inner join SAP_PRODUCT d on b.item_no=d.PART_NO  " + _
            " left join (select distinct cast(replace(z.item_no,'AGS-EW-','') as float) as extended_month,z.order_no from EAI_ORDER_LOG z where z.item_no like 'AGS-EW%') as t on b.order_no=t.order_no " + _
            " where 1=1 "
        If Session("account_status") <> "FC" Then strSql += " and b.org='" + Session("org_id") + "' "
        If rblSearchOption.SelectedValue = "Serial" Then
            strSql += String.Format(" and a.SERIAL_NUMBER like '%{0}%' ", Replace(Replace(Trim(key), "'", "''"), "*", "%"))
            strSql += " order by a.SERIAL_NUMBER "
        ElseIf rblSearchOption.SelectedValue = "Model" Then
            strSql += String.Format(" and (a.PART_NO like '%{0}%' or d.MODEL_NO like '%{0}%') ", Replace(Replace(Trim(key), "'", "''"), "*", "%"))
            strSql += " order by b.order_date desc  "
        End If
        'strSql += " order by a.SERIAL_NUMBER, b.order_date desc  "
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
        Return dt
    End Function

    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        gvResult.EmptyDataText = "No Data"
        Dim dt As DataTable = GetOrderHistoryBySNPrModel(txtKey.Text)
        gvResult.DataSource = dt
        gvResult.DataBind() : upResult.Update()
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim order_no As String = dt.Rows(0).Item("OrderNo")
            gvOrder.DataSource = GetOrder(order_no) : gvOrder.DataBind() : tdOrder.Visible = True : upOrder.Update()
        Else
            gvOrder.DataBind() : tdOrder.Visible = False : upOrder.Update()
        End If
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Util.IsInternalUser2() = False Then Response.Redirect("../../home.aspx")
            If Session("account_status") = "FC" Then rblSearchOption.Items.RemoveAt(0) : rblSearchOption.Items(0).Selected = True : lblKetText.Text = "Serial No.:"
        End If
    End Sub
    
    Shared Function GetOrder(ByVal orderno As String) As DataTable
        If String.IsNullOrEmpty(orderno) Then Return Nothing
        Try
            Dim strSql As String = _
           " select top 200 a.order_no as [SO No.], a.item_no as [Part No.], b.MODEL_NO as [Model No.], b.PRODUCT_DESC as [Product Description], a.Qty,   " + _
           " dbo.dateonly(a.order_date) as [Order Date],  " + _
           " dbo.dateonly(a.efftive_date) as [Shipping Date], dbo.dateonly(dateadd(month,(case when t.extended_month is null then 24 else 24+t.extended_month end),a.efftive_date)) as [Warranty Due Date], case when d.FINAL_REPLACE_BY is not null or d.FINAL_REPLACE_BY <>'' then d.FINAL_REPLACE_BY else case when e.REPLACE_BY is not null or e.REPLACE_BY<>'' then e.REPLACE_BY else '' end end as [Replace By]  " + _
           " from EAI_ORDER_LOG a inner join SAP_PRODUCT b on a.item_no=b.PART_NO inner join SAP_DIMCOMPANY c on a.Customer_ID=c.COMPANY_ID and a.org=c.ORG_ID left join PLM_PHASEOUT_FINAL_REPLACEMENT d on a.item_no=d.ITEM_NUMBER left join PLM_PHASEOUT e on a.item_no=e.ITEM_NUMBER  " + _
           " left join (select distinct cast(replace(z.item_no,'AGS-EW-','') as float) as extended_month,z.order_no from EAI_ORDER_LOG z where z.item_no like 'AGS-EW%' and z.order_no=@ONO) as t on a.order_no=t.order_no " + _
           " where a.order_no=@ONO and a.Qty<>0 " + _
           " order by a.efftive_date  "
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim apt As New SqlClient.SqlDataAdapter(strSql, conn)
            apt.SelectCommand.Parameters.AddWithValue("ONO", Trim(orderno))
            Dim dt As New DataTable
            apt.Fill(dt)
            conn.Close()
            Return dt
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function WSGetMozURLMetrics(ByVal orderno As String) As String
        If String.IsNullOrEmpty(orderno) Then Return ""
        Try
            Dim dt As DataTable = GetOrder(orderno)
            Dim gv As New GridView
            gv.DataSource = dt : gv.DataBind()
            Return Util.WebControl2String(gv)
        Catch ex As Exception
            Return ex.ToString()
        End Try
      
        'Return orderno
        'Dim u As Object = dbUtil.dbExecuteScalar("MY", "select top 1 ResponseUri from MY_WEB_SEARCH where keyid='" + keyid + "' ")
        'If u IsNot Nothing Then
        '    Dim strUrl As String = u.ToString()
        '    If strUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) Then
        '        strUrl = strUrl.Substring(7)
        '    Else
        '        If strUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase) Then
        '            strUrl = strUrl.Substring(8)
        '        End If
        '    End If
        '    Dim ret As String = getMozUrlMetrics(strUrl)
        '    Dim js As New Script.Serialization.JavaScriptSerializer()
        '    Dim l As MozURLMetrics = js.Deserialize(Of MozURLMetrics)(ret)
        '    Dim sb As New System.Text.StringBuilder
        '    sb.AppendLine("<table width='100%'>")
        '    sb.AppendLine(String.Format("<tr valign='top'><th colspan='2'>SEOmoz URL Metrics Analysis</th></tr>"))
        '    sb.AppendLine(String.Format("<tr><td> <a target='blank' href='{0}'>{0}</a></td></tr>", u.ToString()))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Subdomain mozRank (1-10)", l.fmrp))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Subdomain mozRank (raw score)", l.fmrr))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Domain Authority", l.pda))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Page Authority", l.upa))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "External Links", l.ueid))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Links", l.uid))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "mozRank (1-10)", l.umrp))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "mozRank (raw score)", l.umrr))
        '    sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "HTTP Status Code", l.us))
        '    'sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "Title", l.ut))
        '    'sb.AppendLine(String.Format("<tr valign='top'><th align='left' style='width:140px'>{0}</th><td>{1}<td/></tr>", "URL", l.uu))
        '    sb.AppendLine("</table>")
        '    Return sb.ToString()
        'End If
        'Return "No Data"
    End Function
    
    Protected Sub gvResult_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Session("account_status") = "FC" Then
            gvResult.Columns(4).Visible = False : gvResult.Columns(7).Visible = False : gvResult.Columns(8).Visible = False
            gvResult.Columns(11).Visible = False : gvResult.Columns(12).Visible = False
            If e.Row.RowType = DataControlRowType.DataRow Then
                e.Row.Cells(0).Text = "<a href='../../Product/Model_Detail.aspx?model_no=" + e.Row.Cells(0).Text + "' target='_blank'>" + e.Row.Cells(0).Text + "</a>"
            End If
        Else
            If e.Row.RowType = DataControlRowType.DataRow Then
                e.Row.Cells(1).Text = "<a href='../../DM/ProductDashboard.aspx?PN=" + e.Row.Cells(1).Text + "' target='_blank'>" + e.Row.Cells(1).Text + "</a>"
            End If
        End If
    End Sub

    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvOrder.DataSource = GetOrder(CType(sender, LinkButton).Text) : gvOrder.DataBind() : upOrder.Update()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript">
        function ShowMozMetrics(kid) {
            var divMoz = document.getElementById('div_Moz');
            divMoz.style.display = 'block';
            var divMozDetail = document.getElementById('div_MozDetail');
            divMozDetail.innerHTML = "<center><img src='../../Images/loading2.gif' alt='Loading...' width='35' height='35' />Loading...</center> ";
            PageMethods.WSGetMozURLMetrics(kid,
                function (pagedResult, eleid, methodName) {
                    divMozDetail.innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    //alert(error.get_message());
                    divMozDetail.innerHTML = error.get_message();
                });
        }
        function CloseDivMoz() {
            var divMoz = document.getElementById('div_Moz');
            divMoz.style.display = 'none';
        }
    </script>
    <table width="100%">
        <tr><th align="left"><h2>Search Order by Serial Number</h2></th></tr>
        <tr style="height:5px"><td>&nbsp;</td></tr>
        <tr>
            <td>
                <asp:Panel runat="server" ID="Panel1" DefaultButton="btnSearch">
                    <table>
                        <tr>
                            <th align="left">
                                Search By:
                            </th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="rblSearchOption" RepeatColumns="2" RepeatDirection="Horizontal">
                                    <asp:ListItem Text="Model No." Value="Model" Selected="True" />
                                    <asp:ListItem Text="Serial No." Value="Serial" />
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">
                                <asp:Label runat="server" ID="lblKetText" Text="Model/Serial No.:" /> 
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtKey" />
                            </td>
                            <td><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:UpdatePanel runat="server" ID="upResult" UpdateMode="Conditional" ChildrenAsTriggers="false">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gvResult" Width="100%" AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:BoundField HeaderText="Model No." DataField="MODEL_NO" />
                                <asp:BoundField HeaderText="Part No." DataField="MaterialNo" />
                                <asp:BoundField HeaderText="Product Description" DataField="PRODUCT_DESC" />
                                <asp:BoundField HeaderText="Qty." DataField="Qty" ItemStyle-HorizontalAlign="Center" />
                                <asp:TemplateField HeaderText="Amount"> 
                                    <ItemTemplate>
                                        <%#Util.FormatMoney(Eval("Amount"), Eval("CURRENCY"))%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="Serial No." DataField="SERIAL_NUMBER" />
                                <asp:TemplateField HeaderText="SO No.">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lblOrder" Text='<%#Eval("OrderNo") %>' />
                                        <asp:LinkButton runat="server" ID="btnOrder" Text='<%#Eval("OrderNo")%>' OnClick="btnOrder_Click" Visible="false" />
                                        <%--<a href="javascript:void(0);" onclick=ShowMozMetrics('<%#Eval("OrderNo") %>')><%#Eval("OrderNo") %></a>--%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="PO No." DataField="PONo" />
                                <asp:BoundField HeaderText="Invoice No." DataField="InvoiceNo" />
                                <asp:TemplateField HeaderText="Order Date">
                                    <ItemTemplate>
                                        <%#CDate(Eval("order_date")).ToString("yyyy/MM/dd")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Warranty Due Date">
                                    <ItemTemplate>
                                        <%# CDate(Eval("ex_due_date")).ToString("yyyy/MM/dd")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Customer Name">
                                    <ItemTemplate>
                                        <a target="_blank" href='../../DM/CustomerDashboard.aspx?ERPID=<%#Eval("SOLDTO") %>'><%#Eval("COMPANY_NAME")%></a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="Account Status" DataField="ACCOUNT_STATUS" />
                            </Columns>
                        </asp:GridView>
                        <br /><br />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
                <asp:UpdatePanel runat="server" ID="upOrder" UpdateMode="Conditional">
                    <ContentTemplate>
                        <h3 runat="server" id="tdOrder" visible="false">Order Detail:</h3>
                        <asp:GridView runat="server" ID="gvOrder" Width="100%"></asp:GridView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
        TargetControlID="PanelMozDetail" HorizontalSide="Center" VerticalSide="Middle"
        HorizontalOffset="400" VerticalOffset="200" />
    <asp:Panel runat="server" ID="PanelMozDetail">
        <div id="div_Moz" style="display: none; background-color: white;
            border: solid 1px silver; padding: 10px; width: 800px; height: 600px; overflow: auto;">
            <table width="100%">
                <tr>
                    <td><a href="javascript:void(0);" onclick="CloseDivMoz();">Close</a></td>
                </tr>
                <tr>
                    <td>
                        <div id="div_MozDetail"></div>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel>  
</asp:Content>