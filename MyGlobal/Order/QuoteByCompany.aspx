<%@ Page Title="MyAdvantech – Company’s quotation history" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Public Sub getData(ByVal sid As String)
        'Dim ws As New quote.quoteExit
        'Dim ds As New DataSet
        'ws.Timeout = -1
        'ws.getQuotationListByCompany(Session("company_id"), ds)
        'ds.Tables(0).DefaultView.RowFilter = String.Format("customId like '%{0}%' or quoteId like '%{0}%'", sid)
        'ds.Tables(0).DefaultView.Sort = String.Format("quoteDate desc")
        Dim _QuotationMasterList As List(Of QuotationMaster) = eQuotationUtil.GetQuoteMasterByCompanyid(Session("company_id").ToString, sid)

        'Ryan 20170410 Remove all expired data for non-internal users
        If Not Util.IsInternalUser2 Then
            _QuotationMasterList = _QuotationMasterList.Where(Function(p) Not p.X_isExpired).ToList
        End If

        Me.GridView1.DataSource = _QuotationMasterList 'ds.Tables(0).DefaultView
    End Sub

    Public Sub ShowData(ByVal sid As String)
        getData(sid)
        Me.GridView1.DataBind()
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.GridView1.PageIndex = e.NewPageIndex
        ShowData(Me.txtDesc.Text.Trim.Replace("'", "''"))
    End Sub

    Protected Sub btnSH_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ShowData(Me.txtDesc.Text.Trim.Replace("'", "''"))
    End Sub

    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.GridView1.DataKeys(row.RowIndex).Value
        'Dim RURL As String = String.Format("~/Order/Quote2Cart.aspx?UID={0}", id)
        'ming add 20140408 参数补全

        Dim RURL As String = String.Format("~/Order/Quote2Cart.aspx?UID={0}&COMPANY={1}&USER={2}&ORG={3}", id, Session("COMPANY_ID"), Session("user_id"), Session("org_id"))

        'Ryan 20180509 EQV3
        If AuthUtil.IsEQV3 Then
            Dim QM As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(id)
            RURL = String.Format("/ORDER/Quote2CartEQ3.ASPX?UID={0}&USER={1}&COMPANY={2}&ORG={3}&ChangeQtyIsAllowed={4}", id, Session("user_id"), Session("COMPANY_ID"), QM.org, "False")
        End If

        Response.Redirect(RURL)
    End Sub
    Protected Sub btnDetail_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.GridView1.DataKeys(row.RowIndex).Value
        Response.Redirect("~/Order/quotationDetailCustomer.aspx?UID=" & id)
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Session("account_status") = "GA" Then Response.Redirect("../home.aspx")
            ShowData(Me.txtDesc.Text.Trim.Replace("'", "''"))
        End If
    End Sub

    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim _QuotationMaster As QuotationMaster = CType(e.Row.DataItem, QuotationMaster)
            'Dim ws As New quote.quoteExit
            'ws.Timeout = -1
            If _QuotationMaster.X_isExpired Then  'ws.isQuoteExpired(DBITEM.Item("quoteid")) Then
                If Util.IsInternalUser2() Then
                    e.Row.Cells(5).Text = "Expired"
                Else
                    e.Row.Visible = False
                End If
            End If

            If AuthUtil.IsBBUS Then
                e.Row.Cells(0).Text = (_QuotationMaster.quoteNo + " V" + _QuotationMaster.Revision_Number.ToString)
            End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    Quote Desc:<asp:TextBox runat="server" ID="txtDesc"></asp:TextBox>
    <asp:Button runat="server" ID="btnSH" OnClick="btnSH_Click" Text="Search" />
    <asp:GridView DataKeyNames="quoteId" ID="GridView1" AllowPaging="True" PageSize="30"
        runat="server" AutoGenerateColumns="False" OnPageIndexChanging="GridView1_PageIndexChanging"
        Width="100%" OnRowDataBound="GridView1_RowDataBound">
        <Columns>
            <asp:BoundField HeaderText="Quote No" DataField="QuoteNoX" ItemStyle-HorizontalAlign="Left">
                <ItemStyle HorizontalAlign="Left" Width="110px"></ItemStyle>
            </asp:BoundField>
            <asp:BoundField HeaderText="Custom ID" DataField="customId" ItemStyle-HorizontalAlign="Left">
                <ItemStyle HorizontalAlign="Left"></ItemStyle>
            </asp:BoundField>
            <asp:BoundField HeaderText="Erp ID" DataField="quoteToErpId" ItemStyle-HorizontalAlign="Left">
                <ItemStyle HorizontalAlign="Left"></ItemStyle>
            </asp:BoundField>
            <asp:BoundField HeaderText="Account Name" DataField="quoteToName" ItemStyle-HorizontalAlign="Left">
                <ItemStyle HorizontalAlign="Left"></ItemStyle>
            </asp:BoundField>
            <asp:BoundField HeaderText="Quote Date" DataField="quoteDate" DataFormatString="{0:d}"
                ItemStyle-HorizontalAlign="Center">
                <ItemStyle HorizontalAlign="Center"></ItemStyle>
            </asp:BoundField>
            <%--<asp:TemplateField>
                <HeaderTemplate>
                <asp:Label runat="server" ID="lbHdEdit" Text="<%$ Resources:myRs,Add2Cart %>"></asp:Label>
                  </HeaderTemplate>
                <ItemTemplate>
               <asp:Button runat="server" ID="btnAdd2Cart" Text="Add2Cart" />
                </ItemTemplate>
            </asp:TemplateField>--%>
            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    <asp:Label runat="server" ID="lbHdEdit" Text="Order"></asp:Label>
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:Button runat="server" ID="btnOrder" Text="Order" OnClick="btnOrder_Click" />
                </ItemTemplate>
                <HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                <ItemStyle HorizontalAlign="Center"></ItemStyle>
            </asp:TemplateField>
            <%--           <asp:TemplateField HeaderStyle-HorizontalAlign="Center"  ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                <asp:Label runat="server" ID="lbDetail" Text="Detail"></asp:Label>
                  </HeaderTemplate>
                <ItemTemplate>
                    <asp:Button runat="server" ID="btnDetail" Text="Detail" OnClick="btnDetail_Click"  Visible="false"/>
                    <a href="./quotationDetailCustomer.aspx?UID=<%# Eval("quoteId") %>" target="_blank">Detail</a>
                </ItemTemplate>

<HeaderStyle HorizontalAlign="Center"></HeaderStyle>

<ItemStyle HorizontalAlign="Center"></ItemStyle>
            </asp:TemplateField>--%>
            <asp:HyperLinkField DataNavigateUrlFields="quoteId" Target="_blank" HeaderStyle-HorizontalAlign="Center"
                ItemStyle-HorizontalAlign="Center" DataNavigateUrlFormatString="~/order/quotationDetailCustomer.ASPX?UID={0}"
                HeaderText="Detail" Text="Detail" />
            <%--         <asp:TemplateField>
                <HeaderTemplate>
                <asp:Label runat="server" ID="lbHdEdit" Text="Detail"></asp:Label>
                  </HeaderTemplate>
                <ItemTemplate>
                    <asp:ImageButton ImageUrl="~/Images/search.gif" runat="server" ID="ibtnDetail" />
                </ItemTemplate>
            </asp:TemplateField>--%>
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
