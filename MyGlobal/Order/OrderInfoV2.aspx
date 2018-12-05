<%@ Page Title="MyAdvantech–Order Information" EnableEventValidation="false" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<%@ Import Namespace="quote" %>
<%@ Register Src="~/Includes/Order/ShiptoList.ascx" TagName="ShipTo" TagPrefix="uc1" %>
<%@ Register Src="~/Includes/Order/USAOnlineShipBillTo.ascx" TagName="ShipToUS" TagPrefix="uc1" %>
<%@ Register Src="../Includes/PartialDeliver.ascx" TagName="PartialDeliver" TagPrefix="uc2" %>
<%@ Register Src="~/Includes/Order/OrderAddress.ascx" TagName="OrderAddress" TagPrefix="uc1" %>
<%@ Register Src="../Includes/Order/AuthCreditResult.ascx" TagName="AuthCreditResult" TagPrefix="uc3" %>
<%--<%@ Register Src="../Includes/Order/AuthCreditResultV2.ascx" TagName="AuthCreditResultV2" TagPrefix="uc3" %>--%>
<%--<%@ Register Src="../Includes/Payment/PaymentInfo.ascx" TagName="PaymentInfo" TagPrefix="uc3" %>--%>
<%@ Register Src="~/Includes/BBFreightCalculation.ascx" TagName="BBFreightCalculation" TagPrefix="uc4" %>
<%@ Register Src="~/Includes/CreateSAPContact.ascx" TagName="CreateSAPContact" TagPrefix="uc5" %>
<%@ Register Src="~/Includes/CreditInfo.ascx" TagName="CrditInfo" TagPrefix="uc6" %>

