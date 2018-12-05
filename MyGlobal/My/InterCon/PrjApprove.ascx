<%@ Control Language="VB" ClassName="PrjApprove" %>
<%@ Import Namespace="InterConPrjReg" %>
<script runat="server">
    Dim R As MY_PRJ_REG_MASTERRow = Nothing
    Dim Sstr As String = "", spanstr As String = "<hr/>"
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request("ROW_ID") IsNot Nothing AndAlso Trim(Request("ROW_ID")) <> String.Empty Then
            Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
            R = Prj_M_A.GetDataByRowID(Request("ROW_ID")).Rows(0)
            Sstr = GetColor("submitted") + " by " + GetColor(R.CREATED_BY) + " on " + GetColor(R.CREATED_DATE)
            Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
            Dim Sdt As InterConPrjReg.MY_PRJ_REG_AUDITDataTable = Prj_S_A.GetByPRJ_ROW_ID(Request("ROW_ID"))
            If Sdt.Rows.Count > 0 Then
                Dim Srow As MY_PRJ_REG_AUDITRow = Sdt.Rows(0)
                Select Case Srow.STATUS
                    Case 0
                        Lbshowtitle.Text = "Sales Review:"
                        btapp.CommandArgument = 1 : btrej.CommandArgument = 2
                        btnDelete.Enabled = True

                        'ICC 2016/3/8 Add right for MyAdvantech and ChannelManagement.ACL group to approve or reject apply.
                        If MailUtil.IsInRole("MyAdvantech") OrElse MailUtil.IsInRole("ChannelManagement.ACL") OrElse MailUtil.IsInRole("DMKT.ACL") Then Exit Select
                        'ICC 2016/5/19 Change this function parameter
                        Dim strCPOwner As String = InterConPrjRegUtil.GetPriSalesOwnerOfAccount(R.ROW_ID)
                        If strCPOwner <> String.Empty Then
                            Dim strCPOwnerBoss As String = InterConPrjRegUtil.GetSalesOwnerDirectBoss(strCPOwner)
                            If strCPOwnerBoss = String.Empty Then strCPOwnerBoss = "sieowner@advantech.com.tw"
                            If Not HttpContext.Current.User.Identity.Name.Equals(strCPOwner, StringComparison.OrdinalIgnoreCase) And _
                                Not HttpContext.Current.User.Identity.Name.Equals(strCPOwnerBoss, StringComparison.OrdinalIgnoreCase) Then
                                btapp.Enabled = False : btrej.Enabled = False : lbMsg.Text = "Waiting for " + Util.GetNameVonEmail(strCPOwner) + "'s approval"
                            End If
                        Else
                            btapp.Enabled = False : btrej.Enabled = False
                        End If
                    Case 1, 2
                        TRapp.Visible = False
                        Dim Srow_SALES_BY As String = " "
                        Try
                            Srow_SALES_BY = Srow.SALES_BY
                        Catch ex As Exception
                        End Try
                        Sstr += spanstr + GetColor([Enum].GetName(GetType(InterConPrjRegUtil.Prj_Status), Srow.STATUS)) + " by " + GetColor(Srow_SALES_BY) + " on " + GetColor(Srow.SALES_APP_DATE)
                        If Srow.STATUS = 2 Then
                            Sstr += spanstr + "<strong>Reject comment : </strong>" + Srow.REASONWONLOST
                        ElseIf Srow.STATUS = 1 Then
                            Dim dtCourse As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select SALES_BY, OPTY_SATEG, CREATED_DATE from MY_PRJ_REG_OPTY_COURSE where PRJ_ROW_ID = '{0}' order by CREATED_DATE ", Request("ROW_ID")))
                            If Not dtCourse Is Nothing AndAlso dtCourse.Rows.Count > 0 Then
                                Dim sbCourse As New StringBuilder()
                                For Each dr As DataRow In dtCourse.Rows
                                    sbCourse.AppendFormat("{0}{1} to {2} by {3} on {4}", spanstr, GetColor("Update"), GetColor(dr.Item("OPTY_SATEG").ToString), GetColor(dr.Item("SALES_BY").ToString), GetColor(dr.Item("CREATED_DATE").ToString))
                                Next
                                Sstr += sbCourse.ToString
                            End If
                        End If
                    Case 7
                        btapp.Enabled = False : btrej.Enabled = False : btnDelete.Enabled = False
                        Sstr += spanstr + GetColor([Enum].GetName(GetType(InterConPrjRegUtil.Prj_Status), Srow.STATUS)) + " by " + GetColor(Srow.SALES_BY) + " on " + GetColor(Srow.SALES_APP_DATE)
                    Case Else
                        TRapp.Visible = False
                End Select
                prjs.Text = Sstr
            Else
                TRapp.Visible = False
            End If
        End If
    End Sub
    Protected Sub btapp_Click(sender As Object, e As System.EventArgs)
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        Dim statusNum As Integer = Integer.Parse(CType(sender, Button).CommandArgument)
        Select Case statusNum
            Case 1
                Prj_S_A.UpdateForSales(1, Session("user_id"), Now(), dlRejReason.Text.Replace("'", "''"), Request("ROW_ID"))
                InterConPrjRegUtil.Sendmail(Request("ROW_ID"), "Sales Approved project registration", statusNum)
                InterConPrjRegUtil.update_Siebel(Request("ROW_ID"), "25% Proposing/Quoting", InterConPrjRegUtil.GetTotalAmountByID(Request("ROW_ID")), "")
        End Select
        Response.Redirect("PrjDetail.aspx?ROW_ID=" + Request("ROW_ID") + "")
    End Sub
    Protected Sub btrej_Click(sender As Object, e As System.EventArgs)
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        Dim statusNum As Integer = Integer.Parse(CType(sender, Button).CommandArgument)
        Select Case statusNum
            Case 2
                Prj_S_A.UpdateReject(2, Session("user_id"), Now(), dlRejReason.Text.Replace("'", "''").Replace("Please Enter reason", ""), Request("ROW_ID"))
                InterConPrjRegUtil.Sendmail(Request("ROW_ID"), "Sales Rejected project registration", statusNum)
        End Select
        InterConPrjRegUtil.update_Siebel(Request("ROW_ID"), "Rejected by Sales", InterConPrjRegUtil.GetTotalAmountByID(Request("ROW_ID")), dlRejReason.Text.Replace("'", "''"))
        Response.Redirect("PrjDetail.aspx?ROW_ID=" + Request("ROW_ID") + "")
    End Sub
    Public Function GetColor(ByVal str As String) As String
        Return (String.Format(" <font color=""Red""> [ {0} ] </font>", str))
    End Function

    Protected Sub btnDelete_Click(sender As Object, e As EventArgs)
        Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
        Prj_S_A.UpdateReject(7, Session("user_id"), Now(), dlRejReason.Text.Replace("'", "''").Replace("Please Enter reason", ""), Request("ROW_ID"))
        InterConPrjRegUtil.update_Siebel(Request("ROW_ID"), "Rejected by Partner", InterConPrjRegUtil.GetTotalAmountByID(Request("ROW_ID")), dlRejReason.Text.Replace("'", "''"))
        InterConPrjRegUtil.Sendmail(Request("ROW_ID"), "Partner Rejected project registration", 7)
        Response.Redirect("PrjDetail.aspx?ROW_ID=" + Request("ROW_ID") + "")
    End Sub
