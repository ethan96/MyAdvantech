<%@ WebHandler Language="VB" Class="CustChart" %>

Imports System
Imports System.Web

Public Class CustChart : Implements IHttpHandler, IReadOnlySessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If HttpContext.Current.Session Is Nothing _
        OrElse HttpContext.Current.Session("user_id") = "" _
        OrElse HttpContext.Current.Session("user_id").ToString.ToLower() Like "*@advantech*.*" = False _
        OrElse HttpContext.Current.Session("user_id") Like "*@*.*" = False Then
            Exit Sub
        End If
        If context.Request("ROWID") IsNot Nothing AndAlso context.Request("ROWID").ToString() <> "" _
            AndAlso context.Request("Year") IsNot Nothing AndAlso context.Request("Year").ToString() <> "" Then
            Dim pYear As String = context.Request("Year").ToString()
            Dim rowid As String = HttpUtility.UrlEncode(context.Request("ROWID").ToString().Trim())
            Dim erpid As String = ""
            Dim erpDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 b.COMPANY_ID from SIEBEL_ACCOUNT a inner join SAP_DIMCOMPANY b on a.ERP_ID=b.COMPANY_ID where a.ROW_ID='{0}'", rowid.Replace("'", "")))
            If erpDt.Rows.Count = 1 Then
                erpid = erpDt.Rows(0).Item("company_id")
            End If
            Dim labels() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
            Dim c As New ChartDirector.XYChart(870, 400, &HFFFFFF, &HC7D5F1)
            With c
                .setPlotArea(60, 20, 780, 320, &HFFFFFF, -1, -1, &HC0C0C0, -1)
                If False Then
                    .setPlotArea(43, 20, 170, 157, &HFFFFFF, -1, -1, &HC0C0C0, -1)
                End If
                .addLegend(75, 20, False, "", 8).setBackground(ChartDirector.Chart.Transparent)
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
                    Dim optyPerf() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                    Dim aclPerfFlag As Integer = 0
                    Dim itlist As String = "US_AMT"
                    If context.Request("Curr") IsNot Nothing Then itlist = context.Request("Curr").ToString().Trim().Replace("'", "''")
                    If erpid <> "" Then
                        Dim invDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                                                                   " select month(efftive_date) as m, sum({1}) as Amount from eai_sale_fact where " & _
                                                                   " customer_id='{0}' and tran_type='Shipment' and fact_1234=1 " & _
                                                                   " and factyear='" & item.Value & "' " & _
                                                                   " group by month(efftive_date) order by month(efftive_date)", erpid, itlist))
                        For Each r As DataRow In invDt.Rows
                            dataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                        Next
                        With layer
                            .set3D(15)
                            .setBarShape(ChartDirector.Chart.CircleShape)
                            .addDataSet(dataPerf, GetLineColor(item.Value, "Performance"), "Customer " + item.Value + " Performance").setDataSymbol(ChartDirector.Chart.DiamondSymbol, 6, GetLineColor(item.Value, "Performance"))
                        End With
                    End If
                    If rowid <> "" Then
                        Dim optyDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                                                                        " select month(created) as m, sum(SUM_REVN_AMT) as Amount  " + _
                                                                        " from SIEBEL_OPPORTUNITY  " + _
                                                                        " where ACCOUNT_ROW_ID='{0}' and CREATE_YEAR='{1}'   " + _
                                                                        " group by month(created) order by month(created) ", rowid, item.Value))
                        For Each r As DataRow In optyDt.Rows
                            optyPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                        Next
                        With layer
                            .set3D(15)
                            .setBarShape(ChartDirector.Chart.CircleShape)
                            .addDataSet(optyPerf, GetLineColor(item.Value, "Opportunity"), "Customer " + item.Value + " Opportunity").setDataSymbol(ChartDirector.Chart.DiamondSymbol, 6, GetLineColor(item.Value, "Opportunity"))
                        End With
                    End If
                End If
            Next
       
            Dim WebChartViewer1 As New ChartDirector.WebChartViewer
            WebChartViewer1.Image = c.makeWebImage(ChartDirector.Chart.PNG)
            WebChartViewer1.ImageMap = c.getHTMLImageMap("", "", "title='[{dataSetName}] Month {xLabel}: {value} Account'")
            context.Response.BinaryWrite(WebChartViewer1.Image.image)
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
    Public Shared Function GetLineColor(ByVal year As String, ByVal category As String) As Integer
        Select Case year
            Case 2011, 2012
                Select Case category
                    Case "Performance"
                        Return &HCC00
                    Case "Backlog", "Opportunity"
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
                    Case "Backlog", "Opportunity"
                        Return &HA0BDC4
                    Case "Order Entry"
                        Return &HFFFF00
                    Case "Performance of ACL"
                        Return &H808080
                End Select
            Case 2010
                Select Case category
                    Case "Performance"
                        Return &H2284CC
                    Case "Backlog", "Opportunity"
                        Return &HF423B3
                    Case "Order Entry"
                        Return &H38A966
                    Case "Performance of ACL"
                        Return &H7823F3
                End Select
        End Select
        Return &H808080
    End Function

End Class