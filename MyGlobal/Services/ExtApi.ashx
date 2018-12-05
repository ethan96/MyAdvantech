<%@ WebHandler Language="VB" Class="ExtApi" %>

Imports System
Imports System.Web

Public Class ExtApi : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If context.Request("key") IsNot Nothing AndAlso context.Request("pn") IsNot Nothing Then
            Threading.Thread.Sleep((New Random).Next(300, 3388))
            Dim AccessKey As String = context.Request("key"), AdvPartNo As String = context.Request("pn")
            Dim jSerializer As New Script.Serialization.JavaScriptSerializer
            Dim ExtApiAccessRecords As List(Of ExtApiAccessRecord) = Nothing
            Try
                ExtApiAccessRecords = HttpContext.Current.Cache("External Access List")
            Catch ex As InvalidCastException
                HttpContext.Current.Cache.Remove("External Access List")
            End Try
        
            If ExtApiAccessRecords Is Nothing Then
                ExtApiAccessRecords = New List(Of ExtApiAccessRecord)
                HttpContext.Current.Cache.Add("External Access List", ExtApiAccessRecords, Nothing, Now.AddHours(6), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
            End If
        
            Dim chk = From q In ExtApiAccessRecords Where q.AccessKey = AccessKey
        
            If chk.Count = 0 Then
            
                Dim apt As New SqlClient.SqlDataAdapter("select ERP_ID, ORG_ID, IP_RANGES, PLANTS from EXTAPI_ACCESS_KEY where ACCESS_KEY=@AC", ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
                Dim dtAC As New DataTable
                apt.SelectCommand.Parameters.AddWithValue("AC", AccessKey)
                apt.Fill(dtAC)
                apt.SelectCommand.Connection.Close()
                If dtAC.Rows.Count = 1 Then
                    Dim ExtApiAccessRecord1 As New ExtApiAccessRecord
                    ExtApiAccessRecord1.AccessKey = AccessKey : ExtApiAccessRecord1.ERPId = dtAC.Rows(0).Item("ERP_ID") : ExtApiAccessRecord1.OrgId = dtAC.Rows(0).Item("ORG_ID")
                    Dim IPRanges() As String = Split(dtAC.Rows(0).Item("IP_RANGES"), ";")
                    For Each IPRange In IPRanges
                        Dim IR() As String = Split(IPRange, "-")
                        If IR.Length = 2 Then ExtApiAccessRecord1.IPRanges.Add(New IPRange(IR(0), IR(1)))
                    Next
                    ExtApiAccessRecord1.IPRanges.Add(New IPRange(2886731432, 2886731432))   '172.16.6.168 which is PC000627 (TC's PC)
                    ExtApiAccessRecord1.SetPlants(dtAC.Rows(0).Item("PLANTS"))
                    ExtApiAccessRecords.Add(ExtApiAccessRecord1)
                Else
                    HttpContext.Current.Response.StatusCode = 401 : HttpContext.Current.Response.End()
                End If
            End If
        
            chk = From q In ExtApiAccessRecords Where q.AccessKey = AccessKey
        
            If chk.Count = 0 Then
                HttpContext.Current.Response.StatusCode = 401 : HttpContext.Current.Response.End()
            End If
        
            '63.121.150.160/27
            '50.241.173.192/27
            '50.241.173.72/29

            Dim ClientIP As String = Util.GetClientIP()
            'ClientIP = "172.16.6.168"
            'HttpContext.Current.Response.Write("ClientIP:" + ClientIP)
            'HttpContext.Current.Response.End()
            Dim ClientIPValue As Long = IP2Long(ClientIP)
      
            Dim IpList = From sq In chk(0).IPRanges Where ClientIPValue <= sq.MaxIPIntValue And ClientIPValue >= sq.MinIPIntValue
                     
            If IpList.Count = 0 Then
                HttpContext.Current.Response.StatusCode = 401 : HttpContext.Current.Response.End()
            End If
        
        
            Dim ATPRecords As New List(Of ATPRecord)
            
            For Each Plant As String In chk(0).Plants
                Dim _FormatedPartNo As String = FormatToSAPPartNo(Trim(UCase(AdvPartNo))), Inventory As Decimal = 999
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
       
                Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
                p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
                p1.Connection.Open()
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", _FormatedPartNo, Plant, "", "", "", "", "PC", _
                                      "", Inventory, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                p1.Connection.Close()
        
                For Each atpRow As GET_MATERIAL_ATP.BAPIWMDVE In atpTb
                    If atpRow.Com_Qty > 0 Then
                        Dim ATPRecord1 As New ATPRecord
                        With ATPRecord1
                            .AvailableDate = SAPDateToDate(atpRow.Com_Date) : .AvailableQty = FormatNumber(atpRow.Com_Qty, 0) : .Plant = Plant
                        End With
                  
                        ATPRecords.Add(ATPRecord1)
                    End If
                Next
            Next
            
          
            context.Response.Clear()
            context.Response.Write(jSerializer.Serialize(ATPRecords))
            context.Response.End()
        End If
    End Sub
 
    
    Public Shared Function IP2Long(ip As String) As Long
        Dim ipBytes As String()
        Dim num As Double = 0
        If Not String.IsNullOrEmpty(ip) Then
            ipBytes = ip.Split("."c)
            For i As Integer = ipBytes.Length - 1 To 0 Step -1
                num += ((Integer.Parse(ipBytes(i)) Mod 256) * Math.Pow(256, (3 - i)))
            Next
        End If
        Return CLng(num)
    End Function
    
    Public Shared Function RemovePrecedingZeros(ByVal str As String) As String
        If Not str.StartsWith("0") Then Return str
        If str.Length > 1 Then
            Return RemovePrecedingZeros(str.Substring(1))
        Else
            Return str
        End If
    End Function
    
    Public Shared Function FormatToSAPPartNo(ByVal str As String) As String
        If String.IsNullOrEmpty(Trim(str)) Then Return ""
        str = RemovePrecedingZeros(str)
        Dim IsNumericPart As Nullable(Of Boolean)
        For i As Integer = 0 To str.Length - 1
            If Not Decimal.TryParse(str.Substring(i, 1), 0) Then
                IsNumericPart = False : Exit For
            Else
                IsNumericPart = True
            End If
        Next
        If IsNumericPart = True Then
            While str.Length < 18
                str = "0" + str
            End While
        End If
        Return str
    End Function
    
    Public Shared Function SAPDateToDate(ByVal SAPDate As String) As Date
        Dim tmpDate As Date = Date.MinValue
        If Date.TryParseExact(SAPDate, "yyyyMMdd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, tmpDate) Then
            Return tmpDate
        Else
            Return Date.MaxValue
        End If
    End Function
    
    Public Class InventoryInquity
        Public Property AccessKey As String : Public Property AdvPartNo As String
    End Class
    
    Public Class ATPRecord
        Public Property AvailableDate As Date : Public Property AvailableQty As Decimal : Public Property Plant As String
    End Class
    
    Public Class ExtApiAccessRecord
        Public Property AccessKey As String : Public Property ERPId As String : Public Property OrgId As String
        Public Property Plants As List(Of String)
        Public Property IPRanges As List(Of IPRange)
        Public Sub New()
            IPRanges = New List(Of IPRange) : Plants = New List(Of String)
        End Sub
        
        Public Sub SetPlants(Plants As String)
            Me.Plants = New List(Of String)
            Dim ps() As String = Split(Plants, ";")
            For Each p In ps
                If String.IsNullOrEmpty(p) = False AndAlso Me.Plants.Contains(Trim(p)) = False Then Me.Plants.Add(UCase(Trim(p)))
            Next
        End Sub
        
    End Class
    
    Public Class IPRange
        Public Property MinIPIntValue As Long : Public Property MaxIPIntValue As Long
        Public Sub New()
            MinIPIntValue = 0 : MaxIPIntValue = 0
        End Sub
        Public Sub New(MinIp As Long, MaxIp As Long)
            MinIPIntValue = MinIp : MaxIPIntValue = MaxIp
        End Sub
    End Class
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class