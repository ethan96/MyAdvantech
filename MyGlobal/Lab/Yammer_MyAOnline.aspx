<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <div id="embedded-feed" style="height: 800px; width: 400px;">
    </div>
    <script src="https://assets.yammer.com/assets/platform_embed.js"></script>
    <script>        yam.connect.embedFeed({
            container: "#embedded-feed",
            network: "advantech.com.tw",
            feedType: "group",
            feedId: "4680177"
        });
    </script>
</asp:Content>
