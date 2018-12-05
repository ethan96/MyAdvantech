<%@ Control Language="VB" ClassName="Schedules" %>
<script runat="server">

</script>
<table width="150">
    <tr>
        <th align="center">
            Schedule Date
        </th>
        <th align="center">
            Qty.
        </th>
    </tr>
    <tr>
        <td>
            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" Format="yyyy/MM/dd"
                TargetControlID="txtCal1" />
            <asp:TextBox runat="server" ID="txtCal1" Width="80px" />
        </td>
        <td>
            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1"
                TargetControlID="txtQty1" FilterMode="ValidChars" FilterType="Numbers" />
            <asp:TextBox runat="server" ID="txtQty1" Width="30px" CssClass="qtyboxOnlyNO" />
        </td>
    </tr>
    <tr>
        <td>
            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" Format="yyyy/MM/dd"
                TargetControlID="txtCal2" />
            <asp:TextBox runat="server" ID="txtCal2" Width="80px" />
        </td>
        <td>
            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender2"
                TargetControlID="txtQty2" FilterMode="ValidChars" FilterType="Numbers" />
            <asp:TextBox runat="server" ID="txtQty2" Width="30px" CssClass="qtyboxOnlyNO" />
        </td>
    </tr>
    <tr id="tr3" runat="server">
        <td>
            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender3" Format="yyyy/MM/dd"
                TargetControlID="txtCal3" />
            <asp:TextBox runat="server" ID="txtCal3" Width="80px" />
        </td>
        <td>
            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender3"
                TargetControlID="txtQty3" FilterMode="ValidChars" FilterType="Numbers" />
            <asp:TextBox runat="server" ID="txtQty3" Width="30px" CssClass="qtyboxOnlyNO" />
        </td>
    </tr>
    <tr id="tr4" runat="server">
        <td>
            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender4" Format="yyyy/MM/dd"
                TargetControlID="txtCal4" />
            <asp:TextBox runat="server" ID="txtCal4" Width="80px" />
        </td>
        <td>
            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender4"
                TargetControlID="txtQty4" FilterMode="ValidChars" FilterType="Numbers" />
            <asp:TextBox runat="server" ID="txtQty4" Width="30px" CssClass="qtyboxOnlyNO" />
        </td>
    </tr>
    <tr id="tr5" runat="server">
        <td>
            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender5" Format="yyyy/MM/dd"
                TargetControlID="txtCal5" />
            <asp:TextBox runat="server" ID="txtCal5" Width="80px" />
        </td>
        <td>
            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender5"
                TargetControlID="txtQty5" FilterMode="ValidChars" FilterType="Numbers" />
            <asp:TextBox runat="server" ID="txtQty5" Width="30px" CssClass="qtyboxOnlyNO" />
        </td>
    </tr>
    <%--    <tr>
                <td colspan="2" align="right"><input id="btnMore" type="button" value="confirm"  onclick='ShowMore();'/></td>
                </tr>--%>
</table>
<%--            <table width="150">
    <tr>
        <td>
        </td>
    </tr>
    <tr align="right">
        <td>
            <input id="btnMore" type="button" value="+More"  onclick='ShowMore();'/>
        </td>
    </tr>
</table>--%>
<script type="text/javascript">
    function ShowMore() {
        var tr3 = document.getElementById('<%=tr3.ClientID %>');
        alert(tr3.style.display);
        var tr4 = document.getElementById('<%=tr4.ClientID %>');
        var tr5 = document.getElementById('<%=tr5.ClientID %>');
        if (tr3.style.display == 'none') {
            tr3.style.display = 'block';
        }
        else {
            if (tr4.style.display == 'none') {
                tr4.style.display = 'block';
            }
            else {
                if (tr5.style.display == 'none') {
                    tr5.style.display = 'block';
                    document.getElementById('btnMore').style.display = 'none';
                }
            }
        }
    }
</script>
