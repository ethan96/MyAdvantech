<%@ Page Title="AOnline Sales Portal - Campaign Detail" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register Namespace="eBizAEUControls" TagPrefix="uc1" %>
<%@ Register src="AOnlineFunctionLinks.ascx" tagname="AOnlineFunctionLinks" tagprefix="uc1" %>
<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("CampaignId") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("CampaignId")) Then
                Dim ds As DataSet = AOnlineUtil.AOnlineSalesCampaign.GetCampaignAllDetail(Trim(Request("CampaignId")))
                If ds IsNot Nothing Then
                    Dim dtCampaign As DataTable = ds.Tables("AONLINE_SALES_CAMPAIGN"), dtContacts As DataTable = ds.Tables("AONLINE_SALES_CAMPAIGN_CONTACT")
                    Dim dtClickLog As DataTable = ds.Tables("AONLINE_CAMPAIGN_OPENCLICK_LOG"), dtMktRef As DataTable = ds.Tables("AONLINE_SALES_CAMPAIGN_SOURCES")
                    EditorContent.Content = dtCampaign.Rows(0).Item("CONTENT_TEXT")
                    gvMktRef.DataSource = dtMktRef : gvMktRef.DataBind()
                    gvContact.DataSource = dtContacts : gvContact.DataBind()
                    gvClicks.DataSource = dtClickLog : gvClicks.DataBind()
                    tabcon1.ActiveTabIndex = 0
                    If Integer.TryParse(Request("ID"), 0) = True Then tabcon1.ActiveTabIndex = CInt(Request("ID"))
                Else
                   
                End If
            End If
        End If
    End Sub
    
    'Function ShowMktTitleAndUrl(ByVal AppType As String, ByVal SrcId As String) As String
    '    Dim strSubject As String = "", strUrl As String = ""
    '    Select Case AppType
    '        Case "CMS"
    '            Dim ca As CMSDAL.CMSArticle = Nothing
    '            If CMSDAL.GetCMSContentByRecordId(SrcId, ca) Then
    '                strSubject = ca.Title
    '                strUrl = "http://resources.advantech.com/Resources/Details.aspx?rid=" + SrcId
    '            End If
    '        Case "PIS"
    '            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
    '            Dim apt As New SqlClient.SqlDataAdapter( _
    '                "select top 1 LIT_NAME, LIT_TYPE, FILE_NAME, FILE_EXT, model_name, LIT_TXT_CONTENT, GEN_LIT_TYPE " + _
    '                " from PIS_LIT_KM where LITERATURE_ID=@LITID", conn)
    '            apt.SelectCommand.Parameters.AddWithValue("LITID", SrcId)
    '            Dim dt As New DataTable
    '            apt.Fill(dt)
    '            conn.Close()
    '            If dt.Rows.Count = 1 Then
    '                strSubject = dt.Rows(0).Item("LIT_NAME")
    '                strUrl = "'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + SrcId
    '            End If
    '        Case "eCampaign"
    '            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
    '            Dim apt As New SqlClient.SqlDataAdapter( _
    '                "select top 1 campaign_name " + _
    '                " from campaign_master where row_id=@CID", conn)
    '            apt.SelectCommand.Parameters.AddWithValue("CID", SrcId)
    '            Dim dt As New DataTable
    '            apt.Fill(dt)
    '            conn.Close()
    '            If dt.Rows.Count = 1 Then
    '                strSubject = dt.Rows(0).Item("campaign_name")
    '                strUrl = "'http://my.advantech.com/Includes/GetTemplate.ashx?RowId=" + SrcId
    '            End If
    '    End Select
    '    Return String.Format("<a target='_blank' href='{0}'>{1}</a>", strUrl, strSubject)
    'End Function

    Protected Sub btnToXlsContact_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        btnToXlsContact1_Click(sender, New System.EventArgs)
    End Sub
    
    Protected Sub btnToXlsContact1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("CampaignId") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("CampaignId")) Then
            Dim ds As DataSet = AOnlineUtil.AOnlineSalesCampaign.GetCampaignAllDetail(Trim(Request("CampaignId")))
            If ds IsNot Nothing Then
                Dim dtContacts As DataTable = ds.Tables("AONLINE_SALES_CAMPAIGN_CONTACT")
                dtContacts.Columns.Add("account") : dtContacts.Columns.Add("firstname") : dtContacts.Columns.Add("lastname")
                Dim arrEmail As New ArrayList
                For Each row As DataRow In dtContacts.Rows
                    arrEmail.Add("'" + row.Item("CONTACT_EMAIL") + "'")
                Next
                If arrEmail.Count > 0 Then
                    Dim dtSiebel As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select email_address as contact_email, account, firstname, lastname from siebel_contact where email_address in ({0}) order by email_address", String.Join(",", arrEmail.ToArray())))
                    If dtSiebel.Rows.Count > 0 Then
                        For Each row As DataRow In dtContacts.Rows
                            Dim rows() As DataRow = dtSiebel.Select(String.Format("contact_email='{0}'", row.Item("contact_email")))
                            If rows.Length > 0 Then
                                row.Item("account") += rows(0).Item("account") + vbCrLf
                                row.Item("firstname") += rows(0).Item("firstname") + vbCrLf
                                row.Item("lastname") += rows(0).Item("lastname") + vbCrLf
                            End If
                        Next
                        dtContacts.AcceptChanges()
                    End If
                End If
                Util.DataTable2ExcelDownload(dtContacts, "Contact List.xls")
            End If
        End If
    End Sub

    Protected Sub btnToXlsClick_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        btnToXlsClick1_Click(sender, New System.EventArgs)
    End Sub

    Protected Sub btnToXlsClick1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("CampaignId") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("CampaignId")) Then
            Dim ds As DataSet = AOnlineUtil.AOnlineSalesCampaign.GetCampaignAllDetail(Trim(Request("CampaignId")))
            If ds IsNot Nothing Then
                Dim dtClickLog As DataTable = ds.Tables("AONLINE_CAMPAIGN_OPENCLICK_LOG")
                Util.DataTable2ExcelDownload(dtClickLog, "Click Report.xls")
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td align="right"><uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" /></td>
        </tr>
    </table>
    <ajaxToolkit:TabContainer runat="server" ID="tabcon1">
        <ajaxToolkit:TabPanel runat="server" ID="tabContent" HeaderText="eDM Content">
            <ContentTemplate>
                <uc1:NoToolBarEditor2 runat="server" ID="EditorContent" Width="880px" Height="600px" ActiveMode="Preview" />
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabMktRef" HeaderText="Referenced Marketing Contents">
            <ContentTemplate>
                <asp:GridView runat="server" ID="gvMktRef" Width="100%" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundField HeaderText="Source" DataField="SOURCE_APP" />
                        <asp:TemplateField HeaderText="Subject">
                            <ItemTemplate>
                                <a target="_blank" href='<%#Eval("ORIGINAL_URL") %>'><%#Eval("CONTENT_TITLE")%></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Referenced Date" DataField="ADDED_DATE" />
                    </Columns>
                </asp:GridView>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabContacts" HeaderText="Target Audience">
            <ContentTemplate>
                <table>
                    <tr><td><asp:ImageButton runat="server" ID="btnToXlsContact" ImageUrl="~/Images/excel.gif" OnClick="btnToXlsContact_Click" /><asp:LinkButton runat="server" ID="btnToXlsContact1" Text="Export To Excel" OnClick="btnToXlsContact1_Click" /></td></tr>
                    <tr>
                        <td>
                            <asp:GridView runat="server" ID="gvContact" Width="100%" AutoGenerateColumns="true">
                                <Columns>
                        
                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>  
        <ajaxToolkit:TabPanel runat="server" ID="tabClicks" HeaderText="Click Report">
            <ContentTemplate>
                <table>
                    <tr><td><asp:ImageButton runat="server" ID="btnToXlsClick" ImageUrl="~/Images/excel.gif" OnClick="btnToXlsClick_Click" /><asp:LinkButton runat="server" ID="btnToXlsClick1" Text="Export To Excel" OnClick="btnToXlsClick1_Click" /></td></tr>
                    <tr>
                        <td>
                            <asp:GridView runat="server" ID="gvClicks" Width="100%" AutoGenerateColumns="false">
                                <Columns>
                                    <asp:TemplateField HeaderText="Contact Email">
                                        <ItemTemplate>
                                            <a target="_blank" href='../../DM/ContactDashboard.aspx?EMAIL=<%#Eval("CONTACT_EMAIL") %>'>
                                                <%#Eval("CONTACT_EMAIL")%></a>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="URL">
                                        <ItemTemplate>
                                            <a target="_blank" href='<%#Eval("URL") %>'><%#Eval("URL") %></a>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Clicked Date/Time" DataField="LOG_TIME" />
                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>      
    </ajaxToolkit:TabContainer>
</asp:Content>