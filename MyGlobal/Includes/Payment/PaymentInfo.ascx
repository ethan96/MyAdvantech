<%@ Control Language="C#" AutoEventWireup="true" CodeFile="PaymentInfo.ascx.cs" Inherits="Includes_Payment_PaymentInfol" %>
<%@ Register Src="~/Includes/Order/OrderAddress.ascx" TagName="OrderAddress" TagPrefix="uc1" %>

<style>
    .creditCard_info {
        margin-top:20px;
    }

    .creditCard_info table
    {
        width: 100%;
        border-collapse: collapse;
    }
        
    .creditCard_info tr td
    {
        background: #ffffff;
        border: #cccccc 1px solid;
        padding: 2px;
        font-family: Arial;
        font-size: 12px;
    }
    .fillCreditCard {
        margin-top:20px;
        margin-bottom: 30px;
    }

    .fillCreditCard .fillCreditCardTb
    {
        width: 100%;
        border: 1px solid #cccccc;
    }
        
    .fillCreditCard tr td
    {
        background: #ffffff;
        padding: 2px;
        font-family: Arial;
        font-size: 12px;
    }

    .newbilladdress {
        display:none;
    }

    .CCnewBillTo {
        display:none;
    }
</style>
<uc1:OrderAddress ID="billto" runat="server" Type="B_CC" Visible="false" />

<div id="payment_validate_result" runat="server" visible="false">
    <table  width="95%" runat="server" id="trAuthInfoV2" style="border-style:double" align="center">
        <thead>
            <tr>
                <th colspan="2">Verification Result</th>
            </tr>
            <tr>
                <th align="left">
                    Result:
                </th>
                <td>
                    <asp:Label runat="server" ID="lblResult" Width="150px" Font-Bold="True" />
                </td>
                <th align="left" runat="server" id="td1" Visible="false" >
                    TranscationID:
                </th>
                <td runat="server" id="td2">
                    <asp:Label runat="server" ID="lblTransactionID" Width="150px" Visible="false" />
                </td>
            </tr>
            <tr>
                <th align="left">
                    Response Message:
                </th>
                <td>
                    <asp:Label runat="server" ID="lblResponseMessage" Font-Bold="True" />
                </td>
            </tr>
            <tr>
                <th align="left">
                    Authentication Code:
                </th>
                <td>
                    <asp:Label runat="server" ID="lblAuthCode" Width="150px" />
                </td>
            </tr>
        </thead>

    </table>
</div>

<div id="creditCard_info" class="creditCard_info" runat="server" visible="false">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td style="background-color: #ededed; font-weight: bold" colspan="4">                
                Credit Card Information
<%--                <span style="color: red; font-weight: bold"> (Credit card would be authorized after confirming order, pleasae check again.)</span>--%>
            </td>
        </tr>
        <tr>
            <td width="125">
                CardType
            </td>
            <td colspan="2" class="CreditCardType">
                <asp:Label ID="lblcardtype" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                CardNumber
            </td>
            <td colspan="2">
                <asp:Label ID="lblCardNumber" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Cardholder
            </td>
            <td colspan="2">
                <asp:Label ID="lblCardholder" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Card Expiration Date
            </td>
            <td colspan="2">
                <asp:Label ID="lblCardExpirationDate" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Security Code
            </td>
            <td colspan="2">
                <asp:Label ID="lblCVV2" runat="server"></asp:Label>
            </td>
        </tr>
    </table>
</div>

<div id="fillCreditCard" class="fillCreditCard" runat="server">
    <table align="left" cellpadding="0" class="fillCreditCardTb" cellspacing="0" runat="server" id="tbCreditCardInfo">
        <tr>
            <td style="background-color: #ededed; font-weight: bold; color:blue; padding: 3PX;" colspan="4">                
                Please Fill Credit Card Information <span style="color:black">(Payment Term: CODC)</span>
            </td>
            <td style="background-color: #ededed;"></td>
            <td style="background-color: #ededed;"></td>
            <td style="background-color: #ededed;"></td>
            <td style="background-color: #ededed;"></td>
        </tr>
        <tr>
            <td  class="h5" align="left">Card Type:
            </td>
            <td>
                <asp:DropDownList runat="server" ID="dlCCardType">
                    <asp:ListItem Value="AMEX" Text="American Express" />
                    <asp:ListItem Value="DISC" Text="Discover" />
                    <asp:ListItem Value="MC" Text="Master -/Euro Card" />
                    <asp:ListItem Value="VISA" Text="Visa Card" />
                </asp:DropDownList>
            </td>
            <td class="h5" >Card Number:
            </td>
            <td style="padding-left: 5px;">
                <asp:TextBox runat="server" ID="txtCreditCardNumber" />
            </td>
            <td class="h5" align="left">CVV Code:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCCardVerifyValue" Width="45"/>
            </td>
        </tr>
        <tr>
            <td class="h5" align="left">Holder's Name:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCCardHolder" />
            </td>
            <td class="h5" align="left">Expire Date:
            </td>
            <td  style="padding-left: 5px;">
                <table>
                    <tr>
                        <td>
                            <asp:DropDownList runat="server" ID="dlCCardExpYear" />
                        </td>
                        <td>
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
                </table>
            </td>
            <td></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td>
                <asp:CheckBox runat="server" ID="ckbUserNewBillAddress"  Text="Use New Bill Address"/>
            </td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>
        <tr class="CCnewBillTo">
            <td class="h5" align="left">Street1:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtNewBillStreet" />
            </td>
            <td class="h5" align="left">Street2:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtNewBillStreet2" />
            </td>  
            <td class="h5" align="left">Country:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtNewBillCountry" Width="45"/>
            </td>                            
        </tr>
        <tr class="CCnewBillTo">
            <td class="h5" align="left">City:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtNewBillCity" />
            </td>
            <td class="h5" align="left">State:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtNewBillState" />
            </td> 
            <td class="h5" align="left">ZipCode:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtNewBillZipCode" Width="45"/>
            </td>                               
        </tr>
        <tr class="CCnewBillTo">
            <td class="h5" align="left">Tel:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtNewBillTel" />
            </td>   
            <td class="h5" align="left">Attention:
            </td> 
            <td>
                <asp:TextBox runat="server" ID="txtNewBillAttention" />
            </td>  
            <td></td>
            <td></td>
        </tr>
    </table>
</div>
<script type="text/javascript" src="../../EC/Includes/jquery-latest.min.js"></script>
<script>

    $(document).ready(function () {
        IsShowNewBillTo();

        $('#<%=ckbUserNewBillAddress.ClientID %>').click(function () {
            IsShowNewBillTo();
        });

        function IsShowNewBillTo() {
            if ($('#<%=ckbUserNewBillAddress.ClientID %>').is(':checked')) {
                $(".CCnewBillTo").show();
            } else {
                $(".CCnewBillTo").hide();
            }
        }


    });
</script>
