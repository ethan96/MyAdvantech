<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master" Title="My Profile" %>

<script runat="server">
 
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect(String.Format("http://member.advantech.com/profile.aspx?tempid={0}&id={1}&callbackurl=http://my.advantech.com/", Session("TempId"), Session("user_id")), False)
        If Not Page.IsPostBack Then
            Try
                If Session("user_id") Is Nothing Then Response.Redirect("~/home.aspx")
                Dim myProfile As New Contact(Session("user_id"))
                lblMsg.Text = Session("org_id") + "/" + Session("company_id")
                txtUserId.Text = Session("user_id")
                txtFirstName.Text = myProfile.FirstName
                txtLastName.Text = myProfile.LastName
                txtEmail.Text = Session("user_id")
                txtJobTitle.Text = myProfile.JOB_TITLE
                If Not IsDBNull(ddlUserType.SelectedValue) And ddlUserType.Items.FindByValue(myProfile.UserType) IsNot Nothing Then ddlUserType.SelectedValue = myProfile.UserType
                If Not IsDBNull(ddlJobFunction.SelectedValue) And ddlJobFunction.Items.FindByValue(myProfile.JOB_FUNCTION) IsNot Nothing Then ddlJobFunction.SelectedValue = myProfile.JOB_FUNCTION
                ddlCountry.DataBind()
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(country,'') as country from siebel_account where erp_id='{0}'", Session("company_id")))
                If obj IsNot Nothing Then If Not IsDBNull(ddlCountry.SelectedValue) And ddlCountry.Items.FindByValue(obj.ToString) IsNot Nothing Then ddlCountry.SelectedValue = obj.ToString
                txtAccount.Text = myProfile.Account
                If Not myProfile.WorkPhone Is Nothing Then
                    Dim phone() As String = myProfile.WorkPhone.Split(ControlChars.Lf)
                    If phone.Length > 0 Then txtWorkphone.Text = phone(0)
                End If
                If Not myProfile.CellPhone Is Nothing Then
                    Dim cell() As String = myProfile.CellPhone.Split(ControlChars.Lf)
                    If cell.Length > 0 Then txtCellphone.Text = cell(0)
                End If
                If Not myProfile.FaxNumber Is Nothing Then
                    Dim fax() As String = myProfile.FaxNumber.Split(ControlChars.Lf)
                    If fax.Length > 0 Then txtFax.Text = fax(0)
                End If
                
                'txtOldPwd.Text = myProfile.Password : txtOldPwd.Attributes("value") = myProfile.Password
                'txtNewPwd.Text = myProfile.Password : txtNewPwd.Attributes("value") = myProfile.Password
                'txtConfirmPassword.Text = myProfile.Password : txtConfirmPassword.Attributes("value") = myProfile.Password
                'txtUserRole.Text = ""
                If UCase(myProfile.NeverEmail) = "Y" Then
                    cbNEmail.Checked = True
                End If
                'If UCase(myProfile.NeverCall) = "Y" Then
                '    cbNCall.Checked = True
                'End If
                'If UCase(myProfile.NeverFax) = "Y" Then
                '    cbNFax.Checked = True
                'End If
                'If UCase(myProfile.NeverMail) = "Y" Then
                '    cbNMail.Checked = True
                'End If
                If myProfile.Row_ID <> "" Then
                
                Else
                    If Session("user_id") <> "rudy.wang@advantech.com.tw" Then trProduct.Visible = False
                End If
                Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select a.ROW_ID, a.EMAIL_ADDR, c.NAME from S_CONTACT a inner join S_CONTACT_XM b on a.ROW_ID=b.PAR_ROW_ID inner join S_LST_OF_VAL c on b.NAME=c.ROW_ID where a.ROW_ID='{0}' and c.TYPE='CONTACT_MYADVAN_PVLG'", myProfile.Row_ID))
                If dt.Rows.Count > 0 Then
                    For Each row As DataRow In dt.Rows
                        If row.Item("NAME") = "Can See Order" Then cbCanSeeOrder.Checked = True
                        If row.Item("NAME") = "Can Place Order" Then cbCanPlaceOrder.Checked = True
                    Next
                End If
            Catch ex As Exception
                Throw New Exception("MyProfile.aspx error:" + ex.ToString())
            End Try
            
        End If
        
    End Sub

    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim NeverEmail As String ', NeverCall As String, NeverFax As String, NeverMail As String
        If cbNEmail.Checked Then
            NeverEmail = "Y"
        Else
            NeverEmail = "N"
        End If
        'If cbNCall.Checked Then
        '    NeverCall = "Y"
        'Else
        '    NeverCall = "N"
        'End If
        'If cbNFax.Checked Then
        '    NeverFax = "Y"
        'Else
        '    NeverFax = "N"
        'End If
        'If cbNMail.Checked Then
        '    NeverMail = "Y"
        'Else
        '    NeverMail = "N"
        'End If
        
        'ming add for SSO
        Dim sso As New ADWWW_Register.MembershipWebservice, Validated As Boolean = False
        sso.Timeout = -1 : sso.Timeout = 500 * 1000
        Try
            
            If txtNewPwd.Text.Trim <> "" AndAlso txtNewPwd.Text.Length >= 4 Then
                If txtConfirmPassword.Text <> txtNewPwd.Text Then strMsg.Text = "Confirm Password doesn't match New Password." : Exit Sub
                sso.updProfileOnlyBasicInfo(txtUserId.Text, "My", Util.GetMD5Checksum(LCase(txtUserId.Text) + Trim(txtNewPwd.Text).Replace("'", "''")), txtWorkphone.Text.Trim.Replace("'", ""), "", ddlCountry.SelectedValue, "")
                'Dim p As New SSO.SSOUSER  'User_Type 'Account bunenggaibian 'WorkPhone  'CellPhone 'NeverEmail
                'With p
                '    .email_addr = txtUserId.Text
                '    .login_password = Trim(txtNewPwd.Text).Replace("'", "''")
                '    .first_name = Trim(txtFirstName.Text).Replace("'", "''")
                '    .last_name = Trim(txtLastName.Text).Replace("'", "''")
                '    .job_function = ddlJobFunction.SelectedValue
                '    .job_title = Trim(txtJobTitle.Text).Replace("'", "''")
                '    .country = ddlCountry.SelectedValue
                '    .fax_no = Trim(txtFax.Text).Replace("'", "''")
                '    .company_id = Session("company_id").ToString.Trim.ToUpper
                '    .erpid = Session("company_id").ToString.Trim.ToUpper
                'End With
                'Validated = sso.updProfile(p, "MY")
                Dim sb As New StringBuilder
                With sb
                    .AppendFormat("<html><table>")
                    .AppendFormat("<tr><td>Dears, </td></tr>")
                    .AppendFormat("<tr><td height='10'></td></tr>")
                    .AppendFormat("<tr><td>Your password is changed.</td></tr>")
                    .AppendFormat("<tr><td>You can login in <a href='http://my.advantech.com'>MyAdvantech</a> again with this new password.</td></tr>")
                    .AppendFormat("<tr><td></td></tr>")
                    .AppendFormat("<tr><td><b>New password: {0}</b></td></tr>", txtNewPwd.Text)
                    .AppendFormat("<tr><td height='10'></td></tr>")
                    .AppendFormat("<tr><td>Best Regards</td></tr>")
                    .AppendFormat("<tr><td><a href='http://{0}'>MyAdvantech</a></td></tr>", Request.ServerVariables("HTTP_HOST").ToString)
                    .AppendFormat("</table></html>")
                End With
                'Util.SendEmail(txtUserId.Text, "ebiz.aeu@advantech.eu", "Your MyAdvantech password is changed", sb.ToString, True, "", "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw")
            Else
                If txtNewPwd.Text.Length < 4 And txtNewPwd.Text.Trim <> "" Then
                    strMsg.Text = "Password length must be larger than 4" : Exit Sub
                End If
            End If
                
            Dim myProfile As New Contact(Page.User.Identity.Name)
            Dim siebel_ws As New aeu_eai2000.Siebel_WS
            If myProfile.Row_ID <> "" Then
                siebel_ws.UseDefaultCredentials = True
                siebel_ws.Timeout = 300000
                If Not Session("user_id").ToString.Contains("@advantech") Then
                    Dim ret As Boolean = siebel_ws.UpdateContactInfoByMyAdvantechProfile(txtUserId.Text, Trim(txtFirstName.Text), Trim(txtLastName.Text), ddlUserType.SelectedValue, _
                                                                ddlJobFunction.SelectedValue, Trim(txtJobTitle.Text), txtAccount.Text, ddlCountry.SelectedValue, _
                                                                Trim(txtWorkphone.Text), Trim(txtCellphone.Text), Trim(txtFax.Text), txtNewPwd.Text, _
                                                                NeverEmail, cbCanSeeOrder.Checked, cbCanPlaceOrder.Checked)
                    
                    If ret = True Then
                        Threading.Thread.Sleep(10000)
                        Util.SyncContactFromSiebel(myProfile.Row_ID)
                    End If
                End If
            End If
            
            Dim iRet1 As Integer = dbUtil.dbExecuteNoQuery("My", String.Format("Update Contact set LOGIN_PASSWORD='{1}',FirstName='{2}',LastName='{3}'," + _
                                                        "User_Type='{4}',JOB_FUNCTION='{5}',JOB_TITLE='{6}',Account='{7}',Country='{8}',WorkPhone='{9}'," + _
                                                        "CellPhone='{10}',FaxNumber='{11}',NeverEmail='{12}' where UserID='{0}'", _
                                          txtUserId.Text, Trim(txtNewPwd.Text).Replace("'", "''"), Trim(txtFirstName.Text).Replace("'", "''"), Trim(txtLastName.Text).Replace("'", "''"), ddlUserType.SelectedValue, _
                                          ddlJobFunction.SelectedValue, Trim(txtJobTitle.Text).Replace("'", "''"), txtAccount.Text, ddlCountry.SelectedValue, _
                                          Trim(txtWorkphone.Text).Replace("'", "''"), Trim(txtCellphone.Text).Replace("'", "''"), Trim(txtFax.Text).Replace("'", "''"), NeverEmail))
        
        
            Dim InterestedProd As New ArrayList
            For i = 0 To rb1.Items.Count - 1
                If rb1.Items(i).Selected = True Then
                    InterestedProd.Add(rb1.Items(i).Text)
                End If
            Next
            If InterestedProd.Count > 0 And myProfile.Row_ID <> "" Then siebel_ws.SubscribeProduct(Session("user_id"), String.Join("|", InterestedProd.ToArray(Type.GetType("System.String"))), True)
            'Dim str As String = String.Join("|", InterestedProd.ToArray(Type.GetType("System.String")))
            'If iRet1 > 0 Then
            '    Util.JSAlert(Me.Page, "Your profile has been updated.")
            'End If
            If iRet1 > 0 Then
                If Validated Then
                    Util.AjaxJSAlertRedirect(up1, "Your profile has been updated.", "/My/MyProfile.aspx")
                Else
                    Util.AjaxJSAlertRedirect(up1, "Your profile has been updated.", "/My/MyProfile.aspx")
                End If
           
            End If
        Catch ex As Exception
            ' Util.SendEmail("tc.chen@advantech.eu,nada.liu@advantech.com.cn,ming.zhao@advantech.com.cn", "ebiz.aeu@advantech.eu", "MyAdvan-Global: SSO Error Email: Update My Profile in the  MY/MyProfile.aspx", ex.ToString(), False, "", "")
        End Try
        'end     
        
    End Sub

    'Protected Sub btnSelectProd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    If Me.Panel1.Visible = False Then Me.Panel1.Visible = True Else Me.Panel1.Visible = False
    'End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", "select * from siebel_contact_jobfunction_lov order by value")
        'For i As Integer = 0 To dt.Rows.Count - 1
        '    If dt.Rows(i).Item(0).ToString() <> "" Then
        '        If ContainsChinese(dt.Rows(i).Item(0).ToString()) Then dt.Rows(i).Delete()
        '    Else
        '        dt.Rows(i).Delete()
        '    End If
        'Next
        'ddlJobFunction.DataSource = dt
        'ddlJobFunction.DataBind()
    End Sub
    
    Public Shared Function ContainsChinese(ByVal str As String) As Boolean
        Dim num1 As Integer = 0
        Dim num2 As Integer = 0
        Do
            num2 = Char.ConvertToUtf32(str, num1)
            If ((num2 >= CLng("&H4E00")) And (num2 <= CLng("&H9FFF"))) Then
                Return True
            End If
            num1 += 1
        Loop While (num1 < str.Length)
        Return False
    End Function
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">  
    <asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>
            <table border="0" cellspacing="0" cellpadding="0" ID="Table1" style="width: 100%">
		        <tr valign="middle">
			        <td colspan="3" class="title_big" style="width: 100%; height: 10px;">
				        <br/>
				        &nbsp;&nbsp;<font color="#000000" size="4">Update&nbsp;My&nbsp;Profile</font>&nbsp;&nbsp;&nbsp;
				        <asp:Label runat="server" ID="lblMsg" ></asp:Label>
				        <p>&nbsp;</p>
			        </td>
		        </tr>
		        <tr>
			        <td colspan="3" class="text" valign="top" align="left"  style="width: 100%">
				        <table width="620" border="0" cellpadding="1" cellspacing="1" style="background-color:#ffffff" align="left" >
					        <tr>
						        <td align=center  colspan="2" bgcolor="#b0c4de" height="30">
							        <b>My&nbsp;Profile&nbsp;</b>
						        </td>
					        </tr>
                            <tr>
                                <td align="right" bgcolor="#dcdcdc" style="height: 16px" width="120">
                                    <font color="red">*</font>User ID :&nbsp;
                                </td>
                                <td align="left" bgcolor="#e6e6fa" style="height: 16px">&nbsp;
                                    <asp:TextBox ID="txtUserId" runat="server" Enabled="False" Width="280px" />
                                </td>
                            </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Name&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
							        First&nbsp;Name&nbsp;<asp:TextBox runat="server" ID="txtFirstName" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"/>&nbsp;
							        &nbsp;Last&nbsp;Name&nbsp;<asp:TextBox runat="server" ID="txtLastName" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"/>
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height: 22px">
							        User Type&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa"  align=left style="height: 22px">&nbsp;
						            <asp:DropDownList runat="server" ID="ddlUserType" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:150px;text-align: left">
						                <asp:ListItem Value="" Text="---- Please Select ----" Selected="true" />
						                <asp:ListItem Value="Employee" Text="Employee" />
						                <asp:ListItem Value="Contact" Text="Contact" />
						            </asp:DropDownList>
						        </td>
					        </tr> 
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Job Function&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left">&nbsp;
						            <asp:DropDownList runat="server" ID="ddlJobFunction" AppendDataBoundItems="true" DataTextField="TEXT" DataValueField="VALUE"
						                style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:300px;text-align: left">
					                    <asp:ListItem Value="" Text="---- Please Select ----" Selected="true" />
					                    <asp:ListItem Value="Advert Sales" Text="Advert Sales" />
					                    <asp:ListItem Value="Application Engineer" Text="Application Engineer"></asp:ListItem>
					                    <asp:ListItem Value="Business Management" Text="Business Management"></asp:ListItem>
					                    <asp:ListItem Value="Buyer" Text="Buyer"></asp:ListItem>
					                    <asp:ListItem Value="Design Engineering" Text="Design Engineering"></asp:ListItem>
					                    <asp:ListItem Value="Editor/Journalist" Text="Editor/Journalist" />
					                    <asp:ListItem Value="Facility Management" Text="Facility Management"></asp:ListItem>
					                    <asp:ListItem Value="General Manager" Text="General Manager"></asp:ListItem>
					                    <asp:ListItem Value="Hardware Development" Text="Hardware Development"></asp:ListItem>
					                    <asp:ListItem Value="Maintenance" Text="Maintenance"></asp:ListItem>
						                <asp:ListItem Value="Marketing" Text="Marketing"></asp:ListItem>
						                <asp:ListItem Value="Product Development" Text="Product Development"></asp:ListItem>
						                <asp:ListItem Value="Production" Text="Production"></asp:ListItem>
						                <asp:ListItem Value="Project Management" Text="Project Management"></asp:ListItem>
						                <asp:ListItem Value="Publisher" Text="Publisher" />
						                <asp:ListItem Value="Purchasing" Text="Purchasing"></asp:ListItem>
						                <asp:ListItem Value="Sales" Text="Sales"></asp:ListItem>
						                <asp:ListItem Value="Software Development" Text="Software Development"></asp:ListItem>
						                <asp:ListItem Value="Tech / Service Support" Text="Tech / Service Support"></asp:ListItem>
						                <asp:ListItem Value="Technical Consultancy" Text="Technical Consultancy"></asp:ListItem>
						                <asp:ListItem Value="Technical Management" Text="Technical Management"></asp:ListItem>
						                <asp:ListItem Value="Technical Support" Text="Technical Support"></asp:ListItem>
						                <asp:ListItem Value="Test & Quality Assurance" Text="Test & Quality Assurance"></asp:ListItem>
						                <asp:ListItem Value="Others" Text="Others"></asp:ListItem>
					                </asp:DropDownList>
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Job Title&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
						            <asp:TextBox runat="server" ID="txtJobTitle" Width="200" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"/>
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        <font color="red">*</font>Email Address&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
							        <asp:TextBox runat="server" ID="txtEmail" Enabled="false" size="50" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
                                </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Account&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
						            <asp:TextBox runat="server" ID="txtAccount" Width="200" Enabled="false" />
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Country&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
						            <asp:DropDownList runat="server" ID="ddlCountry" DataSourceID="SqlDataSource1" DataTextField="TEXT" DataValueField="VALUE" 
						                style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:150px;text-align: left" AppendDataBoundItems="true">
					                    <asp:ListItem Value="" Text="---- Please Select ----" />
					                </asp:DropDownList>
					                <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:RFM %>"
					                    selectcommand="Select value ,text from siebel_account_country_lov order by value" />
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Work Phone&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
						            <asp:TextBox runat="server" ID="txtWorkphone" Width="200" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"/>
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Cell Phone&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
						            <asp:TextBox runat="server" ID="txtCellphone" Width="200" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"/>
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120">
							        Fax&nbsp;:&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" >&nbsp;
						            <asp:TextBox runat="server" ID="txtFax" Width="200" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"/>
						        </td>
					        </tr>
					        <%--<tr>
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height: 24px">
							        &nbsp;<font color="red">*</font>Old Password :&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" style="height: 24px" >
							        &nbsp;&nbsp;<asp:TextBox runat="server" ID="txtOldPwd" TextMode="Password"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="RequiredFieldValidator2" runat="server" ErrorMessage="Please input password!" ControlToValidate="txtOldPwd"></asp:RequiredFieldValidator>
						        </td>
					        </tr>--%>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height: 24px">
							        &nbsp;New Password :&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" style="height: 24px" >
							        &nbsp;&nbsp;<asp:TextBox runat="server" ID="txtNewPwd" TextMode="Password"></asp:TextBox>
                                    <%--<asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ErrorMessage="Please input password!" ControlToValidate="txtNewPwd"></asp:RequiredFieldValidator>--%>
						        </td>
					        </tr>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height: 24px">
							        &nbsp;Confirm Password :&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" style="height: 24px" align="left" >
							        &nbsp;&nbsp;<asp:TextBox runat="server" ID="txtConfirmPassword" TextMode="Password"></asp:TextBox> 
                                    <asp:CompareValidator ID="CompareValidator1" runat="server" ErrorMessage="Error: Password not match!" ControlToCompare="txtNewPwd" ControlToValidate="txtConfirmPassword"></asp:CompareValidator>
						        </td>
					        </tr>
					        <%--<tr>
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height:24px">
							        &nbsp;User Role :&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" style="height: 24px">&nbsp;
						            <asp:TextBox runat="server" ID="txtUserRole" Enabled="false" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left" />
						        </td>
					        </tr>--%>
					        <tr>
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height:24px">
						        </td>
						        <td bgcolor="#e6e6fa" align="left" style="height: 24px">&nbsp;
						            Never&nbsp;Email&nbsp;<asp:CheckBox runat="server" ID="cbNEmail" />&nbsp;
						            <%--Never&nbsp;Call&nbsp;<asp:CheckBox runat="server" ID="cbNCall" />&nbsp;
						            Never&nbsp;Fax&nbsp;<asp:CheckBox runat="server" ID="cbNFax" />&nbsp;
						            Never&nbsp;Mail&nbsp;<asp:CheckBox runat="server" ID="cbNMail" />&nbsp;--%>
						        </td>
					        </tr>
					        <tr runat="server" id="trProduct">
					            <td bgcolor="#dcdcdc" align="right" width="120" valign="top">
					                Interested&nbsp;Products&nbsp;:&nbsp;
					            </td>
					            <td bgcolor="#e6e6fa" align="left" valign="top" >
					                <b>Choose the one that best suits your needs</b>
					                <asp:RadioButtonList runat="server" ID="rb1" style="font-family: Arial; font-size: 8pt; width:100%; vertical-align:top; vertical-align:text-top" RepeatDirection="Vertical" RepeatColumns="2">
			                            <asp:ListItem Text="" Value="Automation Controllers & Software">Automation Controllers & Software<table><tr><td width="13"></td><td><font color="gray">Automation Software, Programmable Automation Controllers, Distributed Data Acquisition and Control Systems, Analog I/O Modules, Digital I/O Modules, Counter/Frequency Modules, Communication Modules</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Embedded Single Board Computers">Embedded Single Board Computers<table><tr><td width="13"></td><td><font color="gray">Embedded Single Board Computers (EBX, EPIC, 3.5”), Ruggedized Single Board Computers (-40 ~ 85∘C), x86 Single Board Computers (0 ~ 60∘C), PC/104 Modules, COM-Express/ETX/XTX, System on Module (SOM), RISC.</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Communication and Networking Platforms">Communication and Networking Platforms<table><tr><td width="13"></td><td><font color="gray">Blade Computing Platforms (CompactPCI, ATCA, AMC, uTCA), Network Appliance/Network Security Platforms</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Embedded Software Customization Service">Embedded Software Customization Service<table><tr><td width="13"></td><td><font color="gray">BIOS, Windows XP Embedded and CE Operating System Customization Service, Microsoft Embedded OS/ Oracle/ QNX/ VxWorks Operating System License</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Data Acquisition (DAQ) & Control">Data Acquisition (DAQ) & Control<table><tr><td width="13"></td><td><font color="gray">Industrial USB I/O Modules, PC/104 Data Acquisition & Control Modules, Motion Control I/O Modules, Data Acquisition Cards, Signal Conditioning Modules and Terminal Boards, CompactPCI System, PC-based Modular Industrial Controller</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Human Machine Interface & HMI Software">Human Machine Interface & HMI Software<table><tr><td width="13"></td><td><font color="gray">Industrial Panel Computers, Touch Panel Computers, Flat Panel Monitor, Industrial Workstations</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Display Panels and Panel Computers">Display Panels and Panel Computers<table><tr><td width="13"></td><td><font color="gray">6.4” to 17” Open Frame, LCD kits and Industrial grade Panel Monitors with LVDS/TTL Interface; 6.4” to 17” LCD Panel Computers, RISC-based Panel PC, Low Voltage and Fanless All-in-one Touch Computers, Ultra Slim Panel PC</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Industrial Communication">Industrial Communication<table><tr><td width="13"></td><td><font color="gray">Industrial Ethernet Switches, Media Converters, Serial Communication Cards, Serial Device Servers, Serial Converters and Repeaters</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Digital Signage Solutions">Digital Signage Solutions<table><tr><td width="13"></td><td><font color="gray">Digital Signage Servers, Digital Signage Displays, Digital Signage Software.</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Industrial Computers">Industrial Computers<table><tr><td width="13"></td><td><font color="gray">Rackmount and Wallmount Computer Systems, Mini ITX Systems, PICMG 1.0 /1.3 PCI/ISA Single Board Computers, Passive Backplane, Revision Control ATX / MicroATX / Mini ITX Motherboards</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Digital Video Card and Software">Digital Video Card and Software<table><tr><td width="13"></td><td><font color="gray">Video Capture Card, Surveillance Software</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Medical Computers">Medical Computers<table><tr><td width="13"></td><td><font color="gray">Medical-grade Computers, Patient Entertainment Systems, Medical-grade Tablet Computers</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Digital Video Recording Platforms">Digital Video Recording Platforms<table><tr><td width="13"></td><td><font color="gray">DVR Systems, Mobile Digital Video Surveillance Solutions, In-vehicle Video Recording Systems, MPEG4 Encoding Motherboard</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Mobile Computing">Mobile Computing<table><tr><td width="13"></td><td><font color="gray">Ruggedized Vehicle-mount Computers, Mobile Computers, Tablet Computers, Automatic Vehicle Locators</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Embedded Automation Computers">Embedded Automation Computers<table><tr><td width="13"></td><td><font color="gray">Embedded Din-Rail Computers, Embedded Panel Computers, Embedded Panel Computers with PCI Expansion</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Remote I/O">Remote I/O<table><tr><td width="13"></td><td><font color="gray">Ethernet I/O Modules, RS-485 I/O Modules</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Embedded Fanless Computers">Embedded Fanless Computers<table><tr><td width="13"></td><td><font color="gray">Fanless and Compact Embedded Systems, Low Voltage Embedded Computers, I/O Rich Ruggedized Embedded Computers, Expandable Embedded Systems</font></td></tr></table></asp:ListItem>
			                            <asp:ListItem Text="" Value="Smart Home Appliance">Smart Home Appliance<table><tr><td width="13"></td><td><font color="gray">Home Automation Systems, In-wall Touch Panel, Lighting Control Panel, Mobile Home Theater Control Panel, Residential Terminal with Handset and Camera</font></td></tr></table></asp:ListItem>
			                        </asp:RadioButtonList>
					            </td>
					        </tr>
                            <tr runat="server" visible="false">
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height:24px">
							        &nbsp;Can See Order :&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" style="height: 24px">&nbsp;
						            <asp:CheckBox runat="server" ID="cbCanSeeOrder" />
						        </td>
					        </tr>
					        <tr runat="server" visible="false">
						        <td bgcolor="#dcdcdc" align="right" width="120" style="height:24px">
							        &nbsp;Can Place Order :&nbsp;
						        </td>
						        <td bgcolor="#e6e6fa" align="left" style="height: 24px">&nbsp;
						            <asp:CheckBox runat="server" ID="cbCanPlaceOrder" />
						        </td>
					        </tr>
				        </table>
			        </td>
		        </tr>
		        <tr>
		            <td align="left">
           
                  <table align="left" width="47%"><tr><td align="right"> <asp:Button runat="server" ID="btnUpdate" Text="Update" OnClick="btnUpdate_Click" Font-Bold="True" /></td></tr></table>  
                    </td>
		        </tr>
                <tr>
                    <td align="center"><asp:Label runat="server" ID="strMsg" ForeColor="Red" ></asp:Label></td>
                </tr>
	        </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>