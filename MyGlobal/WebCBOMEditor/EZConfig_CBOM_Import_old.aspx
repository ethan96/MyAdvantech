<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="EZ Configurator CBOM Import" %>

<script runat="server">
    Dim BTOItem As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write("on Developing..."):Response.End()
        If Session("user_id").ToString.ToLower = "nada.liu@advantech.com.cn" Or _
            Session("user_id").ToString.ToLower.IndexOf("tam.tran") = 0 Then
            Me.btnDelete.Visible = True
        End If
        Me.lblMessage.Text = ""
        BTOItem = Me.txtBTOName.Text.Trim
    End Sub
    
    Private Sub BuildUpTree(ByVal BTOItem As String)
        
        
        
        Dim CbomId As String = "", BtoItemName As String = ""
        'Dim CbomTB As DataTable = SysUtil.dbGetDataTable("172.21.1.15", "AdvStore", "estoreuser2", "1qa2ws3ed", "SELECT a.Con_Item_virtual_part,b.cbomid FROM dbo.es_config_item_new a " & _
        '            "INNER JOIN dbo.es_cbom b ON  a.Con_Item_AutoID = b.system_id " & _
        '            "where b.storeid='ctos_eu' and a.Con_Item_Number='" & BTOItem & "'")
        Dim CbomTB As DataTable = dbUtil.dbGetDataTable("AdvStore", "SELECT a.Con_Item_virtual_part,b.cbomid FROM dbo.es_config_item_new a " & _
                    "INNER JOIN dbo.es_cbom b ON  a.Con_Item_AutoID = b.system_id " & _
                    "where b.storeid='aeu' and a.Con_Item_Number='" & BTOItem & "'")
        If CbomTB.Rows.Count > 0 Then
            CbomId = CbomTB.Rows(0).Item("cbomid")
            BtoItemName = CbomTB.Rows(0).Item("Con_Item_virtual_part")
        End If
        Me.tv1.Nodes.Clear()
        Dim rootNode As New TreeNode(BtoItemName, BtoItemName)
        rootNode.ImageUrl = "../Images/eConfig_Icons_Advantech/display.gif"
        tv1.Nodes.Add(rootNode)
            
        Dim strSql As String = "select s.nodeid,s.node_name,s.node_desc,c.seq,c.defaults,isnull(c.show,'YES') as show " & _
            "from es_cbomtree c inner join es_sharebomtree s " & _
            "on c.nodeid=s.nodeid where cbomid='" & CbomId & "' and s.node_type='category' order by c.seq"

        Dim CatDt As DataTable = dbUtil.dbGetDataTable("AdvStore", strSql)
        
        For i As Integer = 0 To CatDt.Rows.Count - 1
            
            Dim CatNode As New TreeNode(CatDt.Rows(i).Item("node_name"), CatDt.Rows(i).Item("node_name"))
            If CatDt.Rows(i).Item("show").ToString.ToUpper = "SHOW=NO" Then
                CatNode.Text &= " (" & CatDt.Rows(i).Item("show") & ")"
            End If
            CatNode.ImageUrl = "../Images/eConfig_Icons_Advantech/chassis_adv.gif"
            rootNode.ChildNodes.Add(CatNode)
            
            Dim node_parentid As String = CatDt.Rows(i).Item("nodeid")
            strSql = " select c.localPartno,s.node_name,c.seq,c.defaults,isnull(c.show,'YES') as show " & _
                     "from es_cbomtree c inner join es_sharebomtree s on c.nodeid=s.nodeid " & _
                     "where cbomid='" & CbomId & "' and s.node_type='list' and node_parentid ='" & node_parentid & "' order by c.seq"
                      
            Dim CompDt As DataTable = dbUtil.dbGetDataTable("AdvStore", strSql)
            For j As Integer = 0 To CompDt.Rows.Count - 1
                Dim CompNode As New TreeNode(CompDt.Rows(j).Item("localPartno"), CompDt.Rows(j).Item("localPartno"))
                If CompDt.Rows(j).Item("localPartno").ToString().Trim().Equals("") Then
                    CompNode.Text = "No Need"
                End If
                If CInt(CompDt.Rows(j).Item("defaults")) = 1 Then
                    CompNode.Text &= " (Default)"
                End If
                CompNode.ImageUrl = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                CatNode.ChildNodes.Add(CompNode)
            Next
        Next
        Me.tv1.ExpandAll()
    End Sub
    
    Private Sub ImportCBOM(ByVal BTOItem As String)
        
        'If BTOItem.Equals("") Then Exit Sub
        
       
        
        Dim sc As New StringCollection
        Dim strSql As String = "SELECT b.cbomid,b.cbom_name,a.con_item_desc,a.con_item_virtual_part FROM dbo.es_config_item_new a " & _
                    "INNER JOIN dbo.es_cbom b ON  a.Con_Item_AutoID = b.system_id " & _
                    "where b.storeid='aeu' and a.Con_Item_Number='" & BTOItem & "' and b.state<>'deleted'"
        'strSql = "select top 1 * from dbo.es_config_item_new"
        Dim TbBTO As New DataTable
        TbBTO = dbUtil.dbGetDataTable("AdvStore", strSql)
        
        Dim cbomid As String = "", parent_category_id As String = "", B2CItem As String = "", con_desc As String = ""
        If TbBTO.Rows.Count > 0 Then
            'Response.Write("yes") : Response.End()
            cbomid = TbBTO.Rows(0).Item("cbomid") : If cbomid = "" Then Exit Sub
            parent_category_id = TbBTO.Rows(0).Item("con_item_virtual_part")
            B2CItem = BTOItem 'TbBTO.Rows(0).Item("cbom_name")
            con_desc = TbBTO.Rows(0).Item("con_item_desc")
            
            'If BTOItem.ToLower <> B2CItem.ToLower Then
            '    Me.lblMessage.Text = "the synced item is not idential with virtual item."
            '    Exit Sub
            'End If
            
            If dbUtil.dbGetDataTable("b2b", "select category_id from cbom_catalog_category where category_id='" & parent_category_id & "'").Rows.Count > 0 Then
                Me.lblMessage.Text = "already exists in database for this item."
                Exit Sub
            End If
            
            If Right(B2CItem, 4).ToUpper <> "-BTO" AndAlso _
                dbUtil.dbGetDataTable("b2b", "select part_no from product " & _
                "where part_no='" & parent_category_id & "'").Rows.Count = 0 Then
                Me.lblMessage.Text = "Please maintain con_item_virtual_part." : Exit Sub
            End If
            strSql = "insert into cbom_catalog(catalog_id,catalog_name,catalog_type,catalog_desc," & _
                     "created,created_by,last_updated_by) values('" & B2CItem & "','" & _
                                                      parent_category_id & "','" & _
                                                      "Pre-Configuration" & " ','" & _
                                                      con_desc & "'," & _
                                                      "getdate()" & ",'" & _
                                                      "From CTOS" & "','" & B2CItem & "')"
            sc.Add(strSql)
            strSql = "insert into cbom_catalog_category(category_id,category_name,category_type,parent_category_id,category_desc,show_hide,EZ_FLAG) " & _
                     "values('" & parent_category_id & "','" & _
                                  parent_category_id & "','" & _
                                  "Component" & "','" & _
                                  "Root" & "','" & _
                                  TbBTO.Rows(0).Item("con_item_desc") & "'," & _
                                  "1,'2')"
            sc.Add(strSql)
        Else
            Me.lblMessage.Text = "There's no data in CTOS"
            Exit Sub
        End If
            
        strSql = "select s.nodeid,s.node_name,s.node_desc,c.seq,c.defaults,isnull(c.show,'YES') as show " & _
            "from es_cbomtree c inner join es_sharebomtree s " & _
            "on c.nodeid=s.nodeid where cbomid='" & cbomid & "' and s.node_type='category' order by c.seq"

        Dim CatDt As DataTable = dbUtil.dbGetDataTable("AdvStore", strSql)
        
        For i As Integer = 0 To CatDt.Rows.Count - 1
            Dim child_parent_category_id As String = CatDt.Rows(i).Item("node_name") & " For " & parent_category_id
            strSql = "insert into cbom_catalog_category(category_id,category_name,category_type,parent_category_id,category_desc," & _
                     "seq_no,default_flag,configuration_rule,show_hide,EZ_FLAG) " & _
                     "values('" & child_parent_category_id & "','" & _
                                  child_parent_category_id & "','" & _
                                  "Category" & "','" & _
                                  parent_category_id & "','" & _
                                  CatDt.Rows(i).Item("node_desc") & "'," & _
                                  CatDt.Rows(i).Item("seq") & ",'','REQUIRED',1,'2')"
            sc.Add(strSql)
            
            Dim node_parentid As String = CatDt.Rows(i).Item("nodeid")
            strSql = " select c.localPartno,s.node_name,isnull(c.seq,1) as seq,c.defaults,isnull(c.show,'YES') as show " & _
                     "from es_cbomtree c inner join es_sharebomtree s on c.nodeid=s.nodeid " & _
                     "where cbomid='" & cbomid & "' and s.node_type='list' and node_parentid ='" & node_parentid & "' order by c.seq"
                      
            Dim CompDt As DataTable = dbUtil.dbGetDataTable("AdvStore", strSql)
            For j As Integer = 0 To CompDt.Rows.Count - 1
                Dim show As String = "1", defaults As String = "0", configuration_rule As String = ""
                If CompDt.Rows(j).Item("show").ToString.ToUpper = "NO" Then
                    show = "0"
                End If
                If CompDt.Rows(j).Item("defaults").ToString = "1" Then
                    defaults = "1" : configuration_rule = "DEFAULT"
                End If
               
                Dim PartNo As String = CompDt.Rows(j).Item("localPartno")
                If PartNo.Equals("") Then PartNo = "No Need"
                strSql = "insert into cbom_catalog_category(category_id,category_name,category_type,parent_category_id,category_desc," & _
                     "seq_no,default_flag,configuration_rule,show_hide,EZ_FLAG) " & _
                     "values('" & PartNo & "','" & _
                                  PartNo & "','" & _
                                  "Component" & "','" & _
                                  child_parent_category_id & "','" & _
                                  CompDt.Rows(j).Item("node_name").ToString.Replace("'", "''") & "'," & _
                                  CompDt.Rows(j).Item("seq") & ",'" & defaults & "','" & configuration_rule & "'," & show & ",'2')"
                sc.Add(strSql)
            Next
        Next
        If sc.Count > 1 Then
            If Global_Inc.ExecuteSqls("B2B", sc) = 1 Then
                Me.lblMessage.Text = "Sync Sucessfully!"
            End If
        End If
    End Sub
    
    Protected Sub Button1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        If BTOItem.Equals("") Then Exit Sub
        Me.BuildUpTree(BTOItem)

    End Sub

    Protected Sub Button2_Click(ByVal sender As Object, ByVal e As System.EventArgs)
              
        If BTOItem.Equals("") Then Exit Sub
        Me.ImportCBOM(BTOItem)
        
    End Sub
    
    Protected Sub btnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strSql As String = "", Bto_item As String = ""
        Dim dt As New DataTable
        Dim DtCatalog As New DataTable
        DtCatalog = dbUtil.dbGetDataTable("B2B", "select catalog_name from cbom_catalog where catalog_id='" & _
                    BTOItem & "' and catalog_type='Pre-Configuration' and created_by='from CTOS'")
        If DtCatalog.Rows.Count > 0 Then
            Bto_item = DtCatalog.Rows(0).Item("catalog_name")
        Else
            Me.lblMessage.Text = "Can't find this item,can't delete."
            Exit Sub
        End If
        dt = dbUtil.dbGetDataTable("B2B", "select category_id from cbom_catalog_category where category_id='" & Bto_item & _
                        "' and parent_category_id='Root'")
        If dt.Rows.Count > 0 Then
            strSql = "delete from CBOM_CATALOG_CATEGORY where category_id='" & _
            Bto_item & "' or parent_category_id='" & _
            Bto_item & "' or parent_category_id like '%For " & Bto_item & "';"
            'Me.Global_inc1.dbDataReader("", "", strsql)
        End If
        strSql &= "delete from cbom_catalog where catalog_name='" & Bto_item & "' " & _
                "and catalog_type='Pre-Configuration' and created_by='from CTOS';"
        'Response.Write(strSql)
        dbUtil.dbExecuteNoQuery("B2B", strSql) : Me.lblMessage.Text = "delete sucesfully!"
        
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<table style="height:100%" cellpadding="0" cellspacing="0" width="100%" border="0">
            <tr valign="top">
                <td valign="top">
                   
                </td>                
            </tr>
            <tr valign="top">
                <td valign="top">
                    <asp:Label ID="Label1" runat="server" Text="CTOS Item Id"></asp:Label>
                    <asp:TextBox ID="txtBTOName" runat="server"></asp:TextBox>
                    <asp:Button ID="Button1" runat="server" Text="Query" OnClick="Button1_Click" />
                    <asp:Button ID="Button2" runat="server" Text="Import" OnClick="Button2_Click" />
                    &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                    <asp:Button ID="btnDelete" runat="server" OnClick="btnDelete_Click" Text="Delete"  Visible="False"/>
                    <asp:Label ID="lblMessage" runat="server" ForeColor="Red"></asp:Label></td>
            </tr>            
            <tr>
                <td valign="top">
                    <asp:TreeView runat="server" ID="tv1" ImageSet="XPFileExplorer" NodeIndent="15">
                        <ParentNodeStyle Font-Bold="False" />
                        <HoverNodeStyle Font-Underline="True" ForeColor="#6666AA" />
                        <SelectedNodeStyle BackColor="#B5B5B5" Font-Underline="False" HorizontalPadding="0px"
                            VerticalPadding="0px" />
                        <NodeStyle Font-Names="Tahoma" Font-Size="8pt" ForeColor="Black" HorizontalPadding="2px"
                            NodeSpacing="0px" VerticalPadding="2px" />
                        
                    </asp:TreeView>
                </td>       
            </tr>
            <tr>
                <td>
                    <asp:GridView runat="server" ID="gv1" />
                </td>
            </tr>
            <tr valign="bottom">
                <td valign="bottom">
                  
                </td>
            </tr>
        </table>  
</asp:Content>

