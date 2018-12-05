<%@ Page Title="Capture Credit Card Orders" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="CaptureCreditCardOrders.aspx.cs" Inherits="Order_BBOrder_OrderList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link href="../../Includes/js/jquery-ui.css" rel="stylesheet" />
    <link href="../../Includes/FancyBox/jquery.fancybox.css" rel="Stylesheet" type="text/css" />
    <script type="text/javascript" src="../../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="../../EC/Includes/json2.js"></script>
    <script type="text/javascript" src="../../Includes/blockUI.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <style type="text/css">
        .button {width:100%}
        .batchCaptureButton {
            float: right;
        }
        .invoiceDetai {
            display: none;
        }
        .filterPanel {
            margin-top: 10px;
            border: 1px solid #DCDCDC;
            padding: 5px;
        }
        .filterPanel tr { line-height: 24px; }
        .pageTitleWord {
            font-size:14px; 
            color:#F29803; 
            font-weight:bold; 
            font-family:Arial, Helvetica, sans-serif ;
        
        }
        #captureResultArea
        {
            margin-bottom:15px;
        }

        #invOrderLoading {
            opacity:0.8;      
            position:fixed;
            width:100%;
            height:100%;
            top:0px;
            left:0px;
            z-index:1000;
            display: none;
            
        }

        .waitingWord {
            position: absolute;
            top: 55%;
            left: 47%;
            font-weight: bold;
        }

        .div-table {
          /*display: table;*/         
          width: auto;         
          background-color: #eee;                
          border-spacing: 5px; /* cellspacing:poor IE support for  this */
        }
        
        .div-table-head {
          float: left; /* fix for  buggy browsers */
          display: table-column;                
          text-align:center;
        }
        .div-table-row {
          display: table-row;
          width: auto;
          clear: both;
          
        }
        .div-table-col {
          float: left; /* fix for  buggy browsers */
          display: table-column;             
          text-align:center;
        }
    </style>
    <div>
        <table>
            <tr>
                <td>
                    <img alt="" src="../../images/point.gif" width="7" height="14" />
                </td>
                <td>
                    <h2 class="pageTitleWord">Capture amount for credit card orders</h2>
                </td>
            </tr>
        </table>
        <div class="filterPanel">    
            <table>
            <tr>
                <td>Order No:</td>
                <td><input type="text" id="text_SoNO" value="" size="10"  /> </td>
                <td>Invoice No:</td>
                <td><input type="text" id="text_InvNO" value="" size="10"  /> </td>
<%--                <td>DN No:</td>
                <td><input type="text" id="text_DnNO" value="" size="10"  /> </td>
                <td>PO No:</td>
                <td><input type="text" id="text_PONO" value="" size="10"  /> </td>--%>
            </tr>
<%--            <tr class="date_type">
                <td>Order Status:</td>
                <td>
                    <input id="isInvoicedOrderRadio" type="radio" name="radio" value="true"><label for="isInvoicedOrderRadi">Invoiced Orders</label>
                    <input id="allOrderRadio" type="radio" name="radio" value="false"  checked="checked"><label for="allOrderRadio">All Orders</label>
                </td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>--%>
            <tr>
                 <td>Invoiced Date Range:</td>
                <td>
                    <asp:TextBox ID="txtinvdate_from" runat="server" Width="76px" Text="<%#DateTime.Now.ToShortDateString() %>"></asp:TextBox>&nbsp;~&nbsp;
                    <asp:TextBox ID="txtinvdate_to" runat="server" Width="76px" Text="<%#DateTime.Now.ToShortDateString() %>"></asp:TextBox>
                    <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtinvdate_from"
                        Format="yyyy/MM/dd" />
                    <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtinvdate_to"
                        Format="yyyy/MM/dd" />
                </td>
            </tr>

            <tr>
                <td>
                    <button id="btn-search" type="button">Search</button>
                </td>
            </tr>
        </table>
        </div>
        <div id="captureResultArea"></div>
        <button type='button' id="batchCaptureButton" class='batchCaptureButton'>Capture amount for checked invoices</button>
        <table style="width: 900px;">
            <tr>
                <td>
                    <table style="border: 1px; width: 900px" id="table_OrderList">
                        <thead>
                            <tr style="color: white; background-color: grey">                              
                                <th style="width: 10px">
                                    Select
                                    <input type='checkbox' id="checkAllOrder2"/>
                                </th>
                                <th style="width: 70px">Invoice No.</th>
                                <th style="width: 60px">Order No.</th>
                                <th style="width: 40px">PO No.</th>
                                <th style="width: 70px">Invoiced Date</th>
                                <th style="width: 65px">Customer</th>
                                <th style="width: 40px">Card Number</th>
