<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="Configurator_SRP.aspx.cs" Inherits="Order_Configurator_SRP" %>

<%@ Register Src="~/Includes/CBOM/SRP_PowerCord.ascx" TagName="PowerCord" TagPrefix="SRP" %>
<%@ Register Src="~/Includes/CBOM/SRP_Remark.ascx" TagName="Remark" TagPrefix="SRP" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="/EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="/EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="/EC/Includes/json2.js"></script>
    <script type="text/javascript">
        $(function () {
            SetDefaultPackageQty();
            //Default package textbox.
            $("#DefaultQty").change(function () {
                var mq = parseInt($(this).val()) || 1;
                $(this).val(mq);
                
                GetDefaultPriceAndATP('<%=this.RealPartNo %> ', mq);

                $(".DefaultQty").each(function () {
                    var sq = parseInt($(this).attr("data-qty")) || 1;
                    $(this).val(mq * sq);
                });
            });

            //Optional package checkbox
            $(".selected").change(function () {
                var $dom = $(this);
                var cid = $dom.attr("data-id");
                var pid = $dom.attr("data-pid");
                var seq = $dom.attr("data-seq");
                var pn = $dom.attr("data-pn");
                var desc = $dom.attr("data-desc");

                if ($dom.prop("checked") == true) {

                    $(".Default").each(function () {
                        var $txt = $(this);
                        if ($txt.attr("data-id") == cid) {
                            $txt.val("1");
                        }
                    });

                    var category = "";
                    $(".category").each(function () {
                        var $txt = $(this);
                        if (pid == $txt.attr("data-id")) {
                            category = $txt.text();
                        }
                    });

                    GetPriceAndATP(pn, 1, cid);

                    var str = "<tr id='" + cid + "'>";
                    str += "<td style='width:300px;'>";
                    str += "<input type='button' style='width:20px' value='-' data-id='" + cid + "' onclick='RemoveOptional(this)'/>&nbsp;";
                    str += "<span class='bold'>" + category + "</span>";
                    str += "<p id='optionalitem-" + cid + "' style='margin-left: 30px;'>" + seq + desc + "(" + pn + ")" + "</p></td><td class='top'>";
                    str += "<input type='button' style='width:20px' value='-' onclick='SubOptional(this)'/>";
                    str += "<input style='width:30px;text-align:center;' type='text' class='final' min='0' value='1' data-id='" + cid + "' data-pn='" + pn + "' data-desc='"+ desc + "' onchange='UpdateOptionalQty(this)'/> ";
                    str += "<input type='button' style='width:20px' value='+' onclick='AddOptional(this)'/>";
                    str += "</td><td class='_top' data-id='" + cid + "'></td></tr>";
                    $('#tb_Optional tbody').append(str);

                    //401 - Power cord region
                    if ($dom.hasClass("PowerCord")) {
                        $("#<%=PowerCordPanelID%>").show();
                        $('input[name=PowerCord]').each(function (i, n) {
                            if (i == 0) {
                                var pcHTML = ShowPowerCord(this, cid);
                                $('#tb_Optional tbody').append(pcHTML);
                            }
                        });
                    }
                }
                else {
                    $("#" + cid).remove();
                    $(".Default").each(function () {
                        if (cid == $(this).attr("data-id"))
                            $(this).val("");
                    });
                    //401 - Power cord region
                    if ($dom.hasClass("PowerCord")) {
                        $("#<%=PowerCordPanelID%>").hide();
                        $("#mypc").remove();
                    }

                    CalculateTotalPrice();
                }
            });

            $("#<%=PowerCordPanelID%>").hide();

            $('input[name=PowerCord]').change(function () {
                var $dom = $(this);
                if ($dom.prop("checked") == true) {
                    var pn = $dom.attr("data-pn");
                    var desc = $dom.attr("data-desc");
                    var lp = $dom.attr("data-listprice");
                    var up = $dom.attr("data-unitprice");
                    var qty = $("#pcqty").val();
                    lp = formatFloat(lp * qty, 2);
                    up = formatFloat(up * qty, 2);
                    $("#pcdesc").text(pn + " " + desc);
                    $("#pclp").text(lp);
                    $("#pcup").text(up);
                    $("#pcqty").attr("data-desc", desc);
                    $("#pcqty").attr("data-pn", pn);
                    CalculateTotalPrice();
                }
            });
        });

        function RemoveOptional(node) {
            var cid = $(node).attr("data-id");
            $("#" + cid).remove();
            $(".selected").each(function () {
                if (cid == $(this).attr("data-id")) {
                    $(this).prop("checked", false);
                }
            });
            $(".Default").each(function () {
                if (cid == $(this).attr("data-id")) {
                    $(this).val("");
                }
            });

            var $pc = $("#mypc");
            if ($pc && $pc.attr("data-pc") == cid) {
                $pc.remove();
                $("#<%=PowerCordPanelID%>").hide();
            }

            CalculateTotalPrice();
        }

        function UpdateOptionalQty(node) {
            var $node = $(node);
            var cid = $node.attr("data-id");
            var total = CalculateQty($node, 0);
            var pn = $node.attr("data-pn");

            var $pc = $("#mypc");
            if ($pc && $pc.attr("data-pc") == cid) {
                $("#pcqty").val(total);
                var lp = $("#pclp").attr("data-listprice");
                var up = $("#pcup").attr("data-unitprice");
                lp = formatFloat(lp * total, 2);
                up = formatFloat(up * total, 2);
                $("#pclp").text(lp);
                $("#pcup").text(up);
            }

            GetPriceAndATP(pn, total, cid);
        }

        function SubOptional(node) {
            $node = $(node).next();
            var cid = $node.attr("data-id");
            var total = CalculateQty($node, -1);
            var pn = $node.attr("data-pn");

            var $pc = $("#mypc");
            if ($pc && $pc.attr("data-pc") == cid) {
                $("#pcqty").val(total);
                var lp = $("#pclp").attr("data-listprice");
                var up = $("#pcup").attr("data-unitprice");
                lp = formatFloat(lp * total, 2);
                up = formatFloat(up * total, 2);
                $("#pclp").text(lp);
                $("#pcup").text(up);
            }

            GetPriceAndATP(pn, total, cid);
        }

        function AddOptional(node) {
            $node = $(node).prev();
            var cid = $node.attr("data-id");
            var total = CalculateQty($node, 1);
            var pn = $node.attr("data-pn");

            var $pc = $("#mypc");
            if ($pc && $pc.attr("data-pc") == cid) {
                $("#pcqty").val(total);
                var lp = $("#pclp").attr("data-listprice");
                var up = $("#pcup").attr("data-unitprice");
                lp = formatFloat(lp * total, 2);
                up = formatFloat(up * total, 2);
                $("#pclp").text(lp);
                $("#pcup").text(up);
            }

            GetPriceAndATP(pn, total, cid);
        }

        function CalculateQty(node, qty) {
            var q = parseInt(node.val()) || 1;
            var total = q + qty;
            if (total < 1)
                return 1;
            node.val(total);
            $(".Default").each(function () {
                if (node.attr("data-id") == $(this).attr("data-id"))
                    $(this).val(total);
            });
            return total;
        }

        function GetPriceAndATP(pn, qty, cid) {
            var postData = {
                PartNo: pn,
                Qty: qty
            };
            $.ajax({
                url: '/Services/CBOMV2_Configurator.asmx/GetSRPPrice',
                type: "POST", dataType: 'json', data: postData,
                success: function (retData) {
                    if (retData.result == false) {
                        $("._top").each(function () {
                            if (cid == $(this).attr("data-id")) {
                                $(this).html("<span class='bold'>" + retData.currencysign + "</span>&nbsp;<span class='OptionUnitPrice'>" + retData.unitprice + "</span>" + "<span class='OptionListPrice defaultBtn'>" + retData.listprice + "</span>");
                            }
                        });
                        CalculateTotalPrice();
                        //str += "&nbsp; <b>Available on:</b>" + priceATP.ATPDate + "&nbsp;<b>Qty:</b>&nbsp;" + ((priceATP.ATPQty > 0) ? (((priceATP.ATPQty > 1) ? (priceATP.ATPQty + 'pcs') : ('1pc'))) : ('N/A'));
                    }
                },
                error: function (msg) {
                    
                }
            });
        }

        function GetDefaultPriceAndATP(pn, qty) {
            var postData = {
                PartNo: pn,
                Qty: qty
            };
            $.ajax({
                url: '/Services/CBOMV2_Configurator.asmx/GetSRPPrice',
                type: "POST", dataType: 'json', data: postData,
                success: function (retData) {
                    if (retData.result == false) {
                        $("#default_unitprice").text(retData.unitprice);
                        $("#default_listprice").text(retData.listprice);
                        CalculateTotalPrice();
                    }
                },
                error: function (msg) {

                }
            });
        }

        function CalculateTotalPrice() {
            //Calculate list price
            var listprice = [];
            //Calculate default package list price.
            listprice.push({
                price: $("#default_listprice").text()
            });
            //Calcaulate option package list price.
            $(".OptionListPrice").each(function () {
                listprice.push({
                    price: $(this).text()
                });
            });

            //Calculate unit price
            var unitprice = [];
            //Calcaulate option package unit price.
            $(".OptionUnitPrice").each(function () {
                unitprice.push({
                    price: $(this).text()
                });
            });
            var postData = { ListPrices: JSON.stringify(unitprice), UnitPrices: JSON.stringify(unitprice) };
            $.post("/Services/CBOMV2_Configurator.asmx/CalculateTotalPrice", postData, function (data) {
                if (data) {
                    $("#Optional_sum").text(data.unitprice);
                }
            }, "json");

            //Calculate default package unit price.
            unitprice.push({
                price: $("#default_unitprice").text()
            });

            postData = { ListPrices: JSON.stringify(listprice), UnitPrices: JSON.stringify(unitprice) };
            $.post("/Services/CBOMV2_Configurator.asmx/CalculateTotalPrice", postData, function (data) {
                if (data) {
                    $("#total_price").text(data.listprice);
                    $("#total_discounted_price").text(data.unitprice);
                }
            }, "json");
        }

        //小數點第N位四捨五入
        function formatFloat(num, pos) {
            var size = Math.pow(10, pos);
            return Math.round(num * size) / size;
        }

        function ShowPowerCord(node, cid) {
            var $rd = $(node);
            $rd.prop('checked', true);
            var pn = $rd.attr("data-pn");
            var desc = $rd.attr("data-desc");
            var cur = $rd.attr("data-curr");
            var lp = $rd.attr("data-listprice");
            var up = $rd.attr("data-unitprice");
            var txt = "<tr id='mypc' data-pc='" + cid + "'><td style='width:300px;'>";
            txt += "<input type='button' style='width:20px; visibility: hidden' value='-' />&nbsp;<span id='pcdesc' class='bold'>" + pn + "&nbsp;" + desc + "</span></td><td class='top'>";
            txt += "<input type='button' style='width:20px; visibility: hidden' value='-' />";
            txt += "<input id='pcqty' style='width:30px;text-align:center;' type='text' class='final' min='0' value='1' data-pn='" + pn + "' data-desc='" + desc + "' disabled='disabled' /> ";
            txt += "<input type='button' style='width:20px; visibility: hidden' value='+' />";
            txt += "</td><td style='vertical-align: top;'><span class='bold'>" + cur + "</span>&nbsp;<span id='pcup' class='OptionUnitPrice' data-unitprice='"+ up + "'>" + up + "</span><span id='pclp' data-listprice='" + lp + "' class='OptionListPrice defaultBtn' >" + lp + "</span></td></tr>";
            return txt;
        }

        function Continue() {

            var langpack = $('input[name=Remark]:checked').attr("data-pn") || "";
            //if (!!langpack === false) {
                //alert("Please select language pack");
                //return false;
            //}

            var items = [];
            items.push({
                //Real SRP pn.
                name: '<%=this.RealPartNo%>',
                qty: $("#DefaultQty").val(),
                desc: ""
            });
            //Optional pn.
            $(".final").each(function () {
                var $dom = $(this);
                items.push({
                    name: $dom.attr("data-pn"),
                    desc: $dom.attr("data-desc"),
                    qty: $dom.val()
                });
            });

            var postData = { SelectedItems: JSON.stringify(items), LanguagePack: JSON.stringify(langpack) };
            $.post("/Services/CBOMV2_Configurator.asmx/Add2CartForSRP", postData, function (data) {
                var str = data.IsUpdated;
                if (str) {
                    window.location.href = "Cart_ListV2.aspx";
                } else {
                    alert(data.ServerMessage);
                }
            }, "json");
        }

        function SetDefaultPackageQty() {
            var mq = parseInt($("#DefaultQty").val()) || 1;
            $(".DefaultQty").each(function () {
                var sq = parseInt($(this).attr("data-qty")) || 1;
                $(this).val(mq * sq);
            });
        }
    </script>
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

        .div_title {
            font-size: large;
            font-weight: bold;
        }

        .div_right_bottom {
            color: white;
            float: right;
        }

        .bold {
            font-weight: bold;
        }

        .top {
            vertical-align: top;
            width: 100px;
        }

        ._top {
            vertical-align: top;
        }

        .Optional {
            font-weight: bold;
        }

        .Default {
            width: 25px;
            text-align: center;
        }

        .checkbox {
            background-color: #D4D4D4;
            vertical-align: middle;
            text-align: center;
        }

        .white {
            color: white;
        }

        .defaultBtn {
            display: none;
        }
    </style>
    <table width="100%">
        <tr>
            <td>
                <span style="width: 41%;">
                    <font color="Navy">■</font>&nbsp;&nbsp;
                    <a href="/Order/btos_portal.aspx" target="_self" style="color:Navy;font-weight:bold; text-decoration:none;">System Configuration/Ordering Portal</a>
                    <strong>&nbsp;&nbsp;>&nbsp;&nbsp;<%=this.RealPartNo %></strong>
                    <asp:Button ID="btnDefault" runat="server" UseSubmitBehavior="false" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false" CssClass="defaultBtn" OnClientClick="return false;" />
                </span>
            </td>
        </tr>
        <tr>
            <td>
                <table>
                    <tr>
                        <td style="height: 25px;">
                            <span id="spPartNo" style="font-size: xx-large; float: left;"><%=this.RealPartNo %></span>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td valign="top" style="background-color: #D4D4D4;">
                            <table width="450px" id="tbRequired" style="height: 270px;">
                                <tr>
                                    <td valign="top">
                                        <div style="margin: 5px; height: 20px; padding: 20px 10px; background-color: #959595;">
                                            <div class="div_title" style="width: 300px; float: left;"><span><%=this.RealPartNo %> Package Offering</span></div>
                                            <div class="div_right_bottom" style="vertical-align: middle;">
                                                <div style="height: 40px; width: 60px; float: left;">
                                                    <span>Qty:</span><input type="text" id="DefaultQty" value="<%=this.BTOSQTY %>" class="Default" autocomplete="off" /><br />
                                                </div>
                                                <div style="height: 40px; float: right;">
                                                    <span><%=this.CurrencySign %></span>
                                                    <span id="default_unitprice"><%=this.DefaultUnitPrice %></span><span id="default_listprice" class="defaultBtn"><%=this.DefaultListPrice %></span>
                                                </div>
                                            </div>
                                        </div>
                                        <div style="width: 450px; height: 230px; overflow-x: hidden; overflow-y: auto;">
                                            <table id="tb_default" style="border: 1px; width: 440px; font-size: 12px;">
                                                <tbody>
                                                    <asp:Repeater ID="rpDefaultpackage" runat="server" OnItemDataBound="rpDefaultpackage_ItemDataBound" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false">
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td style="width: 330px;">
                                                                    <asp:Literal ID="ltDefaultComponent" runat="server" EnableViewState="false" ViewStateMode="Disabled"></asp:Literal>
                                                                </td>
                                                                <td class="top">
                                                                    <input type="button" style="width: 20px" id="jian1" value="-" disabled="disabled" />
                                                                    <asp:TextBox ID="txtDefaultQty" runat="server" Enabled="false" CssClass="Default DefaultQty" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false"></asp:TextBox>
                                                                    <input type="button" style="width: 20px;" id="add1" value="+" disabled="disabled" />
                                                                </td>
                                                            </tr>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </tbody>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top" style="background-color: #D4D4D4;">
                            <table width="450px" id="tbOther" style="height: 270px;">
                                <tr>
                                    <td valign="top">
                                        <div style="margin: 5px; height: 20px; padding: 20px 10px; background-color: #959595">
                                            <div class="div_title">Optional Configuration Items</div>
                                            <div class="div_right_bottom">Sub-Total: <span><%=this.CurrencySign %></span><span id="Optional_sum">0</span></div>
                                        </div>
                                        <div style="width: 450px; height: 230px; overflow-x: hidden; overflow-y: auto;">
                                            <table id="tb_Optional" style="border: 1px; width: 440px; font-size: 12px;">
                                                <tbody>
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
        <tr>
            <td valign="top">
                <table width="100%" style="border-style: ridge; height: 300px">
                    <tr>
                        <td style="vertical-align: top">
                            <table class="table" width="100%">
                                <tr>
                                    <td>
                                        <div style="display: inline-block; width: 50%; vertical-align:top; float:left;">
                                            <table>
                                                <asp:Repeater ID="rpOptionLeft" runat="server" OnItemDataBound="rpOption_ItemDataBound" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false">
                                                    <ItemTemplate>
                                                        <tr style="background-color: #376092;">
                                                            <td colspan="3">
                                                                <p class="bold white category" data-id='<%#Eval("id") %>'><%#Eval("text") %></p>
                                                            </td>
                                                        </tr>
                                                        <asp:Repeater ID="rpOptionChild" runat="server" OnItemDataBound="rpOptionChild_ItemDataBound" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false">
                                                            <ItemTemplate>
                                                                <tr>
                                                                    <td style="width:85%;">
                                                                        <p><%#string.Format("[{0}] {1} ({2})", Eval("configurationrule"), Eval("desc"), Eval("text")) %></p>
                                                                        <SRP:PowerCord ID="pcd" runat="server" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false" />
                                                                        
                                                                    </td>
                                                                    <td class="checkbox">
                                                                        <input class="selected <%#Eval("virtualid") %>" type='checkbox' data-id='<%#Eval("id") %>' data-pid='<%#Eval("parentid") %>' data-pn='<%#Eval("text") %>' 
                                                                            data-desc='<%#Eval("desc") %>' data-seq='<%#string.Format("[{0}]", Eval("configurationrule")) %>' />
                                                                    </td>
                                                                    <td style="background-color: #D4D4D4;">
                                                                        <span>Qty:</span>
                                                                        <input type="text" style="width: 20px; text-align: center;" disabled="disabled" class="Default" value="" data-id='<%#Eval("id") %>'  />
                                                                    </td>
                                                                </tr>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                        <SRP:Remark ID="rm" runat="server" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false" />
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </table>
                                        </div>
                                        <div style="display: inline-block; width: 50%; vertical-align:top; float:right;">
                                            <table>
                                                <asp:Repeater ID="rpOptionRight" runat="server" OnItemDataBound="rpOption_ItemDataBound" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false">
                                                    <ItemTemplate>
                                                        <tr style="background-color: #376092;">
                                                            <td colspan="3">
                                                                <p class="bold white category" data-id='<%#Eval("id") %>'><%#Eval("text") %></p>
                                                            </td>
                                                        </tr>
                                                        <asp:Repeater ID="rpOptionChild" runat="server" OnItemDataBound="rpOptionChild_ItemDataBound" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false">
                                                            <ItemTemplate>
                                                                <tr>
                                                                    <td style="width:85%;">
                                                                        <p><%#string.Format("[{0}] {1} ({2})", Eval("configurationrule"), Eval("desc"), Eval("text")) %></p>
                                                                        <SRP:PowerCord ID="pcd" runat="server" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false" />
                                                                    </td>
                                                                    <td class="checkbox">
                                                                        <input class="selected <%#Eval("virtualid") %>" type='checkbox' data-id='<%#Eval("id") %>' data-pid='<%#Eval("parentid") %>' data-pn='<%#Eval("text") %>' 
                                                                            data-desc='<%#Eval("desc") %>' data-seq='<%#string.Format("[{0}]", Eval("configurationrule")) %>' />
                                                                    </td>
                                                                    <td style="background-color: #D4D4D4;">
                                                                        <span>Qty:</span>
                                                                        <input type="text" style="width: 20px; text-align: center;" disabled="disabled" class="Default" value="" data-id='<%#Eval("id") %>'  />
                                                                    </td>
                                                                </tr>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                        <SRP:Remark ID="rm" runat="server" ViewStateMode="Disabled" EnableViewState="false" EnableTheming="false" />
                                                    </ItemTemplate>
                                                </asp:Repeater>
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
                <table style="width: 100%">
                    <tbody>
                        <tr>
                            <td>
                                <div style="height: 20px; width: 95%; margin: 5px; padding: 15px 10px; background-color: #959595">
                                    <div>
                                        <span class="div_title">Total List Price：</span>
                                        <span id="total_price_cur" style="font-weight: bold; color: #FFFFFF; font-size: large"><%=this.CurrencySign %></span>
                                        <span id="total_price" style="font-weight: bold; color: #FFFFFF; font-size: large"><%=this.DefaultListPrice %></span>&nbsp;&nbsp;
                                        <span class="div_title">Total Discounted Price：</span>
                                        <span id="total_discounted_cur" style="font-weight: bold; color: #FFFFFF; font-size: large"><%=this.CurrencySign %></span>
                                        <span id="total_discounted_price" style="font-weight: bold; color: #FFFFFF; font-size: large"><%=this.DefaultUnitPrice%></span>&nbsp;&nbsp;
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td align="center">
                <input type="button" value="Click to Continue" onclick="Continue();" class="continueBtn" />
            </td>
        </tr>
    </table>
    </asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

