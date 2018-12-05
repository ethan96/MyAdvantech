<%@ WebHandler Language="VB" Class="DownloadAttachment" %>

Imports System
Imports System.Web

Public Class DownloadAttachment : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select FILE_BIN, file_ext, file_name from AONLINE_SALES_CAMPAIGN_ATTACHMENTS where row_id='{0}'", .Request("RID")))
            If dt.Rows.Count > 0 Then
                Try
                    Dim bs() As Byte = dt.Rows(0).Item("FILE_BIN")
                    If bs IsNot Nothing And Not IsDBNull(bs) Then
                        Dim file_ext As String = dt.Rows(0).Item("file_ext").ToString.ToLower
                        Dim file_name As String = dt.Rows(0).Item("file_name").ToString
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
                        .Response.AddHeader("Content-Disposition", "attachment;filename=" + file_name)
                        .Response.BinaryWrite(bs)
                    End If
                Catch ex As Exception
                    .Response.Write("File Not Found")
                End Try
            End If
            HttpContext.Current.ApplicationInstance.CompleteRequest()
        End With
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class