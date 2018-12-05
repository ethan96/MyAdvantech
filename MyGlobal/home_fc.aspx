<%@ Page Title="MyAdvantech - Franchise Home" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
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
            hyElearn.NavigateUrl = Util.ELearingUrl 'Andrew 2015/9/16 modify Learning Passport url
        End If
        'TC avoid Hi False
        If username.Equals("False") Then username = "customer"
        If Session("user_id") IsNot Nothing And Session("TempId") IsNot Nothing Then
            'hlPL.NavigateUrl = "http://www.advantech.com.tw/partner/partner_admin/login.aspx?tempid=" + Session("TempId") + "&pass=my&id=" + Session("user_id")
            lblUserName.Text = "<a href='https://member.advantech.com/profile.aspx?pass=my&id=" + Session("user_id").ToString + "&lang=en&tempid=" + Session("TempId").ToString + "'>" + username + "</a>"
        End If
        
        If Not Page.IsPostBack Then
            If Session("account_status") IsNot Nothing AndAlso Session("account_status").ToString() = "EZ" Then tdLogin.Visible = True
            If (Session("account_status") Is Nothing OrElse Session("account_status").ToString() <> "FC") AndAlso Not Util.IsAEUIT() AndAlso HttpContext.Current.User.Identity.Name.ToLower() <> "tanya.lin@advantech.com.tw" Then Response.Redirect("home.aspx")
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
                'LiT20.Visible = False
            End If
            
            If Session("account_status") IsNot Nothing AndAlso Session("account_status").ToString() <> "FC" AndAlso HttpContext.Current.User.Identity.Name.ToLower() <> "tanya.lin@advantech.com.tw" Then btnDailyFlash.Enabled = False : btnDailyFlash.ForeColor = Drawing.Color.Gray
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.ToUpper = "US" Then
            If Session("ORG_ID") IsNot Nothing AndAlso Left(Session("ORG_ID").ToString.ToUpper, 2) = "US" Then
                'LiT29_br.Visible = False : LiT29.Visible = False : Ecard_A.Visible = False : Ecard_Lit.Visible = False : Wiki_Lit.Visible = False : btnWiki.Visible = False
                
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
            'Me.trQuoteTitle.Visible = True : Me.trQuoteContent.Visible = True
            'End If
            
            
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
            If Session("ORG_ID") IsNot Nothing AndAlso Session("ORG_ID").ToString.ToUpper.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
                tr_EUGATP.Visible = True
                'hleMarketing.NavigateUrl = "~/EC/eMarketingEDMEU.aspx"
                'hyEUEstock.Visible = True : brEUEstock.Visible = True : trAdvProdSearch.Visible = True
            End If
            hyAOnlineSalesPortal.NavigateUrl = "http://unica.advantech.com.tw/AOnline/TopContents.aspx?SessionId=" + HttpContext.Current.Session.SessionID + "&Email=" + HttpContext.Current.User.Identity.Name
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
        Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/quote/quotationMaster.aspx"))
        Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
    End Sub
    
    
    Protected Sub lbtnQuoteByCompany_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/order/quoteByCompany.aspx")
    End Sub

    Protected Sub lbtnQuoteRecd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
     
        Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/quote/MyQuotationRecord.aspx"))
        Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
    End Sub
    Protected Sub hyMyDB_Load(sender As Object, e As System.EventArgs)
        'hyMyDB.Visible = True : MyDBbr.Text = "<br/>"
    End Sub

    Protected Sub btnDailyFlash_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("http://172.20.1.105/Login_check.aspx?User_ID=" + HttpContext.Current.User.Identity.Name + "&ToURL=AonlineDailyFlash1.aspx")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="./EC/Includes/jquery-latest.min.js"></script>
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_beginRequest(beginRequest);
        function beginRequest() {
            prm._scrollPosition = null;
        }

        $(document).ready(function () {
            getCoBranding();
            canAccessABRQuotation();

            var sidebar = $('#sidebar-connect');
            sidebar.hide();

            $("#<%=me.HyCobranding.ClientID %>").click(function (e) {
                if ($("#<%=me.HyCobranding.ClientID %>").attr("href") == undefined || $("#<%=me.HyCobranding.ClientID %>").attr("href") == '') {
                    sidebar.toggle();
                }
            });

        });

          function canAccessABRQuotation() {
            $("body").css("cursor", "progress");
            var user_id = '<%=User.Identity.Name %>';
            $("#<%=me.TRABRQuotation.ClientID %>").hide();
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
                        $("#<%=me.TRABRQuotation.ClientID %>").show();
                    }

                    $("body").css("cursor", "auto");
                },
                error: function (msg) {
                }
            }
            );


        function getCoBranding() {
            $("body").css("cursor", "progress");
            $("#<%=me.TrCobranding.ClientID %>").hide();
            var temp_id = '<%=Session("TempId") %>';
            var user_id = '<%=User.Identity.Name %>';
            //var postData = JSON.stringify({ UserID: user_id });
            $.ajax({
                type: "POST",
                url: "./Services/MyServices.asmx/GetCoBranding",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    //alert(msg.d);
                    var ATPTotalInfo = $.parseJSON(msg.d);

                    if (ATPTotalInfo.length > 0) {

                        $("#<%=me.TrCobranding.ClientID %>").show();

                        if (ATPTotalInfo.length == 1) {
                            //alert(ATPTotalInfo[0].AdminSiteURL);
                            $("#<%=me.HyCobranding.ClientID %>").attr("href", ATPTotalInfo[0].AdminSiteURL + '?id=' + user_id + '&tempid=' + temp_id);
                            $("#<%=me.HyCobranding.ClientID %>").attr("target", '_blank');

                        } else {
                            var divCoBrandingURLs = $('#sidebar-connect');
                            //divCoBrandingURLs.append('<ul>');
                            $.each(ATPTotalInfo, function (i, item) {
                                //divCoBrandingURLs.append('<a href="' + item.AdminSiteURL + '" target="_blank">' + item.SiteName + '</a><br/>');
                                divCoBrandingURLs.append('<li><a href="' + item.AdminSiteURL + '?id=' + user_id + '&tempid=' + temp_id + '" target="_blank">' + item.SiteName + '</a>');
                            });
                            //divCoBrandingURLs.append('</ul>');
                        }
                    }

                    $("body").css("cursor", "auto");
                },
                error: function (msg) {
                    //$("body").css("cursor", "auto");
                    alert("error:" + msg.d);
                    //var divATP = $('#divACLATP');
                    //divATP.html('');
                }
            }
            );
        }
    </script>
    <div class="left">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td height="10">
                </td>
            </tr>
            <tr>
                <td runat="server" id="tdLogin" visible="false">
                    <div class="login">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="5%">
                                    &nbsp;
                                </td>
                                <td width="92%">
                                    &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td height="30">
                                    &nbsp;
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
                                <td height="10">
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td height="20">
                                </td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="5%" valign="top">
                                                <img src="images/point.gif" width="7" height="14" />
                                            </td>
                                            <td>
                                                Homepage for Channel Partner
                                                <asp:HyperLink runat="server" ID="hyHomeCP" NavigateUrl="~/home_cp.aspx">Click</asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td height="20">
                                </td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="5%" valign="top">
                                                <img src="images/point.gif" alt="" width="7" height="14" />
                                            </td>
                                            <td>
                                                Homepage for Key Account
                                                <asp:HyperLink runat="server" ID="hyHomeKA" NavigateUrl="~/home_ka.aspx">Click</asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="5%" valign="top">
                                                <img src="images/point.gif" alt="" width="7" height="14" />
                                            </td>
                                            <td>
                                                Homepage for General Account
                                                <asp:HyperLink runat="server" ID="hyHomeGA" NavigateUrl="~/home_ga.aspx">Click</asp:HyperLink>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                        <tr>
                                            <td width="5%" valign="top">
                                            </td>
                                            <th align="left">
                                                Change Company Id
                                            </th>
                                        </tr>
                                        <tr>
                                            <td width="5%" valign="top">
                                            </td>
                                            <td align="left">
                                                <uc8:ChgComp runat="server" ID="ChgComp1" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td height="20">
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="5">
                </td>
            </tr>
