<%@ Page Title="Sync Siebel Account Contact" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetAccName(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim topCount As Integer = 20
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select top " + topCount.ToString() + " A.NAME FROM S_ORG_EXT A where upper(A.NAME) like N'{0}%' ", prefixText.ToUpper()))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String, alist As New ArrayList
            For Each r As DataRow In dt.Rows
                If Not alist.Contains(r.Item(0)) Then
                    str(alist.Count) = r.Item(0)
                    alist.Add(r.Item(0))
                End If
            Next
            ReDim Preserve str(alist.Count - 1)
            Return str
        End If
        Return Nothing
    End Function
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetERPID(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim topCount As Integer = 20
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select top " + topCount.ToString() + " A.NAME FROM S_ORG_EXT A where upper(A.NAME) like N'{0}%' ", prefixText.ToUpper()))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String, alist As New ArrayList
            For Each r As DataRow In dt.Rows
                If Not alist.Contains(r.Item(0)) Then
                    str(alist.Count) = r.Item(0)
                    alist.Add(r.Item(0))
                End If
            Next
            ReDim Preserve str(alist.Count - 1)
            Return str
        End If
        Return Nothing
    End Function
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim accId As String = txtAccId.Text.Trim.Replace("'", "''")
        Dim accName As String = txtAccName.Text.Trim.Replace("'", "''")
        Dim erpid As String = txtERPID.Text.Trim.Replace("'", "''")
        Dim conId As String = txtConId.Text.Trim.Replace("'", "''")
        Dim email As String = txtEmail.Text.Trim.Replace("'", "''")
        If accId = "" AndAlso accName = "" AndAlso erpid = "" AndAlso conId = "" AndAlso email = "" Then Exit Sub
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select distinct a.ROW_ID,IsNull(b.ATTRIB_05,'') as ERP_ID, a.NAME as ACCOUNT_NAME, ")
            .AppendFormat(" a.CUST_STAT_CD as ACCOUNT_STATUS, IsNull(a.OU_TYPE_CD, '') as ACCOUNT_TYPE,")
            .AppendFormat(" IsNull((select EMAIL_ADDR from S_CONTACT where ROW_ID in (select PR_EMP_ID from S_POSTN where ROW_ID in (Select PR_POSTN_ID from S_ORG_EXT where ROW_ID = a.ROW_ID))),'') as PRIMARY_SALES_EMAIL ")
            .AppendFormat(" from S_ORG_EXT a left join S_CONTACT c on c.PR_DEPT_OU_ID = a.PAR_ROW_ID left join S_ORG_EXT_X b on a.ROW_ID=b.ROW_ID where 1=1 ")
            If accId <> "" Then .AppendFormat(" and Upper(a.ROW_ID)='{0}' ", accId.ToUpper())
            If accName <> "" Then .AppendFormat(" and Upper(a.NAME) like N'%{0}%' ", accName.ToUpper())
            If erpid <> "" Then .AppendFormat(" and Upper(b.ATTRIB_05) like '{0}%' ", erpid.ToUpper())
            If conId <> "" Then .AppendFormat(" and Upper(c.ROW_ID)='{0}' ", conId.ToUpper())
            If email <> "" Then .AppendFormat(" and Upper(c.EMAIL_ADDR) like '{0}%' ", email.ToUpper())
            .AppendFormat(" order by a.ROW_ID")
        End With
        ViewState("Sql") = sb.ToString
       TestLab.Text = sb.ToString()
        SqlDataSource1.SelectCommand = sb.ToString
        lblSyncAcc.Text = "" : lblSyncCon.Text = "" : upMsg.Update()
    End Sub

    Protected Sub SqlDataSource1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 30000
    End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("Sql") <> "" AndAlso Not IsNothing(ViewState("Sql")) Then
            SqlDataSource1.SelectCommand = ViewState("Sql")
        End If
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim accId As String = e.Row.Cells(2).Text
            Dim sb As New StringBuilder
            With sb
                .AppendFormat("select A.ROW_ID, IsNull(A.FST_NAME, '') +' '+ IsNull(A.LAST_NAME, '') AS Name, ")
                .AppendFormat(" IsNull(A.EMAIL_ADDR, '') AS EMAIL_ADDRESS, IsNull(A.SUPPRESS_EMAIL_FLG, '') as NeverEmail ")
                .AppendFormat(" FROM S_CONTACT A left join S_ORG_EXT B on A.PR_DEPT_OU_ID = B.PAR_ROW_ID where B.ROW_ID='{0}' ", accId)
                .AppendFormat(" and A.EMAIL_ADDR is not null and A.EMAIL_ADDR != '' ")
                If txtEmail.Text.Trim.Replace("'", "''") <> "" Then .AppendFormat(" and Upper(A.EMAIL_ADDR) like '{0}%' ", txtEmail.Text.Trim.Replace("'", "''").ToUpper())
                If txtConId.Text.Trim.Replace("'", "''") <> "" Then .AppendFormat(" and Upper(A.ROW_ID)='{0}' ", txtConId.Text.Trim.Replace("'", "''").ToUpper())
                .AppendFormat(" order by A.EMAIL_ADDR")
            End With
            CType(e.Row.Cells(7).FindControl("Sql2"), SqlDataSource).SelectCommand = sb.ToString
            
        End If
    End Sub

    Protected Sub btnSync_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lblSyncCon.Text = "" : lblSyncAcc.Text = ""
        Dim arrAccId As New ArrayList, arrConId As New ArrayList, arrErpiD As New ArrayList
        For Each row As GridViewRow In gv1.Rows
            If CType(row.Cells(1).FindControl("cbAcc"), CheckBox).Checked Then
                If Not arrAccId.Contains("'" + row.Cells(2).Text + "'") Then arrAccId.Add("'" + row.Cells(2).Text + "'")
                If Not arrErpiD.Contains(row.Cells(4).Text) Then arrErpiD.Add(row.Cells(4).Text)
            End If
            For Each conR As GridViewRow In CType(row.Cells(7).FindControl("gv2"), SmartGridView).Rows
                If CType(conR.Cells(0).FindControl("cbCon"), CheckBox).Checked Then
                    If Not arrConId.Contains("'" + conR.Cells(1).Text + "'") Then arrConId.Add("'" + conR.Cells(1).Text + "'")
                End If
            Next
        Next
        If arrAccId.Count > 0 Then
            If SyncSiebelAccount(arrAccId) = True Then
                'Dim SC As New SAPDAL.syncSingleCompany
                SAPDAL.syncSingleCompany.syncSingleSAPCustomer(arrErpiD, False, "")
                lblSyncAcc.Text = "Accounts synced: " + String.Join(",", arrAccId.ToArray()).Replace("'", "").Replace(",", ", ")
            Else
                lblSyncAcc.Text = "Accounts synced failed: " + String.Join(",", arrAccId.ToArray()).Replace("'", "").Replace(",", ", ")
            End If
        End If
        
        If arrConId.Count > 0 Then
            If SyncSiebelContact(arrConId) = True Then
                lblSyncCon.Text = "Contacts synced: " + String.Join(",", arrConId.ToArray()).Replace("'", "").Replace(",", ", ")
            Else
                lblSyncCon.Text = "Contacts synced failed: " + String.Join(",", arrConId.ToArray()).Replace("'", "").Replace(",", ", ")
            End If
        End If
        
        upMsg.Update()
        'Util.SendTestEmail("test", lblSyncAcc.Text + "<br/>" + lblSyncCon.Text)
    End Sub
    
    Private Function SyncSiebelAccount(ByVal arrAccId As ArrayList) As Boolean
        Try
            Dim sb As New StringBuilder
            With sb
                .AppendFormat("select a.ROW_ID, IsNull(b.ATTRIB_05,'') as ERP_ID, a.NAME as ACCOUNT_NAME, a.CUST_STAT_CD as ACCOUNT_STATUS,")
                .AppendFormat("IsNull(a.MAIN_FAX_PH_NUM, '') as FAX_NUM, IsNull(a.MAIN_PH_NUM, '') as PHONE_NUM,")
                .AppendFormat("IsNull(a.OU_TYPE_CD, '') as OU_TYPE_CD,IsNull(a.URL, '') as URL,IsNull(b.ATTRIB_34, '') as BusinessGroup, ")
                .AppendFormat("IsNull(a.OU_TYPE_CD, '') as ACCOUNT_TYPE, IsNull(c.NAME, '') as RBU,  ")
                .AppendFormat("IsNull((select EMAIL_ADDR from S_CONTACT where ROW_ID in (select PR_EMP_ID from S_POSTN where ROW_ID in (select PR_POSTN_ID from S_ORG_EXT where ROW_ID=a.ROW_ID))),'') as PRIMARY_SALES_EMAIL, ")
                .AppendFormat("a.PAR_OU_ID as PARENT_ROW_ID,IsNull(b.ATTRIB_09,'N') as MAJORACCOUNT_FLAG,IsNull(a.CMPT_FLG,'N') as COMPETITOR_FLAG,")
                .AppendFormat("IsNull(a.PRTNR_FLG,'N') as PARTNER_FLAG,IsNull(d.COUNTRY,'') as COUNTRY,IsNull(d.CITY,'') as CITY,")
                .AppendFormat("IsNull(d.ADDR,'') as ADDRESS,IsNull(d.STATE,'') as STATE, IsNull(d.ZIPCODE,'') as ZIPCODE, IsNull(d.PROVINCE,'') as PROVINCE, ")
                .AppendFormat("IsNull((select top 1 NAME from S_INDUST where ROW_ID=a.X_ANNIE_PR_INDUST_ID),'N/A') as BAA,a.CREATED, a.LAST_UPD as LAST_UPDATED, ")
                .AppendFormat("IsNull((select top 1 e.NAME from S_PARTY e inner join S_POSTN f on e.ROW_ID=f.OU_ID where f.ROW_ID in (select PR_POSTN_ID from S_ORG_EXT where ROW_ID=a.ROW_ID)),'')  as PriOwnerDivision, ")
                .AppendFormat("PR_POSTN_ID as PriOwnerRowId,IsNull((select top 1 f.NAME from S_POSTN f where f.ROW_ID in (select PR_POSTN_ID from S_ORG_EXT where ROW_ID=a.ROW_ID)),'')  as PriOwnerPosition, ")
                .AppendFormat(" cast('' as nvarchar(10)) as LOCATION, cast('' as nvarchar(10)) as ACCOUNT_TEAM, ")
                .AppendFormat("IsNull(d.ADDR_LINE_2,'') as ADDRESS2, IsNull(b.ATTRIB_36,'') as ACCOUNT_CC_GRADE, IsNull(a.BASE_CURCY_CD,'') as CURRENCY ")
                .AppendFormat("from S_ORG_EXT a left join S_ORG_EXT_X b on a.ROW_ID=b.ROW_ID left join S_PARTY c on a.BU_ID=c.ROW_ID left join S_ADDR_PER d on a.PR_ADDR_ID=d.ROW_ID ")
                .AppendFormat("where a.ROW_ID in ({0})", String.Join(",", arrAccId.ToArray()))
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString)
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_account where row_id in ({0})", String.Join(",", arrAccId.ToArray())))
            Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            BCopy.DestinationTableName = "SIEBEL_ACCOUNT"
            BCopy.WriteToServer(dt)
            
            'Update eQ Account's ERPID
            sb = New StringBuilder
            With sb
                .AppendFormat(" update Q set Q.quoteToErpId=C.COMPANY_ID  from eQuotation.dbo.QuotationMaster  Q ")
                .AppendFormat(" inner  join SIEBEL_ACCOUNT A  on A.ROW_ID = Q.quoteToRowId ")
                .AppendFormat(" inner  join SAP_DIMCOMPANY C  on  C.COMPANY_ID = A.ERP_ID ")
                .AppendFormat(" where  ( Q.quoteToErpId is null or Q.quoteToErpId='') ")
                .AppendFormat(" and (Q.qstatus ='FINISH' or Q.DOCSTATUS =1)  and C.COMPANY_TYPE='Z001'   and  A.ROW_ID in ({0}) ", String.Join(",", arrAccId.ToArray()))
            End With
            dbUtil.dbExecuteNoQuery("MY", sb.ToString)
            Return True
        Catch ex As Exception
            'Util.SendTestEmail("error", ex.ToString)
            Return False
        End Try
        
    End Function
    
    Private Function SyncSiebelContact(ByVal arrConId As ArrayList) As Boolean
        Try
            Dim sb As New StringBuilder
            With sb
                .AppendFormat("SELECT  A.ROW_ID, IsNull(A.FST_NAME, '') AS 'FirstName',IsNull(A.MID_NAME, '') as 'MiddleName', IsNull(A.LAST_NAME, '') AS 'LastName', ")
                .AppendFormat("IsNull(A.WORK_PH_NUM, '') as 'WorkPhone',IsNull(A.CELL_PH_NUM, '') as 'CellPhone',IsNull(A.FAX_PH_NUM, '') as 'FaxNumber', ")
                .AppendFormat("IsNull(E.ATTRIB_37, '') as 'JOB_FUNCTION', IsNull(A.PAR_ROW_ID, '') as PAR_ROW_ID,IsNull(D.ATTRIB_05, '') AS 'ERPID', ")
                .AppendFormat("IsNull(A.BU_ID, '') as 'PriOrgId',(select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) as 'OrgID', ")
                .AppendFormat("IsNull(A.PR_POSTN_ID, '') as 'OwnerId',IsNull(E.ATTRIB_09, 'N') AS 'CanSeeOrder',IsNull(A.X_CONTACT_LOGIN_PASSWORD, '') AS Password,")
                .AppendFormat("'' as 'Sales_Rep',IsNull(A.SUPPRESS_EMAIL_FLG, '') as NeverEmail,IsNull(A.SUPPRESS_CALL_FLG,'') as NeverCall,")
                .AppendFormat("IsNull(A.SUPPRESS_FAX_FLG, '') as NeverFax,IsNull(A.SUPPRESS_MAIL_FLG, '') as NeverMail,IsNull(A.JOB_TITLE, '') as JOB_TITLE,")
                .AppendFormat("IsNull(A.EMAIL_ADDR, '') AS 'EMAIL_ADDRESS',A.COMMENTS,B.ROW_ID as ACCOUNT_ROW_ID,IsNull(B.NAME, '') AS ACCOUNT,IsNull(B.OU_TYPE_CD, '') AS 'ACCOUNT_TYPE', ")
                .AppendFormat("IsNull(B.CUST_STAT_CD, '') AS 'ACCOUNT_STATUS',IsNull(C.COUNTRY, '') AS COUNTRY,IsNull(A.PER_TITLE, '') as Salutation,")
                .AppendFormat("A.EMP_FLG as EMPLOYEE_FLAG,IsNull(A.ACTIVE_FLG,'N') as ACTIVE_FLG,IsNull(A.DFLT_ORDER_PROC_CD,'') as User_Type, IsNull(F.APPL_SRC_CD,'') as Reg_Source,")
                .AppendFormat("A.CREATED, A.LAST_UPD as LAST_UPDATED, A.PR_REP_SYS_FLG as PRIMARY_FLAG   ")
                .AppendFormat("FROM S_CONTACT A LEFT JOIN S_CONTACT_X E ON A.ROW_ID = E.ROW_ID LEFT JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID ")
                .AppendFormat("LEFT JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID LEFT JOIN S_ADDR_PER C ON A.PR_OU_ADDR_ID = C.ROW_ID LEFT JOIN S_PER_PRTNRAPPL F ON A.ROW_ID=F.ROW_ID ")
                .AppendFormat("WHERE A.ROW_ID = A.PAR_ROW_ID and A.ROW_ID in ({0})", String.Join(",", arrConId.ToArray()))
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString)
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact where row_id in ({0})", String.Join(",", arrConId.ToArray())))
            Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            BCopy.DestinationTableName = "SIEBEL_CONTACT"
            BCopy.WriteToServer(dt)
        
            'dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact_privilege where row_id in ({0})", String.Join(",", arrConId.ToArray())))
            'dt = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT a.PAR_ROW_ID as ROW_ID, b.EMAIL_ADDR as EMAIL_ADDRESS, " + _
            '        "IsNull((select top 1 z.VAL from S_LST_OF_VAL z where z.TYPE = 'CONTACT_MYADVAN_PVLG' and z.ROW_ID=a.NAME),'N/A') as PRIVILEGE  " + _
            '        "FROM S_CONTACT_XM a inner join S_CONTACT b on a.PAR_ROW_ID=b.ROW_ID " + _
            '        "WHERE a.TYPE = 'CONTACT_MYADVAN_PVLG' and a.PAR_ROW_ID in ({0})", String.Join(",", arrConId.ToArray())))
            'If dt.Rows.Count > 0 Then
            '    Dim BCopy1 As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            '    BCopy1.DestinationTableName = "SIEBEL_CONTACT_PRIVILEGE"
            '    BCopy1.WriteToServer(dt)
            'End If
            Return True
        Catch ex As Exception
            'Util.SendTestEmail("error", ex.ToString)
            Return False
        End Try
        
    End Function

    Protected Sub gv2_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
    
    End Sub

    Protected Sub gv2_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim chk As CheckBox
        Dim checkboxIdsList As New ArrayList
        For Each rowItem As GridViewRow In CType(sender, SmartGridView).Rows
            chk = CType(rowItem.Cells(0).FindControl("cbCon"), CheckBox)
            checkboxIdsList.Add(chk.ClientID)
        Next
        Dim checkboxIds As String = String.Join("|", checkboxIdsList.ToArray())
        'Util.SendTestEmail("test", checkboxIds)
        CType(CType(sender, SmartGridView).HeaderRow.Cells(0).FindControl("cbConAll"), CheckBox).Attributes.Add("onclick", "selectAll('" & checkboxIds & "',this)")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script type="text/javascript">
    function selectAll(obj1, obj2) {
        var checkboxIds = new String();
        checkboxIds = obj1;

        var arrIds = new Array();
        arrIds = checkboxIds.split('|');

        for (var i = 0; i < arrIds.length; i++) {
            document.getElementById(arrIds[i]).checked = obj2.checked;
        }
    }
