<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Unzip File" EnableEventValidation="false"%>

<script runat="server">
    Private file_id As String = "", fileUrl As String = "", fileName As String = "", fileDesc As String = "", fileSize As String = "",model_no As String=""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Session("IsDisclaim") = False
        If Trim(Request("Literature_Id")) <> "" Then
            'fileUrl = UnzipFileUtil.UnzipLit(Server.UrlEncode(Trim(Request("Literature_Id"))))
            fileUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" & Server.UrlEncode(Trim(Request("Literature_Id")))
            Dim LitDt As DataTable = dbUtil.dbGetDataTable("PIS", _
                                            " Select IsNull(LIT_NAME, '') as LIT_NAME, IsNull(FILE_EXT, '') as FILE_EXT, IsNull(FILE_SIZE, 0) as FILE_SIZE, IsNull(LIT_DESC,'') as LIT_DESC, LIT_TYPE " + _
                                            " From LITERATURE " & _
                                            " Where LITERATURE_ID = '" & Replace(Trim(Request("Literature_Id")), "'", "''") & "'")
            Dim lit_type As String = LCase(Request("C"))
            If LitDt.Rows.Count > 0 Then
                lit_type = LCase(LitDt.Rows(0).Item("LIT_TYPE").ToString)
                fileName = LitDt.Rows(0).Item(0).ToString
                If LitDt.Rows(0).Item(1).ToString() <> "" Then fileName += "." + LitDt.Rows(0).Item(1).ToString()
                fileSize = FormatNumber(CDbl(LitDt.Rows(0).Item(2).ToString) / 1024, 0, , , -2) + "k"
                If Request("Literature_Id") = "1-367Y1B" Then hlDownloadFile.NavigateUrl = fileUrl + ".step"
                hlDownloadFile.Text = fileName
                lblFileSize.Text = fileSize
                file_id = Trim(Request("Literature_Id"))
                lblFileDesc.Text = LitDt.Rows(0).Item(3).ToString : fileDesc = LitDt.Rows(0).Item(3).ToString
                If LCase(Session("user_id")) Like "*@advantech*.*" Then
                    hlDownloadFile.NavigateUrl = fileUrl
                    If fileUrl <> "" Then
                    Else
                        td1.Visible = True : trDisclaim.Visible = False : trDownload.Visible = False
                    End If
                Else
                    If LitDt.Rows(0).Item(1).ToString().ToLower() = "rar" Or LitDt.Rows(0).Item(1).ToString().ToLower() = "zip" Then
                        hlDownloadFile.NavigateUrl = ""
                        hlDownloadFile.Text = fileName + "<br/><font color='red'>Please contact your Advantech representative to obtain this material.</font>"
                    Else
                        hlDownloadFile.NavigateUrl = fileUrl
                        If fileUrl <> "" Then
                            'Response.Redirect(fileUrl)
                            'If Session("IsDisclaim") = True Then
                            '    trDownload.Visible = True : trDisclaim.Visible = False
                            'Else
                            '    trDownload.Visible = False : trDisclaim.Visible = True
                            'End If
                        Else
                            td1.Visible = True : trDisclaim.Visible = False : trDownload.Visible = False
                        End If
                    End If
                End If
            Else
                td1.Visible = True : trDisclaim.Visible = False : trDownload.Visible = False
            End If
            If lit_type Like "*photo*" Then lit_type = "photo"
            If lit_type Like "*certificate*" Then lit_type = "certificate logo"
            If lit_type Like "*data*sheet*" Then lit_type = "datasheet"
            If lit_type Like "poster*" Then lit_type = "event poster"
            hlDownloadFile.NavigateUrl = "MaterialRedirectPage.aspx?Type=lit&C=" + lit_type + "&rid=" + Request("Literature_Id") + "&url=" + fileUrl
            'hlDownloadFile.Attributes.Add("onmouseover", "javascript:GetUrl(""" + hlDownloadFile.ClientID + """,""" + fileUrl + """)")
            'hlDownloadFile.Attributes.Add("onclick", "javascript:TracePage(""lit"",""" + lit_type + """,""" + Request("Literature_Id") + """,""" + hlDownloadFile.ClientID + """,""" + fileUrl + """)")
            'MyLog.UpdateLog(Session("user_id"), lit_type, Request("Literature_Id"), MyLog.PageType.DownloadDocument.ToString)
        End If
        
        If Trim(Request("File_Id")) <> "" Then
            fileUrl = "http://downloadt.advantech.com/download/downloadsr.aspx?File_Id=" & Server.UrlEncode(Trim(Request("File_Id")))
            Dim sr_dt As DataTable = dbUtil.dbGetDataTable("MY", _
                                                " Select IsNull(FILE_EXT, '') as FILE_EXT, IsNull(FILE_NAME, '') as FILE_NAME, IsNull(FILE_SIZE,0) as FILE_SIZE, IsNull(FILE_DESC,'') as FILE_DESC " + _
                                                " From SIEBEL_SR_SOLUTION_FILE Where FILE_ID = '" + Replace(Trim(Request("File_Id")), "'", "''") + "'")
            If sr_dt.Rows.Count > 0 Then
                fileName = sr_dt.Rows(0).Item(1).ToString
                If sr_dt.Rows(0).Item(0).ToString <> "" Then fileName += "." + sr_dt.Rows(0).Item(0).ToString
                fileSize = FormatNumber(CDbl(sr_dt.Rows(0).Item(2).ToString) / 1024, 0, , , -2) + "k"
                hlDownloadFile.Text = fileName
                lblFileSize.Text = fileSize
                file_id = Trim(Request("File_Id"))
                lblFileDesc.Text = sr_dt.Rows(0).Item(3).ToString : fileDesc = sr_dt.Rows(0).Item(3).ToString
                If LCase(Session("user_id")) Like "*@advantech*.*" Then
                    hlDownloadFile.NavigateUrl = fileUrl
                    If fileUrl <> "" Then
                    Else
                        td1.Visible = True : trDisclaim.Visible = False : trDownload.Visible = False
                    End If
                Else
                    If sr_dt.Rows(0).Item(0).ToString.ToLower = "rar" Or sr_dt.Rows(0).Item(0).ToString.ToLower = "zip" Then
                        hlDownloadFile.NavigateUrl = ""
                        hlDownloadFile.Text = fileName + "<br/><font color='red'>Please contact your Advantech representative to obtain this material.</font>"
                    Else
                        hlDownloadFile.NavigateUrl = fileUrl
                        If fileUrl <> "" Then
                            'Response.Redirect(fileUrl)
                            'If Session("IsDisclaim") = True Then
                            '    trDownload.Visible = True : trDisclaim.Visible = False
                            'Else
                            '    trDownload.Visible = False : trDisclaim.Visible = True
                            'End If
                        Else
                            td1.Visible = True : trDisclaim.Visible = False : trDownload.Visible = False
                        End If
                    End If
                End If
            Else
                td1.Visible = True : trDisclaim.Visible = False : trDownload.Visible = False
            End If
            
            hlDownloadFile.NavigateUrl = "MaterialRedirectPage.aspx?Type=lit&C=" + LCase(Request("C")) + "&rid=" + Request("File_Id") + "&url=" + fileUrl
        End If
        
        If Util.IsInternalUser2() OrElse _
            (Session("org_id") IsNot Nothing AndAlso Session("org_id") = "EU10" AndAlso (Session("account_status") = "CP" Or Session("account_status") = "KA")) Then
            trDisclaim.Visible = False : trDownload.Visible = True
        End If
     
    End Sub

    Protected Sub btnAgree_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        trDownload.Visible = True
        SendMail()
    End Sub

    Private Sub SendMail()
        If Not Session("user_id").ToString.Contains("@advantech") Then
            Dim model_no As String = "", sr_id As String = "", p_group As String = ""
            If Trim(Request("Literature_Id")) <> "" Then
                If Trim(Request("Part_NO")) <> "" Then
                    If Request("Part_NO").ToString.Contains("|") Then model_no = Request("Part_NO").ToString.Split("|")(0) Else model_no = Trim(Request("Part_NO"))
                Else
                    Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "select top 1 isnull(c.part_no,'') from [PIS].dbo.literature a left join siebel_product_literature b on a.literature_id=b.literature_Id left join siebel_product c on b.product_id = c.product_id where a.literature_id='" + Trim(Request("Literature_ID")) + "'")
                    If dt.Rows.Count > 0 Then model_no = dt.Rows(0).Item(0).ToString
                End If
            End If
            If Trim(Request("File_Id")) <> "" Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "select top 1 isnull(c.sr_id,'') from siebel_sr_solution_file a left join siebel_sr_solution_file_relation b on a.file_id=b.file_id left join siebel_sr_solution_relation c on b.solution_id=c.solution_id where a.file_id='" + Trim(Request("File_Id")) + "'")
                If dt.Rows.Count > 0 Then sr_id = dt.Rows(0).Item(0).ToString
            End If
            Dim body As New StringBuilder
            body.AppendFormat("Dears,<br/><br/>")
            body.AppendFormat("Customer {0} downloaded the following file.<br/><br/>", Session("user_id"))
            If model_no <> "" Then
                body.AppendFormat("You can get the detailed product information through this page. {0}<br/><br/>", "<a href='http://my.advantech.eu/Product/Model_Detail.aspx?Model_NO=" + model_no + "'>Model Detail</a>")
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 isnull(product_group,'') from sap_product where part_no like '{0}%'", model_no))
                If dt.Rows.Count > 0 Then p_group = dt.Rows(0).Item(0).ToString
                InsertToLog(sr_id, p_group)
            End If
            If sr_id <> "" Then
                Dim part_no As String = ""
                If Request("Part_NO").ToString.Contains("|") Then part_no = Request("Part_NO").ToString.Split("|")(0) Else part_no = Trim(Request("Part_NO"))
                body.AppendFormat("You can get the detailed product information through this page. {0}", "<a href='http://my.advantech.eu/Product/Model_Detail.aspx?Model_NO=" + part_no + "'>Model Detail</a> --- ")
                If Trim(Request("Type")) = "Download" Then body.AppendFormat("<a href='http://my.advantech.eu/Product/SR_Download.aspx?SR_ID=" + sr_id + "&Part_NO=" + part_no + "'>Download</a><br/><br/>")
                If Trim(Request("Type")) = "FAQ" Then body.AppendFormat("<a href='http://my.advantech.eu/Product/SR_Detail.aspx?SR_ID=" + sr_id + "&Part_NO=" + part_no + "'>Download</a><br/><br/>")
                If Trim(Request("Part_NO")) <> "" Then
                    Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 isnull(product_group,'') from PRODUCT_FULLTEXT_NEW where part_no like '{0}%'", part_no))
                    If dt.Rows.Count > 0 Then p_group = dt.Rows(0).Item(0).ToString
                    InsertToLog(sr_id, p_group)
                End If
            End If
            Dim mailTo As String = ""
            If p_group = "EAUT" Then
                'mailTo = "Mariette.Dusseldorp@advantech-nl.nl,Marika.Silla@advantech.it"
                mailTo = "Mariette.Dusseldorp@advantech-nl.nl"
            Else
                mailTo = ""
            End If
            body.AppendFormat("<table cellspacing='0' border='1' style='border-color:#A9C84D'>")
            body.AppendFormat("<tr><td align='center' style='background-color:#E5F39D'><b>ID</b></td><td align='center' style='background-color:#E5F39D'><b>File Name</b></td><td align='center' style='background-color:#E5F39D'><b>File Description</b></td><td align='center' style='background-color:#E5F39D'><b>File Size</b></td></tr>")
            body.AppendFormat("<tr><td align='center'>{0}</td><td align='center'>{1}</td><td align='center'>{2}</td><td align='center'>{3}</td></tr>", file_id, "<a href='" + fileUrl + "'>" + fileName + "</a>", fileDesc, fileSize)
            body.AppendFormat("</table><br/><br/>Best Regards,<br/><a href='http://my.advantech.eu'>MyAdvantech</a>")
            If mailTo <> "" Then
                'Util.SendEmail(mailTo, "eBusiness.AEU@advantech.eu", "MyAdvantech File Download", body.ToString, True, "", "rudy.wang@advantech.com.tw")
            End If
            
        End If
    End Sub
    
    Private Sub InsertToLog(ByVal sr_id As String, ByVal p_group As String)
        'dbUtil.dbExecuteNoQuery("MY", String.Format("insert into FILE_DOWNLOAD_LOG values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')", file_id, fileName, fileDesc, fileSize, Now, Trim(Request("Part_NO")), sr_id, p_group, Session("user_id")))
        Dim sb As New StringBuilder
        sb.AppendFormat("insert into FILE_DOWNLOAD_LOG (FILE_ID,FILE_NAME,FILE_DESC,FILE_SIZE,DOWNLOAD_DATE,MODEL_NO,SR_ID,PRODUCT_LINE,DOWNLOADER) values ")
        sb.AppendFormat("(@FILE_ID,@FILE_NAME,@FILE_DESC,@FILE_SIZE,@DATE,@MODEL_NO,@SR_ID,@PRODUCT_LINE,@DOWNLOADER)")
        Dim pFileID As New System.Data.SqlClient.SqlParameter("FILE_ID", SqlDbType.NVarChar) : pFileID.Value = file_id
        Dim pFileName As New System.Data.SqlClient.SqlParameter("FILE_NAME", SqlDbType.NVarChar) : pFileName.Value = fileName
        Dim pFileDesc As New System.Data.SqlClient.SqlParameter("FILE_DESC", SqlDbType.NVarChar) : pFileDesc.Value = fileDesc
        Dim pFileSize As New System.Data.SqlClient.SqlParameter("FILE_SIZE", SqlDbType.NVarChar) : pFileSize.Value = fileSize
        Dim pDate As New System.Data.SqlClient.SqlParameter("DATE", SqlDbType.DateTime) : pDate.Value = Now
        Dim pModelNo As New System.Data.SqlClient.SqlParameter("MODEL_NO", SqlDbType.NVarChar)
        Dim pmno As String = Trim(Request("Part_NO"))
        If pmno.Length > 500 Then '超過500個字元自動截掉
            pModelNo.Value = Left(pmno, 500)
        Else
            pModelNo.Value = pmno
        End If
       
        Dim pSRID As New System.Data.SqlClient.SqlParameter("SR_ID", SqlDbType.NVarChar) : pSRID.Value = sr_id
        Dim pPLine As New System.Data.SqlClient.SqlParameter("PRODUCT_LINE", SqlDbType.NVarChar) : pPLine.Value = p_group
        Dim pDownloader As New System.Data.SqlClient.SqlParameter("DOWNLOADER", SqlDbType.NVarChar) : pDownloader.Value = Session("user_id")
        Dim para() As System.Data.SqlClient.SqlParameter = {pFileID, pFileName, pFileDesc, pFileSize, pDate, pModelNo, pSRID, pPLine, pDownloader}
        dbUtil.dbExecuteNoQuery2("MY", sb.ToString(), para)
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
<script type="text/javascript">
    function Close(){
        self.close();
    }
    function TracePage(type, lit_type, rid, ID, url) {
        document.getElementById(ID).href = "javascript:void(0)";
        window.open("MaterialRedirectPage.aspx?Type=" + type + "&C=" + lit_type + "&rid=" + rid + "&url=" + url);
    }
    function GetUrl(ID, url) {
        document.getElementById(ID).href=url;
    }
