<%@ Page Title="MyAdvantech–Shopping Cart" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" EnableEventValidation="false" %>

<script runat="server">
    Dim mycart As New CartList("b2b", "CART_DETAIL_V2")
    Dim myCartHistory As New cart_history("b2b", "cart_history")
    Dim isANA As Boolean = False
    Dim CartId As String = "", CurrencySign As String = String.Empty
    Dim isJPAonline As Boolean = False, IsInternalUser As Boolean = False, isACNUser As Boolean = False
    Dim CheckPoint_Convert2Order As String = ""
    Dim isFeiOffice As Boolean = False
    Dim isCartFromQuote As Boolean = False
    Dim isRiskOrder As Boolean = False
    Dim DefaultShipto As String = "", CountryCode As String = ""
    Function isSpecailRole(ByVal user As String) As Boolean
        If user.ToLower.Contains("amy@kingpronet.com.tw") Then
            Return True
        End If
        If user.ToLower.Contains("jack@kingpronet.com.tw") Then
            Return True
        End If
        Return False
    End Function
    Protected Sub InitBtosParent()
        DDLbtosParentItem.Items.Clear()
        drpSplitSystem.Items.Clear()
        Dim _cartlist As List(Of CartItem) = MyCartX.GetBtosParentItems(CartId)
        If _cartlist.Count > 0 Then
            For Each _cartitem As CartItem In _cartlist
                DDLbtosParentItem.Items.Add(New ListItem(String.Format("{0} ({1})", _cartitem.Part_No, _cartitem.Line_No), _cartitem.Line_No))

                If isACNUser Then
                    drpSplitSystem.Items.Add(New ListItem(String.Format("{0} ({1})", _cartitem.Part_No, _cartitem.Line_No), _cartitem.Line_No))
                End If
            Next
        End If
        DDLbtosParentItem.Items.Insert(0, New ListItem("Loose items", "0"))
        If _cartlist.Count > 0 Then
            DDLbtosParentItem.ClearSelection()
            Dim MaxParent As CartItem = _cartlist.OrderByDescending(Function(p) p.Line_No).FirstOrDefault()
            If MaxParent IsNot Nothing Then
                DDLbtosParentItem.SelectedValue = MaxParent.Line_No
            End If
        End If

        'If String.Equals(Session("org_id"), "EU10", StringComparison.InvariantCultureIgnoreCase) Then
        '    If DDLbtosParentItem.Items.Count > 1 Then
        '        Dim LooseItem As ListItem = DDLbtosParentItem.Items.FindByValue("0")
        '        If LooseItem IsNot Nothing Then
        '            DDLbtosParentItem.Items.Remove(LooseItem)
        '            ibtnAdd.Visible = False
        '        End If
        '    End If
        'End If

        'Ryan 20170425 Also hide add button for ACN BTOS cart
        If MyCartX.IsEUBtosCart(CartId) Then
            ibtnAdd.Visible = False
            ibtnSearch.Visible = False
        ElseIf Session("org_id").ToString.StartsWith("CN") AndAlso MyCartX.IsHaveBtos(CartId) Then
            ibtnAdd.Visible = False
            ibtnSearch.Visible = False

            'Ryan 20171127 中科 is able to see add button
            If Session("Company_ID").ToString.ToUpper.Equals("C103379") Then
                ibtnAdd.Visible = True
                ibtnSearch.Visible = True
            End If
        Else
            ibtnAdd.Visible = True
            ibtnSearch.Visible = True
        End If

        'If MyCartX.IsEUBtosCart(CartId) Then
        '    ibtnAdd.Visible = False
        '    ibtnSearch.Visible = False
        'End If

        If isACNUser Then
            If Me.drpSplitSystem.Items.Count > 0 Then
                trSplitPrice.Visible = True
            Else
                trSplitPrice.Visible = False
            End If
        End If
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        '把預設按鈕指定給空按鈕，防止ENTER發生Logout
        Me.Page.Form.DefaultButton = btn_enter.UniqueID

        CartId = Session("CART_ID") : CurrencySign = MyCartX.GetCurrencySign(CartId)
        IsInternalUser = Util.IsInternalUser2()

        If AuthUtil.IsUSAonlineSales(Session("user_id")) Then
            isANA = True
        End If
        'Ryan 20160122 Check if cart is from quotation or not.
        Dim quoteID As String = Advantech.Myadvantech.Business.QuoteBusinessLogic.GetQuoteIDByCartID(CartId)
        If Not String.IsNullOrEmpty(quoteID) Then
            isCartFromQuote = True
        End If
        'Ryan 20160122 Check if user is from Fei's office or not.           
        If isCartFromQuote AndAlso isANA Then
            isFeiOffice = Advantech.Myadvantech.Business.QuoteBusinessLogic.IsFeiOffice(quoteID)
        End If
        'Ryan 20160302 Validate if is risk order
        If isFeiOffice Then
            isRiskOrder = Advantech.Myadvantech.Business.OrderBusinessLogic.IsRiskOrder(CartId, Advantech.Myadvantech.DataAccess.RiskOrderInputType.Cart)
        End If

        If AuthUtil.IsJPAonlineSales(Session("user_id")) Then
            isJPAonline = True
        End If

        If AuthUtil.IsACN Then
            isACNUser = True
        End If

        'Ryan 20160822 Get ship-to country code for North America 3S Patent Litigation issue
        DefaultShipto = Advantech.Myadvantech.Business.UserRoleBusinessLogic.MYAgetShiptoIDBySoldtoID(Session("company_id").ToString(), CartId)
        CountryCode = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getCountryCodeByERPID(DefaultShipto)

        lbConfirmMsg.Text = ""

        If Not Page.IsPostBack Then
            'Ryan 20151222 Check whether page called from Check-Point convert2order or not
            If Not String.IsNullOrEmpty(Request("CheckPoint_Convert2Order")) Then
                CheckPoint_Convert2Order = Request("CheckPoint_Convert2Order")
            End If

            'Ryan 20180426 Delete all cart items and clear EQ3 session
            If Session("Quote3") IsNot Nothing AndAlso Session("Quote3") = True Then
                MyCartX.DeleteCartAllItem(CartId)
                Session("Quote3") = False
            End If

            drpEW.DataSource = MyCartX.GetExtendedWarranty() : drpEW.DataBind()
            drpEW.Items.Insert(0, New ListItem("without extended warranty", 0))
            '\ ming add fro Parent Item 2013-9-10
            Dim _Quoteid As String = String.Empty
            If MyCartX.IsQuote2Cart(CartId, _Quoteid) Then
                HFisquote2cart.Value = _Quoteid

                If Session("org_id").ToString.Trim.StartsWith("TW", StringComparison.OrdinalIgnoreCase) _
            AndAlso (AuthUtil.IsTWAonlineSales(User.Identity.Name) OrElse Util.IsAdmin()) Then
                    Me.btnApplyMinimumPrice.Visible = True
                End If
            End If
            InitBtosParent()
            '/ end
            If Session("org_id") = "TW01" Then
                Dim blToAllTW01 As Boolean = True
                Dim company_id As String = Session("company_id").ToString().ToUpper()
                If company_id.Equals("AVNA001") OrElse
                    company_id.Equals("UUMM001") OrElse
                    company_id.Equals("ASPA002") OrElse
                    company_id.Equals("EURP001") OrElse
                    company_id.Equals("ETKL001") OrElse
                    company_id.Equals("AIAD003") OrElse
                    company_id.Equals("AINA001") OrElse
                    company_id.Equals("AINT001") OrElse
                    company_id.StartsWith("MX", StringComparison.CurrentCultureIgnoreCase) OrElse
                    blToAllTW01 Then
                    'Can Place Order on MyAdvantech
                ElseIf Util.IsInternalUser2() Then
                    'Can Place Order on MyAdvantech
                ElseIf isSpecailRole(Session("user_id")) Then
                    'Can Place Order on MyAdvantech
                Else
                    Dim objPWD As String = dbUtil.dbExecuteScalar("MY",
                        "select top 1 LOGIN_PASSWORD from ACCESS_HISTORY_2013 where USERID ='" + User.Identity.Name + "' order by LOGIN_DATE_TIME desc")
                    Dim fName As String = Util.GetNameVonEmail(User.Identity.Name)
                    Dim strCmd As String =
                        "delete from USER_INFO where userid='" + User.Identity.Name + "'; delete from USER_PROFILE where userid='" + User.Identity.Name + "';" +
                        " INSERT INTO USER_INFO  (USERID, COMPANY_ID, ORG_ID, LOGIN_PASSWORD, USER_TYPE, FIRST_NAME, LAST_NAME, EMAIL_ADDR,  " +
                        " TEL_NO, TEL_EXT, FAX_NO, FAX_EXT, JOB_TITLE, JOB_FUNCTION, LAST_UPDATED, UPDATED_BY, CREATED_BY,  " +
                        " CREATED_DATE, SALES_ID) " +
                        " VALUES ('" + User.Identity.Name + "', '" + Session("company_id") + "', 'TW01', '" + Replace(objPWD, "'", "''") +
                        "', 'Contact', N'" + Replace(fName, "'", "''") + "', N'', '" + User.Identity.Name + "', '', '', '', '', '', '',  " +
                        "  GETDATE(), 'tc.chen@advantech.com.tw', 'tc.chen@advantech.com.tw', GETDATE(), N''); " +
                        "INSERT INTO USER_PROFILE (USERID, ATTRI_ID, ATTRI_VALUE_ID) VALUES ('" + User.Identity.Name + "', 1, '1')"
                    dbUtil.dbExecuteNoQuery("B2BACL", strCmd)

                    Util.JSAlertRedirect(Me.Page, "To place an order please kindly go to B2B ACL instead, thank you.",
                                         "http://b2b.advantech.com.tw/LoginNew.aspx?AutoLogin=Y&MyUID=" + User.Identity.Name + "&MyPWD=" + objPWD)
                End If
            End If

            'Ryan 20161005 Add items validation to MS items like 206Q- for EU10
            If Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
                Dim LoosePartsList As List(Of String) = MyCartX.GetCartList(CartId).Where(Function(p) p.Line_No < 100).Select(Function(p) p.Part_No).ToList
                Dim invalidSWparts As List(Of String) = Advantech.Myadvantech.Business.PartBusinessLogic.isMSSWParts(LoosePartsList, Session("org_id").ToString)
                If invalidSWparts.Count > 0 Then
                    lbConfirmMsg.Text = "Invalid Parts : " & String.Join(", ", invalidSWparts.ToArray()) + ", Software items can only be added under a BTOS/CTOS."
                End If
            End If


            'Ryan 20170116 If is not JP inside sales, not allowed to place orders
            If Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                If Not MailUtil.IsInMailGroup("AJP_IS", Session("user_id").ToString) AndAlso Not MailUtil.IsInMailGroup("ajp_callcenter", Session("user_id").ToString) AndAlso Not Util.IsMyAdvantechIT() Then
                    btnOrder.Enabled = False
                    lblMsg.Visible = True
                    lblMsg.Text = "Sales are not allowed to place order directly, please contact your inside sales instead."
                    lbConfirmMsg.Visible = False
                Else
                    Me.tdITP.Visible = True
                    Me.tdMargin.Visible = True
                End If
            End If

            If AuthUtil.IsBBUS Then
                drpCPI.Visible = False
                trEx.Visible = False
            End If
        End If


        If Util.IsInternalUser(Session("user_id")) = False Then
            If AuthUtil.IsInterConUser() Then
                If AuthUtil.IsCanSeeCost(Session("user_id")) = False Then Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
            End If
            If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then btnOrder.Enabled = False : lblMsg.Visible = True
            If Util.IsFranchiser(Session("user_id"), "") = True Then
                btnOrder.Enabled = False : lblMsg.Visible = True
            End If
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            Dim _org As String = Left(Session("org_id").ToString.ToUpper, 2)
            'If Session("org") <> "TW" And Session("org") <> "US" And Session("org") <> "SG" And Session("org") <> "JP" And Session("org") <> "EU" Then btnOrder.Enabled = False : lblMsg.Visible = True
            'IC 2014/06/18: Put all org in an array, and check it by a function in MYSAPBIZ.isOrgList 
            'If _org <> "TW" And _org <> "US" And _org <> "SG" And _org <> "JP" And _org <> "EU" Then btnOrder.Enabled = False : lblMsg.Visible = True
            If Not MYSAPBIZ.CanPlaceOrderOrg(_org) Then
                btnOrder.Enabled = False
                lblMsg.Visible = True
            End If
        End If

        If isANA Then
            Me.tbSaveCart.Visible = False
            Me.btnOrder.Text = " >> Next << "
            Me.trUP.Visible = True
        Else
            Me.trUP.Visible = False
        End If

        If Not IsPostBack Then
            ' initInterFace()
            initGV()
            'Me.txtPartNo.Attributes("autocomplete") = "off"
        End If
        Source_path()

        '20150327 TC: Display warning message to AJP sales to confirm with PSM first, per Jack.Tsao's request
        If Session("org_id") = "JP01" AndAlso Util.IsInternalUser2() Then
            If (String.IsNullOrEmpty(lbConfirmMsg.Text)) Then
                lbConfirmMsg.Text = "Please make sure all other parts added via this step are suitable for this system with getting confirmation of PSM before going next step"
            End If
        End If

        'Ryan 20151222 Add for Check-Point convert2order event check. If true, perform auto click
        If (Not String.IsNullOrEmpty(CheckPoint_Convert2Order)) AndAlso (CheckPoint_Convert2Order = HttpContext.Current.Session("cart_id")) Then
            btnOrder_Click(btnOrder, e)
        End If

        'Sub initInterFace()
        '    If mycart.isBtoOrder(CartId) = 1 Then
        '        Me.lbPageName.Text = "Add additional components to Cart"
        '        Me.HF_IsBTOS.Value = 1
        '    End If
        '    initGV()
        'End Sub
    End Sub

    Protected Sub ibtnAdd_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        lbAddErrMsg.Text = ""
        Dim part_no As String = "", qty As Integer = 0, ew_flag As Integer = 0, otype As Integer = 0, cate As String = ""
        part_no = Me.txtPartNo.Text.Trim.Replace("'", "''")
        part_no = part_no.ToUpper()
        Dim Parent_item_selected As Boolean = False

        If (DDLbtosParentItem.SelectedValue <> "0") Then Parent_item_selected = True

        Dim refmsg As String = String.Empty
        If Advantech.Myadvantech.Business.PartBusinessLogic.IsInvalidParts(Session("company_id").ToString(), Session("org_id").ToString, part_no,
                 Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString), CountryCode, Util.IsInternalUser(Session("user_id")), refmsg) Then
            lbAddErrMsg.Text = refmsg
            Exit Sub
        End If

        'Ryan 20160120 Validate if is for Schnider Order
        If ((Util.IsInternalUser(Session("user_id")) = True Or String.Equals(Session("user_id"), "Nicole.Chen@advantech.com.tw") Or String.Equals(Session("user_id"), "hawn22.Kuo@advantech.com.tw")) AndAlso part_no.Equals("SES-BM2332-H842AE")) Then
            Advantech.Myadvantech.Business.PartBusinessLogic.ExpandSchneiderSystemPartToCart("SES-BM2332-H842AE", Session("cart_id"), Session("user_id"), "ASGS002", Session("org_id"))
            initGV()
            Exit Sub
        End If

        '20150721 Ming  阻止延保料加入cart
        If part_no.StartsWith("AGS-EW", StringComparison.InvariantCultureIgnoreCase) Then
            'lbAddErrMsg.Text = "Extended warrant can not be individually added."
            Exit Sub
        End If
        qty = CInt(Me.txtQty.Text.Trim)
        ew_flag = Me.drpEW.SelectedValue
        Dim HigherLevel As Integer = Integer.Parse(DDLbtosParentItem.SelectedValue)

        'If mycart.isBtoOrder(CartId) = 1 Then
        'If DDLbtosParentItem.SelectedIndex > 0 Then
        If HigherLevel >= 100 Then

            'Ryan 20180309 Disable original TW01 rule, new function isTW01BTOSInvalidParts is applied
            If MyCartOrderBizDAL.isTW01BTOSInvalidParts(part_no, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString)) Then
                If Util.IsInternalUser2 Then
                    lbAddErrMsg.Text = "Only A/B/C+ parts are allowed to be added to a configuration, please check again."
                Else
                    lbAddErrMsg.Text = "This part is not allowed to be added to a configuration manually, please contact your sales representative for more information."
                End If
                Exit Sub
            End If
            'Ryan 20161026 TW01 users can only add X/Y/17-wires to system
            'Ryan 20161124 Per Liling's request, ADVAJP will not be included
            'If Session("org_id").ToString.Equals("TW01") AndAlso
            '    Not (Session("company_id").ToString().Equals("ADVAJP", StringComparison.OrdinalIgnoreCase) OrElse Session("company_id").ToString().Equals("ADVAMY", StringComparison.OrdinalIgnoreCase)) Then
            '    If Not (part_no.StartsWith("X", StringComparison.InvariantCultureIgnoreCase) Or part_no.StartsWith("Y", StringComparison.InvariantCultureIgnoreCase) _
            '            Or part_no.StartsWith("17", StringComparison.InvariantCultureIgnoreCase)) Then
            '        lbAddErrMsg.Text = "Only X/Y parts and cables/wires which part number start with '17' can be added to a configuration manually."
            '        Exit Sub
            '    End If
            'End If

            otype = 1 : cate = "OTHERS"
            Dim BtosParent As CartItem = MyCartX.GetCartItem(CartId, DDLbtosParentItem.SelectedValue)
            'Frank 2014/05/27: If product is added to a system, then its qty need to be multiplied by parent item's qty
            qty = qty * BtosParent.Qty
            If BtosParent IsNot Nothing Then
                ew_flag = BtosParent.Ew_Flag
            End If
        End If
        Dim ReqDate As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        'Frank:ReqDate should be next working day from today
        ReqDate = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, ReqDate), Session("org_id"))
        Dim msg As String = ""
        Dim lineNo As Integer = 0
        If Session("org_id") = "US01" AndAlso trUP.Visible = True AndAlso IsNumeric(Me.txtPrice.Text.Trim) _
            AndAlso Not IsLoseGPPartNo(part_no) Then
            Dim unitPrice As Decimal = 0
            unitPrice = Me.txtPrice.Text.Trim()
            Dim decGPPercentage As Decimal = -1
            Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id")), distr_chan As String = "10", division As String = "00"
            SAPDOC.Get_disChannel_and_division(Session("company_id"), distr_chan, division)
            If String.Equals(Session("company_id").ToString, "UEPP5001") Then division = "20"
            If OrderUtilities.isANAPnBelowGP(part_no, unitPrice, decGPPercentage) Then
                lbAddErrMsg.Text = "Item " + part_no + " is below GP Price(" & FormatNumber(decGPPercentage, 2).ToString() & ")"
                'Glob.ShowInfo(ErrMsg)
                Exit Sub
            Else
                Dim listPrice As Decimal = 0
                listPrice = Glob.getListPrice(part_no, "US01", "USD")

                lineNo = MyCartOrderBizDAL.Add2Cart_BIZ(CartId, part_no, qty, ew_flag, otype, cate, 0, 1, ReqDate, "", "", HigherLevel, True, msg, Parent_item_selected)
                mycart.Update(String.Format("cart_Id='{0}' and line_no='{1}'", CartId, lineNo), String.Format("list_price='{1}',ounit_price='{0}',unit_Price='{0}'", unitPrice, listPrice))
            End If
        Else

            lineNo = MyCartOrderBizDAL.Add2Cart_BIZ(CartId, part_no, qty, ew_flag, otype, cate, 1, 1, ReqDate, "", "", HigherLevel, True, msg, Parent_item_selected)
        End If
        If lineNo = 0 Then
            lbAddErrMsg.Text = msg
        End If
        If MyCartOrderBizDAL.IsSpecialADAM(part_no) Then
            mycart.Update(String.Format("cart_Id='{0}' and line_no='{1}'", CartId, lineNo), String.Format("ew_Flag='99'"))
        End If
        initGV()
        Me.txtPartNo.Text = "" : Me.txtQty.Text = 1 : Me.txtPrice.Text = "" : Me.drpEW.SelectedValue = 0
        'btnOrder.Enabled = True
        'Ryan 20160428 Still block check out button.
        If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then btnOrder.Enabled = False : lblMsg.Visible = True
    End Sub

    Protected Sub ibtnAvilability_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Page.Response.Redirect("~/Order/priceAndATP.aspx?PN=" & Me.txtPartNo.Text.Trim())
    End Sub

    'Ryan 20170410 Comment AJP zero ITP validation out.
    'Protected Sub AJPZeroITP()
    '    Dim type As Boolean = True
    '    Dim msg As String = ""
    '    ' check items with zero itp
    '    If isJPAonline Then
    '        Dim isZITP As New Dictionary(Of String, Boolean)
    '        isZITP = CheckITPZero(CartId)
    '        If isZITP.Count > 0 Then
    '            type = False
    '            msg = "Item(s): "
    '            For Each r As KeyValuePair(Of String, Boolean) In isZITP
    '                msg &= "'" & r.Key & "' "
    '            Next
    '            msg &= "is(are) with zero ITP, please remove them from cart to enable the confirm button."
    '        End If
    '    End If
    '    '/ check items with zero itp
    '    If Not String.IsNullOrEmpty(msg.Trim) Then
    '        ForbidConfirm(type, msg)
    '    Else
    '        btnOrder.Enabled = True
    '    End If
    'End Sub

    Sub initGV()
        Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(CartId)


        'Ryan 2016/06/27 Revise logic, get ABC indicator for ANA
        If isANA Then
            Dim sqlstr As String = "SELECT distinct a.Part_No, b.ABC_INDICATOR,c.PRODUCT_TYPE FROM cart_DETAIL_V2 a " &
                                " left join SAP_PRODUCT_ABC b on a.Part_No = b.PART_NO " &
                                " left join SAP_PRODUCT c on a.Part_No = c.PART_NO " &
                                " WHERE a.Cart_Id = '" & CartId & "'and b.PLANT='USH1'"
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sqlstr)
            If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                For Each dr As DataRow In dt.Rows
                    Dim _CartItemList As List(Of CartItem) = _cartlist.Where(Function(p) p.Part_No = dr.Item(0).ToString).ToList()
                    If _CartItemList.Count > 0 Then
                        For Each _CartItem As CartItem In _CartItemList
                            If Advantech.Myadvantech.Business.PartBusinessLogic.IsANANCNRParts(dr.Item("Part_No").ToString(),
                                dr.Item("ABC_INDICATOR").ToString(), dr.Item("PRODUCT_TYPE").ToString()) Then
                                _CartItem.Is_NCNR_Part = True
                            Else
                                _CartItem.Is_NCNR_Part = False
                            End If
                            _CartItem.ABC_Indicator = dr.Item(1).ToString
                        Next
                    End If
                Next
            End If
        End If

        'For Each _cartitem As CartItem In _cartlist
        '    If _cartitem.otype = CartItemType.BtosParent Then
        '        _cartitem.List_Price = _cartitem.ChildSubListPriceX
        '        _cartitem.Unit_Price = _cartitem.ChildSubUnitPriceX
        '    End If
        'Next
        'If mycart.isBtoOrder(CartId) And mycart.getTotalPrice_EW(CartId) > 0 Then
        '    Dim R As DataRow = dt.NewRow
        '    R.Item("line_No") = mycart.getMaxLineNo(CartId) + 1
        '    R.Item("category") = "Extended Warranty" : R.Item("Part_No") = Glob.getEWItemByMonth(dt.Rows(1).Item("ew_Flag"))
        '    R.Item("description") = "Extended Warranty" : R.Item("ew_Flag") = "0"
        '    R.Item("list_Price") = mycart.getTotalPrice_EW(CartId) : R.Item("unit_Price") = R.Item("list_Price")
        '    R.Item("qty") = dt.Rows(dt.Rows.Count - 1).Item("qty") : R.Item("req_Date") = Now.ToShortDateString
        '    R.Item("due_Date") = Now.ToShortDateString : R.Item("itp") = R.Item("list_Price")
        '    R.Item("otype") = 1 : dt.Rows.Add(R)
        '    R.Item("delivery_plant") = ""
        'End If
        Me.gv1.DataSource = _cartlist : Me.gv1.DataBind()
    End Sub

    Protected Sub gv_drpEW_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As DropDownList = CType(sender, DropDownList)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim _cartLineno As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim EW_id As Integer = obj.SelectedValue
        Dim _cartitem As CartItem = MyCartX.GetCartItem(CartId, _cartLineno)
        MyCartX.addExtendedWarrantyV2(_cartitem, EW_id)
        MyCartX.ReSetLineNo(CartId)
        'mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, ID), String.Format("ew_flag='{0}'", Month))
        initGV()
    End Sub
    Protected Sub btnDel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim f As Integer = 0
        For i As Integer = 0 To gv1.Rows.Count - 1
            Dim chk As CheckBox = gv1.Rows(i).FindControl("chkKey")
            If chk.Checked Then
                Dim oldLineNo As Integer = gv1.DataKeys(gv1.Rows(i).RowIndex).Value
                Dim _CartItem As CartItem = CType(gv1.Rows(i).DataItem, CartItem)
                MyCartX.DeleteCartItem(CartId, oldLineNo)
                'Dim oldLineNo As Integer = gv1.DataKeys(gv1.Rows(i).RowIndex).Value
                'If oldLineNo = 100 Then
                '    f = 1
                'End If
            End If
        Next
        MyCartX.ReSetLineNo(CartId)
        InitBtosParent()
        initGV()
        'If f = 0 Then
        '    del()
        'Else
        '    Me.MPConfigConfirm.Show()
        'End If
        '  upbtnConfirm.Update()
    End Sub
    'Protected Sub del()
    '    Dim count As Integer = 0
    '    For i As Integer = 0 To gv1.Rows.Count - 1
    '        Dim chk As CheckBox = gv1.Rows(i).FindControl("chkKey")
    '        If chk.Checked Then
    '            Dim oldLineNo As Integer = gv1.DataKeys(gv1.Rows(i).RowIndex).Value
    '            Dim newLineNo As Integer = oldLineNo - count
    '            mycart.Delete(String.Format("cart_id='{0}' and line_no='{1}'", CartId, newLineNo))
    '            mycart.reSetLineNoAfterDel(CartId, newLineNo)
    '            count = count + 1
    '        End If
    '    Next
    '    initGV()
    'End Sub
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        ' Dim currSin As String = Session("company_currency_sign")
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim _CartItem As CartItem = CType(e.Row.DataItem, CartItem)
            Dim line_no As Integer = _CartItem.Line_No ' CInt(CType(e.Row.FindControl("hdLineNo"), HiddenField).Value)
            Dim cbDel As CheckBox = e.Row.FindControl("chkKey")
            'If Session("org_id") <> "US01" Then
            'If _CartItem.otype = CartItemType.BtosPart Then
            '    If cbDel IsNot Nothing Then cbDel.Visible = False
            'End If
            Dim part_no As String = _CartItem.Part_No
            Dim lable_ListPrice As Label = CType(e.Row.FindControl("lbListPrice"), Label)
            Dim TextBox_UnitPrice As TextBox = CType(e.Row.FindControl("txtUnitPrice"), TextBox)
            Dim ListPice As Decimal = CDbl(lable_ListPrice.Text)
            Dim UnitPrice As Decimal = CDbl(TextBox_UnitPrice.Text)
            If IsInternalUser = False Then
                TextBox_UnitPrice.ReadOnly = True
            Else
                If AuthUtil.IsBBUS Then
                    TextBox_UnitPrice.ReadOnly = True
                    TextBox_UnitPrice.BackColor = System.Drawing.ColorTranslator.FromHtml("#eeeeee")
                    TextBox_UnitPrice.BorderWidth = 1
                    TextBox_UnitPrice.BorderColor = System.Drawing.ColorTranslator.FromHtml("#cccccc")
                Else
                    TextBox_UnitPrice.ReadOnly = False
                End If
            End If

            Dim qty As Decimal = CInt(CType(e.Row.FindControl("txtGVQty"), TextBox).Text)
            Dim Discount As Decimal = 0.0
            Dim SubTotal As Decimal = 0.0
            Dim ewPrice As Decimal = 0.0
            Dim DrpEW As DropDownList = CType(e.Row.FindControl("gv_drpEW"), DropDownList) : DrpEW.Items.Clear()
            If _CartItem.IsSpecialADAMX Then
                DrpEW.DataSource = _CartItem.SpecialADAM_EW
            Else
                DrpEW.DataSource = MyCartX.GetExtendedWarranty()
            End If
            DrpEW.DataBind()
            DrpEW.Items.Insert(0, New ListItem("without extended warranty", 0))
            DrpEW.ClearSelection()
            DrpEW.SelectedValue = _CartItem.Ew_Flag
            '  ewPrice = FormatNumber(Glob.getRateByEWItem(Glob.getEWItemByMonth(CInt(DrpEW.SelectedValue)), _CartItem.Delivery_Plant) * UnitPrice, 2)
            CType(e.Row.FindControl("gv_lbEW"), TextBox).Text = ewPrice
            If ListPice = 0 AndAlso _CartItem.ItemTypeX <> CartItemType.BtosParent Then
                e.Row.Cells(9).Text = "TBD"
                e.Row.Cells(11).Text = "TBD"
            Else
                If ListPice > 0 Then
                    Discount = FormatNumber((ListPice - UnitPrice) / ListPice, 2)
                    e.Row.Cells(11).Text = Discount * 100 & "%"
                End If
            End If
            SubTotal = FormatNumber(qty * (UnitPrice), 2)
            e.Row.Cells(15).Text = CurrencySign & SubTotal
            'If Integer.Parse(DBITEM.Item("Line_No").ToString) >= 100 Then
            '    e.Row.Cells(6).Text = ""
            'End If
            If _CartItem.ItemTypeX = CartItemType.BtosParent Then
                e.Row.BackColor = Drawing.Color.LightYellow
                e.Row.Cells(1).Text = "" : e.Row.Cells(3).Text = "" : e.Row.Cells(5).Text = "" 'e.Row.Cells(6).Text = ""
                e.Row.Cells(7).Text = "" : e.Row.Cells(8).Text = "" : e.Row.Cells(9).Text = "" ': e.Row.Cells(10).Text = ""
                e.Row.Cells(11).Text = "" ': e.Row.Cells(13).Text = "" 'e.Row.Cells(14).Text = ""
                e.Row.Cells(15).Text = "" ': e.Row.Cells(16).Text = ""
                If lable_ListPrice IsNot Nothing Then lable_ListPrice.Text = _CartItem.ChildSubListPriceX
                If TextBox_UnitPrice IsNot Nothing Then
                    TextBox_UnitPrice.Text = FormatNumber(_CartItem.ChildSubUnitPriceX / _CartItem.Qty, 2)
                    TextBox_UnitPrice.Enabled = False
                    e.Row.Cells(15).Text = CurrencySign & FormatNumber(_CartItem.ChildSubUnitPriceX, 2)
                End If
                'Ryan 20160427 If is NoEWParts, DrpEW will disable.
                If Advantech.Myadvantech.Business.PartBusinessLogic.IsNoEWParts(part_no) Then
                    If DrpEW IsNot Nothing Then DrpEW.Enabled = False
                End If

                If Session("org_id") = "JP01" Then
                    e.Row.Cells(18).Text = ""
                End If
            End If

            If _CartItem.otype = CartItemType.BtosPart Then
                If DrpEW IsNot Nothing Then DrpEW.Enabled = False
                'If Not isANA AndAlso Not MyCartOrderBizDAL.isODMCart(CartId) Then
                '    CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
                'End If
                '20150715 Ming在Cart頁面的子階數量，只對歐洲鎖定無法改動
                Dim TBqty As TextBox = CType(e.Row.FindControl("txtGVQty"), TextBox)
                If TBqty IsNot Nothing Then
                    If String.Equals(Session("org_id"), "EU10") Then
                        TBqty.Enabled = False
                        '20150715 Ming只有欧洲才进行ODM的判断
                        If MyCartOrderBizDAL.isODMCart(CartId) Then
                            TBqty.Enabled = True
                        End If
                    Else
                        TBqty.Enabled = True
                    End If
                End If
            End If
            If _CartItem.IsEWpartnoX Then
                e.Row.Cells(0).Text = "" : e.Row.Cells(1).Text = ""
                CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = False
                CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
                e.Row.Cells(6).Text = ""
                'If cbDel IsNot Nothing Then cbDel.Visible = False
            End If
            'Ming20141110      Disable the price edit function for all IMG-XXXXX part numbers  ,	Disable adding an extended warranty option for below product lines
            If Not SAPDAL.CommonLogic.isAllowedChangePrice(_CartItem.Part_No, Session("org_id")) Then
                TextBox_UnitPrice.Enabled = False
            End If
            If _CartItem.ItemTypeX = CartItemType.Part AndAlso Not SAPDAL.CommonLogic.isAllowedAddEW(_CartItem.Part_No, "", Session("org_id")) Then
                e.Row.Cells(6).Text = ""
            End If
            If part_no.ToLower.StartsWith("ags-ctos-", StringComparison.CurrentCultureIgnoreCase) Then
                CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = False
                CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
                If String.Equals(Session("org_id"), "EU10") Then
                    e.Row.Cells(0).Text = ""
                End If

                'Ryan 20170519 AJP OP & IS are allowed to modify AGS-CTOS- items price
                If Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                    If MailUtil.IsInMailGroup("AJP_IS", Session("user_id").ToString) OrElse MailUtil.IsInMailGroup("ajp_callcenter", Session("user_id").ToString) OrElse Util.IsMyAdvantechIT() Then
                        CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = True
                    End If
                End If
            End If

            'Ryan 2016/06/27 Revise logic, show ABC indicator anyway if user is ANA
            'Ryan 2016/01/20 Check added item is CDTPXY part or not. If so then highlight it and show its ABC indicator. 
            If isANA Then
                e.Row.Cells(17).Visible = True
                e.Row.Cells(17).Text = _CartItem.ABC_Indicator
                If isFeiOffice AndAlso isRiskOrder Then
                    If _CartItem.Is_NCNR_Part Then
                        e.Row.BackColor = Drawing.Color.FromName("#FFFF77")
                    End If
                End If
            End If

            'Ryan 20170808 Disable qty textbox if is EU external quote2cart order
            'If Session("org_id").ToString.ToUpper.Equals("EU10") AndAlso Not IsInternalUser AndAlso Not String.IsNullOrEmpty(_CartItem.QUOTE_ID) Then
            '    CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
            'End If

        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            If MyCartX.IsHaveBtos(CartId) Then
                e.Row.Cells(3).Visible = False
            End If
            e.Row.Cells(7).Visible = False : e.Row.Cells(8).Visible = False
            If Session("Org_id") = "US01" Then
                If Not String.Equals(Session("user_id"), "ming.zhao@advantech.com.cn") Then
                    e.Row.Cells(13).Visible = False
                End If
            End If

            'Ryan 20161215 Hide ABC indicator column if is not US users.
            If Not isANA Then
                e.Row.Cells(17).Visible = False
            End If

            'Ryan 20171030 Hide extended warranty drop down for BBUS
            If AuthUtil.IsBBUS Then
                e.Row.Cells(6).Visible = False
                e.Row.Cells(13).Visible = False
            End If

            If Session("org_id") = "JP01" Then
                e.Row.Cells(3).Visible = False
                e.Row.Cells(16).Visible = False
            Else
                e.Row.Cells(18).Visible = False
            End If
        End If

    End Sub

    Protected Sub txtCustPN_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim id As Integer = Me.gv1.DataKeys(CType(obj.NamingContainer, GridViewRow).RowIndex).Value
        Dim orgiMaterial As String = CType(Me.gv1.Rows(CType(obj.NamingContainer, GridViewRow).RowIndex).FindControl("hlPartNo"), HyperLink).Text.Trim
        Dim _cartitem As List(Of CartItem) = MyCartX.GetCartList(CartId)
        If _cartitem IsNot Nothing Then
            For Each R As CartItem In _cartitem
                If R.Part_No = orgiMaterial Then
                    R.CustMaterial = obj.Text.Trim
                End If
            Next
        End If
        MyUtil.Current.MyAContext.SubmitChanges()
        ' initGV()
        Dim custMaterial As New Cust_MaterialMapping
        custMaterial.CustomerId = Session("Company_ID")
        custMaterial.MaterialNo = orgiMaterial
        custMaterial.CreatedOn = Now.ToShortDateString
        custMaterial.CreatedBy = Session("user_id")
        custMaterial.CustMaterialNo = obj.Text.Trim

        Dim CM As New CustMaterialDataContext
        Dim TM As Cust_MaterialMapping = CM.Cust_MaterialMappings.SingleOrDefault(Function(X As Cust_MaterialMapping) X.CustomerId = custMaterial.CustomerId AndAlso X.MaterialNo = orgiMaterial)
        If Not IsNothing(TM) Then
            CM.Cust_MaterialMappings.DeleteOnSubmit(TM)
        End If
        CM.Cust_MaterialMappings.InsertOnSubmit(custMaterial)
        CM.SubmitChanges()

    End Sub

    Private Function IsLoseGPPartNo(ByVal partno As String) As Boolean
        If Not String.IsNullOrEmpty(partno) Then
            partno = partno.ToUpper.Trim
            Dim PartNoList As New ArrayList
            With PartNoList
                .Add("X-CERTIFICATE-1")
            End With
            If PartNoList.Contains(partno) Then
                Return True
            End If
        End If
        Return False
    End Function
    Protected Sub txtUnitPrice_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        LabWarn.Text = ""
        If Util.IsInternalUser(Session("user_id")) = False Then
            If Not isACNUser Then
                Exit Sub
            End If
        End If
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        'Dim PartNO As String = CType(row.FindControl("LabPartNo"), Label).Text
        Dim UnitPrice As String = obj.Text
        Dim PartNO As String = CType(row.FindControl("hlPartNo"), HyperLink).Text
        If Session("org_id") = "US01" AndAlso Not IsLoseGPPartNo(PartNO) Then
            Dim decGPPercentage As Decimal = -1
            Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id")), distr_chan As String = "10", division As String = "00"
            SAPDOC.Get_disChannel_and_division(Session("company_id"), distr_chan, division)
            If String.Equals(Session("company_id").ToString, "UEPP5001") Then division = "20"
            If OrderUtilities.isANAPnBelowGP(PartNO, UnitPrice, decGPPercentage) Then
                LabWarn.Text = "Item " + PartNO + " is below GP Price(" & FormatNumber(decGPPercentage, 2).ToString() & ")"
                LabWarn.Visible = True
                Exit Sub
            End If
        End If
        '  mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, id), String.Format("Unit_Price='{0}'", UnitPrice))
        Dim _cartitem As CartItem = MyCartX.GetCartItem(CartId, id)

        'Frank 2013/10/02: Unit Price of BTOS parent item cannot be updated, it should always be 0 in cart_detail
        'If _cartitem IsNot Nothing Then
        If _cartitem IsNot Nothing AndAlso _cartitem.ItemTypeX <> CartItemType.BtosParent Then
            _cartitem.Unit_Price = Decimal.Parse(UnitPrice)
            MyUtil.Current.MyAContext.SubmitChanges()
            If _cartitem.otype = CartItemType.BtosPart Then
                Dim items As List(Of CartItem) = MyCartX.GetCartList(CartId).Where(Function(p) p.higherLevel = _cartitem.higherLevel).ToList()
                Dim EWitem As CartItem = Nothing
                For Each i As CartItem In items
                    If i.IsEWpartnoX Then
                        EWitem = i : Exit For
                    End If
                Next
                If EWitem IsNot Nothing Then
                    Dim BtosParent As CartItem = MyCartX.GetCartItem(_cartitem.Cart_Id, EWitem.higherLevel)
                    If BtosParent IsNot Nothing Then
                        EWitem.Unit_Price = BtosParent.ChildExtendedWarrantyPriceX
                        EWitem.List_Price = EWitem.Unit_Price
                        MyUtil.Current.MyAContext.SubmitChanges()
                    End If

                End If
            Else
                Dim _EWcartitem As CartItem = MyCartX.GetCartItem(CartId, id + 1)
                'Ming 20151103 fixed bug:  System.NullReferenceException.
                If _EWcartitem IsNot Nothing AndAlso _EWcartitem.IsEWpartnoX Then
                    _EWcartitem.List_Price = _cartitem.EWpartnoX.EW_Rate * _cartitem.Unit_Price
                    _EWcartitem.Unit_Price = _EWcartitem.List_Price
                End If
            End If
        End If
        MyUtil.Current.MyAContext.SubmitChanges()
        ' initGV()
    End Sub


    Protected Sub txtGVQty_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim Qty As String = obj.Text
        Dim _intvalue As Integer = 0
        'Frank 20150424 If qty is Less then 1, then do not save 0 qty to cart_detail
        If Not Integer.TryParse(Qty, _intvalue) Then Exit Sub
        If _intvalue < 1 Then Exit Sub

        Dim _cartitem As CartItem = MyCartX.GetCartItem(CartId, id)
        If _cartitem IsNot Nothing Then

            If _cartitem.otype = CartItemType.BtosParent Then
                Dim _cartlistBtosChild As List(Of CartItem) = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.higherLevel = id AndAlso p.Cart_Id = CartId).OrderBy(Function(p) p.Line_No).ToList()
                For Each _cartline As CartItem In _cartlistBtosChild
                    _cartline.Qty = _cartline.Qty / _cartitem.Qty * Qty
                Next
            Else
                If _cartitem.Ew_Flag > 0 Then
                    If _cartitem.otype = CartItemType.BtosPart Then
                        Dim items As List(Of CartItem) = MyCartX.GetCartList(CartId).Where(Function(p) p.higherLevel = _cartitem.higherLevel).ToList()
                        Dim EWitem As CartItem = Nothing
                        For Each i As CartItem In items
                            If i.IsEWpartnoX Then
                                EWitem = i : Exit For
                            End If
                        Next
                        If EWitem IsNot Nothing Then
                            _cartitem.Qty = Qty
                            MyUtil.Current.MyAContext.SubmitChanges()
                            Dim BtosParent As CartItem = MyCartX.GetCartItem(_cartitem.Cart_Id, EWitem.higherLevel)
                            If BtosParent IsNot Nothing Then
                                EWitem.Unit_Price = BtosParent.ChildExtendedWarrantyPriceX
                                EWitem.List_Price = EWitem.Unit_Price
                                MyUtil.Current.MyAContext.SubmitChanges()
                            End If

                        End If
                    Else
                        Dim _EWcartitem As CartItem = MyCartX.GetCartItem(CartId, id + 1)
                        _EWcartitem.Qty = Qty
                    End If

                End If
                MyCartX.ResetDueDate(_cartitem)
            End If
            _cartitem.Qty = Qty
            MyUtil.Current.MyAContext.SubmitChanges()
        End If
        '  initGV()
    End Sub

    Protected Sub txtreqdate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim req_date As Date = CDate(obj.Text)
        Dim _cartitem As CartItem = MyCartX.GetCartItem(CartId, id)
        If _cartitem IsNot Nothing Then
            _cartitem.req_date = req_date
            MyCartX.ResetDueDate(_cartitem)
        End If
        MyUtil.Current.MyAContext.SubmitChanges()
    End Sub

    'Sub ReCalDue(ByVal cart_id As String, ByVal line_no As String)
    '    Dim dt As DataTable = mycart.GetDT(String.Format("cart_id='{0}' and line_no='{1}'", CartId, line_no), "")
    '    If dt.Rows.Count = 1 Then
    '        Dim part_no As String = dt.Rows(0).Item("part_no"), plant As String = dt.Rows(0).Item("delivery_plant")
    '        Dim qty As String = dt.Rows(0).Item("qty"), req_date As String = dt.Rows(0).Item("req_date")
    '        Dim duedate As String = "", inventory As Integer = 0, satisflag As Integer = 0, qtyCanbeConfirmed As Integer = 0
    '        SAPtools.getInventoryAndATPTable(dt.Rows(0).Item("part_no"), dt.Rows(0).Item("delivery_plant"), dt.Rows(0).Item("qty"), duedate, inventory, New DataTable, req_date, satisflag, qtyCanbeConfirmed)
    '        mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, line_no), String.Format("due_date='{0}',inventory='{1}',SatisfyFlag='{2}',CanbeConfirmed='{3}'", duedate, inventory, satisflag, qtyCanbeConfirmed))
    '    End If
    'End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        initGV()
        Me.gv1.DataBind()
    End Sub

    Protected Sub ibSave_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim CHNO As String = myCartHistory.SaveCartHistory(Util.ReplaceSQLStringFunc(Me.txtCartDesc.Text.Trim), 0)
        Response.Redirect("~/Order/CartHistory_List.aspx")
    End Sub

    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        If Not MyCartX.IsHaveItems(CartId) Then
            'Glob.ShowInfo("Please add part number to cart first.")
            ForbidConfirm(False, "Please add part number to cart first.")
            Exit Sub
        End If

        'Ryan 20170815 Check if has zero price items for ACN
        If isACNUser Then
            Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(CartId)
            If _cartlist.Count > 0 AndAlso _cartlist.Where(Function(p) p.otype <> Convert.ToInt32(CartItemType.BtosParent) AndAlso p.Unit_Price = 0).ToList.Count > 0 Then
                ForbidConfirm(True, "Zero price is not allowed, please check item price again.")
                Exit Sub
            End If

            If _cartlist.Count > 0 Then
                For Each c As CartItem In _cartlist
                    Dim count As Integer = Convert.ToInt32(dbUtil.dbExecuteScalar("MY", "select count(*) as c from SAP_PRODUCT_STATUS_ORDERABLE Where PART_NO='" + c.Part_No + "' and SALES_ORG='" + Session("org_id") + "' and PRODUCT_STATUS <> 'O' "))
                    If count = 0 Then
                        ForbidConfirm(True, "Error in item " + c.Part_No + ", status is not orderable.")
                        Exit Sub
                    End If
                Next
            End If
        End If


        'Ryan 20171225 AJP companies with CLA signed, should place 968T parts instead of 968Q
        If Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
            Dim SAP968Q_CartList As List(Of CartItem) = MyCartX.GetCartList(CartId).Where(Function(p) p.Part_No.StartsWith("968Q")).ToList()
            If SAP968Q_CartList.Count > 0 Then
                Dim strSql As String = String.Format("select * from saprdp.ZTSD_106A where vkorg = '{0}' and KUNNR= '{1}' and '{2}' between BDATE and EDATE", Session("org_id"), Session("company_id"), DateTime.Now.ToString("yyyyMMdd"))
                Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", strSql)
                If dt.Rows.Count > 0 Then
                    ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "alert(""Due to MS licenses policy please place 968T- parts instead of 968Q- parts."");", True)
                    ForbidConfirm(True, "Due to MS licenses policy please place 968T- parts instead of 968Q- parts.")
                    Exit Sub
                End If
            End If
        End If

        'Ryan 20160324 If any part in cart starts with "968T" and ERPID maintained in saprdp.ZTSD_106C, than disable check out
        Dim SAP968T_CartList As List(Of CartItem) = MyCartX.GetCartList(CartId).Where(Function(p) p.Part_No.StartsWith("968T")).ToList()
        If SAP968T_CartList.Count > 0 Then
            Dim strSql As String = "select * from saprdp.ZTSD_106C where KUNNR = '" & Session("company_id").ToString() & "'"
            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", strSql)
            If dt.Rows.Count > 0 Then
                ForbidConfirm(True, "Due to MS licenses policy it is not allowed to order part numbers start with 968T.")
                Exit Sub
            End If
        End If

        '20140122 检测BtosParent下面是否有料号
        '20170706 Check compatibility for every BTOS
        Dim CurrentCartList As List(Of CartItem) = MyCartX.GetCartList(CartId)
        Dim SB As New StringBuilder
        For Each _cartitem As CartItem In CurrentCartList
            If _cartitem.ItemTypeX = CartItemType.BtosParent Then
                If _cartitem.ChildListX Is Nothing Then
                    SB.AppendFormat("There is no component under {0} <br/>", _cartitem.Part_No)
                ElseIf Session("org_id").ToString.StartsWith("CN") Then 'ICC 20170728 Compatibility check only for CN order
                    Dim partNos = _cartitem.ChildListX.Select(Function(p) p.Part_No).ToList()
                    Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.Business.PartBusinessLogic.CheckCompatibility(partNos, Advantech.Myadvantech.DataAccess.Compatibility.Incompatible)
                    If result.Item1 = True Then
                        SB.AppendFormat("{0} <br />", result.Item2)
                        Exit For
                    End If
                ElseIf Session("org_id").ToString.StartsWith("TW") Then 'ICC 20171102 Add compatibility check for TW order
                    Dim partNos = _cartitem.ChildListX.Select(Function(p) p.Part_No).ToList()
                    Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.Business.PartBusinessLogic.CheckCompatibilityTW(partNos, Advantech.Myadvantech.DataAccess.Compatibility.Incompatible)
                    If result.Item1 = True Then
                        SB.AppendFormat("{0} <br />", result.Item2)
                        Exit For
                    End If
                End If
            End If
        Next
        If Not String.IsNullOrEmpty(SB.ToString.Trim) Then
            'Glob.ShowInfo(SB.ToString.Trim)
            ForbidConfirm(False, SB.ToString.Trim)
            Exit Sub
        End If
        'end
        If Not String.IsNullOrEmpty(HFisquote2cart.Value) Then
            mycart.Update(String.Format("cart_id='{0}'", CartId), String.Format("Quote_id='{0}'", HFisquote2cart.Value))
        End If
        'ICC 2015/4/28 Update CARTMASTERV2 amount
        Dim amount As Integer = FormatNumber(dbUtil.dbExecuteScalar("MY", String.Format(" select ISNULL(SUM(Unit_Price * Qty), 0) from CART_DETAIL_V2 where Cart_Id = '{0}' ", CartId)))
        dbUtil.dbExecuteNoQuery("MY", String.Format(" update CARTMASTERV2 set OpportunityAmount = {0} where CartID = '{1}' ", amount, CartId))

        'Ryan 20151222 redirect with index while page is called from Check-Point convert2order
        If (Not String.IsNullOrEmpty(CheckPoint_Convert2Order)) AndAlso (CheckPoint_Convert2Order = HttpContext.Current.Session("cart_id")) Then
            Response.Redirect(String.Format("~/Order/OrderInfoV2.aspx?CheckPoint_Convert2Order={0}", CheckPoint_Convert2Order))
        End If

        'Ryan 20161005 Add items validation to MS items like 206Q- for EU10
        If Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
            Dim LoosePartsList As List(Of String) = CurrentCartList.Where(Function(p) p.Line_No < 100).Select(Function(p) p.Part_No).ToList
            Dim invalidSWparts As List(Of String) = Advantech.Myadvantech.Business.PartBusinessLogic.isMSSWParts(LoosePartsList, Session("org_id").ToString)
            If invalidSWparts.Count > 0 Then
                lbConfirmMsg.Text = "Invalid PN : " & String.Join(", ", invalidSWparts.ToArray()) + ", Software items can only be added under a BTOS/CTOS."
                Exit Sub
            End If
        End If

        Response.Redirect("~/Order/OrderInfo.aspx")
    End Sub

    Protected Sub ibtnSeqUp_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim line_no As Integer = Integer.Parse(obj.CommandName)
        Dim id As Integer = Integer.Parse(obj.CommandArgument)
        MyCartX.UpOrDownLineNo(CartId, line_no, "up")
        initGV()
    End Sub

    Protected Sub ibtnSeqDown_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim line_no As Integer = obj.CommandName
        Dim id As Integer = Integer.Parse(obj.CommandArgument)
        MyCartX.UpOrDownLineNo(CartId, line_no, "down")
        initGV()
    End Sub

    Protected Sub imgXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim TB As New DataTable
        TB.Columns.Add("LINE_NO") : TB.Columns.Add("PRODUCT_LINE") : TB.Columns.Add("PART_NO") : TB.Columns.Add("Description")
        TB.Columns.Add("QTY") : TB.Columns.Add("LIST_PRICE", GetType(Decimal)) : TB.Columns.Add("UNIT_PRICE", GetType(Decimal)) : TB.Columns.Add("Discount")
        TB.Columns.Add("REQUIRED_DATE") : TB.Columns.Add("DUE_DATE") : TB.Columns.Add("CustMaterialNo") : TB.Columns.Add("DeliveryPlant")

        Dim DT As DataTable = mycart.GetDT(String.Format("cart_id='{0}'", CartId), "line_no")
        If Not IsNothing(DT) AndAlso DT.Rows.Count > 0 Then
            If DT.Rows.Count > 0 Then
                Dim dtEW As New DataTable
                dtEW.Columns.Add("Line_No") : dtEW.Columns.Add("Part_No") : dtEW.Columns.Add("Description")
                dtEW.Columns.Add("otype") : dtEW.Columns.Add("qty") : dtEW.Columns.Add("req_date")
                dtEW.Columns.Add("due_date") : dtEW.Columns.Add("islinePartial") : dtEW.Columns.Add("UNIT_PRICE", GetType(Decimal))
                dtEW.Columns.Add("delivery_plant") : dtEW.Columns.Add("DMF_Flag") : dtEW.Columns.Add("OptyID")

                Dim count As Integer = 0
                For Each r As DataRow In DT.Rows
                    Dim LINE_NO As Integer = r.Item("line_no"), PRODUCT_LINE As String = "", PART_NO As String = r.Item("part_no")
                    Dim ORDER_LINE_TYPE As String = If(IsDBNull(r.Item("otype")), "", r.Item("otype")), QTY As Integer = r.Item("qty"), LIST_PRICE As Decimal = r.Item("list_price")
                    Dim UNIT_PRICE As Decimal = r.Item("unit_price"), REQUIRED_DATE As Date = r.Item("req_date"), DUE_DATE As Date = r.Item("due_date")
                    Dim ERP_SITE As String = "", ERP_LOCATION As String = "", AUTO_ORDER_FLAG As Char = ""
                    Dim AUTO_ORDER_QTY As Integer = 0, SUPPLIER_DUE_DATE As Date = DUE_DATE, LINE_PARTIAL_FLAG As Integer = 0
                    Dim RoHS_FLAG As String = String.Empty
                    If Not IsDBNull(r.Item("rohs")) Then
                        RoHS_FLAG = r.Item("rohs")
                    End If
                    Dim EXWARRANTY_FLAG As String = r.Item("ew_flag")
                    Dim CustMaterialNo As String = r.Item("custMaterial"), DeliveryPlant As String = r.Item("delivery_plant")
                    Dim NoATPFlag As String = r.Item("satisfyflag"), DMF_Flag As String = ""
                    Dim OptyID As String = String.Empty
                    If Not IsDBNull(r.Item("QUOTE_ID")) Then
                        OptyID = r.Item("QUOTE_ID")
                    End If
                    Dim RTB As DataRow = TB.NewRow

                    RTB.Item("LINE_NO") = LINE_NO : RTB.Item("PRODUCT_LINE") = PRODUCT_LINE : RTB.Item("PART_NO") = PART_NO
                    RTB.Item("Description") = r.Item("Description") : RTB.Item("QTY") = QTY
                    RTB.Item("LIST_PRICE") = LIST_PRICE : RTB.Item("UNIT_PRICE") = UNIT_PRICE
                    If LIST_PRICE <> 0 Then
                        RTB.Item("Discount") = FormatNumber(((LIST_PRICE - UNIT_PRICE) / LIST_PRICE) * 100, 2) & "%"
                    Else
                        RTB.Item("Discount") = "N/A"
                    End If
                    RTB.Item("REQUIRED_DATE") = REQUIRED_DATE : RTB.Item("DUE_DATE") = DUE_DATE
                    RTB.Item("CustMaterialNo") = CustMaterialNo : RTB.Item("DeliveryPlant") = DeliveryPlant

                    TB.Rows.Add(RTB)

                    'If CInt(EXWARRANTY_FLAG) > 0 Then
                    '    count = count + 1
                    '    If ORDER_LINE_TYPE <> -1 Then
                    '        Dim EWR As DataRow = dtEW.NewRow
                    '        With EWR
                    '            .Item("line_no") = LINE_NO + count : .Item("part_no") = Glob.getEWItemByMonth(EXWARRANTY_FLAG)
                    '            .Item("Description") = Glob.getEWItemByMonth(EXWARRANTY_FLAG) + " For " + PART_NO
                    '            .Item("otype") = ORDER_LINE_TYPE : .Item("qty") = QTY
                    '            .Item("req_date") = REQUIRED_DATE : .Item("due_date") = DUE_DATE
                    '            .Item("islinePartial") = LINE_PARTIAL_FLAG
                    '            .Item("unit_price") = Glob.getRateByEWItem(Glob.getEWItemByMonth(EXWARRANTY_FLAG), DeliveryPlant) * UNIT_PRICE
                    '            .Item("delivery_plant") = DeliveryPlant : .Item("DMF_Flag") = DMF_Flag : .Item("OptyID") = OptyID
                    '        End With
                    '        dtEW.Rows.Add(EWR)
                    '    End If
                    'End If
                Next
                'If dtEW.Rows.Count > 0 Then
                '    If mycart.isBtoOrder(CartId) Then
                '        Dim Line_no As Integer = mycart.getMaxLineNo(CartId) + 1
                '        Dim part_no As String = dtEW.Rows(0).Item("part_no")
                '        Dim otype As Integer = dtEW.Rows(0).Item("otype")
                '        Dim qty As Integer = dtEW.Rows(0).Item("qty")
                '        Dim req_date As DateTime = mycart.getMaxReqDate(CartId)
                '        Dim due_date As DateTime = mycart.getMaxDueDate(CartId)
                '        Dim linePartialFlag As Integer = dtEW.Rows(0).Item("islinePartial")
                '        Dim unit_Price As Decimal = dtEW.Compute("sum(unit_price)", "")
                '        Dim delivery_plant As String = dtEW.Rows(0).Item("delivery_plant")
                '        Dim dmf_flag As String = dtEW.Rows(0).Item("DMF_Flag")
                '        Dim optyid As String = dtEW.Rows(0).Item("OptyID")
                '        Dim RTB As DataRow = TB.NewRow

                '        RTB.Item("LINE_NO") = Line_no
                '        RTB.Item("PRODUCT_LINE") = ""
                '        RTB.Item("PART_NO") = part_no
                '        RTB.Item("Description") = dtEW.Rows(0).Item("Description")
                '        RTB.Item("QTY") = qty
                '        RTB.Item("LIST_PRICE") = unit_Price
                '        RTB.Item("UNIT_PRICE") = unit_Price
                '        RTB.Item("Discount") = "0"
                '        RTB.Item("REQUIRED_DATE") = req_date
                '        RTB.Item("DUE_DATE") = due_date
                '        RTB.Item("CustMaterialNo") = ""
                '        RTB.Item("DeliveryPlant") = delivery_plant

                '        TB.Rows.Add(RTB)
                '        'myOrderDetail.Add(ORDER_ID, Line_no, "", part_no, otype, qty, unit_Price, unit_Price, req_date, due_date, "", "", "", 0, due_date, linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid)
                '    Else
                '        Dim MlineNo As Integer = mycart.getMaxLineNo(CartId)
                '        Dim N As Integer = 0
                '        For Each r As DataRow In dtEW.Rows
                '            N = N + 1
                '            Dim line_no As Integer = MlineNo + N, part_no As String = r.Item("part_no"), otype As Integer = r.Item("otype")
                '            Dim qty As Integer = r.Item("qty"), req_date As DateTime = r.Item("req_date"), due_date As DateTime = r.Item("due_date")
                '            Dim linePartialFlag As Integer = r.Item("islinePartial"), unit_price As Decimal = r.Item("unit_price")
                '            Dim delivery_plant As String = r.Item("delivery_plant"), dmf_flag As String = r.Item("DMF_Flag")
                '            Dim optyid As String = r.Item("OptyID"), RTB As DataRow = TB.NewRow
                '            With RTB
                '                .Item("LINE_NO") = line_no : .Item("PRODUCT_LINE") = "" : .Item("PART_NO") = part_no
                '                .Item("Description") = r.Item("Description") : .Item("QTY") = qty : .Item("LIST_PRICE") = unit_price
                '                .Item("UNIT_PRICE") = unit_price : .Item("Discount") = "0" : .Item("REQUIRED_DATE") = req_date
                '                .Item("DUE_DATE") = due_date : .Item("CustMaterialNo") = "" : .Item("DeliveryPlant") = delivery_plant
                '            End With

                '            TB.Rows.Add(RTB)
                '        Next
                '    End If
                'End If
            End If

            Util.DataTable2ExcelDownload(TB, "MyCart.xls")
        End If
    End Sub

    Protected Sub lbtnCartHistory_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/Order/CartHistory_list.aspx")
    End Sub


    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim sAmt As Decimal = mycart.getTotalAmount(CartId)
        'Dim ewAmt As Decimal = mycart.getTotalAmount_EW(CartId)

        Me.lbtotal.Text = FormatNumber(MyCartX.GetTotalAmount(CartId), 2)

        If Session("org_id") = "JP01" Then
            Me.lbITP.Text = FormatNumber(MyCartX.GetTotalITP(CartId), 2)
            Me.lbMargin.Text = FormatNumber(MyCartX.GetTotalMargin(CartId) * 100, 2) + "%"
        End If
    End Sub

    Private Sub Source_path()
        Dim DT As DataTable = mycart.GetDT(String.Format("CART_ID='{0}' AND OTYPE='-1'", CartId), "")

        If DT.Rows.Count > 0 Then
            Dim strhtml As String = ""

            If Request("UID") IsNot Nothing AndAlso Trim(Request("UID")) <> "" Then
                strhtml = "<font color='Navy'>■</font>&nbsp;&nbsp;<a href='../eQuotation/QuotationDetail.aspx?UID=" + Trim(Request("UID")) + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>Quotation Detail</a><b>&nbsp;&nbsp;>&nbsp;&nbsp;</b>" +
                "<a href='./btos_portal.aspx?UID=" + Trim(Request("UID")) + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>BTOS/CTOS Portal</a> <b>&nbsp;&nbsp;>&nbsp;&nbsp;</b>" +
                "<a href='./CBOM_List.aspx?Catalog_Type=" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "&UID=" + Trim(Request("UID")) + "&SPR=' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "</a> <b>&nbsp;&nbsp;>&nbsp;&nbsp;</b>" +
                "<a href='./Configurator.aspx?BTOITEM=" + Trim(DT.Rows(0).Item("PART_NO")) + "&QTY=" + Trim(DT.Rows(0).Item("QTY")) + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + Trim(DT.Rows(0).Item("PART_NO")) + "</a>"

            Else
                strhtml = "<font color='Navy'>■</font>&nbsp;&nbsp;<a href='./btos_portal.aspx' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>System Configuration/Ordering Portal</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>" +
                 "<a href='./CBOM_List.aspx?Catalog_Type=" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "' target='_self' style='color:Navy;font-weight:bold;text-decoration:none;'>" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>" +
                 "<a href='./Configurator.aspx?BTOITEM=" + Trim(DT.Rows(0).Item("PART_NO")) + "&QTY=" + Trim(DT.Rows(0).Item("QTY")) + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + Trim(DT.Rows(0).Item("PART_NO")) + "</a>"
            End If

            page_path.InnerHtml = strhtml
        End If
    End Sub

    Private Shared Function get_catalog_type(ByVal name As String) As String
        Dim catalog_name As String = ""

        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "select catalog_type from CBOM_CATALOG where Catalog_org='" & HttpContext.Current.Session("Org").ToString.ToUpper & "' and CATALOG_NAME = '" + name + "'")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "select catalog_type from CBOM_CATALOG where Catalog_org='" & Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2) & "' and CATALOG_NAME = '" + name + "'")

        If dt.Rows.Count > 0 Then
            If Not Convert.IsDBNull(dt.Rows(0).Item("catalog_type")) Then
                catalog_name = dt.Rows(0).Item("catalog_type").ToString.Trim
            End If
        End If
        Return catalog_name
    End Function

    Protected Sub btnConfigConfirm_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        mycart.Delete(String.Format("cart_id='{0}'", CartId))
        Me.MPConfigConfirm.Hide()
        initGV()
    End Sub

    'Ryan 20170410 Comment AJP zero ITP validation out.
    'Public Function CheckITPZero(ByVal UID As String) As Dictionary(Of String, Boolean)
    '    Dim o As New Dictionary(Of String, Boolean)
    '    Dim dt As New DataTable
    '    dt = mycart.GetDT(String.Format("cart_id='{0}'", CartId), "line_no")
    '    If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
    '        For Each r As DataRow In dt.Rows

    '            If isJPAonline Then
    '                ' Type DIEN (Service parts without delivery) parts can be excluded from zero ITP check.
    '                Dim itemgroup As Object = dbUtil.dbExecuteScalar("MY", String.Format("select GENITEMCATGRP from SAP_PRODUCT where PART_NO = '{0}' ", r.Item("part_no")))
    '                If Not itemgroup Is Nothing AndAlso Not IsDBNull(itemgroup) AndAlso itemgroup.ToString.ToUpper.Equals("DIEN") Then
    '                    Continue For
    '                End If
    '            End If

    '            If Not r.Item("itp") Is Nothing AndAlso Not IsDBNull(r.Item("itp")) AndAlso r.Item("itp") = 0 Then
    '                If r.Item("otype") <> -1 AndAlso (SAPDAL.CommonLogic.NoStandardSensitiveITP(r.Item("part_no")) = False) Then
    '                    If Not o.ContainsKey(r.Item("part_no")) Then
    '                        o.Add(r.Item("part_No"), True)
    '                    End If
    '                End If
    '            End If
    '        Next
    '    End If
    '    Return o
    'End Function

    Public Sub ForbidConfirm(ByVal type As Boolean, ByVal msg As String)
        Me.btnOrder.Enabled = type : Me.lbConfirmMsg.Text = msg : upbtnConfirm.Update()
    End Sub
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function CheckIfReconfigurable() As String
        Dim apt As New SqlClient.SqlDataAdapter(
            " select top 1 a.ROW_ID  " +
            " from eQuotation.dbo.CTOS_CONFIG_LOG a inner join MyAdvantechGlobal.dbo.CART_DETAIL b  " +
            " on a.CART_ID=b.Cart_Id and a.ROOT_CATEGORY_ID=b.Part_No  " +
            " where a.CART_ID=@CID and b.Line_No=100 and a.USERID=@UID and a.COMPANY_ID=@ERPID " +
            " order by a.CONFIG_DATE desc ",
            ConfigurationManager.ConnectionStrings("EQ").ConnectionString)
        With apt.SelectCommand.Parameters
            .AddWithValue("CID", HttpContext.Current.Session("cart_id")) : .AddWithValue("UID", HttpContext.Current.User.Identity.Name)
            .AddWithValue("ERPID", HttpContext.Current.Session("company_id").ToString())
        End With
        Dim reconfigDt As New DataTable
        apt.Fill(reconfigDt) : apt.SelectCommand.Connection.Close()
        If reconfigDt.Rows.Count = 1 Then
            Return reconfigDt.Rows(0).Item("ROW_ID")
        End If
        Return ""
    End Function
    Public Function GetExtendedWarranty() As List(Of EWPartNo)
        Return MyCartX.GetExtendedWarranty()
    End Function

    Protected Sub drpEW_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        Dim ddl As DropDownList = CType(sender, DropDownList)
        ddl.DataSource = MyCartX.GetExtendedWarranty() : ddl.DataBind()
        ddl.Items.Insert(0, New ListItem("without extended warranty", 0))
    End Sub

    Protected Sub btnApplyMinimumPrice_Click(sender As Object, e As EventArgs)
        Dim tmpMinPrice As Double = 0, tmpErrMsg As String = String.Empty
        Dim _Cartlist As List(Of CartItem) = MyCartX.GetCartList(CartId)
        Dim EWLineNos As New SortedSet(Of Integer)

        Dim _accountcurrency As String = Session("Company_currency")
        Dim _returncurrency As String = String.Empty
        For Each _item As CartItem In _Cartlist
            If _item.Ew_Flag > 0 Then
                Select Case _item.ItemTypeX
                    Case CartItemType.BtosParent, CartItemType.Part
                        EWLineNos.Add(_item.Line_No)
                End Select
            End If
            If _item.ItemTypeX = CartItemType.BtosParent Then Continue For
            If _item.Part_No.ToUpper.StartsWith("AGS-") Then Continue For

            tmpMinPrice = SAPDAL.SAPDAL.GetMinPrice("TW01", _item.Part_No, _accountcurrency, SAPDAL.SAPDAL.MinimumPrice_SalesTeam.ATW_AOnline, tmpErrMsg, _returncurrency)
            If tmpMinPrice = -1 Then Continue For
            _item.Unit_Price = tmpMinPrice

        Next
        MyUtil.Current.MyAContext.SubmitChanges()

        For Each _cartLineno As Integer In EWLineNos
            Dim _cartitem As CartItem = MyCartX.GetCartItem(CartId, _cartLineno)
            Dim EW_id As Integer = _cartitem.Ew_Flag
            MyCartX.addExtendedWarrantyV2(_cartitem, EW_id)
        Next
        MyCartX.ReSetLineNo(CartId)

        initGV() : Me.gv1.DataBind()


    End Sub

    Protected Sub btnSplitPrice_Click(sender As Object, e As EventArgs)
        lbAddErrMsg.Text = String.Empty

        Dim _cartid As String = CartId

        Dim _totalamount As Decimal = 0
        If (Decimal.TryParse(Me.txtSplitAmount.Text, _totalamount)) Then
            _totalamount = Convert.ToDecimal(Me.txtSplitAmount.Text)
        Else
            lbAddErrMsg.Text = "Input amount can only be numbers."
            Exit Sub
        End If

        Dim _parentLineNo As Integer = 0
        If Not IsNumeric(Me.drpSplitSystem.SelectedValue) Then
            lbAddErrMsg.Text = "Please select a system first."
            Exit Sub
        Else
            _parentLineNo = Me.drpSplitSystem.SelectedValue
        End If

        Dim _companyid As String = Session("company_id").ToString
        Dim _orgid As String = Session("org_id").ToString
        Dim _currency As String = "CNY"
        Dim _taxrate As Decimal = 0.17

        Dim errmsg As String = String.Empty
        Dim result As Boolean = Advantech.Myadvantech.Business.OrderBusinessLogic.SplitPricefromCart(_cartid, _parentLineNo, _totalamount, _companyid, _orgid, _currency, _taxrate, errmsg)

        If Not result OrElse Not String.IsNullOrEmpty(errmsg) Then
            lbAddErrMsg.Text = "Error: " + errmsg
            Exit Sub
        Else
            '攤價後小數點差距重新補齊
            Dim _balance As Decimal = _totalamount - MyCartX.GetTotalAmount(_cartid)
            Dim _firstitem As CartItem = MyCartX.GetCartItem(_cartid, 101)
            If Not _firstitem Is Nothing Then
                _firstitem.Unit_Price = _firstitem.Unit_Price + (_balance / _firstitem.Qty)
                MyUtil.Current.MyAContext.SubmitChanges()
            End If

            initGV()

            Dim _zeropriceitems As List(Of CartItem) = MyCartX.GetCartList(_cartid).Where(Function(p) p.otype = 1 AndAlso p.Unit_Price = 0).ToList
            If _zeropriceitems IsNot Nothing AndAlso _zeropriceitems.Count > 0 Then
                Dim AlertMsg As String = "下列料號攤價後價格為0，請維護ZMIP: \n\n"
                For Each _cartitem As CartItem In _zeropriceitems
                    AlertMsg = AlertMsg + _cartitem.Part_No + "\n"
                Next
                Util.JSAlert(Me.Page, AlertMsg)
            End If

        End If
    End Sub

    Protected Sub dialogConfirm_Click(sender As Object, e As EventArgs)

        'Convert AEU cart to quotation.
        Dim quoteid As String = Advantech.Myadvantech.Business.OrderBusinessLogic.CopyAEUCart2Quotation(CartId, Session("company_id").ToString, Session("user_id").ToString, Util.IsTesting)
        Dim CurrentUser As String = Session("User_Id").ToString
        Dim QM As Advantech.Myadvantech.DataAccess.QuotationMaster = Advantech.Myadvantech.DataAccess.eQuotationContext.Current.QuotationMaster.Where(Function(p) p.createdBy.Equals(CurrentUser, StringComparison.OrdinalIgnoreCase)).FirstOrDefault

        If Not QM Is Nothing OrElse String.IsNullOrEmpty(quoteid) Then
            Dim RURL As String = HttpContext.Current.Server.UrlEncode(String.Format("/Quote/QuotationMaster.aspx?UID={0}", quoteid))
            If Util.IsTesting Then
                Response.Redirect(String.Format("http://eq.advantech.com:8300/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
            Else
                Response.Redirect(String.Format("http://eq.advantech.com/SSOENTER.ASPX?ID={0}&USER={1}&RURL={2}", Session("TempId"), Session("User_Id"), RURL))
            End If
        Else
            Util.JSAlert(Me.Page, "Convert to quotation failed.")
        End If

    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="../Includes/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../Includes/js/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>
    <link rel="stylesheet" href="../../Includes/js/token-input-facebook.css" type="text/css" />
    <link rel="Stylesheet" href="../../Includes/FancyBox/jquery.fancybox.css" type="text/css" />
    <script type="text/javascript" src="../../Includes/FancyBox/jquery.fancybox.js"></script>

    <style type="text/css">
        ul.token-input-list-facebook {
            overflow: hidden;
            height: auto !important;
            height: 1%;
            border: 1px solid #8496ba;
            cursor: text;
            font-size: 12px;
            font-family: Verdana;
            min-height: 1px;
            z-index: 999;
            margin: 0;
            padding: 0;
            background-color: #fff;
            list-style-type: none;
            clear: left;
            width: 350px;
            display: inline-flex;
        }

            ul.token-input-list-facebook li:hover {
                background-color: #ffffff;
            }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            var tokeninputUrl = "";
            <%If Session("company_id").ToString.StartsWith("ADVBB") Then%>
            tokeninputUrl = "<%System.IO.Path.GetFileName(Request.ApplicationPath)%>/Services/AutoComplete.asmx/GetTokenInputPartNoForBB";            
            <%ElseIf AuthUtil.IsBBUS Then%>
            tokeninputUrl = "<%System.IO.Path.GetFileName(Request.ApplicationPath)%>/Services/AutoComplete.asmx/GetTokenInputPartNoWithLegacePN";            
            <%Else%>
            tokeninputUrl = "<%System.IO.Path.GetFileName(Request.ApplicationPath)%>/Services/AutoComplete.asmx/GetTokenInputPartNo";
            <%End If%>

            var postData = JSON.stringify({});
            $.ajax(
                {
                    type: "POST",
                    url: "Cart_List.aspx/CheckIfReconfigurable",
                    data: postData,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (retData) {
                        if (retData.d != "") {
                            $("#divReconfigBtn").css("display", "block");
                            $("#divReconfigBtn").html("<a href='ReConfigureCTOSCheck.aspx?ReConfigId=" + retData.d + "'>Re-Configure</a>");
                        }
                    },
                    error: function (msg) {
                        $("#divReconfigBtn").css("display", "none");
                    }
                }
            );

            $("#<%=txtPartNo.ClientID%>").tokenInput(tokeninputUrl, {
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type PartNo", tokenLimit: 1, preventDuplicates: true, resizeInput: false, resultsLimit: 6,
                resultsFormatter: function (data) {
                    var cpn = "";
                    if (data.cpn.length > 0) {
                        <% If AuthUtil.IsBBUS Then%>
                            cpn = "<br /><span style='color:red;'>Legacy PN: " + data.cpn + "</span>";
                        <% Else%>
                            cpn = "<br /><span style='color:red;'>Customer PN: " + data.cpn + "</span>";
                        <% End If %>
                    }

                    return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.name + "</span><br/>" + "<span style='color:gray;'>" + data.id + "</span>" + cpn + "</li>";
                },
                onAdd: function (data) {
                    $("#<%=txtPartNo.ClientID%>").val(data.name);
                }
            });
        }
        );
            function OnBeforeCheckOut() {
            <%If isFeiOffice AndAlso isRiskOrder Then%>

                var x = "This may be a risk buy order.\r\nPlease pay attention at the highlighted items (in any).\r\nIf you have any concern and uncertainty, please contact Fei for confirmation before you complete this order flipping.";
                if (confirm(x) == true) {
                    return true;
                }
                else {
                    return false;
                }

            <%ElseIf Util.IsTesting AndAlso Session("org_id").ToString.Equals("EU10") AndAlso Util.IsInternalUser2 AndAlso Not isCartFromQuote Then%>
                var flag = true;

                var postData = {
                    _CartID: "<%=Session("cart_id").ToString%>",
                    _CompanyID: "<%=Session("company_id").ToString%>"
                };
                $.ajax({
                    url: "<%= Util.GetRuntimeSiteUrl()%>/Services/MyServices.asmx/CheckAEUCartGP",
                    type: "POST",
                    dataType: 'json',
                    async: false,
                    data: postData,
                    success: function (retData) {
                        if (retData.Result) {
                            var gallery = [{
                                href: "#dialog"
                            }];
                            $('#StandardMargin').text("Total Margin Advantech product: " + (retData.StandardMargin * 100).toFixed(2) + "%");
                            $('#PTDMargin').text("Total Margin P-trade product: " + (retData.PTDMargin * 100).toFixed(2) + "%");
                            $.fancybox(gallery, {
                                'autoSize': false,
                                'width': 500,
                                'height': 300
                            });
                            flag = false;
                        }
                        else {
                            flag = true;
                        }
                    },
                    error: function (msg) {
                        flag = false;
                    }
                });
                return flag;
            <%ElseIf Session("org_id").ToString.StartsWith("CN") Then%>
                var flag = true;
                var alertmsg = "This cart's GP margin is negative and is not allowed to check out.\nPlease check all price again.\n";
                <%if Not Util.IsInternalUser2 Then%>
                alertmsg = "Current cart is not allowed to check out.\nPlease kindly contact your sales representative for more information.\n";
                <%End If%>

                // 1. Check if ACN loose item carts margin is negative (below zero). If so, block users checking out.
                var postData1 = {
                    _CartID: "<%=Session("cart_id").ToString%>",
                    _Org: "<%=Session("org_id").ToString%>"
                };
                $.ajax({
                    url: "<%= Util.GetRuntimeSiteUrl()%>/Services/MyServices.asmx/IsACNLooseItemCartNegativeMargin",
                    type: "POST",
                    dataType: 'json',
                    async: false,
                    data: postData1,
                    success: function (retData) {
                        if (retData) {
                            alert(alertmsg);
                            flag = false;
                        }
                        else {
                            flag = true;
                        }
                    },
                    error: function (msg) {
                        flag = true;
                    }
                });
                if (flag == false)
                    return flag;

                // 2. Check if ACN cart contatins D/P/T items and needs to convert to SAP quotations for IS approval
                var postData2 = {
                    _CartID: "<%=Session("cart_id").ToString%>",
                    _Plant: "<%=Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString)%>",
                    _Org: "<%=Session("org_id").ToString%>"
                };
                $.ajax({
                    url: "<%= Util.GetRuntimeSiteUrl()%>/Services/MyServices.asmx/IsACNCartNeedsApproval",
                    type: "POST",
                    dataType: 'json',
                    async: false,
                    data: postData2,
                    success: function (retData) {
                        if (retData) {
                            var x = "This cart contains D/P/T items and needs approval.\r\nClick OK for further settings and convert to SAP quotation, cancel to adjust items.";

                            if (confirm(x) == true) {
                                flag = true;
                            }
                            else {
                                flag = false;
                            }
                        }
                        else {
                            flag = true;
                        }
                    },
                    error: function (msg) {
                        flag = true;
                    }
                });

                return flag;
            <%Else%>

                return true;

            <%End If%>
            }

    </script>
    <asp:HiddenField ID="HFisquote2cart" runat="server" Value="" />
    <table width="100%">
        <tr>
            <td>
                <span style="width: 41%;" id="page_path" runat="server"></span>
                <asp:Button ID="btn_enter" runat="server" OnClientClick="return false;"
                    Height="0px" Width="0px" />
            </td>
            <td align="right">
                <table>
                    <tr>
                        <td>
                            <asp:Image ID="imgLK" runat="server" ImageUrl="~/Images/arrow2007_small-BU3.gif" />
                        </td>
                        <td>
                            <asp:LinkButton runat="server" ID="lbtnCartHistory" OnClick="lbtnCartHistory_Click"> Cart History</asp:LinkButton>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <hr />
    <table>
        <tr>
            <td>
                <table>
                    <tr>
                        <td class="menu_title">
                            <asp:Label runat="server" ID="lbPageName" Text="Shopping Cart"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td style="border: 1px solid #d7d0d0; padding: 10px">
                            <asp:Panel DefaultButton="ibtnAdd" runat="server" ID="plAdd">
                                <table cellspacing="5px">
                                    <tr>
                                        <td class="h5">Part No:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtPartNo" Width="400"></asp:TextBox>
                                            <%--<ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" TargetControlID="txtPartNo"
                                                ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetPartNo" MinimumPrefixLength="2" OnClientItemSelected="ClientItemSelected">
                                            </ajaxToolkit:AutoCompleteExtender>--%>
                                        </td>
                                        <td>
                                            <asp:ImageButton ID="ibtnAvilability" runat="server" ImageUrl="~/images/availability.gif"
                                                OnClick="ibtnAvilability_Click" />
                                        </td>
                                    </tr>
                                    <tr runat="server" id="drpCPI">
                                        <td class="h5">Choose Parent Item :
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="DDLbtosParentItem" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td class="h5">Quantity:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtQty" Width="50" Text="1"></asp:TextBox>
                                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft3" TargetControlID="txtQty"
                                                FilterType="Numbers, Custom" />
                                        </td>
                                        <td></td>
                                    </tr>
                                    <tr id="trUP" runat="server">
                                        <td class="h5">Unit Price:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtPrice" Width="80" Text=""></asp:TextBox>
                                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1"
                                                TargetControlID="txtPrice" FilterType="Numbers,Custom" ValidChars="." />
                                        </td>
                                        <td></td>
                                    </tr>
                                    <tr id="trEx" runat="server">
                                        <td class="h5">Extended Warranty:
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="drpEW" runat="server" DataTextField="EW_PartNO" DataValueField="id">
                                            </asp:DropDownList>
                                        </td>
                                        <td></td>
                                    </tr>
                                    <tr id="trSplitPrice" runat="server" visible="false">
                                        <td class="h5">Price Recalculating:
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="drpSplitSystem" runat="server"></asp:DropDownList>
                                            <asp:TextBox ID="txtSplitAmount" runat="server" placeholder="Amount"></asp:TextBox>
                                            <asp:Button ID="btnSplitPrice" runat="server" Text=" Go " OnClick="btnSplitPrice_Click" />
                                        </td>
                                        <td></td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" align="left">
                                            <asp:Label runat="server" ID="lbAddErrMsg" ForeColor="Tomato" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td></td>
                                        <td>
                                            <asp:ImageButton ID="ibtnAdd" runat="server" ImageUrl="~/images/add2cart_2.gif" OnClick="ibtnAdd_Click"
                                                OnClientClick="return CheckPN();" />
                                            <asp:ImageButton ID="ibtnSearch" runat="server" ImageUrl="~/images/search1.gif" OnClientClick="goSearch()" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <hr />
    <table width="100%">
        <tr>
            <td class="menu_title">My Shopping Cart
            </td>
        </tr>
        <tr>
            <td style="border: 1px solid #d7d0d0; padding: 2px">
                <table width="100%">
                    <tr>
                        <td>
                            <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download"
                                OnClick="imgXls_Click" />
                            <asp:Button runat="server" Text=" Del " ID="btnDel" OnClick="btnDel_Click" />
                            <asp:Panel ID="PLconfigConfirm" runat="server" Style="display: none" CssClass="modalPopup">
                                <div style="text-align: right;">
                                    <asp:ImageButton ID="cconfigConfirm" runat="server" ImageUrl="~/Images/del.gif" />
                                </div>
                                <div>
                                    <asp:UpdatePanel ID="UPconfigConfirm" runat="server" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            This will remove all items in shopping cart, continue?
                                            <table width="100%">
                                                <tr>
                                                    <td align="center">
                                                        <asp:Button ID="btnConfigConfirm" runat="server" Text="Confirm" OnClick="btnConfigConfirm_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </asp:Panel>
                            <asp:LinkButton ID="lbDummyConfigConfirm" runat="server"></asp:LinkButton>
                            <ajaxToolkit:ModalPopupExtender ID="MPConfigConfirm" runat="server" TargetControlID="lbDummyConfigConfirm"
                                PopupControlID="PLconfigConfirm" BackgroundCssClass="modalBackground" CancelControlID="cconfigConfirm"
                                DropShadow="true" />
                            <asp:Button runat="server" Text=" Update " ID="btnUpdate" OnClick="btnUpdate_Click" />
                            <asp:Button runat="server" Text=" Apply Minimum Price " ID="btnApplyMinimumPrice" OnClick="btnApplyMinimumPrice_Click" Visible="false" />
                        </td>
                    </tr>
                </table>
                <div style="width: 890px; overflow: scroll; overflow-y: hidden">
                    <%--      <asp:UpdatePanel ID="upGV1" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>--%>
                    <asp:HiddenField ID="HF_IsBTOS" runat="server" Value="0" />
                    <asp:Label runat="server" ID="LabWarn" Visible="false" ForeColor="Tomato" />
                    <div id="divReconfigBtn" style="display: none"></div>
                    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                        AllowSorting="true" Width="100%" EmptyDataText="please add part number in shopping cart."
                        DataKeyNames="line_no" OnRowDataBound="gv1_RowDataBound" OnDataBound="gv1_DataBound">
                        <Columns>
                            <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    <asp:CheckBox ID="chkKey" runat="server" OnClick="GetAllCheckBox(this)" />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="chkKey" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Seq
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:HiddenField runat="server" ID="hdLineNo" Value='<%#Eval("line_no") %>' />
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:LinkButton runat="server" CommandName='<%#Bind("line_no")%>' ID="ibtnSeqUp"
                                                    CommandArgument='<%#Bind("id")%>' Font-Bold="true" OnClick="ibtnSeqUp_Click" Text="↑" />
                                            </td>
                                            <td>
                                                <asp:LinkButton runat="server" CommandName='<%#Bind("line_no")%>' ID="ibtnSeqDown"
                                                    CommandArgument='<%#Bind("id")%>' Font-Bold="true" OnClick="ibtnSeqDown_Click" Text="↓" />
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="line_no" HeaderText="No." ItemStyle-HorizontalAlign="center" />
                            <asp:TemplateField HeaderText="Category">
                                <ItemTemplate>
                                    <asp:TextBox runat="server" ID="txtCategory" Text='<%#Bind("category") %>' BorderWidth="1px"
                                        BorderColor="#cccccc" ReadOnly="true" BackColor="#eeeeee" Width="100px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Part No">
                                <ItemTemplate>
                                    <asp:HyperLink runat="server" ID="hlPartNo" Text='<%#Bind("part_no") %>' NavigateUrl='<%# "~/Product/model_detail.aspx?model_no=" & HttpUtility.UrlEncode(Eval("part_no")) %>'
                                        Target="_blank" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <%--   <asp:HyperLinkField HeaderText="Part No" Target="_blank" DataNavigateUrlFields="model_no"
                                        DataNavigateUrlFormatString="~/product/model_detail.aspx?model_no={0}" DataTextField="part_no" />--%>
                            <asp:TemplateField HeaderText="Description">
                                <ItemTemplate>
                                    <asp:TextBox runat="server" ID="txtDescription" Text='<%#Bind("Description") %>'
                                        BorderWidth="1px" BorderColor="#cccccc" ReadOnly="true" BackColor="#eeeeee" Width="100px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Extended Warranty" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:DropDownList ID="gv_drpEW" runat="server" AutoPostBack="true" Width="110px"
                                        OnSelectedIndexChanged="gv_drpEW_SelectedIndexChanged" DataTextField="EW_PartNO" DataValueField="id">
                                    </asp:DropDownList>
                                    <asp:Label runat="server" Visible="false" Text='<%# CurrencySign%>' ID="lbEWSign"></asp:Label>
                                    <asp:TextBox runat="server" Visible="false" ID="gv_lbEW" Style="text-align: right" BorderWidth="1px"
                                        BorderColor="#cccccc" ReadOnly="true" BackColor="#eeeeee" Width="40px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="rohs" HeaderText="Rohs" ItemStyle-HorizontalAlign="center" />
                            <asp:BoundField DataField="class" HeaderText="Class" ItemStyle-HorizontalAlign="center" />
                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    List Price
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" Text='<%# CurrencySign%>' ID="lbListPriceSign"></asp:Label>
                                    <asp:Label runat="server" Text='<%#FormatNumber(Eval("list_price"), 2) %>' ID="lbListPrice"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Unit Price
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" Text='<%# CurrencySign%>' ID="lbUnitPriceSign"></asp:Label>
                                    <asp:TextBox ID="txtUnitPrice" runat="server" Text='<%#Replace(FormatNumber(Eval("unit_price"), 2), ",", "") %>'
                                        Width="60px" Style="text-align: right" OnTextChanged="txtUnitPrice_TextChanged" />
                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft1" TargetControlID="txtUnitPrice"
                                        FilterType="Numbers, Custom" ValidChars="." />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="" HeaderText="Disc." ItemStyle-HorizontalAlign="right" />
                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Qty.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:TextBox ID="txtGVQty" runat="server" Text='<%#Bind("qty") %>' Width="30px" Style="text-align: right"
                                        OnTextChanged="txtGVQty_TextChanged"></asp:TextBox>
                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft2" TargetControlID="txtGVQty"
                                        FilterType="Numbers, Custom" ValidChars="^[1-9]\d*$" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Req. Date
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:TextBox ID="txtreqdate" name="txtreqdate" runat="server" Text='<%#IIf(isANA, CDate(Eval("req_date")).ToString("MM/dd/yyyy"), CDate(Eval("req_date")).ToString("yyyy/MM/dd")) %>'
                                        Width="65px" Style="text-align: right" Onclick="PickDate('/INCLUDES/PickShippingCalendar.aspx',this)"
                                        OnTextChanged="txtreqdate_TextChanged" onkeydown="javascript:return false;"></asp:TextBox>
                                    <asp:RegularExpressionValidator ID="Validator_ID" runat="Server" ControlToValidate="txtreqdate"
                                        ValidationExpression="^\d{4}(\-|\/|\.)\d{1,2}\1\d{1,2}|^(0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.](19|20)\d\d$"
                                        ErrorMessage="Request Date is in invalid format" Display="Dynamic" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Due Date
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" Text='<%#IIf(CDate(Eval("due_date")).ToString("yyyy/MM/dd") = "1900/01/01", "TBD", IIf(isANA, CDate(Eval("due_date")).ToString("MM/dd/yyyy"), CDate(Eval("due_date")).ToString("yyyy/MM/dd"))) %>'
                                        ID="lbDueDate"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="" HeaderText="Sub Total" ItemStyle-HorizontalAlign="right" />
                            <asp:TemplateField HeaderText="Customer PN.">
                                <ItemTemplate>
                                    <asp:TextBox runat="server" ID="txtCustPN" Text='<%#Server.HtmlDecode(Eval("custMaterial").ToString()) %>'
                                        OnTextChanged="txtCustPN_TextChanged" Width="80px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="ABC Indicator">
                                <ItemTemplate>
                                    <asp:TextBox runat="server" ID="txtABCIndicator" Width="40px"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="ITP" ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:Label runat="server" Text='<%#FormatNumber(Eval("ITP"), 2) %>' ID="lbITP"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <RowStyle Wrap="false" />
                        <HeaderStyle Wrap="false" />
                    </asp:GridView>
                    <table width="100%">
                        <tr>
                            <td align="right">
                                <table>                                  
                                    <tr>                                        
                                        <td id="tdITP" runat="server" visible="false">
                                            <b>Total ITP:</b><asp:Label runat="server" ID="lbITP" Text="0.00" />
                                        </td>
                                        <td id="tdMargin" runat="server" visible="false">
                                            <b>Total Margin:</b><asp:Label runat="server" ID="lbMargin" Text="0.00" />
                                        </td>
                                        <td>
                                            <b>Total:</b>
                                        </td>
                                        <td>
                                            <%= CurrencySign%><asp:Label runat="server"
                                                ID="lbtotal" Text="0.00"></asp:Label>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <%--     </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnConfigConfirm" />
                          <asp:AsyncPostBackTrigger ControlID="btnDel" />
                            <asp:AsyncPostBackTrigger ControlID="btnUpdate" />
                        </Triggers>
                    </asp:UpdatePanel>--%>
                </div>
            </td>
        </tr>
    </table>
    <table runat="server" id="tbSaveCart">
        <tr>
            <td>
                <asp:ImageButton ID="ibSave" runat="server" ImageUrl="~/images/savemycart.gif" OnClick="ibSave_Click"
                    OnClientClick="return CheckCartDesc()" />
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtCartDesc" Width="100px" />
                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft4" TargetControlID="txtCartDesc"
                    FilterType="Numbers,UppercaseLetters,LowercaseLetters,Custom" ValidChars="_ " />
            </td>
        </tr>
    </table>
    <asp:UpdatePanel ID="upbtnConfirm" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <table width="100%">
                <tr>
                    <td>
                        <asp:Label runat="server" ForeColor="Red" ID="lbConfirmMsg" />
                    </td>
                </tr>
                <tr>
                    <td align="center">
                        <asp:Button runat="server" Text=" >> Check Out << " ID="btnOrder" OnClick="btnOrder_Click" OnClientClick="return OnBeforeCheckOut();" />
                    </td>
                </tr>
                <tr>
                    <td align="center">
                        <asp:Label runat="server" ID="lblMsg" Text="You are currently not authorized to place orders through MyAdvantech. <br />Please contact your Advantech Account Manager for assistance if you need to place orders through this portal."
                            ForeColor="Red" Visible="false" />
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
    <div id="dialog" style="display: none; height: inherit">
        <div style="height: 80%; width: 100%;">
            <h2 style="color: #1b1b69; text-align: center; line-height: 60px">Cart items are below GP.</h2>
            <span id="StandardMargin" style="line-height: 30px; font-size: 15px"></span>
            <br />
            <span id="PTDMargin" style="line-height: 30px; font-size: 15px"></span>
            <br />
            <span style="line-height: 30px; font-size: 15px">Click confirm to quote and start GP approval flow.</span><br />
            <span style="line-height: 30px; font-size: 15px">Click cancel to adjust price.</span><br />
        </div>
        <div style="height: 20%; text-align: center">
            <asp:Button ID="dialogConfirm" runat="server" Text="Confirm" OnClick="dialogConfirm_Click" />
            <asp:Button ID="dialogCancel" runat="server" Text="Cancel" OnClientClick="$.fancybox.close();return false;" />
        </div>
    </div>
    <script type="text/javascript">
        function GetAllCheckBox(cbAll) {
            var items = document.getElementsByTagName("input");
            for (i = 0; i < items.length; i++) {
                if (items[i].type == "checkbox") {
                    items[i].checked = cbAll.checked;
                }
            }
        }
        function goSearch() {
            var Obj = document.getElementById('<%=Me.txtPartNo.ClientID%>');
            var Url = "/Product/ProductSearch.aspx?key=" + Obj.value
            window.open(Url, "_blank")
        }
        function PickDate(Url, Element) {
            //Url = Url + "?Element=" + Element.name
            Url = Url + "?Element=" + Element.name + "&SelectedDate=" + Element.value + "&IsBTOS=<%=Me.HF_IsBTOS.Value%>";
            window.open(Url, "pop", "height=265,width=263,top=300,left=400,scrollbars=no")
        }

        function CheckPN() {
            var Obj = document.getElementById('<%=Me.txtPartNo.ClientID%>');
            return Check(Obj);
        }
        function CheckCartDesc() {
            var Obj = document.getElementById('<%=Me.txtCartDesc.ClientID%>');
            return Check(Obj);
        }
        function Check(o) {
            o.style.backgroundColor = '#FFFFFF';
            if (o.value.replace(/ |'/g, '').replace(/'/g, '') == '') {
                alert("Please input a part number first.")
                o.style.backgroundColor = '#ff0000';
                return false
            }
        }
        function ClientItemSelected(sender, e) {
            $("#<%=txtPartNo.ClientID%>").val(e.get_value());
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
