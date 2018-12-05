<%@ Control Language="VB" ClassName="OrderingBlock" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If CType(dbUtil.dbExecuteScalar("My", "select IsAccountOwner from contact where userid='" + Session("user_id") + "'"), Boolean) = True Then
            trAccountManagement.Visible = True
        Else
            trAccountManagement.Visible = False
        End If
        tr7.Visible = True
        If CType(dbUtil.dbExecuteScalar("My", "select Can_Place_Order from contact where userid='" + Session("user_id") + "'"), Boolean) = False then ' Or Session("user_role") = "Guest" Then
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

<ajaxToolkit:CollapsiblePanelExtender ID="cpe" runat="Server"
    TargetControlID="PanelContent" ExpandControlID="PanelHeader" CollapseControlID="PanelHeader"
    CollapsedSize="0" Collapsed="false" ScrollContents="false" SuppressPostBack="true" ExpandDirection="Vertical" /> 
<asp:Panel runat="server" ID="PanelHeader">
    <table border="0" width="100%" cellspacing="0" cellpadding="0" onmouseover="this.style.cursor='hand'">
      <tr>
        <td width="2%" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></td>
        <td width="96%" height="20" background="/images/table_fold_top.gif" >
            <table width="100%"  border="0" cellpadding="0" cellspacing="0"class="text">
                <tr>
                  <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                  <td width="94%"><b>On-line Ordering </b></td>
                </tr>
            </table>
        </td>
        <td width="2%" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"/></td>
      </tr>
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelContent">
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
        <tr>
            <td width="2%" background="/images/table_line_left.gif"></td>
            <td width="96%">
                <table border="0" width="89%" cellspacing="0" cellpadding="0" class="text">
                   <%  If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session IsNot Nothing AndAlso _
                   HttpContext.Current.Session("USER_ID") IsNot Nothing AndAlso HttpContext.Current.User IsNot Nothing AndAlso _
                   HttpContext.Current.User.Identity IsNot Nothing AndAlso HttpContext.Current.User.Identity.Name IsNot Nothing AndAlso _
                    (Roles.IsUserInRole(HttpContext.Current.Session("USER_ID"), "Administrator") = True Or _
                    Roles.IsUserInRole(HttpContext.Current.Session("USER_ID"), "Logistics") = True) Then%>
                    <tr runat="server" id="tr1">
                      <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
                      <td width="141"><b><a href="/eQuotation/quotation_historyCustomer.aspx"><font color="#4D6D94">Quote History</font></a></b></td>
                    </tr>
                    <%End If%>
                    <tr runat="server" id="tr2">
                      <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
                      <td> <b><a href="../Order/Cart_List.aspx"><font color="#4D6D94">Place Order</font></a></b></td>
                    </tr>
                    <tr runat="server" id="tr3">
                      <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
                      <td> <a href="../Order/UploadOrder2Cart.aspx"><font color="#4D6D94"><b><font color="#4D6D94">Upload Order</b></font></a></td>
                    </tr>
                    <tr runat="server" id="tr4">
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
                      <td><b><a href="../Order/CartHistory_List.aspx"><font color="#4D6D94">Cart History</font></a></b></td>
                    </tr>
                    <tr runat="server" id="tr5">
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td>
                      <td><asp:HyperLink runat="server" ID="hlMyBlanketOrder" Text="My Blanket Order" NavigateUrl="/BO/MyBlanketOrder.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                    <tr runat="server" id="trQueryPrice">
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="hlQueryPrice" Text="Inquire Price" NavigateUrl="/Order/QueryPrice.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                    <tr>
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="hlQueryATP" Text="Check Availability" NavigateUrl="/Order/QueryATP.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                    <tr>
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="hlQueryACLATP" Text="Check ACL Availability" NavigateUrl="/Order/QueryACLATP.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                    <tr runat="server" id="tr6">
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="hlPriceList" Text="Download Price List" NavigateUrl="/Order/Price_List.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                    <tr runat="server" id="tr7">
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="btosOrder" Text="Place BTOS/CTOS Orders" NavigateUrl="/order/btos_portal.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>
                    <tr runat="server" id="tr8">
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="btosHistLink" Text="Configuration History" NavigateUrl="/order/BtosHistory_List.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>  
                    <tr>
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="Promotionlist" Text="Promotion List" NavigateUrl="/lab/Promotion_list.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr>          
                    <tr runat="server" id="trAccountManagement">
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:HyperLink runat="server" ID="hlAccountManagement" Text="Account Management" NavigateUrl="/Admin/Profile_admin.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td>
                    </tr> 
                    <tr>
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:LinkButton runat="server" ID="btnWiki" Text="Advantech Wiki" ForeColor="#4D6D94" Font-Bold="true" OnClick="btnWiki_Click" /></td>
                    </tr>
                    <tr>
                      <td align="center"><img border="0" src="/images/icon_add.gif" width="12" height="12" alt=""/></td>
                      <td><asp:LinkButton runat="server" ID="btnGiftShop" Text="Gift Shop" ForeColor="#4D6D94" Font-Bold="true" OnClick="btnGiftShop_Click" /></td>
                    </tr>
                </table>
            </td>
            <td width="2%" background="/images/table_line_right.gif"></td>
        </tr>
        <tr>
            <td colspan="3"><img src="/images/folder_down.gif" width="100%" height="5"></td>
        </tr>
    </table> 
</asp:Panel>
  