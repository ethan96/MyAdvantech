<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            SqlDataSource1.SelectCommand = " SELECT distinct CategoryName FROM ESTORE_BTOS_CATEGORY  where storeid ='AUS' order by CategoryName "
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td align="left" height="45">
                <div class="euPageTitle">   Category List</div>
            </td>
        </tr>
        <tr valign="top">
            <td align="center">
                <asp:GridView runat="server" ID="AdxGrid1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false"
                    DataKeyNames="CategoryName" Width="100%">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="2%" ItemStyle-HorizontalAlign="Center">
                            <HeaderTemplate>
                                No.
                            </HeaderTemplate>
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Category Name">
                            <ItemTemplate>
                                <a href="EstoreCBOMList.aspx?CategoryName=<%# Eval("CategoryName ")%>">
                                    <%# Eval("CategoryName ")%>
                                </a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>">
                </asp:SqlDataSource>
            </td>
        </tr>
        <tr>
            <td align="left">
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
