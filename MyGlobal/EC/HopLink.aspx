<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("HopUrl") IsNot Nothing Then
                meta1.Content = "1; url=" + HttpUtility.UrlPathEncode(Request("HopUrl").ToString())
                hyHop.NavigateUrl = Request("HopUrl").ToString()
                hyHop.Visible = True
            End If
        End If
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>MyAdvantech - Hop Link</title>
    <meta runat="server" id="meta1" http-equiv="refresh" 
        content="0; url=http://my.advantech.com" />
</head>
<body>
    <form id="form1" runat="server">
    <div>
        If your browser doesn't redirect automatically please <asp:HyperLink runat="server" ID="hyHop" Text="Click Here" Visible="false" />
    </div>
    </form>
</body>
</html>
