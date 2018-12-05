<%@ Control Language="VB" ClassName="IntelPortalBanner" %>

<script runat="server">

    Protected Sub hyIntelHome_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            hyIntelHome.Visible = HttpContext.Current.User.Identity.Name.ToLower() = "ncg@advantech.com" Or _
                Util.IsInternalUser2() Or HttpContext.Current.User.Identity.Name.EndsWith("@intel.com", StringComparison.OrdinalIgnoreCase)
        End If
    End Sub
</script>
<asp:HyperLink runat="Server" ID="hyIntelHome" NavigateUrl="~/My/Intel/login_check.aspx" ImageUrl="Intel_Banner.jpg" OnLoad="hyIntelHome_Load" Width="246px" />