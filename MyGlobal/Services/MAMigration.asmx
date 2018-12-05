<%@ WebService Language="VB" Class="MAMigration" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantechGlobal")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class MAMigration
    Inherits System.Web.Services.WebService
    
    Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
    Public Enum CBOMActions
        ADD
        UPDATE
        DELETE
    End Enum
    <WebMethod()> _
    Public Function CATALOG_Edit(ByVal act As CBOMActions, ByVal CataID As String, _
                                 ByVal CataName As String, ByVal GroupName As String, _
                                 ByVal CataDesc As String, ByVal CreatedBy As String, _
                                 ByVal ImgName As String) As Boolean
        Return True
        'Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        'Dim cmd As New SqlClient.SqlCommand()
        'cmd.Connection = conn
        'Select Case act
        '    Case CBOMActions.ADD
        '        Dim strSql As String = String.Format( _
        '          " insert into CBOM_CATALOG (CATALOG_ID,CATALOG_NAME,CATALOG_TYPE,CATALOG_ORG,CATALOG_DESC,CREATED,CREATED_BY,IMAGE_ID，UID) " + _
        '          " VALUES (@CataID, @CataName, @GroupName, 'EU', @CataDesc, getDate(), @UserId, @ImgName, newid()) ")
        '        cmd.CommandText = strSql
        '        With cmd.Parameters
        '            .AddWithValue("CataID", CataID) : .AddWithValue("CataName", CataName) : .AddWithValue("GroupName", GroupName)
        '            .AddWithValue("CataDesc", CataDesc) : .AddWithValue("UserId", CreatedBy) : .AddWithValue("ImgName", ImgName)
        '        End With
          
        '    Case CBOMActions.DELETE
        '        Dim strSql As String = String.Format("delete from CBOM_CATALOG where CATALOG_id=@CataID and CATALOG_ORG='EU'")
        '        cmd.CommandText = strSql
        '        With cmd.Parameters
        '            .AddWithValue("CataID", CataID)
        '        End With
        '    Case Else
        '        Return False
        'End Select
        'Try
        '    conn.Open()
        '    'sm.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw", "CBOM Edit request by " + UpdBy, cmd.CommandText + " catid:" + CatId + ",parcat:" + ParentCatId)
        '    cmd.ExecuteNonQuery()
        '    conn.Close()
        '    Return True
        'Catch ex As Exception
        '    'sm.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw", "CBOM Edit WS error by " + UpdBy, ex.ToString() + "|" + cmd.CommandText)
        '    Return False
        'End Try
    End Function
    <WebMethod()> _
    Public Function SyncSingleSAPCustomer(ByVal CompanyId As String, ByVal isTest As Boolean, ByRef ErrMsg As String) As DataSet
        'Dim sc As New SAPDAL.syncSingleCompany
        Dim cl As New ArrayList : cl.Add(CompanyId)
        Dim ocom As SAPDAL.DimCompanySet = SAPDAL.syncSingleCompany.syncSingleSAPCustomer(cl, isTest, ErrMsg)
        Dim ds As New DataSet
        Dim dtmaster As New DataTable("Master")
        Dim dtcontact As New DataTable("Contact")
        Dim dtpartner As New DataTable("Partner")
        Dim dtemployee As New DataTable("Employee")
        Dim dtsalesdef As New DataTable("SalesDef")
        ds.Tables.Add(dtmaster)
        ds.Tables.Add(dtcontact)
        ds.Tables.Add(dtpartner)
        ds.Tables.Add(dtemployee)
        ds.Tables.Add(dtsalesdef)
        If Not IsNothing(ocom) Then
            If Not IsNothing(ocom.Company) Then
                Dim ar As New ArrayList()
                For Each c As SAPDAL.SAP_DIMCOMPANY In ocom.Company
                    Dim newCom As New New_SAP_DIMCOMPANY(c)
                    ar.Add(newCom)
                Next
                ds.Tables("Master").Merge(Glob.ToDataTable(ar))
            End If
            If Not IsNothing(ocom.Contact) Then
                ds.Tables("Contact").Merge(Glob.ToDataTable(ocom.Contact))
            End If
            If Not IsNothing(ocom.Employee) Then
                ds.Tables("Employee").Merge(Glob.ToDataTable(ocom.Employee))
            End If
            If Not IsNothing(ocom.Partner) Then
                ds.Tables("Partner").Merge(Glob.ToDataTable(ocom.Partner))
            End If
            If Not IsNothing(ocom.Salesdef) Then
                ds.Tables("SalesDef").Merge(Glob.ToDataTable(ocom.Salesdef))
            End If
        End If
        Return ds
    End Function
    <WebMethod()> _
    Public Function CBOM_Edit(ByVal act As CBOMActions, ByVal CatId As String, ByVal CatType As String, ByVal ParentCatId As String, _
                              ByVal CatDesc As String, ByVal ExtDesc As String, ByVal UpdBy As String, ByVal SeqNo As Integer, _
                              ByVal ConfigRule As String, ByVal NotExpandCat As String, ByVal ShowHide As String) As Boolean
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim cmd As New SqlClient.SqlCommand()
        cmd.Connection = conn
        Select Case act
            Case CBOMActions.ADD
                Dim strSql As String = String.Format( _
                  " INSERT INTO CBOM_CATALOG_CATEGORY  (CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE,  PARENT_CATEGORY_ID, CATEGORY_DESC,  " + _
                  " EXTENDED_DESC, CREATED_BY, SEQ_NO,  CONFIGURATION_RULE, NOT_EXPAND_CATEGORY, SHOW_HIDE, UID, ORG)  " + _
                  " VALUES (@CATID, @CATID, @CATTYPE,  @PARCATID, @CATDESC, @EXTDESC, @UBY, @SEQNO, @CONFIGRULE, @NOEXPCAT, @SHOWHIDE, newid(), 'EU') ")
                cmd.CommandText = strSql
                With cmd.Parameters
                    .AddWithValue("CATID", CatId) : .AddWithValue("CATTYPE", CatType) : .AddWithValue("PARCATID", ParentCatId)
                    .AddWithValue("CATDESC", CatDesc) : .AddWithValue("EXTDESC", ExtDesc) : .AddWithValue("UBY", UpdBy)
                    .AddWithValue("SEQNO", SeqNo) : .AddWithValue("CONFIGRULE", ConfigRule) : .AddWithValue("NOEXPCAT", NotExpandCat)
                    .AddWithValue("SHOWHIDE", ShowHide)
                End With
            Case CBOMActions.UPDATE
                Dim strSql As String = String.Format(" UPDATE CBOM_CATALOG_CATEGORY  SET  " + _
                              " CATEGORY_DESC =@CATDESC, " + _
                              " CREATED_BY =@UBY,  SEQ_NO = @SEQNO, " + _
                              " CONFIGURATION_RULE =@CONFIGRULE,  NOT_EXPAND_CATEGORY = @NOEXPCAT, SHOW_HIDE= @SHOWHIDE  " + _
                              " WHERE CATEGORY_ID = @CATID  and parent_category_id=@PARCATID")
                cmd.CommandText = strSql
                With cmd.Parameters
                    .AddWithValue("CATID", CatId) : .AddWithValue("CATTYPE", CatType) : .AddWithValue("PARCATID", ParentCatId)
                    .AddWithValue("CATDESC", CatDesc) : .AddWithValue("EXTDESC", ExtDesc) : .AddWithValue("UBY", UpdBy)
                    .AddWithValue("SEQNO", SeqNo) : .AddWithValue("CONFIGRULE", ConfigRule) : .AddWithValue("NOEXPCAT", NotExpandCat)
                    .AddWithValue("SHOWHIDE", ShowHide)
                End With
            Case CBOMActions.DELETE
                Dim strSql As String = String.Format("delete from cbom_catalog_category where category_id=@CATID and PARENT_CATEGORY_ID=@PARCATID")
                cmd.CommandText = strSql
                With cmd.Parameters
                    .AddWithValue("CATID", CatId) : .AddWithValue("PARCATID", ParentCatId)
                End With
            Case Else
                Return False
        End Select
        Try
            conn.Open()
            'sm.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw", "CBOM Edit request by " + UpdBy, cmd.CommandText + " catid:" + CatId + ",parcat:" + ParentCatId)
            cmd.ExecuteNonQuery()
            conn.Close()
            Return True
        Catch ex As Exception
            sm.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw", "CBOM Edit WS error by " + UpdBy, ex.ToString() + "|" + cmd.CommandText)
            Return False
        End Try
    End Function
    <WebMethod()> _
    Public Function SyncSingleProduct(ByVal PN As String, ByVal OrgPrefix As String, ByVal isTest As Boolean, ByRef errMsg As String) As SAPDAL.DimProductSet
        'Dim PNSYNC As New SAPDAL.syncSingleProduct
        Dim PNA As New ArrayList : PNA.Add(PN)
        Return SAPDAL.syncSingleProduct.syncSAPProduct(PNA, OrgPrefix, isTest, errMsg, False)
    End Function
    <WebMethod()> _
    Public Function SyncSingleProductV2(ByVal PN As String, ByVal OrgPrefix As String, ByVal isTest As Boolean, _
                                        ByRef errMsg As String, ByVal isSyncPIS As Boolean) As SAPDAL.DimProductSet
        'Dim PNSYNC As New SAPDAL.syncSingleProduct
        Dim PNA As New ArrayList : PNA.Add(PN)
        Return SAPDAL.syncSingleProduct.syncSAPProduct(PNA, OrgPrefix, isTest, errMsg, isSyncPIS)
    End Function
    <WebMethod()> _
    Public Function SyncPartNoFromSAP(ByVal pn As String) As Boolean
        If String.IsNullOrEmpty(pn) Then Return False
        pn = Replace(Trim(pn).ToUpper(), "'", "''")
        Dim oriPN As String = pn
        If Global_Inc.IsNumericItem(pn) Then pn = Global_Inc.Format2SAPItem(pn)
        Dim prodDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
            String.Format("select distinct a.matnr as part_no, " & _
                                            "a.bismt as model_no, " & _
                                            "a.MATKL as material_group, " & _
                                            "a.SPART as division, " & _
                                            "a.PRDHA as product_hierarchy, " & _
                                            "a.PRDHA as product_group, " & _
                                            "a.PRDHA as product_division, " &
                                            "a.PRDHA as product_line, " & _
                                            "a.MTPOS_MARA as GenItemCatGrp, " & _
                                            "(select MAKTX from saprdp.makt b where b.matnr=a.matnr and rownum=1 and b.spras='E') as product_desc," & _
                                            "a.ZEIFO as rohs_flag, " & _
                                            "(select vmsta from saprdp.mvke where mvke.matnr=a.matnr and mvke.vkorg='TW01' and rownum=1) as status," & _
                                            "'' as EGROUP, " & _
                                            "'' as EDIVISION, " & _
                                            "a.NTGEW as NET_WEIGHT, " & _
                                            "a.BRGEW as GROSS_WEIGHT, " & _
                                            "a.GEWEI  as WEIGHT_UNIT, " & _
                                            "a.VOLUM as VOLUME, " & _
                                            "a.VOLEH as VOLUME_UNIT, " & _
                                            "a.ERSDA as CREATE_DATE, " & _
                                            "a.LAEDA as LAST_UPD_DATE, " & _
                                            "to_char(a.mtart) as product_type " & _
                                            "from saprdp.mara a where mandt='168' and matnr='{0}'", pn))
        For i As Integer = 0 To prodDt.Rows.Count - 1
            If prodDt.Rows(i).Item("Part_no").ToString.StartsWith("0") Then
                For n As Integer = 1 To prodDt.Rows(i).Item("Part_no").ToString.Length - 1
                    If prodDt.Rows(i).Item("Part_no").ToString.Substring(n, 1) <> "0" Then
                        prodDt.Rows(i).Item("Part_no") = prodDt.Rows(i).Item("Part_no").ToString.Substring(n) : Exit For
                    End If
                Next
            End If
                
            If Not IsDBNull(prodDt.Rows(i).Item("product_hierarchy")) Then
                Dim ps() As String = Split(prodDt.Rows(i).Item("product_hierarchy"), "-")
                If ps.Length >= 3 Then
                    prodDt.Rows(i).Item("PRODUCT_GROUP") = ps(0) : prodDt.Rows(i).Item("PRODUCT_DIVISION") = ps(1)
                    If ps.Length = 3 Then
                        prodDt.Rows(i).Item("PRODUCT_LINE") = ps(2)
                    Else
                        prodDt.Rows(i).Item("PRODUCT_LINE") = ps(2) + ps(3)
                    End If
                End If
            End If
        Next
        
        Dim abcDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
            " select matnr as PART_NO, werks as PLANT, maabc as ABC_INDICATOR,marc.PLIFZ as PlannedDelTime, " + _
            " marc.WEBAZ as GrProcessingTime, " + _
            " marc.DZEIT as InHouseProduction, marc.PRCTR as ProfitCenter " + _
            "  from saprdp.marc where mandt='168' and matnr='" + pn + "' ")
        Dim orgDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
            " SELECT DISTINCT " + _
            "  to_char(mara.matnr) as part_no, " + _
            "  mvke.vkorg as org_id,  " + _
            "  mvke.VTWEG as dist_channel, " + _
            "  to_char(mvke.vmsta) as status, " + _
            "  to_char(mvke.PRAT5) as B2BOnline, " + _
            "  mvke.DWERK as DeliveryPlant, " + _
            "  mvke.kondm as PricingGroup, mara.laeda as LAST_UPD_DATE, mvke.AUMNG as min_ord_qty, mvke.LFMNG as min_dlv_qty " + _
            " FROM saprdp.mara INNER JOIN saprdp.mvke ON mara.matnr = mvke.matnr  " + _
            "  WHERE mara.mandt='168' and mvke.mandt='168' and mara.mtart LIKE 'Z%' and mara.matnr='" + pn + "' ")
        Dim statusDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
            " select matnr as part_no, vkorg as sales_org, vtweg as dist_channel, vmsta as product_status,  " + _
            " AUMNG as min_order_qty, LFMNG as min_dlv_qty, EFMNG as min_bto_qty, DWERK as dlv_plant, KONDM as material_pricing_grp, vmstd as valid_date, to_char(mvke.mtpos) as item_category_group " + _
            " from saprdp.MVKE " + _
            " where mandt='168' and matnr='" + pn + "' ")
        If prodDt.Rows.Count > 0 And abcDt.Rows.Count > 0 And orgDt.Rows.Count > 0 And statusDt.Rows.Count > 0 Then
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim bk As New SqlClient.SqlBulkCopy(conn)
            Dim cmd As New SqlClient.SqlCommand( _
                " delete from SAP_PRODUCT where PART_NO=@PN; " + _
                " delete from SAP_PRODUCT_ABC where PART_NO=@PN; " + _
                " delete from SAP_PRODUCT_STATUS where PART_NO=@PN; " + _
                " delete from SAP_PRODUCT_ORG where PART_NO=@PN; ", conn)
            cmd.Parameters.AddWithValue("PN", oriPN)
            conn.Open()
            cmd.ExecuteNonQuery()
            If conn.State <> ConnectionState.Open Then conn.Open()
            bk.DestinationTableName = "SAP_PRODUCT" : bk.WriteToServer(prodDt)
            bk.DestinationTableName = "SAP_PRODUCT_ABC" : bk.WriteToServer(abcDt)
            bk.DestinationTableName = "SAP_PRODUCT_STATUS" : bk.WriteToServer(statusDt)
            bk.DestinationTableName = "SAP_PRODUCT_ORG" : bk.WriteToServer(orgDt)
            cmd = New SqlClient.SqlCommand( _
                " update sap_product_org set part_no=dbo.DelPrevZero(part_no) where part_no like '0%'; " + _
                " update sap_product_abc set part_no=dbo.DelPrevZero(part_no) where part_no like '0%'; " + _
                " update sap_product_status set part_no=dbo.DelPrevZero(part_no) ", conn)
            If conn.State <> ConnectionState.Open Then conn.Open()
            cmd.ExecuteNonQuery()
            conn.Close()
            
            Dim ws As New quote.quoteExit
            ws.Timeout = -1
            Dim itp As Decimal = 0
            If itp = 0 Then
                Dim DTPRICE As New DataTable
                SAPtools.getSAPPriceByTable(pn, 1, "EU10", "UUAAESC", "", DTPRICE)
                If DTPRICE.Rows.Count > 0 Then
                    itp = FormatNumber(DTPRICE.Rows(0).Item("Netwr"), 2).Replace(",", "")
                    ws.setITP("EU10", pn, "EUR", itp)
                End If
            End If
            
            Return True
        End If
        
        Return False
    End Function
    
    <WebMethod()> _
    Public Function SyncCompanyIdFromSAP(ByVal companyid As String) As Boolean
        'Nada20131119 unify sync single customer
        Dim errMsg As String = ""
        'Dim sc As New SAPDAL.syncSingleCompany
        Dim cl As New ArrayList : cl.Add(companyid)
        Dim p As SAPDAL.DimCompanySet = SAPDAL.syncSingleCompany.syncSingleSAPCustomer(cl, False, errMsg)
        If Not IsNothing(p) AndAlso Not IsNothing(p.Company) AndAlso p.Company.Count > 0 AndAlso errMsg = "" Then
            Return True
        End If
        Return False
        'Dim sb As New System.Text.StringBuilder
        'With sb
        '    .AppendLine(String.Format(" select kna1.kunnr as Company_Id, "))
        '    .AppendLine(String.Format(" 	   knvv.vkorg as org_id, "))
        '    .AppendLine(String.Format("     (select MIN(knvp.kunnr) from saprdp.knvp where knvp.kunn2 = kna1.kunnr and knvp.vkorg=knvv.vkorg AND knvp.parvw='WE') as ParentCompanyId, "))
        '    .AppendLine(String.Format(" 		kna1.name1 || kna1.name2 as Company_Name, "))
        '    .AppendLine(String.Format(" 		adrc.street || adrc.str_suppl3 || adrc.location as Address, "))
        '    .AppendLine(String.Format(" 		kna1.telfx as fax_no, "))
        '    .AppendLine(String.Format(" 		kna1.telf1 as tel_no, "))
        '    .AppendLine(String.Format(" 		kna1.ktokd as company_type, "))
        '    .AppendLine(String.Format(" 		kna1.kdkg1 || kna1.kdkg2 || kna1.kdkg3 || kna1.kdkg4 as price_class,  "))
        '    .AppendLine(String.Format("     '' as ptrade_price_class, "))
        '    .AppendLine(String.Format(" 		knvv.waers as Currency, "))
        '    .AppendLine(String.Format(" 		adrc.country as Country,  "))
        '    .AppendLine(String.Format("     '' as region, "))
        '    .AppendLine(String.Format(" 		adrc.post_code1 as Zip_Code, "))
        '    .AppendLine(String.Format(" 		adrc.city1 as City, "))
        '    .AppendLine(String.Format(" 		adrc.name_co as Attention, "))
        '    .AppendLine(String.Format(" 		'0' as Credit_Limit, "))
        '    .AppendLine(String.Format(" 		knvv.zterm as Credit_Term, "))
        '    .AppendLine(String.Format(" 		knvv.inco1 || '  ' || knvv.inco2 as Ship_Via, "))
        '    .AppendLine(String.Format(" 		kna1.knurl as Url,  "))
        '    .AppendLine(String.Format("     '' as LAST_UPDATED,  "))
        '    .AppendLine(String.Format("     '' as UPDATED_BY,  "))
        '    .AppendLine(String.Format(" 		kna1.erdat as CREATED_DATE, "))
        '    .AppendLine(String.Format(" 		kna1.ernam as Created_By, "))
        '    .AppendLine(String.Format(" 		knvv.kdgrp as Company_Price_Type,	 "))
        '    .AppendLine(String.Format("     '' as SALES_USERID,	 "))
        '    .AppendLine(String.Format(" 		knvv.vsbed as SHIP_CONDITION, "))
        '    .AppendLine(String.Format(" 		kna1.KATR4 as attribute4, "))
        '    .AppendLine(String.Format(" 		KNVV.VKBUR as SalesOffice, "))
        '    .AppendLine(String.Format("     KNVV.VKGRP as SalesGroup, "))
        '    .AppendLine(String.Format(" (select KNVI.TAXKD from saprdp.KNVI where KNVI.kunnr=kna1.kunnr and KNVI.ALAND = 'NL' and KNVI.TATYP = 'MWST' and KNVI.mandt='168' and rownum=1) as TAX_CLASS "))
        '    .AppendLine(String.Format(" from saprdp.knvv inner join saprdp.kna1 on knvv.kunnr=kna1.kunnr  "))
        '    .AppendLine(String.Format(" 	inner join saprdp.adrc on kna1.adrnr=adrc.addrnumber and kna1.land1=adrc.country   "))
        '    .AppendLine(String.Format(" where rownum=1 and knvv.mandt='168'  and kna1.loevm = ' ' and knvv.kunnr='{0}' ", companyid.Trim.Replace("'", "").ToUpper()))
        'End With
        'Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        'If dt.Rows.Count > 0 Then
        '    For Each Row As DataRow In dt.Rows
        '        Row.Item("CREATED_DATE") = Date.ParseExact(Row.Item("CREATED_DATE").ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"))
        '        dbUtil.dbExecuteNoQuery("my", "delete from sap_dimcompany where company_id='" + companyid.Trim.Replace("'", "").ToUpper() + "'")
        '        Dim sql As String = " INSERT INTO [SAP_DIMCOMPANY]([UNIQUE_ID],[COMPANY_ID],[ORG_ID],[PARENTCOMPANYID]," + _
        '            "[COMPANY_NAME],[ADDRESS],[FAX_NO],[TEL_NO],[COMPANY_TYPE],[PRICE_CLASS],[CURRENCY],[COUNTRY],[ZIP_CODE]," + _
        '            "[CITY],[ATTENTION],[CREDIT_TERM],[SHIP_VIA],[URL],[CREATEDDATE],[CREATED_BY],[COMPANY_PRICE_TYPE],[SHIPCONDITION]," + _
        '            "[ATTRIBUTE4],[SALESOFFICE],[SALESGROUP])VALUES ("
        '        sql = sql + "'','" + Row.Item("COMPANY_ID") + "','" + Row.Item("ORG_ID") + "','" + Row.Item("PARENTCOMPANYID") + "'" & _
        '        ",'" + Replace(Row.Item("COMPANY_NAME"), "'", "''") + "','" + Replace(Row.Item("ADDRESS"), "'", "''") + _
        '        "','" + Replace(Row.Item("FAX_NO"), "'", "''") + "','" + Replace(Row.Item("TEL_NO"), "'", "''") + "' " & _
        '        ",'" + Row.Item("COMPANY_TYPE") + "','" + Row.Item("PRICE_CLASS") + "','" + Row.Item("CURRENCY") + _
        '        "','" + Replace(Row.Item("COUNTRY"), "'", "''") + "' " & _
        '        ",'" + Row.Item("ZIP_CODE") + "','" + Row.Item("CITY").ToString().Replace("'", "''") + _
        '        "','" + Replace(Row.Item("ATTENTION"), "'", "''") + "','" + Row.Item("CREDIT_TERM") + "','" + Replace(Row.Item("SHIP_VIA"), "'", "''") + "' " & _
        '        ",'" + Replace(Row.Item("URL"), "'", "''") + "','" + Row.Item("CREATED_DATE") + "','" + Row.Item("CREATED_BY") + _
        '        "','" + Row.Item("COMPANY_PRICE_TYPE") + "','" + Replace(Row.Item("SHIP_CONDITION"), "'", "''") + "' " & _
        '       " ,'" + Row.Item("ATTRIBUTE4") + "','" + Row.Item("SALESOFFICE") + "','" + Row.Item("SALESGROUP") + "')"
        '        Dim retint As Integer = dbUtil.dbExecuteNoQuery("my", sql)
        '        If retint = -1 Then
        '            Return False
        '        End If
        '    Next
        '    Dim Sqlupdate As String = " update SAP_DIMCOMPANY " & _
        '             " set unique_id=dbo.MD5Hash(COMPANY_ID+'|'+ORG_ID+'|'+COMPANY_NAME+'|'+SHIP_VIA+'|'+SALESOFFICE+'|'+SALESGROUP+'|'+CREDIT_TERM) " & _
        '             " where COMPANY_ID = '" + companyid.Trim.Replace("'", "").ToUpper() + "'"
        '    Dim retupdateint As Integer = dbUtil.dbExecuteNoQuery("my", Sqlupdate)
        '    If retupdateint = -1 Then
        '        Return False
        '    End If
        '    dt.AcceptChanges()
        '    Return True
        'End If
        'Return False
    End Function
    
    <WebMethod()> _
    Public Function HelloKiity() As String
        Return "Hello Kitty! It is " + Now.ToString("yyyy/MM/dd HH:mm:ss") + "!"
    End Function

