<%@ Page Title="MyAdvantech - Project Registration" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="InterConPrjReg" %>
<%@ Register Src="Schedules.ascx" TagName="Schedules" TagPrefix="uc1" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Session("user_id") Is Nothing OrElse Session("user_id").ToString() = "" Then
                Response.Redirect("~/home.aspx?ReturnUrl=" + Request.ServerVariables("URL"))
                Response.End()
            End If

            'ICC 2016/5/19 Add a drop down list for sales to pick primary sales
            If Session("company_id") Is Nothing OrElse String.IsNullOrEmpty(Session("company_id")) Then Response.Redirect(Request.ApplicationPath)
            ddlPrimarySales.Items.Clear()
            Dim dt As DataTable = InterConPrjRegUtil.GetPrimarySalesEmail(Session("company_id").ToString())
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                For Each dr As DataRow In dt.Rows
                    Dim email = dr.Item("EMAIL_ADDR").ToString().Trim().ToLower()
                    Dim lt As New ListItem(email, email)
                    If Not String.IsNullOrEmpty(email) AndAlso Not ddlPrimarySales.Items.Contains(lt) AndAlso Util.IsInternalUser(email) = True Then
                        ddlPrimarySales.Items.Add(lt)
                    End If
                Next
            End If

            If Util.IsInternalUser(Session("user_id").ToString()) = False Then
                'ICC 2016/5/30 By Candy's request. We'll check primary sales in two scenarios.
                Dim dtSc1 As DataTable = InterConPrjRegUtil.GetPrimarySalesEmailScenario1(Session("user_id").ToString())
                Dim dtSc2 As DataTable = InterConPrjRegUtil.GetPrimarySalesEmailScenario2(Session("user_id").ToString())

                If Not dtSc1 Is Nothing AndAlso dtSc1.Rows.Count > 0 Then
                    For Each dr As DataRow In dtSc1.Rows
                        Dim email As String = dr.Item("EMAIL_ADDR").ToString().Trim().ToLower()
                        Dim li As New ListItem(email, email)
                        If Not String.IsNullOrEmpty(email) AndAlso Not ddlPrimarySales.Items.Contains(li) AndAlso Util.IsInternalUser(email) = True Then
                            ddlPrimarySales.Items.Add(li)
                        End If
                    Next
                End If

                If Not dtSc2 Is Nothing AndAlso dtSc2.Rows.Count > 0 Then
                    For Each dr As DataRow In dtSc2.Rows
                        Dim email As String = dr.Item("EMAIL_ADDR").ToString().Trim().ToLower()
                        Dim li As New ListItem(email, email)
                        If Not String.IsNullOrEmpty(email) AndAlso Not ddlPrimarySales.Items.Contains(li) AndAlso Util.IsInternalUser(email) = True Then
                            ddlPrimarySales.Items.Add(li)
                        End If
                    Next
                End If
            End If

            'ICC 2017/6/27 For edit mode
            If Not String.IsNullOrEmpty(Request("ROW_ID")) Then
                Dim rowid As String = Request("ROW_ID").ToString.Trim
                hfRowID.Value = rowid
                If EditData(rowid) = False Then Util.AjaxJSAlertRedirect(Me.upProd, "No data for this record", "../../home.aspx")
            End If
            'JJ 2014/4/3 如果是InterCon.ALL這個Group的人員在home_ez上是隱藏的，所以如果直接用URL連結就導回首頁
            'ICC 2016/3/4 Remove this code for Stefanie to test
            'If MailUtil.IsInMailGroup("InterCon.ALL", Session("user_id")) Then
            '    Response.Redirect("~/home.aspx")
            '    Response.End()
            'End If
        End If
    End Sub
    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'lbMsg.Text = ""
        'If txtEndCustomerName.Text.Trim() = "" Then
        '    lbMsg.Text = "Please provide end customer's company name"
        '    btnSubmit.Enabled = True
        '    Exit Sub
        'End If

        'If txtEndContactEmail1.Text.Trim() <> "" AndAlso Util.IsValidEmailFormat(txtEndContactEmail1.Text.Trim()) = False Then
        '    lbMsg.Text = "End customer contact's email format is incorrect" : Exit Sub
        'End If
        ''If txtEndContactTel1.Text.Trim() = "" Then
        ''    lbMsg.Text = "Please provide end customer contact's telephone" : Exit Sub
        ''End If
        'If txtPrjName.Text.Trim() = "" Then
        '    lbMsg.Text = "Please provide project name" : Exit Sub
        'End If
        'If txtPrjName.Text.Length > 100 Then
        '    lbMsg.Text = "Project Name cannot exceed 100 characters" : Exit Sub
        'End If
        'If txtPrjDesc.Text.Length > 255 Then
        '    lbMsg.Text = "Project Description cannot exceed 255 characters" : Exit Sub
        'End If
        ''ICC 2016/5/19 Check drop down list value is not null
        'If String.IsNullOrEmpty(ddlPrimarySales.SelectedValue) Then
        '    lbMsg.Text = "Please select primary sales email" : Exit Sub
        'End If
        ''If Util.IsTesting() Then
        ''    lbMsg.Text = " everything is ok" : Exit Sub
        ''End If
        'Dim SB As New StringBuilder
        'SB.AppendLine(" select a.NAME as OPTY_NAME, c.ATTRIB_05 as ERP_ID ")
        'SB.AppendLine(" from S_OPTY a inner join S_ORG_EXT b on a.PR_DEPT_OU_ID=b.ROW_ID inner join S_ORG_EXT_X c on b.ROW_ID=c.ROW_ID ")
        'SB.AppendFormat(" where RTRIM(LTRIM(Lower(c.ATTRIB_05)))='{0}' and RTRIM(LTRIM(Lower(a.NAME)))=N'{1}'", Session("company_id").ToString.ToLower.Trim, txtPrjName.Text.Trim.Replace("'", "''").ToLower)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", SB.ToString)
        'If dt.Rows.Count > 0 Then lbMsg.Text = " Project Name already exists." : Exit Sub
        'If txtPrjCloseDate.Text.Trim = "" Then
        '    lbMsg.Text = "Please provide project close date" : Exit Sub
        'End If
        'If Date.TryParseExact(txtPrjCloseDate.Text, "yyyy/MM/dd", New System.Globalization.CultureInfo("en-US"), Nothing, Now) = False Then
        '    lbMsg.Text = "Please provide project close date in yyyy/mm/dd format" : Exit Sub
        'End If
        'If Date.Parse(txtPrjCloseDate.Text) <= Date.Parse(Now()) Then
        '    lbMsg.Text = "Project close date must be greater than today" : Exit Sub
        'End If
        ''If txtCopCompanyName1.Text.Trim() = "" OrElse txtCopModel1.Text.Trim() = "" OrElse txtCopPrice1.Text.Trim() = "" Then
        ''    lbMsg.Text = "Please provide complete competitor's information" : Exit Sub
        ''End If
        'If txtModel1.Text.Trim() = "" AndAlso txtPRemark1.Text.Trim() = "" Then
        '    lbMsg.Text = "Please input Remark for the model 1" : Exit Sub
        'End If
        'If txtProdQty1.Text = "" Then
        '    lbMsg.Text = "Please provide model quantity" : Exit Sub
        'End If
        'Dim Qty As Integer = 0, AMOUNT As Double = 0, REMARK As String = ""
        'Dim SELLINGPRICE As Decimal = 0, REQUESTPRICE As Decimal = -1, STANDARDPRICE As Decimal = 0
        'Dim prodDt As New MY_PRJ_REG_PRODUCTSDataTable
        'Dim schDT As New MY_PRJ_REG_PRODUCT_SCHEDULESDataTable
        'For i As Integer = 1 To 20
        '    Dim IsAvailable As Boolean = False
        '    Dim tp As TextBox = Me.Master.FindControl("_main").FindControl("txtModel" + i.ToString())
        '    Dim rmark As TextBox = Me.Master.FindControl("_main").FindControl("txtPRemark" + i.ToString())
        '    'Dim trpro As HtmlTableRow = Me.Master.FindControl("_main").FindControl("trProd" + i.ToString())
        '    If T(tp.Text) <> "" Then
        '        Dim sp() As String = AutoSuggestPN(tp.Text.Trim(), 10)
        '        If sp Is Nothing OrElse sp.Length = 0 Then
        '            lbMsg.Text = "Model number " + i.ToString() + " is invalid" : Exit Sub
        '        Else
        '            IsAvailable = True
        '        End If
        '    End If
        '    If T(rmark.Text) <> "" Then
        '        IsAvailable = True
        '    End If
        '    'If trpro.Visible = True AndAlso T(tp.Text) = "" AndAlso T(rmark.Text) = "" Then
        '    '    lbMsg.Text = "Please input remark for the model " + i.ToString() : Exit Sub
        '    'End If
        '    If IsAvailable Then
        '        Dim qp As TextBox = Me.Master.FindControl("_main").FindControl("txtProdQty" + i.ToString())
        '        If Double.TryParse(qp.Text, 0) = False Then
        '            lbMsg.Text = "Qty of model number " + i.ToString() + " is empty or not a numeric number" : Exit Sub
        '        End If
        '        Qty = CInt(qp.Text)
        '        qp = Me.Master.FindControl("_main").FindControl("txtPRemark" + i.ToString())
        '        REMARK = T(qp.Text)
        '        qp = Me.Master.FindControl("_main").FindControl("txt2EndPrice" + i.ToString())
        '        If Double.TryParse(qp.Text, 0) = False Then
        '            'lbMsg.Text = "End Customer Price of model number " + i.ToString() + " is empty or not a numeric number" : Exit Sub
        '            SELLINGPRICE = 0
        '        Else
        '            SELLINGPRICE = CDec(qp.Text)
        '        End If
        '        qp = Me.Master.FindControl("_main").FindControl("txtSPR" + i.ToString())
        '        If qp.Text.Trim <> "" Then
        '            If Double.TryParse(qp.Text, 0) = False Then
        '                lbMsg.Text = "Special Price of model number " + i.ToString() + " is empty or not a numeric number" : Exit Sub
        '            End If
        '            REQUESTPRICE = CDec(qp.Text)
        '        End If
        '        Dim qpLable As Label = Me.Master.FindControl("_main").FindControl("txtCPP" + i.ToString())
        '        If Double.TryParse(qpLable.Text, 0) = False Then
        '            'lbMsg.Text = "Channel Price of model number " + i.ToString() + " is empty or not a numeric number" : Exit Sub
        '            STANDARDPRICE = GetPrice(tp.Text.Trim())
        '        Else
        '            'STANDARDPRICE = CDec(qpLable.Text)
        '            Decimal.TryParse(qpLable.Text, STANDARDPRICE)
        '        End If
        '        qpLable.Text = STANDARDPRICE.ToString()

        '        'ICC Check REQUEST PRICE, it should not be nagative number
        '        If REQUESTPRICE <= 0 Then REQUESTPRICE = 0

        '        Dim prodDtRow As MY_PRJ_REG_PRODUCTSRow = prodDt.NewMY_PRJ_REG_PRODUCTSRow()
        '        With prodDtRow
        '            .ROW_ID = Guid.NewGuid().ToString()
        '            .PRJ_ROW_ID = "" : .LINE_NO = i : .PART_NO = T(tp.Text) : .PRODUCT_NAME = "" : .QTY = Qty
        '            .REMARK = REMARK : .SELLINGPRICE = SELLINGPRICE : .REQUESTPRICE = REQUESTPRICE
        '            .STANDARDPRICE = STANDARDPRICE : .CREATED_BY = User.Identity.Name : .CREATED_DATE = Now()
        '            .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now() : .AMOUNT = 0
        '        End With
        '        prodDt.AddMY_PRJ_REG_PRODUCTSRow(prodDtRow)
        '        ''SCHEDULES
        '        Dim Stotalqty As Integer = 0
        '        Dim wc As UserControl = CType(Me.Master.FindControl("_main").FindControl("Schedules" + i.ToString()), UserControl)
        '        For j As Integer = 1 To 5
        '            Dim tc As TextBox = CType(wc.FindControl("txtCal" + j.ToString()), TextBox)
        '            Dim tq As TextBox = CType(wc.FindControl("txtQty" + j.ToString()), TextBox)
        '            If tc IsNot Nothing AndAlso tq IsNot Nothing AndAlso tc.Text.Trim() <> "" AndAlso tq.Text.Trim() <> "" Then
        '                Dim schDTRow As MY_PRJ_REG_PRODUCT_SCHEDULESRow = schDT.NewMY_PRJ_REG_PRODUCT_SCHEDULESRow()
        '                With schDTRow
        '                    .ROW_ID = Guid.NewGuid().ToString() : .PRJ_PROD_ROW_ID = prodDtRow.ROW_ID : .SCHEDULE_LINE_NO = j
        '                    .SHIP_DATE = CDate(tc.Text) : .QTY = CInt(tq.Text) : .CREATED_BY = User.Identity.Name
        '                    .CREATED_DATE = Now() : .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now()
        '                    Stotalqty += .QTY
        '                End With
        '                schDT.AddMY_PRJ_REG_PRODUCT_SCHEDULESRow(schDTRow)
        '                schDT.AcceptChanges()
        '            End If
        '        Next
        '        schDT.AcceptChanges()
        '        If Stotalqty <> 0 AndAlso prodDtRow.QTY <> Stotalqty Then
        '            lbMsg.Text = String.Format("The total qty is different with the summarized schedule qty for model {0} ", prodDtRow.PART_NO)
        '            Exit Sub
        '        End If
        '        ''end 
        '    End If
        'Next
        'prodDt.AcceptChanges()
        ' ''
        ' ''Master
        'Dim PrjMasterDt As New MY_PRJ_REG_MASTERDataTable
        'Dim prjMasterRow As MY_PRJ_REG_MASTERRow = PrjMasterDt.NewMY_PRJ_REG_MASTERRow()
        'With prjMasterRow
        '    .ROW_ID = Guid.NewGuid().ToString() : .CP_COMPANY_ID = Session("company_id") : .CP_ACCOUNT_ROW_ID = USPrjRegUtil.GetAccountRowID(Session("company_id"))
        '    .ENDCUST_NAME = T(txtEndCustomerName.Text) : .ENDCUST_POST_CODE = T(txtEndCustPostCode.Text) : .ENDCUST_STATE = T(txtEndCustState.Text)
        '    .ENDCUST_ADDR = T(txtEndCustAddr.Text) : .ENDCUST_COUNTRY = dlEndCustCountry.SelectedValue : .ENDCUST_ADDR = T(txtEndCustAddr.Text)
        '    .ENDCUST_ACCOUNT_ROW_ID = InterConPrjRegUtil.GetAccountRowIDbyName(txtEndCustomerName.Text)
        '    .PRJ_OPTY_ID = "" : .PRJ_NAME = T(txtPrjName.Text) : .PRJ_DESC = T(txtPrjDesc.Text) : .PRJ_EST_CLOSE_DATE = CDate(txtPrjCloseDate.Text)
        '    .PRJ_TOTAL_AMT = 0
        '    If Decimal.TryParse(txtPrjAmt.Text, 0) Then
        '        .PRJ_TOTAL_AMT = CDec(txtPrjAmt.Text)
        '    End If
        '    .PRJ_AMT_CURR = Session("COMPANY_CURRENCY")
        '    .POTENTIAL_RISK = T(txtSPRLB.Text) : .NEEDED_ADV_SUPPORT = T(TBnas.Text)
        '    .CREATED_BY = Session("user_id") : .CREATED_DATE = Now()
        '    .LAST_UPD_BY = Session("user_id") : .LAST_UPD_DATE = Now()
        'End With
        'PrjMasterDt.AddMY_PRJ_REG_MASTERRow(prjMasterRow)
        'PrjMasterDt.AcceptChanges()
        ' ''
        ' ''contacts
        'Dim prjContactDt As New MY_PRJ_REG_CONTACTSDataTable
        'For i As Integer = 1 To 5
        '    Dim tp As TextBox = Me.Master.FindControl("_main").FindControl("txtEndContactLName" + i.ToString())
        '    If tp.Text.Trim() <> "" Then
        '        Dim prjContactRow1 As MY_PRJ_REG_CONTACTSRow = prjContactDt.NewMY_PRJ_REG_CONTACTSRow()
        '        With prjContactRow1
        '            .ROW_ID = Guid.NewGuid().ToString() : .PRJ_ROW_ID = ""
        '            .CONTACT_ROW_ID = "" : .LAST_NAME = T(tp.Text) : .FIRST_NAME = TB("txtEndContactFName" + i.ToString())
        '            .EMAIL = TB("txtEndContactEmail" + i.ToString()) : .TEL = TB("txtEndContactTel" + i.ToString())
        '            .CREATED_BY = User.Identity.Name : .CREATED_DATE = Now() : .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now()
        '        End With
        '        prjContactDt.AddMY_PRJ_REG_CONTACTSRow(prjContactRow1)
        '    End If
        'Next
        'prjContactDt.AcceptChanges()
        ' ''
        ' ''Competitor 
        'Dim compDt As New MY_PRJ_REG_COMPETITORSDataTable
        'For i As Integer = 1 To 5
        '    Dim tp As TextBox = Me.Master.FindControl("_main").FindControl("txtCopCompanyName" + i.ToString())
        '    If tp.Text.Trim() <> "" Then
        '        Dim compDtRow As MY_PRJ_REG_COMPETITORSRow = compDt.NewMY_PRJ_REG_COMPETITORSRow()
        '        With compDtRow
        '            .ROW_ID = Guid.NewGuid().ToString()
        '            .PRJ_ROW_ID = "" : .COMPETITOR_NAME = TB("txtCopCompanyName" + i.ToString()) : .MODEL_NO = TB("txtCopModel" + i.ToString())
        '            Dim strTmpPrice As String = CType(Me.Master.FindControl("_main").FindControl("txtCopPrice" + i.ToString()), TextBox).Text
        '            Dim decTmpPrice As Decimal = 0
        '            If Decimal.TryParse(strTmpPrice, 0) Then decTmpPrice = Decimal.Parse(strTmpPrice)
        '            .SELLING_PRICE = decTmpPrice : .SELLING_CURR = Session("COMPANY_CURRENCY")
        '            .REMARK = TB("txtRemark" + i.ToString()) : .CREATED_BY = User.Identity.Name : .CREATED_DATE = Now()
        '            .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now()
        '        End With
        '        compDt.AddMY_PRJ_REG_COMPETITORSRow(compDtRow)
        '    End If
        'Next
        'compDt.AcceptChanges()
        'ICC 2016/5/19 Pass primary sales vlue
        'Dim prjID As String = InterConPrjRegUtil.AddProject(PrjMasterDt, prjContactDt, prodDt, compDt, schDT, ddlPrimarySales.SelectedValue)
        'ModalPopupExtender1.Hide()
        'ICC 2016/5/19 Tell sales if their project failed.
        'ICC 2017/6/27 Change original logic to a function. For Stefanie to add save fuction in this page.
        If Me.CheckAndSave(1) = False Then Exit Sub
        Dim message As String = "Your data is being processed, thank you"
        'If String.IsNullOrEmpty(prjID) Then message = "Error! Create project failed. Please contact ChannelManagement.ACL@advantech.com"
        Util.AjaxJSAlertRedirect(Me.upProd, message, "../../home.aspx")

    End Sub
    Public Function T(ByVal s As String) As String
        Return s.Replace("'", "''").Trim()
    End Function
    Public Function TB(ByVal s As String) As String
        Try
            Return CType(Me.Master.FindControl("_main").FindControl(s), TextBox).Text().Replace("'", "''").Trim()
        Catch ex As Exception
        End Try
        Return ""
    End Function
    Protected Sub btnMoreContact_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim trEndContacts() As HtmlControl = {Me.tr_EndContact3, Me.tr_EndContact4, Me.tr_EndContact5}
        For i As Integer = 0 To trEndContacts.Length - 1
            Dim tr As HtmlControl = trEndContacts(i)
            If tr.Visible = False Then
                tr.Visible = True
                If i = trEndContacts.Length - 1 Then
                    Me.btnMoreContact.Enabled = False
                End If
                Exit For
            End If
        Next
    End Sub
    Protected Sub btnMoreCop_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim trCop() As HtmlControl = {Me.tr_Cop3, Me.tr_Cop4, Me.tr_Cop5}
        For i As Integer = 0 To trCop.Length - 1
            Dim tr As HtmlControl = trCop(i)
            If tr.Visible = False Then
                tr.Visible = True
                If i = trCop.Length - 1 Then
                    Me.btnMoreCop.Enabled = False
                End If
                Exit For
            End If
        Next
    End Sub
    Protected Sub btnMoreProd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        For i As Integer = 3 To 20
            Dim tr As HtmlControl = Me.Master.FindControl("_main").FindControl("trProd" + i.ToString())
            If tr.Visible = False Then
                tr.Visible = True
                If i = 20 Then btnMoreProd.Enabled = False
                Exit For
            End If
        Next
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetAddrByCustRowId(ByVal rowid As String) As DataTable
        Return InterConPrjRegUtil.GetAddrByCustRowId(rowid)
    End Function
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestCustName(ByVal prefixText As String, ByVal count As Integer) As String()
        Return InterConPrjRegUtil.AutoSuggestCustName(prefixText, count)
    End Function
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPrice(ByVal pn As String) As Double
        Dim ws As New MYSAPDAL, strCompanyId As String = HttpContext.Current.Session("company_id"), strOrg As String = HttpContext.Current.Session("org_id")
        Dim pinTable As New SAPDALDS.ProductInDataTable, pOutTable As New SAPDALDS.ProductOutDataTable
        pinTable.AddProductInRow(pn, 1)
        If ws.GetPriceV2(strCompanyId, strCompanyId, strOrg, MYSAPDAL.SAPOrderType.ZOR, pinTable, pOutTable, "") AndAlso pOutTable.Count > 0 Then
            Return CDbl(pOutTable(0).UNIT_PRICE)
        Else
            'Return -1
            '2016/3/21 Change price to 0 to prevent Siebel web service is not allow -1.
            Return 0
        End If
        'Return InterConPrjRegUtil.GetPrice(pn)
    End Function
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestPN(ByVal prefixText As String, ByVal count As Integer) As String()
        Return InterConPrjRegUtil.AutoSuggestPN(prefixText, count)
    End Function

    Public Function EditData(ByVal rowid As String) As Boolean
        Dim masterDT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select * from [dbo].[MY_PRJ_REG_MASTER] where ROW_ID ='{0}'", rowid))
        If masterDT Is Nothing OrElse masterDT.Rows.Count = 0 Then Return False
        Dim primarysales As Object = dbUtil.dbExecuteScalar("MYLOCAL", String.Format("select PRIMARY_SALES_EMAIL from [dbo].[MY_PRJ_REG_PRIMARY_SALES_EMAIL] where PRJ_ROW_ID='{0}'", rowid))
        If primarysales Is Nothing OrElse String.IsNullOrEmpty(primarysales.ToString) Then Return False
        
        'Master data
        txtEndCustomerName.Text = masterDT.Rows(0).Item("ENDCUST_NAME").ToString()
        txtEndCustPostCode.Text = masterDT.Rows(0).Item("ENDCUST_POST_CODE").ToString()
        txtEndCustState.Text = masterDT.Rows(0).Item("ENDCUST_STATE").ToString()
        txtEndCustAddr.Text = masterDT.Rows(0).Item("ENDCUST_ADDR").ToString()
        dlEndCustCountry.ClearSelection()
        dlEndCustCountry.Items.FindByValue(masterDT.Rows(0).Item("ENDCUST_COUNTRY").ToString()).Selected = True
        txtPrjName.Text = masterDT.Rows(0).Item("PRJ_NAME").ToString()
        txtPrjDesc.Text = masterDT.Rows(0).Item("PRJ_DESC").ToString()
        txtPrjCloseDate.Text = Date.Parse(masterDT.Rows(0).Item("PRJ_EST_CLOSE_DATE").ToString()).ToString("yyyy/MM/dd")
        txtPrjAmt.Text = masterDT.Rows(0).Item("PRJ_TOTAL_AMT").ToString()
        txtSPRLB.Text = masterDT.Rows(0).Item("POTENTIAL_RISK").ToString()
        TBnas.Text = masterDT.Rows(0).Item("NEEDED_ADV_SUPPORT").ToString()
        
        ddlPrimarySales.ClearSelection()
        Try
            ddlPrimarySales.Items.FindByValue(primarysales.ToString()).Selected = True
        Catch ex As Exception

        End Try
        
        Dim contactDT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select * from MY_PRJ_REG_CONTACTS where PRJ_ROW_ID='{0}'", rowid))
        If Not contactDT Is Nothing AndAlso contactDT.Rows.Count > 0 Then
            For i = 0 To contactDT.Rows.Count - 1
                Select Case i
                    Case 0
                        txtEndContactLName1.Text = contactDT.Rows(i).Item("LAST_NAME").ToString
                        txtEndContactFName1.Text = contactDT.Rows(i).Item("FIRST_NAME").ToString
                        txtEndContactEmail1.Text = contactDT.Rows(i).Item("EMAIL").ToString
                        txtEndContactTel1.Text = contactDT.Rows(i).Item("TEL").ToString
                    Case 1
                        txtEndContactLName2.Text = contactDT.Rows(i).Item("LAST_NAME").ToString
                        txtEndContactFName2.Text = contactDT.Rows(i).Item("FIRST_NAME").ToString
                        txtEndContactEmail2.Text = contactDT.Rows(i).Item("EMAIL").ToString
                        txtEndContactTel2.Text = contactDT.Rows(i).Item("TEL").ToString
                    Case 2
                        tr_EndContact3.Visible = True
                        txtEndContactLName3.Text = contactDT.Rows(i).Item("LAST_NAME").ToString
                        txtEndContactFName3.Text = contactDT.Rows(i).Item("FIRST_NAME").ToString
                        txtEndContactEmail3.Text = contactDT.Rows(i).Item("EMAIL").ToString
                        txtEndContactTel3.Text = contactDT.Rows(i).Item("TEL").ToString
                    Case 3
                        tr_EndContact4.Visible = True
                        txtEndContactLName4.Text = contactDT.Rows(i).Item("LAST_NAME").ToString
                        txtEndContactFName4.Text = contactDT.Rows(i).Item("FIRST_NAME").ToString
                        txtEndContactEmail4.Text = contactDT.Rows(i).Item("EMAIL").ToString
                        txtEndContactTel4.Text = contactDT.Rows(i).Item("TEL").ToString
                    Case 4
                        tr_EndContact5.Visible = True
                        txtEndContactLName5.Text = contactDT.Rows(i).Item("LAST_NAME").ToString
                        txtEndContactFName5.Text = contactDT.Rows(i).Item("FIRST_NAME").ToString
                        txtEndContactEmail5.Text = contactDT.Rows(i).Item("EMAIL").ToString
                        txtEndContactTel5.Text = contactDT.Rows(i).Item("TEL").ToString
                        btnMoreContact.Enabled = False
                End Select
            Next
        End If
        
        Dim competiDT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select * from MY_PRJ_REG_COMPETITORS where PRJ_ROW_ID='{0}'", rowid))
        If Not competiDT Is Nothing AndAlso competiDT.Rows.Count > 0 Then
            For i = 0 To competiDT.Rows.Count - 1
                Select Case i
                    Case 0
                        txtCopCompanyName1.Text = competiDT.Rows(i).Item("COMPETITOR_NAME").ToString
                        txtCopModel1.Text = competiDT.Rows(i).Item("MODEL_NO").ToString
                        txtCopPrice1.Text = competiDT.Rows(i).Item("SELLING_PRICE").ToString
                        txtRemark1.Text = competiDT.Rows(i).Item("REMARK").ToString
                    Case 1
                        txtCopCompanyName2.Text = competiDT.Rows(i).Item("COMPETITOR_NAME").ToString
                        txtCopModel2.Text = competiDT.Rows(i).Item("MODEL_NO").ToString
                        txtCopPrice2.Text = competiDT.Rows(i).Item("SELLING_PRICE").ToString
                        txtRemark2.Text = competiDT.Rows(i).Item("REMARK").ToString
                    Case 2
                        tr_Cop3.Visible = True
                        txtCopCompanyName3.Text = competiDT.Rows(i).Item("COMPETITOR_NAME").ToString
                        txtCopModel3.Text = competiDT.Rows(i).Item("MODEL_NO").ToString
                        txtCopPrice3.Text = competiDT.Rows(i).Item("SELLING_PRICE").ToString
                        txtRemark3.Text = competiDT.Rows(i).Item("REMARK").ToString
                    Case 3
                        tr_Cop4.Visible = True
                        txtCopCompanyName4.Text = competiDT.Rows(i).Item("COMPETITOR_NAME").ToString
                        txtCopModel4.Text = competiDT.Rows(i).Item("MODEL_NO").ToString
                        txtCopPrice4.Text = competiDT.Rows(i).Item("SELLING_PRICE").ToString
                        txtRemark4.Text = competiDT.Rows(i).Item("REMARK").ToString
                    Case 4
                        tr_Cop5.Visible = True
                        txtCopCompanyName5.Text = competiDT.Rows(i).Item("COMPETITOR_NAME").ToString
                        txtCopModel5.Text = competiDT.Rows(i).Item("MODEL_NO").ToString
                        txtCopPrice5.Text = competiDT.Rows(i).Item("SELLING_PRICE").ToString
                        txtRemark5.Text = competiDT.Rows(i).Item("REMARK").ToString
                        btnMoreCop.Enabled = False
                End Select
            Next
        End If
        
        Dim productDT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select * from MY_PRJ_REG_PRODUCTS where PRJ_ROW_ID='{0}'", rowid))
        If Not productDT Is Nothing AndAlso productDT.Rows.Count > 0 Then
            For i = 0 To productDT.Rows.Count - 1
                Select Case i
                    Case 0
                        txtModel1.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty1.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark1.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice1.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR1.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP1.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 1
                        txtModel2.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty2.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark2.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice2.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR2.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP2.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 2
                        txtModel3.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty3.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark3.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice3.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR3.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP3.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd3.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 3
                        txtModel4.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty4.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark4.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice4.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR4.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP4.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd4.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 4
                        txtModel5.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty5.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark5.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice5.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR5.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP5.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd5.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 5
                        txtModel6.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty6.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark6.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice6.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR6.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP6.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd6.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 6
                        txtModel7.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty7.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark7.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice7.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR7.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP7.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd7.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 7
                        txtModel8.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty8.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark8.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice8.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR8.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP8.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd8.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 8
                        txtModel9.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty9.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark9.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice9.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR9.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP9.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd9.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 9
                        txtModel10.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty10.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark10.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice10.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR10.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP10.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd10.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 10
                        txtModel11.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty11.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark11.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice11.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR11.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP11.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd11.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 11
                        txtModel12.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty12.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark12.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice12.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR12.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP12.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd12.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 12
                        txtModel13.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty13.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark13.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice13.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR13.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP13.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd13.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 13
                        txtModel14.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty14.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark14.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice14.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR14.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP14.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd14.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 14
                        txtModel15.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty15.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark15.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice15.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR15.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP15.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd15.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 15
                        txtModel16.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty16.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark16.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice16.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR16.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP16.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd16.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 16
                        txtModel17.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty17.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark17.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice17.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR17.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP17.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd17.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 17
                        txtModel18.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty18.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark18.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice18.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR18.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP18.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd18.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 18
                        txtModel19.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty19.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark19.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice19.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR19.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP19.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd19.Visible = True
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                    Case 19
                        btnMoreProd.Enabled = False
                        txtModel20.Text = productDT.Rows(i).Item("PART_NO").ToString
                        txtProdQty20.Text = productDT.Rows(i).Item("QTY").ToString
                        txtPRemark20.Text = productDT.Rows(i).Item("REMARK").ToString
                        txt2EndPrice20.Text = productDT.Rows(i).Item("SELLINGPRICE").ToString
                        txtSPR20.Text = productDT.Rows(i).Item("REQUESTPRICE").ToString
                        txtCPP20.Text = productDT.Rows(i).Item("STANDARDPRICE").ToString
                        trProd20.Visible = True
                        btnMoreProd.Enabled = False
                        Me.SetScheduleData(productDT.Rows(i).Item("ROW_ID").ToString, i)
                End Select
            Next
        End If
        Return True
    End Function
    
    Protected Sub SetScheduleData(ByVal pdID As String, ByVal i As Integer)
        Dim scheduleDT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select * from MY_PRJ_REG_PRODUCT_SCHEDULES where PRJ_PROD_ROW_ID='{0}' order by SCHEDULE_LINE_NO", pdID))
        If Not scheduleDT Is Nothing AndAlso scheduleDT.Rows.Count > 0 Then
            Dim no As Integer = i + 1
            Dim wc As UserControl = CType(Me.Master.FindControl("_main").FindControl("Schedules" + no.ToString()), UserControl)
            For k = 0 To scheduleDT.Rows.Count - 1
                Dim sc As Integer = k + 1
                Select Case k
                    Case 0
                        Dim tc As TextBox = CType(wc.FindControl("txtCal" + sc.ToString()), TextBox)
                        Dim tq As TextBox = CType(wc.FindControl("txtQty" + sc.ToString()), TextBox)
                        tc.Text = Date.Parse(scheduleDT.Rows(k).Item("SHIP_DATE").ToString).ToString("yyyy/MM/dd")
                        tq.Text = scheduleDT.Rows(k).Item("QTY").ToString
                    Case 1
                        Dim tc As TextBox = CType(wc.FindControl("txtCal" + sc.ToString()), TextBox)
                        Dim tq As TextBox = CType(wc.FindControl("txtQty" + sc.ToString()), TextBox)
                        tc.Text = Date.Parse(scheduleDT.Rows(k).Item("SHIP_DATE").ToString).ToString("yyyy/MM/dd")
                        tq.Text = scheduleDT.Rows(k).Item("QTY").ToString
                    Case 2
                        Dim tc As TextBox = CType(wc.FindControl("txtCal" + sc.ToString()), TextBox)
                        Dim tq As TextBox = CType(wc.FindControl("txtQty" + sc.ToString()), TextBox)
                        tc.Text = Date.Parse(scheduleDT.Rows(k).Item("SHIP_DATE").ToString).ToString("yyyy/MM/dd")
                        tq.Text = scheduleDT.Rows(k).Item("QTY").ToString
                    Case 3
                        Dim tc As TextBox = CType(wc.FindControl("txtCal" + sc.ToString()), TextBox)
                        Dim tq As TextBox = CType(wc.FindControl("txtQty" + sc.ToString()), TextBox)
                        tc.Text = Date.Parse(scheduleDT.Rows(k).Item("SHIP_DATE").ToString).ToString("yyyy/MM/dd")
                        tq.Text = scheduleDT.Rows(k).Item("QTY").ToString
                    Case 4
                        Dim tc As TextBox = CType(wc.FindControl("txtCal" + sc.ToString()), TextBox)
                        Dim tq As TextBox = CType(wc.FindControl("txtQty" + sc.ToString()), TextBox)
                        tc.Text = Date.Parse(scheduleDT.Rows(k).Item("SHIP_DATE").ToString).ToString("yyyy/MM/dd")
                        tq.Text = scheduleDT.Rows(k).Item("QTY").ToString
                End Select
            Next
        End If
    End Sub
    Protected Sub btnSave_Click(sender As Object, e As EventArgs)
        If Me.CheckAndSave(2) = False Then Exit Sub
        Dim message As String = "Your data has been saved, thank you"
        Util.AjaxJSAlertRedirect(Me.upProd, message, "../../home.aspx")
    End Sub
    Private Function CheckAndSave(ByVal stage As Integer) As Boolean
        lbMsg.Text = ""
        If txtEndCustomerName.Text.Trim() = "" Then
            lbMsg.Text = "Please provide end customer's company name"
            btnSubmit.Enabled = True
            Return False
        End If

        If txtEndContactEmail1.Text.Trim() <> "" AndAlso Util.IsValidEmailFormat(txtEndContactEmail1.Text.Trim()) = False Then
            lbMsg.Text = "End customer contact's email format is incorrect" : Return False
        End If
        'If txtEndContactTel1.Text.Trim() = "" Then
        '    lbMsg.Text = "Please provide end customer contact's telephone" : Exit Sub
        'End If
        If txtPrjName.Text.Trim() = "" Then
            lbMsg.Text = "Please provide project name" : Return False
        End If
        If txtPrjName.Text.Length > 100 Then
            lbMsg.Text = "Project Name cannot exceed 100 characters" : Return False
        End If
        If txtPrjDesc.Text.Length > 255 Then
            lbMsg.Text = "Project Description cannot exceed 255 characters" : Return False
        End If
        'ICC 2016/5/19 Check drop down list value is not null
        If String.IsNullOrEmpty(ddlPrimarySales.SelectedValue) Then
            lbMsg.Text = "Please select primary sales email" : Return False
        End If
        'If Util.IsTesting() Then
        '    lbMsg.Text = " everything is ok" : Exit Sub
        'End If
        Dim SB As New StringBuilder
        SB.AppendLine(" select a.NAME as OPTY_NAME, c.ATTRIB_05 as ERP_ID ")
        SB.AppendLine(" from S_OPTY a inner join S_ORG_EXT b on a.PR_DEPT_OU_ID=b.ROW_ID inner join S_ORG_EXT_X c on b.ROW_ID=c.ROW_ID ")
        SB.AppendFormat(" where RTRIM(LTRIM(Lower(c.ATTRIB_05)))='{0}' and RTRIM(LTRIM(Lower(a.NAME)))=N'{1}'", Session("company_id").ToString.ToLower.Trim, txtPrjName.Text.Trim.Replace("'", "''").ToLower)
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", SB.ToString)
        If dt.Rows.Count > 0 Then lbMsg.Text = " Project Name already exists." : Return False
        If txtPrjCloseDate.Text.Trim = "" Then
            lbMsg.Text = "Please provide project close date" : Return False
        End If
        If Date.TryParseExact(txtPrjCloseDate.Text, "yyyy/MM/dd", New System.Globalization.CultureInfo("en-US"), Nothing, Now) = False Then
            lbMsg.Text = "Please provide project close date in yyyy/mm/dd format" : Return False
        End If
        If Date.Parse(txtPrjCloseDate.Text) <= Date.Parse(Now()) Then
            lbMsg.Text = "Project close date must be greater than today" : Return False
        End If
        'If txtCopCompanyName1.Text.Trim() = "" OrElse txtCopModel1.Text.Trim() = "" OrElse txtCopPrice1.Text.Trim() = "" Then
        '    lbMsg.Text = "Please provide complete competitor's information" : Exit Sub
        'End If
        If txtModel1.Text.Trim() = "" AndAlso txtPRemark1.Text.Trim() = "" Then
            lbMsg.Text = "Please input Remark for the model 1" : Return False
        End If
        If txtProdQty1.Text = "" Then
            lbMsg.Text = "Please provide model quantity" : Return False
        End If
        Dim Qty As Integer = 0, AMOUNT As Double = 0, REMARK As String = ""
        Dim SELLINGPRICE As Decimal = 0, REQUESTPRICE As Decimal = -1, STANDARDPRICE As Decimal = 0
        Dim prodDt As New MY_PRJ_REG_PRODUCTSDataTable
        Dim schDT As New MY_PRJ_REG_PRODUCT_SCHEDULESDataTable
        For i As Integer = 1 To 20
            Dim IsAvailable As Boolean = False
            Dim tp As TextBox = Me.Master.FindControl("_main").FindControl("txtModel" + i.ToString())
            Dim rmark As TextBox = Me.Master.FindControl("_main").FindControl("txtPRemark" + i.ToString())
            'Dim trpro As HtmlTableRow = Me.Master.FindControl("_main").FindControl("trProd" + i.ToString())
            If T(tp.Text) <> "" Then
                Dim sp() As String = AutoSuggestPN(tp.Text.Trim(), 10)
                If sp Is Nothing OrElse sp.Length = 0 Then
                    lbMsg.Text = "Model number " + i.ToString() + " is invalid" : Return False
                Else
                    IsAvailable = True
                End If
            End If
            If T(rmark.Text) <> "" Then
                IsAvailable = True
            End If
            'If trpro.Visible = True AndAlso T(tp.Text) = "" AndAlso T(rmark.Text) = "" Then
            '    lbMsg.Text = "Please input remark for the model " + i.ToString() : Exit Sub
            'End If
            If IsAvailable Then
                Dim qp As TextBox = Me.Master.FindControl("_main").FindControl("txtProdQty" + i.ToString())
                If Double.TryParse(qp.Text, 0) = False Then
                    lbMsg.Text = "Qty of model number " + i.ToString() + " is empty or not a numeric number" : Return False
                End If
                Qty = CInt(qp.Text)
                qp = Me.Master.FindControl("_main").FindControl("txtPRemark" + i.ToString())
                REMARK = T(qp.Text)
                qp = Me.Master.FindControl("_main").FindControl("txt2EndPrice" + i.ToString())
                If Double.TryParse(qp.Text, 0) = False Then
                    'lbMsg.Text = "End Customer Price of model number " + i.ToString() + " is empty or not a numeric number" : Exit Sub
                    SELLINGPRICE = 0
                Else
                    SELLINGPRICE = CDec(qp.Text)
                End If
                qp = Me.Master.FindControl("_main").FindControl("txtSPR" + i.ToString())
                If qp.Text.Trim <> "" Then
                    If Double.TryParse(qp.Text, 0) = False Then
                        lbMsg.Text = "Special Price of model number " + i.ToString() + " is empty or not a numeric number" : Return False
                    End If
                    REQUESTPRICE = CDec(qp.Text)
                End If
                Dim qpLable As Label = Me.Master.FindControl("_main").FindControl("txtCPP" + i.ToString())
                If Double.TryParse(qpLable.Text, 0) = False Then
                    'lbMsg.Text = "Channel Price of model number " + i.ToString() + " is empty or not a numeric number" : Exit Sub
                    STANDARDPRICE = GetPrice(tp.Text.Trim())
                Else
                    'STANDARDPRICE = CDec(qpLable.Text)
                    Decimal.TryParse(qpLable.Text, STANDARDPRICE)
                End If
                qpLable.Text = STANDARDPRICE.ToString()

                'ICC Check REQUEST PRICE, it should not be nagative number
                If REQUESTPRICE <= 0 Then REQUESTPRICE = 0

                Dim prodDtRow As MY_PRJ_REG_PRODUCTSRow = prodDt.NewMY_PRJ_REG_PRODUCTSRow()
                With prodDtRow
                    .ROW_ID = Guid.NewGuid().ToString()
                    .PRJ_ROW_ID = "" : .LINE_NO = i : .PART_NO = T(tp.Text) : .PRODUCT_NAME = "" : .QTY = Qty
                    .REMARK = REMARK : .SELLINGPRICE = SELLINGPRICE : .REQUESTPRICE = REQUESTPRICE
                    .STANDARDPRICE = STANDARDPRICE : .CREATED_BY = User.Identity.Name : .CREATED_DATE = Now()
                    .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now() : .AMOUNT = 0
                End With
                prodDt.AddMY_PRJ_REG_PRODUCTSRow(prodDtRow)
                ''SCHEDULES
                Dim Stotalqty As Integer = 0
                Dim wc As UserControl = CType(Me.Master.FindControl("_main").FindControl("Schedules" + i.ToString()), UserControl)
                For j As Integer = 1 To 5
                    Dim tc As TextBox = CType(wc.FindControl("txtCal" + j.ToString()), TextBox)
                    Dim tq As TextBox = CType(wc.FindControl("txtQty" + j.ToString()), TextBox)
                    If tc IsNot Nothing AndAlso tq IsNot Nothing AndAlso tc.Text.Trim() <> "" AndAlso tq.Text.Trim() <> "" Then
                        Dim schDTRow As MY_PRJ_REG_PRODUCT_SCHEDULESRow = schDT.NewMY_PRJ_REG_PRODUCT_SCHEDULESRow()
                        With schDTRow
                            .ROW_ID = Guid.NewGuid().ToString() : .PRJ_PROD_ROW_ID = prodDtRow.ROW_ID : .SCHEDULE_LINE_NO = j
                            .SHIP_DATE = CDate(tc.Text) : .QTY = CInt(tq.Text) : .CREATED_BY = User.Identity.Name
                            .CREATED_DATE = Now() : .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now()
                            Stotalqty += .QTY
                        End With
                        schDT.AddMY_PRJ_REG_PRODUCT_SCHEDULESRow(schDTRow)
                        schDT.AcceptChanges()
                    End If
                Next
                schDT.AcceptChanges()
                If Stotalqty <> 0 AndAlso prodDtRow.QTY <> Stotalqty Then
                    lbMsg.Text = String.Format("The total qty is different with the summarized schedule qty for model {0} ", prodDtRow.PART_NO)
                    Return False
                End If
                ''end 
            End If
        Next
        prodDt.AcceptChanges()
        ''
        ''Master
        Dim PrjMasterDt As New MY_PRJ_REG_MASTERDataTable
        Dim prjMasterRow As MY_PRJ_REG_MASTERRow = PrjMasterDt.NewMY_PRJ_REG_MASTERRow()
        With prjMasterRow
            .ROW_ID = Guid.NewGuid().ToString() : .CP_COMPANY_ID = Session("company_id") : .CP_ACCOUNT_ROW_ID = USPrjRegUtil.GetAccountRowID(Session("company_id"))
            .ENDCUST_NAME = T(txtEndCustomerName.Text) : .ENDCUST_POST_CODE = T(txtEndCustPostCode.Text) : .ENDCUST_STATE = T(txtEndCustState.Text)
            .ENDCUST_ADDR = T(txtEndCustAddr.Text) : .ENDCUST_COUNTRY = dlEndCustCountry.SelectedValue : .ENDCUST_ADDR = T(txtEndCustAddr.Text)
            .ENDCUST_ACCOUNT_ROW_ID = InterConPrjRegUtil.GetAccountRowIDbyName(txtEndCustomerName.Text)
            .PRJ_OPTY_ID = "" : .PRJ_NAME = T(txtPrjName.Text) : .PRJ_DESC = T(txtPrjDesc.Text) : .PRJ_EST_CLOSE_DATE = CDate(txtPrjCloseDate.Text)
            .PRJ_TOTAL_AMT = 0
            If Decimal.TryParse(txtPrjAmt.Text, 0) Then
                .PRJ_TOTAL_AMT = CDec(txtPrjAmt.Text)
            End If
            .PRJ_AMT_CURR = Session("COMPANY_CURRENCY")
            .POTENTIAL_RISK = T(txtSPRLB.Text) : .NEEDED_ADV_SUPPORT = T(TBnas.Text)
            .CREATED_BY = Session("user_id") : .CREATED_DATE = Now()
            .LAST_UPD_BY = Session("user_id") : .LAST_UPD_DATE = Now()
        End With
        PrjMasterDt.AddMY_PRJ_REG_MASTERRow(prjMasterRow)
        PrjMasterDt.AcceptChanges()
        ''
        ''contacts
        Dim prjContactDt As New MY_PRJ_REG_CONTACTSDataTable
        For i As Integer = 1 To 5
            Dim tp As TextBox = Me.Master.FindControl("_main").FindControl("txtEndContactLName" + i.ToString())
            If tp.Text.Trim() <> "" Then
                Dim prjContactRow1 As MY_PRJ_REG_CONTACTSRow = prjContactDt.NewMY_PRJ_REG_CONTACTSRow()
                With prjContactRow1
                    .ROW_ID = Guid.NewGuid().ToString() : .PRJ_ROW_ID = ""
                    .CONTACT_ROW_ID = "" : .LAST_NAME = T(tp.Text) : .FIRST_NAME = TB("txtEndContactFName" + i.ToString())
                    .EMAIL = TB("txtEndContactEmail" + i.ToString()) : .TEL = TB("txtEndContactTel" + i.ToString())
                    .CREATED_BY = User.Identity.Name : .CREATED_DATE = Now() : .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now()
                End With
                prjContactDt.AddMY_PRJ_REG_CONTACTSRow(prjContactRow1)
            End If
        Next
        prjContactDt.AcceptChanges()
        ''
        ''Competitor 
        Dim compDt As New MY_PRJ_REG_COMPETITORSDataTable
        For i As Integer = 1 To 5
            Dim tp As TextBox = Me.Master.FindControl("_main").FindControl("txtCopCompanyName" + i.ToString())
            If tp.Text.Trim() <> "" Then
                Dim compDtRow As MY_PRJ_REG_COMPETITORSRow = compDt.NewMY_PRJ_REG_COMPETITORSRow()
                With compDtRow
                    .ROW_ID = Guid.NewGuid().ToString()
                    .PRJ_ROW_ID = "" : .COMPETITOR_NAME = TB("txtCopCompanyName" + i.ToString()) : .MODEL_NO = TB("txtCopModel" + i.ToString())
                    Dim strTmpPrice As String = CType(Me.Master.FindControl("_main").FindControl("txtCopPrice" + i.ToString()), TextBox).Text
                    Dim decTmpPrice As Decimal = 0
                    If Decimal.TryParse(strTmpPrice, 0) Then decTmpPrice = Decimal.Parse(strTmpPrice)
                    .SELLING_PRICE = decTmpPrice : .SELLING_CURR = Session("COMPANY_CURRENCY")
                    .REMARK = TB("txtRemark" + i.ToString()) : .CREATED_BY = User.Identity.Name : .CREATED_DATE = Now()
                    .LAST_UPD_BY = User.Identity.Name : .LAST_UPD_DATE = Now()
                End With
                compDt.AddMY_PRJ_REG_COMPETITORSRow(compDtRow)
            End If
        Next
        compDt.AcceptChanges()
        If Not String.IsNullOrEmpty(hfRowID.Value) Then
            'Edit mode will delete data then save it
            Dim sql As New StringBuilder()
            Dim pdDT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("SELECT ROW_ID FROM MY_PRJ_REG_PRODUCTS where PRJ_ROW_ID = '{0}'", hfRowID.Value))
            If Not pdDT Is Nothing AndAlso pdDT.Rows.Count > 0 Then
                For Each dr As DataRow In pdDT.Rows
                    sql.AppendFormat("DELETE FROM MY_PRJ_REG_PRODUCT_SCHEDULES where PRJ_PROD_ROW_ID = '{0}';", dr(0).ToString())
                Next
            End If
            sql.AppendFormat("DELETE FROM MY_PRJ_REG_AUDIT where PRJ_ROW_ID = '{0}'; ", hfRowID.Value)
            sql.AppendFormat("DELETE FROM MY_PRJ_REG_PRIMARY_SALES_EMAIL where PRJ_ROW_ID = '{0}'; ", hfRowID.Value)
            sql.AppendFormat("DELETE FROM MY_PRJ_REG_COMPETITORS where PRJ_ROW_ID = '{0}'; ", hfRowID.Value)
            sql.AppendFormat("DELETE FROM MY_PRJ_REG_PRODUCTS where PRJ_ROW_ID = '{0}'; ", hfRowID.Value)
            sql.AppendFormat("DELETE FROM MY_PRJ_REG_CONTACTS where PRJ_ROW_ID = '{0}'; ", hfRowID.Value)
            sql.AppendFormat("DELETE FROM MY_PRJ_REG_MASTER where ROW_ID = '{0}'; ", hfRowID.Value)
            Try
                dbUtil.dbExecuteNoQuery("MYLOCAL", sql.ToString())
            Catch ex As Exception
                Return False
            End Try
        End If
        InterConPrjRegUtil.AddProject(PrjMasterDt, prjContactDt, prodDt, compDt, schDT, ddlPrimarySales.SelectedValue, stage)
        Return True
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:HiddenField runat="server" ID="hd_EndCustRowId" />
    <asp:HiddenField runat="server" ID="hfRowID" />
    <link href="Image/PJcss.css" rel="stylesheet" type="text/css" />
    <script src="../../Includes/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="Image/my.js" type="text/javascript"></script>
    <table width="100%">
        <tr>
            <th align="left" style="font-size: large; color: Navy; height: 40px;">
                Project Registration
            </th>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upEndCust" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <th align="left" colspan="2" class="titlebg">
                                    <h2>
                                        Sold-to Customer Info.</h2>
                                </th>
                            </tr>
                            <tr>
                                <td height="10px" colspan="2">
                                </td>
                            </tr>
                            <tr>
                                <th align="right" width="20%">
                                    <span class="TdName">*</span>Sold-to Customer Name:
                                </th>
                                <td>
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext1" OnClientItemSelected="EndCustSelected"
                                        TargetControlID="txtEndCustomerName" MinimumPrefixLength="0" Enabled="false"
                                        CompletionInterval="500" ServiceMethod="AutoSuggestCustName" />
                                    <asp:TextBox runat="server" ID="txtEndCustomerName" Width="500px" />
                                </td>
                            </tr>
                            <tr>
                                <th align="right">
                                    Postal Code:
                                </th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtEndCustPostCode" Width="50px" />
                                </td>
                            </tr>
                            <tr>
                                <th align="right">
                                    State:
                                </th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtEndCustState" Width="80px" />
                                </td>
                            </tr>
                            <tr valign="top">
                                <th align="right">
                                    Address:
                                </th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtEndCustAddr" Width="398px" TextMode="MultiLine"
                                        Height="23px" />
                                </td>
                            </tr>
                            <tr valign="top">
                                <th align="right">
                                    Country:
                                </th>
                                <td>
                                    <asp:DropDownList runat="server" ID="dlEndCustCountry">
                                        <asp:ListItem Value="Albania" />
                                        <asp:ListItem Value="Algeria" />
                                        <asp:ListItem Value="Amer.Virgin Is." />
                                        <asp:ListItem Value="Angola" />
                                        <asp:ListItem Value="Argentina" />
                                        <asp:ListItem Value="Armenia" />
                                        <asp:ListItem Value="Australia" />
                                        <asp:ListItem Value="Austria" />
                                        <asp:ListItem Value="Azerbaijan" />
                                        <asp:ListItem Value="Bahamas" />
                                        <asp:ListItem Value="Bahrain" />
                                        <asp:ListItem Value="Bangladesh" />
                                        <asp:ListItem Value="Belarus" />
                                        <asp:ListItem Value="Belgium" />
                                        <asp:ListItem Value="Belize" />
                                        <asp:ListItem Value="Bermuda" />
                                        <asp:ListItem Value="Bolivia" />
                                        <asp:ListItem Value="Bosnia-Herz." />
                                        <asp:ListItem Value="Brazil" />
                                        <asp:ListItem Value="Brit.Virgin Is." />
                                        <asp:ListItem Value="Brunei Daruss." />
                                        <asp:ListItem Value="Bulgaria" />
                                        <asp:ListItem Value="Burkina-Faso" />
                                        <asp:ListItem Value="Cambodia" />
                                        <asp:ListItem Value="Canada" />
                                        <asp:ListItem Value="Cayman Islands" />
                                        <asp:ListItem Value="Chile" />
                                        <asp:ListItem Value="China" />
                                        <asp:ListItem Value="Colombia" />
                                        <asp:ListItem Value="Costa Rica" />
                                        <asp:ListItem Value="Croatia" />
                                        <asp:ListItem Value="Cyprus" />
                                        <asp:ListItem Value="Czech Republic" />
                                        <asp:ListItem Value="Denmark" />
                                        <asp:ListItem Value="Dominica" />
                                        <asp:ListItem Value="Dominican Rep." />
                                        <asp:ListItem Value="Dutch Antilles" />
                                        <asp:ListItem Value="Ecuador" />
                                        <asp:ListItem Value="Egypt" />
                                        <asp:ListItem Value="El Salvador" />
                                        <asp:ListItem Value="Estonia" />
                                        <asp:ListItem Value="Falkland Islnds" />
                                        <asp:ListItem Value="Fiji" />
                                        <asp:ListItem Value="Finland" />
                                        <asp:ListItem Value="France" />
                                        <asp:ListItem Value="French S.Territ" />
                                        <asp:ListItem Value="Georgia" />
                                        <asp:ListItem Value="Germany" />
                                        <asp:ListItem Value="Greece" />
                                        <asp:ListItem Value="Greenland" />
                                        <asp:ListItem Value="Grenada" />
                                        <asp:ListItem Value="Guatemala" />
                                        <asp:ListItem Value="Honduras" />
                                        <asp:ListItem Value="Hong Kong" />
                                        <asp:ListItem Value="Hungary" />
                                        <asp:ListItem Value="Iceland" />
                                        <asp:ListItem Value="India" />
                                        <asp:ListItem Value="Indonesia" />
                                        <asp:ListItem Value="Iran" />
                                        <asp:ListItem Value="Iraq" />
                                        <asp:ListItem Value="Ireland" />
                                        <asp:ListItem Value="Israel" />
                                        <asp:ListItem Value="Italy" />
                                        <asp:ListItem Value="Jamaica" />
                                        <asp:ListItem Value="Japan" />
                                        <asp:ListItem Value="Jordan" />
                                        <asp:ListItem Value="Kazakhstan" />
                                        <asp:ListItem Value="Kenya" />
                                        <asp:ListItem Value="Kuwait" />
                                        <asp:ListItem Value="Kyrgyzstan" />
                                        <asp:ListItem Value="Laos" />
                                        <asp:ListItem Value="Latvia" />
                                        <asp:ListItem Value="Lebanon" />
                                        <asp:ListItem Value="Libya" />
                                        <asp:ListItem Value="Liechtenstein" />
                                        <asp:ListItem Value="Lithuania" />
                                        <asp:ListItem Value="Luxembourg" />
                                        <asp:ListItem Value="Macau" />
                                        <asp:ListItem Value="Macedonia" />
                                        <asp:ListItem Value="Madagascar" />
                                        <asp:ListItem Value="Malawi" />
                                        <asp:ListItem Value="Malaysia" />
                                        <asp:ListItem Value="Maldives" />
                                        <asp:ListItem Value="Malta" />
                                        <asp:ListItem Value="Mauritania" />
                                        <asp:ListItem Value="Mauritius" />
                                        <asp:ListItem Value="Mexico" />
                                        <asp:ListItem Value="Moldova" />
                                        <asp:ListItem Value="Monaco" />
                                        <asp:ListItem Value="Mongolia" />
                                        <asp:ListItem Value="Morocco" />
                                        <asp:ListItem Value="Nepal" />
                                        <asp:ListItem Value="Netherlands" />
                                        <asp:ListItem Value="New Caledonia" />
                                        <asp:ListItem Value="New Zealand" />
                                        <asp:ListItem Value="Nicaragua" />
                                        <asp:ListItem Value="Niger" />
                                        <asp:ListItem Value="Nigeria" />
                                        <asp:ListItem Value="Norway" />
                                        <asp:ListItem Value="Oman" />
                                        <asp:ListItem Value="Pakistan" />
                                        <asp:ListItem Value="Panama" />
                                        <asp:ListItem Value="Paraguay" />
                                        <asp:ListItem Value="Peru" />
                                        <asp:ListItem Value="Philippines" />
                                        <asp:ListItem Value="Poland" />
                                        <asp:ListItem Value="Portugal" />
                                        <asp:ListItem Value="Puerto Rico" />
                                        <asp:ListItem Value="Qatar" />
                                        <asp:ListItem Value="Romania" />
                                        <asp:ListItem Value="Russia" />
                                        <asp:ListItem Value="Saudi Arabia" />
                                        <asp:ListItem Value="Serbia" />
                                        <asp:ListItem Value="Sierra Leone" />
                                        <asp:ListItem Value="Singapore" />
                                        <asp:ListItem Value="Slovakia" />
                                        <asp:ListItem Value="Slovenia" />
                                        <asp:ListItem Value="Solomon Islands" />
                                        <asp:ListItem Value="South Africa" />
                                        <asp:ListItem Value="South Korea" />
                                        <asp:ListItem Value="Spain" />
                                        <asp:ListItem Value="Sri Lanka" />
                                        <asp:ListItem Value="St. Martin" />
                                        <asp:ListItem Value="Swaziland" />
                                        <asp:ListItem Value="Sweden" />
                                        <asp:ListItem Value="Switzerland" />
                                        <asp:ListItem Value="Syria" />
                                        <asp:ListItem Value="Taiwan" />
                                        <asp:ListItem Value="Tajikistan" />
                                        <asp:ListItem Value="Thailand" />
                                        <asp:ListItem Value="Trinidad,Tobago" />
                                        <asp:ListItem Value="Tunisia" />
                                        <asp:ListItem Value="Turkey" />
                                        <asp:ListItem Value="Uganda" />
                                        <asp:ListItem Value="Ukraine" />
                                        <asp:ListItem Value="United Kingdom" />
                                        <asp:ListItem Value="Uruguay" />
                                        <asp:ListItem Value="USA" />
                                        <asp:ListItem Value="Utd.Arab Emir." />
                                        <asp:ListItem Value="Uzbekistan" />
                                        <asp:ListItem Value="Venezuela" />
                                        <asp:ListItem Value="Vietnam" />
                                        <asp:ListItem Value="Yugoslavia" />
                                        <asp:ListItem Value="Zambia" />
                                        <asp:ListItem Value="Zimbabwe" />
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr valign="top">
                                <th align="right">
                                    Contact(s):
                                </th>
                                <td>
                                    <asp:UpdatePanel runat="server" ID="upEndContact" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <table width="590px">
                                                <tr>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <th>
                                                        Last Name
                                                    </th>
                                                    <th>
                                                        First Name
                                                    </th>
                                                    <th>
                                                        E-mail
                                                    </th>
                                                    <th>
                                                        Telephone
                                                    </th>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactLName1" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactFName1" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactEmail1" />
                                                    </td>
                                                    <td>
                                                        +<asp:TextBox runat="server" ID="txtEndContactTel1" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactLName2" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactFName2" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactEmail2" />
                                                    </td>
                                                    <td>
                                                        +<asp:TextBox runat="server" ID="txtEndContactTel2" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="tr_EndContact3" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactLName3" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactFName3" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactEmail3" />
                                                    </td>
                                                    <td>
                                                        +<asp:TextBox runat="server" ID="txtEndContactTel3" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="tr_EndContact4" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactLName4" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactFName4" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactEmail4" />
                                                    </td>
                                                    <td>
                                                        +<asp:TextBox runat="server" ID="txtEndContactTel4" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="tr_EndContact5" visible="false">
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactLName5" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactFName5" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtEndContactEmail5" />
                                                    </td>
                                                    <td>
                                                        +<asp:TextBox runat="server" ID="txtEndContactTel5" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="5" align="right">
                                                        <asp:Button runat="server" CssClass="signin-bt" ID="btnMoreContact" Text="+More"
                                                            OnClick="btnMoreContact_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <%--<asp:AsyncPostBackTrigger ControlID="btnSubmit" EventName="Click" />--%>
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upPrj" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <th align="left" colspan="2" class="titlebg">
                                    <h2 id="Pjinfor">
                                        Project Information</h2>
                                </th>
                            </tr>
                            <tr>
                                <td height="10px" colspan="2">
                                </td>
                            </tr>
                            <tr>
                                <th align="right" width="20%">
                                    <span class="TdName">*</span>Project Name:
                                </th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtPrjName" Width="500px" />
                                </td>
                            </tr>
                            <tr valign="top">
                                <th align="right">
                                    Project Description:
                                </th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtPrjDesc" Width="500px" TextMode="MultiLine" Height="50px" />
                                </td>
                            </tr>
                            <tr valign="top">
                                <th align="right">
                                    Potential risk:
                                </th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtSPRLB" Width="500px" TextMode="MultiLine" Height="50px" />
                                </td>
                            </tr>
                            <tr valign="top">
                                <th align="right">
                                    Needed Advantech Support:
                                </th>
                                <td>
                                    <asp:TextBox runat="server" ID="TBnas" Width="500px" TextMode="MultiLine" Height="50px" />
                                </td>
                            </tr>
                            <tr>
                                <th align="right">
                                    <span class="TdName">*</span>Close Date:
                                </th>
                                <td>
                                    <ajaxToolkit:CalendarExtender runat="server" ID="cext1" TargetControlID="txtPrjCloseDate"
                                        Format="yyyy/MM/dd" />
                                    <asp:TextBox runat="server" ID="txtPrjCloseDate" Width="70px" />
                                </td>
                            </tr>
                            <tr runat="server" visible="false">
                                <th align="right">
                                    Total Amount:
                                </th>
                                <td>
                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender6"
                                        TargetControlID="txtPrjAmt" FilterMode="ValidChars" FilterType="Numbers" />
                                    <asp:TextBox runat="server" ID="txtPrjAmt" Width="70px" ReadOnly="true" BackColor="Silver" />&nbsp;<b></b>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <%--<asp:AsyncPostBackTrigger ControlID="btnSubmit" EventName="Click" />--%>
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upCop" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr>
                                <th align="left" colspan="2" class="titlebg">
                                    <h2 id="Competitor">
                                        Competitor Information</h2>
                                </th>
                            </tr>
                            <tr>
                                <td height="10px" colspan="2">
                                </td>
                            </tr>
                            <tr valign="top">
                                <th align="right" width="0px">
                                </th>
                                <td>
                                    <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <table width="100%">
                                                <tr>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <th>
                                                        Company Name
                                                    </th>
                                                    <th>
                                                        Model No.
                                                    </th>
                                                    <th>
                                                        Selling Price
                                                    </th>
                                                    <th>
                                                        Remark
                                                    </th>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopCompanyName1" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopModel1" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopPrice1" /><b></b>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtRemark1" Width="300" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopCompanyName2" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopModel2" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopPrice2" /><b></b>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtRemark2" Width="300" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="tr_Cop3" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopCompanyName3" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopModel3" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopPrice3" /><b></b>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtRemark3" Width="300" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="tr_Cop4" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopCompanyName4" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopModel4" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopPrice4" /><b></b>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtRemark4" Width="300" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="tr_Cop5" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopCompanyName5" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopModel5" />
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtCopPrice5" /><b></b>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtRemark5" Width="300" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="5" align="right">
                                                        <asp:Button runat="server" CssClass="signin-bt" ID="btnMoreCop" Text="+More" OnClick="btnMoreCop_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                        </table>
                        <table width="100%">
                            <tr>
                                <th align="left" class="titlebg">
                                    <h2 id="ProInfo">
                                        Product(s) Information</h2>
                                </th>
                            </tr>
                            <tr>
                                <td height="10px">
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <asp:UpdatePanel runat="server" ID="upProd" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <table width="100%">
                                                <tr>
                                                    <td height="40">
                                                    </td>
                                                    <th>
                                                        Model No.
                                                    </th>
                                                    <th>
                                                        Qty.
                                                    </th>
                                                    <th align="center">
                                                        Remark
                                                    </th>
                                                    <th align="center" style="width: 100px">
                                                        Selling Price
                                                    </th>
                                                    <th align="center" style="width: 100px">
                                                        Special Price Request
                                                    </th>
                                                    <th align="center" style="width: 100px">
                                                        CP Standard Price
                                                    </th>
                                                </tr>
                                                <tr runat="server" id="trProd1" visible="true">
                                                    <td align="right">
                                                        <span class="TdName">*</span>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="txtModel1"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel1" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1"
                                                            TargetControlID="txtProdQty1" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty1" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules1" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark1" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice1" CssClass="TBprice" Width="50px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR1" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP1" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd2" visible="true">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender2" TargetControlID="txtModel2"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel2" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender2"
                                                            TargetControlID="txtProdQty2" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty2" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules2" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark2" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice2" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR2" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP2" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd3" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender3" TargetControlID="txtModel3"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel3" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender3"
                                                            TargetControlID="txtProdQty3" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty3" Width="25px" />
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules3" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark3" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice3" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR3" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP3" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd4" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender4" TargetControlID="txtModel4"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel4" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender4"
                                                            TargetControlID="txtProdQty4" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty4" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules4" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark4" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice4" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR4" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP4" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd5" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender5" TargetControlID="txtModel5"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel5" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender5"
                                                            TargetControlID="txtProdQty5" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty5" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules5" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark5" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice5" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR5" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP5" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd6" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender6" TargetControlID="txtModel6"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel6" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender7"
                                                            TargetControlID="txtProdQty6" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty6" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules6" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark6" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice6" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR6" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP6" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd7" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender7" TargetControlID="txtModel7"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel7" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender8"
                                                            TargetControlID="txtProdQty7" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty7" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules7" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark7" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice7" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR7" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP7" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd8" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender8" TargetControlID="txtModel8"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel8" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender9"
                                                            TargetControlID="txtProdQty8" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty8" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules8" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark8" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice8" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR8" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP8" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd9" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender9" TargetControlID="txtModel9"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel9" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender10"
                                                            TargetControlID="txtProdQty9" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty9" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules9" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark9" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice9" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR9" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP9" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd10" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender10" TargetControlID="txtModel10"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel10" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender11"
                                                            TargetControlID="txtProdQty10" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty10" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules10" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark10" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice10" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR10" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP10" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd11" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender11" TargetControlID="txtModel11"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel11" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender12"
                                                            TargetControlID="txtProdQty11" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty11" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules11" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark11" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice11" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR11" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP11" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd12" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender12" TargetControlID="txtModel12"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel12" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender13"
                                                            TargetControlID="txtProdQty12" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty12" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules12" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark12" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice12" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR12" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP12" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd13" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender13" TargetControlID="txtModel13"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel13" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender14"
                                                            TargetControlID="txtProdQty13" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty13" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules13" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark13" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice13" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR13" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP13" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd14" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender14" TargetControlID="txtModel14"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel14" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender15"
                                                            TargetControlID="txtProdQty14" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty14" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules14" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark14" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice14" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR14" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP14" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd15" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender15" TargetControlID="txtModel15"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel15" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender16"
                                                            TargetControlID="txtProdQty15" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty15" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules15" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark15" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice15" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR15" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP15" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd16" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender16" TargetControlID="txtModel16"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel16" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender17"
                                                            TargetControlID="txtProdQty16" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty16" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules16" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark16" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice16" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR16" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP16" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd17" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender17" TargetControlID="txtModel17"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel17" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender18"
                                                            TargetControlID="txtProdQty17" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty17" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules17" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark17" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice17" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR17" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP17" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd18" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender18" TargetControlID="txtModel18"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel18" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender19"
                                                            TargetControlID="txtProdQty18" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty18" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules18" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark18" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice18" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR18" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP18" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd19" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender19" TargetControlID="txtModel19"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel19" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender20"
                                                            TargetControlID="txtProdQty19" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty19" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules19" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark19" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice19" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR19" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP19" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trProd20" visible="false">
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender20" TargetControlID="txtModel20"
                                                            ServiceMethod="AutoSuggestPN" CompletionInterval="100" MinimumPrefixLength="1"
                                                            OnClientItemSelected="PNSelected" />
                                                        <asp:TextBox runat="server" ID="txtModel20" Width="130px" />
                                                    </td>
                                                    <td>
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender21"
                                                            TargetControlID="txtProdQty20" FilterMode="ValidChars" FilterType="Numbers" />
                                                        <asp:TextBox runat="server" ID="txtProdQty20" Width="25px" />&nbsp;
                                                        <div class="PopupDiv">
                                                            <div class="DivSchedule">
                                                                <uc1:Schedules ID="Schedules20" runat="server" />
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtPRemark20" Width="250px" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txt2EndPrice20" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:TextBox runat="server" ID="txtSPR20" Width="50px" CssClass="TBprice" />
                                                    </td>
                                                    <td align="center">
                                                        <asp:Label runat="server" ID="txtCPP20" Width="50px" CssClass="cpprice" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="7" align="right">
                                                        <asp:Button runat="server" CssClass="signin-bt" ID="btnMoreProd" Text="+More" OnClick="btnMoreProd_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </ContentTemplate>
                                        <Triggers>
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </th>
                            </tr>
                            <tr>
                                <td>
                                    <div id="divhr">
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" height="20">
                                    <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                                        <ContentTemplate>
                                            <asp:Label runat="server" ID="lbMsg" ForeColor="Tomato" Font-Bold="true" />
                                        </ContentTemplate>
                                        <Triggers>
                                            <asp:AsyncPostBackTrigger ControlID="btnSubmit" EventName="Click" />
                                        </Triggers>
                                    </asp:UpdatePanel>
                                </td>
                            </tr>
                            <tr>
                                <td height="30">
                                    <table width="100%">
                                        <tr>
                                            <td width="40%" align="center" style="padding-bottom: 5%">
                                                Send to sales:
                                                <asp:DropDownList runat="server" ID="ddlPrimarySales"></asp:DropDownList>
                                            </td>
                                            <td align="left">
                                                <asp:Button runat="server" ID="btnSubmit" Text="Submit" Font-Bold="true" Font-Size="Larger"
                                                    Width="120px" Height="30px" OnClick="btnSubmit_Click" OnClientClick="return disableSubmitBtn();" />&nbsp;&nbsp;
                                                <asp:Button runat="server" ID="btnSave" Text="Save for further edit" Font-Bold="true" Font-Size="Larger" Width="250px" Height="30px" OnClick="btnSave_Click" OnClientClick="return disableSubmitBtn();" />
                                                <p>
                                                    <br />
                                                    <br />
                                                </p>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSubmit" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="btnSave" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <script language="javascript" type="text/javascript">
        $(document).ready(function () {
            // 在这里写你的代码...
            $(".PopupDiv").hover(
              function () {
                  $(this).find("div").addClass("show");
              },
                      function () {
                          sleep(100);
                          $(this).find("div").removeClass("show");
                      }
                              );
                      $(".TBprice").focusout(function (event) {
                if ($.isNumeric($(this).val()) || $(this).val()=="") { }
                else {
                    alert("The value entered is invalid!");
                    $(this).val("");
                    $(this).focus();

                }
            });
            // 在这里写你的代码...
        });
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(EndRequestHandler);
        function EndRequestHandler(sender, args) {
            if (args.get_error() == undefined) {
                $(".PopupDiv").hover(
              function () {
                  $(this).find("div").addClass("show");
              },
                      function () {
                          sleep(100);
                          $(this).find("div").removeClass("show");
                      }
                              );
            }
        }
        function sleep(milliseconds) {
            var start = new Date().getTime();
            for (var i = 0; i < 1e7; i++) {
                if ((new Date().getTime() - start) > milliseconds) {
                    break;
                }
            }
        }
        function disableSubmitBtn() {
            window.setTimeout("DisBtn()", 2);
        }
        function DisBtn() {
            var btn = document.getElementById('<%=btnSubmit.ClientID %>');
            btn.disabled = true;
        }
        function enableSubmitBtn() {
            var btn = document.getElementById('<%=btnSubmit.ClientID %>');
            btn.disabled = false;
        }
    </script>
    <script type="text/javascript">
        function EndCustSelected(source, eventArgs) {
            //alert(" Key : " + eventArgs.get_text() + " Value : " + eventArgs.get_value());
            var rid = eventArgs.get_value();
            //alert(rid);
            FillEndCustAdd(rid);
        }
        function PNSelected(source, eventArgs) {
            //            alert(" Key : " + eventArgs.get_text() + " Value : " + eventArgs.get_value());
            //            alert(source.get_element().id);
            var txtID = source.get_element().id;
            //alert(txtID);
            if (txtID) {
                FillModelCPPrice(eventArgs.get_value(), txtID);
                //                alert('1');
                //                document.getElementById(txtID).value = 'aaaaaaaa';
                //                alert('2');
            }
        }
        function FillModelCPPrice(modelno, sourceid) {
            PageMethods.GetPrice(modelno,
                function (pagedResult, eleid, methodName) {
                    //alert(pagedResult);
                    var p = pagedResult;
                    if (p) {
                        if (p > 0) {
                            var pid = sourceid.replace('_main_txtModel', '_main_txtCPP');
                            //alert(pid);
                            document.getElementById(pid).innerHTML = p;
                        }
                    }
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                }
            );
        }
        function FillEndCustAdd(rid) {
            var custZip = document.getElementById('<%=txtEndCustPostCode.ClientID %>');
            var custAddr = document.getElementById('<%=txtEndCustAddr.ClientID %>');
            var custState = document.getElementById('<%=txtEndCustState.ClientID %>');
            var clist = document.getElementById('<%=dlEndCustCountry.ClientID %>');
            PageMethods.GetAddrByCustRowId(rid,
                function (pagedResult, eleid, methodName) {
                    var dt = pagedResult;
                    if (dt != null && typeof (dt) == "object") {
                        if (dt.rows.length = 1) {
                            //alert(dt.rows[0].COUNTRY);
                            custZip.value = dt.rows[0].ZIPCODE;
                            custAddr.value = dt.rows[0].ADDRESS;
                            custState.value = dt.rows[0].STATE;
                            //alert('1');
                            var ctry = dt.rows[0].COUNTRY;
                            //alert(ctry);
                            //alert(clist);
                            for (i = 0; i < clist.length; i++) {
                                if (clist.options[i].value == ctry) {
                                    clist.selectedIndex = i;
                                    break;
                                }
                            }
                            document.getElementById('<%=hd_EndCustRowId.ClientID %>').value = rid;
                            //alert(document.getElementById('<%=hd_EndCustRowId.ClientID %>').value);
                        }
                    }
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                }
            );
        }
    </script>
</asp:Content>
