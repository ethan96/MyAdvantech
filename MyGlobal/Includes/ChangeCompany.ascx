<%@ Control Language="VB" ClassName="ChangeCompany" %>
<script runat="server">
    Public Event ChangeCompleted()
    Public Property ChangeToERPIDNow() As String
        Get
            Return TargetCompanyId
        End Get
        Set(ByVal value As String)
            TargetCompanyId = value : btnChangeCompany_Click(Me.btnChangeCompany, New EventArgs) : RaiseEvent ChangeCompleted()
        End Set
    End Property

    Public Property TargetCompanyId() As String
        Get
            Return Me.txtCh2Company.Text
        End Get
        Set(ByVal value As String)
            Me.txtCh2Company.Text = value
        End Set
    End Property

    Public Function ChangeToCompanyId() As Boolean
        Dim tmpERPID As String = Me.txtCh2Company.Text, au As New AuthUtil, chgFlag As Boolean = False
        'Return au.ChangeCompanyId(Me.txtCh2Company.Text)
        If tmpERPID.Equals("UUAAESC", StringComparison.OrdinalIgnoreCase) OrElse
               CInt(dbUtil.dbExecuteScalar("MY",
                   "select COUNT(company_id) as c from SAP_DIMCOMPANY where COMPANY_ID='" + Replace(tmpERPID, "'", "''") + "' and ORG_ID in ('EU10','TW01') ")) >= 2 Then
            Dim MultiOrgDt As DataTable = dbUtil.dbGetDataTable("MY", "select top 1 company_id, org_id from sap_company_org where company_id='" + tmpERPID + "' and IS_DEFAULT=1")
            If MultiOrgDt.Rows.Count = 0 Then
                'chgFlag = au.ChangeCompanyId(tmpERPID, "EU10")
                'Ming add 20140313 因台湾或美国也可能出现以上2笔数据，所以不能写死org为EU10
                chgFlag = au.ChangeCompanyId(tmpERPID)
            Else
                chgFlag = au.ChangeCompanyId(tmpERPID, MultiOrgDt.Rows(0).Item("org_id"))
            End If
        ElseIf CInt(dbUtil.dbExecuteScalar("MY", "select COUNT(company_id) as c from SAP_DIMCOMPANY where COMPANY_ID='" + Replace(tmpERPID, "'", "''") + "' and ORG_ID in ('CN10','CN30','CN70') ")) >= 2 Then

            'Ryan 20180629 New function in SAPDAL.cs to set ACN multi org.
            Advantech.Myadvantech.DataAccess.SAPDAL.SetACNMultiOrg(tmpERPID)
            chgFlag = au.ChangeCompanyId(tmpERPID)

            'Ryan 20170523 Temporary added for automatically adding multi orgs to SAP_COMPANY_ORG table if needed
            'Dim MultiOrgDt As DataTable = dbUtil.dbGetDataTable("MY", "select * from sap_company_org where company_id='" + tmpERPID + "'")
            'If MultiOrgDt.Rows.Count = 0 Then
            '    dbUtil.dbExecuteNoQuery("MY", String.Format("insert into SAP_COMPANY_ORG values ('{0}','CN10','CN10','1')", tmpERPID))
            '    dbUtil.dbExecuteNoQuery("MY", String.Format("insert into SAP_COMPANY_ORG values ('{0}','CN30','CN30','0')", tmpERPID))
            '    chgFlag = au.ChangeCompanyId(tmpERPID)
            'Else
            '    chgFlag = au.ChangeCompanyId(tmpERPID)
            'End If

            'Ryan 20180226 - Comment below out for ADLOG, all ERPIDs are able to be changed for them now.
            'ElseIf HttpContext.Current.Session("user_id") IsNot Nothing AndAlso HttpContext.Current.Session("user_id").ToString.ToUpper.Contains("@ADVANTECH-DLOG.COM") Then
            '    Dim strSQL As String = String.Format(
            '    " select company_id, org_id, CURRENCY, company_name, PRICE_CLASS, SALESOFFICE from sap_dimcompany " +
            '    " where org_id not in " + ConfigurationManager.AppSettings("InvalidOrg") + " " +
            '    " and company_id = '{0}' and company_type in ('partner','Z001')", Trim(tmpERPID))
            '    Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSQL)

            '    If dt IsNot Nothing AndAlso dt.Select("org_id = 'EU80'").Count > 0 Then
            '        chgFlag = au.ChangeCompanyId(tmpERPID, "EU80")
            '    Else
            '        chgFlag = au.ChangeCompanyId(Session("COMPANY_ID").ToString)
            '    End If
        Else
            chgFlag = au.ChangeCompanyId(tmpERPID)
        End If
        Return chgFlag
    End Function

    Function GetSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 200 b.row_id, a.company_id, a.company_name, b.account_name, a.ORG_ID, b.RBU, a.SALESOFFICENAME, a.SALESGROUP, b.account_status  "))
            .AppendLine(String.Format(" ,a.[ADDRESS],a.ZIP_CODE,a.CITY  "))
            .AppendLine(String.Format(" from sap_dimcompany a left join SIEBEL_ACCOUNT b on a.COMPANY_ID=b.ERP_ID  "))
            .AppendLine(String.Format(" where a.DELETION_FLAG<>'X' and a.company_type ='Z001' "))
            If txtCompanyID.Text.Trim() <> "" Then .AppendLine(String.Format(" and a.COMPANY_ID like '{0}%' ", txtCompanyID.Text.Trim().Replace("'", "").Replace("*", "%")))
            If txtCompanyName.Text.Trim() <> "" Then .AppendLine(String.Format(" and (a.COMPANY_NAME like N'%{0}%' or b.account_name like N'%{0}%') ", txtCompanyName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            If ddlCountry.SelectedIndex > 0 Then .AppendLine(String.Format(" and a.COUNTRY = '{0}' ", ddlCountry.SelectedValue))
            If txtCity.Text.Trim() <> "" Then .AppendLine(String.Format(" and a.city like '%{0}%' ", txtCity.Text.Trim().Replace("'", "''").Replace("*", "%")))
            If dlOrg.SelectedIndex > 0 Then .AppendLine(String.Format(" and a.ORG_ID = '{0}' ", dlOrg.SelectedValue))
            If txtRBU.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and b.RBU='{0}' ", txtRBU.Text.Trim().Replace("'", "")))
            End If
            .AppendLine(" order by a.company_name ")
        End With

        Return sb.ToString()
    End Function

    Public Sub btnChangeCompany_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim AlertMsg As New Literal
        If String.IsNullOrEmpty(txtCh2Company.Text) Then Exit Sub

        'Ryan 20180104 Return if user is not BBUS purchaser and attempts to change to ADVBBUS
        If txtCh2Company.Text.Equals("ADVBBUS", StringComparison.OrdinalIgnoreCase) AndAlso Not AuthUtil.IsBBUSPurchaser Then
            AlertMsg.Text = "<script language='javascript'>alert('This account\'s ERPID """ + txtCh2Company.Text + """ is not allowed to change.');<" & "/" & "script>"
            Me.Page.Controls.Add(AlertMsg)
            Exit Sub
        End If

        If txtCh2Company.Text.Equals("ADVAVN", StringComparison.OrdinalIgnoreCase) AndAlso Not AuthUtil.IsAVNMgt Then
            AlertMsg.Text = "<script language='javascript'>alert('This account\'s ERPID """ + txtCh2Company.Text + """ is not allowed to change.');<" & "/" & "script>"
            Me.Page.Controls.Add(AlertMsg)
            Exit Sub
        End If

        'Ryan 20180703 Check account block status for TW20
        If CInt(dbUtil.dbExecuteScalar("MY", "select COUNT(company_id) as c from SAP_DIMCOMPANY where COMPANY_ID='" + Replace(txtCh2Company.Text, "'", "''") + "' and ORG_ID in ('TW01','TW20') ")) >= 2 Then
            Dim objSAPStauts As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", "SELECT AUFSD FROM SAPRDP.KNA1 WHERE KUNNR = '" + Replace(txtCh2Company.Text, "'", "''") + "' and rownum = 1")
            If objSAPStauts IsNot Nothing AndAlso Not String.IsNullOrEmpty(objSAPStauts) AndAlso objSAPStauts.ToString.Equals("01") Then
                AlertMsg.Text = "<script language='javascript'>alert('This account\'s ERPID """ + txtCh2Company.Text + """ has been assigned order block and is not allowed to change.');<" & "/" & "script>"
                Me.Page.Controls.Add(AlertMsg)
                Exit Sub
            End If
        End If

        If ChangeToCompanyId() Then
            'IC 2014/06/27 Insert into USER_LOG data when user change ERPID successfully. Remark : Change Company Id
            Try
                Dim strSql As String = String.Empty
                Dim pSessionID As New SqlClient.SqlParameter("SESSION", SqlDbType.VarChar) : pSessionID.Value = HttpContext.Current.Session.SessionID
                Dim pTransID As New SqlClient.SqlParameter("TRANS", SqlDbType.VarChar) : pTransID.Value = ""
                Dim pUserID As New SqlClient.SqlParameter("USERID", SqlDbType.VarChar) : pUserID.Value = HttpContext.Current.User.Identity.Name
                Dim pUrl As New SqlClient.SqlParameter("URL", SqlDbType.VarChar) : pUrl.Value = Context.Request.ServerVariables("SCRIPT_NAME").ToLower()
                Dim pQuery As New SqlClient.SqlParameter("QUERY", SqlDbType.VarChar) : pQuery.Value = txtCh2Company.Text
                Dim pNote As New SqlClient.SqlParameter("NOTE", SqlDbType.VarChar) : pNote.Value = "Change Company Id"
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

            If Request.ServerVariables("HTTP_REFERER") IsNot Nothing Then
                Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
            End If
        Else
            'Util.JSAlert(Page, "Company ID does not exist")
            'Response.Write("<script language='javascript'>alert('Company ID does not exist');</" & "script>")
            ' AlertMsg.Text = "<script language='javascript'>alert('Company ID does not exist');<" & "/" & "script>"
            AlertMsg.Text = "<script language='javascript'>alert('This account\'s ERPID """ + txtCh2Company.Text + """ is invalid either because it does not exist in SAP or it is not a sold-to account');<" & "/" & "script>"
            Me.Page.Controls.Add(AlertMsg)
        End If
    End Sub

    Function Configuration_Destroy(ByVal G_CATALOG_ID As String) As Integer
        REM == Get Category Info ==
        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = " Delete FROM CONFIGURATION_CATALOG_CATEGORY WHERE (CATALOG_ID = '" & G_CATALOG_ID & "')"
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        'sqlConn.Close()
        Configuration_Destroy = 1
    End Function

    Protected Sub SearchCompany()
        SqlDataSource1.SelectCommand = GetSql()
    End Sub

    Protected Sub SearchAdminCompany()
        Dim MySiebelWS As New MYSIEBELDAL
        Dim RBUs() As String = MySiebelWS.GetVisibleRBUByUser(HttpContext.Current.Session("user_id"))

        'JJ 2014/3/14：TC指示Liliana和Stefanie不用檢查RBU，能看到全球的資料
        If HttpContext.Current.Session("user_id").ToString.ToLower = "liliana.wen@advantech.com.tw" Or HttpContext.Current.Session("user_id").ToString.ToLower = "stefanie.chang@advantech.com.tw" Then
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format("select distinct top 200 b.row_id, a.company_id, a.company_name, b.account_name, a.ORG_ID, b.RBU, a.SALESOFFICENAME, "))
                .AppendLine(String.Format(" a.SALESGROUP, b.account_status from siebel_account b left join sap_dimcompany a on b.erp_id=a.company_id "))
                .AppendLine(String.Format(" where a.DELETION_FLAG<>'X' and a.company_type='Z001' "))
                If txtCompanyID.Text.Trim() <> "" Then .AppendLine(String.Format(" and a.COMPANY_ID like '{0}%' ", txtCompanyID.Text.Trim().Replace("'", "").Replace("*", "%")))
                If txtCompanyName.Text.Trim() <> "" Then .AppendLine(String.Format(" and (a.COMPANY_NAME like N'%{0}%' or b.account_name like N'%{0}%') ", txtCompanyName.Text.Trim().Replace("'", "''").Replace("*", "%")))
                If dlOrg.SelectedIndex > 0 Then .AppendLine(String.Format(" and a.ORG_ID = '{0}' ", dlOrg.SelectedValue))
                If txtRBU.Text.Trim() <> "" Then
                    .AppendLine(String.Format(" and b.RBU='{0}' ", txtRBU.Text.Trim().Replace("'", "")))
                End If
            End With
            SqlDataSource1.SelectCommand = sb.ToString + " order by a.company_name"
            ViewState("SqlCommand") = SqlDataSource1.SelectCommand
        Else

            If RBUs.Length > 0 Then
                For i As Integer = 0 To RBUs.Length - 1
                    RBUs(i) = "'" + Replace(RBUs(i), "'", "''") + "'"
                Next
                Dim InRBUString As String = String.Join(",", RBUs)
                Dim sb As New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format("select distinct top 200 b.row_id, a.company_id, a.company_name, b.account_name, a.ORG_ID, b.RBU, a.SALESOFFICENAME, "))
                    .AppendLine(String.Format(" a.SALESGROUP, b.account_status from siebel_account b left join sap_dimcompany a on b.erp_id=a.company_id "))
                    .AppendLine(String.Format(" where a.DELETION_FLAG<>'X' and a.company_type='Z001' and b.rbu in ({0}) ", InRBUString))
                    If txtCompanyID.Text.Trim() <> "" Then .AppendLine(String.Format(" and a.COMPANY_ID like '{0}%' ", txtCompanyID.Text.Trim().Replace("'", "").Replace("*", "%")))
                    If txtCompanyName.Text.Trim() <> "" Then .AppendLine(String.Format(" and (a.COMPANY_NAME like N'%{0}%' or b.account_name like N'%{0}%') ", txtCompanyName.Text.Trim().Replace("'", "''").Replace("*", "%")))
                    If dlOrg.SelectedIndex > 0 Then .AppendLine(String.Format(" and a.ORG_ID = '{0}' ", dlOrg.SelectedValue))
                    If txtRBU.Text.Trim() <> "" Then
                        .AppendLine(String.Format(" and b.RBU='{0}' ", txtRBU.Text.Trim().Replace("'", "")))
                    End If
                End With
                SqlDataSource1.SelectCommand = sb.ToString + " order by a.company_name"
                ViewState("SqlCommand") = SqlDataSource1.SelectCommand
            End If
        End If
    End Sub

    Protected Sub btnPickCompany_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtCompanyID.Text = Trim(txtCh2Company.Text)
        If LCase(Request.ServerVariables("URL")) = "/admin/profile_admin.aspx" Then
            SearchAdminCompany()
        Else
            SearchCompany()
        End If
        sgv1.Visible = True : Panel2.Visible = True : up1.Update() : ModalPopupExtender1.Show() : up2.Update()
    End Sub

    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender1.Hide() : up2.Update()
    End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub btnSearchCompanyID_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If LCase(Request.ServerVariables("URL")) = "/admin/profile_admin.aspx" Then
            SearchAdminCompany()
        Else
            SearchCompany()
        End If
    End Sub

    Protected Sub btnCompanyID_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtCh2Company.Text = CType(sender, LinkButton).Text : ModalPopupExtender1.Hide() : up1.Update()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        '解決UpdatePanel遇到respose.write Alert的問題
        Dim scriptManager As ScriptManager = scriptManager.GetCurrent(Me.Page)
        scriptManager.RegisterPostBackControl(Me.btnChangeCompany)

        If LCase(Request.ServerVariables("URL")) = "/admin/profile_admin.aspx" Then
            ac1.ServiceMethod = "GetAdminERPId"
        Else
            ac1.ServiceMethod = "GetERPId"
        End If
        If Not Page.IsPostBack Then
            Me.txtCh2Company.Attributes("autocomplete") = "off" : Me.txtCompanyID.Attributes("autocomplete") = "off"

            'Ryan 20180521 Add ddlCountry and its data source
            InitDDLCountry()
        End If
    End Sub

    Protected Sub sgv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SqlDataSource1.SelectCommand = GetSql()
    End Sub

    Protected Sub sgv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SqlDataSource1.SelectCommand = GetSql()
    End Sub

    Protected Sub InitDDLCountry()
        Me.ddlCountry.Items.Add(New ListItem("All", ""))

        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", " select distinct COUNTRY_NAME,COUNTRY_CODE FROM [MyAdvantechGlobal].[dbo].[SAP_COUNTRY_REGION_LOV] order by COUNTRY_CODE")
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows
                Me.ddlCountry.Items.Add(New ListItem(dr("COUNTRY_NAME").ToString, dr("COUNTRY_CODE").ToString))
            Next
        End If

        Me.ddlCountry.Items.FindByText("All").Selected = True
    End Sub

</script>
<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
    <ContentTemplate>
        <ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" ServicePath="~/Services/AutoComplete.asmx"
            FirstRowSelected="true" ServiceMethod="" CompletionInterval="100" TargetControlID="txtCh2Company"
            MinimumPrefixLength="2" />
        <table width="100%">
            <tr>
                <td width="21" height="33" align="center">
                    &nbsp;
                </td>
                <td align="left">
                    <asp:Panel runat="server" ID="ChgCompPanel" DefaultButton="btnChangeCompany" Height="95%"
                        ScrollBars="Auto">
                        <table width="100%">
                            <tr>
                                <td>
                                    <asp:TextBox runat="server" ID="txtCh2Company" Width="110px" Height="17px" />
                                </td>
                                <td>
                                    <asp:Button runat="server" ID="btnPickCompany" Text="Pick" OnClick="btnPickCompany_Click"
                                        Font-Size="X-Small" />
                                </td>
                                <td>
                                    <asp:Button runat="server" ID="btnChangeCompany" Text="Change" OnClick="btnChangeCompany_Click"
                                        Font-Size="X-Small" />
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                    <asp:LinkButton runat="server" ID="link1" />
                    <asp:Panel runat="server" ID="Panel2" Visible="false">
                        <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" PopupControlID="Panel1"
                            TargetControlID="link1" BackgroundCssClass="modalBackground" />
                        <asp:Panel runat="server" ID="Panel1" DefaultButton="btnSearchCompanyID">
                            <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <table cellpadding="0" cellspacing="0" style="background-color: White; width: 650px">
                                        <tr style="height: 5px">
                                            <td colspan="2">
                                                &nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" colspan="2">
                                                <asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" />&nbsp;&nbsp;
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="10px">
                                            </td>
                                            <td align="left">
                                                <table width="400px" border="0" bgcolor="f1f2f4" style="background-color: White">
                                                    <tr align="left">
                                                        <th align="left">
                                                            Company ID :
                                                        </th>
                                                        <td align="left">
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="auto1" TargetControlID="txtCompanyID"
                                                                MinimumPrefixLength="1" CompletionInterval="200" ServicePath="~/Services/AutoComplete.asmx"
                                                                ServiceMethod="GetERPId" />
                                                            <asp:TextBox runat="server" ID="txtCompanyID" Width="100px" />
                                                        </td>
                                                    </tr>
                                                    <tr align="left">
                                                        <th align="left">
                                                            Company Name :
                                                        </th>
                                                        <td align="left">
                                                            <asp:TextBox runat="server" ID="txtCompanyName" Width="150px" />
                                                        </td>
                                                    </tr>
                                                    <tr align="left" id="trAddress" runat="server">
                                                        <td colspan="2">
                                                            <table>
                                                                <tr>
                                                                    <td>
                                                                        <b>Country:</b>
                                                                        <asp:DropDownList runat="server" ID="ddlCountry">
                                                                           
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                    <td>
                                                                        <b>City:</b>
                                                                        <asp:TextBox runat="server" ID="txtCity" Width="150px" />
                                                                    </td>                                                                    
                                                                </tr>
                                                            </table>
                                                        </td>                                                        
                                                    </tr>
                                                    <tr align="left">
                                                        <td colspan="2">
                                                            <table>
                                                                <tr>
                                                                    <td>
                                                                        <b>Org:</b>
                                                                        <asp:DropDownList runat="server" ID="dlOrg">
                                                                            <asp:ListItem Text="All" Value="" />
                                                                            <asp:ListItem Text="EU10" Value="EU10" />
                                                                            <asp:ListItem Text="EU80" Value="EU80" />
                                                                            <asp:ListItem Text="TW01" Value="TW01" />
                                                                            <asp:ListItem Text="TW20" Value="TW20" />
                                                                            <asp:ListItem Text="CN10" Value="CN10" />
                                                                            <asp:ListItem Text="CN30" Value="CN30" />
                                                                            <asp:ListItem Text="US01" Value="US01" />
                                                                            <asp:ListItem Text="US10" Value="US10" />
                                                                            <asp:ListItem Text="JP01" Value="JP01" />
                                                                            <asp:ListItem Text="KR01" Value="KR01" />
                                                                            <asp:ListItem Text="SG01" Value="SG01" />
                                                                            <asp:ListItem Text="MY01" Value="MY01" />
                                                                            <asp:ListItem Text="BR01" Value="BR01" />
                                                                            <asp:ListItem Text="AU01" Value="AU01" />
                                                                            <asp:ListItem Text="VN01" Value="VN01" />
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                    <td>
                                                                        <b>RBU:</b>
                                                                        <asp:TextBox runat="server" ID="txtRBU" Width="60px" />
                                                                    </td>
                                                                    <td>
                                                                        <asp:Button runat="server" ID="btnSearchCompanyID" Text="Search" OnClick="btnSearchCompanyID_Click" />
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <table width="100%">
                                                    <tr>
                                                        <td colspan="2" valign="top" align="center">
                                                            <sgv:SmartGridView runat="server" ID="sgv1" AutoGenerateColumns="false" AllowPaging="true"
                                                                AllowSorting="true" PageSize="10" Width="97%" DataSourceID="SqlDataSource1" OnPageIndexChanging="sgv1_PageIndexChanging"
                                                                OnSorting="sgv1_Sorting" Visible="false">
                                                                <Columns>
                                                                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                        <HeaderTemplate>
                                                                            No.
                                                                        </HeaderTemplate>
                                                                        <ItemTemplate>
                                                                            <%# Container.DataItemIndex + 1 %>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Company ID" SortExpression="company_id" ItemStyle-HorizontalAlign="Left">
                                                                        <ItemTemplate>
                                                                            <asp:LinkButton runat="server" ID="btnCompanyID" CommandName="Select" Text='<%# Eval("company_id") %>'
                                                                                OnClick="btnCompanyID_Click" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField DataField="company_name" HeaderText="SAP Company Name" SortExpression="company_name"
                                                                        ItemStyle-HorizontalAlign="Left" />
                                                                    <asp:BoundField DataField="account_name" HeaderText="Siebel Account Name" SortExpression="account_name"
                                                                        ItemStyle-HorizontalAlign="Left" />
                                                                    <asp:BoundField HeaderText="Org." DataField="org_id" SortExpression="org_id" />
                                                                    <asp:BoundField HeaderText="RBU" DataField="RBU" SortExpression="RBU" />
                                                                    <asp:BoundField HeaderText="Account Status" DataField="account_status" SortExpression="account_status" />
                                                                    <asp:BoundField HeaderText="Sales Group" DataField="SALESGROUP" SortExpression="SALESGROUP" />
                                                                    <asp:BoundField HeaderText="Sales Office" DataField="SALESOFFICENAME" SortExpression="SALESOFFICENAME" />
                                                                    <asp:BoundField HeaderText="Zip Code" DataField="ZIP_CODE" SortExpression="ZIP_CODE" />
                                                                    <asp:BoundField HeaderText="City" DataField="CITY" SortExpression="CITY" />
                                                                    <asp:BoundField HeaderText="Street" DataField="ADDRESS" SortExpression="ADDRESS" />

                                                                    <asp:HyperLinkField HeaderText="Row Id" SortExpression="ROW_ID" DataNavigateUrlFields="ROW_ID"
                                                                        DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="ROW_ID"
                                                                        Target="_blank" />
                                                                </Columns>
                                                                <FixRowColumn FixColumns="-1" FixRowType="Header" TableHeight="400px" />
                                                            </sgv:SmartGridView>
                                                            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:RFM %>"
                                                                SelectCommand="" OnLoad="SqlDataSource1_Load"></asp:SqlDataSource>
                                                            <asp:Label runat="server" Text="Label" ID="test" Visible="false"></asp:Label>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </asp:Panel>
                    </asp:Panel>
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
