<%@ Page Title="MyAdvantech – Machine Monitoring & Optimization SRP Configurator" Language="VB" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="false" CodeFile="SRP_CartList.aspx.vb" Inherits="Lab_SRP_CartList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
     <script type="text/javascript" src="../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="../EC/Includes/json2.js"></script>
     <link id="ctl00_ebizCss" href="./MyAdvantech–Shopping Cart_files/ebiz.aeu.style.css" rel="stylesheet" type="text/css" />
    <link href="./MyAdvantech–Shopping Cart_files/global.css" rel="Stylesheet" type="text/css" />
    <link href="./MyAdvantech–Shopping Cart_files/base.css" rel="Stylesheet" type="text/css" />
    <link href="./MyAdvantech–Shopping Cart_files/third.css" rel="Stylesheet" type="text/css" />
     <style type="text/css">
        .trEven {
            background-color: #EBEBEB;
        }

        #CMSList .sort {
            cursor: pointer;
        }

        #CMSList .sortASC {
            background: no-repeat right center;
            background-color: #dcdcdc;
            background-image: url("/Images/sort_2.jpg");
        }

        #CMSList .sortDESC {
            background: no-repeat right center;
            background-color: #dcdcdc;
            background-image: url("/Images/sort_1.jpg");
        }

        .divCMSContent.Title {
            font-weight: bold;
            font-size: 18px;
            color: #cc3300;
        }

        .divCMSContent.Code {
            border: #8b4513 1px solid;
            padding-right: 5px;
            padding-left: 5px;
            color: #000066;
            font-family: 'Courier New', Monospace;
            background-color: #ff9933;
        }

        .ratingStar {
            font-size: 0pt;
            width: 13px;
            height: 12px;
            margin: 0px;
            padding: 0px;
            cursor: pointer;
            display: block;
            background-repeat: no-repeat;
        }

        .filledRatingStar {
            background-image: url(../Images/FilledStar.png);
        }

        .emptyRatingStar {
            background-image: url(../Images/EmptyStar.png);
        }

        .savedRatingStar {
            background-image: url(../Images/SavedStar.png);
        }

        .box {
            background: #fff;
        }

        .boxholder {
            clear: both;
            padding: 5px;
            background: #E5E6F4;
        }

        .tab {
            float: left;
            height: 32px;
            width: 102px;
            margin: 0 1px 0 0;
            text-align: center;
            background: #E5E6F4;
        }

        .tabtxt {
            margin: 0;
            color: #fff;
            font-size: 12px;
            font-weight: bold;
            padding: 9px 0 0 0;
        }

        BODY {
            color: #333333;
            font-size: 12px;
            font-family: Arial, Helvetica, sans-serif;
            line-height: 18px;
        }

        SELECT {
            font: 99% arial,helvetica,clean,sans-serif;
        }

        INPUT {
            font: 99% arial,helvetica,clean,sans-serif;
        }

        TEXTAREA {
            font: 99% arial,helvetica,clean,sans-serif;
        }

        PRE {
            font: 100% monospace;
        }

        CODE {
            font: 100% monospace;
        }

        H1 {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        H2 {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        H3 {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        H4 {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        H5 {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        H6 {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        UL {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        OL {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        LI {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        DL {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        DT {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        DD {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        P {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        FORM {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        FIELDSET {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        LEGEND {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        INPUT {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        IMG {
            padding-right: 0px;
            padding-left: 0px;
            padding-bottom: 0px;
            margin: 0px;
            padding-top: 0px;
        }

        IMG {
            border-right: 0px;
            border-top: 0px;
            border-left: 0px;
            border-bottom: 0px;
        }

        FIELDSET {
            border-right: 0px;
            border-top: 0px;
            border-left: 0px;
            border-bottom: 0px;
        }

        LEGEND {
            font-size: 0px;
            height: 0px;
        }

        LABEL {
            cursor: hand;
        }

        INPUT {
            outline: none;
        }

        CITE {
            font: 85% verdana;
        }

        EM {
            font-style: normal;
        }

        CITE SPAN {
            font-weight: bold;
        }

        A {
            color: #004181;
            text-decoration: none;
        }

            A:link {
                text-decoration: none;
            }

            A:visited {
                text-decoration: none;
            }

            A:hover {
                text-decoration: underline;
            }

        .on A:hover {
            text-decoration: none;
        }
    </style>
    <link id="ctl00_Style1" rel="stylesheet" href="./MyAdvantech–Shopping Cart_files/style-General.css" type="text/css" />
    <style type="text/css">
        .modalBackground {
            background-color: Gray;
            filter: alpha(opacity=70);
            opacity: 0.7;
        }

        .modalPopup {
            background-color: #ffffdd;
            border-width: 3px;
            border-style: solid;
            border-color: Gray;
            padding: 3px;
            width: 550px;
        }

        .sampleStyleA {
            background-color: #FFF;
        }

        .sampleStyleB {
            background-color: #FFF;
            font-family: monospace;
            font-size: 10pt;
            font-weight: bold;
        }

        .sampleStyleC {
            background-color: #ddffdd;
            font-family: sans-serif;
            font-size: 10pt;
            font-style: italic;
        }

        .sampleStyleD {
            background-color: Blue;
            color: White;
            font-family: Arial;
            font-size: 10pt;
        }

        .autocomplete {
            background: #E0E0E0;
            position: absolute;
            border: solid 1px;
            overflow-y: scroll;
            overflow-x: auto;
            height: 100px;
            display: none;
        }

        a.accordionContent:link {
            color: #ff0000;
        }

        a.accordionContent:visited {
            color: #0000ff;
        }

        a.accordionContent:hover {
            background: #66ff66;
        }
    </style>

    <script type="text/javascript">
        $(function () {
            var result = storageAvailable('localStorage');

            if (result && result.length > 0) {
                var html = "";
                var totalamount = 0;
                var seq = 1;
                for (var i = 0; i < result.length; i++) {
                    html += "<tr style='background-color:White;white-space:nowrap;'><td align='center'><input type='checkbox' /></td><td align='center'><table><tbody><tr><td><a style='font-weight:bold;'>↑</a></td><td><a style='font-weight:bold;'>↓</a></td></tr></tbody></table></td><td align='center'>" + seq + "</td><td>";
                    html += "<input type='text' readonly='readonly' style='background-color:#EEEEEE;border-color:#CCCCCC;border-width:1px;border-style:solid;width:100px;' /></td>";
                    html += "<td><a href=" + result[i].URL + " target='_blank'>" + result[i].partNo + "</a></td>";
                    html += "<td><input type='text' value=" + result[i].desc + " readonly='readonly' style='background-color:#EEEEEE;border-color:#CCCCCC;border-width:1px;border-style:solid;width:100px;' /></td>";
                    html += "<td align='center'><select style='width:110px;'><option selected='selected' value='0'>without extended warranty</option><option value='19'>AGS-EW-03</option><option value='20'>AGS-EW-06</option><option value='21'>AGS-EW-12</option><option value='22'>AGS-EW-24</option><option value='23'>AGS-EW-36</option></select></td>";
                    html += "<td align='right'><span>NT" + result[i].price + "</span></td><td align='right'><input type='text' value=NT" + result[i].price + " style='width:60px;text-align: right' /></td>";
                    html += "<td align='right'>0.00%</td><td align='right'><input type='text' value=" + result[i].qty + " style='width:30px;text-align: right' /></td>";
                    html += "<td align='right'><input type='text' value=" + result[i].reqDate + " style='width:65px;text-align: right' /></td><td align='right'><span>" + result[i].reqDate + "</span></td>";
                    html += "<td align='right'>NT" + result[i].price + "</td><td><input type='text' style='width:80px;' /></td><td></td></tr>";
                    totalamount += parseInt(result[i].price) || 0;
                    seq += 1;
                }
                $("#cartlist").html(html);
                $("#lbtotal").html(totalamount * 0.75);
            }

            //startTime();
        });

        function storageAvailable(type) {
            try {
                var storage = window[type];
                //jsonobj = [];

                //item = {}
                //item["partNo"] = "ADAM-4520-EE";
                //item["URL"] = "http://my.advantech.com/Product/ProductSearch.aspx?key=adam-4520-ee";
                //item["desc"] = "'ADAM-4520-EE description";
                //item["price"] = "2162";
                //item["qty"] = "1";
                //item["reqDate"] = "2016/11/11";
                //jsonobj.push(item);

                //item1 = {}
                //item1["partNo"] = "EKI-1221-BE";
                //item1["URL"] = "http://my.advantech.com/Product/ProductSearch.aspx?key=eki-1221-be";
                //item1["desc"] = "'EKI-1221-BE description";
                //item1["price"] = "6900";
                //item1["qty"] = "1";
                //item1["reqDate"] = "2016/11/11";
                //jsonobj.push(item1);

                //storage.removeItem('Cart');
                //storage.setItem('Cart', JSON.stringify(jsonobj));
                return JSON.parse(storage.getItem('Cart'));
            }
            catch (e) {
                return false;
            }
        };

        function startTime() {
            var today = new Date();
            var monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            var h = today.getHours();
            var m = today.getMinutes();
            var s = today.getSeconds();
            var month = today.getMonth();
            var year = today.getFullYear();
            m = checkTime(m);
            s = checkTime(s);
            month = monthNames[month];
            document.getElementById('clock').innerHTML =
            h + ":" + m + ":" + s + " " + month + ", " + year;
            var t = setTimeout(startTime, 500);
        };

        function checkTime(i) {
            if (i < 10) { i = "0" + i };
            return i;
        };
    </script>

     <table width="100%" align="center" border="0" cellpadding="0" cellspacing="0">
        <tbody>
            <tr>
                <td align="center">
                    <%--<div>
                        <table width="900px" align="center" border="0" cellpadding="0" cellspacing="0">
                            <tbody>
                                <tr>
                                    <td align="center">
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tbody>
                                                <tr valign="top">
                                                    <td valign="bottom" align="left" style="padding-bottom: 5px">
                                                        <a href="http://my.advantech.com:4002/Home.aspx">
                                                            <img src="./MyAdvantech–Shopping Cart_files/logo2.jpg" alt="" style="border-width:0px;" />
                                                        </a>
                                                    </td>
                                                    <td valign="bottom" align="left">
                                                        <table width="100%" style="font-family: Arial, Helvetica, sans-serif; font-weight: bold; color: #838181;">
                                                            <tbody>
                                                                <tr valign="top">
                                                                    <td align="right">
                                                                        <span >Tc.chen@advantech.com.tw (Advantech Co. Singapore Pte Ltd. )</span>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <table>
                                                                            <tbody>
                                                                                <tr align="left" valign="middle">
                                                                                    <th align="left" style="color: Gray"> </th>
                                                                                    <td> </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td valign="bottom">
                                                                        <table width="100%">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td width="15%" align="center">
                                                                                        <a id="ctl00_hyMyHome" href="http://my.advantech.com:4002/home.aspx">Home</a>
                                                                                    </td>
                                                                                    <td width="4%" align="center">
                                                                                        <img id="ctl00_Image2_home" alt="" src="./MyAdvantech–Shopping Cart_files/fenceline.jpg" style="height:10px;width:1px;border-width:0px;" />
                                                                                    </td>
                                                                                    <td width="15%" align="center"> <a id="ctl00_hyHome" href="http://www.advantech.com/">advantech.com</a> </td>
                                                                                    <td width="4%" align="center">
                                                                                        <img id="ctl00_Image2" alt="" src="./MyAdvantech–Shopping Cart_files/fenceline.jpg" style="height:10px;width:1px;border-width:0px;" />
                                                                                    </td>
                                                                                    <td id="ctl00_ADMIN1_TR" width="7%" align="center">
                                                                                        <a id="ctl00_hyAdmin" href="http://my.advantech.com:4002/Admin/b2b_admin_portal.aspx">Admin</a>
                                                                                    </td>
                                                                                    <td id="ctl00_ADMIN2_TR" width="4%" align="center">
                                                                                        <img id="ctl00_Image6" alt="" src="./MyAdvantech–Shopping Cart_files/fenceline.jpg" style="height:10px;width:1px;border-width:0px;" />
                                                                                    </td>
                                                                                    <td id="ctl00_tdeQuotation" width="7%" align="center"> <a id="ctl00_hyeQuotation" href="http://eq.advantech.com/Home.aspx">eQuotation</a> </td>
                                                                                    <td id="ctl00_tdeQuotation1" width="4%" align="center">
                                                                                        <img id="ctl00_Image9" alt="" src="./MyAdvantech–Shopping Cart_files/fenceline.jpg" style="height:10px;width:1px;border-width:0px;" />
                                                                                    </td>
                                                                                    <td id="ctl00_tdHomeProduct" width="14%" align="center">
                                                                                        <a id="ctl00_hyProduct" href="http://my.advantech.com:4002/Product/Product_Line_New.aspx">Product</a>
                                                                                    </td>
                                                                                    <td id="ctl00_tdHomeProduct1" width="4%" align="center"> <img id="ctl00_Image3" alt="" src="./MyAdvantech–Shopping Cart_files/fenceline.jpg" style="height:10px;width:1px;border-width:0px;" /> </td>
                                                                                    <td id="ctl00_tdHomeResource" width="15%" align="center"> <a id="ctl00_hyRec" href="http://support.advantech.com/OnlineResources/index.aspx" target="_blank">Resources</a> </td>
                                                                                    <td id="ctl00_tdHomeResource1" width="4%" align="center"> <img id="ctl00_Image4" alt="" src="./MyAdvantech–Shopping Cart_files/fenceline.jpg" style="height:10px;width:1px;border-width:0px;" /> </td>
                                                                                    <td id="ctl00_tdHomeSupport" width="10%" align="center"> <a id="ctl00_hySupport" href="http://support.advantech.com.tw/">Support</a> </td>
                                                                                    <td id="ctl00_tdHomeSupport1" width="4%" align="center"> <img id="ctl00_Image5" src="./MyAdvantech–Shopping Cart_files/fenceline.jpg" style="height:10px;width:1px;border-width:0px;" /> </td>
                                                                                    <td width="20%" align="center" nowrap="nowrap"> <a id="ctl00_hyContactUs" href="http://www.advantech.com/contact/">Contact Us</a> </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div>
                        <table id="ctl00_table2" style="margin-bottom: 5px;" width="900px" align="center" class="day" border="0">
                            <tbody>
                                <tr>
                                    <td width="2"> </td>
                                    <td width="510" valign="middle" align="left">
                                        <table width="100%">
                                            <tbody>
                                                <tr>
                                                    <td id="ctl00_tdTime" width="200">
                                                        <span class="testh1" id="clock"><font size="1px"></font></span>
                                                    </td>
                                                    <td id="ctl00_tdRole"> <span id="ctl00_lblRole"></span> </td>
                                                    <td>
                                                        <a id="ctl00_hyCompanyId" href="http://my.advantech.com:4002/DM/CustomerDashboard.aspx?ERPID=ASPA001" style="font-weight:bold;">(ASPA001)</a>
                                                    </td>
                                                    <td> <span id="ctl00_lbRBU" style="font-weight:bold;">(ACL)</span> </td>
                                                    <td>
                                                        <table width="100%">
                                                            <tbody>
                                                                <tr>
                                                                    <td>
                                                                        <input id="ctl00_LoginView3_LoginStatus1" type="image" name="ctl00$LoginView3$LoginStatus1$ctl01" src="./MyAdvantech–Shopping Cart_files/logout.jpg" alt="Logout" style="border-width:0px;" />
                                                                    </td>
                                                                    <td> <a id="ctl00_LoginView3_hlMyProfile" href="http://my.advantech.com:4002/My/MyProfile.aspx"><img src="./MyAdvantech–Shopping Cart_files/Profile.JPG" alt="" style="border-width:0px;" /></a></td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                    <td id="ctl00_tdSearch" width="50" valign="middle" align="left"> <span class="testh1">SEARCH</span> </td>
                                    <td valign="middle" width="100" align="left">
                                        <select name="ctl00$dlSearchOption" id="ctl00_dlSearchOption" style="height:20px;">
                                            <option selected="selected" value="Product">Product</option>
                                            <option value="Material">Marketing material &amp; Support</option>
                                            <option value="Websites">Websites</option>
                                        </select>
                                    </td>
                                    <td valign="middle" width="80" align="left">
                                        <div id="ctl00_PanelSearch">
                                            <input name="ctl00$txtSearchKey" type="text" id="ctl00_txtSearchKey" autocomplete="off" />
                                        </div>
                                    </td>
                                    <td align="left" width="30">
                                        <a href="javascript:void(0);" id="ctl00_LitTypeLabel" style="display: none; background-color: #004576; color: White;">Type</a>
                                        <div id="ctl00_FlyoutLitType_contentbox"><div id="ctl00_FlyoutLitTypeLitTypeLabel_pv" style="position: absolute; background-color: transparent; width: 119px; height: 332px; z-index: 1000; display: none;"><div id="ctl00_FlyoutLitTypeLitTypeLabel_e" style="background-color: transparent; width: 119px; height: 332px;"><div id="ctl00_FlyoutLitTypeLitTypeLabel_ct"> <div id="ctl00_FlyoutLitType_LitTypePanel" style="background-color:#EBEBEB;text-align:left;"> <table id="ctl00_FlyoutLitType_cblLitSearch" border="0"> <tbody><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_0" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$0" /><label for="ctl00_FlyoutLitType_cblLitSearch_0">Case Study</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_1" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$1" /><label for="ctl00_FlyoutLitType_cblLitSearch_1">Certificate Logo</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_2" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$2" /><label for="ctl00_FlyoutLitType_cblLitSearch_2">Datasheet</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_3" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$3" /><label for="ctl00_FlyoutLitType_cblLitSearch_3">eDM / eNewsletter</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_4" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$4" /><label for="ctl00_FlyoutLitType_cblLitSearch_4">News</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_5" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$5" /><label for="ctl00_FlyoutLitType_cblLitSearch_5">Photo</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_6" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$6" /><label for="ctl00_FlyoutLitType_cblLitSearch_6">Podcast</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_7" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$7" /><label for="ctl00_FlyoutLitType_cblLitSearch_7">Sales Kit</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_8" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$8" /><label for="ctl00_FlyoutLitType_cblLitSearch_8">Video</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_9" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$9" /><label for="ctl00_FlyoutLitType_cblLitSearch_9">White Papers</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_10" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$10" /><label for="ctl00_FlyoutLitType_cblLitSearch_10">Webcast</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_11" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$11" /><label for="ctl00_FlyoutLitType_cblLitSearch_11">eCatalog</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_12" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$12" /><label for="ctl00_FlyoutLitType_cblLitSearch_12">Poster</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_13" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$13" /><label for="ctl00_FlyoutLitType_cblLitSearch_13">presentation slide</label></td> </tr><tr> <td><input id="ctl00_FlyoutLitType_cblLitSearch_14" type="checkbox" name="ctl00$FlyoutLitType$cblLitSearch$14" /><label for="ctl00_FlyoutLitType_cblLitSearch_14">Image</label></td> </tr> </tbody></table> </div> </div></div></div></div>
                                    </td>
                                    <td width="15" valign="middle" align="left"> <input type="image" name="ctl00$btnSearch" id="ctl00_btnSearch" src="./MyAdvantech–Shopping Cart_files/go_btn.jpg" alt="Search" style="height:16px;width:34px;border-width:0px;" /> </td>
                                    <td height="5" valign="middle" align="left"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div> --%><table id="ctl00_table3" align="center" width="900px" border="0" cellpadding="0" cellspacing="0">
                        <tbody>
                            <tr> <td height="5"></td> </tr>
                            <tr>
                                <td align="left">
                                    <table width="100%"> <tbody><tr> <td> <span id="ctl00__main_page_path" style="width: 41%;"><a href="SRP_Configurator.aspx">Back</a></span></td> <td align="right"> <table> <tbody><tr> <td> <img id="ctl00__main_imgLK" src="./MyAdvantech–Shopping Cart_files/arrow2007_small-BU3.gif" style="border-width:0px;" /> </td> <td> <a id="ctl00__main_lbtnCartHistory" href="javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$_main$lbtnCartHistory&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, true))"> Cart History</a> </td> </tr> </tbody></table> </td> </tr> </tbody></table> <hr /> <table>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tbody>
                                                            <tr> <td class="menu_title"> <span id="ctl00__main_lbPageName">Shopping Cart</span> </td> </tr>
                                                            <tr>
                                                                <td style="border: 1px solid #d7d0d0; padding: 10px">
                                                                    <div id="ctl00__main_plAdd">
                                                                        <table cellspacing="5px">
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td class="h5">
                                                                                        Part No:
                                                                                    </td>
                                                                                    <td> <input name="ctl00$_main$txtPartNo" type="text" id="ctl00__main_txtPartNo" autocomplete="off" style="width:250px;" /> </td>
                                                                                    <td> <input type="image" name="ctl00$_main$ibtnAvilability" id="ctl00__main_ibtnAvilability" src="./MyAdvantech–Shopping Cart_files/availability.gif" style="border-width:0px;" /> </td>
                                                                                </tr>
                                                                                <tr id="ctl00__main_drpCPI">
                                                                                    <td class="h5">
                                                                                        Choose Parent Item :
                                                                                    </td>
                                                                                    <td> <select name="ctl00$_main$DDLbtosParentItem" id="ctl00__main_DDLbtosParentItem"> <option selected="selected" value="0">Loose items</option> </select> </td>
                                                                                    <td></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="h5">
                                                                                        Quantity:
                                                                                    </td>
                                                                                    <td> <input name="ctl00$_main$txtQty" type="text" value="1" id="ctl00__main_txtQty" style="width:50px;" /> </td>
                                                                                    <td></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td class="h5">
                                                                                        Extended Warranty:
                                                                                    </td>
                                                                                    <td> <select name="ctl00$_main$drpEW" id="ctl00__main_drpEW"> <option selected="selected" value="0">without extended warranty</option> <option value="19">AGS-EW-03</option> <option value="20">AGS-EW-06</option> <option value="21">AGS-EW-12</option> <option value="22">AGS-EW-24</option> <option value="23">AGS-EW-36</option> </select> </td>
                                                                                    <td></td>
                                                                                </tr>
                                                                                <tr> <td colspan="3" align="left"> <span id="ctl00__main_lbAddErrMsg" style="color:Tomato;"></span> </td> </tr>
                                                                                <tr> <td></td> <td></td> <td> <input type="image" name="ctl00$_main$ibtnAdd" id="ctl00__main_ibtnAdd" src="./MyAdvantech–Shopping Cart_files/add2cart_2.gif" style="border-width:0px;" /> <input type="image" name="ctl00$_main$ibtnSearch" id="ctl00__main_ibtnSearch" src="./MyAdvantech–Shopping Cart_files/search1.gif" style="border-width:0px;" /> </td> </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table> <hr /> <table width="100%">
                                        <tbody>
                                            <tr>
                                                <td class="menu_title">
                                                    My Shopping Cart
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="border: 1px solid #d7d0d0; padding: 2px">
                                                    <table width="100%">
                                                        <tbody>
                                                            <tr>
                                                                <td>
                                                                    <input type="image" name="ctl00$_main$imgXls" id="ctl00__main_imgXls" src="./MyAdvantech–Shopping Cart_files/excel.gif" alt="Download" style="border-width:0px;" /> <input type="submit" name="ctl00$_main$btnDel" value=" Del " id="ctl00__main_btnDel" /> <div id="ctl00__main_MPConfigConfirm_foregroundElement" style="display: none; position: fixed;">
                                                                        <div id="ctl00__main_PLconfigConfirm" class="modalPopup" style="display: none">
                                                                            <div style="text-align: right;"> <input type="image" name="ctl00$_main$cconfigConfirm" id="ctl00__main_cconfigConfirm" src="./MyAdvantech–Shopping Cart_files/del.gif" style="border-width:0px;" /> </div> <div>
                                                                                <div id="ctl00__main_UPconfigConfirm">

                                                                                    This will remove all items in shopping cart, continue?
                                                                                    <table width="100%"> <tbody><tr> <td align="center"> <input type="submit" name="ctl00$_main$btnConfigConfirm" value="Confirm" id="ctl00__main_btnConfigConfirm" /> </td> </tr> </tbody></table>
                                                                                </div>
                                                                            </div>
                                                                        </div>
                                                                    </div> <a id="ctl00__main_lbDummyConfigConfirm" href="javascript:WebForm_DoPostBackWithOptions(new WebForm_PostBackOptions(&quot;ctl00$_main$lbDummyConfigConfirm&quot;, &quot;&quot;, true, &quot;&quot;, &quot;&quot;, false, true))"></a> <input type="submit" name="ctl00$_main$btnUpdate" value=" Update " id="ctl00__main_btnUpdate" /> <div id="ctl00__main_MPConfigConfirm_backgroundElement" class="modalBackground" style="display: none; position: fixed; left: 0px; top: 0px;"></div>
                                                                </td>
                                                            </tr>
                                                        </tbody>
                                                    </table> <div style="width: 890px; overflow: scroll; overflow-y: hidden">
                                                        <input type="hidden" name="ctl00$_main$HF_IsBTOS" id="ctl00__main_HF_IsBTOS" value="0" /> <div id="divReconfigBtn" style="display: none"></div> <div>
                                                            <table cellspacing="0" rules="all" border="1" id="ctl00__main_gv1" style="border-color:#D7D0D0;border-width:1px;border-style:Solid;width:100%;border-collapse:collapse;">
                                                                <thead>
                                                                    <tr style="color:Black;background-color:Gainsboro;white-space:nowrap;">
                                                                        <th align="center" scope="col"> <input id="ctl00__main_gv1_ctl01_chkKey" type="checkbox" name="ctl00$_main$gv1$ctl01$chkKey" onclick="GetAllCheckBox(this);" /> </th>
                                                                        <th align="center" scope="col">
                                                                            Seq
                                                                        </th>
                                                                        <th scope="col">No.</th>
                                                                        <th scope="col">Model No</th>
                                                                        <th scope="col">Part No</th>
                                                                        <th scope="col">Description</th>
                                                                        <th scope="col">Extended Warranty</th>
                                                                        <th align="center" scope="col">
                                                                            List Price
                                                                        </th>
                                                                        <th align="center" scope="col">
                                                                            Unit Price
                                                                        </th>
                                                                        <th scope="col">Disc.</th>
                                                                        <th align="center" scope="col">
                                                                            Qty.
                                                                        </th>
                                                                        <th align="center" scope="col">
                                                                            Req. Date
                                                                        </th>
                                                                        <th align="center" scope="col">
                                                                            Due Date
                                                                        </th>
                                                                        <th scope="col">Sub Total</th>
                                                                        <th scope="col">Customer PN.</th>
                                                                        <th scope="col">ABC Indicator</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="cartlist">
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                        <table width="100%">
                                                            <tbody>
                                                                <tr>
                                                                    <td align="right">
                                                                        <table>
                                                                            <tbody>
                                                                                <tr>
                                                                                    <td> <b>Total:</b> </td>
                                                                                    <td>
                                                                                        NT<span id="lbtotal"></span>
                                                                                    </td>
                                                                                </tr>
                                                                            </tbody>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table> 
                                    <table>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <input type="image" src="./MyAdvantech–Shopping Cart_files/savemycart.gif" style="border-width:0px;" />
                                                </td>
                                                <td>
                                                    <input type="text" style="width:100px;" />
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                    <div>
                                        <table width="100%">
                                            <tbody>
                                                <tr>
                                                    <td>
                                                        <span id="ctl00__main_lbConfirmMsg" style="color:Red;"></span>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td align="center">
                                                        <input type="submit" name="ctl00$_main$btnOrder" value=" &gt;&gt; Check Out &lt;&lt; " id="ctl00__main_btnOrder" />
                                                    </td>
                                                </tr>
                                                <tr> <td align="center"> </td> </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </td>
                            </tr>
                            <tr> <td height="5"></td> </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </tbody>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

