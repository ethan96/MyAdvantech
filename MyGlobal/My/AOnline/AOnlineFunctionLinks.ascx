<%@ Control Language="VB" ClassName="AOnlineFunctionLinks" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub
</script>
<a runat="server" id="LitTypeLabel"><img src="../../Images/Aonline_menu.JPG" /></a>
<obout:Flyout runat="server" ID="FlyoutLitType" OpenEvent="ONMOUSEOVER" CloseEvent="ONMOUSEOUT"
    AttachTo="LitTypeLabel" Position="ABSOLUTE" zIndex="8" RelativeLeft="-35" RelativeTop="25">
    <table width="200px" style="background-color:#EBEBEB; padding-left:5px; padding-top:5px; padding-bottom:5px">
        <tr>
            <th align="left" colspan="2" style="color:Gray; font-size:medium">
                Menu
            </th>
        </tr>
        <tr align="left">
            <td valign="top">
                <asp:Image runat="server" ID="Image1" ImageUrl="~/Images/point_02.gif" />
            </td>
            <td>
                <asp:HyperLink runat="server" ID="HyperLink1" NavigateUrl="~/My/AOnline/ContentSearch.aspx" Text="Content Search" />
            </td>
        </tr>
        <tr align="left">
            <td valign="top">
                <asp:Image runat="server" ID="Image2" ImageUrl="~/Images/point_02.gif" />
            </td>
            <td>
                <asp:HyperLink runat="server" ID="HyperLink2" NavigateUrl="~/My/AOnline/ContentForward.aspx" Text="Content Forward" />
            </td>
        </tr>
        <tr align="left">
            <td valign="top">
                <asp:Image runat="server" ID="Image3" ImageUrl="~/Images/point_02.gif" />
            </td>
            <td>
                <asp:HyperLink runat="server" ID="HyperLink3" NavigateUrl="~/My/AOnline/ContactMining.aspx" Text="Contact Search & List Creation" />
            </td>
        </tr>
        <tr align="left">
            <td valign="top">
                <asp:Image runat="server" ID="Image4" ImageUrl="~/Images/point_02.gif" />
            </td>
            <td>
                <asp:HyperLink runat="server" ID="HyperLink4" NavigateUrl="~/My/AOnline/MyCampaigns.aspx" Text="My eLetters" />
            </td>
        </tr>  
        <tr align="left">
            <td valign="top">
                <asp:Image runat="server" ID="Image5" ImageUrl="~/Images/point_02.gif" />
            </td>
            <td>
                <asp:HyperLink runat="server" ID="HyperLink5" NavigateUrl="~/My/AOnline/RecCenterDashboard.aspx" Text="Resource Dashboard" />
            </td>
        </tr>      
    </table>
</obout:Flyout>
