<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Account Admin"
    EnableEventValidation="false" %>

<%@ Register Src="~/Includes/ChangeCompany.ascx" TagName="ChangeCompany" TagPrefix="uc1" %>
<script runat="server">
    Dim strCompanyId As String = ""
    Dim strOrgID As String = ""
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not MailUtil.IsInRole("MyAdvantech") Then
            If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False And Not Util.IsAdmin() And Not Util.IsAccountAdmin() And Not Util.IsAEUUser() Then
                Response.Redirect("/Admin/B2B_Admin_Portal.aspx")
            End If

        End If
        strOrgID = Session("COMPANY_ORG_ID")
        strCompanyId = UCase(Session("COMPANY_ID"))
        If Not Page.IsPostBack Then
            If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False Then
                With CType(ChangeCompany1.FindControl("ucChangeCompany").FindControl("txtCh2Company"), TextBox)
                    .Text = UCase(Session("COMPANY_ID")) : .ForeColor = Drawing.ColorTranslator.FromHtml("#3A4A8D")
                    .Font.Size = FontSize.Large
                End With
            End If
            If Util.IsInternalUser(Session("user_id")) OrElse Util.IsAEUIT() Then
                ChangeCompany1.Visible = True
            End If

            Register_Tag.NavigateUrl = String.Format("~/admin/user_profile.aspx?company_id={0}&org_id={1}", strCompanyId, strCompanyId)
            'Ryan 20160418 Hide "Register New User" if ERPID is not maintained in Siebel.
            Dim sql_str As String = "SELECT a.COMPANY_ID FROM SAP_DIMCOMPANY a INNER JOIN SIEBEL_ACCOUNT b ON a.COMPANY_ID = b.ERP_ID where a.COMPANY_ID = '" + Session("COMPANY_ID") + "'"
            Dim check_account_dt As DataTable = dbUtil.dbGetDataTable("MY", sql_str)
            If check_account_dt.Rows.Count = 0 Then
                Register_Tag.Enabled = False
                Register_Message.Text = "Can't Register New User due to ERPID " + Session("COMPANY_ID") + " is not found in Siebel Account."
            End If
        End If
        '20060203 TC: Error handle for org id, used to be AESC but become EU10 after SAP go-live
        strOrgID = Session("org_id")

        InitSearch()
    End Sub
    Protected Sub InitSearch()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select '' as C_NO, A.ROW_ID, IsNull(A.FST_NAME, '') + ' ' + IsNull(A.LAST_NAME, '') as full_name, ")
            .AppendFormat("IsNull(A.EMAIL_ADDR, '') as userid, (select top 1 IsNull(E.ATTRIB_37, '') from S_CONTACT_X E where A.ROW_ID = E.ROW_ID) as job_function, B.ROW_ID as account_row_id, ")
            .AppendFormat("IsNull(D.ATTRIB_05, '') as company_id, (select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) as org_id, A.ACTIVE_FLG ")
            .AppendFormat("FROM S_CONTACT A INNER JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID INNER JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID ")
            .AppendFormat("WHERE (A.ROW_ID = A.PAR_ROW_ID) and A.EMAIL_ADDR like '%@%.%' and Upper(D.ATTRIB_05)='{0}' ", UCase(strCompanyId))
            'If Not Util.IsAdmin() Then
            '    Dim dt As DataTable = dbUtil.dbGetDataTable("My", String.Format("select rbu from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid='{0}'", Session("user_id")))
            '    If dt.Rows.Count > 0 Then
            '        Dim arrRbu() As String = dt.Rows(0).Item("rbu").ToString.Split("|")
            '        For i As Integer = 0 To arrRbu.Length - 1
            '            arrRbu(i) = "'" + arrRbu(i) + "'"
            '        Next
            '        If arrRbu.Length > 0 Then
            '            .AppendFormat(" and (select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) in ({0}) ", String.Join(",", arrRbu))
            '        End If

            '    Else
            '        .AppendFormat(" and 1 != 1 ")
            '    End If
            'End If
            .AppendFormat(" order by userid")
        End With
        'MailUtil.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "Admin SQL", sb.ToString, False, "", "")
        'ViewState("SqlCommand") = ""
        SqlDataSource1.SelectCommand = sb.ToString
        ''Response.Write("<xml>"+SqlDataSource1.SelectCommand+"</xml>")
        'ViewState("SqlCommand") = SqlDataSource1.SelectCommand
        sgv1.DataBind()

    End Sub

    Protected Sub AdgSearch_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            'Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", String.Format("select * from SSO_MEMBER where EMAIL_ADDR = '{0}'", e.Row.Cells(3).Text))
            Dim dt As DataTable = dbUtil.dbGetDataTable("CP", String.Format("select USER_STATUS from SSO_MEMBER (nolock) where EMAIL_ADDR = '{0}'", e.Row.Cells(3).Text))
            Dim ws1 As New ADWWW_Register.MembershipWebservice
            ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000
            Dim IsSSOExist As Boolean = ws1.isExist(LCase(e.Row.Cells(3).Text), "My")
            Dim isActive As Boolean = True
            If IsSSOExist Then
                For Each row As DataRow In dt.Rows
                    If CBool(row.Item("USER_STATUS")) = False Then isActive = False
                Next
                'e.Row.Cells(4).Text = "Y"
                CType(e.Row.Cells(4).FindControl("lblLogin"), Label).Text = "Y"
                CType(e.Row.Cells(4).FindControl("btnCreateLogin"), LinkButton).Visible = False
            Else
                'e.Row.Cells(4).Text = "N"
                CType(e.Row.Cells(4).FindControl("lblLogin"), Label).Text = "N"
                CType(e.Row.Cells(4).FindControl("btnCreateLogin"), LinkButton).Visible = True
            End If
            If DataBinder.Eval(e.Row.DataItem, "ACTIVE_FLG") <> "Y" Or isActive = False Then
                CType(e.Row.Cells(11).FindControl("btnDisable"), Button).Text = "Enable"
                e.Row.BackColor = Drawing.Color.Gray
            End If
        End If
    End Sub

    Protected Sub btnDelete_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False And Util.IsAccountAdmin = False And Not Util.IsAEUUser() Then
            Response.Redirect("/Admin/B2B_Admin_Portal.aspx")
            Exit Sub
        End If
        dbUtil.dbExecuteNoQuery("My", "delete from Contact where Userid='" & sgv1.DataKeys(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).RowIndex).Values("userid") & "'")
        dbUtil.dbExecuteNoQuery("My", "delete from Contact_Role where Userid='" & sgv1.DataKeys(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).RowIndex).Values("userid") & "'")
        'Log
        Try
            Dim sb As New StringBuilder
            With sb
                .AppendFormat("INSERT INTO ACCOUNT_ADMIN_LOG ")
                .AppendFormat("(USER_ID,ACCOUNT_ID,TIMESTAMP,TYPE) ")
                .AppendFormat(" VALUES (@USERID,@ACCOUNTID,@DATE,@TYPE)")
            End With
            Dim pUserID As New System.Data.SqlClient.SqlParameter("USERID", SqlDbType.NVarChar) : pUserID.Value = Session("user_id")
            Dim pAccountID As New System.Data.SqlClient.SqlParameter("ACCOUNTID", SqlDbType.NVarChar) : pAccountID.Value = sgv1.DataKeys(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).RowIndex).Values("userid")
            Dim pDate As New System.Data.SqlClient.SqlParameter("DATE", SqlDbType.DateTime) : pDate.Value = Now.ToString
            Dim pType As New System.Data.SqlClient.SqlParameter("TYPE", SqlDbType.NVarChar) : pType.Value = "Delete"
            Dim para() As System.Data.SqlClient.SqlParameter = {pUserID, pAccountID, pDate, pType}
            dbUtil.dbExecuteNoQuery2("My", sb.ToString, para)
            sgv1.DataBind()
        Catch ex As Exception

        End Try

    End Sub

    Protected Sub btnEdit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If MYSIEBELDAL.IsAccountOwner(Session("user_id")) = False And Not Util.IsAdmin() And Not Util.IsAccountAdmin() And Not Util.IsAEUUser() Then
            Response.Redirect("/Admin/B2B_Admin_Portal.aspx")
            Exit Sub
        End If
        Dim strUserId As String = sgv1.DataKeys(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).RowIndex).Values("userid")
        Dim row_id As String = sgv1.DataKeys(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).RowIndex).Values("ROW_ID")
        Response.Redirect("/Admin/user_profile_update.aspx?userid=" + strUserId + "&company_id=" + strCompanyId + "&org_id=" + strOrgID + "&rid=" + HttpUtility.UrlEncode(row_id))
    End Sub

    Protected Sub btnDisable_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim button As Button = CType(sender, Button)
        Dim userId As String = sgv1.DataKeys(CType(button.NamingContainer, GridViewRow).RowIndex).Values("userid")
        Dim rowId As String = sgv1.DataKeys(CType(button.NamingContainer, GridViewRow).RowIndex).Values("ROW_ID") 'ICC 2015/9/18 Add rowId para
        'Dim ws As New aeu_eai2000.Siebel_WS
        'ws.UseDefaultCredentials = True : ws.Timeout = 500 * 1000
        If button.Text = "Disable" Then
            'Dim retVal As Boolean = ws.UpdateContactDisable(userId, True)
            'If retVal = True Then
            '    'sgv1.DataBind()
            '    dbUtil.dbExecuteNoQuery("MY", String.Format("update siebel_contact set active_flag='N' where EMAIL_ADDRESS='{0}'", userId))
            '    dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact_privilege where row_id='{0}'", sgv1.DataKeys(CType(button.NamingContainer, GridViewRow).RowIndex).Values("ROW_ID")))

            '    Dim ws1 As New ADWWW_Register.MembershipWebservice
            '    ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000
            '    ws1.DisableUser(userId, "MY")
            '    dbUtil.dbExecuteNoQuery("CP", String.Format("update SSO_MEMBER set USER_STATUS=0 where EMAIL_ADDR='{0}'", userId))
            '    Util.JSAlertRedirect(Page, "Update Successfully", "Profile_Admin.aspx")

            'Else
            '    Util.JSAlert(Page, "Update Failed")
            'End If

            'ICC 2015/9/18 Becasue Siebel web service is going well now.
            'ICC 2015/4/15 Because Siebel web service can not be used now, so we only update SSO and update privilege.
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact_privilege where row_id='{0}'", rowId)) 'Use rowId para
                'ICC 2015/7/6 No longer insert data into TEMP table, becasue we don't have to sync privilege data from SIEBEL
                'dbUtil.dbExecuteNoQuery("MY", String.Format(" insert into SIEBEL_CONTACT_PRIVILEGE_TEMP values ('{0}', '{1}', 'All', 'Remove', '{2}', GETDATE()) ", sgv1.DataKeys(CType(button.NamingContainer, GridViewRow).RowIndex).Values("ROW_ID"), userId, User.Identity.Name))
                'Dim ws1 As New ADWWW_Register.MembershipWebservice
                'ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000
                dbUtil.dbExecuteNoQuery("CP", String.Format("update SSO_MEMBER set USER_STATUS=0 where EMAIL_ADDR='{0}'", userId))
                'ws1.DisableUser(userId, "MY")

                'ICC 2015/9/18 各自檢查SSO & Siebel, SSO 有問題則提示SSO問題, Siebel 有問題則提示Siebel
                Dim ssoRet As Boolean = Me.UpdateSSoStatus(userId, False)
                Dim siebelRet As Boolean = Me.UpdateSiebelContact(rowId, False)

                If ssoRet = False Then
                    Util.JSAlert(Page, "Update SSO Failed")
                    Exit Sub
                End If

                If siebelRet = False Then
                    Util.JSAlert(Page, "Update Siebel Failed")
                    Exit Sub
                End If

                Util.JSAlertRedirect(Page, "Update Successfully", "Profile_Admin.aspx")
            Catch ex As Exception
                Util.InsertMyErrLog(ex.ToString)
                Util.JSAlert(Page, "Update Failed")
            End Try
        Else
            'Dim retVal As Boolean = ws.UpdateContactDisable(userId, False)
            'If retVal = True Then
            '    'sgv1.DataBind()
            '    dbUtil.dbExecuteNoQuery("MY", String.Format("update siebel_contact set active_flag='Y' where EMAIL_ADDRESS='{0}'", userId))
            '    Dim ws1 As New ADWWW_Register.MembershipWebservice
            '    ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000
            '    ws1.EnableUser(userId, "MY")
            '    dbUtil.dbExecuteNoQuery("CP", String.Format("update SSO_MEMBER set USER_STATUS=1 where EMAIL_ADDR='{0}'", userId))
            '    Util.JSAlertRedirect(Page, "Update Successfully", "Profile_Admin.aspx")

            'Else
            '    Util.JSAlert(Page, "Update Failed")
            'End If

            'ICC 2015/4/15 Because Siebel web service can not be used now, so we only update SSO in use.
            Try
                dbUtil.dbExecuteNoQuery("CP", String.Format("update SSO_MEMBER set USER_STATUS=1 where EMAIL_ADDR='{0}'", userId)) '2015/4/16 ICC Update MyAdvantech status first
                'Dim ws1 As New ADWWW_Register.MembershipWebservice
                'ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000
                'ws1.EnableUser(userId, "MY")

                'ICC 2015/9/18 各自檢查SSO & Siebel, SSO 有問題則提示SSO問題, Siebel 有問題則提示Siebel
                Dim ssoRet As Boolean = Me.UpdateSSoStatus(userId, True)
                Dim siebelRet As Boolean = Me.UpdateSiebelContact(rowId, True)

                If ssoRet = False Then
                    Util.JSAlert(Page, "Update SSO Failed")
                    Exit Sub
                End If

                If siebelRet = False Then
                    Util.JSAlert(Page, "Update Siebel Failed")
                    Exit Sub
                End If

                Util.JSAlertRedirect(Page, "Update Successfully", "Profile_Admin.aspx")
            Catch ex As Exception
                Util.InsertMyErrLog(ex.ToString)
                Util.JSAlert(Page, "Update Failed")
            End Try
        End If
    End Sub

    'ICC 2015/9/18 Create Update SSO status function
    Private Function UpdateSSoStatus(ByVal userId As String, ByVal status As Boolean) As Boolean
        Try
            Dim ws1 As New ADWWW_Register.MembershipWebservice
            ws1.UseDefaultCredentials = True : ws1.Timeout = 500 * 1000
            If status = True Then ' status = True means Enable user else means Disable user 
                ws1.EnableUser(userId, "MY")
            Else
                ws1.DisableUser(userId, "MY")
            End If
            Return True
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString)
            Return False
        End Try
    End Function

    'ICC 2015/9/18 Create Update Siebel Contact function
    Private Function UpdateSiebelContact(ByVal rowId As String, ByVal status As Boolean) As Boolean
        Try
            Dim contact As Advantech.Myadvantech.DataAccess.SIEBEL_CONTACT
            contact = Advantech.Myadvantech.Business.SiebelBusinessLogic.GetSiebelContact(rowId)
            If Not contact Is Nothing Then
                Dim flag As String = "Y"
                If status = False Then flag = "N" 'status = false means Disable else means Enable
                contact.ACTIVE_FLAG = flag
                Dim ret As Boolean = Advantech.Myadvantech.Business.SiebelBusinessLogic.UpdateSiebelContactByWS(contact)
                If ret = True Then
                    Util.SyncContactFromSiebel(rowId)
                    Return True
                End If
            End If
            Return False
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString)
            Return False
        End Try
    End Function

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'InitSearch()
    End Sub

    Protected Sub btnCreateLogin_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim row_id As String = CType(CType(sender, LinkButton).NamingContainer, GridViewRow).Cells(1).Text
        Response.Redirect("user_profile.aspx?company_id=" + strCompanyId + "&org_id" + strOrgID + "&id=" + HttpUtility.UrlEncode(row_id)) : Exit Sub 'ICC 2014/10/23 Encoded row_id to prevent URL parse problems
        Dim email As String = CType(CType(sender, LinkButton).NamingContainer, GridViewRow).Cells(3).Text
        Dim firstname As String = "", lastname As String = "", country As String = "", tel As String = "", accountId As String = "", account_name As String = ""
        Dim password As String = CreateRandomPassword()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select isnull(firstname,'') as firstname, isnull(lastname,'') as lastname, isnull(country,'') as country, isnull(workphone,'') as workphone, isnull(account_row_id,'') as account_row_id, isnull(account,'') as account from siebel_contact where email_address='{0}'", email))
        If dt.Rows.Count > 0 Then
            firstname = dt.Rows(0).Item(0).ToString
            lastname = dt.Rows(0).Item(1).ToString
            country = dt.Rows(0).Item("country").ToString
            tel = dt.Rows(0).Item("workphone").ToString
            accountId = dt.Rows(0).Item("account_row_id").ToString
            account_name = dt.Rows(0).Item("account").ToString
        End If
        Dim ws As New ADWWW_Register.MembershipWebservice
        ws.UseDefaultCredentials = True : ws.Timeout = 500 * 1000
        If ws.isExist(LCase(email.Trim), "My") = True Then Exit Sub
        Dim p As New ADWWW_Register.SSOUSER
        With p
            p.company_id = Session("COMPANY_ID") : p.erpid = Session("COMPANY_ID")
            p.email_addr = email
            p.login_password = password  'Util.GetMD5Checksum(LCase(email.Text.Trim) + "|" + password.Text.Trim)
            p.first_name = firstname : p.last_name = lastname : p.country = country
            p.source = "My" : p.tel_no = tel : p.AccountID = accountId : p.company_name = account_name
        End With
        ws.register("My", p)
        dbUtil.dbExecuteNoQuery("CP", String.Format("insert into SSO_MEMBER (EMAIL_ADDR,USER_STATUS) values ('{0}',1)", email))

        Dim l_strHTML As String = ""
        l_strHTML = l_strHTML & "<html xmlns=""http://www.w3.org/1999/xhtml"">"
        l_strHTML = l_strHTML & "<body><table  width=""900"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font-family:Arial Unicode MS""><tr><td>"
        l_strHTML = l_strHTML & "<img alt="""" src=""http://" + Request.ServerVariables("HTTP_HOST").ToString + "/Images/logo2.jpg"" /><br/></td>"
        l_strHTML = l_strHTML & "</tr><tr><td>"
        If firstname = "" Then
            l_strHTML = l_strHTML & "Dear customer,</td>"
        Else
            l_strHTML = l_strHTML & "Dear <b>" & firstname & "&nbsp;" & lastname & "</b>,</td>"
        End If
        l_strHTML = l_strHTML & "</tr><tr><td>"
        l_strHTML = l_strHTML & "Welcome to MyAdvantech. Through this portal you can access <b>personal content</b> and Advantech <b>Product/Sales/MarketingTools, eRMA & Support, and B2B online procurement</b> easily with the least effort."
        l_strHTML = l_strHTML & "</td></tr>"
        l_strHTML = l_strHTML & "<tr><td height=""50"">"
        l_strHTML = l_strHTML & "Your login information for&nbsp;MyAdvantech is as follows:</td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr><td>"
        l_strHTML = l_strHTML & "<table style="" width: 80.0%;background: silver;font-family:Arial Unicode MS"" border=""0"" cellspacing=""0""  cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""width: 150px ;background: #EEEEEE;border-right:solid 1px #cccccc"">ID(Email Address):</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & email & "</span></td></tr>"
        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #D9D9D9;border-right:solid 1px #cccccc"">Password:</td> <td style=""background: #D9D9D9""><span style=""color:navy""> &nbsp;" & password & "</span></td></tr>"
        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">First Name:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & firstname & "</span></td></tr>"
        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #D9D9D9;border-right:solid 1px #cccccc"">Last Name:</td><td style=""background: #D9D9D9""><span style=""color:navy""> &nbsp;" & lastname & "</span></td></tr>"
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
        Dim SiebDt As DataTable = dbUtil.dbGetDataTable("MY", _
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
        'strTo = Trim(email)
        strTo = Session("USER_ID")
        strCC = "" '"Jackie.wu@adv"
        strBCC = Session("USER_ID") + ",rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw"
        strSubject = "MyAdvantech thanks your registration - (" & email & ")"
        AttachFile = "" 'Server.MapPath("../images/") & "\header_advantech_logo.gif"
        strBody = l_strHTML 'Replace(l_strHTML, "/images/", "")

        Try
            Dim sb As New StringBuilder
            With sb
                .AppendFormat("INSERT INTO ACCOUNT_ADMIN_LOG ")
                .AppendFormat("(USER_ID,ACCOUNT_ID,TIMESTAMP,TYPE) ")
                .AppendFormat(" VALUES (@USERID,@ACCOUNTID,@DATE,@TYPE)")
            End With
            Dim pUserID As New System.Data.SqlClient.SqlParameter("USERID", SqlDbType.NVarChar) : pUserID.Value = Session("user_id")
            Dim pAccountID As New System.Data.SqlClient.SqlParameter("ACCOUNTID", SqlDbType.NVarChar) : pAccountID.Value = email
            Dim pDate As New System.Data.SqlClient.SqlParameter("DATE", SqlDbType.DateTime) : pDate.Value = Now.ToString
            Dim pType As New System.Data.SqlClient.SqlParameter("TYPE", SqlDbType.NVarChar) : pType.Value = "Create"
            Dim para() As System.Data.SqlClient.SqlParameter = {pUserID, pAccountID, pDate, pType}
            dbUtil.dbExecuteNoQuery2("My", sb.ToString, para)
        Catch ex As Exception

        End Try

        Util.SendEmail(strTo, strFrom, strSubject, strBody, True, strCC, strBCC)
        Response.Redirect("Profile_Admin.aspx")
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

    Protected Sub Btn_Excel_Click(sender As Object, e As EventArgs)

        'Get Account List from CRM DB
        Dim crm_str As String = "select A.ROW_ID, IsNull(A.FST_NAME, '') + ' ' + IsNull(A.LAST_NAME, '') as full_name, " & _
            " IsNull(A.EMAIL_ADDR, '') as userid, (select top 1 IsNull(E.ATTRIB_37, '') " & _
            " from S_CONTACT_X E where A.ROW_ID = E.ROW_ID) as job_function, B.ROW_ID as account_row_id, " & _
            " IsNull(D.ATTRIB_05, '') as company_id, (select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) as org_id, " & _
            " A.ACTIVE_FLG FROM S_CONTACT A INNER JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID " & _
            " INNER JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID " & _
            "WHERE (A.ROW_ID = A.PAR_ROW_ID) and A.EMAIL_ADDR like '%@%.%' and Upper(D.ATTRIB_05)='" & UCase(Session("COMPANY_ID")) & "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", crm_str)
        dt.Columns.Add("See Order", Type.GetType("System.String"))
        dt.Columns.Add("Place Order", Type.GetType("System.String"))
        dt.Columns.Add("View Cost", Type.GetType("System.String"))
        dt.Columns.Add("Account Admin", Type.GetType("System.String"))

        'Get Account status from Siebel_Contact
        Dim str_privilege As String = "select * from SIEBEL_CONTACT_PRIVILEGE where EMAIL_ADDRESS in "
        If dt.Rows.Count > 0 Then
            Dim a As New ArrayList
            For Each r As DataRow In dt.Rows
                a.Add("'" + r.Item("userid") + "'")
            Next
            str_privilege += "(" + String.Join(",", a.ToArray()) + ")"
        End If
        Dim dt_privilege As DataTable = dbUtil.dbGetDataTable("MY", str_privilege)

        For Each r As DataRow In dt.Rows
            Dim rows() As DataRow = dt_privilege.Select("EMAIL_ADDRESS = '" & r.Item("userid") + "'")
            If rows.Count > 0 Then
                For Each row As DataRow In rows
                    If row.Item("PRIVILEGE").ToString.Equals("Can Place Order") Then
                        r.Item("Place Order") = "True"
                    ElseIf row.Item("PRIVILEGE").ToString.Equals("Can See Order") Then
                        r.Item("See Order") = "True"
                    ElseIf row.Item("PRIVILEGE").ToString.Equals("View Cost") Then
                        r.Item("View Cost") = "True"
                    ElseIf row.Item("PRIVILEGE").ToString.Equals("Account Admin") Then
                        r.Item("Account Admin") = "True"
                    End If
                Next
            End If
        Next

        Util.DataTable2ExcelDownload(dt, "AccountList.xls")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" language="javascript">
        function PickCompany(xElement, xContent) {
            var xValue = new Array();
            var Url;

            xValue = xElement.split("*");
            //alert(xValue[0]);
            Url = "../order/PickCompanyID.aspx?Element=" + xElement + "&Type=&CompanyID=" + document.form1.elements(xValue[0]).value + "";
            window.open(Url, "pop", "height=570,width=480,scrollbars=yes");
        }
        //	function User_Register(strCompanyId,strOrgId) {
        //		window.event.returnValue = false;
        //		document.location.href = '/profile/user_profile_new.asp?company_id=' + strCompanyId + '&org_id=' + strOrgId;
        //	}
    </script>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr valign="top">
            <td>
                <!-- ******* main pane (start) ********-->
                <table width="100%" id="Table2">
                    <tr valign="top">
                        <td height="2">
                            &nbsp;
                        </td>
                    </tr>
                    <!-- ******* page title (start) ********-->
                    <tr valign="top">
                        <td class="pagetitle">
                            <div class="euPageTitle">
                                Account Administration&nbsp;&nbsp;&nbsp;&nbsp;<asp:Label runat="server" ID="strMsg"
                                    Text="" class="PageMessageBar" /></div>
                        </td>
                    </tr>
                    <!-- ******* page title (end) ********-->
                    <tr valign="top">
                        <td height="2">
                            &nbsp;
                        </td>
                    </tr>
                    <tr valign="top">
                        <td>
                            <table width="100%" id="Table3">
                                <!-- ******* form  (start) ********-->
                                <tr valign="top">
                                    <td valign="top" width="82%" id="ChangeCompany1" runat="server" visible="false">
                                        <hr style="background-color: blue; outline-color: Blue" />
                                        <table valign="top" width="100%" cellpadding="3" cellspacing="0" border="0">
                                            <tr class="FormBlank">
                                                <td valign="top" width="30%">
                                                    <table border="0">
                                                        <tr>
                                                            <td class="FormLabel">
                                                                <br />
                                                                <b>Change&nbsp;Company:</b>
                                                            </td>
                                                            <td class="FormField">
                                                                &nbsp;<uc1:ChangeCompany ID="ucChangeCompany" runat="server" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                        <hr style="background-color: blue" />
                                    </td>
                                    <td valign="top" width="130">
                                        <!-- ******* Account Admin Navi (start) ********-->
                                        <table border="0" cellpadding="0" cellspacing="0" class="text" id="Table1">
                                            <tr>
                                                <td>
                                                    <table width="200" border="0" cellpadding="0" cellspacing="0" id="Table5">
                                                        <tr>
                                                            <td width="19" align="right" valign="bottom">
                                                                <img alt="" src="../images/ebiz.aeu.face/table_lefttop.gif" width="15" height="32" />
                                                            </td>
                                                            <td width="434" style="background-image: url(../images/ebiz.aeu.face/table_top.gif)"
                                                                class="text">
                                                                <div class="euNaviTableTitle">
                                                                    Account Admin Navi
                                                                </div>
                                                            </td>
                                                            <td width="23" align="left" valign="bottom">
                                                                <img alt="" src="../images/ebiz.aeu.face/table_righttop.gif" width="17" height="32" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td height="125" style="background-image: url(../Images/ebiz.aeu.face/table_left.gif);">
                                                            </td>
                                                            <td align="right" bgcolor="F5F6F7" valign="top">
                                                                <table width="190" border="0" cellpadding="0" cellspacing="0" class="text" id="Table4">
                                                                    <tr>
                                                                        <td colspan="2" height="8">
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td width="22" height="20">
                                                                            <div align="center">
                                                                                <img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6" /></div>
                                                                        </td>
                                                                        <td width="168" valign="middle" align="left">
                                                                            <%--<a id="Register_aTag" runat="server" href="../admin/user_profile.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>">
                                                                                <div class="euNaviTableItem" runat="server" id="euNaviTableItem">
                                                                                    Register New User</div>
                                                                            </a>--%>
                                                                            <asp:HyperLink ID="Register_Tag" runat="server" Text="Register New User" Enabled="true"></asp:HyperLink>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td width="22" height="20">
                                                                            <div align="center"></div>
                                                                        </td>
                                                                        <td>
                                                                            <div align="left">
                                                                            <asp:Label Id="Register_Message" runat="server" Text="" ForeColor="Red"></asp:Label>
                                                                            </div>
                                                                        </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td colspan="2" height="8">
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td style="background-image: url(../images/ebiz.aeu.face/table_right.gif)">
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="right" valign="top">
                                                                <img alt="" src="../images/ebiz.aeu.face/table_downleft.gif" width="15" height="13" />
                                                            </td>
                                                            <td style="background-image: url(../images/ebiz.aeu.face/table_down.gif)">
                                                            </td>
                                                            <td align="left" valign="top">
                                                                <img alt="" src="../Images/ebiz.aeu.face/table_downright.gif" width="17" height="13" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                        <!-- ******* Account Admin Navi (End) ********-->
                                    </td>
                                </tr>
                                <!-- ******* form  (end) ********-->
                            </table>
                        </td>
                    </tr>
                    <!-- ******* record list1 (start) ********-->
                    <tr valign="top">
                        <td>
                            <input type="hidden" name="DeleteInfo" />
                            <asp:ImageButton ID="Btn_Excel" runat="server" ImageUrl="~/Images/excel.gif" OnClick="Btn_Excel_Click" />
                            <sgv:SmartGridView runat="server" ID="sgv1" AutoGenerateColumns="False" Width="97%"
                                AllowSorting="true" DataSourceID="SqlDataSource1" HeaderStyle-BackColor="#EBEADB"
                                OnRowDataBoundDataRow="AdgSearch_RowDataBoundDataRow" DataKeyNames="userid,ROW_ID">
                                <Columns>
                                    <asp:TemplateField ItemStyle-Width="2%" ItemStyle-HorizontalAlign="Center">
                                        <HeaderTemplate>
                                            No.
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Row Id" DataField="ROW_ID" />
                                    <asp:BoundField HeaderText="User Name" DataField="full_name" />
                                    <asp:BoundField HeaderText="User Id" DataField="userid" />
                                    <asp:TemplateField HeaderText="Has Login?" ItemStyle-Width="100px">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="lblLogin" />
                                            <asp:LinkButton runat="server" ID="btnCreateLogin" Text="Create Login" OnClick="btnCreateLogin_Click" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Job Function" DataField="job_function" />
                                    <asp:HyperLinkField HeaderText="Account Row Id" DataNavigateUrlFields="account_row_id"
                                        DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="account_row_id"
                                        Target="_blank" SortExpression="account_row_id" />
                                    <asp:BoundField HeaderText="Company Id" DataField="company_id" Visible="false" />
                                    <asp:BoundField HeaderText="Org_Id" DataField="org_id" Visible="false" />
                                    <asp:TemplateField HeaderText="Edit" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:ImageButton runat="server" ID="btnEdit" ImageUrl="/images/ebiz.aeu.face/btn_Edit.GIF"
                                                OnClick="btnEdit_Click" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Del" ItemStyle-HorizontalAlign="Center" Visible="false">
                                        <ItemTemplate>
                                            <asp:ImageButton runat="server" ID="btnDelete" ImageUrl="/images/btn_del.GIF" OnClick="btnDelete_Click" />
                                            <ajaxToolkit:ConfirmButtonExtender runat="server" ID="cbe1" TargetControlID="btnDelete"
                                                ConfirmText="Are you sure to delete this user ?" ConfirmOnFormSubmit="true" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Disable" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Button runat="server" ID="btnDisable" Text="Disable" OnClick="btnDisable_Click" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <CustomPagerSettings PagingMode="default" TextFormat="{0} record per page/totla {1} records&nbsp;&nbsp;&nbsp;&nbsp;page {2}/total {3} page(s)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" />
                                <PagerSettings Position="Top" PageButtonCount="13" FirstPageText="First Page" PreviousPageText="Previous Page"
                                    NextPageText="Next Page" LastPageText="Last Page" />
                                <PagerStyle BackColor="#C3DAF9" />
                                <CascadeCheckboxes>
                                    <sgv:CascadeCheckbox ChildCheckboxID="item" ParentCheckboxID="all" />
                                </CascadeCheckboxes>
                            </sgv:SmartGridView>
                            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:CRMDB75 %>"
                                SelectCommand="" OnLoad="SqlDataSource1_Load"></asp:SqlDataSource>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td height="2">
                            <hr />
                        </td>
                    </tr>
                </table>
                <!-- ******* main pane (end) ********-->
            </td>
        </tr>
        <tr valign="top">
            <td height="2">
                &nbsp;
            </td>
        </tr>
    </table>
</asp:Content>
