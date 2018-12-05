<%@ WebHandler Language="VB" Class="SimpleTrend" %>

Imports System
Imports System.Web
Imports Aspose.Chart
Imports System.IO
Imports System.Drawing.Imaging

Public Class SimpleTrend : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If context.Request("DOTS") Is Nothing Then Exit Sub
        Dim ds() As String = Split(Trim(context.Request("DOTS")), ",")
        Dim reg As New Regression, xv(ds.Length - 1) As Double, yv(ds.Length - 1) As Double
        Dim license As New Aspose.Chart.License
        Try
            license.SetLicense(HttpContext.Current.Server.MapPath("~/Files/Aspose.Total.lic"))
        Catch ex As Exception
            'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Error set aspose license", ex.ToString(), False, "", "")
        End Try
        Dim c As Chart = New Chart
        c.Width = 250 : c.Height = 100
        c.ChartArea.LegendBox.IsVisible = False
        c.ChartArea.AxisX.IsVisible = False : c.ChartArea.AxisY.IsVisible = False
        'c.ChartArea.AxisX.Interval = 1000
        Dim s As Series = New Series, s2 As New Series
        s.ChartType = ChartType.Line : s2.ChartType = ChartType.Line
        For i As Integer = 0 To ds.Length - 1
            s.DataPoints.Add(New DataPoint("", (2005 + i).ToString(), CDbl(ds(i))))
            xv(i) = i : yv(i) = CDbl(ds(i))
        Next
        Dim regInfo As RegressionProcessInfo = reg.Regress(xv, yv)
        For i As Integer = 0 To ds.Length - 1
            s2.DataPoints.Add(New DataPoint("", (2005 + i), regInfo.a + regInfo.b * (i + 1)))
        Next
        c.SeriesCollection.Add(s) : c.SeriesCollection.Add(s2)
        Dim ms As MemoryStream = New MemoryStream
        c.Save(ms, ImageFormat.Png) : context.Response.Clear() : context.Response.ContentType = "image/png"
        context.Response.OutputStream.Write(ms.ToArray(), 0, ms.Length)
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class