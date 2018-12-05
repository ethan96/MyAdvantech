<%@ Page Title="MyAdvantech Home" Language="VB" MasterPageFile="~/Includes/MyMaster.master" Async="true" EnableEventValidation="false" %>
<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>
<%@ Register TagName="GAFooter" TagPrefix="uc2" Src="~/Includes/GAFooter.ascx" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        btnClick.Attributes("onmouseover") = "this.src='../Images/btn-login2.jpg';"
        btnClick.Attributes("onmouseout") = "this.src='../Images/btn-login1.jpg';"
        If Not Page.IsPostBack Then
            'Me.Master.EnableAsyncPostBackHolder = False
            If Not Request.Cookies("UserID") Is Nothing Then
                Dim uCookie As HttpCookie = Request.Cookies("UserID")
                txtUserId.Text = Server.HtmlEncode(uCookie.Value)
                cbRemember.Checked = True
            End If
        End If
    End Sub

    Protected Sub btnClick_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        AuthUser(txtUserId.Text.Replace("'", "''").Trim, txtUserPwd.Text.Replace("'", "''").Trim)
    End Sub

    Private Sub AuthUser(ByVal UID As String, ByVal PWD As String)

        Dim sso As New SSO.MembershipWebservice, Validated As Boolean = False
        Dim loginTicket As String = ""
        sso.Timeout = -1
        Try
            If Util.IsValidEmailFormat(UID) Then
                If PWD <> "" Then
                    loginTicket = sso.login(UID, PWD, "MY", Util.GetClientIP())
                Else
                    loginTicket = sso.loginForEUMyAdvantech(UID, "MY", Util.GetClientIP())
                End If
            End If
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "SSO Error email:" + UID + "|pwd:" + PWD, ex.ToString(), False, "", "")
        End Try
        'Response.Write(loginTicket)

        Dim failed_reason As String = ""

        If loginTicket <> "" Then
            ' Validated = True
            '/ ming add for sieble validation
            If Util.IsInternalUser(UID) Then 'If UID Like "*@advantech*" Then
                Dim o As Object = dbUtil.dbExecuteScalar("EZ", String.Format("SELECT count(email_addr) FROM [Employee_New].[dbo].[EZ_PROFILE] where email_addr='{0}'", UID))
                If IsNumeric(o) AndAlso CInt(o) > 0 Then
                    Validated = True
                Else
                    If Util.IsFranchiser(UID, "") Then
                        Validated = True
                    Else
                        Validated = CheckValidation(UID, failed_reason)
                    End If
                End If

            Else
                If LCase(UID) = "test.acl@advantech.com" Then
                    Validated = True
                Else
                    Validated = CheckValidation(UID, failed_reason)
                End If
            End If
            '\ ming end
        Else

            Dim dt As DataTable = dbUtil.dbGetDataTable("CP", String.Format("select USER_STATUS from SSO_MEMBER where EMAIL_ADDR='{0}'", UID))
            If dt.Rows.Count > 0 Then
                If CBool(dt.Rows(0).Item("USER_STATUS")) = False Then
                    failed_reason = "SSO Inactive"
                Else
                    lblErrMsg.Text = "Login ID or password is incorrect."
                    failed_reason = "Password error"
                End If
            Else
                lblErrMsg.Text = "Email does not exist."
                failed_reason = "No User"
            End If

        End If

        If Validated Then
            '\ ming add for multiple languages
            'If Dllanguage.SelectedIndex >= 0 Then
            If cbRemember.Checked Then
                Dim uCookie As New HttpCookie("UserID")
                uCookie.Value = txtUserId.Text.Trim
                uCookie.Expires = DateTime.Now.AddDays(7)
                Response.Cookies.Add(uCookie)
            End If

            Session("LanG") = "ENG"
            Dim aCookie As New HttpCookie("lastVisitLanG")
            aCookie.Value = Session("LanG").ToString.Trim.ToUpper
            aCookie.Expires = DateTime.Now.AddDays(5)
            Response.Cookies.Add(aCookie)
            'End If
            '/ ming end
            AuthUtil.SetSessionById(UID, loginTicket)
            'If MailUtil.IstSchwarz() Then Response.Redirect("http://www.advantech.com")
            If HttpContext.Current.Session("user_id") = "test.acl@advantech.com" Then
                Dim au As New AuthUtil
                au.ChangeCompanyId("UHTE00002")
            End If
            AuthUtil.LogUserAccess(HttpContext.Current.Session("CART_ID"), PWD)
            Try
                If Util.IsInternalUser2() Then
                    Dim WS As New quote.quoteExit
                    WS.Timeout = -1
                    WS.LogSSOIdAsync(loginTicket, UID, PWD, Util.GetClientIP())
                End If
            Catch ex As Exception

            End Try
            If Request("ReturnUrl") IsNot Nothing _
               AndAlso Trim(Request("ReturnUrl")) <> "" _
               AndAlso Request("ReturnUrl") <> "/" Then
                Try
                    FormsAuthentication.RedirectFromLoginPage(UID, False)
                Catch ex As Exception
                    FormsAuthentication.SetAuthCookie(UID, False)
                    If Request("ReturnUrl").Contains(":") Then
                        Response.Redirect(HttpUtility.UrlDecode(Request("ReturnUrl")), False)
                    Else
                        Util.SendEmail("tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw,nada.liu@advantech.com.cn,ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu",
                                   "ReturnUrl Error email:" + UID + "", " The return URL: " + Request("ReturnUrl") + "," + ex.ToString(), False, "", "")
                        RedirectLoginUser()
                    End If
                End Try
            Else
                FormsAuthentication.SetAuthCookie(UID, False)
                'If Util.IsPCP_Marcom(Session("user_id").ToString, "") Then Response.Redirect("home_cp.aspx")
                RedirectLoginUser()
            End If
        Else
            'ming add for vendor login 20130516
            Dim loginFlag As Boolean = False
            Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("SELECT TOP 1 userid,userpassword FROM VENDOR_USER where userid ='{0}' AND userpassword='{1}'", UID, PWD))
            If dt.Rows.Count > 0 Then loginFlag = True
            If (Not String.IsNullOrEmpty(UID) AndAlso String.Equals(PWD, "apacl", StringComparison.CurrentCultureIgnoreCase)) Then
                dt = dbUtil.dbGetDataTable("B2B", String.Format("select top 1 xap_vend from B2BSupplier.dbo.[Mis_xapinq] where xap_vend='{0}'", UID))
                If dt.Rows.Count = 1 Then loginFlag = True
            End If
            If loginFlag Then
                Session("USER_ID") = UID : Session("Password") = PWD
                Response.Redirect("~/order/Vendor_AP.aspx")
            End If
            'ming end  
            lblErrMsg.Visible = True
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into LOGIN_FAILED (USERID,PASSWORD,TIMESTAMP,IP,REASON) values " +
                                                            " (N'{0}',N'{1}',GETDATE(),'{2}','{3}')", Replace(UID, "'", "''"), Replace(PWD, "'", "''"), Util.GetClientIP(), failed_reason))
            Catch ex As Exception

            End Try
        End If
    End Sub
    Sub RedirectLoginUser()
        If Session("account_status") Is Nothing Then Session("account_status") = AuthUtil.GetUserType(Session("user_id"))
        If Session("company_id") = "UCAPRO008" Then Response.Redirect(Util.GetRuntimeSiteUrl() + "/My/Premier/PremierCustomerPortal.aspx")
        'If String.Equals(Session("company_id"), "UCAADV001") AndAlso Session("account_status").ToString().ToUpper() = "EZ" Then Response.Redirect("home_cp.aspx")

        'Ryan 20180222 Redirect to Arrow home page for Arrow users
        If Session("company_id") IsNot Nothing AndAlso AuthUtil.IsArrowCompanyUser(Session("company_id")) Then
            Response.Redirect("home_premier.aspx")
        End If

        Select Case Session("account_status").ToString().ToUpper()
            Case "EZ"
                Response.Redirect("home_ez.aspx")
            Case "CP"
                Response.Redirect("home_cp.aspx")
            Case "GA"
                Response.Redirect("home_ga.aspx")
            Case "KA"
                Response.Redirect("home_ka.aspx")
            Case "DMS"
                Response.Redirect("home_dms.aspx")
            Case "FC"
                Response.Redirect("home_fc.aspx")
        End Select
    End Sub

    Function CheckValidation(ByVal UID As String, ByRef ErrMsg As String) As Boolean
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 isnull(erpid,'') as erpid,isnull(ACTIVE_FLAG,'N') as ACTIVE_FLAG from siebel_contact where email_address='{0}'", Replace(UID, "'", "")))
        If dt.Rows.Count > 0 Then
            If dt.Rows(0).Item(0).ToString <> "" AndAlso UCase(dt.Rows(0).Item(1).ToString) = "Y" Then
                Return True
            Else
                If dt.Rows(0).Item(0).ToString = "" Then
                    ErrMsg = "Siebel ERPID is empty"
                    Return True
                End If
                If UCase(dt.Rows(0).Item(1).ToString) = "N" Then
                    ErrMsg = "Siebel is inactive"
                    Return False
                End If
            End If
        Else
            dt = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT A.ROW_ID FROM S_CONTACT A WHERE Lower(A.EMAIL_ADDR)='{0}' and A.ACTIVE_FLG='Y'", Replace(UID.ToLower(), "'", "")))
            If dt.Rows.Count > 0 Then
                Util.SyncContactFromSiebel(dt.Rows(0).Item(0).ToString)
                Return True
            Else
                Return True
                'failed_reason = "No Siebel Contact"
            End If
        End If
    End Function

    Private Function parseQueryString(ByVal qstring As String) As Hashtable
        'simplify our task
        qstring = qstring + "&"
        Dim outc As New Hashtable()
        Dim r As New Regex("(?<name>[^=&]+)=(?<value>[^&]+)&", RegexOptions.IgnoreCase Or RegexOptions.Compiled)
        Dim _enum As IEnumerator = r.Matches(qstring).GetEnumerator()
        While _enum.MoveNext() AndAlso _enum.Current IsNot Nothing
            If Not outc.ContainsKey(DirectCast(_enum.Current, Match).Result("${name}")) Then outc.Add(DirectCast(_enum.Current, Match).Result("${name}"), DirectCast(_enum.Current, Match).Result("${value}"))
        End While
        Return outc
    End Function

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'ICC 2018/3/26 Use SSL in production environment
            If Util.IsTesting = False AndAlso Request.IsSecureConnection = False AndAlso Request.ServerVariables("HTTP_HOST") IsNot Nothing Then
                Response.Redirect("https://" + Request.ServerVariables("HTTP_HOST").ToString + Request.RawUrl)
            End If
            'ming add for multiple languages
            If Session("LanG") Is Nothing OrElse Session("LanG").ToString() = "" Then
                If Not Request.Cookies("lastVisitLanG") Is Nothing Then
                    Dim aCookie As HttpCookie = Request.Cookies("lastVisitLanG")
                    Session("LanG") = Server.HtmlEncode(aCookie.Value)
                Else
                    If Request.ServerVariables("HTTP_ACCEPT_LANGUAGE") IsNot Nothing AndAlso Request.ServerVariables("HTTP_ACCEPT_LANGUAGE").ToString.Trim <> "" Then
                        Dim lan As String = Request.ServerVariables("HTTP_ACCEPT_LANGUAGE").ToString.ToLower
                        Select Case 1
                            Case InStr(lan, "zh-cn")
                                Session("LanG") = "CHS"
                            Case InStr(lan, "zh-tw")
                                Session("LanG") = "CHT"
                            Case InStr(lan, "ja-jp")
                                Session("LanG") = "JAP"
                            Case InStr(lan, "ko-kr")
                                Session("LanG") = "KOR"
                            Case Else
                                Session("LanG") = "ENG"
                        End Select
                    Else
                        Session("LanG") = "ENG"
                    End If
                End If

            End If
            ' ming end
            If Request("ReturnUrl") IsNot Nothing AndAlso Request.IsAuthenticated = False Then
                If Request("ReturnUrl").ToString.ToUpper.Contains("MADAM") Then
                    With Request("ReturnUrl").ToString.ToUpper
                        If .Contains("DOWNLOAD.ASPX") Then Response.Redirect("./MADAM/download.aspx", False)
                        If .Contains("MAIN_1.ASPX") Then Response.Redirect("./MADAM/main_1.aspx", False)
                        If .Contains("MAIN_2.ASPX") Then Response.Redirect("./MADAM/main_2.aspx", False)
                        If .Contains("INDEX.ASPX") Then Response.Redirect("./MADAM/index.aspx", False)
                        If .Contains("HOME.ASPX") Then Response.Redirect("./MADAM/home.aspx", False)
                    End With
                End If
                Dim str As String = HttpUtility.UrlDecode(Request("ReturnUrl"))
                Dim ht As Hashtable = parseQueryString(str)
                If ht.Count > 0 AndAlso ht.Keys(0).ToString().EndsWith("USERID") Then
                    'Response.Write("ht:" + ht.Values(0) + "<br/>")
                    Dim userid As String = ""
                    Try
                        userid = AEUIT_Rijndael.DecryptDefault(Replace(ht.Values(0), " ", "+"))
                    Catch ex As Exception
                        userid = "" 'Response.Write(ex.ToString()) : Response.End()
                        MailUtil.SendDebugMsg("global MA Decrypt failed " + ht.Values(0), ex.ToString(), "tc.chen@advantech.eu")
                    End Try
                    If userid <> "" Then
                        'Response.Write(userid) : Response.End()
                        AuthUser(userid, "")
                    End If
                End If
            End If
            If User.Identity.IsAuthenticated AndAlso Request("ReturnUrl") IsNot Nothing Then
                Response.Redirect(HttpUtility.UrlDecode(Request("ReturnUrl")), True)
            End If
            If Request.IsAuthenticated AndAlso Session IsNot Nothing AndAlso Session("user_id") IsNot Nothing Then
                RedirectLoginUser()
            Else
                If Request("SessionId") <> "" AndAlso Request("Email") <> "" Then
                    If AuthUtil.IsSSO(Request("SessionId"), Request("Email")) Then
                        If Request("ReturnUrl") IsNot Nothing _
                        AndAlso Trim(Request("ReturnUrl")) <> "" _
                        AndAlso Request("ReturnUrl") <> "/" Then
                            Try
                                FormsAuthentication.RedirectFromLoginPage(Request("Email"), False)
                            Catch ex As Exception
                                FormsAuthentication.SetAuthCookie(Request("Email"), False)
                                If Request("ReturnUrl").Contains(":") Then
                                    Response.Redirect(HttpUtility.UrlDecode(Request("ReturnUrl")), False)
                                End If
                            End Try
                        Else
                            FormsAuthentication.SetAuthCookie(Request("Email"), False)
                            Response.Redirect("home.aspx")
                        End If
                    End If
                End If
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link href='./Includes/styles.css' rel="Stylesheet" type="text/css" />
    <link href='./Includes/main.css' rel="Stylesheet" type="text/css" />
    <link href='./Includes/systemselection.css' rel="Stylesheet" type="text/css" />
    <style type="text/css">
        ul.login1
        {
            list-style: none;
            margin: 0;
            padding: 0;
            display: block;
        }
        ul.login1 li
        {
            display: block;
            background: none;
            margin: 0;
            padding: 0;
            line-height: normal;
        }
        ul.login1 li a
        {
            display: block;
            outline: none;
            padding: 4px 12px;
            margin: 0;
            text-decoration: none;
            letter-spacing: -0.3px;
            color: #dddddd;
            background: url(/images/arrow1.gif) no-repeat 2px 8px;
        }
        ul.login1 li a:hover, ul.login1 li a:active, ul.login1 li a:focus
        {
            color: #000000;
            text-decoration: none;
            background: url(/images/arrow1-on.gif) no-repeat 2px 8px;
        }
        ul.login1 li.active a
        {
            font-weight: bold;
            background: url(/images/arrow1-on.gif) no-repeat 2px 8px;
            color: #CC0000;
        }
        ul.sign
        {
            list-style: none;
            margin: 0;
            padding: 0;
            display: block;
        }
        ul.sign li
        {
            display: block;
            background: none;
            margin: 0;
            padding: 0;
            line-height: normal;
        }
        ul.sign li a
        {
            display: block;
            outline: none;
            margin: 0;
            text-decoration: none;
            color: #3399FF;
        }
        ul.sign li a:hover, ul.sign li a:active, ul.sign li a:focus
        {
            color: #CC0000;
            text-decoration: none;
        }
    </style>
    <div class="at-maincontainer wrap column2">
        <div class="at-mainbody">
            <!-- CONTENT -->
            <div>
                MyAdvantech is a personalized web portal for Advantech customers. Sign up today
                to get 24/7 quick access to your account information.
                <h3>
                    Here is what you can do in MyAdvantech:</h3>
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="49%" valign="top" style='border: #CCC solid 1px; background: url(/images/box-btm.gif) repeat-x left bottom;'>
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange">
                                    MY ACCOUNT</h3>
                                <div class="box-ct clearfix">
                                    <p>
                                        Modify your profile and subscription preference.</p>
                                    <ul class="plussign">
                                        <li><asp:HyperLink runat="server" ID="hlMyProfile" NavigateUrl="~/My/MyProfile.aspx" Text="Profile" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlMySubscription" NavigateUrl="~/My/MySubscriptionRSS.aspx" Text="Subscriptions" /></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                        <td>
                            &nbsp;
                        </td>
                        <td width="49%" valign="top" style='border: #CCC solid 1px; background: url(/images/box-btm.gif) repeat-x left bottom;'>
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange">
                                    MY STORE</h3>
                                <div class="box-ct clearfix">
                                    <p>
                                        View and retrieve the shopping information you need.</p>
                                    <ul class="plussign">
                                        <li><a href="http://buy.advantech.com/" target="_blank"><span>Shopping Cart</span></a></li>
                                        <li><a href="http://buy.advantech.com/" target="_blank"><span>Quotes</span></a></li>
                                        <li><a href="http://buy.advantech.com/" target="_blank"><span>Orders & Delivery</span></a></li>
                                        <li><asp:HyperLink runat="server" ID="hlProduct" NavigateUrl="~/Product/Product_Line_New.aspx" Text="Viewed Products" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlWishList" NavigateUrl="~/My/MyWishList.aspx" Text="Wish List" /></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" style="height: 12px">
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" style='border: #CCC solid 1px; background: url(/images/box-btm.gif) repeat-x left bottom;'>
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange">
                                    MY SUPPORT</h3>
                                <div class="box-ct clearfix">
                                    <p>
                                        Check product information and training updates.</p>
                                    <ul class="plussign">
                                        <li><asp:HyperLink runat="server" ID="hlNewProduct" NavigateUrl="~/Product/New_Product.aspx" Text="New Product Highlight" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlPhaseInOut" NavigateUrl="~/Product/Product_PhaseInOut.aspx" Text="Product Phase in/out" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlDownload" NavigateUrl="~/My/MyDownloadList.aspx" Text="My Download Document" /></li>
                                        <li><a href="http://forum.adamcommunity.com/index.php" target="_blank"><span>Technical Forum</span></a></li>
                                        <li><a href="http://erma.advantech.com.tw/" target="_blank"><span>Return & Repair</span></a></li>
                                        <li><asp:HyperLink runat="server" ID="hlWarranty" NavigateUrl="~/Product/WarrantyLookup.aspx" Text="Warranty" /></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                        <td>
                            &nbsp;
                        </td>
                        <td valign="top" style='border: #CCC solid 1px; background: url(/images/box-btm.gif) repeat-x left bottom;'>
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange">
                                    MY VIEWED MATERIALS</h3>
                                <div class="box-ct clearfix">
                                    <p>
                                        Check the online materials you have seen.</p>
                                    <ul class="plussign">
                                        <li><asp:HyperLink runat="server" ID="hlVideo" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=8" Text="Video" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlNews" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=4" Text="News" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlEDM" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=3" Text="eDM" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlCaseStudy" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=0" Text="Case Study" /></li>
                                        <li><asp:HyperLink runat="server" ID="hlWhitePaper" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=9" Text="White Paper" /></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="iplanet_online_systemsection">
            </div>
            <!-- //CONTENT -->
            <uc2:GAFooter runat="server" ID="ucGAFooter" />
        </div>
        <div class="at-sidebar at-sidebar-right">
            <!-- RIGHT COLUMN -->
            <div class="at-box module_gray">
                <div>
                    <h3 class="title-login">
                        <span>log</span> me in</h3>
                </div>
                <div>
                    <asp:Panel runat="server" ID="Panel" DefaultButton="btnClick">
                        <div>
                            <p style="margin-top:0px; margin-bottom:0px; color:White">ID</p>
                            <asp:TextBox ID="txtUserId" runat="server" Width="90%" Height="25"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ID="rfv1" ErrorMessage=" *" ForeColor="Red"
                                Font-Bold="true" ControlToValidate="txtUserId" />
                            <ajaxToolkit:TextBoxWatermarkExtender runat="server" ID="we0" TargetControlID="txtUserId"
                                WatermarkText="User Name" WatermarkCssClass="watermarked" />
                        </div>
                        <div>
                            <p style="margin-top:0px; margin-bottom:0px; color:White">Password</p>
                            <asp:TextBox ID="txtUserPwd" runat="server" TextMode="Password" Width="90%" Height="25"></asp:TextBox>
                            <%--<ajaxToolkit:TextBoxWatermarkExtender runat="server" ID="we1" TargetControlID="txtUserPwd"
                                WatermarkText="Password" WatermarkCssClass="watermarked" />--%>
                            <asp:RequiredFieldValidator runat="server" ID="rfv2" ErrorMessage=" *" ForeColor="Red"
                                Font-Bold="true" ControlToValidate="txtUserPwd" />
                        </div>
                        <div>
                            <asp:CheckBox runat="server" ID="cbRemember" Text="Remember Me" />
                        </div>
                        <div>
                            <asp:ImageButton runat="server" ID="btnClick" ImageUrl="~/Images/btn-login1.jpg"
                                BorderWidth="0" OnClick="btnClick_Click" />
                        </div>
                        <div>
                            <asp:Label runat="server" ID="lblErrMsg" Text="Login Error.<br />Incorrect User ID or Password."
                                ForeColor="Red" Visible="false" /></div>
                        <ul class="login1">
                            <li><a href="https://member.advantech.com/forgetpassword.aspx?Pass=mya&lang=en" target="_blank">
                                Forgot Your Password</a></li>
                            <li><a href="https://member.advantech.com/profile.aspx?Pass=mya&id=&lang=&tempid=&callbackurl=http://my.advantech.com&CallBackURLName=Go To MyAdvantech">
                                Sign Up for MyAdvantech</a></li>
                        </ul>
                        <div class="clear">
                        </div>
                    </asp:Panel>
                </div>
            </div>
            <!-- //RIGHT COLUMN -->
        </div>
    </div>
    <!-- Start of Async HubSpot Analytics Code -->
    <script type="text/javascript">
        (function (d, s, i, r) {
            if (d.getElementById(i)) { return; }
            var n = d.createElement(s), e = d.getElementsByTagName(s)[0];
            n.id = i; n.src = '//js.hs-analytics.net/analytics/' + (Math.ceil(new Date() / r) * r) + '/1925917.js';
            e.parentNode.insertBefore(n, e);
        })(document, "script", "hs-analytics", 300000);
    </script>
    <!-- End of Async HubSpot Analytics Code -->
</asp:Content>

