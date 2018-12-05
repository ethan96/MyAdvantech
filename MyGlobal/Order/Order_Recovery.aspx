<%@ Page Title="MyAdvantech–Order Recovery" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register Src="../Includes/Payment/PaymentInfo.ascx" TagName="PaymentInfo" TagPrefix="uc1" %>
<%@ Register Src="~/Includes/BBFreightCalculation.ascx" TagName="BBFreightCalculation" TagPrefix="uc4" %>
<script runat="server">
    Dim myOrderMaster As New order_Master("b2b", "ORDER_MASTER")
    Dim myOrderDetail As New order_Detail("b2b", "ORDER_DETAIL")
    Dim myFailedOrder As New ORDER_PROC_STATUS("b2b", "ORDER_PROC_STATUS2")
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Not IsNothing(Request("NO")) And Request("NO") <> "" Then
                Me.txtOrderNo.Text = Request("NO")
                initGVMaster(Request("NO"))
                initGVDetail(Request("NO"))

            Else
                Me.btnUpdateUp.Visible = False
                Me.btnUpdateDown.Visible = False
                initGV1()
            End If
            If AuthUtil.IsBBUS And Not IsNothing(Request("NO")) And Request("NO") <> "" Then
                'Alex 20170925: If BB, show bb freight textbox
                ShowBBFreight(Request("NO"))

            End If
        End If
        If AuthUtil.IsBBUS And Not IsNothing(Request("NO")) And Request("NO") <> ""Then

            'Alex: 20180427 選CODC時顯示Credit card fill form
            Dim DT As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
            If AuthUtil.IsBBUS AndAlso DT IsNot Nothing AndAlso DT.Rows(0).Item("PAYTERM") = "CODC" Then
                BBCreditCard.Visible = True
            End If
        End If
    End Sub
    Sub initGV1()
        Dim str As String = String.Format("select distinct a.ORDER_ID, a.SOLDTO_ID, a.ORDER_DATE, a.CREATED_BY, 'Failed' as STATUS from ORDER_MASTER a " & _
                                                                             " INNER JOIN ORDER_PROC_STATUS2 b " & _
                                                                             " ON b.ORDER_NO = a.ORDER_NO " & _
                                                                             " where b.status=0 and a.ORDER_DATE between getdate()-900 and getdate() and a.ORDER_NO not in (select distinct c.ORDER_NO from ORDER_PROC_STATUS2 c where c.STATUS = 1)")

        Me.sqlDS1.SelectCommand = str
        gv1.DataBind()
    End Sub

    Sub initGVMaster(ByVal orderID As String)

        Dim Dt As DataTable = myOrderMaster.GetDT(String.Format("order_ID='{0}'", orderID), "")
        Me.gvMaster.DataSource = Dt
        Me.gvMaster.DataBind()
    End Sub

    Sub initGVDetail(ByVal orderID As String)
        Dim Dt As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", orderID), "line_no")
        Me.gvDetail.DataSource = Dt
        Me.gvDetail.DataBind()
    End Sub

    Sub ShowBBFreight(ByVal orderID As String)
        Dim myFt As New Freight("b2b", "Freight")
        Dim dtFreight As DataTable =myFt.GetDT(String.Format("order_id='{0}'", orderID), "")
        trFreightBB.Visible = True
        If dtFreight.Rows.Count > 0  Then
            Dim freight As Decimal = dtFreight.Rows(0).Item("fvalue")
            txtBBFreight.Text = Convert.ToString(freight)
        Else
            txtBBFreight.Text = "NA"
        End If
    End Sub

    Sub GetBBNewFreight(ByVal orderID As String)

        Dim orderPartner As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        Dim orderPartnerSoldToDT As DataTable = orderPartner.GetPartnerByOrderIDAndType(orderID,"SOLDTO")
        Dim orderPartnerShipToDT As DataTable = orderPartner.GetPartnerByOrderIDAndType(orderID,"S")
        Dim orderPartnerBillToDT As DataTable = orderPartner.GetPartnerByOrderIDAndType(orderID,"B")
        Dim SoldtoID As String = ""
        Dim ShiptoID As String = ""
        Dim BilltoID As String = ""


        'If  AuthUtil.IsBBUS  Then
        '    'Alex 20170925: If BB, delete freight by bbfreight textbox value
        '    Dim myFt As New Freight("b2b", "Freight")
        '    myFt.Delete(String.Format("order_id='{0}'", Request("NO")))
        'End If

        'Sold-to
        Dim SoldtoCompany As Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY = New Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY()
        If orderPartnerSoldToDT.Rows.Count > 0 Then
            SoldtoID  = orderPartnerSoldToDT.Rows(0).Item("ERPID")
            If Not String.IsNullOrEmpty(SoldtoID) Then
                SoldtoCompany.COMPANY_ID = SoldtoID
                SoldtoCompany.COUNTRY = orderPartnerSoldToDT.Rows(0).Item("COUNTRY")
                SoldtoCompany.REGION_CODE = orderPartnerSoldToDT.Rows(0).Item("STATE")
                SoldtoCompany.ZIP_CODE = orderPartnerSoldToDT.Rows(0).Item("ZIPCODE")
            Else
                SoldtoID = Session("company_id")
                SoldtoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
            End If
        Else
            SoldtoID = Session("company_id")
            SoldtoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
        End If

        'Ship-to
        Dim ShiptoCompany As Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY = New Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY()
        If orderPartnerShipToDT.Rows.Count > 0 Then
            ShiptoID = orderPartnerShipToDT.Rows(0).Item("ERPID")
            If Not String.IsNullOrEmpty(ShiptoID) Then
                ShiptoCompany.COMPANY_ID = ShiptoID
                ShiptoCompany.COUNTRY = orderPartnerShipToDT.Rows(0).Item("COUNTRY")
                ShiptoCompany.REGION_CODE = orderPartnerShipToDT.Rows(0).Item("STATE")
                ShiptoCompany.ZIP_CODE = orderPartnerShipToDT.Rows(0).Item("ZIPCODE")
            Else
                ShiptoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
            End If
        Else
            ShiptoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
        End If

        'Bill-to
        Dim BilltoCompany As Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY = New Advantech.Myadvantech.DataAccess.SAP_DIMCOMPANY()
        If orderPartnerBillToDT.Rows.Count > 0 Then
            BilltoID = orderPartnerBillToDT.Rows(0).Item("ERPID")
            If Not String.IsNullOrEmpty(BilltoID) Then
                BilltoCompany.COMPANY_ID = BilltoID
                BilltoCompany.COUNTRY = orderPartnerBillToDT.Rows(0).Item("COUNTRY")
                BilltoCompany.REGION_CODE = orderPartnerBillToDT.Rows(0).Item("STATE")
                BilltoCompany.ZIP_CODE = orderPartnerBillToDT.Rows(0).Item("ZIPCODE")
            Else
                BilltoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
            End If
        Else
            BilltoCompany = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSAPDIMCompanyByERPID(SoldtoID).FirstOrDefault()
        End If

        Dim CartItems As List(Of Advantech.Myadvantech.DataAccess.cart_DETAIL_V2) = OrderToCart(orderID)

        If CartItems IsNot Nothing AndAlso CartItems.Count > 0 Then
            Dim result As Boolean = Me.ascxBBFreightCalculation.GetFreight(SoldtoCompany, ShiptoCompany, BilltoCompany, CartItems)
            If result Then
                ClientScript.RegisterStartupScript(GetType(Page), "Script", "ShowFancyBox();", True)
            Else
                Util.JSAlert(Me.Page, "Get Freight Failed.")
            End If
        End If


    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Sub AddFreight(ByVal orderId As String, ByVal freightAmount As String)
        'Dim myFt As New Freight("b2b", "Freight")
        'myFt.Add(orderId, "ZHD0", Util.ReplaceSQLStringFunc(freightAmount))
    End Sub

    Function OrderToCart(ByVal orderID As String) As List(Of Advantech.Myadvantech.DataAccess.cart_DETAIL_V2)
        Dim myOrderDetailDt As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", orderID), "line_no")
        Dim cartItems As New List(Of Advantech.Myadvantech.DataAccess.cart_DETAIL_V2)

        If myOrderDetailDt.Rows.Count > 0 Then
            For Each row As DataRow In myOrderDetailDt.Rows
                Dim cartItem As New Advantech.Myadvantech.DataAccess.cart_DETAIL_V2
                cartItem.otype = Convert.toInt32(row.Item("ORDER_LINE_TYPE"))
                cartItem.Qty = Convert.toInt32(row.Item("QTY"))
                cartItem.Part_No = row.Item("PART_NO")
                cartItem.Line_No = Convert.toInt32(row.Item("LINE_NO"))
                cartItem.higherLevel  = Convert.toInt32(row.Item("HigherLevel"))
                cartItems.Add(cartItem)
            Next row
        End If

        Return cartItems
    End Function

    Sub Update() Handles btnUpdateUp.Click, btnUpdateDown.Click
        initGVMaster(Request("NO"))
        initGVDetail(Request("NO"))

        'Alex 20170925:  For BB, need to select new freight
        If AuthUtil.IsBBUS Then
            GetBBNewFreight(Request("NO"))
        End If
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        initGV1()
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(0).Text = "<a href=""/order/Order_recovery.aspx?NO=" & e.Row.Cells(0).Text & """>" & e.Row.Cells(0).Text & "</a>"
        End If
    End Sub

    Protected Sub txtPartNo_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim CustPN As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' AND LINE_NO='{1}'", Request("NO"), id), String.Format("PART_NO='{0}'", CustPN))
    End Sub

    Protected Sub chxDel_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As CheckBox = CType(sender, CheckBox)
        If obj.Checked Then
            Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
            Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
            myOrderDetail.Delete(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), id))
            myOrderDetail.reSetLineNoAfterDel(Request("NO"), id)
        End If
    End Sub

    Protected Sub txtPO_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim PONO As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("PO_NO='{0}'", PONO))
    End Sub
    Protected Sub txtMSReqDate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim ReqDate As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("REQUIRED_DATE='{0}'", ReqDate))
    End Sub
    Protected Sub txtPrice_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim price As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("UNIT_PRICE='{0}'", price))
    End Sub

    Protected Sub txtQty_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim Qty As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("qty='{0}'", Qty))
    End Sub


    Protected Sub txtDueDate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim DueDate As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("due_Date='{0}'", DueDate))
    End Sub

    Protected Sub txtReqDate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gvDetail.DataKeys(row.RowIndex).Value
        Dim ReqDate As String = obj.Text
        myOrderDetail.Update(String.Format("Order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("required_Date='{0}'", ReqDate))
    End Sub

    Protected Sub txtShipTo_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim shipto As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("shipto_id='{0}'", shipto))
    End Sub

    Protected Sub btnShowAll_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/order/order_recovery.aspx")
    End Sub

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim OrderNo As String = Me.txtOrderNo.Text.Trim.Replace("'", "''")
        Response.Redirect("~/order/order_recovery.aspx?NO=" & OrderNo)
    End Sub

    Public Function getMassage() As String
        Dim mm As String = ""
        Dim Message_DT As DataTable = myFailedOrder.GetDT(String.Format("order_no='{0}'", Request("NO")), "LINE_SEQ")
        If Message_DT.Rows.Count > 0 Then
            Dim j As Integer = 0
            While j <= Message_DT.Rows.Count - 1
                mm &= "<font color=""red"">&nbsp;&nbsp;+&nbsp;" & Message_DT.Rows(j).Item("MESSAGE") & "</font>"
                mm &= "<br/>"
                j = j + 1
            End While
        Else
            mm &= "&nbsp;&nbsp;+&nbsp;<font color=""red"">No Message" & "</font>"
        End If
        Return mm
    End Function

    Protected Sub btnReCover_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ErrMsg As String = "", soldto As String = String.Empty
        If changeCompany(Request("NO"), soldto) = False Then
            ErrMsg = "This Order’s ERPID """ + soldto + """ is invalid either because it does not exist in SAP or it is not a sold-to account"
            Glob.ShowInfo(ErrMsg)
            Exit Sub
        End If
        Dim ret As Boolean = False
        Dim order_no As String = Request("NO")
        Dim Quote_Id As String = ""

        'Alex 20170925: If BB, insert new freight 
        'If AuthUtil.IsBBUS And IsNumeric(Util.ReplaceSQLStringFunc(Me.txtBBFreight.Text.Trim)) Then
        '    Dim myFt As New Freight("b2b", "Freight")
        '    myFt.Add(order_no, "ZHD0", Util.ReplaceSQLStringFunc(Me.txtBBFreight.Text.Trim))
        'End If

        Try
            If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) AndAlso myOrderDetail.isQuoteOrder(order_no, Quote_Id) Then
                If Not String.IsNullOrEmpty(Quote_Id) Then
                    Dim SAPQlogA As New MyOrderDSTableAdapters.CreateSAPQuoteLogTableAdapter
                    SAPQlogA.Insert(order_no, Quote_Id, Now)
                    If Quote_Id.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase) Then
                        If MYSAPDAL.checkSAPQuote(Quote_Id) = False Then
                            ret = SAPDOC.SOCreateV6(order_no, ErrMsg, False, Quote_Id, True)
                        End If
                    End If
                End If
            End If
        Catch ex As Exception
            Util.SendEmail("myadvanteh@advantech.com", "myadvanteh@advantech.com", "Create SAP Quote Failed.", ex.ToString, True, "", "")
        End Try
        Dim dtMsg As New DataTable
        If MYSAPDAL.checkSAPQuote(Quote_Id) = False Then
            Quote_Id = ""
        End If


        'Alex 20171219: for B+B, if payment term is CODC,  auth credit card before create SO  
        Dim paymentRet As Boolean = True
        Dim myOrderMaster As New order_Master("b2b", "order_master")
        Dim DT As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", order_no), "")

        If AuthUtil.IsBBUS Then

            'Alex 20180427: If BB, delete old freight and add freight by bbfreight textbox value
            Dim myFt As New Freight("b2b", "Freight")
            myFt.Delete(String.Format("order_id='{0}'", order_no))
            myFt.Add(order_no, "ZHD0", Util.ReplaceSQLStringFunc(txtBBFreight.Text))

            If DT.Rows.Count > 0 And DT.Rows(0).Item("PAYTERM") = "CODC" Then
                paymentRet = BBCreditCard.AuthPaymentAmount(order_no, order_no, Session("COMPANY_ID"), ErrMsg)
            End If
        End If

        If paymentRet Then
            'Ryan 20170731 If is ACN loose order and contains D/P/T items, create SAP quotation instead
            If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.StartsWith("CN") AndAlso MyServices.IsACNOrderNeedsApproval(order_no, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString), Session("org_id")) Then
                ret = SAPDOC.SOCreateV6(order_no, ErrMsg, False, order_no, True)
            Else
                ret = SAPDOC.SOCreateV6(order_no, ErrMsg, False, Quote_Id)
            End If
        Else
            ret = False
        End If


        If ret Then
            SAPDOC.ProcessAfterOrderSuccess(Request("NO"), ErrMsg, True)
            ' 20120801 Ming: Update SO ShipTo Attention
            Dim retTable As New DataTable
            If Util.IsTesting() Then
                SAPDOC.UpdateSAPSOShipToAttention(Request("NO"), retTable, False)
            Else
                SAPDOC.UpdateSAPSOShipToAttention(Request("NO"), retTable, True)
            End If
            'end

            'Ryan 20180723 Add PO creation
            If MYSAPDAL.IsCreatePO(UCase(Session("COMPANY_ID"))) AndAlso BtosOrderCheck(order_no) = 1 Then
                Dim retMsg As String = "", pono As String = "", retCode As Boolean = False
                MYSAPDAL.CreatePo(order_no, pono, retMsg, retCode)
            End If

            'Ming 20150612 呼叫MyAdvantechAPI插入转单记录
            Dim logOrgs As String() = New String() {"US01", "TW01", "CN10", "JP01"}
            If logOrgs.Contains(Session("org_id").ToString.ToUpper) Then
                ' If Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                Dim quoteId As String = "", Msg = ""
                If myOrderDetail.isQuoteOrder(order_no, quoteId) Then
                    Dim retbool = Advantech.Myadvantech.Business.QuoteBusinessLogic.LogQuote2Order(order_no, quoteId, Msg)
                    If Not retbool Then Util.InsertMyErrLog(Msg)
                End If
            End If
            Response.Redirect("~/ORDER/PI.ASPX?NO=" & Request("NO"))
        Else
            If Not Util.IsTesting() Then
                'SAPDOC.ProcessAfterOrderFailed(Request("NO"), ErrMsg)
            End If

            'For bb, if create SO failed, void preauth payment 
            If AuthUtil.IsBBUS And DT.Rows.Count > 0 And DT.Rows(0).Item("PAYTERM") = "CODC" And paymentRet Then
                BBCreditCard.VoidPayment(order_no, order_no)
            End If

            Glob.ShowInfo(ErrMsg)
            Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", "Order recovery Failed:" + Request("NO"), ErrMsg.ToString, True, "", "")
        End If
    End Sub
    'Protected Function AuthCreditCard(ByVal order_no As String, DT As DataTable, ByRef errorMessage As String) As Boolean
    '    Dim paymentRet As Boolean = False
    '    Dim orderamount As Decimal = 0, taxamount As Decimal = 0, freightamount As Decimal = 0

    '    ' Order amount
    '    Dim myOrderDetail As New order_Detail("b2b", "order_detail")
    '    orderamount = myOrderDetail.getTotalAmount(order_no)

    '    ' Freight amount
    '    Dim myFt As New Freight("b2b", "Freight")
    '    Dim dtFreight As DataTable = myFt.GetDT(String.Format("order_id='{0}'", order_no), "")
    '    If dtFreight.Rows(0) IsNot Nothing Then
    '        Dim freight As Decimal = dtFreight.Rows(0).Item("fvalue")
    '        freightamount += freight
    '    End If

    '    ' Tax amount
    '    Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = order_no).FirstOrDefault()
    '    If MasterExtension IsNot Nothing Then
    '        taxamount = Decimal.Round(orderamount * Decimal.Parse(MasterExtension.OrderTaxRate), 2, MidpointRounding.AwayFromZero)
    '    End If

    '    Dim totalauthamount As Decimal = orderamount + freightamount + taxamount


    '    Dim cardNum As String = DT.Rows(0).Item("CREDIT_CARD")
    '    Dim cardHolder As String = DT.Rows(0).Item("CREDIT_CARD_HOLDER")
    '    Dim cvvCode As String = DT.Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER")
    '    Dim cardExpDate As String = DT.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE")
    '    Dim cardType As String = DT.Rows(0).Item("CREDIT_CARD_TYPE")


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
    '    Dim orderPartnerDT As DataTable = orderPartner.GetPartnerByOrderIDAndType(order_no, "B_CC")

    '    If orderPartnerDT.Rows.Count > 0 Then
    '        Dim zipCode As String = orderPartnerDT.Rows(0).Item("ZIPCODE")
    '        Dim country As String = orderPartnerDT.Rows(0).Item("COUNTRY")
    '        Dim city As String = orderPartnerDT.Rows(0).Item("CITY")
    '        Dim street As String = orderPartnerDT.Rows(0).Item("STREET")
    '        Dim state As String = orderPartnerDT.Rows(0).Item("STATE")
    '        'paymentRet = PaymentInfo.AuthPaymentAmount(order_no, totalauthamount, firstName, lastName, street, city, state, zipCode, "", cardNum, cvvCode, Convert.ToDateTime(cardExpDate), errorMessage)
    '        If paymentRet Then
    '            dbUtil.dbExecuteNoQuery("MY", String.Format("update ORDER_PARTNERS  set ROWID = '{0}' where type = 'B_CC' and ORDER_ID = '{1}'", PaymentInfo.TransactionId + "|" + PaymentInfo.AuthCode, order_no))
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

    'Protected Function VoidCreditCard(ByVal order_no As String, DT As DataTable, ByRef errorMessage As String) As Boolean
    '    Dim paymentRet As Boolean = False

    '    Dim cardNum As String = DT.Rows(0).Item("CREDIT_CARD")
    '    Dim cardHolder As String = DT.Rows(0).Item("CREDIT_CARD_HOLDER")
    '    Dim cvvCode As String = DT.Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER")
    '    Dim cardExpDate As String = DT.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE")
    '    Dim cardType As String = DT.Rows(0).Item("CREDIT_CARD_TYPE")


    '    Dim orderPartner As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
    '    Dim orderPartnerDT As DataTable = orderPartner.GetPartnerByOrderIDAndType(order_no, "B_CC")

    '    If orderPartnerDT.Rows.Count > 0 Then
    '        Dim transactionId As String = ""
    '        Dim Authinfo As Object = dbUtil.dbExecuteScalar("MY", "select ROWID from ORDER_PARTNERS where ORDER_ID = '" + order_no + "' and type = 'B_CC' ")
    '        If Authinfo IsNot Nothing AndAlso Not String.IsNullOrEmpty(Authinfo) Then
    '            If Authinfo.ToString.Contains("|") Then
    '                transactionId = Authinfo.ToString.Split("|")(0)
    '            End If
    '        End If

    '        paymentRet = PaymentInfo.VoidPayment(transactionId, cardNum, cvvCode, Convert.ToDateTime(cardExpDate), errorMessage)
    '    Else
    '        errorMessage = "No Credit Card information. Void Auth Payment fail!"
    '    End If

    '    Return paymentRet

    'End Function

    Protected Function changeCompany(ByVal Order_Id As String, ByRef soldto As String) As Boolean
        Dim _retbool As Boolean = False
        Dim dt As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_Id), "")
        If dt.Rows.Count > 0 Then
            Dim _soldto As String = dt.Rows(0).Item("soldto_id").ToString.Trim
            soldto = _soldto
            If Not String.Equals(Session("company_id"), _soldto, StringComparison.CurrentCultureIgnoreCase) Then
                Dim AU As New AuthUtil
                'Me.chgCompany.TargetCompanyId = dt.Rows(0).Item("soldto_id")
                'Me.chgCompany.ChangeToCompanyId()
                _retbool = AU.ChangeCompanyId(_soldto)
            Else
                _retbool = True
            End If
        End If
        Return _retbool
    End Function

    Protected Sub gvMaster_RowCreated(sender As Object, e As GridViewRowEventArgs)
        If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.StartsWith("CN") Then
            gvMaster.Columns(5).Visible = True
            gvMaster.Columns(6).Visible = True
        End If
    End Sub

    Protected Sub txtSalesGroup_TextChanged(sender As Object, e As EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim SalesGroup As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("SALESGROUP='{0}'", SalesGroup))
    End Sub

    Protected Sub txtSalesOffice_TextChanged(sender As Object, e As EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As String = Me.gvMaster.DataKeys(row.RowIndex).Value
        Dim SalesOffice As String = obj.Text
        myOrderMaster.Update(String.Format("Order_id='{0}'", id), String.Format("SALESOFFICE='{0}'", SalesOffice))
    End Sub

    Protected Sub gvDetail_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            'Ryan 20170830 Disable Parent Item price textbox
            Dim line_no As Integer = gvDetail.DataKeys(e.Row.RowIndex).Value
            Dim txtBox_Price As TextBox = CType(e.Row.FindControl("txtPrice"), TextBox)

            If line_no Mod 100 = 0 Then
                txtBox_Price.Enabled = False
            End If
        End If
    End Sub

    Function BtosOrderCheck(ByVal Order_No As String) As Integer
        Dim myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}' and line_no >= 100", Order_No), "line_No")
        If dtDetail.Rows.Count > 0 Then
            BtosOrderCheck = 1
        Else
            BtosOrderCheck = 0
        End If
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <%--  <uc1:ChangeCompany runat="server" ID="chgCompany" Visible="false" />--%>
    <table width="100%">
        <tr>
            <td class="menu_title">Order Recovery
            </td>
        </tr>
        <tr>
            <td style="border: 1px solid #d7d0d0; padding: 10px">
                <table cellspacing="5px">
                    <tr>
                        <td class="h5">Order NO:
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtOrderNo"></asp:TextBox>
                        </td>
                        <td>
                            <asp:Button runat="server" Text="ShowFailedOrderList" ID="btnShowAll" OnClick="btnShowAll_Click" />
                        </td>
                        <td>
                            <asp:Button runat="server" Text="Query" ID="btnQuery" OnClick="btnQuery_Click" />
                        </td>
                        <td>
                            <asp:Button runat="server" Text="Recover" ID="btnReCover" OnClick="btnReCover_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <hr />
    <table width="100%" cellpadding="5px">
        <tr>
            <td>
                <%=getMassage()%>
            </td>
        </tr>
    </table>
    <br />
    <asp:Button runat="server" ID="btnUpdateUp" Text=" >> Update << " />
    <asp:GridView runat="server" ID="gvMaster" AutoGenerateColumns="false" AllowPaging="false"
        AllowSorting="true" Width="100%" EmptyDataText="No Order" DataKeyNames="Order_id" OnRowCreated="gvMaster_RowCreated">
        <Columns>
            <asp:TemplateField>
                <HeaderTemplate>
                    Order NO
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("order_no")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    PO NO
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtPO" runat="server" Text='<%# Eval("PO_no")%>' OnTextChanged="txtPO_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Ship To
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtShipTo" runat="server" Text='<%# Eval("shipto_id")%>' Enabled="false"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Order Date
                </HeaderTemplate>
                <ItemTemplate>
                    <%# CDate(Eval("Order_Date")).ToString("yyyy/MM/dd")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Required Date
                </HeaderTemplate>
                <ItemTemplate>
                    <%--<%# CDate(Eval("Required_date")).ToString("yyyy/MM/dd")%>--%>
                    <asp:TextBox ID="txtMSReqDate" Width="80px" runat="server" Text='<%#CDate(Eval("Required_date")).ToString("yyyy/MM/dd")%>'
                        OnTextChanged="txtMSReqDate_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField Visible="false">
                <HeaderTemplate>
                    Sales Group
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtSalesGroup" runat="server" Text='<%# Eval("SALESGROUP")%>' OnTextChanged="txtSalesGroup_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField Visible="false">
                <HeaderTemplate>
                    Sales Office
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtSalesOffice" runat="server" Text='<%# Eval("SALESOFFICE")%>' OnTextChanged="txtSalesOffice_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <br />
    <asp:GridView runat="server" ID="gvDetail" AutoGenerateColumns="false" AllowPaging="false"
        AllowSorting="true" Width="100%" EmptyDataText="No Order" DataKeyNames="line_no" OnRowDataBound="gvDetail_RowDataBound">
        <Columns>
            <asp:TemplateField>
                <HeaderTemplate>
                    Index
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Container.DataItemIndex + 1%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Line No
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("Line_no")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Order No
                </HeaderTemplate>
                <ItemTemplate>
                    <%# Eval("Order_ID")%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Item No
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtPartNo" runat="server" Text='<%# Eval("part_no")%>' OnTextChanged="txtPartNo_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    QTY
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtQty" Width="30px" runat="server" Text='<%# Eval("Qty")%>' OnTextChanged="txtQty_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Price
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtPrice" Width="80px" runat="server" Text='<%# Eval("unit_Price")%>'
                        OnTextChanged="txtPrice_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Req Date
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtReqDate" Width="80px" runat="server" Text='<%# cdate(Eval("required_date")).tostring("yyyy/MM/dd")%>'
                        OnTextChanged="txtReqDate_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Due Date
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:TextBox ID="txtDueDate" Width="80px" runat="server" Text='<%# cdate(Eval("due_date")).tostring("yyyy/MM/dd")%>'
                        OnTextChanged="txtDueDate_TextChanged"></asp:TextBox>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    Del
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:CheckBox runat="server" ID="chxDel" OnCheckedChanged="chxDel_CheckedChanged" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <table style="float: right;">
        <tr runat="server" id="trFreightBB" visible="false">
            <td class="h5">Freight Fee(B+B):
            </td>
            <td>
                <asp:TextBox ID="txtBBFreight" runat="server" style="width:50px;"></asp:TextBox>
                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender2" TargetControlID="txtBBFreight"
                    FilterType="Numbers, Custom" ValidChars="." />
            </td>
        </tr>
    </table>


    <asp:Button runat="server" ID="btnUpdateDown" Text=" >> Update << " />
    <br />
    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="true" DataSourceID="sqlDS1"
        AllowPaging="true" PageSize="15" AllowSorting="true" Width="100%" EmptyDataText=""
        DataKeyNames="Order_ID" OnPageIndexChanging="gv1_PageIndexChanging" OnRowDataBound="gv1_RowDataBound">
    </asp:GridView>
    <uc1:PaymentInfo ID="BBCreditCard" runat="server" visible="false"/>
    <asp:SqlDataSource runat="server" ID="sqlDS1" ConnectionString="<%$ ConnectionStrings:B2B %>"></asp:SqlDataSource>
    <div style="display: none">
        <div id="divBBFreightCalculation">
            <uc4:BBFreightCalculation ID="ascxBBFreightCalculation" runat="server" />
        </div>
    </div>


    <link href="../Includes/jquery-ui.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../Includes/jquery-latest.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.easyui.min.js"></script>
    <script type="text/javascript" src="../Includes/js/jquery-ui.min.js"></script>
    <script src="../../Includes/EasyUI/jquery.searchabledropdown-1.0.8.min.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <link rel="Stylesheet" href="../../Includes/FancyBox/jquery.fancybox.css" type="text/css" />
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <script  type="text/javascript">
        function ShowFancyBox() {
            var gallery = [{
                href: "#divBBFreightCalculation"
            }];

            $.fancybox(gallery, {
                'autoSize': true,
                'autoCenter': true
            });
        }

        $(document).ready(function () {
            $("#<%=Me.txtBBFreight.ClientID%>").attr("readonly", true);
        });
                       

        function SetBBFreightFromASCX(DeliveryType, DeliveryValue, FreightCost) {
               $("#<%=Me.txtBBFreight.ClientID%>").val(FreightCost);

<%--           var postData = JSON.stringify({ orderId: "<%=Request("NO")%>", freightAmount: Cost });
           $.ajax({

                type: "POST",
                url: "Order_Recovery.aspx/AddFreight",
                data: postData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (retData) {
                    $("#<%=Me.txtBBFreight.ClientID%>").val(FreightCost);
                    $("#<%=Me.txtBBFreight.ClientID%>").attr("readonly", true);
                }
            });--%>
       }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

