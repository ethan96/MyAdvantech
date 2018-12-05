<%@ Page Title="MyAdvantech - New SAP Account" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="NewSAPAccount.aspx.cs" Inherits="Admin_NewSAPAccount" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../../Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../Includes/js/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <script src="../../Includes/jquery-ui.js" type="text/javascript"></script>
    <link href="../../Includes/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script src="../../Includes/js/ajaxfileupload.js" type="text/javascript"></script>
    <link rel="stylesheet" href="../../Includes/js/token-input-facebook.css" type="text/css" />
    <style type="text/css">
        ul.token-input-list-facebook {
            overflow: hidden;
            height: auto !important;
            height: 1%;
            border: 1px solid #8496ba;
            cursor: text;
            font-size: 12px;
            font-family: Verdana;
            min-height: 1px;
            z-index: 999;
            margin: 0;
            padding: 0;
            background-color: #fff;
            list-style-type: none;
            clear: left;
            width: 450px;
            display: inline-flex;
        }

            ul.token-input-list-facebook li:hover {
                background-color: #ffffff;
            }

        .myhide {
            display: none;
        }
        .auto-style1 {
            height: 22px;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(
            function () {
                RegSoldToIdTokenInput(); RegSalesIdTokenInput();
            });
        function RegSoldToIdTokenInput() {
            var tokeninputUrl = "";
            tokeninputUrl = "<%System.IO.Path.GetFileName(Request.ApplicationPath);%>/Services/AutoComplete.asmx/GetTokenInputSAPSoldToId";
                $("#<%=txtLinkToCompanyId.ClientID%>").tokenInput(tokeninputUrl,
                {
                    theme: "facebook", searchDelay: 200, minChars: 3, tokenDelimiter: ";", hintText: "Type sold-to id", tokenLimit: 4,
                    preventDuplicates: true, resizeInput: false, resultsLimit: 10,
                    resultsFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span><br/>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    },
                    tokenFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    }
                }
            );
        }

        function RegSalesIdTokenInput() {
            var tokeninputUrl = "";
            tokeninputUrl = "<%System.IO.Path.GetFileName(Request.ApplicationPath);%>/Services/AutoComplete.asmx/GetTokenInputSalesId";
            $("#<%=txtSalesCode.ClientID%>").tokenInput(tokeninputUrl,
                {
                    theme: "facebook", searchDelay: 200, minChars: 2, tokenDelimiter: ";", hintText: "Type name or id", tokenLimit: 1,
                    preventDuplicates: true, resizeInput: false, resultsLimit: 10,
                    resultsFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span><br/>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    },
                    tokenFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    }
                }
            );
            $("#<%=txtInsideSalesCode.ClientID%>").tokenInput(tokeninputUrl,
                {
                    theme: "facebook", searchDelay: 200, minChars: 2, tokenDelimiter: ";", hintText: "Type name or id", tokenLimit: 1,
                    preventDuplicates: true, resizeInput: false, resultsLimit: 10,
                    resultsFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span><br/>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    },
                    tokenFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    }
                }
            );

            $("#<%=txtSONotifyCode.ClientID%>").tokenInput(tokeninputUrl,
                {
                    theme: "facebook", searchDelay: 200, minChars: 2, tokenDelimiter: ";", hintText: "Type name or id", tokenLimit: 1,
                    preventDuplicates: true, resizeInput: false, resultsLimit: 10,
                    resultsFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span><br/>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    },
                    tokenFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    }
                }
            );

            $("#<%=txtOPCode.ClientID%>").tokenInput(tokeninputUrl,
                {
                    theme: "facebook", searchDelay: 200, minChars: 2, tokenDelimiter: ";", hintText: "Type name or id", tokenLimit: 1,
                    preventDuplicates: true, resizeInput: false, resultsLimit: 10,
                    resultsFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span><br/>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    },
                    tokenFormatter: function (data) {
                        return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.id + "</span>" + "<span style='color:gray;'>" + data.name + "</span></li>";
                    }
                }
            );
        }

        function AddToken(tokenId, tokenName, inputId) {
            $("#" + inputId).tokenInput("add", { id: tokenId, name: tokenName });
        }

        function ClearPickedSiebelAccount() {
            $("#<%=txtSiebelAccountInfo.ClientID%>").val(""); $("#<%=hdSiebelAccountRowId.ClientID%>").val("");
        }

        function ShowSearchSiebelAccount(buttonObject) {
            $("#tbodySearchSiebelAccount").empty();
            $("#divSearchSiebelAccount").dialog(
                { modal: true, draggable: true, resizable: true, width: 1000, height: $(window).height() * 0.8 }
            );
        }

        function SiebelAccountPicked(AnchorObj) {
            //console.log("AccountRowId:" + $(AnchorObj).attr("rid"));
            var PickedAccountRowId = $(AnchorObj).attr("rid"); var countryname = $(AnchorObj).attr("country");
            $("#<%=txtSiebelAccountInfo.ClientID%>").val($(AnchorObj).attr("aname") + " (" + PickedAccountRowId + ")");
            $("#<%=txtCity.ClientID%>").val($(AnchorObj).attr("city"));
            $("#<%=txtCompanyName.ClientID%>").val($(AnchorObj).attr("aname"));
            $("#<%=txtPostCode.ClientID%>").val($(AnchorObj).attr("postcode"));
            $("#<%=txtAddr1.ClientID%>").val($(AnchorObj).attr("addr"));
            $("#<%=dlCountryCode.ClientID%> option:contains(" + countryname + ")").attr('selected', 'selected');
            $("#<%=hdSiebelAccountRowId.ClientID%>").val(PickedAccountRowId);
            $("#divSearchSiebelAccount").dialog("close");
            javascript: setTimeout('__doPostBack(\'ctl00$_main$dlCountryCode\',\'\')', 0);
        }

        function SearchSiebelAccount() {
            var inputJsonData = JSON.stringify({ AccountName: $("#txtSiebelAccountNameSearch").val(), SAPOrg: $("#<%=dlOrgID.ClientID%>").val() });
            $.ajax({
                type: "POST",
                url: "NewSAPAccount.aspx/GetSiebelAccount",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: inputJsonData,
                success: function (retData) {
                    var idlist = retData.d;
                    $("#tbodySearchSiebelAccount").empty(); var SearchSiebelHtml = "";
                    $.each(idlist, function (idx, item) {
                        SearchSiebelHtml +=
                            "<tr>" +
                            "<td><a aname='" + item.account_name + "' rid='" + item.row_id + "' country='" + item.country + "' city='" + item.city + "' postcode='" + item.postcode + "' addr='" + item.addr + "' href='javascript:void(0)' onclick='SiebelAccountPicked(this)'>Pick</a></td>" +
                            "<td>" + item.account_name + "</td>" +
                            "<td align='center'>" + item.RBU + "</td>" +
                            "<td align='center'>" + item.account_status + "</td>" +
                            "<td align='center'>" + item.primary_sales + "</td>" +
                            "<td>" + item.country + ", " + item.postcode + ", " + item.city + "</td>" +
                            "</tr>";
                    });
                    $("#tbodySearchSiebelAccount").html(SearchSiebelHtml);
                }
            });
        }

        function ShowSearchSAPCompanyId(buttonObject) {
            console.log("buttonObject ID:" + buttonObject.id);
            inputJsonData = "";
            if (buttonObject.id == "btnChkDupCompId") {
                inputJsonData = JSON.stringify({ erpid: $("#<%=txtCompanyId.ClientID%>").val(), cname: "" });
            }
            else {
                if (buttonObject.id == "btnChkDupCompName")
                    inputJsonData = JSON.stringify({ erpid: "", cname: $("#<%=txtCompanyName.ClientID%>").val() });
            }
            $.ajax({
                type: "POST",
                url: "NewSAPAccount.aspx/GetSAPCompanyById",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: inputJsonData,
                success: function (retData) {
                    var idlist = retData.d;
                    $("#tbodySearchCompanyId").empty(); var SearchCompanyIdHtml = "";
                    $.each(idlist, function (idx, item) {
                        //console.log(item.company_id);
                        SearchCompanyIdHtml += "<tr><td>" + item.company_id + "</td><td>" + item.org_id + "</td><td>" + item.company_name + "</td></tr>";
                    });
                    $("#tbodySearchCompanyId").html(SearchCompanyIdHtml);
                    $("#divSearchCompanyId").dialog(
                        {
                            modal: true, draggable: true, resizable: true, width: 600, height: $(window).height() * 0.5
                        }
                    );
                }
            });
        }

    </script>
    <h3>New SAP Account Creation</h3>
    <br />
    <asp:HyperLink runat="server" ID="hyNewReq" NavigateUrl="~/Admin/NC/NewSAPAccount.aspx" Text="Submit a New Request" /><br />
    <asp:HyperLink runat="server" ID="hyToReqList" NavigateUrl="~/Admin/NC/ReqList.aspx" Text="List of All Requests" />
    <div id="divWholeForm" onkeypress="javascript: return event.keyCode != 13;">
        <asp:HiddenField runat="server" ID="ApplicationId" />
        <table width="100%">
            <tr>
                <td>
                    <b>Account Group:</b>
                    <asp:DropDownList runat="server" ID="dlAccountGrp" AutoPostBack="true" OnSelectedIndexChanged="dlAccountGrp_SelectedIndexChanged" Width="100px">
                        <asp:ListItem Text="Sold-to" Value="Z001" />
                        <asp:ListItem Text="Ship-to" Value="Z002" />
                        <asp:ListItem Text="Bill-to" Value="Z003" />
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" runat="server" id="tbWholeForm" visible="false">
                        <tr>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upSAPOrgOfficeGrp" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <table>
                                            <tr>
                                                <th align="left">Sales Org.</th>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlOrgID" Width="170px" AutoPostBack="true" OnSelectedIndexChanged="dlOrgID_SelectedIndexChanged">
                                                        <asp:ListItem Text="ATW/Intercon (TW01)" Value="TW01" />
                                                    </asp:DropDownList>
                                                </td>
                                                <th align="left">Sales Office:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" Width="200px" ID="dlSalesOffice" AutoPostBack="true" OnSelectedIndexChanged="dlSalesOffice_SelectedIndexChanged" /></td>
                                                <th align="left">Sales Group:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" Width="200px" ID="dlSalesGroup" /></td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upLoadSalesIDs" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Timer runat="server" ID="TimerLoadSalesIDs" Enabled="false" Interval="300" OnTick="TimerLoadSalesIDs_Tick" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <table width="700px">
                                    <tr>
                                        <th align="left">Sales (VE):</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtSalesCode" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left">Sales 2 (Z2):</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtInsideSalesCode" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left">SO Notify Person (ZV):</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtSONotifyCode" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left">OP (ER):</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtOPCode" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trKUNNR" visible="true">
                            <td>
                                <table>
                                    <tr valign="top">
                                        <th align="left">Sold-to company Id:</th>
                                        <td>
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCompanyId" Width="90px" AutoPostBack="true" OnTextChanged="txtCompanyId_TextChanged" /></td>
                                                    <td>
                                                        <input type="button" id="btnChkDupCompId" value="Search by company Id" onclick="ShowSearchSAPCompanyId(this)" style="display: block" /></td>
                                                    <td style="font-size: x-small; height: 15px">
                                                        <asp:UpdatePanel runat="server" ID="upERPID" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <asp:Label runat="server" ID="lbDubCompanyIdMsg" Font-Bold="true" ForeColor="Tomato" Font-Size="XX-Small" />
                                                            </ContentTemplate>
                                                            <Triggers>
                                                                <asp:AsyncPostBackTrigger ControlID="txtCompanyId" EventName="TextChanged" />
                                                            </Triggers>
                                                        </asp:UpdatePanel>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="trLinkToKUNNR" runat="server" visible="false">
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Link to Sold-to Id:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtLinkToCompanyId" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Company Name:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtCompanyName" Width="350px" />
                                        </td>
                                        <td>
                                            <input type="button" id="btnChkDupCompName" value="Search by company name" onclick="ShowSearchSAPCompanyId(this)" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Corresponding Siebel Account:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtSiebelAccountInfo" Width="300px" ReadOnly="true" />
                                            <asp:HiddenField runat="server" ID="hdSiebelAccountRowId" />
                                        </td>
                                        <td>
                                            <input type="button" id="btnPickSiebelAccount" value="Pick" onclick="ShowSearchSiebelAccount(this)" />
                                        </td>
                                        <td>
                                            <input type="button" id="btnClearPickedSiebelAccount" value="Clear" onclick="ClearPickedSiebelAccount()" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Comments:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtAddrNotes" /></td>
                                        <th align="left">Search Term1:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtSearchTerm1" Width="120px" /></td>
                                        <th align="left">Search Term2:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtSearchTerm2" Width="120px" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Address1:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtAddr1" /></td>
                                        <th align="left">Address2:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtAddr2" /></td>
                                        <th align="left">Address3:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtAddr3" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Country:</th>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upCountryCodes" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DropDownList runat="server" ID="dlCountryCode" AutoPostBack="true" OnSelectedIndexChanged="dlCountryCode_SelectedIndexChanged" />
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="dlOrgId" EventName="SelectedIndexChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                        <th align="left">City:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtCity" Width="110px" /></td>
                                        <th align="left">Postal Code:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtPostCode" Width="70px" /></td>
                                        <th align="left">Tax Juri.:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtTaxJuri" Width="80px"></asp:TextBox></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upTransZone" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <table>
                                            <tr>
                                                <th>Transport zone:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlTransZone" Width="195px" /></td>
                                                <th>Time zone:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlTimeZone" Width="120px" /></td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="dlCountryCode" EventName="SelectedIndexChanged" />
                                        <asp:AsyncPostBackTrigger ControlID="dlOrgId" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Region (State, Provice, County)</th>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upRegion" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DropDownList runat="server" ID="dlRegion" Width="170px" />
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="dlCountryCode" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="dlOrgId" EventName="SelectedIndexChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                        <th align="left">District:</th>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upDistrict" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DropDownList runat="server" ID="dlDistrict" />
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="dlCountryCode" EventName="SelectedIndexChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="dlOrgId" EventName="SelectedIndexChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Telephone:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtTelephone" />&nbsp;<asp:TextBox runat="server" ID="txtTelExt" Width="30px" /></td>
                                        <th align="left">FAX:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtFAX" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Contact Person F/L Name:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtContactPersonFName" Width="50px" /></td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtContactPersonLName" Width="50px" />
                                        </td>
                                        <th align="left">Contact Email:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtContactPersonEmail" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table width="600px">
                                    <tr>
                                        <th align="left">Official Reg. no.:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtTaxNum1" /></td>
                                        <th align="left">DUNS Number:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtDUNSNo" /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">D&B Payment Index:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtDBPayIdx" /></td>
                                        <th align="left">VAT Number:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtVATNo" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Website URL:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtWebSiteURL" Width="220px" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table width="100%">
                                    <tr>
                                        <th align="left">Shipping Condition:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlShipConds" /></td>
                                        <th align="left">Payment Term:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlPayTerms" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trCreditLimit" visible="false">
                            <td>
                                <table width="100%" style="border-style: groove">
                                    <tr>
                                        <td>
                                            <asp:CheckBox runat="server" ID="cbCreditLimit" Text="Specify Credit Limit?" Font-Bold="true"
                                                AutoPostBack="true" OnCheckedChanged="cbCreditLimit_CheckedChanged" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upCreditLimit" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <table runat="server" id="tbCreditLimit" visible="false" width="100%">
                                                        <tr>
                                                            <th align="left">Credit Amount Currency:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlCreditAmtCurr">
                                                                    <asp:ListItem Text="USD" Value="USD" />
                                                                    <asp:ListItem Text="TWD" Value="TWD" />
                                                                </asp:DropDownList>
                                                            </td>
                                                            <th align="left">Credit Limit Amount:</th>
                                                            <td>
                                                                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1"
                                                                    TargetControlID="txtCreditUSDAmt" FilterType="Numbers" FilterMode="ValidChars" />
                                                                <asp:TextBox runat="server" ID="txtCreditUSDAmt" Width="40px" />
                                                            </td>
                                                            <th align="left">Risk Category:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlCreditAmtRiskCat" />
                                                            </td>
                                                            <th align="left">Cred.rep.grp:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlCredRepGrp" Width="150px" /></td>
                                                        </tr>
                                                    </table>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="cbCreditLimit" EventName="CheckedChanged" />
                                                    <asp:AsyncPostBackTrigger ControlID="dlOrgId" EventName="SelectedIndexChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Inco Term:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlIncoTerms" /></td>
                                        <th align="left">Inco text:</th>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtIncotxt" Width="130px" /></td>
                                        <th align="left">Industry:</th>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upIndustry" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DropDownList runat="server" ID="dlIndustry">
                                                        <asp:ListItem Text="1000 (Taiwan)" Value="1000" />
                                                        <asp:ListItem Text="2000 (America)" Value="2000" />
                                                        <asp:ListItem Text="3000 (Europe)" Value="3000" />
                                                        <asp:ListItem Text="4000 (China)" Value="4000" />
                                                        <asp:ListItem Text="5000 (Asia - Others)" Value="5000" />
                                                        <asp:ListItem Text="BRCT (Brazil Contribuinte)" Value="BRCT" />
                                                        <asp:ListItem Text="BRNC (Brazil Non-Contribu.)" Value="BRNC" />
                                                    </asp:DropDownList>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="dlOrgID" EventName="SelectedIndexChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>

                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="industry">
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Industry Code 1:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlMktIndustryCode1" />
                                        </td>
                                        <th align="left">Industry Code 2:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlMktIndustryCode2" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Customer Group:</th>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upCustGrp" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:DropDownList runat="server" ID="dlCustGrp" />
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="dlOrgID" EventName="SelectedIndexChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                        <td>
                                            <table>
                                                <tr>
                                                    <th align="left">Tax Code (MWST):</th>
                                                    <td>
                                                        <asp:DropDownList runat="server" ID="dlMWSTTaxCode" /></td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table>
                                                <tr>
                                                    <th align="left">Tax Code (UTXJ):</th>
                                                    <td>
                                                        <asp:DropDownList runat="server" ID="dlUTXJTaxCode" /></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Account Assignment Group:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlAccAssignGrp">
                                                <asp:ListItem Text="Domestic Revenues (01)" Value="01" />
                                                <asp:ListItem Text="Foreign Revenues (02)" Value="02" />
                                                <asp:ListItem Text="Affiliate Comp. Rev. (03)" Value="03" />                                                
                                            </asp:DropDownList>
                                        </td>
                                        <th align="left">Customer Class:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlCustClass">
                                                <asp:ListItem Text="External Customer (03)" Value="03" />
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upPriceGrades" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <table runat="server" id="tbPriceGrades">
                                            <tr>
                                                <th align="left">Price Grade (Condition Group 1~4):</th>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlCondGrp1">
                                                        <asp:ListItem Text="N/A" Value="" />
                                                        <asp:ListItem Value="A0" />
                                                        <asp:ListItem Value="A1" />
                                                        <asp:ListItem Value="A2" />
                                                        <asp:ListItem Value="A3" />
                                                        <asp:ListItem Value="A4" />
                                                        <asp:ListItem Value="A5" />
                                                        <asp:ListItem Value="A6" />
                                                        <asp:ListItem Value="A7" />
                                                        <asp:ListItem Value="A8" />
                                                        <asp:ListItem Value="BR" />
                                                        <asp:ListItem Value="C0" />
                                                        <asp:ListItem Value="C1" />
                                                        <asp:ListItem Value="C2" />
                                                        <asp:ListItem Value="C3" />
                                                        <asp:ListItem Value="C4" />
                                                        <asp:ListItem Value="C5" />
                                                        <asp:ListItem Value="C6" />
                                                        <asp:ListItem Value="C9" />
                                                        <asp:ListItem Value="CC" />
                                                        <asp:ListItem Value="E0" />
                                                        <asp:ListItem Value="E1" />
                                                        <asp:ListItem Value="E2" />
                                                        <asp:ListItem Value="E3" />
                                                        <asp:ListItem Value="E4" />
                                                        <asp:ListItem Value="E5" />
                                                        <asp:ListItem Value="E6" />
                                                        <asp:ListItem Value="E8" />
                                                        <asp:ListItem Value="E9" />
                                                        <asp:ListItem Value="K0" />
                                                        <asp:ListItem Value="K1" />
                                                        <asp:ListItem Value="K2" />
                                                        <asp:ListItem Value="K3" />
                                                        <asp:ListItem Value="K4" />
                                                        <asp:ListItem Value="K5" />
                                                        <asp:ListItem Value="K6" />
                                                        <asp:ListItem Value="K8" />
                                                        <asp:ListItem Value="K9" />
                                                        <asp:ListItem Value="L0" Selected="True" />
                                                        <asp:ListItem Value="L1" />
                                                        <asp:ListItem Value="LS" />
                                                        <asp:ListItem Value="MS" />
                                                        <asp:ListItem Value="P0" />
                                                        <asp:ListItem Value="P1" />
                                                        <asp:ListItem Value="P2" />
                                                        <asp:ListItem Value="P3" />
                                                        <asp:ListItem Value="P4" />
                                                        <asp:ListItem Value="P5" />
                                                        <asp:ListItem Value="P6" />
                                                        <asp:ListItem Value="P7" />
                                                        <asp:ListItem Value="P8" />
                                                        <asp:ListItem Value="Q5" />
                                                        <asp:ListItem Value="Q6" />
                                                        <asp:ListItem Value="R0" />
                                                        <asp:ListItem Value="R1" />
                                                        <asp:ListItem Value="R2" />
                                                        <asp:ListItem Value="R3" />
                                                        <asp:ListItem Value="R5" />
                                                        <asp:ListItem Value="R6" />
                                                        <asp:ListItem Value="R7" />
                                                        <asp:ListItem Value="R8" />
                                                        <asp:ListItem Value="X1" />
                                                        <asp:ListItem Value="X2" />
                                                        <asp:ListItem Value="X3" />
                                                        <asp:ListItem Value="X4" />
                                                        <asp:ListItem Value="X5" />
                                                        <asp:ListItem Value="X7" />
                                                        <asp:ListItem Value="X8" />
                                                        <asp:ListItem Value="X9" />
                                                        <asp:ListItem Value="Y1" />
                                                        <asp:ListItem Value="ZZ" />
                                                    </asp:DropDownList>
                                                    <asp:DropDownList runat="server" ID="dlCondGrp2">
                                                        <asp:ListItem Text="N/A" Value="" />
                                                        <asp:ListItem Value="A0" />
                                                        <asp:ListItem Value="A1" />
                                                        <asp:ListItem Value="A2" />
                                                        <asp:ListItem Value="A3" />
                                                        <asp:ListItem Value="A4" />
                                                        <asp:ListItem Value="A5" />
                                                        <asp:ListItem Value="A6" />
                                                        <asp:ListItem Value="A7" />
                                                        <asp:ListItem Value="A8" />
                                                        <asp:ListItem Value="BR" />
                                                        <asp:ListItem Value="C0" />
                                                        <asp:ListItem Value="C1" />
                                                        <asp:ListItem Value="C2" />
                                                        <asp:ListItem Value="C3" />
                                                        <asp:ListItem Value="C4" />
                                                        <asp:ListItem Value="C5" />
                                                        <asp:ListItem Value="C6" />
                                                        <asp:ListItem Value="C9" />
                                                        <asp:ListItem Value="CC" />
                                                        <asp:ListItem Value="E0" />
                                                        <asp:ListItem Value="E1" />
                                                        <asp:ListItem Value="E2" />
                                                        <asp:ListItem Value="E3" />
                                                        <asp:ListItem Value="E4" />
                                                        <asp:ListItem Value="E5" />
                                                        <asp:ListItem Value="E6" />
                                                        <asp:ListItem Value="E8" />
                                                        <asp:ListItem Value="E9" />
                                                        <asp:ListItem Value="K0" />
                                                        <asp:ListItem Value="K1" />
                                                        <asp:ListItem Value="K2" />
                                                        <asp:ListItem Value="K3" />
                                                        <asp:ListItem Value="K4" />
                                                        <asp:ListItem Value="K5" />
                                                        <asp:ListItem Value="K6" />
                                                        <asp:ListItem Value="K8" />
                                                        <asp:ListItem Value="K9" />
                                                        <asp:ListItem Value="L0" Selected="True" />
                                                        <asp:ListItem Value="L1" />
                                                        <asp:ListItem Value="LS" />
                                                        <asp:ListItem Value="MS" />
                                                        <asp:ListItem Value="P0" />
                                                        <asp:ListItem Value="P1" />
                                                        <asp:ListItem Value="P2" />
                                                        <asp:ListItem Value="P3" />
                                                        <asp:ListItem Value="P4" />
                                                        <asp:ListItem Value="P5" />
                                                        <asp:ListItem Value="P6" />
                                                        <asp:ListItem Value="P7" />
                                                        <asp:ListItem Value="P8" />
                                                        <asp:ListItem Value="Q5" />
                                                        <asp:ListItem Value="Q6" />
                                                        <asp:ListItem Value="R0" />
                                                        <asp:ListItem Value="R1" />
                                                        <asp:ListItem Value="R2" />
                                                        <asp:ListItem Value="R3" />
                                                        <asp:ListItem Value="R5" />
                                                        <asp:ListItem Value="R6" />
                                                        <asp:ListItem Value="R7" />
                                                        <asp:ListItem Value="R8" />
                                                        <asp:ListItem Value="X1" />
                                                        <asp:ListItem Value="X2" />
                                                        <asp:ListItem Value="X3" />
                                                        <asp:ListItem Value="X4" />
                                                        <asp:ListItem Value="X5" />
                                                        <asp:ListItem Value="X7" />
                                                        <asp:ListItem Value="X8" />
                                                        <asp:ListItem Value="X9" />
                                                        <asp:ListItem Value="Y1" />
                                                        <asp:ListItem Value="ZZ" />
                                                    </asp:DropDownList>
                                                    <asp:DropDownList runat="server" ID="dlCondGrp3">
                                                        <asp:ListItem Text="N/A" Value="" />
                                                        <asp:ListItem Value="A0" />
                                                        <asp:ListItem Value="A1" />
                                                        <asp:ListItem Value="A2" />
                                                        <asp:ListItem Value="A3" />
                                                        <asp:ListItem Value="A4" />
                                                        <asp:ListItem Value="A5" />
                                                        <asp:ListItem Value="A6" />
                                                        <asp:ListItem Value="A7" />
                                                        <asp:ListItem Value="A8" />
                                                        <asp:ListItem Value="BR" />
                                                        <asp:ListItem Value="C0" />
                                                        <asp:ListItem Value="C1" />
                                                        <asp:ListItem Value="C2" />
                                                        <asp:ListItem Value="C3" />
                                                        <asp:ListItem Value="C4" />
                                                        <asp:ListItem Value="C5" />
                                                        <asp:ListItem Value="C6" />
                                                        <asp:ListItem Value="C9" />
                                                        <asp:ListItem Value="CC" />
                                                        <asp:ListItem Value="E0" />
                                                        <asp:ListItem Value="E1" />
                                                        <asp:ListItem Value="E2" />
                                                        <asp:ListItem Value="E3" />
                                                        <asp:ListItem Value="E4" />
                                                        <asp:ListItem Value="E5" />
                                                        <asp:ListItem Value="E6" />
                                                        <asp:ListItem Value="E8" />
                                                        <asp:ListItem Value="E9" />
                                                        <asp:ListItem Value="K0" />
                                                        <asp:ListItem Value="K1" />
                                                        <asp:ListItem Value="K2" />
                                                        <asp:ListItem Value="K3" />
                                                        <asp:ListItem Value="K4" />
                                                        <asp:ListItem Value="K5" />
                                                        <asp:ListItem Value="K6" />
                                                        <asp:ListItem Value="K8" />
                                                        <asp:ListItem Value="K9" />
                                                        <asp:ListItem Value="L0" Selected="True" />
                                                        <asp:ListItem Value="L1" />
                                                        <asp:ListItem Value="LS" />
                                                        <asp:ListItem Value="MS" />
                                                        <asp:ListItem Value="P0" />
                                                        <asp:ListItem Value="P1" />
                                                        <asp:ListItem Value="P2" />
                                                        <asp:ListItem Value="P3" />
                                                        <asp:ListItem Value="P4" />
                                                        <asp:ListItem Value="P5" />
                                                        <asp:ListItem Value="P6" />
                                                        <asp:ListItem Value="P7" />
                                                        <asp:ListItem Value="P8" />
                                                        <asp:ListItem Value="Q5" />
                                                        <asp:ListItem Value="Q6" />
                                                        <asp:ListItem Value="R0" />
                                                        <asp:ListItem Value="R1" />
                                                        <asp:ListItem Value="R2" />
                                                        <asp:ListItem Value="R3" />
                                                        <asp:ListItem Value="R5" />
                                                        <asp:ListItem Value="R6" />
                                                        <asp:ListItem Value="R7" />
                                                        <asp:ListItem Value="R8" />
                                                        <asp:ListItem Value="X1" />
                                                        <asp:ListItem Value="X2" />
                                                        <asp:ListItem Value="X3" />
                                                        <asp:ListItem Value="X4" />
                                                        <asp:ListItem Value="X5" />
                                                        <asp:ListItem Value="X7" />
                                                        <asp:ListItem Value="X8" />
                                                        <asp:ListItem Value="X9" />
                                                        <asp:ListItem Value="Y1" />
                                                        <asp:ListItem Value="ZZ" />
                                                    </asp:DropDownList>
                                                    <asp:DropDownList runat="server" ID="dlCondGrp4">
                                                        <asp:ListItem Text="N/A" Value="" />
                                                        <asp:ListItem Value="A0" />
                                                        <asp:ListItem Value="A1" />
                                                        <asp:ListItem Value="A2" />
                                                        <asp:ListItem Value="A3" />
                                                        <asp:ListItem Value="A4" />
                                                        <asp:ListItem Value="A5" />
                                                        <asp:ListItem Value="A6" />
                                                        <asp:ListItem Value="A7" />
                                                        <asp:ListItem Value="A8" />
                                                        <asp:ListItem Value="BR" />
                                                        <asp:ListItem Value="C0" />
                                                        <asp:ListItem Value="C1" />
                                                        <asp:ListItem Value="C2" />
                                                        <asp:ListItem Value="C3" />
                                                        <asp:ListItem Value="C4" />
                                                        <asp:ListItem Value="C5" />
                                                        <asp:ListItem Value="C6" />
                                                        <asp:ListItem Value="C9" />
                                                        <asp:ListItem Value="CC" />
                                                        <asp:ListItem Value="E0" />
                                                        <asp:ListItem Value="E1" />
                                                        <asp:ListItem Value="E2" />
                                                        <asp:ListItem Value="E3" />
                                                        <asp:ListItem Value="E4" />
                                                        <asp:ListItem Value="E5" />
                                                        <asp:ListItem Value="E6" />
                                                        <asp:ListItem Value="E8" />
                                                        <asp:ListItem Value="E9" />
                                                        <asp:ListItem Value="K0" />
                                                        <asp:ListItem Value="K1" />
                                                        <asp:ListItem Value="K2" />
                                                        <asp:ListItem Value="K3" />
                                                        <asp:ListItem Value="K4" />
                                                        <asp:ListItem Value="K5" />
                                                        <asp:ListItem Value="K6" />
                                                        <asp:ListItem Value="K8" />
                                                        <asp:ListItem Value="K9" />
                                                        <asp:ListItem Value="L0" Selected="True" />
                                                        <asp:ListItem Value="L1" />
                                                        <asp:ListItem Value="LS" />
                                                        <asp:ListItem Value="MS" />
                                                        <asp:ListItem Value="P0" />
                                                        <asp:ListItem Value="P1" />
                                                        <asp:ListItem Value="P2" />
                                                        <asp:ListItem Value="P3" />
                                                        <asp:ListItem Value="P4" />
                                                        <asp:ListItem Value="P5" />
                                                        <asp:ListItem Value="P6" />
                                                        <asp:ListItem Value="P7" />
                                                        <asp:ListItem Value="P8" />
                                                        <asp:ListItem Value="Q5" />
                                                        <asp:ListItem Value="Q6" />
                                                        <asp:ListItem Value="R0" />
                                                        <asp:ListItem Value="R1" />
                                                        <asp:ListItem Value="R2" />
                                                        <asp:ListItem Value="R3" />
                                                        <asp:ListItem Value="R5" />
                                                        <asp:ListItem Value="R6" />
                                                        <asp:ListItem Value="R7" />
                                                        <asp:ListItem Value="R8" />
                                                        <asp:ListItem Value="X1" />
                                                        <asp:ListItem Value="X2" />
                                                        <asp:ListItem Value="X3" />
                                                        <asp:ListItem Value="X4" />
                                                        <asp:ListItem Value="X5" />
                                                        <asp:ListItem Value="X7" />
                                                        <asp:ListItem Value="X8" />
                                                        <asp:ListItem Value="X9" />
                                                        <asp:ListItem Value="Y1" />
                                                        <asp:ListItem Value="ZZ" />
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="dlOrgID" EventName="SelectedIndexChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Price Group:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlPriceGrp" />
                                        </td>
                                        <th align="left">Currency:</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlCurrency">
                                                <asp:ListItem Value="AUD" />
                                                <asp:ListItem Value="BRL" />
                                                <asp:ListItem Value="CNY" />
                                                <asp:ListItem Value="EUR" />
                                                <asp:ListItem Value="GBP" />
                                                <asp:ListItem Value="IDR" />
                                                <asp:ListItem Value="INR" />
                                                <asp:ListItem Value="JPY" />
                                                <asp:ListItem Value="KRW" />
                                                <asp:ListItem Value="MXN" />
                                                <asp:ListItem Value="MYR" />
                                                <asp:ListItem Value="SGD" />
                                                <asp:ListItem Value="THB" />
                                                <asp:ListItem Value="TWD" />
                                                <asp:ListItem Value="USD" Selected="True" />
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr id="addcust">
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Additional Customer Data:</th>
                                        <th align="left">Attribute 1</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlKATR1" /></td>
                                        <th align="left">Attribute 9</th>
                                        <td>
                                            <asp:DropDownList runat="server" ID="dlKATR9" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table width="700px">
                                    <tr style="vertical-align: top">
                                        <td style="width: 50%">
                                            <b>Upload Files</b><br />
                                            <input id="fileupload1" name="file[]" type="file" multiple />
                                            <br />
                                            <input id="fileupload2" name="file[]" type="file" multiple />
                                            <br />
                                            <input id="fileupload3" name="file[]" type="file" multiple />
                                            &nbsp;<input id="btnUploadFiles" type="button" value="Upload" onclick="UploadFile(1)" /><br />
                                            <script type="text/javascript">
                                                function UploadFile(fup_seq) {
                                                    if (fup_seq > 3) {
                                                        console.log("ShowUploadedFiles");
                                                        javascript: __doPostBack('ctl00$_main$btnShowUploadedFiles', '');
                                                    }
                                                    else {
                                                        //console.log("appid:" + $("#<%=this.ApplicationId.ClientID%>").val());
                                                        $.ajaxFileUpload({
                                                            url: "soldto_file_upload.ashx",
                                                            data: { appid: $("#<%=this.ApplicationId.ClientID%>").val() },
                                                            secureuri: false,
                                                            fileElementId: 'fileupload' + fup_seq.toString(),
                                                            dataType: "json",
                                                            success:
                                                                function (data, status) {
                                                                    //console.log("good");
                                                                    $.each(data,
                                                                                function (idx, item) {
                                                                                    if (item.IsUploaded == true) {
                                                                                        UploadFile(++fup_seq);
                                                                                    }
                                                                                    else {
                                                                                        alert(item.ErrorString);
                                                                                    }
                                                                                }
                                                                            );
                                                                },
                                                            error: function (data, status, e) {
                                                                console.log("bad");
                                                                alert(data[0]);
                                                            }
                                                        });
                                                    }

                                                }
                                            </script>
                                        </td>
                                        <td style="width: 50%">
                                            <b>Uploaded Files</b>&nbsp;<asp:LinkButton ForeColor="White" runat="server" ID="btnShowUploadedFiles" Text="Refresh" OnClick="btnShowUploadedFiles_Click" />
                                            <asp:UpdatePanel runat="server" ID="upShowUploadedFiles" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:GridView runat="server" ID="gvUploadedFiles" ShowHeader="false"
                                                        AutoGenerateColumns="false" Width="95%" EnableTheming="false">
                                                        <Columns>
                                                            <asp:TemplateField HeaderText="">
                                                                <ItemTemplate>
                                                                    <asp:HiddenField runat="server" ID="hdRowFileId" Value='<%#Eval("FileId") %>' />
                                                                    <a target="_blank" href='dl_soldto_file.ashx?appid=<%=ApplicationId.Value %>&fid=<%#Eval("FileId") %>'><%#Eval("FILE_NAME") %></a>&nbsp;&nbsp;                                                                    
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                                                <ItemTemplate>
                                                                    <asp:LinkButton runat="server" ID="lnkRowDelUpFile" Text="X" OnClick="lnkRowDelUpFile_Click" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="btnShowUploadedFiles" EventName="Click" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table width="100%">
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upBtnReset" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <table width="500px">
                                                        <tr>
                                                            <td>
                                                                <asp:Button runat="server" ID="btnCreateSAPAccount" Visible="false" Text="Create SAP Account" OnClick="btnCreateSAPAccount_Click" />&nbsp;</td>
                                                            <td>
                                                                <asp:Button runat="server" ID="btnSaveAsApplication" Text="Submit Request" OnClick="btnSaveAsApplication_Click" /></td>
                                                            <td>
                                                                <asp:Button runat="server" ID="btnReset" Text="Reset All Fields" Visible="false" OnClick="btnReset_Click" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="height: 25px">
                                            <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" Font-Size="Large" />
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="btnCreateSAPAccount" EventName="Click" />
                                                    <asp:AsyncPostBackTrigger ControlID="btnSaveAsApplication" EventName="Click" />
                                                    <asp:AsyncPostBackTrigger ControlID="btnApproval" EventName="Click" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table runat="server" id="dviApproval" visible="false" style="border-style: ridge; align-content: center; width:100%">
                                                <tr>
                                                    <td>
                                                        <h3>Approval Block</h3>
                                                        <table style="width: 99%">
                                                            <tr>
                                                                <th align="left" style="width:120px">Ticket ID:</th>
                                                                <td class="auto-style1">
                                                                    <asp:Label runat="server" ID="lbTicketId" /></td>
                                                            </tr>
                                                            <tr>
                                                                <th align="left">Requested By:</th>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lbReqBy" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <th align="left">Requested Date:</th>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lbReqDate" /></td>
                                                            </tr>
                                                            <tr>
                                                                <th align="left">Approval Log:</th>
                                                                <td>
                                                                    <asp:Label runat="server" ID="lbApprovalLog" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <th align="left">Approval Status:</th>
                                                                <td align="left">
                                                                    <asp:RadioButtonList runat="server" ID="rblApprovalStatus" RepeatDirection="Horizontal" RepeatColumns="3">                                                                        
                                                                        <asp:ListItem Text="Approve" Selected="True" />
                                                                        <asp:ListItem Text="Reject" />
                                                                    </asp:RadioButtonList>
                                                                </td>
                                                            </tr>
                                                            <tr valign="top">
                                                                <td colspan="2" valign="top">
                                                                    <b>Comment:</b><br />
                                                                    <asp:TextBox runat="server" ID="txtApprovalComment" TextMode="MultiLine" Rows="5" Columns="3" Width="100%" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="2" align="center">
                                                                    <asp:Button runat="server" ID="btnApproval" Text="Submit" Font-Size="Larger" Font-Bold="true" OnClick="btnApproval_Click" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>
        </table>
    </div>
    <div id="divSearchCompanyId" style="display: none;">
        <table id="tbSearchCompanyId" width="100%">
            <thead>
                <tr>
                    <th>Company Id</th>
                    <th>Org Id</th>
                    <th>Name</th>
                </tr>
            </thead>
            <tbody id="tbodySearchCompanyId"></tbody>
        </table>
    </div>
    <div id="divSearchSiebelAccount" style="display: none;" onkeypress="javascript: if(event.keyCode==13) SearchSiebelAccount();">
        Account Name:<input id="txtSiebelAccountNameSearch" type="text" />&nbsp;<input type="button" id="btnSearchSiebelAccount" value="Search" onclick="SearchSiebelAccount()" />
        <table id="tbSearchSiebelAccount" width="100%">
            <thead>
                <tr>
                    <th>Pick</th>
                    <th>Account Name</th>
                    <th>RBU</th>
                    <th>Account Status</th>
                    <th>Primary Sales Owner</th>
                    <th>Address Info.</th>
                </tr>
            </thead>
            <tbody id="tbodySearchSiebelAccount"></tbody>
        </table>
    </div>
</asp:Content>
