<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write("oid:" + Session("OptyId"))
    End Sub

    Protected Sub lbUid_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If HttpContext.Current.User.Identity.IsAuthenticated Then
            CType(sender, Label).Text = Session("cart_id") + " | " + Now.ToString("yyyy/MM/dd") + " | " + Session("company_id") + " | "' + Session("user_role")
        End If
    End Sub

    Protected Sub lbOptyId_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs)
        'Session.Abandon()
    End Sub
</script>

<table style="text-align:center" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td width="10" rowspan="9" align="left"><img src="/images/clear.gif" width="10" height="10"></td>
        <td width="100%" align="left"><img src="/images/advantech_logo.jpg" width="387" height="37"></td>
    </tr>
    <tr>
        <td colspan="2"><img src="/images/clear.gif" width="10" height="10"></td>
    </tr>
    <tr>
        <td align="left" colspan="2">
            <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="11"><img src="/images/folder_left.jpg" width="11" height="30"></td>
                    <td width="100%" bgcolor="E5E5E5" align="left">
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0" class="text">
                            <tr>
                                <td width="118"><b><a href="#"><font color="767373">Corporate Home </font></a></b></td>
                                <td width="10">&nbsp;</td>
                                <td width="138"><b><a href="#"><font color="767373">Partner Zone Home </font></a></b></td>
                                <td width="12">&nbsp;</td>
                                <td width="150"><b><a href="#"><font color="767373">Employee Zone Home </font></a></b></td>
                                <td align="right"><asp:Label runat="server" ID="Label1" OnLoad="lbUid_Load" />|<asp:LoginStatus runat="server" ID="LoginStatus1" /></td>
                            </tr>
                        </table>
                    </td>
                    <td width="12" align="left"><img src="/images/folder_right.jpg" width="12" height="30"></td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td height=15 colspan="2">            
            <asp:Label runat="server" ID="lbOptyId" OnLoad="lbOptyId_Load" />
        </td>
    </tr>
</table>