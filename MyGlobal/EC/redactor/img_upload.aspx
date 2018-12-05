<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If User.Identity.IsAuthenticated = False Then Response.Redirect("../../home.aspx")
        
        If Request.Files IsNot Nothing AndAlso Request.Files.Count > 0 Then
            If Request.Files(0).ContentLength < 5000000 Then
                Dim cmd As New SqlClient.SqlCommand("insert into CurationPool.dbo.FWD_EDM_IMG (ROW_ID, UPLOADED_BY, FILE_NAME, FILE_BIN, EDM_ID) values(@ROWID,@UID,@FNAME,@FBIN,@EDMID)", _
                                               New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
                Dim strImgId As String = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10)
                With cmd.Parameters
                    .AddWithValue("ROWID", strImgId) : .AddWithValue("UID", User.Identity.Name) : .AddWithValue("FNAME", Request.Files(0).FileName)
                    .AddWithValue("FBIN", StreamToBytes(Request.Files(0).InputStream)) : .AddWithValue("EDMID", "")
                End With
                cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
                'e.PostedUrl = Util.GetRuntimeSiteUrl + "/EC/FwdEDMImg.ashx?ID=" + strImgId
                
                Dim serializer = New Script.Serialization.JavaScriptSerializer()
                Dim json As String = serializer.Serialize(New With {Key .filelink = Util.GetRuntimeSiteUrl + "/EC/FwdEDMImg.ashx?ID=" + strImgId})
                Response.Write(json)
                
            End If
        End If
        
      
        
        
    End Sub
    
    Public Function StreamToBytes(stream As IO.Stream) As Byte()
        Dim bytes As Byte() = New Byte(stream.Length - 1) {}
        stream.Read(bytes, 0, bytes.Length)
        ' 设置当前流的位置为流的开始 
        stream.Seek(0, IO.SeekOrigin.Begin)
        Return bytes
    End Function
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
