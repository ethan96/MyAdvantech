<%@ Page Title="MyAdvantech - My Viewed Materials" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="GAContactBlocak" TagPrefix="uc1" Src="~/Includes/GAContactBlock.ascx" %>
<%@ Register TagName="MyViewCategory" TagPrefix="uc2" Src="~/Includes/MyViewCategory.ascx" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            Select Case LCase(Request("C"))
                'Case LCase(MyLog.CMSCategory.Video.ToString)
                '    tabc.ActiveTab = tabVideo
                'Case LCase(MyLog.CMSCategory.News.ToString)
                '    tabc.ActiveTab = tabNews
                'Case LCase(MyLog.CMSCategory.eDM.ToString)
                '    tabc.ActiveTab = tabeDM
                'Case LCase(MyLog.CMSCategory.CaseStudy.ToString)
                '    tabc.ActiveTab = tabCaseStudy
                'Case LCase(MyLog.CMSCategory.WhitePaper.ToString)
                '    tabc.ActiveTab = tabWhitePaper
            End Select
        End If
    End Sub
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetNewsContent(ByVal recid As String, ByVal Type As String) As String
        Try
            Return Util.GetCMSContent(recid, Type)
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Error GetWWWNews", "recid:" + recid + "<br/>" + ex.ToString, False, "", "")
        End Try
        Return "Content currently not available"
    End Function
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
    #content {
	    height: auto;
	    width: 690px;
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    line-height: 1.5em;
	    float: left;
	    margin-top: 10px;
    }
    #content #product {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    margin-top: 10px;
	    height: 300px;
	    width: 690px;
    }
    .bluetitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 15px;
	    font-weight: bold;
	    color: #3fb2e2;
    }
    #content #title {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 22px;
	    color: #000;
	    font-weight: bold;
    }
    #content #subtitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    margin-top: 10px;
    }
    #rightmenu {
	    float: left;
	    height: auto;
	    width: 195px;
	    margin-left: 5px;
	    margin-top: 10px;
    }
    #rightmenu #hline {
	    background-image: url(images/line1.jpg);
	    background-repeat: no-repeat;
	    height: 5px;
    }
    #rightmenu #contact {
	    height: auto;
	    width: 190px;
	    margin-bottom: 10px;
    }
    #content #MedicalComputing {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #004a84;
	    background-image: url(images/band_blue.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #Networks {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #0082d1;
	    background-image: url(images/band_sky.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #AppliedComputing {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #f98800;
	    background-image: url(images/band_orange.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #EmbeddedBoards {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #5b2b6e;
	    background-image: url(images/band_purple.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #IndustrialAutomation {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #008736;
	    background-image: url(images/band_green.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #DigitalSignage {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #f7b500;
	    background-image: url(images/band_yellow.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
    }
    #content #product #product1 {
	    float: left;
	    height: 270px;
	    width: 220px;
	    margin-right: 10px;
    }
    #content #product #more {
	    float: left;
	    height: 30px;
	    width: 70px;
	    padding-left: 620px;
	    border-bottom-width: thin;
	    border-bottom-style: solid;
	    border-bottom-color: #CCC;
	    padding-top: 10px;
	    margin-bottom: 10px;
    }
    #rightmenu #ecatalog {
	    float: left;
	    height: auto;
	    width: 195px;
	    margin-top: 5px;
    }
    #rightmenu #ecatalog table tr td .bg {
	    background-image: url(images/ecatalog_bg.jpg);
	    background-repeat: repeat-y;
    }
    #content #productset {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    float: left;
	    height: auto;
	    width: 690px;
	    margin-top: 10px;
    }
    .producttitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 16px;
	    font-weight: bold;
	    color: #3fb2e2;
	    line-height: 2em;
    }
    .price {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 14px;
	    font-weight: bold;
	    color: #fb6717;
	    line-height: 2em;
    }
    #content #menu {
	    float: left;
	    height: auto;
	    width: 690px;
	    margin-top: 10px;
    }
    .tabletext {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    font-weight: normal;
    }
    .subtitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 16px;
	    font-weight: bold;
    }
    .bluetext {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 14px;
	    font-weight: bold;
	    color: #3fb2e2;
	    line-height: 1.3em;
    }
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
	    width: 100%;
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
	    margin: 0 20px 20px 0;
	    border: 1px solid #ddd;
	    padding: 5px;
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
	    width: 100%;
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
        //$("ul.tabs li:first").addClass("active").show(); //Activate first tab
        //$(".tab_content:first").show(); //Show first tab content
        var queryString = window.top.location.search.substring(1);
        var para = getParameter(queryString, "C");
        switch (para) {
            case "News":
                document.getElementById("li2").setAttribute("class", "active");
                document.getElementById("li1").removeAttribute("class");
                document.getElementById("tab2").style.display = "block";
                break;
            case "eDM":
                document.getElementById("li3").setAttribute("class", "active");
                document.getElementById("li1").removeAttribute("class");
                document.getElementById("tab3").style.display = "block";
                break;
            case "CaseStudy":
                document.getElementById("li4").setAttribute("class", "active");
                document.getElementById("li1").removeAttribute("class");
                document.getElementById("tab4").style.display = "block";
                break;
            case "WhitePaper":
                document.getElementById("li5").setAttribute("class", "active");
                document.getElementById("li1").removeAttribute("class");
                document.getElementById("tab5").style.display = "block";
                break;
            default:
                $("ul.tabs li:first").addClass("active").show();
                $(".tab_content:first").show();
        }

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
    function getParameter(queryString, parameterName) {
        var parameterName = parameterName + "=";
        if (queryString.length > 0) {
            begin = queryString.indexOf(parameterName);
            if (begin != -1) {
                begin += parameterName.length;
                end = queryString.indexOf("&", begin);
                if (end == -1) {
                    end = queryString.length
                }
                return unescape(queryString.substring(begin, end));
            }
            return "null";
        }
    } 
    function MM_preloadImages() { //v3.0
        var d = document; if (d.images) {
            if (!d.MM_p) d.MM_p = new Array();
            var i, j = d.MM_p.length, a = MM_preloadImages.arguments; for (i = 0; i < a.length; i++)
                if (a[i].indexOf("#") != 0) { d.MM_p[j] = new Image; d.MM_p[j++].src = a[i]; }
        }
    }
