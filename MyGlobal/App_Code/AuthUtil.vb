Imports Microsoft.VisualBasic
Imports System
Imports System.IO
Imports System.Text
Imports System.Security.Cryptography

Public Class MYASSO

    Shared Function CheckSSO(ByVal tempid As String, ByVal UserId As String) As Boolean
        If dbUtil.dbExecuteScalar("MY", String.Format("select top 1 SESSIONID from USER_LOG where SESSIONID='{0}' and USERID='{1}' and APPID='EQ' and timestamp between dateadd(day,-1,getdate()) and getdate()", tempid, UserId)) IsNot Nothing Then
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Function LoginBySSO(ByVal ID As String, ByVal USER As String, ByRef MSG As String) As Boolean
        Dim Validated As Boolean = False
        Validated = CheckSSO(ID, USER)
        If Validated Then
            Return True
        Else
            Dim sso As New SSO.MembershipWebservice
            sso.Timeout = -1
            If sso.validateTemidEmail(Util.GetClientIP(), ID, "MY", USER) Then
                Return True
            Else
                MSG = "SSO login failed. please logout and re-login."
            End If
        End If
        Return False
    End Function
End Class
Public Class AuthUtil

    Public Shared Function IsHQAOnlineMkt() As Boolean
        If Not HttpContext.Current.User.Identity.IsAuthenticated Then Return False
        If String.Equals(HttpContext.Current.User.Identity.Name, "tanya.lin@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
           OrElse String.Equals(HttpContext.Current.User.Identity.Name, "ada.tang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
           OrElse String.Equals(HttpContext.Current.User.Identity.Name, "wen.chiang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
           OrElse String.Equals(HttpContext.Current.User.Identity.Name, "gary.lee@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
           OrElse String.Equals(HttpContext.Current.User.Identity.Name, "julie.fang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
           OrElse String.Equals(HttpContext.Current.User.Identity.Name, "aurora.sun@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
           OrElse String.Equals(HttpContext.Current.User.Identity.Name, "mary.huang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) Then
            Return True
        End If
        Return False
    End Function
    ''' <summary>
    ''' 判断是否有权限编辑ACL Contacts
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function IsTW01PIMailContactAdmin() As Boolean
        If Not HttpContext.Current.User.Identity.IsAuthenticated Then Return False



        'Frank 20160510: Becuase most of them are also the members of GBS.ACL, therefore identify this group directly.
        'Dim B2Bmembers As New List(Of String)(New String() {"polar.yu@advantech.com.tw", "emily.chen@advantech.com.tw", "maggie.yu@advantech.com.tw", "amy.yen@advantech.com.tw", "beca.wu@advantech.com.tw", "sandy.lin@advantech.com.tw", "fanny.tseng@advantech.com.tw", "elisa.huang@advantech.com.tw", "vanage.lin@advantech.com.tw", "inge.lee@advantech.com.tw"})
        If MailUtil.IsInMailGroup("GBS.ACL", HttpContext.Current.User.Identity.Name) Then Return True

        Dim B2Bmembers As New List(Of String)(New String() {"vanage.lin@advantech.com.tw"})
        If Util.IsAEUIT() OrElse B2Bmembers.Contains(HttpContext.Current.User.Identity.Name.ToLower) Then
            Return True
        End If
        Return False
    End Function

    Public Shared Function IsUSAonlineOrderNo(ByVal Orderid As String) As Boolean
        If String.IsNullOrEmpty(Orderid) Then Return False
        If Orderid.StartsWith("AUSO", StringComparison.InvariantCultureIgnoreCase) Then Return True
        If Orderid.StartsWith("AMXO", StringComparison.InvariantCultureIgnoreCase) Then Return True
        If Orderid.StartsWith("AIAG", StringComparison.InvariantCultureIgnoreCase) Then Return True
        Return False
    End Function

    Public Shared Function IsJPAonlineSales(ByVal Userid As String) As Boolean
        If SAPDAL.SAPDAL.IsJPPowerUser(Userid) Then Return True
        If MailUtil.IsInMailGroup("ajp_sales_all", Userid) Then Return True
        Return False
    End Function

    Public Shared Function IsKRAonlineSales(ByVal Userid As String) As Boolean
        If MailUtil.IsInMailGroup("PROS.AKR", Userid) Then Return True
        Return False
    End Function

    Public Shared Function IsHQDCiASales(ByVal Userid As String) As Boolean
        If MailUtil.IsInMailGroup("IA.eSales", Userid) Then Return True
        Return False
    End Function

    Public Shared Function IsHQDCeCSales(ByVal Userid As String) As Boolean
        If MailUtil.IsInMailGroup("InterCon.Embedded", Userid) Then Return True
        Return False
    End Function


    Public Shared Function IsTWAonlineSales(ByVal Userid As String) As Boolean
        If MailUtil.IsInMailGroup("OP.ATW.ACL", Userid) Then Return True
        If MailUtil.IsInMailGroup("ATWCallCenter", Userid) Then Return True
        If MailUtil.IsInMailGroup("Sales.ATW.AOL-Neihu(IIoT)", Userid) Then Return True
        If MailUtil.IsInMailGroup("Sales.ATW.AOL-EC", Userid) Then Return True
        If MailUtil.IsInMailGroup("CallCenter.IA.ACL", Userid) Then Return True
        If MailUtil.IsInMailGroup("Sales.ATW.AOL-ATC(IIoT)", Userid) Then Return True
        Return False
    End Function

    Public Shared Function IsUSAonlineSales(ByVal Userid As String) As Boolean

        If HttpContext.Current.Session("IsUSAonlineSale") IsNot Nothing Then
            Return CType(HttpContext.Current.Session("IsUSAonlineSale"), Boolean)
        End If

        If Userid Is Nothing OrElse String.IsNullOrEmpty(Userid) Then
            HttpContext.Current.Session("IsUSAonlineSale") = False : Return False
        End If

        If MailUtil.IsInMailGroup("AOnline.USA", Userid) Then
            HttpContext.Current.Session("IsUSAonlineSale") = True : Return True
        End If
        If MailUtil.IsInMailGroup("Aonline.USA.IAG", Userid) Then
            HttpContext.Current.Session("IsUSAonlineSale") = True : Return True
        End If
        'Frank 20140916 Confirmed with TC, Irvine should not have AOnline Sales
        'If MailUtil.IsInMailGroup("EMPLOYEES.Irvine", Userid) Then
        '    HttpContext.Current.Session("IsUSAonlineSale") = True : Return True
        'End If
        'If MailUtil.IsInMailGroup("SALES.AAC.USA", Userid) Then
        '    HttpContext.Current.Session("IsUSAonlineSale") = True : Return True
        'End If

        If IsMexicoAonlineSales(Userid) Then
            HttpContext.Current.Session("IsUSAonlineSale") = True : Return True
        End If

        HttpContext.Current.Session("IsUSAonlineSale") = False : Return False

    End Function

    Public Shared Function IsMexicoAonlineSales(ByVal Userid As String) As Boolean
        If Userid Is Nothing OrElse String.IsNullOrEmpty(Userid) Then Return False
        If Userid.EndsWith("@advantech.com.mx", StringComparison.InvariantCultureIgnoreCase) Then Return True
        'If IsInMailGroup("AOnline.AMX", Userid) Then Return True
        Return False
    End Function


    Public Enum AccountStatus
        EZ
        CP
        GA
        KA
        DMS
        FC
    End Enum
    Public Shared Function GetUserType(ByVal userid As String) As String
        If userid.ToString.ToLower = "test.acl@advantech.com" Then
            Return AccountStatus.CP.ToString()
        ElseIf userid.ToLower = "ncg@advantech.com" Then
            Return AccountStatus.GA.ToString()
        End If

        'Frank 2012/10/01 Franchiser verify
        If Util.IsFranchiser(userid, "") Then Return AccountStatus.FC.ToString()
        'If Util.IsPCP_Marcom(userid, "") Then Return AccountStatus.CP.ToString()
        If Util.IsInternalUser(userid) Then Return AccountStatus.EZ.ToString()
        userid = Trim(userid).Replace("'", "")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 account_status, isnull(firstname,'') as firstname from SIEBEL_CONTACT where email_address='{0}' and account_status<>'' and account_status is not null order by account_status", userid))
        If dt.Rows.Count = 1 Then
            HttpContext.Current.Session("FirstName") = dt.Rows(0).Item("firstname").ToString
            Dim tmpAc As String = dt.Rows(0).Item("account_status")
            Select Case tmpAc
                Case "01- Channel Partner", "01-Platinum Channel Partner", "01-Premier Channel Partner", "02-Gold Channel Partner", "03-Certified Channel Partner"
                    Return AccountStatus.CP.ToString()
                Case "03-Premier Key Account", "04-Premier Key Account", "06G-Golden Key Account(ACN)", "06-Key Account"
                    Return AccountStatus.KA.ToString()
                Case "05-D&Ms PKA"
                    Return AccountStatus.DMS.ToString()
                Case "06P-Potential Key Account", "07-General Account", "08-General Account(List Price)", "12-Leads", "11-Prospect", "10-Sales Contact", "11-Sales Contact"
                    Return AccountStatus.GA.ToString()
                Case Else
                    Return AccountStatus.GA.ToString()
            End Select
        Else
            HttpContext.Current.Session("FirstName") = ""
            Return AccountStatus.GA.ToString()
        End If
    End Function

    Public Shared Sub SetSessionById(ByVal UID As String, Optional ByVal TempId As String = "", Optional ERPID As String = "")
        'Dim tmpERPId As String = ""
        Dim tmpERPId As String = ERPID
        HttpContext.Current.Session("TempId") = TempId
        If tmpERPId = "" Then

            If Util.IsInternalUser(UID) Then

                If MailUtil.IsInRole2("EMPLOYEE.AAU", UID) Then
                    tmpERPId = "AUQAI010"
                ElseIf MailUtil.IsInRole2("ATWCallCenter", UID) Then
                    tmpERPId = "2NC00001"
                ElseIf (MailUtil.IsInRole2("Employee.Tokyo", UID) OrElse MailUtil.IsInRole2("Employee.Osaka", UID)) Then
                    tmpERPId = "ADVAJP"
                ElseIf MailUtil.IsInRole2("EMPLOYEE.AKR", UID) Then
                    tmpERPId = "AKRJ00173"
                ElseIf MailUtil.IsInRole2("EMPLOYEE.ATH", UID) Then
                    tmpERPId = "ADVATH"
                ElseIf MailUtil.IsInRole2("EMPLOYEE.APL", UID) Then
                    tmpERPId = "UUAAESC"
                ElseIf MailUtil.IsInRole2("EMPLOYEE.MADRID", UID) Then
                    tmpERPId = "UUAAESC"
                ElseIf Util.IsFranchiser(UID, tmpERPId) Then
                    'tmpERPId = "AINI007"
                    'Ming 20150824 Champion Club 功能已取消
                    'ElseIf Util.IsPCP_Marcom(UID, tmpERPId) Then
                    'ElseIf Util.IsPHIUser(UID) Then
                    '    tmpERPId = "SSAO-SA"
                ElseIf UID.EndsWith("@advantech.eu", StringComparison.OrdinalIgnoreCase) Or
                    UID.EndsWith("@advantech.de", StringComparison.OrdinalIgnoreCase) Or
                    UID.EndsWith("@advantech.fr", StringComparison.OrdinalIgnoreCase) Or
                    UID.EndsWith("@advantech.nl", StringComparison.OrdinalIgnoreCase) Or
                    UID.EndsWith("@advantech-nl.nl", StringComparison.OrdinalIgnoreCase) Or
                     UID.EndsWith("@advantech.pl", StringComparison.OrdinalIgnoreCase) Or
                    UID.EndsWith("@advantech-uk.com", StringComparison.OrdinalIgnoreCase) Or
                    UID.EndsWith("@advantech.it", StringComparison.OrdinalIgnoreCase) Or
                    UID.EndsWith("@gpegint.com", StringComparison.OrdinalIgnoreCase) Then
                    tmpERPId = "UUAAESC"
                ElseIf UID.EndsWith("@advantech.com.cn", StringComparison.OrdinalIgnoreCase) Then
                    tmpERPId = "CKM4"
                ElseIf UID.EndsWith("@advantech.com.vn", StringComparison.OrdinalIgnoreCase) Then
                    tmpERPId = "VNESTORE"
                ElseIf UID.EndsWith("@advansus.com.tw", StringComparison.OrdinalIgnoreCase) _
                    OrElse UID.EndsWith("@advanixs.com", StringComparison.OrdinalIgnoreCase) _
                    OrElse UID.EndsWith("@advanixs.com.tw", StringComparison.OrdinalIgnoreCase) Then
                    tmpERPId = "ADVADS"
                ElseIf UID.EndsWith("@advantech.com.tw", StringComparison.OrdinalIgnoreCase) OrElse
                    UID.Equals("elvin.ng@advantech.com", StringComparison.OrdinalIgnoreCase) Then
                    tmpERPId = "ASPA001"
                ElseIf UID.EndsWith("@dlog.com", StringComparison.OrdinalIgnoreCase) OrElse UID.EndsWith("@advantech-dlog.com", StringComparison.OrdinalIgnoreCase) Then
                    '20170811 TC: Per discussion with June.Hsieh, Poki, Zack, Tina, use ADVADLOG as the customer id to check both ADLoG ITP and ACL ITP
                    '20160218 TC: Since all of ADLoG employees email have been changed to end with @advantech-dlog.com, we should let such emails still see ADLoG's price
                    tmpERPId = "ADVADLOG"
                ElseIf MailUtil.IsInRole2("EMPLOYEE.AENC.USA", UID) OrElse MailUtil.IsInRole2("EMPLOYEES.Irvine", UID) Then
                    tmpERPId = "UCAADV001"
                ElseIf MailUtil.IsInRole2("Employee.AID", UID) Then 'Per Guo-Lu's request set AID employee's default company id to ADVAID
                    tmpERPId = "ADVAID"
                ElseIf MailUtil.IsInRole2("Employee.PG.AMY", UID) Or
                    MailUtil.IsInRole2("Employee.KL.AMY", UID) Then 'Frank 2013/11/26
                    tmpERPId = "UUAASC"
                ElseIf MailUtil.IsInRole2("Aonline.ABR", UID) Then
                    tmpERPId = "BRC012955"
                ElseIf MailUtil.IsInRole2("Employee.BB.Ottawa", UID) Then
                    tmpERPId = "BBESTORE"
                ElseIf MailUtil.IsInRole2("Employee.BB.Ireland", UID) OrElse MailUtil.IsInRole2("BB.Sales.IE", UID) Then
                    tmpERPId = "ADVBBIR"
                ElseIf MailUtil.IsInRole2("Employee.BB.Conel", UID) Then
                    tmpERPId = "ADVBBCZ"
                Else
                    tmpERPId = "UAAC00100"
                End If

                ''----------------------------------------------------------------------------------------------------------------
                ''Frank 20141002:If temp erpid is not associate with any account on Siebel, then switch it to "UAAC00100"
                'Dim strSqlSiebelContact As String = String.Format(" select top 1 RBU, row_id as account_row_id, isnull(account_name,'') as account_name " & _
                '                                  " from siebel_account where RBU is not null and RBU<>'' and ERP_ID='{0}' " & _
                '                                  " order by account_status", tmpERPId)
                'Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                'Dim SiebDt As New DataTable
                'Dim da As New SqlClient.SqlDataAdapter(strSqlSiebelContact, sqlMA)
                'da.Fill(SiebDt)
                'If SiebDt.Rows.Count = 0 Then tmpERPId = "UAAC00100"
                ''----------------------------------------------------------------------------------------------------------------


            Else
                '20180402 TC: For B+B CP, when accessing MyA by my.advantech-bb.com, get ERPID from Siebel contact with Org ABB.
                Dim strSelectContact = String.Format("select top 1 erpid from siebel_contact where email_address='{0}' and erpid<>'' and erpid is not null and ACTIVE_FLAG ='Y' and OrgId<>'ABB' order by account_status", Replace(UID, "'", ""))
                If Util.GetRuntimeSiteUrl().ToLower().Contains("advantech-bb.com") Then
                    strSelectContact = String.Format("select top 1 erpid from siebel_contact where email_address='{0}' and erpid<>'' and erpid is not null and ACTIVE_FLAG ='Y' and OrgId='ABB' order by account_status", Replace(UID, "'", ""))
                End If

                Dim obj As Object = dbUtil.dbExecuteScalar("MY", strSelectContact)
                If obj IsNot Nothing Then
                    tmpERPId = obj.ToString()
                Else
                    obj = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 company_id from estore_member where email_addr='{0}' and company_id<>'' and company_id is not null ", Replace(UID, "'", "")))
                    If obj IsNot Nothing Then
                        tmpERPId = obj.ToString()
                    End If

                End If
                If Not MYSAPBIZ.is_Valid_Company_Id(tmpERPId) Then
                    tmpERPId = ""
                End If

                'Ryan 20170310 Hard Code for AJP users to set their user role as GA per YC's request.
                If tmpERPId.StartsWith("JJ") Then
                    Dim AJPobj As Object = dbUtil.dbExecuteScalar("MY", String.Format(" SELECT TOP 1 ORG_ID FROM SAP_DIMCOMPANY WHERE COMPANY_ID = '{0}'", tmpERPId))
                    If AJPobj IsNot Nothing AndAlso AJPobj.ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                        tmpERPId = String.Empty
                    End If
                End If
            End If

        End If


        'If tmpERPId = "" Then tmpERPId = "EDDEAA01"
        Dim au As New AuthUtil : Dim changFlag As Boolean = False
        HttpContext.Current.Session("user_id") = LCase(UID.Trim())
        HttpContext.Current.Response.Cookies("LoginId").Value = HttpContext.Current.Session("user_id")
        HttpContext.Current.Response.Cookies("LoginId").Expires = DateAdd(DateInterval.Month, 10, Date.Now())
        If tmpERPId <> "" Then
            If tmpERPId.Equals("UUAAESC", StringComparison.OrdinalIgnoreCase) OrElse
                CInt(dbUtil.dbExecuteScalar("MY",
                    "select COUNT(company_id) as c from SAP_DIMCOMPANY where COMPANY_ID='" + Replace(tmpERPId, "'", "''") + "' and ORG_ID in ('EU10','TW01') ")) = 2 Then
                Dim MultiOrgDt As DataTable = dbUtil.dbGetDataTable("MY", "select top 1 company_id, org_id from sap_company_org where company_id='" + tmpERPId + "' and IS_DEFAULT=1")
                If MultiOrgDt.Rows.Count = 0 Then
                    'au.ChangeCompanyId(tmpERPId, "EU10")
                    'Ming add 20140313 因台湾或美国也可能出现以上2笔数据，所以不能写死org为EU10
                    changFlag = au.ChangeCompanyId(tmpERPId)
                Else
                    changFlag = au.ChangeCompanyId(tmpERPId, MultiOrgDt.Rows(0).Item("org_id"))
                End If
            Else
                If tmpERPId = "ADVAID" Then
                    changFlag = au.ChangeCompanyId(tmpERPId, "TW01")
                ElseIf tmpERPId = "ADVADS" Then
                    changFlag = au.ChangeCompanyId(tmpERPId, "TW01")
                Else
                    changFlag = au.ChangeCompanyId(tmpERPId)
                End If
            End If
            If changFlag = False Then
                FormsAuthentication.SignOut()
                HttpContext.Current.Session.Abandon()
                'Dim ErrMsg As String = "This Order’s ERPID """ + tmpERPId + """ is invalid either because it does not exist in SAP or it is not a sold-to account"
                'Glob.ShowInfo(ErrMsg)
                HttpContext.Current.Response.Redirect("~/home.aspx", True)
            End If
        Else
            'Get RBU
            Dim dtCon As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 isnull(b.rbu,'') as rbu,ISNULL(b.PRIMARY_SALES_EMAIL,'') as PRIMARY_SALES_EMAIL from siebel_contact a left join siebel_account b on a.account_row_id=b.row_id where a.email_address='{0}' and ACTIVE_FLAG ='Y' order by a.account_status ", Replace(UID, "'", "")))
            If dtCon.Rows.Count > 0 Then
                Dim rbu As String = dtCon.Rows(0).Item("rbu").ToString
                If tmpERPId = "UUAAESC" And rbu = "ACL" Then rbu = "AEU"
                HttpContext.Current.Session("RBU") = rbu
                If rbu = "ADL" OrElse rbu = "AFR" OrElse rbu = "AIT" OrElse rbu = "ABN" OrElse rbu = "AUK" _
                     OrElse rbu = "AEE" OrElse rbu = "AMEA-Medical" OrElse rbu = "AINNOCORE" Then
                    Dim body As String = "Customer " + UID + " attempted to access MyAdvantech but failed.<br/>If he/she is indeed a channel partner or key account, please add this email to Siebel contact, and associate contact to a Siebel account, and then maintain correct ERPID and account status.<br/>Otherwise customer will be forwarded to eStore when login.</br>Thank you.<br/><br/>Best regards,<br/>MyAdvantech IT Team"
                    Dim sendTo As String = "marielle.severac@advantech.fr"
                    If dtCon.Rows(0).Item("PRIMARY_SALES_EMAIL").ToString <> "" Then
                        body = "Dear Sales,<br/><br/>" + body
                        sendTo = dtCon.Rows(0).Item("PRIMARY_SALES_EMAIL").ToString
                    Else
                        body = "Dear Marielle,<br/><br/>" + body
                    End If
                    Util.SendEmail(sendTo, "ebiz.aeu@advantech.eu", "MyAdvantech Access Error: customer " + UID + " without ERPID.", body, True, "tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw", "")
                End If
            End If
        End If
        'If Not au.ChangeCompanyId(tmpERPId) And tmpERPId <> "EDDEAA01" Then
        '    au.ChangeCompanyId("EDDEAA01")
        'End If
        If tmpERPId = "" Then
            HttpContext.Current.Session("account_status") = "GA"
        Else
            HttpContext.Current.Session("account_status") = AuthUtil.GetUserType(HttpContext.Current.Session("USER_ID")).ToString()
        End If

        If Util.IsInternalUser(HttpContext.Current.Session("user_id")) Then
            If Util.IsAdmin() Then
                HttpContext.Current.Session("user_role") = "administrator"
            Else
                HttpContext.Current.Session("user_role") = "logistics"
            End If
        Else
            HttpContext.Current.Session("user_role") = "buyer"
        End If

        If HttpContext.Current.Session("FirstName") = "" Then
            Dim ws As New SSO.MembershipWebservice
            Dim p As SSO.SSOUSER = ws.getProfile(HttpContext.Current.Session("user_id"), "MY")
            If p Is Nothing Then
                p = ws.getProfile(HttpContext.Current.Session("user_id"), "MY")
            End If
            If p IsNot Nothing Then
                HttpContext.Current.Session("FirstName") = p.first_name
            Else
                HttpContext.Current.Session("FirstName") = HttpContext.Current.Session("user_id").split("@")(0).ToString.Split(".")(0)
            End If
        End If

    End Sub

    Public Function ChangeCompanyId(ByVal companyid As String, Optional ByVal OrgId As String = "") As Boolean
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim iRet As New DataTable, sqlCmd As SqlClient.SqlCommand = Nothing

        Dim strSqlCompIdOrgId As String = String.Format(
            " select company_id, org_id, CURRENCY, company_name, PRICE_CLASS, SALESOFFICE " +
            " from sap_dimcompany " +
            " where org_id not in " + ConfigurationManager.AppSettings("InvalidOrg") + " " +
            " and company_id = '{0}' and company_type in ('partner','Z001') {1} ",
            Trim(companyid), IIf(OrgId <> "", " and org_id='" + OrgId + "' ", " "))
        If companyid.StartsWith("MX", StringComparison.CurrentCultureIgnoreCase) Then
            strSqlCompIdOrgId += " order by org_id desc"
        End If
        Dim sqlAptr As New SqlClient.SqlDataAdapter(strSqlCompIdOrgId, sqlMA)
        sqlAptr.Fill(iRet)
        If iRet.Rows.Count > 0 Then

            'Frank 2014/02/21: Table quotation_detail in MyAdvanGlobal is no longer in used. Therefore I comment out below 3 lines
            'sqlCmd = New SqlClient.SqlCommand("delete from quotation_detail where quote_id='" & HttpContext.Current.Session("cart_id") & "'", sqlMA)
            'If sqlMA.State <> ConnectionState.Open Then sqlMA.Open()
            'sqlCmd.ExecuteNonQuery()

            'dbUtil.dbExecuteNoQuery("B2B", "delete from quotation_detail where quote_id='" & HttpContext.Current.Session("cart_id") & "'")

            Dim strCompanyID As String = Trim(companyid)
            'ICC 2014/08/11 Check company id first. If it is not in siebel_account, then return false in this function.
            Dim strSqlSiebelContact As String = String.Format(" select top 1 RBU, row_id as account_row_id, isnull(account_name,'') as account_name, isnull(ACCOUNT_STATUS,'') as account_status " &
                                                              " from siebel_account where RBU is not null and RBU<>'' and ERP_ID='{0}' " &
                                                              " order by account_status", strCompanyID)
            Dim SiebDt As New DataTable
            Dim da As New SqlClient.SqlDataAdapter(strSqlSiebelContact, sqlMA)
            da.Fill(SiebDt)
            If SiebDt.Rows.Count > 0 Then
                HttpContext.Current.Session("RBU") = SiebDt.Rows(0).Item("RBU")
                HttpContext.Current.Session("account_row_id") = SiebDt.Rows(0).Item("account_row_id")
                HttpContext.Current.Session("account_name") = SiebDt.Rows(0).Item("account_name")
                HttpContext.Current.Session("company_account_status") = SiebDt.Rows(0).Item("account_status")
            Else



                '20150327 TC: For AJP do not check if Siebel Account exists, because many ERPID are not maintained on Siebel but they urgently need to use MyAdvantech to place order
                If String.Equals(iRet.Rows(0).Item("org_id").ToString(), "JP01", StringComparison.CurrentCultureIgnoreCase) Then
                    HttpContext.Current.Session("RBU") = "AJP" : HttpContext.Current.Session("account_row_id") = "N/A" : HttpContext.Current.Session("account_name") = "N/A"
                ElseIf iRet.Rows(0).Item("org_id").ToString().StartsWith("CN") Then
                    HttpContext.Current.Session("RBU") = "ACN" : HttpContext.Current.Session("account_row_id") = "N/A" : HttpContext.Current.Session("account_name") = "N/A"
                ElseIf String.Equals(iRet.Rows(0).Item("org_id").ToString(), "US01", StringComparison.CurrentCultureIgnoreCase) Then
                    HttpContext.Current.Session("RBU") = "ACL"
                    Try
                        Dim UsDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" select a.SALESOFFICE, b.RBU, COUNT(b.RBU) AS [SEQ] " &
                                                                      " from SAP_DIMCOMPANY a inner join SIEBEL_ACCOUNT b on a.COMPANY_ID=b.ERP_ID " &
                                                                      " where a.ORG_ID='US01' and a.SALESOFFICE=(select top 1 SALESOFFICE from SAP_DIMCOMPANY " &
                                                                      " where COMPANY_ID='{0}' and ORG_ID='US01' order by SALESOFFICE) group by a.SALESOFFICE, b.RBU order by a.SALESOFFICE, SEQ desc ", strCompanyID))
                        If UsDt IsNot Nothing AndAlso UsDt.Rows.Count > 0 AndAlso UsDt.Rows(0).Item("RBU") IsNot DBNull.Value AndAlso Not String.IsNullOrEmpty(UsDt.Rows(0).Item("RBU").ToString) Then
                            HttpContext.Current.Session("RBU") = UsDt.Rows(0).Item("RBU").ToString
                        End If
                    Catch ex As Exception
                    End Try
                    HttpContext.Current.Session("account_row_id") = "N/A" : HttpContext.Current.Session("account_name") = "N/A"
                ElseIf String.Equals(iRet.Rows(0).Item("company_id").ToString(), "ASGS002", StringComparison.CurrentCultureIgnoreCase) Then
                    HttpContext.Current.Session("RBU") = "ATW" : HttpContext.Current.Session("account_row_id") = "N/A" : HttpContext.Current.Session("account_name") = "N/A"
                ElseIf iRet.Rows(0).Item("company_id").ToString().ToUpper().StartsWith("ADVBB") Then
                    'ADVBBUS : B+B
                    HttpContext.Current.Session("RBU") = "ABB" : HttpContext.Current.Session("account_row_id") = "N/A" : HttpContext.Current.Session("account_name") = "N/A"
                Else

                    '20160323 TC: Do not consider Siebel Account anymore because many ERPIDs are still not well maintained on Siebel and we can't let this block sales to place order
                    HttpContext.Current.Session("RBU") = "ACL" : HttpContext.Current.Session("account_row_id") = "N/A" : HttpContext.Current.Session("account_name") = "N/A"


                End If
            End If

            'Ryan 20170209 If is ADV*** and has multiple select result, should take the TW01 one.
            If strCompanyID.ToUpper.StartsWith("ADV") Then
                If iRet.Rows.Count > 1 AndAlso iRet.Select("org_id = 'TW01'").Count > 0 Then
                    For Each dr As DataRow In iRet.Rows
                        If Not dr.Item("org_id").ToString.ToUpper.Equals("TW01") Then
                            dr.Delete()
                        End If
                    Next
                    iRet.AcceptChanges()
                End If
            End If

            'Ryan 20180625 Set case for TW20 launch 
            If iRet.Rows.Count > 1 AndAlso iRet.Select("org_id = 'TW20'").Count > 0 Then
                Dim sapcnt As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select COUNT(*) as count from SAPRDP.KNVV WHERE KUNNR = '{0}' AND VKORG = 'TW20' AND AUFSD = ' '", strCompanyID.ToUpper))
                If sapcnt IsNot Nothing AndAlso Integer.Parse(sapcnt) > 0 Then
                    For Each dr As DataRow In iRet.Rows
                        If Not dr.Item("org_id").ToString.ToUpper.Equals("TW20") Then
                            dr.Delete()
                        End If
                    Next
                    iRet.AcceptChanges()
                End If
            End If


            HttpContext.Current.Session("COMPANY_ID") = iRet.Rows(0).Item("company_id")
            HttpContext.Current.Session("COMPANY_PRICE_CLASS") = iRet.Rows(0).Item("PRICE_CLASS")
            HttpContext.Current.Session("COMPANY_CURRENCY") = iRet.Rows(0).Item("CURRENCY")
            HttpContext.Current.Session("company_name") = iRet.Rows(0).Item("company_name")
            HttpContext.Current.Session("org_id") = iRet.Rows(0).Item("org_id")

            '20170823 TC: add SAP sales office to session in order to determine if it's an AAC customer and show different price list download and lit req page per Adam.Strum's request
            HttpContext.Current.Session("SAP Sales Office") = iRet.Rows(0).Item("SALESOFFICE")

            'Ryan 20170323 Add ACN Storage Location Session for ACN 
            HttpContext.Current.Session("ACN_StorageLocation") = "1000"

            'ICC 20170811 Set org_id_cbom for ADLoG
            HttpContext.Current.Session("org_id_cbom") = HttpContext.Current.Session("org_id")
            If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso Not String.IsNullOrEmpty(HttpContext.Current.Session("org_id").ToString) AndAlso HttpContext.Current.Session("org_id").ToString.ToUpper.Equals("EU80") Then HttpContext.Current.Session("org_id_cbom") = "DL"

            If OrgId = "" Then
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 org_id from sap_company_org where company_id='{0}' and is_default=1", companyid))
                If obj IsNot Nothing Then
                    HttpContext.Current.Session("org_id") = obj.ToString
                End If
            End If
            If String.Equals(companyid, "CKM4") Then
                HttpContext.Current.Session("org_id") = "CN10"
                HttpContext.Current.Session("org_id_cbom") = "CN10"
                HttpContext.Current.Session("COMPANY_CURRENCY") = "CNY"
            End If
            If companyid.Trim.ToUpper = "ASPA001" Then
                HttpContext.Current.Session("org_id") = "TW01"
                HttpContext.Current.Session("org_id_cbom") = "TW01"
                HttpContext.Current.Session("COMPANY_CURRENCY") = "USD"
            End If
            If companyid.Trim.ToUpper = "AILR001" AndAlso OrgId = "" Then
                HttpContext.Current.Session("org_id") = "TW01"
                HttpContext.Current.Session("org_id_cbom") = "TW01"
                HttpContext.Current.Session("COMPANY_CURRENCY") = "USD"
            End If
            If companyid = "C300231" Then
                HttpContext.Current.Session("org_id") = "CN30"
                HttpContext.Current.Session("org_id_cbom") = "CN30"
            End If
            If companyid = "ATHADV" OrElse companyid = "ADVATH" Then
                HttpContext.Current.Session("org_id") = "TW01"
                HttpContext.Current.Session("org_id_cbom") = "TW01"
            End If
            If companyid.Trim.ToUpper = "AAEA010" Then
                HttpContext.Current.Session("COMPANY_CURRENCY") = "EUR"
            End If

            'If companyid = "ADVAJP" Then
            '    HttpContext.Current.Session("org_id") = "TW01"
            'End If
            'If companyid.Trim.ToUpper = "EURM001" Then
            '    HttpContext.Current.Session("org_id") = "TW01"
            'End If
            If HttpContext.Current.Session("org_id") = "EU50" Then HttpContext.Current.Session("org_id") = "EU10"
            If HttpContext.Current.Session("org_id") = "TW03" Then HttpContext.Current.Session("org_id") = "TW01"

            'Frank 2012/06/04: Stop using Session("org")
            'HttpContext.Current.Session("org") = Left(HttpContext.Current.Session("org_id").ToString, 2).ToUpper
            Select Case UCase(HttpContext.Current.Session("COMPANY_CURRENCY"))
                Case "NT", "TWD"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "NT"
                Case "US", "USD"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "$"
                Case "EUR"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "&euro;"
                Case "YEN", "JPY", "RMB", "CNY"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "&yen;"
                Case "GBP"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "&pound;"
                Case "AUD"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "AUD"
                Case "SGD"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "SGD"
                Case "MYR"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "RM"
                Case "KRW"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "₩"
                Case "VND"
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "VND"
                Case Else
                    HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "&euro;"
            End Select
            SetOrderid()
            Dim G_CATALOG_ID As String = ""
            UniqueID_Get(G_CATALOG_ID)
            HttpContext.Current.Session("G_CATALOG_ID") = G_CATALOG_ID

            If String.Equals(strCompanyID, "UUAAESC", StringComparison.CurrentCultureIgnoreCase) And String.Equals(HttpContext.Current.Session("RBU"), "ACL", StringComparison.CurrentCultureIgnoreCase) Then HttpContext.Current.Session("RBU") = "AEU"

            sqlMA.Close()
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Sub SetOrderid(Optional ByVal OldOrderid As String = "")
        If Not String.IsNullOrEmpty(OldOrderid) Then
            Dim cartM As New MyOrderDSTableAdapters.CART_MASTERTableAdapter
            cartM.DeleteCART_MASTERByCartid(OldOrderid)
            Dim cartD As New MyOrderDSTableAdapters.CART_DETAILTableAdapter
            cartD.DeleteCART_DETAILByCartid(OldOrderid)
        End If
        Dim strUniqueId As String = ""
        UniqueID_Get(strUniqueId)
        HttpContext.Current.Session("CART_ID") = strUniqueId
        HttpContext.Current.Session("LOGISTICS_ID") = strUniqueId
        HttpContext.Current.Session("ORDER_ID") = strUniqueId
        'Ming add 20131220 清空sieble quote带过来的OptyId，下单成功就清空
        If HttpContext.Current.Session IsNot Nothing AndAlso HttpContext.Current.Session("OptyId") IsNot Nothing Then
            HttpContext.Current.Session.Remove("OptyId")
        End If
        'end

        'Ryan 20170323 Reset ACN Storage Location back to 1000 (default)
        HttpContext.Current.Session("ACN_StorageLocation") = "1000"
    End Sub


    Public Shared Function Cart_Initiate(ByVal strCart_Id, ByVal strCurrency) As Boolean
        Dim l_strSQLCmd As String = String.Empty
        l_strSQLCmd = "delete from cart_master where cart_id = '" & strCart_Id & "'"
        dbUtil.dbExecuteScalar("MY", l_strSQLCmd)
        l_strSQLCmd = "delete from cart_detail where cart_id = '" & strCart_Id & "'"
        dbUtil.dbExecuteScalar("MY", l_strSQLCmd)
        l_strSQLCmd = "insert cart_master (cart_id,currency,checkout_flag) " &
            "values('" & strCart_Id & "'," &
            "'" & strCurrency & "'," &
            "'N')"
        dbUtil.dbExecuteScalar("MY", l_strSQLCmd)
        Return True
    End Function

    Public Shared Sub UniqueID_Get(ByRef strResult)
        strResult = Replace(System.Guid.NewGuid().ToString().ToUpper(), "-", "")
    End Sub

    Public Shared Sub LogUserAccess(ByVal strUniqueId As String, ByVal PWD As String)
        Try
            Dim l_strSQLCmd2 As String = "insert ACCESS_HISTORY_2013 (unique_id, session_id, login_date_time, userid, login_password, login_ip) " &
                       "values(" &
                       "'" & strUniqueId & "'," &
                       "'" & CStr(HttpContext.Current.Session.SessionID) & "',  " &
                       "Getdate()," &
                       "'" & HttpContext.Current.Session("USER_ID") & "', '" + Replace(PWD, "'", "''") + "'," &
                       "'" & Util.GetClientIP() & "')"
            'Dim sqlConn As SqlClient.SqlConnection = Nothing
            dbUtil.dbExecuteNoQuery("MY", l_strSQLCmd2)
        Catch ex As HttpException
        End Try
    End Sub

    Public Shared Function IsInterConUser() As Boolean
        If HttpContext.Current.User.Identity.IsAuthenticated = False Then Return False
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("RBU") Is Nothing Then Return False
        If HttpContext.Current.Session("RBU").ToString.Equals("HQDC", StringComparison.OrdinalIgnoreCase) OrElse HttpContext.Current.Session("RBU").ToString.Equals("ARU", StringComparison.OrdinalIgnoreCase) Then Return True
        If HttpContext.Current.Session("RBU").ToString.Equals("ANADMF", StringComparison.OrdinalIgnoreCase) Then
            Dim cmd As New SqlClient.SqlCommand("select count(a.row_id) from siebel_contact a inner join siebel_account b on a.account_row_id=b.row_id where a.email_address=@EM and b.country in ('Mexico') ",
                                                New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            cmd.Parameters.AddWithValue("EM", HttpContext.Current.User.Identity.Name)
            cmd.Connection.Open()
            Dim obj As Integer = cmd.ExecuteScalar()
            cmd.Connection.Close()
            If obj > 0 Then
                Return True
            End If
        End If
        Return False
    End Function
    Public Shared Function IsInterConUserV2(Optional ByVal companyid As String = "") As Boolean
        If HttpContext.Current.User.Identity.IsAuthenticated = False Then Return False
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("RBU") Is Nothing Then Return False
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("ORG_ID") Is Nothing Then Return False
        Dim RBU As String = HttpContext.Current.Session("RBU").ToString().ToUpper()
        Dim RBUList As New ArrayList
        With RBUList
            .Add("HQDC") : .Add("LATAM")
            .Add("AIN") : .Add("ARU")
            .Add("SAP") : .Add("AMX")
            .Add("ATH") : .Add("AAU")
        End With
        If RBUList.Contains(RBU) AndAlso HttpContext.Current.Session("ORG_ID").Equals("TW01") Then
            Return True
        End If
        'If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("COMPANY_ID") Is Nothing Then Return False
        'If String.IsNullOrEmpty(companyid) Then
        '    If HttpContext.Current.Session IsNot Nothing AndAlso HttpContext.Current.Session("COMPANY_ID") IsNot Nothing Then
        '        companyid = HttpContext.Current.Session("COMPANY_ID").ToString.Trim
        '    End If
        'End If
        'If String.IsNullOrEmpty(companyid) Then Return False
        'Dim RUB As Object = dbUtil.dbExecuteScalar("MY", String.Format("SELECT top 1 RBU FROM  dbo.SIEBEL_ACCOUNT WHERE ERP_ID='{0}' AND RBU <> '' AND RBU IS NOT NULL", companyid))
        'If RUB Is Nothing Then Return False
        'Dim cmd As New SqlClient.SqlCommand("select count(SIEBEL_RBU) AS RBUCOUNT FROM dbo.LEADSFLASHRBU_SIEBELRBU where FLASHLEADS_RBU ='InterCon' AND SIEBEL_RBU =@RBU ", _
        '                                    New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("CP").ConnectionString))
        '    cmd.Parameters.AddWithValue("RBU", RUB.ToString.Trim)
        '    cmd.Connection.Open()
        '    Dim obj As Integer = cmd.ExecuteScalar()
        '    cmd.Connection.Close()
        'If obj > 0 Then Return True
        Return False
    End Function

    Public Shared Function IsInterConUserV3() As Boolean
        If HttpContext.Current.Session("user_Id") IsNot Nothing Then
            If MailUtil.IsInMailGroup("InterCon.IAG", HttpContext.Current.Session("user_id")) OrElse
                MailUtil.IsInMailGroup("InterCon.Embedded", HttpContext.Current.Session("user_id")) OrElse
                MailUtil.IsInMailGroup("InterCon.iService", HttpContext.Current.Session("user_id")) Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsACN() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("CN10") Then
                Return True
            ElseIf HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("CN30") Then
                Return True
            ElseIf HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("CN70") Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsAEU() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("EU10") Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsBBUS() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("US10") Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsBBDropShipmentCustomer() As Boolean
        If HttpContext.Current.Session("company_id") IsNot Nothing And SAPDAL.SAPDAL.IsBBDropshipmentCustomer(HttpContext.Current.Session("company_id")) Then
            Return True
        End If

        Return False
    End Function



    Public Shared Function IsAJP() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("JP01") Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsAKR() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("KR01") Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsASG() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.Equals("SG01", StringComparison.InvariantCultureIgnoreCase) Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsADloG() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.Equals("EU80", StringComparison.InvariantCultureIgnoreCase) Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsAVN() As Boolean
        If HttpContext.Current.Session("ORG_ID") IsNot Nothing Then
            If HttpContext.Current.Session("ORG_ID").ToString.Equals("VN01", StringComparison.InvariantCultureIgnoreCase) Then
                Return True
            End If
        End If

        Return False
    End Function

    Public Shared Function IsBBUSPurchaser() As Boolean
        '20180106 TC: Add B+B PSM Mario as purchaser in order to let him be able to change company id to ADVBBUS
        If Util.IsMyAdvantechIT OrElse
            (HttpContext.Current.Session("user_id") IsNot Nothing AndAlso
            (HttpContext.Current.Session("user_id").ToString.Equals("m.eitutis@advantech-bb.com", StringComparison.OrdinalIgnoreCase) Or
            HttpContext.Current.Session("user_id").ToString.Equals("mbernardini@advantech-bb.com", StringComparison.OrdinalIgnoreCase) Or
            HttpContext.Current.Session("user_id").ToString.Equals("cszczygiel@advantech-bb.com", StringComparison.OrdinalIgnoreCase))) Then
            Return True
        End If

        Return False
    End Function

    Public Shared Function IsAVNMgt() As Boolean
        '20180106 TC: Add B+B PSM Mario as purchaser in order to let him be able to change company id to ADVBBUS
        If Util.IsMyAdvantechIT OrElse
            (HttpContext.Current.Session("user_id") IsNot Nothing AndAlso
            (HttpContext.Current.Session("user_id").ToString.Equals("Hau.Do@advantech.com.vn", StringComparison.OrdinalIgnoreCase) Or
            HttpContext.Current.Session("user_id").ToString.Equals("Hai.Ngo@advantech.com.vn", StringComparison.OrdinalIgnoreCase) Or
            HttpContext.Current.Session("user_id").ToString.Equals("thuy.nghiem@advantech.com.vn", StringComparison.OrdinalIgnoreCase) Or
            MailUtil.IsInMailGroup("GBS.ACL", HttpContext.Current.Session("user_id")))) Then
            Return True
        End If
        Return False
    End Function

    Public Shared Function IsEQV3() As Boolean
        If IsACN() OrElse IsBBUS() Then
            Return True
        End If

        Return False
    End Function

    Public Shared Function IsSensitivePage(ByVal PageName As String, ByRef PageClass As String) As Boolean
        Dim oPageName As DataTable = dbUtil.dbGetDataTable("My", "select  pagename from sensitivepage where  class='" & PageClass & "'")
        'If HttpContext.Current.Session("user_id") = "nada.liu@advantech.com.cn" Then
        '    HttpContext.Current.Response.Write(PageName) : HttpContext.Current.Response.End()
        'End If
        If oPageName.Rows.Count > 0 Then
            For Each dr As DataRow In oPageName.Rows
                If PageName.ToLower.Contains(dr.Item("pagename").ToString.ToLower) Then
                    Return True
                End If
            Next
        End If
        Return False
    End Function

    Public Shared Function IsCanPlaceOrder(ByVal userid As String) As Boolean
        Return GetPermissionByUser.CanPlaceOrder
        'Return True
        'If Util.IsInternalUser(userid) Then Return True
        'If HttpContext.Current.Session("account_status") Is Nothing OrElse HttpContext.Current.Session("account_status") = "GA" Then Return False
        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select a.ROW_ID, a.EMAIL_ADDR, c.NAME from S_CONTACT a inner join S_CONTACT_XM b on a.ROW_ID=b.PAR_ROW_ID inner join S_LST_OF_VAL c on b.NAME=c.ROW_ID where a.EMAIL_ADDR='{0}' and c.TYPE='CONTACT_MYADVAN_PVLG'", userid.ToLower))
        'If dt.Rows.Count > 0 Then
        '    For Each row As DataRow In dt.Rows
        '        If row.Item("NAME") = "Can Place Order" Then Return True
        '    Next
        'End If
        ''Dim OrderFlag As Integer = dbUtil.dbExecuteScalar("My", "select count(*) from contact where can_place_order=1 and userid='" & userid & "'")
        ''If OrderFlag > 0 Then
        ''    Return True
        ''Else
        'If CInt(dbUtil.dbExecuteScalar("RFM", String.Format("select count(order_no) as o from estore_order_log where user_id='{0}'", userid))) > 0 Then Return True
        ''End If
        'Return False
    End Function
    Public Shared Function IsCanSeeOrder(ByVal userid As String) As Boolean
        Return GetPermissionByUser.CanSeeOrder
        'Return True
        'If userid Is Nothing Then Return False
        'If Util.IsInternalUser(userid) Then Return True

        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select a.ROW_ID, a.EMAIL_ADDR, c.NAME from S_CONTACT a inner join S_CONTACT_XM b on a.ROW_ID=b.PAR_ROW_ID inner join S_LST_OF_VAL c on b.NAME=c.ROW_ID where a.EMAIL_ADDR='{0}' and c.TYPE='CONTACT_MYADVAN_PVLG'", userid.ToLower))
        'If dt.Rows.Count > 0 Then
        '    For Each row As DataRow In dt.Rows
        '        If row.Item("NAME") = "Can See Order" Then Return True
        '        If row.Item("NAME") = "Can Place Order" Then Return True
        '    Next
        'End If
        ''Dim OrderFlag As Integer = dbUtil.dbExecuteScalar("My", "select count(*) from contact where can_place_order=1 and userid='" & userid & "'")
        ''If OrderFlag > 0 Then
        ''    Return True
        ''Else
        'If CInt(dbUtil.dbExecuteScalar("RFM", String.Format("select count(order_no) as o from estore_order_log where user_id='{0}'", userid))) > 0 Then Return True
        ''End If
        'Return False
    End Function
    Public Shared Function IsCanSeeCost(ByVal userid As String) As Boolean
        Return GetPermissionByUser.CanSeeUnitPrice
        'If Util.IsInternalUser(userid) Then Return True
        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select a.ROW_ID, a.EMAIL_ADDR, c.NAME from S_CONTACT a inner join S_CONTACT_XM b on a.ROW_ID=b.PAR_ROW_ID inner join S_LST_OF_VAL c on b.NAME=c.ROW_ID where a.EMAIL_ADDR='{0}' and c.TYPE='CONTACT_MYADVAN_PVLG'", userid.ToLower))
        'If dt.Rows.Count > 0 Then
        '    For Each row As DataRow In dt.Rows
        '        If row.Item("NAME") = "View Cost" Then Return True
        '    Next
        'End If
        'Return False
    End Function

    Public Shared Function GetPermissionByUser() As UserPermission
        Dim upm As UserPermission = Nothing
        '20150722 TC: if session's user_permission isnot nothing but type isn't same with latest userpermission, then set session to nothing
        If HttpContext.Current.Session("user_permission") IsNot Nothing Then
            Try
                upm = HttpContext.Current.Session("user_permission")
            Catch ex As InvalidCastException
                upm = Nothing : HttpContext.Current.Session("user_permission") = Nothing
            End Try
        End If

        If HttpContext.Current.Session("user_permission") Is Nothing Then
            upm = New UserPermission
            HttpContext.Current.Session("user_permission") = upm
            'All user should be able to see list price as they can also see it on eStore
            upm.CanSeeListPrice = True
            If HttpContext.Current.User.Identity.IsAuthenticated Then
                '<-- Special case by Elena's request
                If HttpContext.Current.User.Identity.Name.ToLower = "kss@elticon.ru" Then
                    upm.CanSeeListPrice = False : upm.CanSeeOrder = False : upm.CanPlaceOrder = False : upm.CanSeeUnitPrice = False
                    Return upm
                End If

                'ICC 20170704 Remove this auth rule for BB user
                'Frank 20160315 for B+B
                'If HttpContext.Current.User.Identity.Name.ToLower.IndexOf("@advantech-bb.com") > 0 Then
                '    'Ryan 20161019 If is b+b power user defines in database, than is allowed to place order and see price.
                '    Dim obj_bbuser As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 userid from BB_UserList where userid='{0}'", HttpContext.Current.User.Identity.Name.ToLower))
                '    If obj_bbuser IsNot Nothing Then
                '        upm.CanSeeListPrice = True : upm.CanSeeOrder = True : upm.CanPlaceOrder = True : upm.CanSeeUnitPrice = True
                '    Else
                '        upm.CanSeeListPrice = False : upm.CanSeeOrder = False : upm.CanPlaceOrder = False : upm.CanSeeUnitPrice = False
                '    End If
                '    Return upm
                'End If


                '-->

                If HttpContext.Current.Session("account_status").ToString.Equals("GA", StringComparison.OrdinalIgnoreCase) Then
                    upm.CanSeeListPrice = True : upm.CanSeeOrder = False : upm.CanPlaceOrder = False : upm.CanSeeUnitPrice = False
                Else
                    'Please Rudy implement here
                    If Not HttpContext.Current.Session("account_status").ToString.Equals("EZ", StringComparison.OrdinalIgnoreCase) Then
                        'Get permission table from Siebel if it's a customer user
                        Dim crmConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString), dtPermission As New DataTable
                        'Dim crmApt As New SqlClient.SqlDataAdapter( _
                        '    " select distinct upper(c.NAME) as Permission_Value  " + _
                        '    " from S_CONTACT a inner join S_CONTACT_XM b on a.ROW_ID=b.PAR_ROW_ID inner join S_LST_OF_VAL c on b.NAME=c.ROW_ID  " + _
                        '    " where c.TYPE='CONTACT_MYADVAN_PVLG' " + _
                        '    " and lower(a.EMAIL_ADDR)=@EM " + _
                        '    " order by upper(c.NAME) ", crmConn)
                        Dim crmApt As New SqlClient.SqlDataAdapter(
                            " select distinct upper(PRIVILEGE) as Permission_Value from SIEBEL_CONTACT_PRIVILEGE where EMAIL_ADDRESS=@EM ", crmConn)
                        crmApt.SelectCommand.Parameters.AddWithValue("EM", HttpContext.Current.User.Identity.Name.ToLower())
                        crmApt.Fill(dtPermission)
                        If dtPermission.Select("Permission_Value='CAN SEE ORDER'").Length > 0 Then
                            upm.CanSeeOrder = True : upm.CanSeeUnitPrice = True
                        Else
                            upm.CanSeeOrder = False : upm.CanSeeUnitPrice = False
                        End If
                        If dtPermission.Select("Permission_Value='ACCOUNT ADMIN'").Length > 0 Then
                            upm.CanDoAccountAdmin = True
                        Else
                            upm.CanDoAccountAdmin = False
                        End If
                        'For Cristina's request: Add EIITER01 for special privilege setting
                        If AuthUtil.IsInterConUser() OrElse HttpContext.Current.Session("RBU") = "AIN" OrElse (HttpContext.Current.Session("company_id") IsNot Nothing _
                                                             AndAlso HttpContext.Current.Session("company_id").ToString = "EIITER01") Then
                            If dtPermission.Select("Permission_Value='VIEW COST'").Length > 0 Then
                                upm.CanSeeUnitPrice = True : upm.CanSeeListPrice = True
                            Else
                                upm.CanSeeUnitPrice = False : upm.CanSeeListPrice = True
                            End If
                        End If
                        If dtPermission.Select("Permission_Value='CAN PLACE ORDER'").Length > 0 Then
                            upm.CanSeeOrder = True : upm.CanSeeUnitPrice = True : upm.CanPlaceOrder = True
                        Else
                            upm.CanPlaceOrder = False
                        End If
                    Else
                        upm.CanSeeListPrice = True : upm.CanSeeOrder = True : upm.CanPlaceOrder = True : upm.CanSeeUnitPrice = True
                    End If
                End If
            End If
        Else
            upm = HttpContext.Current.Session("user_permission")
            If upm.CanPlaceOrder = Nothing OrElse upm.CanSeeUnitPrice = Nothing Then
                HttpContext.Current.Session("user_permission") = Nothing
                GetPermissionByUser()
            End If
        End If
        Return upm
    End Function

    Public Shared Function IsSSO(ByVal SessionId As String, ByVal Email As String) As Boolean
        If dbUtil.dbExecuteScalar("MYLOCAL_NEW", String.Format("select top 1 sessionid from mkt_user_log where sessionid='{0}' and userid='{1}' and timestamp between dateadd(day,-1,getdate()) and getdate()", SessionId, Email)) IsNot Nothing Then
            Return True
        Else
            Return False
        End If
    End Function

    <Serializable()>
    Public Class UserPermission
        Public CanSeeOrder As Boolean, CanPlaceOrder As Boolean, CanSeeListPrice As Boolean, CanSeeUnitPrice As Boolean, CanDoAccountAdmin As Boolean
        Public Sub New()
            CanSeeOrder = False : CanPlaceOrder = False : CanSeeListPrice = False : CanSeeUnitPrice = False : CanDoAccountAdmin = False
        End Sub
    End Class
    'ICC 2014/12/16 Move GetEZ function here to get email data from input
    Public Shared Function GetEZ(ByVal prefixText As String) As String()
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 10 PrimarySmtpAddress from ADVANTECH_ADDRESSBOOK where PrimarySmtpAddress like '{0}%' order by PrimarySmtpAddress", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = Global_Inc.DeleteZeroOfStr(dt.Rows(i).Item(0))
            Next
            Return str
        End If
        Return Nothing
    End Function
    'Public Shared Function VerifyCreditCardByPayPalService( _
    '        ByVal PoNum As String, ByVal InvoiceNum As String, ByVal Amount As Decimal, ByVal BillToStreet As String, ByVal BillToZip As String, _
    '        ByVal CreditCardNum As String, ByVal ExpireDate As Date, ByVal CVVCode As String, Optional CurrencyCode As String = "USD") As CreditCardAuthResult
    '    Dim CreditCardAuthResult1 As CreditCardAuthResult = Nothing
    '    Dim User As New PayPal.Payments.DataObjects.UserInfo("Advantech", "Advantech", "verisign", "2ws3ed4rf")
    '    Dim Connection As New PayPal.Payments.DataObjects.PayflowConnectionData("pilot-payflowpro.paypal.com")
    '    Dim Inv As New PayPal.Payments.DataObjects.Invoice
    '    Dim Amt As New PayPal.Payments.DataObjects.Currency(Amount, CurrencyCode)
    '    Inv.Amt = Amt : Inv.PoNum = PoNum : Inv.InvNum = InvoiceNum
    '    ' Set the Billing Address details.
    '    Dim Bill As New PayPal.Payments.DataObjects.BillTo
    '    Bill.Street = BillToStreet : Bill.Zip = BillToZip
    '    Inv.BillTo = Bill
    '    ' Create a new Payment Device - Credit Card data object.
    '    ' The input parameters are Credit Card No. and Expiry Date for the Credit Card.
    '    Dim CC As New PayPal.Payments.DataObjects.CreditCard(CreditCardNum, ExpireDate.ToString("MM") + Right(ExpireDate.Year.ToString(), 2))
    '    CC.Cvv2 = CVVCode

    '    ' Create a new Tender - Card Tender data object.
    '    Dim Card As New PayPal.Payments.DataObjects.CardTender(CC)
    '    '/////////////////////////////////////////////////////////////////

    '    ' Create a new Auth Transaction.
    '    Dim Trans As New PayPal.Payments.Transactions.AuthorizationTransaction(User, Connection, Inv, Card, PayPal.Payments.Common.Utility.PayflowUtility.RequestId)

    '    ' Submit the transaction.
    '    Dim Resp As PayPal.Payments.DataObjects.Response = Nothing
    '    Try
    '        Trans.SubmitTransaction()
    '    Catch ex As Exception
    '        Dim errCreditCardAuthResult As New CreditCardAuthResult
    '        errCreditCardAuthResult.cTransactionErrors = "Failed to connect to PayPal Authentication service. Error message: " + ex.Message
    '        Return errCreditCardAuthResult
    '    End Try
    '    If Not Resp Is Nothing Then
    '        Dim TrxnResponse As PayPal.Payments.DataObjects.TransactionResponse = Resp.TransactionResponse
    '        If Not TrxnResponse Is Nothing Then
    '            CreditCardAuthResult1 = New CreditCardAuthResult( _
    '                TrxnResponse.Result.ToString, TrxnResponse.Pnref, TrxnResponse.RespMsg, TrxnResponse.AuthCode, TrxnResponse.AVSAddr, _
    '                TrxnResponse.AVSZip, TrxnResponse.IAVS, TrxnResponse.CVV2Match, TrxnResponse.Duplicate)

    '            Dim FraudResp As PayPal.Payments.DataObjects.FraudResponse = Resp.FraudResponse
    '            If Not FraudResp Is Nothing Then
    '                CreditCardAuthResult1.cFraud_POSTFPSMSG = FraudResp.PostFpsMsg
    '                CreditCardAuthResult1.cFraud_PREFPSMSG = FraudResp.PreFpsMsg
    '            End If

    '            ' Get the Transaction Context and check for any contained SDK specific errors (optional code).
    '            Dim TransCtx As PayPal.Payments.Common.Context = Resp.TransactionContext
    '            If (Not TransCtx Is Nothing) And (TransCtx.getErrorCount() > 0) Then
    '                CreditCardAuthResult1.cTransactionErrors = TransCtx.ToString()
    '            End If
    '        End If
    '    End If
    '    If CreditCardAuthResult1 Is Nothing Then CreditCardAuthResult1 = New CreditCardAuthResult()
    '    Return CreditCardAuthResult1
    'End Function

    'ICC 2015/11/11 Hard code all Arrow company IDs.
    Public Shared Function IsArrowCompanyUser(ByVal company_ID As String)
        Dim arrowComList As List(Of String) = HttpContext.Current.Cache("ArrowCompanyIDs")
        If arrowComList Is Nothing Then
            arrowComList = New List(Of String)
            arrowComList.Add("UARROW001") : arrowComList.Add("UCAARR001") : arrowComList.Add("UCAARR002") : arrowComList.Add("UCAARR005")
            arrowComList.Add("UCAARR006") : arrowComList.Add("UCAARR009") : arrowComList.Add("UCOARR001") : arrowComList.Add("UGAARR002")
            arrowComList.Add("UIDARR001") : arrowComList.Add("UILARR001") : arrowComList.Add("UILARR004") : arrowComList.Add("UILARR005")
            arrowComList.Add("UKSARR001") : arrowComList.Add("UMAARR001") : arrowComList.Add("UMAARR002") : arrowComList.Add("UMAARR004")
            arrowComList.Add("UMDARR001") : arrowComList.Add("UMIARR001") : arrowComList.Add("UMNARR002") : arrowComList.Add("UNCARR001")
            arrowComList.Add("UNJARR001") : arrowComList.Add("UNMARR001") : arrowComList.Add("UONARR001") : arrowComList.Add("UONARR002")
            arrowComList.Add("UORARR002") : arrowComList.Add("UORARR003") : arrowComList.Add("UPAARR001") : arrowComList.Add("UPAARR002")
            arrowComList.Add("UPAARR003") : arrowComList.Add("UQCARR001") : arrowComList.Add("UQCARR002") : arrowComList.Add("UTXARR001")
            arrowComList.Add("UTXARR003") : arrowComList.Add("UTXARR004") : arrowComList.Add("UTXARR005") : arrowComList.Add("UWIARR001")
            arrowComList.Add("UWIARR002")

            ' Ryan 20180221 Add new list of IDs as below per Peter's mail
            arrowComList.Add("UONAVN001") : arrowComList.Add("UTXAVN005") : arrowComList.Add("UCAAVN001")
            arrowComList.Add("UKSAVN001") : arrowComList.Add("UPAAVN001") : arrowComList.Add("UMAAVN002")
            arrowComList.Add("UAZAVN007") : arrowComList.Add("UMNAVN004") : arrowComList.Add("UILAVN001")
            arrowComList.Add("UONAVN001") : arrowComList.Add("UTXAVN007") : arrowComList.Add("UNMAVN001")
            arrowComList.Add("UAZAVN003") : arrowComList.Add("UAZAVN002") : arrowComList.Add("UWIAVN003")
            arrowComList.Add("UONAVN002") : arrowComList.Add("UCAAVN011")

            HttpContext.Current.Cache.Add("ArrowCompanyIDs", arrowComList, Nothing, Now.AddHours(3), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        Return arrowComList.Contains(company_ID)
    End Function

    Public Shared Function IsCheckPointOrder(ByVal user_id As String, ByVal cart_id As String) As Boolean
        If ((user_id = "javian.tsai@advantech.com.tw") Or (Util.IsAdmin())) AndAlso (Advantech.Myadvantech.Business.CPDBBusinessLogic.CheckPointOrder2Cart_CartIDExist(cart_id)) Then
            Return True
        Else
            Return False
        End If
    End Function

End Class

'Public Class CreditCardAuthResult
'    Public cRESULT As String, cPNREF As String, cRESPMSG As String, cAUTHCODE As String, cAVSADDR As String, cAVSZIP As String, cIAVS As String, cCVV2MATCH As String, cDUPLICATE As String
'    Public cFraud_PREFPSMSG As String, cFraud_POSTFPSMSG As String, cTransactionErrors As String
'    Public Sub New(ByVal RESULT As String, ByVal PNREF As String, ByVal RESPMSG As String, ByVal AUTHCODE As String, ByVal AVSADDR As String, ByVal AVSZIP As String, _
'                   ByVal IAVS As String, ByVal CVV2MATCH As String, ByVal DUPLICATE As String)
'        Me.cRESULT = RESULT : Me.cPNREF = PNREF : Me.cRESPMSG = RESPMSG : Me.cAUTHCODE = AUTHCODE : Me.cAVSADDR = AVSADDR
'        Me.cAVSZIP = AVSZIP : Me.cIAVS = IAVS : Me.cCVV2MATCH = CVV2MATCH : Me.cDUPLICATE = DUPLICATE
'        cFraud_PREFPSMSG = "" : cFraud_POSTFPSMSG = "" : cTransactionErrors = ""
'    End Sub
'    Public Sub New()
'        Me.cRESULT = "" : Me.cPNREF = "" : Me.cRESPMSG = "" : Me.cAUTHCODE = "" : Me.cAVSADDR = ""
'        Me.cAVSZIP = "" : Me.cIAVS = "" : Me.cCVV2MATCH = "" : Me.cDUPLICATE = ""
'        cFraud_PREFPSMSG = "" : cFraud_POSTFPSMSG = "" : cTransactionErrors = ""
'    End Sub
'End Class

Public Class AEUIT_Rijndael
    Public Shared Function EncryptDefault(ByVal plainText As String) As String
        Dim paras() As String = Split(ConfigurationManager.AppSettings("EncryptPara"), "|")
        Return Encrypt(plainText, paras(0), paras(1), paras(2), paras(3), paras(4), paras(5))
    End Function
    Public Shared Function DecryptDefault(ByVal plainText As String) As String
        Dim paras() As String = Split(ConfigurationManager.AppSettings("EncryptPara"), "|")
        Return Decrypt(plainText, paras(0), paras(1), paras(2), paras(3), paras(4), paras(5))
    End Function
    Public Shared Function Encrypt(ByVal plainText As String,
                                   ByVal passPhrase As String,
                                   ByVal saltValue As String,
                                   ByVal hashAlgorithm As String,
                                   ByVal passwordIterations As Integer,
                                   ByVal initVector As String,
                                   ByVal keySize As Integer) _
                           As String
        'passPhrase = "GygY7788"        ' can be any string
        'saltValue = "rUbBishaCLiT"        ' can be any string
        'hashAlgorithm = "SHA1"             ' can be "MD5"
        'passwordIterations = 7                  ' can be any number
        'initVector = "gygyGYGYGGYYggyy" ' must be 16 bytes
        'keySize = 256                ' can be 192 or 128
        ' Convert strings into byte arrays.
        ' Let us assume that strings only contain ASCII codes.
        ' If strings include Unicode characters, use Unicode, UTF7, or UTF8 
        ' encoding.
        Dim initVectorBytes As Byte()
        initVectorBytes = Encoding.ASCII.GetBytes(initVector)

        Dim saltValueBytes As Byte()
        saltValueBytes = Encoding.ASCII.GetBytes(saltValue)

        ' Convert our plaintext into a byte array.
        ' Let us assume that plaintext contains UTF8-encoded characters.
        Dim plainTextBytes As Byte()
        plainTextBytes = Encoding.UTF8.GetBytes(plainText)

        ' First, we must create a password, from which the key will be derived.
        ' This password will be generated from the specified passphrase and 
        ' salt value. The password will be created using the specified hash 
        ' algorithm. Password creation can be done in several iterations.
        Dim password As PasswordDeriveBytes
        password = New PasswordDeriveBytes(passPhrase,
                                           saltValueBytes,
                                           hashAlgorithm,
                                           passwordIterations)

        ' Use the password to generate pseudo-random bytes for the encryption
        ' key. Specify the size of the key in bytes (instead of bits).
        Dim keyBytes As Byte()
        keyBytes = password.GetBytes(keySize / 8)

        ' Create uninitialized Rijndael encryption object.
        Dim symmetricKey As RijndaelManaged
        symmetricKey = New RijndaelManaged()

        ' It is reasonable to set encryption mode to Cipher Block Chaining
        ' (CBC). Use default options for other symmetric key parameters.
        symmetricKey.Mode = CipherMode.CBC

        ' Generate encryptor from the existing key bytes and initialization 
        ' vector. Key size will be defined based on the number of the key 
        ' bytes.
        Dim encryptor As ICryptoTransform
        encryptor = symmetricKey.CreateEncryptor(keyBytes, initVectorBytes)

        ' Define memory stream which will be used to hold encrypted data.
        Dim memoryStream As MemoryStream
        memoryStream = New MemoryStream()

        ' Define cryptographic stream (always use Write mode for encryption).
        Dim cryptoStream As CryptoStream
        cryptoStream = New CryptoStream(memoryStream,
                                        encryptor,
                                        CryptoStreamMode.Write)
        ' Start encrypting.
        cryptoStream.Write(plainTextBytes, 0, plainTextBytes.Length)

        ' Finish encrypting.
        cryptoStream.FlushFinalBlock()

        ' Convert our encrypted data from a memory stream into a byte array.
        Dim cipherTextBytes As Byte()
        cipherTextBytes = memoryStream.ToArray()

        ' Close both streams.
        memoryStream.Close()
        cryptoStream.Close()

        ' Convert encrypted data into a base64-encoded string.
        Dim cipherText As String
        cipherText = Convert.ToBase64String(cipherTextBytes)

        ' Return encrypted string.
        Encrypt = cipherText
    End Function

    Public Shared Function Decrypt(ByVal cipherText As String,
                                   ByVal passPhrase As String,
                                   ByVal saltValue As String,
                                   ByVal hashAlgorithm As String,
                                   ByVal passwordIterations As Integer,
                                   ByVal initVector As String,
                                   ByVal keySize As Integer) _
                           As String
        'passPhrase = "GygY7788"        ' can be any string
        'saltValue = "rUbBishaCLiT"        ' can be any string
        'hashAlgorithm = "SHA1"             ' can be "MD5"
        'passwordIterations = 7                  ' can be any number
        'initVector = "gygyGYGYGGYYggyy" ' must be 16 bytes
        'keySize = 256                ' can be 192 or 128
        ' Convert strings defining encryption key characteristics into byte
        ' arrays. Let us assume that strings only contain ASCII codes.
        ' If strings include Unicode characters, use Unicode, UTF7, or UTF8
        ' encoding.
        Dim initVectorBytes As Byte()
        initVectorBytes = Encoding.ASCII.GetBytes(initVector)

        Dim saltValueBytes As Byte()
        saltValueBytes = Encoding.ASCII.GetBytes(saltValue)

        ' Convert our ciphertext into a byte array.
        Dim cipherTextBytes As Byte()
        cipherTextBytes = Convert.FromBase64String(cipherText)

        ' First, we must create a password, from which the key will be 
        ' derived. This password will be generated from the specified 
        ' passphrase and salt value. The password will be created using
        ' the specified hash algorithm. Password creation can be done in
        ' several iterations.
        Dim password As PasswordDeriveBytes
        password = New PasswordDeriveBytes(passPhrase,
                                           saltValueBytes,
                                           hashAlgorithm,
                                           passwordIterations)

        ' Use the password to generate pseudo-random bytes for the encryption
        ' key. Specify the size of the key in bytes (instead of bits).
        Dim keyBytes As Byte()
        keyBytes = password.GetBytes(keySize / 8)

        ' Create uninitialized Rijndael encryption object.
        Dim symmetricKey As RijndaelManaged
        symmetricKey = New RijndaelManaged()

        ' It is reasonable to set encryption mode to Cipher Block Chaining
        ' (CBC). Use default options for other symmetric key parameters.
        symmetricKey.Mode = CipherMode.CBC

        ' Generate decryptor from the existing key bytes and initialization 
        ' vector. Key size will be defined based on the number of the key 
        ' bytes.
        Dim decryptor As ICryptoTransform
        decryptor = symmetricKey.CreateDecryptor(keyBytes, initVectorBytes)

        ' Define memory stream which will be used to hold encrypted data.
        Dim memoryStream As MemoryStream
        memoryStream = New MemoryStream(cipherTextBytes)

        ' Define memory stream which will be used to hold encrypted data.
        Dim cryptoStream As CryptoStream
        cryptoStream = New CryptoStream(memoryStream,
                                        decryptor,
                                        CryptoStreamMode.Read)

        ' Since at this point we don't know what the size of decrypted data
        ' will be, allocate the buffer long enough to hold ciphertext;
        ' plaintext is never longer than ciphertext.
        Dim plainTextBytes As Byte()
        ReDim plainTextBytes(cipherTextBytes.Length)

        ' Start decrypting.
        Dim decryptedByteCount As Integer
        decryptedByteCount = cryptoStream.Read(plainTextBytes,
                                               0,
                                               plainTextBytes.Length)

        ' Close both streams.
        memoryStream.Close()
        cryptoStream.Close()

        ' Convert decrypted data into a string. 
        ' Let us assume that the original plaintext string was UTF8-encoded.
        Dim plainText As String
        plainText = Encoding.UTF8.GetString(plainTextBytes,
                                            0,
                                            decryptedByteCount)

        ' Return decrypted string.
        Decrypt = plainText
    End Function

End Class

