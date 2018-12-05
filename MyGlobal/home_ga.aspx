<%@ Page Title="MyAdvantech - Homepage" Language="VB" MasterPageFile="~/Includes/MyMaster.master" EnableEventValidation="false" %>

<%@ Import Namespace="System.Drawing" %>
<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>
<%@ Register TagName="GAContactBlocak" TagPrefix="uc1" Src="~/Includes/GAContactBlock.ascx" %>
<%@ Register TagName="GAFooter" TagPrefix="uc2" Src="~/Includes/GAFooter.ascx" %>
<%@ Register Src="My/Intel/IntelPortalBanner.ascx" TagName="IntelPortalBanner" TagPrefix="uc1" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.Master.EnableAsyncPostBackHolder = False
        End If

        Dim username As String = ""
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            username = Session("user_id").split("@")(0).ToString.Split(".")(0)

            If Util.IsInternalUser(Session("user_id")) = False Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 isnull(FirstName,'') as firstname from siebel_contact where email_address='{0}' order by account_status", Session("user_id")))
                If dt.Rows.Count > 0 Then
                    If dt.Rows(0).Item(0).ToString <> "" Then username = dt.Rows(0).Item(0).ToString
                Else
                    If Session("FirstName") <> "" Then username = Session("FirstName")
                End If
            Else
                If Session("FirstName") <> "" Then username = Session("FirstName")
            End If
            lbluser.Text = username.Substring(0, 1).ToUpper() + username.Substring(1)

            If Not AuthUtil.IsACN Then
                Me.ACNPackingList.Visible = True
                Me.ACNTestReport.Visible = True
            End If
        Else
            lbluser.Text = "Guest"
        End If
        If Session("user_id") IsNot Nothing AndAlso Session("TempId") IsNot Nothing Then
            hyElearn.NavigateUrl = Util.ELearingUrl 'Andrew 2015/9/17 modify Learning Passport url
        End If
        gvEDM.DataSource = GetMyEDM() : gvEDM.DataBind()
        Dim cdt As DataTable = GetCustContent(True)
        Dim wpaperDt As DataTable = cdt.Clone()
        Dim rTypes() As String = {"White Papers"}
        Dim rTables() As DataTable = {wpaperDt}
        Dim gvResources() As GridView = {gvWhiteP}
        Dim rs() As DataRow = Nothing
        For i As Integer = 0 To rTypes.Length - 1
            rs = cdt.Select("CATEGORY_NAME='" + rTypes(i) + "'")
            If rs.Length > 0 Then
                For Each r As DataRow In rs
                    rTables(i).ImportRow(r)
                Next
            End If
        Next
        For i As Integer = 0 To rTypes.Length - 1
            If rTables(i).Rows.Count = 0 Then
                cdt = GetCustContent(False) : Exit For
            End If
        Next
        For i As Integer = 0 To rTypes.Length - 1
            If rTables(i).Rows.Count = 0 Then
                rs = cdt.Select("CATEGORY_NAME='" + rTypes(i) + "'")
                If rs.Length > 0 Then
                    For Each r As DataRow In rs
                        rTables(i).ImportRow(r)
                    Next
                End If
            End If
            gvResources(i).DataSource = rTables(i) : gvResources(i).DataBind()
        Next
    End Sub

    Function GetMyEDM() As DataTable
        Dim strSql As String = String.Format(
            " select top 1 b.row_id, a.contact_email, b.email_subject, b.description, isnull(b.url,'') as url " +
            " from campaign_contact_list a inner join campaign_master b on a.campaign_row_id=b.row_id " +
            " where a.contact_email='{0}' and b.actual_send_date is not null order by a.email_send_time desc", HttpContext.Current.User.Identity.Name)
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", strSql)
        If dt.Rows.Count = 0 Then
            dt = dbUtil.dbGetDataTable("RFM", String.Format("select top 1 b.row_id, b.email_subject, b.description, isnull(b.url,'') as url from CAMPAIGN_MASTER b where CAMPAIGN_NAME Like N'%eStore%' and ACTUAL_SEND_DATE is not null and CLICK_CUST>100 and is_public=1 order by ACTUAL_SEND_DATE desc"))
        End If
        Return dt
    End Function

    Function GetCustContent(ByVal UseBaa As Boolean) As DataTable
        Dim userBaa As New ArrayList
        If UseBaa Then userBaa = Util.GetUserBaa()
        Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT distinct top 1 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, "))
            .AppendLine(String.Format(" a.ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, "))
            .AppendLine(String.Format(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, "))
            .AppendLine(String.Format(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME "))
            .AppendLine(String.Format(" FROM WWW_RESOURCES AS a "))
            .AppendLine(String.Format(" WHERE a.ABSTRACT<>''  "))
            If Session("lanG") = "KOR" Then
                .AppendLine(String.Format(" and a.RBU ='AKR' "))
            ElseIf Session("lanG") = "JAP" Then
                .AppendLine(String.Format(" and a.RBU ='AJP' "))
            Else
                .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU') "))
            End If
            .AppendLine(String.Format(" and a.CATEGORY_NAME='White Papers'  "))
            If Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
        End With
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function

    Protected Sub imgEDM_DataBinding(sender As Object, e As System.EventArgs)
        Dim img As System.Web.UI.WebControls.Image = CType(sender, System.Web.UI.WebControls.Image)
        img.ImageUrl = "~/Includes/GetThumbnail.ashx?RowId=" + img.ImageUrl
    End Sub

    Protected Sub lblWhiteP_DataBinding(sender As Object, e As System.EventArgs)
        BindText(CType(sender, Label))
    End Sub

    Public Sub BindText(ByVal lbl As Label)
        If Len(lbl.Text) > 200 Then
            lbl.Text = lbl.Text.Substring(0, 200) + String.Format("<a href='javascript:void(0);' onclick='javascript:ShowText(""{0}"",""{1}"")'> ...</a>", lbl.ClientID, lbl.Text)
        End If
    End Sub

    Protected Sub hlWhitePaper_Load(sender As Object, e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink), strLitType As Integer = -1
        strLitType = 19
        If Session("account_status") Is Nothing Then
            strLitType = 9
        Else
            If Session("account_status") = "CP" Then strLitType = 17
            If Session("account_status") = "GA" Then strLitType = 9
        End If
        hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=" + strLitType.ToString()
    End Sub

    Protected Sub LoginStatus1_LoggingOut(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.LoginCancelEventArgs)
        Dim httpWebcookie As HttpCookie
        httpWebcookie = Request.Cookies(".AEULogin")
        If httpWebcookie IsNot Nothing Then
            Try
                httpWebcookie.Domain = Request.Url.Host : httpWebcookie.Expires = DateTime.Now.AddYears(-3) : Response.Cookies.Add(httpWebcookie)
            Catch ex As Exception
            End Try
        End If
        Session("user_id") = "" : Session("FirstName") = "" : Session.Abandon() : FormsAuthentication.SignOut() : Server.Transfer("~/Logout.aspx")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link href="./Includes/styles.css" rel="Stylesheet" type="text/css" />
    <link href="./Includes/main.css" rel="Stylesheet" type="text/css" />
    <link href="./Includes/systemselection.css" rel="Stylesheet" type="text/css" />
    <style type="text/css">
        ul.sign {
            list-style: none;
            margin: 0;
            padding: 0;
            display: block;
        }

            ul.sign li {
                display: block;
                background: none;
                margin: 0;
                padding: 0;
                line-height: normal;
            }

                ul.sign li a {
                    display: block;
                    outline: none;
                    margin: 0;
                    text-decoration: none;
                    color: #3399FF;
                }

                    ul.sign li a:hover, ul.sign li a:active, ul.sign li a:focus {
                        color: #CC0000;
                        text-decoration: none;
                    }
    </style>
    <script type="text/javascript">
        function ShowText(id, text) {
            document.getElementById(id).innerText = text;
        }
    </script>
    <!-- MAIN CONTAINER -->

    <div class="at-maincontainer wrap column2">
        <div style="text-align: right">
            <b>Hi, </b>
            <asp:Label runat="server" ID="lbluser" Font-Bold="true" />
            <a href="../My/MyProfile.aspx" style="color: #3399FF">Edit My Profile</a> |
           
            <asp:LoginStatus runat="server" ID="LoginStatus1" LogoutText="Log out" ForeColor="#3399FF"
                OnLoggingOut="LoginStatus1_LoggingOut" />
        </div>
        <div class="at-mainbody">
            <table cellpadding="0" cellspacing="0">
                <tr>
                    <td height="3"></td>
                </tr>
            </table>
            <!-- CONTENT -->
            <div style="padding-bottom: 20px;">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td width="24%" valign="top" style="border: #CCC solid 1px; background: url(images/box-btm.gif) repeat-x left bottom;">
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange" style="font-size: 96%">MY ACCOUNT</h3>
                                <div class="box-ct clearfix">
                                    <ul class="plussign">
                                        <li><a href="../My/MyProfile.aspx"><span>Profile</span></a></li>
                                        <li><a href="../My/MySubscriptionRSS.aspx"><span></span>Subscriptions</a></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                        <td valign="top">&nbsp;
                        </td>
                        <td width="24%" valign="top" style="border: #CCC solid 1px; background: url(images/box-btm.gif) repeat-x left bottom;">
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange" style="font-size: 96%">MY STORE</h3>
                                <div class="box-ct clearfix">
                                    <ul class="plussign">
                                        <li><a href="https://buy.advantech.com/" target="_blank"><span>Shopping Cart</span></a></li>
                                        <li><a href="https://buy.advantech.com/" target="_blank"><span>Quotes</span></a></li>
                                        <li><a href="https://buy.advantech.com/" target="_blank"><span>Orders & Delivery</span></a></li>
                                        <li><a href="../My/MyViewedProduct.aspx"><span>Viewed Products</span></a></li>
                                        <li><a href="../My/MyWishList.aspx"><span>Wish List</span></a></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                        <td valign="top">&nbsp;
                        </td>
                        <td width="24%" valign="top" style="border: #CCC solid 1px; background: url(images/box-btm.gif) repeat-x left bottom;">
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange" style="font-size: 96%">MY SUPPORT</h3>
                                <div class="box-ct clearfix">
                                    <ul class="plussign">
                                        <li><a href="../Product/New_Product.aspx"><span>New Product Highlight</span></a></li>
                                        <li><a href="../Product/Product_PhaseInOut.aspx"><span>Product Phase in/out</span></a></li>
                                        <li><a href="../My/MyDownloadList.aspx"><span>My Download Document</span></a></li>
                                        <li><a href="http://forum.adamcommunity.com/index.php" target="_blank"><span>Technical Forum</span></a></li>
                                        <li>
                                            <asp:HyperLink runat="server" ID="hyElearn" Text="Learning Passport" Target="_blank" /></li>
                                        <li><a href="http://erma.advantech.com.tw/" target="_blank"><span>Return & Repair</span></a></li>
                                        <li><a href="../Order/MyWarrantyExpireItems.aspx"><span>Warranty</span></a></li>                                        
                                        <li runat="server" id="ACNPackingList"><a href="http://ictos.advantech.com.cn/Report/SearchPacking" target="_blank"><span>Packing List</span></a></li>
                                        <li runat="server" id="ACNTestReport"><a href="http://ictos.advantech.com.cn/Report/SearchTest" target="_blank"><span>Test Report</span></a></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                        <td valign="top">&nbsp;
                        </td>
                        <td width="24%" valign="top" style="border: #CCC solid 1px; background: url(images/box-btm.gif) repeat-x left bottom;">
                            <div style="padding: 10px 15px;">
                                <h3 class="title-orange" style="font-size: 96%">MY VIEWED MATERIALS</h3>
                                <div class="box-ct clearfix">
                                    <ul class="plussign">
                                        <li><a href="../My/MyViewedList.aspx?C=Video">
                                            <span>Video</span></a></li>
                                        <li><a href="../My/MyViewedList.aspx?C=News">
                                            <span>News</span></a></li>
                                        <li><a href="../My/MyViewedList.aspx?C=eDM">
                                            <span>eDM</span></a></li>
                                        <li><a href="../My/MyViewedList.aspx?C=CaseStudy">
                                            <span>Case Study</span></a></li>
                                        <li><a href="../My/MyViewedList.aspx?C=WhitePaper">
                                            <span>White Paper</span></a></li>
                                    </ul>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="at-list1" style="width: 49%; float: left">
                <div>
                    <h3>eDM</h3>
                    <asp:GridView runat="server" ID="gvEDM" EnableTheming="false" AutoGenerateColumns="false"
                        ShowHeader="false" BorderColor="White" BorderWidth="0">
                        <Columns>
                            <asp:TemplateField ItemStyle-BorderColor="White">
                                <ItemTemplate>
                                    <a href='../Includes/GetTemplate.ashx?RowId=<%#Eval("row_id") %>'
                                        target='_blank'>
                                        <%# Trim(Eval("email_subject"))%></a>
                                    <table cellpadding="0" cellspacing="0" border="0">
                                        <tr>
                                            <td height="10"></td>
                                        </tr>
                                        <tr>
                                            <td valign="top">
                                                <a href='../Includes/GetTemplate.ashx?RowId=<%#Eval("row_id") %>'
                                                    target='_blank'>
                                                    <asp:Image runat="server" ID="imgEDM" ImageUrl='<%#Eval("row_id") %>' Width="100" Height="100" OnDataBinding="imgEDM_DataBinding" />
                                                </a>
                                            </td>
                                            <td valign="top">
                                                <asp:Label runat="server" ID="lbleDM" Text='<%#Eval("description") %>' />
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
                <div style="clear: both; text-align: right;">
                    <a href="../My/MyViewedList.aspx?C=eDM" class="at-button" title="See Details">> See Details</a>
                </div>
            </div>
            <div class="at-list1" style="width: 49%; float: right">
                <div>
                    <h3>White Paper</h3>
                    <asp:GridView runat="server" ID="gvWhiteP" EnableTheming="false" AutoGenerateColumns="false"
                        ShowHeader="false" BorderColor="White" BorderWidth="0">
                        <Columns>
                            <asp:TemplateField ItemStyle-BorderColor="White">
                                <ItemTemplate>
                                    <a href='https://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                        target='_blank'>
                                        <%#Trim(Eval("title"))%></a>
                                    <table cellpadding="0" cellspacing="0" border="0">
                                        <tr>
                                            <td height="10"></td>
                                        </tr>
                                        <tr>
                                            <td valign="top">
                                                <a href='https://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                                    target='_blank'>
                                                    <asp:Image runat="server" ID="imgWhiteP" ImageUrl="~/images/pud2.jpg" />
                                                </a>
                                            </td>
                                            <td valign="top">
                                                <asp:Label runat="server" ID="lblWhiteP" Text='<%#Eval("abstract") %>' OnDataBinding="lblWhiteP_DataBinding" />
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
                <div style="clear: both; text-align: right;">
                    <asp:HyperLink runat="server" ID="hlWhitePaper" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=19"
                        Text="> See Details" Width="100" Height="12" CssClass="at-button" OnLoad="hlWhitePaper_Load" />
                </div>
            </div>
            <div class="clear">
            </div>
            <!-- //CONTENT -->

        </div>
        <div class="at-sidebar at-sidebar-right">
            <uc1:IntelPortalBanner runat="server" ID="IntelBanner1" />
            <uc1:GAContactBlocak runat="server" ID="ucGAContactBlock" />
        </div>
    </div>
    <uc2:GAFooter runat="server" ID="ucGAFooter" />
</asp:Content>

