<%@ Page Title="MyAdvantech–Shopping Cart" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" EnableEventValidation="false" %>

<script runat="server">
    Dim mycart As New CartList("b2b", "CART_DETAIL_V2")
    Dim myCartHistory As New cart_history("b2b", "cart_history")
    Dim isANA As Boolean = False
    Dim CartId As String = "", CurrencySign As String = String.Empty
    Dim IsInternalUser As Boolean = False

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        '把預設按鈕指定給空按鈕，防止ENTER發生Logout
        Me.Page.Form.DefaultButton = btn_enter.UniqueID

        CartId = Session("CART_ID") : CurrencySign = MyCartX.GetCurrencySign(CartId)
        IsInternalUser = Util.IsInternalUser2()
        lbConfirmMsg.Text = ""

        If MyCartX.IsHaveBtos(CartId) Then
            btnDel.Visible = False
        End If

        If Not Page.IsPostBack Then
            tbCart.Visible = False

            drpEW.DataSource = MyCartX.GetExtendedWarranty() : drpEW.DataBind()
            drpEW.Items.Insert(0, New ListItem("without extended warranty", 0))

            Dim _Quoteid As String = String.Empty
            If MyCartX.IsQuote2Cart(CartId, _Quoteid) Then
                HFisquote2cart.Value = _Quoteid
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
            Dim _org As String = Left(Session("org_id").ToString.ToUpper, 2)
            If Not MYSAPBIZ.CanPlaceOrderOrg(_org) Then
                btnOrder.Enabled = False
                lblMsg.Visible = True
            End If
        End If

        If Not IsPostBack Then
            initGV()
        End If
        Source_path()
    End Sub

    Sub initGV()
        Dim _cartlist As List(Of CartItem) = MyCartX.GetCartList(CartId)
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

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        ' Dim currSin As String = Session("company_currency_sign")
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim _CartItem As CartItem = CType(e.Row.DataItem, CartItem)
            Dim line_no As Integer = _CartItem.Line_No ' CInt(CType(e.Row.FindControl("hdLineNo"), HiddenField).Value)
            Dim cbDel As CheckBox = e.Row.FindControl("chkKey")
            Dim part_no As String = _CartItem.Part_No
            Dim lable_ListPrice As Label = CType(e.Row.FindControl("lbListPrice"), Label)
            Dim TextBox_UnitPrice As TextBox = CType(e.Row.FindControl("txtUnitPrice"), TextBox)
            Dim ListPice As Decimal = CDbl(lable_ListPrice.Text)
            Dim UnitPrice As Decimal = CDbl(TextBox_UnitPrice.Text)
            If IsInternalUser = False Then
                TextBox_UnitPrice.ReadOnly = True
            Else
                TextBox_UnitPrice.ReadOnly = False
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
            End If

            If _CartItem.otype = CartItemType.BtosPart Then
                If DrpEW IsNot Nothing Then DrpEW.Enabled = False
                Dim TBqty As TextBox = CType(e.Row.FindControl("txtGVQty"), TextBox)
                If TBqty IsNot Nothing Then
                    TBqty.Enabled = True
                End If
            End If
            If _CartItem.IsEWpartnoX Then
                e.Row.Cells(0).Text = "" : e.Row.Cells(1).Text = ""
                CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = False
                CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
                e.Row.Cells(6).Text = ""
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

                If MyCartX.IsHaveBtos(CartId) Then
                    CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
                End If

                If String.Equals(Session("org_id"), "EU10") Then
                    e.Row.Cells(0).Text = ""
                End If
            End If

            CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = False
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            If MyCartX.IsHaveBtos(CartId) Then
                e.Row.Cells(3).Visible = False
            End If
            e.Row.Cells(3).Visible = False : e.Row.Cells(6).Visible = False
            e.Row.Cells(7).Visible = False : e.Row.Cells(8).Visible = False
            e.Row.Cells(16).Visible = False : e.Row.Cells(17).Visible = False : e.Row.Cells(18).Visible = False
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

    Protected Sub txtGVQty_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim Qty As String = obj.Text
        Dim _intvalue As Integer = 0
        If Not Integer.TryParse(Qty, _intvalue) Then Exit Sub
        If _intvalue < 1 Then Exit Sub

        If Session("Quote3AllowedReduceQty") IsNot Nothing AndAlso Session("Quote3AllowedReduceQty") = False Then
            Dim hf As HiddenField = row.FindControl("hfGVQty")
            If Integer.Parse(Qty) < Integer.Parse(hf.Value) Then
                ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "alert(""Update failed, this quotation is not allowed to reduce qty."");", True)
                obj.Text = hf.Value
                Exit Sub
            End If
        End If


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

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        initGV()
        Me.gv1.DataBind()
    End Sub

    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        If Not MyCartX.IsHaveItems(CartId) Then
            ForbidConfirm(False, "Please add part number to cart first.")
            Exit Sub
        End If

        'Ryan 20160324 If any part in cart starts with "968T" and org exist in saprdp.ZTSD_106C, than disable check out
        Dim SAP968T_CartList As List(Of CartItem) = MyCartX.GetCartList(CartId).Where(Function(p) p.Part_No.StartsWith("968T")).ToList()
        If SAP968T_CartList.Count > 0 Then
            Dim strSql As String = "select * from saprdp.ZTSD_106C where KUNNR = '" & Session("company_id").ToString() & "'"
            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", strSql)
            If dt.Rows.Count > 0 Then
                ForbidConfirm(True, "Due to MS licenses policy it is not allowed to order part numbers start with 968T.")
                Exit Sub
            End If
        End If

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
                End If
            End If
        Next
        If Not String.IsNullOrEmpty(SB.ToString.Trim) Then
            ForbidConfirm(False, SB.ToString.Trim)
            Exit Sub
        End If

        If Not String.IsNullOrEmpty(HFisquote2cart.Value) Then
            mycart.Update(String.Format("cart_id='{0}'", CartId), String.Format("Quote_id='{0}'", HFisquote2cart.Value))
        End If
        'ICC 2015/4/28 Update CARTMASTERV2 amount
        Dim amount As Integer = FormatNumber(dbUtil.dbExecuteScalar("MY", String.Format(" select ISNULL(SUM(Unit_Price * Qty), 0) from CART_DETAIL_V2 where Cart_Id = '{0}' ", CartId)))
        dbUtil.dbExecuteNoQuery("MY", String.Format(" update CARTMASTERV2 set OpportunityAmount = {0} where CartID = '{1}' ", amount, CartId))

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
                Next
            End If

            Util.DataTable2ExcelDownload(TB, "MyCart.xls")
        End If
    End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.lbtotal.Text = FormatNumber(MyCartX.GetTotalAmount(CartId), 2)
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

    Public Sub ForbidConfirm(ByVal type As Boolean, ByVal msg As String)
        Me.btnOrder.Enabled = type : Me.lbConfirmMsg.Text = msg : upbtnConfirm.Update()
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

    Protected Sub ibtnAdd_Click(sender As Object, e As ImageClickEventArgs)

    End Sub

    Protected Sub btnDel_Click(sender As Object, e As EventArgs)
        Dim f As Integer = 0
        For i As Integer = 0 To gv1.Rows.Count - 1
            Dim chk As CheckBox = gv1.Rows(i).FindControl("chkKey")
            If chk.Checked Then
                Dim oldLineNo As Integer = gv1.DataKeys(gv1.Rows(i).RowIndex).Value
                Dim _CartItem As CartItem = CType(gv1.Rows(i).DataItem, CartItem)
                MyCartX.DeleteCartItem(CartId, oldLineNo)
            End If
        Next
        MyCartX.ReSetLineNo(CartId)
        initGV()
    End Sub

    Protected Sub txtUnitPrice_TextChanged(sender As Object, e As EventArgs)

    End Sub

    Protected Sub ibSave_Click(sender As Object, e As ImageClickEventArgs)

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
                theme: "facebook", searchDelay: 200, minChars: 1, tokenDelimiter: ";", hintText: "Type PartNo", tokenLimit: 1, preventDuplicates: true, resizeInput: false, resultsLimit: 5,
                resultsFormatter: function (data) {
                    var cpn = "";
                    if (data.cpn.length > 0) {
                        cpn = "<br /><span style='color:red;'>Customer PN: " + data.cpn + "</span>";
                    }

                    return "<li style='border-bottom: 1px solid #003377;'>" + "<span style='font-weight: bold;font-size: 14px;'>" + data.name + "</span><br/>" + "<span style='color:gray;'>" + data.id + "</span>" + cpn + "</li>";
                },
                onAdd: function (data) {
                    $("#<%=txtPartNo.ClientID%>").val(data.name);
                }
            });
        }
        );
    </script>
    <asp:HiddenField ID="HFisquote2cart" runat="server" Value="" />
    <table width="100%">
        <tr>
            <td>
                <span style="width: 41%;" id="page_path" runat="server"></span>
                <asp:Button ID="btn_enter" runat="server" OnClientClick="return false;"
                    Height="0px" Width="0px" />
            </td>            
        </tr>
    </table>
    <table runat="server" id="tbCart">
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
                                        </td>
                                        <td>
                                            <asp:ImageButton ID="ibtnAvilability" runat="server" ImageUrl="~/images/availability.gif" />
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
                                    <tr>
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
                                            <asp:Button ID="btnSplitPrice" runat="server" Text=" Go " />
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
                                OnClick="imgXls_Click" Visible="false" />
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
                                        BorderWidth="1px" BorderColor="#cccccc" ReadOnly="true" BackColor="#eeeeee" Width="99%"></asp:TextBox>
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
                                        Width="60px" Style="text-align: right" OnTextChanged="txtUnitPrice_TextChanged"/>
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
                                        OnTextChanged="txtGVQty_TextChanged" AutoPostBack="true"></asp:TextBox>
                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft2" TargetControlID="txtGVQty"
                                        FilterType="Numbers, Custom" ValidChars="^[1-9]\d*$" />
                                    <asp:HiddenField ID="hfGVQty" runat="server" Value='<%#Bind("qty") %>' />
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
                </div>
            </td>
        </tr>
    </table>
    <table runat="server" id="tbSaveCart" visible="false">
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
                        <asp:Button runat="server" Text=" >> Check Out << " ID="btnOrder" OnClick="btnOrder_Click" />
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
