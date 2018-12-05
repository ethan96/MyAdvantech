<%@ WebHandler Language="VB" Class="ShowFile" %>

Imports System
Imports System.Web

Public Class ShowFile : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        With context
            If .Request("File_ID") IsNot Nothing AndAlso .Request("File_ID").ToString() <> "" Then
                Dim strFID As String = .Request("File_ID").ToString().Trim()
                Dim fdt As DataTable = dbUtil.dbGetDataTable("CP", String.Format( _
                " SELECT top 1 File_ID,File_Name,File_Ext,File_Size,File_Data,File_ContentType " + _
                " FROM B2BDIR_THANKYOU_LETTER_UPLOAD_FILES where File_ID='{0}' and File_Data is not null and File_Name<>'' and File_Ext<>'' ", strFID))
                If fdt.Rows.Count = 1 Then
                    Dim r As DataRow = fdt.Rows(0)
                    If Not String.Equals(r.Item("File_ContentType"), "image/jpeg", StringComparison.CurrentCultureIgnoreCase) Then
                        Dim cmd As New SqlClient.SqlCommand("insert into ChampionClub_Track([File_ID],[Visitor],[Visitor_IP],[Visitor_Date]) " & _
                                                    "values(@File_ID,@Visitor,@Visitor_IP,@Visitor_Date)", _
                                               New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("CP").ConnectionString))
                        Dim Visitor As String = String.Empty, File_ID As String = String.Empty
                        With cmd.Parameters
                            If context.Request("UID") IsNot Nothing Then Visitor = context.Request("UID")
                            If context.Request("File_ID") IsNot Nothing Then File_ID = context.Request("File_ID")
                            .AddWithValue("File_ID", File_ID) : .AddWithValue("Visitor", Visitor)
                            .AddWithValue("Visitor_IP", Util.GetClientIP()) : .AddWithValue("Visitor_Date", Now)
                        End With
                        cmd.Connection.Open()
                        Try
                            cmd.ExecuteNonQuery()
                        Catch ex As Exception
                            Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Insert ChampionClub_Prize_Track Failed", Visitor + vbCrLf + File_ID + vbCrLf + ex.ToString, True, "", "")
                        End Try
                        cmd.Connection.Close()
                    End If
                    Dim FileNameFull = r.Item("File_Name") + "." + r.Item("File_Ext")
                    .Response.AddHeader("content-type", r.Item("File_ContentType") + ";")
                    .Response.AddHeader("Content-Disposition", "inline;filename=" + _
                                       System.Web.HttpUtility.UrlEncode(.Request.ContentEncoding.GetBytes(FileNameFull)))
                    .Response.AddHeader("content-length", r.Item("File_Size"))
                    .Response.BinaryWrite(r.Item("File_Data"))
                    .Response.End()
                Else
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