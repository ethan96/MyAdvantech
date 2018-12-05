<%@ Control Language="VB" ClassName="incCBOMV2Admin" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        If Util.IsMyAdvantechIT OrElse AuthUtil.IsADloG Then
            tCBOMReport.Visible = True
        End If

    End Sub


    Protected Sub lbtn_CBOMV2Report_Click(sender As Object, e As EventArgs)
        Dim ORGID As String = Session("org_id").ToString().ToUpper().Substring(0, 2)
        If Session("org_id_cbom") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Session("org_id_cbom").ToString()) Then
            ORGID = Session("org_id_cbom").ToString().ToUpper().Substring(0, 2)
        End If

        Dim dtCBOMReport As DataTable = Advantech.Myadvantech.DataAccess.CBOMV2_EditorDAL.GetCBOMV2ExcelData(ORGID)

        Util.DataTable2ExcelDownload(dtCBOMReport, "CBOMReport_" + DateTime.Now.ToString("yyyyMMdd") + ".xls")
    End Sub

</script>
<table cellpadding="0" cellspacing="0" width="98%">
    <tr>
        <td>
            <table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table1">
                <tr>
                    <td width="28">
                        <img src="../images/ebiz.aeu.face/titlefolder_left.gif" width="28" height="26">
                    </td>
                    <td width="172" background="../images/ebiz.aeu.face/titlefolder_middle.gif" class="text">
                        <div align="center">
                            <font color="000066"><b>CBOM Administration</b></font></div>
                    </td>
                    <td width="21">
                        <img src="../images/ebiz.aeu.face/titlefolder_right.gif" width="21" height="26">
                    </td>
                    <td background="../images/ebiz.aeu.face/folder_line.gif">
                        &nbsp;
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td height="8px">
        </td>
    </tr>
    <tr>
        <td>
            <table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table2">
                <tr>
                    <td valign="top" bgcolor="EEEEEE">
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table18">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../Lab/CBOMV2/CBOM_CATALOGV2.aspx"><b><font color="000099">Catalog Editor</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text">
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../Lab/CBOMV2/CBOM_CATALOG_CREATE.aspx"><b><font color="000099">Category Editor</font></b></a>
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
                        <table width="100%" border="0" cellpadding="0" cellspacing="1" id="Table18">
                            <tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text">                                        
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="../Lab/CBOMV2/Product_Compatibility.aspx"><b><font color="000099">Compatibility Editor</font></b></a>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td width="50%" height="25">    
                                    <table id="tCBOMReport" runat="server" visible="false" width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text">                                        
                                        <tr onmouseover="this.style.backgroundColor='#FFFBC0';" onmouseout="this.style.backgroundColor='#FFFFFF'">
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:LinkButton runat="server" ID="lbtn_CBOMV2Report" Text="Download CBOM Report" ForeColor="#000099" Font-Bold="true" OnClick="lbtn_CBOMV2Report_Click"/>
                                            </td>
                                        </tr>
                                    </table>                               
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>