<%--            <tr runat="server" id="trQuoteTitle">
                <td height="24" class="menu_title">
                    <asp:Literal ID="Literal1" runat="server" OnLoad="LiTs_Load">eQuotation 2.0</asp:Literal>
                </td>
            </tr>
            <tr runat="server" id="trQuoteContent">
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
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
                        <tr>
                            <td height="25">
                            </td>
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
                        <tr>
                            <td height="25">
                            </td>
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
                            <td height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>--%>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT0" runat="server" OnLoad="LiTs_Load">Online Ordering</asp:Literal>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login" style="font-weight: bold;">
                        <tr>
                            <td width="5%" height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyCart" NavigateUrl="~/Order/Cart_List.aspx" Text="Place Component Orders" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyBTOS" NavigateUrl="~/Order/Btos_portal.aspx" Text="System Configuration/Orders" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyUploadOrder" NavigateUrl="~/Order/UploadOrderFromExcel.aspx" Text="Upload Order" />
                                        </td></tr></table></td></tr><tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyPriceATP" NavigateUrl="~/Order/PriceAndATP.aspx" Text="Check Price & Availability" />
                                        </td></tr></table></td></tr><tr runat="server" id="tr_EUGATP" visible="false">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyEUGATP" NavigateUrl="~/Order/QueryACLATP.aspx"
                                                Text="Check ACL Availability" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyOrderTracking" NavigateUrl="~/Order/BO_OrderTracking.aspx" Text="Order Tracking" />
                                        </td></tr></table></td></tr><tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyCartHistory" NavigateUrl="~/Order/CartHistory_List.aspx" Text="Cart & Configuration history" />
                                        </td></tr></table></td></tr>
                          <tr runat="server" id="TRABRQuotation" visible="true">
                                        <td height="25">
                                        </td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="./Order/ABRQuote/B2B_Quotation_List.aspx">
                                                            <asp:Literal ID="Literal11" runat="server">New Quotation</asp:Literal></a>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                        <tr>
                            <td height="10" />
                            <td />
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="5">
                </td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT3" runat="server" OnLoad="LiTs_Load">Product Info.</asp:Literal></td></tr><tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyProdSearch" NavigateUrl="~/Product/ProductSearch.aspx" Text="Search" />
                                        </td></tr></table></td></tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /></td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyPPhaseInOut" NavigateUrl="~/Product/Product_PhaseInOut.aspx"
                                                Text="Phase In/ Out" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyNewProd" NavigateUrl="~/Product/New_Product.aspx" Text="New Product Highlight" />
                                        </td></tr></table></td></tr><tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink2" 
                                                NavigateUrl="~/Order/Price_List.aspx" Text="Price List" />
                                        </td></tr></table></td></tr><tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink3" 
                                                NavigateUrl="~/My/AOnline/SearchOrderByModelSerialNo.aspx" 
                                                Text="Search Order by Serial No" /></td></tr></table></td></tr><tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink ID="hyWarrantyLookup" runat="server" text="Warranty Lookup" navigateurl="http://support.advantech.com.tw/RMA/NewRMAWarrantyLookup.aspx" Target="_blank" />
                                            </td></tr></table></td></tr>


                        <tr runat="server" visible="false">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink4" NavigateUrl="http://erma.advantech.com.tw/" Text="Return, Repair, Warranty" Target="_blank" />
                                        </td></tr></table></td></tr><tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink5" NavigateUrl="~/Order/MyRMA.aspx" Text="My RMA Record" />
                                        </td></tr></table></td></tr><tr>
                            <td height="10" />
                            <td />
                        </tr>
                    </table>
                </td>
            </tr>



            <tr>
                <td height="5">
                </td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="Literal2" runat="server" OnLoad="LiTs_Load">Marketing</asp:Literal></td></tr><tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink6" NavigateUrl="http://ec.advantech.eu" Text="eCampaign" />
                                        </td></tr></table></td>

                        </tr>
                        <tr runat="server">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyAOnlineSalesPortal" Text="AOnline Sales Portal"
                                                NavigateUrl="~/My/AOnline/ContentSearch.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyMKTMaterialSearch" Text="Marketing Material Search"
                                                NavigateUrl="~/My/AOnline/MKTMaterialSearch.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                         <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink1" Text="MyDashboard"
                                                NavigateUrl="~/My/MyDashboard.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="TrCobranding" visible="true">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" alt="" /> </td><td class="menu_title02">
                                                <asp:HyperLink ID="HyCobranding" runat="server">Co-branding Website Maintenance</asp:HyperLink></td></tr><tr>
                                        <td colspan="2" width="100%">
                                            <div id="sidebar-connect" style="display: none; position: absolute; border-style: solid;
                                            background-color: white; padding: 15px; width: 195px; overflow:auto;"></div>                                        
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10" />
                            <td />
                        </tr>
                    </table>
                </td>
            </tr>



            <tr>
                <td height="5">
                </td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="Literal4" runat="server" OnLoad="LiTs_Load">Sales Management</asp:Literal></td></tr><tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink8" NavigateUrl="http://crmap-aonline/prmportal_enu/start.swe" Text="Siebel" Target="_blank" />
                                            </td></tr></table></td></tr>
                        <tr runat="server">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:LinkButton runat="server" ID="btnDailyFlash" Text="AOnline Daily Flash" OnClick="btnDailyFlash_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10" />
                            <td />
                        </tr>
                    </table>
                </td>
            </tr>



            <tr>
                <td height="5">
                </td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="Literal6" runat="server" OnLoad="LiTs_Load">Download</asp:Literal></td></tr><tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10">
                            </td>
                            <td>
                            </td>
                        </tr>

                        <tr runat="server">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink11" Text="E-mail Account Application Form"
                                                NavigateUrl="" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr id="Tr4" runat="server">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink12" Text="Siebel Account Application Form"
                                                NavigateUrl="" />
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
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hlVOIP" Text="VOIP Software Installation"
                                                NavigateUrl="http://www.3cx.com/VOIP/voip-phone.html" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr id="Tr5" runat="server">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyElearn" Text="Learning Passport"
                                                NavigateUrl="~/Product/Search.aspx" Target="_blank" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr id="Tr6" runat="server">
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="HyperLink14" Text="Terms & Condition"
                                                NavigateUrl="~/Files/Terms_Index.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>


                        <tr>
                            <td height="10" />
                            <td />
                        </tr>
                    </table>
                </td>
            </tr>




