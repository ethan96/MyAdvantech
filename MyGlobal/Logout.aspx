<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim httpWebcookie As HttpCookie
        httpWebcookie = Request.Cookies(".AEULogin")
        If httpWebcookie IsNot Nothing Then
            httpWebcookie.Domain = "advantech.eu" 
            httpWebcookie.Expires = DateTime.Now.AddYears(-3)
            Response.Cookies.Add(httpWebcookie)  
        End If
        'Frank:This logout url(http://localhost:3291/Home.aspx) is not correct in debug mode. It will occur the http 404 not found.
        'Dim redir As String = "http://" + Request.ServerVariables("SERVER_NAME") + IIf(Request.ServerVariables("SERVER_PORT") <> "80", ":" + Request.ServerVariables("SERVER_PORT"), "")
        Dim redir As String = "~"
        If Session("account_status") = "CP" And Session("RBU") = "ANA" Then
            redir += "/Home.aspx?c=cp&From=ANA"
        Else
            If Session("RBU") = "ANA" Then
                redir += "/Home.aspx?From=ANA"
            Else
                redir += "/Home.aspx"
            End If
        End If
        
        Response.Redirect(redir)
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
