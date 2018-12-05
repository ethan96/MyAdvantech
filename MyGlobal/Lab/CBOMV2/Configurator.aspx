<%@ Page Title="MyAdvantech - eConfigurator" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    AutoEventWireup="false" CodeFile="Configurator.aspx.vb" Inherits="Lab_ConfiguratorJQ" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../EC/Includes/jquery-ui.js"></script>
    <script type="text/javascript" src="../../EC/Includes/json2.js"></script>
    <script type="text/javascript">

        $(document).ready(function(){});

        function InitReconfigData(rid) {
            busyMode(1);
            var postData = JSON.stringify({ ReConfigId: rid });
            $.ajax(
                {
                    type: "POST", url: "Configurator.aspx/GetReconfigTree", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        //console.log("call GetReconfigTree ok");
                        var ReconfigTreeObject = $.parseJSON(retData.d); $("#hdBTOId").val(ReconfigTreeObject.BTOItem);
                        $("#tbConfigurator").html(ReconfigTreeObject.ReConfigTreeHtml); $("#hdConfigQty").val(ReconfigTreeObject.ReConfigQty);
                        var priceNodes = $(".divPriceValue");
                        //console.log("priceNodes length:" + priceNodes.length);
                        $.each(priceNodes, function (idx, item) {
                            $($($(item).parent().parent()).children(".compOption")).prop("checked", true);
                            //console.log("check mate");
                        }
                        );
                        calcTotalPriceMaxDueDate();
                        var arrCatcomp = {
                            CategoryId: ReconfigTreeObject.BTOItem, CategoryType: "category", ChildComps: []
                        };
                        $("#tbConfigResult").html(getCheckedComps('tbConfigurator', arrCatcomp));
                        busyMode(0);
                    },
                    error: function (msg) {
                        //console.log("call GetReconfigTree err:" + msg.d);
                        busyMode(0);
                    }
                }
            );
        }

        function InitLoadBOM() {
            appendChildCBom($('#tbConfigurator'), $('#hdBTOId').val(), 0); var $scrollingDiv = $("#configResult"); $scrollingDiv.css("opacity", 0.9);
            $(window).scroll(function () {
                $scrollingDiv.stop().animate({ "marginTop": ($(window).scrollTop()) }, "slow");
            });
        }

        function busyMode(modeCode) {
            //(modeCode == 1) ? $("body").css("cursor", "progress") : $("body").css("cursor", "auto");
            var progressNode = $("#ctl00_UpdateProgress2");
            if (modeCode == 1) {progressNode.css("visibility", "visible");}
            else {progressNode.css("visibility", "hidden");}
        }        

        function fillChildBOM(inputId, tableId, level) {            
            var categoryValue = $("#" + inputId).attr("compname");  calcTotalPriceMaxDueDate(); var targetTable = $('#' + tableId);   
            var arrCatcomp = {CategoryId: categoryValue, CategoryType: "category", ChildComps: []};
            $("#tbConfigResult").html(getCheckedComps('tbConfigurator', arrCatcomp));
            if (inputId == "" || categoryValue == "") return;
            var priceNode = $("#" + inputId).parent().children(".divPrice")[0]; atpNode = $("#" + inputId).parent().children(".divATP")[0];
            var postData = JSON.stringify({ ComponentCategoryId: categoryValue, ConfigQty: $('#hdConfigQty').val() });
            $.ajax(
                {
                    type: "POST", url: "Configurator.aspx/GetCompPriceATP", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        var priceATP = $.parseJSON(retData.d);
                        //Check if item is AGS-EW item      
                        //console.log(categoryValue + " priceATP.ATPQty:" + priceATP.ATPQty);
                        if (priceATP.IsEw == false) {
                            $(priceNode).html("<b>Price:</b>" + priceATP.CurrencySign + "<div class='divPriceValue' style='display:inline;'>" + priceATP.Price) + "</div>";
                            $(atpNode).html("<b>Available on:</b>" + "<div class='divATPValue' style='display:inline;'>" + priceATP.ATPDate + "</div>,&nbsp;<b>Qty:</b>&nbsp;<div class='divATPQty' style='display:inline;'>" + ((priceATP.ATPQty > 0) ? (((priceATP.ATPQty > 1) ? (priceATP.ATPQty + 'pcs') : ('1pc'))) : ('N/A')) + "</div>");
                        }
                        else {
                            $(priceNode).html("<b>Price:</b><div class='divPriceValue' style='display:inline;'>" + priceATP.Price + "%") + "</div>";
                            $(atpNode).html("<b>Available on:</b>" + "<div class='divATPValue' style='display:inline;'>" + (new Date()).format("yyyy/MM/dd") + "</div>");
                        }
                        appendChildCBom(targetTable, categoryValue, level);
                        calcTotalPriceMaxDueDate();
                    },
                    error: function (msg) {
                        //console.log('err getpriceatp ' + msg.d);
                        busyMode(0);
                    }
                }
            );
        }

        function appendChildCBom(tableElement, CategoryValue, level) {
            //console.log("appendChildCBomCategoryValue:" + CategoryValue);
            tableElement.empty();
            //if (!CategoryValue) { tableElement.empty(); return; }
            level = parseInt(level); var tableId = tableElement.attr('id');
            if (!CategoryValue || CategoryValue == "") {
                tableElement.css('border-style', 'none'); return;
            }
            //console.log("hdIsOneLevel:" + $("#hdIsOneLevel").val());
            if ($("#hdIsOneLevel").val() == "1" && level > 0) { return; }

            busyMode(1);
            var postData = JSON.stringify({ ParentCategoryId: CategoryValue, ConfigQty: $('#hdConfigQty').val() });
            $.ajax(
                {
                    type: "POST", url: "Configurator.aspx/GetCBOM", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        appendChildCBomSuccess(retData, tableElement, level);
                    },
                    error: function (msg) {
                        //console.log('err GetCBOM ' + msg.d);
                        busyMode(0);
                    }
                }
            );
        }

        function appendChildCBomSuccess(retData, tableElement, level) {
            var bomRows = $.parseJSON(retData.d);
            //For each category append it to tableElement
            $.each(bomRows, function (index, item) {
                if (item.ChildCategories.length == 0) {
                    if (item.IsCatRequired) {
                        //disable order button and alert category is required but has no component to choose
                        //20150401 TC: If $("#hdIsForceChooseReqCat").val()==0 then no force to disable continue button                          
                        $($("#divReqCatNoComp").children("b")).text(item.CategoryId);
                        $("#divReqCatNoComp").dialog({
                            modal: true, width: '30%', height: 120,
                            open: function (event, ui) {
                                //
                                if ($("#hdIsForceChooseReqCat").val() == 0) {
                                    console.log("Close popup after 5 secs");
                                    setTimeout("$('#divReqCatNoComp').dialog('close')", 5000);
                                }
                            }
                        });

                        if ($("#hdIsForceChooseReqCat").val() == 1) {
                            $(".continueBtn").prop('disabled', true);
                        }                        
                    }
                    //console.log(item.CategoryId + " has no components"); 
                    return true;
                }
                var childTableId = "chtb_" + item.ClientId + "_" + (level + 1); selGrpName = "grp_" + childTableId;
                var compSelection = "<table width='100%' isreq=" + ((item.IsCatRequired) ? "true" : "false") + " catname='" + item.CategoryId + "'>";
                if (item.ChildCategories.length > 0) {
                    tableElement.css('border-style', 'ridge');
                    //Add Select... as the first component selection
                    compSelection +=
                                    "<tr>" +
                                        "<td>" +
                                            "<input type='radio' compname='' name='" + selGrpName + "' onclick=fillChildBOM('','" + childTableId + "','" + (level + 1) + "'); " + ((hasDefaultComp) ? "" : "checked") + ">Select..." +
                                        "</td>" +
                                    "</tr>";
                }

                var hasDefaultComp = false;
                $.each(item.ChildCategories, function (idx, compItem) { if (compItem.IsCompDefault) hasDefaultComp = true; });
                var showHideAnchorId = "showHideAnchor_" + item.ClientId; trSelId = "trSel_" + item.ClientId;
                //For each component under current catetory append it under category
                $.each(item.ChildCategories, function (idx, compItem) {
                    //console.log("IsCompDefault:"+compItem.IsCompDefault);
                    //Loop all components and add as current category
                    var inputCompId = "rcomp_" + compItem.ClientId + "_" + idx + "_" + (level + 1);
                    compSelection +=
                                "<tr>" +
                                    "<td>" +
                                        "<input compname='" + compItem.CategoryId + "' id='" + inputCompId + "' class='compOption' type='radio' name='" + selGrpName + "' onclick=fillChildBOM('" + inputCompId + "','" + childTableId + "','" + (level + 1) + "'); " + ((compItem.IsCompDefault) ? "checked" : "") + " />" +
                                            compItem.CategoryId + " -- " + compItem.Description +
                                            ((compItem.IsCompRoHS == true) ? "&nbsp;<img alt='RoHS' src='../../Images/rohs.jpg' />" : "") +
                                            ((compItem.IsHot == true) ? "&nbsp;<img alt='Hot' src='../../Images/Hot-orange.gif' />" : "") +
                                            "&nbsp;<div class='divPrice' style='display:inline'></div>" +
                                            "&nbsp;<div class='divATP' style='display:inline'></div>" +
                                    "</td>" +
                                "</tr>";
                    if (compItem.IsCompDefault) {
                        //console.log("setting time out for " + childTableId);
                        setTimeout("fillChildBOM('" + inputCompId + "','" + childTableId + "', '" + (level + 1) + "');", 100);
                    }
                }
                            );
                compSelection +=
                                "<tr>" +
                                    "<td>" +
                                    "   <table class='trChildTable' width='100%' id='" + childTableId + "' style='border-style:none'></table>" +
                                    "</td>" +
                                "</tr>" +
                            "</table>";
                tableElement.append(
                                "<tr>" +
                                    "<td>" +
                                        "<table width='100%'>" +
                                            "<tr style='background-color:#000080; width:100%'>" +
                                                "<td style='color:White; font-weight:bold; width:100%'>" +
                                                    "<input class='catHeader' type='button' style='width:13px; height:17px' id='" + showHideAnchorId + "' onclick=collapseExpand('" + showHideAnchorId + "','" + trSelId + "'); value='" + ((item.IsCatRequired) ? "-" : "+") + "' /> " +
                                                    item.CategoryId + ((item.IsCatRequired) ? " <font color='red'>(Required)</font>" : "") +
                                                "</td>" +
                                            "</tr>" +
                                            "<tr id='" + trSelId + "' class='trSelection' style='width:100%; display:" + ((item.IsCatRequired) ? "block" : "none") + "'>" +
                                            "   <td>" + compSelection + "</td>" +
                                            "</tr>" +
                                        "</table>" +
                                    "</td>" +
                                "</tr>");
                $(tableElement).css("width", "100%");
            });
            busyMode(0);
        }

        function collapseExpand(anchorId, trSelId) {
            var anchorNode = $("#" + anchorId); var trSelNode = $("#" + trSelId);
            if (anchorNode.val().indexOf("-") >= 0) {
                trSelNode.css("display", "none"); anchorNode.val("+");
            }
            else {
                trSelNode.css("display", "block"); anchorNode.val("-"); trSelNode.css("width", "100%");
            }
        }

        function collapseExpandAll() {
            //console.log($("#colExpAll").text());
            if ($("#colExpAll").text().indexOf("Collapse") >= 0) {
                $(".trSelection").css("display", "none"); $(".catHeader").val("+"); $("#colExpAll").text("Expand All");
            }
            else {
                $(".trSelection").css("display", "block"); $(".catHeader").val("-"); $("#colExpAll").text("Collapse All");
            }
        }

        function checkAndContinue() {  
            $(".continueBtn").prop('disabled', true);
            var blReqNotChecked = false;
            var reqCats = $('table[isreq=true]');
            $.each(reqCats, function (idx, item) {
                //console.log("req cat id:" + $(item).parent().parent().attr("id"));
                var checkedCompOption = $("> tbody > tr > td > input.compOption:checked", $(item));
                if (checkedCompOption.length == 0) {
                    $("#colExpAll").text("Expand All"); collapseExpandAll();
                    $(window).scrollTop($(item).position().top - 350);
                    $("#reqCatDialog").find(".pcatname").text($(item).attr("catname"));
                    $("#reqCatDialog").dialog({
                        modal: true, width: '50%', height: 100,
                        open: function (event, ui) {
                            setTimeout("$('#reqCatDialog').dialog('close')", 3000);
                        }
                    });
                    blReqNotChecked = true; $(".continueBtn").prop('disabled', false);
                }
            }
            );
            if (blReqNotChecked == false) {
                //console.log("blReqNotChecked is false");
                var arrCatcomp = {
                    CategoryId: $("#hdBTOId").val(), CategoryType: "category", ChildComps: []
                };
                busyMode(1); getCheckedComps('tbConfigurator', arrCatcomp);
                var postData = JSON.stringify({ RootComp: arrCatcomp, ConfigQty: $('#hdConfigQty').val(), ConfigTreeHtml: $("#tbConfigurator").html() });
                $.ajax(
                {
                    type: "POST", url: "Configurator.aspx/SaveConfigResult", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        //console.log("GetConfigResult ok:" + retData.d);
                        var retMsg = $.parseJSON(retData.d); busyMode(0);
                        if (retMsg.ProcessStatus == true) {
                            window.location.href = "cart_list.aspx";
                        }
                        else {
                            alert("Error saved configuration to cart:" + retMsg.ProcessMessage);
                        }
                    },
                    error: function (msg) {
                        //console.log('err GetConfigResult ' + msg.d);
                        busyMode(0);
                        //$(thisBtn).prop('disabled', false);
                        $(".continueBtn").prop('disabled', false);
                    }
                }
            );              
            }
        }

        function getCheckedComps(tableId, arrCatcomp) {
            var retStr = "<table width='100%'>";
            var trSelectedComps = $("> tbody > tr > td > table > tbody > tr > td > table > tbody > tr > td > input.compOption:checked", $("#" + tableId));
            $.each(trSelectedComps, function (idx, item) {
                var childTable = $("> tr > td > table.trChildTable", $(item).parent().parent().parent());
                if (childTable) {
                    var catname = $($(item).parent().parent().parent().parent()).attr("catname");
                    var compname = $(item).attr("compname");
                    var compNode = { CategoryId: compname, CategoryType: "component", ChildComps: []
                    };
                    var catNode = {
                        CategoryId: catname, CategoryType: "category", ChildComps: []
                    };
                    catNode.ChildComps.push(compNode); arrCatcomp.ChildComps.push(catNode);
                    //console.log("catname:" + catname + ",compname:" + compname);
                    retStr +=
                      "<tr style='display:block'>" +
                        "<td><input style='width:13px; height:17px' type='button' value='-' onclick='showHideNextTr(this);' /></td>" +
                        "<td>" + catname + "</td>" +
                      "</tr>" +
                      "<tr style='display:block'>" +
                        "<td></td>" +
                        "<td>" +
                            "<table width='100%'>" +
                                "<tr>" +
                                    "<td>" + compname + "</td>" +
                                "</tr>" +
                                "<tr>" +
                                    "<td>" + getCheckedComps($(childTable).attr("id"), compNode) + "</td>" +
                                "</tr>" +
                            "</table>" +
                        "</td>" +
                      "</tr>";
                };
            }
            );
            retStr += "</table>";
            return retStr;
        }

        function showHideNextTr(o) {
            var blockOrNone = ($(o).val() == "-") ? "none" : "block"; var newValue = ($(o).val() == "-") ? "+" : "-"; $($(o).parent().parent().next()).css("display", blockOrNone); $(o).val(newValue);
        }

        function calcTotalPriceMaxDueDate() {
            var totalPrice = 0; var maxDd = new Date(); var ewRate = 0.0; var selectedInputs = $('input.compOption:checked');
            $.each(selectedInputs, function (idx, item) {
                var pNode = $(item).parent().children(".divPrice").children(".divPriceValue");
                //console.log("pNode count:" + pNode.length);
                if (pNode.length == 1) {
                    if ($(pNode[0]).text().match("%$")) {
                        ewRate = parseFloat($(pNode[0]).text());
                    }
                    else {
                        totalPrice += parseFloat($(pNode[0]).text());
                    }
                }
                var aNode = $(item).parent().children(".divATP").children(".divATPValue");
                if (aNode.length == 1) {
                    var cDate = new Date($(aNode).text()); var curMaxDate = maxDd; if ((cDate - curMaxDate) > 0) maxDd = cDate;
                }
            }
            );
            //console.log("ewRate:" + ewRate);
            totalPrice = totalPrice * (1+ewRate*0.01);
            $($(".totalPrice")[0]).text(totalPrice.toFixed(2)); $($(".maxDueDate")[0]).text(maxDd.format("yyyy/MM/dd"));
        }

        function showHideConfigResultDiv(o) {
            if ($(o).val() == "Hide") {
                $("#tbConfigResult").css("display", "none"); $("#tbConfigResult").css("right", "100px"); $("#tbConfigTable").css("display", "none"); $("#configResult").css("width", "30px"); $("#configResult").css("height", "1px"); $(o).val("Show");
            }
            else {
                $("#tbConfigResult").css("display", "block"); $("#tbConfigResult").css("right", "10px"); $("#tbConfigTable").css("display", "block"); $("#configResult").css("width", "300px"); $("#configResult").css("height", "350px"); $(o).val("Hide");
            }
        }

    </script>
    <input type="hidden" id="hdBTOId" />
    <input type="hidden" value="1" id="hdConfigQty" />
    <input type="hidden" value="0" id="hdIsOneLevel" />    
    <input type="hidden" value="1" id="hdIsForceChooseReqCat" />    
    <table width="100%">
        <tr>
            <td>
                <span style="width: 41%;" id="page_path" runat="server" />
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td align="left">
                            <a onclick="collapseExpandAll();" id="colExpAll" href="javascript:void(0);">Collapse
                                All</a>
                        </td>
                        <td>
                            <input type="button" value="Click to Continue" onclick="checkAndContinue();" class="continueBtn" /><br />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <table width="100%" id="tbConfigurator" style="border-style: ridge; height: 400px">
                    <tr>
                        <th>
                            Loading...
                        </th>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td align="center">
                <input type="button" value="Click to Continue" onclick="checkAndContinue();" class="continueBtn" />
            </td>
        </tr>
    </table>    
    <div id="configResult" style="display: block; background-color: #EBEBEB; width: 300px;
        height: 350px; position: fixed; bottom: 25%; right: 10px;">
        <input type="button" value="Hide" onclick="showHideConfigResultDiv(this);" class="continueBtn" />
        <table width="100%" style="display:block" id="tbConfigTable">            
            <tr>
                <td>
                    <table>
                        <tr>
                            <th align="left">
                                Total Price:
                            </th>
                            <td class="totalPriceCurrSign">
                            </td>
                            <td class="totalPrice">
                            </td>
                            <th align="left">
                                Max Due Date:
                            </th>
                            <td class="maxDueDate">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <input type="button" value="Click to Continue" onclick="checkAndContinue();" class="continueBtn" />
                </td>
            </tr>
            <tr>
                <td>
                    <div style="width: 99%; height: 300px; overflow-x: auto; overflow-y: scroll;" id="tbConfigResult">
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <div id="divReqCatNoComp" style="background-color: #EBEBEB; width: 30%; height: 100px;
        display: none; position: fixed; top:150px; right:15%; border-style:double; border-color:#FFA500">
        Category <b></b> is required but there is currently no available component.        
    </div>   
    <div id="reqCatDialog" style="background-color: #EBEBEB; width: 50%; height: 100px; border-style:double; border-color:#FFA500; display:none">
        <h3 style="color: Black">
            Please select one component of category:</h3>
        <p class="pcatname" style="color: Red; font-weight: bold">
        </p>
    </div>
    <div id="fakeDiv" style="display:none"></div>
</asp:Content>
