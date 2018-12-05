<%@ Page Title="B+B eStore order detail" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="OrderDetail.aspx.cs" Inherits="Order_BBOrder_OrderDetail" %>

<%@ Register Src="~/Includes/Order/OrderAddress.ascx" TagName="OrderAddress" TagPrefix="uc1" %>
<%@ Register Src="~/Includes/BB/SAPContactPerson.ascx" TagPrefix="BB" TagName="ContactPerson" %>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        .MyOrderNo {
            font-size: large;
        }
        .MyMessage {
            font-size: large;
            font-weight: bold;
        }
    </style>
    <link href="../../Includes/js/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../Includes/FancyBox/jquery.fancybox.css" rel="Stylesheet" type="text/css" />
    <script type="text/javascript" src="../../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <script type="text/javascript" src="../../Includes/blockUI.js"></script>
    <script type="text/javascript">
        $(function () {
            CheckUseTransfer();
            if ('<%=btnUpdShitpAddr.Visible%>' == 'True') {
                $('#ctl00__main_ShipTo_txtShipToStreet').prop("disabled", false);
            }

            $('#<%=btnConvert.ClientID%>').click(function () {
                $('#<%=lbMsg.ClientID%>').text("");
                var orderNo = $('#<%=lbOrderNo.ClientID%>').text();
                if (orderNo == undefined || orderNo == "") {
                    alert("No order No.");
                    return false;
                }

                $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/SynceStoreOrderToSAP', { OrderNo: orderNo }, function (data) {
                    if (data && data.length > 0) {
                        if (data[0].Result == true) {
                            window.location = "/order/PIV2.aspx?No=" + orderNo + "&BBorder=bb";
                        }
                        else {
                            if (data[0].Message == "") {
                                $('#<%=lbMsg.ClientID%>').text("Sync order to SAP failed. Please refer to the failed order email.");
                            }
                            else {
                                $('#<%=lbMsg.ClientID%>').text(data[0].Message);
                            }
                        }
                    }
                    else {
                        $('#<%=lbMsg.ClientID%>').text("No order No.");
                    }
                });

                return false;
            });

            $('#<%=btnCreateContactPerson.ClientID%>').click(function () {
                ShowFancyBox("ContactPerson");
                return false;
            });
        });

        $(document).ajaxStart(function () {
            $.blockUI({
                message: "Processing...",
                baseZ: 20000
            });
        }).ajaxStop($.unblockUI);

        function ShowFancyBox(div) {
            if (div == "ContactPerson") {
                $("#txtContactEmail").val("");
                $("#txtContactERPID").val("");
                $("#hd").hide();
                $("#bd").hide();
            }

            var gallery = [{
                href: '#' + div
            }];
            $.fancybox(gallery, {
                'autoSize': true,
                'autoCenter': true
            });
        }

        function AssoSiebelSAP(erpid) {
            var orderNo = $('#<%=lbOrderNo.ClientID%>').text();
            if (orderNo != "" && erpid != "") {
                $.fancybox.close();
                $('#<%=lbMsg.ClientID%>').text("");
                $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/AssociateSiebelSAPAccountContact', { OrderNo: orderNo, ERPID: erpid }, function (data) {
                    if (data && data.length > 0) {
                        if (data[0].Result == true) {
                            $('#<%=lbMsg.ClientID%>').text("Success! You can convert this order to SAP.");
                            $('#<%=lbERPID.ClientID%>').text(erpid);
                        }
                        else
                            $('#<%=lbMsg.ClientID%>').text("Link ERP ID failed!");
                        CheckUseTransfer();
                    }
                    else {
                        $('#<%=lbMsg.ClientID%>').text("No order");
                        CheckUseTransfer();
                    }
                });
            }
        }

        function CheckUseTransfer() {
            var erpid = $('#<%=lbERPID.ClientID%>').text();
            if (erpid == "")
                $("#dvConvert").hide();
            else
                $("#dvConvert").show();
        }

        function checkdate(element, id) {
            return true;
        }

        function updateShiptoAddr(element) {
            var contactID = $(element).attr("title");
            var addr = $('#ctl00__main_ShipTo_txtShipToStreet').val();
            var originaddr = $('<%=hfAddress1.ClientID%>').val();
            if (!!contactID) {
                $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/UpdateShipToAddress', { ContactID: contactID, Address: addr }, function (data) {
                    if (!!data) {
                        if (data.Result == true) {
                            alert("Update completed.");
                            $('#<%=lbValidAddr.ClientID%>').text("CCRConfirmed");
                        }
                        else {
                            alert("Failed to update. Message: " + data.Message);
                            $('#ctl00__main_ShipTo_txtShipToStreet').val(originaddr);
                        }
                    }
                    else {
                        alert("Failed to update");
                        $('#ctl00__main_ShipTo_txtShipToStreet').val(originaddr);
                    }
                });
            }
            return false;
        }
    </script>
    <asp:Panel ID="dvMain" runat="server">
        <asp:Panel ID="dvFailedMessage" runat="server" Visible="false">
            <table>
                <tr>
                    <td><asp:Literal ID="ltFailedMessage" runat="server"></asp:Literal></td>
                </tr>
            </table>
        </asp:Panel>
        <div style="display: inline;">
            <table>
                <tr>
                    <td class="menu_title">Order Information</td>
                </tr>
                <tr>
                    <td colspan="2">
                        Order No.:
                        <asp:Label ID="lbOrderNo" runat="server" CssClass="MyOrderNo"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="height: 22px">Sold to</td>
                    <td style="height: 22px">Ship to</td>
                    <td style="height: 22px">Bill to</td>
                </tr>
                <tr>
                    <td>
                        <uc1:OrderAddress ID="SoldTo" runat="server" />
                    </td>
                    <td>
                        <uc1:OrderAddress ID="ShipTo" runat="server" />
                        <div>
                            <asp:Button ID="btnUpdShitpAddr" runat="server" Text="Update address" Visible="false" OnClientClick="return updateShiptoAddr(this);" />
                        </div>
                    </td>
                    <td>
                        <uc1:OrderAddress ID="BillTo" runat="server" />
                    </td>
                </tr>
            </table>
        </div>
        <br />
        <div style="display: inline;">
            <asp:Repeater ID="rpOrderDetail" runat="server">
                <HeaderTemplate>
                    <table>
                        <tr>
                            <td class="menu_title">Order Detail</td>
                        </tr>
                    </table>
                    <table>
                        <thead>
                            <tr>
                                <th>Line No</th>
                                <th>Part No</th>
                                <th>Display Name</th>
                                <th style="max-width: 30px;">Description</th>
                                <th>Unit Price</th>
                                <th>Qty</th>
                                <th>Sub Total</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td align="center">
                            <%#Eval("ItemNo") %>
                        </td>
                        <td>
                            <%#Eval("SProductID") %>
                        </td>
                        <td>
                            <%#Eval("ProductName") %>
                        </td>
                        <td>
                            <%#Eval("Description") %>
                        </td>
                        <td align="center">
                            <%#Eval("UnitPriceX") %>
                        </td>
                        <td align="center">
                            <%#Eval("Qty") %>
                        </td>
                        <td align="center">
                            <%#Eval("AdjustedPriceX") %>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                </FooterTemplate>
            </asp:Repeater>
            <table>
                <tbody>
                    <tr>
                        <td>Customer Comment</td>
                        <td>
                            <asp:TextBox ID="txtCustComm" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td></td>
                    </tr>
                    <tr>
                        <td>Resale</td>
                        <td>
                            <asp:RadioButtonList ID="rbResale" runat="server" Enabled="false">
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                    </tr>
                    <tr id="trResaleID" runat="server">
                        <td>Resale ID</td>
                        <td><asp:Label ID="lbResaleID" runat="server" ForeColor="Tomato"></asp:Label></td>
                    </tr>
                    <tr id="trResaleDocURL" runat="server">
                        <td>Resale certificate</td>
                        <td><asp:HyperLink ID="hlResaleCer" runat="server" Text="Link" Target="_blank"></asp:HyperLink></td>
                    </tr>
                    <tr>
                        <td>PO No.</td>
                        <td>
                            <asp:Label ID="lbPoNo" runat="server"></asp:Label></td>
                    </tr>
                    <tr>
                        <td>Freight</td>
                        <td>
                            <asp:Label ID="lbFreight" runat="server"></asp:Label></td>
                    </tr>
                    <tr>
                        <td>Shipping method</td>
                        <td>
                            <asp:Label ID="lbShippingMethod" runat="server"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>Tax</td>
                        <td>
                            <asp:Label ID="lbTax" runat="server"></asp:Label></td>
                    </tr>
                    <tr>
                        <td>Tax Rate</td>
                        <td>
                            <asp:Label ID="lbTaxRate" runat="server"></asp:Label></td>
                    </tr>
