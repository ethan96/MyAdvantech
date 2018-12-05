<%@ WebHandler Language="VB" Class="ChristmasImg" %>

Imports System
Imports System.Web

Public Class ChristmasImg : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("RowId") IsNot Nothing Then
                Dim dic As Dictionary(Of String, Byte()) = System.Web.HttpRuntime.Cache("eCardCache")
                If dic Is Nothing Then
                    dic = New Dictionary(Of String, Byte())
                    Dim onRemove As CacheItemRemovedCallback = New CacheItemRemovedCallback(AddressOf RemovedCallback)
                    HttpContext.Current.Cache.Add("eCardCache", dic, Nothing, DateTime.Now.AddDays(1), Caching.Cache.NoSlidingExpiration, CacheItemPriority.High, onRemove)
                End If
                
                Dim obj As Byte() = Nothing
                If dic.ContainsKey(.Request("RowId")) Then
                    dic.TryGetValue(.Request("RowId"), obj)
                Else
                    obj = dbUtil.dbExecuteScalar("MY", String.Format("select image_byte from christmas_card where row_id='{0}'", .Request("RowId")))
                    dic.Add(.Request("RowId"), obj)
                End If
                If obj IsNot Nothing Then
                    HttpContext.Current.Response.Clear()
                    HttpContext.Current.Response.ContentType = "image/Jpg"
                    HttpContext.Current.Response.BinaryWrite(obj)
                End If
            End If
        End With
    End Sub
    Private itemRemoved As Boolean = False
    Private reason As CacheItemRemovedReason
    Protected Sub RemovedCallback(ByVal k As String, ByVal v As Object, ByVal r As CacheItemRemovedReason)
        itemRemoved = True
        reason = r
    End Sub
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class