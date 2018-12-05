<%@ WebService Language="VB" Class="MySSO" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="AEUIT")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class MySSO
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty"
    End Function

    <WebMethod()> _
    Public Function EncryptUserId(ByVal uid As String) As String
        If HttpContext.Current.Request.ServerVariables("REMOTE_ADDR").StartsWith("172.21.") = False _
            AndAlso HttpContext.Current.Request.ServerVariables("REMOTE_ADDR").StartsWith("127.") = False Then
            Return New Guid().ToString()
        End If
        Return AEUIT_Rijndael.EncryptDefault(uid)
    End Function
    
End Class
