<%@ WebHandler Language="VB" Class="PRM" %>

Imports System
Imports System.Web

Public Class PRM : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim returnValue As Boolean = False
        Dim ClientIp = Util.GetClientIP()
        If context.Request("optyid") IsNot Nothing AndAlso (ClientIp.StartsWith("172.1") Or ClientIp = "::1") Then
            Dim rnd As New Random()
            Threading.Thread.Sleep(rnd.Next(100, 999))  'Avoid bulk invoke
            '20160621 TC: Create a WS for Siebel team to invoke, when an oppty is created on Siebel and let Siebel inform MyA to trigger email notice to CP
            'select from CRM DB to see if this oppty exists and ineed one that is assigned to CP
            'To-be implemented by IC/Ryan
            Dim dtOpty As New DataTable
            Dim sql As String = _
                " select A.NAME, A.ROW_ID " + _
                " from S_OPTY A inner join S_OPTY_X X on A.ROW_ID=X.ROW_ID  " + _
                " left outer join  S_STG B on A.CURR_STG_ID = B.ROW_ID left outer join  S_BU C on A.BU_ID = C.ROW_ID  " + _
                " left outer join  S_POSTN D on A.PR_POSTN_ID = D.ROW_ID left outer join  S_USER E on A.CREATED_BY = E.ROW_ID  " + _
                " left outer join  S_USER F on A.LAST_UPD_BY = F.ROW_ID left outer join  S_USER I on D.PR_EMP_ID = I.ROW_ID  " + _
                " left outer join  S_OPTY_T SC on SC.PAR_ROW_ID = A.ROW_ID left outer join  S_OPTY_CON CON on CON.OPTY_ID = A.ROW_ID  " + _
                " where A.SUM_WIN_PROB between 1 and 99 and X.ATTRIB_10='Y' and A.ROW_ID=@OPTYID "
            Dim SiebelApt As New SqlClient.SqlDataAdapter(sql, ConfigurationManager.ConnectionStrings("CRM").ConnectionString)
            SiebelApt.SelectCommand.Parameters.AddWithValue("OPTYID", Trim(context.Request("optyid")))
            SiebelApt.Fill(dtOpty)
            SiebelApt.SelectCommand.Connection.Close()
            If dtOpty.Rows.Count > 0 Then
                returnValue = True
            End If
        End If
        context.Response.Write(returnValue.ToString())
        context.Response.End()
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class