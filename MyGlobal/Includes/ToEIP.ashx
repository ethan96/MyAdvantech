<%@ WebHandler Language="VB" Class="ToEIP" %>

Imports System
Imports System.Web

Public Class ToEIP : Implements IHttpHandler, IReadOnlySessionState

    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("EIPPID") IsNot Nothing AndAlso .Session IsNot Nothing _
                AndAlso (Util.IsInternalUser(.Session("user_id")) OrElse context.Session("company_id") = "T80087921") _
                AndAlso .Session("TempId") IsNot Nothing AndAlso .Session("TempId").ToString() <> "" Then
                Dim strRedUrl As String = "http://employeezone.advantech.com.tw/"
                If .Request("EIPPID") = "ePricer_SSO" Then
                    'strRedUrl = String.Format("http://172.20.1.20/ez_sso/ez_sso_check.aspx?email={0}&tempid={1}&strSrcPage={2}", .Session("user_id"), .Session("TempId"), Trim(.Request("EIPPID")))
                    strRedUrl = String.Format("http://aclepricer.advantech.corp/?id={0}&tempid={1}", .Session("user_id"), .Session("TempId"))
                End If
                'Util.SendEmail("tc.chen@advantech.eu", "ebusiness.aeu@advantech.eu", "", strRedUrl, True, "", "")
                .Response.Redirect(strRedUrl)
            Else
                Dim strRedUrl As String = "http://employeezone.advantech.com.tw/"
                'Util.SendEmail("tc.chen@advantech.eu", "ebusiness.aeu@advantech.eu", "", strRedUrl, True, "", "")
                .Response.Redirect(strRedUrl)
            End If
        End With
    End Sub

    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class