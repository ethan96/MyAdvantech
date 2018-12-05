Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Globalization

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantech.SAP.DataAccessLayer")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class MyCBOMDAL
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function GetCBOMCatalog() As DataTable

    End Function

    <WebMethod()> _
    Public Function GetCBOM(ByVal ParentCategoryId As String, ByVal RBU As String, ByVal SAPOrg As String) As DataTable
        Dim ShowOrg As String = getShowOrg(RBU, SAPOrg)
        Dim PCatId As String = Replace(Trim(ParentCategoryId), "'", "''")
        Dim qsb As New System.Text.StringBuilder
        With qsb
            .AppendLine(" SELECT a.PARENT_CATEGORY_ID, a.CATEGORY_ID, a.CATEGORY_NAME, a.CATEGORY_TYPE, a.CATEGORY_DESC, ")
            .AppendLine(" IsNull(a.DISPLAY_NAME,'') as DISPLAY_NAME, IsNull(a.SEQ_NO,0) as SEQ_NO, IsNull(a.DEFAULT_FLAG,0) as DEFAULT_FLAG, ")
            .AppendLine(" IsNull(a.CONFIGURATION_RULE,'') as CONFIGURATION_RULE, IsNull(a.NOT_EXPAND_CATEGORY,'') as NOT_EXPAND_CATEGORY, ")
            .AppendLine(" IsNull(a.SHOW_HIDE,0) as SHOW_HIDE, IsNull(a.EZ_FLAG,0) as EZ_FLAG, IsNull(b.STATUS,'') as STATUS_OLD, 0 as SHIP_WEIGHT,  ")
            .AppendLine(" 0 as NET_WEIGHT, IsNull(b.MATERIAL_GROUP,'') as MATERIAL_GROUP, ")
            .AppendLine("case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as class,a.UID,a.org, '' as STATUS ")
            .AppendLine(" FROM CBOM_CATALOG_CATEGORY AS a LEFT OUTER JOIN ")
            .AppendLine(" SAP_PRODUCT AS b ON a.CATEGORY_ID = b.PART_NO ")
            .AppendLine(String.Format(" WHERE a.PARENT_CATEGORY_ID = N'{0}' and a.org='" & ShowOrg & "' and a.CATEGORY_ID<>N'{0}' ", PCatId))
            .AppendLine(" and (a.CATEGORY_TYPE='Category' or A.CATEGORY_TYPE='Component' or (a.CATEGORY_TYPE='Component' and (a.CATEGORY_ID='No Need' or a.CATEGORY_ID like '%|%'))) ")
            .AppendLine(" ORDER BY a.SEQ_NO ")
        End With
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter(qsb.ToString(), conn), cmd As New SqlClient.SqlCommand("", conn)
        Dim dt As New DataTable
        apt.Fill(dt)
        Dim compArray As New ArrayList
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE").ToString.Equals("Component", StringComparison.OrdinalIgnoreCase) And r.Item("category_id").ToString.Contains("|") Then
                Dim ps() As String = Split(r.Item("category_id").ToString, "|")
                For Each p As String In ps
                    If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                        cmd.CommandText = String.Format( _
                                                        " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " + _
                                                        " where product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + _
                                                        " and part_no ='{0}' and sales_org='{1}'", p.ToString, SAPOrg)
                        If conn.State <> ConnectionState.Open Then conn.Open()
                        If CInt(cmd.ExecuteScalar()) <= 0 Then r.Delete()
                    End If
                Next
            ElseIf r.Item("CATEGORY_TYPE").ToString.Equals("Component", StringComparison.OrdinalIgnoreCase) And Not r.Item("category_id").ToString.Contains("|") _
                And Not r.Item("category_id").ToString().ContainsV2(MyExtension.BuildIn) Then
                If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                    cmd.CommandText = String.Format( _
                                                   " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " + _
                                                   " where product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + _
                                                   " and part_no in ('{0}') and sales_org='{1}'", r.Item("CATEGORY_ID").ToString, SAPOrg)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    If CInt(cmd.ExecuteScalar()) <= 0 Then r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE").ToString().Equals("Component", StringComparison.OrdinalIgnoreCase) Then
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
            If r.Item("CATEGORY_TYPE").ToString().Equals("Category", StringComparison.OrdinalIgnoreCase) Then
                If compArray.Contains(r.Item("category_id").ToString()) = False Then
                    compArray.Add(r.Item("category_id").ToString())
                Else
                    r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        cmd.CommandText = String.Format( _
            " select count(category_id) as c FROM CBOM_CATALOG_CATEGORY where org='" & ShowOrg & "' and parent_category_id='Root' " + _
            " and category_id='{0}'", PCatId)
        If conn.State <> ConnectionState.Open Then conn.Open()
        If (PCatId.ToUpper().EndsWith("-BTO") Or PCatId.ToUpper().StartsWith("C-CTOS-")) AndAlso _
            CInt(cmd.ExecuteScalar()) > 0 Then
            Dim r As DataRow = dt.NewRow()
            With r
                .Item("CATEGORY_ID") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("CATEGORY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("CATEGORY_TYPE") = "Category"
                .Item("CATEGORY_DESC") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("DISPLAY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("SEQ_NO") = 99 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
            End With
            dt.Rows.Add(r)
            cmd.CommandText = String.Format( _
                " select count(category_name) as c from cbom_catalog_category where org='" & ShowOrg & "' and category_id not like '%-CTOS%' " + _
                " and category_id not like '%SYS-%' and category_id='{0}' and isnull(EZ_Flag,'0')<>'2'", PCatId)
            If conn.State <> ConnectionState.Open Then conn.Open()
            If CInt(cmd.ExecuteScalar()) > 0 Then
                Dim r2 As DataRow = dt.NewRow()
                With r2
                    .Item("CATEGORY_ID") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_TYPE") = "Category"
                    .Item("CATEGORY_DESC") = "CTOS note for " + PCatId.ToUpper()
                    .Item("DISPLAY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("SEQ_NO") = 100 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                    .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                    .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                    .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                End With
                If SAPOrg.ToUpper.Trim <> "TW01" Then
                    dt.Rows.Add(r2)
                End If
            End If
        Else
            If PCatId.ToUpper().StartsWith("EXTENDED WARRANTY FOR") Then
                Dim AgsEwList As List(Of AGS_EW_PN)
                '= GetSpecialExWarrantyItemByRootCatId(Replace(UCase(PCatId), "EXTENDED WARRANTY FOR ", ""))
                qsb = New System.Text.StringBuilder
                With qsb
                    .AppendLine(" SELECT PART_NO as CATEGORY_ID, PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                    .AppendLine(" PRODUCT_DESC as CATEGORY_DESC, PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                    .AppendLine(" (CASE PART_NO WHEN 'AGS-EW/DOA-03' THEN 'DEFAULT' ELSE '' END), '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(STATUS,'') as STATUS, ")
                    .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                    .AppendLine(" FROM  SAP_PRODUCT ")
                    .AppendLine(" WHERE 1=1 ")
                    If AgsEwList IsNot Nothing AndAlso AgsEwList.Count > 0 Then
                        Dim arAgs As New ArrayList
                        For Each ew As AGS_EW_PN In AgsEwList
                            arAgs.Add("'" + ew.PartNo + "'")
                        Next
                        Dim strPNList As String = "(" + String.Join(",", arAgs.ToArray()) + ")"
                        .AppendLine(String.Format(" and (PART_NO in {0} or PART_NO in {1}) ", ConfigurationManager.AppSettings("StdAGSEWPN"), strPNList))
                    Else
                        .AppendLine(String.Format(" and PART_NO in {0} ", ConfigurationManager.AppSettings("StdAGSEWPN")))
                    End If
                    .AppendLine(" order by PART_NO ")
                End With
                apt = New SqlClient.SqlDataAdapter(qsb.ToString(), conn)
                If conn.State <> ConnectionState.Open Then conn.Open()
                apt.Fill(dt)
            Else
                If PCatId.ToUpper().StartsWith("CTOS NOTE FOR") Then
                    qsb = New System.Text.StringBuilder
                    With qsb
                        .AppendLine(" SELECT distinct a.PART_NO as CATEGORY_ID, a.PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                        .AppendLine(" b.PRODUCT_DESC as CATEGORY_DESC, b.PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                        .AppendLine(" '' as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(b.STATUS,'') as STATUS, ")
                        .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                        .AppendLine(" from CBOM_CATEGORY_CTOS_NOTE a left join SAP_PRODUCT b on a.part_no=b.part_no ")
                        .AppendLine(" order by a.PART_NO ")
                    End With
                    apt = New SqlClient.SqlDataAdapter(qsb.ToString(), conn)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    apt.Fill(dt)
                End If
            End If
        End If
        If conn.State <> ConnectionState.Closed Then conn.Close()
        dt.TableName = "CBOM"
        Return dt
    End Function
    <WebMethod()> _
    Public Function getCatalogList(ByVal RBU As String, ByVal SAPOrg As String) As CBOMDS.CBOM_CATALOGDataTable
        Dim retDt As New CBOMDS.CBOM_CATALOGDataTable
        Dim strSqlCmd As String = String.Empty
        Dim ShowOrg As String = getShowOrg(RBU, SAPOrg)

        'strSqlCmd = _
        '"select DISTINCT IsNull(Catalog_Type, '') as Catalog_Type from CBOM_Catalog WHERE Catalog_Org='" & ShowOrg.ToString.ToUpper & "' and Catalog_Type <>'' "
        'Frank 2015/11/02 AEU user's request, sorting catalog items
        strSqlCmd = " Select s.Catalog_Type,s.Catalog_Name From "
        strSqlCmd &= " (Select IsNull(a.Catalog_Type,'') as Catalog_Type,IsNull(b.LOCAL_NAME,a.Catalog_Type) as Catalog_Name from CBOM_Catalog a "
        strSqlCmd &= " left join CBOM_CATALOG_LOCALNAME b on a.Catalog_Type=b.catalog_type and a.Catalog_Org=b.org "
        strSqlCmd &= " WHERE a.Catalog_Org='" & ShowOrg.ToString.ToUpper & "' and a.Catalog_Type <>'' group by a.Catalog_Type,b.LOCAL_NAME) s "
        If ShowOrg.Equals("EU", StringComparison.InvariantCultureIgnoreCase) Then
            strSqlCmd &= " Order by s.Catalog_Name"
        End If

        Dim BtosDT As New DataTable
        BtosDT = dbUtil.dbGetDataTable("B2B", strSqlCmd)
        For Each r As DataRow In BtosDT.Rows
            retDt.AddCBOM_CATALOGRow("", r.Item("Catalog_Name"), r.Item("Catalog_Type"), "", "", "", "")
        Next
        Return retDt
    End Function
    <WebMethod()> _
    Public Function getCatalogLocalName(ByVal Catalog_type As String, ByVal SAPOrg As String) As String
        Dim strSqlCmd As String = String.Format("SELECT TOP 1 LOCAL_NAME  FROM  CBOM_CATALOG_LOCALNAME where catalog_type ='{0}' and org='{1}'", Catalog_type.Trim(), SAPOrg.Trim())
        Dim LocalDT As DataTable = dbUtil.dbGetDataTable("B2B", strSqlCmd)
        If LocalDT.Rows.Count = 1 Then
            Return LocalDT.Rows(0).Item("LOCAL_NAME")
        End If
        Return Catalog_type
    End Function

    <WebMethod()> _
    Public Function getCBOMList(ByVal RBU As String, ByVal SAPOrg As String, ByVal Catalog As String, ByVal CompanyId As String) As CBOMDS.CBOM_CATALOGDataTable
        Dim retDt As New CBOMDS.CBOM_CATALOGDataTable

        Dim ShowOrg As String = getShowOrg(RBU, SAPOrg)

        Catalog = Catalog.Trim()
        Dim T_strselect As String = ""
        Dim T_strWhere As String = ""

        If Catalog <> "CTOS" Then
            If Catalog = "Pre-Configuration" Then
                T_strselect = " select distinct '' as SNO,CATALOG_NAME as CATALOG_NAME,a.CATALOG_DESC,CATALOG_NAME as IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " & _
                          " from CBOM_CATALOG a " & _
                          " where a.Catalog_Org='" & ShowOrg.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & Catalog & "'"
                T_strWhere = ""
            Else
                If Catalog = "eStoreBTO" Then
                    T_strselect = " select distinct '' as SNO,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                    " from CBOM_CATALOG a " &
                    " where a.Catalog_Org='" & ShowOrg.ToString.ToUpper & "' and Created_by='EZ'"
                    T_strWhere = ""
                Else
                    If ShowOrg.ToUpper = "US" Then
                        T_strselect = " select distinct '' as SNO,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                                      " from CBOM_CATALOG a " &
                                      " where a.Catalog_Org='" & ShowOrg.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & Catalog & "'"
                        T_strWhere = ""
                    Else
                        T_strselect = " select distinct '' as SNO,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                                      " from CBOM_CATALOG a inner join SAP_PRODUCT_STATUS_ORDERABLE b on a.CATALOG_ID = b.PART_NO" &
                                      " where a.Catalog_Org='" & ShowOrg.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & Catalog & "' and b.SALES_ORG like '" & SAPOrg & "%'"
                        T_strWhere = ""
                    End If

                End If
            End If
        Else
            T_strselect = " select distinct '' as SNO,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly,c.COMPANY_ID , a.CREATED" & _
                          " from CBOM_CATALOG a " & _
                          " inner join PRODUCT_CUSTOMER_DICT c" & _
                          " on a.CATALOG_NAME=c.PART_NO " & _
                          " where a.Catalog_Org='" & ShowOrg.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & Catalog & "' and a.CATALOG_NAME=c.PART_NO"
            T_strWhere = " and c.Company_id='" & CompanyId & "' "


            T_strselect = T_strselect & T_strWhere '& " Order By c.COMPANY_ID asc,a.CATALOG_NAME asc"
            'ICC 2016/8/4 HotFix about PRODUCT_CUSTOMER_DICT
            T_strselect &= String.Format(" union select distinct '' as SNO,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '{0}' as COMPANY_ID, " &
                                        " a.CREATED from CBOM_CATALOG a where a.Catalog_Org='{1}' and a.CATALOG_TYPE like '%{2}' and a.CATALOG_NAME like 'C-CTOS-{0}%' " &
                                        " order by a.CATALOG_NAME asc ", CompanyId, ShowOrg.ToString.ToUpper, Catalog)
        End If
        'HttpContext.Current.Response.Write(T_strselect)
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("b2b", T_strselect)
        For Each r As DataRow In dt.Rows
            retDt.AddCBOM_CATALOGRow("", IIf(IsDBNull(r.Item("catalog_name")), "", r.Item("catalog_name")), "", "",
             IIf(IsDBNull(r.Item("catalog_desc")), "", r.Item("catalog_desc")), IIf(IsDBNull(r.Item("image_id")), "", r.Item("image_id")), "")
        Next
        Return retDt
    End Function
    Public Function getShowOrg(ByVal RBU As String, ByVal SAPOrg As String) As String
        Dim ShowOrg As String = "EU"
        ShowOrg = Left(MYSAPBIZ.RBU2Org(RBU, SAPOrg), 2)
        If RBU.Equals("ACL", StringComparison.OrdinalIgnoreCase) And
            SAPOrg.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
            ShowOrg = "EU"
        ElseIf SAPOrg.ToUpper.Equals("US10") Then
            ShowOrg = "US"
        End If
        Return ShowOrg
    End Function
    <WebMethod()>
    Public Function getBTOParentList(ByVal RBU As String, ByVal SAPOrg As String, ByVal PN As String) As CBOMDS.CBOM_CATALOGDataTable
        Dim retDt As New CBOMDS.CBOM_CATALOGDataTable

        Dim ShowOrg As String = getShowOrg(RBU, SAPOrg)

        Dim T_strselect As String = String.Format("select isnull(CATALOG_ID,'') as CATALOG_ID,isnull(CATALOG_TYPE,'') as CATALOG_TYPE from CBOM_CATALOG where CATALOG_ID like '%{0}%' and CATALOG_ORG = '{1}'", PN, ShowOrg)


        'HttpContext.Current.Response.Write(T_strselect)
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("b2b", T_strselect)
        For Each r As DataRow In dt.Rows
            retDt.AddCBOM_CATALOGRow(r.Item("catalog_id"), "", r.Item("catalog_type"), "",
             "", "", "")
        Next
        Return retDt
    End Function


    Public Function GetCBOMDatatable(ByVal PCatId As String, ByVal SAPOrg As String, ByVal ShowOrg As String, Optional ByRef RetDatatable As DataTable = Nothing) As CBOMDS.CBOM_CATALOG_CATEGORYDataTable

        'ICC & Ryan 2016/4/13 If company ID is in ZTSD_106C, then do not show 968T parts in e-Configurator.
        Dim hidePtrade As Boolean = False
        If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("company_id") IsNot Nothing AndAlso HttpContext.Current.Session("org_id") IsNot Nothing Then
            If Not Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(HttpContext.Current.Session("company_id")) Then
                hidePtrade = True
            End If
        End If

        'Ryan 20160419 If is not internal user, then hide X/Y parts in configurator.
        Dim hideXYParts As Boolean = False
        'If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("user_id") IsNot Nothing Then
        '    If Not Util.IsInternalUser(HttpContext.Current.Session("user_id")) Then
        '        hideXYParts = True
        '    End If
        'End If

        'Ryan 20160801 If is not internal user, then hide T/P parts in configurator.
        Dim hideTPParts As Boolean = False
        If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("user_id") IsNot Nothing Then
            If Not Util.IsInternalUser(HttpContext.Current.Session("user_id")) Then
                hideTPParts = True
            End If
        End If

        'Ryan 20160830 Add country code parameter for 3S litigation parts validation
        'Dim CountryCode As String = String.Empty
        'Dim CheckLitigation As Boolean = False
        'If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("company_id") IsNot Nothing AndAlso HttpContext.Current.Session("CART_ID") IsNot Nothing Then
        '    CountryCode = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getCountryCodeByERPID(Advantech.Myadvantech.Business.UserRoleBusinessLogic.MYAgetShiptoIDBySoldtoID(Session("company_id").ToString(), Session("CART_ID").ToString))
        '    CheckLitigation = True
        'End If

        Dim retDt As New CBOMDS.CBOM_CATALOG_CATEGORYDataTable, qsb As New System.Text.StringBuilder

        With qsb
            .AppendLine(" SELECT a.PARENT_CATEGORY_ID, case when a.CATEGORY_ID='No Need' then 'Build In' else a.CATEGORY_ID end as CATEGORY_ID, IsNull(a.CATEGORY_NAME,'') as CATEGORY_NAME, IsNull(a.CATEGORY_TYPE,'') as CATEGORY_TYPE, IsNull(a.CATEGORY_DESC,'') as CATEGORY_DESC, ")
            'If CheckLitigation = True Then .AppendLine(" case when (select COUNT(*) from PatentLitigationParts where partno = a.CATEGORY_ID and countrycode = '" + CountryCode + "') >= 1 then 1 else 0 end as isLitigation , ")
            .AppendLine(" IsNull(a.DISPLAY_NAME,'') as DISPLAY_NAME, IsNull(a.SEQ_NO,0) as SEQ_NO, IsNull(a.DEFAULT_FLAG,0) as DEFAULT_FLAG, ")
            .AppendLine(" IsNull(a.CONFIGURATION_RULE,'') as CONFIGURATION_RULE, IsNull(a.NOT_EXPAND_CATEGORY,'') as NOT_EXPAND_CATEGORY, ")
            .AppendLine(" IsNull(a.SHOW_HIDE,0) as SHOW_HIDE, IsNull(a.EZ_FLAG,0) as EZ_FLAG, IsNull(b.STATUS,'') as STATUS_OLD, 0 as SHIP_WEIGHT,  ")
            .AppendLine(" 0 as NET_WEIGHT, IsNull(b.MATERIAL_GROUP,'') as MATERIAL_GROUP, ")
            .AppendLine("case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as class,a.UID,a.org, '' as STATUS, case when EZ_FLAG = '2' and IMAGE_ID='created_by_ming' then ISNULL(a.EXTENDED_DESC,'') else '' end as EXTENDED_DESC ") 'ICC 2015/4/14 Get EXTENDED_DESC column for eStore cbom to show detail message (only need eStore data)
            If hideTPParts = True Then .AppendLine(" , c.ABC_INDICATOR ")
            .AppendLine(" FROM CBOM_CATALOG_CATEGORY AS a LEFT OUTER JOIN ")
            .AppendLine(" SAP_PRODUCT AS b ON a.CATEGORY_ID = b.PART_NO ")
            If hideTPParts = True Then .AppendLine(" left join SAP_PRODUCT_ABC c on b.PART_NO = c.PART_NO ")
            .AppendLine(String.Format(" WHERE a.PARENT_CATEGORY_ID = N'{0}' and a.org='" & ShowOrg & "' and a.CATEGORY_ID<>N'{0}' ", PCatId))
            .AppendLine(" and (a.CATEGORY_TYPE='Category' or A.CATEGORY_TYPE='Component' or (a.CATEGORY_TYPE='Component' and (a.CATEGORY_ID='No Need' or a.CATEGORY_ID like '%|%')) or CATEGORY_TYPE = 'extendedcategory' or CATEGORY_TYPE = 'extendedComponent') ")
            If hidePtrade = True Then .AppendLine(" and a.CATEGORY_ID not like '968T%' ")
            If hideXYParts = True Then .AppendLine(" and left(a.CATEGORY_ID,1) not in ('X','Y') ")
            If hideTPParts = True Then
                .AppendLine(" and isnull(c.ABC_INDICATOR,'') not IN ('T','P') ")
                .AppendLine(" and isnull(c.PLANT,'" + Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(ShowOrg) + "')  = '" + Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(ShowOrg) + "' ")
            End If
            .AppendLine(" ORDER BY a.SEQ_NO ")
        End With
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter(qsb.ToString(), conn), cmd As New SqlClient.SqlCommand("", conn)
        Dim dt As New DataTable
        apt.Fill(dt)
        Dim compArray As New ArrayList
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE").ToString.Equals("Component", StringComparison.OrdinalIgnoreCase) And r.Item("category_id").ToString.Contains("|") Then
                Dim ps() As String = Split(r.Item("category_id").ToString, "|")
                For Each p As String In ps
                    If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                        cmd.CommandText = String.Format(
                                                        " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " +
                                                        " where product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus") +
                                                        " and part_no ='{0}' and sales_org='{1}'", p.ToString, SAPOrg)
                        If conn.State <> ConnectionState.Open Then conn.Open()
                        If CInt(cmd.ExecuteScalar()) <= 0 Then r.Delete()
                    End If
                Next
            ElseIf (r.Item("CATEGORY_TYPE").ToString.Equals("Component", StringComparison.OrdinalIgnoreCase) Or r.Item("CATEGORY_TYPE").ToString.Equals("extendedComponent", StringComparison.OrdinalIgnoreCase)) _
                And Not r.Item("category_id").ToString.Contains("|") _
                And Not r.Item("category_id").ToString().ContainsV2(MyExtension.BuildIn) Then
                If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                    cmd.CommandText = String.Format(
                                                   " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " +
                                                   " where product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus") +
                                                   " and part_no in ('{0}') and sales_org='{1}'", r.Item("CATEGORY_ID").ToString.Trim, SAPOrg)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    If CInt(cmd.ExecuteScalar()) <= 0 Then r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE").ToString().Equals("Component", StringComparison.OrdinalIgnoreCase) Or r.Item("CATEGORY_TYPE").ToString().Equals("extendedComponent", StringComparison.OrdinalIgnoreCase) Then
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
            If r.Item("CATEGORY_TYPE").ToString().Equals("Category", StringComparison.OrdinalIgnoreCase) Or r.Item("CATEGORY_TYPE").ToString().Equals("extendedcategory", StringComparison.OrdinalIgnoreCase) Then
                If compArray.Contains(r.Item("category_id").ToString()) = False Then
                    compArray.Add(r.Item("category_id").ToString())
                Else
                    r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()

        'Ryan 20160830 Ligigation parts validation
        'If CheckLitigation = True Then
        '    For Each r As DataRow In dt.Rows
        '        If r.Item("isLitigation").ToString().Equals("1", StringComparison.OrdinalIgnoreCase) Then
        '            r.Delete()
        '        End If
        '    Next
        '    dt.AcceptChanges()
        'End If

        'for CN Block MEDC product to show price
        If SAPOrg.ToString.ToUpper.StartsWith("CN") AndAlso Not Util.IsInternalUser2() Then
            For Each r As DataRow In dt.Rows
                If String.Equals(r.Item("category_type"), "component", StringComparison.OrdinalIgnoreCase) AndAlso SAPDAL.CommonLogic.isMEDC(r.Item("category_id").ToString()) Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()
        End If
        cmd.CommandText = String.Format( _
            " select count(category_id) as c FROM CBOM_CATALOG_CATEGORY where org='" & ShowOrg & "' and parent_category_id='Root' " + _
            " and category_id='{0}'", PCatId)
        If conn.State <> ConnectionState.Open Then conn.Open()
        'Frank:2013/02/20 
        'Extended warranty option need to be applied for all the configuration system
        'If (PCatId.ToUpper().EndsWith("-BTO") Or PCatId.ToUpper().StartsWith("C-CTOS-")) AndAlso (Not PCatId.ToUpper().Contains(" FOR ")) AndAlso _
        '    CInt(cmd.ExecuteScalar()) > 0 Then
        If (PCatId.ToUpper().EndsWith("-BTO") Or PCatId.ToUpper().StartsWith("C-CTOS-") Or PCatId.ToUpper().StartsWith("EZ-")) _
            AndAlso (Not PCatId.ToUpper().Contains(" FOR ")) AndAlso CInt(cmd.ExecuteScalar()) > 0 Then

            'Ryan 20160427 Block adding EW for particular part which is defined in CBOM_WithoutEW
            If Not Advantech.Myadvantech.Business.PartBusinessLogic.IsNoEWParts(PCatId) Then
                Dim r As DataRow = dt.NewRow()
                With r
                    .Item("CATEGORY_ID") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("CATEGORY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("CATEGORY_TYPE") = "Category"
                    .Item("CATEGORY_DESC") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("DISPLAY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("SEQ_NO") = 99 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                    .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                    .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                    .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                End With
                dt.Rows.Add(r)
            End If

            cmd.CommandText = String.Format( _
                " select count(category_name) as c from cbom_catalog_category where org='" & ShowOrg & "' and category_id not like '%-CTOS%' " + _
                " and category_id not like '%SYS-%' and category_id='{0}' and isnull(EZ_Flag,'0')<>'2'", PCatId)
            If conn.State <> ConnectionState.Open Then conn.Open()
            If CInt(cmd.ExecuteScalar()) > 0 Then
                Dim r2 As DataRow = dt.NewRow()
                With r2
                    .Item("CATEGORY_ID") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_TYPE") = "Category"
                    .Item("CATEGORY_DESC") = "CTOS note for " + PCatId.ToUpper()
                    .Item("DISPLAY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("SEQ_NO") = 100 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                    .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                    .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                    .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                End With
                If SAPOrg.ToUpper.Trim = "EU10" Then
                    dt.Rows.Add(r2)
                End If
            End If
        Else
            If PCatId.ToUpper().StartsWith("EXTENDED WARRANTY FOR") Then
                If dbUtil.dbGetDataTable(CBOMSetting.DBConn, String.Format("select CATEGORY_ID from dbo.CBOM_CATALOG_CATEGORY where  CATEGORY_ID ='{0}' AND EZ_FLAG=2 and ORG ='{1}'", PCatId, ShowOrg)).Rows.Count = 0 Then
                    qsb = New System.Text.StringBuilder
                    With qsb
                        .AppendLine(" SELECT A.PART_NO as CATEGORY_ID, A.PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                        .AppendLine(" A.PRODUCT_DESC as CATEGORY_DESC, A.PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                        .AppendLine(" (CASE A.PART_NO WHEN 'AGS-EW/DOA-03' THEN 'DEFAULT' ELSE '' END) as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(A.STATUS,'') as STATUS, ")
                        .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, A.MATERIAL_GROUP, case A.RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                        .AppendLine(" From SAP_PRODUCT A INNER JOIN SAP_PRODUCT_ORG B ON A.PART_NO=B.PART_NO  ")
                        .AppendFormat(" WHERE  B.ORG_ID='{0}' ", SAPOrg)
                        'If AgsEwList IsNot Nothing AndAlso AgsEwList.Count > 0 Then
                        '    Dim arAgs As New ArrayList
                        '    For Each ew As AGS_EW_PN In AgsEwList
                        '        arAgs.Add("'" + ew.PartNo + "'")
                        '    Next
                        '    Dim strPNList As String = "(" + String.Join(",", arAgs.ToArray()) + ")"
                        '    .AppendLine(String.Format(" and (PART_NO in {0} or PART_NO in {1}) ", ConfigurationManager.AppSettings("StdAGSEWPN"), strPNList))
                        'Else
                        .AppendLine(String.Format(" and A.PART_NO in {0} ", ConfigurationManager.AppSettings("StdAGSEWPN")))
                        'End If
                        .AppendLine(" order by A.PART_NO ")
                    End With
                    'Util.SendEmail("ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "SQL:", qsb.ToString(), True, "", "")
                    apt = New SqlClient.SqlDataAdapter(qsb.ToString(), conn)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    apt.Fill(dt)

                    If Not PCatId.ToString.ToUpper.Contains("EDDEAL21") Then
                        For Each r As DataRow In dt.Rows
                            If r.Item("CATEGORY_ID").ToString().ToUpper.StartsWith("AGS-EW/DOA") Then
                                r.Delete()
                            End If
                        Next
                    End If
                    dt.AcceptChanges()
                End If
            Else
                If PCatId.ToUpper().StartsWith("CTOS NOTE FOR") Then
                    qsb = New System.Text.StringBuilder
                    With qsb
                        .AppendLine(" SELECT distinct a.PART_NO as CATEGORY_ID, a.PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                        .AppendLine(" b.PRODUCT_DESC as CATEGORY_DESC, b.PRODUCT_DESC as DISPLAY_NAME, a.SEQ_NUMBER as SEQ_NO, 0 as DEFAULT_FLAG, ")
                        .AppendLine(" '' as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(b.STATUS,'') as STATUS, ")
                        .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, IsNull(MATERIAL_GROUP,'') as MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                        .AppendLine(" from CBOM_CATEGORY_CTOS_NOTE a left join SAP_PRODUCT b on a.part_no=b.part_no ")
                        .AppendFormat(" INNER JOIN SAP_PRODUCT_ORG c ON b.PART_NO=c.PART_NO AND c.ORG_ID ='{0}' ", SAPOrg)
                        .AppendLine(" order by a.SEQ_NUMBER ")
                    End With
                    apt = New SqlClient.SqlDataAdapter(qsb.ToString(), conn)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    apt.Fill(dt)

                ElseIf PCatId.StartsWith("Std Assembly,Functional Testing", StringComparison.OrdinalIgnoreCase) AndAlso SAPOrg.ToUpper.ToString.Equals("JP01") Then
                    'Ryan 20161219 Add for AJP, dynamically add AGS-SYS-A, AGS-SYS-B
                    Dim addSYSA As Boolean = True, addSYSB As Boolean = True, addIQC As Boolean = True

                    For Each r As DataRow In dt.Rows
                        If r.Item("CATEGORY_ID").ToString().ToUpper.Equals("AGS-CTOS-SYS-A") Then
                            addSYSA = False
                        ElseIf r.Item("CATEGORY_ID").ToString().ToUpper.Equals("AGS-CTOS-SYS-B") Then
                            addSYSB = False
                        ElseIf r.Item("CATEGORY_ID").ToString().ToUpper.Equals("OPTION 100 IQC") Then
                            addIQC = False
                        End If
                    Next
                    If addSYSA Then
                        Dim rA As DataRow = dt.NewRow()
                        With rA
                            .Item("CATEGORY_ID") = "AGS-CTOS-SYS-A"
                            .Item("CATEGORY_NAME") = "AGS-CTOS-SYS-A"
                            .Item("CATEGORY_TYPE") = "Component"
                            .Item("CATEGORY_DESC") = "Standard Assembly + Functional Testing + Software"
                            .Item("DISPLAY_NAME") = "AGS-CTOS-SYS-A"
                            .Item("SEQ_NO") = 1 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                            .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                            .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                            .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                        End With
                        dt.Rows.Add(rA)
                    End If
                    If addSYSB Then
                        Dim rB As DataRow = dt.NewRow()
                        With rB
                            .Item("CATEGORY_ID") = "AGS-CTOS-SYS-B"
                            .Item("CATEGORY_NAME") = "AGS-CTOS-SYS-B"
                            .Item("CATEGORY_TYPE") = "Component"
                            .Item("CATEGORY_DESC") = "Standard Assembly + Functional Testing + Software"
                            .Item("DISPLAY_NAME") = "AGS-CTOS-SYS-B"
                            .Item("SEQ_NO") = 1 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                            .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                            .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                            .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                        End With
                        dt.Rows.Add(rB)
                    End If
                    If addIQC Then
                        Dim rC As DataRow = dt.NewRow()
                        With rC
                            .Item("CATEGORY_ID") = "OPTION 100 IQC"
                            .Item("CATEGORY_NAME") = "OPTION 100 IQC"
                            .Item("CATEGORY_TYPE") = "Component"
                            .Item("CATEGORY_DESC") = "Assemble in AJSC（BIOS, General IQC)"
                            .Item("DISPLAY_NAME") = "OPTION 100 IQC"
                            .Item("SEQ_NO") = 1 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                            .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                            .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                            .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                        End With
                        dt.Rows.Add(rC)
                    End If
                End If
            End If
        End If
        If conn.State <> ConnectionState.Closed Then conn.Close()

        For Each BomRec As DataRow In dt.Rows
            With BomRec
                If .Item("PARENT_CATEGORY_ID") Is DBNull.Value Then .Item("PARENT_CATEGORY_ID") = ""
                If .Item("CATEGORY_ID") Is DBNull.Value Then .Item("CATEGORY_ID") = ""
                If .Item("CATEGORY_NAME") Is DBNull.Value Then .Item("CATEGORY_NAME") = ""
                If .Item("CATEGORY_DESC") Is DBNull.Value Then .Item("CATEGORY_DESC") = ""
                If .Item("DISPLAY_NAME") Is DBNull.Value Then .Item("DISPLAY_NAME") = ""
                If .Item("CATEGORY_TYPE") Is DBNull.Value Then .Item("CATEGORY_TYPE") = ""
                If .Item("CONFIGURATION_RULE") Is DBNull.Value Then .Item("CONFIGURATION_RULE") = ""
                If .Item("NOT_EXPAND_CATEGORY") Is DBNull.Value Then .Item("NOT_EXPAND_CATEGORY") = ""
                If .Item("SHOW_HIDE") Is DBNull.Value Then .Item("SHOW_HIDE") = 1
                If .Item("EZ_FLAG") Is DBNull.Value Then .Item("EZ_FLAG") = 0
                If .Item("STATUS_OLD") Is DBNull.Value Then .Item("STATUS_OLD") = ""
                If .Item("SHIP_WEIGHT") Is DBNull.Value Then .Item("SHIP_WEIGHT") = 0
                If .Item("NET_WEIGHT") Is DBNull.Value Then .Item("NET_WEIGHT") = 0
                If .Item("MATERIAL_GROUP") Is DBNull.Value Then .Item("MATERIAL_GROUP") = ""
                If .Item("RoHS") Is DBNull.Value Then .Item("RoHS") = "n"
                If .Item("class") Is DBNull.Value Then .Item("class") = ""
                If .Item("UID") Is DBNull.Value Then .Item("UID") = ""
                If .Item("org") Is DBNull.Value Then .Item("org") = ""
                If .Item("STATUS") Is DBNull.Value Then .Item("STATUS") = ""
                If .Item("EXTENDED_DESC") Is DBNull.Value Then .Item("EXTENDED_DESC") = String.Empty 'ICC 2015/4/7 Add new column [EXTENDED_DESC]
                retDt.AddCBOM_CATALOG_CATEGORYRow( _
                     .Item("PARENT_CATEGORY_ID"), .Item("CATEGORY_ID"), .Item("CATEGORY_NAME"), .Item("CATEGORY_TYPE"), .Item("CATEGORY_DESC"), _
                     .Item("DISPLAY_NAME"), .Item("SEQ_NO"), .Item("DEFAULT_FLAG"), .Item("CONFIGURATION_RULE"), .Item("NOT_EXPAND_CATEGORY"), _
                     .Item("SHOW_HIDE"), .Item("EZ_FLAG"), .Item("STATUS_OLD"), .Item("SHIP_WEIGHT"), .Item("NET_WEIGHT"), .Item("MATERIAL_GROUP"), .Item("RoHS"), _
                     .Item("class"), .Item("UID"), .Item("org"), .Item("STATUS"), .Item("EXTENDED_DESC")) 'ICC 2015/4/7 Add new column [EXTENDED_DESC]
            End With
        Next

        RetDatatable = dt
        Return retDt
    End Function
    'ICC & Ryan 2016/4/13 Add seesion
    <WebMethod(EnableSession:=True)>
    Public Function GetCBOM2(ByVal ParentCategoryId As String, ByVal RBU As String, ByVal SAPOrg As String, ByVal RootId As String) As CBOMDS.CBOM_CATALOG_CATEGORYDataTable
        Dim ShowOrg As String = getShowOrg(RBU, SAPOrg)

        If RBU = "AJP" AndAlso Not String.IsNullOrEmpty(RootId) AndAlso RootId.ToString.ToUpper.StartsWith("EIS") Then
            ShowOrg = "JP"
        End If

        Dim PCatId As String = Replace(Trim(ParentCategoryId), "'", "''")
        Return GetCBOMDatatable(ParentCategoryId, SAPOrg, ShowOrg)
    End Function
    'ICC & Ryan 2016/4/13 Add seesion
    <WebMethod(EnableSession:=True)> _
    Public Function GeteStoreCBOM(ByVal ParentCategoryId As String, ByVal RBU As String, ByVal SAPOrg As String) As CBOMDS.CBOM_CATALOG_CATEGORYDataTable
        Dim ShowOrg As String = getShowOrg(RBU, SAPOrg)
        If RBU.Equals("AJP", StringComparison.InvariantCultureIgnoreCase) AndAlso _
            SAPOrg.Equals("JP01", StringComparison.InvariantCultureIgnoreCase) Then
            ShowOrg = "JP"
        End If
        Dim PCatId As String = Replace(Trim(ParentCategoryId), "'", "''")
        Return GetCBOMDatatable(ParentCategoryId, SAPOrg, ShowOrg)
    End Function

    ''' <summary>
    ''' Frank 這是到Hierarchy ID結構來儲存BOM表的資料表來取BOM表中某個節點下的子節點
    ''' </summary>
    ''' <param name="ParentCategoryId"></param>
    ''' <param name="RBU"></param>
    ''' <param name="SAPOrg"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    <WebMethod(EnableSession:=True)> _
    Public Function GetCBOMV3(ByVal ParentCategoryId As String, ByVal RBU As String, ByVal SAPOrg As String) As CBOMDS.CBOM_CATALOG_CATEGORYDataTable
        Dim ShowOrg As String = getShowOrg(RBU, SAPOrg)
        Dim PCatId As String = Replace(Trim(ParentCategoryId), "'", "''")
        Return GetCBOMDatatableV3(ParentCategoryId, SAPOrg, ShowOrg)
    End Function

    Public Function GetCBOMDatatableV3(ByVal PCatId As String, ByVal SAPOrg As String, ByVal ShowOrg As String, Optional ByRef RetDatatable As DataTable = Nothing) As CBOMDS.CBOM_CATALOG_CATEGORYDataTable

        'ICC & Ryan 2016/4/13 If company ID is in ZTSD_106C, then do not show 968T parts in e-Configurator.
        Dim hidePtrade As Boolean = False
        If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("company_id") IsNot Nothing AndAlso HttpContext.Current.Session("org_id") IsNot Nothing Then
            If Not Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(HttpContext.Current.Session("company_id")) Then
                hidePtrade = True
            End If
        End If

        'Ryan 20160419 If is not internal user, then hide X/Y parts in configurator.
        Dim hideXYParts As Boolean = False
        'If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("user_id") IsNot Nothing Then
        '    If Not Util.IsInternalUser(HttpContext.Current.Session("user_id")) Then
        '        hideXYParts = True
        '    End If
        'End If

        'Ryan 20160801 If is not internal user, then hide T/P parts in configurator.
        Dim hideTPParts As Boolean = False
        If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("user_id") IsNot Nothing Then
            If Not Util.IsInternalUser(HttpContext.Current.Session("user_id")) Then
                hideTPParts = True
            End If
        End If

        Dim retDt As New CBOMDS.CBOM_CATALOG_CATEGORYDataTable, qsb As New System.Text.StringBuilder

        With qsb
            .AppendLine(" DECLARE @ID hierarchyid ")
            .AppendLine(" SELECT @ID = HIE_ID ")
            .AppendLine(" FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" & PCatId & "' ")
            .AppendLine("  ")
            .AppendLine(" SELECT a.ID as PARENT_CATEGORY_ID , case when a.CATEGORY_ID='No Need' then 'Build In' else a.CATEGORY_ID end as CATEGORY_ID, IsNull(a.CATEGORY_ID,'') as CATEGORY_NAME, IsNull(a.CATEGORY_TYPE,0) as CATEGORY_TYPE, IsNull(a.CATEGORY_NOTE,'') as CATEGORY_DESC ")
            .AppendLine(" ,IsNull(a.CATEGORY_ID,'') as DISPLAY_NAME, IsNull(a.SEQ_NO,0) as SEQ_NO, IsNull(a.DEFAULT_FLAG,0) as DEFAULT_FLAG ")
            .AppendLine(" ,IsNull(a.CONFIGURATION_RULE,'') as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY ")
            .AppendLine(" ,0 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(b.STATUS,'') as STATUS_OLD, 0 as SHIP_WEIGHT ")
            .AppendLine(" ,0 as NET_WEIGHT, IsNull(b.MATERIAL_GROUP,'') as MATERIAL_GROUP ")
            'ICC 2015/4/14 Get EXTENDED_DESC column for eStore cbom to show detail message (only need eStore data)
            .AppendLine(" ,case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as class,a.ID as [UID],a.org, '' as [STATUS] ")
            .AppendLine(" ,'' as EXTENDED_DESC ")

            If hideTPParts = True Then .AppendLine(" , c.ABC_INDICATOR ")
            .AppendLine(" FROM CBOM_CATALOG_CATEGORY_V2 AS a LEFT OUTER JOIN ")
            .AppendLine(" SAP_PRODUCT AS b ON a.CATEGORY_ID = b.PART_NO ")
            If hideTPParts = True Then .AppendLine(" left join SAP_PRODUCT_ABC c on b.PART_NO = c.PART_NO ")
            .AppendLine(" WHERE a.HIE_ID.GetAncestor(1) = @ID ")
            .AppendLine(" and (a.CATEGORY_TYPE=0 or A.CATEGORY_TYPE=1 or (a.CATEGORY_TYPE=1 and (a.CATEGORY_ID='No Need' or a.CATEGORY_ID like '%|%')) or CATEGORY_TYPE = 2 or CATEGORY_TYPE = 3) ")
            If hidePtrade = True Then .AppendLine(" and a.CATEGORY_ID not like '968T%' ")
            If hideXYParts = True Then .AppendLine(" and left(a.CATEGORY_ID,1) not in ('X','Y') ")
            If hideTPParts = True Then
                .AppendLine(" and isnull(c.ABC_INDICATOR,'') not IN ('T','P') ")
                .AppendLine(" and isnull(c.PLANT,'" + Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(ShowOrg) + "')  = '" + Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(ShowOrg) + "' ")
            End If
            .AppendLine(" ORDER BY a.SEQ_NO ")
        End With
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("CBOMV2").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter(qsb.ToString(), conn), cmd As New SqlClient.SqlCommand("", conn)
        Dim dt As New DataTable
        apt.Fill(dt)
        Dim compArray As New ArrayList
        For Each r As DataRow In dt.Rows
            'If r.Item("CATEGORY_TYPE").ToString.Equals("Component", StringComparison.OrdinalIgnoreCase) And r.Item("category_id").ToString.Contains("|") Then
            If r.Item("CATEGORY_TYPE") = 2 And r.Item("category_id").ToString.Contains("|") Then
                Dim ps() As String = Split(r.Item("category_id").ToString, "|")
                For Each p As String In ps
                    If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                        cmd.CommandText = String.Format(
                                                        " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " +
                                                        " where product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus") +
                                                        " and part_no ='{0}' and sales_org='{1}'", p.ToString, SAPOrg)
                        If conn.State <> ConnectionState.Open Then conn.Open()
                        If CInt(cmd.ExecuteScalar()) <= 0 Then r.Delete()
                    End If
                Next
                ' ElseIf (r.Item("CATEGORY_TYPE").ToString.Equals("Component", StringComparison.OrdinalIgnoreCase) Or r.Item("CATEGORY_TYPE").ToString.Equals("extendedComponent", StringComparison.OrdinalIgnoreCase)) _
            ElseIf (r.Item("CATEGORY_TYPE") = 2 Or r.Item("CATEGORY_TYPE") = 4) _
                And Not r.Item("category_id").ToString.Contains("|") _
                And Not r.Item("category_id").ToString().ContainsV2(MyExtension.BuildIn) Then

                If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                    cmd.CommandText = String.Format( _
                                                   " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " + _
                                                   " where product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + _
                                                   " and part_no in ('{0}') and sales_org='{1}'", r.Item("CATEGORY_ID").ToString, SAPOrg)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    If CInt(cmd.ExecuteScalar()) <= 0 Then r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        For Each r As DataRow In dt.Rows
            'If r.Item("CATEGORY_TYPE").ToString().Equals("Component", StringComparison.OrdinalIgnoreCase) Or r.Item("CATEGORY_TYPE").ToString().Equals("extendedComponent", StringComparison.OrdinalIgnoreCase) Then
            If r.Item("CATEGORY_TYPE") = 2 Or r.Item("CATEGORY_TYPE") = 4 Then
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
            'If r.Item("CATEGORY_TYPE").ToString().Equals("Category", StringComparison.OrdinalIgnoreCase) Or r.Item("CATEGORY_TYPE").ToString().Equals("extendedcategory", StringComparison.OrdinalIgnoreCase) Then
            If r.Item("CATEGORY_TYPE") = 1 Or r.Item("CATEGORY_TYPE") = 4 Then
                If compArray.Contains(r.Item("category_id").ToString()) = False Then
                    compArray.Add(r.Item("category_id").ToString())
                Else
                    r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        'for CN Block MEDC product to show price
        If SAPOrg.ToString.ToUpper.StartsWith("CN") AndAlso Not Util.IsInternalUser2() Then
            For Each r As DataRow In dt.Rows
                'If String.Equals(r.Item("category_type"), "component", StringComparison.OrdinalIgnoreCase) AndAlso SAPDAL.CommonLogic.isMEDC(r.Item("category_id").ToString()) Then
                If r.Item("category_type") = 2 AndAlso SAPDAL.CommonLogic.isMEDC(r.Item("category_id").ToString()) Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()
        End If
        cmd.CommandText = String.Format( _
            " select count(category_id) as c FROM CBOM_CATALOG_CATEGORY_V2 where and ID='{0}'", PCatId)
        If conn.State <> ConnectionState.Open Then conn.Open()
        'Frank:2013/02/20 
        'Extended warranty option need to be applied for all the configuration system
        'If (PCatId.ToUpper().EndsWith("-BTO") Or PCatId.ToUpper().StartsWith("C-CTOS-")) AndAlso (Not PCatId.ToUpper().Contains(" FOR ")) AndAlso _
        '    CInt(cmd.ExecuteScalar()) > 0 Then
        If (PCatId.ToUpper().EndsWith("-BTO") Or PCatId.ToUpper().StartsWith("C-CTOS-") Or PCatId.ToUpper().StartsWith("EZ-")) _
            AndAlso (Not PCatId.ToUpper().Contains(" FOR ")) AndAlso CInt(cmd.ExecuteScalar()) > 0 Then

            'Ryan 20160427 Block adding EW for particular part which is defined in CBOM_WithoutEW
            If Not Advantech.Myadvantech.Business.PartBusinessLogic.IsNoEWParts(PCatId) Then
                Dim r As DataRow = dt.NewRow()
                With r
                    .Item("CATEGORY_ID") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("CATEGORY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("CATEGORY_TYPE") = "Category"
                    .Item("CATEGORY_DESC") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("DISPLAY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                    .Item("SEQ_NO") = 99 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                    .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                    .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                    .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                End With
                dt.Rows.Add(r)
            End If

            'cmd.CommandText = String.Format( _
            '    " select count(category_name) as c from cbom_catalog_category where org='" & ShowOrg & "' and category_id not like '%-CTOS%' " + _
            '    " and category_id not like '%SYS-%' and category_id='{0}' and isnull(EZ_Flag,'0')<>'2'", PCatId)

            cmd.CommandText = String.Format( _
                " select count(category_name) as c from CBOM_CATALOG_CATEGORY_V2 where org='" & ShowOrg & "' and category_id not like '%-CTOS%' " + _
                " and category_id not like '%SYS-%' and ID='{0}' ", PCatId)

            If conn.State <> ConnectionState.Open Then conn.Open()
            If CInt(cmd.ExecuteScalar()) > 0 Then
                Dim r2 As DataRow = dt.NewRow()
                With r2
                    .Item("CATEGORY_ID") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_TYPE") = "Category"
                    .Item("CATEGORY_DESC") = "CTOS note for " + PCatId.ToUpper()
                    .Item("DISPLAY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("SEQ_NO") = 100 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                    .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                    .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                    .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                End With
                If SAPOrg.ToUpper.Trim = "EU10" Then
                    dt.Rows.Add(r2)
                End If
            End If
        Else
            If PCatId.ToUpper().StartsWith("EXTENDED WARRANTY FOR") Then
                'If dbUtil.dbGetDataTable(CBOMSetting.DBConn, String.Format("select CATEGORY_ID from dbo.CBOM_CATALOG_CATEGORY where  CATEGORY_ID ='{0}' AND EZ_FLAG=2 and ORG ='{1}'", PCatId, ShowOrg)).Rows.Count = 0 Then
                If dbUtil.dbGetDataTable(CBOMSetting.DBConn, String.Format("select CATEGORY_ID from dbo.CBOM_CATALOG_CATEGORY_V2 where  ID ='{0}' and ORG ='{1}'", PCatId, ShowOrg)).Rows.Count = 0 Then
                    qsb = New System.Text.StringBuilder
                    With qsb
                        .AppendLine(" SELECT A.PART_NO as CATEGORY_ID, A.PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                        .AppendLine(" A.PRODUCT_DESC as CATEGORY_DESC, A.PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                        .AppendLine(" (CASE A.PART_NO WHEN 'AGS-EW/DOA-03' THEN 'DEFAULT' ELSE '' END) as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(A.STATUS,'') as STATUS, ")
                        .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, A.MATERIAL_GROUP, case A.RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                        .AppendLine(" From SAP_PRODUCT A INNER JOIN SAP_PRODUCT_ORG B ON A.PART_NO=B.PART_NO  ")
                        .AppendFormat(" WHERE  B.ORG_ID='{0}' ", SAPOrg)
                        'If AgsEwList IsNot Nothing AndAlso AgsEwList.Count > 0 Then
                        '    Dim arAgs As New ArrayList
                        '    For Each ew As AGS_EW_PN In AgsEwList
                        '        arAgs.Add("'" + ew.PartNo + "'")
                        '    Next
                        '    Dim strPNList As String = "(" + String.Join(",", arAgs.ToArray()) + ")"
                        '    .AppendLine(String.Format(" and (PART_NO in {0} or PART_NO in {1}) ", ConfigurationManager.AppSettings("StdAGSEWPN"), strPNList))
                        'Else
                        .AppendLine(String.Format(" and A.PART_NO in {0} ", ConfigurationManager.AppSettings("StdAGSEWPN")))
                        'End If
                        .AppendLine(" order by A.PART_NO ")
                    End With
                    'Util.SendEmail("ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "SQL:", qsb.ToString(), True, "", "")
                    apt = New SqlClient.SqlDataAdapter(qsb.ToString(), conn)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    apt.Fill(dt)

                    If Not PCatId.ToString.ToUpper.Contains("EDDEAL21") Then
                        For Each r As DataRow In dt.Rows
                            If r.Item("CATEGORY_ID").ToString().ToUpper.StartsWith("AGS-EW/DOA") Then
                                r.Delete()
                            End If
                        Next
                    End If
                    dt.AcceptChanges()
                End If
            Else
                If PCatId.ToUpper().StartsWith("CTOS NOTE FOR") Then
                    qsb = New System.Text.StringBuilder
                    With qsb
                        .AppendLine(" SELECT distinct a.PART_NO as CATEGORY_ID, a.PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                        .AppendLine(" b.PRODUCT_DESC as CATEGORY_DESC, b.PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                        .AppendLine(" '' as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(b.STATUS,'') as STATUS, ")
                        .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, IsNull(MATERIAL_GROUP,'') as MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                        .AppendLine(" from CBOM_CATEGORY_CTOS_NOTE a left join SAP_PRODUCT b on a.part_no=b.part_no ")
                        .AppendFormat(" INNER JOIN SAP_PRODUCT_ORG c ON b.PART_NO=c.PART_NO AND c.ORG_ID ='{0}' ", SAPOrg)
                        .AppendLine(" order by a.PART_NO ")
                    End With
                    apt = New SqlClient.SqlDataAdapter(qsb.ToString(), conn)
                    If conn.State <> ConnectionState.Open Then conn.Open()
                    apt.Fill(dt)
                End If
            End If
        End If
        If conn.State <> ConnectionState.Closed Then conn.Close()

        For Each BomRec As DataRow In dt.Rows
            With BomRec
                If .Item("PARENT_CATEGORY_ID") Is DBNull.Value Then .Item("PARENT_CATEGORY_ID") = ""
                If .Item("CATEGORY_ID") Is DBNull.Value Then .Item("CATEGORY_ID") = ""
                If .Item("CATEGORY_NAME") Is DBNull.Value Then .Item("CATEGORY_NAME") = ""
                If .Item("CATEGORY_DESC") Is DBNull.Value Then .Item("CATEGORY_DESC") = ""
                If .Item("DISPLAY_NAME") Is DBNull.Value Then .Item("DISPLAY_NAME") = ""
                If .Item("CATEGORY_TYPE") Is DBNull.Value Then .Item("CATEGORY_TYPE") = ""
                If .Item("CONFIGURATION_RULE") Is DBNull.Value Then .Item("CONFIGURATION_RULE") = ""
                If .Item("NOT_EXPAND_CATEGORY") Is DBNull.Value Then .Item("NOT_EXPAND_CATEGORY") = ""
                If .Item("SHOW_HIDE") Is DBNull.Value Then .Item("SHOW_HIDE") = 1
                If .Item("EZ_FLAG") Is DBNull.Value Then .Item("EZ_FLAG") = 0
                If .Item("STATUS_OLD") Is DBNull.Value Then .Item("STATUS_OLD") = ""
                If .Item("SHIP_WEIGHT") Is DBNull.Value Then .Item("SHIP_WEIGHT") = 0
                If .Item("NET_WEIGHT") Is DBNull.Value Then .Item("NET_WEIGHT") = 0
                If .Item("MATERIAL_GROUP") Is DBNull.Value Then .Item("MATERIAL_GROUP") = ""
                If .Item("RoHS") Is DBNull.Value Then .Item("RoHS") = "n"
                If .Item("class") Is DBNull.Value Then .Item("class") = ""
                If .Item("UID") Is DBNull.Value Then .Item("UID") = ""
                If .Item("org") Is DBNull.Value Then .Item("org") = ""
                If .Item("STATUS") Is DBNull.Value Then .Item("STATUS") = ""
                If .Item("EXTENDED_DESC") Is DBNull.Value Then .Item("EXTENDED_DESC") = String.Empty 'ICC 2015/4/7 Add new column [EXTENDED_DESC]
                retDt.AddCBOM_CATALOG_CATEGORYRow( _
                     .Item("PARENT_CATEGORY_ID"), .Item("CATEGORY_ID"), .Item("CATEGORY_NAME"), .Item("CATEGORY_TYPE"), .Item("CATEGORY_DESC"), _
                     .Item("DISPLAY_NAME"), .Item("SEQ_NO"), .Item("DEFAULT_FLAG"), .Item("CONFIGURATION_RULE"), .Item("NOT_EXPAND_CATEGORY"), _
                     .Item("SHOW_HIDE"), .Item("EZ_FLAG"), .Item("STATUS_OLD"), .Item("SHIP_WEIGHT"), .Item("NET_WEIGHT"), .Item("MATERIAL_GROUP"), .Item("RoHS"), _
                     .Item("class"), .Item("UID"), .Item("org"), .Item("STATUS"), .Item("EXTENDED_DESC")) 'ICC 2015/4/7 Add new column [EXTENDED_DESC]
            End With
        Next

        RetDatatable = dt
        Return retDt
    End Function

    Public Shared Function GetSpecialExWarrantyItemByRootCatId(ByVal RootCatId As String) As List(Of AGS_EW_PN)
        Dim AgsEwList As New List(Of AGS_EW_PN)
        If Not RootCatId.ToUpper().Contains("CTOS") Then Return AgsEwList
        Dim dt As New DataTable
        Dim apt As New SqlClient.SqlDataAdapter("select PART_NO, CHARGE_PERCENTAGE from CBOM_EXWARRANTY_COMPANY where ROOT_CATEGORY_ID=@RCATID order by PART_NO ", _
                                                ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("RCATID", RootCatId)
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        For Each r As DataRow In dt.Rows
            AgsEwList.Add(New AGS_EW_PN(r.Item("PART_NO"), r.Item("CHARGE_PERCENTAGE")))
        Next
        Return AgsEwList
    End Function

    Class AGS_EW_PN
        Public PartNo As String, ChargePercentage As Double
        Public Sub New(ByVal PN As String, ByVal Per As Double)
            PartNo = PN : ChargePercentage = Per
        End Sub
    End Class

    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty!"
    End Function

#Region "ConfiguratorJQ"
    Public Class PriceATP
        Public Property Price As Decimal : Public Property ATPDate As String : Public Property ATPQty As Integer : Public Property CurrencySign As String : Public Property IsEw As Boolean
    End Class

    Public Shared Function IsOrderable(ByVal strPartNo As String, ByVal strSAPOrg As String) As Boolean
        Dim strPNs() As String = Split(strPartNo, "|")
        If strPNs.Length = 0 Then Return False
        For Each pn As String In strPNs
            pn = Trim(pn).Replace("'", "''")
            If String.Equals(pn, MyExtension.BuildIn, StringComparison.CurrentCultureIgnoreCase) Then Continue For
            Dim objCount As Object = Nothing
            Dim strSql As String = String.Format( _
              " select count(part_no) as c " + _
              " from SAP_PRODUCT_STATUS_ORDERABLE " + _
              " where product_status in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + _
              " and part_no =@PN and sales_org=@SAPORG ", pn, strSAPOrg)
            Dim cmd As New SqlClient.SqlCommand(strSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            cmd.Parameters.AddWithValue("PN", pn) : cmd.Parameters.AddWithValue("SAPORG", strSAPOrg)
            cmd.Connection.Open() : objCount = cmd.ExecuteScalar() : cmd.Connection.Close()
            If objCount Is Nothing OrElse CInt(objCount) = 0 Then
                Return False
            End If
        Next
        'If strPartNo.StartsWith("IPC-610") Then Return False
        Return True
    End Function

    Shared Function GetPrice(ByVal PartNo As String) As Decimal
        If String.Equals(PartNo, MyExtension.BuildIn, StringComparison.CurrentCultureIgnoreCase) Then Return 0
        If PartNo.ToUpper.StartsWith("AGS-EW") Then
            Return Glob.getRateByEWItem(PartNo, Left(HttpContext.Current.Session("org_id"), 2) + "H1") * 100
        End If
        'Ming 2012-11-12 修复数字料号价格为0
        If Global_Inc.IsNumericItem(PartNo) Then
            PartNo = Global_Inc.RemoveZeroString(PartNo)
        End If
        'end
        Dim WS As New MYSAPDAL, ProdInDt As New SAPDALDS.ProductInDataTable, ProdOutDt As New SAPDALDS.ProductOutDataTable, strErrMsg As String = ""
        ProdInDt.AddProductInRow(PartNo, 1)
        Dim retFlg As Boolean = WS.GetPrice(HttpContext.Current.Session("company_id"), HttpContext.Current.Session("company_id"), HttpContext.Current.Session("org_id"), ProdInDt, ProdOutDt, strErrMsg)
        If retFlg AndAlso ProdOutDt.Rows.Count > 0 Then
            Dim upm As AuthUtil.UserPermission = AuthUtil.GetPermissionByUser()
            Dim TotalAmount As Decimal = 0
            If upm.CanSeeUnitPrice Then
                For Each r As SAPDALDS.ProductOutRow In ProdOutDt
                    If Decimal.TryParse(r.UNIT_PRICE, 0) Then
                        TotalAmount += Decimal.Parse(r.UNIT_PRICE)
                    End If
                Next
                'Return CType(ProdOutDt.Rows(0), SAPDALDS.ProductOutRow).UNIT_PRICE
            Else
                For Each r As SAPDALDS.ProductOutRow In ProdOutDt
                    If Decimal.TryParse(r.LIST_PRICE, 0) Then
                        TotalAmount += Decimal.Parse(r.LIST_PRICE)
                    End If
                Next
                'Return CType(ProdOutDt.Rows(0), SAPDALDS.ProductOutRow).LIST_PRICE
            End If
            Return TotalAmount
        Else
            Return 0
        End If

    End Function

    Shared Function GetATP(ByVal PartNo As String, ByVal ReqQty As Integer) As Date
        If PartNo = MyExtension.BuildIn Then Return Now.ToString("yyyy/MM/dd")
        If PartNo.ToUpper.StartsWith("AGS-EW") Then
            Return Now.ToString("yyyy/MM/dd")
        End If
        Dim due_date As String = Now.ToString("yyyy/MM/dd")
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'SAPtools.getInventoryAndATPTable(PartNo, HttpContext.Current.Session("Org") & "H1", ReqQty, due_date, 0, Nothing, "", 1, 0)
        SAPtools.getInventoryAndATPTable(PartNo, Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2) & "H1", ReqQty, due_date, 0, Nothing, "", 1, 0)
        'Util.GetDueDate(PartNo, ReqQty, Now.ToString("yyyy/MM/dd"), due_date)
        Return CDate(due_date).ToString("yyyy/MM/dd")
    End Function

    Public Shared Function GetCompPriceATP(ByVal ComponentCategoryId As String, ByVal ConfigQty As Integer) As MyCBOMDAL.PriceATP
        Dim objPriceATP As New MyCBOMDAL.PriceATP, due_date As Date = Date.MaxValue, culQty As Decimal = 0, QtyMeetReqAtp As Decimal = 0
        Dim plant As String = UCase(Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2) & "H1")
        If ComponentCategoryId = MyExtension.BuildIn OrElse ComponentCategoryId.ToUpper.StartsWith("AGS-EW") Then
            due_date = Now
        ElseIf ComponentCategoryId.Contains("|") Then
            'For pipeline items, need to calculate both item atp due date and use the latest one
            due_date = Now
            Dim pipelineitems As List(Of String) = ComponentCategoryId.Split("|").ToList
            For Each pipelineitem As String In pipelineitems
                Dim current_item_duedate As DateTime = DateTime.MaxValue
                culQty = 0
                Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
                p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
                pipelineitem = Global_Inc.Format2SAPItem(Trim(UCase(pipelineitem)))
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
                rOfretTb.Req_Qty = 999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd")
                retTb.Add(rOfretTb)
                p1.Connection.Open()
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", pipelineitem, plant,
                                              "", "", "", "", "PC", "", 1, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                p1.Connection.Close()
                For Each atpRec As GET_MATERIAL_ATP.BAPIWMDVE In atpTb
                    If atpRec.Com_Qty > 0 Then
                        culQty += atpRec.Com_Qty
                        If culQty >= ConfigQty AndAlso current_item_duedate = Date.MaxValue Then
                            Date.TryParseExact(atpRec.Com_Date, "yyyyMMdd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, current_item_duedate)
                            QtyMeetReqAtp = culQty
                        End If
                    End If
                Next
                If current_item_duedate > due_date Then
                    due_date = current_item_duedate
                End If
            Next
        Else
            Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
            p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0
            ComponentCategoryId = Global_Inc.Format2SAPItem(Trim(UCase(ComponentCategoryId)))
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
            rOfretTb.Req_Qty = 999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd")
            retTb.Add(rOfretTb)
            p1.Connection.Open()
            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", ComponentCategoryId, plant, _
                                          "", "", "", "", "PC", "", 1, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            p1.Connection.Close()
            For Each atpRec As GET_MATERIAL_ATP.BAPIWMDVE In atpTb
                If atpRec.Com_Qty > 0 Then
                    culQty += atpRec.Com_Qty
                    If culQty >= ConfigQty AndAlso due_date = Date.MaxValue Then
                        Date.TryParseExact(atpRec.Com_Date, "yyyyMMdd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, due_date)
                        QtyMeetReqAtp = culQty
                    End If
                End If
            Next
        End If

        If due_date = Date.MaxValue Then
            due_date = Now.Date.AddDays(SAPtools.getLeadTime(ComponentCategoryId, plant))
        End If

        With objPriceATP
            If QtyMeetReqAtp > 9999 Then
                QtyMeetReqAtp = 9999
            End If
            .Price = MyCBOMDAL.GetPrice(ComponentCategoryId) : .ATPDate = due_date.ToString("yyyy/MM/dd") : .ATPQty = CInt(QtyMeetReqAtp)
            If ComponentCategoryId.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) Then
                .CurrencySign = "" : .IsEw = True
            Else
                .CurrencySign = HttpContext.Current.Session("company_currency_sign") : .IsEw = False
            End If

        End With

        Return objPriceATP
    End Function


    Shared Function SaveConfig2Cart(ByRef DTCOM As DataTable, ByVal strBTOItem As String, ByVal intConfigQty As Integer) As Boolean
        Dim cart_id As String = HttpContext.Current.Session("cart_id"), company As String = HttpContext.Current.Session("company_id"), plant As String = OrderUtilities.getPlant()
        Dim ORG As String = HttpContext.Current.Session("ORG_ID"), ewFLAG As Integer = 0, ddMaxDueDate As Date = Now
        Dim mycart As New CartList("b2b", "cart_detail")
        mycart.Delete(String.Format("cart_id='{0}'", cart_id))
        mycart.ADD2CART(cart_id, strBTOItem.ToUpper(), intConfigQty, 0, -1, "", 0, 0)

        'Frank 2013/12/16
        '可否將PTRADE-BTO這個料號直接帶出組裝費AGS-CTOS-SYS-B?
        '這樣將來客戶不論是否用PTRADE-BTO下單,皆會帶出AGS-CTOS-SYS-B.
        '因不讓客戶可在MYADVANTECH手動加COMPONENT, 可能會造成客戶的困擾
        'AGS-CTOS-SYS-B費用是固定的USD50.  TKS
        'Fanny
        If ORG.ToUpper.StartsWith("TW") AndAlso strBTOItem.ToUpper() = "PTRADE-BTO" Then
            mycart.ADD2CART(cart_id, "AGS-CTOS-SYS-B", intConfigQty, 0, 1, "", 0, 0)
        End If


        If DTCOM.Rows.Count > 0 Then
            Dim cartSt As Integer = 0
            For Each R As DataRow In DTCOM.Select("CATEGORY_TYPE='Component'")
                If R.Item("CATEGORY_ID").ToString.Contains("|") Then
                    Dim ps() As String = Split(R.Item("CATEGORY_ID").ToString.ToUpper(), "|")
                    For Each p As String In ps
                        Dim cate As String = R.Item("PARENT_CATEGORY_ID").ToString.Replace("'", "''").ToUpper
                        cartSt = mycart.ADD2CART(cart_id, p.ToUpper, intConfigQty, 0, 1, cate, 0, 1)
                    Next
                Else
                    If R.Item("CATEGORY_ID").ToString.ToUpper().StartsWith("AGS-EW") Then
                        ewFLAG = Glob.getMonthByEWItem(R.Item("CATEGORY_ID").ToString.ToUpper())
                    Else
                        Dim p As String = R.Item("CATEGORY_ID").ToString.ToUpper()
                        Dim cate As String = R.Item("PARENT_CATEGORY_ID").ToString.Replace("'", "''").ToUpper
                        cartSt = mycart.ADD2CART(cart_id, p.ToUpper, intConfigQty, 0, 1, cate, 0, 1)
                    End If
                End If

                If cartSt = 0 Then Return False
                If DateDiff(DateInterval.Day, ddMaxDueDate, R.Item("ATP_DATE")) > 0 Then
                    ddMaxDueDate = R.Item("ATP_DATE")
                End If
            Next
        End If

        'add Other Item               
        'Dim partNoStrOther As String = Me.HOtherCom.Value.Trim().Trim("|").ToUpper.Replace("'", "''")
        'If partNoStrOther <> "" Then
        '    Dim part_noArr() As String = partNoStrOther.Split("|")
        '    For Each N As String In part_noArr
        '        Dim p As String = N.ToUpper()
        '        Dim cate As String = "OTHERS"
        '        mycart.ADD2CART(cart_id, p.ToUpper, Request("Qty"), 0, 1, cate, 0, 1)

        '    Next
        'End If
        '/add Other Item

        'update
        Dim cartDT As DataTable = mycart.GetDT(String.Format("cart_id='{0}' and otype<>'-1'", cart_id), "line_no"), partNoStr As String = ""
        For Each r As DataRow In cartDT.Rows
            partNoStr &= r.Item("part_no") & "|"
        Next
        Dim priceTB As DataTable = Nothing
        SAPtools.getSAPPriceByTable(partNoStr, 1, ORG, company, "", priceTB)
        If priceTB.Rows.Count > 0 Then
            For Each r As DataRow In priceTB.Rows
                mycart.Update(String.Format("cart_id='{0}' and part_no='{1}'", cart_id, r.Item("MATNR").ToString.TrimStart("0")), String.Format("list_price='{0}',unit_price='{1}',ew_flag='{2}',ounit_price='{1}'", r.Item("Kzwi1"), r.Item("Netwr"), ewFLAG))
            Next
        End If
        If IsDate(ddMaxDueDate) Then
            ddMaxDueDate = DateAdd(DateInterval.Day, CInt(Glob.getBTOWorkingDate()), ddMaxDueDate)
            mycart.Update(String.Format("cart_id='{0}' and otype='-1'", cart_id), String.Format("due_date='{0}'", ddMaxDueDate))
        End If
        Return True
    End Function
    Shared Function SaveConfig2Cart_V2(ByRef DTCOM As DataTable, ByVal strBTOItem As String, ByVal intConfigQty As Integer) As Boolean
        Dim cart_id As String = HttpContext.Current.Session("cart_id"), company As String = HttpContext.Current.Session("company_id"), plant As String = OrderUtilities.getPlant()
        Dim ORG As String = HttpContext.Current.Session("ORG_ID"), ewFLAG As Integer = 0, ddMaxDueDate As Date = Now
        Dim mycart As New CartList("b2b", "CART_DETAIL_V2")
        'Ming  2014/6/16 避免欧洲组装单下有单品存在
        If String.Equals(ORG, "EU10", StringComparison.InvariantCultureIgnoreCase) Then
            mycart.Delete(String.Format("cart_id='{0}' and Line_No < 100 ", cart_id))
        End If

        Dim higherLevel As Integer = 100
        higherLevel = MyCartX.getBtosParentLineNo(cart_id)
        mycart.ADD2CART_V2(cart_id, strBTOItem.ToUpper(), intConfigQty, 0, CartItemType.BtosParent, "", 0, 0, #12:00:00 AM#, "", "", 0)
        Dim Currency As String = MyCartX.GetCurrency(cart_id)
        'Frank 2013/12/16
        '可否將PTRADE-BTO這個料號直接帶出組裝費AGS-CTOS-SYS-B?
        '這樣將來客戶不論是否用PTRADE-BTO下單,皆會帶出AGS-CTOS-SYS-B.
        '因不讓客戶可在MYADVANTECH手動加COMPONENT, 可能會造成客戶的困擾
        'AGS-CTOS-SYS-B費用是固定的USD50.  TKS
        'Fanny
        If ORG.ToUpper.StartsWith("TW") AndAlso strBTOItem.ToUpper() = "PTRADE-BTO" Then
            'mycart.ADD2CART_V2(cart_id, "AGS-CTOS-SYS-B", intConfigQty, 0, 1, "", 0, 0)
            '20140120 因790行是以higherLevel做条件更新price的,所以在add时一定要加上higherLevel
            mycart.ADD2CART_V2(cart_id, "AGS-CTOS-SYS-B", intConfigQty, 0, CartItemType.BtosPart, "", 0, 0, #12:00:00 AM#, "", "", higherLevel)
        End If

        Dim _EWlist As List(Of EWPartNo) = MyCartX.GetExtendedWarranty()
        If DTCOM.Rows.Count > 0 Then
            Dim cartSt As Integer = 0
            For Each R As DataRow In DTCOM.Select("CATEGORY_TYPE='Component'")
                If R.Item("CATEGORY_ID").ToString.Contains("|") Then
                    Dim ps() As String = Split(R.Item("CATEGORY_ID").ToString.ToUpper(), "|")
                    For Each p As String In ps
                        Dim cate As String = R.Item("PARENT_CATEGORY_ID").ToString.Replace("'", "''").ToUpper
                        cartSt = mycart.ADD2CART_V2(cart_id, p.ToUpper, intConfigQty, 0, CartItemType.BtosPart, cate, 0, 1, #12:00:00 AM#, "", "", higherLevel)
                    Next
                Else
                    If R.Item("CATEGORY_ID").ToString.ToUpper().StartsWith("AGS-EW") Then
                        ' ewFLAG = Glob.getMonthByEWItem(R.Item("CATEGORY_ID").ToString.ToUpper())
                        For Each _ew As EWPartNo In _EWlist
                            If String.Equals(_ew.EW_PartNO, R.Item("CATEGORY_ID").ToString.Trim) Then
                                ewFLAG = _ew.ID
                            End If
                        Next
                    Else
                        Dim p As String = R.Item("CATEGORY_ID").ToString.ToUpper()
                        Dim cate As String = R.Item("PARENT_CATEGORY_ID").ToString.Replace("'", "''").ToUpper
                        cartSt = mycart.ADD2CART_V2(cart_id, p.ToUpper, intConfigQty, 0, CartItemType.BtosPart, cate, 0, 1, #12:00:00 AM#, "", "", higherLevel)
                    End If
                End If

                If cartSt = 0 Then Return False
                If DateDiff(DateInterval.Day, ddMaxDueDate, R.Item("ATP_DATE")) > 0 Then
                    ddMaxDueDate = R.Item("ATP_DATE")
                End If
            Next
        End If

        'add Other Item               
        'Dim partNoStrOther As String = Me.HOtherCom.Value.Trim().Trim("|").ToUpper.Replace("'", "''")
        'If partNoStrOther <> "" Then
        '    Dim part_noArr() As String = partNoStrOther.Split("|")
        '    For Each N As String In part_noArr
        '        Dim p As String = N.ToUpper()
        '        Dim cate As String = "OTHERS"
        '        mycart.ADD2CART(cart_id, p.ToUpper, Request("Qty"), 0, 1, cate, 0, 1)

        '    Next
        'End If
        '/add Other Item

        'update
        Dim cartDT As DataTable = mycart.GetDT(String.Format("cart_id='{0}' and otype<>'-1'", cart_id), "line_no"), partNoStr As String = ""
        For Each r As DataRow In cartDT.Rows
            partNoStr &= r.Item("part_no") & "|"
        Next
        Dim priceTB As DataTable = Nothing
        SAPtools.getSAPPriceByTable(partNoStr, 1, ORG, company, Currency, priceTB)
        If priceTB.Rows.Count > 0 Then
            For Each r As DataRow In priceTB.Rows
                mycart.Update(String.Format("cart_id='{0}' and part_no='{1}' and higherLevel={2}", cart_id, r.Item("MATNR").ToString.TrimStart("0"), higherLevel), String.Format("list_price='{0}',unit_price='{1}',ew_flag='{2}',ounit_price='{1}'", r.Item("Kzwi1"), r.Item("Netwr"), 0))
            Next
        End If
        If IsDate(ddMaxDueDate) Then
            'ddMaxDueDate = DateAdd(DateInterval.Day, CInt(Glob.getBTOWorkingDate()), ddMaxDueDate)
            ddMaxDueDate = CDate(MyCartOrderBizDAL.getBTOParentDueDate(ddMaxDueDate))
            mycart.Update(String.Format("cart_id='{0}' and otype={1} and Line_No={2}", cart_id, -1, higherLevel), String.Format("due_date='{0}'", ddMaxDueDate))
        End If
        If ewFLAG > 0 Then
            Dim _cartBtosParentitem As CartItem = MyCartX.GetCartItem(cart_id, higherLevel)
            _cartBtosParentitem.Ew_Flag = ewFLAG
            MyCartX.addExtendedWarrantyV2(_cartBtosParentitem, ewFLAG)
        End If
        Return True
    End Function
    Public Class SaveToCartResult
        Private _procStatus As Boolean, _procMsg As String
        Public Property ProcessStatus As Boolean
            Get
                Return _procStatus
            End Get
            Set(ByVal value As Boolean)
                _procStatus = value
            End Set
        End Property
        Public Property ProcessMessage As String
            Get
                Return _procMsg
            End Get
            Set(ByVal value As String)
                _procMsg = value
            End Set
        End Property

    End Class

    Public Class ReconfigTreeObject
        Private _BtoItem As String, _reConfigTreeHtml As String, _reConfigQty As Integer
        Public Property BTOItem As String
            Get
                Return _BtoItem
            End Get
            Set(ByVal value As String)
                _BtoItem = value
            End Set
        End Property
        Public Property ReConfigTreeHtml As String
            Get
                Return _reConfigTreeHtml
            End Get
            Set(ByVal value As String)
                _reConfigTreeHtml = value
            End Set
        End Property
        Public Property ReConfigQty As Integer
            Get
                Return _reConfigQty
            End Get
            Set(ByVal value As Integer)
                _reConfigQty = value
            End Set
        End Property
    End Class

    Public Shared Function IsEstoreBom(ByVal BTORootID As String) As Boolean
        If BTORootID.StartsWith("EZ-", StringComparison.OrdinalIgnoreCase) Then
            Return True
        End If
        Dim ObjectEZ_FLAG As Object = dbUtil.dbExecuteScalar("B2B",
                                                             String.Format("SELECT ISNULL(COUNT(BTONo),0) as Bcount  FROM  ESTORE_BTOS_CATEGORY WHERE  DisplayPartno ='{1}' and StoreID like '%{0}'", _
                                                                   Left(HttpContext.Current.Session("org_id").ToUpper, 2), BTORootID.Trim))
        If ObjectEZ_FLAG IsNot Nothing AndAlso Integer.TryParse(ObjectEZ_FLAG, 0) AndAlso Integer.Parse(ObjectEZ_FLAG) > 0 Then
            Return True
        End If
        Return False
    End Function

    Public Shared Function IsOnlyOneLevelBOM(ByVal BTORootID As String) As Boolean
        If BTORootID.StartsWith("C-CTOS", StringComparison.CurrentCultureIgnoreCase) Or BTORootID.StartsWith("SYS-", StringComparison.CurrentCultureIgnoreCase) Then
            Return True
        End If
        Return False
    End Function

#End Region

End Class

Public Class HierarchyConfig
    Public CATEGORY_ID As String, CATEGORY_NAME As String, CATEGORY_TYPE As String, PARENT_CATEGORY_ID As String
    Public CATALOG_ID As String, CATALOGCFG_SEQ As Integer, CATEGORY_DESC As String, DISPLAY_NAME As String
    Public IMAGE_ID As String, EXTENDED_DESC As String, CREATED As DateTime, CREATED_BY As String
    Public LAST_UPDATED As DateTime, LAST_UPDATED_BY As String, SEQ_NO As Integer, PUBLISH_STATUS As String
    Public CATEGORY_PRICE As Double, CATEGORY_QTY As Integer, ParentSeqNo As Integer, ParentRoot As String
    Public Level As Integer, ATP_Date As Date
    Public ParentHierarchyConfig As HierarchyConfig
    Public ChildHierarchyConfigs As ArrayList
    Public Sub New(ByVal CatId As String, ByVal CatTypeValue As CATTYPE)
        ChildHierarchyConfigs = New ArrayList
        CATEGORY_ID = CatId : CATEGORY_TYPE = CatTypeValue
    End Sub
    Public Enum CATTYPE
        category
        component
        Root
    End Enum
End Class

Public Class CBom
    Private _CategoryType As String, _CategoryId As String, _IsCatRequired As Boolean, _IsCompDefault As Boolean, _strDescription As String
    Private _IsCompRoHS As Boolean, _Expand As Boolean, _ChildCategories As List(Of CBom), _ClientId As String, _IsHot As Boolean
    Public Property CategoryType As String
        Get
            Return _CategoryType
        End Get
        Set(value As String)
            _CategoryType = value
        End Set
    End Property
    Public Property CategoryId As String
        Get
            Return _CategoryId
        End Get
        Set(value As String)
            _CategoryId = value
        End Set
    End Property
    Public Property IsCatRequired As Boolean
        Get
            Return _IsCatRequired
        End Get
        Set(value As Boolean)
            _IsCatRequired = value
        End Set
    End Property
    Public Property IsCompDefault As Boolean
        Get
            Return _IsCompDefault
        End Get
        Set(value As Boolean)
            _IsCompDefault = value
        End Set
    End Property
    Public Property Description As String
        Get
            Return _strDescription
        End Get
        Set(value As String)
            _strDescription = value
        End Set
    End Property
    Public Property IsCompRoHS As Boolean
        Get
            Return _IsCompRoHS
        End Get
        Set(value As Boolean)
            _IsCompRoHS = value
        End Set
    End Property
    Public Property IsHot As Boolean
        Get
            Return _IsHot
        End Get
        Set(value As Boolean)
            _IsHot = value
        End Set
    End Property
    Public Property Expand As Boolean
        Get
            Return _Expand
        End Get
        Set(value As Boolean)
            _Expand = value
        End Set
    End Property
    Public Property ChildCategories As List(Of CBom)
        Get
            Return _ChildCategories
        End Get
        Set(value As List(Of CBom))
            _ChildCategories = value
        End Set
    End Property

    Public Property ClientId As String
        Get
            Return _ClientId
        End Get
        Set(value As String)
            _ClientId = value
        End Set
    End Property

    Sub CalcClientId(ByVal strInput As String)
        Dim hashAlgorithm As New System.Security.Cryptography.SHA1CryptoServiceProvider
        Dim byteValue() As Byte = Encoding.UTF8.GetBytes(strInput)
        Dim hashValue() As Byte = hashAlgorithm.ComputeHash(byteValue)
        _ClientId = Left(Convert.ToBase64String(hashValue).Replace("_", "").Replace("+", "").Replace("=", "").Replace("/", ""), 10)
    End Sub

End Class


Public Class CBomV2
    Private _CategoryType As String, _ID As String, _CategoryId As String, _IsCatRequired As Boolean, _IsCompDefault As Boolean, _strDescription As String
    Private _IsCompRoHS As Boolean, _Expand As Boolean, _ChildCategories As List(Of CBomV2), _ClientId As String, _IsHot As Boolean
    Public Property CategoryType As String
        Get
            Return _CategoryType
        End Get
        Set(value As String)
            _CategoryType = value
        End Set
    End Property

    Public Property ID As String
        Get
            Return _ID
        End Get
        Set(value As String)
            _ID = value
        End Set
    End Property


    Public Property CategoryId As String
        Get
            Return _CategoryId
        End Get
        Set(value As String)
            _CategoryId = value
        End Set
    End Property
    Public Property IsCatRequired As Boolean
        Get
            Return _IsCatRequired
        End Get
        Set(value As Boolean)
            _IsCatRequired = value
        End Set
    End Property
    Public Property IsCompDefault As Boolean
        Get
            Return _IsCompDefault
        End Get
        Set(value As Boolean)
            _IsCompDefault = value
        End Set
    End Property
    Public Property Description As String
        Get
            Return _strDescription
        End Get
        Set(value As String)
            _strDescription = value
        End Set
    End Property
    Public Property IsCompRoHS As Boolean
        Get
            Return _IsCompRoHS
        End Get
        Set(value As Boolean)
            _IsCompRoHS = value
        End Set
    End Property
    Public Property IsHot As Boolean
        Get
            Return _IsHot
        End Get
        Set(value As Boolean)
            _IsHot = value
        End Set
    End Property
    Public Property Expand As Boolean
        Get
            Return _Expand
        End Get
        Set(value As Boolean)
            _Expand = value
        End Set
    End Property
    Public Property ChildCategories As List(Of CBomV2)
        Get
            Return _ChildCategories
        End Get
        Set(value As List(Of CBomV2))
            _ChildCategories = value
        End Set
    End Property

    Public Property ClientId As String
        Get
            Return _ClientId
        End Get
        Set(value As String)
            _ClientId = value
        End Set
    End Property

    Sub CalcClientId(ByVal strInput As String)
        Dim hashAlgorithm As New System.Security.Cryptography.SHA1CryptoServiceProvider
        Dim byteValue() As Byte = Encoding.UTF8.GetBytes(strInput)
        Dim hashValue() As Byte = hashAlgorithm.ComputeHash(byteValue)
        _ClientId = Left(Convert.ToBase64String(hashValue).Replace("_", "").Replace("+", "").Replace("=", "").Replace("/", ""), 10)
    End Sub

End Class

Public Class ConfiguredComponent
    Private _catid As String, _childComps As List(Of ConfiguredComponent), _catType As String
    Public Property CategoryId As String
        Get
            Return _catid
        End Get
        Set(value As String)
            _catid = value
        End Set
    End Property
    Public Property CategoryType As String
        Get
            Return _catType
        End Get
        Set(value As String)
            _catType = value
        End Set
    End Property
    Public Property ChildComps As List(Of ConfiguredComponent)
        Get
            Return _childComps
        End Get
        Set(value As List(Of ConfiguredComponent))
            _childComps = value

        End Set
    End Property
End Class
Public Class CBOMSetting
    Private Shared _DBConn As String = "MY"
    Public Shared ReadOnly Property DBConn As String
        Get
            If HttpContext.Current.Request.ServerVariables("SERVER_PORT") = "4002" Then
                _DBConn = "MY"
            End If
            Return _DBConn
        End Get
    End Property
End Class