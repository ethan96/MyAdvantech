<%@ Page Title="MyAdvantech - Campaign Request" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Namespace="eBizAEUControls" TagPrefix="uc1" %>
<script runat="server">
    Public ReadOnly Property PageRequestNO() As String
        Get
            If Request("REQUESTNO") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("REQUESTNO")) Then
                Return Trim(Request("REQUESTNO"))
            Else
                Return ""
            End If
        End Get
    End Property
    Private _CampaignID As String
    Public Property CampaignID() As String
        Get
            If Request("CampaignID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("CampaignID")) Then
                Return Trim(Request("CampaignID"))
            Else
                Return _CampaignID
            End If
        End Get
        Set(value As String)
            _CampaignID = value
        End Set
    End Property
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            If CampaignUtil.IsAdmin() Then
                AdminPan.Visible = True
            End If
            For Each myCode As Integer In [Enum].GetValues(GetType(CampaignUtil.CR_Status))
                Dim strName As String = [Enum].GetName(GetType(CampaignUtil.CR_Status), myCode).ToString.Replace("_", " ")
                Dim strVaule As String = myCode.ToString
                If myCode <> -1 AndAlso myCode <> 0 Then
                    DDlSTATUS.Items.Add(New ListItem(strName, strVaule))
                End If
            Next
            lab_requestno.Text = CampaignUtil.GetRequestNO()
            lab_name.Text = CampaignUtil.getCompanyName(Session("COMPANY_ID"))
            lab_ERPID.Text = Session("COMPANY_ID")
            lab_status.Text = [Enum].GetName(GetType(CampaignUtil.CR_Status), -1)
            Lab_REQUEST_BY.Text = Session("USER_ID")
            TB_Roll_out_Time.Text = Now.ToString("yyyy/MM/dd")
            If Not String.IsNullOrEmpty(PageRequestNO) Then
                Dim MyDC As New MyCampaignDBDataContext()
                Dim MyCR As CAMPAIGN_REQUEST = (From CR In MyDC.CAMPAIGN_REQUESTs
                              Where CR.REQUESTNO = PageRequestNO).FirstOrDefault()
                lab_requestno.Text = MyCR.REQUESTNO
                lab_name.Text = MyCR.ErpNameX
                lab_ERPID.Text = MyCR.ERPID
                lab_status.Text = MyCR.StatusX
                Lab_REQUEST_BY.Text = MyCR.REQUEST_BY
                ' TB_COMMENT.Text = MyCR.FEEDBACK
                'TB_PROMOTION_PLAN.Content = MyCR.PROMOTION_PLAN
                TB_ROLL_OUT_REGION.Text = MyCR.ROLL_OUT_REGION
                TB_Roll_out_Time.Text = CDate(MyCR.ROLL_OUT_TIME).ToString("yyyy/MM/dd")
                TB_TargetAudience.Text = MyCR.TARGET_AUDIENCE
                ' TB_REQUEST_SUPPORT.Content = MyCR.REQUEST_SUPPORT
                CampaignID = MyCR.CAMPAIGNID
                If IsNumeric(MyCR.STATUS) Then
                    If Integer.Parse(MyCR.STATUS) > 1 AndAlso Not (Integer.Parse(MyCR.STATUS) = 4 OrElse Integer.Parse(MyCR.STATUS) = 5 OrElse Integer.Parse(MyCR.STATUS) = 6) Then
                        hyUploadTAlist.NavigateUrl = String.Format("<a  href=""UploadTAlist.aspx?REQUESTNO={0}"" target=""_blank"">Upload TA list</a>", PageRequestNO)
                        hyUploadTAlist.Text = "Upload TA list"
                        hyUploadTAlist.Font.Bold = True
                    End If
                End If
                If MyCR.STATUS > 0 Then
                    BTSave.Enabled = False
                End If
                If MyCR.STATUS >= 1 Then
                    
                    BTSubmit.Enabled = False
                    BTSubmit.Text = "Submitted by " + MyCR.REQUEST_BY + " on " + MyCR.REQUEST_DATE.ToString
                    If Not CampaignUtil.IsAdmin() Then
                        AdminPan.Visible = True : BTadvSubmit.Visible = False : DDlSTATUS.Visible = False
                    End If
                    If MyCR.MarketingManagerMailX.ToString.Contains(Session("user_id").ToString) Then
                        AdminPan.Visible = True : BTadvSubmit.Visible = True : DDlSTATUS.Visible = True
                    End If
                    PANCSS.Visible = True ': TB_PROMOTION_PLAN.ActiveMode = ActiveModeType.Preview : TB_REQUEST_SUPPORT.ActiveMode = ActiveModeType.Preview
                End If
                If MyCR.STATUS >= 1 Then
                    tbPPRA.Visible = True
                End If
        
                If MyCR.STATUS = 0 Then
                    AdminPan.Visible = False
                End If
            End If
            If String.IsNullOrEmpty(PageRequestNO) Then
                AdminPan.Visible = False
            End If
            ' SET Campaign
            Dim sb As New StringBuilder
            sb.Append(" select a.CampaignID, a.CampaignCode, a.Name as CampaignName, a.Description,  c.NAME as Creator,d.NAME as LastUpdBy, ")
            sb.Append(" IsNull((select top 1 z.StringValue from UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=100),'') as ProductGroup,  ")
            sb.Append(" IsNull((select top 1 z.StringValue from UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=101),'') as TargetSolution, ")
            sb.Append(" IsNull((select top 1 z.StringValue from UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=102),'') as ParentCampaignCode, ")
            sb.Append(" b.Name as SBU_Name, a.CreateDate, a.StartDate, a.EndDate")
            sb.Append(" from UNICADBP.dbo.UA_Campaign a inner join UNICADBP.dbo.UA_Folder b on a.FolderID=b.FolderID ")
            sb.Append(" inner join UNICAMPP.dbo.USM_USER c on a.CreateBy=c.ID ")
            sb.Append(" inner join UNICAMPP.dbo.USM_USER d on a.UpdateBy=d.ID ")
            sb.AppendFormat(" where b.Name like 'SBU%'  and a.CampaignID={0}", CampaignID)
            sb.Append(" order by a.StartDate, a.EndDate ")
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString)
            If dt.Rows.Count > 0 Then
                With dt.Rows(0)
                    LabCampaignID.Text = .Item("CampaignName").ToString + vbTab + "(" + .Item("CampaignID").ToString + ")"
                    LabThemeSlogan.Text = .Item("Description")
                    LabCampaignPeriod.Text = CDate(.Item("StartDate")).ToString("MM-dd-yyyy") + "~" + CDate(.Item("EndDate")).ToString("MM-dd-yyyy")
                    LabKPS.Text = .Item("ProductGroup")
                    LabSI.Text = .Item("TargetSolution")
                    LabSBUOwner.Text = .Item("Creator")
                End With
            End If
            ' END
            BindGvPP()
            'BindFiles()
        End If
        'fup1.Visible=True 
        Setlog()
    End Sub
    Protected Sub Setlog()
        If Not String.IsNullOrEmpty(PageRequestNO) Then
            Lablog.Text = ""
            Dim MyCRlog As List(Of CAMPAIGN_REQUEST_log) = CampaignUtil.GetLog(PageRequestNO)
            For Each i As CAMPAIGN_REQUEST_log In MyCRlog
                Lablog.Text += "[ <font color=""red"">" + i.REQUES_STATUSX + "</font> ]" + vbTab + "Submitted by " + i.Submitted_by + " on " + i.Submitted_date.ToString + "<br/>"
            Next
        End If
    End Sub
    Protected Function CheckForm() As Boolean
        If Date.TryParse(TB_Roll_out_Time.Text, Now) = False Then
            Util.JSAlert(Me.Page, " Roll-out Time is incorrect. ")
            Return False
        End If
        If String.IsNullOrEmpty(TB_TargetAudience.Text.Trim) Then
            Util.JSAlert(Me.Page, "Target Audience cannot be empty. ")
            Return False
        End If
        Return True
    End Function
    Protected Sub BTSave_Click(sender As Object, e As System.EventArgs)
        If CheckForm() = False Then Exit Sub
        If InsertCR(0, lab_requestno.Text) Then
            Util.JSAlertRedirect(Me.Page, " Succeed. ", "CampaignRequest.aspx?REQUESTNO=" + lab_requestno.Text)
        End If
    End Sub
    Protected Sub BTSubmit_Click(sender As Object, e As System.EventArgs)
        If CheckForm() = False Then Exit Sub
        If InsertCR(1, lab_requestno.Text) Then
            Util.JSAlertRedirect(Me.Page, " Your new campaign request is successfully submitted.\n Once the request is approved, system will inform you via email. thank you. ", "CampaignList.aspx")
            BTSave.Enabled = False
            BTSubmit.Enabled = False
        End If
    End Sub
    
    Protected Function InsertCR(ByVal CRSTATUS As Integer, ByVal REQUESTNO As String) As Boolean
        Dim MyDC As New MyCampaignDBDataContext()
        Dim CR As CAMPAIGN_REQUEST = (From MyCR In MyDC.CAMPAIGN_REQUESTs
                    Where MyCR.REQUESTNO = REQUESTNO).FirstOrDefault()
        Dim Isexist As Boolean = True
        If CR Is Nothing Then
            Isexist = False
            CR = New CAMPAIGN_REQUEST
            CR.REQUESTNO = REQUESTNO
        End If
        If Isexist = False Then
            If Request("CAMPAIGNID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("CAMPAIGNID")) Then
                CR.CAMPAIGNID = Request("CAMPAIGNID").Trim
            Else
                Util.JSAlert(Me.Page, " Campaignid is incorrect. ")
                Return False
            End If
        End If
        CR.ERPID = lab_ERPID.Text
        CR.STATUS = CRSTATUS
        CR.REQUEST_BY = Lab_REQUEST_BY.Text
        CR.REQUEST_DATE = Now
        CR.LAST_UPD_BY = Session("USER_ID")
        CR.LAST_UPD_DATE = Now
        CR.RBU = Session("RBU")
        CR.PROMOTION_PLAN = TB_PROMOTION_PLAN.Content.Replace("'", "''")
        CR.ROLL_OUT_REGION = TB_ROLL_OUT_REGION.Text.Replace("'", "''")
        CR.ROLL_OUT_TIME = CDate(TB_Roll_out_Time.Text)
        CR.TARGET_AUDIENCE = TB_TargetAudience.Text.Replace("'", "''")
        CR.REQUEST_SUPPORT = TB_REQUEST_SUPPORT.Content.Replace("'", "''")
        If Not Isexist Then
            MyDC.CAMPAIGN_REQUESTs.InsertOnSubmit(CR)
        End If
        Try
            MyDC.SubmitChanges()
            CampaignUtil.InsertLog(CR.REQUESTNO, CRSTATUS, Session("user_id").ToString)
            '''''''''''''''''''''
            InsertMessageBoard()
            Dim userid As String = Session("user_id").ToString.Trim
            Dim CRE As New CAMPAIGN_REQUEST_Expand
            With CRE
                .RequestNO = lab_requestno.Text
                If Not String.IsNullOrEmpty(TB_PROMOTION_PLAN.Content.Trim) Then
                    .Promotion_Plan = TB_PROMOTION_PLAN.Content.Replace("'", "''")
                    .PP_CreateBy = userid
                    .PP_CreateTime = Now
                End If
                If Not String.IsNullOrEmpty(TB_REQUEST_SUPPORT.Content.Trim) Then
                    .Request_Support = TB_REQUEST_SUPPORT.Content.Replace("'", "''")
                    .RS_CreateBy = userid
                    .RS_CreateTime = Now
                End If
            End With
            MyDC.CAMPAIGN_REQUEST_Expands.InsertOnSubmit(CRE)
            MyDC.SubmitChanges()
            ''''''''''''''''''''''
            If CRSTATUS = 1 Then
                CampaignUtil.SendEmail(CR.REQUESTNO, 1)
                CampaignUtil.SendEmail(CR.REQUESTNO, 100)
            End If
            Return True
        Catch ex As Exception
        End Try
        Return False
    End Function

    Protected Sub BTadvSubmit_Click(sender As Object, e As System.EventArgs)
        'If String.IsNullOrEmpty(TB_COMMENT.Text.Trim) Then
        '    Util.JSAlert(Me.Page, "Feedback cannot be empty. ")
        '    Exit Sub
        'End If
        Dim MyDC As New MyCampaignDBDataContext()
        Dim CR As CAMPAIGN_REQUEST = (From MyCR In MyDC.CAMPAIGN_REQUESTs
                    Where MyCR.REQUESTNO = PageRequestNO).FirstOrDefault()
        CR.FEEDBACK = TB_COMMENT.Text.Replace("'", "''")
        CR.LAST_UPD_BY = Session("USER_ID")
        CR.LAST_UPD_DATE = Now
        CR.STATUS = Integer.Parse(DDlSTATUS.SelectedValue)
        MyDC.SubmitChanges()
        CampaignUtil.InsertLog(CR.REQUESTNO, CR.STATUS, Session("user_id").ToString)
        Setlog()
        CampaignUtil.SendEmail(CR.REQUESTNO, 200)
        InsertMessageBoard()
        Util.JSAlertRedirect(Me.Page, " Succeed. ", "CampaignRequest.aspx?REQUESTNO=" + PageRequestNO)
    End Sub

    Protected Sub fup1_UploadedComplete(sender As Object, e As AjaxControlToolkit.AsyncFileUploadEventArgs)
        lbFupMsg.Text = ""
        ScriptManager.RegisterClientScriptBlock(Me, Me.GetType(), "reply", "document.getElementById('" & lbFupMsg.ClientID & "').innerHTML= 'Done!';", True)
        If fup1.HasFile AndAlso _
                               (fup1.FileName.EndsWith(".xls", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".xlsx", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".doc", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".docx", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".pptx", StringComparison.OrdinalIgnoreCase) _
                                  Or fup1.FileName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase) _
                                    Or fup1.FileName.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase) _
                                      Or fup1.FileName.EndsWith(".gif", StringComparison.OrdinalIgnoreCase) _
                                        Or fup1.FileName.EndsWith(".png", StringComparison.OrdinalIgnoreCase) _
                                Or fup1.FileName.EndsWith(".ppt", StringComparison.OrdinalIgnoreCase)) Then
            Dim _stream As IO.Stream = fup1.FileContent
            Dim fileData(_stream.Length) As Byte
            _stream.Read(fileData, 0, _stream.Length)
            Dim userid As String = Session("user_id").ToString.Trim
            Dim MyDC As New MyCampaignDBDataContext()
            Dim CRE As New CAMPAIGN_REQUEST_Expand
            With CRE
                .RequestNO = lab_requestno.Text
                .Files = fileData
                .File_Name = fup1.FileName
                .File_Ext = fup1.FileName.Substring(fup1.FileName.LastIndexOf(".") + 1, fup1.FileName.Length - fup1.FileName.LastIndexOf(".") - 1)
                .File_CreateBy = userid
                .File_CreateTime = Now
            End With
            MyDC.CAMPAIGN_REQUEST_Expands.InsertOnSubmit(CRE)
            MyDC.SubmitChanges()
        End If
 
    End Sub
    Private Sub BindGvPP()
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR = New List(Of CAMPAIGN_REQUEST_Expand)
        If Not String.IsNullOrEmpty(PageRequestNO) Then
            MyCR = MyDC.CAMPAIGN_REQUEST_Expands.Where(Function(P) P.RequestNO = lab_requestno.Text).ToList
            GvPP.DataSource = MyCR.Where(Function(P) P.Promotion_Plan IsNot Nothing).ToList.OrderBy(Function(P) P.PP_CreateTime)
            GvPP.DataBind()
            GvRS.DataSource = MyCR.Where(Function(P) P.Request_Support IsNot Nothing).ToList.OrderBy(Function(P) P.RS_CreateTime)
            'Response.Write(MyCR.Where(Function(P) P.Request_Support IsNot Nothing).ToList.OrderBy(Function(P) P.RS_CreateTime).ToList.Count.ToString)
            GvRS.DataBind()
            RtQA.DataSource = MyCR.Where(Function(P) P.Message_Board IsNot Nothing).ToList.OrderBy(Function(P) P.RS_CreateTime)
            'Response.Write(MyCR.Where(Function(P) P.Message_Board IsNot Nothing).ToList.OrderBy(Function(P) P.RS_CreateTime).ToList.Count.ToString)
            RtQA.DataBind()
        Else
            GvPP.Visible = False
        End If
      
    End Sub
    Public Sub InsertMessageBoard()
        If Not String.IsNullOrEmpty(TB_COMMENT.Text.Trim) AndAlso Not String.Equals(TB_COMMENT.Text.Trim, "Leave your message here...") Then
            Dim userid As String = Session("user_id").ToString.Trim
            Dim MyDC As New MyCampaignDBDataContext()
            Dim CRE As New CAMPAIGN_REQUEST_Expand
            With CRE
                .RequestNO = lab_requestno.Text
                .Message_Board = TB_COMMENT.Text.Trim
                .MS_CreateBy = userid
                .MS_CreateTime = Now
            End With
            MyDC.CAMPAIGN_REQUEST_Expands.InsertOnSubmit(CRE)
            MyDC.SubmitChanges()
            CampaignUtil.SendEmailV2(lab_requestno.Text.Trim, 1, TB_COMMENT.Text)
        End If
     
    End Sub
    'Public Function display(ByVal str As Object) As String
    '    If str IsNot Nothing AndAlso str.ToString.Trim.Length > 0 Then
    '        Return "style=""display:none;"""
    '    End If
    '    Dim MyDC As New MyCampaignDBDataContext()
    '    Dim MyCR As CAMPAIGN_REQUEST = (From CR In MyDC.CAMPAIGN_REQUESTs
    '                       Where CR.REQUESTNO = PageRequestNO).FirstOrDefault()
    '    If MyCR IsNot Nothing Then
    '        If Not MyCR.MarketingManagerMailX.ToString.Contains(Session("user_id").ToString) Then
    '            Return "style=""display:none;"""
    '        End If
    '    End If
    '    Return ""
    'End Function

    'Protected Sub BTan_Click(sender As Object, e As System.EventArgs)
    '    Dim BT As Button = CType(sender, Button)
    '    Dim ID As String = BT.CommandArgument
    '    Dim _RepeaterItem As RepeaterItem = CType(BT.NamingContainer, RepeaterItem)
    '    Dim AN As TextBox = CType(_RepeaterItem.FindControl("TBan"), TextBox)
    '    Dim userid As String = Session("user_id").ToString.Trim
    '    Dim MyDC As New MyCampaignDBDataContext()
    '    Dim CRE As CAMPAIGN_REQUEST_Expand = MyDC.CAMPAIGN_REQUEST_Expands.Where(Function(P) P.ID = ID).FirstOrDefault
    '    With CRE
    '        .Message_Board_Answer = AN.Text.Trim.Replace("'", "''")
    '        .MSA_CreateBy = userid
    '        .MSA_CreateTime = Now
    '    End With
    '    MyDC.SubmitChanges()
    '    CampaignUtil.SendEmailV2(lab_requestno.Text.Trim, 0, AN.Text)
    '    BindGvPP()
    'End Sub
    <Services.WebMethod()> _
      <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetFiles(ByVal RequestNo As String, ByVal str As String) As String
        Dim sb As New System.Text.StringBuilder
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As List(Of CAMPAIGN_REQUEST_Expand) = MyDC.CAMPAIGN_REQUEST_Expands.Where(Function(P) P.RequestNO = RequestNo AndAlso P.File_Name IsNot Nothing).OrderBy(Function(P) P.File_CreateTime).ToList
        With sb
            .AppendLine(String.Format("<table width='100%'>"))
            ' .AppendLine(String.Format("<tr><th>File Name</th><th>Uploader</th></tr>"))
            For Each i As CAMPAIGN_REQUEST_Expand In MyCR
                .AppendLine(String.Format("<tr>" + _
                                          " <td>" + _
                                          "     <a href='Files.aspx?id={0}' target='_blank'>{1}</a>" + _
                                          " </td>" + _
                                          " <td class='hei'>{2}</td>" + _
                                          "</tr>", i.ID, i.File_Name, Util.GetNameVonEmail(i.File_CreateBy)))
            Next
            .AppendLine(String.Format("</table>"))
        End With
        Return sb.ToString()
    End Function
    'Dim filestr As String = String.Empty
    'Private Sub BindFiles()
    '    Dim sb As New System.Text.StringBuilder
    '    Dim MyDC As New MyCampaignDBDataContext()
    '    Dim MyCR As List(Of CAMPAIGN_REQUEST_Expand) = MyDC.CAMPAIGN_REQUEST_Expands.Where(Function(P) P.RequestNO = lab_requestno.Text.Trim AndAlso P.File_Name IsNot Nothing).OrderBy(Function(P) P.File_CreateTime).ToList
    '    With sb
    '        .AppendLine(String.Format("<table width='100%'>"))
    '        ' .AppendLine(String.Format("<tr><th>File Name</th><th>Uploader</th></tr>"))
    '        For Each i As CAMPAIGN_REQUEST_Expand In MyCR
   
    '            .AppendLine(String.Format("<tr>" + _
    '                                      " <td>" + _
    '                                      "     <a href='Files.aspx?id={0}'>{1}</a>" + _
    '                                      " </td>" + _
    '                                      " <td class='hei'>{2}</td>" + _
    '                                      "</tr>", i.ID, i.File_Name, Util.GetNameVonEmail(i.File_CreateBy)))
    '        Next
    '        .AppendLine(String.Format("</table>"))
    '    End With
    '    filestr = sb.ToString()
    'End Sub

    Protected Sub btPPRA_Click(sender As Object, e As System.EventArgs)
        Dim MyDC As New MyCampaignDBDataContext()
        Dim userid As String = Session("user_id")
        If Not String.IsNullOrEmpty(TB_PROMOTION_PLAN.Content.Trim) Then
            Dim CRE As New CAMPAIGN_REQUEST_Expand
            With CRE
                .RequestNO = lab_requestno.Text
                .Promotion_Plan = TB_PROMOTION_PLAN.Content.Replace("'", "''")
                .PP_CreateBy = userid
                .PP_CreateTime = Now
            End With
            MyDC.CAMPAIGN_REQUEST_Expands.InsertOnSubmit(CRE)
            MyDC.SubmitChanges()
        End If
        If Not String.IsNullOrEmpty(TB_REQUEST_SUPPORT.Content.Trim) Then
            Dim CRE As New CAMPAIGN_REQUEST_Expand
            With CRE
                .RequestNO = lab_requestno.Text
                .Request_Support = TB_REQUEST_SUPPORT.Content.Replace("'", "''")
                .RS_CreateBy = userid
                .RS_CreateTime = Now
            End With
            MyDC.CAMPAIGN_REQUEST_Expands.InsertOnSubmit(CRE)
            MyDC.SubmitChanges()
        End If
        'If Not String.IsNullOrEmpty(TB_COMMENT.Text.Trim) Then
        '    Dim CRE As New CAMPAIGN_REQUEST_Expand
        '    With CRE
        '        .Message_Board = TB_COMMENT.Text.Replace("'", "''")
        '        .MS_CreateBy = userid
        '        .MS_CreateTime = Now
        '    End With
        '    MyDC.CAMPAIGN_REQUEST_Expands.InsertOnSubmit(CRE)
        '    MyDC.SubmitChanges()
        'End If
        InsertMessageBoard()
        Util.JSAlertRedirect(Me.Page, " Succeed. ", "CampaignRequest.aspx?REQUESTNO=" + PageRequestNO)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">

    <table width="100%">
        <tr>
            <td align="left">
                <asp:HyperLink runat="server" ID="hyMyCampaigns" NavigateUrl="~/My/Campaign/CampaignList.aspx"
                    Text="My Campaigns" />
            </td>
            <td align="right">
                <asp:HyperLink runat="server" ID="hyUploadTAlist" Text="" Target="_blank" />
            </td>
        </tr>
    </table>
    <table width="100%" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#DADADA"
        style="margin-bottom: 10px; margin-top: 7px;">
        <tr>
            <td colspan="6" align="left" class="cpcs2">
                Campaign Nmae: &nbsp;&nbsp;
                <asp:Label ID="LabCampaignID" runat="server" Text=""></asp:Label>
            </td>
        </tr>
        <tr>
            <td width="150" height="30" bgcolor="#FFFFFF" class="cpcs">
                Theme/Slogan
            </td>
            <td colspan="3" bgcolor="#FFFFFF">
                &nbsp;<asp:Label ID="LabThemeSlogan" runat="server" Text=""></asp:Label>
            </td>
            <td bgcolor="#FFFFFF" class="cpcs">
                Campaign Period
            </td>
            <td width="200" bgcolor="#FFFFFF">
                &nbsp;<asp:Label ID="LabCampaignPeriod" runat="server" Text="" />
            </td>
        </tr>
        <tr>
            <td height="30" bgcolor="#F2F2F2" class="cpcs">
                Key Product/Solution
            </td>
            <td bgcolor="#F2F2F2" class="style2" width="150">
                &nbsp;<asp:Label ID="LabKPS" runat="server" Text="" />
            </td>
            <td bgcolor="#F2F2F2" class="cpcs">
                Sector/Industry
            </td>
            <td bgcolor="#F2F2F2" class="style1">
                &nbsp;<asp:Label ID="LabSI" runat="server" Text="" />
            </td>
            <td bgcolor="#F2F2F2" width="100" class="cpcs">
                SBU Owner
            </td>
            <td bgcolor="#F2F2F2">
                &nbsp;<asp:Label ID="LabSBUOwner" runat="server" Text="" />
            </td>
        </tr>
    </table>
    <table width="100%" border="0" cellpadding="1" cellspacing="1" align="center" bordercolor="#D9D9D9"
        bgcolor="#D9D9D9">
        <tr>
            <td align="center" bgcolor="#D9D9D9" class="BGW">
                RequestNO
            </td>
            <td align="center" bgcolor="#D9D9D9" class="style4">
                Status
            </td>
            <td align="center" bgcolor="#D9D9D9" class="BGW">
                Channel Name
            </td>
            <td align="center" bgcolor="#D9D9D9" class="BGW">
                ERPID
            </td>
        </tr>
        <tr>
            <td bgcolor="#FFFFFF" align="center">
                <asp:Label ID="lab_requestno" runat="server" Text=""></asp:Label>
            </td>
            <td bgcolor="#FFFFFF" align="center" class="style5">
                <asp:Label ID="lab_status" runat="server" Text=""></asp:Label>
            </td>
            <td bgcolor="#FFFFFF" align="center">
                <asp:Label ID="lab_name" runat="server" Text=""></asp:Label>
            </td>
            <td bgcolor="#FFFFFF" height="30" align="center">
                <asp:Label ID="lab_ERPID" runat="server" Text=""></asp:Label>
            </td>
        </tr>
        <tr>
            <td align="center" bgcolor="#0070C0" class="BGH">
                Campaign Owner
            </td>
            <td align="center" bgcolor="#0070C0" class="BGH">
                Roll-out Region
            </td>
            <td align="center" bgcolor="#0070C0" class="BGH">
                Roll-out Time
            </td>
            <td align="center" bgcolor="#0070C0" class="BGH">
                Target Audience
                <asp:Label ID="lab1" Text="#" runat="server" ForeColor="White" Font-Size="9px" />
            </td>
        </tr>
        <tr>
            <td bgcolor="#FFFFFF" height="30" align="center">
                <asp:Label ID="Lab_REQUEST_BY" runat="server" Text=""></asp:Label>
            </td>
            <td bgcolor="#FFFFFF" align="center" class="style5">
                <asp:TextBox ID="TB_ROLL_OUT_REGION" runat="server"></asp:TextBox>
            </td>
            <td bgcolor="#FFFFFF" align="center">
                <asp:TextBox ID="TB_Roll_out_Time" runat="server"></asp:TextBox>
                <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="TB_Roll_out_Time"
                    Format="yyyy/MM/dd" />
            </td>
            <td bgcolor="#FFFFFF" align="center">
                <asp:TextBox ID="TB_TargetAudience" runat="server"></asp:TextBox>
                <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ft1" TargetControlID="TB_TargetAudience"
                    FilterType="Numbers" />
            </td>
        </tr>
        <tr>
            <td colspan="2" align="center" bgcolor="#0070C0" class="BGH">
                Promotion Plan
            </td>
            <td colspan="2" align="center" bgcolor="#0070C0" class="BGH">
                Request Support from Advantech
                 
            </td>
        </tr>
        <tr>
            <td colspan="2" align="left" bgcolor="#FFFFFF" class="BGH" valign="top">
               
                <asp:GridView runat="server" ID="GvPP" AutoGenerateColumns="False" Width="444" ShowHeader="False"
                    BackColor="White" BorderColor="#CC9966" BorderStyle="None" BorderWidth="1px"
                    CellPadding="4" ShowWhenEmpty="False">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <div style="position: relative; cursor: pointer;" onmouseover="document.getElementById('divpp<%# Eval("id")%>').style.display='';"
                                    onmouseout="document.getElementById('divpp<%# Eval("id")%>').style.display='none';">
                                    <%# Eval("Promotion_Plan")%>
                                    <img alt="?" src="../../Images/why.png">
                                    <div id="divpp<%# Eval("id")%>" style="position: absolute; width: 200px; height: 35px;
                                        padding: 3px 3px 6px 8px; border: 1px solid rgb(255, 0, 0); line-height: 20px;
                                        background-color: rgb(255, 255, 255); color: rgb(255, 0, 0); z-index: 99; display: none;">
                                        <%# Eval("PP_CreateBy")%>
                                        <%# Eval("PP_CreateTime")%>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <RowStyle BackColor="White" ForeColor="#330099" />
                    <SortedAscendingCellStyle BackColor="#FEFCEB" />
                    <SortedAscendingHeaderStyle BackColor="#AF0101" />
                    <SortedDescendingCellStyle BackColor="#F6F0C0" />
                    <SortedDescendingHeaderStyle BackColor="#7E0000" />
                </asp:GridView>
                
            </td>
            <td colspan="2" align="center" bgcolor="#FFFFFF" class="BGH" valign="top">
                <asp:GridView runat="server" ID="GvRS" AutoGenerateColumns="False" Width="444" ShowHeader="False"
                    BackColor="White" BorderColor="#CC9966" BorderStyle="None" BorderWidth="1px"
                    CellPadding="4" ShowWhenEmpty="False">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <div style="position: relative; cursor: pointer;" onmouseover="document.getElementById('divrs<%# Eval("id")%>').style.display='';"
                                    onmouseout="document.getElementById('divrs<%# Eval("id")%>').style.display='none';">
                                    <%# Eval("Request_Support")%>
                                    <img alt="?" src="../../Images/why.png">
                                    <div id="divrs<%# Eval("id")%>" style="position: absolute; width: 200px; height: 35px;
                                        padding: 3px 3px 6px 8px; border: 1px solid rgb(255, 0, 0); line-height: 20px;
                                        background-color: rgb(255, 255, 255); color: rgb(255, 0, 0); z-index: 99; display: none;">
                                        <%# Eval("RS_CreateBy")%>
                                        <%# Eval("RS_CreateTime")%>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <RowStyle ForeColor="#330099" BackColor="White" />
                    <SortedAscendingCellStyle BackColor="#FEFCEB" />
                    <SortedAscendingHeaderStyle BackColor="#AF0101" />
                    <SortedDescendingCellStyle BackColor="#F6F0C0" />
                    <SortedDescendingHeaderStyle BackColor="#7E0000" />
                </asp:GridView>
            </td>
        </tr>
        <tr>
            <td colspan="2" bgcolor="#FFFFFF" align="center">
                <uc1:NoToolBarEditor runat="server" ID="TB_PROMOTION_PLAN" Width="100%" Height="150px"
                    AutoFocus="false"/>
                 
            </td>
            <td colspan="2" bgcolor="#FFFFFF" align="center">
                <uc1:NoToolBarEditor runat="server" ID="TB_REQUEST_SUPPORT" Width="100%" Height="150px"
                    AutoFocus="false" />
            </td>
        </tr>
        <tr>
        <td colspan="2"  bgcolor="#FFFFFF">   <ajaxToolkit:AsyncFileUpload runat="server" ID="fup1" ThrobberID="imgUploadingProdPhoto"
                    OnClientUploadError="uploadError" OnClientUploadStarted="StartUpload" OnClientUploadComplete="UploadComplete"
                    CompleteBackColor="Lime" UploaderStyle="Modern" ErrorBackColor="Red" UploadingBackColor="#66CCFF"
                    OnUploadedComplete="fup1_UploadedComplete" CssClass="mytb2"  />
                <asp:Image runat="server" ID="imgUploadingProdPhoto" ImageUrl="~/Images/loading2.gif"
                    AlternateText="Loading..." />
                <asp:Label runat="server" ID="lbFupMsg"></asp:Label></td>
                <td colspan="2"  bgcolor="#FFFFFF"></td>
        </tr>
    </table>
    <p>
        <table width="100%" border="0" cellpadding="1" cellspacing="1" bordercolor="#D9D9D9"
            bgcolor="#D9D9D9" align="center" style="margin-top: 10px;">
            <tr>
                <td bgcolor="#BFBFBF" align="center">
                    <strong>Message Board </strong>
                </td>
            </tr>
            <tr>
                <td bgcolor="#FFFFFF" align="center">
                    <asp:TextBox ID="TB_COMMENT" runat="server" TextMode="MultiLine" Width="99%" Height="50"
                        CssClass="keyword" Text="Leave your message here..."> </asp:TextBox>
                </td>
            </tr>
        </table>
        <table width="100%" border="0" cellpadding="1" cellspacing="1" bordercolor="#D9D9D9"
            align="left" style="margin-top: 10px;" id="tbPPRA" runat="server" visible="false">
            <tr>
                <td height="30" align="center">
                    <asp:Button ID="btPPRA" runat="server" CssClass="BTAN" Text="Submit New Edit" OnClick="btPPRA_Click" />
                </td>
            </tr>
        </table>
        <table width="100%" border="0" cellpadding="1" cellspacing="1" bordercolor="#D9D9D9"
            bgcolor="#D9D9D9" align="left" style="margin-top: 10px;">
            <asp:Repeater ID="RtQA" runat="server">
                <ItemTemplate>
                    <tr>
                        <td bgcolor="#FFFFFF" align="left" style="padding-top: 3px; padding-bottom: 3px;
                            padding-left: 5px;" class="tdbg<%# (Container.ItemIndex + 1) mod 2 %>">
                            <span style="display: inline-block; width: 150px;">
                                <%# Util.GetNameVonEmail(Eval("MS_CreateBy"))%></span> &nbsp;&nbsp;&nbsp;&nbsp;
                            <span>
                                <%# CDate(Eval("MS_CreateTime")).ToString("yyyy-MM-dd   hh:ss")%></span>
                            <br />
                            ● <strong>
                                <%# Eval("Message_Board")%></strong>
                            <%--                <div <%# display(Eval("Message_Board_Answer"))%>>
                                <table style="margin-top: -20px;">
                                    <tr>
                                        <td>
                                            <asp:TextBox ID="TBan" runat="server" TextMode="MultiLine" Height="20" Width="400"
                                                CssClass="TBan"></asp:TextBox>
                                        </td>
                                        <td valign="middle">
                                            <asp:Button ID="BTan" runat="server" Text="Submit" OnClick="BTan_Click" CommandArgument='<%# Eval("ID")%>'
                                                CssClass="btan" />
                                        </td>
                                    </tr>
                                </table>
                            </div>--%>
                        </td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </table>
        <br />
    </p>
    <table width="100%" border="0" align="center" style="margin-top: 10px;">
        <tr>
            <td align="center">
                <asp:Button ID="BTSave" runat="server" CssClass="BTAN" Text="Save for further edit"
                    OnClick="BTSave_Click" />
                &nbsp;&nbsp;&nbsp;&nbsp;
                <asp:Button ID="BTSubmit" runat="server" CssClass="BTAN" Text="Submit" OnClick="BTSubmit_Click" />
            </td>
        </tr>
    </table>
    <table width="100%" border="0" align="center" style="margin-top: 10px;">
        <tr>
            <td align="center" valign="middle" bgcolor="#FFFFFF">
                <asp:Label ID="Lablog" runat="server" Text=""></asp:Label>
            </td>
        </tr>
    </table>
    <asp:Panel ID="AdminPan" runat="server" Visible="false">
        <table width="100%" border="0" align="center" style="margin-top: 10px;">
            <tr>
                <td align="center" valign="middle" bgcolor="#FFFFFF">
                    <asp:DropDownList ID="DDlSTATUS" runat="server">
                    </asp:DropDownList>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:Button ID="BTadvSubmit" runat="server" CssClass="BTAN" Text="Submit" OnClick="BTadvSubmit_Click" />
                </td>
            </tr>
        </table>
    </asp:Panel>
    <br />
    <br />
    <br />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <script language="javascript" type="text/javascript">
        var obj = document.getElementById("<%=TB_COMMENT.ClientID %>");
        obj.onfocus = function () { if (this.value == "Leave your message here...") { this.value = "" } };
        obj.onblur = function () { if (this.value == "") { this.value = "Leave your message here..."; this.className = "keyword"; } };
        obj.onkeydown = function () { if (this.value != "Leave your message here...") { this.className = "keywordover"; } };

    </script>
    <script type="text/javascript">
        window.onload = function () {
            var RequestNo = document.getElementById('<%=lab_requestno.ClientID %>').innerHTML;
            ShowFilesDiv(RequestNo);
        }
        function uploadError(sender, args) {
            alert('Error during upload');
        }

        function StartUpload(sender, args) {

        }

        function UploadComplete(sender, args) {
            //getElementById('myframe').contentWindow.location.reload(true);
            var RequestNo = document.getElementById('<%=lab_requestno.ClientID %>').innerHTML;
            ShowFilesDiv(RequestNo);
        }

        function ShowListPanel() {
            var divMoz = document.getElementById('divList');
            divMoz.style.display = 'block';
        }
        function CloseDivList() {
            var divMoz = document.getElementById('divList');
            divMoz.style.display = 'none';
        }
    </script>
    <script type="text/javascript">
        function ShowFilesDiv(RequestNo) {
            var divlist = document.getElementById('<%=lbFupMsg.ClientID %>');
            PageMethods.GetFiles(RequestNo, "",
                function (pagedResult, eleid, methodName) {
                    divlist.innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                    divlist.innerHTML = "";
                });
        }
    </script>
    <style type="text/css">
        .tdbg0
        {
            background-color: #f2eeee;
        }
        .keyword
        {
            color: #9d9b9b;
            border-width: 1px;
        }
        .keywordover
        {
            border-width: 1px;
            color: #0e0e0e;
        }
        .BGH
        {
            color: #FFFFFF;
            font-weight: bold;
        }
        .hei
        {
            color: #a19c9c;
        }
        .BGW
        {
            color: #000000;
            font-weight: bold;
        }
        .BTAN
        {
            padding-top: 4px;
            padding-bottom: 4px;
            padding-left: 6px;
            padding-right: 6px;
            border-width: thick;
            font-weight: bold;
        }
        input
        {
            text-align: center;
        }
        .cpcs
        {
            padding-left: 5px;
            font-weight: bolder;
        }
        .cpcs2
        {
            background-color: #595959;
            padding-left: 5px;
            color: #FFFFFF;
            font-weight: bolder;
            height: 30px;
        }
    </style>
    <asp:Panel ID="PANCSS" Visible="false" runat="server">
        <style type="text/css">
            input, TEXTAREA
            {
                border-width: 0px;
            }
            .mytb2 input
            {
                border-width: 2px;
            }
            .TBan
            {
                border-width: 1px;
            }
            .mytb
            {
                border-width: 1px;
            }
            .btan
            {
                border-width: 2px;
                height: 20px;
                text-align: center;
                vertical-align: middle;
                line-height: 20px;
            }
        </style>
    </asp:Panel>
</asp:Content>
