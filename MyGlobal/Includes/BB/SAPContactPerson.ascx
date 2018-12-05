<%@ Control Language="C#" AutoEventWireup="true" CodeFile="SAPContactPerson.ascx.cs" Inherits="Includes_BB_SAPContactPerson" %>

<script>
    $(function () {
        $("#hd").hide();
        $("#bd").hide();

        $("#btnSearchContact").click(function (e) {
            var email = $("#txtContactEmail").val();
            var erpid = $("#txtContactERPID").val();
            var name = $("#txtAccountName").val();
            if (email == "" && erpid == "" && name == "") {
                alert("Please input email or ERP ID.");
                return false;
            }

            var option = {
                Email: email,
                ERPID: erpid,
                Name: name
            };

            $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/GetContactPerson', option, function (data) {
                if (data && data.length > 0) {
                    var html = "";
                    for (var i = 0; i < data.length; i++) {
                        html += ("<tr><td style='text-align: center;'>" + data[i].CompanyID + "</td>");
                        html += ("<td>" + data[i].Email + "</td>");
                        html += ("<td style='text-align: center;'>" + data[i].State + "</td>");
                        html += ("<td style='text-align: center;'>" + data[i].City + "</td>");
                        html += ("<td style='text-align: center;'>" + data[i].Zipcode + "</td>");
                        html += ("<td style='text-align: center;'>" + data[i].Country + "</td>");
                        html += ("<td style='text-align: center;'><button type='button' onclick='AssoSiebelSAP(\"" + data[i].CompanyID + "\");'>Pick</button></td></tr>");
                    }
                    $.fancybox.update();
                    $("#hd").show();
                    $("#bd").show().html(html);
                }
                else {
                    alert('No data');
                    $("#hd").hide();
                    $("#bd").hide();
                }

            });
            e.preventDefault();
        });

    });
</script>
<div id="dvSearchSoldTo">
    <table style="width: 890px">
        <tr>
            <td colspan="4" style="font-size: 20px; color: #003377; text-align: center;">Search SAP Sold to ID
            </td>
        </tr>
        <tr>
            <th style="width: 15%;">Sold to ID</th>
            <td>
                <input type="text" id="txtContactERPID" style="width: 120px" />
            </td>
            <th style="width: 15%">Email:</th>
            <td>
                <input type="text" id="txtContactEmail" style="width: 190px" />
            </td>
        </tr>
        <tr>
            <th style="width: 15%;">Account name</th>
            <td colspan="3">
                <input type="text" id="txtAccountName" style="width: 150px" />
            </td>
        </tr>
        <tr>
            <td colspan="4" style="text-align: center">
                <button id="btnSearchContact">Search</button>
            </td>
        </tr>
        <tr>
            <td colspan="4">
                <table style="width:100%;">
                    <thead id="hd">
                        <tr>
                            <th style="width: 15%;">Sold to ID</th>
                            <th style="width: 30%;">Account name</th>
                            <th style="width: 10%;">State</th>
                            <th style="width: 15%;">City</th>
                            <th style="width: 15%;">Zip code</th>
                            <th style="width: 10%;">Country</th>
                            <th style="width: 10%;">Pick</th>
                        </tr>
                    </thead>
                    <tbody id="bd">
                    </tbody>
                </table>
            </td>
        </tr>
    </table>
    <br />
    <asp:HiddenField ID="hfOrderNo" runat="server" Visible="false" Value="" />
</div>