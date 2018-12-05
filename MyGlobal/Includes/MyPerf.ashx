<%@ WebHandler Language="VB" Class="MyPerf" %>

Imports System
Imports System.Web
Imports System.Web.SessionState
Public Class MyPerf : Implements IHttpHandler, IReadOnlySessionState
    
    
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.BinaryWrite(GetMyPerfImgUrl(context.Request("Year"), context.Request("Currency")))
        'context.Response.Write(context.Session("company_id"))
        context.Response.End()
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
    Public Shared Function GetMyPerfImgUrl(ByVal pYear As Integer, ByVal cur As String) As Byte()
        Dim labels() As String = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"}
        Dim c As New ChartDirector.XYChart(232, 200, &HFFFFFF, &HC7D5F1)
        With c
            .setPlotArea(48, 20, 170, 157, &HFFFFFF, -1, -1, &HC0C0C0, -1)
            .addLegend(35, 20, False, "", 8).setBackground(ChartDirector.Chart.Transparent)
            .addTitle("", "Arial Bold Italic", 11, &H333333).setBackground(&HECECEC, &HC7D5F1)
            .yAxis().setTitle("Amount (Unit=1K)") : .xAxis().setLabels(labels) : .xAxis().setTitle(" ")
        End With
        Dim layer As ChartDirector.BarLayer = c.addBarLayer()
        Dim scoreDt As New DataTable
        With scoreDt.Columns
            .Add("Category") : .Add("Year")
            For Each strMNonth As String In labels
                .Add(strMNonth, Type.GetType("System.Double"))
            Next
            .Add("YTD", Type.GetType("System.Double")) : .Add("url")
        End With
        Dim cblYear As New DropDownList
        With cblYear.Items
            .Add(New ListItem(pYear, pYear))
        End With
        cblYear.Items(0).Selected = True
        For Each item As ListItem In cblYear.Items
            If item.Selected Then
                Dim dataPerf() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                'Dim dataBackOrder() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                'Dim DataOrderEntry() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                'Dim ACLDataPerf() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                Dim aclPerfFlag As Integer = 0
                Dim conn1 As System.Data.SqlClient.SqlConnection = Nothing
                Dim itlist As String = cur
                'If ddlCurr.SelectedValue = "EUR" Then
                '    itlist = "EUR"
                'Else
                '    itlist = "Us_Amt"
                'End If
                'Dim sqlBackorder As String = String.Format("select Month_id as m,  Amount from MyDashboard where " & _
                '                                 "CustomerID='{0}' and Category='Backorder' and Mony='" & itlist & "' and itYear='" & item.Value & "'  " & _
                '                                 "order by Month_id", HttpContext.Current.Session("company_id"))
                'Dim sqlOrderEntry As String = String.Format("select month(b.order_date) as m, sum(a.unit_price*a.qty) as Amount" & _
                '                                            " from order_detail a inner join order_master b on a.order_id=b.order_id " & _
                '                                            "where b.soldto_id='{0}' and year(b.order_date)>='" & item.Value & "' group by month(b.order_date)" & _
                '                                            " order by month(b.order_date)", HttpContext.Current.Session("company_id"))
                Dim sqlInvoice As String = String.Format("select month(efftive_date) as m, sum({1}) as Amount from g_sale_fact where " & _
                                                            "Customer_Id='{0}' and tran_type='Shipment' and fact_1234=1 " & _
                                                            "and year(efftive_date)='" & item.Value & "' " & _
                                                            "and dec01>=0 " & _
                                                            "and bomseq>=0 " & _
                                                            "group by month(efftive_date) order by month(efftive_date)", HttpContext.Current.Session("company_id"), itlist)
                'Dim aclSqlInvoice As String = String.Format("select Month_ID as m, Amount from MyDashboard where " & _
                '                                           "CustomerID='{0}' and Mony='" & itlist & "'  and Category='aclSqlInvoice' and itYear='" & item.Value & "' " & _
                '                                            "order by Month_ID", HttpContext.Current.Session("company_id"))
                
                
                Dim dbcmd1 As System.Data.SqlClient.SqlCommand = Nothing, _
                dbcmd2 As System.Data.SqlClient.SqlCommand = Nothing, _
                dbcmd3 As System.Data.SqlClient.SqlCommand = Nothing, _
                dbcmd4 As System.Data.SqlClient.SqlCommand = Nothing
                'Dim ia1 As IAsyncResult = dbUtil.dbGetReaderAsync("B2B", sqlOrderEntry, conn1, dbcmd1)
                'Dim ia2 As IAsyncResult = dbUtil.dbGetReaderAsync("RFM", sqlBackorder, conn1, dbcmd2)
                'Dim ia2 As IAsyncResult = dbUtil.dbGetReaderAsync("MY", sqlBackorder, conn1, dbcmd2)
                Dim ia3 As IAsyncResult = dbUtil.dbGetReaderAsync("eai", sqlInvoice, conn1, dbcmd3)
                'Dim ia4 As IAsyncResult = dbUtil.dbGetReaderAsync("RFM", aclSqlInvoice, conn1, dbcmd4)
                'Dim ia4 As IAsyncResult = dbUtil.dbGetReaderAsync("MY", aclSqlInvoice, conn1, dbcmd4)
                'ia1.AsyncWaitHandle.WaitOne()
                'ia2.AsyncWaitHandle.WaitOne()
                ia3.AsyncWaitHandle.WaitOne()
                'ia4.AsyncWaitHandle.WaitOne()
                'Dim oeDt As DataTable = dbUtil.Reader2DataTable(dbcmd1.EndExecuteReader(ia1)), _
                'boDt As DataTable = dbUtil.Reader2DataTable(dbcmd2.EndExecuteReader(ia2)), _
                Dim invDt As DataTable = dbUtil.Reader2DataTable(dbcmd3.EndExecuteReader(ia3))
                'ACLinvDt As DataTable = dbUtil.Reader2DataTable(dbcmd4.EndExecuteReader(ia4))
                'If ACLinvDt.Rows.Count > 0 Then
                '    aclPerfFlag = 1
                'End If
                conn1.Close()
                'For Each r As DataRow In oeDt.Rows
                '    DataOrderEntry(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                'Next
                'For Each r As DataRow In boDt.Rows
                '    dataBackOrder(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                'Next
                For Each r As DataRow In invDt.Rows
                    dataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                Next
                'If aclPerfFlag = 1 Then
                '    For Each r As DataRow In ACLinvDt.Rows
                '        ACLDataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                '    Next
                'End If
                
                'Set ScoreBoard
                Dim invR As DataRow = scoreDt.NewRow(), ACLinvR As DataRow = scoreDt.NewRow(), oeR As DataRow = scoreDt.NewRow, boR As DataRow = scoreDt.NewRow
                oeR.Item(0) = "Order Entry" : oeR.Item(1) = item.Value : boR.Item(0) = "Back Order" : boR.Item(1) = item.Value : invR.Item(0) = "Shipment" : invR.Item(1) = item.Value
                If aclPerfFlag = 1 Then
                    ACLinvR.Item(0) = "Shipment(ACL)" : ACLinvR.Item(1) = item.Value
                End If
                For i As Integer = 2 To 13
                    'oeR.Item(i) = DataOrderEntry(i - 2) : boR.Item(i) = dataBackOrder(i - 2)
                    invR.Item(i) = dataPerf(i - 2)
                    'If aclPerfFlag = 1 Then
                    '    ACLinvR.Item(i) = ACLDataPerf(i - 2)
                    'End If
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
                    .set3D(5)
                    .setBarShape(ChartDirector.Chart.CircleShape)
                    '.setLineWidth(2)
                    .addDataSet(dataPerf, GetLineColor(item.Value, "Performance"), item.Value + " Performance").setDataSymbol(ChartDirector.Chart.DiamondSymbol, 6, GetLineColor(item.Value, "Performance"))
                    ': .addDataSet(dataBackOrder, GetLineColor(item.Value, "Backlog"), item.Value + " Backlog").setDataSymbol(ChartDirector.Chart.CrossSymbol, 6, GetLineColor(item.Value, "Backlog"))
                    ': .addDataSet(DataOrderEntry, GetLineColor(item.Value, "Order Entry"), item.Value + " Order Entry").setDataSymbol(ChartDirector.Chart.CrossSymbol, 6, GetLineColor(item.Value, "Order Entry"))
                    'If aclPerfFlag = 1 Then .addDataSet(ACLDataPerf, GetLineColor(item.Value, "Performance of ACL"), item.Value + " Performance of ACL").setDataSymbol(ChartDirector.Chart.CrossSymbol, 6, GetLineColor(item.Value, "Performance of ACL"))
                End With
                
                
            End If
        Next
        'Dim dv As DataView = scoreDt.DefaultView
        'dv.Sort = "Category desc"
        'Me.gvCustPerf.DataSource = dv.ToTable : Me.gvCustPerf.DataBind()
       
        Dim WebChartViewer1 As New ChartDirector.WebChartViewer
        WebChartViewer1.Image = c.makeWebImage(ChartDirector.Chart.PNG)
        WebChartViewer1.ImageMap = c.getHTMLImageMap("", "", "title='[{dataSetName}] Month {xLabel}: {value} Account'")
        Return WebChartViewer1.Image.image
    End Function
    
        
    Public Shared Function GetLineColor(ByVal year As String, ByVal category As String) As Integer
        Select Case year
            Case 2010
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
            Case 2009
                Select Case category
                    Case "Performance"
                        Return &HDE0023
                    Case "Backlog"
                        Return &HA0BDC4
                    Case "Order Entry"
                        Return &HFFFF00
                    Case "Performance of ACL"
                        Return &H808080
                End Select
            Case 2008
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
        End Select
    End Function

End Class