<%--                                <th style="width: 390px;">Invoce Detail
                                    <div class='div-table'>
	                                    <div class='div-table-row' style='font-weight: bold;'>
		                                    <div class='div-table-head' style='width:15px;'>Line</div>
		                                    <div class='div-table-head' style='width:110px;'>PartNo</div>
		                                    <div class='div-table-head' style='width:40px;'>Qty</div>
		                                    <div class='div-table-head' style='width:35px;'>Total</div>
	                                    </div>
                                    </div>
                                </th>--%>
                                <th style="width: 30px">Card Type</th>
                                <th style="width: 30px;">Invoiced Amount</th>
                                <th style="width: 30px;">Auth Amount</th>
                                <th style="width: 60px">Transaction Status</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </td>
            </tr>
        </table>
    </div>

    <div id="invOrderLoading" style="background:url(/Images/loading.gif) no-repeat center center; background-color: white;"><div class="waitingWord">Please wait...</div></div>
    
    <script type="text/javascript">
        $(document).ready(function () {
            
            //$loading = $(".invOrderLoading");
            
            GetBBCreditCardOrder();
            //$loading.hide();

            $("#checkAllOrder2").click(function () {
                $('input:checkbox').not(this).prop('checked', this.checked);
            });
            
        });

        $("#btn-search").on("click", function () {
            
            $("#captureResultArea").empty();
            GetBBCreditCardOrder();
             
                       
        });

        $("#batchCaptureButton").on("click", function () {
            if (confirm("Are you sure to capture these authorized orders?") == true) {
                CaptureAuthorizedOrder();
            }
        });

        function GetBBCreditCardOrder()
        {
            
            $("#invOrderLoading").show();
            $('#table_OrderList tbody').empty();
            $invNo = $("#text_InvNO").val();
            $soNo = $("#text_SoNO").val();
            //$dnNo = $("#text_DnNO").val();
            //$poNo = $("#text_PONO").val();
            $dnNo = '';
            $poNo = '';
            dateFrom = $('#<%=txtinvdate_from.ClientID %>').val();
            dateTo = $('#<%=txtinvdate_to.ClientID %>').val();
            //$isOnlyInvOrders = $(".date_type  input[type='radio']:checked").val();
            $isOnlyInvOrders = true;
            var postData = {
                invNo: $invNo, soNo: $soNo, dnNo: $dnNo, poNo: $poNo, org: 'US10', dateFrom: dateFrom, dateTo: dateTo, onlyInvoicedOrders: $isOnlyInvOrders, isCaptured: false, rowCount: 500
            };

            //Invoiced Oreder(payment term = CODC) List:
            $.ajax({
                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/GetBBCreditCardOrder',
                    type: "POST",
                    dataType: "json",
                    async: true,
                    data: postData,
                    success: function (retData) {
                        $("#invOrderLoading").hide();
                        if (retData && retData.length > 0) {
                            
                            for (var i = 0; i < retData.length; i++) 
                            {

                                $('#table_OrderList tbody').append("<tr>");
                                if (retData[i].TransactionStatus != 'Already Captured') {
                                    if (retData[i].InvoicedAmount) {
                                        $('#table_OrderList tbody').append("<td style='width:10px; text-align: center;'><input type='checkbox' name='locationthemes' orderNo='" + retData[i].OrderNo + "'  tranId='" + retData[i].TransactionId + "' captureAmount='" + retData[i].InvoicedAmount + "'/></td>");
                                    } else {
                                        $('#table_OrderList tbody').append("<td style='width:10px color:red'>No Auth Amount</td>");
                                    }
                                } else {
                                    $('#table_OrderList tbody').append("<td style='width:10px'></td>");
                                }

                                $('#table_OrderList tbody').append("<td style='width:70px'>" + retData[i].InvoiceNo.substring(2) + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:60px'>" + retData[i].OrderNo + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:40px'>" + retData[i].PoNo + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:70px'>" + retData[i].InvoicedDate + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:65px'>" + retData[i].Customer + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:40px'>" + retData[i].CreditCardNumber + "</td>");

                                //if (retData[i].InvoiceOrderDetail && retData[i].InvoiceOrderDetail.length > 0) {
                                //    var details = "<div class='div-table'>";
                                //    for (var j = 0; j < retData[i].InvoiceOrderDetail.length; j++) {
                                //        details += "<div class='div-table-row'>";
                                //        details += "<div class='div-table-col'  style='width:25px;'>" + retData[i].InvoiceOrderDetail[j].LineNo + "</div>";
                                //        details += "<div class='div-table-col'  style='width:110px;'>" + retData[i].InvoiceOrderDetail[j].PartNo + "</div>";
                                //        details += "<div class='div-table-col' style='width:40px;'>" + retData[i].InvoiceOrderDetail[j].InvoiceQty + "</div>";
                                //        details += "<div class='div-table-col' style='width:35px;'>$" + retData[i].InvoiceOrderDetail[j].SubTotal + "</div>";
                                //        details += "</div>";
                                //    }
                                //    details += "</div>";
                                //    $('#table_OrderList tbody').append("<td style='width: 390px;'>" + details + "</td>");
                                //}else {
                                //    $('#table_OrderList tbody').append("<td style='width: 390px;'>Not yet invoiced.</td>");
                                //}
                                
                                //$('#table_OrderList tbody').append("<td style='width:200px; display:none;'>" + retData[i].TransactionId + "</td>");
                                //$('#table_OrderList tbody').append("<td style='width:100px; display:none;'>" + retData[i].AuthCode + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:30px text-align:center;'>" + retData[i].CardType + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:30px text-align:center;'>$" + retData[i].InvoicedAmount + "</td>");

                                $('#table_OrderList tbody').append("<td style='width:30px text-align:center;'>$" + retData[i].AuthorizedAmount + "</td>");
                                //$('#table_OrderList tbody').append("<td style='width:100px;  display:none;'>" + retData[i].AuthorizedDate + "</td>");
                                $('#table_OrderList tbody').append("<td style='width:60px; text-align:center;'>" + retData[i].TransactionStatus + "</td>");
                                //if (retData[i].TransactionStatus != 'Already Captured') {
                                //    $('#table_OrderList tbody').append("<td style='width:100px'><button type='button' class='button capture' orderNo='" + retData[i].OrderNo + "' tranId='" + retData[i].TransactionId + "' authAmount='" + retData[i].AuthorizedAmount + "'>Capture</button></td>");
                                //} else {
                                //    $('#table_OrderList tbody').append("<td style='width:100px'></td>");

                                //}
                                $('#table_OrderList tbody').append("</tr>");
                            }
                    
                        }


                    },
                    error: function (msg) {
                        $("#invOrderLoading").hide();
                        //$loading.hide();
                        //AlertDialog("call getOrderList err:" + msg.d);
                    },
                    complete: function () {
                        $("#invOrderLoading").hide();
                    }
            });
            
        }

        function CaptureAuthorizedOrder()
        {
            $("#invOrderLoading").show();
            selectedOrders = new Array();
            $('input[name="locationthemes"]:checked').each(function () {
                orderNo = $(this).attr('orderNo');
                tranId = $(this).attr('tranId');
                captureAmount = $(this).attr('captureAmount');
                selectedOrders.push({
                    OrderNo: orderNo,
                    TransactionId: tranId,
                    CaptureAmount: captureAmount
                });
            });

                var postData = {
                    selectedCapturedItems: JSON.stringify(selectedOrders)
                };
                //Invoiced Oreder(payment term = CODC) List:
                $.ajax({
                    url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/CaptureBBCreditCardAuthorizedOrder',
                        type: "POST",
                        dataType: "json",
                        async: true,
                        data: postData,
                        success: function (retData) {
                            $("#invOrderLoading").hide();
                            if (retData && retData.length > 0) {
                                var resultMessages = "<b>Capture Result:</b><br/>";
                                $('#table_OrderList tbody').empty();
                                for (var i = 0; i < retData.length; i++) {
                                    if (retData[i].Result != "Success") {
                                        result = "<font color='red'>" + retData[i].Result + "</font>";
                                    }
                                    else {
                                        result = "<font color='blue'>" + retData[i].Result + "</font>";
                                    }

                                    resultMessages += retData[i].OrderNo + ": " + result + " (" + retData[i].Message + ")<br/>";
                                }
                                $('#captureResultArea').html(resultMessages);

                                $isOnlyInvOrders = true;
                                dateFrom = $('#<%= txtinvdate_from.ClientID %>').val();
                                dateTo = $('#<%= txtinvdate_to.ClientID %>').val();
                                GetBBCreditCardOrder("", "", "", "", "US10", dateFrom, dateTo, $isOnlyInvOrders, false, 100);

                            }
                        },
                        error: function (msg) {
                            $("#invOrderLoading").hide();
                            //$loading.hide();
                            //AlertDialog("call getOrderList err:" + msg.d);
                        },
                        complete: function () {
                            //$("#invOrderLoading").hide();
                        }
                });

        }


    </script>
</asp:Content>



