<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - My Performance" Culture="en-US" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Register Src="~/Includes/ChangeCompany.ascx" TagName="ChgComp" TagPrefix="uc8" %>
<script runat="server">
 Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Andrew 2015/9/8 add permission for franchiser and modify redirection to root home.aspx not my/home.aspx
            If Session("account_status") IsNot Nothing AndAlso (Session("account_status").ToString() = "EZ" _
                OrElse Session("account_status").ToString() = "CP" _
                OrElse Session("account_status").ToString() = "KA" _
                OrElse Session("account_status").ToString() = "FC") Then
            Else
                Response.Redirect("~/home.aspx")
            End If
            'ICC 2015/1/9 The options will be dynamically changed for these 3 years
            cblYear.Items.Clear()
            For i As Integer = DateTime.Now.Year To DateTime.Now.Year - 2 Step -1
                cblYear.Items.Add(New ListItem(i.ToString, i.ToString))
            Next
            cblYear.SelectedValue = DateTime.Now.Year.ToString
            Dim dt As DataTable = MYSAPDAL.GetCompanyDataFromLocal(Session("company_id"), Session("org_id"))
            If dt.Rows.Count > 0 Then
                With dt.Rows(0)
                    ltCustAddr.Text = .Item("ADDRESS") : ltCustName.Text = .Item("COMPANY_NAME") : ltCustUrl.Text = .Item("URL") : ltCity.Text = .Item("city")
                End With
            End If
            'Dim Cust As New Company(Session("company_id"))
            'With Cust
            '    ltCustAddr.Text = ._addr : ltCustName.Text = ._companyName : ltCustType.Text = ._type : ltCustUrl.Text = ._url : ltCity.Text = ._city
            'End With
            'Me.WeatherRow.Visible = (New GoogleWeather).GetWeather(Cust._city, ltCond.Text, ltTemp.Text, ltHumid.Text, imgIcon.ImageUrl, ltWind.Text)
            GetScoreBoard()
            If Not Util.IsInternalUser2() Then
                ChgComp1.Visible = False
            End If
        End If
    End Sub
    Protected Sub gvCustPerf_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim rowTotal As Double = 0
            For i As Integer = 2 To 13
                Dim tmpValue As Double = 0
                If Double.TryParse(e.Row.Cells(i).Text, tmpValue) Then
                    rowTotal += tmpValue
                End If
            Next
            e.Row.Cells(14).Text = rowTotal
            e.Row.BackColor = Drawing.Color.White
        End If
        gvCustPerf.Columns(14).ItemStyle.HorizontalAlign = HorizontalAlign.Center
    End Sub

    Protected Sub gvCustPerf_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        Dim oRowGrid As GridViewRow = CType(e.Row, GridViewRow)
        If oRowGrid.RowType = DataControlRowType.Footer Then
            Dim oRowGridAdd As New GridViewRow(2, 2, DataControlRowType.Header, DataControlRowState.Normal)
            Dim oCell As New TableCell
            gvCustPerf.Controls(0).Controls(0).Controls.RemoveAt(0) : gvCustPerf.Controls(0).Controls(0).Controls.RemoveAt(0)
            oCell.Text = "Category" : oCell.RowSpan = "2" : oCell.CssClass = "hdrstyle02" : oRowGridAdd.Cells.Add(oCell)
            oCell = New TableCell : oCell.Text = "Year" : oCell.RowSpan = "2" : oCell.CssClass = "hdrstyle02" : oRowGridAdd.Cells.Add(oCell)
            oCell = New TableCell : oCell.Text = "Q1" : oCell.ColumnSpan = 3 : oCell.CssClass = "hdrstyle02" : oRowGridAdd.Cells.Add(oCell)
            oCell = New TableCell : oCell.Text = "Q2" : oCell.ColumnSpan = 3 : oCell.CssClass = "hdrstyle02" : oRowGridAdd.Cells.Add(oCell)
            oCell = New TableCell : oCell.Text = "Q3" : oCell.ColumnSpan = 3 : oCell.CssClass = "hdrstyle02" : oRowGridAdd.Cells.Add(oCell)
            oCell = New TableCell : oCell.Text = "Q4" : oCell.ColumnSpan = 3 : oCell.CssClass = "hdrstyle02" : oRowGridAdd.Cells.Add(oCell)
            oCell = New TableCell : oCell.HorizontalAlign=HorizontalAlign.Center:oCell.Text = "YTD" : oCell.RowSpan = "2" : oCell.CssClass = "hdrstyle02" : oRowGridAdd.Cells.Add(oCell)
            gvCustPerf.Controls(0).Controls(0).Controls.RemoveAt(12) : gvCustPerf.Controls(0).Controls.AddAt(0, oRowGridAdd)
        End If
    End Sub
    Protected Sub hlInvoiceNo_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink)
        hl.NavigateUrl = "/Order/BO_InvoiceInquiry.aspx?inv_no=" + CInt(hl.Text).ToString()
        hl.Target = "_blank"
    End Sub

    Protected Sub hlBackorder_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink)
        If Integer.TryParse(hl.Text, Integer.MaxValue) Then
            hl.NavigateUrl = "/Order/BO_BackOrderInquiry.aspx?txtSONO=" + CInt(hl.Text).ToString()
        Else
            hl.NavigateUrl = "/Order/BO_BackOrderInquiry.aspx?txtSONO=" + hl.Text
        End If
        hl.Target = "_blank"
    End Sub

    Protected Sub hlAR_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink)
        hl.NavigateUrl = "/Order/ARInquiry_WS.aspx?inv_no=" + CInt(hl.Text).ToString()
        hl.Target = "_blank"
    End Sub
    Public Shared Function GetCurrencyCode(ByVal currency As String) As String
        Select Case currency
            Case "US", "USD"
                Return "$"
            Case "EUR"
                Return "&euro;"
            Case "GBP"
                Return "&pound;"
            Case "NT", "NTD"
                Return "NT"
            Case Else
                Return "$"
        End Select
    End Function
    Protected Sub lblRole_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Select Case CType(sender, Label).Text
            Case "VE" : CType(sender, Label).Text = "Sales"
            Case "Z2" : CType(sender, Label).Text = "SA"
            Case "ZM" : CType(sender, Label).Text = "OP"
        End Select
    End Sub
    Protected Sub lbluseridLong_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Select Case CType(CType(CType(sender, Label).NamingContainer, GridViewRow).FindControl("lblsubty"), Label).Text
            Case "MAIL"
                CType(CType(CType(sender, Label).NamingContainer, GridViewRow).FindControl("lblsubty"), Label).Text = "<img alt='email' src='/Images/icon_mail.jpg' />"
                CType(sender, Label).Text = String.Format("<a href='mailto:{0}'>{0}</a>", LCase(CType(sender, Label).Text))
            Case "0020" : CType(CType(CType(sender, Label).NamingContainer, GridViewRow).FindControl("lblsubty"), Label).Text = "<img alt='phone' src='/Images/icon_phone.jpg' />"
        End Select
    End Sub
    
    Protected Sub Export2XLS() Handles BtnSave2Excel.Click
        Dim DT As DataTable = dbUtil.dbGetDataTable("EAI", "select ITEM_NO AS Material,CUSTOMER_ID as customer_ID, " & _
                                                            "left(TRAN_ID,8) AS InvoiceNo,right(TRAN_ID,4) as InvoiceLine,Order_No as OrderNo, " & _
                                                            "Org,Qty,EUR/qty as PriceEuro,EUR AS InvoiceTotalEuro,Sector,tr_curr as Currency, " & _
                                                            "efftive_date as InvoiceDate,Product_line as ProductLine from g_sale_fact " & _
                                                            "where Customer_Id='" + Session("company_id").ToString.Trim + "' and sam_sw='N' and year(efftive_date) in (" & GetYear() & ") " & _
                                                            "and tran_type='Shipment' and fact_1234=1 and (sale_type='ACL-FOB' or (fact_zone='Europe' or " & _
                                                    "(fact_zone = 'D&MS(E2E)' and org like 'E%'))) and eur<>0  and qty<>0")

        If DT.Rows.Count > 0 Then
            DT.TableName = "shipment_detail"
            Util.DataTable2ExcelDownload(DT, "shipment.xls")
        End If
     
    End Sub
    Private Function GetYear() As String
        Dim itemArray As New ArrayList
        For Each item As ListItem In cblYear.Items
            If item.Selected Then itemArray.Add("'" + item.Value + "'")
        Next
        'Frank 2012/06/05:bug fixed: String.Join(",", itemArray.ToArray(GetType(System.String))) returned incorrect format string(returned this ==> System.String[])
        'Return String.Join(",", itemArray.ToArray(GetType(System.String)))
        Return String.Join(",", itemArray.ToArray())
    End Function

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        GetScoreBoard()
    End Sub
    
    Private Sub GetScoreBoard()
        Me.testP.Visible = True
        Dim g_Company_Name As String = ltCustName.Text
        Dim labels() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
        Dim c As XYChart = New XYChart(583, 370, &HFFFFFF, &HC7D5F1)
        With c
            .setPlotArea(50, 70, 510, 280, &HFFFFFF, -1, -1, &HC0C0C0, -1) : .addLegend(35, 20, False, "", 8).setBackground(Chart.Transparent) : .addTitle("Customer: " & g_Company_Name, "Arial Bold Italic", 11, &H333333).setBackground(&HECECEC, &HC7D5F1) : .yAxis().setTitle("Amount (Unit=1K Euro)") : .xAxis().setLabels(labels) : .xAxis().setTitle(" ")
        End With
        Dim layer As LineLayer = c.addLineLayer2()
        
        Dim scoreDt As New DataTable
        With scoreDt.Columns
            .Add("Category") : .Add("Year")
            For Each strMNonth As String In labels
                .Add(strMNonth, Type.GetType("System.Double"))
            Next
            .Add("YTD", Type.GetType("System.Double")) : .Add("url")
        End With
        
        For Each item As ListItem In cblYear.Items
            If item.Selected Then
                Dim dataPerf() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                Dim dataBackOrder() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                Dim DataOrderEntry() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                Dim ACLDataPerf() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                Dim aclPerfFlag As Integer = 0
                Dim conn1 As SqlClient.SqlConnection = Nothing
                'Dim sqlBackorder As String = String.Format("select month(due_date) as m, sum({1}) as Amount from eai_sale_fact where " & _
                ' "Customer_Id='{0}' and sam_sw='N' and year(due_date)='" & item.Value & "' " & _
                ' "and tran_type='Backlog' and fact_1234=1 and factyear='" & item.Value & "' and eur<>0 and bomseq>=0" & _
                ' "group by month(due_date) order by month(due_date)", Session("company_id"), ddlCurr.SelectedValue)
                'Dim itlist As String
                'If ddlCurr.SelectedValue = "EUR" Then
                '    itlist = "EUR"
                'Else
                '    itlist = "Us_Amt"
                'End If
                'Dim sqlBackorder As String = String.Format("select month(due_date) as m, sum({1}) as Amount from eai_sale_fact where " & _
                '                                      "Customer_Id='{0}' and sam_sw='N' and year(due_date)='" & item.Value & "' " & _
                '                                      "and tran_type='Backlog' and fact_1234=1 and factyear='" & item.Value & "' and (fact_zone='Europe' or " & _
                '                                      "(fact_zone = 'D&MS(E2E)' and org like 'E%')) and eur<>0 " & _
                '                                      "group by month(due_date) order by month(due_date)", Session("company_id"), ddlCurr.SelectedValue)
                Dim sqlBackorder As String = String.Empty
                Dim SB As New StringBuilder
                SB.AppendFormat(" select month(efftive_date) as m, sum({0}) as Amount from eai_sale_fact where ", ddlCurr.SelectedValue)
                SB.AppendFormat(" Customer_Id='{1}' and sam_sw='N' and year(efftive_date)='{0}'  ", item.Value, Session("company_id"))
                SB.AppendFormat(" and tran_type='Backlog' and fact_1234=1 and factyear='{0}' ", item.Value)
                If Session("org_id") IsNot Nothing AndAlso String.Equals(Session("org_id"), "EU10") Then
                    SB.AppendFormat("  and (fact_zone='Europe' or (fact_zone = 'D&MS(E2E)' and org like 'E%'))  ")
                End If
                SB.AppendFormat(" and eur<>0  ")
                SB.AppendFormat(" group by month(efftive_date) order by month(efftive_date)  ")
                sqlBackorder= SB.ToString
                'Dim sqlBackorder2 As String = String.Format("select month(due_date) as m, sum({1}) as Amount from EAI_SALE_FACT_NEW where " & _
                '                                               "Customer_Id='{0}' and tran_type='Backlog' and fact_1234=1 and factyear='" & item.Value & "' and eur<>0 " & _
                '                                               "group by month(due_date) order by month(due_date)", Session("company_id"), ddlCurr.SelectedValue)
                'Dim sqlBackorder As String = String.Format("select Month_id as m,  Amount from MyDashboard where " & _
                '                                 "CustomerID='{0}' and Category='Backorder' and Mony='" & itlist & "' and itYear='" & item.Value & "'  " & _
                '                                 "order by Month_id", Session("company_id"))
               
                Dim sqlOrderEntry As String = String.Format("select month(b.order_date) as m, sum(a.unit_price*a.qty) as Amount" & _
                                                            " from order_detail a inner join order_master b on a.order_id=b.order_id " & _
                                                            "where b.soldto_id='{0}' and year(b.order_date)>='" & item.Value & "' group by month(b.order_date)" & _
                                                            " order by month(b.order_date)", Session("company_id"))
                'Dim sqlInvoice As String = String.Format("select month(efftive_date) as m, sum({1}) as Amount from g_sale_fact where " & _
                '                                            "Customer_Id='{0}' and tran_type='Shipment' and fact_1234=1 " & _
                '                                            "and year(efftive_date)='" & item.Value & "' " & _
                '                                            " and sam_sw='N' and dec01>=0 and sale_type='AESC'" & _
                '                                            "and eur<>0 and bomseq>=0 and qty<>0 " & _
                '                                            "group by month(efftive_date) order by month(efftive_date)", Session("company_id"), ddlCurr.SelectedValue)
                'Dim sqlInvoice As String = String.Format("select month(efftive_date) as m, sum({1}) as Amount from g_sale_fact where " & _
                '                                  "Customer_Id='{0}' and tran_type='Shipment' and fact_1234=1 " & _
                '                                  "and year(efftive_date)='" & item.Value & "' " & _
                '                                  "and dec01>=0 and (fact_zone='Europe' or (fact_zone = 'D&MS(E2E)' and org like 'E%')) " & _
                '                                  "and eur<>0 and bomseq>=0  and qty<>0 " & _
                '                                  "group by month(efftive_date) order by month(efftive_date)", Session("company_id"), ddlCurr.SelectedValue)
                Dim sqlInvoice As String = String.Empty
                Dim SBInvoice As New StringBuilder
                SBInvoice.AppendFormat(" select month(efftive_date) as m, sum({0}) as Amount from g_sale_fact where ", ddlCurr.SelectedValue)
                SBInvoice.AppendFormat(" Customer_Id='{0}' and tran_type='Shipment' and fact_1234=1  ", Session("company_id"))
                SBInvoice.AppendFormat(" and year(efftive_date)='{0}'  and dec01>=0 ", item.Value)
                'ICC 2015/1/9 Remove this sql to ensure getting data from eai
                'If Session("org_id") IsNot Nothing AndAlso String.Equals(Session("org_id"), "EU10") Then
                '    SBInvoice.AppendFormat("  and (fact_zone='Europe' or (fact_zone = 'D&MS(E2E)' and org like 'E%'))  ")
                'End If
                SBInvoice.AppendFormat(" and eur<>0   and bomseq>=0  and qty<>0")
                SBInvoice.AppendFormat(" group by month(efftive_date) order by month(efftive_date) ")
                sqlInvoice = SBInvoice.ToString
                
                Dim aclSqlInvoice As String = String.Format("select month(due_date) as m, sum({1}) as Amount from eai_sale_fact where " & _
                                                            "Customer_Id='{0}' and sam_sw='N' and year(due_date)='" & item.Value & "' " & _
                                                            "and tran_type='Shipment' and fact_1234=1 and factyear='" & item.Value & "' and sale_type='ACL-FOB' and eur<>0 and bomseq>=0" & _
                                                            "group by month(due_date) order by month(due_date) ", Session("company_id"), ddlCurr.SelectedValue)
                
                'Dim aclSqlInvoice As String = String.Format("select Month_ID as m, Amount from MyDashboard where " & _
                '                                           "CustomerID='{0}' and Mony='" & itlist & "'  and Category='aclSqlInvoice' and itYear='" & item.Value & "' " & _
                '                                            "order by Month_ID", Session("company_id"))
                
                
                Dim dbcmd1 As SqlClient.SqlCommand = Nothing, _
                dbcmd2 As SqlClient.SqlCommand = Nothing, _
                dbcmd3 As SqlClient.SqlCommand = Nothing, _
                dbcmd4 As SqlClient.SqlCommand = Nothing
                Dim ia1 As IAsyncResult = dbUtil.dbGetReaderAsync("B2B", sqlOrderEntry, conn1, dbcmd1)
                'Dim ia2 As IAsyncResult = dbUtil.dbGetReaderAsync("RFM", sqlBackorder, conn1, dbcmd2)
                Dim ia2 As IAsyncResult = dbUtil.dbGetReaderAsync("MY", sqlBackorder, conn1, dbcmd2)
                Dim ia3 As IAsyncResult = dbUtil.dbGetReaderAsync("eai", sqlInvoice, conn1, dbcmd3)
                'Dim ia4 As IAsyncResult = dbUtil.dbGetReaderAsync("RFM", aclSqlInvoice, conn1, dbcmd4)
                Dim ia4 As IAsyncResult = dbUtil.dbGetReaderAsync("MY", aclSqlInvoice, conn1, dbcmd4)
                'MailUtil.SendEmail("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn", "sqlBackorder", sqlBackorder.ToString, False, "", "")
                'MailUtil.SendEmail("ming.zhao@advantech.com.cn", "ming.zhao@advantech.com.cn", "aclSqlInvoice", aclSqlInvoice.ToString, False, "", "")
                ia1.AsyncWaitHandle.WaitOne() : ia2.AsyncWaitHandle.WaitOne() _
                : ia3.AsyncWaitHandle.WaitOne() : ia4.AsyncWaitHandle.WaitOne()
                Dim oeDt As DataTable = dbUtil.Reader2DataTable(dbcmd1.EndExecuteReader(ia1)), _
                boDt As DataTable = dbUtil.Reader2DataTable(dbcmd2.EndExecuteReader(ia2)), _
                invDt As DataTable = dbUtil.Reader2DataTable(dbcmd3.EndExecuteReader(ia3)), _
                ACLinvDt As DataTable = dbUtil.Reader2DataTable(dbcmd4.EndExecuteReader(ia4))
                If ACLinvDt.Rows.Count > 0 Then
                    aclPerfFlag = 1
                End If
                conn1.Close()
                For Each r As DataRow In oeDt.Rows
                    DataOrderEntry(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                Next
                For Each r As DataRow In boDt.Rows
                    dataBackOrder(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                Next
                For Each r As DataRow In invDt.Rows
                    dataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                Next
                If aclPerfFlag = 1 Then
                    For Each r As DataRow In ACLinvDt.Rows
                        ACLDataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                    Next
                End If
                
                'Set ScoreBoard
                Dim invR As DataRow = scoreDt.NewRow(), ACLinvR As DataRow = scoreDt.NewRow(), oeR As DataRow = scoreDt.NewRow, boR As DataRow = scoreDt.NewRow
                oeR.Item(0) = "Order Entry" : oeR.Item(1) = item.Value : boR.Item(0) = "Back Order" : boR.Item(1) = item.Value : invR.Item(0) = "Shipment" : invR.Item(1) = item.Value
                If aclPerfFlag = 1 Then
                    ACLinvR.Item(0) = "Shipment(ACL)" : ACLinvR.Item(1) = item.Value
                End If
                For i As Integer = 2 To 13
                    oeR.Item(i) = DataOrderEntry(i - 2) : boR.Item(i) = dataBackOrder(i - 2) _
                  : invR.Item(i) = dataPerf(i - 2)
                    If aclPerfFlag = 1 Then
                        ACLinvR.Item(i) = ACLDataPerf(i - 2)
                    End If
                Next
                oeR.Item(14) = 0 : boR.Item(14) = 0 : invR.Item(14) = 0
                If aclPerfFlag = 1 Then
                    ACLinvR.Item(14) = 0
                End If
                With scoreDt.Rows
                    .Add(oeR) : .Add(boR) : .Add(invR)
                    If aclPerfFlag = 1 Then
                        .Add(ACLinvR)
                    End If
                End With
                
                'Set Chart
                With layer
                    .setLineWidth(2) _
                  : .addDataSet(dataPerf, GetLineColor(item.Value, "Performance"), item.Value + " Performance").setDataSymbol(Chart.DiamondSymbol, 6, GetLineColor(item.Value, "Performance")) _
                  : .addDataSet(dataBackOrder, GetLineColor(item.Value, "Backlog"), item.Value + " Backlog").setDataSymbol(Chart.CrossSymbol, 6, GetLineColor(item.Value, "Backlog")) _
                  : .addDataSet(DataOrderEntry, GetLineColor(item.Value, "Order Entry"), item.Value + " Order Entry").setDataSymbol(Chart.CrossSymbol, 6, GetLineColor(item.Value, "Order Entry"))
                    If aclPerfFlag = 1 Then .addDataSet(ACLDataPerf, GetLineColor(item.Value, "Performance of ACL"), item.Value + " Performance of ACL").setDataSymbol(Chart.CrossSymbol, 6, GetLineColor(item.Value, "Performance of ACL"))
                End With
                If Request("PDFFlag") Is Nothing Then
        
                Else
                    Dim filechart1 As String = c.makeTmpFile(Server.MapPath("/tmp_chart"))
                    'Me.ChartImage1.ImageUrl = "../tmp_chart/" & filechart1
                End If
                'output the chart
                
                
            End If
        Next
        Dim dv As DataView = scoreDt.DefaultView
        dv.Sort = "Category desc"
        Me.gvCustPerf.DataSource = dv.ToTable : Me.gvCustPerf.DataBind()
        WebChartViewer1.Image = c.makeWebImage(Chart.PNG) : WebChartViewer1.ImageMap = c.getHTMLImageMap("", "", "title='[{dataSetName}] Month {xLabel}: {value} Account'")
        Dim sw As New IO.StringWriter, htw As HtmlTextWriter = New HtmlTextWriter(sw)
        WebChartViewer1.RenderControl(htw)
        'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "", WebChartViewer1.ImageSessionId + "," + WebChartViewer1.ImageUrl, False, "", "")
    End Sub
    
    Private Function GetLineColor(ByVal year As String, ByVal category As String) As Integer
        Select Case year
            Case cblYear.Items(0).Value
                Select Case category
                    Case "Performance"
                        Return &HCC00
                    Case "Backlog"
                        Return &HDE0023
                    Case "Order Entry"
                        Return &HFF9900
                    Case "Performance of ACL"
                        Return &HFF
                End Select
            Case cblYear.Items(1).Value
                Select Case category
                    Case "Performance"
                        Return &H9900FF
                    Case "Backlog"
                        Return &HA0BDC4
                    Case "Order Entry"
                        Return &HFFFF00
                    Case "Performance of ACL"
                        Return &H808080
                End Select
            Case cblYear.Items(2).Value
                Select Case category
                    Case "Performance"
                        Return &H2284CC
                    Case "Backlog"
                        Return &HF423B3
                    Case "Order Entry"
                        Return &H38A966
                    Case "Performance of ACL"
                        Return &H7823F3
                End Select
            Case cblYear.Items(3).Value
                Select Case category
                    Case "Performance"
                        Return &H66A9D5
                    Case "Backlog"
                        Return &HFF1800
                    Case "Order Entry"
                        Return &H5E5340
                    Case "Performance of ACL"
                        Return &H70FF
                End Select
        End Select
    End Function
    
    Protected Sub gvCustPerf_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim i As Integer = 1
        For Each wkItem As GridViewRow In gvCustPerf.Rows
            If wkItem.RowIndex <> 0 Then
                If wkItem.Cells(0).Text.Trim() = gvCustPerf.Rows((wkItem.RowIndex - i)).Cells(0).Text.Trim() Then
                    gvCustPerf.Rows((wkItem.RowIndex - i)).Cells(0).RowSpan += 1
                    wkItem.Cells(0).Visible = False
                    i = i + 1
                Else
                    gvCustPerf.Rows((wkItem.RowIndex)).Cells(0).RowSpan = 1
                    i = 1
                End If
            Else
                wkItem.Cells(0).RowSpan = 1
            End If
        Next
    End Sub
    
    Private Function GetCurrency() As String
        If ddlCurr.SelectedValue = "EUR" Then Return "&euro;"
        Return "$"
    End Function

    Protected Sub btnMyPrice_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("~/order/Price_List.aspx")
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <table width="100%">
        <tr>
            <td style="width:20%" valign="top">
                <table width="100%">
                    <tr>
                        <td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0" style="border:#CCCCCC 1px solid">
                                 <tr>
                                    <td height="22" valign="middle" bgcolor="C7D5F1" class="text">
			                            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table3">
				                            <tr>
					                            <td width="190" align="center"><b><font color="2D56A7" size="2pt">Customer Profile</font></b></td>
				                            </tr>
			                            </table>          
                                    </td>
                                 </tr>
                                 <tr>
                                     <td bgcolor="F7F7F7">
                                         <table id="DashLmenu1_CustomerProfile" cellspacing="0" cellpadding="0" border="0" class="text" border="0" style="width:100%;border-collapse:collapse;">
	                                        <tr>
		                                        <td colspan="2" style="height:1px;class="text" align="center" bgcolor="#F7F7F7"">&nbsp;</td>
	                                        </tr>
	                                        <tr>
		                                        <td colspan="2" style="class="text" align="center" bgcolor="#F7F7F7"">
		                                            <font color="#333333"><b><asp:Literal runat="server" ID="ltCustName" /></b></font>
		                                        </td>
	                                        </tr>
	                                        <tr>
		                                        <td colspan="2" style="class="text" align="center" bgcolor="#F7F7F7"">
		                                            <font color="#333333"><b>( <%=Session("company_id")%> )</b></font>
		                                        </td>
	                                        </tr>	                                       
	                                        <tr valign="middle" style="height:20px;">
		                                        <td class="text" align="right" bgcolor="#F7F7F7" valign="top">
		                                            <font color="#7F7F7F">&nbsp;<b>Addr.:</b>&nbsp;</font>
		                                        </td>
		                                        <td class="text" align="left" bgcolor="#F7F7F7" valign="top">
		                                            <font color="#6666CC">
		                                                <asp:Literal runat="server" ID="ltCustAddr" />    
		                                            </font>
		                                        </td>
	                                        </tr>
	                                        <tr runat="server" visible="false" id="WeatherRow">
	                                            <td colspan="2" align="center">
	                                                <table width="80%">
	                                                    <tr>
	                                                        <td align="left">
	                                                            <table width="100%">
	                                                                <tr><td> <b><asp:Literal runat="server" ID="ltCity" /></b></td></tr>
	                                                                <tr><td><asp:Literal runat="server" ID="ltCond" /></td></tr>
	                                                                <tr><td><asp:Literal runat="server" ID="ltTemp" /> °C</td></tr>
	                                                                <tr><td><asp:Literal runat="server" ID="ltHumid" /></td></tr>
	                                                                <tr><td><asp:Literal runat="server" ID="ltWind" /> </td></tr>
	                                                            </table>
	                                                        </td>
	                                                        <td valign="bottom"><asp:Image runat="server" ID="imgIcon" /></td>
	                                                    </tr>
	                                                </table>	
	                                            </td>
	                                        </tr>
	                                        <tr valign="middle" style="height:20px;display:none;">
		                                        <td class="text" align="right" bgcolor="#F7F7F7" valign="top"> <font color="#7F7F7F">&nbsp;<b>URL:</b>&nbsp;</font></td>
		                                        <td class="text" align="left" bgcolor="#F7F7F7" valign="top"> <font color="#6666CC"><asp:Literal runat="server" ID="ltCustUrl" /></font></td>
	                                        </tr>
	                                  
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                                 <uc8:ChgComp runat="server" ID="ChgComp1" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%" style="background-color:#E5ECF9">
                                <tr>
                                    <td align="center" style="background-color: #ffffff" height="25" valign="middle">
                                        <asp:HyperLink runat="server" ID="lnkBigCalender" Text="Shipping Calendar" NavigateUrl="~/Order/ShippingCalendar.aspx"
                                            Target="_blank"   Font-Size="Small" ForeColor="#2D56A7" Font-Bold="true"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" style="background-color: #ffffff" height="25" valign="middle">
                                    <asp:hyperlink runat="server" ID="hlOpenOrderStatus" NavigateUrl="~/Order/BO_BackOrderInquiry.aspx" Text="Open Order Status" Font-Size="Small"   Target="_blank"  ForeColor="#2D56A7" Font-Bold="true" />
                                    </td>
                                </tr>
                                  <tr>
                                    <td align="center" style="background-color: #ffffff" height="25" valign="middle">
                                    <asp:hyperlink runat="server" ID="hlBillingInformation" NavigateUrl="~/Order/BO_InvoiceInquiry.aspx"     Text="Billing Information" Font-Size="Small"   Target="_blank"  ForeColor="#2D56A7" Font-Bold="true" />
                                    </td>
                                </tr>
                                  <tr>
                                    <td align="center" style="background-color: #ffffff" height="25" valign="middle">
                                    <asp:hyperlink runat="server" ID="hlAPInquiry" NavigateUrl="~/Order/ARInquiry_WS.aspx"   Target="_blank"  Text="Over Due A/P Status" Font-Size="Small" ForeColor="#2D56A7" Font-Bold="true" />
                                    </td>
                                </tr>
                                  <tr>
                                    <td align="center" style="background-color: #ffffff" height="25" valign="middle">
                                    <asp:hyperlink runat="server" ID="hlRMATracking" NavigateUrl="~/Order/MyRMA.aspx"   Target="_blank"  Text="Open RMA Tracking" Font-Size="Small" ForeColor="#2D56A7" Font-Bold="true" />
                                    </td>
                                </tr>
                            </table>                                                   
                        </td>
                    </tr>                    
                </table>
            </td>
            <td style="width:80%" valign="top">
            <table width="100%"><tr>
                        <td style="font-family:Arial;">
                            <h2>My Dashboard</h2>
                        </td>
                        <td align="right"><table><tr>
                         <td align="right" valign="top">
                            <table>
                                <tr>
                                    <td valign="top"><font color="#d7cece">Export shipment detail to XLS by year</font></td>
                                    <td valign="top"><asp:ImageButton runat="server" ID="BtnSave2Excel" OnClick ="Export2XLS" ImageUrl="~/images/excel.gif" ToolTip="Save To Excel"/></td>    
                                    <td><b>Currency : </b></td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="ddlCurr">
                                            <asp:ListItem Text="EUR" Value="EUR"></asp:ListItem>
                                            <asp:ListItem Text="US" Value="Us_Amt"></asp:ListItem>
                                        </asp:DropDownList>
                                    </td>
                                    <td><b>Year : </b> </td>
                                    <td>
                                        <asp:CheckBoxList runat="server" ID="cblYear" RepeatDirection="Horizontal">
                                         <%--<asp:ListItem Text="2015" Value="2015"></asp:ListItem>
                                         <asp:ListItem Text="2014" Value="2014" ></asp:ListItem>
                                         <asp:ListItem Text="2013" Value="2013"  Selected="True"></asp:ListItem>
                                        <asp:ListItem Text="2012" Value="2012"></asp:ListItem>--%>
                                        <%-- <asp:ListItem Text="2011" Value="2011" ></asp:ListItem>
                                    <asp:ListItem Text="2010" Value="2010" ></asp:ListItem>--%>
                                        </asp:CheckBoxList>
                                    </td>
                                    <td><asp:Button runat="server" ID="btnSearch"  Text="Go" OnClick="btnSearch_Click" /></td>
                                </tr>
                            </table>
                        </td> 
                        </tr></table>
                        </td>                    
                    </tr></table>
                <span id="gridspan">
                    <asp:Panel ID="testP" runat="server" Visible="false">
                        <asp:UpdatePanel runat="server" ID="upCenter">
                            <ContentTemplate>
                                <table width="100%">
                                    <tr><td align="center" colspan="2"> <chartdir:WebChartViewer runat="server" ID="WebChartViewer1"/></td> </tr>
                                    <tr>
                                        <td colspan="2">
                                            <table class="text" width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#C7D5F1">
                                                <tr>
                                                    <td bgcolor="#ECECEC" width="100%" height="20px">
                                                        <div><font color="#333333" size="2"><b>&nbsp;Customer Information</b></font></div>
                                                    </td>
                                                    <td bgcolor="#ECECEC" width="100%" height="20px" align="right">
                                                        <font color="666666">(amount unit = 1000<%=GetCurrency()%>)</font>&nbsp; &nbsp;&nbsp;
                                                        <asp:ImageButton runat="server" ID="BtnSave2PDF" Visible="false" ImageUrl="~/images/pdf_icon.jpg" ToolTip="Save To PDF"/>&nbsp;&nbsp;&nbsp;
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td width="100%" colspan="2">
                                                        <asp:GridView runat="server" ID="gvCustPerf" AutoGenerateColumns="false" Font-Names="Verdana" Font-Size="7pt" width="100%" OnRowDataBound="gvCustPerf_RowDataBound" OnRowCreated="gvCustPerf_RowCreated" OnPreRender="gvCustPerf_PreRender">
                                                            <Columns>
                                                                <asp:BoundField ItemStyle-Width="110px" DataField="category" HeaderText="Category" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle01" />
                                                                <asp:BoundField ItemStyle-Width="30px" DataField="year" HeaderText="Year" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle01" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Jan" HeaderText="Jan" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Feb" HeaderText="Feb" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Mar" HeaderText="Mar" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Apr" HeaderText="Apr" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="May" HeaderText="May" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Jun" HeaderText="Jun" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Jul" HeaderText="Jul" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Aug" HeaderText="Aug" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Sep" HeaderText="Sep" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Oct" HeaderText="Oct" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Nov" HeaderText="Nov" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:BoundField HeaderStyle-Width="30px" DataField="Dec" HeaderText="Dec" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                                <asp:HyperLinkField DataNavigateUrlFields="url" DataTextField="ytd" HeaderText="YTD" HeaderStyle-CssClass="hdrstyle02" ItemStyle-CssClass="rodstyle02" />
                                                            </Columns>
                                                        </asp:GridView>
                                                         
                                                    </td>
                                                </tr>
                                            </table>
                                            <asp:Button runat="server" ID="btnMyPrice" Text="Get My Price List" OnClick="btnMyPrice_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </asp:Panel>
                </span> 
            </td>

        </tr>
    </table>
    <script type="text/javascript">
 
       
 var a = document.getElementById("ifmm"); 
 var b = document.getElementById("load"); 
     a.style.display = "none";
     b.style.display = "block";  
    function stateChangeIE(_frame)
    { 
     if (_frame.readyState=="complete")//state: loading ,interactive,   complete
     {
       var loader = document.getElementById("load"); 
        loader.innerHTML = "load complete!"; 
        loader.style.display = "none"; 
        _frame.style.display = "block";   
     }   
    }
    function stateChangeFirefox(_frame)
    { 
       var loader = document.getElementById("load"); 
       
        loader.innerText      = "load complete!";    
        loader.style.display = "none"; 
        _frame.style.visibility = "visible";   
        _frame.style.display = "block";   
    }
    //callframe.location.href=""; 
	a.src="shippingcalendariframe.aspx"; 

    </script>
</asp:Content>