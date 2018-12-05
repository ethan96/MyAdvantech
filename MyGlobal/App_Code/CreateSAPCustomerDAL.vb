Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports MYSAPDAL
Imports CreateSAPCustomer

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class CreateSAPCustomerDAL
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function HelloWorld() As String
        Return "Hello World"
    End Function
    <WebMethod()> _
    Public Function GetApplicationNO(ByVal AplicationID As Object) As String
        If AplicationID Is Nothing Then
            Dim SQL As String = String.Format(" select ISNULL(MAX(CONVERT(INT,REPLACE(APLICATIONNO,'TN',''))),0) as APLICATIONNO from SAPCUSTOMER_GENERALDATA  where APLICATIONNO is not null and APLICATIONNO <> '' and APLICATIONNO like 'TN%'", "")
            Dim NUM As Object = dbUtil.dbExecuteScalar("MYLOCAL", SQL)
            If NUM IsNot Nothing AndAlso IsNumeric(NUM) Then
                Return "TN" & (CDbl(NUM) + 1).ToString("00000")
            End If
        Else
            Dim SQL As String = String.Format("  SELECT TOP 1 APLICATIONNO FROM  SAPCUSTOMER_GENERALDATA WHERE APPLICATIONID='{0}' AND APLICATIONNO is not null and APLICATIONNO <> '' and APLICATIONNO like 'TN%' ", AplicationID.ToString.Trim)
            Dim DT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", SQL)
            If DT.Rows.Count > 0 AndAlso Not IsDBNull(DT.Rows(0).Item("APLICATIONNO")) Then
                Return DT.Rows(0).Item("APLICATIONNO")
            End If
        End If
        Return ""
    End Function
    Public Function SO_GetNumber(ByVal preFix As String) As String
       
        Return ""
    End Function
    <WebMethod()> _
    Public Function GetApplicationByApplicationIDForeStore(ByVal ApplicationID As String, ByRef ApplicationDt As CreateSAPCustomer.GetAllDataTable, ByRef ds As DataSet, ByRef errorStr As String) As Integer 'CreateSAPCustomer.GetAllDataTable
        Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
        'Dim dt As New CreateSAPCustomer.GetAllDataTable
        ApplicationDt = A.GetDataByApplicationID(ApplicationID)
        If ApplicationDt.Rows.Count > 0 Then
            Dim R As GetAllRow = ApplicationDt.Rows(0)
            If String.IsNullOrEmpty(R.COUNTRYCODE_X) Then
                R.BeginEdit()
                R.COUNTRYCODE_X = [Enum].GetName(GetType(EnumCountryCode), Integer.Parse(R.COUNTRYCODE)).Substring(5)
                R.EndEdit()
            End If
            If String.IsNullOrEmpty(R.SHIPTOCOUNTRY_X) Then
                R.BeginEdit()
                R.SHIPTOCOUNTRY_X = [Enum].GetName(GetType(EnumCountryCode), Integer.Parse(R.SHIPTOCOUNTRY)).Substring(5)
                R.EndEdit()
            End If
            If String.IsNullOrEmpty(R.BILLINGCOUNTRY_X) Then
                R.BeginEdit()
                R.BILLINGCOUNTRY_X = [Enum].GetName(GetType(EnumCountryCode), Integer.Parse(R.BILLINGCOUNTRY)).Substring(5)
                R.EndEdit()
            End If
            R.AcceptChanges()
            Dim SQL As String = String.Format("select top 1 companyid  from  SAPCUSTOMER_GENERALDATA where companyid <> '' and companyid is not null and APPLICATIONID='{0}'", ApplicationID)
            Dim companyid As Object = dbUtil.dbExecuteScalar("MYLOCAL", SQL)
            If companyid IsNot Nothing Then
                Try
                    Dim ConnectToSAPPRD As Boolean = True : If Util.IsTesting() Then ConnectToSAPPRD = False
                    Dim retb As Boolean = SAPDAL.SAPDAL.GetCustomerDataSet(companyid.ToString.ToUpper.Trim, ds, ConnectToSAPPRD)
                Catch ex As Exception
                    errorStr = ex.ToString
                End Try
            End If
            'dt.TableName = "MyMaster"
            'ds.Tables.Add(dt)
            Return 1
        End If
        Return 0
    End Function
    <WebMethod()> _
    Public Function CreateSAPCustomerForeStore(ByVal dT As GetAllDataTable, ByVal ApplicationID As String, ByVal IsCreate As Boolean, ByRef ErrorStr As String) As String
        Try
            Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
            Dim R As GetAllRow = dT.Rows(0)
            Dim objGeneralData As New CreateSAPCustomerDAL.SAPCustomerGeneralData, objCreditData As New CreateSAPCustomerDAL.SAPCustomerCreditData
            If R.COUNTRYCODE_X IsNot Nothing AndAlso Not String.IsNullOrEmpty(R.COUNTRYCODE_X) Then
                R.BeginEdit()
                R.COUNTRYCODE = FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.COUNTRYCODE_X).ToString.Trim
                R.EndEdit()
            End If
            If R.SHIPTOCOUNTRY_X IsNot Nothing AndAlso Not String.IsNullOrEmpty(R.SHIPTOCOUNTRY_X) Then
                R.BeginEdit()
                R.SHIPTOCOUNTRY = FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.SHIPTOCOUNTRY_X).ToString.Trim
                R.EndEdit()
            End If
            If R.BILLINGCOUNTRY_X IsNot Nothing AndAlso Not String.IsNullOrEmpty(R.BILLINGCOUNTRY_X) Then
                R.BeginEdit()
                R.BILLINGCOUNTRY = FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.BILLINGCOUNTRY_X).ToString.Trim
                R.EndEdit()
            End If
            R.AcceptChanges()
            With objGeneralData
                .HasCreditData = R.HASCREDITDATA
                .IsExist = CType(R.ISEXIST, Boolean)
                .HasShiptoData = CType(R.HASSHIPTODATA, Boolean)
                .HasBillingData = CType(R.HASBILLINGDATA, Boolean)
                .Address = R.ADDRESS : .City = R.CITY : .CompanyId = R.COMPANYID : .LegalForm = R.LEGALFORM.Replace("'", "''") : .CompanyName = R.COMPANYNAME
                .CompanyType = EnumCompanyType.Enum_Z001 : .ContactPersonEmail = R.CONTACTPERSONEMAIL : .ContactPersonName = R.CONTACTPERSONNAME
                ' .CountryCode = FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.COUNTRYCODE)
                .CountryCode = Integer.Parse(R.COUNTRYCODE) ' [Enum].GetName(GetType(EnumCountryCode), Integer.Parse(R.COUNTRYCODE)).Replace("Enum_", "")

                .CustomerClass = EnumCustomerClass.Enum_03
                .CustomerType = FindEnumValueByName(GetType(EnumCustomerType), "Enum_" + R.CUSTOMERTYPE)
                'lbDebugMsg.Text = "CustomerType:" + .CustomerType.ToString() + ",dlCustomerType.SelectedValue:" + dlCustomerType.SelectedValue
                .FaxNumber = R.FAXNUMBER
                .IncoTerm1 = FindEnumValueByName(GetType(EnumIncoTerm), "Enum_" + R.INCOTERM1)
                .IncoTerm2 = R.INCOTERM2 : .IndustryCode = EnumIndustryCode.Enum_3000
                .InsideSalesCode = R.INSIDESALESCODE
                .OrgId = EnumOrgId.Enum_EU10
                .PostCode = R.POSTCODE
                .RegionWestEast = EnumRegionWestEast.Enum_0000000001 : .SalesCode = R.SALESCODE
                .SalesGroup = R.SALESGROUP : .SalesOffice = R.SALESOFFICE
                .SearchTerm1 = R.VATNUMBER : .SearchTerm2 = R.COMPANYNAME
                .TelNumber = R.TELNUMBER : .VATNumber = R.VATNUMBER
                .VerticalMarket = R.VERTICALMARKET
                .CONTACTPERSON_FA = R.CONTACTPERSON_FA
                .TELEPHONE_FA = R.TELEPHONE_FA
                .EMAIL_FA = R.EMAIL_FA
                .APLICATIONNO = R.APLICATIONNO
                .WebSiteUrl = R.WEBSITEURL

                ' Ryan 20160606 Add new fields per Ruud's request
                .REGISTRATION_NUMBER = R.REGISTRATION_NUMBER
                .FORM = R.FORM
                .NEED_DIGITALINVOICE = R.NEED_DIGITALINVOICE
                .INVOICE_EMAIL = R.INVOICE_EMAIL
            End With

            With objCreditData
                .AccountingClerk = EnumAccountingClerk.Enum_EI
                .AmountInsured = Integer.Parse(R.AMOUNTINSURED)
                'If Double.TryParse(txtAmtInsured.Text, 0) Then .AmountInsured = CDbl(txtAmtInsured.Text)
                .CreditTerm = R.CREDITTERM ' FindEnumValueByName(GetType(EnumCreditTerm), "Enum_" + R.CREDITTERM)
                .Currency = FindEnumValueByName(GetType(EnumCurrency), "Enum_" + R.CURRENCY)
                .CustomerGroup = EnumCustomerGroup.Enum_02
                .InsurePolicyNumber = R.INSUREPOLICYNUMBER
                .PlanningGroup = EnumPlanningGroup.Enum_R1
                .RecAccount = GetReconciliationAccount(objGeneralData.SalesOffice) 'EnumReconciliationAccount.Enum_0000121005
                .SalesDistrict = GetSalesDistrictByCountry([Enum].Parse(GetType(EnumCountryCode), Integer.Parse(R.COUNTRYCODE))) 'EnumSalesDistrict.Enum_E06
                '.ShippingCondition = FindEnumValueByName(GetType(EnumShippingCondition), "Enum_" + R.SHIPPINGCONDITION)
                .ShippingCondition = R.SHIPPINGCONDITION
            End With

            'CreateSAPCustomer(objGeneralData, objCreditData)

            'Create ship-to'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
            Dim objShiptoGeneralData As New CreateSAPCustomerDAL.SAPCustomerGeneralData, objShiptoCreditData As New CreateSAPCustomerDAL.SAPCustomerCreditData
            If Boolean.Parse(R.HASSHIPTODATA) Then
                With objShiptoGeneralData
                    .HasCreditData = True
                    .Address = R.SHIPTOADDRESS : .City = R.SHIPTOCITY : .CompanyId = "" : .CompanyName = R.SHIPTOCOMPANYNAME
                    .CompanyType = EnumCompanyType.Enum_Z002 : .ContactPersonEmail = R.SHIPTOCONTACTEMAIL : .ContactPersonName = R.SHIPTOCONTACTNAME
                    .CountryCode = Integer.Parse(R.SHIPTOCOUNTRY) ' FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.SHIPTOCOUNTRY)
                    .CustomerClass = EnumCustomerClass.Enum_03
                    .CustomerType = FindEnumValueByName(GetType(EnumCustomerType), "Enum_" + R.CUSTOMERTYPE)
                    'lbDebugMsg.Text = "CustomerType:" + .CustomerType.ToString() + ",dlCustomerType.SelectedValue:" + dlCustomerType.SelectedValue
                    .FaxNumber = R.SHIPTOFAX
                    '.IncoTerm1 = FindEnumValueByName(GetType(EnumIncoTerm), "Enum_" + dlInco1.SelectedItem.Text)
                    '.IncoTerm2 = txtInco2.Text
                    .IndustryCode = EnumIndustryCode.Enum_3000
                    .OrgId = EnumOrgId.Enum_EU10
                    .PostCode = R.SHIPTOPOSTCODE
                    .RegionWestEast = EnumRegionWestEast.Enum_0000000001 '.SalesCode = ""
                    .SalesGroup = R.SALESGROUP : .SalesOffice = R.SALESOFFICE
                    .SearchTerm1 = R.SHIPTOVATNUMBER : .SearchTerm2 = R.SHIPTOCOMPANYNAME
                    .TelNumber = R.SHIPTOTEL : .VATNumber = R.SHIPTOVATNUMBER
                    '.VerticalMarket = FindEnumValueByName(GetType(EnumVerticalMarket), "Enum_" + dlVM.SelectedValue)
                    'If dlVM.SelectedIndex = 0 Then .VerticalMarket = EnumVerticalMarket.Enum_NONE
                    '.WebSiteUrl = txtWebsiteUrl.Text

                    ' .LegalForm = R.LEGALFORM.Replace("'", "''")
                    .IncoTerm1 = FindEnumValueByName(GetType(EnumIncoTerm), "Enum_" + R.INCOTERM1)
                    .IncoTerm2 = R.INCOTERM2
                    .InsideSalesCode = R.INSIDESALESCODE
                    .SalesCode = R.SALESCODE
                    ' .VerticalMarket = R.VERTICALMARKET
                End With
                With objShiptoCreditData
                    .AccountingClerk = EnumAccountingClerk.Enum_EI
                    .AmountInsured = 0

                    ' If Double.TryParse(txtAmtInsured.Text, 0) Then .AmountInsured = CDbl(txtAmtInsured.Text)
                    .AmountInsured = CDbl(R.AMOUNTINSURED)
                    .CreditTerm = R.CREDITTERM 'FindEnumValueByName(GetType(EnumCreditTerm), "Enum_" + R.CREDITTERM)
                    .Currency = FindEnumValueByName(GetType(EnumCurrency), "Enum_" + R.CURRENCY)
                    .CustomerGroup = EnumCustomerGroup.Enum_02
                    .InsurePolicyNumber = ""
                    .PlanningGroup = EnumPlanningGroup.Enum_R1
                    .RecAccount = GetReconciliationAccount(objGeneralData.SalesOffice) 'EnumReconciliationAccount.Enum_0000121005
                    .SalesDistrict = GetSalesDistrictByCountry([Enum].Parse(GetType(EnumCountryCode), Integer.Parse(R.SHIPTOCOUNTRY)))
                    'GetSalesDistrictByCountry(Integer.Parse(R.SHIPTOCOUNTRY))
                    'GetSalesDistrictByCountry(FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.SHIPTOCOUNTRY)) 'EnumSalesDistrict.Enum_E06
                    '.ShippingCondition = FindEnumValueByName(GetType(EnumShippingCondition), "Enum_" + R.SHIPPINGCONDITION)
                    .ShippingCondition = R.SHIPPINGCONDITION
                End With
                'CreateSAPCustomer(objShiptoGeneralData, objShiptoCreditData)
            End If
            'end ship-to'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
            'Create Billing '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
            Dim objBillingGeneralData As New CreateSAPCustomerDAL.SAPCustomerGeneralData, objBillingCreditData As New CreateSAPCustomerDAL.SAPCustomerCreditData
            If Boolean.Parse(R.HASBILLINGDATA) Then
                With objBillingGeneralData
                    .HasCreditData = True
                    .Address = R.BILLINGADDRESS : .City = R.BILLINGCITY : .CompanyId = "" : .CompanyName = R.BILLINGCOMPANYNAME
                    .CompanyType = EnumCompanyType.Enum_Z003 : .ContactPersonEmail = R.BILLINGCONTACTEMAIL : .ContactPersonName = R.BILLINGCONTACTNAME
                    .CountryCode = Integer.Parse(R.BILLINGCOUNTRY) ' FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.BILLINGCOUNTRY)
                    .CustomerClass = EnumCustomerClass.Enum_03
                    .CustomerType = FindEnumValueByName(GetType(EnumCustomerType), "Enum_" + R.CUSTOMERTYPE)
                    .FaxNumber = R.BILLINGFAX
                    .IndustryCode = EnumIndustryCode.Enum_3000
                    .OrgId = EnumOrgId.Enum_EU10
                    .PostCode = R.BILLINGPOSTCODE
                    .RegionWestEast = EnumRegionWestEast.Enum_0000000001 : .SalesCode = ""
                    .SalesGroup = R.SALESGROUP : .SalesOffice = R.SALESOFFICE
                    .SearchTerm1 = R.BILLINGVATNUMBER : .SearchTerm2 = R.BILLINGCOMPANYNAME
                    .TelNumber = R.BILLINGTEL : .VATNumber = R.BILLINGVATNUMBER
                End With
                With objBillingCreditData
                    .AccountingClerk = EnumAccountingClerk.Enum_EI
                    .AmountInsured = CDbl(R.AMOUNTINSURED)
                    ' If Double.TryParse(txtAmtInsured.Text, 0) Then .AmountInsured = CDbl(txtAmtInsured.Text)
                    .CreditTerm = R.CREDITTERM ' FindEnumValueByName(GetType(EnumCreditTerm), "Enum_" + R.CREDITTERM)
                    .Currency = FindEnumValueByName(GetType(EnumCurrency), "Enum_" + R.CURRENCY)
                    .CustomerGroup = EnumCustomerGroup.Enum_02
                    .InsurePolicyNumber = ""
                    .PlanningGroup = EnumPlanningGroup.Enum_R1
                    .RecAccount = GetReconciliationAccount(objGeneralData.SalesOffice) 'EnumReconciliationAccount.Enum_0000121005
                    .SalesDistrict = GetSalesDistrictByCountry([Enum].Parse(GetType(EnumCountryCode), Integer.Parse(R.BILLINGCOUNTRY)))
                    'GetSalesDistrictByCountry(Integer.Parse(R.BILLINGCOUNTRY))
                    'GetSalesDistrictByCountry(FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.BILLINGCOUNTRY)) 'EnumSalesDistrict.Enum_E06
                    '.ShippingCondition = FindEnumValueByName(GetType(EnumShippingCondition), "Enum_" + R.SHIPPINGCONDITION)
                    .ShippingCondition = R.SHIPPINGCONDITION
                End With
                'CreateSAPCustomer(objBillingGeneralData, objBillingCreditData)
            End If
            'end Billing '''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
            If Not String.IsNullOrEmpty(ApplicationID) Then
                Dim deletesql As New StringBuilder
                deletesql.AppendFormat("delete from SAPCUSTOMER_CREDITDATA where APPLICATIONID='{0}';", ApplicationID)
                deletesql.AppendFormat("delete from SAPCUSTOMER_GENERALDATA where APPLICATIONID='{0}';", ApplicationID)
                deletesql.AppendFormat("update SAPCUSTOMER_APPLICATION set  STATUS =0 where  row_id='{0}';", ApplicationID)
                dbUtil.dbExecuteNoQuery("MYLOCAL", deletesql.ToString())
            Else
                ApplicationID = Util.NewRowId("SAPCUSTOMER_APPLICATION", "MYLOCAL")
                A.InsertSAPCustomerApplication(ApplicationID, 0, R.REQUEST_BY, Date.Now(), "", _
                                               "", Nothing, "", Nothing, R.LAST_UPD_BY, Date.Now())
            End If


            A.InsertSAPCustomerGeneralData(Guid.NewGuid().ToString(), ApplicationID, objGeneralData.IsExist, objGeneralData.CompanyId, objGeneralData.CompanyName, _
                                            objGeneralData.LegalForm, objGeneralData.Address, objGeneralData.City, objGeneralData.PostCode, objGeneralData.SearchTerm1, _
                                            objGeneralData.SearchTerm2, objGeneralData.VATNumber, objGeneralData.TelNumber, _
                                            objGeneralData.FaxNumber, objGeneralData.OrgId, objGeneralData.CountryCode, _
                                            objGeneralData.CustomerClass, objGeneralData.IndustryCode, objGeneralData.CompanyType, _
                                            objGeneralData.RegionWestEast, objGeneralData.CustomerType, objGeneralData.CondGrp1, _
                                            objGeneralData.CondGrp2, objGeneralData.CondGrp3, objGeneralData.CondGrp4, objGeneralData.CondGrp5, _
                                            objGeneralData.Attribute1, objGeneralData.Attribute2, objGeneralData.Attribute3, objGeneralData.Attribute4, _
                                            objGeneralData.Attribute5, objGeneralData.Attribute6, objGeneralData.Attribute8, objGeneralData.Attribute10, _
                                            objGeneralData.WebSiteUrl, objGeneralData.ContactPersonName, objGeneralData.ContactPersonEmail, _
                                            objGeneralData.IncoTerm1, objGeneralData.IncoTerm2, objGeneralData.SalesGroup, _
                                            objGeneralData.SalesOffice, objGeneralData.SalesCode, objGeneralData.InsideSalesCode, _
                                            objGeneralData.VerticalMarket, IIf(IsNothing(R.OPCODE), "", R.OPCODE), objGeneralData.HasCreditData, _
                                            objGeneralData.HasShiptoData, objGeneralData.HasBillingData, _
                                            objShiptoGeneralData.CompanyName, objShiptoGeneralData.VATNumber, _
                                            objShiptoGeneralData.Address, objShiptoGeneralData.PostCode, objShiptoGeneralData.City, _
                                            objShiptoGeneralData.CountryCode, objShiptoGeneralData.TelNumber, objShiptoGeneralData.FaxNumber, _
                                            objShiptoGeneralData.ContactPersonName, objShiptoGeneralData.ContactPersonEmail, _
                                            objBillingGeneralData.CompanyName, objBillingGeneralData.VATNumber, _
                                            objBillingGeneralData.Address, objBillingGeneralData.PostCode, objBillingGeneralData.City, _
                                            objBillingGeneralData.CountryCode, objBillingGeneralData.TelNumber, objBillingGeneralData.FaxNumber, _
                                            objBillingGeneralData.ContactPersonName, objBillingGeneralData.ContactPersonEmail, objGeneralData.CONTACTPERSON_FA, objGeneralData.TELEPHONE_FA, objGeneralData.EMAIL_FA, objGeneralData.APLICATIONNO,
                                            objGeneralData.REGISTRATION_NUMBER, objGeneralData.FORM, objGeneralData.NEED_DIGITALINVOICE, objGeneralData.INVOICE_EMAIL)
            A.InsertSAPCustomerCreditData(Guid.NewGuid().ToString(), ApplicationID, objCreditData.CreditTerm, objCreditData.Currency, _
                                          objCreditData.CustomerGroup, objCreditData.SalesDistrict, objCreditData.RecAccount, objCreditData.AmountInsured, _
                                          objCreditData.InsurePolicyNumber, objCreditData.AccountingClerk, objCreditData.PlanningGroup, _
                                          objCreditData.ShippingCondition)
            If Not IsCreate Then
                'SendEmail(ApplicationID, 0)
                'Util.AjaxJSAlert(Me.up1, "Your data is being processed, thank you.")
                'Util.AjaxJSAlertRedirect(Me.up1, "Your data is being processed, thank you.", Request.Url.ToString())
                'Return objGeneralData.APLICATIONNO
                Return ApplicationID
                Exit Function
            End If
            If Boolean.Parse(objGeneralData.IsExist) = False AndAlso Not IsERPIDExist(objGeneralData.CompanyId) Then
                CreateSAPCustomerDAL.CreateSAPCustomer(objGeneralData, objCreditData)
                Dim strErr As String = String.Empty, ConnectToSAPPRD As Boolean = True
                If Util.IsTesting() Then ConnectToSAPPRD = False
                Dim Creditrep_group As String = "330"
                Select Case R.SALESOFFICE
                    Case "3000"
                        Creditrep_group = "320"
                    Case "3100"
                        Creditrep_group = "310"
                    Case "3900"
                        Creditrep_group = "390"
                    Case "3200"
                        Creditrep_group = "330"
                    Case "3300"
                        Creditrep_group = "340"
                    Case "3400"
                        Creditrep_group = "350"
                    Case "3600"
                        Creditrep_group = "360"
                    Case "3700"
                        Creditrep_group = "370"
                    Case Else
                        Creditrep_group = "330"
                End Select
                MYSAPDAL.UpdateCustomerCreditLimit(objGeneralData.CompanyId, "EU01", 0.01, "200", Creditrep_group, strErr, ConnectToSAPPRD)
                'create siebel account
                Dim SiebelRowid As String = String.Empty
                Dim B As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_APPLICATION_ExtendTableAdapter
                Dim dt2 As DataTable = B.selectbyApplicationID(ApplicationID)
                If dt2.Rows.Count > 0 Then
                    SiebelRowid = dt2.Rows(0).Item("SIEBELROWID").ToString().Trim
                End If
                If String.IsNullOrEmpty(SiebelRowid) Then
                    'Dim acc As New eCoverageWS.ACCOUNT, 
                    Dim acc As New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.ACC()
                    Dim strOwnerPriPositionName As String = String.Empty, strRBU As String = String.Empty
                    '20180306 TC: If can't get Siebel position by SAP sales code, use System Use - MyAdvantech as the default position 
                    If Not Util.GetPositionNameBySalesCode(objGeneralData.SalesCode, strOwnerPriPositionName) Then
                        strOwnerPriPositionName = "System Use - MyAdvantech"
                    End If
                    If Not Util.GetRBUBySalesCode(objGeneralData.SalesCode, strRBU) Then
                        'Ming add 20150417
                        ' 1）RBU如果sales关联不到，就根据挑选的country去找RBU
                        ' 2）如果找不到assign owner，将MyAdvantech带进去.
                        Try
                            Dim RBUobj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select  top 1 isnull(RBU,'') as RBU  from  [CurationPool].[dbo].[COUNTRY_RBU_MAPPING] where COUNTRY  =( select top 1 isnull(country_name,'') as  country_name  from SAP_DIMCOMPANY  WHERE  country_name IS NOT NULL and country_name <> '' and COUNTRY='{0}'  )", [Enum].GetName(GetType(EnumCountryCode), Int32.Parse(objGeneralData.CountryCode)).Substring(5)))
                            If RBUobj IsNot Nothing AndAlso Not String.IsNullOrEmpty(RBUobj.ToString) Then
                                strRBU = RBUobj.ToString.Trim
                            End If
                        Catch ex As Exception
                            Util.SendEmail("ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "sales关联不到RBU，就根据挑选的country去找RBU:", ex.ToString(), True, "", "")
                        End Try
                    End If
                    'Ming 20150505处理特殊情况 Is it possible that when eRMA is selected, Account should be owned by MICHALS instead of MYADVANTECH
                    If objGeneralData.SalesCode = "39050010" AndAlso String.Equals(strOwnerPriPositionName, "MyAdvantech", StringComparison.InvariantCultureIgnoreCase) Then
                        strOwnerPriPositionName = "MICHALS"
                    End If
                    With acc
                        .NAME = objGeneralData.CompanyName : .SITE = "" : .STATUS = "07-General Account"
                        .CURRENCY = "EUR" : .DESC = "" : .ERPID = objGeneralData.CompanyId
                        .URL = objGeneralData.WebSiteUrl : .MAIN_FAX = objGeneralData.FaxNumber
                        .MAIN_PHONE = objGeneralData.TelNumber : .IS_PARTNER = False
                        .TYPE = ""

                        Dim objAddress As New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.ADDR()
                        objAddress.CITY = objGeneralData.City : objAddress.LINE1 = objGeneralData.Address.Replace("|", " ")
                        objAddress.COUNTRY = dbUtil.dbExecuteScalar("MY", String.Format("select TOP 1 isnull(country_name,'') as  country_name  from SAP_DIMCOMPANY where COUNTRY ='{0}' ", [Enum].GetName(GetType(EnumCountryCode), Int32.Parse(objGeneralData.CountryCode)).Substring(5)))
                        objAddress.ZIP = objGeneralData.PostCode : objAddress.STATE = ""
                        .ADDR = New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.ADDR() {objAddress}

                        Dim objPosition As New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.POSITION()
                        objPosition.NAME = strOwnerPriPositionName
                        .POSITION = New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.POSITION() {objPosition}

                        Dim objBAA As New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.BAA()
                        objBAA.NAME = ""
                        .BAA = New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.BAA() {objBAA}

                        Dim objOrg As New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.ORG()
                        objOrg.NAME = strRBU
                        .ORG = New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.ORG() {objOrg}

                        'Dim objIndustry As New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.INDUSTRY()
                        'objIndustry.CODE = String.Empty
                        'objIndustry.IS_PRIMARY = String.Empty
                        'objIndustry.NAME = String.Empty
                        '.INDUSTRY = New Advantech.Myadvantech.DataAccess.WSSiebel_AddAccount.INDUSTRY() {objIndustry}

                    End With
                    Dim strAccountId As String = Advantech.Myadvantech.DataAccess.SiebelDAL.CreateAccount2(acc)
                    If Not String.IsNullOrEmpty(strAccountId) Then
                        SiebelRowid = strAccountId
                        Dim ASB As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_APPLICATION_ExtendTableAdapter
                        ASB.DeleteApplicationID(ApplicationID)
                        ASB.Insert(ApplicationID, strAccountId, "", "")
                    End If

                Else
                    'ICC 2016/5/27 Already has Siebel Row ID, update Siebel account ERP ID and sync to MyAdvantech
                    Dim result As String = Advantech.Myadvantech.DataAccess.SiebelDAL.UpdateAccountErpID(SiebelRowid, objGeneralData.CompanyId)
                    If Not String.IsNullOrEmpty(result) Then
                        Try
                            System.Threading.Thread.Sleep(4000)
                            MYSIEBELDAL.SyncAccountFromSiebel2MyAdvantech(SiebelRowid)
                        Catch ex As Exception
                            Call MailUtil.Utility_EMailPage("MyAdvantech@advantech.com", "Frank.Chung@advantech.com.tw,IC.Chen@advantech.com.tw,YL.Huang@advantech.com.tw", "", "", "SyncAccountFromSiebel2MyAdvantech failed", "", SiebelRowid + vbTab + Now.ToLongTimeString)
                        End Try
                    End If
                End If
                'If Not String.IsNullOrEmpty(SiebelRowid) Then
                '    Try
                '        System.Threading.Thread.Sleep(4000)
                '        MYSIEBELDAL.SyncAccountFromSiebel2MyAdvantech(SiebelRowid)
                '    Catch ex As Exception
                '        Call MailUtil.Utility_EMailPage("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn", "", "", "SyncAccountFromSiebel2MyAdvantech", "", SiebelRowid + vbTab + Now.ToLongTimeString)
                '    End Try
                'End If
                'end
            End If
            Dim tempShiptoErpid As String = String.Empty
            Dim tempBilltoErpid As String = String.Empty
            Dim retInt As Integer = NewCompanyId(objGeneralData.CompanyId, tempShiptoErpid, tempBilltoErpid)
            If Boolean.Parse(R.HASSHIPTODATA) Then
                If Not String.IsNullOrEmpty(tempShiptoErpid) Then
                    objShiptoGeneralData.CompanyId = tempShiptoErpid
                    CreateSAPCustomerDAL.CreateSAPCustomer(objShiptoGeneralData, objShiptoCreditData)
                    A.UpdateErpID(tempBilltoErpid, tempShiptoErpid, ApplicationID)
                End If
            End If
            If Boolean.Parse(R.HASBILLINGDATA) Then
                If Not String.IsNullOrEmpty(tempBilltoErpid) Then
                    objBillingGeneralData.CompanyId = tempBilltoErpid
                    CreateSAPCustomerDAL.CreateSAPCustomer(objBillingGeneralData, objBillingCreditData)
                    A.UpdateErpID(tempBilltoErpid, tempShiptoErpid, ApplicationID)
                End If
            End If
            'Create sales/op/is code in knvp table, and ship-to if specified              
            Dim knvpTable As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVPTable
            Dim salesRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
            Dim opRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
            Dim isRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
            Dim ShipToRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
            Dim BillingRow As New ZCUSTOMER_UPDATE_SALES_AREA.FKNVP
            Dim CompanyId As String = objGeneralData.CompanyId, OrgId As String = "EU10"
            With salesRow
                .Defpa = "" : .Knref = "" : .Kunn2 = "" : .Kunnr = CompanyId
                .Lifnr = "" : .Mandt = "168" : .Parnr = "0000000000" : .Parvw = "VE" : .Parza = "000"
                .Pernr = R.SALESCODE : .Spart = "00" : .Vkorg = OrgId : .Vtweg = "00" : .Kz = "I"
            End With

            With isRow
                .Defpa = "" : .Knref = "" : .Kunn2 = "" : .Kunnr = CompanyId
                .Lifnr = "" : .Mandt = "168" : .Parnr = "0000000000" : .Parvw = "Z2" : .Parza = "001"
                .Pernr = R.INSIDESALESCODE : .Spart = "00" : .Vkorg = OrgId : .Vtweg = "00" : .Kz = "I"
            End With

            With opRow
                .Defpa = "" : .Knref = "" : .Kunn2 = "" : .Kunnr = CompanyId
                .Lifnr = "" : .Mandt = "168" : .Parnr = "0000000000" : .Parvw = "ZM" : .Parza = "000"
                .Pernr = R.OPCODE : .Spart = "00" : .Vkorg = OrgId : .Vtweg = "00" : .Kz = "I"
            End With
            If Boolean.Parse(objGeneralData.IsExist) = False AndAlso IsERPIDExist(objGeneralData.CompanyId) Then
                If Not checkknvp(objGeneralData.CompanyId, "VE") Then
                    knvpTable.Add(salesRow)
                End If
                If Not checkknvp(objGeneralData.CompanyId, "Z2") Then
                    knvpTable.Add(isRow)
                End If
                If Not checkknvp(objGeneralData.CompanyId, "ZM") Then
                    knvpTable.Add(opRow)
                End If
            End If
            With ShipToRow
                .Defpa = "" : .Knref = ""
                .Kunn2 = objShiptoGeneralData.CompanyId : .Kunnr = CompanyId
                .Lifnr = "" : .Mandt = "168" : .Parnr = "0000000000" : .Parvw = "WE"
                .Parza = New_knvp_Parza(CompanyId, "WE") : .Pernr = "00000000" : .Spart = "00" : .Vkorg = OrgId : .Vtweg = "00" : .Kz = "I"
            End With
            With BillingRow
                .Defpa = "" : .Knref = ""
                .Kunn2 = objBillingGeneralData.CompanyId : .Kunnr = CompanyId
                .Lifnr = "" : .Mandt = "168" : .Parnr = "0000000000" : .Parvw = "RE"
                .Parza = New_knvp_Parza(CompanyId, "RE") : .Pernr = "00000000" : .Spart = "00" : .Vkorg = OrgId : .Vtweg = "00" : .Kz = "I"
            End With
            If Boolean.Parse(R.HASSHIPTODATA) Then knvpTable.Add(ShipToRow)
            If Boolean.Parse(R.HASBILLINGDATA) Then knvpTable.Add(BillingRow)
            If knvpTable.Count > 0 Then
                'System.Threading.Thread.Sleep(15000)
                For i As Integer = 0 To 3
                    If checkSAPErp(objGeneralData.CompanyId.Trim) Then
                        Exit For
                    End If
                    If i = 3 Then
                        Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Find SAP Erp Failed:", "", True, "", "")
                        Exit For
                    End If
                    Threading.Thread.Sleep(1000)
                Next
                Dim p1 As New ZCUSTOMER_UPDATE_SALES_AREA.ZCUSTOMER_UPDATE_SALES_AREA
                Dim SAPconnection2 As String = "SAP_PRD"
                If Util.IsTesting() Then
                    SAPconnection2 = "SAPConnTest"
                End If
                p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection2))
                p1.Connection.Open()
                p1.Zcustomer_Update_Sales_Area( _
                    New ZCUSTOMER_UPDATE_SALES_AREA.FKNVDTable, knvpTable, New ZCUSTOMER_UPDATE_SALES_AREA.KNVVTable, _
                    New ZCUSTOMER_UPDATE_SALES_AREA.FKNVDTable, New ZCUSTOMER_UPDATE_SALES_AREA.FKNVPTable)
                p1.CommitWork() : p1.Connection.Close()
            End If
            'lbDoneMsg.Text = txtCompanyId.Text + " has been created" : lbERPIDMsg.Text = ""
            Return ApplicationID 'objGeneralData.APLICATIONNO
            'End With
        Catch ex As Exception
            ErrorStr = ex.ToString()
            Util.SendEmail("YL.Huang@advantech.com.tw", "myadvanteh@advantech.com", "Zcustomer_Update_Sales_Area Failed:", ErrorStr, True, "", "")
            Return ""
        End Try
        Return ""
    End Function
    Public Shared Function GetApplicationStatus(ByVal ApplicationID As String) As String
        ApplicationID = Trim(ApplicationID.ToString)
        Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
        Dim dt As New CreateSAPCustomer.GetAllDataTable
        dt = A.GetDataByApplicationID(ApplicationID)
        If dt.Rows.Count > 0 Then
            Dim dr As CreateSAPCustomer.GetAllRow = dt.Rows(0)
            With dr
                If Not IsDBNull(dr.STATUS) Then
                    Return dr.STATUS.ToString.Trim
                End If
            End With
        End If
        Return ""
    End Function

    Public Shared Function GetReconciliationAccount(ByVal officecode As String) As EnumReconciliationAccount
        Dim RA As EnumReconciliationAccount = Nothing
        Select Case officecode.Trim
            Case "3100", "3900"
                RA = EnumReconciliationAccount.Enum_0000121006
            Case "3000"
                RA = EnumReconciliationAccount.Enum_0000121005
            Case "3200"
                RA = EnumReconciliationAccount.Enum_0000121007
            Case "3300"
                RA = EnumReconciliationAccount.Enum_0000121008
            Case "3400"
                RA = EnumReconciliationAccount.Enum_0000121009
            Case "3600", "3700"
                RA = EnumReconciliationAccount.Enum_0000121002
            Case Else
                RA = EnumReconciliationAccount.Enum_0000121006
        End Select
        Return RA
    End Function
    Public Shared Function New_knvp_Parza(ByVal CompanyId As String, ByVal Flag As String) As String
        Dim tmpParza As String = "001"
        Dim SAPconnection As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnection = "SAP_Test"
        End If
        Do While True
            Dim knvp_dt As DataTable = OraDbUtil.dbGetDataTable(SAPconnection, "select Kunnr from saprdp.knvp  where Kunnr ='" + CompanyId + "' and Parza ='" + tmpParza + "' and PARVW ='" + Flag + "' ")
            If knvp_dt.Rows.Count = 0 Then
                Exit Do
            Else
                tmpParza = String.Format("{0:000}", Integer.Parse(tmpParza) + 1)
            End If
        Loop
        Return tmpParza
    End Function
    Public Shared Function checkknvp(ByVal CompanyID As String, ByVal Flag As String) As Boolean
        Dim knvp_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select Kunnr from saprdp.knvp  where Kunnr ='" + CompanyID + "' and PARVW ='" + Flag + "' ")
        If knvp_dt.Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function GetSalesDistrictByCountry(ByVal CountryCode As EnumCountryCode) As EnumSalesDistrict
        Select Case CountryCode
            Case EnumCountryCode.Enum_NO, EnumCountryCode.Enum_SE, EnumCountryCode.Enum_FI, EnumCountryCode.Enum_DK, EnumCountryCode.Enum_IS
                Return EnumSalesDistrict.Enum_E01
            Case EnumCountryCode.Enum_GB, EnumCountryCode.Enum_IE
                Return EnumSalesDistrict.Enum_E02
            Case EnumCountryCode.Enum_AT, EnumCountryCode.Enum_DE, EnumCountryCode.Enum_CH
                Return EnumSalesDistrict.Enum_E03
            Case EnumCountryCode.Enum_FR, EnumCountryCode.Enum_ES, EnumCountryCode.Enum_PT
                Return EnumSalesDistrict.Enum_E04
            Case EnumCountryCode.Enum_IT
                Return EnumSalesDistrict.Enum_E05
            Case EnumCountryCode.Enum_BE, EnumCountryCode.Enum_LU, EnumCountryCode.Enum_NL
                Return EnumSalesDistrict.Enum_E06
            Case EnumCountryCode.Enum_AL, EnumCountryCode.Enum_BA, EnumCountryCode.Enum_BG, EnumCountryCode.Enum_BY, EnumCountryCode.Enum_CZ, EnumCountryCode.Enum_EE, _
                EnumCountryCode.Enum_HU, EnumCountryCode.Enum_LV, EnumCountryCode.Enum_LT, EnumCountryCode.Enum_MD, EnumCountryCode.Enum_PL, EnumCountryCode.Enum_RO, _
                EnumCountryCode.Enum_MK, EnumCountryCode.Enum_ME, EnumCountryCode.Enum_SK, EnumCountryCode.Enum_SI, EnumCountryCode.Enum_HR, EnumCountryCode.Enum_RS, _
                EnumCountryCode.Enum_UA
                Return EnumSalesDistrict.Enum_E07
            Case EnumCountryCode.Enum_GR
                Return EnumSalesDistrict.Enum_E08
            Case EnumCountryCode.Enum_RU
                Return EnumSalesDistrict.Enum_E09
            Case Else
                Return EnumSalesDistrict.Enum_E10
        End Select
    End Function
    Public Shared Function GetCustomerAcctAssgmtGroupAndTaxClassification(ByVal countrycode As String, ByRef AAG As String, ByRef TC As String)
        Dim strCountrys As String = "AT,BE,BG,CY,CZ,DE,DK,EE,GR,ES,FI,FR,GB,HR,HU,IE,IT,LT,LU,LV,MT,PL,PT,RO,SE,SI,SK"
        If strCountrys.Contains(countrycode.ToUpper.Trim) Then
            AAG = "02" : TC = "8"
        ElseIf String.Equals(countrycode, "NL", StringComparison.CurrentCultureIgnoreCase) Then
            AAG = "01" : TC = "7"
        Else
            AAG = "02" : TC = "9"
        End If
    End Function
    Public Shared Function CreateSAPCustomer(ByVal GeneralData As SAPCustomerGeneralData, ByVal CreditData2 As SAPCustomerCreditData) As Boolean
        GeneralData.CompanyId = UCase(GeneralData.CompanyId) : GeneralData.OrgId = UCase(GeneralData.OrgId)
        Dim strCustomerClass As String = GeneralData.CustomerClass.ToString().Substring(5)
        Dim strCountryCode As String = [Enum].GetName(GetType(EnumCountryCode), GeneralData.CountryCode).ToString().Substring(5)
        Dim strCompanyType As String = GeneralData.CompanyType.ToString().Substring(5)
        Dim strIndustryCode As String = GeneralData.IndustryCode.ToString().Substring(5)
        Dim strRegionWestEast As String = GeneralData.RegionWestEast.ToString().Substring(5)
        Dim strCreditTerm As String = "PPD"
        'If GeneralData.HasCreditData Then
        'End If
        'strCreditTerm = CreditData2.CreditTerm.ToString().Trim '.Substring(5)
        Dim strOrgId As String = GeneralData.OrgId.ToString().Substring(5)
        Dim strPlant As String = Left(strOrgId, 2) + "H1"
        Dim strInco1 As String = GeneralData.IncoTerm1.ToString().Substring(5)
        Dim strVM As String = GeneralData.VerticalMarket '.ToString().Substring(5)
        If strVM = "NONE" Then strVM = ""
        ' If strCreditTerm = "NONE" Then strCreditTerm = ""
        'strCreditTerm = "P98"
        Dim strCurrency As String = ""
        'If GeneralData.HasCreditData Then
        'End If
        strCurrency = CreditData2.Currency.ToString().Substring(5)
        Dim strCreateDate As String = Now.ToString("yyyyMMdd"), strCreator As String = "b2baeu"

        Dim p1 As New SAPCustomerRFC.SAPCustomerRFC() '.Zsd_Customer_Maintain_All_V2.Zsd_Customer_Maintain_All_V2
        Dim SAPconnection As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnection = "SAPConnTest"
        End If
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPconnection))
        Dim I_Bapiaddr1 As New SAPCustomerRFC.BAPIADDR1, I_Bapiaddr2 As New SAPCustomerRFC.BAPIADDR2
        Dim I_Customer_Is_Consumer As String = "", I_Force_External_Number_Range As String = "", I_From_Customermaster As String = ""
        Dim I_Kna1 As New SAPCustomerRFC.KNA1, I_Knb1 As New SAPCustomerRFC.KNB1
        Dim I_Knb1_Reference As String = "", I_Knvv As New SAPCustomerRFC.KNVV, I_Maintain_Address_By_Kna1 As String = "X"
        Dim I_No_Bank_Master_Update As String = "", I_Raise_No_Bte As String = "", Pi_Add_On_Data As New SAPCustomerRFC.CUST_ADD_ON_DATA
        Dim Pi_Cam_Changed As String = "", Pi_Postflag As String = ""
        ''Return Arguments
        Dim E_Kunnr As String = "", E_Sd_Cust_1321_Done As String = "", O_Kna1 As New SAPCustomerRFC.KNA1
        Dim T_Upd_Txt As New SAPCustomerRFC.FKUNTXTTable, T_Xkn As New SAPCustomerRFC.FKNASTable
        Dim T_Xknb5 As New SAPCustomerRFC.FKNB5Table, T_Xknbk As New SAPCustomerRFC.FKNBKTable
        Dim T_Xknex As New SAPCustomerRFC.FKNEXTable, T_Xknva As New SAPCustomerRFC.FKNVATable
        Dim T_Xknvd As New SAPCustomerRFC.FKNVDTable, T_Xknvi As New SAPCustomerRFC.FKNVITable
        Dim T_Xknvk As New SAPCustomerRFC.FKNVKTable, T_Xknvl As New SAPCustomerRFC.FKNVLTable
        Dim T_Xknvp As New SAPCustomerRFC.FKNVPTable, T_Xknza As New SAPCustomerRFC.FKNZATable
        Dim T_Ykn As New SAPCustomerRFC.FKNASTable, T_Yknb5 As New SAPCustomerRFC.FKNB5Table
        Dim T_Yknbk As New SAPCustomerRFC.FKNBKTable, T_Yknex As New SAPCustomerRFC.FKNEXTable
        Dim T_Yknva As New SAPCustomerRFC.FKNVATable, T_Yknvd As New SAPCustomerRFC.FKNVDTable
        Dim T_Yknvi As New SAPCustomerRFC.FKNVITable, T_Yknvk As New SAPCustomerRFC.FKNVKTable
        Dim T_Yknvl As New SAPCustomerRFC.FKNVLTable, T_Yknvp As New SAPCustomerRFC.FKNVPTable
        Dim T_Yknza As New SAPCustomerRFC.FKNZATable
        'Assignment 
        Dim T_Xknvidr As New SAPCustomerRFC.FKNVI
        With T_Xknvidr

            .Tatyp = "MWST"
            .Aland = "NL"
            .Kunnr = T(GeneralData.CompanyId)
            .Mandt = "168"
            Dim Taxid As String = String.Empty
            GetCustomerAcctAssgmtGroupAndTaxClassification(strCountryCode, "", Taxid)
            .Taxkd = Taxid
        End With
        With T_Xknvi
            .Add(T_Xknvidr)
        End With
        Dim T_Xknvidr2 As New SAPCustomerRFC.FKNVI
        With T_Xknvidr2
            .Tatyp = "MWST"
            .Aland = "TW"
            .Kunnr = T(GeneralData.CompanyId)
            .Mandt = "168"
            .Taxkd = "0"

        End With
        With T_Xknvi
            .Add(T_Xknvidr2)
        End With
        With I_Bapiaddr1

            .Langu = "EN"
            .Comm_Type = "INT"
            .Homepage = GeneralData.WebSiteUrl
            .Fax_Number = GeneralData.FaxNumber
            .Tel1_Numbr = GeneralData.TelNumber

            ''
            Dim CompanyName As String = T(GeneralData.CompanyName)
            If GeneralData.LegalForm IsNot Nothing AndAlso GeneralData.LegalForm.ToString.Trim <> "" Then
                CompanyName += " " + GeneralData.LegalForm.ToString.Trim
            End If
            If CompanyName.Length <= 40 Then
                .Name = CompanyName
            ElseIf 40 < CompanyName.Length <= 80 Then
                .Name = CompanyName.Substring(0, 40)
                .Name_2 = CompanyName.Substring(40)
            ElseIf 80 < CompanyName.Length <= 120 Then
                .Name = CompanyName.Substring(0, 40)
                .Name_2 = CompanyName.Substring(40, 80)
                .Name_3 = CompanyName.Substring(80)
            ElseIf 120 < CompanyName.Length Then
                .Name = CompanyName.Substring(0, 40)
                .Name_2 = CompanyName.Substring(40, 80)
                .Name_3 = CompanyName.Substring(80, 120)
                .Name_4 = CompanyName.Substring(120)
            End If
            .Title = "Company"
            .Country = T(GeneralData.CountryCode.ToString().Substring(5))
            '.Street = T(GeneralData.Address.Replace("|", " "))
            '.Str_Suppl3 = ""
            '.Location = ""
            If GeneralData.Address.Contains("|") Then
                Dim p() As String = Split(GeneralData.Address, "|")
                .Street = T(p(0))
                '.Str_Suppl1 = T(p(1))
                'If p.Length >= 3 Then
                '    .Str_Suppl2 = T(p(2))
                'End If
                'If p.Length >= 4 Then
                '    .Str_Suppl3 = T(p(3))
                'End If
                'If p.Length >= 5 Then
                '    .Location = T(p(4))
                'End If
                .Str_Suppl3 = T(p(1))
                If p.Length >= 3 Then
                    .Location = T(p(2))
                End If
                If p.Length >= 4 Then
                    .Str_Suppl1 = T(p(3))
                End If
                If p.Length >= 5 Then
                    .Str_Suppl2 = T(p(4))
                End If


            Else
                .Street = T(GeneralData.Address)
            End If
            .Postl_Cod1 = T(GeneralData.PostCode)
            .Addr_No = "" : .City = T(GeneralData.City) : .C_O_Name = T(GeneralData.ContactPersonName) : .E_Mail = T(GeneralData.ContactPersonEmail)
            '.Sort1 = T(GeneralData.SearchTerm1)
            '.Sort2 = T(GeneralData.SearchTerm2)
            '.Sort1 = T("NL0002032")
            '.Sort2 = T(GeneralData.SearchTerm2.Replace(" ", ""))
            If GeneralData.NEED_DIGITALINVOICE Then
                '.Comm_Type = "E-Mail"
                .E_Mail = T(GeneralData.INVOICE_EMAIL)
            End If
        End With
        With I_Bapiaddr2

            '.Sort1_P = T(GeneralData.SearchTerm1)
            '.Sort2_P = T(GeneralData.SearchTerm2)
            ' .Namcountry = GeneralData.CountryCode.ToString().Substring(5)
            ' .Postl_Cod1 = GeneralData.PostCode
            '.C_O_Name = T(GeneralData.ContactPersonName)

            .Addr_No = ""
        End With
        I_Customer_Is_Consumer = "" : I_Force_External_Number_Range = "1" : I_From_Customermaster = "1"
        With I_Kna1
            .Mandt = "168"

            .Kunnr = T(GeneralData.CompanyId)
            .Land1 = T(strCountryCode)
            .Name1 = T(GeneralData.CompanyName)
            .Name2 = ""
            .Ort01 = T(GeneralData.City)
            .Pstlz = T(GeneralData.PostCode)
            .Regio = " "
            .Sortl = T(GeneralData.SearchTerm1) : .Stras = T(GeneralData.Address) : .Telf1 = GeneralData.TelNumber : .Telfx = GeneralData.FaxNumber
            .Xcpdk = " "
            '.Adrnr = "0000090780"
            .Mcod1 = T(GeneralData.CompanyName)
            .Mcod2 = " "
            .Mcod3 = T(GeneralData.Address) : .Anred = "Company"
            .Aufsd = " " : .Bahne = " " : .Bahns = " " : .Begru = " "
            .Bbbnr = "0000000" : .Bbsnr = "00000" 'International location number  (part 1 & 2), not a variable value so far
            .Bubkz = "0"    'Check digit for the international location number           
            .Brsch = T(strIndustryCode)
            .Datlt = " " : .Erdat = strCreateDate : .Ernam = T(strCreator)
            .Exabl = " " : .Faksd = " " : .Fiskn = " " : .Knazk = " " : .Knrza = " " : .Konzs = " "
            .Ktokd = strCompanyType
            .Kukla = strCustomerClass
            .Lifnr = " " : .Lifsd = " " : .Locco = " " : .Loevm = " " : .Name3 = " " : .Name4 = " "
            .Niels = " " : .Ort02 = " " : .Pfach = " " : .Pstl2 = " " : .Counc = " " : .Cityc = " " : .Rpmkr = " "
            .Sperr = " " : .Spras = "E" : .Stcd1 = GeneralData.REGISTRATION_NUMBER : .Stcd2 = " "
            .Stkza = " " : .Stkzu = " " : .Telbx = " "
            .Telf2 = " " : .Teltx = " " : .Telx1 = " "
            .Lzone = "0000000001" 'T(strRegionWestEast)
            .Xzemp = " " : .Vbund = " "
            .Stceg = GeneralData.VATNumber

            .Dear1 = " " : .Dear2 = " " : .Dear3 = " " : .Dear4 = " " : .Dear5 = " "
            .Gform = " " : .Bran1 = " " : .Bran2 = " " : .Bran3 = " " : .Bran4 = " " : .Bran5 = " " : .Ekont = " "
            .Umsat = "0" : .Umjah = "0000" : .Uwaer = " " : .Jmzah = "000000" : .Jmjah = "0000"
            .Katr1 = T(GeneralData.Attribute1) : .Katr2 = T(GeneralData.Attribute2)

            .Katr3 = T(GeneralData.Attribute3)

            If GeneralData.SalesOffice.Trim = "3000" Then
                .Katr3 = "02"
            ElseIf GeneralData.SalesOffice.Trim = "3300" Then
                .Katr3 = "03"
            ElseIf GeneralData.SalesOffice.Trim = "3200" Then
                .Katr3 = "04"
            End If
            .Katr4 = T(GeneralData.Attribute4) : .Katr5 = T(GeneralData.Attribute5) : .Katr6 = T(GeneralData.Attribute6)
            'Dim strCustomerType As String = T(GeneralData.CustomerType.ToString.Substring(5))
            'If strCustomerType = "NONE" Then strCustomerType = ""
            .Katr7 = "" 'T(strCustomerType) 'Customer Type - ex: 315 - GA eAutomation
            .Katr8 = T(GeneralData.Attribute8)
            .Katr9 = T(strVM) 'Vertical Market
            .Katr10 = T(GeneralData.Attribute10)
            .Stkzn = " " : .Umsa1 = "0" : .Txjcd = " " : .Periv = " " : .Abrvw = " "
            .Inspbydebi = " " : .Inspatdebi = " " : .Ktocd = " " : .Pfort = " " : .Werks = " " : .Dtams = " "
            .Dtaws = " " : .Duefl = "X" : .Hzuor = "00" : .Sperz = " " : .Etikg = " " : .Civve = "X" : .Milve = " "
            .Kdkg1 = T(GeneralData.CondGrp1) : .Kdkg2 = T(GeneralData.CondGrp2) : .Kdkg3 = T(GeneralData.CondGrp3)
            .Kdkg4 = T(GeneralData.CondGrp4) : .Kdkg5 = T(GeneralData.CondGrp5)
            .Xknza = " "
            .Fityp = " " : .Stcdt = " " : .Stcd3 = " " : .Stcd4 = " " : .Xicms = " " : .Xxipi = " " : .Xsubt = " "
            .Cfopc = " " : .Txlw1 = " " : .Txlw2 = " " : .Ccc01 = " " : .Ccc02 = " " : .Ccc03 = " " : .Ccc04 = " "
            .Cassd = " "
            .Knurl = T(GeneralData.WebSiteUrl)
            .J_1kfrepre = " " : .J_1kftbus = " " : .J_1kftind = " " : .Confs = " "
            .Updat = "00000000" : .Uptim = "000000" : .Nodel = " " : .Dear6 = " " : .Alc = " " : .Pmt_Office = " " : .Psofg = " "
            .Psois = " " : .Pson1 = " " : .Pson2 = " " : .Pson3 = " " : .Psovn = " " : .Psotl = " " : .Psohs = " " : .Psost = " "
            .Psoo1 = " " : .Psoo2 = " " : .Psoo3 = " " : .Psoo4 = " " : .Psoo5 = " "
        End With
        With I_Knb1

            .Mandt = "168" : .Kunnr = T(GeneralData.CompanyId) : .Bukrs = strOrgId : .Pernr = "00000000" : .Erdat = strCreateDate
            .Ernam = T(strCreator) : .Sperr = " " : .Loevm = " "
            .Zuawa = "001" 'Sort Key
            If True Then 'GeneralData.HasCreditData
                .Busab = T(CreditData2.AccountingClerk.ToString().Substring(5)) 'Accounting clerk
                .Akont = T(CreditData2.RecAccount.ToString().Substring(5))
                .Vlibb = CreditData2.AmountInsured
                .Fdgrv = T(CreditData2.PlanningGroup.ToString().Substring(5))
                .Vrsnr = "" 'CreditData2.InsurePolicyNumber
            End If

            .Begru = " " : .Knrze = " " : .Knrzb = " " : .Zamim = " " : .Zamiv = " " : .Zamir = " " : .Zamib = " "
            .Zamio = " " : .Zwels = " " : .Xverr = " " : .Zahls = " " : .Zterm = strCreditTerm : .Wakon = " " : .Vzskz = " "
            .Zindt = "00000000" : .Zinrt = "00" : .Eikto = " " : .Zsabe = " " : .Kverm = " "
            .Vrbkz = " " : .Vrszl = "0" : .Vrspr = "0" : .Verdt = "00000000"
            .Perkz = " " : .Xdezv = " " : .Xausz = " " : .Webtr = "0" : .Remit = " " : .Datlz = "00000000" : .Xzver = "X"
            .Togru = " " : .Kultg = "0" : .Hbkid = " " : .Xpore = " " : .Blnkz = " " : .Altkn = " " : .Zgrup = " "
            .Urlid = " "
            .Mgrup = "01" 'Dunning group - currently only one option 01
            .Lockb = " " : .Uzawe = " " : .Ekvbd = " " : .Sregl = " " : .Xedip = " "
            .Frgrp = " " : .Vrsdg = " " : .Tlfxs = " " : .Intad = " " : .Xknzb = " " : .Guzte = " " : .Gricd = " "
            .Gridt = " " : .Wbrsl = " " : .Confs = " " : .Updat = "00000000" : .Uptim = "000000" : .Nodel = " "
            .Tlfns = " " : .Cession_Kz = " " : .Gmvkzd = " "
        End With
        I_Knb1_Reference = ""
        If True Then 'GeneralData.HasCreditData
            With I_Knvv

                .Mandt = "168" : .Kunnr = GeneralData.CompanyId : .Vkorg = strOrgId : .Vtweg = "00" : .Spart = "00"
                .Ernam = strCreator : .Erdat = strCreateDate : .Begru = " " : .Loevm = " " : .Versg = " "
                .Aufsd = " " : .Kalks = "1"
                If GeneralData.CompanyType = EnumCompanyType.Enum_Z001 Then .Kdgrp = T(CreditData2.CustomerGroup.ToString().Substring(5))
                If GeneralData.CompanyType = EnumCompanyType.Enum_Z001 Then .Bzirk = T(CreditData2.SalesDistrict.ToString().Substring(5)) 'Sales District
                .Konda = "00" : .Pltyp = "00"
                .Awahr = "100" 'Order probability
                .Inco1 = T(strInco1) : .Inco2 = T(GeneralData.IncoTerm2)
                .Lifsd = " " : .Autlf = " "
                .Antlf = "9" 'Maximum Number of Partial Deliveries Allowed Per Item
                .Kztlf = " " : .Kzazu = "X" : .Chspl = " "
                .Lprio = "02" 'Delivery Priority
                .Eikto = " " : .Vsbed = T(CreditData2.ShippingCondition)
                .Faksd = " " : .Mrnkz = " " : .Perfk = " " : .Perrl = " " : .Kvakz = " " : .Kvawt = "0"
                .Waers = T(strCurrency) : .Klabc = " "
                Dim AAG As String = String.Empty
                GetCustomerAcctAssgmtGroupAndTaxClassification(strCountryCode, AAG, "")
                .Ktgrd = AAG
                .Zterm = T(strCreditTerm) : .Vwerk = T(strPlant)
                .Vkgrp = T(GeneralData.SalesGroup) : .Vkbur = T(GeneralData.SalesOffice)
                .Vsort = " " : .Kvgr1 = " " : .Kvgr2 = " " : .Kvgr3 = "D0" : .Kvgr4 = " "
                .Kvgr5 = " " : .Bokre = " " : .Boidt = "00000000" : .Kurst = " " : .Prfre = " " : .Prat1 = " "
                .Prat2 = " " : .Prat3 = " " : .Prat4 = " " : .Prat5 = " " : .Prat6 = " " : .Prat7 = " " : .Prat8 = " "
                .Prat9 = " " : .Prata = " " : .Kabss = " " : .Kkber = " " : .Cassd = " " : .Rdoff = " " : .Agrel = " "
                .Megru = " " : .Uebto = "0" : .Untto = "0" : .Uebtk = " " : .Pvksm = " " : .Podkz = " " : .Podtg = "0"
                .Blind = " " : .Bev1_Emlgforts = " " : .Bev1_Emlgpfand = " "
            End With
        End If

        If Not String.IsNullOrEmpty(GeneralData.ContactPersonName) Then
            Dim _knvk As New SAPCustomerRFC.FKNVK
            With _knvk
                .Kunnr = GeneralData.CompanyId
                .Name1 = GeneralData.ContactPersonName
                .Anred = GeneralData.FORM
            End With
            T_Xknvk.Add(_knvk)
        End If

        I_Maintain_Address_By_Kna1 = "" : I_No_Bank_Master_Update = "" : I_Raise_No_Bte = ""
        With Pi_Add_On_Data
            '  .Kunnr = "EFFRFA05"
        End With
        Pi_Cam_Changed = "" : Pi_Postflag = ""
        Try
            p1.Zsd_Customer_Maintain_All(I_Bapiaddr1, I_Bapiaddr2, I_Customer_Is_Consumer, _
                                       I_Force_External_Number_Range, I_From_Customermaster, _
                                       I_Kna1, I_Knb1, I_Knb1_Reference, I_Knvv, I_Maintain_Address_By_Kna1, _
                                       I_No_Bank_Master_Update, I_Raise_No_Bte, _
                                       Pi_Add_On_Data, Pi_Cam_Changed, Pi_Postflag, _
                                       E_Kunnr, E_Sd_Cust_1321_Done, O_Kna1, T_Upd_Txt, _
                                       T_Xkn, T_Xknb5, T_Xknbk, T_Xknex, T_Xknva, T_Xknvd, T_Xknvi, _
                                       T_Xknvk, T_Xknvl, T_Xknvp, T_Xknza, T_Ykn, T_Yknb5, T_Yknbk, T_Yknex, T_Yknva, _
                                       T_Yknvd, T_Yknvi, T_Yknvk, T_Yknvl, T_Yknvp, T_Yknza)
            p1.CommitWork()
            p1.Connection.Close()

            If Not String.IsNullOrEmpty(GeneralData.ContactPersonName) Then
                System.Threading.Thread.Sleep(4000)
                Advantech.Myadvantech.DataAccess.SAPDAL.UpdateContactPerson(T_Xknvk(0).Kunnr, T_Xknvk(0).Parnr _
                 , T_Xknvk(0).Name1, " ", T_Xknvk(0).Anred, GeneralData.ContactPersonEmail, Util.IsTesting())
            End If

        Catch ex As Exception

        End Try
        Dim ConnectToSAPPRD As Boolean = True
        If Util.IsTesting() Then ConnectToSAPPRD = False
        MYSAPDAL.UpdateTranspZoneV2(GeneralData.CompanyId.Trim, "EU10", T(GeneralData.SearchTerm1), T(GeneralData.SearchTerm2), ConnectToSAPPRD)
        Return True
    End Function
    Public Shared Function checkSAPErp(ByVal Erpid As String) As Boolean
        Dim SAPconnection As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnection = "SAP_Test"
        End If
        Dim dt As DataTable = OraDbUtil.dbGetDataTable(SAPconnection, "select Name1 from  saprdp.kna1  where Kunnr ='" + UCase(Erpid) + "'")
        If dt.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function
    <Serializable()> _
    Public Class SAPCustomerGeneralData
        Public IsExist As Boolean
        Public CompanyId As String, CompanyName As String, LegalForm As String, Address As String, City As String, PostCode As String, SearchTerm1 As String, VATNumber As String
        Public SearchTerm2 As String, TelNumber As String, FaxNumber As String, OrgId As EnumOrgId
        Public CountryCode As EnumCountryCode, CustomerClass As EnumCustomerClass, IndustryCode As EnumIndustryCode
        Public CompanyType As EnumCompanyType, RegionWestEast As EnumRegionWestEast, CustomerType As EnumCustomerType
        Public CondGrp1 As String = "L0", CondGrp2 As String = "L0", CondGrp3 As String = "L0", CondGrp4 As String = "L0", CondGrp5 As String = "R4"
        Public Attribute1 As String, Attribute2 As String, Attribute3 As String = "01", Attribute4 As String, Attribute5 As String, Attribute6 As String
        Public Attribute8 As String, Attribute10 As String
        Public WebSiteUrl As String, ContactPersonName As String, ContactPersonEmail As String
        Public IncoTerm1 As EnumIncoTerm, IncoTerm2 As String
        Public SalesGroup As String, SalesOffice As String, SalesCode As String, InsideSalesCode As String
        Public VerticalMarket As EnumVerticalMarket
        Public HasCreditData As Boolean, HasShiptoData As Boolean, HasBillingData As Boolean
        Public CONTACTPERSON_FA As String, TELEPHONE_FA As String, EMAIL_FA As String, APLICATIONNO As String
        Public REGISTRATION_NUMBER As String, FORM As String, NEED_DIGITALINVOICE As Boolean, INVOICE_EMAIL As String

        Public Sub New()
            HasCreditData = False : HasShiptoData = False : HasBillingData = False : IsExist = False
        End Sub
    End Class
    <Serializable()> _
    Public Class SAPCustomerCreditData
        Public CreditTerm As String, Currency As EnumCurrency, CustomerGroup As EnumCustomerGroup
        Public SalesDistrict As EnumSalesDistrict, RecAccount As EnumReconciliationAccount
        Public AmountInsured As Double, InsurePolicyNumber As String, AccountingClerk As EnumAccountingClerk
        Public PlanningGroup As EnumPlanningGroup, ShippingCondition As String 'EnumShippingCondition
    End Class