<%--                    <tr>
                        <td>Total Discount</td>
                        <td></td>
                    </tr>--%>
                    <tr>
                        <td>Total Amount</td>
                        <td>
                            <asp:Label ID="lbTotalAmount" runat="server"></asp:Label></td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div style="height: 20px;">
        </div>
        <asp:Panel ID="dvValidShipToAddr" runat="server" CssClass="MyMessage" Visible="false">
            Ship to address: &nbsp;<asp:Label ID="lbValidAddr" runat="server" ForeColor="Tomato"></asp:Label>
        </asp:Panel>
        <div style="height: 20px;">
        </div>
        <div class="MyMessage">
            This customer's email address is: &nbsp;<asp:Label ID="lbEmail" runat="server" ForeColor="Tomato"></asp:Label>
        </div>
        <div style="height: 20px;">
        </div>
        <div class="MyMessage">
            This customer's Sold to ID is: &nbsp;<asp:Label ID="lbERPID" runat="server" ForeColor="Tomato"></asp:Label>
        </div>
        <div style="height: 20px;">
        </div>
        <div>
            <table>
                <tr>
                    <td>
                        <asp:Button ID="btnBackToOrderList" runat="server" Text="Back to order list" OnClick="btnBackToOrderList_Click" Height="40px" Width="155px" />&nbsp;&nbsp;
                    </td>
                    <td>
                        <asp:Button ID="btnCreateNewSAPaccount" runat="server" Text="Create New SAP account" OnClick="btnCreateNewSAPaccount_Click" Height="40px" Width="215px" />&nbsp;&nbsp;
                    </td>
                    <td>
                        <asp:Button ID="btnCreateContactPerson" runat="server" Text="Pick SAP account" Height="40px" Width="150px" />&nbsp;&nbsp;
                    </td>
                    <td>
                        <div id="dvConvert">
                            <asp:Button ID="btnConvert" runat="server" Text="Convert to SAP" Height="40px" Width="140px" />
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel>
    <div style="height: 20px;">
    </div>
    <div style="font-size:large; font-weight:bold;">
        <asp:Label ID="lbMsg" runat="server" ForeColor="Tomato"></asp:Label>
    </div>
    <div style="height: 20px;">
    </div>
    <div id="ContactPerson" style="display: none;">
        <BB:ContactPerson ID="CP" runat="server" />
    </div>
    <asp:HiddenField ID="hfAddress1" runat="server" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

