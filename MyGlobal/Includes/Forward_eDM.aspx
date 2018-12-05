<%@ Page Title="Forward eDM" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" EnableEventValidation="false" %>

<script runat="server">
    Dim email As String = "", rid As String = ""
    Protected Sub nb1_GenerateChallengeAndResponse(ByVal sender As Object, ByVal e As AjaxControlToolkit.NoBotEventArgs)
        Dim p As New Panel
        p.ID = "NoBotPanel"
        Dim rand As New Random
        With p
            .Width = rand.Next(300) : .Height = rand.Next(200) : .Style.Add(HtmlTextWriterStyle.Visibility, "hidden")
            .Style.Add(HtmlTextWriterStyle.Position, "absolute")
        End With
        CType(sender, AjaxControlToolkit.NoBot).Controls.Add(p)
        e.ChallengeScript = String.Format("var e = document.getElementById('{0}'); e.offsetWidth * e.offsetHeight;", p.ClientID)
        e.RequiredResponse = (p.Width.Value * p.Height.Value).ToString
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select email from email_uniqueid where hashvalue='{0}'", Request("UID")))
        If dt.Rows.Count > 0 Then email = dt.Rows(0).Item(0).ToString
        rid = Request("RID")
        If rid = "" Then btnSubmit.Enabled = False
        Dim dt1 As DataTable = dbUtil.dbGetDataTable("RFM", "select email_subject from campaign_master where row_id='" + rid + "'")
        If dt1.Rows.Count > 0 Then
            lblSubject.Text = dt1.Rows(0).Item(0).ToString
        End If
        If Page.IsPostBack Or ScriptManager.GetCurrent(Page).IsInAsyncPostBack Then
            Dim state As NoBotState = NoBotState.Valid
            If Not nb1.IsValid(state) Then
                Select Case state
                    Case NoBotState.InvalidAddressTooActive
                        Util.JSAlert(Page, "Send too much e-mails in few seconds!")
                    Case NoBotState.InvalidBadResponse
                        Util.JSAlert(Page, "Invalid Response!")
                    Case NoBotState.InvalidBadSession
                        Util.JSAlert(Page, "Session not exist!")
                    Case NoBotState.InvalidResponseTooSoon
                        Util.JSAlert(Page, "Response too quickly!")
                    Case NoBotState.InvalidUnknown
                        Util.JSAlert(Page, "Unknown Error!")
                End Select
            End If
        End If
        
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("http://www.advantech.eu")
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            Dim emails() As String = txtForwardTo.Text.Trim.Split(";")
            Dim invalidEmails As New ArrayList
            For i As Integer = 0 To emails.Length - 1
                Dim reg As String = "^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
                Dim options As RegexOptions = RegexOptions.Singleline
                If Regex.Matches(emails(i), reg, options).Count = 0 Then
                    invalidEmails.Add(emails(i))
                End If
            Next
            If invalidEmails.Count > 0 Then Util.JSAlert(Page, "Email : " + String.Join(";", invalidEmails.ToArray(GetType(System.String))) + ", is not valid!") : Exit Sub
            For i As Integer = 0 To emails.Length - 1
                If CInt(dbUtil.dbExecuteScalar("RFM", String.Format("select count(contact_email) from CAMPAIGN_CONTACT_LIST where campaign_row_id='{0}' and contact_email='{1}' ", rid, emails(i)))) = 0 And dbUtil.dbGetDataTable("RFM", String.Format("select email from UNSUBSCRIBE_EMAIL where email='{0}'", emails(i))).Rows.Count = 0 Then
                    Dim sb As New StringBuilder
                    With sb
                        .AppendFormat("insert into campaign_contact_list (campaign_row_id, contact_email, is_outeremail, is_forward, forward_by, forward_date, forward_comment) values ")
                        .AppendFormat("(@CAMPAIGNROWID, @CONTACTEMAIL, '{0}', '{1}', @FORWARDBY, getdate(), @FORWARDCOMMENT)", False, True)
                    End With
                    Dim pCampaignRowId As New System.Data.SqlClient.SqlParameter("CAMPAIGNROWID", SqlDbType.NVarChar) : pCampaignRowId.Value = rid
                    Dim pContactEmail As New System.Data.SqlClient.SqlParameter("CONTACTEMAIL", SqlDbType.NVarChar) : pContactEmail.Value = emails(i)
                    Dim pForwardBy As New System.Data.SqlClient.SqlParameter("FORWARDBY", SqlDbType.NVarChar) : pForwardBy.Value = email
                    Dim pForwardComment As New System.Data.SqlClient.SqlParameter("FORWARDCOMMENT", SqlDbType.NVarChar) : pForwardComment.Value = HttpUtility.HtmlEncode(txtComment.Text.Trim)
                    Dim para() As System.Data.SqlClient.SqlParameter = {pCampaignRowId, pContactEmail, pForwardBy, pForwardComment}
                    dbUtil.dbExecuteNoQuery2("RFM", sb.ToString, para)
                End If
                Dim ws As New eCampaign_New.EC
                ws.UseDefaultCredentials = True
                ws.Timeout = 500 * 1000
                ws.ForwardCampaignEmail(emails(i), rid, HttpUtility.HtmlEncode(txtComment.Text.Trim))
            Next
            Util.JSAlert(Page, "Forward eDMs successfully!")
        Catch ex As Exception
            Util.SendEmail("rudy.wang@advantech.com.tw,tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Forward eDM error", ex.ToString, True, "", "")
        End Try
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table align="center" border="0" width="500px">
        <tr>
            <td height="10">
                <table border="0" width="220">
                    <tr><td align="center" style="background-color:#003D7C"><font color="white" size="2"><b>Forward Advantech eDM</b></font></td></tr>
                </table>
            </td>
        </tr>
    </table>
    <table align="center" border="1" width="500px" height="350px">
        <tr>
            <td valign="top" align="center">
                <table>
                    <tr><td colspan="2" height="10"></td></tr>
                    <tr><td colspan="2" align="center">Please enter the following information, and click the Submit button.</td></tr>
                    <tr><td colspan="2" height="10"></td></tr>
                    <tr>
                        <td colspan="2" align="left"><font size="2"><b>Subject : </b></font><font color="blue" size="2"><b><asp:Label runat="server" ID="lblSubject" /></b></font></td>
                    </tr>
                    <tr><td colspan="2" height="10"></td></tr>
                    <tr>
                        <td align="right"><font size="2">Email to Your Friend(s)</font></td>
                        <td align="left"><asp:TextBox runat="server" ID="txtForwardTo" Width="300" /><asp:RequiredFieldValidator runat="server" ID="rfv1" Text=" *" ForeColor="Red" ControlToValidate="txtForwardTo" /></td>
                    </tr>
                    <tr><td></td><td align="left"><font color="gray" size="2">Please use " ; " to divide each email address.</font></td></tr>
                    <tr><td colspan="2" height="10"></td></tr>
                    <tr>
                        <td align="right" valign="top"><font size="2">Your Comments</font></td>
                        <td align="left"><asp:TextBox runat="server" ID="txtComment" TextMode="MultiLine" Height="150" Width="300" /></td>
                    </tr>
                    <tr><td colspan="2" height="10"></td></tr>
                    <tr><td colspan="2"><ajaxToolkit:NoBot runat="server" ID="nb1" CutoffMaximumInstances="2" CutoffWindowSeconds="5" ResponseMinimumDelaySeconds="2" OnGenerateChallengeAndResponse="nb1_GenerateChallengeAndResponse" /></td></tr>
                    <tr>
                        <td></td>
                        <td align="left">
                            <asp:Button runat="server" ID="btnSubmit" Text="Submit" OnClick="btnSubmit_Click" />
                            <asp:Button runat="server" ID="btnCancel" Text="Cancel" OnClick="btnCancel_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <br /><br />
</asp:Content>

