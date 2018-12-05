<%@ Page Title="MyAdvantech – Machine Monitoring & Optimization SRP Configurator" Language="VB" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="false" CodeFile="SRP_Configurator.aspx.vb" Inherits="Lab_SBR_Configurator" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript" src="../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="../EC/Includes/json2.js"></script>
    <style type="text/css">
        /*.table{border-collapse:collapse;border-spacing:0}
        .table.body,.table.th,.table.td{margin:0;padding:0}*/
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
        .continueBtn {
            width: 120px;
        }
        .button.b-close:hover { /*hover 是在控制當滑鼠移至某元件時，某元件該如何反應*/
            box-shadow: 2px 2px 19px black;
            -o-box-shadow: 2px 2px 19px black;
            -webkit-box-shadow: 2px 2px 19px black;
            -moz-box-shadow: 2px 2px 19px black;
            opacity: 0.8;
            filter: alpha(opacity=80);
        }
        .div_title{
            font-size:large;
            font-weight: bold;
        }
        .div_right_bottom {
                           color:white;
                           float:right;
        }
        .bold{
            font-weight:bold;
        }
        .top{
            vertical-align:top;
            width:80px;
        }
        ._top{
             vertical-align:top;
        }
        .Optional{
            font-weight:bold;
        }
        .Default{
            width:25px;
            text-align:center;
        }
        .checkbox{
            background-color: #D4D4D4;
            vertical-align:middle;
            text-align:center;
        }
        .white{
             color:white;
        }
