<%@ Page Title="MyAdvantech - My Download Documents" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="GAContactBlocak" TagPrefix="uc1" Src="~/Includes/GAContactBlock.ascx" %>
<%@ Register TagName="MyViewCategory" TagPrefix="uc2" Src="~/Includes/MyViewCategory.ascx" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select distinct type from MY_VIEWED_LIST where USER_ID='{0}' and page_type='{1}' and type <>'' and type is not null order by type", Session("user_id"), MyLog.PageType.DownloadDocument.ToString))
        Dim count As Integer = 0
        If dt.Rows.Count > 0 Then
            Dim tabs As New Label, tabc As New Label, endtab As New Label
            tabs.Text = "<div id='tabsblock'><ul class='tabs'>"
            For i As Integer = 0 To dt.Rows.Count - 1
                If i = 0 Then
                    tabs.Text += String.Format("<li class='active'><a href='#tab{0}'><span>{1}</span></a></li>", i.ToString, dt.Rows(i).Item(0).ToString)
                Else
                    tabs.Text += String.Format("<li class=''><a href='#tab{0}'><span>{1}</span></a></li>", i.ToString, dt.Rows(i).Item(0).ToString)
                End If
                Dim tabcon1 As New Label, tabcon2 As New Label, tabcon3 As New Label
                tabcon1.Text = String.Format("<div style='display: block;' id='tab{0}' class='tab_content'><h2>{1}</h2>", i.ToString, dt.Rows(i).Item(0).ToString)
                Dim uc As New MyViewCategory
                Dim index As Integer = Array.IndexOf([Enum].GetNames(GetType(MyLog.LiteratureType)), dt.Rows(i).Item(0).ToString)
                If index <> -1 Then
                    uc.LiteratureCategory = index : uc.ShowLit = True
                Else
                    index = Array.IndexOf([Enum].GetNames(GetType(MyLog.TechnicalDocument)), dt.Rows(i).Item(0).ToString)
                    If index <> -1 Then uc.TechnicalCategory = index : uc.ShowTech = True
                End If
                If index <> -1 Then
                    tabcon2.Controls.Add(uc)
                End If
                tabcon3.Text = "</div>"
                With tabc
                    .Controls.Add(tabcon1) : .Controls.Add(tabcon2) : .Controls.Add(tabcon3)
                End With
            Next
            tabs.Text += "</ul></div><div class='tab_container'>"
            endtab.Text = "</div>"
            With div_content
                .Controls.Add(tabs) : .Controls.Add(tabc) : .Controls.Add(endtab)
            End With
        Else
            div_content.Visible = False
        End If
        'For Each row As DataRow In dt.Rows
        '    Dim uc As New MyViewCategory
        '    Dim index As Integer = Array.IndexOf([Enum].GetNames(GetType(MyLog.LiteratureType)), row.Item(0))
        '    If index <> -1 Then
        '        uc.LiteratureCategory = index : uc.ShowLit = True
        '    Else
        '        index = Array.IndexOf([Enum].GetNames(GetType(MyLog.TechnicalDocument)), row.Item(0))
        '        If index <> -1 Then uc.TechnicalCategory = index : uc.ShowTech = True
        '    End If
        '    If index <> -1 Then
        '        Dim tab As New TabPanel
        '        tab.HeaderText = row.Item(0)
        '        tab.Controls.Add(uc)
        '        tab.Visible = True
        '        tabc.Tabs.Add(tab)
        '        If count = 0 Then tabc.ActiveTab = tab : count += 1
        '    End If
        'Next
        
        'Dim lb As New Label, lb1 As New Label, con As New Label, con1 As New Label, con2 As New Label, con3 As New Label
        'lb.Text = "<div id='tabsblock'><ul class='tabs'><li class='active'><a href='#tab1'><span>Video</span></a></li><li class=''><a href='#tab2'><span>News</span></a></li></ul></div><div class='tab_container'>"
        'lb1.Text = "</div>"
        'con1.Text = "<div style='display: block;' id='tab1' class='tab_content'><h2>Video</h2>"
        'Dim uc1 As New MyViewCategory
        'uc1.LiteratureCategory = MyLog.LiteratureType.Photo : uc1.ShowLit = True
        'con2.Controls.Add(uc1)
        'con3.Text = "</div>"
        'con.Controls.Add(con1)
        'con.Controls.Add(con2)
        'con.Controls.Add(con3)
        'div_content.Controls.Add(lb)
        'div_content.Controls.Add(con)
        'div_content.Controls.Add(lb1)
        'tabc.ActiveTab = CType(tabc.FindControl("tabBanner"), TabPanel)
    End Sub
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
            <div id="navtext"><a style="color:Black" href="../home_ga.aspx">Home</a>> My Download Documents</div>
            <div id="content">
                <div id="title">
                    My Download Documents</div>
                <div id="subtitle">
                    Click to see what you have downloaded in Advantech portals.</div>
                <br />
                <div class="container1" runat="server" id="div_content"> </div>
                <%--<div id="menu">
                    <div class="TabbedPanelsContentGroup">
                        <div class="TabbedPanelsContent">
                            <ajaxToolkit:TabContainer runat="server" ID="tabc" CssClass="Tabs1">
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
</asp:Content>