#Region "Enum Definitions"
    Public Enum EnumCompanyType
        Enum_Z001 ' Customer
        Enum_Z002 ' ShipTo
        Enum_Z003 ' BillTo
    End Enum

    Public Enum EnumIndustryCode
        Enum_1000 ' Taiwan
        Enum_2000 ' America
        Enum_3000 ' Europe
        Enum_4000 ' China
        Enum_5000 ' Asia - Others
        Enum_BRCT ' Brazil
        Enum_BRNC ' Non-Contribu.
    End Enum

    Public Enum EnumRegionWestEast
        Enum_0000000001 ' East
        Enum_0000000002 ' West
    End Enum

    Public Enum EnumCustomerClass
        Enum_01 'AXSC
        Enum_02 'RBU
        Enum_03 'External
        Enum_04 'Joint Venture
    End Enum

    Public Enum EnumCreditTerm
        'Enum_NONE
        'Enum_07D4
        'Enum_10D1
        'Enum_10D2
        'Enum_10D5
        'Enum_15D1
        'Enum_15D2
        'Enum_15D5
        'Enum_30D3
        'Enum_CN01
        'Enum_CN02
        'Enum_CN04
        'Enum_CN05
        'Enum_CN07
        'Enum_CN10
        'Enum_CN15
        'Enum_COD
        'Enum_CODC
        'Enum_CODM
        'Enum_EC30
        'Enum_ECBD
        'Enum_ECBO
        'Enum_ECOB
        'Enum_ECOO
        'Enum_I001
        'Enum_I007
        'Enum_I010
        Enum_I014
        'Enum_I015
        'Enum_I021
        'Enum_I028
        Enum_I030
        'Enum_I035
        'Enum_I045
        'Enum_I060
        'Enum_I070
        'Enum_I075
        'Enum_I090
        'Enum_I120
        'Enum_LC00
        'Enum_M014
        'Enum_M015
        'Enum_M025
        'Enum_M030
        'Enum_M045
        'Enum_M060
        'Enum_M075
        'Enum_M090
        'Enum_M120
        'Enum_M150
        'Enum_M20
        'Enum_M25
        'Enum_M30
        'Enum_MA15
        'Enum_MA30
        'Enum_MB60
        'Enum_MC30
        'Enum_MC60
        'Enum_NM25
        'Enum_P007
        'Enum_P015
        'Enum_P030
        'Enum_P045
        'Enum_P060
        Enum_PPD
        'Enum_PPDW
        'Enum_T030
        'Enum_T045
        'Enum_T060
        'Enum_T075
        'Enum_T090
        'Enum_T120
        'Enum_TN01
    End Enum

    Public Enum EnumIncoTerm
        'Enum_AIR
        'Enum_CFR
        'Enum_CIF
        'Enum_CIP
        'Enum_CPT
        'Enum_DDP
        'Enum_DDU
        'Enum_DHL
        'Enum_EW1
        'Enum_EW3
        Enum_EWS
        'Enum_EXW
        'Enum_FB1
        'Enum_FB2
        'Enum_FB4
        'Enum_FB5
        'Enum_FCA
        'Enum_FEX
        'Enum_FOB
        'Enum_LEX
        'Enum_MOE
        'Enum_OTR
        'Enum_TBD
        'Enum_UPS
    End Enum

    Public Enum EnumReconciliationAccount
        'Enum_0000113997
        Enum_0000121001
        Enum_0000121002
        Enum_0000121003
        Enum_0000121005
        Enum_0000121006
        Enum_0000121007
        Enum_0000121008
        Enum_0000121009
        Enum_0000123100
        'Enum_0000142000
        'Enum_0000148009
        Enum_0000245000
        'Enum_0000248000
    End Enum

    Public Enum EnumVerticalMarket
        Enum_NONE
        Enum_080
        Enum_081
        Enum_082
        Enum_083
        Enum_084
        Enum_100
        Enum_101
        Enum_103
        Enum_104
        Enum_105
        Enum_106
        Enum_107
        Enum_108
        Enum_109
        Enum_130
        Enum_131
        Enum_132
        Enum_133
        Enum_140
        Enum_141
        Enum_142
        Enum_143
        Enum_144
        Enum_145
        Enum_146
        Enum_150
        Enum_151
        Enum_152
        Enum_153
        Enum_154
        Enum_155
        Enum_156
        Enum_157
        Enum_158
        Enum_170
        Enum_200
        Enum_201
        Enum_202
        Enum_203
        Enum_204
        Enum_221
        Enum_222
        Enum_224
        Enum_227
        Enum_260
        Enum_261
        Enum_262
        Enum_263
        Enum_265
        Enum_266
        Enum_270
        Enum_400
        Enum_401
        Enum_590
        Enum_591
        Enum_592
        Enum_593
        Enum_594
        Enum_610
        Enum_611
        Enum_612
        Enum_614
        Enum_615
        Enum_700
        Enum_710
        Enum_720
        Enum_730
        Enum_740
        Enum_750
        Enum_760
        Enum_770
        Enum_780
        Enum_790
        Enum_800
        Enum_810
        Enum_999
    End Enum

    Public Enum EnumShippingCondition
        Enum_01
        Enum_02
        Enum_03
        Enum_04
        Enum_05
        Enum_06
        Enum_07
        Enum_08
        Enum_09
        Enum_10
        Enum_11
        Enum_12
        Enum_13
        Enum_14
        Enum_15
        Enum_16
        Enum_17
        Enum_18
        Enum_19
        Enum_20
        Enum_22
        Enum_23
    End Enum

    Public Enum EnumPlanningGroup
        Enum_A1
        Enum_A2
        Enum_E1
        Enum_E2
        Enum_E3
        Enum_E4
        Enum_P1
        Enum_P3
        Enum_R1
        Enum_R2
        Enum_R3
    End Enum

    Public Enum EnumAccountingClerk
        Enum_01
        Enum_02
        Enum_03
        Enum_04
        Enum_05
        Enum_06
        Enum_07
        Enum_08
        Enum_09
        Enum_10
        Enum_11
        Enum_12
        Enum_13
        Enum_14
        Enum_15
        Enum_16
        Enum_17
        Enum_18
        Enum_19
        Enum_20
        Enum_21
        Enum_22
        Enum_23
        Enum_24
        Enum_25
        Enum_26
        Enum_27
        Enum_28
        Enum_29
        Enum_30
        Enum_31
        Enum_32
        Enum_33
        Enum_34
        Enum_35
        Enum_36
        Enum_37
        Enum_38
        Enum_39
        Enum_40
        Enum_41
        Enum_42
        Enum_43
        Enum_44
        Enum_45
        Enum_46
        Enum_47
        Enum_48
        Enum_49
        Enum_50
        Enum_51
        Enum_52
        Enum_53
        Enum_54
        Enum_55
        Enum_56
        Enum_57
        Enum_58
        Enum_59
        Enum_60
        Enum_61
        Enum_62
        Enum_63
        Enum_64
        Enum_65
        Enum_66
        Enum_67
        Enum_68
        Enum_69
        Enum_70
        Enum_71
        Enum_72
        Enum_73
        Enum_74
        Enum_75
        Enum_76
        Enum_77
        Enum_78
        Enum_79
        Enum_81
        Enum_82
        Enum_83
        Enum_84
        Enum_85
        Enum_86
        Enum_87
        Enum_88
        Enum_89
        Enum_90
        Enum_91
        Enum_93
        Enum_94
        Enum_95
        Enum_96
        Enum_97
        Enum_98
        Enum_AC
        Enum_AI
        Enum_CT
        Enum_EI
        Enum_OP
        Enum_TI
        Enum_Z1
    End Enum

    Public Enum EnumSalesDistrict
        Enum_010
        Enum_020
        Enum_030
        Enum_040
        Enum_050
        Enum_060
        Enum_070
        Enum_080
        Enum_090
        Enum_100
        Enum_110
        Enum_120
        Enum_130
        Enum_140
        Enum_150
        Enum_160
        Enum_170
        Enum_180
        Enum_190
        Enum_200
        Enum_210
        Enum_220
        Enum_230
        Enum_240
        Enum_250
        Enum_260
        Enum_270
        Enum_280
        Enum_290
        Enum_330
        Enum_D10
        Enum_D15
        Enum_D20
        Enum_D21
        Enum_D25
        Enum_D30
        Enum_D35
        Enum_D36
        Enum_D39
        Enum_D40
        Enum_D41
        Enum_D45
        Enum_D46
        Enum_D50
        Enum_D51
        Enum_D52
        Enum_D55
        Enum_D56
        Enum_D60
        Enum_D61
        Enum_D70
        Enum_D75
        Enum_D80
        Enum_D85
        Enum_D90
        Enum_D91
        Enum_D94
        Enum_D95
        Enum_D97
        Enum_D98
        Enum_DLG
        Enum_DMS
        Enum_E01
        Enum_E02
        Enum_E03
        Enum_E04
        Enum_E05
        Enum_E06
        Enum_E07
        Enum_E08
        Enum_E09
        Enum_E10
        Enum_I20
        Enum_I90
        Enum_L10
        Enum_L20
        Enum_L30
        Enum_L40
        Enum_L50
        Enum_L60
        Enum_M10
        Enum_M15
        Enum_M20
        Enum_M25
        Enum_M30
        Enum_M35
        Enum_M40
        Enum_M45
        Enum_M50
        Enum_M55
        Enum_M65
        Enum_M70
        Enum_M75
        Enum_M80
        Enum_PC0
    End Enum

    Public Enum EnumCustomerGroup
        Enum_01
        Enum_02
        Enum_03
        Enum_04
        Enum_05
        Enum_06
        Enum_07
        Enum_08
        Enum_09
        Enum_10
        Enum_11
        Enum_12
        Enum_13
        Enum_15
        Enum_20
        Enum_30
        Enum_B1
        Enum_D1
        Enum_K1
    End Enum

    Public Enum EnumCurrency
        Enum_AUD
        Enum_BRL
        Enum_CNY
        Enum_EUR
        Enum_GBP
        Enum_JPY
        Enum_KRW
        Enum_MYR
        Enum_SGD
        Enum_THB
        Enum_TWD
        Enum_USD
    End Enum

    Public Enum EnumOrgId
        Enum_AU01
        Enum_BR01
        Enum_CN01
        Enum_CN02
        Enum_CN10
        Enum_CN11
        Enum_CN12
        Enum_CN13
        Enum_CN20
        Enum_CN30
        Enum_CN40
        Enum_EU10
        Enum_EU33
        Enum_EU34
        Enum_EU50
        Enum_HK05
        Enum_JP01
        Enum_KR01
        Enum_MY01
        Enum_SG01
        Enum_TL01
        Enum_TW01
        Enum_TW02
        Enum_TW03
        Enum_TW04
        Enum_TW05
        Enum_TWCP
        Enum_US01
    End Enum

    Public Enum EnumCountryCode
        Enum_AD
        Enum_AE
        Enum_AL
        Enum_AM
        Enum_AN
        Enum_AO
        Enum_AR
        Enum_AT
        Enum_AU
        Enum_AZ
        Enum_BA
        Enum_BD
        Enum_BE
        Enum_BF
        Enum_BG
        Enum_BH
        Enum_BM
        Enum_BN
        Enum_BO
        Enum_BR
        Enum_BS
        Enum_BW
        Enum_BY
        Enum_BZ
        Enum_CA
        Enum_CH
        Enum_CL
        Enum_CN
        Enum_CO
        Enum_CR
        Enum_CY
        Enum_CZ
        Enum_DE
        Enum_DK
        Enum_DM
        Enum_DO
        Enum_DZ
        Enum_EC
        Enum_EE
        Enum_EG
        Enum_ES
        Enum_FI
        Enum_FJ
        Enum_FK
        Enum_FR
        Enum_GB
        Enum_GD
        Enum_GE
        Enum_GL
        Enum_GR
        Enum_GT
        Enum_HK
        Enum_HN
        Enum_HR
        Enum_HU
        Enum_ID
        Enum_IE
        Enum_IL
        Enum_IN
        Enum_IQ
        Enum_IR
        Enum_IS
        Enum_IT
        Enum_JM
        Enum_JO
        Enum_JP
        Enum_KE
        Enum_KG
        Enum_KH
        Enum_KR
        Enum_KW
        Enum_KY
        Enum_KZ
        Enum_LA
        Enum_LB
        Enum_LI
        Enum_LK
        Enum_LT
        Enum_LU
        Enum_LV
        Enum_LY
        Enum_MA
        Enum_MC
        Enum_MD
        Enum_ME
        Enum_MF
        Enum_MG
        Enum_MK
        Enum_MM
        Enum_MN
        Enum_MO
        Enum_MR
        Enum_MT
        Enum_MU
        Enum_MV
        Enum_MW
        Enum_MX
        Enum_MY
        Enum_NA
        Enum_NC
        Enum_NE
        Enum_NG
        Enum_NI
        Enum_NL
        Enum_NO
        Enum_NP
        Enum_NZ
        Enum_OM
        Enum_PA
        Enum_PE
        Enum_PH
        Enum_PK
        Enum_PL
        Enum_PR
        Enum_PS
        Enum_PT
        Enum_PY
        Enum_QA
        Enum_RO
        Enum_RS
        Enum_RU
        Enum_SA
        Enum_SB
        Enum_SE
        Enum_SG
        Enum_SI
        Enum_SK
        Enum_SL
        Enum_SV
        Enum_SY
        Enum_SZ
        Enum_TF
        Enum_TH
        Enum_TJ
        Enum_TN
        Enum_TR
        Enum_TT
        Enum_TW
        Enum_UA
        Enum_UG
        Enum_US
        Enum_UY
        Enum_UZ
        Enum_VA
        Enum_VE
        Enum_VG
        Enum_VI
        Enum_VN
        Enum_XK
        Enum_YU
        Enum_ZA
        Enum_ZM
        Enum_ZW
    End Enum

    Public Enum EnumCustomerType
        Enum_NONE
        Enum_312
        Enum_315
        Enum_321
        Enum_322
        Enum_323
        Enum_324
        Enum_325
        Enum_327
    End Enum
