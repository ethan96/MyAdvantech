<%@ WebHandler Language="VB" Class="ECRss" %>

Imports System
Imports System.Web
Imports Rss

Public Class ECRss : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim ecRss As New RssChannel
        ecRss.Title = "Campaigns" : ecRss.Description = "Campaigns"
        Dim ECItems As Rss.RssItemCollection = GetECItems(IIf(IsNothing(context.Request("RBU")), "", context.Request("RBU")), IIf(IsNothing(context.Request("Enews")), "", context.Request("Enews")))
        'Dim s As String = HttpUtility.UrlEncodeUnicode(context.Request("Enews"))
        
        'context.Response.Write(HttpUtility.UrlPathEncode(context.Request("Enews")))
        'context.Response.Write(HttpUtility.UrlDecode(s))
        'context.Response.Write(context.Request.ServerVariables("QUERY_STRING"))

        For Each i As RssItem In ECItems
            ecRss.Items.Add(i)
        Next
        With ecRss
            .LastBuildDate = ecRss.Items.LatestPubDate : .Link = New Uri("http://my.advantech.eu")
            .Docs = "http://my.advantech.eu" : .Generator = "AEU IT"
        End With
        With context
            Dim feed As New RssFeed
            feed.Encoding = Encoding.UTF8
            feed.Channels.Add(ecRss)
            If ecRss.Items.Count = 0 Then
                .Response.Write(ecRss.Items.Count.ToString())
                .Response.End()
            Else
                .Response.ContentType = "text/xml"
                feed.Write(.Response.OutputStream)
                .Response.End()
            End If
        End With
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

    Private Function GetECItems(ByVal rbu As String, ByVal enews As String) As Rss.RssItemCollection
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select * from campaign_master where region='{0}' and enews=N'{1}' and actual_send_date is not null order by actual_send_date desc", rbu, enews.Replace("%20", " ").Replace("'", "''").Trim()))
        Dim rssCol As New Rss.RssItemCollection
        For Each row As DataRow In dt.Rows
            Dim item As New RssItem
            item.Title = "Camapign Name: " + row.Item("campaign_name").ToString
            item.Description = "Campaign Description: " + row.Item("description").ToString
            item.PubDate = CDate(row.Item("actual_send_date"))
            item.Link = New System.Uri("http://my-global.advantech.eu/Includes/GetTemplate.ashx?RowId=" + row.Item("row_id") + "&Email=tc.chen@advantech.com.tw")
            rssCol.Add(item)
        Next
        Return rssCol
    End Function
End Class