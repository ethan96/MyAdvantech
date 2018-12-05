<%@ Page Title="MyAdvantech - AOnline Resource Center Dashboard" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Src="AOnlineFunctionLinks.ascx" TagName="AOnlineFunctionLinks" TagPrefix="uc1" %>
<script runat="server">
 
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            btnRefContent.Attributes.Add("onmouseover", "this.style.text-decoration='underline'") : btnRefContent.Attributes.Add("onmouseout", "this.style.text-decoration='none'")
            btnPerContent.Attributes.Add("onmouseover", "this.style.text-decoration='underline'") : btnPerContent.Attributes.Add("onmouseout", "this.style.text-decoration='none'")
            btnRefContent.ControlStyle.Font.Bold = True
            txtRefDateFrom.Text = DateAdd(DateInterval.Day, -7, Now).ToString("yyyy/MM/dd")
            txtRefDateTo.Text = Now.ToString("yyyy/MM/dd")
            Dim arrMembers As New ArrayList, arrParMembers As New ArrayList
            arrMembers.Add("'" + Session("user_id").ToString + "'") : arrParMembers.Add("'" + Session("user_id").ToString + "'")
            GetTeamMember(arrMembers, arrParMembers, 3)
            hdnMyMembers.Value = String.Join(",", arrMembers.ToArray())
            BindRefContent()
            MultiView1.ActiveViewIndex = 0
            
        End If
    End Sub
    
    Sub GetTeamMember(ByRef arrMembers As ArrayList, ByVal arrParMembers As ArrayList, ByVal depth As Integer)
        If Util.IsAEUIT OrElse Session("user_id").ToString.ToLower() = "ada.tang@advantech.com.tw" _
            OrElse Session("user_id").ToString.ToLower() = "wen.chiang@advantech.com.tw" Then
            arrMembers.Clear()
        Else
            If depth > 0 Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select distinct email from SIEBEL_SALES_HIERARCHY where PAR_EMAIL in ({0})", String.Join(",", arrParMembers.ToArray())))
                arrParMembers.Clear()
                For Each row As DataRow In dt.Rows
                    If Not arrMembers.Contains("'" + row.Item("email").ToString + "'") Then arrMembers.Add("'" + row.Item("email").ToString + "'")
                    If Not arrParMembers.Contains("'" + row.Item("email").ToString + "'") Then arrParMembers.Add("'" + row.Item("email").ToString + "'")
                Next
                If arrParMembers.Count = 0 Then Exit Sub
                GetTeamMember(arrMembers, arrParMembers, depth - 1)
            Else
                Exit Sub
            End If
        End If
    End Sub
    
    Private Function GetRefContent() As DataTable
        Dim DateFrom As String = txtRefDateFrom.Text.Trim.Replace("'", "")
        Dim DateTo As String = txtRefDateTo.Text.Trim.Replace("'", "")
        If DateFrom = "" Then DateFrom = "1911/01/01" : If DateTo = "" Then DateTo = "9999/12/31"
        Dim strSql As String = _
                " select a.SOURCE_TYPE,  " + _
                " (select top 1 z.CONTENT_TITLE from AONLINE_SALES_CAMPAIGN_SOURCES z where z.SOURCE_APP=a.SOURCE_APP and z.SOURCE_ID=a.SOURCE_ID) as CONTENT_TITLE, " + _
                " (select top 1 z.ORIGINAL_URL from AONLINE_SALES_CAMPAIGN_SOURCES z where z.SOURCE_APP=a.SOURCE_APP and z.SOURCE_ID=a.SOURCE_ID) as ORIGINAL_URL, " + _
                " a.SOURCE_OWNER, COUNT(distinct a.CAMPAIGN_ROW_ID) as RefCounts, a.SOURCE_APP, a.SOURCE_ID " + _
                " from AONLINE_SALES_CAMPAIGN_SOURCES a " + _
                String.Format(" where a.ADDED_DATE between '{0} 00:00:00' and '{1} 23:59:59' ", DateFrom, DateTo) + _
                IIf(hdnMyMembers.Value <> "", String.Format(" and a.CAMPAIGN_ROW_ID in (select z.ROW_ID from AONLINE_SALES_CAMPAIGN z where z.CREATED_BY in ({0})) ", hdnMyMembers.Value), "") + _
                " group by a.SOURCE_APP, a.SOURCE_ID, a.SOURCE_TYPE, a.SOURCE_OWNER order by COUNT(distinct a.CAMPAIGN_ROW_ID) desc"
        Return dbUtil.dbGetDataTable("MyLocal_New", strSql)
    End Function
    
    Sub BindRefContent()
        gvRefContent.DataSource = GetRefContent() : gvRefContent.DataBind()
    End Sub
    
    Function ShowOpenClickRate(ByVal ContactNumber As Integer, OpenedNumber As Integer) As String
        If ContactNumber = 0 Then Return "0"
        Return FormatNumber(CDbl(OpenedNumber) / CDbl(ContactNumber) * 100.0, 0) + "%"
    End Function

    Protected Sub gvRefContent_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim gvCampaigns As GridView = e.Row.FindControl("gvRowCampaign")
            Dim strSrcId As String = CType(e.Row.FindControl("hdSrcId"), HiddenField).Value
            Dim strSrcApp As String = CType(e.Row.FindControl("hdSrcApp"), HiddenField).Value
            gvCampaigns.DataSource = GetReferencedCampaigns(strSrcId, strSrcApp)
            gvCampaigns.DataBind()
        End If
    End Sub
    
    Function GetReferencedCampaigns(ByVal SRCID As String, ByVal SRCAPP As String) As DataTable
        Dim DateFrom As String = txtRefDateFrom.Text.Trim.Replace("'", "")
        Dim DateTo As String = txtRefDateTo.Text.Trim.Replace("'", "")
        If DateFrom = "" Then DateFrom = "1911/01/01" : If DateTo = "" Then DateTo = "9999/12/31"
        Dim strSql As String = _
            " select a.SUBJECT, a.CREATED_BY, a.ACTUAL_SEND_DATE, " + _
            " IsNull((select COUNT(z.contact_email) from AONLINE_SALES_CAMPAIGN_CONTACT z where z.CAMPAIGN_ROW_ID=a.ROW_ID),0) as contacts, a.ROW_ID, a.CREATED_DATE " + _
            " from AONLINE_SALES_CAMPAIGN a " + _
            " where a.ROW_ID in " + _
            " (select distinct CAMPAIGN_ROW_ID from AONLINE_SALES_CAMPAIGN_SOURCES where SOURCE_ID=@SRCID and SOURCE_APP=@SRCAPP) " + _
            String.Format(" and a.actual_send_date between '{0} 00:00:00' and '{1} 23:59:59' ", DateFrom, DateTo) + _
            IIf(hdnMyMembers.Value <> "", String.Format(" and a.CREATED_BY in ({0}) ", hdnMyMembers.Value), "") + _
            " order by a.CREATED_DATE desc, a.ACTUAL_SEND_DATE desc "
        Dim apt As New SqlClient.SqlDataAdapter(strSql, ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
        Dim dt As New DataTable
        apt.SelectCommand.Parameters.AddWithValue("SRCID", SRCID) : apt.SelectCommand.Parameters.AddWithValue("SRCAPP", SRCAPP)
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function

    Protected Sub btnRefContent_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        btnRefContent.ControlStyle.Font.Bold = True
        btnPerContent.ControlStyle.Font.Bold = False
        BindRefContent()
        MultiView1.ActiveViewIndex = 0
    End Sub

    Protected Sub btnPerContent_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        btnPerContent.ControlStyle.Font.Bold = True
        btnRefContent.ControlStyle.Font.Bold = False
        BindPerContent()
        MultiView1.ActiveViewIndex = 1
    End Sub
    
    Sub BindPerContent()
        gvPerContent.DataSource = GetPerContent() : gvPerContent.DataBind()
    End Sub
    
    Private Function GetPerContent() As DataTable
        Dim DateFrom As String = txtRefDateFrom.Text.Trim.Replace("'", "")
        Dim DateTo As String = txtRefDateTo.Text.Trim.Replace("'", "")
        If DateFrom = "" Then DateFrom = "1911/01/01" : If DateTo = "" Then DateTo = "9999/12/31"
        Dim strSql As String = _
            " SELECT a.created_by, COUNT(a.ROW_ID) as RefCounts " + _
            " FROM AONLINE_SALES_CAMPAIGN a " + _
            String.Format(" where a.IS_DRAFT = 0 and a.actual_send_date between '{0} 00:00:00' and '{1} 23:59:59' ", DateFrom, DateTo) + _
            IIf(hdnMyMembers.Value <> "", String.Format(" and a.created_by in ({0}) ", hdnMyMembers.Value), "") + _
            " group by a.CREATED_BY order by COUNT(a.ROW_ID) desc"
        Return dbUtil.dbGetDataTable("MyLocal_New", strSql)
    End Function

    Protected Sub gvPerContent_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim gvCampaigns As GridView = e.Row.FindControl("gvRowRefCampaign")
            gvCampaigns.DataSource = GetPerReferencedCampaigns(e.Row.Cells(0).Text)
            gvCampaigns.DataBind()
        End If
    End Sub
    
    Function GetPerReferencedCampaigns(ByVal created_by As String) As DataTable
        Dim DateFrom As String = txtRefDateFrom.Text.Trim.Replace("'", "")
        Dim DateTo As String = txtRefDateTo.Text.Trim.Replace("'", "")
        If DateFrom = "" Then DateFrom = "1911/01/01" : If DateTo = "" Then DateTo = "9999/12/31"
        Dim strSql As String = _
            " SELECT distinct a.ROW_ID, a.SUBJECT, replace(replace((select distinct z.source_type from AONLINE_SALES_CAMPAIGN_SOURCES z where z.campaign_row_id=a.row_id for xml auto),'<z source_type=""',''),'""/>',' ') as source_type, a.ACTUAL_SEND_DATE, " + _
            " IsNull((select COUNT(z.contact_email) from AONLINE_SALES_CAMPAIGN_CONTACT z where z.CAMPAIGN_ROW_ID=a.ROW_ID),0) as contacts, " + _
            " IsNull((select COUNT(z.contact_email) from AONLINE_SALES_CAMPAIGN_CONTACT z where z.CAMPAIGN_ROW_ID=a.ROW_ID and z.IS_OPENED=1),0) as opened_contacts, " + _
            " IsNull((select COUNT(z.contact_email) from AONLINE_SALES_CAMPAIGN_CONTACT z where z.CAMPAIGN_ROW_ID=a.ROW_ID and z.IS_CLICKED=1),0) as clicked_contacts   " + _
            " FROM AONLINE_SALES_CAMPAIGN a " + _
            String.Format(" where a.CREATED_BY=@CREATED_BY and a.IS_DRAFT=0 and a.actual_send_date between '{0} 00:00:00' and '{1} 23:59:59' ", DateFrom, DateTo) + _
            " order by a.ACTUAL_SEND_DATE desc"
        Dim apt As New SqlClient.SqlDataAdapter(strSql, ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
        Dim dt As New DataTable
        apt.SelectCommand.Parameters.AddWithValue("CREATED_BY", created_by)
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        Return dt
    End Function

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If MultiView1.ActiveViewIndex = 0 Then
            BindRefContent()
        Else
            BindPerContent()
        End If
    End Sub

    Protected Sub gvRefContent_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Session("user_id").ToString.ToLower = "rudy.wang@advantech.com.tw" OrElse Session("user_id").ToString.ToLower = "tc.chen@advantech.com.tw" _
                OrElse Session("user_id").ToString.ToLower = "julia.lin@advantech.com.tw" Then
            End If
        End If
    End Sub

    Protected Sub gvRowCampaign_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
    End Sub
    
    Sub ExportToExcel(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim lnkbtn As LinkButton = CType(sender, LinkButton)
        Dim SRCID As String = CType(CType(lnkbtn.NamingContainer.NamingContainer.NamingContainer, GridViewRow).FindControl("hdSrcId"), HiddenField).Value
        Dim SRCAPP As String = CType(CType(lnkbtn.NamingContainer.NamingContainer.NamingContainer, GridViewRow).FindControl("hdSrcApp"), HiddenField).Value
        Dim DateFrom As String = txtRefDateFrom.Text.Trim.Replace("'", "")
        Dim DateTo As String = txtRefDateTo.Text.Trim.Replace("'", "")
        If DateFrom = "" Then DateFrom = "1911/01/01" : If DateTo = "" Then DateTo = "9999/12/31"
        Dim sql As String = _
            " select a.SUBJECT, a.ACTUAL_SEND_DATE, a.CREATED_BY, b.CONTACT_EMAIL, '' as Account, '' as Firstname, '' as Lastname, b.IS_CLICKED, b.IS_OPENED, b.SENT_DATE, b.LAST_OPENED_TIME, b.LAST_CLICKED_TIME " + _
            "from AONLINE_SALES_CAMPAIGN a inner join AONLINE_SALES_CAMPAIGN_CONTACT b on a.ROW_ID=b.CAMPAIGN_ROW_ID " + _
            "where a.ROW_ID in " + _
            String.Format("(select distinct CAMPAIGN_ROW_ID from AONLINE_SALES_CAMPAIGN_SOURCES where SOURCE_ID='{0}' and SOURCE_APP='{1}') ", SRCID, SRCAPP) + _
            IIf(hdnMyMembers.Value <> "", String.Format(" and a.created_by in ({0}) ", hdnMyMembers.Value), "") + _
            String.Format(" and a.IS_DRAFT = 0 and a.actual_send_date between '{0} 00:00:00' and '{1} 23:59:59' ", DateFrom, DateTo) + _
            "order by a.ACTUAL_SEND_DATE desc, b.CONTACT_EMAIL"
        Dim dtContacts As DataTable = dbUtil.dbGetDataTable("MYLOCAL_NEW", sql)
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
        Util.DataTable2ExcelDownload(dtContacts, "All Contact List.xls")
    End Sub

    Protected Sub gvRowCampaign_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.Header Then
            If Session("user_id").ToString.ToLower = "rudy.wang@advantech.com.tw" OrElse Session("user_id").ToString.ToLower = "tc.chen@advantech.com.tw" _
                OrElse Session("user_id").ToString.ToLower = "julia.lin@advantech.com.tw" Then
                Dim gv As GridView = CType(sender, GridView)
                Dim row As New GridViewRow(0, 0, DataControlRowType.DataRow, DataControlRowState.Normal)
                row.HorizontalAlign = HorizontalAlign.Center
                Dim btnToXls As New LinkButton
                btnToXls.Text = "Download All Contact List"
                AddHandler btnToXls.Click, AddressOf ExportToExcel
                Dim ScriptManager As ScriptManager = Master.FindControl("tlsm1")
                ScriptManager.RegisterPostBackControl(btnToXls)
                Dim icon As New Image
                icon.ImageUrl = "~/Images/excel.gif"
                Dim cell As New TableCell
                cell.Controls.Add(icon) : cell.Controls.Add(btnToXls)
                row.Cells.Add(cell)
                row.Cells(0).ColumnSpan = 3
                gv.Controls(0).Controls.AddAt(gv.Controls(0).Controls.Count - 1, row)
            End If
        End If
    End Sub

    Protected Sub btnDownloadReport_Click(sender As Object, e As System.EventArgs)
        Util.SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        wb.Worksheets(0).Name = "Content Usage Report" : wb.Worksheets(1).Name = "Sales Usage Report"
        
        Dim dtRefContent As DataTable = GetRefContent()
        With wb.Worksheets(0)
            .Cells(0, 0).PutValue("Type") : .Cells(0, 1).PutValue("Content Title") : .Cells(0, 2).PutValue("Content URL") : .Cells(0, 3).PutValue("Content Owner")
            .Cells(0, 4).PutValue("Referenced Times") : .Cells(0, 5).PutValue("eDM Subject") : .Cells(0, 6).PutValue("Sent By") : .Cells(0, 7).PutValue("Sent Date")
            .Cells(0, 8).PutValue("# of Contacts")
        End With
        For j As Integer = 0 To dtRefContent.Columns.Count - 3
            wb.Worksheets(0).Cells(1, j).PutValue(dtRefContent.Rows(0).Item(j))
        Next
        Dim dtRefCamp As DataTable = GetReferencedCampaigns(dtRefContent.Rows(0).Item("SOURCE_ID"), dtRefContent.Rows(0).Item("SOURCE_APP"))
        For i As Integer = 0 To dtRefCamp.Rows.Count - 1
            For j As Integer = 0 To dtRefCamp.Columns.Count - 3
                If IsDate(dtRefCamp.Rows(i).Item(j)) Then
                    wb.Worksheets(0).Cells(i + 1, dtRefContent.Columns.Count - 2 + j).PutValue(dtRefCamp.Rows(i).Item(j).ToString)
                Else
                    wb.Worksheets(0).Cells(i + 1, dtRefContent.Columns.Count - 2 + j).PutValue(dtRefCamp.Rows(i).Item(j))
                End If
            Next
        Next
        Dim colIndex As Integer = 1
        For i As Integer = 1 To dtRefContent.Rows.Count - 1
            colIndex += CInt(dtRefContent.Rows(i - 1).Item("RefCounts"))
            For j As Integer = 0 To dtRefContent.Columns.Count - 3
                wb.Worksheets(0).Cells(i + colIndex, j).PutValue(dtRefContent.Rows(i).Item(j))
            Next
            dtRefCamp = GetReferencedCampaigns(dtRefContent.Rows(i).Item("SOURCE_ID"), dtRefContent.Rows(i).Item("SOURCE_APP"))
            For ic As Integer = 0 To dtRefCamp.Rows.Count - 1
                For jc As Integer = 0 To dtRefCamp.Columns.Count - 3
                    If IsDate(dtRefCamp.Rows(ic).Item(jc)) Then
                        wb.Worksheets(0).Cells(ic + i + colIndex, dtRefContent.Columns.Count - 2 + jc).PutValue(dtRefCamp.Rows(ic).Item(jc).ToString)
                    Else
                        wb.Worksheets(0).Cells(ic + i + colIndex, dtRefContent.Columns.Count - 2 + jc).PutValue(dtRefCamp.Rows(ic).Item(jc))
                    End If
                Next
            Next
        Next
        
        'Get Sales Report
        Dim dtPerContent As DataTable = GetPerContent()
        With wb.Worksheets(1)
            .Cells(0, 0).PutValue("Sales Email") : .Cells(0, 1).PutValue("Referenced Times") : .Cells(0, 2).PutValue("eDM Subject") : .Cells(0, 3).PutValue("Type")
            .Cells(0, 4).PutValue("Sent Date") : .Cells(0, 5).PutValue("# of Contacts") : .Cells(0, 6).PutValue("# of Opened") : .Cells(0, 7).PutValue("# of Clicked")
            .Cells(0, 8).PutValue("Open Rate (%)") : .Cells(0, 9).PutValue("Click Rate (%)")
        End With
        For j As Integer = 0 To dtPerContent.Columns.Count - 1
            wb.Worksheets(1).Cells(1, j).PutValue(dtPerContent.Rows(0).Item(j))
        Next
        Dim dtCamp As DataTable = GetPerReferencedCampaigns(dtPerContent.Rows(0).Item("created_by"))
        For i As Integer = 0 To dtCamp.Rows.Count - 1
            For j As Integer = 1 To dtCamp.Columns.Count - 1
                If IsDate(dtCamp.Rows(i).Item(j)) Then
                    wb.Worksheets(1).Cells(i + 1, dtPerContent.Columns.Count + j - 1).PutValue(dtCamp.Rows(i).Item(j).ToString)
                Else
                    wb.Worksheets(1).Cells(i + 1, dtPerContent.Columns.Count + j - 1).PutValue(dtCamp.Rows(i).Item(j))
                End If
            Next
            wb.Worksheets(1).Cells(i + 1, dtPerContent.Columns.Count + 7 - 1).PutValue(ShowOpenClickRate(dtCamp.Rows(i).Item("contacts"), dtCamp.Rows(i).Item("opened_contacts")))
            wb.Worksheets(1).Cells(i + 1, dtPerContent.Columns.Count + 8 - 1).PutValue(ShowOpenClickRate(dtCamp.Rows(i).Item("contacts"), dtCamp.Rows(i).Item("clicked_contacts")))
        Next
            
        Dim curIndex As Integer = 1
        For i As Integer = 1 To dtPerContent.Rows.Count - 1
            curIndex += CInt(dtPerContent.Rows(i - 1).Item(1))
            For j As Integer = 0 To dtPerContent.Columns.Count - 1
                wb.Worksheets(1).Cells(i + curIndex, j).PutValue(dtPerContent.Rows(i).Item(j))
            Next
            dtCamp = GetPerReferencedCampaigns(dtPerContent.Rows(i).Item("created_by"))
            For ic As Integer = 0 To dtCamp.Rows.Count - 1
                For jc As Integer = 1 To dtCamp.Columns.Count - 1
                    If IsDate(dtCamp.Rows(ic).Item(jc)) Then
                        wb.Worksheets(1).Cells(ic + i + curIndex, dtPerContent.Columns.Count + jc - 1).PutValue(dtCamp.Rows(ic).Item(jc).ToString)
                    Else
                        wb.Worksheets(1).Cells(ic + i + curIndex, dtPerContent.Columns.Count + jc - 1).PutValue(dtCamp.Rows(ic).Item(jc))
                    End If
                Next
                wb.Worksheets(1).Cells(ic + i + curIndex, dtPerContent.Columns.Count + 7 - 1).PutValue(ShowOpenClickRate(dtCamp.Rows(ic).Item("contacts"), dtCamp.Rows(ic).Item("opened_contacts")))
                wb.Worksheets(1).Cells(ic + i + curIndex, dtPerContent.Columns.Count + 8 - 1).PutValue(ShowOpenClickRate(dtCamp.Rows(ic).Item("contacts"), dtCamp.Rows(ic).Item("clicked_contacts")))
            Next
        Next
        With HttpContext.Current.Response
            .Clear()
            .ContentType = "application/vnd.ms-excel"
            .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", "Curated Content Report.xls"))
            .BinaryWrite(wb.SaveToStream().ToArray)
        End With
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:HiddenField runat="server" ID="hdnMyMembers" />
    <asp:Panel runat="server" ID="p1"></asp:Panel>
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <table width="100%" style="padding-top:10px; padding-bottom:15px">
                <tr align="right">
                    <td align="left" style="color: #0070C0; font-size:medium;">
                        <asp:LinkButton runat="server" ID="btnRefContent" Text="Referenced Marketing Resources" ForeColor="#0070C0" OnClick="btnRefContent_Click" /> | <asp:LinkButton runat="server" ID="btnPerContent" Text="Curated Contents Used by Each Sales" ForeColor="#0070C0" OnClick="btnPerContent_Click" />
                    </td>
                    <td align="right">
                        <uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" />
                    </td>
                </tr>
                <tr><td colspan="2" height="10"></td></tr>
                <tr>
                    <td colspan="2">
                        <table cellpadding="0" cellspacing="0">
                            <tr>
                                <th>Referenced Date: </th>
                                <td width="5"></td>
                                <td><asp:TextBox runat="server" ID="txtRefDateFrom" /><ajaxToolkit:CalendarExtender runat="server" ID="ceRefDateFrom" TargetControlID="txtRefDateFrom" Format="yyyy/MM/dd" /></td>
                                <td width="10">~</td>
                                <td><asp:TextBox runat="server" ID="txtRefDateTo" /><ajaxToolkit:CalendarExtender runat="server" ID="ceRefDateTo" TargetControlID="txtRefDateTo" Format="yyyy/MM/dd" /></td>
                                <td width="5"></td>
                                <td><asp:Button Width="60" runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr><td><img src="../../Images/excel.gif" /><asp:LinkButton runat="server" ID="btnDownloadReport" Text="Download Report" OnClick="btnDownloadReport_Click" /></td></tr>
            </table>
            <asp:MultiView runat="server" ID="MultiView1">
                <asp:View runat="server" ID="vRefContent">
                    <table width="100%">
                        <tr>
                            <td>
                                <asp:GridView runat="server" ID="gvRefContent" Width="100%" OnRowDataBound="gvRefContent_RowDataBound" AutoGenerateColumns="false" OnRowCreated="gvRefContent_RowCreated">
                                    <Columns>
                                        <asp:BoundField HeaderText="Type" DataField="SOURCE_TYPE" ItemStyle-HorizontalAlign="Center" />
                                        <asp:TemplateField HeaderText="Content Title">
                                            <ItemTemplate>
                                                <a href='<%#Eval("ORIGINAL_URL")%>' target="_blank"><%#Eval("CONTENT_TITLE")%></a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="Content Owner" DataField="SOURCE_OWNER" ItemStyle-HorizontalAlign="Center" />
                                        <asp:BoundField HeaderText="Referenced Times" DataField="RefCounts" ItemStyle-HorizontalAlign="Center" />
                                        <asp:TemplateField HeaderText="Reference eLetter List" ItemStyle-Width="500px">
                                            <ItemTemplate>
                                                <asp:HiddenField runat="server" ID="hdSrcId" Value='<%#Eval("SOURCE_ID")%>' />
                                                <asp:HiddenField runat="server" ID="hdSrcApp" Value='<%#Eval("SOURCE_APP")%>' />
                                                <asp:GridView runat="server" ID="gvRowCampaign" AutoGenerateColumns="false" OnPreRender="gvRowCampaign_PreRender" OnRowCreated="gvRowCampaign_RowCreated">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="eDM Subject" DataField="SUBJECT" />
                                                        <asp:TemplateField HeaderText="Sent By" ItemStyle-Width="42%">
                                                            <ItemTemplate>
                                                                <table width="100%">
                                                                    <tr><td><%# Eval("CREATED_BY")%></td></tr>
                                                                    <tr><td style="font-style:italic; color:gray">on <%# Eval("ACTUAL_SEND_DATE")%></td></tr>
                                                                </table>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="# of Contacts" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%">
                                                            <ItemTemplate>
                                                                <a target="_blank" href='CampaignDetail.aspx?CampaignId=<%#Eval("ROW_ID") %>&ID=2'>
                                                                    <%# Eval("contacts")%></a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </td>
                        </tr>
                    </table>
                </asp:View>
                <asp:View runat="server" ID="vPreContent">
                    <table width="100%">
                        <tr>
                            <td>
                                <asp:GridView runat="server" ID="gvPerContent" Width="100%" AutoGenerateColumns="false" OnRowDataBound="gvPerContent_RowDataBound">
                                    <Columns>
                                        <asp:BoundField HeaderText="Sales Email" DataField="CREATED_BY" />
                                        <asp:BoundField HeaderText="Referenced Times" DataField="RefCounts" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%" />
                                        <asp:TemplateField HeaderText="Referenced Articles" ItemStyle-Width="70%">
                                            <ItemTemplate>
                                                <asp:GridView runat="server" ID="gvRowRefCampaign" AutoGenerateColumns="false" Width="100%">
                                                    <Columns>
                                                        <asp:TemplateField HeaderText="eDM Subject">
                                                            <ItemTemplate>
                                                                <a target="_blank" href='CampaignDetail.aspx?CampaignId=<%#Eval("ROW_ID") %>&ID=0'>
                                                                    <%# Eval("SUBJECT")%></a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="SOURCE_TYPE" HeaderText="Type" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="15%" />
                                                        <asp:TemplateField HeaderText="# of Contacts" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%">
                                                            <ItemTemplate>
                                                                <a target="_blank" href='CampaignDetail.aspx?CampaignId=<%#Eval("ROW_ID") %>&ID=2'>
                                                                    <%# Eval("contacts")%></a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField HeaderText="# of Opened" DataField="opened_contacts" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%" />
                                                        <asp:BoundField HeaderText="# of Clicked" DataField="clicked_contacts" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%" />
                                                        <asp:TemplateField HeaderText="Open Rate (%)" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%">
                                                            <ItemTemplate>
                                                                <%#ShowOpenClickRate(Eval("contacts"), Eval("opened_contacts"))%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Click Rate (%)" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%">
                                                            <ItemTemplate>
                                                                <%#ShowOpenClickRate(Eval("contacts"), Eval("clicked_contacts"))%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </td>
                        </tr>
                    </table>
                </asp:View>
            </asp:MultiView>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnDownloadReport" />
        </Triggers>
    </asp:UpdatePanel>
    
</asp:Content>