</script>
    <asp:Panel runat="server" ID="Panel1" DefaultButton="btnSearch">
        <table>
            <tr>
                <td>
                    <table cellpadding="2" cellspacing="2">
                        <tr>
                            <td>Account Row ID: <asp:TextBox runat="server" ID="txtAccId" /></td>
                            <td>Account Name: <asp:TextBox runat="server" ID="txtAccName" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"                                           
                                    ServiceMethod="GetAccName" TargetControlID="txtAccName" 
                                    MinimumPrefixLength="2" FirstRowSelected="true" />
                            </td>
                            <td>ERPID: <asp:TextBox runat="server" ID="txtERPID" />
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace2"                                           
                                    ServiceMethod="GetERPId" ServicePath="~/Services/AutoComplete.asmx" TargetControlID="txtERPID" 
                                    MinimumPrefixLength="2" FirstRowSelected="true" />
                            </td>
                        </tr>
                        <tr>
                            <td>Contact Row ID: <asp:TextBox runat="server" ID="txtConId" /></td>
                            <td>Contact Email: <asp:TextBox runat="server" ID="txtEmail" /></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
                <td valign="bottom">
                    <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                        <ContentTemplate>
                            <table>
                                <tr><td><asp:Label runat="server" ID="lblSyncAcc" ForeColor="Blue" /></td></tr>
                                <tr><td><asp:Label runat="server" ID="lblSyncCon" ForeColor="Blue" /></td></tr>
                            </table>
                            <asp:Label runat="server" Text="Label" ID="TestLab" Visible="false"></asp:Label>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </td>
            </tr>
            <tr>
                <td colspan="2"><asp:Button runat="server" ID="btnSync" Text="Sync Account or Contact" OnClick="btnSync_Click" /></td>
            </tr>
        </table>
    </asp:Panel>
    
    <table height="400px">
        <tr>
            <td valign="top">
                <asp:UpdatePanel runat="server" ID="up1">
                    <ContentTemplate>
                        <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" 
                            PageSize="30" DataSourceID="SqlDataSource1" OnRowDataBound="gv1_RowDataBound" Width="100%">
                            <Columns>
                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                    <headertemplate>
                                        No.
                                    </headertemplate>
                                    <itemtemplate>
                                        <%# Container.DataItemIndex + 1 %>
                                    </itemtemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sync">
                                    <HeaderTemplate>
                                        <asp:CheckBox runat="server" ID="cbAccAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox runat="server" ID="cbAcc" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ROW_ID" HeaderText="ROW ID" SortExpression="ROW_ID" />
                                <asp:BoundField DataField="ACCOUNT_NAME" HeaderText="Account Name" SortExpression="ACCOUTN_NAME" />
                                <asp:BoundField DataField="ERP_ID" HeaderText="ERP ID" SortExpression="ERP_ID" />
                                <asp:BoundField DataField="ACCOUNT_STATUS" HeaderText="Account Status" SortExpression="ACCOUNT_STATUS" />
                                <asp:BoundField DataField="PRIMARY_SALES_EMAIL" HeaderText="Primary Sales Email" SortExpression="PRIMARY_SALES_EMAIL" />
                                <asp:TemplateField HeaderText="Contact Info.">
                                    <ItemTemplate>
                                        <table>
                                            <tr><td height="5"></td></tr>
                                            <tr>
                                                <td>
                                                    <sgv:SmartGridView runat="server" ID="gv2" AutoGenerateColumns="false" Width="100%" DataSourceID="Sql2" OnRowDataBound="gv2_RowDataBound" OnPreRender="gv2_PreRender">
                                                        <Columns>
                                                            <asp:TemplateField HeaderText="Sync">
                                                                <HeaderTemplate>
                                                                    <asp:CheckBox runat="server" ID="cbConAll" />
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <asp:CheckBox runat="server" ID="cbCon" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:BoundField DataField="ROW_ID" HeaderText="ROW ID" />
                                                            <asp:BoundField DataField="Name" HeaderText="Name" />
                                                            <asp:BoundField DataField="EMAIL_ADDRESS" HeaderText="Email" />
                                                            <asp:BoundField DataField="NeverEmail" HeaderText="NeverEmail" />
                                                        </Columns>
                                                        <HeaderStyle BackColor="#E5F39D" />
                                                        <FixRowColumn FixColumns="-1" FixRows="-1" TableHeight="100px" />
                                                    </sgv:SmartGridView>
                                                    <asp:SqlDataSource ID="Sql2" runat="server" ConnectionString="<%$ ConnectionStrings:CRMDB75 %>" 
                                                        SelectCommand="">
                                                    </asp:SqlDataSource>
                                                </td>
                                            </tr>
                                            <tr><td height="5"></td></tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <CascadeCheckboxes>
                                <sgv:CascadeCheckbox ParentCheckboxID="cbAccAll" ChildCheckboxID="cbAcc" />
                            </CascadeCheckboxes>
                        </sgv:SmartGridView>
                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:CRMDB75 %>" 
                                SelectCommand="" OnSelecting="SqlDataSource1_Selecting" OnLoad="SqlDataSource1_Load">
                        </asp:SqlDataSource>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="btnSync" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    
</asp:Content>