<%--            <tr>
                <td height="5">
                </td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT4" runat="server" OnLoad="LiTs_Load">Support & Download</asp:Literal></td></tr><tr>
                <td>
                    <!--'Frank 2012/03/15
                    'UpdatePanel to make sure url of SupportBlock.HyperLink2 do really changed when change region-->
                    <uc9:SupportBlock runat="server" ID="ucSupportBlock" />
                </td>
            </tr>
--%>            

<%--            <tr>
                <td height="5">
                </td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT10" runat="server" OnLoad="LiTs_Load">Internal Functional Tools</asp:Literal></td></tr><tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td width="5%" height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" width="7" height="14" alt="" /> </td><td class="menu_title02">
                                            Project Registration </td></tr></table></td></tr><tr>
                            <td height="20">
                            </td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%">
                                        </td>
                                        <td class="menu_list">
                                            <asp:HyperLink runat="server" ID="hyMyLeads" NavigateUrl="~/My/MyLeads.aspx">
                                                <asp:Literal ID="LiT29" runat="server" OnLoad="LiTs_Load">Leads Management</asp:Literal></asp:HyperLink><asp:Literal
                                                    ID="LiT29_br" runat="server"><br /></asp:Literal>
                                            <asp:HyperLink runat="server" ID="hyPrjReg" Text="" NavigateUrl="~/My/ProjectRegist.aspx">
                                                <asp:Literal ID="LiT30" runat="server" OnLoad="LiTs_Load">Project Registration Request</asp:Literal>
                                                <asp:Literal ID="LiT31" runat="server" Visible="false">Special Price Request</asp:Literal>
                                            </asp:HyperLink><br />
                                            <asp:HyperLink runat="server" ID="HyperLink1" Text="" NavigateUrl="~/My/ProjectRegList.aspx">
                                                <asp:Literal ID="LiT360" runat="server" OnLoad="LiTs_Load">My Registered Projects</asp:Literal>
                                            </asp:HyperLink><br />
                                            <asp:HyperLink runat="server" ID="hyEPricer" NavigateUrl="~/Includes/ToEIP.ashx?EIPPID=ePricer_SSO"
                                                Target="_blank">ePricer</asp:HyperLink><br />
                                            <a href="http://employeezone.advantech.com.tw/eManager/" target="_blank">eManager</a><br />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            Marketing </td></tr></table></td></tr><tr>
                            <td height="20">
                            </td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%">
                                        </td>
                                        <td class="menu_list">
                                            <a href="http://ec.advantech.eu" target="_blank">eCampaign</a><br />
                                            <asp:HyperLink runat="server" ID="hyAdvPageRank" NavigateUrl="~/DM/SEO/AdvPageRankAnalysis.aspx"
                                                Text="Page Rank Analysis" /><img src="/Images/new2.gif" alt="New QR Code Campaign Tracking Function"
                                                    style="border: 0px" width="28" height="11" /><br />
                                            <asp:HyperLink runat="server" ID="hyCatalogPriceATP" NavigateUrl="~/DM/Marketing/Catalog_Price_Inventory.aspx"
                                                Text="Catalog Price & Inventory" /><img src="/Images/new2.gif" alt="New QR Code Campaign Tracking Function"
                                                    style="border: 0px" width="28" height="11" /><br />
                                            <a href="http://ec.advantech.eu/QRCampaign/Campaign_List.aspx" target="_blank">QR Code Campaign</a><br />
                                            <asp:HyperLink runat="server" ID="hy_VMKey" NavigateUrl="~/DM/Marketing/VM_Keywords.aspx"
                                                Text="Vertical Market Keywords Analysis" /><br />
                                            <a href="http://employeezone.advantech.com.tw/WebManager/CMS/Main.Asp" target="_blank">
                                                Content Management System (CMS)</a><br />
                                            <asp:HyperLink runat="server" ID="hlPL" Target="_blank" Text="Partner Locator" /><br />
                                            <asp:LinkButton runat="server" ID="btnSolutionDay" Text="Solution Day Administration"
                                                OnClick="btnSolutionDay_Click" />
                                            <asp:Literal ID="Ecard_Lit" runat="server"><br /></asp:Literal>
                                            <a href="http://partner.advantech.com.tw/Utility/App_Login.aspx?App=ecard" id="Ecard_A"
                                                runat="server" target="_blank">eCard System</a><br />
                                            <asp:Literal ID="Wiki_Lit" runat="server"></asp:Literal><asp:HyperLink runat="server"
                                                ID="hyElearn" Text="Learning Passport" Target="_blank" /><br />
                                            <asp:LinkButton runat="server" ID="btnWiki" Text="AdvantechWiki" OnClick="btnWiki_Click" />
                                            <br />
                                            <asp:HyperLink runat="server" ID="hleMarketing" Text="Customizable eMarketing" NavigateUrl="http://www.advantech-eautomation.com/eMarketingPrograms/ChannelPartner/Channel_Partner_ppt/Advantech%20IAG%20eDMs%202009.htm"
                                                Target="_blank" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            Data Mining </td></tr></table></td></tr><tr>
                            <td height="20">
                            </td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%">
                                        </td>
                                        <td class="menu_list">
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyAOnlineSalesPortal" NavigateUrl="~/My/AOnline/ContentSearch.aspx"
                                                Text="AOnline Sales Portal" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyOrderByMNSN" 
                                                NavigateUrl="~/My/AOnline/SearchOrderByModelSerialNo.aspx"
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
                                                runat="server" ID="hyAccountAnalysis" NavigateUrl="~/DM/ATWAccounts.aspx" Text="Customer Analysis" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyTopCust" NavigateUrl="~/DM/DMF/TopCustAnalysis.aspx"
                                                Text="Top Customers" /><br />
                                            <asp:HyperLink ForeColor="#00008B" runat="server" ID="hyHotPN" NavigateUrl="~/DM/DMF/TopPNAnalysis.aspx"
                                                Text="Hot Products" /><br />
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
                            <td height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td height="25">
                            </td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" /> </td><td class="menu_title02">
                                            Office ADMIN. </td></tr></table></td></tr><tr>
                            <td height="20">
                            </td>
                            <td class="menu_list">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="10%">
                                        </td>
                                        <td class="menu_list">
                                            <a href="../Includes/ToEIP.ashx?EIPPID=Meet_Room" target="_blank">Meeting Room Reservation</a><br />
                                            <a href="../Includes/ToEIP.ashx?EIPPID=ePR%20/%20eClaim" target="_blank">ePR/eClaim</a><br />
                                            <a href="../Includes/ToEIP.ashx?EIPPID=Leave_Request" target="_blank">Leave Request</a><br />
                                            <asp:HyperLink runat="server" ID="hyEUEstock" Visible="false" NavigateUrl="http://employee.advantech.eu"
                                                Target="_blank" Text="eStock" />
                                            <br runat="server" id="brEUEstock" visible="false" />
                                            <a href="#" target="_blank">My Mail Box</a><br />
                                            <a href="../Includes/ToEIP.ashx?EIPPID=" target="_blank">Go to Employee Zone</a> </td></tr></table></td></tr><tr>
                            <td height="10">
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>--%>
            <tr>
                <td height="10">
                </td>
            </tr>
            <tr>
                <td>
                    <uc10:eLearningBanner runat="server" ID="ucElBanner" />
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
                    </asp:HyperLink></td></tr><tr>
                <td height="10">
                </td>
            </tr>
            <tr>
                <td height="139">
                    <a href="http://adamforum.com/" target="_blank">
                        <img src="images/banner_adm.jpg" width="246" height="138" alt="" /></a> </td></tr><tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td><a href="http://iservicesblog.advantech.eu/IServiceBlog/" target="_blank"><img src="images/promotionbutton1.jpg" /></a></td></tr></table></div><div class="right">
        <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex="0">
            <asp:View ID="ViewTab1" runat="server">
                <table width="100%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td height="9">
                        </td>
                    </tr>
                    <tr runat="server" id="tr_banner1">
                        <td align="left">
                            <uc10:Banner runat="server" ID="ucBanner" />
                        </td>
                    </tr>
                    <tr>
                        <td height="10">
                        </td>
                    </tr>
                    <tr valign="top">
                        <td align="left">
                            <uc9:WCustContent runat="server" ID="WCont1" />
                        </td>
                    </tr>
                    <tr>
                        <td height="10">
                        </td>
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