End Class

<Serializable>
Public Class New_SAP_DIMCOMPANY
    Sub New()

    End Sub

    Sub New(ByVal com As SAPDAL.SAP_DIMCOMPANY)
        Me.UNIQUE_ID = com.UNIQUE_ID : Me.COMPANY_ID = com.COMPANY_ID : Me.ORG_ID = com.ORG_ID : Me.PARENTCOMPANYID = com.PARENTCOMPANYID
        Me.COMPANY_NAME = com.COMPANY_NAME : Me.ADDRESS = com.ADDRESS : Me.FAX_NO = com.FAX_NO : Me.TEL_NO = com.TEL_NO
        Me.COMPANY_TYPE = com.COMPANY_TYPE : Me.PRICE_CLASS = com.PRICE_CLASS : Me.CURRENCY = com.CURRENCY : Me.COUNTRY = com.COUNTRY
        Me.ZIP_CODE = com.ZIP_CODE : Me.CITY = com.CITY : Me.ATTENTION = com.ATTENTION : Me.CREDIT_TERM = com.CREDIT_TERM
        Me.SHIP_VIA = com.SHIP_VIA : Me.URL = com.URL : Me.CREATEDDATE = com.CREATEDDATE : Me.CREATED_BY = com.CREATED_BY
        Me.COMPANY_PRICE_TYPE = com.COMPANY_PRICE_TYPE : Me.SHIPCONDITION = com.SHIPCONDITION : Me.ATTRIBUTE4 = com.ATTRIBUTE4
        Me.SALESOFFICE = com.SALESOFFICE : Me.SALESGROUP = com.SALESGROUP
        If com.AMT_INSURED.HasValue = True Then Me.AMT_INSURED = com.AMT_INSURED.Value
        If com.CREDIT_LIMIT.HasValue = True Then Me.CREDIT_LIMIT = com.CREDIT_LIMIT.Value
        Me.CONTACT_EMAIL = com.CONTACT_EMAIL : Me.PAYMENT_TERM_NAME = com.PAYMENT_TERM_NAME : Me.DELETION_FLAG = com.DELETION_FLAG
        Me.CUST_IND = com.CUST_IND : Me.VM = com.VM : Me.PRICE_GRP = com.PRICE_GRP : Me.PRICE_LIST = com.PRICE_LIST : Me.INCO1 = com.INCO1
        Me.INCO2 = com.INCO2 : Me.PAYMENT_TERM_CODE = com.PAYMENT_TERM_CODE : Me.COUNTRY_NAME = com.COUNTRY_NAME : Me.REGION = com.REGION_CODE
    End Sub
    
    Private _UNIQUE_ID As String
    Public Property UNIQUE_ID() As String
        Get
            Return _UNIQUE_ID
        End Get
        Set(ByVal value As String)
            _UNIQUE_ID = value
        End Set
    End Property

    Private _COMPANY_ID As String
    Public Property COMPANY_ID() As String
        Get
            Return _COMPANY_ID
        End Get
        Set(ByVal value As String)
            _COMPANY_ID = value
        End Set
    End Property

    Private _ORG_ID As String
    Public Property ORG_ID() As String
        Get
            Return _ORG_ID
        End Get
        Set(ByVal value As String)
            _ORG_ID = value
        End Set
    End Property
	
    Private _PARENTCOMPANYID As String
    Public Property PARENTCOMPANYID() As String
        Get
            Return _PARENTCOMPANYID
        End Get
        Set(ByVal value As String)
            _PARENTCOMPANYID = value
        End Set
    End Property
	
    Private _COMPANY_NAME As String
    Public Property COMPANY_NAME() As String
        Get
            Return _COMPANY_NAME
        End Get
        Set(ByVal value As String)
            _COMPANY_NAME = value
        End Set
    End Property
	
    Private _ADDRESS As String
    Public Property ADDRESS() As String
        Get
            Return _ADDRESS
        End Get
        Set(ByVal value As String)
            _ADDRESS = value
        End Set
    End Property
	
    Private _FAX_NO As String
    Public Property FAX_NO() As String
        Get
            Return _FAX_NO
        End Get
        Set(ByVal value As String)
            _FAX_NO = value
        End Set
    End Property
	
    Private _TEL_NO As String
    Public Property TEL_NO() As String
        Get
            Return _TEL_NO
        End Get
        Set(ByVal value As String)
            _TEL_NO = value
        End Set
    End Property
	
    Private _COMPANY_TYPE As String
    Public Property COMPANY_TYPE() As String
        Get
            Return _COMPANY_TYPE
        End Get
        Set(ByVal value As String)
            _COMPANY_TYPE = value
        End Set
    End Property
    
    Private _PRICE_CLASS As String
    Public Property PRICE_CLASS() As String
        Get
            Return _PRICE_CLASS
        End Get
        Set(ByVal value As String)
            _PRICE_CLASS = value
        End Set
    End Property
    
    Private _CURRENCY As String
    Public Property CURRENCY() As String
        Get
            Return _CURRENCY
        End Get
        Set(ByVal value As String)
            _CURRENCY = value
        End Set
    End Property
    
    Private _COUNTRY As String
    Public Property COUNTRY() As String
        Get
            Return _COUNTRY
        End Get
        Set(ByVal value As String)
            _COUNTRY = value
        End Set
    End Property
    
    Private _REGION As String
    Public Property REGION() As String
        Get
            Return _REGION
        End Get
        Set(ByVal value As String)
            _REGION = value
        End Set
    End Property
    
    Private _ZIP_CODE As String
    Public Property ZIP_CODE() As String
        Get
            Return _ZIP_CODE
        End Get
        Set(ByVal value As String)
            _ZIP_CODE = value
        End Set
    End Property
    
    Private _CITY As String
    Public Property CITY() As String
        Get
            Return _CITY
        End Get
        Set(ByVal value As String)
            _CITY = value
        End Set
    End Property
    
    Private _ATTENTION As String
    Public Property ATTENTION() As String
        Get
            Return _ATTENTION
        End Get
        Set(ByVal value As String)
            _ATTENTION = value
        End Set
    End Property
    
    Private _CREDIT_TERM As String
    Public Property CREDIT_TERM() As String
        Get
            Return _CREDIT_TERM
        End Get
        Set(ByVal value As String)
            _CREDIT_TERM = value
        End Set
    End Property
    
    Private _SHIP_VIA As String
    Public Property SHIP_VIA() As String
        Get
            Return _SHIP_VIA
        End Get
        Set(ByVal value As String)
            _SHIP_VIA = value
        End Set
    End Property
    
    Private _URL As String
    Public Property URL() As String
        Get
            Return _URL
        End Get
        Set(ByVal value As String)
            _URL = value
        End Set
    End Property
    
    Private _CREATEDDATE As String
    Public Property CREATEDDATE() As String
        Get
            Return _CREATEDDATE
        End Get
        Set(ByVal value As String)
            _CREATEDDATE = value
        End Set
    End Property
    
    Private _CREATED_BY As String
    Public Property CREATED_BY() As String
        Get
            Return _CREATED_BY
        End Get
        Set(ByVal value As String)
            _CREATED_BY = value
        End Set
    End Property
    
    Private _COMPANY_PRICE_TYPE As String
    Public Property COMPANY_PRICE_TYPE() As String
        Get
            Return _COMPANY_PRICE_TYPE
        End Get
        Set(ByVal value As String)
            _COMPANY_PRICE_TYPE = value
        End Set
    End Property
    
    Private _SHIPCONDITION As String
    Public Property SHIPCONDITION() As String
        Get
            Return _SHIPCONDITION
        End Get
        Set(ByVal value As String)
            _SHIPCONDITION = value
        End Set
    End Property
    
    Private _ATTRIBUTE4 As String
    Public Property ATTRIBUTE4() As String
        Get
            Return _ATTRIBUTE4
        End Get
        Set(ByVal value As String)
            _ATTRIBUTE4 = value
        End Set
    End Property
    
    Private _SALESOFFICE As String
    Public Property SALESOFFICE() As String
        Get
            Return _SALESOFFICE
        End Get
        Set(ByVal value As String)
            _SALESOFFICE = value
        End Set
    End Property
    
    Private _SALESGROUP As String
    Public Property SALESGROUP() As String
        Get
            Return _SALESGROUP
        End Get
        Set(ByVal value As String)
            _SALESGROUP = value
        End Set
    End Property
    
    Private _AMT_INSURED As Decimal
    Public Property AMT_INSURED() As Decimal
        Get
            Return _AMT_INSURED
        End Get
        Set(ByVal value As Decimal)
            _AMT_INSURED = value
        End Set
    End Property
    
    Private _CREDIT_LIMIT As Decimal
    Public Property CREDIT_LIMIT() As Decimal
        Get
            Return _CREDIT_LIMIT
        End Get
        Set(ByVal value As Decimal)
            _CREDIT_LIMIT = value
        End Set
    End Property
    
    Private _CONTACT_EMAIL As String
    Public Property CONTACT_EMAIL() As String
        Get
            Return _CONTACT_EMAIL
        End Get
        Set(ByVal value As String)
            _CONTACT_EMAIL = value
        End Set
    End Property
    
    Private _DELETION_FLAG As String
    Public Property DELETION_FLAG() As String
        Get
            Return _DELETION_FLAG
        End Get
        Set(ByVal value As String)
            _DELETION_FLAG = value
        End Set
    End Property
    
    Private _COUNTRY_NAME As String
    Public Property COUNTRY_NAME() As String
        Get
            Return _COUNTRY_NAME
        End Get
        Set(ByVal value As String)
            _COUNTRY_NAME = value
        End Set
    End Property
    
    Private _SALESOFFICENAME As String
    Public Property SALESOFFICENAME() As String
        Get
            Return _SALESOFFICENAME
        End Get
        Set(ByVal value As String)
            _SALESOFFICENAME = value
        End Set
    End Property
    
    Private _SAP_SALESNAME As String
    Public Property SAP_SALESNAME() As String
        Get
            Return _SAP_SALESNAME
        End Get
        Set(ByVal value As String)
            _SAP_SALESNAME = value
        End Set
    End Property
    
    Private _SAP_SALESCODE As String
    Public Property SAP_SALESCODE() As String
        Get
            Return _SAP_SALESCODE
        End Get
        Set(ByVal value As String)
            _SAP_SALESCODE = value
        End Set
    End Property
    
    Private _SAP_ISNAME As String
    Public Property SAP_ISNAME() As String
        Get
            Return _SAP_ISNAME
        End Get
        Set(ByVal value As String)
            _SAP_ISNAME = value
        End Set
    End Property
    
    Private _SAP_OPNAME As String
    Public Property SAP_OPNAME() As String
        Get
            Return _SAP_OPNAME
        End Get
        Set(ByVal value As String)
            _SAP_OPNAME = value
        End Set
    End Property
    
    Private _SECTOR As String
    Public Property SECTOR() As String
        Get
            Return _SECTOR
        End Get
        Set(ByVal value As String)
            _SECTOR = value
        End Set
    End Property
    
    Private _PRIMARY_BAA As String
    Public Property PRIMARY_BAA() As String
        Get
            Return _PRIMARY_BAA
        End Get
        Set(ByVal value As String)
            _PRIMARY_BAA = value
        End Set
    End Property
    
    Private _ACCOUNT_ROW_ID As String
    Public Property ACCOUNT_ROW_ID() As String
        Get
            Return _ACCOUNT_ROW_ID
        End Get
        Set(ByVal value As String)
            _ACCOUNT_ROW_ID = value
        End Set
    End Property
    
    Private _ACCOUNT_NAME As String
    Public Property ACCOUNT_NAME() As String
        Get
            Return _ACCOUNT_NAME
        End Get
        Set(ByVal value As String)
            _ACCOUNT_NAME = value
        End Set
    End Property
    
    Private _ACCOUNT_STATUS As String
    Public Property ACCOUNT_STATUS() As String
        Get
            Return _ACCOUNT_STATUS
        End Get
        Set(ByVal value As String)
            _ACCOUNT_STATUS = value
        End Set
    End Property
    
    Private _RBU As String
    Public Property RBU() As String
        Get
            Return _RBU
        End Get
        Set(ByVal value As String)
            _RBU = value
        End Set
    End Property
    
    Private _PRIMARY_SALES_EMAIL As String
    Public Property PRIMARY_SALES_EMAIL() As String
        Get
            Return _PRIMARY_SALES_EMAIL
        End Get
        Set(ByVal value As String)
            _PRIMARY_SALES_EMAIL = value
        End Set
    End Property
    
    Private _PRIMARY_OWNER_DIVISION As String
    Public Property PRIMARY_OWNER_DIVISION() As String
        Get
            Return _PRIMARY_OWNER_DIVISION
        End Get
        Set(ByVal value As String)
            _PRIMARY_OWNER_DIVISION = value
        End Set
    End Property
    
    Private _BUSINESS_GROUP As String
    Public Property BUSINESS_GROUP() As String
        Get
            Return _BUSINESS_GROUP
        End Get
        Set(ByVal value As String)
            _BUSINESS_GROUP = value
        End Set
    End Property
    
    Private _ACCOUNT_TYPE As String
    Public Property ACCOUNT_TYPE() As String
        Get
            Return _ACCOUNT_TYPE
        End Get
        Set(ByVal value As String)
            _ACCOUNT_TYPE = value
        End Set
    End Property
    
    Private _CUST_IND As String
    Public Property CUST_IND() As String
        Get
            Return _CUST_IND
        End Get
        Set(ByVal value As String)
            _CUST_IND = value
        End Set
    End Property
    
    Private _VM As String
    Public Property VM() As String
        Get
            Return _VM
        End Get
        Set(ByVal value As String)
            _VM = value
        End Set
    End Property
    
    Private _PRICE_GRP As String
    Public Property PRICE_GRP() As String
        Get
            Return _PRICE_GRP
        End Get
        Set(ByVal value As String)
            _PRICE_GRP = value
        End Set
    End Property
    
    Private _PRICE_LIST As String
    Public Property PRICE_LIST() As String
        Get
            Return _PRICE_LIST
        End Get
        Set(ByVal value As String)
            _PRICE_LIST = value
        End Set
    End Property
    
    Private _INCO1 As String
    Public Property INCO1() As String
        Get
            Return _INCO1
        End Get
        Set(ByVal value As String)
            _INCO1 = value
        End Set
    End Property
    
    Private _INCO2 As String
    Public Property INCO2() As String
        Get
            Return _INCO2
        End Get
        Set(ByVal value As String)
            _INCO2 = value
        End Set
    End Property
    
    Private _PAYMENT_TERM_CODE As String
    Public Property PAYMENT_TERM_CODE() As String
        Get
            Return _PAYMENT_TERM_CODE
        End Get
        Set(ByVal value As String)
            _PAYMENT_TERM_CODE = value
        End Set
    End Property
    
    Private _PAYMENT_TERM_NAME As String
    Public Property PAYMENT_TERM_NAME() As String
        Get
            Return _PAYMENT_TERM_NAME
        End Get
        Set(ByVal value As String)
            _PAYMENT_TERM_NAME = value
        End Set
    End Property
    
    Private _ID As Integer
    Public Property ID() As Integer
        Get
            Return _ID
        End Get
        Set(ByVal value As Integer)
            _ID = value
        End Set
    End Property
End Class