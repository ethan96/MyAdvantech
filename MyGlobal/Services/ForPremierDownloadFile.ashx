<%@ WebHandler Language="VB" Class="ForPremierDownloadFile" %>

Imports System
Imports System.Web

'ICC 2015/10/26 For customer - Arrow. They want to upload and download their own datasheet.
Public Class ForPremierDownloadFile : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If Not String.IsNullOrEmpty(context.Request("RowID")) andalso context.User.Identity.IsAuthenticated = True Then
            Dim RowID As String = context.Request("RowID").ToString().Trim()
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", String.Format("select top 1 FILE_SOURCE, FILE_NAME from ADV_ARROW_DATASHEET where ROW_ID = '{0}' ", Replace(RowID, "'", "")))
            If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                Dim fileName As String = String.Empty
                Dim fbin() As Byte = Nothing
                If Not dt.Rows(0).Item("FILE_NAME") Is Nothing Then fileName = dt.Rows(0).Item("FILE_NAME").ToString()
                If Not dt.Rows(0).Item("FILE_SOURCE") Is Nothing Then fbin = dt.Rows(0).Item("FILE_SOURCE")
                
                If Not String.IsNullOrEmpty(fileName) AndAlso fbin IsNot Nothing Then
                    context.Response.ContentType = "application/octet-stream"
                    context.Response.AddHeader("Content-Disposition", String.Format("attachment; filename={0}", fileName))
                    context.Response.BinaryWrite(fbin)
                End If
            End If
            
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class