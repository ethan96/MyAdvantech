<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- Order Tracking" %>
<%@ Register TagPrefix="NaviOrderTracking" TagName="Inc" Src="~/Includes/OrderTrackingNavi_Inc.ascx" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>

<script runat="server">
    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") = Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property

    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") = Nothing, String.Empty, ViewState("SortExpression"))
        End Get
        Set(ByVal value As String)
            ViewState("SortExpression") = value
        End Set
    End Property

    Private Function GetSortDirection() As String
        Select Case GridViewSortDirection
            Case "ASC"
                GridViewSortDirection = "DESC"
            Case "DESC"
                GridViewSortDirection = "ASC"
        End Select
        Return GridViewSortDirection
    End Function

    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("so_no") <> "" Then txtso_no.Text = Request("so_no")
            If Request("po_no") <> "" Then txtpo_no.Text = Request("po_no")
            initSearch() : gv1.DataSource = ViewState("SqlCommand") : gv1.DataBind()
        End If
    End Sub

    Private Sub initSearch()
        If ViewState("SqlCommand") Is Nothing Then
            ViewState("SqlCommand") = New DataTable
        Else
            CType(ViewState("SqlCommand"), DataTable).Clear()
        End If
        If Trim(txtso_no.Text.Replace("'", "")) <> "" Or Trim(txtpo_no.Text.Replace("'", "")) <> "" Then
            'Dim t1 As New Threading.Thread(AddressOf GetOrder) ', t2 As New Threading.Thread(AddressOf GetBackOrderC)
            't1.Start() ': t2.Start()
            't1.Join() ': t2.Join()
            GetOrder()
            If CType(ViewState("SqlCommand"), DataTable).Rows.Count > 0 Then CType(ViewState("SqlCommand"), DataTable).DefaultView.Sort = "LINE_NO asc, DUE_DATE2 desc"
            ViewState("SqlCommand") = CType(ViewState("SqlCommand"), DataTable).DefaultView.ToTable()
        End If
    End Sub

    Private Sub GetOrder()
        Try
            Dim strCompanyId As String, strOrgId As String
            strCompanyId = UCase(Session("COMPANY_ID")) : strOrgId = UCase(Session("org_id"))
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS LINE_NO, ")
                .AppendFormat(" VBAP.MATNR AS PART_NO, VBAP.KWMENG AS ORDER_QTY, ")
                .AppendFormat(" VBAP.NETPR AS UNIT_PRICE, VBUP.LFSTA AS Status, ")
                .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, ")
                .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
                .AppendFormat(" VBEP.EDATU AS DUE_DATE2, VBAP.ZZ_GUARA AS ExWarranty, '' as SERIAL_NO, ")
                .AppendFormat(" nvl((select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1),0) as SchedLineShipedQty, ")
                .AppendFormat(" nvl((select VBRP.VBELN from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),'') as INVOICE_INFO1, ")
                .AppendFormat(" nvl((select VBRK.FKDAT from SAPRDP.VBRK INNER JOIN SAPRDP.VBRP on VBRK.VBELN=VBRP.VBELN WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRK.MANDT='168'),'9999-12-31') as INVOICE_INFO2, ")
                .AppendFormat(" nvl((select VBRP.FKIMG from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),0) as INVOICE_INFO3, ")
                .AppendFormat(" nvl((select SUM(LFIMG) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR),0) as DLV_QTY, ")
                .AppendFormat(" (SELECT VTEXT FROM SAPRDP.TVLST where SPRAS='E' AND LIFSP=vbak.LIFSK and ROWNUM=1) as DELBLOCK ")
                .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
                .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
                .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
                .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') ")
                .AppendFormat(" AND (VBAK.VKORG like '{0}%') ", Left(strOrgId, 2))
                If strCompanyId <> "EKGBEC01" Then
                    .AppendFormat(" AND (VBAK.KUNNR = '{0}') ", strCompanyId)
                Else
                    If LCase(Session("user_id")) = "freya.huggard@ecauk.com" Then
                        .AppendFormat(" AND (VBAK.KUNNR in ('EKGBEC01','EKGBEC02','EKGBEC03','EKGBEC04')) ")
                    Else
                        .AppendFormat(" AND (VBAK.KUNNR = '{0}') ", strCompanyId)
                    End If
                End If
                .AppendFormat(" AND VBAP.MATNR not like 'AGS-EW-%' ")
                If Trim(txtSO_NO.Text.Replace("'", "")) <> "" Then .AppendFormat(" AND VBAK.VBELN = '{0}' ", Global_Inc.Format2SAPItem2(Trim(txtSO_NO.Text.Replace("'", "").ToUpper())))
                If Trim(txtPO_NO.Text.Replace("'", "")) <> "" Then .AppendFormat(" AND VBAK.BSTNK = '{0}' ", Trim(txtPO_NO.Text.Replace("'", "").ToUpper()))
                .AppendFormat(" and VBAP.ABGRU = ' ' ")
                .AppendFormat(" and rownum <100 ORDER BY LINE_NO asc, DUE_DATE2 desc")
            End With
            'If Session("user_id") = "rudy.wang@advantech.com.tw" Then Util.SendTestEmail("sql", sb.ToString)
            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
            'Nada 20140124 remove first sch line
            If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
                Dim isnextfirstline As Boolean = True
                Dim iscurrentfirstline As Boolean = False
                Dim ishassucc As Boolean = False
                Dim iszeroq As Boolean = False
                For i As Integer = dt.Rows.Count - 1 To 1 Step -1
                    iscurrentfirstline = isnextfirstline
                    If dt.Rows(i).Item("SchdLineOpenQty") = 0 Then
                        iszeroq = True
                    Else
                        iszeroq = False
                    End If
                    If dt.Rows(i - 1).Item("OrderNo") = dt.Rows(i).Item("OrderNo") AndAlso dt.Rows(i - 1).Item("LINE_NO") = dt.Rows(i).Item("LINE_NO") Then
                        ishassucc = True
                    Else
                        ishassucc = False
                        isnextfirstline = True
                    End If
                    If (Not iscurrentfirstline AndAlso iszeroq) OrElse (iscurrentfirstline AndAlso iszeroq AndAlso ishassucc) Then
                        dt.Rows.Remove(dt.Rows(i))
                    End If
                Next

                'Ryan 20171020 Add currency mark up settings
                Dim objCurrencyMarkUp As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("SELECT CURRDEC FROM SAPRDP.TCURX WHERE CURRKEY = '{0}'", dt.Rows(0).Item("CURRENCY")))
                Dim CurrencyMarkUp As Decimal = 1
                If objCurrencyMarkUp IsNot Nothing AndAlso Int32.TryParse(objCurrencyMarkUp.ToString(), 0) Then
                    CurrencyMarkUp = Convert.ToInt32(100 * Math.Pow(10, objCurrencyMarkUp.ToString()))
                    For Each d As DataRow In dt.Rows
                        d.Item("UNIT_PRICE") = Convert.ToDecimal(d.Item("UNIT_PRICE")) * CurrencyMarkUp
                    Next
                End If

            End If
            dt.AcceptChanges()
            '/Nada 20140124
            'Dim BRs() As DataRow = dt.Select("Status='B'", "OrderNo ASC, LINE_NO ASC, DUE_DATE2 ASC")

            'If BRs.Length > 0 Then
            '    Dim curSO As String = "", curLine As String = "", curQty As Decimal = 0
            '    For Each sch As DataRow In BRs
            '        If sch.Item("LINE_NO").ToString() <> curLine Then
            '            curLine = sch.Item("LINE_NO")
            '            curQty = DirectCast(sch.Item("DLV_QTY"), Decimal)
            '        End If
            '        If CDbl(sch.Item("SchdLineOpenQty")) > curQty Then
            '            sch.Item("SchdLineOpenQty") = sch.Item("SchdLineOpenQty") - curQty
            '            curQty = 0
            '        Else
            '            curQty = curQty - CDbl(sch.Item("SchdLineOpenQty"))
            '            sch.Delete()
            '        End If
            '    Next
            'End If
            'dt.AcceptChanges()

            'BRs = dt.Select("Status='A' and SchedLineShipedQty=0 and SchdLineOpenQty=0")
            ''If Session("user_id") = "rudy.wang@advantech.com.tw" Then Response.Write(sb.ToString)
            'For Each sch As DataRow In BRs
            '    If dt.Select(String.Format("LINE_NO={0} and OrderNo='{1}' and SchdLineNo>1", sch.Item("LINE_NO"), sch.Item("OrderNo"))).Length > 0 Then
            '        sch.Delete()
            '    End If
            'Next
            'dt.AcceptChanges()

            'Dim part_no As String = ""
            'For Each row As DataRow In dt.Rows
            '    If row.Item("PART_NO") <> part_no Then
            '        part_no = row.Item("PART_NO")
            '    Else
            '        row.Delete()
            '    End If
            'Next
            'dt.AcceptChanges()
            CType(ViewState("SqlCommand"), DataTable).Merge(dt)
        Catch ex As Exception
            Response.Write(ex.ToString())
        End Try
    End Sub

    Private Sub GetBackOrderC()
        Try
            Dim strCompanyId As String, strOrgId As String
            strCompanyId = UCase(Session("COMPANY_ID")) : strOrgId = UCase(Session("org_id"))
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS LINE_NO, ")
                .AppendFormat(" VBAP.MATNR AS PART_NO, VBAP.KWMENG AS ORDER_QTY, ")
                .AppendFormat(" VBAP.NETPR AS UNIT_PRICE, VBUP.LFSTA AS Status, ")
                .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, ")
                .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
                .AppendFormat(" VBEP.EDATU AS DUE_DATE2, VBAP.ZZ_GUARA AS ExWarranty, '' as SERIAL_NO, ")
                .AppendFormat(" nvl((select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1),0) as SchedLineShipedQty, ")
                .AppendFormat(" nvl((select VBRP.VBELN from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),'') as INVOICE_INFO1, ")
                .AppendFormat(" nvl((select VBRK.FKDAT from SAPRDP.VBRK INNER JOIN SAPRDP.VBRP on VBRK.VBELN=VBRP.VBELN WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRK.MANDT='168'),'9999-12-31') as INVOICE_INFO2, ")
                .AppendFormat(" nvl((select VBRP.FKIMG from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),0) as INVOICE_INFO3, ")
                .AppendFormat(" nvl((select SUM(LFIMG) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR),0) as DLV_QTY ")
                .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
                .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
                .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
                .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND ")
                .AppendFormat(" (VBAK.KUNNR='{0}') AND (VBAK.VKORG like '{1}%') AND VBUP.LFSTA IN ('C') ", strCompanyId, Left(strOrgId, 2))
                .AppendFormat(" AND VBAP.MATNR not like 'AGS-EW-%' ")
                If Trim(txtso_no.Text.Replace("'", "")) <> "" Then .AppendFormat(" AND VBAK.VBELN = '{0}' ", Trim(txtso_no.Text.Replace("'", "")))
                If Trim(txtpo_no.Text.Replace("'", "")) <> "" Then .AppendFormat(" AND VBAK.BSTNK = '{0}' ", Trim(txtpo_no.Text.Replace("'", "")))
                .AppendFormat(" and VBAP.ABGRU = ' ' ")
                .AppendFormat(" ORDER BY LINE_NO asc, DUE_DATE2 desc")
            End With

            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
            'For Each r As DataRow In dt.Rows
            '    If CInt(r.Item("DLV_QTY")) > 0 Then
            '        r.Delete()
            '    End If
            'Next
            'dt.AcceptChanges()
            'If Session("user_id") = "rudy.wang@advantech.com.tw" Then Response.Write(sb.ToString)
            'Dim part_no As String = ""
            'For Each row As DataRow In dt.Rows
            '    If row.Item("PART_NO") <> part_no Then
            '        part_no = row.Item("PART_NO")
            '    Else
            '        row.Delete()
            '    End If
            'Next
            'dt.AcceptChanges()
            CType(ViewState("SqlCommand"), DataTable).Merge(dt)
        Catch ex As Exception
            'Response.Write(ex.ToString())
        End Try

    End Sub

    Protected Sub submit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        CType(ViewState("SqlCommand"), DataTable).Clear()
        Me.initSearch() : gv1.DataSource = ViewState("SqlCommand") : gv1.DataBind()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gv1.Sorting
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gv1.PageIndex
        gv1.DataSource = SortDataTable(ViewState("SqlCommand"), False)
        gv1.DataBind()
        gv1.PageIndex = pageIndex
    End Sub

    'Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs) Handles gv1.PageIndexChanging
    '    gv1.PageIndex = e.NewPageIndex : gv1.DataSource = ViewState("boDt") : gv1.DataBind()
    'End Sub

    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GetSortDirection())
                End If
            End If
            Return dataView
        Else
            Response.Write("no gv source!")
            Return New DataView()
        End If
    End Function
    Dim pdt As New DataTable
    Dim pOrderNo As String = ""
    Dim pdto As New DataTable
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            e.Row.Cells(1).Text = Global_Inc.DeleteZeroOfStr(e.Row.Cells(1).Text)
            Select Case UCase(e.Row.Cells(3).Text)
                Case "US", "USD"
                    e.Row.Cells(4).Text = "$" & FormatNumber(e.Row.Cells(4).Text, 2)
                Case "EUR"
                    e.Row.Cells(4).Text = "&euro;" & FormatNumber(e.Row.Cells(4).Text, 2)
                Case "NT", "NTD", "TWD"
                    e.Row.Cells(4).Text = "NT" & FormatNumber(e.Row.Cells(4).Text, 2)
                Case "GBP"
                    e.Row.Cells(4).Text = "&pound;" & FormatNumber(e.Row.Cells(4).Text, 2)
                Case Else
                    e.Row.Cells(4).Text = "$" & FormatNumber(e.Row.Cells(4).Text, 2)
            End Select
            If Trim(e.Row.Cells(6).Text) = "" Or Trim(e.Row.Cells(6).Text) = "0" Or Trim(e.Row.Cells(6).Text) = "00" Or Trim(e.Row.Cells(6).Text) = "&nbsp;" Then
                e.Row.Cells(6).Text = ""
            Else
                e.Row.Cells(6).Text = e.Row.Cells(6).Text & "&nbsp;M(s)"
            End If
            If pOrderNo <> e.Row.Cells(0).Text Then
                pdto = dbUtil.dbGetDataTable("B2B", String.Format("select isnull(a.due_date,'') as due_date,a.Line_No from order_detail a left join order_master b on a.order_id=b.order_id where b.order_no='{0}'", e.Row.Cells(0).Text))
            End If
            Dim oriDD As String = ""
            If pdto.Rows.Count > 0 Then
                Dim r() As DataRow = pdto.Select("line_no='" & e.Row.Cells(1).Text & "'")
                If r.Count > 0 Then
                    oriDD = Global_Inc.FormatDate(r(0).Item("due_date"))
                End If
                '20170523 TC: If there is no schedule line confirmed in SAP, then just show N/A instead of an estimated due date. This is per AEU Lupe and Louis's request.
                oriDD = "N/A"
            End If
            If oriDD = "" Then oriDD = Global_Inc.FormatDate(e.Row.Cells(7).Text)
            If CInt(e.Row.Cells(8).Text) = 0 Then
                e.Row.Cells(7).Text = oriDD
                'e.Row.Cells(8).Text = e.Row.Cells(5).Text
            Else
                e.Row.Cells(7).Text = Global_Inc.FormatDate(e.Row.Cells(7).Text)
            End If

            If pOrderNo <> e.Row.Cells(0).Text Then
                pdt = dbUtil.dbGetDataTable("MY", String.Format("select isnull(convert(nvarchar,BillingDoc),''),tr_line from eai_sale_fact where order_no='{0}' and Tran_Type='Shipment'", Global_Inc.DeleteZeroOfStr(e.Row.Cells(0).Text)))
            End If
            pOrderNo = e.Row.Cells(0).Text

            e.Row.Cells(12).Text = ""
            If pdt.Select("tr_line='" & e.Row.Cells(1).Text & "'").Count > 0 Then
                If pdt.Rows(0).Item(0).ToString <> "" Then
                    e.Row.Cells(12).Text = "<a href='BO_InvoiceInquiry.aspx?inv_no=" + pdt.Rows(0).Item(0).ToString + "' target='_blank'>Link</a>"
                End If
            End If
            If UCase(e.Row.Cells(13).Text) = "A" Then
                'e.Row.Cells(11).Text = "Not Delivery" : e.Row.Cells(12).Text = ""
            ElseIf UCase(e.Row.Cells(13).Text) = "B" Then
                'e.Row.Cells(11).Text = "Partial Delivery" : e.Row.Cells(12).Text = ""
            Else
                'e.Row.Cells(11).Text = "Complete Delivery"
                'e.Row.Cells(11).Text = "<a href='/Order/BO_InvoiceInquiry.aspx?so_no=" & Global_Inc.DeleteZeroOfStr(txtso_no.Text) & "' target='_blank'>[" & Global_Inc.DeleteZeroOfStr(e.Row.Cells(9).Text) & "] - [" & Global_Inc.FormatDate(e.Row.Cells(10).Text) & "] - [" & e.Row.Cells(11).Text & "]</a>"
                e.Row.Cells(14).Text = "<a href='/Order/BO_SerialInquiry.aspx?Company_id=" & Session("COMPANY_ID") & "&so_no=" & Global_Inc.DeleteZeroOfStr(e.Row.Cells(0).Text) & "' target='_blank'>Link</a>"
            End If
            'Nada20131202 added DN info
            If Session("org_id").ToString.ToUpper.Contains("CN") Then
                If Not IsNothing(Oconn) Then
                    Dim dt As New DataTable
                    Dim da As New Oracle.DataAccess.Client.OracleDataAdapter(String.Format("select VBELN,ERDAT,SUM(RFMNG) as QTY from saprdp.vbfa where vbelv='{0}' and cast(POSNV as integer)='{1}' AND VBTYP_N='J' GROUP BY VBELN,ERDAT " & _
      " ORDER BY VBELN ", e.Row.Cells(0).Text, e.Row.Cells(1).Text), Oconn)
                    da.Fill(dt)
                    Dim GV As GridView = e.Row.FindControl("gv2")
                    GV.DataSource = dt
                    GV.DataBind()
                End If
                If AuthUtil.GetPermissionByUser().CanSeeUnitPrice = False Then
                    e.Row.Cells(4).Visible = False
                End If
            End If
        End If

        If e.Row.RowType = DataControlRowType.DataRow Or e.Row.RowType = DataControlRowType.Header Then
            If Not Session("org_id").ToString.ToUpper.Contains("CN") Then
                e.Row.Cells(9).Visible = False
                e.Row.Cells(15).Visible = False
                If AuthUtil.GetPermissionByUser().CanSeeUnitPrice = False Then
                    e.Row.Cells(4).Visible = False
                End If
            End If
            e.Row.Cells(3).Visible = False : e.Row.Cells(10).Visible = False : e.Row.Cells(11).Visible = False : e.Row.Cells(13).Visible = False
        End If

    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gv1.AllowPaging = False
        gv1.DataSource = ViewState("SqlCommand")
        gv1.DataBind()
        gv1.Export2Excel("Order.xls")
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Session("org_id") = "EU10"
        End If
    End Sub
    Dim Oconn As Oracle.DataAccess.Client.OracleConnection = Nothing
    Protected Sub gv1_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        If IsNothing(Oconn) Then
            Oconn = New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
        End If
    End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(Oconn) Then
            Oconn.Close()
            Oconn = Nothing
        End If
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <asp:Panel ID="Panel_Form" runat="server" DefaultButton="submit">
        <div class="root">
            <asp:HyperLink runat="server" ID="HyperLink1" NavigateUrl="~/home.aspx" Text="Home" />
            > Order Tracking</div>
        <table width="100%">
            <tr>
                <td valign="top">
                    <div class="left" style="width: 170px;">
                        <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="BO_OrderTracking" />
                    </div>
                </td>
                <td valign="top">
                    <div class="right" style="width: 707px;">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td height="10">
                                    &nbsp;
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td height="24" class="h2">
                                    <table border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="12" valign="top">
                                                <img src="../images/point.gif" width="7" height="14" />
                                            </td>
                                            <td>
                                                Order Tracking
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="rightcontant3">
                                        <tr>
                                            <td colspan="3">
                                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="20" colspan="3">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="3%">
                                            </td>
                                            <td valign="top">
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td class="h5" height="30" width="100px">
                                                            SO Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" ServiceMethod="GetSO"
                                                                TargetControlID="txtSO_NO" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtSO_NO" runat="server" Width="86px"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                        </td>
                                                        <td class="h5" height="30" width="100px">
                                                            PO Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace2" ServiceMethod="GetPO"
                                                                TargetControlID="txtPO_NO" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtPO_NO" runat="server" Width="86px"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                        </td>
                                                        <td>
                                                            <asp:ImageButton runat="server" ID="submit" ImageUrl="~/Images/search1.gif" OnClick="submit_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            <td width="3%">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="20" colspan="3">
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <table width="100%">
            <tr>
                <td height="10" colspan="2">
                    <img src="../images/line3.gif" width="889" height="1" />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td colspan="2" style="height: 15px">
                    <table>
                        <tr>
                            <td width="20px">
                                <asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="~/images/excel.gif" OnClick="btnToXls_Click" />
                            </td>
                            <td>
                                <asp:LinkButton runat="server" ID="btnToXls" Text="Export To Excel" Font-Size="12px"
                                    ForeColor="#f29702" Font-Bold="true" OnClick="btnToXls_Click" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="width: 10px">
                </td>
                <td valign="top">
                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowSorting="true"
                                    Width="100%" OnRowDataBound="gv1_RowDataBound" OnDataBinding="gv1_DataBinding" OnDataBound="gv1_DataBound">
                                    <Columns>
                                        <asp:BoundField HeaderText="Order No." DataField="OrderNo" />
                                        <asp:BoundField HeaderText="Line" DataField="LINE_NO" ReadOnly="true" SortExpression="LINE_NO" />
                                        <asp:BoundField HeaderText="Part NO." DataField="PART_NO" ReadOnly="true" SortExpression="PART_NO" />
                                        <asp:BoundField HeaderText="Currency" DataField="CURRENCY" ReadOnly="true" SortExpression="CURRENCY" />
                                        <asp:BoundField HeaderText="Unit Price" DataField="UNIT_PRICE" ReadOnly="true" SortExpression="UNIT_PRICE"
                                            ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Order QTY" DataField="ORDER_QTY" ReadOnly="true" SortExpression="ORDER_QTY"
                                            ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Extended Warranty Months" DataField="ExWarranty" ReadOnly="true"
                                            SortExpression="ExWarranty" ItemStyle-HorizontalAlign="Right" />
                                        <asp:BoundField HeaderText="Due Date" DataField="DUE_DATE2" ReadOnly="true" SortExpression="DUE_DATE2"
                                            ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="Open QTY" DataField="SchdLineOpenQty" ItemStyle-HorizontalAlign="Right" />
                                       <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="200px">
                                        <HeaderTemplate>
                                           DN Info
                                        </HeaderTemplate>
                                        <ItemTemplate>                            
                                             <asp:GridView runat="server" ID="gv2" AutoGenerateColumns="false" AllowPaging="false"
                                                            Width="100%" EmptyDataText="N/A" EmptyDataRowStyle-Font-Size="Larger" EmptyDataRowStyle-Font-Bold="true">
                                                 <Columns>
                                                 <asp:BoundField HeaderText="DN No" DataField="VBELN" ItemStyle-HorizontalAlign="Center" />
                                                 <asp:BoundField HeaderText="DN Date" DataField="ERDAT"
                                                                    ItemStyle-HorizontalAlign="Center" />
                                                 <asp:BoundField HeaderText="Qty" DataField="QTY" ItemStyle-HorizontalAlign="Center" />
                                                 </Columns>
                                             </asp:GridView>
                                        </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="Invoice No." DataField="INVOICE_INFO1" ReadOnly="true" />
                                        <asp:BoundField HeaderText="Invoice Date" DataField="INVOICE_INFO2" ReadOnly="true" />
                                        <asp:BoundField HeaderText="Invoice Info." DataField="INVOICE_INFO3" ReadOnly="true"
                                            ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="SchdLineStatus" DataField="Status" ReadOnly="true" />
                                        <asp:BoundField HeaderText="Link to (Serial No)" DataField="SERIAL_NO" ReadOnly="true"
                                            ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="Delivery Block" DataField="DELBLOCK" ReadOnly="true"
                                                                                    ItemStyle-HorizontalAlign="Center" />
                                    </Columns>
                                    <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                    <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                    <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                    <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify" />
                                    <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                    <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                    <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                </sgv:SmartGridView>
                            </td>
                        </tr>
                    </table>
                </td>
                <td style="width: 20px">
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>
    
    