
Partial Class Lab_CreateShiptoTest
    Inherits System.Web.UI.Page


    'Public Enum EnumCompanyType
    '    Enum_Z001 ' Customer
    '    Enum_Z002 ' ShipTo
    '    Enum_Z003 ' BillTo
    'End Enum


    'Public Enum EnumCustomerClass
    '    Enum_01 'AXSC
    '    Enum_02 'RBU
    '    Enum_03 'External
    '    Enum_04 'Joint Venture
    'End Enum

    'Public Enum EnumCustomerType
    '    Enum_NONE
    '    Enum_312
    '    Enum_315
    '    Enum_321
    '    Enum_322
    '    Enum_323
    '    Enum_324
    '    Enum_325
    '    Enum_327
    'End Enum

    'Public Enum EnumIndustryCode
    '    Enum_1000 ' Taiwan
    '    Enum_2000 ' America
    '    Enum_3000 ' Europe
    '    Enum_4000 ' China
    '    Enum_5000 ' Asia - Others
    '    Enum_BRCT ' Brazil
    '    Enum_BRNC ' Non-Contribu.
    'End Enum

    'Public Enum EnumOrgId
    '    Enum_AU01
    '    Enum_BR01
    '    Enum_CN01
    '    Enum_CN02
    '    Enum_CN10
    '    Enum_CN11
    '    Enum_CN12
    '    Enum_CN13
    '    Enum_CN20
    '    Enum_CN30
    '    Enum_CN40
    '    Enum_EU10
    '    Enum_EU33
    '    Enum_EU34
    '    Enum_EU50
    '    Enum_HK05
    '    Enum_JP01
    '    Enum_KR01
    '    Enum_MY01
    '    Enum_SG01
    '    Enum_TL01
    '    Enum_TW01
    '    Enum_TW02
    '    Enum_TW03
    '    Enum_TW04
    '    Enum_TW05
    '    Enum_TWCP
    '    Enum_US01
    'End Enum

    'Public Shared Function FindEnumValueByName(ByVal EnumType As System.Type, ByVal EnumName As String) As Integer
    '    Dim Names() As String = [Enum].GetNames(EnumType)
    '    Dim Values() As Integer = [Enum].GetValues(EnumType)
    '    For i As Integer = 0 To Names.Length - 1
    '        If Names(i).Equals(EnumName, StringComparison.OrdinalIgnoreCase) Then
    '            Return Values(i)
    '        End If
    '    Next
    '    Return -1
    'End Function

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load

        Dim dt As New CreateSAPCustomer.GetAllDataTable

        Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
        Dim R As CreateSAPCustomer.GetAllRow = dT.Rows(0)
        Dim tempShiptoErpid As String = String.Empty  ' <-- 這裏需要傳入新的ship to ERPID
        Dim salesofficecode As String = String.Empty  ' <-- 需要帶入Sales Office Code

        'Create ship-to'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        Dim objShiptoGeneralData As New CreateSAPCustomerDAL.SAPCustomerGeneralData, objShiptoCreditData As New CreateSAPCustomerDAL.SAPCustomerCreditData
        If Boolean.Parse(R.HASSHIPTODATA) Then
            With objShiptoGeneralData
                .HasCreditData = True
                .Address = R.SHIPTOADDRESS : .City = R.SHIPTOCITY : .CompanyId = "" : .CompanyName = R.SHIPTOCOMPANYNAME
                .CompanyType = CreateSAPCustomerDAL.EnumCompanyType.Enum_Z002 : .ContactPersonEmail = R.SHIPTOCONTACTEMAIL : .ContactPersonName = R.SHIPTOCONTACTNAME
                .CountryCode = Integer.Parse(R.SHIPTOCOUNTRY) ' FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.SHIPTOCOUNTRY)
                .CustomerClass = CreateSAPCustomerDAL.EnumCustomerClass.Enum_03
                .CustomerType = CreateSAPCustomerDAL.FindEnumValueByName(GetType(CreateSAPCustomerDAL.EnumCustomerType), "Enum_" + R.CUSTOMERTYPE)
                'lbDebugMsg.Text = "CustomerType:" + .CustomerType.ToString() + ",dlCustomerType.SelectedValue:" + dlCustomerType.SelectedValue
                .FaxNumber = R.SHIPTOFAX
                '.IncoTerm1 = FindEnumValueByName(GetType(EnumIncoTerm), "Enum_" + dlInco1.SelectedItem.Text)
                '.IncoTerm2 = txtInco2.Text
                .IndustryCode = CreateSAPCustomerDAL.EnumIndustryCode.Enum_3000
                .OrgId = CreateSAPCustomerDAL.EnumOrgId.Enum_EU10
                .PostCode = R.SHIPTOPOSTCODE
                .RegionWestEast = CreateSAPCustomerDAL.EnumRegionWestEast.Enum_0000000001 '.SalesCode = ""
                .SalesGroup = R.SALESGROUP : .SalesOffice = R.SALESOFFICE
                .SearchTerm1 = R.SHIPTOVATNUMBER : .SearchTerm2 = R.SHIPTOCOMPANYNAME
                .TelNumber = R.SHIPTOTEL : .VATNumber = R.SHIPTOVATNUMBER
                '.VerticalMarket = FindEnumValueByName(GetType(EnumVerticalMarket), "Enum_" + dlVM.SelectedValue)
                'If dlVM.SelectedIndex = 0 Then .VerticalMarket = EnumVerticalMarket.Enum_NONE
                '.WebSiteUrl = txtWebsiteUrl.Text

                ' .LegalForm = R.LEGALFORM.Replace("'", "''")
                .IncoTerm1 = CreateSAPCustomerDAL.FindEnumValueByName(GetType(CreateSAPCustomerDAL.EnumIncoTerm), "Enum_" + R.INCOTERM1)
                .IncoTerm2 = R.INCOTERM2
                .InsideSalesCode = R.INSIDESALESCODE
                .SalesCode = R.SALESCODE
                ' .VerticalMarket = R.VERTICALMARKET
            End With
            With objShiptoCreditData
                .AccountingClerk = CreateSAPCustomerDAL.EnumAccountingClerk.Enum_EI
                .AmountInsured = 0

                ' If Double.TryParse(txtAmtInsured.Text, 0) Then .AmountInsured = CDbl(txtAmtInsured.Text)
                .AmountInsured = CDbl(R.AMOUNTINSURED)
                .CreditTerm = R.CREDITTERM 'FindEnumValueByName(GetType(EnumCreditTerm), "Enum_" + R.CREDITTERM)
                .Currency = CreateSAPCustomerDAL.FindEnumValueByName(GetType(CreateSAPCustomerDAL.EnumCurrency), "Enum_" + R.CURRENCY)
                .CustomerGroup = CreateSAPCustomerDAL.EnumCustomerGroup.Enum_02
                .InsurePolicyNumber = ""
                .PlanningGroup = CreateSAPCustomerDAL.EnumPlanningGroup.Enum_R1
                '.RecAccount = CreateSAPCustomerDAL.GetReconciliationAccount(objGeneralData.SalesOffice) 'EnumReconciliationAccount.Enum_0000121005
                .RecAccount = CreateSAPCustomerDAL.GetReconciliationAccount(salesofficecode) 'EnumReconciliationAccount.Enum_0000121005
                .SalesDistrict = CreateSAPCustomerDAL.GetSalesDistrictByCountry([Enum].Parse(GetType(CreateSAPCustomerDAL.EnumCountryCode), Integer.Parse(R.SHIPTOCOUNTRY)))
                'GetSalesDistrictByCountry(Integer.Parse(R.SHIPTOCOUNTRY))
                'GetSalesDistrictByCountry(FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + R.SHIPTOCOUNTRY)) 'EnumSalesDistrict.Enum_E06
                '.ShippingCondition = FindEnumValueByName(GetType(EnumShippingCondition), "Enum_" + R.SHIPPINGCONDITION)
                .ShippingCondition = R.SHIPPINGCONDITION
            End With
            'CreateSAPCustomer(objShiptoGeneralData, objShiptoCreditData)
        End If
        'end ship-to'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

        If Not String.IsNullOrEmpty(tempShiptoErpid) Then
            objShiptoGeneralData.CompanyId = tempShiptoErpid
            CreateSAPCustomerDAL.CreateSAPCustomer(objShiptoGeneralData, objShiptoCreditData)
            'A.UpdateErpID(tempBilltoErpid, tempShiptoErpid, ApplicationId)
        End If



    End Sub
End Class
