<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request("id") IsNot Nothing AndAlso Request("id").ToString() <> "" Then
            Dim strFID As String = Request("id").ToString().Trim()
            Dim MyDC As New MyChampionClubDataContext()
            Dim MyCR As ChampionClub_File = MyDC.ChampionClub_Files.Where(Function(P) P.FileID = strFID).FirstOrDefault
            If MyCR IsNot Nothing Then
                Response.AddHeader("content-type", Forum_Util.FileExt2FileType(MyCR.File_Ext))
                Response.AddHeader("Content-Disposition", "inline;filename=" + _
                                   System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(MyCR.File_Name)))
                Response.AddHeader("content-length", MyCR.FileBits.Length)
                Response.BinaryWrite(CType(MyCR.FileBits.ToArray, Byte()))
                Response.End()
            Else
                Util.JSAlert(Me.Page, "Cannot find this document on server")
            End If
        End If
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">

    </form>
</body>
</html>
