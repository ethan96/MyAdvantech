<%@ Control Language="VB" ClassName="CustomContent" %>

<script runat="server">
    
    Function GetMyEDM() As DataTable
        'If HttpContext.Current.User.Identity.Name Is Nothing OrElse HttpContext.Current.User.Identity.Name = String.Empty Then Return Nothing
        Dim strSql As String = ""
        If Session("user_id") Is Nothing Then
            strSql = String.Format("select top 4 b.row_id, b.email_subject from CAMPAIGN_MASTER b (nolock) where CAMPAIGN_NAME Like N'%eStore%' and ACTUAL_SEND_DATE is not null and CLICK_CUST>100 and b.IS_PUBLIC=1 order by CREATED_DATE desc")
        Else
            strSql = String.Format( _
            " select top 4 b.row_id, a.contact_email, b.email_subject " + _
            " from campaign_contact_list a (nolock) inner join campaign_master b (nolock) on a.campaign_row_id=b.row_id " + _
            " where a.contact_email='{0}' {1} order by a.email_send_time desc", HttpContext.Current.User.Identity.Name, IIf(Util.IsInternalUser(HttpContext.Current.User.Identity.Name), "", " and b.IS_PUBLIC=1 "))
        End If
        Return dbUtil.dbGetDataTable("MY", strSql)
    End Function
    
    Function GetCustContent(ByVal UseBaa As Boolean) As DataTable
        Dim userBaa As New ArrayList
        If UseBaa Then userBaa = Util.GetUserBaa()
        Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select * from ( ")
            .AppendLine(String.Format(" SELECT distinct top 1 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, replace(a.RECORD_IMG,'http://','https://') as RECORD_IMG, a.HYPER_LINK, "))
            .AppendLine(String.Format(" a.ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, "))
            .AppendLine(String.Format(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, "))
            .AppendLine(String.Format(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME "))
            .AppendLine(String.Format(" FROM WWW_RESOURCES AS a (nolock) "))
            .AppendLine(String.Format(" WHERE a.ABSTRACT<>'' and a.RECORD_IMG<>'' "))
            If Session("lanG") = "KOR" OrElse Session("RBU") = "AKR" Then
                .AppendLine(String.Format(" and a.RBU ='AKR' "))
            ElseIf Session("lanG") = "JAP" OrElse Session("RBU") = "AJP" Then
                .AppendLine(String.Format(" and a.RBU ='AJP' "))
            Else
                .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU','AESC') "))
            End If
            .AppendLine(String.Format(" and a.CATEGORY_NAME='Video'  "))
            If Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            'Frank 2012/11/21
            If Session("account_status") <> "EZ" Then
                .AppendLine(" and a.IS_INTERNAL_ONLY=0 ")
            End If
            .AppendLine(" order by a.RELEASE_DATE desc)  t ")
            .AppendLine(String.Format(" union all "))
            .AppendLine(" select * from ( ")
            .AppendLine(String.Format(" SELECT distinct top 1 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, "))
            .AppendLine(String.Format(" a.ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, "))
            .AppendLine(String.Format(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, "))
            .AppendLine(String.Format(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME "))
            .AppendLine(String.Format(" FROM WWW_RESOURCES AS a (nolock) "))
            .AppendLine(String.Format(" WHERE a.ABSTRACT<>''  "))
            If Session("lanG") = "KOR" OrElse Session("RBU") = "AKR" Then
                .AppendLine(String.Format(" and a.RBU ='AKR' "))
            ElseIf Session("lanG") = "JAP" OrElse Session("RBU") = "AJP" Then
                .AppendLine(String.Format(" and a.RBU ='AJP' "))
            Else
                .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU','AESC') "))
            End If
            .AppendLine(String.Format(" and a.CATEGORY_NAME='News'  "))
            If Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            'Frank 2012/11/21
            If Session("account_status") <> "EZ" Then
                .AppendLine(" and a.IS_INTERNAL_ONLY=0 ")
            End If
            .AppendLine(" order by a.RELEASE_DATE desc)  t1 ")
            .AppendLine(String.Format(" union all "))
            .AppendLine(" select * from ( ")
            .AppendLine(String.Format(" SELECT distinct top 2 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, "))
            .AppendLine(String.Format(" '' as ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, "))
            .AppendLine(String.Format(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, "))
            .AppendLine(String.Format(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME "))
            .AppendLine(String.Format(" FROM WWW_RESOURCES AS a (nolock) "))
            .AppendLine(String.Format(" WHERE a.ABSTRACT<>''  "))
            If Session("lanG") = "KOR" OrElse Session("RBU") = "AKR" Then
                .AppendLine(String.Format(" and a.RBU ='AKR' "))
            ElseIf Session("lanG") = "JAP" OrElse Session("RBU") = "AJP" Then
                .AppendLine(String.Format(" and a.RBU ='AJP' "))
            Else
                .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU','AESC') "))
            End If
            .AppendLine(String.Format(" and a.CATEGORY_NAME='Case Study'  "))
            If Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            'Frank 2012/11/21
            If Session("account_status") <> "EZ" Then
                .AppendLine(" and a.IS_INTERNAL_ONLY=0 ")
            End If
            .AppendLine(" order by a.RELEASE_DATE desc) t2 ")
            .AppendLine(String.Format(" union all "))
            .AppendLine(" select * from ( ")
            .AppendLine(String.Format(" SELECT distinct top 2 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, "))
            .AppendLine(String.Format(" '' as ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, "))
            .AppendLine(String.Format(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, "))
            .AppendLine(String.Format(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME "))
            .AppendLine(String.Format(" FROM WWW_RESOURCES AS a (nolock) "))
            .AppendLine(String.Format(" WHERE a.ABSTRACT<>''  "))
            If Session("lanG") = "KOR" OrElse Session("RBU") = "AKR" Then
                .AppendLine(String.Format(" and a.RBU ='AKR' "))
            ElseIf Session("lanG") = "JAP" OrElse Session("RBU") = "AJP" Then
                .AppendLine(String.Format(" and a.RBU ='AJP' "))
            Else
                .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU','AESC') "))
            End If
            .AppendLine(String.Format(" and a.CATEGORY_NAME='White Papers'  "))
            If Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            'Frank 2012/11/21
            If Session("account_status") <> "EZ" Then
                .AppendLine(" and a.IS_INTERNAL_ONLY=0 ")
            End If
            .AppendLine(" order by a.RELEASE_DATE desc)  t3 ")
        End With
        
        'Andrew 2015/10/7 解決多執行緒時會重複使用同一個索引值對dicCMSSelect寫入的問題
        Dim dicCMSSelect As Dictionary(Of String, DataTable) = If(HttpContext.Current.Cache("CustContent") Is Nothing, New Dictionary(Of String, DataTable)(), HttpContext.Current.Cache("CustContent"))
        Dim strSql As String = sb.ToString()
        
        If (dicCMSSelect.Count = 0) Then
            HttpContext.Current.Cache.Insert("CustContent", dicCMSSelect, Nothing, Now.AddSeconds(12), Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        
        If (Not dicCMSSelect.ContainsKey(strSql)) Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
            dicCMSSelect.CollectionAdd(dt, strSql)
        End If
        
        Return dicCMSSelect(strSql)
        
    End Function
    
    Public Shared Function ShowAbstract(ByVal abstract As String, ByVal rectype As String, ByVal recid As String, ByVal GvRowIdx As Integer) As String
        If rectype.ToLower() = "news" Or rectype.ToLower() = "case study" Then
            Dim aspxpage As String = ""
            Select Case rectype.ToLower()
                Case "news"
                    aspxpage = "News"
                Case "case study"
                    aspxpage = "applications"
            End Select
            Dim URL As String = String.Format("http://www.advantech.com.tw/ePlatform/{0}.aspx?doc_id={1}", aspxpage, recid)
            'Return abstract
        Else
            
        End If
        'abstract = HttpContext.Current.Server.HtmlEncode(abstract)
        abstract = RegularExpressions.Regex.Replace(abstract, "<[^>]*>", String.Empty)
        If abstract.Length > 300 Then abstract = abstract.Substring(0, 300) + String.Format(" <a href='https://resources.advantech.com/Resources/Details.aspx?rid={0}' target='_blank'>...</a>", recid)
        Return abstract
    End Function
    
    Protected Sub LiTs_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Lit As Literal = CType(sender, Literal)
        Dim LiTstr As String = Util.GetLANGLiT_text(Lit.ID.ToString.Trim)
        If LiTstr.ToString.Trim <> "" Then
            Lit.Text = LiTstr
        End If
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Not Page.IsPostBack Then
                e.Row.Cells(0).FindControl("tbContent").Visible = False
                CType(e.Row.Cells(0).FindControl("btnCollapse"), ImageButton).Visible = False
            Else
                'If Session("user_id") <> "" Then
                '    Dim gvC As GridView = CType(e.Row.Cells(0).FindControl("gvComment"), GridView)
                '    Dim record_id As String = gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
                '    Dim ws As New ADVWS.AdvantechWebService
                '    ws.UseDefaultCredentials = True : ws.Timeout = 50000
                '    Dim ds As DataSet = ws.Comment_GetByRecord_ID(record_id)
                '    Dim dt As DataTable = ds.Tables(0)
                '    gvC.DataSource = dt : gvC.DataBind()
                'End If
            End If
            Dim url As String = ""
            If Session("user_id") Is Nothing Then
                url = "https://resources.advantech.com/Resources/Details.aspx?rid=" + gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
                'CType(e.Row.Cells(0).FindControl("hyVideo"), HyperLink).NavigateUrl = "http://resources.advantech.com/Resources/Details.aspx?rid=" + gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
                'CType(e.Row.Cells(0).FindControl("hyVideo1"), HyperLink).NavigateUrl = "http://resources.advantech.com/Resources/Details.aspx?rid=" + gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
            Else
                url = "https://resources.advantech.com.tw/sso/autologin.aspx?tempid=" + Session("TempId") + "&id=" + Session("user_id") + "&pass=MY&callbackupurl=https://resources.advantech.com/Resources/Details.aspx?rid=" + gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
                'CType(e.Row.Cells(0).FindControl("hyVideo"), HyperLink).NavigateUrl = "http://resources.advantech.com.tw/sso/autologin.aspx?tempid=" + Session("TempId") + "&id=" + Session("user_id") + "&pass=MY&callbackupurl=http://resources.advantech.com/Resources/Details.aspx?rid=" + gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
                'CType(e.Row.Cells(0).FindControl("hyVideo1"), HyperLink).NavigateUrl = "http://resources.advantech.com.tw/sso/autologin.aspx?tempid=" + Session("TempId") + "&id=" + Session("user_id") + "&pass=MY&callbackupurl=http://resources.advantech.com/Resources/Details.aspx?rid=" + gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
            End If
            Dim hl As HyperLink = CType(e.Row.Cells(0).FindControl("hyVideo"), HyperLink)
            Dim hl1 As HyperLink = CType(e.Row.Cells(0).FindControl("hyVideo1"), HyperLink)
            hl.Attributes.Add("onmouseover", "javascript:GetUrl(""" + hl.ClientID + """,""" + url + """)")
            hl.Attributes.Add("onmousedown", "javascript:TracePage(""cms"",""video"",""" + gvVideo.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString + """,""" + hl.ClientID + """,""" + url + """)")
            hl1 = hl
        End If
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
                strLitType = 7
                If Session("account_status") Is Nothing Then
                    strLitType = 6
                Else
                    If Session("account_status") = "CP" Then strLitType = 6
                    If Session("account_status") = "GA" Then strLitType = 6
                End If
            Case RecType.News
                strLitType = 4
                If Session("account_status") Is Nothing Then
                    strLitType = 4
                Else
                    If Session("account_status") = "CP" Then strLitType = 4
                    If Session("account_status") = "GA" Then strLitType = 4
                End If
            Case RecType.WhitePaper
                strLitType = 8
                If Session("account_status") Is Nothing Then
                    strLitType = 7
                Else
                    If Session("account_status") = "CP" Then strLitType = 7
                    If Session("account_status") = "GA" Then strLitType = 7
                End If
            Case RecType.CaseStudy
                strLitType = 0
                If Session("account_status") Is Nothing Then
                    strLitType = 0
                Else
                    If Session("account_status") = "CP" Then strLitType = 0
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

    Protected Sub TimerContent_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            Dim cdt As DataTable = GetCustContent(True)
            Dim vidDt As DataTable = cdt.Clone(), newsDt As DataTable = cdt.Clone(), wpaperDt As DataTable = cdt.Clone(), csDt As DataTable = cdt.Clone()
            Dim rTypes() As String = {"Video", "News", "Case Study", "White Papers"}
            Dim rTables() As DataTable = {vidDt, newsDt, wpaperDt, csDt}
            Dim gvResources() As GridView = {gvVideo, gvNews, gvCaseStudy, gvWhitePapers}
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
            
            gvEDM.DataSource = GetMyEDM() : gvEDM.DataBind()
        Catch ex As Exception
            MailUtil.SendDebugMsg("GetCustomContent Error", ex.ToString(), "tc.chen@advantech.com.tw")
        End Try
        TimerContent.Enabled = False : imgLoad.Visible = False : tbContent.Visible = True
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerContent.Enabled = True
        If Session("RBU") IsNot Nothing AndAlso Session("account_status") IsNot Nothing Then
            If Session("RBU") = "AENC" And Session("account_status") = "CP" Then lblAENCDisclaimer.Visible = True
        End If
    End Sub

    Protected Sub hlUpdateProfile_Load(sender As Object, e As System.EventArgs)
        
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
<div class="rightcontant">
    <asp:UpdatePanel runat="server" ID="upContent" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Timer runat="server" ID="TimerContent" Interval="200" OnTick="TimerContent_Tick" />
            <asp:Image runat="server" ID="imgLoad" ImageUrl="~/Images/LoadingRed.gif" AlternateText="Loading Customized Content..." ImageAlign="Middle" />
            <table width="100%" border="0" cellspacing="0" cellpadding="0" runat="server" id="tbContent" visible="false">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td height="20" />
                                <td />
                                <td />
                            </tr>
                            <tr>
                                <td width="3%" />
                                <td width="94%" class="h2">
                                    <asp:Literal ID="LiT5" runat="server" OnLoad="LiTs_Load">Customized Content</asp:Literal>
                                </td>
                                <td width="3%" />
                            </tr>
                            <tr>
                                <td height="5" />
                                <td />
                                <td />
                            </tr>
                            <tr>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    MyAdvantech provides you with customized content based on your personal profile.
                                    If you would like to update your profile so more relevant content is displayed below,
                                    please
                                    <asp:HyperLink runat="server" ID="hlUpdateProfile" Text="click" NavigateUrl="~/My/MyProfile.aspx" OnLoad="hlUpdateProfile_Load" />
                                    here!
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                            <tr><td colspan="3" height="5"></td></tr>
                            <tr><td></td><td><asp:Label runat="server" ID="lblAENCDisclaimer" Text="Please note: all information posted within the MyAdvantech site is Company Confidential data and must be managed under the non-disclosure terms and conditions in your current contract with Advantech.  Any violation of these terms and conditions will be grounds for expulsion from the site and may result in additional Corporate penalties." Font-Italic="true" Visible="false" /></td><td></td></tr>
                            <tr>
                                <td colspan="3" height="20px" />
                            </tr>
                            <tr>
                                <td width="3%" />
                                <td width="94%">
                                    <table width="100%" cellpadding="0" cellspacing="0" style="border-color:White">
                                        <tr valign="top">
                                            <td>
                                                <asp:GridView runat="server" ID="gvVideo" Width="100%" EnableTheming="false" AutoGenerateColumns="false"
                                                    ShowHeader="false" BorderWidth="0" CellPadding="0" CellSpacing="0" DataKeyNames="RECORD_ID,CATEGORY_NAME,RECORD_IMG,TITLE"
                                                    AllowPaging="true" AllowSorting="true" BorderColor="White" PageSize="5" PagerSettings-Position="TopAndBottom"
                                                    OnRowDataBound="gv1_RowDataBound">
                                                    <Columns>
                                                        <asp:TemplateField SortExpression="title">
                                                            <ItemTemplate>
                                                                <table width="100%" style="border-color:White">
                                                                    <tr valign="top">
                                                                        <td colspan="2" align="left" style="width: 15%" class="h3">
                                                                            <%#Eval("category_name")%>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="2">
                                                                            <hr />
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <asp:HyperLink runat="server" ID="hyVideo1" Target="_blank" Width="143" Height="108">
                                                                            <%--<a href="http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackupurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>"
                                                                                target="_blank">--%>
                                                                                <img width="143" height="108" src='<%#Eval("RECORD_IMG") %>' alt='' /></a>
                                                                            </asp:HyperLink>
                                                                        </td>
                                                                        <td>
                                                                            <table width="100%" style="border-color:White">
                                                                                <tr>
                                                                                    <td align="left" class="h4">
                                                                                        <asp:HyperLink runat="server" ID="hyVideo" Text='<%#Eval("TITLE") %>' Target="_blank" />
                                                                                        <%--<a href='http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackupurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                                                                            target='_blank'>
                                                                                            <%#Trim(Eval("title"))%></a>--%>
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td style="height: 60px" valign="top" align="left">
                                                                                        <table cellpadding="0" cellspacing="0" style="border-color:White">
                                                                                            <tr>
                                                                                                <td valign="top">
                                                                                                    <%#ShowAbstract(Eval("abstract"), Eval("category_name"), Eval("record_id"), Container.DataItemIndex)%>
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="2" valign="top" align="left">
                                                                            <table width="100%" border="0" style="border-color:White">
                                                                                <tr>
                                                                                    <td width="7%">
                                                                                        Views:
                                                                                    </td>
                                                                                    <td width="3%">
                                                                                        <%# Eval("CLICKTIME")%>
                                                                                    </td>
                                                                                    <td width="5%">
                                                                                        Date:
                                                                                    </td>
                                                                                    <td width="12%">
                                                                                        <%# CDate(Eval("RELEASE_DATE")).ToString("M/dd/yyyy")%>
                                                                                    </td>
                                                                                    <td width="11%">
                                                                                        Your Rate:
                                                                                    </td>
                                                                                    <td width="15%">
                                                                                    </td>
                                                                                    <td>
                                                                                    </td>
                                                                                    <td align="right">
                                                                                        <asp:HyperLink runat="server" ID="hlVideo" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=17"
                                                                                            ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlVideo_Load" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td colspan="8">
                                                                                    </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="3%">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3" height="20">
                                </td>
                            </tr>
                            <tr>
                                <td width="3%">
                                </td>
                                <td width="94%" class="h3">
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="50%" class="h3">
                                                <asp:Literal ID="LiT6" runat="server" OnLoad="LiTs_Load">News</asp:Literal>
                                            </td>
                                            <td class="h3">
                                                <asp:Literal ID="LiT7" runat="server" OnLoad="LiTs_Load">New eDM</asp:Literal>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="3%">
                                </td>
                            </tr>
                            <tr>
                                <td width="3%">
                                </td>
                                <td width="94%">
                                    <hr />
                                </td>
                                <td width="3%">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3" height="5">
                                </td>
                            </tr>
                            <tr>
                                <td width="3%">
                                    &nbsp;
                                </td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td>
                                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td height="43" valign="top">
                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                <tr>
                                                                    <td width="50%" valign="top">
                                                                        <asp:GridView runat="server" ID="gvNews" EnableTheming="false" AutoGenerateColumns="false"
                                                                            ShowHeader="false" BorderWidth="0" BorderColor="White" Width="100%">
                                                                            <Columns>
                                                                                <asp:TemplateField>
                                                                                    <ItemTemplate>
                                                                                        <table width="90%" border="0" cellspacing="0" cellpadding="0" style="border-color:White">
                                                                                            <tr>
                                                                                                <td width="100%" height="45" valign="top">
                                                                                                    <a id='<%#Eval("record_id") %>' href='' onmouseover='javascript:GetUrl("<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")' onmousedown='javascript:TracePage("cms","news","<%#Eval("record_id") %>","<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                        target='_blank'>
                                                                                                        <%#Trim(Eval("title"))%></a>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td width="100%">
                                                                                                    <%#ShowAbstract(Eval("abstract"), Eval("category_name"), Eval("record_id"), Container.DataItemIndex)%>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td width="100%" align="right">
                                                                                                    <asp:HyperLink runat="server" ID="hlNews" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=4"
                                                                                                        ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlNews_Load" />
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                    </td>
                                                                    <td width="50%" valign="top">
                                                                        <asp:GridView runat="server" ID="gvEDM" EnableTheming="false" AutoGenerateColumns="false"
                                                                            ShowHeader="false" BorderColor="White" BorderWidth="0" Width="100%">
                                                                            <Columns>
                                                                                <asp:TemplateField>
                                                                                    <ItemTemplate>
                                                                                        <table width="90%" border="0" cellspacing="0" cellpadding="0" style="border-color:White">
                                                                                            <tr>
                                                                                                <td width="4%" valign="top">
                                                                                                    <asp:Image runat="server" ID="imgPoint1" ImageUrl="~/images/point.png" Width="7px"
                                                                                                        Height="8px" />
                                                                                                </td>
                                                                                                <td width="96%" valign="top">
                                                                                                    <a href='https://my.advantech.com/Includes/GetTemplate.ashx?RowId=<%#Eval("row_id") %>'
                                                                                                        target='_blank'>
                                                                                                        <%# Trim(Eval("email_subject"))%></a>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>
                                                                                                </td>
                                                                                                <td height="8" style="background-image: url(images/line02.jpg); background-repeat: repeat-x;
                                                                                                    background-position: center">
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
                                                            <a href="#" class="h4"></a>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="3%">
                                    &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3" height="20">
                                </td>
                            </tr>
                            <tr>
                                <td width="3%">
                                </td>
                                <td width="94%" class="h3">
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="50%" class="h3">
                                                <asp:Literal ID="LiT8" runat="server" OnLoad="LiTs_Load">Case Study</asp:Literal>
                                            </td>
                                            <td class="h3">
                                                <asp:Literal ID="LiT9" runat="server" OnLoad="LiTs_Load">White Papers</asp:Literal>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="3%">
                                </td>
                            </tr>
                            <tr>
                                <td width="3%">
                                </td>
                                <td width="94%">
                                    <hr />
                                </td>
                                <td width="3%">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3" height="5">
                                </td>
                            </tr>
                            <tr>
                                <td width="3%">
                                    &nbsp;
                                </td>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td>
                                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td height="43" valign="top">
                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                <tr>
                                                                    <td width="50%" valign="top">
                                                                        <asp:GridView runat="server" ID="gvCaseStudy" EnableTheming="false" Width="100%"
                                                                            AutoGenerateColumns="false" BorderColor="White" BorderWidth="0" ShowHeader="false">
                                                                            <Columns>
                                                                                <asp:TemplateField>
                                                                                    <ItemTemplate>
                                                                                        <table width="90%" border="0" cellspacing="0" cellpadding="0" style="border-color:White">
                                                                                            <tr>
                                                                                                <td width="4%" valign="top">
                                                                                                    <asp:Image runat="server" ID="imgPoint2" ImageUrl="~/images/point.png" Width="7"
                                                                                                        Height="8" />
                                                                                                </td>
                                                                                                <td width="96%" valign="top">
                                                                                                    <a id='<%#Eval("record_id") %>' href='' onmouseover='javascript:GetUrl("<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")' onmousedown='javascript:TracePage("cms","case study","<%#Eval("record_id") %>","<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                        target='_blank'>
                                                                                                        <%#Trim(Eval("title"))%></a>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>
                                                                                                </td>
                                                                                                <td height="8" style="background-image: url(images/line02.jpg); background-repeat: repeat-x;
                                                                                                    background-position: center">
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                        <table width="90%" border="0" cellspacing="0" cellpadding="0" style="border-color:White">
                                                                            <tr>
                                                                                <td>
                                                                                    &nbsp;
                                                                                </td>
                                                                                <td align="right">
                                                                                    <asp:HyperLink runat="server" ID="hlCaseStudy" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=0"
                                                                                        ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlCaseStudy_Load" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td valign="top">
                                                                        <asp:GridView runat="server" ID="gvWhitePapers" EnableTheming="false" AutoGenerateColumns="false"
                                                                            BorderColor="White" BorderWidth="0" ShowHeader="false">
                                                                            <Columns>
                                                                                <asp:TemplateField>
                                                                                    <ItemTemplate>
                                                                                        <table width="90%" border="0" cellspacing="0" cellpadding="0" style="border-color:White">
                                                                                            <tr>
                                                                                                <td width="4%" valign="top">
                                                                                                    <asp:Image runat="server" ID="imgPoint3" ImageUrl="~/images/point.png" Width="7"
                                                                                                        Height="8" />
                                                                                                </td>
                                                                                                <td width="96%" valign="top">
                                                                                                    <a id='<%#Eval("record_id") %>' href='' onmouseover='javascript:GetUrl("<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")' onmousedown='javascript:TracePage("cms","white papers","<%#Eval("record_id") %>","<%#Eval("record_id") %>","http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>")'
                                                                                                        target='_blank'>
                                                                                                        <%#Trim(Eval("title"))%></a>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>
                                                                                                </td>
                                                                                                <td height="8" style="background-image: url(images/line02.jpg); background-repeat: repeat-x;
                                                                                                    background-position: center">
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </ItemTemplate>
                                                                                </asp:TemplateField>
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                        <table width="90%" border="0" cellspacing="0" cellpadding="0" style="border-color:White">
                                                                            <tr>
                                                                                <td>
                                                                                    &nbsp;
                                                                                </td>
                                                                                <td align="right">
                                                                                    <asp:HyperLink runat="server" ID="hlWhitePaper" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=8"
                                                                                        ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlWhitePaper_Load" />
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
                                <td width="3%">
                                    &nbsp;
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>    
</div>