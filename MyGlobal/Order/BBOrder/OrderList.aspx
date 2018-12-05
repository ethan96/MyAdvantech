<%@ Page Title="B+B eStore order list" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="OrderList.aspx.cs" Inherits="Order_BBOrder_OrderList" %>

<%@ Register Src="~/Includes/BB/SAPContactPerson.ascx" TagPrefix="BB" TagName="ContactPerson" %>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link href="../../Includes/js/jquery-ui.css" rel="stylesheet" type="text/css" />
    <link href="../../Includes/FancyBox/jquery.fancybox.css" rel="Stylesheet" type="text/css" />
    <script type="text/javascript" src="../../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="../../EC/Includes/json2.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <script type="text/javascript" src="../../Includes/blockUI.js"></script>
    <style type="text/css">
        .button {
            width: 100%;
        }
    </style>
    <script type="text/javascript">
        function GeteStoreOrder() {
            $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/GetBBorder', { Email: $("#txtEmail").val(), OrderNo: $("#txtOrderNo").val(), OrderStatus: $('#<%=ddlStatus.ClientID%>').val() }, function (data) {
                if (data && data.length > 0) {
                    var html = "";
                    for (var i = 0; i < data.length; i++) {
                        var em = "";
                        if (data[i].Emergency == true) em = " style='Color: #FF0000; font-weight: bold;'";
                        html += "<tr" + em + "><td style='width:120px'>" + data[i].OrderDate + "</td>";
                        html += "<td style='width:150px;text-align: center;'>" + data[i].OrderNo + "</td>";
                        html += "<td style='width:120px;text-align: center;'>" + data[i].ERPID + "</td>";
                        html += "<td style='width:250px'>" + data[i].UserID + "</td>";

                        if (data[i].SAPSyncStatus == "FailedToSAP" || data[i].SAPSyncStatus == "ToBeVerifiedShipToAddr")
                            html += "<td style='width:100px;text-align: center;'><a href='/Order/BBorder/OrderDetail.aspx?OrderNo=" + data[i].OrderNo + "' title='View deatil message' >" + data[i].SAPSyncStatus + "</a></td>";
                        else
                            html += "<td style='width:100px;text-align: center;'>" + data[i].SAPSyncStatus + "</td>";

                        if (data[i].SAPSyncStatus == "NeedERPID" || data[i].SAPSyncStatus == "ToBeVerifiedShipToAddr")
                            html += "<td></td>";
                        else
                            html += "<td style='text-align: center;'><button class='syncorder' type='button' data-order='" + data[i].OrderNo + "' onclick='SynceStoreOrderToSAP(this);'>Convert</button></td>";
                        html += "<td style='width:100px' align='center'><a href='/Order/BBorder/OrderDetail.aspx?OrderNo=" + data[i].OrderNo + "' >Detail</a></td></tr>";
                    }
                    $("#mylist").html(html);
                }
                else
                    $("#mylist").html("");
            });
        }

        function SynceStoreOrderToSAP(btn) {
            var orderNo = $(btn).attr("data-order");
            if (orderNo == undefined || orderNo == "") {
                alert("No order No.");
                return false;
            }

            $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/SynceStoreOrderToSAP', { OrderNo: orderNo }, function (data) {
                if (data && data.length > 0) {
                    if (data[0].Result == true) {
                        //alert("Success");
                        //GeteStoreOrder();
                        window.location = "/order/PIV2.aspx?No=" + orderNo + "&BBorder=bb";
                    }
                    else {
                        alert("Failed! " + data[0].Message);
                    }
                }
                else {
                    alert("No order No.");
                }
            });

            return false;
        }

        $(document).ajaxStart(function () {
            $.blockUI({
                message: "Processing..."
            });
        }).ajaxStop($.unblockUI);

        $(function () {
            GeteStoreOrder();

            $("#btnSearch").click(function () {
                GeteStoreOrder();
            });
        });

    </script>
    <div>
        <table style="width: 100%;">
            <tr>
                <td style="width: 10%;">Customer Email:</td>
                <td style="width: 30%;">
                    <input type="text" id="txtEmail" size="30" />
                </td>
                <td style="width: 10%;">Order No.:</td>
                <td style="width: 30%;">
                    <input type="text" id="txtOrderNo" size="20" /></td>
            </tr>
            <tr>
                <td style="width: 10%;">Order status:</td>
                <td style="width: 20%;">
                    <asp:DropDownList ID="ddlStatus" runat="server"></asp:DropDownList></td>
                <td style="width: 10%;"></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="4">
                    <button id="btnSearch" type="button">Search</button>
                </td>
            </tr>
        </table>
        <table style="width: 900px;">
            <tr>
                <td>
                    <table style="border: 1px; width: 900px" id="table_OrderList">
                        <thead>
                            <tr style="color: white; background-color: grey">
                                <th style="width: 90px">Order Date</th>
                                <th style="width: 120px">Order Number</th>
                                <th style="width: 100px">ERP ID</th>
                                <th style="width: 200px">Email</th>
                                <th style="width: 100px">Status</th>
                                <%--<th style="width: 90px">Pick SAP account</th>--%>
                                <th style="width: 90px">Convert to SAP</th>
                                <th style="width: 80px">Detail</th>
                            </tr>
                        </thead>
                        <tbody id="mylist"></tbody>
                    </table>
                </td>
            </tr>
<%--            <tr>
                <td>
                    <div style="width: 900px; height: 220px; overflow-x: hidden; overflow-y: auto;">
                        <table id="table_OrderList1"  style="border: 1px; width: 900px; font-size: 12px;">
                            <tbody></tbody>
                        </table>
                    </div>
                </td>
            </tr>--%>
        </table>
    </div>
    <div id="ContactPerson" style="display: none;">
        <BB:ContactPerson ID="CP" runat="server" Visible="false" />
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

