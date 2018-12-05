<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RyanTest.aspx.cs" Inherits="Lab_RyanTest" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <script type="text/javascript" src="../Includes/dialog/jquery.min.js"></script>
    <script src="../Includes/dialog/jquery-ui.js" type="text/javascript"></script>
    <link href="../Includes/dialog/jquery-ui.css"
        rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        $(function () {
            $("#btn_Detail").click(function (e) {
                e.preventDefault();
                var wWidth = $(window).width();
                var dWidth = wWidth * 0.8;
                var wHeight = $(window).height();
                var dHeight = wHeight * 0.8;
                var btn_value = $(this).attr("value");
                $.ajax({
                    type: "POST",
                    url: "RyanTest.aspx/GetWSResult",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({ SO: btn_value }),

                    success: function (data) {
                        $("#showresult").dialog({
                            width: dWidth,
                            height: dHeight,
                            modal: true,
                            draggable: false,
                            resizable: false,
                            buttons: {
                                'Convert to Order': function () { $(this).dialog('close'); },
                                'Add to Cart': function () { $('#btn_Convert2Order').trigger('click'); },
                                'Cancel': function () { $(this).dialog('close'); }
                            }
                        });
                        $("#showresult").html(data.d);
                    },
                });
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server"
                DataKeyNames="SO" Width="60%" AutoGenerateColumns="False">
                <Columns>
                    <asp:TemplateField HeaderText="SO">
                        <ItemTemplate>
                            <%# Eval("SO")%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="dist_chan"
                        DataField="dist_chan" SortExpression="dist_chan"></asp:BoundField>
                    <asp:BoundField HeaderText="Division"
                        DataField="DIVISION" SortExpression="DIVISION"></asp:BoundField>
                    <asp:BoundField HeaderText="inco2"
                        DataField="inco2" SortExpression="inco2"></asp:BoundField>
                    <asp:BoundField HeaderText="CUST_PO_NO"
                        DataField="CUST_PO_NO" SortExpression="CUST_PO_NO"></asp:BoundField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <button id="btn_Detail" value="<%# Eval("SO")%>">Detail</button>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <%-- <asp:SqlDataSource ID="SqlDataSource1" runat="server"
                ConnectionString="Data Source=172.21.1.131;Initial Catalog=CheckPointDB;Persist Security Info=True;User ID=ITRequestSA;Password=fred1234"
                SelectCommand="SELECT * FROM [CheckPointDB].[dbo].[SO_HEADER]"></asp:SqlDataSource>--%>
            <%--            <asp:GridView ID="gv1" runat="server">
            </asp:GridView>--%>
        </div>
        <div id="showresult" style="display: none" title="Detail">
        </div>
        <asp:Button ID="btn_Convert2Order" runat="server" UseSubmitBehavior="false" Style="display: none" OnClick="btn_Convert2Order_Click" />
        <asp:Button ID="btn_test" runat="server" Text="test" OnClick="btn_test_Click" />
    </form>
</body>
</html>
