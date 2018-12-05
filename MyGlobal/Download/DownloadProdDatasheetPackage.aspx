<%@ Page Language="VB" %>

<%@ Import Namespace="System.IO" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        '20140206 TC: delete old cache to improve select speed
        dbUtil.dbExecuteNoQuery("MY", "delete from  PACKAGE_PRODUCT_DATASHEET_CACHE  where Cached_Date<GETDATE()-30")
        Dim _PackageID As String = Request("PackageID")

        If String.IsNullOrEmpty(_PackageID) Then
            'Response.Redirect("~\home.asp")
            Exit Sub
        End If
        
        'Dim _apt As New PISDSTableAdapters.PACKAGE_PRODUCT_DATASHEET_CACHETableAdapter
        'Dim _dt As PISDS.PACKAGE_PRODUCT_DATASHEET_CACHEDataTable = _apt.GetDataByPackageID(_PackageID)
        'If _dt Is Nothing OrElse _dt.Rows.Count = 0 Then Exit Sub
        
        'Dim _row As PISDS.PACKAGE_PRODUCT_DATASHEET_CACHERow = _dt.Rows(0)
        
        Dim strSql As String = _
                  String.Format("Select File_Bytes from PACKAGE_PRODUCT_DATASHEET_CACHE where PackageID='{0}'", _PackageID)
        Dim odt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
        If odt Is Nothing OrElse odt.Rows.Count = 0 Then Exit Sub
        
        Dim fileData() As Byte = DirectCast(odt.Rows(0)("File_Bytes"), Byte())
       
        'Dim fileData() As Byte = _row.File_Bytes
        Response.ClearContent()
        Response.AddHeader("Content-Disposition", "attachment; filename=" & _PackageID & ".zip")
        Dim bw As BinaryWriter = New BinaryWriter(Response.OutputStream)
        bw.Write(fileData)
        bw.Close()
        Response.ContentType = ".zip"
        Response.End()
        
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
