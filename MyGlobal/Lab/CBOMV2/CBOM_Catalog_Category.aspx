<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CBOM_Catalog_Category.aspx.cs" Inherits="Lab_CBOMV2_CBOM_Catalog_Category" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Src="~/Includes/CBOM/CBOM_SharedCategory.ascx" TagName="SharedCategory" TagPrefix="CBOM" %>
<%@ Register Src="~/Includes/CBOM/CBOM_SharedComponent.ascx" TagName="SharedComponent" TagPrefix="CBOM" %>

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
    <a href="CBOM_Catalog_Create.aspx">Catalog List   </a>
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
                    <div id="tabs" class="easyui-tabs" style="width: 650px; height: 300px; border: solid">
                        <div title="Edit Selected Node" style="padding: 20px; display: block;">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableEditContent">
                                <tr>
                                    <th align="left" style="width: 15%">Name:</th>
                                    <td>
                                        <input type="text" id="txtSelectedNodeName" class="input-field" />
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeDesc">
                                    <th align="left" style="width: 15%">Desc:</th>
                                    <td>
                                        <input type="text" id="txtSelectedNodeDesc" class="input-field" />
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeQty">
                                    <th align="left" style="width: 15%">Qty:</th>
                                    <td>
                                        <input type="text" id="txtSelectedNodeQty" style="width: 5%; height: 20px; text-align: right;" />
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeExpand" style="height: 20px;">
                                    <th>Is Expand?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isSelectedExpand" value="1" />Yes
                                    <input type="radio" name="isSelectedExpand" value="0" />No
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeRequired" style="height: 20px;">
                                    <th>Is Required?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isSelectedRequired" value="1" />Yes
                                        <input type="radio" name="isSelectedRequired" value="0" />No
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeDefault" style="height: 20px;">
                                    <th>Is Default?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isSelectedDefault" value="1" />Yes
                                        <input type="radio" name="isSelectedDefault" value="0" />No
                                    </td>
                                </tr>
                                <tr id="trSelectedNodeLooseItem" style="height: 20px;">
                                    <th>Is Loose Item?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isSelectedNodeLooseItem" value="1" />Yes
                                        <input type="radio" name="isSelectedNodeLooseItem" value="0" />No
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
                                    <th>Is Shared Category?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isCategoryShared" value="1" />Yes
                                    <input type="radio" name="isCategoryShared" value="0" checked="checked" />No
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Category Name:</th>
                                    <td>
                                        <input type="text" id="txtNewCategoryName" class="input-field" />
                                        <input type="button" value="Pick" id="btnPickCategory" onclick="PickCategory()" style="display: none;" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Part Desc:</th>
                                    <td>
                                        <input type="text" id="txtNewCategoryDesc" class="input-field" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Part Qty:</th>
                                    <td>
                                        <input type="text" id="txtCategoryQty" value="1" style="width: 5%; text-align: right;" />
                                    </td>
                                </tr>
                                <tr>
                                    <th>Is Expand?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isCategoryExpand" value="1" />Yes
                                    <input type="radio" name="isCategoryExpand" value="0" checked="checked" />No
                                    </td>
                                </tr>
                                <tr>
                                    <th>Is Required?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isCategoryRequired" value="1" />Yes
                                    <input type="radio" name="isCategoryRequired" value="0" checked="checked" />No
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
                                    <th>Is Shared Component?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isComponentShared" value="1" />Yes
                                    <input type="radio" name="isComponentShared" value="0" checked="checked" />No
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Part No.:</th>
                                    <td>
                                        <input type="text" id="txtComponentName" class="input-field" />
                                        <input type="button" value="Pick" id="btnPickComponent" onclick="PickComponent()" style="display: none;" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 20%">Part Desc:</th>
                                    <td>
                                        <input type="text" id="txtComponentDesc" class="input-field" />
                                    </td>
                                </tr>
                                <tr>
                                    <th>Is Expand?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isComponentExpand" value="1" />Yes
                                        <input type="radio" name="isComponentExpand" value="0" checked="checked" />No
                                    </td>
                                </tr>
                                <tr>
                                    <th>Is Default?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isComponentDefault" value="1" />Yes
                                        <input type="radio" name="isComponentDefault" value="0" checked="checked" />No
                                    </td>
                                </tr>
                                <tr id="trIsLooseItem">
                                    <th>Is Loose Item?</th>
                                    <td colspan="2">
                                        <input type="radio" name="isComponentLooseItem" value="1" />Yes
                                        <input type="radio" name="isComponentLooseItem" value="0" checked="checked" />No
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="Add" id="btnAddComponent" onclick="AddComponent()" data-type='<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddNewComponent %>' />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="AddCBOMVisibilityControl" title="CBOM Visibility Control" data-options="" style="overflow: auto; padding: 20px; display: block;" runat="server">
                            <table style="width: 99%; background-color: #EBEBEB" id="tableCBOMVisibilityControl">
                                <tr>
                                    <th align="left" style="width: 15%">Name:</th>
                                    <td>
                                        <input type="text" id="txtVisibilityControlERPID" class="input-field" />
                                        <input type="button" value="Add" id="btnAddVisibilityControl" onclick="AddCBOMVisibleCompanyID()" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 15%">Upload:</th>
                                    <td>
                                        <input type="file" id="UploadVisibilityControl" accept=".xls, .xlsx"/>                                        
                                        <input type="button" value="Submit" id="btnSubmitUploadVisibilityControl" onclick="UploadVisibilityFile()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="height:20px">
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <input type="button" value="Delete" id="btnDeleteVisibilityControl" onclick="DeleteCBOMVisibleCompanyID()" />
                                    </td>
                                </tr>
                            </table>
                            <asp:UpdatePanel ID="UPCBOMVisibilityControl" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                            <table style="width: 99%; background-color: #EBEBEB" id="tableCBOMVisibilityControl1">
                                <tr>
                                    <td colspan="2">

                                        <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                                            AllowSorting="true" Width="100%" EmptyDataText="This system has not yet been maintained the visibility control."
                                            DataKeyNames="ROW_ID" OnRowDataBound="gv1_RowDataBound">
                                            <Columns>
                                                <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                                    <HeaderTemplate>
                                                        <asp:CheckBox ID="chkKey" runat="server" OnClick="GetAllCheckBox(this)" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        
                                                        <asp:CheckBox ID="chkKey" runat="server"    />
                                                        <asp:HiddenField ID="hdnId" runat="server" Value='<%#Eval("ROW_ID") %>' />  
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="Company_ID" HeaderText="Company ID" ItemStyle-HorizontalAlign="center" />
                                                <asp:BoundField DataField="Company_Name" HeaderText="Company Name" ItemStyle-HorizontalAlign="center" />
                                            </Columns>
                                        </asp:GridView>

                                    </td>
                                </tr>
                            </table>
                           </ContentTemplate>
                           </asp:UpdatePanel>
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
    <div id="SharedCategoryMenu" style="display: none;">
        <CBOM:SharedCategory ID="SharedCategory1" runat="server" />
    </div>
    <div id="SharedComponentMenu" style="display: none;">
        <CBOM:SharedComponent ID="SharedComponent1" runat="server" />
    </div>

    <script type="text/javascript">

        var selectedNode = null;

        function ShowTree() {
            $('#CategoryTree').tree(
                {
                    loadFilter: myLoadFilter,
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

                            var root = $('#CategoryTree').tree('getRoot');
                            DefaultSettings(root);
                        }
                    },
                    onContextMenu: function (e, node) {
                        e.preventDefault();
                        $('#CategoryTree').tree('select', node.target);
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
                        var target = $('#CategoryTree').tree('getNode', targetNode);
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
                        var targetid = $('#CategoryTree').tree('getNode', targetNode).id;
                        var targetseq = $('#CategoryTree').tree('getNode', targetNode).seq;
                        var targetText = $('#CategoryTree').tree('getNode', targetNode).text;
                        console.log("parentid:" + source.parentid + ", parenttype:" + $('#CategoryTree').tree('find', source.parentid).type + ", currentid:" + source.id + ", currentseq:" + source.seq + ", targetid:" + targetid + ", target seq:" + targetseq + ", point:" + point);

                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            parentid: source.parentid,
                            parenttype: $('#CategoryTree').tree('find', source.parentid).type,
                            currentid: source.id,
                            currentseq: source.seq,
                            targetid: targetid,
                            targetseq: targetseq,
                            point: point
                        };
                        $.ajax(
                            {
                                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/DropTreeNode', type: "POST",
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

                    $("#txtComponentName").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputCBOMPartNo", {
                        theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type BTOS/CTOS PN", tokenLimit: 9, preventDuplicates: true, resizeInput: false,
                        onAdd: function (data) {
                            var tokens = $("#txtComponentName").tokenInput("get");
                            var result = tokens.map(function (obj) {
                                return obj.name;
                            }).join("|");
                            $("#txtComponentName").val(result);

                            if (tokens.length == 1) {
                                $("#txtComponentDesc").val(data.id);
                            }
                            else {
                                $("#txtComponentDesc").val("");
                            }
                        },
                        onDelete: function (data) {
                            DefaultComponentSettings();
                        }
                    });

                    var tokeninputUrl = "<%=System.IO.Path.GetFileName(Request.ApplicationPath)%>/Services/AutoComplete.asmx/GetTokenInputSAPSoldToId";            
                    $("#txtVisibilityControlERPID").tokenInput(tokeninputUrl, {
                        theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type PartNo", tokenLimit: 1, preventDuplicates: true, resizeInput: false, resultsLimit: 6,
                        resultsFormatter: function (data) {
                            var cpn = "";
                            if (data.cpn.length > 0) {
<%--                                    <% If AuthUtil.IsBBUS Then%>
                                    cpn = "<br /><span style='color:red;'>Legacy PN: " + data.cpn + "</span>";
                                <% Else%>
                                    cpn = "<br /><span style='color:red;'>Customer PN: " + data.cpn + "</span>";
                                <% End If %>--%>
                            }

                            return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.name + "</span><br/>" + "<span style='color:gray;'>" + data.id + "</span></li>";
                        },
                        onAdd: function (data) {
                            $("#txtVisibilityControlERPID").val(data.id);
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
                    $("input[name='isSelectedExpand'][value='" + selectedNode.isexpand + "']").prop("checked", true);
                    $("input[name='isSelectedRequired'][value='" + selectedNode.isrequired + "']").prop("checked", true);
                    $("input[name='isSelectedDefault'][value='" + selectedNode.isdefault + "']").prop("checked", true);
                    $("input[name='isSelectedNodeLooseItem'][value='" + selectedNode.configurationrule + "']").prop("checked", true);
                    $('#tabs').tabs("select", 0);
                    $(".tree-node-selected-category").removeClass("tree-node-selected-category");
                    // =======================================================================================
                    // Default Settings, free all button and visibility
                    $('#tabs').tabs('enableTab', 1);
                    $('#tabs').tabs('enableTab', 2);
                    $('#btnAddComponent').attr("disabled", false);
                    $('#btnAddCategory').attr("disabled", false);
                    $('#txtSelectedNodeName').attr("disabled", true);
                    $('#trSelectedNodeQty').show();
                    $('#trSelectedNodeDesc').show();
                    $('#trSelectedNodeExpand').show();
                    $('#trSelectedNodeRequired').show();
                    $('#trSelectedNodeDefault').show();
                    $('#trSelectedNodeLooseItem').hide();

                    // type 0 root, type 1 category, type 2 component, type 3 shared category, type 4 shared component
                    if (selectedNode.type == 0) {
                        $('#txtSelectedNodeName').attr("disabled", false);
                        $('#tabs').tabs('disableTab', 2);
                        $('#trSelectedNodeQty').hide();
                        $('#trSelectedNodeDesc').hide();
                        $('#trSelectedNodeExpand').hide();
                        $('#trSelectedNodeRequired').hide();
                        $('#trSelectedNodeDefault').hide();
                    }
                    else if (selectedNode.type == 1) {
                        $('#tabs').tabs('disableTab', 1);
                        $('#txtSelectedNodeName').attr("disabled", false);
                        $('#trSelectedNodeDefault').hide();
                    }
                    else if (selectedNode.type == 2) {
                        $('#tabs').tabs('disableTab', 2);
                        $('#trSelectedNodeQty').hide();
                        $('#trSelectedNodeRequired').hide();
                        $('#trSelectedNodeLooseItem').show();
                    }
                    else if (selectedNode.type == 3) {
                        $('#tabs').tabs('disableTab', 1);
                        $('#btnAddCategory').attr("disabled", true);
                        $('#trSelectedNodeDefault').hide();
                        $(".tree-node-selected").addClass("tree-node-selected-category").removeClass("tree-node-selected");
                    }
                    else if (selectedNode.type == 4) {
                        $('#tabs').tabs('disableTab', 2);
                        $('#btnAddComponent').attr("disabled", true);
                        $('#trSelectedNodeQty').hide();
                        $('#trSelectedNodeRequired').hide();
                        $('#trSelectedNodeLooseItem').show();
                        $(".tree-node-selected").addClass("tree-node-selected-category").removeClass("tree-node-selected");
                    }
                    // =======================================================================================

                    if ("<%=orgid%>" != "DL") {
                        $('#trSelectedNodeLooseItem').hide();
                        $('#trIsLooseItem').hide();
                    }
                }


                function DefaultCategorySettings() {
                    if ($('input:radio[name=isCategoryShared]:checked').val() == "1") {
                        $('#btnPickCategory').show();
                        $("#btnAddCategory").attr("data-type", '<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddSharedCategory%>');
                    }
                    else {
                        $('#btnPickCategory').hide();
                        $("#btnAddCategory").attr("data-type", '<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddNewCategory%>');
                    }

                    $("#txtNewCategoryName").val("").attr("disabled", false);
                    $("#txtNewCategoryDesc").val("").attr("disabled", false);
                    $('#txtCategoryQty').val("1").attr("disabled", false);
                    $("input[name='isCategoryExpand'][value='0']").attr("checked", true);
                    $("input[name='isCategoryRequired'][value='0']").attr("checked", true);
                    $('input[name=isCategoryExpand]').attr("disabled", false);
                    $('input[name=isCategoryRequired]').attr("disabled", false);
                }

                function DefaultComponentSettings() {
                    if ($('input:radio[name=isComponentShared]:checked').val() == "1") {
                        $('#btnPickComponent').show();
                        $("#btnAddComponent").attr("data-type", '<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddSharedComponent%>');
                    }
                    else {
                        $('#btnPickComponent').hide();
                        $("#btnAddComponent").attr("data-type", '<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddNewComponent%>');
                    }

                    $("#txtComponentName").tokenInput("clear");
                    $("#txtComponentName").data("settings").tokenLimit = 2;
                    $("#txtComponentName").val("").attr("disabled", false);
                    $("#txtComponentDesc").val("").attr("disabled", false);
                    $("input[name='isComponentExpand'][value='0']").attr("checked", true);
                    $("input[name='isComponentDefault'][value='0']").attr("checked", true);
                    $("input[name='isComponentLooseItem'][value='0']").attr("checked", true);
                    $('input[name=isComponentExpand]').attr("disabled", false);
                    $('input[name=isComponentDefault]').attr("disabled", false);
                    $('input[name=isComponentLooseItem]').attr("disabled", false);
                    $("#txtComponentDesc").val("").attr("disabled", false);

                }

                function UpdateSelectedNode() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();
                    if (selectedNode) {
                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            GUID: selectedNode.id,
                            CategoryID: $('#txtSelectedNodeName').val(),
                            Desc: $('#txtSelectedNodeDesc').val(),
                            Type: selectedNode.type,
                            Qty: $('#txtSelectedNodeQty').val(),
                            isExpand: $("input:radio[name='isSelectedExpand']:checked").val(),
                            isRequired: $("input:radio[name='isSelectedRequired']:checked").val(),
                            isDefault: $("input:radio[name='isSelectedDefault']:checked").val(),
                            ConfigurationRule: $("input:radio[name='isSelectedNodeLooseItem']:checked").val()
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
                                        selectedNode.qty = $('#txtSelectedNodeQty').val();
                                        selectedNode.isDefault = $("input:radio[name='isSelectedDefault']:checked").val();
                                        selectedNode.isrequired = $("input:radio[name='isSelectedRequired']:checked").val();
                                        selectedNode.isexpand = $("input:radio[name='isSelectedExpand']:checked").val();

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
                        var url = "";
                        var guid = "";
                        switch ($("#btnAddCategory").attr("data-type")) {
                            case ('<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddSharedCategory%>'):
                                url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddSharedCategory';
                                break;
                            case ('<%=Advantech.Myadvantech.DataAccess.CBOMAddType.CopySharedCategory%>'):
                                url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/CopySharedCategory';
                                guid = $("#txtNewCategoryName").attr("data-id");

                                // Check Ancestor
                                if (CheckRepeatAncestor($('#txtNewCategoryName').val())) {
                                    return false;
                                }

                                break;
                            case ('<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddNewCategory%>'):
                            default:
                                url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddCategory';
                                break;
                        }
                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            ParentGUID: selectedNode.id,
                            CategoryID: $('#txtNewCategoryName').val(),
                            CategoryNote: $('#txtNewCategoryDesc').val(),
                            CategoryType: selectedNode.type,
                            CategoryQty: $('#txtCategoryQty').val(),
                            IsExpand: $("input:radio[name='isCategoryExpand']:checked").val(),
                            IsRequired: $("input:radio[name='isCategoryRequired']:checked").val(),
                            SharedGUID: guid,
                            OrgID: "<%=orgid%>"
                        };
                        $.ajax(
                            {
                                url: url, type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Category successfully added.");

                                        // Reset All settings
                                        DefaultCategorySettings();

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
                        var url = "";
                        var guid = "";

                        switch ($("#btnAddComponent").attr("data-type")) {
                            case ('<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddSharedComponent%>'):
                                url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddSharedComponent';
                                break;
                            case ('<%=Advantech.Myadvantech.DataAccess.CBOMAddType.CopySharedComponent%>'):
                                url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/CopySharedComponent';
                                guid = $("#txtComponentDesc").attr("data-id");

                                // Check Ancestor
                                if (CheckRepeatAncestor($('#txtComponentName').val())) {
                                    return false;
                                }

                                break;
                            case ('<%=Advantech.Myadvantech.DataAccess.CBOMAddType.AddNewComponent%>'):
                            default:
                                url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddComponent';
                                break;
                        }
                        $('#diveditor').LoadingOverlay("show");

                        var postData = {
                            ParentGUID: selectedNode.id,
                            CategoryID: $('#txtComponentName').val(),
                            CategoryNote: $('#txtComponentDesc').val(),
                            CategoryType: selectedNode.type,
                            IsExpand: $("input:radio[name='isComponentExpand']:checked").val(),
                            IsDefault: $("input:radio[name='isComponentDefault']:checked").val(),
                            SharedGUID: guid,
                            OrgID: "<%=orgid%>",
                            ConfigurationRule: $("input:radio[name='isComponentLooseItem']:checked").val()
                        };
                        $.ajax(
                            {
                                url: url, type: "POST",
                                dataType: 'json', data: postData,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Component successfully added.");

                                        // Reset All settings
                                        DefaultComponentSettings();

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


                function AddCBOMVisibleCompanyID() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();

                    var _NewCBOMVisibleCompanyID = $('#txtVisibilityControlERPID').val()
                    var systemID = $('#CategoryTree').tree('getRoot');

                    if (_NewCBOMVisibleCompanyID != "") {

                        var url = "";
                        var guid = "";

                        url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddCBOMVisibilityCompanyID';
                        $('#diveditor').LoadingOverlay("show");

                        var postData = { companyID: _NewCBOMVisibleCompanyID, categoryid: systemID.id };

                        $.ajax(
                            {
                                url: url, type: "POST",
                                dataType: 'json', data: postData,
                                async: false,
                                success: function (retData) {
                                    if (retData.IsUpdated) {
                                        $('#divMsg').text("Company Id successfully added.");
                                        // Reset All settings
                                        DefaultComponentSettings();
                                        RefreshUpdatePanelCBOMVisibilityControl();
                                        //Ryan Showtree
                                        $('#CategoryTree').tree('reload');
                                    }
                                    else {
                                        $('#divErrMsg').text(retData.ServerMessage);
                                    }
                                    $('#txtVisibilityControlERPID').val('');
                                    $("#txtVisibilityControlERPID").tokenInput("clear");
                                    RefreshUpdatePanelCBOMVisibilityControl();
                                },
                                error: function (msg) {
                                    console.log("err:" + msg.d);
                                }
                            }
                        );
                    }
                    else { $('#divErrMsg').text('Please input a Company Id'); }
                }

                function GetAllCheckBox(cbAll) {
                    var items = document.getElementsByTagName("input");
                    for (i = 0; i < items.length; i++) {
                        if (items[i].type == "checkbox") {
                            items[i].checked = cbAll.checked;
                        }
                    }
                }

                function UploadVisibilityFile() {
                    //var UploadFile = $('#UploadVisibilityControl').prop('files')[0];
                    var formData = new FormData();                    
                    var files = $("#UploadVisibilityControl").get(0).files;
                    if(files.length == 0)
                    {
                        alert("No files to be uploaded.");
                        return false;
                    }
                    else if (files[0].name.split('.').pop() != "xlsx" && files[0].name.split('.').pop() != "xls")
                    {                        
                        alert("File type must be xlsx or xls file.");
                        return false;
                    }
                    else{
                        formData.append("UploadedFile", files[0]);
                        formData.append("CategoryID", $('#CategoryTree').tree('getRoot').id);
                    }

                    var url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/UploadCBOMVisibilityByExcel';
                    $.ajax({
                        url: url, type: "POST",
                        dataType: 'json', data: formData,
                        async: false,
                        contentType: false,
                        processData: false,
                        success: function (retData) {                            
                            if (retData.Result) {
                                $('#divMsg').text(retData.Message);
                                RefreshUpdatePanelCBOMVisibilityControl();
                                document.getElementById("UploadVisibilityControl").value = "";
                            }
                            else {
                                $('#divErrMsg').text(retData.Message);
                            }
                        },
                        error: function (msg) {
                            console.log("err:" + msg.d);
                        }
                    });
                }
                

                function DeleteCBOMVisibleCompanyID() {

                    $('#divMsg').empty();
                    $('#divErrMsg').empty();

                    var _NewCBOMVisibleCompanyID = $('#txtVisibilityControlERPID').val()
                    var systemID = $('#CategoryTree').tree('getRoot');


                    var url = "";
                    var guid = "";

                    url = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/DeleteAssignedCTOS';
                    $('#diveditor').LoadingOverlay("show");
                    var rowid = 1;
                    var isrefresh = false;
                    var arr = [];
                    $("#<%=gv1.ClientID%> input[id*='chkKey']:checkbox").each(function (index) {
                        if ($(this).is(':checked')) {
                            rowid = $(this).parent().find('input:hidden:first').attr('value');
                            arr.push(rowid);
                        }
                    });
                    //alert(arr.length);
                    var postData = { ROW_IDs: JSON.stringify(arr)};

                    console.log(postData);
                    $.ajax(
                        {
                            url: url, type: "POST",
                            dataType: 'json', data: postData,
                            async: false,
                            success: function (retData) {
                                isrefresh = true;
                            },
                            error: function (msg) {
                                console.log("err:" + msg.d);
                            }
                        }
                    );

                    RefreshUpdatePanelCBOMVisibilityControl();
                }

                function RefreshUpdatePanelCBOMVisibilityControl()
                {
                    var UpdatePanelCBOMVisibilityControl = '<%=UPCBOMVisibilityControl.UniqueID %>';
                    __doPostBack(UpdatePanelCBOMVisibilityControl, '');
                }


                function RemoveNode() {
                    $('#divMsg').empty();
                    $('#divErrMsg').empty();
                   
                    if (selectedNode) {
                        if (((selectedNode.children1.length == 0) && selectedNode.type != 0) || (selectedNode.type == 3) || (selectedNode.type == 4)) {
                            $('#diveditor').LoadingOverlay("show");

                            var postData = { GUID: selectedNode.id, NodeType: selectedNode.type };
                            $.ajax(
                                {
                                    url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/DeleteNode', type: "POST",
                                    dataType: 'json', data: postData,
                                    success: function (retData) {
                                        if (retData.IsUpdated) {
                                            // Reorder by seq to fill seq gap.
                                            ReOrderBySeq();
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
                    }

                    function PickCategory() {
                        $('#divMsg').empty();
                        $('#divErrMsg').empty();

                        if (selectedNode) {
                            $("#<%=SharedCategory1.GetInitialButtonID%>").click();
                            $("#<%=SharedCategory1.GetSearchTextBoxID%>").val("");
                        }
                    }

                    $("#AddCategory input[name='isCategoryShared']").click(function () {
                        DefaultCategorySettings();
                    });

                    function PickComponent() {
                        $('#divMsg').empty();
                        $('#divErrMsg').empty();

                        if (selectedNode) {
                            $("#<%=SharedComponent1.GetInitialButtonID%>").click();
                            $("#<%=SharedComponent1.GetSearchTextBoxID%>").val("");
                        }
                    }

                    $("#AddComponent input[name='isComponentShared']").click(function () {
                        DefaultComponentSettings();
                    });

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

                    function ReOrderByAlphabetical() {
                        $('#divMsg').empty();
                        $('#divErrMsg').empty();

                        if (selectedNode) {
                            if (selectedNode.children1.length > 1) {
                                $('#diveditor').LoadingOverlay("show");

                                var postData = { GUID: selectedNode.id, NodeType: selectedNode.type };
                                $.ajax({
                                    url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/ReOrderByAlphabetical', type: "POST",
                                    dataType: 'json', data: postData,
                                    success: function (retData) {
                                        if (retData.IsUpdated) {
                                            $('#divMsg').text("Sequence successfully reordered by alphabetical.");

                                            selectedNode = $('#CategoryTree').tree('getParent', selectedNode.target);
                                            //Ryan Showtree
                                            $('#CategoryTree').tree('reload');
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
                            var parentnode = $('#CategoryTree').tree('getParent', selectedNode.target);

                            var postData = {
                                ParentGUID: parentnode.id,
                                ParentNodeType: parentnode.type
                            };
                            $.ajax({
                                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/ReOrderBySeq', type: "POST",
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

                    function CheckRepeatAncestor(sharednode_name) {

                        if (selectedNode) {
                            var root = $('#CategoryTree').tree('getRoot');
                            var currentnode = $('#CategoryTree').tree('find', selectedNode.id);

                            while (currentnode != root) {
                                currentnode = $('#CategoryTree').tree('getParent', currentnode.target);

                                if ((currentnode.type == 3 || currentnode.type == 4) && currentnode.text == sharednode_name) {
                                    $('#divErrMsg').text("Invalid operation, there are repeat shared nodes in ancestors.");
                                    return true;
                                }
                            }
                            return false;
                        }
                        return false;
                    }

                    // Although all data are loaded from database, but lazy load to user end level by level due to performance
                    function myLoadFilter(data, parent) {
                        var state = $.data(this, 'tree');
                        var t = $(this);
                        var opts = t.tree('options');

                        function setData() {
                            var serno = 1;
                            var todo = [];

                            for (var i = 0; i < data.length; i++) {
                                todo.push(data[i]);
                            }

                            while (todo.length) {
                                var node = todo.shift();
                                if (node.id == undefined) {
                                    node.id = '_node_' + (serno++);
                                }

                                if (node.children && node.children.length > 0) {
                                    node.state = 'closed';
                                    node.children1 = node.children;
                                    node.children = undefined;
                                    todo = todo.concat(node.children1);
                                }
                                else {
                                    node.state = 'open';
                                    node.children1 = node.children;
                                }
                            }
                            state.tdata = data;
                        }

                        function find(id) {
                            var data = state.tdata;
                            var cc = [data];
                            while (cc.length) {
                                var c = cc.shift();
                                for (var i = 0; i < c.length; i++) {
                                    var node = c[i];
                                    if (node.virtualid == id) {
                                        return node;
                                    } else if (node.children1) {
                                        cc.push(node.children1);
                                    }
                                }
                            }
                            return null;
                        }

                        function expandfirstlevel() {
                        <% if (!string.IsNullOrEmpty(Request["ID"]))
                           {%>
                        var root = find("<%=Request["ID"].ToString()%>");
                        if (root != null) {
                            if (root.children && root.children.length) { return }
                            if (root.children1) {
                                var filter = opts.loadFilter;
                                opts.loadFilter = function (data) { return data; };
                                t.tree('append', {
                                    parent: root.target,
                                    data: root.children1
                                });
                                opts.loadFilter = filter;
                                root.children = root.children1;
                            }
                            root.state = 'open';
                        }
                        <%}%>
                    }

                    setData();
                    expandfirstlevel();

                    opts.onBeforeExpand = function (node) {
                        var n = find(node.virtualid);
                        if (n.children && n.children.length) { return }
                        if (n.children1) {
                            var filter = opts.loadFilter;
                            opts.loadFilter = function (data) { return data; };
                            t.tree('append', {
                                parent: node.target,
                                data: n.children1
                            });
                            opts.loadFilter = filter;
                            n.children = n.children1;
                        }
                    };
                    return data;
                }

    </script>
</asp:Content>
