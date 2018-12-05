<%@ Page Language="VB" %>
<%@ Register TagPrefix="adl" Namespace="clsAdxInheritsTreeView.nms3view" Assembly="clsAdxInheritsTreeView" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">    
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            OrderUtilities.SetSessionOrgForCbomEditor(Session("user_id"))
        End If
        If Not Page.IsPostBack Then
            If Not IsNothing(Request("UID")) AndAlso Request("UID") <> "" Then
                Dim ITEM As DataTable = dbUtil.dbGetDataTable("B2B", "SELECT * FROM CBOM_CATALOG_CATEGORY WHERE UID='" & Request("UID") & "'")
                If ITEM.Rows.Count > 0 Then
                    Me.BTOItemTb.Text = ITEM.Rows(0).Item("Category_id").ToString
                End If
            ElseIf Not IsNothing(Request("BTOItem")) AndAlso Request("BTOItem") <> "" Then
                Me.BTOItemTb.Text = Request("BTOItem")
            Else
                Exit Sub
            End If
            
          
            If Me.BTOItemTb.Text = "" Then Exit Sub
            'Dim dt As DataTable = Util.GetQBOMSql(Me.BTOItemTb.Text, Session("org").ToString.ToUpper)
            Dim dt As DataTable = Util.GetQBOMSql(Me.BTOItemTb.Text, Left(Session("org_id").ToString.ToUpper, 2))
            'OrderUtilities.showDT(dt)
            If dt Is Nothing Then Exit Sub
            Me.BuildCBOMTree(Me.tv1, dt)
        End If
    End Sub
    
    Sub BuildCBOMTree(ByRef t As AdxTreeView, ByVal dt As DataTable)

        t.Nodes.Clear()
        Dim RootN As New AdxTreeNode
        RootN.Text = Me.BTOItemTb.Text
        RootN.Value = Me.BTOItemTb.Text
        RootN.xNodeType = ENumNodeType.root
        RootN.xSeqNo = 0
        RootN.ImageUrl = "../Images/eConfig_Icons_Advantech/display.gif"
        t.Nodes.Add(RootN)
        
        Dim catDt As New DataTable, compDt As New DataTable
        catDt = dt.Copy()
        compDt = dt.Copy()
        catDt.DefaultView.RowFilter = "category_type='Category'"
        catDt.DefaultView.Sort = "seq_no asc"
        catDt = catDt.DefaultView.ToTable()
        compDt.DefaultView.RowFilter = "category_type='Component'"
        compDt.DefaultView.Sort = "seq_no asc"
        compDt = compDt.DefaultView.ToTable()
        
        For i As Integer = 0 To catDt.Rows.Count - 1
            
            Dim cn As New AdxTreeNode
            cn.xSeqNo = CDbl(catDt.Rows(i).Item("seq_no"))
            cn.Text = catDt.Rows(i).Item("configuration_rule").ToString() & " " & _
                      cn.xSeqNo.ToString() & " " & _
                      catDt.Rows(i).Item("category_id").ToString()
            
            cn.Value = catDt.Rows(i).Item("category_id").ToString()
            cn.xNodeType = ENumNodeType.category
            cn.xConfigRuleType = catDt.Rows(i).Item("configuration_rule").ToString()
            cn.ImageUrl = "../Images/eConfig_Icons_Advantech/chassis_adv.gif"
            
            RootN.ChildNodes.Add(cn)
            Dim subCompDt As New DataTable
            subCompDt = compDt.Copy()
            subCompDt.DefaultView.RowFilter = "parent_category_id='" & _
            catDt.Rows(i).Item("category_id").ToString() & "'"
            subCompDt = subCompDt.DefaultView.ToTable()
            
            For j As Integer = 0 To subCompDt.Rows.Count - 1
                
                Dim n As New AdxTreeNode
                n.Text = subCompDt.Rows(j).Item("seq_no") & " " & subCompDt.Rows(j).Item("category_id").ToString()
                n.Value = subCompDt.Rows(j).Item("category_id").ToString()
                n.xNodeType = ENumNodeType.component
                n.xSeqNo = CDbl(subCompDt.Rows(j).Item("seq_no"))
                n.ImageUrl = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                n.xConfigRuleType = subCompDt.Rows(j).Item("configuration_rule").ToString()
                cn.ChildNodes.Add(n)
                
            Next
            
        Next
        
        If catDt.Rows.Count = 0 Then
            
            For i As Integer = 0 To compDt.Rows.Count - 1
                
                Dim compN As New AdxTreeNode
                compN.Text = compDt.Rows(i).Item("seq_no") & " " & compDt.Rows(i).Item("category_id")
                compN.Value = compDt.Rows(i).Item("category_id")
                compN.xNodeType = ENumNodeType.component
                compN.xSeqNo = CDbl(compDt.Rows(i).Item("seq_no"))
                compN.ImageUrl = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                compN.xConfigRuleType = compDt.Rows(i).Item("configuration_rule").ToString()
                RootN.ChildNodes.Add(compN)
                
            Next
            
        End If
        
        If Me.tv1.Nodes.Count > 0 Then Me.tv1.Nodes(0).Select()
        CType(Me.tv1.Nodes(0), AdxTreeNode).SortChildNode()
        't.ExpandAll()
        
    End Sub
    
    Sub OnSelectedItemChanged(ByVal s As Object, ByVal e As System.EventArgs) Handles tv1.SelectedNodeChanged
     
        Dim sn As AdxTreeNode = CType(Me.tv1.SelectedNode, AdxTreeNode)
        Me.AppendSubNodes(sn)
        sn.Expand()
        'Clear field text
        If CType(Me.tv1.SelectedNode, AdxTreeNode).xNodeType = ENumNodeType.category Then
            Me.CatNameTb.Text = "" : Me.CatDesc.Text = "" : Me.CatSeqNo.Text = "0" : Me.CatCreatedByTb.Text = ""
        Else
            Me.CompNameTb.Text = "" : Me.CompDesc.Text = "" : Me.CompSeqNo.Text = "0" : Me.CompCreatedBy.Text = ""
        End If
        
        'Dim tempSql As String = _
        '" select category_id, IsNull(category_desc,'') as category_desc, IsNull(seq_no,0) as seq_no," & _
        '" IsNull(configuration_rule,'') as configuration_rule, IsNull(show_hide,1) as show_hide, " & _
        '" IsNull(not_expand_category,'') as not_expand_category " & _
        '" from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and category_id='" & sn.Value & "' "
        Dim tempSql As String = _
        " select category_id, IsNull(category_desc,'') as category_desc, IsNull(seq_no,0) as seq_no," & _
        " IsNull(configuration_rule,'') as configuration_rule, IsNull(show_hide,1) as show_hide, " & _
        " IsNull(not_expand_category,'') as not_expand_category " & _
        " from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & sn.Value & "' "
        
        If sn.Depth > 0 Then
            tempSql &= " and parent_category_id='" & sn.Parent.Value & "' "
        End If
        'Response.Write(tempSql)
        Dim itemDt As DataTable = dbUtil.dbGetDataTable("B2B", tempSql)
        
        If itemDt Is Nothing Then Exit Sub
        If itemDt.Rows.Count = 0 Then Exit Sub
        Dim iName As String = "", iDesc As String = "", iSeqNo As String = "", iConfigRule As String = ""
        Dim iShowHide As Integer = 0
        
        iName = itemDt.Rows(0).Item("category_id").ToString()
        iDesc = itemDt.Rows(0).Item("category_desc").ToString()
        iSeqNo = itemDt.Rows(0).Item("seq_no").ToString()
        iSeqNo = CType(Me.tv1.SelectedNode, AdxTreeNode).xSeqNo.ToString()
        iConfigRule = itemDt.Rows(0).Item("configuration_rule").ToString().ToUpper().Trim()
        iShowHide = CInt(itemDt.Rows(0).Item("show_hide"))
        
        Select Case (sn.xNodeType)
        
            Case (ENumNodeType.root)
                Me.MultiView1.ActiveViewIndex = 0
                Me.CatNameTb.Text = iName : Me.CatDesc.Text = iDesc : Me.CatSeqNo.Text = iSeqNo
            Case (ENumNodeType.category)
                Me.MultiView1.ActiveViewIndex = 0
                Me.CatNameTb.Text = iName : Me.CatDesc.Text = iDesc : Me.CatSeqNo.Text = iSeqNo
                If iConfigRule.Equals("REQUIRED") Then
                    Me.CatRequiredRadio.SelectedIndex = 0
                Else
                    Me.CatRequiredRadio.SelectedIndex = 1
                End If
            Case (ENumNodeType.component)
                Me.MultiView1.ActiveViewIndex = 1
                Me.CompNameTb.Text = iName : Me.CompDesc.Text = iDesc : Me.CompSeqNo.Text = iSeqNo
                If iConfigRule.Equals("DEFAULT") Then
                    Me.CompDefaultRadio.SelectedIndex = 0
                Else
                    Me.CompDefaultRadio.SelectedIndex = 1
                End If
                If iShowHide = 1 Then
                    Me.CompShowHideRadio.SelectedIndex = 0
                Else
                    Me.CompShowHideRadio.SelectedIndex = 1
                End If
                If Not itemDt.Rows(0).Item("not_expand_category").ToString().Equals("") Then
                    If Me.tv1.SelectedNode.Depth > 0 Then
                        If itemDt.Rows(0).Item("not_expand_category").ToString().Equals( _
                        Me.tv1.SelectedNode.Parent.Value) Then
                            Me.CompNotExpandRadio.SelectedIndex = 0
                        Else
                            Me.CompNotExpandRadio.SelectedIndex = 1
                        End If
                    Else
                        Me.CompNotExpandRadio.SelectedIndex = 1
                    End If
                Else
                    Me.CompNotExpandRadio.SelectedIndex = 1
                End If
            
        End Select
        
        SetFocus2(sn)
        
    End Sub
    
    Private Sub SetFocus2(ByVal t As AdxTreeNode)
       
        Dim expandedLines As Integer = 1
        expandedLines += GetParentExpandedLines(t)
        'Response.Write(expandedLines)
        expandedLines = expandedLines * 20 + 200
        Dim Script As String
        Script = "<script language='javascript'>"
        Script += "window.scroll(0, " & expandedLines & ");"
        'Script += "alert('ya!');"
        Script += "<"
        Script += "/"
        Script += "script>"
        Page.ClientScript.RegisterStartupScript(Type.GetType("System.String"), "setFocus", Script)
        
    End Sub
    
    Function GetParentExpandedLines(ByVal t As TreeNode) As Integer

        'If Not (t.Parent Is Nothing) Then
        Try
            If t.Parent.Expanded Then
                If t.Parent.ChildNodes.IndexOf(t) > 0 Then
                    Dim tempLines = 0
                    For i As Integer = 0 To t.Parent.ChildNodes.IndexOf(t) - 1
                        tempLines += GetChildExpandedLines(t.Parent.ChildNodes.Item(i))
                    Next
                    Return tempLines + GetParentExpandedLines(t.Parent)
                Else
                    Return 1 + GetParentExpandedLines(t.Parent)
                End If
            Else
                Return GetParentExpandedLines(t.Parent)
            End If
        Catch ex As Exception
            Return 0
        End Try
        'Else
        'Return 0
        'End If
    End Function
    
    Function GetChildExpandedLines(ByVal t As TreeNode) As Integer

        If t.ChildNodes.Count > 0 Then
            
            If t.Expanded.HasValue Then
                If t.Expanded.Value = False Then
                    Return 1
                Else
                    Dim tempLines As Integer = 1
                    For i As Integer = 0 To t.ChildNodes.Count - 1
                        tempLines += GetChildExpandedLines(t.ChildNodes.Item(i))
                    Next
                    Return tempLines
                End If
            Else
                Return 1
            End If
            
        Else
            Return 1
        End If
        
    End Function
    
    Sub AppendSubNodes(ByRef Sel_Node As AdxTreeNode)

        If Sel_Node.ChildNodes.Count > 0 Then Exit Sub
        'Dim dt As DataTable = Util.GetQBOMSql(Sel_Node.Value, Session("org").ToString.ToUpper)
        Dim dt As DataTable = Util.GetQBOMSql(Sel_Node.Value, Left(Session("org_id").ToString.ToUpper, 2))
        If dt Is Nothing Then Exit Sub
        Dim catDt As New DataTable, compDt As New DataTable
        catDt = dt.Copy()
        compDt = dt.Copy()
        catDt.DefaultView.RowFilter = "category_type='Category'"
        catDt.DefaultView.Sort = "seq_no asc"
        catDt = catDt.DefaultView.ToTable()
        compDt.DefaultView.RowFilter = "category_type='Component'"
        compDt.DefaultView.Sort = "seq_no asc"
        compDt = compDt.DefaultView.ToTable()
        
        For i As Integer = 0 To catDt.Rows.Count - 1
            
            Dim cn As New AdxTreeNode
            cn.Text = catDt.Rows(i).Item("configuration_rule").ToString() & " " & _
                      catDt.Rows(i).Item("seq_no") & " " & catDt.Rows(i).Item("category_id").ToString()
            
            cn.Value = catDt.Rows(i).Item("category_id").ToString()
            cn.xNodeType = ENumNodeType.category
            cn.xSeqNo = CDbl(catDt.Rows(i).Item("seq_no"))
            cn.xConfigRuleType = catDt.Rows(i).Item("configuration_rule").ToString()
            cn.ImageUrl = "../Images/eConfig_Icons_Advantech/chassis_adv.gif"
            'cn.xConfigRuleType=
            Sel_Node.ChildNodes.Add(cn)
            Dim subCompDt As New DataTable
            subCompDt = compDt.Copy()
            subCompDt.DefaultView.RowFilter = "parent_category_id='" & _
            catDt.Rows(i).Item("category_id").ToString() & "'"
            subCompDt = subCompDt.DefaultView.ToTable()
            
            For j As Integer = 0 To subCompDt.Rows.Count - 1
                
                Dim n As New AdxTreeNode
                n.Text = subCompDt.Rows(j).Item("seq_no") & " " & subCompDt.Rows(j).Item("category_id").ToString()
                n.Value = subCompDt.Rows(j).Item("category_id").ToString()
                n.xSeqNo = CDbl(subCompDt.Rows(j).Item("seq_no"))
                n.xNodeType = ENumNodeType.component
                n.xConfigRuleType = subCompDt.Rows(j).Item("configuration_rule").ToString()
                n.ImageUrl = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                cn.ChildNodes.Add(n)
                
            Next
            
        Next
        
        If catDt.Rows.Count = 0 Then
            
            For i As Integer = 0 To compDt.Rows.Count - 1
                
                Dim compN As New AdxTreeNode
                compN.Text = compDt.Rows(i).Item("category_id") & " " & compDt.Rows(i).Item("seq_no")
                compN.Value = compDt.Rows(i).Item("category_id")
                compN.xNodeType = ENumNodeType.component
                compN.xSeqNo = CDbl(compDt.Rows(i).Item("seq_no"))
                compN.ImageUrl = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                compN.xConfigRuleType = compDt.Rows(i).Item("configuration_rule").ToString()
                Sel_Node.ChildNodes.Add(compN)
                
            Next
            
        End If
        
    End Sub
    
    Sub OnMenuItemClick(ByVal s As Object, ByVal e As System.Web.UI.WebControls.MenuEventArgs) _
    Handles Menu1.MenuItemClick

        Me.MultiView1.ActiveViewIndex = Menu1.SelectedValue
    End Sub
    
    Sub OnEditButtonClick(ByVal s As Object, ByVal e As System.EventArgs) _
    Handles CatAdd.Click, CatDel.Click, CatUpdate.Click, CompAdd.Click, CompDel.Click, CompUpdate.Click

        If Me.tv1.SelectedNode Is Nothing Then Exit Sub
        If Me.tv1.SelectedNode.Value.Trim().Equals("") Then Exit Sub
        
        Dim sCatId As String = Me.CatNameTb.Text.Trim()
        Dim sCatDesc As String = Me.CatDesc.Text.Trim()
        Dim sCatRef As String = Me.txtRefCategory.Text.Trim()
        Dim sCatCopyFlag As Boolean = False
        If Me.chkCat.Checked Then
            sCatCopyFlag = True
        End If
        Dim sCatSeqNo As Integer = 0
        Dim sCatRequired As String = ""
        Dim sCompId As String = Me.CompNameTb.Text.Trim()
        Dim sCompDesc As String = Me.CompDesc.Text.Trim()
        Dim sCompRef As String = Me.txtRefCategory1.Text.Trim()
        Dim sCompCopyFlag As Boolean = False
        If Me.chkComp.Checked Then
            sCompCopyFlag = True
        End If
        Dim sCompSeqNo As String = 0
        Dim sCompDefault As String = ""
        Dim sCompShowHide As String = ""
        Dim sCompNotExpand As String = ""
        
        'Dim selectedNodeLevel As Integer = Me.tv1.SelectedNode.Depth
        'Response.Write("depth:" & selectedNodeLevel)
        
        Dim b As Button = CType(s, Button)
        
        Select Case (b.ID.ToLower())
            
            Case "catadd", "catdel", "catupdate"
                If sCatId = "" Then Exit Sub
                If IsNumeric(Me.CatSeqNo.Text) Then
                    sCatSeqNo = System.Math.Abs(CInt(Me.CatSeqNo.Text))
                End If
                If Me.CatRequiredRadio.SelectedValue.ToString().Equals("1") Then
                    sCatRequired = "REQUIRED"
                End If
                
            Case "compadd", "compdel", "compupdate"
                If sCompId = "" Then Exit Sub
                If IsNumeric(Me.CompSeqNo.Text) Then
                    sCompSeqNo = System.Math.Abs(CInt(Me.CompSeqNo.Text))
                End If
                If Me.CompDefaultRadio.SelectedValue.ToString().Equals("1") Then
                    sCompDefault = "DEFAULT"
                Else
                    sCompDefault = ""
                End If
                If Me.CompShowHideRadio.SelectedValue.ToString().Equals("1") Then
                    sCompShowHide = "1"
                Else
                    sCompShowHide = "0"
                End If
                If Me.CompNotExpandRadio.SelectedValue.ToString().Equals("1") Then
                    sCompNotExpand = "y"
                End If
            Case Else
                Exit Sub
            
        End Select
        
        Select Case (b.ID.ToLower())
            
            Case "catadd"
                If Me.MultiView1.ActiveViewIndex <> 0 Then Exit Sub
                If Me.CatNameTb.Text.Trim() = "" Then Exit Sub
                Dim n As New AdxTreeNode
                n.Text = Me.CatSeqNo.Text & " " & Me.CatNameTb.Text.Trim() : n.Value = Me.CatNameTb.Text.Trim()
                n.ImageUrl = "../Images/eConfig_Icons_Advantech/chassis_adv.gif"
                n.xNodeType = ENumNodeType.category
                n.xSeqNo = 0
                If sCatRequired.Equals("REQUIRED") Then
                    n.Text = "REQUIRED " & n.Text
                    n.xConfigRuleType = "REQUIRED"
                End If
                
                If IsNumeric(Me.CatSeqNo.Text) Then n.xSeqNo = CDbl(Me.CatSeqNo.Text)
               
                For i As Integer = 0 To Me.tv1.SelectedNode.ChildNodes.Count - 1
                    If CType(Me.tv1.SelectedNode.ChildNodes(i), AdxTreeNode).xSeqNo >= sCatSeqNo Then
                        CType(Me.tv1.SelectedNode.ChildNodes(i), AdxTreeNode).xSeqNo += 1
                        Me.tv1.SelectedNode.ChildNodes(i).Text = _
                        CType(Me.tv1.SelectedNode.ChildNodes(i), AdxTreeNode).xConfigRuleType & " " & _
                        CType(Me.tv1.SelectedNode.ChildNodes(i), AdxTreeNode).xSeqNo & " " & _
                        Me.tv1.SelectedNode.ChildNodes(i).Value
                    End If
                Next
                
                Me.tv1.SelectedNode.ChildNodes.Add(n)
                Me.AppendSubNodes(n)
                n.Select()
                SetFocus2(n)
                Me.tv1.SelectedNode.Expand()
                Dim dt As DataTable = Nothing
                'dt = dbUtil.dbGetDataTable("B2B", _
                '" select IsNull(category_id,'') as category_id, IsNull(category_desc,'') as category_desc, " & _
                '" IsNull(seq_no,0) as seq_no, IsNull(created_by,'') as created_by " & _
                '" from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and category_id='" & Me.CatNameTb.Text.Trim() & "'")
                dt = dbUtil.dbGetDataTable("B2B", _
                " select IsNull(category_id,'') as category_id, IsNull(category_desc,'') as category_desc, " & _
                " IsNull(seq_no,0) as seq_no, IsNull(created_by,'') as created_by " & _
                " from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & Me.CatNameTb.Text.Trim() & "'")

                
                
                If dt.Rows.Count > 0 Then
                    Me.CatNameTb.Text = dt.Rows(0).Item("category_id").ToString()
                    Me.CatDesc.Text = dt.Rows(0).Item("category_desc").ToString()
                    Me.CatSeqNo.Text = dt.Rows(0).Item("seq_no").ToString()
                    Me.CatCreatedByTb.Text = dt.Rows(0).Item("created_by").ToString()
                End If
                
                'Dim addSql As String = _
                '" INSERT INTO CBOM_CATALOG_CATEGORY " & _
                '" (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, " & _
                '" PARENT_CATEGORY_ID, CATEGORY_DESC, " & _
                '" EXTENDED_DESC, CREATED_BY, SEQ_NO, " & _
                '" CONFIGURATION_RULE,org,uid) " & _
                '" VALUES ('" & sCatId & "', '" & sCatId & "', 'Category', " & _
                '" '" & Me.tv1.SelectedNode.Parent.Value & "', '" & sCatDesc & "', '" & _
                'Me.tv1.Nodes(0).Value & "', '" & Session("user_id") & "', " & _
                'sCatSeqNo & ", '" & sCatRequired & "','" & Session("org").ToString.ToUpper & "',newid()) "
                
                Dim addSql As String = _
                " INSERT INTO CBOM_CATALOG_CATEGORY " & _
                " (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, " & _
                " PARENT_CATEGORY_ID, CATEGORY_DESC, " & _
                " EXTENDED_DESC, CREATED_BY, SEQ_NO, " & _
                " CONFIGURATION_RULE,org,uid) " & _
                " VALUES ('" & sCatId & "', '" & sCatId & "', 'Category', " & _
                " '" & Me.tv1.SelectedNode.Parent.Value & "', '" & sCatDesc & "', '" & _
                Me.tv1.Nodes(0).Value & "', '" & Session("user_id") & "', " & _
                sCatSeqNo & ", '" & sCatRequired & "','" & Left(Session("org_id").ToString.ToUpper, 2) & "',newid()) "

                
                Me.DebugSql.Text = addSql
                dbUtil.dbGetDataTable("B2B", addSql)
                
                'Dim UpdateSeqSql As String = _
                '" update cbom_catalog_category set seq_no = (seq_no+1) " & _
                '" where org='" & Session("org").ToString.ToUpper & "' and parent_category_id='" & Me.tv1.SelectedNode.Parent.Value & "' " & _
                '" and seq_no=" & sCatSeqNo & " and category_type='Category' and category_id<>'" & sCatId & "'"

                Dim UpdateSeqSql As String = _
                " update cbom_catalog_category set seq_no = (seq_no+1) " & _
                " where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and parent_category_id='" & Me.tv1.SelectedNode.Parent.Value & "' " & _
                " and seq_no=" & sCatSeqNo & " and category_type='Category' and category_id<>'" & sCatId & "'"

                dbUtil.dbGetDataTable("B2B", UpdateSeqSql)
                
                If n.Depth > 0 Then
                    CType(n.Parent, AdxTreeNode).SortChildNode()
                End If
                
                For i As Integer = 0 To n.Parent.ChildNodes.Count - 1
                    
                    n.Parent.ChildNodes(i).Text = _
                    CType(n.Parent.ChildNodes(i), AdxTreeNode).xConfigRuleType & _
                    " " & CType(n.Parent.ChildNodes(i), AdxTreeNode).xSeqNo.ToString() & _
                    " " & n.Parent.ChildNodes(i).Value
                    'Response.Write(CType(n.Parent.ChildNodes(i), AdxTreeNode).xConfigRuleType & "<br/>")
                    
                Next
                If sCatRef <> "" And sCatCopyFlag = True Then
                    'OrderUtilities.CopyCategory(sCatRef, sCatId, Session("Org").ToString.ToUpper)
                    OrderUtilities.CopyCategory(sCatRef, sCatId, Left(Session("Org_id").ToString.ToUpper, 2))
                End If
            Case "catdel"
                If Me.MultiView1.ActiveViewIndex <> 0 Then Exit Sub
                If Me.CatNameTb.Text.Trim() = "" Then Exit Sub
                
                'Dim pCountDt As DataTable = dbUtil.dbGetDataTable("B2B", _
                '" select count(parent_category_id) as parent_count from cbom_catalog_category " & _
                '" where org='" & Session("org").ToString.ToUpper & "' and category_id='" & Me.tv1.SelectedValue & "' ")
                Dim pCountDt As DataTable = dbUtil.dbGetDataTable("B2B", _
                " select count(parent_category_id) as parent_count from cbom_catalog_category " & _
                " where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & Me.tv1.SelectedValue & "' ")

                
                Dim delSql As String = ""
                If 1 = 1 Then
                    'delSql = " delete from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and category_id='" & Me.tv1.SelectedValue & "' "
                    delSql = " delete from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & Me.tv1.SelectedValue & "' "
                    If Me.tv1.SelectedValue <> Me.BTOItemTb.Text Then
                        delSql &= " and parent_category_id='" & Me.tv1.SelectedNode.Parent.Value & "' "
                    End If
                Else
                    'delSql = " update cbom_catalog_category set parent_category_id='EMPTY' " & _
                    '         " where org='" & Session("org").ToString.ToUpper & "' and category_id='" & Me.tv1.SelectedValue & "' "
                    delSql = " update cbom_catalog_category set parent_category_id='EMPTY' " & _
                             " where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & Me.tv1.SelectedValue & "' "

                End If
                
                
                
                If Me.tv1.SelectedNode.Depth > 0 Then
                    Dim parentN As AdxTreeNode = Me.tv1.SelectedNode.Parent
                    Me.tv1.SelectedNode.Parent.ChildNodes.Remove(Me.tv1.SelectedNode)
                    parentN.Select()
                    SetFocus2(parentN)
                Else
                    Me.tv1.Nodes.Remove(Me.tv1.SelectedNode)
                End If
                Me.DebugSql.Text = delSql
                'Response.Write(pCountDt) : Response.End()
                dbUtil.dbGetDataTable("B2B", delSql)
                
            Case "catupdate"
                If Me.MultiView1.ActiveViewIndex <> 0 Then Exit Sub
                If Me.CatNameTb.Text.Trim() = "" Then Exit Sub
                If Me.CatNameTb.Text <> Me.tv1.SelectedValue Then Exit Sub
                'Dim updateSql As String = _
                '" UPDATE CBOM_CATALOG_CATEGORY " & _
                '" SET " & _
                '" CATEGORY_DESC ='" & sCatDesc & "', CREATED_BY ='" & Session("user_id") & "', " & _
                '" SEQ_NO = " & sCatSeqNo & ", CONFIGURATION_RULE ='" & sCatRequired & "' " & _
                '" WHERE org='" & Session("org").ToString.ToUpper & "' and CATEGORY_ID = '" & Me.CatNameTb.Text.Trim() & "' "

                Dim updateSql As String = _
                " UPDATE CBOM_CATALOG_CATEGORY " & _
                " SET " & _
                " CATEGORY_DESC ='" & sCatDesc & "', CREATED_BY ='" & Session("user_id") & "', " & _
                " SEQ_NO = " & sCatSeqNo & ", CONFIGURATION_RULE ='" & sCatRequired & "' " & _
                " WHERE org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and CATEGORY_ID = '" & Me.CatNameTb.Text.Trim() & "' "

                CType(Me.tv1.SelectedNode, AdxTreeNode).xSeqNo = 0
                If IsNumeric(Me.CatSeqNo.Text) Then
                    CType(Me.tv1.SelectedNode, AdxTreeNode).xSeqNo = CDbl(Me.CatSeqNo.Text)
                End If
                CType(Me.tv1.SelectedNode, AdxTreeNode).Text = Me.CatSeqNo.Text & " " & Me.CatNameTb.Text.Trim()
                CType(Me.tv1.SelectedNode, AdxTreeNode).xAva = sCatRequired
                If Me.tv1.SelectedNode.Depth > 0 Then
                    updateSql &= " and parent_category_id='" & Me.tv1.SelectedNode.Parent.Value & "'"
                End If
                Me.DebugSql.Text = updateSql
                dbUtil.dbGetDataTable("B2B", updateSql)
                If Me.tv1.SelectedNode.Depth > 0 Then
                    CType(Me.tv1.SelectedNode.Parent, AdxTreeNode).SortChildNode()
                End If
                
            Case "compadd"
                If Me.MultiView1.ActiveViewIndex <> 1 Then Exit Sub
                If Me.CompNameTb.Text.Trim() = "" Then Exit Sub
                Dim n As New AdxTreeNode
                n.Text = Me.CompSeqNo.Text & " " & Me.CompNameTb.Text.Trim() : n.Value = Me.CompNameTb.Text.Trim()
                n.ImageUrl = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                n.xNodeType = ENumNodeType.component
                n.xSeqNo = 0
                If IsNumeric(Me.CompSeqNo.Text) Then n.xSeqNo = CDbl(Me.CompSeqNo.Text)
                
                Me.tv1.SelectedNode.ChildNodes.Add(n)
                Me.AppendSubNodes(n)
                Dim dt As DataTable = Nothing
                'dt = dbUtil.dbGetDataTable("B2B", _
                '" select IsNull(category_id,'') as category_id, IsNull(category_desc,'') as category_desc, " & _
                '" IsNull(seq_no,0) as seq_no, IsNull(created_by,'') as created_by " & _
                '" from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and category_id='" & Me.CompNameTb.Text.Trim() & "'")
                
                dt = dbUtil.dbGetDataTable("B2B", _
                " select IsNull(category_id,'') as category_id, IsNull(category_desc,'') as category_desc, " & _
                " IsNull(seq_no,0) as seq_no, IsNull(created_by,'') as created_by " & _
                " from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & Me.CompNameTb.Text.Trim() & "'")

                
                If dt.Rows.Count > 0 Then
                    Me.CompNameTb.Text = dt.Rows(0).Item("category_id").ToString()
                    Me.CompDesc.Text = dt.Rows(0).Item("category_desc").ToString()
                    Me.CompSeqNo.Text = dt.Rows(0).Item("seq_no").ToString()
                    Me.CompCreatedBy.Text = dt.Rows(0).Item("created_by").ToString()
                End If
                
                If sCompNotExpand.Equals("y") Then sCompNotExpand = Me.tv1.SelectedNode.Value
                
                'Dim addSql As String = _
                '" INSERT INTO CBOM_CATALOG_CATEGORY " & _
                '" (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, " & _
                '" PARENT_CATEGORY_ID, CATEGORY_DESC, " & _
                '" EXTENDED_DESC, CREATED_BY, SEQ_NO, " & _
                '" CONFIGURATION_RULE, NOT_EXPAND_CATEGORY, SHOW_HIDE,ORG,UID) " & _
                '" VALUES ('" & sCompId & "', '" & sCompId & "', 'Component', " & _
                '" '" & Me.tv1.SelectedNode.Value & "', '" & sCompDesc & "', '" & _
                'Me.tv1.Nodes(0).Value & "', '" & Session("user_id") & "', " & _
                'sCompSeqNo & ", '" & sCompDefault & "', '" & sCompNotExpand & "', '" & sCompShowHide & "','" & Session("org").ToString.ToUpper & "',NEWID()) "

                Dim addSql As String = _
                " INSERT INTO CBOM_CATALOG_CATEGORY " & _
                " (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, " & _
                " PARENT_CATEGORY_ID, CATEGORY_DESC, " & _
                " EXTENDED_DESC, CREATED_BY, SEQ_NO, " & _
                " CONFIGURATION_RULE, NOT_EXPAND_CATEGORY, SHOW_HIDE,ORG,UID) " & _
                " VALUES ('" & sCompId & "', '" & sCompId & "', 'Component', " & _
                " '" & Me.tv1.SelectedNode.Value & "', '" & sCompDesc & "', '" & _
                Me.tv1.Nodes(0).Value & "', '" & Session("user_id") & "', " & _
                sCompSeqNo & ", '" & sCompDefault & "', '" & sCompNotExpand & "', '" & sCompShowHide & "','" & Left(Session("org_id").ToString.ToUpper, 2) & "',NEWID()) "


                Me.DebugSql.Text = addSql
                dbUtil.dbGetDataTable("B2B", addSql)
                n.Select()
                SetFocus2(n)
                If n.Depth > 0 Then
                    CType(n.Parent, AdxTreeNode).SortChildNode()
                End If
                If sCompRef <> "" And sCompCopyFlag = True Then
                    'OrderUtilities.CopyCategory(sCompRef, sCompId, Session("Org").ToString.ToUpper)
                    OrderUtilities.CopyCategory(sCompRef, sCompId, Left(Session("Org_id").ToString.ToUpper, 2))
                End If
            Case "compdel"
                If Me.MultiView1.ActiveViewIndex <> 1 Then Exit Sub
                If Me.CompNameTb.Text.Trim() = "" Then Exit Sub
                'Dim delSql As String = _
                '"delete from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and category_id='" & Me.tv1.SelectedValue & "' "
                Dim delSql As String = _
                "delete from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & Me.tv1.SelectedValue & "' "


                If Me.tv1.SelectedValue <> Me.BTOItemTb.Text Then
                    delSql &= "and parent_category_id='" & Me.tv1.SelectedNode.Parent.Value & "'"
                End If
                
                If Me.tv1.SelectedNode.Depth > 0 Then
                    Dim parentN As AdxTreeNode = Me.tv1.SelectedNode.Parent
                    Me.tv1.SelectedNode.Parent.ChildNodes.Remove(Me.tv1.SelectedNode)
                    parentN.Select()
                    SetFocus2(parentN)
                Else
                    Me.tv1.Nodes.Remove(Me.tv1.SelectedNode)
                End If
                Me.DebugSql.Text = delSql
                dbUtil.dbGetDataTable("B2B", delSql)
                
            Case "compupdate"
                If Me.MultiView1.ActiveViewIndex <> 1 Then Exit Sub
                If Me.CompNameTb.Text.Trim() = "" Then Exit Sub
                If Me.CompNameTb.Text <> Me.tv1.SelectedValue Then Exit Sub
                CType(Me.tv1.SelectedNode, AdxTreeNode).xSeqNo = 0
                If IsNumeric(Me.CompSeqNo.Text) Then
                    CType(Me.tv1.SelectedNode, AdxTreeNode).xSeqNo = CDbl(Me.CompSeqNo.Text)
                End If
                'Dim updateSql As String = _
                '" UPDATE CBOM_CATALOG_CATEGORY " & _
                '" SET " & _
                '" CATEGORY_DESC ='" & sCompDesc & "', CREATED_BY ='" & Session("user_id") & "', " & _
                '" SEQ_NO = " & sCompSeqNo & ", CONFIGURATION_RULE ='" & sCompDefault & "', " & _
                '" NOT_EXPAND_CATEGORY = '" & sCompNotExpand & "', SHOW_HIDE= '" & sCompShowHide & "' " & _
                '" WHERE org='" & Session("org").ToString.ToUpper & "' and CATEGORY_ID = '" & Me.CompNameTb.Text.Trim() & "' "

                Dim updateSql As String = _
                " UPDATE CBOM_CATALOG_CATEGORY " & _
                " SET " & _
                " CATEGORY_DESC ='" & sCompDesc & "', CREATED_BY ='" & Session("user_id") & "', " & _
                " SEQ_NO = " & sCompSeqNo & ", CONFIGURATION_RULE ='" & sCompDefault & "', " & _
                " NOT_EXPAND_CATEGORY = '" & sCompNotExpand & "', SHOW_HIDE= '" & sCompShowHide & "' " & _
                " WHERE org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and CATEGORY_ID = '" & Me.CompNameTb.Text.Trim() & "' "


                If Me.tv1.SelectedNode.Depth > 0 Then
                    updateSql &= " and parent_category_id='" & Me.tv1.SelectedNode.Parent.Value & "'"
                End If
                Me.DebugSql.Text = updateSql
                dbUtil.dbGetDataTable("B2B", updateSql)
                Me.tv1.SelectedNode.Text = CType(Me.tv1.SelectedNode, AdxTreeNode).xSeqNo & _
                " " & Me.CompNameTb.Text.Trim()
                If Me.tv1.SelectedNode.Depth > 0 Then
                    CType(Me.tv1.SelectedNode.Parent, AdxTreeNode).SortChildNode()
                End If
            
        End Select
        
    End Sub
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>

<body>
    <form id="form1" runat="server">
    <div>
        <asp:ScriptManager runat="server">
        </asp:ScriptManager>
    <asp:TextBox ID="BTOItemTb" Text="" runat="server" Visible="false"></asp:TextBox>
    <asp:Button ID="RefreshBtn" runat="server" Text="Refresh" Visible="false" />
    <asp:Label ID="Label1" runat="server" Font-Bold="True" Font-Size="Large" Text="Full Scale CBOM Editor"></asp:Label>
    <asp:Table ID="Table1" runat="server">
        <asp:TableRow>
            <asp:TableCell VerticalAlign="Top">
                <adl:AdxTreeView ID="tv1" runat="server" ExpandDepth="1" ImageSet="XPFileExplorer"
                    NodeIndent="15" Height="100%" Width="228px">
                    <ParentNodeStyle Font-Bold="False" />
                    <HoverNodeStyle Font-Underline="True" ForeColor="#6666AA" />
                    <SelectedNodeStyle BackColor="#B5B5B5" Font-Underline="False" HorizontalPadding="0px"
                        VerticalPadding="0px" />
                    <NodeStyle Font-Names="Tahoma" Font-Size="8pt" ForeColor="Black" HorizontalPadding="2px"
                        NodeSpacing="0px" VerticalPadding="2px" />
                </adl:AdxTreeView>
            </asp:TableCell>
        </asp:TableRow>
    </asp:Table>
    <a href='http://<%=Request.ServerVariables("HTTP_HOST") %>/Order/Configurator_Test.aspx?BTOItem=<%=me.BTOItemTb.text %>&Qty=1'
        target="_blank">Check this CBOM in eConfigurator </a>
      <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
         TargetControlID="Panel1" VerticalSide="top" HorizontalSide="right" VerticalOffset="50" HorizontalOffset="50"
          ScrollEffectDuration="1">
        </ajaxToolkit:AlwaysVisibleControlExtender>
    <asp:Panel ID= "Panel1" runat="server">
        <asp:Table ID="Table2" runat="server" BackColor="#E0E0E0" BorderStyle="Solid">
            <asp:TableRow ID="TableRow1" runat="server">
                <asp:TableCell ID="TableCell1" VerticalAlign="Top" runat="server">
                    <asp:Menu ID="Menu1" Orientation="Horizontal" runat="server" BackColor="#F7F6F3"
                        DynamicHorizontalOffset="2" Font-Names="Verdana" Font-Size="0.8em" ForeColor="#7C6F57"
                        StaticSubMenuIndent="10px">
                        <StaticMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                        <DynamicHoverStyle BackColor="#7C6F57" ForeColor="White" />
                        <DynamicMenuStyle BackColor="#F7F6F3" />
                        <StaticSelectedStyle BackColor="#5D7B9D" />
                        <DynamicSelectedStyle BackColor="#5D7B9D" />
                        <DynamicMenuItemStyle HorizontalPadding="5px" VerticalPadding="2px" />
                        <StaticHoverStyle BackColor="#7C6F57" ForeColor="White" />
                        <Items>
                            <asp:MenuItem Text="Edit Category" Value="0"></asp:MenuItem>
                            <asp:MenuItem Text="Edit Component" Value="1"></asp:MenuItem>
                        </Items>
                    </asp:Menu>
                    <asp:MultiView ID="MultiView1" runat="server" ActiveViewIndex="0">
                        <asp:View ID="CatView" runat="server">
                            <asp:Table ID="CatEditTable" runat="server">
                                <asp:TableRow ID="TableRow2" runat="server">
                                    <asp:TableCell ID="TableCell2" Text="Category View" runat="server"></asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow3" runat="server">
                                    <asp:TableCell ID="TableCell3" runat="server">
                                        <asp:Button ID="CatAdd" runat="server" Text="CatAdd" />
                                        &nbsp;
                                        <asp:Button ID="CatUpdate" runat="server" Text="CatUpdate" />
                                        &nbsp;
                                        <asp:Button ID="CatDel" runat="server" Text="CatDelete" />
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow4" runat="server">
                                    <asp:TableCell ID="TableCell4" Text="CATEGORY_NAME:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell5" runat="server">
                                        <asp:TextBox ID="CatNameTb" runat="server" Width="250px"></asp:TextBox>
                                        <input type="button" value="Pick Existed Category" onclick="PickCatWin();" />
                                    </asp:TableCell>
                                </asp:TableRow>
                                 <asp:TableRow ID="TableRowCopy" runat="server">
                                    <asp:TableCell ID="TableCellCopy" Text="" runat="server"><asp:CheckBox ID="chkCat" runat="server"></asp:CheckBox></asp:TableCell>
                                    <asp:TableCell ID="TableCellCopy1" runat="server">
                                        Copy From: <asp:TextBox ID="txtRefCategory" runat="server" Width="250px"></asp:TextBox>
                                        
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow5" runat="server">
                                    <asp:TableCell ID="TableCell6" Text="DESCRIPTION:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell7" runat="server">
                                        <asp:TextBox ID="CatDesc" runat="server" Width="400px"></asp:TextBox>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow6" runat="server">
                                    <asp:TableCell ID="TableCell8" Text="SEQ_NO:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell9" runat="server">
                                        <asp:TextBox ID="CatSeqNo" runat="server"></asp:TextBox>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow7" runat="server">
                                    <asp:TableCell ID="TableCell10" Text="CONFIGURATION TYPE:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell11" runat="server">
                                        <asp:RadioButtonList ID="CatRequiredRadio" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Required" Value="1"></asp:ListItem>
                                            <asp:ListItem Text="Not Required" Value="0" Selected="True"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow8" runat="server">
                                    <asp:TableCell ID="TableCell12" Text="CREATED BY:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell13" runat="server">
                                        <asp:TextBox Width="200px" ID="CatCreatedByTb" Text="tc.chen@advantech.com.tw" runat="server"></asp:TextBox>
                                    </asp:TableCell>
                                </asp:TableRow>
                            </asp:Table>
                        </asp:View>
                        <asp:View ID="CompView" runat="server">
                            <asp:Table ID="CompEditTable" runat="server">
                                <asp:TableRow ID="TableRow9" runat="server">
                                    <asp:TableCell ID="TableCell14" Text="Component View" runat="server"></asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow10" runat="server">
                                    <asp:TableCell ID="TableCell15" runat="server">
                                        <asp:Button ID="CompAdd" runat="server" Text="CompAdd" />
                                        &nbsp;
                                        <asp:Button ID="CompUpdate" runat="server" Text="CompUpdate" />
                                        &nbsp;
                                        <asp:Button ID="CompDel" runat="server" Text="CompDelete" />
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow11" runat="server">
                                    <asp:TableCell ID="TableCell16" Text="Component Name" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell17" runat="server">
                                        <asp:TextBox ID="CompNameTb" runat="server"></asp:TextBox>
                                        <input type="button" value="Pick Existed Component" onclick="PickCompWin();" />
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRowCopy2" runat="server">
                                    <asp:TableCell ID="TableCellCopy2" Text="" runat="server"><asp:CheckBox ID = "chkComp" runat="server"></asp:CheckBox></asp:TableCell>
                                    <asp:TableCell ID="TableCellCopy21" runat="server">
                                        Copy From: <asp:TextBox ID="txtRefCategory1" runat="server" Width="250px"></asp:TextBox>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow12" runat="server">
                                    <asp:TableCell ID="TableCell18" Text="DESCRIPTION" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell19" runat="server">
                                        <asp:TextBox ID="CompDesc" runat="server" Width="400px"></asp:TextBox>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow13" runat="server">
                                    <asp:TableCell ID="TableCell20" Text="SEQ_NO:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell21" runat="server">
                                        <asp:TextBox ID="CompSeqNo" runat="server"></asp:TextBox>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow14" runat="server">
                                    <asp:TableCell ID="TableCell22" Text="DEFAULT:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell23" runat="server">
                                        <asp:RadioButtonList ID="CompDefaultRadio" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                                            <asp:ListItem Text="No" Value="0" Selected="True"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow15" runat="server">
                                    <asp:TableCell ID="TableCell24" Text="SHOW HIDE:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell25" runat="server">
                                        <asp:RadioButtonList ID="CompShowHideRadio" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Show" Selected="True" Value="1"></asp:ListItem>
                                            <asp:ListItem Text="Hide" Value="0"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow16" runat="server">
                                    <asp:TableCell ID="TableCell26" Text="NOT EXPAND:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell27" runat="server">
                                        <asp:RadioButtonList ID="CompNotExpandRadio" runat="server" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Expand" Value="1" Selected="True"></asp:ListItem>
                                            <asp:ListItem Text="Not Expand" Value="0"></asp:ListItem>
                                        </asp:RadioButtonList>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow ID="TableRow17" runat="server">
                                    <asp:TableCell ID="TableCell28" Text="CREATED BY:" runat="server"></asp:TableCell>
                                    <asp:TableCell ID="TableCell29" runat="server">
                                        <asp:TextBox Width="200px" ID="CompCreatedBy" runat="server" Text="tc.chen@advantech.com.tw"></asp:TextBox>
                                    </asp:TableCell>
                                </asp:TableRow>
                            </asp:Table>
                        </asp:View>
                    </asp:MultiView>
                </asp:TableCell>
            </asp:TableRow>
        </asp:Table>
   </asp:Panel>
    &nbsp;&nbsp;
    <asp:TextBox ID="DebugSql" TextMode="MultiLine" runat="server" Height="65px" Width="826px"
        Visible="False"></asp:TextBox>
    <script language="javascript" type="text/javascript">

function PickCompWin()
	{
	    var aa = document.getElementById('ctl00__main_CompNameTb')
	    var part_no = aa.value
	    //alert (part_no)
	    //var Url = "http://<%=Request.servervariables("HTTP_HOST") %>/Order/PickComponent.aspx?Type=QueryPrice&Element=CompNameTb&Element2=CompDesc"
	    Url="../Order/PickComponent.aspx?Type=CBOMEDITOR&Element=CompNameTb&Element2=CompDesc"
	    Url=Url + "&PartNo=" + part_no
		window.open(Url, "pop","height=570,width=520,scrollbars=yes");
	}	

function PickCatWin()
	{
	    var aa = document.getElementById('ctl00__main_CatNameTb')
	    var part_no = aa.value
	    //alert (part_no)
	    var Url = "http://<%=Request.servervariables("HTTP_HOST") %>/Order/PickCategory.aspx?Type=QueryPrice&Element=CatNameTb&Element2=CatDesc"
	    Url=Url + "&PartNo=" + part_no
		window.open(Url, "pop","height=570,width=520,scrollbars=yes");
	}	
	
    </script>
    </div>
    </form>
</body>
</html>
