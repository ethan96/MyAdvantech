Imports Microsoft.VisualBasic
Imports System.Collections.Concurrent

Public Class MailUtil
    Private Shared Function IsCurrentUserInMailGroup(ByVal RoleName As String) As Boolean
        If RoleName.Trim() = "" Then Return False

        If HttpContext.Current.Session IsNot Nothing AndAlso HttpContext.Current.Session("user") IsNot Nothing Then
            Dim dtuserMailGroup As New DataTable
            If HttpContext.Current.Session("userMailGroup") Is Nothing Then

                Dim sb As New System.Text.StringBuilder
                'With sb
                '    .AppendLine(String.Format(" select c.Name "))
                '    .AppendLine(String.Format(" from ADVANTECH_ADDRESSBOOK a left join ADVANTECH_ADDRESSBOOK_ALIAS b on a.ID=b.ID inner join ADVANTECH_ADDRESSBOOK_GROUP c on a.ID=c.ID   "))
                '    .AppendLine(String.Format(" where (a.PrimarySmtpAddress=N'{0}' or b.Email=N'{0}') ", _
                '                              HttpContext.Current.Session("user")))
                'End With
                With sb
                    .AppendLine(String.Format(" select c.GROUP_NAME as Name "))
                    .AppendLine(String.Format(" from AD_MEMBER a left join AD_MEMBER_ALIAS b on a.PrimarySmtpAddress=b.EMAIL inner join AD_MEMBER_GROUP c on a.PrimarySmtpAddress=c.EMAIL "))
                    .AppendLine(String.Format(" where (a.PrimarySmtpAddress=N'{0}' or b.ALIAS_EMAIL=N'{0}') ",
                                              HttpContext.Current.Session("user")))
                End With


                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
                Dim cmd As New SqlClient.SqlCommand(sb.ToString(), conn)
                Dim adapter As New SqlClient.SqlDataAdapter(cmd)
                adapter.Fill(dtuserMailGroup)
                conn.Close()
                HttpContext.Current.Session("userMailGroup") = dtuserMailGroup
            Else
                dtuserMailGroup = CType(HttpContext.Current.Session("userMailGroup"), DataTable)
            End If

            If dtuserMailGroup IsNot Nothing AndAlso dtuserMailGroup.Select(String.Format("Name='{0}'", RoleName)).Count > 0 Then
                Return True
            Else
                If String.Equals(RoleName, "AOnline.USA", StringComparison.CurrentCultureIgnoreCase) Then
                    Return IsCurrentUserInMailGroup("SALES.AISA.USA")
                Else
                    Return False
                End If
            End If
        Else
            Return False
        End If

    End Function
    Public Shared Function IsInMailGroup(ByVal RoleName As String, ByVal user_id As String) As Boolean

        If RoleName.Trim() = "" Then Return False

        If HttpContext.Current.Session IsNot Nothing _
            AndAlso HttpContext.Current.Session("user") IsNot Nothing _
            AndAlso String.Equals(user_id, HttpContext.Current.Session("user"), StringComparison.CurrentCultureIgnoreCase) Then
            Return IsCurrentUserInMailGroup(RoleName)
        End If

        Dim sb As New System.Text.StringBuilder
        'With sb
        '    .AppendLine(String.Format(" select COUNT(a.ID) as c "))
        '    .AppendLine(String.Format(" from ADVANTECH_ADDRESSBOOK a left join ADVANTECH_ADDRESSBOOK_ALIAS b on a.ID=b.ID inner join ADVANTECH_ADDRESSBOOK_GROUP c on a.ID=c.ID   "))
        '    .AppendLine(String.Format(" where c.Name=N'{0}' and (a.PrimarySmtpAddress=N'{1}' or b.Email=N'{1}') ", _
        '                              Replace(RoleName, "'", "''"), user_id))
        'End With

        With sb
            .AppendLine(String.Format(" select COUNT(a.PrimarySmtpAddress) as c "))
            .AppendLine(String.Format(" from AD_MEMBER a left join AD_MEMBER_ALIAS b on a.PrimarySmtpAddress=b.EMAIL inner join AD_MEMBER_GROUP c on a.PrimarySmtpAddress=c.EMAIL "))
            .AppendLine(String.Format(" where c.GROUP_NAME=N'{0}' and (a.PrimarySmtpAddress=N'{1}' or b.ALIAS_EMAIL=N'{1}') ",
                                      Replace(RoleName, "'", "''"), user_id))
        End With

        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
        Dim cmd As New SqlClient.SqlCommand(sb.ToString(), conn)
        conn.Open()
        Dim c As Integer = cmd.ExecuteScalar()
        conn.Close()
        If c > 0 Then
            Return True
        Else
            '20120731 TC: For sales in SALES.AISA.USA such as Tim.Sterling and Rex.Cherng, they should share same permission setting like AOnline.USA
            If String.Equals(RoleName, "AOnline.USA", StringComparison.CurrentCultureIgnoreCase) Then
                Return IsInMailGroup("SALES.AISA.USA", user_id)
            Else
                Return False
            End If

        End If
    End Function

    Public Shared Function IsTWAOnlineGroup(ByVal user_id As String) As Boolean
        If HttpContext.Current.Session IsNot Nothing AndAlso HttpContext.Current.Session("user_id") IsNot Nothing _
            AndAlso String.Equals(user_id, HttpContext.Current.Session("user_id"), StringComparison.CurrentCultureIgnoreCase) Then

            If IsInMailGroup("Sales.ATW.AOL-Neihu(IIoT)", user_id) OrElse IsInMailGroup("Sales.ATW.AOL-EC", user_id) _
                OrElse IsInMailGroup("CallCenter.IA.ACL", user_id) OrElse IsInMailGroup("Sales.ATW.AOL-ATC(IIoT)", user_id) Then
                Return True
            Else
                Return False
            End If
        End If

    End Function


    Public Shared Sub SendEmail(
           ByVal SendTo As String, ByVal From As String,
           ByVal Subject As String, ByVal Body As String,
           ByVal IsBodyHtml As Boolean,
           ByVal cc As String,
           ByVal bcc As String, Optional ByVal NotifyOnFailure As Boolean = False)
        Dim htmlMessage As Net.Mail.MailMessage, mySmtpClient As Net.Mail.SmtpClient
        htmlMessage = New Net.Mail.MailMessage(From, SendTo, Subject, Body)
        htmlMessage.IsBodyHtml = IsBodyHtml
        If cc <> "" Then htmlMessage.CC.Add(cc)
        Try
            If bcc <> "" Then htmlMessage.Bcc.Add(bcc)
        Catch ex As Exception
            Throw New Exception("BCC:" + bcc + " caused error for sending email")
        End Try

        If NotifyOnFailure Then htmlMessage.DeliveryNotificationOptions = Net.Mail.DeliveryNotificationOptions.OnFailure
        'htmlMessage.CC.Add("tc.chen@advantech.com.tw")
        'htmlMessage.CC.Add("jackie.wu@advantech.com.cn")
        mySmtpClient = New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Try
            mySmtpClient.Send(htmlMessage)
        Catch ex As System.Net.Mail.SmtpException
            System.Threading.Thread.Sleep(100)
            Try
                mySmtpClient.Send(htmlMessage)
            Catch ex1 As Exception
                Try
                    mySmtpClient = New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("ACLSMTPServer"))
                    mySmtpClient.Send(htmlMessage)
                    htmlMessage = New Net.Mail.MailMessage("ebusiness.aeu@advantech.eu", "ebusiness.aeu@advantech.eu", "ACL SMTP Server Send Mail Failed", ex1.ToString)
                    mySmtpClient.Send(htmlMessage)
                Catch ex2 As Exception

                End Try
            End Try
        End Try
    End Sub

    Public Shared Sub SendEmailV2(ByVal FROM_Email As String, ByVal TO_Email As String,
                                    ByVal CC_Email As String, ByVal BCC_Email As String,
                                    ByVal Subject_Email As String, ByVal AttachFile As String,
                                    ByVal MailBody As String, ByVal str_type As String, Optional ByVal atts As System.IO.Stream = Nothing, Optional ByVal attsName As String = "")

        Dim m1 As New System.Net.Mail.SmtpClient
        m1.Host = ConfigurationManager.AppSettings("SMTPServer")
        Dim msg As New System.Net.Mail.MailMessage
        If MailUtil.isEmail(FROM_Email) Then
            msg.From = New System.Net.Mail.MailAddress(FROM_Email)
        Else
            msg.From = New System.Net.Mail.MailAddress("eBusiness.AEU@advantech.eu")
        End If
        If TO_Email <> "" Then
            Dim ToArray As String() = Split(TO_Email, ";")
            For i As Integer = 0 To ToArray.Length - 1
                If Not String.IsNullOrEmpty(ToArray(i).Trim) AndAlso Util.IsValidEmailFormat(ToArray(i).Trim) Then
                    msg.To.Add(ToArray(i))
                End If
            Next
        End If
        If CC_Email <> "" Then
            Dim CcArray As String() = Split(CC_Email, ";")
            For i As Integer = 0 To CcArray.Length - 1
                If Not String.IsNullOrEmpty(CcArray(i)) AndAlso Util.IsValidEmailFormat(CcArray(i).Trim) Then
                    msg.CC.Add(CcArray(i))
                End If
            Next
        End If
        If BCC_Email <> "" Then
            Dim BccArray As String() = Split(BCC_Email, ";")
            For i As Integer = 0 To BccArray.Length - 1
                If Not String.IsNullOrEmpty(BccArray(i)) AndAlso Util.IsValidEmailFormat(BccArray(i).Trim) Then
                    msg.Bcc.Add(BccArray(i))
                End If
            Next
        End If

        '20060316 TC: Handle MailBody image resources
        If InStr(MailBody, "<img") > 0 Then
            'Try
            Dim send_mail_body As String = MailBody
            MailBody = "<xml>" & MailBody & "</xml>"
            Dim prefix As String = "<img", postfix As String = ">", imgarr As New ArrayList
            GetImgArr(MailBody, prefix, postfix, imgarr)
            Dim xml_img As String = "<xml>"
            For i As Integer = 0 To imgarr.Count - 1
                If InStr(imgarr(i).ToString(), "/>") <= 0 Then
                    xml_img &= Replace(imgarr(i).ToString(), ">", " />")
                Else
                    xml_img &= imgarr(i).ToString()
                End If
            Next
            xml_img &= "</xml>"

            Dim xmlDoc As New System.Xml.XmlDataDocument
            xmlDoc.LoadXml(xml_img)

            Dim ImgLinkSrcArray(0) As System.Net.Mail.LinkedResource
            Dim ImageCounter As Integer = 0
            Dim n As System.Xml.XmlNode = xmlDoc.DocumentElement

            EmbedChildNodeImageSrc(n, ImageCounter, ImgLinkSrcArray)

            MailBody = send_mail_body

            Dim xn As System.Xml.XmlNode
            Dim count As Integer = 0
            'Try
            For Each xn In n.ChildNodes
                'Response.Write(xn.Attributes("src").Value)
                MailBody = Replace(MailBody, imgarr(count).ToString(), xn.OuterXml)
                count += 1
            Next
            'Catch ex As Exception

            'End Try

            Dim av1 As System.Net.Mail.AlternateView =
            System.Net.Mail.AlternateView.CreateAlternateViewFromString(MailBody, System.Text.Encoding.UTF8, System.Net.Mime.MediaTypeNames.Text.Html)


            For i As Integer = 0 To ImgLinkSrcArray.Length - 1
                Try
                    av1.LinkedResources.Add(ImgLinkSrcArray(i))
                Catch ex As Exception
                End Try
            Next
            msg.AlternateViews.Add(av1)

            'Catch ex As Exception

            'End Try
        End If

        msg.Body = MailBody : msg.IsBodyHtml = True : msg.SubjectEncoding = System.Text.Encoding.GetEncoding("UTF-8") : msg.BodyEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.Subject = Subject_Email
        If Trim(AttachFile) <> "" Then
            Dim attArray As String() = Split(AttachFile, ";")
            For i As Integer = 0 To attArray.Length - 1
                If attArray(i) <> "" Then
                    Dim Att As New System.Net.Mail.Attachment(attArray(i))
                    msg.Attachments.Add(Att)

                End If
            Next
        End If
        If Not IsNothing(atts) Then
            Dim FileName As String = IIf(String.IsNullOrEmpty(attsName.Trim), "EQ_pdf.pdf", attsName.Trim())
            Dim Att As New System.Net.Mail.Attachment(atts, FileName)
            msg.Attachments.Add(Att)
        End If

        m1.Send(msg)

        For i As Integer = 0 To msg.Attachments.Count - 1
            msg.Attachments.Item(i).ContentStream.Close()
        Next
        For i As Integer = 0 To msg.AlternateViews.Count - 1
            For j As Integer = 0 To msg.AlternateViews.Item(i).LinkedResources.Count - 1
                msg.AlternateViews.Item(i).LinkedResources.Item(j).ContentStream.Close()
            Next
        Next

    End Sub

    Shared Function isEmail(ByVal str As String) As Boolean
        Dim regExp As New RegularExpressions.Regex("^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$")
        If regExp.Match(str).Success Then
            Return True
        End If
        Return False
    End Function


    Public Shared Sub Utility_EMailPage(ByVal FROM_Email As String, ByVal TO_Email As String,
                                        ByVal CC_Email As String, ByVal BCC_Email As String,
                                        ByVal Subject_Email As String, ByVal AttachFile As String,
                                        ByVal MailBody As String)

        FROM_Email = FROM_Email.Trim
        TO_Email = TO_Email.Trim
        CC_Email = CC_Email.Trim
        BCC_Email = BCC_Email.Trim
        Dim m1 As New System.Net.Mail.SmtpClient
        m1.Host = ConfigurationManager.AppSettings("SMTPServer")

        'Ryan 20170803 ACN Smtp settings
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing AndAlso HttpContext.Current.Session("ORG_ID").ToString.ToUpper.StartsWith("CN") Then
            m1.Host = ConfigurationManager.AppSettings("SMTPServerACN")
        End If

        Dim msg As New System.Net.Mail.MailMessage
        If Util.IsValidEmailFormat(FROM_Email) Then
            msg.From = New System.Net.Mail.MailAddress(FROM_Email)
        Else
            msg.From = New System.Net.Mail.MailAddress("eBusiness.AEU@advantech.eu")
        End If

        If Not String.IsNullOrEmpty(TO_Email) Then
            Dim ToArray As String() = Split(TO_Email, ";")
            For i As Integer = 0 To ToArray.Length - 1
                If Not String.IsNullOrEmpty(ToArray(i).Trim) Then
                    msg.To.Add(ToArray(i))
                End If
            Next
        End If
        If Not String.IsNullOrEmpty(CC_Email) Then
            Dim CcArray As String() = Split(CC_Email, ";")
            For i As Integer = 0 To CcArray.Length - 1
                If Not String.IsNullOrEmpty(CcArray(i).Trim) Then
                    msg.CC.Add(CcArray(i))
                End If
            Next
        End If
        If Not String.IsNullOrEmpty(BCC_Email) Then
            Dim BccArray As String() = Split(BCC_Email, ";")
            For i As Integer = 0 To BccArray.Length - 1
                If Not String.IsNullOrEmpty(BccArray(i).Trim) Then
                    msg.Bcc.Add(BccArray(i))
                End If
            Next
        End If

        '20060316 TC: Handle MailBody image resources
        If InStr(MailBody, "<img") > 0 Then
            Try
                Dim send_mail_body As String = MailBody
                MailBody = "<xml>" & MailBody & "</xml>"
                Dim prefix As String = "<img", postfix As String = ">", imgarr As New ArrayList
                GetImgArr(MailBody, prefix, postfix, imgarr)
                Dim xml_img As String = "<xml>"
                For i As Integer = 0 To imgarr.Count - 1
                    If InStr(imgarr(i).ToString(), "/>") <= 0 Then
                        xml_img &= Replace(imgarr(i).ToString(), ">", " />")
                    Else
                        xml_img &= imgarr(i).ToString()
                    End If
                Next
                xml_img &= "</xml>"

                Dim xmlDoc As New System.Xml.XmlDataDocument
                xmlDoc.LoadXml(xml_img)

                Dim ImgLinkSrcArray(0) As System.Net.Mail.LinkedResource
                Dim ImageCounter As Integer = 0
                Dim n As System.Xml.XmlNode = xmlDoc.DocumentElement

                EmbedChildNodeImageSrc(n, ImageCounter, ImgLinkSrcArray)

                MailBody = send_mail_body

                Dim xn As System.Xml.XmlNode
                Dim count As Integer = 0
                Try
                    For Each xn In n.ChildNodes
                        'Response.Write(xn.Attributes("src").Value)
                        MailBody = Replace(MailBody, imgarr(count).ToString(), xn.OuterXml)
                        count += 1
                    Next
                Catch ex As Exception

                End Try

                Dim av1 As System.Net.Mail.AlternateView =
                System.Net.Mail.AlternateView.CreateAlternateViewFromString(MailBody, System.Text.Encoding.UTF8, System.Net.Mime.MediaTypeNames.Text.Html)


                For i As Integer = 0 To ImgLinkSrcArray.Length - 1
                    Try
                        av1.LinkedResources.Add(ImgLinkSrcArray(i))
                    Catch ex As Exception
                    End Try
                Next
                msg.AlternateViews.Add(av1)

            Catch ex As Exception

            End Try
        End If

        msg.Body = MailBody : msg.IsBodyHtml = True : msg.SubjectEncoding = System.Text.Encoding.GetEncoding("UTF-8") : msg.BodyEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.Subject = Subject_Email
        If Trim(AttachFile) <> "" Then
            Dim attArray As String() = Split(AttachFile, ";")
            For i As Integer = 0 To attArray.Length - 1
                If attArray(i) <> "" Then
                    Dim Att As New System.Net.Mail.Attachment(attArray(i))
                    msg.Attachments.Add(Att)
                End If
            Next
        End If
        m1.Send(msg)

        For i As Integer = 0 To msg.Attachments.Count - 1
            msg.Attachments.Item(i).ContentStream.Close()
        Next
        For i As Integer = 0 To msg.AlternateViews.Count - 1
            For j As Integer = 0 To msg.AlternateViews.Item(i).LinkedResources.Count - 1
                msg.AlternateViews.Item(i).LinkedResources.Item(j).ContentStream.Close()
            Next
        Next

    End Sub

    Public Shared Function GetImgArr(ByVal str As String, ByVal prefix As String, ByVal postfix As String, ByRef ImgArr As ArrayList) As Integer
        Dim len_prefix = InStr(str, prefix)
        str = Mid(str, InStr(str, prefix))
        Dim len_postfix = InStr(str, postfix)
        '--{2006-06-28}--Daive: Avoid the duplicate image in attachment
        Dim ImgCode As String = Left(str, InStr(str, postfix))
        Dim i As Integer = 0
        Dim ExistFlag As Boolean = False
        For i = 0 To ImgArr.Count - 1
            If ImgArr.Item(i).ToString.Trim.ToUpper = ImgCode.Trim.ToUpper Then
                ExistFlag = True
                Exit For
            End If
        Next
        If ExistFlag = False Then ImgArr.Add(ImgCode)

        'ImgArr.Add(Left(str, InStr(str, postfix)))
        str = Mid(str, len_postfix + 1)
        If InStr(str, prefix) > 0 Then
            GetImgArr(str, prefix, postfix, ImgArr)
        End If
        Return 1
    End Function

    Public Shared Sub EmbedChildNodeImageSrc(ByRef sn As System.Xml.XmlNode, ByRef ImageCounter As Integer, ByRef LinkSrcArray As System.Net.Mail.LinkedResource())

        Dim ssn As System.Xml.XmlNode
        Try
            For Each ssn In sn.ChildNodes

                If LCase(ssn.Name) = "img" Then

                    If IO.File.Exists(HttpContext.Current.Server.MapPath(ssn.Attributes("src").Value)) Then

                        Dim ImgLinkSrc1 As System.Net.Mail.LinkedResource = Nothing

                        Try
                            ImgLinkSrc1 = New System.Net.Mail.LinkedResource(HttpContext.Current.Server.MapPath(ssn.Attributes("src").Value))
                        Catch ex As Exception
                            HttpContext.Current.Response.Write(ex.Message)
                        End Try

                        ImgLinkSrc1.ContentId = "Img" & ImageCounter
                        ImgLinkSrc1.ContentType.Name = "Img" & ImageCounter
                        ssn.Attributes("src").Value = "cid:Img" & ImageCounter
                        ImageCounter += 1
                        ReDim Preserve LinkSrcArray(ImageCounter - 1)
                        LinkSrcArray(ImageCounter - 1) = ImgLinkSrc1

                    End If

                End If

                If ssn.ChildNodes.Count > 0 Then
                    EmbedChildNodeImageSrc(ssn, ImageCounter, LinkSrcArray)
                End If
            Next
        Catch ex As Exception
            Exit Sub
        End Try

    End Sub

    Public Shared Sub SendDebugMsg(ByVal title As String, ByVal body As String, Optional ByVal ToEmail As String = "ebusiness.aeu@advantech.eu")
        SendEmail(ToEmail, "ebusiness.aeu@advantech.eu", title, body, False, "", "")
    End Sub

    Public Shared Function IsInRole2(ByVal RoleName As String, ByVal user_id As String, Optional ByVal Depth As Integer = 0) As Boolean
        If RoleName.Trim() = "" Then Return False
        Dim UserIdRole As String = RoleName + "," + user_id
        Dim dicUserRoles As Dictionary(Of String, Boolean) = HttpContext.Current.Cache("UserRoles")
        If dicUserRoles Is Nothing Then
            dicUserRoles = New Dictionary(Of String, Boolean)
            If HttpContext.Current.Cache("UserRoles") Is Nothing Then
                HttpContext.Current.Cache.Add("UserRoles", dicUserRoles, Nothing, Now.AddHours(1), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
            Else
                HttpContext.Current.Cache.Insert("UserRoles", dicUserRoles, Nothing, Now.AddHours(1), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
            End If
        End If

        If Not dicUserRoles.ContainsKey(UserIdRole) Then
            Dim sb As New System.Text.StringBuilder
            'With sb
            '    .AppendLine(String.Format(" select COUNT(*) as c "))
            '    .AppendLine(String.Format(" from ADVANTECH_ADDRESSBOOK a left join ADVANTECH_ADDRESSBOOK_ALIAS b on a.ID=b.ID inner join ADVANTECH_ADDRESSBOOK_GROUP c on a.ID=c.ID   "))
            '    .AppendLine(String.Format(" where c.Name=N'{0}' and (a.PrimarySmtpAddress=N'{1}' or b.Email=N'{1}') ", _
            '                              Replace(RoleName, "'", "''"), user_id))
            'End With
            With sb
                .AppendLine(String.Format(" select COUNT(*) as c "))
                .AppendLine(String.Format(" from AD_MEMBER a left join AD_MEMBER_ALIAS b on a.PrimarySmtpAddress=b.EMAIL inner join AD_MEMBER_GROUP c on a.PrimarySmtpAddress=c.EMAIL "))
                .AppendLine(String.Format(" where c.GROUP_NAME=N'{0}' and (a.PrimarySmtpAddress=N'{1}' or b.ALIAS_EMAIL=N'{1}') ",
                                          Replace(RoleName, "'", "''"), user_id))
            End With



            Dim c As Integer = dbUtil.dbExecuteScalar("MY", sb.ToString())
            If c > 0 Then
                dicUserRoles.Add(UserIdRole, True)
            Else
                dicUserRoles.Add(UserIdRole, False)
            End If

        End If

        If dicUserRoles.ContainsKey(UserIdRole) Then
            Return dicUserRoles.Item(UserIdRole)
        Else
            Return False
        End If

    End Function

    Public Shared Function IsAACSales(ByVal Userid As String) As Boolean
        If Userid Is Nothing OrElse String.IsNullOrEmpty(Userid) Then Return False
        If IsInMailGroup("SALES.IAG.USA", Userid) Then Return True
        Return False
    End Function
    'ICC 2015/2/10 Add a new check if userid is in PAPS.eStore group
    Public Shared Function IsPAPSeStore(ByVal Userid As String) As Boolean
        If Userid Is Nothing OrElse String.IsNullOrEmpty(Userid) Then Return False
        If IsInMailGroup("PAPS.ESTORE", Userid) Then Return True
        Return False
    End Function

    Public Shared Function IsMexicoAonlineSale(ByVal Userid As String) As Boolean
        'If Userid.ToLower.Contains("nada.liu") Then
        '    Return True
        'End If
        If Userid Is Nothing OrElse String.IsNullOrEmpty(Userid) Then Return False
        If Userid.EndsWith("@advantech.com.mx", StringComparison.InvariantCultureIgnoreCase) Then Return True
        'If IsInMailGroup("AOnline.AMX", Userid) Then Return True
        Return False
    End Function

    Public Shared Function IsAENCSale() As Boolean
        Dim Userid As String = HttpContext.Current.User.Identity.Name
        If HttpContext.Current.Session IsNot Nothing AndAlso HttpContext.Current.Session("org_id") IsNot Nothing Then
            If String.Equals("EU10", HttpContext.Current.Session("org_id").ToString.Trim, StringComparison.CurrentCultureIgnoreCase) AndAlso IsInMailGroup("EMPLOYEES.Irvine", Userid) Then
                Return True
            End If
        End If
        Return False
    End Function
    Public Shared Function IsInRole(ByVal RoleName As String, Optional ByVal Depth As Integer = 0) As Boolean
        If RoleName.Trim() = "" Then Return False
        If HttpContext.Current.Request.IsAuthenticated = False Then Return False
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
            OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False
        Return IsInRole2(RoleName, HttpContext.Current.Session("user_id").ToString())
    End Function

    ''' <summary>
    ''' Rewrite IsInRole for improving performance
    ''' </summary>
    ''' <param name="RoleName"></param>
    ''' <returns></returns>
    ''' <remarks>Frank 2012/05/16</remarks>
    Public Shared Function IsInRole_V2(ByVal RoleName As String()) As Boolean
        If RoleName Is Nothing Then Return False
        If RoleName.Length = 0 Then Return False
        If HttpContext.Current.Request.IsAuthenticated = False Then Return False
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
            OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False

        Dim _Groups As String = String.Empty
        _Groups = "'" & String.Join(",", RoleName).Replace("'", "''").Replace(",", "','") & "'"


        Dim sb As New System.Text.StringBuilder
        'With sb
        '    .AppendLine(String.Format(" select COUNT(*) as c "))
        '    .AppendLine(String.Format(" from ADVANTECH_ADDRESSBOOK a left join ADVANTECH_ADDRESSBOOK_ALIAS b on a.ID=b.ID inner join ADVANTECH_ADDRESSBOOK_GROUP c on a.ID=c.ID   "))
        '    .AppendLine(String.Format(" where c.Name in ({0}) and (a.PrimarySmtpAddress=N'{1}' or b.Email=N'{1}') ", _
        '                              _Groups, HttpContext.Current.Session("user_id").ToString()))

        'End With
        With sb
            .AppendLine(String.Format(" select COUNT(a.PrimarySmtpAddress) as c "))
            .AppendLine(String.Format(" from AD_MEMBER a left join AD_MEMBER_ALIAS b on a.PrimarySmtpAddress=b.EMAIL inner join AD_MEMBER_GROUP c on a.PrimarySmtpAddress=c.EMAIL "))
            .AppendLine(String.Format(" where c.GROUP_NAME in ({0}) and (a.PrimarySmtpAddress=N'{1}' or b.ALIAS_EMAIL=N'{1}') ",
                                      _Groups, HttpContext.Current.Session("user_id").ToString()))
        End With


        Dim c As Integer = dbUtil.dbExecuteScalar("MY", sb.ToString())

        If c > 0 Then
            Return True
        Else
            Return False
        End If

    End Function



#Region "For eCampaign"
    Public Shared Function SendFromAmazon(ByRef htmlMessage As Net.Mail.MailMessage, ByVal source_email As String, ByVal sender_name As String, _
                                       ByRef AmazonClient As Amazon.SimpleEmail.AmazonSimpleEmailServiceClient, ByRef ErrorMsg As String) As Boolean
        If AmazonClient Is Nothing Then
            AmazonClient = New Amazon.SimpleEmail.AmazonSimpleEmailServiceClient("AKIAIKMEOIM7JRSWOFIA", "HjIuHdUQ5GEG7w/volh/mgOvOmmqbRvH2lH9KX6S")
        End If
        Try
            Dim listColl As New System.Collections.Generic.List(Of String)
            listColl.Add(htmlMessage.To.Item(0).Address)
            htmlMessage.From = New Net.Mail.MailAddress("edm.advantech@edm-advantech.com", sender_name, Encoding.UTF8)
            Dim mailObj As New Amazon.SimpleEmail.Model.SendRawEmailRequest
            mailObj.Source = "edm.advantech@edm-advantech.com"
            Dim assembly As System.Reflection.Assembly = GetType(Net.Mail.SmtpClient).Assembly
            Dim _mailWriterType As Type = assembly.[GetType]("System.Net.Mail.MailWriter")
            Dim _fileStream As New IO.MemoryStream()
            Dim _mailWriterContructor As Reflection.ConstructorInfo = _mailWriterType.GetConstructor(Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic, Nothing, New Type() {GetType(IO.Stream)}, Nothing)
            Dim _mailWriter As Object = _mailWriterContructor.Invoke(New Object() {_fileStream})
            Dim _sendMethod As Reflection.MethodInfo = GetType(Net.Mail.MailMessage).GetMethod("Send", Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic)
            _sendMethod.Invoke(htmlMessage, Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic, Nothing, New Object() {_mailWriter, True}, Nothing)
            Dim _closeMethod As Reflection.MethodInfo = _mailWriter.[GetType]().GetMethod("Close", Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic)
            Dim m As New IO.MemoryStream
            _fileStream.WriteTo(m)
            _closeMethod.Invoke(_mailWriter, Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic, Nothing, New Object() {}, Nothing)
            Dim rm As New Amazon.SimpleEmail.Model.RawMessage
            rm.WithData(m)
            mailObj.RawMessage = rm
            AmazonClient.SendRawEmail(mailObj)
            Return True
        Catch ex As Amazon.SimpleEmail.Model.MessageRejectedException
            ErrorMsg = "MessageRejectedException:" + ex.ToString() : Return False
        Catch ex1 As Exception
            ErrorMsg = ex1.ToString() : Return False
        End Try
    End Function

    Public Shared Function SendFromACLSMTP(ByVal htmlMessage As Net.Mail.MailMessage, ByVal source_email As String, ByVal sender_name As String, _
                                    ByRef mySmtpClient As Net.Mail.SmtpClient, ByRef ErrorMsg As String) As Boolean
        If mySmtpClient Is Nothing Then
            'mySmtpClient = New System.Net.Mail.SmtpClient("172.16.9.183")
            mySmtpClient = New System.Net.Mail.SmtpClient("172.17.20.220")
        End If
        'ACLSourceEmail As String = "edm.advantech@edm-advantech.com"
        htmlMessage.From = New Net.Mail.MailAddress(source_email, sender_name, Text.Encoding.UTF8)
        Try
            mySmtpClient.Send(htmlMessage)
        Catch ex1 As Net.Mail.SmtpException
            ErrorMsg = "SmtpException:" + ex1.ToString() : Return False
        Catch ex2 As Exception
            ErrorMsg = ex2.ToString() : Return False
        End Try

        Return True
    End Function

    Public Shared Function SendFromAEUSMTP(ByVal htmlMessage As Net.Mail.MailMessage, ByVal source_email As String, ByVal sender_name As String, _
                                    ByRef mySmtpClient As Net.Mail.SmtpClient, ByRef ErrorMsg As String) As Boolean
        'If mySmtpClient Is Nothing Then
        mySmtpClient = New System.Net.Mail.SmtpClient("172.21.34.21")
        'End If
        htmlMessage.From = New Net.Mail.MailAddress(source_email, sender_name, Text.Encoding.UTF8)
        Try
            mySmtpClient.Send(htmlMessage)
        Catch ex1 As Net.Mail.SmtpException
            ErrorMsg = "SmtpException:" + ex1.ToString() : Return False
        Catch ex2 As Exception
            ErrorMsg = ex2.ToString() : Return False
        End Try

        Return True
    End Function

    Public Shared Function SendFromAEUExchange(ByVal htmlMessage As Net.Mail.MailMessage, ByVal source_email As String, ByVal sender_name As String, _
                                   ByRef mySmtpClient As Net.Mail.SmtpClient, ByRef ErrorMsg As String) As Boolean
        'If mySmtpClient Is Nothing Then
        mySmtpClient = New Net.Mail.SmtpClient("172.21.34.78")
        mySmtpClient.Credentials = New Net.NetworkCredential("EDM_Advantech", "!Advant258")
        'End If
        Dim strSenderEmail As String = htmlMessage.From.Address
        'ACLSourceEmail As String = "edm.advantech@edm-advantech.com"
        htmlMessage.From = New Net.Mail.MailAddress("eDM_Advantech@advantech-ebiz.eu", sender_name, Text.Encoding.UTF8)
        htmlMessage.ReplyToList.Add(New Net.Mail.MailAddress(strSenderEmail, sender_name, Text.Encoding.UTF8))
        Try
            mySmtpClient.Send(htmlMessage)
        Catch ex1 As Net.Mail.SmtpException
            ErrorMsg = "SmtpException:" + ex1.ToString() : Return False
        Catch ex2 As Exception
            ErrorMsg = ex2.ToString() : Return False
        End Try
        Return True
    End Function

#End Region

End Class

Public Class CampaignSendToEmail
    Public SendToEmail As System.Net.Mail.MailAddress, SendStatus As Boolean, SendVia As String, ErrorMsg As String, CampaignContactRowId As String
    Public Sub New(ByRef st As Net.Mail.MailAddress)
        SendToEmail = st
        SendStatus = False : SendVia = "" : ErrorMsg = ""
    End Sub
End Class
