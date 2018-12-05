<%@ Control Language="VB" ClassName="incAPAdminB2B_New" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        If IsB2BSA(Session("user_id")) Then
            Me.lbtnEXrate.Visible = True : Me.GP_Block_Admin.Visible = True : Me.ProductSplit.Visible = True : Me.lbAgent.Visible = True
        Else
            Me.lbtnEXrate.Visible = False : Me.GP_Block_Admin.Visible = False : Me.ProductSplit.Visible = False : Me.lbAgent.Visible = False
        End If
        Invoice.Visible = False
        'Ryan 20160401 Add rudd in can see list
        If Util.IsAEUIT() OrElse Session("user_id").ToString.Trim.ToLower = "michael.vanderveeken@advantech.nl" _
            OrElse String.Equals(Session("user_id"), "Peter.Thijssens@advantech.nl", StringComparison.OrdinalIgnoreCase) _
            OrElse String.Equals(Session("user_id"), "antonio.rigazio@advantech.nl", StringComparison.OrdinalIgnoreCase) _
            OrElse String.Equals(Session("user_id"), "ruud.proost@advantech.nl", StringComparison.OrdinalIgnoreCase) Then
            Billboardadmin.Visible = True
        End If

        'Frank 2012/11/2:Access control for Uploading Product Family function
        If Util.IsAEUIT() OrElse MailUtil.IsInRole("SCM.AASECO") OrElse MailUtil.IsInRole("SCM.embedded") Then
            ProductFamilyadmin.Visible = True
        End If

        If Session("org_id").ToString.Trim.Equals("EU10") Then
            Me.Table_AEUBacklogReport.Visible = True
        End If
        
    End Sub

    Function IsB2BSA(ByVal user_id As String) As Boolean

        user_id = LCase(Trim(user_id))
        If Not Util.IsAdmin() Then
            IsB2BSA = False
        Else
            IsB2BSA = True
        End If

    End Function

    Function IsB2BAccountSA(ByVal user_id As String) As Boolean

        If MYSIEBELDAL.IsAccountOwner(user_id) Or Util.IsAdmin() Then
            IsB2BAccountSA = True
        Else
            IsB2BAccountSA = False
        End If
        'user_id = LCase(Trim(user_id))
        'If user_id.ToString.IndexOf("ozdal.turp") <> 0 And _
        '    user_id.ToString.IndexOf("stephanie.auchabie") <> 0 And _
        '    user_id.ToString.IndexOf("maria.unger") <> 0 And _
        '    user_id.ToString.IndexOf("andrea.wynne-jones") <> 0 And _
        '    user_id.ToString.IndexOf("marco.pavesi") <> 0 And _
        '    user_id.ToString.IndexOf("leroy.boeren") <> 0 And _
        '    user_id.ToString.IndexOf("paul.jaspers") <> 0 And _
        '    user_id.ToString.IndexOf("leeann.fletcher") <> 0 And _
        '    user_id.ToString.IndexOf("pauline.dujardin") <> 0 And _
        '     user_id <> "sabine.lin@advantech.fr" And _
        '     user_id <> "nico.koegl@advantech.eu" And _
        '    user_id.ToString.IndexOf("sara.kailla") <> 0 _
        'Then
        '    If Util.IsAdmin() Then
        '        IsB2BAccountSA = True
        '    Else
        '        IsB2BAccountSA = False
        '    End If

        'Else
        '    IsB2BAccountSA = True
        'End If

    End Function

    Function IsAccountAdmin() As Boolean
        If Not Util.IsAdmin() Then
            IsAccountAdmin = False
        Else
            IsAccountAdmin = True
        End If
    End Function
    Protected Sub lnkePricer_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "PZ")
        If Not IsNothing(p) Then
            Response.Redirect(String.Format("http://aclepartner.advantech.com.tw/Login1.asp?SWEusername={0}&SWEpassword={1}&SrcString=/pricing/epricer_entry.asp", Session("user_id"), p.login_password))
        End If

    End Sub

    Protected Sub lnkWiki_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "PZ")
        If Not IsNothing(p) Then
            Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}&redirectpage", p.email_addr, p.login_password, ""))
        End If
    End Sub

    Protected Sub GP_Block_Admin_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("../esales/quote/GPBlockManagement.aspx")
    End Sub

    Protected Sub ProductSplit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("../esales/quote/ProductSplit.aspx")
    End Sub

    Protected Sub lbtnEXrate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("../esales/quote/exchangerate.aspx")
    End Sub

    Protected Sub lbAgent_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("../admin/agent.aspx")
    End Sub

    Protected Sub Cust_Calendar_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("../admin/Customer_Calendar.aspx")
    End Sub
</script>

