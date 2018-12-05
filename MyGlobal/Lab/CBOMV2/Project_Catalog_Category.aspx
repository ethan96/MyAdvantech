<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="Project_Catalog_Category.aspx.cs" Inherits="Lab_CBOMV2_CBOM_Project_Category" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" href="/Includes/js/token-input-facebook.css" type="text/css" />
    <script type="text/javascript" src="/Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="/Includes/js/jquery.tokeninput.js"></script>
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
    </style>
    <script type="text/javascript">
        function DeleteData(node) {
            if (!!node && confirm("确定删除?") == true) {
                var postData = {
                    ID: $(node).attr("data-id"),
                    companyID: '<%=hfCompanyID.Value%>'
                };
                $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/DeleterProjectCatalogCategory', postData, function (data) {
                    if (!!data && data.Result == true) {
                        var html = "";
                        if (!!data.NewData && data.NewData.length > 0) {
                            for (var i = 0; i < data.NewData.length; i++) {
                                html += "<tr style='background-color:White;'>";
                                html += "<td>" + data.NewData[i].ERPID + "</td>";
                                html += "<td>" + data.NewData[i].pn + "</td>";
                                html += "<td>" + data.NewData[i].memo + "</td>";
                                html += "<td align='center'><img src='/Images/delete.jpg' onclick='DeleteData(this);' data-id=" + data.NewData[i].ID + " /></td></tr>";
                            }
                        }
                        $("#tbData").html(html);
                        alert("删除成功");
                    }
                    else {
                        alert(data.Message);
                    }
                });
            }
            else
                return false;
        }

        $(function () {
            $("#txtErpID").val('<%=hfCompanyID.Value%>');
            $("#txtErpID").attr('autocomplete', 'off');
            $("#txtPartNo").attr('autocomplete', 'off');
            $("#txtMemo").attr('autocomplete', 'off');

            <%--$("#txtPartNo").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputPartNo", {
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type Part No.", tokenLimit: 1, preventDuplicates: true, resizeInput: false,
                onAdd: function (item) {
                    $("#txtPartNo").tokenInput("add", { id: item.name, name: item.id });
                },
                onDelete: function (data) {
                    $("#txtPartNo").val("");
                }
            });--%>

            $("#btnSave").click(function () {
                var id = '<%=hfCompanyID.Value%>';
                var pn = $("#txtPartNo").val();
                var mm = $("#txtMemo").val() || "";
                if (!id || id == "" || !pn || pn == "") {
                    alert("ERP ID & Part No 为必填");
                    return false;
                }
                var postData = {
                    companyID: id,
                    partNo: pn,
                    memo: mm
                };
                $.ajax(
                    {
                        url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/AddProjectCatelogCategory', type: "POST",
                        dataType: 'json', data: postData,
                        success: function (retData) {
                            if (!!retData && retData.Result == true) {
                                //$("#txtErpID").val("");
                                $("#txtPartNo").val("");
                                $("#txtMemo").val("");
                                alert("Add success");
                                var html = "";
                                if (!!retData.NewData && retData.NewData.length > 0) {
                                    for (var i = 0; i < retData.NewData.length; i++) {
                                        html += "<tr style='background-color:White;'>";
                                        html += "<td>" + retData.NewData[i].ERPID + "</td>";
                                        html += "<td>" + retData.NewData[i].pn + "</td>";
                                        html += "<td>" + retData.NewData[i].memo + "</td>";
                                        html += "<td align='center'><img src='/Images/delete.jpg' onclick='DeleteData(this);' data-id=" + retData.NewData[i].ID + " /></td></tr>";
                                    }
                                }
                                $("#tbData").html(html);
                            }
                            else {
                                alert(retData.Message);
                            }
                        },
                        error: function (msg) {
                            alert(msg);
                        }
                    });
            });

            //page load init
            var postData = {
                companyID: '<%=hfCompanyID.Value%>'
            };
            $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/InitialProjectCatalogCategory', postData, function (data) {
                if (!!data && data.length > 0) {
                    var html = "";
                    for (var i = 0; i < data.length; i++) {
                        html += "<tr style='background-color:White;'>";
                        html += "<td>" + data[i].ERPID + "</td>";
                        html += "<td>" + data[i].pn + "</td>";
                        html += "<td>" + data[i].memo + "</td>";
                        html += "<td align='center'><img src='/Images/delete.jpg' onclick='DeleteData(this);' data-id=" + data[i].ID + " /></td></tr>";
                    }
                    $("#tbData").html(html);
                }
            });
        });
    </script>
    <div>
        <table>
            <tr>
                <td>
                    ERP ID
                </td>
                <td>
                    <input type="text" id="txtErpID" disabled="disabled"/>
                </td>
            </tr>
            <tr>
                <td>
                    Part No.
                </td>
                <td>
                    <input type="text" id="txtPartNo" />
                </td>
            </tr>
            <tr>
                <td>
                    备注
                </td>
                <td>
                    <input type="text" style="width: 100%; height: 20px;" id="txtMemo" />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <input type="button" id="btnSave" value="保存" />
                </td>
            </tr>
        </table>
    </div>
    <div>
        <table cellspacing="0" border="1" style="border-color:#D7D0D0;border-width:1px;border-style:Solid;width:100%;border-collapse:collapse;">
            <thead>
                <tr style="color:Black;background-color:Gainsboro;">
                    <th>ERP ID</th>
                    <th>Part No.</th>
                    <th>备注</th>
                    <th>刪除</th>
                </tr>
            </thead>
            <tbody id="tbData">
            </tbody>
        </table>
    </div>
    <asp:HiddenField ID="hfCompanyID" runat="server" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

