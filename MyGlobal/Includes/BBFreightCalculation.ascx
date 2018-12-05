<%@ Control Language="C#" AutoEventWireup="true" CodeFile="BBFreightCalculation.ascx.cs" Inherits="Includes_BBFreightCalculation" %>

<style type="text/css">
    .tbShippingResult td
    {
        cursor: pointer;
    }
    .hover_row
    {
        background-color: #A1DCF2;
    }
</style>

<div>

    <script language="javascript" type="text/javascript">
        function CheckOtherIsCheckedByGVID(rb) {
            var isChecked = rb.checked;
            var row = rb.parentNode.parentNode;

            var currentRdbID = rb.id;
            parent = document.getElementById("<%= gvShippingResult.ClientID %>");
            var items = parent.getElementsByTagName('input');

            for (i = 0; i < items.length; i++) {
                if (items[i].id != currentRdbID && items[i].type == "radio") {
                    if (items[i].checked) {
                        items[i].checked = false;
                    }
                }
            }
        }

        function SetFreightOptionAndCost() {
            var DeliveryType = "";
            var FreightCost = "";

            var items = document.getElementById("<%= gvShippingResult.ClientID %>").getElementsByTagName('input');
            for (i = 0; i < items.length; i++) {
                if (items[i].type == "radio" && items[i].checked) {
                    DeliveryType = items[i].getAttribute("dtype");
                    DeliveryValue = items[i].getAttribute("dvalue");
                    FreightCost = items[i].getAttribute("fvalue");
                }
            }
            SetBBFreightFromASCX(DeliveryType, DeliveryValue, FreightCost);
            $.fancybox.close();
            return false;
        }

        $(function () {
            $("[id*=gvShippingResult] td").hover(function () {
                $("td", $(this).closest("tr")).addClass("hover_row");
            }, function () {
                $("td", $(this).closest("tr")).removeClass("hover_row");
            });


            $("[id*=gvShippingResult] td").click(function () {
                var deliveryType = "";
                var deliveryValue = "";
                var freightCost = "";
                var row = $(this).closest("tr");
                var selectRowItem = $("td", row).eq(0).find("input");
                deliveryValue = selectRowItem.attr("dvalue");
                deliveryType = selectRowItem.attr("dtype");
                freightCost = selectRowItem.attr("fvalue");
                SetBBFreightFromASCX(deliveryType, deliveryValue, freightCost);
                $.fancybox.close();
            });


        });



    </script>
    <div>
        <div style="text-align:center;margin:5px">
            <b style=""><asp:Label ID="lblResultTitle" runat="server" style="font-size: 20px; font-weight: bold;"></asp:Label></b>
        </div>

        <table id="tbShippingResult" class="tbShippingResult" runat ="server" visible="false">
            <tr>
                <td style="text-align: left">
                    <asp:Label ID="lbWeight" runat="server"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:GridView ID="gvShippingResult" runat="server" AutoGenerateColumns="False" OnRowDataBound="gvShippingResult_RowDataBound">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                </HeaderTemplate>
                                <ItemTemplate>
<%--                                    <input type="radio" id="rb" runat="server" dtype='<%#Eval("MethodName")%>' dvalue='<%#Eval("MethodValue")%>' fvalue='<%#Eval("ShippingCost")%>' onclick="CheckOtherIsCheckedByGVID(this);" />--%>
                                    <input type="hidden" id="hdnField1" runat="server" dtype='<%#Eval("MethodName")%>' dvalue='<%#Eval("MethodValue")%>' fvalue='<%#Eval("ShippingCost")%>'/>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    Delivery Type
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="lblName" runat="server" Text='<%#Eval("MethodName")%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    Cost
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="lbRate" runat="server" Text='<%#Eval("DisplayShippingCost")%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="lblErrmsg" runat="server" Text='<%#Eval("ErrorMessage")%>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </td>
            </tr>
<%--            <tr>
                <td style="text-align: right">
                    <asp:Button ID="btnConfirm" runat="server" Text="Confirm" OnClientClick="return SetFreightOptionAndCost();" />
                </td>
            </tr>--%>
        </table>
        <table id="tbTotalMessage" runat ="server" visible="false">
            <tr style="font-size: 18px">               
                <td>
                   <asp:Label ID="lblResultMessage" runat="server"></asp:Label>
                </td>               
            </tr>         
            <tr>
                <td>
                    <asp:GridView ID="gvTotalMessage" runat="server" AutoGenerateColumns="False">
                        <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>No</HeaderTemplate>
                                <ItemTemplate>
                                     <%#Container.DataItemIndex+1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderStyle Width="250" />
                                <ItemStyle Width="250" HorizontalAlign="Center" />
                                <HeaderTemplate>
                                   Error Details
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="Label1" runat="server"
                                        Text="<%# Container.DataItem %>"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </td>
            </tr>
        </table>

    </div>
</div>

