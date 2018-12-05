<%@ Page Title="MyAdvantech–Shopping Cart" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim mycart As New CartList("b2b", "cart_detail")
    Dim myCartHistory As New cart_history("b2b", "cart_history")
    Dim isANA As Boolean = False
    Dim CartId As String = ""
    Dim isJPAonline As Boolean = False
    Function isSpecailRole(ByVal user As String) As Boolean
        If user.ToLower.Contains("amy@kingpronet.com.tw") Then
            Return True
        End If
        If user.ToLower.Contains("jack@kingpronet.com.tw") Then
            Return True
        End If
        Return False
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Util.IsTestingQuote2Order() Then
                Response.Redirect(String.Format("Cart_ListV2.aspx{0}", Request.Url.Query))
            End If
            If Session("org_id") = "TW01" Then
                Dim blToAllTW01 As Boolean = True
                Dim company_id As String = Session("company_id").ToString().ToUpper()
                If company_id.Equals("AVNA001") OrElse _
                    company_id.Equals("UUMM001") OrElse _
                    company_id.Equals("ASPA002") OrElse _
                    company_id.Equals("EURP001") OrElse _
                    company_id.Equals("ETKL001") OrElse _
                    company_id.Equals("AIAD003") OrElse _
                    company_id.Equals("AINA001") OrElse _
                    company_id.Equals("AINT001") OrElse _
                    company_id.StartsWith("MX", StringComparison.CurrentCultureIgnoreCase) OrElse _
                    blToAllTW01 Then
                    'Can Place Order on MyAdvantech
                ElseIf Util.IsInternalUser2() Then
                    'Can Place Order on MyAdvantech
                ElseIf isSpecailRole(Session("user_id")) Then
                    'Can Place Order on MyAdvantech
                Else
                    Dim objPWD As String = dbUtil.dbExecuteScalar("MY", _
                        "select top 1 LOGIN_PASSWORD from ACCESS_HISTORY_2013 where USERID ='" + User.Identity.Name + "' order by LOGIN_DATE_TIME desc")
                    Dim fName As String = Util.GetNameVonEmail(User.Identity.Name)
                    Dim strCmd As String = _
                        "delete from USER_INFO where userid='" + User.Identity.Name + "'; delete from USER_PROFILE where userid='" + User.Identity.Name + "';" + _
                        " INSERT INTO USER_INFO  (USERID, COMPANY_ID, ORG_ID, LOGIN_PASSWORD, USER_TYPE, FIRST_NAME, LAST_NAME, EMAIL_ADDR,  " + _
                        " TEL_NO, TEL_EXT, FAX_NO, FAX_EXT, JOB_TITLE, JOB_FUNCTION, LAST_UPDATED, UPDATED_BY, CREATED_BY,  " + _
                        " CREATED_DATE, SALES_ID) " + _
                        " VALUES ('" + User.Identity.Name + "', '" + Session("company_id") + "', 'TW01', '" + Replace(objPWD, "'", "''") + _
                        "', 'Contact', N'" + Replace(fName, "'", "''") + "', N'', '" + User.Identity.Name + "', '', '', '', '', '', '',  " + _
                        "  GETDATE(), 'tc.chen@advantech.com.tw', 'tc.chen@advantech.com.tw', GETDATE(), N''); " + _
                        "INSERT INTO USER_PROFILE (USERID, ATTRI_ID, ATTRI_VALUE_ID) VALUES ('" + User.Identity.Name + "', 1, '1')"
                    dbUtil.dbExecuteNoQuery("B2BACL", strCmd)
          
                    Util.JSAlertRedirect(Me.Page, "To place an order please kindly go to B2B ACL instead, thank you.", _
                                         "http://b2b.advantech.com.tw/LoginNew.aspx?AutoLogin=Y&MyUID=" + User.Identity.Name + "&MyPWD=" + objPWD)
                End If
            End If
        End If
        'Response.Write(HttpContext.Current.Session("cart_id"))
        

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
            If _org <> "TW" And _org <> "US" And _org <> "SG" And _org <> "JP" And _org <> "EU" Then btnOrder.Enabled = False : lblMsg.Visible = True
        End If
        If AuthUtil.IsJPAonlineSales(Session("user_id")) Then
            isJPAonline = True
        End If
        If AuthUtil.IsUSAonlineSales(Session("user_id")) Then
            isANA = True
        End If
        If isANA Then
            Me.tbSaveCart.Visible = False
            Me.btnOrder.Text = " >> Next << "
            Me.trUP.Visible = True
        Else
            Me.trUP.Visible = False
        End If
        CartId = Session("CART_ID")
        If Not IsPostBack Then
            initInterFace()
            Me.txtPartNo.Attributes("autocomplete") = "off"
        End If
        Source_path()
        
    End Sub
    Sub initInterFace()
        If mycart.isBtoOrder(CartId) = 1 Then
            Me.lbPageName.Text = "Add additional components to Cart"
            Me.HF_IsBTOS.Value = 1
        End If
        initGV()
    End Sub
    Protected Sub ibtnAdd_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        lbAddErrMsg.Text = ""
        Dim part_no As String = "", qty As Integer = 0, ew_flag As Integer = 0, otype As Integer = 0, cate As String = ""
        part_no = Me.txtPartNo.Text.Trim.Replace("'", "''")
        part_no = part_no.ToUpper()
        qty = CInt(Me.txtQty.Text.Trim)
        ew_flag = Me.drpEW.SelectedValue
        If mycart.isBtoOrder(CartId) = 1 Then
            If (Not Util.IsInternalUser2()) AndAlso (Not Session("org_id") = "TW01") Then 'Nada:20131118 prohibit external user adding component to system order.
                lbAddErrMsg.Text = "Component cannot be added to system order directly, please use eConfigurator instead."
                Exit Sub
            End If
            otype = 1 : cate = "OTHERS" : ew_flag = mycart.getEWFlagBTO(CartId)
        End If
        Dim ReqDate As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        
        'Frank:ReqDate should be next working day from today
        ReqDate = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, ReqDate), Session("org_id"))
        
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
                lineNo = mycart.ADD2CART(CartId, part_no, qty, ew_flag, otype, cate, 0, 1, ReqDate)
                mycart.Update(String.Format("cart_Id='{0}' and line_no='{1}'", CartId, lineNo), String.Format("list_price='{1}',ounit_price='{0}',unit_Price='{0}'", unitPrice, listPrice))
            End If
        Else
            lineNo = mycart.ADD2CART(CartId, part_no, qty, ew_flag, otype, cate, 1, 1, ReqDate)
        End If
        If MyCartOrderBizDAL.IsSpecialADAM(part_no) Then
            mycart.Update(String.Format("cart_Id='{0}' and line_no='{1}'", CartId, lineNo), String.Format("ew_Flag='99'"))
        End If
        initGV()
        Me.txtPartNo.Text = "" : Me.txtQty.Text = 1 : Me.txtPrice.Text = "" : Me.drpEW.SelectedValue = 0
    End Sub

    Protected Sub ibtnAvilability_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Page.Response.Redirect("~/Order/priceAndATP.aspx?PN=" & Me.txtPartNo.Text.Trim())
    End Sub
    
    
    Sub initGV()
        Dim dt As DataTable = mycart.GetDT(String.Format("cart_id='{0}'", CartId), "line_no")
        If mycart.isBtoOrder(CartId) And mycart.getTotalPrice_EW(CartId) > 0 Then
            Dim R As DataRow = dt.NewRow
            R.Item("line_No") = mycart.getMaxLineNo(CartId) + 1
            R.Item("category") = "Extended Warranty" : R.Item("Part_No") = Glob.getEWItemByMonth(dt.Rows(1).Item("ew_Flag"))
            R.Item("description") = "Extended Warranty" : R.Item("ew_Flag") = "0"
            R.Item("list_Price") = mycart.getTotalPrice_EW(CartId) : R.Item("unit_Price") = R.Item("list_Price")
            R.Item("qty") = dt.Rows(dt.Rows.Count - 1).Item("qty") : R.Item("req_Date") = Now.ToShortDateString
            R.Item("due_Date") = Now.ToShortDateString : R.Item("itp") = R.Item("list_Price")
            R.Item("otype") = 1 : dt.Rows.Add(R)
            R.Item("delivery_plant") = ""
        End If
        Me.gv1.DataSource = dt : Me.gv1.DataBind()
    End Sub

    Protected Sub gv_drpEW_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As DropDownList = CType(sender, DropDownList)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim month As Integer = obj.SelectedValue
        mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, id), String.Format("ew_flag='{0}'", month))
        initGV()
    End Sub
    Protected Sub btnDel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim f As Integer = 0
        For i As Integer = 0 To gv1.Rows.Count - 1
            Dim chk As CheckBox = gv1.Rows(i).FindControl("chkKey")
            If chk.Checked Then
                Dim oldLineNo As Integer = gv1.DataKeys(gv1.Rows(i).RowIndex).Value
                If oldLineNo = 100 Then
                    f = 1
                End If
            End If
        Next
        
        If f = 0 Then
            del()
        Else
            Me.MPConfigConfirm.Show()
        End If
        upbtnConfirm.Update()
    End Sub
    Protected Sub del()
        Dim count As Integer = 0
        For i As Integer = 0 To gv1.Rows.Count - 1
            Dim chk As CheckBox = gv1.Rows(i).FindControl("chkKey")
            If chk.Checked Then
                Dim oldLineNo As Integer = gv1.DataKeys(gv1.Rows(i).RowIndex).Value
                Dim newLineNo As Integer = oldLineNo - count
                mycart.Delete(String.Format("cart_id='{0}' and line_no='{1}'", CartId, newLineNo))
                mycart.reSetLineNoAfterDel(CartId, newLineNo)
                count = count + 1
            End If
        Next
        initGV()
    End Sub
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        Dim currSin As String = Session("company_currency_sign")
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim DBITEM As DataRowView = CType(e.Row.DataItem, DataRowView)
            Dim line_no As Integer = CInt(CType(e.Row.FindControl("hdLineNo"), HiddenField).Value)
            If line_no > 100 And Session("org_id") <> "US01" Then
                Dim cbDel As CheckBox = e.Row.FindControl("chkKey")
                cbDel.Visible = False
            End If
            Dim part_no As String = DBITEM.Item("part_No").ToString
            Dim ListPice As Decimal = CDbl(CType(e.Row.FindControl("lbListPrice"), Label).Text)
            Dim UnitPrice As Decimal = CDbl(CType(e.Row.FindControl("txtUnitPrice"), TextBox).Text)
            If Util.IsInternalUser(Session("user_id")) = False Then
                CType(e.Row.FindControl("txtUnitPrice"), TextBox).ReadOnly = True
            Else
                CType(e.Row.FindControl("txtUnitPrice"), TextBox).ReadOnly = False
            End If
            Dim qty As Decimal = CInt(CType(e.Row.FindControl("txtGVQty"), TextBox).Text)
            Dim Discount As Decimal = 0.0
            Dim SubTotal As Decimal = 0.0
            Dim ewPrice As Decimal = 0.0
            Dim DrpEW As DropDownList = CType(e.Row.FindControl("gv_drpEW"), DropDownList)
            If MyCartOrderBizDAL.IsSpecialADAM(part_no) Or DBITEM.Item("ew_Flag") = 99 Then
                DrpEW.Items.Clear()
                DrpEW.Items.Add(New ListItem("without EW", "0"))
                DrpEW.Items.Add(New ListItem("36 months", "99"))
            End If
           
            If DBITEM.Item("ew_Flag") = 999 Then
                DrpEW.Items.Clear()
                DrpEW.Items.Add(New ListItem("without EW", "0"))
                DrpEW.Items.Add(New ListItem("3 months", "999"))
            End If
            DrpEW.SelectedValue = DBITEM.Item("ew_Flag").ToString
            ewPrice = FormatNumber(Glob.getRateByEWItem(Glob.getEWItemByMonth(CInt(DrpEW.SelectedValue)), DBITEM.Item("delivery_Plant")) * UnitPrice, 2)
            CType(e.Row.FindControl("gv_lbEW"), TextBox).Text = ewPrice
            If ListPice = 0 Then
                e.Row.Cells(9).Text = "TBD"
                e.Row.Cells(11).Text = "TBD"
            Else
                Discount = FormatNumber((ListPice - UnitPrice) / ListPice, 2)
                e.Row.Cells(11).Text = Discount * 100 & "%"
            End If
            SubTotal = FormatNumber(qty * (UnitPrice), 2)
            e.Row.Cells(15).Text = currSin & SubTotal
            
            If mycart.isBtoParentItem(CartId, line_no) Then
                e.Row.Cells(1).Text = "" : e.Row.Cells(3).Text = "" : e.Row.Cells(5).Text = "" : e.Row.Cells(6).Text = ""
                e.Row.Cells(7).Text = "" : e.Row.Cells(8).Text = "" : e.Row.Cells(9).Text = "" : e.Row.Cells(10).Text = ""
                e.Row.Cells(11).Text = "" : e.Row.Cells(13).Text = "" 'e.Row.Cells(14).Text = ""
                e.Row.Cells(15).Text = "" ': e.Row.Cells(16).Text = ""
            End If
            If DBITEM.Item("part_No").ToString.ToLower.Contains("ags-ew") Then
                CType(e.Row.FindControl("txtUnitPrice"), TextBox).Enabled = False
                CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
                
            End If
            If mycart.isBtoChildItem(CartId, line_no) = 1 Then
                CType(e.Row.FindControl("gv_drpEW"), DropDownList).Enabled = False
                If Not MyCartOrderBizDAL.isODMCart(CartId) And Not isANA Then
                    CType(e.Row.FindControl("txtGVQty"), TextBox).Enabled = False
                End If
            End If
            If Session("Org_id") = "US01" Then
                e.Row.Cells(13).Visible = False
            End If
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            If mycart.isBtoOrder(CartId) = 0 Then
                e.Row.Cells(3).Visible = False
            End If
            e.Row.Cells(7).Visible = False : e.Row.Cells(8).Visible = False
            If mycart.isBtoOrder(CartId) = 1 Then
                e.Row.Cells(6).Visible = False
            End If
            If Session("Org_id") = "US01" Then
                e.Row.Cells(13).Visible = False
            End If
        End If
    End Sub

    Protected Sub txtCustPN_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value

        'Dim CustPN As String = Util.ReplaceSQLStringFunc(obj.Text.Trim)
        'mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, id), String.Format("CustMaterial='{0}'", CustPN))
        ''Frank 2012/09/20:Do not change any character in customer part number string
        Dim CustPN As String = obj.Text.Trim, _mcartda As New MyCartDSTableAdapters.CART_DETAILTableAdapter
        _mcartda.UpdateCustMaterialByLineNo(CustPN, CartId, id)
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
            Exit Sub
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
        mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, id), String.Format("Unit_Price='{0}'", UnitPrice))
    End Sub


    Protected Sub txtGVQty_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim Qty As String = obj.Text
        If id = 100 Then
            mycart.Update(String.Format("cart_id='{0}'", CartId), String.Format("qty='{0}'", Qty))
            '/ReCalDueDateForEachLine/'
        Else
            mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, id), String.Format("qty='{0}'", Qty))
            ReCalDue(CartId, id)
        End If
        
    End Sub

    Protected Sub txtreqdate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim req_date As Date = CDate(obj.Text)
        mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, id), String.Format("req_date='{0}'", req_date))
        ReCalDue(CartId, id)
    End Sub
    
    Sub ReCalDue(ByVal cart_id As String, ByVal line_no As String)
        Dim dt As DataTable = mycart.GetDT(String.Format("cart_id='{0}' and line_no='{1}'", CartId, line_no), "")
        If dt.Rows.Count = 1 Then
            Dim part_no As String = dt.Rows(0).Item("part_no"), plant As String = dt.Rows(0).Item("delivery_plant")
            Dim qty As String = dt.Rows(0).Item("qty"), req_date As String = dt.Rows(0).Item("req_date")
            Dim duedate As String = "", inventory As Integer = 0, satisflag As Integer = 0, qtyCanbeConfirmed As Integer = 0
            SAPtools.getInventoryAndATPTable(dt.Rows(0).Item("part_no"), dt.Rows(0).Item("delivery_plant"), dt.Rows(0).Item("qty"), duedate, inventory, New DataTable, req_date, satisflag, qtyCanbeConfirmed)
            mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", CartId, line_no), String.Format("due_date='{0}',inventory='{1}',SatisfyFlag='{2}',CanbeConfirmed='{3}'", duedate, inventory, satisflag, qtyCanbeConfirmed))
        End If
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        initGV()
        Me.gv1.DataBind()
    End Sub

    Protected Sub ibSave_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim CHNO As String = myCartHistory.SaveCartHistory(Util.ReplaceSQLStringFunc(Me.txtCartDesc.Text.Trim), 0)
        Response.Redirect("~/Order/CartHistory_List.aspx")
    End Sub

    Protected Sub btnOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If mycart.getMaxLineNo(CartId) = 0 Then
            Glob.ShowInfo("Please add part number to cart first.")
            Exit Sub
        End If
        Response.Redirect("~/Order/OrderInfo.aspx")
    End Sub
    
    Protected Sub ibtnSeqUp_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim line_no As Integer = obj.CommandName
        mycart.exChangeLineNo(CartId, line_no, line_no - 1)
        initGV()
        
    End Sub

    Protected Sub ibtnSeqDown_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As LinkButton = CType(sender, LinkButton)
        Dim line_no As Integer = obj.CommandName
        mycart.exChangeLineNo(CartId, line_no, line_no + 1)
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
                    Dim ORDER_LINE_TYPE As String = r.Item("otype"), QTY As Integer = r.Item("qty"), LIST_PRICE As Decimal = r.Item("list_price")
                    Dim UNIT_PRICE As Decimal = r.Item("unit_price"), REQUIRED_DATE As Date = r.Item("req_date"), DUE_DATE As Date = r.Item("due_date")
                    Dim ERP_SITE As String = "", ERP_LOCATION As String = "", AUTO_ORDER_FLAG As Char = ""
                    Dim AUTO_ORDER_QTY As Integer = 0, SUPPLIER_DUE_DATE As Date = DUE_DATE, LINE_PARTIAL_FLAG As Integer = 0
                    Dim RoHS_FLAG As String = r.Item("rohs"), EXWARRANTY_FLAG As String = r.Item("ew_flag")
                    Dim CustMaterialNo As String = r.Item("custMaterial"), DeliveryPlant As String = r.Item("delivery_plant")
                    Dim NoATPFlag As String = r.Item("satisfyflag"), DMF_Flag As String = "", OptyID As String = r.Item("QUOTE_ID"), RTB As DataRow = TB.NewRow
                   
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
               
                    If CInt(EXWARRANTY_FLAG) > 0 Then
                        count = count + 1
                        If ORDER_LINE_TYPE <> -1 Then
                            Dim EWR As DataRow = dtEW.NewRow
                            With EWR
                                .Item("line_no") = LINE_NO + count : .Item("part_no") = Glob.getEWItemByMonth(EXWARRANTY_FLAG)
                                .Item("Description") = Glob.getEWItemByMonth(EXWARRANTY_FLAG) + " For " + PART_NO
                                .Item("otype") = ORDER_LINE_TYPE : .Item("qty") = QTY
                                .Item("req_date") = REQUIRED_DATE : .Item("due_date") = DUE_DATE
                                .Item("islinePartial") = LINE_PARTIAL_FLAG
                                .Item("unit_price") = Glob.getRateByEWItem(Glob.getEWItemByMonth(EXWARRANTY_FLAG), DeliveryPlant) * UNIT_PRICE
                                .Item("delivery_plant") = DeliveryPlant : .Item("DMF_Flag") = DMF_Flag : .Item("OptyID") = OptyID
                            End With
                            dtEW.Rows.Add(EWR)
                        End If
                    End If
                Next
                If dtEW.Rows.Count > 0 Then
                    If mycart.isBtoOrder(CartId) Then
                        Dim Line_no As Integer = mycart.getMaxLineNo(CartId) + 1
                        Dim part_no As String = dtEW.Rows(0).Item("part_no")
                        Dim otype As Integer = dtEW.Rows(0).Item("otype")
                        Dim qty As Integer = dtEW.Rows(0).Item("qty")
                        Dim req_date As DateTime = mycart.getMaxReqDate(CartId)
                        Dim due_date As DateTime = mycart.getMaxDueDate(CartId)
                        Dim linePartialFlag As Integer = dtEW.Rows(0).Item("islinePartial")
                        Dim unit_Price As Decimal = dtEW.Compute("sum(unit_price)", "")
                        Dim delivery_plant As String = dtEW.Rows(0).Item("delivery_plant")
                        Dim dmf_flag As String = dtEW.Rows(0).Item("DMF_Flag")
                        Dim optyid As String = dtEW.Rows(0).Item("OptyID")
                        Dim RTB As DataRow = TB.NewRow
                   
                        RTB.Item("LINE_NO") = Line_no
                        RTB.Item("PRODUCT_LINE") = ""
                        RTB.Item("PART_NO") = part_no
                        RTB.Item("Description") = dtEW.Rows(0).Item("Description")
                        RTB.Item("QTY") = qty
                        RTB.Item("LIST_PRICE") = unit_Price
                        RTB.Item("UNIT_PRICE") = unit_Price
                        RTB.Item("Discount") = "0"
                        RTB.Item("REQUIRED_DATE") = req_date
                        RTB.Item("DUE_DATE") = due_date
                        RTB.Item("CustMaterialNo") = ""
                        RTB.Item("DeliveryPlant") = delivery_plant
                    
                        TB.Rows.Add(RTB)
                        'myOrderDetail.Add(ORDER_ID, Line_no, "", part_no, otype, qty, unit_Price, unit_Price, req_date, due_date, "", "", "", 0, due_date, linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid)
                    Else
                        Dim MlineNo As Integer = mycart.getMaxLineNo(CartId)
                        Dim N As Integer = 0
                        For Each r As DataRow In dtEW.Rows
                            N = N + 1
                            Dim line_no As Integer = MlineNo + N, part_no As String = r.Item("part_no"), otype As Integer = r.Item("otype")
                            Dim qty As Integer = r.Item("qty"), req_date As DateTime = r.Item("req_date"), due_date As DateTime = r.Item("due_date")
                            Dim linePartialFlag As Integer = r.Item("islinePartial"), unit_price As Decimal = r.Item("unit_price")
                            Dim delivery_plant As String = r.Item("delivery_plant"), dmf_flag As String = r.Item("DMF_Flag")
                            Dim optyid As String = r.Item("OptyID"), RTB As DataRow = TB.NewRow
                            With RTB
                                .Item("LINE_NO") = line_no : .Item("PRODUCT_LINE") = "" : .Item("PART_NO") = part_no
                                .Item("Description") = r.Item("Description") : .Item("QTY") = qty : .Item("LIST_PRICE") = unit_price
                                .Item("UNIT_PRICE") = unit_price : .Item("Discount") = "0" : .Item("REQUIRED_DATE") = req_date
                                .Item("DUE_DATE") = due_date : .Item("CustMaterialNo") = "" : .Item("DeliveryPlant") = delivery_plant
                            End With
                    
                            TB.Rows.Add(RTB)
                        Next
                    End If
                End If
            End If
            
            Util.DataTable2ExcelDownload(TB, "MyCart.xls")
        End If
    End Sub
    
    Protected Sub lbtnCartHistory_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/Order/CartHistory_list.aspx")
    End Sub
    
   
    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sAmt As Decimal = mycart.getTotalAmount(CartId)
        Dim ewAmt As Decimal = mycart.getTotalAmount_EW(CartId)
      
        Me.lbtotal.Text = FormatNumber(sAmt + ewAmt, 2)
    End Sub
    
    Private Sub Source_path()
        Dim DT As DataTable = mycart.GetDT(String.Format("CART_ID='{0}' AND OTYPE='-1'", CartId), "")
        
        If DT.Rows.Count > 0 Then
            Dim strhtml As String = ""
           
            If Request("UID") IsNot Nothing AndAlso Trim(Request("UID")) <> "" Then
                strhtml = "<font color='Navy'>■</font>&nbsp;&nbsp;<a href='../eQuotation/QuotationDetail.aspx?UID=" + Trim(Request("UID")) + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>Quotation Detail</a><b>&nbsp;&nbsp;>&nbsp;&nbsp;</b>" + _
                "<a href='./btos_portal.aspx?UID=" + Trim(Request("UID")) + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>BTOS/CTOS Portal</a> <b>&nbsp;&nbsp;>&nbsp;&nbsp;</b>" + _
                "<a href='./CBOM_List.aspx?Catalog_Type=" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "&UID=" + Trim(Request("UID")) + "&SPR=' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "</a> <b>&nbsp;&nbsp;>&nbsp;&nbsp;</b>" + _
                "<a href='./Configurator.aspx?BTOITEM=" + Trim(DT.Rows(0).Item("PART_NO")) + "&QTY=" + Trim(DT.Rows(0).Item("QTY")) + "' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>" + Trim(DT.Rows(0).Item("PART_NO")) + "</a>"
           
            Else
                strhtml = "<font color='Navy'>■</font>&nbsp;&nbsp;<a href='./btos_portal.aspx' target='_self' style='color:Navy;font-weight:bold; text-decoration:none;'>System Configuration/Ordering Portal</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>" + _
                 "<a href='./CBOM_List.aspx?Catalog_Type=" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "' target='_self' style='color:Navy;font-weight:bold;text-decoration:none;'>" + get_catalog_type(Trim(DT.Rows(0).Item("PART_NO"))) + "</a><strong>&nbsp;&nbsp;>&nbsp;&nbsp;</strong>" + _
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
    Public Function CheckITPZero(ByVal UID As String) As Dictionary(Of String, Boolean)
        Dim o As New Dictionary(Of String, Boolean)
        Dim dt As New DataTable
        dt = mycart.GetDT(String.Format("cart_id='{0}'", CartId), "line_no")
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            For Each r As DataRow In dt.Rows
                If r.Item("itp") = 0 Then
                    If r.Item("otype") <> -1 AndAlso (SAPDAL.CommonLogic.NoStandardSensitiveITP(r.Item("part_no")) = False) Then
                        If Not o.ContainsKey(r.Item("part_no")) Then
                            o.Add(r.Item("part_No"), True)
                        End If
                    End If
                End If
            Next
        End If
        Return o
    End Function
    Public Sub ForbidConfirm(ByVal type As Boolean, ByVal msg As String)
        Me.btnOrder.Enabled = type
        Me.lbConfirmMsg.Text = msg
        upbtnConfirm.Update()
    End Sub
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim type As Boolean = True
        Dim msg As String = ""
        ' check items with zero itp
        If isJPAonline Then
            Dim isZITP As New Dictionary(Of String, Boolean)
            isZITP = CheckITPZero(CartId)
            If isZITP.Count > 0 Then
                type = False
                msg = "Item(s): "
                For Each r As KeyValuePair(Of String, Boolean) In isZITP
                    msg &= "'" & r.Key & "' "
                Next
                msg &= "is(are) with zero ITP, please remove them from cart to enable the confirm button."
            End If
        End If
        '/ check items with zero itp
        ForbidConfirm(type, msg)
    End Sub
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function CheckIfReconfigurable() As String
        Dim apt As New SqlClient.SqlDataAdapter( _
            " select top 1 a.ROW_ID  " + _
            " from eQuotation.dbo.CTOS_CONFIG_LOG a inner join MyAdvantechGlobal.dbo.CART_DETAIL b  " + _
            " on a.CART_ID=b.Cart_Id and a.ROOT_CATEGORY_ID=b.Part_No  " + _
            " where a.CART_ID=@CID and b.Line_No=100 and a.USERID=@UID and a.COMPANY_ID=@ERPID " + _
            " order by a.CONFIG_DATE desc ", _
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
    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
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
        }
        );
    </script>
    <table width="100%">
        <tr>
            <td>
                <span style="width: 41%;" id="page_path" runat="server"></span>
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
                                        <td class="h5">
                                            Part No:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtPartNo" Width="250"></asp:TextBox>
                                            <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" TargetControlID="txtPartNo"
                                                ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetPartNo" MinimumPrefixLength="2">
                                            </ajaxToolkit:AutoCompleteExtender>
                                        </td>
                                        <td>
                                            <asp:ImageButton ID="ibtnAvilability" runat="server" ImageUrl="~/images/availability.gif"
                                                OnClick="ibtnAvilability_Click" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="h5">
                                            Quantity:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtQty" Width="50" Text="1"></asp:TextBox>
                                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft3" TargetControlID="txtQty"
                                                FilterType="Numbers, Custom" />
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                    <tr id="trUP" runat="server">
                                        <td class="h5">
                                            Unit Price:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtPrice" Width="80" Text=""></asp:TextBox>
                                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1"
                                                TargetControlID="txtPrice" FilterType="Numbers,Custom" ValidChars="." />
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="h5">
                                            Extended Warranty:
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="drpEW" runat="server">
                                                <asp:ListItem Text="without extended warranty" Value="0" Selected="true"></asp:ListItem>
                                                <asp:ListItem Text="3 months" Value="3"></asp:ListItem>
                                                <asp:ListItem Text="6 months" Value="6"></asp:ListItem>
                                                <asp:ListItem Text="9 months" Value="9"></asp:ListItem>
                                                <asp:ListItem Text="12 months" Value="12"></asp:ListItem>
                                                <asp:ListItem Text="15 months" Value="15"></asp:ListItem>
                                                <asp:ListItem Text="24 months" Value="24"></asp:ListItem>
                                                <asp:ListItem Text="36 months" Value="36"></asp:ListItem>
                                            </asp:DropDownList>
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" align="left">
                                            <asp:Label runat="server" ID="lbAddErrMsg" ForeColor="Tomato" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                        </td>
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
            <td class="menu_title">
                My Shopping Cart
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
                        </td>
                    </tr>
                </table>
                <div style="width: 890px; overflow: scroll; overflow-y: hidden">
                    <asp:UpdatePanel ID="upGV1" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:HiddenField ID="HF_IsBTOS" runat="server" Value="0" />
                            <asp:Label runat="server" ID="LabWarn" Visible="false" ForeColor="Tomato" />
                            <div id="divReconfigBtn" style="display:none"></div>
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
                                                            Font-Bold="true" OnClick="ibtnSeqUp_Click" Text="↑" />
                                                    </td>
                                                    <td>
                                                        <asp:LinkButton runat="server" CommandName='<%#Bind("line_no")%>' ID="ibtnSeqDown"
                                                            Font-Bold="true" OnClick="ibtnSeqDown_Click" Text="↓" />
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
                                    <asp:TemplateField HeaderText="Extended Warranty">
                                        <ItemTemplate>
                                            <asp:DropDownList ID="gv_drpEW" runat="server" AutoPostBack="true" OnSelectedIndexChanged="gv_drpEW_SelectedIndexChanged">
                                                <asp:ListItem Text="without EW" Value="0"></asp:ListItem>
                                                <asp:ListItem Text="3 months" Value="3"></asp:ListItem>
                                                <asp:ListItem Text="6 months" Value="6"></asp:ListItem>
                                                <asp:ListItem Text="9 months" Value="9"></asp:ListItem>
                                                <asp:ListItem Text="12 months" Value="12"></asp:ListItem>
                                                <asp:ListItem Text="15 months" Value="15"></asp:ListItem>
                                                <asp:ListItem Text="24 months" Value="24"></asp:ListItem>
                                                <asp:ListItem Text="36 months" Value="36"></asp:ListItem>
                                            </asp:DropDownList>
                                            <asp:Label runat="server" Text='<%# Session("company_currency_sign")%>' ID="lbEWSign"></asp:Label>
                                            <asp:TextBox runat="server" ID="gv_lbEW" Style="text-align: right" BorderWidth="1px"
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
                                            <asp:Label runat="server" Text='<%# Session("company_currency_sign")%>' ID="lbListPriceSign"></asp:Label>
                                            <asp:Label runat="server" Text='<%#FormatNumber(Eval("list_price"),2) %>' ID="lbListPrice"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                        <HeaderTemplate>
                                            Unit Price
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Label runat="server" Text='<%# Session("company_currency_sign")%>' ID="lbUnitPriceSign"></asp:Label>
                                            <asp:TextBox ID="txtUnitPrice" runat="server" Text='<%#replace(FormatNumber(Eval("unit_price"),2),",","") %>'
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
                                            <asp:TextBox ID="txtreqdate" name="txtreqdate" runat="server" Text='<%# iif(isANA,CDate(Eval("req_date")).toString("MM/dd/yyyy"),CDate(Eval("req_date")).toString("yyyy/MM/dd")) %>'
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
                                            <asp:Label runat="server" Text='<%# iif(CDate(Eval("due_date")).toString("yyyy/MM/dd")="1900/01/01","TBD",iif(isANA,CDate(Eval("due_date")).toString("MM/dd/yyyy"),CDate(Eval("due_date")).toString("yyyy/MM/dd"))  ) %>'
                                                ID="lbDueDate"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="" HeaderText="Sub Total" ItemStyle-HorizontalAlign="right" />
                                    <asp:TemplateField HeaderText="Customer PN.">
                                        <ItemTemplate>
                                            <asp:TextBox runat="server" ID="txtCustPN" Text='<%#Server.HtmlDecode(Eval("custMaterial").toString()) %>'
                                                OnTextChanged="txtCustPN_TextChanged" Width="80px"></asp:TextBox>
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
                                                <td>
                                                    <b>Total:</b>
                                                </td>
                                                <td>
                                                    <%= HttpContext.Current.Session("company_currency_sign")%><asp:Label runat="server"
                                                        ID="lbtotal" Text="0.00"></asp:Label>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnConfigConfirm" />
                            <asp:AsyncPostBackTrigger ControlID="btnDel" />
                            <asp:AsyncPostBackTrigger ControlID="btnUpdate" />
                        </Triggers>
                    </asp:UpdatePanel>
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
                        <asp:Label runat="server" ForeColor="Red" ID="lbConfirmMsg" Text=""></asp:Label>
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
            Url = Url + "?Element=" + Element.name + "&SelectedDate=" + Element.value + "&IsBTOS=<%=Me.HF_IsBTOS.value%>";
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
       
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
