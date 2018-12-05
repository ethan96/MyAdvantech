<%@ WebService Language="VB" Class="WebService" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace := "my.advantech.eu")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _  
Public Class WebService
    Inherits System.Web.Services.WebService 
    <WebMethod()> _
    Public Function CreateAccountContactQuotationFromSPR() As Boolean
        'Dim ST As New OP_SiebelTools
        'ST.CreateAccountContactQuotationFromSPR()
        Return False
    End Function
    
End Class
