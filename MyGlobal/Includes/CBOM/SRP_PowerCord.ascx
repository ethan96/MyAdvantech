<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SRP_PowerCord.ascx.cs" Inherits="CBOM_SRP_PowerCord" %>
<asp:Panel ID="pnSrp" runat="server">
    <asp:Repeater ID="rpSRP" runat="server" OnItemDataBound="rpSRP_ItemDataBound">
    <HeaderTemplate>
        <table>
            <tbody>
    </HeaderTemplate>
    <ItemTemplate>
        <tr>
            <td>
                <p style="display:inline;"><%#Eval("text") %> <%#Eval("desc") %></p>&nbsp;
                <asp:Literal ID="lt" runat="server"></asp:Literal>
            </td>
        </tr>
    </ItemTemplate>
    <FooterTemplate>
            </tbody>
        </table>
    </FooterTemplate>
</asp:Repeater>
</asp:Panel>