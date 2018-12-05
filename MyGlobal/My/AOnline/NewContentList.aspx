<%@ Page Title="MyAdvantech AOnline Sales Portal - New Content List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register Namespace="eBizAEUControls" TagPrefix="uc1" %>
<%@ Register src="AOnlineFunctionLinks.ascx" tagname="AOnlineFunctionLinks" tagprefix="uc1" %>
<script runat="server">

    'Public Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
    '    If Search_Str <> String.Empty AndAlso Search_Str.Trim <> "" AndAlso Search_Str <> "*" Then
    '        Search_Str = Replace(Search_Str, "*", "{0,}")
    '        Try
    '            Dim RegExp As New Regex(Search_Str.Replace(" ", "|").Trim(), RegexOptions.IgnoreCase)
    '            Return RegExp.Replace(InputTxt, New MatchEvaluator(AddressOf ReplaceKeyWords))
    '            RegExp = Nothing
    '        Catch ex As System.ArgumentException
    '            Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
    '            sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Highlight error for search:" + Search_Str + ". inputTxt:" + InputTxt, ex.ToString())
    '        End Try
    '    End If
    '    Return InputTxt
    'End Function

    Function ShowHideLink(ByVal Url As String) As String
        If String.IsNullOrEmpty(Url) = False Then Return Url
        Return "javascript:void(0);"
    End Function
    
    
    'Public Function ReplaceKeyWords(ByVal m As Match) As String
    '    Return "<span style='background-color:Yellow'>" + m.Value + "</span>"
    'End Function

    
    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    
    


    
    Protected Sub lnkRowShowEditor_Click(sender As Object, e As System.EventArgs)
        'hdSrcApp
       
        Dim lnkBtn As LinkButton = sender
        Dim ed As AjaxControlToolkit.HTMLEditor.Editor = lnkBtn.NamingContainer.FindControl("RowEditor")
        Dim srcType As String = CType(lnkBtn.NamingContainer.FindControl("hdSrcApp"), HiddenField).Value
        Dim srcId As String = CType(lnkBtn.NamingContainer.FindControl("hdSrcID"), HiddenField).Value
        If srcType.Equals("CMS", StringComparison.OrdinalIgnoreCase) Then
            Dim CA As CMSDAL.CMSArticle = Nothing
            If CMSDAL.GetCMSContentByRecordId(srcId, CA) Then
                If rblCHConvertOption.SelectedIndex = 1 Then
                    CA.Abstract = CharSetConverter.ToTraditional(CA.Abstract) : CA.Content = CharSetConverter.ToTraditional(CA.Content)
                ElseIf rblCHConvertOption.SelectedIndex = 2 Then
                    CA.Abstract = CharSetConverter.ToSimplified(CA.Abstract) : CA.Content = CharSetConverter.ToSimplified(CA.Content)
                End If
                ed.Content = _
                    "<table width='100%'>" + _
                    "   <tr><td>" + CA.Abstract + "</td></tr>" + _
                    "   <tr><td>" + CA.Content + "</td></tr>" + _
                    "</table>"
            End If
        End If
        ed.Visible = True : lnkBtn.Visible = False
    End Sub
    
    
    Private Function GetSortColumnIndex(ByVal _SortField As String) As Integer
       
        Dim _ReturnValue As Integer = -1
        
        If String.IsNullOrEmpty(_SortField) Then Return _ReturnValue
        
        For Each _col As DataControlField In gv1.Columns
            If _col.SortExpression = _SortField Then
                Return gv1.Columns.IndexOf(_col)
            End If
        Next
        
        Return _ReturnValue
    End Function
    
    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        
        Select Case e.Row.RowType
            Case DataControlRowType.Header
                
                Dim SortField As String = ViewState("SortField")
                Dim SortDir As SortDirection = ViewState("SortDir")
                Dim SortFieldIndex As Integer = GetSortColumnIndex(SortField)

                If SortFieldIndex > -1 Then
                    If DirectCast(e.Row.Cells(SortFieldIndex).Controls(1), System.Web.UI.WebControls.ImageButton).CommandArgument = SortField Then
                        Select Case SortDir
                            Case SortDirection.Descending
                                DirectCast(e.Row.Cells(SortFieldIndex).Controls(1), System.Web.UI.WebControls.ImageButton).ImageUrl = "~/Images/sort_2.jpg"
                            Case Else
                                DirectCast(e.Row.Cells(SortFieldIndex).Controls(1), System.Web.UI.WebControls.ImageButton).ImageUrl = "~/Images/sort_1.jpg"
                        End Select
                    End If
                End If

                
            Case DataControlRowType.DataRow
                'Dim ed As AjaxControlToolkit.HTMLEditor.Editor = CType(e.Row.FindControl("RowEditor"), AjaxControlToolkit.HTMLEditor.Editor)
                'If ed.Content = String.Empty Then ed.Visible = False
        End Select
        
        
    End Sub

    
    Private issorted As Boolean = False
    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gv1.Sorting


        
        If issorted Then
            e.SortDirection = SortDirection.Descending

            Exit Sub
        End If
        
        issorted = True
        
        Dim pageIndex As Integer = gv1.PageIndex
        Dim SortField As String = e.SortExpression
        Dim SortDir As System.Web.UI.WebControls.SortDirection = e.SortDirection

        If ViewState("SortField") IsNot Nothing Then
            If ViewState("SortField") = SortField Then
                SortDir = (CInt(ViewState("SortDir") + 1) Mod 2).ToString
            Else
                SortDir = SortDirection.Descending
            End If
        Else
            SortDir = SortDirection.Descending
        End If

        Dim _sortColumnIndex As Integer = -1
        
        ViewState("SortField") = SortField
        ViewState("SortDir") = SortDir
        
        Go4It(SortField, SortDir)
        gv1.PageIndex = pageIndex

        'Get Sort Column Index
        
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gv1.PageIndexChanging
        'gv1.PageIndex = e.NewPageIndex : gv1.DataSource = ViewState("boDt") : gv1.DataBind()
        
        gv1.PageIndex = e.NewPageIndex
        Go4It()
        
        
    End Sub

    Protected Sub RadioButtonList1_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        Go4It()
    End Sub

    
    
    Private Sub Go4It(Optional sortfield As String = "", Optional sortdir As SortDirection = SortDirection.Ascending)
        Dim ThreadList As New ArrayList, KSObj As New ArrayList
        Dim _ContentCreateInDayCount As Integer = 7
        '
        Select Case Me.RadioButtonList_ContentCreatedIn.SelectedIndex
            Case 1
                _ContentCreateInDayCount = 30
            Case Else
                _ContentCreateInDayCount = 7
        End Select
        
        
       
        'Query new content of CMS
        Dim ks_CMS As New AOnlineUtil.ContentSearch("", Session.SessionID, "")
        ks_CMS.ContentCreatedIn = _ContentCreateInDayCount
        
        Dim t_CMS As New Threading.Thread(AddressOf ks_CMS.SearchNewCMS) : t_CMS.Start()
        ThreadList.Add(t_CMS) : KSObj.Add(ks_CMS)
        '==================

        'Query new content of eDM
        Dim ks_eDM As New AOnlineUtil.ContentSearch("", Session.SessionID, "")
        ks_eDM.ContentCreatedIn = _ContentCreateInDayCount
        
        Dim t_eDM As New Threading.Thread(AddressOf ks_eDM.SearchNewEDM) : t_eDM.Start()
        ThreadList.Add(t_eDM) : KSObj.Add(ks_eDM)
        '==================

        
        'Query new content of PIS
        Dim ks_PIS As New AOnlineUtil.ContentSearch("", Session.SessionID, "")
        ks_PIS.ContentCreatedIn = _ContentCreateInDayCount
        
        Dim t_PIS As New Threading.Thread(AddressOf ks_PIS.SearchNewMKTLit) : t_PIS.Start()
        ThreadList.Add(t_PIS) : KSObj.Add(ks_PIS)
        '==================
        
        For Each _thread As Threading.Thread In ThreadList
            _thread.Join()
        Next

        
        Dim dt As New DataTable
        For Each ksItem As AOnlineUtil.ContentSearch In KSObj
            If ksItem.SearchFlg Then
                dt.Merge(ksItem.ResultDt)
                'If rblCHConvertOption.SelectedIndex = 1 Then
                '    For Each ContentRow As DataRow In dt.Rows
                '        ContentRow.Item("NAME") = CharSetConverter.ToTraditional(ContentRow.Item("NAME"))
                '        ContentRow.Item("CONTENT_TEXT") = CharSetConverter.ToTraditional(ContentRow.Item("CONTENT_TEXT"))
                '    Next
                'ElseIf rblCHConvertOption.SelectedIndex = 2 Then
                '    For Each ContentRow As DataRow In dt.Rows
                '        ContentRow.Item("NAME") = CharSetConverter.ToSimplified(ContentRow.Item("NAME"))
                '        ContentRow.Item("CONTENT_TEXT") = CharSetConverter.ToSimplified(ContentRow.Item("CONTENT_TEXT"))
                '    Next
                'End If
                'Dim bk2 As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
                'bk2.DestinationTableName = "KM_SEARCH_TMP_DETAIL"
                'bk2.WriteToServer(dt)
            Else
                'lbMsg.Text += "|" + ks.strErrMsg
            End If
        Next

        Dim _isgetdatafromview As Boolean = False
        
        If Not String.IsNullOrEmpty(Me._ContentType) Then
            dt.DefaultView.RowFilter = "SOURCE_TYPE='" & Me._ContentType & "'"
            _isgetdatafromview = True
        End If
        
        If Not String.IsNullOrEmpty(sortfield) Then
            'dt.DefaultView.Sort = "SOURCE_TYPE='" & Me._ContentType & "'"

            Dim SortTxt As String = String.Empty
            SortTxt = sortfield
            If sortdir = SortDirection.Descending Then
                SortTxt += " DESC"
            End If
            dt.DefaultView.Sort = SortTxt
            _isgetdatafromview = True
           
        End If
        
        If _isgetdatafromview Then dt = dt.DefaultView.ToTable
        
        Me.gv1.DataSource = dt
        Me.gv1.DataBind()
    End Sub
    
    
    Dim _ContentType As String = String.Empty
    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        
        _ContentType = Request.Params("ContentType")
        
        If Not Page.IsPostBack Then
            
            'buttonCheck.Attributes.CssStyle("visibility") = "hidden"
            'tvPISCat.Attributes.Add("onclick", String.Format("document.getElementById('{0}').click();", buttonCheck.ClientID))
            Me.srcMyContents.SelectParameters("SEID").DefaultValue = Session.SessionID
            If AOnlineUtil.AOnlineSalesCampaign.MyContentCartCount() > 0 Then
                PanelAddedContents.Visible = True
            Else
                PanelAddedContents.Visible = False
            End If
            If MailUtil.IsInRole("EMPLOYEE.ABJ") OrElse MailUtil.IsInRole("ATWCallCenter") _
                OrElse MailUtil.IsInRole("DIRECTOR.ACL") OrElse MailUtil.IsInRole("ITD.ACL") Then
                trChsCht.Visible = True
            End If
            If rblCHConvertOption.SelectedIndex = 1 Then
                hyContentFwd.HRef = "ContentForward.aspx?ToCHT=y"
            ElseIf rblCHConvertOption.SelectedIndex = 2 Then
                hyContentFwd.HRef = "ContentForward.aspx?ToCHS=y"
            End If
            
            'Query Data
            Go4It()
        End If
    End Sub

    
    Protected Sub lnkRowAddContent_Click(sender As Object, e As System.EventArgs)
        Dim lnk As Button = sender
        Dim srcId As String = CType(lnk.NamingContainer.FindControl("hdSrcID"), HiddenField).Value
        Dim srcTitle As String = CType(lnk.NamingContainer.FindControl("hdSrcTitle"), HiddenField).Value
        Dim srcApp As String = CType(lnk.NamingContainer.FindControl("hdSrcApp"), HiddenField).Value
        Dim srcURL As String = CType(lnk.NamingContainer.FindControl("hdSrcOriUrl"), HiddenField).Value
        AOnlineUtil.AOnlineSalesCampaign.AddContentToMyContentCart(srcId, srcTitle, srcApp, srcURL)
        
        gvMyContents.DataBind()
        
        lnk.Text = "Added to My Content" 'lnk.Enabled = False
        'If gvMyContents.Rows.Count > 0 Then PanelAddedContents.Visible = True
    End Sub

    
    Protected Sub gvMyContents_DataBound(sender As Object, e As System.EventArgs)
        If AOnlineUtil.AOnlineSalesCampaign.MyContentCartCount() > 0 Then
            PanelAddedContents.Visible = True
        Else
            PanelAddedContents.Visible = False
        End If
    End Sub

    Protected Sub gvMyContents_RowDeleted(sender As Object, e As System.Web.UI.WebControls.GridViewDeletedEventArgs)
        If AOnlineUtil.AOnlineSalesCampaign.MyContentCartCount() > 0 Then
            PanelAddedContents.Visible = True
        Else
            PanelAddedContents.Visible = False
        End If
    End Sub

    Protected Sub RowEditor_PreRender(sender As Object, e As System.EventArgs)
        'Dim ed As AjaxControlToolkit.HTMLEditor.Editor = sender
        'Dim lnkBtn As LinkButton = ed.NamingContainer.FindControl("lnkRowShowEditor")
        'If ed.Content = String.Empty Then
        '    ed.Visible = False : lnkBtn.Visible = False
        'End If
       
    End Sub

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr align="right">
            <td align="right">
                <uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" />
            </td>
        </tr>
    </table>
    <h2 style="color: Navy">
        New Content List</h2>
    <br />
    <table>
        <tr>
            <td>
                <asp:HyperLink ID="HyperLink5" runat="server" NavigateUrl="NewContentList.aspx?ContentType="
                    Text="All" />
            </td>
            <td>
                |
            </td>
            <td>
                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="NewContentList.aspx?ContentType=EDM"
                    Text="eDM" />
            </td>
            <td>
                |
            </td>
            <td>
                <asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl="NewContentList.aspx?ContentType=Case Study"
                    Text="Case Study" />
            </td>
            <td>
                |
            </td>
            <td>
                <asp:HyperLink ID="HyperLink3" runat="server" NavigateUrl="NewContentList.aspx?ContentType=White Paper"
                    Text="White Paper" />
            </td>
            <td>
                |
            </td>
            <td>
                <asp:HyperLink ID="HyperLink4" runat="server" NavigateUrl="NewContentList.aspx?ContentType=News"
                    Text="News" />
            </td>
            <td>
                |
            </td>
            <td>
                <asp:HyperLink ID="HyperLink6" runat="server" NavigateUrl="NewContentList.aspx?ContentType=Curated Content"
                    Text="Curated Content" />
            </td>
        </tr>
    </table>
    <table>
        <tr runat="server" id="trChsCht" visible="false">
            <th align="left">
                简繁中转换/簡繁中轉換
            </th>
            <td>
                <asp:RadioButtonList runat="server" ID="rblCHConvertOption" RepeatColumns="3" RepeatDirection="Horizontal">
                    <asp:ListItem Text="不转换/不轉換" Selected="True" />
                    <asp:ListItem Text="簡轉繁" />
                    <asp:ListItem Text="繁转简" />
                </asp:RadioButtonList>
            </td>
            <th align="left">
                Content created in
            </th>
            <td>
                <asp:RadioButtonList runat="server" ID="RadioButtonList_ContentCreatedIn" RepeatColumns="2" 
                    RepeatDirection="Horizontal" 
                    onselectedindexchanged="RadioButtonList1_SelectedIndexChanged" 
                    AutoPostBack="True">
                    <asp:ListItem Text="Last 7 Days" Selected="True" />
                    <asp:ListItem Text="Last 1 Month" />
                </asp:RadioButtonList>
            </td>
        </tr>
    </table>
    <table width="100%">
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" Width="100%" AllowPaging="true" AllowSorting="true"
                            OnRowCreated="gvRowCreated" PageSize="10" PagerSettings-Position="TopAndBottom"
                            AutoGenerateColumns="false" EmptyDataText="" PagerSettings-PageButtonCount="20"
                            OnRowDataBound="gv1_RowDataBound" OnSorting="gv1_Sorting">
                            <Columns>
                                <asp:BoundField HeaderText="Source" DataField="SOURCE_APP" SortExpression="SOURCE_APP"
                                    HeaderStyle-Width="10%" ItemStyle-HorizontalAlign="Center" />
                                <asp:BoundField HeaderText="Type" DataField="SOURCE_TYPE" SortExpression="SOURCE_TYPE"
                                    HeaderStyle-Width="10%" ItemStyle-HorizontalAlign="Center" />
                                <asp:TemplateField HeaderText="Content" HeaderStyle-Width="80%">
                                    <ItemTemplate>
                                        <asp:HiddenField runat="server" ID="hdSrcApp" Value='<%#Eval("SOURCE_APP") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcID" Value='<%#Eval("SOURCE_ID") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcType" Value='<%#Eval("SOURCE_TYPE") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcTitle" Value='<%#Eval("NAME") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcOriUrl" Value='<%#Eval("URL") %>' />
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <a href='<%#ShowHideLink(Eval("URL")) %>' target="_blank">
                                                        <%# Eval("NAME")%>
                                                        <%'# Highlight(Eval("NAME"), Eval("NAME"))%></a>
                                                </td>
                                                <td align="right" style="display: none">
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" style="font-size: small">
                                                    <i>Last updated on
                                                        <%#CDate(Eval("LAST_UPD_DATE")).ToString("yyyy/MM/dd")%></i>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <asp:Button runat="server" ID="lnkRowAddContent" Text="Add to My Content" OnClick="lnkRowAddContent_Click" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <asp:UpdatePanel runat="server" ID="upRowEditor" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:LinkButton runat="server" ID="lnkRowShowEditor" Text="Show Content" OnClick="lnkRowShowEditor_Click" />
                                                            <uc1:NoToolBarEditor2 runat="server" ID="RowEditor" Visible="false" Content='<%# Eval("CONTENT_TEXT")%>'
                                                                Width="750px" Height="120px" ActiveMode="Preview" OnPreRender="RowEditor_PreRender" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender2" runat="server"
                            TargetControlID="PanelAddedContents" HorizontalSide="Right" VerticalSide="Bottom"
                            HorizontalOffset="200" VerticalOffset="60" />
                        <asp:Panel runat="server" ID="PanelAddedContents" Visible="false" BackColor="Azure">
                            <table width="100%" style="border-style: double">
                                <tr>
                                    <th align="left">
                                        My Contents
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="PanelACInside" Width="220px" Height="100px" ScrollBars="Auto">
                                            <table width="100%">
                                                <tr>
                                                    <td colspan="1">
                                                        <asp:GridView runat="server" ID="gvMyContents" DataSourceID="srcMyContents" OnDataBound="gvMyContents_DataBound"
                                                            AutoGenerateColumns="false" ShowHeader="false" DataKeyNames="SESSIONID,SOURCE_ID"
                                                            OnRowDeleted="gvMyContents_RowDeleted">
                                                            <Columns>
                                                                <asp:TemplateField ItemStyle-Width="99%">
                                                                    <ItemTemplate>
                                                                        <table>
                                                                            <tr>
                                                                                <td>
                                                                                    <div style="overflow: auto">
                                                                                        <a target="_blank" href='<%#Eval("ORIGINAL_URL") %>'>
                                                                                            <%#Eval("CONTENT_TITLE")%></a>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:LinkButton Font-Size="XX-Small" ID="LinkButton1" runat="server" CommandName="Delete"
                                                                                        Text="Delete" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                        <asp:SqlDataSource runat="server" ID="srcMyContents" ConnectionString="<%$ConnectionStrings:MyLocal_New %>"
                                                            SelectCommand="SELECT TOP 100 SESSIONID, SOURCE_ID, CONTENT_TITLE, SOURCE_APP, ORIGINAL_URL
                                                                        FROM AONLINE_SALES_CONTENT_CART where SESSIONID=@SEID order by ADDED_DATE desc"
                                                            DeleteCommand="delete from AONLINE_SALES_CONTENT_CART where SESSIONID=@SESSIONID and SOURCE_ID=@SOURCE_ID">
                                                            <SelectParameters>
                                                                <asp:Parameter ConvertEmptyStringToNull="false" Name="SEID" />
                                                            </SelectParameters>
                                                        </asp:SqlDataSource>
                                                    </td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <a style="font-size: x-small" href="ContentForward.aspx" runat="server" id="hyContentFwd">
                                                        Forward Content</a>
                                                </td>
                                                <td>
                                                    |
                                                </td>
                                                <td>
                                                    <a style="font-size: x-small" href="ContactMining.aspx">Search Contact</a>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>
