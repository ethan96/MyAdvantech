<%@ WebHandler Language="VB" Class="SpecialMaterialDownload" %>

Imports System
Imports System.Web
Imports System.Net

Public Class SpecialMaterialDownload : Implements IHttpHandler, IReadOnlySessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("LIT_ID") IsNot Nothing Then
                If HttpContext.Current.Request.IsAuthenticated Then
                    Dim obj As Object = dbUtil.dbExecuteScalar("PIS", String.Format("exec PIS.dbo.getDwonloadURL '{0}'", .Request("LIT_ID")))
                    If obj IsNot Nothing Then
                        Dim client As New WebClient
                        Try
                            Dim bs() As Byte = client.DownloadData("http://download.advantech.com" + obj.ToString)
                            If bs IsNot Nothing And Not IsDBNull(bs) Then
                                Dim file_ext As String = "", lit_type As String = "", file_name As String = ""
                                Dim dt As DataTable = dbUtil.dbGetDataTable("PIS", String.Format("select top 1 lit_type, isnull(file_ext,'') as file_ext, isnull(file_name,'') as file_name from literature where literature_id='{0}'", .Request("LIT_ID")))
                                If dt.Rows.Count > 0 Then
                                    file_ext = dt.Rows(0).Item("file_ext").ToString.ToLower
                                    lit_type = dt.Rows(0).Item("lit_type").ToString.ToLower
                                    file_name = dt.Rows(0).Item("file_name").ToString
                                End If
                                If lit_type = "product - sales kit" And .Session("account_status").ToString() <> "EZ" Then
                                    .ApplicationInstance.CompleteRequest()
                                ElseIf (lit_type = "product - roadmap" OrElse lit_type = "presentation (for cp only)") AndAlso .Session("account_status").ToString() <> "EZ" _
                                    AndAlso .Session("account_status").ToString() <> "CP" Then
                                    .ApplicationInstance.CompleteRequest()
                                End If
                                .Response.Clear()
                                Select Case file_ext
                                    Case "ppt", "pptx"
                                        .Response.ContentType = "application/vnd.ms-powerpoint"
                                    Case "doc", "docx"
                                        .Response.ContentType = "application/msword"
                                    Case "xls", "xlsx"
                                        .Response.ContentType = "application/vnd.ms-excel"
                                    Case "pdf"
                                        .Response.ContentType = "application/pdf"
                                    Case "zip"
                                        .Response.ContentType = "application/x-zip-compressed"
                                    Case "rar"
                                        .Response.ContentType = "application/octet-stream"
                                    Case "swf"
                                        .Response.ContentType = "application/x-shockwave-flash"
                                    Case "rtf"
                                        .Response.ContentType = "application/rtf"
                                    Case "tif", "tiff"
                                        .Response.ContentType = "image/tiff"
                                    Case "bmp"
                                        .Response.ContentType = "image/bmp"
                                    Case "gif"
                                        .Response.ContentType = "image/gif"
                                    Case "jpe", "jpeg", "jpg"
                                        .Response.ContentType = "image/jpeg"
                                    Case "png"
                                        .Response.ContentType = "image/png"
                                End Select
                                .Response.AddHeader("Content-Disposition", "attachment;filename=" + file_name + "." + file_ext)
                                .Response.BinaryWrite(bs)
                            End If
                        Catch ex As Exception
                            .Response.Write("File Not Found")
                        End Try
                    End If
                End If
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