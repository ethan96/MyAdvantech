Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="prm.my.advantech.com")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class MyPRM
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty!"
    End Function


    Class PartNoQtyReqDate
        Public Property PartNo As String : Public Property Qty As Integer : Public Property RequiredDate As Date
    End Class

    Class ReturnMessage
        Public Property RequestRowId As String : Public Property ErrorMessage As String : Public Property IsSuccessful As Boolean
    End Class

    Class PRMReqOrderDetail
        Public Property ContactId As String : Public Property ContactEmail As String : Public Property ProductRecords As New List(Of MyPRM.PartNoQtyReqDate)
    End Class

    <WebMethod()> _
    Public Sub CreateRepOrderRequest(ByVal ContactRowId As String, ByRef ProductRecords As List(Of PartNoQtyReqDate), ByRef ReturnedMessageObject As ReturnMessage)
        'Threading.Thread.Sleep(2000)
        ReturnedMessageObject = New ReturnMessage
        If String.IsNullOrEmpty(ContactRowId) OrElse ProductRecords Is Nothing OrElse ProductRecords.Count = 0 Then
            ReturnedMessageObject.IsSuccessful = False : ReturnedMessageObject.ErrorMessage = "Input parameters are incorrect" : Exit Sub
        End If

        Dim ConnMy As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter( _
            " select top 1 a.ROW_ID as CONTACT_ID, a.EMAIL_ADDRESS, b.ACCOUNT_STATUS, b.ACCOUNT_NAME, b.RBU, c.COMPANY_ID, c.ORG_ID, b.ROW_ID as ACCOUNT_ID " + _
            " from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID inner join SAP_DIMCOMPANY c on b.ERP_ID=c.COMPANY_ID  " + _
            " where c.COMPANY_TYPE='Z001' and dbo.IsEmail(a.EMAIL_ADDRESS)=1  " + _
            " and a.ACCOUNT_STATUS in ('01-Platinum Channel Partner','01-Premier Channel Partner','02-Gold Channel Partner','03-Certified Channel Partner') " + _
            " and a.ROW_ID=@CONTACTID  " + _
            " order by c.COMPANY_ID, c.ORG_ID ", ConnMy)
        apt.SelectCommand.Parameters.AddWithValue("CONTACTID", ContactRowId)
        Dim dtContactProfile As New DataTable
        apt.Fill(dtContactProfile)
        apt.SelectCommand.Connection.Close()
        If dtContactProfile.Rows.Count = 0 Then
            ReturnedMessageObject.IsSuccessful = False : ReturnedMessageObject.ErrorMessage = "Contact cannot be found, or not a PCP, or email is invalid, or ERPID is invalid" : Exit Sub
        End If
        Dim strPcpEmail As String = dtContactProfile.Rows(0).Item("EMAIL_ADDRESS")
        Dim cmd As New SqlClient.SqlCommand( _
            " select COUNT(a.PRIVILEGE) as c from SIEBEL_CONTACT_PRIVILEGE a inner join SIEBEL_CONTACT b on a.ROW_ID=b.ROW_ID " + _
            " where a.PRIVILEGE in ('Can Place Order') and b.EMAIL_ADDRESS=@PCPEMAIL", ConnMy)
        cmd.Parameters.AddWithValue("PCPEMAIL", strPcpEmail)
        cmd.Connection.Open() : Dim objHasOrderPermission As Integer = CInt(cmd.ExecuteScalar()) : cmd.Connection.Close()
        If objHasOrderPermission = 0 Then
            ReturnedMessageObject.IsSuccessful = False : ReturnedMessageObject.ErrorMessage = "Contact has no permission to place order" : Exit Sub
        End If

        cmd.Parameters.Clear() : ConnMy.Open()

        For Each PartNoQtyReqDate1 As PartNoQtyReqDate In ProductRecords
            If String.IsNullOrEmpty(PartNoQtyReqDate1.PartNo) Then
                ConnMy.Close() : ReturnedMessageObject.IsSuccessful = False : ReturnedMessageObject.ErrorMessage = "Part number cannot be empty" : Exit Sub
            End If
            PartNoQtyReqDate1.PartNo = UCase(Trim(PartNoQtyReqDate1.PartNo))
            If Integer.TryParse(PartNoQtyReqDate1.Qty, 0) = False OrElse CInt(PartNoQtyReqDate1.Qty) <= 0 Then
                ConnMy.Close() : ReturnedMessageObject.IsSuccessful = False : ReturnedMessageObject.ErrorMessage = "Qty of " + PartNoQtyReqDate1.PartNo + " is not a valid integer number" : Exit Sub
            End If
            cmd.Parameters.Clear()
            cmd.CommandText = "select COUNT(PART_NO) as p from SAP_PRODUCT where PART_NO=@PN and STATUS in ('A','N','O')"
            cmd.Parameters.AddWithValue("PN", PartNoQtyReqDate1.PartNo)
            Dim objPNCount As Integer = CInt(cmd.ExecuteScalar())
            If objPNCount = 0 Then
                ConnMy.Close() : ReturnedMessageObject.IsSuccessful = False
                ReturnedMessageObject.ErrorMessage = "Part number:" + PartNoQtyReqDate1.PartNo + " cannot be found on SAP, or not yet phased-in, or already phased out"
                Exit Sub
            End If
        Next


        ReturnedMessageObject.RequestRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)

        Dim PRMReqOrderDetail1 As New PRMReqOrderDetail
        PRMReqOrderDetail1.ContactId = ContactRowId : PRMReqOrderDetail1.ContactEmail = strPcpEmail : PRMReqOrderDetail1.ProductRecords = ProductRecords
        Dim PRMOrderRequests As Dictionary(Of String, PRMReqOrderDetail) = CType(HttpContext.Current.Cache("PRMOrderRequests"), Dictionary(Of String, PRMReqOrderDetail))
        If PRMOrderRequests Is Nothing Then
            PRMOrderRequests = New Dictionary(Of String, PRMReqOrderDetail)
            HttpContext.Current.Cache.Add("PRMOrderRequests", PRMOrderRequests, Nothing, DateTime.Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        PRMOrderRequests.Add(ReturnedMessageObject.RequestRowId, PRMReqOrderDetail1)
        ReturnedMessageObject.IsSuccessful = True : ReturnedMessageObject.ErrorMessage = "" : Exit Sub
    End Sub

End Class