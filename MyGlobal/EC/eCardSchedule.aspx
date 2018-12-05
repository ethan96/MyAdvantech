<%@ Page Title="MyAdvantech - eCard Schedule List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" EnableEventValidation="false" %>

<script runat="server">
    Protected Sub btnView_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lblBody.Text = CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnTemplate"), HiddenField).Value
        btnClose.Visible = True
        lblBody.Visible = True
        ModalPopupExtender1.Show()
    End Sub

    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        btnClose.Visible = False
        lblBody.Visible = False
        ModalPopupExtender1.Hide()
    End Sub

    Protected Sub btnViewSendto_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select email from CHRISTMAS_SEND_LOG where row_id='{0}'", gv1.DataKeys(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).RowIndex).Item("ROW_ID").ToString))
        Dim SendTo As New ArrayList
        For Each row As DataRow In dt.Rows
            If row.Item("email").ToString.Contains(",") Then
                txtSendTo.Text = row.Item("email").ToString.Replace(",", ControlChars.Lf)
            Else
                SendTo.Add(row.Item("email").ToString)
            End If
        Next
        If SendTo.Count > 0 Then txtSendTo.Text = String.Join(ControlChars.Lf, SendTo.ToArray())
        tb1.Visible = True
        ModalPopupExtender2.Show()
    End Sub

    Protected Sub btnClose1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtSendTo.Text = ""
        tb1.Visible = False
        ModalPopupExtender2.Hide()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Request.IsAuthenticated Or Session("user_id") Is Nothing Then Response.Redirect("../home.aspx?ReturnUrl=%2fEC%2feCardSchedule.aspx") : Exit Sub
    End Sub

    Protected Sub btnSend_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            Dim row_id As String = gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Item("ROW_ID").ToString
            Dim subject As String = gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Item("SUBJECT").ToString
            Dim card_id As String = gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Item("CARD_ID").ToString
            'Dim bmp As Drawing.Bitmap = WebsiteThumbnail.GetThumbnail("http://my.advantech.com/EC/GenerateCardThumbnail.ashx?RowId=" + row_id, 820, 630, 820, 630)
            Dim dtImage As DataTable = dbUtil.dbGetDataTable("MYLocal", String.Format("select isnull(IMAGE_WIDTH,0) as IMAGE_WIDTH, isnull(IMAGE_HEIGHT,0) as IMAGE_HEIGHT from CHRISTMAS_CARD where ROW_ID='{0}'", card_id))
            Dim ws As New aclecampaign.EC
            ws.UseDefaultCredentials = True : ws.Timeout = -1
            Dim by() As Byte = ws.GenarateECard(row_id, CInt(dtImage.Rows(0).Item("image_width")), CInt(dtImage.Rows(0).Item("image_height")))
            
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select email, send_by from CHRISTMAS_SEND_LOG where row_id='{0}' and is_sent=0", row_id))
            Dim SendOne As Boolean = True
            If dt.Rows.Count = 1 Then SendOne = False
            Dim send_by As String = dt.Rows(0).Item("send_by").ToString
            
            Dim SendTo As New ArrayList
            If Not SendOne Then
                Dim emails() As String = dt.Rows(0).Item(0).ToString.Split(",")
                For Each email As String In emails
                    If email.Trim <> "" Then SendTo.Add(email)
                Next
            Else
                For Each row As DataRow In dt.Rows
                    SendTo.Add(row.Item("email").ToString)
                Next
            End If
            
            If SendTo IsNot Nothing AndAlso SendTo.Count > 0 Then
                Dim RandomClass As New Random()
                Dim smtp() As String = {"ACLSMTPServer", "ACLSMTPServer2"}
                If SendOne Then
                    For Each email As String In SendTo
                        Dim RandomNumber As Integer = RandomClass.Next(2)
                        Dim ms As New System.IO.MemoryStream(by)
                        'bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
                        ms.Position = 0
                        SendCard(ms, {email}, subject, smtp(RandomNumber), send_by)
                        ms.Dispose()
                        dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("update christmas_send_log set is_sent=1, smtp='{2}' where row_id='{0}' and email='{1}'", row_id, email, smtp(RandomNumber)))
                    Next
                Else
                    Dim RandomNumber As Integer = RandomClass.Next(2)
                    Dim ms As New System.IO.MemoryStream(by)
                    'bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
                    ms.Position = 0
                    SendCard(ms, SendTo.ToArray(GetType(String)), subject, smtp(RandomNumber), send_by)
                    ms.Dispose()
                    dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("update christmas_send_log set is_sent=1, smtp='{1}' where row_id='{0}'", row_id, smtp(RandomNumber)))
                End If
            End If
            
            Util.AjaxJSAlert(up1, "Your eCard has been delivered, thank you!")
            gv1.DataBind()
        Catch ex As Exception
            Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Send eCard Error", ex.ToString, True, "", "")
        End Try
    End Sub
    
    Public Sub SendCard(ByVal ms As System.IO.MemoryStream, ByVal SendTo As String(), ByVal subject As String, ByVal smtp As String, ByVal send_by As String)
        Dim m1 As New System.Net.Mail.SmtpClient
        m1.Host = ConfigurationManager.AppSettings(smtp)
        'm1.Host = "172.21.34.21"
        Dim msg As New System.Net.Mail.MailMessage
        msg.From = New System.Net.Mail.MailAddress(send_by)
        Dim MailBody As String = "<table><tr><td width='830' height='630'><img src=cid:Img1></td></tr></table>"
        Dim av1 As System.Net.Mail.AlternateView = System.Net.Mail.AlternateView.CreateAlternateViewFromString(MailBody, System.Text.Encoding.UTF8, System.Net.Mime.MediaTypeNames.Text.Html)
        Dim ImgLinkSrc As New System.Net.Mail.LinkedResource(ms)
        ImgLinkSrc.ContentId = "Img1"
        ImgLinkSrc.ContentType.Name = "eCard.png"
        av1.LinkedResources.Add(ImgLinkSrc)
        msg.AlternateViews.Add(av1)
        msg.IsBodyHtml = True
        msg.SubjectEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.BodyEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.Subject = subject
        For Each email As String In SendTo
            msg.To.Add(email)
        Next
        m1.Send(msg)

        For i As Integer = 0 To msg.AlternateViews.Count - 1
            For j As Integer = 0 To msg.AlternateViews.Item(i).LinkedResources.Count - 1
                msg.AlternateViews.Item(i).LinkedResources.Item(j).ContentStream.Close()
            Next
        Next
    End Sub

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table class="at-maincontainer">
        <tr>
            <td>
                <div id="navtext"><a style="color:Black" href="../home.aspx">Home</a> > <a style="color:Black" href="../EC/eCard.aspx">Send eCard</a> > My eCard Schedule List</div><br />
                <div style="font-size: 22px;color: #000;font-weight: bold;font-family: Arial, Helvetica, sans-serif;">My eCard Schedule List</div>
            </td>
        </tr>
        <tr><td height="10"></td></tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" Width="100%" DataSourceID="sql1" AllowPaging="true" AllowSorting="true" PageSize="20" DataKeyNames="ROW_ID,SUBJECT">
                            <Columns>
                                <asp:CommandField ShowDeleteButton="true" />
                                <asp:TemplateField HeaderText="Template" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton runat="server" ID="btnView" Text="View" OnClick="btnView_Click" />
                                        <asp:HiddenField runat="server" ID="hdnTemplate" Value='<%#Eval("template_content") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="subject" HeaderText="Subject" SortExpression="subject" />
                                <asp:TemplateField HeaderText="Content">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lblGreeting" Text='<%#Eval("greeting") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Signature">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lblSig" Text='<%#Eval("signature") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Send To List" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton runat="server" ID="btnViewSendto" Text="View" OnClick="btnViewSendto_Click" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Button runat="server" ID="btnSend" Text="Send Immediately" Width="150px" Enabled='<%#Eval("is_sent") %>' OnClick="btnSend_Click" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:LinkButton runat="server" ID="link1" />
                        <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1" PopupControlID="Panel1" 
                            PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground">
                        </ajaxToolkit:ModalPopupExtender>
                        <asp:Panel runat="server" ID="Panel1">
                            <table width="100%">
                                <tr><td align="right"><asp:ImageButton runat="server" ID="btnClose" ImageUrl="~/images/close1.jpg" Width="30" OnClick="btnClose_Click" Visible="false" /></td></tr>
                                <tr><td><asp:Label runat="server" ID="lblBody" Visible="false" /></td></tr>
                            </table>
                        </asp:Panel>
                        <asp:LinkButton runat="server" ID="link2" />
                        <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender2" BehaviorID="modalPopup2" PopupControlID="Panel2" 
                            PopupDragHandleControlID="Panel2" TargetControlID="link2" BackgroundCssClass="modalBackground">
                        </ajaxToolkit:ModalPopupExtender>
                        <asp:Panel runat="server" ID="Panel2">
                            <table width="450" height="250" runat="server" id="tb1" visible="false" style="border-width:1px; border-color:Gray; border-style:solid; background-color:White">
                                <tr><td align="right"><asp:LinkButton runat="server" ID="btnClose1" Text="[Close]" OnClick="btnClose1_Click" /></td></tr>
                                <tr><td align="center"><asp:TextBox runat="server" ID="txtSendTo" TextMode="MultiLine" Width="400" Height="200" Enabled="false" /></td></tr>
                                <tr><td height="5"></td></tr>
                            </table>
                        </asp:Panel>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings:MYLOCAL %>"
                    SelectCommand="select distinct a.row_id, a.subject, a.send_by, a.template_content, a.greeting, a.signature, case (select count(z.email) from CHRISTMAS_SEND_LOG z where z.row_id=a.row_id and z.is_schedule =1 and z.is_sent=0) when 0 then 'false' else 'true' end as is_sent from CHRISTMAS_SEND_LOG a where a.is_schedule =1 and send_by=@SEND_BY" 
                    DeleteCommand="delete from christmas_send_log where row_id=@ROW_ID">
                    <SelectParameters>
                        <asp:SessionParameter Type="String" Name="SEND_BY" SessionField="user_id" />
                    </SelectParameters>
                </asp:SqlDataSource>
            </td>
        </tr>
    </table>
</asp:Content>

