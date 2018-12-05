<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="EZ Configurator CBOM Import" %>

<script runat="server">
    Dim BTOItem As String = ""
    Dim EZ As String = "EZ-"
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id").ToString.ToLower = "tc.chen@advantech.com.tw" Or _
            Session("user_id").ToString.ToLower.IndexOf("tam.tran") = 0 Or _
            Session("user_id").ToString.ToLower.IndexOf("ming.zhao") = 0 Or _
            LCase(Session("USER_ID")) = "paul.tempelaars@advantech.eu" Or LCase(Session("USER_ID")) = "martijn.vosselman@advantech.eu" Or _
            Session("user_id").ToString.ToLower.IndexOf("nada.liu") = 0 Then
            Me.btnDelete.Visible = True
        End If
        Me.lblMessage.Text = ""
        BTOItem = Me.txtBTOName.Text.Trim
    End Sub
    Public Function GetSQL(ByVal WhereStr As String, ByVal disPlayPart As String) As String
        Dim sql As New System.Text.StringBuilder
        With sql
            .AppendLine(" SELECT     ")
            .AppendLine("  case  WHEN CTOSComponent.ComponentParentID IS NULL then CTOSComponent.ComponentName    + ' for EZ-' + Product.DisplayPartno   ")
            .AppendLine("  when CTOSComponent.Componenttype='list' then  isnull(CTOSComponentDetailpart.parts,'No Need')  ")
            .AppendLine("  else 'No Need' end as CATEGORY_ID,''  as CATEGORY_NAME,  ")
            .AppendLine("  case when  CTOSComponent.ComponentType='list' then 'Component' else CTOSComponent.ComponentType end as CATEGORY_TYPE ,  ")
            .AppendLine("  CASE WHEN CTOSComponent.ComponentParentID IS NULL  THEN 'EZ-'+Product.DisplayPartno ELSE CTOSComponent_1.ComponentName   + ' for EZ-' + Product.DisplayPartno  END AS PARENT_CATEGORY_ID,  ")
            .AppendLine("  '' as  CATALOG_ID,CTOSComponent.ComponentDesc as  CATEGORY_DESC,  ")
            .AppendLine("  '' AS DISPLAY_NAME ,'created_by_ming' as IMAGE_ID, '' AS EXTENDED_DESC ,getdate()as CREATED, 'EZ' AS created_by, getdate()as LAST_UPDATED ,'EZ' as last_updated_by,  ")
            .AppendLine("  CTOSBOM.Seq as SEQ_NO ,'' as publish_status,convert(char(1),CTOSBOM.Defaults) as DEFAULT_FLAG, ''as CONFIGURATION_RULE,'' as  NOT_EXPAND_CATEGORY,  ")
            .AppendLine("  CTOSBOM.Show AS show_hide,'2' AS EZ_FLAG,NEWID() as  UID , SUBSTRING ( Product_Ctos.StoreID , 2 , 2 ) AS  ORG  ")
            .AppendLine("  FROM Parts INNER JOIN  ")
            .AppendLine("  Product ON Parts.StoreID = Product.StoreID AND Parts.SProductID = Product.SProductID INNER JOIN  ")
            .AppendLine("  Product_Ctos ON Product.StoreID = Product_Ctos.StoreID AND Product.SProductID = Product_Ctos.SProductID INNER JOIN  ")
            .AppendLine("  CTOSBOM ON Product_Ctos.StoreID = CTOSBOM.StoreID AND Product_Ctos.SProductID = CTOSBOM.SProductID INNER JOIN  ")
            .AppendLine("  CTOSComponent ON CTOSBOM.ComponentID = CTOSComponent.ComponentID and CTOSBOM.StoreID = CTOSComponent.StoreID  ")
            .AppendLine("  left join  ")
            .AppendLine("               (SELECT t1.StoreID,t1.ComponentID  ")
            .AppendLine(" , parts=STUFF((SELECT '|'+ + dbo.[f_DuplicateSProductID](SProductID ,Qty)  ")
            .AppendLine("  FROM CTOSComponentDetail  t WHERE StoreID=t1.StoreID ")
            .AppendLine("  and ComponentID=t1.ComponentID  FOR XML PATH('')), 1, 1, '') ")
            .AppendLine(" FROM CTOSComponentDetail t1 ")
            .AppendLine(" GROUP BY t1.StoreID,t1.ComponentID  ")
            .AppendLine(" ) as CTOSComponentDetailpart on CTOSComponentDetailpart.StoreID=CTOSComponent.StoreID and CTOSComponentDetailpart.ComponentID=CTOSComponent.ComponentID  left JOIN   ")
            .AppendLine("  CTOSComponent AS CTOSComponent_1 ON CTOSComponent.ComponentParentID = CTOSComponent_1.ComponentID and  CTOSComponent.StoreID = CTOSComponent_1.StoreID  ")
            .AppendLine("  WHERE     (Parts.StoreID = 'aeu' ) AND (Product.Status <> 'INACTIVE_AUTO')   ")
            .AppendLine("  AND (Product.Status <> 'deleted') AND (Product.Status <> 'INACTIVE') and (CTOSBOM.Show = 1)  ")
            .AppendLine("  and Product.DisplayPartno='" & disPlayPart & "' ")
            .AppendLine("  union  ")
            .AppendLine("  SELECT     ")
            .AppendLine("  'EZ-'+Product.DisplayPartno as  CATEGORY_ID,'' as CATEGORY_NAME,  ")
            .AppendLine("  'Component' as CATEGORY_TYPE,'Root' AS PARENT_CATEGORY_ID,'' as  CATALOG_ID,Product.ProductDesc as  CATEGORY_DESC,  ")
            .AppendLine("  '' AS DISPLAY_NAME ,'created_by_ming' as IMAGE_ID, '' AS EXTENDED_DESC ,getdate()as CREATED, 'EZ' AS created_by, getdate()as LAST_UPDATED ,'EZ' as last_updated_by,  ")
            .AppendLine("  0 as SEQ_NO ,'' as publish_status,'' as DEFAULT_FLAG, ''as CONFIGURATION_RULE,'' as  NOT_EXPAND_CATEGORY,  ")
            .AppendLine("  1 AS show_hide,'2' AS EZ_FLAG,NEWID() AS UID,SUBSTRING ( Product_Ctos.StoreID , 2 , 2 ) as ORG  ")
            .AppendLine("  FROM   Parts INNER JOIN  ")
            .AppendLine("  Product ON Parts.StoreID = Product.StoreID AND Parts.SProductID = Product.SProductID INNER JOIN  ")
            .AppendLine("  Product_Ctos ON Product.StoreID = Product_Ctos.StoreID AND Product.SProductID = Product_Ctos.SProductID  ")
            .AppendLine("  where ( Parts.StoreID='aeu' )  ")
            .AppendLine("  and (Product.Status<>'INACTIVE_AUTO' and Product.Status<>'deleted' and Product.Status<>'INACTIVE')   ")

            
        
            '.AppendLine(" SELECT    ")
            '.AppendLine(" case  WHEN CTOSComponent.ComponentParentID IS NULL then CTOSComponent.ComponentName    + ' for EZ-' + Product.DisplayPartno  ")
            '.AppendLine(" when CTOSComponent.Componenttype='list' then  isnull([dbo].f_mergComponentSProductID(CTOSComponent.ComponentID),'No Need') ")
            '.AppendLine(" else 'No Need' end as CATEGORY_ID,''  as CATEGORY_NAME, ")
            '.AppendLine(" case when  CTOSComponent.ComponentType='list' then 'Component' else CTOSComponent.ComponentType end as CATEGORY_TYPE , ")
            '.AppendLine(" CASE WHEN CTOSComponent.ComponentParentID IS NULL  THEN 'EZ-'+Product.DisplayPartno ELSE CTOSComponent_1.ComponentName   + ' for EZ-' + Product.DisplayPartno  END AS PARENT_CATEGORY_ID, ")
            '.AppendLine(" '' as  CATALOG_ID,CTOSComponent.ComponentDesc as  CATEGORY_DESC, ")
            '.AppendLine(" '' AS DISPLAY_NAME ,'created_by_ming' as IMAGE_ID, '' AS EXTENDED_DESC ,getdate()as CREATED, 'EZ' AS created_by, getdate()as LAST_UPDATED ,'EZ' as last_updated_by, ")
            '.AppendLine(" CTOSBOM.Seq as SEQ_NO ,'' as publish_status,convert(char(1),CTOSBOM.Defaults) as DEFAULT_FLAG, ''as CONFIGURATION_RULE,'' as  NOT_EXPAND_CATEGORY, ")
            '.AppendLine(" CTOSBOM.Show AS show_hide,'2' AS EZ_FLAG,NEWID() as  UID , SUBSTRING ( Product_Ctos.StoreID , 2 , 2 ) AS  ORG ")
            '.AppendLine(" FROM Parts INNER JOIN ")
            '.AppendLine(" Product ON Parts.StoreID = Product.StoreID AND Parts.SProductID = Product.SProductID INNER JOIN ")
            '.AppendLine(" Product_Ctos ON Product.StoreID = Product_Ctos.StoreID AND Product.SProductID = Product_Ctos.SProductID INNER JOIN ")
            '.AppendLine(" CTOSBOM ON Product_Ctos.StoreID = CTOSBOM.StoreID AND Product_Ctos.SProductID = CTOSBOM.SProductID INNER JOIN ")
            '.AppendLine(" CTOSComponent ON CTOSBOM.ComponentID = CTOSComponent.ComponentID left JOIN ")
            '.AppendLine(" CTOSComponent AS CTOSComponent_1 ON CTOSComponent.ComponentParentID = CTOSComponent_1.ComponentID ")
            '.AppendLine(" WHERE     (Parts.StoreID = 'aeu' ) AND (Product.Status <> 'INACTIVE_AUTO')  ") 'or Parts.StoreID ='AAU'
            '.AppendLine(" AND (Product.Status <> 'deleted') AND (Product.Status <> 'INACTIVE') and (CTOSBOM.Show = 1) ")
            '.AppendLine(" union ")
            '.AppendLine(" SELECT    ")
            '.AppendLine(" 'EZ-'+Product.DisplayPartno as  CATEGORY_ID,'' as CATEGORY_NAME, ")
            '.AppendLine(" 'Component' as CATEGORY_TYPE,'Root' AS PARENT_CATEGORY_ID,'' as  CATALOG_ID,Product.ProductDesc as  CATEGORY_DESC, ")
            '.AppendLine(" '' AS DISPLAY_NAME ,'created_by_ming' as IMAGE_ID, '' AS EXTENDED_DESC ,getdate()as CREATED, 'EZ' AS created_by, getdate()as LAST_UPDATED ,'EZ' as last_updated_by, ")
            '.AppendLine(" 0 as SEQ_NO ,'' as publish_status,'' as DEFAULT_FLAG, ''as CONFIGURATION_RULE,'' as  NOT_EXPAND_CATEGORY, ")
            '.AppendLine(" 1 AS show_hide,'2' AS EZ_FLAG,NEWID() AS UID,SUBSTRING ( Product_Ctos.StoreID , 2 , 2 ) as ORG ")
            '.AppendLine(" FROM   Parts INNER JOIN ")
            '.AppendLine(" Product ON Parts.StoreID = Product.StoreID AND Parts.SProductID = Product.SProductID INNER JOIN ")
            '.AppendLine(" Product_Ctos ON Product.StoreID = Product_Ctos.StoreID AND Product.SProductID = Product_Ctos.SProductID ")
            '.AppendLine(" where ( Parts.StoreID='aeu' ) ") 'or Parts.StoreID='aau'
            '.AppendLine(" and (Product.Status<>'INACTIVE_AUTO' and Product.Status<>'deleted' and Product.Status<>'INACTIVE')  ")
        End With
        Dim SQL_Str As String = String.Format("select * from  ( {0} ) as t where  {1} order by SEQ_NO", sql.ToString, WhereStr)
        Return SQL_Str
    End Function
    Private Sub BuildUpTree(ByVal BTOItem As String)
        Dim dispPart As String = BTOItem
        BTOItem = EZ + BTOItem
        Dim sqlwhere As String = "CATEGORY_ID = '" & BTOItem & "'"
        Me.tv1.Nodes.Clear()
        Dim CbomTB As DataTable = dbUtil.dbGetDataTable("Estore", GetSQL(sqlwhere, dispPart))
        If CbomTB.Rows.Count = 0 Then
            Me.lblMessage.Text = "Can't find this Ctos."
            Exit Sub
        End If
        'Response.Write(GetSQL(sqlwhere))
        Dim rootNode As New TreeNode(BTOItem, BTOItem)
        rootNode.ImageUrl = "../Images/eConfig_Icons_Advantech/display.gif"
        tv1.Nodes.Add(rootNode)
        sqlwhere = "parent_category_id='" & BTOItem & "' and CATEGORY_TYPE ='category'"
        Dim CatDt As DataTable = dbUtil.dbGetDataTable("Estore", GetSQL(sqlwhere, dispPart))
        For i As Integer = 0 To CatDt.Rows.Count - 1
            Dim CatNode As New TreeNode(CatDt.Rows(i).Item("CATEGORY_ID"), CatDt.Rows(i).Item("CATEGORY_ID"))
            'If CatDt.Rows(i).Item("show").ToString.ToUpper = "SHOW=NO" Then
            '    CatNode.Text &= " (" & CatDt.Rows(i).Item("show") & ")"
            'End If
            CatNode.ImageUrl = "../Images/eConfig_Icons_Advantech/chassis_adv.gif"
            rootNode.ChildNodes.Add(CatNode)
            
            sqlwhere = String.Format(" parent_category_id = '{0}' and CATEGORY_TYPE='Component'", CatDt.Rows(i).Item("CATEGORY_ID").ToString.Trim)
                      
            Dim CompDt As DataTable = dbUtil.dbGetDataTable("Estore", GetSQL(sqlwhere, dispPart))
            For j As Integer = 0 To CompDt.Rows.Count - 1
                Dim CompNode As New TreeNode(CompDt.Rows(j).Item("CATEGORY_ID"), CompDt.Rows(j).Item("CATEGORY_ID"))
                If CompDt.Rows(j).Item("CATEGORY_ID").ToString().ToLower.Trim().Equals(MyExtension.BuildIn.ToLower) Then
                    CompNode.Text = MyExtension.BuildIn
                End If
                'If CInt(CompDt.Rows(j).Item("defaults")) = 1 Then
                '    CompNode.Text &= " (Default)"
                'End If
                CompNode.ImageUrl = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                CatNode.ChildNodes.Add(CompNode)
            Next
        Next
        Me.tv1.ExpandAll()
    End Sub
    
    Private Sub ImportCBOM(ByVal BTOItem As String)
        Dim TotalDT As DataTable = Nothing, BTOItemForCheck As String = BTOItem, strSql As String = ""
        'If Right(BTOItem, 4).ToUpper <> "-BTO" Then
        '    BTOItemForCheck = BTOItem + "-BTO"
        'End If
        BTOItemForCheck = BTOItem
        'If dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select category_id from cbom_catalog_category where category_id='" & BTOItemForCheck & "'").Rows.Count > 0 Then
        '    Me.lblMessage.Text = "already exists in database for this item."
        '    Exit Sub
        'End If
        If dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select category_id from cbom_catalog_category where category_id='" & EZ + BTOItemForCheck & "' and ORG ='EU' ").Rows.Count > 0 Then
            Me.lblMessage.Text = "already exists in database for this item."
            Exit Sub
        End If
        'If dbUtil.dbGetDataTable(CBOMSetting.DBConn, String.Format("select TOP 1 CATALOG_ID from  CBOM_CATALOG where catalog_id ='{0}' OR CATALOG_NAME ='{0}'", BTOItemForCheck)).Rows.Count > 0 Then
        '    EZ = "[EZ]"
        'End If        
        Dim sqlwhere As String = "CATEGORY_ID = '" & EZ + BTOItem & "' and parent_category_id ='Root'"
        Dim TbBTO As DataTable = dbUtil.dbGetDataTable("Estore", GetSQL(sqlwhere, BTOItem))
        If TbBTO.Rows.Count = 0 Then Me.lblMessage.Text = "Error."
        If TbBTO.Rows.Count > 0 Then
            TotalDT = TbBTO.Clone()
            TotalDT.Merge(TbBTO)
            With TbBTO.Rows(0)
                                                             
                strSql = "insert into cbom_catalog(catalog_id,catalog_name,catalog_type,catalog_desc," & _
                         "created,created_by,last_updated_by,CATALOG_ORG) values('" & .Item("CATEGORY_ID") & "','" & _
                                                           .Item("CATEGORY_ID") & "','" & _
                                                          "Pre-Configuration" & " ','" & _
                                                          .Item("category_desc") & "'," & _
                                                          "getdate()" & ",'" & _
                                                          "From CTOS" & "','" & .Item("CATEGORY_ID") & "','EU')"
               
                '-----------
                sqlwhere = "parent_category_id='" & EZ + BTOItem & "' and CATEGORY_TYPE ='category' AND LOWER(CATEGORY_ID) NOT LIKE 'extended warranty%'"
                Dim CatDt As DataTable = dbUtil.dbGetDataTable("Estore", GetSQL(sqlwhere, BTOItem))
                TotalDT.Merge(CatDt)               
                For i As Integer = 0 To CatDt.Rows.Count - 1
                             
                    sqlwhere = String.Format(" parent_category_id = '{0}' and CATEGORY_TYPE='Component' ", CatDt.Rows(i).Item("CATEGORY_ID").ToString.Trim)
                      
                    Dim CompDt As DataTable = dbUtil.dbGetDataTable("Estore", GetSQL(sqlwhere, BTOItem))
                    If CompDt.Rows.Count > 0 Then
                        TotalDT.Merge(CompDt)
                        
                    End If
                Next
                '-----------
            End With
            
        Else
            Me.lblMessage.Text = "There's no data in CTOS"
            Exit Sub
        End If
 
        If TotalDT.Rows.Count > 0 Then
            'TotalDT.Columns.Remove("UID")
            'TotalDT.Columns.Remove("ORG")
            'OrderUtilities.showDT(TotalDT)
            For i As Integer = 0 To TotalDT.Rows.Count - 1
                If TotalDT.Rows(i).Item("parent_category_id").ToString.Trim.ToLower = "root" Or TotalDT.Rows(i).Item("CATEGORY_TYPE").ToString.ToLower.ToLower = "category" Then
                    TotalDT.Rows(i).Item("CATEGORY_ID") = TotalDT.Rows(i).Item("CATEGORY_ID") + ""
                    TotalDT.Rows(i).Item("CATEGORY_NAME") = TotalDT.Rows(i).Item("CATEGORY_ID")                  
                End If
                If TotalDT.Rows(i).Item("parent_category_id").ToString.Trim.ToLower <> "root" Then
                    TotalDT.Rows(i).Item("parent_category_id") = TotalDT.Rows(i).Item("parent_category_id") + ""
                End If
                If TotalDT.Rows(i).Item("CATEGORY_TYPE").ToString.ToLower.ToLower = "category" Then
                    TotalDT.Rows(i).Item("CATEGORY_TYPE") = "Category"
                End If
                If TotalDT.Rows(i).Item("CATEGORY_TYPE").ToString.ToLower.ToLower = "component" AndAlso _
                TotalDT.Rows(i).Item("parent_category_id").ToString.ToLower.ToLower <> "root" AndAlso _
                TotalDT.Rows(i).Item("CATEGORY_ID").ToString.Trim.ToLower <> MyExtension.BuildIn.ToLower Then
                    Dim PN = TotalDT.Rows(i).Item("CATEGORY_ID").ToString.Trim, PNO As String = ""
                    If PN.Contains("|") Then
                        PNO = PN.Split("|")(0)
                    Else
                        PNO = PN
                    End If
                    If dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select part_no from SAP_PRODUCT " & _
                    "where part_no='" & PNO & "'").Rows.Count = 0 Then
                        Me.lblMessage.Text = String.Format("Please maintain con_item_virtual_part( {0} ).", PNO)
                        'Exit Sub
                    End If
                End If
                TotalDT.Rows(i).Item("CONFIGURATION_RULE") = "REQUIRED"
                If TotalDT.Rows(i).Item("CATEGORY_ID").ToString.ToLower.ToLower = MyExtension.BuildIn.ToLower Then
                    TotalDT.Rows(i).Item("DEFAULT_FLAG") = "1"
                    TotalDT.Rows(i).Item("CONFIGURATION_RULE") = "DEFAULT"
                End If
                If TotalDT.Rows(i).Item("DEFAULT_FLAG") = "1" Then
                    TotalDT.Rows(i).Item("CONFIGURATION_RULE") = "DEFAULT"
                End If
            Next
            TotalDT.AcceptChanges()
            gv1.DataSource = TotalDT
            gv1.DataBind()
            'Exit Sub
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, strSql)
            'Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString)
            'bk.DestinationTableName = "cbom_catalog_category"
            'bk.WriteToServer(TotalDT)
            For i As Integer = 0 To TotalDT.Rows.Count - 1
                With TotalDT.Rows(i)
                    Dim InSql As New StringBuilder
                    InSql.AppendLine("INSERT INTO CBOM_CATALOG_CATEGORY VALUES (")
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("CATEGORY_ID")), "", .Item("CATEGORY_ID").ToString().Trim()))
                    InSql.AppendFormat(" '{0}',  ", IIf(IsDBNull(.Item("CATEGORY_NAME")), "", .Item("CATEGORY_NAME").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("CATEGORY_TYPE")), "", .Item("CATEGORY_TYPE").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("PARENT_CATEGORY_ID")), "", .Item("PARENT_CATEGORY_ID").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("CATALOG_ID")), "", .Item("CATALOG_ID").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("CATEGORY_DESC")), "", .Item("CATEGORY_DESC").ToString().Trim()))
                    InSql.AppendFormat(" '{0}'  ,", IIf(IsDBNull(.Item("DISPLAY_NAME")), "", .Item("DISPLAY_NAME").ToString().Trim()))
                    InSql.AppendFormat(" '{0}'  ,", IIf(IsDBNull(.Item("IMAGE_ID")), "", .Item("IMAGE_ID").ToString().Trim()))
                    InSql.AppendFormat(" '{0}'  ,", IIf(IsDBNull(.Item("EXTENDED_DESC")), "", .Item("EXTENDED_DESC").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("CREATED")), "", .Item("CREATED").ToString().Trim()))
                    InSql.AppendFormat(" '{0}'  ,", IIf(IsDBNull(.Item("CREATED_BY")), "", .Item("CREATED_BY").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("LAST_UPDATED")), "", .Item("LAST_UPDATED").ToString().Trim()))
                    InSql.AppendFormat(" '{0}'  ,", IIf(IsDBNull(.Item("LAST_UPDATED_BY")), "", .Item("LAST_UPDATED_BY").ToString().Trim()))
                    InSql.AppendFormat(" {0} , ", IIf(IsDBNull(.Item("SEQ_NO")), "", .Item("SEQ_NO").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("PUBLISH_STATUS")), "", .Item("PUBLISH_STATUS").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("DEFAULT_FLAG")), "", .Item("DEFAULT_FLAG").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("CONFIGURATION_RULE")), "", .Item("CONFIGURATION_RULE").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("NOT_EXPAND_CATEGORY")), "", .Item("NOT_EXPAND_CATEGORY").ToString().Trim()))
                    InSql.AppendFormat(" {0}  ,", IIf(IsDBNull(.Item("SHOW_HIDE")), "", .Item("SHOW_HIDE").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("EZ_FLAG")), "", .Item("EZ_FLAG").ToString().Trim()))
                    InSql.AppendFormat(" '{0}' , ", IIf(IsDBNull(.Item("UID")), "", .Item("UID").ToString().Trim()))
                    InSql.AppendFormat(" '{0}'  ", IIf(IsDBNull(.Item("ORG")), "", .Item("ORG").ToString().Trim()))
                    InSql.AppendLine(")")
                    dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, InSql.ToString())
                End With
            Next
        End If
        Me.lblMessage.Text = "Sync Sucessfully!" 
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
        'Me.lblMessage.Text = "This function is disabled for maintenance."
        'Exit Sub
        Dim strSql As String = "", Bto_item As String = ""
        Dim dt As New DataTable
        Dim DtCatalog As New DataTable
        Dim BTOTEMP As String = ""
        'If Right(BTOItem, 4).ToUpper <> "-BTO" Then
        '    BTOTEMP = BTOItem + "-BTO"
        'End If
        BTOTEMP = BTOItem
        Dim Isql = String.Format("select catalog_name from cbom_catalog where (catalog_id='{0}' or catalog_id ='{1}') AND CATALOG_ORG ='EU'", EZ + BTOTEMP, EZ + BTOTEMP)
        DtCatalog = dbUtil.dbGetDataTable(CBOMSetting.DBConn, Isql)
        'Response.Write(Isql)
        'Exit Sub
        'DtCatalog = dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select catalog_name from cbom_catalog where catalog_id='" & _
        '            BTOTEMP & "' and catalog_type='Pre-Configuration' and created_by='from CTOS'")
        If DtCatalog.Rows.Count > 0 Then
            Bto_item = DtCatalog.Rows(0).Item("catalog_name")
        Else
            Me.lblMessage.Text = "Can't find this item,can't delete."
            Exit Sub
        End If
        'Response.Write(Bto_item)
        'Exit Sub
        dt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, "select category_id from cbom_catalog_category where category_id='" & Bto_item & _
                        "' and parent_category_id='Root' AND ORG = 'EU' ")
        If dt.Rows.Count > 0 Then
            strSql = "delete from CBOM_CATALOG_CATEGORY where (category_id='" & _
            Bto_item & "' or parent_category_id='" & _
            Bto_item & "' or parent_category_id like '%For " & Bto_item & "') AND ORG = 'EU';"
            'Me.Global_inc1.dbDataReader("", "", strsql)
        End If
        strSql &= "delete from cbom_catalog where catalog_name='" & Bto_item & "' " & _
                "and catalog_type='Pre-Configuration' and created_by='from CTOS' AND CATALOG_ORG ='EU';"
        'Response.Write(strSql)
        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, strSql) : Me.lblMessage.Text = "delete sucesfully!"
        
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

