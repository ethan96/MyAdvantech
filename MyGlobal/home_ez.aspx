<%@ Page Title="MyAdvantech - Employee Home" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    EnableEventValidation="false" %>

<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>
<%@ Register Src="~/Includes/CustomContent.ascx" TagName="WCustContent" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/ChangeCompany.ascx" TagName="ChgComp" TagPrefix="uc8" %>
<%@ Register Src="~/Includes/SupportBlock.ascx" TagName="SupportBlock" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/Banner.ascx" TagName="Banner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/AMDbanner.ascx" TagName="AMDBanner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/eLearningBanner.ascx" TagName="eLearningBanner" TagPrefix="uc10" %>
<%@ Register Src="My/Intel/IntelPortalBanner.ascx" TagName="IntelPortalBanner" TagPrefix="uc1" %>
<%@ Register Src="~/Includes/AENC_HomePage.ascx" TagPrefix="uc11" TagName="AENC_HomePage" %>

<script runat="server">

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim username As String = ""
        If Session("user_id") IsNot Nothing AndAlso Session("TempId") IsNot Nothing Then
            username = Session("user_id").split("@")(0).ToString.Split(".")(0)
            username = username.Substring(0, 1).ToUpper() + username.Substring(1)
            hyElearn.NavigateUrl = Util.ELearingUrl 'Andrew 2015/9/17 modify Learning Passport url
        End If
        'TC avoid Hi False
        If username.Equals("False") Then username = "customer"
        If Session("user_id") IsNot Nothing And Session("TempId") IsNot Nothing Then
            hlPL.NavigateUrl = "http://www.advantech.com.tw/partner/partner_admin/login.aspx?tempid=" + Session("TempId") + "&pass=my&id=" + Session("user_id")
            lblUserName.Text = "<a href='https://member.advantech.com/profile.aspx?pass=my&id=" + Session("user_id").ToString + "&lang=en&tempid=" + Session("TempId").ToString + "'>" + username + "</a>"
        End If

        If Not Page.IsPostBack Then
            'Alex 2016 / 5 / 24取消以下判斷  只要能進來home_ez的帳號都可以看到td_PR連結
            'JJ 2014/4/3 如果是InterCon.ALL這個Group的人員就隱藏掉
            'If Session("user_id") IsNot Nothing Then
            '    If MailUtil.IsInMailGroup("InterCon.ALL", Session("user_id")) Then
            '        td_PR.Visible = False
            '    Else
            '        td_PR.Visible = True
            '    End If
            'Else
            '    td_PR.Visible = False
            'End If

            If Session("account_status") Is Nothing OrElse Session("account_status").ToString() <> "EZ" Then Response.Redirect("home.aspx")
            Me.Master.EnableAsyncPostBackHolder = False
            If Session("TempId") Is Nothing OrElse Session("TempId").ToString() = "" Then
                Dim ws As New SSO.MembershipWebservice
                ws.Timeout = -1
                Try
                    Session("TempId") = ws.loginForEUMyAdvantech(Session("user_id"), "MyEU", Request.ServerVariables("REMOTE_ADDR"))
                Catch ex As Exception
                End Try
            End If
            'Response.Write(Session("account_status").ToString()+Session("user_role")+Session("user_id"))           
            If Session("user_id") IsNot Nothing AndAlso Util.IsInternalUser(Session("user_id")) Then
            Else
                'LiT20_br.Visible = False
                LiT20.Visible = False
            End If

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.ToUpper = "US" Then
            If Session("ORG_ID") IsNot Nothing AndAlso Left(Session("ORG_ID").ToString.ToUpper, 2) = "US" Then
                LiT29_br.Visible = False : LiT29.Visible = False : Ecard_A.Visible = False : Ecard_Lit.Visible = False : Wiki_Lit.Visible = False : btnWiki.Visible = False

                'Frank 2012/06/15: 
                'After logged in, AENC employees still be sent to employee’s homepage, 
                'but right side view will be AENC product/news/event view which was arranged by Brian
                Select Case Session("RBU")

                    Case "AENC"
                        Me.MultiView1.ActiveViewIndex = 1
                        Dim _aenc As New AENC_HomePage
                        Me.MultiView1.Views(1).Controls.Add(_aenc)

                End Select


            End If
            'If MailUtil.IsInRole("Sales.AEU") = False AndAlso MailUtil.IsInRole("ITD.ACL") = False AndAlso MailUtil.IsInRole("OP.AEU") = False Then
            Me.trQuoteTitle.Visible = True : Me.trQuoteContent.Visible = True
            'End If

            'Alex 2016/05/24取消以下判斷  只要能進來home_ez的帳號都可以看到hyPrjReg/HyperLink1等連結
            'JJ 2014/3/10 home頁只要是下列company ID："EURA004", "EGBR001", "ELVE001", "ELTG002", "EKZI003", "AHKP006", "ERUP002", "EURP001", "EURP011", "EUAJ001", "EURS006"的就隱藏
            'If Session("company_id") IsNot Nothing AndAlso Util.NoShowProjectRegistrationUser(Session("company_id")) Then
            '    hyPrjReg.Visible = False : HyperLink1.Visible = False
            'End If

            'Ryan 20160823 Set visibility to open for all orgs
            tr_EUGATP.Visible = True

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
            'ICC 2015/8/6 US employee can see [Check ACL availability] function
            If Session("ORG_ID") IsNot Nothing AndAlso (Session("ORG_ID").ToString.ToUpper.StartsWith("EU", StringComparison.OrdinalIgnoreCase) OrElse
                                                    Session("ORG_ID").ToString.ToUpper.StartsWith("CN", StringComparison.OrdinalIgnoreCase)) Then

                hleMarketing.Visible = True : hleMarketing.NavigateUrl = "~/EC/eMarketingEDMEU.aspx"
                hyEUEstock.Visible = True : brEUEstock.Visible = True : trAdvProdSearch.Visible = True
                hlCreateSAPAccount.Visible = True : hlSAPAccountList.Visible = True
                '20121217 TC: Per AEU Emil's request add a new block for AEU sales -- Project A3 Management
                trEUPrjFunctions.Visible = True : trEUPrjHeader.Visible = True

            End If
            'If Session("ORG_ID") IsNot Nothing AndAlso Session("ORG_ID").ToString.ToUpper.StartsWith("CN", StringComparison.OrdinalIgnoreCase) Then
            '    trCNAss.Visible = True
            'End If
            'hyAOnlineSalesPortal.NavigateUrl = "http://unica.advantech.com.tw/AOnline/TopContents.aspx?SessionId=" + HttpContext.Current.Session.SessionID + "&Email=" + HttpContext.Current.User.Identity.Name
            hyAOnlineSalesPortal.NavigateUrl = "http://unica.advantech.com.tw/SSO.aspx?ReturnUrl=http://unica.advantech.com.tw/AOnline/TopContents.aspx&tempid=" + Session("TempId") + "&id=" + HttpContext.Current.User.Identity.Name
            '20130729 Nada added for employee AID not allowed to change company id
            If MailUtil.IsInMailGroup("Employee.AID", Session("user_id")) Then
                Me.trCCID.Visible = False
            End If

            '20150724 TC: Release home_premier to Marady/Jay/MyIT for testing Premier portal for Arrow
            '20151102 ICC: Add permission for Andy.Chiu to use premier page. 
            '20151111 ICC: Add permission for Arrow's company ID users.
            If MailUtil.IsInRole("MyAdvantech") OrElse MailUtil.IsInRole("eStore.IT") OrElse MailUtil.IsInRole("EMPLOYEES.Irvine") OrElse User.Identity.Name.ToLower() = "andy.chiu@advantech.com.tw" _
                OrElse (Session("COMPANY_ID") IsNot Nothing AndAlso AuthUtil.IsArrowCompanyUser(Session("COMPANY_ID").ToString().Trim())) Then
                trHomePremier.Visible = True
            End If

            'Alex 2016 / 5 / 24取消以下判斷  只要能進來home_ez的帳號都可以看到td_PR/hyPrjReg/HyperLink1等連結
            'ICC 2016/3/4 Add MyAdvantech and ChannelManagement.ACL can see project registration link
            'If MailUtil.IsInRole("MyAdvantech") OrElse MailUtil.IsInRole("ChannelManagement.ACL") Then
            '    Panel1.Visible = True
            '    td_PR.Visible = True
            '    hyPrjReg.Visible = True
            '    HyperLink1.Visible = True
            'End If

            'Frank 20171227 Visibility control for BBUS block
            If Util.IsBBCustomerCare() Then
                Me.tr_BBeStoreTool_Title.Visible = True : Me.tr_BBeStoreTool.Visible = True
            End If

        End If

    End Sub

    Protected Sub LoginStatus1_LoggingOut(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.LoginCancelEventArgs)
        Dim httpWebcookie As HttpCookie
        httpWebcookie = Request.Cookies(".AEULogin")
        If httpWebcookie IsNot Nothing Then
            Try
                httpWebcookie.Domain = Request.Url.Host
                httpWebcookie.Expires = DateTime.Now.AddYears(-3)
                Response.Cookies.Add(httpWebcookie)
            Catch ex As Exception
            End Try
        End If
        Session("user_id") = "" : Session.Abandon() : FormsAuthentication.SignOut()
        Server.Transfer("~/Logout.aspx")
    End Sub
    Protected Sub tree_ByOnLine_SelectedNodeChanged(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub btnSolutionDay_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/Includes/SolutionDayLogin.htm")
    End Sub

    Protected Sub LiTs_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Lit As Literal = CType(sender, Literal)
        Dim LiTstr As String = Util.GetLANGLiT_text(Lit.ID.ToString.Trim)
        If LiTstr.ToString.Trim <> "" Then
            Lit.Text = LiTstr
        End If
    End Sub


    Protected Sub btnWiki_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "MY")
        If p IsNot Nothing Then
            Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}", Session("user_id"), p.login_password))
        End If
    End Sub

    Protected Sub lbtnNewQuote_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Frank 2013/10/21:ABR sales uses ABR quotation function.
        'Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/quote/quotationMaster.aspx"))
        'Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
        Dim internalws As New InternalWebService
        If internalws.CanAccessABRQuotation(User.Identity.Name, Session("RBU"), Session("Account_Status")) Then
            Response.Redirect("~/Order/ABRQuote/B2B_Quotation_List.aspx")
        Else
            Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/quote/quotationMaster.aspx"))
            Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
        End If
    End Sub


    Protected Sub lbtnQuoteByCompany_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/order/quoteByCompany.aspx")
    End Sub

    Protected Sub lbtnQuoteRecd_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/quote/quoteByAccountOwner.aspx"))
        Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
    End Sub
    Protected Sub hyMyDB_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hyMyDB.Visible = True : MyDBbr.Text = "<br/>"
    End Sub

    Public Class eTalks
        Public Subject As String
        Public URL As String
    End Class

    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function getETalks() As String
        Dim reList As New List(Of Object)()
        Try
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "SELECT TOP 3 [Subject],[WistaPath] FROM [MyAdvantechGlobal].[dbo].[ELEARNING_ETALKS] order by CreateCourseTime desc")
            Dim list_ListName As New List(Of eTalks)
            For Each drow As DataRow In dt.Rows
                Dim etalk As New eTalks()
                etalk.Subject = DirectCast(drow("Subject"), String)
                etalk.URL = DirectCast(drow("WistaPath"), String).Replace("http://", "https://")
                list_ListName.Add(etalk)
            Next
            reList.Add(list_ListName)
        Catch ex As Exception
        End Try

        Dim jsr As New System.Web.Script.Serialization.JavaScriptSerializer()
        Return jsr.Serialize(reList)
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        .slide {
            padding-left: 5px;
            padding-bottom: 10px;
            font-size: 14px;
            font-weight: bold;
            color: #004181
        }
        #nav {
            z-index: 50;
            position: absolute;
            vertical-align: bottom;
            text-align: right;
            top: 392px;
        }

            #nav a {
                margin: 0 5px;
                padding: 3px 5px;
                border: 1px solid #ccc;
                background: gray;
                text-decoration: none;
                color: White;
                font-weight: bold;
            }

                #nav a.activeSlide {
                    background: #aaf;
                }

                #nav a:focus {
                    outline: none;
                }
    </style>
    <script type="text/javascript" src='./EC/Includes/jquery-latest.min.js'></script>
    <script type="text/javascript" src='./EC/Includes/jquery.cycle.all.latest.js'></script>
    <script type="text/javascript" src='EC/Includes/json2.js'></script>
    <script src="Includes/js/E-v1.js" async></script>
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_beginRequest(beginRequest);
        function beginRequest() {
            prm._scrollPosition = null;
        }

        $(document).ready(function () {
            canAccessABRQuotation();
        }
        );

        var getUrlParameter = function getUrlParameter(sParam) {
            var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                sURLVariables = sPageURL.split('&'),
                sParameterName,
                i;

            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('=');

                if (sParameterName[0] === sParam) {
                    return sParameterName[1] === undefined ? true : sParameterName[1];
                }
            }
        };


        function canAccessABRQuotation() {
            $("body").css("cursor", "progress");
            var user_id = '<%=User.Identity.Name %>';
            $.ajax({
                type: "POST",
                url: "./Services/InternalWebService.asmx/CanAccessABRQuotation",
                data: JSON.stringify({
                    UserID: user_id,
                    RBU: '<%=Session("RBU") %>',
                    AccountStatus: '<%=Session("Account_Status") %>'
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var ATPTotalInfo = $.parseJSON(msg.d);

                    if (ATPTotalInfo) {
                        $("#<%=me.trMyQuoteHistory.ClientID %>").hide();
                        $("#<%=me.trCompanyQuoteHistory.ClientID %>").hide();
                    }

                    $("body").css("cursor", "auto");
                },
                error: function (msg) {
                }
            }
            );
        }

        $(function () {

            $.ajax({
                type: "POST", url: "<%=System.IO.Path.GetFileName(Request.PhysicalPath) %>/getETalks", contentType: "application/json; charset=utf-8", dataType: "json",
                success: function (retData) {
                    result = $.parseJSON(retData.d); // 取得資料
                    //List
                    Lists = result[0];
                    if (typeof Lists != "undefined") {
                        if (Lists.length != 0) {
                            for (var i = 0; i < Lists.length; i++) {
                                $('#slideshow').append("<table height='410' class='slide'><tr><td height='3px'></td></tr><tr><td height='10'><a href='" + Lists[i].URL + "' target='_blank'><font color='#f29702'>Executive talk</font> - " + Lists[i].Subject + "</a></td></tr><tr><td height='3px'></td></tr><tr><td valign='top'><iframe id='frame1' src='" + Lists[i].URL + "' allowtransparency='true' frameborder='0' scrolling='no' class='wistia_embed' name='wistia_embed' allowfullscreen mozallowfullscreen webkitallowfullscreen oallowfullscreen msallowfullscreen width='620' height='349'></iframe></td></tr></table>");
                            }

                            $('#slideshow').cycle({
                                fx: 'fade',
                                pager: '#nav',
                                slideExpr: 'table',
                                timeout: 30000000
                            });


                        }
                    }
                },
                error: function (msg) {
                    console.log("call getSourceType err:" + msg.d);
                }
            });

        });
    </script>
    <div class="left">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td>
                    <div class="login">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="5%">&nbsp;
                                </td>
                                <td width="92%">&nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td height="30">&nbsp;
                                </td>
                                <td class="h2">
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="12%" class="h2">
                                                <img src="images/login_employee.jpg" width="19" height="23">
                                            </td>
                                            <td class="h2">
                                                <table border="0">
                                                    <tr>
                                                        <td>
                                                            <font color="#104999">Hi,
                                                                <asp:Label runat="server" ID="lblUserName" />!</font>
                                                        </td>
                                                        <td>
                                                            <table>
                                                                <tr>
                                                                    <td>
                                                                        <asp:LoginStatus runat="server" ID="LoginStatus1" LogoutImageUrl="~/Images/logout.jpg"
                                                                            OnLoggingOut="LoginStatus1_LoggingOut" />
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <asp:HyperLink runat="server" ID="hlMyProfile" NavigateUrl="~/My/MyProfile.aspx"
                                                                            ImageUrl="~/Images/Profile.JPG" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td height="10"></td>
                                <td></td>
                            </tr>
                            <tr runat="server" id="trHomePremier" visible="false">
                                <td height="20"></td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="5%" valign="top">
                                                <img src="images/point.gif" width="7" height="14" />
                                            </td>
                                            <td>Homepage for Premier Customer
                                                <asp:HyperLink runat="server" ID="HyperLink3" NavigateUrl="~/home_premier.aspx">Click</asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td height="20"></td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="5%" valign="top">
                                                <img src="images/point.gif" width="7" height="14" />
                                            </td>
                                            <td>Homepage for Channel Partner
                                                <asp:HyperLink runat="server" ID="hyHomeCP" NavigateUrl="~/home_cp.aspx">Click</asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td height="20"></td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="5%" valign="top">
                                                <img src="images/point.gif" alt="" width="7" height="14" />
                                            </td>
                                            <td>Homepage for Key Account
                                                <asp:HyperLink runat="server" ID="hyHomeKA" NavigateUrl="~/home_ka.aspx">Click</asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp;
                                </td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="5%" valign="top">
                                                <img src="images/point.gif" alt="" width="7" height="14" />
                                            </td>
                                            <td>Homepage for General Account
                                                <asp:HyperLink runat="server" ID="hyHomeGA" NavigateUrl="~/home_ga.aspx">Click</asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr runat="server" id="trCCID">
                                <td>&nbsp;
                                </td>
                                <td>
                                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                        <tr>
                                            <td width="5%" valign="top"></td>
                                            <th align="left">Change Company Id
                                            </th>
                                        </tr>
                                        <tr>
                                            <td width="5%" valign="top"></td>
                                            <td align="left">
                                                <uc8:ChgComp runat="server" ID="ChgComp1" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td height="20"></td>
                                <td>&nbsp;
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr runat="server" id="tr_BBeStoreTool_Title" visible="false">
                <td height="24" class="menu_title">
                    <asp:Literal ID="Literal3" runat="server" OnLoad="LiTs_Load">B+B Order Utilities</asp:Literal>
                </td>
            </tr>
            <tr runat="server" id="tr_BBeStoreTool" visible="false">
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink_ProcesseStoreOrders" runat="server" NavigateUrl="/order/bborder/OrderList.aspx">Process eStore Orders</asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="tr2">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink_AuthAmount" runat="server" NavigateUrl="/order/bborder/AuthCreditCard.aspx">Authorize amount of credit card orders</asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="tr3">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink_CaptureAmount" runat="server" NavigateUrl="/order/bborder/CaptureCreditCardOrders.aspx">Capture amount of credit card orders</asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="tr4">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink_CreateNewSAPAccount" runat="server" NavigateUrl="/order/bborder/NewSAPAccount_ABB.aspx">Create New SAP Account</asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="tr1">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink_CancelSO" runat="server" NavigateUrl="/order/bbOrder/CancelSO_ABB.aspx">Cancel SO</asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr runat="server" id="trQuoteTitle">
                <td height="24" class="menu_title">
                    <asp:Literal ID="Literal1" runat="server" OnLoad="LiTs_Load">eQuotation 2.5</asp:Literal>
                </td>
            </tr>
            <tr runat="server" id="trQuoteContent">
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:LinkButton ID="lbtnNewQuote" runat="server" OnClick="lbtnNewQuote_Click">New Quotation</asp:LinkButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trMyQuoteHistory">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:LinkButton ID="lbtnQuoteRecd" runat="server" OnClick="lbtnQuoteRecd_Click">My Quotation History</asp:LinkButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trCompanyQuoteHistory">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:LinkButton ID="lbtnQuoteByCompany" runat="server" OnClick="lbtnQuoteByCompany_Click">Company's quotation history</asp:LinkButton>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT0" runat="server" OnLoad="LiTs_Load">Online Ordering</asp:Literal>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login" style="font-weight: bold;">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyCart" NavigateUrl="~/Order/Cart_List.aspx">
                                                <asp:Literal ID="LiT16" runat="server" OnLoad="LiTs_Load">Place Component Orders</asp:Literal>
                                            </asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyBTOS" NavigateUrl="~/Order/Btos_portal.aspx">
                                                <asp:Literal ID="LiT17" runat="server" OnLoad="LiTs_Load">System Configuration/Orders</asp:Literal>
                                            </asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyUploadOrder" NavigateUrl="~/Order/UploadOrderFromExcel.aspx">
                                                <asp:Literal ID="LiT32" runat="server" Text="Upload Order" OnLoad="LiTs_Load" />
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyPriceATP" NavigateUrl="~/Order/PriceAndATP.aspx">
                                                <asp:Literal ID="LiT15" runat="server" OnLoad="LiTs_Load">Check Price & Availability</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="tr_EUGATP" visible="false">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyEUGATP" NavigateUrl="~/Order/QueryACLATP.aspx"
                                                Text="Check ACL Availability" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <%--    <tr runat="server" id="trCNAss" visible="false" >
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink3" NavigateUrl="~/Order/ACNCTOSStatusInquiry.aspx">
                                                <asp:Literal ID="Literal2" runat="server" OnLoad="LiTs_Load">ACN Assembly Status</asp:Literal>
                                            </asp:HyperLink></td></tr></table></td></tr>--%>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyOrderTracking" NavigateUrl="~/Order/BO_OrderTracking.aspx">
                                                <asp:Literal ID="LiT13" runat="server" OnLoad="LiTs_Load">Order Tracking</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyCartHistory" NavigateUrl="~/Order/CartHistory_List.aspx">
                                                <asp:Literal ID="LiT34" runat="server" OnLoad="LiTs_Load">Cart & Configuration history</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hlForecast" NavigateUrl="~/Admin/Forecast_Catalog.aspx">
                                                <asp:Literal ID="LiT20" runat="server" Text="Catalog Forecast" OnLoad="LiTs_Load" />
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT3" runat="server" OnLoad="LiTs_Load">Product Info.</asp:Literal></td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyProdSearch" NavigateUrl="~/Product/ProductSearch.aspx">
                                                <asp:Literal ID="LiT21" runat="server" OnLoad="LiTs_Load">Search</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trAdvProdSearch" visible="false">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyAdvProdSearch" Text="Advanced Product Search"
                                                NavigateUrl="~/Product/Search.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyPPhaseInOut" NavigateUrl="~/Product/Product_PhaseInOut.aspx"
                                                Text="Phase In/ Out" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyNewProd" NavigateUrl="~/Product/New_Product.aspx">
                                                <asp:Literal ID="LiT23" runat="server" OnLoad="LiTs_Load">New Product Highlight</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="hyWarrantyLookup" runat="server" Text="Warranty Lookup" NavigateUrl="~/Order/RMAWarrantyLookup.aspx" />
                                            <%--<asp:HyperLink runat="server" ID="hyWarrantyLookup" NavigateUrl="~/Order/MyWarrantyExpireItems.aspx">
                                                <asp:Literal ID="LiT24" runat="server" OnLoad="LiTs_Load">Warranty Lookup</asp:Literal></asp:HyperLink>--%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT4" runat="server" OnLoad="LiTs_Load">Support & Download</asp:Literal></td>
            </tr>
            <tr>
                <td>
                    <!--'Frank 2012/03/15
                    'UpdatePanel to make sure url of SupportBlock.HyperLink2 do really changed when change region-->
                    <uc9:SupportBlock runat="server" ID="ucSupportBlock" />
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT10" runat="server" OnLoad="LiTs_Load">Internal Functional Tools</asp:Literal></td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" alt="" />
                                        </td>
                                        <td class="menu_title02">Project Registration </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="20"></td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%"></td>
                                        <td class="menu_list">
                                            <asp:Panel ID="Panel1" runat="server">
                                                <span id="td_PR" runat="server">
                                                    <asp:HyperLink runat="server" ID="hyMyLeads" NavigateUrl="~/My/MyLeads.aspx">
                                                        <asp:Literal ID="LiT29" runat="server" OnLoad="LiTs_Load">Leads Management</asp:Literal>
                                                    </asp:HyperLink><asp:Literal
                                                        ID="LiT29_br" runat="server"><br /></asp:Literal>
                                                    <asp:HyperLink runat="server" ID="hyPrjReg" Text="" NavigateUrl="~/My/InterCon/PrjReg.aspx">
                                                        <asp:Literal ID="LiT30" runat="server" OnLoad="LiTs_Load">Project Registration Request</asp:Literal>
                                                        <asp:Literal ID="LiT31" runat="server" Visible="false">Special Price Request</asp:Literal>
                                                    </asp:HyperLink><br />
                                                    <asp:HyperLink runat="server" ID="hyPrjTmpReg" Text="" NavigateUrl="~/My/InterCon/PrjTmpList.aspx">
                                                        <asp:Literal ID="Literal2" runat="server" OnLoad="LiTs_Load">My Temporary Projects</asp:Literal>
                                                    </asp:HyperLink><br />
                                                    <asp:HyperLink runat="server" ID="HyperLink1" Text="" NavigateUrl="~/My/InterCon/PrjList.aspx">
                                                        <asp:Literal ID="LiT360" runat="server" OnLoad="LiTs_Load">My Registered Projects</asp:Literal>
                                                    </asp:HyperLink><br />
                                                </span>
                                            </asp:Panel>
                                            <asp:HyperLink runat="server" ID="hyEPricer" NavigateUrl="~/Includes/ToEIP.ashx?EIPPID=ePricer_SSO"
                                                Target="_blank">ePricer</asp:HyperLink><br />
                                            <a href="http://employeezone.advantech.com.tw/eManager/" target="_blank">eManager</a><br />
                                            <asp:HyperLink runat="server" ID="hlCreateSAPAccount" NavigateUrl="~/Admin/CreateSAPCustomer.aspx"
                                                Text="Apply New SAP Account" Visible="false" /><br />
                                            <asp:HyperLink runat="server" ID="hlSAPAccountList" NavigateUrl="~/Admin/SAPCustomerList.aspx"
                                                Text="SAP Account Applications" Visible="false" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr runat="server" id="trEUPrjHeader" visible="false">
                            <td width="5%" height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" alt="" />
                                        </td>
                                        <td class="menu_title02">Sales </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trEUPrjFunctions" visible="false">
                            <td height="20"></td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%"></td>
                                        <td class="menu_list">
                                            <asp:HyperLink runat="server" ID="hyEUAccountProfile" NavigateUrl="http://apps.advantech.eu/Advantech.App/Home/Company"
                                                Target="_blank" Text="Account Profile" /><br />
                                            <asp:HyperLink runat="server" ID="hyEUPrjA3Mgt" NavigateUrl="http://apps.advantech.eu/Advantech.App/Home/Project"
                                                Target="_blank" Text="Project A3 Management" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">Marketing </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="20"></td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%"></td>
                                        <td class="menu_list">
                                            <a href="http://digital.advantech.com/" target="_blank">Digital Marketing Portal</a><br />
                                            <%--<a href="http://ec.advantech.eu" target="_blank">eCampaign</a><br />--%>
                                            <asp:HyperLink runat="server" ID="HyperLink4" NavigateUrl="~/Product/CorporateMaterial.aspx"
                                                Text="Company Profile & Corporate Video" /><img src="Images/new2.gif" alt="Company Profile & Corporate Video"
                                                    style="border: 0px" width="28" height="11" /><br />
                                            <asp:HyperLink runat="server" ID="hyAdvGiftShop" NavigateUrl="~/DM/MArketing/GiftList.aspx"
                                                Text="Gift Shop" /><img src="Images/new2.gif" alt="Gift Shop"
                                                    style="border: 0px" width="28" height="11" /><br />
                                            <asp:HyperLink runat="server" ID="hyCatalogPriceATP" NavigateUrl="~/DM/Marketing/Catalog_Price_Inventory.aspx"
                                                Text="Catalog Price & Inventory" /><img src="Images/new2.gif" alt="New QR Code Campaign Tracking Function"
                                                    style="border: 0px" width="28" height="11" /><br />
                                            <%--<a href="http://ec.advantech.eu/QRCampaign/Campaign_List.aspx" target="_blank">QR Code
                                                Campaign</a><br />--%>
                                            <asp:HyperLink runat="server" ID="hy_VMKey" NavigateUrl="~/DM/Marketing/VM_Keywords.aspx"
                                                Text="Vertical Market Keywords Analysis" /><br />
                                            <%--<a href="http://employeezone.advantech.com.tw/WebManager/CMS/Main.Asp" target="_blank">Content Management System (CMS)</a><br />--%>
                                            <asp:HyperLink runat="server" ID="hlPL" Target="_blank" Text="Partner Locator" /><br />
                                            <asp:LinkButton runat="server" ID="btnSolutionDay" Text="Solution Day Administration"
                                                OnClick="btnSolutionDay_Click" />
                                            <asp:Literal ID="Ecard_Lit" runat="server"><br /></asp:Literal>
                                            <asp:HyperLink runat="server" ID="hleDMTool" NavigateUrl="https://my.advantech.com/EC/AllEDMNewsletters.aspx" Text="eDM Tool" /><br />
                                            <asp:HyperLink runat="server" ID="Ecard_A" NavigateUrl="~/EC/eCard.aspx" Text="eCard System" /><br />
                                            <asp:Literal ID="Wiki_Lit" runat="server"></asp:Literal><asp:HyperLink runat="server"
                                                ID="hyElearn" Text="Learning Passport" Target="_blank" /><br />
                                            <asp:LinkButton runat="server" ID="btnWiki" Text="AdvantechWiki" OnClick="btnWiki_Click" />
                                            <br />
                                            <asp:HyperLink runat="server" ID="hleMarketing" Text="Customizable eMarketing" NavigateUrl="https://www.advantech-eautomation.com/eMarketingPrograms/ChannelPartner/Channel_Partner_ppt/Advantech%20IAG%20eDMs%202009.htm"
                                                Target="_blank" Visible="false" />
                                            <%--<br runat="server" id="hleMarketingBr" visible="false" />
                                            <asp:HyperLink runat="server" ID="HyperLink17" Target="_blank" NavigateUrl="~/My/AOnline/UNICA_SBU_Campaigns_New.aspx"
                                                Text="Advantech Campaign Overview" />
                                            <img src="./images/new2.gif" alt="Advantech Campaign Overview" style="border: 0px"
                                                width="28" height="11" />
                                            <br />--%>
                                            <asp:HyperLink runat="server" ID="hyMyCampaigns" CssClass="pl17" Target="_blank"
                                                Text="My Campaigns" NavigateUrl="~/My/Campaign/CampaignList.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">Data Mining </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="20"></td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%"></td>
                                        <td class="menu_list">
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyBTOSOrderHistory" NavigateUrl="~/Admin/BTOS_OrderHistory.aspx"
                                                Text="BTOS Order History Inquiry" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyKABTOSOrderHistory" NavigateUrl="~/Order/BO_KA_BTOS_OrderHistory.aspx"
                                                Text="KA BTOS Order History Inquiry" />
                                            <img src="./images/new2.gif" alt="KA BTOS Order History Inquiry" style="border: 0px"
                                                width="28" height="11" />
                                            <br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyAOnlineSalesPortal" NavigateUrl="~/My/AOnline/ContentSearch.aspx"
                                                Text="AOnline Sales Portal" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyOrderByMNSN" NavigateUrl="~/My/AOnline/SearchOrderByModelSerialNo.aspx"
                                                Text="Search Order By Model/Serial No." /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hySalesDB" NavigateUrl="~/DM/SalesDashboard.aspx"
                                                Text="Sales Dashboard" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyCustDB" NavigateUrl="~/DM/CustomerDashboard.aspx"
                                                Text="Customer Dashboard" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyProdDB" NavigateUrl="~/DM/ProductDashboard.aspx"
                                                Text="Product Dashboard" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyMyDB" Visible="false" NavigateUrl="~/My/MyDashboard.aspx"
                                                Text="My Dashboard (For Channel Partner)" OnLoad="hyMyDB_Load" />
                                            <asp:Literal runat="server" ID="MyDBbr"></asp:Literal><asp:HyperLink ForeColor="#00008B"
                                                runat="server" ID="hyAccountAnalysis" NavigateUrl="http://unica.advantech.com.tw/AOnline/CustomerAnalysis.aspx" Text="Customer Analysis" /><br />
                                            <%--<asp:HyperLink ForeColor="#00008B" runat="server" ID="hyTopCust" NavigateUrl="~/DM/DMF/TopCustAnalysis.aspx"
                                                Text="Top Customers" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyHotPN" NavigateUrl="~/DM/DMF/TopPNAnalysis.aspx"
                                                Text="Hot Products" /><br />--%>
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyCTOSAnalysis" NavigateUrl="~/DM/CTOSAnalysis.aspx"
                                                Text="CTOS Analysis" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyExwAnalysis" NavigateUrl="~/DM/WarrantyExpireCustomerList.aspx"
                                                Text="Warranty Expired Customers" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">Office ADMIN. </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="20"></td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%"></td>
                                        <td class="menu_list">
                                            <a href="../Includes/ToEIP.ashx?EIPPID=Meet_Room" target="_blank">Meeting Room Reservation</a><br />
                                            <a href="../Includes/ToEIP.ashx?EIPPID=ePR%20/%20eClaim" target="_blank">ePR/eClaim</a><br />
                                            <a href="../Includes/ToEIP.ashx?EIPPID=Leave_Request" target="_blank">Leave Request</a><br />
                                            <asp:HyperLink runat="server" ID="hyEUEstock" Visible="false" NavigateUrl="http://estock.advantech.eu"
                                                Target="_blank" Text="eStock" />
                                            <br runat="server" id="brEUEstock" visible="false" />
                                            <a href="#" target="_blank">My Mail Box</a><br />
                                            <a href="../Includes/ToEIP.ashx?EIPPID=" target="_blank">Go to Employee Zone</a>
                                            <br />
                                            <%--                                            <asp:HyperLink runat="server" ID="HyperLink2" Target="_blank" NavigateUrl="http://crm-partner.advantech.com.tw/"
                                                Text="PRM System" />
                                            <img src="./images/new2.gif" alt="PRM System" style="border: 0px"
                                                width="28" height="11" />--%>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <uc10:eLearningBanner runat="server" ID="ucElBanner" Visible="false" />
                </td>
            </tr>
            <tr>
                <td>
                    <uc10:AMDBanner runat="server" ID="ucAMDBanner" />
                </td>
            </tr>
            <tr>
                <td>
                    <uc1:IntelPortalBanner ID="IntelPortalBanner1" runat="server" />
                </td>
            </tr>
            <tr>
                <td height="139">
                    <asp:HyperLink runat="server" ID="hyDAQ" NavigateUrl="~/DAQ/Default.aspx">
                        <img src="images/DAQ_Your_Way.jpg" width="246" height="138" style="border:0px" alt="" />
                    </asp:HyperLink></td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td height="139">
                    <a href="http://adamforum.com/" target="_blank">
                        <img src="images/banner_adm.jpg" width="246" height="138" alt="" /></a> </td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td>
                    <a href="http://iservicesblog.advantech.eu/IServiceBlog/" target="_blank">
                        <img src="images/promotionbutton1.jpg" /></a> </td>
            </tr>
        </table>
    </div>
    <div class="right">
        <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex="0">
            <asp:View ID="ViewTab1" runat="server">
                <table width="100%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td height="9"></td>
                    </tr>
                    <tr>
                        <td>
                            <div class="rightcontant">
                                <div id="slideshow">
                                    <table height="410" class="slide">
                                        <tr>
                                            <td height="3px"></td>
                                        </tr>
                                        <tr>
                                            <td height="10px"><a href="Product/CorporateMaterial.aspx" target='_blank'><font color="#f29702">Company Profile & Corporate Video</font></a></td>
                                        </tr>
                                        <tr>
                                            <td height="3px"></td>
                                        </tr>
                                        <tr>
                                            <td valign="top">
                                                <a href="Product/CorporateMaterial.aspx" target="_blank">
                                                    <img src="Includes/GetThumbnail.ashx?RowId=CorporateMaterial" width="620" /></a>
                                            </td>
                                        </tr>
                                    </table>
                                    <%--<table height="330">
                                        <tr>
                                            <td valign="top">
                                                <object width='450' height='300'>
                                                    <param name='movie' value='https://youtube.googleapis.com/v/FFd3qIWk4HE'></param>
                                                    <param name='wmode' value='transparent'></param>
                                                    <embed src='https://youtube.googleapis.com/v/FFd3qIWk4HE' type='application/x-shockwave-flash' wmode='transparent' width='450' height='300'></embed></object></td>
                                            <td width="10"></td>
                                            <td valign="top" style="padding-top: 10px"><a href="http://youtu.be/FFd3qIWk4HE" target="_blank">From Good to Great</a><br />
                                                <br />
                                                For 30 years, "Good to great" has always been Advantech's core philosophy, which lead us keep growing."Good to Great" is based on the 3-Circle Principle from Jim Collins' book. Advantech has put it into action by clearly defining Advantech's particular 3-Circle Principle. Watch the video to know more about Advantech's business philosophy!</td>
                                        </tr>
                                    </table>
                                    <table height="340">
                                        <tr>
                                            <td valign="top">
                                                <object width='450' height='300'>
                                                    <param name='movie' value='https://youtube.googleapis.com/v/LyPsdwSN6wQ'></param>
                                                    <param name='wmode' value='transparent'></param>
                                                    <embed src='https://youtube.googleapis.com/v/LyPsdwSN6wQ' type='application/x-shockwave-flash' wmode='transparent' width='450' height='300'></embed></object></td>
                                            <td width="10"></td>
                                            <td valign="top" style="padding-top: 5px">
                                                <a href="http://www.youtube.com/watch?v=LyPsdwSN6wQ" target="_blank">Visit Advantech's headquarter through the video with us.</a><br />
                                                <b>Advantech Mission:</b><br />
                                                <li>Enabling an intelligent Plant through our IoT and Embedded Platforms designed for system integrators.</li>
                                                <li>Working & Learning Toward a Beautiful Life under our Altruistic (LITA) Philosophy.</li>
                                                <b>Advantech Values:</b><br />
                                                <li>Customer Partnership and Talent Invigoration</li>
                                                <li>Integrity and Certitude</li>
                                                <li>Focused Leadership</li>
                                            </td>
                                        </tr>
                                    </table>
                                    <table height="330">
                                        <tr>
                                            <td valign="top">
                                                <object width='450' height='300'>
                                                    <param name='movie' value='https://youtube.googleapis.com/v/hr_htF0_zdI'></param>
                                                    <param name='wmode' value='transparent'></param>
                                                    <embed src='https://youtube.googleapis.com/v/hr_htF0_zdI' type='application/x-shockwave-flash' wmode='transparent' width='450' height='300'></embed></object></td>
                                            <td width="10"></td>
                                            <td valign="top" style="padding-top: 5px"><a href="http://www.youtube.com/watch?v=hr_htF0_zdI" target="_blank">Progressing the Advantech Story</a><br />
                                                <br />
                                                Established in 1983, Advantech has grown from a small business to an international enterprise. In the 30 years, the core spirit and management philosophy of Advantech Corporation is well presented in this corporate altruistic LITA tree.<br />
                                                <br />
                                                The video illustrates the story of what we have done in the past 30 years and our vision for the next 30 years.</td>
                                        </tr>
                                    </table>--%>
                                    <div id="nav"></div>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td height="10"></td>
                    </tr>
                    <tr runat="server" id="tr_banner1">
                        <td align="left">
                            <uc10:Banner runat="server" ID="ucBanner" />
                        </td>
                    </tr>
                    <tr>
                        <td height="10"></td>
                    </tr>
                    <tr valign="top">
                        <td align="left">
                            <uc9:WCustContent runat="server" ID="WCont1" />
                        </td>
                    </tr>
                    <tr>
                        <td height="10"></td>
                    </tr>
                </table>
            </asp:View>
            <asp:View ID="ViewTab2" runat="server">
                <%-- dynamic load user control "AENC_HomePage"   <uc11:AENC_HomePage runat="server" ID="AENC_HomePage1"  Visible="false" />
                --%>
            </asp:View>
        </asp:MultiView>
    </div>    
</asp:Content>
