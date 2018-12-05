<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Function upload() As System.IO.Stream
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Dim MSM As New System.IO.MemoryStream(Me.FileUpload1.FileBytes)
            'Me.FileUpload1.SaveAs(fileName)
            Return MSM
        End If
        Return Nothing
    End Function
    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If String.IsNullOrEmpty(TBlistname.Text.Trim) Then
            Util.JSAlert(Me.Page, "List Name cannot be empty. ")
            Exit Sub
        End If
        Dim filestream As System.IO.Stream = upload()
        If Not IsNothing(filestream) Then
            ' Dim bt As Button = CType(sender, Button)
            Dim tempds As DataSet = ExcelFile2DataTable(filestream, 1, 0)
            If tempds Is Nothing Then Exit Sub
            Dim tempdt As DataTable = tempds.Tables(0)
            If tempdt.Rows.Count <= 0 Then
                Glob.ShowInfo("No data be uploaded.")
                Exit Sub
            End If
            If tempdt.Columns.Count < 1 Then
                Glob.ShowInfo("The uploaded excel file is in invalid format. Please download and use sample excel file.")
                Exit Sub
            End If
            Dim MyDC As New MyCampaignDBDataContext()
            Dim TA As CAMPAIGN_REQUEST_TA_Master = MyDC.CAMPAIGN_REQUEST_TA_Masters.Where(Function(p) p.REQUESTNO = Request("REQUESTNO")).FirstOrDefault()
            If TA Is Nothing Then
                TA = New CAMPAIGN_REQUEST_TA_Master
                TA.LAST_UPD_BY = Session("USER_ID")
                TA.LAST_UPD_DATE = Now
                TA.Create_By = Session("USER_ID")
                TA.Create_Date = Now
                TA.ListName = TBlistname.Text.Replace("'", "''")
                TA.REQUESTNO = Request("REQUESTNO").ToString
                TA.Description = TBDescription.Text.Replace("'", "''")
                TA.Status = 0 ': If bt.CommandArgument = "1" Then TA.Status = 1

                MyDC.CAMPAIGN_REQUEST_TA_Masters.InsertOnSubmit(TA)
                MyDC.SubmitChanges()
            Else
                TA.Status = 0 ' : If bt.CommandArgument = "1" Then TA.Status = 1
                TA.LAST_UPD_BY = Session("USER_ID")
                TA.LAST_UPD_DATE = Now
                TA.ListName = TBlistname.Text.Replace("'", "''")
                TA.Description = TBDescription.Text.Replace("'", "''")
                MyDC.SubmitChanges()
            End If
            Dim TaList As List(Of CAMPAIGN_REQUEST_TA_Detail) = New List(Of CAMPAIGN_REQUEST_TA_Detail)
            Dim acj As Integer = 0
            Dim ArrEmail As New ArrayList
            For Each dr As DataRow In tempdt.Rows
                Dim ta_list As New CAMPAIGN_REQUEST_TA_Detail
                ta_list.Email = dr.Item(0).ToString.Trim
                ArrEmail.Add(dr.Item(0).ToString.Trim.ToLower)
                ta_list.TAID = TA.ID
                ta_list.IsExistSiebel = 0
                TaList.Add(ta_list)
                'End If
            Next
            TA.CAMPAIGN_REQUEST_TA_Details.Clear()
            MyDC.CAMPAIGN_REQUEST_TA_Details.InsertAllOnSubmit(TaList)
            MyDC.SubmitChanges()
            Dim Instr As String = String.Join(",", CType(ArrEmail.ToArray(GetType(String)), String()))
            Instr = Instr.Replace(",", "','")
            ' Response.Write(Instr + "<hr>")
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select EMAIL_ADDR from S_CONTACT where Lower(EMAIL_ADDR) in ('{0}')", Instr))
            ArrEmail.Clear()
            For Each dr As DataRow In dt.Rows
                ArrEmail.Add(dr.Item(0).ToString.Trim)
            Next
            Instr = String.Join(",", CType(ArrEmail.ToArray(GetType(String)), String()))
            ' Response.Write(Instr +"<hr>")
            dbUtil.dbExecuteNoQuery("My", String.Format("update CAMPAIGN_REQUEST_TA_Detail set IsExistSiebel = 1 where  TAID={1} and Email in ('{0}')", Instr, TA.ID))
            Dim TaListTemp As List(Of CAMPAIGN_REQUEST_TA_Detail) = MyDC.CAMPAIGN_REQUEST_TA_Details.Where(Function(p) p.TAID = TA.ID AndAlso p.IsExistSiebel = 0).ToList
            TBucj.Text = tempdt.Rows.Count.ToString
            TBacj.Text = TaListTemp.Count.ToString
            BindGV()
            'If bt.CommandArgument = "1" Then
            '    Util.JSAlert(Me.Page, "Import TA List Succeed. ")
            'End If
        Else
            Util.JSAlert(Me.Page, "Please select a file. ")
            Exit Sub
        End If
    End Sub
    Public Shared Function ExcelFile2DataTable(ByVal fs As System.IO.Stream, ByVal startRow As Integer, ByVal startColumn As Integer) As DataSet
        Util.SetASPOSELicense()
        Dim ds As New DataSet
        Try
            For p As Integer = 0 To 1
                Dim dt As New DataTable
                Dim wb As New Aspose.Cells.Workbook
                wb.Open(fs)
                Dim SheetCurrentIndex As Integer = p
                For i As Integer = startColumn To wb.Worksheets(0).Cells.Columns.Count - 1
                    If wb.Worksheets(SheetCurrentIndex).Cells(0, i).Value IsNot Nothing AndAlso wb.Worksheets(SheetCurrentIndex).Cells(0, i).Value.ToString <> "" Then
                        dt.Columns.Add(wb.Worksheets(SheetCurrentIndex).Cells(0, i).Value)
                    Else
                        Exit For
                    End If
                Next
                For i As Integer = startRow To wb.Worksheets(SheetCurrentIndex).Cells.Rows.Count - 1
                    Dim r As DataRow = dt.NewRow
                    For j As Integer = 0 To dt.Columns.Count - 1
                        r.Item(j) = wb.Worksheets(SheetCurrentIndex).Cells(i, j).Value
                    Next
                    dt.Rows.Add(r)
                Next
                dt.AcceptChanges()
                ds.Tables.Add(dt)
            Next
        Catch ex As Exception
            Util.SendEmail("eBusiness.AEU@advantech.eu", "ebiz.aeu@advantech.eu", "error reading excel to dt", ex.ToString(), False, "", "")
            Return Nothing
        End Try
        Return ds
    End Function
    Protected Sub Button2_Click(sender As Object, e As System.EventArgs)
        TBlistname.Text = ""
        TBDescription.Text = ""
        TBucj.Text = ""
        TBacj.Text = ""
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            If Request("REQUESTNO") Is Nothing Then Response.Redirect("CampaignList.aspx")
            Dim MyDC As New MyCampaignDBDataContext()
            Dim TA As CAMPAIGN_REQUEST_TA_Master = MyDC.CAMPAIGN_REQUEST_TA_Masters.Where(Function(p) p.REQUESTNO = Request("REQUESTNO") AndAlso p.Status = 1).FirstOrDefault()
            If TA IsNot Nothing Then
                TBlistname.Text = TA.ListName
                TBDescription.Text = TA.Description.Trim
                TBucj.Text = TA.CAMPAIGN_REQUEST_TA_Details.Count.ToString
                TBacj.Text = TA.CAMPAIGN_REQUEST_TA_Details.Where(Function(p) p.IsExistSiebel = 0).Count.ToString
            End If
            Dim MyCR As CAMPAIGN_REQUEST = (From CR In MyDC.CAMPAIGN_REQUESTs
                        Where CR.REQUESTNO = Request("REQUESTNO")).FirstOrDefault()
            If MyCR IsNot Nothing Then
                If MyCR.STATUS = 2 Then
                Else
                    FileUpload1.Enabled = False : btnUpload.Enabled = False : BTconfirm.Enabled = False : BTcancel.Enabled = False
                End If
            End If
            BindGV()
        End If
    End Sub
    Private Sub BindGV()
        'Dim MyDC As New MyCampaignDBDataContext()
        'Dim TA As CAMPAIGN_REQUEST_TA_Master = MyDC.CAMPAIGN_REQUEST_TA_Masters.Where(Function(p) p.REQUESTNO = Request("REQUESTNO") AndAlso p.Status = 1).FirstOrDefault()
        'If TA IsNot Nothing Then
        '    gv1.DataSource = TA.CAMPAIGN_REQUEST_TA_Details
        '    gv1.DataBind()
        'End If
    End Sub
    Protected Sub BTconfirm_Click(sender As Object, e As System.EventArgs)
        Dim MyDC As New MyCampaignDBDataContext()
        Dim TA As CAMPAIGN_REQUEST_TA_Master = MyDC.CAMPAIGN_REQUEST_TA_Masters.Where(Function(p) p.REQUESTNO = Request("REQUESTNO")).FirstOrDefault()
        If TA Is Nothing Then
            Util.JSAlert(Me.Page, "Please first upload contact list. ")
            Exit Sub
        End If
        TA.Status = 1
        TA.LAST_UPD_BY = Session("USER_ID")
        TA.LAST_UPD_DATE = Now
        TA.ListName = TBlistname.Text.Replace("'", "''")
        TA.Description = TBDescription.Text.Replace("'", "''")
        MyDC.SubmitChanges()
        Util.JSAlert(Me.Page, "Import TA List Succeed. ")
        BindGV()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:HyperLink runat="server" ID="hySBUCampaignList" NavigateUrl="~/My/AOnline/UNICA_SBU_Campaigns.aspx"
        Text="SBU Campaign Overview" />&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;
    <asp:HyperLink runat="server" ID="hyMyCampains" NavigateUrl="~/My/Campaign/CampaignList.aspx"
        Text="My Campaigns" />
    <table width="600">
        <tr>
            <td colspan="2">
                <b>
                    <h2>
                        Upload Contact list</h2>
                </b>
            </td>
        </tr>
        <tr>
            <td class="BGH">
                <asp:Label Text="*" runat="server" ID="Label1" ForeColor="Red" />
                Contact list
            </td>
            <td width="410">
                <asp:FileUpload ID="FileUpload1" runat="server" /><br />
                <asp:HyperLink NavigateUrl="~/Files/TalistSample.xls" runat="server" ID="HyperLink1"
                    Text="Click Here for Downloadable Sample (MS Excel)"></asp:HyperLink>
            </td>
        </tr>
        <tr>
            <td class="BGH">
                <asp:Label Text="*" runat="server" ID="lab1" ForeColor="Red" />
                List Name
            </td>
            <td>
                <asp:TextBox runat="server" ID="TBlistname" Width="400" />
            </td>
        </tr>
        <tr>
            <td class="BGH">
                Description
            </td>
            <td>
                <asp:TextBox runat="server" ID="TBDescription" Width="400" Height="80" TextMode="MultiLine" />
            </td>
        </tr>
        <tr>
            <td colspan="2" align="right">
                <asp:Button ID="btnUpload" runat="server" Text="Upload" CssClass="BTAN2" OnClick="btnUpload_Click" />
            </td>
        </tr>
        <tr>
            <td colspan="2" style="color: Red;">
                To secure the account ownership, the named accounts will be filtered out of your
                list. Please check the available contact# as below.
            </td>
        </tr>
        <tr>
            <td class="BGH">
                Upload contact#:
            </td>
            <td>
                <asp:TextBox runat="server" ID="TBucj" Width="400" />
            </td>
        </tr>
        <tr>
            <td class="BGH">
                Available contact#:
            </td>
            <td>
                <asp:TextBox runat="server" ID="TBacj" Width="400" />
            </td>
        </tr>
        <tr>
            <td>
            </td>
            <td>
                <asp:Button ID="BTconfirm" runat="server" Text="Confirm" CssClass="BTAN2" OnClick="BTconfirm_Click" />
                &nbsp;&nbsp;&nbsp;&nbsp;<asp:Button ID="BTcancel" runat="server" Text="Cancel" CssClass="BTAN2"
                    OnClick="Button2_Click" />
            </td>
        </tr>
    </table><br />
    <asp:GridView runat="server" ID="gv1" Width="600" AutoGenerateColumns="False">
        <Columns>
            <asp:BoundField HeaderText="EMAIL" DataField="EMAIL" ItemStyle-HorizontalAlign="Center">
            </asp:BoundField>
            <asp:CheckBoxField DataField="IsExistSiebel" HeaderText="Already Exists" ReadOnly="True" ItemStyle-HorizontalAlign="Center" />
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <style type="text/css">
        .BGH
        {
            font-weight: bold;
        }
    </style>
</asp:Content>
