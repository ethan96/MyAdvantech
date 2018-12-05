Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Web.Script.Services
Imports System.Globalization

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
<System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://my.advantech.eu")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class MyServices
    Inherits System.Web.Services.WebService

#Region "SAP RFCs"

    <Serializable()> _
    Class CAPSPriceATP
        Public Property IsFuncCallOK As Boolean : Public Property ReturnMessage As String : Public Property AdvantechPN As String : Public Property MPN As String
        Public Property ATPRecords As List(Of ATPRecord)
        Public Property UnitPrice As Decimal : Public Property Currency As String
        Public Sub New()
            IsFuncCallOK = False : ReturnMessage = "" : AdvantechPN = "" : ATPRecords = New List(Of ATPRecord) : UnitPrice = -1 : Currency = ""
        End Sub
    End Class

    <Serializable()> _
    Class ATPRecord
        Public Property Qty As Integer : Public Property Plant As String : Public Property AvailableDate As Date
        Public Sub New(Qty As Integer, Plant As String, AvailableDate As Date)
            Me.Qty = Qty : Me.Plant = Plant : Me.AvailableDate = AvailableDate
        End Sub

        Public Sub New()
            Me.Qty = -1 : Me.Plant = "" : Me.AvailableDate = Date.MaxValue
        End Sub

    End Class

    <Serializable()> _
    Public Enum PNValueTypes
        MPN
        AdvantechPN
    End Enum

    <WebMethod()> _
    Public Function GetCAPSPriceATPV2(ByVal Email As String, ByVal InputPNValue As String, ByVal PNType As PNValueTypes) As CAPSPriceATP
        Threading.Thread.Sleep((New Random).Next(400, 1300))
        Dim CAPSPriceATP1 As New CAPSPriceATP
        If String.IsNullOrEmpty(Email) Or Not Util.IsValidEmailFormat(Email) Then
            CAPSPriceATP1.ReturnMessage = String.Format("{0} is not in valid email format", Email) : Return CAPSPriceATP1
        End If
        Dim erpId As Object = dbUtil.dbExecuteScalar("MY", _
                               " select top 1 a.ERPID from SIEBEL_CONTACT a inner join SAP_DIMCOMPANY b on a.ERPID=b.COMPANY_ID  " + _
                               " where b.COMPANY_TYPE='Z001' and b.COMPANY_ID in ('T27957723','T23718011','T70604376','T84469443','T27998246') " + _
                               " and dbo.IsEmail(a.EMAIL_ADDRESS)=1 and a.EMAIL_ADDRESS='" + Trim(Email).Replace("'", "''") + "' " + _
                               " order by a.ACCOUNT_STATUS  ")
        If erpId Is Nothing Then
            CAPSPriceATP1.ReturnMessage = String.Format("{0} is not well maintained in Siebel", Email) : Return CAPSPriceATP1
        End If

        Dim CompanyId As String = erpId.ToString().ToUpper()
        Dim advPn As String = "", mpn As String = ""
        If PNType = PNValueTypes.MPN Then
            advPn = CAPS_PAPS_Util.GetAdvantechPNByCAPSMPN(InputPNValue) : mpn = InputPNValue
        ElseIf PNType = PNValueTypes.AdvantechPN Then
            advPn = CAPS_PAPS_Util.VerifyCAPSAdvantechPN(InputPNValue, mpn)
        End If
        If String.IsNullOrEmpty(advPn) Then
            CAPSPriceATP1.ReturnMessage = String.Format("MPN o PN {0} cannot be found", InputPNValue) : Return CAPSPriceATP1
        Else
            CAPSPriceATP1.AdvantechPN = advPn : CAPSPriceATP1.MPN = mpn
        End If

        Dim PNValue As String = Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(advPn))

        Dim SalesOrgs As New List(Of String), Plants As New List(Of String)
        With Plants
            .Add("ADK1") : .Add("ACH2") : .Add("TWH1")
        End With
        With SalesOrgs
            .Add("TW07")
        End With

        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        For Each plant As String In Plants
            Dim Inventory As Integer = 0
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
            rOfretTb.Req_Qty = 9999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd") : retTb.Add(rOfretTb)
            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PNValue, plant, _
                                          "", "", "", "", "PC", "", Inventory, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            For Each atpRecord As GET_MATERIAL_ATP.BAPIWMDVE In atpTb
                If atpRecord.Com_Qty > 0 Then
                    Dim ATPRecord1 As New ATPRecord(atpRecord.Com_Qty, plant, Date.ParseExact(atpRecord.Com_Date, "yyyyMMdd", New System.Globalization.CultureInfo("en-US")))
                    CAPSPriceATP1.ATPRecords.Add(ATPRecord1)
                End If
            Next
        Next
        p1.Connection.Close()

        'CAPSPriceATP1.ATPRecords.Clear()
        'CAPSPriceATP1.ATPRecords.Add(New ATPRecord(999, "ADK1", Now.AddDays(1)))

        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        For Each SalesOrg As String In SalesOrgs
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = CompanyId : .Mandt = "168" : .Matnr = PNValue : .Mglme = 1 : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = SalesOrg
            End With
            pin.Add(prec)
        Next
        eup.Connection.Open()
        eup.Z_Sd_Eupriceinquery("1", pin, pout)
        eup.Connection.Close()
        If pout.Count > 0 Then
            CAPSPriceATP1.Currency = pout(0).Waerk : CAPSPriceATP1.UnitPrice = pout(0).Netwr : CAPSPriceATP1.IsFuncCallOK = True
            'CAPSPriceATP1.UnitPrice = 777
            Return CAPSPriceATP1
        Else
            CAPSPriceATP1.ReturnMessage = "Cannot get price"
            Return CAPSPriceATP1
        End If
    End Function

    <WebMethod()> _
    Public Function GetCAPSPriceATP(ByVal Email As String, ByVal MPN As String) As CAPSPriceATP
        Threading.Thread.Sleep((New Random).Next(400, 1300))
        Dim CAPSPriceATP1 As New CAPSPriceATP
        If String.IsNullOrEmpty(Email) Or Not Util.IsValidEmailFormat(Email) Then
            CAPSPriceATP1.ReturnMessage = String.Format("{0} is not in valid email format", Email) : Return CAPSPriceATP1
        End If
        Dim erpId As Object = dbUtil.dbExecuteScalar("MY", _
                               " select top 1 a.ERPID from SIEBEL_CONTACT a inner join SAP_DIMCOMPANY b on a.ERPID=b.COMPANY_ID  " + _
                               " where b.COMPANY_TYPE='Z001' and b.COMPANY_ID in ('T27957723','T23718011','T70604376','T84469443','T27998246') " + _
                               " and dbo.IsEmail(a.EMAIL_ADDRESS)=1 and a.EMAIL_ADDRESS='" + Trim(Email).Replace("'", "''") + "' " + _
                               " order by a.ACCOUNT_STATUS  ")
        If erpId Is Nothing Then
            CAPSPriceATP1.ReturnMessage = String.Format("{0} is not well maintained in Siebel", Email) : Return CAPSPriceATP1
        End If

        Dim CompanyId As String = erpId.ToString().ToUpper()

        Dim advPn As String = CAPS_PAPS_Util.GetAdvantechPNByCAPSMPN(MPN)
        If String.IsNullOrEmpty(advPn) Then
            CAPSPriceATP1.ReturnMessage = String.Format("MPN {0} cannot be found", MPN) : Return CAPSPriceATP1
        Else
            CAPSPriceATP1.AdvantechPN = advPn
        End If

        Dim PNValue As String = Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(advPn))

        Dim SalesOrgs As New List(Of String), Plants As New List(Of String)
        With Plants
            .Add("ADK1") : .Add("ACH2") : .Add("TWH1")
        End With
        With SalesOrgs
            .Add("TW07")
        End With

        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        For Each plant As String In Plants
            Dim Inventory As Integer = 0
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
            rOfretTb.Req_Qty = 9999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd") : retTb.Add(rOfretTb)
            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PNValue, plant, _
                                          "", "", "", "", "PC", "", Inventory, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            For Each atpRecord As GET_MATERIAL_ATP.BAPIWMDVE In atpTb
                If atpRecord.Com_Qty > 0 Then
                    Dim ATPRecord1 As New ATPRecord(atpRecord.Com_Qty, plant, Date.ParseExact(atpRecord.Com_Date, "yyyyMMdd", New System.Globalization.CultureInfo("en-US")))
                    CAPSPriceATP1.ATPRecords.Add(ATPRecord1)
                End If
            Next
        Next
        p1.Connection.Close()

        'CAPSPriceATP1.ATPRecords.Clear()
        'CAPSPriceATP1.ATPRecords.Add(New ATPRecord(999, "ADK1", Now.AddDays(1)))

        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        For Each SalesOrg As String In SalesOrgs
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = CompanyId : .Mandt = "168" : .Matnr = PNValue : .Mglme = 1 : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = SalesOrg
            End With
            pin.Add(prec)
        Next
        eup.Connection.Open()
        eup.Z_Sd_Eupriceinquery("1", pin, pout)
        eup.Connection.Close()
        If pout.Count > 0 Then
            CAPSPriceATP1.Currency = pout(0).Waerk : CAPSPriceATP1.UnitPrice = pout(0).Netwr : CAPSPriceATP1.IsFuncCallOK = True
            'CAPSPriceATP1.UnitPrice = 777
            Return CAPSPriceATP1
        Else
            CAPSPriceATP1.ReturnMessage = "Cannot get price"
            Return CAPSPriceATP1
        End If

    End Function

    Class SAPPrice
        Public Property ListPrice As Decimal : Public Property UnitPrice As Decimal : Public Property Currency As String : Public Property IsCalledSuccess As Boolean : Public Property ErrorString As String
        Public Sub New(ByVal ListPrice As Decimal, ByVal UnitPrice As Decimal, ByVal Currency As String)
            Me.ListPrice = ListPrice : Me.UnitPrice = UnitPrice : Me.Currency = Currency : IsCalledSuccess = True : ErrorString = ""
        End Sub
        Public Sub New()
            Me.ListPrice = -1 : Me.UnitPrice = -1 : Me.Currency = "" : IsCalledSuccess = False : ErrorString = ""
        End Sub
    End Class

    <WebMethod()> _
    Public Function GetPrice(ByVal CompanyId As String, ByVal OrgId As String, ByVal PartNo As String) As SAPPrice
        Threading.Thread.Sleep(350)
        Dim SAPPrice1 As New SAPPrice()
        Dim priceCache As Dictionary(Of String, SAPPrice) = HttpContext.Current.Cache("eRMAPriceCache")
        If priceCache Is Nothing Then
            priceCache = New Dictionary(Of String, SAPPrice)
            HttpContext.Current.Cache.Add("eRMAPriceCache", priceCache, Nothing, Now.AddHours(1), Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If

        If Not priceCache.ContainsKey(CompanyId + "," + OrgId + "," + PartNo) Then
            Dim Kunnr As String = UCase(CompanyId), org As String = UCase(OrgId)
            Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY, pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = Kunnr : .Mandt = "168" : .Matnr = Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(PartNo)) : .Mglme = 1 : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = org
            End With
            pin.Add(prec)
            eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            eup.Connection.Open()
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
            eup.Connection.Close()
            If pout.Count > 0 Then
                With SAPPrice1
                    .ListPrice = pout.Item(0).Kzwi1 : .UnitPrice = pout.Item(0).Netwr : .Currency = pout.Item(0).Waerk : .IsCalledSuccess = True : .ErrorString = ""
                    If .UnitPrice > .ListPrice Then .ListPrice = .UnitPrice
                End With
            Else
                SAPPrice1.IsCalledSuccess = False : SAPPrice1.ErrorString = "Error getting price"
            End If
            priceCache.Add(CompanyId + "," + OrgId + "," + PartNo, SAPPrice1)
        End If
        If priceCache.ContainsKey(CompanyId + "," + OrgId + "," + PartNo) Then
            Return priceCache.Item(CompanyId + "," + OrgId + "," + PartNo)
        Else
            SAPPrice1.IsCalledSuccess = False : SAPPrice1.ErrorString = "Error getting price" : Return SAPPrice1
        End If
    End Function
