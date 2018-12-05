<%@ Page Title="Apply New SAP Account" Language="VB" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="false" CodeFile="CreateSAPCustomer.aspx.vb" Inherits="Admin_CreateSAPCustomer" %>

<%@ Register Src="~/Includes/PickAccount.ascx" TagName="PickAccount" TagPrefix="myASCX" %>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style>
        .defaultWidth {
            width: 300px;
        }

        .dropdownWidth {
            width: 300px;
        }
    </style>

    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:HiddenField runat="server" ID="hid1" />
            <asp:Panel runat="server" ID="ApproveDIV" Visible="false">
                <table width="600">
                    <tr runat="server" id="TBCompanyId2">
                        <td width="120">
                            <b>Company ID:</b>
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtCompanyId2" Width="80px" AutoPostBack="true" />
                            <asp:Label runat="server" ID="lbERPIDMsg2" ForeColor="Tomato" Font-Bold="true" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <b>Comment:</b>
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="TBComment" TextMode="MultiLine" Width="500"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" colspan="2">
                            <asp:Button runat="server" Text="Approved" ID="BtApprove" />&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;&nbsp; &nbsp;
                            <asp:Button runat="server" Text="Rejected" ID="BtReject" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:Label runat="server" ID="lbDoneMsg2" Font-Bold="true" ForeColor="Tomato" />
                        </td>
                    </tr>
                </table>
                <br />
            </asp:Panel>
            <asp:MultiView runat="server" ID="mv1" ActiveViewIndex="0">
                <asp:View runat="server" ID="GeneralView">
                    <asp:HyperLink ID="hlucl" runat="server" Visible="false" NavigateUrl="SAPCutomerCreditLimit.aspx" Target="_blank" Text="Request to update credit limit for an existing account" />
                    <h2>General Data</h2>
                    <table width="100%" style="height: 25px; background-color: #EBEBEB; line-height: 25px;">
                        <tr>
                            <th align="left" width="210">Already have Existing Company ID<img alt="?" src="../Images/why.png" />
                            </th>
                            <td>
                                <table>
                                    <tr>
                                        <td>
                                            <asp:RadioButtonList runat="server" ID="RBIsExist" RepeatDirection="Horizontal"
                                                AutoPostBack="True" OnSelectedIndexChanged="RBIsExist_SelectedIndexChanged">
                                                <asp:ListItem Value="1">YES</asp:ListItem>
                                                <asp:ListItem Value="0" Selected="True">NO</asp:ListItem>
                                            </asp:RadioButtonList></td>
                                        <%--  <th align="right" width="210">
                               OR have Existing Siebel:
                            </th>
                            <td>
                               <asp:TextBox ID="TBsiebelAccountID" Enabled="false" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <asp:Button ID="BtChecksiebel" runat="server" Text="Pick a Account" />
                            </td>--%>
                                    </tr>

                                </table>

                            </td>
                        </tr>
                    </table>
                    <table id="TBCompanyId" runat="server">
                        <tr>
                            <th align="left">Existing Company ID:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtCompanyId" Width="80px" AutoPostBack="true" />&nbsp;
                                &nbsp;<asp:Button runat="server" Text="check" ID="BTcheck" />&nbsp; &nbsp;
                                <asp:Label runat="server" ID="lbERPIDMsg" ForeColor="Tomato" Font-Bold="true" />
                            </td>
                        </tr>
                    </table>
                    <table id="TBGeneralData" runat="server">
                        <tr>
                            <th align="left" with="240">Company Name:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtCompanyName" CssClass="defaultWidth" />&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left" width="240">Pick corresponding Siebel account:
                            </th>
                            <td>
                                <asp:TextBox ID="TBsiebelAccountID" Enabled="false" runat="server" CssClass="defaultWidth"></asp:TextBox>
                                <asp:Button ID="BtChecksiebel" runat="server" Text="Pick an Account" />
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Legal Form:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtLegalForm" CssClass="defaultWidth" />&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">VAT Number:
                            </th>
                            <td>
                                <table cellpadding="0" cellspacing="0" width="100%">
                                    <tr>
                                        <td width="220">
                                            <asp:TextBox runat="server" ID="txtVAT" CssClass="defaultWidth" />&nbsp;&nbsp;<asp:Label ID="Label2"
                                                runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                                        </td>
                                        <td style="padding-left: 10px;">
                                            <span style="color: #FF0066; font-size: 10px; font-style: italic; text-align: left;">Always include country code in front of VAT number. Don’t use dots, dashes or space
                                                within the VAT number.</span>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Company Registration Number:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtRegistrationNo" CssClass="defaultWidth" />&nbsp;&nbsp;
                                <asp:Label runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                                <span style="color: #FF0066; font-size: 10px; font-style: italic; text-align: left;">Please fill in company registration number.</span>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Website:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtWebsiteUrl" CssClass="defaultWidth" />&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address1:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtAddr1" CssClass="defaultWidth" />&nbsp;&nbsp;
                                <asp:Label runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                                <span style="color: #FF0066; font-size: 10px; font-style: italic; text-align: left;">Please fill in street and number only, PO BOX not allowed!</span>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address2:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtAddr2" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address3:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtAddr3" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Postal Code:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtPostCode" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">City:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtCity" CssClass="defaultWidth" />&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Country:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlCountry" CssClass="dropdownWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Form:
                            </th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="RB_form" RepeatDirection="Horizontal">
                                    <asp:ListItem Value="0" Text="Mr.">Mr.</asp:ListItem>
                                    <asp:ListItem Value="1" Text="Ms.">Ms.</asp:ListItem>
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Telephone:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtTel" CssClass="defaultWidth" />
                                <asp:Label runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Fax:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtFax" Width="100px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Contact Person Name:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtContactName" CssClass="defaultWidth" />
                                <asp:Label runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Contact Person Email:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtContactEmail" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Digital Invoice:
                            </th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="RB_DigitalInvoice" RepeatDirection="Horizontal">
                                    <asp:ListItem Value="1" >Yes</asp:ListItem>
                                    <asp:ListItem Value="0" >No</asp:ListItem>
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Invoice Email Address:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtInvoiceEmail" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Currency:</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlCurr" CssClass="dropdownWidth">
                                    <asp:ListItem Text="EUR" Value="EUR" Selected="True" />
                                    <asp:ListItem Text="USD" Value="USD" />
                                    <asp:ListItem Text="GBP" Value="GBP" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Forwarder/Transporter:</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlShipCond" CssClass="dropdownWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Incoterm1
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlInco1" CssClass="dropdownWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Shipping Remarks
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtInco2" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Sales Office:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlSalesOffice" CssClass="dropdownWidth"  OnSelectedIndexChanged="SetOPCodeBySelection" AutoPostBack="true">
                                    <asp:ListItem Text="ABN" Value="3100" />
                                    <asp:ListItem Text="ADL" Value="3000" />
                                    <asp:ListItem Text="AESC" Value="3900" />
                                    <asp:ListItem Text="AFR" Value="3200" />
                                    <asp:ListItem Text="AIT" Value="3300" />
                                    <asp:ListItem Text="AUK" Value="3400" />
                                    <asp:ListItem Text="AIR" Value="3410" />
                                    <asp:ListItem Text="ANR" Value="3500" />
                                    <asp:ListItem Text="Eastern Europe" Value="3600" />
                                    <asp:ListItem Text="Emerging Territory" Value="3700" />
                                    <asp:ListItem Text="AIB" Value="3800" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Sales:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlSalesCode" CssClass="dropdownWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Inside Sales:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlISCode" CssClass="dropdownWidth" />
                            </td>
                        </tr>
                        <tr runat="server" id="trOPCode">
                            <th align="left">OP:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlOPCode" CssClass="dropdownWidth" Enabled="false">
                                    <asp:ListItem Text="TBD" Value="TBD" Selected="True"></asp:ListItem>
                                </asp:DropDownList>                                
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Customer Type:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlCustomerType" CssClass="dropdownWidth" OnSelectedIndexChanged="SetOPCodeBySelection" AutoPostBack="true">
                                    <asp:ListItem Text="310 = TBD" Value="310" />
                                    <asp:ListItem Text="311 = Others" Value="311" />
                                    <asp:ListItem Text="312 = IA KA" Value="312" />
                                    <asp:ListItem Text="313 = EC CSF" Value="313" />
                                    <asp:ListItem Text="314 = iHospital" Value="314" />
                                    <asp:ListItem Text="315 = iA IoT Aonline" Value="315" />
                                    <asp:ListItem Text="316 = iA KA 2" Value="316" />
                                    <asp:ListItem Text="317 = iS Aonline" Value="317" />
                                    <asp:ListItem Text="318 = EC Aonline" Value="318" />
                                    <asp:ListItem Text="320 = iSystem KA" Value="320" />
                                    <asp:ListItem Text="321 = iA IoT CSF" Value="321" />
                                    <asp:ListItem Text="322 = EC KA" Value="322" />
                                    <asp:ListItem Text="323 = NC KA" Value="323" />
                                    <asp:ListItem Text="324 = AC KA" Value="324" />
                                    <asp:ListItem Text="325 = EC Display" Value="325" />
                                    <asp:ListItem Text="326 = EC Gaming" Value="326" />
                                    <asp:ListItem Text="327 = iRetail" Value="327" />
                                    <asp:ListItem Text="330 = iNetworking AOL - EU10" Value="330" />
                                    <asp:ListItem Text="331 = iNetworking CSF - EU10" Value="331" />
                                    <asp:ListItem Text="332 = iNetworking KA - EU10" Value="332" />
                                    <asp:ListItem Text="380 = Service" Value="380" />
                                    <asp:ListItem Text="381 = Logistics" Value="381" />
                                    <asp:ListItem Text="382 = RMA" Value="382" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Vertical Market Definition (Only for KA):
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlVM" CssClass="dropdownWidth">
                                    <asp:ListItem Text="Select..." Value="NONE" />
                                    <asp:ListItem Text="080 / (BA) Building Automation" Value="080" />
                                    <asp:ListItem Text="100 / (MA) Machine Automation " Value="100" />
                                    <asp:ListItem Text="130 / (FA) Factory Automation " Value="130" />
                                    <asp:ListItem Text="140 / (EFMS) Environmental and Facility Management " Value="140" />
                                    <asp:ListItem Text="150 / (P&E) Power & Energy" Value="150" />
                                    <asp:ListItem Text="170 / Education" Value="170" />
                                    <asp:ListItem Text="200 / Transportation" Value="200" />
                                    <asp:ListItem Text="260 / Networks & Telecom" Value="260" />
                                    <asp:ListItem Text="270 / Military" Value="270" />
                                    <asp:ListItem Text="400 / Gaming/ POS" Value="400" />
                                    <asp:ListItem Text="401 / Gaming / Innocore" Value="401" />
                                    <asp:ListItem Text="590 / Medical" Value="590" />
                                    <asp:ListItem Text="610 / Self Service" Value="610" />
                                    <asp:ListItem Text="700 / Brand Store (AiS)" Value="700" />
                                    <asp:ListItem Text="710 / eHome (AiS)" Value="710" />
                                    <asp:ListItem Text="720 / Enterprise (AiS)" Value="720" />
                                    <asp:ListItem Text="730 / Exhibition (AiS)" Value="730" />
                                    <asp:ListItem Text="740 / Hospitality (AiS)" Value="740" />
                                    <asp:ListItem Text="750 / Hotel (AiS)" Value="750" />
                                    <asp:ListItem Text="760 / Lifestyle Service (AiS)" Value="760" />
                                    <asp:ListItem Text="770 / Museum (AiS)" Value="770" />
                                    <asp:ListItem Text="780 / Public Space (AiS)" Value="780" />
                                    <asp:ListItem Text="790 / Restaurant (AiS)" Value="790" />
                                    <asp:ListItem Text="800 / Retail (AiS)" Value="800" />
                                    <asp:ListItem Text="810 / School Campus (AiS)" Value="810" />
                                    <asp:ListItem Text="999 / Others / General Biz" Value="999" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Credit Limit & Payment Terms:
                            </th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="rblFillCredit" RepeatColumns="2" RepeatDirection="Horizontal" AutoPostBack="true">
                                    <asp:ListItem Text="NO" Selected="True" />
                                    <asp:ListItem Text="YES" />
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left" style="position: relative; cursor: pointer;" onmouseover="document.getElementById('divship').style.display='';" onmouseout="document.getElementById('divship').style.display='none';">Ship-to Address 
                                <img alt="?" src="../Images/why.png" />
                                <div id="divship" style="position: absolute; width: 200px; height: 35px; padding: 3px 3px 6px 8px; border: 1px solid #FF0000; line-height: 20px; background-color: #FFFFFF; color: #FF0000; display: none; z-index: 99;">(when different from Sold-to and Billing address)</div>
                            </th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="rblHasShipto" RepeatColumns="2" RepeatDirection="Horizontal" AutoPostBack="true">
                                    <asp:ListItem Text="NO" Selected="True" />
                                    <asp:ListItem Text="YES" />
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left" style="position: relative; cursor: pointer;" onmouseover="document.getElementById('divBilling').style.display='';" onmouseout="document.getElementById('divBilling').style.display='none';">Billing Address 
                                <img alt="?" src="../Images/why.png" />
                                <div id="divBilling" style="position: absolute; width: 200px; height: 35px; padding: 3px 3px 6px 8px; border: 1px solid #FF0000; line-height: 20px; background-color: #FFFFFF; color: #FF0000; display: none; z-index: 99;">(when different from Sold-to and Ship-to address)</div>
                            </th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="rblHasBilling" RepeatColumns="2" RepeatDirection="Horizontal" AutoPostBack="true">
                                    <asp:ListItem Text="NO" Selected="True" />
                                    <asp:ListItem Text="YES" />
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                    </table>
                    <table>
                        <tr>
                            <td>
                                <asp:Button runat="server" ID="btnSubmit1" Text="Submit" UseSubmitBehavior="false" OnClientClick="this.disabled = true;" OnClick="btnCreate_Click"/>
                            </td>
                            <%--          <td>
                                <asp:Button runat="server" ID="btnCreate" Text="Create" />
                            </td>--%>
                            <td>
                                <asp:Button runat="server" ID="btnGo2Credit" Visible="false" Text="Input Credit Data" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnGo2Shipto" Text="Input Ship-to Data" Visible="false" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnGo2Billing" Text="Input  Billing Address" Visible="false" />
                            </td>
                        </tr>
                    </table>
                </asp:View>
                <asp:View runat="server" ID="CreditView">
                    <h2>Credit Data</h2>
                    <table>
                        <tr>
                            <th align="left" width="240" style="height: 26px">Contact Person Finance & Acounting dept:
                            </th>
                            <td style="height: 26px">
                                <asp:TextBox runat="server" ID="TBCONTACTPERSON_FA" Width="300px"></asp:TextBox>&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Telephone F&A:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="TBTELEPHONE_FA" Width="300px"></asp:TextBox>&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Email F&A:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="TBEMAIL_FA" Width="300px"></asp:TextBox>&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Credit info:
                            </th>
                            <td>
                                <asp:LinkButton runat="server" ID="lnkDeviceInfo">Direct Device</asp:LinkButton>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Requested Payment Terms:</th>
                            <td>
                                <%--  <asp:DropDownList runat="server" ID="dlPayTerm" />--%>
                                <asp:TextBox ID="TBdlPayTerm" runat="server"></asp:TextBox>
                                &nbsp;&nbsp;<asp:Label ID="Label1" runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Credit Limit:</th>
                            <td>
                                <%--  <asp:DropDownList runat="server" ID="dlPayTerm" />--%>
                                <asp:TextBox ID="TBCreditLimit" runat="server"></asp:TextBox>
                                <%--             &nbsp;&nbsp;<asp:Label runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>--%>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Amount Insured:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtAmtInsured" Width="80px" />
                                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft1" TargetControlID="txtAmtInsured"
                                    FilterType="Numbers, Custom" ValidChars="^[1-9]\d*$" />
                            </td>
                        </tr>
                    </table>
                    <table>
                        <tr>
                            <td>
                                <asp:Button runat="server" ID="btnSubmit2" Text="Submit" UseSubmitBehavior="false" OnClientClick="this.disabled = true;" OnClick="btnCreate_Click"/>
                            </td>
                            <%--<td>
                                <asp:Button runat="server" ID="btnCreate2" Text="Create" />
                            </td>--%>
                            <td>
                                <asp:Button runat="server" ID="btn2General" Text="Back to Edit General Data" />
                            </td>
                        </tr>
                    </table>
                </asp:View>
                <asp:View runat="server" ID="ShiptoView">
                    <h2>Ship-to</h2>
                    <table width="100%">
                        <tr>
                            <th align="left" width="180">Company Name:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoCompanyName" Width="300px" />&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left" valign="middle">VAT Number:
                            </th>
                            <td valign="middle">
                                <table valign="middle" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtShiptoVATNumber" Width="300px" />
                                        </td>
                                        <td width="8px">
                                            <asp:Label ID="Label3" runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label></td>
                                        <td>
                                            <span style="color: Red; font-size: 11px;">Copy the VAT-number from the Sold-to account<%--= Sold-to VAT-number.
                                                (Only for shipments <u>within the Netherlands</u>, provide VAT of the Ship-to)--%></span></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address1:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoAddress" Width="300px" />&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address2:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoAddress2" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address3:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoAddress3" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Postal Code:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoPostcode" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">City:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoCity" Width="300px" />&nbsp;&nbsp;<asp:Label
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Country:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlShiptoCountry" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Telephone:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoTel" Width="300px" />
                                <asp:Label runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Fax:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoFax" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Contact Person Name:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoContactName" Width="300px" />
                                <asp:Label runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Contact Person Email:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtShiptoContactEmail" Width="300px" />
                            </td>
                        </tr>
                    </table>
                    <table>
                        <tr>
                            <td>
                                <asp:Button runat="server" ID="btnSubmit3" Text="Submit" UseSubmitBehavior="false" OnClientClick="this.disabled = true;" OnClick="btnCreate_Click"/>
                            </td>
                            <%--  <td>
                                <asp:Button runat="server" ID="btnCreate3" Text="Create" />
                            </td>--%>
                            <td>
                                <asp:Button runat="server" ID="btn2General2" Text="Back to Edit General Data" />
                            </td>
                        </tr>
                    </table>
                </asp:View>
                <asp:View runat="server" ID="BillingView">
                    <h2>Billing Address</h2>
                    <table width="100%">
                        <tr>
                            <th align="left" width="180">Company Name:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingCompanyName" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">VAT Number:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingVATNumber" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address1:</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingAddress" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address2:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingAddress2" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Address3:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingAddress3" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Postal Code:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingPostcode" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">City:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingCity" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Country:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlBillingCountry" />
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Telephone:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingTel" Width="300px" />
                            </td>
                        </tr>
                        <tr style="display: none;">
                            <th align="left">Fax:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingFax" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Contact Person Name:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingContactName" Width="300px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Contact Person Email:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtBillingContactEmail" Width="300px" />
                            </td>
                        </tr>
                    </table>
                    <table>
                        <tr>
                            <td>
                                <asp:Button runat="server" ID="btnSubmit4" Text="Submit" UseSubmitBehavior="false" OnClientClick="this.disabled = true;" OnClick="btnCreate_Click"/>
                            </td>
                            <%--     <td>
                                <asp:Button runat="server" ID="btnCreate4" Text="Create" />
                            </td>--%>
                            <td>
                                <asp:Button runat="server" ID="btn2General3" Text="Back to Edit General Data" />
                            </td>
                        </tr>
                    </table>
                </asp:View>
                <asp:View runat="server" ID="viewDirectDevice">
                    <asp:Button ID="btn2General4" runat="server" Text="Back to Credit Data" /><br />
                    <iframe src="https://www.directdevice.info" width="1024" height="700" />
                    </iframe>
                </asp:View>
            </asp:MultiView>
            <asp:Label runat="server" ID="lbDoneMsg" Font-Bold="true" ForeColor="Tomato" />
            <br />
            <asp:Label runat="server" ID="lbDebugMsg" />
            <asp:GridView runat="server" ID="gvPtnr" />
            <asp:Panel ID="PLPickAccount" runat="server" Style="display: none" CssClass="modalPopup" Width="700">
                <div style="text-align: right;">
                    <asp:ImageButton ID="CancelButtonAccount" runat="server" ImageUrl="~/Images/del.gif" />
                </div>
                <div>
                    <asp:UpdatePanel ID="UPPickAccount" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <myASCX:PickAccount ID="ascxPickAccount" runat="server" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:Panel>
            <asp:LinkButton ID="lbDummyAccount" runat="server" />
            <ajaxToolkit:ModalPopupExtender ID="MPPickAccount" runat="server" TargetControlID="lbDummyAccount"
                PopupControlID="PLPickAccount" BackgroundCssClass="modalBackground" CancelControlID="CancelButtonAccount" />
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

