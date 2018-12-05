<%@ Page Title="MyAdvantech - AOnline Content Search" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    ValidateRequest="false" EnableEventValidation="false" %>

<%@ Register Namespace="eBizAEUControls" TagPrefix="uc1" %>
<%@ Register src="AOnlineFunctionLinks.ascx" tagname="AOnlineFunctionLinks" tagprefix="uc1" %>
<script runat="server">   
    
    Protected Sub Sort_Command(ByVal sender As Object, ByVal e As CommandEventArgs)
        If e.CommandName = "SortData" Then
            
            
            Dim obj As ImageButton = TryCast(sender, ImageButton)
            Dim _SortField As String = ViewState("SortField")
            
            If String.IsNullOrEmpty(_SortField) Then
                _SortField = "RANK_VALUE"
            End If
            
            'e.CommandArgument = _SortField
            
            'Select Case e.CommandArgument.ToString.ToUpper
            
            Dim _pageindex As Integer = Me.gv1.PageIndex
            
            '~/Images/sort_1.jpg
            Select Case obj.ImageUrl
                'Frank 2012/04/16:
                Case "~/Images/Aonline_icon_down1.jpg"
                    'Me.gv1.Sort("LAST_UPD_DATE", SortDirection.Ascending)
                    Me.gv1.Sort(_SortField, SortDirection.Ascending)
                
                Case "~/Images/Aonline_icon_up1.jpg"
                    'Me.gv1.Sort("LAST_UPD_DATE", SortDirection.Descending)
                    Me.gv1.Sort(_SortField, SortDirection.Descending)
            
            End Select
            Me.gv1.PageIndex = _pageindex
            'Dim _linkImageAsc As Image = TryCast(Me.FindControl("Image_LastUpdDate_SortImage_asc"), ImageButton)
            'Dim _linkImageDesc As Image = TryCast(Me.FindControl("Image_LastUpdDate_SortImage_desc"), ImageButton)

            
            'If Me.gv1.SortDirection = SortDirection.Ascending Then
            '    _linkImageAsc.ImageUrl = "~/Images/sort_2.jpg"
            '    _linkImageDesc.ImageUrl = "~/Images/sort_1_disable.jpg"

            '    '_linkImageAesc.Visible = True
            '    '_linkImageDesc.Visible = False
            'Else
            '    _linkImageAsc.ImageUrl = "~/Images/sort_2_disable.jpg"
            '    _linkImageDesc.ImageUrl = "~/Images/sort_1.jpg"
            '    '_linkImageAesc.Visible = False
            '    '_linkImageDesc.Visible = True
            'End If

            
            
            'Me.gv1.Sort("LAST_UPD_DATE", SortDirection.Descending)
            
        End If
    End Sub
    
    
    
    'Dim ShowPreviewLitTypes() As String = {"eDM", "1-1 eLetter", "News", "Case Study"}
    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    
                    'Frank 2012/04/13. Use TryCast is better
                    'Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    ' Dim _Btn_SortBy_LASTUPDDATE As LinkButton = TryCast(cell.FindControl("btn_SortBy_LASTUPDDATE"), LinkButton)
                    
                    Dim _dlSortingField As DropDownList = TryCast(cell.FindControl("dlSortingField"), DropDownList)
                        
                    
                    If _dlSortingField IsNot Nothing Then

                        Dim _selectindex As Integer = 0
                        Try
                            _selectindex = Integer.Parse(ViewState("SortFieldIndex"))
                        Catch ex As Exception
                        End Try
                        _dlSortingField.SelectedIndex = _selectindex

                        If GridView1.SortExpression = _dlSortingField.SelectedValue Then
                                
                            'Dim _linkImageAsc As Image = TryCast(cell.FindControl("Image_LastUpdDate_SortImage_asc"), ImageButton)
                            Dim _linkImage As Image = TryCast(cell.FindControl("Image_LastUpdDate_SortImage"), ImageButton)
                                
                                
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                '_linkImageAsc.ImageUrl = "~/Images/sort_2.jpg"
                                '_linkImageDesc.ImageUrl = "~/Images/sort_1_disable.jpg"
                                _linkImage.ImageUrl = "~/Images/Aonline_icon_up1.jpg"

                                '_linkImageAesc.Visible = True
                                '_linkImageDesc.Visible = False
                            Else
                                _linkImage.ImageUrl = "~/Images/Aonline_icon_down1.jpg"
                                '_linkImage.ImageUrl = "~/Images/sort_1.jpg"
                                '_linkImageAesc.Visible = False
                                '_linkImageDesc.Visible = True
                            End If
                                
                        End If
                                

                    End If

                    'ViewState("aaa") = "aaaa"
                    'Dim bbb = ViewState("aaa")
                    'Old code                    
                    'Dim _CountrolCount As Integer = cell.Controls.Count
                    'If _CountrolCount > 0 Then

                    '    For i As Integer = 0 To _CountrolCount - 1
                    
                    '        Dim button As LinkButton = TryCast(cell.Controls(i), LinkButton)
                            
                    '        If Not (button Is Nothing) Then
                    '            Dim image As New ImageButton
                    '            image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_1.jpg"
                    '            image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                    '            If GridView1.SortExpression = button.CommandArgument Then
                    '                If GridView1.SortDirection = SortDirection.Ascending Then
                    '                    image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_2.jpg"
                    '                Else
                    '                    image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_1.jpg"
                    '                End If
                    '            End If
                    '            cell.Controls.AddAt(i + 1, image)
                    '        End If
                    
                    '    Next

                    'End If

                End If
            Next
        
            Dim numbericPagerPlaceHoder As PlaceHolder = (e.Row.FindControl("NumbericPagerPlaceHolder"))
            Dim numbericButton As New LinkButton

            Dim pageIndex As Integer = gv1.PageIndex
            Dim pageCount As Integer = gv1.PageCount
            Dim startIndex As Integer = IIf(pageIndex < 5, 0, IIf(pageIndex - 5 < pageCount - 10, pageIndex - 5, pageCount - 10))
            If startIndex < 0 Then startIndex = 0
            Dim endIndex As Integer = IIf(startIndex + 9 <= pageCount - 1, startIndex + 9, pageCount - 1)

            numbericPagerPlaceHoder.Controls.Add(New LiteralControl("&nbsp;&nbsp;"))

            For i As Integer = startIndex To endIndex
                If i = pageIndex Then
                    numbericPagerPlaceHoder.Controls.Add(New LiteralControl(String.Format("<span style='font-weight: bold;'>{0}</span>&nbsp;", i + 1)))
                Else
                    numbericButton = New LinkButton()
                    numbericButton.Text = (i + 1).ToString()
                    numbericButton.CommandName = "Page"
                    numbericButton.CommandArgument = (i + 1).ToString()

                    numbericPagerPlaceHoder.Controls.Add(numbericButton)
                    numbericPagerPlaceHoder.Controls.Add(New LiteralControl("&nbsp;"))
                End If
            Next

            numbericPagerPlaceHoder.Controls.Add(New LiteralControl("&nbsp;&nbsp;"))
        End If
    End Sub
    
    Protected Sub tvPISCat_TreeNodeCheckChanged(sender As Object, e As System.Web.UI.WebControls.TreeNodeEventArgs)
        Dim CheckedNode As TreeNode = e.Node
        If CheckedNode.Checked Then
            CheckedNode.Expand()
        Else
          
        End If
        For Each cn As TreeNode In CheckedNode.ChildNodes
            cn.Checked = CheckedNode.Checked
            tvPISCat_TreeNodeCheckChanged(cn, New TreeNodeEventArgs(cn))
        Next
    End Sub
    
    Sub BuildPisCatTree()
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim rootDt As New DataTable
        Dim apt As New SqlClient.SqlDataAdapter( _
            "select a.CATEGORY_ID, b.DISPLAY_NAME from CATALOG_SHOW a inner join PIS.dbo.CATEGORY b on a.CATEGORY_ID=b.CATEGORY_ID order by a.SEQ_NO ", conn)
        apt.Fill(rootDt)
        For Each r As DataRow In rootDt.Rows
            Dim RootCatNode As New TreeNode(r.Item("DISPLAY_NAME"), r.Item("CATEGORY_ID"))
            tvPISCat.Nodes.Add(RootCatNode)
            FillSubCat(RootCatNode, conn)
        Next
        If conn.State <> ConnectionState.Closed Then conn.Close()
    End Sub
    
    Sub FillSubCat(ByRef RootNode As TreeNode, ByRef conn As SqlClient.SqlConnection)
        If RootNode.Depth >= 6 Then Exit Sub
        Dim apt As New SqlClient.SqlDataAdapter( _
             "select CATEGORY_ID, DISPLAY_NAME from PIS.dbo.CATEGORY where PARENT_CATEGORY_ID=@CATID and ACTIVE_FLG='Y' order by SEQ_NO ", conn)
        apt.SelectCommand.Parameters.AddWithValue("CATID", RootNode.Value)
        Dim ChildDt As New DataTable
        If conn.State <> ConnectionState.Open Then conn.Open()
        apt.Fill(ChildDt)
        For Each cr As DataRow In ChildDt.Rows
            Dim ChildNode As New TreeNode(cr.Item("DISPLAY_NAME"), cr.Item("CATEGORY_ID"))
            RootNode.ChildNodes.Add(ChildNode)
            FillSubCat(ChildNode, conn)
        Next
    End Sub
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("http://my.advantech.com:7100/AOnline/ContentSearch.aspx?SessionId=" + HttpContext.Current.Session.SessionID + "&Email=" + HttpContext.Current.User.Identity.Name)
        If Not Page.IsPostBack Then
            buttonCheck.Attributes.CssStyle("visibility") = "hidden"
            tvPISCat.Attributes.Add("onclick", String.Format("document.getElementById('{0}').click();", buttonCheck.ClientID))
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
        End If
        If Not Page.IsPostBack AndAlso Request("SearchSid") IsNot Nothing Then
            src1.SelectParameters("SID").DefaultValue = Request("SearchSid")
        End If
        
    End Sub

    Protected Sub lnkExpandAll_Click(sender As Object, e As System.EventArgs)
        If lnkExpandAll.Text = "Expand All" Then
            tvPISCat.ExpandAll() : lnkExpandAll.Text = "Collapse All"
        Else
            tvPISCat.CollapseAll() : lnkExpandAll.Text = "Expand All"
        End If
    End Sub

    Protected Sub tvPISCat_TreeNodeCollapsed(sender As Object, e As System.Web.UI.WebControls.TreeNodeEventArgs)
        e.Node.Collapse()
    End Sub

    Protected Sub tvPISCat_TreeNodeExpanded(sender As Object, e As System.Web.UI.WebControls.TreeNodeEventArgs)
        e.Node.Expand()
    End Sub
    
    Sub GetCheckedCatTreeNodes(ByRef arr As ArrayList, Optional cn As TreeNode = Nothing)
        If arr Is Nothing And cn Is Nothing Then
            arr = New ArrayList
            For Each n As TreeNode In tvPISCat.Nodes
                GetCheckedCatTreeNodes(arr, n)
            Next
        Else
            If cn.Checked AndAlso Not arr.Contains(cn.Value) Then arr.Add(cn.Value)
            For Each ccn As TreeNode In cn.ChildNodes
                GetCheckedCatTreeNodes(arr, ccn)
            Next
        End If
    End Sub
    
    Sub GetCheckedLitTypes(ByRef arr As ArrayList)
        arr = New ArrayList
        Dim cbs() As CheckBox = GetAllCbLitCheckboxes()
        For Each cb As CheckBox In cbs
            If cb.Checked Then arr.Add(cb.Text)
        Next
    End Sub

    Protected Sub TimerLoadPisCat_Tick(sender As Object, e As System.EventArgs)
        TimerLoadPisCat.Interval = 99999
        Try
            BuildPisCatTree()
        Catch ex As Exception
        End Try
      
        TimerLoadPisCat.Enabled = False
    End Sub
    
    'Public Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
    '    If Search_Str <> String.Empty AndAlso Search_Str.Trim <> "" AndAlso Search_Str <> "*" Then
            
    '        'Frank 2012/04/26:Fixed error Quantifier {x,y} following nothing.
    '        'Search_Str = Replace(Search_Str, "*", "{0,}")
    '        Search_Str = Replace(Search_Str, "*", " ")
            
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
    
    'Public Function ReplaceKeyWords(ByVal m As Match) As String
    '    Return "<span style='background-color:Yellow'>" + m.Value + "</span>"
    'End Function
    
    Function ShowFwdEmailLink(ByVal srcApp As String, ByVal SrcId As String) As String
        If srcApp = "eCampaign" Or srcApp = "PIS" Or srcApp = "CMS" Then
            Return "<a href='ContentForward.aspx?SrcApp=" + srcApp + "&SrcId=" + SrcId + "&SearchSid=" + _
                src1.SelectParameters("SID").DefaultValue + "'>Forward Content</a>"
        End If
        Return ""
    End Function
    
    Function ShowHideLink(ByVal Url As String) As String
        If String.IsNullOrEmpty(Url) = False Then Return Url
        Return "javascript:void(0);"
    End Function
    
    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        If String.IsNullOrEmpty(txtKey.Text) Then txtKey.Text = "*"
        src1.SelectParameters("SID").DefaultValue = ""
        'hyContentFwd  
        If rblCHConvertOption.SelectedIndex = 1 Then
            hyContentFwd.HRef = "ContentForward.aspx?ToCHT=y"
        ElseIf rblCHConvertOption.SelectedIndex = 2 Then
            hyContentFwd.HRef = "ContentForward.aspx?ToCHS=y"
        End If
        If String.IsNullOrEmpty(txtKey.Text) = False Then
            Go4It()
        Else
            
        End If
        
    End Sub
    
    Function GetSelectedLanguageList() As List(Of AOnlineUtil.MktLanguageType)
        Dim ll As New List(Of AOnlineUtil.MktLanguageType)
        Select Case UCase(rblLanguage.SelectedValue)
            Case "ALL"
            Case "ENU", "EUS"
                ll.Add(AOnlineUtil.MktLanguageType.ENU)
            Case "JP"
                ll.Add(AOnlineUtil.MktLanguageType.JP)
            Case "RUS"
                ll.Add(AOnlineUtil.MktLanguageType.RUS)
            Case "CHS"
                ll.Add(AOnlineUtil.MktLanguageType.CHS)
            Case "CHT"
                ll.Add(AOnlineUtil.MktLanguageType.CHT)
            Case "ESP"
                ll.Add(AOnlineUtil.MktLanguageType.ESP)
        End Select
        Return ll
    End Function
    
    Sub Go4It()
        gv1.EmptyDataText = "No record found"
        Dim arrCatId As ArrayList = Nothing, arrLitId As ArrayList = Nothing
        Dim ListLanguage As List(Of AOnlineUtil.MktLanguageType) = GetSelectedLanguageList()
        GetCheckedCatTreeNodes(arrCatId) : GetCheckedLitTypes(arrLitId)
        dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", _
                                " delete from KM_SEARCH_TMP_DETAIL where SEARCH_ROW_ID in " + _
                                " (select row_id from KM_SEARCH_TMP_MASTER where USERID='" + User.Identity.Name + "')")
        Dim dtMaster As New DataTable
        With dtMaster.Columns
            .Add("ROW_ID") : .Add("SESSIONID") : .Add("USERID") : .Add("QUERY_DATETIME", GetType(DateTime)) : .Add("KEYWORDS")
        End With
        Dim r As DataRow = dtMaster.NewRow()
        r.Item("ROW_ID") = Left(Util.NewRowId("KM_SEARCH_TMP_MASTER", "MYLOCAL_NEW"), 10)
        : r.Item("SESSIONID") = Session.SessionID : r.Item("USERID") = User.Identity.Name : r.Item("QUERY_DATETIME") = Now() : r.Item("KEYWORDS") = txtKey.Text
        dtMaster.Rows.Add(r)
        Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
        bk.DestinationTableName = "KM_SEARCH_TMP_MASTER"
        bk.WriteToServer(dtMaster)
        Dim ThreadList As New ArrayList, KSObj As New ArrayList
        If cbEDM.Checked Then
            Dim ks As New AOnlineUtil.ContentSearch(txtKey.Text, Session.SessionID, r.Item("ROW_ID"))
            ks.CatIdSet = arrCatId : ks._SearchLanguage = ListLanguage
            Select Case rblSrcOptions.SelectedIndex
                Case 1
                    ks.enumSearchType = AOnlineUtil.SearchType.ByProduct
                Case 0
                    ks.enumSearchType = AOnlineUtil.SearchType.ByContent
            End Select
            Dim t As New Threading.Thread(AddressOf ks.SearchEDM) : t.Start()
            ThreadList.Add(t) : KSObj.Add(ks)
        End If
        If arrLitId.Count > 0 Then
            Dim ks As New AOnlineUtil.ContentSearch(txtKey.Text, Session.SessionID, r.Item("ROW_ID"))
            ks.CatIdSet = arrCatId : ks.LitTypeSet = arrLitId : ks._SearchLanguage = ListLanguage
            Select Case rblSrcOptions.SelectedIndex
                Case 1
                    ks.enumSearchType = AOnlineUtil.SearchType.ByProduct
                Case 0
                    ks.enumSearchType = AOnlineUtil.SearchType.ByContent
            End Select
            Dim t As New Threading.Thread(AddressOf ks.SearchMKTLit) : t.Start()
            ThreadList.Add(t) : KSObj.Add(ks)
        End If
        If arrLitId.Count > 0 Then
            Dim ks As New AOnlineUtil.ContentSearch(txtKey.Text, Session.SessionID, r.Item("ROW_ID"))
            ks.CatIdSet = arrCatId : ks.LitTypeSet = arrLitId : ks._SearchLanguage = ListLanguage
            Select Case rblSrcOptions.SelectedIndex
                Case 1
                    ks.enumSearchType = AOnlineUtil.SearchType.ByProduct
                Case 0
                    ks.enumSearchType = AOnlineUtil.SearchType.ByContent
            End Select
            Dim t As New Threading.Thread(AddressOf ks.SearchCMS) : t.Start()
            ThreadList.Add(t) : KSObj.Add(ks)
        End If
        For Each t As Threading.Thread In ThreadList
            t.Join()
        Next
        For Each ks As AOnlineUtil.ContentSearch In KSObj
            If ks.SearchFlg Then
                Dim dt As DataTable = ks.ResultDt
                If rblCHConvertOption.SelectedIndex = 1 Then
                    For Each ContentRow As DataRow In dt.Rows
                        ContentRow.Item("NAME") = CharSetConverter.ToTraditional(ContentRow.Item("NAME"))
                        ContentRow.Item("CONTENT_TEXT") = CharSetConverter.ToTraditional(ContentRow.Item("CONTENT_TEXT"))
                    Next
                ElseIf rblCHConvertOption.SelectedIndex = 2 Then
                    For Each ContentRow As DataRow In dt.Rows
                        ContentRow.Item("NAME") = CharSetConverter.ToSimplified(ContentRow.Item("NAME"))
                        ContentRow.Item("CONTENT_TEXT") = CharSetConverter.ToSimplified(ContentRow.Item("CONTENT_TEXT"))
                    Next
                End If
                Dim bk2 As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
                bk2.DestinationTableName = "KM_SEARCH_TMP_DETAIL"
                bk2.WriteToServer(dt)
                'lbMsg.Text = dt.Rows.Count.ToString()
            Else
                lbMsg.Text += "|" + ks.strErrMsg
            End If
        Next
        'Update Campaign referenced times
        dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", String.Format("update KM_SEARCH_TMP_DETAIL set referenced_times=(select COUNT(distinct a.CAMPAIGN_ROW_ID) from AONLINE_SALES_CAMPAIGN_SOURCES a where a.SOURCE_ID=KM_SEARCH_TMP_DETAIL.SOURCE_ID) where SEARCH_ROW_ID='{0}'", r.Item("ROW_ID")))
                                
        'If lbMsg.Text <> String.Empty Then Util.SendEmail("tc.chen@advantech.com.tw", "myadvantech@advantech.com", "Error KM search by " + User.Identity.Name, lbMsg.Text, False)
        src1.SelectParameters("SID").DefaultValue = r.Item("ROW_ID")
        srcResultTypes.SelectParameters("SID").DefaultValue = r.Item("ROW_ID")
        
        hdnRowId.Value = r.Item("ROW_ID").ToString
        Dim dtSource As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", GetLitTypeSql())
        If dtSource.Rows.Count > 0 Then
            For Each row As DataRow In dtSource.Rows
                Dim tab As New TabPanel
                tab.HeaderText = row.Item("source_type").ToString + " (" + row.Item("source_count").ToString + ")"
                tab.Visible = True
                tabc.Tabs.Add(tab)
            Next
            tabc.ActiveTabIndex = 0
            hdnRows.Value = dtSource.Rows(0).Item("source_count")
            tabc.Height = 100 + GetGVRows() * 140
        Else
            'tabc.Visible = False
        End If
    End Sub
    
    Function GetLitTypeSql() As String
        Return "select distinct SOURCE_TYPE, count(source_type) as source_count from KM_SEARCH_TMP_DETAIL where SEARCH_ROW_ID='" + hdnRowId.Value + "' group by source_type order by SOURCE_TYPE"
    End Function

    Protected Sub cbAllLitType_CheckedChanged(sender As Object, e As System.EventArgs)
        Dim tmpAllLitCb() As CheckBox = GetAllCbLitCheckboxes()
        For Each cb As CheckBox In tmpAllLitCb
            If cb IsNot Nothing Then
                cb.Checked = cbAllLitType.Checked
            End If
           
        Next
    End Sub
    
    Function GetAllCbLitCheckboxes() As CheckBox()
        Dim tmpAllLitCb() As CheckBox = { _
          cbEDM, cbWhitePaper, cbCaseStudy, cbNews, _
          cbECatalog, cbVideo, cbBrochure, _
          cbDataSheet, cbCertificate, cbIndusFocus, cbTechHigh}
        Return tmpAllLitCb
    End Function

    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            'Dim ed As AjaxControlToolkit.HTMLEditor.Editor = CType(e.Row.FindControl("RowEditor"), AjaxControlToolkit.HTMLEditor.Editor)
            'If ed.Content = String.Empty Then ed.Visible = False
        End If
    End Sub

    Protected Sub RowEditor_PreRender(sender As Object, e As System.EventArgs)
        'Dim ed As AjaxControlToolkit.HTMLEditor.Editor = sender
        'Dim lnkBtn As LinkButton = ed.NamingContainer.FindControl("lnkRowShowEditor")
        'If ed.Content = String.Empty Then
        '    ed.Visible = False : lnkBtn.Visible = False
        'End If
       
    End Sub

    Protected Sub rblResultLitTypes_DataBound(sender As Object, e As System.EventArgs)
        If rblResultLitTypes.Items.Count > 0 Then
            rblResultLitTypes.Items(0).Selected = True
        End If
        rblResultLitTypes.Style.Add("display", "none")
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
                '"<script type='text/javascript'>" + _
                '    "function keyFunction() {" + _
                '        "if ((event.ctrlKey) && (event.keyCode == 67))" + _
                '            "return false;" + _
                '    "}" + _
                '    "document.onkeydown = keyFunction;" + _
                '    "document.oncontextmenu = new Function('return false;')" + _
                '"<" + "/" + "script>"
            End If
        End If
        ed.Visible = True : lnkBtn.Visible = False
    End Sub

    Protected Sub lnkClosePickCat_Click(sender As Object, e As System.EventArgs)
        lbPickedCatNames.Text = ""
        For Each n As TreeNode In tvPISCat.Nodes
            ShowPickedCatName(n)
        Next
    End Sub
    
    Private Sub ShowPickedCatName(ByRef cn As TreeNode)
        If cn.Checked Then
            lbPickedCatNames.Text += cn.Text + ";"
        End If
        For Each n As TreeNode In cn.ChildNodes
            ShowPickedCatName(n)
        Next
    End Sub

    Protected Sub lnkRowAddMail_Click(sender As Object, e As System.EventArgs)
        Dim lnk As ImageButton = sender
        Dim srcId As String = CType(lnk.NamingContainer.FindControl("hdSrcID"), HiddenField).Value
        Dim srcTitle As String = CType(lnk.NamingContainer.FindControl("hdSrcTitle"), HiddenField).Value
        Dim srcApp As String = CType(lnk.NamingContainer.FindControl("hdSrcApp"), HiddenField).Value
        Dim srcURL As String = CType(lnk.NamingContainer.FindControl("hdSrcOriUrl"), HiddenField).Value
        AOnlineUtil.AOnlineSalesCampaign.AddContentToMyContentCart(srcId, srcTitle, srcApp, srcURL)
        Response.Redirect("ContentForward.aspx")
        'gvMyContents.DataBind()
        'lnk.Text = "Added to My Content" 'lnk.Enabled = False
        'If gvMyContents.Rows.Count > 0 Then PanelAddedContents.Visible = True
    End Sub

    Protected Sub lnkRowAddContent_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim lnk As ImageButton = sender
        Dim srcId As String = CType(lnk.NamingContainer.FindControl("hdSrcID"), HiddenField).Value
        Dim srcTitle As String = CType(lnk.NamingContainer.FindControl("hdSrcTitle"), HiddenField).Value
        Dim srcApp As String = CType(lnk.NamingContainer.FindControl("hdSrcApp"), HiddenField).Value
        Dim srcURL As String = CType(lnk.NamingContainer.FindControl("hdSrcOriUrl"), HiddenField).Value
        AOnlineUtil.AOnlineSalesCampaign.AddContentToMyContentCart(srcId, srcTitle, srcApp, srcURL)
        gvMyContents.DataBind()
        'lnk.Enabled = False
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

    Protected Sub tabc_ActiveTabChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        tabc.Tabs.Clear()
        Dim dtSource As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", GetLitTypeSql())
        If dtSource.Rows.Count > 0 Then
            tabc.Visible = True
            For Each row As DataRow In dtSource.Rows
                Dim tab As New TabPanel
                tab.HeaderText = row.Item("source_type").ToString + " (" + row.Item("source_count").ToString + ")"
                tab.Visible = True
                tabc.Tabs.Add(tab)
            Next
            hdnRows.Value = tabc.Tabs(tabc.ActiveTabIndex).HeaderText.Substring(tabc.Tabs(tabc.ActiveTabIndex).HeaderText.LastIndexOf("(") + 1).Replace(")", "")
        Else
            tabc.Visible = False
        End If
        rblResultLitTypes.SelectedIndex = tabc.ActiveTabIndex
        tabc.Height = 100 + GetGVRows() * 140
        gv1.PageIndex = 0
        up1.Update()
    End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If tabc.Tabs.Count > 0 Then
            gv1.Style.Add("position", "relative")
            gv1.Style.Add("left", "10px")
            gv1.Style.Add("top", (-105 - (140 * GetGVRows())).ToString + "px")
        End If
    End Sub
    
    Function GetGVRows() As Integer
        Dim rows As Integer = CInt(hdnRows.Value)
        If rows >= 10 Then rows = 10
        Return rows
    End Function
    
    Private Function CutString(ByVal _text As String, ByVal _cutlength As Integer) As String
        If String.IsNullOrEmpty(_text) Then
            Return _text
        End If
        
        If _text.Length > _cutlength Then
            Return _text.Substring(0, _cutlength)
        End If
        
        Return _text
        
    End Function
    
    ''' <summary>
    ''' Sort field changed
    ''' </summary>
    ''' <param name="sender"></param>
    ''' <param name="e"></param>
    ''' <remarks></remarks>
    Protected Sub dlSortingField_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dl As DropDownList = sender
        Dim _SortColumn As String = dl.SelectedValue
        Dim _selectindex As Integer = dl.SelectedIndex
        ViewState("SortFieldIndex") = _selectindex
        ViewState("SortField") = _SortColumn
        Dim _sortdirection As SortDirection = SortDirection.Descending
        
        'Select Case dl.SelectedIndex
        '    Case 0
        '        'rank_value
        '        '_sortdir()
        '    Case 1
        '        'last_upd_date
        '    Case 2
        '        '?
        'End Select

        Me.gv1.Sort(_SortColumn, _sortdirection)
       
        
    End Sub


    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
    .Tabs1 .ajax__tab_header
    {
        padding:0px;
        color: #4682b4;
        font-family:Calibri;
        font-size: 14px;
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
        color: #595959;
        background:url("../../Images/AOnline_tab_inactive1.jpg") repeat-x;
        padding-top:5px;
        height:19px;
    }
    .Tabs1 .ajax__tab_active .ajax__tab_inner
    {
            background:url("../../Images/AOnline_tab_inactive_left1.jpg") no-repeat;
            padding-left:10px;
    }
    .Tabs1 .ajax__tab_active .ajax__tab_outer
    {
            background:url("../../Images/AOnline_tab_inactive_right1.jpg") no-repeat right;
            padding-right:10px;
    }
    /*Tab Hover*/
    .Tabs1 .ajax__tab_hover .ajax__tab_tab
    {
        color: #595959;
        background:url("../../Images/AOnline_tab_inactive1.jpg") repeat-x;
        padding-top:5px;
        height:19px;
    }
    .Tabs1 .ajax__tab_hover .ajax__tab_inner
    {
        background:url("../../Images/AOnline_tab_inactive_left1.jpg") no-repeat;
            padding-left:10px;
    }
    .Tabs1 .ajax__tab_hover .ajax__tab_outer
    {
        background:url("../../Images/AOnline_tab_inactive_right1.jpg") no-repeat right;
            padding-right:10px;
    }
    /*Tab Inactive*/
    .Tabs1 .ajax__tab_tab
    {
        color: #8B898A;
        background:url("../../Images/AOnline_tab_active1.jpg") repeat-x;
        padding-top:5px;
        height:19px;
    }
    .Tabs1 .ajax__tab_inner
    {
        background:url("../../Images/AOnline_tab_active_left1.jpg") no-repeat;
            padding-left:10px;
    }
    .Tabs1 .ajax__tab_outer
    {
        background:url("../../Images/AOnline_tab_active_right1.jpg") no-repeat right;
            padding-right:10px;
    }