#End Region

#Region "AE KB Search"
    Public Class KBSearchOptions
        Public AE_FTP As Boolean, iPlanet_Forum As Boolean, ADAM_Community As Boolean, Siebel_SR As Boolean
        Public Sub New(ByVal FTP As Boolean, ByVal iPlanet As Boolean, ByVal ADAM As Boolean, ByVal SR As Boolean)
            AE_FTP = FTP : iPlanet_Forum = iPlanet : ADAM_Community = ADAM : Siebel_SR = SR
        End Sub
        Public Sub New()
            AE_FTP = True : iPlanet_Forum = True : ADAM_Community = True : Siebel_SR = True
        End Sub
    End Class
    <WebMethod()> _
    Public Function Search_AE_KB(ByVal keyword As String, ByRef QueryOption As KBSearchOptions, ByRef ErrMsg As String) As DataSet
        ErrMsg = ""
        Threading.Thread.Sleep(8000)
        'Dim _ip As String = Util.GetClientIP(), validIPs() As String = {"172.16.11.107", "172.16.6.15", "172.20.1.31", "172.20.1.21", "::1", "172.21.129.228"}
        'If Not validIPs.Contains(_ip) AndAlso Not _ip.StartsWith("172.20.") _
        '    AndAlso Not _ip.StartsWith("127.") AndAlso Not _ip.StartsWith("172.16.") Then
        '    HttpContext.Current.Response.StatusCode = 400 : HttpContext.Current.Response.End()
        'End If
        Try
            Dim dt As New DataTable("MySearchResult")
            Dim sesId As String = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 24)
            If Session IsNot Nothing AndAlso Session.SessionID IsNot Nothing Then sesId = Session.SessionID
            dbUtil.dbExecuteNoQuery("MyLocal", _
                                 " delete from KM_SEARCH_TMP_DETAIL where search_row_id in (select row_id from KM_SEARCH_TMP_MASTER where query_datetime<=getdate()-1); " + _
                                 " delete from KM_SEARCH_TMP_MASTER where query_datetime<=getdate()-1")

            Dim dtMaster As New DataTable
            With dtMaster.Columns
                .Add("ROW_ID") : .Add("SESSIONID") : .Add("USERID") : .Add("QUERY_DATETIME", GetType(DateTime)) : .Add("KEYWORDS")
            End With
            Dim r As DataRow = dtMaster.NewRow()
            r.Item("ROW_ID") = Left(Util.NewRowId("KM_SEARCH_TMP_MASTER", "MyLocal"), 10)
            r.Item("SESSIONID") = sesId : r.Item("USERID") = "AEPortal" : r.Item("QUERY_DATETIME") = Now() : r.Item("KEYWORDS") = keyword
            dtMaster.Rows.Add(r)
            Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
            bk.DestinationTableName = "KM_SEARCH_TMP_MASTER"
            bk.WriteToServer(dtMaster)
            Dim ThreadList As New ArrayList, KSObj As New ArrayList
            If QueryOption.iPlanet_Forum Then
                Dim ks As New KM_Search(keyword, sesId, r.Item("ROW_ID"))
                ks.strWebAppName = "iPlanet"
                Dim t As New Threading.Thread(AddressOf ks.SearchWEB) : t.Start() : t.Join()
                ThreadList.Add(t) : KSObj.Add(ks)
            End If
            If QueryOption.ADAM_Community Then
                Dim ks As New KM_Search(keyword, sesId, r.Item("ROW_ID"))
                ks.strWebAppName = "ADAM Community"
                Dim t As New Threading.Thread(AddressOf ks.SearchWEB) : t.Start() : t.Join()
                ThreadList.Add(t) : KSObj.Add(ks)
            End If
            If QueryOption.AE_FTP Then
                Dim ks As New KM_Search(keyword, sesId, r.Item("ROW_ID"))
                Dim t As New Threading.Thread(AddressOf ks.SearchAEFTP) : t.Start() : t.Join()
                ThreadList.Add(t) : KSObj.Add(ks)
            End If
            If QueryOption.Siebel_SR Then
                Dim ks As New KM_Search(keyword, sesId, r.Item("ROW_ID"))
                Dim t As New Threading.Thread(AddressOf ks.SearchSR) : t.Start() : t.Join() : t.Join()
                ThreadList.Add(t) : KSObj.Add(ks)
            End If
            'For Each t As Threading.Thread In ThreadList
            '    t.Join()
            'Next
            For Each ks As KM_Search In KSObj
                If ks.SearchFlg Then
                    Dim tmpDt As DataTable = ks.ResultDt
                    Dim bk2 As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
                    bk2.DestinationTableName = "KM_SEARCH_TMP_DETAIL"
                    bk2.WriteToServer(tmpDt)
                    dt.Merge(tmpDt)
                Else
                    ErrMsg += "|" + ks.strErrMsg
                End If
            Next
            If dt.Rows.Count > 0 Then
                Dim removeColumnNames() As String = {"SEARCH_ROW_ID", "SOURCE_ID", "THUMBNAIL_URL", "RANK_VALUE", "SOURCE_APP", "SOURCE_ROW_ID", "URL"}
                Dim tmpSiteURL As String = Util.GetRuntimeSiteUrl()

                'Frank 2012/04/02: There is a exception "Column 'ORIGINAL_URL' does not belong to table MySearchResult."
                'Therefore I add this column in dt if not exist.
                If dt.Columns.IndexOf("ORIGINAL_URL") < 0 Then
                    dt.Columns.Add("ORIGINAL_URL")
                End If

                Dim _keywords(0) As String
                _keywords(0) = keyword
                For Each rr As DataRow In dt.Rows
                    rr.Item("ORIGINAL_URL") = String.Format("{0}/DM/KM/KMSource.ashx?SrcType={1}&SrcId={2}", tmpSiteURL, rr.Item("SOURCE_APP"), rr.Item("SOURCE_ID"))
                    'Frank 2012/04/17: Getting sentences by keyword
                    'rr.Item("CONTENT_TEXT") = Regex.Replace(Highlight(keyword, rr.Item("CONTENT_TEXT")), "\p{C}+", "")
                    rr.Item("CONTENT_TEXT") = Regex.Replace(Util.Highlight(keyword, Util.GetSentenceByKeyword(rr.Item("CONTENT_TEXT"), _keywords, 70, 35)), "\p{C}+", "")
                Next
                For Each reCol As String In removeColumnNames
                    If dt.Columns.Contains(reCol) Then dt.Columns.Remove(reCol)
                Next
            End If
            If String.IsNullOrEmpty(ErrMsg) = False Then ErrMsg = "Error in WS: " + Right(ErrMsg, 50)

            'Frank 2012/04/24:It's better to return dataset that includes the datatable 
            'Return dt
            Dim _returnDS As New DataSet
            _returnDS.Tables.Add(dt)
            Return _returnDS

        Catch ex As Exception
            ErrMsg = ex.Message : Return Nothing
        End Try
    End Function



