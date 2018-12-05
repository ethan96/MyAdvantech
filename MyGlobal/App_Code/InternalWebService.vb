Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Web.Script.Services

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
<System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantech.Internal")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class InternalWebService
    Inherits System.Web.Services.WebService

    <WebMethod()>
 <ScriptMethod(ResponseFormat:=ResponseFormat.Json)> _
    Public Function GetTollNumber() As String
        Try
            Dim toll_num As String = Util.GetTollNumber()
            Return toll_num

        Catch ex As Exception
            Return "1-888-576-9668"

        End Try

    End Function

    <WebMethod()>
 <ScriptMethod(ResponseFormat:=ResponseFormat.Json)> _
    Public Function CanAccessABRQuotation(ByVal UserID As String, ByVal RBU As String, ByVal AccountStatus As String) As Boolean
        'Frank 2013/10/21
        If Util.IsInternalUser(UserID) Then
            If MailUtil.IsInRole2("colaboradores.sp", UserID) Then
                Return True
            End If
            If RBU.Equals("ABR", StringComparison.InvariantCultureIgnoreCase) AndAlso
                AccountStatus.Equals("FC", StringComparison.InvariantCultureIgnoreCase) Then
                Return True
            End If
        Else
            If RBU.Equals("ABR", StringComparison.InvariantCultureIgnoreCase) Then
                If AccountStatus.Equals("CP", StringComparison.InvariantCultureIgnoreCase) OrElse _
                   AccountStatus.Equals("KA", StringComparison.InvariantCultureIgnoreCase) Then
                    Return True
                End If
            End If
        End If
        Return False
    End Function

    <WebMethod()>
    Public Function GetATP(ByVal partNumber As String, ByVal plant As String, ByVal postponeDays As Integer) As List(Of Advantech.Myadvantech.DataAccess.Inventory)
        Dim errMsg As String = String.Empty
        Dim Parts As List(Of Advantech.Myadvantech.DataAccess.Part) = New List(Of Advantech.Myadvantech.DataAccess.Part)
        Dim P1 As Advantech.Myadvantech.DataAccess.Part = New Advantech.Myadvantech.DataAccess.Part()
        P1.PartNumber = partNumber
        P1.PlantID = plant
        Parts.Add(P1)

        Dim result As List(Of Advantech.Myadvantech.DataAccess.Inventory) = New List(Of Advantech.Myadvantech.DataAccess.Inventory)
        result = Advantech.Myadvantech.DataAccess.SAPDAL.GetInventory(Parts, 0, errMsg)

        Return result
    End Function


End Class