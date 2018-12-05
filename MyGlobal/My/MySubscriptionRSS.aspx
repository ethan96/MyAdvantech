<%@ Page Title="My Subscription" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="GAContactBlocak" TagPrefix="uc1" Src="~/Includes/GAContactBlock.ascx" %>
<%@ Register TagName="GAFooter" TagPrefix="uc2" Src="~/Includes/GAFooter.ascx" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request.IsAuthenticated Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select distinct name from SIEBEL_CONTACT_INTERESTED_ENEWS where CONTACT_ROW_ID in (select row_id from SIEBEL_CONTACT where EMAIL_ADDRESS='{0}')", Session("user_id")))
                If dt.Rows.Count > 0 Then
                    For Each row As DataRow In dt.Rows
                        Select Case row.Item("name")
                            Case "Industrial Automation"
                                cbIndust.Checked = True
                            Case "Medical Computing"
                                cbMedical.Checked = True
                            Case "Transportation Infrastructure"
                                cbTrans.Checked = True
                            Case "Logistics & In-Vehicle Computing"
                                cbLogistic.Checked = True
                            Case "Digital Signage & Self-Service"
                                cbDigital.Checked = True
                            Case "Building & Home Automation"
                                cbBuilding.Checked = True
                            Case "Embedded Boards & Systems"
                                cbEmbed.Checked = True
                            Case "Gaming"
                                cbGaming.Checked = True
                            Case "Networks & Telecom"
                                cbNetwork.Checked = True
                            Case " IoTMart eNews (Embedded)"
                                'cbEmbedIoT.Checked = True
                            Case "eNews Clips – Industry 4.0"
                                cbIndustry4_0.Checked = True
                            Case "eNews Clips – Industry IoT"
                                cbSmartEnvironment.Checked = True
                            Case "IoTMart eNews (Intelligent Hospital)"
                                'cbIntelligentHostipal.Checked = True
                        End Select
                    Next
                End If
            End If
        End If
    End Sub

    Protected Sub btnNext_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request.IsAuthenticated = False Then
            Util.AjaxJSAlertRedirect(up1, "Please login first. Thank you!", "../home.aspx?ReturnUrl=%2fMy%2fMySubscriptionRSS.aspx")
            Exit Sub
        End If
        lblSub.Text = "" : lblUnsub.Text = ""
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select distinct name from SIEBEL_CONTACT_INTERESTED_ENEWS where CONTACT_ROW_ID in (select row_id from SIEBEL_CONTACT where EMAIL_ADDRESS='{0}')", Session("user_id")))
        Dim arrEnews As New ArrayList
        For Each row As DataRow In dt.Rows
            arrEnews.Add(row.Item(0))
        Next
        If cbIndust.Checked AndAlso Not arrEnews.Contains("Industrial Automation") Then
            lblSub.Text += "<li>Industrial Automation</li>"
        Else
            If arrEnews.Contains("Industrial Automation") AndAlso Not cbIndust.Checked Then lblUnsub.Text += "<li>Industrial Automation</li>"
        End If
        If cbMedical.Checked AndAlso Not arrEnews.Contains("Medical Computing") Then
            lblSub.Text += "<li>Medical Computing</li>"
        Else
            If arrEnews.Contains("Medical Computing") AndAlso Not cbMedical.Checked Then lblUnsub.Text += "<li>Medical Computing</li>"
        End If
        If cbTrans.Checked AndAlso Not arrEnews.Contains("Transportation Infrastructure") Then
            lblSub.Text += "<li>Transportation Infrastructure</li>"
        Else
            If arrEnews.Contains("Transportation Infrastructure") AndAlso Not cbTrans.Checked Then lblUnsub.Text += "<li>Transportation Infrastructure</li>"
        End If
        If cbLogistic.Checked AndAlso Not arrEnews.Contains("Logistics & In-Vehicle Computing") Then
            lblSub.Text += "<li>Logistics & In-Vehicle Computing</li>"
        Else
            If arrEnews.Contains("Logistics & In-Vehicle Computing") AndAlso Not cbLogistic.Checked Then lblUnsub.Text += "<li>Logistics & In-Vehicle Computing</li>"
        End If
        If cbDigital.Checked AndAlso Not arrEnews.Contains("Digital Signage & Self-Service") Then
            lblSub.Text += "<li>Digital Signage & Self-Service</li>"
        Else
            If arrEnews.Contains("Digital Signage & Self-Service") AndAlso Not cbDigital.Checked Then lblUnsub.Text += "<li>Digital Signage & Self-Service</li>"
        End If
        If cbBuilding.Checked AndAlso Not arrEnews.Contains("Building & Home Automation") Then
            lblSub.Text += "<li>Building & Home Automation</li>"
        Else
            If arrEnews.Contains("Building & Home Automation") AndAlso Not cbBuilding.Checked Then lblUnsub.Text += "<li>Building & Home Automation</li>"
        End If
        If cbEmbed.Checked AndAlso Not arrEnews.Contains("Embedded Boards & Systems") Then
            lblSub.Text += "<li>Embedded Boards & Systems</li>"
        Else
            If arrEnews.Contains("Embedded Boards & Systems") AndAlso Not cbEmbed.Checked Then lblUnsub.Text += "<li>Embedded Boards & Systems</li>"
        End If
        If cbGaming.Checked AndAlso Not arrEnews.Contains("Gaming") Then
            lblSub.Text += "<li>Gaming</li>"
        Else
            If arrEnews.Contains("Gaming") AndAlso Not cbGaming.Checked Then lblUnsub.Text += "<li>Gaming</li>"
        End If
        If cbNetwork.Checked AndAlso Not arrEnews.Contains("Networks & Telecom") Then
            lblSub.Text += "<li>Networks & Telecom</li>"
        Else
            If arrEnews.Contains("Networks & Telecom") AndAlso Not cbNetwork.Checked Then lblUnsub.Text += "<li>Networks & Telecom</li>"
        End If
        
        If cbIndustry4_0.Checked AndAlso Not arrEnews.Contains("Industry 4.0") Then
            lblSub.Text += "<li>Industry 4.0</li>"
        Else
            If arrEnews.Contains("Industry 4.0") AndAlso Not cbIndustry4_0.Checked Then lblUnsub.Text += "<li>Industry 4.0</li>"
        End If
        If cbSmartEnvironment.Checked AndAlso Not arrEnews.Contains("Industry IoT") Then
            lblSub.Text += "<li>Industry IoT</li>"
        Else
            If arrEnews.Contains("Industry IoT") AndAlso Not cbSmartEnvironment.Checked Then lblUnsub.Text += "<li>Industry IoT</li>"
        End If
        'If cbEmbedIoT.Checked AndAlso Not arrEnews.Contains("Industry 4.0") Then
        '    lblSub.Text += "<li>Industry 4.0</li>"
        'Else
        '    If arrEnews.Contains("Industry 4.0") AndAlso Not cbEmbedIoT.Checked Then lblUnsub.Text += "<li>Industry 4.0</li>"
        'End If
        'If cbIntelligentHostipal.Checked AndAlso Not arrEnews.Contains("Intelligent Hospital") Then
        '    lblSub.Text += "<li>Intelligent Hospital</li>"
        'Else
        '    If arrEnews.Contains("Intelligent Hospital") AndAlso Not cbIntelligentHostipal.Checked Then lblUnsub.Text += "<li>Intelligent Hospital</li>"
        'End If
        mpeSubscribe.Show()
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim siebel_ws As New aeu_eai2000.Siebel_WS
        siebel_ws.UseDefaultCredentials = True
        siebel_ws.Timeout = 300000
        If lblUnsub.Text <> "" Then
            'siebel_ws.SubscribeENews2(Session("user_id"), lblUnsub.Text.Replace("<li>", "").Replace("</li>", "|"), False)
            Dim arrEnews As New ArrayList
            For Each enews As String In lblUnsub.Text.Replace("<li>", "").Replace("</li>", "|").Split("|")
                If enews <> "" Then
                    arrEnews.Add("'" + enews + "'")
                    dbUtil.dbExecuteNoQuery("MY", String.Format("insert into CurationPool.dbo.CURATION_ACTIVITY_IMPORTED_ENEWS_LOG (IMPORT_ROW_ID,ENEWS,EMAIL,SUBSCRIBE) values ('MY','{0}','{1}',0)", enews.Replace("'", "''"), Session("user_id")))
                End If
            Next
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from SIEBEL_CONTACT_INTERESTED_ENEWS where name in ({1}) and contact_row_id in (select row_id from siebel_contact where email_address ='{0}')", Session("user_id"), String.Join(",", arrEnews.ToArray())))
        End If
        If lblSub.Text <> "" Then
            'siebel_ws.SubscribeENews2(Session("user_id"), lblSub.Text.Replace("<li>", "").Replace("</li>", "|"), True)
            Dim dt As DataTable = dbUtil.dbGetDataTable("My", String.Format("select row_id from siebel_contact where email_address='{0}'", Session("user_id")))
            For Each enews As String In lblSub.Text.Replace("<li>", "").Replace("</li>", "|").Split("|")
                If enews <> "" Then
                    For Each row As DataRow In dt.Rows
                        dbUtil.dbExecuteNoQuery("MY", String.Format("insert into SIEBEL_CONTACT_INTERESTED_ENEWS (contact_row_id,name,primary_flag) values ('{0}','{1}','0')", row.Item(0), enews))
                    Next
                    dbUtil.dbExecuteNoQuery("MY", String.Format("insert into CurationPool.dbo.CURATION_ACTIVITY_IMPORTED_ENEWS_LOG (IMPORT_ROW_ID,ENEWS,EMAIL,SUBSCRIBE) values ('MY','{0}','{1}',1)", enews.Replace("'", "''"), Session("user_id")))
                End If
            Next
        End If
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As System.EventArgs)
        mpeSubscribe.Hide()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<link rel="stylesheet" type="text/css" href="../includes/styles.css" />
