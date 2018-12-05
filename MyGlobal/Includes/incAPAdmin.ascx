<%@ Control Language="VB" ClassName="incAPAdmin" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If MailUtil.IsInRole("MyAdvantech") Then
                Me.trEZCatalogAdmin.Visible = True
            End If
        End If
        If String.Equals(Session("user_id"), "tam.tran@advantech.nl", StringComparison.OrdinalIgnoreCase) _
            OrElse String.Equals(Session("user_id"), "martijn.vosselman@advantech.nl", StringComparison.OrdinalIgnoreCase) _
            OrElse Util.IsAEUIT() Then
            tr1.Visible = True
            Table29.Visible = True
        End If
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
                    <td width="142" background="../images/ebiz.aeu.face/titlefolder_middle.gif" class="text">
                        <div align="center">
                            <font color="000066"><b>eBTOS Administration</b></font>
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
                <!-- New CBOM Editor-->
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
                                                <a href="../WebCBOMEditor/CBOM_Catalog_Input.aspx"><b><font color="000099">Create And
                                                    Maintain CBOM List</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table20">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%" height="22">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../WebCBOMEditor/LoadCBOM_Input.aspx"><b><font color="000099">Create And Edit
                                                    CBOM</font>
                                                    <!--font color="red">(Test)</font-->
                                                </b></a>
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
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table21">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table22">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../WebCBOMEditor/LoadCategory_Input.aspx"><b><font color="000099">Create And
                                                    Edit Category</font>
                                                    <!--font color="red">(Test)</font-->
                                                </b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table24">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%" height="22">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../WebCBOMEditor/PhaseOut_Check.aspx"><b><font color="000099">Check Phase-out
                                                    Items</font></b></a>
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
                                                <a href="../WebCBOMEditor/PTRADE_DEFINITION.aspx"><b><font color="000099">P-trade Item
                                                    List in CBOM</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table27">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%" height="22">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../WebCBOMEditor/eCTOSProductAdmin.aspx"><b><font color="000099">Maintain eCTOS
                                                    Customer-Product Mapping</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr id="tr1" runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table28">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table29" runat="server" visible="false">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../WebCBOMEditor/CtosNoteAdmin.aspx"><b><font color="000099">CTOS Note Admin</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table23">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <%												    												                If Session("user_id") = "tc.chen@advantech.com.tw" Or
                                                                                    Session("user_id").ToString.ToLower = "nada.liu@advantech.com.cn" Or
                                                                                    LCase(Session("user_id")).ToString.StartsWith("tam.tran") Or
                                                                                     LCase(Session("user_id")) = "ming.zhao@advantech.com.cn" Or
                                                                                    LCase(Session("user_id")).ToString.StartsWith("raoul.brouns") Then%>
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6" />
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../WebCBOMEditor/EZConfig_CBOM_Import.aspx"><b><font color="000099">EZ CBOM
                                                    Import</font></b></a>
                                            </td>
                                            <%Else%>
                                            <td width="11%" height="22">&nbsp;
                                            </td>
                                            <td width="89%" align="left">&nbsp;
                                            </td>
                                            <%End If%>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%         If Session("user_id") = "tc.chen@advantech.com.tw" Or
Session("user_id").ToString.ToLower = "nada.liu@advantech.com.cn" Or
LCase(Session("user_id")).ToString.StartsWith("tam.tran") Or
LCase(Session("user_id")) = "ming.zhao@advantech.com.cn" Or
LCase(Session("user_id")) = "tc.chen@advantech.eu" Then%>
                <tr>
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
                                                <a href="./IServicesGroup_admin.aspx "><b><font color="000099">IServices Group Admin</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <%    If Util.IsAEUIT() OrElse HttpContext.Current.User.Identity.Name.Equals("tam.tran@advantech.nl", StringComparison.OrdinalIgnoreCase) Then%>
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table11">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../Admin/MaintainBTOCatalog.aspx"><b><font color="000099">Maintain Catalog Names</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                    <%End If%>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <%End If%>
                <tr id="trEZCatalogAdmin" runat="server" visible="false">
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table5">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table9">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left" id="tdAdminEzCatalog" runat="server">
                                                <a href="../admin/AdminEZCatalog_DetailView.aspx?id=SYS-1U1000-3A01"><b><font color="000099">
                                                    EZ Catalog Admin</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table5">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%">
                                    <%  If Util.IsAEUIT() Or
                LCase(Session("user_id")) = "charles.chi@advantech.com" Or
                LCase(Session("user_id")) = "mary.lin@advantech.com" Or
                LCase(Session("user_id")) = "dale.chiang@advantech.com" Or
                LCase(Session("user_id")) = "brian.tsai@advantech.com.tw" Or
                LCase(Session("user_id")) = "james.yung@advantech.com" Or
                LCase(Session("user_id")) = "junghung.hsu@advantech.com.tw" Or
                LCase(Session("user_id")) = "gene.chiueh@advantech.com.tw" Then%>
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table11">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../admin/ManualSyncFromEurope.aspx"><b><font color="000099">Manual Sync From
                                                    Europe</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                    <%End If%>
                                </td>
                                <td width="50%">
                                    <%If Util.IsAEUIT() Or
                HttpContext.Current.User.Identity.Name.Equals("james.hill@advantech.com", StringComparison.OrdinalIgnoreCase) Then%> <%--Add James Hill to access ReplaceCartBTO_Admin. By ICC--%>
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text"
                                        id="Table11">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../admin/ReplaceCartBTO_Admin.aspx"><b><font color="000099">Maintain Virtual BTO</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                    <%End If%>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table5">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%">
                                    <%  If MailUtil.IsInRole("MyAdvantech") Or
            LCase(Session("user_id")) = "brian.tsai@advantech.com.tw" Or
            LCase(Session("user_id")) = "junghung.hsu@advantech.com.tw" Or
            LCase(Session("user_id")) = "gene.chiueh@advantech.com.tw" Then%>
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6">
                                                </div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../WebCBOMEditor/ReplacePhaseOutItem.aspx"><b><font color="000099">Replace phase out parts for TW.</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                    <%End If%>
                                </td>
                                <td width="50%"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
