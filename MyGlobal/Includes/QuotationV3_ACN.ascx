<%@ Control Language="C#" AutoEventWireup="true" CodeFile="QuotationV3_ACN.ascx.cs" Inherits="Includes_QuotationV3_ACN" %>
<script type="text/javascript">
    function UpdateQtyOrReqDate() {
        return false;
    }
</script>
<asp:Button ID="btnUpdate" runat="server" Text="Update" OnClick="btnUpdate_Click" />
<asp:Repeater ID="rpCartDetail" runat="server" OnItemDataBound="rpCartDetail_ItemDataBound">
    <HeaderTemplate>
        <table cellspacing="0" rules="all" border="1" style="border-color:#D7D0D0;border-width:1px;border-style:Solid;width:100%;border-collapse:collapse;">
            <tr style="color:Black;background-color:Gainsboro;white-space:nowrap;">
                <th align="center" scope="col">No.</th>
                <% if (this._showCategory == true)
                   {  %>
                <th>Category</th>
                <%} %>
                <th>Part No.</th>
                <th>Description</th>
                <th>List Price</th>
                <th>Unit Price</th>
                <th>Disc.</th>
                <th>Qty.</th>
                <th>Require Date</th>
                <th>Sub Total</th>
                <th>Customer PN.</th>
                <th>ABC Indicator</th>
            </tr>
    </HeaderTemplate>
    <ItemTemplate>
        <tr class=<%#GetRowStyle(Container.ItemIndex, Eval("line_no").ToString()) %>>
            <td><%#Eval("line_no") %></td>
            <% if (this._showCategory == true)
               {  %>
            <td><%#Eval("category") %></td>
            <%} %>
            <td><%#Eval("part_no") %></td>
            <td><%#Eval("Description") %></td>
            <td><%#Eval("list_price") %></td>
            <td><%#Eval("unit_price") %></td>
            <td></td>
            <td><%#Eval("qty") %><asp:TextBox ID="txtQty" runat="server"></asp:TextBox></td>
            <td><%#Eval("req_date") %></td>
            <td></td>
            <td><%#Server.HtmlDecode(Eval("custMaterial").ToString()) %></td>
            <td></td>
        </tr>
    </ItemTemplate>
    <FooterTemplate>
        </table>
    </FooterTemplate>
</asp:Repeater>