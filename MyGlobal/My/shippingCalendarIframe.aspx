<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Private Sub GetBackOrderAB()
        Try
            Dim kunnr As String = UCase(Session("company_id")), vkorg As String = "EU10"
            If kunnr = "" Or vkorg = "" Then Exit Sub
            Dim FromDate As String = CDate(calendar1.VisibleDate.ToString("yyyy-MM-01")).ToString("yyyyMMdd")
            Dim ToDate As String = CDate(Util.GetLastDateOfMonth(calendar1.VisibleDate).ToString("yyyy-MM-dd")).ToString("yyyyMMdd")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.BSTNK AS PONO, VBAK.KUNNR as BILLTOID, ")
                .AppendFormat(" (select kunnr from saprdp.vbpa where vbpa.vbeln=vbak.vbeln and vbpa.parvw='WE' and rownum=1) AS SHIPTOID, ")
                .AppendFormat(" VBAK.AUDAT AS ORDERDATE, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS ORDERLINE, ")
                .AppendFormat(" VBAP.MATNR AS ProductId, VBAP.KWMENG AS SchdLineConfirmQty, ")
                .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, VBAP.NETPR AS UNITPRICE, ")
                .AppendFormat(" VBAP.NETWR AS TOTALPRICE, VBUP.LFSTA AS DOC_STATUS, VBEP.EDATU AS DUEDATE, VBEP.EDATU AS OriginalDD, VBAP.ZZ_GUARA AS ExWarranty, ")
                .AppendFormat(" nvl((select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1),0) as SchedLineShipedQty, ")
                .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
                .AppendFormat(" nvl((select SUM(LFIMG) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR),0) as DLV_QTY ")
                .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
                .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
                .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
                .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND (VBUP.MANDT = '168')  AND ")
                .AppendFormat(" (VBAK.VKORG = '{0}') AND (VBAK.KUNNR='{1}') AND ", vkorg, kunnr)
                .AppendFormat(" (VBEP.EDATU between '{0}' and '{1}') and VBUP.LFSTA IN ('A','B') ", FromDate, ToDate)
                .AppendFormat(" and VBAP.ABGRU = ' ' ")
            End With
            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
            'Response.Write(dt.Rows.Count)
            'Response.Write(sb.ToString())
            Dim BRs() As DataRow = dt.Select("DOC_STATUS='B'", "OrderNo ASC, ORDERLINE ASC, DUEDATE ASC")

            If BRs.Length > 0 Then
                Dim curSO As String = "", curLine As String = "", curQty As Decimal = 0
                For Each sch As DataRow In BRs
                    If sch.Item("OrderNo").ToString() <> curSO Or sch.Item("ORDERLINE").ToString() <> curLine Then
                        curSO = sch.Item("OrderNo").ToString() : curLine = sch.Item("ORDERLINE")
                        curQty = DirectCast(sch.Item("DLV_QTY"), Decimal)
                    End If
                    If CDbl(sch.Item("SchdLineOpenQty")) > curQty Then
                        sch.Item("SchdLineOpenQty") = sch.Item("SchdLineOpenQty") - curQty
                        curQty = 0
                    Else
                        curQty = curQty - CDbl(sch.Item("SchdLineOpenQty"))
                        sch.Delete()
                    End If
                Next
            End If
            dt.AcceptChanges()
            BRs = dt.Select("DOC_STATUS='A' and SchedLineShipedQty=0 and SchdLineNo=1")
            For Each sch As DataRow In BRs
                If dt.Select(String.Format("OrderNo='{0}' and ORDERLINE={1} and SchdLineNo>1", sch.Item("OrderNo"), sch.Item("ORDERLINE"))).Length > 0 Then
                    sch.Delete()
                End If
            Next
            dt.AcceptChanges()
            CType(ViewState("DDTable"), DataTable).Merge(dt)
        Catch ex As Exception
            Response.Write(ex.ToString())
        End Try
    End Sub
    Private Sub GetBackOrderC()
        Try
            Dim kunnr As String = UCase(Session("company_id")), vkorg As String = "EU10"
            If kunnr = "" Or vkorg = "" Then Exit Sub
            Dim FromDate As String = CDate(calendar1.VisibleDate.ToString("yyyy-MM-01")).ToString("yyyyMMdd")
            Dim ToDate As String = CDate(Util.GetLastDateOfMonth(calendar1.VisibleDate).ToString("yyyy-MM-dd")).ToString("yyyyMMdd")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.BSTNK AS PONO, VBAK.KUNNR as BILLTOID, ")
                .AppendFormat(" (select kunnr from saprdp.vbpa where vbpa.vbeln=vbak.vbeln and vbpa.parvw='WE' and rownum=1) AS SHIPTOID, ")
                .AppendFormat(" VBAK.AUDAT AS ORDERDATE, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS ORDERLINE, ")
                .AppendFormat(" VBAP.MATNR AS ProductId, VBAP.KWMENG AS SchdLineConfirmQty, ")
                .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, VBAP.NETPR AS UNITPRICE, ")
                .AppendFormat(" VBAP.NETWR AS TOTALPRICE, VBUP.LFSTA AS DOC_STATUS, VBEP.EDATU AS DUEDATE, VBEP.EDATU AS OriginalDD, VBAP.ZZ_GUARA AS ExWarranty, ")
                .AppendFormat(" (select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1) as SchedLineShipedQty, ")
                .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
                .AppendFormat(" nvl((select count(*) as n from SAPRDP.VBRP where VBRP.AUBEL = VBAK.VBELN and VBRP.AUPOS=VBAP.POSNR),0) as DLV_QTY ")
                .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
                .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
                .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
                .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND (VBUP.MANDT = '168')  AND ")
                .AppendFormat(" (VBAK.VKORG = '{0}') AND (VBAK.KUNNR='{1}') AND ", vkorg, kunnr)
                .AppendFormat(" (VBEP.EDATU between '{0}' and '{1}') and VBUP.LFSTA ='C' ", FromDate, ToDate)
                .AppendFormat(" and VBAP.ABGRU = ' ' ")
            End With
            'Response.Write(sb.ToString())
            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
            For Each r As DataRow In dt.Rows
                If CInt(r.Item("DLV_QTY")) > 0 Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()
            CType(ViewState("DDTable"), DataTable).Merge(dt)
        Catch ex As Exception
            Response.Write(ex.ToString())
        End Try
    End Sub
    Private Sub SetBackOrderOfVisibleMonth()
        If ViewState("DDTable") Is Nothing Then
            ViewState("DDTable") = New DataTable
        Else
            CType(ViewState("DDTable"), DataTable).Clear()
        End If
        Dim t1 As New Threading.Thread(AddressOf GetBackOrderAB), t2 As New Threading.Thread(AddressOf GetBackOrderC)
        t1.Start() : t2.Start()
        t1.Join() : t2.Join()
        'OrderUtilities.showDT(CType(ViewState("DDTable"), DataTable)) : Response.End()
    End Sub
    
    Protected Sub calendar1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            calendar1.VisibleDate = Now : SetBackOrderOfVisibleMonth()
        End If
    End Sub

    Protected Sub calendar1_VisibleMonthChanged(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.MonthChangedEventArgs)
        SetBackOrderOfVisibleMonth()
    End Sub

    Protected Sub calendar1_DayRender(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DayRenderEventArgs)
        Dim d As CalendarDay = e.Day, dLink As New HyperLink
        With dLink
            .Text = d.Date.Day.ToString() : .ForeColor = Drawing.Color.Black : .Target = "_blank"
        End With
        'OrderUtilities.showDT(CType(ViewState("DDTable"), DataTable))
        e.Cell.Controls.Clear() : e.Cell.Controls.Add(dLink)
        Dim rs() As DataRow = CType(ViewState("DDTable"), DataTable).Select(String.Format("DueDate='{0}'", d.Date.ToString("yyyyMMdd")))
        If rs.Length > 0 Then
            'Response.Write("aa")
            dLink.Font.Bold = True : dLink.ToolTip = GetBOInfo(rs)
            dLink.NavigateUrl = String.Format("~/Order/BO_BackorderInquiry.aspx?txtPN={0}&txtOrderDateFrom={1}&txtOrderDateTo={2}", rs(0).Item("PRODUCTID"), DateAdd(DateInterval.Month, -4, Now).ToString("yyyy/MM/dd"), Now.ToString("yyyy/MM/dd"))
        Else
            dLink.ForeColor = Drawing.Color.Gray
        End If
    End Sub
    
    Private Shared Function GetBOInfo(ByVal dr As DataRow()) As String
        Dim sb As New System.Text.StringBuilder
        For Each r As DataRow In dr
            sb.AppendLine(String.Format("{0} : {1} ", r.Item("PONo"), r.Item("PRODUCTID")))
        Next
        Return sb.ToString()
    End Function

    Protected Sub calendar1_SelectionChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        'Util.AjaxRedirect(UpCal, "/Order/BO_BackorderInquiry.aspx?")
    End Sub

    'Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
    '    'Response.Write(Session("company_id") & Session("org_id"))
    '    SetBackOrderOfVisibleMonth()
    '    'DataBind()
    'End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
     <asp:Calendar runat="server" ID="calendar1" 
                                                    OnLoad="calendar1_Load" OnVisibleMonthChanged="calendar1_VisibleMonthChanged" 
                                                    OnDayRender="calendar1_DayRender"
                                                    OnSelectionChanged="calendar1_SelectionChanged" BackColor="White" 
                                                    BorderColor="White" BorderWidth="1px" Font-Names="Verdana" Font-Size="9pt" 
                                                    ForeColor="Black" Height="190px" NextPrevFormat="FullMonth" >
                                                    <SelectedDayStyle BackColor="#333399" ForeColor="White" />
                                                    <TodayDayStyle BackColor="#CCCCCC" />
                                                    <OtherMonthDayStyle ForeColor="#999999" />
                                                    <NextPrevStyle Font-Bold="True" Font-Size="8pt" ForeColor="#333333" 
                                                        VerticalAlign="Bottom" />
                                                    <DayHeaderStyle Font-Bold="True" Font-Size="8pt" />
                                                    <TitleStyle BackColor="White" BorderColor="Black" BorderWidth="4px" 
                                                        Font-Bold="True" Font-Size="12pt" ForeColor="#333399" />
                                                </asp:Calendar>
    </div>
    </form>
</body>
</html>