</style>
    <script type="text/javascript">

        $(document).on("change", ".pacss", function () {
            $(".pacss").each(function () {
                $(this).prop("checked", false);
            });
            $("#optionaltitle-500").text($(this).parent().find("p").text());
            $(this).prop("checked", true);
        });

        $(document).ready(function () {
            var node = { RootID: '<%=Request("ID")%>' };
            $.ajax(
                {
                    type: "GET", url: "/Services/CBOMV2_Configurator.asmx/GetSRPConfigRecord",
                    data: node,
                    dataType: "json",
                    async: false,
                    success: function (retData) {
                        if (retData) {

                            $("#spPartNo").text(retData.RealPartNo);
                            $("#spDefaultPack").text(retData.RealPartNo + " Package Offering");
                            //console.log(retData.RealPartNo);
                            //console.log(retData.DefaultPackage.text);
                            var dp = retData.DefaultPackage;
                            for (var i = 0; i < dp.children.length; i++) {
                                //console.log(dp.children[i].text);
                            }

                            //console.log(retData.OptionPackage.text);
                            var op = retData.OptionPackage;
                            for (var i = 0; i < op.children.length; i++) {
                                //console.log(op.children[i].text);
                            }
                        }
                    },
                    error: function () {
                        console.log("ERROR");
                    }
                });
            //$('.Default').on("change", function () {
                //default_sun();
            //});          

            //$("#add1").click(function () {
            //    var n = $("#Default1").val();
            //    var num = parseInt(n) + 1;
            //    $("#Default1").val(num);
            //    default_sun();
            //});

            //$("#jian1").click(function () {
                
            //    var n = $("#Default1").val();
            //    var num = parseInt(n) - 1;
            //    if (num == 0) { return;}
            //    $("#Default1").val(num);
            //    default_sun();
            //});


            //$("#add2").click(function () {
            //    var n = $("#Default2").val();
            //    var num = parseInt(n) + 1;
            //    $("#Default2").val(num);
            //    default_sun();
            //});

            //$("#jian2").click(function () {
            //    var n = $("#Default2").val();
            //    var num = parseInt(n) - 1;
            //    if (num == 0) { return; }
            //    $("#Default2").val(num);
            //    default_sun();
            //});


            //$("#add3").click(function () {
            //    var n = $("#Default3").val();
            //    var num = parseInt(n) + 1;
            //    $("#Default3").val(num);
            //    default_sun();
            //});

            //$("#jian3").click(function () {
            //    var n = $("#Default3").val();
            //    var num = parseInt(n) - 1;
            //    if (num == 0) { return; }
            //    $("#Default3").val(num);
            //    default_sun();
            //});


            //$("#add4").click(function () {
            //    var n = $("#Default4").val();
            //    var num = parseInt(n) + 1;
            //    $("#Default4").val(num);
            //    default_sun();
            //});

            //$("#jian4").click(function () {
            //    var n = $("#Default4").val();
            //    var num = parseInt(n) - 1;
            //    if (num == 0) { return; }
            //    $("#Default4").val(num);
            //    default_sun();
            //});

            //sum();

            //$("#txt1").change(function () {
            //    var qty = parseInt($(this).val()) || 1;
            //    if (qty > 10) qty = 10;
            //    $('#Default1').val(qty.toString());
            //    $('#Default2').val(qty.toString());
            //    $('#Default3').val(qty.toString());
            //    $('#Default4').val(qty.toString());
            //    var tp = qty * 1500;
            //    var dp = tp * 0.8;
            //    $(this).val(qty.toString());
            //    $("#default_price").text("$" + tp.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
            //    $("#default_sun").text(dp.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
            //    sum();
            //});
        });

        function sum() {
            
            var _sum = 0;
            var optional = $('.Optional');
            if (optional != "undefined") {
                for (var i = 0; i < optional.length; i++) {
                    if (optional[i].innerText != '') {
                        _sum += parseInt(RemoveComma(optional[i].innerText));
                    }
                }
            }
            $('#Optional_sum').text(AppendComma(_sum));
            var total = parseInt(RemoveComma($('#default_sun').text())) + parseInt(RemoveComma($('#Optional_sum').text()));
            $('#total_price').text(AppendComma(total));
            var total_discount = total - (total * (parseInt($('#discount').text())/100));
            $('#total_discounted_price').text(AppendComma(total_discount));
        }

        function default_sun() {
            var default_sun = 0;
            if ($("#Default1").val() != '') {
                default_sun += parseInt($("#Default1").val());
            }
            if ($("#Default2").val() != '') {
                default_sun += parseInt($("#Default2").val());
            }
            if ($("#Default3").val() != '') {
                default_sun += parseInt($("#Default3").val());
            }
            if ($("#Default4").val() != '') {
                default_sun += parseInt($("#Default4").val());
            }
            default_sun = default_sun * 300;
            $('#default_sun').text(AppendComma(default_sun));

            sum();
        }

        function Optional_sun(id,name) {
            
            var n = $('#Optional-' + id).val();
            if (n == '') { n= '0' }
            var num = 0;
            if (name == "add") {
                num = parseInt(n) + 1;
            } else if(name =="jian") {
                num = parseInt(n) - 1;
            } else if (name == "opt") {
                num = n;
            } else {
                num = parseInt(name);
            }
            if (num < 0) { num = 0 }

            $('#Optional-' + id).val(num);
            $('#qty-' + id).val(num);

            var Optional_sun = 0;
            if ($('#Optional-' + id).val() != '') {
                Optional_sun += parseInt($('#Optional-' + id).val());
            }
            Optional_sun = Optional_sun * 100;
            $('#money-' + id).text(AppendComma(Optional_sun));
           
            if (id == "4_1") {
                $("#Optional-500").val(num);
                $("#money-500").text(num * 100);
            }

            sum();
        }

        function Optional_num(id) {
            var newID = id.split("-")[1];
            var num = 0;
            if ($('#qty-' + newID).val() != '') {
                num = parseInt($('#qty-' + newID).val());
            }
            $('#Optional-' + newID).val(num);
            Optional_sun(newID, num);
        }

        function checkbox_Optional(id, name) {
            if ($("#" + id).prop("checked")) {//如果打勾的話就加入到Optional

                var str ="<tr id='tr_"+ id +"'>";
                str +="<td style='width:300px;'>";
                str += "<input type='button' style='width:20px' id='clear-" + id + "' value='-' onclick='remove_Optional(\"" + id + "\")'/>&nbsp;";
                str += "<span id='optionaltitle-" + id + "' class='bold'>" + $('#item_title_' + id.split('_')[0]).text() + "</span> ";
                str += "<p id='optionalitem-" + id + "' style='margin-left: 30px;'>" + $('#item_' + id).text() + "</p>";
                str +="</td>"; 
                str +="<td class='top'>";
                str += "<input type='button' style='width:20px' id='jian-" + id + "' value='-' onclick='Optional_sun(\"" + id + "\",\"jian\")'/>";
                var qty = $("#qty-" + id).val();
                if (qty == '') { qty = '1' }
                str += "<input style='width:30px;text-align:center;' type='text' id='Optional-" + id + "' min='0' value='" + qty + "' onkeypress='return onKeyPressBlockNumbers(event;' onpaste='return false;' onchange='Optional_sun(\"" + id + "\",\"opt\")'/> ";
                str += "<input type='button' style='width:20px' id='add-" + id + "' value='+' onclick='Optional_sun(\"" + id + "\",\"add\")'/>";
                str +="</td>";
                str +="<td class='_top'>";
                str += "<span class='bold'>$ </span>";
                var money = parseInt(qty) * 100;
                str += "<span class='Optional' id='money-" + id + "'>" + AppendComma(money) + "</span> ";
                str +="</td>";
                str +="</tr>";
                $('#tb_Optional tbody').append(str);
                $('#qty-' + id).val(qty);

                if (name == "4_1") {
                    var txt = "";
                    txt += "<table><tr><td><p style='display:inline;'>1702002600 	Power Cable US Plug 1.8 M</p>&nbsp;<input type='checkbox' checked='checked' class='pacss' /></td></tr></table>";
                    txt += "<table><tr><td><p style='display:inline;'>1702002605 	Power Cable EU Plug 1.8 M</p>&nbsp;<input type='checkbox' class='pacss' /></td></tr></table>";
                    txt += "<table><tr><td><p style='display:inline;'>1702031801 	Power Cable UK Plug 1.8 M</p>&nbsp;<input type='checkbox' class='pacss' /></td></tr></table>";
                    txt += "<table><tr><td><p style='display:inline;'>1700000596 	Power Cable China/Australia Plug 1.8 M</p>&nbsp;<input type='checkbox' class='pacss' /></td></tr></table>";

                    var item = "<tr id='tr_" + 500 + "'>";
                    item += "<td style='width:300px;'>";
                    item += "<input type='button' style='width:20px' id='clear-" + 500 + "' value='-' onclick='remove_Optional(\"" + 500 + "\")'/>&nbsp;";
                    item += "<span id='optionaltitle-" + 500 + "' class='bold'>1702002600 	Power Cable US Plug 1.8 M</span> ";
                    item += "<p id='optionalitem-" + 500 + "' style='margin-left: 30px;'>" + $('#item_' + 500).text() + "</p>";
                    item += "</td>";
                    item += "<td class='top' style='text-align:center;'>";
                    item += "<input style='width:30px;text-align:center;' type='text' id='Optional-" + 500 + "' min='0' value='" + 1 + "' onkeypress='return onKeyPressBlockNumbers(event;' onpaste='return false;' onchange='Optional_sun(\"" + id + "\",\"opt\")'/> ";
                    item += "</td>";
                    item += "<td class='_top'>";
                    item += "<span class='bold'>$ </span>";

                    item += "<span class='Optional' id='money-" + 500 + "'>" + AppendComma(100) + "</span> ";
                    item += "</td>";
                    item += "</tr>";
                    $('#tb_Optional tbody').append(item);

                    $("#pa").html(txt);
                    $("#pa").show();
                }

                sum();
            } else {
                remove_Optional(id);
                $("#tr_500").remove();
                $("#pa").html();
                $("#pa").hide();
            }
        }

        function remove_Optional(id) {
            $('#tr_' + id).remove();
            $('#qty-' + id).val('');
            $('#' + id).prop("checked", false);
            sum();
        }

        function Continue() {
            var storage = window['localStorage'];
            jsonobj = [];
            var mp = {};
            var qty = parseInt($('#txt1').val()) || 0;
            mp["partNo"] = "SRP-FEC220-U2271AE";
            mp["URL"] = "http://my.advantech.com/Product/ProductSearch.aspx?key=SRP-FEC220-U2271AE";
            mp["desc"] = "COMPUTER SYSTEM, UNO-2271G-E23AE, HMI, 32G eMMC, WES7P, ADAM-6060";
            mp["price"] = 1200 * qty;
            mp["qty"] = qty;
            var dt = new Date();
            mp["reqDate"] = dt.getFullYear() + "/" + (dt.getMonth() + 1) + "/" + dt.getDate();
            jsonobj.push(mp);
            //for (var j = 1; j <= 4; j++) {
            //    var item = {};
            //    item["partNo"] = $('#defaulttitle' + j).text();
            //    item["URL"] = "http://my.advantech.com/Product/ProductSearch.aspx?key=SRP-FEC220";
            //    item["desc"] = $('#defaultitem' + j).text();
            //    item["price"] = parseInt($('#Default' + j).val()) * 300
            //    item["qty"] = $('#Default' + j).val();
            //    var Today = new Date();
            //    item["reqDate"] = Today.getFullYear() + "/" + (Today.getMonth() + 1) + "/" + Today.getDate();
            //    jsonobj.push(item);
            //}

            var Optitem = $('#tb_Optional tbody').find('tr');
            if (Optitem.length > 0) {
                for (var i = 0; i < Optitem.length; i++) {
                    var id = Optitem[i].id.replace('tr_', '').trim();
                    var item = {};
                    item["partNo"] = $('#optionaltitle-' + id).text();
                    item["URL"] = "http://my.advantech.com/Product/ProductSearch.aspx?key=SRP-FEC220";
                    item["desc"] = $('#optionalitem-' + id).text();
                    item["price"] = RemoveComma($('#money-' + id).text());
                    item["qty"] = $('#Optional-' + id).val();
                    var Today = new Date();
                    item["reqDate"] = Today.getFullYear() + "/" + (Today.getMonth() + 1) + "/" + Today.getDate();
                    jsonobj.push(item);
                }
            }
            storage.removeItem('Cart');
            storage.setItem('Cart', JSON.stringify(jsonobj));
            window.location.href = "SRP_CartList.aspx";

            //else {
            //    AlertDialog("Error saved configuration to cart");
            //}
        }

        function AlertDialog(str, second) {
            $("#AlertDialog div").html('');
            $("#AlertDialog div").html(str);

            $('#AlertDialog').css({//位置
                top: $(window).height() / 3 - 50,
                left: $(window).width() / 3 - 50
            });

            //設定自動關閉
            second = second || 5000;//如果為空就帶預設值5秒
            $('#AlertDialog').fadeIn("slow");//淡入顯示
            setTimeout("$('#AlertDialog').fadeOut('slow')", second);
        }

        //數字處理為有千分位
        function AppendComma(n) {
            if (!/^((-*\d+)|(0))$/.test(n)) {
                var newValue = /^((-*\d+)|(0))$/.exec(n);
                if (newValue != null) {
                    if (parseInt(newValue, 10)) {
                        n = newValue;
                    }
                    else {
                        n = '0';
                    }
                }
                else {
                    n = '0';
                }
            }
            if (parseInt(n, 10) == 0) {
                n = '0';
            }
            else {
                n = parseInt(n, 10).toString();
            }

            n += '';
            var arr = n.split('.');
            var re = /(\d{1,3})(?=(\d{3})+$)/g;
            return arr[0].replace(re, '$1,') + (arr.length == 2 ? '.' + arr[1] : '');
        }
        //將有千分位的數值轉為一般數字
        function RemoveComma(n) {
            return n.replace(/[,]+/g, '');
        }

        //只能輸入數字和小數點
        function onKeyPressBlockNumbers(e) {
            var key = window.event ? e.keyCode : e.which;
            var keychar = String.fromCharCode(key);
            reg = /[0-9]|\./;
            return reg.test(keychar);
        }
    </script>
    <input type="hidden" id="hdBTOId" />
    <input type="hidden" value="1" id="hdConfigQty" />
    <input type="hidden" value="0" id="hdIsOneLevel" />    
    <input type="hidden" value="1" id="hdIsForceChooseReqCat" />    
    <table width="100%">
        <tr>
            <td>
                <asp:Literal ID="ltBreadPath" runat="server" EnableViewState="false"></asp:Literal>
            </td>
        </tr>
        <tr>
            <td>
                <table>
                    <tr>
                        <td style="height:25px;">
                            <span id="spPartNo" style="font-size:xx-large; float: left;"></span>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <%--<span>COMPUTER SYSTEM, UNO-2271G-E23AE, HMI, 32G eMMC, WES7P, ADAM-6060</span>--%>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td valign="top" style=" background-color: #D4D4D4;">
                            <table width="450px" id="tbRequired" style="height:270px;">
                                <tr>
                                    <td valign="top">
                                         <div  style="margin: 5px; height:20px; padding: 20px 10px; background-color: #959595;">
                                             <div class="div_title" style="width:300px; float:left;"><span id="spDefaultPack"></span></div>
                                             <div class="div_right_bottom" style="width:110px; height:40px;vertical-align:middle;">
                                                 <div style="height:40px;width:60px; float:left;">
                                                     <span>Qty:</span><input type="text" id="txt1" value="1" class="Default" /><br />
                                                     <span>Sub-Total:</span> 
                                                 </div>
                                                 <div style="height:40px;float:right;">
                                                     <span id="default_price" style="text-decoration: line-through" >$1,500</span><br />
                                                     $<span id="default_sun">1,200</span>
                                                 </div>
                                             </div>
                                         </div>
                                        <div style="width: 450px;height:230px; overflow-x: hidden; overflow-y: auto;">
                                            <table id="tb_default" style="border: 1px; width: 440px; font-size: 12px;">
                                                <tbody>
                                                    <tr>
                                                        <td style="width:330px;">
                                                            <p id="defaulttitle1" style="font-weight: bold;">Application Software : WebAccess/HMI Runtime 1500 tags</p>
                                                            <p id="defaultitem1" style="margin-left: 30px;">Preinstalled WebAccess/HMI Runtime 1500 tags</p>
                                                        </td>
                                                        <td class="top">
                                                            <input type="button" style="width:20px" id="jian1" value="-" disabled="disabled"/>
                                                            <input class="Default" type="text" id="Default1" min="0" value="1" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;" disabled="disabled"/>
                                                            <input type="button" style="width:20px;" id="add1" value="+" disabled="disabled" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <p id="defaulttitle2" style="font-weight: bold;">System Computing : UNO-2271G-E23AE</p>
                                                            <p id="defaultitem2" style="margin-left: 30px;">Intel® Atom™ E3815 Pocket-Size DIN-rail PC, 4GB RAM, 32G eMMC</p>
                                                        </td>
                                                        <td class="top">
                                                            <input type="button" style="width:20px" id="jian2" value="-" disabled="disabled"/>
                                                             <input class="Default" type="text" id="Default2" min="0" value="1" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;" disabled="disabled"/>
                                                            <input type="button" style="width:20px" id="add2" value="+" disabled="disabled"/>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <p id="defaulttitle3" style="font-weight: bold;">O.S：Microsoft® Windows Embedded 7 Pro</p>
                                                            <p id="defaultitem3" style="margin-left: 30px;">Preinstalled Microsoft Windows Embedded 7 Pro</p>
                                                        </td>
                                                        <td class="top">
                                                           <input type="button" style="width:20px" id="jian3" value="-" disabled="disabled"/>
                                                            <input class="Default" type="text" id="Default3" min="0" value="1" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;" disabled="disabled"/>
                                                             <input type="button" style="width:20px" id="add3" value="+" disabled="disabled"/>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <p id="defaulttitle4" class="bold">Peripherals ：ADAM-6060-CE</p>
                                                            <p id="defaultitem4" style="margin-left: 30px;">6-ch Digital Input and 6-ch Power Relay Modbus TCP Module</p>
                                                        </td>
                                                        <td class="top">
                                                            <input type="button" style="width:20px" id="jian4" value="-" disabled="disabled"/>
                                                            <input class="Default" type="text" id="Default4" min="0" value="1" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;" disabled="disabled"/>
                                                            <input type="button" style="width:20px" id="add4" value="+" disabled="disabled"/>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top" style=" background-color: #D4D4D4;">
                            <table width="450px" id="tbOther" style="height:270px;">
                                <tr>
                                    <td valign="top">
                                        <div  style="margin: 5px; height:20px; padding: 20px 10px; background-color: #959595">
                                            <div class="div_title">Optional Configuration Items</div>
                                            <div class="div_right_bottom">Sub-Total: $<span id="Optional_sum">0</span></div>
                                        </div>
                                         <div style="width: 450px;height:230px; overflow-x: hidden; overflow-y: auto;">
                                            <table id="tb_Optional" style="border: 1px; width: 440px; font-size: 12px;">
                                                <tbody>
                                                    <%--<tr>
                                                        <td style="width:300px;">
                                                            <input type="button" style="width:20px" id="clear-1_1" value="-" />
                                                            <span class="bold">Option 100  WISE-PaaS/SaaS Software</span>
                                                            <p style="margin-left: 30px;">[101] WebAccess/SCADA 8.1 Prof. 1500 tags</p>
                                                        </td>
                                                        <td class="top">
                                                            <input type="button" style="width:20px" id="jian1" value="-" />
                                                            <input style="width:30px;text-align:center;" type="text" name="Optional" min="0" value="0" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;"/>
                                                            <input type="button" style="width:20px" id="add1" value="+" />
                                                        </td>
                                                        <td class="_top">
                                                            <span class="bold">$ </span><span class="Optional">200</span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="button" style="width:20px" id="clear-2_1" value="-" />
                                                            <span class="bold">Option 300  I/O & Peripherals</span>
                                                            <p style="margin-left: 30px;">[301] ADAM-6060-CE</p>
                                                        </td>
                                                        <td class="top">
                                                            <input type="button" style="width:20px" id="jian1" value="-" />
                                                            <input style="width:30px;text-align:center;" type="text" name="Optional" min="0" value="0" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;"/>
                                                            <input type="button" style="width:20px" id="add1" value="+" />
                                                        </td>
                                                        <td class="_top">
                                                            <span class="bold">$ </span><span class="Optional">100</span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="button" style="width:20px" id="clear-3_1" value="-" />
                                                            <span class="bold">Option 400  Add-on Accessories</span>
                                                            <p style="margin-left: 30px;">[401] PWR-247-CE</p>
                                                        </td>
                                                        <td class="top">
                                                            <input type="button" style="width:20px" id="jian1" value="-" />
                                                            <input style="width:30px;text-align:center;" type="text" name="Optional" min="0" value="0" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;"/>
                                                            <input type="button" style="width:20px" id="add1" value="+" />
                                                        </td>
                                                        <td class="_top">
                                                            <span class="bold">$ </span><span class="Optional">150</span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="button" style="width:20px" id="clear-4_1" value="-" />
                                                            <span class="bold">Option 800  Training & Consulting Service</span>
                                                            <p style="margin-left: 30px;">[801] Software Basic Training Course</p>
                                                        </td>
                                                        <td class="top">
                                                            <input type="button" style="width:20px" id="jian1" value="-" />
                                                            <input style="width:30px;text-align:center;" type="text" name="Optional" min="0" value="0" onkeypress="return onKeyPressBlockNumbers(event);" onpaste="return false;"/>
                                                            <input type="button" style="width:20px" id="add1" value="+" />
                                                        </td>
                                                        <td class="_top">
                                                            <span class="bold">$ </span><span class="Optional">50</span>
                                                        </td>
                                                    </tr>--%>
                                                </tbody>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr style="background-color: #D4D4D4;">
            <td valign="top">
                <table style="width:100%">
                    <tbody>
                        <tr>
                            <td>
                                <div  style="height:20px; width:80%; margin: 5px; padding: 15px 10px; background-color: #959595">
                                    <div>
                                        <span class="div_title">Total List Price：</span>
                                        <span style="font-weight: bold; color: #FFFFFF; font-size: large">$ </span>
                                        <span id="total_price" style="font-weight: bold; color: #FFFFFF; font-size: large">1,200</span>&nbsp;&nbsp;
                                        <span class="div_title">Total Discounted Price：</span>
                                        <span style="font-weight: bold; color: #FFFFFF; font-size: large">$ </span>
                                        <span id="total_discounted_price" style="font-weight: bold; color: #FFFFFF; font-size: large"></span>&nbsp;&nbsp;
                                        <span class="div_title">Discount：</span>
                                        <span id="discount" style="font-weight: bold; color: #FFFFFF; font-size: large">25.00</span>
                                        <span style="font-weight: bold; color: #FFFFFF; font-size: large">%</span>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td> 
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td align="left">
                            <a id="colExpAll" href="javascript:void(0);">Collapse All</a>
                        </td>
                        <td>
                            <input type="button" value="Click to Continue" onclick="Continue();" class="continueBtn" /><br />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <table width="100%" id="tbConfigurator" style="border-style: ridge; height: 300px">
                    <tr>
                        <td style="vertical-align: top">
                            <table class="table" width="100%">
                                <tr style="background-color:#376092;" >
                                    <td colspan="3">
                                        <p class="bold white" id="item_title_1">Option 100  WISE-PaaS/SaaS Software</p>
                                    </td>
                                    <td colspan="3">
                                         <p class="bold white" id="item_title_4">Option 400  Add-on Accessories</p>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p id="item_1_1">[101] BTOS P/N for SRP IT Ordering System test (SRP-FEC220-BTO)</p>
                                    </td>
                                     <td class="checkbox">
                                         <input id='1_1'  name='1_1' type='checkbox' value='1_1' onclick='checkbox_Optional(id,name)'/>
                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                        <asp:Label runat="server" Text="Qty:" Height="23px"></asp:Label>
                                        <input type="text" style="width:50px;text-align:center;" id="qty-1_1" value="" onchange='Optional_num(id)'/>
                                    </td>
                                     <td>
                                         <p id="item_4_1">[401] Power Adaptor (PWR-247-CE)</p>
                                         <div id="pa" style="display:none;"></div>
                                    </td>
                                     <td class="checkbox">
                                          <input id='4_1'  name='4_1' type='checkbox' value='4_1' onclick='checkbox_Optional(id,name)'/>
                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                         <asp:Label runat="server" Text="Qty:" Height="23px"></asp:Label>
                                        <input type="text" style="width:50px;text-align:center;"  id="qty-4_1" value="" onchange='Optional_num(id)'/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p id="item_1_2">[102] WebAccess/SCADA 8.1 Prof. 5000 tags</p>
                                    </td>
                                     <td class="checkbox">
                                           <input id='1_2'  name='1_2' type='checkbox' value='1_2' onclick='checkbox_Optional(id,name)'/>
                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                          <asp:Label runat="server" Text="Qty:" Height="23px"></asp:Label>
                                        <input type="text" style="width:50px;text-align:center;"  id="qty-1_2" value=""  onchange='Optional_num(id)'/>
                                    </td>
                                     <td>

                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                         
                                    </td>
                                     <td style="background-color: #D4D4D4;">

                                    </td>
                                </tr>
                                <tr style="background-color:#376092;" >
                                    <td colspan="3">
                                        <p class="bold white" id="item_title_2">Option 200  System Computing</p>
                                    </td>
                                    <td colspan="3">
                                         <p class="bold white" id="item_title_8">Option 800  Training & Consulting Service</p>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p id="item_2_1">[201]</p>
                                    </td>
                                     <td class="checkbox">
                                          <input id='2_1'  name='2_1' type='checkbox' value='2_1' onclick='checkbox_Optional(id,name)'/>
                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                          <asp:Label runat="server" Text="Qty:" Height="23px"></asp:Label>
                                        <input type="text" style="width:50px;text-align:center;"  id="qty-2_1" value=""  onchange='Optional_num(id)'/>
                                    </td>
                                     <td>
                                         <p id="item_8_1">[801] 1Hr Quick Start Phone Support (Preliminary)</p>
                                    </td>
                                     <td class="checkbox">
                                          <input id='8_1'  name='8_1' type='checkbox' value='8_1' onclick='checkbox_Optional(id,name)'/>
                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                         <asp:Label runat="server" Text="Qty:" Height="23px"></asp:Label>
                                        <input type="text" style="width:50px;text-align:center;"  id="qty-8_1" value=""  onchange='Optional_num(id)'/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>

                                    </td>
                                     <td style="background-color: #D4D4D4;">

                                    </td>
                                     <td style="background-color: #D4D4D4;">

                                    </td>
                                </tr>
                                <tr style="background-color:#376092;" >
                                    <td colspan="3">
                                        <p class="bold white" id="item_title_3">Option 300  I/O & Peripherals</p>
                                    </td>
                                    <td colspan="3">
                                         <p class="bold white" id="item_title_0">Remark</p>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p id="item_3_1">[301] Distributed Digital I/O (ADAM-6060-CE)</p>
                                    </td>
                                     <td class="checkbox">
                                          <input id='3_1'  name='3_1' type='checkbox' value='3_1' onclick='checkbox_Optional(id,name)'/>
                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                         <asp:Label runat="server" Text="Qty:" Height="23px"></asp:Label>
                                        <input type="text" style="width:50px;text-align:center;"  id="qty-3_1" value="" onchange='Optional_num(id)'/>
                                    </td>
                                     <td colspan="3" rowspan="2">
                                         <textarea cols="50" rows="5" style="width: 100%"></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p id="item_3_2">[302] Distributed Analog I/O (ADAM-6024-A1E)</p>
                                    </td>
                                     <td class="checkbox">
                                          <input id='3_2'  name='3_2' type='checkbox' value='3_2' onclick='checkbox_Optional(id,name)'/>
                                    </td>
                                     <td style="background-color: #D4D4D4;">
                                         <asp:Label runat="server" Text="Qty:" Height="23px"></asp:Label>
                                        <input type="text" style="width:50px;text-align:center;"  id="qty-3_2" value="" onchange='Optional_num(id)'/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td align="center">
                <input type="button" value="Click to Continue" onclick="Continue();" class="continueBtn" />
            </td>
        </tr>
    </table>  
     <div id="AlertDialog" class="popup" style="display: none">
        <a href="#" id="b-close"><span class="button b-close"><span>X</span></span></a>
        <div></div>
    </div> 
</asp:Content>

