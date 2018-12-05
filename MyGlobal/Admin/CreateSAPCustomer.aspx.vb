Imports CreateSAPCustomerDAL
Imports CreateSAPCustomer
Imports System.IO

Partial Class Admin_CreateSAPCustomer
    Inherits System.Web.UI.Page

    Dim directDeviceVisited As Boolean
    Public Function PageMethod_CreateCustomer(Optional ByVal IsCreate As Boolean = False) As Boolean
        Dim Errorstr As String = ""
        Dim ws As New CreateSAPCustomerDAL
        'ws.url = "http://localhost:3004/MyGlobal2/services/CreateSAPCustomerDAL.asmx?wsdl"
        Dim ds As New DataSet
        '''''''
        Dim dt As GetAllDataTable = ws.GetApplicationDT()
        Dim R As GetAllRow = dt.NewGetAllRow()
        With R
            .ROW_ID = Guid.NewGuid().ToString()
            .STATUS = 0

            If Me.dlOPCode.SelectedValue.Equals("TBD") Then
                .OPCODE = ""
            Else
                .OPCODE = dlOPCode.SelectedValue
            End If

            .REQUEST_DATE = Date.Now()
            .CREDITDATA_ROW_ID = Guid.NewGuid().ToString()
            .GENERALDATA_ROW_ID = Guid.NewGuid().ToString()
            .HASCREDITDATA = IIf(rblFillCredit.SelectedIndex = 1, True, False)
            .HASSHIPTODATA = IIf(rblHasShipto.SelectedIndex = 1, True, False)
            .HASBILLINGDATA = IIf(rblHasBilling.SelectedIndex = 1, True, False)
            .REQUEST_BY = Session("user_id")
            .LAST_UPD_BY = Session("user_id")
            .ISEXIST = IIf(RBIsExist.SelectedIndex = 0, True, False)
            .COMPANYID = T(txtCompanyId.Text)
            .ADDRESS = T(txtAddr1.Text + "|" + txtAddr2.Text + "|" + txtAddr3.Text)
            .CITY = T(txtCity.Text)
            .COMPANYNAME = T(txtCompanyName.Text)
            .LEGALFORM = T(txtLegalForm.Text)
            .CONTACTPERSONEMAIL = T(txtContactEmail.Text)
            .CONTACTPERSONNAME = T(txtContactName.Text)
            .COUNTRYCODE = T(dlCountry.SelectedValue)
            .COUNTRYCODE_X = ""
            .CUSTOMERTYPE = T(dlCustomerType.SelectedValue)
            .FAXNUMBER = T(txtFax.Text)
            .INCOTERM1 = T(dlInco1.SelectedItem.Text)
            .INCOTERM2 = T(txtInco2.Text)
            .INSIDESALESCODE = T(dlISCode.SelectedValue)
            .POSTCODE = T(txtPostCode.Text)
            .SALESCODE = T(dlSalesCode.SelectedValue)
            .SALESGROUP = T(dlCustomerType.SelectedValue)
            .SALESOFFICE = T(dlSalesOffice.SelectedValue)
            .TELNUMBER = T(txtTel.Text)
            .VATNUMBER = T(txtVAT.Text)
            .VERTICALMARKET = T(dlVM.SelectedValue)
            .CONTACTPERSON_FA = T(TBCONTACTPERSON_FA.Text)
            .TELEPHONE_FA = T(TBTELEPHONE_FA.Text)
            .EMAIL_FA = T(TBEMAIL_FA.Text)
            .APLICATIONNO = ws.GetApplicationNO(Request("ApplicationID"))

            ' Ryan 20160606 Add new fields per Ruud's request
            .REGISTRATION_NUMBER = IIf(String.IsNullOrEmpty(T(txtRegistrationNo.Text)), "", T(txtRegistrationNo.Text))
            .FORM = IIf(String.IsNullOrEmpty(RB_form.SelectedItem.Text), "", RB_form.SelectedItem.Text)
            .NEED_DIGITALINVOICE = IIf(RB_DigitalInvoice.SelectedValue = 1, True, False)
            .INVOICE_EMAIL = IIf(String.IsNullOrEmpty(txtInvoiceEmail.Text), "", txtInvoiceEmail.Text)

            If dlVM.SelectedIndex = 0 Then .VERTICALMARKET = EnumVerticalMarket.Enum_NONE
            .WEBSITEURL = T(txtWebsiteUrl.Text)
            .AMOUNTINSURED = 0
            If Double.TryParse(txtAmtInsured.Text, 0) Then .AMOUNTINSURED = CDbl(txtAmtInsured.Text)
            If T(TBdlPayTerm.Text) = "" Then .CREDITTERM = "PPD" Else .CREDITTERM = T(TBdlPayTerm.Text)
            .INSUREPOLICYNUMBER = T(TBCreditLimit.Text)
            .CURRENCY = T(dlCurr.SelectedItem.Text)
            .SHIPPINGCONDITION = T(dlShipCond.SelectedItem.Value)
            If rblHasShipto.SelectedIndex = 1 Then
                .SHIPTOCOMPANYNAME = T(txtShiptoCompanyName.Text)
                .SHIPTOVATNUMBER = T(txtShiptoVATNumber.Text)
                .SHIPTOADDRESS = T(txtShiptoAddress.Text + "|" + txtShiptoAddress2.Text + "|" + txtShiptoAddress3.Text) 'T(txtShiptoAddress.Text) 
                .SHIPTOPOSTCODE = T(txtShiptoPostcode.Text)
                .SHIPTOCITY = T(txtShiptoCity.Text)
                .SHIPTOCOUNTRY = T(dlShiptoCountry.SelectedValue)
                .SHIPTOCOUNTRY_X = ""
                .SHIPTOTEL = T(txtShiptoTel.Text)
                .SHIPTOFAX = T(txtShiptoFax.Text)
                .SHIPTOCONTACTNAME = T(txtShiptoContactName.Text)
                .SHIPTOCONTACTEMAIL = T(txtShiptoContactEmail.Text)
            End If
            If rblHasBilling.SelectedIndex = 1 Then
                .BILLINGCOMPANYNAME = T(txtBillingCompanyName.Text)
                .BILLINGVATNUMBER = T(txtBillingVATNumber.Text)
                .BILLINGADDRESS = T(txtBillingAddress.Text + "|" + txtBillingAddress2.Text + "|" + txtBillingAddress3.Text) ' T(txtBillingAddress.Text)
                .BILLINGPOSTCODE = T(txtBillingPostcode.Text)
                .BILLINGCITY = T(txtBillingCity.Text)
                .BILLINGCOUNTRY = T(dlBillingCountry.SelectedValue)
                .BILLINGCOUNTRY_X = ""
                .BILLINGTEL = T(txtBillingTel.Text)
                .BILLINGFAX = T(txtBillingFax.Text)
                .BILLINGCONTACTNAME = T(txtBillingContactName.Text)
                .BILLINGCONTACTEMAIL = T(txtBillingContactEmail.Text)
            End If
        End With
        dt.Rows.Add(R)
        dt.AcceptChanges()
        '''''''
        ds.Tables.Add(dt)
        ds.AcceptChanges()
        Dim AppID As String = ""
        If Request("ApplicationID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("ApplicationID")) Then
            AppID = Trim(Request("ApplicationID").ToString)
        End If
        Dim ApplicationID As String = ws.CreateSAPCustomerForeStore(dt, AppID, IsCreate, Errorstr)
        If Not String.IsNullOrEmpty(Errorstr) Then
            lbDoneMsg.Text = Errorstr
            Return False
            Exit Function
        Else
            Dim siebelAccountID As String = String.Empty
            Dim estoreorderid As String = String.Empty

            If Not String.IsNullOrEmpty(TBsiebelAccountID.Text.Trim) Then
                siebelAccountID = TBsiebelAccountID.Text.Trim
            End If
            If Request("estoreorderid") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("estoreorderid").ToString.Trim) Then
                estoreorderid = Request("estoreorderid").ToString.Trim
            End If
            If Not String.IsNullOrEmpty(siebelAccountID) OrElse Not String.IsNullOrEmpty(estoreorderid) Then
                Dim A As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_APPLICATION_ExtendTableAdapter
                A.DeleteApplicationID(ApplicationID)
                Dim TobackURL As String = String.Empty
                If Request("callurl") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("callurl").ToString.Trim) Then
                    TobackURL = Request("callurl").ToString.Trim
                End If
                A.Insert(ApplicationID, TBsiebelAccountID.Text.Trim, estoreorderid, TobackURL)
                If Not String.IsNullOrEmpty(siebelAccountID) Then
                    Dim SB As New StringBuilder
                    SB.AppendFormat(" DELETE FROM [SAPCUSTOMER_LOG] WHERE [ApplicationID]='{0}' ;", ApplicationID)
                    SB.AppendFormat(" INSERT INTO [SAPCUSTOMER_LOG] ([ApplicationID] ,[IsHaveSeibelAccountRowID] ,[CreatedDate]) ")
                    SB.AppendFormat(" values ('{0}','{1}',GETDATE()) ", ApplicationID, siebelAccountID)
                    dbUtil.dbExecuteNoQuery("MYLOCAL", SB.ToString())
                End If
            End If
            If Request("ApplicationID") Is Nothing OrElse IsCreate = False Then
                SendEmail(ApplicationID, -1)
                SendEmail(ApplicationID, 0)
            End If
            'btnSubmit1.Enabled = False
            'btnSubmit2.Enabled = False
            'btnSubmit3.Enabled = False
            'btnSubmit4.Enabled = False
            'lbDoneMsg.Text = txtCompanyId.Text + "  Your data is being processed, thank you." : lbERPIDMsg.Text = "" : lbDebugMsg.Text = ""
        End If
        Return True
    End Function
    Public Shared Function IsAdmin() As Boolean
        'If Util.IsAEUIT() Then
        '    Return False
        'End If 
        If Util.IsAEUIT() OrElse
             MailUtil.IsInMailGroup("FINANCE.AEU", HttpContext.Current.User.Identity.Name) OrElse
             HttpContext.Current.User.Identity.Name.Equals("Sigrid.Donkers@advantech.nl", StringComparison.OrdinalIgnoreCase) OrElse
             HttpContext.Current.User.Identity.Name.Equals("bahar.nasserie@advantech.nl", StringComparison.OrdinalIgnoreCase) OrElse
             HttpContext.Current.User.Identity.Name.Equals("Carla.Scholten@advantech.nl", StringComparison.OrdinalIgnoreCase) OrElse
             HttpContext.Current.User.Identity.Name.Equals("Peter.Thijssens@advantech.nl", StringComparison.OrdinalIgnoreCase) OrElse
             HttpContext.Current.User.Identity.Name.Equals("Tamiem.Shierzada@advantech.nl", StringComparison.OrdinalIgnoreCase) OrElse
             HttpContext.Current.User.Identity.Name.Equals("Hannelore.Willemsen@advantech.nl", StringComparison.OrdinalIgnoreCase) Then
            '2015/2/10 Add Tamiem Shierzada. This request is from Michael. By IC
            'Ryan 20170705 Add Sigrid.Donkers@advantech.nl
            Return True
        End If
        Return False
    End Function
    Protected Sub Lab_CreateSAPCustomer_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            directDeviceVisited = False
            'If Session("ORG_ID") Is Nothing OrElse Session("ORG_ID").ToString.ToUpper <> "EU10" Then
            '    Response.Redirect("~/home.aspx") : Exit Sub
            'End If
            'If Request("ApplicationID") IsNot Nothing AndAlso Request("ApplicationID").Trim.StartsWith("TN") Then
            '    Dim A As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_GENERALDATATableAdapter
            '    Dim dt As DataTable = A.selectByApplicationNO(Request("ApplicationID"))
            '    If dt.Rows.Count > 0 Then
            '        Dim ApplicationID As String = dt.Rows(0).Item("ApplicationID").ToString().Trim
            '        Response.Redirect(String.Format("CreateSAPCustomer.aspx?ApplicationID={0}", ApplicationID))
            '        Response.End()
            '    End If
            'End If
            If IsAdmin() AndAlso Request("ApplicationID") IsNot Nothing Then
                ApproveDIV.Visible = True
            End If
            If Request("estoreorderid") IsNot Nothing Then
                ApproveDIV.Visible = False
            End If
            'Response.Write("find value:" + FindEnumValueByName(GetType(EnumCreditTerm), "Enum_15D5").ToString() + "@@@")
            Dim Names() As String = [Enum].GetNames(GetType(EnumCountryCode))
            Dim Values() As Integer = [Enum].GetValues(GetType(EnumCountryCode))
            Dim dtCountry As DataTable = dbUtil.dbGetDataTable("MY", "select distinct COUNTRY, isnull(country_name,'') as  country_name  from SAP_DIMCOMPANY WHERE  country_name IS NOT NULL  order by COUNTRY")
            If dtCountry.Select("COUNTRY='XK'").Length = 0 Then
                Dim xkRow As DataRow = dtCountry.NewRow()
                xkRow.Item("COUNTRY") = "XK" : xkRow.Item("country_name") = "Kosovo"
                dtCountry.Rows.Add(xkRow)
            End If
            If dtCountry.Select("COUNTRY='PS'").Length = 0 Then
                Dim xkRow As DataRow = dtCountry.NewRow()
                xkRow.Item("COUNTRY") = "PS" : xkRow.Item("country_name") = "Palestina"
                dtCountry.Rows.Add(xkRow)
            End If
            dtCountry.AcceptChanges()
            For i As Integer = 0 To Names.Length - 1
                Dim drs() As DataRow = dtCountry.Select("COUNTRY = '" + Names(i).Substring(5).Trim + "'")
                If drs.Length > 0 Then
                    dlCountry.Items.Add(New ListItem(Names(i).Substring(5) + " - " + drs(0).Item("country_name"), Values(i).ToString()))
                    dlShiptoCountry.Items.Add(New ListItem(Names(i).Substring(5) + " - " + drs(0).Item("country_name"), Values(i).ToString()))
                Else
                    If String.Equals(Names(i).Substring(5), "AD", StringComparison.CurrentCultureIgnoreCase) Then
                        dlCountry.Items.Add(New ListItem(Names(i).Substring(5) + " - Andorra", Values(i).ToString()))
                        dlShiptoCountry.Items.Add(New ListItem(Names(i).Substring(5) + " - Andorra", Values(i).ToString()))
                    Else
                        dlCountry.Items.Add(New ListItem(Names(i).Substring(5), Values(i).ToString()))
                        dlShiptoCountry.Items.Add(New ListItem(Names(i).Substring(5), Values(i).ToString()))
                    End If
                End If
                ' dlShiptoCountry.Items.Add(New ListItem(Names(i).Substring(5), Values(i).ToString()))
                dlBillingCountry.Items.Add(New ListItem(Names(i).Substring(5), Values(i).ToString()))
            Next
            Names = [Enum].GetNames(GetType(EnumIncoTerm)) : Values = [Enum].GetValues(GetType(EnumIncoTerm))
            For i As Integer = 0 To Names.Length - 1
                dlInco1.Items.Add(New ListItem(Names(i).Substring(5), Values(i).ToString()))
            Next
            SetDropDownList(dlInco1, "0")
            'Names = [Enum].GetNames(GetType(EnumCreditTerm)) : Values = [Enum].GetValues(GetType(EnumCreditTerm))
            'For i As Integer = 0 To Names.Length - 1
            '    dlPayTerm.Items.Add(New ListItem(Names(i).Substring(5), Values(i).ToString()))
            'Next
            'For Each item As ListItem In dlPayTerm.Items
            '    If item.Text = "PPD" Then
            '        item.Selected = True
            '    End If
            'Next
            Names = [Enum].GetNames(GetType(EnumShippingCondition)) : Values = [Enum].GetValues(GetType(EnumShippingCondition))
            For i As Integer = 0 To Names.Length - 1
                ' dlShipCond.Items.Add(New ListItem(Names(i).Substring(5), Values(i).ToString()))
                dlShipCond.Items.Add(New ListItem(Glob.shipCode2Txt(Names(i).Substring(5)), Names(i).Substring(5)))
            Next
            SetDropDownList(dlShipCond, "09")
            Dim EusalesCodeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct b.FULL_NAME, b.SALES_CODE from  SAP_EMPLOYEE b left join  SAP_COMPANY_EMPLOYEE a on a.SALES_CODE=b.SALES_CODE where (a.SALES_ORG like 'EU%' and  a.PARTNER_FUNCTION='VE' ) or (b.PERS_AREA like 'EU%' and a.SALES_ORG is null)  order by b.FULL_NAME  ")
            Dim EuISOPCodeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct b.FULL_NAME, b.SALES_CODE from  SAP_EMPLOYEE b left join  SAP_COMPANY_EMPLOYEE a on a.SALES_CODE=b.SALES_CODE where (a.SALES_ORG like 'EU%' and  a.PARTNER_FUNCTION<>'VE' ) or (b.PERS_AREA like 'EU%' and a.SALES_ORG is null)  order by b.SALES_CODE  ")
            Dim query As IEnumerable(Of DataRow) = EusalesCodeDt.AsEnumerable().Union(EuISOPCodeDt.AsEnumerable(), DataRowComparer.Default)
            Dim dtall As DataTable = query.CopyToDataTable()
            EusalesCodeDt = dtall
            EuISOPCodeDt = dtall
            For Each salesRow As DataRow In EusalesCodeDt.Rows
                dlSalesCode.Items.Add(New ListItem(String.Format("{0} ({1})", salesRow.Item("FULL_NAME"), salesRow.Item("SALES_CODE")), salesRow.Item("SALES_CODE")))
            Next
            For Each ISOPRow As DataRow In EuISOPCodeDt.Rows
                dlISCode.Items.Add(New ListItem(String.Format("{0} ({1})", ISOPRow.Item("FULL_NAME"), ISOPRow.Item("SALES_CODE")), ISOPRow.Item("SALES_CODE")))
                Dim OPList As New ArrayList
                With OPList
                    'Ryan 20160912 Add below two person per Erika Mol's request
                    '.Add("39050003") : .Add("39050005")
                    '.Add("39050019") : .Add("39050015") : .Add("39050023") : .Add("39050027")
                    '.Add("39050032")

                    'Ryan 20160503 Hide items
                    '.Add("39050013") : .Add("39050018") : .Add("39050020") : .Add("31010004") : .Add("31010005")

                    'ICC 2016/2/24 Add Monika Panteva's sales code
                    '.Add("39050021") : .Add("39050018") : .Add("39050016") : .Add("39050017") : .Add("39050015") : .Add("39050019") : .Add("39050020") 'ICC 2015/2/4 Add more OPs from Michael. 2015/2/6 Remove from Louis
                    '.Add("39050007").Add("39050006") :.Add("39050012") :: .Add("39050003")

                    Dim dtOP As DataTable = dbUtil.dbGetDataTable("MY", "select distinct SalesCode from AEU_OPMapping order by SalesCode")
                    If dtOP IsNot Nothing AndAlso dtOP.Rows.Count > 0 Then
                        For Each drOP As DataRow In dtOP.Rows
                            .Add(drOP("SalesCode").ToString)
                        Next
                    End If
                End With
                'ICC 2014/10/1 Add O.P. INNO GPEG in the dropdownlist
                If OPList.Contains(ISOPRow.Item("SALES_CODE")) Then
                    'If ISOPRow.Item("SALES_CODE").ToString.Trim = "39050013" Then
                    ' dlOPCode.Items.Add(New ListItem(String.Format("{0} ({1})", "O.P. INNO GPEG", ISOPRow.Item("SALES_CODE")), ISOPRow.Item("SALES_CODE")))
                    'Else
                    dlOPCode.Items.Add(New ListItem(String.Format("{0} ({1})", ISOPRow.Item("FULL_NAME"), ISOPRow.Item("SALES_CODE")), ISOPRow.Item("SALES_CODE")))
                    'End If
                End If
            Next
            ''ming add
            If Request("ApplicationID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("ApplicationID")) Then
                Dim ApplicationID As String = Trim(Request("ApplicationID").ToString)
                Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
                Dim dt As New CreateSAPCustomer.GetAllDataTable
                dt = A.GetDataByApplicationID(ApplicationID)
                Dim dr As CreateSAPCustomer.GetAllRow = dt.Rows(0)
                With dr
                    Dim objGeneralData As New SAPCustomerGeneralData, objCreditData As New SAPCustomerCreditData
                    If .ADDRESS.Contains("|") Then
                        Dim p() As String = Split(.ADDRESS, "|")
                        txtAddr1.Text = p(0) : txtAddr2.Text = p(1)
                        If p.Length >= 3 Then
                            txtAddr3.Text = p(2)
                        End If
                    Else
                        txtAddr1.Text = .ADDRESS
                    End If
                    txtCity.Text = .CITY : txtCompanyId.Text = .COMPANYID : txtCompanyName.Text = .COMPANYNAME
                    ' .COMPANYTYPE = EnumCompanyType.Enum_Z001
                    Dim AG As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_GENERALDATATableAdapter
                    Dim dtAG As DataTable = AG.selectByApplicationID(Trim(Request("ApplicationID").ToString))
                    If dtAG.Rows.Count > 0 Then
                        Dim B As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_APPLICATION_ExtendTableAdapter
                        Dim dt2 As DataTable = B.selectbyApplicationID(Trim(Request("ApplicationID").ToString))
                        If dt2.Rows.Count > 0 Then
                            TBsiebelAccountID.Text = dt2.Rows(0).Item("SIEBELROWID").ToString().Trim
                        End If
                    End If
                    txtLegalForm.Text = .LEGALFORM
                    txtContactEmail.Text = .CONTACTPERSONEMAIL : txtContactName.Text = .CONTACTPERSONNAME
                    SetDropDownList(dlCountry, .COUNTRYCODE)
                    SetDropDownList(dlCustomerType, .CUSTOMERTYPE)
                    txtFax.Text = .FAXNUMBER
                    '.INCOTERM1 = FindEnumValueByName(GetType(EnumIncoTerm), "Enum_" + dlInco1.SelectedItem.Text)
                    SetDropDownList(dlInco1, .INCOTERM1)
                    txtInco2.Text = .INCOTERM2
                    txtPostCode.Text = .POSTCODE
                    SetDropDownList(dlCustomerType, .SALESGROUP)
                    SetDropDownList(dlSalesOffice, .SALESOFFICE)
                    txtTel.Text = .TELNUMBER : txtVAT.Text = .VATNUMBER
                    SetDropDownList(dlVM, IIf(.VERTICALMARKET = "-1", "NONE", .VERTICALMARKET))
                    ' If dlVM.SelectedIndex = 0 Then .VERTICALMARKET = EnumVerticalMarket.Enum_NONE
                    txtWebsiteUrl.Text = .WEBSITEURL
                    ''
                    txtAmtInsured.Text = .AMOUNTINSURED
                    TBCONTACTPERSON_FA.Text = .CONTACTPERSON_FA
                    TBTELEPHONE_FA.Text = .TELEPHONE_FA
                    TBEMAIL_FA.Text = .EMAIL_FA
                    '.CREDITTERM = FindEnumValueByName(GetType(EnumCreditTerm), "Enum_" + dlPayTerm.SelectedItem.Text)
                    'SetDropDownList(dlPayTerm, .CREDITTERM)
                    TBCreditLimit.Text = .INSUREPOLICYNUMBER
                    TBdlPayTerm.Text = .CREDITTERM
                    SetDropDownList(dlCurr, [Enum].GetName(GetType(EnumCurrency), Int32.Parse(.CURRENCY)).ToString.Replace("Enum_", ""))
                    SetDropDownList(dlShipCond, .SHIPPINGCONDITION)
                    'txtShiptoAddress.Text = .SHIPTOADDRESS

                    If .SHIPTOADDRESS.Contains("|") Then
                        Dim p() As String = Split(.SHIPTOADDRESS, "|")
                        txtShiptoAddress.Text = p(0) : txtShiptoAddress2.Text = p(1)
                        If p.Length >= 3 Then
                            txtShiptoAddress3.Text = p(2)
                        End If
                    Else
                        txtShiptoAddress.Text = .SHIPTOADDRESS
                    End If
                    txtShiptoCity.Text = .SHIPTOCITY
                    txtShiptoCompanyName.Text = .SHIPTOCOMPANYNAME
                    txtShiptoContactEmail.Text = .SHIPTOCONTACTEMAIL
                    txtShiptoContactName.Text = .SHIPTOCONTACTNAME
                    SetDropDownList(dlShiptoCountry, .SHIPTOCOUNTRY)
                    txtShiptoFax.Text = .SHIPTOFAX
                    txtShiptoPostcode.Text = .SHIPTOPOSTCODE
                    txtShiptoTel.Text = .SHIPTOTEL
                    txtShiptoVATNumber.Text = .SHIPTOVATNUMBER
                    ' set Billing 
                    ' txtBillingAddress.Text = .BILLINGADDRESS

                    'Ryan 20160615
                    txtRegistrationNo.Text = .REGISTRATION_NUMBER
                    RB_form.Items.FindByText(.FORM).Selected = True
                    If .NEED_DIGITALINVOICE.Equals("True", StringComparison.OrdinalIgnoreCase) Then
                        RB_DigitalInvoice.Items.FindByValue("1").Selected = True
                    Else
                        RB_DigitalInvoice.Items.FindByValue("0").Selected = True
                    End If
                    txtInvoiceEmail.Text = .INVOICE_EMAIL

                    If .BILLINGADDRESS.Contains("|") Then
                        Dim p() As String = Split(.BILLINGADDRESS, "|")
                        txtBillingAddress.Text = p(0) : txtBillingAddress2.Text = p(1)
                        If p.Length >= 3 Then
                            txtBillingAddress3.Text = p(2)
                        End If
                    Else
                        txtBillingAddress.Text = .BILLINGADDRESS
                    End If



                    txtBillingCity.Text = .BILLINGCITY
                    txtBillingCompanyName.Text = .BILLINGCOMPANYNAME
                    txtBillingContactEmail.Text = .BILLINGCONTACTEMAIL
                    txtBillingContactName.Text = .BILLINGCONTACTNAME
                    SetDropDownList(dlBillingCountry, .BILLINGCOUNTRY)
                    txtBillingFax.Text = .BILLINGFAX
                    txtBillingPostcode.Text = .BILLINGPOSTCODE
                    txtBillingTel.Text = .BILLINGTEL
                    txtBillingVATNumber.Text = .BILLINGVATNUMBER
                    'end
                    SetDropDownList(dlSalesCode, .SALESCODE)
                    SetDropDownList(dlISCode, .INSIDESALESCODE)
                    SetDropDownList(dlOPCode, IIf(IsDBNull(.OPCODE), "", .OPCODE.ToString))
                    If Boolean.Parse(.HASCREDITDATA) Then
                        rblFillCredit.SelectedIndex = 1 : btnGo2Credit.Visible = True
                    Else
                        btnGo2Credit.Visible = False
                    End If
                    If Boolean.Parse(.HASSHIPTODATA) Then rblHasShipto.SelectedIndex = 1 : btnGo2Shipto.Visible = True
                    If Boolean.Parse(.HASBILLINGDATA) Then rblHasBilling.SelectedIndex = 1 : btnGo2Billing.Visible = True
                    If .STATUS.ToString.Trim <> "0" Then
                        btnSubmit1.Visible = False : btnSubmit1.Text = "Modify"
                        btnSubmit2.Visible = False : btnSubmit2.Text = "Modify"
                        btnSubmit3.Visible = False : btnSubmit3.Text = "Modify"
                        btnSubmit4.Visible = False : btnSubmit4.Text = "Modify"
                        BtApprove.Enabled = False
                        BtReject.Enabled = False
                    End If
                    If .STATUS.ToString.Trim = "2" Then
                        If HttpContext.Current.User.Identity.Name.Equals(dr.REQUEST_BY, StringComparison.OrdinalIgnoreCase) Then
                            btnSubmit1.Visible = True
                            btnSubmit2.Visible = True
                            btnSubmit3.Visible = True
                            btnSubmit4.Visible = True
                            BtApprove.Enabled = False
                            BtReject.Enabled = False
                        End If
                        If IsAdmin() Then
                            BtApprove.Enabled = True
                            BtReject.Enabled = True
                        End If
                    End If
                    TBComment.Text = .COMMENT.Trim
                    If Boolean.Parse(.ISEXIST) = False Then
                        hid1.Value = 0
                        txtCompanyId2.Text = IIf(IsDBNull(.COMPANYID), "", .COMPANYID)
                    Else
                        hid1.Value = 1
                    End If
                End With
                ''ming end
            End If
        End If
        TBCompanyId.Visible = True
        If RBIsExist.SelectedValue = "0" Then
            TBCompanyId.Visible = False
        Else
        End If
        If IsAdmin() AndAlso Request("ApplicationID") IsNot Nothing Then
            RBIsExist.Enabled = False
            BtChecksiebel.Enabled = False
            btnSubmit1.Visible = False
            btnSubmit2.Visible = False
            btnSubmit3.Visible = False
            btnSubmit4.Visible = False
            If hid1.Value = 0 Then
                RBIsExist.SelectedIndex = 1
                TBCompanyId.Visible = False : BTcheck.Visible = False
            ElseIf hid1.Value = 1 Then
                RBIsExist.SelectedIndex = 0
                TBCompanyId.Visible = True : BTcheck.Visible = False : TBCompanyId2.Visible = False
            End If
        End If
        If Request("estoreorderid") IsNot Nothing Then
            RBIsExist.Enabled = True
            BtChecksiebel.Enabled = True
            btnSubmit1.Visible = True
            btnSubmit2.Visible = True
            btnSubmit3.Visible = True
            btnSubmit4.Visible = True
        End If
        If Session("user_id") IsNot Nothing AndAlso Session("user_id").ToString = "YL.Huang@advantech.com.tw" Then
            BtApprove.Enabled = True
        End If

        If String.IsNullOrEmpty(RB_form.SelectedValue) Then
            RB_form.Items.FindByValue("0").Selected = True
        End If
        If String.IsNullOrEmpty(RB_DigitalInvoice.SelectedValue) Then
            RB_DigitalInvoice.Items.FindByValue("0").Selected = True
        End If

    End Sub
    Public Shared Function T(str As Object) As String
        Try
            Return str.ToString.Trim.ToUpper
        Catch ex As Exception
            Return ""
        End Try
    End Function

    ''' <summary>
    ''' Handles the Click event of the btnGo2Credit control. Will activate the panel for credit data input.
    ''' </summary>
    ''' <param name="sender">The source of the event.</param>
    ''' <param name="e">The <see cref="System.EventArgs" /> instance containing the event data.</param>
    Protected Sub btnGo2Credit_Click(sender As Object, e As System.EventArgs) Handles btnGo2Credit.Click, btn2General4.Click
        'mv1.ActiveViewIndex = 4 'Device info
        lbDoneMsg.Text = Nothing
        mv1.ActiveViewIndex = 1 'Credit Data
    End Sub

    Protected Sub btn2General_Click(sender As Object, e As System.EventArgs) Handles btn2General.Click, btn2General2.Click, btn2General3.Click
        mv1.ActiveViewIndex = 0
    End Sub

    ''' <summary>
    ''' When clicked the webpage will go to the panel with the www.directdevice.info in it. It will registrate that 
    ''' the user has clicked the link.
    ''' </summary>
    ''' <param name="sender">The sender.</param>
    ''' <param name="e">The <see cref="System.EventArgs" /> instance containing the event data.</param>
    Protected Sub btnGoDirectDevice(sender As Object, e As System.EventArgs) _
        Handles lnkDeviceInfo.Click
        '' Visitor visits the direct device
        directDeviceVisited = True
        '' set the active panel.
        mv1.ActiveViewIndex = 4
    End Sub


    Function ValidateInputData(Optional IsVaildateExist As Boolean = True) As Boolean
        lbDoneMsg2.Text = ""
        'If Request("ApplicationID") IsNot Nothing Then
        '    If CreateSAPCustomerDAL.GetApplicationStatus(Request("ApplicationID").ToString) <> "2" Then

        '    End If

        'End If
        If (rblFillCredit.SelectedValue = "YES") Then
            If Not directDeviceVisited Then
                lbDoneMsg.Text = "You did not visit www.directdevice.info while you stated that Credit data should be filled" : Return False
            End If
        End If
        If RBIsExist.SelectedValue = "1" Then
            txtCompanyId.Text = UCase(Trim(txtCompanyId.Text))
            If IsVaildateExist Then
                If CreateSAPCustomerDAL.IsERPIDExist(txtCompanyId.Text) Then
                    If Request("ApplicationID") IsNot Nothing Then
                        lbDoneMsg2.Text = "Company id " + txtCompanyId.Text + " already exists in SAP"
                    Else
                        lbDoneMsg.Text = "Company id " + txtCompanyId.Text + " already exists in SAP"
                    End If
                    Return False
                End If
            End If
        Else
            'If String.IsNullOrEmpty(txtWebsiteUrl.Text.Trim) Then
            '    lbDoneMsg.Text = "General data is not complete. Website cannot be empty" : Return False
            'End If

        End If
        'If String.IsNullOrEmpty(TBCONTACTPERSON_FA.Text.Trim) Then
        '    lbDoneMsg.Text = "Contact Person Finance & Acounting dept cannot be empty" : mv1.ActiveViewIndex = 1 : Return False
        'End If
        'If String.IsNullOrEmpty(TBTELEPHONE_FA.Text.Trim) Then
        '    lbDoneMsg.Text = "Telephone Finance & Acounting dept cannot be empty" : mv1.ActiveViewIndex = 1 : Return False
        'End If
        'If String.IsNullOrEmpty(TBEMAIL_FA.Text.Trim) Then
        '    lbDoneMsg.Text = "Email Finance & Acounting dept cannot be empty" : mv1.ActiveViewIndex = 1 : Return False
        'End If
        If String.IsNullOrEmpty(txtCompanyName.Text) Or String.IsNullOrEmpty(txtVAT.Text) Or String.IsNullOrEmpty(txtAddr1.Text) _
            Or String.IsNullOrEmpty(txtCity.Text) Or String.IsNullOrEmpty(txtRegistrationNo.Text) Then
            lbDoneMsg.Text = "General data is not complete. Name/Registration Number/VAT/Address/City are all mandatory." : Return False
        End If

        If txtCompanyName.Text.Trim.Length <= 2 Then
            lbDoneMsg.Text = "General data Company Name must be greater than 2 characters" : Return False
        ElseIf txtCompanyName.Text.Trim.Length > 40 Then
            lbDoneMsg.Text = "General data Company Name cannot exceed 40 characters" : Return False
        End If

        If Not String.IsNullOrEmpty(txtPostCode.Text.Trim) Then
            If txtPostCode.Text.Trim.Length > 10 Then
                lbDoneMsg.Text = "Postal Code cannot exceed 10 characters" : Return False
            End If
        End If
        If Not String.IsNullOrEmpty(txtTel.Text.Trim) Then
            If txtTel.Text.Trim.Length > 100 Then
                lbDoneMsg.Text = "Telephone cannot exceed 100 characters" : Return False
            End If
        End If
        If rblHasShipto.SelectedIndex = 1 Then

            If txtShiptoCompanyName.Text.Trim.Length <= 2 Then
                lbDoneMsg.Text = "ShipTo company name must be greater than 2 characters" : Return False
            ElseIf txtShiptoCompanyName.Text.Trim.Length > 40 Then
                lbDoneMsg.Text = "ShipTo company name cannot exceed 40 characters" : Return False
            End If

            If Not String.IsNullOrEmpty(txtShiptoPostcode.Text.Trim) Then
                If txtShiptoPostcode.Text.Trim.Length > 10 Then
                    lbDoneMsg.Text = "ShipTo Postal Code cannot exceed 10 characters" : Return False
                End If
            End If
            'Ming fix bug for Contact Person Name
            If Not String.IsNullOrEmpty(txtShiptoContactName.Text.Trim) Then
                If txtShiptoContactName.Text.Trim.Length > 30 Then
                    lbDoneMsg.Text = "ShipTo Contact Person Name cannot exceed 30 characters" : Return False
                End If
            End If
            'end

            'Ryan 20160628 Add extra validation
            If Not String.IsNullOrEmpty(txtCity.Text.Trim) Then
                If txtCity.Text.Trim.Length > 35 Then
                    lbDoneMsg.Text = "Ship-to City cannot exceed 35 characters" : Return False
                End If
            End If
            If Not String.IsNullOrEmpty(txtShiptoAddress.Text.Trim) Then
                If txtShiptoAddress.Text.Trim.Length > 30 Then
                    lbDoneMsg.Text = "Ship-to Address1 cannot exceed 30 characters" : Return False
                End If
            End If
            If Not String.IsNullOrEmpty(txtShiptoAddress2.Text.Trim) Then
                If txtShiptoAddress2.Text.Trim.Length > 30 Then
                    lbDoneMsg.Text = "Ship-to Address2 cannot exceed 30 characters" : Return False
                End If
            End If
            If Not String.IsNullOrEmpty(txtShiptoAddress3.Text.Trim) Then
                If txtShiptoAddress3.Text.Trim.Length > 30 Then
                    lbDoneMsg.Text = "Ship-to Address3 cannot exceed 30 characters" : Return False
                End If
            End If
            If Not String.IsNullOrEmpty(txtShiptoTel.Text.Trim) Then
                If txtShiptoTel.Text.Trim.Length > 100 Then
                    lbDoneMsg.Text = "Ship-to Telephone cannot exceed 100 characters" : Return False
                End If
            End If
        End If
        If rblHasBilling.SelectedIndex = 1 Then
            If Not String.IsNullOrEmpty(txtBillingPostcode.Text.Trim) Then
                If txtBillingPostcode.Text.Trim.Length > 10 Then
                    lbDoneMsg.Text = "BillTo Postal Code cannot exceed 10 characters" : Return False
                End If
            End If
        End If
        If txtCity.Text.Trim.Length > 35 Then
            lbDoneMsg.Text = "General data City cannot exceed 35 characters" : Return False
        End If
        If txtAddr1.Text.Trim.Length > 30 Then
            lbDoneMsg.Text = "General data Address1 cannot exceed 30 characters" : Return False
        End If
        If txtAddr2.Text.Trim.Length > 30 Then
            lbDoneMsg.Text = "General data Address2 cannot exceed 30 characters" : Return False
        End If
        If txtAddr3.Text.Trim.Length > 30 Then
            lbDoneMsg.Text = "General data Address3 cannot exceed 30 characters" : Return False
        End If
        If txtInco2.Text.Trim.Length > 28 Then
            lbDoneMsg.Text = "Shipping Remarks cannot exceed 28 characters" : Return False
        End If
        If rblFillCredit.SelectedIndex = 1 Then
            'If dlPayTerm.SelectedIndex = 0 Then
            '    mv1.ActiveViewIndex = 1
            '    lbDoneMsg.Text = "Please select a payment term in Credit Data" : Return False
            'End If
            'If String.IsNullOrEmpty(TBdlPayTerm.Text.Trim) Then
            '    lbDoneMsg.Text = """Requested Payment Terms and Credit Limi"" cannot be empty" : mv1.ActiveViewIndex = 1 : Return False
            'End If
            'If TBdlPayTerm.Text.Trim.Length > 10 Then
            '    lbDoneMsg.Text = "Payment Terms cannot exceed 10 characters" : mv1.ActiveViewIndex = 1 : Return False
            'End If
        End If
        If rblHasShipto.SelectedIndex = 1 Then
            If String.IsNullOrEmpty(txtShiptoCompanyName.Text) Or String.IsNullOrEmpty(txtShiptoVATNumber.Text) _
                Or String.IsNullOrEmpty(txtShiptoAddress.Text) Or String.IsNullOrEmpty(txtShiptoCity.Text) Then
                mv1.ActiveViewIndex = 2
                lbDoneMsg.Text = "Ship-to data is not complete. Name/VAT/Address/City are all mandatory." : Return False
            End If
        End If

        'Ryan 20161005 Set Tel & Contact Person to required fields
        If RBIsExist.SelectedValue = "0" Then
            If String.IsNullOrEmpty(txtTel.Text) Or String.IsNullOrEmpty(txtContactName.Text) Then
                lbDoneMsg.Text = "General data is not complete. Telephone/ContactPerson are all mandatory." : Return False
            End If
        End If
        If rblHasShipto.SelectedIndex = 1 Then
            If String.IsNullOrEmpty(txtShiptoContactName.Text) Or String.IsNullOrEmpty(txtShiptoTel.Text) Then
                mv1.ActiveViewIndex = 2
                lbDoneMsg.Text = "Ship-to data is not complete. Telephone/ContactPerson are all mandatory." : Return False
            End If
        End If

        'Ryan 20161003 Validate if txtbox are regular string (only accept numbers and english alphabets and some distinct characters)
        '1. General Data Parts
        'If Not Util.IsRegularString(txtCompanyName.Text) OrElse Not Util.IsRegularString(txtAddr1.Text) _
        '    OrElse Not Util.IsRegularString(txtAddr2.Text) OrElse Not Util.IsRegularString(txtAddr3.Text) _
        '    OrElse Not Util.IsRegularString(txtCity.Text) OrElse Not Util.IsRegularString(txtContactName.Text) _
        '    OrElse Not Util.IsRegularString(txtInco2.Text) Then
        '    lbDoneMsg.Text = "Input fields in General Data can only be numbers and English alphabet letters." : Return False
        'End If

        '2. Ship-to Data Parts
        'If Not Util.IsRegularString(txtShiptoCompanyName.Text) OrElse Not Util.IsRegularString(txtShiptoAddress.Text) _
        '    OrElse Not Util.IsRegularString(txtShiptoAddress2.Text) OrElse Not Util.IsRegularString(txtShiptoAddress3.Text) _
        '    OrElse Not Util.IsRegularString(txtShiptoCity.Text) OrElse Not Util.IsRegularString(txtShiptoContactName.Text) Then
        '    mv1.ActiveViewIndex = 2
        '    lbDoneMsg.Text = "Input fields in Ship-to data can only be numbers and English alphabet letters." : Return False
        'End If
        Return True
    End Function

    Protected Sub btnCreate_Click(sender As Object, e As System.EventArgs)
        Dim btn As Button = CType(sender, Button)
        lbDoneMsg.Text = ""
        Dim IsCreate As Boolean = True
        If btn.ID.ToLower Like "btnsubmit*" Then
            If RBIsExist.SelectedIndex = 0 Then
                If rblHasShipto.SelectedIndex = 0 AndAlso rblHasBilling.SelectedIndex = 0 Then
                    lbDoneMsg.Text = "Select at least one Ship-to or  Billing"
                    Exit Sub
                End If
            End If
            IsCreate = False
        End If
        If ValidateInputData(False) Then
            If PageMethod_CreateCustomer(IsCreate) Then
                'SendEmail(ApplicationId, 0)
                btnSubmit1.Enabled = False
                btnSubmit2.Enabled = False
                btnSubmit3.Enabled = False
                btnSubmit4.Enabled = False
                Dim AlertStr As String = txtCompanyId.Text + " Your data is being processed, thank you."
                lbDoneMsg.Text = AlertStr : lbERPIDMsg.Text = "" : lbDebugMsg.Text = ""
                If Request("estoreorderid") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("estoreorderid").ToString.Trim) Then
                    Dim B As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_APPLICATION_ExtendTableAdapter
                    Dim dt2 As DataTable = B.selectbyApplicationID(Request("ApplicationID").ToString().Trim)
                    AlertStr = "Your new SAP account application is successfully submitted.  Once the application is approved, system will inform you via email."
                    If dt2.Rows.Count > 0 Then
                        Dim TOBACKURL As String = dt2.Rows(0).Item("TOBACKURL").ToString().Trim
                        If TOBACKURL.ToUpper.Contains("Orders/OrderDetailsAEU.aspx".ToUpper.Trim) Then
                            Util.AjaxJSAlertRedirect(Me.up1, AlertStr + "\n Click on ""OK"" to continue your activities at eStore OM. ", String.Format("{1}?OrderNo={0}", Request("estoreorderid").ToString.Trim, TOBACKURL))
                        Else
                            Util.AjaxJSAlertRedirect(Me.up1, AlertStr + "\n Click on ""OK"" to continue your activities at eStore OM. ", String.Format("{1}/Orders/OrderDetailsAEU.aspx?OrderNo={0}", Request("estoreorderid").ToString.Trim, TOBACKURL))
                        End If

                    Else
                        Util.AjaxJSAlertRedirect(Me.up1, AlertStr + "\n Click on ""OK"" to continue your activities at eStore OM . ", String.Format("http://buydev.advantech.com:8888/Orders/OrderDetailsAEU.aspx?OrderNo={0}", Request("estoreorderid").ToString.Trim))
                    End If
                Else
                    Util.AjaxJSConfirm(Me.up1, AlertStr + "\ndo you want to another request? ", "./CreateSAPCustomer.aspx")
                End If

            End If
        Else
            'If input data is not complete, set the submit button back to active
            btnSubmit1.Enabled = True
            btnSubmit2.Enabled = True
            btnSubmit3.Enabled = True
            btnSubmit4.Enabled = True
        End If
    End Sub

    Protected Sub rblFillCredit_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles rblFillCredit.SelectedIndexChanged
        If rblFillCredit.SelectedIndex = 1 Then
            btnGo2Credit.Visible = True
        Else
            btnGo2Credit.Visible = False
        End If
    End Sub

    Protected Sub btnGo2Shipto_Click(sender As Object, e As System.EventArgs) Handles btnGo2Shipto.Click
        mv1.ActiveViewIndex = 2
    End Sub
    Protected Sub btnGo2Billing_Click(sender As Object, e As System.EventArgs) Handles btnGo2Billing.Click
        mv1.ActiveViewIndex = 3
    End Sub

    Protected Sub rblHasShipto_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles rblHasShipto.SelectedIndexChanged
        Me.btnGo2Shipto.Visible = IIf(rblHasShipto.SelectedIndex = 1, True, False)
    End Sub
    Protected Sub rblHasBilling_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles rblHasBilling.SelectedIndexChanged
        Me.btnGo2Billing.Visible = IIf(rblHasBilling.SelectedIndex = 1, True, False)
    End Sub

    Protected Sub BtApprove_Click(sender As Object, e As System.EventArgs) Handles BtApprove.Click
        If Request("ApplicationID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("ApplicationID")) Then
            lbDoneMsg2.Text = ""
            If RBIsExist.SelectedValue = "0" Then
                txtCompanyId.Text = txtCompanyId2.Text
            End If
            If String.IsNullOrEmpty(txtCompanyId.Text) Then
                lbDoneMsg2.Text = "Company id cannot be empty" : Exit Sub
            End If
            If txtCompanyId.Text.Trim.Length > 9 OrElse txtCompanyId.Text.Trim.Length < 7 Then
                lbDoneMsg2.Text = "Company id should be 7~9 characters (ex: EDDEVI07)" : Exit Sub
            End If
            If Not RBIsExist.SelectedIndex = 0 AndAlso CreateSAPCustomerDAL.IsERPIDExist(txtCompanyId.Text) Then
                lbDoneMsg2.Text = "Company id " + txtCompanyId.Text + " already exists in SAP"
                Exit Sub
            End If
            If TBComment.Text.Trim = "" Then
                lbDoneMsg2.Text = "Comment cannot be empty"
                Exit Sub
            End If
            If ValidateInputData(False) Then
                Try
                    If PageMethod_CreateCustomer(True) = False Then
                        Util.AjaxJSAlert(Me.up1, "Fail")
                        Exit Sub
                    End If
                    Dim sql As String = String.Format("update SAPCUSTOMER_APPLICATION set  [STATUS]=1 , COMMENT =N'{1}', APPROVED_BY='{2}', APPROVED_DATE='{3}' ,LAST_UPD_BY ='{2}', LAST_UPD_DATE='{3}' where ROW_ID ='{0}' ", Trim(Request("ApplicationID").ToString), TBComment.Text.Replace("'", "''"), Session("user_id"), Date.Now())
                    dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
                    SendEmail(Request("ApplicationID"), 1)

                    Dim A As New CreateSAPCustomerTableAdapters.SAPCUSTOMER_GENERALDATATableAdapter
                    Dim dt As DataTable = A.selectByApplicationID(Trim(Request("ApplicationID").ToString))
                    If dt.Rows.Count > 0 Then
                        CreateSAPCustomerDAL.UpdateSieble(Trim(Request("ApplicationID").ToString))
                        CreateSAPCustomerDAL.CallEstoreWS(Trim(Request("ApplicationID").ToString))
                    End If
                    Util.AjaxJSAlertRedirect(Me.up1, "Succeed", "SAPCustomerList.aspx")
                Catch ex As Exception
                    Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", "Approve Customer Failed.", Request("ApplicationID").ToString + vbTab + Session("user_id").ToString() + vbTab + Date.Now.ToString() + vbCrLf + ex.ToString(), False, "YL.Huang@advantech.com.tw", "")
                End Try
            End If
        End If
    End Sub

    Protected Sub BtReject_Click(sender As Object, e As System.EventArgs) Handles BtReject.Click
        If Request("ApplicationID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("ApplicationID")) Then
            If TBComment.Text.Trim = "" Then
                lbDoneMsg2.Text = "Comment cannot be empty"
                Exit Sub
            End If
            Dim sql As String = String.Format("update SAPCUSTOMER_APPLICATION set [STATUS]=2 ,COMMENT =N'{1}', REJECTED_BY='{2}', REJECTED_DATE='{3}' ,LAST_UPD_BY ='{2}', LAST_UPD_DATE='{3}' where ROW_ID ='{0}' ", Trim(Request("ApplicationID").ToString), TBComment.Text.Replace("'", "''"), Session("user_id"), Date.Now())
            dbUtil.dbExecuteNoQuery("MYLOCAL", sql)
            SendEmail(Request("ApplicationID"), 2)
            Util.AjaxJSAlertRedirect(Me.up1, "refuse to success", "SAPCustomerList.aspx")
        End If
    End Sub
    Public Shared Function SendEmail(ByVal ApplicationID As String, ByVal TypeInt As Integer) As Integer
        'If TypeInt = 0 Then
        '    ApplicationID = dbUtil.dbExecuteScalar("MYLOCAL", String.Format("select top 1  isnull(applicationid,'') as id from SAPCUSTOMER_GENERALDATA where APLICATIONNO='{0}'", ApplicationID))
        'End If
        Dim A As New CreateSAPCustomerTableAdapters.GetAllTableAdapter
        Dim dt As New CreateSAPCustomer.GetAllDataTable
        dt = A.GetDataByApplicationID(ApplicationID)
        Dim dr As CreateSAPCustomer.GetAllRow = dt.Rows(0)
        With dr
            Dim strSubject As String = ""
            Dim strFrom As String = "eBusiness.AEU@advantech.eu"
            Dim strTo As String = ""
            Dim strCC As String = ""
            Dim strBcc As String = "Jay.Lee@advantech.com,tc.chen@advantech.com.tw,IC.Chen@advantech.com.tw,YL.Huang@advantech.com.tw"
            If HttpContext.Current.Session("user_id") IsNot Nothing AndAlso HttpContext.Current.Session("user_id").ToString.Equals("YL.Huang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
                strBcc = "tc.chen@advantech.com.tw,IC.Chen@advantech.com.tw,YL.Huang@advantech.com.tw"
            End If
            Dim mailbody As String = ""
            Select Case TypeInt
                Case -1
                    strSubject = String.Format("Your new SAP account application being processed. Company Name: {0} ({1})", .COMPANYNAME, .APLICATIONNO)
                    strTo = .REQUEST_BY
                    strCC = ""
                    mailbody = ""
                Case 0
                    strSubject = String.Format("A new SAP account application is applied by {0} and request for your approval. Company Name: {1}({2})", .REQUEST_BY, .COMPANYNAME, .APLICATIONNO)
                    strTo = "AEU.Creditmanagement@advantech.nl"
                    strCC = ""
                    mailbody = String.Format(" Please <a href=""{0}"">click</a> to check and approve this request. Thanks.", Util.GetRuntimeSiteUrl + String.Format("/admin/CreateSAPCustomer.aspx?ApplicationID={0}",
                                                                                         ApplicationID))
                Case 1
                    strSubject = String.Format("Your application new SAP account has been approved by {0}. Company Name: {1}({2})", .APPROVED_BY, .COMPANYNAME, .APLICATIONNO)
                    strTo = "AEU.Creditmanagement@advantech.nl" ' .REQUEST_BY
                    strCC = "AEU.Creditmanagement@advantech.nl"
                    mailbody = String.Format("New ERP ID is ""{1}"", Please <a href=""{0}"">click</a> to check the approval comment and detail. Thanks.", Util.GetRuntimeSiteUrl + String.Format("/admin/SAPCustomerDetail.aspx?ApplicationID={0}",
                                                                                         ApplicationID), .COMPANYID)
                Case 2
                    strSubject = String.Format("Your application new SAP account has been rejected by {0}. Company Name: {1}({2})", .REJECTED_BY, .COMPANYNAME, .APLICATIONNO)
                    strTo = .REQUEST_BY
                    strCC = "AEU.Creditmanagement@advantech.nl"
                    mailbody = String.Format("The reason of denial is "" {1} "", Please <a href=""{0}"">click</a> to modify the detail. Thanks.", Util.GetRuntimeSiteUrl + String.Format("/admin/CreateSAPCustomer.aspx?ApplicationID={0}",
                                                                                         ApplicationID), .COMMENT.ToString.Trim)
            End Select
            Try
                mailbody += "<br/><p></p>" + GetDetail(ApplicationID, 0)
            Catch ex As Exception
            End Try
            'If HttpContext.Current.User.Identity.Name.Equals("ming.zhao@advantech.com.cn", StringComparison.OrdinalIgnoreCase) Then
            If Util.IsTesting() Then
                Dim CCstr As String = "Jay.Lee@advantech.com,tc.chen@advantech.com.tw,xiaoya.hua@advantech.com.cn"
                If HttpContext.Current.Session("user_id") IsNot Nothing AndAlso HttpContext.Current.Session("user_id").ToString.Equals("YL.Huang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
                    CCstr = "IC.Chen@advantech.com.tw,YL.Huang@advantech.com.tw"
                End If
                Call MailUtil.Utility_EMailPage(strFrom, "YL.Huang@advantech.com.tw", CCstr, "YL.Huang@advantech.com.tw", strSubject.Trim(), "", "TO:" + strTo + "<BR/>CC:" + strCC + "<BR/>BCC:" + strBcc + "<HR/>" + mailbody.Trim())
            Else
                Call MailUtil.Utility_EMailPage(strFrom, strTo, strCC, strBcc, strSubject.Trim(), "", mailbody.Trim())
            End If
        End With
        Return 1
    End Function
    Public Shared Function GetDetail(ByVal ApplicationID As String, ByVal Type As String) As String
        Dim myDoc As New System.Xml.XmlDocument, DivBlock As String = ""
        Global_Inc.HtmlToXML("~/admin/SAPCustomerDetail.aspx?ApplicationID=" & ApplicationID, myDoc)
        Global_Inc.getXmlBlockByID("div", "divdetail", myDoc, DivBlock)
        Return DivBlock
    End Function

    Protected Sub RB1_SelectedIndexChanged(sender As Object, e As System.EventArgs) Handles RBIsExist.SelectedIndexChanged

    End Sub

    Protected Sub BTcheck_Click(sender As Object, e As System.EventArgs) Handles BTcheck.Click
        lbERPIDMsg.Text = ""
        txtCompanyId.Text = UCase(Trim(txtCompanyId.Text))
        If String.IsNullOrEmpty(txtCompanyId.Text) Then lbERPIDMsg.Text = "Company ID can not be empty." : Exit Sub
        If 7 > txtCompanyId.Text.Trim.Length OrElse txtCompanyId.Text.Trim.Length > 9 Then lbERPIDMsg.Text = "Company id should be 7~9 characters (ex: EDDEVI07)" : Exit Sub
        If Not CreateSAPCustomerDAL.IsERPIDExist(txtCompanyId.Text) Then lbERPIDMsg.Text = txtCompanyId.Text.Trim() + " does not exist" : Exit Sub
        GetGeneralDataFormSAP(txtCompanyId.Text)
    End Sub
    Public Sub GetGeneralDataFormSAP(ByVal CompanyID As String)
        Try
            Dim kna1_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select Stras,Ort01, Name1, adrnr,Land1,Ktokd,PSTLZ,Stceg,Katr9 from  saprdp.kna1  where Kunnr ='" + CompanyID + "'")
            Dim knvv_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select Inco1,Inco2,Vkgrp,Vkbur,Waers from  saprdp.knvv  where Kunnr ='" + CompanyID + "'")
            Dim knb1_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select Vlibb,Zterm  from  saprdp.knb1  where Kunnr ='" + CompanyID + "'")
            Dim knvp_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select PERNR,PARVW,Pernr from  saprdp.knvp  where Kunnr ='" + CompanyID + "' ")
            Dim kna1_dr As DataRow = kna1_dt.Rows(0)
            Dim knvv_dr As DataRow = knvv_dt.Rows(0)
            Dim knb1_dr As DataRow = knb1_dt.Rows(0)
            With kna1_dr
                txtAddr1.Text = .Item("Stras") : txtCity.Text = .Item("Ort01")
                txtCompanyName.Text = .Item("Name1")
                Dim smtp_addr_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select smtp_addr from  saprdp.adr6 where addrnumber ='" + .Item("adrnr") + "'")
                If smtp_addr_dt.Rows.Count > 0 Then
                    txtContactEmail.Text = smtp_addr_dt.Rows(0).Item("smtp_addr")
                End If
                'txtLegalForm.Text = .LEGALFORM
                Dim adrc_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select NAME_CO from    saprdp.adrc where  adrc.addrnumber='" + .Item("adrnr") + "'")
                If adrc_dt.Rows.Count > 0 Then
                    txtContactName.Text = adrc_dt.Rows(0).Item("NAME_CO")
                End If
                Dim adr12_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select uri_srch from  saprdp.adr12 where addrnumber='" + .Item("adrnr") + "'")
                If adr12_dt.Rows.Count > 0 Then
                    txtWebsiteUrl.Text = adr12_dt.Rows(0).Item("uri_srch")
                End If
                Dim adr3_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select fax_number from  saprdp.adr3 where addrnumber='" + .Item("adrnr") + "'")
                If adr3_dt.Rows.Count > 0 Then
                    txtFax.Text = adr3_dt.Rows(0).Item("fax_number")
                End If
                Dim adr2_dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select tel_number from  saprdp.adr2 where addrnumber='" + .Item("adrnr") + "'")
                If adr2_dt.Rows.Count > 0 Then
                    txtTel.Text = adr2_dt.Rows(0).Item("tel_number")
                End If
                SetDropDownList(dlCountry, FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + .Item("Land1")))
                SetDropDownList(dlCustomerType, FindEnumValueByName(GetType(EnumCustomerType), "Enum_" + .Item("Ktokd")))
                SetDropDownList(dlInco1, FindEnumValueByName(GetType(EnumIncoTerm), "Enum_" + knvv_dr.Item("Inco1")))
                txtInco2.Text = knvv_dr.Item("Inco2")
                txtPostCode.Text = .Item("PSTLZ")
                SetDropDownList(dlCustomerType, knvv_dr.Item("Vkgrp"))
                SetDropDownList(dlSalesOffice, knvv_dr.Item("Vkbur"))
                txtVAT.Text = .Item("Stceg")
                SetDropDownList(dlVM, .Item("Katr9").ToString)
                Dim drs() As DataRow = knvp_dt.Select("PARVW = 'VE'")
                If drs.Length = 1 Then
                    SetDropDownList(dlSalesCode, drs(0).Item("Pernr"))
                End If
                drs = knvp_dt.Select("PARVW = 'Z2'")
                If drs.Length = 1 Then
                    SetDropDownList(dlISCode, drs(0).Item("Pernr"))
                End If
                drs = knvp_dt.Select("PARVW = 'ZM'")
                If drs.Length = 1 Then
                    SetDropDownList(dlOPCode, drs(0).Item("Pernr"))
                End If
                txtAmtInsured.Text = knb1_dr.Item("Vlibb")
                'SetDropDownListText(dlPayTerm, knb1_dr.Item("Zterm"))
                TBdlPayTerm.Text = knb1_dr.Item("Zterm")
                SetDropDownListText(dlCurr, knvv_dr.Item("Waers"))
            End With

        Catch ex As Exception
            lbERPIDMsg.Text = ex.ToString()
        End Try
    End Sub
    Public Sub SetDropDownList(ByVal DDid As DropDownList, ByVal valuestr As String)
        valuestr = valuestr.Trim
        If DDid.Items.FindByValue(valuestr) IsNot Nothing Then
            DDid.SelectedValue = valuestr
        End If
    End Sub
    Public Sub SetDropDownListText(ByVal DDid As DropDownList, ByVal Textstr As String)
        Textstr = Textstr.Trim
        If DDid.Items.FindByText(Textstr) IsNot Nothing Then
            DDid.SelectedItem.Text = Textstr
        End If
    End Sub
    Protected Sub txtCompanyId_TextChanged(sender As Object, e As System.EventArgs) Handles txtCompanyId2.TextChanged
        If String.IsNullOrEmpty(txtCompanyId.Text) Then Exit Sub
        If txtCompanyId.Text.Length < 8 Then Exit Sub
        If CreateSAPCustomerDAL.IsERPIDExist(txtCompanyId.Text) Then
            'lbERPIDMsg2.Text = txtCompanyId.Text.Trim() + " already exists"
        Else
            'lbERPIDMsg2.Text = txtCompanyId.Text.Trim() + " is new and ok to be created"
        End If
    End Sub

    Protected Sub BtChecksiebel_Click(sender As Object, e As System.EventArgs) Handles BtChecksiebel.Click
        Me.UPPickAccount.Update() : Me.MPPickAccount.Show()
        'Exit Sub

    End Sub
    Public Sub PickAccountEnd(ByVal str As Object)
        TBsiebelAccountID.Text = str(0).ToString
        'Dim srFile As StreamReader = Nothing
        'Dim sql As String = String.Empty
        'srFile = New StreamReader(Server.MapPath("~/admin/sql/GetSiebelAccount.txt"), System.Text.Encoding.[Default])
        'sql = srFile.ReadToEnd()
        'If srFile IsNot Nothing Then
        '    srFile.Dispose()
        '    srFile.Close()
        'End If
        Dim sb As New StringBuilder()
        sb.AppendLine("SELECT TOP 1 a.ROW_ID, ISNULL(b.ATTRIB_05, N'') AS ERP_ID, a.NAME AS ACCOUNT_NAME, ")
        sb.AppendLine("a.CUST_STAT_CD AS ACCOUNT_STATUS, ISNULL(a.MAIN_FAX_PH_NUM, N'') AS FAX_NUM, ")
        sb.AppendLine("ISNULL(a.MAIN_PH_NUM, N'') AS PHONE_NUM, ISNULL(a.OU_TYPE_CD, N'') AS OU_TYPE_CD, ISNULL(a.URL, N'') ")
        sb.AppendLine("AS URL, ISNULL(b.ATTRIB_34, N'') AS BusinessGroup, ISNULL(a.OU_TYPE_CD, N'') AS ACCOUNT_TYPE, ")
        sb.AppendLine("ISNULL(c.NAME, N'') AS RBU, ISNULL((SELECT EMAIL_ADDR FROM S_CONTACT WHERE ")
        sb.AppendLine("(ROW_ID IN (SELECT PR_EMP_ID FROM S_POSTN WHERE (ROW_ID IN (SELECT PR_POSTN_ID FROM S_ORG_EXT WHERE ")
        sb.AppendLine("(ROW_ID = a.ROW_ID)))))), N'') AS PRIMARY_SALES_EMAIL, a.PAR_OU_ID AS PARENT_ROW_ID, ")
        sb.AppendLine("ISNULL(b.ATTRIB_09, N'N') AS MAJORACCOUNT_FLAG, ISNULL(a.CMPT_FLG, N'N') AS COMPETITOR_FLAG, ")
        sb.AppendLine("ISNULL(a.PRTNR_FLG, N'N') AS PARTNER_FLAG, ISNULL(d.COUNTRY, N'') AS COUNTRY, ")
        sb.AppendLine("ISNULL(d.CITY, N'') AS CITY, ISNULL(d.ADDR, N'') AS ADDRESS, ISNULL(d.STATE, N'') AS STATE, ")
        sb.AppendLine("ISNULL(d.ZIPCODE, N'') AS ZIPCODE, ISNULL(d.PROVINCE, N'') AS PROVINCE, ")
        sb.AppendLine("ISNULL((SELECT TOP (1) NAME FROM S_INDUST WHERE (ROW_ID = a.X_ANNIE_PR_INDUST_ID)), N'N/A') AS BAA, ")
        sb.AppendLine("b.CREATED, b.LAST_UPD AS LAST_UPDATED, ISNULL((SELECT TOP (1) e.NAME ")
        sb.AppendLine("FROM S_PARTY AS e INNER JOIN S_POSTN AS f ON e.ROW_ID = f.OU_ID WHERE ")
        sb.AppendLine("(f.ROW_ID IN (SELECT PR_POSTN_ID FROM S_ORG_EXT AS S_ORG_EXT_2 WHERE ")
        sb.AppendLine("(ROW_ID = a.ROW_ID)))), N'') AS PriOwnerDivision, a.PR_POSTN_ID AS PriOwnerRowId, ")
        sb.AppendLine("ISNULL((SELECT TOP (1) NAME FROM S_POSTN AS f WHERE (ROW_ID IN ")
        sb.AppendLine("(SELECT PR_POSTN_ID FROM S_ORG_EXT AS S_ORG_EXT_1 WHERE ")
        sb.AppendLine("(ROW_ID = a.ROW_ID)))), N'') AS PriOwnerPosition, CAST('' AS nvarchar(10)) ")
        sb.AppendLine("AS LOCATION, CAST('' AS nvarchar(10)) AS ACCOUNT_TEAM, ISNULL(d.ADDR_LINE_2, N'') AS ADDRESS2, ")
        sb.AppendLine("ISNULL(b.ATTRIB_36, N'') AS ACCOUNT_CC_GRADE, ISNULL(a.BASE_CURCY_CD, N'') AS CURRENCY, ")
        sb.AppendLine("ISNULL(b.ATTRIB_04, N'') AS VAT_NO FROM S_ORG_EXT AS a LEFT OUTER JOIN ")
        sb.AppendLine("S_ORG_EXT_X AS b ON a.ROW_ID = b.ROW_ID LEFT OUTER JOIN ")
        sb.AppendLine("S_PARTY AS c ON a.BU_ID = c.ROW_ID LEFT OUTER JOIN ")
        sb.AppendLine("S_ADDR_PER AS d ON a.PR_ADDR_ID = d.ROW_ID ")
        sb.AppendLine("WHERE (a.ROW_ID = '{0}') ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format(sb.ToString, TBsiebelAccountID.Text.Trim.Replace("'", "''")))
        If dt.Rows.Count = 1 Then
            With dt.Rows(0)
                txtCompanyName.Text = .Item("ACCOUNT_NAME")
                txtAddr1.Text = .Item("Address")
                'txtAddr2.Text = Trim(.Item("province").ToString.Trim + " " + .Item("city"))
                'txtAddr3.Text = .Item("COUNTRY") + " " + .Item("State") '.Item("location")
                txtPostCode.Text = .Item("ZIPCODE")
                txtCity.Text = .Item("city")
                txtWebsiteUrl.Text = .Item("URL")
                txtVAT.Text = .Item("VAT_NO")
                'txtContactEmail.Text = .Item("PRIMARY_SALES_EMAIL")
                'txtContactName.Text = Util.GetNameVonEmail(.Item("PRIMARY_SALES_EMAIL"))
                If .Item("COUNTRY") IsNot Nothing Then
                    Dim Names() As String = [Enum].GetNames(GetType(EnumCountryCode))
                    Dim Values() As Integer = [Enum].GetValues(GetType(EnumCountryCode))
                    Dim dtCountry As DataTable = dbUtil.dbGetDataTable("MY", "select distinct COUNTRY, isnull(country_name,'') as  country_name  from SAP_DIMCOMPANY where country_name='" + .Item("COUNTRY") + "' order by COUNTRY")
                    If dtCountry.Rows.Count > 0 Then
                        SetDropDownList(dlCountry, FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + dtCountry.Rows(0).Item("COUNTRY")))
                    End If
                End If
            End With
        End If
        dt = dbUtil.dbGetDataTable("MY", String.Format("SELECT TOP 1 ( isnull(FirstName,'') +' '+ isnull(MiddleName,'') + ' '+isnull(LastName,'') ) AS  NAME , isnull(EMAIL_ADDRESS,'') as Email from dbo.SIEBEL_CONTACT WHERE ACCOUNT_ROW_ID ='{0}'", TBsiebelAccountID.Text.Trim.Replace("'", "''")))
        If dt.Rows.Count = 1 Then
            With dt.Rows(0)
                txtContactEmail.Text = .Item("Email")
                txtContactName.Text = .Item("NAME")
            End With
        End If
        up1.Update()
        Me.MPPickAccount.Hide()
    End Sub

    Protected Sub BtApprove_Load(sender As Object, e As System.EventArgs) Handles BtApprove.Load

    End Sub

    Public Sub SetOPCodeBySelection()
        Dim SalesGroup As Integer = 0, SalesOffice As Integer = 0

        If Integer.TryParse(Me.dlCustomerType.SelectedValue, SalesGroup) AndAlso Integer.TryParse(Me.dlSalesOffice.SelectedValue, SalesOffice) Then
            Dim objOPCode As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 SalesCode from AEU_OPMapping where SalesGroup = '{0}' and SalesOffice = '{1}'", SalesGroup, SalesOffice))
            If objOPCode IsNot Nothing AndAlso Not String.IsNullOrEmpty(objOPCode.ToString) AndAlso Me.dlOPCode.Items.FindByValue(objOPCode.ToString) IsNot Nothing Then
                Me.dlOPCode.SelectedValue = objOPCode.ToString
            Else
                Me.dlOPCode.SelectedValue = "TBD"
            End If
            up1.Update()
        End If
    End Sub

    Public Sub New()

    End Sub

    Protected Sub RBIsExist_SelectedIndexChanged(sender As Object, e As EventArgs)
        If Not RBIsExist.SelectedIndex = 0 Then
            txtCompanyId.Text = ""
        End If
    End Sub
End Class