<script runat="server">
    Dim myCompany As New SAP_Company("b2b", "SAP_dimCompany"), myOrderMaster As New order_Master("b2b", "order_master"), myOrderDetail As New order_Detail("b2b", "order_detail"), mycart As New CartList("b2b", "CART_DETAIL_V2"), CartId As String = ""
    Dim rbtnIsPartial As RadioButtonList = Nothing, txtShipTo As TextBox = Nothing, txtShipToAttention As TextBox = Nothing, txtBillTo As TextBox = Nothing, txtShiptoCountry As TextBox = Nothing
    Dim EQpaymentTerm As String = ""
    Dim CheckPoint_Convert2Order As String = ""
    Dim IsCheckPointOrder As Boolean = False
    Dim IsEUBtosOrder As Boolean = False

    Protected Sub FillSalesEmployees()
        Dim SalesEmployees As DataTable = OrderUtilities.getSalesEmployeeList(Session("org_id"), Session("company_id"))
        'SalesEmployees.Columns.Add("DisplayName", GetType(String), "FULL_NAME + ' ('+ SALES_CODE +')'")
        SalesEmployees.Columns.Add("DisplayName", GetType(String), "SALES_CODE + ' '+ FULL_NAME +''")
        ddlSE.DataTextField = "DisplayName" : ddlSE.DataValueField = "SALES_CODE"
        ddlSE.DataSource = SalesEmployees
        ddlSE.DataBind()

        'Ryan 20170629 Add corresponding sales from SAP_COMPANY_EMPLOYEE table if not existed in ddlSE
        Dim sql As New StringBuilder()
        sql.AppendFormat(" select a.SALES_CODE, b.FULL_NAME from SAP_COMPANY_EMPLOYEE a inner join SAP_EMPLOYEE b ")
        sql.AppendFormat(" On a.SALES_CODE = b.SALES_CODE where a.COMPANY_ID = '{0}' and a.PARTNER_FUNCTION = 'VE' ", Session("company_id"))
        Dim dtCompanyEmployee As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString)
        If dtCompanyEmployee IsNot Nothing AndAlso dtCompanyEmployee.Rows.Count > 0 Then
            For Each d As DataRow In dtCompanyEmployee.Rows
                If ddlSE.Items.FindByValue(d.Item("SALES_CODE").ToString) Is Nothing Then
                    ddlSE.Items.Add(New ListItem(d.Item("SALES_CODE").ToString + " " + d.Item("FULL_NAME").ToString, d.Item("SALES_CODE").ToString))
                End If
            Next
        End If

        ddlSE.Items.Insert(0, New ListItem("Select…", ""))
    End Sub

    Protected Sub FillKeyInPerson()
        Dim KeyInPersonDT As DataTable = SAPDOC.GetKeyInPersonV2(Session("USER_ID"))
        If KeyInPersonDT.Rows.Count > 0 Then
            If Not SAPDOC.IsATWCustomer() Then
                KeyInPersonDT.Columns.Add("DisplayName", GetType(String), "FULL_NAME + ' ('+ SALES_CODE +')'")
            Else
                KeyInPersonDT.Columns.Add("DisplayName", GetType(String), "SALES_CODE + ' ' + FULL_NAME +''")
            End If
            Dim _foundrow() As DataRow = KeyInPersonDT.Select("EMAIL='" & Session("USER_ID") & "'")
            Dim _SelectEmployeeCode As String = ""
            If _foundrow IsNot Nothing AndAlso _foundrow.Length > 0 Then
                _SelectEmployeeCode = _foundrow(0).Item("SALES_CODE")
            End If
            ddlKeyInPerson.DataTextField = "DisplayName" : ddlKeyInPerson.DataValueField = "SALES_CODE"
            ddlKeyInPerson.DataSource = KeyInPersonDT
            ddlKeyInPerson.DataBind()
            ddlKeyInPerson.SelectedValue = _SelectEmployeeCode
            trKeyInPerson.Visible = True
        Else
            trKeyInPerson.Visible = False
        End If
    End Sub

    Protected Function GetPrimarySales() As String
        Dim sql As New StringBuilder()
        sql.Append(" select TOP 1  isnull(SALES_CODE,'') as salescode from SAP_COMPANY_PARTNERS ")
        sql.AppendFormat(" where COMPANY_ID='{0}' and ORG_ID='{1}' and PARTNER_FUNCTION='VE' ", Session("company_id"), Session("org_id"))
        sql.Append("  and SALES_CODE<>'00000000' order by SALES_CODE ")
        Dim objsale As Object = dbUtil.dbExecuteScalar("MY", sql.ToString)
        If objsale IsNot Nothing Then Return objsale.ToString.Trim
        Return ""
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        '把預設按鈕指定給空按鈕，防止ENTER發生Logout
        Me.Page.Form.DefaultButton = btn_enter.UniqueID

        'If Util.IsTestingQuote2Order() Then
        '    Response.Redirect(String.Format("OrderInfoV2.aspx{0}", Request.Url.Query))
        'End If
        CartId = Session("cart_id")
        rbtnIsPartial = CType(Me.PartialDeliver1.FindControl("rbtnIsPartial"), RadioButtonList)
        txtShipTo = CType(Me.shiptoaddress.FindControl("txtShipTo"), TextBox)
        txtShipToAttention = CType(Me.shiptoaddress.FindControl("txtShipToAttention"), TextBox)
        txtBillTo = CType(Me.billtoaddress.FindControl("txtShipTo"), TextBox)
        txtShiptoCountry = CType(Me.shiptoaddress.FindControl("txtShipToCountry"), TextBox)

        'Ryan 20160328 Check if is Check Point Order
        If Advantech.Myadvantech.Business.CPDBBusinessLogic.IsCheckPointOrder(CartId, Session("user_id").ToString()) Then
            IsCheckPointOrder = True
        End If

        'Ryan 20160516 Check if is EU Btos Cart
        If String.Equals(HttpContext.Current.Session("org_id"), "EU10", StringComparison.CurrentCultureIgnoreCase) Then
            If MyCartX.IsHaveBtos(CartId) Then
                IsEUBtosOrder = True
            End If
        End If

        If Not Page.IsPostBack Then

            'Ryan 20151222 Check whether page called from Check-Point convert2order or not
            If Not String.IsNullOrEmpty(Request("CheckPoint_Convert2Order")) Then
                CheckPoint_Convert2Order = Request("CheckPoint_Convert2Order")
            End If

            If Session("Org_id") = "EU10" AndAlso Util.IsInternalUser2() Then
                If mycart.CheckCartGPByCartId(CartId) = True Then
                    Response.Redirect("~/Order/GPcontrol.aspx")
                End If
            End If
            txtreqdate.Attributes("onclick") = "PickDate('" + Util.GetRuntimeSiteUrl() + "/INCLUDES/PickShippingCalendar.aspx',this)"
            txtPODate.Attributes.Add("readonly", "readonly")
            If Session("company_id") = "SAID" Then
                Me.trDelPlant.Visible = True
            End If
            If String.Equals(Session("company_id"), "EDDEAM01", StringComparison.CurrentCultureIgnoreCase) Then
                trSE.Visible = True
                FillSalesEmployees()
                Dim custom_salescode As New ArrayList
                custom_salescode.Add("30040003")
                Dim GetPrimary_Sales As String = GetPrimarySales()
                If Not String.IsNullOrEmpty(GetPrimary_Sales) Then custom_salescode.Add(GetPrimary_Sales)
                Dim listsales As New List(Of ListItem)
                For i As Integer = 0 To ddlSE.Items.Count - 1
                    If custom_salescode.Contains(ddlSE.Items(i).Value) Then
                        listsales.Add(ddlSE.Items(i))
                    End If
                Next
                ddlSE.Items.Clear()
                For Each i As ListItem In listsales
                    ddlSE.Items.Add(i)
                Next
                ddlSE.Items.Insert(0, New ListItem("Select…", ""))
            End If

            'Ryan 20170214 End Customer block is now opened to EU, JP and Intercon users.
            If String.Equals(Session("company_id"), "UUMM001", StringComparison.CurrentCultureIgnoreCase) OrElse
                Session("Org_id").Equals("TW01") OrElse
                Session("Org_id").Equals("TW20") OrElse
                Session("Org_id").Equals("JP01") OrElse
                Session("Org_id").Equals("EU10") OrElse
                Session("Org_id").ToString.StartsWith("CN") OrElse
                AuthUtil.IsInterConUser Then

                'Ryan 20170216 JP01 will show EM ascx anyway, others will need to check if ERPID has maintained EM or not.
                If Session("Org_id").Equals("JP01") Then
                    tdendcustomer.Visible = True : thendcustomer.Visible = True
                Else
                    Dim showEMblock As Boolean = False
                    'If has no default End Customer, then will not need to show EM ascx
                    Dim _Quoteid As String = String.Empty
                    Dim isQuote2Cart As Boolean = MyCartX.IsQuote2Cart(Session("cart_id"), _Quoteid)
                    Dim QuoteEndCustomer As String = Advantech.Myadvantech.Business.QuoteBusinessLogic.GetQuotationEndCustomer(_Quoteid)

                    If isQuote2Cart AndAlso Not String.IsNullOrEmpty(QuoteEndCustomer) Then
                        showEMblock = True
                    Else
                        Dim HasSAPEM As Boolean = Advantech.Myadvantech.Business.OrderBusinessLogic.HasSAPEndCustomer(Session("company_id").ToString, "")
                        If HasSAPEM Then
                            showEMblock = True
                        End If
                    End If

                    If showEMblock Then
                        tdendcustomer.Visible = True : thendcustomer.Visible = True
                    End If
                End If
            End If

            Dim _IsInternalButNotFC As Boolean = False

            If Util.IsInternalUser2() AndAlso (Session("account_status") <> "FC" Or Util.IsFranchiser(Session("user_id"), "")) Then

                _IsInternalButNotFC = True

                ' Set  Sales Employee
                trSE.Visible = True
                FillSalesEmployees()
                ddlSE2.Items.Clear() : ddlSE3.Items.Clear()
                For Each r As ListItem In ddlSE.Items
                    ddlSE2.Items.Add(New ListItem(r.Text, r.Value))
                    ddlSE3.Items.Add(New ListItem(r.Text, r.Value))
                Next

                FillKeyInPerson()
            Else
                If Session("org_id").ToString.StartsWith("CN") Then
                    trSE.Visible = True
                    FillSalesEmployees()
                    FillKeyInPerson()
                End If
            End If

            initInterface()

            If Util.IsAEUIT() Then
                btnDirect2SAP.Visible = True : D2Std.Visible = True
            End If

            Dim _IsATWAOnline As Boolean = False
            'Frank 2014/02/13: The column hiding request comes from Show.Liaw
            If Session("org_id").ToString.Trim.StartsWith("TW", StringComparison.OrdinalIgnoreCase) _
                AndAlso AuthUtil.IsTWAonlineSales(User.Identity.Name) Then
                Me.trBillInfo.Visible = False : Me.trFreTax.Visible = False : _IsATWAOnline = True
            End If

            If Session("account_status") = "FC" Then
                trSN.Visible = False : trBillInfo.Visible = False : trFreTax.Visible = False
            End If

            'If Util.IsInternalUser2() AndAlso (Session("account_status") <> "FC" Or Util.IsFranchiser(Session("user_id"), "")) Then
            If _IsInternalButNotFC Then
                If _IsATWAOnline Then
                    trPayTerm.Visible = False
                Else
                    trPayTerm.Visible = True
                End If

                'If Util.IsAEUIT() Or User.Identity.Name.EndsWith("@advantech.com", StringComparison.CurrentCultureIgnoreCase) Then
                If Util.IsAEUIT() Or AuthUtil.IsUSAonlineSales(User.Identity.Name) Then
                    trDSGSO.Visible = True
                End If

                '20120716 TC: Show ucShipToUS for US Employees
                If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then 'Or Util.IsFranchiser(Session("user_id"), "")
                    Me.spShipc.Visible = False : Me.drpShipCondition.Visible = False
                    tdbillto.Visible = True : tdbilltoascx.Visible = True : tyEarlyShip.Visible = True
                    tdE2name.Visible = True : tdE3name.Visible = True : tdE2.Visible = True : tdE3.Visible = True
                    litRD.Text = "Req delivery date" : litRDF.Text = "yyyy/MM/dd"
                    If Date.TryParse(txtreqdate.Text, Now) = True Then
                        txtreqdate.Text = CDate(txtreqdate.Text).ToString("yyyy/MM/dd")
                    End If
                    calDate.Format = "MM/dd/yyyy"
                    'If drpIncoterm.Items.FindByValue("FB1") IsNot Nothing Then
                    '    drpIncoterm.SelectedValue = "FB1"
                    'drpIncoterm.Enabled = False
                    'End If
                End If
                'Get all regional payment term options
                dlPayterm.DataSource = dbUtil.dbGetDataTable("MY",
                    " select distinct CREDIT_TERM from SAP_DIMCOMPANY where ORG_ID='" + Session("org_id") + "' and CREDIT_TERM is not null " +
                    " and CREDIT_TERM <> '' order by CREDIT_TERM")
                ' Get current customer's payment term 
                If String.IsNullOrEmpty(EQpaymentTerm) Then
                    'Frank 20150901 determine default payment term by bill-to party

                    Dim CurrentCompanyID As String = SAPDAL.SAPDAL.GetBillToNotSoldTo(Session("company_id").ToString, Session("org_id").ToString)

                    'Ryan 20171116 For EU10 take SoldtoID as default per Sigrid's request.
                    If Session("Org_id") = "EU10" Then
                        CurrentCompanyID = Session("company_id").ToString
                    End If

                    If String.IsNullOrEmpty(CurrentCompanyID) Then
                        CurrentCompanyID = Session("company_id").ToString
                    End If
                    '\ Ming Get current customer's payment term for MexicoT2Customer 2013-08-26
                    Dim ParentCompany As String = String.Empty
                    If Util.IsMexicoT2Customer(CurrentCompanyID, ParentCompany) Then
                        CurrentCompanyID = ParentCompany
                    End If
                    '/ end
                    Dim objcustCTerm As Object = dbUtil.dbExecuteScalar("MY",
                   String.Format("select top 1 CREDIT_TERM from SAP_DIMCOMPANY where company_id='{0}' and org_id='{1}'",
                                 CurrentCompanyID, Session("org_id")))
                    If objcustCTerm IsNot Nothing AndAlso Not String.IsNullOrEmpty(objcustCTerm.ToString) Then
                        EQpaymentTerm = objcustCTerm.ToString
                    End If
                End If

                dlPayterm.DataTextField = "CREDIT_TERM" : dlPayterm.DataValueField = "CREDIT_TERM" : dlPayterm.DataBind()
                If dlPayterm.Items.Count > 0 AndAlso Not String.IsNullOrEmpty(EQpaymentTerm) Then
                    dlPayterm.SelectedIndex = -1
                    For Each liCreditTermItem As ListItem In dlPayterm.Items
                        If String.Equals(liCreditTermItem.Value, EQpaymentTerm, StringComparison.CurrentCultureIgnoreCase) Then
                            liCreditTermItem.Selected = True
                        End If
                    Next
                End If
                dlPayterm_SelectedIndexChanged(Nothing, Nothing)
            End If
            'Ming add 20140605 Hide the function for picking “Sales Employee” on MyAdvantech order info page for all AEU users.
            If Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
                dlPayterm.Enabled = False
                trSE.Visible = False

                'Ryan 20171026 Show payer list for EU10
                Me.trPayer.Visible = True
                Me.ddlPayer.Items.Clear()
                Me.ddlPayer.Items.Add(New ListItem(Session("company_id") + " - " + Session("company_name"), Session("company_id")))
                Dim strPayer As StringBuilder = New StringBuilder
                strPayer.AppendLine(" select a.PARENT_COMPANY_ID as PayerID, b.COMPANY_NAME as PayerName from SAP_COMPANY_PARTNERS a inner join SAP_DIMCOMPANY b on a.PARENT_COMPANY_ID = b.COMPANY_ID")
                strPayer.AppendFormat(" where a.COMPANY_ID = '{0}' AND a.PARTNER_FUNCTION = 'RG' ORDER BY a.DEFPA desc, a.PARENT_COMPANY_ID", Session("company_id"))
                Dim dtPayer As DataTable = dbUtil.dbGetDataTable("MY", strPayer.ToString)
                If dtPayer IsNot Nothing AndAlso dtPayer.Rows.Count > 0 Then
                    For Each d As DataRow In dtPayer.Rows
                        If ddlPayer.Items.FindByValue(d.Item("PayerID").ToString) Is Nothing Then
                            ddlPayer.Items.Add(New ListItem(d.Item("PayerID").ToString + " - " + d.Item("PayerName").ToString, d.Item("PayerID").ToString))
                        End If
                    Next
                End If
            End If
            If Session("company_id").ToString.Equals("ULTR00001", StringComparison.CurrentCultureIgnoreCase) _
                OrElse MailUtil.IsInRole("Aonline.USA") _
                OrElse MailUtil.IsInRole("AOnline.USA.IAG") Then
                Me.shiptoaddress.Editable = True
            Else
                Me.shiptoaddress.Editable = False
            End If
            'If Session("user_id") = "ming.zhao@advantech.com.cn" Then
            '    tdbilltoascx.Visible = True
            'End If

            'Ryan 20171013 Special case for Alitek(ETRA002)
            If String.Equals(Session("company_id"), "ETRA002", StringComparison.CurrentCultureIgnoreCase) AndAlso Not Util.IsInternalUser2 Then
                trSE.Visible = True
                ddlSE.Items.Clear()
                ddlSE.Items.Insert(0, New ListItem("Select…", ""))
                ddlSE.Items.Insert(1, New ListItem("94000002 - Jack945.Lin", "94000002"))
                ddlSE.Items.Insert(2, New ListItem("96000002 - Jennifer.Chen", "96000002"))
            End If

            '  Get po number and ShipCondition for upload order
            Dim PoNo As String = String.Empty, ShipCondition As String = String.Empty
            Dim retint As Integer = OrderUtilities.GetParsForUploadOrder(CartId, "", PoNo, ShipCondition)
            If retint = 1 Then
                txtPONo.Text = PoNo
                For Each itemsc As ListItem In drpShipCondition.Items
                    If String.Equals(itemsc.Text.Trim.Replace(" ", ""), ShipCondition.Replace(" ", "")) Then
                        drpShipCondition.SelectedValue = itemsc.Value
                    End If
                Next
            End If
            'If MailUtil.IsAENCSale() Then
            '    trOrderNo.Visible    = True 
            'End If

            'AJP Settings
            If AuthUtil.IsAJP Then
                dlPayterm.Enabled = False
                trON.Visible = False
                trKeyInPerson.Visible = False
                trDSGSO.Visible = False
                trFreTax.Visible = False

                'Ryan 20170628 For AJP revenue split settings
                EnableRevenueSplitSettings()

                If Util.IsInternalUser2() Then
                    txtSalesNote.Text = "Repeat SO number: (in case of repeat order)" + vbCrLf + "Reason of need extra check of CTOS: (in case of needed)" + vbCrLf + txtSalesNote.Text
                End If
            End If

            'ACN Settings
            If AuthUtil.IsACN Then
                dlPayterm.Enabled = False
                stShipCondition.Visible = False
                trFreTax.Visible = False
                trBillInfo.Visible = False
                trDSGSO.Visible = True

                trKeyInPerson.Visible = True
                lbKeyInPerson.Text = "Inside Sales/Key In Person"
                ddlKeyInPerson.Items.Insert(0, New ListItem("Select…", ""))

                'Ryan 20170907 Clear all list items in dlDistChann, and only add 10 per Jingjing's request.
                dlDistChann.Items.Clear()
                dlDistChann.Items.Add(New ListItem("Select...", ""))
                dlDistChann.Items.Add(New ListItem("10", "10"))

                'Ryan 20180814 Check if trOSBitSelection should be visible or not.
                If CInt(dbUtil.dbExecuteScalar("MY", String.Format(" select count(*) as count from cart_DETAIL_V2 a inner join SpecialOSParts b on a.Part_No = b.PartNo where a.Cart_Id = '{0}' and b.Org = 'CN'", CartId))) > 0 Then
                    Me.trOSBitSelection.Visible = True
                End If
            End If

            'Intercon Settings
            If AuthUtil.IsInterConUserV2 Then
                If Util.IsInternalUser2 AndAlso AuthUtil.IsInterConUserV3 Then
                    tdFileUpload.Visible = True
                End If

                Me.trFreTax.Visible = False
            End If

            'Ryan 20170906 BBUS settings
            If AuthUtil.IsBBUS Then
                Me.trFreTax.Visible = False
                'Me.trFreightBB.Visible = True
                Me.tdbillto.Visible = True
                Me.tdbilltoascx.Visible = True
                Me.tdShipVia.Visible = False

                Me.trBBUSFreightChargeBy.Visible = True : Me.trBBUSCustomTaxChargeBy.Visible = True

                'Alex 2017/10/18: Show bb freight option for B+B
                Me.trFreightOptionBB.Visible = True
                'GetFreight()

                'Dim freightOptions As List(Of Advantech.Myadvantech.DataAccess.FreightOption) = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetAllFreightOptions()
                'If freightOptions.Count > 0 Then
                '    For Each o As Advantech.Myadvantech.DataAccess.FreightOption In freightOptions
                '        Dim li As New ListItem()
                '        li.Text = o.SAPCode + ": " + o.Description
                '        li.Value = o.CarrierCode + ": " + o.Description
                '        Me.ddlFreightOption.Items.Add(li)
                '    Next
                'End If

                Me.trBBUSContact.Visible = True
                Me.trBBUSTax.Visible = True
                If AuthUtil.IsBBDropShipmentCustomer Then
                    Me.trBBUSDropShipment.Visible = True
                End If
                'Me.trBBUSDropShipment.Visible = True


                Me.ddlSE.Enabled = False
                Dim defaultBBVE As Object = dbUtil.dbExecuteScalar("MY", String.Format("select TOP 1 SALES_CODE from SAP_COMPANY_EMPLOYEE where COMPANY_ID = '{0}' AND PARTNER_FUNCTION = 'VE'", Session("company_id")))
                If defaultBBVE IsNot Nothing AndAlso Not String.IsNullOrEmpty(defaultBBVE) AndAlso ddlSE.Items.FindByValue(defaultBBVE.ToString) IsNot Nothing Then
                    ddlSE.SelectedValue = (defaultBBVE.ToString)
                Else
                    ddlSE.SelectedIndex = 0
                End If

                'Ryan 20180103 Only set its courier account from SAP inco2 if value is valid (length >=6 andalso not "Ottawa IL")
                If Not String.IsNullOrEmpty(Me.txtIncoterm.Text) AndAlso Me.txtIncoterm.Text.Length >= 6 AndAlso Not Me.txtIncoterm.Text.Equals("Ottawa IL", StringComparison.OrdinalIgnoreCase) Then
                    Me.txtCourier.Text = Me.txtIncoterm.Text
                End If

                'Ryan 20180601 Set default Incoterm as FCA per Tracy's request
                If drpIncoterm.Items.FindByValue("FCA") IsNot Nothing Then
                    drpIncoterm.SelectedValue = "FCA"
                End If
            End If

            'Ryan 20180322 ADLOG settings
            If AuthUtil.IsADloG Then
                EnableRevenueSplitSettings()
                Me.trEmployeeResponse.Visible = True
                Me.lbEmployeeResponse.Text = "Employee Responsible"

                ddlEmployeeResponse.Items.Clear()
                For Each r As ListItem In ddlSE.Items
                    ddlEmployeeResponse.Items.Add(New ListItem(r.Text, r.Value))
                Next

                'Ryan 20180706 Hide DRPs for ADLoG external users
                If Not Util.IsInternalUser2 Then
                    FillSalesEmployees()
                    Me.trSE.Visible = False
                    Me.trRevenueSplit.Visible = False
                    Me.trEmployeeResponse.Visible = False
                End If

                ' Set company default VE & ZA & ZM to drop down list
                Dim defaultADLoGVE As Object = dbUtil.dbExecuteScalar("MY", String.Format("select TOP 1 SALES_CODE from SAP_COMPANY_EMPLOYEE where COMPANY_ID = '{0}' AND PARTNER_FUNCTION = 'VE'", Session("company_id")))
                If defaultADLoGVE IsNot Nothing AndAlso Not String.IsNullOrEmpty(defaultADLoGVE) AndAlso ddlSE.Items.FindByValue(defaultADLoGVE.ToString) IsNot Nothing Then
                    ddlSE.SelectedValue = (defaultADLoGVE.ToString)
                End If
                Dim defaultADLoGZA As Object = dbUtil.dbExecuteScalar("MY", String.Format("select TOP 1 SALES_CODE from SAP_COMPANY_EMPLOYEE where COMPANY_ID = '{0}' AND PARTNER_FUNCTION = 'ZA'", Session("company_id")))
                If defaultADLoGZA IsNot Nothing AndAlso Not String.IsNullOrEmpty(defaultADLoGZA) AndAlso ddlRevenueSpiltPerson.Items.FindByValue(defaultADLoGZA.ToString) IsNot Nothing Then
                    ddlRevenueSpiltPerson.SelectedValue = (defaultADLoGZA.ToString)
                End If
                Dim defaultADLoGZM As Object = dbUtil.dbExecuteScalar("MY", String.Format("select TOP 1 SALES_CODE from SAP_COMPANY_EMPLOYEE where COMPANY_ID = '{0}' AND PARTNER_FUNCTION = 'ZM'", Session("company_id")))
                If defaultADLoGZM IsNot Nothing AndAlso Not String.IsNullOrEmpty(defaultADLoGZM) AndAlso ddlEmployeeResponse.Items.FindByValue(defaultADLoGZM.ToString) IsNot Nothing Then
                    ddlEmployeeResponse.SelectedValue = (defaultADLoGZM.ToString)
                End If
            End If

            If AuthUtil.IsAVN Then
                If MyCartX.IsHaveBtos(CartId) Then
                    Me.trAVNBTOSOption.Visible = True
                End If
            End If

            If AuthUtil.IsASG Then
                If Util.IsInternalUser2 AndAlso MyCartX.IsHaveBtos(CartId) Then
                    ' Enable BTOS instruction block for ASG
                    Me.trBTOSInstruction.Visible = True
                    Me.rpBTOSInstruction.DataSource = dbUtil.dbGetDataTable("MY", String.Format("select * from cart_DETAIL_V2 where Cart_Id = '{0}' and otype = '-1'", CartId))
                    Me.rpBTOSInstruction.DataBind()
                End If
            End If

            'Ryan 20160328 If is check point order then set it's req date to now date +2
            If IsCheckPointOrder Then
                txtreqdate.Text = MyCartOrderBizDAL.getCompNextWorkDateV2(DateTime.Now, "UZISCHE01", 2).ToString("yyyy/MM/dd")
            End If

        End If
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        'Ryan 20151222 Add for Check-Point convert2order event check. If true, perform auto click
        If (Not String.IsNullOrEmpty(CheckPoint_Convert2Order)) AndAlso (CheckPoint_Convert2Order = HttpContext.Current.Session("cart_id")) Then
            btnPIPreview_Click(btnPIPreview, e)
        End If
    End Sub

    Sub initInterface()
        initShipConDrp() : initIncoDrp()
        For i As Integer = Now.Year To Now.Year + 15
            dlCCardExpYear.Items.Add(New ListItem(i.ToString(), i.ToString()))
        Next
        Dim PoNum As String = "", attention As String = "", isPartial As String = "", shipCon As String = "", incotermdrp As String = ""
        Dim incotermText As String = "", orderNote As String = "", salesNote As String = "", opNote As String = "", pjNote As String = ""
        Dim DMFflag As String = "", ShipTodrp As String = "", ShipToText As String = "", ShipToAtt As String = ""
        ' nada adjusted ''ming get local time
        Dim localtime As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        Dim reqDate As DateTime = Now

        If Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            '\Ming fixed for OrderV2
            If MyCartX.IsHaveBtos(CartId) Then
                If MyCartX.IsHaveSBCB(CartId) Then
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(localtime, Session("org_id"), 1) ' Normal: +5
                Else
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(localtime, Session("org_id"), Glob.getBTOWorkingDate()) ' Normal: +5  
                End If
            Else
                Dim USwestTime As DateTime = localtime 'DateTime.Now.ToUniversalTime.AddHours(-8)
                If USwestTime.Hour >= 13 Then
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(USwestTime, Session("org_id"), 1) ' not BTOS & > 13:00: +1
                Else
                    reqDate = USwestTime '.Date.ToString("yyyy/MM/dd") ' not BTOS & < 13:00: +0
                End If
            End If
            '/end
            'If mycart.isBtoOrder(CartId) Then
            '    If mycart.isSBCBtoOrder(CartId) Then
            '        reqDate = MyCartOrderBizDAL.getCompNextWorkDate(localtime, Session("org_id"), 1) ' SBC: +1
            '    Else
            '        reqDate = MyCartOrderBizDAL.getCompNextWorkDate(localtime, Session("org_id"), Glob.getBTOWorkingDate()) ' Normal: +5
            '    End If
            'Else
            '    If localtime.Hour >= 13 Then
            '        reqDate = MyCartOrderBizDAL.getCompNextWorkDate(localtime, Session("org_id"), 1) ' not BTOS & > 13:00: +1
            '    Else
            '        reqDate = localtime.Date.ToString("yyyy/MM/dd") ' not BTOS & < 13:00: +0
            '    End If
            'End If
        ElseIf Session("org_id").ToString.Trim.StartsWith("CN", StringComparison.OrdinalIgnoreCase) Then
            'Ryan 20171006 Add 5 days from now for ACN per Blanche's request.
            reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(localtime, Session("org_id"), 5)
        ElseIf AuthUtil.IsBBUS Then
            Dim USCentralTime As DateTime = SAPDOC.GetLocalTime("BB")

            'US10 BTOS will take US01's required date rule
            If MyCartX.IsHaveBtos(CartId) Then
                If MyCartX.IsHaveSBCB(CartId) Then
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(localtime, "US01", 1)
                Else
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(localtime, "US01", Glob.getBTOWorkingDate())
                End If
            Else
                If USCentralTime.Hour >= 15 Then
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(USCentralTime, Session("org_id"), 1)
                Else
                    reqDate = USCentralTime
                End If
            End If
        Else
            reqDate = DateAdd(DateInterval.Day, 1, localtime) '.Date.ToString("yyyy/MM/dd")

            If mycart.isBtoOrder(CartId) Then
                reqDate = MyCartOrderBizDAL.getBTOParentDueDate(reqDate)
            Else
                reqDate = MyCartOrderBizDAL.getCompNextWorkDateV2(reqDate, Session("org_id"))
            End If
        End If

        Me.txtreqdate.Text = reqDate.Date.ToString("yyyy/MM/dd")

        'Ryan 20160516
        If IsEUBtosOrder Then
            Me.txtreqdate.Text = ""
        End If

        'end
        Dim dt As DataTable = myCompany.GetDT(String.Format("company_id='{0}' and org_id='{1}'", Session("Company_id"), Session("org_id")), "")
        If dt.Rows.Count > 0 Then
            attention = dt.Rows(0).Item("ATTENTION") : shipCon = dt.Rows(0).Item("SHIPCONDITION")
            If Not IsDBNull(dt.Rows(0).Item("INCO1")) Then
                incotermdrp = dt.Rows(0).Item("INCO1")
            End If
            If Not IsDBNull(dt.Rows(0).Item("INCO2")) Then
                incotermText = dt.Rows(0).Item("INCO2")
            End If
        End If

        '20120503 TC: If company id has weekly ship date setup in SAP, then get nearest ship week date
        'Dim tmpNextWeekShipDate As Date = CDate(Me.txtreqdate.Text)
        'If MyCartOrderBizDAL.GetNextWeeklyShippingDate(CDate(Me.txtreqdate.Text), tmpNextWeekShipDate) Then Me.txtreqdate.Text = tmpNextWeekShipDate.ToString("yyyy/MM/dd")


        ''Frank 2012/11/23:If Order was created by uploading excel file,then getting max require date of cart detail and to be req_date
        'Dim _upDA As New MyCartDSTableAdapters.UPLOAD_ORDER_PARATableAdapter
        'Dim _UploadFromExcelCount As Integer = _upDA.GetCountByCartID(Me.CartId)
        'If _UploadFromExcelCount > 0 Then
        '    Dim _sql As String = "Select Max(req_date) as Max_Req_Date From CART_DETAIL Where Cart_Id='" & Me.CartId & "'"
        '    Dim _dtMaxReqDate As DataTable = dbUtil.dbGetDataTable("MY", _sql)
        '    If _dtMaxReqDate IsNot Nothing AndAlso _dtMaxReqDate.Rows.Count > 0 Then Me.txtreqdate.Text = Format(_dtMaxReqDate.Rows(0).Item("Max_Req_Date"), "yyyy/MM/dd")
        'End If

        'Frank: Only release tax exempt user control for US AOnline user
        If AuthUtil.IsUSAonlineSales(User.Identity.Name) Then
            Me.tbExempt.Visible = True
        End If

        Me.cbxIsTaxExempt.Checked = IIf(SAPDAL.SAPDAL.isTaxExempt(Session("Company_id")), 1, 0)

        'Me.txtShipTo.Text = Session("Company_id")
        Dim _quoteId As String = ""
        If mycart.isQuote2Order(CartId, _quoteId) Then
            'orderaddressesforus.Visible = True
            'Dim WS As New quote.quoteExit : WS.Timeout = -1
            'If Util.IsTestingQuote2Order() Then
            '    WS.Url = "http://eq.advantech.com:8300/Services/QuoteExit.asmx?wsdl"
            'End If
            Dim _QuoteMaster As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(_quoteId)
            Dim _QuoteDetail As List(Of QuotationDetail) = eQuotationUtil.GetQuoteDetailByQuoteid(_quoteId)
            Dim _QuotePartner As List(Of EQPARTNER) = eQuotationUtil.GetEQPartnerByQuoteid(_quoteId)
            Dim _QuoteNotes As List(Of QuotationNote) = eQuotationUtil.GetQuotationNoteByQuoteid(_quoteId)
            '  Dim ReturnValue As Boolean = WS.getQuotationMasterByIdV4(quoteId, QuoteMaster, QuoteDetail, QuotePartner, QuoteNotes)
            If _QuoteMaster IsNot Nothing AndAlso _QuoteDetail.Count > 0 Then
                If _QuotePartner IsNot Nothing AndAlso _QuotePartner.Count > 0 Then
                    For Each partner As EQPARTNER In _QuotePartner
                        With partner
                            Dim _address As OrderAddress = Nothing
                            If .TYPE.ToUpper = "SOLDTO" Then
                                _address = soldtoaddress
                            ElseIf .TYPE.ToUpper = "S" Then
                                _address = shiptoaddress
                            ElseIf .TYPE.ToUpper = "B" Then
                                _address = billtoaddress
                            End If
                            If _address IsNot Nothing Then
                                If String.IsNullOrEmpty(.ERPID) AndAlso .TYPE.ToUpper <> "B" Then
                                    _address.ERPID = Session("Company_id")
                                Else
                                    _address.ERPID = .ERPID
                                End If

                                If Session("Quote3") IsNot Nothing AndAlso Session("Quote3") = True Then
                                    _address.Name = .NAME
                                    _address.Tel = .TEL : _address.Attention = .ATTENTION
                                    _address.City = .CITY : _address.State = .STATE
                                    _address.Street = .ADDRESS : _address.Zipcode = .ZIPCODE
                                    _address.Country = .COUNTRY : _address.Street2 = .STREET

                                    If AuthUtil.IsBBUS Then
                                        _address.taxJuri = .STATE + .ZIPCODE
                                    End If
                                Else
                                    _address.Name = .NAME
                                    _address.Tel = .TEL : _address.Attention = .ATTENTION
                                    _address.City = .CITY : _address.State = .STATE
                                    _address.Street = .STREET : _address.Zipcode = .ZIPCODE
                                    _address.Country = .COUNTRY : _address.Street2 = .STREET2
                                End If
                            End If
                            If .TYPE.Trim.Equals("E", StringComparison.OrdinalIgnoreCase) Then
                                If Not IsDBNull(.ERPID) AndAlso Not String.IsNullOrEmpty(.ERPID) Then
                                    If ddlSE.Items.FindByValue(.ERPID) IsNot Nothing Then
                                        ddlSE.SelectedValue = .ERPID
                                    End If
                                End If
                            End If
                            If .TYPE.Trim.Equals("E2", StringComparison.OrdinalIgnoreCase) Then
                                If Not IsDBNull(.ERPID) AndAlso Not String.IsNullOrEmpty(.ERPID) Then
                                    If ddlSE2.Items.FindByValue(.ERPID) IsNot Nothing Then
                                        ddlSE2.SelectedValue = .ERPID
                                    End If
                                End If
                            End If
                            If .TYPE.Trim.Equals("E3", StringComparison.OrdinalIgnoreCase) Then
                                If Not IsDBNull(.ERPID) AndAlso Not String.IsNullOrEmpty(.ERPID) Then
                                    If ddlSE3.Items.FindByValue(.ERPID) IsNot Nothing Then
                                        ddlSE3.SelectedValue = .ERPID
                                    End If
                                End If
                            End If
                        End With
                    Next
                    With _QuoteMaster
                        If Not String.IsNullOrEmpty(.PO_NO) Then
                            txtPONo.Text = .PO_NO
                        End If
                        'Frank 2014/02/11 EX Works is only used in eQuotation ship condition option for AEU Sales, no need to apply in MyAdvantech order info page.
                        If Not String.IsNullOrEmpty(.shipTerm) AndAlso Not .shipTerm.Equals("EX Works", StringComparison.OrdinalIgnoreCase) Then
                            shipCon = .shipTerm
                        End If
                        If Not IsDBNull(.DIST_CHAN) AndAlso Not String.IsNullOrEmpty(.DIST_CHAN) Then
                            If dlDistChann.Items.FindByValue(.DIST_CHAN) IsNot Nothing Then
                                dlDistChann.SelectedValue = .DIST_CHAN : dlDistChann_SelectedIndexChanged(Nothing, Nothing)
                            End If
                        End If

                        If Not IsDBNull(.paymentTerm) AndAlso Not String.IsNullOrEmpty(.paymentTerm) Then
                            'If dlPayterm.Items.FindByValue(.paymentTerm) IsNot Nothing Then
                            '    dlPayterm.SelectedValue = .paymentTerm : dlPayterm_SelectedIndexChanged(Nothing, Nothing)
                            'End If
                            'Ming 20150508 TW转单时不再预设Quote的PaymentTrem值
                            If (Not .quoteNo.StartsWith("TWQ", StringComparison.InvariantCultureIgnoreCase)) AndAlso
                                (Not .quoteNo.StartsWith("ACNQ", StringComparison.InvariantCultureIgnoreCase)) AndAlso
                                (Not .quoteNo.StartsWith("AKRQ", StringComparison.InvariantCultureIgnoreCase)) Then
                                EQpaymentTerm = .paymentTerm
                            End If
                        End If
                        If Not IsDBNull(.DIVISION) AndAlso Not String.IsNullOrEmpty(.DIVISION) Then
                            If ddlDivision.Items.FindByValue(.DIVISION) IsNot Nothing Then
                                ddlDivision.SelectedValue = .DIVISION
                            End If
                        End If
                        If Not IsDBNull(.SALESGROUP) AndAlso Not String.IsNullOrEmpty(.SALESGROUP) Then
                            If ddlSalesGroup.Items.FindByValue(.SALESGROUP) IsNot Nothing Then
                                ddlSalesGroup.SelectedValue = .SALESGROUP
                            End If
                        End If
                        If Not IsDBNull(.SALESOFFICE) AndAlso Not String.IsNullOrEmpty(.SALESOFFICE) Then
                            If ddlSalesOffice.Items.FindByValue(.SALESOFFICE) IsNot Nothing Then
                                ddlSalesOffice.SelectedValue = .SALESOFFICE
                            End If
                        End If
                        If Not IsDBNull(.DISTRICT) AndAlso Not String.IsNullOrEmpty(.DISTRICT) Then
                            txtSalesDistrict.Text = .DISTRICT.Trim
                        End If
                        If Not IsDBNull(.INCO1) AndAlso Not String.IsNullOrEmpty(.INCO1) Then
                            If drpIncoterm.Items.FindByValue(.INCO1) IsNot Nothing Then
                                incotermdrp = .INCO1
                            End If
                        End If
                        If Not IsDBNull(.INCO2) AndAlso Not String.IsNullOrEmpty(.INCO2) Then
                            txtIncoterm.Text = .INCO2 : incotermText = txtIncoterm.Text
                        End If
                        If .isExempt = 1 Then
                            cbxIsTaxExempt.Checked = True
                        Else
                            cbxIsTaxExempt.Checked = False
                        End If
                    End With
                End If
                If _QuoteNotes IsNot Nothing AndAlso _QuoteNotes.Count > 0 Then
                    For Each dr As QuotationNote In _QuoteNotes
                        If dr.notetype.Trim.Equals("SalesNote", StringComparison.OrdinalIgnoreCase) Then
                            'Ming 20141028 仿eStore salesNote里面加Freight信息
                            txtSalesNote.Text = dr.notetext
                            If String.Equals(Session("org_id"), "US01") AndAlso _QuoteMaster.freight IsNot Nothing AndAlso Decimal.TryParse(_QuoteMaster.freight, 0) AndAlso Decimal.Parse(_QuoteMaster.freight) > 0 Then
                                txtSalesNote.Text = String.Format("To Shipping: Signature Req. Online Freight: {1} {0} ", _QuoteMaster.freight, eQuotationUtil.GetExpressCompanyByQuoteid(_QuoteMaster.quoteId)) + dr.notetext
                            End If
                        End If
                        If dr.notetype.Trim.Equals("OrderNote", StringComparison.OrdinalIgnoreCase) Then
                            txtOrderNote.Text = dr.notetext
                        End If
                    Next
                End If

                'Ryan 20170206 Add AJP terms summary to sales note field.
                If Session("org_id") = "JP01" AndAlso Util.IsInternalUser2() Then
                    txtSalesNote.Text = Advantech.Myadvantech.Business.OrderBusinessLogic.GetAJPTermsSummary(_quoteId) + vbCrLf + txtSalesNote.Text
                End If
            End If
        End If
        'Nada 20131209 load SHTC products to Order Note for TW 
        'Ming  20150806 Include EU for showing such notice information in order note
        'Dim orgid As String = Session("org_id").ToString.ToUpper.Trim
        'If (orgid.StartsWith("TW") OrElse orgid.StartsWith("EU")) AndAlso Not txtOrderNote.Text.ToUpper.Contains("(SHTC)") Then
        '    txtOrderNote.Text &= MYSAPBIZ.getOrderNoteBySHTCProduct()
        'End If
        'Frank 20150812 release this notice to all region        
        txtOrderNote.Text &= MYSAPBIZ.getOrderNoteBySHTCProduct()

        'Ryan 20160412 Add ordernote for IDM items
        If String.Equals(Session("org_id"), "EU10") Then
            Dim str As String = String.Format("select a.Part_No,b.TXT from cart_DETAIL_V2 a left join SAP_PRODUCT_ORDERNOTE b " &
                                               "on a.Part_No = b.PART_NO where a.PART_NO like 'IDM%' and a.Cart_Id = '{0}'", CartId)
            Dim cart_dt As DataTable = dbUtil.dbGetDataTable("MY", str)
            If Not IsNothing(cart_dt) AndAlso dt.Rows.Count > 0 Then
                If Not String.IsNullOrEmpty(txtOrderNote.Text) Then
                    txtOrderNote.Text &= vbNewLine
                End If
                For Each r As DataRow In cart_dt.Rows
                    txtOrderNote.Text &= r.Item("Part_No") + " Note: " & vbNewLine + r.Item("TXT") & vbNewLine
                Next
            End If
        ElseIf Session("org_id").ToString.StartsWith("CN") AndAlso MyCartX.IsHaveBtos(CartId) = True Then

            'ICC 20170731 For ACN 中科專案，將母階原本的料號，從order note 取出提示文字，放到 order note 當中
            Dim parentItems As List(Of CartItem) = MyCartX.GetBtosParentItems(CartId)
            If Not parentItems Is Nothing AndAlso parentItems.Count > 0 Then
                For Each parentItem As CartItem In parentItems
                    If Not String.IsNullOrEmpty(parentItem.Category) AndAlso parentItem.Category.StartsWith("CM-") Then
                        Dim txt As Object = dbUtil.dbExecuteScalar("MY", String.Format("SELECT TOP 1 TXT FROM SAP_PRODUCT_ORDERNOTE WHERE PART_NO = '{0}' AND ORG = '{1}'", parentItem.Category, Session("org_id").ToString()))
                        If Not txt Is Nothing Then
                            txtOrderNote.Text = txt.ToString
                            txtSalesNote.Text = txt.ToString
                        End If
                    End If
                Next
            End If

            'Ryan 20170828 Add [三防服务] to txtOrderNote if specific items are placed per Tianlan's request
            Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(CartId)
            If _cartlist.Where(Function(p) p.Part_No.ToUpper.Equals("AGS-CTOS-SCCS-N300") OrElse p.Part_No.ToUpper.Equals("AGS-CTOS-SCCS-W400")).Any Then
                txtOrderNote.Text = txtOrderNote.Text + " [三防服务]"
            End If

        End If

        Me.drpShipCondition.SelectedValue = shipCon : Me.drpIncoterm.SelectedValue = incotermdrp
        Me.txtIncoterm.Text = incotermText
        'Nada modified to append sales note and ctos note
        'Me.txtSalesNote.Text += vbLf + MYSAPBIZ.getSalesNotebyCustomer(Session("Company_id")).Trim()
        Me.txtSalesNote.Text += vbLf + MYSAPBIZ.getSalesNotebyCustomer(Session("Company_id")).Trim()

        '20130813 TC: Comment getting default CTOS note first and waiting for Jay's decision to see if we can let sales pick CTOS note by themselves instead
        'Dim cnot As String = SAPDAL.SAPDAL.GetCTOSAssemblyInstructionListByERPIdFromMyadvantech1(Session("Company_id"))
        'If Not String.IsNullOrEmpty(cnot.Trim().Trim("****")) Then
        '    Me.txtSalesNote.Text += vbLf + "CTOS Special Introduction : " + vbLf + cnot
        'End If

        If Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) AndAlso Not Util.IsInternalUser2() Then
            Me.trSN.Visible = False ' : Me.trPJN.Visible = False : Me.trOPN.Visible = False 
        End If
        Me.trOPN.Visible = False
        If Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
            Me.trOPN.Visible = True
        End If

        If Util.IsInternalUser2() Then trBillInfo.Visible = True


        'If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) AndAlso Util.IsInternalUser2 Then
        '    Me.tbExempt.Visible = True
        'End If

        'If mycart.isBtoOrder(CartId) Then
        '    Me.rbtnIsPartial.Enabled = False
        'Else
        '    If MYSAPBIZ.isCustomerCompleteDeliv(Session("Company_id"), Session("Org_id")) Then
        '        Me.rbtnIsPartial.SelectedValue = "0"
        '    End If
        'End If

        'Ryan 20160328 Add for CheckPoint PO No
        If IsCheckPointOrder Then
            Dim cp_pono As String = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetCustPONoByCartID(CartId)
            Dim cp_dnno As String = Advantech.Myadvantech.Business.CPDBBusinessLogic.GetCustDNNoByCartID(CartId)

            txtPONo.Text = cp_pono + (IIf(String.IsNullOrEmpty(cp_dnno), "", "/" + cp_dnno))
        End If

    End Sub


    Sub initShipConDrp()
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct VSBED AS SHIPCONDITION,'' as SHIPCONTXT from SAP_SHIPCONDITION_BY_PLANT where WERKS like '" & Session("org") & "%'"))
        'Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct VSBED AS SHIPCONDITION,'' as SHIPCONTXT from SAP_SHIPCONDITION_BY_PLANT where WERKS like '" & Left(Session("org_id"), 2) & "%'"))
        'If dt.Rows.Count > 0 Then
        '    For I As Integer = 0 To dt.Rows.Count - 1
        '        dt.Rows(I).Item("SHIPCONTXT") = Glob.shipCode2Txt(dt.Rows(I).Item("SHIPCONDITION"))
        '    Next
        'End If

        'Ryan 20180105 Get ship condition from SAP instead
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", " select vsbed as SHIPCONDITION, vtext as SHIPCONTXT from saprdp.tvsbt where mandt='168' and spras='E' order by vsbed")

        Me.drpShipCondition.DataSource = dt : Me.drpShipCondition.DataTextField = "SHIPCONTXT" : Me.drpShipCondition.DataValueField = "SHIPCONDITION" : Me.drpShipCondition.DataBind()
    End Sub
    Sub initIncoDrp()
        'Ming 20150413 只有AOnline.USA這個群組的成員在轉訂單時，MyAdvantech order info頁面中的payment term只出現FB1與 EXW兩個選項。
        'This requirement for Denise.Kwong
        Dim dt As DataTable = New DataTable
        If MailUtil.IsInMailGroup("AOnline.USA", User.Identity.Name) Then
            dt.Columns.Add("INCO1")
            Dim dr As DataRow = dt.NewRow : dr("INCO1") = "FB1" : dt.Rows.Add(dr)
            dr = dt.NewRow : dr("INCO1") = "EXW" : dt.Rows.Add(dr)
        Else
            dt = myCompany.GetDTbySelectStr(String.Format("select distinct isnull(INCO1,'') as INCO1 from {0}", myCompany.tb))
        End If
        Me.drpIncoterm.DataSource = dt : Me.drpIncoterm.DataTextField = "INCO1" : Me.drpIncoterm.DataValueField = "INCO1" : Me.drpIncoterm.DataBind()
    End Sub

    Sub DBfromCart2Order(ByVal Cart_ID As String)
        myOrderMaster.Delete(String.Format("order_id='{0}'", Cart_ID)) : myOrderDetail.Delete(String.Format("order_id='{0}'", Cart_ID))
        Dim ORDER_ID As String = Cart_ID, ORDER_NO As String = "", ORDER_TYPE As String = "ZOR2"
        If Left(Session("org_id"), 2) = "CN" Then
            ORDER_TYPE = "ZOR"
        End If
        If String.Equals(rbOrderNo.SelectedValue.Trim, "1") Then
            ORDER_TYPE = "ZOR"
        End If
        'If MyCartOrderBizDAL.isODMCartV2(Cart_ID) Then
        '    ORDER_TYPE = "ZOR6"txtpono
        'End If
        If MyCartX.IsEUBtosCart(Cart_ID) Then
            ORDER_TYPE = "ZOR6"
        End If

        'Ryan 20180305 Add from wide to narrow processing to PO_NO text
        Dim PO_NO As String = Util.StringFromWide2Narrow(Me.txtPONo.Text)
        'Alex add: remove tab/enter/space character in PO_NO textbox
        PO_NO = PO_NO.Replace(vbTab, "").Replace(vbLf, "").Replace(vbCr, "").Replace(vbCrLf, "").Replace(" ", "")
        'Alex 20160615 add: remove special symbol(like →)
        PO_NO = Regex.Replace(PO_NO, "[^\p{L}\p{N}`~!@#$%^&*\(\)_\-\+\[\]\{\}\|\\\.\?\,\'\/<>:;""\=]", "")

        Dim PO_DATE As DateTime
        If String.IsNullOrEmpty(Me.txtPODate.Text.Trim) Then
            PO_DATE = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        Else
            PO_DATE = CDate(Me.txtPODate.Text)
        End If
        Dim SOLDTO_ID As String = Session("company_id"), SHIPTO_ID As String = Me.txtShipTo.Text.Trim.Replace("'", "''")
        If Not MYSAPBIZ.is_Valid_Company_Id_All(SHIPTO_ID) Then
            SHIPTO_ID = SOLDTO_ID
        End If
        '\ 2013-11-13 Ming add for localtime 
        Dim localtime As Date = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        '/ end
        Dim ATTENTION As String = Me.txtAttention.Text.Trim, PARTIALFLAG As String = Me.rbtnIsPartial.SelectedValue
        Dim MREQDATE As Date = CDate(IIf(Me.txtreqdate.Text.Trim = "", localtime, Me.txtreqdate.Text.Trim))
        Dim MDUEDATE As Date = localtime, SHIPVIA As String = "", CURRENCY As String = Session("Company_currency")
        Dim ORDER_NOTE As String = Me.txtOrderNote.Text.Trim
        'If Me.chxNewShip.Checked Then
        '    Dim shipInfo As String = String.Format("[Addr:{0};Tel:{1}]", Me.txtShipToAddr.Text.Trim, Me.txtShipToTel.Text.Trim)
        '    ORDER_NOTE = ORDER_NOTE & " " & shipInfo
        'End If
        Dim INCOTERM As String = Me.drpIncoterm.SelectedValue, CUSTOMER_ATTENTION As String = Me.txtShipToAttention.Text.Trim
        Dim INCOTERM_TEXT As String = Me.txtIncoterm.Text.Trim, SALES_NOTE As String = Me.txtSalesNote.Text.Trim
        Dim OP_NOTE As String = Me.txtOPNote.Text.Trim, SHIP_CONDITION As String = Me.drpShipCondition.SelectedValue
        Dim prj_Note As String = "" 'Me.txtPJNote.Text.Trim
        Dim ISESE As String = "", ERE As String = "", EC As String = "", PAR1 As String = ""
        If Not IsNothing(Request("ISESE")) AndAlso Request("ISESE") <> "" Then
            ISESE = Request("ISESE")
        End If
        If Not IsNothing(Request("ERE")) AndAlso Request("ERE") <> "" Then
            ERE = Request("ERE")
        End If
        If Not IsNothing(Request("EC")) AndAlso Request("EC") <> "" Then
            EC = Request("EC")
        End If
        If Not IsNothing(Request("PAR1")) AndAlso Request("PAR1") <> "" Then
            PAR1 = Request("PAR1")
        End If

        ' Dim DT As DataTable = mycart.GetDT(String.Format("cart_id='{0}'", Cart_ID), "Line_no")
        Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(Cart_ID)
        If _cartlist.Count > 0 Then
            'Dim dtEW As New DataTable
            'With dtEW.Columns
            '    .Add("Line_No") : .Add("Part_No") : .Add("otype") : .Add("qty") : .Add("req_date") : .Add("due_date") : .Add("islinePartial")
            '    .Add("UNIT_PRICE", GetType(Decimal)) : .Add("delivery_plant") : .Add("DMF_Flag") : .Add("OptyID") : .Add("subTotal", GetType(Decimal))
            '    .Add("HigherLevel", GetType(Integer))
            'End With
            Dim count As Integer = 0, BTOChildDate As Date = localtime

            'Frank 2012/11/23:If Order was created by uploading excel file,
            'then getting require date of cart detail and to be order detail req_date
            Dim ltime As String = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
            For Each _cartitem As CartItem In _cartlist
                Dim LINE_NO As Integer = _cartitem.Line_No, PRODUCT_LINE As String = "", PART_NO As String = _cartitem.Part_No
                Dim ORDER_LINE_TYPE As String = _cartitem.otype, QTY As Integer = _cartitem.Qty, LIST_PRICE As Decimal = _cartitem.List_Price
                Dim UNIT_PRICE As Decimal = _cartitem.Unit_Price, REQUIRED_DATE As Date = _cartitem.req_date
                Dim HigherLevel As Integer = 0
                If Not IsDBNull(_cartitem.higherLevel) AndAlso Integer.TryParse(_cartitem.higherLevel, 0) Then
                    HigherLevel = Integer.Parse(_cartitem.higherLevel)
                End If
                If _cartitem.otype = CartItemType.Part Then

                    'Ryan 20160720 全球都開放可以根據頁面上設定的REQ DATE進行日期更新
                    REQUIRED_DATE = MREQDATE
                    'Ryan 20160720 comment out old logic-------------------------------------
                    ''Ming 20140409 下面这段逻辑有点奇怪，但美国已经用很久没人反应这个问题，证明可能已经习惯这种逻辑
                    'If Me.rbtnIsPartial.SelectedValue = "0" Then
                    '    REQUIRED_DATE = MREQDATE
                    'End If
                    ''Ming 20140409 上面一段逻辑已不符合TW和EU需求，所以加如下一段逻辑
                    'If Session("org_id") IsNot Nothing AndAlso (Session("org_id").ToString.Trim.Equals("TW01", StringComparison.OrdinalIgnoreCase) OrElse Session("org_id").ToString.Trim.Equals("EU10", StringComparison.OrdinalIgnoreCase)) Then
                    '    REQUIRED_DATE = MREQDATE
                    'End If
                    'End comment--------------------------------------------------------------


                    Dim quoteId As String = ""
                    If mycart.isQuote2Order(CartId, quoteId) AndAlso Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                        Dim QuoteMaster As QuotationMaster = eQuotationUtil.CurrentDC.QuotationMasters.Where(Function(p) p.quoteId = quoteId).FirstOrDefault
                        'If QuoteMaster IsNot Nothing AndAlso (QuoteMaster.quoteId.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase) OrElse _
                        '                                       (QuoteMaster.quoteNo IsNot Nothing AndAlso QuoteMaster.quoteNo.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase))) Then
                        '    REQUIRED_DATE = MREQDATE
                        'End If
                        'Ming 20151111 US01下其它組織也應該符合一下邏輯.
                        If QuoteMaster IsNot Nothing Then
                            REQUIRED_DATE = MREQDATE
                        End If
                    End If
                    'If _UploadFromExcelCount > 0 AndAlso Not IsDBNull(r.Item("req_date")) AndAlso Date.TryParse(r.Item("req_date"), Now) Then
                    '    REQUIRED_DATE = Date.Parse(r.Item("req_date"))
                    'End If

                Else
                    Dim temp As String = MyCartOrderBizDAL.getBTOChildDueDate(MREQDATE.ToString("yyyy/MM/dd"), Session("org_id"))
                    REQUIRED_DATE = CDate(temp)
                    If CDate(temp) > ltime Then
                        REQUIRED_DATE = temp
                    End If

                    If mycart.isSBCBtoOrder(Cart_ID) Then
                        Dim sbcDateDef As Integer = 1
                        Dim temp1 As String = MyCartOrderBizDAL.getCompNextWorkDate(ltime, Session("org"), sbcDateDef)

                        If CDate(MREQDATE.ToShortDateString) <= CDate(temp1) Then

                            REQUIRED_DATE = ltime
                        Else
                            REQUIRED_DATE = MREQDATE
                        End If
                    End If
                    BTOChildDate = REQUIRED_DATE
                End If
                Dim DUE_DATE As Date = _cartitem.due_date, ERP_SITE As String = "", ERP_LOCATION As String = "", AUTO_ORDER_FLAG As Char = ""
                Dim AUTO_ORDER_QTY As Integer = 0, SUPPLIER_DUE_DATE As Date = DUE_DATE, LINE_PARTIAL_FLAG As Integer = 0
                Dim RoHS_FLAG As String = "" : If _cartitem.rohs IsNot Nothing Then RoHS_FLAG = _cartitem.rohs
                Dim EXWARRANTY_FLAG As Integer = _cartitem.Ew_Flag, CustMaterialNo As String = _cartitem.CustMaterial
                Dim DeliveryPlant As String = _cartitem.Delivery_Plant
                If Session("company_id") = "SAID" Then
                    DeliveryPlant = Me.drpDelPlant.SelectedValue
                End If
                Dim NoATPFlag As String = _cartitem.SatisfyFlag, DMF_Flag As String = "", OptyID As String = _cartitem.QUOTE_ID
                Dim Cate As String = String.Empty
                If Not IsDBNull(_cartitem.Category) Then Cate = _cartitem.Category
                If EXWARRANTY_FLAG > 0 Then EXWARRANTY_FLAG = _cartitem.EWpartnoX.EW_Month
                Dim Description = _cartitem.Description
                '\ Ming 2010-10-8 add for companyid UZISCHE01 直接接受user輸入的Required. Date，並apply到每一條order line的first date
                If String.Equals(Session("COMPANY_ID"), "UZISCHE01", StringComparison.CurrentCultureIgnoreCase) Then
                    REQUIRED_DATE = MREQDATE
                End If
                '/ end

                'Ryan 20160516 EU BTOS ReqDate issue
                If IsEUBtosOrder Then
                    If _cartitem.otype = CartItemType.BtosPart Then
                        'REQUIRED_DATE = MREQDATE.AddDays(-10).ToString("yyyy/MM/dd")
                        REQUIRED_DATE = MyCartOrderBizDAL.getCompNextWorkDateV2(MREQDATE, Session("org"), -10)
                        If CDate(REQUIRED_DATE) < Date.Now Then
                            REQUIRED_DATE = MyCartOrderBizDAL.getCompNextWorkDateV2(Date.Now, Session("org"), 1)
                        End If
                    ElseIf _cartitem.otype = CartItemType.BtosParent Then
                        REQUIRED_DATE = MREQDATE
                    End If
                End If

                'Ryan 20170329 AJP特例，AJP不需使用CPN，欄位實際上儲存的是cust_po_no
                If Session("org_id") = "JP01" Then
                    CustMaterialNo = PO_NO

                    Dim NextWorkingDate As DateTime = MyCartOrderBizDAL.getCompNextWorkDateV2(Date.Now, Session("org"), 1)
                    If REQUIRED_DATE < NextWorkingDate Then
                        REQUIRED_DATE = NextWorkingDate
                    End If
                End If

                SAPtools.getInventoryAndATPTable(PART_NO, DeliveryPlant, QTY, DUE_DATE, 0, Nothing, REQUIRED_DATE)
                If MDUEDATE < DUE_DATE Then MDUEDATE = DUE_DATE
                If QTY <= 0 Then QTY = 1

                myOrderDetail.Add_V2(ORDER_ID, LINE_NO, PRODUCT_LINE, PART_NO, ORDER_LINE_TYPE, QTY, LIST_PRICE, UNIT_PRICE, REQUIRED_DATE, DUE_DATE,
                                  ERP_SITE, ERP_LOCATION, AUTO_ORDER_FLAG, AUTO_ORDER_QTY, SUPPLIER_DUE_DATE, LINE_PARTIAL_FLAG, RoHS_FLAG,
                                  EXWARRANTY_FLAG, CustMaterialNo, DeliveryPlant, NoATPFlag, DMF_Flag, OptyID, Cate, Description, HigherLevel)

                'If CInt(EXWARRANTY_FLAG) > 0 Then
                '    count = count + 1
                '    If ORDER_LINE_TYPE <> -1 Then
                '        Dim EWR As DataRow = dtEW.NewRow
                '        With EWR
                '            .Item("line_no") = LINE_NO + count : .Item("part_no") = Glob.getEWItemByMonth(EXWARRANTY_FLAG)
                '            .Item("otype") = ORDER_LINE_TYPE : .Item("qty") = QTY : .Item("req_date") = REQUIRED_DATE
                '            .Item("due_date") = DUE_DATE : .Item("islinePartial") = LINE_PARTIAL_FLAG
                '            'Nada revised uniform ew logic .....
                '            .Item("unit_price") = Glob.getRateByEWItem(EWR.Item("part_no"), DeliveryPlant) * UNIT_PRICE
                '            .Item("delivery_plant") = DeliveryPlant : .Item("DMF_Flag") = DMF_Flag : .Item("OptyID") = OptyID : .Item("subTotal") = .Item("unit_price") * .Item("qty")
                '            .Item("HigherLevel") = HigherLevel
                '        End With
                '        dtEW.Rows.Add(EWR)
                '    End If
                'End If
            Next
            'If dtEW.Rows.Count > 0 Then
            '    If myOrderDetail.isBtoOrder(Cart_ID) Then
            '        Dim Line_no As Integer = myOrderDetail.getMaxLineNo(Cart_ID) + 1
            '        Dim part_no As String = dtEW.Rows(0).Item("part_no"), otype As Integer = dtEW.Rows(0).Item("otype")
            '        Dim qty As Integer = dtEW.Rows(0).Item("qty"), req_date As DateTime = BTOChildDate, due_date As DateTime = MDUEDATE
            '        Dim linePartialFlag As Integer = dtEW.Rows(0).Item("islinePartial")
            '        Dim unit_Price As Decimal = mycart.getTotalPrice_EW(CartId), delivery_plant As String = dtEW.Rows(0).Item("delivery_plant")
            '        Dim dmf_flag As String = dtEW.Rows(0).Item("DMF_Flag"), optyid As String = dtEW.Rows(0).Item("OptyID")
            '        Dim HigherLevel As Integer = 0
            '        If Not IsDBNull(dtEW.Rows(0).Item("HigherLevel")) AndAlso Integer.TryParse(dtEW.Rows(0).Item("HigherLevel"), 0) Then
            '            HigherLevel = Integer.Parse(dtEW.Rows(0).Item("HigherLevel"))
            '        End If
            '        myOrderDetail.Add_V2(ORDER_ID, Line_no, "", part_no, otype, qty, unit_Price, unit_Price, req_date, due_date, "", "", "", 0, due_date, _
            '                          linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid, "", "", HigherLevel)
            '    Else
            '        For Each r As DataRow In dtEW.Rows
            '            Dim line_no As Integer = r.Item("line_no"), part_no As String = r.Item("part_no"), otype As Integer = r.Item("otype")
            '            Dim qty As Integer = r.Item("qty"), req_date As DateTime = r.Item("req_date"), due_date As DateTime = r.Item("due_date")
            '            Dim linePartialFlag As Integer = r.Item("islinePartial"), unit_price As Decimal = r.Item("unit_price")
            '            Dim delivery_plant As String = r.Item("delivery_plant"), dmf_flag As String = r.Item("DMF_Flag"), optyid As String = r.Item("OptyID")
            '            Dim HigherLevel As Integer = 0
            '            If Not IsDBNull(dtEW.Rows(0).Item("HigherLevel")) AndAlso Integer.TryParse(dtEW.Rows(0).Item("HigherLevel"), 0) Then
            '                HigherLevel = Integer.Parse(dtEW.Rows(0).Item("HigherLevel"))
            '            End If
            '            myOrderDetail.reSetLineNoBeforeInsert(Cart_ID, line_no)
            '            myOrderDetail.Add_V2(ORDER_ID, line_no, "", part_no, otype, qty, unit_price, unit_price, req_date, due_date, "", "", "", 0, due_date, _
            '                              linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid, "", "", HigherLevel)
            '        Next
            '    End If
            'End If
        End If
        If myOrderDetail.isBtoOrder(ORDER_ID) Then
            MDUEDATE = MyCartOrderBizDAL.getBTOParentDueDate(MDUEDATE.ToString("yyyy/MM/dd"))
            If MDUEDATE < MREQDATE Then MDUEDATE = MREQDATE
        End If
        Dim CreditCardNumber As String = String.Empty
        Dim VerifyNumber As String = String.Empty
        Dim CreditCardExpireDate As DateTime = DateTime.MinValue
        Dim credit_card_holder As String = String.Empty
        Dim CardType As String = String.Empty
        '\ Ming :当Payment Term只有选择CODC时，才能存储card的相关资料,反正就不存储. 2013-09-12  alex20180107 ABB時CARD相關欄位也先不寫值
        If String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) And Not AuthUtil.IsBBUS Then
            CreditCardNumber = txtCreditCardNumber.Text.Replace("'", "''")
            VerifyNumber = txtCCardVerifyValue.Text.Replace("'", "''")
            credit_card_holder = txtCCardHolder.Text.Replace("'", "''")
            CardType = dlCCardType.SelectedValue
            CreditCardExpireDate = DateSerial(Integer.Parse(dlCCardExpYear.SelectedValue), Integer.Parse(dlCCardExpMonth.SelectedValue), 1)
        End If
        '/ end
        '20120711 TC: Auto append CVV code to Billing Instruction per Cathee's request
        'If Not String.IsNullOrEmpty(txtCCardVerifyValue.Text) And String.IsNullOrEmpty(Trim(txtBillingInstructionInfo.Text)) Then
        '    txtBillingInstructionInfo.Text += " CVV Code:" + txtCCardVerifyValue.Text
        'End If
        '20120717 Ming: Auto append CVV code to Sales Note 
        'If Not String.IsNullOrEmpty(VerifyNumber) AndAlso String.IsNullOrEmpty(Trim(txtSalesNote.Text)) Then
        '    SALES_NOTE += " CVV Code:" + VerifyNumber
        'End If
        ' Dim CreditCardExpireDate As DateTime = DateSerial(Integer.Parse(dlCCardExpYear.SelectedValue), Integer.Parse(dlCCardExpMonth.SelectedValue), 1)
        Dim strDistChann As String = "", strDivision As String = "", strSalesGrp As String = "", strSalesOffice As String = ""
        If dlDistChann.SelectedIndex > 0 Then
            strDistChann = dlDistChann.SelectedValue : strDivision = ddlDivision.SelectedValue : strSalesGrp = ddlSalesGroup.SelectedValue : strSalesOffice = ddlSalesOffice.SelectedValue
        End If
        Dim LAST_UPDATED As DateTime = Date.Now, CREATED_DATE As DateTime = Date.Now
        If Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            LAST_UPDATED = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
            CREATED_DATE = LAST_UPDATED
        End If
        Dim ORDER_DATE As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        Dim IS_EARLYSHIP As Integer = 0
        If cbEarlyShipmentAllowed.Checked Or Session("org_id") <> "US01" Then
            IS_EARLYSHIP = 1
        End If
        Dim _CartMaster As CartMaster = MyCartX.GetCartMaster(CartId)
        If _CartMaster IsNot Nothing AndAlso Not String.IsNullOrEmpty(_CartMaster.Currency) Then
            CURRENCY = _CartMaster.Currency
        End If

        'Ryan 20160328 Add created_by variable and set it as Adam Powell for CheckPoint Order
        Dim CREATED_BY As String = Session("user_Id").ToString()
        If IsCheckPointOrder Then
            CREATED_BY = "adamp@advantech.com"
        End If


        Dim TAX_CLASSIFICATION As Integer = 0
        TAX_CLASSIFICATION = IIf(cbxIsTaxExempt.Checked, 1, 0)

        Dim OrderTotalAmount As Decimal = 0
        OrderTotalAmount = myOrderDetail.getTotalAmount(ORDER_ID)

        If AuthUtil.IsBBUS Then
            'Ryan 20171002 Add Tax Classification settings for BBUS
            TAX_CLASSIFICATION = Int32.Parse(Me.shiptoaddress.TaxClassification)

            'Ryan 20171019 Inco term text for BBUS will be Courier Account in Freight Charge By block
            If Me.ddlBBUSFreightChargeBy.SelectedIndex > 0 Then
                INCOTERM_TEXT = IIf(String.IsNullOrEmpty(txtCourier.Text), String.Empty, txtCourier.Text)
            End If
        End If

        If AuthUtil.IsACN Then
            'Ryan 20170522 ACN sales office & group settings. Take selected value in ddl first, else get SAP_EMPLOYEE settings
            Dim SalesCode As String = ddlSE.SelectedValue
            If dlDistChann.SelectedIndex > 0 Then
                strDistChann = dlDistChann.SelectedValue : strDivision = ddlDivision.SelectedValue : strSalesGrp = ddlSalesGroup.SelectedValue : strSalesOffice = ddlSalesOffice.SelectedValue
            Else
                Dim dt_Sales As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select * from SAP_EMPLOYEE where SALES_CODE = '{0}'", SalesCode))
                If Not dt_Sales Is Nothing AndAlso dt_Sales.Rows.Count > 0 AndAlso dlDistChann.SelectedIndex = 0 Then
                    strSalesGrp = dt_Sales.Rows(0).Item("SALESGROUP").ToString : strSalesOffice = dt_Sales.Rows(0).Item("SALESOFFICE").ToString
                End If
            End If

            If Me.ddlOSBitSelection.SelectedIndex <> 0 Then
                ORDER_NOTE = ORDER_NOTE + vbNewLine + "OS: " + Me.ddlOSBitSelection.SelectedValue + "bit"
            End If
        End If

        If Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
            'Ryan 20170524 Set JP01 dist_chan to 10
            strDistChann = "10"
        ElseIf SAPDOC.IsATWCustomer() Then
            'Ryan 20170905 Set ATW dist_chan to 10
            strDistChann = "10"
        End If

        Dim REMARK As String = ""
        'Ryan 20180627 Save AVN selected option in remark field
        If AuthUtil.IsAVN Then
            If MyCartX.IsHaveBtos(CartId) Then
                REMARK = Me.rdlAVNBTOSOption.SelectedValue
            End If
        End If

        myOrderMaster.Add(ORDER_ID, ORDER_NO, ORDER_TYPE, PO_NO, PO_DATE, SOLDTO_ID, SHIPTO_ID, CURRENCY, MREQDATE, txtBillTo.Text, "", ORDER_DATE, "", ATTENTION, PARTIALFLAG,
            "", "", 0, 0, REMARK, "", MDUEDATE, "", SHIPVIA, ORDER_NOTE, "", OrderTotalAmount, 0, LAST_UPDATED, CREATED_DATE, CREATED_BY, CUSTOMER_ATTENTION, "", INCOTERM,
            INCOTERM_TEXT, SALES_NOTE, OP_NOTE, SHIP_CONDITION, "", "", "", "", prj_Note, ISESE, ERE, EC, PAR1, CreditCardNumber,
            CreditCardExpireDate, VerifyNumber, dlPayterm.SelectedValue, CardType, credit_card_holder, txtBillingInstructionInfo.Text, ddlSE.SelectedValue,
            strDistChann, strDivision, strSalesGrp, strSalesOffice, txtSalesDistrict.Text.Trim, IS_EARLYSHIP, TAX_CLASSIFICATION)
        '20120816 TC: If early shipment is not allowed, update 0 value to order master. This value will be taken into considertation when creating a SO to SAP.
        'Dim aptOrderMaster As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        'If cbEarlyShipmentAllowed.Checked Or Session("org_id") <> "US01" Then
        '    aptOrderMaster.UpdateEarlyShipOption(1, ORDER_ID)
        'Else
        '    aptOrderMaster.UpdateEarlyShipOption(0, ORDER_ID)
        'End If
        myOrderDetail.Update(String.Format("ORDER_ID='{0}' and ORDER_LINE_TYPE=-1", ORDER_ID), String.Format("due_date='{0}',required_date='{1}'", MDUEDATE, MREQDATE))
        '20140509 add table Cart2OrderMaping
        Dim _Cart2OrderMaping As New Cart2OrderMaping
        _Cart2OrderMaping.CartID = CartId
        _Cart2OrderMaping.OrderID = ORDER_ID
        _Cart2OrderMaping.OrderNo = ""
        _Cart2OrderMaping.CreateBy = Session("user_Id")
        _Cart2OrderMaping.CreateTime = Now
        MyOrderX.LogCart2OrderMaping(_Cart2OrderMaping)
    End Sub

    Protected Sub addFreight()
        Dim myFt As New Freight("b2b", "Freight")
        myFt.Delete(String.Format("order_id='{0}'", CartId))
        If IsNumeric(Util.ReplaceSQLStringFunc(Me.txtFtTax.Text.Trim)) Then
            myFt.Add(CartId, "ZHD1", Util.ReplaceSQLStringFunc(Me.txtFtTax.Text.Trim))
        End If
        If IsNumeric(Util.ReplaceSQLStringFunc(Me.txtFtFre.Text.Trim)) Then
            myFt.Add(CartId, "ZHDA", Util.ReplaceSQLStringFunc(Me.txtFtFre.Text.Trim))
        End If
        If IsNumeric(Util.ReplaceSQLStringFunc(Me.txtBBFreight.Text.Trim)) Then
            myFt.Add(CartId, "ZHD0", Util.ReplaceSQLStringFunc(Me.txtBBFreight.Text.Trim))
        End If
    End Sub

    Function VerifyCreditCardInfo() As Boolean
        lbCCardMsg.Text = ""
        If trPayTerm.Visible AndAlso String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) AndAlso tbCreditCardInfo.Visible Then
            'Ryan 20170327 AJP users won't need credit card validation.
            If Not Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                If String.IsNullOrEmpty(txtCreditCardNumber.Text) Then
                    lbCCardMsg.Text = "Please input credit card number" : Return False
                End If
                If String.IsNullOrEmpty(txtCCardVerifyValue.Text) Then
                    lbCCardMsg.Text = "Please input credit card verification value" : Return False
                End If
                If String.IsNullOrEmpty(txtCCardHolder.Text) Then
                    lbCCardMsg.Text = "Please input credit card holder name" : Return False
                End If
            End If
        End If
        Return True
    End Function
    Function VerifyDist_Chann() As Boolean
        If Util.IsANAPowerUser() AndAlso dlDistChann.SelectedIndex > 0 Then
            Dim RDT As New DataTable : RDT.TableName = "RDTABLE"
            Dim ReturnValue As Boolean = MYSAPBIZ.VerifyDistChannelDivisionGroupOffice(Session("org_id"), Session("company_id"), txtShipTo.Text.Trim, dlDistChann.SelectedValue,
                                                          ddlDivision.SelectedValue, SAPDAL.SAPDAL.SAPOrderType.ZOR, ddlSalesGroup.SelectedValue,
                                                          ddlSalesOffice.SelectedValue, RDT)
            If ReturnValue = False AndAlso RDT.Rows.Count > 0 Then Util.JSAlert(Me.Page, RDT.Rows(0).Item("MESSAGE"))
            Return ReturnValue
        End If
        Return True
    End Function

    Function GetCCFirstName(ByVal cardholder As String) As String
        Dim firstName As String = ""
        If Not String.IsNullOrEmpty(cardholder) Then
            If cardholder.Contains(" ") Then
                firstName = cardholder.Substring(0, cardholder.LastIndexOf(" "))
            Else
                firstName = cardholder
            End If
        End If
        Return firstName
    End Function

    Function GetCCLastName(ByVal cardholder As String) As String
        Dim lastName As String = ""


        If Not String.IsNullOrEmpty(cardholder) Then
            If cardholder.Contains(" ") Then
                lastName = cardholder.Substring(cardholder.LastIndexOf(" ") + 1)
            End If
        End If
        Return lastName
    End Function

    Protected Sub btnPIPreview_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write(rbtnIsPartial.SelectedItem.Text)
        'Exit Sub

        'Ryan 20171227 Stop executing if req. date is empty.
        If String.IsNullOrEmpty(Me.txtreqdate.Text) OrElse Date.TryParse(txtreqdate.Text, Now) = False Then
            SetFocus(Me.txtreqdate)
            reqdate_label.Visible = True
            reqdate_label.Text = "Invalid format, please check again."
            Exit Sub
        End If

        If AuthUtil.IsBBUS Then

            'Ryan 20180115 Check if ship-to tax jurisdiction code is valid for BBUS.
            'ICC 20180115 Only US country will be checked Zip code & state, and check tax jurisdiction code is valid.
            If Me.shiptoaddress.Country.ToUpper = "US" Then
                Dim WS As New USTaxService
                Dim _state As String = String.Empty
                If Not WS.getZIPInfo(Me.shiptoaddress.Zipcode, _state, "", "", True, True) Then
                    Util.JSAlert(Me.Page, "Ship-to ZIP code is invalid, please check again.")
                    Exit Sub
                Else
                    If _state.ToUpper <> Me.shiptoaddress.State.ToUpper Then
                        Util.JSAlert(Me.Page, "Tax jurisdiction is invalid, please check again.")
                        Exit Sub
                    End If
                End If
            End If


            'Ryan 20170905 Check if ship-to tax jurisdiction code is valid for BBUS.
            If Me.shiptoaddress.IsTaxJuriValid = False Then
                Util.JSAlert(Me.Page, "Tax jurisdiction code is invalid in Ship-to data, please check again.")
                Exit Sub
            End If

            'Ryan 20180104 If FreightChargeBy is shipper and not selecting any freight option, show alert and exit.
            If Me.ddlBBUSFreightChargeBy.SelectedValue.ToUpper.Equals("SHIPPER") AndAlso (String.IsNullOrEmpty(Me.txtFinalFreightOption.Text) OrElse String.IsNullOrEmpty(Me.txtBBFreight.Text)) Then
                Util.JSAlert(Me.Page, "Please select a freight option if freight charge by is setting as Shipper.")
                Exit Sub
            End If


            'Alex 20180611 Check if drop shipment for BBUS, if yes, add 'OPTION-DropShip' item only in testing site.
            'If Util.IsTesting Then
            Dim currentDropShipItem = MyCartX.GetCartList(CartId).Where(Function(x) x.Part_No = "OPTION-DROPSHIP").FirstOrDefault
            If currentDropShipItem IsNot Nothing Then
                MyCartX.DeleteCartItem(CartId, currentDropShipItem.Line_No)
                MyCartX.ReSetLineNo(CartId)
            End If
            If Me.rblDropShipment.SelectedItem.Value = "true" Then

                Dim dropShipmentItem As CartItem = New CartItem()
                Dim lastItem = MyCartX.GetCartList(CartId).FirstOrDefault
                If lastItem IsNot Nothing Then
                    Dim msg As String = ""
                    Dim lineNo = MyCartOrderBizDAL.Add2Cart_BIZ(CartId, "OPTION-DROPSHIP", 1, 0, 0, "", 1, 1, lastItem.req_date, "", "", 0, True, msg, False)
                End If

            End If
            'End If

            'Alex 20170925 For b+b, if select CODC payment term,  final check credict card information before next step:
            'If String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) Then
            '    Dim retBool As Boolean
            '    Dim errorMessage As String = ""


            '    Dim ccaddress As OrderAddress
            '    If Me.ckbUserNewBillAddress.Checked Then
            '        ccaddress = Me.newbilladdress
            '    Else
            '        ccaddress = Me.billtoaddress
            '    End If
            '    Dim cardholder As String
            '    If Not String.IsNullOrEmpty(Me.txtCCardHolder.Text.Trim()) Then
            '        cardholder = Me.txtCCardHolder.Text
            '    Else
            '        cardholder = ccaddress.Attention
            '    End If
            '    'Dim txtBillToStreet As String = "", txtCity As String = "", txtState As String = "", txtBillToZip As String = ""
            '    'txtCity = ccaddress.City
            '    'txtState = ccaddress.State
            '    'txtBillToStreet = ccaddress.Street : txtBillToZip = ccaddress.Zipcode

            '    AuthCreditResult2.isCheckoutPage = False
            '    retBool = AuthCreditResult2.ValidatePayment("", 0.01, GetCCFirstName(cardholder), GetCCLastName(cardholder), ccaddress.Street, ccaddress.City, ccaddress.State, ccaddress.Zipcode, txtPONo.Text, txtCreditCardNumber.Text,
            '    txtCCardVerifyValue.Text, New Date(dlCCardExpYear.SelectedValue, dlCCardExpMonth.SelectedValue, 1), errorMessage)

            '    If Not retBool Then
            '        SetFocus(Me.endcustomer)
            '        Util.JSAlert(Me.Page, errorMessage)
            '        Exit Sub
            '    End If
            'End If

            'Ryan 20171019 Log BBUS freight options and related settings
            Dim OFS As Advantech.Myadvantech.DataAccess.OrderForwarderService = New Advantech.Myadvantech.DataAccess.OrderForwarderService()
            OFS.OrderId = CartId
            OFS.FreightOption = Me.txtFinalFreightOptionValue.Value.Trim
            OFS.FreightChargeBy = Me.ddlBBUSFreightChargeBy.SelectedValue.Trim
            OFS.CustomChargeBy = Me.ddlBBUSCustomTaxChargeBy.SelectedValue.Trim
            Advantech.Myadvantech.DataAccess.MyAdvantechDAL.AddOrUpdateOrderForwarderService(OFS)
        End If

        If AuthUtil.IsACN Then
            'Ryan 20170407 Block executing if ACN users leave Sales Employee blank.
            If ddlSE.SelectedIndex = 0 Then
                Util.JSAlert(Me.Page, "Please select a sales employee first.")
                ddlSE.Focus()
                Exit Sub
            End If
            If ddlKeyInPerson.SelectedIndex = 0 Then
                Util.JSAlert(Me.Page, "Please select a key-in person first.")
                ddlSE.Focus()
                Exit Sub
            End If

            'Ryan 20170914 Required date must within five months per Blanche's request.
            '9/1 起, 發現IS下長單..2018/6/30..等等, 請協助增加功能, 只接受未來5個月內的訂單 (只接受未來5個月內的訂單). 
            If Not String.IsNullOrEmpty(txtreqdate.Text) AndAlso DateTime.Parse(txtreqdate.Text) > DateTime.Now.AddMonths(5) Then
                Util.JSAlert(Me.Page, "Required date must within five months.")
                txtreqdate.Focus()
                Exit Sub
            End If

            If Me.trOSBitSelection.Visible = True AndAlso Me.ddlOSBitSelection.SelectedIndex = 0 Then
                Util.JSAlert(Me.Page, "Please select OS bit first.")
                ddlSE.Focus()
                Exit Sub
            End If

            'Ryan 20171006 If required date is somehow still smaller than localtime.adddays(5), then overwrite it.
            Dim ACNFirstAvailableDate As Date = MyCartOrderBizDAL.getCompNextWorkDateV2(SAPDOC.GetLocalTime(Session("org_id")), Session("org_id"), 5)
            If Not String.IsNullOrEmpty(txtreqdate.Text) AndAlso DateTime.Parse(txtreqdate.Text) < ACNFirstAvailableDate Then
                txtreqdate.Text = ACNFirstAvailableDate.ToString
            End If

        End If

        'Ryan 20170621 Force AJP users to select at least one end customer
        If Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
            If String.IsNullOrEmpty(Me.endcustomer.ERPID) Then
                SetFocus(Me.endcustomer)
                Util.JSAlert(Me.Page, "Please select an end customer first.")
                Exit Sub
            End If

            If (ddlRevenueSpiltPerson.SelectedIndex > 0 AndAlso ddlRevenueSpiltOption.SelectedIndex = 0) OrElse
                (ddlRevenueSpiltPerson.SelectedIndex = 0 AndAlso ddlRevenueSpiltOption.SelectedIndex > 0) Then
                Util.JSAlert(Me.Page, "Please select both sales person and split option for revenue sharing settings.")
                Exit Sub
            End If

            'Ryan 20180430 Checking rule for AJP CLA
            Dim SAP968Q_CartList As List(Of CartItem) = MyCartX.GetCartList(CartId).Where(Function(p) p.Part_No.StartsWith("968Q")).ToList()
            If SAP968Q_CartList.Count > 0 Then
                Dim strSql As String = String.Format("select * from saprdp.ZTSD_106A where vkorg = '{0}' and KUNNR in ('{1}','{2}') and '{3}' between BDATE and EDATE", Session("org_id"), Me.soldtoaddress.ERPID, Me.endcustomer.ERPID, DateTime.Now.ToString("yyyyMMdd"))
                Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", strSql)
                If dt.Rows.Count > 0 Then
                    ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "alert(""Due to MS licenses policy please place 968T- parts instead of 968Q- parts."");", True)
                    Util.JSAlert(Me.Page, "Due to MS licenses policy please place 968T- parts instead of 968Q- parts.")
                    Exit Sub
                End If
            End If
            Dim SAP968T_CartList As List(Of CartItem) = MyCartX.GetCartList(CartId).Where(Function(p) p.Part_No.StartsWith("968T")).ToList()
            If SAP968T_CartList.Count > 0 Then
                If Not Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(Me.soldtoaddress.ERPID) AndAlso Not Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(Me.endcustomer.ERPID) Then
                    Util.JSAlert(Me.Page, "Due to MS licenses policy it is not allowed to order part numbers start with 968T.")
                    Exit Sub
                End If
            End If
        End If

        'Ryan 20180322 Validations for ADLOG
        If AuthUtil.IsADloG Then
            If (ddlRevenueSpiltPerson.SelectedIndex > 0 AndAlso ddlRevenueSpiltOption.SelectedIndex = 0) OrElse
                (ddlRevenueSpiltPerson.SelectedIndex = 0 AndAlso ddlRevenueSpiltOption.SelectedIndex > 0) Then
                Util.JSAlert(Me.Page, "Please select both sales person and split option for revenue sharing settings.")
                Exit Sub
            End If
        End If

        If AuthUtil.IsASG Then

            'Ryan 20180808 For ASG BTOS Instruction Input
            If Me.trBTOSInstruction.Visible = True Then
                For Each rpItem As RepeaterItem In Me.rpBTOSInstruction.Items
                    Dim rpHiddenField As HiddenField = CType(rpItem.FindControl("hfBTOSLineNo"), HiddenField)
                    Dim rpTextbox As TextBox = CType(rpItem.FindControl("txtBTOSInstruction"), TextBox)

                    If Not String.IsNullOrEmpty(CartId) AndAlso Not String.IsNullOrEmpty(rpHiddenField.Value) AndAlso Not String.IsNullOrEmpty(rpTextbox.Text.Trim) Then
                        Advantech.Myadvantech.DataAccess.MyAdvantechDAL.AddASGBtosInstruction(CartId, Integer.Parse(rpHiddenField.Value), rpTextbox.Text.Trim)
                    End If
                Next
            End If
        End If

        If AuthUtil.IsUSAonlineSales(User.Identity.Name) Then
            If validateShipAddress(False) Then
                goNext()
            Else
                Me.hdlgCSV.Value = 1
            End If
        Else
            goNext()
        End If
    End Sub

    Sub goNext()
        If VerifyCreditCardInfo() = False Then Exit Sub
        If VerifyDist_Chann() = False Then Exit Sub
        If Date.TryParse(txtreqdate.Text, Now) = False Then txtreqdate.Text = Now.ToString("yyyy/MM/dd")
        Dim tmpNextWeekShipDate As Date = CDate(Me.txtreqdate.Text)
        'Ming 20140929  检查页面停留时间太长，是不是已经过了13点
        'If Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
        '    Dim localtime As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        '    If CDate(localtime) = CDate(tmpNextWeekShipDate) Then
        '        If localtime.Hour >= 13 Then
        '            tmpNextWeekShipDate = MyCartOrderBizDAL.getCompNextWorkDateV2(localtime, Session("org_id"), 1)
        '        End If
        '    End If
        'End If
        'end
        If MyCartOrderBizDAL.GetNextWeeklyShippingDate(CDate(Me.txtreqdate.Text), tmpNextWeekShipDate) Then Me.txtreqdate.Text = tmpNextWeekShipDate.ToString("yyyy/MM/dd")
        DBfromCart2Order(CartId) : addFreight() : InsertORDER_PARTNERS() : SyncCustomerID(CartId)
        MyOrderX.LogOrderMasterExtension(CartId, 1, Integer.Parse(rbOrderNo.SelectedValue), Decimal.Parse(Me.lbBBTaxRate.Text))

        UploadFile()

        'Frank 2014/02/11 
        If Session("org_id").ToString.Trim.StartsWith("TW", StringComparison.OrdinalIgnoreCase) _
            AndAlso AuthUtil.IsTWAonlineSales(User.Identity.Name) _
            AndAlso Me.rbtnIsPartial.SelectedValue = 0 Then
            Response.Redirect("~/Order/pi.aspx?NO=" & CartId)
        End If

        If AuthUtil.IsUSAonlineSales(User.Identity.Name) And Me.rbtnIsPartial.SelectedValue = 0 Then
            Response.Redirect("~/Order/pi.aspx?NO=" & CartId)
        End If

        'Ryan 20151223 Redirect with index parameter while page is called from Check-Point convert2order
        If (Not String.IsNullOrEmpty(CheckPoint_Convert2Order)) AndAlso (CheckPoint_Convert2Order = HttpContext.Current.Session("cart_id")) Then
            Response.Redirect("~/Order/pi.aspx?NO=" & CartId)
        End If

        'Ryan 20160516 Skip DueDateReset Page for EU BTOS Order
        'If IsEUBtosOrder Then
        '    Response.Redirect("~/Order/pi.aspx?NO=" & CartId)
        'End If

        Response.Redirect("~/Order/DueDateReset.aspx?NO=" & CartId)
    End Sub
    Protected Sub SyncCustomerID(ByVal OrderID As String)
        Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        Dim OPdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(OrderID)
        For Each op As MyOrderDS.ORDER_PARTNERSRow In OPdt
            If Not String.IsNullOrEmpty(op.ERPID) AndAlso (String.Equals(op.TYPE, "SOLDTO", StringComparison.CurrentCultureIgnoreCase) OrElse
                                                           String.Equals(op.TYPE, "S", StringComparison.CurrentCultureIgnoreCase) OrElse
                                                           String.Equals(op.TYPE, "B", StringComparison.CurrentCultureIgnoreCase)) Then
                Dim companycount As Object = dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(COMPANY_ID) as c  FROM SAP_DIMCOMPANY  where COMPANY_ID ='{0}'", op.ERPID))
                If companycount IsNot Nothing AndAlso Integer.TryParse(companycount, 0) AndAlso Integer.Parse(companycount) = 0 Then
                    Server.Execute(String.Format("~/admin/SyncCustomer.aspx?companyid={0}&auto=1", op.ERPID))
                End If
            End If
        Next
    End Sub
    Public Function validateShipAddress(ByVal isConfirmed As Boolean) As Boolean
        If Not IsNothing(Me.shiptoaddress) AndAlso Not String.IsNullOrEmpty(Me.shiptoaddress.ERPID) Then
            Dim ws As New eStore_WS.eStoreWebService
            Dim addr As New eStore_WS.ShippingAddress
            addr.ERPID = Me.shiptoaddress.ERPID.Trim
            addr.Country = Me.shiptoaddress.Country.Trim
            addr.State = Me.shiptoaddress.State.Trim
            addr.City = Me.shiptoaddress.City.Trim
            addr.Street = Me.shiptoaddress.Street.Trim
            addr.Street2 = Me.shiptoaddress.Street2.Trim
            addr.PostalCode = Me.shiptoaddress.Zipcode
            Dim pder As eStore_WS.ValidatationProvider
            If Me.drpShipCondition.SelectedItem.Text.StartsWith("UPS") Then
                pder = eStore_WS.ValidatationProvider.UPS
            Else
                pder = eStore_WS.ValidatationProvider.Fedex
            End If

            'ICC 2016/3/31 Add try catch to prevent eStore ws failed
            Try
                Dim ret As eStore_WS.ShippingAddressValidationResult = ws.ValidateFreightAddress(addr, pder, Session("user_id"), "MyAdvantech", isConfirmed)
                If isConfirmed Then Return True
                If ret.isValid = True Then Return True
            Catch ex As Exception
                Util.InsertMyErrLogV2(ex.ToString)
                Return False
            End Try

        End If
        Return False
    End Function
    Protected Sub InsertORDER_PARTNERS()
        Dim OrderAddressS As OrderAddress() = {Me.soldtoaddress, Me.shiptoaddress, Me.billtoaddress, Me.endcustomer}
        Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        A.DeleteByOrderID(CartId)
        For Each OrderAddress As OrderAddress In OrderAddressS
            With OrderAddress
                If Not String.IsNullOrEmpty(.ERPID.Trim) Then
                    A.Insert(CartId, "", .ERPID.ToUpper.Trim, .Name.Trim, .EMAIL.Trim, .Type.Trim, .Attention.Trim, .Tel.Trim, "", .Zipcode.Trim, .Country.Trim, .City.Trim, .Street.Trim, .State.Trim, "", .Street2.Trim, .taxJuri.Trim)
                End If
            End With
        Next

        'Alex 20170926 Add new partner with type "B_CC" if CODC for all org
        If String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) Then
            Dim ccaddress As OrderAddress

            'Alex If and ckbUserNewBillAddres is checked, replaced ccaddress with new  bill to
            If Me.ckbUserNewBillAddress.Checked Then
                ccaddress = Me.newbilladdress
            Else
                ccaddress = Me.billtoaddress
            End If

            Dim txtFirstName As String = "", txtLastName As String = ""
            Dim cardholder As String
            If Not String.IsNullOrEmpty(Me.txtCCardHolder.Text.Trim()) Then
                cardholder = Me.txtCCardHolder.Text
            Else
                cardholder = ccaddress.Attention
            End If

            A.Insert(CartId, "", Me.soldtoaddress.ERPID.ToUpper.Trim, cardholder, "", "B_CC", ccaddress.Attention, ccaddress.Tel, "", ccaddress.Zipcode, ccaddress.Country, ccaddress.City, ccaddress.Street.Trim, ccaddress.State, "", ccaddress.Street2, "")

        End If

        If ddlSE.SelectedIndex > 0 Then
            A.Insert(CartId, "", ddlSE.SelectedValue, "", "", "E", "", "", "", "", "", "", "", "", "", "", "")
        End If
        If ddlSE2.SelectedIndex > 0 Then
            A.Insert(CartId, "", ddlSE2.SelectedValue, "", "", "E2", "", "", "", "", "", "", "", "", "", "", "")
        End If
        If ddlSE3.SelectedIndex > 0 Then
            A.Insert(CartId, "", ddlSE3.SelectedValue, "", "", "E3", "", "", "", "", "", "", "", "", "", "", "")
        End If
        If ddlKeyInPerson.Items.Count > 0 AndAlso Not String.IsNullOrEmpty(ddlKeyInPerson.SelectedValue.Trim) Then
            'Ryan 20170411 AJP uses type ER instead of KIP, Key-in-person is decided by AGS-CTOS-SYS-A(B)
            If Session("org_id").ToString.Equals("JP01") Then
                A.Insert(CartId, "", ddlKeyInPerson.SelectedValue, "", "", "ZM", "", "", "", "", "", "", "", "", "", "", "")
            Else
                A.Insert(CartId, "", ddlKeyInPerson.SelectedValue, "", "", "KIP", "", "", "", "", "", "", "", "", "", "", "")
            End If
        End If


        'Ryan 20170424 AJP Key-in-Person logic, AGS-CTOS-SYS-A = Maiko.Ikezaki, AGS-CTOS-SYS-B = Liling.Wang, else leave blank.
        'Ryan 20170629 Add AJP revenue sharing settings
        If Session("org_id").ToString.Equals("JP01") Then
            Dim AJPItemCategory As String = Advantech.Myadvantech.Business.OrderBusinessLogic.GetAJPOrderItemCategory(CartId)
            If Not String.IsNullOrEmpty(AJPItemCategory) AndAlso AJPItemCategory.Equals("ZTM5") Then
                A.Insert(CartId, "", "12300032", "", "", "KIP", "", "", "", "", "", "", "", "", "", "", "")
            ElseIf Not String.IsNullOrEmpty(AJPItemCategory) AndAlso AJPItemCategory.Equals("ZTM6") Then
                A.Insert(CartId, "", "12300031", "", "", "KIP", "", "", "", "", "", "", "", "", "", "", "")
            End If

            If ddlRevenueSpiltPerson.SelectedIndex > 0 AndAlso ddlRevenueSpiltOption.SelectedIndex > 0 Then
                A.Insert(CartId, "", ddlRevenueSpiltPerson.SelectedValue, ddlRevenueSpiltOption.SelectedValue, "", "ZA", "", "", "", "", "", "", "", "", "", "", "")
            End If
        End If

        'Ryan 20171013 New payer logic
        Dim PayerID As String = String.Empty
        If Me.soldtoaddress IsNot Nothing AndAlso Not String.IsNullOrEmpty(Me.soldtoaddress.ERPID) AndAlso
           Me.billtoaddress IsNot Nothing AndAlso Not String.IsNullOrEmpty(Me.billtoaddress.ERPID) Then
            PayerID = Me.billtoaddress.ERPID
        End If
        'Add default payer to OrderPartners table for AEU
        If Session("org_id").ToString.Equals("EU10") Then
            PayerID = Me.soldtoaddress.ERPID
            If Me.ddlPayer.SelectedValue IsNot Nothing AndAlso Not String.IsNullOrEmpty(Me.ddlPayer.SelectedValue) Then
                PayerID = Me.ddlPayer.SelectedValue
            End If
        End If
        If Not String.IsNullOrEmpty(PayerID) Then
            A.Insert(CartId, "", PayerID.ToString, "", "", "RG", "", "", "", "", "", "", "", "", "", "", "")
        End If

        If AuthUtil.IsADloG Then
            If ddlEmployeeResponse.Items.Count > 0 AndAlso Not String.IsNullOrEmpty(ddlEmployeeResponse.SelectedValue.Trim) Then
                A.Insert(CartId, "", ddlEmployeeResponse.SelectedValue, "", "", "ZM", "", "", "", "", "", "", "", "", "", "", "")
            End If

            If ddlRevenueSpiltPerson.SelectedIndex > 0 AndAlso ddlRevenueSpiltOption.SelectedIndex > 0 Then
                A.Insert(CartId, "", ddlRevenueSpiltPerson.SelectedValue, ddlRevenueSpiltOption.SelectedValue, "", "ZA", "", "", "", "", "", "", "", "", "", "", "")
            End If
        End If


        If AuthUtil.IsBBUS Then
            'Ryan 20180108 Comment below out due to BBUS should take ZM(Employee Response) from SAP customer master data.
            'Ryan 20170915 Set current user id as ZM(Employee Response) for BBUS
            'Dim salescode As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 SALES_CODE from SAP_EMPLOYEE where EMAIL = '{0}'", Session("user_id").ToString))
            'If salescode IsNot Nothing AndAlso Not String.IsNullOrEmpty(salescode.ToString) Then
            '    A.Insert(CartId, "", salescode.ToString, "", "", "ZM", "", "", "", "", "", "", "", "", "", "", "")
            'End If

            'Ryan 20171018 Set type ZP/ZQ to OrderPartners
            If Me.ddlBBUSFreightChargeBy.SelectedIndex > 0 Then
                With Me.FreightChargeByAddress
                    If Not String.IsNullOrEmpty(.ERPID.Trim) Then
                        A.Insert(CartId, "", .ERPID.ToUpper.Trim, .Name.Trim, .EMAIL.Trim, .Type.Trim, .Attention.Trim, .Tel.Trim, "", .Zipcode.Trim, .Country.Trim, .City.Trim, .Street.Trim, .State.Trim, "", .Street2.Trim, .taxJuri.Trim)
                    End If
                End With
            End If
            If Me.ddlBBUSCustomTaxChargeBy.SelectedIndex > 0 Then
                With Me.CustomTaxChargeByAddress
                    If Not String.IsNullOrEmpty(.ERPID.Trim) Then
                        A.Insert(CartId, "", .ERPID.ToUpper.Trim, .Name.Trim, .EMAIL.Trim, .Type.Trim, .Attention.Trim, .Tel.Trim, "", .Zipcode.Trim, .Country.Trim, .City.Trim, .Street.Trim, .State.Trim, "", .Street2.Trim, .taxJuri.Trim)
                    End If
                End With
            End If

            'Ryan 20171219 Save order contact persons to OrderPartner with type "Contact" for further PI mail using.
            If Not String.IsNullOrEmpty(Me.txtBBContact.Text) Then
                A.Insert(CartId, "", "", "", Me.txtBBContact.Text, "Contact", "", "", "", "", "", "", "", "", "", "", "")

                'Ryan 20171230 Also put first selected contact person as type AP (will be synced to SAP order partner tab)
                Dim APContactEMAIL As String = Me.txtBBContact.Text.Split(";")(0)
                Dim APContactSAPID As String = String.Empty
                If Not String.IsNullOrEmpty(APContactEMAIL) Then
                    APContactSAPID = Advantech.Myadvantech.DataAccess.SAPDAL.GetSAPContactRowID(Session("company_id").ToString, APContactEMAIL, Util.IsTesting)

                    If Not String.IsNullOrEmpty(APContactSAPID) Then
                        A.Insert(CartId, "", APContactSAPID, HttpContext.Current.Session("company_name"), APContactEMAIL, "AP", "", "", "", "", "", "", "", "", "", "", "")
                    End If
                End If
            End If

        End If


    End Sub
    'Protected Sub drpShipTo_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
    '    Dim obj As DropDownList = CType(sender, DropDownList) : Me.txtShipTo.Text = obj.SelectedValue : Me.upShipTo.Update()
    'End Sub
    'Protected Sub btnShipPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    If ucShipTo.Visible Then
    '        Me.ucShipTo.GetData()
    '    Else
    '        Me.ucShipToUS.GetData()
    '    End If
    '    Me.up_shipto_c.Update() : Me.MP_shipto.Show()
    'End Sub
    Protected Sub btnDirect2SAP_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        'Ryan 20171227 Stop executing if req. date is empty.
        If String.IsNullOrEmpty(Me.txtreqdate.Text) OrElse Date.TryParse(txtreqdate.Text, Now) = False Then
            SetFocus(Me.txtreqdate)
            reqdate_label.Visible = True
            reqdate_label.Text = "Invalid format, please check again."
            Exit Sub
        End If

        OrderUtilities.SetDirect2SAPSession()
        Me.btnPIPreview_Click(Me.btnPIPreview, Nothing)
    End Sub

    Protected Sub dlPayterm_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)

        If String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) Then
            If Not AuthUtil.IsBBUS Then
                tbCreditCardInfo.Visible = True
            End If
        Else
            tbCreditCardInfo.Visible = False
        End If

        If AuthUtil.IsAEU AndAlso String.Equals(dlPayterm.SelectedValue, "PPD", StringComparison.CurrentCultureIgnoreCase) Then
            rbtnIsPartial.SelectedValue = "0"
        End If

    End Sub

    Protected Sub dlDistChann_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If dlDistChann.SelectedIndex > 0 Then
            tbDivSalesGrpOffice.Visible = True
            Dim sql As New StringBuilder
            Dim strDivision As String = "", strDistChann As String = "", strSalesGrp As String = "", strSalesOffice As String = ""
            If MYSAPDAL.GetDefaultDistChannDivisionSalesGrpOfficeByCompanyId(Session("company_id"), strDistChann, strDivision, strSalesGrp, strSalesOffice) Then
            End If
            sql.Clear()
            sql.AppendFormat("select distinct DIVISION as Value from SAP_COMPANY_LOV where ORG_ID='{0}' order by DIVISION", Session("org_id"))
            ddlDivision.DataTextField = "Value" : ddlDivision.DataValueField = "Value"
            ddlDivision.DataSource = dbUtil.dbGetDataTable("MY", sql.ToString())
            ddlDivision.DataBind()
            If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                Dim liDivDoubleZero As ListItem = ddlDivision.Items.FindByValue("00")
                If liDivDoubleZero IsNot Nothing Then ddlDivision.Items.Remove(liDivDoubleZero)
            End If
            If Not String.IsNullOrEmpty(strDivision) Then
                If ddlDivision.Items.FindByValue(strDivision) IsNot Nothing Then
                    ddlDivision.SelectedValue = strDivision
                End If
            End If
            'end
            ' Set  SalesGroup
            sql.Clear()
            sql.AppendFormat("select distinct SALESGROUP as Value from SAP_COMPANY_LOV where ORG_ID='{0}' and SALESGROUP<>'' order by SALESGROUP", Session("org_id"))
            ddlSalesGroup.DataTextField = "Value" : ddlSalesGroup.DataValueField = "Value"
            ddlSalesGroup.DataSource = dbUtil.dbGetDataTable("MY", sql.ToString())
            ddlSalesGroup.DataBind()
            If Not String.IsNullOrEmpty(strSalesGrp) Then
                If ddlSalesGroup.Items.FindByValue(strSalesGrp) IsNot Nothing Then
                    ddlSalesGroup.SelectedValue = strSalesGrp
                End If
            End If
            'end
            ' Set  SalesOffice
            sql.Clear()
            sql.AppendFormat("select distinct SALESOFFICE as Value from SAP_COMPANY_LOV where ORG_ID='{0}' and SALESOFFICE<>'' order by SALESOFFICE", Session("org_id"))
            ddlSalesOffice.DataTextField = "Value" : ddlSalesOffice.DataValueField = "Value"
            ddlSalesOffice.DataSource = dbUtil.dbGetDataTable("MY", sql.ToString())
            ddlSalesOffice.DataBind()
            If Not String.IsNullOrEmpty(strSalesOffice) Then
                If ddlSalesOffice.Items.FindByValue(strSalesOffice) IsNot Nothing Then
                    ddlSalesOffice.SelectedValue = strSalesOffice
                End If
            End If

            'Ryan 20170809 ACN SalesGroup/SalesOffice settings
            If Session("org_id").ToString.StartsWith("CN") Then
                sql.Clear()
                sql.AppendFormat(" select distinct SALES_GROUP_CODE + ' - ' + SALES_GROUP as Text, SALES_GROUP_CODE as Value from SAP_ORG_OFFICE_GRP where SALES_ORG = '{0}' and SALES_GROUP_CODE <> '' order by SALES_GROUP_CODE", Session("org_id"))
                ddlSalesGroup.DataTextField = "Text" : ddlSalesGroup.DataValueField = "Value"
                ddlSalesGroup.DataSource = dbUtil.dbGetDataTable("MY", sql.ToString())
                ddlSalesGroup.DataBind()

                sql.Clear()
                sql.AppendFormat(" select distinct SALES_OFFICE_CODE + ' - ' + SALES_OFFICE as Text, SALES_OFFICE_CODE as Value from SAP_ORG_OFFICE_GRP where SALES_ORG = '{0}' and SALES_OFFICE_CODE <> '' order by SALES_OFFICE_CODE", Session("org_id"))
                ddlSalesOffice.DataTextField = "Text" : ddlSalesOffice.DataValueField = "Value"
                ddlSalesOffice.DataSource = dbUtil.dbGetDataTable("MY", sql.ToString())
                ddlSalesOffice.DataBind()

                Dim dt_Sales As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select * from SAP_EMPLOYEE where SALES_CODE = '{0}'", ddlSE.SelectedValue))
                If Not dt_Sales Is Nothing AndAlso dt_Sales.Rows.Count > 0 Then
                    If ddlSalesGroup.Items.FindByValue(dt_Sales.Rows(0).Item("SALESGROUP").ToString) IsNot Nothing Then
                        ddlSalesGroup.SelectedValue = dt_Sales.Rows(0).Item("SALESGROUP").ToString
                    End If
                    If ddlSalesOffice.Items.FindByValue(dt_Sales.Rows(0).Item("SALESOFFICE").ToString) IsNot Nothing Then
                        ddlSalesOffice.SelectedValue = dt_Sales.Rows(0).Item("SALESOFFICE").ToString
                    End If
                End If
            End If
        Else
            tbDivSalesGrpOffice.Visible = False
        End If
    End Sub

    'Protected Sub txtCCardVerifyValue_TextChanged(sender As Object, e As System.EventArgs)
    '    If Not String.IsNullOrEmpty(txtCCardVerifyValue.Text) Then
    '        If String.IsNullOrEmpty(Trim(txtSalesNote.Text)) Then
    '            txtSalesNote.Text = "CVV Code:" + txtCCardVerifyValue.Text
    '        Else
    '            txtSalesNote.Text += " CVV Code:" + txtCCardVerifyValue.Text
    '        End If
    '    End If
    'End Sub

    Protected Sub txtPONo_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        lbPoDuplicateMsg.Text = ""
        If txtPONo.Text.Length > 35 Then
            lbPoDuplicateMsg.Text = "Maximum length is 35 characters"
        ElseIf Not String.IsNullOrEmpty(txtPONo.Text) AndAlso Util.IsInternalUser2() Then
            lbPoDuplicateMsg.Text = ""
            Dim SAPconnection As String = "SAP_PRD"
            If Util.IsTesting() Then
                SAPconnection = "SAP_Test"
            End If
            Dim poDt As DataTable = OraDbUtil.dbGetDataTable(SAPconnection,
            "select vbeln from saprdp.vbak where KNKLI='" + Session("company_id") + "' and BSTNK='" + Replace(txtPONo.Text, "'", "''") + "' and rownum<=20 and vkorg='" + Session("org_id") +
            "' and auart in ('ZOR','ZOR2') order by erdat desc")
            If poDt.Rows.Count > 0 Then
                Dim arySo As New ArrayList
                For Each poRow As DataRow In poDt.Rows
                    arySo.Add(Global_Inc.RemoveZeroString(poRow.Item("vbeln").ToString()))
                Next
                lbPoDuplicateMsg.Text = "Purchase order number already exists in SO: " + String.Join(",", arySo.ToArray())
            End If
        End If
    End Sub

    Protected Sub UploadFile()

        'Ryan 20170704 Add for Intercon File Upload
        If FileUpload1.HasFile Then
            Dim ID As String = CartId
            Dim FileName As String = FileUpload1.FileName
            Dim FileData As Byte() = FileUpload1.FileBytes
            Dim FileExt As String = System.IO.Path.GetExtension(FileUpload1.FileName).Replace(".", "")

            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from InterconUploadedFile where cart_id = '{0}'", ID))

            Dim SQLstr As String = " insert into InterconUploadedFile (Cart_ID, FileName, FileData, FileExt) values (@CART_ID, @FileName, @FileData, @FileExt)"
            Dim cmd As New SqlClient.SqlCommand(SQLstr, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            With cmd.Parameters
                .AddWithValue("CART_ID", ID)
                .AddWithValue("FileName", FileName)
                .AddWithValue("FileData", FileData)
                .AddWithValue("FileExt", FileExt)
            End With
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
            cmd.Connection.Close()
        Else
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from InterconUploadedFile where cart_id = '{0}'", CartId))
        End If

    End Sub

    Protected Sub lBtnAuthCcInfo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PanelCreditAuthInfo.Visible = False
        If String.IsNullOrEmpty(txtCreditCardNumber.Text) OrElse String.IsNullOrEmpty(txtCCardVerifyValue.Text) Then
            Exit Sub
        End If

        Dim aptOrderDetail As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter, aptOrderPartner As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        Dim decTotalAmount As Decimal = aptOrderDetail.getTotalAmount(CartId)
        'Dim txtBillToStreet As String = "", txtBillToZip As String = ""
        'Dim BillSoldToDt As MyOrderDS.ORDER_PARTNERSDataTable = aptOrderPartner.GetPartnerByOrderIDAndType(CartId, "B")
        'If BillSoldToDt.Count = 0 OrElse String.IsNullOrEmpty(BillSoldToDt(0).STREET) OrElse String.IsNullOrEmpty(BillSoldToDt(0).ZIPCODE) Then
        '    BillSoldToDt = aptOrderPartner.GetPartnerByOrderIDAndType(CartId, "SOLDTO")
        '    If BillSoldToDt.Count = 0 Then
        '        Exit Sub
        '    End If
        'End If
        Dim ccaddress As OrderAddress
        If Me.ckbUserNewBillAddress.Checked Then
            ccaddress = Me.newbilladdress
        Else
            ccaddress = Me.billtoaddress
        End If
        'Dim txtFirstName As String = "", txtLastName As String = ""
        'Dim txtBillToStreet As String = "", txtCity As String = "", txtState As String = "", txtBillToZip As String = ""
        Dim cardholder As String
        If Not String.IsNullOrEmpty(Me.txtCCardHolder.Text.Trim()) Then
            cardholder = Me.txtCCardHolder.Text
        Else
            cardholder = ccaddress.Attention
        End If
        'If Not String.IsNullOrEmpty(cardholder) Then
        '    If cardholder.Contains(" ") Then
        '        txtFirstName = cardholder.Substring(0, cardholder.LastIndexOf(" "))
        '        txtLastName = cardholder.Substring(cardholder.LastIndexOf(" ") + 1)
        '    Else
        '        txtFirstName = cardholder
        '    End If
        'End If
        'txtCity = ccaddress.City
        'txtState = ccaddress.State
        'txtBillToStreet = ccaddress.Street : txtBillToZip = ccaddress.Zipcode
        Dim retBool As Boolean = False, newaddress As String = ""
        Dim pnRefenrce As String = ""
        '如為BB(US10), 使用AuthCreditResult2介面(authorize.net) preview payment result

        'If AuthUtil.IsBBUS Then
        '    AuthCreditResult2.isCheckoutPage = False
        '    retBool = AuthCreditResult2.PreviewPaymentResult("", 0.01, GetCCFirstName(cardholder), GetCCLastName(cardholder), ccaddress.Street, ccaddress.City, ccaddress.State, ccaddress.Zipcode, txtPONo.Text, txtCreditCardNumber.Text,
        '    txtCCardVerifyValue.Text, New Date(dlCCardExpYear.SelectedValue, dlCCardExpMonth.SelectedValue, 1))

        '    pnRefenrce = AuthCreditResult2.PNReference

        'Else


        'End If

        retBool = AuthCreditResult1.Auth(decTotalAmount, GetCCFirstName(cardholder), GetCCLastName(cardholder), ccaddress.Street, ccaddress.City, ccaddress.State, ccaddress.Zipcode, txtPONo.Text, txtCreditCardNumber.Text,
txtCCardVerifyValue.Text, New Date(dlCCardExpYear.SelectedValue, dlCCardExpMonth.SelectedValue, 1))
        'retBool = AuthCreditResult1.Auth(decTotalAmount, txtFirstName, txtLastName, txtBillToStreet, txtCity, txtState, txtBillToZip, txtPONo.Text, txtCreditCardNumber.Text,
        '            txtCCardVerifyValue.Text, New Date(dlCCardExpYear.SelectedValue, dlCCardExpMonth.SelectedValue, 1))
        pnRefenrce = AuthCreditResult1.PNReference
        If retBool Then
            If Not AuthUtil.IsBBUS Then
                If Not String.IsNullOrEmpty(txtCCardVerifyValue.Text.Trim) Then
                    If String.IsNullOrEmpty(txtSalesNote.Text.Trim) Then
                        txtSalesNote.Text = "CVV Code: " + txtCCardVerifyValue.Text.Trim + vbCrLf
                    Else
                        txtSalesNote.Text += vbCrLf + "CVV Code: " + txtCCardVerifyValue.Text.Trim
                    End If
                End If
                If Me.ckbUserNewBillAddress.Checked Then
                    newaddress = "Address: " + newbilladdress.Street + vbTab + newbilladdress.City + vbTab + newbilladdress.State + vbTab + newbilladdress.Country + vbTab + newbilladdress.Zipcode
                Else
                    newaddress = "Address: " + billtoaddress.Street + vbTab + billtoaddress.City + vbTab + billtoaddress.State + vbTab + billtoaddress.Country + vbTab + billtoaddress.Zipcode
                End If

                If String.IsNullOrEmpty(txtSalesNote.Text.Trim) Then
                    txtSalesNote.Text = newaddress + vbCrLf
                Else
                    txtSalesNote.Text += vbCrLf + newaddress
                End If
                If String.IsNullOrEmpty(txtBillingInstructionInfo.Text.Trim) Then
                    txtBillingInstructionInfo.Text = "PN Reference: " + pnRefenrce + vbCrLf
                Else
                    txtBillingInstructionInfo.Text += vbCrLf + "PN Reference: " + pnRefenrce
                End If
            End If
        End If

        PanelCreditAuthInfo.Visible = True
    End Sub
    Protected Sub ckbUserNewBillAddress_OnCheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.newbilladdress.Visible = ckbUserNewBillAddress.Checked
    End Sub
    Protected Sub lnkCloseCreditCardAuthInfo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PanelCreditAuthInfo.Visible = False
    End Sub
    Public Shared Function toJson(ByVal dt As DataTable) As String
        Dim jsS As New Script.Serialization.JavaScriptSerializer
        jsS.MaxJsonLength = Int32.MaxValue
        Dim ar As New ArrayList
        For Each r As DataRow In dt.Rows
            Dim dic As New Dictionary(Of String, Object)
            For Each c As DataColumn In dt.Columns
                dic.Add(c.ColumnName, r(c.ColumnName).ToString)
            Next
            ar.Add(dic)
        Next
        Return jsS.Serialize(ar)
    End Function
    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function GetTaxJuri(ByVal q As String, ByVal isCheck As String) As String


        If Not IsNothing(q) AndAlso Not String.IsNullOrEmpty(q) AndAlso Not String.IsNullOrEmpty(q) Then
            q = Replace(Replace(Trim(q), "'", "''"), "*", "%")
            Dim strCond As String = String.Format("TXJCD LIKE '{0}%'", q.ToUpper)
            If isCheck = "Y" Then
                strCond = String.Format("TXJCD = '{0}'", q.ToUpper)
            End If
            Dim dt As DataTable = SAPDAL.OraDbUtil.dbGetDataTable("SAP_PRD", String.Format("select NVL((CASE WHEN XSKFN='X' THEN '' ELSE TXJCD END),' ') AS name from saprdp.TTXJ WHERE {0} and MANDT=168 and rownum<=10 AND XSKFN<>'X'", strCond))
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                Dim s As String = toJson(dt)
                Return s
            End If
        End If
        Return "[]"
    End Function

    Protected Sub btnConfirmShipValidate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        validateShipAddress(True)
        goNext()
    End Sub

    <Services.WebMethod(EnableSession:=True)>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function Get3SParts(ByVal ShiptoID As String) As String
        'Ryan 20160921 Add 3S litigation parts validation
        Dim msg As String = String.Empty
        Dim DefaultShipto As String = "", CountryCode As String = ""
        If (Not String.IsNullOrEmpty(ShiptoID)) Then
            DefaultShipto = ShiptoID
        Else
            DefaultShipto = Advantech.Myadvantech.Business.UserRoleBusinessLogic.MYAgetShiptoIDBySoldtoID(HttpContext.Current.Session("company_id").ToString(), HttpContext.Current.Session("cart_id").ToString)
        End If
        CountryCode = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getCountryCodeByERPID(DefaultShipto)
        Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(HttpContext.Current.Session("cart_id").ToString)
        Dim returnmsg As List(Of String) = New List(Of String)
        Dim refmsg As String = String.Empty
        For Each _cartItem As CartItem In _cartlist
            refmsg = ""
            If Advantech.Myadvantech.Business.PartBusinessLogic.PatentLitigationParts(_cartItem.Part_No, CountryCode, refmsg) Then
                returnmsg.Add(_cartItem.Part_No + ", " + refmsg)
            End If
        Next
        Dim jsr As New Script.Serialization.JavaScriptSerializer()
        Return jsr.Serialize(returnmsg)
    End Function

    'Protected Sub btnBBFreightCalculation_Click(sender As Object, e As EventArgs)
    '    Dim SoldtoID As String = Me.soldtoaddress.ERPID
    '    Dim ShiptoID As String = Me.shiptoaddress.ERPID
    '    Dim BilltoID As String = Me.billtoaddress.ERPID

    '    'Sold-to
    '    Dim SoldtoCompany As Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY = New Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY()
    '    If Not String.IsNullOrEmpty(SoldtoID) Then
    '        SoldtoCompany.COMPANY_ID = SoldtoID
    '       SoldtoCompany.COUNTRY = Me.soldtoaddress.Country
    '        SoldtoCompany.REGION_CODE = Me.soldtoaddress.State
    '        SoldtoCompany.ZIP_CODE = Me.soldtoaddress.Zipcode
    '    Else
    '        SoldtoID = Session("company_id")
    '        SoldtoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
    '    End If

    '    'Ship-to
    '    Dim ShiptoCompany As Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY = New Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY()
    '    If Not String.IsNullOrEmpty(ShiptoID) Then
    '        ShiptoCompany.COMPANY_ID = ShiptoID
    '        ShiptoCompany.COUNTRY = Me.shiptoaddress.Country
    '        ShiptoCompany.REGION_CODE = Me.shiptoaddress.State
    '        ShiptoCompany.ZIP_CODE = Me.shiptoaddress.Zipcode
    '    Else
    '        ShiptoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
    '    End If

    '    'Bill-to
    '    Dim BilltoCompany As Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY = New Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY()
    '    If Not String.IsNullOrEmpty(BilltoID) Then
    '        BilltoCompany.COMPANY_ID = BilltoID
    '        BilltoCompany.COUNTRY = Me.billtoaddress.Country
    '        BilltoCompany.REGION_CODE = Me.billtoaddress.State
    '        BilltoCompany.ZIP_CODE = Me.billtoaddress.Zipcode
    '    Else
    '        BilltoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
    '    End If

    '    Dim CartItems As List(Of Advantech.Myadvantech.DataAccess.cart_DETAIL_V2) = Advantech.Myadvantech.DataAccess.CartDetailHelper.GetCartDetailByID(CartId)

    '    If CartItems IsNot Nothing AndAlso CartItems.Count > 0 Then
    '        Dim result As Boolean = Me.ascxBBFreightCalculation.GetFreight(SoldtoCompany, ShiptoCompany, BilltoCompany, CartItems)

    '        Me.txtFinalFreightOption.Text = String.Empty
    '        Me.txtFinalFreightOptionValue.Value = String.Empty
    '        Me.txtBBFreight.Text = String.Empty

    '        ClientScript.RegisterStartupScript(GetType(Page), "Script", "ShowFancyBox('divBBFreightCalculation');", True)

    '    Else
    '        Util.JSAlert(Me.Page, "Cart is empty!")
    '    End If
    'End Sub

    Protected Sub EnableRevenueSplitSettings()
        trRevenueSplit.Visible = True
        ddlRevenueSpiltPerson.Items.Clear()
        For Each r As ListItem In ddlSE.Items
            ddlRevenueSpiltPerson.Items.Add(New ListItem(r.Text, r.Value))
        Next
        Dim dtATR8 As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", "select katr8, vtext from saprdp.TVK8T where mandt='168' and spras='E'")
        If dtATR8 IsNot Nothing AndAlso dtATR8.Rows.Count > 0 Then
            For Each d As DataRow In dtATR8.Rows
                ddlRevenueSpiltOption.Items.Add(New ListItem(d.Item("VTEXT").ToString, d.Item("katr8").ToString))
            Next
        End If
        ddlRevenueSpiltOption.Items.Insert(0, New ListItem("Select…", ""))
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="/Includes/EasyUI/jquery.min.js"></script>
    <script type="text/javascript" src="/Includes/EasyUI/jquery.easyui.min.js"></script>
    <link rel="stylesheet" type="text/css" href="/Includes/EasyUI/demo.css" />
    <link rel="stylesheet" type="text/css" href="/Includes/EasyUI/themes/metro/easyui.css" />
    <link rel="stylesheet" type="text/css" href="/Includes/EasyUI/themes/icon.css" />
    <table width="100%">
        <tr>
            <td class="menu_title">Order Information
                 <asp:Button ID="btn_enter" runat="server" OnClientClick="return false;"
                     Height="0px" Width="0px" />
            </td>
        </tr>
        <tr id="orderaddressesforus" runat="server">
            <td colspan="2">
                <table>
                    <tr>
                        <td class="h5">Sold to
                        </td>
                        <td class="h5">Ship to
                        </td>
                        <td class="h5" id="tdbillto" runat="server" visible="false">Bill to
                        </td>
                        <td class="h5" id="thendcustomer" runat="server" visible="false">End Customer
                        </td>
                    </tr>
                    <tr>
                        <td valign="top">
                            <uc1:OrderAddress ID="soldtoaddress" runat="server" IsCanPick="false" Type="SOLDTO" />
                        </td>
                        <td valign="top">
                            <uc1:OrderAddress ID="shiptoaddress" runat="server" Type="S" />
                        </td>
                        <td valign="top" id="tdbilltoascx" runat="server" visible="false">
                            <uc1:OrderAddress ID="billtoaddress" runat="server" Type="B" />
                        </td>
                        <td valign="top" id="tdendcustomer" runat="server" visible="false">
                            <uc1:OrderAddress ID="endcustomer" runat="server" Type="EM" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="trBBUSContact" runat="server" visible="false">
            <td class="h5" style="width: 25%">Order Confirmation Receiver:                
            </td>
            <td style="width: 300px">
                <asp:TextBox runat="server" ID="txtBBContact" Width="300"></asp:TextBox>
                <input type="button" id="btnAddNewContact" value="Add New" style="vertical-align: top; height: 25px;" onclick="ShowFancyBox('divCreateSAPContact');" />
            </td>
        </tr>
        <tr id="trBBUSTax" runat="server" visible="false">
            <td class="h5" style="width: 25%">Tax Amount:                
            </td>
            <td style="width: 300px">
                <asp:UpdatePanel ID="upBBUS" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:TextBox runat="server" ID="txtBBTaxAmount" Width="100" ReadOnly="true"></asp:TextBox>
                        &nbsp;
                        (TaxRate:
                        <asp:Label runat="server" ID="lbBBTaxRate" Text="0"></asp:Label>)
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr id="trBBUSDropShipment" runat="server" visible="false">
            <td class="h5" style="width: 25%">Drop Shipment:
            </td>
            <td style="width: 300px">
                <asp:UpdatePanel ID="upBBUSDropShipment" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:RadioButtonList ID="rblDropShipment" runat="server" RepeatDirection="Horizontal">
                            <asp:ListItem Value="true" Selected="True">Y</asp:ListItem>
                            <asp:ListItem Value="false">N</asp:ListItem>
                        </asp:RadioButtonList>
                    </ContentTemplate>
                </asp:UpdatePanel>

            </td>
        </tr>
        <tr id="trBBUSFreightChargeBy" runat="server" visible="false">
            <td class="h5" style="width: 25%">Freight Charge By:                
            </td>
            <td>
                <div>
                    <asp:DropDownList ID="ddlBBUSFreightChargeBy" runat="server">
                        <asp:ListItem Text="SHIPPER" Value="SHIPPER"></asp:ListItem>
                        <asp:ListItem Text="RECEIVER" Value="RECEIVER" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="3RD PARTY" Value="3RD PARTY"></asp:ListItem>
                        <asp:ListItem Text="COSIGNEE" Value="COSIGNEE"></asp:ListItem>
                    </asp:DropDownList>
                    <input type="button" id="btnBBUSFreightChargeByEdit" value="Edit" />
                </div>
                <div id="divlBBUSFreightChargeByContainer" style="display: none">
                    <table>
                        <tr>
                            <td style="font-size: 20px; color: #003377; text-align: center;">Freight Charge By
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <uc1:OrderAddress ID="FreightChargeByAddress" runat="server" IsCanPick="false" Type="ZP" />
                            </td>
                        </tr>
                        <tr>
                            <td class="h5" colspan="5">
                                <h5>Courier Account</h5>
                                <asp:TextBox runat="server" ID="txtCourier" Style="width: 99%" onblur="return checkdate(this,'150')"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr id="trBBUSCustomTaxChargeBy" runat="server" visible="false">
            <td class="h5" style="width: 25%">Custom Tax Charge By:              
            </td>
            <td>
                <div>
                    <asp:DropDownList ID="ddlBBUSCustomTaxChargeBy" runat="server">
                        <asp:ListItem Text="SHIPPER" Value="SHIPPER"></asp:ListItem>
                        <asp:ListItem Text="RECEIVER" Value="RECEIVER" Selected="True"></asp:ListItem>
                        <asp:ListItem Text="3RD PARTY" Value="3RD PARTY"></asp:ListItem>
                        <asp:ListItem Text="COSIGNEE" Value="COSIGNEE"></asp:ListItem>
                    </asp:DropDownList>
                    <input type="button" id="btnBBUSCustomTaxChargeByEdit" value="Edit" />
                </div>
                <div id="divlBBUSCustomTaxChargeByContainer" style="display: none">
                    <table>
                        <tr>
                            <td style="font-size: 20px; color: #003377; text-align: center;">Custom Tax Charge By
                            </td>
                        </tr>
                        <tr>
                            <td valign="top">
                                <uc1:OrderAddress ID="CustomTaxChargeByAddress" runat="server" IsCanPick="false" Type="ZQ" />
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr id="trPayer" runat="server" visible="false">
            <td class="h5" style="width: 25%">Payer:              
            </td>
            <td>
                <div>
                    <asp:DropDownList ID="ddlPayer" runat="server">
                    </asp:DropDownList>
                </div>
            </td>
        </tr>
        <tr>
            <td style="height: 15px"></td>
        </tr>
        <tr runat="server" id="trOrderNo" visible="false">
            <td class="h5" style="width: 25%">Order Number is generated by :
            </td>
            <td>
                <asp:RadioButtonList ID="rbOrderNo" runat="server" RepeatDirection="Horizontal">
                    <asp:ListItem Value="0" Selected="True">MyAdvantech</asp:ListItem>
                    <asp:ListItem Value="1">SAP </asp:ListItem>
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr runat="server" id="trAVNBTOSOption" visible="false">
            <td class="h5" style="width: 25%">System Assemble In:
            </td>
            <td>
                <asp:RadioButtonList ID="rdlAVNBTOSOption" runat="server" RepeatDirection="Horizontal">
                    <asp:ListItem Value="ACL" Selected="True">ACL</asp:ListItem>
                    <asp:ListItem Value="AVN">AVN</asp:ListItem>
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr>
            <td class="h5" style="width: 25%">
                <asp:Literal runat="server" ID="litRD">Required Date</asp:Literal>:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtreqdate"></asp:TextBox>
                (
                <asp:Literal runat="server" ID="litRDF">yyyy/MM/dd </asp:Literal>)
                <asp:Label runat="server" ID="reqdate_label" Visible="false" ForeColor="Red" Text=""></asp:Label>
            </td>
        </tr>
        <tr runat="server" id="trDelPlant" visible="false">
            <td class="h5" style="width: 25%">Delivery Plant:
            </td>
            <td>
                <asp:DropDownList ID="drpDelPlant" runat="server">
                    <asp:ListItem Value="SGH1">SGH1</asp:ListItem>
                    <asp:ListItem Value="TWH1">TWH1</asp:ListItem>
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td class="h5" style="width: 25%">PO Number:
            </td>
            <td>
                <table>
                    <tr>
                        <td>
                            <asp:TextBox runat="server" ID="txtPONo" AutoPostBack="true" OnTextChanged="txtPONo_TextChanged" />
                        </td>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upPoDuplicateMsg" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Label runat="server" ID="lbPoDuplicateMsg" Font-Bold="true" ForeColor="Tomato"
                                        Font-Size="X-Small" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="txtPONo" EventName="TextChanged" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                        <td id="tdFileUpload" runat="server" visible="false">
                            <asp:FileUpload runat="server" ID="FileUpload1" ToolTip="UploadFile" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="h5">PO Date:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtPODate"></asp:TextBox>
                <ajaxToolkit:CalendarExtender TargetControlID="txtPODate" runat="server" Format="yyyy/MM/dd" ID="calDate" />
            </td>
        </tr>
        <tr id="TRAttention" runat="server" visible="false">
            <td class="h5">Attention:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtAttention"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td colspan="2">

                <table style="width: 80%">
                    <tr>
                        <td style="width: 50%">
                            <uc2:PartialDeliver ID="PartialDeliver1" runat="server" />
                        </td>
                        <td style="width: 50%" runat="server" visible="false" id="tbExempt">
                            <asp:CheckBox ID="cbxIsTaxExempt" runat="server" Text="Tax Exempt?" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr runat="server" id="tyEarlyShip" visible="false">
            <td colspan="2">
                <asp:CheckBox runat="server" ID="cbEarlyShipmentAllowed" Text=" Early Shipment Allowed?"
                    Font-Bold="true" />
            </td>
        </tr>
        <tr runat="server" id="stShipCondition">
            <td class="h5">
                <span runat="server" id="spShipc">Ship Condition:</span>
            </td>
            <td>
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:DropDownList runat="server" ID="drpShipCondition">
                            </asp:DropDownList>
                        </td>
                        <td style="padding-left: 10px;">
                            <span runat="server" id="SpanInct" class="h5">Incoterm:</span>
                            <asp:DropDownList runat="server" ID="drpIncoterm">
                            </asp:DropDownList>
                        </td>
                        <td id="tdShipVia" runat="server" class="h5" style="padding-left: 10px; padding-right: 4px;">
                            <div>
                                Ship via:
                            <asp:TextBox runat="server" ID="txtIncoterm" onblur="return checkdate(this,'28')"></asp:TextBox><asp:Label ID="Label1" runat="server" Text="( Maximum 28 Characters )"></asp:Label>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr runat="server" id="trFreightOptionBB" visible="false">
            <td class="h5">Freight Option:
            </td>
            <td>
                <table>
                    <tr>
                        <%--                        <td><asp:Button ID="btnBBFreightCalculation" runat="server" Text="Select Freight Option" OnClick="btnBBFreightCalculation_Click" />:</td>--%>
                        <td>
                            <input id="btnBBFreightCalculation2" type="button" value="Select Freight Option" />
                        </td>
                        <td>
                            <asp:TextBox ID="txtFinalFreightOption" runat="server" Style="width: 230px;"></asp:TextBox>
                            <asp:HiddenField ID="txtFinalFreightOptionValue" runat="server"></asp:HiddenField>
                            <span>$</span><asp:TextBox ID="txtBBFreight" runat="server" Style="width: 50px;"></asp:TextBox>
                        </td>

                    </tr>
                </table>


            </td>
        </tr>

        <%--<tr>
            <td class="h5">
                Incoterm:
            </td>
            <td>
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:DropDownList runat="server" ID="drpIncoterm">
                            </asp:DropDownList>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>--%>
        <tr runat="server" id="trPayTerm" visible="false" valign="top">
            <td class="h5">Payment Term:<br />
                (Visible to internal user only)
            </td>
            <td>
                <table>
                    <tr valign="top">
                        <td>
                            <asp:DropDownList runat="server" ID="dlPayterm" OnSelectedIndexChanged="dlPayterm_SelectedIndexChanged"
                                AutoPostBack="True" />
                        </td>
                    </tr>
                    <tr valign="top">
                        <td>
                            <asp:UpdatePanel runat="server" ID="upCreditCard" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <table align="left" cellpadding="0" cellspacing="0" runat="server" id="tbCreditCardInfo"
                                        visible="false">
                                        <tr>
                                            <th align="left">Card Type:
                                            </th>
                                            <td>
                                                <asp:DropDownList runat="server" ID="dlCCardType">
                                                    <asp:ListItem Value="AMEX" Text="American Express" />
                                                    <asp:ListItem Value="DISC" Text="Discover" />
                                                    <asp:ListItem Value="MC" Text="Master -/Euro Card" />
                                                    <asp:ListItem Value="VISA" Text="Visa Card" />
                                                </asp:DropDownList>
                                            </td>
                                            <td class="h5" width="125">Credit Card Number:
                                            </td>
                                            <td width="150" style="padding-left: 5px;">
                                                <asp:TextBox runat="server" ID="txtCreditCardNumber" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="left">Holder's Name:
                                            </th>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtCCardHolder" />
                                            </td>
                                            <td class="h5" width="100" align="left">Expire Date:
                                            </td>
                                            <td width="100" style="padding-left: 5px;">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:DropDownList runat="server" ID="dlCCardExpYear" />
                                                        </td>
                                                        <td>
                                                            <asp:DropDownList runat="server" ID="dlCCardExpMonth">
                                                                <asp:ListItem Text="January" Value="1" />
                                                                <asp:ListItem Text="February" Value="2" />
                                                                <asp:ListItem Text="March" Value="3" />
                                                                <asp:ListItem Text="April" Value="4" />
                                                                <asp:ListItem Text="May" Value="5" />
                                                                <asp:ListItem Text="June" Value="6" />
                                                                <asp:ListItem Text="July" Value="7" />
                                                                <asp:ListItem Text="August" Value="8" />
                                                                <asp:ListItem Text="September" Value="9" />
                                                                <asp:ListItem Text="October" Value="10" />
                                                                <asp:ListItem Text="November" Value="11" />
                                                                <asp:ListItem Text="December" Value="12" />
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="h5" width="120" align="left">CVV Code:
                                            </td>
                                            <td colspan="3" width="200">
                                                <asp:TextBox runat="server" ID="txtCCardVerifyValue" Width="45" AutoPostBack="true" />
                                            </td>
                                        </tr>
                                        <tr valign="top">
                                            <td>
                                                <asp:LinkButton runat="server" ID="lBtnAuthCcInfo" Text="Verify Credit Card" OnClick="lBtnAuthCcInfo_Click" />
                                                <br />
                                                <asp:CheckBox runat="server" ID="ckbUserNewBillAddress" AutoPostBack="true" Text="Use New Bill Address"
                                                    OnCheckedChanged="ckbUserNewBillAddress_OnCheckedChanged" />
                                            </td>
                                            <td colspan="3">
                                                <uc1:OrderAddress ID="newbilladdress" runat="server" Editable="true" Visible="false" />
                                            </td>
                                        </tr>
                                        <tr style="height: 10px">
                                            <td colspan="2">
                                                <asp:Label runat="server" ID="lbCCardMsg" Font-Bold="true" ForeColor="Tomato" />
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="dlPayterm" EventName="SelectedIndexChanged" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="trSE" runat="server" visible="false">
            <td class="h5">Sales Employee:
            </td>
            <td align="left">
                <asp:DropDownList runat="server" ID="ddlSE">
                </asp:DropDownList>
            </td>
        </tr>
        <tr runat="server" id="tdE2name" visible="false">
            <td class="h5">Sales Employee 2:
            </td>
            <td runat="server" id="tdE2" visible="false">
                <asp:DropDownList runat="server" ID="ddlSE2">
                </asp:DropDownList>
            </td>
        </tr>
        <tr runat="server" id="tdE3name" visible="false">
            <td class="h5">Sales Employee 3:
            </td>
            <td runat="server" id="tdE3" visible="false">
                <asp:DropDownList runat="server" ID="ddlSE3">
                </asp:DropDownList>
            </td>
        </tr>
        <tr id="trKeyInPerson" runat="server" visible="false">
            <td class="h5">
                <asp:Label ID="lbKeyInPerson" runat="server" Text="Key In Person"></asp:Label>
            </td>
            <td>
                <asp:DropDownList runat="server" ID="ddlKeyInPerson">
                </asp:DropDownList>
            </td>
        </tr>
        <tr id="trRevenueSplit" runat="server" visible="false">
            <td class="h5">Sales Employee 2 (Revenue Split)
            </td>
            <td>
                <asp:DropDownList runat="server" ID="ddlRevenueSpiltPerson">
                </asp:DropDownList>
                <asp:DropDownList runat="server" ID="ddlRevenueSpiltOption">
                </asp:DropDownList>
            </td>
        </tr>
        <tr id="trEmployeeResponse" runat="server" visible="false">
            <td class="h5">
                <asp:Label ID="lbEmployeeResponse" runat="server" Text="Employee Response"></asp:Label>
            </td>
            <td>
                <asp:DropDownList runat="server" ID="ddlEmployeeResponse">
                </asp:DropDownList>
            </td>
        </tr>
        <tr id="trDSGSO" runat="server" visible="false">
            <td class="h5"></td>
            <td>
                <asp:UpdatePanel runat="server" ID="upDistChannDiv" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table>
                            <tr>
                                <td class="h5">Distribution Channel:
                                </td>
                                <td>
                                    <asp:DropDownList runat="server" ID="dlDistChann" AutoPostBack="true" OnSelectedIndexChanged="dlDistChann_SelectedIndexChanged">
                                        <asp:ListItem Text="Select..." Value="" Selected="True" />
                                        <asp:ListItem Value="10" />
                                        <asp:ListItem Value="20" />
                                        <asp:ListItem Value="30" />
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <table runat="server" id="tbDivSalesGrpOffice" visible="false">
                                        <tr>
                                            <td class="h5">Division:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlDivision" />
                                            </td>
                                            <td class="h5">Sales Group:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlSalesGroup" />
                                            </td>
                                            <td class="h5">Sales Office:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlSalesOffice" />
                                            </td>
                                            <td class="h5">District:
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtSalesDistrict" Width="30px" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr id="trOSBitSelection" runat="server" visible="false">
            <td class="h5">
                <asp:Label ID="lbOSBitSelection" runat="server" Text="OS Bit"></asp:Label>
            </td>
            <td>
                <asp:DropDownList runat="server" ID="ddlOSBitSelection">
                    <asp:ListItem Text="Select..." Value="" Selected="True" />
                    <asp:ListItem Value="32" Text="32 bit" />
                    <asp:ListItem Value="64" Text="64 bit" />
                </asp:DropDownList>
            </td>
        </tr>
        <tr id="trBTOSInstruction" runat="server" visible="false">
            <td class="h5">
                <asp:Label ID="lbBTOSInstruction" runat="server" Text="BTOS Instruction:"></asp:Label>
            </td>
            <td>
                <table>
                    <asp:Repeater ID="rpBTOSInstruction" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:HiddenField ID="hfBTOSLineNo" runat="server" Value='<%#Eval("LINE_NO")%>' />
                                    <asp:Label ID="lbBTOSName" runat="server" Text='<%#Eval("PART_NO")%>'></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox TextMode="MultiLine" Width="250px" Height="50px" ID="txtBTOSInstruction" runat="server" Style="display: table-cell; vertical-align: middle;"></asp:TextBox>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </table>                
            </td>
        </tr>
        <tr id="trON" runat="server">
            <td class="h5">Order Note (External Note):<br />
                (Maximum 1000 Characters)
            </td>
            <td>
                <asp:TextBox TextMode="MultiLine" Width="300px" Height="80px" runat="server" ID="txtOrderNote"
                    onblur="return checkdate(this,'1000')"></asp:TextBox>
            </td>
        </tr>
        <tr id="trSN" runat="server">
            <td class="h5">Sales Note From Customer:<br />
                (Maximum 300 Characters)
            </td>
            <td>
                <asp:UpdatePanel runat="server" ID="upSalesNote" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:TextBox TextMode="MultiLine" Width="300px" Height="80px" runat="server" ID="txtSalesNote"
                            onblur="return checkdate(this,'3000')"></asp:TextBox>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="lBtnAuthCcInfo" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr id="trOPN" runat="server">
            <td class="h5">EU OP Note:<br />
                (Maximum 100 Characters)
            </td>
            <td>
                <asp:TextBox TextMode="MultiLine" Width="300px" Height="80px" runat="server" ID="txtOPNote"
                    onblur="return checkdate(this,'100')"></asp:TextBox>
            </td>
        </tr>
        <tr runat="server" id="trBillInfo" visible="false">
            <td class="h5">Billing Instruction Info:
            </td>
            <td>
                <asp:UpdatePanel runat="server" ID="upBillingInstructionInfo" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:TextBox Width="300px" runat="server" ID="txtBillingInstructionInfo" TextMode="MultiLine"
                            Height="80px" onblur="return checkdate(this,'2000')" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="lBtnAuthCcInfo" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr runat="server" id="trFreTax">
            <td class="h5">Freight Fee:
            </td>
            <td>
                <table>
                    <tr>
                        <td>Freight(taxable):
                        </td>
                        <td>
                            <asp:TextBox ID="txtFtTax" runat="server"></asp:TextBox>
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft1" TargetControlID="txtFtTax"
                                FilterType="Numbers, Custom" ValidChars="." />
                        </td>
                    </tr>
                    <tr>
                        <td>Free Freight Charge:
                        </td>
                        <td>
                            <asp:TextBox ID="txtFtFre" runat="server"></asp:TextBox>
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="Filteredtextboxextender1"
                                TargetControlID="txtFtFre" FilterType="Numbers, Custom" ValidChars="." />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

    </table>
    <table width="100%">
        <tr>
            <td width="30%"></td>
            <td align="center">
                <asp:Button runat="server" Text="Next" ID="btnPIPreview" OnClientClick="if (Check3SParts() == false) return false;" OnClick="btnPIPreview_Click"
                    Width="150px" />
            </td>
            <td id="D2Std" align="center" runat="server" visible="false">
                <asp:Button ID="btnDirect2SAP" runat="server" Text=" >> Direct2SAP << " OnClick="btnDirect2SAP_Click"
                    Visible="false" />
            </td>
            <td width="30%"></td>
        </tr>
    </table>
    <asp:HiddenField runat="server" ID="hdlgCSV" ViewStateMode="Disabled" Value="0" />
    <div id="dlgShipValidate" class="easyui-dialog" data-options="modal:false" title="Shipping Address Confirm :"
        style="padding: 5px; width: 500px; height: 120px" closed="true">
        <asp:Panel ID="pa2" runat="server">
            <table>
                <tr>
                    <td>
                        <font color="red">*</font> Shipping address does not match UPS/FedEx database, please reconfirm or correct order shipping address.
                    </td>
                </tr>
            </table>
            <div style="text-align: center">
                <input type="button" value="Edit" id="quitShipValidate" onclick="$('#dlgShipValidate').dialog('close')" />/
            <asp:Button runat="server" ID="btnConfirmShipValidate" Text="Confirm" OnClick="btnConfirmShipValidate_Click" />
            </div>
        </asp:Panel>
    </div>
    <div id="showresult" style="display: none" title="Warning"></div>
    <script type="text/javascript">
        $(document).ready(function () {
            <%If AuthUtil.IsAJP Then%>

                <%If Util.IsInternalUser2 AndAlso Me.ascxCreditInfo.isBalanceExpired Then%>
            ShowFancyBox('divCustomerCreditInfo');
                <%End If%>

            $("select").searchable({
                maxMultiMatch: 700,
            });

            <%ElseIf AuthUtil.IsACN Then %>

            $("select").searchable({
                maxMultiMatch: 700,
            });

            <%ElseIf AuthUtil.IsAEU Then %>

                <%If Util.IsInternalUser2 AndAlso Me.ascxCreditInfo.isBalanceExpired Then%>
            ShowFancyBox('divCustomerCreditInfo');
            <%End If%>

            <%ElseIf AuthUtil.IsBBUS Then %>

            BBUSSettings();

            <%End If%>
        });

        function showhideDlg() {
            if ($("#<%=Me.hdlgCSV.ClientID %>").val() == 1) {
                $("#dlgShipValidate").parent().appendTo("form:first");
                $('#dlgShipValidate').dialog('open');
                $("#<%=Me.hdlgCSV.ClientID %>").val(0)
            }
            else { $('#dlgShipValidate').dialog('close'); }
        }

        $(function () {
            $("#dlgShipValidate").dialog({
                autoOpen: false,
                width: 'auto',
                height: 'auto',
                closeText: 'X'
            });
            showhideDlg();
        });

        function PickDate(Url, Element) {
            Url = Url + "?Element=" + Element.name
            window.open(Url, "pop", "height=265,width=263,top=300,left=400,scrollbars=no")
        }

        var isCheck = true;
        function checkdate(id, Maximum) {
            if (isCheck) {
                if (id.value.length > Maximum) {
                    alert('More than ' + Maximum + ' characters')
                    id.focus()
                    isCheck = false;
                    return false;
                }
                else {
                    return true;
                }
            }
            else {
                isCheck = true;
                return true;
            }
        }
    </script>
    <link href="../Includes/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../Includes/jquery-latest.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="../Includes/js/jquery-ui.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.searchabledropdown-1.0.8.min.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <link rel="Stylesheet" href="../../Includes/FancyBox/jquery.fancybox.css" type="text/css" />
    <script type="text/javascript" src="../../Includes/js/jquery.tokeninput_showallonclick.js"></script>
    <link rel="stylesheet" href="../../Includes/js/token-input-facebook.css" type="text/css" />


    <script type="text/javascript">
        // Ryan 20160922 Add for check cart items are 3S Parts or not.
        function Check3SParts() {
            var flag = false;
            var postData = JSON.stringify({ ShiptoID: $("#<%=Me.txtShipTo.ClientID%>").val() });
            $.ajax({
                url: 'OrderInfoV2.aspx/Get3SParts', type: "POST",
                contentType: "application/json; charset=utf-8", dataType: 'json', data: postData, async: false,
                success: function (retData) {
                    var ret = $.parseJSON(retData.d);
                    var msg = "";

                    if (ret.length > 0) {
                        for (var i = 0; i < ret.length; i++) {
                            msg += (i + 1) + ". " + ret[i] + "<br />";
                        }
                        msg = "Ordering process is blocked due to below cart items  have issues in ship-to country (" + $("#<%=Me.txtShiptoCountry.ClientID%>").val() + "). <br /><br />" + msg +
                                "<br /><br />Click 'Edit CartItems' to go back to shopping cart to remove these items, or click 'Change ShiptoID' and select another ship-to ID.";

                        $("#showresult").html(msg);
                        $("#showresult").dialog({
                            show: "blind",
                            hide: "blind",
                            width: 'auto',
                            height: 'auto',
                            dialogClass: 'DialogClass',
                            buttons: [{
                                text: "Edit CartItems",
                                click: function () {
                                    window.location = "Cart_ListV2.aspx";
                                }
                            },
                            {
                                text: "Change ShiptoID",
                                click: function () {
                                    flag = false;
                                    $(this).dialog("close");
                                }
                            }]
                        }).load(msg, function () {
                            $(this).dialog("option", "position", ['center', 'center']);
                        });
                    }
                    else {
                        flag = true;
                    }
                },
                error: function (msg) {
                    console.log("err:" + msg);
                    flag = false;
                }
            });
            return flag;
        }


        function ShowFancyBox(divName) {
            var gallery = [{
                href: '#' + divName
            }];

            $.fancybox(gallery, {
                'autoSize': true,
                'autoCenter': true
            });
        }

        function SetBBFreightFromASCX(DeliveryType, DeliveryValue, Cost) {
            $("#<%=Me.txtFinalFreightOption.ClientID%>").val(DeliveryType);
            $("#<%=Me.txtFinalFreightOptionValue.ClientID%>").val(DeliveryValue);
            $("#<%=Me.txtBBFreight.ClientID%>").val(Cost);
            //$("#<%=Me.txtBBFreight.ClientID%>").attr("readonly", true);
        }

        function SetBBContactTokenFromASCX(id, name) {
            $("#<%=txtBBContact.ClientID%>").tokenInput("add", { id: id, name: name });
        }


        function GetBBGetFreight() {
            $("#BBFreightLoading").show();
            $("#BBFreightDetailContent").hide();


            $country = $('#<%=Me.shiptoaddress.ShipToCountry.ClientID%>').val();
            $zipCode = $('#<%=Me.shiptoaddress.ShipToZipCode.ClientID%>').val();
            $state = $('#<%=Me.shiptoaddress.ShipToState.ClientID%>').val();
            cardId = '<%=Session("cart_id")%>';
            var postData = {
                shipToCountry: $country, shipToZipCode: $zipCode, shipToState: $state, cartId: cardId
            };


            $.ajax({
                url: '<%=System.IO.Path.GetFileName(Request.ApplicationPath) %>/Services/BBorderAPI.asmx/GetFreight',
                type: "POST",
                dataType: "json",
                async: true,
                data: postData,
                success: function (retData) {
                    $("#BBFreightLoading").hide();
                    $("#BBFreightDetailContent").show();
                    if (retData.ShippingMethods && retData.ShippingMethods.length > 0) {
                        $('.bbFreightWeight').html("Total weight: " + retData.Weight + " pounds");


                        if (retData.Message)
                            $('.overallMessage').html("<label><b style=\"color: #ff0033;  font-size:14px;\">" + retData.Message + "</b></label>");
                        else
                            $('.overallMessage').html("");



                        for (var i = 0; i < retData.ShippingMethods.length; i++) {
                            $('#table_BBFreight_result tbody').append("<tr dtype='" + retData.ShippingMethods[i].MethodName + "' dvalue='" + retData.ShippingMethods[i].MethodValue + "' fvalue='" + retData.ShippingMethods[i].ShippingCost + "'>" + "<td style='width:70px'>" + retData.ShippingMethods[i].MethodName + "</td>" + "<td style='width:60px'>" + retData.ShippingMethods[i].DisplayShippingCost + "</td>" + "<td style='width:40px'>" + retData.ShippingMethods[i].ErrorMessage + "</td></tr>");

                        }

                    }

                    $.fancybox.update();
                    $("#table_BBFreight_result td").hover(function () {
                        $("td", $(this).closest("tr")).addClass("hover_row");
                    }, function () {
                        $("td", $(this).closest("tr")).removeClass("hover_row");
                    });

                    $("#table_BBFreight_result td").click(function () {
                        var deliveryType = "";
                        var deliveryValue = "";
                        var freightCost = "";
                        var selectRow = $(this).closest("tr");

                        deliveryType = selectRow.attr("dtype");
                        deliveryValue = selectRow.attr("dvalue");
                        freightCost = selectRow.attr("fvalue");
                        SetBBFreightFromASCX(deliveryType, deliveryValue, freightCost);
                        $.fancybox.close();
                    });

                },
                error: function (msg) {
                    $("#BBFreightLoading").hide();
                    $("#BBFreightDetailContent").show();

                },
                complete: function () {
                    $("#BBFreightLoading").hide();
                    $("#BBFreightDetailContent").show();
                }
            });

        }

        function BBUSSettings() {
            $("#<%=Me.txtFinalFreightOption.ClientID%>").attr("readonly", true);
            $("#<%=Me.txtFinalFreightOption.ClientID%>").css("background", "#EBEBE4");
            $("#<%=Me.txtFinalFreightOption.ClientID%>").css("border", "1px solid #AAAAAA");


            if ($('#<%=Me.ddlBBUSFreightChargeBy.ClientID%>').val() == "SHIPPER") {
                $('#btnBBUSFreightChargeByEdit').hide();
            }
            if ($('#<%=Me.ddlBBUSCustomTaxChargeBy.ClientID%>').val() == "SHIPPER") {
                $('#btnBBUSCustomTaxChargeByEdit').hide();
            }

            $('#<%=Me.ddlBBUSFreightChargeBy.ClientID%>').change(function () {
                if ($('#<%=Me.ddlBBUSFreightChargeBy.ClientID%>').val() != "SHIPPER") {
                    $('#btnBBUSFreightChargeByEdit').show();
                    ShowFancyBox('divlBBUSFreightChargeByContainer');
                }
                else {
                    $('#btnBBUSFreightChargeByEdit').hide();
                }
            });
            $('#btnBBUSFreightChargeByEdit').click(function () {
                ShowFancyBox('divlBBUSFreightChargeByContainer');
            });

            $('#<%=Me.ddlBBUSCustomTaxChargeBy.ClientID%>').change(function () {
                if ($('#<%=Me.ddlBBUSCustomTaxChargeBy.ClientID%>').val() != "SHIPPER") {
                    $('#btnBBUSCustomTaxChargeByEdit').show();
                    ShowFancyBox('divlBBUSCustomTaxChargeByContainer');
                }
                else {
                    $('#btnBBUSCustomTaxChargeByEdit').hide();
                }
            });
            $('#btnBBUSCustomTaxChargeByEdit').click(function () {
                ShowFancyBox('divlBBUSCustomTaxChargeByContainer');
            });

            var tokeninputUrl = "<%System.IO.Path.GetFileName(Request.ApplicationPath)%>/Services/AutoComplete.asmx/GetTokenInputCompanyContact";
            $("#<%=txtBBContact.ClientID%>").tokenInput(tokeninputUrl, {
                theme: "facebook", searchDelay: 200, minChars: 0, tokenDelimiter: ";",
                hintText: "Type PartNo", tokenLimit: 7, preventDuplicates: true, resizeInput: false,
                resultsLimit: 6, showing_all_results: true,
                resultsFormatter: function (data) {
                    return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.name + "</span>";
                }
            });

            // Set partial shipment as false if payment term is CODC
            if ($('#<%=Me.dlPayterm.ClientID%>').val() == "CODC") {
                $('#<%=Me.rbtnIsPartial.ClientID%>').find("input:radio").eq(0).removeAttr('checked', 'checked');
                $('#<%=Me.rbtnIsPartial.ClientID%>').find("input:radio").eq(1).attr('checked', 'checked');
                $('#<%=Me.rbtnIsPartial.ClientID%>').find("input:radio").eq(0).attr("disabled", "disabled");
            }
            $('#<%=Me.dlPayterm.ClientID%>').change(function () {
                if ($('#<%=Me.dlPayterm.ClientID%>').val() == "CODC") {
                    $('#<%=Me.rbtnIsPartial.ClientID%>').find("input:radio").eq(0).removeAttr('checked', 'checked');
                    $('#<%=Me.rbtnIsPartial.ClientID%>').find("input:radio").eq(1).attr('checked', 'checked');
                    $('#<%=Me.rbtnIsPartial.ClientID%>').find("input:radio").eq(0).attr("disabled", "disabled");
                }
                else {
                    $('#<%=Me.rbtnIsPartial.ClientID%>').find("input:radio").eq(0).removeAttr("disabled", "disabled");
                }
            });

            $('#btnBBFreightCalculation2').click(function () {
                $('#table_BBFreight_result tbody').empty();
                ShowFancyBox('divBBFreightCalculation');
                GetBBGetFreight();

            });
        }


    </script>
    <style>
        .DialogClass .ui-dialog-titlebar {
            color: #FFFFFF;
            background: #1f367a;
            font-weight: bold;
        }

        ul.token-input-list-facebook {
            height: 25px;
         
        0px;
      inline-block;
                   }         
        BFreight_result td {
        cursor: pointer;
      }
                    hove;
        r

         {
            backgroun lor: #A1DCF2;
        }
    </style>
    <asp:UpdatePanel runat="server" ID="upCreditCardAuthInfo" UpdateMode="Conditional">
        <ContentTemplate>
            <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
                TargetControlID="PanelCreditAuthInfo" HorizontalSide="Center" VerticalSide="Middle"
                HorizontalOffset="0" VerticalOffset="0" />
            <asp:Panel runat="server" ID="PanelCreditAuthInfo" Visible="false" Width="340px"
                BackColor="LightGray" HorizontalAlign="Center">
                <table align="center" width="100%">
                    <tr>
                        <td align="right">
                            <asp:LinkButton runat="server" ID="lnkCloseCreditCardAuthInfo" Text="Close" OnClick="lnkCloseCreditCardAuthInfo_Click" />
                        </td>
                    </tr>
                    <tr>
                        <td align="center">
                            <uc3:AuthCreditResult ID="AuthCreditResult1" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <%--                        <td align="center">
                            <uc3:AuthCreditResultV2 ID="AuthCreditResult2" runat="server" />
                        </td>--%>
                        <%--                        <td align="center">
                            <uc3:PaymentInfo ID="AuthCreditResult2" runat="server" />
                        </td>--%>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="lBtnAuthCcInfo" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
    <div style="display: none">
        <div id="divBBFreightCalculation">
            <%--            <uc4:BBFreightCalculation ID="ascxBBFreightCalculation" runat="server" />--%>
            <div id="BBFreightLoading">
                <div style="text-align: center; font-size: 16px;">Please wait...</div>
                <div style="background: url(/Images/loading.gif) no-repeat center center; background-color: white;">
                    <div style="text-align: center;">.</div>
                </div>
            </div>
            <div id="BBFreightDetailContent">
                <label style="font-size: 20px; font-weight: bold">Freight Info</label>
                <div style="margin-top: 10px;">
                    <label class="bbFreightWeight"></label>
                </div>
                <div class="overallMessage" style="margin-top: 10px;"></div>
            </div>

            <table style="border: 1px;" id="table_BBFreight_result" class="table_BBFreight_result">
                <thead>
                    <tr style="color: white; background-color: grey">
                        <th style="width: 300px">Delivery Type</th>
                        <th style="width: 30px">Cost</th>
                        <th>Message</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
        <div id="divCustomerCreditInfo">
            <uc6:CrditInfo ID="ascxCreditInfo" runat="server" />
        </div>
    </div>
    <div style="display: none">
        <div id="divCreateSAPContact">
            <uc5:CreateSAPContact ID="ascxCreateSAPContact" runat="server" />
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
