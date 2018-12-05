<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            'If Request("tempid") IsNot Nothing AndAlso Request("tempid") <> "" And Request("user_id") Is Nothing Then
                'Dim ws As New SSO.MembershipWebservice
                'ws.Timeout = -1
                'Dim hasSSO As Boolean = ws.validateTemidEmail(Request.ServerVariables("REMOTE_ADDR"), Request("tempid"), "My", Request("id"))
                'If hasSSO Then
                    'Session("TempId") = Request("tempid")
                    'FormsAuthentication.RedirectFromLoginPage(Request("id"), False)
                'Else
                    'Response.Redirect("home.aspx")
                'End If
            'End If
            If Request("TempId") = "" Or Request("user_id") = "" Then
                Response.Redirect("home.aspx")
            Else
                Dim sso As New SSO.MembershipWebservice, Validated As Boolean = False
                sso.Timeout = -1
                Validated = sso.validateTemidEmail(Util.GetClientIP(), Request("TempId"), "MY", Request("user_id"))
                If Validated Then
                    Session("LanG") = "ENG"
                    Dim aCookie As New HttpCookie("lastVisitLanG")
                    aCookie.Value = Session("LanG").ToString.Trim.ToUpper
                    aCookie.Expires = DateTime.Now.AddDays(5)
                    Response.Cookies.Add(aCookie)
                    AuthUtil.SetSessionById(Request("user_id"), Request("TempId"))
                    FormsAuthentication.SetAuthCookie(Request("user_id"), False)
                    If Request("ToUrl") <> "" Then
                        Response.Redirect(HttpUtility.UrlDecode(Request("ToUrl")))
                    Else
                        RedirectLoginUser()
                    End If
                End If
            End If
        End If
    End Sub
    Sub RedirectLoginUser()
        If Session("account_status") Is Nothing Then Session("account_status") = AuthUtil.GetUserType(Session("user_id"))
        Select Case Session("account_status").ToString().ToUpper()
            Case "EZ"
                Response.Redirect("home_ez.aspx")
            Case "CP"
                Response.Redirect("home_cp.aspx")
            Case "GA"
                Response.Redirect("home_ga.aspx")
            Case "KA"
                Response.Redirect("home_ka.aspx")
            Case "DMS"
                Response.Redirect("home_dms.aspx")
        End Select
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
