<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Account Admin" %>

<script runat="server">
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetUserID(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", String.Format("select distinct top 10 PrimarySmtpAddress from ADVANTECH_ADDRESSBOOK where PrimarySmtpAddressd like '{0}%'", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    Protected Sub btnAddUser_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim iRet As Integer = CInt(dbUtil.dbExecuteScalar("My", "select count(userid) from contact where userid='" + Trim(txtUserID.Text) + "'"))
        'If iRet > 0 Then
        Dim iRet As Integer = CInt(dbUtil.dbExecuteScalar("My", "select count(userid) from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid = '" + Trim(txtUserID.Text) + "'"))
        If iRet = 0 Then
            'Dim sb As New StringBuilder
            'sb.Append("<account></account>")
            dbUtil.dbExecuteNoQuery("My", String.Format("insert into MYADVANTECH_ACCOUNT_ADMIN_USERS (userid,rbu) values ('{0}','')", Trim(txtUserID.Text)))
            gv1.DataBind()
        Else
            Util.JSAlert(Page, "This account has already existed.")
        End If
        'Else
        'Util.JSAlert(Page, "This account is not registered user.")
        'End If
    End Sub

    Protected Sub gv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            'e.Row.Cells(2).Text = e.Row.Cells(2).Text.Replace("FUTURE, Engineering", "FUTURE Engineering")
        End If
    End Sub
    
    Protected Sub btnDeleteUser_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim userid As String = CType(CType(sender, Button).NamingContainer, GridViewRow).Cells(1).Text
        dbUtil.dbExecuteNoQuery("My", "delete from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid='" + userid + "'")
        gv1.DataBind()
        up1.Update()
    End Sub

    Protected Sub btnEditUser_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        cbSelectAll.Checked = False
        Dim rbuList As String = CType(CType(sender, Button).NamingContainer, GridViewRow).Cells(2).Text
        If Trim(rbuList) <> "" Then
            Dim table As New DataTable
            table.Columns.Add("No.", GetType(String))
            table.Columns.Add("RBU", GetType(String))
            Dim rbuArray As New ArrayList
            If rbuList.Replace("&nbsp;", "") <> "" Then
                Dim rbu() As String = Trim(rbuList).Split("|")
                For i As Integer = 0 To rbu.Length - 1
                    Dim row As DataRow = table.NewRow()
                    row("No.") = i + 1
                    row("RBU") = rbu(i)
                    table.Rows.Add(row)
                    rbuArray.Add(rbu(i))
                Next
            End If
            If rbuArray.Count > 0 Then
                If rbuArray.Item(0).ToString = "All" Then
                    'cbSelectAll.Enabled = False
                    cbSelectAll.Checked = True
                    cblRBU.Enabled = False : btnAddRBU.Enabled = False
                Else
                    
                    'SqlDataSource2.SelectCommand = "select * from siebel_account_rbu_lov where text not in (" + String.Join(",", rbuArray.ToArray()) + ")"
                    cblRBU.DataBind() : btnAddRBU.Enabled = True
                    For Each r As String In rbuArray
                        cblRBU.Items.FindByText(r).Selected = True
                    Next
                End If
                btnDeleteRBU.Enabled = True
            Else
                'SqlDataSource2.SelectCommand = "select * from siebel_account_rbu_lov"
                cblRBU.DataBind()
                cbSelectAll.Enabled = True : cblRBU.Enabled = True : btnAddRBU.Enabled = True
                btnDeleteRBU.Enabled = False
            End If
            gvRBU.DataSource = table
            gvRBU.DataBind()
        End If
        lblUserID.Text = CType(CType(sender, Button).NamingContainer, GridViewRow).Cells(1).Text
        ModalPopupExtender1.Show()
        up2.Update()
    End Sub

    Protected Sub btnDeleteRBU_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim arrRbuList As New ArrayList
        For Each gvRow As GridViewRow In gvRBU.Rows
            If gvRow.RowType = DataControlRowType.DataRow Then
                Dim cb As CheckBox = CType(gvRow.FindControl("chkItem"), CheckBox)
                If cb IsNot Nothing And cb.Checked = False Then
                    arrRbuList.Add(gvRow.Cells(2).Text)
                End If
            End If
        Next
        dbUtil.dbExecuteNoQuery("My", String.Format("update MYADVANTECH_ACCOUNT_ADMIN_USERS set rbu='{0}' where userid='{1}'", IIf(arrRbuList.Count > 0, String.Join("|", arrRbuList.ToArray()), ""), lblUserID.Text))
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select isnull(rbu,'') as rbu from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid='" + Session("user_id") + "'")
        'rbuList = rbuList.Replace("FUTURE, Engineering", "FUTURE Engineering")
        Dim rbuList As String = ""
        If dt.Rows.Count > 0 Then
            rbuList = dt.Rows(0).Item(0).ToString
        End If
        Dim table As New DataTable
        table.Columns.Add("No.", GetType(String)) : table.Columns.Add("RBU", GetType(String))
        Dim rbuArray As New ArrayList
        If rbuList.Replace("&nbsp;", "") <> "" Then
            Dim rbu() As String = Trim(rbuList).Split("|")
            For i As Integer = 0 To rbu.Length - 1
                Dim row As DataRow = table.NewRow()
                row("No.") = i + 1
                row("RBU") = rbu(i)
                table.Rows.Add(row)
                rbuArray.Add("'" + rbu(i) + "'")
            Next
        End If
        If rbuArray.Count > 0 Then
            If rbuArray.Item(0).ToString = "'All'" Then
                cbSelectAll.Enabled = False : cblRBU.Enabled = False : btnAddRBU.Enabled = False
            Else
                SqlDataSource2.SelectCommand = "select * from siebel_account_rbu_lov where text not in (" + String.Join(",", rbuArray.ToArray()) + ")"
                cblRBU.DataBind() : btnAddRBU.Enabled = True
            End If
            btnDeleteRBU.Enabled = True
        Else
            SqlDataSource2.SelectCommand = "select * from siebel_account_rbu_lov"
            cblRBU.DataBind()
            cbSelectAll.Enabled = True : cblRBU.Enabled = True : btnAddRBU.Enabled = True
            btnDeleteRBU.Enabled = False
        End If
        gvRBU.DataSource = table
        gvRBU.DataBind()
        up2.Update()
    End Sub
    
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender1.Hide()
        gv1.DataBind()
        up1.Update()
    End Sub

    Protected Sub btnSelectRBU_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.Panel2.Visible = False Then Me.Panel2.Visible = True Else Me.Panel2.Visible = False
    End Sub

    Protected Sub btnAddRBU_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If cbSelectAll.Checked Then
            dbUtil.dbExecuteNoQuery("My", String.Format("update MYADVANTECH_ACCOUNT_ADMIN_USERS set rbu ='All' where userid='{0}'", lblUserID.Text))
            'dbUtil.dbExecuteNoQuery("My", String.Format("update account_admin set rbu.modify('insert <rbu id=""{0}"">{0}</rbu> into (/account)[last()]') where userid='{1}'", cbSelectAll.Text, lblUserID.Text))
        Else
            Dim arrRbuList As New ArrayList
            For i As Integer = 0 To cblRBU.Items.Count - 1
                If cblRBU.Items(i).Selected Then
                    arrRbuList.Add(cblRBU.Items(i).Value)
                End If
            Next
            dbUtil.dbExecuteNoQuery("My", String.Format("update MYADVANTECH_ACCOUNT_ADMIN_USERS set rbu='{0}' where userid='{1}'", IIf(arrRbuList.Count > 0, String.Join("|", arrRbuList.ToArray()), ""), lblUserID.Text))
        End If
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select isnull(rbu,'') as rbu from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid='" + lblUserID.Text + "'")
        'rbuList = rbuList.Replace("FUTURE, Engineering", "FUTURE Engineering")
        Dim rbuList As String = ""
        If dt.Rows.Count > 0 Then
            rbuList = dt.Rows(0).Item(0).ToString
        End If
        
        Dim table As New DataTable
        table.Columns.Add("No.", GetType(String)) : table.Columns.Add("RBU", GetType(String))
        Dim rbuArray As New ArrayList
        If rbuList.Replace("&nbsp;", "") <> "" Then
            Dim rbu() As String = Trim(rbuList).Split("|")
            For i As Integer = 0 To rbu.Length - 1
                Dim row As DataRow = table.NewRow()
                row("No.") = i + 1
                row("RBU") = rbu(i)
                table.Rows.Add(row)
                rbuArray.Add(rbu(i))
            Next
        End If
        If rbuArray.Count > 0 Then
            If rbuArray.Item(0).ToString = "All" Then
                'cbSelectAll.Enabled = False
                cbSelectAll.Checked = True
                cblRBU.Enabled = False : btnAddRBU.Enabled = False
            Else
                'SqlDataSource2.SelectCommand = "select * from siebel_account_rbu_lov where text not in (" + String.Join(",", rbuArray.ToArray()) + ")"
                For Each r As String In rbuArray
                    cblRBU.Items.FindByText(r).Selected = True
                Next
                cblRBU.DataBind() : btnAddRBU.Enabled = True
            End If
            btnDeleteRBU.Enabled = True
        Else
            'SqlDataSource2.SelectCommand = "select * from siebel_account_rbu_lov"
            cblRBU.DataBind()
            cbSelectAll.Enabled = True : cblRBU.Enabled = True : btnAddRBU.Enabled = True
            btnDeleteRBU.Enabled = False
        End If
        gvRBU.DataSource = table
        gvRBU.DataBind()
        up2.Update()
    End Sub

    Protected Sub cblRBU_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub

    Protected Sub cblRBU_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        SqlDataSource2.SelectCommand = "select * from siebel_account_rbu_lov"
    End Sub

    Protected Sub cbSelectAll_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        If CType(sender, CheckBox).Checked Then
            cblRBU.Enabled = False
        Else
            cblRBU.Enabled = True
        End If
    End Sub

    Protected Sub btnDeleteOwner_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        For Each gvRow As GridViewRow In gv2.Rows
            If gvRow.RowType = DataControlRowType.DataRow Then
                Dim cb As CheckBox = CType(gvRow.FindControl("chkOwnerItem"), CheckBox)
                If cb IsNot Nothing And cb.Checked Then
                    dbUtil.dbExecuteNoQuery("My", "update contact set IsAccountOwner = 0 where userid='" + gvRow.Cells(2).Text + "'")
                End If
            End If
        Next
        gv2.DataBind() : gv3.DataBind()
    End Sub

    Protected Sub btnAddOwner_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        For Each gvRow As GridViewRow In gv3.Rows
            If gvRow.RowType = DataControlRowType.DataRow Then
                Dim cb As CheckBox = CType(gvRow.FindControl("chkNotOwnerItem"), CheckBox)
                If cb IsNot Nothing And cb.Checked Then
                    dbUtil.dbExecuteNoQuery("My", "update contact set IsAccountOwner = 1 where userid='" + gvRow.Cells(2).Text + "'")
                End If
            End If
        Next
        gv2.DataBind() : gv3.DataBind()
    End Sub

    Protected Sub btnSearchOwner_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        SqlDataSource3.SelectCommand = "select distinct userid from contact where IsAccountOwner = 1 and userid like '" + Trim(txtSearchOwner.Text) + "%' order by userid"
        gv2.DataBind()
    End Sub

    Protected Sub btnSearchNotOwner_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        SqlDataSource4.SelectCommand = "select distinct userid from contact where IsAccountOwner = 0 and employee_flag='N' and userid like '" + Trim(txtSearchNotOwner.Text) + "%' order by userid"
        gv3.DataBind()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Util.IsAdmin() Then
            tabPanel1.Visible = True
        Else
            tabPanel1.Visible = False : tabPanel1.HeaderText = ""
        End If
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsAdmin() Then Response.Redirect("/admin/b2b_admin_portal.aspx")
    End Sub

    Protected Sub SqlDataSource3_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select isnull(rbu,'') as rbu from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid='" + Session("user_id") + "'")
        'rbuList = rbuList.Replace("FUTURE, Engineering", "FUTURE Engineering")
        Dim rbuList As String = ""
        If dt.Rows.Count > 0 Then
            rbuList = dt.Rows(0).Item(0).ToString
        End If
        If Not IsNothing(rbuList) Then
            Dim rbuArray As New ArrayList
            If rbuList.Replace("&nbsp;", "") <> "" Then
                Dim rbu() As String = Trim(rbuList).Split("|")
                For i As Integer = 0 To rbu.Length - 1
                    rbuArray.Add("'" + rbu(i) + "'")
                Next
                If rbuArray.Count > 0 Then
                    If rbuArray.Item(0).ToString = "'All'" Then
                        SqlDataSource3.SelectCommand = "select distinct userid from contact where IsAccountOwner = 1 order by userid"
                    Else
                        SqlDataSource3.SelectCommand = "select distinct a.userid from contact a inner join Siebel_Account b on a.Company_id=b.ERP_ID where b.rbu in (" + String.Join(",", rbuArray.ToArray()) + ") and a.IsAccountOwner = 1 order by a.userid"
                    End If
                End If
            End If
        End If
        
    End Sub

    Protected Sub SqlDataSource4_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select isnull(rbu,'') as rbu from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid='" + Session("user_id") + "'")
        'rbuList = rbuList.Replace("FUTURE, Engineering", "FUTURE Engineering")
        Dim rbuList As String = ""
        If dt.Rows.Count > 0 Then
            rbuList = dt.Rows(0).Item(0).ToString
        End If
        If Not IsNothing(rbuList) Then
            Dim rbuArray As New ArrayList
            If rbuList.Replace("&nbsp;", "") <> "" Then
                Dim rbu() As String = Trim(rbuList).Split("|")
                For i As Integer = 0 To rbu.Length - 1
                    rbuArray.Add("'" + rbu(i) + "'")
                Next
                If rbuArray.Count > 0 Then
                    If rbuArray.Item(0).ToString = "'All'" Then
                        SqlDataSource4.SelectCommand = "select distinct userid from contact where IsAccountOwner = 0 and employee_flag='N' order by userid"
                    Else
                        SqlDataSource4.SelectCommand = "select distinct a.userid from contact a inner join Siebel_Account b on a.Company_id=b.ERP_ID where b.rbu in (" + String.Join(",", rbuArray.ToArray()) + ") and a.IsAccountOwner = 0 and a.employee_flag='N' order by a.userid"
                    End If
                End If
            End If
        End If
        
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <br />
    <ajaxToolkit:TabContainer runat="server" ID="TabContainer1">
        <ajaxToolkit:TabPanel runat="server" ID="tabPanel1" TabIndex="0" HeaderText="Account Management" Visible="false">
            <ContentTemplate>
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>User ID:</td>
                        <td><asp:TextBox runat="server" ID="txtUserID" Width="200" /><ajaxToolkit:AutoCompleteExtender runat="server" ID="aceUserID" CompletionInterval="1000" ServiceMethod="GetUserID" TargetControlID="txtUserID" MinimumPrefixLength="2" /></td>
                        <td><asp:Button runat="server" ID="btnAddUser" Text="Add" OnClick="btnAddUser_Click" /></td>
                    </tr>
                </table>
                <br />
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
				                <ContentTemplate>
                                    <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowSorting="true" Width="800" DataSourceID="SqlDataSource1" OnRowDataBoundDataRow="gv1_RowDataBoundDataRow">
                                        <Columns>
                                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                <headertemplate>
                                                    No.
                                                </headertemplate>
                                                <itemtemplate>
                                                    <%# Container.DataItemIndex + 1 %>
                                                </itemtemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="User ID" DataField="userid" SortExpression="userid" ReadOnly="true" />
                                            <asp:BoundField HeaderText="RBU" DataField="rbu" />
                                            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <asp:Button runat="server" ID="btnDeleteUser" Text="Delete" OnClick="btnDeleteUser_Click" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <asp:Button runat="server" ID="btnEditUser" Text="Edit" OnClick="btnEditUser_Click" />
                                                    <%--<input name="Edit" style="cursor:hand" value="Edit" type="button" onclick="PickRBU('<%#Eval("userid") %>','<%#Eval("RBU") %>');" id="btnEditUser" />--%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </sgv:SmartGridView>
                                    <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:My %>"
                                         SelectCommand="select userid, rbu from MYADVANTECH_ACCOUNT_ADMIN_USERS order by userid">
                                    </asp:SqlDataSource>
                                    <asp:LinkButton runat="server" ID="link1" />
                                    <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1" PopupControlID="Panel1" 
                                        PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground">
                                    </ajaxToolkit:ModalPopupExtender>
                                    <asp:Panel runat="server" ID="Panel1">
                                        <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <table border="0" cellpadding="0" cellspacing="0" width="500" bgcolor="f1f2f4" style="height:400px">
                                                    <tr><td height="5">&nbsp</td></tr>
                                                    <tr>
                                                        <td valign="top">&nbsp;User ID : <asp:Label runat="server" ID="lblUserID" Text="" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td valign="top">
                                                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                                <tr>
                                                                    <td width="100">&nbsp;Add New RBU : </td>
                                                                    <td>
                                                                        <asp:LinkButton runat="server" ID="btnSelectRBU" Text="[ Select RBU ]" OnClick="btnSelectRBU_Click" />
                                                                        <asp:UpdatePanel runat="server" ID="up3">
                                                                            <ContentTemplate>
                                                                                <asp:Panel runat="server" ID="Panel2" Visible="true">
                                                                                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                                                                                        <tr>
                                                                                            <td><asp:CheckBox runat="server" ID="cbSelectAll" Text="All" AutoPostBack="true" OnCheckedChanged="cbSelectAll_CheckedChanged" /></td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td><asp:CheckBoxList runat="server" ID="cblRBU" RepeatColumns="4" DataSourceID="SqlDataSource2" AutoPostBack="true" DataTextField="text" DataValueField="value" OnSelectedIndexChanged="cblRBU_SelectedIndexChanged" OnInit="cblRBU_Init">
                                                                                                </asp:CheckBoxList>
                                                                                                <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString="<%$ connectionStrings: RFM %>"
                                                                                                     SelectCommand="select * from siebel_account_rbu_lov">
                                                                                                </asp:SqlDataSource>
                                                                                            </td>
                                                                                            <td><asp:Button runat="server" ID="btnAddRBU" Text="Add" OnClick="btnAddRBU_Click" /></td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </asp:Panel>
                                                                            </ContentTemplate>
                                                                            <Triggers>
                                                                                <asp:AsyncPostBackTrigger ControlID="btnSelectRBU" EventName="Click" />
                                                                            </Triggers>
                                                                        </asp:UpdatePanel>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr><td height="10">&nbsp</td></tr>
                                                    <tr><td><asp:Button runat="server" ID="btnDeleteRBU" Text="Delete" OnClick="btnDeleteRBU_Click" Visible="false" /></td></tr>
                                                    <tr>
                                                        <td valign="top">
                                                            <sgv:SmartGridView runat="server" ID="gvRBU" Width="100%" AutoGenerateColumns="false">
                                                                <Columns>
                                                                    <asp:BoundField HeaderText="No." DataField="No." ItemStyle-HorizontalAlign="Center" />
                                                                    <asp:TemplateField ItemStyle-HorizontalAlign="Center" Visible="false">
                                                                        <HeaderTemplate>
                                                                            <asp:CheckBox runat="server" ID="chkAll" />
                                                                        </HeaderTemplate>
                                                                        <ItemTemplate>
                                                                            <asp:CheckBox runat="server" ID="chkItem" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField HeaderText="RBU" DataField="RBU" ItemStyle-HorizontalAlign="Center" />
                                                                </Columns>
                                                                <FixRowColumn FixRowType="Header" FixColumns="-1" FixRows="-1" TableHeight="150px" />
                                                                <CascadeCheckboxes>
                                                                    <sgv:CascadeCheckbox ParentCheckboxID="chkAll" ChildCheckboxID="chkItem" />
                                                                </CascadeCheckboxes>
                                                            </sgv:SmartGridView>
                                                        </td>
                                                    </tr>
		                                            <tr>
			                                            <td width="100%" valign="top" align="center">
			                                                <asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" />
				                                        </td>
		                                            </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </asp:Panel>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabPanel2" TabIndex="1" HeaderText="Customer Management">
            <ContentTemplate>
                <table border="0" width="100%" style="height:400px">
                    <tr>
                        <td width="45%" valign="top" align="center"><b>Account Owner</b><br />
                            <table border="1" width="100%">
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="up4">
                                            <ContentTemplate>
                                                UserID : <asp:TextBox runat="server" ID="txtSearchOwner" /><asp:Button runat="server" ID="btnSearchOwner" Text="Search" OnClick="btnSearchOwner_Click" /><br />
                                                <sgv:SmartGridView runat="server" ID="gv2" AutoGenerateColumns="false" Width="100%" DataSourceID="SqlDataSource3">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                            <headertemplate>
                                                                No.
                                                            </headertemplate>
                                                            <itemtemplate>
                                                                <%# Container.DataItemIndex + 1 %>
                                                            </itemtemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                                            <HeaderTemplate>
                                                                <asp:CheckBox runat="server" ID="chkOwnerAll" />
                                                            </HeaderTemplate>
                                                            <ItemTemplate>
                                                                <asp:CheckBox runat="server" ID="chkOwnerItem" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="userid" HeaderText="User ID" />
                                                    </Columns>
                                                    <FixRowColumn FixRowType="Header" FixColumns="-1" FixRows="-1" TableWidth="100%" TableHeight="380px" />
                                                    <CascadeCheckboxes>
                                                        <sgv:CascadeCheckbox ParentCheckboxID="chkOwnerAll" ChildCheckboxID="chkOwnerItem" />
                                                    </CascadeCheckboxes>
                                                </sgv:SmartGridView>
                                                <asp:SqlDataSource runat="server" ID="SqlDataSource3" ConnectionString="<%$ connectionStrings:My %>"
                                                     SelectCommand="" OnLoad="SqlDataSource3_Load">
                                                </asp:SqlDataSource>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        <td width="10%">
                            <asp:Button runat="server" ID="btnDeleteOwner" Text="Remove Account Owner >>" Width="200" OnClick="btnDeleteOwner_Click" /><br /><br />
                            <asp:Button runat="server" ID="btnAddOwner" Text="<< Add Account Owner" Width="200" OnClick="btnAddOwner_Click" />
                        </td>
                        <td width="45%" valign="top" align="center"><b>Not Account Owner</b><br />
                            <table border="1" width="100%">
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="up5">
                                            <ContentTemplate>
                                                UserID : <asp:TextBox runat="server" ID="txtSearchNotOwner" /><asp:Button runat="server" ID="btnSearchNotOwner" Text="Search" OnClick="btnSearchNotOwner_Click" /><br />
                                                <sgv:SmartGridView runat="server" ID="gv3" AutoGenerateColumns="false" Width="100%" DataSourceID="SqlDataSource4">
                                                    <Columns>
                                                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                            <headertemplate>
                                                                No.
                                                            </headertemplate>
                                                            <itemtemplate>
                                                                <%# Container.DataItemIndex + 1 %>
                                                            </itemtemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                                            <HeaderTemplate>
                                                                <asp:CheckBox runat="server" ID="chkNotOwnerAll" />
                                                            </HeaderTemplate>
                                                            <ItemTemplate>
                                                                <asp:CheckBox runat="server" ID="chkNotOwnerItem" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField DataField="userid" HeaderText="User ID" />
                                                    </Columns>
                                                    <CascadeCheckboxes>
                                                        <sgv:CascadeCheckbox ParentCheckboxID="chkNotOwnerAll" ChildCheckboxID="chkNotOwnerItem" />
                                                    </CascadeCheckboxes>
                                                    <FixRowColumn FixRowType="Header" FixColumns="-1" FixRows="-1" TableHeight="380px" />
                                                </sgv:SmartGridView>
                                                <asp:SqlDataSource runat="server" ID="SqlDataSource4" ConnectionString="<%$ connectionStrings:My %>"
                                                     SelectCommand="" OnLoad="SqlDataSource4_Load">
                                                </asp:SqlDataSource>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
    </ajaxToolkit:TabContainer>
    
<script type="text/javascript">
function PickRBU(userid,rbu){
    var Url;
    //alert("test");
    //alert(document.getElementsByName("company_id").value);
    Url="/Includes/Account_Admin.aspx?userid="+userid+"&rbu="+rbu;
    window.open(Url, "pop","height=550,width=520,scrollbars=yes");
}
</script>
</asp:Content>

