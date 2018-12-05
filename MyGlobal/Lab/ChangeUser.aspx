<%@ Page Language="C#" %>

<!DOCTYPE html>

<script runat="server">

    protected void btnChange_Click(object sender, EventArgs e)
    {
        Session.Abandon();
        System.Web.Security.FormsAuthentication.SignOut();
        var UID = txtUID.Text;
        System.Web.Security.FormsAuthentication.SetAuthCookie(UID, true);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:TextBox runat="server" ID="txtUID" />&nbsp;<asp:Button runat="server" ID="btnChange" Text="Change" OnClick="btnChange_Click" />
    </div>
    </form>
</body>
</html>
