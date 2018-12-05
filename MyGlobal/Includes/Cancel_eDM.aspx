<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- Unsubscribe eNews from Advantech" %>

<script runat="server">

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim ws As New eCampaign_New.EC
        'ws.UseDefaultCredentials = True : ws.Timeout = -1
        Dim items As New ArrayList
        Select Case MultiView1.ActiveViewIndex
            Case 1
                For Each item As ListItem In cbl1.Items
                    If item.Selected Then items.Add(item.Value)
                Next
                If cbOther.Checked And HttpUtility.HtmlEncode(txtOther.Text.Trim()) <> "" Then items.Add("Others:" + HttpUtility.HtmlEncode(txtOther.Text.Replace("'", "''").Trim()))
                Dim email As String = UniqueIdToEmail(Trim(Request("ID")))
                Try
                    If UnregEDM(email, String.Join("|", items.ToArray()), Request("CampID"), Request.ServerVariables("REMOTE_HOST")) Then
                        Util.AjaxJSAlertRedirect(up1, "Thank you! You are now unsubscribed from Advantech Newsletters.", "http://www.advantech.com")
                    Else
                        Util.AjaxJSAlertRedirect(up1, "Thank you! You are now unsubscribed from Advantech Newsletters.", "http://www.advantech.com")
                    End If
                Catch ex As Exception
                    'Util.SendTestEmail("Cancel eDM Failed", String.Format("<table border='1'><tr><td>{0}</td></tr><tr><td>{1}</td></tr><tr><td>{2}</td></tr><tr><td>{3}</td></tr></table>",email, String.Join("|", items.ToArray()), Request("CampID"), Request.ServerVariables("REMOTE_HOST")))
                    dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("INSERT INTO UNSUBSCRIBE_EMAIL (EMAIL,IS_SUCCESS,REASON,CAMPAIGN_ROW_ID,IP) VALUES ('{0}',0,'{1}','{2}','{3}')", email, String.Join("|", items.ToArray()), Request("CampID"), Request.ServerVariables("REMOTE_HOST")))
                    Util.AjaxJSAlertRedirect(up1, "Thank you! You are now unsubscribed from Advantech Newsletters.", "http://www.advantech.com")
                End Try
            Case 2
                For Each item As ListItem In cbl_JP.Items
                    If item.Selected Then items.Add(item.Value)
                Next
                If cbOther_JP.Checked And HttpUtility.HtmlEncode(txtOther_JP.Text.Trim()) <> "" Then items.Add("Others:" + HttpUtility.HtmlEncode(txtOther_JP.Text.Replace("'", "''").Trim()))
                Dim email As String = UniqueIdToEmail(Trim(Request("ID")))
                Try
                    If UnregEDM(email, String.Join("|", items.ToArray()), Request("CampID"), Request.ServerVariables("REMOTE_HOST")) Then
                        Util.AjaxJSAlertRedirect(up1, "Thank you! You are now unsubscribed from Advantech Newsletters.", "http://www.advantech.co.jp/")
                    Else
                        Util.AjaxJSAlertRedirect(up1, "Thank you! You are now unsubscribed from Advantech Newsletters.", "http://www.advantech.co.jp/")
                    End If
                Catch ex As Exception
                    'Util.SendTestEmail("Cancel eDM Failed", String.Format("<table border='1'><tr><td>{0}</td></tr><tr><td>{1}</td></tr><tr><td>{2}</td></tr><tr><td>{3}</td></tr></table>",email, String.Join("|", items.ToArray()), Request("CampID"), Request.ServerVariables("REMOTE_HOST")))
                    dbUtil.dbExecuteNoQuery("MYLOCAL", String.Format("INSERT INTO UNSUBSCRIBE_EMAIL (EMAIL,IS_SUCCESS,REASON,CAMPAIGN_ROW_ID,IP) VALUES ('{0}',0,'{1}','{2}','{3}')", email, String.Join("|", items.ToArray()), Request("CampID"), Request.ServerVariables("REMOTE_HOST")))
                    Util.AjaxJSAlertRedirect(up1, "Thank you! You are now unsubscribed from Advantech Newsletters.", "http://www.advantech.co.jp/")
                End Try
        End Select




        ''Dim ws As New eCampaign_New.EC
        'Dim ws As New eCampaign.EC
        'ws.Credentials = System.Net.CredentialCache.DefaultCredentials
        'ws.Timeout = -1
        'Dim items As New ArrayList
        'For Each item As ListItem In cbl1.Items
        '    If item.Selected Then items.Add(item.Value)
        'Next
        'If cbOther.Checked And HttpUtility.HtmlEncode(txtOther.Text.Trim()) <> "" Then items.Add("Others:" + HttpUtility.HtmlEncode(txtOther.Text.Trim()))
        'If True Or ws.UnregEDM(ws.UniqueIdToEmail(Trim(Request("ID"))), String.Join("|", items.ToArray(GetType(String))), Request.ServerVariables("REMOTE_HOST").ToString) Then
        '    'If True Or ws.UnregEDM(ws.UniqueIdToEmail(Trim(Request("ID"))), String.Join("|", items.ToArray(GetType(String))), Request("CampID")) Then
        '    'mpe1.Hide()
        '    'lblOK.Visible = True
        '    Util.JSAlertRedirect(Me.Page, "Thank you! You are unsubscribed to Advantech email newsletters.", "http://www.advantech.eu")
        '    'Util.AjaxJSAlertRedirect(up1, "Thank you! You're unsubscribed to Advantech email newsletters.", "http://www.advantech.eu")

        '    'up2.Update()
        '    'Util.AjaxRedirect(up2, "http://www.advantech.eu")
        '    'Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", Me.txtEmail.Text + " request to cancel eDM, ok", "", False, "", "")
        'Else
        '    'Util.AjaxJSAlertRedirect(up2, "Unable to process this request", "http://www.advantech.eu")
        '    'Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", Me.txtEmail.Text + " request to cancel eDM, fail", "", False, "", "")
        'End If

    End Sub

    Function UniqueIdToEmail(ByVal ID As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("RFM", String.Format("select email from EMAIL_UNIQUEID where HASHVALUE='{0}'", ID))
        If obj IsNot Nothing Then Return obj.ToString
        Return ""
    End Function

    Public Function UnregEDM(ByVal email As String, ByVal reason As String, ByVal campaign_row_id As String, ByVal IP As String) As Boolean
        'Dim ws As New aeu_eai.Siebel_WS
        'Dim ws As New aeu_eai2000.Siebel_WS
        'ws.UseDefaultCredentials = True
        'ws.Timeout = 500 * 1000
        Dim retCode As Boolean = False

        '20150429: If IoTMart eDM, do not update Siebel Never Email
        If CInt(dbUtil.dbExecuteScalar("RFM", "select COUNT(ROW_ID) from CAMPAIGN_MASTER where ENEWS like '%IoTMart eNews%' and ROW_ID='" + campaign_row_id.Replace("'", "") + "'")) = 0 Then
            Try
                'retCode = ws.UpdateContactNeverEmail(email, True)
                'dbUtil.dbExecuteNoQuery("RFM", String.Format("update siebel_contact set NeverEmail='Y' where email_address='{0}'", email))
            Catch ex As Exception

            End Try
        Else
            retCode = True
        End If

        'If CInt(dbUtil.dbExecuteScalar("RFM", String.Format("select count(*) from UNSUBSCRIBE_EMAIL where email='{0}'", Replace(email, "'", "''")))) = 0 Then

        If retCode Then
            Dim sql As String = String.Format("INSERT INTO UNSUBSCRIBE_EMAIL (EMAIL,IS_SUCCESS,REASON,CAMPAIGN_ROW_ID,IP) VALUES ('{0}',1,@REASON,@CAMPAIGN_ROW_ID,'{1}')", Replace(email, "'", "''"), IP)
            Dim tmpReason As New SqlClient.SqlParameter("REASON", SqlDbType.NVarChar) : tmpReason.Value = reason
            Dim tmpCampaignId As New SqlClient.SqlParameter("CAMPAIGN_ROW_ID", SqlDbType.NVarChar) : tmpCampaignId.Value = campaign_row_id
            Dim para() As SqlClient.SqlParameter = {tmpReason, tmpCampaignId}
            dbUtil.dbExecuteNoQuery2("RFM", sql, para)
            'Try
            '    Dim tmpReason1 As New SqlClient.SqlParameter("REASON", SqlDbType.NVarChar) : tmpReason1.Value = reason
            '    Dim tmpCampaignId1 As New SqlClient.SqlParameter("CAMPAIGN_ROW_ID", SqlDbType.NVarChar) : tmpCampaignId1.Value = campaign_row_id
            '    Dim para1() As SqlClient.SqlParameter = {tmpReason1, tmpCampaignId1}
            '    dbUtil.dbExecuteNoQuery("eCampaign", sql, para1)
            'Catch ex As Exception
            '    Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Unsubscribe Email Failed", sql + "<br/>" + ex.ToString, True, "", "")
            'End Try
        Else
            Dim sql As String = ""
            If dbUtil.dbGetDataTable("RFM", String.Format("select * from siebel_contact where email_address='{0}'", Replace(email, "'", "''"))).Rows.Count > 0 Then
                sql = String.Format("INSERT INTO UNSUBSCRIBE_EMAIL (EMAIL,IS_SUCCESS,REASON,CAMPAIGN_ROW_ID,IP) VALUES ('{0}',0,@REASON,@CAMPAIGN_ROW_ID,'{1}')", Replace(email, "'", "''"), IP)
            Else
                sql = String.Format("INSERT INTO UNSUBSCRIBE_EMAIL (EMAIL,IS_SUCCESS,REASON,CAMPAIGN_ROW_ID,IP) VALUES ('{0}',1,@REASON,@CAMPAIGN_ROW_ID,'{1}')", Replace(email, "'", "''"), IP)
            End If
            Dim tmpReason As New SqlClient.SqlParameter("REASON", SqlDbType.NVarChar) : tmpReason.Value = reason
            Dim tmpCampaignId As New SqlClient.SqlParameter("CAMPAIGN_ROW_ID", SqlDbType.NVarChar) : tmpCampaignId.Value = campaign_row_id
            Dim para() As SqlClient.SqlParameter = {tmpReason, tmpCampaignId}
            dbUtil.dbExecuteNoQuery2("RFM", sql, para)
            'Try
            '    Dim tmpReason1 As New SqlClient.SqlParameter("REASON", SqlDbType.NVarChar) : tmpReason1.Value = reason
            '    Dim tmpCampaignId1 As New SqlClient.SqlParameter("CAMPAIGN_ROW_ID", SqlDbType.NVarChar) : tmpCampaignId1.Value = campaign_row_id
            '    Dim para1() As SqlClient.SqlParameter = {tmpReason1, tmpCampaignId1}
            '    dbUtil.dbExecuteNoQuery("eCampaign", sql, para1)
            'Catch ex As Exception
            '    Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Unsubscribe Email Failed", sql + "<br/>" + ex.ToString, True, "", "")
            'End Try
        End If
        'Else
        '    If retCode Then
        '        Dim sql As String = String.Format("update UNSUBSCRIBE_EMAIL set IS_SUCCESS=1,REASON=@REASON where EMAIL='{0}'", Replace(email, "'", "''"))
        '        Dim tmpReason As New SqlClient.SqlParameter("REASON", SqlDbType.NVarChar) : tmpReason.Value = reason
        '        Dim para() As SqlClient.SqlParameter = {tmpReason}
        '        dbUtil.dbExecuteNoQuery("RFM", sql, para)
        '    Else
        '        Dim sql As String = ""
        '        If dbUtil.dbGetDataTable("RFM", String.Format("select * from siebel_contact where email_address='{0}'", Replace(email, "'", "''"))).Rows.Count > 0 Then
        '            sql = String.Format("update UNSUBSCRIBE_EMAIL set IS_SUCCESS=0,REASON=@REASON where EMAIL='{0}'", Replace(email, "'", "''"))
        '        Else
        '            sql = String.Format("update UNSUBSCRIBE_EMAIL set IS_SUCCESS=1,REASON=@REASON where EMAIL='{0}'", Replace(email, "'", "''"))
        '        End If
        '        Dim tmpReason As New SqlClient.SqlParameter("REASON", SqlDbType.NVarChar) : tmpReason.Value = reason
        '        Dim para() As SqlClient.SqlParameter = {tmpReason}
        '        dbUtil.dbExecuteNoQuery("RFM", sql, para)
        '    End If
        'End If
        Return retCode
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack AndAlso Request("ID") IsNot Nothing Then
            'Dim ws As New eCampaign_New.EC
            'ws.UseDefaultCredentials = True : ws.Timeout = -1
            'ws.Credentials = System.Net.CredentialCache.DefaultCredentials
            'Me.txtEmail.Text = ws.UniqueIdToEmail(Trim(Request("ID")))
            'Response.Write(ws.UniqueIdToEmail(Trim(Request("ID"))))
            mpe1.Show()
        End If
    End Sub

    Protected Sub btnCancle_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Util.AjaxRedirect(up2, "http://www.advantech.eu")
        Util.AjaxRedirect(up1, "http://www.advantech.com")
    End Sub

    Public Function ConvertHashToEmail(ByVal hashvalue As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 email from email_uniqueid where hashvalue=N'{0}'", hashvalue.Replace("'", "").Trim()))
        If obj IsNot Nothing Then Return obj.ToString Else Return ""
    End Function

    Function GetView() As Integer
        If Request("lang") IsNot Nothing AndAlso Request("lang").Trim.ToUpper() = "AJP" Then
            Return 2
        Else
            Return 1
        End If
    End Function

    Protected Sub sqlUnsub_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim ws As New eCampaign_New.EC
        'ws.UseDefaultCredentials = True : ws.Timeout = -1
        Dim email As String = UniqueIdToEmail(Trim(Request("ID")))
        Dim sql As String = String.Format("select distinct name as value from SIEBEL_CONTACT_INTERESTED_ENEWS where CONTACT_ROW_ID in (select row_id from SIEBEL_CONTACT where EMAIL_ADDRESS='{0}')", email)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        If dt.Rows.Count > 0 Then
            MultiView1.ActiveViewIndex = 0
            sqlUnsub.SelectCommand = sql
        Else
            MultiView1.ActiveViewIndex = GetView()
        End If
    End Sub

    Protected Sub btnUnsub_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        MultiView1.ActiveViewIndex = GetView()
        'Dim siebel_ws As New aeu_eai2000.Siebel_WS
        'siebel_ws.UseDefaultCredentials = True
        'siebel_ws.Timeout = 500 * 1000
        Dim UnInterestedEnews As New ArrayList
        For i As Integer = 0 To cblUnSub.Items.Count - 1
            If cblUnSub.Items(i).Selected = True Then UnInterestedEnews.Add(cblUnSub.Items(i).Value)
        Next

        'Dim ws As New eCampaign_New.EC
        'ws.Credentials = System.Net.CredentialCache.DefaultCredentials
        'ws.Timeout = 500 * 1000

        Dim email As String = UniqueIdToEmail(Trim(Request("ID")))
        Dim retValue As Boolean = False
        If UnInterestedEnews.Count > 0 Then
            '    retValue = siebel_ws.SubscribeENews2(email, String.Join("|", UnInterestedEnews.ToArray()), False)
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format("delete from SIEBEL_CONTACT_INTERESTED_ENEWS where contact_row_id in (select row_id from siebel_contact where email_address='{0}')", email))
                For Each item As String In UnInterestedEnews
                    dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_DATA_CHANGE (CONTACT_ROW_ID,EMAIL_ADDRESS,CATEGORY,FIELD,ACTION,VALUE,TIMESTAMP) values ('','{0}','Interested eNews','NAME','Delete','{1}',getdate()) ", email, item.Replace("'", "''")))
                Next
            Catch ex As Exception

            End Try
        End If

        mpe1.Show()
    End Sub

    Protected Sub btnUpdEmail_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            Dim camp_id As String = IIf(Request("CampID") IsNot Nothing, Request("CampID").Replace("'", ""), "")
            Dim hashcode As String = IIf(Request("ID") IsNot Nothing, Request("ID").Replace("'", ""), "")
            Dim email As String = UniqueIdToEmail(hashcode).Replace("'", "")
            Dim dtCamp As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 created_by, campaign_name from campaign_master where row_id='{0}'", camp_id))
            If dtCamp IsNot Nothing AndAlso dtCamp.Rows.Count > 0 AndAlso email <> "" Then
                Dim sendTo As String = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 PrimarySmtpAddress from ADVANTECH_ADDRESSBOOK where Name like '{0}%'", dtCamp.Rows(0).Item("created_by").ToString.Split("\")(1))).ToString.Replace("'", "")
                Dim IsExisting As Boolean = False
                If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(ROW_ID) from siebel_contact where email_address='{0}'", email))) > 0 Then
                    IsExisting = True
                End If
                Dim mailbody As New StringBuilder
                Dim owner_name As String = dtCamp.Rows(0).Item("created_by").ToString.Split("\")(1).Split(".")(0)
                Select Case IsExisting
                    Case True
                        With mailbody
                            .AppendFormat("<html><table>")
                            .AppendFormat("<tr><td>Hi {0},</td></tr>", owner_name.Substring(0, 1).ToUpper() + owner_name.Substring(1).ToLower())
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td>Contact email change request has been made to <u>existing</u> Siebel contact from <b>{0}</b></td></tr>", dtCamp.Rows(0).Item("campaign_name").ToString)
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td>Old Email: {0}</td></tr>", email)
                            .AppendFormat("<tr><td>New Email: {0}</td></tr>", txtUpdEmail.Text)
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td><a href='http://my.advantech.com/DM/ContactDashboard.aspx?EMAIL={0}'>You can check the contact entry here.</a></td></tr>", email)
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td>Thanks,</td></tr>")
                            .AppendFormat("<tr><td>Advantech eStore</td></tr>")
                            .AppendFormat("</table></html>")
                        End With
                    Case False
                        With mailbody
                            .AppendFormat("<html><table>")
                            .AppendFormat("<tr><td>Hi {0},</td></tr>", owner_name.Substring(0, 1).ToUpper() + owner_name.Substring(1).ToLower())
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td>Contact email change request has been made to <ul>non-existing</ul> Siebel contact from <b>{0}</b></td></tr>", dtCamp.Rows(0).Item("campaign_name").ToString)
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td>Old Email: {0}</td></tr>", email)
                            .AppendFormat("<tr><td>New Email: {0}</td></tr>", txtUpdEmail.Text)
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td>Please manually add contact into Siebel database.</td></tr>")
                            .AppendFormat("<tr><td height='10'></td></tr>")
                            .AppendFormat("<tr><td>Thanks,</td></tr>")
                            .AppendFormat("<tr><td>Advantech eStore</td></tr>")
                            .AppendFormat("</table></html>")
                        End With
                End Select
                MailUtil.SendEmail(sendTo, "MyAdvantech@advantech.com", "eDM Unsubscribe Form - Contact Email Update Request", mailbody.ToString, True, "", "")
            End If
        Catch ex As Exception

        End Try
        Util.AjaxJSAlertRedirect(up1, "Thank you! Your contact email has been updated.", "http://www.advantech.com")
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <table width="100%">
        <tr>
            <td>
                <asp:LinkButton runat="server" ID="link1" />
                <ajaxToolkit:ModalPopupExtender runat="server" ID="mpe1" BehaviorID="modalPopup1" PopupControlID="Panel1" 
                    PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground">
                </ajaxToolkit:ModalPopupExtender>
                <asp:Panel runat="server" ID="Panel1">
                    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:MultiView runat="server" ID="MultiView1" ActiveViewIndex="0">
                                <asp:View runat="server" ID="view1">
                                    <table border="0" cellpadding="0" cellspacing="10" width="700" bgcolor="f1f2f4">
                                        <tr runat="server" id="trUnsub">
                                            <td>
                                                <table width="100%">
                                                    <tr><td height="10"></td></tr>
                                                    <tr>
                                                        <td align="center" style="font-size:medium; color:red"><b>Unsubscribe your eNews</b></td>
                                                    </tr>
                                                    <tr><td height="5"></td></tr>
                                                    <tr>
                                                        <td style="color:red">The following eNewsletter list is the list you subscribed from Advantech.</td>
                                                    </tr>
                                                    <tr><td height="5"></td></tr>
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBoxList runat="server" ID="cblUnSub" DataSourceID="sqlUnsub" DataTextField="value" DataValueField="value" RepeatColumns="4" RepeatDirection="Horizontal">
                                                            </asp:CheckBoxList>
                                                            <asp:SqlDataSource runat="server" ID="sqlUnsub" ConnectionString="<%$connectionStrings:MY %>"
                                                                    SelectCommand="" OnLoad="sqlUnsub_Load">
                                                            </asp:SqlDataSource>
                                                        </td>
                                                    </tr>
                                                    <tr><td height="5"></td></tr>
                                                    <tr>
                                                        <td align="center">
                                                            <asp:Button runat="server" ID="btnUnsub" Text="Unsubscribe" Width="100" Height="20" OnClick="btnUnsub_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:View>
                                <asp:View runat="server" ID="view2">
                                    <table border="0" cellpadding="0" cellspacing="10" width="750" bgcolor="f1f2f4">
                                        <tr>
                                            <td>
                                                <table width="100%">
                                                    <tr><td height="5"></td></tr>
                                                    <tr>
                                                        <td align="center" style="font-size:medium; color:red"><b>Help Us to Improve Our Email Communications</b></td>
                                                    </tr>
                                                    <tr><td height="10"></td></tr>
                                                    <tr>
                                                        <td style="color:red">&nbsp;We understand you've expressed your wish to receive no further email communications (eNewsletter and/or eDM) from Advantech.<br />
                                                            &nbsp;Please help us to improve our service by telling us why.</td>
                                                    </tr>
                                                    <tr><td height="10"></td></tr>
                                                    <tr>
                                                        <td style="color:red">&nbsp;I want to unsubscribe from Advantech email newsletters because (please tick whichever is applicable):</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBoxList runat="server" ID="cbl1" RepeatColumns="1" RepeatDirection="Vertical">
                                                                <asp:ListItem Text="Not interested with Advantech products / services" Value="Not interested with Advantech products / services" />
                                                                <asp:ListItem Text="Content is not useful in my decision making" Value="Content is not useful in my decision making" />
                                                                <asp:ListItem Text="No longer with the company / department" Value="No longer with the company / department" />
                                                                <asp:ListItem Text="Too many spam mails" Value="Too many spam mails" />
                                                            </asp:CheckBoxList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            <table>
                                                                <tr>
                                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbOther" Text="Other : " /></td>
                                                                    <td><asp:TextBox runat="server" ID="txtOther" Width="450px" Height="50px" TextMode="MultiLine" /></td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr><td height="10"></td></tr>
                                                    <tr>
                                                        <td align="center">
                                                            <asp:Button runat="server" ID="btnSubmit" Text="Unsubscribe" Width="80" Height="20" OnClick="btnSubmit_Click" />
                                                            <asp:Button runat="server" ID="btnCancle" Text="Cancel" Width="80" Height="20" OnClick="btnCancle_Click" />
                                                        </td>
                                                    </tr>
                                                    <tr><td height="5"></td></tr>
                                                </table>
                                                <% If Request("ID") = "A3x3qA" Then%>
                                                <br />
                                                <table width="90%">
                                                    <tr>
                                                        <td colspan="2" style="color:red">&nbsp;I want to update my contact email and still receive Advantech newsletters</td>
                                                    </tr>
                                                    <tr>
                                                        <td width="160"><asp:CheckBox runat="server" ID="cbUpdEmail" Text=" Update E-mail Address" /></td>
                                                        <td><asp:TextBox runat="server" ID="txtUpdEmail" Width="250px" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" align="center"><asp:Button runat="server" ID="btnUpdEmail" Text="Update" Width="80" Height="20" OnClick="btnUpdEmail_Click" /></td>
                                                    </tr>
                                                </table>
                                                <% End If%>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:View>
                                <asp:View runat="server" ID="view_JP">
                                    <table border="0" cellpadding="0" cellspacing="10" width="750" bgcolor="f1f2f4">
                                        <tr>
                                            <td>
                                                <table width="100%">
                                                    <tr><td height="5"></td></tr>
                                                    <tr>
                                                        <td align="center" style="font-size:medium; color:red"><b>今後のメール配信改善のためサポートさせてください</b></td>
                                                    </tr>
                                                    <tr><td height="10"></td></tr>
                                                    <tr>
                                                        <td style="color:red">&nbsp;お客様が当社からのメルマガ配信を停止する旨、
                                                            承知致しました。
                                                        </td>
                                                    </tr>
                                                    <tr><td height="10"></td></tr>
                                                    <tr>
                                                        <td style="color:red">&nbsp;メールを配信停止する理由(複数選択可):</td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:CheckBoxList runat="server" ID="cbl_JP" RepeatColumns="1" RepeatDirection="Vertical">
                                                                <asp:ListItem Text="アドバンテック製品 / サービスに興味がないから" Value="Not interested with Advantech products / services" />
                                                                <asp:ListItem Text="メール配信の内容がつまらないから" Value="Content is not useful in my decision making" />
                                                                <asp:ListItem Text="退職 / 部署移動するから" Value="No longer with the company / department" />
                                                                <asp:ListItem Text="スパムメールが多いから" Value="Too many spam mails" />
                                                            </asp:CheckBoxList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            <table>
                                                                <tr>
                                                                    <td valign="top"><asp:CheckBox runat="server" ID="cbOther_JP" Text="その他 : " /></td>
                                                                    <td><asp:TextBox runat="server" ID="txtOther_JP" Width="450px" Height="50px" TextMode="MultiLine" /></td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr><td height="10"></td></tr>
                                                    <tr>
                                                        <td align="center">
                                                            <asp:Button runat="server" ID="Button1" Text="配信停止する" Width="80" Height="20" OnClick="btnSubmit_Click" />
                                                            <asp:Button runat="server" ID="Button2" Text="キャンセル" Width="80" Height="20" OnClick="btnCancle_Click" />
                                                        </td>
                                                    </tr>
                                                    <tr><td height="5"></td></tr>
                                                </table>
                                                <% If Request("ID") = "A3x3qA" Then%>
                                                <br />
                                                <table width="90%">
                                                    <tr>
                                                        <td colspan="2" style="color:red">&nbsp;I want to update my contact email and still receive Advantech newsletters</td>
                                                    </tr>
                                                    <tr>
                                                        <td width="160"><asp:CheckBox runat="server" ID="CheckBox2" Text=" Update E-mail Address" /></td>
                                                        <td><asp:TextBox runat="server" ID="TextBox2" Width="250px" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" align="center"><asp:Button runat="server" ID="Button3" Text="Update" Width="80" Height="20" OnClick="btnUpdEmail_Click" /></td>
                                                    </tr>
                                                </table>
                                                <% End If%>
                                            </td>
                                        </tr>
                                    </table>
                                </asp:View>
                            </asp:MultiView>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </asp:Panel>
            </td>
        </tr>
    </table>
</asp:Content>
