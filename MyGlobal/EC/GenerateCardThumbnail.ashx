<%@ WebHandler Language="VB" Class="GenerateCardThumbnail" %>

Imports System
Imports System.Web

Public Class GenerateCardThumbnail : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("RowId") IsNot Nothing Then
                Try
                    Dim obj As Object = dbUtil.dbExecuteScalar("MYLOCAL", String.Format("select top 1 template_content from christmas_send_log where row_id='{0}'", .Request("RowId")))
                    .Response.Write(obj.ToString)
                Catch ex As Exception
                    .Response.Write("Not yet maintained " + ex.ToString())
                End Try
            End If
            .Response.End()
        End With
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class