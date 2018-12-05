<%@ Control Language="VB" ClassName="AENC_HomePage" %>
<script runat="server">

    Private _RunTimeURL As String = Util.GetRuntimeSiteUrl
    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)

        '===From PIS===
        'New Product
        Me.BindingNewProductList()
        '===From PIS end===

        '===From CMS===
        'Case Study
        Me.BindingCaseStudy(True)
        'White Paper
        Me.BindingWhitePaper(True)
        'eDM
        Me.BindingEDM()
        'Catalog
        Me.BindingCatalogsBrochures(True)
        
        'Video
        Me.BindingVideo(True)
        
        'Events
        Me.BindingEvents(True)
        '===From CMS end===
        
    End Sub

    
    Private Sub BindingNewProductList()
        
        Dim _dt As DataTable = AENCHomePage.GetNewProductList()
        
        Me.GridView_NewProduct.DataSource = _dt
        Me.GridView_NewProduct.DataBind()
        
        
    End Sub

    Private Sub BindingVideo(ByVal UseBaa As Boolean)
        
        Dim _dt As DataTable = AENCHomePage.GetVideo(UseBaa)
        
        Me.gvVideo.DataSource = _dt
        Me.gvVideo.DataBind()
        
    End Sub
    
    Private Sub BindingCaseStudy(ByVal UseBaa As Boolean)
        
        Dim _dt As DataTable = AENCHomePage.GetCaseStudy(UseBaa)
        
        Me.gvCaseStudy.DataSource = _dt
        Me.gvCaseStudy.DataBind()
        
    End Sub
    
    
    Private Sub BindingWhitePaper(ByVal UseBaa As Boolean)
        
        Dim _dt As DataTable = AENCHomePage.GetWhitePaper(UseBaa)
        
        Me.gvWhitePaper.DataSource = _dt
        Me.gvWhitePaper.DataBind()
        
    End Sub
    
    
    Private Sub BindingEDM()
        
        Dim _dt As DataTable = AENCHomePage.GeteDM()
        
        Me.gveDM.DataSource = _dt
        Me.gveDM.DataBind()
        
    End Sub
    
    
    Private Sub BindingCatalogsBrochures(ByVal UseBaa As Boolean)

        Dim _dt As DataTable = AENCHomePage.GetCatalogsBrochures(UseBaa)
        
        Me.gvCatalogsBrochures.DataSource = _dt
        Me.gvCatalogsBrochures.DataBind()
        
    End Sub
    
    
    Private Sub BindingEvents(ByVal UseBaa As Boolean)
        
        Dim _dt As DataTable = AENCHomePage.GetEvents(UseBaa)
        
        Me.gvEvents.DataSource = _dt
        Me.gvEvents.DataBind()
        
    End Sub
    
    
    Enum RecType
        Video
        News
        WhitePaper
        CaseStudy
    End Enum
    
    Sub hlLoad(Sender As Object, ByVal rtype As RecType)
        Dim hl As HyperLink = CType(Sender, HyperLink), strLitType As Integer = -1
        Select Case rtype
            Case RecType.Video
                strLitType = 18
                If Session("account_status") Is Nothing Then
                    strLitType = 8
                Else
                    If Session("account_status") = "CP" Then strLitType = 15
                    If Session("account_status") = "GA" Then strLitType = 8
                End If
            Case RecType.News
                strLitType = 12
                If Session("account_status") Is Nothing Then
                    strLitType = 4
                Else
                    If Session("account_status") = "CP" Then strLitType = 10
                    If Session("account_status") = "GA" Then strLitType = 3
                End If
            Case RecType.WhitePaper
                strLitType = 19
                If Session("account_status") Is Nothing Then
                    strLitType = 9
                Else
                    If Session("account_status") = "CP" Then strLitType = 17
                    If Session("account_status") = "GA" Then strLitType = 9
                End If
            Case RecType.CaseStudy
                strLitType = 3
                If Session("account_status") Is Nothing Then
                    strLitType = 0
                Else
                    If Session("account_status") = "CP" Then strLitType = 3
                    If Session("account_status") = "GA" Then strLitType = 0
                End If
        End Select
        hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=" + strLitType.ToString()
    End Sub
    
    Protected Sub hlVideo_Load(sender As Object, e As System.EventArgs)
        hlLoad(sender, RecType.Video)
    End Sub
    
    Protected Sub hlNews_Load(sender As Object, e As System.EventArgs)
        hlLoad(sender, RecType.News)
    End Sub
    
    Protected Sub hlCaseStudy_Load(sender As Object, e As System.EventArgs)
        hlLoad(sender, RecType.CaseStudy)
    End Sub
    
    Protected Sub hlWhitePaper_Load(sender As Object, e As System.EventArgs)
        hlLoad(sender, RecType.WhitePaper)
    End Sub
    
