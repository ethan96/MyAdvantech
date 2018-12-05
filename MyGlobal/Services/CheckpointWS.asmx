<%@ WebService Language="VB" Class="CheckpointWS" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantechWS")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class CheckpointWS
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty"
    End Function

    <WebMethod()> _
    Public Function GetTrackingNoBySONo(ByVal SONO As String, IsDebugging As Boolean) As DataTable
        SONO = Global_Inc.SONoBuildSAPFormat(Trim(SONO).ToUpper().Replace("'", "''"))
        Dim sql As String = _
            " select distinct a.VBELN as SO_NO, b.VBELN as DN_NO, c.BOLNR as FORWARDER_NO, d.BSTKD as PO_NO, c.LFDAT as DLV_DATE, c.KODAT as PICK_DATE  " + _
            " from saprdp.vbak a inner join saprdp.lips b on a.VBELN=b.VGBEL inner join saprdp.LIKP c on b.vbeln=c.vbeln left join saprdp.vbkd d on a.vbeln=d.vbeln  " + _
            " where a.mandt='168' and b.mandt='168' and c.mandt='168' and d.mandt='168' and a.VBELN='" + SONO + "' "
        Dim apt As New Oracle.DataAccess.Client.OracleDataAdapter(sql, New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString))
        Dim dt As New DataTable("SOTrackingNo")
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        If dt.Rows.Count > 0 Then
            For Each r As DataRow In dt.Rows
                If r.Item("FORWARDER_NO") IsNot DBNull.Value AndAlso Not String.IsNullOrEmpty(r.Item("FORWARDER_NO")) AndAlso r.Item("FORWARDER_NO").ToString().Contains("NO.") Then
                    Dim tmpFwdNo As String = r.Item("FORWARDER_NO")
                    tmpFwdNo = tmpFwdNo.Substring(tmpFwdNo.LastIndexOf("NO.") + 3)
                    r.Item("FORWARDER_NO") = tmpFwdNo
                Else
                    If IsDebugging Then r.Item("FORWARDER_NO") = "Dummy12345"
                End If
            Next
            dt.AcceptChanges()
        End If
        dt.TableName = "TrackingNo"
        Return dt
    End Function
    
    <WebMethod()> _
    Public Function GetSerialNoBySONo(ByVal SONO As String) As DataTable
        SONO = Trim(SONO).ToUpper().Replace("'", "''")
        Dim sql As String = _
            " select serial_number, mo_number, key_part_no  " + _
            " from sfism4.r_wip_tracking_t " + _
            " where mo_number like ( select vbeln||'%' as mo_number from saprdp.vbak@saprdp where vbeln = '" + SONO + "' and rownum = 1) "
        Dim apt As New Oracle.DataAccess.Client.OracleDataAdapter(sql, New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("MES").ConnectionString))
        Dim dt As New DataTable("SOSerialNo")
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function
    
    <WebMethod()> _
    Public Function GetSONoBySerialNo(ByVal SerialNo As String) As DataTable
        SerialNo = Trim(SerialNo).ToUpper().Replace("'", "''")
        If IsNumeric(SerialNo) Then
            SerialNo = "00000000" + SerialNo
        End If
        
        Dim sql As String = _
            " select distinct a.SERIAL_NUMBER,  a.SO_NO " + _
            " from SAP_INVOICE_SN_V2 a (nolock) inner join SAP_ORDER_HISTORY b (nolock) on a.SO_NO=b.SO_NO " + _
            " where b.COMPANY_ID='UZISCHE01' and a.SERIAL_NUMBER='" + SerialNo + "' order by a.SO_NO "      
        
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("MY", sql)
        dt.TableName = "SONo"
        Return dt
    End Function
    
    <WebMethod()> _
    Public Function GetTrackingNoBySONo_FromSAP(ByVal SONO As String) As DataTable
        SONO = Global_Inc.SONoBuildSAPFormat(Trim(SONO).ToUpper().Replace("'", "''"))
        Dim sql As String = _
            " select t.*,b.OBKNR AS ObjectLineSerialNo, c.SERNR as serial_number  " + _
            " from  " + _
            " (  " + _
            "     select a.vbeln as invoice_no,a.aubel as so_no, " + _
            "     (select bstnk from saprdp.vbak where vbak.vbeln=a.aubel and rownum=1 and mandt='168') as po_no,  " + _
            "     a.vgbel as dn_no, a.matnr as part_no,a.erdat as create_date,a.VGPOS,a.VGBEL, a.AUPOS as SO_LINE_NO  " + _
            "     from saprdp.vbrp a where a.mandt='168'  " + _
            " ) T inner join SAPRDP.SER01 b on T.VGBEL=b.LIEF_NR AND T.VGPOS=b.POSNR  " + _
            " inner join SAPRDP.OBJK c on b.OBKNR=c.OBKNR  " + _
            " WHERE b.mandt='168' and c.mandt='168' and T.so_no='" + SONO + "' "
        Dim apt As New Oracle.DataAccess.Client.OracleDataAdapter(sql, New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString))
        Dim dt As New DataTable("SO_SerialNo")
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function
    
End Class
