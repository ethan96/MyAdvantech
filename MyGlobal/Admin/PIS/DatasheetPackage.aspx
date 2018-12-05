<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Product Datasheet Package"
    ValidateRequest="false" %>

<%@ Import Namespace="ICSharpCode.SharpZipLib.Core" %>

<%@ Import Namespace="ICSharpCode.SharpZipLib.Zip" %>

<%@ Import Namespace="System.IO" %>

<%@ Import Namespace="System.Diagnostics" %>

<script runat="server">

    Dim _ConsoleProgramPath_DevelopeSite As String = "D:\Advantech\PIS\PIS_SchedulePrograms\PackageProductDatasheet\bin\Debug\PackageProductDatasheet.exe"
    Dim _ConsoleProgramPath As String = "D:\PIS_ConsoleProgram\PackageProductDatasheet\PackageProductDatasheet.exe"

    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.Label_Msg.Text = ""
        Try
            Dim filename As System.IO.Stream = upload()
            If Not IsNothing(filename) Then
                preview(filename)
                'Button_Search_Click(sender, e)
                Me.Label_Msg.ForeColor = Drawing.Color.Black
                Me.Label_Msg.Text = "Upload successful. MyAdvantech will send you the datasheet download link in 5 minutes."
            End If

        Catch ex As Exception
            Me.Label_Msg.ForeColor = System.Drawing.ColorTranslator.FromHtml("#FF3300")
            Me.Label_Msg.Text = "Upload failed! " & ex.Message
        End Try
    End Sub

    Function upload() As System.IO.Stream
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Dim MSM As New System.IO.MemoryStream(Me.FileUpload1.FileBytes)
            'Me.FileUpload1.SaveAs(fileName)
            Return MSM
        End If
        Return Nothing
    End Function

    Sub preview(ByVal fileName As System.IO.Stream)

        Dim tempdt As DataTable = Util.ExcelFile2DataTable(fileName, 1, 0)
        If tempdt.Rows.Count <= 0 Then
            Glob.ShowInfo("No data be uploaded.")
            Exit Sub
        End If
        If tempdt.Columns.Count < 1 Then
            Glob.ShowInfo("The uploaded excel file is in invalid format. Please download and use sample excel file.")
            Exit Sub
        End If
        Dim _sql_remove As String = "Delete From PRODUCT_FAMILY Where ", _sql_remove_Where As String = ""
        Dim _sql_insert As String = "Insert into PRODUCT_FAMILY values ", _sql_insert_values As String = ""
        Dim _ModelNo As String = String.Empty, _LiterID As String = String.Empty
        Dim _PackageID As String = System.Guid.NewGuid().ToString().Replace("-", "")
        Dim _pisAPT As New PISDSTableAdapters.PACKAGE_PRODUCT_DATASHEETTableAdapter
        For Each _row As DataRow In tempdt.Rows

            Dim _part_no As String = _row.Item(0).ToString
            If String.IsNullOrEmpty(_part_no) Then Continue For
            '_part_no = _part_no.Replace("'", "''")
            'Remove current record
            _sql_remove_Where = " PART_NO='" & _part_no & "' "


            Me.GetPisDatasheetLiteratureIDByPartNo(_part_no, _ModelNo, _LiterID)
            'Insert new record  
            _pisAPT.Insert(_PackageID, _part_no, _ModelNo, _LiterID, Session("user_id"), Now, False)

        Next

        Dim _dt As DataTable = _pisAPT.GetDataByPackageID(_PackageID)

        Me.GV_ProductFamily.DataSource = _dt
        Me.GV_ProductFamily.DataBind()

        'Download datasheet files
        'compress files in zip format
        'save zip file to database
        'send download url to user
        Me.DownloadandSendEmail(_PackageID)

        ''System.Diagnostics.Process.Start(_ConsoleProgramPath)
        'If Not System.IO.File.Exists(_ConsoleProgramPath) Then
        '    _ConsoleProgramPath = _ConsoleProgramPath_DevelopeSite
        'End If
        'If System.IO.File.Exists(_ConsoleProgramPath) Then

        '    Dim _Process As New Process
        '    _Process.StartInfo.FileName = _ConsoleProgramPath
        '    _Process.StartInfo.Arguments = _PackageID
        '    _Process.StartInfo.UseShellExecute = False
        '    _Process.StartInfo.CreateNoWindow = True
        '    _Process.StartInfo.RedirectStandardOutput = True
        '    _Process.Start()
        '    '_Process.WaitForExit()
        'Else
        '    Throw New Exception("Datasheet package console program dose not exist!")
        'End If

    End Sub


    Private Sub DownloadandSendEmail(ByVal _PackageID As String)

        Dim _PisPackageDatasheetTAP As New PISDSTableAdapters.PACKAGE_PRODUCT_DATASHEETTableAdapter
        Dim _PisPackageDatasheetCacheTAP As New PISDSTableAdapters.PACKAGE_PRODUCT_DATASHEET_CACHETableAdapter
        Dim _PackageTaskListDT As PISDS.PACKAGE_PRODUCT_DATASHEETDataTable
        _PackageTaskListDT = _PisPackageDatasheetTAP.GetUnprocessPackageIDByPackageID(_PackageID)

        Dim _DatasheetFileListDT As PISDS.PACKAGE_PRODUCT_DATASHEETDataTable = Nothing, _LiteratureDT As DataTable = Nothing
        Dim _url As String = "http://downloadt.advantech.com/download/downloadlit.aspx?LIT_ID="
        Dim _LiterID As String = String.Empty ', _PackageID As String = String.Empty
        Dim _File_Mame As String = String.Empty, _OutPathName = String.Empty, password = String.Empty
        Dim _FolderName As String = String.Empty, _ZipFileFullName As String = String.Empty

        'Dim _AppPath As String = IO.Path.GetDirectoryName(Diagnostics.Process.GetCurrentProcess().MainModule.FileName)
        Dim _AppPath As String = Server.MapPath("~/Files/TempFiles")

        '_AppPath = IO.Path.GetDirectoryName(Diagnostics.Process.GetCurrentProcess().MainModule.FileName)
        For Each _TaskListRow As DataRow In _PackageTaskListDT.Rows
            _PackageID = _TaskListRow.Item("PackageID").ToString

            Console.WriteLine("Process " & _PackageID)

            '_OutPathName = Path.Combine("d:\temp1\", _PackageID)
            '_FolderName = Path.Combine("d:\temp1\", _PackageID)
            _OutPathName = System.IO.Path.Combine(_AppPath, _PackageID)
            _FolderName = _OutPathName

            _DatasheetFileListDT = _PisPackageDatasheetTAP.GetDataByPackageID(_PackageID)
            If _DatasheetFileListDT Is Nothing OrElse _DatasheetFileListDT.Rows.Count = 0 Then
                Continue For
            End If

            _DatasheetFileListDT.Columns.Add("Msg") : _DatasheetFileListDT.Columns("Msg").ReadOnly = False : _DatasheetFileListDT.Columns("Msg").MaxLength = 200

            '=====Download each datasheet to a folder=====
            For Each _FileRow As DataRow In _DatasheetFileListDT.Rows
                '_RowMsg = ""
                _LiterID = _FileRow.Item("PisLiterID").ToString
                _LiteratureDT = Me.GetLiteratureByLiterId(_LiterID)
                If _LiteratureDT Is Nothing OrElse _LiteratureDT.Rows.Count = 0 Then
                    _FileRow.Item("Msg") = "File information(LiterID=" & _LiterID & ") cannot be found in PIS"
                    Continue For
                End If

                '_LiterID = _LiteratureDT.Rows(0).Item("LITERATURE_ID").ToString
                _File_Mame = _LiteratureDT.Rows(0).Item("FILE_NAME").ToString & "." & _LiteratureDT.Rows(0).Item("FILE_EXT").ToString

                If Not Directory.Exists(_FolderName) Then Directory.CreateDirectory(_FolderName)

                If DownloadFile(_url & _LiterID, Path.Combine(_FolderName, _File_Mame)) Then
                Else
                    _FileRow.Item("Msg") = "File(LiterID=" & _LiterID & ") cannot be download from PIS"
                End If

            Next
            '=====End Download each datasheet to a folder=====

            _ZipFileFullName = _FolderName & ".zip"

            '=====Zip folder=====
            If File.Exists(_ZipFileFullName) Then File.Delete(_ZipFileFullName)
            Dim fsOut As FileStream = File.Create(_ZipFileFullName)
            Dim zipStream As New ZipOutputStream(fsOut)

            zipStream.SetLevel(3)       '0-9, 9 being the highest level of compression
            zipStream.Password = password   ' optional. Null is the same as not setting.

            ' This setting will strip the leading part of the folder path in the entries, to
            ' make the entries relative to the starting folder.
            ' To include the full path for each entry up to the drive root, assign folderOffset = 0.
            Dim folderOffset As Integer = _FolderName.Length + (If(_FolderName.EndsWith("\"), 0, 1))

            If Not Directory.Exists(_FolderName) Then Directory.CreateDirectory(_FolderName)
            CompressFolder(_OutPathName, zipStream, folderOffset)

            zipStream.IsStreamOwner = True
            ' Makes the Close also Close the underlying stream
            zipStream.Close()
            '=====End Zip folder=====

            '=====Save zip file to table=====
            Dim fInfo As New FileInfo(_ZipFileFullName)
            Dim numBytes As Long = fInfo.Length
            Dim fStream As New FileStream(_ZipFileFullName, FileMode.Open, FileAccess.Read)
            Dim br As New BinaryReader(fStream)

            Dim _Zipbytes As Byte() = br.ReadBytes(CInt(numBytes))

            br.Close() : fStream.Close()

            _PisPackageDatasheetCacheTAP.DeleteByPackageID(_PackageID)
            _PisPackageDatasheetCacheTAP.Insert(_PackageID, _Zipbytes, Now)
            '=====End Save zip file to table=====

            '=====Send email =====
            SendEmailWithAttachment("", _DatasheetFileListDT)
            '=====End Send email =====

            _PisPackageDatasheetTAP.UpdatePackageStatusByPackageId(True, _PackageID)

            If Directory.Exists(_OutPathName) Then Directory.Delete(_OutPathName, True)

        Next
    End Sub



    Function DownloadFile(ByVal uri As String, ByVal destFile As String, _
    Optional ByVal username As String = Nothing, Optional ByVal pwd As String = Nothing) As Boolean
        Try
            Dim wc As New System.Net.WebClient
            If Not username Is Nothing AndAlso Not pwd Is Nothing Then
                wc.Credentials = New System.Net.NetworkCredential(username, pwd)
            End If
            wc.DownloadFile(uri, destFile)
        Catch ex As Exception
            Return False
        End Try
        Return True
    End Function


    Private Sub CompressFolder(path As String, zipStream As ZipOutputStream, folderOffset As Integer)

        Dim files As String() = Directory.GetFiles(path)

        For Each filename As String In files

            Dim fi As New FileInfo(filename)

            Dim entryName As String = filename.Substring(folderOffset)  ' Makes the name in zip based on the folder
            entryName = ZipEntry.CleanName(entryName)       ' Removes drive from name and fixes slash direction
            Dim newEntry As New ZipEntry(entryName)
            newEntry.DateTime = fi.LastWriteTime            ' Note the zip format stores 2 second granularity

            ' Specifying the AESKeySize triggers AES encryption. Allowable values are 0 (off), 128 or 256.
            '   newEntry.AESKeySize = 256;

            ' To permit the zip to be unpacked by built-in extractor in WinXP and Server2003, WinZip 8, Java, and other older code,
            ' you need to do one of the following: Specify UseZip64.Off, or set the Size.
            ' If the file may be bigger than 4GB, or you do not need WinXP built-in compatibility, you do not need either,
            ' but the zip will be in Zip64 format which not all utilities can understand.
            '   zipStream.UseZip64 = UseZip64.Off;
            newEntry.Size = fi.Length

            zipStream.PutNextEntry(newEntry)

            ' Zip the file in buffered chunks
            ' the "using" will close the stream even if an exception occurs
            Dim buffer As Byte() = New Byte(4095) {}
            Using streamReader As FileStream = File.OpenRead(filename)
                StreamUtils.Copy(streamReader, zipStream, buffer)
            End Using
            zipStream.CloseEntry()
        Next
        Dim folders As String() = Directory.GetDirectories(path)
        For Each folder As String In folders
            CompressFolder(folder, zipStream, folderOffset)
        Next
    End Sub

    Public Function SendEmailWithAttachment(ByVal AttachmentFile As String, ByVal _dt As DataTable) As Boolean
        Dim oMail As New Net.Mail.MailMessage(), _EmailTo As String = _dt.Rows(0).Item("Email").ToString
        Dim _Name As String = _EmailTo.Substring(0, 1).ToUpper & _EmailTo.Substring(1, _EmailTo.IndexOf("@") - 1)
        Dim _PackageID As String = _dt.Rows(0).Item("PackageID").ToString
        oMail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
        'oMail.To.Add("Frank.Chung@advantech.com.tw")
        oMail.To.Add(_EmailTo)
        'oMail.Bcc.Add("Frank.Chung@advantech.com.tw")
        'oMail.Bcc.Add("TC.Chen@advantech.com.tw")

        oMail.Subject = "Advantech product datasheet download link"
        oMail.IsBodyHtml = True
        oMail.Body = "<html><body>Dear " & _Name & ","
        'oMail.Body &= "<br /><br />Please click <a href='http://my.advantech.com/Download/DownloadProdDatasheetPackage.aspx?PackageID=" & _PackageID & "'>"
        oMail.Body &= "<br /><br />Please click <a href='" & Util.GetRuntimeSiteUrl() & "/Download/DownloadProdDatasheetPackage.aspx?PackageID=" & _PackageID & "'>"
        oMail.Body &= "[here]</a> to download Advantech product datasheet."
        oMail.Body &= "<Font size='2'><br/><br/>"
        For Each _row As DataRow In _dt.Rows
            oMail.Body &= "<li>" & _row.Item("Partno").ToString & ":"
            If String.IsNullOrEmpty(_row.Item("Msg").ToString) Then
                oMail.Body &= "<font color='green'>OK</font>"
            Else
                oMail.Body &= "<font color='red'>" & _row.Item("Msg").ToString & "</font>"
            End If
        Next
        oMail.Body &= "</Font>"
        oMail.Body &= "<br /><br />Thank you."
        oMail.Body &= "<br /><br />MyAdvantech</body></html>"
        If Not String.IsNullOrEmpty(AttachmentFile) Then
            oMail.Attachments.Add(New Net.Mail.Attachment(AttachmentFile))
        End If
        '172.21.34.21
        Dim oSmpt As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Try
            oSmpt.Send(oMail)
            Return True
        Catch ex As Exception
        End Try
        Return False
    End Function

    Public Function SendErrorReportEmail(ByVal _title As String, ByVal _errmsg As String) As Boolean
        Dim oMail As New Net.Mail.MailMessage()
        oMail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
        oMail.To.Add("Frank.Chung@advantech.com.tw")

        oMail.Subject = _title '"Interested Product updated log message"
        oMail.IsBodyHtml = False
        oMail.Body = _errmsg
        'oMail.Attachments.Add(New Net.Mail.Attachment(AttachmentFile))
        '172.21.34.21
        Dim oSmpt As New Net.Mail.SmtpClient("172.21.34.21")
        Try
            oSmpt.Send(oMail)
            Return True
        Catch ex As Exception
        End Try
        Return False
    End Function

    Public Function GetLiteratureByLiterId(ByVal _LiterId As String) As DataTable
        Dim _sql As New StringBuilder
        _sql.AppendLine(" SELECT LITERATURE_ID,SIEBEL_FILENAME,LIT_NAME,LIT_DESC ")
        _sql.AppendLine(" ,LIT_TYPE,[FILE_NAME],FILE_EXT,FILE_SIZE,FILE_LOCATION ")
        _sql.AppendLine(" ,PRIMARY_ORG_ID,PRIMARY_BU,PRIMARY_LEVEL,PRIMARY_SDU ")
        _sql.AppendLine(" ,CREATED,CREATED_BY,LAST_UPDATED,LAST_UPDATED_BY ")
        _sql.AppendLine(" ,[START_DATE],END_DATE,INT_FLG,LANG ")
        _sql.AppendLine(" FROM LITERATURE ")
        _sql.AppendLine(" Where LITERATURE_ID='" & _LiterId & "' ")
        'Dim _db_type As ConnectionManager.DatabaseConnection = ConnectionManager.DatabaseConnection.PIS_Readonly
        Return dbUtil.dbGetDataTable("PIS", _sql.ToString)
    End Function




    Private Sub GetPisDatasheetLiteratureIDByPartNo(ByVal _PartNo As String, ByRef _ModelNo As String, ByRef _LiterID As String)

        _ModelNo = String.Empty : _LiterID = String.Empty

        Dim _sql As New StringBuilder, _dt As DataTable = Nothing

        _sql.AppendLine(" Select Top 1 a.model_name,c.LITERATURE_ID ")
        _sql.AppendLine(" From model_product a inner join Model_lit b on a.model_name=b.model_name ")
        _sql.AppendLine(" left join LITERATURE c on b.literature_id=c.LITERATURE_ID ")
        _sql.AppendLine(" Where a.part_no='" & _PartNo.Replace("'", "''") & "' ")
        _sql.AppendLine(" And a.relation='product' ")
        _sql.AppendLine(" And c.LIT_TYPE='Product - Datasheet' ")
        _sql.AppendLine(" And c.LANG='ENU' ")
        _sql.AppendLine(" Order by c.LAST_UPDATED desc ")

        _dt = dbUtil.dbGetDataTable("PIS", _sql.ToString)

        If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
            _ModelNo = _dt.Rows(0).Item("model_name").ToString() : _LiterID = _dt.Rows(0).Item("LITERATURE_ID").ToString()
            Exit Sub
        End If

        _sql.Clear()
        _sql.AppendLine(" Select Top 1 b.model_name,c.LITERATURE_ID ")
        _sql.AppendLine(" From Model_lit b left join LITERATURE c on b.literature_id=c.LITERATURE_ID ")
        _sql.AppendLine(" Where b.model_name='" & _PartNo.Replace("'", "''") & "' ")
        _sql.AppendLine(" And c.LIT_TYPE='Product - Datasheet' ")
        _sql.AppendLine(" And c.LANG='ENU' ")
        _sql.AppendLine(" Order by c.LAST_UPDATED desc ")

        _dt = dbUtil.dbGetDataTable("PIS", _sql.ToString)

        If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
            _ModelNo = _dt.Rows(0).Item("model_name").ToString() : _LiterID = _dt.Rows(0).Item("LITERATURE_ID").ToString()
            Exit Sub
        End If

        _sql.Clear()
        _sql.AppendLine(" Select Top 1 a.MODEL_NO,c.LITERATURE_ID ")
        _sql.AppendLine(" From PRODUCT_LOGISTICS_NEW a inner join Model_lit b on a.MODEL_NO=b.model_name ")
        _sql.AppendLine(" left join LITERATURE c on b.literature_id=c.LITERATURE_ID ")
        _sql.AppendLine(" Where a.PART_NO='" & _PartNo.Replace("'", "''") & "' ")
        '_sql.AppendLine(" And a.relation='product' ")
        _sql.AppendLine(" And c.LIT_TYPE='Product - Datasheet' ")
        _sql.AppendLine(" And c.LANG='ENU' ")
        _sql.AppendLine(" Order by c.LAST_UPDATED desc ")

        _dt = dbUtil.dbGetDataTable("PIS", _sql.ToString)

        If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
            _ModelNo = _dt.Rows(0).Item("MODEL_NO").ToString() : _LiterID = _dt.Rows(0).Item("LITERATURE_ID").ToString()
            Exit Sub
        End If

    End Sub

</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">


    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        > Package Product Datasheet</div>
    <br />
    <div class="menu_title">
        Package Product Datasheet</div>
    <br />
    <asp:Panel DefaultButton="btnUpload" runat="server" ID="Panel1">
        <table width="100%" class="rightcontant3">
            <tr>
                <td align="left">
                 Upload Part Number for Packaging Product Datasheets：<br />
                    <asp:FileUpload ID="FileUpload1" runat="server" />
                    <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
                    <br/>
                    <asp:Label ID="Label_Msg" runat="server" Text="" ForeColor="#FF3300" />
                </td>
                <td width="450">
                    <asp:HyperLink NavigateUrl="~/Files/PackageProdDatasheetSample.xls" runat="server" ID="HyperLink1"
                        Text="Click Here for Downloadable Sample (MS Excel)"></asp:HyperLink>
                    <asp:Image ID="Image2" runat="server" ImageUrl="~/Images/PackageProductDatasheetExcelSample.png" />
                </td>
            </tr>
        </table>
        <br />
        <asp:GridView ID="GV_ProductFamily" runat="server" AutoGenerateColumns="false" EmptyDataText="No search results were found."
            Width="100%">
            <Columns>
                <asp:BoundField ItemStyle-Width="200px" HeaderText="Part Number" DataField="PARTNO"
                    ItemStyle-HorizontalAlign="left"/>
                <asp:BoundField ItemStyle-Width="200px" HeaderText="Model Name" DataField="Model_Name"
                    ItemStyle-HorizontalAlign="left"/>
                <asp:BoundField ItemStyle-Width="200px" HeaderText="PIS Literature ID" DataField="PisLiterID"
                    ItemStyle-HorizontalAlign="left"/>
                <asp:BoundField ItemStyle-Width="200px" HeaderText="Upload By" DataField="Email"
                    ItemStyle-HorizontalAlign="left"/>
                <asp:BoundField ItemStyle-Width="200px" HeaderText="Upload Time" DataField="UploadTime"
                    ItemStyle-HorizontalAlign="left"/>
            </Columns>
        </asp:GridView>
<%--        <asp:SqlDataSource ID="SqlDataSource_ProductFamily" runat="server" ConnectionString="<%$ ConnectionStrings:PIS %>"
            SelectCommand="SELECT PART_NO,FAMILY_NAME,ALTERNATIVE_GROUP FROM PRODUCT_FAMILY Order by LAST_UPDATED desc,PART_NO,FAMILY_NAME" />
--%>    </asp:Panel>


</asp:Content>