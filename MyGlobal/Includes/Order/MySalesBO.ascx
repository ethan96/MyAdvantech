<%@ Control Language="VB" ClassName="MySalesBO" %>

<script runat="server">
    Function GetSql() As String
        If Session("account_status") Is Nothing OrElse Session("account_status").ToString() <> "EZ" OrElse Session("sales_id") = "gy78787878" Then
            Return ""
        End If
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT top 100 a.ORDERNO, a.PONO, a.BILLTOID, a.SHIPTOID, a.ORDERDATE, a.CURRENCY, "))
            .AppendLine(String.Format(" a.ORDERLINE, a.PRODUCTID, cast(a.SCHDLINECONFIRMQTY as int) as SCHDLINECONFIRMQTY, a.SCHDLINEOPENQTY, a.UNITPRICE, "))
            .AppendLine(String.Format(" a.TOTALPRICE, a.DOC_STATUS, a.DUEDATE, a.ORIGINALDD, a.EXWARRANTY,  "))
            .AppendLine(String.Format(" a.SCHEDLINESHIPEDQTY, a.SCHDLINENO, a.DLV_QTY, a.COMPANY_NAME "))
            .AppendLine(String.Format(" FROM SAP_BACKORDER_AB AS a INNER JOIN SAP_COMPANY_EMPLOYEE AS b ON a.BILLTOID = b.COMPANY_ID "))
            .AppendLine(String.Format(" WHERE b.SALES_CODE = '{0}' ", Session("sales_id"), Session("org_id")))
            If txtCustName.Text.Trim() <> "" Then
                .Append(String.Format(" and a.COMPANY_NAME like N'%{0}%' ", txtCustName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtOrderNo.Text.Trim() <> "" Then
                .Append(String.Format(" and (a.ORDERNO like N'%{0}%' or a.PONO like N'%{0}%') ", txtOrderNo.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtPN.Text.Trim() <> "" Then
                .Append(String.Format(" and a.PRODUCTID like N'%{0}%' ", txtPN.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by a.ORDERDATE desc "))
        End With
        Return sb.ToString()
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Session("account_status") IsNot Nothing AndAlso Session("account_status").ToString() = "EZ" Then
                If Session("sales_id") Is Nothing Then
                    Session("sales_id") = Util.GetSalesID(Session("user_id"))
                    If Session("sales_id") Is Nothing OrElse Session("sales_id") = "" Then Session("sales_id") = "gy78787878"
                    If Util.IsAdmin() Then Session("sales_id") = "34013004"
                End If
            End If
        End If

    End Sub

    Protected Sub Timer1_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Interval = 99999 : src1.SelectCommand = GetSql() : Timer1.Enabled = False
        imgLoading.Visible = False : tr_QForm.Visible = True
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Public Shared Function FDate(ByVal d As String) As String
        If Date.TryParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Now) Then
            Return Date.ParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
        End If
        Return d
    End Function

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Enabled = False
    End Sub
</script>
<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
    <ContentTemplate>
        <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
                <td align="left" class="h3" height="30">My Backorder</td>
            </tr>
            <tr>
                <td valign="top">
                    <asp:Timer runat="server" ID="Timer1" Interval="20" OnTick="Timer1_Tick" />
                    <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                            <td align="center"><asp:Image runat="server" ID="imgLoading" ImageUrl="~/Images/loading2.gif" /></td>
                        </tr>
                        <tr runat="server" id="tr_QForm" visible="false">
                            <td valign="top">
                                <table width="100%" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <th align="left">Customer:</th>
                                        <td><asp:TextBox runat="server" ID="txtCustName" size="15" /></td>
                                        <th align="left">Order No.:</th>
                                        <td><asp:TextBox runat="server" ID="txtOrderNo" size="15" /></td>
                                        <th align="left">Part No.:</th>
                                        <td><asp:TextBox runat="server" ID="txtPN" size="15" /></td>
                                        <td><asp:ImageButton runat="server" ID="btnQuery" ImageUrl="~/Images/query_btn.jpg" OnClick="btnQuery_Click" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr><td height="10px"></td></tr>
                        <tr>
                            <td valign="top">
                                <asp:GridView runat="server" Width="100%" ID="gv1" AutoGenerateColumns="false" AllowPaging="true" EnableTheming="false" 
                                    AllowSorting="true" PageSize="10" DataSourceID="src1" 
                                    RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" 
                                    BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                    OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting" OnRowCreated="gv1_RowCreated"
                                    PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                    <Columns>                                        
                                        <asp:HyperLinkField HeaderText="Customer Name" SortExpression="company_name" DataNavigateUrlFields="BILLTOID" 
                                            DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ERPID={0}" DataTextField="company_name" Target="_blank" />                                                                    
                                        <asp:BoundField HeaderText="SO No." DataField="ORDERNO" SortExpression="ORDERNO" />
                                        <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="PRODUCTID" 
                                            DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" DataTextField="PRODUCTID" Target="_blank" />
                                        <asp:BoundField HeaderText="Qty." DataField="SCHDLINECONFIRMQTY" SortExpression="SCHDLINECONFIRMQTY" 
                                            ItemStyle-HorizontalAlign="Center" />
                                        <asp:TemplateField HeaderText="Order Date" SortExpression="DUEDATE">
                                            <ItemTemplate>
                                                <%# FDate(Eval("ORDERDATE"))%>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Due Date" SortExpression="DUEDATE">
                                            <ItemTemplate>
                                                <%# FDate(Eval("DUEDATE"))%>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>        
    </ContentTemplate>
</asp:UpdatePanel>
