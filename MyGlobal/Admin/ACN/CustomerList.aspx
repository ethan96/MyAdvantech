<%@ Page Title="SAP Customer list" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            BindGV()
        End If
    End Sub
    Private Sub BindGV()
        Dim _customers As List(Of ACNitem) = ACNUtil.Current.ACNContext.ACNitems.OrderByDescending(Function(p) p.RequestDate).ToList
        gv1.DataSource = _customers
        gv1.DataBind()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataKeyNames="rowid">
        <Columns>
            <asp:TemplateField HeaderText="序号" InsertVisible="False">
                <ItemStyle HorizontalAlign="Center" />
                <HeaderStyle HorizontalAlign="Center" Width="35" />
                <ItemTemplate>
                    <%#Container.DataItemIndex+1%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="客户名称" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center"
                ItemStyle-Width="20%">
                <ItemTemplate>
                    <asp:HyperLink ID="HyperLink1" Target="_blank" runat="server" NavigateUrl='<%# Eval("rowid", "CreateCustomer.aspx?rowid={0}") %>'>
                                    <%# Eval("sdt_Name")%>
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="ErpID" DataField="sdt_EripID" HeaderStyle-HorizontalAlign="Center"
                ItemStyle-HorizontalAlign="Center" />
            <asp:TemplateField HeaderText="新Ship-To" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:CheckBox runat="server" ID="tj" Checked='<%#Eval("IsHaveShipto")%> ' Enabled="false" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Ship-To" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <span style="padding-left: 5px; color: tomato;">
                        <%# Eval("spt_EripID")%>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="状态" DataField="StatusDescX" HeaderStyle-HorizontalAlign="Center"
                ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="业务" DataField="ResquestByX" SortExpression="ResquestBy"
                ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="申请日期" DataField="RequestDate" SortExpression="RequestDate"
                DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
