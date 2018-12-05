<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Register Contact" %>

<script runat="server">
    Dim strCompanyId, strOrgId As String
    Protected Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        If Request("company_id") <> "" Then
            strCompanyId = UCase(Request("company_id"))
            Me.company_id.Text = strCompanyId
        Else
            strCompanyId = Me.company_id.Text
        End If
        If Request("org_id") <> "" Then
            strOrgId = UCase(Request("org_id"))
            Me.company_id.Text = strOrgId
        Else
            strOrgId = Me.org_id.Text
        End If
        
        'If Request("userid") = "" And Page.IsPostBack Then
        '    Me.userid.Text = Request("userid")
        '    Me.LblMsg.Text = "Error: Please complete User ID!"
        '    Me.EmptyFlag.Text = "YES"
        '    Exit Sub
        'Else
        '    Me.userid.Text = Request("userid")
        'End If
        'If Request("fname") = "" And Page.IsPostBack Then
        '    Me.fname.Text = Request("fname")
        '    Me.LblMsg.Text = "Error: Please complete First Name!"
        '    Me.EmptyFlag.Text = "YES"
        '    Exit Sub
        'Else
        '    Me.fname.Text = Request("fname")
        'End If
        'If Request("lname") = "" And Page.IsPostBack Then
        '    Me.lname.Text = Request("lname")
        '    Me.LblMsg.Text = "Error: Please complete Last Name!"
        '    Me.EmptyFlag.Text = "YES"
        '    Exit Sub
        'Else
        '    Me.lname.Text = Request("lname")
        'End If
        'If Me.job_function.SelectedIndex = 0 And Page.IsPostBack Then
        '    Me.LblMsg.Text = "Error: Please choose a job function!"
        '    Me.EmptyFlag.Text = "YES"
        '    Exit Sub
        'End If
        'strCompanyId = "UUAAESC"
        strOrgId = Session("org_id")
        Me.company_id.Text = strCompanyId
        Me.org_id.Text = strOrgId
    End Sub
    Protected Sub Register_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If LCase(Me.action.Text) = "register" And Me.EmptyFlag.Text = "NO" Then
            '==== check user exist ===='
            Dim flgError As Boolean
            Dim strSqlCmd As String = ""
            Dim adoDT As DataTable
            strSqlCmd = "select * from company_contact where userid ='" & Me.userid.Text & "' and company_id='" & Me.company_id.Text & "' and org_id='" & Me.org_id.Text & "'"
            adoDT = dbUtil.dbGetDataTable("B2B", strSqlCmd)
            If adoDT.Rows.Count > 0 Then
                Me.LblMsg.Text = " Error: User " & Me.userid.Text & " already exist! "
                flgError = True
            End If

            strSqlCmd = "select * from contact where userid ='" & Me.userid.Text & "'"
            adoDT = New DataTable
            adoDT = dbUtil.dbGetDataTable("My", strSqlCmd)
            If adoDT.Rows.Count < 1 Then
                Me.LblMsg.Text = " Error: User """ & Me.userid.Text & """ not found in user pool! "
                flgError = True
            End If
            '==== password not match ===='
            If flgError = False Then
                strSqlCmd = "insert company_contact " & _
                   "(userid," & _
                   "org_id," & _
                   "company_id," & _
                   "first_name," & _
                   "last_name," & _
                   "job_function,autoupdate,PHONE) " & _
                   "values(" & _
                   "'" & LCase(Me.userid.Text) & "'," & _
                   "'" & Me.org_id.Text & "'," & _
                   "'" & UCase(Session("company_id")) & "'," & _
                   "'" & Me.fname.Text & "'," & _
                   "'" & Me.lname.Text & "'," & _
                   "'" & Me.job_function.SelectedValue & "','No','" & Request("tel_no") & "')"
                'Response.Write(strSqlCmd) : Response.End()
                dbUtil.dbExecuteNoQuery("B2B", strSqlCmd)
                'Me.company_id.Text
                Me.LblMsg.Text = " Note: Add new contact " & Me.userid.Text & " successfully! "
            End If
        Else
            Me.EmptyFlag.Text = "NO"
        End If
    End Sub

    Protected Sub btnPickEmployee_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        'xCompanyID = Request.QueryString("CompanyID")
        'Type = Request.QueryString("Type")
        'ElementName = Request.QueryString("Element")
        Dim strSqlCmd As String
        strSqlCmd = "select " & _
                    "Company_id," & _
                    "isnull(firstname,'') as firstname, " & _
                    "isnull(lastname,'') as lastname, " & _
                    "userid, " & _
                    "isnull(workphone,'') as workphone, " & _
                    "org_id " & _
                    "from contact " & _
                    "where Company_id in ('EITW004','ENNLAS05','UUAAESC','EUKADV','EFRA008','ENLA001','EHLC001','EHLA002','ACL') order by Company_id"
        
        ViewState("SqlCommand") = ""
        SqlDataSource1.SelectCommand = strSqlCmd
        ViewState("SqlCommand") = SqlDataSource1.SelectCommand
        If Not Page.IsPostBack Then
            sgv1.DataBind()
        End If
        ModalPopupExtender1.Show()
        up2.Update()
    End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub sgv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
        End If
    End Sub

    Protected Sub btnSelectID_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim lb As LinkButton = CType(sender, LinkButton)
        userid.Text = lb.Text
        fname.Text = CType(lb.NamingContainer, GridViewRow).Cells(2).Text
        lname.Text = CType(lb.NamingContainer, GridViewRow).Cells(3).Text
        userid.Text = CType(lb.NamingContainer, GridViewRow).Cells(4).Text
        Dim tel As String = "", tel_ext As String = ""
        If CType(lb.NamingContainer, GridViewRow).Cells(5).Text.Contains("&nbsp") Then
            tel = ""
        Else
            tel = CType(lb.NamingContainer, GridViewRow).Cells(5).Text
        End If
        If CType(lb.NamingContainer, GridViewRow).Cells(6).Text.Contains("&nbsp") Then
            tel_ext = ""
        Else
            tel_ext = CType(lb.NamingContainer, GridViewRow).Cells(6).Text
        End If
        tel_no.Text = tel + " " + tel_ext
        ModalPopupExtender1.Hide()
        up1.Update()
    End Sub
    
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender1.Hide()
        up2.Update()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server"> 
    <table width="100%" border="0" cellspacing="0" cellpadding="0" ID="Table1">
		<tr><td height="6"></td></tr>
		<tr>
			<td colspan="2" class="text_mini">&nbsp;&nbsp;
				<!-- **** Thread Bar ****-->
				<a href="/Admin/profile_admin.aspx?company_id=<%=session("company_id")%>&org_id=<%=strOrgId%>">Account Administration</a>
				&gt; <a href="/Admin/account_contact.aspx?company_id=<%=session("company_id")%>&org_id=<%=strOrgId%>">Contact Administration</a>
				&gt; Add New Contact
			</td>
		</tr>
		<tr >
			<td height="30" valign="middle">
				<br>
				<!-- ******* page title (start) ********-->
				<div class="euPageTitle">Contact Administration</div>
				<!-- ******* page title (end) ********-->
			</td>
			<td width="70%" valign=bottom>&nbsp;&nbsp;&nbsp;<span class="PageMessageBar"><asp:Label runat="Server" ID="LblMsg"></asp:Label></span></td>
		</tr>
		<tr>
			<td colspan="2" class="text" valign="top" align="left">
				<!-- **** Center Column : Main Part Start****-->
				<center>
					<br>
					<!-- **** input form start **** -->
						<span class="AppletStyle3">
						    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                <ContentTemplate>
                                    <asp:LinkButton runat="server" ID="link1" />
                                    <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" PopupControlID="Panel1" 
                                                 PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground" />
                                    <asp:Panel runat="server" ID="Panel1" style="display:none">
                                        <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <table width="650" height="550" border="0" cellpadding="0" cellspacing="0" bgcolor="f1f2f4">
                                                    <tr><td colspan="3" height="10">&nbsp</td></tr>
                                                    <%--<tr>
                                                        <td>
                                                            &nbsp;&nbsp;<font size="2">Company ID : </font><asp:TextBox runat="server" ID="txtCompanyID" />
                                                        </td>
                                                        <td>
                                                            <font size="2">User ID : </font><asp:TextBox runat="server" ID="txtUserID" />
                                                        </td>
                                                        <td>
                                                            <asp:Button runat="server" ID="btnSearch" Text="Search" />
                                                        </td>
                                                    </tr>--%>
                                                    <tr><td colspan="3" height="10">&nbsp</td></tr>
                                                    <tr>
                                                        <td colspan="3" valign="top" align="center">
                                                            <sgv:SmartGridView runat="server" ID="sgv1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="50"
                                                                 Width="97%" DataSourceID="SqlDataSource1" OnRowDataBoundDataRow="sgv1_RowDataBoundDataRow">
                                                                <Columns>
                                                                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                        <headertemplate>
                                                                            No.
                                                                        </headertemplate>
                                                                        <itemtemplate>
                                                                            <%# Container.DataItemIndex + 1 %>
                                                                        </itemtemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Company ID" SortExpression="company_id">
                                                                        <ItemTemplate>
                                                                            <asp:LinkButton runat="server" ID="btnSelectID" Text='<%# Eval("company_id") %>' OnClick="btnSelectID_Click" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField HeaderText="First Name" DataField="firstname" SortExpression="first_name" />
                                                                    <asp:BoundField HeaderText="Last Name" DataField="lastname" SortExpression="last_name" />
                                                                    <asp:BoundField HeaderText="User ID" DataField="userid" SortExpression="userid" />
                                                                    <asp:BoundField HeaderText="Tel No" DataField="workphone" />
                                                                    <asp:BoundField HeaderText="Sales Ord." DataField="ord_id" Visible="false" />
                                                                </Columns>
                                                                <FixRowColumn TableHeight="500" FixRowType="Header" FixColumns="-1" FixRows="-1" />
                                                                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                                                <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                                                                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                                                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                                            </sgv:SmartGridView>
                                                            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:My %>"
                                                                 SelectCommand="" OnLoad="SqlDataSource1_Load">
                                                            </asp:SqlDataSource>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center" colspan="3"><asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" /></td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </asp:Panel>
							        <table width="570" border="0" cellpadding="1" cellspacing="1">
								        <tr>
									        <td align="center" colspan="2" bgcolor="#b0c4de" height="30">
										        <b>Account&nbsp;Contact&nbsp;Information</b>
									        </td>
								        </tr>
								        <tr>
									        <td bgcolor="#dcdcdc" align="right" width="120">
										        <div class="mceLabel"><font color="red">*</font>User Id&nbsp;:&nbsp;</div>
									        </td>
									        <td bgcolor="#e6e6fa" class="mceLabel" align="left" valign="middle">											
										        <table border="0" cellpadding="0" cellspacing="0">
										            <tr>
										                <td>&nbsp;<asp:TextBox runat="server" ID="userid" size="50" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left" /></td>
										                <td><asp:ImageButton runat="server" ID="btnPickEmployee" ImageUrl="/Images/ebiz.aeu.face/btn_PickEmployee.GIF" OnClick="btnPickEmployee_Click" /></td>
										            </tr>
										        </table>
										    </td>
								        </tr>
								        <tr>
									        <td bgcolor="#dcdcdc" align="right" width="120">
										        <div class="mceLabel"><font color="red">*</font>First Name&nbsp;:&nbsp;</div>
									        </td>
									        <td bgcolor="#e6e6fa" class="mceLabel" align="left">
										        &nbsp;<asp:TextBox runat="server" ID="fname" size="20" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
									        </td>
								        </tr>
								        <tr>
									        <td bgcolor="#dcdcdc" align="right" width="120">
										        <div class="mceLabel"><font color="red">*</font>Last Name&nbsp;:&nbsp;</div>
									        </td>
									        <td bgcolor="#e6e6fa" class="mceLabel" align="left">
										        &nbsp;<asp:TextBox runat="server" ID="lname" size="20" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
									        </td>
								        </tr>
								        <tr>
									        <td bgcolor="#dcdcdc" align="right" width="120">
										        <div class="mceLabel"><font color="red">*</font>Phone&nbsp;:&nbsp;</div>
									        </td>
									        <td bgcolor="#e6e6fa" class="mceLabel" align="left">
										        &nbsp;<asp:TextBox runat="server" ID="tel_no" size="20" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
									        </td>
								        </tr>
								        <tr>
									        <td bgcolor="#dcdcdc" align="right" width="120">
										        <div class="mceLabel"><font color="red">*</font>Job Function&nbsp;:&nbsp;</div>
									        </td>
									        <td bgcolor="#e6e6fa" align="left">
										        <div class="mceLabel">
											        &nbsp;<asp:DropDownList runat="server" ID="job_function" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; width:150;text-align: left">
											                <asp:ListItem Value="" Text="---- Please Select ----"></asp:ListItem>
											                <asp:ListItem Value="Sales Assistant" Text="Sales Assistant"></asp:ListItem>
											                <asp:ListItem Value="Customer Service - BTOS" Text="Customer Service - BTOS"></asp:ListItem>
											                <asp:ListItem Value="Customer Service - RMA" Text="Customer Service - RMA"></asp:ListItem>
											                <asp:ListItem Value="Technical Support" Text="Technical Support"></asp:ListItem>
											                <asp:ListItem Value="Logistics" Text="Logistics"></asp:ListItem>
											                <asp:ListItem Value="Inside Sales Engineer" Text="Inside Sales Engineer"></asp:ListItem>
											                <asp:ListItem Value="Account/Channel Manager" Text="Account/Channel Manager"></asp:ListItem>
											                <asp:ListItem Value="Field Sales Engineer" Text="Field Sales Engineer"></asp:ListItem>
											                <asp:ListItem Value="Product Manager" Text="Product Manager"></asp:ListItem>
											                <asp:ListItem Value="Marketing" Text="Marketing"></asp:ListItem>
											                <asp:ListItem Value="Sales" Text="Sales"></asp:ListItem>
											                <asp:ListItem Value="OP" Text="OP"></asp:ListItem>
											              </asp:DropDownList>			
											    </div>
									        </td>
								        </tr>
								        <tr runat="server" id="trHidden" visible="false">
								            <td align="center" colspan="2">
								                <asp:TextBox runat="server" ID="company_id"></asp:TextBox>
										        <asp:TextBox runat="server" ID="org_id"></asp:TextBox>
										        <asp:TextBox runat="server" ID="action" Text="register"></asp:TextBox>
        										
										        <asp:TextBox runat="server" ID="EmptyFlag" Text="NO"></asp:TextBox>
									        </td>
								        </tr>
								        <tr>
									        <td align="center" colspan="2" bgcolor="#e6e6fa" valign="middle" height="35">
									        </td>
								        </tr>
							        </table>
							    </ContentTemplate>
							</asp:UpdatePanel>
						</span>
					<br>
										        <asp:Button runat="server" ID="Register" Text="Register New Contact" BackColor="SteelBlue" Font-Bold="True" ForeColor="White" OnClick="Register_Click" />
					
				</center>
				<!-- **** Center Column : Main Part End ****-->
			</td>
		</tr>
		<tr><td height="170"></td></tr>
	</table>
<script type="text/javascript" language="javascript">
function PickEmployee(xElement,xContent){
    //var xValue = new Array();
    var Url;
    //xValue = xElement.split("*");
    xContent='<%=strCompanyId%>'
    Url="../order/PickEmployee.aspx?Element=" + xElement + "&Type=&CompanyID=" + xContent;
    //alert (Url)
    window.open(Url, "pop","height=570,width=600,scrollbars=yes");
}
</script>
</asp:Content>