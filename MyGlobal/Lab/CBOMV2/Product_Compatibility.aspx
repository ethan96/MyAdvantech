<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="Product_Compatibility.aspx.cs" Inherits="Product_Compatibility" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
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
        $(function () {
            $("#txtReason").attr('autocomplete', 'off');

            $("#txtPartNo1").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputPartNo", {
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type Part No.", tokenLimit: 2, preventDuplicates: true, resizeInput: false,
                onAdd: function (data) {
                    var tokens = $("#txtPartNo1").tokenInput("get");
                    var result = tokens.map(function (obj) {
                        return obj.name;
                    }).join("|");
                    $("#txtPartNo1").val(result);
                },
                onDelete: function (data) {
                    var tokens = $("#txtPartNo1").tokenInput("get");
                    var result = tokens.map(function (obj) {
                        return obj.name;
                    }).join("|");
                    $("#txtPartNo1").val(result);
                }
            });

            $("#txtPartNo2").tokenInput("<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/AutoComplete.asmx/GetTokenInputPartNo", {
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type Part No.", tokenLimit: 2, preventDuplicates: true, resizeInput: false,
                onAdd: function (data) {
                    var tokens = $("#txtPartNo2").tokenInput("get");
                    var result = tokens.map(function (obj) {
                        return obj.name;
                    }).join("|");
                    $("#txtPartNo2").val(result);
                },
                onDelete: function (data) {
                    var tokens = $("#txtPartNo2").tokenInput("get");
                    var result = tokens.map(function (obj) {
                        return obj.name;
                    }).join("|");
                    $("#txtPartNo2").val(result);
                }
            });

            $("#btnSave").click(function () {
                var pn1 = $("#txtPartNo1").val();
                var pn2 = $("#txtPartNo2").val();
                if (pn1 == "" || pn2 == "") {
                    alert("Please input data.");
                    return false;
                }
                else {
                    var postData = {
                        PartNo1: pn1,
                        PartNo2: pn2,
                        Relation: $('#<%=ddlRelation.ClientID%>').val(),
                        Reason: $("#txtReason").val()
                    };
                    $.ajax(
                        {
                            url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/CreateProductCompatibility', type: "POST",
                            dataType: 'json', data: postData,
                            success: function (retData) {

                                if (retData.Result) {
                                    $("#txtPartNo1").tokenInput("clear");
                                    $("#txtPartNo2").tokenInput("clear");
                                    alert("Add success");
                                    if (!!retData.NewData && retData.NewData.length > 0) {
                                        var html = "";
                                        for (var i = 0; i < retData.NewData.length; i++) {
                                            var uid = retData.NewData[i].userID.split("@");
                                            html += "<tr style='background-color:White;'>";
                                            html += "<td>" + retData.NewData[i].pn1 + "</td>";
                                            html += "<td>" + retData.NewData[i].pn2 + "</td>";
                                            html += "<td align='center'>" + retData.NewData[i].relation + "</td>";
                                            html += "<td>" + retData.NewData[i].reason + "</td>";
                                            html += "<td>" + uid[0] + "</td>";
                                            html += "<td align='center'><img src='/Images/delete.jpg' onclick='DeleteData(" + retData.NewData[i].ID + ");' /></td></tr>";
                                        }
                                        $("#tbData").html(html);
                                    }
                                }
                                else {
                                    alert(retData.Message);
                                }
                            },
                            error: function (msg) {
                                alert(msg);
                            }
                        });
                }
                return false;
            });

            $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/InitialProductCompatibility', null, function (data) {
                if (!!data && data.length > 0) {
                    var html = "";
                    for (var i = 0; i < data.length; i++) {
                        var uid = data[i].userID.split("@");
                        html += "<tr style='background-color:White;'>";
                        html += "<td>" + data[i].pn1 + "</td>";
                        html += "<td>" + data[i].pn2 + "</td>";
                        html += "<td align='center'>" + data[i].relation + "</td>";
                        html += "<td>" + data[i].reason + "</td>";
                        html += "<td>" + uid[0] + "</td>";
                        html += "<td align='center'><img src='/Images/delete.jpg' onclick='DeleteData(" + data[i].ID + ");' /></td></tr>";
                    }
                    $("#tbData").html(html);
                }
            });
        });

        function DeleteData(id) {
            if (!!id && id > 0) {
                if (confirm("Are you sure to delete it?") == true) {
                    $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/DeleteProductCompatibility', {ID: id}, function (data) {
                        if (data.Result == true) {
                            alert("Delete success.");
                            var html = "";
                            if (!!data.NewData && data.NewData.length > 0) {
                                for (var i = 0; i < data.NewData.length; i++) {
                                    var uid = data.NewData[i].userID.split("@");
                                    html += "<tr style='background-color:White;'>";
                                    html += "<td>" + data.NewData[i].pn1 + "</td>";
                                    html += "<td>" + data.NewData[i].pn2 + "</td>";
                                    html += "<td align='center'>" + data.NewData[i].relation + "</td>";
                                    html += "<td>" + data.NewData[i].reason + "</td>";
                                    html += "<td>" + uid[0] + "</td>";
                                    html += "<td align='center'><img src='/Images/delete.jpg' onclick='DeleteData(" + data.NewData[i].ID + ");' /></td></tr>";
                                }
                            }
                            $("#tbData").html(html);
                        }
                        else {
                            alert(data.Message);
                        }
                    });
                }
            }
        }
    </script>
    <div>
        <table>
            <%--<tr>
                <th>Part No. 1</th>
                <th>Status</th>
                <th>Part No. 2</th>
            </tr>--%>
            <tr>
                <td>
                    Part No. 1
                </td>
                <td colspan="2">
                    <input type="text" id="txtPartNo1"/>
                </td>
            </tr>
            <tr>
                <td>
                    Part No. 2
                </td>
                <td>
                    <input type="text" id="txtPartNo2" />
                </td>
                <td>
                    <asp:DropDownList ID="ddlRelation" runat="server"></asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td>
                    Reason
                </td>
                <td colspan="2">
                    <input type="text" style="width: 100%; height: 20px;" id="txtReason" />
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <input type="button" id="btnSave" value="Save" />
                </td>
            </tr>
        </table>
    </div>
    <div>
        <table cellspacing="0" border="1" style="border-color:#D7D0D0;border-width:1px;border-style:Solid;width:100%;border-collapse:collapse;">
            <thead>
                <tr style="color:Black;background-color:Gainsboro;">
                    <th>Part No 1.</th>
                    <th>Part No 2.</th>
                    <th>Status</th>
                    <th>Reason</th>
                    <th>User ID</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tbData">
            </tbody>
        </table>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

