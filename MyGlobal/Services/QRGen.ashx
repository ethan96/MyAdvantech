<%@ WebHandler Language="VB" Class="QRGen" %>

Imports System
Imports System.Web

Public Class QRGen : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If context.Request("Text") IsNot Nothing Then
            Dim license As Aspose.BarCode.License = New Aspose.BarCode.License()
            Dim strFPath As String = HttpContext.Current.Server.MapPath("~/Files/Aspose.Total.lic")
            license.SetLicense(strFPath)
            Dim QRText As String = Trim(context.Request("Text"))
            QRText = "MyAdvantech " + QRText
            Dim intW As Single = 100, intH As Single = 100
            'If Not Single.TryParse(context.Request("Width"), intW) Then
            '    intW = 100
            'End If
            'If Not Single.TryParse(context.Request("Height"), intH) Then
            '    intH = 100
            'End If
            Dim mStream As System.IO.MemoryStream = New System.IO.MemoryStream()
            Dim b As New Aspose.BarCode.BarCodeBuilder
            With b
                .Resolution = New Aspose.BarCode.Resolution(intW, intH, Aspose.BarCode.ResolutionMode.Customized)
                .SymbologyType = Aspose.BarCode.Symbology.QR
                'Dim byteArray As Byte() = Encoding.UTF8.GetBytes("中文")
                '.SetCodeText(byteArray)
                .CodeText = QRText
                .CodeLocation = Aspose.BarCode.CodeLocation.None
                .QRErrorLevel = Aspose.BarCode.QRErrorLevel.LevelH
                '.ImageQuality = Aspose.BarCode.ImageQualityMode.AntiAlias              
                b.BarCodeImage.Save(mStream, System.Drawing.Imaging.ImageFormat.Gif)
            End With
            context.Response.Clear()
            context.Response.ContentType = "image/gif"
            context.Response.BinaryWrite(mStream.ToArray())
            mStream.Close()
            context.Response.End()
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class