#End Region
    Class CoBrandingInfo
        Private _SiteName As String, _SiteURL As String
        Public Property SiteName As String
            Get
                Return _SiteName
            End Get
            Set(ByVal value As String)
                _SiteName = value
            End Set
        End Property

        Public Property AdminSiteURL As String
            Get
                Return _SiteURL
            End Get
            Set(ByVal value As String)
                _SiteURL = value
            End Set
        End Property

    End Class

    <Services.WebMethod()> _
    Public Function GetCoBranding() As String
        Dim _CoBrand As New AdvantechCoBrandingPartnerPortal.CoBrandingPartnerWebservice
        Dim _returnval() As AdvantechCoBrandingPartnerPortal.PartnerListEntity = _CoBrand.GetCoBrandingPartnerSitesByEmail(HttpContext.Current.User.Identity.Name)
        Dim _CoBrandingInfo(_returnval.Length - 1) As MyServices.CoBrandingInfo, i = 0
        'Dim _CoBrandingInfo(0) As CoBrandingInfo, i = 0
        For Each _item As AdvantechCoBrandingPartnerPortal.PartnerListEntity In _returnval
            _CoBrandingInfo(i) = New CoBrandingInfo
            _CoBrandingInfo(i).SiteName = _item.partnerName
            _CoBrandingInfo(i).AdminSiteURL = _item.urlAdminSite
            'Exit For
            i += 1
        Next

        Dim serializer = New Script.Serialization.JavaScriptSerializer()
        Dim json As String = serializer.Serialize(_CoBrandingInfo)
        Return json
    End Function

    <WebMethod()> _
    Public Function SearchPISModelInfo(ByVal keywords As String) As DataSet
        Threading.Thread.Sleep(3000)
        If Trim(keywords) = "" Then Return Nothing
        Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(keywords))
        Dim strKey As String = fts.NormalForm.Replace("'", "''")
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("PIS").ConnectionString)
        Dim ds As New DataSet("PIS_Search")
        Dim dt As New DataTable("MyAdvantech_PIS")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT top 100 b.search_rank, a.ROW_ID, a.MODEL_NAME, a.Active_FLG, a.MODEL_DESC,  "))
            .AppendLine(String.Format(" a.DISPLAY_NAME, a.EXTENDED_DESC, a.KEYWORDS, a.Publish_Status, a.Site_ID,  "))
            .AppendLine(String.Format(" a.model_features, a.LANG_extended_desc, a.LANG_keyword, a.LANG_model_desc,  "))
            .AppendLine(String.Format(" a.PART_NUMBERS, a.Category_id, a.CATEGORY_DESC,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.CATEGORY_DISPLAY_NAME, a.product_spec "))
            .AppendLine(String.Format(" FROM PIS_MODEL_FULLTEXT AS a INNER JOIN  "))
            .AppendLine(String.Format(" ( "))
            .AppendLine(String.Format(" 	SELECT [KEY] AS row_id, RANK AS search_rank "))
            .AppendLine(String.Format(" 	FROM CONTAINSTABLE(PIS_MODEL_FULLTEXT,  "))
            .AppendLine(String.Format(" 		(MODEL_NAME, MODEL_DESC, DISPLAY_NAME, EXTENDED_DESC, KEYWORDS, model_features,  "))
            .AppendLine(String.Format(" 		 LANG_model_desc, literature_texts, PART_NUMBERS, product_spec, CATEGORY_DISPLAY_NAME),  "))
            .AppendLine(String.Format(" 	N'{0}')) AS b ON a.ROW_ID = b.row_id ", strKey))
            .AppendLine(String.Format(" ORDER BY b.search_rank DESC "))
            .AppendLine(String.Format("  "))
        End With
        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
        apt.Fill(dt)
        If dt.Rows.Count = 0 Then
            dt = New DataTable("MyAdvantech_PIS")
            sb = New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" SELECT top 100 100 as search_rank, a.ROW_ID, a.MODEL_NAME, a.Active_FLG, a.MODEL_DESC,  "))
                .AppendLine(String.Format(" a.DISPLAY_NAME, a.EXTENDED_DESC, a.KEYWORDS, a.Publish_Status, a.Site_ID,  "))
                .AppendLine(String.Format(" a.model_features, a.LANG_extended_desc, a.LANG_keyword, a.LANG_model_desc,  "))
                .AppendLine(String.Format(" a.PART_NUMBERS, a.Category_id, a.CATEGORY_DESC,  "))
                .AppendLine(String.Format(" a.CATEGORY_NAME, a.CATEGORY_DISPLAY_NAME, a.product_spec "))
                .AppendLine(String.Format(" FROM PIS_MODEL_FULLTEXT AS a "))
                .AppendLine(String.Format(" where  "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	a.MODEL_NAME like N'%{0}%' or a.MODEL_DESC like N'%{0}%' or a.DISPLAY_NAME like N'%{0}%' or a.EXTENDED_DESC like N'%{0}%' or ", Trim(keywords).Replace("'", "''")))
                .AppendLine(String.Format(" 	a.model_features like N'%{0}%' or a.LANG_extended_desc like N'%{0}%' or a.LANG_keyword like N'%{0}%' or a.LANG_model_desc like N'%{0}%'  ", Trim(keywords).Replace("'", "''")))
                .AppendLine(String.Format(" ) "))
                .AppendLine(String.Format(" order by a.MODEL_NAME  "))
            End With
            apt.SelectCommand.CommandText = sb.ToString()
            apt.Fill(dt)
        End If
        conn.Close()
        ds.Tables.Add(dt)
        Return ds
    End Function

    <WebMethod()> _
    Public Function getExRate(ByVal C_FROM As String, ByVal C_TO As String) As Decimal
        Threading.Thread.Sleep(1000)
        Return Glob.get_exchangerate(C_FROM, C_TO)
    End Function

    Public Class ElearningContact
        Public Email As String
        Public CompanyId As String
        Public OrgId As String
        Public Sub New()

        End Sub
        Public Sub New(ByVal mail As String, ByVal cid As String, ByVal oid As String)
            Email = mail : CompanyId = cid : OrgId = oid
        End Sub
    End Class
    <WebMethod()> _
    Public Function GetElearningContactInfo(ByVal email As String) As ElearningContact()
        If Trim(email) = "" OrElse Util.IsValidEmailFormat(email) = False Then Return Nothing
        Threading.Thread.Sleep(500)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                                                    "select top 10 userid, company_id, org_id " + _
                                                    " from v_el_contact where userid='" + Replace(Trim(email), "'", "''") + "'")
        If dt.Rows.Count = 0 Then Return Nothing
        Dim ret(dt.Rows.Count - 1) As ElearningContact
        For i As Integer = 0 To dt.Rows.Count - 1
            ret(i) = New ElearningContact(dt.Rows(i).Item("userid"), dt.Rows(i).Item("company_id"), dt.Rows(i).Item("org_id"))
        Next
        Return ret
    End Function

    <WebMethod()> _
    Public Function GetEmailStatus(ByVal email As String) As Boolean
        Threading.Thread.Sleep(500)
        Dim reg As String = "^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
        Dim options As RegexOptions = RegexOptions.Singleline
        If Regex.Matches(email, reg, options).Count = 0 Then
            Return False
        Else
            Return True
        End If
    End Function

    <WebMethod()> _
    Public Function IsValidAddr(ByVal addr As String) As Boolean
        Threading.Thread.Sleep(500)
        'Return GetCoordinateByAddress(addr, 0, 0, "")
    End Function

    <WebMethod()> _
    Public Function GetAccountStatusByContactEmail(ByVal email As String) As String
        Threading.Thread.Sleep(5000)
        If GetEmailStatus(email) = False Then Return "Email format is incorrect"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "select top 1 account_status from siebel_contact where account_status<>'' and email_Address='" + email.Trim().Replace("'", "''") + "' order by account_status")
        If dt.Rows.Count = 1 Then
            Return dt.Rows(0).Item("account_status")
        End If
        Return "N/A"
    End Function

    'Public Shared Function GetCoordinateByAddress( _
    ' ByRef Address As String, ByRef Longitude As Double, ByRef Latitude As Double, ByRef ResponseXml As String) As Boolean
    '    Return False
    '    Dim sURL As String = "http://maps.google.com/maps/geo?q=" + Address + "&output=xml&key=" + ConfigurationManager.AppSettings("GoogleAPIKey")
    '    Dim request As Net.WebRequest = Net.WebRequest.Create(sURL)
    '    request.Proxy = New Net.WebProxy("http://172.21.34.46:8080", True)
    '    request.Proxy.Credentials = New System.Net.NetworkCredential("ebiz.aeu", "@dvantech1", "AESC_NT")
    '    request.Timeout = 10000 : request.Method = "POST"
    '    Dim postData As String = "This is a test that posts this string to a Web server."
    '    Dim byteArray As Byte() = Encoding.UTF8.GetBytes(postData)
    '    request.ContentType = "application/x-www-form-urlencoded"
    '    request.ContentLength = byteArray.Length
    '    Dim dataStream As IO.Stream = request.GetRequestStream()
    '    Dim response As Net.WebResponse = Nothing
    '    Try
    '        dataStream.Write(byteArray, 0, byteArray.Length) : dataStream.Close()
    '        response = request.GetResponse() : dataStream = response.GetResponseStream()
    '    Catch ex As Exception
    '        ResponseXml = ex.ToString() : Return False
    '    End Try
    '    Dim reader As New IO.StreamReader(dataStream)
    '    Dim responseFromServer As String = reader.ReadToEnd()
    '    Dim tx As New IO.StringReader(responseFromServer)
    '    Dim DS As New DataSet()
    '    DS.ReadXml(tx)
    '    Dim StatusCode As Integer = GetIntegerValue(DS.Tables("Status").Rows(0)("code"))
    '    If StatusCode = 200 Then
    '        Dim sLatLon As String = GetStringValue(DS.Tables("Point").Rows(0)("coordinates"))
    '        Dim s As String() = sLatLon.Split(","c)
    '        If s.Length > 1 Then
    '            Latitude = GetNumericValue(s(1)) : Longitude = GetNumericValue(s(0))
    '        End If
    '        Try
    '            If DS.Tables("Placemark") IsNot Nothing Then
    '                Address = GetStringValue(DS.Tables("Placemark").Rows(0)("address"))
    '            End If
    '            If DS.Tables("PostalCode") IsNot Nothing Then
    '                Address += " " + GetStringValue(DS.Tables("PostalCode").Rows(0)("PostalCodeNumber"))
    '            End If
    '        Catch ex As Exception
    '        End Try
    '        Return True
    '    Else
    '        ResponseXml = DS.GetXml() : Return False
    '    End If
    'End Function

    'Public Shared Function GetIntegerValue(ByVal pNumValue As Object) As Integer
    '    If (pNumValue Is Nothing) Then
    '        Return 0
    '    End If
    '    If IsNumeric(pNumValue) Then
    '        Return Integer.Parse((pNumValue.ToString()))
    '    Else
    '        Return 0
    '    End If
    'End Function

    'Public Shared Function GetNumericValue(ByVal pNumValue As Object) As Double
    '    If (pNumValue Is Nothing) Then
    '        Return 0
    '    End If
    '    If IsNumeric(pNumValue) Then
    '        Return Double.Parse((pNumValue.ToString()))
    '    Else
    '        Return 0
    '    End If
    'End Function

    'Public Shared Function GetStringValue(ByVal obj As Object) As String
    '    If obj Is Nothing Then
    '        Return ""
    '    End If
    '    If (obj Is Nothing) Then
    '        Return ""
    '    End If
    '    If Not (obj Is Nothing) Then
    '        Return obj.ToString()
    '    Else
    '        Return ""
    '    End If
    'End Function

    <WebMethod()> _
    Public Function SubscribeENews(ByVal Email As String, ByVal eNewsName As String) As Boolean
        Threading.Thread.Sleep(2000)
        Dim siebel_ws As New aeu_ebus_dev.Siebel_WS
        siebel_ws.UseDefaultCredentials = True
        siebel_ws.Timeout = 300000
        Return siebel_ws.SubscribeENews(Email, eNewsName, True)
    End Function

    <WebMethod()> _
    Public Function UnsubscribeENews(ByVal Email As String, ByVal eNewsName As String) As Boolean
        Threading.Thread.Sleep(2000)
        Dim siebel_ws As New aeu_ebus_dev.Siebel_WS
        siebel_ws.UseDefaultCredentials = True
        siebel_ws.Timeout = 300000
        Return siebel_ws.SubscribeENews(Email, eNewsName, False)
    End Function

    <WebMethod()> _
    Public Function HashCodeToEmail(ByVal Hashcode As String) As String
        'If Hashcode = "" Then Return ""
        'Dim HashEmail As Dictionary(Of String, String) = CType(HttpContext.Current.Cache("HashEmail"), Dictionary(Of String, String))

        'If HashEmail Is Nothing Then
        '    HashEmail = New Dictionary(Of String, String)
        '    HttpContext.Current.Cache("HashEmail") = HashEmail
        '    HttpContext.Current.Cache.Add("HashEmail", HashEmail, Nothing, DateTime.Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        'End If

        'If Not HashEmail.ContainsKey(Hashcode) Then
        '    Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", "select email from EMAIL_UNIQUEID where hashvalue='" + Hashcode + "'")
        '    If dt.Rows.Count > 0 Then
        '        HashEmail.Add(Hashcode, dt.Rows(0).Item(0).ToString)
        '    Else
        '        HashEmail.Add(Hashcode, "")
        '    End If
        'End If
        'Return HashEmail.Item(Hashcode)

        Dim sEmail As String = ""
        If Hashcode = "" Then Return ""

        If HttpContext.Current.Cache(Hashcode) Is Nothing Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", "select email from EMAIL_UNIQUEID where hashvalue='" + Hashcode + "'")
            If dt.Rows.Count > 0 Then
                sEmail = dt.Rows(0).Item(0).ToString
            Else
                sEmail = ""
            End If

            HttpContext.Current.Cache.Add(Hashcode, sEmail, Nothing, DateTime.Now.AddMinutes(30), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        Else
            sEmail = CStr(HttpContext.Current.Cache(Hashcode))
        End If
        Return sEmail
    End Function

    <WebMethod()> _
    Public Function EmailToHashCode(ByVal Email As String) As String
        Dim sHashCode As String = ""
        If Email = "" Then Return ""

        If HttpContext.Current.Cache(Email) Is Nothing Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", "select hashvalue from EMAIL_UNIQUEID where email='" + Email + "'")
            If dt.Rows.Count > 0 Then
                sHashCode = dt.Rows(0).Item(0).ToString
            Else
                sHashCode = ""
            End If

            HttpContext.Current.Cache.Add(Email, sHashCode, Nothing, DateTime.Now.AddMinutes(30), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        Else
            sHashCode = CStr(HttpContext.Current.Cache(Email))
        End If

        Return sHashCode
    End Function

    <WebMethod()> _
    Public Function IsAMDSales(ByVal Email As String) As Boolean
        Threading.Thread.Sleep(2000)
        Try
            If dbUtil.dbGetDataTable("MY", String.Format("select email from amd_sales_list where email = '{0}'", Email.Replace("'", "''"))).Rows.Count > 0 Then
                Return True
            Else
                Return False
            End If
        Catch ex As Exception
            Return False
        End Try
    End Function

    <WebMethod()> _
    Public Function GetSAPPartNo(ByVal PN As String) As DataTable
        Threading.Thread.Sleep(500)
        Dim sb As New System.Text.StringBuilder
        With sb
            .Append(" select distinct matnr as part_no, vmsta as product_status ")
            .Append(" from saprdp.MVKE ")
            .Append(" where mandt='168' and vkorg='TW01' and rownum<=100  ")
            .Append(" and matnr not like '#%' and matnr not like '$%' and matnr not like '(DEL)%' ")
            If String.IsNullOrEmpty(PN) = False Then .AppendFormat(" and matnr like '%{0}%' ", Replace(Replace(Trim(UCase(PN)), "'", "''"), "*", "%"))
            .Append(" order by matnr ")
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        dt.TableName = "SAP_Product"
        For Each r As DataRow In dt.Rows
            r.Item("part_no") = Global_Inc.RemoveZeroString(r.Item("part_no"))
        Next
        Return dt
    End Function

    <WebMethod()> _
    Public Function IsSAPPartNoMatch(ByVal PN As String, ByRef ProductStatus As String) As Boolean
        Threading.Thread.Sleep(500)
        If Global_Inc.IsNumericItem(PN) Then PN = Global_Inc.Format2SAPItem(PN)
        Dim sb As New System.Text.StringBuilder
        With sb
            .Append(" select distinct matnr as part_no, vmsta as product_status ")
            .Append(" from saprdp.MVKE ")
            .Append(" where mandt='168' and vkorg='TW01' and rownum<=100  ")
            .Append(" and matnr not like '#%' and matnr not like '$%' and matnr not like '(DEL)%' ")
            If String.IsNullOrEmpty(PN) = False Then .AppendFormat(" and matnr = '{0}' ", Replace(Trim(UCase(PN)), "'", "''"))
            .Append(" order by matnr ")
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        If dt.Rows.Count = 1 Then
            ProductStatus = dt.Rows(0).Item("product_status") : Return True
        End If
        ProductStatus = "N/A" : Return False
    End Function

    Public Shared Sub SyncCMSSolution()
        Dim ws As New WWWLocal.AdvantechWebServiceLocal
        ws.Timeout = -1
        Dim dt As DataTable = ws.getCMS_Category_ListBy("BU/SECTOR", "(Solution)")
        dbUtil.dbExecuteNoQuery("MY", "truncate table cms_solution_lov")
        For Each row As DataRow In dt.Rows
            dbUtil.dbExecuteNoQuery("MY", String.Format("insert into cms_solution_lov (id,value) values ('{0}','{1}')", row.Item("CATEGORY_ID").ToString, row.Item("CATEGORY_NAME").ToString))
        Next
    End Sub

    Public Enum WebApp
        CorpWeb
        eStore
        MyAdvantech
        InnoCore
        Support
        All
    End Enum

    Private Shared Function WebType2String(ByVal WebAppType As WebApp) As String
        Select Case WebAppType
            Case WebApp.CorpWeb
                Return "('Advantech JP','Advantech KR','Advantech TW','Advantech US')"
            Case WebApp.eStore
                Return "('eStore CN','eStore JP','eStore KR','eStore TW','eStore US')"
            Case WebApp.InnoCore
                Return "('Advantech Innocore')"
            Case WebApp.Support
                Return "('Support')"
            Case WebApp.MyAdvantech
                Return "('MyAdvantech')"
            Case Else
                Return "('Advantech US')"
        End Select
    End Function

    <WebMethod()> _
    Function SearchAdvWeb(ByVal SearchKey As String, ByVal WebAppType As WebApp) As DataTable
        Threading.Thread.Sleep(500)
        'If String.IsNullOrEmpty(SearchKey) Then Return ""
        If String.IsNullOrEmpty(SearchKey) Then SearchKey = "*"
        SearchKey = Replace(SearchKey, "*", "%")
        Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(SearchKey))
        Dim strKey As String = fts.NormalForm.Replace("'", "''")
        Dim AD_field As String = "", ES_field As String = ""
        'Me.Isspecial_user(AD_field, ES_field)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct * from ( "))
            .AppendLine(String.Format(" select top 100 b.[rank], a.ContentType, a.APPNAME, a.Meta_Description, "))
            .AppendLine(String.Format(" a.Url, LOWER(a.ResponseUri) as ResponseUri, a.Title, a.[Text], a.GOOGLE_PAGERANK " + _
                                      " from MY_WEB_SEARCH a inner join  "))
            .AppendLine(String.Format(" (  "))
            .AppendLine(String.Format("     select top 100 z.keyid as [key], 1000 as [rank] "))
            .AppendLine(String.Format("     from MY_WEB_SEARCH z where (z.Title like N'%{0}%')  ", SearchKey.Trim().Replace("'", "''").Replace("*", "%")))
            If WebAppType <> WebApp.All Then
                .AppendLine(String.Format(" and z.APPNAME in {0} ", WebType2String(WebAppType)))
            End If
            .AppendLine(String.Format("     order by z.Title "))
            .AppendLine(String.Format("     union "))
            .AppendLine(String.Format(" 	SELECT top 500 [key], [rank]  "))
            .AppendLine(String.Format(" 	from freetexttable(MY_WEB_SEARCH, (title, text, Meta_Description),  "))
            .AppendLine(String.Format(" 	N'{0}') order by [rank] desc ", strKey))
            .AppendLine(String.Format(" ) b on a.keyid=b.[key]  "))
            If WebAppType <> WebApp.All Then
                .AppendLine(String.Format(" and a.APPNAME in {0} ", WebType2String(WebAppType)))
            End If
            .AppendLine(" and a.APPNAME<>'ADAM Community' ")
            .AppendLine(String.Format(" order by (1+a.GOOGLE_PAGERANK)*50+b.[rank]-a.Depth desc "))
            .AppendLine(" ) as t order by t.[rank] desc ")
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        dt.TableName = "AdvWebSearch"
        Return dt
    End Function

    <WebMethod()> _
    Public Function GetProductStatusByOrg(ByVal PartNo As String, ByVal SiebelOrg As String) As DataTable
        Threading.Thread.Sleep(500)
        If String.IsNullOrEmpty(PartNo) Or String.IsNullOrEmpty(SiebelOrg) Then Return New DataTable("OhNo")
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim strSql As String = _
            " select distinct a.SALES_ORG, a.PRODUCT_STATUS " + _
            " from SAP_PRODUCT_STATUS a inner join SAP_DIMCOMPANY b on a.SALES_ORG=b.ORG_ID " + _
            " inner join SIEBEL_ACCOUNT c on b.COMPANY_ID=c.ERP_ID " + _
            " where a.PART_NO=@PN and c.RBU=@ORG " + _
            " and a.SALES_ORG not in " + ConfigurationManager.AppSettings("InvalidOrg") + _
            " order by a.SALES_ORG, a.PRODUCT_STATUS "
        Dim apt As New SqlClient.SqlDataAdapter(strSql, conn)
        apt.SelectCommand.Parameters.AddWithValue("PN", Trim(PartNo)) : apt.SelectCommand.Parameters.AddWithValue("ORG", Trim(SiebelOrg))
        Dim dt As New DataTable("OhYes")
        apt.Fill(dt)
        conn.Close()
        Return dt
    End Function

    <WebMethod()> _
    Public Function GetProductStatusByERPId(ByVal PartNo As String, ByVal ERPID As String) As DataTable
        Threading.Thread.Sleep(500)
        If String.IsNullOrEmpty(PartNo) Or String.IsNullOrEmpty(ERPID) Then Return New DataTable("OhNo")
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim strSql As String = _
            " select distinct a.SALES_ORG, a.PRODUCT_STATUS " + _
            " from SAP_PRODUCT_STATUS a inner join SAP_DIMCOMPANY b on a.SALES_ORG=b.ORG_ID " + _
            " inner join SIEBEL_ACCOUNT c on b.COMPANY_ID=c.ERP_ID " + _
            " where a.PART_NO=@PN and c.ERP_ID=@ERPID " + _
            " and a.SALES_ORG not in " + ConfigurationManager.AppSettings("InvalidOrg") + _
            " order by a.SALES_ORG, a.PRODUCT_STATUS "
        Dim apt As New SqlClient.SqlDataAdapter(strSql, conn)
        apt.SelectCommand.Parameters.AddWithValue("PN", Trim(PartNo)) : apt.SelectCommand.Parameters.AddWithValue("ERPID", Trim(ERPID))
        Dim dt As New DataTable("OhYes")
        apt.Fill(dt)
        conn.Close()
        Return dt
    End Function

    <WebMethod()> _
    Public Function GetProductStatus(ByVal PartNo As String) As DataTable
        Threading.Thread.Sleep(500)
        If String.IsNullOrEmpty(PartNo) Then Return New DataTable("OhNo")
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim strSql As String = _
            " select distinct a.SALES_ORG, a.PRODUCT_STATUS " + _
            " from SAP_PRODUCT_STATUS a " + _
            " where a.PART_NO=@PN " + _
            " and a.SALES_ORG not in " + ConfigurationManager.AppSettings("InvalidOrg") + _
            " order by a.SALES_ORG, a.PRODUCT_STATUS "
        Dim apt As New SqlClient.SqlDataAdapter(strSql, conn)
        apt.SelectCommand.Parameters.AddWithValue("PN", Trim(PartNo))
        Dim dt As New DataTable("OhYes")
        apt.Fill(dt)
        conn.Close()
        Return dt
    End Function

    Public Enum ElearningUserType
        EZ
        CP
    End Enum

    Public Class ElearningUserProperties
        Public UserType As ElearningUserType
        Public RBU As String, AccountName As String, AccountErpId As String, AccountRowId As String
    End Class

    <WebMethod()> _
    Public Function IsElearningUserV2(ByVal UserEmail As String, ByRef UP As ElearningUserProperties) As Boolean
        If Util.IsValidEmailFormat(UserEmail) = False Then Return False
        UP = New ElearningUserProperties
        If Util.IsInternalUser(UserEmail) Then
            UP.UserType = ElearningUserType.EZ
            If MailUtil.IsInRole2("EMPLOYEE.AENC.USA", UserEmail) OrElse MailUtil.IsInRole2("EMPLOYEES.Irvine", UserEmail) Then
                UP.RBU = "AENC" : Return True
            ElseIf MailUtil.IsInRole2("AOnline.USA", UserEmail) Then
                UP.RBU = "ANADMF" : Return True
            ElseIf MailUtil.IsInRole2("EMPLOYEES.AAC.USA", UserEmail) Then
                UP.RBU = "AAC" : Return True
            Else
                Return False
            End If
        Else
            'Return False
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                " select top 1 b.RBU, b.account_name, b.row_id, b.ERP_ID from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID " + _
                " where a.EMAIL_ADDRESS='" + UserEmail + "' and b.RBU in ('AAC','AACIAG','AENC','ANADMF') " + _
                " and b.account_status in ('01-Platinum Channel Partner', '01-Premier Channel Partner', '02-Gold Channel Partner', '03-Certified Channel Partner')")
            If dt.Rows.Count = 1 Then
                With UP
                    .UserType = ElearningUserType.CP : .RBU = dt.Rows(0).Item("RBU") : .AccountName = dt.Rows(0).Item("account_name")
                    .AccountErpId = dt.Rows(0).Item("ERP_ID") : .AccountRowId = dt.Rows(0).Item("row_id")
                End With
                Return True
            End If
        End If
        Return False
    End Function

    <WebMethod()> _
    Public Function IsElearningUser(ByVal UserEmail As String, ByRef et As ElearningUserType, ByRef RBU As String) As Boolean
        If Util.IsValidEmailFormat(UserEmail) = False Then Return False
        If Util.IsInternalUser(UserEmail) Then
            et = ElearningUserType.EZ
            If MailUtil.IsInRole2("EMPLOYEE.AENC.USA", UserEmail) OrElse MailUtil.IsInRole2("EMPLOYEES.Irvine", UserEmail) Then
                RBU = "AENC" : Return True
            ElseIf MailUtil.IsInRole2("AOnline.USA", UserEmail) Then
                RBU = "ANADMF" : Return True
            ElseIf MailUtil.IsInRole2("EMPLOYEES.AAC.USA", UserEmail) Then
                RBU = "AAC" : Return True
            Else
                Return False
            End If
        Else
            Return False
        End If
        Return False
    End Function

    Public Sub New()
        Dim strRemoteAddr As String = HttpContext.Current.Request.ServerVariables("REMOTE_ADDR")
        If strRemoteAddr Like "172.*" = False And strRemoteAddr Like "127.*" = False AndAlso strRemoteAddr <> "::1" _
            AndAlso HttpContext.Current.User.Identity.IsAuthenticated = False Then
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.StatusCode = 401 : HttpContext.Current.Response.End()
        End If
    End Sub

    '20120608 - This WS is for Employee Zone Credit Application System only, requested by Jacky.Wu
    <WebMethod()> _
    Public Function GetSAPCustomerPartnerFunction(ByVal ERPID As String) As DataTable
        If String.IsNullOrEmpty(ERPID) Then Return Nothing
        Threading.Thread.Sleep(500)
        ERPID = Replace(Trim(ERPID), "'", "")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 30 b.company_id as company_id, b.COMPANY_NAME, b.ADDRESS, b.COUNTRY, b.CITY, " + _
                                      " b.ZIP_CODE, IsNull(b.REGION_CODE,' ') as [STATE], b.CONTACT_EMAIL, b.TEL_NO, b.FAX_NO, " + _
                                      " case a.PARTNER_FUNCTION when 'WE' then 'Ship-To' when 'AG' then 'Sold-To' when 'RE' then 'Bill-To' end as PARTNER_FUNCTION  "))
            .AppendLine(" from SAP_COMPANY_PARTNERS a inner join SAP_DIMCOMPANY b on a.PARENT_COMPANY_ID=b.COMPANY_ID  ")
            .AppendLine(String.Format(" WHERE b.COMPANY_ID='{0}' and a.PARTNER_FUNCTION in ('WE','AG','RE') ", ERPID))
            .AppendLine(String.Format(" order by b.company_id "))
        End With
        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        Dim dt As New DataTable("SAPPartnerFunction")
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function

    Public Enum ActivityStatus
        Approved
        Cancelled
        Done
        Draft
        In_Progress
        Not_Started
        On_Hold
        Scheduled
    End Enum

    <WebMethod()> _
    Public Function UpdateSiebelActivity(ByVal RowId As String, ByVal Description As String, ByVal Comment As String, ByVal Status As ActivityStatus, _
                                         ByVal OwnerEmail As String, ByRef ErrMsg As String) As Boolean
        If RowId = "" Then ErrMsg = "Row Id is mandatory." : Return False
        Try
            Dim ws As New eCoverageWS.WSSiebel, emp As New eCoverageWS.EMPLOYEE, actObj As New eCoverageWS.ACTION
            emp.USER_ID = ConfigurationManager.AppSettings("CRMHQId") : emp.PASSWORD = ConfigurationManager.AppSettings("CRMHQPwd")

            Dim empL As New eCoverageWS.EMPLOYEE, empCK As New eCoverageWS.EMPLOYEE
            empL.USER_ID = ConfigurationManager.AppSettings("CRMHQId") : empL.PASSWORD = ConfigurationManager.AppSettings("CRMHQPwd")
            empCK.EMAIL = OwnerEmail
            Dim _Res As eCoverageWS.RESULT = ws.CheckEmployee(empL, empCK)
            If _Res.IS_COMMITTED = False Then ErrMsg = "Owner Email: " + OwnerEmail + " is not in Siebel." : Return False

            With actObj
                .ROW_ID = RowId
                If Description <> "" Then .DESP = Description
                If Comment <> "" Then .CMT = Comment
                If Not IsNothing(Status) Then .STATUS = Status.ToString.Replace("_", " ")
                If OwnerEmail <> "" Then .OWNER_EMAIL = OwnerEmail
            End With
            Dim res As eCoverageWS.RESULT = ws.UpdAction(emp, actObj)
            If res.ERR_MSG IsNot Nothing AndAlso res.ERR_MSG <> "" Then
                ErrMsg = res.ERR_MSG : Return False
            End If
            Return True
        Catch ex As Exception
            ErrMsg = ex.ToString : Return False
        End Try
    End Function

    <WebMethod()> _
    Public Function GetSiebelActivityByRowId(ByVal RowId As String) As DataTable

        Dim _dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select a.NAME as DESCRIPTION, a.COMMENTS_LONG as COMMENT, a.EVT_STAT_CD as STATUS, " + _
                                                         " (select email_address from SIEBEL_CONTACT where ROW_ID=a.OWNER_PER_ID) as OWNER_EMAIL " + _
                                                         " from siebel_activity a where a.ROW_ID='{0}'", RowId))
        If _dt IsNot Nothing Then _dt.TableName = "SiebelActivityByRowId"
        Return _dt
    End Function

    <WebMethod()> _
    Public Sub SendECard()
        Exit Sub
        Dim dtRowId As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "select distinct row_id, subject from CHRISTMAS_SEND_LOG where is_sent=0 and is_schedule=1 and send_by='rudy.wang@advantech.com.tw'")
        For Each r As DataRow In dtRowId.Rows
            Dim row_id As String = r.Item("row_id").ToString
            Dim subject As String = r.Item("subject").ToString
            Dim bmp As Drawing.Bitmap = WebsiteThumbnail.GetThumbnail("http://my.advantech.com/EC/GenerateCardThumbnail.ashx?RowId=" + row_id, 820, 630, 820, 630)

            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select email from CHRISTMAS_SEND_LOG where row_id='{0}' and is_sent=0 and is_schedule=1", row_id))
            Dim SendOne As Boolean = True
            If dt.Rows.Count = 1 Then SendOne = False

            Dim SendTo As New ArrayList
            If Not SendOne Then
                Dim emails() As String = dt.Rows(0).Item(0).ToString.Split(",")
                For Each email As String In emails
                    If email.Trim <> "" Then SendTo.Add(email)
                Next
            Else
                For Each row As DataRow In dt.Rows
                    SendTo.Add(row.Item("email").ToString)
                Next
            End If

            If SendTo IsNot Nothing AndAlso SendTo.Count > 0 Then
                Dim RandomClass As New Random()
                Dim smtp() As String = {"ACLSMTPServer", "ACLSMTPServer2"}
                If SendOne Then
                    For Each email As String In SendTo
                        Dim RandomNumber As Integer = RandomClass.Next(2)
                        Dim ms As New System.IO.MemoryStream()
                        bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
                        ms.Position = 0
                        SendCard(ms, {email}, subject, smtp(RandomNumber))
                        ms.Dispose()
                        dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("update christmas_send_log set is_sent=1, smtp='{2}' where row_id='{0}' and email='{1}'", row_id, email, smtp(RandomNumber)))
                    Next
                Else
                    Dim RandomNumber As Integer = RandomClass.Next(2)
                    Dim ms As New System.IO.MemoryStream()
                    bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Png)
                    ms.Position = 0
                    SendCard(ms, SendTo.ToArray(GetType(String)), subject, smtp(RandomNumber))
                    ms.Dispose()
                    dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("update christmas_send_log set is_sent=1, smtp='{1}' where row_id='{0}'", row_id, smtp(RandomNumber)))
                End If
            End If
        Next
    End Sub

    Public Sub SendCard(ByVal ms As System.IO.MemoryStream, ByVal SendTo As String(), ByVal subject As String, ByVal smtp As String)
        Exit Sub
        Dim m1 As New System.Net.Mail.SmtpClient
        m1.Host = ConfigurationManager.AppSettings(smtp)
        'm1.Host = "172.21.34.21"
        Dim msg As New System.Net.Mail.MailMessage
        msg.From = New System.Net.Mail.MailAddress(Session("user_id"))
        Dim MailBody As String = "<table><tr><td width='830' height='630'><img src=cid:Img1></td></tr></table>"
        Dim av1 As System.Net.Mail.AlternateView = System.Net.Mail.AlternateView.CreateAlternateViewFromString(MailBody, System.Text.Encoding.UTF8, System.Net.Mime.MediaTypeNames.Text.Html)
        Dim ImgLinkSrc As New System.Net.Mail.LinkedResource(ms)
        ImgLinkSrc.ContentId = "Img1"
        ImgLinkSrc.ContentType.Name = "Christmas Card.png"
        av1.LinkedResources.Add(ImgLinkSrc)
        msg.AlternateViews.Add(av1)
        msg.IsBodyHtml = True
        msg.SubjectEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.BodyEncoding = System.Text.Encoding.GetEncoding("UTF-8")
        msg.Subject = subject
        For Each email As String In SendTo
            msg.To.Add(email)
        Next
        m1.Send(msg)

        For i As Integer = 0 To msg.AlternateViews.Count - 1
            For j As Integer = 0 To msg.AlternateViews.Item(i).LinkedResources.Count - 1
                msg.AlternateViews.Item(i).LinkedResources.Item(j).ContentStream.Close()
            Next
        Next
    End Sub

    'ICC 2016/6/28 Get company ID can see CLA items
    <WebMethod()>
    Public Function Get968TCompany(ByVal datetime As String) As Advantech.Myadvantech.DataAccess.CLAcompany
        Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.Get968TCompany(datetime)
    End Function

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub CheckEOLItems(ByVal _SONo As String, ByVal _ORGID As String)
        Dim my As MYSAPDAL = New MYSAPDAL
        Dim OrderDetail As DataTable = my.GetOrderDetailFromSAPByPoNo(_SONo)
        Dim EOLItems As List(Of String) = New List(Of String)

        For Each d As DataRow In OrderDetail.Rows
            Dim o As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 part_no from SAP_PRODUCT_STATUS_ORDERABLE where PART_NO = '{0}' and SALES_ORG = '{1}' ", Util.RemovePrecedingZeros(d("Partno").ToString), _ORGID))
            If o Is Nothing OrElse String.IsNullOrEmpty(o) Then
                EOLItems.Add(d("Partno").ToString)
            End If
        Next

        System.Web.HttpContext.Current.Response.Clear()
        System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(EOLItems))
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub CheckConfiguratorEOLItems(ByVal Root As String, ByVal ORGID As String)
        Try
            Dim EOLItems As List(Of String) = Advantech.Myadvantech.Business.PartBusinessLogic.GetConfiguratorEOLItems(Root, ORGID)
            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(EOLItems))
        Catch ex As Exception
            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New List(Of String)))
        End Try
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub CheckAEUCartGP(ByVal _CartID As String, ByVal _CompanyID As String)
        Dim result As AEUCartGPResult = New AEUCartGPResult
        result.Result = Advantech.Myadvantech.Business.GPControlBusinessLogic.AEUCartGPValidation(_CartID, _CompanyID, result.StandardMargin, result.PTDMargin)

        System.Web.HttpContext.Current.Response.Clear()
        System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(result))
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub IsACNCartNeedsApproval(ByVal _CartID As String, ByVal _Plant As String, ByVal _Org As String)
        If Not _Org.ToUpper.StartsWith("CN") Then
            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(False))
            Exit Sub
        End If

        If MyCartX.IsHaveBtos(_CartID) Then
            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(False))
            Exit Sub
        Else
            Dim result As Boolean = False
            Dim items As List(Of CartItem) = MyCartX.GetCartList(_CartID)

            For Each part As CartItem In items
                Dim o As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 part_no from SAP_PRODUCT_ABC where PART_NO = '{0}' and PLANT = '{1}' and ABC_INDICATOR in ('D','P','T')", part.Part_No, _Plant))
                If Not o Is Nothing AndAlso Not String.IsNullOrEmpty(o) Then
                    result = True
                    Exit For
                End If
            Next

            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(result))
        End If
    End Sub

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub IsACNLooseItemCartNegativeMargin(ByVal _CartID As String, ByVal _Org As String)
        If Not _Org.ToUpper.StartsWith("CN") Then
            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(False))
            Exit Sub
        End If

        If MyCartX.IsHaveBtos(_CartID) Then
            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(False))
            Exit Sub
        Else
            Dim Result As Boolean = False
            Dim TotalMargin As Decimal = 0
            Result = Advantech.Myadvantech.Business.GPControlBusinessLogic.ACNLooseItemCartGPValidation(_CartID, CType((1 + ConfigurationManager.AppSettings("ACNTaxRate")), Decimal), TotalMargin)

            System.Web.HttpContext.Current.Response.Clear()
            System.Web.HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(Result))
        End If
    End Sub

    Public Shared Function IsACNOrderNeedsApproval(ByVal _OrderID As String, ByVal _Plant As String, ByVal _Org As String) As Boolean
        If Not _Org.ToUpper.StartsWith("CN") Then
            Return False
        End If

        If MyOrderX.IsHaveBtos(_OrderID) Then
            Return False
        Else
            Dim result As Boolean = False
            Dim items As List(Of OrderItem) = MyOrderX.GetOrderListV2(_OrderID)

            For Each part As OrderItem In items
                Dim o As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 part_no from SAP_PRODUCT_ABC where PART_NO = '{0}' and PLANT = '{1}' and ABC_INDICATOR in ('D','P','T')", part.PART_NO, _Plant))
                If Not o Is Nothing AndAlso Not String.IsNullOrEmpty(o) Then
                    result = True
                    Exit For
                End If
            Next

            Return result
        End If
    End Function

    <Serializable()>
    Public Class AEUCartGPResult
        Public Result As Boolean
        Public StandardMargin As Decimal, PTDMargin As Decimal
    End Class
End Class
