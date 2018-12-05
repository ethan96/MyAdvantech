<%@ WebService Language="VB" Class="WSForeStore" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace := "http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _  
Public Class WSForeStore
    Inherits System.Web.Services.WebService 
    
	<WebMethod()> _
	Public Function HelloWorld() As String
		Return "Hello World"
	End Function
    <WebMethod()> _
    Public Function GetSAPProductInfo(ByVal PartNO As String, ByVal ORG As String, ByRef ProductInfo As SAPDAL.DimProductSet, ByRef ErrorStr As String) As Boolean
        Dim EM As String = ""
        Dim PNA As New ArrayList : PNA.Add(PartNO)
        ProductInfo = SAPDAL.syncSingleProduct.syncSAPProduct(PNA, ORG, False, ErrorStr, False)
        Dim DC As New L2SProductDataContext
        'Dim spo As SAP_PRODUCT_ORG = DC.SAP_PRODUCT_ORGs.Where(Function(p) p.PART_NO = PartNO AndAlso p.ORG_ID = ORG)
        If String.IsNullOrEmpty(ErrorStr) Then Return True
        Return False 
    End Function
    
    <WebMethod()> _
    Public Function GetAEUcompanyRegistrationNum(ByVal companyID As String, ByVal isTesting As Boolean) As String
        Dim regi As String = String.Empty
        If Not String.IsNullOrEmpty(companyID) Then
            Dim conn As String = "SAP_PRD"
            If isTesting = True Then conn = "SAP_Test"
            Dim obj As Object = OraDbUtil.dbExecuteScalar(conn, String.Format("select STCD1 from saprdp.kna1 where  kunnr='{0}' and rownum = 1", companyID.Trim.ToUpper))
            If obj IsNot Nothing AndAlso Not String.IsNullOrEmpty(obj.ToString) Then
                regi = obj.ToString
            End If
        End If
        Return regi
    End Function
End Class
