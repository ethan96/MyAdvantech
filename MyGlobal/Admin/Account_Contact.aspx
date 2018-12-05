<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Account Administration" %>
<%@ Register Src="~/Includes/account_admin_block.ascx" TagName="account_admin_block" TagPrefix="uc1" %>
<%@ Register Src="~/Includes/ChangeCompany.ascx" TagName="ChangeCompanyBlock" TagPrefix="uc2" %>

<script runat="server">
    Dim T_strSelect As String = "", strOrgId As String = "", strCompanyId As String = "",g_strMessage as string=""
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
         
        strOrgId = Session("org_id")
        strCompanyId = Session("company_id")
        g_strMessage = g_strMessage + " " + strOrgId & " / " & UCase(strCompanyId)
        T_strSelect = "select " & _
     "'' as C_NO, " & _
     "org_id, " & _
     "company_id, " & _
     "isnull(userid,'') as userid, " & _
     "isnull(job_function,'') as job_function, " & _
     "isnull(first_name,'') as first_name, " & _
     "isnull(last_name,'') as last_name, " & _
     "isnull(phone,'') as phone, " & _
     "'Edit' as C_EDIT, " & _
     "'Edit' as C_DELETE " & _
     "from company_contact " & _
     "where " & _
     "org_id = '" & strOrgId & "' and " & _
     "company_id = '" & strCompanyId & "'" & _
     "order by org_id, company_id"
        If Session("user_id") = "jackie.wu@advantech.com.cn" Then
            Response.Write(T_strSelect)
        End If
        ViewState("SqlCommand") = ""
        SqlDataSource1.SelectCommand = Me.T_strSelect
        ViewState("SqlCommand") = SqlDataSource1.SelectCommand
        ' End If
        If Not Page.IsPostBack Then
            gv1.DataBind()
        End If
    End Sub
    
    Protected Sub Button2_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        strOrgId = Request("org_id")
        strCompanyId = Request("company_id")
        dbUtil.dbExecuteNoQuery("B2B", "DELETE FROM COMPANY_CONTACT WHERE " & _
        "COMPANY_ID='" & Session("COMPANY_ID") & "' AND " & _
        "ORG_ID='" & Session("COMPANY_ORG_ID") & "'")

        dbUtil.dbExecuteNoQuery("B2B", "INSERT INTO COMPANY_CONTACT " & _
            "SELECT USERID,'" & Session("COMPANY_ID") & "','" & Session("COMPANY_ORG_ID") & "',ROLE,FIRST_NAME,LAST_NAME,PHONE,EXTENSION," & _
            "       LOC_COUNTRY,OFFICE,EMAIL_ADDR,PRIMARY_BU,LOC_REGION,JOB_FUNCTION,FAX,LOC_CITY,getdate(),ACCOUNT_MANAGER " & _
            "  FROM COMPANY_CONTACT " & _
            " WHERE COMPANY_ID = '" & strCompanyId & "' AND ORG_ID = '" & strOrgId & "'")
        g_strMessage = g_strMessage + " Bulk copy to " & Session("COMPANY_ORG_ID") & ":" & Session("COMPANY_ID") & " sucessfully. "
        'Response.Redirect("../admin/account_contact.aspx?company_id")
        'Me.Label1.Text = " Bulk copy to" & Me.txtDestOrg.Value.Trim() & ";" & Me.txtDestCompany.Value.Trim() & " sucessfully. "
    End Sub

    Protected Sub gv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
        End If
    End Sub
    
    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub
    
    Protected Sub btnAddNewContact_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Response.Redirect("/admin/account_contact_new.aspx")
    End Sub

    Protected Sub btnEdit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim xCompanyID As String = CType(CType(sender, ImageButton).NamingContainer, GridViewRow).Cells(2).Text
        Dim xUserID As String = CType(CType(sender, ImageButton).NamingContainer, GridViewRow).Cells(3).Text
        Response.Redirect("/admin/account_contact_update.aspx?company_id=" + xCompanyID + "&userid=" + xUserID + "&org_id=" + Session("org_id"))
    End Sub

    Protected Sub btnDelete_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim xOrgID As String = CType(CType(sender, ImageButton).NamingContainer, GridViewRow).Cells(1).Text
        Dim xCompanyID As String = CType(CType(sender, ImageButton).NamingContainer, GridViewRow).Cells(2).Text
        Dim xUserID As String = CType(CType(sender, ImageButton).NamingContainer, GridViewRow).Cells(3).Text
        Dim sql As String = String.Format("delete from company_contact where org_id='{0}' and company_id='{1}' and userid='{2}'", xOrgID, xCompanyID, xUserID)
        dbUtil.dbExecuteNoQuery("B2B", sql)
        gv1.DataBind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr valign="top">
				<td>
					<!-- ******* main pane (start) ********-->
					<table width="100%" ID="Table2">
						<!-- ******* thread bar (start) ********-->
						<tr>
							<td class="text_mini">&nbsp;&nbsp;
								<!-- ******* thread bar (start) ********-->
								<!-- **** Thread Bar ****-->
								<a href="/Admin/profile_admin.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>">Account
									Administration</a> &gt; Contact Administration
								<!-- ******* thread bar (end) ********-->
							</td>
						</tr>
						<!-- ******* thread bar (end) ********-->
						<tr valign="top">
							<td height="2">&nbsp;
							</td>
						</tr>
						<!-- ******* page title (start) ********-->
						<tr valign="top">
							<td class="pagetitle">
								&nbsp;&nbsp;<img src="../images/title-dot.gif" width="25" height="17">&nbsp;
								Contact Administration&nbsp;&nbsp;&nbsp;<span class="PageMessageBar"><%=g_strMessage%></span>
							</td>
						</tr>
						<!-- ******* page title (end) ********-->
						<tr valign="top">
							<td height="2">&nbsp;
							</td>
						</tr>
						<tr valign="top">
							<td>
								<table width="100%" ID="Table3">
									<!-- ******* form  (start) ********-->
									<tr valign="top">
										<td valign="top" width="82%">
											<!-- include virtual = "/Test_sebastian/pick_bcp_account_form.asp" -->
											<!-- include virtual = "/includesV2/forms/pick_bcp_account_form.asp" -->
											
											<table>
											<tr>
		<td valign="top">
			<table valign="top" width="100%" cellpadding="3" cellspacing="0" border="0">
				<tr class="FormBlank">
					<td valign="top" width="30%">
						<table border="0">
							<tr>
								<td><b>Change Company : </b><uc2:ChangeCompanyBlock runat="server" ID="ucChangeCompany" /></td>
							</tr>
							<tr>
								<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:Button ID="Button2" runat="server" Text="Bulk Copy" OnClick="Button2_Click" /></td>
							</tr>
						</table>
                    </td>
				</tr>
			</table>
        </td>
	</tr>
	</table>
                                            <asp:Label ID="Label1" runat="server" ForeColor="Red"></asp:Label></td>
										<td valign="top" width="130">
                                            <uc1:account_admin_block ID="Account_admin_block1" runat="server" />
											<!-- include virtual = "/profile/account_admin_block.asp" -->
											
										</td>
									</tr>
									<!-- ******* form  (end) ********-->
								</table>
							</td>
						</tr>
						<!-- ******* record list1 (start) ********-->
						<tr valign="top">
							<td>
								<sgv:SmartGridView ShowWhenEmpty="true" runat="server" ID="gv1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false" 
                                    HeaderStyle-HorizontalAlign="Center" AllowSorting="true" AllowPaging="true" PageSize="50" Width="100%" OnRowDataBoundDataRow="gv1_RowDataBoundDataRow">
				                    <Columns>
				                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                            <headertemplate>
                                                No.
                                            </headertemplate>
                                            <itemtemplate>
                                                <%# Container.DataItemIndex + 1 %>
                                            </itemtemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="Org Id" DataField="org_id" ItemStyle-HorizontalAlign="Center" SortExpression="org_id" />
                                        <asp:BoundField HeaderText="Company Id" DataField="company_id" SortExpression="company_id" />
                                        <asp:BoundField HeaderText="User Id" DataField="userid" />
                                        <asp:BoundField HeaderText="Role" DataField="job_function" SortExpression="job_function" />
                                        <asp:BoundField HeaderText="First Name" DataField="first_name" />
                                        <asp:BoundField HeaderText="Last Name" DataField="last_name" SortExpression="last_name" />
                                        <asp:BoundField HeaderText="Phone" DataField="phone" SortExpression="phone" />
                                        <asp:TemplateField HeaderText="Edit" ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <asp:ImageButton runat="server" ID="btnEdit" ImageUrl="/images/pencil.gif" OnClick="btnEdit_Click" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Delete" ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <asp:ImageButton runat="server" ID="btnDelete" ImageUrl="/images/btn_del.gif" OnClick="btnDelete_Click" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
				                    <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                    <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                    <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                    <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                                    <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                    <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                    <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
				                </sgv:SmartGridView>
				                <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:B2B %>" 
				                    SelectCommand="" OnLoad="SqlDataSource1_Load">
				                </asp:SqlDataSource>
							</td>
						</tr>
						<tr valign="top">
							<td height="2" align="right">
							    <asp:ImageButton runat="server" ID="btnAddNewContact" ImageUrl="/images/addnew_contact.GIF" OnClick="btnAddNewContact_Click" />
							</td>
						</tr>
						<tr valign="top">
							<td height="2"><hr>
							</td>
						</tr>
					</table>
					<!-- ******* main pane (end) ********-->
				</td>
			</tr>
			<tr valign="top">
				<td height="2">&nbsp;
				</td>
			</tr>
		</table>
</asp:Content>