<link rel="stylesheet" type="text/css" href="../includes/main.css" />
<link rel="stylesheet" type="text/css" href="../includes/systemselection.css" />
<style type="text/css">
    .Tabs1 .ajax__tab_header
    {
        padding:0px;
        color: #4682b4;
        font-family:Calibri;
        font-size: 15px;
        font-weight:bold;
        background-color: #ffffff;
        margin-left: 0px;
        cursor: pointer;
    }
    /*Body*/
    .Tabs1 .ajax__tab_body
    {
        border:3px solid #f2f2f2;
        padding-top:0px;
    }
    /*Tab Active*/
    .Tabs1 .ajax__tab_active .ajax__tab_tab
    {
        color: #159DD7;
        background:url("../Images/tab-active.jpg") repeat-x;
        padding-top:6px;
    }
    .Tabs1 .ajax__tab_active .ajax__tab_inner
    {
            background:url("../Images/tab-active-left.jpg") no-repeat;
            padding-left:24px;
    }
    .Tabs1 .ajax__tab_active .ajax__tab_outer
    {
            background:url("../Images/tab-active-right.jpg") no-repeat right;
            padding-right:24px;
    }
    /*Tab Hover*/
    .Tabs1 .ajax__tab_hover .ajax__tab_tab
    {
        color: #159DD7;
        background:url("../Images/tab-active.jpg") repeat-x;
        padding-top:6px;
    }
    .Tabs1 .ajax__tab_hover .ajax__tab_inner
    {
        background:url("../Images/tab-active-left.jpg") no-repeat;
            padding-left:24px;
    }
    .Tabs1 .ajax__tab_hover .ajax__tab_outer
    {
        background:url("../Images/tab-active-right.jpg") no-repeat right;
            padding-right:24px;
    }
    /*Tab Inactive*/
    .Tabs1 .ajax__tab_tab
    {
        color: #8B898A;
        background:url("../Images/tab-inactive.jpg") repeat-x;
        padding-top:3px;
        height:23px;
    }
    .Tabs1 .ajax__tab_inner
    {
        background:url("../Images/tab-inactive-left.jpg") no-repeat;
            padding-left:23px;
    }
    .Tabs1 .ajax__tab_outer
    {
        background:url("../Images/tab-inactive-right.jpg") no-repeat right;
            padding-right:23px;
            margin-right: 2px;
    }
    .bluetext {
	    font-family: Arial, Helvetica, sans-serif;
	    color: #3fb2e2;
	    line-height: 1.3em;
    }
    #Corporate {
	    font-size: 125%;
	    padding: 0 14px 5px;
	    margin-top:20px;
	    margin-bottom:5px;
	    border-bottom:#CCC solid 1px;
	    background: url(../images/band_sky1.jpg) no-repeat 0 0;
	    color: #0082d1;
    }
    #MedicalComputing {
	    font-size: 125%;
	    padding: 0 14px 5px;
	    margin-top:15px;
	    margin-bottom:5px;
	    border-bottom:#CCC solid 1px;
	    background: url(../images/band_blue.jpg) no-repeat 0 0;
	    color: #004a84;
    }
    #Networks {
	    font-size: 125%;
	    padding: 0 14px 5px;
	    margin-top:15px;
	    margin-bottom:5px;
	    border-bottom:#CCC solid 1px;
	    background: url(../images/band_sky.jpg) no-repeat 0 0;
	    color: #0082d1;
    }
    #AppliedComputing {
	    font-size: 125%;
	    padding: 0 14px 5px;
	    margin-top:15px;
	    margin-bottom:5px;
	    border-bottom:#CCC solid 1px;
	    background: url(../images/band_orange.jpg) no-repeat 0 0;
	    color: #f98800;
    }
    #EmbeddedBoards {
	    font-size: 125%;
	    padding: 0 14px 5px;
	    margin-top:15px;
	    margin-bottom:5px;
	    border-bottom:#CCC solid 1px;
	    background: url(../images/band_purple.jpg) no-repeat 0 0;
	    color: #5b2b6e;
    }
    #IndustrialAutomation {
	    font-size: 125%;
	    padding: 0 14px 5px;
	    margin-top:15px;
	    margin-bottom:5px;
	    border-bottom:#CCC solid 1px;
	    background: url(../images/band_green.jpg) no-repeat 0 0;
	    color: #008736;
    }
    #DigitalSignage {
	    font-size: 125%;
	    padding: 0 14px 5px;
	    margin-top:15px;
	    margin-bottom:5px;
	    border-bottom:#CCC solid 1px;
	    background: url(../images/band_yellow.jpg) no-repeat 0 0;
	    color: #f7b500;
    }
    #rss-obj {
	    overflow:hidden;
	    padding:6px;
    }
    #rss-obj .des {
	    float:left;
	    padding-top:3px;
	    width:350px;
    }
    #rss-obj .links {
	    float:right;
    }
    .at-maincontainer {
	    background-color:#FFF;
	    line-height: 1.5em;
	    line-height:normal;
	    margin: 0 auto;
	    height:auto;
	    width:890px;
	    color:#666;
    }
    .readon1 {
	    color:#7c1e21;
	    padding-top:7px;
	    background-color: transparent;
	    overflow:visible;
	    background:#e9e9e9;
	    border:1px solid #d7d7d7;
	    vertical-align:middle;
	    text-align:center;
	    display:table-cell;
    }
    #content #title {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 22px;
	    color: #000;
	    font-weight: bold;
    }
    h1 {
	    font-size: 3em;
	    margin: 20px 0;
    }
    .container1 {
	    width: 685px;
    }
    .tab_container {
	    border: 1px solid #CCC;
	    border-top: none;
	    clear: both;
	    float: left;
	    width: 685;
	    background: #fff;
    }
    .tab_content {
	    padding: 0 20px 20px 20px;
    }
    .tab_content h2 {
	    font-weight: normal;
	    padding-bottom: 10px;
	    border-bottom: 1px dashed #CCC;
	    font-size: 1.8em;
    }
    .tab_content h3 a {
	    color: #254588;
    }
    .tab_content img {
	    
    }
    /* MAIN NAVIGATION
    ----------------------------------------------------------- */
    #tabsblock {
	    margin: 0;
	    padding: 0;
	    position: relative;
	    background-color:#F4F4F4;
	    border: 1px solid #CCC;
	    border-bottom:none;
	    width: 685;
    }
    ul.tabs {
	    margin: 0;
	    padding: 10px;
	    list-style: none;
	    overflow:hidden;
    }
    ul.tabs li {
	    float: left;
	    padding: 0 7px 0 0;
	    margin: 0 2px;
	    background: url(../images/tabs-sep.gif) no-repeat right;
    }
    ul.tabs a {
	    display: block;
	    float: left;
	    text-decoration: none;
	    font-weight: bold;
	    color: #4F4F4F;
	    padding: 0 0 0 15px;
	    height: 30px;
	    line-height: 30px;
	    text-transform: uppercase;
	    font-size: 92%;
    }
    ul.tabs a span {
	    display: block;
	    float: left;
	    padding: 0 15px 0 0;
	    height: 30px;
	    line-height: 30px;
    }
    ul.tabs a:hover, ul.tabs a:active, ul.tabs a:focus {
	    background: url(../images/tabs-hover.gif) repeat-x left center;
	    color: #FFFFFF;
    }
    ul.tabs a:hover span, ul.tabs a:active span, ul.tabs a:focus span {
	    background: url(../images/tabs-hover.gif) repeat-x right center;
	    cursor: pointer;
    }
    ul.tabs li.active a, ul.tabs li.active a:hover, ul.tabs li.active a:active, ul.tabs li.active a:focus {
	    background: url(../images/tabs-active.gif) no-repeat left center;
	    color: #FFFFFF;
    }
    ul.tabs li.active a span, ul.tabs li.active a:hover span, ul.tabs li.active a:active span, ul.tabs li.active a:focus span {
	    background: url(../images/tabs-active.gif) no-repeat right center;
	    cursor: pointer;
    }
