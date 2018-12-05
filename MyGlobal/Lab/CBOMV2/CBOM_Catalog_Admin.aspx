<%@ Page Title="MyAdvantech - CBOM Catalog Admin." Language="VB" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="false" CodeFile="CBOM_Catalog_Admin.aspx.vb" Inherits="Lab_CBOMV2_CBOM_Catalog_Admin" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/icon.css">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/demo.css">
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.easyui.min.js"></script>
    <link rel="stylesheet" href="../../Includes/js/token-input-facebook.css" type="text/css" />
    <script type="text/javascript" src="../../Includes/js/jquery.tokeninput.js"></script>
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
            width: 500px;
        }

            ul.token-input-list-facebook li input {
                border: 0;
                padding: 3px 8px;
                background-color: white;
                margin: 2px 0;
                -webkit-appearance: caret;
                width: 240px;
            }
    </style>

    <h2>CBOM Catalog Maintenance</h2>
    <asp:HiddenField runat="server" ID="hdOrgCatalogId" Value="" />
    <table width="100%">
        <tr valign="top">
            <td style="width: 30%">
                <ul id="CatalogTree" class="easyui-tree">
                </ul>
            </td>
            <td style="width: 70%" valign="top">
                <div id="divErrMsg" style="color:tomato; height:20px; font-weight:bold"></div>
                <div id="tabs" class="easyui-tabs" style="width: 600px; height: 250px; border:solid">
                    <div title="Edit Catalog" style="padding: 20px; display: block;">
                        <table style="width: 99%; background-color: #EBEBEB" id="tableEditCatalog">
                            <tr>
                                <th align="left" style="width: 15%">Catalog Name:</th>
                                <td>
                                    <input type="text" id="txtSelectedCatalogName" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <input type="button" value="update" id="btnUpdateCatalog" onclick="UpdateCatalog()" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div title="Add Sub-Catalog" data-options="" style="overflow: auto; padding: 20px; display: block;">
                        <table style="width: 99%; background-color: #EBEBEB" id="tableAddCatalog">
                            <tr>
                                <th align="left" style="width: 15%">Catalog Name:</th>
                                <td>
                                    <input type="text" id="txtNewCatalogName" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <input type="button" value="add" id="btnAddCatalog" onclick="AddCatalog()" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div title="Add BTOS Item" data-options="" style="display: block;">
                        <table style="width: 99%; background-color: #EBEBEB" id="tableAddBTO">
                            <tr>
                                <th align="left" style="width: 15%">BTOS Part No.:</th>
                                <td>
                                    <input type="text" id="txtBTOSPN" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <input type="button" value="add" id="btnAddBTOS" onclick="AddBTOS()" />
                                </td>
                            </tr>                        
                        </table>
                    </div>
                </div>                
            </td>
        </tr>
    </table>

    <div id="treeMenu" class="easyui-menu" style="width:120px;">		
		<div onclick="RemoveNode()" data-options="iconCls:'icon-remove'">Remove</div>
	</div>

    <script type="text/javascript">

        var selectedNode = null;

        $(document).ready(
            function () {
                $('#CatalogTree').tree(
                {
                    dnd: true,
                    onClick: function (node) {                        
                        selectedNode = node; $('#txtSelectedCatalogName').val(node.text);
                    },
                    onContextMenu: function(e,node){
                        e.preventDefault(); $(this).tree('select',node.target); $('#treeMenu').menu('show',{left: e.pageX, top: e.pageY});
                    },
                    onDrop: function (targetNode, source, point) {
                        var targetId = $('#CatalogTree').tree('getNode', targetNode).id;
                        var targetText = $('#CatalogTree').tree('getNode', targetNode).text;
                        console.log("source.id:" + source.text + ", targetId:" + targetText + ", point:" + point);

                        var data = {
                            id: source.id,
                            targetId: targetId,
                            point: point
                        }
                        var postData = JSON.stringify({ data: data });

                        $.ajax(
                            {
                                url: '<%=IO.Path.GetFileName(Request.PhysicalPath) %>/DropTreeNode', type: "POST",
                                contentType: "application/json; charset=utf-8", dataType: 'json', data: postData,
                                success: function (retData) {
                                    console.log("ok");
                                },
                                error: function (msg) {
                                    console.log("err:" + msg.d);
                                }
                            }
                        );
                    }
                }
                );

                $("#tableEditCatalog").keypress(function (event) {
                    if (event.keyCode == 13) {
                        event.preventDefault(); $("#btnUpdateCatalog").click();
                    }
                });

                $("#tableAddCatalog").keypress(function (event) {
                    if (event.keyCode == 13) {
                        event.preventDefault(); $("#btnAddCatalog").click();
                    }
                });

                $("#tableAddBTO").keypress(function (event) {
                    if (event.keyCode == 13) {
                        event.preventDefault(); $("#btnAddBTOS").click();
                    }
                });

                $('#tabs').tabs(
                    {
                        border: false,
                        onSelect: function (title) {
                        //alert(title + ' is selected');
                        }
                    }
                );

                $(window).scroll(function () {
                    $("#tabs").stop().animate({ "marginTop": ($(window).scrollTop()) }, 0);
                });

                //Load AEU's catalog, subject to change to dynamically load regional's data based on user's org
                $('#CatalogTree').tree(
                    {
                        url: '<%=IO.Path.GetFileName(Request.PhysicalPath) %>?RootId=' + $("#<%=hdOrgCatalogId.ClientID%>").val()    //ACN's catalog. AEU's is D78A390AD4
                    }
                );

                $("#txtBTOSPN").tokenInput("<%=IO.Path.GetFileName(Request.PhysicalPath) %>", {
                    theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type BTOS/CTOS PN", tokenLimit: 1, preventDuplicates: true
                });


            }
        );

        function UpdateCatalog() {
            $('#divErrMsg').empty();
            if (selectedNode) {                
                var postData = JSON.stringify({ NodeRowId: selectedNode.id, CatalogName: $('#txtSelectedCatalogName').val() });
                $.ajax(
                    {
                        url: '<%=IO.Path.GetFileName(Request.PhysicalPath) %>/UpdateCatalogName', type: "POST",
                        contentType: "application/json; charset=utf-8", dataType: 'json', data: postData,
                        success: function (retData) {
                            var ret = $.parseJSON(retData.d);
                            if (ret.IsUpdated) {
                                selectedNode.text = $('#txtSelectedCatalogName').val();
                                $('#CatalogTree').tree('update', selectedNode);
                            }
                            else {
                                $('#divErrMsg').text(ret.ServerMessage);
                            }
                        },
                        error: function (msg) {
                            console.log("err:" + msg.d);
                        }
                    }
                );

                
            }
            else { $('#divErrMsg').text('Please select a node first'); }
        }

        function AddCatalog() {
            $('#divErrMsg').empty();
            if (selectedNode) {
                var postData = JSON.stringify({ ParRowId: selectedNode.id, CatalogName: $('#txtNewCatalogName').val() });
                $.ajax(
                    {
                        url: '<%=IO.Path.GetFileName(Request.PhysicalPath) %>/AddSubCatalog', type: "POST",
                        contentType: "application/json; charset=utf-8", dataType: 'json', data: postData,
                        success: function (retData) {                            
                            var ret = $.parseJSON(retData.d);
                            //console.log(ret.IsUpdated);
                            if (ret.IsUpdated) {
                                var nodes = [
                                    {
                                        "id": ret.NewNodeRowId,
                                        "text": $('#txtNewCatalogName').val()
                                    }
                                ];
                                $('#CatalogTree').tree('append', {
                                    parent: selectedNode.target, data: nodes
                                });
                                $('#txtNewCatalogName').val('');
                            }
                        },
                        error: function (msg) {
                            console.log("err:" + msg.d);
                        }
                    }
                );
            }
            else { $('#divErrMsg').text('Please select a node first'); }
        }

        function AddBTOS() {
            //console.log($('#txtBTOSPN').val());
            $('#divErrMsg').empty();
            if (selectedNode) {
                var postData = JSON.stringify({ ParNodeId: selectedNode.id, BTOS: $('#txtBTOSPN').val() });
                $.ajax(
                    {
                        url: '<%=IO.Path.GetFileName(Request.PhysicalPath) %>/AddBTOS', type: "POST",
                        contentType: "application/json; charset=utf-8", dataType: 'json', data: postData,
                        success: function (retData) {                            
                            var ret = $.parseJSON(retData.d);
                            if (ret.IsUpdated) {
                                var nodes = [
                                    {
                                        "id": ret.NewNodeRowId,
                                        "text": $('#txtBTOSPN').val()
                                    }
                                ];
                                $('#CatalogTree').tree('append', {
                                    parent: selectedNode.target, data: nodes
                                });
                                $('#txtBTOSPN').tokenInput("clear");
                            }
                            else {
                                $('#divErrMsg').text(ret.ServerMessage);
                            }
                        },
                        error: function (msg) {
                            console.log("err:" + msg.d);
                        }
                    }
                );
            }
            else { $('#divErrMsg').text('Please select a node first'); }
        }

        function RemoveNode() {
            $('#divErrMsg').empty();
            var node = $('#CatalogTree').tree('getSelected');            
            var postData = JSON.stringify({ NodeId: node.id });
            $.ajax(
                {
                    url: '<%=IO.Path.GetFileName(Request.PhysicalPath) %>/DeleteNode', type: "POST",
                    contentType: "application/json; charset=utf-8", dataType: 'json', data: postData,
                    success: function (retData) {
                        var ret = $.parseJSON(retData.d);
                        //console.log(ret.IsUpdated);
                        if (ret.IsUpdated) {
                            $('#CatalogTree').tree('remove', node.target);
                        }
                    },
                    error: function (msg) {
                        console.log("err:" + msg.d);
                    }
                }
            );
        }

        function getParameterByName(name, url) {
            if (!url) url = window.location.href;
            name = name.replace(/[\[\]]/g, "\\$&");
            var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, " "));
        }

    </script>
</asp:Content>
