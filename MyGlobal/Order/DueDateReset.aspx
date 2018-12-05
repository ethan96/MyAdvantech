<%@ Page Title="MyAdvantech - Due Date Calculation" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    ValidateRequest="false" %>

<%@ Import Namespace="System.Globalization" %>
<script runat="server">
    Dim myOrderMaster As New order_Master("b2b", "order_master")
    Dim myOrderDetail As New order_Detail("b2b", "order_detail")
    Dim myCompany As New SAP_Company("b2b", "sap_dimcompany")
    Dim myProduct As New SAPProduct("b2b", "sap_product")
    Dim mycart As New CartList("b2b", "cart_detail")
    Dim CartId As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Util.IsTestingQuote2Order() Then
                Response.Redirect(String.Format("DueDateResetV2.aspx{0}", Request.Url.Query))
            End If
        End If
        If Not IsNothing(Request("NO")) AndAlso Request("NO") <> "" And Not IsPostBack Then
            initInterface()
            '20111128 TC: Check if there is any item's status=O, and if yes, if the order qty<=ATP qty, if not, disable Confirm button and show warning message
            CheckStatusOItemATP()
            If OrderUtilities.IsDirect2SAP() Then
                Me.btnConfirm_Click(Me.btnConfirm, Nothing)
            End If
        End If
        CartId = Session("cart_id")
    End Sub
    
    Sub CheckStatusOItemATP()
        lbMsg.Text = ""
        Dim orderId As String = Trim(Request("NO")), OrgId As String = Session("org_id")
        Dim strSql As String = _
            " select a.part_no, sum(a.QTY) as ORDER_QTY,  " + _
            " IsNull((select sum(z.ATP_QTY) from SAP_PRODUCT_ATP z where z.PART_NO=a.PART_NO and z.SALES_ORG='" + Session("org_id") + "'),0) as ATP_QTY " + _
            " from ORDER_DETAIL a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO  " + _
            " where a.ORDER_ID='" + orderId + "' and b.ORG_ID='" + OrgId + "' and b.STATUS in ('O') " + _
            " group by a.PART_NO  "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
        If dt.Rows.Count > 0 Then
            Dim sbWarnMsg As New System.Text.StringBuilder
            For Each r As DataRow In dt.Rows
                Dim strTmpPN As String = r.Item("part_no")
                Dim intTmpOrderQty As Integer = CInt(r.Item("ORDER_QTY")), intTmpATPQty As Integer = CInt(r.Item("ATP_QTY"))
                If intTmpOrderQty > 0 And intTmpOrderQty > intTmpATPQty Then
                    If btnConfirm.Enabled Then btnConfirm.Enabled = False
                    sbWarnMsg.AppendLine(String.Format("{0} is phased out inventory qty {1} is less than order qty {2}<br/>", _
                                                       strTmpPN, intTmpATPQty.ToString(), intTmpOrderQty.ToString()))
                End If
            Next
            If btnConfirm.Enabled = False Then lbMsg.Text = sbWarnMsg.ToString()
        End If
    End Sub
    
    Sub initInterface()
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
        Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Request("NO")), "line_no")
        If dtMaster.Rows.Count > 0 And dtDetail.Rows.Count > 0 Then
            litorderinfo.Text = Util.GetAscxStr(Request("NO"), 0) + Util.GetAscxStr(Request("NO"), 1)
        End If
        If dtDetail.Rows.Count = 0 Then
            Glob.ShowInfo("There are no products in your shopping cart.")
            btnConfirm.Enabled = False : btnUpdate.Visible = False
            Exit Sub
        Else
            btnConfirm.Enabled = True : btnUpdate.Visible = True
        End If
        
        'Frank 2013/06/04
        If myOrderDetail.isBtoOrder(Request("NO")) Then
            Me.HF_IsBTOS.Value = "1"
            
            Dim _MaxComponentDueDate As Date = myOrderDetail.getMaxDueDateWithout100Line(Request("NO"))
            Dim MDUEDATE As String = MyCartOrderBizDAL.getBTOParentDueDate(_MaxComponentDueDate.ToString("yyyy/MM/dd"))
            myOrderDetail.Update(String.Format("order_id='{0}' and line_no=100", Request("NO")), String.Format("DUE_DATE='{0}'", MDUEDATE))
            
        Else
            Me.HF_IsBTOS.Value = "0"
            'Frank 2013/06/04: Detecting require date
          
            Dim _IsNeedReloadQD As Boolean = False
            'Nada20131215 to avoid deadlock
            Using sconn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                For Each _row As DataRow In dtDetail.Rows
                    '20131105 JJ: If company id has weekly ship date setup in SAP, then get nearest ship week date
                    Dim tmpNextWeekShipDate As Date = Today
                    'If require date is today, then update it to next working date
                    Dim _NextWorkingDate As Date = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, Today), Session("org_id"))
                    If Format(_row.Item("REQUIRED_DATE"), "yyyyMMdd") = _NextWorkingDate.ToString("yyyyMMdd") Then
                        If Not Session("org_id") Is Nothing AndAlso Session("org_id") = "EU10" Then
                            If MyCartOrderBizDAL.GetNextWeeklyShippingDate(_NextWorkingDate, tmpNextWeekShipDate) Then _NextWorkingDate = tmpNextWeekShipDate.ToString("yyyy/MM/dd")
                        End If
                        myOrderDetail.UpdateShareConn(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), _row.Item("LINE_NO")), String.Format("required_date='{0}'", _NextWorkingDate), sconn)
                        ReCalDue(Request("NO"), _row.Item("LINE_NO"))
                        _IsNeedReloadQD = True
                    End If
                Next
            End Using
            If _IsNeedReloadQD Then
                dtDetail = myOrderDetail.GetDT(String.Format("order_id='{0}'", Request("NO")), "line_no")
            End If
        End If
        
        Me.gv1.DataSource = dtDetail : Me.gv1.DataBind()
    End Sub
       
    
    Public Function getDescForPN(ByVal PN As String, ByVal Description As String) As String
        If Not String.IsNullOrEmpty(Description.ToString.Trim) Then
            Return Description
        End If
        Dim DTSAPPRODUCT As DataTable = myProduct.GetDT(String.Format("part_no='{0}'", PN), "")
        If DTSAPPRODUCT.Rows.Count > 0 Then
            Return DTSAPPRODUCT.Rows(0).Item("Product_desc")
        End If
        Return ""
    End Function

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim total As Decimal = myOrderDetail.getTotalAmount(Request("NO"))
        Dim freight As Decimal = 0
        freight = getFreight()
        If freight > 0 Then
            Me.trFreight.Visible = True : Me.lbFt.Text = freight ': Me.lbFreight.Text = freight
        End If
        Me.lbTotal.Text = FormatNumber(total + freight, 2)
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
    Protected Sub txtreqdate_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        Dim req_date As Date = CDate(obj.Text)
        myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("required_date='{0}'", req_date))
        ReCalDue(Request("NO"), id)
        initInterface()
    End Sub
    
    Sub ReCalDue(ByVal order_id As String, ByVal line_no As String, Optional ByVal sconn As SqlClient.SqlConnection = Nothing)
        Dim dt As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}' and line_no='{1}'", order_id, line_no), "")
        If dt.Rows.Count = 1 Then
            Dim part_no As String = dt.Rows(0).Item("part_no"), plant As String = dt.Rows(0).Item("deliveryplant")
            Dim qty As String = dt.Rows(0).Item("qty"), req_date As String = dt.Rows(0).Item("required_date"), duedate As String = ""
            Dim inventory As Integer = 0, satisflag As Integer = 0, qtyCanbeConfirmed As Integer = 0
            If part_no.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) Then
                Dim dtpartno As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}' and line_no='{1}'", order_id, Integer.Parse(line_no) - 1), "")
                If dtpartno.Rows.Count > 0 Then
                    duedate = dtpartno.Rows(0).Item("due_date")
                End If
            Else
                SAPtools.getInventoryAndATPTable(part_no, plant, qty, duedate, 0, Nothing, req_date)
            End If
            If Not IsNothing(sconn) Then
                myOrderDetail.UpdateShareConn(String.Format("order_id='{0}' and line_no='{1}'", order_id, line_no), String.Format("due_date='{0}'", duedate), sconn)
            Else
                myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", order_id, line_no), String.Format("due_date='{0}'", duedate))
            End If
        End If
    End Sub

    ' ''' <summary>
    ' ''' Create by Frank
    ' ''' </summary>
    ' ''' <param name="order_id"></param>
    ' ''' <param name="line_no"></param>
    ' ''' <param name="DueDate"></param>
    ' ''' <remarks></remarks>
    'Sub ReCalBtosDue_ForFutureDate(ByVal order_id As String, ByVal line_no As String, ByVal DueDate As Date)
        
    '    myOrderDetail.Update(String.Format("order_id='{0}'", order_id), String.Format("due_date='{0}'", DueDate))
        
    '    'Dim dt As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}' and line_no='{1}'", order_id, line_no), "")
    '    'If dt.Rows.Count = 1 Then
    '    '    Dim part_no As String = dt.Rows(0).Item("part_no"), plant As String = dt.Rows(0).Item("deliveryplant")
    '    '    Dim qty As String = dt.Rows(0).Item("qty"), req_date As String = dt.Rows(0).Item("required_date"), duedate As String = ""
    '    '    Dim inventory As Integer = 0, satisflag As Integer = 0, qtyCanbeConfirmed As Integer = 0
    '    '    SAPtools.getInventoryAndATPTable(part_no, plant, qty, duedate, 0, Nothing, req_date)
    '    '    myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", order_id, line_no), String.Format("due_date='{0}'", duedate))
    '    'End If
        
    'End Sub

    
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
        'For Each gvr As GridViewRow In gv1.Rows
        '    Dim reqTB As TextBox = CType(gvr.FindControl("txtreqdate"), TextBox)
        '    If Date.TryParse(reqTB.Text, Now) = False Then Exit Sub
        '    Dim req_date As Date = CDate(reqTB.Text)
        '    Dim LineNO As String = gv1.DataKeys(gvr.DataItemIndex).Value.ToString.Trim
            
        '    myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), LineNO), String.Format("required_date='{0}'", req_date))
        '    ReCalDue(Request("NO"), LineNO)
        'Next
        Me.DoUpdateButton()
        
        Me.UpdateBTOSRequireAndDueDate()
        
        Me.initInterface()
    End Sub

    Protected Sub UpdateBTOSRequireAndDueDate()
        'Frank 2013/06/04
        '=============Process future require date for EU btos order=========================
        '\ Ming 2010-10-8 因UZISCHE01 要直接接受user輸入的Required Date，所以不用再重新计算Required Date
        If String.Equals(Session("COMPANY_ID"), "UZISCHE01", StringComparison.CurrentCultureIgnoreCase) Then
            Exit Sub
        End If
        '/ end
        Dim _org As String = Left(Session("org_id").ToString.ToUpper, 2)
        Dim _MaxDueDate As Date = Nothing, _MaxComponentDueDate As Date = Nothing
        Dim _Before5WorkingDate As Date = Nothing, _Before7WorkingDate As Date = Nothing
        'If Me.HF_IsBTOS.Value = "1" _
        '    AndAlso _org.Equals("EU", StringComparison.InvariantCultureIgnoreCase) _
        '    AndAlso gv1.Rows.Count > 0 Then

        If Me.HF_IsBTOS.Value = "1" AndAlso gv1.Rows.Count > 0 Then

            Dim reqTB As TextBox = CType(gv1.Rows(0).FindControl("txtreqdate"), TextBox)
            Dim req_date As Date = CDate(reqTB.Text)
            Dim LineNO As String = gv1.DataKeys(gv1.Rows(0).DataItemIndex).Value.ToString.Trim
            _MaxComponentDueDate = myOrderDetail.getMaxDueDateWithout100Line(Request("NO"))

            '_MaxDueDate should be 100 line due date
            Dim MDUEDATE As String = MyCartOrderBizDAL.getBTOParentDueDate(_MaxComponentDueDate.ToString("yyyy/MM/dd"))
            If Not Date.TryParseExact(MDUEDATE, "yyyy/MM/dd", CultureInfo.CurrentCulture, DateTimeStyles.None, _MaxDueDate) Then
                _MaxDueDate = myOrderDetail.getMaxDueDate(Request("NO"))
            End If
            
            'Frank : Get BTOS working date
            Dim _BTOSWorkingDate As Integer = 7
            If Not Integer.TryParse(Glob.getBTOWorkingDate(), _BTOSWorkingDate) Then _BTOSWorkingDate = 7

            'Update Required Date
            Dim _ComponentMaxRequiredDate As Date = myOrderDetail.getMaxReqDateWithout100Line(Request("NO"))
            Dim _BTOS100LineRequireDate As Date = MyCartOrderBizDAL.getCompNextWorkDate(_ComponentMaxRequiredDate, Session("org_id"), _BTOSWorkingDate)
            If req_date < _BTOS100LineRequireDate Then
                myOrderDetail.Update(String.Format("order_id='{0}' and line_no=100", Request("NO")), String.Format("REQUIRED_DATE='{0}'", _BTOS100LineRequireDate))
            Else
                _Before7WorkingDate = MyCartOrderBizDAL.getCompNextWorkDate(req_date, Session("org_id"), -(_BTOSWorkingDate))
                myOrderDetail.Update(String.Format("order_id='{0}' and line_no<>100", Request("NO")), String.Format("REQUIRED_DATE='{0}'", _Before7WorkingDate))
            End If
            
            'Update Due Date
            If req_date > _MaxDueDate Then
                _Before7WorkingDate = MyCartOrderBizDAL.getCompNextWorkDate(req_date, Session("org_id"), -(_BTOSWorkingDate))

                myOrderDetail.Update(String.Format("order_id='{0}' and line_no<>100", Request("NO")), String.Format("REQUIRED_DATE='{0}'", _Before7WorkingDate))

                myOrderDetail.Update(String.Format("order_id='{0}' and line_no=100", Request("NO")), String.Format("due_date='{0}'", req_date))
                myOrderDetail.Update(String.Format("order_id='{0}' and line_no<>100", Request("NO")), String.Format("due_date='{0}'", _Before7WorkingDate))
            Else
                myOrderDetail.Update(String.Format("order_id='{0}' and line_no=100", Request("NO")), String.Format("due_date='{0}'", MDUEDATE))
            End If


        End If
        'End=============Process future require date for EU btos order=========================        
    End Sub
    
    ''' <summary>
    ''' Process future require date for EU btos order
    ''' </summary>
    ''' <remarks>Frank 2013/06/04</remarks>
    Protected Sub DoUpdateButton()
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

            'Frank 2013/06/13
            'myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), LineNO), String.Format("required_date='{0}'", req_date))
            If Me.HF_IsBTOS.Value = "1" Then
                If LineNO = "100" Then
                    myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), LineNO), String.Format("required_date='{0}'", req_date))
                Else
                    myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), LineNO), String.Format("required_date='{0}'", DateAdd(DateInterval.Day, 1, Today)))
                End If
            Else
                myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), LineNO), String.Format("required_date='{0}'", req_date))
            End If
            
            ReCalDue(Request("NO"), LineNO)
        Next
        

    End Sub
    
    Protected Sub btnConfirm_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'TC:按下Next button時也先呼叫Update button的動作將req date與customer PN update後再往下走
        '=============Process future require date for EU btos order=========================
        Me.DoUpdateButton()
        Me.UpdateBTOSRequireAndDueDate()
        'End=============Process future require date for EU btos order=========================

        If Left(Session("org_id").ToString.ToUpper, 2) = "EU" Then
            Me.updateDueDateByCustCal()
        End If
        
        'Me.UpdateBTOSRequireAndDueDate()
        
        If Session("COMPANY_ID") IsNot Nothing Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("SELECT top 1 COMPANY_ID FROM ADMIN_PREFERENTIAL_PRODS where COMPANY_ID ='{0}'", Session("COMPANY_ID")))
            If dt.Rows.Count > 0 Then
                AddEW()
            End If
        End If
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
            Dim DBITEM As DataRowView = CType(e.Row.DataItem, DataRowView)
            If DBITEM.Item("EXWARRANTY_FLAG") = 99 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "36"
            End If
            If DBITEM.Item("EXWARRANTY_FLAG") = 999 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "3"
            End If
            Dim dueDate As String = Now.Date
            dueDate = IIf(CDate(DBITEM.Item("due_date")).ToString("yyyy/MM/dd") = "1900/01/01", "TBD", CDate(DBITEM.Item("due_date")).ToString("yyyy/MM/dd"))
            If Not DBITEM.Item("part_no").ToString.StartsWith("AGS-") And myOrderDetail.isBtoParentItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) = 0 And DBITEM.Item("NOATPFLAG") = 0 And dueDate <> "TBD" Then
                e.Row.Cells(5).Text = "<font color='#FF0000'>For Reference Only</font>" & "<br/>" & dueDate
            End If
            
            If myOrderDetail.isBtoParentItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) = 1 And myOrderDetail.isBtoNotSatisfy(Request("NO")) = 1 Then
                e.Row.Cells(5).Text = "<font color='#FF0000'>For Reference Only</font>" & "<br/>" & dueDate
            End If
            If myOrderDetail.isBtoParentItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) Then
                If Util.IsTestingQuote2Order() AndAlso DBITEM.Item("Line_No") IsNot Nothing Then
                    Dim SubTotal As Decimal = myOrderDetail.getTotalAmountV2(Request("NO"), DBITEM.Item("Line_No").ToString)
                    ' e.Row.Cells(9).Text = Session("company_currency_sign") & FormatNumber(myOrderDetail.getTotalPriceV2(Request("NO"), DBITEM.Item("Line_No").ToString), 2)
                    e.Row.Cells(11).Text = Session("company_currency_sign") & FormatNumber(SubTotal, 2)
                    If DBITEM.Item("qty") IsNot Nothing AndAlso Integer.TryParse(DBITEM.Item("qty"), 0) AndAlso Integer.Parse(DBITEM.Item("qty")) > 0 Then
                        e.Row.Cells(10).Text = Session("company_currency_sign") & FormatNumber(SubTotal / Integer.Parse(DBITEM.Item("qty").ToString), 2)
                    End If
                End If
            End If
            
            If myOrderDetail.isBtoChildItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) = 1 Then
                CType(e.Row.FindControl("txtreqdate"), TextBox).Visible = False
            End If
            Dim txtPickCalender As TextBox = e.Row.FindControl("txtreqdate")
            txtPickCalender.Attributes("onclick") = "PickDate('" + Util.GetRuntimeSiteUrl() + "/INCLUDES/PickShippingCalendar.aspx',this)"
            
        End If
        If Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            If e.Row.RowType = DataControlRowType.Header Then
                CType(e.Row.FindControl("lbHDueDate"), Label).Text = "Available Date"
                CType(e.Row.FindControl("lbHReqDate"), Label).Text = "Req deliv date"
            End If
            If e.Row.RowType <> DataControlRowType.EmptyDataRow Then
                e.Row.Cells(7).Visible = False
            End If
        End If
    End Sub
    
    Protected Sub txtCustPN_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim obj As TextBox = CType(sender, TextBox)
        Dim row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        Dim id As Integer = Me.gv1.DataKeys(row.RowIndex).Value
        
        Dim CustPN As String = obj.Text.Trim
        Dim o As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
        o.UpdateCustPn(CustPN, Request("NO"), id)
        'myOrderDetail.Update(String.Format("order_id='{0}' and line_no='{1}'", Request("NO"), id), String.Format("CustMaterialNo='{0}'", CustPN))
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:Literal runat="server" ID="litorderinfo"></asp:Literal>
    <div id="divDetailInfo" class="mytable">
        <asp:Panel DefaultButton="btnConfirm" runat="server" ID="plDueDateReset">
            <table width="100%">
                <tr>
                    <td style="background-color: #ededed; font-weight: bold">
                        Purchased Products
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:HiddenField ID="HF_IsBTOS" runat="server" Value="0" />
                        <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                            AllowSorting="true" Width="100%" EmptyDataText="No Order Line." DataKeyNames="line_no"
                            OnDataBound="gv1_DataBound" OnRowDataBound="gv1_RowDataBound">
                            <Columns>
                                <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
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
                                        <%# Eval("Line_no")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Customer PN.">
                                    <ItemTemplate>
                                        <asp:TextBox runat="server" ID="txtCustPN" Text='<%#Server.HtmlDecode(Eval("CustMaterialNo").toString()) %>'
                                            Width="80px" OnTextChanged="txtCustPN_TextChanged"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                    <HeaderTemplate>
                                        Product
                                    </HeaderTemplate>
                                    <ItemTemplate>
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
                                <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                    <HeaderTemplate>
                                        Sales Leads from Advantech (DMF)
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%# Eval("DMF_Flag")%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
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
                                <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                    <HeaderTemplate>
                                        Price
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Label runat="server" Text='<%# Session("company_currency_sign")%>' ID="lbUnitPriceSign"></asp:Label>
                                        <%# FormatNumber(Eval("Unit_price"), 2)%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                    <HeaderTemplate>
                                        Sub Total
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Label runat="server" Text='<%# Session("company_currency_sign")%>' ID="lbSubTotalSign"></asp:Label>
                                        <%# FormatNumber(Eval("Unit_price") * Eval("Qty"), 2)%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </td>
                </tr>
                <tr>
                    <td align="right" runat="server" id="trFreight" visible="false">
                        Freight：<%= HttpContext.Current.Session("company_currency_sign")%><asp:Label runat="server"
                            ID="lbFt"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        Total：<%= HttpContext.Current.Session("company_currency_sign")%><asp:Label runat="server"
                            ID="lbTotal"></asp:Label>
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
        </asp:Panel>
    </div>
    <script type="text/javascript">
        function PickDate(Url, Element) {
            Url = Url + "?Element=" + Element.name + "&SelectedDate=" + Element.value + "&IsBTOS=<%=Me.HF_IsBTOS.value%>";
            window.open(Url, "pop", "height=265,width=263,top=300,left=400,scrollbars=no")
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
