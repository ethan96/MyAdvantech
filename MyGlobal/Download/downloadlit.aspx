﻿<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Download Files" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack AndAlso _
            ( _
                (Request("lit_id") IsNot Nothing AndAlso Request("lit_id") <> "") _
                OrElse _
                (Request("pn") IsNot Nothing AndAlso Request("pn") <> "") _
            ) Then
            Dim litid As String = ""
            If Request("lit_id") IsNot Nothing AndAlso Request("lit_id") <> "" Then
                litid = Trim(Request("lit_id")).Replace("'", "")
            Else
                Dim tmpLitId As Object = dbUtil.dbExecuteScalar("MY", _
                String.Format("select top 1 tumbnail_image_id from PRODUCT_FULLTEXT_NEW where part_no='{0}' and tumbnail_image_id is not null", Trim(HttpUtility.UrlEncode(Request("pn"))).Replace("'", "")))
                If tmpLitId IsNot Nothing Then
                    litid = tmpLitId
                End If
            End If
            
            Dim bs() As Byte = Nothing, IsNew As Boolean = False
            bs = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 LIT_FILE from SIEBEL_LIT_CACHE where DATEDIFF(HH,CACHE_DATE,GETDATE())<=12 and row_id='{0}' and LIT_FILE is not null", litid))
            If bs Is Nothing Then
                bs = GetRemoteImgWidthHeight(String.Format("http://{0}/download/downloadlit.aspx?lit_id={1}", _
                                                           "download.advantech.com", litid), 0, 0)
                If bs Is Nothing Then
                    bs = GetRemoteImgWidthHeight(String.Format("http://{0}/download/downloadlit.aspx?lit_id={1}", _
                                                           "downloadt.advantech.com", litid), 0, 0)
                End If
                IsNew = True
            End If
            If bs IsNot Nothing Then
                If IsNew Then
                    Dim g_adoConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                    Dim dbCmd As SqlClient.SqlCommand = g_adoConn.CreateCommand()
                    dbCmd.Connection = g_adoConn : dbCmd.CommandText = String.Format("delete from siebel_lit_cache where row_id='{0}'", litid)
                    g_adoConn.Open()
                    Try
                        dbCmd.ExecuteNonQuery()
                        dbCmd.CommandText = String.Format("INSERT INTO SIEBEL_LIT_CACHE (ROW_ID, LIT_FILE) VALUES ('{0}',@FILE)", litid)
                        Dim p As New SqlClient.SqlParameter("FILE", SqlDbType.VarBinary)
                        p.Value = bs
                        dbCmd.Parameters.Add(p)
                        dbCmd.ExecuteNonQuery()
                    Catch ex As Exception
                        g_adoConn.Close() : Throw ex
                    End Try
                    g_adoConn.Close()
                End If
                Response.Clear()
                Response.AppendHeader("Content-disposition", "attachment; filename=" + litid + ".GIF")
                Response.ContentType = "image/" + litid + ".GIF"
                Response.BinaryWrite(bs)
                Response.End()
            End If
        End If
    End Sub
    
    Function GetRemoteImgWidthHeight(ByVal imgurl As String, ByRef w As Integer, ByRef h As Integer) As Byte()
        Dim bs() As Byte
        Dim wc As New System.Net.WebClient
        Try
            bs = wc.DownloadData(imgurl)
        Catch ex As Exception
            Return Nothing
        End Try
        Try
            Dim objImage As System.Drawing.Image = System.Drawing.Image.FromStream(New IO.MemoryStream(bs))
            w = objImage.Width : h = objImage.Height
            Return bs
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
</asp:Content>