<%@ Page Title="MyAdvantech - eDM List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Public Enum Lang
        English
        TraditionalChinese
        SimplifiedChinese
        Japanese
        Korean
    End Enum
    
    Public Function GetCategoryId() As ArrayList
        Dim arrItem As ArrayList
        Select Case LCase(Request("ID"))
            Case "ia"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.IndustrialAutomation)
                lblHeader.Text = "Industrial Automation"
            Case "mc"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.MedicalComputing)
                lblHeader.Text = "Medical Computing"
            Case "tr"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.Transportation)
                lblHeader.Text = "Transportation Infrastructure"
            Case "lo"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.Logistics)
                lblHeader.Text = "Logistics & In-Vehicle Computing"
            Case "ds"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.DigitalSignage)
                lblHeader.Text = "Digital Signage & Self-Service"
            Case "ba"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.BuildingAutomation)
                lblHeader.Text = "Building & HomeAutomation"
            Case "eb"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.EmbeddedBoards)
                lblHeader.Text = "Embedded Boards & Systems"
            Case "ga"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.Gaming)
                lblHeader.Text = "Gaming"
            Case "ne"
                arrItem = MyLog.GetEDMSolutionMapping(MyLog.eDMCategory.Networks)
                lblHeader.Text = "Networks & Telecom"
            Case Else
                arrItem = Nothing
        End Select
        lblHeadermin.Text = lblHeader.Text
        Return arrItem
    End Function
    
    Public Function GetIoTNews() As List(Of String)
        Dim arrItem As New List(Of String)
        Select Case LCase(Request("ID"))
            Case "i4"
                arrItem.Add("'eNews Clips – Industry 4.0'")
                lblHeader.Text = "Industry 4.0"
            Case "se"
                arrItem.Add("'eNews Clips – Industry IoT'")
                lblHeader.Text = "Industry IoT"
            Case "ein"
                arrItem.Add("' IoTMart eNews (Embedded)'")
                lblHeader.Text = "Embedded IoT News"
            Case "ih"
                arrItem.Add("'IoTMart eNews (Intelligent Hospital)'")
                lblHeader.Text = "Intelligent Hospital"
            Case Else
                arrItem = Nothing
        End Select
        lblHeadermin.Text = lblHeader.Text
        Return arrItem
    End Function
    
    Public Function GetSQL() As String
        Dim arrItem As ArrayList = GetCategoryId()
        Dim IoTList As List(Of String) = GetIoTNews()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct {0} a.row_id, a.description, a.actual_send_date, a.email_subject as title, '../Includes/GetThumbnail.ashx?RowId='+a.row_id as img_url ", IIf(LCase(Request("type")) = "all", "", " top 1 "))
            .AppendFormat(" from campaign_master a left join campaign_cms_solution b on a.row_id=b.campaign_row_id ")
            If Not LCase(Request("type")) = "all" Then .AppendFormat(" left join campaign_contact_list c on a.row_id=c.campaign_row_id ")
            .AppendFormat(" where a.is_public=1 and a.actual_send_date is not null and a.created_by <> 'ADVANTECH\Rudy.Wang' ")
            'If Not LCase(Request("type")) = "all" Then .AppendFormat(" and c.email_issent=1 and c.contact_email = '{0}' ", HttpContext.Current.Session("user_id"))
            If (arrItem IsNot Nothing AndAlso arrItem.Count > 0) OrElse (IoTList IsNot Nothing AndAlso IoTList.Count > 0) Then
                If arrItem IsNot Nothing AndAlso arrItem.Count > 0 Then .AppendFormat(" and b.category_id in ({0}) ", String.Join(",", arrItem.ToArray()))
                If IoTList IsNot Nothing AndAlso IoTList.Count > 0 Then .AppendFormat(" and a.ENEWS in ({0}) ", String.Join(",", IoTList.ToArray()))
                If hdnRBU.Value <> "" Then
                    Select Case hdnRBU.Value.ToUpper
                        Case "ABJ", "ACD", "ACN", "ACN-E", "ACN-N", "ACN-S", "ACQ", "AFZ", "AGZ", "AHZ", "ASH", "ASY", "ASZ", "AWH", "AXA", "AHK"
                            .AppendFormat(" and (a.region in ('ABJ','ACD','ACN','ACN-E','ACN-N','ACN-S','ACQ','AFZ','AGZ','AHZ','ASH','ASY','ASZ','AWH','AXA','AHK')) ")
                        Case "ADL", "AIT", "AFR", "AEE", "ABN", "AUK", "AINNOCORE", "AMEA-MEDICAL", "AEU"
                            .AppendFormat(" and (a.region in ('{0}','AEU')) ", hdnRBU.Value)
                        Case "USA", "AAC", "AENC", "ANADMF", "AIC"
                            .AppendFormat(" and (a.region in ('AAC','AENC','ANADMF')) ")
                        Case "ATH"
                            .AppendFormat(" and (a.region in ('ATH','ASG','SAP')) ", hdnRBU.Value)
                        Case Else
                            .AppendFormat(" and (a.region = '{0}') ", hdnRBU.Value)
                    End Select
                End If
                'Select Case ddlLang.SelectedValue
                '    Case Lang.TraditionalChinese.ToString
                '        .AppendFormat(" and a.region = 'ATW' ")
                '    Case Lang.SimplifiedChinese.ToString
                '        .AppendFormat(" and a.region in ('ABJ','ACD','ACN','ACN-E','ACN-N','ACN-S','ACQ','AFZ','AGZ','AHZ','ASH','ASY','ASZ','AWH','AXA','AHK') ")
                '    Case Lang.Japanese.ToString
                '        .AppendFormat(" and a.region = 'AJP' ")
                '    Case Lang.Korean.ToString
                '        .AppendFormat(" and a.region = 'AKR' ")
                '    Case Else
                '        .AppendFormat(" and a.region not in ('ATW','AJP','AKR','ABJ','ACD','ACN','ACN-E','ACN-N','ACN-S','ACQ','AFZ','AGZ','AHZ','ASH','ASY','ASZ','AWH','AXA','AHK') ")
                'End Select
                'If (IsRegional = True OrElse hdnRegion.Value = "0") AndAlso hdnRBU.Value <> "" Then
                '    Select Case hdnRBU.Value.ToUpper
                '        Case "ADL", "AIT", "AFR", "AEE", "ABN", "AUK", "AINNOCORE", "AMEA-MEDICAL", "AEU"
                '            .AppendFormat(" and a.region in ('{0}','AEU') ", hdnRBU.Value)
                '        Case "USA"
                '            .AppendFormat(" and a.region in ('AAC','AENC','ANADMF') ")
                '        Case "ABJ", "ACD", "ACN", "ACN-E", "ACN-N", "ACN-S", "ACQ", "AFZ", "AGZ", "AHZ", "ASH", "ASY", "ASZ", "AWH", "AXA", "AHK"
                '            .AppendFormat(" and a.region in ('ABJ','ACD','ACN','ACN-E','ACN-N','ACN-S','ACQ','AFZ','AGZ','AHZ','ASH','ASY','ASZ','AWH','AXA','AHK') ")
                '        Case Else
                '            .AppendFormat(" and a.region = '{0}' ", hdnRBU.Value)
                '    End Select
                'ElseIf hdnRBU.Value = "" Then
                '    .AppendFormat(" and 1 <> 1 ")
                'End If
            Else
                .AppendFormat(" and 1<>1 ")
            End If
            
            .AppendFormat(" order by a.actual_send_date desc")
        End With
        Return sb.ToString
    End Function
    
    Protected Sub sql1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        sql1.SelectCommand = GetSQL()
    End Sub
    
    Public Sub PageIndexChanged(ByVal PageIndex As String)
        gv1.PageIndex = CInt(PageIndex) - 1
    End Sub

    Protected Sub btnP1_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP2_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP3_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP4_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP5_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP6_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP7_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub gv1_DataBound(sender As Object, e As System.EventArgs)
        Try
            If gv1.Rows.Count = 0 Then hdnRBU.Value = "ACL" : up1.Update() : Exit Sub ': sql1.SelectCommand = GetSQL() 'gv1.DataBind() : 
            If gv1.BottomPagerRow IsNot Nothing Then
                
                Dim quotient As Integer = Math.DivRem(gv1.PageIndex, 7, 0)
                For i As Integer = 0 To 6
                    CType(gv1.BottomPagerRow.FindControl("btnP" + (i + 1).ToString), LinkButton).Text = (quotient * 7) + i + 1
                Next
                Dim PageIndex As Integer = 0
                Math.DivRem(gv1.PageIndex, 7, PageIndex)
                If CInt(CType(gv1.BottomPagerRow.FindControl("btnP1"), LinkButton).Text) + 7 > gv1.PageCount Then
                    Dim MaxPageIndex As Integer = 0
                    Math.DivRem(gv1.PageCount, 7, MaxPageIndex)
                    For i As Integer = MaxPageIndex To 6
                        CType(gv1.BottomPagerRow.FindControl("btnP" + (i + 1).ToString), LinkButton).Visible = False
                    Next
                End If
                Dim btn As LinkButton = CType(gv1.BottomPagerRow.FindControl("btnP" + (PageIndex + 1).ToString), LinkButton)
                btn.ForeColor = Drawing.Color.Black : btn.Font.Bold = True
                If gv1.PageIndex >= 7 Then CType(gv1.BottomPagerRow.FindControl("btnPre"), LinkButton).Visible = True
            End If
        Catch ex As Exception

        End Try
    End Sub

    Protected Sub btnNext_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged((gv1.PageIndex + 7 + 1).ToString)
    End Sub

    Protected Sub btnPre_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged((gv1.PageIndex - 7 + 1).ToString)
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'If Not Request.IsAuthenticated Or Session("user_id") Is Nothing Then Response.Redirect("../home.aspx?ReturnUrl=%2fEC%2feDMList.aspx") : Exit Sub
        If Not Page.IsPostBack Then
            'Dim arrItem As ArrayList = GetCategoryId()
            'Dim sb As New StringBuilder
            'With sb
            '    .AppendFormat(" select distinct a.region ")
            '    .AppendFormat(" from campaign_master a left join campaign_cms_solution b on a.row_id=b.campaign_row_id ")
            '    .AppendFormat(" where a.is_public=1 and a.actual_send_date is not null ")
            '    If arrItem IsNot Nothing AndAlso arrItem.Count > 0 Then
            '        .AppendFormat(" and b.category_id in ({0}) ", String.Join(",", arrItem.ToArray()))
            '        .AppendFormat(" and a.region in ('ATW','AJP','AKR','ABJ','ACD','ACN','ACN-E','ACN-N','ACN-S','ACQ','AFZ','AGZ','AHZ','ASH','ASY','ASZ','AWH','AXA','AHK') ")
            '    Else
            '        .AppendFormat(" and 1<>1 ")
            '    End If
            'End With
            'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString)
            'If dt.Rows.Count > 0 Then
            '    If dt.Select("region='ATW'").Count = 0 Then ddlLang.Items.Remove(Lang.TraditionalChinese.ToString)
            '    If dt.Select("region='AJP'").Count = 0 Then ddlLang.Items.Remove(Lang.Japanese.ToString)
            '    If dt.Select("region='AKR'").Count = 0 Then ddlLang.Items.Remove(Lang.Korean.ToString)
            '    If dt.Select("region <> 'ATW' and region <> 'AJP' and region <> 'AKR'").Count = 0 Then ddlLang.Items.Remove(Lang.SimplifiedChinese.ToString)
            'Else
            '    ddlLang.Items.Clear() : ddlLang.Items.Add(New ListItem(Lang.English.ToString, Lang.English.ToString))
            'End If

            'Get user RBU and country
            Dim na As String = ""
            If HttpContext.Current.Session("user_id") Is Nothing Then
                na = Util.IP2Nation()
            Else
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(b.country,'') as country from SIEBEL_CONTACT a left join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID where a.EMAIL_ADDRESS='{0}' and b.country <> '' and b.country is not null", HttpContext.Current.Session("user_id")))
                If obj IsNot Nothing Then
                    na = obj.ToString
                Else
                    na = Util.IP2Nation()
                End If
            End If
            
            GetRBUbyCountry(na)
            
            'Select Case hdnRBU.Value.ToUpper
            '    Case "ATW", "ACL"
            '        If ddlLang.Items.FindByValue(Lang.TraditionalChinese.ToString) IsNot Nothing Then ddlLang.Items.FindByValue(Lang.TraditionalChinese.ToString).Selected = True
            '    Case "AJP"
            '        If ddlLang.Items.FindByValue(Lang.Japanese.ToString) IsNot Nothing Then ddlLang.Items.FindByValue(Lang.Japanese.ToString).Selected = True
            '    Case "AKR"
            '        If ddlLang.Items.FindByValue(Lang.Korean.ToString) IsNot Nothing Then ddlLang.Items.FindByValue(Lang.Korean.ToString).Selected = True
            '    Case "ABJ", "ACD", "ACN", "ACN-E", "ACN-N", "ACN-S", "ACQ", "AFZ", "AGZ", "AHZ", "ASH", "ASY", "ASZ", "AWH", "AXA", "AHK"
            '        If ddlLang.Items.FindByValue(Lang.SimplifiedChinese.ToString) IsNot Nothing Then ddlLang.Items.FindByValue(Lang.SimplifiedChinese.ToString).Selected = True
            '    Case Else
            '        ddlLang.Items(0).Selected = True
            'End Select
        End If
    End Sub

    'Protected Sub ddlLang_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
    '    Select Case hdnRBU.Value.ToUpper
    '        Case "ATW", "ACL"
    '            If ddlLang.Items.FindByValue(Lang.TraditionalChinese.ToString) IsNot Nothing AndAlso ddlLang.Items.FindByValue(Lang.TraditionalChinese.ToString).Selected = False Then
    '                btnAll_Click(btnAll, e) : upRegion.Update()
    '            End If
    '        Case "AJP"
    '            If ddlLang.Items.FindByValue(Lang.Japanese.ToString) IsNot Nothing AndAlso ddlLang.Items.FindByValue(Lang.Japanese.ToString).Selected = False Then
    '                btnAll_Click(btnAll, e) : upRegion.Update()
    '            End If
    '        Case "AKR"
    '            If ddlLang.Items.FindByValue(Lang.Korean.ToString) IsNot Nothing AndAlso ddlLang.Items.FindByValue(Lang.Korean.ToString).Selected = False Then
    '                btnAll_Click(btnAll, e) : upRegion.Update()
    '            End If
    '        Case "ABJ", "ACD", "ACN", "ACN-E", "ACN-N", "ACN-S", "ACQ", "AFZ", "AGZ", "AHZ", "ASH", "ASY", "ASZ", "AWH", "AXA", "AHK"
    '            If ddlLang.Items.FindByValue(Lang.SimplifiedChinese.ToString) IsNot Nothing AndAlso ddlLang.Items.FindByValue(Lang.SimplifiedChinese.ToString).Selected = False Then
    '                btnAll_Click(btnAll, e) : upRegion.Update()
    '            End If
    '        Case Else
    '            If ddlLang.Items.FindByValue(Lang.English.ToString) IsNot Nothing AndAlso ddlLang.Items.FindByValue(Lang.English.ToString).Selected = False Then
    '                btnAll_Click(btnAll, e) : upRegion.Update()
    '            End If
    '    End Select
    '    gv1.DataBind()
    '    up1.Update()
    'End Sub

    'Protected Sub btnRegion_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    btnRegion.Font.Bold = True : btnAll.Font.Bold = False : hdnRegion.Value = "0" : sql1.SelectCommand = GetSQL(True)
    'End Sub

    'Protected Sub btnAll_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    btnAll.Font.Bold = True : btnRegion.Font.Bold = False : hdnRegion.Value = "1" : sql1.SelectCommand = GetSQL(False)
    'End Sub

    Protected Sub ddlCountry_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        If ddlCountry.Items.FindByValue(hdnCountry.Value) IsNot Nothing Then ddlCountry.Items.FindByValue(hdnCountry.Value).Selected = True
    End Sub

    Protected Sub ddlCountry_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        GetRBUbyCountry(ddlCountry.SelectedValue)
        sql1.SelectCommand = GetSQL()
        gv1.DataBind() : up1.Update()
    End Sub
    
    Sub GetRBUbyCountry(ByVal na As String)
        Dim rbu As Object = dbUtil.dbExecuteScalar("MY", String.Format("select rbu, count(rbu) as num from SIEBEL_ACCOUNT where COUNTRY='{0}' and rbu<>'' group by RBU ORDER by COUNT(rbu) desc", na))
        If rbu IsNot Nothing Then
            hdnRBU.Value = rbu.ToString : hdnCountry.Value = na
        Else
            Dim advws As New ADVWWW.AdvantechWebService
            advws.UseDefaultCredentials = True : advws.Timeout = 5000
            Dim ds As New DataSet
            Try
                ds = advws.getRBUInfoByCountryBU(na, "eP")
            Catch ex As System.Exception
                Try
                    ds = advws.getRBUInfoByCountryBU(na, "eP")
                Catch ex1 As System.Exception
                    hdnCountry.Value = "" : hdnRBU.Value = ""
                End Try
            End Try

            If ds.Tables.Count > 0 Then
                If ds.Tables(0).Rows.Count > 0 Then
                    hdnCountry.Value = ds.Tables(0).Rows(0).Item("country").ToString : hdnRBU.Value = ds.Tables(0).Rows(0).Item("RBU").ToString
                Else
                    hdnCountry.Value = "" : hdnRBU.Value = ""
                End If
            Else
                hdnCountry.Value = "" : hdnRBU.Value = ""
            End If
            
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
    .PageButton 
    {
        color:#0032D0;
        border-width:1px;
        border-color:#CFCFCF;
        border-style:solid;
        background-color:#F7F7F7;
        font-style:normal;
        text-align:center;
        vertical-align:middle;
        display:table-cell;
        width:21px;
        height:25px;
    }
    .bluetext {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 14px;
	    font-weight: bold;
	    color: #3fb2e2;
	    line-height: 1.3em;
    }
