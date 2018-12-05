<%@ Page Title="Capture Credit Card Orders" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="AuthCreditCard.aspx.cs" Inherits="Order_BBOrder_OrderList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link href="../../Includes/js/jquery-ui.css" rel="stylesheet" />
    <link href="../../Includes/FancyBox/jquery.fancybox.css" rel="Stylesheet" type="text/css" />
    <script type="text/javascript" src="../../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="../../EC/Includes/json2.js"></script>
    <script type="text/javascript" src="../../Includes/blockUI.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <style type="text/css">

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
        #authResultArea
        {
            margin-bottom:15px;
        }

        #authloading {
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

        .billToArea {
            display:none;
        }

        label.required::before {
          content: '*';
          margin-right: 4px;
          color: red;
        }
    </style>
    <div>
        <table>
            <tr>
                <td>
                    <img alt="" src="../../images/point.gif" width="7" height="14" />
                </td>
                <td>
                    <h2 class="pageTitleWord">Auth amount for credit card order</h2>
                </td>
            </tr>
        </table>
        <div class="filterPanel">    
            <table>
                <thead>
                    <tr>
                        <td></td>
                        <td style="width:250px;"></td>
                        <td style="width:150px;"></td>
                        <td></td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <label class="required">
                                Order No:
                            </label>
                        </td>
                        <td><input type="text" id="text_OrderNO" value="" size="10"  /> </td>
                    </tr>
                    <tr>
                        <td>
                            <label class="required">
                                Credit Type:
                            </label>
                        </td>
                        <td>
                            <asp:DropDownList runat="server" ID="text_CC_Type">
                                <asp:ListItem Value="AMEX" Text="American Express" />
                                <asp:ListItem Value="DISC" Text="Discover" />
                                <asp:ListItem Value="MC" Text="Master -/Euro Card" />
                                <asp:ListItem Value="VISA" Text="Visa Card" />
                            </asp:DropDownList>
                        </td>
                        <td>
                            <label class="required">
                                Credit Card Number:
                            </label>
                        </td>
                        <td><input type="text" id="text_CC_Number" value="" size="20"  /> </td>
                    </tr>
                    <tr>
                        <td>
                            <label class="required">
                                Card Holder:
                            </label>
                        </td>
                        <td><input type="text" id="text_CC_holder" value="" size="10"  /> </td>
                        <td>
                            <label class="required">
                                Expired Date:
                            </label>
                        </td>
                        <td>
                            <asp:DropDownList runat="server" ID="dlCCardExpYear" />
                            <asp:DropDownList runat="server" ID="dlCCardExpMonth">
                                <asp:ListItem Text="January" Value="1" />
                                <asp:ListItem Text="February" Value="2" />
                                <asp:ListItem Text="March" Value="3" />
                                <asp:ListItem Text="April" Value="4" />
                                <asp:ListItem Text="May" Value="5" />
                                <asp:ListItem Text="June" Value="6" />
                                <asp:ListItem Text="July" Value="7" />
                                <asp:ListItem Text="August" Value="8" />
                                <asp:ListItem Text="September" Value="9" />
                                <asp:ListItem Text="October" Value="10" />
                                <asp:ListItem Text="November" Value="11" />
                                <asp:ListItem Text="December" Value="12" />
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <label class="required">
                                CVV Code:
                            </label>
                        </td>
                        <td><input type="text" id="text_CVV" value="" size="10"  /> </td>
                    </tr>
                    <tr>
                        <td>
                            <label class="required">
                                Total Authorized Amount:
                            </label>
                        </td>
                        <td><input type="text" id="text_AuthAmount" value="" size="10"  /> </td>
                    </tr>
                    <tr>
                        <td>
                            <input type="checkbox" id="ckBillTo" /> Fill bill to
                        </td>
                    </tr>
                    <tr class="billToArea">
                        <td>Street:</td>
                        <td><input type="text" id="text_Street" value="" size="20"  /> </td>
                        <td>City:</td>
                        <td><input type="text" id="text_City" value="" size="10"  /> </td>
                    </tr>
                    <tr class="billToArea">
                        <td>State:</td>
                        <td><input type="text" id="text_State" value="" size="20"  /> </td>
                        <td>ZipCode:</td>
                        <td><input type="text" id="text_ZipCode" value="" size="10"  /> </td>
                    </tr>
                    <tr class="billToArea">
                        <td>Country:</td>
                        <td><input type="text" id="text_Country" value="" size="20"  /> </td>
                    </tr>
                    <tr>
                        <td>
                            <button type='button' id="authButton" class='authButton'>Authorize CreditCard Amount</button>
                        </td>
                    </tr>
                </tbody>

            </table>
        </div>

        <div id="authResultArea"></div>

    </div>

    <div id="authloading" style="background:url(/Images/loading.gif) no-repeat center center; background-color: white;"><div class="waitingWord">Please wait...</div></div>
    
    <script type="text/javascript">
        $(document).ready(function () {           
        });

        $('#ckBillTo').click(function () {
            IsShowNewBillTo();
        });

        function IsShowNewBillTo() {
            if ($('#ckBillTo').is(':checked')) {
                $(".billToArea").show();
            } else {
                $(".billToArea").hide();
            }
        }

        $("#authButton").on("click", function () {
            if (confirm("Are you sure to authorize these orders?") == true) {
                orderNo = $('#text_OrderNO').val();
                cardType = $('#<%=text_CC_Type.ClientID%> option:selected').val();
                cardNumber = $('#text_CC_Number').val();
                expDate = $('#<%=dlCCardExpYear.ClientID%> option:selected').val() + "-" + $('#<%=dlCCardExpMonth.ClientID%> option:selected').val();
                cvv = $('#text_CVV').val();
                cardHolder = $('#text_CC_holder').val();
                authAmount = $('#text_AuthAmount').val();
                street = "";
                city = "";
                state = "";
                zipcode = "";
                country = ""
                if ($('#ckBillTo').is(':checked')) {
                    street = $('#text_Street').val(),
                    city = $('#text_City').val(),
                    state = $('#text_State').val(),
                    zipcode = $('#text_ZipCode').val(),
                    country = $('#text_Country').val()
                }
                if (validateForm(orderNo, cardType, cardNumber, expDate, cvv, cardHolder, authAmount)) {
                    $('#authResultArea').empty();

                    AuthorizedAmount(orderNo, cardType, cardNumber, expDate, cvv, cardHolder, authAmount, street, city, state, zipcode, country);
                }
            }
        });
        function validateForm(orderNo, cardType, cardNumber, expDate, cvv, cardHolder, authAmount) {
            if (orderNo == null || orderNo == "", cardType == null || cardType == "",
                cardNumber == null || cardNumber == "", expDate == null || expDate == "",
                cvv == null || cvv == "", cardHolder == null || cardHolder == "", authAmount == null || authAmount == "") {
                alert("Please Fill All Required Field");
                return false;
            }
            return true;
        }
        function AuthorizedAmount(orderNo, cardType, cardNumber, expDate, cvv, cardHolder, authAmount, billToStreet, billToCity, billToState, billToZipCode, billToCountry)
        {
            $("#authloading").show();

            var postData = {
                orderNo: orderNo,
                cardType: cardType,
                cardNumber: cardNumber,
                expDate: expDate,
                cvv: cvv,
                cardHolder: cardHolder,
                authAmount: authAmount,
                billToStreet: billToStreet,
                billToCity: billToCity,
                billToState: billToState,
                billToZipCode: billToZipCode,
                billToCountry: billToCountry
            };
            //Invoiced Oreder(payment term = CODC) List:
            $.ajax({
                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/AuthorizeBBCreditCardOrder',
                    type: "POST",
                    dataType: "json",
                    async: true,
                    data: postData,
                    success: function (retData) {
                        $("#invOrderLoading").hide();
                        if (retData && retData.length > 0) {
                            var resultMessages = "<b>Authorization Result:</b><br/>";

                            for (var i = 0; i < retData.length; i++) {
                                var result = '';
                                if (retData[i].Result != "Success") {
                                    result = "<font color='red'>" + retData[i].Result + "</font>";                                    
                                }
                                else
                                {
                                    result = "<font color='blue'>" + retData[i].Result + "</font>";
                                }
                                resultMessages += "Order No:" + retData[i].OrderNo + "<br/>Result: " + result + "<br/>Message: " + retData[i].Message
                                    + "<br/>Transaction Id:" + retData[i].TransactionId + " </br>AuthCode:" + retData[i].AuthCode;
                                if (retData[i].Result == "Success") {
                                    resultMessages += "<br/><font color='blue'>Pleae manually insert above transaction ID, Auth Code and Auth Amount to " + retData[i].OrderNo + "'s payment cards table in SAP.</font>";
                                }

                            }

                            $('#authResultArea').html(resultMessages);

                        }
                        else
                        {
                            $('#authResultArea').html("No authorization results");
                        }
                    },
                    error: function (msg) {
                        $("#authloading").hide();
                        $('#authResultArea').html(msg);
                    },
                    complete: function () {
                        $("#authloading").hide();
                    }
            });
        }

    </script>
</asp:Content>



