<%@ Control Language="VB" ClassName="PartnerTrainingBlock_new" %>

<script runat="server">

    Protected Sub btnELearning_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        ws.Timeout = 500 * 1000
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "PZ")
        If Not IsDBNull(p) And Not IsNothing(p) Then
            Response.Redirect("http://elearning.advantech.com.tw/Login_check.aspx?EMAIL_ADDR=" + Session("user_id") + "&Password=" + p.login_password)
        Else
            'Util.JSAlert(Me.Page, "You don't have account to access eLearning!!")
            Dim newP As New SSO.SSOUSER
            With newP
                .company_id = Session("company_id") : .erpid = Session("company_id")
                .email_addr = Session("user_id")
                .login_password = "1234"
            End With
            ws.register("PZ", newP)
            Response.Redirect("http://elearning.advantech.com.tw/Login_check.aspx?EMAIL_ADDR=" + Session("user_id") + "&Password=" + newP.login_password)
        End If
    End Sub
</script>


    <table border="0" width="100%" cellspacing="0" cellpadding="0" onmouseover="this.style.cursor='hand'">
      <tr>
        <td width="2%" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></td>
        <td width="96%" height="20" background="/images/table_fold_top.gif" >
            <table width="100%"  border="0" cellpadding="0" cellspacing="0" class="text">
                <tr>
                  <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                  <td width="94%"><b>Training_new </b></td>
                </tr>
            </table>
        </td>
        <td width="2%" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"/></td>
      </tr>
    </table>
<%--next--%>

    <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="2%" background="/images/table_line_left.gif"></td>
            <td width="96%">
          <%--  start--%>
          <div class="suckerdiv">
<ul id="suckertree4">
<li>
<asp:LinkButton style="background-image: url(../Images/Icon_new.gif);background-repeat: no-repeat;background-position: 71px center;" runat="server" ID="LinkButton1" Text="eLearning" Font-Bold="true" ForeColor="#4D6D94" OnClick="btnELearning_Click" />
</li>
<li><asp:HyperLink runat="server" ID="HyperLink1" Text="2009Q1 Sales Kits & Roadmap" NavigateUrl="/eP_PartnerTraining.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li >
<asp:HyperLink runat="server" ID="HyperLink2" Text="eA Training Material" NavigateUrl="/eA_PartnerTraining.aspx" ForeColor="#4D6D94" Font-Bold="true" />
</li>

</ul>
</div>
          <%--  end--%>
               <%-- <table border="0" width="89%" cellspacing="0" cellpadding="0" class="text">
                    <tr>
                      <td align="center" valign="middle" valign="top" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td width="141">
                        <table cellpadding="0" cellspacing="0">
                            <tr>
                                <td><asp:LinkButton runat="server" ID="btnELearning" Text="eLearning" Font-Bold="true" ForeColor="#4D6D94" OnClick="btnELearning_Click" /></td>
                                <td><img src="../Images/Icon_new.gif" /></td>
                            </tr>
                        </table>
                      </td>
                    </tr>
                    <tr>
                      <td align="center" valign="top" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td width="141"><asp:HyperLink runat="server" ID="hlTraining_eP" Text="2009Q1 Sales Kits & Roadmap" NavigateUrl="/eP_PartnerTraining.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                    <tr>
                      <td align="center" valign="top" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td width="141"><asp:HyperLink runat="server" ID="hlTraining_eA" Text="eA Training Material" NavigateUrl="/eA_PartnerTraining.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                </table>--%>
            </td>
            <td width="2%" background="/images/table_line_right.gif"></td>
        </tr>
     <%--   <tr>
            <td colspan="3"><img src="/images/folder_down.gif" width="100%" height="5"></td>
        </tr>--%>
    </table> 