#End Region
    Public Shared Function T(str As Object) As String
        Try
            Return str.ToString.Trim.ToUpper
        Catch ex As Exception
            Return ""
        End Try
    End Function
    Public Shared Function FindEnumValueByName(ByVal EnumType As System.Type, ByVal EnumName As String) As Integer
        Dim Names() As String = [Enum].GetNames(EnumType)
        Dim Values() As Integer = [Enum].GetValues(EnumType)
        For i As Integer = 0 To Names.Length - 1
            If Names(i).Equals(EnumName, StringComparison.OrdinalIgnoreCase) Then
                Return Values(i)
            End If
        Next
        Return -1
    End Function
    <WebMethod()> _
    Public Function GetApplicationDT() As GetAllDataTable
        'Dim dt As New DataTable
        'dt.Columns.Add(New DataColumn("ROW_ID", GetType(String)))
        'Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
        Dim dt As New GetAllDataTable
        'dt = A.GetDataByApplicationID("")
        'Dim R As GetAllRow = dt.Rows(0)
        Return dt
    End Function
    <WebMethod()> _
    Public Shared Function IsERPIDExist(ByVal strERPID As String) As Boolean
        Dim SAPconnection As String = "SAP_PRD"
        If Util.IsTesting() Then
            SAPconnection = "SAP_Test"
        End If
        Dim dt As DataTable = OraDbUtil.dbGetDataTable(SAPconnection, _
                 "select kunnr from saprdp.kna1 where kunnr='" + UCase(Replace(Trim(strERPID), "'", "''")) + "' and rownum=1")
        If dt.Rows.Count = 1 Then
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Sub UpdateSieble(ByVal ApplicationID As String)
        ' If Util.IsTesting() Then Exit Sub
        Dim SiebelRowid As String = String.Empty
        Dim companyID As String = String.Empty
        Dim A As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_GENERALDATATableAdapter
        Dim dt As DataTable = A.selectByApplicationID(ApplicationID)
        If dt.Rows.Count > 0 Then
            companyID = dt.Rows(0).Item("companyid").ToString().Trim
        End If
        Dim B As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_APPLICATION_ExtendTableAdapter
        Dim dt2 As DataTable = B.selectbyApplicationID(ApplicationID)
        If dt2.Rows.Count > 0 Then
            SiebelRowid = dt2.Rows(0).Item("SIEBELROWID").ToString().Trim
        End If
        If Not String.IsNullOrEmpty(SiebelRowid) AndAlso Not String.IsNullOrEmpty(companyID) Then
            Try
                Dim result As String = Advantech.Myadvantech.DataAccess.SiebelDAL.UpdateAccountErpID(SiebelRowid, companyID)
                If Not String.IsNullOrEmpty(result) Then
                    System.Threading.Thread.Sleep(4000)
                    MYSIEBELDAL.SyncAccountFromSiebel2MyAdvantech(SiebelRowid)
                    Dim usql As String = String.Format("update QuotationMaster set quoteToErpId ='{0}'  where   quoteToRowId ='{1}' and (quoteToErpId is null or quoteToErpId='')", companyID, SiebelRowid)
                    Dim retint As Integer = -1
                    retint = dbUtil.dbExecuteNoQuery("EQ", usql)
                    If retint = -1 Then
                        Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "myadvantech@advantech.com", _
                                          "", "", _
                                          " Update Quotation EripID Failed", "", SiebelRowid + "->" + companyID + vbNewLine + usql)
                    End If
                End If
                'Dim ws As New aeu_eai2000.Siebel_WS, ret As String = String.Empty
                'ret = ws.UpdateAccountV2(SiebelRowid, companyID)
                'If String.IsNullOrEmpty(ret.Trim) Then
                '    Dim usql As String = String.Format("update QuotationMaster set quoteToErpId ='{0}'  where   quoteToRowId ='{1}' and (quoteToErpId is null or quoteToErpId='')", companyID, SiebelRowid)
                '    Dim retint As Integer = -1
                '    retint = dbUtil.dbExecuteNoQuery("EQ", usql)
                '    ' Call MailUtil.Utility_EMailPage("myadvantech@advantech.com.cn", "myadvantech@advantech.com.cn", _
                '    '                  "", "", " Update Quotation EripID sql: .", "", SiebelRowid + "->" + companyID + "->" + usql.ToString)
                '    If retint <> -1 Then
                '        '   Call MailUtil.Utility_EMailPage("myadvantech@advantech.com.cn", "myadvantech@advantech.com.cn", _
                '        '                   "", "", _
                '        '                 " Update Quotation EripID successfully .", "", SiebelRowid + "->" + companyID)
                '    Else
                '        Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "myadvantech@advantech.com", _
                '                          "", "", _
                '                          " Update Quotation EripID Failed", "", SiebelRowid + "->" + companyID + vbNewLine + usql)
                '    End If
                'Else
                '    Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "myadvantech@advantech.com", _
                '                                    "", "", _
                '                                    " Update Sieble Failed", "", SiebelRowid + "->" + companyID + vbNewLine + ret)
                'End If
            Catch ex As Exception
                Call MailUtil.Utility_EMailPage("myadvantech@advantech.com", "myadvantech@advantech.com", _
                                                 "", "", _
                                                 " Update Sieble Failed", "", SiebelRowid + "->" + companyID + " : " + ex.ToString)
            End Try

        End If
        If Not String.IsNullOrEmpty(SiebelRowid) Then
            Try
                System.Threading.Thread.Sleep(4000)
                ' Call MailUtil.Utility_EMailPage("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn", "", "", "SyncAccountFromSiebel2MyAdvantech", "", SiebelRowid + vbTab + Now.ToLongTimeString)
                MYSIEBELDAL.SyncAccountFromSiebel2MyAdvantech(SiebelRowid)
            Catch ex As Exception
                Call MailUtil.Utility_EMailPage("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn", "", "", "SyncAccountFromSiebel2MyAdvantech error:", "", SiebelRowid + vbTab + Now.ToLongTimeString + vbCrLf + ex.ToString())
            End Try
        End If
    End Sub
    Public Shared Sub CallEstoreWS(ByVal ApplicationID As String)
        Dim EstoreOrderid As String = String.Empty, WSurl As String = String.Empty
        Dim B As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_APPLICATION_ExtendTableAdapter
        Dim dt2 As DataTable = B.selectbyApplicationID(ApplicationID)
        If dt2.Rows.Count > 0 Then
            EstoreOrderid = dt2.Rows(0).Item("EstoreOrderid").ToString().Trim
            WSurl = dt2.Rows(0).Item("TOBACKURL").ToString().Trim
        End If
        If Not String.IsNullOrEmpty(EstoreOrderid) Then
            Try
                Dim ws As New eStoreOrderWSV2.eStoreWebService, ret As String = String.Empty
                If Not String.IsNullOrEmpty(WSurl) Then
                    ws.Url = String.Format("{0}/eStoreWebService.asmx", WSurl)
                End If
                Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
                Dim dt As New CreateSAPCustomer.GetAllDataTable
                dt = A.GetDataByApplicationID(ApplicationID)
                Dim dr As CreateSAPCustomer.GetAllRow = dt.Rows(0)
                ret = ws.generateSAPCustomer(EstoreOrderid, ApplicationID)
                If Not String.IsNullOrEmpty(ret) Then
                    If ret.Contains("[/eStoreOrderLink]") AndAlso Not String.IsNullOrEmpty(WSurl) Then
                        ret = ret.Replace("[/eStoreOrderLink]", WSurl)
                    End If
                    Dim strSubject As String = "SAP account creation request for order notification "
                    Dim strFrom As String = "eBusiness.AEU@advantech.eu"
                    Dim strTo As String = dr.REQUEST_BY
                    Dim strCC As String = ""
                    Dim strBcc As String = "Jay.Lee@advantech.com,tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn"
                    If Util.IsTesting() Then
                        Call MailUtil.Utility_EMailPage(strFrom, "ming.zhao@advantech.com.cn", "Jay.Lee@advantech.com,tc.chen@advantech.com.tw,xiaoya.hua@advantech.com.cn", "ming.zhao@advantech.com.cn", strSubject.Trim(), "", "TO:" + strTo + "<BR/>CC:" + strCC + "<BR/>BCC:" + strBcc + "<HR/>" + ret)
                    Else
                        Call MailUtil.Utility_EMailPage(strFrom, strTo, strCC, strBcc, strSubject.Trim(), "", ret)
                    End If
                End If
            Catch ex As Exception
                Call MailUtil.Utility_EMailPage("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn", _
                                                 "Xiaoya.hua@advantech.com.cn", "Xiaoya.hua@advantech.com.cn,ming.zhao@advantech.com.cn", _
                                                 " CallEstoreWS Failed", "", EstoreOrderid + " : " + ex.ToString)
            End Try


        End If
    End Sub
    Public Shared Function NewCompanyId(ByVal CompanyId As String, ByRef tempShiptoErpid As String, ByRef tempBilltoErpid As String) As Boolean
        Dim tmpCompanyId As String = ""
        Dim arrList As ArrayList = New ArrayList
        Dim arrChar As Char() = New Char() {"A", "B", "C", "D", _
       "E", "F", "G", "H", "I", "J", _
       "K", "L", "M", "N", "O", "P", "Q", _
       "R", "T", "S", "V", "U", "W", _
       "X", "Y", "Z"}
        For Each A As Char In arrChar
            arrList.Add(A)
        Next
        For k As Integer = 0 To arrChar.Length - 1
            For j As Integer = 0 To arrChar.Length - 1
                arrList.Add(arrChar(k) + arrChar(j))
            Next
        Next
        Dim i As Integer = 0
        Do While True
            tmpCompanyId = CompanyId + arrList(i).ToString() 'RandLetter()
            If IsERPIDExist(tmpCompanyId) = False Then
                If String.IsNullOrEmpty(tempShiptoErpid) Then
                    tempShiptoErpid = tmpCompanyId
                Else
                    tempBilltoErpid = tmpCompanyId
                End If
                If Not String.IsNullOrEmpty(tempBilltoErpid) Then
                    Exit Do
                End If
            End If
            If i = arrList.Count - 1 Then
                Exit Do
            End If
            i = i + 1
        Loop
        Return 1
    End Function
    Public Shared Function NewCompanyIdforACN(ByVal CompanyId As String, ByRef tempShiptoErpid As String, ByRef tempBilltoErpid As String) As Boolean
        Dim tmpCompanyId As String = ""
        Dim arrList As ArrayList = New ArrayList
        Dim arrChar As String() = New String() {"S01", "S02", "S03", "S04", _
       "S05", "S06", "S07", "S08", "S09", "S10", _
       "S11", "S12", "S13", "S14", "S15", "S16", "S17", _
       "S18", "S19", "S20", "S21", "S22", "S23", _
       "S24", "S25", "S26"}
        For Each A As String In arrChar
            arrList.Add(A)
        Next
        'For k As Integer = 0 To arrChar.Length - 1
        '    For j As Integer = 0 To arrChar.Length - 1
        '        arrList.Add(arrChar(k) + arrChar(j))
        '    Next
        'Next
        Dim i As Integer = 0
        Do While True
            tmpCompanyId = CompanyId + arrList(i).ToString() 'RandLetter()
            If IsERPIDExist(tmpCompanyId) = False Then
                If String.IsNullOrEmpty(tempShiptoErpid) Then
                    tempShiptoErpid = tmpCompanyId
                Else
                    tempBilltoErpid = tmpCompanyId
                End If
                If Not String.IsNullOrEmpty(tempBilltoErpid) Then
                    Exit Do
                End If
            End If
            If i = arrList.Count - 1 Then
                Exit Do
            End If
            i = i + 1
        Loop
        Return 1
    End Function
    Public Shared Function RandLetter() As String
        Dim arrChar As Char() = New Char() {"A", "B", "C", "D", _
        "E", "F", "G", "H", "I", "J", _
        "K", "L", "M", "N", "Q", "P", _
        "R", "T", "S", "V", "U", "W", _
        "X", "Y", "Z"}
        Dim rnd As New Random(DateTime.Now.Millisecond)
        Return arrChar(rnd.Next(0, arrChar.Length)).ToString.Trim
    End Function
    Shared Function GET_Siebel_Account_List(ByVal Name As String, ByVal RBU As String, ByVal erpid As String, _
                                        ByVal country As String, ByVal location As String, ByVal state As String, _
                                        ByVal province As String, ByVal status As String, ByVal address1 As String, ByVal ZipCode As String, ByVal City As String) As String
        Dim str As String = " select TOP 100 a.ROW_ID AS ROW_ID, a.NAME as COMPANYNAME, IsNull(b.ATTRIB_05,'') as ERPID, " & _
                            " IsNull(d.COUNTRY,'') as COUNTRY, IsNull(d.CITY,'') as CITY, Isnull(a.LOC,'') as LOCATION, " & _
                            " IsNull(c.NAME, '') as RBU, IsNull(d.STATE,'') as STATE,IsNull(d.PROVINCE,'') as PROVINCE, " + _
                            " IsNull(a.CUST_STAT_CD,'') as STATUS ,IsNull(d.ADDR,'') as ADDRESS, IsNull(d.ZIPCODE,'') as ZIPCODE, IsNull(d.ADDR_LINE_2,'') as ADDRESS2,  " & _
                            " ISNULL((SELECT EMAIL_ADDR FROM S_CONTACT WHERE (ROW_ID IN (SELECT PR_EMP_ID FROM S_POSTN WHERE (ROW_ID IN (SELECT PR_POSTN_ID FROM S_ORG_EXT WHERE (ROW_ID = a.ROW_ID)))))), N'') AS PRIMARY_SALES_EMAIL" & _
                            " from S_ORG_EXT a left join S_ORG_EXT_X b on a.ROW_ID=b.ROW_ID " & _
                            " left join S_PARTY c on a.BU_ID=c.ROW_ID " & _
                            " left join S_ADDR_PER d on a.PR_ADDR_ID=d.ROW_ID where 1=1 and (a.INT_ORG_FLG != N'Y' OR a.PRTNR_FLG != N'N') "
        If Not Util.IsTesting() Then
            str += "  and ( b.ATTRIB_05 ='' or b.ATTRIB_05 is null ) "
        End If
        If Not String.IsNullOrEmpty(Name) Then
            str += String.Format(" and Upper(ISNULL(a.NAME,'')) like Upper(N'%{0}%') ", Name.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
        End If
        'If Not String.IsNullOrEmpty(erpid) Then
        '    str += String.Format(" and Upper(ISNULL(b.ATTRIB_05,'')) like Upper(N'%{0}%') ", erpid.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
        'End If
        If Not String.IsNullOrEmpty(RBU) Then
            Dim SRBU() As String = RBU.Split(",")
            If SRBU.Length > 1 Then
                Dim temp As String = ""
                For Each r As String In SRBU
                    temp = temp + "'" + r.ToUpper + "',"
                Next
                temp = temp.Trim(",")
                str += String.Format(" and Upper(c.NAME) in ({0}) ", temp)

            Else
                str += String.Format(" and Upper(c.NAME) = Upper(N'{0}') ", RBU.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
            End If
            For Each R As String In SRBU

            Next

        End If
        If Not String.IsNullOrEmpty(country) Then
            str += String.Format(" and Upper(d.COUNTRY) like Upper(N'%{0}%') ", country.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
        End If
        If Not String.IsNullOrEmpty(location) Then
            str += String.Format(" and Upper(a.LOC) like Upper(N'%{0}%') ", location.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
        End If
        If Not String.IsNullOrEmpty(state) AndAlso Not String.IsNullOrEmpty(province) Then
            str += String.Format(" and (Upper(d.STATE) like Upper(N'%{0}%') or Upper(d.PROVINCE) like Upper(N'%{1}%'))", state.Trim().ToUpper().Replace("'", "''").Replace("*", "%"), province.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
        Else
            If Not String.IsNullOrEmpty(state) Then
                str += String.Format(" and Upper(d.STATE) like Upper(N'%{0}%') ", state.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
            End If

            If Not String.IsNullOrEmpty(province) Then
                str += String.Format(" and Upper(d.PROVINCE) like Upper(N'%{0}%') ", province.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
            End If
        End If
        If Not String.IsNullOrEmpty(status) Then
            str += String.Format(" and Upper(a.CUST_STAT_CD) = Upper(N'{0}') ", status.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
        End If

        If Not String.IsNullOrEmpty(address1) Then
            str += String.Format(" and Upper(d.ADDR) like Upper(N'%{0}%') ", address1.Trim().ToUpper().Replace("'", "''").Replace("*", "%"))
        End If

        If Not String.IsNullOrEmpty(ZipCode) Then
            str += String.Format(" and Upper(d.ZIPCODE) like Upper(N'%{0}%') ", ZipCode.ToUpper())
        End If
        If Not String.IsNullOrEmpty(City) Then
            str += String.Format(" and Upper(d.CITY) like Upper(N'%{0}%') ", City.ToUpper())
        End If

        'If Not AuthControlUtil.IsInMailGroup("MyAdvantech", HttpContext.Current.Session("user")) And _
        '    Not HttpContext.Current.Session("user").ToString().Equals("jay.lee@advantech.com", StringComparison.OrdinalIgnoreCase) Then
        '    Dim arrRBU As ArrayList = AuthControlUtil.GetVisibleRBUByUser(HttpContext.Current.Session("user"))

        '    If arrRBU.Count > 0 Then
        '        Dim strRBU(arrRBU.Count - 1) As String
        '        For i As Integer = 0 To arrRBU.Count - 1
        '            strRBU(i) = "'" + Replace(UCase(arrRBU.Item(i)), "'", "''") + "'"
        '        Next
        '        Dim strJoinedRBU As String = String.Join(",", strRBU)
        '        str += " and c.NAME is not null and Upper(c.NAME) in (" + strJoinedRBU + ") "

        '    End If
        'End If

        'If Biz_CN.isCNuser(HttpContext.Current.Session("user")) Then
        '    Dim LST As String = getAccountOwnerByUser(HttpContext.Current.Session("user"))
        '    If LST.Length > 0 Then
        '        str += String.Format(" and a.ROW_ID in ({0}) ", LST)
        '    Else
        '        str += String.Format(" and 1<>1 ")
        '    End If
        'End If
        str += " order by a.ROW_ID "
        'Util.SendEmail("eBusiness.AEU@advantech.eu", "nada.liu@advantech.com.cn", "", "", "eQuotation Error Massage by ", "", str, "")
        Return str
    End Function
End Class