</script>
<script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script>
<script src="http://platform.twitter.com/widgets.js" type="text/javascript"></script>
    <table>
        <tr>
            <td valign="top">
                <div id="navtext"><a style="color:Black" href="../home_ga.aspx">Home</a>> My Viewed Documents</div>
                <div id="content">
                    <div id="title">
                        My Viewed Materials</div>
                    <div id="subtitle">
                        Click to see what you have seen in Advantech portals.</div>
                        <br />
                    <div class="container1"> 
                        <!-- MAIN TABS -->
                        <div id="tabsblock">
                            <ul class="tabs">
                                <li class="active" id="li1"><a href="#tab1"><span>Video</span></a></li>
                                <li class="" id="li2"><a href="#tab2"><span>News</span></a></li>
                                <li class="" id="li3"><a href="#tab3"><span>eDM</span></a></li>
                                <li class="" id="li4"><a href="#tab4"><span>Case Study</span></a></li>
                                <li class="" id="li5"><a href="#tab5"><span>White Paper</span></a></li>
                                <li class="" id="li6"><a href="#tab6"><span>eCatalog</span></a></li>
                            </ul>
                        </div>
                        <div class="tab_container"> 
                            <div style="display: block;" id="tab1" class="tab_content">
                                <h2>Video</h2>
                                <uc2:MyViewCategory runat="server" ID="ucMyVideo" CMSCategory="Video" ShowCMS="true" />
                            </div>
                            <div style="display: block;" id="tab2" class="tab_content">
                                <h2>News</h2>
                                <uc2:MyViewCategory runat="server" ID="ucMyNews" CMSCategory="News" ShowCMS="true" />
                            </div>
                            <div style="display: block;" id="tab3" class="tab_content">
                                <h2>eDM</h2>
                                <uc2:MyViewCategory runat="server" ID="uceDM" CMSCategory="eDM" ShowCMS="true" />
                            </div>
                            <div style="display: block;" id="tab4" class="tab_content">
                                <h2>Case Study</h2>
                                <uc2:MyViewCategory runat="server" ID="ucMyCaseStudy" CMSCategory="CaseStudy" ShowCMS="true" />
                            </div>
                            <div style="display: block;" id="tab5" class="tab_content">
                                <h2>White Paper</h2>
                                <uc2:MyViewCategory runat="server" ID="ucMyWhitePaper" CMSCategory="WhitePaper" ShowCMS="true" />
                            </div>
                            <div style="display: block;" id="tab6" class="tab_content">
                                <h2>eCatalog</h2>
                                <uc2:MyViewCategory runat="server" ID="ucMyeCatalog" CMSCategory="eCatalog" ShowCMS="true" />
                            </div>
                        </div>
                    </div>
                    <%--<div id="menu">
                        <div class="TabbedPanelsContentGroup">
                            <div class="TabbedPanelsContent">
                                <ajaxToolkit:TabContainer runat="server" ID="tabc" CssClass="Tabs1">
                                    <ajaxToolkit:TabPanel runat="server" ID="tabVideo" HeaderText="Video">
                                        <ContentTemplate>
                                            <uc2:MyViewCategory runat="server" ID="ucMyVideo" CMSCategory="Video" ShowCMS="true" />
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                    <ajaxToolkit:TabPanel runat="server" ID="tabNews" HeaderText="News">
                                        <ContentTemplate>
                                            <uc2:MyViewCategory runat="server" ID="ucMyNews" CMSCategory="News" ShowCMS="true" />
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                    <ajaxToolkit:TabPanel runat="server" ID="tabeDM" HeaderText="eDM">
                                        <ContentTemplate>
                                            <uc2:MyViewCategory runat="server" ID="uceDM" CMSCategory="eDM" ShowCMS="true" />
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                    <ajaxToolkit:TabPanel runat="server" ID="tabCaseStudy" HeaderText="Case Study">
                                        <ContentTemplate>
                                            <uc2:MyViewCategory runat="server" ID="ucMyCaseStudy" CMSCategory="CaseStudy" ShowCMS="true" />
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                    <ajaxToolkit:TabPanel runat="server" ID="tabWhitePaper" HeaderText="White Paper">
                                        <ContentTemplate>
                                            <uc2:MyViewCategory runat="server" ID="ucMyWhitePaper" CMSCategory="WhitePaper" ShowCMS="true" />
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                    <ajaxToolkit:TabPanel runat="server" ID="tabeCatalog" HeaderText="eCatalog">
                                        <ContentTemplate>
                                            <uc2:MyViewCategory runat="server" ID="ucMyeCatalog" CMSCategory="eCatalog" ShowCMS="true" />
                                        </ContentTemplate>
                                    </ajaxToolkit:TabPanel>
                                </ajaxToolkit:TabContainer>
                                
                            </div>
                        </div>
                    </div>--%>
                </div>
            </td>
            <td valign="top">
                <uc1:GAContactBlocak runat="server" ID="ucGAContactBlock" />
            </td>
        </tr>
    </table>
    
    <script type="text/javascript">
        function GetNews(nodeid, recid, cattype) {
            document.getElementById(nodeid).innerHTML = "<img src='/Images/loading2.gif' alt='Loading News...' width='35' height='35' />Loading...";
            PageMethods.GetNewsContent(recid, cattype,
                function (pagedResult, eleid, methodName) {
                    document.getElementById(nodeid).innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    //alert(error.get_message());
                    //document.getElementById('div_myrecentitems').innerHTML="";
                });
        }
    </script>
</asp:Content>

