<%@ WebService Language="VB" Class="EUAdvPrice" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="eBizAEU")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class EUAdvPrice
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty!"
    End Function

    <WebMethod()> _
    Public Function GetPrice() As Decimal
        Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
        Dim lp As Decimal = -1, up As Decimal = -1
        ws.GetPriceRFC("168", "KR01", "AKRC00134", "AIMB-762G2-00A1E", 1, lp, up)
        Return up
    End Function
    
End Class
