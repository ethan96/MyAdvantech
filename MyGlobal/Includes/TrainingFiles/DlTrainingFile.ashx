<%@ WebHandler Language="VB" Class="DlTrainingFile" %>

Imports System
Imports System.Web

Public Class DlTrainingFile : Implements IHttpHandler, IReadOnlySessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If context.Request("upid") IsNot Nothing AndAlso context.Request("fid") IsNot Nothing Then
            context.Response.Clear()
            Dim email As String = HttpContext.Current.Session("user_id")
            Dim upid As String = context.Request("upid"), fid As String = context.Request("fid")
            Dim fdt As DataTable = dbUtil.dbGetDataTable("BigFiles", _
                String.Format("select FILE_NAME, FILE_TYPE, FILE_BIN, TO_ALL from TRAINING_FILES where upload_id='{0}' and file_id='{1}'", upid, fid))
            If fdt.Rows.Count > 0 Then
                'Dim isToAll As Integer = fdt.Rows(0).Item("TO_ALL")
                'Dim chk As Object = dbUtil.dbExecuteScalar("BigFiles", _
                '" select count(b.EMAIL) from TRAINING_FILES a inner join TRAINING_FILE_PERMISSION b " + _
                '" on a.UPLOAD_ID=b.UPLOAD_ID where a.UPLOAD_ID='" + upid + "' " + _
                '" and (a.UPLOADED_BY='" + email + "' or b.EMAIL='" + email + "') ")
                If True Then
                    dbUtil.dbExecuteNoQuery("BigFiles", _
                                      " INSERT INTO TRAINING_DOWNLOAD_LOG (FILE_ID, EMAIL, DOWNLOAD_TIME) " + _
                                      " VALUES (N'" + fid + "', N'" + context.Session("user_id") + "', GETDATE())")
                    context.Response.HeaderEncoding = System.Text.Encoding.GetEncoding("big5")
                    context.Response.ContentType = "application/octet-stream"
                    'If context.Response.ContentType.StartsWith(".") AndAlso context.Response.ContentType.Length > 1 Then context.Response.ContentType = context.Response.ContentType.Substring(1)
                    context.Response.AddHeader("Content-disposition", String.Format("attachment;filename={0};", HttpUtility.UrlEncode(fdt.Rows(0).Item("FILE_NAME"))))
                    context.Response.BinaryWrite(fdt.Rows(0).Item("FILE_BIN"))
                Else
                    context.Response.Write("Sorry, you do not have permission to download requested file")
                End If
            Else
                context.Response.Write("Sorry, requested file is either invalid or has been deleted")
            End If
            context.Response.End()
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class