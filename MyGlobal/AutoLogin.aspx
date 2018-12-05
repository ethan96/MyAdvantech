<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
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

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

</asp:Content>

