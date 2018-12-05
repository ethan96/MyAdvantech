<%@ Page Title="MyAdvantech - Forward Curated Content to AOnline Customer" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Src="AOnlineFunctionLinks.ascx" TagName="AOnlineFunctionLinks" TagPrefix="uc1" %>
<%@ Register Namespace="eBizAEUControls" TagPrefix="uc1" %>
<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim NewCamp As New AOnlineUtil.AOnlineSalesCampaign(User.Identity.Name)
            hdCampId.Value = NewCamp.CampaignRowId
            srcMyList.SelectParameters("CBY").DefaultValue = User.Identity.Name
            If Request("campid") IsNot Nothing AndAlso Request("campid") <> "" Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", String.Format("select isnull(subject,'') as subject, isnull(content_text,'') as content_text, isnull(signature,'') as signature from AONLINE_SALES_CAMPAIGN where row_id='{0}'", Request("campid")))
                If dt.Rows.Count > 0 Then
                    txtSubject.Text = dt.Rows(0).Item("subject").ToString
                    Dim doc As New HtmlAgilityPack.HtmlDocument
                    doc.LoadHtml(dt.Rows(0).Item("content_text").ToString)
                    Dim linkNodes As HtmlAgilityPack.HtmlNodeCollection = doc.DocumentNode.SelectNodes("//table")
                    If linkNodes IsNot Nothing AndAlso linkNodes.Count > 0 Then
                        For Each linkNode As HtmlAgilityPack.HtmlNode In linkNodes
                            If linkNode.HasAttributes Then
                                If linkNode.Attributes("id") IsNot Nothing AndAlso linkNode.Attributes("id").Value IsNot Nothing _
                                    AndAlso Not String.IsNullOrEmpty(linkNode.Attributes("id").Value) _
                                    AndAlso linkNode.Attributes("id").Value = "tbSignature" Then
                                    linkNode.RemoveAll() : Exit For
                                End If
                            End If
                        Next
                    End If
                    editorBody.Content = doc.DocumentNode.OuterHtml
                End If
            Else
                Dim strMyContentCartContents As String = AOnlineUtil.AOnlineSalesCampaign.MyContentCartContents()
                editorBody.Content = _
                    "<table width='750px'>" + _
                    "   <tr style='height:60px'><td>Dear Customer</td></tr>" + _
                    "   <tr><td>" + strMyContentCartContents + "<td></tr>" + _
                    "</table>"
            End If
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
            Dim cmd As New SqlClient.SqlCommand("select top 1 DEFAULT_SIGNATURE1 from AONLINE_SALES_PROFILE where USERID=@UID and DEFAULT_SIGNATURE1 is not null", conn)
            cmd.Parameters.AddWithValue("UID", User.Identity.Name) : conn.Open()
            Dim obj As Object = cmd.ExecuteScalar()
            conn.Close()
            If obj IsNot Nothing Then editorSignature.Content = obj.ToString()
            
            'txtCc.Text = User.Identity.Name + ";"
            If DownloadAndUpdateProductSheetAttachments() > 0 Then
                
            End If
        End If
    End Sub
    
    Function DownloadAndUpdateProductSheetAttachments() As Integer
        Dim retCount As Integer = 0
        Dim MyLocalConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
        Dim MyGlobConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter( _
            " delete from AONLINE_SALES_CAMPAIGN_ATTACHMENTS where campaign_row_id=@CAMPID; " + _
            " select top 10 a.source_id, a.ORIGINAL_URL from AONLINE_SALES_CONTENT_CART a " + _
            " where a.SOURCE_APP='PIS' and a.SESSIONID=@SEID and a.ORIGINAL_URL like 'http%://%' order by a.ADDED_DATE desc", MyLocalConn)
        apt.SelectCommand.Parameters.AddWithValue("CAMPID", hdCampId.Value)
        apt.SelectCommand.Parameters.AddWithValue("SEID", Session.SessionID)
        Dim pisDt As New DataTable
        apt.Fill(pisDt)
        MyGlobConn.Open()
        For Each pisRow As DataRow In pisDt.Rows
            Dim cmd As New SqlClient.SqlCommand( _
                " select COUNT(a.LITERATURE_ID) as c from PIS_LIT_KM a " + _
                " where a.LIT_TYPE='Product - Datasheet' and a.LITERATURE_ID=@LITID and a.FILE_EXT='pdf'", MyGlobConn)
            cmd.Parameters.AddWithValue("LITID", pisRow.Item("source_id"))
            If MyGlobConn.State <> ConnectionState.Open Then MyGlobConn.Open()
            If CInt(cmd.ExecuteScalar()) > 0 Then
                Dim strDlUrl As String = pisRow.Item("ORIGINAL_URL")
                Dim webRequest As Net.HttpWebRequest = _
                    DirectCast(Net.WebRequest.Create(strDlUrl), Net.HttpWebRequest)
                Dim webResponse As Net.HttpWebResponse = DirectCast(webRequest.GetResponse(), Net.HttpWebResponse)
                If webResponse.ContentLength <= 1024 * 1000 * 5 Then
                    Dim fName As String = webResponse.ResponseUri.AbsoluteUri.Substring( _
                        webResponse.ResponseUri.AbsoluteUri.LastIndexOf("/") + 1)
                    Dim extName As String = fName.Substring(fName.LastIndexOf(".") + 1).ToLower()
                    If extName = "ppt" Or extName = "pptx" Or extName = "pdf" Then
                        'lbAtts.Text = "<a target='_blank' href='" + strDlUrl + "'>" + fName + "</a>"
                        Dim wc As New Net.WebClient()
                        Dim bs() As Byte = wc.DownloadData(strDlUrl)
                        Dim cmdUpdAtt As New SqlClient.SqlCommand( _
                            " insert into AONLINE_SALES_CAMPAIGN_ATTACHMENTS " + _
                            " (ROW_ID, CAMPAIGN_ROW_ID, FILE_NAME, FILE_EXT, FILE_BIN, ORIGINAL_URL) " + _
                            " values (@ROWID, @CROWID, @FNAME, @FEXT, @FBIN, @OURL)", MyLocalConn)
                        With cmdUpdAtt.Parameters
                            .AddWithValue("ROWID", System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30))
                            .AddWithValue("CROWID", hdCampId.Value) : .AddWithValue("FNAME", fName) : .AddWithValue("FEXT", "pdf")
                            .AddWithValue("FBIN", bs) : .AddWithValue("OURL", strDlUrl)
                        End With
                        If MyLocalConn.State <> ConnectionState.Open Then MyLocalConn.Open()
                        cmdUpdAtt.ExecuteNonQuery()
                        retCount += 1
                        'AOnlineUtil.AOnlineSalesCampaign.UpdateAttachment(hdCampId.Value, bs, fName, User.Identity.Name)
                    Else
                        'lbAtts.Text = extName + " cannot be attached"
                        'lbAtts.Text = ""
                    End If
                Else
                    'lbAtts.Text = ""
                End If
            End If
        Next
        MyGlobConn.Close() : MyLocalConn.Close()
        Return retCount
    End Function
    
    Protected Sub lnkSave2MySignature_Click(sender As Object, e As System.EventArgs)
        lbSaveSig.Text = ""
        If String.IsNullOrEmpty(editorSignature.Content) Then
            lbSaveSig.Text = "Signature is empty" : Exit Sub
        End If
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
        Dim cmd As New SqlClient.SqlCommand( _
            " delete from AONLINE_SALES_PROFILE where USERID=@UID; " + _
            " insert into AONLINE_SALES_PROFILE (USERID, DEFAULT_SIGNATURE1) values (@UID,@SIG1)", conn)
        cmd.Parameters.AddWithValue("UID", User.Identity.Name) : cmd.Parameters.AddWithValue("SIG1", editorSignature.Content)
        conn.Open() : cmd.ExecuteNonQuery() : conn.Close()
        lbSaveSig.Text = "Saved"
    End Sub
    
    Protected Sub btnSend_Click(sender As Object, e As System.EventArgs)
        lbMsg.Text = ""
        If String.IsNullOrEmpty(hdCampId.Value) Then
            lbMsg.Text = "eDM has been delivered, please start from content search again, thank you." : Exit Sub
        End If
        If String.IsNullOrEmpty(txtSubject.Text) Then
            lbMsg.Text = "Email subject is empty" : Exit Sub
        End If
        Dim arrTo As New ArrayList
        If String.IsNullOrEmpty(txtSendTo.Text) Then
            lbMsg.Text = "Send To list is empty" : Exit Sub
        End If
        txtSendTo.Text = Replace(Replace(Replace(Replace(txtSendTo.Text, ",", ";"), vbCrLf, ";"), vbCr, ";"), vbLf, ";")
        Dim strTo() As String = Split(txtSendTo.Text, ";")
        For Each strEmail As String In strTo
            strEmail = Trim(strEmail)
            If String.IsNullOrEmpty(strEmail) = False Then
                If Util.IsValidEmailFormat(Trim(strEmail)) Then
                    If Not arrTo.Contains(Trim(strEmail)) Then arrTo.Add(Trim(strEmail))
                Else
                    lbMsg.Text = strEmail + " is not a valid email format" : Exit Sub
                End If
            End If
        Next
        If arrTo.Count >= 100 Then
            lbMsg.Text = "Please enter less than 100 emails" : Exit Sub
        End If
       
        If String.IsNullOrEmpty(editorBody.Content) Then
            lbMsg.Text = "Content is empty" : Exit Sub
        End If
        ProcessSending()
    End Sub
    
    Function GetEmailContent() As String
        Dim sb As New System.Text.StringBuilder
        sb.Append(editorBody.Content + "<br/>")
        sb.Append("<table id='tbSignature'><tr><td>" + editorSignature.Content + "</td></tr></table><br/>")
        Return sb.ToString()
    End Function
    
    Function GetCandidateSendToEmailList() As ArrayList
        Dim arrTo As New ArrayList
        txtSendTo.Text = Replace(txtSendTo.Text, ",", ";")
        Dim strTo() As String = Split(txtSendTo.Text, ";")
        For Each strEmail As String In strTo
            If Util.IsValidEmailFormat(Trim(strEmail)) Then
                If Not arrTo.Contains(Trim(strEmail)) Then arrTo.Add(Trim(strEmail))
            End If
        Next
        Return arrTo
    End Function
    
    Sub ProcessSending()
        Dim strContent As String = GetEmailContent()
        Dim arrTo As ArrayList = GetCandidateSendToEmailList()
        Dim Attachments() As System.Net.Mail.Attachment = Nothing, ccList() As String = Nothing, BccList() As String = Nothing
        Dim attDt As DataTable = dbUtil.dbGetDataTable("MyLocal_New", _
        " select FILE_NAME, file_bin from AONLINE_SALES_CAMPAIGN_ATTACHMENTS " + _
        " where CAMPAIGN_ROW_ID='" + hdCampId.Value + "' order by FILE_NAME ")
        If attDt.Rows.Count > 0 Then
            ReDim Attachments(attDt.Rows.Count - 1)
            For i As Integer = 0 To attDt.Rows.Count - 1
                Dim msAtt As New IO.MemoryStream(CType(attDt.Rows(i).Item("file_bin"), Byte()))
                msAtt.Position = 0
                Attachments(i) = New System.Net.Mail.Attachment(msAtt, attDt.Rows(i).Item("FILE_NAME").ToString())
            Next
        End If
        If String.IsNullOrEmpty(txtCc.Text) = False Then
            ccList = Split(Replace(txtCc.Text, ",", ";"), ";")
        End If
        If String.IsNullOrEmpty(txtBcc.Text) = False Then
            BccList = Split(Replace(txtBcc.Text, ",", ";"), ";")
        End If
        AOnlineUtil.AOnlineSalesCampaign.UpdateContent(hdCampId.Value, txtSubject.Text, "", strContent, editorSignature.Content, User.Identity.Name)
        AOnlineUtil.AOnlineSalesCampaign.ReplaceAndUpdateCampaignContentHyperlinkImg(strContent, hdCampId.Value, strContent)
        AOnlineUtil.AOnlineSalesCampaign.Draft2Formal(hdCampId.Value, User.Identity.Name)
        AOnlineUtil.AOnlineSalesCampaign.ImportContacts(hdCampId.Value, User.Identity.Name, arrTo)
        Dim strcampId As String = hdCampId.Value
        hdCampId.Value = ""
        Dim cmd As SqlClient.SqlCommand = Nothing, conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
        conn.Open()
        For Each strEmail As String In arrTo
            Dim tmpTo As New ArrayList
            tmpTo.Add(New CampaignSendToEmail(New Net.Mail.MailAddress(strEmail)))
            Try
                Dim strContactContent As String = ""
                Dim cmdContactId As New SqlClient.SqlCommand("select top 1 row_id from AONLINE_SALES_CAMPAIGN_CONTACT where CAMPAIGN_ROW_ID=@CID and CONTACT_EMAIL=@EM", conn)
                cmdContactId.Parameters.AddWithValue("CID", strcampId) : cmdContactId.Parameters.AddWithValue("EM", strEmail)
                Dim tmpContactId As String = cmdContactId.ExecuteScalar()
                If tmpContactId IsNot Nothing Then
                    AOnlineUtil.AOnlineSalesCampaign.ReplaceHyperlinkImgWithContactRowId(strContent, tmpContactId, strContactContent)
                    If AOnlineUtil.AOnlineSalesCampaign.SendAOnlineEDM( _
                        tmpTo.ToArray(GetType(CampaignSendToEmail)), txtSubject.Text, strContactContent, True, Attachments, ccList, BccList, "") Then
                        cmd = New SqlClient.SqlCommand( _
                       "update AONLINE_SALES_CAMPAIGN_CONTACT set IS_SENT=1, VIA_SMTP_ADDR=@SM, SENT_DATE=getdate() where campaign_row_id=@CID and CONTACT_EMAIL=@EM", conn)
                        With cmd.Parameters
                            .AddWithValue("CID", strcampId) : .AddWithValue("EM", strEmail) : .AddWithValue("SM", CType(tmpTo(0), CampaignSendToEmail).SendVia)
                        End With
                        If cmd.Connection.State <> ConnectionState.Open Then cmd.Connection.Open()
                        cmd.ExecuteNonQuery()
                    End If
                End If
               
            Catch ex As Exception
                lbMsg.Text = "Error occurred while sending email to " + strEmail
                conn.Close()
                Util.InsertMyErrLog(ex.ToString())
                Exit Sub
            End Try
        Next
        conn.Close()
        txtSendTo.Text = "" : txtSubject.Text = ""
        'editorBody.Content = "" : editorSignature.Content = ""
        txtCc.Text = "" : txtBcc.Text = ""
        lbMsg.Text = "Email has been delivered, thank you!"
    End Sub
    
    Protected Sub dlMyList_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        If dlMyList.SelectedIndex > 0 Then
            hySeeMyList.NavigateUrl = "MyContactList.aspx?ListID=" + dlMyList.SelectedValue : hySeeMyList.Visible = True
        Else
            hySeeMyList.Visible = False
        End If
    End Sub
    
    Protected Sub dlMyList_DataBound(sender As Object, e As System.EventArgs)
        dlMyList.Items.Insert(0, New ListItem("select...", ""))
    End Sub

    Protected Sub btnPopRecipients_Click(sender As Object, e As System.EventArgs)
        txtPopTo.Text = txtSendTo.Text : PanelAddedContents.Visible = True
    End Sub

    Protected Sub btnAddFromSelectedList_Click(sender As Object, e As System.EventArgs)
        If dlMyList.SelectedIndex > 0 Then
            Dim arrTo As New ArrayList
            AOnlineUtil.AOnlineSalesCampaign.ExportContactFromMyContactList(dlMyList.SelectedValue, arrTo)
            Dim strAppendList As String = String.Join(";", arrTo.ToArray())
            If String.IsNullOrEmpty(Trim(txtPopTo.Text)) Then
                txtPopTo.Text = strAppendList
            Else
                txtPopTo.Text += ";" + strAppendList
            End If
        End If
    End Sub

    Protected Sub btnClosePopContactList_Click(sender As Object, e As System.EventArgs)
        txtSendTo.Text = Replace(Replace(Replace(Replace(txtPopTo.Text, vbCrLf, ";"), ",", ";"), vbCr, ";"), vbLf, ";")
        PanelAddedContents.Visible = False
    End Sub

    Protected Sub lnkDelAtt_Click(sender As Object, e As System.EventArgs)
        Dim lnkBtn As LinkButton = CType(sender, LinkButton)
        Dim strAttRowId As String = CType(lnkBtn.NamingContainer.FindControl("hdAttRowId"), HiddenField).Value
        dbUtil.dbExecuteNoQuery("MyLocal_New", "delete from AONLINE_SALES_CAMPAIGN_ATTACHMENTS where row_id='" + strAttRowId + "'")
        gvAtt.DataBind()
    End Sub

    Protected Sub btnConvertToSimpTradChinese_Click(sender As Object, e As System.EventArgs)
        If editorBody.Content IsNot Nothing Then
            If dlChinseType.SelectedIndex = 0 Then
                editorBody.Content = CharSetConverter.ToSimplified(editorBody.Content)
            ElseIf dlChinseType.SelectedIndex = 1 Then
                editorBody.Content = CharSetConverter.ToTraditional(editorBody.Content)
            End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:HiddenField runat="server" ID="hdCampId" />
    <table width="100%">
        <tr align="right">
            <td align="right">
                <uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" />
            </td>
        </tr>
    </table>
    <h2 style="color: Navy">
        Forward Marketing Content to Customer</h2>
    <br />
    <table width="100%">
        <tr>
            <td valign="top">
                <table width="100%">
                    <tr>
                        <td style="width: 10%">
                            <asp:Button runat="server" ID="btnSend" Font-Bold="true" Font-Size="Large" Text="Send"
                                Height="80px" Width="70px" OnClick="btnSend_Click" />
                        </td>
                        <td style="width: 90%">
                            <table width="100%">
                                <tr>
                                    <th align="left" style="width: 10%">
                                        <asp:Button runat="server" ID="btnPopRecipients" Text="Recipients:" Font-Bold="true"
                                            OnClick="btnPopRecipients_Click" />
                                    </th>
                                    <td style="width: 90%">
                                        <asp:UpdatePanel runat="server" ID="upSendTo" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:TextBox runat="server" ID="txtSendTo" Width="90%" TextMode="MultiLine" Height="40px" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnClosePopContactList" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="btnSend" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                        <asp:UpdatePanel runat="server" ID="upPanelMyList" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender2" runat="server"
                                                    TargetControlID="PanelAddedContents" HorizontalSide="Center" VerticalSide="Middle"
                                                    HorizontalOffset="0" VerticalOffset="0" />
                                                <asp:Panel runat="server" ID="PanelAddedContents" Visible="false" BackColor="Azure">
                                                    <table width="100%" style="border-style: double">
                                                        <tr>
                                                            <td align="right">
                                                                <asp:Button runat="server" ID="btnClosePopContactList" Text="Close" OnClick="btnClosePopContactList_Click" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">
                                                                My Contents
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Panel runat="server" ID="PanelContactList" Width="800px" Height="200px" ScrollBars="Auto">
                                                                    <table width="100%">
                                                                        <tr>
                                                                            <td>
                                                                                <asp:Button runat="server" ID="btnAddFromSelectedList" Text="Add" OnClick="btnAddFromSelectedList_Click" />
                                                                            </td>
                                                                            <td>
                                                                                <asp:DropDownList runat="server" ID="dlMyList" DataTextField="LIST_NAME" DataSourceID="srcMyList"
                                                                                    DataValueField="ROW_ID" OnSelectedIndexChanged="dlMyList_SelectedIndexChanged"
                                                                                    AutoPostBack="true" OnDataBound="dlMyList_DataBound" />
                                                                                <asp:SqlDataSource runat="server" ID="srcMyList" ConnectionString="<%$ConnectionStrings:MyLocal_New %>"
                                                                                    SelectCommand="select top 10 ROW_ID, LIST_NAME, CREATED_DATE, (select count(z.row_id) from AONLINE_SALES_CONTACTLIST_DETAIL z where z.LIST_ID=a.ROW_ID) as contacts 
                                                                                        from AONLINE_SALES_CONTACTLIST_MASTER a where a.USERID=@CBY order by CREATED_DATE desc">
                                                                                    <SelectParameters>
                                                                                        <asp:Parameter ConvertEmptyStringToNull="false" Name="CBY" />
                                                                                    </SelectParameters>
                                                                                </asp:SqlDataSource>
                                                                            </td>
                                                                            <td>
                                                                                <asp:UpdatePanel runat="server" ID="upMyListDetail" UpdateMode="Conditional">
                                                                                    <ContentTemplate>
                                                                                        <asp:HyperLink Visible="false" runat="server" ID="hySeeMyList" NavigateUrl='MyContactList.aspx'
                                                                                            Text="See Contacts" Target="_blank" />
                                                                                    </ContentTemplate>
                                                                                    <Triggers>
                                                                                        <asp:AsyncPostBackTrigger ControlID="dlMyList" EventName="SelectedIndexChanged" />
                                                                                    </Triggers>
                                                                                </asp:UpdatePanel>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                Recipients:
                                                                            </td>
                                                                            <td colspan="2">
                                                                                <asp:TextBox runat="server" ID="txtPopTo" Width="600px" TextMode="MultiLine" Height="40px" />
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </asp:Panel>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnPopRecipients" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr runat="server" visible="false">
                                    <th align="left" style="width: 10%">
                                        Cc:
                                    </th>
                                    <td style="width: 90%">
                                        <asp:UpdatePanel runat="server" ID="upCc" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:TextBox runat="server" ID="txtCc" Width="90%" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnSend" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>                                        
                                    </td>
                                </tr>
                                <tr runat="server" visible="false">
                                    <th align="left" style="width: 10%">
                                        Bcc:
                                    </th>
                                    <td style="width: 90%">                                        
                                        <asp:UpdatePanel runat="server" ID="upBcc" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:TextBox runat="server" ID="txtBcc" Width="90%" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnSend" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>      
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 10%">
                                        Subject:
                                    </th>
                                    <td style="width: 90%">                                        
                                        <asp:UpdatePanel runat="server" ID="upSubject" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:TextBox runat="server" ID="txtSubject" Width="90%" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnSend" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>      
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left" style="width: 10%">
                                        Attachment:
                                    </th>
                                    <td style="width: 90%">
                                        <asp:UpdatePanel runat="server" ID="upAtt" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:GridView runat="server" ID="gvAtt" DataSourceID="srcAtt" AutoGenerateColumns="false" Width="80%" ShowHeader="false">
                                                    <Columns>
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:HiddenField runat="server" ID="hdAttRowId" Value='<%#Eval("ROW_ID") %>' />
                                                                <a style="font-weight: bold; font-size: small; color: #114B9F" target="_blank" href='<%# Eval("ORIGINAL_URL")%>'>
                                                                    <%# Eval("FILE_NAME")%>
                                                                </a>&nbsp;
                                                                <asp:LinkButton runat="server" ID="lnkDelAtt" Text="X" Font-Bold="true" ForeColor="Black"
                                                                    OnClick="lnkDelAtt_Click" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>                                                
                                                <asp:SqlDataSource runat="server" ID="srcAtt" ConnectionString="<%$ConnectionStrings:MYLOCAL_NEW %>"
                                                    SelectCommand="select FILE_NAME, ORIGINAL_URL, ROW_ID from AONLINE_SALES_CAMPAIGN_ATTACHMENTS where CAMPAIGN_ROW_ID=@CAMPID order by FILE_NAME">
                                                    <SelectParameters>
                                                        <asp:ControlParameter ControlID="hdCampId" ConvertEmptyStringToNull="false" PropertyName="Value"
                                                            Name="CAMPID" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="height: 20px">
                <asp:UpdatePanel runat="server" ID="upSendMsg" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSend" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td valign="top">
                <table width="100%">
                    <tr>
                        <td colspan="2" align="right">
                            <table>
                                <tr>
                                    <th align="left">Convert to:</th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="dlChinseType">
                                            <asp:ListItem Value="Simplified" Selected="True" />
                                            <asp:ListItem Value="Traditional" />
                                        </asp:DropDownList>
                                    </td>
                                    <th align="left">Chinese</th>
                                    <td>
                                        <asp:Button runat="server" ID="btnConvertToSimpTradChinese" Text="Convert" OnClick="btnConvertToSimpTradChinese_Click" />
                                    </td>
                                    <td style="width:20px">&nbsp;</td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <ajaxToolkit:Editor runat="server" ID="editorBody" Width="890px" Height="500px" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnSend" EventName="Click" />
                                    <asp:AsyncPostBackTrigger ControlID="btnConvertToSimpTradChinese" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <b>Signature:</b>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <uc1:NoToolBarEditor runat="server" ID="editorSignature" Width="890px" Height="100px" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:LinkButton runat="server" ID="lnkSave2MySignature" Text="Save as My Signature"
                                OnClick="lnkSave2MySignature_Click" />
                        </td>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upSaveSig" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Label runat="server" ID="lbSaveSig" ForeColor="Tomato" /></ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="lnkSave2MySignature" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
