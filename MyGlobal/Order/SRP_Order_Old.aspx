<%@ Page Title="MyAdvantech - SRP Ordering Function" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="SRP_Order_Old.aspx.cs" Inherits="Order_SRP_Order" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td>
                <h3 style="color:navy">SRP Ordering Function</h3><br /><br />
            </td>
        </tr>
        <tr>
            <td align="center">
                <table style="width:700px; border: 1px solid black;">
                    <tr>
                        <th>SRP Product No.</th><th>Qty.</th><th>Selling Price</th><th></th>
                    </tr>
                    <tr>
                        <td align="center">
                            SRP-SR-100-BTO
                        </td>
                        <td align="center">
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1" TargetControlID="txtQty" FilterType="Numbers" />
                            <asp:TextBox runat="server" ID="txtQty" Width="20px" Text="1" />
                        </td>
                        <td align="center">
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender2" TargetControlID="txtSellingPrice" FilterType="Numbers" />
                            <%=Session["COMPANY_CURRENCY_SIGN"].ToString() %><asp:TextBox runat="server" ID="txtSellingPrice" Width="50px" />
                        </td>
                        <td align="center"><asp:Button runat="server" ID="btnOrder" Text="Order" OnClick="btnOrder_Click" Enabled="false" /></td>
                    </tr>
                </table>
                <br /><br />
            </td>
        </tr>
        <tr>
            <td align="center">
                <asp:Label ID="lbMsg" runat="server" ForeColor="Tomato" Font-Size="Large"></asp:Label>
            </td>
        </tr>
        <tr runat="server" id="trInternalTr" visible="false">
            <td align="center">
                Revenue Split List (Internal Only)
                <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundField HeaderText="Part No." DataField="CATEGORY_ID" />
                        <asp:BoundField HeaderText="Category Name" DataField="CATEGORY_NAME" />                        
                        <asp:BoundField HeaderText="Unit Price" DataField="CATEGORY_PRICE" />
                        <asp:BoundField HeaderText="Qty." DataField="CATEGORY_QTY" />
                    </Columns>
                </asp:GridView>
                
            </td>
        </tr>
    </table>
</asp:Content>
