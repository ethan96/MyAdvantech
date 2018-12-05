<%@ Page Title="MyAdvantech - Campaign Report Overview" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Private Function GetDataTable(Optional ByVal is_formatNumber As Boolean = False) As DataTable
        Dim sql As String = ""
        If txtDateFrom.Text.Trim = "" AndAlso txtDateTo.Text <> "" Then txtDateFrom.Text = DateAdd(DateInterval.Month, -6, CDate(txtDateTo.Text)).ToString("yyyy/MM/dd")
        If txtDateFrom.Text <> "" AndAlso txtDateTo.Text = "" Then txtDateTo.Text = DateAdd(DateInterval.Month, 6, CDate(txtDateFrom.Text)).ToString("yyyy/MM/dd")
        If txtDateFrom.Text = "" AndAlso txtDateTo.Text = "" Then txtDateFrom.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd") : txtDateTo.Text = Now.ToString("yyyy/MM/dd")
        Dim arrRBU As New ArrayList, arrENews As New ArrayList
        For Each item As ListItem In cblRBU.Items
            If item.Selected Then arrRBU.Add("'" + item.Value + "'")
        Next
        If dleNews.SelectedValue <> "All" Then arrENews.Add("'" + dleNews.SelectedValue + "'")
        Return eCampaignReportingUtility.GetCampaignOverview(arrRBU, arrENews, CDate(txtDateFrom.Text), CDate(txtDateTo.Text), is_formatNumber)
    End Function
    
    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") = Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property

    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") = Nothing, String.Empty, ViewState("SortExpression"))
        End Get
        Set(ByVal value As String)
            ViewState("SortExpression") = value
        End Set
    End Property
    
    Private Function GetSortDirection() As String
        Select Case GridViewSortDirection
            Case "ASC"
                GridViewSortDirection = "DESC"
            Case "DESC"
                GridViewSortDirection = "ASC"
        End Select
        Return GridViewSortDirection
    End Function
    
    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gv1.Sorting
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gv1.PageIndex
        gv1.DataSource = SortDataTable(GetDataTable(), False)
        gv1.DataBind()
        gv1.PageIndex = pageIndex
    End Sub
    
    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GetSortDirection())
                End If
            End If
            Return dataView
        Else
            Response.Write("no gv source!")
            Return New DataView()
        End If
    End Function
    
    Protected Sub cbAll_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        For Each l As ListItem In cblRBU.Items
            l.Selected = cbAll.Checked
        Next
    End Sub
    
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = GetDataTable()
        If dt.Rows.Count > 0 Then
            PanelGV.Visible = True : gv1.DataSource = dt : gv1.DataBind()
        End If
    End Sub
    
    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ToXls_Click(sender, New ImageClickEventArgs(1, 1))
    End Sub
    
    Protected Sub ToXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        DataTable2ExcelFile(GetDataTable(True), "Click Report.xls")
    End Sub
    
    Public Sub DataTable2ExcelFile(ByVal dt As DataTable, ByVal path As String)
        Util.SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        For i As Integer = 0 To dt.Columns.Count - 1
            wb.Worksheets(0).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
        Next
        For i As Integer = 0 To dt.Rows.Count - 1
            For j As Integer = 0 To dt.Columns.Count - 1
                If dt.Columns(j).ColumnName = "actual_send_date" Then
                    wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j).ToString)
                Else
                    If dt.Columns(j).ColumnName = "open_rate" Or dt.Columns(j).ColumnName = "click_rate" Or dt.Columns(j).ColumnName = "delivery_rate" _
                        Or dt.Columns(j).ColumnName = "click_rate_per_open" Or dt.Columns(j).ColumnName = "unsubscribe_rate" Then
                        wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j), False)
                    Else
                        wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j), True)
                    End If
                End If
            Next
        Next
            
        With HttpContext.Current.Response
            .Clear()
            .ContentType = "application/vnd.ms-excel"
            .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", path))
            .BinaryWrite(wb.SaveToStream().ToArray)
            .End()
        End With
    End Sub
    
    Protected Sub gv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Date.TryParse(e.Row.Cells(1).Text, Now) = True Then e.Row.Cells(1).Text = CDate(e.Row.Cells(1).Text).ToString("yyyy/MM/dd")
            Dim cols As Integer() = {8, 10, 13, 14, 16}
            For Each col As Integer In cols
                e.Row.Cells(col).Text = String.Format("{0:n2}", e.Row.Cells(col).Text * 100) + "%"
            Next
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Not MailUtil.IsInRole("AOnline") AndAlso Not MailUtil.IsInRole("AOnline.ACN") AndAlso Not MailUtil.IsInRole("AOnline.AKR") _
                 AndAlso Not MailUtil.IsInRole("AOnline.estore") AndAlso Not MailUtil.IsInRole("AOnline.Marketing") AndAlso Not MailUtil.IsInRole("aonline.parttime") _
                  AndAlso Not MailUtil.IsInRole("Aonline.USA") AndAlso Not Util.IsAEUIT() Then
                Response.Redirect("/home.aspx", False)
            End If
            txtDateFrom.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd")
            txtDateTo.Text = Now.ToString("yyyy/MM/dd")
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <asp:Panel runat="server" ID="PanelSearch" DefaultButton="btnSearch">
        <table width="100%">
            <tr><td height="10"></td></tr>
            <tr><th align="left" style="font-size:medium">Campaign Report</th></tr>
            <tr><td height="5"></td></tr>
            <tr>
                <td>
                    <table width="100%" style="background-color:#ebebeb">
                        <tr>
                            <td width="5"></td>
                            <td><b> RBU : </b></td>
                            <td colspan="4">
                                <table width="100%">
                                    <tr>
                                        <td><asp:CheckBox runat="server" ID="cbAll" AutoPostBack="true" Text="All" OnCheckedChanged="cbAll_CheckedChanged" /></td>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="upRBU" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:CheckBoxList runat="server" ID="cblRBU" AutoPostBack="false" Width="100%" RepeatDirection="Vertical" RepeatColumns="8" DataSourceID="sqlRBU" DataTextField="TEXT" DataValueField="VALUE">
                                                    </asp:CheckBoxList>
                                                    <asp:SqlDataSource runat="server" ID="sqlRBU" ConnectionString="<%$ConnectionStrings:RFM %>" 
                                                           SelectCommand="select TEXT, VALUE from SIEBEL_ACCOUNT_RBU_LOV where VALUE<>'' and TEXT<>'' order by TEXT" />
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="cbAll" EventName="CheckedChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td width="5"></td>
                            <td><b> eNews: </b></td>
                            <td>
                                <asp:DropDownList runat="server" ID="dleNews" DataSourceID="eNewsLov" DataTextField="value" DataValueField="value" AppendDataBoundItems="true" AutoPostBack="false">
                                    <asp:ListItem text="All" Value="All"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:SqlDataSource runat="server" ID="eNewsLov" ConnectionString="<%$ ConnectionStrings:RFM %>" 
                                    SelectCommand="select '' as text, '' as value union select distinct text, value from SIEBEL_CONTACT_InterestedENews_LOV order by text"/>
                            </td>
                            <td><b> Delivery Date : </b></td>
                            <td>
                                <asp:TextBox runat="server" ID="txtDateFrom" /> ~ <asp:TextBox runat="server" ID="txtDateTo" />
                                <ajaxToolkit:CalendarExtender runat="server" ID="ceFrom" TargetControlID="txtDateFrom" Format="yyyy/MM/dd" />
                                <ajaxToolkit:CalendarExtender runat="server" ID="ceTo" TargetControlID="txtDateTo" Format="yyyy/MM/dd" />
                            </td>
                            <td><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
                        </tr>
                        <tr><td colspan="7" height="5"></td></tr>
                    </table>
                </td>
            </tr>        
        </table>
    </asp:Panel>
    
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Panel runat="server" ID="PanelGV" Visible="false">
                <table>
                    <tr><td height="10"></td></tr>
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td><asp:ImageButton runat="server" ID="ToXls" ImageUrl="~/Images/excel.gif" AlternateText="Export To Excel" OnClick="ToXls_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnToXls" Text="Export To Excel" OnClick="btnToXls_Click" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <sgv:SmartGridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataKeyNames="ROW_ID" AllowSorting="true" OnRowDataBoundDataRow="gv1_RowDataBoundDataRow">
                                <Columns>             
                                    <asp:HyperLinkField HeaderText="Campaign Name" SortExpression="campaign_name" DataTextField="campaign_name" DataNavigateUrlFields="row_id" DataNavigateUrlFormatString="~/Includes/GetTemplate.ashx?RowId={0}" Target="_blank" />
                                    <asp:BoundField HeaderText="Delivery Date" DataField="actual_send_date" SortExpression="actual_send_date" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="eNews Category" DataField="eNews" SortExpression="eNews" />
                                    <asp:BoundField HeaderText="RBU" DataField="region" SortExpression="region" />
                                    <asp:BoundField HeaderText="Send By" DataField="created_by" SortExpression="created_by" />
                                    <asp:BoundField HeaderText="# of Recipients" DataField="recipients" SortExpression="recipients" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of Email Delivered" DataField="email_delivered" SortExpression="email_delivered" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of Hard Bounced" DataField="hard_bounced" SortExpression="hard_bounced" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Delivery Rate" DataField="delivery_rate" SortExpression="delivery_rate" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# recipients who opened" DataField="recipient_opens" SortExpression="recipient_opens" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Open Rate" DataField="open_rate" SortExpression="open_rate" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Total Clicks" DataField="total_clicks" SortExpression="total_clicks" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of contacts who clicked eDM" DataField="recipient_clicks" SortExpression="recipient_clicks" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Click Rate" DataField="click_rate" SortExpression="click_rate" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Click Rate Per Open Message" DataField="click_rate_per_open" SortExpression="click_rate_per_open" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of Unsubscribers" DataField="unsubscribe" SortExpression="unsubscribe" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Unsubscribe Rate" DataField="unsubscribe_rate" SortExpression="unsubscribe_rate" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of KA Clicks" DataField="ka_clicks" SortExpression="ka_clicks" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of GA Clicks" DataField="ga_clicks" SortExpression="ga_clicks" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of CP Clicks" DataField="cp_clicks" SortExpression="cp_clicks" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of Sales Contacts Clicks" DataField="sales_contacts_clicks" SortExpression="sales_contacts_clicks" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="# of Other Clicks" DataField="other_clicks" SortExpression="other_clicks" ItemStyle-HorizontalAlign="Center" />
                                </Columns>
                                <FixRowColumn FixRowType="Header" TableHeight="500px" TableWidth="900px" FixColumns="-1" FixRows="-1" />
                                <SmartSorting AllowMultiSorting="True" AllowSortTip="True" />
                            </sgv:SmartGridView>
                        </td>
                    </tr>
                    <tr><td height="30"></td></tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
            <asp:PostBackTrigger ControlID="ToXls" />
            <asp:PostBackTrigger ControlID="btnToXls" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>