</style>
    <table width="100%" border="0" cellpadding="10" cellspacing="0">
        <tr>
            <td>
                <div id="navtext"><a style="color:Black" href="../home_ga.aspx">Home</a> > <a style="color:Black" href="../My/MySubscriptionRSS.aspx">My Subscription</a> > <asp:Label runat="server" ID="lblHeadermin" /></div><br />
                <div style="font-size: 22px;color: #000;font-weight: bold;font-family: Arial, Helvetica, sans-serif;"><asp:Label runat="server" ID="lblHeader" /></div>
                <%--<div>
                    <asp:UpdatePanel runat="server" ID="upRegion" UpdateMode="Conditional">
                        <ContentTemplate>
                            <table>
                                <tr><td><asp:LinkButton runat="server" ID="btnRegion" Text="Regional eDM" Font-Bold="true" OnClick="btnRegion_Click" /></td>
                                    <td> | </td>
                                    <td><asp:LinkButton runat="server" ID="btnAll" Text="All eDMs" OnClick="btnAll_Click" /></td>
                                </tr>
                            </table>
                            <asp:HiddenField runat="server" ID="hdnRegion" Value="0" />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>--%>
            </td>
            <td align="right" valign="top">
                <asp:UpdatePanel runat="server" ID="upLang" UpdateMode="Conditional">
                    <ContentTemplate>
                        <%--Language: 
                        <asp:DropDownList runat="server" ID="ddlLang" AutoPostBack="true" OnSelectedIndexChanged="ddlLang_SelectedIndexChanged">
                            <asp:ListItem Text="English" Value="English" />
                            <asp:ListItem Text="Traditional Chinese" Value="TraditionalChinese" />
                            <asp:ListItem Text="Simplified Chinese" Value="SimplifiedChinese" />
                            <asp:ListItem Text="Japanese" Value="Japanese" />
                            <asp:ListItem Text="Korean" Value="Korean" />
                        </asp:DropDownList>--%>
                        Country:
                        <asp:DropDownList runat="server" ID="ddlCountry" AutoPostBack="true" DataSourceID="sqlCountry" DataTextField="text" DataValueField="value" OnPreRender="ddlCountry_PreRender" OnSelectedIndexChanged="ddlCountry_SelectedIndexChanged"></asp:DropDownList>
                        <asp:SqlDataSource runat="server" ID="sqlCountry" ConnectionString="<%$ connectionStrings: MY %>"
                            SelectCommand="select * from siebel_account_country_lov"></asp:SqlDataSource>
                        <asp:HiddenField runat="server" ID="hdnRBU" /><asp:HiddenField runat="server" ID="hdnCountry" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:GridView runat="server" ID="gv1" EnableTheming="false" ShowHeader="false" ShowFooter="false" BorderWidth="0" BorderColor="White" RowStyle-Width="0" AutoGenerateColumns="false" 
                PageSize="10" AllowPaging="true" DataSourceID="sql1" OnDataBound="gv1_DataBound" CellPadding="10">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <table width="650" border="0" align="center" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="21%" rowspan="2">
                                        <a href='../Includes/GetTemplate.ashx?RowId=<%#Eval("row_id") %>' target="_blank">
                                            <asp:Image runat="server" ID="imgSmall" ImageUrl='<%#Eval("img_url") %>' width="121" />
                                        </a>
                                    </td>
                                    <td width="79%" class="bluetext">
                                        <a href='../Includes/GetTemplate.ashx?RowId=<%#Eval("row_id") %>' target="_blank">
                                            <asp:Label runat="server" ID="lblTitle" Text='<%#Eval("title") %>' />
                                        </a>
                                    </td>
                                </tr>
                                <tr>
                                    <td valign="top">
                                        <asp:Label runat="server" ID="lblDesc" Text='<%#Eval("description") %>' />
                                    </td>
                                </tr>
                                <tr><td height="5"></td></tr>
                            </table>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerTemplate>
                    <table width="100%">
                        <tr>
                            <td align="center">
                                <table>
                                    <tr>
                                        <td width="30">&nbsp;</td>
                                        <td><asp:LinkButton runat="server" ID="btnPre" cssClass="blue" Text="Previous Page" OnClick="btnPre_Click" Visible="false" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnP1" CssClass="PageButton" OnClick="btnP1_Click" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnP2" CssClass="PageButton" OnClick="btnP2_Click" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnP3" CssClass="PageButton" OnClick="btnP3_Click" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnP4" CssClass="PageButton" OnClick="btnP4_Click" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnP5" CssClass="PageButton" OnClick="btnP5_Click" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnP6" CssClass="PageButton" OnClick="btnP6_Click" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnP7" CssClass="PageButton" OnClick="btnP7_Click" /></td>
                                        <td><asp:LinkButton runat="server" ID="btnNext" cssClass="blue" Text="Next Page" OnClick="btnNext_Click" /></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </PagerTemplate>
                <PagerStyle BorderWidth="0" BorderColor="White" />
                <RowStyle BorderColor="White" BorderWidth="0" />
            </asp:GridView>
            <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings: MY %>"
                SelectCommand="" OnLoad="sql1_Load">
            </asp:SqlDataSource>
        </ContentTemplate>
        <Triggers>
            <%--<asp:AsyncPostBackTrigger ControlID="btnRegion" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnAll" EventName="Click" />--%>
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>

