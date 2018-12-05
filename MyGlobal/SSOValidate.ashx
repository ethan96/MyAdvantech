<%@ WebHandler Language="VB" Class="SSOValidate" %>

Imports System
Imports System.Web
Imports MemberShip

Public Class SSOValidate : Implements IHttpHandler, IRequiresSessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        'context.Response.ContentType = "text/plain"
        'context.Response.Write("Hello World")
        With context
            If .Request("TempId") = "" OrElse .Request("user_id") = "" Then
                .Response.Redirect("home.aspx")
            Else
                Dim sso As New SSO.MembershipWebservice, Validated As Boolean = False
                sso.Timeout = -1
                Validated = sso.validateTemidEmail(Util.GetClientIP(), .Request("TempId"), "MY", .Request("user_id"))
                If Validated Then
                    If .Session("LanG") Is Nothing Then
                        .Session("LanG") = "ENG"
                    End If
                    'Dim aCookie As New HttpCookie("lastVisitLanG")
                    'aCookie.Value = .Session("LanG").ToString.Trim.ToUpper
                    'aCookie.Expires = DateTime.Now.AddDays(5)
                    '.Response.Cookies.Add(aCookie)
                    AuthUtil.SetSessionById(.Request("user_id"), .Request("TempId"))
                    FormsAuthentication.SetAuthCookie(.Request("user_id"), False)
                    If .Request("ToUrl") <> "" Then
                        .Response.Redirect(HttpUtility.UrlDecode(.Request("ToUrl")))
                    Else
                        RedirectLoginUser()
                    End If
                End If
            End If
        End With
    End Sub
    Public Shared Sub RedirectLoginUser()
        With HttpContext.Current
            If .Session("account_status") Is Nothing Then .Session("account_status") = AuthUtil.GetUserType(.Session("user_id"))
            Select Case .Session("account_status").ToString().ToUpper()
                Case "EZ"
                    .Response.Redirect("home_ez.aspx")
                Case "CP"
                    .Response.Redirect("home_cp.aspx")
                Case "GA"
                    .Response.Redirect("home_ga.aspx")
                Case "KA"
                    .Response.Redirect("home_ka.aspx")
                Case "DMS"
                    .Response.Redirect("home_dms.aspx")
            End Select
        End With
    End Sub
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class