<%@ Page Title="MyAdvantech - Due Date Calculation" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    ValidateRequest="false" %>

<%@ Import Namespace="System.Globalization" %>
<script runat="server">
    Dim myOrderMaster As New order_Master("b2b", "order_master")
    Dim myOrderDetail As New order_Detail("b2b", "order_detail")
    Dim myCompany As New SAP_Company("b2b", "sap_dimcompany")
    Dim myProduct As New SAPProduct("b2b", "sap_product")
    Dim mycart As New CartList("b2b", "cart_detail")
    Dim _OrderID As String = "", CurrencySign As String = String.Empty
    Dim CheckPoint_Convert2Order As String = ""

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        'Ryan 20151223 Check whether page called from Check-Point convert2order or not
        If Not String.IsNullOrEmpty(Request("CheckPoint_Convert2Order")) Then
            CheckPoint_Convert2Order = Request("CheckPoint_Convert2Order")
        End If

        '把預設按鈕指定給空按鈕，防止ENTER發生Logout
        Me.Page.Form.DefaultButton = btn_enter.UniqueID

        _OrderID = Request("NO") : CurrencySign = MyOrderX.GetCurrencySign(_OrderID)
        If Not IsNothing(Request("NO")) AndAlso Request("NO") <> "" And Not IsPostBack Then
            initInterface()
            '20111128 TC: Check if there is any item's status=O, and if yes, if the order qty<=ATP qty, if not, disable Confirm button and show warning message
            'CheckStatusOItemATP()
            If OrderUtilities.IsDirect2SAP() Then
                Me.btnConfirm_Click(Me.btnConfirm, Nothing)
            End If
        End If
        'Session("ORDER_ID")
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        'Ryan 20151222 Add for Check-Point convert2order event check. If true, perform auto click
        If (Not String.IsNullOrEmpty(CheckPoint_Convert2Order)) AndAlso (CheckPoint_Convert2Order = HttpContext.Current.Session("cart_id")) Then
            btnConfirm_Click(btnConfirm, e)
        End If
    End Sub

    'Sub CheckStatusOItemATP()
    '    lbMsg.Text = ""
    '    Dim orderId As String = Trim(Request("NO")), OrgId As String = Session("org_id")
    '    Dim strSql As String = _
    '        " select a.part_no, sum(a.QTY) as ORDER_QTY,  " + _
    '        " IsNull((select sum(z.ATP_QTY) from SAP_PRODUCT_ATP z where z.PART_NO=a.PART_NO and z.SALES_ORG='" + Session("org_id") + "'),0) as ATP_QTY " + _
    '        " from ORDER_DETAIL a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO  " + _
    '        " where a.ORDER_ID='" + orderId + "' and b.ORG_ID='" + OrgId + "' and b.STATUS in ('O') " + _
    '        " group by a.PART_NO  "
    '    Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
    '    If dt.Rows.Count > 0 Then
    '        Dim sbWarnMsg As New System.Text.StringBuilder
    '        For Each r As DataRow In dt.Rows
    '            Dim strTmpPN As String = r.Item("part_no")
    '            Dim intTmpOrderQty As Integer = CInt(r.Item("ORDER_QTY")), intTmpATPQty As Integer = CInt(r.Item("ATP_QTY"))
    '            If intTmpOrderQty > 0 And intTmpOrderQty > intTmpATPQty Then
    '                If btnConfirm.Enabled Then btnConfirm.Enabled = False
    '                sbWarnMsg.AppendLine(String.Format("{0} is phased out inventory qty {1} is less than order qty {2}<br/>", _
    '                                                   strTmpPN, intTmpATPQty.ToString(), intTmpOrderQty.ToString()))
    '            End If
    '        Next
    '        If btnConfirm.Enabled = False Then lbMsg.Text = sbWarnMsg.ToString()
    '    End If
    'End Sub

    Sub initInterface()
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
        'Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Request("NO")), "line_no")
        Dim _orderlist As List(Of OrderItem) = MyOrderX.GetOrderList(_OrderID)
        If dtMaster.Rows.Count > 0 And _orderlist.Count > 0 Then
            litorderinfo.Text = Util.GetAscxStr(Request("NO"), 0) + Util.GetAscxStr(Request("NO"), 1)
        End If
        If _orderlist.Count = 0 Then
            Glob.ShowInfo("There are no products in your shopping cart.")
            btnConfirm.Enabled = False : btnUpdate.Visible = False
            Exit Sub
        Else
            btnConfirm.Enabled = True : btnUpdate.Visible = True
            'CheckStatusOItemATP()
        End If
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        'Dim _NextWeekShipDate As Date
        'For Each i As OrderItem In _orderlist
        '    If i.ItemTypeX = OrderItemType.BtosParent Then
        '        i.DUE_DATE = CDate(i.ChildMaxDueDateAddBTOWorkingDateX)
        '    End If
        '    If i.ItemTypeX = OrderItemType.Part Then
        '        If CDate(i.REQUIRED_DATE) = MyUtil.Current.CurrentLocalTime Then
        '            If MyCartOrderBizDAL.GetNextWeeklyShippingDate(i.REQUIRED_DATE, _NextWeekShipDate) Then
        '                i.REQUIRED_DATE = _NextWeekShipDate
        '            End If
        '        End If
        '    End If
        '    ReCalDue(_OrderID, i.LINE_NO)
        'Next
        'MyUtil.Current.CurrentDataContext.SubmitChanges()
        ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        'Frank 2013/06/04
        'If myOrderDetail.isBtoOrder(Request("NO")) Then
        '    Me.HF_IsBTOS.Value = "1"

        '    Dim _MaxComponentDueDate As Date = myOrderDetail.getMaxDueDateWithout100Line(Request("NO"))
        '    Dim MDUEDATE As String = MyCartOrderBizDAL.getBTOParentDueDate(_MaxComponentDueDate.ToString("yyyy/MM/dd"))
        '    myOrderDetail.Update(String.Format("order_id='{0}' and line_no=100", Request("NO")), String.Format("DUE_DATE='{0}'", MDUEDATE))

        'Else
        '    Me.HF_IsBTOS.Value = "0"
        '    'Frank 2013/06/04: Detecting require date

        '    Dim _IsNeedReloadQD As Boolean = False
        '    Dim dtDetail As New DataTable
        '    For Each _row As DataRow In dtDetail.Rows
        '        '20131105 JJ: If company id has weekly ship date setup in SAP, then get nearest ship week date
        '        Dim tmpNextWeekShipDate As Date = Today
        '        'If require date is today, then update it to next working date
        '        Dim _NextWorkingDate As Date = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, Today), Session("org_id"))
        '        If Format(_row.Item("REQUIRED_DATE"), "yyyyMMdd") = _NextWorkingDate.ToString("yyyyMMdd") Then
        '            If Not Session("org_id") Is Nothing AndAlso Session("org_id") = "EU10" Then
        '                If MyCartOrderBizDAL.GetNextWeeklyShippingDate(_NextWorkingDate, tmpNextWeekShipDate) Then _NextWorkingDate = tmpNextWeekShipDate.ToString("yyyy/MM/dd")
        '            End If
        '            myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), _row.Item("LINE_NO")), String.Format("required_date='{0}'", _NextWorkingDate))
        '            ReCalDue(Request("NO"), _row.Item("LINE_NO"))
        '            _IsNeedReloadQD = True
        '        End If
        '    Next
        '    If _IsNeedReloadQD Then
        '        dtDetail = myOrderDetail.GetDT(String.Format("order_id='{0}'", Request("NO")), "line_no")
        '    End If
        'End If

        Me.gv1.DataSource = _orderlist : Me.gv1.DataBind()
    End Sub
    Public Function getDueDetail() As String
        Return ""
        Dim str As String = ""
        Dim dt As New DataTable
        dt = myOrderDetail.GetDT(String.Format("order_id='{0}'", Request("NO")), "line_no")
        If dt.Rows.Count > 0 Then
            Dim Mdue As Date = Now.Date
            str &= "<table><tr><td>Without Btos Process</td></tr><tr><td><table>"
            For Each x As DataRow In dt.Rows
                str &= "<tr>"
                str &= "<td>" & x.Item("line_no") & "</td>"
                str &= "<td>" & x.Item("part_no") & "</td>"
                str &= "<td>" & x.Item("qty") & "</td>"
                str &= "<td>" & IIf(CDate(x.Item("due_date")).ToString("yyyy/MM/dd") = "1900/01/01", "TBD", CDate(x.Item("due_date")).ToString("yyyy/MM/dd")) & "</td>"
                str &= "<td>" & x.Item("deliveryplant") & "</td>"
                str &= "</tr>"
                If Mdue < x.Item("due_date") Then
                    Mdue = x.Item("due_date")
                End If
            Next
            str &= "</table></td></tr></table>"
            str &= "<br/>"
            str &= "<table><tr><td>After Btos Process</td></tr><tr><td><table>"
            For Each x As DataRow In dt.Rows
                str &= "<tr>"
                str &= "<td>" & x.Item("line_no") & "</td>"
                str &= "<td>" & x.Item("part_no") & "</td>"
                str &= "<td>" & x.Item("qty") & "</td>"
                str &= "<td>" & Mdue.ToString("yyyy/MM/dd") & "</td>"
                str &= "<td>" & x.Item("deliveryplant") & "</td>"
                str &= "</tr>"
            Next
            str &= "</table></td></tr></table>"
        End If

        Return str
    End Function

    Sub updateDueDateByCustCal()
        Dim dt As New DataTable
        dt = myOrderDetail.GetDT(String.Format("Order_Id='{0}'", Request("NO")), "line_no")
        If dt.Rows.Count > 0 Then
            For Each r As DataRow In dt.Rows
                r.Item("due_date") = Glob.getNextCustDelDate(r.Item("due_date"))
            Next
            dt.AcceptChanges()
            myOrderDetail.Delete(String.Format("Order_Id='{0}'", Request("NO")))
            Dim bk1 As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            bk1.DestinationTableName = "ORDER_DETAIL"
            bk1.WriteToServer(dt)
        End If
    End Sub
    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.UpdateRequireDate()
        Me.UpdateBTOSRequireAndDueDate()
        Me.OverwriteBTOSPartsReqDate()
        Me.initInterface()
    End Sub
    Protected Sub UpdateRequireDate()
        '\ Ming 2010-10-8 因UZISCHE01 要直接接受user輸入的Required Date，所以不用再重新计算Required Date
        If String.Equals(Session("COMPANY_ID"), "UZISCHE01", StringComparison.CurrentCultureIgnoreCase) Then
            Exit Sub
        End If
        '/ end
        For Each gvr As GridViewRow In gv1.Rows
            Dim reqTB As TextBox = CType(gvr.FindControl("txtreqdate"), TextBox)
            If Date.TryParse(reqTB.Text, Now) = False Then Exit Sub
            Dim req_date As Date = CDate(reqTB.Text)
            Dim LineNO As String = gv1.DataKeys(gvr.DataItemIndex).Value.ToString.Trim
            Dim item As OrderItem = MyOrderX.GetOrderItem(_OrderID, LineNO)
            If item IsNot Nothing AndAlso item.ItemTypeX <> OrderItemType.BtosPart Then
                item.REQUIRED_DATE = req_date
            End If
        Next
        MyUtil.Current.MyAContext.SubmitChanges()
        Dim _orderlist As List(Of OrderItem) = MyOrderX.GetOrderList(_OrderID)
        For Each i As OrderItem In _orderlist
            If i.ItemTypeX = OrderItemType.BtosParent Then
                For Each oitem As OrderItem In i.ChildListX
                    oitem.REQUIRED_DATE = MyCartOrderBizDAL.getCompNextWorkDate(i.REQUIRED_DATE, Session("org_id"), -(Glob.getBTOWorkingDate()))
                Next
            End If
        Next
        MyUtil.Current.MyAContext.SubmitChanges()
        For Each i As OrderItem In _orderlist
            ReCalDue(_OrderID, i.LINE_NO)
        Next
    End Sub
    Sub ReCalDue(ByVal order_id As String, ByVal line_no As String)
        Dim item As OrderItem = MyOrderX.GetOrderItem(order_id, line_no)
        Dim duedate As DateTime = item.DUE_DATE
        If item IsNot Nothing AndAlso item.ItemTypeX <> OrderItemType.BtosParent Then
            'If item.ItemTypeX = OrderItemType.BtosParent Then
            '    duedate = item.ChildMaxDueDateX
            'End If
            'If item.ItemTypeX = OrderItemType.BtosPart AndAlso item.IsEWpartnoX Then
            '    Dim BtosItem As OrderItem = MyOrderX.GetOrderItem(order_id, item.HigherLevel)
            '    If BtosItem IsNot Nothing Then
            '        duedate = BtosItem.ChildMaxDueDateX
            '    End If
            'End If
            If Not (item.ItemTypeX = OrderItemType.BtosPart AndAlso item.IsEWpartnoX) Then
                If item.ItemTypeX = OrderItemType.Part AndAlso item.IsEWpartnoX Then
                    Dim PartItem As OrderItem = MyOrderX.GetOrderItem(order_id, Integer.Parse(line_no) - 1)
                    If PartItem IsNot Nothing Then
                        duedate = PartItem.DUE_DATE
                    End If
                End If
                If Not item.IsEWpartnoX AndAlso (item.ItemTypeX = OrderItemType.Part OrElse item.ItemTypeX = OrderItemType.BtosPart) Then
                    SAPtools.getInventoryAndATPTable(item.PART_NO, item.DeliveryPlant, item.QTY, duedate, 0, Nothing, item.REQUIRED_DATE)
                End If
                item.DUE_DATE = CDate(duedate)
                MyUtil.Current.MyAContext.SubmitChanges()
            End If

        End If
    End Sub
    Protected Sub UpdateBTOSRequireAndDueDate()
        '=============Process future require date for EU btos order=========================
        '\ Ming 2010-10-8 因UZISCHE01 要直接接受user輸入的Required Date，所以不用再重新计算Required Date
        If String.Equals(Session("COMPANY_ID"), "UZISCHE01", StringComparison.CurrentCultureIgnoreCase) Then
            Exit Sub
        End If
        '/ end
        Dim _orderlist As List(Of OrderItem) = MyOrderX.GetOrderList(_OrderID)
        For Each i As OrderItem In _orderlist
            If i.ItemTypeX = OrderItemType.BtosParent Then
                '  i.DUE_DATE = CDate(i.ChildMaxDueDateAddBTOWorkingDateX)

                If CDate(i.REQUIRED_DATE) >= CDate(i.ChildMaxDueDateAddBTOWorkingDateX) Then
                    'i.REQUIRED_DATE = i.REQUIRED_DATE ' CDate(i.ChildMaxDueDateAddBTOWorkingDateX)
                    Dim _BeforeAssemblyWorkday As Date = MyCartOrderBizDAL.getCompNextWorkDate(i.REQUIRED_DATE, Session("org_id"), -(Glob.getBTOWorkingDate()))
                    For Each item As OrderItem In i.ChildListX
                        item.REQUIRED_DATE = _BeforeAssemblyWorkday
                        item.DUE_DATE = _BeforeAssemblyWorkday 'MyCartOrderBizDAL.getCompNextWorkDate(i.REQUIRED_DATE, Session("org_id"), -(Glob.getBTOWorkingDate()))
                    Next
                    i.DUE_DATE = CDate(i.ChildMaxDueDateAddBTOWorkingDateX)
                Else
                    ' i.REQUIRED_DATE = CDate(i.ChildMaxDueDateAddBTOWorkingDateX)
                    i.DUE_DATE = CDate(i.ChildMaxDueDateAddBTOWorkingDateX)
                    For Each item As OrderItem In i.ChildListX
                        item.REQUIRED_DATE = MyCartOrderBizDAL.getCompNextWorkDate(i.REQUIRED_DATE, Session("org_id"), -(Glob.getBTOWorkingDate()))
                        ' item.DUE_DATE = MyCartOrderBizDAL.getCompNextWorkDate(i.REQUIRED_DATE, Session("org_id"), -(Glob.getBTOWorkingDate()))
                        If item.IsEWpartnoX Then
                            item.DUE_DATE = i.DUE_DATE
                        End If
                    Next
                End If

            End If
            'ReCalDue(_OrderID, i.LINE_NO)
        Next
        MyUtil.Current.MyAContext.SubmitChanges()
    End Sub

    Protected Sub OverwriteBTOSPartsReqDate()
        'Ryan 20170627 Add to overwrite all btos parts items' required date
        'For ACN, all BTOS child's req date are BTOS parent req date.
        'For AJP, all BTOS child's req date can't be earlier than today+1
        If Session("org_id").ToString.ToUpper.StartsWith("CN") AndAlso MyOrderX.IsHaveBtos(_OrderID) Then
            Dim OrderList As List(Of OrderItem) = MyOrderX.GetOrderList(_OrderID)
            Dim BTOSParent As OrderItem = OrderList.Where(Function(p) p.ORDER_LINE_TYPE = -1).FirstOrDefault

            If Not BTOSParent Is Nothing Then
                OrderList.Where(Function(p) p.HigherLevel = BTOSParent.LINE_NO).ToList().ForEach(Sub(p) p.REQUIRED_DATE = BTOSParent.REQUIRED_DATE)
            End If
            MyUtil.Current.MyAContext.SubmitChanges()
        ElseIf Session("org_id").ToString.ToUpper.Equals("JP01") AndAlso MyOrderX.IsHaveBtos(_OrderID) Then
            Dim _orderlist As List(Of OrderItem) = MyOrderX.GetOrderList(_OrderID)
            For Each i As OrderItem In _orderlist
                If i.ItemTypeX = OrderItemType.BtosParent Then
                    Dim NextWorkingDate As DateTime = MyCartOrderBizDAL.getCompNextWorkDateV2(Date.Now, Session("org"), 1)
                    For Each oitem As OrderItem In i.ChildListX
                        If oitem.REQUIRED_DATE < NextWorkingDate Then
                            oitem.REQUIRED_DATE = NextWorkingDate
                        End If
                    Next
                End If
            Next
            MyUtil.Current.MyAContext.SubmitChanges()
        End If
    End Sub

    Protected Sub btnConfirm_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'TC:按下Next button時也先呼叫Update button的動作將req date與customer PN update後再往下走
        '=============Process future require date for EU btos order=========================
        Me.UpdateRequireDate()
        Me.UpdateBTOSRequireAndDueDate()
        Me.OverwriteBTOSPartsReqDate()
        'End=============Process future require date for EU btos order=========================

        If Left(Session("org_id").ToString.ToUpper, 2) = "US" Then
            Me.updateDueDateByCustCal()
        End If

        'Me.UpdateBTOSRequireAndDueDate()

        'Ryan 20161206 Comment below code out due to MYLOCAL is currently unstable
        'If Session("COMPANY_ID") IsNot Nothing Then
        '    Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("SELECT top 1 COMPANY_ID FROM ADMIN_PREFERENTIAL_PRODS where COMPANY_ID ='{0}'", Session("COMPANY_ID")))
        '    If dt.Rows.Count > 0 Then
        '        AddEW()
        '    End If
        'End If
        'End comment out

        Response.Redirect("~/order/PI.aspx?NO=" & Request("NO"))
    End Sub
    Sub AddEW()
        Dim dt As DataTable = myOrderDetail.GetDT(String.Format("Order_Id='{0}'", Request("NO")), "line_no")
        If dt.Rows.Count > 0 Then
            Dim dt_Temp As DataTable = dt.Copy()
            Dim Count As Integer = 0
            For Each r As DataRow In dt_Temp.Rows
                If MyCartOrderBizDAL.IsEUStockingProgram(r.Item("part_no"), r.Item("qty")) Then
                    Count += 1
                    Dim drs() As DataRow = dt.Select(String.Format("part_no = '{0}' and line_no ={1}", r.Item("part_no"), Integer.Parse(r.Item("line_no") + Count - 1)))
                    If drs.Length <> 1 Then Exit Sub
                    If drs.Length = 1 Then
                        dt = AddEWforDT(dt, drs(0)) : dt.AcceptChanges()
                    End If
                End If
            Next
            myOrderDetail.Delete(String.Format("Order_Id='{0}'", Request("NO")))
            Dim bk1 As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            bk1.DestinationTableName = "ORDER_DETAIL"
            bk1.WriteToServer(dt)
        End If
    End Sub
    Public Function AddEWforDT(ByVal dt As DataTable, ByVal PartNoRow As DataRow) As DataTable
        If dt.Rows.Count > 0 Then
            Dim linenoTemp As Integer = 0
            linenoTemp = PartNoRow.Item("line_no") : PartNoRow.BeginEdit() : PartNoRow.Item("EXWARRANTY_FLAG") = "3" : PartNoRow.EndEdit()
            Dim drsTemp() As DataRow = dt.Select("line_no > " + linenoTemp.ToString() + "")
            For i As Integer = 0 To drsTemp.Length - 1
                drsTemp(i).BeginEdit() : drsTemp(i).Item("line_no") = Integer.Parse(drsTemp(i).Item("line_no")) + 1 : drsTemp(i).EndEdit()
            Next
            dt.AcceptChanges()
            Dim workRow As DataRow = dt.NewRow()
            workRow.ItemArray = PartNoRow.ItemArray
            workRow.BeginEdit() : workRow.Item("PART_NO") = "AGS-EW-03" : workRow.Item("line_no") = Integer.Parse(workRow.Item("line_no")) + 1
            workRow.Item("LIST_PRICE") = 0.01 : workRow.Item("UNIT_PRICE") = 0.01 : workRow.Item("NoATPFlag") = "0" : workRow.Item("EXWARRANTY_FLAG") = "0"
            workRow.Item("CustMaterialNo") = ""
            workRow.EndEdit() : dt.Rows.Add(workRow) : dt.AcceptChanges()
        End If
        Return dt
    End Function

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim item As OrderItem = CType(e.Row.DataItem, OrderItem)
            If item.EXWARRANTY_FLAG = 99 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "36"
            End If
            If item.EXWARRANTY_FLAG = 999 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "3"
            End If
            Dim dueDate As String = Now.Date
            dueDate = IIf(CDate(item.DUE_DATE).ToString("yyyy/MM/dd") = "1900/01/01", "TBD", CDate(item.DUE_DATE).ToString("yyyy/MM/dd"))
            If Not item.PART_NO.ToString.StartsWith("AGS-") And myOrderDetail.isBtoParentItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) = 0 And item.NoATPFlag = 0 And dueDate <> "TBD" Then
                e.Row.Cells(5).Text = "<font color='#FF0000'>For Reference Only</font>" & "<br/>" & dueDate
            End If

            If item.ItemTypeX = OrderItemType.BtosParent And myOrderDetail.isBtoNotSatisfy(Request("NO")) = 1 Then
                e.Row.Cells(5).Text = "<font color='#FF0000'>For Reference Only</font>" & "<br/>" & dueDate
            End If
            If item.ItemTypeX = OrderItemType.BtosParent Then
                e.Row.BackColor = Drawing.Color.LightYellow
                If Util.IsTestingQuote2Order() AndAlso item.LINE_NO IsNot Nothing Then
                    Dim SubTotal As Decimal = myOrderDetail.getTotalAmountV2(Request("NO"), item.LINE_NO.ToString)
                    ' e.Row.Cells(9).Text = Session("company_currency_sign") & FormatNumber(myOrderDetail.getTotalPriceV2(Request("NO"), DBITEM.Item("Line_No").ToString), 2)
                    e.Row.Cells(11).Text = CurrencySign & FormatNumber(SubTotal, 2)
                    If item.QTY IsNot Nothing AndAlso Integer.TryParse(item.QTY, 0) AndAlso Integer.Parse(item.QTY) > 0 Then
                        e.Row.Cells(10).Text = CurrencySign & FormatNumber(SubTotal / Integer.Parse(item.QTY.ToString), 2)
                    End If
                End If
            End If
            Dim PickUrl As String = "/INCLUDES/PickShippingCalendar.aspx?IsBTOS=0"
            If item.ItemTypeX = OrderItemType.BtosParent Then
                PickUrl = "/INCLUDES/PickShippingCalendar.aspx?IsBTOS=1"
            End If
            Dim txtPickCalender As TextBox = CType(e.Row.FindControl("txtreqdate"), TextBox)
            If item.IsEWpartnoX OrElse item.ItemTypeX = OrderItemType.BtosPart Then '.isBtoChildItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) = 1 Then
                txtPickCalender.Visible = False
            Else
                txtPickCalender.Attributes("onclick") = "PickDate('" + Util.GetRuntimeSiteUrl() + PickUrl + "',this)"
            End If
            If Util.IsTesting() AndAlso item.ItemTypeX = OrderItemType.BtosPart Then
                txtPickCalender.Visible = True
                txtPickCalender.BorderWidth = 0 : txtPickCalender.Enabled = False
            End If

            If AuthUtil.IsAEU AndAlso (item.ItemTypeX = OrderItemType.BtosParent OrElse item.ItemTypeX = OrderItemType.BtosPart) Then
                CType(e.Row.FindControl("txtreqdate"), TextBox).Enabled = False
            End If
        End If
        If Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            If e.Row.RowType = DataControlRowType.Header Then
                CType(e.Row.FindControl("lbHDueDate"), Label).Text = "Available Date"
                CType(e.Row.FindControl("lbHReqDate"), Label).Text = "Req deliv date"
            End If
            If e.Row.RowType <> DataControlRowType.EmptyDataRow Then
                e.Row.Cells(7).Visible = False
            End If

            'Ryan 20170710 Hide cell 5 (due date column for US01 per Jay's request.)
            e.Row.Cells(5).Visible = False
        End If

        'Ryan 20170329 AJP特例，AJP不需使用CPN，欄位實際上儲存的是cust_po_no
        If e.Row.RowType = DataControlRowType.Header Then
            If Session("org_id").ToString.Trim.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                e.Row.Cells(2).Text = "Customer PO No."
            End If
        End If
    End Sub

    Protected Sub txtCustPN_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim orgiMaterial As String = CType(Me.gv1.Rows(row.RowIndex).FindControl("hPN"), HiddenField).Value.Trim
        Dim CustPN As String = obj.Text.Trim
        'Dim o As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
        'o.UpdateCustPn(CustPN, Request("NO"), orgiMaterial)

        'Ryan 20170419 Update CPN by sql command, ORDER_DETAILTableAdapter can't update nvarchar...
        If Session("org_id").ToString.Trim.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
            Dim LineNo As String = CType(Me.gv1.Rows(row.RowIndex).FindControl("hLineNo"), HiddenField).Value.Trim
            Dim cmd As New SqlClient.SqlCommand(" UPDATE MyAdvantechGlobal.dbo.ORDER_DETAIL SET CustMaterialNo = @CPN WHERE ORDER_ID = @ORDERID AND PART_NO = @PARTNO AND LINE_NO = @LINENO",
                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            cmd.Parameters.AddWithValue("CPN", CustPN)
            cmd.Parameters.AddWithValue("ORDERID", Request("NO"))
            cmd.Parameters.AddWithValue("PARTNO", orgiMaterial)
            cmd.Parameters.AddWithValue("LINENO", LineNo)
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
            cmd.Connection.Close()
        Else
            Dim cmd As New SqlClient.SqlCommand(" UPDATE MyAdvantechGlobal.dbo.ORDER_DETAIL SET CustMaterialNo = @CPN WHERE ORDER_ID = @ORDERID AND PART_NO = @PARTNO",
                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            cmd.Parameters.AddWithValue("CPN", CustPN)
            cmd.Parameters.AddWithValue("ORDERID", Request("NO"))
            cmd.Parameters.AddWithValue("PARTNO", orgiMaterial)
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
            cmd.Connection.Close()
        End If


        Dim CM As New CustMaterialDataContext
        Dim custMaterial As Cust_MaterialMapping = CM.Cust_MaterialMappings.SingleOrDefault(Function(X As Cust_MaterialMapping) X.MaterialNo = orgiMaterial AndAlso X.CustomerId = Session("Company_ID").ToString)
        If Not IsNothing(custMaterial) Then
            custMaterial.CustMaterialNo = CustPN
        End If
        CM.SubmitChanges()
        'myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("CustMaterialNo='{0}'", CustPN))
    End Sub
    Public Function getDescForPN(ByVal PN As String, ByVal Description As Object) As String
        'Ming 20150413 檢查String是否為Null Or Empty前，從datarow中取出時就要先檢查 Is DbNull.Value
        If Not IsDBNull(Description) AndAlso Description IsNot Nothing AndAlso Not String.IsNullOrEmpty(Description) Then
            Return Description
        End If
        Dim DTSAPPRODUCT As DataTable = myProduct.GetDT(String.Format("part_no='{0}'", PN), "")
        If DTSAPPRODUCT.Rows.Count > 0 Then
            Return DTSAPPRODUCT.Rows(0).Item("Product_desc")
        End If
        Return ""
    End Function

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)

        'Order Total
        Dim ordertotal As Decimal = myOrderDetail.getTotalAmount(Request("NO"))

        'Freight
        Dim freight As Decimal = 0
        freight = getFreight()
        If freight > 0 Then
            Me.tdFreight.Visible = True : Me.lbFt.Text = freight ': Me.lbFreight.Text = freight
        End If

        'Tax
        Dim taxrate As Decimal = 0, taxtotal As Decimal = 0
        Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = Request("NO")).FirstOrDefault()
        If MasterExtension IsNot Nothing AndAlso Decimal.TryParse(MasterExtension.OrderTaxRate, taxrate) AndAlso MasterExtension.OrderTaxRate <> 0 Then
            taxrate = MasterExtension.OrderTaxRate
            taxtotal = Decimal.Round(ordertotal * taxrate, 2, MidpointRounding.AwayFromZero)
            Me.tdTax.Visible = True : Me.lbTax.Text = taxtotal
        End If

        Me.lbTotal.Text = FormatNumber(ordertotal + freight + taxtotal, 2)
    End Sub
    Protected Function getFreight() As Decimal
        Dim v As Decimal = 0
        Dim myFT As New Freight("MY", "FREIGHT"), DT As New DataTable
        DT = myFT.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
        If DT.Rows.Count > 0 Then
            For Each X As DataRow In DT.Rows
                If X.Item("FTYPE") = "ZHDA" Then
                    v = v - 0
                Else
                    v = v + X.Item("FVALUE")
                End If
            Next
        End If
        Return v
    End Function
    'Protected Sub txtreqdate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
    '    Dim obj As TextBox = CType(sender, TextBox)
    '    Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
    '    Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
    '    Dim req_date As Date = CDate(obj.Text)
    '    myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("required_date='{0}'", req_date))
    '    ReCalDue(Request("NO"), id)
    '    initInterface()
    'End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:Literal runat="server" ID="litorderinfo"></asp:Literal>
    <div id="divDetailInfo" class="mytable1">
        <div class="bk5">
        </div>
        <table width="100%">
            <tr>
                <td style="background-color: #ededed; font-weight: bold">Purchased Products
                     <asp:Button ID="btn_enter" runat="server" OnClientClick="return false;"
                         Height="0px" Width="0px" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:HiddenField ID="HF_IsBTOS" runat="server" Value="0" />
                    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                        AllowSorting="true" Width="100%" EmptyDataText="No Order Line." DataKeyNames="line_no"
                        OnDataBound="gv1_DataBound" OnRowDataBound="gv1_RowDataBound">
                        <Columns>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" Visible="false" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Seq.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Line No.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:HiddenField ID="hLineNo" runat="server" Value='<%# Eval("Line_no")%>' />
                                    <%# Eval("Line_no")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Customer PN.">
                                <ItemTemplate>
                                    <asp:TextBox runat="server" ID="txtCustPN" Text='<%#Server.HtmlDecode(Eval("CustMaterialNo").toString()) %>'
                                        Width="80px" OnTextChanged="txtCustPN_TextChanged"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left"
                                ItemStyle-CssClass="Tnowrap">
                                <HeaderTemplate>
                                    Product
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:HiddenField ID="hPN" runat="server" Value='<%# Eval("Part_no")%>' />
                                    <%# Eval("Part_no")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    Description
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# getDescForPN(Eval("PART_NO"), Eval("Description"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    <asp:Label runat="server" ID="lbHDueDate">Due Date</asp:Label>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# iif(CDate(Eval("due_date")).toString("yyyy/MM/dd")="1900/01/01","TBD",CDate(Eval("due_date")).toString("yyyy/MM/dd")) %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    <asp:Label runat="server" ID="lbHReqDate"> Required Date </asp:Label>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:TextBox ID="txtreqdate" name="txtreqdate" runat="server" Text='<%#CDate(Eval("required_date")).toString("yyyy/MM/dd") %>'
                                        Onclick="PickDate('/INCLUDES/PickShippingCalendar.aspx',this)" Width="65px" Style="text-align: right"
                                        onkeydown="javascript:return false;"></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" Visible="false">
                                <HeaderTemplate>
                                    Sales Leads from Advantech (DMF)
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("DMF_Flag")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" HeaderStyle-Width="80" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Extended Warranty Months
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lbew" Text='<%#Bind("EXWARRANTY_FLAG") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Qty.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Qty")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center"
                                ItemStyle-CssClass="Tnowrap">
                                <HeaderTemplate>
                                    Price
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" Text='<%# CurrencySign%>' ID="lbUnitPriceSign"></asp:Label>
                                    <%# FormatNumber(Eval("Unit_price"), 2)%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center"
                                ItemStyle-CssClass="Tnowrap">
                                <HeaderTemplate>
                                    Sub Total
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" Text='<%# CurrencySign%>' ID="lbSubTotalSign"></asp:Label>
                                    <%# FormatNumber(Eval("Unit_price") * Eval("Qty"), 2)%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </td>
            </tr>
            <tr>
                <td align="right" runat="server" id="tdFreight" visible="false">
                    <span style="padding-left:75%">Freight：<%#CurrencySign%></span>
                    <asp:Label runat="server" ID="lbFt"></asp:Label>
                </td>
            </tr>
            <tr>
                <td align="right" runat="server" id="tdTax" visible="false">
                    <span style="padding-left:75%">Tax：<%#CurrencySign%></span>
                    <asp:Label runat="server" ID="lbTax"></asp:Label>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <span style="padding-left:75%">Total：<%#CurrencySign%></span>
                    <asp:Label runat="server" id="lbTotal"></asp:Label>
                </td>
            </tr>
        </table>
        <table width="100%">
            <tr>
                <td align="center">
                    <asp:Button runat="server" Text=" >> Update << " ID="btnUpdate" OnClick="btnUpdate_Click" />
                </td>
            </tr>
        </table>
        <br />
        <%=getDueDetail() %>
        <table width="100%">
            <tr>
                <td align="center">
                    <asp:Button runat="server" Text="Next" ID="btnConfirm" OnClick="btnConfirm_Click"
                        Width="120px" />
                </td>
            </tr>
            <tr>
                <td align="center">
                    <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                </td>
            </tr>
        </table>
    </div>
    <script type="text/javascript">
        function PickDate(Url, Element) {
            Url = Url + "&Element=" + Element.name + "&SelectedDate=" + Element.value + ""; //&IsBTOS=<%=Me.HF_IsBTOS.value%>
            window.open(Url, "pop", "height=265,width=263,top=300,left=400,scrollbars=no")
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
