<%@ WebHandler Language="VB" Class="FileShow" %>

Imports System
Imports System.Web

Public Class FileShow : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        'context.Response.ContentType = "text/plain"
        'context.Response.Write("Hello World")
        With context
            If .Request("id") IsNot Nothing AndAlso .Request("id").ToString() <> "" Then
                Dim strFID As String = .Request("id").ToString().Trim()
                Dim MyCR As ACNCustomerFile = ACNUtil.Current.ACNContext.ACNCustomerFiles.Where(Function(P) P.ID = strFID).FirstOrDefault
                If MyCR IsNot Nothing Then
                    .Response.AddHeader("content-type", Forum_Util.FileExt2FileType(MyCR.File_Ext))
                    .Response.AddHeader("Content-Disposition", "inline;filename=" + _
                                       System.Web.HttpUtility.UrlEncode(.Request.ContentEncoding.GetBytes(MyCR.File_Name)))
                    .Response.AddHeader("content-length", MyCR.Files.Length)
                    .Response.BinaryWrite(CType(MyCR.Files.ToArray, Byte()))
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