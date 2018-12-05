Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
'<WebService(Namespace:="BBeStoreMyA")>
<WebService(Namespace:="http://tempuri.org/")>
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)>
Public Class USTaxService
    Inherits System.Web.Services.WebService
    Dim istesting As Boolean = False

    Class A053Record
        Public Property TXJCD As String : Public Property DATBI As String : Public Property DATAB As String : Public Property KNUMH As String
    End Class

    Class Zip_State_Tax
        Public Property ZIPCode As String : Public Property StateCode As String : Public Property TaxRate As Decimal
    End Class

    <WebMethod(EnableSession:=True)>
    Public Function getSalesTaxByZIP(ByVal pStrZIP5Digit As String, ByRef pDecSalesTax As Decimal) As Boolean
        '20171207 TC:Start to get tax from SAP
        pStrZIP5Digit = Trim(pStrZIP5Digit).Replace("'", "")
        If pStrZIP5Digit.Length <> 5 Then
            pDecSalesTax = 0 : Return False
        End If
        Dim pChar() As Char = pStrZIP5Digit.ToCharArray()
        For Each zc In pChar
            If Not IsNumeric(zc) Then
                pDecSalesTax = 0 : Return False
            End If
        Next

        Dim BBZipStateTaxCacheList As List(Of Zip_State_Tax) = HttpRuntime.Cache.Get("BBZipStateTax")
        If BBZipStateTaxCacheList Is Nothing OrElse TryCast(BBZipStateTaxCacheList, List(Of Zip_State_Tax)) Is Nothing Then
            BBZipStateTaxCacheList = New List(Of Zip_State_Tax)()
            HttpRuntime.Cache.Insert("BBZipStateTax", BBZipStateTaxCacheList, Nothing, Now.AddHours(12), TimeSpan.Zero)
        End If
        Dim queryTaxResult = From q In BBZipStateTaxCacheList Where q.ZIPCode.Equals(pStrZIP5Digit)
        If queryTaxResult.Count > 0 Then
            pDecSalesTax = queryTaxResult.First.TaxRate : Return True
        End If

        Dim ReadSAPTable As New Read_Sap_Table.Read_Sap_Table, SAPTableData As New Read_Sap_Table.TAB512Table
        Dim SAPTableFields As New Read_Sap_Table.RFC_DB_FLDTable, SAPTableQuery As New Read_Sap_Table.RFC_DB_OPTTable
        Dim SAPRFCconnection As String = "SAP_PRD"
        If istesting Then SAPRFCconnection = "SAPConnTest"
        Dim SAPDbconnection As String = "SAP_PRD"
        If istesting Then SAPDbconnection = "SAP_Test"
        With SAPTableFields
            .Add(New Read_Sap_Table.RFC_DB_FLD() With {.Fieldname = "TXJCD"}) : .Add(New Read_Sap_Table.RFC_DB_FLD() With {.Fieldname = "DATBI"})
            .Add(New Read_Sap_Table.RFC_DB_FLD() With {.Fieldname = "DATAB"}) : .Add(New Read_Sap_Table.RFC_DB_FLD() With {.Fieldname = "KNUMH"})
        End With
        SAPTableQuery.Add(New Read_Sap_Table.RFC_DB_OPT() With {.Text = "MANDT EQ '168' AND KAPPL EQ 'TX' AND ALAND EQ 'US' AND MWSKZ EQ 'S2'"})
        SAPTableQuery.Add(New Read_Sap_Table.RFC_DB_OPT() With {.Text = "AND KSCHL EQ 'JR2' AND TXJCD LIKE '%" + pStrZIP5Digit + "' AND DATBI EQ '99991231'"})
        ReadSAPTable.Connection = New SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings(SAPRFCconnection))
        ReadSAPTable.Connection.Open()
        ReadSAPTable.Rfc_Read_Table(";", "", "A053", 10, 0, SAPTableData, SAPTableFields, SAPTableQuery)
        ReadSAPTable.Connection.Close()
        Dim A053List As New List(Of A053Record)
        For Each SAPTableRec As Read_Sap_Table.TAB512 In SAPTableData
            Dim SapTableRecFields = SAPTableRec.Wa.Split(New String() {";"}, StringSplitOptions.None)
            Dim A053Record1 = New A053Record() With {.TXJCD = SapTableRecFields(0), .DATBI = SapTableRecFields(1), .DATAB = SapTableRecFields(2), .KNUMH = SapTableRecFields(3)}
            A053List.Add(A053Record1)
        Next
        If (A053List.Count > 0) Then
            A053List = A053List.OrderByDescending(Function(p) p.DATAB).ToList
            Dim dtTaxRate = OraDbUtil.dbGetDataTable(SAPDbconnection, ("select kbetr*0.001 as kbetr from saprdp.konp where knumh='" _
                            + (A053List(0).KNUMH + "'")))
            If (dtTaxRate.Rows.Count > 0) Then
                Dim StateCode As String = A053List(0).TXJCD.Substring(0, 2)
                pDecSalesTax = dtTaxRate.Rows(0).Item("kbetr")
                BBZipStateTaxCacheList.Add(New Zip_State_Tax() With {.StateCode = StateCode, .TaxRate = pDecSalesTax, .ZIPCode = pStrZIP5Digit})
                Return True
            End If
        End If
        pDecSalesTax = 0 : Return False
        '20171207 TC:Get SAP tax ends here, below are old codes from Eric.Shih


        'pStrZIP5Digit = pStrZIP5Digit.Trim()
        'If pStrZIP5Digit.Length > 5 Then
        '    pStrZIP5Digit = pStrZIP5Digit.Substring(0, 5)
        'End If
        'If pStrZIP5Digit = "" Or Not IsNumeric(pStrZIP5Digit) Or pStrZIP5Digit.Length < 5 Then
        '    Return False
        'End If



        'Dim queryString As String = "select Total_Sales_Tax from BB_TAX_ZIP_TAX where ZIP_CODE = '" & pStrZIP5Digit & "'"
        ''Dim oUtil As New AdvEBiz2.Commerence.EBIZ_UtilDB
        ''Dim dsTmp As System.Data.DataSet = New System.Data.DataSet
        ''oUtil.EbizGetDataSet(dsTmp, System.Configuration.ConfigurationManager.AppSettings("ConnectionString"), queryString)
        'Dim dtTmp = dbUtil.dbGetDataTable("MyLocal", queryString)

        'If True Then
        '    If dtTmp.Rows.Count > 0 Then
        '        pDecSalesTax = dtTmp.Rows(0)(0)

        '        'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
        '        '               "Page Entry", "WebService", "getSalesTaxByZIP:", pStrZIP5Digit & "^Success")
        '        Return True
        '    Else
        '        pDecSalesTax = 0
        '        'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
        '        '               "Page Entry", "WebService", "getSalesTaxByZIP:", pStrZIP5Digit & "^Fail")
        '        Return False
        '    End If
        'Else
        '    pDecSalesTax = 0
        '    'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
        '    '                   "Page Entry", "WebService", "getSalesTaxByZIP:", pStrZIP5Digit & "^Fail")
        '    Return False
        'End If

        'oUtil = Nothing


    End Function

    <WebMethod(EnableSession:=True)>
    Public Function getStateTaxInfo(ByVal pStrStateAbb2Digit As String, ByRef TAX_SHIPPING_ALONE As Boolean, ByRef Advan_Taxable As Boolean) As Boolean


        pStrStateAbb2Digit = pStrStateAbb2Digit.Trim()

        If pStrStateAbb2Digit = "" Or IsNumeric(pStrStateAbb2Digit) Or pStrStateAbb2Digit.Length <> 2 Then
            Return False
        End If

        Dim queryString As String = "select TAX_SHIPPING_ALONE, Advan_Taxable from BB_TAX_STATE_INFO where STATE_ABBREV = '" & pStrStateAbb2Digit & "'"
        'Dim oUtil As New AdvEbiz2.Commerence.EBIZ_UtilDB
        'Dim dsTmp As System.Data.DataSet = New System.Data.DataSet
        'oUtil.EbizGetDataSet(dsTmp, System.Configuration.ConfigurationManager.AppSettings("ConnectionString"), queryString)
        Dim dtTmp = dbUtil.dbGetDataTable("MyLocal", queryString)
        If True Then
            If dtTmp.Rows.Count > 0 Then


                TAX_SHIPPING_ALONE = IIf(dtTmp.Rows(0)(0) = "Y", True, False)
                Advan_Taxable = IIf(dtTmp.Rows(0)(1), True, False)
                'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
                '               "Page Entry", "WebService", "getStateTaxInfo:", pStrStateAbb2Digit & "^Success")
                Return True
            Else
                TAX_SHIPPING_ALONE = False
                Advan_Taxable = False
                'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
                '               "Page Entry", "WebService", "getStateTaxInfo:", pStrStateAbb2Digit & "^Fail")
                Return False
            End If
        Else
            TAX_SHIPPING_ALONE = False
            Advan_Taxable = False
            'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
            '                   "Page Entry", "WebService", "getStateTaxInfo:", pStrStateAbb2Digit & "^Fail")
            Return False
        End If

        'oUtil = Nothing

    End Function


    <WebMethod(EnableSession:=True)>
    Public Function getZIPInfo(ByVal pStrZIP5Digit As String, ByRef pStrStateAbb2Digit As String, ByRef pStrCountyName As String,
                                ByRef pStrCityName As String, ByRef TAX_SHIPPING_ALONE As Boolean, ByRef Advan_Taxable As Boolean) As Boolean
        '20171207 TC: Get Tax and State info from SAP directly
        pStrZIP5Digit = pStrZIP5Digit.Trim()
        If pStrZIP5Digit = "" Or Not IsNumeric(pStrZIP5Digit) Or pStrZIP5Digit.Length <> 5 Then
            Return False
        End If
        Dim decTaxRate As Decimal = -1
        If getSalesTaxByZIP(pStrZIP5Digit, decTaxRate) Then
            Dim BBZipStateTaxCacheList As List(Of Zip_State_Tax) = HttpRuntime.Cache.Get("BBZipStateTax")
            Dim QueryResult = From q In BBZipStateTaxCacheList Where q.ZIPCode.Equals(pStrZIP5Digit)
            If QueryResult.Count > 0 Then
                pStrStateAbb2Digit = QueryResult.First.StateCode
                Return True
            End If
        Else
            Return False
        End If
        '20171207 TC: End of gettting from SAP, below are old code from Mike/Eric

        Dim queryString As String = "select A.STATE_ABBREV , A.COUNTY_NAME , A.CITY_NAME , B.TAX_SHIPPING_ALONE, B.Advan_Taxable " &
                                "from BB_TAX_ZIP_TAX A " &
                                " inner join BB_TAX_STATE_INFO B on A.STATE_ABBREV = b.STATE_ABBREV " &
                                " where A.ZIP_CODE = '" & pStrZIP5Digit & "'"
        'Dim oUtil As New AdvEBiz2.Commerence.EBIZ_UtilDB
        'Dim dsTmp As System.Data.DataSet = New System.Data.DataSet
        'oUtil.EbizGetDataSet(dsTmp, System.Configuration.ConfigurationManager.AppSettings("ConnectionString"), queryString)
        Dim dtTmp = dbUtil.dbGetDataTable("MyLocal", queryString)
        If True Then
            If dtTmp.Rows.Count > 0 Then
                pStrStateAbb2Digit = dtTmp.Rows(0)(0)
                pStrCountyName = dtTmp.Rows(0)(1)
                pStrCityName = dtTmp.Rows(0)(2)
                TAX_SHIPPING_ALONE = IIf(dtTmp.Rows(0)(3) = "Y", True, False)
                Advan_Taxable = IIf(dtTmp.Rows(0)(4), True, False)
                'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
                '               "Page Entry", "WebService", "getZIPInfo:", pStrZIP5Digit & "^Success")
                Return True
            Else
                pStrStateAbb2Digit = ""
                pStrCountyName = ""
                pStrCityName = ""
                TAX_SHIPPING_ALONE = False
                Advan_Taxable = False
                'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
                '               "Page Entry", "WebService", "getZIPInfo:", pStrZIP5Digit & "^Fail")
                Return False
            End If
        Else
            pStrStateAbb2Digit = ""
            pStrCountyName = ""
            pStrCityName = ""
            TAX_SHIPPING_ALONE = False
            Advan_Taxable = False
            'oUtil.Log_Insert("PPS", "Application", "Page", "", Context.Request.UserHostAddress, "post",
            '                   "Page Entry", "WebService", "getZIPInfo:", pStrZIP5Digit & "^Fail")
            Return False
        End If

        'oUtil = Nothing


    End Function

    <Obsolete()>
    <WebMethod(EnableSession:=True)>
    Public Function getPFP(ByVal pParmList As String, ByVal pBolPoduction As Boolean, ByRef pResponse As String) As Boolean


        'Dim pfpro As New PayFlowPro.PFPro
        'Dim pCtlx As Integer

        'Dim ResponseOut As String
        'Dim User, Vendor, Partner, Password As String
        'Dim HostAddress As String
        'Dim HostPort, Timeout, ProxyPort As Integer
        'Dim ProxyAddress, ProxyLogon, ProxyPassword As String
        'Dim ParmList, UserAuth As String

        'User = "Advantech"
        'Vendor = "Advantech"
        'Partner = "verisign"
        ''Password			=  "1qa2ws3ed"
        'Password = "2ws3ed4rf"

        'HostPort = 443
        'Timeout = 30

        'ProxyPort = 0
        'ProxyAddress = ""
        'ProxyLogon = ""
        'ProxyPassword = ""

        'If pBolPoduction Then
        '    HostAddress = "payflow.verisign.com"
        'Else
        '    HostAddress = "test-payflow.verisign.com"
        '    'tmpTestString = "TEST Account; 123"
        'End If

        'UserAuth = "USER=" + User + "&VENDOR=" + Vendor +
        '    "&PARTNER=" + Partner + "&PWD=" + Password

        ''---------------------
        ''Get Parameters
        ''--------------------
        'Dim oEncry As New AdvEBiz2.Common.SymmEnCrypTool(AdvEBiz2.Common.SymmEnCrypTool.SymmProvEnum.DES)

        'Dim oKey As String = "XPara2lr"
        'ParmList = oEncry.Decrypting(pParmList, oKey)


        'ParmList = UserAuth + ParmList

        'Try
        '    pCtlx = pfpro.CreateContext(HostAddress, HostPort, Timeout,
        '      ProxyAddress, ProxyPort, ProxyLogon, ProxyPassword)

        '    ResponseOut = pfpro.SubmitTransaction(pCtlx, ParmList)

        '    pfpro.DestroyContext(pCtlx)

        '    pfpro = Nothing

        '    pResponse = oEncry.Encrypting(ResponseOut, oKey)

        '    getPFP = True

        'Catch ex As Exception
        '    pfpro = Nothing

        '    getPFP = False
        'End Try

    End Function

End Class
