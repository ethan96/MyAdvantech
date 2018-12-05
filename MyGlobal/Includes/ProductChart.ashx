<%@ WebHandler Language="VB" Class="ProductChart" %>

Imports System
Imports System.Web

Public Class ProductChart : Implements IHttpHandler, IReadOnlySessionState
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        If HttpContext.Current.Session Is Nothing _
        OrElse HttpContext.Current.Session("user_id") = "" Then
            Exit Sub
        End If
        If context.Request("PN") IsNot Nothing AndAlso context.Request("PN").ToString() <> "" _
            AndAlso context.Request("Year") IsNot Nothing AndAlso context.Request("Year").ToString() <> "" _
            AndAlso context.Request("Unit") IsNot Nothing AndAlso context.Request("Unit").ToString() <> "" _
            AndAlso context.Request("Sector") IsNot Nothing AndAlso context.Request("TranType") IsNot Nothing Then
            Dim pYear As String = context.Request("Year").ToString()
            Dim PN As String = HttpUtility.UrlEncode(context.Request("PN").ToString().Trim())
            Dim labels() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
            Dim strTranType As String = "shipment"
            Select Case context.Request("TranType").ToString().Trim()
                Case "1"
                    strTranType = "Shipment"
                Case "2"
                    strTranType = "Backlog"
                Case "3"
                    strTranType = ""
            End Select
            Dim c As New ChartDirector.XYChart(1000, 500, &HFFFFFF, &HC7D5F1)
            With c
                .setPlotArea(60, 20, 900, 380, &HFFFFFF, -1, -1, &HC0C0C0, -1)
                If False Then
                    .setPlotArea(43, 20, 170, 157, &HFFFFFF, -1, -1, &HC0C0C0, -1)
                End If
                .addLegend(75, 20, False, "", 8).setBackground(ChartDirector.Chart.Transparent)
                .addTitle("", "Arial Bold Italic", 11, &H333333).setBackground(&HECECEC, &HC7D5F1)
                If context.Request("Unit").ToString() = "Qty" Then
                    .yAxis().setTitle("Quantity (Unit=pcs)")
                Else
                    .yAxis().setTitle("USD Amount (Unit=1K)")
                End If
                
                .xAxis().setLabels(labels) : .xAxis().setTitle(" ")
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
            Dim tmpOrg As String = ""
            If context.Request("org") IsNot Nothing AndAlso context.Request("org").ToString() <> "" Then
                tmpOrg = context.Request("org").ToString().Trim().Replace("'", "''")
            End If
            For Each item As ListItem In cblYear.Items
                If item.Selected And PN <> "" Then
                    Dim sb As New System.Text.StringBuilder
                    With sb
                        .AppendLine(String.Format(" select month(efftive_date) as m, "))
                        If tmpOrg <> "" Then
                            .AppendLine(String.Format(" left(org,2) as org, "))
                        Else
                            .AppendLine(String.Format(" 'Global' as org, "))
                        End If
                        .AppendLine(String.Format(" sum({0}) as Amount ", context.Request("Unit").ToString().Trim().Replace("'", "''")))
                        .AppendLine(String.Format(" from eai_sale_fact "))
                        .AppendLine(String.Format(" where item_no='{0}' and fact_1234=1 and qty>0    ", PN))
                        .AppendLine(String.Format(" and factyear='{0}'   ", pYear))
                        If context.Request("Sector").ToString() <> "" Then
                            .AppendLine(String.Format(" and sector='{0}' ", context.Request("Sector").ToString().Trim().Replace("'", "''")))
                        End If
                        If strTranType <> "" Then
                            .AppendLine(String.Format(" and tran_type='{0}' ", strTranType))
                        End If
                        If tmpOrg <> "" Then
                            .AppendLine(String.Format(" and left(org,2)='{0}' ", tmpOrg))
                            .AppendLine(String.Format(" group by month(efftive_date), LEFT(org,2)   "))
                            .AppendLine(String.Format(" order by LEFT(org,2), month(efftive_date)  "))
                        Else
                            .AppendLine(String.Format(" group by month(efftive_date)  "))
                            .AppendLine(String.Format(" order by month(efftive_date)  "))
                        End If
                       
                    End With
                    Dim invDt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
                    Dim orgs As New ArrayList
                    For Each r As DataRow In invDt.Rows
                        If orgs.Contains(r.Item("org")) = False Then orgs.Add(r.Item("org"))
                    Next
                    For Each org As String In orgs
                        Dim dataPerf() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
                        Dim rs() As DataRow = invDt.Select("org='" + org + "'")
                        For Each r As DataRow In rs
                            dataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount"))))
                            If context.Request("Unit").ToString().Trim() <> "Qty" Then
                                dataPerf(CInt(r.Item("m")) - 1) = dataPerf(CInt(r.Item("m")) - 1) / 1000
                            End If
                        Next
                        With layer
                            .set3D(15)
                            .setBarShape(ChartDirector.Chart.CircleShape)
                            .addDataSet(dataPerf, GetLineColor(org, "Qty"), org).setDataSymbol(ChartDirector.Chart.DiamondSymbol, 6, GetLineColor(org, "Qty"))
                        End With
                    Next
                   
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
    
    Public Shared Function GetLineColor(ByVal org As String, ByVal category As String) As Integer
        Select Case org
            Case "AU"
                Return &HCC00
            Case "BR"
                Return &HDE0023
            Case "CN"
                Return &HFF9900
            Case "DL"
                Return &HFF
            Case "EU"
                Return &HDE0023
            Case "JP"
                Return &HA0BDC4
            Case "KR"
                Return &HFFFF00
            Case "MY"
                Return &H808080
            Case "SG"
                Return &H2284CC
            Case "TW"
                Return &HF423B3
            Case "US"
                Return &H38A966
            Case Else
                Return &HDE0023
        End Select
    End Function

End Class