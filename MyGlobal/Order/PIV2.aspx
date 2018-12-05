<%@ Page Title="MyAdvantech–Proforma Invoice Preview" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register Src="~/Includes/Order/OrderAddress.ascx" TagName="OrderAddress" TagPrefix="uc1" %>
<%@ Register Src="../Includes/Payment/PaymentInfo.ascx" TagName="PaymentInfo" TagPrefix="uc1" %>

<script runat="server">
    Dim myOrderMaster As New order_Master("b2b", "order_master")
    Dim myOrderDetail As New order_Detail("b2b", "order_detail")
    Dim myFailedOrder As New ORDER_PROC_STATUS("b2b", "ORDER_PROC_STATUS2")

    Public Function getMassage() As String
        Dim isSimulate As Boolean = False
        If Request("NO").ToString.Length > 15 Then
            isSimulate = True
        End If
        If Util.IsInternalUser2() Then
            Dim ordermasterA As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
            Dim ordermasterDT As MyOrderDS.ORDER_MASTERDataTable = ordermasterA.GetOrderMasterByOrderID(Request("NO"))
            If ordermasterDT.Rows.Count > 0 Then
                Dim ordermasterDR As MyOrderDS.ORDER_MASTERRow = ordermasterDT.Rows(0)
                If Not IsDBNull(ordermasterDR.ORDER_STATUS) AndAlso ordermasterDR.ORDER_STATUS.ToString.Equals("FINISH", StringComparison.OrdinalIgnoreCase) Then
                    Return ""
                End If
            End If
            Dim mm As String = ""
            Dim Message_DT As DataTable = myFailedOrder.GetDT(String.Format("order_no='{0}'", Request("NO")), "LINE_SEQ")
            If Message_DT.Rows.Count > 0 Then
                Dim j As Integer = 0
                While j <= Message_DT.Rows.Count - 1
                    If Message_DT.Rows(j).Item("NUMBER") <> "311" And Message_DT.Rows(j).Item("NUMBER") <> "233" Then
                        mm &= "<font color=""red"">&nbsp;&nbsp;+&nbsp;" & Message_DT.Rows(j).Item("MESSAGE") & "</font>"
                        mm &= "<br/>"
                    End If
                    j = j + 1
                End While
                If isSimulate Then
                    myFailedOrder.Delete(String.Format("order_no='{0}'", Request("NO")))
                End If
            End If
            Return mm.Replace(Request("NO"), "SO")
        End If
        Return ""
    End Function
    Public Function SetOrder_Master_Extension(ByVal OrderNo As String) As Integer
        Dim PI2CUSTOMER_FLAG As Integer = 1
        If CBPI2Customer.Checked = True Then
            PI2CUSTOMER_FLAG = 0
        End If
        Dim _OrderNoScheme As Integer = 0
        'Dim myorder_Master_Extension As New order_Master_Extension("b2b", "order_Master_Extension")
        'myorder_Master_Extension.Add(OrderNo, PI2CUSTOMER_FLAG)
        Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = OrderNo).FirstOrDefault()
        If MasterExtension IsNot Nothing Then
            '_OrderNoScheme = MasterExtension.OrderNoScheme
            MasterExtension.PI2CUSTOMER_FLAG = PI2CUSTOMER_FLAG
        End If
        'MyOrderX.LogOrderMasterExtension(OrderNo, PI2CUSTOMER_FLAG, _OrderNoScheme, MasterExtension.OrderTaxRate)
        MyUtil.Current.MyAContext.SubmitChanges()

        Return 1
    End Function
    '<System.Web.Services.WebMethod()> _
    Public Function PlaceOrder(ByVal OrderNo As String) As String
        Dim myOrderMaster As New order_Master("b2b", "order_master"), myOrderDetail As New order_Detail("b2b", "order_detail")
        Dim myFt As New Freight("b2b", "Freight"), ret As Boolean = False, ErrMsg As String = "", old_id As String = OrderNo, order_no As String = old_id
        Dim DT As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", OrderNo), "")


        If DT.Rows.Count > 0 AndAlso DT.Rows(0).Item("ORDER_STATUS") = "" Then
            order_no = SAPDOC.getOrderNumberOracle(old_id)

            'Alex 2018/01/09 Move auth credit card logic before update orderNo(and before createSO V6)
            'Alex 2018/04/26 Move to just before SOCreateV6
            Dim paymentRet As Boolean = True
            If AuthUtil.IsBBUS And DT.Rows(0).Item("PAYTERM") = "CODC" And Not String.IsNullOrEmpty(order_no) Then
                paymentRet = BBCreditCard.AuthPaymentAmount(old_id, order_no, Session("COMPANY_ID"), ErrMsg)
                If Not paymentRet Then
                    Glob.ShowInfo(ErrMsg)
                    Return "AuthFail"
                End If
            End If

            'Alex 2018/01/09 Move auth credit card logic before update orderNo(and before createSO V6)
            'Dim paymentRet As Boolean = True
            'If AuthUtil.IsBBUS And DT.Rows(0).Item("PAYTERM") = "CODC" And Not String.IsNullOrEmpty(order_no) Then
            '    If Me.ckbUserNewBillAddress.Checked Then
            '        Dim txtFirstName As String = "", txtLastName As String = ""
            '        Dim cardholder As String
            '        If Not String.IsNullOrEmpty(Me.txtCCardHolder.Text.Trim()) Then
            '            cardholder = Me.txtCCardHolder.Text
            '        Else
            '            cardholder = txtNewBillAttention.Text
            '        End If
            '        ' If customer choice new bill to address for creditCard authorization, then update type b_cc partner
            '        dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PARTNERS  set NAME = '{1}', ATTENTION = '{2}' , TEL = '{3}', ZIPCODE = '{4}', COUNTRY = '{5}', CITY = '{6}', STREET = '{7}',STREET2 = '{8}', STATE = '{9}' where type = 'B_CC' and ORDER_ID = '{0}'",
            '                                            old_id, cardholder, txtNewBillAttention.Text, txtNewBillTel.Text, txtNewBillZipCode.Text, txtNewBillCountry.Text, txtNewBillCity.Text, txtNewBillStreet.Text, txtNewBillStreet2.Text, txtNewBillState.Text))
            '    Else
            '        ' If customer not choice new bill to address for creditCard authorization, then update type b_cc partner tp empty
            '        dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PARTNERS  set NAME = '{1}', ATTENTION = '{2}' , TEL = '{3}', ZIPCODE = '{4}', COUNTRY = '{5}', CITY = '{6}', STREET = '{7}',STREET2 = '{8}', STATE = '{9}' where type = 'B_CC' and ORDER_ID = '{0}'",
            '                                        old_id, "", "", "", "", "", "", "", "", ""))
            '    End If
            '    paymentRet = AuthCreditCard(order_no, old_id, DT, ErrMsg)

            '    If Not paymentRet Then
            '        Glob.ShowInfo(ErrMsg)
            '        Return "AuthFail"
            '    End If
            'End If

            If order_no <> "" And order_no <> old_id Then
                myOrderMaster.Update(String.Format("order_id='{0}'", old_id), String.Format("order_id='{0}',ORDER_STATUS='TEMP',order_No='{0}'", order_no))
                myOrderDetail.Update(String.Format("order_id='{0}'", old_id), String.Format("order_id='{0}'", order_no))
                myOrderDetail.Update(String.Format("order_id='{0}'", old_id), String.Format("order_id='{0}'", order_no))
                myFt.Update(String.Format("order_id='{0}'", old_id), String.Format("order_id='{0}'", order_no))
                'MyOrderX.UpdateOrderMasterExtensionOrderIdByOldId(old_id, order_no)
                dbUtil.dbExecuteNoQuery("MY", String.Format("update order_Master_ExtensionV2 set ORDER_ID = '{0}' where ORDER_ID = '{1}'", order_no, old_id))
                dbUtil.dbExecuteNoQuery("MY", String.Format("update asg_btosinstruction set ID = '{0}' where ID = '{1}'", order_no, old_id))
                Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
                A.UpdateOrderID(order_no, old_id)
                SetOrder_Master_Extension(order_no)
                dbUtil.dbExecuteNoQuery("MY", String.Format("update OrderForwarderService set OrderID = '{0}' where OrderID = '{1}'", order_no, old_id))
                Dim _Cart2OrderMaping As Cart2OrderMaping = MyOrderX.GetCart2OrderMaping(old_id)
                If _Cart2OrderMaping IsNot Nothing Then
                    _Cart2OrderMaping.OrderNo = order_no
                    MyOrderX.LogCart2OrderMaping(_Cart2OrderMaping)
                End If
                '20121012 Ming CreateSAPQuote
                Dim Quote_Id As String = String.Empty, QuoteNo = String.Empty
                Dim CQuoteret As Boolean = False
                Try
                    If AuthUtil.IsUSAonlineSales(Session("user_id")) AndAlso myOrderDetail.isQuoteOrder(order_no, Quote_Id, QuoteNo) Then
                        If Not String.IsNullOrEmpty(QuoteNo) Then
                            Dim SAPQlogA As New MyOrderDSTableAdapters.CreateSAPQuoteLogTableAdapter
                            SAPQlogA.Insert(order_no, QuoteNo, Now)
                            If QuoteNo.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase) OrElse QuoteNo.StartsWith("AMXQ", StringComparison.CurrentCultureIgnoreCase) Then
                                If MYSAPDAL.checkSAPQuote(QuoteNo) = False Then
                                    CQuoteret = SAPDOC.SOCreateV6(order_no, ErrMsg, False, QuoteNo, True)
                                End If
                            End If
                        End If
                    End If
                Catch ex As Exception
                    Util.SendEmail("myadvanteh@advantech.com", "myadvanteh@advantech.com", "Create SAP Quote Failed.", ex.ToString, True, "", "")
                End Try
                Dim dtMsg As New DataTable
                If CQuoteret Then
                    For i As Integer = 0 To 3
                        If MYSAPDAL.checkSAPQuote(QuoteNo) Then
                            Exit For
                        End If
                        If i = 3 Then
                            QuoteNo = ""
                            Util.SendEmail("myadvanteh@advantech.com", "myadvanteh@advantech.com", "Find SAP Quote Failed.", "", True, "", "")
                            Exit For
                        End If
                        Threading.Thread.Sleep(1000)
                    Next
                Else
                    If MYSAPDAL.checkSAPQuote(QuoteNo) = False Then
                        QuoteNo = ""
                    End If
                End If


                'Ryan 20170705 If is ACN loose order and contains D/P/T items, create SAP quotation instead
                If Session("org_id").ToString.StartsWith("CN") AndAlso MyServices.IsACNOrderNeedsApproval(order_no, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString), Session("org_id")) Then
                    ret = SAPDOC.SOCreateV6(order_no, ErrMsg, False, order_no, True)
                Else
                    ret = SAPDOC.SOCreateV6(order_no, ErrMsg, False, QuoteNo)
                End If


                If ret Then
                    SAPDOC.ProcessAfterOrderSuccess(order_no, ErrMsg)
                    ' 201208022 Ming: delete old data for cart and create new cartid and orderid
                    AuthUtil.SetOrderid(old_id)

                    '20130729 Rudy: Create PO when company id is AJPADV, or AALP003, or ASPA001
                    'Dim POcompanys As String() = {"AJPADV", "AALP003", "ASPA001", "EDEA002", "EWGD002"}
                    'If UCase(Session("COMPANY_ID")) = "AJPADV" Or UCase(Session("COMPANY_ID")) = "AALP003" Or UCase(Session("COMPANY_ID")) = "ASPA001" Then
                    '  If POcompanys.Contains(UCase(Session("COMPANY_ID"))) Then
                    If MYSAPDAL.IsCreatePO(UCase(Session("COMPANY_ID"))) AndAlso BtosOrderCheck(order_no) = 1 Then
                        Dim retMsg As String = "", pono As String = "", retCode As Boolean = False
                        MYSAPDAL.CreatePo(order_no, pono, retMsg, retCode)
                        'PO XML to SAP
                        ' MYSAPDAL.CreatePo_Sap(order_no, pono, retMsg, result)
                        'Send Mail 
                        'MYSAPDAL.PO_SendMail(order_no, pono, retMsg, result)
                    End If
                    'End If
                    'Ming20150922 create PO for Cermate
                    If Util.IsTesting() AndAlso (Session("org_id").ToString.Trim.StartsWith("TW", StringComparison.OrdinalIgnoreCase) OrElse Session("org_id").ToString.Trim.StartsWith("CN", StringComparison.OrdinalIgnoreCase)) Then
                        Dim retMsg As String = "", pono As String = "", retCode As Boolean = False
                        MYSAPDAL.CreatePoForCermate(order_no, pono, retMsg, retCode)
                    End If
                    ' 20120801 Ming: Update SO ShipTo Attention
                    Dim retTable As New DataTable : Dim IsSAPProductionServer As Boolean = True
                    If Util.IsTesting() Then
                        IsSAPProductionServer = False
                    End If
                    If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                        Dim OrderPartnerdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(order_no)
                        Dim FirstRow As MyOrderDS.ORDER_PARTNERSRow = OrderPartnerdt.Select("TYPE='S'").FirstOrDefault()
                        If FirstRow IsNot Nothing AndAlso Not String.IsNullOrEmpty(FirstRow.ERPID) AndAlso Not String.IsNullOrEmpty(order_no) Then
                            With FirstRow
                                MYSAPBIZ.UpdateSAPSOShipToAttentionAddress(order_no, .ERPID, .NAME, .ATTENTION, .STREET,
                                                                           .STREET2, .CITY, .STATE, .ZIPCODE, .COUNTRY, .TAXJURI, retTable, IsSAPProductionServer)
                            End With
                        End If
                        '20120816 Ming: Update SO Zero Price Items
                        Threading.Thread.Sleep(1000)
                        MYSAPBIZ.UpdateSOZeroPriceItems(order_no, retTable)
                        '20120816 TC: If Early ship is not allowed, update it on SAP SO
                        Dim aptOrderMaster As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
                        If aptOrderMaster.GetEarlyShipOption(order_no) = 0 Then
                            Dim dtReturn As DataTable = Nothing
                            Threading.Thread.Sleep(2000)
                            If Not MYSAPBIZ.UpdateSOSpecId(order_no, EnumSetting.EarlyShipmentSetting.Early_Shipment_Not_Allowed, dtReturn) Then
                                '20120816 TC: should log this failure and inform IT
                            End If
                        End If
                    End If
                    'end

                    '20170419 Alex/Ryan: Move release GP Function logic to ProcessAfterOrderSuccess
                    ''Ming add 20141210 改用呼叫MyAdvantechAPI插入转单记录
                    'Dim quoteId As String = "", Msg = "", _QuoteNo = ""
                    'If myOrderDetail.isQuoteOrder(order_no, quoteId, _QuoteNo) Then
                    '    Dim retbool = Advantech.Myadvantech.Business.QuoteBusinessLogic.LogQuote2Order(order_no, quoteId, Msg)
                    '    If Not retbool Then Util.InsertMyErrLog(Msg)
                    '    'End
                    '    'Dim ordermasterA As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
                    '    'Dim ordermasterDT As MyOrderDS.ORDER_MASTERDataTable = ordermasterA.GetOrderMasterByOrderID(order_no)
                    '    'If ordermasterDT.Rows.Count > 0 Then
                    '    '    Dim ordermasterDR As MyOrderDS.ORDER_MASTERRow = ordermasterDT.Rows(0)
                    '    '    With ordermasterDR
                    '    '        Dim quote_to_order_logDT As New quote.EQDS.QUOTE_TO_ORDER_LOGDataTable
                    '    '        Dim quote_to_order_logDR As quote.EQDS.QUOTE_TO_ORDER_LOGRow = quote_to_order_logDT.NewQUOTE_TO_ORDER_LOGRow()
                    '    '        quote_to_order_logDR.PO_NO = .PO_NO
                    '    '        quote_to_order_logDR.SO_NO = .ORDER_NO
                    '    '        quote_to_order_logDR.QUOTEID = quoteId
                    '    '        quote_to_order_logDR.ORDER_DATE = .CREATED_DATE
                    '    '        quote_to_order_logDR.ORDER_BY = .CREATED_BY
                    '    '        quote_to_order_logDT.Rows.Add(quote_to_order_logDR)
                    '    '        quote_to_order_logDT.AcceptChanges()
                    '    '        Dim WS As New quote.quoteExit : WS.Timeout = -1
                    '    '        If Util.IsTesting() Then
                    '    '            WS.Url = "http://eq.advantech.com:8300/Services/QuoteExit.asmx"
                    '    '        End If
                    '    '        WS.WriteQuoteToOrderLog(quote_to_order_logDT)
                    '    '    End With
                    '    'End If

                    '    Dim SAPDAL1 As New SAPDAL.SAPDAL()

                    '    '20160921 TC: Always release SO's GP block because all orders entered to SAP via MyAdvantech should have been approved in advance
                    '    '20161003 Frank: After discussion with TC, release the function to Intercon sales first.
                    '    'If Util.IsTesting Then
                    '    'AIAQ:Intercon IA's quote
                    '    'AIEQ:Intercon EC's quote
                    '    'AISQ:Intercon IService's quote
                    '    If _QuoteNo.StartsWith("AIAQ", StringComparison.InvariantCultureIgnoreCase) OrElse
                    '        _QuoteNo.StartsWith("AIEQ", StringComparison.InvariantCultureIgnoreCase) OrElse
                    '        _QuoteNo.StartsWith("AISQ", StringComparison.InvariantCultureIgnoreCase) Then
                    '        SAPDAL1.UnblockSOGP(order_no, Util.IsTesting)
                    '    ElseIf _QuoteNo.StartsWith("ACNQ", StringComparison.InvariantCultureIgnoreCase) Then
                    '        SAPDAL1.UnblockSOHeaderGP(order_no, Util.IsTesting)
                    '    ElseIf _QuoteNo.StartsWith("BBEQ", StringComparison.InvariantCultureIgnoreCase) Then
                    '        'Ryan 20180412 For B+B, unblock SO header GP and send SPR No to SAP
                    '        SAPDAL1.UnblockSOHeaderGP(order_no, Util.IsTesting)
                    '        SAPDAL1.UpdateSPRNo(order_no, quoteId, Util.IsTesting)
                    '    End If
                    '    'End If
                    'End If
                    'Ming add 20140826解决ATW SIebleQuote转单时Opp. ID未能带入SO
                    MYSAPDAL.checkOptyIDForATWSO(order_no)

                Else
                    If Not Util.IsTesting() Then
                        SAPDOC.ProcessAfterOrderFailed(order_no, ErrMsg)
                        'Ryan 20170413 Reset session after order failed
                        AuthUtil.SetOrderid(old_id)
                    End If

                    'For bb, if create SO failed, void preauth payment 
                    If AuthUtil.IsBBUS And DT.Rows.Count > 0 And DT.Rows(0).Item("PAYTERM") = "CODC" Then
                        BBCreditCard.VoidPayment(order_no, order_no)
                    End If

                    Glob.ShowInfo(ErrMsg)
                    'OrderUtilities.showDT(dtMsg)
                End If

            End If
        End If
        Return order_no
    End Function

    Function BtosOrderCheck(ByVal Order_No As String) As Integer
        Dim myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}' and line_no >= 100", Order_No), "line_No")
        If dtDetail.Rows.Count > 0 Then
            BtosOrderCheck = 1
        Else
            BtosOrderCheck = 0
        End If
    End Function

    Function SiteDefinition_Get(ByVal szSite_Parameter, ByRef szPara_Value) As String

        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
        "select Site_Parameter,Para_Value from SITE_DEFINITION where Site_Parameter=" & "'" & szSite_Parameter & "'")
        If dt Is Nothing Then
            Return ""
            Exit Function
        End If
        If dt.Rows.Count = 0 Then
            Return ""
            Exit Function
        End If
        szPara_Value = dt.Rows(0).Item("Para_Value").ToString()
        Return 1

    End Function

    Public Function IsNumericItem(ByVal part_no As String) As Boolean

        Dim pChar() As Char = part_no.ToCharArray()

        For i As Integer = 0 To pChar.Length - 1
            If Not IsNumeric(pChar(i)) Then
                Return False
                Exit Function
            End If
        Next

        Return True
    End Function

    Function FormatDate(ByVal xDate, ByVal xFormat) As String
        Dim xYear As String = "0000"
        Dim xMonth As String = "00"
        Dim xDay As String = "00"

        If IsDate(xDate) = True Then
            xYear = Year(xDate).ToString
            xMonth = Month(xDate).ToString
            xDay = Day(xDate).ToString
        Else
            Dim ArrDate() As String = xDate.Split("/")

            If ArrDate(0).Length = 4 Then
                xYear = ArrDate(0)
                xMonth = ArrDate(1)
                xDay = ArrDate(2)
            ElseIf UBound(ArrDate) >= 2 Then
                xYear = ArrDate(2)
                xMonth = ArrDate(0)
                xDay = ArrDate(1)
            ElseIf UBound(ArrDate) = 0 Then
                If ArrDate(0).Length = 8 Then
                    xYear = Left(ArrDate(0), 4)
                    xMonth = Mid(ArrDate(0), 5, 2)
                    xDay = Right(ArrDate(0), 2)
                End If
            End If
        End If

        If xMonth.Length = 1 Then
            xMonth = "0" & xMonth
        End If
        If xDay.Length = 1 Then
            xDay = "0" & xDay
        End If
        Select Case LCase(xFormat)
            Case "yyyy/mm/dd"
                FormatDate = xYear & "/" & xMonth & "/" & xDay
            Case "mm/dd/yy"
                FormatDate = xMonth & "/" & xDay & "/" & xYear
            Case Else
                FormatDate = xYear & "/" & xMonth & "/" & xDay
        End Select
        'If xYear = "0000" And xMonth = "00" And xDay = "00" Then               ' Modified by Siaowei.Jhai    2006/12/27
        '    FormatDate = ""
        'Else
        '    FormatDate = xYear & "/" & xMonth & "/" & xDay
        'End If
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            'If Util.IsTestingQuote2Order() Then
            '    Response.Redirect(String.Format("PIV2.aspx{0}", Request.Url.Query))
            'End If
            Dim _ISAonlineUSA As Boolean = False
            If MailUtil.IsInRole("Aonline.USA") OrElse MailUtil.IsInRole("Aonline.USA.IAG") Then _ISAonlineUSA = True
            '20150330 TC: For AJP sales tick the option of PI to internal only by default
            If _ISAonlineUSA OrElse (Session("org_id") = "JP01" AndAlso Util.IsInternalUser2()) Then
                CBPI2Customer.Checked = True : trTermConditionContent.Visible = False
            Else
                CBPI2Customer.Checked = False
            End If

            If Util.IsInternalUser2() AndAlso (AuthUtil.IsACN OrElse AuthUtil.IsInterConUserV2 OrElse AuthUtil.IsAJP OrElse AuthUtil.IsAKR) Then
                CBPI2Customer.Checked = True
            End If

            'Ryan 20180706 Hide terms and conditions field for ASG
            If AuthUtil.IsASG Then
                trTermConditionContent.Visible = False
            End If

            'Frank 2014/02/11: To hide the T&C area when placing order for TW customer
            If Session("org_id").ToString.Trim.StartsWith("TW", StringComparison.OrdinalIgnoreCase) AndAlso AuthUtil.IsTWAonlineSales(User.Identity.Name) Then
                trTermConditionContent.Visible = False
            End If
            If Util.IsInternalUser2() Then
                Me.trPI2In.Visible = True : TandC_Button.SelectedIndex = 0
            End If
            'Ming 2014/04/22  hide "PI to internal only" for ATW
            ' If Session("org_id").ToString.Trim.StartsWith("TW", StringComparison.OrdinalIgnoreCase) Then
            If SAPDOC.IsATWCustomer() Then
                ' trPI2In.Visible = False
                CBPI2Customer.Checked = True
            End If
            btnOrder.Enabled = IIf(SAPDOC.ISRBU(Session("company_id")) = True, False, True)
            Dim DT As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
            'Frank 2017/11/29
            If AuthUtil.IsBBUS Then
                Me.PICheckboxLabel.InnerText = "Send Order confirmation (Proforma Invoice) to Internal User Only"
                If Request("BBorder") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("BBorder")) Then
                    hlBBeStoreOrderList.Visible = True
                End If

            End If
            If DT.Rows.Count > 0 Then
                If DT.Rows(0).Item("ORDER_STATUS") = "" Or myOrderDetail.IsExists(String.Format("order_id='{0}'", Request("NO"))) = 1 Then
                    Me.btnOrder.Visible = True : Me.TCtb.Visible = True

                End If
                If _ISAonlineUSA OrElse AuthUtil.IsACN OrElse Util.IsTesting() Then
                    SAPDOC.SOCreateV6(Request("NO"), "", True)
                End If

                'Frank 20150909 Checking MOQ for AEU's order
                If Session("org_id").ToString.Trim.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
                    Dim errmsg As String = String.Empty
                    'ICC 2015/9/21 Modify minimun order qty sql. Add org ID parameter.
                    If Advantech.Myadvantech.Business.OrderBusinessLogic.IsAEUOrderItemBelowMOQ(Request("NO"), Session("org_id").ToString.Trim, errmsg) Then
                        Me.lbThanks.Text = "This order cannot be synced to SAP due to following reason:<br/>" & errmsg
                        Me.lbThanks.ForeColor = Drawing.Color.Red
                        btnOrder.Enabled = False
                    End If
                End If

                'Alex: 20180109 選CODC時顯示Credit card fill form
                If AuthUtil.IsBBUS AndAlso DT.Rows(0).Item("PAYTERM") = "CODC" Then
                    BBCreditCard.Visible = True
                    'For i As Integer = Now.Year To Now.Year + 15
                    '    dlCCardExpYear.Items.Add(New ListItem(i.ToString(), i.ToString()))
                    'Next
                End If

                If DT.Rows(0).Item("ORDER_STATUS") = "TEMP" Then
                    If Not Util.IsInternalUser2() Then
                        Me.lbThanks.Text = "Thanks for Order: " & Request("NO") & "."
                        Me.lbThanks.ForeColor = Drawing.Color.Green
                        Me.lbThanks.Font.Bold = True
                    Else
                        ' Me.lbThanks.Text = "Order: " & Request("NO") & " NOT SUCCESS"
                        Me.lbThanks.Text = "MyAdvantech failed to sync this order to SAP due to following reason:"
                        Me.lbThanks.ForeColor = Drawing.Color.Red
                        Me.lbThanks.Font.Bold = True
                    End If
                ElseIf DT.Rows(0).Item("ORDER_STATUS") = "FINISH" Then
                    Me.lbThanks.Text = "Thanks for Order: " & Request("NO") & "."
                    ' Ming add for Aonline.USA  Return to Quotation2.5
                    If _ISAonlineUSA Then
                        Me.lbThanks.Text += String.Format("<span style='margin-left:30px;'><a href='http://eq.advantech.com'>{0}</a></span>", "Return to Quotation2.5")
                    End If
                    ' end
                    Me.lbThanks.ForeColor = Drawing.Color.Green
                    Me.lbThanks.Font.Bold = True
                    Me.btnOrder.Visible = False
                    Me.TCtb.Visible = False
                    Me.BBCreditCard.Visible = False
                End If

                'GETORDERINFO(Request("NO"))
            End If

            GETORDERINFO(Request("NO"))
            If OrderUtilities.IsDirect2SAP() Then
                If Not Session("user_id") = "ming.zhao@advantech.com.cn" Then
                    Me.btnOrder_Click(Me.btnOrder, Nothing)
                End If
            End If
        End If
    End Sub

    Protected Sub GETORDERINFO(ByVal ORDERNO As String)
        Dim customerBlock As String = "", orderBlock As String = "", detailBlock As String = ""
        Dim url As String = ""
        url = "PI_AEU.aspx?NO=" & ORDERNO
        Dim MyDOC As New System.Xml.XmlDocument
        Global_Inc.HtmlToXML(url, MyDOC)
        'Global_Inc.getXmlBlockByID("div", "divCustInfo", MyDOC, customerBlock)
        'Global_Inc.getXmlBlockByID("div", "divOrderInfo", MyDOC, orderBlock)
        Global_Inc.getXmlBlockByID("div", "divDetailInfo", MyDOC, detailBlock)
        Me.lb_Cust.Text = Util.GetAscxStr(ORDERNO, 0)
        Me.lb_Order.Text = Util.GetAscxStr(ORDERNO, 1)
        Me.lb_Detail.Text = detailBlock
    End Sub

    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Threading.Thread.Sleep(2000 * 5)
        'Exit Sub
        If SAPDOC.ISRBU(Session("company_id")) Then
            Glob.ShowInfo("Order cannot be placed via Sales Offices.") : Exit Sub
        End If

        Dim ORDERNO As String = PlaceOrder(Request("NO"))

        If AuthUtil.IsBBUS And ORDERNO = "AuthFail" Then
            Exit Sub
        End If


        If OrderUtilities.IsDirect2SAP() Then
            Session.Contents.Remove("Direct2SAP")
        End If

        ''20160921 TC: Always release SO's GP block because all orders entered to SAP via MyAdvantech should have been approved in advance
        ''20161003 Frank: After discussion with TC, release the function to Intercon sales first.
        ''If Util.IsTesting Then
        'Dim quoteId As String = "", QuoteNo = ""
        'If myOrderDetail.isQuoteOrder(ORDERNO, quoteId, QuoteNo) Then

        '    If Not String.IsNullOrEmpty(ORDERNO) AndAlso (
        '        QuoteNo.StartsWith("AIAQ", StringComparison.InvariantCultureIgnoreCase) OrElse
        '        QuoteNo.StartsWith("AIEQ", StringComparison.InvariantCultureIgnoreCase) OrElse
        '        QuoteNo.StartsWith("AISQ", StringComparison.InvariantCultureIgnoreCase)) Then

        '        Dim SAPDAL1 As New SAPDAL.SAPDAL()
        '        SAPDAL1.UnblockSOGP(ORDERNO, Util.IsTesting)
        '    End If
        'End If
        ''End If

        Response.Redirect("~/order/PIV2.aspx?NO=" + ORDERNO)
    End Sub

    'Protected Function AuthCreditCard(ByVal order_no As String, ByVal old_id As String, DT As DataTable, ByRef errorMessage As String) As Boolean
    '    Dim paymentRet As Boolean = False
    '    Dim totalauthamount As Decimal = GetBBTotalAmount(old_id)



    '    Dim cardNum As String = txtCreditCardNumber.Text.Replace("'", "''")
    '    Dim cardHolder As String = txtCCardHolder.Text.Replace("'", "''")
    '    Dim cvvCode As String = txtCCardVerifyValue.Text.Replace("'", "''")
    '    Dim cardExpDate As String = New Date(dlCCardExpYear.SelectedValue, dlCCardExpMonth.SelectedValue, 1)
    '    Dim cardType As String = dlCCardType.SelectedValue

    '    Dim firstName As String = ""
    '    Dim lastName As String = ""
    '    If Not String.IsNullOrEmpty(cardHolder) Then
    '        If cardHolder.Contains(" ") Then
    '            firstName = cardHolder.Substring(0, cardHolder.LastIndexOf(" "))
    '            lastName = cardHolder.Substring(cardHolder.LastIndexOf(" ") + 1)
    '        Else
    '            firstName = cardHolder
    '        End If
    '    End If

    '    Dim orderPartner As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
    '    Dim orderPartnerDT As DataTable = orderPartner.GetPartnerByOrderIDAndType(old_id, "B_CC")

    '    If orderPartnerDT.Rows.Count > 0 Then
    '        Dim zipCode As String = orderPartnerDT.Rows(0).Item("ZIPCODE")
    '        Dim country As String = orderPartnerDT.Rows(0).Item("COUNTRY")
    '        Dim city As String = orderPartnerDT.Rows(0).Item("CITY")
    '        Dim street As String = orderPartnerDT.Rows(0).Item("STREET")
    '        Dim state As String = orderPartnerDT.Rows(0).Item("STATE")
    '        paymentRet = PaymentInfo.AuthPaymentAmount(order_no, totalauthamount, firstName, lastName, street, city, state, zipCode, "", cardNum, cvvCode, Convert.ToDateTime(cardExpDate), errorMessage)

    '        'Update tranid and authocode to orderpartner's rowid column
    '        If paymentRet Then
    '            Try
    '                'update tranid/authocode in orderpartner bcc type and store partial credit card information in order master 
    '                dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PARTNERS  set ROWID = '{0}' where type = 'B_CC' and ORDER_ID = '{1}'", PaymentInfo.TransactionId + "|" + PaymentInfo.AuthCode, old_id))
    '                cardNum = "************" + cardNum.Substring(cardNum.Length - 4, 4)
    '                dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_MASTER  set CREDIT_CARD = '{1}',CREDIT_CARD_EXPIRE_DATE = '{2}',CREDIT_CARD_HOLDER = '{3}', CREDIT_CARD_TYPE = '{4}', CREDIT_CARD_VERIFY_NUMBER = '{5}' where  ORDER_ID = '{0}'", old_id, cardNum, cardExpDate, cardHolder, cardType, "999"))

    '                'Add CC transaction reocrd to bb_credtiCard_order table too
    '                Dim ccOrder = New Advantech.Myadvantech.DataAccess.BB_CREDITCARD_ORDER
    '                ccOrder.ORDER_NO = order_no
    '                ccOrder.CARD_NO = cardNum
    '                ccOrder.CARD_TYPE = cardType
    '                ccOrder.TRANSACTION_TYPE = Advantech.Myadvantech.DataAccess.CCTransactionType.Authorization.ToString
    '                ccOrder.STATUS = "Success"
    '                ccOrder.TRANSACTION_ID = PaymentInfo.TransactionId
    '                ccOrder.AUTH_CODE = PaymentInfo.AuthCode
    '                ccOrder.TOTAL_AUTH_AMOUNT = totalauthamount
    '                ccOrder.CREATED_DATE = DateTime.Now
    '                ccOrder.CREATED_By = Session("user_id")
    '                If PaymentInfo.ResponseMessage IsNot Nothing Then
    '                    ccOrder.MESSAGE = PaymentInfo.ResponseMessage
    '                End If

    '                Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBCreditCardOrderRecord(ccOrder)

    '                'Alex: 20170425 create paymnet profile for custoemr in authorize.net CIM
    '                PaymentInfo.CreatePaymnetProfileForCustomer(PaymentInfo.TransactionId, DT.Rows(0).Item("SOLDTO_ID"), "US10")

    '            Catch ex As Exception
    '                paymentRet = False
    '                errorMessage = ex.Message
    '                '更新各TABLE失敗的話也要VOID
    '                PaymentInfo.VoidPayment(PaymentInfo.TransactionId, cardNum, cvvCode, Convert.ToDateTime(cardExpDate), errorMessage)
    '            End Try

    '        End If

    '    Else
    '        paymentRet = False
    '        errorMessage = "No Credit Card billto information. Authorize payment fail!"
    '    End If
    '    If Not paymentRet Then
    '        Try
    '            If Not String.IsNullOrEmpty(errorMessage) Then
    '                Dim A As New MyOrderDSTableAdapters.ORDER_PROC_STATUS2TableAdapter
    '                A.Insert(order_no, 0, 0, errorMessage, Now, 0, "CC_Error")
    '            End If
    '        Catch ex As Exception
    '        End Try
    '    End If

    '    Return paymentRet

    'End Function

    'Protected Function VoidCreditCard(ByVal order_no As String, DT As DataTable) As Boolean
    '    Dim paymentRet As Boolean = False

    '    Dim cardNum As String = txtCreditCardNumber.Text.Replace("'", "''")
    '    Dim cvvCode As String = txtCCardVerifyValue.Text.Replace("'", "''")
    '    Dim cardExpDate As String = New Date(dlCCardExpYear.SelectedValue, dlCCardExpMonth.SelectedValue, 1)
    '    Dim cardType As String = dlCCardType.SelectedValue


    '    Dim orderPartner As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
    '    Dim orderPartnerDT As DataTable = orderPartner.GetPartnerByOrderIDAndType(order_no, "B_CC")

    '    If orderPartnerDT.Rows.Count > 0 Then
    '        Dim transactionId As String = ""
    '        Dim Authinfo As Object = dbUtil.dbExecuteScalar("MY", "select ROWID from ORDER_PARTNERS where ORDER_ID = '" + order_no + "' and type = 'B_CC' ")
    '        If Authinfo IsNot Nothing AndAlso Not String.IsNullOrEmpty(Authinfo) Then
    '            If Authinfo.ToString.Contains("|") Then
    '                transactionId = Authinfo.ToString.Split("|")(0)
    '                paymentRet = PaymentInfo.VoidPayment(transactionId, cardNum, cvvCode, Convert.ToDateTime(cardExpDate), "")
    '                If paymentRet Then
    '                    Try
    '                        Dim ccOrder = New Advantech.Myadvantech.DataAccess.BB_CREDITCARD_ORDER
    '                        ccOrder.ORDER_NO = order_no
    '                        ccOrder.TRANSACTION_TYPE = Advantech.Myadvantech.DataAccess.CCTransactionType.Void.ToString
    '                        ccOrder.STATUS = "Success"
    '                        ccOrder.TRANSACTION_ID = PaymentInfo.TransactionId
    '                        ccOrder.AUTH_CODE = PaymentInfo.AuthCode
    '                        ccOrder.CREATED_DATE = DateTime.Now
    '                        ccOrder.CREATED_By = Session("user_id")
    '                        If PaymentInfo.ResponseMessage IsNot Nothing Then
    '                            ccOrder.MESSAGE = PaymentInfo.ResponseMessage
    '                        End If

    '                        Advantech.Myadvantech.Business.OrderBusinessLogic.CreateBBCreditCardOrderRecord(ccOrder)
    '                    Catch ex As Exception

    '                    End Try
    '                End If

    '            End If
    '        End If

    '    End If

    '    Return paymentRet

    'End Function

    Public Function GetBBTotalAmount(ByVal order_no As String) As Decimal
        Dim orderamount As Decimal = 0, taxamount As Decimal = 0, freightamount As Decimal = 0
        ' Order amount
        orderamount = myOrderDetail.getTotalAmount(order_no)

        ' Freight amount
        Dim myFt As New Freight("b2b", "Freight")
        Dim dtFreight As DataTable = myFt.GetDT(String.Format("order_id='{0}'", order_no), "")
        If dtFreight IsNot Nothing AndAlso dtFreight.Rows.Count > 0 AndAlso dtFreight.Rows(0) IsNot Nothing Then
            Dim freight As Decimal = dtFreight.Rows(0).Item("fvalue")
            freightamount += freight
        End If

        ' Tax amount
        Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = order_no).FirstOrDefault()
        If MasterExtension IsNot Nothing Then
            taxamount = Decimal.Round(orderamount * Decimal.Parse(MasterExtension.OrderTaxRate), 2, MidpointRounding.AwayFromZero)
        End If

        Return orderamount + freightamount + taxamount
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css" id="Sty" runat="server">
        .mytable table
        {
            width: 100%;
            border-collapse: collapse;
        }
        
        .mytable tr td
        {
            background: #ffffff;
            border: #cccccc 1px solid;
            padding: 2px;
            font-family: Arial;
            font-size: 12px;
        }
    </style>
    <table width="100%">
        <tr>
            <td align="left">
                <asp:Label runat="server" ID="lbThanks"></asp:Label>&nbsp;<asp:HyperLink ID="hlBBeStoreOrderList" runat="server" Visible="false" NavigateUrl="~/Order/BBOrder/OrderList.aspx" Text="Back to order list"></asp:HyperLink>
                <br />
                <%= getMassage()%>
            </td>
            <td align="right">
                <table>
                    <tr>
                        <td>
                            <a href="#" onclick="DoPrint()">Print</a>
                        </td>
                        <td>
                            |
                        </td>
                        <td>
                            <asp:HyperLink runat="server" ID="hlHome" Text="Home" NavigateUrl="~/home.aspx"></asp:HyperLink>
                        </td>
                        <td>
                            |
                        </td>
                        <td>
                            <asp:HyperLink runat="server" ID="hlNew" Text="New Order" NavigateUrl="~/order/Cart_list.aspx"></asp:HyperLink>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

