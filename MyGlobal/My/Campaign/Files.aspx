<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request("id") IsNot Nothing AndAlso Request("id").ToString() <> "" Then
            Dim strFID As String = Request("id").ToString().Trim()
            Dim MyDC As New MyCampaignDBDataContext()
            Dim MyCR As CAMPAIGN_REQUEST_Expand = MyDC.CAMPAIGN_REQUEST_Expands.Where(Function(P) P.ID = strFID).FirstOrDefault
            If MyCR IsNot Nothing Then
                Response.AddHeader("content-type", Forum_Util.FileExt2FileType(MyCR.File_Ext))
                Response.AddHeader("Content-Disposition", "inline;filename=" + _
                                   System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(MyCR.File_Name)))
                Response.AddHeader("content-length", MyCR.Files.Length)
                Response.BinaryWrite(CType(MyCR.Files.ToArray, Byte()))
                Response.End()
            Else
                Util.JSAlert(Me.Page, "Cannot find this document on server")
            End If
        End If
    End Sub
    Public Sub BindGvFiles()
        'Dim MyDC As New MyCampaignDBDataContext()
        'Dim MyCR As CAMPAIGN_REQUEST = MyDC.CAMPAIGN_REQUESTs.Where(Function(P) P.REQUESTNO = Request("REQUESTNO")).FirstOrDefault
        'If MyCR IsNot Nothing Then
        '    GvFiles.DataSource = MyCR.CAMPAIGN_REQUEST_Expands.Where(Function(P) P.File_Ext IsNot Nothing).ToList
        '    GvFiles.DataBind()
        'End If
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <asp:GridView runat="server" ID="GvFiles" AutoGenerateColumns="false" Width="200" ShowHeader="false">
        <Columns>
            <asp:BoundField HeaderText="File Name" DataField="File_Name" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Create By" DataField="File_CreateBy" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Create Time" DataField="File_CreateTime" DataFormatString="{0:yyyy-MM-dd}"
                ItemStyle-HorizontalAlign="Center" />
        </Columns>
    </asp:GridView>
    </form>
</body>
</html>
