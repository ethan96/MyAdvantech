﻿<%@ Page Title="MyAdvantech – Check Price & Availability" EnableEventValidation="false"
    Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Src="~/ascx/PickPN.ascx" TagName="PickProduct" TagPrefix="myASCX" %>
<script runat="server">
    Dim isPremierCustomer As Boolean = False
    Dim DefaultShipto As String = String.Empty, CountryCode As String = String.Empty

    Protected Function getProductTable(ByVal Pat As String) As DataTable
        If Pat.Contains("*") Then
            Pat = Replace(Pat, "*", "%").Trim()
        End If
        If Pat = "" Then
            Return Nothing
        End If
        '20180419 TC: Replace SAP_PRODUCT_STATUS with SAP_PRODUCT_STATUS_ORDERABLE
        'Frank 2012/01/10:
        '以task249加了IIf(Util.IsInternalUser(Session("user_id")), " ", " and b.product_line != 'DLGR' ")這一行
        Dim str As String = String.Format(
    " select distinct TOP 50 a.Part_no,'0' as qty,'0' as listprice,'0' as unitprice, b.model_no, b.product_desc, " +
    " c.ABC_INDICATOR, b.product_group, b.product_division, b.product_line, " +
    " (select top 1 z.EMAIL_ADDR from SAP_GIP_CONTACT z where z.GIP_CODE=b.GIP_CODE and z.GIP_CODE<>'' and dbo.IsEmail(z.EMAIL_ADDR)=1) as GIP_EMAIL, " +
    "Gross_weight,Net_weight,size_DIMENSIONS ,'' AS PROD_STATUS,'' AS STATUS_DESC " +
    " from SAP_PRODUCT_STATUS_ORDERABLE a inner join sap_product b ON A.PART_NO=B.PART_NO " +
    " left join SAP_PRODUCT_ABC c on a.PART_NO=c.PART_NO and a.DLV_PLANT=c.PLANT " +
    " where a.part_no like '{0}%' and a.sales_org='{1}' " +
    " and a.part_no not like '%-bto' and a.PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus").ToString + " and b.material_group <> '207' " +
IIf(Util.IsInternalUser2() OrElse HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN"), " ", " and b.material_group not in ('ODM','ODM-P','T','ES','ZSRV','968MS','96SW','206') and GENITEMCATGRP  <> 'ZSWL' and b.PRODUCT_HIERARCHY!='EAPC-INNO-DPX'" +
    " and left(a.PART_NO,1) not in ('X','Y') ") +
    " ", Pat, Session("org_id")) +
