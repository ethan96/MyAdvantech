<%@ Application Language="VB" %>

<script runat="server">

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs on application startup
        Dim myJob As New ScheduledJob()
        Dim mode As String = ConfigurationManager.AppSettings("QuartzJob")
        If Not mode Is Nothing AndAlso mode.ToUpper.Equals("ON") Then
            Try
                'Stop job first, then start job
                myJob.StopPImailJob()
                myJob.StartPImailJob()

            Catch ex As Exception
                Dim smtpClient1 As System.Net.Mail.SmtpClient = New System.Net.Mail.SmtpClient("172.20.0.76")
                smtpClient1.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw,Frank.Chung@advantech.com.tw,IC.Chen@advantech.com.tw,YL.Huang@advantech.com.tw", "MyAdvantech call WebJob Failed:" + Now.ToString(), ex.ToString())
            Finally
                myJob = Nothing
            End Try
        End If

        'Ryan 20160701 Add webjob for b+b cache in Home_CP
        Try
            myJob.StopBBCacheJob()
            myJob.StartBBCacheJob()
        Catch ex As Exception
            Dim smtpClient1 As System.Net.Mail.SmtpClient = New System.Net.Mail.SmtpClient("172.20.0.76")
            smtpClient1.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw,Frank.Chung@advantech.com.tw,IC.Chen@advantech.com.tw,YL.Huang@advantech.com.tw", "MyAdvantech call WebJob(B+B) Failed:" + Now.ToString(), ex.ToString())
        Finally
            myJob = Nothing
        End Try

        mode = Nothing

    End Sub

    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
        ' Code that runs on application shutdown
        'Dim myJob As New ScheduledJob()
        'Try
        '    myJob.StopPImailJob()
        'Catch ex As Exception
        'End Try
    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
        'Dim cip As String = Util.GetClientIP()
        'If cip = "172.16.2.101" OrElse cip = "172.16.6.85" OrElse cip = "172.16.6.89" Then
        '    Response.Redirect("http://www.advantech.com")
        'End If
    End Sub

    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
        Dim exstr As String = "", exdetail As String = "", ex As Exception = Server.GetLastError().GetBaseException()
        exstr = ex.Message.ToString
        If InStr(exstr, vbNewLine) > 0 Then exstr = Left(exstr, InStr(exstr, vbNewLine))
        exstr = exstr.Replace("'", "''")
        If exstr.Length > 2000 Then exstr = Left(exstr, 2000)
        exdetail = ex.ToString

        'Frank 2012/10/15 Excluding this exception
        If ex.ToString.StartsWith("System.Web.HttpException (0x80004005): File does not exist") Then Exit Sub

        Util.InsertMyErrLog(ex.ToString)
        ''Frank 2012/05/15
        ''log user client information
        'Moving below code to InsertMyErrLog
        'Dim _HTTP_USER_AGENT As String = "HTTP_USER_AGENT value is "
        'If Request.ServerVariables("HTTP_USER_AGENT") Is Nothing Then
        '    _HTTP_USER_AGENT &= "nothing"
        'Else
        '    _HTTP_USER_AGENT &= Request.ServerVariables("HTTP_USER_AGENT")
        'End If
        'Util.InsertMyErrLog(exdetail & Environment.NewLine & _HTTP_USER_AGENT)

        Try
            If ex.GetType().ToString() = "System.OutOfMemoryException" Then
                System.GC.Collect()
            ElseIf ex.GetType.ToString() = "System.Web.HttpException" _
                    AndAlso ex.ToString().StartsWith("System.Web.HttpException (0x80004005): Path '/eurl.axd") Then
                Response.Redirect(Util.GetRuntimeSiteUrl())
            ElseIf ex.GetType().ToString Like "*SqlException*" Then
                Dim ea As SqlClient.SqlException = ex
                Dim i As Integer
                exdetail = ""
                For i = 0 To ea.Errors.Count - 1
                    exdetail += "Index #" & i.ToString() & "$$$" _
                                   & "Message: " & ea.Errors(i).Message & "$$$" _
                                   & "LineNumber: " & ea.Errors(i).LineNumber & "$$$" _
                                   & "Source: " & ea.Errors(i).Source & "$$$" _
                                   & "Procedure: " & ea.Errors(i).Procedure & "$$$"
                Next i
                Util.InsertMyErrLog(exdetail)

            Else
                'If Request.ServerVariables("SERVER_PORT") = "80" OrElse Request.ServerVariables("SERVER_PORT") = "4001" Then
                '    Response.Write("<font color=""#ff0000""><b>Sorry, there is an error of the page you are visiting.</b></font><br/>")
                '    'Response.Write("<font color=""#336699"">" & exstr & "</font>")
                '    Response.End()
                'Else
                '    MailUtil.SendEmail(User.Identity.Name, "ebusiness.aeu@advantech.eu", "Local debug GMA Error", ex.ToString, False, "", "")
                '    Response.Write(ex.ToString())
                'End If

                'End If
            End If

        Catch ex2 As Exception
            Util.InsertMyErrLog("Exception in Global.asax:" + ex2.ToString)
        End Try
        'Server.ClearError()
    End Sub

    Protected Sub Application_PreRequestHandlerExecute(ByVal sender As Object, ByVal e As System.EventArgs)
        'Try
        'ICC 2018/3/5 For production site, automatically force URL to SSL.
        'Dim SSL As Boolean = False
        'Boolean.TryParse(If(ConfigurationManager.AppSettings("SSL"), String.Empty), SSL)
        'If SSL = True AndAlso Not Request.IsSecureConnection Then
        '    Dim url As String = "https://my.advantech.com" + HttpContext.Current.Request.RawUrl
        '    HttpContext.Current.Response.Redirect(url)
        'End If

        Dim sUrl As String = Context.Request.ServerVariables("SCRIPT_NAME").ToLower()
        If sUrl.Contains("/ec/") Then
            '20110419 TC: Handle QR Code Tracking
            If sUrl.Contains("/ec/qr_") Then
                If sUrl.EndsWith(".jsp", StringComparison.OrdinalIgnoreCase) Then
                    Dim ws As New QREC, returnUrl As String = ""
                    Dim cp As New QREC.ClientProperties()
                    With cp
                        .Browser = Request.Browser.Browser : .BrowserPlatform = Request.Browser.Platform : .IP = Util.GetClientIP()
                        .IsMobile = Request.Browser.IsMobileDevice : .Languages = Request.UserLanguages : .mDeviceMf = Request.Browser.MobileDeviceManufacturer
                        .mDeviceModel = Request.Browser.MobileDeviceModel
                    End With

                    If ws.HandleQRCampaignURL(sUrl, cp, returnUrl) Then
                        Response.Redirect(returnUrl, True)
                    Else
                        Response.Clear() : Response.Write("Invalid URL request") : HttpContext.Current.ApplicationInstance.CompleteRequest()
                    End If
                    'End of QR Code Tracking  

                End If
            Else
                '20120312 TC: Handle AOnline campaign's open/click
                If sUrl.Contains("/ec/ao_") Then
                    If sUrl.EndsWith(".jsp", StringComparison.OrdinalIgnoreCase) Then
                        Dim LinkType As AOnlineUtil.AOnlineSalesCampaign.AOnlineEDMLinkType = AOnlineUtil.AOnlineSalesCampaign.AOnlineEDMLinkType.URL
                        Dim UserAgent As String = HttpContext.Current.Request.UserAgent
                        Dim strRedirectUrl As String = AOnlineUtil.AOnlineSalesCampaign.GetAndLogAOnlineEDMContactOpenClickLink(sUrl, Util.GetClientIP(), LinkType, UserAgent)
                        If strRedirectUrl.EndsWith("#") Then strRedirectUrl = strRedirectUrl.Substring(0, strRedirectUrl.Length - 1)
                        'Response.Write(strRedirectUrl) : Response.End()
                        If LinkType = AOnlineUtil.AOnlineSalesCampaign.AOnlineEDMLinkType.IMG Then
                            Dim ws As New Net.WebClient(), bs() As Byte = Nothing
                            Try
                                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                                conn.Open()
                                Dim cmd As New SqlClient.SqlCommand("delete from AONLINE_CAMPAIGN_IMG_CACHE where CACHED_DATE<getdate()-7;", conn)
                                cmd.ExecuteNonQuery()
                                cmd.CommandText =
                                    " select top 1 CONTENT_BYTES from AONLINE_CAMPAIGN_IMG_CACHE where URL=@URL and CACHED_DATE>=GETDATE()-7 and CONTENT_BYTES is not null"
                                cmd.Parameters.AddWithValue("URL", strRedirectUrl)
                                bs = cmd.ExecuteScalar()
                                If bs IsNot Nothing AndAlso bs.Length > 0 Then

                                Else
                                    bs = ws.DownloadData(strRedirectUrl)
                                    If bs IsNot Nothing AndAlso bs.Length > 0 Then
                                        cmd.Parameters.Clear()
                                        cmd.CommandText = "insert into AONLINE_CAMPAIGN_IMG_CACHE (URL, CONTENT_BYTES, CACHED_DATE) values(@URL,@CB,GETDATE())"
                                        cmd.Parameters.AddWithValue("URL", strRedirectUrl) : cmd.Parameters.AddWithValue("CB", bs)
                                        cmd.ExecuteNonQuery()
                                    End If
                                End If
                                conn.Close()
                                If bs IsNot Nothing AndAlso bs.Length > 0 Then
                                    Response.Clear()
                                    Response.ContentType = "image/gif" : Response.BinaryWrite(bs)
                                    HttpContext.Current.ApplicationInstance.CompleteRequest()
                                End If
                            Catch ex As Exception
                                Util.InsertMyErrLog(ex.ToString())
                            End Try
                        Else
                            Response.Redirect(strRedirectUrl, True)
                        End If
                    End If
                    HttpContext.Current.ApplicationInstance.CompleteRequest()
                End If
            End If
        End If

        If HttpContext.Current.Session Is Nothing Then Exit Sub

        'TC 20120221 Check if User is still logged in but session is null, then reset all session value
        'If User.Identity.IsAuthenticated AndAlso Request.IsAuthenticated AndAlso Not String.IsNullOrEmpty(User.Identity.Name) Then
        If Request.IsAuthenticated Then

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("org_id") Is Nothing OrElse Session("org") Is Nothing OrElse Session("user_id") Is Nothing _
            If Session("org_id") Is Nothing OrElse Session("user_id") Is Nothing _
                OrElse Session("company_id") Is Nothing OrElse Session("account_status") Is Nothing OrElse Session("RBU") Is Nothing Then
                AuthUtil.SetSessionById(User.Identity.Name, Session("TempId"))
            End If

            If Session("user_permission") Is Nothing Then
                AuthUtil.GetPermissionByUser()
            End If

        End If
        'End

        Dim sServerName As String = Request.ServerVariables("SERVER_NAME"), sClientName As String = Util.GetClientIP(), sServerPort As String = Request.ServerVariables("SERVER_PORT")

        Dim sMethod As String = Request.ServerVariables("REQUEST_METHOD")
        Dim sUserId As String = HttpContext.Current.User.Identity.Name, sSessionID As String = HttpContext.Current.Session.SessionID
        Dim sLogoutPath As String = "", sQuery As String = "", sTransId As String = "", dTimeStamp As DateTime = Now()
        Dim sAppId As String = "MY", sSQL As String = "", sNotes As String = "", sReferrer As String = ""
        If Request.ServerVariables("HTTP_REFERER") IsNot Nothing Then sReferrer = Request.ServerVariables("HTTP_REFERER")

        If HttpContext.Current.Session("user_id") Is Nothing OrElse (Not AuthUtil.IsCanSeeOrder(HttpContext.Current.Session("user_id"))) Or Request.IsAuthenticated = False Then
            Dim url As String = LCase(Request.ServerVariables("URL"))
            If url = "/my/myinterest.aspx" Or url = "/order/bo_ordertracking.aspx" Or url = "/my/mydashboard.aspx" Or
            url = "/order/cart_list.aspx" Or url = "/quote/quotehistory_list.aspx" Or url = "/order/uploadorder2cart.aspx" Or
            url = "/order/carthistory_list.aspx" Or url = "/bo/myblanketorder.aspx" Or url = "/order/price_list.aspx" Or
            url = "/order/btos_portal_disablebyTC.aspx" Or url = "/order/btoshistory_list.aspx" Or url = "/order/bo_b2borderinquiry.aspx" Or
            url = "/order/shippingcalendar.aspx" Or url = "/order/myrma.aspx" Or url = "/order/bo_backorderinquiry.aspx" Or
            url = "/order/bo_invoiceinquiry.aspx" Or url = "/order/arinquiry_ws.aspx" Or url = "/order/bo_serialinquiry.aspx" Or
            url = "/order/bo_forwardertracking.aspx" Or url = "/order/configurator_new.aspx" Then
                HttpContext.Current.Response.Redirect(ConfigurationManager.AppSettings("SysURL") & "/home.aspx")
            End If
            If url.StartsWith("/DM/") AndAlso Util.IsInternalUser(HttpContext.Current.Session("user_id")) = False Then
                HttpContext.Current.Response.Redirect(ConfigurationManager.AppSettings("SysURL") & "/home.aspx")
            End If
        End If
        If (sUrl.IndexOf("Login.aspx") = -1 And sUrl.IndexOf(".axd") = -1) Then

            If Request.QueryString.HasKeys Then
                For i As Integer = 0 To Request.QueryString.Count - 1
                    sQuery &= Request.QueryString.Keys(i) & "=" &
                              Request.QueryString.Item(i) & "&"
                Next
                sQuery.Replace("'", "&aps")
            End If

            'If sQuery.IndexOf("ChartDirectorChartImage") = -1 Then
            Dim pSessionID As New SqlClient.SqlParameter("SESSION", SqlDbType.VarChar) : pSessionID.Value = sSessionID
            Dim pTransID As New SqlClient.SqlParameter("TRANS", SqlDbType.VarChar) : pTransID.Value = sTransId
            Dim pUserID As New SqlClient.SqlParameter("USERID", SqlDbType.VarChar) : pUserID.Value = sUserId
            Dim pUrl As New SqlClient.SqlParameter("URL", SqlDbType.VarChar) : pUrl.Value = sUrl
            Dim pQuery As New SqlClient.SqlParameter("QUERY", SqlDbType.VarChar) : pQuery.Value = sQuery
            Dim pNote As New SqlClient.SqlParameter("NOTE", SqlDbType.VarChar) : pNote.Value = sNotes
            Dim pMethod As New SqlClient.SqlParameter("METHOD", SqlDbType.VarChar) : pMethod.Value = sMethod
            Dim pServerPort As New SqlClient.SqlParameter("SERVERPORT", SqlDbType.VarChar) : pServerPort.Value = sServerName + ":" + sServerPort
            Dim pClientName As New SqlClient.SqlParameter("CLIENT", SqlDbType.VarChar) : pClientName.Value = sClientName
            Dim pAppID As New SqlClient.SqlParameter("APPID", SqlDbType.VarChar) : pAppID.Value = sAppId
            Dim pReferrer As New SqlClient.SqlParameter("REFERRER", SqlDbType.VarChar) : pReferrer.Value = sReferrer
            sSQL = "insert into USER_LOG values(@SESSION,@TRANS,@USERID,GetDate(),@URL,@QUERY,@NOTE,@METHOD,@SERVERPORT,@CLIENT,@APPID,'N',@REFERRER)"
            Dim para() As SqlClient.SqlParameter = {pSessionID, pTransID, pUserID, pUrl, pQuery, pNote, pMethod, pServerPort, pClientName, pAppID, pReferrer}
            Try
                dbUtil.dbExecuteNoQuery2("MY", sSQL, para)
            Catch ex As Exception
                Util.SendEmail("tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw", "myadvantech@advantech.com", "Insert User Log Failed", ex.ToString, True, "", "")
            End Try

            'End If
        End If
        'Catch ex As Exception

        'End Try
    End Sub

    Protected Sub Application_PostRequestHandlerExecute(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub Application_AuthenticateRequest(ByVal sender As Object, ByVal e As System.EventArgs)
        'If Request.IsAuthenticated Then
        '    AuthUtil.SetSessionById(HttpContext.Current.User.Identity.Name)
        '    Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Application_AuthenticateRequest for " + HttpContext.Current.User.Identity.Name, "", False, "", "")
        'End If
    End Sub

</script>
