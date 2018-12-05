<%@ Page Title="MyAdvantech–Order Information" EnableEventValidation="false" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<%@ Import Namespace="quote" %>
<%@ Register Src="~/Includes/Order/ShiptoList.ascx" TagName="ShipTo" TagPrefix="uc1" %>
<%@ Register Src="~/Includes/Order/USAOnlineShipBillTo.ascx" TagName="ShipToUS" TagPrefix="uc1" %>
<%@ Register Src="../Includes/PartialDeliver.ascx" TagName="PartialDeliver" TagPrefix="uc2" %>
<%@ Register Src="~/Includes/Order/OrderAddress.ascx" TagName="OrderAddress" TagPrefix="uc1" %>
<%@ Register Src="../Includes/Order/AuthCreditResult.ascx" TagName="AuthCreditResult"
    TagPrefix="uc3" %>
<script runat="server">
    Dim myCompany As New SAP_Company("b2b", "SAP_dimCompany"), myOrderMaster As New order_Master("b2b", "order_master"), myOrderDetail As New order_Detail("b2b", "order_detail"), mycart As New CartList("b2b", "cart_detail"), CartId As String = ""
    Dim rbtnIsPartial As RadioButtonList = Nothing, txtShipTo As TextBox = Nothing, txtShipToAttention As TextBox = Nothing, txtBillTo As TextBox = Nothing
    Dim EQpaymentTerm As String = ""
    Protected Sub FillSalesEmployees()
        Dim SalesEmployees As DataTable = OrderUtilities.getSalesEmployeeList(Session("org_id"), Session("company_id"))
        SalesEmployees.Columns.Add("DisplayName", GetType(String), "FULL_NAME + ' ('+ SALES_CODE +')'")
        ddlSE.DataTextField = "DisplayName" : ddlSE.DataValueField = "SALES_CODE"
        ddlSE.DataSource = SalesEmployees
        ddlSE.DataBind()
        ddlSE.Items.Insert(0, New ListItem("Select…", ""))
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
        If Util.IsTestingQuote2Order() Then
            Response.Redirect(String.Format("OrderInfoV2.aspx{0}", Request.Url.Query))
        End If
        CartId = Session("cart_id")
        rbtnIsPartial = CType(Me.PartialDeliver1.FindControl("rbtnIsPartial"), RadioButtonList)
        txtShipTo = CType(Me.shiptoaddress.FindControl("txtShipTo"), TextBox)
        txtShipToAttention = CType(Me.shiptoaddress.FindControl("txtShipToAttention"), TextBox)
        txtBillTo = CType(Me.billtoaddress.FindControl("txtShipTo"), TextBox)
        If Not Page.IsPostBack Then
            If Session("Org_id") = "EU10" AndAlso Util.IsInternalUser2() Then
                If mycart.CheckCartGPByCartId(CartId) = True Then
                    Response.Redirect("~/Order/GPcontrol.aspx")
                End If
            End If
            txtreqdate.Attributes("onclick") = "PickDate('" + Util.GetRuntimeSiteUrl() + "/INCLUDES/PickShippingCalendar.aspx',this)"
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
            If String.Equals(Session("company_id"), "UUMM001", StringComparison.CurrentCultureIgnoreCase)  Then
                tdendcustomer.Visible = True : thendcustomer.Visible = True
            End If
            
            If Util.IsInternalUser2() AndAlso (Session("account_status") <> "FC" Or Util.IsFranchiser(Session("user_id"), "")) Then
                ' Set  Sales Employee
                trSE.Visible = True
                FillSalesEmployees()
                ddlSE2.Items.Clear() : ddlSE3.Items.Clear()
                For Each r As ListItem In ddlSE.Items
                    ddlSE2.Items.Add(New ListItem(r.Text, r.Value))
                    ddlSE3.Items.Add(New ListItem(r.Text, r.Value))
                Next
                Dim KeyInPersonDT As DataTable = SAPDOC.GetKeyInPersonV2(Session("USER_ID"))
                If KeyInPersonDT.Rows.Count > 0 Then
                    KeyInPersonDT.Columns.Add("DisplayName", GetType(String), "FULL_NAME + ' ('+ SALES_CODE +')'")
                    ddlKeyInPerson.DataTextField = "DisplayName" : ddlKeyInPerson.DataValueField = "SALES_CODE"
                    ddlKeyInPerson.DataSource = KeyInPersonDT
                    ddlKeyInPerson.DataBind()
                    trKeyInPerson.Visible = True
                Else
                    trKeyInPerson.Visible = False
                End If
            End If
       
            initInterface()
            If Util.IsAEUIT() Then
                btnDirect2SAP.Visible = True : D2Std.Visible = True
            End If
            If Session("account_status") = "FC" Then
                trSN.Visible = False : trBillInfo.Visible = False : trFreTax.Visible = False
            End If
            If Util.IsInternalUser2() AndAlso (Session("account_status") <> "FC" Or Util.IsFranchiser(Session("user_id"), "")) Then
                trPayTerm.Visible = True
                
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
                    If drpIncoterm.Items.FindByValue("FB1") IsNot Nothing Then
                        drpIncoterm.SelectedValue = "FB1"
                        drpIncoterm.Enabled = False
                    End If
                End If
                'Get all regional payment term options
                dlPayterm.DataSource = dbUtil.dbGetDataTable("MY", _
                    " select distinct CREDIT_TERM from SAP_DIMCOMPANY where ORG_ID='" + Session("org_id") + "' and CREDIT_TERM is not null " + _
                    " and CREDIT_TERM <> '' order by CREDIT_TERM")
                ' Get current customer's payment term 
                If String.IsNullOrEmpty(EQpaymentTerm) Then
                    '\ Ming Get current customer's payment term for MexicoT2Customer 2013-08-26
                    Dim CurrentCompanyID As String = Session("company_id").ToString, ParentCompany As String = String.Empty
                    If Util.IsMexicoT2Customer(CurrentCompanyID, ParentCompany) Then
                        CurrentCompanyID = ParentCompany
                    End If
                    '/ end
                    Dim objcustCTerm As Object = dbUtil.dbExecuteScalar("MY", _
                   String.Format("select top 1 CREDIT_TERM from SAP_DIMCOMPANY where company_id='{0}' and org_id='{1}'", _
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
            If Session("company_id").ToString.Equals("ULTR00001", StringComparison.CurrentCultureIgnoreCase) OrElse _
             MailUtil.IsInRole("Aonline.USA") OrElse Session("user_id").ToString.Equals("jessamine.ku@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) Then
                Me.shiptoaddress.Editable = True
            Else
                Me.shiptoaddress.Editable = False
            End If
            'If Session("user_id") = "ming.zhao@advantech.com.cn" Then
            '    tdbilltoascx.Visible = True
            'End If
 
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
        Dim reqDate As String = Now
        If Not Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            reqDate = DateAdd(DateInterval.Day, 1, localtime).Date.ToString("yyyy/MM/dd")
            If mycart.isBtoOrder(CartId) Then
                reqDate = MyCartOrderBizDAL.getBTOParentDueDate(reqDate)
            Else
                reqDate = MyCartOrderBizDAL.getCompNextWorkDate(reqDate, Session("org_id"))
            End If
        End If
        If Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            If mycart.isBtoOrder(CartId) Then
                If mycart.isSBCBtoOrder(CartId) Then
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDate(localtime, Session("org_id"), 1) ' SBC: +1
                Else
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDate(localtime, Session("org_id"), Glob.getBTOWorkingDate()) ' Normal: +5
                End If
            Else
                If localtime.Hour >= 13 Then
                    reqDate = MyCartOrderBizDAL.getCompNextWorkDate(localtime, Session("org_id"), 1) ' not BTOS & > 13:00: +1
                Else
                    reqDate = localtime.Date.ToString("yyyy/MM/dd") ' not BTOS & < 13:00: +0
                End If
            End If
        End If
        
        Me.txtreqdate.Text = reqDate
        
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
        Dim tmpNextWeekShipDate As Date = CDate(Me.txtreqdate.Text)
        If MyCartOrderBizDAL.GetNextWeeklyShippingDate(CDate(Me.txtreqdate.Text), tmpNextWeekShipDate) Then Me.txtreqdate.Text = tmpNextWeekShipDate.ToString("yyyy/MM/dd")

        
        ''Frank 2012/11/23:If Order was created by uploading excel file,then getting max require date of cart detail and to be req_date
        'Dim _upDA As New MyCartDSTableAdapters.UPLOAD_ORDER_PARATableAdapter
        'Dim _UploadFromExcelCount As Integer = _upDA.GetCountByCartID(Me.CartId)
        'If _UploadFromExcelCount > 0 Then
        '    Dim _sql As String = "Select Max(req_date) as Max_Req_Date From CART_DETAIL Where Cart_Id='" & Me.CartId & "'"
        '    Dim _dtMaxReqDate As DataTable = dbUtil.dbGetDataTable("MY", _sql)
        '    If _dtMaxReqDate IsNot Nothing AndAlso _dtMaxReqDate.Rows.Count > 0 Then Me.txtreqdate.Text = Format(_dtMaxReqDate.Rows(0).Item("Max_Req_Date"), "yyyy/MM/dd")
        'End If
        If Me.tbExempt.Visible = True Then
            Me.cbxIsTaxExempt.Checked = IIf(SAPDAL.SAPDAL.isTaxExempt(Session("Company_id")), 1, 0)
        End If
        
        'Me.txtShipTo.Text = Session("Company_id")
        Dim quoteId As String = ""
        If mycart.isQuote2Order(CartId, quoteId) Then
            'orderaddressesforus.Visible = True
            Dim WS As New quote.quoteExit : WS.Timeout = -1
            Dim QuoteMaster As EQDS.QuotationMasterDataTable = Nothing, QuoteDetail As EQDS.QuotationDetailDataTable = Nothing, QuotePartner As EQDS.EQPARTNERDataTable = Nothing, QuoteNotes As EQDS.QuotationNoteDataTable = Nothing
            Dim ReturnValue As Boolean = WS.getQuotationMasterByIdV4(quoteId, QuoteMaster, QuoteDetail, QuotePartner, QuoteNotes)
            If ReturnValue Then
                If QuotePartner IsNot Nothing AndAlso QuotePartner.Rows.Count > 0 Then
                    For Each partner As EQDS.EQPARTNERRow In QuotePartner.Rows
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
                                _address.Name = .NAME
                                _address.Tel = .TEL : _address.Attention = .ATTENTION
                                _address.City = .CITY : _address.State = .STATE
                                _address.Street = .STREET : _address.Zipcode = .ZIPCODE
                                _address.Country = .COUNTRY : _address.Street2 = .STREET2
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
                    With QuoteMaster(0)
                        If Not String.IsNullOrEmpty(.PO_NO) Then
                            txtPONo.Text = .PO_NO
                        End If
                        If Not String.IsNullOrEmpty(.shipTerm) AndAlso .shipTerm.Equals("EX Works", StringComparison.OrdinalIgnoreCase) Then
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
                            EQpaymentTerm = .paymentTerm
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
                            txtSalesDistrict.Text = .DISTRICT
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
                If QuoteNotes IsNot Nothing AndAlso QuoteNotes.Rows.Count > 0 Then
                    For Each dr As EQDS.QuotationNoteRow In QuoteNotes.Rows
                        If dr.notetype.Trim.Equals("SalesNote", StringComparison.OrdinalIgnoreCase) Then
                            txtSalesNote.Text = dr.notetext
                        End If
                        If dr.notetype.Trim.Equals("OrderNote", StringComparison.OrdinalIgnoreCase) Then
                            txtOrderNote.Text = dr.notetext
                        End If
                    Next
                End If
            End If
        End If
        'Nada 20131209 load SHTC products to Order Note for TW 
        If Session("org_id").ToString.ToUpper.StartsWith("TW") AndAlso Not txtOrderNote.Text.ToUpper.Contains("(SHTC)") Then
            txtOrderNote.Text &= MYSAPBIZ.getOrderNoteBySHTCProduct()
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
        If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) AndAlso Util.IsInternalUser2 Then
            Me.tbExempt.Visible = True
        End If
        'If mycart.isBtoOrder(CartId) Then
        '    Me.rbtnIsPartial.Enabled = False
        'Else
        '    If MYSAPBIZ.isCustomerCompleteDeliv(Session("Company_id"), Session("Org_id")) Then
        '        Me.rbtnIsPartial.SelectedValue = "0"
        '    End If
        'End If
    End Sub
   
        
    Sub initShipConDrp()
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct VSBED AS SHIPCONDITION,'' as SHIPCONTXT from SAP_SHIPCONDITION_BY_PLANT where WERKS like '" & Session("org") & "%'"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct VSBED AS SHIPCONDITION,'' as SHIPCONTXT from SAP_SHIPCONDITION_BY_PLANT where WERKS like '" & Left(Session("org_id"), 2) & "%'"))
        If dt.Rows.Count > 0 Then
            For I As Integer = 0 To dt.Rows.Count - 1
                dt.Rows(I).Item("SHIPCONTXT") = Glob.shipCode2Txt(dt.Rows(I).Item("SHIPCONDITION"))
            Next
        End If
        Me.drpShipCondition.DataSource = dt : Me.drpShipCondition.DataTextField = "SHIPCONTXT" : Me.drpShipCondition.DataValueField = "SHIPCONDITION" : Me.drpShipCondition.DataBind()
    End Sub
    Sub initIncoDrp()
        Dim dt As DataTable = myCompany.GetDTbySelectStr(String.Format("select distinct isnull(INCO1,'') as INCO1 from {0}", myCompany.tb))
        Me.drpIncoterm.DataSource = dt : Me.drpIncoterm.DataTextField = "INCO1" : Me.drpIncoterm.DataValueField = "INCO1" : Me.drpIncoterm.DataBind()
    End Sub
  
    Sub DBfromCart2Order(ByVal Cart_ID As String)
        myOrderMaster.Delete(String.Format("order_id='{0}'", Cart_ID)) : myOrderDetail.Delete(String.Format("order_id='{0}'", Cart_ID))
        Dim ORDER_ID As String = Cart_ID, ORDER_NO As String = "", ORDER_TYPE As String = "ZOR2"
        If Left(Session("org_id"), 2) = "CN" Then
            ORDER_TYPE = "ZOR"
        End If

        If MyCartOrderBizDAL.isODMCart(Cart_ID) Then
            ORDER_TYPE = "ZOR6"
        End If
        Dim PO_NO As String = Me.txtPONo.Text.Trim
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
        Dim ATTENTION As String = Me.txtAttention.Text.Trim, PARTIALFLAG As String = Me.rbtnIsPartial.SelectedValue
        Dim MREQDATE As Date = CDate(IIf(Me.txtreqdate.Text.Trim = "", Now.Date, Me.txtreqdate.Text.Trim))
        Dim MDUEDATE As Date = Now.Date, SHIPVIA As String = "", CURRENCY As String = Session("Company_currency")
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
        
        Dim DT As DataTable = mycart.GetDT(String.Format("cart_id='{0}'", Cart_ID), "Line_no")
        If DT.Rows.Count > 0 Then
            Dim dtEW As New DataTable
            With dtEW.Columns
                .Add("Line_No") : .Add("Part_No") : .Add("otype") : .Add("qty") : .Add("req_date") : .Add("due_date") : .Add("islinePartial")
                .Add("UNIT_PRICE", GetType(Decimal)) : .Add("delivery_plant") : .Add("DMF_Flag") : .Add("OptyID") : .Add("subTotal", GetType(Decimal))
            End With
            
            Dim count As Integer = 0, BTOChildDate As Date = Now.Date
            
            'Frank 2012/11/23:If Order was created by uploading excel file,
            'then getting require date of cart detail and to be order detail req_date
   
            
            For Each r As DataRow In DT.Rows
                Dim LINE_NO As Integer = r.Item("line_no"), PRODUCT_LINE As String = "", PART_NO As String = r.Item("part_no")
                Dim ORDER_LINE_TYPE As String = r.Item("otype"), QTY As Integer = r.Item("qty"), LIST_PRICE As Decimal = r.Item("list_price")
                Dim UNIT_PRICE As Decimal = r.Item("unit_price"), REQUIRED_DATE As Date = r.Item("req_date")
                
                Dim ltime As String = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
                If r.Item("otype") = 0 Then
                    If Me.rbtnIsPartial.SelectedValue = "0" Then
                        REQUIRED_DATE = MREQDATE
                    End If
                    Dim quoteId As String = ""
                    If mycart.isQuote2Order(CartId, quoteId) AndAlso Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                        Dim QuoteMaster As QuotationMaster = eQuotationUtil.CurrentDC.QuotationMasters.Where(Function(p) p.quoteId = quoteId).FirstOrDefault
                        If QuoteMaster IsNot Nothing AndAlso (QuoteMaster.quoteId.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase) OrElse _
                                                               (QuoteMaster.quoteNo IsNot Nothing AndAlso QuoteMaster.quoteNo.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase))) Then
                            REQUIRED_DATE = MREQDATE
                        End If
                    End If
                    'If _UploadFromExcelCount > 0 AndAlso Not IsDBNull(r.Item("req_date")) AndAlso Date.TryParse(r.Item("req_date"), Now) Then
                    '    REQUIRED_DATE = Date.Parse(r.Item("req_date"))
                    'End If

                Else
                    Dim temp As String = MyCartOrderBizDAL.getBTOChildDueDate(MREQDATE.ToString("yyyy/MM/dd"), Session("org_id"))
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
                Dim DUE_DATE As Date = r.Item("due_date"), ERP_SITE As String = "", ERP_LOCATION As String = "", AUTO_ORDER_FLAG As Char = ""
                Dim AUTO_ORDER_QTY As Integer = 0, SUPPLIER_DUE_DATE As Date = DUE_DATE, LINE_PARTIAL_FLAG As Integer = 0
                Dim RoHS_FLAG As String = r.Item("rohs"), EXWARRANTY_FLAG As String = r.Item("ew_flag"), CustMaterialNo As String = r.Item("custMaterial")
                Dim DeliveryPlant As String = r.Item("delivery_plant")
                If Session("company_id") = "SAID" Then
                    DeliveryPlant = Me.drpDelPlant.SelectedValue
                End If
                Dim NoATPFlag As String = r.Item("satisfyflag"), DMF_Flag As String = "", OptyID As String = r.Item("QUOTE_ID"), Cate As String = r.Item("category")
                Dim Description = r.Item("Description")
                SAPtools.getInventoryAndATPTable(PART_NO, DeliveryPlant, QTY, DUE_DATE, 0, Nothing, REQUIRED_DATE)
                If MDUEDATE < DUE_DATE Then MDUEDATE = DUE_DATE
                If QTY <= 0 Then QTY = 1
                myOrderDetail.Add(ORDER_ID, LINE_NO, PRODUCT_LINE, PART_NO, ORDER_LINE_TYPE, QTY, LIST_PRICE, UNIT_PRICE, REQUIRED_DATE, DUE_DATE, _
                                  ERP_SITE, ERP_LOCATION, AUTO_ORDER_FLAG, AUTO_ORDER_QTY, SUPPLIER_DUE_DATE, LINE_PARTIAL_FLAG, RoHS_FLAG, _
                                  EXWARRANTY_FLAG, CustMaterialNo, DeliveryPlant, NoATPFlag, DMF_Flag, OptyID, Cate, Description)
               
                If CInt(EXWARRANTY_FLAG) > 0 Then
                    count = count + 1
                    If ORDER_LINE_TYPE <> -1 Then
                        Dim EWR As DataRow = dtEW.NewRow
                        With EWR
                            .Item("line_no") = LINE_NO + count : .Item("part_no") = Glob.getEWItemByMonth(EXWARRANTY_FLAG)
                            .Item("otype") = ORDER_LINE_TYPE : .Item("qty") = QTY : .Item("req_date") = REQUIRED_DATE
                            .Item("due_date") = DUE_DATE : .Item("islinePartial") = LINE_PARTIAL_FLAG
                            'Nada revised uniform ew logic .....
                            .Item("unit_price") = Glob.getRateByEWItem(EWR.Item("part_no"), DeliveryPlant) * UNIT_PRICE
                            .Item("delivery_plant") = DeliveryPlant : .Item("DMF_Flag") = DMF_Flag : .Item("OptyID") = OptyID : .Item("subTotal") = .Item("unit_price") * .Item("qty")
                        End With
                        dtEW.Rows.Add(EWR)
                    End If
                End If
            Next
            If dtEW.Rows.Count > 0 Then
                If myOrderDetail.isBtoOrder(Cart_ID) Then
                    Dim Line_no As Integer = myOrderDetail.getMaxLineNo(Cart_ID) + 1
                    Dim part_no As String = dtEW.Rows(0).Item("part_no"), otype As Integer = dtEW.Rows(0).Item("otype")
                    Dim qty As Integer = dtEW.Rows(0).Item("qty"), req_date As DateTime = BTOChildDate, due_date As DateTime = MDUEDATE
                    Dim linePartialFlag As Integer = dtEW.Rows(0).Item("islinePartial")
                    Dim unit_Price As Decimal = mycart.getTotalPrice_EW(CartId), delivery_plant As String = dtEW.Rows(0).Item("delivery_plant")
                    Dim dmf_flag As String = dtEW.Rows(0).Item("DMF_Flag"), optyid As String = dtEW.Rows(0).Item("OptyID")
                    myOrderDetail.Add(ORDER_ID, Line_no, "", part_no, otype, qty, unit_Price, unit_Price, req_date, due_date, "", "", "", 0, due_date, _
                                      linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid, "", "")
                Else
                    For Each r As DataRow In dtEW.Rows
                        Dim line_no As Integer = r.Item("line_no"), part_no As String = r.Item("part_no"), otype As Integer = r.Item("otype")
                        Dim qty As Integer = r.Item("qty"), req_date As DateTime = r.Item("req_date"), due_date As DateTime = r.Item("due_date")
                        Dim linePartialFlag As Integer = r.Item("islinePartial"), unit_price As Decimal = r.Item("unit_price")
                        Dim delivery_plant As String = r.Item("delivery_plant"), dmf_flag As String = r.Item("DMF_Flag"), optyid As String = r.Item("OptyID")
                        myOrderDetail.reSetLineNoBeforeInsert(Cart_ID, line_no)
                        myOrderDetail.Add(ORDER_ID, line_no, "", part_no, otype, qty, unit_price, unit_price, req_date, due_date, "", "", "", 0, due_date, _
                                          linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid, "", "")
                    Next
                End If
            End If
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
        '20120711 TC: Auto append CVV code to Billing Instruction per Cathee's request
        'If Not String.IsNullOrEmpty(txtCCardVerifyValue.Text) And String.IsNullOrEmpty(Trim(txtBillingInstructionInfo.Text)) Then
        '    txtBillingInstructionInfo.Text += " CVV Code:" + txtCCardVerifyValue.Text
        'End If
        '20120717 Ming: Auto append CVV code to Sales Note 
        'If Not String.IsNullOrEmpty(VerifyNumber) AndAlso String.IsNullOrEmpty(Trim(txtSalesNote.Text)) Then
        '    SALES_NOTE += " CVV Code:" + VerifyNumber
        'End If
        '\ Ming :当Payment Term只有选择CODC时，才能存储card的相关资料,反正就不存储. 2013-09-12
        If String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) Then
            CreditCardNumber = txtCreditCardNumber.Text.Replace("'", "''")
            VerifyNumber = txtCCardVerifyValue.Text.Replace("'", "''")
            credit_card_holder = txtCCardHolder.Text.Replace("'", "''")
            CardType = dlCCardType.SelectedValue
            CreditCardExpireDate = DateSerial(Integer.Parse(dlCCardExpYear.SelectedValue), Integer.Parse(dlCCardExpMonth.SelectedValue), 1)
        End If
        '/ end
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
        myOrderMaster.Add(ORDER_ID, ORDER_NO, ORDER_TYPE, PO_NO, PO_DATE, SOLDTO_ID, SHIPTO_ID, CURRENCY, MREQDATE, txtBillTo.Text, "", ORDER_DATE, "", ATTENTION, PARTIALFLAG, _
                          "", "", 0, 0, "", "", MDUEDATE, "", SHIPVIA, ORDER_NOTE, "", 0, 0, LAST_UPDATED, CREATED_DATE, Session("user_Id"), CUSTOMER_ATTENTION, "", INCOTERM, _
                          INCOTERM_TEXT, SALES_NOTE, OP_NOTE, SHIP_CONDITION, "", "", "", "", prj_Note, ISESE, ERE, EC, PAR1, CreditCardNumber, _
                          CreditCardExpireDate, VerifyNumber, dlPayterm.SelectedValue, CardType, credit_card_holder, txtBillingInstructionInfo.Text, ddlSE.SelectedValue, _
                          strDistChann, strDivision, strSalesGrp, strSalesOffice, txtSalesDistrict.Text, IS_EARLYSHIP, IIf(cbxIsTaxExempt.Checked, 1, 0))
        '20120816 TC: If early shipment is not allowed, update 0 value to order master. This value will be taken into considertation when creating a SO to SAP.
        'Dim aptOrderMaster As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        'If cbEarlyShipmentAllowed.Checked Or Session("org_id") <> "US01" Then
        '    aptOrderMaster.UpdateEarlyShipOption(1, ORDER_ID)
        'Else
        '    aptOrderMaster.UpdateEarlyShipOption(0, ORDER_ID)
        'End If
        myOrderDetail.Update(String.Format("ORDER_ID='{0}' and ORDER_LINE_TYPE=-1", ORDER_ID), String.Format("due_date='{0}',required_date='{1}'", MDUEDATE, MREQDATE))
   
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
    End Sub
    
    Function VerifyCreditCardInfo() As Boolean
        lbCCardMsg.Text = ""
        If trPayTerm.Visible AndAlso String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) AndAlso tbCreditCardInfo.Visible Then
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
        Return True
    End Function
    Function VerifyDist_Chann() As Boolean
        If Util.IsANAPowerUser() AndAlso dlDistChann.SelectedIndex > 0 Then
            Dim RDT As New DataTable : RDT.TableName = "RDTABLE"
            Dim ReturnValue As Boolean = MYSAPBIZ.VerifyDistChannelDivisionGroupOffice(Session("org_id"), Session("company_id"), txtShipTo.Text.Trim, dlDistChann.SelectedValue, _
                                                          ddlDivision.SelectedValue, SAPDAL.SAPDAL.SAPOrderType.ZOR, ddlSalesGroup.SelectedValue, _
                                                          ddlSalesOffice.SelectedValue, RDT)
            If ReturnValue = False AndAlso RDT.Rows.Count > 0 Then Util.JSAlert(Me.Page, RDT.Rows(0).Item("MESSAGE"))
            Return ReturnValue
        End If
        Return True
    End Function
    Protected Sub btnPIPreview_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write(rbtnIsPartial.SelectedItem.Text)
        'Exit Sub
        If VerifyCreditCardInfo() = False Then Exit Sub
        If VerifyDist_Chann() = False Then Exit Sub
        If Date.TryParse(txtreqdate.Text, Now) = False Then txtreqdate.Text = Now.ToString("yyyy/MM/dd")
        Dim tmpNextWeekShipDate As Date = CDate(Me.txtreqdate.Text)
        If MyCartOrderBizDAL.GetNextWeeklyShippingDate(CDate(Me.txtreqdate.Text), tmpNextWeekShipDate) Then Me.txtreqdate.Text = tmpNextWeekShipDate.ToString("yyyy/MM/dd")
        DBfromCart2Order(CartId) : addFreight() : InsertORDER_PARTNERS() : SyncCustomerID(CartId)
        If AuthUtil.IsUSAonlineSales(User.Identity.Name) And Me.rbtnIsPartial.SelectedValue = 0 Then
            Response.Redirect("~/Order/pi.aspx?NO=" & CartId)
        End If
        Response.Redirect("~/Order/DueDateReset.aspx?NO=" & CartId)
    End Sub
    Protected Sub SyncCustomerID(ByVal OrderID As String)
        Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        Dim OPdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(OrderID)
        For Each op As MyOrderDS.ORDER_PARTNERSRow In OPdt
            If Not String.IsNullOrEmpty(op.ERPID) AndAlso (String.Equals(op.TYPE, "SOLDTO", StringComparison.CurrentCultureIgnoreCase) OrElse _
                                                           String.Equals(op.TYPE, "S", StringComparison.CurrentCultureIgnoreCase) OrElse _
                                                           String.Equals(op.TYPE, "B", StringComparison.CurrentCultureIgnoreCase)) Then
                Dim companycount As Object = dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(COMPANY_ID) as c  FROM SAP_DIMCOMPANY  where COMPANY_ID ='{0}'", op.ERPID))
                If companycount IsNot Nothing AndAlso Integer.TryParse(companycount, 0) AndAlso Integer.Parse(companycount) = 0 Then
                    Server.Execute(String.Format("~/admin/SyncCustomer.aspx?companyid={0}&auto=1", op.ERPID))
                End If
            End If
        Next
    End Sub
    Protected Sub InsertORDER_PARTNERS()
        Dim OrderAddressS As OrderAddress() = {Me.soldtoaddress, Me.shiptoaddress, Me.billtoaddress,Me.endcustomer}
        Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        A.DeleteByOrderID(CartId)
        For Each OrderAddress As OrderAddress In OrderAddressS
            With OrderAddress
                If Not String.IsNullOrEmpty(.ERPID.Trim) Then
                    A.Insert(CartId, "", .ERPID.ToUpper.Trim, .Name.Trim, "", .Type.Trim, .Attention.Trim, .Tel.Trim, "", .Zipcode.Trim, .Country.Trim, .City.Trim, .Street.Trim, .State.Trim, "", .Street2.Trim, .taxJuri)
                End If
            End With
        Next
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
            A.Insert(CartId, "", ddlKeyInPerson.SelectedValue, "", "", "KIP", "", "", "", "", "", "", "", "", "", "", "")
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
        OrderUtilities.SetDirect2SAPSession()
        Me.btnPIPreview_Click(Me.btnPIPreview, Nothing)
    End Sub

    Protected Sub dlPayterm_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If String.Equals(dlPayterm.SelectedValue, "CODC", StringComparison.CurrentCultureIgnoreCase) Then
            tbCreditCardInfo.Visible = True
        Else
            tbCreditCardInfo.Visible = False
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
        If Not String.IsNullOrEmpty(txtPONo.Text) AndAlso Util.IsInternalUser2() Then
            Dim poDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
            "select vbeln from saprdp.vbak where BSTNK='" + Replace(txtPONo.Text, "'", "''") + "' and rownum<=20 and vkorg='" + Session("org_id") + _
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
        Dim txtFirstName As String = "", txtLastName As String = ""
        Dim txtBillToStreet As String = "", txtCity As String = "", txtState As String = "", txtBillToZip As String = ""
        Dim cardholder As String
        If Not String.IsNullOrEmpty(Me.txtCCardHolder.Text.Trim()) Then
            cardholder = Me.txtCCardHolder.Text
        Else
            cardholder = ccaddress.Attention
        End If
        If Not String.IsNullOrEmpty(cardholder) Then
            If cardholder.Contains(" ") Then
                txtFirstName = cardholder.Substring(0, cardholder.LastIndexOf(" "))
                txtLastName = cardholder.Substring(cardholder.LastIndexOf(" ") + 1)
            Else
                txtFirstName = cardholder
            End If
        End If
        txtCity = ccaddress.City
        txtState = ccaddress.State
        txtBillToStreet = ccaddress.Street : txtBillToZip = ccaddress.Zipcode
        Dim retBool As Boolean = False, newaddress As String = ""
        retBool = AuthCreditResult1.Auth(decTotalAmount, txtFirstName, txtLastName, txtBillToStreet, txtCity, txtState, txtBillToZip, txtPONo.Text, txtCreditCardNumber.Text, _
                               txtCCardVerifyValue.Text, New Date(dlCCardExpYear.SelectedValue, dlCCardExpMonth.SelectedValue, 1))
       
        If retBool Then
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
                txtBillingInstructionInfo.Text = "PN Reference: " + AuthCreditResult1.PNReference + vbCrLf
            Else
                txtBillingInstructionInfo.Text += vbCrLf + "PN Reference: " + AuthCreditResult1.PNReference
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
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td class="menu_title">
                Order Information
            </td>
        </tr>
        <tr id="orderaddressesforus" runat="server">
            <td colspan="2">
                <table>
                    <tr>
                        <td class="h5">
                            Sold to
                        </td>
                        <td class="h5">
                            Ship to
                        </td>
                        <td class="h5" id="tdbillto" runat="server" visible="false">
                            Bill to
                        </td>
                        <td class="h5" id="thendcustomer" runat="server" visible="false">
                            End Customer
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <uc1:OrderAddress ID="soldtoaddress" runat="server" IsCanPick="false" Type="SOLDTO" />
                        </td>
                        <td>
                            <uc1:OrderAddress ID="shiptoaddress" runat="server" Type="S" />
                        </td>
                        <td id="tdbilltoascx" runat="server" visible="false">
                            <uc1:OrderAddress ID="billtoaddress" runat="server" Type="B" />
                        </td>
                         <td id="tdendcustomer" runat="server" visible="false">
                            <uc1:OrderAddress ID="endcustomer" runat="server" Type="EM" />
                        </td>
                    </tr>
                </table>
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
            </td>
        </tr>
        <tr runat="server" id="trDelPlant" visible="false">
            <td class="h5" style="width: 25%">
                Delivery Plant:
            </td>
            <td>
                <asp:DropDownList ID="drpDelPlant" runat="server">
                    <asp:ListItem Value="SGH1">SGH1</asp:ListItem>
                    <asp:ListItem Value="TWH1">TWH1</asp:ListItem>
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td class="h5" style="width: 25%">
                PO Number:
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
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="h5">
                PO Date:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtPODate" ReadOnly="true"></asp:TextBox>
                <ajaxToolkit:CalendarExtender TargetControlID="txtPODate" runat="server" Format="yyyy/MM/dd"
                    ID="calDate" />
            </td>
        </tr>
        <tr id="TRAttention" runat="server" visible="false">
            <td class="h5">
                Attention:
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtAttention"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                
                <table style="width:80%">
                    <tr>
                    <td style="width:50%"><uc2:PartialDeliver ID="PartialDeliver1" runat="server" /> </td>
                        <td style="width:50%" runat="server" visible="false" id="tbExempt">
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
        <tr>
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
                            <span runat="server" id="SpanInct" class="h5">  Incoterm:</span>
                            <asp:DropDownList runat="server" ID="drpIncoterm">
                            </asp:DropDownList>
                        </td>
                        <td class="h5" style="padding-left: 19px; padding-right: 4px;">
                            Ship via:
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtIncoterm" onblur="return checkdate(this,'28')"></asp:TextBox><asp:Label ID="Label1" runat="server" Text="( Maximum 28 Characters )"></asp:Label>
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
            <td class="h5">
                Payment Term:<br />
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
                                            <th align="left">
                                                Card Type:
                                            </th>
                                            <td>
                                                <asp:DropDownList runat="server" ID="dlCCardType">
                                                    <asp:ListItem Value="AMEX" Text="American Express" />
                                                    <asp:ListItem Value="DISC" Text="Discover" />
                                                    <asp:ListItem Value="MC" Text="Master -/Euro Card" />
                                                    <asp:ListItem Value="VISA" Text="Visa Card" />
                                                </asp:DropDownList>
                                            </td>
                                            <td class="h5" width="125">
                                                Credit Card Number:
                                            </td>
                                            <td width="150" style="padding-left: 5px;">
                                                <asp:TextBox runat="server" ID="txtCreditCardNumber" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="left">
                                                Holder's Name:
                                            </th>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtCCardHolder" />
                                            </td>
                                            <td class="h5" width="100" align="left">
                                                Expire Date:
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
                                            <td class="h5" width="120" align="left">
                                                CVV Code:
                                            </td>
                                            <td colspan="3" width="200" style="padding-left: 5px;">
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
            <td class="h5">
                Sales Employee
            </td>
            <td>
                <table>
                    <tr>
                        <td>
                            <asp:DropDownList runat="server" ID="ddlSE" Width="150">
                            </asp:DropDownList>
                        </td>
                        <td runat="server" id="tdE2name" visible="false">
                            Sales Employee2
                        </td>
                        <td runat="server" id="tdE2" visible="false">
                            <asp:DropDownList runat="server" ID="ddlSE2" Width="150">
                            </asp:DropDownList>
                        </td>
                        <td runat="server" id="tdE3name" visible="false">
                            Sales Employe3
                        </td>
                        <td runat="server" id="tdE3" visible="false">
                            <asp:DropDownList runat="server" ID="ddlSE3" Width="150">
                            </asp:DropDownList>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr id="trKeyInPerson" runat="server" visible="false">
            <td class="h5">
                Key In Person
            </td>
            <td>
              <asp:DropDownList runat="server" ID="ddlKeyInPerson" Width="150">
               </asp:DropDownList>
            </td>
        </tr>
        <tr id="trDSGSO" runat="server" visible="false">
            <td class="h5">
            </td>
            <td>
                <asp:UpdatePanel runat="server" ID="upDistChannDiv" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table>
                            <tr>
                                <td class="h5">
                                    Distribution Channel:
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
                                            <td class="h5">
                                                Division:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlDivision" />
                                            </td>
                                            <td class="h5">
                                                Sales Group:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlSalesGroup" />
                                            </td>
                                            <td class="h5">
                                                Sales Office:
                                            </td>
                                            <td>
                                                <asp:DropDownList runat="server" ID="ddlSalesOffice" />
                                            </td>
                                            <td class="h5">
                                                District:
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
        <tr>
            <td class="h5">
                Order Note (External Note):<br />
                (Maximum 1000 Characters)
            </td>
            <td>
                <asp:TextBox TextMode="MultiLine" Width="300px" Height="80px" runat="server" ID="txtOrderNote"
                    onblur="return checkdate(this,'1000')"></asp:TextBox>
            </td>
        </tr>
        <tr id="trSN" runat="server">
            <td class="h5">
                Sales Note From Customer:<br />
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
            <td class="h5">
                EU OP Note:<br />
                (Maximum 100 Characters)
            </td>
            <td>
                <asp:TextBox TextMode="MultiLine" Width="300px" Height="80px" runat="server" ID="txtOPNote"
                    onblur="return checkdate(this,'100')"></asp:TextBox>
            </td>
        </tr>
        <tr runat="server" id="trBillInfo" visible="false">
            <td class="h5">
                Billing Instruction Info:
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
            <td class="h5">
                Freight Fee:
            </td>
            <td>
                <table>
                    <tr>
                        <td>
                            Freight(taxable):
                        </td>
                        <td>
                            <asp:TextBox ID="txtFtTax" runat="server"></asp:TextBox>
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft1" TargetControlID="txtFtTax"
                                FilterType="Numbers, Custom" ValidChars="." />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Free Freight Charge:
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
            <td width="30%">
            </td>
            <td align="center">
                <asp:Button runat="server" Text="Next" ID="btnPIPreview" OnClick="btnPIPreview_Click"
                    Width="150px" />
            </td>
            <td id="D2Std" align="center" runat="server" visible="false">
                <asp:Button ID="btnDirect2SAP" runat="server" Text=" >> Direct2SAP << " OnClick="btnDirect2SAP_Click"
                    Visible="false" />
            </td>
            <td width="30%">
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        function PickDate(Url, Element) {
            Url = Url + "?Element=" + Element.name
            window.open(Url, "pop", "height=265,width=263,top=300,left=400,scrollbars=no")
        }
        function checkdate(id, Maximum) {
            if (id.value.length > Maximum) {
                alert('More than ' + Maximum + ' characters')
                id.focus()
                return false
            }
            else {
                return true
            }
        }
    </script>
    <asp:UpdatePanel runat="server" ID="upCreditCardAuthInfo" UpdateMode="Conditional">
        <ContentTemplate>
            <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
                TargetControlID="PanelCreditAuthInfo" HorizontalSide="Center" VerticalSide="Middle"
                HorizontalOffset="0" VerticalOffset="0" />
            <asp:Panel runat="server" ID="PanelCreditAuthInfo" Visible="false" Width="340px"
                Height="125px" BackColor="LightGray" HorizontalAlign="Center">
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
                </table>
            </asp:Panel>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="lBtnAuthCcInfo" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server"> 
</asp:Content>
