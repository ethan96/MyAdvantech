<%@ WebHandler Language="VB" Class="TIFF_Handler" %>

Imports System
Imports System.Web
Imports System.Net
Imports System.Drawing.Imaging
Imports System.IO
Imports System.Drawing

Public Class TIFF_Handler : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Try
            Dim client As New WebClient
            Dim bs() As Byte = client.DownloadData("http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + HttpContext.Current.Request("LIT_ID"))
            Dim jpg As System.Drawing.Image = System.Drawing.Image.FromStream(New MemoryStream(bs))
            Dim imgOutput As New Bitmap(jpg, jpg.Width * 0.5, jpg.Height * 0.5)
            imgOutput.Save(context.Response.OutputStream, System.Drawing.Imaging.ImageFormat.Jpeg)
            imgOutput.Dispose()
            jpg.Dispose()
        Catch ex As Exception

        End Try
        
    End Sub
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class