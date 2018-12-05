Imports SAP.Connector
Imports System.Globalization
Imports System.Linq
Partial Class WebCBOMEditor_Default
    Inherits System.Web.UI.Page
    Shared TableDest As String = "CBOM_CATALOG_CATEGORY"
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not IsPostBack() Then
       
            If IsNothing(Request("BTOItem")) OrElse Request("BTOItem") = "" Then
                Me.hBTO.Value = "ACP-1010-BTO"
            Else
                Me.hBTO.Value = Request("BTOItem")
            End If
            If IsNothing(Session("ORG_ID")) Then
                Me.hORG.Value = "EU10"
            Else
                Me.hORG.Value = Session("ORG_ID")
            End If
            If Not IsNothing(Request("UID")) AndAlso Request("UID") <> "" Then
                Dim ITEM As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, "SELECT * FROM " & TableDest & " WHERE UID='" & Request("UID") & "'")
                If ITEM.Rows.Count > 0 Then
                    Me.hBTO.Value = ITEM.Rows(0).Item("Category_id").ToString
                End If
            End If
            If Not IsNothing(Request("q")) Then
                Dim txtKey As String = Trim(Request("q"))
                Dim ORG As String = Me.hORG.Value
                If Not IsNothing(Request("ORG")) Then
                    ORG = Request("ORG")
                End If
                Dim dt As DataTable = GetPartNo(txtKey, 10, ORG)
                Dim js As String = "[]"
                Dim l As New List(Of CategorySugg)
                If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
                    Dim N As Integer = 1
                    For Each DR As DataRow In dt.Rows
                        Dim p As New CategorySugg
                        p.id = N
                        N = N + 1
                        p.name = DR.Item("part_no")
                        l.Add(p)
                    Next
                    Dim slz = New Script.Serialization.JavaScriptSerializer()
                    js = slz.Serialize(l)
                End If
                Response.Clear() : Response.Write(js) : Response.End()
            End If
        End If
    End Sub
    Public Shared Function GetPartNo(ByVal prefixText As String, ByVal count As Integer, ByVal Org As String) As DataTable
        Dim dt As DataTable = Nothing
        If HttpContext.Current.Session Is Nothing Then
            Return Nothing
        End If
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct top 10 A.part_no from  dbo.SAP_PRODUCT A INNER JOIN SAP_PRODUCT_STATUS B ON A.PART_NO=B.PART_NO  ")
        sql.AppendFormat(" where A.PART_NO like '{0}%' ", prefixText)
        'sql.AppendFormat(" and  B.PRODUCT_STATUS in {0}", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        sql.AppendFormat(" AND B.SALES_ORG ='{0}' ", Org)
        'If Not Util.IsInternalUser2() Then
        sql.AppendLine(" and A.material_group not in ('T','ODM') ")
        'End If
        sql.AppendLine(" order by part_no ")
        'dt = dbUtil.dbGetDataTable("RFM", String.Format( _
        '"select distinct top 10 part_no from sap_product where part_no like '{0}%' and material_group not in ('T','ODM') and status in ('A','N') order by part_no desc", prefixText))
        dt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, sql.ToString())
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            Return dt
        Else
            Dim t As New DataTable
            t.Columns.Add("part_no")
            Dim r As DataRow = t.NewRow
            r.Item("part_no") = prefixText
            t.Rows.Add(r)
            Return t
        End If
        Return Nothing
    End Function
    Public Shared Function getCateDT(ByVal rowCount As Integer, ByVal PageNum As Integer, ByVal org As String, ByVal pn As String, ByVal type As String) As DataTable
        Dim Str As String = ""
        If type = "CATEGORY" Then
            Str = "select * from ( " & _
                                     " select distinct ROW_NUMBER() OVER(Order by category_id) AS RowNumber, category_id as part_no, isnull(category_desc,'') as product_desc " & _
                                     " from " & TableDest & " " & _
                                     " where org= '" & Left(org, 2) & "' and category_id like '" & pn & "%' and category_type='" & type & "') " & _
                                     " as b where b.RowNumber BETWEEN " & rowCount * (PageNum - 1) + 1 & " and " & rowCount * PageNum & " "
        Else
            Str = "select * from ( " & _
                                     " select distinct ROW_NUMBER() OVER(Order by PART_NO) AS RowNumber, part_no, isnull(product_desc,'') as product_desc " & _
                                     " from sap_product " & _
                                     " where part_no like '" & pn & "%')" & _
                                     " as b where b.RowNumber BETWEEN " & rowCount * (PageNum - 1) + 1 & " and " & rowCount * PageNum & " "
        End If

        Dim dt As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, Str)
        Return dt
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetProd(ByVal rowCount As String, ByVal pageNum As String, ByVal org As String, ByVal pn As String, ByVal type As String) As String
        Dim dt As DataTable = getCateDT(rowCount, pageNum, org, pn, type)
        Dim l As New List(Of Product)
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            For Each DR As DataRow In dt.Rows
                Dim p As New Product
                p.rowno = DR.Item("RowNumber")
                p.partno = DR.Item("part_no")
                p.desc = DR.Item("product_desc")
                l.Add(p)
            Next
        End If

        Dim slz = New Script.Serialization.JavaScriptSerializer()
        Dim r As String = slz.Serialize(l)
        Return "{""total"":" & 800 & ",""rows"":" & r & "}"
    End Function
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetTree(ByVal id As String, ByVal isRoot As String, ByVal ORG As String, ByVal byreg As String) As String

        Dim r As New Category
        r.id = id
        r.state = "open"
        If isRoot = "Y" Then
            r.type = "root"
        End If



        Dim reg As Boolean = False
        If byreg = "reg" Then
            reg = True
        End If
        Dim dt As DataTable = GetQBOMSql(id, ORG, reg)

        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows
                Dim cld As New Category
                cld.UID = dr.Item("UID").ToString()
                cld.id = dr.Item("CATEGORY_ID")
                cld.isReq = dr.Item("CONFIGURATION_RULE")
                cld.type = dr.Item("CATEGORY_TYPE")
                cld.showhide = dr.Item("SHOW_HIDE")
                cld.notexpand = dr.Item("NOT_EXPAND_CATEGORY")
                cld.desc = dr.Item("CATEGORY_DESC")
                cld.seq = dr.Item("SEQ_NO")
                cld.cby = ""
                r.children.Add(cld)
            Next
        Else
            If r.type = "root" Then
                Dim tp As New Category
                tp.type = "DM"
                tp.id = "<font color=""#eeeeee"">Empty Category...</font>"
                r.children.Add(tp)
            End If
        End If
        Dim slz = New Script.Serialization.JavaScriptSerializer()
        Dim re As String = ""
        If isRoot = "Y" Then
            re = slz.Serialize(r)
            Return "[" & re & "]"
        Else
            re = slz.Serialize(r.children)
            Return re
        End If

    End Function
    Class CategorySugg
        Private _id As String
        Public Property id As String
            Get
                Return _id
            End Get
            Set(ByVal value As String)
                _id = value
            End Set
        End Property
        Private _name As String
        Public Property name As String
            Get
                Return _name
            End Get
            Set(ByVal value As String)
                _name = value
            End Set
        End Property
    End Class

    Class Category
        Private _UID As String = ""
        Private _id As String = ""
        Private _isreq As String = ""
        Private _state As String = "closed"
        Private _img As String = ""
        Private _type As String = ""
        Private _showhide As String = "1"
        Private _notexpand As String = ""
        Private _desc As String = ""
        Private _cby As String = ""
        Private _seq As String = ""
        Private _children As New List(Of Category)

        Public Property UID As String
            Get
                Return _UID
            End Get
            Set(ByVal value As String)
                _UID = value
            End Set
        End Property
        Public Property id As String
            Get
                Return _id
            End Get
            Set(ByVal value As String)
                _id = value
            End Set
        End Property
        Public ReadOnly Property text As String
            Get
                If _type.ToUpper = "CATEGORY" Then
                    _img = "../Images/eConfig_Icons_Advantech/chassis_adv.gif"
                ElseIf _type.ToUpper = "ROOT" Then
                    _img = "../Images/eConfig_Icons_Advantech/display.gif"
                Else
                    _img = "../Images/eConfig_Icons_Advantech/op_adv.gif"
                End If
                Dim img As String = ""
                If Not String.IsNullOrEmpty(_img) Then
                    img = "<img src=""" & _img & """ width=""12px"" alt="""">"
                End If
                Return "<table><tr><td>" & img & "</td><td style=""color:#999999;width:20px"">" & _seq & "</td><td>" & _id & "</td><td> </td><td style=""font-weight:bold;color:#009900"">" & _isreq & "</td></tr></table>"
            End Get
        End Property
        Public Property isReq As String
            Get
                Return _isreq
            End Get
            Set(ByVal value As String)
                _isreq = value
            End Set
        End Property
        Public Property state As String
            Get
                Return _state
            End Get
            Set(ByVal value As String)
                _state = value
            End Set
        End Property
        Public ReadOnly Property img As String
            Get
                Return _img
            End Get
        End Property
        Public Property type As String
            Get
                Return _type
            End Get
            Set(ByVal value As String)
                _type = value
            End Set
        End Property
        Public Property showhide As String
            Get
                Return _showhide
            End Get
            Set(ByVal value As String)
                _showhide = value
            End Set
        End Property
        Public Property notexpand As String
            Get
                Return _notexpand
            End Get
            Set(ByVal value As String)
                _notexpand = value
            End Set
        End Property
        Public Property desc As String
            Get
                Return _desc
            End Get
            Set(ByVal value As String)
                _desc = value
            End Set
        End Property
        Public Property cby As String
            Get
                Return _cby
            End Get
            Set(ByVal value As String)
                _cby = value
            End Set
        End Property
        Public Property seq As String
            Get
                Return _seq
            End Get
            Set(ByVal value As String)
                _seq = value
            End Set
        End Property
        Public Property children As List(Of Category)
            Get
                Return _children
            End Get
            Set(ByVal value As List(Of Category))
                _children = value
            End Set
        End Property

    End Class
    Class Product
        Private _rowno As String = ""
        Private _partno As String = ""
        Private _desc As String = ""
        Public Property rowno As String
            Get
                Return _rowno
            End Get
            Set(ByVal value As String)
                _rowno = value
            End Set
        End Property
        Public ReadOnly Property pick As String
            Get
                Return "<a href=""#"" onclick=""setPick('" & HttpUtility.JavaScriptStringEncode(_partno).Replace("""", "‘’").Replace("'", "‘") & "','" & HttpUtility.JavaScriptStringEncode(_desc).Replace("""", "‘’").Replace("'", "‘") & "')""  >Pick</a>"
            End Get
        End Property
        Public Property partno As String
            Get
                Return _partno
            End Get
            Set(ByVal value As String)
                _partno = value
            End Set
        End Property
        Public Property desc As String
            Get
                Return _desc
            End Get
            Set(ByVal value As String)
                _desc = value
            End Set
        End Property
    End Class




    'biz
    Public Shared Function GetQBOMSql(ByVal PCatId As String, ByVal orgID As String, Optional ByVal isByReg As Boolean = False) As DataTable
        Dim ORG As String = Left(orgID, 2)
        Dim qsb As New System.Text.StringBuilder
        With qsb
            .AppendLine(" SELECT a.UID, a.PARENT_CATEGORY_ID, a.CATEGORY_ID, a.CATEGORY_NAME, a.CATEGORY_TYPE, ISNULL(a.CATEGORY_DESC,'') AS CATEGORY_DESC, ")
            .AppendLine(" IsNull(a.DISPLAY_NAME,'') as DISPLAY_NAME, IsNull(a.SEQ_NO,0) as SEQ_NO, IsNull(a.DEFAULT_FLAG,0) as DEFAULT_FLAG, ")
            .AppendLine(" IsNull(a.CONFIGURATION_RULE,'') as CONFIGURATION_RULE, IsNull(a.NOT_EXPAND_CATEGORY,'') as NOT_EXPAND_CATEGORY, ")
            .AppendLine(" IsNull(a.SHOW_HIDE,0) as SHOW_HIDE, IsNull(a.EZ_FLAG,0) as EZ_FLAG, IsNull(b.STATUS,'') as STATUS_OLD, 0 as SHIP_WEIGHT,  ")
            .AppendLine(" 0 as NET_WEIGHT, IsNull(b.MATERIAL_GROUP,'') as MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as class,a.UID,a.org ")
            .AppendLine(" ,c.PRODUCT_STATUS as STATUS ")
            .AppendLine(" FROM " & TableDest & " AS a LEFT OUTER JOIN ")
            .AppendLine(" SAP_PRODUCT AS b ON a.CATEGORY_ID = b.PART_NO ")
            .AppendFormat(" LEFT JOIN sap_product_status AS c on c.PART_NO = a.CATEGORY_ID and c.SALES_ORG = '{0}' ", orgID)
            'Nada 20131121 PMsin cbom edit no need be controlled by org
            If isByReg Then
                .AppendLine(String.Format(" WHERE a.PARENT_CATEGORY_ID = N'{0}' and a.org='" & org & "' and a.CATEGORY_ID<>N'{0}' ", PCatId))
            Else
                .AppendLine(String.Format(" WHERE a.PARENT_CATEGORY_ID = N'{0}' and a.CATEGORY_ID<>N'{0}' ", PCatId))
            End If
            .AppendLine(" and (a.CATEGORY_TYPE='Category' or A.CATEGORY_TYPE='Component' or (a.CATEGORY_TYPE='Component' and (a.CATEGORY_ID='No Need' or a.CATEGORY_ID like '%|%'))) ")
            .AppendLine(" ORDER BY a.SEQ_NO ")
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, qsb.ToString())
        Dim compArray As New ArrayList
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE") = "Component" And r.Item("category_id").ToString.Contains("|") Then
                Dim ps() As String = Split(r.Item("category_id").ToString, "|")
                For Each p As String In ps
                    If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                        If CInt(dbUtil.dbExecuteScalar(CBOMSetting.DBConn, String.Format( _
                                                        "select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " + _
                                                       " where PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " and part_no in ('{0}') and SALES_ORG='{1}'", p.ToString, orgID))) <= 0 Then
                            r.Delete()
                        End If
                    End If
                Next
            ElseIf r.Item("CATEGORY_TYPE") = "Component" And Not r.Item("category_id").ToString.Contains("|") And Not r.Item("category_id").ToString.ContainsV2(MyExtension.BuildIn) Then
                If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                    If CInt(dbUtil.dbExecuteScalar(CBOMSetting.DBConn, String.Format( _
                                                   " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " + _
                                                   " where PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " and part_no in ('{0}') and SALES_ORG='{1}'", r.Item("CATEGORY_ID").ToString, orgID))) <= 0 Then
                        r.Delete()
                    End If
                End If
            End If
        Next
        dt.AcceptChanges()
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE") = "Component" Then
                If compArray.Contains(r.Item("category_id").ToString()) = False Then
                    compArray.Add(r.Item("category_id").ToString())
                Else
                    r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        compArray.Clear()
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE") = "Category" Then
                If compArray.Contains(r.Item("category_id").ToString()) = False Then
                    compArray.Add(r.Item("category_id").ToString())
                Else
                    r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        'Nada 20131121 PMsin cbom edit no need be controlled by org
        Dim str As String = String.Format("select count(category_id) as c FROM " & TableDest & " where parent_category_id='Root' and category_id='{0}'", Replace(PCatId, "'", "''"))
        If isByReg Then
            str = String.Format("select count(category_id) as c FROM " & TableDest & " where org='" & ORG & "' and parent_category_id='Root' and category_id='{0}'", Replace(PCatId, "'", "''"))
        End If
        If (PCatId.ToUpper().EndsWith("-BTO") Or PCatId.ToUpper().StartsWith("C-CTOS-")) AndAlso CInt(dbUtil.dbExecuteScalar(CBOMSetting.DBConn, str)) > 0 Then
            Dim r As DataRow = dt.NewRow()
            With r
                .Item("CATEGORY_ID") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("CATEGORY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("CATEGORY_TYPE") = "Category"
                .Item("CATEGORY_DESC") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("DISPLAY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("SEQ_NO") = 9999 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
            End With
            dt.Rows.Add(r)
            'If dbUtil.dbGetDataTable("RFM", String.Format("select category_name from cbom_catalog_category where org='" & org & "' and category_id not like '%-CTOS%' and category_id not like '%SYS-%' and category_id='{0}' and isnull(EZ_Flag,'0')<>'2'", Replace(PCatId, "'", "''"))).Rows.Count > 0 Then
            If dbUtil.dbGetDataTable(CBOMSetting.DBConn, String.Format("select category_name from " & TableDest & " where category_id not like '%-CTOS%' and category_id not like '%SYS-%' and category_id='{0}' and isnull(EZ_Flag,'0')<>'2'", Replace(PCatId, "'", "''"))).Rows.Count > 0 Then
                Dim r2 As DataRow = dt.NewRow()
                With r2
                    .Item("CATEGORY_ID") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_TYPE") = "Category"
                    .Item("CATEGORY_DESC") = "CTOS note for " + PCatId.ToUpper()
                    .Item("DISPLAY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("SEQ_NO") = 10000 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                    .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                    .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                    .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                End With
                dt.Rows.Add(r2)
            End If
        Else
            If PCatId.ToUpper().StartsWith("EXTENDED WARRANTY FOR") Then
                qsb = New System.Text.StringBuilder
                With qsb
                    .AppendLine(" SELECT PART_NO AS UID, PART_NO as CATEGORY_ID, PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                    .AppendLine(" PRODUCT_DESC as CATEGORY_DESC, PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                    .AppendLine(" '' as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(STATUS,'') as STATUS, ")
                    .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                    .AppendLine(" FROM  SAP_PRODUCT ")
                    .AppendLine(" WHERE PART_NO LIKE 'AGS-EW%' order by PART_NO ")
                End With
                dt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, qsb.ToString())
            Else
                If PCatId.ToUpper().StartsWith("CTOS NOTE FOR") Then
                    qsb = New System.Text.StringBuilder
                    With qsb
                        .AppendLine(" SELECT distinct a.PART_NO as UID, a.PART_NO as CATEGORY_ID, a.PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                        .AppendLine(" b.PRODUCT_DESC as CATEGORY_DESC, b.PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                        .AppendLine(" '' as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(b.STATUS,'') as STATUS, ")
                        .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                        .AppendLine(" from CBOM_CATEGORY_CTOS_NOTE a left join SAP_PRODUCT b on a.part_no=b.part_no ")
                        .AppendLine(" order by a.PART_NO ")
                    End With
                    dt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, qsb.ToString())
                End If
            End If
        End If
        Return dt
    End Function
    Public Shared Sub CopyFromExCate(ByVal Cate As String, ByVal fromCate As String, ByVal Org As String, ByRef em As String)
        Dim strEixst1 As String = "select count([uid]) from " & TableDest & " where Category_ID ='" & fromCate & "'"
        Dim o1 As Object = dbUtil.dbExecuteScalar(CBOMSetting.DBConn, strEixst1)
        If Not Integer.TryParse(o1, 0) OrElse CInt(o1) < 1 Then
            em = String.Format("Copy child items from '{0}' to '{1}' failed. because '{0}' dose not exist.", fromCate, Cate)
            Exit Sub
        End If

        Dim strEixst As String = "select count([uid]) from " & TableDest & " where Category_ID ='" & Cate & "'"
        Dim o As Object = dbUtil.dbExecuteScalar(CBOMSetting.DBConn, strEixst)
        If Integer.TryParse(o, 0) AndAlso CInt(o) = 1 Then
            Dim str As String = " INSERT INTO " & TableDest & " (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, " & _
                                  " PARENT_CATEGORY_ID, CATEGORY_DESC,  " & _
                                  " EXTENDED_DESC, CREATED_BY, SEQ_NO, " & _
                                  " CONFIGURATION_RULE,org,EZ_FLAG,[uid])  " & _
                                  " (select distinct CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE,  " & _
                                   "  '" & Cate & "', CATEGORY_DESC,  " & _
                                  " EXTENDED_DESC, CREATED_BY, SEQ_NO,  " & _
                                  " CONFIGURATION_RULE,org,'9',newid() from " & TableDest & "  " & _
                                  " where parent_category_id='" & fromCate & "' and org='" & Left(Org.ToString.ToUpper, 2) & "')"
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, str)
            logop2db(HttpContext.Current.Session("user_id"), HttpContext.Current.Request("BTOItem"), str, "copy", fromCate & "->" & Cate)
        Else
            em = String.Format("Copy child items from '{0}' to '{1}' failed. because '{1}' is not a unique category or '{2}' dose not exist.", fromCate, Cate, Cate)
        End If
    End Sub
    Public Shared Sub updateSeq(ByVal ID As String, ByVal PID As String, ByVal SEQ As Integer, ByVal ORG As String)
        Dim UpdateSeqSql As String = _
               " update " & TableDest & " set seq_no = (seq_no+1) " & _
               " where org='" & Left(ORG.ToString.ToUpper, 2) & "' and parent_category_id='" & PID & "' " & _
               " and seq_no>=" & SEQ & " and category_id<>'" & ID & "'"
        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, UpdateSeqSql)
    End Sub
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function addCate(ByVal UID As String, ByVal id As String, ByVal pid As String, ByVal rid As String, ByVal desc As String, ByVal cBy As String, ByVal seq As String, ByVal req As String, ByVal org As String, ByVal copyFrom As String) As String
        id = id.Replace("‘’", """").Replace("‘", "''")
        desc = desc.Replace("‘’", """").Replace("‘", "''")
        copyFrom = copyFrom.Replace("‘’", """").Replace("‘", "''")
        UID = System.Guid.NewGuid.ToString()
        Dim addSql As String = _
               " INSERT INTO " & TableDest & " " & _
               " (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, " & _
               " PARENT_CATEGORY_ID, CATEGORY_DESC, " & _
               " EXTENDED_DESC, CREATED_BY, SEQ_NO, " & _
               " CONFIGURATION_RULE,org,EZ_FLAG,uid) " & _
               " VALUES ('" & id & "', '" & id & "', 'Category', " & _
               " N'" & pid & "', '" & desc & "', '" & _
               rid & "', '" & cBy & "', '" & _
               seq & "', '" & req & "','" & Left(org.ToString.ToUpper, 2) & "','9','" & UID & "') "
        Dim N As Integer = dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, addSql)

        If N = 1 Then
            updateSeq(id, pid, seq, org)
            logop2db(HttpContext.Current.Session("user_id"), HttpContext.Current.Request("BTOItem"), addSql, "addCate", pid & ">>" & id)
            Dim em As String = ""
            If copyFrom <> "" Then
                CopyFromExCate(id, copyFrom, org, em)
            End If
            If em = "" Then
                Return "OK"
            Else
                Return em
            End If
        End If
        Return ""
    End Function
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function addComp(ByVal UID As String, ByVal id As String, ByVal pid As String, ByVal rid As String, ByVal desc As String, ByVal cBy As String, ByVal seq As String, ByVal req As String, ByVal sh As String, ByVal def As String, ByVal org As String) As String
        id = id.Replace("‘’", """").Replace("‘", "''")
        desc = desc.Replace("‘’", """").Replace("‘", "''")
        Dim sCompNotExpand = ""
        If def = "1" Then
            sCompNotExpand = id
        End If
        Dim addSql As String = _
                " INSERT INTO " & TableDest & " " & _
                " (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, " & _
                " PARENT_CATEGORY_ID, CATEGORY_DESC, " & _
                " EXTENDED_DESC, CREATED_BY, SEQ_NO, " & _
                " CONFIGURATION_RULE, NOT_EXPAND_CATEGORY, SHOW_HIDE,ORG,EZ_FLAG,UID) " & _
                " VALUES ('" & id.Replace("'", "''") & "', '" & id.Replace("'", "''") & "', 'Component', " & _
                " N'" & pid.Replace("'", "''") & "', '" & desc.Replace("'", "''") & "', '" & _
                rid & "', '" & cBy & "', '" & _
                seq & "', '" & req.Replace("'", "''") & "', '" & sCompNotExpand.Replace("'", "''") & "', '" & sh & "','" & Left(org.ToUpper, 2) & "','9',NEWID()) "
        Dim N As Integer = dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, addSql)

        If N = 1 Then
            updateSeq(id, pid, seq, org)
            logop2db(HttpContext.Current.Session("user_id"), HttpContext.Current.Request("BTOItem"), addSql, "addComp", pid & ">>" & id)
            Return "OK"
        End If
        Return ""
    End Function
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function editCate(ByVal UID As String, ByVal id As String, ByVal desc As String, ByVal cBy As String, ByVal seq As String, ByVal req As String, ByVal org As String) As String
        id = id.Replace("‘’", """").Replace("‘", "''")
        desc = desc.Replace("‘’", """").Replace("‘", "''")
        Dim updateSql As String = _
      " UPDATE " & TableDest & " " & _
      " SET " & _
      " CATEGORY_DESC ='" & desc & "', CREATED_BY ='" & cBy & "', " & _
      " SEQ_NO = '" & seq & "', CONFIGURATION_RULE ='" & req & "',EZ_FLAG='9' " & _
      " WHERE org='" & Left(org, 2) & "' and CATEGORY_ID = '" & id & "' "
        Dim N As Integer = dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, updateSql)
        If N > 0 Then
            logop2db(HttpContext.Current.Session("user_id"), HttpContext.Current.Request("BTOItem"), updateSql, "editCate", id)
            Return "OK"
        End If
        Return ""
    End Function
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function editComp(ByVal UID As String, ByVal id As String, ByVal desc As String, ByVal cBy As String, ByVal seq As String, ByVal req As String, ByVal sh As String, ByVal def As String, ByVal org As String) As String
        id = id.Replace("‘’", """").Replace("‘", "''")
        desc = desc.Replace("‘’", """").Replace("‘", "''")
        Dim sCompNotExpand = ""
        If def = "1" Then
            sCompNotExpand = id
        End If
        Dim updateSql As String = _
              " UPDATE " & TableDest & " " & _
              " SET " & _
              " CATEGORY_DESC ='" & desc & "', CREATED_BY ='" & cBy & "', " & _
              " SEQ_NO = '" & seq & "', CONFIGURATION_RULE ='" & req & "', " & _
              " NOT_EXPAND_CATEGORY = '" & sCompNotExpand & "', SHOW_HIDE= '" & sh & "',EZ_FLAG='9' " & _
              " WHERE org='" & Left(org.ToUpper, 2) & "' and CATEGORY_ID = '" & id & "' "
        Dim N As Integer = dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, updateSql)
        If N > 0 Then
            logop2db(HttpContext.Current.Session("user_id"), HttpContext.Current.Request("BTOItem"), updateSql, "editComp", id)
            Return "OK"
        End If
        Return ""
    End Function
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function remove(ByVal UID As String, ByVal id As String) As String
        Dim delSql = " delete from " & TableDest & " where UID='" & UID & "' and category_id='" & id & "' "
        Dim N As Integer = dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, delSql)
        If N > 0 Then
            logop2db(HttpContext.Current.Session("user_id"), HttpContext.Current.Request("BTOItem"), delSql, "del", id)
            Return "OK"
        End If
        Return ""
    End Function

    Public Shared Sub logop2db(ByVal userid As String, ByVal btoid As String, ByVal sql As String, ByVal type As String, ByVal tagsign As String)
        Dim C As New L2SCBOMDataContext
        Dim l As New CBOM_EDITOR_LOG
        l.uid = System.Guid.NewGuid.ToString
        l.userid = userid
        l.btoid = btoid
        l.timestamp = Now.ToString("yyyy-MM-dd hh:mm:ss")
        l.sqlstr = sql
        l.otype = type
        l.tagsign = tagsign
        C.CBOM_EDITOR_LOGs.InsertOnSubmit(l)
        C.SubmitChanges()
    End Sub
End Class