</style>
    <table width="100%">
        <tr align="right"><td align="right"><uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" /></td></tr>
    </table>
    <table width="100%">
        <tr style="height: 25px">
            <th align="left" valign="top">
                <h1 style="color: #0070C0">
                    Search
                </h1>
            </th>
        </tr>
        <tr><td height="10"></td></tr>
        <tr>
            <td style="padding-left:20px; padding-top:20px; border-width:1px; border-style:solid; border-color:#d9d9d9">
                <asp:Panel runat="server" ID="PanelSearch" DefaultButton="btnSearch">
                    <table width="100%">
                        <tr>
                            <th align="left">
                                Keyword
                            </th>
                            <td>
                                <table>
                                    <tr>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtKey" Width="300px" />
                                        </td>
                                        <td align="left">
                                            by
                                        </td>
                                        <td>
                                            <asp:RadioButtonList runat="server" ID="rblSrcOptions" RepeatColumns="4" RepeatDirection="Horizontal">
                                                <asp:ListItem Text="content" Selected="True" />
                                                <asp:ListItem Text="product/model number" />                                                            
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">
                                Types
                            </th>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td align="center">
                                <asp:CheckBox runat="server" ID="cbAllLitType" AutoPostBack="True" Text="All" OnCheckedChanged="cbAllLitType_CheckedChanged" />
                            </td>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upLitType" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <table width="100%">
                                            <tr>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="Server" ID="cbCaseStudy" Text="Case Study" Checked="true" />                                          
                                                </td>
                                                <td colspan="3">
                                                    <table cellpadding="0" cellspacing="0" border="0">
                                                        <tr>
                                                            <td>
                                                                <asp:CheckBox runat="Server" ID="cbIndusFocus" Text="Industry Focus (Curated Content)" Checked="true" />
                                                            </td>
                                                            <td width="50"></td>
                                                            <td>
                                                                <asp:CheckBox runat="Server" ID="cbTechHigh" Text="Technology Highlight (Curated Content)" Checked="true" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="Server" ID="cbNews" Text="News" Checked="true" />
                                                </td>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="Server" ID="cbWhitePaper" Text="White Paper" Checked="true" />
                                                </td>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="Server" ID="cbEDM" Text="eDM" Checked="true" />
                                                </td>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="server" ID="cbCertificate" Text="Certificate" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="Server" ID="cbBrochure" Text="Brochure" />
                                                </td>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="Server" ID="cbECatalog" Text="eCatalog" />
                                                </td>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="server" ID="cbDataSheet" Text="Product - Datasheet" />
                                                </td>
                                                <td style="width: 25%">
                                                    <asp:CheckBox runat="Server" ID="cbVideo" Text="Video" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="width: 25%">
                                                </td>
                                                <td style="width: 25%">
                                                </td>
                                                <td style="width: 25%">
                                                </td>
                                                <td style="width: 25%">
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="cbAllLitType" EventName="CheckedChanged" />
                                    </Triggers>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Language</th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="rblLanguage" RepeatColumns="9" RepeatDirection="Horizontal">
                                    <asp:ListItem Text="All" Value="All" Selected="True" />
                                    <asp:ListItem Text="English" Value="ENU" />
                                    <asp:ListItem Text="Traditional Chinese" Value="CHT" />
                                    <asp:ListItem Text="Simplified Chinese" Value="CHS" />
                                    <asp:ListItem Text="Russian" Value="RUS" />
                                    <asp:ListItem Text="Spanish" Value="ESP" />
                                    <asp:ListItem Text="Japanese" Value="JP" />
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr runat="server" id="trChsCht" visible="False" style="display: none">
                            <th id="Th1" align="left" runat="server">
                                简繁中转换/簡繁中轉換
                            </th>
                            <td id="Td1" runat="server">
                                <asp:RadioButtonList runat="server" ID="rblCHConvertOption" RepeatColumns="3" RepeatDirection="Horizontal">
                                    <asp:ListItem Text="不转换/不轉換" Selected="True" />
                                    <asp:ListItem Text="簡轉繁" />
                                    <asp:ListItem Text="繁转简" />
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">
                                Product Category
                            </th>
                            <td>
                                <table>
                                    <tr>
                                        <td>
                                            <a href="javascript:void(0);" onclick="ShowPISCat();">Pick</a>
                                        </td>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upPickedCat" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:Panel runat="server" ID="PanelPickedCat" Width="700px" ScrollBars="Auto" Height="25px">
                                                        <asp:Label runat="server" ID="lbPickedCatNames" />
                                                    </asp:Panel>
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="lnkClosePickCat" EventName="Click" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr align="center">
                            <td align="center" colspan="2">
                                <div>
                                    <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td style="height: 15px">
                                <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Label runat="server" ID="lbMsg" ForeColor="Tomato" Font-Bold="true" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr><td height="10"></td></tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upTab" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ajaxToolkit:TabContainer runat="server" ID="tabc" AutoPostBack="true" CssClass="Tabs1" OnActiveTabChanged="tabc_ActiveTabChanged"></ajaxToolkit:TabContainer>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:HiddenField runat="server" ID="hdnRowId" />
                        <asp:HiddenField runat="server" ID="hdnRows" />
                        <asp:RadioButtonList runat="server" ID="rblResultLitTypes" RepeatColumns="7" RepeatDirection="Horizontal"
                            Font-Size="Small" RepeatLayout="Table" AutoPostBack="true" DataSourceID="srcResultTypes"
                            DataTextField="SOURCE_TYPE" DataValueField="SOURCE_TYPE" OnDataBound="rblResultLitTypes_DataBound" />
                        <asp:SqlDataSource runat="server" ID="srcResultTypes" ConnectionString="<%$ConnectionStrings:MyLocal_New %>"
                            SelectCommand="select distinct SOURCE_APP+' - '+SOURCE_TYPE as APP_TYPE, SOURCE_TYPE from KM_SEARCH_TMP_DETAIL where SEARCH_ROW_ID=@SID order by SOURCE_TYPE">
                            <SelectParameters>
                                <asp:Parameter ConvertEmptyStringToNull="false" Name="SID" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                        <asp:GridView runat="server" ID="gv1" Width="98%" AllowPaging="true" AllowSorting="true" BorderWidth="0" RowStyle-BorderWidth="0"
                            OnRowCreated="gvRowCreated" PageSize="10" PagerSettings-Position="Top" EnableTheming="false" BorderColor="White" RowStyle-BorderColor="White"
                            DataSourceID="src1" AutoGenerateColumns="false" EmptyDataText="" PagerSettings-PageButtonCount="20" PagerStyle-HorizontalAlign="Right"
                            OnRowDataBound="gv1_RowDataBound" OnDataBound="gv1_DataBound">
                            <PagerTemplate>
                                          
                            </PagerTemplate>
                            <Columns>
                                <asp:TemplateField HeaderStyle-Width="80%">
                                    <HeaderTemplate>
                                        <table width="100%" cellpadding="0" cellspacing="0" border="0">
                                            <tr>
                                                <td align="left" width="55%">
                                                    <asp:Label runat="Server" ID="lbl" Text="Content" Visible="false" />
                                                </td>
                                                <td align="right" width="30%" valign="middle">
                                                    <table>
                                                        <tr>
                                                            <th>Sort by : </th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlSortingField" Width="90%" AutoPostBack="true" OnSelectedIndexChanged="dlSortingField_SelectedIndexChanged" Style="vertical-align: middle" >
                                                                    <asp:ListItem Text="Best Match" Value="RANK_VALUE" />
                                                                    <asp:ListItem Text="Newly Updated" Value="LAST_UPD_DATE" />
                                                                    <asp:ListItem Text="Most Frequently Used" Value="REFERENCED_TIMES"/>
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td align="left">
                                                    <table cellpadding="0" cellspacing="0" border="0" style="height: 18px">
                                                        <%--<tr>
                                                            <td>
                                                                <!--Descen:arrowdirect to up -->
                                                                <asp:ImageButton ID="Image_LastUpdDate_SortImage_asc" runat="server" ImageUrl="~/Images/sort_2.jpg"
                                                                    Style="vertical-align: bottom" CommandArgument="LAST_UPD_DATE" CommandName="Sort" OnCommand="Sort_Command" />
                                                            </td>
                                                        </tr>--%>
                                                        <tr>
                                                            <td>
                                                                <asp:ImageButton ID="Image_LastUpdDate_SortImage" runat="server" ImageUrl="~/Images/Aonline_icon_down1.jpg"
                                                                    Style="vertical-align: middle" CommandName="SortData" OnCommand="Sort_Command" Visible="false" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                                <td><asp:PlaceHolder ID="NumbericPagerPlaceHolder" runat="server"></asp:PlaceHolder></td>
                                            </tr>
                                        </table>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:HiddenField runat="server" ID="hdSrcApp" Value='<%#Eval("SOURCE_APP") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcID" Value='<%#Eval("SOURCE_ID") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcType" Value='<%#Eval("SOURCE_TYPE") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcTitle" Value='<%#Eval("NAME") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcOriUrl" Value='<%#Eval("ORIGINAL_URL") %>' />
                                        <table border="0" style="table-layout: fixed; padding-left:10px">
                                            <tr>
                                                <td width="12"><img src="../../Images/Aonline_icon.jpg" /></td>
                                                <td align="left"><a href='<%#ShowHideLink(Eval("ORIGINAL_URL")) %>' target="_blank" style="color:#E46C0A; font-family: sans-serif; font-size:small">
                                                        <%# Util.Highlight(Me.txtKey.Text, Eval("NAME"))%></a>
                                                    &nbsp;
                                                    <asp:ImageButton ID="lnkRowAddMail" runat="server" ToolTip="Add to Mail" OnClick="lnkRowAddMail_Click" ImageUrl="~/Images/AddtoMail_Send.png" Style="vertical-align: middle" />
                                                    &nbsp;
                                                    <asp:ImageButton runat="server" ID="lnkRowAddContent" ToolTip="Add to My Content" ImageUrl="~/Images/AddtoMail_Merge.PNG" Style="vertical-align: middle" OnClick="lnkRowAddContent_Click" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <div id="SomeID" runat="server" style="width:800px;word-wrap:break-word" ><%#Eval("DESCRIPTION")%>&nbsp;&nbsp;<i><font color="gray">[Last updated on
                                                        <%#CDate(Eval("LAST_UPD_DATE")).ToString("yyyy/MM/dd")%>]</font></i></div>
                                                </td>
                                            </tr>
                                            <tr style="display: none">
                                                <td colspan="2">
                                                    <asp:UpdatePanel runat="server" ID="upRowEditor" UpdateMode="Conditional" Visible="false">
                                                        <ContentTemplate>
                                                            <asp:LinkButton  Visible="false" runat="server" ID="lnkRowShowEditor" Text="Show Content" OnClick="lnkRowShowEditor_Click" />
                                                            <uc1:NoToolBarEditor2 runat="server" ID="RowEditor" Visible="false" Content='<%# Util.Highlight(Me.txtKey.Text, Eval("CONTENT_TEXT"))%>'
                                                                Width="750px" Height="120px" ActiveMode="Preview" OnPreRender="RowEditor_PreRender" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                            <tr><td colspan="2" height="10"></td></tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MyLocal_New %>"
                            SelectCommand="
                            SELECT a.SOURCE_APP, a.SOURCE_ID, a.SOURCE_TYPE, a.NAME, IsNull(a.CONTENT_TEXT,'') as CONTENT_TEXT,
                            a.ORIGINAL_URL, a.THUMBNAIL_URL, a.RANK_VALUE, a.LAST_UPD_DATE, IsNull(a.DESCRIPTION,'') as DESCRIPTION
                            ,a.REFERENCED_TIMES 
                            FROM KM_SEARCH_TMP_DETAIL a
                            where a.SEARCH_ROW_ID=@SID and a.SOURCE_TYPE=@LTYPE
                            order by a.RANK_VALUE desc, a.SOURCE_APP desc, a.LAST_UPD_DATE desc, a.SOURCE_ID
                        ">
                            <SelectParameters>
                                <asp:Parameter ConvertEmptyStringToNull="false" Name="SID" />
                                <asp:ControlParameter ControlID="rblResultLitTypes" ConvertEmptyStringToNull="false"
                                    Name="LTYPE" PropertyName="SelectedValue" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                        <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender2" runat="server"
                            TargetControlID="PanelAddedContents" HorizontalSide="Right" VerticalSide="Bottom"
                            HorizontalOffset="200" VerticalOffset="60" />
                        <asp:Panel runat="server" ID="PanelAddedContents" Visible="false" BackColor="Azure">
                            <table width="100%" style="border-style:double">
                                <tr><th align="left">My Contents</th></tr>
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
                                                                                        <a target="_blank" href='<%#Eval("ORIGINAL_URL") %>'><%#Eval("CONTENT_TITLE")%></a>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="right">
                                                                                    <asp:LinkButton Font-Size="XX-Small" ID="LinkButton1" runat="server" CommandName="Delete" Text="Delete" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ItemTemplate>
                                                                </asp:TemplateField>
                                                            </Columns>
                                                        </asp:GridView>
                                                        <asp:SqlDataSource runat="server" ID="srcMyContents" ConnectionString="<%$ConnectionStrings:MyLocal_New %>"
                                                            SelectCommand="SELECT TOP 100 SESSIONID, SOURCE_ID, CONTENT_TITLE, SOURCE_APP, ORIGINAL_URL
                                                            FROM AONLINE_SALES_CONTENT_CART where SESSIONID=@SEID order by ADDED_DATE desc" DeleteCommand="delete from AONLINE_SALES_CONTENT_CART where SESSIONID=@SESSIONID and SOURCE_ID=@SOURCE_ID">
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
                                                <td><a style="font-size:x-small" href="ContentForward.aspx" runat="server" id="hyContentFwd">Forward Content</a></td>
                                                <td>|</td>
                                                <td><a style="font-size:x-small" href="ContactMining.aspx">Search Contact</a></td>
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
            
    <script type="text/javascript">
        function ShowPISCat() {
            var divCat = document.getElementById('divPCat');
            divCat.style.display = 'block';
        }
        function CloseDivCat() {
            var divCat = document.getElementById('divPCat');
            divCat.style.display = 'none';
        }
    </script>
    <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
        TargetControlID="PanelProductCategories" HorizontalSide="Center" VerticalSide="Middle"
        HorizontalOffset="400" VerticalOffset="200" />
    <asp:Panel runat="server" ID="PanelProductCategories">
        <div id="divPCat" style="display: none; background-color: white; border: solid 1px silver;
            padding: 10px; width: 650px; height: 350px; overflow: auto;">
            <table width="100%">
                <tr>
                    <td align="right">
                        <asp:LinkButton runat="server" ID="lnkClosePickCat" Text="Close" OnClientClick="CloseDivCat();"
                            OnClick="lnkClosePickCat_Click" />
                    </td>
                </tr>
                <tr>
                    <th>
                        Pick PIS Product Categories
                    </th>
                </tr>
                <tr>
                    <td>
                        <asp:UpdatePanel runat="server" ID="upTvPisCat" UpdateMode="Conditional">
                            <ContentTemplate>
                                <asp:Timer runat="server" ID="TimerLoadPisCat" Interval="100" OnTick="TimerLoadPisCat_Tick" />
                                <asp:LinkButton runat="server" ID="lnkExpandAll" Text="Expand All" OnClick="lnkExpandAll_Click" />
                                <asp:TreeView runat="server" ID="tvPISCat" OnTreeNodeCheckChanged="tvPISCat_TreeNodeCheckChanged"
                                    ShowCheckBoxes="All" ExpandDepth="0" OnTreeNodeCollapsed="tvPISCat_TreeNodeCollapsed"
                                    OnTreeNodeExpanded="tvPISCat_TreeNodeExpanded" />
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="buttonCheck" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel>
    <asp:Button ID="buttonCheck" runat="server" CausesValidation="false" />    
</asp:Content>
