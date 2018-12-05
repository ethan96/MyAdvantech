<%@ WebService Language="VB" Class="CreateSAPSoForeStore" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports SAPDAL
' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace := "http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _  
Public Class CreateSAPSoForeStore
    Inherits System.Web.Services.WebService 
    <WebMethod()> _
    Public Function CreateSO(ByRef refDoc_Number As String, ByRef org_id As String, ByRef ErrMsg As String, _
                            ByRef OrderHeaderDt As SalesOrder.OrderHeaderDataTable, _
                            ByRef OrderLineDt As SalesOrder.OrderLinesDataTable, _
                            ByRef PartnerFuncDT As SalesOrder.PartnerFuncDataTable, _
                            ByRef ConditionDT As SalesOrder.ConditionDataTable, _
                            ByRef HeaderTextsDt As SalesOrder.HeaderTextsDataTable, _
                            ByRef CreditCardDT As SalesOrder.CreditCardDataTable, _
                            ByRef retDataTableDT As DataTable) As Boolean
        
        If refDoc_Number = "" Then ErrMsg = "NO ORDER NO!" : Return False
        If OrderHeaderDt.Rows.Count <= 0 Then ErrMsg = "NO HEADER!" : Return False
        If OrderLineDt.Rows.Count <= 0 Then ErrMsg = "NO DETAIL!" : Return False
        '\ 20140825 欧洲Btos Parent Item FirstDate 设置成 2020-12-31, Order Type = "ZOR6"
        Dim _IsHasBTOS As Boolean = False
        If String.Equals(org_id, "EU") Then
            For Each dr As SalesOrder.OrderLinesRow In OrderLineDt.Rows
                Dim _lineno As Integer = Integer.Parse(dr.LINE_NO)
                If OrderLineDt.Select(String.Format("HIGHER_LEVEL='{0}'", _lineno)).Length > 0 Then
                    dr.REQ_DATE = "2020/12/31"
                    _IsHasBTOS = True
                End If
            Next
            If _IsHasBTOS Then
                Dim dr As SalesOrder.OrderHeaderRow = OrderHeaderDt.Rows(0)
                dr.ORDER_TYPE = "ZOR6"
            End If
        End If
        '/end 

        'ICC 2015/6/10 To ensure material no is capital
        For Each dr As SalesOrder.OrderLinesRow In OrderLineDt.Rows
            dr.MATERIAL = SAPDAL.SAPDAL.FormatToSAPPartNo(dr.MATERIAL.Trim().ToUpper())
            dr.AcceptChanges()
        Next
      
        If PartnerFuncDT.Rows.Count <= 0 Then ErrMsg = "NO PARTNER FUNC!" : Return False
        Dim LocalTime As DateTime = SAPDOC.GetLocalTime(org_id)
        Dim filename As String = refDoc_Number + "_" + org_id + "_" + DateTime.Now.ToString("yyyyMMddHHmmssfff") + ".xml"
        Dim ret As Boolean = False
        Dim WS As New SAPDAL.SAPDAL
        ret = WS.CreateSO(refDoc_Number, ErrMsg, OrderHeaderDt, OrderLineDt, PartnerFuncDT, ConditionDT, HeaderTextsDt, CreditCardDT, retDataTableDT, LocalTime)
        ' log 
        Try
            Dim ds As New DataSet
            ds.Tables.Add(OrderHeaderDt)
            ds.Tables.Add(OrderLineDt)
            ds.Tables.Add(PartnerFuncDT)
            ds.Tables.Add(ConditionDT)
            ds.Tables.Add(HeaderTextsDt)
            ds.Tables.Add(CreditCardDT)
            ds.Tables.Add(retDataTableDT)
            ds.GetXml()
            Dim xdoc As New System.Xml.XmlDocument()
            xdoc.LoadXml(ds.GetXml())
            Dim file As String = "D:\eStoreCreateSOlog\" + filename
            xdoc.Save(file)
        Catch ex As Exception

        End Try

        '
        Return ret
    End Function
    
    <WebMethod()> _
    Public Function eStoreSSOLoginAndCalPoint(ByVal userid As String, ByVal key As String, ByVal test As Boolean) As Decimal
        'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" select RecordType,TotalPoint from RewardRecord where UserID= '{0}' and RecordType in (1,2)", userid))
        'Dim points As Decimal = 0
        'If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
        '    For Each dr As DataRow In dt.Rows
        '        If Convert.ToInt32(dr.Item("RecordType").ToString()) = 1 Then
        '            points += Convert.ToDecimal(dr.Item("TotalPoint").ToString())
        '        ElseIf Convert.ToInt32(dr.Item("RecordType").ToString()) = 2 Then
        '            points -= Convert.ToDecimal(dr.Item("TotalPoint").ToString())
        '        End If
        '    Next
        'End If
        dbUtil.dbExecuteNoQuery("MY", String.Format("insert into RewardSSO values('{0}', 'ATW', '{1}', '{1}', GETDATE())", key, userid))
        Return 0D
    End Function
End Class
