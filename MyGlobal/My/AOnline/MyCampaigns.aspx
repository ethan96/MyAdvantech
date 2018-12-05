<%@ Page Title="AOnline Sales Portal - My Campaign Statistics" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register src="AOnlineFunctionLinks.ascx" tagname="AOnlineFunctionLinks" tagprefix="uc1" %>
<script runat="server">
    Function GetMyCampaigns() As DataTable
        Dim strSql As String = _
            " select top 50 a.ROW_ID, a.CREATED_DATE, a.SUBJECT, a.ACTUAL_SEND_DATE, " + _
            " IsNull((select COUNT(z.contact_email) from AONLINE_SALES_CAMPAIGN_CONTACT z where z.CAMPAIGN_ROW_ID=a.ROW_ID),0) as contacts, " + _
            " IsNull((select COUNT(z.contact_email) from AONLINE_SALES_CAMPAIGN_CONTACT z where z.CAMPAIGN_ROW_ID=a.ROW_ID and z.IS_OPENED=1),0) as opened_contacts, " + _
            " IsNull((select COUNT(z.contact_email) from AONLINE_SALES_CAMPAIGN_CONTACT z where z.CAMPAIGN_ROW_ID=a.ROW_ID and z.IS_CLICKED=1),0) as clicked_contacts   " + _
            " from AONLINE_SALES_CAMPAIGN a " + _
            " where (a.CREATED_BY=@UID or a.LAST_UPD_BY=@UID) " + _
            " order by a.CREATED_DATE desc, a.ACTUAL_SEND_DATE desc "
        Dim apt As New SqlClient.SqlDataAdapter(strSql, ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
        Dim dt As New DataTable
        apt.SelectCommand.Parameters.AddWithValue("UID", User.Identity.Name)
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            gv1.DataSource = GetMyCampaigns() : gv1.DataBind()
        End If
    End Sub
    
    Function ShowOpenClickRate(ByVal ContactNumber As Integer, OpenedNumber As Integer) As String
        If ContactNumber = 0 Then Return "0"
        Return FormatNumber(CDbl(OpenedNumber) / CDbl(ContactNumber) * 100.0, 0) + "%"
    End Function

    Protected Sub btnReuse_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        dbUtil.dbExecuteNoQuery("MYLOCAL_NEW", String.Format("delete from AONLINE_SALES_CONTENT_CART where SESSIONID='{0}'", Session.SessionID))
        Dim camp_id As String = CType(CType(CType(sender, Button).NamingContainer, GridViewRow).FindControl("hdnCampId"), HiddenField).Value
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", String.Format("select isnull(SOURCE_ID,'') as SOURCE_ID,isnull(SOURCE_APP,'') as SOURCE_APP,isnull(CONTENT_TITLE,'') as CONTENT_TITLE,isnull(ORIGINAL_URL,'') as ORIGINAL_URL from AONLINE_SALES_CAMPAIGN_SOURCES where campaign_row_id='{0}'", camp_id))
        If dt.Rows.Count > 0 Then
            For Each row As DataRow In dt.Rows
                AOnlineUtil.AOnlineSalesCampaign.AddContentToMyContentCart(row.Item("SOURCE_ID").ToString, row.Item("CONTENT_TITLE").ToString, row.Item("SOURCE_APP").ToString, row.Item("ORIGINAL_URL").ToString)
            Next
        End If
        Response.Redirect("ContentForward.aspx?campid=" + camp_id)
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr align="right"><td align="right"><uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" /></td></tr>
    </table>
    <h2>My eLetters</h2><br />
    <table>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:Button runat="server" ID="btnReuse" Text="Re-Use" OnClick="btnReuse_Click" />
                                <asp:HiddenField runat="server" ID="hdnCampId" Value='<%#Eval("ROW_ID") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="eDM Subject">
                            <ItemTemplate>
                                <a target="_blank" href='CampaignDetail.aspx?CampaignId=<%#Eval("ROW_ID") %>'><%#Eval("SUBJECT")%></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Send Date" DataField="ACTUAL_SEND_DATE" />
                        <asp:BoundField HeaderText="# of Contacts" DataField="contacts" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="# of Opened" DataField="opened_contacts" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="# of Clicked" DataField="clicked_contacts" ItemStyle-HorizontalAlign="Center" />
                        <asp:TemplateField HeaderText="Open Rate (%)" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#ShowOpenClickRate(Eval("contacts"), Eval("opened_contacts"))%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Click Rate (%)" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#ShowOpenClickRate(Eval("contacts"), Eval("clicked_contacts"))%>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </td>
        </tr>
    </table>
</asp:Content>