</script>
    <asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>
        <table width="100%" align="center">
            <tr>
                <td valign="top" align="center">
                    <table width="100%" align="center">
                        <tr runat="server" id="trDisclaim">
                            <td align="center">
                                <table width="100%" align="center">
                                    <tr>
                                        <td><div class="euPageTitle"> Disclaimer</div></td>
                                    </tr>
                                    <tr><td height="3"></td></tr>
                                    <tr>
                                        <td align="center">
                                            <table border="1" style="background-color:#F0F0F0" align="center" width="400">
                                                <tr>
                                                    <td align="center">
                                                        <table align="center">
                                                            <tr>
                                                                <td width="3"></td>
                                                                <td><b>How You May Use Our Material</b><br /><br />
                                                                    The materials contained on this Website are copyrighted, and may not be changed, modified or altered in any way. 
                                                                    You agree that any copies of these materials which you make shall retain all copyright and proprietary notices. 
                                                                    This means that you may not distribute these materials in any fashion without the express written permission of Advantech. 
                                                                    <br /><br />
                                                                    By downloading any of the materials contained in this Website you agree to the terms and provisions as outlined. 
                                                                    If you do not agree to them, do not use this Website or download materials from it. 
                                                                    "Materials" contained in the Advantech Website include, but not limited to, text, documents, graphic images, and other marketing materials and information.
                                                                </td>
                                                                <td width="3"></td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center"><asp:Button runat="server" ID="btnNotAgree" Text="I don't agree" OnClientClick="Close();return false;" />&nbsp;&nbsp;&nbsp;&nbsp;<asp:Button runat="server" ID="btnAgree" Text="I agree" OnClick="btnAgree_Click" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr><td height="5"></td></tr>
                        <tr runat="server" id="trDownload" visible="false">
                            <td>
                                <hr /><br />
                                    <table width="100%">
                                        <tr>
                                            <td><div class="euPageTitle"> Download</div></td>
                                        </tr>
                                        <tr><td height="3"></td></tr>
                                        <tr>
                                            <td>
                                                <table cellspacing="0" cellpadding="3" border="1" style="border-color:#A9C84D" align="center" width="600px">
                                                    <tr>
                                                        <td style="background-color:#E5F39D"></td>
                                                        <td style="background-color:#E5F39D" align="center"><b>File Name</b></td>
                                                        <td style="background-color:#E5F39D" align="center"><b>File Description</b></td>
                                                        <td style="background-color:#E5F39D" align="center"><b>File Size</b></td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" width="30px" align="center">Link</td>
                                                        <td align="center"><asp:HyperLink runat="server" ID="hlDownloadFile" Target="_blank" /></td>
                                                        <td align="center" width="250px"><asp:Label runat="server" ID="lblFileDesc" /></td>
                                                        <td align="center" width="80px"><asp:Label runat="server" ID="lblFileSize" /></td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                
                            </td>
                        </tr>
                        <tr align="center">
                            <td style="color:red" align="left" runat="server" id="td1" visible="false">
                                <h4>
                                There is an error occured while retrieving file from our internal server.<br />
                                Advantech IT has been informed for this error and will fix it ASAP.<br />
                                Sorry for the inconvenience. 
                                </h4>   
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnAgree" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>