<%@ Control Language="VB" ClassName="OrderingBlock_new" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If CType(dbUtil.dbExecuteScalar("My", "select IsAccountOwner from contact where userid='" + Session("user_id") + "'"), Boolean) = True Then
            trAccountManagement.Visible = True
        Else
            trAccountManagement.Visible = False
        End If
        tr7.Visible = True
        If CType(dbUtil.dbExecuteScalar("My", "select Can_Place_Order from contact where userid='" + Session("user_id") + "'"), Boolean) = False then'Or Session("user_role") = "Guest" Then
            tr1.Visible = False : tr2.Visible = False : tr3.Visible = False : tr4.Visible = False : tr5.Visible = False : tr6.Visible = False
            'tr7.Visible = False
            tr8.Visible = False
        Else
            tr1.Visible = True : tr2.Visible = True : tr3.Visible = True : tr4.Visible = True : tr5.Visible = True : tr6.Visible = True
            'tr7.Visible = True : 
            tr8.Visible = True
        End If
        If LCase(Session("user_id")) = "r.deraad@go4mobility.nl" Or LCase(Session("user_id")) = "j.sep@go4mobility.nl" Then
            trQueryPrice.Visible = False
        End If
    End Sub

    Protected Sub btnGiftShop_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Try
            Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "PZ")
            If p IsNot Nothing Then
                Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}&redirectpage={2}", p.email_addr, p.login_password, "%E2%80%A7Gift_Shop"))
            Else
                Response.Redirect(String.Format("http://wiki.advantech.com"))
            End If
        Catch ex As System.Net.WebException
            Response.Redirect(String.Format("http://wiki.advantech.com"))
        End Try
    End Sub

    Protected Sub btnWiki_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        ws.Timeout = 500 * 1000
        Try
            Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "PZ")
            If Not IsDBNull(p) And Not IsNothing(p) Then
                Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}&redirectpage={2}", p.email_addr, p.login_password, "Main_Page"))
            Else
                'Response.Redirect(String.Format("http://wiki.advantech.com"))
                Dim newP As New SSO.SSOUSER
                With newP
                    .company_id = Session("company_id") : .erpid = Session("company_id")
                    .email_addr = Session("user_id")
                    .login_password = "1234"
                End With
                ws.register("PZ", newP)
                Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}&redirectpage={2}", newP.email_addr, newP.login_password, "Main_Page"))
            End If
        Catch ex As System.Net.WebException
            Response.Redirect(String.Format("http://wiki.advantech.com"))
        End Try
    End Sub
</script>


    <table border="0" width="100%" cellspacing="0" cellpadding="0" onmouseover="this.style.cursor='hand'">
      <tr>
        <td width="2%" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></td>
        <td width="96%" height="20" background="/images/table_fold_top.gif" >
            <table width="100%"  border="0" cellpadding="0" cellspacing="0"class="text">
                <tr>
                  <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                  <td width="94%"><b>On-line Ordering_new </b></td>
                </tr>
            </table>
        </td>
        <td width="2%" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"/></td>
      </tr>
    </table>



    <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="2%" background="/images/table_line_left.gif"></td>
            <td width="96%">
            
           <%-- start--%>
            <div class="suckerdiv">
<ul id="suckertree5">
 <%  If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session IsNot Nothing AndAlso _
                   HttpContext.Current.Session("USER_ID") IsNot Nothing AndAlso HttpContext.Current.User IsNot Nothing AndAlso _
                   HttpContext.Current.User.Identity IsNot Nothing AndAlso HttpContext.Current.User.Identity.Name IsNot Nothing AndAlso _
                    (Roles.IsUserInRole(HttpContext.Current.Session("USER_ID"), "Administrator") = True Or _
                    Roles.IsUserInRole(HttpContext.Current.Session("USER_ID"), "Logistics") = True) Then%>
<li runat="server" id="tr1"><b><a href="/eQuotation/quotation_historyCustomer.aspx"><font color="#4D6D94">Quote History</font></a></b></li>

<%End If%>
<li runat="server" id="tr2"><b><a href="../Order/Cart_List.aspx"><font color="#4D6D94">Place Order</font></a></b></li>

<li runat="server" id="tr3" ><a href="../Order/UploadOrder2Cart.aspx"><font color="#4D6D94"><b><font color="#4D6D94">Upload Order</b></font></a></li>
<li runat="server" id="tr4"><b><a href="../Order/CartHistory_List.aspx"><font color="#4D6D94">Cart History</font></a></b></li>
<li runat="server" id="tr5"><asp:HyperLink runat="server" ID="hlMyBlanketOrder" Text="My Blanket Order" NavigateUrl="/BO/MyBlanketOrder.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li runat="server" id="trQueryPrice"><asp:HyperLink runat="server" ID="hlQueryPrice" Text="Inquire Price" NavigateUrl="/Order/QueryPrice.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li><asp:HyperLink runat="server" ID="hlQueryATP" Text="Check Availability" NavigateUrl="/Order/QueryATP.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li><asp:HyperLink runat="server" ID="hlQueryACLATP" Text="Check ACL Availability" NavigateUrl="/Order/QueryACLATP.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li  runat="server" id="tr6"><asp:HyperLink runat="server" ID="hlPriceList" Text="Download Price List" NavigateUrl="/Order/Price_List.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li runat="server" id="tr7"><asp:HyperLink runat="server" ID="btosOrder" Text="Place BTOS/CTOS Orders" NavigateUrl="/order/btos_portal.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li runat="server" id="tr8"><asp:HyperLink runat="server" ID="btosHistLink" Text="Configuration History" NavigateUrl="/order/BtosHistory_List.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li><asp:HyperLink runat="server" ID="Promotionlist" Text="Promotion List" NavigateUrl="/lab/Promotion_list.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li  runat="server" id="trAccountManagement"><asp:HyperLink runat="server" ID="hlAccountManagement" Text="Account Management" NavigateUrl="/Admin/Profile_admin.aspx" ForeColor="#4D6D94" Font-Bold="true" /></li>
<li><asp:LinkButton runat="server" ID="btnWiki" Text="Advantech Wiki" ForeColor="#4D6D94" Font-Bold="true" OnClick="btnWiki_Click" /></li>
<li><asp:LinkButton runat="server" ID="btnGiftShop" Text="Gift Shop" ForeColor="#4D6D94" Font-Bold="true" OnClick="btnGiftShop_Click" /></li>
</ul>
</div>
          <%-- end--%>

            </td>
            <td width="2%" background="/images/table_line_right.gif"></td>
        </tr>
      <%--  <tr>
            <td colspan="3"><img src="/images/folder_down.gif" width="100%" height="5"></td>
        </tr>--%>
    </table> 