</script>
<script type="text/javascript">
    function TracePage(type, lit_type, rid, ID, url) {
        document.getElementById(ID).href = "javascript:void(0)";
        window.open("../Product/MaterialRedirectPage.aspx?Type=" + type + "&C=" + lit_type + "&rid=" + rid + "&url=" + url);
    }
    function GetUrl(ID, url) {
        document.getElementById(ID).href = url;
    }
</script>
<style type="text/css">
    .d
    {
        color: #999;
        font-size: 12px;
    }
    .x_01
    {
        font-size: 12px;
        line-height: 18px;
        color: #0082d1;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_03
    {
        font-size: 12px;
        line-height: 18px;
        color: #ff7800;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_05
    {
        font-size: 12px;
        line-height: 16px;
        color: #666666;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .footertit
    {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 12px;
        line-height: 18px;
        color: #0082d1;
        font-weight: bold;
    }
    .style18
    {
        font-size: 11px;
        line-height: 16px;
        color: #666666;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_04
    {
        font-size: 15px;
        line-height: 18px;
        color: #0d678e;
        font-weight: bold;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .x_06
    {
        font-size: 11px;
        line-height: 14px;
        color: #666666;
        text-align: left;
        font-family: Verdana, Arial, Helvetica, sans-serif;
    }
    .x_07
    {
        font-size: 11px;
        line-height: 14px;
        color: #0082d1;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .pcont
    {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 11px;
        line-height: 14px;
        color: #666666;
    }
    .style3
    {
        font-size: 12px;
        line-height: 14px;
        color: #0082d1;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
    .titlesub
    {
        font-family: Arial, Helvetica, sans-serif;
        font-size: 14px;
        line-height: 18px;
        color: #0082d1;
        font-weight: bold;
    }
    .x_042
    {
        font-size: 15px;
        line-height: 18px;
        color: #FF8C1A;
        font-weight: bold;
        text-align: left;
        font-family: Arial, Helvetica, sans-serif;
    }
</style>
<div align="center">
    <table width="625" cellpadding="0" cellspacing="0">
        <tr>
            <td height="10">
            </td>
        </tr>
        <tr runat="server" id="tr1">
            <td align="left">
                <asp:Hyperlink runat="server" ID="hlBanner" NavigateUrl="http://www.advantech.com/embcore/" ImageUrl="~/Images/AENC_HomePage/Intel-Core-i7-Technology-630x110.jpg" target="_blank" />
            </td>
        </tr>
        <tr>
            <td height="10">
            </td>
        </tr>
    </table>
    <table width="625" cellpadding="0" cellspacing="0" border="0" style="padding: 0px; margin: 0px">
        <tr>
            <td bgcolor="#014C6D">
                <table width="625" cellpadding="0" cellspacing="0" border="0" style="padding: 1px; margin: 1px">
                    <tr>
                        <td>
                            <table width="625" cellpadding="2" bgcolor="#FFFFFF">
                                <tr>
                                    <td valign="bottom">
                                        <div align="right">
                                            <span class="d">Stay Connected</span></div>
                                    </td>
                                    <td width="19">
                                        <div align="left">
                                            <a href="http://www.advantech.com/" target="_blank">
                                                <asp:Image ID="Image5" runat="server" ImageUrl="~/Images/AENC_HomePage/web.jpg" />
                                            </a>
                                        </div>
                                    </td>
                                    <td width="19">
                                        <div align="left">
                                            <a href="https://www.facebook.com/advantechUSA" target="_blank">
                                                <asp:Image ID="Image6" runat="server" ImageUrl="~/Images/AENC_HomePage/fb.jpg" />
                                            </a>
                                        </div>
                                    </td>
                                    <td width="19">
                                        <div align="left">
                                            <a href="http://www.twitter.com/advantech_usa" target="_blank">
                                                <asp:Image ID="Image7" runat="server" ImageUrl="~/Images/AENC_HomePage/twitter.jpg" />
                                            </a>
                                        </div>
                                    </td>
                                    <td width="19" bgcolor="#FFFFFF">
                                        <div align="left">
                                            <a href="http://www.youtube.com/advantechnusa" target="_blank">
                                                <asp:Image ID="Image8" runat="server" ImageUrl="~/Images/AENC_HomePage/yt.jpg" />
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            <table width="625" border="0" align="left" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
                                <tr>
                                    <td align="left" valign="bottom">
                                        <asp:Image ID="Image1" ImageUrl="~/Images/AENC_HomePage/button1.png" runat="server" Width="625" />
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#04496a" height="2" valign="top">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" valign="top">
                                        <table width="100%" bgcolor="#FFFFFF">
                                            <tr>
                                                <td width="100%" height="258" valign="top" class="x_05">
                                                    <asp:GridView runat="server" ID="GridView_NewProduct" Width="100%" EnableTheming="false"
                                                        AutoGenerateColumns="false" ShowHeader="false" BorderWidth="0" CellPadding="0"
                                                        CellSpacing="0" AllowPaging="false" AllowSorting="true" BorderColor="White" PageSize="5"
                                                        PagerSettings-Position="TopAndBottom">
                                                        <Columns>
                                                            <asp:TemplateField HeaderStyle-Width="80%">
                                                                <HeaderTemplate>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <table border="0" cellpadding="2" cellspacing="0" width="100%">
                                                                        <tbody>
                                                                            <tr>
                                                                                <td width="10" valign="middle" class="x_03">
                                                                                    <asp:Image ID="Image9" runat="server" ImageUrl="~/Images/AENC_HomePage/arror1.gif" />
                                                                                </td>
                                                                                <td colspan="2" valign="middle" class="x_01">
                                                                                    <strong>
                                                                                        <%#Eval("PART_NO") %></strong>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td width="10" valign="top">
                                                                                    &nbsp;
                                                                                </td>
                                                                                <td class="x_05" valign="top" width="120">
                                                                                    <img src="http://downloadt.advantech.com/download/downloadlit.aspx?lit_Id=<%#Eval("Main_Image_LiteratureID") %>"
                                                                                        alt="Subway Automatic Fare Collection (AFC) System" style="margin: 0px 10px 0px 0px;"
                                                                                        border="0" height="99" align="left" width="112" />
                                                                                </td>
                                                                                <td class="x_05" valign="middle">
                                                                                    <%#Eval("PRODUCT_DESC")%><span class="x_01">
                                                                                        <asp:Image ID="Image12" runat="server" ImageUrl="~/Images/AENC_HomePage/arror_blue.gif" />
                                                                                        <a href="<%#_RunTimeURL %>/Product/Model_Detail.aspx?model_no=<%#Eval("MODEL_NAME") %>"
                                                                                            class="x_03">More</a> </span>
                                                                                </td>
                                                                            </tr>
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" valign="bottom">
                                        <asp:Image ID="Image2" ImageUrl="~/Images/AENC_HomePage/button2.png" 
                                            runat="server" Width="625" />
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#04496a" height="2" valign="top">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" valign="top">
                                        <table width="625">
                                            <tr>
                                                <td>
                                                    <table width="100%">
                                                        <tr>
                                                            <td width="50%" valign="top">
                                                                <table cellpadding="3" cellspacing="0">
                                                                    <tr>
                                                                        <td valign="top" bgcolor="#CCCCCC" class="titlesub">
                                                                            <div align="left" class="style3">
                                                                                Application Story</div>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top">
                                                                            <%#Eval("PART_NO") %>
                                                                            <asp:GridView runat="server" ID="gvCaseStudy" Width="100%" EnableTheming="false"
                                                                                AutoGenerateColumns="false" ShowHeader="false" BorderWidth="0" CellPadding="0"
                                                                                CellSpacing="0" AllowPaging="true" AllowSorting="true" BorderColor="White" PageSize="2"
                                                                                PagerSettings-Position="TopAndBottom">
                                                                                <Columns>
                                                                                    <asp:TemplateField HeaderStyle-Width="80%">
                                                                                        <HeaderTemplate>
                                                                                        </HeaderTemplate>
                                                                                        <ItemTemplate>
                                                                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td width="6" valign="top" class="pcont">
                                                                                                        <img src="http://advantechusa.com/campaigns/Product_Exclusive/ARK-DS/images/dot01.gif"
                                                                                                            alt="dot" width="3" height="3" vspace="6" />
                                                                                                    </td>
                                                                                                    <td width="537" align="left" class="pcont">
                                                                                                        <a id='<%#Eval("record_id") %>' href='' onmouseover='javascript:GetUrl("<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                            onmousedown='javascript:TracePage("cms","case study","<%#Eval("record_id") %>","<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                            target='_blank'>
                                                                                                            <%#Trim(Eval("title"))%></a>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </ItemTemplate>
                                                                                        <HeaderStyle Width="80%"></HeaderStyle>
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                                <PagerSettings Position="TopAndBottom"></PagerSettings>
                                                                            </asp:GridView>
                                                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                                                <tr>
                                                                                    <td valign="top" class="pcont">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                    <td align="left" valign="top" class="pcont">
                                                                                        <table width="50" align="right">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <span class="x_01">
                                                                                                        <asp:Image ID="Image16" runat="server" ImageUrl="~/Images/AENC_HomePage/arror_blue.gif" />
                                                                                                        <a href="http://my.advantech.com/Product/MaterialSearch.aspx?key=&LitType=3" target="_new"
                                                                                                            class="x_03">More</a></span>
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
                                                            <td width="50%" valign="top">
                                                                <table cellpadding="3" cellspacing="0">
                                                                    <tr>
                                                                        <td valign="top" bgcolor="#CCCCCC" class="titlesub">
                                                                            <div align="left" class="style3">
                                                                                White Papers</div>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top">
                                                                            <%#Eval("PRODUCT_DESC")%>
                                                                            <asp:GridView runat="server" ID="gvWhitePaper" Width="100%" EnableTheming="false"
                                                                                AutoGenerateColumns="false" ShowHeader="false" BorderWidth="0" CellPadding="0"
                                                                                CellSpacing="0" AllowPaging="true" AllowSorting="true" BorderColor="White" PageSize="2"
                                                                                PagerSettings-Position="TopAndBottom">
                                                                                <Columns>
                                                                                    <asp:TemplateField HeaderStyle-Width="80%">
                                                                                        <HeaderTemplate>
                                                                                        </HeaderTemplate>
                                                                                        <ItemTemplate>
                                                                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td width="6" valign="top" class="pcont">
                                                                                                        <img src="http://advantechusa.com/campaigns/Product_Exclusive/ARK-DS/images/dot01.gif"
                                                                                                            alt="dot" width="3" height="3" vspace="6" />
                                                                                                    </td>
                                                                                                    <td width="537" align="left" class="pcont">
                                                                                                        <a id='<%#Eval("record_id") %>' href='' onmouseover='javascript:GetUrl("<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                            onmousedown='javascript:TracePage("cms","white papers","<%#Eval("record_id") %>","<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                            target='_blank'>
                                                                                                            <%#Trim(Eval("title"))%></a>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                            </asp:GridView>
                                                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                                                <tr>
                                                                                    <td valign="top" class="pcont">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                    <td align="left" valign="top" class="pcont">
                                                                                        <table width="50" align="right">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <span class="x_01">
                                                                                                        <asp:Image ID="Image15" runat="server" ImageUrl="~/Images/AENC_HomePage/arror_blue.gif" />
                                                                                                        <a href="http://my.advantech.com/Product/MaterialSearch.aspx?key=&LitType=19" target="_new"
                                                                                                            class="x_03">More</a></span>
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
                                                            <td width="50%" valign="top">
                                                                <table cellpadding="3" cellspacing="0" width="100%">
                                                                    <tr>
                                                                        <td valign="top" bgcolor="#CCCCCC" class="titlesub" width="100%">
                                                                            <div align="left" class="style3">
                                                                                eDM</div>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top">
                                                                            <%#Eval("PART_NO") %>
                                                                            <asp:GridView runat="server" ID="gveDM" Width="100%" EnableTheming="false" AutoGenerateColumns="false"
                                                                                ShowHeader="false" BorderWidth="0" CellPadding="0" CellSpacing="0" AllowPaging="true"
                                                                                AllowSorting="true" BorderColor="White" PageSize="4" PagerSettings-Position="TopAndBottom">
                                                                                <Columns>
                                                                                    <asp:TemplateField HeaderStyle-Width="80%">
                                                                                        <HeaderTemplate>
                                                                                        </HeaderTemplate>
                                                                                        <ItemTemplate>
                                                                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td width="6" valign="top" class="pcont">
                                                                                                        <img src="http://advantechusa.com/campaigns/Product_Exclusive/ARK-DS/images/dot01.gif"
                                                                                                            alt="dot" width="3" height="3" vspace="6" />
                                                                                                    </td>
                                                                                                    <td width="537" align="left" class="pcont">
                                                                                                        <a href='http://my.advantech.com/Includes/GetTemplate.ashx?RowId=<%#Eval("row_id") %>&Email=tc.chen@advantech.com.tw'
                                                                                                            target='_blank'>
                                                                                                            <%# Trim(Eval("email_subject"))%></a>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                            </asp:GridView>
                                                                            <%#Eval("title")%>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td width="50%" valign="top">
                                                                <table cellpadding="3" cellspacing="0">
                                                                    <tr>
                                                                        <td valign="top" bgcolor="#CCCCCC" class="titlesub">
                                                                            <div align="left" class="style3">
                                                                                Catalogs/Brochures</div>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td valign="top">
                                                                            <%#Eval("PRODUCT_DESC")%>
                                                                            <asp:GridView runat="server" ID="gvCatalogsBrochures" Width="100%" EnableTheming="false"
                                                                                AutoGenerateColumns="false" ShowHeader="false" BorderWidth="0" CellPadding="0"
                                                                                CellSpacing="0" AllowPaging="true" AllowSorting="true" BorderColor="White" PageSize="4"
                                                                                PagerSettings-Position="TopAndBottom">
                                                                                <Columns>
                                                                                    <asp:TemplateField HeaderStyle-Width="80%">
                                                                                        <HeaderTemplate>
                                                                                        </HeaderTemplate>
                                                                                        <ItemTemplate>
                                                                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td width="6" valign="top" class="pcont">
                                                                                                        <img src="http://advantechusa.com/campaigns/Product_Exclusive/ARK-DS/images/dot01.gif"
                                                                                                            alt="dot" width="3" height="3" vspace="6" />
                                                                                                    </td>
                                                                                                    <td width="537" align="left" class="pcont">
                                                                                                        <a id='<%#Eval("record_id") %>' href='' onmouseover='javascript:GetUrl("<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                            onmousedown='javascript:TracePage("cms","eCatalog","<%#Eval("record_id") %>","<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                            target='_blank'>
                                                                                                            <%#Trim(Eval("title"))%></a>
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </ItemTemplate>
                                                                                    </asp:TemplateField>
                                                                                </Columns>
                                                                            </asp:GridView>
                                                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                                                <tr>
                                                                                    <td valign="top" class="pcont">
                                                                                        &nbsp;
                                                                                    </td>
                                                                                    <td align="left" class="pcont">
                                                                                        <table width="50" align="right">
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <span class="x_01">
                                                                                                        <asp:Image ID="Image18" runat="server" ImageUrl="~/Images/AENC_HomePage/arror_blue.gif" />
                                                                                                        <a href="http://my.advantech.com/Product/MaterialSearch.aspx?key=&LitType=21" target="_new"
                                                                                                            class="x_03">More</a></span>
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
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" valign="bottom">
                                        <asp:Image ID="Image3" ImageUrl="~/Images/AENC_HomePage/button4.png" 
                                            runat="server" Width="625" />
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#04496a" height="2" valign="top">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" valign="top">
                                        <asp:GridView runat="server" ID="gvVideo" Width="100%" EnableTheming="false" AutoGenerateColumns="false"
                                            ShowHeader="false" BorderWidth="0" CellPadding="0" CellSpacing="0" DataKeyNames="RECORD_ID,CATEGORY_NAME,RECORD_IMG,TITLE"
                                            AllowPaging="true" AllowSorting="true" BorderColor="White" PageSize="1" PagerSettings-Position="TopAndBottom">
                                            <Columns>
                                                <asp:TemplateField SortExpression="title">
                                                    <ItemTemplate>
                                                        <table border="0" cellpadding="2" cellspacing="0" width="100%">
                                                            <tbody>
                                                                <tr>
                                                                    <td width="10" valign="middle" class="x_03">
                                                                        <asp:Image ID="Image20" runat="server" ImageUrl="~/Images/AENC_HomePage/arror1.gif" />
                                                                    </td>
                                                                    <td colspan="2" valign="middle" class="x_01">
                                                                        <strong><a id='<%#Eval("record_id") %>' href='' onmouseover='javascript:GetUrl("<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                            onmousedown='javascript:TracePage("cms","news","<%#Eval("record_id") %>","<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                            target='_blank'>
                                                                            <%#Trim(Eval("title"))%></a></strong>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td width="10" valign="top">
                                                                        &nbsp;
                                                                    </td>
                                                                    <td class="x_05" valign="top" width="120">
                                                                        <asp:HyperLink runat="server" ID="hyVideo1" Target="_blank" Width="143" Height="108">
                                                                                <img width="143" height="108" src='<%#Eval("RECORD_IMG") %>' alt='' /></a>
                                                                        </asp:HyperLink>
                                                                    </td>
                                                                    <td class="x_05" valign="middle">
                                                                        <%#Eval("abstract")%><span class="x_01"><img src="<%#_RunTimeURL %>/images/AENC_HomePage/arror_blue.gif"
                                                                            alt="arr" height="9" width="10" />
                                                                            <a href="http://my.advantech.com/Product/MaterialSearch.aspx?key=&LitType=15" target="_new"
                                                                                class="x_03">More</a></span>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" valign="bottom">
                                        <asp:Image ID="Image4" ImageUrl="~/Images/AENC_HomePage/button3.png" 
                                            runat="server" Width="625" />
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#04496a" height="2" valign="top">
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left" valign="top">
                                        <asp:GridView runat="server" ID="gvEvents" Width="100%" EnableTheming="False" AutoGenerateColumns="False"
                                            BorderWidth="1px" CellPadding="3" AllowPaging="True" AllowSorting="True" BorderColor="#CCCCCC"
                                            PagerSettings-Position="TopAndBottom" BackColor="White" BorderStyle="None">
                                            <Columns>
                                                <asp:TemplateField HeaderText="Event" HeaderStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <a id='<%#Eval("record_id") %>' href='<%#Eval("HYPER_LINK") %>' target='_blank'>
                                                            <%#Trim(Eval("title"))%></a>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="Date" DataField="RELEASE_DATE" HeaderStyle-HorizontalAlign="Center" />
                                                <asp:TemplateField HeaderText="Location" HeaderStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#Eval("CITY")%>,<%#Eval("COUNTRY")%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="Booth Number" DataField="BOOTH" HeaderStyle-HorizontalAlign="Center" />
                                            </Columns>
                                            <FooterStyle BackColor="White" ForeColor="#000066" />
                                            <AlternatingRowStyle BackColor="#E2FEFD" ForeColor="Black" />
                                            <HeaderStyle BackColor="#006699" Font-Bold="True" ForeColor="#FF9900" />
                                            <PagerSettings Position="TopAndBottom"></PagerSettings>
                                            <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                                            <RowStyle ForeColor="#33CCFF" HorizontalAlign="Center" />
                                            <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                                            <SortedAscendingCellStyle BackColor="#F1F1F1" />
                                            <SortedAscendingHeaderStyle BackColor="#007DBB" />
                                            <SortedDescendingCellStyle BackColor="#CAC9C9" />
                                            <SortedDescendingHeaderStyle BackColor="#00547E" />
                                        </asp:GridView>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>
