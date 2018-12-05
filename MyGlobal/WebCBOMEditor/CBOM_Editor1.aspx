<%@ Page Language="VB" AutoEventWireup="false" CodeFile="CBOM_Editor1.aspx.vb" Inherits="WebCBOMEditor_CBOMEditor_JQ" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
   
    <script type="text/javascript" src="../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../Includes/EasyUI/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="../Includes/EasyUI/Others/jquery.tokeninput.js"></script>
    <link rel="stylesheet" type="text/css" href="../Includes/EasyUI/Others/token-input-facebook.css" />
    <link rel="stylesheet" type="text/css" href="../Includes/EasyUI/demo.css" />
     <link rel="stylesheet" type="text/css" href="../Includes/EasyUI/themes/metro/easyui.css" />
    <link rel="stylesheet" type="text/css" href="../Includes/EasyUI/themes/icon.css" />
    <title></title>
    <style type="text/css">
        html, body
        {
            height: 90%;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <h2>
        CBOM Editor</h2>
    <div class="demo-info">
        <div class="demo-tip icon-tip">
        </div>
        <div>
            Right click on a node to show the menu.</div>
    </div>
    <div style="margin: 10px 0;">
    </div>
    <br />
    <br />
    <input type="radio" onclick="reloadtree('reg')" name="rbtnByReg" value="reg" checked="checked" />
    By Region
    <input type="radio" onclick="reloadtree('nreg')" name="rbtnByReg" value="nreg" />
    Not By Region
    <br />
    <br />
    <input type="hidden" id="hmod" value="" />
    <asp:HiddenField runat="server" ID="hBTO" />
    <asp:HiddenField runat="server" ID="hORG" />
    <div id="divP" style="overflow: scroll; overflow-x: hidden;">
        <ul id="tt" class="easyui-tree" data-options="
			loader:getTree,
			animate: true,
            lines: true,
			onContextMenu: function(e,node){
				e.preventDefault();
				$(this).tree('select',node.target);
				if (node.type.toUpperCase()=='ROOT'){$('#m3').hide();$('#m2').hide();$('#m4').hide();}
                else
                {$('#m3').show();$('#m2').show();$('#m4').show();};
                $('#mm').menu('show',{
					left: e.pageX,
					top: e.pageY
				});
			}
		">
        </ul>
        <div id="mm" class="easyui-menu" style="width: 120px">
            <div id="m1" onclick="Append()" data-options="iconCls:'icon-add'">
                Append</div>
            <div id="m2" onclick="edit()" data-options="iconCls:'icon-edit'">
                Edit</div>
            <div id="m4" class="menu-sep">
            </div>
            <div id="m3" onclick="removeit()" data-options="iconCls:'icon-remove'">
                Remove</div>
        </div>
        <div id="dlg2" class="easyui-dialog" data-options="modal:true" title=" " style="padding: 5px;
            width: 650px; height: 220px" closed="true">
            <asp:Panel ID="pa1" runat="server" DefaultButton="btnConfirm">
                <table>
                    <tr id="trCopy">
                        <td>
                            Copy From :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtCategoryCopy" Width="400px" ReadOnly="true" BackColor="#eeeeee"></asp:TextBox>
                        </td>
                        <td>
                            <input type="button" id="p3" onclick="$('#htype').val('CATEGORY');$('#hpickCopy').val('1');$('#dlg').dialog('open');$('#dg').datagrid()"
                                value="Pick Category" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Category Name <font color="red">*</font>:
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtCategory" Width="400px"></asp:TextBox>
                        </td>
                        <td>
                            <input type="button" id="p1" onclick="$('#htype').val('CATEGORY');$('#hpickCopy').val('0');$('#dlg').dialog('open');$('#dg').datagrid()"
                                value="Pick Category" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Description :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtDesc" Width="400px"></asp:TextBox>
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Seq :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtSeq" Width="50px" Text="1"></asp:TextBox>
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="f1" TargetControlID="txtSeq"
                                FilterType="Numbers, Custom" ValidChars="^[1-9]\d*$" />
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Configuration Type :
                        </td>
                        <td>
                            <input type="radio" name="rbtnReq" value="REQUIRED" />
                            Required
                            <input type="radio" name="rbtnReq" value="" checked="checked" />
                            Not Required
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Created By :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtCreatedBy" Width="200px"></asp:TextBox>
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
                <div style="text-align: center">
                    <asp:Button runat="server" ID="btnConfirm" Text="Confirm" OnClientClick="confirmca();return false;" /></div>
            </asp:Panel>
        </div>
        <div id="dlg3" class="easyui-dialog" data-options="modal:true" title=" " style="padding: 5px;
            width: 650px; height: 270px" closed="true">
            <asp:Panel ID="pa2" runat="server" DefaultButton="Button2">
                <table>
                    <tr>
                        <td>
                            Component Name<font color="red">*</font> :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtComp"></asp:TextBox>
                        </td>
                        <td>
                            <input type="button" id="p2" onclick="$('#htype').val('COMPONENT');$('#dlg').dialog('open');$('#dg').datagrid()"
                                value="Pick Component" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Description :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtDescComp" Width="400px"></asp:TextBox>
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Seq :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtSeqComp" Width="50px" Text="1"></asp:TextBox>
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft2" TargetControlID="txtSeqComp"
                                FilterType="Numbers, Custom" ValidChars="^[1-9]\d*$" />
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Configuration Type :
                        </td>
                        <td>
                            <input type="radio" name="rbtnDefault" value="DEFAULT" />
                            Default
                            <input type="radio" name="rbtnDefault" value="" checked="checked" />
                            Not Default
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Show Hide :
                        </td>
                        <td>
                            <input type="radio" name="rbtnShowHide" value="1" checked="checked" />
                            Show
                            <input type="radio" name="rbtnShowHide" value="0" />
                            Hide
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Not Expand :
                        </td>
                        <td>
                            <asp:RadioButtonList runat="server" ID="rbtnExpand" RepeatDirection="Horizontal">
                                <asp:ListItem Value="1" Selected="True">Expand</asp:ListItem>
                                <asp:ListItem Value="0">Not Expand</asp:ListItem>
                            </asp:RadioButtonList>
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Created By :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtCbyComp" Width="200px"></asp:TextBox>
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
                <div style="text-align: center">
                    <asp:Button runat="server" ID="Button2" Text="Confirm" OnClientClick="confirmco();return false;" /></div>
            </asp:Panel>
        </div>
        <div id="dlg" class="easyui-dialog" title="Pick Product" data-options="modal:true"
            style="padding: 5px; width: 624px; height: 425px" closed="true">
            <asp:Panel ID="pa3" runat="server" DefaultButton="Button1">
                <input type="hidden" id="htype" value="" />
                <input type="hidden" id="hpickCopy" value="" />
                <table>
                    <tr>
                        <td>
                            <b>Search :</b>
                        </td>
                        <td>
                            <input type="text" id="iptsh" />
                        </td>
                        <td>
                            <asp:Button runat="server" ID="Button1" Text="Go" OnClientClick="sh();return false;" />
        </div>
        </td> </tr> </table>
        <table id="dg" title=" " style="width: 600px; height: 340px" data-options="
                loader:myLoader,
				singleSelect:true,
				autoRowHeight:false,
				pagination:true,
				pageSize:10">
            <thead>
                <tr>
                    <th field="rowno" width="60">
                        Row No
                    </th>
                    <th field="pick" width="59">
                        Pick
                    </th>
                    <th field="partno" width="170">
                        Part No
                    </th>
                    <th field="desc" width="305">
                        Description
                    </th>
                </tr>
            </thead>
        </table>
        </asp:Panel>
    </div>
    </div>
    </form>
    <script type="text/javascript">
        function autoHeight() {
            var h = $(window).height();
            var h_old = 200;
            if (h > h_old) {
                $('#divP').css('height', h * 0.75);
            } else {
                return false;
            }
        }

        $(function () {

            var t1 = $("#<%=Me.txtComp.ClientID %>")

            t1.tokenInput("<%=IO.Path.GetFileName(Request.PhysicalPath)%>?T=COMPONENT&ORG=" + $("#<%=Me.hORG.ClientID %>").val(), {
                theme: "facebook", zindex: "999999999", searchDelay: 350, minChars: 2, tokenDelimiter: ";", hintText: "Type Component ..."
            });

            autoHeight();
            $(window).resize(autoHeight);
        });



        function reloadtree(r) {
            if (r == 'reg') {

                var t = $('#tt');
                t.tree('reload');
            }
            else {

                var t = $('#tt');
                t.tree('reload');
            }

        }
        function setPick(pn, desc) {
            if ($('#htype').val() == "CATEGORY") {
                if ($('#hpickCopy').val() == '1') {
                    $("#<%=Me.txtCategoryCopy.ClientID %>").val(pn);
                }
                else {
                    $("#<%=Me.txtCategory.ClientID %>").val(pn);

                }
                $("#<%=Me.txtDesc.ClientID %>").val(desc);
            }
            else {
                var t1 = $("#<%=Me.txtComp.ClientID %>")
                t1.tokenInput("add", { id: 1, name: pn });
                t1.val(desc);
            }
            $('#dlg').dialog("close");
        }
        function sh() {
            $('#dg').datagrid({ queryParams: { t: $('#htype').val()} });
        }
        function myLoader(param, success, e) {
            var op = $(this).datagrid('options');
            $.ajax({
                data: JSON.stringify({ rowCount: op.pageSize, pageNum: op.pageNumber, org: $("#<%=Me.hORG.ClientID %>").val(), pn: $('#iptsh').val(), type: $('#htype').val() }),
                type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetProd", contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (data) {
                    var obj = $.parseJSON(data.d);
                    success(obj);
                },
                error: function (msg) {
                    error = msg;
                    alert(msg.responseText);
                }
            });
        }

        function getTree(param, success, e) {

            $.ajax({
                data: JSON.stringify({ id: (param.id ? param.id : $("#<%=Me.hBTO.ClientID %>").val()), isRoot: (param.id ? "N" : "Y"), ORG: $("#<%=Me.hORG.ClientID %>").val(), byreg: $("input[name='rbtnByReg']:checked").val() }),
                type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetTree", contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (data) {
                    var obj = $.parseJSON(data.d);
                    success(obj);
                },
                error: function (msg) {
                    error = msg;
                    alert(msg.responseText);
                }
            });
        }




        function confirmca() {
            $('#btnConfirm').attr("disabled", "true");
            var t = $('#tt');
            var node = t.tree('getSelected');
            if ($('#hmod').val() == "A") {
                var UID = "";
                var id = $("#<%=Me.txtCategory.ClientID %>").val();
                if (id == '') { alert("Please input category id first."); $('#btnConfirm').removeAttr("disabled"); return; }
                var pid = node.id;
                var rid = $("#<%=Me.hBTO.ClientID %>").val()
                var desc = $("#<%=Me.txtDesc.ClientID %>").val();
                var cBy = $("#<%=Me.txtCreatedBy.ClientID %>").val();
                var seq = $("#<%=Me.txtSeq.ClientID %>").val();
                var req = $("input[name='rbtnReq']:checked").val();
                var org = $("#<%=Me.hORG.ClientID %>").val()
                var copyFrom = $("#<%=Me.txtCategoryCopy.ClientID %>").val()
                $("#<%=Me.txtCategoryCopy.ClientID %>").val('')
                $.ajax({
                    data: JSON.stringify({ UID: UID, id: id, pid: pid, rid: rid, desc: desc, cBy: cBy, seq: seq, req: req, org: org, copyFrom: copyFrom }),
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/addCate", contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (data) {
                        if (data.d != "") {
                            t.tree("reload", node.target);
                            if (data.d != "OK") { alert(data.d); }
                        };
                        $('#btnConfirm').removeAttr("disabled");
                    },
                    error: function (msg) {
                        error = msg;
                        alert(msg.responseText);
                        $('#btnConfirm').removeAttr("disabled");
                    }
                });
            }
            else if ($('#hmod').val() == "E") {
                var UID = node.UID;
                var id = node.id;
                if (id == '') { alert("Please input category id first."); $('#btnConfirm').removeAttr("disabled"); return; }
                var desc = $("#<%=Me.txtDesc.ClientID %>").val();
                var cBy = $("#<%=Me.txtCreatedBy.ClientID %>").val();
                var seq = $("#<%=Me.txtSeq.ClientID %>").val();
                var req = $("input[name='rbtnReq']:checked").val();
                var org = $("#<%=Me.hORG.ClientID %>").val()
                $.ajax({
                    data: JSON.stringify({ UID: UID, id: id, desc: desc, cBy: cBy, seq: seq, req: req, org: org }),
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/editCate", contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (data) {
                        if (data.d == "OK") {
                            o = t.tree('getParent', node.target);
                            t.tree("reload", o.target);
                            $('#btnConfirm').removeAttr("disabled");
                            $('#dlg2').dialog("close");
                        };
                    },
                    error: function (msg) {
                        error = msg;
                        alert(msg.responseText);
                        $('#btnConfirm').removeAttr("disabled");
                        $('#dlg2').dialog("close");
                    }
                });
            }


        }

        function getCombId(t) {

            var v = t.tokenInput("get");
            var r = "";

            for (var i = 0; i < v.length; i++) {
                var sp = ""
                if (i > 0) sp = "|";
                r = r + sp + v[i].name;
            }
            return r
        }

        function confirmco() {
            $('#Button2').attr("disabled", "true");
            var t = $('#tt');
            var node = t.tree('getSelected');
            if ($('#hmod').val() == "A") {
                var UID = "";

                var id = getCombId($("#<%=Me.txtComp.ClientID %>"))
                var pid = node.id;
                if (id == '' || pid == '') { alert("Category id or parent category id is invalid."); $('#Button2').removeAttr("disabled"); return; }
                var rid = $("#<%=Me.hBTO.ClientID %>").val()
                var desc = $("#<%=Me.txtDescComp.ClientID %>").val();
                var cBy = $("#<%=Me.txtCbyComp.ClientID %>").val();
                var seq = $("#<%=Me.txtSeqComp.ClientID %>").val();
                var req = $("input[name='rbtnDefault']:checked").val();
                var sh = $("input[name='rbtnShowHide']:checked").val();
                var def = $("input[name='rbtnExpand']:checked").val();
                var org = $("#<%=Me.hORG.ClientID %>").val()
                $.ajax({
                    data: JSON.stringify({ UID: UID, id: id, pid: pid, rid: rid, desc: desc, cBy: cBy, seq: seq, req: req, sh: sh, def: def, org: org }),
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/addComp", contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (data) {
                        if (data.d == "OK") {
                            t.tree("reload", node.target);
                        };
                        $('#Button2').removeAttr("disabled");
                    },
                    error: function (msg) {
                        error = msg;
                        alert(msg.responseText);
                        $('#Button2').removeAttr("disabled");
                    }
                });
            }
            else if ($('#hmod').val() == "E") {
                var UID = node.UID;
                var id = node.id;
                if (id == '') { alert("Category id is invalid."); $('#Button2').removeAttr("disabled"); return; };
                var desc = $("#<%=Me.txtDescComp.ClientID %>").val();
                var cBy = $("#<%=Me.txtCbyComp.ClientID %>").val();
                var seq = $("#<%=Me.txtSeqComp.ClientID %>").val();
                var req = $("input[name='rbtnDefault']:checked").val();
                var sh = $("input[name='rbtnShowHide']:checked").val();
                var def = $("input[name='rbtnExpand']:checked").val();
                var org = $("#<%=Me.hORG.ClientID %>").val()
                $.ajax({
                    data: JSON.stringify({ UID: UID, id: id, desc: desc, cBy: cBy, seq: seq, req: req, sh: sh, def: def, org: org }),
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/editComp", contentType: "application/json; charset=utf-8", dataType: "json",
                    success: function (data) {
                        if (data.d == "OK") {
                            o = t.tree('getParent', node.target);
                            t.tree("reload", o.target);
                        };
                        $('#Button2').removeAttr("disabled");
                        $('#dlg3').dialog("close");
                    },
                    error: function (msg) {
                        error = msg;
                        alert(msg.responseText);
                        $('#Button2').removeAttr("disabled");
                        $('#dlg3').dialog("close");
                    }
                });
            }

        }
        function removeit() {
            var t = $('#tt');
            var node = t.tree('getSelected');
            var UID = node.UID;
            var id = node.id;
            if (node.id == $("#<%=Me.hBTO.ClientID %>").val()) { alert('Root item cannot be deleted.'); return false; };
            $.ajax({
                data: JSON.stringify({ UID: UID, id: id }),
                type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/remove", contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (data) {
                    if (data.d == "OK") {
                        o = t.tree('getParent', node.target);
                        t.tree("reload", o.target);
                    };
                },
                error: function (msg) {
                    error = msg;
                    alert(msg.responseText);
                }
            });
        }
        function Append() {
            $('#hmod').val("A");
            $("#p1").show();
            $("#p2").show();
            $("#<%=Me.txtCategoryCopy.ClientID %>").val('')
            $('#trCopy').show();

            var t1 = $("#<%=Me.txtCategory.ClientID %>");
            t1.val("")
            t1.removeAttr("readonly");
            t1.css("background-color", "#ffffff");
            var t2 = $("#<%=Me.txtComp.ClientID %>");
            t2.tokenInput("remove");
            var t = $('#tt');
            var node = t.tree('getSelected');
            var tt
            if (node.type.toUpperCase() == "CATEGORY") {
                tt = $('#dlg3');
            }
            else {
                tt = $('#dlg2');
            }
            tt.panel({ title: "Append" });
            tt.dialog('open');
        }
        function edit() {
            $('#hmod').val("E");
            var t = $('#tt');
            var node = t.tree('getSelected');
            var tt
            if (node.type.toUpperCase() == "CATEGORY") {
                var t1 = $("#<%=Me.txtCategory.ClientID %>");
                t1.val(node.id);
                t1.attr("readonly", "readonly");
                t1.css("background-color", "#eeeeee");
                $("#<%=Me.txtDesc.ClientID %>").val(node.desc);
                $("#<%=Me.txtSeq.ClientID %>").val(node.seq);
                $("#<%=Me.txtCreatedBy.ClientID %>").val(node.cby);
                $("input[name='rbtnReq']").val([node.isReq]);

                tt = $('#dlg2');
            }
            else {
                tt = $('#dlg3');
                var t1 = $("#<%=Me.txtComp.ClientID %>");
                t1.tokenInput("remove");
                t1.tokenInput("add", { id: 1, name: node.id });
                $("#<%=Me.txtDescComp.ClientID %>").val(node.desc);
                $("#<%=Me.txtSeqComp.ClientID %>").val(node.seq);
                $("#<%=Me.txtCbyComp.ClientID %>").val(node.cby);
                $("input[name='rbtnDefault']").val([node.isReq]);
                $("input[name='rbtnShowHide']").val([node.showhide]);
                $("input[name='rbtnExpand']").val([(node.notexpand = '' ? 0 : 1)]);
                tt = $('#dlg3');
            }
            $("#p1").hide();
            $("#p2").hide();
            $("#<%=Me.txtCategoryCopy.ClientID %>").val('')
            $('#trCopy').hide()
            tt.panel({ title: "Edit" });
            tt.dialog('open');
        }
    </script>
</body>
</html>