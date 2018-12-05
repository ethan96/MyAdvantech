<%@ Control Language="VB" ClassName="BillboardBlock" %>

<script runat="server">

    Private ChannelInsightURL As String = "http://www.advantech.eu/it/edm/ChannelInsight_0612/"

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.ToUpper = "EU" Then
        If Session("ORG_ID") IsNot Nothing AndAlso Left(Session("ORG_ID").ToString.ToUpper, 2) = "EU" Then
            'If Util.IsAEUIT() Then
            MB1.Visible = True : MB2.Visible = True
            Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "select isnull(YQ,'') as YQ,  isnull(MD,'') as MD,isnull(THORST,'') as THORST,isnull(YR,'') as YR from BillBoard")
            If dt.Rows.Count > 0 Then
                With dt.Rows(0)
                    MBLit1.Text = .Item("YQ") : MBLit2.Text = .Item("MD") : MBLit3.Text = .Item("THORST") : MBLit4.Text = .Item("YR")
                End With
            End If
        End If
        If Session("ORG_ID") IsNot Nothing AndAlso Session("ORG_ID").ToString() = "EU10" Then
            MB2_1.Visible = True
        End If
    End Sub
</script>
<tr runat="server" id="MB1" visible="false">
    <td height="24" class="menu_title">MyAdvantech Billboard
    </td>
</tr>
<tr runat="server" id="MB2" visible="false">
    <td>
        <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login" style="font-weight: bold;">
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td class="menu_title11">Dear Customers,<br />
                    Advantech Europe <font color="tomato">
                                    <asp:Literal ID="MBLit1" runat="server"></asp:Literal></font>pricing will be
                                effective on <font color="tomato">
                                    <asp:Literal ID="MBLit2" runat="server"></asp:Literal><sup><asp:Literal ID="MBLit3"
                                        runat="server"></asp:Literal></sup>,
                                    <asp:Literal ID="MBLit4" runat="server"></asp:Literal></font>.
                                <br />
                    Here is the <a target="_blank" href="/Files/MyAdvantechEU_Manual_Jan_2010.pdf"><font
                        color="tomato">User Manual</font></a>.
                                <br />
                    Thank you very much!<br />
                    Advantech Europe
                </td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td width="5%"></td>
                            <td width="5%" valign="top">
                                <asp:Image runat="server" ID="Image4" ImageUrl="~/Images/new2.gif" AlternateText="point" />
                            </td>
                            <td class="menu_title02">
                                <asp:HyperLink runat="server" ID="Esrp" Target="_blank" NavigateUrl="~/Files/AdvantechSalesReturnPolicy20180418.pdf"
                                    Text="Europe Sales Return Policy">
                                </asp:HyperLink>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td width="5%"></td>
                            <td width="5%" valign="top">
                                <asp:Image runat="server" ID="Image3" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                            </td>
                            <td class="menu_title02">
                                <asp:HyperLink runat="server" ID="HyperLink2" Target="_blank" NavigateUrl="~/EC/ChannelInsightEnews.aspx"
                                    Text="Channel Insight Newsletters">
                                </asp:HyperLink>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td width="5%"></td>
                            <td width="5%" valign="top">
                                <asp:Image runat="server" ID="Image1" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                            </td>
                            <td class="menu_title02">
                                <asp:HyperLink runat="server" ID="hyEUWebinar" Target="_blank" NavigateUrl="http://webinar.advantech.eu"
                                    Text="Webinar Schedule">
                                </asp:HyperLink>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr id="MB2_1" runat="server" visible="false">
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td width="5%"></td>
                            <td width="5%" valign="top">
                                <asp:Image runat="server" ID="Image5" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                            </td>
                            <td class="menu_title02">
                                <asp:HyperLink runat="server" ID="HyperLink3" Target="_blank" NavigateUrl="http://advcloudfiles.advantech.com/cms/5d272fb0-41dc-4527-94b4-8b6f93b205bd/eDM%20HTML%20Zip%20File/Content/2018%20Advantech%20Professional_Trainings/index.html"
                                    Text="Advantech Professional Trainings">
                                </asp:HyperLink>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </td>
</tr>
