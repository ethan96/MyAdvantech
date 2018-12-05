<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SRP_Catalog_Category.aspx.cs" Inherits="Lab_CBOMV2_CBOM_Catalog_Category" MasterPageFile="~/Includes/MyMaster.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/default/easyui.css" />
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/icon.css" />
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/demo.css" />
    <link rel="stylesheet" href="../../Includes/js/token-input-facebook.css" type="text/css" />
    <link rel="stylesheet" href="../../Includes/FancyBox/jquery.fancybox.css" type="text/css" />
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="../../Includes/js/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <script type="text/javascript" src="../../Includes/LoadingOverlay/loadingoverlay.min.js"></script>
    <script type="text/javascript" src="../../Includes/LoadingOverlay/loadingoverlay_progress.min.js"></script>
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
            width: 400px;
            display: inline-block;
        }

            ul.token-input-list-facebook li input {
                border: 0;
                padding: 3px 8px;
                background-color: white;
                margin: 2px 0;
                -webkit-appearance: caret;
                width: 240px;
            }

        .tree-node-selected-category {
            background: #FFE4E1;
            color: #000000;
        }

        .Tree_Node_Root {
            background: url("/Includes/EasyUI/themes/default/images/root.png");
        }

        .Tree_Node_Category {
            background: url("/Includes/EasyUI/themes/default/images/tree_icons.png") no-repeat -208px 0;
        }

        .Tree_Node_Component {
            background: url("/Includes/EasyUI/themes/default/images/comp.png");
        }

        .Tree_Node_Shared_Category {
            background: url("/Includes/EasyUI/themes/default/images/cates.png");
        }

        .Tree_Node_Shared_Component {
            background: url("/Includes/EasyUI/themes/default/images/comps.png");
        }

        .input-field {
            width: 80%;
            height: 20px;
        }
    </style>

    <h2 id="h2title" runat="server"></h2>
    <a href="SRP_Catalog_Create.aspx">Catalog List   </a>
    <a id="ExpandAll" onclick="ExpandAll()" href="javascript:void(0);">Expand All   </a>
    <a id="CollapseAll" onclick="CollapseAll()" href="javascript:void(0);">Collapse All   </a>
    <asp:HiddenField runat="server" ID="hdOrgCatalogId" Value="" />
    <div id="diveditor" style="width: auto; height: auto">
        <table width="100%">
            <tr valign="top">
                <td style="width: 30%">
                    <ul id="CategoryTree" class="easyui-tree">
                    </ul>
                </td>
                <td style="width: 70%" valign="top">
                    <div id="divMsg" style="color: forestgreen; height: 20px; font-weight: bold; display: inline"></div>
                    <div id="divErrMsg" style="color: tomato; height: 20px; font-weight: bold; display: inline"></div>
                    <div id="tabs" class="easyui-tabs" style="width: 650px; height: 275px; border: solid">
                        <div title="Edit Selected Node" style="padding: 20px; display: block;">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableEditContent">
                                <tr>
                                    <th align="left" style="width: 15%">Display Name:</th>
                                    <td>
                                        <input type="text" id="txtSelectedNodeName" class="input-field" />
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeDesc">
                                    <th align="left" style="width: 15%">Display Desc:</th>
                                    <td>
                                        <input type="text" id="txtSelectedNodeDesc" class="input-field" />
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeQty">
                                    <th align="left" style="width: 15%">Qty:</th>
                                    <td>
                                        <input type="text" id="txtSelectedNodeQty" class="input-field" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="update" id="btnUpdateNode" onclick="UpdateSelectedNode()" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="AddCategory" title="Add Category" style="overflow: auto; padding: 20px; display: block;">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableAddCategory">
                                <tr>
                                    <th align="left" style="width: 20%">Category Name:</th>
                                    <td>
                                        <input type="text" id="txtNewCategoryName" class="input-field" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Part Desc:</th>
                                    <td>
                                        <input type="text" id="txtNewCategoryDesc" class="input-field" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="Add" id="btnAddCategory" onclick="AddCategory()" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="AddComponent" title="Add Component" data-options="" style="overflow: auto; padding: 20px; display: block;">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableAddComponent">
                                <tr id="trComponentPartName">
                                    <th align="left" style="width: 20%">Display Name:</th>
                                    <td>
                                        <input type="text" id="txtComponentPartName" class="input-field" />
                                    </td>
                                </tr>
                                <tr id="trComponentDisplayName">
                                    <th align="left" style="width: 20%">Display Name:</th>
                                    <td>
                                        <input type="text" id="txtComponentDisplayName" class="input-field" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Display Desc:</th>
                                    <td>
                                        <input type="text" id="txtComponentDesc" class="input-field" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="Add" id="btnAddComponent" onclick="AddComponent()" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <div id="treeMenu" class="easyui-menu" style="width: 120px;">
        <div onclick="RemoveNode()" data-options="iconCls:'icon-remove'">Remove</div>
    </div>

    <script type="text/javascript">

        var selectedNode = null;

        function ShowTree() {
            $('#CategoryTree').tree(
                {
                    dnd: false,
                    onClick: function (node) {
                        selectedNode = node;
                        console.log("ID:" + node.id + ", name:" + node.text + ", qty:" + node.qty + ", desc:" + node.desc + ", seq:" + node.seq + ", type:" + node.type);
                        DefaultSettings(selectedNode);
                    },
                    onBeforeLoad: function () {
                        $('#diveditor').LoadingOverlay("show");
                    },
                    onLoadSuccess: function () {
                        $('#diveditor').LoadingOverlay("hide", true);
                        if ($('#CategoryTree').tree('getRoot') == null) {
                            alert("root not found");
                            window.location = "<%=string.Format("{0}/Lab/CBOMV2/CBOM_Catalog_Create.aspx", Util.GetRuntimeSiteUrl())%>";
                        }

                        if (selectedNode) {
                            var node = $('#CategoryTree').tree('find', selectedNode.id);
                            if (node) {
                                $('#CategoryTree').tree('select', node.target);
                                $('#CategoryTree').tree('scrollTo', node.target);
                                DefaultSettings(selectedNode);
                            }
                        }
                        else {
                            $('#tabs').tabs('disableTab', 1);
                            $('#tabs').tabs('disableTab', 2);
                        }
                    },
                    onContextMenu: function (e, node) {
                        e.preventDefault();
                        $(this).tree('select', node.target);
                        if (node.type == 2)
                            $('#treeMenu').menu('show', { left: e.pageX, top: e.pageY });
                    },
                });

                $('#CategoryTree').tree(
                    {
                        url: '/Services/CBOMV2_Editor.asmx/InitializeTree?RootID=<%=rootid%>&ORG_ID=<%=orgid%>'
                    }
                );
            }

            $(document).ready(
                function () {
                    ShowTree();
                    $("#tableEditCategory").keypress(function (event) {
                        if (event.keyCode == 13) {
                            event.preventDefault(); $("#btnUpdateNode").click();
                        }
                    });

                    $("#tableAddCategory").keypress(function (event) {
                        if (event.keyCode == 13) {
                            event.preventDefault(); $("#btnAddCategory").click();
                        }
                    });

                    $("#tableAddComponent").keypress(function (event) {
                        if (event.keyCode == 13) {
                            event.preventDefault(); $("#btnAddComponent").click();
                        }
                    });

                    $('#tabs').tabs(
                        {
                            border: false,
                            onSelect: function (title) {
                            }
                        }
                    );

                    $(window).scroll(function () {
                        $("#tabs").stop().animate({ "marginTop": ($(window).scrollTop()) }, 0);
                    });

                    $("#txtComponentPartName").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputPartNo", {
                        theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type BTOS/CTOS PN", tokenLimit: 1, preventDuplicates: true, resizeInput: false,
                        onAdd: function (data) {
                            $("#txtComponentPartName").val(data.name);
                            $("#txtComponentDesc").val(data.id);
                        },
                        onDelete: function (data) {
                            $('#txtComponentDesc').val('');
                        }
                    });
                }
            );

            $(document).ajaxStart(function () {

            });
            $(document).ajaxStop(function () {
                $('#diveditor').LoadingOverlay("hide");
            })

            function DefaultSettings(selectedNode) {

                $('#txtSelectedNodeName').val(selectedNode.text);
                $('#txtSelectedNodeDesc').val(selectedNode.desc);
                $('#tabs').tabs("select", 0);
                $(".tree-node-selected-category").removeClass("tree-node-selected-category");
                // =======================================================================================
                // Default Settings, free all button and visibility
                $('#tabs').tabs('enableTab', 1);
                $('#tabs').tabs('enableTab', 2);
                $('#btnAddComponent').attr("disabled", false);
                $('#btnAddCategory').attr("disabled", false);
                $('#txtSelectedNodeName').attr("disabled", true);
                $('#trSelectedNodeDesc').show();
                $('#trComponentPartName').hide();
                $('#trComponentDisplayName').hide();

                // type 0 root, type 1 category, type 2 component, type 3 shared category, type 4 shared component
                if (selectedNode.type == 0) {
                    $('#txtSelectedNodeName').attr("disabled", false);
                    $('#tabs').tabs('disableTab', 2);
                    $('#trSelectedNodeDesc').hide();
                    $("#trSelectedNodeQty").hide();
                }
                else if (selectedNode.type == 1) {
                    $('#tabs').tabs('disableTab', 1);
                    $('#txtSelectedNodeName').attr("disabled", false);
                    $("#trSelectedNodeQty").hide();
                    if (selectedNode.text.startsWith("Option")) {
                        $('#trComponentPartName').show();
                    }
                    else {
                        $('#trComponentDisplayName').show();
                    }
                }
                else if (selectedNode.type == 2) {
                    $('#tabs').tabs('disableTab', 1);
                    $('#tabs').tabs('disableTab', 2);
                    $('#txtSelectedNodeName').attr("disabled", false);
                    $("#trSelectedNodeQty").show();
                    $("#txtSelectedNodeQty").val(selectedNode.qty);
                }
                // =======================================================================================
            }

            function UpdateSelectedNode() {
                $('#divMsg').empty();
                $('#divErrMsg').empty();
                if (selectedNode) {
                    $('#diveditor').LoadingOverlay("show");

                    var qty = "0";
                    if (selectedNode.type == 2)
                        qty = $("#txtSelectedNodeQty").val();

                    var postData = {
                        GUID: selectedNode.id,
                        CategoryID: $('#txtSelectedNodeName').val(),
                        Desc: $('#txtSelectedNodeDesc').val(),
                        Type: selectedNode.type,
                        Qty: qty,
                        isExpand: "0",
                        isRequired: "0",
                        isDefault: "0",
                        ConfigurationRule: ""
                    };
                    $.ajax(
                        {
                            url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/UpdateSelectedNode', type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Selected node successfully uploaded.");

                                        selectedNode.text = $('#txtSelectedNodeName').val();
                                        selectedNode.desc = $('#txtSelectedNodeDesc').val();

                                        //Ryan Showtree
                                        $('#CategoryTree').tree('reload');
                                    }
                                    else {
                                        $('#divErrMsg').text(retData.ServerMessage);
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

                function AddCategory() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();

                    if (selectedNode) {
                        var url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddCategory';

                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            ParentGUID: selectedNode.id,
                            CategoryID: $('#txtNewCategoryName').val(),
                            CategoryNote: $('#txtNewCategoryDesc').val(),
                            CategoryType: selectedNode.type,
                            CategoryQty: "1",
                            IsExpand: "0",
                            IsRequired: "0",
                            OrgID: "<%=orgid%>"
                        };
                        $.ajax(
                            {
                                url: url, type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Category successfully added.");
                                        // set tag contents back to default
                                        $('#txtNewCategoryName').val('');
                                        $('#txtNewCategoryDesc').val('');

                                        //Ryan Showtree
                                        $('#CategoryTree').tree('reload');
                                    }
                                    else {
                                        $('#divErrMsg').text(retData.ServerMessage);
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

                function AddComponent() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();

                    if (selectedNode) {
                        var url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddComponent';
                        var input_component = $('#txtComponentDisplayName').val();
                        if (selectedNode.text.startsWith("Option")) {
                            input_component = $('#txtComponentPartName').val();
                        }

                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            ParentGUID: selectedNode.id,
                            CategoryID: input_component,
                            CategoryNote: $('#txtComponentDesc').val(),
                            CategoryType: selectedNode.type,
                            IsExpand: "0",
                            IsDefault: "0",
                            OrgID: "<%=orgid%>",
                            ConfigurationRule: 0
                        };
                        $.ajax(
                            {
                                url: url, type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Component successfully added.");
                                        // set tag contents back to default
                                        $('#txtComponentDesc').val('');
                                        $('#txtComponentDisplayName').val('');
                                        $("#txtComponentPartName").tokenInput("clear");

                                        //Ryan Showtree
                                        $('#CategoryTree').tree('reload');
                                    }
                                    else {
                                        $('#divErrMsg').text(retData.ServerMessage);
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
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();

                    var node = $('#CategoryTree').tree('getSelected');

                    if (((node.children.length == 0) && node.type != 0) || (node.type == 3) || (node.type == 4)) {

                        $('#diveditor').LoadingOverlay("show");

                        var postData = { GUID: node.id, NodeType: node.type };
                        $.ajax(
                            {
                                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/DeleteNode', type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Node successfully deleted.");

                                        selectedNode = $('#CategoryTree').tree('getParent', selectedNode.target);
                                        //Ryan Showtree
                                        $('#CategoryTree').tree('reload');
                                    }
                                },
                                error: function (msg) {
                                    console.log("err:" + msg.d);
                                }
                            }
                            );
                    }
                    else {
                        $('#divErrMsg').text("This node can't be deleted.");
                    }
                }

                function ExpandAll() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();
                    $("#CategoryTree").tree('expandAll');
                }

                function CollapseAll() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();
                    $("#CategoryTree").tree('collapseAll');
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