</style>
<script type="text/javascript" src="../Includes/jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="../Includes/jquery-ui-1.8.16.custom.min.js"></script>
<script type="text/javascript">
    $(document).ready(function () {

        //Default Action
        $(".tab_content").hide(); //Hide all content
        $("ul.tabs li:first").addClass("active").show(); //Activate first tab
        $(".tab_content:first").show(); //Show first tab content

        //On Click Event
        $("ul.tabs li").click(function () {
            $("ul.tabs li").removeClass("active"); //Remove any "active" class
            $(this).addClass("active"); //Add "active" class to selected tab
            $(".tab_content").hide(); //Hide all tab content
            var activeTab = $(this).find("a").attr("href"); //Find the rel attribute value to identify the active tab + content
            $(activeTab).fadeIn(); //Fade in the active content
            return false;
        });

    });
</script>
<!-- MAIN CONTAINER -->
  <!-- CONTENT -->
  <table class="at-maincontainer">
    <tr>
        <td width="685">
            <div id="navtext"><a style="color:Black" href="../home_ga.aspx">Home</a>> My Subscription</div><br />
            <div style="font-size: 22px;color: #000;font-weight: bold;font-family: Arial, Helvetica, sans-serif;">Subscription Services</div>
            <p>Advantech's electronic eNewsletter and RSS feeds provide you the newest information of Advantech, from product news and updates to the latest events. Subscribe to the eNewsletter and RSS feeds to make the first-hand news delivered right to you.</p>
            <div style="border:#CCC solid 1px; background: url(../images/box-btm.gif) repeat-x left bottom;">
              <div style="padding:0 15px;">
                <p><strong>Step 1:</strong><br />
                  Please <a href="../home.aspx" style="color:#3399FF">log in</a> to edit/change your subscription preferences. If you are NOT MyAdvantech members yet, please <a href="https://member.advantech.com/profile.aspx?lang=EN" style="color:#3399FF" target="_blank">register</a>.</p>
                <p><strong>Step 2:</strong><br />
                  Please select one or more of the eNewsletter and RSS feeds below based on your needs .</p>
              </div>
            </div>
            <table><tr><td height="10"></td></tr></table>
            <div class="container1">
                <div id="tabsblock">
                    <ul class="tabs">
                        <li class="active"><a href="#tab1"><span>Subscription</span></a></li>
                        <li class=""><a href="#tab2"><span>RSS</span></a></li>
                    </ul>
                </div>
                <div class="tab_container">
                    <div style="display: block;" id="tab1" class="tab_content">
                        <div style="clear:both"></div>
                        <div class="tab-content">
                            <div id="nl-obj" style="padding:10px">
                                <table>
                                    <tr>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbIndust" /></td>
                                                    <td valign="top"><img src="../images/nl-ia.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Industrial Automation</h4>
                                                        <p>Highlights of the best industrial automation products, as well as details of certified products and integrated solutions for vertical markets.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=ia" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=ia" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbMedical" /></td>
                                                    <td valign="top"><img src="../images/nl-mc.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Medical Computing</h4>
                                                        <p>Features exciting new medical computing platforms and successful application stories covering the Medical Computing domain.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=mc" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=mc" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr><td colspan="2" height="10"></td></tr>
                                    <tr>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbTrans" /></td>
                                                    <td valign="top"><img src="../images/nl-ti.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Transportation Infrastructure</h4>
                                                        <p>Covers transportation and traffic management applications, including road infrastructure, railways and rolling stock, and more.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=tr" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=tr" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbLogistic" /></td>
                                                    <td valign="top"><img src="../images/nl-lc.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Logistics & In-Vehicle Computing</h4>
                                                        <p>Highlights innovative products and integrated system solutions for fleet management, in-vehicle surveillance, warehousing and ports.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=lo" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=lo" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr><td colspan="2" height="10"></td></tr>
                                    <tr>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbDigital" /></td>
                                                    <td valign="top"><img src="../images/nl-ds.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Digital Signage & Self-Service</h4>
                                                        <p>Latest product information about applications in retail and hospitality as well as many other diverse markets.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=ds" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=ds" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbBuilding" /></td>
                                                    <td valign="top"><img src="../images/nl-ba.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Building & Home Automation</h4>
                                                        <p>Latest product information about applications in retail and hospitality as well as many other diverse markets.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=ba" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=ba" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr><td colspan="2" height="10"></td></tr>
                                    <tr>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbEmbed" /></td>
                                                    <td valign="top"><img src="../images/nl-es.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Embedded Boards & Systems</h4>
                                                        <p>Embedded technologies and solutions covering embedded boards, systems and peripheral modules, as well as software services for developers.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=eb" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=eb" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbGaming" /></td>
                                                    <td valign="top"><img src="../images/nl-ga.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Gaming</h4>
                                                        <p>Features innovative gaming platforms, software and peripherals, as well as up-to-date technologies for the gaming industry.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=ga" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=ga" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr><td colspan="2" height="10"></td></tr>
                                    <tr>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbNetwork" /></td>
                                                    <td valign="top"><img src="../images/nl-nt.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Networks & Telecom</h4>
                                                        <p>Focuses on the latest solutions, and product and event information in the field of networks & telecom.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=ne" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=ne" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbSmartEnvironment" /></td>
                                                    <td valign="top"><img src="../images/nl-se.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Industry IoT</h4>
                                                        <p>Vertical-market eNews with latest news collection related to environment monitoring applications.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=se" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=se" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr><td colspan="2" height="10"></td></tr>
                                    <tr>
                                        <%--<td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbEmbedIoT" /></td>
                                                    <td valign="top"><img src="../images/nl-ein.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Embedded IoT News</h4>
                                                        <p>Top news about IoT Trends, Big Data, Embedded Technologies.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=ein" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=ein" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>--%>
                                        <td>
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbIndustry4_0" /></td>
                                                    <td valign="top"><img src="../Images/eNewsClip_Industry4.0.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Industry 4.0</h4>
                                                        <p>Top news about Industry 4.0 trends, up-to-date technologies, and its impact to the world.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=i4" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=i4" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <%--<tr><td colspan="2" height="10"></td></tr>
                                    <tr>
                                        <td valign="top">
                                            <table>
                                                <tr>
                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbIntelligentHostipal" /></td>
                                                    <td valign="top"><img src="../images/nl-nt.jpg" /></td>
                                                    <td valign="top">
                                                        <h4>Intelligent Hospital</h4>
                                                        <p>Latest news, insight, and IoT development in medical sector.</p>
                                                        <table>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?ID=ih" style="color:#3399FF"><span>View recent issue</span></a></td></tr>
                                                            <tr><td><img src="../images/arrowblue.png" /></td><td><a href="../EC/eDMList.aspx?type=all&ID=ih" style="color:#3399FF"><span></span>View all issues</a></td></tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td>

                                        </td>
                                    </tr>--%>
                                    <tr>
                                        <td colspan="2" align="right">
                                            <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:LinkButton runat="server" ID="btnNext" Text="Next" Width="45" Height="22" ForeColor="#666666" CssClass="readon1" OnClick="btnNext_Click" />
                                                    <asp:LinkButton runat="server" ID="linkSubscribe" />
                                                    <ajaxToolkit:ModalPopupExtender runat="server" ID="mpeSubscribe" PopupControlID="PanelSubscribe" 
                                                        TargetControlID="linkSubscribe" BackgroundCssClass="modalBackground" />
                                                    <asp:Panel runat="server" ID="PanelSubscribe" Width="400" Height="600" ScrollBars="Auto">
                                                        <table width="100%" cellpadding="3" style="border-width:1px; border-color:Black; border-style:solid; background-color:White">
                                                            <tr>
                                                                <td width="10"></td>
                                                                <td>
                                                                    <table width="100%">
                                                                        <tr><td height="10"></td></tr>
                                                                        <tr>
                                                                            <td style="border: 2px dotted #AAAAAA">
                                                                                <table>
                                                                                    <tr><th align="left">New <font color="red">Subscribe</font> eNews</th></tr>
                                                                                    <tr><td height="5"></td></tr>
                                                                                    <tr>
                                                                                        <td align="left"><asp:Label runat="server" ID="lblSub" ForeColor="Gray" /></td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                        <tr><td height="15"></td></tr>
                                                                        <tr>
                                                                            <td style="border: 2px dotted #AAAAAA">
                                                                                <table>
                                                                                    <tr><th align="left">New <font color="red">Unsubscribe</font> eNews</th></tr>
                                                                                    <tr><td height="5"></td></tr>
                                                                                    <tr>
                                                                                        <td align="left"><asp:Label runat="server" ID="lblUnsub" ForeColor="Gray" /></td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                        <tr><td height="5"></td></tr>
                                                                        <tr><td align="center"><asp:Button runat="server" ID="btnSubmit" Text="Submit" Width="70" Height="20" OnClick="btnSubmit_Click" /><asp:Button runat="server" ID="btnCancel" Text="Cancel" Width="70" Height="20" OnClick="btnCancel_Click" /></td></tr>
                                                                        <tr><td height="10"></td></tr>
                                                                    </table>
                                                                </td>
                                                                <td width="10"></td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="clear"></div>
                          </div>
                    </div>
                    <div style="display: block;" id="tab2" class="tab_content">
                        <div class="tab-content" style="padding:10px">
                            <h3 style="margin:0">Advantech RSS</h3>
                            <p>Subscribe to Advantech's RSS (Really Simple Syndication) feeds to get news delivered directly to your desktop!</p>
                            <p> To view one of the Advantech feeds in your RSS Aggregator (About RSS Aggregators):</p>
                            <ol>
                              <li>Copy the URL/shortcut that corresponds to the topic that interests you.</li>
                              <li>Paste the URL into your reader.</li>
                            </ol>
                            <p><a href="http://en.wikipedia.org/wiki/RSS" target="_blank">what is RSS?(WikiPedia)</a></p>

                            <div id="Corporate">Corporate</div>
                            <div id="rss-obj">
                                <div class="des"> Corporate News</div>
                                <div class="links"> 
                                    <table>
                                        <tr>
                                            <td><a href="http://feeds2.feedburner.com/AdvantechPressRoom" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2ffeeds2.feedburner.com%2fAdvantechPressRoom" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2ffeeds2.feedburner.com%2fAdvantechPressRoom" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> Case Study</div>
                                <div class="links"> 
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/applicationstory.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fapplicationstory.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fapplicationstory.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="EmbeddedBoards">Embedded Boards & Design-in Services</div>
                            <div id="rss-obj">
                                <div class="des"> Case Study</div>
                                <div class="links"> 
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eplatformapplications.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feplatformapplications.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feplatformapplications.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> News</div>
                                <div class="links"> 
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eplatformnews.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feplatformnews.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feplatformnews.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> White Paper</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eplatformwhitepapers.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feplatformwhitepapers.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feplatformwhitepapers.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
    
                            <div id="IndustrialAutomation">Industrial Automation</div>
                            <div id="rss-obj">
                                <div class="des"> Case Study</div>
                                <div class="links"> 
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eautomationapplications.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feautomationapplications.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feautomationapplications.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> News</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eautomationnews.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feautomationnews.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feautomationnews.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> White Paper</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eautomationwhitepaper.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feautomationwhitepaper.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feautomationwhitepaper.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>    
                                </div>
                            </div>
    
                            <div id="AppliedComputing">Applied Computing & Embedded Systems</div>
                            <div id="rss-obj">
                                <div class="des"> Case Study</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eServiceAppliedComputingapplications.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feServiceAppliedComputingapplications.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feServiceAppliedComputingapplications.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> News</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eserviceappliedcomputingnews.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feserviceappliedcomputingnews.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feserviceappliedcomputingnews.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> White Paper</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/eserviceappliedcomputingwhitepapers.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2feserviceappliedcomputingwhitepapers.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2feserviceappliedcomputingwhitepapers.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
    
                            <div id="MedicalComputing">Medical Computing</div>
                            <div id="rss-obj">
                                <div class="des"> Case Study</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/mc_casestudy.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/mc_casestudy.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/mc_casestudy.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> News</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/mc_news.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/mc_news.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/mc_news.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> White Paper</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/mc_WhitePaper.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/mc_WhitePaper.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/mc_WhitePaper.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
    
                            <div id="Networks">Design & Manufacturing/Networks & Telecom</div>
                            <div id="rss-obj">
                                <div class="des"> Case Study</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/communication-networking-applications.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fcommunication-networking-applications.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fcommunication-networking-applications.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> News</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/communication-networking-news.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fcommunication-networking-news.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fcommunication-networking-news.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> White Paper</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/communication-networking-whitepapers.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fcommunication-networking-whitepapers.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fcommunication-networking-whitepapers.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
    
                            <div id="DigitalSignage">Digital Signage & Self-Service</div>
                            <div id="rss-obj">
                                <div class="des"> Case Study</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/ds_casestudy.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/ds_casestudy.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/ds_casestudy.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> News</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/ds_news.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/ds_news.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/ds_news.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div id="rss-obj">
                                <div class="des"> White Paper</div>
                                <div class="links">
                                    <table>
                                        <tr>
                                            <td><a href="http://www.advantech.com.tw/rss/ds_WhitePaper.aspx" target="_blank"><img src="../images/rss_button.gif"/></a></td>
                                            <td><a href="http://fusion.google.com/add?source=atgs&feedurl=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/ds_WhitePaper.aspx" target="_blank"><img src="../images/addgoogle.gif"/></a></td>
                                            <td><a href="http://us.rd.yahoo.com/my/atm/Advantech/Advantech%20Rss/*http://add.my.yahoo.com/rss?url=http%3a%2f%2fwww.advantech.com.tw%2frss%2fhttp://www.advantech.com.tw/rss/ds_WhitePaper.aspx" target="_blank"><img src="../images/addtomyyahoo4.gif"/> </a></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                          </div>
                        </div>
                    </div>
                </div>
            </div>
        </td>
        <td width="7"></td>
        <td valign="top">
            <uc1:GAContactBlocak runat="server" ID="ucGAContact" />
        </td>
    </tr>
    <tr>
        <td colspan="3"><uc2:GAFooter runat="server" ID="ucGAFooter" /></td>
    </tr>
  </table>
</asp:Content>

