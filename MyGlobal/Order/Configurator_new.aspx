<%@ Page Title="MyAdvantech - eConfigurator" Language="VB" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="false" CodeFile="Configurator_new.aspx.vb" Inherits="Order_Configurator_new" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="../EC/Includes/json2.js"></script>
    <script type="text/javascript" src="../Includes/LoadingOverlay/loadingoverlay.min.js"></script>
    <script type="text/javascript" src="../Includes/LoadingOverlay/loadingoverlay_progress.min.js"></script>
    <script type="text/javascript" src="Language/Configurator_new.js"></script>
    <script type="text/javascript" src="../Includes/js/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="../Includes/js/Math.uuid.js"></script>
    <link href="../Includes/jquery-ui.css" rel="stylesheet" />
    <link rel="stylesheet" href="../Includes/js/token-input-facebook.css" type="text/css" />
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
            width: 350px;
            display: inline-flex;
        }

            ul.token-input-list-facebook li:hover {
                background-color: #ffffff;
            }

        .w20 {
            width: 20px;
        }

        .w30 {
            width: 30px;
        }

        .w175 {
            width: 175px;
        }

        .text_center {
            text-align: center;
        }

        .text_left {
            text-align: left;
        }

        .text_right {
            text-align: right;
        }

        .vertical { /*文字垂直*/
            -webkit-writing-mode: vertical-lr;
            writing-mode: vertical-lr;
        }

        .bg_blue {
            background-color: #000080;
        }

        .font_white {
            color: white;
        }

        .font_red {
            color: red;
        }

        .font_bold {
            font-weight: bold;
        }

        .relative {
            position: relative;
        }

        .fixed_left600 {
            position: fixed;
            left: 600px;
        }

        .catHeader {
            width: 13px;
            height: 17px;
        }

        .show {
            display: block;
        }

        .hide {
            display: none;
        }

        .margin5_5 {
            margin: 5px 5px;
        }

        .margin_left10 {
            margin: 0 0 0 10px;
        }

        . {
            margin: 0 10px 0 0;
        }

            .border_ridge {
                border-style: ridge;
            }

            /*alert訊息專用*/
            .popup {
                background-color: #fff;
                border-radius: 10px 10px 10px 10px;
                box-shadow: 0 0 25px 5px #999;
                color: #111;
                min-width: 50px;
                padding: 25px;
                position: absolute;
                z-index: 9999;
                opacity: 1;
            }

                .popup div {
                    color: #2b91af;
                    font: bold 100% 'Petrona',sans;
                }

            .button.b-close {
                background-color: #2b91af;
                color: #fff;
                border-radius: 7px 7px 7px 7px;
                box-shadow: none;
                padding: 0 6px 2px;
                font: bold 131% sans-serif;
                right: -7px;
                top: -7px;
                margin: 0;
                position: absolute;
            }

                .button.b-close:hover { /*hover 是在控制當滑鼠移至某元件時，某元件該如何反應*/
                    box-shadow: 2px 2px 19px black;
                    -o-box-shadow: 2px 2px 19px black;
                    -webkit-box-shadow: 2px 2px 19px black;
                    -moz-box-shadow: 2px 2px 19px black;
                    opacity: 0.8;
                    filter: alpha(opacity=80);
                }

        /*top tab*/
        /*#top_scroll
        {
            left:0px;
	        top:-160px;	
            height:160px;
            width:100%;
	        position:fixed;
	        z-index:9999;
        }

        #top_content{
            height:100%;
            width:100%;
	        background:#000080;
	        text-align:center;
	        padding-left:20px;
            opacity:0.4;
        }

        #top_tab {
	        position:absolute;
	        left:320px;
	        bottom:-24px;
	        width:74px;
	        background:#000080;
	        color:#ffffff;
	        font-family:Arial, Helvetica, sans-serif;	
	        text-align:center;
	        padding:9px 0;

	        -moz-border-radius-bottomleft:10px;
	        -moz-border-radius-bottomright:10px;
	        -webkit-border-bottom-left-radius:10px;
	        -webkit-border-bottom-right-radius:10px;	
        }
        #top_tab span {
            color:white;
	        display:block;
	        height:12px;
	        padding:1px 0;
	        line-height:12px;
	        text-transform:uppercase;
	        font-size:12px;
        }*/


        /*Right tab*/
        #right_scroll {
            top: 0;
            right: -200px;
            width: 200px;
            position: fixed;
            z-index: 9999;
        }

        #right_content {
            background: #000080;
            padding-top: 120px;
            opacity: 0.4;
            height: 400px;
            overflow-x: hidden;
            overflow-y: auto;
        }

        #right_tab {
            position: absolute;
            top: 320px;
            left: -24px;
            width: 24px;
            background: #000080;
            color: #ffffff;
            font-family: Arial, Helvetica, sans-serif;
            text-align: center;
            padding: 9px 0;
            -moz-border-radius-topleft: 10px;
            -moz-border-radius-bottomleft: 10px;
            -webkit-border-top-left-radius: 10px;
            -webkit-border-bottom-left-radius: 10px;
        }

            #right_tab span {
                color: white;
                display: block;
                height: 12px;
                padding: 1px 0;
                line-height: 12px;
                text-transform: uppercase;
                font-size: 12px;
            }

        .otherpanel {
            min-height: 250px;
        }
    </style>
    <script type="text/javascript">
        var RequiredItem = new Array();
        var OtherComponent = [];

        $(function () {
            //多國語系
            $lang.gTxtLib.defaultSet($('#<%=hdLanguage.ClientID %>').val());

            $("input[type=button]").button();//Continue按鈕

            //自定義AlertDialog的關閉按鈕
            $("#b-close").click(function (e) {
                $('#AlertDialog').hide();
                e.preventDefault();
            });
            //讓超連結失效
            $('a[href="#"]').on('click', function (e) {
                e.preventDefault();
            });

            //黑屏--start
            $(document).ajaxStart(function () {
                $.LoadingOverlay("show");
            });
            $(document).ajaxStop(function () {
                $.LoadingOverlay("hide");
                SetRightTab();//設定右側CART
                $lang.gTxtLib.updateUIText();//多國語系
            });
            //黑屏--End

            //取得資料
            GetCBOM($('#tbConfigurator'), $('#<%=hdBTOId.ClientID %>').val(), 0);

            //Right Tab
            var w = $("#right_scroll").width();
            $("#right_tab").click(function () { //當滑鼠點擊時
                if ($("#right_scroll").css('right') == '-' + w + 'px') {
                    $("#right_scroll").animate({ right: '0px' }, 200, 'swing');
                } else {
                    $("#right_scroll").animate({ right: '-' + w + 'px' }, 200, 'swing');
                }
            });

            resizeRightTab();//Right Tab的位置

            ////Top Tab
            //var h = $("#top_scroll").height();
            //$("#top_tab").click(function () { //當滑鼠點擊時
            //    if ($("#top_scroll").css('top') == '-' + h + 'px') {
            //        $("#top_scroll").animate({ top: '0px' }, 400, 'swing');
            //    } else {
            //        $("#top_scroll").animate({ top: '-' + h + 'px' }, 400, 'swing');
            //    }
            //});

            //resizeTopTab();//Top Tab的位置

            $("#<%=txtPartNo.ClientID%>").tokenInput("<%System.IO.Path.GetFileName(Request.ApplicationPath)%>/Services/AutoComplete.asmx/GetTokenInputCBOMPartNo", {
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type PartNo", tokenLimit: 1, preventDuplicates: true, resizeInput: false, resultsLimit: 5,
                onAdd: function (data) {
                    $("#<%=txtPartNo.ClientID%>").val(data.name);
                    $("#<%=txtPartNo.ClientID%>").attr("data-desc", data.id);
                },
                onDelete: function (data) {
                    $("#<%=txtPartNo.ClientID%>").val("");
                    $("#<%=txtPartNo.ClientID%>").attr("data-desc", "");
                }
            });

            $("#btnAddOther").click(function () {
                var pn = $.trim($("#<%=txtPartNo.ClientID%>").val());
                var desc = $.trim($("#<%=txtPartNo.ClientID%>").attr("data-desc"));
                if (!pn || pn == "" || !desc || desc == "") {
                    AlertDialog("Please key in part no.");
                    return false;
                }
                for (var i = 0; i < OtherComponent.length; i++) {
                    if (OtherComponent[i].name == pn) {
                        AlertDialog("This part: " + pn + " already exists in other list");
                        return false;
                    }
                }
                OtherComponent.push({
                    name: pn,
                    desc: desc,
                    qty: 1,
                    category: 'Others'
                });
                var guid = Math.uuid(8, 10);
                var html = "<tr id='" + guid + "'><td>" + pn + "</td><td>" + desc + "</td>";
                var postData = {
                    ComponentName: pn,
                    ConfigQty: 1
                };
                $.ajax(
                        {
                            url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Configurator.asmx/GetPriceATP', type: "POST",
                            dataType: 'json', data: postData,
                            success: function (priceATP) {
                                if (priceATP.IsEw == false) {
                                    html += "<td>" + priceATP.CurrencySign + priceATP.Price + "</td>";
                                    html += "<td style=\"text-align:center;\"><input type=\"button\" value='Remove' data-pn=" + pn + " data-id=" + guid + " onclick='RemoveOtherCom(this)' / ></td><tr>";
                                    $("#othercoms").append(html);
                                    $("#oc").show();
                                }
                            },
                            error: function (msg) {
                                AlertDialog("Get price failed!");
                            }
                        }
                );
                $("#<%=txtPartNo.ClientID%>").tokenInput("clear");
            });
        });

        function RemoveOtherCom(node) {
            var pn = $(node).attr("data-pn");
            var guid = $(node).attr("data-id");
            if (OtherComponent.length === 0) {
                AlertDialog("Remove error");
                return false;
            }
            OtherComponent = OtherComponent.filter(function (item) {
                return item.name != pn;
            });
            if (OtherComponent.length == 0) {
                $("#othercoms").html("");
                $("#oc").hide();
            }
            else
                $("#" + guid).remove();
        }

        function GetCBOM(tableElement, CategoryID, type) {
            tableElement.empty(); //清空

            var tableId = tableElement.attr('id');
            if (tableId == "tbConfigurator") {
                if (!CategoryID || CategoryID == "") {
                    tableElement.addClass("hide");
                } else {
                    tableElement.removeClass("hide");
                }
            }


            var node = { RootID: CategoryID, SalesOrg: '<%= HttpContext.Current.Session("ORG_ID").ToString %>', CBOMOrg: '<%=Me.CBOM_Org%>', Type: type };
            $.getJSON("/Services/CBOMV2_Configurator.asmx/GetConfigRecord", node, function (data) {
                if (data && data.length > 0) {
                    var str = treeBOM(data[0]);
                    if (str != "") {
                        tableElement.append(str);
                        tableElement.removeClass("hide");
                    } else {
                        //先清空再加入隱藏(hide)，以防止一直重覆加入隱藏(hide)
                        tableElement.removeClass("hide").addClass("hide");
                    }
                }
                else {
                    //console.log('err GetCBOM： CategoryID：' + CategoryID + '; Type：'+type);
                    //AlertDialog('err GetCBOM： CategoryID：' + CategoryID + '; Type：' + type);
                }
            });

            //var node = { RootID: CategoryID, Org_ID: 'CN' };
            //$.getJSON("/Services/CBOMV2_Editor.asmx/InitializeTree", node, function (data) {
            //    
            //    if (data && data.length > 0) {
            //       
            //        var str = treeBOM(data[0]);
            //        tableElement.append(str);
            //    }
            //    else {
            //        console.log('err GetCBOM ' + msg.d);
            //    }
            //});
        }

        function treeBOM(BOM) {
            var str = "";
            if (BOM.children != 0) {
                var catBOM = BOM.children;
                for (var i = 0; i <= catBOM.length - 1; i++) {
                    if (catBOM[i].children != 0 || catBOM[i].isrequired == 1) {
                        //Category的部份
                        str += "<div id='" + catBOM[i].id + "' class='bg_blue font_white margin5_5'>";
                        str += "<input class='catHeader' type='button' id='inp_" + catBOM[i].id + "' onclick=collapseExpand('inp_" + catBOM[i].id + "','com_" + catBOM[i].id + "'); value='" + ((catBOM[i].isexpand == 1) ? "-" : "+") + "' />";
                        str += catBOM[i].text;
                        if (catBOM[i].isrequired == 1) {
                            str += "<font color='red'>(Required)</font>";
                        }
                        str += "</div>";
                        //Component框架
                        str += "<div id='com_" + catBOM[i].id + "' class='trSelection margin_left10 " + ((catBOM[i].isexpand == 1) ? "" : "hide") + "'>";
                        //Component內容 - radio button
                        str += "<input type='radio' name='rdn_" + catBOM[i].id + "' onclick='fillChildBOM(\"\",0,\"" + catBOM[i].id + "\");' value='" + catBOM[i].id + "--" + catBOM[i].text + "--" + ((catBOM[i].isrequired == 1) ? "Required" : "") + "' " + ((catBOM[i].isdefault == 1) ? "" : "checked") + "/>Select..</br>";
                        var comBOM = catBOM[i].children;
                        for (var j = 0; j <= comBOM.length - 1; j++) {
                            str += "<input type='radio' id='" + comBOM[j].id + "' name='rdn_" + catBOM[i].id + "' value='" + comBOM[j].id + "--" + comBOM[j].text + "--" + comBOM[j].desc + "--" + catBOM[i].text + "' onclick=fillChildBOM('" + comBOM[j].id + "'," + comBOM[j].type + ",'" + catBOM[i].id + "'); " + " islooseitem='" + ((comBOM[j].configurationrule == 1) ? "true" : "false") + "' " + ((comBOM[j].isdefault == 1) ? "checked" : "") + "/>" + comBOM[j].text + " -- " + comBOM[j].desc;
                            str += "</br><div class='margin_left10 " + ((comBOM[j].isdefault == 1) ? "" : "hide") + "' id='qtybox_" + comBOM[j].id + "'>"
                            str += "<input type='button' class='w20' id='jian_" + comBOM[j].id + "' value='-' onclick='qty_sun(\"" + comBOM[j].id + "\",\"jian\"," + catBOM[i].qty + ")'/>";
                            str += "<input type='text' class='w30 text_center' id='qty_" + comBOM[j].id + "' min='1' max='" + catBOM[i].qty + "' value='1' disabled='disabled'/>";
                            str += "<input type='button' class='w20' id='add_" + comBOM[j].id + "' value='+' onclick='qty_sun(\"" + comBOM[j].id + "\",\"add\"," + catBOM[i].qty + ")'/>";
                            str += "<span id='atp_" + comBOM[j].id + "'></span>";
                            str += "</div>";
                            if (comBOM[j].isdefault == 1) { //有default就先往下先行查詢
                                setTimeout("fillChildBOM('" + comBOM[j].id + "'," + comBOM[j].type + ", '" + catBOM[i].id + "');", 10);
                            }
                        }
                        str += "<div id='child_" + catBOM[i].id + "' class='border_ridge margin_left10 hide'>";
                        str += "</div>";

                        str += "</div>";
                    }
                }
            }
            return str;
        }

        //料號選取按鈕事件
        function fillChildBOM(comID, type, catID) {
            var childID = "child_" + catID;
            if (comID != "") {
                //相容性檢查
                var list = [];
                $('input:radio:checked').each(function () {
                    var pn = $(this).val().split("--")[1];
                    if (!!pn) {
                        list.push(pn);
                    }
                });
                var curPN = $('#' + comID).val().split("--")[1];
                if (!!curPN) {
                    list = $.grep(list, function (n, i) {
                        return n !== curPN;
                    });
                    var postData = {
                        PartNo: curPN,
                        SelectedItem: list.toString()
                    };
                    $.ajax(
                    {
                        url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Configurator.asmx/CheckCompatibility', type: "POST",
                        dataType: 'json', data: postData, async: true,
                        success: function (retData) {
                            if (retData.Result == true) {
                                AlertDialog(retData.Message);
                                var name = $('#' + comID).attr("name");
                                $("input:radio[name=" + name + "]:first").prop('checked', true);
                                fillChildBOM("", "0", catID);
                            }
                            else {
                                //qty的部份
                                $('#com_' + catID + ' > div').removeClass("hide").addClass("hide");//先隱藏
                                $('#qtybox_' + comID).removeClass("hide");//把qty加減的部份顯示出來
                                GetCompPriceATP(comID);//取得價格
                                //取得子項目
                                GetCBOM($('#' + childID), comID, type);
                            }
                        },
                        error: function (msg) {
                            AlertDialog("Get price failed!");
                        }
                    }
                );
                    }
                } else {
                //先清空再加入隱藏(hide)，以防止一直重覆加入隱藏(hide)
                    $('#' + childID).empty().removeClass("hide").addClass("hide");
                //qty的部份 - 如果選擇select的話就全部隱藏
                    $('#com_' + catID + ' > div').removeClass("hide").addClass("hide");

                    SetRightTab();
                }
            }

            function GetCompPriceATP(comID) {
                var str = "";
                var comATP = $('#atp_' + comID);

                if (comATP.has('b').length != 0) { return; }

                var postData = {
                    ComponentName: $('#' + comID).val().split("--")[1],
                    ConfigQty: $('#hdBTOQty').val()
                };
                $.ajax(
                        {
                            url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Configurator.asmx/GetPriceATP', type: "POST",
                        dataType: 'json', data: postData,
                        success: function (priceATP) {
                            if (priceATP.IsEw == false) {
                                str += "&nbsp; <b class='leng' data-tid='price'>Price:</b>" + priceATP.CurrencySign + "<span class='price'>" + priceATP.Price + "</span>";
                                str += "&nbsp; <b class='leng' data-tid='available'>Available on:</b>" + priceATP.ATPDate + "&nbsp;<b class='leng' data-tid='qty'>Qty:</b>&nbsp;" + ((priceATP.ATPQty > 0) ? (((priceATP.ATPQty > 1) ? (priceATP.ATPQty + 'pcs') : ('1pc'))) : ('N/A'));
                                //$('#<%=hdCurrencySign.ClientID %>').val(priceATP.CurrencySign);
                            }
                            comATP.append(str);

                        },
                        error: function (msg) {
                            AlertDialog("Get price failed!");
                        }
                    }
                );
                }

                //設定右側
                function SetRightTab() {
                    $('#right_CurrencySign').text($('#<%=hdCurrencySign.ClientID %>').val());//幣別符號
                    sum_price();//合計金額
                    AddCartItem();
                }

                function sum_price() {
                    var _sum = 0;
                    var arrRadio = $('input:radio[type=radio]:checked');
                    for (var i = 0; i <= arrRadio.length - 1; i++) {
                        if (!(arrRadio[i].value.split("--")[2] == "Required" || arrRadio[i].value.split("--")[2] == "")) {
                            var priceATP = $('#atp_' + arrRadio[i].value.split("--")[0]);
                            if (priceATP.has('span').length != 0) {
                                var price = $('#atp_' + arrRadio[i].value.split("--")[0] + ' > .price');
                                var qty = $('#qty_' + arrRadio[i].value.split("--")[0]).val();
                                if (price[0].innerText != "undefined") {
                                    _sum += parseFloat(price[0].innerText) * parseInt(qty);
                                }
                            }
                        }
                    }
                    $('#right_totalprice').text(formatFloat(_sum, 2));//右側購物車總價
                }

                //Add Right Cart Item -一次加入全部有選取的料號到右側購物車
                function AddCartItem() {
                    $('#right_cart').empty();
                    var str = "";
                    var arrRadio = $('input:radio[type=radio]:checked');
                    var requestqty = $('#hdBTOQty').val();
                    for (var i = 0; i <= arrRadio.length - 1; i++) {
                        if (!(arrRadio[i].value.split("--")[2] == "Required" || arrRadio[i].value.split("--")[2] == "")) {
                            str += "<div id='r_" + arrRadio[i].value.split("--")[0] + "'>";
                            str += "<div class='text_left w175'>" + arrRadio[i].value.split("--")[1] + "</div>";
                            str += "<div class='text_right w175 margin_right10'><b class='leng' data-tid='qty'>QTY:</b><span id='r_qty_" + arrRadio[i].value.split("--")[0] + "'>" + $('#qty_' + arrRadio[i].value.split("--")[0]).val() * requestqty + "</span></div>";
                            str += "</div>";
                        }
                    }
                    $('#right_cart').append(str);
                }

                function checkAndContinue() {
                    var check = true;
                    var focus = "";
                    var arrRadio = $('input:radio[type=radio]:checked');
                    var requestqty = $('#hdBTOQty').val();
                    var str = "<h3 class='font_bold leng' data-tid='Continue_checkTitle'>Please select a component in category:</h3><br/>";
                    for (var i = 0; i <= arrRadio.length - 1; i++) {
                        if (arrRadio[i].value.split("--")[2] == "Required") {
                            str += "<span class='font_red'>" + arrRadio[i].value.split("--")[1] + "</span></br>";
                            check = false;
                            if (focus == "") {//跳到未選取的項目
                                focus = arrRadio[i].value.split("--")[0];
                            }
                        }
                    }

                    if (check) {

                        if ($('#<%=hdBTOName.ClientID %>').val() == "") {
                            AlertDialog("The BTO Name can not be empty!");
                            return false;
                        }

                        var oRadio = new Array();
                        //Root需加入到第一位
                        oRadio.push({
                            name: $('#<%=hdBTOName.ClientID %>').val(),
                            desc: '',
                            qty: $('#hdBTOQty').val(),
                            category: 'Root',
                            isLooseItem: "false"
                        });

                        //選取的項目
                        for (var j = 0; j <= arrRadio.length - 1; j++) {
                            if (arrRadio[j].value.split("--")[2] != "Required" && arrRadio[j].value.split("--")[2] != "") {
                                oRadio.push({
                                    name: arrRadio[j].value.split("--")[1],
                                    desc: arrRadio[j].value.split("--")[2],
                                    qty: $('#qty_' + arrRadio[j].value.split("--")[0]).val() * requestqty,
                                    category: arrRadio[j].value.split("--")[3],
                                    isLooseItem: arrRadio[j].getAttribute("islooseitem")
                                });
                            }
                        }
                        var hasOtherComp = false;
                        if (OtherComponent.length > 0) {
                            hasOtherComp = true;
                            for (var o = 0; o < OtherComponent.length; o++) {
                                oRadio.push({
                                    name: OtherComponent[o].name,
                                    desc: OtherComponent[o].desc,
                                    qty: OtherComponent[o].qty,
                                    category: OtherComponent[o].category
                                });
                            }
                        }
                        var postData = { SelectedItems: JSON.stringify(oRadio), SelectedOther: hasOtherComp };
                        $.post("/Services/CBOMV2_Configurator.asmx/Add2Cart", postData, function (data) {
                            var str = data.IsUpdated;
                            if (str) {
                                window.location.href = "Cart_ListV2.aspx";
                            } else {
                                AlertDialog(data.ServerMessage);
                            }
                        }, "json");

                    } else {
                        $("#colExpAll").val("Expand All"); collapseExpandAll();
                        $('input:radio[name=rdn_' + focus + ']:first').focus();
                        AlertDialog(str, 10000);
                    }

                }

                //qty的加減
                function qty_sun(id, name, max) {
                    var requestqty = $('#hdBTOQty').val();

                    var n = $('#qty_' + id).val();
                    if (n == '') { n = '1' }
                    var num = 1;
                    if (name == "add") {
                        num = parseInt(n) + 1;
                        if (num > parseInt(max)) { num = parseInt(max) }//不可大於max
                    } else if (name == "jian") {
                        num = parseInt(n) - 1;
                    }
                    if (num <= 0) { num = 1 }
                    $('#qty_' + id).val(num);
                    $('#r_qty_' + id).text(num * requestqty);
                    sum_price();
                }

                //節點控制
                function collapseExpand(anchorId, trSelId) {
                    var anchorNode = $("#" + anchorId); var trSelNode = $("#" + trSelId);
                    if (anchorNode.val().indexOf("-") >= 0) {
                        trSelNode.addClass("hide"); anchorNode.val("+");
                    }
                    else {
                        trSelNode.removeClass("hide"); anchorNode.val("-"); //trSelNode.css("width", "100%");
                    }
                }

                //節點全開、全關控制
                function collapseExpandAll() {

                    if ($("#colExpAll").val().indexOf($('#hdCollapse').val()) >= 0) {
                        $(".trSelection").removeClass("hide").addClass("hide");
                        $(".catHeader").val("+");
                        $("#colExpAll").val($('#hdExpand').val());
                    }
                    else {
                        $(".trSelection").removeClass("hide");
                        $(".catHeader").val("-");
                        $("#colExpAll").val($('#hdCollapse').val());
                    }
                }

                //alert訊息
                function AlertDialog(str, second) {
                    $("#AlertDialog div").html('');
                    $("#AlertDialog div").html(str);

                    //$('#AlertDialog').css({//位置
                    //    top: $(window).height() / 3 - 50,
                    //    left: $(window).width() / 3 - 50
                    //});

                    //位置置中
                    center($('#AlertDialog'));

                    //設定自動關閉
                    second = second || 5000;//如果為空就帶預設值5秒
                    $('#AlertDialog').fadeIn("slow");//淡入顯示
                    setTimeout("$('#AlertDialog').fadeOut('slow')", second);
                    $lang.gTxtLib.updateUIText();//多國語系
                }

                // 居中
                function center(obj) {

                    var screenWidth = $(window).width(), screenHeight = $(window).height();  //当前浏览器窗口的 宽高
                    var scrolltop = $(document).scrollTop();//获取当前窗口距离页面顶部高度

                    var objLeft = (screenWidth - obj.width()) / 2;
                    var objTop = (screenHeight - obj.height()) / 2 + scrolltop;

                    obj.css({ left: objLeft + 'px', top: objTop + 'px' });
                    //浏览器窗口大小改变时
                    $(window).resize(function () {
                        screenWidth = $(window).width();
                        screenHeight = $(window).height();
                        scrolltop = $(document).scrollTop();

                        objLeft = (screenWidth - obj.width()) / 2;
                        objTop = (screenHeight - obj.height()) / 2 + scrolltop;

                        obj.css({ left: objLeft + 'px', top: objTop + 'px' });

                    });
                    //浏览器有滚动条时的操作、
                    $(window).scroll(function () {
                        screenWidth = $(window).width();
                        screenHeight = $(window).height();
                        scrolltop = $(document).scrollTop();

                        objLeft = (screenWidth - obj.width()) / 2;
                        objTop = (screenHeight - obj.height()) / 2 + scrolltop;

                        obj.css({ left: objLeft + 'px', top: objTop + 'px' });
                    });

                }

                //當桌面大小改變時
                $(window).resize(function () {
                    resizeRightTab();//Right Tab的位置
                    //resizeTopTab();//Top Tab的位置
                }).trigger('resize');

                //Right Tab的位置
                function resizeRightTab() {
                    $('#right_tab').css({
                        top: $(window).height() / 2 - 50
                    });
                    $('#right_content').css('height', ($(window).height() - 20) + 'px'); //將區塊自動撐滿畫面高度
                }

                ////Top Tab的位置
                //function resizeTopTab() {
                //    $('#top_tab').css({
                //        left: ($(window).width() / 2) - 80
                //    });
                //}

                //小數點第N位四捨五入
                function formatFloat(num, pos) {
                    var size = Math.pow(10, pos);
                    return Math.round(num * size) / size;
                }

    </script>
    <div>
        <%--        <span style="width: 41%;" id="page_path" runat="server" />--%>
        <div id="btn_up">
            <input id="colExpAll" class="leng_val" data-tid="Expand" type="button" onclick="collapseExpandAll();" value="Expand All" />
            <input class="fixed_left600 leng_val" data-tid="Continue" type="button" onclick="checkAndContinue();" value="Click to Continue" />
            <asp:DropDownList runat="server" ID="dlACNStorageLocation" Visible="false" OnSelectedIndexChanged="dlACNStorageLocation_SelectedIndexChanged" AutoPostBack="true">
                <asp:ListItem Text="1000庫" Value="1000"></asp:ListItem>
                <asp:ListItem Text="2000庫" Value="2000"></asp:ListItem>
            </asp:DropDownList>
        </div>
        <div id="tbConfigurator" class="border_ridge" style="padding: 15px">
        </div>
        <asp:Panel ID="pnOthers" runat="server" CssClass="otherpanel" Visible="false">
            <table style="width: 100%;">
                <thead>
                    <tr>
                        <th class="leng" data-tid="Others">Others
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <div>
                                <table>
                                    <tbody>
                                        <tr>
                                            <td class="leng" data-tid="PartNo">Part No:
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtPartNo" runat="server"></asp:TextBox>
                                            </td>
                                            <td>
                                                <input class="leng_val" type="button" id="btnAddOther" value="Add other" data-tid="AddOther" />
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
            <table id="oc" style="width: 100%; display: none;">
                <thead>
                    <tr>
                        <th class="leng" data-tid="PartNo">Part No.
                        </th>
                        <th class="leng" data-tid="Desc">Description
                        </th>
                        <th class="leng" data-tid="price">List Price
                        </th>
                        <th class="leng" data-tid="Remove">Remove
                        </th>
                    </tr>
                </thead>
                <tbody id="othercoms">
                </tbody>
            </table>
        </asp:Panel>
        <div id="btn_down">
            <input class="fixed_left600 leng_val" data-tid="Continue" type="button" onclick="checkAndContinue();" value="Click to Continue" />
        </div>
        <input type="hidden" id="hdBTOId" runat="server" />
        <input type="hidden" id="hdBTOName" runat="server" />
        <input type="hidden" value="1" id="hdBTOQty" />
        <input type="hidden" id="hdCurrencySign" runat="server" />
        <input type="hidden" class="leng_val" data-tid="Collapse" id="hdCollapse" />
        <input type="hidden" class="leng_val" data-tid="Expand" id="hdExpand" />
        <input type="hidden" id="hdLanguage" runat="server" />
    </div>
    <div id="AlertDialog" class="popup" style="display: none">
        <a href="#" id="b-close"><span class="button b-close"><span>X</span></span></a>
        <div></div>
    </div>

    <%-- <div id="top_scroll">
        <div id="top_tab">
            <a href="#">
                <span>CART</span>
            </a>
        </div>
        <div id="top_content">  
        </div>
    </div>--%>


    <div id="right_scroll">
        <div id="right_tab" class="vertical">
            <a href="#">
                <h2 class="leng" data-tid="cart" style="margin-left: 5px;">CART</h2>
                <%-- <span>C</span>
                <span>A</span>
                <span>R</span>
                <span>T</span>--%>
            </a>
        </div>
        <div id="right_content">
            <div class="text_left margin5_5 font_white">
                <b class='leng' data-tid='TotalPrice'>Total Price:</b>&nbsp;<span id="right_CurrencySign"></span>&nbsp;<span id="right_totalprice"></span>
            </div>
            <div id="btn_right" class="margin5_5">
                <input class="button leng_val" data-tid="Continue" type="button" onclick="checkAndContinue();" value="Click to Continue" />
            </div>
            <div id="right_cart" class="text_left margin5_5 font_white" style="width: 195px; height: 415px; overflow-x: hidden; overflow-y: auto;">
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

