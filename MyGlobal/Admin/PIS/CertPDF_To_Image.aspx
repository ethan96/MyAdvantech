<%@ Page Title="MyAdvantech - Extract cover page from Certificate PDF file" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request("pagenum") IsNot Nothing AndAlso Integer.TryParse(Request("pagenum"), 0) _
            AndAlso CInt(Request("pagenum")) > 0 AndAlso Request("fid") IsNot Nothing Then
            Dim UploadedPDFFiles As Dictionary(Of String, String) = HttpContext.Current.Cache("UploadedPDFFiles")
            If UploadedPDFFiles IsNot Nothing AndAlso UploadedPDFFiles.ContainsKey(Request("fid")) Then
                Dim strFilePath As String = UploadedPDFFiles.Item(Request("fid"))
                'Dim pdfMS As New IO.MemoryStream(CType(ViewState("pdfFileBytes"), Byte()))
                Dim intReqPageNum As Integer = CInt(Request("pagenum"))
                Dim lic As New Aspose.Pdf.Kit.License() : lic.SetLicense(HttpContext.Current.Server.MapPath("~/Files/Aspose.Total.lic"))
                Dim viewer As New Aspose.Pdf.Kit.PdfViewer
                viewer.OpenPdfFile(strFilePath)
                Dim bm As Drawing.Bitmap = Nothing
                bm = viewer.DecodePage(intReqPageNum)
                viewer.ClosePdfFile()
                Dim bms As New IO.MemoryStream()
                bm.Save(bms, System.Drawing.Imaging.ImageFormat.Jpeg)
                Dim bb() As Byte = bms.ToArray()
                Context.Response.CacheControl = "no-cache"
                Context.Response.Cache.SetCacheability(HttpCacheability.NoCache)
                Context.Response.Clear()
                Context.Response.AddHeader("Content-Disposition", "attachment; filename=" + String.Format("pdfImg_{0}.jpg", intReqPageNum.ToString()))
                Context.Response.ContentType = "image/jpg"
                Context.Response.BinaryWrite(bb)
                bms.Close()
                Context.Response.End()
            End If
        End If
    
       
    End Sub

    Protected Sub btnUpload_Click(sender As Object, e As System.EventArgs)
        tdPageImgPreview.Visible = False : dlPageNum.Items.Clear() : lbMsg.Text = ""
        If fup1.HasFile AndAlso fup1.FileName.EndsWith(".pdf", StringComparison.CurrentCultureIgnoreCase) Then
            Dim intMaxM As Integer = 10
            If fup1.FileBytes.Length >= 1024 * 1024 * intMaxM Then
                lbMsg.Text = "File size should not be larger than " + intMaxM.ToString() + "M" : Exit Sub
            End If
            Dim lic As New Aspose.Pdf.Kit.License() : lic.SetLicense(HttpContext.Current.Server.MapPath("~/Files/Aspose.Total.lic"))
            Dim viewer As New Aspose.Pdf.Kit.PdfViewer
            viewer.OpenPdfFile(fup1.FileContent)
           
            Dim intPages As Integer = 0
            Try
                intPages = viewer.PageCount
            Catch ex As Aspose.Pdf.Kit.PdfKitErrorCodeException
                viewer.ClosePdfFile()
                lbMsg.Text = "File is damaged or not a pdf file" : Exit Sub
            End Try
        
            If intPages > 0 Then
                For i As Integer = 0 To intPages - 1
                    dlPageNum.Items.Add(New ListItem((i + 1).ToString(), (i + 1).ToString()))
                Next
                Dim strFileId As String = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
                Dim strPDFFilePath As String = Server.MapPath("~/Files/TempFiles") + "\" + strFileId + ".pdf"
                strFileId = Left(strFileId, 5) + Right(strFileId, 5)
                Dim UploadedPDFFiles As Dictionary(Of String, String) = HttpContext.Current.Cache("UploadedPDFFiles")
                If UploadedPDFFiles Is Nothing Then
                    UploadedPDFFiles = New Dictionary(Of String, String)
                    HttpContext.Current.Cache.Add("UploadedPDFFiles", UploadedPDFFiles, Nothing, DateTime.Now.AddMinutes(30), _
                                                  System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
                End If
                UploadedPDFFiles.Add(strFileId, strPDFFilePath)
                fup1.SaveAs(strPDFFilePath)
                ViewState("fid") = strFileId
                dlPageNum_SelectedIndexChanged(dlPageNum, Nothing)
                tdPageImgPreview.Visible = True
            Else
                lbMsg.Text = "No page in this file"
            End If
            viewer.ClosePdfFile()
        Else
            lbMsg.Text = "No file uploaded or not a valid pdf file"
        End If
    End Sub

    Protected Sub dlPageNum_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        imgPDFPage.ImageUrl = IO.Path.GetFileName(Request.PhysicalPath) + "?pagenum=" + dlPageNum.SelectedValue + "&fid=" + ViewState("fid").ToString()
    End Sub
    
    Protected Sub Page_PreRender(sender As Object, e As System.EventArgs)
       
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">       
    <table>
        <tr>
            <td><asp:FileUpload runat="server" ID="fup1" Width="700px" /></td>            
        </tr>
        <tr>
            <td><asp:Button runat="server" ID="btnUpload" Text="Upload PDF" OnClick="btnUpload_Click" /></td>
        </tr>
        <tr style="height:20px">
            <td><asp:Label runat="server" ID="lbMsg" ForeColor="Tomato" Font-Bold="true" /></td>
        </tr>
        <tr>
            <td runat="server" id="tdPageImgPreview" visible="false">
                <table>
                    <tr>
                        <td>
                        Page Number:&nbsp;<asp:DropDownList runat="server" ID="dlPageNum" AutoPostBack="true" OnSelectedIndexChanged="dlPageNum_SelectedIndexChanged" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="panelPreviewImage" Width="900px" Height="450px" ScrollBars="Auto">
                                <asp:Image runat="server" ID="imgPDFPage" />
                            </asp:Panel>                            
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>  
</asp:Content>
