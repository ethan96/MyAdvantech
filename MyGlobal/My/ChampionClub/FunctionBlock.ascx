<%@ Control Language="VB" ClassName="FunctionBlock" %>
<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            If Session("org_id").ToString.StartsWith("US") Then
            End If
            If Session("org_id").ToString.StartsWith("CN") Then
                LitPI.Text = "活动介绍"
                LitRPR.Text = "区域积分标准"
                LitPIUSER.Text = "报名"
                LitRU.Text = "提交积分申请"
                LitPM.Text = "积分记录"
                LitRN.Text = "心动大奖"
                LitRL.Text = "排行榜"
                LitQA.Text = "Q&amp;A"
            End If
            
            'JJ 2014/4/16 Liliana/Adam那邊要求隱藏北美的Points Request
            Dim org As String = Session("org_id").ToString.Substring(0, 2)
            If AuthUtil.IsInterConUserV2() Then
                org = "InterCon"
            End If
        
            If org = "US" Then
                Me.tr_point.Visible = False
            End If
        End If
    End Sub
</script>
<div class="cpclub-content-sidebar">
    <div class="menu-heading">
        Advantech Champion Club</div>
    <table width="200">
        <tr>
            <td>
                <table  border="0" cellspacing="0" cellpadding="0" class="login"  >
                    <tr>
                        <td width="5%" height="10">
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0" >
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="ChampionClub.aspx"><asp:Literal ID="LitPI" runat="server">Program Introduction</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="ProgramCriteria.aspx"><asp:Literal ID="LitRPR"
                                            runat="server">Regional Program &amp; Registration</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="PersonalInfo.aspx"><asp:Literal ID="LitPIUSER" runat="server">Personal Info</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                     <tr ID="tr_point" runat="server">
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="ReportsUpload.aspx"><asp:Literal ID="LitRU" runat="server">Points Request</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="PointManagement.aspx"><asp:Literal ID="LitPM" runat="server">Point Management</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="Redemption.aspx"><asp:Literal ID="LitRN" runat="server">Redemption</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <%-- <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="RedeemRecord.aspx">Redemption Record</a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>--%>
                    <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="RankingList.aspx"><asp:Literal ID="LitRL" runat="server">Ranking List</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25">
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="img/point_02.gif" alt="" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="ChampionClub_QA.aspx"><asp:Literal ID="LitQA" runat="server">FAQ</asp:Literal></a>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="10">
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>