</script>
<style type="text/css">
    .unwatermarked
    {
        height: 18px;
        width: 148px;
    }
    .watermarked
    {
        height: 20px;
        width: 150px;
        padding: 2px 0 0 2px;
        border: 1px solid #BEBEBE;
        background-color: #F0F8FF;
        color: gray;
    }
</style>
<h2>
    Project Status Update</h2>
<table width="100%" align="center">
    <tr>
        <td align="center">
            <table width="100%" align="center" border="1" cellpadding="0" cellspacing="2" style="border-style: groove;">
                <tr>
                    <td colspan="2" align="center" height="30">
                        <asp:Label ID="prjs" runat="server" Text=""></asp:Label>
                    </td>
                    <td align="center" valign="middle">
                        <asp:Button ID="btnDelete" runat="server" Text="Delete Registration (by Partner)" Enabled="false" Font-Bold="true" Font-Size="Larger" Width="240px" Height="40px" OnClick="btnDelete_Click" />
                    </td>
                </tr>
                <tr runat="server" id="TRapp">
                    <td align="center" valign="middle" width="150">
                        <asp:Label ID="Lbshowtitle" runat="server" Text="Label"></asp:Label>
                    </td>
                    <td align="left" valign="middle">
                        <asp:CheckBox ID="ISPI" Checked="true" runat="server" Visible="false" />
                        <b>Comment:</b>
                        <ajaxToolkit:TextBoxWatermarkExtender runat="server" ID="TextBoxWatermarkExtender1"
                            TargetControlID="dlRejReason" WatermarkText="Please enter approve/reject reason" WatermarkCssClass="watermarked" />
                        <asp:TextBox ID="dlRejReason" runat="server" Width="350px" />
                    </td>
                    <td align="center" valign="middle">
                        <asp:Button ID="btapp" runat="server" Text="Approve" OnClick="btapp_Click" Font-Bold="true" Font-Size="Larger" Width="120px" Height="40px" />
                        <asp:Button ID="btrej" runat="server" Text="Reject" OnClick="btrej_Click" Font-Bold="true" Font-Size="Larger" Width="120px" Height="40px"
                            OnClientClick="return checkR();" /><br /><asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<script type="text/javascript" language="javascript">
    function checkR() {
        //        var currSelectIndex = document.getElementById("<= dlRejReason.ClientID %>").selectedIndex;
        if ($.trim($("#<%= dlRejReason.ClientID  %>").val()) == "" || $.trim($("#<%= dlRejReason.ClientID  %>").val()) == "Please Enter reason") {
            alert("Please Enter reason for rejection!")
            $("#<%= dlRejReason.ClientID  %>").focus();
            return false;
        }
        //        if (currSelectIndex == 0) {
        //            alert("Please select reason for rejection.");
        //            return false;
        //        }

    }
</script>
