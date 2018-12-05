<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech KPI" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim user() As String = {"Channel Partner", "Key Account", "General Account"}
        'Dim country() As String = {"Europe", "US", "Asia", "Emerging Territory"}
        'Dim month() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
        'Dim ran As New Random
        'For i As Integer = 0 To 99
        '    Dim userID As String = NewUserID()
        '    Dim auser As String = user(ran.Next(3))
        '    Dim acountry As String = country(ran.Next(4))
        '    Dim amonth As String = month(ran.Next(12))
        '    Dim k As Integer = dbUtil.dbExecuteNoQuery("My", String.Format("insert into testKPI values ('{0}','{1}','{2}','{3}')", userID, auser, acountry, amonth))
        'Next
        DrawAccountStatusPieChart() : DrawCountryBarChart()
    End Sub
    
    Protected Sub DrawAccountStatusPieChart()
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select Account_Status, count(*) from testKPI group by account_status")
        Dim data(0) As Double, labels(0) As String
        If dt.Rows.Count > 0 Then
            ReDim data(dt.Rows.Count - 1) : ReDim labels(dt.Rows.Count - 1)
            For row As Integer = 0 To dt.Rows.Count - 1
                labels(row) = dt.Rows(row).Item(0)
                data(row) = CType(dt.Rows(row).Item(1), Double)
            Next
        End If
        Dim c As PieChart = New PieChart(1000, 400)
        With c
            .setPieSize(350, 150, 100) : .addTitle2(Chart.TopCenter, "Account Status Ratio", "Arial Bold Italic")
            .set3D() : .addLegend(700, 20) : .setLabelLayout(0)
            .setLabelFormat("{value} contact(s) {label}<*br*>({percent}%)")
            .setData(data, labels) : ContactAccountStatusPie.Image = .makeWebImage(Chart.PNG)
            ContactAccountStatusPie.ImageMap = .getHTMLImageMap("/Admin/ShowContactList.aspx", "account_status={label}", "target='_blank' title='{label}: {value} ({percent}%)'")
        End With
        ContactAccountStatusPie.Visible = True
    End Sub
    
    Protected Sub DrawCountryBarChart()
        Dim labels() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select login_month,country, count(*) from testKPI group by login_month, country")
        Dim dataEur(11) As Double, dataUS(11) As Double, dataAsia(11) As Double, dataET(11) As Double
        Dim month As New ArrayList
        For i As Integer = 0 To labels.Length - 1
            month.Add(labels(i))
        Next
        If Not IsNothing(dt) And dt.Rows.Count > 0 Then
            For row As Integer = 0 To dt.Rows.Count - 1
                Select Case dt.Rows(row).Item(1).ToString
                    Case "Europe"
                        dataEur(month.IndexOf(dt.Rows(row).Item(0).ToString.Trim)) = dt.Rows(row).Item(2)
                    Case "US"
                        dataUS(month.IndexOf(dt.Rows(row).Item(0).ToString.Trim)) = dt.Rows(row).Item(2)
                    Case "Asia"
                        dataAsia(month.IndexOf(dt.Rows(row).Item(0).ToString.Trim)) = dt.Rows(row).Item(2)
                    Case "Emerging Territory"
                        dataET(month.IndexOf(dt.Rows(row).Item(0).ToString.Trim)) = dt.Rows(row).Item(2)
                End Select
            Next
        End If

        Dim c As XYChart = New XYChart(1000, 400)

        With c
            .addTitle2(Chart.TopCenter, "Every Month Contacts Login", "Arial Bold Italic")
            .setPlotArea(45, 25, 800, 350).setBackground(&HFFFFC0, &HFFFFE0)
            .addLegend(45, 20, False, "", 8).setBackground(Chart.Transparent)
            .yAxis().setTitle("Contacts") : .yAxis().setTopMargin(20) : .xAxis().setLabels(labels)
            Dim layer As BarLayer = .addBarLayer2(Chart.Side, 4)
            layer.addDataSet(dataEur, &HFF8080, "Europe")
            layer.addDataSet(dataUS, &H80FF80, "US")
            layer.addDataSet(dataAsia, &H8080FF, "Asia")
            layer.addDataSet(dataET, &H8F8F00, "Emerging Territory")
            ContactAccountCountryBar.Image = .makeWebImage(Chart.PNG)
            ContactAccountCountryBar.ImageMap = .getHTMLImageMap("/Admin/ShowContactList.aspx", "", "target='_blank' title='{dataSetName} on {xLabel}: {value} contacts'")
        End With
        
        ContactAccountCountryBar.Visible = True
    End Sub
    
    'Private Function NewUserID() As String
    '    Dim tmpUserID As String = ""
    '    Do While True
    '        tmpUserID = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
    '        If CInt( _
    '          dbUtil.dbExecuteScalar("My", "select count(*) from Contact_Role_Definition where RoleID='" + tmpUserID + "'") _
    '           ) = 0 Then
    '            Exit Do
    '        End If
    '    Loop
    '    Return tmpUserID
    'End Function
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td><chartdir:WebChartViewer runat="server" ID="ContactAccountStatusPie" Visible="false"/></td>
        </tr>
        <tr><td><hr /></td></tr>
        <tr>
            <td><chartdir:WebChartViewer runat="server" ID="ContactAccountCountryBar" Visible="false" /></td>
        </tr>
    </table>
</asp:Content>
