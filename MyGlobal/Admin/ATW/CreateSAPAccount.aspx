<%@ Page Title="MyAdvantech - New SAP Customer Application" Language="C#" EnableEventValidation="true" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="CreateSAPAccount.aspx.cs" Inherits="Admin_ATW_CreateSAPAccount" %>

<%@ Register Src="~/Includes/PickAccount.ascx" TagName="PickAccount" TagPrefix="myASCX" %>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">

    <link href="../../Includes/EasyUI/themes/default/easyui.css" rel="stylesheet" />
    <link href="../../Includes/EasyUI/themes/icon.css" rel="stylesheet" />
    <script src="../../Includes/EasyUI/jquery.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.easyui.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.searchabledropdown-1.0.8.min.js"></script>
    <script>
        function pageLoad(sender, e) {
            if (e.get_isPartialLoad() == false) {
                Sys.WebForms.PageRequestManager.getInstance().add_initializeRequest(InitRequestHandler);
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
            }
        }
        function InitRequestHandler(sender, e) { }
        function EndRequestHandler(sender, e) {
            $.parser.parse();
            $("select").searchable();
        }
        $.extend({
            show_warning: function (strTitle, strMsg) {
                $.messager.show({
                    title: strTitle,
                    width: 300,
                    height: 100,
                    msg: strMsg,
                    closable: true,
                    style: {
                        right: '',
                        top: document.body.scrollTop + document.documentElement.scrollTop,
                        bottom: ''
                    }
                });
            }
        });
        $.extend({
            show_alert: function (strTitle, strMsg) {
                $.messager.alert(strTitle, strMsg);
            }
        });

        //2015/03/05 Add jquery search dropdownlist function
        $(document).ready(function () {
            $("select").searchable();
        });

        function getPriceGrade(group) {
            $('#PriceGrade').combobox({
                url: '../../../Services/PriceGradeHandler.ashx?group=' + group,
                valueField: 'Grade',
                textField: 'Grade'
            });
        }
    </script>
    <style>
        .defaultWidth {
            width: 300px;
        }

        .dropdownWidth {
            width: 300px;
        }

        span.csname {
            color: tomato;
        }
    </style>
    <style>
        td.th {
            background-color: #d3d3d3;
            height: 25px;
        }

        td.ac {
            text-align: center;
            font-weight: bold;
        }

        td.acb {
            text-align: center;
            background-color: #E6E6FA;
        }

        input.bt {
            padding: 2px;
        }
    </style>
    <asp:Button ID="Button1" runat="server" Text="Update" OnClick="Button1_Click" Visible="false" />
    <asp:UpdatePanel runat="server" ID="up2">
        <ContentTemplate>
            <% if (Request["id"] != null && IsManager())
                {  %>
            <div id="Approvepanel" class="easyui-panel" title="Manager Review" style="width: 900px; height: auto; padding: 10px; background: #fafafa;">
                <table width="850">
                    <tr>
                        <td>
                            <table>
                                <tr runat="server" id="TBCompanyId2">
                                    <td width="100" style="text-align: right;">
                                        <b>Company ID:</b>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtCompanyId2" Width="280" AutoPostBack="true" OnTextChanged="txtCompanyId2_TextChanged" />&nbsp;                                                                                
                                    </td>
                                </tr>
                                <tr>
                                    <td>&nbsp;</td>
                                    <td><asp:Label runat="server" ID="lbERPIDMsg2" ForeColor="Tomato" Font-Bold="true" /></td>
                                </tr>
                                <tr>
                                    <td style="text-align: right;">
                                        <b>Remark:</b>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="txtCompanyDescription" Width="280" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="text-align: right;">
                                        <b>Assign To:</b>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="TBmail" Width="280"></asp:TextBox>
                                        <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" TargetControlID="TBmail"
                                            ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetEmployeeEmail" MinimumPrefixLength="2">
                                        </ajaxToolkit:AutoCompleteExtender>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="text-align: right;">
                                        <b>Comment:</b>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="TBComment" TextMode="MultiLine" Width="280" Height="80"></asp:TextBox>&nbsp;&nbsp;
                                        <span style="color: Red; font-size: 11px;">*</span>
                                    </td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <td width="33%">
                                                    <asp:Button runat="server" Text="Approve" ID="BtApprove" CssClass="bt" OnClick="BtApprove_Click" /></td>
                                                <td width="33%">
                                                    <asp:Button runat="server" Text="Reject" ID="BtReject" CssClass="bt" OnClick="BtReject_Click" /></td>
                                                <td width="33%">
                                                    <asp:Button ID="btproposal" runat="server" Text="Assign" CssClass="bt" OnClick="btproposal_Click" /></td>
                                            </tr>
                                        </table>

                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:Label runat="server" ID="lbDoneMsg2" Font-Bold="true" ForeColor="Tomato" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top">
                            <table width="100%" border="1" bordercolor="#000000" style="border-collapse: collapse">
                                <tr>
                                    <td class="th ac">Step</td>
                                    <td class="th ac">Employee Email</td>
                                    <td class="th ac">Date & Time</td>
                                    <td class="th ac">Comment</td>
                                </tr>
                                <asp:Label ID="labTBproposal" runat="server" Text="" />
                            </table>

                        </td>
                    </tr>
                </table>
            </div>
            <%} %>
        </ContentTemplate>
    </asp:UpdatePanel>
    <div style="height: 8px;"></div>    
    <table>
        <tr>
            <th align="left" style="position: relative; cursor: pointer;" onmouseover="document.getElementById(&#39;divship&#39;).style.display=&#39;&#39;;" onmouseout="document.getElementById(&#39;divship&#39;).style.display=&#39;none&#39;;">Ship-to Address 
                <img alt="?" src="../../Images/why.png" />
                <div id="divship" style="position: absolute; width: 200px; height: 35px; padding: 3px 3px 6px 8px; border: 1px solid #FF0000; line-height: 20px; background-color: #FFFFFF; color: #FF0000; display: none; z-index: 99;">(when different from Sold-to and Billing address)</div>
            </th>
            <td>
                <table id="ctl00__main_rblHasShipto" border="0">
                    <tr>
                        <td>
                            <input type="radio" name="HasShipto" value="0" <%= IsHaveShipTO ? "":"checked='checked'" %> />NO</td>
                        <td>
                            <input type="radio" name="HasShipto" value="1" <%= IsHaveShipTO ? "checked='checked'":"" %> />YES</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <th align="left" style="position: relative; cursor: pointer;" onmouseover="document.getElementById('divBilling').style.display='';" onmouseout="document.getElementById('divBilling').style.display='none';">Billing Address 
                <img alt="?" src="../../Images/why.png" style="padding-left: 5px;" />
                <div id="divBilling" style="position: absolute; width: 200px; height: 35px; padding: 3px 3px 6px 8px; border: 1px solid #FF0000; line-height: 20px; background-color: #FFFFFF; color: #FF0000; display: none; z-index: 99;">(when different from Sold-to and Ship-to address)</div>
            </th>
            <td>
                <table border="0">
                    <tr>
                        <td>
                            <input type="radio" name="HasBilling" value="0" <%= IsHaveBillTo ? "":"checked='checked'" %> />NO</td>
                        <td>
                            <input type="radio" name="HasBilling" value="1" <%= IsHaveBillTo ? "checked='checked'":"" %> />YES</td>
                    </tr>
                </table>
            </td>
        </tr>
        <% if (Request["id"] == null)
            {  %>
        <tr>
            <td colspan="2">
                <a href="javascript:void('0');" class="easyui-linkbutton" data-options="iconCls:'icon-save'" id="btsave">Submit</a>
                <div id="loading" style="display: none;">
                    <img src="../../images/loading2.gif">
                </div>
            </td>
        </tr>
        <% } %>
    </table>
    <div id="mytab" class="easyui-tabs" style="width: 900px; height: 1200px">
        <div title="SoldTo" style="padding: 20px;">
            <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                <ContentTemplate>
                    <table>
                        <tr>
                            <th align="left" style="width: 150px">Sales Org:
                            </th>
                            <td>
                                <asp:DropDownList ID="dlOrgID" runat="server" DataTextField="OrgID" DataValueField="OrgID" AutoPostBack="true"
                                    OnSelectedIndexChanged="dlOrgID_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Sales Office:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlSalesOffice" Width="300px" AutoPostBack="true" OnSelectedIndexChanged="dlSalesOffice_SelectedIndexChanged" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Sales Group:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlSalesGroup" Width="280px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Company Name:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtCompanyName" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<span style="color: Red; font-size: 11px;">*</span>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Search Term1:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="TBSearchTerm1" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Search Term2:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="TBSearchTerm2" CssClass="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Siebel account:
                            </th>
                            <td>
                                <asp:TextBox ID="TBsiebelAccountID" Enabled="false" runat="server" CssClass="defaultWidth"></asp:TextBox>
                                <asp:Button ID="BtChecksiebel" runat="server" Text="Pick" OnClick="BtChecksiebel_Click" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">DUNS Number:
                            </th>
                            <td>
                                <input type="text" id="DUNSNumber" name="DUNSNumber" class="defaultWidth" value="<%=DUNSNumber%>" />&nbsp;&nbsp;
                            </td>
                        </tr>
                        <tr>
                            <th align="left">D&B Payment Index:
                            </th>
                            <td>
                                <input type="text" id="DBPaymentIndex" name="DBPaymentIndex" class="defaultWidth" value="<%=DBPaymentIndex %>" />&nbsp;&nbsp;
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Payment Term:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlPaymentTerm" Width="290px" />
                               <span style="color: Red; font-size: 11px;">*</span>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Credit Amount:<br />
                                <td>
                                    <table cellpadding="0" cellspacing="0" width="100%">
                                        <tr>
                                            <td width="100">
                                                <input name="CreditAmount" type="text" id="CreditAmount" class="defaultWidth easyui-validatebox" value="<%=CreditAmount%>" data-options="required:true" />
                                            </td>
                                            <td style="padding-left: 10px;"><span style="color: Red; font-size: 11px;">USD (For TW01’s customer data the credit amount will be auto-converted to TWD based on the USD amount you input.)</span></td>
                                        </tr>
                                    </table>
                                </td>
                        </tr>
                        <tr>
                            <th align="left">Official Registration no.:
                            </th>
                            <td>
                                <input name="LegalForm" type="text" id="LegalForm" class="defaultWidth easyui-validatebox" value="<%=LegalForm %>" data-options="required:true" />&nbsp;&nbsp;<span style="color: Red; font-size: 11px;">*</span></td>
                        </tr>
                        <tr>
                            <th align="left">VAT Number:
                            </th>
                            <td>
                                <table cellpadding="0" cellspacing="0" width="100%">
                                    <tr>
                                        <td width="220">
                                            <asp:TextBox runat="server" ID="txtVAT" CssClass="defaultWidth" />
                                        </td>
                                        <td style="padding-left: 10px;"><span style="color: #FF0066; font-size: 10px; font-style: italic; text-align: left;">Always include country code in front of VAT number. Don’t use dots, dashes or space
                                                within the VAT number.</span> </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Website:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtWebsiteUrl" CssClass="defaultWidth" />&nbsp;&nbsp;</td>
                        </tr>
                        <tr>
                            <th align="left">Address1:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtAddr1" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<asp:Label ID="Label1"
                                    runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
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
                                <asp:TextBox runat="server" ID="txtPostCode" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">City:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtCity" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<span style="color: Red; font-size: 11px;">*</span> </td>
                        </tr>
                        <tr>
                            <th align="left">Country:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlCountry" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Tax Code:</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlTAXID" />
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Telephone:
                                        </th>
                                        <td>
                                            <input name="ctl00$_main$txtTel" type="text" id="ctl00__main_txtTel" value="<%=txtTel %>" style="width: 100px;" />
                                        </td>
                                        <th align="left">Fax:
                                        </th>
                                        <td>
                                            <input name="ctl00$_main$txtFax" type="text" id="ctl00__main_txtFax" value="<%=Fax %>" style="width: 100px;" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Contact Person Name:
                            </th>
                            <td>
                                <asp:TextBox runat="server" ID="txtContactName" CssClass="defaultWidth" />
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
                            <th align="left">Currency:</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlCurr" DataTextField="CURRENCY" DataValueField="CURRENCY">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Forwarder/Transporter:</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlShipCond" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Incoterm1
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlInco1" DataValueField="INCO1" DataTextField="INCO1" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Shipping Remarks
                            </th>
                            <td>
                                <input name="ctl00$_main$txtInco2" type="text" id="ctl00__main_txtInco2" value="<%=ShippingRemarks %>" class="defaultWidth" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Sales ID:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlSalesCode" /><span style="color: Red; font-size: 11px;">&nbsp;&nbsp;*</span>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">OP:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlOPCode">
                                </asp:DropDownList><%--<span style="color: Red; font-size: 11px;">*</span>--%>
                            </td>
                        </tr>                        
                        <tr>
                            <th align="left">Industry:</th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlIndustry">
                                    <asp:ListItem Text="1000 (Taiwan)" Value="1000" />
                                    <asp:ListItem Text="2000 (America)" Value="2000" />
                                    <asp:ListItem Text="3000 (Europe)" Value="3000" />
                                    <asp:ListItem Text="4000 (China)" Value="4000" />
                                    <asp:ListItem Text="5000 (Asia - Others)" Value="5000" />
                                    <asp:ListItem Text="BRCT (Brazil Contribuinte)" Value="BRCT" />
                                    <asp:ListItem Text="BRNC (Brazil Non-Contribu.)" Value="BRNC" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Vertical Market Definition
                                <br />
                                (Only for KA):
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlVM">
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
                        <tr>
                            <th align="left">Customer Group:
                            </th>
                            <td>
                                <asp:DropDownList runat="server" ID="dlCustomerGroup" onchange="getPriceGrade(this.value)">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Price Grade:
                            </th>
                            <td>
                                <input type="text" id="PriceGrade" name="PriceGrade" class="defaultWidth easyui-validatebox" value="<%=PriceGrade %>" data-options="required:true,validType:'length[8,8]',invalidMessage:'Please enter 8 characters'" />&nbsp;&nbsp;    <span style="color: Red; font-size: 11px;">*</span>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Sector ID:
                            </th>
                            <td>
                                <select name="Industrycode1" class="dropdownWidth" value="<%=Industrycode1%>">
                                    <option value="">Select...</option>
                                    <option <%= Industrycode1=="0001" ? "selected='selected'":"" %> value="0001">Industry code 01</option>
                                    <option <%= Industrycode1=="700" ? "selected='selected'":"" %> value="700">SEC-Co-Own</option>
                                    <option <%= Industrycode1=="701" ? "selected='selected'":"" %> value="701">SEC-D. Healthcare</option>
                                    <option <%= Industrycode1=="702" ? "selected='selected'":"" %> value="702">SEC-D. Logistic</option>
                                    <option <%= Industrycode1=="703" ? "selected='selected'":"" %> value="703">SEC-EC-AOnline</option>
                                    <option <%= Industrycode1=="704" ? "selected='selected'":"" %> value="704">SEC-EC-CSF</option>
                                    <option <%= Industrycode1=="705" ? "selected='selected'":"" %> value="705">SEC-EC-KA</option>
                                    <option <%= Industrycode1=="706" ? "selected='selected'":"" %> value="706">SEC-IA-CSF</option>
                                    <option <%= Industrycode1=="707" ? "selected='selected'":"" %> value="707">SEC - iCloud CSF</option>
                                    <option <%= Industrycode1=="708" ? "selected='selected'":"" %> value="708">SEC - iCloud KA</option>
                                    <option <%= Industrycode1=="709" ? "selected='selected'":"" %> value="709">SEC- iRetail</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">RUB ID:
                            </th>
                            <td>
                                <select name="Industrycode2" class="dropdownWidth" value="<%=Industrycode2%>">
                                    <option value="">Select...</option>
                                    <option <%= Industrycode2=="800" ? "selected='selected'":"" %> value="800">RBU - Africa</option>
                                    <option <%= Industrycode2=="801" ? "selected='selected'":"" %> value="801">RBU - gcc</option>
                                    <option <%= Industrycode2=="802" ? "selected='selected'":"" %> value="802">RBU -India</option>
                                    <option <%= Industrycode2=="803" ? "selected='selected'":"" %> value="803">RBU - Israel</option>
                                    <option <%= Industrycode2=="804" ? "selected='selected'":"" %> value="804">RBU - New Zealand</option>
                                    <option <%= Industrycode2=="805" ? "selected='selected'":"" %> value="805">RBU - Russia</option>
                                    <option <%= Industrycode2=="806" ? "selected='selected'":"" %> value="806">RBU - Turkey</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Remark:</th>
                            <td>
                                <input type="text" id="CompanyDescription" name="CompanyDescription" class="defaultWidth easyui-validatebox" value="<%=CompanyDescription %>" />
                            </td>
                        </tr>
                    </table>

                </ContentTemplate>
            </asp:UpdatePanel>
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
        </div>
        <div title="ShipTo" style="overflow: auto; padding: 20px;">
            <table width="100%">
                <tr>
                    <th align="left" width="180">Company Name:</th>
                    <td>
                        <asp:TextBox runat="server" ID="txtShiptoCompanyName" Width="300px" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<asp:Label ID="Label2"
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
                                    <asp:TextBox runat="server" ID="txtShiptoVATNumber" Width="300px" CssClass="defaultWidth" />
                                </td>
                                <td>&nbsp;&nbsp;
                                            <span style="color: Red; font-size: 11px;">Copy the VAT-number from the Sold-to account</span>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <th align="left">Address1:</th>
                    <td>
                        <asp:TextBox runat="server" ID="txtShiptoAddress" Width="300px" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<asp:Label ID="Label4"
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
                        <asp:TextBox runat="server" ID="txtShiptoCity" Width="300px" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<asp:Label ID="Label5"
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
                    <th align="left">Tax Code:</th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlShipToTaxId" />
                    </td>
                </tr>
                <tr>
                    <th align="left">Telephone:
                    </th>
                    <td>
                        <asp:TextBox runat="server" ID="txtShiptoTel" Width="300px" />
                    </td>
                </tr>
                <tr>
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
        </div>
        <div title="BillTo" style="padding: 20px;">
            <table width="100%">
                <tr>
                    <th align="left" width="180">Company Name:</th>
                    <td>
                        <asp:TextBox runat="server" ID="txtBillingCompanyName" Width="300px" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<asp:Label ID="Label3"
                            runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
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
                        <asp:TextBox runat="server" ID="txtBillingAddress" Width="300px" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<asp:Label ID="Label6"
                            runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
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
                        <asp:TextBox runat="server" ID="txtBillingCity" Width="300px" CssClass="defaultWidth easyui-validatebox" data-options="required:true" />&nbsp;&nbsp;<asp:Label ID="Label7"
                            runat="server" Text="*" Font-Size="11px" ForeColor="Red"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <th align="left">Country:
                    </th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlBillingCountry" />
                    </td>
                </tr>
                <tr>
                    <th align="left">Tax Code:</th>
                    <td>
                        <asp:DropDownList runat="server" ID="dlBillToTaxId" />
                    </td>
                </tr>
                <tr>
                    <th align="left">Telephone:
                    </th>
                    <td>
                        <asp:TextBox runat="server" ID="txtBillingTel" Width="300px" />
                    </td>
                </tr>
                <tr>
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
        </div>
    </div>
    <div id="Approvepanel" class="easyui-panel" title="Upload Attachments" style="width: 900px; height: auto; padding: 10px; background: #fafafa;">
        <table>
            <tr>

                <td class="tb2">
                    <ajaxToolkit:AsyncFileUpload runat="server" ID="fup1" OnClientUploadError="uploadError"
                        OnClientUploadStarted="StartUpload" OnClientUploadComplete="UploadComplete" CompleteBackColor="Lime"
                        UploaderStyle="Traditional" ErrorBackColor="Red" UploadingBackColor="#66CCFF"
                        OnUploadedComplete="fup1_UploadedComplete" CssClass="mytb2" />
                    <asp:Label runat="server" ID="lbFupMsg"></asp:Label>
                    <div id="FupMsg">
                    </div>
                    <asp:HiddenField ID="HidRowid" runat="server" />
                    <script type="text/javascript">

                        window.onload = function () {
                            var rowid = $("#<%=HidRowid.ClientID %>").val();
                            if (rowid != "") {
                                ShowFilesDiv(rowid);
                            }
                        }
                        function uploadError(sender, args) {
                            // console.log(args);
                            $("#<%=lbFupMsg.ClientID %>").html('Error during upload');
                        }

                        function StartUpload(sender, args) {
                            $("#<%=lbFupMsg.ClientID %>").html('<img src="../../Images/loading2.gif">');
                        }

                        function UploadComplete(sender, args) {
                            var rowid = $("#<%=HidRowid.ClientID %>").val();
                            ShowFilesDiv(rowid);
                        }

                        function ShowFilesDiv(rowid) {
                            PageMethods.GetFiles(rowid, "",
                    function (pagedResult, eleid, methodName) {
                        $("#<%=lbFupMsg.ClientID %>").html('');
                        $('#FupMsg').html(pagedResult);
                    },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                    $('#FupMsg').html("");
                });
                }
                    </script>

                </td>
            </tr>
        </table>
    </div>

    <script type="text/javascript">
        $(function () {
            var tab_shipto = $('#mytab').tabs('getTab', 1).panel('options').tab;

            var tab_billto = $('#mytab').tabs('getTab', 2).panel('options').tab;

            var HasShipto = $("input[name='HasShipto']:checked").val();

            var HasBilling = $("input[name='HasBilling']:checked").val();

            if ($.trim(HasShipto) == "1") {

                tab_shipto.show(); $('#mytab').tabs('select', 1);

            } else { tab_shipto.hide(); $('#mytab').tabs('select', 0); }

            if ($.trim(HasBilling) == "1") { tab_billto.show(); $('#mytab').tabs('select', 2); } else { tab_billto.hide(); $('#mytab').tabs('select', 0); }

            ///

            $("input[name='HasShipto']").on("change", function () {

                var HasShipto = $(this).val(); if ($.trim(HasShipto) == "1")

                { tab_shipto.show(); $('#mytab').tabs('select', 1); } else

                { tab_shipto.hide(); $('#mytab').tabs('select', 0); }

            });

            $("input[name='HasBilling']").on("change", function () {

                var HasBilling = $(this).val(); if ($.trim(HasBilling) == "1")

                { tab_billto.show(); $('#mytab').tabs('select', 2); } else

                { tab_billto.hide(); $('#mytab').tabs('select', 0); }

            });


            ////

        })
    </script>
    <script type="text/javascript">
        $(function () {

            $("#btsave").click(function () {

                //$("#btsave").linkbutton('disable');
                //return false;
                $('#aspnetForm').form('submit', {
                    url: 'CreateSAPAccount.aspx?action=save&id=<%=Request["id"]%>',
                    onSubmit: function () {
                        if ($("input[name='ctl00$_main$txtCompanyName']").validatebox('isValid') == false) {
                            $("input[name='ctl00$_main$txtCompanyName']").focus();
                            $.show_warning("Prompt", "Please enter the company name.");
                            return false;
                        }
                        if ($("#dlPaymentTerm").val() == "") {
                            $("#dlPaymentTerm").focus();
                            $.show_warning("Prompt", "Please select PaymentTerm.");
                            return false;
                        }
                        if ($("#CreditAmount").val() == "") {
                            $("#CreditAmount").focus();
                            $.show_warning("Prompt", "Please enter Credit Amount");
                            return false;
                        }
                        if ($("#LegalForm").val() == "") {
                            $("#LegalForm").focus();
                            $.show_warning("Prompt", "Please enter Official Registration no.");
                            return false;
                        }
                        if ($("#ctl00__main_txtAddr1").val() == "") {
                            $("#ctl00__main_txtAddr1").focus();
                            $.show_warning("Prompt", "Please enter Address.");
                            return false;
                        }
                        if ($("#ctl00__main_txtPostCode").val() == "") {
                            $("#ctl00__main_txtPostCode").focus();
                            $.show_warning("Prompt", "Please enter Postal Code.");
                            return false;
                        }
                        if ($("#ctl00__main_txtCity").val() == "") {
                            $("#ctl00__main_txtCity").focus();
                            $.show_warning("Prompt", "Please enter City.");
                            return false;
                        }

                        if ($("#ctl00__main_dlSalesCode").val() == "") {
                            $("#ctl00__main_dlSalesCode").focus();
                            $.show_warning("Prompt", "Please select sales.");
                            return false;
                        }
                        if ($("#ctl00__main_dlISCode").val() == "") {
                            $("#ctl00__main_dlISCode").focus();
                            $.show_warning("Prompt", "Please select inside sales.");
                            return false;
                        }
                        if ($("#ctl00__main_dlOPCode").val() == "") {
                            $("#ctl00__main_dlOPCode").focus();
                            $.show_warning("Prompt", "Please select OP.");
                            return false;
                        }
                        if ($("#PriceGrade").val() == "") {
                            $("#PriceGrade").focus();
                            $.show_warning("Prompt", "Please enter Price Grade.");
                            return false;
                        }
                        $("#loading").show();
                    },
                    success: function (data) {
                        var data = eval('(' + data + ')');
                        $("#loading").hide();
                        if (data.type == "1") {
                            $("#btsave").linkbutton('disable');
                            if (confirm(data.msg + "\ndo you want to another request?")) {
                                window.location.href = "CreateSAPAccount.aspx";
                            }

                        }
                        else {
                            $.show_warning("Prompt", data.msg);
                        }
                    }
                });

                return false;

            })
        })

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

