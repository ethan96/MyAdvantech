<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Register User" %>

<script runat="server">
    Dim strCompanyId As String = ""
    Dim strOrgId As String = ""
    Protected Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)

        If Not MailUtil.IsInRole("MyAdvantech") Then

            If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False And Not Util.IsAdmin() And Not Util.IsAccountAdmin() And Not Util.IsAEUUser() Then
                Response.Redirect("/Admin/B2B_Admin_Portal.aspx")
            End If

        End If

        strCompanyId = Request("company_id") : strOrgId = Session("RBU")
        Me.org_id.Text = strOrgId : Me.company_id.Text = strCompanyId

        If Not Page.IsPostBack Then
            Me.password.Text = CreateRandomPassword()
            Me.strCompany.Text = " " + strOrgId & " / " & UCase(strCompanyId) & " "

            If Request("id") IsNot Nothing AndAlso Request("id") <> "" Then
                email.Enabled = False
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select email_address, firstname, lastname, workphone, faxnumber, country from siebel_contact where row_id='{0}'", Request("id")))
                If dt.Rows.Count > 0 Then
                    With dt.Rows(0)
                        email.Text = .Item("email_address") : FirstName.Text = .Item("firstname") : LastName.Text = .Item("lastname")
                        txtPhone.Text = .Item("workphone") : txtFax.Text = .Item("faxnumber")
                        ddlCountry.DataBind()
                        If ddlCountry.Items.FindByValue(.Item("country")) IsNot Nothing Then ddlCountry.SelectedValue = .Item("country")
                    End With
                End If
                Dim AccDAL As New MYSIEBELTableAdapters.SIEBEL_ACCOUNTTableAdapter
                Dim dtAcc As MYSIEBEL.SIEBEL_ACCOUNTDataTable = AccDAL.GetAccountByERPID(strCompanyId)
                If dtAcc.Rows.Count > 0 Then
                    Dim row As MYSIEBEL.SIEBEL_ACCOUNTRow = dtAcc.Rows(0)
                    txtCity.Text = row.CITY
                End If
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 NAME from SIEBEL_CONTACT_INTERESTED_PRODUCT where contact_row_id='{0}' order by primary_flag desc", Request("id")))
                If obj IsNot Nothing Then
                    ddlInterestedProd.DataBind()
                    If ddlInterestedProd.Items.FindByValue(obj.ToString) IsNot Nothing Then ddlInterestedProd.SelectedValue = obj.ToString
                End If
                obj = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 NAME from SIEBEL_CONTACT_BAA where contact_row_id='{0}' order by primary_flag desc", Request("id")))
                If obj IsNot Nothing Then
                    ddlBAA.DataBind()
                    If ddlBAA.Items.FindByValue(obj.ToString) IsNot Nothing Then ddlBAA.SelectedValue = obj.ToString
                End If
            End If
        End If
    End Sub

    Protected Sub RegisterNewUser_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False And Not Util.IsAdmin() And Not Util.IsAccountAdmin() And Not Util.IsAEUUser() Then
            Response.Redirect("/Admin/B2B_Admin_Portal.aspx")
            Exit Sub
        End If
        'If Not Util.IsValidEmailFormat(email.Text) Then Me.strMsg.Text = Me.strMsg.Text + " Error : Email format is not valid." : Exit Sub
        strMsg.Text = ""
        If ddlCountry.SelectedValue = "" Then Util.AjaxJSAlert(up1, "Please select a country.") : Exit Sub
        If ddlInterestedProd.SelectedValue = "" Then Util.AjaxJSAlert(up1, "Please select an interested product.") : Exit Sub
        If ddlBAA.SelectedValue = "" Then Util.AjaxJSAlert(up1, "Please select a BAA.") : Exit Sub
        If Not Util.IsValidEmailFormat(email.Text) Then Util.AjaxJSAlert(up1, "Email is not a valid format.") : Exit Sub
        If Request("action") = "register" Or Me.action.Text = "register" Then
            Dim strSqlCmd As String = "", xDataTable1 As DataTable, flgError As String = "", is_Siebel_Acc As Boolean = False
            If flgError <> "Yes" Then
                If Util.IsInternalUser(email.Text.Trim) Then strMsg.Text = "Advantech employees can login MyAdvantech with their employee zone’s ID/password. No need to register again on MyAdvantech. Thank you." : Exit Sub
                Dim account_name As String = "", account_row_id As String = "", erpid As String = "", country As String = "", city As String = "", zip As String = "", address As String = "", state As String = ""
                Dim dtAccount As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 a.ROW_ID, isnull(a.ACCOUNT_NAME,'') as ACCOUNT_NAME, isnull(a.ERP_ID,'') as ERP_ID, isnull(a.COUNTRY,'') as COUNTRY, isnull(a.CITY,'') as CITY, isnull(a.ZIPCODE,'') as ZIPCODE, isnull(a.ADDRESS,'') as ADDRESS, isnull(a.STATE,'') as STATE from SIEBEL_ACCOUNT a where a.ERP_ID='{0}'", Request("company_id")))

                If dtAccount.Rows.Count > 0 Then
                    For Each row As DataRow In dtAccount.Rows
                        If row.Item("ACCOUNT_NAME") <> "" Then
                            account_name = row.Item("ACCOUNT_NAME") : account_row_id = row.Item("ROW_ID") : erpid = row.Item("ERP_ID")
                            country = row.Item("COUNTRY") : city = row.Item("CITY") : zip = row.Item("ZIPCODE") : state = row.Item("STATE") : address = row.Item("ADDRESS")
                            Exit For
                        End If
                    Next
                End If

                'Dim ws As New aeu_eai2000.Siebel_WS
                'ws.UseDefaultCredentials = True : ws.Timeout = 500 * 1000
                Dim ws1 As New ADWWW_Register.MembershipWebservice
                ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000

                Try
                    strSqlCmd = "select * FROM S_CONTACT A where upper(A.EMAIL_ADDR) ='" & Trim(Me.email.Text.ToUpper()) & "' "
                    xDataTable1 = dbUtil.dbGetDataTable("CRMDB75", strSqlCmd)
                    Dim row_id As String = ""
                    If xDataTable1.Rows.Count >= 1 Then 'user is in Siebel
                        'Me.strMsg.Text = Me.strMsg.Text + " Error: User already exists."
                        row_id = xDataTable1.Rows(0).Item("ROW_ID").ToString
                        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select A.ROW_ID FROM S_CONTACT A INNER JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID INNER JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID where upper(A.EMAIL_ADDR) = '{0}'", email.Text.ToUpper()))
                        If dt.Rows.Count > 0 Then 'user is in Siebel and map an account row id
                            is_Siebel_Acc = True
                        Else 'user is in Siebel but not map an account row id
                            'ws.UpdateContactInfoByMyAdvantechProfile_New(email.Text, Trim(FirstName.Text.Replace("'", "").Trim), Trim(LastName.Text.Replace("'", "").Trim), "", _
                            '                                    "", "", account_row_id, country, _
                            '                                    txtPhone.Text.Replace("'", "").Trim, "", txtFax.Text.Replace("'", "").Trim, password.Text, _
                            '                                    "", cbCanSeeOrder.Checked, cbCanPlaceOrder.Checked, cbAccAdmin.Checked, cbCanSeeCost.Checked, ddlInterestedProd.SelectedValue, ddlBAA.SelectedValue)
                            'Threading.Thread.Sleep(10000)
                            'ICC 2015/3/27 改用API & 新Siebel WS進行update Contact
                            Dim ip As New List(Of String)
                            ip.Add(ddlInterestedProd.SelectedValue)
                            Dim baa As New List(Of String)
                            baa.Add(ddlBAA.SelectedValue)
                            Dim contact As New Advantech.Myadvantech.DataAccess.SIEBEL_CONTACT()
                            With contact
                                .ROW_ID = row_id
                                '.EMAIL_ADDRESS = email.Text ICC 2015/7/8 Exclude email
                                .FirstName = Trim(FirstName.Text.Replace("'", "").Trim)
                                .LastName = Trim(LastName.Text.Replace("'", "").Trim)
                                .USER_TYPE = String.Empty
                                .JOB_FUNCTION = String.Empty
                                .JOB_TITLE = String.Empty
                                .ACCOUNT_ROW_ID = account_row_id
                                .COUNTRY = country
                                .WorkPhone = txtPhone.Text.Replace("'", "").Trim
                                .CellPhone = String.Empty
                                .FaxNumber = txtFax.Text.Replace("'", "").Trim
                                .Password = password.Text
                                .NeverEmail = String.Empty
                                .InterestedProduct = ip.ToArray()
                                .BAA = baa.ToArray()
                            End With
                            Dim result As Boolean = Advantech.Myadvantech.Business.SiebelBusinessLogic.UpdateSiebelContactByWS(contact)
                            If Not result Then
                                strMsg.Text = "Error : Update Siebel contact failed."
                                Exit Sub
                            End If

                            'ICC 2015/3/27 Remove Privilege and Privilege_Temp
                            'Dim priDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" select * from SIEBEL_CONTACT_PRIVILEGE where row_id = '{0}' ", row_id))
                            'If Not priDt Is Nothing AndAlso priDt.Rows.Count > 0 Then
                            '    For Each dr As DataRow In priDt.Rows
                            '        Select Case dr.Item("PRIVILEGE").ToString()
                            '            Case "Can Place Order"
                            '                If Not cbCanPlaceOrder.Checked Then
                            '                    dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can Place Order', 'Remove', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            '                End If
                            '            Case "View Cost"
                            '                If Not cbCanSeeCost.Checked Then
                            '                    dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'View Cost', 'Remove', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            '                End If
                            '            Case "Can See Order"
                            '                If Not cbCanSeeOrder.Checked Then
                            '                    dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can See Order', 'Remove', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            '                End If
                            '            Case "Account Admin"
                            '                If Not cbAccAdmin.Checked Then
                            '                    dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Account Admin', 'Remove', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                            '                End If
                            '        End Select
                            '    Next
                            'End If

                            Util.SyncContactFromSiebel(row_id)
                            If ws1.isExist(LCase(email.Text.Trim), "My") = True Then 'user is in Siebel and SSO
                                ws1.updProfileOnlyBasicInfo(email.Text.Trim, "My", Util.GetMD5Checksum(LCase(email.Text.Trim) + password.Text.Trim), txtPhone.Text.Replace("'", "").Trim, "", country, "")
                            End If

                            'ICC 2018/5/10 Update contact's BAA and interested product data from Siebel DB
                            SyncContactInPrdAndBAA(row_id)

                            'ICC 2015/3/27 Create Privilege and Privilege_Temp
                            If Not Me.CreatePrivilege(row_id) Then
                                Exit Sub
                            End If

                        End If
                    Else 'user is not in Siebel
                        Dim phone As String = txtPhone.Text.Replace("'", "").Trim
                        Dim AreaCode As String = ""
                        Dim objAreaCode As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(AREA_CODE,'') from [CurationPool].[dbo].[COUNTRY_AREACODE] where country_name='{0}' or ISO_COUNTRY_CODE like '%{0}%'", country))
                        If objAreaCode IsNot Nothing AndAlso objAreaCode <> "" Then AreaCode = objAreaCode.ToString
                        phone = "+" + AreaCode + phone

                        'Dim row_id As String = ws.CreateMyAdvantechProfile(email.Text.Trim.Replace("'", ""), account_row_id, FirstName.Text.Replace("'", "").Trim, LastName.Text.Replace("'", "").Trim, cbCanSeeOrder.Checked, cbCanPlaceOrder.Checked, "", phone, cbAccAdmin.Checked, cbCanSeeCost.Checked, ddlInterestedProd.SelectedValue, ddlBAA.SelectedValue)
                        'ICC 2015/3/27 改用API & 新Siebel WS進行新增Contact
                        Dim ip As New List(Of String)
                        ip.Add(ddlInterestedProd.SelectedValue)
                        Dim baa As New List(Of String)
                        baa.Add(ddlBAA.SelectedValue)
                        Dim contact As New Advantech.Myadvantech.DataAccess.SIEBEL_CONTACT()
                        With contact
                            .ACCOUNT_ROW_ID = account_row_id
                            .EMAIL_ADDRESS = email.Text.Trim.Replace("'", "")
                            .FirstName = FirstName.Text.Replace("'", "").Trim
                            .LastName = LastName.Text.Replace("'", "").Trim
                            .JOB_TITLE = String.Empty
                            .WorkPhone = phone
                            .FaxNumber = String.Empty
                            .InterestedProduct = ip.ToArray()
                            .BAA = baa.ToArray()
                        End With
                        row_id = Advantech.Myadvantech.Business.SiebelBusinessLogic.CreateSiebelContactByWS(contact)
                        If String.IsNullOrEmpty(row_id) Then
                            strMsg.Text = "Error : Create Siebel contact failed."
                            Exit Sub
                        End If

                        'Dim row_id As String = ws.CreateNewContact_New(email.Text.Trim.Replace("'", ""), account_row_id, FirstName.Text.Trim, LastName.Text.Trim, cbCanSeeOrder.Checked, cbCanPlaceOrder.Checked, "", txtPhone.Text.Trim, cbAccAdmin.Checked, cbCanSeeCost.Checked)
                        Dim count As Integer = 0
                        Do While CInt(dbUtil.dbExecuteScalar("CRMDB75", String.Format("select count(A.EMAIL_ADDR) FROM S_CONTACT A where upper(A.EMAIL_ADDR) ='{0}'", email.Text.ToUpper().Trim))) = 0
                            Threading.Thread.Sleep(10000)
                            count += 1
                            If count > 15 Then strMsg.Text = "Error : Create Siebel contact failed." : Exit Do
                        Loop
                        Util.SyncContactFromSiebel(row_id)

                        'ICC 2018/5/10 Update contact's BAA and interested product data from Siebel DB
                        SyncContactInPrdAndBAA(row_id)

                        'ICC 2015/3/27 Create Privilege and Privilege_Temp
                        If Not Me.CreatePrivilege(row_id) Then
                            Exit Sub
                        End If
                    End If

                    'ws.Abort()
                Catch ex As Exception
                    Throw New Exception("User_Profile.aspx error:" + ex.ToString())
                End Try

                If ws1.isExist(LCase(email.Text.Trim), "My") = True Then 'user is in SSO
                    If is_Siebel_Acc = True Then 'user is in Siebel with mapping an account row id and in SSO 
                        Me.strMsg.Text = Me.strMsg.Text + " Error : User already exists." : Exit Sub
                    Else
                        'ICC 2015/8/6 Remind user's account is already in SSO, so he/she can login by his/her account and password.
                        Me.strMsg.Text = Me.strMsg.Text + " Note: User already exists, please use his or her own account and password to login." : Exit Sub
                    End If
                Else
                    Dim p As New ADWWW_Register.SSOUSER
                    With p
                        p.company_id = erpid : p.erpid = erpid
                        p.email_addr = email.Text.Trim
                        p.login_password = password.Text.Trim 'Util.GetMD5Checksum(LCase(email.Text.Trim) + "|" + password.Text.Trim)
                        p.AccountID = account_row_id : p.company_name = account_name
                        p.first_name = FirstName.Text.Replace("'", "").Trim : p.last_name = LastName.Text.Replace("'", "").Trim
                        p.tel_no = txtPhone.Text.Replace("'", "").Trim
                        p.country = ddlCountry.SelectedValue
                        p.source = "mya" : p.city = txtCity.Text.Replace("'", "").Trim : p.state = state : p.zip = zip : p.address = address
                        p.business_application_area = ddlBAA.SelectedValue : p.in_product = ddlInterestedProd.SelectedValue
                    End With
                    Dim ret As String = ws1.register("My", p)
                    If ret = "" Then
                        Me.strMsg.Text = Me.strMsg.Text + " System Error: Register " & Request("email") & " failed! "
                    Else
                        If CInt(dbUtil.dbExecuteScalar("CP", String.Format("select count(*) from SSO_MEMBER where EMAIL_ADDR = '{0}'", email.Text))) = 0 Then
                            dbUtil.dbExecuteNoQuery("CP", String.Format("insert into SSO_MEMBER (EMAIL_ADDR,USER_STATUS) values ('{0}',1)", email.Text))
                        End If
                        Dim l_strHTML As String = ""
                        l_strHTML = l_strHTML & "<html xmlns=""http://www.w3.org/1999/xhtml"">"
                        l_strHTML = l_strHTML & "<body><table  width=""900"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font-family:Arial Unicode MS""><tr><td>"
                        l_strHTML = l_strHTML & "<img alt='' src='http://" + Request.ServerVariables("HTTP_HOST").ToString + "/Images/logo2.jpg' /><br/></td>"
                        l_strHTML = l_strHTML & "</tr><tr><td>"
                        l_strHTML = l_strHTML & "Dear <b>" & Trim(Me.FirstName.Text) & "&nbsp;" & Trim(Me.LastName.Text) & "</b>,</td>"
                        l_strHTML = l_strHTML & "</tr><tr><td>"
                        l_strHTML = l_strHTML & "Welcome to MyAdvantech. Through this portal you can access <b>personal content</b> and Advantech <b>Product/Sales/MarketingTools, eRMA & Support, and B2B online procurement</b> easily with the least effort."
                        l_strHTML = l_strHTML & "</td></tr>"
                        l_strHTML = l_strHTML & "<tr><td height=""50"">"
                        l_strHTML = l_strHTML & "Your login information for&nbsp;MyAdvantech is as follows:</td>"
                        l_strHTML = l_strHTML & "</tr>"
                        l_strHTML = l_strHTML & "<tr><td>"
                        l_strHTML = l_strHTML & "<table style="" width: 80.0%;background: silver;font-family:Arial Unicode MS"" border=""0"" cellspacing=""0""  cellpadding=""0"">"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""width: 150px ;background: #EEEEEE;border-right:solid 1px #cccccc"">ID(Email Address):</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(Me.email.Text) & "</span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #D9D9D9;border-right:solid 1px #cccccc"">Password:</td> <td style=""background: #D9D9D9""><span style=""color:navy""> &nbsp;" & Trim(Me.password.Text) & "</span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">First Name:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(Me.FirstName.Text) & "</span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #D9D9D9;border-right:solid 1px #cccccc"">Last Name:</td><td style=""background: #D9D9D9""><span style=""color:navy""> &nbsp;" & Trim(Me.LastName.Text) & "</span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Phone No:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(Me.txtPhone.Text) & "</span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #D9D9D9;border-right:solid 1px #cccccc"">Fax No:</td><td style=""background: #D9D9D9""><span style=""color:navy""> &nbsp;" & Trim(Me.txtFax.Text) & "</span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Account Name:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & account_name & " </span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Country:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & ddlCountry.SelectedValue & " </span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Interested Product:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & ddlInterestedProd.SelectedValue & " </span></td></tr>"
                        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">BAA:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & ddlBAA.SelectedValue & " </span></td></tr>"
                        l_strHTML = l_strHTML & "</table></td></tr> <tr><td>"
                        l_strHTML = l_strHTML & "At the MyAdvantech "
                        l_strHTML = l_strHTML & "<a href=""http://" + Request.ServerVariables("HTTP_HOST").ToString + "/Login.aspx?ReturnUrl=%2fhome.aspx"" "
                        l_strHTML = l_strHTML & "title=""http://my.advantech.com/""><span style=""color:#000099"">login</span></a> "
                        l_strHTML = l_strHTML & "page, enter the ID and password provided above for the first login. Afterwards, "
                        l_strHTML = l_strHTML & "you can change the password by updating your user "
                        l_strHTML = l_strHTML & "<a href=""http://" + Request.ServerVariables("HTTP_HOST").ToString + "/My/MyProfile.aspx"">profile</a> .</td>"
                        l_strHTML = l_strHTML & "</tr><tr><td></td> </tr>"
                        l_strHTML = l_strHTML & "<tr><td >Should you have any questions or comments please feel free to "
                        Dim rbu As String = ""
                        Dim SiebDt As DataTable = dbUtil.dbGetDataTable("MY",
                            String.Format("select top 1 RBU, row_id as account_row_id from siebel_account where RBU is not null and RBU<>'' and ERP_ID='{0}' order by account_status ", strCompanyId))
                        If SiebDt.Rows.Count = 1 Then
                            rbu = SiebDt.Rows(0).Item("RBU").ToString
                        End If
                        If rbu = "ADL" OrElse rbu = "AFR" OrElse rbu = "AIT" OrElse rbu = "ABN" OrElse rbu = "AEE" OrElse rbu = "AUK" Then
                            l_strHTML = l_strHTML & "contact us via&nbsp;<u><a href=""mailto:customercare@advantech.eu"">customercare@advantech.eu</a></u>"
                        ElseIf rbu = "HQDC" Or rbu = "ABR" Or rbu = "ARU" Or rbu = "AIN" Then
                            l_strHTML = l_strHTML & "contact us via&nbsp;<u><a href=""mailto:inquiry@advantech.com"">inquiry@advantech.com</a></u>"
                        Else
                            l_strHTML = l_strHTML & "contact us via&nbsp;<u><a href=""mailto:buy@advantech.com"">buy@advantech.com</a></u>"
                        End If
                        l_strHTML = l_strHTML & "</td></tr>"
                        l_strHTML = l_strHTML & "</table>"
                        l_strHTML = l_strHTML & "</body>"
                        l_strHTML = l_strHTML & "</html>"
                        Dim strFrom, strTo, strCC, strBCC, strSubject, AttachFile, strBody As String
                        strFrom = "myadvantech@advantech.com"
                        If rbu = "HQDC" Or rbu = "ABR" Or rbu = "ARU" Or rbu = "AIN" Then
                            strFrom = "inquiry@advantech.com"
                            Dim footer As String = dbUtil.dbGetDataTable("MY", String.Format("select isnull(footer,'') as footer from email_template where org_id='HQDC'")).Rows(0).Item(0).ToString
                            l_strHTML = l_strHTML & "<tr><td height='15' align='left'></td></tr><tr><td>" & footer & "</td></tr>"
                        End If
                        strTo = Trim(Me.email.Text)
                        'strTo = "jan.huang@Advantech.com.cn;"
                        strCC = "" '"Jackie.wu@adv"
                        strBCC = Session("user_id") + ",rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw"
                        strSubject = "MyAdvantech thanks your registration - (" & Trim(Me.email.Text) & ")"
                        AttachFile = "" 'Server.MapPath("../images/") & "\header_advantech_logo.gif"
                        strBody = l_strHTML 'Replace(l_strHTML, "/images/", "")
                        If Not cbSend.Checked Then strTo = Session("user_id")
                        Util.SendEmail(strTo, strFrom, strSubject, strBody, True, strCC, strBCC)
                        'Call MailUtil.Utility_EMailPage(strFrom, strTo, strCC, strBCC, strSubject, AttachFile, strBody)

                        Try
                            Dim sb As New StringBuilder
                            With sb
                                .AppendFormat("INSERT INTO ACCOUNT_ADMIN_LOG ")
                                .AppendFormat("(USER_ID,ACCOUNT_ID,TIMESTAMP,TYPE) ")
                                .AppendFormat(" VALUES (@USERID,@ACCOUNTID,@DATE,@TYPE)")
                            End With
                            Dim pUserID As New System.Data.SqlClient.SqlParameter("USERID", SqlDbType.NVarChar) : pUserID.Value = Session("user_id")
                            Dim pAccountID As New System.Data.SqlClient.SqlParameter("ACCOUNTID", SqlDbType.NVarChar) : pAccountID.Value = HttpUtility.HtmlEncode(email.Text).Trim()
                            Dim pDate As New System.Data.SqlClient.SqlParameter("DATE", SqlDbType.DateTime) : pDate.Value = Now.ToString
                            Dim pType As New System.Data.SqlClient.SqlParameter("TYPE", SqlDbType.NVarChar) : pType.Value = "Create"
                            Dim para() As System.Data.SqlClient.SqlParameter = {pUserID, pAccountID, pDate, pType}
                            dbUtil.dbExecuteNoQuery2("My", sb.ToString, para)
                        Catch ex As Exception

                        End Try

                        Me.strMsg.Text = Me.strMsg.Text + " Note: Register " & Request("email") & " successfully! "
                        Response.Redirect("../Admin/profile_admin.aspx?company_id=" & strCompanyId & "&org_id=" & strOrgId & "&message=" & Me.strMsg.Text)
                    End If

                    'Threading.Thread.Sleep(10000)
                    'Util.SyncContactFromSiebelByEmail(email.Text.Trim)
                End If


            End If
        End If
    End Sub

    Protected Sub sqlInterestedProd_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        sqlInterestedProd.SelectCommand = "select '---- Please Select ----' as text, '' as value union select value ,text from SIEBEL_CONTACT_InterestedProduct_LOV " + IIf(Session("RBU") = "ABB", " where value like 'BB %' ", " where value not like 'BB %' ") + " order by value"
    End Sub

    Public Function CreateRandomPassword() As String
        Dim _allowedChars As String = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ"
        Dim _allowedNumber As String = "0123456789"
        Dim randNum As New Random()
        Dim chars As New ArrayList

        For i As Integer = 0 To 3
            chars.Add(_allowedChars.Chars(CInt(Fix((_allowedChars.Length) * randNum.NextDouble()))))
        Next
        For j As Integer = 4 To 5
            chars.Add(_allowedNumber.Chars(CInt(Fix((_allowedNumber.Length) * randNum.NextDouble()))))
        Next
        Dim ran As New Random()
        Dim newChars(5) As Char
        Dim count As Integer = 5
        For k As Integer = 0 To 5
            Dim index As Integer = CInt(count * ran.NextDouble())
            newChars(k) = chars.Item(index)
            chars.RemoveAt(index)
            count -= 1
        Next

        Return New String(newChars)
    End Function

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then

        End If
    End Sub

    Private Function CreatePrivilege(ByVal row_id As String) As Boolean
        dbUtil.dbExecuteNoQuery("MY", String.Format(" delete from SIEBEL_CONTACT_PRIVILEGE where row_id = '{0}' ", row_id))
        'Can See Order
        If cbCanSeeOrder.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Can See Order',GetDate(),'{2}') ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can See Order', 'Create', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text = "Error : Create Siebel contact privilege - [Can See Order] failed."
                Return False
            End Try
        End If

        'Can Place Order
        If cbCanPlaceOrder.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Can Place Order',GetDate(),'{2}') ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Can Place Order', 'Create', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text = "Error : Create Siebel contact privilege - [Can Place Order] failed."
                Return False
            End Try
        End If

        'Account Admin
        If cbAccAdmin.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Account Admin',GetDate(),'{2}') ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'Account Admin', 'Create', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text = "Error : Create Siebel contact privilege - [Account Admin] failed."
                Return False
            End Try
        End If

        'Can See Cost
        If cbCanSeeCost.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'View Cost',GetDate(),'{2}') ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'View Cost', 'Create', '{2}', GETDATE()) ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text = "Error : Create Siebel contact privilege - [Can View Cost] failed."
                Return False
            End Try
        End If

        'Can See Project
        If cbCanSeePrj.Checked Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE (ROW_ID,EMAIL_ADDRESS,PRIVILEGE,CREATED_DATE,CREATED_BY) values ('{0}', '{1}', 'Can See Project',GetDate(),'{2}') ", row_id, email.Text.Trim.Replace("'", ""), User.Identity.Name))
            Catch ex As Exception
                strMsg.Text = "Error : Create contact privilege - [Can See Project] failed."
                Return False
            End Try
        End If
        Return True
    End Function

    Private Sub SyncContactInPrdAndBAA(ByVal rowid As String)
        'Update user's BAA data
        Try
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact_baa where contact_row_id='{0}'", rowid))
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT [Contact Id] AS CONTACT_ROW_ID, [Biz. Application Area] AS [NAME], NULL  AS [PRIMARY_FLAG] FROM V_CONTACT_BAA WHERE [Contact Id] = '{0}' ", rowid))
            If dt.Rows.Count > 0 Then
                Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                BCopy.DestinationTableName = "SIEBEL_CONTACT_BAA"
                BCopy.WriteToServer(dt)
            End If
        Catch ex As Exception

        End Try
        'Update user's interested product
        Try
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from SIEBEL_CONTACT_INTERESTED_PRODUCT where contact_row_id='{0}'", rowid))
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT c.ROW_ID as CONTACT_ROW_ID, a.NAME AS NAME, case a.ROW_ID when d.ATTRIB_35 then 1 else 0 end as PRIMARY_FLAG " +
                " FROM S_INDUST a INNER JOIN S_CONTACT_XM b ON a.ROW_ID = b.NAME  " +
                " INNER JOIN S_CONTACT c on b.PAR_ROW_ID=c.ROW_ID inner join S_CONTACT_X d on c.ROW_ID=d.ROW_ID " +
                " where not (c.EMAIL_ADDR is null) and c.EMAIL_ADDR like '%@%.%' and b.TYPE='Interested Product' " +
                " and c.ROW_ID='{0}' ", rowid))
            If dt.Rows.Count > 0 Then
                Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                BCopy.DestinationTableName = "SIEBEL_CONTACT_INTERESTED_PRODUCT"
                BCopy.WriteToServer(dt)
            End If
        Catch ex As Exception

        End Try
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <asp:UpdatePanel runat="server" ID="up1">
        <ContentTemplate>
            <table width="760" border="0" cellspacing="0" cellpadding="0" ID="Table1">
			    <tr>
				    <td colspan="3" class="text_mini">&nbsp;&nbsp;
					    <!-- **** Thread Bar ****-->
					    <a href="profile_admin.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>">Account Administration</a>
					    &gt; Register New User
				    </td>
			    </tr>
			    <tr valign="middle">
				    <td colspan="3" height="30" class="title_big">
					    <br/>
					    <!-- ******* page title (start) ********-->
					    &nbsp;&nbsp;<font color="#000000" size="4">User&nbsp;
						    Administration</font>&nbsp;&nbsp;&nbsp;<asp:Label runat="server" ID="strCompany"></asp:Label>
					    <!-- ******* page title (end) ********-->
					    <p></p>
				    </td>
			    </tr>
			    <tr>
				    <td colspan="3" class="text" valign="top" align="left">
					    <!-- **** Center Column : Main Part Start****-->
						    <br/>
						    <!-- **** input form start **** -->
						
							
								    <table width="600" border="0" cellpadding="1" cellspacing="1" style="background-color:#ffffff">
									    <tr>
										    <td align="center" colspan="2" bgcolor="#b0c4de" height="30">
											    <b>User&nbsp;Profile&nbsp;</b>
										    </td>
									    </tr>
									    <tr>
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel"><font color="red">*</font>Email Address&nbsp;:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    <div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="email" size="50" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20; text-align: left"></asp:TextBox>
											    <asp:RequiredFieldValidator runat="server" ID="rfv1" ControlToValidate="email" Display="Dynamic" Width="5" ErrorMessage=" *Email Address is mandatory" ForeColor="Red" /></div> 
										    </td>
									    </tr>
									    <tr>
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel"><font color="red">*</font>Name&nbsp;:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" align="left" >
											    &nbsp;First&nbsp;Name&nbsp;<asp:TextBox runat="server" ID="FirstName"></asp:TextBox><asp:RequiredFieldValidator runat="server" ID="rfvfin" ControlToValidate="FirstName" Display="Dynamic" Width="5" ErrorMessage=" *First Name is mandatory" ForeColor="Red" />&nbsp;
											    &nbsp;Last&nbsp;Name&nbsp;<asp:TextBox runat="server" ID="LastName"></asp:TextBox><asp:RequiredFieldValidator runat="server" ID="rfvlan" ControlToValidate="LastName" Display="Dynamic" Width="5" ErrorMessage=" *Last Name is mandatory" ForeColor="Red" />
										    </td>
									    </tr>
									    <tr>
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel"><font color="red">*</font>Phone No:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    <div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="txtPhone"></asp:TextBox><asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator1" ControlToValidate="txtPhone" Display="Dynamic" Width="5" ErrorMessage=" *Phone is mandatory" ForeColor="Red" /></div>
										    </td>
									    </tr>
									    <tr>
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;Fax No:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    <div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="txtFax"></asp:TextBox></div>
										    </td>
									    </tr>
									    <tr>
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;<font color="red">*</font>Password:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    <div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="password"></asp:TextBox></div>
										    </td>
									    </tr>
                                        <tr>
						                    <td bgcolor="#dcdcdc" align="right" width="120">
							                    <div class="mceLabel">&nbsp;<font color="red">*</font>Country:&nbsp;</div>
						                    </td>
						                    <td bgcolor="#e6e6fa" align="left" >
						                        &nbsp;<asp:DropDownList runat="server" ID="ddlCountry" DataSourceID="SqlDataSource1" DataTextField="TEXT" DataValueField="VALUE" 
						                            style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:150px;text-align: left">
					                            </asp:DropDownList>
					                            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:MY %>"
					                                selectcommand="select '---- Please Select ----' as text, '' as value union select VALUE as value ,text from siebel_account_country_lov order by value" />
						                    </td>
					                    </tr>
                                        <tr>
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;<font color="red">*</font>City:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    <div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="txtCity"></asp:TextBox><asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidator2" ControlToValidate="txtCity" Display="Dynamic" Width="5" ErrorMessage=" *City is mandatory" ForeColor="Red" /></div>
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
					                            <asp:SqlDataSource runat="server" ID="sqlInterestedProd" ConnectionString="<%$ connectionStrings:MY %>" OnLoad="sqlInterestedProd_Load" 
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
					                                selectcommand="select '---- Please Select ----' as text, '' as value union select value ,text from SIEBEL_CONTACT_BAA_LOV order by value" />
						                    </td>
					                    </tr>
									    <%--<tr>
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;<font color="red">*</font>Confirm Password:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    <div class="mceLabel">&nbsp;<asp:TextBox runat="server" ID="confirm_password" TextMode="Password"></asp:TextBox> </div>
										    </td>
									    </tr>--%>
									    <%--<tr runat="server" id="truser_role">
										    <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;User Role:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    &nbsp;<asp:DropDownList runat="server" ID="user_role" style="font-family: Arial; font-size: 8pt; color: #3A4A8D; height: 20;  width:150px;text-align: left">
											          <asp:ListItem Value="" Text="---- Please Select ----"></asp:ListItem>
											          <asp:ListItem Value="Buyer" Text="Buyer"></asp:ListItem>
											          <asp:ListItem Value="Guest" Text="Guest"></asp:ListItem>
											          <asp:ListItem Value="Sales" Text="Sales"></asp:ListItem>
											          <asp:ListItem Value="Logistics" Text="Logistics"></asp:ListItem>
											          </asp:DropDownList>
										    </td>
									    </tr>--%>
                                        <tr>
									        <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;Can See Order:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    &nbsp;<asp:CheckBox runat="server" ID="cbCanSeeOrder" />
										    </td>
									    </tr>
									    <tr>
									        <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;Can Place Order:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
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
									        <td bgcolor="#dcdcdc" align="right" width="120">
											    <div class="mceLabel">&nbsp;Account Admin:&nbsp;</div>
										    </td>
										    <td bgcolor="#e6e6fa" >
											    &nbsp;<asp:CheckBox runat="server" ID="cbAccAdmin" />
										    </td>
									    </tr>
                                        <tr>
                                            <td bgcolor="#dcdcdc" align="right" width="120">
                                                <div class="mceLabel">&nbsp;Can See Project:&nbsp;</div>
                                            </td>
                                            <td bgcolor="#e6e6fa">&nbsp;<asp:CheckBox runat="server" ID="cbCanSeePrj" />
                                            </td>
                                        </tr>
									    <tr>
										    <td align="center" colspan="2" bgcolor="#e6e6fa"  valign="middle" height="35">
											    <asp:TextBox runat="server" ID="company_id" Visible="false"></asp:TextBox>
											    <asp:TextBox runat="server" ID="org_id" Visible="false"></asp:TextBox>
											    <asp:TextBox runat="server" ID="action" Visible="false" Text="register"></asp:TextBox>
											    <asp:ImageButton  runat="server" ID="RegisterNewUser" ImageUrl="../Images/ebiz.aeu.face/btn_RegisterNewUser.GIF" OnClick="RegisterNewUser_Click" />											
										        <asp:CheckBox runat="server" ID="cbSend" Text=" Send registration email to customer" ForeColor="Red" />
                                            </td>
									    </tr>
								    </table>
						    <br/>
					    <!-- **** Center Column : Main Part End ****-->
				    </td>
			    </tr>
                <tr><td width="120"></td><td colspan="2"><asp:Label runat="server" ID="strMsg" ForeColor="Red" Font-Size="Medium"></asp:Label></td></tr>
	    </table>
        <br /><br />
        </ContentTemplate>
    </asp:UpdatePanel>
    
</asp:Content>
