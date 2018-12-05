<%@ WebHandler Language="VB" Class="RecLink" %>

Imports System
Imports System.Web

Public Class RecLink : Implements IHttpHandler, IReadOnlySessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("RECID") IsNot Nothing AndAlso .Request("RECID") <> "" Then
                Dim o As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 hyper_link from www_resources where record_id='{0}' and hyper_link like 'http://%.%'", Trim(.Request("RECID")).Replace("'", "''")))
                If o IsNot Nothing Then
                    .Response.Redirect(o.ToString, False)
                Else
                    .Response.Clear()
                    .Response.Write("Requested resource does not exist")
                    .Response.End()
                End If
            End If
        End With
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class