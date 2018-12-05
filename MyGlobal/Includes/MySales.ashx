<%@ WebHandler Language="VB" Class="MySales" %>

Imports System
Imports System.Web
Imports System.Web.SessionState
Public Class MySales : Implements IHttpHandler, IReadOnlySessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If context.Request("Year") Is Nothing OrElse context.Request("Currency") Is Nothing OrElse context.Request("uid") Is Nothing Then Exit Sub
        Dim bs() As Byte = GetMyPerfImgUrl(context.Request("Year"), context.Request("Currency"), context.Request("uid"))
        If bs IsNot Nothing AndAlso bs.Length > 0 Then
            context.Response.BinaryWrite(bs)
            context.Response.End()
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
    Public Shared Function GetMyPerfImgUrl(ByVal pYear As Integer, ByVal cur As String, ByVal AdminUId As String) As Byte()
        'HttpContext.Current.Session("user_id") = "christoph.kuehn@advantech.de"
        Dim uid As String = ""
        If HttpContext.Current.Session Is Nothing _
        OrElse HttpContext.Current.Session("user_id") = "" _
        OrElse HttpContext.Current.Session("user_id").ToString.ToLower() Like "*@advantech*.*" = False _
        OrElse HttpContext.Current.Session("user_id") Like "*@*.*" = False Then
            Return Nothing
        End If
        uid = HttpContext.Current.Session("user_id")
        If Util.IsAdmin() Then uid = "christoph.kuehn@advantech.eu"
        If Util.IsAdmin() AndAlso AdminUId <> "" Then
            uid = Trim(AdminUId).Replace("'", "''")
        End If
        Dim salesid As String = Util.GetSalesID(uid)
        If salesid Is Nothing Then Return Nothing
        Dim labels() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
        If False Then
            labels = New String() {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"}
        End If
        Dim c As New ChartDirector.XYChart(750, 400, &HFFFFFF, &HC7D5F1)
        If False Then
            c = New ChartDirector.XYChart(232, 220, &HFFFFFF, &HC7D5F1)
        End If
        With c
            .setPlotArea(60, 20, 630, 320, &HFFFFFF, -1, -1, &HC0C0C0, -1)
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
                Dim aclPerfFlag As Integer = 0
                Dim itlist As String = cur
                Dim sqlInvoice As String = String.Format("select month(efftive_date) as m, sum({1}) as Amount from eai_sale_fact where " & _
                                                            "sales_id='{0}' and tran_type='Shipment' and fact_1234=1 " & _
                                                            "and year(efftive_date)='" & item.Value & "' " & _
                                                            "group by month(efftive_date) order by month(efftive_date)", salesid, itlist)
                Dim invDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                                                                " select month(efftive_date) as m, sum({1}) as Amount from eai_sale_fact where " & _
                                                                " sales_id='{0}' and tran_type='Shipment' and fact_1234=1 " & _
                                                                " and factyear='" & item.Value & "' " & _
                                                                " group by month(efftive_date) order by month(efftive_date)", salesid, itlist))
                For Each r As DataRow In invDt.Rows
                    dataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
                Next
                Dim invR As DataRow = scoreDt.NewRow(), ACLinvR As DataRow = scoreDt.NewRow(), oeR As DataRow = scoreDt.NewRow, boR As DataRow = scoreDt.NewRow
                oeR.Item(0) = "Order Entry" : oeR.Item(1) = item.Value : boR.Item(0) = "Back Order" : boR.Item(1) = item.Value : invR.Item(0) = "Shipment" : invR.Item(1) = item.Value
                If aclPerfFlag = 1 Then
                    ACLinvR.Item(0) = "Shipment(ACL)" : ACLinvR.Item(1) = item.Value
                End If
                For i As Integer = 2 To 13
                    invR.Item(i) = dataPerf(i - 2)
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
                With layer
                    .set3D(15)
                    .setBarShape(ChartDirector.Chart.CircleShape)
                    .addDataSet(dataPerf, GetLineColor(item.Value, "Performance"), "My " + item.Value + " Performance").setDataSymbol(ChartDirector.Chart.DiamondSymbol, 6, GetLineColor(item.Value, "Performance"))
                   
                End With
            End If
        Next
       
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