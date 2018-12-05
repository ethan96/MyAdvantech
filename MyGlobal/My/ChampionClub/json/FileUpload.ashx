<%@ WebHandler Language="VB" Class="ImgUpload" %>

Imports System
Imports System.Web
Imports System.Web.SessionState
Public Class ImgUpload : Implements IHttpHandler, IRequiresSessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "text/plain"
        'context.Response.Write("Hello World")
       Dim type As  String = context.Request("type")
        If context.Request.Files IsNot Nothing AndAlso context.Request.Files.Count > 0 Then
            If context.Request.Files(0).ContentLength < 5000000 Then
                Dim cmd As New SqlClient.SqlCommand("insert into B2BDIR_THANKYOU_LETTER_UPLOAD_FILES(File_ID,File_Name,File_Ext,File_Size,Last_Updated_Date,Last_Updated_By,Created_Date,Created_By,File_Data,File_Category,File_ContentType) " & _
                                                    "values(@File_ID,@File_Name,@File_Ext,@File_Size,@Last_Updated_Date,@Last_Updated_By,@Created_Date,@Created_By,@File_Data,@File_Category,@File_ContentType)", _
                                               New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("CP").ConnectionString))
                Dim File_ID As String = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10)
                Dim CurrentFile = context.Request.Files(0)
                Dim strFileName As String = CurrentFile.FileName
                Dim FileName As String = String.Empty, FileExt As String = String.Empty
                If CurrentFile.FileName.LastIndexOf(".") > 0 Then
                    FileExt = strFileName.Substring(strFileName.LastIndexOf(".") + 1, strFileName.Length - strFileName.LastIndexOf(".") - 1)
                    FileName = strFileName.Substring(0, strFileName.LastIndexOf("."))
                End If
  
                With cmd.Parameters
                    .AddWithValue("File_ID", File_ID) : .AddWithValue("File_Name", FileName)
                    .AddWithValue("File_Ext", FileExt) : .AddWithValue("File_Size", CurrentFile.ContentLength)
                    .AddWithValue("Last_Updated_Date", Now) : .AddWithValue("Last_Updated_By", context.User.Identity.Name)
                    .AddWithValue("Created_Date", Now) : .AddWithValue("Created_By", context.User.Identity.Name)
                    .AddWithValue("File_Data", StreamToBytes(context.Request.Files(0).InputStream)) : .AddWithValue("File_Category", 1)
                    .AddWithValue("File_ContentType", CurrentFile.ContentType)
                End With
                cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
                'e.PostedUrl = Util.GetRuntimeSiteUrl + "/EC/FwdEDMImg.ashx?ID=" + strImgId
                
                Dim serializer = New Script.Serialization.JavaScriptSerializer()
                Dim json As String = serializer.Serialize(New With {Key .filelink = Util.GetRuntimeSiteUrl + "/My/ChampionClub/json/ShowFile.ashx?File_ID=" + File_ID})
                context.Response.Write(json)
                
            End If
        End If
    End Sub
    Public Function StreamToBytes(ByVal stream As IO.Stream) As Byte()
        Dim bytes As Byte() = New Byte(stream.Length - 1) {}
        stream.Read(bytes, 0, bytes.Length)
        ' 设置当前流的位置为流的开始 
        stream.Seek(0, IO.SeekOrigin.Begin)
        Return bytes
    End Function
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class