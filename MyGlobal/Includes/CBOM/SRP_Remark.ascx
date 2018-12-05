<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SRP_Remark.ascx.cs" Inherits="CBOM_SRP_Remark" %>
<tr>
    <td style="width: 100%;">
        <tr>
            <td>
                <p style="display: inline;"><%=this.RemarkText %>:</p>
            </td>
        </tr>
        <asp:Repeater ID="rpSRP" runat="server" OnItemDataBound="rpSRP_ItemDataBound">
            <ItemTemplate>
                <tr>
                    <td>
                        <p style="display: inline;">- <%#Eval("text") %></p>
                        <asp:Literal ID="lt" runat="server" EnableViewState="false" ViewStateMode="Disabled"></asp:Literal>
                    </td>
                </tr>
            </ItemTemplate>
        </asp:Repeater>
    </td>
</tr>