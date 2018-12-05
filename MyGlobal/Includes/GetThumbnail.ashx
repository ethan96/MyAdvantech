<%@ WebHandler Language="VB" Class="GetThumbnail" %>

Imports System
Imports System.Web
Imports System.Drawing

Public Class GetThumbnail : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("RowId") IsNot Nothing Then
                Dim obj As Byte()
                Dim connMY As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                Select Case .Request("Type")
                    Case "Catalog"
                        Dim cmd As New SqlClient.SqlCommand(" select thumbnail from forecast_catalog_list where row_id=@RID and thumbnail is not null", connMY)
                        cmd.Parameters.AddWithValue("RID", .Request("RowId"))
                        connMY.Open()
                        obj = cmd.ExecuteScalar()
                        'obj = dbUtil.dbExecuteScalar("MY", String.Format("select thumbnail from forecast_catalog_list where row_id='{0}' and thumbnail is not null", .Request("RowId")))
                    Case Else
                        Dim cmd As New SqlClient.SqlCommand(" select thumbnail from campaign_thumbnail where campaign_row_id=@CID", connMY)
                        cmd.Parameters.AddWithValue("CID", .Request("RowId"))
                        connMY.Open()
                        obj = cmd.ExecuteScalar()
                        'obj = dbUtil.dbExecuteScalar("RFM", String.Format("select thumbnail from campaign_thumbnail where campaign_row_id='{0}'", .Request("RowId")))
                End Select
                connMY.Close()
                If obj IsNot Nothing And Not IsDBNull(obj) Then
                    HttpContext.Current.Response.Clear()
                    HttpContext.Current.Response.ContentType = "image/Jpg"
                    HttpContext.Current.Response.BinaryWrite(obj)
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