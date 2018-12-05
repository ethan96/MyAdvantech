<%@ Page Title="MyAdvantech - eCard" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>
<%@ Register TagPrefix="ed" Namespace="OboutInc.Editor" Assembly="obout_Editor" %>
<%@ Register TagPrefix="Upload" Namespace="Brettle.Web.NeatUpload" Assembly="Brettle.Web.NeatUpload" %>
<%@ Register namespace="eBizAEUControls" tagprefix="uc1" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Request.IsAuthenticated Or Session("user_id") Is Nothing Then Response.Redirect("../home.aspx?ReturnUrl=%2fEC%2feCard.aspx") : Exit Sub
        'If MailUtil.IsInRole("AOnline.estore") Or MailUtil.IsInRole("AOnline.Marketing") Or MailUtil.IsInRole("ITD.ACL") Then
        '    btnUploadTemplate.Visible = True
        'Else
        '    btnUploadTemplate.Visible = False
        'End If
        If Not Page.IsPostBack Then
            'rblGreeting.Items(0).Selected = True
            FillCardInfo()
        End If
    End Sub
    
    Sub FillCardInfo()
        hdnWidth.Value = "0" : hdnHeight.Value = "0"
        GetTemplateImageInfo()
        If ddlLang.SelectedIndex = 1 Then
            txtSubject.Text = "研華祝您  新年快樂!!!"
            'edContent.Text = GetGreeting(0).Replace("<br/>", ControlChars.Lf)
            edContent.Content = GetMailBody(GetGreeting("0"))
            rblGreeting.Visible = False
            rblSend.Items(0).Text = "一個email發送一封eCard" : rblSend.Items(1).Text = "所有emails一起發送在一封eCard裡 (收件者將會看到其他收件者的email在收件者名單中)"
        Else
            txtSubject.Text = "研華祝您  新年快樂!!!"
            'edContent.Text = GetGreeting(1).Replace("<br/>", ControlChars.Lf)
            edContent.Content = GetMailBody(GetGreeting("1"))
            rblGreeting.Visible = True
            rblGreeting.DataBind()
            rblGreeting.Items.Remove(rblGreeting.Items.FindByValue("0"))
            rblSend.Items(0).Text = "Send to One by One" : rblSend.Items(1).Text = "Send to All in one eCard (receivers will see other people's emails in the Send To list)"
        End If
        'edSig.Text = "Best Regards,"
    End Sub

    Protected Sub btnSend_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") IsNot Nothing And Request.IsAuthenticated Then
            If HasInvalidCardInfo() Then Exit Sub
            Dim SendTo As ArrayList = GetSendList()
            If SendTo IsNot Nothing AndAlso SendTo.Count > 0 Then
                Dim _smtp As String = "", _email As String = ""
                Dim RandomClass As New Random()
                Dim row_id As String = LogSendToInfo(SendTo, False)
                Try
                    'Dim bmp As Drawing.Bitmap = WebsiteThumbnail.GetThumbnail("http://my.advantech.com/EC/GenerateCardThumbnail.ashx?RowId=" + row_id, hdnImgWidth.Value, hdnImgHeight.Value, hdnImgWidth.Value, hdnImgHeight.Value)
                    Dim bmp As Drawing.Bitmap = WebsiteThumbnail.GetThumbnail("http://my.advantech.com/EC/GenerateCardThumbnail.ashx?RowId=" + row_id, CInt(hdnImgWidth.Value), CInt(hdnImgHeight.Value), CInt(hdnImgWidth.Value), CInt(hdnImgHeight.Value))
                    Dim msB As New System.IO.MemoryStream()
                    bmp.Save(msB, System.Drawing.Imaging.ImageFormat.Png)
                    'Dim ws As New aclecampaign.EC
                    'ws.UseDefaultCredentials = True : ws.Timeout = -1
                    'Dim by() As Byte = ws.GenarateECard(row_id, CInt(hdnImgWidth.Value), CInt(hdnImgHeight.Value))
                    Dim by() As Byte = msB.ToArray()
                    Dim smtp() As String = {"Amazon"}
                    If rblSend.SelectedIndex = 0 Then
                        For Each email As String In SendTo
                            'Dim RandomNumber As Integer = RandomClass.Next(2)
                            Dim ms As New System.IO.MemoryStream(by)
                            'bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
                            ms.Position = 0
                            _smtp = smtp(0) : _email = email
                            SendCard(ms, {email}, smtp(0))
                            ms.Dispose()
                            dbUtil.dbExecuteNoQuery("MY", String.Format("update christmas_send_log set is_sent=1, smtp='{2}' where row_id='{0}' and email='{1}'", row_id, email, smtp(0)))
                        Next
                    Else
                        'Dim RandomNumber As Integer = RandomClass.Next(2)
                        Dim ms As New System.IO.MemoryStream(by)
                        _smtp = smtp(0)
                        'bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
                        ms.Position = 0
                        SendCard(ms, SendTo.ToArray(GetType(String)), smtp(0))
                        ms.Dispose()
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update christmas_send_log set is_sent=1, smtp='{1}' where row_id='{0}'", row_id, smtp(0)))
                    End If
                    txtEmail.Text = ""
                    Util.AjaxJSAlert(up1, "Your ecard has been delivered, thank you!")
                Catch ex As Exception
                    If _email <> "" Then dbUtil.dbExecuteNoQuery("MY", String.Format("update christmas_send_log set is_sent=0, smtp='{1}' where row_id='{0}' and email='{2}'", row_id, _smtp, _email))
                    If _email = "" Then dbUtil.dbExecuteNoQuery("MY", String.Format("update christmas_send_log set is_sent=0, smtp='{1}' where row_id='{0}'", row_id, _smtp))
                    Util.SendEmail("rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "Send eCard Error", ex.ToString, True, "", "")
                End Try
            End If
        Else
            Util.AjaxJSAlertRedirect(up1, "Please sign in MyAdvantech.", "../home.aspx?ReturnUrl=%2fEC%2feCard.aspx")
        End If
    End Sub
    
    Public Function HasInvalidCardInfo() As Boolean
        Dim isError As Boolean = False
        lblMsg.Text = ""
        'If ddlTemplate.SelectedValue = "" Then lblMsg.Text += "Please select a Christmas Card first. Thank you." : isError = True
        If rblTemplate.SelectedValue = "" Then lblMsg.Text += "Please select a eCard first. Thank you." : isError = True
        If txtSubject.Text.Replace("'", "").Trim = "" Then lblMsg.Text += "Please input email subject.<br/>" : isError = True
        If txtEmail.Text.Replace("'", "").Replace(ControlChars.Lf, "").Replace(";", "").Trim = "" Then lblMsg.Text += "Please input at least one email.<br/>" : isError = True
        'If edContent.Text.Replace("'", "").Replace(ControlChars.Lf, "").Trim = "" Then lblMsg.Text += "Please input the content." : isError = True
        If isError = True Then Return True
        Return False
    End Function
    
    Public Function GetSendList() As ArrayList
        Dim SendTo As New ArrayList
        Dim arrEmail As String() = txtEmail.Text.Replace(ControlChars.Lf, ";").Split(";")
        Dim has_invalid As Boolean = False
        For Each email As String In arrEmail
            If email.Trim <> "" Then
                If Util.IsValidEmailFormat(email.Trim) Then
                    SendTo.Add(email.Trim)
                Else
                    lblMsg.Text += email + " is not a valid email format.<br/>" : has_invalid = True
                End If
            End If
        Next
        If has_invalid Then Return Nothing
        If SendTo.Count > 1000 Then Util.AjaxJSAlert(up1, "There are more than 1000 emails in the Send To list. For performance issue, please reduce it in 1000 emails. Thank you!") : Return Nothing
        Return SendTo
    End Function
    
    Public Function LogSendToInfo(ByVal SendTo As ArrayList, ByVal is_schedule As Boolean) As String
        Dim body As String = edContent.Content
        Dim row_id As String = NewId()
        If rblSend.SelectedIndex = 0 Then
            For Each email As String In SendTo
                'Util.SendEmail(email.Trim, Session("user_id"), txtSubject.Text.Trim, body, True, "", "")
                'dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("insert into christmas_send_log (email,send_by,subject,template_content,is_sent,row_id,signature,is_schedule,greeting,card_id) values (N'{0}','{1}',N'{2}',N'{3}',0,'{4}',N'{5}','{6}',N'{7}','{8}')", email.Replace("'", "''").Trim, Session("user_id"), txtSubject.Text.Replace("'", "''").Trim, body.Replace("'", "''"), row_id, edSig.Text.Replace("'", "''").Replace(ControlChars.Lf, "<br/>").Trim, is_schedule, edContent.Text.Replace("'", "''").Replace(ControlChars.Lf, "<br/>").Trim, rblTemplate.SelectedValue))
                dbUtil.dbExecuteNoQuery("MY", String.Format("insert into christmas_send_log (email,send_by,subject,template_content,is_sent,row_id,signature,is_schedule,greeting,card_id) values (N'{0}','{1}',N'{2}',N'{3}',0,'{4}',N'{5}','{6}',N'{7}','{8}')", email.Replace("'", "''").Trim, Session("user_id"), txtSubject.Text.Replace("'", "''").Trim, body.Replace("'", "''"), row_id, "", is_schedule, GetGreeting(rblGreeting.SelectedValue).Replace("'", "''").Replace(ControlChars.Lf, "<br/>").Trim, rblTemplate.SelectedValue))
            Next
        Else
            'Util.SendEmail(String.Join(",", SendTo.ToArray()), Session("user_id"), txtSubject.Text.Trim, body, True, "", "")
            dbUtil.dbExecuteNoQuery("MY", String.Format("insert into christmas_send_log (email,send_by,subject,template_content,is_sent,row_id,signature,is_schedule,greeting,card_id) values (N'{0}','{1}',N'{2}',N'{3}',0,'{4}',N'{5}','{6}',N'{7}','{8}')", String.Join(",", SendTo.ToArray()).Replace("'", "''"), Session("user_id"), txtSubject.Text.Replace("'", "''").Trim, body.Replace("'", "''"), row_id, "", is_schedule, GetGreeting(rblGreeting.SelectedValue).Replace("'", "''").Replace(ControlChars.Lf, "<br/>").Trim, rblTemplate.SelectedValue))
        End If
        Return row_id
    End Function
    
    Public Sub SendCard(ByVal ms As System.IO.MemoryStream, ByVal SendTo As String(), ByVal smtp As String)
        'Dim m1 As New System.Net.Mail.SmtpClient
        'm1.Host = ConfigurationManager.AppSettings(smtp)
        'm1.Credentials = New Net.NetworkCredential("EDM_Advantech", "!Advant258")
        
        Dim msg As New System.Net.Mail.MailMessage
        msg.From = New Net.Mail.MailAddress("eDM_Advantech@advantech-ebiz.eu", Session("user_id"), Text.Encoding.UTF8)
        msg.ReplyToList.Add(New Net.Mail.MailAddress(Session("user_id"), Session("user_id"), Text.Encoding.UTF8))
        msg.Body = GetMailBody(edContent.PlainText.Replace(ControlChars.Lf, "<br/>"))
        'Dim MailBody As String = "<table><tr><td width='" + hdnImgWidth.Value + "' height='" + hdnImgHeight.Value + "'><img src=cid:Img1></td></tr></table>"
        'Dim av1 As System.Net.Mail.AlternateView = System.Net.Mail.AlternateView.CreateAlternateViewFromString(MailBody, System.Text.Encoding.UTF8, System.Net.Mime.MediaTypeNames.Text.Html)
        'Dim ImgLinkSrc As New System.Net.Mail.LinkedResource(ms)
        'ImgLinkSrc.ContentId = "Img1"
        'ImgLinkSrc.ContentType.Name = "eCard.png"
        'av1.LinkedResources.Add(ImgLinkSrc)
        'msg.AlternateViews.Add(av1)
        msg.IsBodyHtml = True
        msg.SubjectEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.BodyEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.Subject = txtSubject.Text.Trim
        For Each email As String In SendTo
            msg.To.Add(email)
        Next
        'm1.Send(msg)

        If LCase(SendTo(0)) Like "*@advantech*.*" Then
            Dim mySmtpClient As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
            mySmtpClient.Send(msg)
        Else
            Dim mySmtpClient As New System.Net.Mail.SmtpClient("172.20.2.122")

            msg.From = New Net.Mail.MailAddress("edm.advantech@edm-advantech.com", Session("user_id"), Text.Encoding.UTF8)
            'htmlMessage.From = New Net.Mail.MailAddress(source_email, sender_name, Text.Encoding.UTF8)
            Dim err As String = ""
            Dim ret As Boolean = True
            Try
                mySmtpClient.Send(msg)
            Catch ex1 As Net.Mail.SmtpException
                ret = False : err = ex1.ToString
            Catch ex2 As Exception
                ret = False : err = ex2.ToString
            End Try
            
            'Dim ws As New aclecampaign.EC
            'ws.UseDefaultCredentials = True : ws.Timeout = -1
            
            'Dim ret As Boolean = ws.SendEDMFromAmazon(ms.ToArray(), SendTo(0), txtSubject.Text.Trim, MailBody, Session("user_id"), err)
            If ret = False Then
                Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Send eCard Error", err, True, "", "")
            End If
            
            'Dim AmazonClient As New Amazon.SimpleEmail.AmazonSimpleEmailServiceClient("AKIAIKMEOIM7JRSWOFIA", "HjIuHdUQ5GEG7w/volh/mgOvOmmqbRvH2lH9KX6S")
            'Try
            '    Dim listColl As New System.Collections.Generic.List(Of String)
            '    listColl.Add(msg.To.Item(0).Address)
            '    msg.From = New Net.Mail.MailAddress("edm.advantech@edm-advantech.com", Session("user_id"), Encoding.UTF8)
            '    Dim mailObj As New Amazon.SimpleEmail.Model.SendRawEmailRequest
            '    mailObj.Source = "edm.advantech@edm-advantech.com"
            '    Dim assembly As System.Reflection.Assembly = GetType(Net.Mail.SmtpClient).Assembly
            '    Dim _mailWriterType As Type = assembly.[GetType]("System.Net.Mail.MailWriter")
            '    Dim _fileStream As New IO.MemoryStream()
            '    Dim _mailWriterContructor As Reflection.ConstructorInfo = _mailWriterType.GetConstructor(Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic, Nothing, New Type() {GetType(IO.Stream)}, Nothing)
            '    Dim _mailWriter As Object = _mailWriterContructor.Invoke(New Object() {_fileStream})
            '    Dim _sendMethod As Reflection.MethodInfo = GetType(Net.Mail.MailMessage).GetMethod("Send", Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic)
            '    _sendMethod.Invoke(msg, Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic, Nothing, New Object() {_mailWriter, True}, Nothing)
            '    Dim _closeMethod As Reflection.MethodInfo = _mailWriter.[GetType]().GetMethod("Close", Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic)
            '    Dim m As New IO.MemoryStream
            '    _fileStream.WriteTo(m)
            '    _closeMethod.Invoke(_mailWriter, Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic, Nothing, New Object() {}, Nothing)
            '    Dim rm As New Amazon.SimpleEmail.Model.RawMessage
            '    rm.WithData(m)
            '    mailObj.RawMessage = rm
            '    AmazonClient.SendRawEmail(mailObj)
            'Catch ex As Amazon.SimpleEmail.Model.MessageRejectedException
            
            'End Try
        End If
        
        
        For i As Integer = 0 To msg.AlternateViews.Count - 1
            For j As Integer = 0 To msg.AlternateViews.Item(i).LinkedResources.Count - 1
                msg.AlternateViews.Item(i).LinkedResources.Item(j).ContentStream.Close()
            Next
        Next
    End Sub
    
    Private Function NewId() As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MY", "select count(ROW_ID) as counts from CHRISTMAS_SEND_LOG where ROW_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    
    Public Function GetMailBody(ByVal content As String) As String
        'Dim body As String = "<html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml'><head>" + _
        '                                    "<style type='text/css'>v\:* { behavior: url(#default#VML); display:inline-block}</style></head><body>" + _
        '                                    "<table width='799' border='0' align='center' cellpadding='0' cellspacing='0'>" + _
        '                                    "<tr><td height='372' colspan='3'><img src='http://my.advantech.com/images/top.jpg' width='800' height='377'/></td></tr>" + _
        '                                    "<tr><td width='214' height='220' align='left' valign='top'><img src='http://my.advantech.com/images/down_left.jpg' width='214' height='223'/></td>" + _
        '                                    "<td width='369' align='left' valign='top' style='font-size:14px;font-family: Arial, Helvetica, sans-serif;background-image: url(http://my.advantech.com/images/down_middle.jpg);background-repeat: no-repeat'>" + edContent.Text.Replace(ControlChars.Lf, "<br/>") + "<br/><br/>" + edSig.Text.Replace(ControlChars.Lf, "<br/>") + _
        '                                    "<!--[if gte vml 1]><v:shape stroked='f' style= 'position:absolute;z-index:-1;visibility:visible;width:369px;height:223px;top:0;left:0;border:0;'><v:imagedata src='http://my.advantech.com/images/down_middle.jpg'/></v:shape><![endif]-->" + _
        '                                    "</td><td width='217' align='left' valign='top'><img src='http://my.advantech.com/images/down_right.jpg' width='217' height='223'/></td></tr></table></body></html>"
        
        'Dim body As String = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /></head><body>" + _
        '                    "<table width='799' border='0' align='center' cellpadding='0' cellspacing='0'>" + _
        '                    "<tr><td height='372' colspan='3'><img src='http://my.advantech.com/images/top.jpg' width='800' height='377'/></td></tr>" + _
        '                    "<tr><td width='214' height='220'><img src='http://my.advantech.com/images/down_left.jpg' width='214' height='223'/></td>" + _
        '                    "<td width='369' valign='top' style='background-image: url(http://my.advantech.com/images/down_middle.jpg);background-repeat: no-repeat'><table cellpadding='0' cellspacing='0' border='0'><tr><td width='30px'></td><td style='font-size:14px;font-family: Arial, Helvetica, sans-serif'><br/>" + edContent.Text.Replace(ControlChars.Lf, "<br/>") + "<br/><br/>" + edSig.Text.Replace(ControlChars.Lf, "<br/>") + "</td></tr></table>" + _
        '                    "</td><td width='217'><img src='http://my.advantech.com/images/down_right.jpg' width='217' height='223'/></td></tr></table></body></html>"
        
        'Dim body As String = "<html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml'><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><style type='text/css'>v\:* { behavior: url(#default#VML); display:inline-block}</style></head>" + _
        '                    "<body><div style='background-image: url(http://my.advantech.com/images/Christmas_bg1.jpg);background-repeat: no-repeat;height: 600px;width: 800px;margin-right: auto;margin-left: auto;font-family: Arial, Helvetica, sans-serif;font-size: 14px;color: #000;'>" + _
        '                    "<!--[if gte vml 1]><v:shape stroked='f' style= 'position:absolute;z-index:-1;visibility:visible;width:800px;height:600px;top:0;left:0;border:0;'><v:imagedata src='http://my.advantech.com/images/Christmas_bg1.jpg'/></v:shape><![endif]-->" + _
        '                    "<table width='800' border='0' cellspacing='0' cellpadding='0'><tr><td width='800' height='372'>&nbsp;</td></tr>" + _
        '                    "<tr><td><table border='0' cellspacing='0' cellpadding='0' width='800' height='230'><tr><td width='214' height='230'>&nbsp;</td><td width='397' height='230' valign='top'><table cellpadding='0' cellspacing='0' border='0' width='397' height='230'><tr><td width='30'></td><td style='font-family: Arial, Helvetica, sans-serif;font-size: 14px;color: #000;'>" + edContent.Text.Replace(ControlChars.Lf, "<br/>") + "<br/><br/>" + edSig.Text.Replace(ControlChars.Lf, "<br/>") + "</td><td width='10'></td></tr></table>" + _
        '                    "</td><td width='189' height='230'>&nbsp;</td></tr></table></td></tr></table>" + _
        '                    "</div></body></html>"
        
        Dim body As String = "<html xmlns='http://www.w3.org/1999/xhtml'><body>"
        ''If cbAppendGreeting.Checked Then body += edContent.Text.Replace(ControlChars.Lf, "<br/>") + "<br/>"
        'If hdnWidth.Value = 0 Or hdnHeight.Value = 0 Then
        '    body += GetGreeting(index) + "<br/><br/>"
        '    body += "<table><tr><td><img src='http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + rblTemplate.SelectedValue + "' width='" + hdnImgWidth.Value + "' height='" + hdnImgHeight.Value + "' /></td></tr></table>"
        'Else
        '    body += "<div style='background-image: url(http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + rblTemplate.SelectedValue + ");background-repeat: no-repeat;background-size: " + hdnImgWidth.Value + "px " + hdnImgHeight.Value + "px;margin-right: auto;margin-left: auto;font-family: 標楷體, serif;font-size: 18px;color: #000;'>" + _
        '            "<table border='0' cellspacing='0' cellpadding='0' width='" + hdnImgWidth.Value + "'><tr><td width='" + hdnImgWidth.Value + "' height='" + hdnY.Value + "'>&nbsp;</td></tr>" + _
        '            "<tr><td valign='top'><table border='0' cellspacing='0' cellpadding='0'><tr><td width='" + hdnX.Value + "' height='" + hdnHeight.Value + "'>&nbsp;</td><td width='" + hdnWidth.Value + "' height='" + hdnHeight.Value + "' valign='top' style='font-family: 標楷體, serif;font-size: 18px;color: #000;'>"
        '    body += GetGreeting(index)
        '    body += "</td><td>&nbsp;</td></tr></table></td></tr><tr><td width='" + hdnImgWidth.Value + "' height='" + CInt(CInt(hdnImgHeight.Value) - CInt(hdnHeight.Value) - CInt(hdnY.Value)).ToString + "'></td></tr></table></div>"
        'End If
        'body += "</body></html>"
        
        If hdnWidth.Value = 0 Or hdnHeight.Value = 0 Then
            body += content + "<br/><br/>"
            body += "<table><tr><td><img src='http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + rblTemplate.SelectedValue + "' width='" + hdnImgWidth.Value + "' height='" + hdnImgHeight.Value + "' /></td></tr></table>"
        Else
            Dim sb As New System.Text.StringBuilder
            With sb
                .Append("<html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml'><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8' /><style type='text/css'>v\:* { behavior: url(#default#VML); display:inline-block}</style></head><body>")
                .Append("<div style='background-image: url(http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + rblTemplate.SelectedValue + ");background-repeat: no-repeat;height: " + hdnImgHeight.Value + "px;width: " + hdnImgWidth.Value + "px;margin-right: auto;margin-left: auto;font-family: 標楷體, Helvetica, sans-serif;font-size: 18px;color: #000;'>")
                .Append("<!--[if gte vml 1]><v:shape stroked='f' style= 'position:absolute;z-index:-1;visibility:visible;width:" + hdnImgWidth.Value + "px;height:" + hdnImgHeight.Value + "px;top:0;left:0;border:0;'><v:imagedata src='http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + rblTemplate.SelectedValue + "'/></v:shape><![endif]-->")
                .Append("<table><tr><td background='http://my.advantech.com/EC/ChristmasImg.ashx?RowId=" + rblTemplate.SelectedValue + "' style='background-repeat: no-repeat;height: " + hdnImgHeight.Value + "px;width: " + hdnImgWidth.Value + "px; font-family: 標楷體, serif;font-size: 18px;color: #000;'>")
                .Append("<table border='0' cellspacing='0' cellpadding='0' width='" + hdnImgWidth.Value + "'><tr><td width='" + hdnImgWidth.Value + "' height='" + hdnY.Value + "'>&nbsp;</td></tr>")
                .Append("<tr><td valign='top'><table border='0' cellspacing='0' cellpadding='0'><tr><td width='" + hdnX.Value + "' height='" + hdnHeight.Value + "'>&nbsp;</td><td width='" + hdnWidth.Value + "' height='" + hdnHeight.Value + "' valign='top' style='font-family: 標楷體, serif;font-size: 18px;color: #000;'>")
                '.Append(GetGreeting(index))
                .Append(content.Replace(ControlChars.Lf, "<br/>"))
                .Append("</td><td>&nbsp;</td></tr></table></td></tr><tr><td width='" + hdnImgWidth.Value + "' height='" + CInt(CInt(hdnImgHeight.Value) - CInt(hdnHeight.Value) - CInt(hdnY.Value)).ToString + "'></td></tr></table>")
                .Append("</td></tr></table></div></body></html>")
            End With
            body = sb.ToString
        End If
        
        Return body
    End Function

    Protected Sub btnPreview_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If rblTemplate.SelectedValue = "" Then Util.AjaxJSAlert(up1, "Please select a eCard first. Thank you.") : Exit Sub
        lblBody.Text = edContent.Content
        lblBody.Visible = True
        btnClose.Visible = True
        btnSend1.Visible = True
        ModalPopupExtender1.Show()
    End Sub

    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        lblBody.Visible = False
        btnClose.Visible = False
        btnSend1.Visible = False
        ModalPopupExtender1.Hide()
    End Sub

    Protected Sub rblGreeting_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        'edContent.Text = GetGreeting(rblGreeting.SelectedValue).Replace("<br/>", ControlChars.Lf)
        edContent.Content = GetMailBody(GetGreeting(rblGreeting.SelectedValue))
    End Sub

    Public Function GetGreeting(ByVal index As String) As String
        Select Case index
            Case "2"
                Return "2014馬年到，萬馬奔騰景壯觀。新年迎來新氣象，快馬加鞭都爭先。<br/>馬到功成事業燦，昂首闊步勇向前。願你馬年福祿壽，新年快樂闔家歡！"
            Case "3"
                Return "大紅燈籠掛得高，大紅對聯門上貼。家家戶戶喜洋洋，闔家團聚迎新年。<br/>鞭炮聲聲腳下繞，焰火繽紛躥得高。大街小巷人如潮，問候祝福身邊保。<br/>馬年到了，祝你萬事順利，馬到成功！"
            Case "1"
                Return "策馬揚鞭馬年到，送份祝福表心意；祝你馬年交好運，馬到功成萬事順；<br/>龍馬精神展宏圖，事業精彩頂呱呱；馬年吉祥闔家歡，幸福安康過大年！"
            Case "0"
                Return "策馬揚鞭馬年到，送份祝福表心意；祝你馬年交好運，馬到功成萬事順；<br/>龍馬精神展宏圖，事業精彩頂呱呱；馬年吉祥闔家歡，幸福安康過大年！"
            Case Else
                Return ""
        End Select
    End Function

    Protected Sub btnSend1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        btnSend_Click(sender, e)
        ModalPopupExtender1.Hide()
    End Sub

    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not if1.HasFile Then Util.JSAlert(Me.Page, "Please select an excel file.") : Exit Sub
        If Not if1.FileName.EndsWith(".xls", StringComparison.OrdinalIgnoreCase) AndAlso Not if1.FileName.EndsWith(".xlsx", StringComparison.OrdinalIgnoreCase) Then
            Util.JSAlert(Me.Page, "Please upload excel file (*.xls)") : Exit Sub
        End If
        Dim xlsPath As String = Server.MapPath("~/EC/") + String.Format("CardEmailList_{0}.xls", Session.SessionID + "_" + Now.ToString("yyyyMMddHHmmss"))
        if1.MoveTo(xlsPath, Brettle.Web.NeatUpload.MoveToOptions.Overwrite)
        Dim SendTo As New ArrayList
        Dim arrEmail As String() = txtEmail.Text.Replace(ControlChars.Lf, ";").Split(";")
        For Each email As String In arrEmail
            If email.Trim <> "" Then
                If Util.IsValidEmailFormat(email.Trim) Then
                    SendTo.Add(email.Trim)
                End If
            End If
        Next
        Dim dt As DataTable = Util.ExcelFile2DataTable(xlsPath)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                Dim email As String = dt.Rows(i).Item(0).ToString.Trim
                If Util.IsValidEmailFormat(email) AndAlso Not SendTo.Contains(email) Then SendTo.Add(email)
            Next
            IO.File.Delete(xlsPath)
            txtEmail.Text = String.Join(ControlChars.Lf, SendTo.ToArray())
        End If
    End Sub

    Protected Sub ddlLang_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        FillCardInfo()
    End Sub

    Protected Sub btnSchedule_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") IsNot Nothing And Request.IsAuthenticated Then
            If HasInvalidCardInfo() Then Exit Sub
            Dim SendTo As ArrayList = GetSendList()
            If SendTo IsNot Nothing AndAlso SendTo.Count > 0 Then
                LogSendToInfo(SendTo, True)
            End If
            txtEmail.Text = ""
            Util.AjaxJSAlert(up1, "Your eCard has been scheduled, thank you!")
        Else
            Util.AjaxJSAlertRedirect(up1, "Please sign in MyAdvantech.", "../home.aspx?ReturnUrl=%2fEC%2feCard.aspx")
        End If
    End Sub

    Protected Sub ddlTemplate_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select isnull(XL,'') as XL,isnull(YL,'') as YL,isnull(WIDTH,'') as WIDTH,isnull(HEIGHT,'') as HEIGHT, isnull(IMAGE_WIDTH,'') as IMAGE_WIDTH, isnull(IMAGE_HEIGHT,'') as IMAGE_HEIGHT from christmas_card where row_id='{0}'", ddlTemplate.SelectedValue))
        'If dt.Rows.Count > 0 Then
        '    With dt.Rows(0)
        '        hdnX.Value = .Item("XL").ToString : hdnY.Value = .Item("YL").ToString
        '        hdnWidth.Value = .Item("WIDTH").ToString : hdnHeight.Value = .Item("HEIGHT").ToString
        '        hdnImgWidth.Value = .Item("IMAGE_WIDTH").ToString : hdnImgHeight.Value = .Item("IMAGE_HEIGHT").ToString
        '    End With
        'End If
    End Sub

    Protected Sub rblTemplate_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        GetTemplateImageInfo()
        edContent.Content = GetMailBody(GetGreeting(rblGreeting.SelectedValue))
    End Sub
    
    Public Sub GetTemplateImageInfo()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select isnull(XL,'') as XL,isnull(YL,'') as YL,isnull(WIDTH,'') as WIDTH,isnull(HEIGHT,'') as HEIGHT, isnull(IMAGE_WIDTH,'') as IMAGE_WIDTH, isnull(IMAGE_HEIGHT,'') as IMAGE_HEIGHT from christmas_card where row_id='{0}'", rblTemplate.SelectedValue))
        If dt.Rows.Count > 0 Then
            With dt.Rows(0)
                hdnX.Value = .Item("XL").ToString : hdnY.Value = .Item("YL").ToString
                hdnWidth.Value = .Item("WIDTH").ToString : hdnHeight.Value = .Item("HEIGHT").ToString
                hdnImgWidth.Value = .Item("IMAGE_WIDTH").ToString : hdnImgHeight.Value = .Item("IMAGE_HEIGHT").ToString
            End With
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script src="../Includes/jquery-1.11.1.min.js" type="text/javascript"></script> 
<script src="../Includes/lightbox/lightbox.min.js" type="text/javascript"></script> 
<link rel="stylesheet" type="text/css" href="../Includes/lightbox/lightbox.css" />
<style type="text/css">
    .at-maincontainer {
	    background-color:#FFF;
	    line-height: 1.5em;
	    line-height:normal;
	    margin: 0 auto;
	    height:auto;
	    width:890px;
	    color:#666;
    }
    table.mylist input 
    {
        width: 150px;
        display: block;
        text-align: center;
    }
    table.mylist label 
    {
        display: block;
        text-align: center;
    }
</style>
<script type="text/javascript" charset="utf-8">
    $(document).ready(function () {
//        $("a[rel^='prettyPhoto']").prettyPhoto({
//            social_tools: false,
//            gallery_markup: '',
//            slideshow: 2000
//        });
    });
</script>
    <table class="at-maincontainer">
        <tr>
            <td>
                <table>
                    <tr>
                        <td width="500">
                            <div id="navtext"><a style="color:Black" href="../home.aspx">Home</a> > Send eCard</div><br />
                            <div style="font-size: 22px;color: #000;font-weight: bold;font-family: Arial, Helvetica, sans-serif;">Send Advantech eCard to your Friend</div>
                        </td>
                        <td align="right" width="550" valign="bottom">
                            <table width="100%">
                                <tr>
                                    <td align="left"><asp:HyperLink runat="server" ID="hlSchedule" NavigateUrl="~/EC/eCardSchedule.aspx" Text="My Schedule Log" /></td>
                                    <th align="right" width="200">eCard Language: </th>
                                    <td align="right">
                                        <asp:DropDownList runat="server" ID="ddlLang" AutoPostBack="true" OnSelectedIndexChanged="ddlLang_SelectedIndexChanged">
                                            <asp:ListItem Text="Traditional Chinese" Value="0" />
                                            <asp:ListItem Text="Simplified Chinese" Value="1" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr><td height="10"></td></tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table>
                            <tr>
                                <td align="left" colspan="2">
                                    <table>
                                        <tr>
                                            <th>Select a eCard Template </th>
                                            <td>Or</td>
                                            <th><asp:HyperLink runat="server" ID="hlUploadTemplate" Text="Upload custom eCard template" NavigateUrl="~/EC/UploadeCard.aspx" /></th>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td align="left">
                                    <asp:Panel runat="server" ID="PanelTemplate" ScrollBars="Auto" Width="600px">
                                        <table>
                                            <tr>
                                                <td>
                                                    <asp:RadioButtonList runat="server" ID="rblTemplate" DataSourceID="sqlTemplate" AutoPostBack="true" CellPadding="10" CellSpacing="3" RepeatDirection="Horizontal" 
                                                        DataTextFormatString="<a href='http://my.advantech.com/EC/ChristmasImg.ashx?RowId={0}' data-lightbox='rbtlist'><img src='http://my.advantech.com/EC/ChristmasImg.ashx?RowId={0}' width='150' /></a><br/>" 
                                                        DataTextField="row_id" DataValueField="row_id" TextAlign="Left" RepeatLayout="Table" CssClass="mylist" OnSelectedIndexChanged="rblTemplate_SelectedIndexChanged">
                                                    </asp:RadioButtonList>
                                                    <%--<asp:DropDownList runat="server" ID="ddlTemplate" DataSourceID="sqlTemplate" AutoPostBack="true" DataTextField="image_name" DataValueField="row_id" OnSelectedIndexChanged="ddlTemplate_SelectedIndexChanged">
                                                    </asp:DropDownList>--%>
                                                    <asp:SqlDataSource runat="server" ID="sqlTemplate" ConnectionString="<%$ connectionStrings: MY %>"
                                                        SelectCommand="select row_id, image_name from christmas_card where uploaded_date>='2014-01-01' and width is not null order by uploaded_date desc">
                                                    </asp:SqlDataSource>
                                                </td>
                                            </tr>
                                        </table>
                                    </asp:Panel>
                                    <asp:HiddenField runat="server" ID="hdnX" /><asp:HiddenField runat="server" ID="hdnY" />
                                    <asp:HiddenField runat="server" ID="hdnWidth" /><asp:HiddenField runat="server" ID="hdnHeight" />
                                    <asp:HiddenField runat="server" ID="hdnImgWidth" /><asp:HiddenField runat="server" ID="hdnImgHeight" />
                                </td>
                            </tr>
                            <tr><td colspan="2" height="5"></td></tr>
                            <tr>
                                <th align="right" width="100">Email Subject: </th>
                                <td align="left"><table><tr><td><asp:TextBox runat="server" ID="txtSubject" Width="400px" /></td></tr></table></td>
                            </tr>
                            <tr><td colspan="2" height="5"></td></tr>
                            <tr>
                                <td align="right"><b>Send To: </b><br />(Maximum: 1000)</td>
                                <td align="left">
                                    <table>
                                        <tr>
                                            <td><asp:TextBox runat="server" ID="txtEmail" Width="400px" Height="80" TextMode="MultiLine" /></td>
                                            <td valign="top">
                                                Please enter each email on a separate line or a semicolon.<br />
                                                Or<br />
                                                Upload from excel file: (<a href='http://my.advantech.com/EC/SampleEmailList.xlsx'>Sample</a>)<br />
                                                <Upload:InputFile runat="server" ID="if1" />&nbsp;
                                                <asp:Button runat="server" ID="btnUpload" Text="Upload" OnClick="btnUpload_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:RadioButtonList runat="server" ID="rblSend" RepeatDirection="Vertical">
                                        <asp:ListItem Text="Send to One by One" Value="0" Selected="True" />
                                        <asp:ListItem Text="Send to All in one eCard (receivers will see other people's emails in the Send To list)" Value="1" />
                                    </asp:RadioButtonList>
                                </td>
                            </tr>
                            <tr><td colspan="2" height="10"></td></tr>
                            <tr>
                                <th align="right">Content: </th>
                                <td>
                                    <table>
                                        <tr>
                                            <td>
                                                <%--<asp:TextBox runat="server" ID="edContent" Width="400" Height="200" TextMode="MultiLine" />--%>
                                                <ed:Editor Appearance="custom" id="edContent" runat="server" Width="600" Height="550" FullHTML="false" PreviewMode="false" DefaultFontFamily="Impact"  ShowQuickFormat="false" Submit="false" NoScript="true">
                                                    <%--<AddFontNames>
                                                        <ed:FontNamesItem Name="標楷體" Family="標楷體, serif" />
                                                    </AddFontNames>--%>
                                                    <Buttons>
                                                        <ed:Method Name="Undo" />
                                                        <ed:Method Name="Redo" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Toggle Name="Bold" />
                                                        <ed:Toggle Name="Italic" />
                                                        <ed:Toggle Name="Underline" />
                                                        <ed:Toggle Name="StrikeThrough" />
                                                        <ed:Toggle Name="SubScript" />
                                                        <ed:Toggle Name="SuperScript" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Toggle Name="Ltr" />
                                                        <ed:Toggle Name="Rtl" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Method Name="ForeColor" />
                                                        <ed:Method Name="ForeColorClear" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Method Name="BackColor" />
                                                        <ed:Method Name="BackColorClear" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Method Name="ClearStyles" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Select Name="FontSize" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Method Name="Cut" />
                                                        <ed:Method Name="PasteText" />
                                                        <ed:Method Name="PasteWord" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Method Name="DecreaseIndent" />
                                                        <ed:Method Name="IncreaseIndent" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:VerticalSeparator />
                                                        <ed:Method Name="Paragraph" />
                                                        <ed:Method Name="JustifyLeft" />
                                                        <ed:Method Name="JustifyCenter" />
                                                        <ed:Method Name="JustifyRight" />
                                                        <ed:Method Name="JustifyFull" />
                                                        <ed:Method Name="RemoveAlignment" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Method Name="OrderedList" />
                                                        <ed:Method Name="BulletedList" />
                                                        <ed:HorizontalSeparator />
                                                        <ed:Method Name="InsertHR" />
                                                        <ed:Method Name="CreateLink" />
                                                        <ed:Method Name="InsertReset" />
                                                    </Buttons>
                                                </ed:Editor>
                                                <%--<ed:Editor Appearance="full" id="edSig" runat="server" Width="600" Height="350" FullHTML="false" PreviewMode="false" ShowQuickFormat="false" Submit="false" NoScript="true">
                                                </ed:Editor>--%>
                                                <%--<uc1:NoToolBarEditor runat="server" ID="edSig" Width="420px" Height="150px" ActiveMode="Design" />--%>
                                            </td>
                                            <td valign="top">
                                                <asp:RadioButtonList runat="server" ID="rblGreeting" RepeatDirection="Vertical" AutoPostBack="true" OnSelectedIndexChanged="rblGreeting_SelectedIndexChanged">
                                                    <asp:ListItem Text="Sample Greeting 1" Value="0" />
                                                    <asp:ListItem Text="Sample Greeting 1" Value="1" Selected="True" />
                                                    <asp:ListItem Text="Sample Greeting 2" Value="2" />
                                                    <asp:ListItem Text="Sample Greeting 3" Value="3" />
                                                </asp:RadioButtonList>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <%--<tr>
                                <td></td>
                                <td><asp:CheckBox runat="server" ID="cbAppendGreeting" Text="Append the greeting above the eCard" /></td>
                            </tr>
                            <tr><td colspan="2" height="10"></td></tr>
                            <tr>
                                <th align="right">Signature: </th>
                                <td align="left">
                                    <table>
                                        <tr>
                                            <td valign="top">
                                                <asp:TextBox runat="server" ID="edSig" Width="400" Height="80" TextMode="MultiLine" />
                                                
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>--%>
                            <tr><td colspan="2" height="10"></td></tr>
                            <tr>
                                <td></td>
                                <td>
                                    <table width="600">
                                        <tr><td><asp:Button runat="server" ID="btnPreview" Text="Preview" Width="100px" OnClick="btnPreview_Click" />&nbsp;<asp:Button runat="server" ID="btnSend" Text="Send Immediately" Width="150px" OnClick="btnSend_Click" />&nbsp;<asp:Button runat="server" ID="btnSchedule" Text="Send on Scheduled Date" Width="200px" Visible="false" OnClick="btnSchedule_Click" OnClientClick="return confirm('Your request will be scheduled and delivered on December 20th or 21th, click OK to confirm or CANCEL to go back.')" /></td></tr>
                                        <tr><td><asp:Label runat="server" ID="lblMsg" ForeColor="Red" /></td></tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <asp:LinkButton runat="server" ID="link1" />
                        <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1" PopupControlID="Panel1" 
                            TargetControlID="link1" BackgroundCssClass="modalBackground">
                        </ajaxToolkit:ModalPopupExtender>
                        <asp:Panel runat="server" ID="Panel1" BackColor="White" ScrollBars="Both" Height="600" Width="800">
                            <table width="100%">
                                <tr><td><asp:ImageButton runat="server" ID="btnClose" ImageUrl="~/images/close1.jpg" Width="30" Visible="false" OnClick="btnClose_Click" /></td></tr>
                                <tr><td><asp:Label runat="server" ID="lblBody" Visible="false" /></td></tr>
                                <tr><td align="center"><asp:Button runat="server" ID="btnSend1" Text="Send" Width="100px" Height="30px" Visible="false" OnClick="btnSend1_Click" /></td></tr>
                            </table>
                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnUpload" />
                        <asp:AsyncPostBackTrigger ControlID="ddlLang" EventName="SelectedIndexChanged" />
                        <%--<asp:AsyncPostBackTrigger ControlID="ddlTemplate" EventName="SelectedIndexChanged" />--%>
                        <asp:AsyncPostBackTrigger ControlID="rblTemplate" EventName="SelectedIndexChanged" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr><td height="20"></td></tr>
    </table>
</asp:Content>

