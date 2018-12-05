<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="User Profile Update" %>

<script runat="server">
    Dim strCompanyId As String = ""
    Dim strOrgId As String = ""
    Protected Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If Not MailUtil.IsInRole("MyAdvantech") And Not Util.IsAdmin() And Not Util.IsAEUUser() Then

                If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False And Not Util.IsAdmin() And Not Util.IsAccountAdmin() Then
                    Response.Redirect("/Admin/B2B_Admin_Portal.aspx")
                End If

            End If
            Dim RID As String = ""
            If Request("rid") = "" Then
                Util.JSAlert(Page, "Contact Row ID is needed.")
                Response.Redirect("Admin/Profile_Admin.aspx")
            Else
                RID = HttpUtility.HtmlDecode(Request("rid"))
            End If

            Me.strMsg.Text = ""
            If Not Page.IsPostBack Then
                If LCase(Session("USER_ID")) = Nothing Then
                    Response.Redirect("../login.aspx")
                Else
                    'Update按鈕送出後鎖定
                    UpdateUser.Attributes("onclick") = "this.disabled = true;this.value='Please wait...';" + Page.ClientScript.GetPostBackEventReference(UpdateUser, "")

                    strCompanyId = Request("company_id")
                    strOrgId = Session("RBU")
                    '--- 2006-06-01 Emil recover Org Id = AESC 
                    'strOrgId = "AESC"
                    Me.org_id.Text = strOrgId
                    Me.company_id.Text = strCompanyId
                    Dim xDataTable As New DataTable
                    '---- 2006-06-01 Emil 
                    Dim strSqlCmd As String
                    Dim UserID As String = ""
                    If Request("userid") = "" Then
                        UserID = Session("USER_ID")
                    Else
                        UserID = Request("userid").ToString.Replace("|", "+")
                    End If

                    Dim sb As New StringBuilder
                    With sb
                        .AppendFormat("select distinct A.ROW_ID, IsNull(A.FST_NAME, '') as firstname, IsNull(A.LAST_NAME, '') as lastname, ")
                        .AppendFormat("IsNull(A.EMAIL_ADDR, '') as userid, IsNull(E.ATTRIB_37, '') as job_function, IsNull(A.WORK_PH_NUM, '') as workphone, IsNull(A.CELL_PH_NUM, '') as cellphone, IsNull(A.FAX_PH_NUM, '') as faxnumber, ")
                        .AppendFormat("IsNull(A.SUPPRESS_EMAIL_FLG, 'N') as NeverEmail, IsNull(B.NAME, '') as Account, IsNull(C.COUNTRY, '') as Country, IsNull(A.JOB_TITLE, '') as job_title, ")
                        .AppendFormat("IsNull(D.ATTRIB_05, '') as company_id, (select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) as org_id, IsNull(E.ATTRIB_09, 0) as Can_Place_Order ")
                        .AppendFormat("FROM S_CONTACT A LEFT JOIN S_CONTACT_X E ON A.ROW_ID = E.ROW_ID LEFT JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID LEFT JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID LEFT JOIN S_ADDR_ORG C ON A.PR_OU_ADDR_ID = C.ROW_ID ")
                        .AppendFormat("WHERE (A.ROW_ID = A.PAR_ROW_ID) and A.ROW_ID='{0}'", RID)
                    End With
                    strSqlCmd = sb.ToString
                    'Response.Write(strSqlCmd)
                    xDataTable = dbUtil.dbGetDataTable("CRMDB75", strSqlCmd)
                    If xDataTable.Rows.Count >= 1 Then
                        'Try
                        hdnRowId.Value = xDataTable.Rows(0).Item("ROW_ID")
                        Me.UserId.Text = xDataTable.Rows(0).Item("userid")
                        Try
                            Me.FirstName.Text = xDataTable.Rows(0).Item("firstname")
                        Catch ex As Exception
                            Me.FirstName.Text = ""
                        End Try
                        Try
                            Me.LastName.Text = xDataTable.Rows(0).Item("lastname")
                        Catch ex As Exception
                            Me.LastName.Text = ""
                        End Try
                        'If Not IsDBNull(xDataTable.Rows(0).Item("user_type")) Then
                        '    ddlUserType.SelectedValue = xDataTable.Rows(0).Item("user_type")
                        'End If
                        Try
                            ddlJobFunction.DataBind()
                            ddlJobFunction.SelectedValue = xDataTable.Rows(0).Item("job_function")
                        Catch ex As Exception
                            'Me.job_function.SelectedValue = xDataTable.Rows(0).Item("job_function")
                        End Try
                        Try
                            txtJobTitle.Text = xDataTable.Rows(0).Item("job_title")
                        Catch ex As Exception
                            'Me.job_title.SelectedValue = xDataTable.Rows(0).Item("job_title")
                        End Try
                        Me.email.Text = xDataTable.Rows(0).Item("userid")
                        Try
                            Dim phone() As String = xDataTable.Rows(0).Item("workphone").ToString.Split(ControlChars.Lf)
                            If phone.Length > 0 Then tel.Text = phone(0)
                            Dim cell() As String = xDataTable.Rows(0).Item("cellphone").ToString.Split(ControlChars.Lf)
                            If cell.Length > 0 Then cellphone.Text = cell(0)
                            Dim faxs() As String = xDataTable.Rows(0).Item("faxnumber").ToString.Split(ControlChars.Lf)
                            If faxs.Length > 0 Then fax.Text = faxs(0)
                        Catch ex As Exception
                            'Me.tel.Text = xDataTable.Rows(0).Item("TEL_NO")
                            'Me.tel_ext.Text = xDataTable.Rows(0).Item("TEL_EXT")
                        End Try

                        Try
                            Me.txtAccount.Text = xDataTable.Rows(0).Item("Account")
                        Catch ex As Exception
                        End Try
                        Try
                            'If xDataTable.Rows(0).Item("Country").ToString.Trim <> "" Then
                            '    ddlCountry.DataBind()
                            '    'Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(country,'') as country from siebel_account where erp_id='{0}'", strCompanyId))
                            '    If Not IsDBNull(ddlCountry.SelectedValue) And ddlCountry.Items.FindByValue(xDataTable.Rows(0).Item("Country")) IsNot Nothing Then ddlCountry.SelectedValue = xDataTable.Rows(0).Item("Country")
                            'End If

                            'ICC 2018/5/10 Use SSO web service to get user profile for country data
                            ddlCountry.DataBind()
                            Dim sso As New ADWWW_Register.MembershipWebservice()
                            sso.UseDefaultCredentials = True : sso.Timeout = 500 * 1000
                            Dim profile As ADWWW_Register.SSOUSER = sso.getProfile(UserID, "My")
                            If profile IsNot Nothing AndAlso Not String.IsNullOrEmpty(profile.country) Then
                                Dim item As ListItem = ddlCountry.Items.FindByValue(profile.country)
                                If item IsNot Nothing Then
                                    ddlCountry.SelectedValue = profile.country
                                Else
                                    'If SSO didn't have this country, then automatically added this country in list
                                    Dim li As New ListItem(profile.country, profile.country)
                                    li.Selected = True
                                    ddlCountry.Items.Add(li)
                                End If
                            End If
                        Catch ex As Exception

                        End Try
                        Try
                            sqlInterestedProd_Load()
                            ddlInterestedProd.DataBind()
                            Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 NAME from SIEBEL_CONTACT_INTERESTED_PRODUCT where contact_row_id='{0}' order by primary_flag desc", RID))
                            If Not IsDBNull(ddlInterestedProd.SelectedValue) And ddlInterestedProd.Items.FindByValue(obj.ToString) IsNot Nothing Then ddlInterestedProd.SelectedValue = obj.ToString
                        Catch ex As Exception
                        End Try
                        Try
                            ddlBAA.DataBind()
                            Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 NAME from SIEBEL_CONTACT_BAA where contact_row_id='{0}' order by primary_flag desc", RID))
                            If Not IsDBNull(ddlBAA.SelectedValue) And ddlBAA.Items.FindByValue(obj.ToString) IsNot Nothing Then ddlBAA.SelectedValue = obj.ToString
                        Catch ex As Exception
                        End Try
                        Try
                            If UCase(xDataTable.Rows(0).Item("NeverEmail")) = "Y" Then
                                cbNEmail.Checked = True
                            End If
                        Catch ex As Exception

                        End Try

                        'Me.password.Text = xDataTable.Rows(0).Item("login_password")
                        'Me.password.Attributes("value") = xDataTable.Rows(0).Item("login_password")

                        'Me.confirm_password.Text = xDataTable.Rows(0).Item("login_password")
                        'Me.confirm_password.Attributes("value") = xDataTable.Rows(0).Item("login_password")



                        Me.strMsg.Text = strOrgId & "/" & UCase(strCompanyId)

                        '---- 2006-06-01 Emil remove If
                        '----If xDataTable.Rows(0).Item("ATTRI_VALUE") <> "Administrator" Then
                        'Response.Write (xDataTable.Rows(0).Item("ATTRI_VALUE"))
                        'Me.user_role.SelectedValue = dbUtil.dbExecuteScalar("My", "select a.rolename from contact_role_definition a left join contact_role b on a.roleid=b.roleid where b.userid='" + UserID + "'").ToString
                        '----End If

                        'Catch ex As Exception

                        'End Try
                        'Response.Write(xDataTable.Rows(0).Item("Can_Place_Order"))
                        'IIf(CType(xDataTable.Rows(0).Item("Can_Place_Order"), Boolean), Me.cbCanPlaceOrder.Checked = True, Me.cbCanPlaceOrder.Checked = False)
                        'If Boolean.TryParse(xDataTable.Rows(0).Item("Can_Place_Order"), 0) = True Then
                        '    Me.cbCanPlaceOrder.Checked = CBool(xDataTable.Rows(0).Item("Can_Place_Order"))
                        'Else
                        '    If LCase(xDataTable.Rows(0).Item("Can_Place_Order")) = "y" Then
                        '        cbCanPlaceOrder.Checked = True
                        '    Else
                        '        cbCanPlaceOrder.Checked = False
                        '    End If
                        'End If


                    End If

                    'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select a.ROW_ID, a.EMAIL_ADDR, c.NAME from S_CONTACT a inner join S_CONTACT_XM b on a.ROW_ID=b.PAR_ROW_ID inner join S_LST_OF_VAL c on b.NAME=c.ROW_ID where a.ROW_ID='{0}' and c.TYPE='CONTACT_MYADVAN_PVLG'", RID))
                    'ICC 2015/3/27 改成直接撈SIEBEL_CONTACT_PRIVILEGE 
                    Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select PRIVILEGE as [NAME] from SIEBEL_CONTACT_PRIVILEGE where ROW_ID = '{0}' ", RID))
                    If dt.Rows.Count > 0 Then
                        For Each row As DataRow In dt.Rows
                            If row.Item("NAME") = "Can See Order" Then cbCanSeeOrder.Checked = True
                            If row.Item("NAME") = "Can Place Order" Then cbCanPlaceOrder.Checked = True
                            If row.Item("NAME") = "View Cost" Then cbCanSeeCost.Checked = True
                            If row.Item("NAME") = "Account Admin" Then cbAccAdmin.Checked = True
                            If row.Item("NAME") = "Can See Project" Then cbCanSeePrj.Checked = True
                        Next
                    End If

                    'Ryan 20170425 If user email is not exists in SSO table then hide password rows
                    Dim SSOCount As Object = dbUtil.dbExecuteScalar("CP", String.Format("SELECT count(*) FROM [CurationPool].[dbo].[SSO_MEMBER] where email_addr = '{0}'", Me.email.Text))
                    If SSOCount IsNot Nothing AndAlso Integer.TryParse(SSOCount, 0) AndAlso Integer.Parse(SSOCount) = 0 Then
                        Me.trPW.Visible = False
                        Me.trPW2.Visible = False
                    End If
                End If
            End If
        Catch ex As Exception
            Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "User profile update error", ex.ToString, True, "", "")
        End Try

    End Sub


    Protected Sub UpdateUser_Click(sender As Object, e As System.EventArgs)
        If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False And Not Util.IsAdmin() And Not Util.IsAccountAdmin() And Not Util.IsAEUUser() Then
            Response.Redirect("/Admin/B2B_Admin_Portal.aspx")
            Exit Sub
        End If
        Dim flgError As String = ""
        Dim strSqlCmd As String
        strMsg.Text = ""
        'If Request("password") <> Request("confirm_password") And Request("password") <> "" Then
        '    Me.strMsg.Text = " Error: Password not match! "
        '    flgError = "Yes"
        'End If
        If tel.Text = "" Then strMsg.Text += "Work Phone field is required.<br/>" : Exit Sub
        If ddlCountry.SelectedValue = "" Then Util.AjaxJSAlert(up1, "Please select a country.") : Exit Sub
        If ddlInterestedProd.SelectedValue = "" Then Util.AjaxJSAlert(up1, "Please select an interested product.") : Exit Sub
        If ddlBAA.SelectedValue = "" Then Util.AjaxJSAlert(up1, "Please select a BAA.") : Exit Sub
        'If flgError <> "Yes" Then
        Dim NeverEmail As String ', NeverCall As String, NeverFax As String, NeverMail As String
        If cbNEmail.Checked Then
            NeverEmail = "Y"
        Else
            NeverEmail = "N"
        End If
        Try


            Dim ws1 As New ADWWW_Register.MembershipWebservice
            ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000
            'If password.Text.Trim <> "" Then
            '    Dim sso As New SSO.MembershipWebservice, Validated As Boolean = False
            '    Dim loginTicket As String = ""
            '    sso.Timeout = -1
            '    loginTicket = sso.login(UserId.Text.Trim, oldpassword.Text, "MY", Request.ServerVariables("REMOTE_ADDR"))
            '    If loginTicket <> "" And Not IsNothing(loginTicket) Then
            '        Me.strMsg.Text = " Note: Old password is incorrect!!"
            '        Exit Sub
            '    End If
            'End If

            'Dim siebel_ws As New aeu_eai2000.Siebel_WS
            'siebel_ws.UseDefaultCredentials = True
            'siebel_ws.Timeout = 300000
            'Dim BusObj As SiebelBusObjectInterfaces.SiebelBusObject = Nothing
            'Dim BusComp As SiebelBusObjectInterfaces.SiebelBusComp = Nothing
            'Dim errMsg As String = ""

            'Dim ret As Boolean = siebel_ws.UpdateContactInfoByMyAdvantechProfile_New(email.Text, Trim(FirstName.Text), Trim(LastName.Text), "", _
            '                                            ddlJobFunction.SelectedValue, Trim(txtJobTitle.Text), "", ddlCountry.SelectedValue, _
            '                                            Trim(tel.Text), Trim(cellphone.Text), Trim(fax.Text), password.Text, _
            '                                            NeverEmail, cbCanSeeOrder.Checked, cbCanPlaceOrder.Checked, cbAccAdmin.Checked, _
            '                                            cbCanSeeCost.Checked, ddlInterestedProd.SelectedValue, ddlBAA.SelectedValue)

            'Util.SendTestEmail("error", ret.ToString)

            Dim ret As Boolean = True

            'JJ 2015/3/16：必須有Siebel Contact ID
            If Not String.IsNullOrEmpty(hdnRowId.Value) Then
                Dim contact As Advantech.Myadvantech.DataAccess.SIEBEL_CONTACT
                contact = Advantech.Myadvantech.Business.SiebelBusinessLogic.GetSiebelContact(hdnRowId.Value)
                Dim ip As New List(Of String)
                ip.Add(ddlInterestedProd.SelectedValue)
                Dim baa As New List(Of String)
                baa.Add(ddlBAA.SelectedValue)

                If Not contact Is Nothing Then
                    'If Not String.IsNullOrEmpty(email.Text) Then contact.EMAIL_ADDRESS = email.Text ICC 2015/7/8 Exclude email
                    If Not String.IsNullOrEmpty(FirstName.Text) Then contact.FirstName = Trim(FirstName.Text)
                    If Not String.IsNullOrEmpty(LastName.Text) Then contact.LastName = Trim(LastName.Text)
                    If Not String.IsNullOrEmpty(ddlJobFunction.SelectedValue) Then contact.JOB_FUNCTION = ddlJobFunction.SelectedValue
                    If Not String.IsNullOrEmpty(txtJobTitle.Text) Then contact.JOB_TITLE = Trim(txtJobTitle.Text)
                    If Not String.IsNullOrEmpty(tel.Text) Then contact.WorkPhone = Trim(tel.Text)
                    If Not String.IsNullOrEmpty(fax.Text) Then contact.FaxNumber = Trim(fax.Text)
                    If Not String.IsNullOrEmpty(password.Text) Then contact.NeverEmail = NeverEmail
                    If Not IsNothing(ddlInterestedProd.SelectedValue) Then contact.InterestedProduct = ip.ToArray()
                    If Not IsNothing(ddlBAA.SelectedValue) Then contact.BAA = baa.ToArray()

                    ret = Advantech.Myadvantech.Business.SiebelBusinessLogic.UpdateSiebelContactByWS(contact)
                Else
                    ret = False
                End If
            Else
                ret = False
            End If

            If ret = True Then
                'ICC 2015/3/27 紀錄本次log到temp
                'If Not Me.WriteLogInPrivilegeTemp() Then Exit Sub
                Threading.Thread.Sleep(10000)
                Util.SyncContactFromSiebel(hdnRowId.Value)
                'ICC 2015/3/27 直接insert到SIEBEL_CONTACT_PRIVILEGE
                If Not Me.CreatePrivilege() Then Exit Sub

                dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact_baa where contact_row_id='{0}'", hdnRowId.Value))
                Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT [Contact Id] AS CONTACT_ROW_ID, [Biz. Application Area] AS [NAME], NULL  AS [PRIMARY_FLAG] FROM V_CONTACT_BAA WHERE [Contact Id] = '{0}' ", hdnRowId.Value))
                If dt.Rows.Count > 0 Then
                    Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                    BCopy.DestinationTableName = "SIEBEL_CONTACT_BAA"
                    BCopy.WriteToServer(dt)
                End If

                dbUtil.dbExecuteNoQuery("MY", String.Format("delete from SIEBEL_CONTACT_INTERESTED_PRODUCT where contact_row_id='{0}'", hdnRowId.Value))
                dt = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT c.ROW_ID as CONTACT_ROW_ID, a.NAME AS NAME, case a.ROW_ID when d.ATTRIB_35 then 1 else 0 end as PRIMARY_FLAG " + _
                        " FROM S_INDUST a INNER JOIN S_CONTACT_XM b ON a.ROW_ID = b.NAME  " + _
                        " INNER JOIN S_CONTACT c on b.PAR_ROW_ID=c.ROW_ID inner join S_CONTACT_X d on c.ROW_ID=d.ROW_ID " + _
                        " where not (c.EMAIL_ADDR is null) and c.EMAIL_ADDR like '%@%.%' and b.TYPE='Interested Product' " + _
                        " and c.ROW_ID='{0}' ", hdnRowId.Value))
                If dt.Rows.Count > 0 Then
                    Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                    BCopy.DestinationTableName = "SIEBEL_CONTACT_INTERESTED_PRODUCT"
                    BCopy.WriteToServer(dt)
                End If
                strMsg.Text += "Updated!!<br/>"
            Else
                'ICC 2015/6/5 Because Siebel web service is not going well, so we still have to update privillege.
                'WriteLogInPrivilegeTemp()
                CreatePrivilege()
                strMsg.Text += "Update Profile to Siebel Failed.<br/>"
            End If

            If password.Text.Trim <> "" AndAlso password.Text.Length >= 4 Then
                If confirm_password.Text <> password.Text Then strMsg.Text += "Confirm Password doesn't match New Password." : Exit Sub
                Dim retUpdPwd As Boolean = ws1.updProfileOnlyBasicInfo(UserId.Text.Trim, "My", Util.GetMD5Checksum(LCase(UserId.Text.Trim) + password.Text.Trim), tel.Text.Trim, "", ddlCountry.SelectedValue, "")
                If retUpdPwd = True Then
                    Dim sb As New StringBuilder
                    With sb
                        .AppendFormat("<html><table>")
                        .AppendFormat("<tr><td>Dears, </td></tr>")
                        .AppendFormat("<tr><td></td></tr>")
                        .AppendFormat("<tr><td>Your password is changed.</td></tr>")
                        .AppendFormat("<tr><td>You can login in <a href='http://my.advantech.com'>MyAdvantech</a> with this new password.</td></tr>")
                        .AppendFormat("<tr><td></td></tr>")
                        .AppendFormat("<tr><td><b>New password: {0}</b></td></tr>", password.Text.Trim)
                        .AppendFormat("<tr><td></td></tr>")
                        .AppendFormat("<tr><td>Best Regards</td></tr>")
                        .AppendFormat("<tr><td><a href='http://{0}'>MyAdvantech</a></td></tr>", Request.ServerVariables("HTTP_HOST").ToString)
                        .AppendFormat("</table></html>")
                    End With
                    Dim strTo As String = UserId.Text.Trim
                    If Not cbSend.Checked Then strTo = Session("user_id")
                    Util.SendEmail(strTo, "myadvantech@advantech.com", "Your MyAdvantech password is changed", sb.ToString, True, "", "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw,yl.huang@advantech.com.tw")
                    strMsg.Text += "Update password successfully."
                Else
                    strMsg.Text += "Update password failed."
                End If

            Else
                If password.Text.Length < 4 And password.Text.Trim <> "" Then
                    strMsg.Text += "Password length is needed to be larger than 4" : Exit Sub
                End If
            End If

            'dbUtil.dbExecuteNoQuery("My", String.Format("Update Contact set LOGIN_PASSWORD='{1}',FirstName='{2}',LastName='{3}'," + _
            '                                            "User_Type='{4}',JOB_FUNCTION='{5}',JOB_TITLE='{6}',Account='{7}',Country='{8}',WorkPhone='{9}'," + _
            '                                            "CellPhone='{10}',FaxNumber='{11}',NeverEmail='{12}',Can_Place_Order='{13}' where UserID='{0}'", _
            '                              UserId.Text, password.Text, Trim(FirstName.Text), Trim(LastName.Text), ddlUserType.SelectedValue, _
            '                              ddlJobFunction.SelectedValue, Trim(txtJobTitle.Text), txtAccount.Text, ddlCountry.SelectedValue, _
            '                              Trim(tel.Text), Trim(cellphone.Text), Trim(fax.Text), NeverEmail, IIf(Me.cbCanPlaceOrder.Checked, True, False)))

            'strSqlCmd = "update contact  set " & _
            '            "FirstName='" & Trim(FirstName.Text) & "', " & _
            '            "LastName='" & Trim(LastName.Text) & "', " & _
            '            "LOGIN_PASSWORD='" & password.Text & "', " & _
            '            "Can_Place_Order='" & IIf(Me.cbCanPlaceOrder.Checked, True, False) & "' " & _
            '            "where userid='" & Me.UserId.Text & "'"
            'dbUtil.dbExecuteNoQuery("My", strSqlCmd)

            'dbUtil.dbExecuteNoQuery("My", String.Format("update contact_role set roleid = (select roleid from contact_role_definition where rolename='{0}') where userid = '{1}'", user_role.SelectedValue, Me.UserId.Text))
            '---- Change value from 5 (Admin) to 1 (Buyer) ---'



            '---- 2006-06-01 Emil remark
            '----Session("USER_ROLE") = Me.user_role.SelectedValue

            'If LCase(Session("USER_ROLE")) = "administrator" Or LCase(Session("USER_ROLE")) = "logistics" Then
            '    Me.truser_role.Visible = True
            'Else
            '    Me.truser_role.Visible = False
            'End If
            'End If

            'Log
            Try
                Dim sb As New StringBuilder
                With sb
                    .AppendFormat("INSERT INTO ACCOUNT_ADMIN_LOG ")
                    .AppendFormat("(USER_ID,ACCOUNT_ID,TIMESTAMP,TYPE) ")
                    .AppendFormat(" VALUES (@USERID,@ACCOUNTID,@DATE,@TYPE)")
                End With
                Dim pUserID As New System.Data.SqlClient.SqlParameter("USERID", SqlDbType.NVarChar) : pUserID.Value = Session("user_id")
                Dim pAccountID As New System.Data.SqlClient.SqlParameter("ACCOUNTID", SqlDbType.NVarChar) : pAccountID.Value = HttpUtility.HtmlEncode(UserId.Text).Trim()
                Dim pDate As New System.Data.SqlClient.SqlParameter("DATE", SqlDbType.DateTime) : pDate.Value = Now.ToString
                Dim pType As New System.Data.SqlClient.SqlParameter("TYPE", SqlDbType.NVarChar) : pType.Value = "Update"
                Dim para() As System.Data.SqlClient.SqlParameter = {pUserID, pAccountID, pDate, pType}
                dbUtil.dbExecuteNoQuery2("My", sb.ToString, para)
            Catch ex As Exception

            End Try


            ' If Me.UserId.Text <> Me.email.Text Then
            ' Me.strMsg.Text = Me.strMsg.Text + " Warning: User Id is changed from " & Me.UserId.Text & " to " & Me.email.Text & "! """
            ' Else
            'Me.strMsg.Text += Me.strMsg.Text + " Note: Update " & Me.UserId.Text & " successfully! "
            'End If

            'End If

        Catch ex As Exception
            Me.strMsg.Text = ex.Message
        End Try

    End Sub

    Private Function CreatePrivilege() As Boolean
        dbUtil.dbExecuteNoQuery("MY", String.Format(" delete from SIEBEL_CONTACT_PRIVILEGE where row_id = '{0}' ", hdnRowId.Value))

        'Can See Order
        If cbCanSeeOrder.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Can See Order',GetDate(),'{2}') ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can See Order', 'Create', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text = "Error : Create Siebel contact privilege - [Can See Order] failed.<br />"
                Return False
            End Try
        End If

        'Can Place Order
        If cbCanPlaceOrder.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Can Place Order',GetDate(),'{2}') ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can Place Order', 'Create', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text += "Error : Create Siebel contact privilege - [Can Place Order] failed.<br />"
                Return False
            End Try
        End If

        'Account Admin
        If cbAccAdmin.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Account Admin',GetDate(),'{2}') ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Account Admin', 'Create', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text += "Error : Create Siebel contact privilege - [Account Admin] failed.<br />"
                Return False
            End Try
        End If

        'Can See Cost
        If cbCanSeeCost.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'View Cost',GetDate(),'{2}') ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'View Cost', 'Create', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text += "Error : Create Siebel contact privilege - [Can View Cost] failed.<br />"
                Return False
            End Try
        End If

        'Can See Project
        If cbCanSeePrj.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Can See Project',GetDate(),'{2}') ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text = "Error : Create contact privilege - [Can See Project] failed."
                Return False
            End Try
        End If
        Return True
    End Function

    Private Function WriteLogInPrivilegeTemp() As Boolean
        Try
            Dim priDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" select * from SIEBEL_CONTACT_PRIVILEGE where row_id = '{0}' ", hdnRowId.Value))
            If Not priDt Is Nothing AndAlso priDt.Rows.Count > 0 Then
                For Each dr As DataRow In priDt.Rows
                    Select Case dr.Item("PRIVILEGE").ToString()
                        Case "Can Place Order"
                            If Not cbCanPlaceOrder.Checked Then
                                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can Place Order', 'Remove', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            End If
                        Case "View Cost"
                            If Not cbCanSeeCost.Checked Then
                                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'View Cost', 'Remove', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            End If
                        Case "Can See Order"
                            If Not cbCanSeeOrder.Checked Then
                                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can See Order', 'Remove', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            End If
                        Case "Account Admin"
                            If Not cbAccAdmin.Checked Then
                                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Account Admin', 'Remove', '{2}', GETDATE()) ", hdnRowId.Value, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            End If
                    End Select
                Next
            End If
            Return True
        Catch ex As Exception
            strMsg.Text += "Error : Write Privilege temp failed.<br />"
            Return False
        End Try
    End Function

    Protected Sub sqlInterestedProd_Load()
        sqlInterestedProd.SelectCommand = "select '---- Please Select ----' as text, '' as value union select value ,text from SIEBEL_CONTACT_InterestedProduct_LOV " + IIf(Session("RBU") = "ABB", " where value like 'BB %' ", " where value not like 'BB %' ") + " order by value"
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>
            <table border="0" cellspacing="0" cellpadding="0" ID="Table1" style="width: 971px">
			<tr>
				<td colspan="3" style="width: 1291px; height: 14px;">
					<!-- **** Header ****-->
				</td>
			</tr>
			<tr>
				<td colspan="3" class="text_mini" style="width: 1291px; height: 13px;">&nbsp;&nbsp;
					<!-- **** Thread Bar ****-->
					<a href="profile_admin.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>">Account Administration</a>
					&gt;Update User Profile
				</td>
			</tr>
			<tr valign="middle">
				<td colspan="3" class="title_big" style="width: 1291px; height: 10px;">
					<br/>
					<!-- ******* page title (start) ********-->
					&nbsp;&nbsp;<font color="#000000" size="4">Update&nbsp;
						User &nbsp;
						Profile</font>&nbsp;&nbsp;&nbsp;
						<asp:Label runat="server" ID="strMsg" ></asp:Label>
					<!-- ******* page title (end) ********-->
					<p>
                        &nbsp;</p>
				</td>
			</tr>
			<tr>
				<td colspan="3" class="text" valign="top" align="left"  style="width: 1291px">
					<!-- **** Center Column : Main Part Start****-->
						
							    <asp:HiddenField runat="server" ID="hdnRowId" />
								<table width="570" border="0" cellpadding="1" cellspacing="1" style="background-color:#ffffff" align="left">
									<tr>
										<td align=center  colspan="2" bgcolor="#b0c4de" height="30">
											<b>User&nbsp;Profile&nbsp;</b>
										</td>
									</tr>
                                    <tr>
                                        <td align="right" bgcolor="#dcdcdc" style="height: 16px" width="120">
                                            <div class="mceLabel">
                                                <font color="red">*</font>User Id :&nbsp;</div>
                                        </td>
                                        <td align="left" bgcolor="#e6e6fa" style="height: 16px">
                                            <asp:TextBox ID="UserId" runat="server" Enabled="False" Width="280px"></asp:TextBox></td>
                                    </tr>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel">Name&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											&nbsp;First&nbsp;Name&nbsp;<asp:TextBox runat="server" ID="FirstName"></asp:TextBox>&nbsp;
											&nbsp;Last&nbsp;Name&nbsp;<asp:TextBox runat="server" ID="LastName"></asp:TextBox>
										</td>
									</tr>
									<%--<tr>
										<td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>User Type&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											<div class="mceLabel" align="left">
											&nbsp;<asp:DropDownList runat="server" ID="ddlUserType" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:300px;text-align: left">
					                                <asp:ListItem Value="" Text="---- Please Select ----" Selected="true" />
					                                <asp:ListItem Value="Employee" Text="Employee" />
					                                <asp:ListItem Value="Customer" Text="Customer" />
					                              </asp:DropDownList>
					                        </div>
										</td>
									</tr>--%>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Job Function&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" >
											<div class="mceLabel" align="left">
											&nbsp;<asp:DropDownList runat="server" ID="ddlJobFunction" 
                                                    AppendDataBoundItems="true" DataTextField="TEXT" DataValueField="VALUE"
						                                
                                                    
                                                    style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:300px;text-align: left">
					                                <asp:ListItem Value="" Text="---- Please Select ----" Selected="true" />
					                                <asp:ListItem>Advert Sales</asp:ListItem>
                                                    <asp:ListItem>Application Engineer</asp:ListItem>
                                                    <asp:ListItem>Business Management</asp:ListItem>
                                                    <asp:ListItem>Editor/Journalist</asp:ListItem>
                                                    <asp:ListItem>Facility Management</asp:ListItem>
                                                    <asp:ListItem>Hardware Development</asp:ListItem>
                                                    <asp:ListItem>Maintenance</asp:ListItem>
                                                    <asp:ListItem>Marketing</asp:ListItem>
                                                    <asp:ListItem>Product Manager</asp:ListItem>
                                                    <asp:ListItem>Project Management</asp:ListItem>
                                                    <asp:ListItem>Production</asp:ListItem>
                                                    <asp:ListItem>Publisher</asp:ListItem>
                                                    <asp:ListItem>Purchasing</asp:ListItem>
                                                    <asp:ListItem>RD Manager</asp:ListItem>
                                                    <asp:ListItem>Sales</asp:ListItem>
                                                    <asp:ListItem>Software Development</asp:ListItem>
                                                    <asp:ListItem>Technical Consultancy</asp:ListItem>
                                                    <asp:ListItem>Technical Management</asp:ListItem>
                                                    <asp:ListItem>Technical Support</asp:ListItem>
                                                    <asp:ListItem>Test &amp; Quality Assurance</asp:ListItem>
					                              </asp:DropDownList>
					                              <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString="<%$ connectionStrings:RFM %>" 
					                                    SelectCommand="select * from siebel_contact_jobfunction_lov order by value" />
											</div>
										</td>
									</tr>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel">Job Title&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											&nbsp;<asp:TextBox runat="server" ID="txtJobTitle" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; width:150px; text-align: left" />
										</td>
									</tr>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Email Address&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											<div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="email" Enabled="false" size="50" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
                                            </div> 
										</td>
									</tr>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120" style="height: 26px">
											<div class="mceLabel"><font color="red">*</font>WorkPhone&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" style="height: 26px" align="left" >
											&nbsp;<asp:TextBox runat="server" ID="tel" size="12" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
										</td>
									</tr>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120" style="height: 26px">
											<div class="mceLabel">CellPhone&nbsp;:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" style="height: 26px" align="left" >
											&nbsp;<asp:TextBox runat="server" ID="cellphone" size="12" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
										</td>
									</tr>
									<tr>
										<td bgcolor="#dcdcdc" align="right" width="120" style="height: 24px">
											<div class="mceLabel">&nbsp;Fax :&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" style="height: 24px" >
											&nbsp;<asp:TextBox runat="server" ID="fax" size="12" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
										</td>
									</tr>
									<tr>
						                <td bgcolor="#dcdcdc" align="right" width="120">
							                Account&nbsp;:&nbsp;
						                </td>
						                <td bgcolor="#e6e6fa" align="left" >
						                    &nbsp;<asp:TextBox runat="server" ID="txtAccount" Width="200" Enabled="false" />
						                </td>
					                </tr>
					                <tr>
						                <td bgcolor="#dcdcdc" align="right" width="120">
							                <div class="mceLabel">&nbsp;<font color="red">*</font>Country&nbsp;:&nbsp;</div>
						                </td>
						                <td bgcolor="#e6e6fa" align="left" >
						                    &nbsp;<asp:DropDownList runat="server" ID="ddlCountry" DataSourceID="SqlDataSource1" DataTextField="TEXT" DataValueField="VALUE" 
						                        style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:150px;text-align: left" AppendDataBoundItems="true">
					                        </asp:DropDownList>
					                        <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:MY %>"
					                            selectcommand="Select value ,text from siebel_account_country_lov order by value" />
						                </td>
					                </tr>
                                    <tr>
						                <td bgcolor="#dcdcdc" align="right" width="120">
							                <div class="mceLabel">&nbsp;<font color="red">*</font>Interested Product:&nbsp;</div>
						                </td>
						                <td bgcolor="#e6e6fa" align="left" >
						                    &nbsp;<asp:DropDownList runat="server" ID="ddlInterestedProd" DataSourceID="sqlInterestedProd" DataTextField="TEXT" DataValueField="VALUE" 
						                        style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:250px;text-align: left">
					                        </asp:DropDownList>
					                        <asp:SqlDataSource runat="server" ID="sqlInterestedProd" ConnectionString="<%$ connectionStrings:MY %>" 
					                            selectcommand="" />
						                </td>
					                </tr>
                                    <tr>
						                <td bgcolor="#dcdcdc" align="right" width="120">
							                <div class="mceLabel">&nbsp;<font color="red">*</font>BAA:&nbsp;</div>
						                </td>
						                <td bgcolor="#e6e6fa" align="left" >
						                    &nbsp;<asp:DropDownList runat="server" ID="ddlBAA" DataSourceID="sqlBAA" DataTextField="TEXT" DataValueField="VALUE" 
						                        style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:250px;text-align: left">
					                        </asp:DropDownList>
					                        <asp:SqlDataSource runat="server" ID="sqlBAA" ConnectionString="<%$ connectionStrings:MY %>"
					                            selectcommand="select '' as value, '---- Please Select ----' as text union select value ,text from SIEBEL_CONTACT_BAA_LOV order by value" />
						                </td>
					                </tr>
                                   <%-- <tr>
										<td bgcolor="#dcdcdc" align="right" width="120" style="height: 24px">
											<div class="mceLabel"><font color="red">*</font>&nbsp;Old Password :&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" style="height: 24px" >
											<div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="oldpassword" TextMode="Password"></asp:TextBox>
                                        </td>
									</tr>--%>
									<tr id="trPW" runat="server">
										<td bgcolor="#dcdcdc" align="right" width="120" style="height: 24px">
											<div class="mceLabel">&nbsp;New Password :&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" style="height: 24px" >
											<div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="password" TextMode="Password"></asp:TextBox>
                                        </td>
									</tr>
									<tr id="trPW2" runat="server">
										<td bgcolor="#dcdcdc" align="right" width="120" style="height: 24px">
											<div class="mceLabel">&nbsp;Confirm Password :&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" style="height: 24px" align="left" >
											<div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="confirm_password" TextMode="Password">111</asp:TextBox> 
                                                <asp:CompareValidator ID="CompareValidator1" runat="server" ErrorMessage="Error: Password not match!" ControlToCompare="password" ControlToValidate="confirm_password"></asp:CompareValidator></div>
										</td>
									</tr>
									<%--<tr runat="server" id="truser_role" visible="false">
										<td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel">&nbsp;User Role :&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											&nbsp;<asp:DropDownList runat="server" ID="user_role" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:150px;text-align: left">
											          <asp:ListItem Value="" Text="---- Please Select ----" Selected="True" ></asp:ListItem>
											          <asp:ListItem Value="Guest" Text="Guest" />
											          <asp:ListItem Value="Buyer" Text="Buyer" />
											          <asp:ListItem Value="Sales" Text="Sales" />
											          <asp:ListItem Value="Logistics" Text="Logistics" />
											      </asp:DropDownList>
											      <br />
										</td>
									</tr>--%>
                                    <tr>
									    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel">&nbsp;Can See Order :&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											&nbsp;<asp:CheckBox runat="server" ID="cbCanSeeOrder" />
										</td>
									</tr>
									<tr>
									    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel">&nbsp;Can Place Order :&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" align="left" >
											&nbsp;<asp:CheckBox runat="server" ID="cbCanPlaceOrder" />
										</td>
									</tr>
                                    <tr>
									    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel">&nbsp;Can See Cost:&nbsp;</div>
										</td>
										<td bgcolor="#e6e6fa" >
											&nbsp;<asp:CheckBox runat="server" ID="cbCanSeeCost" />
										</td>
									</tr>
									<tr>
						                <td bgcolor="#dcdcdc" align="right" width="120" style="height:24px">
						                    <div class="mceLabel">&nbsp;Never Email :&nbsp;</div>
						                </td>
						                <td bgcolor="#e6e6fa" align="left" style="height: 24px">
						                    &nbsp;<asp:CheckBox runat="server" ID="cbNEmail" />&nbsp;
						                    <%--Never&nbsp;Call&nbsp;<asp:CheckBox runat="server" ID="cbNCall" />&nbsp;
						                    Never&nbsp;Fax&nbsp;<asp:CheckBox runat="server" ID="cbNFax" />&nbsp;
						                    Never&nbsp;Mail&nbsp;<asp:CheckBox runat="server" ID="cbNMail" />&nbsp;--%>
						                </td>
					                </tr>
                                    <tr>
						                <td bgcolor="#dcdcdc" align="right" width="120" style="height:24px">
						                    <div class="mceLabel">&nbsp;Account Admin :&nbsp;</div>
						                </td>
						                <td bgcolor="#e6e6fa" align="left" style="height: 24px">
						                    &nbsp;<asp:CheckBox runat="server" ID="cbAccAdmin" />&nbsp;
						                    <%--Never&nbsp;Call&nbsp;<asp:CheckBox runat="server" ID="cbNCall" />&nbsp;
						                    Never&nbsp;Fax&nbsp;<asp:CheckBox runat="server" ID="cbNFax" />&nbsp;
						                    Never&nbsp;Mail&nbsp;<asp:CheckBox runat="server" ID="cbNMail" />&nbsp;--%>
						                </td>
					                </tr>
                                    <tr>
						                <td bgcolor="#dcdcdc" align="right" width="120" style="height:24px">
						                    <div class="mceLabel">&nbsp;Can See Project :&nbsp;</div>
						                </td>
                                        <td bgcolor="#e6e6fa" align="left" style="height: 24px">
                                            &nbsp;<asp:CheckBox runat="server" ID="cbCanSeePrj" />&nbsp;
                                        </td>
                                    </tr>
									<tr>
										<td align="center" colspan="2" bgcolor="#dcdcdc"  valign="middle" height="35">
											<asp:TextBox runat="server" ID="company_id" Visible="false"></asp:TextBox>
											<asp:TextBox runat="server" ID="org_id" Visible="false"></asp:TextBox>
											<asp:TextBox runat="server" ID="action" Visible="false" Text="register"></asp:TextBox>
											<%--<asp:ImageButton  runat="server" ID="UpdateUser" ImageUrl="~/Images/ebiz.aeu.face/btn_update.gif" OnClick="UpdateUser_Click" />--%>	
                                            <asp:Button ID="UpdateUser" runat="server" Text="Update" 
                                                OnClick="UpdateUser_Click" UseSubmitBehavior="False" />										
										    <asp:CheckBox runat="server" ID="cbSend" Text=" Send password changed email to customer" ForeColor="Red" />
                                        </td>
									</tr>
								</table>
				</td>
			</tr>
			<tr>
				<td colspan="3" style="height: 14px; width: 1291px;">
					<!-- **** Footer ****-->
				</td>
			</tr>
	</table>
        </ContentTemplate>
    </asp:UpdatePanel>
         <script type="text/javascript">
            

             //為解決在IE10中點擊updatepanel裡面的imagebutton時出現的錯誤
             Sys.WebForms.PageRequestManager.getInstance()._origOnFormActiveElement = Sys.WebForms.PageRequestManager.getInstance()._onFormElementActive;
             Sys.WebForms.PageRequestManager.getInstance()._onFormElementActive = function (element, offsetX, offsetY) {
                 if (element.tagName.toUpperCase() === 'INPUT' && element.type === 'image') {
                     offsetX = Math.floor(offsetX);
                     offsetY = Math.floor(offsetY);
                 }
                 this._origOnFormActiveElement(element, offsetX, offsetY);
             };
    </script>
</asp:Content>
