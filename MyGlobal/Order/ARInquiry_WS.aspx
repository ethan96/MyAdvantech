<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - A/P Inquiry" EnableEventValidation="false" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>
<script runat="server">
    Dim dt_vbrk As New DataTable, dt_bsid As New DataTable, dt_bsad As New DataTable, table As New DataTable
    Dim invoiceNO As String = "", type As String = "", dateFrom As String = "", dateTo As String = "", dueDateFrom As String = "", dueDateTo As String = ""
    Dim disChannel As String = "10"
    Dim division As String = "00"
    Dim customer_ID As String = "" 'session("Company_ID")
    Dim status As String = "" 'this var is for open,overdue,all status
    Dim no As String = ""
    
    Protected Sub Search(ByVal Sales_Org As String, ByVal discha As String, ByVal division As String, ByVal customer_id As String, ByVal SDate As String, ByVal EDate As String, ByVal S_Due_Date As String, ByVal E_Due_Date As String)
        Dim salesOrg As String = Session("org_id")
        Dim sb As New StringBuilder
        With sb
            
            'Frank 2013/05/30: Remove 3 sub select statements, they are too slow and not in used.
            '.AppendFormat("select distinct a.vkorg,a.vbeln,a.fkdat,nvl(a.netwr,0) as netwr,a.waerk,nvl(a.mwsbk,0) as mwsbk,a.kunag,a.kunrg,b.aubel,(select c.kunnr from SAPRDP.vbpa c where c.vbeln=b.aubel and rownum = 1 and c.parvw = 'WE') as kunnr,(select d.kunnr from SAPRDP.vbpa d where d.vbeln=b.aubel and rownum=1 and d.parvw = 'RE') as kunnr2,(select e.bstkd from SAPRDP.vbkd e where b.aubel = e.vbeln and rownum=1) as bstkd ")
            .AppendFormat("select distinct a.vkorg,a.vbeln,a.fkdat,nvl(a.netwr,0) as netwr,a.waerk,nvl(a.mwsbk,0) as mwsbk,a.kunag,a.kunrg,b.aubel ")
            .AppendFormat(" FROM SAPRDP.vbrk a inner join SAPRDP.vbrp b on a.vbeln = b.vbeln ")
            .AppendFormat(" WHERE a.mandt='168' and b.mandt='168' and a.fksto = ' ' and a.sfakn = ' ' and a.vbeln <> ' ' and a.vkorg = '{0}' and a.spart = '{1}' ", Sales_Org, division)
            If customer_id <> "EKGBEC01" Then
                .AppendFormat(" and a.kunag = '{0}' ", customer_id)
            Else
                If LCase(Session("user_id")) = "freya.huggard@ecauk.com" Then
                    .AppendFormat(" and (a.kunag in ('EKGBEC01','EKGBEC02','EKGBEC03','EKGBEC04')) ")
                Else
                    .AppendFormat(" and a.kunag = '{0}' ", customer_id)
                End If
            End If
        End With
        'Dim sql As String = String.Format("select distinct a.vkorg,a.vbeln,a.fkdat,nvl(a.netwr,0) as netwr,a.waerk,nvl(a.mwsbk,0) as mwsbk,a.kunag,a.kunrg,b.aubel,(select c.kunnr from SAPRDP.vbpa c where c.vbeln=b.aubel and rownum = 1 and c.parvw = 'WE') as kunnr,(select d.kunnr from SAPRDP.vbpa d where d.vbeln=b.aubel and rownum=1 and d.parvw = 'RE') as kunnr2,(select e.bstkd from SAPRDP.vbkd e where b.aubel = e.vbeln and rownum=1) as bstkd " + _
        '                                  " FROM SAPRDP.vbrk a inner join SAPRDP.vbrp b on a.vbeln = b.vbeln" + _
        '                                  " WHERE a.mandt='168' and b.mandt='168' and a.fksto = ' ' and a.sfakn = ' ' and a.vbeln <> ' ' and a.vkorg = '{0}' and a.spart = '{1}' and a.kunag = '{2}' and a.fkdat between '{3}' and '{4}' order by a.fkdat desc", Sales_Org, division, customer_id, SDate, EDate)
        'If Session("user_id") = "rudy.wang@advantech.com.tw" Then 
        'Response.Write(sb.ToString())
        dt_vbrk = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
        Dim t1 As New Threading.Thread(AddressOf GetOpenItem), t2 As New Threading.Thread(AddressOf GetCloseItem)
        t1.Start() : t2.Start()
        t1.Join() : t2.Join()
        table = GetARTable(SDate, EDate, S_Due_Date, E_Due_Date)
    End Sub
    
    Private Sub GetOpenItem()
        Dim arrInvoiceNo As New ArrayList(), arrInvoiceNo1 As New ArrayList
        Dim i As Integer = 0, _sql As New StringBuilder, _IsExecSQL As Boolean = False
        For Each r As DataRow In dt_vbrk.Rows
            If arrInvoiceNo1.Count Mod 1000 = 0 Then
                If arrInvoiceNo1.Count >= 1000 Then
                    _IsExecSQL = True
                    _sql.AppendLine(String.Join(",", arrInvoiceNo1.ToArray()) & " ) ")
                    _sql.AppendLine(" union all ")
                End If
                If _sql.Length = 0 Or arrInvoiceNo1.Count > 0 Then
                    _sql.AppendLine(" SELECT vbeln,budat,blart,xzahl,shkzg,nvl(wrbtr,0) as wrbtr,zfbdt,zbd1t,waers ")
                    _sql.AppendLine(" From SAPRDP.bsid ")
                    _sql.AppendLine(" where mandt='168' and kunnr='" & customer_ID & "' and vbeln in ( ")
                End If
                arrInvoiceNo1.Clear()
            End If
            If Not arrInvoiceNo.Contains("'" + r.Item("vbeln") + "'") Then
                arrInvoiceNo.Add("'" + r.Item("vbeln") + "'")
                arrInvoiceNo1.Add("'" + r.Item("vbeln") + "'")
            End If
            i += 1
        Next

        
        If arrInvoiceNo1.Count > 0 Then
            'Dim sql As String = "SELECT vbeln,budat,blart,xzahl,shkzg,nvl(wrbtr,0) as wrbtr,zfbdt,zbd1t,waers From SAPRDP.bsid where vbeln in (" + String.Join(",", arrInvoiceNo.ToArray()) + ")"
            'Response.Write(sql)
            'dt_bsid = OraDbUtil.dbGetDataTable("SAP_PRD", sql)
            _sql.AppendLine(String.Join(",", arrInvoiceNo1.ToArray()) & " ) ")
            _IsExecSQL = True
        End If
        If _IsExecSQL Then dt_bsid = OraDbUtil.dbGetDataTable("SAP_PRD", _sql.ToString)
    End Sub
    
    Private Sub GetCloseItem()
        Dim arrInvoiceNo As New ArrayList(), arrInvoiceNo1 As New ArrayList
        Dim i As Integer = 0, _sql As New StringBuilder, _IsExecSQL As Boolean = False
        For Each r As DataRow In dt_vbrk.Rows
            If arrInvoiceNo1.Count Mod 1000 = 0 Then
                If arrInvoiceNo1.Count >= 1000 Then
                    _IsExecSQL = True
                    _sql.AppendLine(String.Join(",", arrInvoiceNo1.ToArray()) & " ) ")
                    _sql.AppendLine(" union all ")
                End If
                If _sql.Length = 0 Or arrInvoiceNo1.Count > 0 Then
                    _sql.AppendLine(" SELECT vbeln,budat,blart,nvl(wrbtr,0) as wrbtr,shkzg,waers,zfbdt,zbd1t ")
                    _sql.AppendLine(" From SAPRDP.bsad ")
                    _sql.AppendLine(" where mandt='168' and kunnr='" & customer_ID & "' and vbeln in ( ")
                End If
                arrInvoiceNo1.Clear()
            End If
            If Not arrInvoiceNo.Contains("'" + r.Item("vbeln") + "'") Then
                arrInvoiceNo.Add("'" + r.Item("vbeln") + "'")
                arrInvoiceNo1.Add("'" + r.Item("vbeln") + "'")
            End If
            i += 1
        Next

        If arrInvoiceNo1.Count > 0 Then
            _sql.AppendLine(String.Join(",", arrInvoiceNo1.ToArray()) & " ) ")
            _IsExecSQL = True
        End If
        If _IsExecSQL Then dt_bsad = OraDbUtil.dbGetDataTable("SAP_PRD", _sql.ToString)
    End Sub
    
    'Private Sub GetCloseItem()
    '    Dim arrInvoiceNo As New ArrayList
    '    For Each r As DataRow In dt_vbrk.Rows
    '        If Not arrInvoiceNo.Contains("'" + r.Item("vbeln") + "'") Then arrInvoiceNo.Add("'" + r.Item("vbeln") + "'")
    '    Next
    '    If arrInvoiceNo.Count > 0 Then
    '        Dim sql As String = "SELECT vbeln,budat,blart,nvl(wrbtr,0) as wrbtr,shkzg,waers,zfbdt,zbd1t From SAPRDP.bsad where vbeln in (" + String.Join(",", arrInvoiceNo.ToArray()) + ")"
    '        'Response.Write(sql)
    '        'If Session("user_id") = "rudy.wang@advantech.com.tw" Then Response.Write(sql)
    '        dt_bsad = OraDbUtil.dbGetDataTable("SAP_PRD", sql)
    '    End If
    'End Sub
    
    Protected Function GetARTable(ByVal SDate As String, ByVal EDate As String, ByVal S_Due_Date As String, ByVal E_Due_Date As String) As DataTable
        Dim dt_ar As New DataTable
        dt_ar.Columns.Add("AR_NO", GetType(System.String))
        dt_ar.Columns.Add("AR_DATE", GetType(System.String))
        'dt_ar.Columns.Add("SOLDTO", GetType(System.String))
        dt_ar.Columns.Add("AMOUNT", GetType(System.Double))
        dt_ar.Columns.Add("CURRENCY", GetType(System.String))
        dt_ar.Columns.Add("AR_DUE_DATE", GetType(System.String))
        dt_ar.Columns.Add("LOCAL_AMOUNT", GetType(System.Double))
        dt_ar.Columns.Add("AR_STATUS", GetType(System.String))
        'dt_ar.Columns.Add("SONO", GetType(System.String))
        'dt_ar.Columns.Add("SHIPTO", GetType(System.String))
        'dt_ar.Columns.Add("BILLTO", GetType(System.String))
        'dt_ar.Columns.Add("PONO", GetType(System.String))
        
        If dt_bsad.Rows.Count > 0 Then
            For Each r As DataRow In dt_bsad.Rows
                Dim row As DataRow = dt_ar.NewRow()
                row.Item("AR_NO") = r.Item("vbeln")
                row.Item("AR_DATE") = Date.ParseExact(r.Item("budat"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd")
                row.Item("CURRENCY") = r.Item("waers")
                Dim dr() As DataRow = dt_vbrk.Select("vbeln='" + r.Item("vbeln") + "'")
                row.Item("AMOUNT") = dr(0).Item("netwr")
                For i As Integer = 0 To dr.Length - 1
                    row.Item("AMOUNT") += dr(i).Item("mwsbk")
                Next
                row.Item("AR_DUE_DATE") = DateAdd(DateInterval.Day, CDbl(r.Item("zbd1t")), Date.ParseExact(r.Item("zfbdt"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None)).ToString("yyyy/MM/dd")
                row.Item("LOCAL_AMOUNT") = row.Item("AMOUNT") - r.Item("wrbtr")
                row.Item("AR_STATUS") = "Cleared"
                dt_ar.Rows.Add(row)
            Next
        End If
        
        If dt_bsid.Rows.Count > 0 Then
            For Each r As DataRow In dt_bsid.Rows
                Dim row As DataRow = dt_ar.NewRow()
                row.Item("AR_NO") = r.Item("vbeln")
                row.Item("AR_DATE") = Date.ParseExact(r.Item("budat"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd")
                row.Item("CURRENCY") = r.Item("waers")
                Dim dr() As DataRow = dt_vbrk.Select("vbeln='" + r.Item("vbeln") + "'")
                row.Item("AMOUNT") = dr(0).Item("netwr")
                For i As Integer = 0 To dr.Length - 1
                    row.Item("AMOUNT") += dr(i).Item("mwsbk")
                Next
                row.Item("AR_DUE_DATE") = DateAdd(DateInterval.Day, CDbl(r.Item("zbd1t")), Date.ParseExact(r.Item("zfbdt"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None)).ToString("yyyy/MM/dd")
                If r.Item("shkzg") = "H" Then
                    Dim oridr() As DataRow = dt_ar.Select("AR_NO='" + r.Item("vbeln") + "'")
                    If oridr.Length > 0 Then
                        row.Item("AR_DATE") = oridr(0).Item("AR_DATE")
                        row.Item("LOCAL_AMOUNT") = row.Item("AMOUNT") + r.Item("wrbtr")
                        dt_ar.Rows(dt_ar.Rows.IndexOf(oridr(0))).Delete()
                    End If
                Else
                    row.Item("LOCAL_AMOUNT") = r.Item("wrbtr")
                End If
                
                If IsDBNull(row.Item("LOCAL_AMOUNT")) Then
                    row.Item("AR_STATUS") = "Cleared"
                ElseIf row.Item("LOCAL_AMOUNT") = 0 Then
                    row.Item("AR_STATUS") = "Cleared"
                Else
                    If row.Item("AR_DUE_DATE") = "" Or IsDBNull(row.Item("AR_DUE_DATE")) Then
                        row.Item("AR_STATUS") = "Open"
                    Else
                        If row.Item("AMOUNT") - row.Item("LOCAL_AMOUNT") <> 0 Then
                            If CDate(row.Item("AR_DUE_DATE")) < Date.Today Then
                                row.Item("AR_STATUS") = "Partial Overdue"
                            Else
                                row.Item("AR_STATUS") = "Partially Cleared"
                            End If
                        Else
                            If CDate(row.Item("AR_DUE_DATE")) < Date.Today Then
                                row.Item("AR_STATUS") = "Overdue"
                            Else
                                row.Item("AR_STATUS") = "Open"
                            End If
                        End If
                    End If
                End If
                dt_ar.Rows.Add(row)
            Next
        End If
        
        Dim dr1() As DataRow = dt_ar.Select("AR_DUE_DATE < '" + Date.ParseExact(S_Due_Date, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd") + "' or AR_DUE_DATE > '" + Date.ParseExact(E_Due_Date, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd") + "'")
        For i As Integer = 0 To dr1.Length - 1
            dt_ar.Rows(dt_ar.Rows.IndexOf(dr1(i))).Delete()
        Next
        
        Return dt_ar
    End Function
   
    Function DateConvert(ByVal strVal) As String
        If IsDate(strVal) Then
            Dim yyyy As String = Year(strVal).ToString()
            Dim mm As String = ""
            Dim dd As String = ""
            Select Case Month(strVal).ToString().Length
                Case 1
                    mm = "0" & Month(strVal).ToString()
                Case 2
                    mm = Month(strVal).ToString()
            End Select
            Select Case Day(strVal).ToString().Length
                Case 1
                    dd = "0" & Day(strVal).ToString()
                Case 2
                    dd = Day(strVal).ToString()
            End Select
            DateConvert = yyyy & mm & dd
        Else
            DateConvert = "00000000"
        End If
    End Function
    
    Function DateConvertRevsese(ByVal strVal) As String
        Dim yyyy As String = Mid(strVal, 1, 4)
        Dim mm As String = Mid(strVal, 5, 2)
        Dim dd As String = Mid(strVal, 7, 2)
        DateConvertRevsese = yyyy & "/" & mm & "/" & dd
    End Function
    
    Function FormatDate(ByVal xDate) As String
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
            Else
                xYear = ArrDate(2)
                xMonth = ArrDate(0)
                xDay = ArrDate(1)
            End If
        End If
        
        If xMonth.Length = 1 Then
            xMonth = "0" & xMonth
        End If
        If xDay.Length = 1 Then
            xDay = "0" & xDay
        End If
        FormatDate = xYear & "/" & xMonth & "/" & xDay
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("org_id") Is Nothing OrElse Session("company_id") Is Nothing Then
            btnSearch.Visible = False
            btnToXls1.Visible = False
            btnToXls.Visible = False
            Exit Sub
        End If
        SAPDOC.Get_disChannel_and_division(Session("company_id").ToString, disChannel, division)
        If Not Page.IsPostBack Then
            Dim salesOrg As String = Session("org_id")
            customer_ID = Session("company_id")
            'Dim sales_org As String = Session("org_id")            
            Me.txtInvoiceNO.Text = Request("inv_no")
            Me.txtDateFrom.Text = FormatDate(Date.Now.AddDays(-60))
            Me.txtDateTo.Text = FormatDate(Date.Now)
            Me.txtDueDateFrom.Text = FormatDate(Date.Now.AddDays(-30))
            Me.txtDueDateTo.Text = FormatDate(Date.Now.AddDays(60))
            dateFrom = DateConvert(CDate(Me.txtDateFrom.Text))
            dateTo = DateConvert(CDate(Me.txtDateTo.Text))
            dueDateFrom = DateConvert(CDate(Me.txtDueDateFrom.Text))
            dueDateTo = DateConvert(CDate(Me.txtDueDateTo.Text))
            Call Search(salesOrg, disChannel, division, Session("company_id").ToString().ToUpper(), dateFrom, dateTo, dueDateFrom, dueDateTo)
            Dim dv As DataView = New DataView()
            dv = table.DefaultView()
            dv.Sort = " ar_no,ar_date desc "
            gv1.DataSource = dv.ToTable()
            gv1.DataBind()
            ViewState("DT") = ""
            ViewState("DT") = gv1.DataSource
            If Trim(Session("org_id")).ToUpper() = "US01" Then
                disChannel = "30" : division = "10"
            End If
        End If
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            e.Row.Cells(1).Text = "<a href='/Order/BO_InvoiceInquiry.aspx?inv_no=" & CInt(e.Row.Cells(1).Text) & "' target='_blank'>" & CInt(e.Row.Cells(1).Text) & "</a>"
            Dim strRowCell7 As String = e.Row.Cells(7).Text
            If strRowCell7 = "Cleared" Then
                e.Row.Cells(7).Text = "<font >" & "--" & "</font>"
            ElseIf strRowCell7 = "Overdue" Or strRowCell7 = "Partial Overdue" Then
                Dim diff As TimeSpan = CDate(System.DateTime.Today.ToString("yyyy-MM-dd")) - CDate(e.Row.Cells(6).Text)
                e.Row.Cells(7).Text = "<table width='100%'><tr><td bgcolor='#ffcc66'><font color='red'>" & diff.TotalDays.ToString() & "</font></td></tr></table>"
                'style="BACKGROUND-COLOR: #ffcc66;WIDTH=100%"     style='BACKGROUND-COLOR: #99ff66;WIDTH=100%'
            End If
            If strRowCell7 = "Open" Then
                e.Row.Cells(7).Text = "<table width='100%'><tr><td bgcolor='#99ff66'><font color='red'>" & "Open" & "</font></td></tr></table>"
            End If
            e.Row.Cells(4).Text = CDbl(e.Row.Cells(4).Text).ToString("#,##0.00")
            Dim open_amount As Double
            If Double.TryParse(e.Row.Cells(5).Text, open_amount) Then e.Row.Cells(5).Text = open_amount.ToString("#,##0.00")
            'e.Row.Cells(5).Text = CDbl(e.Row.Cells(5).Text).ToString("#,##0.00")
        End If
    End Sub
    
    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Util.DataTable2ExcelFile(ViewState("DT"), "AP.xls")
        Util.DataTable2ExcelDownload(ViewState("DT"), "AP.xls")
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim salesOrg As String = Session("org_id")
        customer_ID = Session("company_id")
        dateFrom = DateConvert(CDate(Me.txtDateFrom.Text))
        dateTo = DateConvert(CDate(Me.txtDateTo.Text))
        dueDateFrom = DateConvert(CDate(Me.txtDueDateFrom.Text))
        dueDateTo = DateConvert(CDate(Me.txtDueDateTo.Text))
        Call Search(salesOrg, disChannel, division, Session("company_id").ToString().ToUpper(), dateFrom, dateTo, dueDateFrom, dueDateTo)
        Dim dv As DataView = New DataView()
        dv = table.DefaultView()
        dv.Sort = " ar_no,ar_date desc "
        Select Case Me.ddlType.Value
            Case "Open"
                Me.status = " ar_status like 'Open%' "
            Case "Over Due"
                'Me.status = " status = 'Overdue' or status = 'Partial Overdue'"
                Me.status = " ar_status like '%Over%' "
            Case "All"
                Me.status = " 1=1 "
        End Select
        Me.no = " and ar_no like '%" & Me.txtInvoiceNO.Text & "%' "
        dv.RowFilter = Me.status & Me.no
        
        gv1.DataSource = dv.ToTable()
        gv1.DataBind()
        ViewState("DT") = ""
        ViewState("DT") = gv1.DataSource
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <asp:Panel ID="Panel_Form" runat="server" DefaultButton="btnSearch">
        <div class="root">
            <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
            >
            <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx"
                Text="Order Tracking" />
            > A/P Inquiry</div>
        <table width="100%">
            <tr>
                <td valign="top">
                    <div class="left" style="width: 170px;">
                        <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="ARInquiry_WS" />
                    </div>
                </td>
                <td>
                    <div class="right" style="width: 707px;">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td height="9">
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
                                                Account Payable
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
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
                                            <td>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                    <form id="form3" name="form3" method="post" action="">
                                                    <tr>
                                                        <td width="20%" height="30" class="h5">
                                                            Type:
                                                        </td>
                                                        <td colspan="2">
                                                            <select name="ddlType" size="1" class="euFormFieldValue" runat="server" id="ddlType">
                                                                <option value="All">All</option>
                                                                <option value="Over Due">Over Due</option>
                                                                <option value="Open">Open</option>
                                                            </select>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30">
                                                            Invoice Number:
                                                        </td>
                                                        <td colspan="2">
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" ServiceMethod="GetInvoiceNo"
                                                                TargetControlID="txtInvoiceNo" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                FirstRowSelected="true" CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtInvoiceNO" runat="server" size="10" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30">
                                                            Shipping Date:
                                                        </td>
                                                        <td colspan="2">
                                                            <asp:TextBox runat="server" ID="txtDateFrom" Width="76px" />
                                                            <asp:RequiredFieldValidator runat="server" ID="rfvDateFrom" ErrorMessage=" *" ForeColor="Red"
                                                                ControlToValidate="txtDateFrom" />
                                                            ~
                                                            <asp:TextBox runat="server" ID="txtDateTo" Width="76px" /><asp:RequiredFieldValidator
                                                                runat="server" ID="rfvDateTo" ErrorMessage=" *" ForeColor="Red" ControlToValidate="txtDateTo" />
                                                            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" TargetControlID="txtDateFrom"
                                                                Format="yyyy/MM/dd" />
                                                            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" TargetControlID="txtDateTo"
                                                                Format="yyyy/MM/dd" />
                                                            <span class="date_word">yyyy/mm/dd</span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30">
                                                            Due Date:
                                                        </td>
                                                        <td colspan="2">
                                                            <asp:TextBox runat="server" ID="txtDueDateFrom" Width="76px" />
                                                            <asp:RequiredFieldValidator runat="server" ID="rfvDueDateFrom" ErrorMessage=" *"
                                                                ForeColor="Red" ControlToValidate="txtDueDateFrom" />
                                                            ~
                                                            <asp:TextBox runat="server" ID="txtDueDateTo" Width="76px" /><asp:RequiredFieldValidator
                                                                runat="server" ID="rfvDueDateTo" ErrorMessage=" *" ForeColor="Red" ControlToValidate="txtDueDateTo" />
                                                            <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtDueDateFrom"
                                                                Format="yyyy/MM/dd" />
                                                            <ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtDueDateTo"
                                                                Format="yyyy/MM/dd" />
                                                            <span class="date_word">yyyy/mm/dd</span>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td height="30" colspan="3" align="right">
                                                            <asp:ImageButton runat="server" ID="btnSearch" ImageUrl="~/Images/search1.gif" OnClick="btnSearch_Click" />
                                                        </td>
                                                    </tr>
                                                    </form>
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
        <table>
            <tr>
                <td>
                    <div>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td height="10" colspan="2">
                                    <img src="../images/line3.gif" width="889" height="1" />
                                </td>
                            </tr>
                            <tr height="30">
                                <td>
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
                                <td>
                                    <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                                        Width="100%" EnableTheming="false" RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb"
                                        HeaderStyle-BackColor="#dcdcdc" BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="#311e90"
                                        HeaderStyle-Font-Size="10px" RowStyle-Font-Size="10px" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                        PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnRowDataBound="gv1_RowDataBound">
                                        <Columns>
                                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    No.
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <%# Container.DataItemIndex + 1 %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="Invoice NO" DataField="ar_no" SortExpression="ar_no"
                                                ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Shipping Date" DataField="ar_date" SortExpression="ar_date"
                                                ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Currency" DataField="currency" SortExpression="currency"
                                                ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Amount" DataField="amount" SortExpression="amount" ItemStyle-HorizontalAlign="Right" />
                                            <asp:BoundField HeaderText="Open Amount" DataField="local_amount" SortExpression="local_amount"
                                                ItemStyle-HorizontalAlign="Right" />
                                            <asp:BoundField HeaderText="Due Date" DataField="ar_due_date" SortExpression="ar_due_date"
                                                ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Over Due" DataField="ar_status" SortExpression="ar_status" />
                                        </Columns>
                                        <FixRowColumn FixColumns="-1" FixRows="-1" TableHeight="400px" FixRowType="Header" />
                                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                    </sgv:SmartGridView>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>
