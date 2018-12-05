<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Angel Parser" %>
<%@ Register TagPrefix="Upload" Namespace="Brettle.Web.NeatUpload" Assembly="Brettle.Web.NeatUpload" %>
<%@ Import Namespace="HtmlAgilityPack" %>
<%@ Import Namespace="ChartDirector" %>
 
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            ViewState("IFCount") = 5
        End If
    End Sub
    Private Function HtmlStreamToDts(ByRef fc As System.IO.Stream, ByVal FileName As String) As ArrayList
        If FileName.Contains(".") Then FileName = Split(FileName, ".")(0)
        Try
            Dim doc1 As New HtmlAgilityPack.HtmlDocument
            doc1.Load(fc)
            Dim ATitles As HtmlNodeCollection = doc1.DocumentNode.SelectNodes("//table")
            Dim TableSet As New ArrayList, NameSets As New ArrayList

            For i As Integer = 0 To ATitles.Count - 1
                Dim ndt As New DataTable()
                If ATitles(i).ParentNode IsNot Nothing _
                AndAlso ATitles(i).ParentNode.PreviousSibling IsNot Nothing _
                AndAlso ATitles(i).ParentNode.PreviousSibling.OuterHtml.StartsWith("<b") Then
                    ndt.TableName = ATitles(i).ParentNode.PreviousSibling.InnerText + "_" + FileName
                Else
                    If ATitles(i).ParentNode IsNot Nothing _
                    AndAlso ATitles(i).ParentNode.PreviousSibling IsNot Nothing _
                    AndAlso ATitles(i).ParentNode.PreviousSibling.PreviousSibling IsNot Nothing _
                    AndAlso ATitles(i).ParentNode.PreviousSibling.PreviousSibling.OuterHtml.StartsWith("<BIG") Then
                        ndt.TableName = ATitles(i).ParentNode.PreviousSibling.PreviousSibling.InnerText + "_" + FileName
                    Else
                        ndt.TableName = "Table" + (i + 1).ToString()
                    End If
                End If
                'If ndt.TableName.Length > 10 Then ndt.TableName = Left(ndt.TableName, 10)
                Dim trs As HtmlNodeCollection = ATitles(i).SelectNodes("tr")
                If trs.Count >= 2 Then
                    Dim ErsteTdSet As HtmlNodeCollection = trs(0).SelectNodes("td")
                    For Each col As HtmlNode In ErsteTdSet
                        ndt.Columns.Add(col.InnerText)
                    Next
                    For J As Integer = 1 To trs.Count - 1
                        Dim nr As DataRow = ndt.NewRow()
                        Dim After2ndTdSet As HtmlNodeCollection = trs(J).SelectNodes("td")
                        For k As Integer = 0 To After2ndTdSet.Count - 1
                            nr(k) = After2ndTdSet.Item(k).InnerText
                        Next
                        ndt.Rows.Add(nr)
                    Next
                    TableSet.Add(ndt)
                End If
            Next
            Return TableSet
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
    
    Protected Sub btnAddUp_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ifPanel.FindControl("if" + (ViewState("IFCount") + 1).ToString()).Visible = True
        CType(ifPanel.FindControl("if" + (ViewState("IFCount") + 1).ToString()), Brettle.Web.NeatUpload.InputFile).Enabled = True
        ViewState("IFCount") += 1
        If ViewState("IFCount") >= 2 Then
            btnDelUp.Enabled = True
            If ViewState("IFCount") = 10 Then btnAddUp.Enabled = False
        End If
        ifPanel.Height = Unit.Pixel(22 * ViewState("IFCount"))
    End Sub

    Protected Sub btnDelUp_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        btnAddUp.Enabled = True
        CType(ifPanel.FindControl("if" + ViewState("IFCount").ToString()), Brettle.Web.NeatUpload.InputFile).Enabled = False
        ifPanel.FindControl("if" + ViewState("IFCount").ToString()).Visible = False
        ViewState("IFCount") -= 1
        If ViewState("IFCount") = 1 Then btnDelUp.Enabled = False
        ifPanel.Height = Unit.Pixel(22 * ViewState("IFCount"))
    End Sub
    
    Private Sub ProcTab1(ByVal TableSet As ArrayList)
        Dim c As XYChart = New XYChart(1020, 700)
        c.setPlotArea(55, 65, 890, 570, -1, -1, &HC0C0C0, &HC0C0C0, -1)
        'c.addLegend(50, 30, False, "Times New Roman Bold Italic", 12).setBackground( _
        '    Chart.Transparent)
        c.addTitle("", "Times New Roman Bold Italic", 18)
        c.yAxis().setTitle("NV Lim Vs Freq", "Arial Bold Italic", 12)
        c.xAxis().setTitle("Channel (Unit=K)", "Arial Bold Italic", 12)
        c.xAxis().setWidth(3)
        c.yAxis().setWidth(3)
        Dim GColors() As Integer = {&HFF8040, &H6666FF, &HCC00, &HDE0023, &HFBFD04, &HFE0000, &H99B3CC, &H5C342C}
        Dim CIdx As Integer = 0
        For Each dt As DataTable In TableSet
            If dt.TableName.StartsWith("Tx Cal Over Freq NV") AndAlso dt.Rows.Count > 0 _
            AndAlso dt.Columns.Contains("Channel") AndAlso dt.Columns.Contains("NV Lim Vs Freq") Then
                Dim gv As New GridView, lb1 As New Label, TableCon As New Table
                TableCon.Width = Unit.Pixel(1000) : gv.Width = Unit.Percentage(100)
                Dim tr1 As New TableRow, th1 As New TableCell, tr2 As New TableRow, td2 As New TableCell
                gv.DataSource = dt : gv.DataBind() : lb1.Text = dt.TableName
                th1.Controls.Add(lb1) : tr1.Cells.Add(th1)
                td2.Controls.Add(gv) : tr2.Cells.Add(td2)
                TableCon.Rows.Add(tr1) : TableCon.Rows.Add(tr2)
                ph1.Controls.Add(TableCon)
                For Each r As DataRow In dt.Rows
                    If Not Double.TryParse(r.Item("Channel"), 0) Or Not Double.TryParse(r.Item("NV Lim Vs Freq"), 0) Then r.Delete()
                Next
                dt.AcceptChanges()
                Dim dataX0(dt.Rows.Count - 1) As Double
                Dim dataY0(dt.Rows.Count - 1) As Double
                For i As Integer = 0 To dt.Rows.Count - 1
                    dataX0(i) = dt.Rows(i).Item("Channel") / 1000 : dataY0(i) = dt.Rows(i).Item("NV Lim Vs Freq")
                Next
                c.addScatterLayer(dataX0, dataY0, dt.TableName, Chart.DiamondSymbol, 13, GColors(CIdx Mod 8) + 50 * (CIdx / 8))
                CIdx += 1
            End If
        Next
        WebChartViewer1.Image = c.makeWebImage(Chart.PNG)
        WebChartViewer1.ImageMap = c.getHTMLImageMap("", "", _
            "title='[{dataSetName}] Channel = {x}, NV Lim Vs Freq = {value}'")
        WebChartViewer1.Visible = True
    End Sub
    
    Private Sub ProcTab2(ByVal TableSet As ArrayList)
        Dim c As XYChart = New XYChart(1020, 700)
        c.setPlotArea(55, 65, 890, 570, -1, -1, &HC0C0C0, &HC0C0C0, -1)
        'c.addLegend(50, 30, False, "Times New Roman Bold Italic", 12).setBackground( _
        '    Chart.Transparent)
        c.addTitle("", "Times New Roman Bold Italic", 18)
        c.yAxis().setTitle("Lim Vs Freq PDM", "Arial Bold Italic", 12)
        c.yAxis2().setTitle("Lim Vs Freq HDET", "Arial Bold Italic", 12)
        c.xAxis().setTitle("Channel (Unit=K)", "Arial Bold Italic", 12)
        c.xAxis().setWidth(3)
        c.yAxis().setWidth(3)
        c.yAxis2().setWidth(3)
        Dim GColors() As Integer = {&HFF8040, &H6666FF, &HCC00, &HDE0023, &HFBFD04, &HFE0000, &H99B3CC, &H5C342C}
        Dim CIdx As Integer = 0
        For Each dt As DataTable In TableSet
            If dt.TableName.StartsWith("Tx Cal Over Freq Measurements") AndAlso dt.Rows.Count > 0 _
            AndAlso dt.Columns.Contains("Channel") _
            AndAlso dt.Columns.Contains("Lim Vs Freq PDM") _
            AndAlso dt.Columns.Contains("Lim Vs Freq HDET") Then
                Dim gv As New GridView, lb1 As New Label, TableCon As New Table
                TableCon.Width = Unit.Pixel(1000) : gv.Width = Unit.Percentage(100)
                Dim tr1 As New TableRow, th1 As New TableCell, tr2 As New TableRow, td2 As New TableCell
                gv.DataSource = dt : gv.DataBind() : lb1.Text = dt.TableName
                th1.Controls.Add(lb1) : tr1.Cells.Add(th1)
                td2.Controls.Add(gv) : tr2.Cells.Add(td2)
                TableCon.Rows.Add(tr1) : TableCon.Rows.Add(tr2)
                ph2.Controls.Add(TableCon)
                For Each r As DataRow In dt.Rows
                    If Not Double.TryParse(r.Item("Channel"), 0) Or Not Double.TryParse(r.Item("Lim Vs Freq PDM"), 0) _
                    Or Not Double.TryParse(r.Item("Lim Vs Freq HDET"), 0) Then r.Delete()
                Next
                dt.AcceptChanges()
                Dim dataX0(dt.Rows.Count - 1) As Double
                Dim dataY0(dt.Rows.Count - 1) As Double
                Dim dataY20(dt.Rows.Count - 1) As Double
                For i As Integer = 0 To dt.Rows.Count - 1
                    dataX0(i) = dt.Rows(i).Item("Channel") / 1000 : dataY0(i) = dt.Rows(i).Item("Lim Vs Freq PDM")
                    dataY20(i) = dt.Rows(i).Item("Lim Vs Freq HDET")
                Next
                c.addScatterLayer(dataX0, dataY0, dt.TableName, Chart.DiamondSymbol, 13, GColors(CIdx Mod 8) + 50 * (CIdx / 8))
                CIdx += 1
                Dim y2Layer As ScatterLayer = c.addScatterLayer(dataX0, dataY20, dt.TableName, Chart.DiamondSymbol, 13, GColors(CIdx Mod 8) + 50 * (CIdx / 8))
                y2Layer.setUseYAxis2()
                CIdx += 1
            End If
        Next
        WebChartViewer2.Image = c.makeWebImage(Chart.PNG)
        WebChartViewer2.ImageMap = c.getHTMLImageMap("", "", _
            "title='[{dataSetName}] Channel = {x}, Lim Vs Freq PDM = {value}'")
        WebChartViewer2.Visible = True
    End Sub
    
    Private Sub ProcTab3(ByVal TableSet As ArrayList)
        Dim c As XYChart = New XYChart(1020, 700)
        c.setPlotArea(55, 65, 890, 570, -1, -1, &HC0C0C0, &HC0C0C0, -1)
        'c.addLegend(50, 30, False, "Times New Roman Bold Italic", 12).setBackground( _
        '    Chart.Transparent)
        c.addTitle("", "Times New Roman Bold Italic", 18)
        c.yAxis().setTitle("NV HDET Vs AGC", "Arial Bold Italic", 12)
        c.xAxis().setTitle("NVMode", "Arial Bold Italic", 12)
        c.xAxis().setWidth(3)
        c.yAxis().setWidth(3)
        Dim GColors() As Integer = {&HFF8040, &H6666FF, &HCC00, &HDE0023, &HFBFD04, &HFE0000, &H99B3CC, &H5C342C}
        Dim CIdx As Integer = 0
        For Each dt As DataTable In TableSet
            If dt.TableName.StartsWith("HDET Vs AGC NV") AndAlso dt.Rows.Count > 0 _
            AndAlso dt.Columns.Contains("NVMode") AndAlso dt.Columns.Contains("NV HDET Vs AGC") Then
                Dim gv As New GridView, lb1 As New Label, TableCon As New Table
                TableCon.Width = Unit.Pixel(1000) : gv.Width = Unit.Percentage(100)
                Dim tr1 As New TableRow, th1 As New TableCell, tr2 As New TableRow, td2 As New TableCell
                gv.DataSource = dt : gv.DataBind() : lb1.Text = dt.TableName
                th1.Controls.Add(lb1) : tr1.Cells.Add(th1)
                td2.Controls.Add(gv) : tr2.Cells.Add(td2)
                TableCon.Rows.Add(tr1) : TableCon.Rows.Add(tr2)
                ph3.Controls.Add(TableCon)
                For Each r As DataRow In dt.Rows
                    If Not Double.TryParse(r.Item("NVMode"), 0) Or Not Double.TryParse(r.Item("NV HDET Vs AGC"), 0) Then r.Delete()
                Next
                dt.AcceptChanges()
                Dim dataX0(dt.Rows.Count - 1) As Double
                Dim dataY0(dt.Rows.Count - 1) As Double
                For i As Integer = 0 To dt.Rows.Count - 1
                    dataX0(i) = dt.Rows(i).Item("NVMode") : dataY0(i) = dt.Rows(i).Item("NV HDET Vs AGC")
                Next
                c.addScatterLayer(dataX0, dataY0, dt.TableName, Chart.DiamondSymbol, 13, GColors(CIdx Mod 8) + 50 * (CIdx / 8))
                CIdx += 1
            End If
        Next
        WebChartViewer3.Image = c.makeWebImage(Chart.PNG)
        WebChartViewer3.ImageMap = c.getHTMLImageMap("", "", _
            "title='[{dataSetName}] NVMode = {x}, NV HDET Vs AGC = {value}'")
        WebChartViewer3.Visible = True
    End Sub
    
    Private Sub ProcTab4(ByVal TableSet As ArrayList)
        Dim c As XYChart = New XYChart(1020, 700)
        c.setPlotArea(55, 65, 890, 570, -1, -1, &HC0C0C0, &HC0C0C0, -1)
        'c.addLegend(50, 30, False, "Times New Roman Bold Italic", 12).setBackground( _
        '    Chart.Transparent)
        c.addTitle("", "Times New Roman Bold Italic", 18)
        c.yAxis().setTitle("VGA Offset vs Freq", "Arial Bold Italic", 12)
        c.xAxis().setTitle("Channel (Unit=K)", "Arial Bold Italic", 12)
        c.xAxis().setWidth(3)
        c.yAxis().setWidth(3)
        Dim GColors() As Integer = {&HFF8040, &H6666FF, &HCC00, &HDE0023, &HFBFD04, &HFE0000, &H99B3CC, &H5C342C}
        Dim CIdx As Integer = 0
        For Each dt As DataTable In TableSet
            If dt.TableName.StartsWith("Rx Cal Over Freq Measurements") AndAlso dt.Rows.Count > 0 _
            AndAlso dt.Columns.Contains("Channel") AndAlso dt.Columns.Contains("VGA Offset vs Freq") Then
                Dim gv As New GridView, lb1 As New Label, TableCon As New Table
                TableCon.Width = Unit.Pixel(1000) : gv.Width = Unit.Percentage(100)
                Dim tr1 As New TableRow, th1 As New TableCell, tr2 As New TableRow, td2 As New TableCell
                gv.DataSource = dt : gv.DataBind() : lb1.Text = dt.TableName
                th1.Controls.Add(lb1) : tr1.Cells.Add(th1)
                td2.Controls.Add(gv) : tr2.Cells.Add(td2)
                TableCon.Rows.Add(tr1) : TableCon.Rows.Add(tr2)
                ph4.Controls.Add(TableCon)
                For Each r As DataRow In dt.Rows
                    Try
                        If Not Double.TryParse(r.Item("Channel"), 0) Or Not Double.TryParse(r.Item("VGA Offset vs Freq"), 0) Then r.Delete()
                    Catch ex As Exception
                        r.Delete()
                    End Try
                Next
                dt.AcceptChanges()
                Dim dataX0(dt.Rows.Count - 1) As Double
                Dim dataY0(dt.Rows.Count - 1) As Double
                For i As Integer = 0 To dt.Rows.Count - 1
                    dataX0(i) = dt.Rows(i).Item("Channel") / 1000 : dataY0(i) = dt.Rows(i).Item("VGA Offset vs Freq")
                Next
                c.addScatterLayer(dataX0, dataY0, dt.TableName, Chart.DiamondSymbol, 13, GColors(CIdx Mod 8) + 50 * (CIdx / 8))
                CIdx += 1
            End If
        Next
        WebChartViewer4.Image = c.makeWebImage(Chart.PNG)
        WebChartViewer4.ImageMap = c.getHTMLImageMap("", "", _
            "title='[{dataSetName}] Channel = {x}, VGA Offset vs Freq = {value}'")
        WebChartViewer4.Visible = True
    End Sub
    
    Protected Sub submitButton_Click(ByVal sender As Object, ByVal e As EventArgs)
        If IsValid Then
            Dim TableSet As New ArrayList
            For i As Integer = 1 To 10
                Dim fup As Brettle.Web.NeatUpload.InputFile = CType(ifPanel.FindControl("if" + i.ToString()), Brettle.Web.NeatUpload.InputFile)
                If fup.Visible AndAlso fup.ContentLength > 0 AndAlso _
                (fup.FileName.ToLower.EndsWith(".htm") Or fup.FileName.ToLower.EndsWith(".html")) Then
                    TableSet.AddRange(HtmlStreamToDts(fup.FileContent, fup.FileName))
                    fup.FileContent.Close()
                End If
            Next
            ProcTab1(TableSet) : ProcTab2(TableSet) : ProcTab3(TableSet) : ProcTab4(TableSet)
        End If
    End Sub
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="750px">
        <tr>
            <td>
                <table width="80%">
                    <tr>
                        <td colspan="2">                            
                            <asp:Button runat="server" ID="btnAddUp" Text="More upload files" OnClick="btnAddUp_Click" /> &nbsp;
                            <asp:Button runat="server" ID="btnDelUp" Text="Less upload files" OnClick="btnDelUp_Click" />                        
                        </td>
                    </tr>
                    <tr>
                        <td>  
                            <asp:Panel runat="server" ID="ifPanel" Width="710px" Height="22px">
                                <Upload:InputFile runat="server" ID="if1" Width="700px" />
                                <Upload:InputFile runat="server" ID="if2" Width="700px" />
                                <Upload:InputFile runat="server" ID="if3" Width="700px" />
                                <Upload:InputFile runat="server" ID="if4" Width="700px" />
                                <Upload:InputFile runat="server" ID="if5" Width="700px" />
                                <Upload:InputFile runat="server" ID="if6" Width="700px" Visible="false" />
                                <Upload:InputFile runat="server" ID="if7" Width="700px" Visible="false" />
                                <Upload:InputFile runat="server" ID="if8" Width="700px" Visible="false" />
                                <Upload:InputFile runat="server" ID="if9" Width="700px" Visible="false" />
                                <Upload:InputFile runat="server" ID="if10" Width="700px" Visible="false" /> 
                            </asp:Panel>                                                                                   
                        </td>
                        <td valign="bottom" align="left">
                            <asp:Button runat="server" ID="submitButton" OnClick="submitButton_Click" Text="Upload" Enabled="true"/>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="1" align="center">
                <Upload:ProgressBar id="progressBarId" runat="server" Inline="true"
                    Triggers="submitButton" Width="700px" Height="130px" Url="/Includes/NeatUpload/Progress.aspx"/>
            </td>
        </tr>
        <tr>
            <td>
                <ajaxToolkit:TabContainer runat="server" ID="tabcon1">
                    <ajaxToolkit:TabPanel runat="server" ID="Tab1" HeaderText="Tx Cal Over Freq NV">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td colspan="1">
                                        <chartdir:WebChartViewer runat="server" ID="WebChartViewer1" Visible="false" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="Panel1" Width="1020px" ScrollBars="Auto">
                                            <asp:PlaceHolder runat="server" ID="ph1" />
                                        </asp:Panel>                                        
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="TabPanel1" HeaderText="Tx Cal Over Freq Measurements">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td colspan="1">
                                        <chartdir:WebChartViewer runat="server" ID="WebChartViewer2" Visible="false" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="Panel2" Width="1020px" ScrollBars="Auto">
                                            <asp:PlaceHolder runat="server" ID="ph2" />
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="TabPanel2" HeaderText="HDET Vs AGC NV">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td colspan="1">
                                        <chartdir:WebChartViewer runat="server" ID="WebChartViewer3" Visible="false" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="Panel3" Width="1020px" ScrollBars="Auto">
                                            <asp:PlaceHolder runat="server" ID="ph3" />
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="TabPanel3" HeaderText="Rx Cal Over Freq Measurements">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td colspan="1">
                                        <chartdir:WebChartViewer runat="server" ID="WebChartViewer4" Visible="false" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="Panel4" Width="1020px" ScrollBars="Auto">
                                            <asp:PlaceHolder runat="server" ID="ph4" />
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </td>
        </tr>
    </table>
</asp:Content>