<%--    <div id="fillCreditCard" class="fillCreditCard" runat="server" visible="false">
        <table align="left" cellpadding="0" class="fillCreditCardTb" cellspacing="0" runat="server" id="tbCreditCardInfo">
            <tr>
                <td style="background-color: #ededed; font-weight: bold; color:blue; padding: 3PX;" colspan="4">                
                    Please Fill Credit Card Information <span style="color:black">(Payment Term: CODC)</span>
                </td>
                <td style="background-color: #ededed;"></td>
                <td style="background-color: #ededed;"></td>
                <td style="background-color: #ededed;"></td>
                <td style="background-color: #ededed;"></td>
            </tr>
            <tr>
                <td  class="h5" align="left">Card Type:
                </td>
                <td>
                    <asp:DropDownList runat="server" ID="dlCCardType">
                        <asp:ListItem Value="AMEX" Text="American Express" />
                        <asp:ListItem Value="DISC" Text="Discover" />
                        <asp:ListItem Value="MC" Text="Master -/Euro Card" />
                        <asp:ListItem Value="VISA" Text="Visa Card" />
                    </asp:DropDownList>
                </td>
                <td class="h5" >Card Number:
                </td>
                <td style="padding-left: 5px;">
                    <asp:TextBox runat="server" ID="txtCreditCardNumber" />
                </td>
                <td class="h5" align="left">CVV Code:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCCardVerifyValue" Width="45"/>
                </td>
            </tr>
            <tr>
                <td class="h5" align="left">Holder's Name:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtCCardHolder" />
                </td>
                <td class="h5" align="left">Expire Date:
                </td>
                <td  style="padding-left: 5px;">
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
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td></td>
                <td>
                    <asp:CheckBox runat="server" ID="ckbUserNewBillAddress"  Text="Use New Bill Address"/>
                </td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            <tr class="CCnewBillTo">
                <td class="h5" align="left">Street1:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillStreet" />
                </td>
                <td class="h5" align="left">Street2:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillStreet2" />
                </td>  
                <td class="h5" align="left">Country:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillCountry" Width="45"/>
                </td>                            
            </tr>
            <tr class="CCnewBillTo">
                <td class="h5" align="left">City:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillCity" />
                </td>
                <td class="h5" align="left">State:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillState" />
                </td> 
                <td class="h5" align="left">ZipCode:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillZipCode" Width="45"/>
                </td>                               
            </tr>
            <tr class="CCnewBillTo">
                <td class="h5" align="left">Tel:
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillTel" />
                </td>   
                <td class="h5" align="left">Attention:
                </td> 
                <td>
                    <asp:TextBox runat="server" ID="txtNewBillAttention" />
                </td>  
                <td></td>
                <td></td>
            </tr>
        </table>
    </div>--%>
    <uc1:PaymentInfo ID="BBCreditCard" runat="server" visible="false"/>
    <asp:Label runat="server" ID="lb_Cust" CssClass="mytable"></asp:Label>
    <asp:Label runat="server" ID="lb_Order" CssClass="mytable"></asp:Label>
    <asp:Label runat="server" ID="lb_Detail" CssClass="mytable"></asp:Label>
    <table valign="top" align="center" id="TCtb" runat="server" visible="false" width="100%">
        <tr>
            <td height="25px" id="trPI2In" align="center" runat="server" visible="false">
                <asp:CheckBox ID="CBPI2Customer" runat="server" Checked="true" />
                &nbsp;<label id="PICheckboxLabel" runat="server" style="color: Red; font-weight: bold;">PI to internal only</label>
                <%--<strong style="color: Red;">PI to internal only</strong>--%>
            </td>
        </tr>
        <tr runat="server" id="trTermConditionContent">
            <td height="233px" valign="top" align="center">
                <iframe style="border: 0; border-color: #D4D0C8" frameborder="0" scrolling="no" id="my_Iframe"
                    runat="server" name="Terms_Condition" width="898" height="335px" src="./Terms_Conditions.aspx">
                </iframe>
            </td>
        </tr>
        <tr>
            <td align="center" height="15px">
                <asp:RadioButtonList ID="TandC_Button" runat="server" RepeatDirection="Horizontal" Font-Bold="true">
                    <asp:ListItem Value="Y" Text=" I Accept" />
                    <asp:ListItem Value="N" Selected="true" Text=" I DO NOT Accept" />
                </asp:RadioButtonList>
            </td>
        </tr>
    </table>
    <div id="warndiv" style="font-size: 12px; color: #FF0000">
    </div>
    <table width="100%">
        <tr>
            <td align="center">
                <asp:Button runat="server" ID="btnOrder" Text=" >> Confirm Order << " Visible="false"
                   OnClick="btnOrder_Click"  OnClientClick="return getOpty(this)" />  
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        function getOpty(O) {
            //ming add
            document.getElementById('warndiv').innerHTML = "";
            var SPAN_RB = document.getElementById('<%=Me.TandC_Button.ClientID%>');
            if (SPAN_RB) {
                var radioButtonList = SPAN_RB.getElementsByTagName('input');
                for (var i = 0; i < radioButtonList.length; i++) {
                    if (radioButtonList.item(i).checked && radioButtonList.item(i).value == 'N') {
                        document.getElementById('warndiv').innerHTML = "Please accept Terms and Conditions, or contact Advantech for further request.";
                        return false;
                    }
                }
            }
            ShowDIV('DialogDiv');
            return true;
            //end
            //            O.value = " >> Waiting... << "
            //            O.disabled = true;
            //            var t = '<%=Request("NO") %>'
            //            PageMethods.PlaceOrder(t, onS, onF, O);
        }
        //        function onS(result, O) {
        //            location.href = "/order/pi.aspx?NO=" + result
        //        }
        //        function onF(result, O) {
        //            location.href = "/order/pi.aspx?NO=" + result
        //        }


        function DoPrint() {
            var obj0 = document.getElementById('<%=Me.Sty.ClientID%>');
            var obj1 = document.getElementById('<%=Me.lb_Cust.ClientID%>');
            var obj2 = document.getElementById('<%=Me.lb_Order.ClientID%>');
            var obj3 = document.getElementById('<%=Me.lb_Detail.ClientID%>');

            var text0 = obj0.outerHTML;
            var text1 = obj1.innerHTML;
            var text2 = obj2.innerHTML;
            var text3 = obj3.innerHTML;
            document.open();
            document.write("");
            document.write(text0 + text1 + text2 + text3);
            document.close();
            print();
            window.location.href = window.location.href;
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <script src="../Includes/jquery.min.js" type="text/javascript"></script>
    <style type="text/css"  >      
      #BgDiv{background-color:#000; position:absolute; z-index:99; left:0; top:0; display:none; width:100%; height:1000px;opacity:0.5;filter: alpha(opacity=50);-moz-opacity: 0.5;}
      #DialogDiv{position:absolute;width:600px; left:50%; top:50%;  margin-left:-300px;margin-top:-63px;height:125px; z-index:100;background-color:#fff; border:4px #BF7A06 solid; padding:1px;}
      #DialogDiv .form{padding:10px; line-height:20px; font-weight:bold; color:Black;}
  </style>
  <script language="javascript" type="text/javascript">
      function ShowDIV(thisObjID) {
          $("#BgDiv").css({ display: "block", height: $(document).height() });
         var divId = document.getElementById(thisObjID);
        divId.style.top = ((document.body.clientHeight - divId.clientHeight) / 2 + document.body.scrollTop/2) + "px";
          $("#" + thisObjID).css("display", "block");
      }

      $(document).ready(function () {
<%--          IsShowNewBillTo();

          $('#<%=ckbUserNewBillAddress.ClientID %>').click(function () {
              IsShowNewBillTo();
          });

          function IsShowNewBillTo() {
              if ($('#<%=ckbUserNewBillAddress.ClientID %>').is(':checked')) {
                  $(".CCnewBillTo").show();
              } else {
                  $(".CCnewBillTo").hide();
              }
          }--%>


      });


 </script>
  <div id="BgDiv"></div>
  <div id="DialogDiv" style="display:none">
   <div class="form">Your order is being processed and may take several seconds. Please do not close or refresh this page, or your order may not be processed successfully, thank you.
    <br />
    <asp:Image runat="server" ID="imgMasterLoad" ImageUrl="~/Images/LoadingRed.gif" />
    <b>Loading ...</b>
   </div>
  </div>
</asp:Content>
