<%@ Page Language="C#" CodeFile="CheckPoint.aspx.cs" Inherits="Order_CheckPoint_CheckPoint" MasterPageFile="~/Includes/MyMaster.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../../Includes/dialog/jquery.min.js"></script>
    <script src="../../Includes/dialog/jquery-ui.js" type="text/javascript"></script>
    <link href="../../Includes/dialog/jquery-ui.css"
        rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        $(function () {
            $(".btn_Detail").click(function (e) {
                e.preventDefault();
                var wWidth = $(window).width();
                var dWidth = wWidth * 0.95;
                var wHeight = $(window).height();
                var dHeight = wHeight * 0.95;
                var btn_value = $(this).attr("value");

                $.ajax({
                    type: "POST",
                    url: "CheckPoint.aspx/GetWSResult",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({ SO: btn_value }),

                    // 需求送出後 就先把dialog & button 建立出來
                    complete: function () {
                        $("#showresult").dialog({
                            modal: true,
                            draggable: false,
                            resizable: false,
                            width: dWidth,
                            height: dHeight,
                            buttons: {
                                'Convert to Order': function () {
                                    $('#hf1').val(btn_value),
                                    __doPostBack('hf1', '');
                                },
                                'Add to Cart': function () {
                                    $('#hf2').val(btn_value),
                                    __doPostBack('hf2', '');
                                },
                                'Cancel': function () { $(this).dialog('close'); }
                            }
                        });
                    },
                    // 若web-service呼叫成功 則將回傳訊息顯示在dialog上
                    success: function (data) {
                        $("#showresult").html(data.d);
                    },
                    // 若呼叫失敗 則顯示無回存訊息
                    error: function () {
                        $("#showresult").html("No detail message returned.");
                    },
                });
            });
        });
    </script>
    <div>
        <table width="100%">
            <tr>
                <td class="menu_title">
                    <asp:Label runat="server" ID="lbPageName" Text="CheckPoint Order List"></asp:Label>
                </td>
            </tr>
            <tr>
                <td class="menu_title">
                   <asp:Button runat="server" ID="btnRefresh" Text="Refresh" OnClick="btnRefresh_Click" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:GridView ID="GridView1" runat="server"
                        DataKeyNames="SO" Width="100%" AutoGenerateColumns="False">
                        <Columns>
                            <asp:TemplateField HeaderText="SO">
                                <ItemTemplate>
                                    <%# Eval("SO")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Distribuction Channel"
                                DataField="dist_chan" SortExpression="dist_chan"></asp:BoundField>
                            <asp:BoundField HeaderText="Division"
                                DataField="DIVISION" SortExpression="DIVISION"></asp:BoundField>
                            <asp:BoundField HeaderText="Incoterm 2"
                                DataField="inco2" SortExpression="inco2"></asp:BoundField>
                            <asp:BoundField HeaderText="Customer PO No."
                                DataField="CUST_PO_NO" SortExpression="CUST_PO_NO"></asp:BoundField>
                            <asp:TemplateField ShowHeader="False">
                                <ItemTemplate>
                                    <button class="btn_Detail" value="<%# Eval("SO")%>">Detail</button>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </td>
            </tr>
    </div>
    <div id="showresult" style="display: none" title="Detail">
    </div>
    <asp:HiddenField ID="hf1" runat="server" Value="" ClientIDMode="Static" OnValueChanged="hf1_valueChanged" />
    <asp:HiddenField ID="hf2" runat="server" Value="" ClientIDMode="Static" OnValueChanged="hf2_valueChanged" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