IIf(Util.IsInternalUser(Session("user_id")) OrElse HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN"), " ", " and b.product_line != 'DLGR' ")

        'Ryan 20160727 Block non-internal users viewing T/P indicator items
        str += IIf(Util.IsInternalUser(Session("user_id")) OrElse HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN"), " ", " and c.ABC_INDICATOR not in ('T','P') ")

        'Ryan 20161202 Block non-internal users viewing V status items
        str += IIf(Util.IsInternalUser(Session("user_id")) OrElse HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN"), " ", " and a.PRODUCT_STATUS <> 'V' ")

        'Ryan 20160419 If ERPID is defined in ZTSD_106C, then can't see 968T parts.
        If Not Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(Session("company_id").ToString()) Then
            str += " and a.PART_NO not like '968T%' "
        End If

        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", str)

        If dt.Rows.Count <= 0 Then
            Return Nothing
        End If

        Dim Oconn As Oracle.DataAccess.Client.OracleConnection = New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
        Try
            For Each r As DataRow In dt.Rows
                Dim PSAP As String = r.Item("Part_No").ToString
                If IsNumeric(PSAP) Then
                    PSAP = CDbl(PSAP).ToString("000000000000000000")
                End If
                If Not IsNothing(Oconn) Then
                    Dim dtStatus As New DataTable
                    'Dim da As New Oracle.DataAccess.Client.OracleDataAdapter(String.Format("SELECT A.MMSTA AS STATUS_CODE,C.VMSTB AS STATUS_DESC from saprdp.marc a " &
                    '" left join saprdp.tvmst c on a.mmsta=c.vmsta where a.mandt='168' " &
                    '" and a.werks='{1}' and a.matnr='{0}' and c.spras='E' and rownum=1 ", PSAP, Me.drpPlant.SelectedValue), Oconn)

                    'Alex Chiu 20160613 change status column data source from MARC to MVKE
                    Dim da As New Oracle.DataAccess.Client.OracleDataAdapter(String.Format("Select A.VMSTA As STATUS_CODE,C.VMSTB As STATUS_DESC from saprdp.MVKE a " &
                " left join saprdp.tvmst c On a.vmsta=c.vmsta where a.mandt='168'  " &
                " And a.DWERK ='{1}' and a.matnr='{0}' and c.spras='E' and rownum=1 ", PSAP, Me.drpPlant.SelectedValue), Oconn)


                    da.Fill(dtStatus)
                    If Not IsNothing(dtStatus) AndAlso dtStatus.Rows.Count > 0 Then
                        r.Item("PROD_STATUS") = dtStatus.Rows(0).Item("STATUS_CODE")
                        r.Item("STATUS_DESC") = dtStatus.Rows(0).Item("STATUS_DESC")
                    End If
                End If
            Next

        Catch ex As Exception
            Throw ex
        Finally
            If Not IsNothing(Oconn) Then
                Oconn.Close() : Oconn = Nothing
            End If
        End Try

        If Session("company_id").ToString().Equals("EHLA002", StringComparison.OrdinalIgnoreCase) Then
            Dim ws As New MYSAPDAL
            Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
            For Each r As DataRow In dt.Rows
                'for CN Block MEDC product to show price
                If Not (Session("org_id").ToString.ToUpper.StartsWith("CN") AndAlso SAPDAL.CommonLogic.isMEDC(r.Item("part_no")) AndAlso Not Util.IsInternalUser2()) Then
                    pin.AddProductInRow(r.Item("part_no"), 1)
                End If
            Next
            If ws.GetListPrice(Session("org_id"), "", "EUR", pin, pout, errMsg) Then
                For Each r As DataRow In dt.Rows
                    Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + r.Item("part_no") + "'")
                    If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).LIST_PRICE, 0) Then
                        r.Item("unitprice") = FormatNumber(rs(0).LIST_PRICE, 2).Replace(",", "")
                        r.Item("listprice") = FormatNumber(rs(0).LIST_PRICE, 2).Replace(",", "")
                    End If
                Next
                Return dt
            End If
        Else
            Dim ws As New MYSAPDAL
            Dim pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, errMsg As String = ""
            For Each r As DataRow In dt.Rows
                'for CN Block MEDC product to show price
                If Not (Session("org_id").ToString.ToUpper.StartsWith("CN") AndAlso SAPDAL.CommonLogic.isMEDC(r.Item("part_no")) AndAlso Not Util.IsInternalUser2()) Then
                    pin.AddProductInRow(r.Item("part_no"), 1)
                End If
            Next
            If ws.GetPrice(Session("company_id"), Session("company_id"), Session("org_id"), pin, pout, errMsg) Then
                For Each r As DataRow In dt.Rows
                    Dim rs() As SAPDALDS.ProductOutRow = pout.Select("part_no='" + r.Item("part_no") + "'")
                    If rs.Length > 0 AndAlso Decimal.TryParse(rs(0).UNIT_PRICE, 0) AndAlso Decimal.TryParse(rs(0).LIST_PRICE, 0) Then
                        r.Item("unitprice") = FormatNumber(rs(0).UNIT_PRICE, 2).Replace(",", "")
                        r.Item("listprice") = FormatNumber(rs(0).LIST_PRICE, 2).Replace(",", "")
                    End If
                Next
                Return dt
            End If
            Return dt
        End If

        Return Nothing
    End Function

    Protected Function getATPdetail(ByVal pn As String) As DataTable
        Dim dt As New DataTable
        dt.Columns.Add("date") : dt.Columns.Add("qty")
        Try
            Dim stoc As String = ""
            Dim _PlantID = Me.drpPlant.SelectedValue
            If _PlantID = "CNH1-BJ" Then
                _PlantID = "CNH1"
                stoc = "2000"
            End If
            Dim dttemp As New DataTable
            SAPtools.getInventoryAndATPTable(pn, _PlantID, 0, "", 0, dttemp, "", 1, 0, stoc)
            If dttemp.Rows.Count > 0 Then
                For i As Integer = 0 To dttemp.Rows.Count - 1
                    If Decimal.TryParse(dttemp.Rows(i).Item("com_qty"), 0) = True AndAlso CInt(dttemp.Rows(i).Item("com_qty")) <> 0 Then
                        Dim r As DataRow = dt.NewRow
                        r.Item("date") = dttemp.Rows(i).Item("com_date") : r.Item("qty") = CInt(dttemp.Rows(i).Item("com_qty")) : dt.Rows.Add(r)
                    End If
                Next
            End If
            If dt.Rows.Count = 0 Then
                Dim r As DataRow = dt.NewRow
                r.Item("date") = Now.ToString("yyyyMMdd") : r.Item("qty") = 0 : dt.Rows.Add(r)
            End If
            For Each r As DataRow In dt.Rows
                r.Item("date") = Date.ParseExact(r.Item("date"), "yyyyMMdd", New System.Globalization.CultureInfo("en-US")).ToString("yyyy/MM/dd")
            Next
            Return dt
        Catch ex As Exception

        End Try

        Return Nothing
    End Function

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim GV As GridView = e.Row.FindControl("gv2")
            'Frank 20120511            
            'Calling SAPDALDS.QueryInventory to get product inventory information
            'GV.DataSource = getATPdetail(CType(e.Row.Cells(1).Controls(0), HyperLink).Text)

            Dim _partno As String = CType(e.Row.Cells(1).Controls(0), HyperLink).Text
            Dim _mysapdal As SAPDAL.SAPDAL = New SAPDAL.SAPDAL
            Dim pin As New SAPDAL.SAPDALDS.ProductInDataTable
            Dim _PlantID As String = String.Empty
            Dim lbPlant As Label = CType(e.Row.Cells(4).FindControl("lb_Plant"), Label)

            'Frank 2012/05/16
            'Get parameter Plant from UI Me.drpPlant.SelectedValue
            'JJ 2014/2/7
            'TW開頭的Plant會隱藏，就到SAP_PRODUCT_ORG用Part no抓出其plant



            If tr_Plant.Visible Then
                _PlantID = Me.drpPlant.SelectedValue
            Else
                Dim sql As String = String.Format("select DELIVERYPLANT from SAP_PRODUCT_ORG where ORG_ID='TW01' and PART_NO = '{0}'", _partno)
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", sql)
                If obj IsNot Nothing Then
                    _PlantID = obj.ToString()
                End If
            End If

            lbPlant.Text = _PlantID

            Dim stoc As String = ""
            If _PlantID = "CNH1-BJ" Then
                _PlantID = "CNH1"
                stoc = "2000"
            End If
            pin.AddProductInRow(_partno, 0, _PlantID)

            Dim _dtInventory As SAPDAL.SAPDALDS.QueryInventory_OutputDataTable = Nothing
            Dim _errormsg As String = String.Empty

            'Dim _querystatus As Boolean = _mysapdal.QueryInventory(pin, "twh1", _dtInventory, _errormsg)

            Dim _querystatus As Boolean = _mysapdal.QueryInventory_V3(pin, _PlantID, Now, _dtInventory, stoc, _errormsg) ' QueryInventory(pin, _PlantID, _dtInventory, _errormsg)

            GV.DataSource = _dtInventory

            GV.DataBind()


            'Ryan 20160711 Hide extra ACL inventory table if is not US01
            If Session("Org_id").ToString = "US01" Then
                e.Row.FindControl("ACLInventory").Visible = True
            Else
                e.Row.FindControl("ACLInventory").Visible = False
            End If

            'Ryan 20160711 Show ACL inventory for US01
            Dim pin2 As New SAPDAL.SAPDALDS.ProductInDataTable
            Dim _dtInventory2 As SAPDAL.SAPDALDS.QueryInventory_OutputDataTable = Nothing
            pin2.AddProductInRow(_partno, 0, "TWH1")
            _querystatus = _mysapdal.QueryInventory_V3(pin2, "TWH1", Now, _dtInventory2, "", _errormsg) ' QueryInventory(pin, _PlantID, _dtInventory, _errormsg)
            Dim GV3 As GridView = e.Row.FindControl("gv3")
            GV3.DataSource = _dtInventory2
            GV3.DataBind()


            'Frank 2012/10/12:Showing up the minimum order quantity if min_order_qty is greater than 0.
            Dim _sap_prod_statusTA As New SAPDSTableAdapters.SAP_PRODUCT_STATUSTableAdapter, _sap_prod_ststusDT As SAPDS.SAP_PRODUCT_STATUSDataTable
            _sap_prod_ststusDT = _sap_prod_statusTA.GetData(_partno, Session("org_id"))
            Dim _LabelMOQ As Label = CType(e.Row.FindControl("LabelMOQ"), Label)
            If _sap_prod_ststusDT.Rows.Count > 0 AndAlso CType(_sap_prod_ststusDT.Rows(0), SAPDS.SAP_PRODUCT_STATUSRow).MIN_ORDER_QTY > 0 Then
                e.Row.FindControl("divMOQ").Visible = True
                _LabelMOQ.Text = "Minimum Order Quantity：" & CInt(CType(_sap_prod_ststusDT.Rows(0), SAPDS.SAP_PRODUCT_STATUSRow).MIN_ORDER_QTY).ToString
            Else
                e.Row.FindControl("divMOQ").Visible = False
            End If

            Dim hdRowGipEmail As String = CType(e.Row.FindControl("hd_RowGipEmail"), HiddenField).Value, hyGipEmail As HyperLink = CType(e.Row.FindControl("hyEmailGip"), HyperLink)
            Dim hyFamilyProduct As HyperLink = CType(e.Row.FindControl("hyFamilyProduct"), HyperLink)
            If Session("account_status") = "EZ" Then
                If String.IsNullOrEmpty(hdRowGipEmail) Then
                    hyGipEmail.Visible = False
                Else
                    hyGipEmail.NavigateUrl = "mailto:" + hdRowGipEmail + "&Subject=Inventory of " + _partno
                End If
                'Frank                
                hyFamilyProduct.NavigateUrl = "ProductATPInfo.aspx?Part_Number=" & _partno & "&QUANTITY=0&SALES_ORG=" & Session("org_id")
            ElseIf Session("ORG_ID").ToString.ToUpper.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
                'ICC 2014/10/14 Show Check Family Product link for EU CP & KA users
                If Session("account_status") = "CP" OrElse Session("account_status") = "KA" Then
                    hyFamilyProduct.NavigateUrl = "ProductATPInfo.aspx?Part_Number=" & _partno & "&QUANTITY=0&SALES_ORG=" & Session("org_id")
                Else
                    hyFamilyProduct.Visible = False
                End If
                hyGipEmail.Visible = False
            Else
                hyGipEmail.Visible = False
                hyFamilyProduct.Visible = False
            End If
            'Only EZ and CP and KA can see ABCD indicator
            If Session("account_status") = "GA" Then
                Dim TrInventory As HtmlTableRow = CType(e.Row.FindControl("TrInventory"), HtmlTableRow)
                TrInventory.Visible = False
            End If
            'gv1.Columns(5).Visible = False
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            Dim upm As AuthUtil.UserPermission = AuthUtil.GetPermissionByUser()
            Dim ColIndex As Integer = GetColumnIdx(gv1, "List Price")
            e.Row.Cells(ColIndex).Visible = upm.CanSeeListPrice
            e.Row.Cells(ColIndex + 1).Visible = upm.CanSeeUnitPrice
            e.Row.Cells(ColIndex + 2).Visible = upm.CanPlaceOrder
        End If

        'Ryan 20160215 if is premier customer thne set column 678 invisible
        If isPremierCustomer Then
            e.Row.Cells(6).Visible = False
            e.Row.Cells(7).Visible = False
            e.Row.Cells(8).Visible = False
        End If

        'Frank 20160421 Cannot add any items to BTOS cart
        If Session("CART_ID") IsNot Nothing AndAlso
            (
            MyCartX.IsEUBtosCart(Session("CART_ID")) OrElse
            (Session("ORG_ID").ToString.StartsWith("CN") AndAlso MyCartX.IsHaveBtos(Session("CART_ID")))
            ) Then
            e.Row.Cells(8).Visible = False
        End If

    End Sub
    Protected Function GetColumnIdx(ByVal Gv As GridView, ByVal Hname As String) As Integer
        Dim result As Integer = -1
        For i As Integer = 0 To Gv.Columns.Count - 1
            If String.Equals(Gv.Columns(i).HeaderText.Trim, Hname.Trim) Then
                result = i
                Exit For
            End If
        Next
        Return result
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write(Session("company_id")) : Response.End()
        If Request.IsAuthenticated AndAlso Session("account_status").ToString() = "GA" Then
            Response.Redirect(String.Format("http://buy.advantech.com/sso.aspx?tempid={0}&pass=estore&id={1}", Session("TempId"), Session("user_id")))
        End If

        'Ryan 20160215 Check if is premier customer
        'ICC 20160223 Only Inventory has to hide price column
        If Not String.IsNullOrEmpty(Request("Status")) AndAlso (Request("Status").ToString().Trim().Equals("Inventory", StringComparison.OrdinalIgnoreCase)) Then
            isPremierCustomer = True
        End If

        'Ryan 20160829 Get ship-to country code for North America 3S Patent Litigation issue
        DefaultShipto = Advantech.Myadvantech.Business.UserRoleBusinessLogic.MYAgetShiptoIDBySoldtoID(Session("company_id").ToString(), Session("Cart_id").ToString)
        CountryCode = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getCountryCodeByERPID(DefaultShipto)


        If Not Page.IsPostBack Then

            Me.txtPN.Attributes("autocomplete") = "off"
            If Not IsNothing(Request("PN")) AndAlso Request("PN").Trim <> "" Then
                Me.txtPN.Text = Request("PN").Trim
                Dim dt As DataTable = getProductTable(Me.txtPN.Text.Trim.Replace("'", "''"))
                Me.gv1.DataSource = dt : Me.gv1.DataBind() : Me.upContent.Update()
            End If

            'ICC 2015/10/26 For Arrow customers. They don't want to see price and inventory in same function.
            ltMessage.Text = "Search by partial part numbers to compare price and availability <br />for multiple products in the same family."
            'Arrow
            If Not String.IsNullOrEmpty(Request("Status")) Then
                Dim status As String = Request("Status").ToString().Trim()
                Select Case status
                    Case "Price"
                        lbRoot.Text = "> Check Price"
                        lbTitle.Text = "Check Price"
                        btnQuery.Text = "Check Price"
                        ltMessage.Text = "Search by partial part numbers to compare price <br />for multiple products in the same family."
                    Case "Inventory"
                        lbRoot.Text = "> Check Availability"
                        lbTitle.Text = "Check Availability"
                        btnQuery.Text = "Check Availability"
                        ltMessage.Text = "Search by partial part numbers to compare availability <br />for multiple products in the same family."
                    Case Else
                        lbmsg.Text = "> Check Price & Availability"
                        lbTitle.Text = "Check Price & Availability"
                        btnQuery.Text = "Check Price & Availability"
                End Select

            End If
        End If
    End Sub

    Protected Sub imgXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = getProductTable(Me.txtPN.Text.Trim.Replace("'", "''"))
        If dt IsNot Nothing Then
            Util.DataTable2ExcelDownload(dt, "PriceATP.xls")
        End If
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub gvBtnAdd2Cart_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim obj As ImageButton = CType(sender, ImageButton), Part_no As String = obj.CommandName, mycart As New CartList("b2b", "cart_detail_v2")

        lbmsg.Text = String.Empty
        Dim refmsg As String = String.Empty
        If Advantech.Myadvantech.Business.PartBusinessLogic.IsInvalidParts(Session("company_id").ToString(), Session("org_id").ToString, Part_no,
                 Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString), CountryCode, Util.IsInternalUser(Session("user_id")), refmsg) Then
            lbmsg.Text = refmsg
            UpdatePanel1.Update()
            Exit Sub
        End If

        'Ryan 20180309 Disable original TW01 rule, new function isTW01BTOSInvalidParts is applied
        If MyCartOrderBizDAL.isTW01BTOSInvalidParts(Part_no, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString)) Then
            If Util.IsInternalUser2 Then
                lbmsg.Text = "Only A/B/C+ parts are allowed to be added to a configuration, please check again."
            Else
                lbmsg.Text = "This part is not allowed to be added to a configuration manually, please contact your sales representative for more information."
            End If
            UpdatePanel1.Update()
            Exit Sub
        End If
        'If Session("org_id").ToString.Equals("TW01") AndAlso
        '    Not (Session("company_id").ToString().Equals("ADVAJP", StringComparison.OrdinalIgnoreCase) OrElse Session("company_id").ToString().Equals("ADVAMY", StringComparison.OrdinalIgnoreCase)) Then
        '    If Not (Part_no.StartsWith("X", StringComparison.InvariantCultureIgnoreCase) Or Part_no.StartsWith("Y", StringComparison.InvariantCultureIgnoreCase) _
        '            Or Part_no.StartsWith("17", StringComparison.InvariantCultureIgnoreCase)) Then
        '        lbmsg.Text = "Only X/Y parts and cables/wires which part number start with '17' can be added to a configuration manually."
        '        UpdatePanel1.Update()
        '        Exit Sub
        '    End If
        'End If



        Dim CartId As String = Session("Cart_id"), Cate As String = "", otype As Integer = 0
        Dim ReqDate As DateTime = SAPDOC.GetLocalTime(Session("org_id").ToString.Substring(0, 2))
        ReqDate = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, ReqDate), Session("org_id"))
        Dim higherLevel As Integer = 0
        If mycart.isBtoOrder(CartId) = 1 Then
            otype = 1 : Cate = "OTHERS"
            Dim Parents As List(Of CartItem) = MyCartX.GetBtosParentItems(CartId)
            If Parents.Count > 0 Then higherLevel = Parents.Max(Function(p) p.Line_No)
        End If
        Dim msg As String = ""
        If MyCartOrderBizDAL.Add2Cart_BIZ(CartId, Part_no, 1, 0, otype, Cate, 1, 1, ReqDate, "", "", higherLevel, False, msg) <> 0 Then
            Response.Redirect("~/Order/Cart_listV2.aspx")
        Else
            lbmsg.Text = msg
            UpdatePanel1.Update()
        End If
    End Sub


    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lbmsg.Text = String.Empty

        Dim dt As DataTable = getProductTable(Me.txtPN.Text.Trim.Replace("'", "''"))
        Me.gv1.DataSource = dt : Me.gv1.DataBind() : Me.upContent.Update()
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Session("company_id") Is Nothing OrElse Session("Org_id") Is Nothing Then
                Session.Abandon() : FormsAuthentication.SignOut() : Response.Redirect("~/home.aspx")
            End If
            getPlantListByOrg()
        End If
    End Sub

    Sub getPlantListByOrg()
        Dim PLANT As String = ""
        If Session("Org_id") = "SG01" Then
            PLANT = "SGH1" : Me.drpPlant.Items.Add(PLANT) : PLANT = "TWH1" : Me.drpPlant.Items.Add(PLANT)
        ElseIf Session("Org_id") = "EU10" Or Session("company_id").ToString.StartsWith("E", StringComparison.OrdinalIgnoreCase) Then
            PLANT = "EUH1" : Me.drpPlant.Items.Add(PLANT) : PLANT = "TWH1" : Me.drpPlant.Items.Add(PLANT)
            If Session("Org_id") = "TW01" Then
                Me.drpPlant.SelectedValue = "TWH1"
            End If
        ElseIf Session("Org_id") = "MX01" Then 'Per Sabrina's request show TWH1 as the only plant, to avoid confusion
            Me.drpPlant.Items.Add("TWH1")
        ElseIf Session("Org_id").ToString.ToUpper.StartsWith("CN") Then
            If Util.IsInternalUser2() Then
                Me.drpPlant.Items.Add("CNH1") : Me.drpPlant.Items.Add("CNH1-BJ") : Me.drpPlant.Items.Add("CNH3") : Me.drpPlant.Items.Add("CKH2") : Me.drpPlant.Items.Add("TWH1") : Me.drpPlant.Items.Add("TWH3") : Me.drpPlant.Items.Add("TWH4")
            Else
                Me.drpPlant.Items.Add("CNH1") : Me.drpPlant.Items.Add("CNH3")
            End If
        Else
            PLANT = OrderUtilities.getPlant() : Me.drpPlant.Items.Add(PLANT)
        End If
        If MailUtil.IsInRole("SCM.AASECO") OrElse MailUtil.IsInRole("SCM.embedded") Then
            Dim dtPlants As DataTable = dbUtil.dbGetDataTable("MY", "select distinct DLV_PLANT from SAP_PRODUCT_STATUS where DLV_PLANT is not null and DLV_PLANT<>'' order by DLV_PLANT ")
            For Each rPlant As DataRow In dtPlants.Rows
                If drpPlant.Items.FindByValue(rPlant.Item("DLV_PLANT")) Is Nothing Then
                    drpPlant.Items.Add(New ListItem(rPlant.Item("DLV_PLANT"), rPlant.Item("DLV_PLANT")))
                End If
            Next
        End If

        'JJ 2014/2/7：只要ORG是TW01就隱藏Plant
        If Session("Org_id") = "TW01" Then
            tr_Plant.Visible = False
        Else
            tr_Plant.Visible = True
        End If

    End Sub


    Public Sub PickProductEnd(ByVal str As Object)
        Me.txtPN.Text = str(0).ToString
        Me.up1.Update()
        Me.ModalPopupExtender1.Hide()
    End Sub

    Protected Sub btnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim partNo As String = Me.txtPN.Text.Trim.Replace("'", "''")
        CType(Me.ascxPickProduct.FindControl("txtName"), TextBox).Text = partNo
        Me.ascxPickProduct.ShowData(partNo, "")
        Me.up2.Update()
        Me.ModalPopupExtender1.Show()
    End Sub
    Protected Function GetCell(ByVal DataItem As Object, ByVal name As String) As String
        Dim Value As Object = DataBinder.Eval(DataItem, name)
        Select Case name
            Case "part_no"
                'Ming add qty per box info
                If Not String.IsNullOrEmpty(Value) Then
                    Dim sql As String = String.Format("select top 1 MIN_LOT_SIZE from sap_product_abc where PART_NO='{0}' and PLANT='{1}'", Value, Me.drpPlant.SelectedValue)
                    Dim obj As Object = dbUtil.dbExecuteScalar("MY", sql)
                    If obj IsNot Nothing Then
                        Return obj.ToString()
                    End If
                End If
                'end
        End Select
        Return ""
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        <%--ICC Use a label to control it's text--%>
        <asp:Label runat="server" ID="lbRoot" Text="> Check Price & Availability"></asp:Label>
    </div>
    <br />
    <div class="menu_title">
        <%--ICC Use a label to control it's text--%>
        <asp:Label runat="server" ID="lbTitle" Text="Check Price & Availability"></asp:Label>
    </div>
    <br />
    <asp:Panel DefaultButton="btnQuery" runat="server" ID="pldd">
        <table style="margin: 10px">
            <tr valign="top">
                <td>
                    <b>Part No:</b>
                </td>
                <td>
                    <table>
                        <tr valign="top">
                            <td>
                                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                    <ContentTemplate>
                                        <ajaxToolkit:AutoCompleteExtender ID="ajacAce" runat="server" TargetControlID="txtPN"
                                            ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetSAPPN" MinimumPrefixLength="1" />
                                        <asp:TextBox runat="server" ID="txtPN" Width="250px" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnPick" Text="Pick Product" OnClick="btnPick_Click" />
                                <asp:Button runat="server" ID="btnQuery" Text="Query price & Availability" OnClientClick="onProgress(1)"
                                    OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr id="tr_Plant" runat="server">
                <td>
                    <b>Plant:</b>
                </td>
                <td>
                    <table>
                        <tr valign="top">
                            <td>
                                <asp:DropDownList ID="drpPlant" runat="server" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td></td>
                <td style="color: Tomato; font-size: small;" colspan="2">
                    <%--ICC 2015/10/26 Add a literal to control it's text--%>
                    <asp:Literal runat="server" ID="ltMessage"></asp:Literal>
                </td>
            </tr>
        </table>
    </asp:Panel>
    <br />
    <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Conditional" ChildrenAsTriggers="false">
        <ContentTemplate>
            <asp:Label runat="server" ID="lbmsg" Font-Bold="true" ForeColor="red"></asp:Label>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:UpdatePanel runat="server" ID="upContent" UpdateMode="Conditional" ChildrenAsTriggers="false">
        <ContentTemplate>
            <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download"
                OnClick="imgXls_Click" />
            <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" Width="100%"
                EmptyDataText="No search results were found." EmptyDataRowStyle-Font-Size="Larger"
                EmptyDataRowStyle-Font-Bold="true" AllowPaging="false" OnRowDataBound="gv1_RowDataBound">
                <Columns>
                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            No.
                        </HeaderTemplate>
                        <ItemTemplate>
                            <%# Container.DataItemIndex + 1 %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:HyperLinkField HeaderText="Part No." Target="_blank" DataNavigateUrlFields="model_no"
                        DataNavigateUrlFormatString="~/product/model_detail.aspx?model_no={0}" DataTextField="part_no"
                        SortExpression="part_no" />
                    <asp:HyperLinkField HeaderText="Model No." Target="_blank" DataTextField="model_no"
                        DataNavigateUrlFields="model_no" DataNavigateUrlFormatString="~/product/model_detail.aspx?model_no={0}" />
                    <asp:BoundField HeaderText="Product Description" DataField="product_desc" ItemStyle-Width="200px" />
                    <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="200px">
                        <HeaderTemplate>
                            Qty.
                        </HeaderTemplate>
                        <ItemTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <div runat="server" id="divMOQ" visible="false">
                                            <strong>
                                                <asp:Label ID="LabelMOQ" runat="server" Text="" /></strong>
                                            <br />
                                        </div>
                                        <asp:HiddenField runat="server" ID="hd_RowGipEmail" Value='<%#Eval("GIP_EMAIL") %>' />
                                        <asp:HyperLink runat="server" ID="hyEmailGip" NavigateUrl="">
                                            Contact SCM
                                            <asp:Image runat="server" ID="imgEmailGip" ImageUrl="~/Images/icon_mail.jpg" AlternateText="contact SCM" />
                                        </asp:HyperLink>
                                        <br />
                                        <asp:HyperLink runat="server" ID="hyFamilyProduct" NavigateUrl="" Target="_blank">
                                            Check Family Product
                                        </asp:HyperLink>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="Label1" runat="server" Text="Plant: "></asp:Label><asp:Label ID="lb_Plant"
                                            runat="server" Text=""></asp:Label>
                                        <asp:GridView runat="server" ID="gv2" AutoGenerateColumns="false" AllowPaging="false"
                                            Width="100%" EmptyDataText="N/A" EmptyDataRowStyle-Font-Size="Larger" EmptyDataRowStyle-Font-Bold="true">
                                            <Columns>
                                                <asp:BoundField HeaderText="Available Date" DataField="STOCK_DATE" DataFormatString="{0:yyyy/MM/dd}"
                                                    ItemStyle-HorizontalAlign="Center" />
                                                <asp:BoundField HeaderText="Qty." DataField="STOCK" ItemStyle-HorizontalAlign="Center" />
                                            </Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                                <tr id="ACLInventory" runat="server">
                                    <td>
                                        <asp:Label ID="Label2" runat="server" Text="Plant: "></asp:Label><asp:Label ID="lb_Plant2"
                                            runat="server" Text="TWH1"></asp:Label>
                                        <asp:GridView runat="server" ID="gv3" AutoGenerateColumns="false" AllowPaging="false"
                                            Width="100%" EmptyDataText="N/A" EmptyDataRowStyle-Font-Size="Larger" EmptyDataRowStyle-Font-Bold="true">
                                            <Columns>
                                                <asp:BoundField HeaderText="Available Date" DataField="STOCK_DATE" DataFormatString="{0:yyyy/MM/dd}"
                                                    ItemStyle-HorizontalAlign="Center" />
                                                <asp:BoundField HeaderText="Qty." DataField="STOCK" ItemStyle-HorizontalAlign="Center" />
                                            </Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                            </table>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <%--                    <asp:BoundField HeaderText="Product Group" DataField="product_group" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField HeaderText="Product Line" DataField="product_line" ItemStyle-HorizontalAlign="Center" />
                    <asp:BoundField HeaderText="Inventory Level" DataField="ABC_INDICATOR" ItemStyle-HorizontalAlign="Center" />--%>
                    <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderText="Other information"
                        HeaderStyle-Width="140px">
                        <ItemTemplate>
                            <table>
                                <tr>
                                    <tr>
                                        <td align="right">
                                            <strong>Status:</strong>
                                        </td>
                                        <td style="white-space: nowrap">
                                            <%# Eval("PROD_STATUS")%>
                                            (<%# Eval("STATUS_DESC")%>)
                                        </td>
                                    </tr>
                                    <td align="right">
                                        <strong>Product Group:</strong>
                                    </td>
                                    <td>
                                        <%#Eval("product_group")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <strong>Product Line:</strong>
                                    </td>
                                    <td>
                                        <%#Eval("product_line")%>
                                    </td>
                                </tr>
                                <tr runat="server" id="TrInventory">
                                    <td align="right">
                                        <strong>Inventory Level:</strong>
                                    </td>
                                    <td>
                                        <%#Eval("ABC_INDICATOR")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <strong>Qty Per Box Info:</strong>
                                    </td>
                                    <td>
                                        <%# GetCell(Container.DataItem, "part_no")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <strong>Gross Weight:</strong>
                                    </td>
                                    <td>
                                        <%# Eval("Gross_weight")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <strong>Net Weight:</strong>
                                    </td>
                                    <td>
                                        <%# Eval("Net_weight")%>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        <strong>Dimensions:</strong>
                                    </td>
                                    <td>
                                        <%# Eval("Size_Dimensions")%>
                                    </td>
                                </tr>
                            </table>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="List Price" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <%#IIf(Eval("listPrice") = 0, "TBD", Session("company_Currency_sign").ToString() + Eval("listPrice").ToString())%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Unit Price" ItemStyle-HorizontalAlign="Right">
                        <ItemTemplate>
                            <%#IIf(Eval("UnitPrice") = 0, "TBD", Session("company_Currency_sign").ToString() + Eval("UnitPrice").ToString())%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            Add2Cart
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:ImageButton ImageUrl="~/Images/add2cart_2.gif" runat="server" ID="gvBtnAdd2Cart"
                                CommandName='<%#Bind("part_no")%>' OnClick="gvBtnAdd2Cart_Click" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify" />
                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                <%--      <FixRowColumn FixColumns="-1" FixRowType="Header"  TableWidth="890px"  />--%>
            </sgv:SmartGridView>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />
            <asp:PostBackTrigger ControlID="imgXls" />
        </Triggers>
    </asp:UpdatePanel>
    <!--ASCX-->
    <asp:LinkButton runat="server" ID="link1" />
    <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1"
        PopupControlID="Panel1" PopupDragHandleControlID="Panel1" TargetControlID="link1"
        BackgroundCssClass="modalBackground" CancelControlID="CancelButtonProduct" />
    <asp:Panel runat="server" ID="Panel1">
        <div style="text-align: right;">
            <asp:ImageButton ID="CancelButtonProduct" runat="server" ImageUrl="~/Images/del.gif" />
        </div>
        <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
            <ContentTemplate>
                <myASCX:PickProduct ID="ascxPickProduct" runat="server" />
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnPick" EventName="Click" />
            </Triggers>
        </asp:UpdatePanel>
    </asp:Panel>
    <!--/ASCX-->
    <script type="text/javascript">
        function onProgress(f) {
            if (f == 1) {
                var obj = document.getElementById("<%=Me.upContent.ClientID %>");
                obj.innerHTML = '<img src="/Images/loading2.gif">';
            }
            else {
                var obj = f.parentNode
                obj.innerHTML = '<img src="/Images/loading2.gif">';
            }
        }

        //為解決在IE10中點擊updatepanel裡面的imagebutton時出現的錯誤
        Sys.WebForms.PageRequestManager.getInstance()._origOnFormActiveElement = Sys.WebForms.PageRequestManager.getInstance()._onFormElementActive;
        Sys.WebForms.PageRequestManager.getInstance()._onFormElementActive = function (element, offsetX, offsetY) {
            if (element.tagName.toUpperCase() === 'INPUT' && element.type === 'image') {
                offsetX = Math.floor(offsetX);
                offsetY = Math.floor(offsetY);
            }
            this._origOnFormActiveElement(element, offsetX, offsetY);
        };
    </script>
</asp:Content>