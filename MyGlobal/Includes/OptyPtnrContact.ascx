<%@ Control Language="VB" ClassName="OptyPtnrContact" %>
<%@ Import Namespace="SiebelBusObjectInterfaces" %>

<script runat="server">
    Public Property AccountRowId() As String
        Get
            Return src1.SelectParameters("ACCOUNTROWID").DefaultValue
        End Get
        Set(ByVal value As String)
            If value.IndexOf("1-X9GVWZ") > -1 Then
                src1.SelectParameters("ACCOUNTROWID").DefaultValue = "1-NXWLXT"
            Else
                src1.SelectParameters("ACCOUNTROWID").DefaultValue = value
            End If
        End Set
    End Property
    Public Property ContactRowId() As String
        Get
            Return ViewState("CRID")
        End Get
        Set(ByVal value As String)
            ViewState("CRID") = value
            'Response.Write(src1.SelectParameters("ACCOUNTROWID").DefaultValue + "," + ViewState("CRID") + "<br/>")
        End Set
    End Property

    Public Property OptyRowId() As String
        Get
            Return ViewState("OPTYRID")
        End Get
        Set(ByVal value As String)
            ViewState("OPTYRID") = value
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
            String.Format(" select top 1 dbo.DateOnly(assign_date) as assign_date, contact_email, assign_by from dbo.OPTY_ASSIGN_HISTORY " + _
                          " where row_id='{0}' order by assign_date desc", ViewState("OPTYRID")))
            If dt.Rows.Count = 1 Then
                Me.lbAssignHistory.Text = String.Format("{0} assigned on {2}", dt.Rows(0).Item("assign_by"), dt.Rows(0).Item("contact_email"), dt.Rows(0).Item("assign_date"))
            End If
        End Set
    End Property

    Protected Sub dlContact_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If ContactRowId <> "" Then
            For Each li As ListItem In dlContact.Items
                If li.Value = ContactRowId Then
                    li.Selected = True 'Response.Write(li.Text)
                    ' Exit For
                End If
                'If isexist2(li.Text.ToString.Trim) Then
                '    li.Attributes.Add("style", "color:#FF0000")                              
                'End If

            Next
        End If
    End Sub
    'Public Function isexist2(ByVal contact_email As String) As Boolean
    '    Dim sql As String = String.Format("select * from siebel_MyLeads where contact_email = '{0}' and company_id = '{1}'", contact_email, Session("company_id"))
    '    Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", sql)     
    '    If dt.Rows.Count > 0 Then
    '        Return True
    '    Else
    '        Return False
    '    End If
    'End Function
    Protected Sub btnUpdate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'If dlContact.SelectedItem.Text Like "*@*.*" Then
        'If Session("user_id") = "ming.zhao@advantech.com.cn" Then           
        '    uMsg.Text = OptyRowId + "0000" + dlContact.SelectedValue
        '    Exit Sub
        'End If

        If True Then
            dbUtil.dbExecuteNoQuery("RFM", String.Format( _
            "INSERT INTO OPTY_ASSIGN_HISTORY (ROW_ID, ASSIGN_DATE, ASSIGN_BY, CONTACT_ROW_ID, CONTACT_EMAIL) " + _
            " VALUES (N'{0}',GetDate(), N'{1}', N'{2}', N'{3}')", OptyRowId, Session("user_id"), dlContact.SelectedValue, dlContact.SelectedItem.Text))
            ContactRowId = dlContact.SelectedValue
            For Each li As ListItem In dlContact.Items
                If li.Value = ContactRowId Then
                    li.Selected = True
                    If dlContact.SelectedItem.Text <> "" Then

                        'ICC 2016/4/1 Update Siebel opportunity - partner ID, partner contact
                        Dim Account_RowID_List As List(Of Advantech.Myadvantech.DataAccess.SIEBEL_ACCOUNT) = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSiebelAccountChannelPartnerByERPID(Session("company_id"))
                        Dim Account_RowID As String = String.Empty
                        If (Not Account_RowID_List Is Nothing AndAlso Account_RowID_List.Count > 0) Then
                            Account_RowID = Account_RowID_List.Item(0).ROW_ID.ToString()
                        End If

                        'ICC 2016/4/1 Update Siebel opportunity
                        Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.SiebelDAL.UpdateSiebelOpty4PrjReg(OptyRowId, String.Empty, String.Empty, String.Empty, String.Empty, Account_RowID, ContactRowId)

                        If result.Item1 = True Then
                            uMsg.Text = "Sales lead has been assigned to " + dlContact.SelectedItem.Text
                            SendLeadsInfoToContact(OptyRowId, dlContact.SelectedItem.Text)
                        Else
                            'ICC Update Siebel opportunity failed
                            Util.SendEmail("MyAdvantech@advantech.com", "MyAdvantech@advantech.com", "Update Siebel opportunity failed about lead partner contact!", result.Item2, True, String.Empty, String.Empty)
                            uMsg.Text = "Update Siebel failed! Please contact MyAdvantech@advantech.com"
                        End If
                    Else
                        uMsg.Text = "Sales lead is now assigned to no one"
                    End If
                    Exit For
                End If
            Next
            If CInt(dbUtil.dbExecuteScalar("My", String.Format("select count(*) from contact where userid='{0}'", dlContact.SelectedItem.Text))) = 0 Then
                Try
                    SyncFromSiebelContact(dlContact.SelectedValue, dlContact.SelectedItem.Text)
                Catch ex As Exception
                    Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Assign Lead to Contact Failed", dlContact.SelectedItem.Text + ":" + dlContact.SelectedValue, True, "", "")
                End Try
            End If
        Else
            uMsg.Text = "failed to assign partner contact in Siebel"
        End If

        'End If
    End Sub

    Private Sub SyncFromSiebelContact(ByVal row_id As String, ByVal email As String)
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select * from siebel_contact where row_id='{0}'", row_id))
        If dt.Rows.Count > 0 Then
            Dim sb As New StringBuilder
            With sb
                .AppendFormat("insert into contact (USERID,COMPANY_ID,org_id,LOGIN_PASSWORD,ROW_ID,FirstName,MiddleName,LastName,WorkPhone,FaxNumber,")
                .AppendFormat("CellPhone,JOB_FUNCTION,PAR_ROW_ID,ERPID,PriOrgId,OwnerId,CanSeeOrder,Password,Sales_Rep,NeverEmail,NeverCall,NeverFax,")
                .AppendFormat("NeverMail,JOB_TITLE,ACCOUNT_ROW_ID,ACCOUNT,COUNTRY,Salutation,EMPLOYEE_FLAG,ACTIVE_FLG,User_Type,Registration_Source,")
                .AppendFormat("CREATED,LAST_UPDATED,Can_Place_Order,IsAccountOwner,Registration_Time) ")
                .AppendFormat("values ('{0}',@COMPANYID,@ORGID,@LOGINPASSWORD,'{1}',@FIRSTNAME,@MIDDLENAME,@LASTNAME,@WORKPHONE,@FAXNUMBER,", email, row_id)
                .AppendFormat("@CELLPHONE,@JOBFUNCTION,@PARROWID,@ERPID,@PRIORGID,@OWNERID,@CANSEEORDER,@PASSWORD,@SALESREP,@NEVEREMAIL,@NEVERCALL,@NEVERFAX,")
                .AppendFormat("@NEVERMAIL,@JOBTITLE,@ACCOUNTROWID,@ACCOUNT,@COUNTRY,@SALUTATION,@EMPLOYEEFLAG,@ACTIVEFLG,@USERTYPE,@REGISTRATIONSOURCE,")
                .AppendFormat("@CREATED,@LASTUPDATED,@CANPLACEORDER,@ISACCOUNTOWNER,'{0}')", Now)
            End With
            For Each row As DataRow In dt.Rows
                Dim pCompanyID As New System.Data.SqlClient.SqlParameter("COMPANYID", SqlDbType.NVarChar) : pCompanyID.Value = row.Item("ERPID")
                Dim pOrgID As New System.Data.SqlClient.SqlParameter("ORGID", SqlDbType.NVarChar) : pOrgID.Value = row.Item("OrgID")
                Dim pLoginPassword As New System.Data.SqlClient.SqlParameter("LOGINPASSWORD", SqlDbType.NVarChar)
                Dim ws As New SSO.MembershipWebservice
                Dim p As SSO.SSOUSER = ws.getProfile(email, "my")
                If p IsNot Nothing Then
                    pLoginPassword.Value = p.login_password
                Else
                    If Not IsDBNull(row.Item("Password")) And row.Item("Password").ToString <> "" Then
                        pLoginPassword.Value = row.Item("Password")
                    Else
                        pLoginPassword.Value = CreateRandomPassword()
                    End If
                End If
                Dim pFirstName As New System.Data.SqlClient.SqlParameter("FIRSTNAME", SqlDbType.NVarChar) : pFirstName.Value = row.Item("FirstName")
                Dim pMiddleName As New System.Data.SqlClient.SqlParameter("MIDDLENAME", SqlDbType.NVarChar) : pMiddleName.Value = row.Item("MiddleName")
                Dim pLastName As New System.Data.SqlClient.SqlParameter("LASTNAME", SqlDbType.NVarChar) : pLastName.Value = row.Item("LastName")
                Dim pWorkPhone As New System.Data.SqlClient.SqlParameter("WORKPHONE", SqlDbType.NVarChar) : pWorkPhone.Value = row.Item("WorkPhone")
                Dim pFaxNumber As New System.Data.SqlClient.SqlParameter("FAXNUMBER", SqlDbType.NVarChar) : pFaxNumber.Value = row.Item("FaxNumber")
                Dim pCellPhone As New System.Data.SqlClient.SqlParameter("CELLPHONE", SqlDbType.NVarChar) : pCellPhone.Value = row.Item("CellPhone")
                Dim pJobFunction As New System.Data.SqlClient.SqlParameter("JOBFUNCTION", SqlDbType.NVarChar) : pJobFunction.Value = row.Item("JOB_FUNCTION")
                Dim pParRowID As New System.Data.SqlClient.SqlParameter("PARROWID", SqlDbType.NVarChar) : pParRowID.Value = row.Item("PAR_ROW_ID")
                Dim pERPID As New System.Data.SqlClient.SqlParameter("ERPID", SqlDbType.NVarChar) : pERPID.Value = row.Item("ERPID")
                Dim pPriOrgID As New System.Data.SqlClient.SqlParameter("PRIORGID", SqlDbType.NVarChar) : pPriOrgID.Value = row.Item("PriOrgId")
                Dim pOwnerID As New System.Data.SqlClient.SqlParameter("OWNERID", SqlDbType.NVarChar) : pOwnerID.Value = row.Item("OwnerId")
                Dim pCanSeeOrder As New System.Data.SqlClient.SqlParameter("CANSEEORDER", SqlDbType.NVarChar) : pCanSeeOrder.Value = row.Item("CanSeeOrder")
                Dim pPassword As New System.Data.SqlClient.SqlParameter("PASSWORD", SqlDbType.NVarChar) : pPassword.Value = row.Item("Password")
                Dim pSalesRep As New System.Data.SqlClient.SqlParameter("SALESREP", SqlDbType.VarChar) : pSalesRep.Value = row.Item("Sales_Rep")
                Dim pNeverEmail As New System.Data.SqlClient.SqlParameter("NEVEREMAIL", SqlDbType.NVarChar) : pNeverEmail.Value = row.Item("NeverEmail")
                Dim pNeverCall As New System.Data.SqlClient.SqlParameter("NEVERCALL", SqlDbType.NVarChar) : pNeverCall.Value = row.Item("NeverCall")
                Dim pNeverFax As New System.Data.SqlClient.SqlParameter("NEVERFAX", SqlDbType.NVarChar) : pNeverFax.Value = row.Item("NeverFax")
                Dim pNeverMail As New System.Data.SqlClient.SqlParameter("NEVERMAIL", SqlDbType.NVarChar) : pNeverMail.Value = row.Item("NeverMail")
                Dim pJobTitle As New System.Data.SqlClient.SqlParameter("JOBTITLE", SqlDbType.NVarChar) : pJobTitle.Value = row.Item("JOB_TITLE")
                Dim pAccountRowID As New System.Data.SqlClient.SqlParameter("ACCOUNTROWID", SqlDbType.NVarChar) : pAccountRowID.Value = row.Item("ACCOUNT_ROW_ID")
                Dim pAccount As New System.Data.SqlClient.SqlParameter("ACCOUNT", SqlDbType.NVarChar) : pAccount.Value = row.Item("ACCOUNT")
                Dim pCountry As New System.Data.SqlClient.SqlParameter("COUNTRY", SqlDbType.NVarChar) : pCountry.Value = row.Item("COUNTRY")
                Dim pSalutation As New System.Data.SqlClient.SqlParameter("SALUTATION", SqlDbType.NVarChar) : pSalutation.Value = row.Item("Salutation")
                Dim pEmployeeFlag As New System.Data.SqlClient.SqlParameter("EMPLOYEEFLAG", SqlDbType.NVarChar) : pEmployeeFlag.Value = row.Item("EMPLOYEE_FLAG")
                Dim pActiveFlg As New System.Data.SqlClient.SqlParameter("ACTIVEFLG", SqlDbType.NVarChar) : pActiveFlg.Value = row.Item("ACTIVE_FLAG")
                Dim pUserType As New System.Data.SqlClient.SqlParameter("USERTYPE", SqlDbType.NVarChar) : pUserType.Value = row.Item("USER_TYPE")
                Dim pRegistrationSource As New System.Data.SqlClient.SqlParameter("REGISTRATIONSOURCE", SqlDbType.NVarChar) : pRegistrationSource.Value = row.Item("REG_SOURCE")
                Dim pCreated As New System.Data.SqlClient.SqlParameter("CREATED", SqlDbType.DateTime) : pCreated.Value = row.Item("CREATED")
                Dim pLastUpdated As New System.Data.SqlClient.SqlParameter("LASTUPDATED", SqlDbType.DateTime) : pLastUpdated.Value = row.Item("LAST_UPDATED")
                Dim pCanPlaceOrder As New System.Data.SqlClient.SqlParameter("CANPLACEORDER", SqlDbType.Bit) : pCanPlaceOrder.Value = False
                Dim pIsAccountOwner As New System.Data.SqlClient.SqlParameter("ISACCOUNTOWNER", SqlDbType.Bit) : pIsAccountOwner.Value = False
                Dim para() As System.Data.SqlClient.SqlParameter = {pCompanyID, pOrgID, pLoginPassword, pFirstName, pMiddleName, pLastName, pWorkPhone, pFaxNumber, pCellPhone, pJobFunction, pParRowID, pERPID, pPriOrgID, pOwnerID, pCanSeeOrder, pPassword, pSalesRep, pNeverEmail, pNeverCall, pNeverFax, pNeverMail, pJobTitle, pAccountRowID, pAccount, pCountry, pSalutation, pEmployeeFlag, pActiveFlg, pUserType, pRegistrationSource, pCreated, pLastUpdated, pCanPlaceOrder, pIsAccountOwner}
                dbUtil.dbExecuteNoQuery2("My", sb.ToString, para)

                Dim l_strHTML As String = ""
                l_strHTML = l_strHTML & "<html xmlns=""http://www.w3.org/1999/xhtml"">"
                l_strHTML = l_strHTML & "<body><table  width=""900"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font-family:Arial Unicode MS""><tr><td  >"
                l_strHTML = l_strHTML & "<img alt="""" src=""../Images/main_banner.jpg"" style=""width: 557px; height: 150px"" /></td>"
                l_strHTML = l_strHTML & "</tr><tr> <td>"
                l_strHTML = l_strHTML & "Dear <b>" & Trim(pFirstName.Value) & "&nbsp;" & Trim(pLastName.Value) & "</b></td>"
                l_strHTML = l_strHTML & "</tr><tr><td>"
                l_strHTML = l_strHTML & "Welcome to&nbsp;MyAdvantech. Through this portal you can access Advantech "
                l_strHTML = l_strHTML & "<b>Product/Sales/Marketing Tools,&nbsp;eRMA &amp; Support, and B2B online procurement "
                l_strHTML = l_strHTML & "easily with the least effort.</b></b> "
                l_strHTML = l_strHTML & "</td></tr>"
                l_strHTML = l_strHTML & "<tr><td height=""50"">"
                l_strHTML = l_strHTML & "Your login information for&nbsp;MyAdvantech is as follows:</td>"
                l_strHTML = l_strHTML & "</tr>"
                l_strHTML = l_strHTML & "<tr><td height=""50"">"
                l_strHTML = l_strHTML & "<table style="" width: 80.0%;background: silver;"" border=""0"" cellspacing=""0""  cellpadding=""0"">"
                l_strHTML = l_strHTML & "<tr><td  align=""center""style=""width: 150px ;background: #EEEEEE;border-right:solid 1px #cccccc"">ID(Email Address):</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & email & "</span></td></tr>"
                l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Password:</td> <td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(pLoginPassword.Value) & "</span></td></tr>"
                l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">First Name:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(pFirstName.Value) & "</span></td></tr>"
                l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Last Name:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(pLastName.Value) & "</span></td></tr>"
                l_strHTML = l_strHTML & "<tr><td align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Phone No:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(pWorkPhone.Value) & "</span></td></tr>"
                l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Fax No:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(pFaxNumber.Value) & "</span></td></tr>"
                l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #EEEEEE;border-right:solid 1px #cccccc"">Account Name:</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(pAccount.Value) & " </span></td></tr>"
                l_strHTML = l_strHTML & "</table></td></tr> <tr><td>"
                l_strHTML = l_strHTML & "At the MyAdvantech "
                l_strHTML = l_strHTML & "<a href=""http://" + Request.ServerVariables("HTTP_HOST").ToString + "/Login.aspx?ReturnUrl=%2fhome.aspx"" "
                l_strHTML = l_strHTML & "title=""http://partner.advantech.com.tw/""><span style=""color:#000099"">login</span></a> "
                l_strHTML = l_strHTML & "page, enter the ID and password provided above for the first login. Afterwards, "
                l_strHTML = l_strHTML & "you can change the password by updating your user "
                l_strHTML = l_strHTML & "<a href=""http://" + Request.ServerVariables("HTTP_HOST").ToString + "/My/MyProfile.aspx"">profile</a> .</td>"
                l_strHTML = l_strHTML & "</tr><tr><td></td> </tr>"
                l_strHTML = l_strHTML & "<tr><td valign=""top""><a href='http://www.advantech.com/'><img src='/images/logo1.jpg' alt='Advantech'/></a><a href='/Home.aspx'><img src='/images/logo.jpg' alt='MyAdvantech'></a>"
                l_strHTML = l_strHTML & "</td>"
                'l_strHTML = l_strHTML & "<tr><td align=""left"" height=""50"">"
                'l_strHTML = l_strHTML & "<img alt="""" src=""../Images/logo.gif""style=""width: 308px; height: 31px"" />"
                'l_strHTML = l_strHTML & "</td></tr>"
                If Not Session("RBU") = "AAC" Then
                    l_strHTML = l_strHTML & "<tr><td >Should you have any questions or comments please feel free to "
                End If
                Dim rbu As String = ""
                Dim SiebDt As DataTable = dbUtil.dbGetDataTable("MY", _
                    String.Format("select top 1 RBU, row_id as account_row_id from siebel_account where RBU is not null and RBU<>'' and ERP_ID='{0}' order by account_status ", Request("company_id")))
                If SiebDt.Rows.Count = 1 Then
                    rbu = SiebDt.Rows(0).Item("RBU").ToString
                End If
                If rbu = "ADL" OrElse rbu = "AFR" OrElse rbu = "AIT" OrElse rbu = "ABN" OrElse rbu = "AEE" OrElse rbu = "AUK" Then
                    l_strHTML = l_strHTML & "contact us via&nbsp;<u><a href=""mailto:customercare@advantech.eu"">customercare@advantech.eu</a></u>"
                ElseIf Not Session("RBU") = "AAC" Then
                    l_strHTML = l_strHTML & "contact us via&nbsp;<u><a href=""mailto:buy@advantech.com"">buy@advantech.com</a></u>"
                End If
                l_strHTML = l_strHTML & "</td></tr>"
                l_strHTML = l_strHTML & "</table>"
                l_strHTML = l_strHTML & "</body>"
                l_strHTML = l_strHTML & "</html>"
                Dim strFrom, strTo, strCC, strBCC, strSubject, AttachFile, strBody As String
                strFrom = "myadvantech@advantech.com"

                strTo = Trim(email)
                'strTo = "jan.huang@Advantech.com.cn;"
                strCC = "" '"Jackie.wu@adv"
                strBCC = Session("USER_ID") + ";rudy.wang@advantech.com.tw;tc.chen@advantech.com.tw"
                strSubject = "MyAdvantech thanks your registration - (" & Trim(email) & ")"
                AttachFile = "" 'Server.MapPath("../images/") & "\header_advantech_logo.gif"
                strBody = l_strHTML 'Replace(l_strHTML, "/images/", "")
                Call MailUtil.Utility_EMailPage(strFrom, strTo, strCC, strBCC, strSubject, AttachFile, strBody)
            Next
            dbUtil.dbExecuteNoQuery("My", String.Format("insert into contact_role (userid,roleid) values ('{0}','5e6bc2ad83')", email))
        End If
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

    Public Sub SendLeadsInfoToContact(ByVal OptyId As String, ByVal ContactEmail As String)
        If Not ContactEmail Like "*@*.*" Then ContactEmail = "myadvantech@advantech.com"
        Dim dt As DataTable = GetOptyDetail(OptyId)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim salesEmail As String = dt.Rows(0).Item("sales_email")
            Dim salesName As String = dt.Rows(0).Item("sales_email")
            Dim accountName As String = dt.Rows(0).Item("account_name")
            Dim dtOwner As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select distinct isnull(J.EMAIL_ADDR,'') as owner_email from S_OPTY A left outer join  S_POSTN D on A.PR_POSTN_ID = D.ROW_ID left outer join  S_USER I on D.PR_EMP_ID = I.ROW_ID left outer join S_CONTACT J on J.ROW_ID = I.ROW_ID where A.ROW_ID='{0}'", OptyId))
            If dt.Rows.Count > 0 Then
                Dim owner As String = dtOwner.Rows(0).Item(0).ToString
                If owner <> "" AndAlso Util.IsValidEmailFormat(owner) Then salesEmail = owner : salesName = owner
            End If
            Dim OptyName As String = dt.Rows(0).Item("name")
            If Not salesEmail Like "*@*.*" Then
                salesEmail = "myadvantech@advantech.com"
            End If
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format("Dear Customer,<br/>"))
                .AppendLine("<br/>")
                .AppendLine(String.Format(" A sales lead <b>{0}</b> has been assigned to you from Advantech.<br/>", OptyName))
                .AppendLine(String.Format(" Please visit <a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "/My/MyLeads.aspx'>MyAdvantech</a> to check the detail.<br/>"))
                .AppendLine(String.Format(" Thank you.<br/>"))
                .AppendLine("<br/>")
                .AppendLine(String.Format("Best regards,<br/>"))
                'ICC Block this code
                'Dim rbu As String = ""
                'Dim SiebDt As DataTable = dbUtil.dbGetDataTable("MY", _
                '    String.Format("select top 1 RBU, row_id as account_row_id from siebel_account where RBU is not null and RBU<>'' and ERP_ID='{0}' order by account_status ", Request("company_id")))
                'If SiebDt.Rows.Count = 1 Then
                '    rbu = SiebDt.Rows(0).Item("RBU").ToString
                'End If
                'If rbu = "ADL" OrElse rbu = "AFR" OrElse rbu = "AIT" OrElse rbu = "ABN" OrElse rbu = "AEE" OrElse rbu = "AUK" Then
                '    .AppendLine("<b><a href=""mailto:customercare@advantech.eu"">customercare@advantech.eu</a></b>")
                'Else
                '    .AppendLine("<b><a href=""mailto:buy@advantech.com"">buy@advantech.com</a></b>")
                'End If
                .AppendLine(String.Format("<b><a href='mailto:{0}'>{1}</a></b>", salesEmail, salesName))
            End With
            'Dim FromSales As String = salesEmail
            Dim FromSales As String = "MyAdvantech@advantech.com"
            If salesEmail <> "" Then
                salesEmail += "," + Session("user_id")
            Else
                salesEmail = Session("user_id")
            End If

            If Session("company_id") IsNot Nothing Then
                Dim ISDt As DataTable = GetISFromCompanyId(Session("company_id"))
                If ISDt.Rows.Count = 1 Then
                    salesEmail += "," + ISDt.Rows(0).Item("email")
                End If
                Dim OptyTeamDt As DataTable = dbUtil.dbGetDataTable("MY", "select email from opty_team where company_id='" + Session("company_id") + "'")
                If OptyTeamDt.Rows.Count > 0 Then
                    For Each r As DataRow In OptyTeamDt.Rows
                        salesEmail += "," + r.Item("email")
                    Next
                End If
            End If
            salesEmail += ",ChannelManagement.ACL@advantech.com"
            If True Then
                'If Session("user_id") = "tc.chen@advantech.com.tw" Then ContactEmail = Session("user_id")
                If Util.IsTesting() Then
                    Util.SendEmail("ic.chen@advantech.com.tw,yl.huang@advantech.com.tw,tc.chen@advantech.com.tw", FromSales, "New Sales Lead From Advantech", "To Email: " + ContactEmail + "<br/> CC: " + salesEmail + "<br/>" + sb.ToString, True, "", "")
                Else
                    Util.SendEmail(ContactEmail, FromSales, "New Sales Lead From Advantech", sb.ToString, True, salesEmail, "tc.chen@advantech.eu,rudy.wang@advantech.com.tw,ic.chen@advantech.com.tw,yl.huang@advantech.com.tw")
                End If
            Else
                'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "TESTOPTYPTNCONTACT", sb.ToString() + "-----------" + vbCrLf + "ContactEmail:" + ContactEmail + vbCrLf + "--------------" + vbCrLf + "FromSales:" + FromSales + vbCrLf + "-------------" + vbCrLf + "salesemail:" + salesEmail, False, "", "")
            End If
        End If
    End Sub

    Public Function GetOptyDetail(ByVal OptyId As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", _
        String.Format(" select a.ROW_ID, a.NAME, a.STATUS_CD, b.NAME as account_name, IsNull(a.DESC_TEXT,'') as desc_text, " + _
                      " IsNull(d.EMAIL_ADDR,'ebusiness.aeu@advantech.eu') as sales_email, IsNull(d.EMAIL_ADDR,'ebusiness.aeu@advantech.eu') as sales, " + _
                      " IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID=a.CREATED_BY),'ebusiness.aeu@advantech.eu') as creator_email " + _
                      " from S_OPTY a inner join S_ORG_EXT b on a.PR_PRTNR_ID=b.ROW_ID inner join S_POSTN c on b.PR_POSTN_ID=c.ROW_ID inner join S_CONTACT d on c.PR_EMP_ID=d.ROW_ID where a.ROW_ID='{0}' ", OptyId))
        For Each r As DataRow In dt.Rows
            If r.Item("sales").ToString Like "*@*" Then
                Dim mp() As String = Split(r.Item("sales").ToString(), "@")
                r.Item("sales") = mp(0).Trim()
            End If
        Next
        dt.AcceptChanges()
        Return dt

    End Function

    'Public Function GetISFromCompanyId(ByVal companyid As String) As DataTable
    '    Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format( _
    '    "select top 1 b.sales_code, b.full_name, b.email " + _
    '    " from sap_company_employee a inner join sap_employee b on a.sales_code=b.sales_code " + _
    '    " where a.partner_function='Z2' and a.sales_org='EU10' and b.email like '%@%advantech%.%' and a.company_id in ('{0}')", _
    '    companyid))
    '    Return dt
    'End Function

    Public Function GetISFromCompanyId(ByVal companyid As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format( _
        "select top 1 b.sales_code, b.full_name, b.email " + _
        " from sap_company_employee a inner join sap_employee b on a.sales_code=b.sales_code " + _
        " where a.partner_function='Z2' and b.full_name not in ('OP CE.OP CENTRAL EUROPE','OP EE.OP EAST EUROPE','OP NE.OP NORTH EUROPE','OP SE.OP SOUTH EUROPE') and a.sales_org='EU10' and b.email like '%@%advantech%.%' and a.company_id in ('{0}')", _
        companyid))
        Return dt
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then

        End If
    End Sub
</script>
<table>
    <tr>
        <td colspan="2">
            <table>
                <tr>
                    <td>
                        <asp:Label Font-Size="Small" Font-Italic="true" runat="server" ID="lbAssignHistory" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:DropDownList runat="server" ID="dlContact" Width="180px" DataTextField="contact_email" DataValueField="row_id" DataSourceID="src1" OnDataBound="dlContact_DataBound" />
                        <asp:SqlDataSource runat="server" ID="src1"
                            SelectCommand="select '' as row_id, '' as contact_email union select row_id, email_address as contact_email from siebel_contact where account_row_id in (select row_id from siebel_account where erp_id<>'' and erp_id in (select erp_id from siebel_account where erp_id<>'' and erp_id is not null and row_id=@ACCOUNTROWID)) and email_address like '%@%.%' order by row_id"
                            ConnectionString="<%$ ConnectionStrings:RFM %>">
                            <SelectParameters>
                                <asp:Parameter Name="ACCOUNTROWID" ConvertEmptyStringToNull="false" Type="String" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <asp:Button runat="server" ID="btnUpdate" Text="Assign" OnClick="btnUpdate_Click" />
        </td>
        <td colspan="2">
            <asp:Label runat="server" ID="uMsg" Font-Bold="true" ForeColor="Tomato" Font-Size="Larger" />
        </td>
    </tr>
</table>
