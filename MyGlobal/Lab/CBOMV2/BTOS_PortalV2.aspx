<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="BTOS_PortalV2.aspx.cs" Inherits="Lab_CBOMV2_BTOS_PortalV2" %>

<%@ Register Src="~/Includes/CBOM/ACN_C-CTOS.ascx" TagName="CCTOS" TagPrefix="CBOM" %>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        .hlClass {
            font-weight: bold;
            font-size: 90%;
            vertical-align: bottom;
        }

        a:visited {
            color: #004181;
        }

        .imgClass {
            padding-left: 10px;
            width: 10px;
            padding-top: 1px;
            vertical-align: top;
            padding-bottom:3px;
        }
    </style>
    <link rel="Stylesheet" href="../../Includes/FancyBox/jquery.fancybox.css" type="text/css" />
    <script type="text/javascript" src="../../Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <script type="text/javascript">
        function ShowCCTOS() {
            $.fancybox('#cc');
            return false;
        }
    </script>

    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home"></asp:HyperLink>
        <span>/</span>
        <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx" Text="Order Tracking "></asp:HyperLink>
        Place System Orders
    </div>
    <br />
    <div class="menu_title">
        Place System Orders
    </div>
    <br />
    <table style="border-top: solid 1px #556b78; border-bottom: solid 1px #556b78; font-family: Arial; font-size: 9pt; background-color: #ebebeb"
        cellpadding="0" cellspacing="0" width="100%"
        border="0">
        <tr>
            <td>
                <asp:Repeater ID="rp_BTOS" runat="server" OnItemDataBound="rp_BTOS_ItemDataBound">
                    <ItemTemplate>
                        <tr>
                            <td align="left">
                                <asp:Image ID="img1" runat="server" ImageUrl="~/Images/point_02.gif" CssClass="imgClass" />
                                <asp:HyperLink ID="hl1" runat="server" Text='<%#Eval("CATALOG_NAME")%>' CssClass="hlClass" NavigateUrl='<%#Util.GetRuntimeSiteUrl() + "/Lab/CBOMV2/CBOM_ListV2.aspx?ID="+Eval("ID") %>'></asp:HyperLink>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        <tr>
                            <td align="left">
                                <asp:Image ID="img2" runat="server" ImageUrl="~/Images/point_02.gif" CssClass="imgClass" />
                                <asp:LinkButton ID="lbCCTOS" runat="server" Text="Project CTOS" CssClass="hlClass" OnClientClick="return ShowCCTOS();"></asp:LinkButton>
                            </td>
                        </tr>
                    </FooterTemplate>
                </asp:Repeater>
            </td>
        </tr>
    </table>
    <div id="cc" style="display: none;">
        <CBOM:CCTOS ID="CCTOS" runat="server" />
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

