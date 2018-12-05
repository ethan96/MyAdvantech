<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Account Administration Update" %>

<script runat="server">

    Dim strSqlCmd As String, strUserId As String, strOrgId As String, strCompanyId As String, g_strMessage As String, flgError As String
    Dim strJobFunction As String = ""
    Dim strFirstName As String, strLastName As String
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim strFirstName, strLastName
        If Not Page.IsPostBack Then
            strUserId = Request("userid")
            strCompanyId = Request("company_id")
            Dim dt As New DataTable
            dt = dbUtil.dbGetDataTable("B2B", "select isnull(phone,'') as phone from company_contact where userid='" & strUserId & _
                                "' and Company_Id='" & strCompanyId & "'")
            If dt.Rows.Count > 0 Then
                Me.txtPhone.Text = dt.Rows(0).Item("phone")
            End If
            strOrgId = Request("org_id")
            g_strMessage = g_strMessage + " " + strOrgId & " / " & UCase(strCompanyId) & " "
        
       
            strSqlCmd = "select * from company_contact where userid ='" & strUserId & "'  and company_id='" & strCompanyId & "' and org_id='" & strOrgId & "'"
            'adoRs = g_adoConn.Execute(strSqlCmd)
            Using cn As New System.Data.SqlClient.SqlConnection
                Dim adoR As DataTable
                adoR = dbUtil.dbGetDataTable("B2B", Me.strSqlCmd)
                If Not adoR.Rows.Count > 0 Then
                    g_strMessage = g_strMessage + " User not found! "
                    flgError = "Yes"
                Else
                    'strUserId = adoRs("userid")
                    Me.txtUserId.Text = adoR.Rows(0).Item("userid")
                    Me.txtFirstName.Text = adoR.Rows(0).Item("first_name")
                    Me.txtLastName.Text = adoR.Rows(0).Item("last_name")
                    'strOrgId = adoRs("org_id")
                    'strCompanyId = adoRs("company_id")
                    'strFirstName = adoRs("first_name")
                    'strLastName = adoRs("last_name")
                    Try
                        strJobFunction = adoR.Rows(0).Item("job_function")
                    Catch ex As Exception
                        strJobFunction = ""
                    End Try
                    
                    If strJobFunction <> "" Then
                        Me.DropDownList1.SelectedItem.Text = strJobFunction
                    End If
                End If
            End Using
        End If
       
    End Sub

    Protected Sub ImageButton1_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        
        strUserId = Request("userid")
        strCompanyId = Request("company_id")
        strOrgId = Request("org_id")
        'g_strMessage = g_strMessage + " " + strOrgId & " / " & UCase(strCompanyId) & " "
        
        
        'flgError = "No"

        'If Request("email") = "" Then
        'strUserId = Request("userid")
        ' Else
        'strUserId = Request("email")
        ' End If

        ' If Request("action") = "update" Then
        ''==== validation ===='
        ' If flgError <> "Yes" Then
        If Me.DropDownList1.SelectedIndex <> 0 Then
            strSqlCmd = "update company_contact set " & _
               "job_function = '" & Me.DropDownList1.SelectedItem.Text & "', " & _
               "Phone='" & txtPhone.Text.Trim & "',AutoUpdate='No' " & _
               " where userid = '" & Request("userid") & "' and company_id='" & strCompanyId & "' and org_id='" & strOrgId & "'"
            'g_adoConn.Execute(strSqlCmd)
            dbUtil.dbExecuteNoQuery("B2B", Me.strSqlCmd)
		
            g_strMessage = g_strMessage + " Note: Update " & Request("userid") & " successfully! "
        Else
            g_strMessage = g_strMessage + " Note: Please select Job Function "
            Exit Sub
            ' End If
            'End If
        End If
        strSqlCmd = "select * from company_contact where userid ='" & strUserId & "'  and company_id='" & strCompanyId & "' and org_id='" & strOrgId & "'"
        'adoRs = g_adoConn.Execute(strSqlCmd)
        Using cn As New System.Data.SqlClient.SqlConnection
            Dim adoR As DataTable = dbUtil.dbGetDataTable("B2B", Me.strSqlCmd)
            If Not adoR.Rows.Count > 0 Then
                g_strMessage = g_strMessage + " User not found! "
                flgError = "Yes"
            Else
                strUserId = adoR.Rows(0).Item("userid")
                strOrgId = adoR.Rows(0).Item("org_id")
                strCompanyId = adoR.Rows(0).Item("company_id")
                strFirstName = adoR.Rows(0).Item("first_name")
                strLastName = adoR.Rows(0).Item("last_name")
                strJobFunction = adoR.Rows(0).Item("job_function")
            End If
        End Using
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">  
    <table width="100%" border="0" cellspacing="0" cellpadding="0" ID="Table1">
			<tr>
				<td colspan="3" class="text_mini">&nbsp;&nbsp; 
					<!-- **** Thread Bar ****-->
					<a href="/Admin/profile_admin.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>">Account Administration</a> 
					&gt; <a href="/Admin/account_contact.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>">Contact Administration</a>
					&gt; Update Contact Information
				</td>
			</tr>
			<tr valign="middle">
				<td colspan="3" height="30" class="title_big">
					<!-- **** Page Title ****-->
					<br>
					&nbsp;&nbsp;<img src="../images/title-dot.gif" width="25" height="17" >&nbsp;<font color="#3A4A8D">Contact 
						Administration</font>&nbsp;&nbsp;&nbsp;<span class="PageMessageBar"><%=g_strMessage%></span> 
				</td>
			</tr>
			<tr>
				<td colspan="3" class="text" valign="top" align="left">
					<!-- **** Center Column : Main Part Start****-->
					<center>
						<br>
						<!-- **** input form start **** -->
						<!--form name="register" action="<%=Request.ServerVariables("PATH_INFO")%>" method="post" onsubmit="return validate(this)"-->
							<span class="AppletStyle3">
								<table width="500" border="0" cellpadding="1" cellspacing="1">
									<tr>
										<td align="center" colspan="2" bgcolor="#b0c4de" height="30">
											<b>Contact&nbsp;Information&nbsp;</b>
										</td>
									</tr>
									<tr>
										<td  bgcolor=#dcdcdc align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>User Id&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											<div class="mceLabel">&nbsp;&nbsp;<asp:TextBox runat="server" ID="txtUserId" ReadOnly="true" size="50" style="background-color:#dddddd; font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left" /></div>
										</td>
									</tr>
									<tr>
										<td  bgcolor=#dcdcdc align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>First Name&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left"  >
											<div class="mceLabel">&nbsp;&nbsp;<asp:TextBox runat="server" ID="txtFirstName" ReadOnly="true" size="50" style="background-color:#dddddd; font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left" /></div>
										</td>
									</tr>
									<tr>
										<td  bgcolor=#dcdcdc align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Last Name&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left"  >
											<div class="mceLabel">&nbsp;&nbsp;<asp:TextBox runat="server" ID="txtLastName" ReadOnly="true" size="50" style="background-color:#dddddd; font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left" /></div>
										</td>
									</tr>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Job Function&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left"  >
											<div class="mceLabel">&nbsp;
                                                <asp:DropDownList ID="DropDownList1" runat="server" Width="176px">
                                                    <asp:ListItem>---- Please Select ----</asp:ListItem>
                                                    <asp:ListItem>Sales Assistant</asp:ListItem>
                                                    <asp:ListItem>Customer Service - BTOS</asp:ListItem>
                                                    <asp:ListItem>Customer Service - RMA</asp:ListItem>	
													<asp:ListItem>Technical Support</asp:ListItem>
													<asp:ListItem>Logistics</asp:ListItem>
													<asp:ListItem>Inside Sales Engineer</asp:ListItem>
													<asp:ListItem>Account/Channel Manager</asp:ListItem>
													<asp:ListItem>Field Sales Engineer</asp:ListItem>
													<asp:ListItem>Product Manager</asp:ListItem>
													<asp:ListItem>Marketing</asp:ListItem>
													<asp:ListItem>Sales</asp:ListItem>
													<asp:ListItem>OP</asp:ListItem>
                                                </asp:DropDownList></div>
										</td>
									</tr>
									<tr>
										<td  bgcolor=#dcdcdc align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Telephone&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left"  >
											<div class="mceLabel">&nbsp;&nbsp;<asp:TextBox runat="server" ID="txtPhone" size="50" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left" /></div>
										</td>
									</tr>
									
									<tr>
										<td align="center" colspan="2"  bgcolor="#dcdcdc" valign="middle" height="35">
                                            <asp:ImageButton ID="ImageButton1" runat="server" OnClick="ImageButton1_Click" ImageUrl="../images/ebiz.aeu.face/btn_update.gif" />
                                            &nbsp;
											<!--<input type="submit" value="Update" NAME="Submit" ID="Button2" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; width=100">-->
											
											
										</td>
									</tr>
								</table>
							</span>
						<!--/form-->
    
						<br>
					</center>
					<!-- **** Center Column : Main Part End ****--></td>
			</tr>
		</table>
</asp:Content>
