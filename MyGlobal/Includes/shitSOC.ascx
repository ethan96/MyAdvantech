<%@ Control Language="VB" ClassName="incESalesAdminSch" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.hyHQSOC.NavigateUrl = String.Format("http://employeezone.advantech.com.tw/soc/check_login.aspx?user_id={0}&request_category=SOC_WEB", Session("user_id"))
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
                    <td width="260" background="../images/ebiz.aeu.face/titlefolder_middle.gif" class="text">
                        <div align="center">
                            <font color="000066"><b>Global SOC (IT Owner <a href="mailto:jacky.wu@advantech.com.tw">
                                Jacky.Wu</a>)</b></font></div>
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
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <a href="http://employeezone.advantech.com.tw/SOC/SOC_Change.aspx"><b><font color="000099">
                                                    New Order Change Request</font></b></a>
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
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="hyHQSOC" Text="SOC Status" ForeColor="#000099"
                                                    Font-Bold="true" NavigateUrl="http://employeezone.advantech.com.tw/soc/check_login.aspx?user_id=&request_category=SOC_WEB" />
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
