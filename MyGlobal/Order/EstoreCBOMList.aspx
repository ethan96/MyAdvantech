<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request("CategoryName") Is Nothing Then
            Response.End()
        End If
        If Not IsPostBack Then
            SqlDataSource1.SelectCommand = " SELECT  SProductID,BTONo,DisplayPartno FROM ESTORE_BTOS_CATEGORY  where storeid ='AUS' and CategoryName ='" + Request("CategoryName") + "' order by DisplayPartno"
        End If
    End Sub
    Protected Sub btnConfig_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As Button = CType(sender, Button)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim CATEGORY_ID As String = AdxGrid1.DataKeys(row.RowIndex).Values(0)
        Dim intQty As Integer = 1
        intQty = CType(row.FindControl("txtQty"), TextBox).Text
        Dim str As String = "Configurator.aspx?BTOITEM=" & CATEGORY_ID & "&QTY=" & intQty
        Response.Redirect(str)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%" cellpadding="0" cellspacing="0">
        <tr>
            <td height="45">
                <label class="lbStyle">
                    Search:</label>
                <input id="Text1" type="text" onkeyup="filter('ctl00__main_AdxGrid1',this.value)" />
            </td>
        </tr>
        <tr> <td valign="middle" align="left" class="text" style="padding-left:10px;border-bottom:#ffffff 1px solid;height:20px;background-color:#6699CC"> <font color="#ffffff"><b>Configuration Listing</b></font> </td> </tr>
        <tr valign="top">
            <td align="center">
                <asp:GridView runat="server" ID="AdxGrid1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false"
                    DataKeyNames="DisplayPartno">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="2%" ItemStyle-HorizontalAlign="Center">
                            <HeaderTemplate>
                                No.
                            </HeaderTemplate>
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="DisplayPartno" HeaderText="Part NO" />
                        <asp:TemplateField HeaderText="QTY" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:TextBox runat="server" ID="txtQty" Text="1" Width="30px" />
                                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft3" TargetControlID="txtQty"
                                    FilterType="Numbers, Custom" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Assemble" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:Button ID="btnConfig" runat="server" Text="Config" OnClick="btnConfig_Click" />
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
    <script type="text/javascript" language="javascript">
        function filter(name, q) {
            var regex = new RegExp(q, 'i');

            $('#' + name + ' tr').slice(1).each(function (i, tr) {
                tr = $(tr);
                var str = tr.text();
                if (regex.test(str)) {
                    tr.show();
                } else {
                    tr.hide();
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
