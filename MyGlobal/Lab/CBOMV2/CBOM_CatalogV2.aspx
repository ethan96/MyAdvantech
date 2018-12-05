<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="CBOM_CatalogV2.aspx.cs" Inherits="Lab_CBOM_CatalogV2" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/default/easyui.css">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/themes/icon.css">
    <link rel="stylesheet" type="text/css" href="../../Includes/EasyUI/demo.css">
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.easyui.min.js"></script>
    <link rel="stylesheet" href="../../Includes/js/token-input-facebook.css" type="text/css" />
    <link rel="Stylesheet" href="../../Includes/FancyBox/jquery.fancybox.css" type="text/css" />
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
            display: inline-flex;
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

        .input-field {
            width: 80%;
            height: 20px;
        }
    </style>


    <h2 id="h2title" runat="server"></h2>
    <a id="ExpandAll" onclick="ExpandAll()" href="javascript:void(0);">Expand All   </a>
    <a id="CollapseAll" onclick="CollapseAll()" href="javascript:void(0);">Collapse All   </a>
    <asp:HiddenField runat="server" ID="hdOrgCatalogId" Value="" />
    <div id="diveditor" style="width: auto; height: auto">
        <table width="100%">
            <tr valign="top">
                <td style="width: 30%">
                    <ul id="CatalogTree" class="easyui-tree">
                    </ul>
                </td>
                <td style="width: 70%" valign="top">
                    <div id="divMsg" style="color: forestgreen; height: 20px; font-weight: bold; display: inline"></div>
                    <div id="divErrMsg" style="color: tomato; height: 20px; font-weight: bold; display: inline"></div>
                    <div id="tabs" class="easyui-tabs" style="width: 650px; height: 300px; border: solid">
                        <div title="Edit Selected Node" style="padding: 20px; display: block;">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableEditContent">
                                <tr>
                                    <th align="left" style="width: 15%">Name:</th>
                                    <td>
                                        <input type="text" id="txtSelectedNodeName" class="input-field" style="width: 85%" />
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeDesc">
                                    <th align="left" style="width: 15%">Desc:</th>
                                    <td>
                                        <textarea id="txtSelectedNodeDesc" cols="" rows="5" style="width: 85%"></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="update" id="btnUpdateNode" onclick="UpdateSelectedNode()" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="AddCategory" title="Add Category" data-options="" style="overflow: auto; padding: 20px; display: block;">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableAddCategory">
                                <tr>
                                    <th align="left" style="width: 20%">Category Name:</th>
                                    <td>
                                        <input type="text" id="txtNewCategoryName" class="input-field" style="width: 85%" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Part Desc:</th>
                                    <td>
                                        <textarea id="txtNewCategoryDesc" cols="" rows="5" style="width: 85%"></textarea>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="Add" id="btnAddCategory" onclick="AddCategory()" data-type='<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddNewCategory %>' />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="AddComponent" title="Add Component" data-options="" style="overflow: auto; padding: 20px; display: block;">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableAddComponent">
                                <tr>
                                    <th align="left" style="width: 20%">Part No.:</th>
                                    <td>
                                        <input type="text" id="txtComponentName" class="input-field" style="width: 85%" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Part Desc:</th>
                                    <td>
                                        <textarea id="txtComponentDesc" cols="" rows="5" style="width: 85%"></textarea>
                                    </td>
                                </tr>
                                <tr style="display:none">
                                    <td>
                                        <input type="text" id="txtCategoryGUID" class="input-field" style="width: 85%" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="Add" id="btnAddComponent" onclick="AddComponent()" data-type='<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddNewComponent %>' />
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
        <div onclick="ReOrderByAlphabetical()" data-options="iconCls:'icon-remove'">Reorder</div>
        <div onclick="RemoveNode()" data-options="iconCls:'icon-remove'">Remove</div>
    </div>

    <script type="text/javascript">

        var selectedNode = null;

        function ShowTree() {
            $('#CatalogTree').tree(
                {
                    dnd: true,
                    onClick: function (node) {
                        selectedNode = node;
                        console.log("ID:" + node.id + ", name:" + node.text + ", qty:" + node.qty + ", desc:" + node.desc + ", seq:" + node.seq + ", type:" + node.type);
                        console.log("VirtualID:" + node.virtualid);
                        DefaultSettings(selectedNode);
                    },
                    onBeforeLoad: function () {
                        $('#diveditor').LoadingOverlay("show");
                    },
                    onLoadSuccess: function () {
                        $('#diveditor').LoadingOverlay("hide", true);
                        if ($('#CatalogTree').tree('getRoot') == null) {
                            alert("root not found");
                        }

                        if (selectedNode) {
                            var node = $('#CatalogTree').tree('find', selectedNode.id);
                            if (node) {
                                $('#CatalogTree').tree('select', node.target);
                                $('#CatalogTree').tree('scrollTo', node.target);
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
                        $('#CatalogTree').tree('select', node.target);
                        selectedNode = node;
                        $('#treeMenu').menu('show', { left: e.pageX, top: e.pageY });
                    },
                    onBeforeDrag: function (node) {
                        // root is not allow to drag.
                        if (node.type == 0)
                            return false;
                    },
                    onBeforeDrop: function (targetNode, source, point) {
                        $('#divMsg').empty();
                        $('#divErrMsg').empty();
                        var target = $('#CatalogTree').tree('getNode', targetNode);
                        if (target.parentid != source.parentid) {
                            $('#divErrMsg').text("Not allow to moving cross levels.");
                            return false;
                        }
                        else {
                            if (point == "append") {
                                $('#divErrMsg').text("Not allow to append under brothers.");
                                return false;
                            }

                            if (target.seq == source.seq) {
                                $('#divErrMsg').text("Invalid operation - moving to current location.");
                                return false;
                            }
                        }
                    },
                    onDrop: function (targetNode, source, point) {
                        var targetid = $('#CatalogTree').tree('getNode', targetNode).id;
                        var targetseq = $('#CatalogTree').tree('getNode', targetNode).seq;
                        var targetText = $('#CatalogTree').tree('getNode', targetNode).text;
                        console.log("parentid:" + source.parentid + ", currentid:" + source.id + ", currentseq:" + source.seq + ", targetid:" + targetid + ", target seq:" + targetseq + ", point:" + point);

                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            parentid: source.parentid,
                            currentid: source.id,
                            currentseq: source.seq,
                            targetid: targetid,
                            targetseq: targetseq,
                            point: point
                        };
                        $.ajax(
                            {
                                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_CatalogEditor.asmx/DropTreeNode', type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {

                                    if (retData.IsUpdated) {
                                        ShowTree();
                                    }
                                    else {
                                        $('#divErrMsg').text(retData.ServerMessage);
                                        return false;
                                    }
                                },
                                error: function (msg) {
                                    console.log("err:" + msg.d);
                                    return false;
                                }
                            });
                    }
                });

                $('#CatalogTree').tree(
                    {
                        url: '/Services/CBOMV2_CatalogEditor.asmx/InitializeTree?ORG_ID=<%=orgid%>'
                    }
                );
            }

            $(document).ready(
                function () {
                    ShowTree();
                    $('#tabs').tabs(
                        {
                            border: false,
                        }
                    );

                    $(window).scroll(function () {
                        $("#tabs").stop().animate({ "marginTop": ($(window).scrollTop()) }, 0);
                    });

                    $("#txtComponentName").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputCBOMBTOS", {
                        theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type BTOS/CTOS PN", tokenLimit: 1, preventDuplicates: true, resizeInput: false,resultsLimit: 7,
                        onAdd: function (data) {
                            $("#txtComponentName").val(data.name);
                            $("#txtComponentDesc").val(data.cpn);
                            $("#txtCategoryGUID").val(data.id);
                        },
                        onDelete: function (data) {
                            $('#txtComponentDesc').val("");
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
                    $('#txtSelectedNodeQty').val(selectedNode.qty);
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

                    // type 0 root, type 1 category, type 2 component, type 3 shared category, type 4 shared component
                    if (selectedNode.type == 0) {
                        $('#txtSelectedNodeName').attr("disabled", false);
                        $('#tabs').tabs('disableTab', 2);
                        $('#trSelectedNodeDesc').hide();
                    }
                    else if (selectedNode.type == 1) {
                        $('#tabs').tabs('disableTab', 1);
                        $('#txtSelectedNodeName').attr("disabled", false);
                    }
                    else if (selectedNode.type == 2) {
                        $('#tabs').tabs('disableTab', 1);
                        $('#tabs').tabs('disableTab', 2);
                    }
                    // =======================================================================================
                }

                function UpdateSelectedNode() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();
                    if (selectedNode) {
                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            GUID: selectedNode.id,
                            CategoryID: $('#txtSelectedNodeName').val(),
                            Desc: $('#txtSelectedNodeDesc').val()
                        };
                        $.ajax(
                            {
                                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_CatalogEditor.asmx/UpdateSelectedNode', type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Selected node successfully uploaded.");

                                        selectedNode.text = $('#txtSelectedNodeName').val();
                                        selectedNode.desc = $('#txtSelectedNodeDesc').val();
                                        selectedNode.qty = $('#txtSelectedNodeQty').val();
                                        selectedNode.isDefault = $("input:radio[name='isSelectedDefault']:checked").val();
                                        selectedNode.isrequired = $("input:radio[name='isSelectedRequired']:checked").val();
                                        selectedNode.isexpand = $("input:radio[name='isSelectedExpand']:checked").val();

                                        //Ryan Showtree
                                        $('#CatalogTree').tree('reload');
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
                        var url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_CatalogEditor.asmx/AddCategory';
                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            ParentGUID: selectedNode.id,
                            CategoryID: $('#txtNewCategoryName').val(),
                            CategoryNote: $('#txtNewCategoryDesc').val(),
                            OrgID: "<%=orgid%>",
                            UserID: "<%=userid%>"
                        };
                        $.ajax(
                            {
                                url: url, type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Category successfully added.");

                                        $('#txtNewCategoryName').val("");
                                        $('#txtNewCategoryDesc').val("");

                                        //Ryan Showtree
                                        $('#CatalogTree').tree('reload');
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
                        var url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_CatalogEditor.asmx/AddComponent';
                        var guid = "";
                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            ParentGUID: selectedNode.id,
                            CategoryID: $('#txtComponentName').val(),
                            CategoryNote: $('#txtComponentDesc').val(),
                            OrgID: "<%=orgid%>",
                            UserID: "<%=userid%>",
                            CategoryGUID: $('#txtCategoryGUID').val()
                        };
                        $.ajax(
                            {
                                url: url, type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Component successfully added.");

                                        $("#txtComponentName").tokenInput("clear");
                                        $('#txtComponentDesc').val("");

                                        //Ryan Showtree
                                        $('#CatalogTree').tree('reload');
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

                    if (selectedNode) {
                        if (((selectedNode.children.length == 0) && selectedNode.type != 0) || (selectedNode.type == 3) || (selectedNode.type == 4)) {
                            $('#diveditor').LoadingOverlay("show");

                            var postData = { GUID: selectedNode.id, NodeType: selectedNode.type };
                            $.ajax(
                                {
                                    url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_CatalogEditor.asmx/DeleteNode', type: "POST",
                                    dataType: 'json', data: postData,
                                    success: function (retData) {
                                        if (retData.IsUpdated) {
                                            // Reorder by seq to fill seq gap.
                                            ReOrderBySeq();

                                            $('#divMsg').text("Node successfully deleted.");

                                            selectedNode = $('#CatalogTree').tree('getParent', selectedNode.target);
                                            //Ryan Showtree
                                            $('#CatalogTree').tree('reload');
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
                    }

                    function ExpandAll() {
                        $('#divMsg').empty();
                        $('#divErrMsg').empty();
                        $("#CatalogTree").tree('expandAll');
                    }

                    function CollapseAll() {
                        $('#divMsg').empty();
                        $('#divErrMsg').empty();
                        $("#CatalogTree").tree('collapseAll');
                    }

                    function ReOrderByAlphabetical() {
                        $('#divMsg').empty();
                        $('#divErrMsg').empty();

                        if (selectedNode) {
                            if (selectedNode.children.length > 1) {
                                $('#diveditor').LoadingOverlay("show");

                                var postData = { GUID: selectedNode.id };
                                $.ajax({
                                    url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_CatalogEditor.asmx/ReOrderByAlphabetical', type: "POST",
                                    dataType: 'json', data: postData,
                                    success: function (retData) {
                                        if (retData.IsUpdated) {
                                            $('#divMsg').text("Sequence successfully reordered by alphabetical.");

                                            selectedNode = $('#CatalogTree').tree('getParent', selectedNode.target);
                                            //Ryan Showtree
                                            $('#CatalogTree').tree('reload');
                                        }
                                    },
                                    error: function (msg) {
                                        console.log("err:" + msg.d);
                                    }
                                });
                            }
                            else {
                                $('#divErrMsg').text("No children are needed to be reordered under this node.");
                            }
                        }
                    }

                    function ReOrderBySeq() {
                        if (selectedNode) {
                            var parentnode = $('#CatalogTree').tree('getParent', selectedNode.target);

                            var postData = {
                                ParentGUID: parentnode.id,
                                ParentNodeType: parentnode.type
                            };
                            $.ajax({
                                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_CatalogEditor.asmx/ReOrderBySeq', type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        console.log("Reorder by seq.");
                                    }
                                },
                                error: function (msg) {
                                    console.log("err:" + msg.d);
                                }
                            });
                        }
                    }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

