<%@ WebHandler Language="VB" Class="FwdEDMImg" %>

Imports System
Imports System.Web

Public Class FwdEDMImg : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("ID") IsNot Nothing Then
                Dim cmd As New SqlClient.SqlCommand("select top 1 FILE_BIN from CurationPool.dbo.FWD_EDM_IMG where ROW_ID=@RID", _
                                                    New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
                cmd.Parameters.AddWithValue("RID", .Request("ID"))
                cmd.Connection.Open()
                Dim obj As Object = cmd.ExecuteScalar()
                cmd.Connection.Close()
                If obj IsNot Nothing Then
                    .Response.Clear()
                    .Response.ContentType = "image/JPEG"
                    .Response.BinaryWrite(CType(obj, Byte()))
                    .Response.End()
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