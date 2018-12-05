<%@ Page Title="MyAdvantech - AOnline Content Search" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    ValidateRequest="false" EnableEventValidation="false" %>

<%@ Register Namespace="eBizAEUControls" TagPrefix="uc1" %>
<%--<%@ Register src="AOnlineFunctionLinks.ascx" tagname="AOnlineFunctionLinks" tagprefix="uc1" %>
<%@ Register Src="~/Includes/Campaign/CampaignCriteria.ascx" TagName="CampaignCriteria" TagPrefix="uc1" %>
--%>
<script runat="server">   
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetTagKeywords(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As DataTable = Nothing
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")

        'dt = dbUtil.dbGetDataTable("MY", String.Format( _
        '"select distinct top 5 META_KEYWORD From CAMPAIGN_META_KEYWORDS Where META_KEYWORD like '{0}%' order by META_KEYWORD desc", prefixText))
        
        Dim _sql As String = "Select top 5 META_KEYWORD ,COUNT(META_KEYWORD) as META_KEYWORD_COUNT"
        _sql &= " From CAMPAIGN_META_KEYWORDS"
        _sql &= " Where META_KEYWORD like N'%" & prefixText & "%'"
        _sql &= " Group by META_KEYWORD"
        _sql &= " Order by META_KEYWORD_COUNT desc"
        
        dt = dbUtil.dbGetDataTable("MY", _sql)
        
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    
    Protected Sub btnPickSector_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'ucSelectSector.ShowModalPopup()
    End Sub
    
    Protected Sub ucSelectSector_RaiseSelection(ByVal dt As System.Data.DataTable)
        
        Me.Literal_Sector_Checked_List.Text = ""
        
        For Each row As DataRow In dt.Rows
            If Me.Literal_Sector_Checked_List.Text.Trim.Length > 0 Then
                Me.Literal_Sector_Checked_List.Text += " | "
            End If
            Me.Literal_Sector_Checked_List.Text += row.Item("text").ToString
        Next
        
    End Sub

    
    Protected Sub Sort_Command(ByVal sender As Object, ByVal e As CommandEventArgs)
        If e.CommandName = "SortData" Then
            
            
            Dim obj As ImageButton = TryCast(sender, ImageButton)
            Dim _SortField As String = ViewState("SortField")
            
            If String.IsNullOrEmpty(_SortField) Then
                _SortField = "RANK_VALUE"
            End If
            
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
        End If
    End Sub
    
    'Dim ShowPreviewLitTypes() As String = {"eDM", "1-1 eLetter", "News", "Case Study"}
    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
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
                                _linkImage.ImageUrl = "~/Images/Aonline_icon_up1.jpg"

                            Else
                                _linkImage.ImageUrl = "~/Images/Aonline_icon_down1.jpg"
                            End If
                                
                        End If
                                

                    End If
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
        If Not Page.IsPostBack Then
            If True Then tbTab.Visible = True : MultiView1.ActiveViewIndex = 0
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
            Call BindGVNew() : BindGVHot()
        End If
        If Not Page.IsPostBack AndAlso Request("SearchSid") IsNot Nothing Then
            src1.SelectParameters("SID").DefaultValue = Request("SearchSid")
        End If
    End Sub

    Public Function GetNewContent(Optional ByVal FilterType As String = "") As DataTable
        Dim arrLit As New ArrayList
        If FilterType <> "" Then
            arrLit.Add(FilterType)
        Else
            Dim cbs() As CheckBox = GetAllCbLitCheckboxes()
            For Each cb As CheckBox In cbs
                arrLit.Add(cb.Text)
            Next
        End If
        Dim ks As New AOnlineUtil.ContentSearch("", Session.SessionID, "")
        ks.LitTypeSet = arrLit : ks._SearchLanguage = GetSelectedLanguageList(rblNewLang)
        ks.SearchNewContent()
        Return ks.ResultDt
    End Function
    
    Sub BindGVNew()
        Dim dt As DataTable = GetNewContent()
        'gvNew.DataSource = dt : gvNew.DataBind()
        Dim dtC As DataTable = dt.Clone()
        Dim index As Integer = 0
        For Each row As DataRow In dt.Rows
            dtC.ImportRow(row)
            index += 1
            If index >= 10 Then Exit For
        Next
        rpNew.DataSource = dtC : rpNew.DataBind()
        Dim dtType As DataTable = dt.DefaultView.ToTable(True, "SOURCE_TYPE")
        Dim r As DataRow = dtType.NewRow()
        r.Item(0) = "All" : dtType.Rows.InsertAt(r, 0)
        lvNew.DataSource = dtType : lvNew.DataBind()
    End Sub
    
    Public Function GetTopContent(Optional ByVal FilterType As String = "") As DataTable
        Dim ks As New AOnlineUtil.ContentSearch("", Session.SessionID, "")
        ks._SearchLanguage = GetSelectedLanguageList(rblHotLang)
        ks.SearchTopRefContent(FilterType)
        Return ks.ResultDt
    End Function
    
    Sub BindGVHot()
        Dim dt As DataTable = GetTopContent()
        'gvHot.DataSource = dt : gvHot.DataBind()
        Dim dtC As DataTable = dt.Clone()
        Dim index As Integer = 0
        For Each row As DataRow In dt.Rows
            dtC.ImportRow(row)
            index += 1
            If index >= 10 Then Exit For
        Next
        rpHot.DataSource = dtC : rpHot.DataBind()
        Dim dtType As DataTable = dt.DefaultView.ToTable(True, "SOURCE_TYPE")
        Dim r As DataRow = dtType.NewRow()
        r.Item(0) = "All" : dtType.Rows.InsertAt(r, 0)
        lvHot.DataSource = dtType : lvHot.DataBind()
    End Sub
    
    Protected Sub lnkExpandAll_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If lnkExpandAll.Text = "Expand All" Then
            tvPISCat.ExpandAll() : lnkExpandAll.Text = "Collapse All"
        Else
            tvPISCat.CollapseAll() : lnkExpandAll.Text = "Expand All"
        End If
    End Sub

    Protected Sub tvPISCat_TreeNodeCollapsed(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.TreeNodeEventArgs)
        e.Node.Collapse()
    End Sub

    Protected Sub tvPISCat_TreeNodeExpanded(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.TreeNodeEventArgs)
        e.Node.Expand()
    End Sub
    
    Sub GetCheckedCatTreeNodes(ByRef arr As ArrayList, Optional ByVal cn As TreeNode = Nothing)
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

    Protected Sub TimerLoadPisCat_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerLoadPisCat.Interval = 99999
        Try
            BuildPisCatTree()
        Catch ex As Exception
        End Try
      
        TimerLoadPisCat.Enabled = False
    End Sub
    
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
    
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
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
    
    Function GetSelectedLanguageList(ByVal rblLang As RadioButtonList) As List(Of AOnlineUtil.MktLanguageType)
        Dim ll As New List(Of AOnlineUtil.MktLanguageType)
        Select Case UCase(rblLang.SelectedValue)
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
            Case "KR"
                ll.Add(AOnlineUtil.MktLanguageType.KR)
        End Select
        Return ll
    End Function
    
    Private Function GetSectorSelectedItem() As String
        
        'Dim _dt As DataTable = ucSelectSector.GetSelectionList
        
        'Dim _returnval As String = ""
        
        'For Each _item As DataRow In _dt.Rows
        '    _returnval &= "'" & _item.Item("value").ToString.Replace("'", "''") & "',"
        'Next
        
        'If _returnval <> "" Then
        '    Dim dtSecMap As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select CMS_BU from AONLINE_SECTOR_CMSBU where sector_name in ({0})", _returnval.TrimEnd(",")))
        '    _returnval = ""
        '    For Each row As DataRow In dtSecMap.Rows
        '        _returnval &= "'" & row.Item("CMS_BU").ToString.Replace("'", "''") & "',"
        '    Next
        'End If
        'Return _returnval.TrimEnd(",")
        Return ""
    End Function
    
    Private Function GetTagKeyword() As String
        
        Dim _returnstr As String = String.Empty
        Dim _keyword1 As String = Me.TextBox_TagKeyword1.Text.Trim, _keyword2 As String = Me.TextBox_TagKeyword2.Text.Trim, _keyword3 As String = Me.TextBox_TagKeyword3.Text.Trim
        
        If Not String.IsNullOrEmpty(_keyword1) Then _returnstr &= "'" & _keyword1.Replace("'", "''") & "',"
        If Not String.IsNullOrEmpty(_keyword2) Then _returnstr &= "'" & _keyword2.Replace("'", "''") & "',"
        If Not String.IsNullOrEmpty(_keyword3) Then _returnstr &= "'" & _keyword3.Replace("'", "''") & "',"
        If Not String.IsNullOrEmpty(_returnstr) Then
            Return _returnstr.TrimEnd(",")
        End If

        Return ""
        
    End Function
    
    Sub Go4It()
        'Frank 2012/06/05
        Dim _SectorString As String = GetSectorSelectedItem(), _TagKeywordString As String = GetTagKeyword()
        
        tabc.Tabs.Clear()
        gv1.EmptyDataText = "No record found"
        Dim arrCatId As ArrayList = Nothing, arrLitId As ArrayList = Nothing
        Dim ListLanguage As List(Of AOnlineUtil.MktLanguageType) = GetSelectedLanguageList(rblLanguage)
        GetCheckedCatTreeNodes(arrCatId) : GetCheckedLitTypes(arrLitId)
        dbUtil.dbExecuteNoQuery("MY", _
                                " delete from KM_SEARCH_TMP_DETAIL where SEARCH_ROW_ID in " + _
                                " (select row_id from KM_SEARCH_TMP_MASTER where USERID='" + User.Identity.Name + "')")
        Dim dtMaster As New DataTable
        With dtMaster.Columns
            .Add("ROW_ID") : .Add("SESSIONID") : .Add("USERID") : .Add("QUERY_DATETIME", GetType(DateTime)) : .Add("KEYWORDS")
        End With
        Dim r As DataRow = dtMaster.NewRow()
        r.Item("ROW_ID") = Left(Util.NewRowId("KM_SEARCH_TMP_MASTER", "MY"), 10)
        : r.Item("SESSIONID") = Session.SessionID : r.Item("USERID") = User.Identity.Name : r.Item("QUERY_DATETIME") = Now() : r.Item("KEYWORDS") = txtKey.Text
        dtMaster.Rows.Add(r)
        Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        bk.DestinationTableName = "KM_SEARCH_TMP_MASTER"
        bk.WriteToServer(dtMaster)
        Dim ThreadList As New ArrayList, KSObj As New ArrayList
        If cbEDM.Checked Then
            Dim ks As New AOnlineUtil.ContentSearch(txtKey.Text, Session.SessionID, r.Item("ROW_ID"))
            ks.CatIdSet = arrCatId : ks._SearchLanguage = ListLanguage : ks.strSearchTagKwyword = _TagKeywordString
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
            ks.strSearchSector = _SectorString : ks.strSearchTagKwyword = _TagKeywordString
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
                Dim bk2 As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                bk2.DestinationTableName = "KM_SEARCH_TMP_DETAIL"
                bk2.WriteToServer(dt)
                'lbMsg.Text = dt.Rows.Count.ToString()
            Else
                lbMsg.Text += "|" + ks.strErrMsg
            End If
        Next
        'Update Campaign referenced times
        dbUtil.dbExecuteNoQuery("MY", String.Format("update KM_SEARCH_TMP_DETAIL set referenced_times=(select COUNT(distinct a.CAMPAIGN_ROW_ID) from AONLINE_SALES_CAMPAIGN_SOURCES a where a.SOURCE_ID=KM_SEARCH_TMP_DETAIL.SOURCE_ID) where SEARCH_ROW_ID='{0}'", r.Item("ROW_ID")))
                                
        'If lbMsg.Text <> String.Empty Then Util.SendEmail("tc.chen@advantech.com.tw", "myadvantech@advantech.com", "Error KM search by " + User.Identity.Name, lbMsg.Text, False)
        src1.SelectParameters("SID").DefaultValue = r.Item("ROW_ID")
        srcResultTypes.SelectParameters("SID").DefaultValue = r.Item("ROW_ID")
        
        hdnRowId.Value = r.Item("ROW_ID").ToString
        
        Dim dtSource As DataTable = dbUtil.dbGetDataTable("MY", GetLitTypeSql())
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

    Protected Sub cbAllLitType_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
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

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            'Dim ed As AjaxControlToolkit.HTMLEditor.Editor = CType(e.Row.FindControl("RowEditor"), AjaxControlToolkit.HTMLEditor.Editor)
            'If ed.Content = String.Empty Then ed.Visible = False
        End If
    End Sub

    Protected Sub RowEditor_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim ed As AjaxControlToolkit.HTMLEditor.Editor = sender
        'Dim lnkBtn As LinkButton = ed.NamingContainer.FindControl("lnkRowShowEditor")
        'If ed.Content = String.Empty Then
        '    ed.Visible = False : lnkBtn.Visible = False
        'End If
       
    End Sub

    Protected Sub rblResultLitTypes_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If rblResultLitTypes.Items.Count > 0 Then
            rblResultLitTypes.Items(0).Selected = True
        End If
        rblResultLitTypes.Style.Add("display", "none")
    End Sub

    Protected Sub lnkRowShowEditor_Click(ByVal sender As Object, ByVal e As System.EventArgs)
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

    Protected Sub lnkClosePickCat_Click(ByVal sender As Object, ByVal e As System.EventArgs)
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

    Protected Sub lnkRowAddMail_Click(ByVal sender As Object, ByVal e As System.EventArgs)
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
        gvMyContents.DataBind() : upContent.Update()
        If TypeOf (CType(sender, ImageButton).NamingContainer) Is GridViewRow Then
            gv1.PageIndex = gv1.PageIndex
        End If
        'lnk.Enabled = False
        'If gvMyContents.Rows.Count > 0 Then PanelAddedContents.Visible = True
    End Sub

    
    Protected Sub gvMyContents_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If AOnlineUtil.AOnlineSalesCampaign.MyContentCartCount() > 0 Then
            PanelAddedContents.Visible = True
        Else
            PanelAddedContents.Visible = False
        End If
    End Sub

    Protected Sub gvMyContents_RowDeleted(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewDeletedEventArgs)
        If AOnlineUtil.AOnlineSalesCampaign.MyContentCartCount() > 0 Then
            PanelAddedContents.Visible = True
        Else
            PanelAddedContents.Visible = False
        End If
    End Sub

    Protected Sub tabc_ActiveTabChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        CreateTabs()
    End Sub
    
    Sub CreateTabs()
        tabc.Tabs.Clear()
        Dim dtSource As DataTable = dbUtil.dbGetDataTable("MY", GetLitTypeSql())
        If dtSource.Rows.Count > 0 Then
            tabc.Visible = True
            For Each row As DataRow In dtSource.Rows
                Dim tab As New TabPanel
                tab.HeaderText = row.Item("source_type").ToString + " (" + row.Item("source_count").ToString + ")"
                tab.Visible = True
                tabc.Tabs.Add(tab)
            Next
            hdnRows.Value = tabc.Tabs(tabc.ActiveTabIndex).HeaderText.Substring(tabc.Tabs(tabc.ActiveTabIndex).HeaderText.LastIndexOf("(") + 1).Replace(")", "")
        End If
        If tabc.Tabs.Count > 0 Then
            rblResultLitTypes.SelectedIndex = tabc.ActiveTabIndex
            tabc.Height = 100 + GetGVRows() * 140
            gv1.PageIndex = 0
        End If
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
    
    Protected Sub btnHotView_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        MultiView1.ActiveViewIndex = 1 'btnNewView.ImageUrl = "~/Images/New2.jpg" : btnHotView.ImageUrl = "~/Images/Hot.jpg" : btnSearchView.ImageUrl = "~/Images/SearchTab2.jpg"
    End Sub

    Protected Sub btnNewView_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        MultiView1.ActiveViewIndex = 0 'btnNewView.ImageUrl = "~/Images/New.jpg" : btnHotView.ImageUrl = "~/Images/Hot2.jpg" : btnSearchView.ImageUrl = "~/Images/SearchTab2.jpg"
    End Sub

    Protected Sub btnSearchView_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        MultiView1.ActiveViewIndex = 2 'btnNewView.ImageUrl = "~/Images/New2.jpg" : btnHotView.ImageUrl = "~/Images/Hot2.jpg" : btnSearchView.ImageUrl = "~/Images/SearchTab.jpg"
        CreateTabs()
    End Sub

    Protected Sub gvNew_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        'gvNew.PageIndex = e.NewPageIndex
        Dim dt As DataTable = GetNewContent(hdnNewType.Value)
        ' gvNew.DataSource = dt : gvNew.DataBind()
    End Sub

    Protected Sub gvHot_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        'gvHot.PageIndex = e.NewPageIndex
        Dim dt As DataTable = GetTopContent(hdnHotType.Value)
        'gvHot.DataSource = dt : gvHot.DataBind()
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As System.EventArgs)
        Dim dt As New DataTable
        If TypeOf sender Is Button Then
            dt = GetNewContent(IIf(CType(sender, Button).Text = "All", "", CType(sender, Button).Text))
        Else
            dt = GetNewContent(IIf(sender.ToString = "All", "", sender.ToString))
        End If
        
        ' gvNew.DataSource = dt : gvNew.DataBind()
        Dim dtC As DataTable = dt.Clone()
        Dim index As Integer = 0
        For Each row As DataRow In dt.Rows
            dtC.ImportRow(row)
            index += 1
            If index >= 10 Then Exit For
        Next
        rpNew.DataSource = dtC : rpNew.DataBind()
        If TypeOf sender Is Button Then hdnNewType.Value = CType(sender, Button).Text
    End Sub

    Protected Sub btnHot_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As New DataTable
        If TypeOf sender Is Button Then
            dt = GetTopContent(IIf(CType(sender, Button).Text = "All", "", CType(sender, Button).Text))
        Else
            dt = GetTopContent(IIf(sender.ToString = "All", "", sender.ToString))
        End If
        
        'gvHot.DataSource = dt : gvHot.DataBind()
        Dim dtC As DataTable = dt.Clone()
        Dim index As Integer = 0
        For Each row As DataRow In dt.Rows
            dtC.ImportRow(row)
            index += 1
            If index >= 10 Then Exit For
        Next
        rpHot.DataSource = dtC : rpHot.DataBind()
        If TypeOf sender Is Button Then hdnHotType.Value = CType(sender, Button).Text
    End Sub

    Protected Sub rblNewLang_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        btnNew_Click(hdnNewType.Value, e)
    End Sub

    Protected Sub rblHotLang_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        btnHot_Click(hdnHotType.Value, e)
    End Sub

    Protected Sub lblDesc_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim desc As String = System.Text.RegularExpressions.Regex.Replace(CType(sender, Label).Text, "<[^>]*>", String.Empty).Trim
        Dim lang As String = CType(CType(CType(sender, Label).NamingContainer, DataListItem).FindControl("hdSrcLang"), HiddenField).Value
        Dim PreLen As Integer = 300
        If lang = "TraditionalChinese" OrElse lang = "SimplifiedChinese" OrElse lang = "CHS" OrElse lang = "CHT" Then PreLen = 200
        
        If Len(desc) > PreLen Then
            CType(sender, Label).Text = desc.Substring(0, PreLen) + "<a href='" + CType(CType(CType(sender, Label).NamingContainer, DataListItem).FindControl("hdSrcOriUrl"), HiddenField).Value + "' target='_blank'> ...</a>"
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
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
        background:url("../Images/AOnline_tab_inactive1.jpg") repeat-x;
        padding-top:5px;
        height:19px;
    }
    .Tabs1 .ajax__tab_active .ajax__tab_inner
    {
            background:url("../Images/AOnline_tab_inactive_left1.jpg") no-repeat;
            padding-left:10px;
    }
    .Tabs1 .ajax__tab_active .ajax__tab_outer
    {
            background:url("../Images/AOnline_tab_inactive_right1.jpg") no-repeat right;
            padding-right:10px;
    }
    /*Tab Hover*/
    .Tabs1 .ajax__tab_hover .ajax__tab_tab
    {
        color: #595959;
        background:url("../Images/AOnline_tab_inactive1.jpg") repeat-x;
        padding-top:5px;
        height:19px;
    }
    .Tabs1 .ajax__tab_hover .ajax__tab_inner
    {
        background:url("../Images/AOnline_tab_inactive_left1.jpg") no-repeat;
            padding-left:10px;
    }
    .Tabs1 .ajax__tab_hover .ajax__tab_outer
    {
        background:url("../Images/AOnline_tab_inactive_right1.jpg") no-repeat right;
            padding-right:10px;
    }
    /*Tab Inactive*/
    .Tabs1 .ajax__tab_tab
    {
        color: #8B898A;
        background:url("../Images/AOnline_tab_active1.jpg") repeat-x;
        padding-top:5px;
        height:19px;
    }
    .Tabs1 .ajax__tab_inner
    {
        background:url("../Images/AOnline_tab_active_left1.jpg") no-repeat;
            padding-left:10px;
    }
    .Tabs1 .ajax__tab_outer
    {
        background:url("../Images/AOnline_tab_active_right1.jpg") no-repeat right;
            padding-right:10px;
    }
    .RowBottom
    {
        padding-bottom:2px;
        border-bottom: 2px #D5E4F5 solid;
        border-left: 0px #FFF solid;
        border-top: 0px #FFF solid;
        border-right: 0px #FFF solid;
    }
    .btnCss {
        background-color:#FF964A;
        color:#FFFFFF;
        -webkit-border-radius: 6px;
        -moz-border-radius: 6px;
        padding: 3px 5px 3px 5px;
        border-radius: 6px;
        background: #FFD399;
        background: -webkit-gradient(linear, 0 0, 0 bottom, from(#FFD399), to(#FF964A));
        background: -webkit-linear-gradient(#FFD399, #FF964A);
        background: -moz-linear-gradient(#FFD399, #FF964A);
        background: -ms-linear-gradient(#FFD399, #FF964A);
        background: -o-linear-gradient(#FFD399, #FF964A);
        background: linear-gradient(#FFD399, #FF964A);
    }
    .btnCss:hover{
        border:solid 2px #FF964A;
        CURSOR: hand;
        -webkit-border-radius: 6px;
        -moz-border-radius: 6px;
        padding: 3px 5px 3px 5px;
        border-radius: 6px;
        background: #FFD399;
        background: -webkit-gradient(linear, 0 0, 0 bottom, from(#FFD399), to(#FF964A));
        background: -webkit-linear-gradient(#FFD399, #FF964A);
        background: -moz-linear-gradient(#FFD399, #FF964A);
        background: -ms-linear-gradient(#FFD399, #FF964A);
        background: -o-linear-gradient(#FFD399, #FF964A);
        background: linear-gradient(#FFD399, #FF964A);
    }

    .btnCss:active{
        background-color:#FF964A;
        color:#FFF;
        -webkit-border-radius: 6px;
        -moz-border-radius: 6px;
        padding: 3px 5px 3px 5px;
        border-radius: 6px;
        background: #FFD399;
        background: -webkit-gradient(linear, 0 0, 0 bottom, from(#FFD399), to(#FF964A));
        background: -webkit-linear-gradient(#FFD399, #FF964A);
        background: -moz-linear-gradient(#FFD399, #FF964A);
        background: -ms-linear-gradient(#FFD399, #FF964A);
        background: -o-linear-gradient(#FFD399, #FF964A);
        background: linear-gradient(#FFD399, #FF964A);
    }
</style>
<script type="text/javascript">
    function ChangeTab(index) {
        switch (index) {
            case 0:
                document.getElementById("<%=btnNewView.ClientID %>").src = "../Images/New.jpg";
                document.getElementById("<%=btnHotView.ClientID %>").src = "../Images/Hot2.jpg";
                document.getElementById("<%=btnSearchView.ClientID %>").src = "../Images/SearchTab2.jpg";
                break;
            case 1:
                document.getElementById("<%=btnNewView.ClientID %>").src = "../Images/New2.jpg";
                document.getElementById("<%=btnHotView.ClientID %>").src = "../Images/Hot.jpg";
                document.getElementById("<%=btnSearchView.ClientID %>").src = "../Images/SearchTab2.jpg";
                break;
            case 2:
                document.getElementById("<%=btnNewView.ClientID %>").src = "../Images/New2.jpg";
                document.getElementById("<%=btnHotView.ClientID %>").src = "../Images/Hot2.jpg";
                document.getElementById("<%=btnSearchView.ClientID %>").src = "../Images/SearchTab.jpg";
                break;
        }
    }
</script>

    <table width="100%">
        <tr align="right"><td align="right"><%--<uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" />--%></td></tr>
    </table>
    <table width="100%" align="center" runat="server" id="tbTab" visible='false'>
        <tr>
            <td align="center">
                <table cellspacing="0" cellpadding="0">
                    <tr>
                        <td><asp:ImageButton runat="server" ID="btnNewView" ImageUrl="~/Images/New.jpg" OnClick="btnNewView_Click" OnClientClick="ChangeTab(0)" /></td>
                        <td><asp:ImageButton runat="server" ID="btnHotView" ImageUrl="~/Images/Hot2.jpg" OnClick="btnHotView_Click" OnClientClick="ChangeTab(1)" /></td>
                        <td><asp:ImageButton runat="server" ID="btnSearchView" ImageUrl="~/Images/SearchTab2.jpg" OnClick="btnSearchView_Click" OnClientClick="ChangeTab(2)" /></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <asp:UpdatePanel runat="server" ID="UpView" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:MultiView runat="server" ID="MultiView1" ActiveViewIndex="2">
                <asp:View runat="server" ID="ViewNew">
                
                    <table border="0" style="border-color:White">
                        <tr>
                            <td width="20"></td>
                            <td>
                                <div id="divContentNew" style="height:630px;width:910px;border:solid 1px #D5E4F5;overflow:auto">
                                <table width="100%" border="0" style="border-color:White">
                                    <tr>
                                        <td width="10%"></td>
                                        <td>
                                            <table border="0" style="border-color:White">
                                                <tr>
                                                    <th align="left">Language</th>
                                                    <td>
                                                        <asp:RadioButtonList runat="server" ID="rblNewLang" RepeatColumns="9" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblNewLang_SelectedIndexChanged">
                                                            <asp:ListItem Text="All" Value="All" Selected="True" />
                                                            <asp:ListItem Text="English" Value="ENU" />
                                                            <asp:ListItem Text="Traditional Chinese" Value="CHT" />
                                                            <asp:ListItem Text="Simplified Chinese" Value="CHS" />
                                                            <asp:ListItem Text="Korean" Value="KR" />
                                                            <asp:ListItem Text="Russian" Value="RUS" />
                                                            <asp:ListItem Text="Spanish" Value="ESP" />
                                                            <asp:ListItem Text="Japanese" Value="JP" />
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td width="10%"></td>
                                    </tr>
                                    <tr>
                                        <td width="10%"></td>
                                        <td align="center">
                                            <asp:ListView runat="server" ID="lvNew">
                                                <ItemTemplate>
                                                    <asp:Button runat="server" ID="btnNew" Text='<%#Eval("SOURCE_TYPE") %>' Font-Bold="true" CssClass="btnCss" OnClick="btnNew_Click" />
                                                </ItemTemplate>
                                            </asp:ListView>
                                            <asp:HiddenField runat="server" ID="hdnNewType" />
                                        </td>
                                        <td width="10%"></td>
                                    </tr>
                                </table>
                                <asp:DataList runat="server" ID="rpNew" RepeatColumns="2" RepeatDirection="Horizontal" ItemStyle-VerticalAlign="Top">
                                    <ItemTemplate>
                                        <br />
                                        <asp:HiddenField runat="server" ID="hdSrcApp" Value='<%#Eval("SOURCE_APP") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcID" Value='<%#Eval("SOURCE_ID") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcType" Value='<%#Eval("SOURCE_TYPE") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcTitle" Value='<%#Eval("NAME") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcOriUrl" Value='<%#Eval("URL") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcLang" Value='<%#Eval("LANG") %>' />
                                        <table Width="420" border="0" style="table-layout: fixed; padding-left:10px; vertical-align:text-top">
                                            <tr>
                                                <td width="100" rowspan="5" valign="top"><img alt="Thumbnail" width="100" src='../../Includes/ContentThumbnail.ashx?type=<%#Eval("SOURCE_APP")%>&contentid=<%#Eval("SOURCE_ID")%>' /></td>
                                                <th width="300" align="left" valign="top" style="color:Blue"><%# Eval("SOURCE_TYPE")%></th>
                                            </tr>
                                            <tr>
                                                <td width="300" align="left" valign="top"><a href='<%#ShowHideLink(Eval("URL")) %>' target="_blank" style="color:#E46C0A; font-family: sans-serif; font-size:small">
                                                        <%# Util.Highlight(Me.txtKey.Text, Eval("NAME"))%></a>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="300" align="left" valign="top">
                                                    <div id="SomeID" runat="server" style="width:280px;word-wrap:break-word" ><asp:Label runat="server" ID="lblDesc" Text='<%#Eval("DESCRIPTION")%>' OnDataBinding="lblDesc_DataBinding" /></div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="300" align="left" valign="top">
                                                    <i><font color="gray">[Last updated on <%#CDate(Eval("LAST_UPD_DATE")).ToString("yyyy/MM/dd")%>]</font></i>
                                                </td>
                                            </tr>
<%--                                            <tr>
                                                <td width="300" align="left" valign="top">
                                                    <asp:ImageButton ID="lnkRowAddMailNew" runat="server" ToolTip="Add to Mail" OnClick="lnkRowAddMail_Click" ImageUrl="~/Images/AddtoMail_Send.png" Style="vertical-align: middle" />
                                                    &nbsp;
                                                    <asp:ImageButton runat="server" ID="lnkRowAddContentNew" ToolTip="Add to My Content" ImageUrl="~/Images/AddtoMail_Merge.PNG" Style="vertical-align: middle" OnClick="lnkRowAddContent_Click" />
                                                </td>
                                            </tr>
--%>                                            <tr><td colspan="2" height="10"></td></tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:DataList>
                                </div>
                            </td>
                            <td width="20"></td>
                        </tr>
                    </table>
                </asp:View>
                <asp:View runat="server" ID="ViewHot">
                    <table border="0" style="border-color:White">
                        <tr>
                            <td width="20"></td>
                            <td>
                                <div id="divContentHot" style="height:630px;width:910px;border:solid 1px #D5E4F5;overflow:auto">
                                <table width="100%" border="0" style="border-color:White">
                                    <tr>
                                        <td width="10%"></td>
                                        <td>
                                            <table border="0" style="border-color:White">
                                                <tr>
                                                    <th align="left">Language</th>
                                                    <td>
                                                        <asp:RadioButtonList runat="server" ID="rblHotLang" RepeatColumns="9" RepeatDirection="Horizontal" AutoPostBack="true" OnSelectedIndexChanged="rblHotLang_SelectedIndexChanged">
                                                            <asp:ListItem Text="All" Value="All" Selected="True" />
                                                            <asp:ListItem Text="English" Value="ENU" />
                                                            <asp:ListItem Text="Traditional Chinese" Value="CHT" />
                                                            <asp:ListItem Text="Simplified Chinese" Value="CHS" />
                                                            <asp:ListItem Text="Korean" Value="KR" />
                                                            <asp:ListItem Text="Russian" Value="RUS" />
                                                            <asp:ListItem Text="Spanish" Value="ESP" />
                                                            <asp:ListItem Text="Japanese" Value="JP" />
                                                        </asp:RadioButtonList>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                        <td width="10%"></td>
                                    </tr>
                                    <tr>
                                        <td width="10%"></td>
                                        <td align="center">
                                            <asp:ListView runat="server" ID="lvHot">
                                                <ItemTemplate>
                                                    <asp:Button runat="server" ID="btnHot" Text='<%#Eval("SOURCE_TYPE") %>' Font-Bold="true" CssClass="btnCss" OnClick="btnHot_Click" />
                                                </ItemTemplate>
                                            </asp:ListView>
                                            <asp:HiddenField runat="server" ID="hdnHotType" />
                                        </td>
                                        <td width="10%"></td>
                                    </tr>
                                </table>
                                <asp:DataList runat="server" ID="rpHot" RepeatColumns="2" RepeatDirection="Horizontal" ItemStyle-VerticalAlign="Top">
                                    <ItemTemplate>
                                        <br />
                                        <asp:HiddenField runat="server" ID="hdSrcApp" Value='<%#Eval("SOURCE_APP") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcID" Value='<%#Eval("SOURCE_ID") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcType" Value='<%#Eval("SOURCE_TYPE") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcTitle" Value='<%#Eval("CONTENT_TITLE") %>' />
                                        <asp:HiddenField runat="server" ID="hdSrcOriUrl" Value='<%#Eval("ORIGINAL_URL") %>' />
                                        <table Width="420" border="0" style="table-layout: fixed; padding-left:10px">
                                            <tr>
                                                <td width="100" rowspan="5"><img width="100" src='../Includes/ContentThumbnail.ashx?type=<%#Eval("SOURCE_APP")%>&contentid=<%#Eval("SOURCE_ID")%>' /></td>
                                                <th align="left" valign="top" style="color:Blue"><%# Eval("SOURCE_TYPE")%></th>
                                            </tr>
                                            <tr>
                                                <td align="left" valign="top"><a href='<%#ShowHideLink(Eval("ORIGINAL_URL")) %>' target="_blank" style="color:#E46C0A; font-family: sans-serif; font-size:small">
                                                    <%# Util.Highlight(Me.txtKey.Text, Eval("CONTENT_TITLE"))%></a>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="left" valign="top">
                                                    <div id="SomeID" runat="server" style="width:280px;word-wrap:break-word" ><%#Eval("DESCRIPTION")%></div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="left" valign="top">
                                                    <i><font color="gray">[Referenced Times: </font><font color="red"><%# Eval("RefCounts")%></font><font color="gray">]</font></i>
                                                </td>
                                            </tr>
<%--                                            <tr>
                                                <td align="left" valign="top">
                                                    <asp:ImageButton ID="lnkRowAddMailHot" runat="server" ToolTip="Add to Mail" OnClick="lnkRowAddMail_Click" ImageUrl="~/Images/AddtoMail_Send.png" Style="vertical-align: middle" />
                                                    &nbsp;
                                                    <asp:ImageButton runat="server" ID="lnkRowAddContentHot" ToolTip="Add to My Content" ImageUrl="~/Images/AddtoMail_Merge.PNG" Style="vertical-align: middle" OnClick="lnkRowAddContent_Click" />
                                                </td>
                                            </tr>
--%>                                            <tr><td colspan="2" height="10"></td></tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:DataList>
                                </div>
                            </td>
                            <td width="20"></td>
                        </tr>
                    </table>
                </asp:View>
                <asp:View runat="server" ID="ViewSearch">
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
                                            <th align="left">Sector</th>
                                            <td>
                                                <asp:UpdatePanel runat="server" ID="upSector" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <table width="550" cellspacing="0" cellpadding="0" border="0">
                                                            <tr>
                                                                <td width="45" align="left" valign="middle"><asp:LinkButton runat="server" ID="btnPickSector" Text="Pick" OnClick="btnPickSector_Click" /></td>
                                                                <td width="5"></td>
                                                                <td width="500">
                                                                    <asp:Panel ID="Panel_Sector_Checked_List" Width="500px" Height="30px" runat="server" ScrollBars="Auto">
                                                                        <asp:Literal ID="Literal_Sector_Checked_List" runat="server"></asp:Literal>
                                                                    </asp:Panel>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                        <%--<uc1:CampaignCriteria runat="server" ID="ucSelectSector" FormType="Gridview" ConnectionStringName="MY" SqlSelect="select distinct SECTOR_NAME as text, SECTOR_NAME as value from AONLINE_SECTOR_CMSBU order by SECTOR_NAME" OnRaiseSelection="ucSelectSector_RaiseSelection" />--%>
                                                    </ContentTemplate>
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
                                                    <asp:ListItem Text="Korean" Value="KR" />
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


                                        <tr style="display:none">
                                            <th align="left">
                                                Tag
                                            </th>
                                            <td>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" ServiceMethod="GetTagKeywords"
                                                                TargetControlID="TextBox_TagKeyword1" MinimumPrefixLength="0" FirstRowSelected="true" CompletionInterval="200" />
                                                            <asp:TextBox ID="TextBox_TagKeyword1" runat="server" width="150"></asp:TextBox>
                                                        </td>
                                                        <td width="5"></td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender2" ServiceMethod="GetTagKeywords"
                                                                TargetControlID="TextBox_TagKeyword2" MinimumPrefixLength="1" FirstRowSelected="true" CompletionInterval="200" />
                                                            <asp:TextBox ID="TextBox_TagKeyword2" runat="server" width="150"></asp:TextBox>
                                                        </td>
                                                        <td width="5"></td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender3" ServiceMethod="GetTagKeywords"
                                                                TargetControlID="TextBox_TagKeyword3" MinimumPrefixLength="1" FirstRowSelected="true" CompletionInterval="200" />
                                                            <asp:TextBox ID="TextBox_TagKeyword3" runat="server" width="150"></asp:TextBox>
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
                                <ajaxToolkit:TabContainer runat="server" ID="tabc" AutoPostBack="true" CssClass="Tabs1" OnActiveTabChanged="tabc_ActiveTabChanged"></ajaxToolkit:TabContainer>
                                <asp:HiddenField runat="server" ID="hdnRowId" />
                                <asp:HiddenField runat="server" ID="hdnRows" />
                                <asp:RadioButtonList runat="server" ID="rblResultLitTypes" RepeatColumns="7" RepeatDirection="Horizontal"
                                    Font-Size="Small" RepeatLayout="Table" AutoPostBack="true" DataSourceID="srcResultTypes"
                                    DataTextField="SOURCE_TYPE" DataValueField="SOURCE_TYPE" OnDataBound="rblResultLitTypes_DataBound" />
                                <asp:SqlDataSource runat="server" ID="srcResultTypes" ConnectionString="<%$ConnectionStrings:MY %>"
                                    SelectCommand="select distinct SOURCE_APP+' - '+SOURCE_TYPE as APP_TYPE, SOURCE_TYPE from KM_SEARCH_TMP_DETAIL where SEARCH_ROW_ID=@SID order by SOURCE_TYPE">
                                    <SelectParameters>
                                        <asp:Parameter ConvertEmptyStringToNull="false" Name="SID" />
                                    </SelectParameters>
                                </asp:SqlDataSource>
                                <asp:UpdatePanel runat="server" ID="upGv" UpdateMode="Conditional">
                                    <ContentTemplate>
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
                                                                <td width="12"><img src=".././Images/Aonline_icon.jpg" /></td>
                                                                <td align="left"><a href='<%#ShowHideLink(Eval("ORIGINAL_URL")) %>' target="_blank" style="color:#E46C0A; font-family: sans-serif; font-size:small">
                                                                        <%# Util.Highlight(Me.txtKey.Text, Eval("NAME"))%></a>
<%--                                                                    &nbsp;
                                                                    <asp:ImageButton ID="lnkRowAddMail" runat="server" ToolTip="Add to Mail" OnClick="lnkRowAddMail_Click" ImageUrl="~/Images/AddtoMail_Send.png" Style="vertical-align: middle" />
                                                                    &nbsp;
                                                                    <asp:ImageButton runat="server" ID="lnkRowAddContent" ToolTip="Add to My Content" ImageUrl="~/Images/AddtoMail_Merge.PNG" Style="vertical-align: middle" OnClick="lnkRowAddContent_Click" />
--%>                                                                </td>
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
                                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>"
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
                                    </ContentTemplate>
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
                                            OnClick="lnkClosePickCat_Click" Font-Bold="true" Font-Size="Large" />
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
                </asp:View>
            </asp:MultiView>
            <asp:UpdatePanel runat="server" ID="upContent" UpdateMode="Conditional">
                <ContentTemplate>
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
                                                    <asp:SqlDataSource runat="server" ID="srcMyContents" ConnectionString="<%$ConnectionStrings:MY %>"
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
            </asp:UpdatePanel>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnNewView" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnHotView" EventName="Click" />
            <asp:AsyncPostBackTrigger ControlID="btnSearchView" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
