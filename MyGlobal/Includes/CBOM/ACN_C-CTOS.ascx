<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ACN_C-CTOS.ascx.cs" Inherits="Includes_CBOM_ACN_C_CTOS" %>
<script type="text/javascript" src="/Includes/blockUI.js"></script>
<script type="text/javascript">
    $(document).ajaxStart(function () {
        $.blockUI({
            message: "加载中..."
        });
    }).ajaxStop($.unblockUI);

    $(function () {
        $("#txtFinlter").attr('autocomplete', 'off');
        $("#btnSearch").click(function () {
            var txt = $("#txtFinlter").val();
            $(".cmdata").each(function () {
                var cid = $(this).attr("data-id");
                if (!!cid && cid != "") {
                    if (cid.indexOf(txt) > -1)
                        $(this).show();
                    else
                        $(this).hide();
                }
                else
                    $(this).show();
            });
        });
    });

    function AddCCTOS2Cart(node) {
        var id = $(node).attr("data-id");
        if (!!id && id != "") {
            $.fancybox.close();
            var postData = { PartNo: id };
            $.getJSON('<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/CBOMV2_Configurator.asmx/AddProject2Cart', postData, function (data) {
                if (!!data && data.IsUpdated == true)
                    window.location.href = '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Order/Cart_ListV2.aspx';
                else {
                    alert(data.ServerMessage);
                }
            });
        }
        return false;
    }
</script>
<div style="min-height:250px; min-width:250px;">
    <table>
        <tr>
            <td>
                <input type="text" id="txtFinlter" />&nbsp;
                <input type="button" id="btnSearch" value="查找" />
            </td>
        </tr>
    </table>
    <asp:Repeater ID="rpCCTOS" runat="server">
        <HeaderTemplate>
            <table>
                <tr>
                    <th>No.</th>
                    <th>BTO Name</th>
                    <th>Add 2 cart</th>
                </tr>
        </HeaderTemplate>
        <ItemTemplate>
            <tr class="cmdata" data-id='<%#Eval("PART_NO")%>' data-index='<%# Container.ItemIndex%>'>
                <td>
                    <%# Container.ItemIndex + 1%>
                </td>
                <td>
                    <%#Eval("PART_NO")%>
                </td>
                <td style="text-align: center;">
                    <asp:LinkButton ID="btnAdd2Cart" runat="server" data-id='<%#Eval("PART_NO")%>' Text="Add" OnClientClick="return AddCCTOS2Cart(this);"></asp:LinkButton>
                </td>
            </tr>
        </ItemTemplate>
    </asp:Repeater>
    <%--<asp:Label ID="lbMessage" runat="server" ForeColor="Tomato"></asp:Label>--%>
</div>
