<%@ WebHandler Language="VB" Class="dl_intel_file" %>

Imports System
Imports System.Web

Public Class dl_intel_file : Implements IHttpHandler, IReadOnlySessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("fid") IsNot Nothing Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("MyLocal", _
                String.Format("select top 1 file_bin, file_ext, file_name from INTEL_PORTAL_FILES where row_id='" + .Request("fid") + "' and file_bin is not null"))
                If dt.Rows.Count = 1 Then
                    .Response.Clear()
                    .Response.ContentType = dt.Rows(0).Item("file_ext")
                    .Response.AddHeader("Content-Disposition", String.Format("attachment; filename={0};", HttpUtility.UrlEncode(dt.Rows(0).Item("file_name"))))
                    .Response.BinaryWrite(dt.Rows(0).Item("file_bin"))
                    .Response.End()
                Else
                    '.Response.Redirect("http://www.advantech.eu/images/logo_advantech.gif")
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