<%@ Page Title="MyAdvantech - B2B Company Contact Administration" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Not AuthUtil.IsTW01PIMailContactAdmin() Then Response.Redirect(Request.ApplicationPath)
            'ddlAddOrgID.DataSource = OrgList
            'ddlAddOrgID.DataTextField = "ORG_ID"
            'ddlAddOrgID.DataValueField = "ORG_ID"
            'ddlAddOrgID.DataBind()
            'ddlAddOrgID.SelectedValue = "TW01"
        End If
    End Sub

    'Protected ReadOnly Property OrgList As DataTable
    '    Get
    '        Dim dt As DataTable = Cache("B2BOrg")
    '        If dt Is Nothing Then
    '            dt = dbUtil.dbGetDataTable("MY", " SELECT DISTINCT ORG_ID FROM B2B_COMPANY_CONTACT ")
    '            Cache.Add("B2BOrg", dt, Nothing, Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
    '        End If
    '        Return dt
    '    End Get
    'End Property
    
    'Protected ReadOnly Property B2Bmembers As List(Of String)
    '    Get
    '        Return New List(Of String)(New String() {"polar.yu@advantech.com.tw", "emily.chen@advantech.com.tw", "maggie.yu@advantech.com.tw", "amy.yen@advantech.com.tw.", "beca.wu@advantech.com.tw", "sandy.lin@advantech.com.tw", "fanny.tseng@advantech.com.tw", "elisa.huang@advantech.com.tw"})
    '    End Get
    'End Property

    Protected Sub InitialB2BwithViewState()
        If Not ViewState("b2bData") Is Nothing Then
            gvB2BCompanyContacts.DataSource = dbUtil.dbGetDataTable("MY", ViewState("b2bData"))
            gvB2BCompanyContacts.DataBind()
        Else
            InitialB2BCompanyContacts(txtSearchUserID.Text.Trim, txtSearchCompanyID.Text.Trim)
        End If
    End Sub
    
    Protected Sub InitialB2BCompanyContacts(ByVal UserId As String, ByVal CompanyId As String)
        Dim sb As New StringBuilder()
        sb.Append(" SELECT USERID, COMPANY_ID, ORG_ID, FIRST_NAME, LAST_NAME FROM B2B_COMPANY_CONTACT WHERE 1 = 1 ")
        If Not String.IsNullOrEmpty(UserId) Then sb.Append(String.Format(" AND USERID = '{0}' ", UserId))
        If Not String.IsNullOrEmpty(CompanyId) Then sb.Append(String.Format(" AND COMPANY_ID = '{0}' ", CompanyId))
        gvB2BCompanyContacts.DataSource = dbUtil.dbGetDataTable("MY", sb.ToString)
        gvB2BCompanyContacts.DataBind()
        ViewState("b2bData") = sb.ToString
    End Sub

    Protected Sub GetFirstAndLastName(ByVal UserId As String, ByRef FirstName As String, ByRef LastName As String)
        Dim dtEmploy As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" SELECT FIRST_NAME, LAST_NAME FROM SAP_EMPLOYEE WHERE EMAIL = '{0}' ", UserId))
        If dtEmploy.Rows.Count > 0 Then
            FirstName = dtEmploy.Rows(0).Item(0).ToString
            LastName = dtEmploy.Rows(0).Item(1).ToString
        Else
            dtEmploy.Clear()
            dtEmploy = dbUtil.dbGetDataTable("MY", String.Format(" SELECT FirstName, LastName FROM SIEBEL_CONTACT WHERE EMAIL_ADDRESS = '{0}' ", UserId))
            If dtEmploy.Rows.Count > 0 Then
                FirstName = dtEmploy.Rows(0).Item(0).ToString
                LastName = dtEmploy.Rows(0).Item(1).ToString
            Else
                dtEmploy.Clear()
                dtEmploy = dbUtil.dbGetDataTable("MY", String.Format(" SELECT FST_NAME, LST_NAME FROM EZ_EMPLOYEE WHERE EMAIL_ADDR = '{0}' ", UserId))
                If dtEmploy.Rows.Count > 0 Then
                    FirstName = dtEmploy.Rows(0).Item(0).ToString
                    LastName = dtEmploy.Rows(0).Item(1).ToString
                End If
            End If
        End If
    End Sub
    
    Protected Function CheckInputDataIsValid(ByVal UserId As String, ByVal CompanyId As String, ByVal OrgId As String) As Boolean
        If String.IsNullOrEmpty(UserId) OrElse String.IsNullOrEmpty(CompanyId) Then
            lbAddMsg.Text = "Please enter user email and company id"
            Return True
        End If
        If Not Util.IsValidEmailFormat(UserId) Then
            lbAddMsg.Text = "This email is not valid"
            Return True
        End If
        If SAPDAL.SAPDAL.GetCompanyDataFromLocal(CompanyId, OrgId).Rows.Count = 0 Then
            lbAddMsg.Text = "This company id and org id are not valid in SAP"
            Return True
        End If
        Return False
    End Function
    
    Protected Sub btnSearchContact_Click(sender As Object, e As System.EventArgs)
        If String.IsNullOrEmpty(txtSearchUserID.Text) AndAlso String.IsNullOrEmpty(txtSearchCompanyID.Text) Then Return
        InitialB2BCompanyContacts(txtSearchUserID.Text.Trim, txtSearchCompanyID.Text.Trim)
    End Sub
    
    Protected Sub btnAddContact_Click(sender As Object, e As System.EventArgs)
        If CheckInputDataIsValid(txtAddUserID.Text.Trim, txtAddComID.Text.Trim, "TW01") Then Return 'ddlAddOrgID.SelectedItem.Value
        Dim checksql As String = String.Format("select USERID  from  B2B_COMPANY_CONTACT  WHERE COMPANY_ID='{0}' and USERID ='{1}' and ORG_ID ='{2}'", txtAddComID.Text.Trim, txtAddUserID.Text.Trim, "TW01")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", checksql)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            lbAddMsg.Text = String.Format("{0} already exists on {1}", txtAddUserID.Text.Trim, txtAddComID.Text.Trim)
            Exit Sub
        End If
        Dim firstName As String = String.Empty
        Dim lastName As String = String.Empty
        GetFirstAndLastName(txtAddUserID.Text.Trim, firstName, lastName)
        
        Dim strSql As String = " INSERT INTO B2B_COMPANY_CONTACT VALUES (@UserId, @ComId, @OrgId, @First, @Last, GETDATE()) "
        Dim userId As New SqlClient.SqlParameter("UserId", SqlDbType.VarChar, 100) : userId.Value = txtAddUserID.Text.Trim
        Dim comId As New SqlClient.SqlParameter("ComId", SqlDbType.VarChar, 15) : comId.Value = txtAddComID.Text.Trim.ToUpper()
        Dim orgId As New SqlClient.SqlParameter("OrgId", SqlDbType.VarChar, 15) : orgId.Value = "TW01" ' ddlAddOrgID.SelectedItem.Value.ToUpper()
        Dim first As New SqlClient.SqlParameter("First", SqlDbType.NVarChar, 50) : first.Value = firstName
        Dim last As New SqlClient.SqlParameter("Last", SqlDbType.NVarChar, 50) : last.Value = lastName
        Dim para() As SqlClient.SqlParameter = {userId, comId, orgId, first, last}
        Try
            dbUtil.dbExecuteNoQuery2("MY", strSql, para)
            lbAddMsg.Text = "Success"
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString())
            lbAddMsg.Text = "Failed"
        End Try
        InitialB2BCompanyContacts("", txtAddComID.Text.Trim.ToUpper())
    End Sub
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetEZ(ByVal prefixText As String, ByVal count As Integer) As String()
        Return AuthUtil.GetEZ(prefixText)
    End Function

    Protected Sub gvB2BCompanyContacts_RowEditing(sender As Object, e As System.Web.UI.WebControls.GridViewEditEventArgs)
        gvB2BCompanyContacts.EditIndex = e.NewEditIndex
        InitialB2BwithViewState()
        lbAddMsg.Text = String.Empty
    End Sub

    Protected Sub gvB2BCompanyContacts_RowCancelingEdit(sender As Object, e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        gvB2BCompanyContacts.EditIndex = -1
        InitialB2BwithViewState()
        lbAddMsg.Text = String.Empty
    End Sub

    Protected Sub gvB2BCompanyContacts_RowUpdating(sender As Object, e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        Dim txtUser As String = CType(gvB2BCompanyContacts.Rows(e.RowIndex).Cells(0).FindControl("txtUserID"), TextBox).Text.Trim
        Dim txtCompany As String = CType(gvB2BCompanyContacts.Rows(e.RowIndex).Cells(1).FindControl("txtCompanyID"), TextBox).Text.Trim
        Dim ddlOrg As String ="TW01"' CType(gvB2BCompanyContacts.Rows(e.RowIndex).Cells(2).FindControl("ddlOrgID"), DropDownList).SelectedItem.Value
        If CheckInputDataIsValid(txtUser, txtCompany, ddlOrg) Then Return
                
        Dim firstName As String = String.Empty
        Dim lastName As String = String.Empty
        GetFirstAndLastName(txtUser, firstName, lastName)
        
        Dim sb As New StringBuilder()
        Dim hUserID As String = CType(gvB2BCompanyContacts.Rows(e.RowIndex).Cells(0).FindControl("hUSERID"), HiddenField).Value
        Dim hComID As String = CType(gvB2BCompanyContacts.Rows(e.RowIndex).Cells(1).FindControl("hCOMPANY_ID"), HiddenField).Value
        sb.Append(String.Format(" UPDATE B2B_COMPANY_CONTACT SET USERID = '{0}', COMPANY_ID = '{1}', ORG_ID = '{2}', ", txtUser, txtCompany, ddlOrg))
        sb.Append(String.Format(" FIRST_NAME = '{0}', LAST_NAME = '{1}' WHERE USERID = '{2}' AND COMPANY_ID = '{3}' ", firstName, lastName, hUserID, hComID))
        Try
            dbUtil.dbExecuteNoQuery("MY", sb.ToString)
            lbAddMsg.Text = String.Empty
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString())
        End Try
        gvB2BCompanyContacts.EditIndex = -1
        'InitialB2BCompanyContacts(txtUser, txtCompany)
        InitialB2BCompanyContacts("", txtCompany)

        'Try
        '    Dim strSql As String = String.Empty
        '    Dim pSessionID As New SqlClient.SqlParameter("SESSION", SqlDbType.VarChar) : pSessionID.Value = HttpContext.Current.Session.SessionID
        '    Dim pTransID As New SqlClient.SqlParameter("TRANS", SqlDbType.VarChar) : pTransID.Value = ""
        '    Dim pUserID As New SqlClient.SqlParameter("USERID", SqlDbType.VarChar) : pUserID.Value = HttpContext.Current.User.Identity.Name
        '    Dim pUrl As New SqlClient.SqlParameter("URL", SqlDbType.VarChar) : pUrl.Value = Context.Request.ServerVariables("SCRIPT_NAME").ToLower()
        '    Dim pQuery As New SqlClient.SqlParameter("QUERY", SqlDbType.VarChar) : pQuery.Value = "UPDATE B2B_COMPANY_CONTACT"
        '    Dim pNote As New SqlClient.SqlParameter("NOTE", SqlDbType.VarChar) : pNote.Value = String.Format("{0} has updated user id from {1} to {2}, and company id from {3} to {4}", HttpContext.Current.User.Identity.Name, hUserID, txtUser, hComID, txtCompany)
        '    Dim pMethod As New SqlClient.SqlParameter("METHOD", SqlDbType.VarChar) : pMethod.Value = Request.ServerVariables("REQUEST_METHOD")
        '    Dim pServerPort As New SqlClient.SqlParameter("SERVERPORT", SqlDbType.VarChar) : pServerPort.Value = Request.ServerVariables("SERVER_NAME") + ":" + Request.ServerVariables("SERVER_PORT")
        '    Dim pClientName As New SqlClient.SqlParameter("CLIENT", SqlDbType.VarChar) : pClientName.Value = Util.GetClientIP()
        '    Dim pAppID As New SqlClient.SqlParameter("APPID", SqlDbType.VarChar) : pAppID.Value = "MY"
        '    Dim sReferrer As String = String.Empty
        '    If Request.ServerVariables("HTTP_REFERER") IsNot Nothing Then sReferrer = Request.ServerVariables("HTTP_REFERER")
        '    Dim pReferrer As New SqlClient.SqlParameter("REFERRER", SqlDbType.VarChar) : pReferrer.Value = sReferrer
        '    strSql = "INSERT INTO USER_LOG VALUES(@SESSION,@TRANS,@USERID,GetDate(),@URL,@QUERY,@NOTE,@METHOD,@SERVERPORT,@CLIENT,@APPID,'N',@REFERRER)"
        '    Dim para() As SqlClient.SqlParameter = {pSessionID, pTransID, pUserID, pUrl, pQuery, pNote, pMethod, pServerPort, pClientName, pAppID, pReferrer}
        '    dbUtil.dbExecuteNoQuery2("B2B", strSql, para)
        'Catch ex As Exception
        '    Util.InsertMyErrLog(ex.ToString())
        'End Try
        InsertLog("UPDATE B2B_COMPANY_CONTACT", String.Format("{0} has updated user id from {1} to {2}, and company id from {3} to {4}", HttpContext.Current.User.Identity.Name, hUserID, txtUser, hComID, txtCompany))
    End Sub
    Private Sub InsertLog(ByVal QUERY As String, ByVal NOTE As String)
        Try
            Dim strSql As String = String.Empty
            Dim pSessionID As New SqlClient.SqlParameter("SESSION", SqlDbType.VarChar) : pSessionID.Value = HttpContext.Current.Session.SessionID
            Dim pTransID As New SqlClient.SqlParameter("TRANS", SqlDbType.VarChar) : pTransID.Value = ""
            Dim pUserID As New SqlClient.SqlParameter("USERID", SqlDbType.VarChar) : pUserID.Value = HttpContext.Current.User.Identity.Name
            Dim pUrl As New SqlClient.SqlParameter("URL", SqlDbType.VarChar) : pUrl.Value = Context.Request.ServerVariables("SCRIPT_NAME").ToLower()
            Dim pQuery As New SqlClient.SqlParameter("QUERY", SqlDbType.VarChar) : pQuery.Value = QUERY
            Dim pNote As New SqlClient.SqlParameter("NOTE", SqlDbType.VarChar) : pNote.Value = NOTE
            Dim pMethod As New SqlClient.SqlParameter("METHOD", SqlDbType.VarChar) : pMethod.Value = Request.ServerVariables("REQUEST_METHOD")
            Dim pServerPort As New SqlClient.SqlParameter("SERVERPORT", SqlDbType.VarChar) : pServerPort.Value = Request.ServerVariables("SERVER_NAME") + ":" + Request.ServerVariables("SERVER_PORT")
            Dim pClientName As New SqlClient.SqlParameter("CLIENT", SqlDbType.VarChar) : pClientName.Value = Util.GetClientIP()
            Dim pAppID As New SqlClient.SqlParameter("APPID", SqlDbType.VarChar) : pAppID.Value = "MY"
            Dim sReferrer As String = String.Empty
            If Request.ServerVariables("HTTP_REFERER") IsNot Nothing Then sReferrer = Request.ServerVariables("HTTP_REFERER")
            Dim pReferrer As New SqlClient.SqlParameter("REFERRER", SqlDbType.VarChar) : pReferrer.Value = sReferrer
            strSql = "INSERT INTO USER_LOG VALUES(@SESSION,@TRANS,@USERID,GetDate(),@URL,@QUERY,@NOTE,@METHOD,@SERVERPORT,@CLIENT,@APPID,'N',@REFERRER)"
            Dim para() As SqlClient.SqlParameter = {pSessionID, pTransID, pUserID, pUrl, pQuery, pNote, pMethod, pServerPort, pClientName, pAppID, pReferrer}
            dbUtil.dbExecuteNoQuery2("B2B", strSql, para)
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString())
        End Try
    End Sub
    Protected Sub gvB2BCompanyContacts_RowDeleting(sender As Object, e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim hUserID As String = CType(gvB2BCompanyContacts.Rows(e.RowIndex).Cells(0).FindControl("hUSERID"), HiddenField).Value
        Dim hComID As String = CType(gvB2BCompanyContacts.Rows(e.RowIndex).Cells(1).FindControl("hCOMPANY_ID"), HiddenField).Value
        Dim sb As New StringBuilder()
        sb.Append(String.Format(" DELETE FROM B2B_COMPANY_CONTACT WHERE USERID = '{0}' AND COMPANY_ID = '{1}' ", hUserID, hComID))
        Try
            dbUtil.dbExecuteNoQuery("MY", sb.ToString)
            lbAddMsg.Text = String.Empty
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString())
        End Try
        InsertLog("DELETE B2B_COMPANY_CONTACT", String.Format("{0} has deleted user id({1}) from {2}", HttpContext.Current.User.Identity.Name, hUserID, hComID))
        InitialB2BwithViewState()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:UpdatePanel ID="up1" runat="server">
        <ContentTemplate>
            <table width="100%">
                <tr>
                    <td valign="top">
                        <table width="100%">
                            <tr>
                                <th align="left" colspan="2">Search user id or company id:
                                </th>
                            </tr>
                            <tr>
                                <th align="left">User Id:
                                </th>
                                <td>
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext1" TargetControlID="txtSearchUserID"
                                        CompletionInterval="100" MinimumPrefixLength="1" ServiceMethod="GetEZ" />
                                    <asp:TextBox runat="server" ID="txtSearchUserID" Width="250px" AutoCompleteType="Disabled" />
                                </td>
                            </tr>
                            <tr>
                                <th align="left">Company Id:
                                </th>
                                <td>
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext2" TargetControlID="txtSearchCompanyID"
                                        CompletionInterval="100" MinimumPrefixLength="1" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetERPId" />
                                    <asp:TextBox runat="server" ID="txtSearchCompanyID" Width="210px" AutoCompleteType="Disabled" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:Button runat="server" ID="btnSearchContact" Text="Search" OnClick="btnSearchContact_Click" />
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <table width="100%">
                            <tr>
                                <th align="left" colspan="2">Add a New Contact:
                                </th>
                            </tr>
                            <tr>
                                <th align="left">User Id:
                                </th>
                                <td>
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext3" TargetControlID="txtAddUserID"
                                        CompletionInterval="100" MinimumPrefixLength="1" ServiceMethod="GetEZ" />
                                    <asp:TextBox runat="server" ID="txtAddUserID" Width="250px" AutoCompleteType="Disabled" />
                                </td>
                            </tr>
                            <tr>
                                <th align="left">Company Id:
                                </th>
                                <td>
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext4" TargetControlID="txtAddComID"
                                        CompletionInterval="100" MinimumPrefixLength="1" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetERPId" />
                                    <asp:TextBox runat="server" ID="txtAddComID" Width="210px" AutoCompleteType="Disabled" />
                                </td>
                            </tr>
                            <tr style="display:none;">
                                <th align="left">Org Id:
                                </th>
                                <td>
                                    <asp:DropDownList runat="server" ID="ddlAddOrgID">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:Button runat="server" ID="btnAddContact" Text="Add"
                                        OnClick="btnAddContact_Click" />
                                </td>
                            </tr>
                            <tr style="height: 20px">
                                <td colspan="2">
                                    <asp:Label runat="server" ID="lbAddMsg" Font-Bold="true" ForeColor="Tomato" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:GridView runat="server" ID="gvB2BCompanyContacts" Width="100%" AutoGenerateColumns="false"
                            OnRowEditing="gvB2BCompanyContacts_RowEditing"
                            OnRowCancelingEdit="gvB2BCompanyContacts_RowCancelingEdit"
                            OnRowUpdating="gvB2BCompanyContacts_RowUpdating"
                            OnRowDeleting="gvB2BCompanyContacts_RowDeleting">
                            <Columns>
                                <asp:TemplateField HeaderText="User_Id" ItemStyle-Width="300px">
                                    <ItemTemplate>
                                        <%# Eval("USERID")%>
                                        <asp:HiddenField ID="hUSERID" runat="server" Value='<%#Eval("USERID")%>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext5" TargetControlID="txtUserID"
                                            CompletionInterval="100" MinimumPrefixLength="1" ServiceMethod="GetEZ" />
                                        <asp:TextBox ID="txtUserID" runat="server" AutoCompleteType="Disabled" MaxLength="250" Width="250" Text='<%# Bind("USERID") %>'></asp:TextBox>
                                        <asp:HiddenField ID="hUSERID" runat="server" Value='<%#Eval("USERID")%>' />
                                    </EditItemTemplate>
                                    <ItemStyle Width="300px" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Company_Id" HeaderStyle-Width="160px" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <%# Eval("COMPANY_ID")%>
                                        <asp:HiddenField ID="hCOMPANY_ID" runat="server" Value='<%#Eval("COMPANY_ID")%>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext6" TargetControlID="txtCompanyID"
                                            CompletionInterval="100" MinimumPrefixLength="1" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetERPId" />
                                        <asp:TextBox ID="txtCompanyID" runat="server" AutoCompleteType="Disabled" MaxLength="100" Width="160" Text='<%# Bind("COMPANY_ID") %>'></asp:TextBox>
                                        <asp:HiddenField ID="hCOMPANY_ID" runat="server" Value='<%#Eval("COMPANY_ID")%>' />
                                    </EditItemTemplate>
                                    <ItemStyle Width="160px" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="ORG_ID" HeaderStyle-Width="80px" ItemStyle-HorizontalAlign="Center"  Visible="false">
                                    <ItemTemplate>
                                        <%# Eval("ORG_ID")%>
                                    </ItemTemplate>
                                    <EditItemTemplate>
<%--                                        <asp:DropDownList runat="server" ID="ddlOrgID" DataSource="<%# Me.OrgList %>" DataTextField="ORG_ID" DataValueField="ORG_ID" SelectedValue='<%# Eval("ORG_ID")%>'></asp:DropDownList>--%>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="FIRST_NAME" HeaderStyle-Width="100px">
                                    <ItemTemplate>
                                        <%# Eval("FIRST_NAME")%>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <%# Eval("FIRST_NAME")%>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="LAST_NAME" HeaderStyle-Width="100px">
                                    <ItemTemplate>
                                        <%# Eval("LAST_NAME")%>
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <%# Eval("LAST_NAME")%>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:CommandField ShowEditButton="true" ItemStyle-HorizontalAlign="Center" />
                                <asp:TemplateField ShowHeader="False" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnDelete" runat="server" Text="Delete" CausesValidation="False" CommandName="Delete" OnClientClick="return confirm('Are you sure to delete this record?')"></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

