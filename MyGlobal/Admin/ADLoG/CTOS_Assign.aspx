<%@ Page Title="Assign CTOS to specific account" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="CTOS_Assign.aspx.cs" Inherits="Admin_ADLoG_CTOS_Assign" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../../EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript">
        $(function () {
            ShowAllCTOS("");

            $("#btnAdd").click(function () {
                //Collect tokeninput CTOS' ID (Only ID, not catalog name)

            });
        });

        function ShowAllCTOS(erpid) {
            $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/GetAssignedCTOS', { ERPID: erpid }, function (data) {
                if (data && data.length > 0) {
                    var html = "";
                    for (var i = 0; i < data.length; i++) {
                        html += "<tr><td rowspan=" + data[i].ctos.length + ">" + data[i].account + "</td>";

                        if (data[i].ctos.length == 0) {
                            html += "<td></td><td></td><td></td></tr>";
                            continue;
                        }
                        else {
                            html += "<td>" + data[i].ctos[0].name + "</td>";
                            html += "<td>" + data[i].ctos[0].desc + "</td>";
                            html += "<td style='text-align: center;'><a href='/' onclick='return DeleteAssign(" + data[i].ctos[0].ID + ")'><img src='/Images/delete.jpg' alt='delete'></a></td></tr>";

                            if (data[i].ctos.length == 1)
                                continue;
                            else {
                                for (var j = 1; j < data[i].ctos.length; j++) {
                                    html += "<tr><td>" + data[i].ctos[j].name + "</td>";
                                    html += "<td>" + data[i].ctos[j].desc + "</td>";
                                    html += "<td style='text-align: center;'><a href='/' onclick='return DeleteAssign(" + data[i].ctos[j].ID + ")'><img src='/Images/delete.jpg' alt='delete'></a></td></tr>";
                                }
                            }
                        }
                    }
                    $("#dv1").show();
                    $("#ctosbd").html(html);
                }
                else {
                    $("#dv1").hide();
                }
            });
        }

        function DeleteAssign(id) {
            if (id != "") {
                $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Editor.asmx/DeleteAssignedCTOS', { ID: id }, function () {
                });
            }
            ShowAllCTOS("");
            return false;
        }
    </script>
    <table width="100%">
        <tr>
            <td valign="top">
                <table width="100%">
                    <tr>
                        <th align="left" colspan="2">Search ERP ID:
                        </th>
                    </tr>
                    <tr>
                        <th align="left">ERP ID:
                        </th>
                        <td>
                            <input type="text" id="txtSearch" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <button id="btnSearch" type="button">Search</button>
                        </td>
                    </tr>
                </table>
            </td>
            <td>
                <table width="100%">
                    <tr>
                        <th align="left" colspan="2">Assign CTOS
                        </th>
                    </tr>
                    <tr>
                        <th align="left">ERP ID:
                        </th>
                        <td>
                            <input type="text" id="txtAddAccount" />
                        </td>
                    </tr>
                    <tr>
                        <th align="left">CTOS Items:
                        </th>
                        <td>Token input
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <button id="btnAdd" type="button">Add</button>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <br />
    <br />
    <div id="dv1">
        <table width="100%">
            <thead>
                <tr>
                    <th>ERP ID</th>
                    <th>BTO description</th>
                    <th>Group Description</th>
                    <th>Delete</th>
                </tr>
            </thead>
            <tbody id="ctosbd"></tbody>
        </table>
    </div>
</asp:Content>