<table cellpadding="0" cellspacing="0" width="98%">
    <tr>
        <!-- title folder -->
        <td>
            <table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table1">
                <tr>
                    <td width="28">
                        <img src="../images/ebiz.aeu.face/titlefolder_left.gif" width="28" height="26">
                    </td>
                    <td width="172" background="../images/ebiz.aeu.face/titlefolder_middle.gif" class="text">
                        <div align="center">
                            <font color="000066"><b>MyAdvantech Administration</b></font>
                        </div>
                    </td>
                    <td width="21">
                        <img src="../images/ebiz.aeu.face/titlefolder_right.gif" width="21" height="26">
                    </td>
                    <td background="../images/ebiz.aeu.face/folder_line.gif">&nbsp;
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td height="8px"></td>
    </tr>
    <tr>
        <!-- main table -->
        <td>
            <table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table2">
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table18">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table19">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <%If Util.IsAEUUser() Or IsB2BAccountSA(Session("user_id")) Or MYSIEBELDAL.IsAccountOwner(Session("user_id")) Or Util.IsAdmin() Or (Util.IsAccountAdmin = True AndAlso Util.IsInternalUser(Session("user_id"))) Then%>
                                                <a href="../Admin/profile_admin.aspx"><b><font color="000099">Account Administration</font></b></a>
                                                <%Else%>
                                                <font color="gray"><b>Account Administration</b></font>
                                                <%End If%>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <%-- <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table20">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%" height="22">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <%If IsB2BAccountSA(Session("user_id")) Or Account.IsCompanyIDMatchRBU(Session("user_id")) Then%>
                                                <a href="../Admin/account_contact.aspx"><b><font color="000099">Contact Administration</font></b></a>
                                                <%Else%>
                                                <font color="gray"><b>Contact Administration</b></font>
                                                <%End If%>
                                            </td>
                                        </tr>
                                    </table>--%>
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table7">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../order/Order_Recovery.aspx"><b><font color="000099">B2B Order Recovery</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table4">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table5">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <%If IsB2BSA(Session("user_id")) Then%>
                                                <a href="../ddCalculator/ShipCalendarSetup.asp"><b><font color="000099">Supplier Shipping
                                                    Calendar</font></b></a>
                                            </td>
                                            <%Else%>
                                            <font color="gray"><b>Supplier Shipping Calendar</b></font>
                                            <%End If%>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table6">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%" height="22">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../ddCalculator/CustShipCalendarSetup.asp"><b><font color="000099">Customer
                                                    Weekly Shipping</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table3">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table8">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%" height="22">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../Admin/SyncSingleProduct.aspx"><b><font color="000099">Sync Product Status</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table13">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="/Admin/SyncCustomer.aspx"><b><font color="000099">Sync Customer and Ship-to</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table9">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table10">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <%If IsB2BSA(Session("user_id")) Then%>
                                                <a href="../lab/Promotion_Register.aspx"><b><font color="000099">ePromotion Administration</font></b></a>
                                                <%Else%>
                                                <font color="gray"><b>ePromotion Administration</b></font>
                                                <%End If%>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table11">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%" height="22">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <%If IsB2BSA(Session("user_id")) Then%>
                                                <a href="B2B-KPI.aspx"><b><font color="000099">B2B-AEU Site Analysis</font></b></a>
                                                <%Else%>
                                                <font color="gray"><b>B2B-AEU Site Analysis</b></font>
                                                <%End If%>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table12">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25"></td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table13">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="/BO/registration.aspx"><b><font color="000099">New Blanket Order</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table12">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table13">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <%If IsB2BSA(Session("user_id")) Then%>
                                                <a href="/BO/bo_admin.aspx"><b><font color="000099">Blanket Order Admin</font></b></a>
                                            </td>
                                            <%Else%>
                                            <font color="gray"><b>Blanket Order Admin</b></font>
                                            <%End If%>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table15">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <%If IsB2BSA(Session("user_id")) Then%>
                                                <a href="/BO/bo_report.aspx"><b><font color="000099">Blanket Order Report</font></b></a>
                                            </td>
                                            <%Else%>
                                            <font color="gray"><b>Blanket Order Admin</b></font>
                                            <%End If%>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table22">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table23">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="lnkWiki" Text="AdvantechWiki" OnClick="lnkWiki_Click"
                                                    ForeColor="#000099" Font-Bold="true" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table24">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="hlMyKPI" Text="MyAdvantech KPI" NavigateUrl="~/Admin/B2B-KPI.aspx"
                                                    ForeColor="#000099" Font-Bold="true" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table25">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table26">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="GP_Block_Admin" Text="Approval Flow Definition"
                                                    ForeColor="#000099" Font-Bold="true" OnClick="GP_Block_Admin_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table27">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="ProductSplit" Text="Product Split Customer Admin"
                                                    ForeColor="#000099" Font-Bold="true" OnClick="ProductSplit_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table28">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table29">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="lbtnEXrate" Text="Exchange Rate Maintain" ForeColor="#000099"
                                                    Font-Bold="true" OnClick="lbtnEXrate_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table30">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="Invoice" Text="Invoice Data for Sales Performance"
                                                    NavigateUrl="http://my.advantech.eu/esales/eTCR/invoice.aspx" ForeColor="#000099"
                                                    Font-Bold="true" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table31">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table32">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="LinkButton1" Text="eQuotation & SOC monthly report"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="http://my.advantech.eu/eSales/Quote/eQuotation_report.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table33">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="lbAgent" Text="Agent Setting" ForeColor="#000099"
                                                    Font-Bold="true" OnClick="lbAgent_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE" align="left">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table34" align="left">
                            <tr bgcolor="#FFFFFF" align="left">
                                <%If Util.IsAEUIT() Or Session("user_id") = "mory.lin@advantech.com.tw" Or Session("user_id") = "ming.zhao@advantech.com.cn" Then%>
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table35">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HyperLink1" Text="IPC promotion order inquiry"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="http://my.advantech.eu/Admin/getPcOrder.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <%End If%>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table36" align="left">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="Cust_Calendar" Text="Customer Calendar" ForeColor="#000099"
                                                    Font-Bold="true" OnClick="Cust_Calendar_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%-- ''''''''''''''''''--%>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table34">
                            <tr bgcolor="#FFFFFF">

                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table35">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="LR1" Text="Literature Request Online Report"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="http://my.advantech.com/admin/LitReqLargeReport.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>

                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table36">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="ll1" Text="Literature listing"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="http://my.advantech.com/product/LitCatalogListing.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table35">
                            <tr bgcolor="#FFFFFF">

                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table35">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="ML" Text="Multi-Language Admin"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/MultiLangAdmin.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>

                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table14">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="LinkButton2" Text="ePricer" OnClick="lnkePricer_Click"
                                                    ForeColor="#000099" Font-Bold="true" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table16">
                            <tr bgcolor="#FFFFFF">

                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table17">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="hlSyncAccCon" Text="Sync Account or Contact from Siebel"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/SyncSiebelAccountContact.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>

                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" runat="server" visible="false" cellspacing="0" class="text" id="Billboardadmin">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6" alt="">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HyperLink2" Text="Update Billboard for AEU"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/Billboardadmin.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table20">
                            <tr bgcolor="#FFFFFF">

                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table21">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HyperLink3" Text="MyAdvantech Usage Report"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/Usage_Report.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>

                                <td width="50%">
                                    <%--ICC 2015/8/14 This function is no longer valid. For adding TW01 PI mail list, please use PI Mail Contact Admin(TW01) link.--%>
                                    <%--<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table37">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HyperLink4" Text="B2B Contact Administration"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/B2BACL/b2b_account_contact.aspx" />
                                            </td>
                                        </tr>
                                    </table>--%>
                                        <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table_AEUBacklogReport" runat="server" visible="false">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HL_AEUBacklogReport" Text="Maintain Backlog Report Recipients"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/MaintainRecipients.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table20">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" visible="false" cellspacing="0" class="text" runat="server" id="ProductFamilyadmin">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HyperLink5" Text="Upload Product Family to PIS"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/PIS/ProductFamily.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" visible="false" cellspacing="0" class="text" runat="server" id="tbb2bca">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HLb2bca" Text="PI Mail Contact Admin(TW01)"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/b2bacl/b2b_company_contact.aspx" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table20">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <%If MailUtil.IsInMailGroup("ajp_op", Session("user_id").ToString) OrElse MailUtil.IsInMailGroup("ajsc.ctos", Session("user_id").ToString) OrElse Util.IsMyAdvantechIT() Then%>
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" runat="server" id="TableAJPCTOSShipmentReport">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">                                                
                                                <asp:HyperLink runat="server" ID="hlAJPCTOSShipmentReport" Text="AJP CTOS Shipment Report"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/AJPCTOSShipmentReport.aspx" />                                                
                                            </td>
                                        </tr>
                                    </table>
                                    <%End If %>
                                </td>
                                <td width="50%">
                                    <%If MailUtil.IsInMailGroup("OP.AESC", Session("user_id").ToString) OrElse Util.IsMyAdvantechIT() OrElse Session("user_id").ToString.Equals("louis.lin@advantech.nl", StringComparison.OrdinalIgnoreCase) Then%>
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" runat="server" id="Table37">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">                                                
                                                <asp:HyperLink runat="server" ID="hlAEUOPMaintenance" Text="AEU OP Maintenance"
                                                    ForeColor="#000099" Font-Bold="true" NavigateUrl="~/Admin/AEUOPMapping.aspx" />                                                
                                            </td>
                                        </tr>
                                    </table>
                                    <%End If %>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%-- ''''''''''''''''''''--%>
            </table>
        </td>
    </tr>
</table>
