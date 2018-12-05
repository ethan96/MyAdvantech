<%@ Page Language="VB" AutoEventWireup="false" ViewStateMode="Disabled" CodeFile="PI_ATW.aspx.vb" Inherits="Order_PI_ATW" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ATW Order</title>
</head>
<body>
    <form id="form1" runat="server">
        <div id="divHeader">
            <table>
                <tr>
                    <td>
                        <img src="/images/header_advantech_logo.gif" alt="Advantech" />
                    </td>
                </tr>
            </table>
        </div>
        <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" Visible="false" />

        <div align='left' style="color: white; height: 25px; line-height: 25px; background-color: #FF6600; text-align: left;">
            <b>&nbsp;&nbsp;Customer</b>
        </div>
        <table width="100%" class="mytable" cellpadding="0" cellspacing="0" border="1" style="border-color: #D7D0D0; border-width: 1px; border-style: Solid; width: 100%; border-collapse: collapse;">
            <tr>
                <th style="text-align: right" width="15%">Account's ERPID:&nbsp;&nbsp;
                </th>
                <td width="35%">&nbsp;&nbsp;<asp:Label runat="server" ID="lbERPID" />
                </td>
                <th style="text-align: right" width="15%">Sales Person:&nbsp;&nbsp;
                </th>
                <td width="35%">&nbsp;&nbsp;<asp:Label runat="server" ID="lbSalesPersonLstName" /><asp:Label runat="server" ID="lbSalesPersonFstName" />
                </td>
            </tr>
            <tr>
                <th style="text-align: right">Account:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label runat="server" ID="lbAccount" />
                </td>
                <th style="text-align: right">Opp. ID:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label ID="lbOptyid" runat="server" Text=""></asp:Label>
                </td>
            </tr>
            <tr>
                <th style="text-align: right">Address:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label ID="lbAdr" runat="server" Text=""></asp:Label>
                </td>
                <th style="text-align: right">Project Name:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label runat="server" ID="lbOptyName" />
                </td>
            </tr>
            <tr>
                <th style="text-align: right">Attention:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label runat="server" ID="lbLstName"/><asp:Label runat="server" ID="lbFstName" />
                </td>
                <th style="text-align: right">Currency:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label runat="server" ID="lbCurr" />
                </td>
            </tr>
            <tr>
                <th style="text-align: right">Tel:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label ID="lbtel" runat="server" Text="" />
                </td>
                <th style="text-align: right">Total Revenue:&nbsp;&nbsp;
                </th>
                <td>&nbsp;&nbsp;<asp:Label runat="server" ID="lbTotal"> </asp:Label>

                    <asp:Label runat="server" ID="lbQuoteName" Visible="false" />
                    <asp:Label runat="server" ID="lbQuoteNum" Visible="false" />
                    <asp:Label ID="Labaccountrowid" runat="server" Text="" Visible="false"></asp:Label>
                    <asp:Label runat="server" ID="lbQuoteStatus" Visible="false" />
                    <asp:Label runat="server" ID="lbDue" Visible="false" /><asp:Label runat="server"
                        ID="lbSalesRep" Visible="false" />
                    <asp:Label runat="server" ID="lbEffDate" Visible="false" />
                </td>
            </tr>
            <tr>
                <th style="text-align: right">Note:&nbsp;&nbsp;
                </th>
                <td colspan="3">&nbsp;&nbsp;<asp:Label ID="lbnote" runat="server" Text="" />
                </td>                
            </tr>
        </table>
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
            <%--    <tr>
                <th align='left' style="color: #000000; text-align: left;"> Line Items
                </th>
            </tr>--%>
            <tr>
                <td>
                    <table style="width: 100%" cellpadding="0" cellspacing="0" border="0">
                        <tr>
                            <td>
                                <asp:GridView runat="server" ID="gvItems" Width="100%" AutoGenerateColumns="false"
                                    OnRowDataBound="gvItems_RowDataBound"
                                    DataKeyNames="line_no" HeaderStyle-CssClass="gvhd">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                            <HeaderTemplate>
                                                No.
                                                
                                            </HeaderTemplate>
                                            <HeaderStyle BackColor="#FF6600" ForeColor="White" />
                                            <ItemTemplate>
                                                <%#Eval("line_no") %>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Center" Width="50px"></ItemStyle>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Product">
                                            <ItemTemplate>
                                                &nbsp;&nbsp;<%#Eval("PART_NO") %>
                                            </ItemTemplate>
                                            <HeaderStyle BackColor="#FF6600" ForeColor="White" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Description">
                                            <ItemTemplate>
                                                &nbsp;&nbsp;<%#Eval("Description")%>
                                            </ItemTemplate>
                                            <HeaderStyle BackColor="#FF6600" ForeColor="White" />
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Net Price" ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                            </ItemTemplate>
                                            <HeaderStyle BackColor="#FF6600" ForeColor="White" />
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="Discount" DataField="DISC" ItemStyle-HorizontalAlign="Center"
                                            Visible="false">
                                            <HeaderStyle BackColor="#FF6600" ForeColor="White" />
                                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                        </asp:BoundField>
                                        <asp:TemplateField HeaderText="Qty." ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <%#Eval("QTY") %>
                                            </ItemTemplate>
                                            <HeaderStyle BackColor="#FF6600" ForeColor="White" />
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Due Date" ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <%# CDate(Eval("due_date")).ToString("yyyy-MM-dd") %>
                                            </ItemTemplate>
                                            <HeaderStyle BackColor="#FF6600" ForeColor="White" Height="25" />
                                        </asp:TemplateField>
                                    </Columns>
                                    <HeaderStyle BackColor="White" CssClass="gvhd" />
                                </asp:GridView>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <style type="text/css">
            body {
                font-family: arial,Arial Narrow,serif;
                font-size: 12px;
            }
            .mytable td {
                line-height: 35px;
            }
            .myth {
                color: white;
                background-color: #FF6600;
                line-height: 25px;
            }
        </style>
    </form>
</body>
</html>
