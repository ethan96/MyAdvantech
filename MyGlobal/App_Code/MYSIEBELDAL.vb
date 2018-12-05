Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports SiebelBusObjectInterfaces
Imports System.Data.SqlClient

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantech.Siebel.DataAccessLayer")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class MYSIEBELDAL
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function GetChinaProductForecastByPartNo(ByVal PartNo As String) As DataTable
        Dim strSql As String = _
             "SELECT '' as GIP,'' AS [Desc], '' as LastBuyDate,IsNull(S_OPTY.CREATED,'') AS CREATED,IsNull(SUM_EFFECTIVE_DT,'') AS SUM_EFFECTIVE_DT, " + _
             "IsNull(S_PROD_INT.NAME,'') AS PART_NO, IsNull(S_USER.LOGIN,'') AS SALES_NAME, IsNull(S_PARTY.NAME,'') AS RBU, " + _
             "IsNull(S_OPTY.NAME,'') AS OPTY_NAME, IsNull(S_OPTY.DESC_TEXT,'') as DESC_TEXT, " + _
             "cast(IsNull(S_OPTY.SUM_WIN_PROB,0) as int) as SUM_WIN_PROB,   " + _
             "IsNull(S_OPTY.LAST_UPD,'') as LAST_UPD, IsNull(S_REVN.ROW_ID,'') as ROW_ID, IsNull(S_ORG_EXT.NAME,'') AS ACCOUNT_NAME,  " + _
             "IsNull(S_ORG_EXT.ROW_ID,'') as ACCOUNT_ROW_ID,IsNull(S_ORG_EXT.LOC,'') AS [SITE], IsNull(SUM_EFFECTIVE_DT,'') AS CLOSE_DATE, " + _
             "IsNull(S_OPTY.ROW_ID,'') as OPTY_ID, IsNull(S_REVN_X.ATTRIB_14,0) AS Jan_Qty, IsNull(S_REVN_X.ATTRIB_15,0) AS Feb_Qty, " + _
             "IsNull(S_REVN_X.ATTRIB_16,0) AS March_Qty, IsNull(S_REVN_X.ATTRIB_17,0) AS April_Qty,  " + _
             "IsNull(S_REVN_X.ATTRIB_18,0) AS May_Qty, IsNull(S_REVN_X.ATTRIB_19,0) AS June_Qty, IsNull(S_REVN_X.ATTRIB_20,0) AS July_Qty, " + _
             "IsNull(S_REVN_X.ATTRIB_21,0) AS Aug_Qty, IsNull(S_REVN_X.ATTRIB_22,0) AS Sept_Qty, IsNull(S_REVN_X.ATTRIB_23,0) AS Oct_Qty, " + _
             "IsNull(S_REVN_X.ATTRIB_24,0) AS Nov_Qty, IsNull(S_REVN_X.ATTRIB_25,0) AS Dec_Qty " + _
             "FROM S_REVN_X INNER JOIN S_REVN ON S_REVN_X.PAR_ROW_ID = S_REVN.ROW_ID INNER JOIN " + _
             "S_OPTY ON S_REVN.OPTY_ID = S_OPTY.ROW_ID INNER JOIN S_PROD_INT ON S_REVN.PROD_ID = S_PROD_INT.ROW_ID INNER JOIN " + _
             "S_POSTN ON S_REVN.CRDT_POSTN_ID = S_POSTN.PAR_ROW_ID INNER JOIN S_USER ON S_POSTN.PR_EMP_ID = S_USER.PAR_ROW_ID INNER JOIN " + _
             "S_PARTY ON S_REVN.BU_ID = S_PARTY.ROW_ID INNER JOIN S_ORG_EXT ON S_OPTY.PR_DEPT_OU_ID = S_ORG_EXT.ROW_ID " + _
             "where SUM_EFFECTIVE_DT between getdate()-30 and getdate()+30 and " + _
             "S_PARTY.NAME in ('ACN','ACN-E','ASH','AHZ','AWH','ACN-N','ABJ','ASY','AXA','ACN-S','AFZ','AGZ','AHK','ASZ','ACN-WS','ACD','ACQ') and S_PROD_INT.NAME='" & PartNo & "' " + _
             "order by S_OPTY.CREATED desc "
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("CRMDB75").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter(strSql, conn)
        apt.SelectCommand.Parameters.AddWithValue("PN", PartNo)
        Dim dt As New DataTable("ProductForecast")
        apt.Fill(dt)
        conn.Close()

        Dim GIP As String = ""
        Dim Desc As String = ""
        Dim lastBuyDate As String = ""

        Dim dtGIP As New DataTable
        Dim dtLastBuy As New DataTable
        Dim strGIP As String = String.Format("select isNull(a.PART_NO,'') AS PART_NO, isNull(a.PRODUCT_DESC,'') AS PRODUCT_DESC, isnull(b.EMAIL_ADDR,'') AS EMAIL_ADDR from " & _
                                             "SAP_PRODUCT a left join SAP_GIP_CONTACT b on a.GIP_CODE=b.GIP_CODE where a.PART_NO='{0}'", PartNo)
        Dim strLastBuyDate As String = String.Format("SELECT isnull(LAST_BUY_DATE,'') AS LAST_BUY_DATE FROM PLM_PHASEOUT WHERE ITEM_NUMBER='{0}'", PartNo)

        dtGIP = dbUtil.dbGetDataTable("B2B", strGIP)
        dtLastBuy = dbUtil.dbGetDataTable("B2B", strLastBuyDate)

        If dtGIP.Rows.Count > 0 Then
            GIP = dtGIP.Rows(0).Item("EMAIL_ADDR") : Desc = dtGIP.Rows(0).Item("PRODUCT_DESC")
        End If
        If dtLastBuy.Rows.Count > 0 Then
            lastBuyDate = dtLastBuy.Rows(0).Item("LAST_BUY_DATE")
        End If

        If dt.Rows.Count > 0 Then
            For Each r As DataRow In dt.Rows
                r.Item("GIP") = GIP
                r.Item("Desc") = Desc
                r.Item("LastBuyDate") = lastBuyDate
            Next
            dt.AcceptChanges()
        End If
        Return dt
    End Function

    <WebMethod()> _
    Public Function GetVisibleRBUByUser(ByVal EmployeeEmail As String) As String()
        Dim arrRBU As New ArrayList
        If MailUtil.IsInRole2("Sales.AEU", EmployeeEmail) OrElse MailUtil.IsInRole2("OP.AEU", EmployeeEmail) OrElse MailUtil.IsInRole2("BTOS-AESC", EmployeeEmail) _
            OrElse MailUtil.IsInRole2("AEU.DMF.Sales", EmployeeEmail) Then
            arrRBU.Add("ADL") : arrRBU.Add("AFR") : arrRBU.Add("AIT") : arrRBU.Add("ABN") : arrRBU.Add("AUK") : arrRBU.Add("AEE") : arrRBU.Add("AMEA-Medical")
        End If
        If MailUtil.IsInRole2("EMPLOYEES.DMFUS", EmployeeEmail) Or MailUtil.IsInRole2("Aonline.USA", EmployeeEmail) Then arrRBU.Add("ANADMF")
        If MailUtil.IsInRole2("ATWCallCenter", EmployeeEmail) Then arrRBU.Add("ATW")
        If MailUtil.IsInRole2("ASG Sales & Marcom", EmployeeEmail) Then
            arrRBU.Add("SAP") : arrRBU.Add("AMY") : arrRBU.Add("ASG")
        End If
        If MailUtil.IsInRole2("EMPLOYEES.Irvine", EmployeeEmail) Then arrRBU.Add("AENC")
        If MailUtil.IsInRole2("SALES.AAC.USA", EmployeeEmail) Then arrRBU.Add("AACIAG")
        If MailUtil.IsInRole2("InterCon.SALES", EmployeeEmail) Or MailUtil.IsInRole2("InterCon.Marketing", EmployeeEmail) Then arrRBU.Add("HQDC")
        If MailUtil.IsInRole2("info.in", EmployeeEmail) Then arrRBU.Add("AIN")
        If MailUtil.IsInRole2("ajp_sales_all", EmployeeEmail) Then arrRBU.Add("AJP")
        If MailUtil.IsInRole2("EMPLOYEE.AKR", EmployeeEmail) Then arrRBU.Add("AKR")
        If MailUtil.IsInRole2("SALES.AAU", EmployeeEmail) OrElse MailUtil.IsInRole2("AAU.MELBOURNE", EmployeeEmail) Then
            arrRBU.Add("AAU")
        End If
        If MailUtil.IsInRole2("Advantech-Innocore", EmployeeEmail) Then arrRBU.Add("AINNOCORE")
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
        Dim dt As New DataTable
        Dim apt As New SqlClient.SqlDataAdapter("select distinct RBU from SIEBEL_ACCOUNT where PRIMARY_SALES_EMAIL=@SM and RBU is not null and RBU<>'' order by RBU", conn)
        apt.SelectCommand.Parameters.AddWithValue("SM", EmployeeEmail)
        apt.Fill(dt)
        For Each r As DataRow In dt.Rows
            If Not arrRBU.Contains(r.Item("RBU")) Then arrRBU.Add(r.Item("RBU"))
        Next
        Return arrRBU.ToArray(GetType(String))
    End Function

    <WebMethod()> _
    Public Function HelloKiity() As String
        Return "Hello Kitty"
    End Function

    Public Shared Function IsAccountOwner(ByVal userid As String) As Boolean
        If dbUtil.dbGetDataTable("My", String.Format("select userid from MYADVANTECH_ACCOUNT_ADMIN_USERS where userid='{0}'", userid)).Rows.Count > 0 Then Return True Else Return False
    End Function

    Public Shared Function GetOwnerOfAccount(ByVal account_row_id As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT  b.USER_LOGIN, a.primary_flag, b.ROW_ID as POSITION_ID "))
            .AppendLine(String.Format(" FROM SIEBEL_ACCOUNT_OWNER AS a INNER JOIN SIEBEL_POSITION AS b ON a.OWNER_ID = b.CONTACT_ID "))
            .AppendLine(String.Format(" where b.USER_LOGIN is not null and b.USER_LOGIN<>'' and a.account_row_id='{0}' ", account_row_id.Replace("'", "")))
            .AppendLine(String.Format(" order by a.primary_flag desc  "))
        End With
        Return dbUtil.dbGetDataTable("RFM", sb.ToString())
    End Function
    Shared Function GET_Contact_Info_by_RowID(ByVal sales_ROWID As String) As DataTable
        Dim dt As New DataTable
        Dim str As String = String.Format("select TOP 1 ROW_ID, ISNULL(FST_NAME,'') AS FirstName ,ISNULL(MID_NAME,'') AS MiddleName, ISNULL(LAST_NAME,'') AS lastName, ISNULL(WORK_PH_NUM,'') AS workPhone,ISNULL(EMAIL_ADDR ,'')AS email_address,ISNULL(FAX_PH_NUM,'') as FaxNumber from S_CONTACT where ROW_ID='{0}'", sales_ROWID)
        dt = dbUtil.dbGetDataTable("CRMDB75", str)
        Return dt
    End Function
    Public Shared Function GetRBUFromAccountID(ByVal accountId As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 RBU from SIEBEL_ACCOUNT where ROW_ID='{0}'", Trim(accountId).Replace("'", "''")))
        If obj IsNot Nothing Then Return obj.ToString.ToUpper()
        Return "ACL"
    End Function

    Public Shared Function GetAdminCompany() As String
        Dim MySiebelWS As New MYSIEBELDAL
        Dim RBUs() As String = MySiebelWS.GetVisibleRBUByUser(HttpContext.Current.Session("user_id"))
        If RBUs.Length > 0 Then
            For i As Integer = 0 To RBUs.Length - 1
                RBUs(i) = "'" + Replace(RBUs(i), "'", "''") + "'"
            Next
            Dim InRBUString As String = String.Join(",", RBUs)
            Return "select distinct top 200 b.row_id, a.company_id, a.company_name, b.account_name, a.ORG_ID, b.RBU, a.SALESOFFICENAME, a.SALESGROUP, b.account_status from siebel_account b left join sap_dimcompany a on b.erp_id=a.company_id where a.DELETION_FLAG<>'X' and a.company_type in ('partner','Z001') and b.rbu in (" + InRBUString + ") "
        Else
            Return ""
        End If

    End Function

    Public Function CreateSiebelOpportunity( _
   ByVal strAccountRowId As String, ByVal strProjectName As String, ByVal strDescription As String, _
   ByVal strSalesStage As String, ByVal strRevenue As String, ByVal AssignToPartnerFlag As String, ByVal strOwner As String, _
   ByVal strCurrency As String, ByVal strReasonWonLost As String, ByVal strContact As String, ByVal ConnectToACL As Boolean, ByRef ErrMsg As String) As String
        Try
            Dim strOptID As String
            Dim bObj As SiebelBusObject = Nothing, bComp As SiebelBusComp = Nothing
            getSiebelConn("Opportunity", "Opportunity", bObj, bComp, ConnectToACL)
            With bComp
                .ActivateField("Name") : .ActivateField("Description") : .ActivateField("Sales Method") : .ActivateField("Sales Stage")
                .ActivateField("Primary Revenue Amount") : .ActivateField("Currency Code") : .ActivateField("Reason Won Lost")
                '.ActivateField("Primary Revenue Win Probability") : .ActivateField("Status")
                .ActivateField("Critical Success Factor")
                .ActivateField("AssignToPartner")
                .ActivateField("Account Id")
                .ActivateField("Channel")
                '.ActivateField("Contact")
                .SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
                .ClearToQuery()
                .NewRecord(1)
                .SetFieldValue("Name", strProjectName) : .SetFieldValue("Description", strDescription) : .SetFieldValue("Sales Method", "Funnel Sales Methodology")
                .SetFieldValue("Sales Stage", strSalesStage) : .SetFieldValue("Currency Code", strCurrency)
                .SetFieldValue("AssignToPartner", AssignToPartnerFlag)
                If strRevenue = "" Then
                    .SetFieldValue("Primary Revenue Amount", "0")
                Else
                    .SetFieldValue("Primary Revenue Amount", strRevenue)
                End If
                '.SetFieldValue("Primary Revenue Win Probability", strProbability) : .SetFieldValue("Status", strStatus)
                .SetFieldValue("Critical Success Factor", strReasonWonLost)
                .SetFieldValue("Reason Won Lost", strReasonWonLost)
                .SetFieldValue("Account Id", strAccountRowId)
                .SetFieldValue("Channel", "CSF")
                '.WriteRecord()
                'strOptID = .GetFieldValue("Id")
                '.ClearToQuery() : .SetViewMode(2) : .SetSearchSpec("Id", strOptID)
                '.ExecuteQuery(1)
            End With


            Dim oBCPick As SiebelBusObjectInterfaces.SiebelBusComp = Nothing
            Dim oBCMVG = Nothing
            Dim oBOEmployee As SiebelBusObject = Nothing, oBCEmployee As SiebelBusComp = Nothing
            If Not getSiebelConn("Employee", "Employee", oBOEmployee, oBCEmployee, True) Then Return ""
            Dim strPositionID As String = ""
            oBCEmployee.ActivateField("Login Name")
            oBCEmployee.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
            oBCEmployee.ClearToQuery()
            oBCEmployee.SetSearchSpec("Login Name", strOwner)
            oBCEmployee.ExecuteQuery(1)
            If oBCEmployee.FirstRecord Then strPositionID = oBCEmployee.GetFieldValue("Primary Position Id")

            oBCMVG = bComp.GetMVGBusComp("Sales Rep")
            oBCMVG.ActivateField("Active Login Name")
            oBCMVG.ActivateField("SSA Primary Field")
            oBCMVG.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
            oBCMVG.ClearToQuery()
            oBCMVG.SetSearchSpec("Active Login Name", strOwner)
            oBCMVG.ExecuteQuery(1)
            If oBCMVG.FirstRecord Then
                If oBCMVG.GetFieldValue("SSA Primary Field") <> "Y" Then bComp.SetFieldVale("Primary Position Id", strPositionID)
            Else
                oBCPick = oBCMVG.GetAssocBusComp
                oBCPick.ActivateField("Active Login Name")
                oBCPick.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
                oBCPick.ClearToQuery()
                oBCPick.SetSearchSpec("Active Login Name", strOwner)
                oBCPick.ExecuteQuery(1)
                If oBCPick.FirstRecord Then
                    oBCPick.Associate(0)
                    bComp.SetFieldValue("Primary Position Id", strPositionID)
                End If
            End If

            If strContact <> "" Then
                oBCMVG = Nothing
                oBCPick = Nothing
                oBCMVG = bComp.GetMVGBusComp("Contact")
                oBCPick = oBCMVG.GetAssocBusComp
                oBCPick.ActivateField("Contact Row Id")
                oBCPick.ActivateField("Row Id")
                oBCPick.ActivateField("Email Address")
                oBCPick.ActivateField("First Name")
                oBCPick.ActivateField("Last Name")
                oBCPick.SetViewMode(3)
                oBCPick.ClearToQuery()
                oBCPick.SetSearchSpec("Email Address", strContact)
                oBCPick.ExecuteQuery(1)
                If oBCPick.FirstRecord Then
                    oBCPick.Associate(0)
                End If
            End If


            bComp.WriteRecord()
            strOptID = bComp.GetFieldValue("Id")

            bComp = Nothing : bObj = Nothing
            Return strOptID
        Catch ex As Exception
            ErrMsg = ex.ToString() : Return ""
        End Try
    End Function

    Public Function CreateSiebelActivity( _
   ByVal Activity_Type As String, ByVal OptyID As String, ByVal PrimaryOwnerID As String, _
   ByVal AccountRowID As String, ByVal Description As String, ByVal Comment As String, _
   ByRef ErrMsg As String) As String
        Try
            Dim StrActivityID As String
            Dim oBO As SiebelBusObjectInterfaces.SiebelBusObject = Nothing
            Dim oBC As SiebelBusObjectInterfaces.SiebelBusComp = Nothing
            getSiebelConn("Action", "Action", oBO, oBC, True)
            With oBC
                .ActivateField("Type") : .ActivateField("Primary Owned By") : .ActivateField("Opportunity Id") : .ActivateField("Description")
                .ActivateField("Comment") : .ActivateField("Account Id")
                .NewRecord(1)
                .SetFieldValue("Type", Activity_Type) : .SetFieldValue("Primary Owned By", PrimaryOwnerID) : .SetFieldValue("Opportunity Id", OptyID)
                .SetFieldValue("Description", Description) : .SetFieldValue("Comment", Comment) : .SetFieldValue("Account Id", AccountRowID)
                .WriteRecord()
                StrActivityID = .GetFieldValue("Id")
                .ClearToQuery() : .SetViewMode(2) : .SetSearchSpec("Id", StrActivityID)
                .ExecuteQuery(1)
            End With
            oBC.WriteRecord()
            oBC = Nothing : oBO = Nothing
            Return StrActivityID
        Catch ex As Exception
            ErrMsg = ex.ToString() : Return ""
        End Try
    End Function


    Public Function CreateAccount( _
    ByVal strRegion As String, _
    ByVal strName As String, _
    ByVal strSite As String, _
    ByVal strMainPhone As String, _
    ByVal strMainFax As String, _
    ByVal strAccountType As String, _
    ByVal strURL As String, _
    ByVal strAccountStatus As String, _
    ByVal strAccountTeam As String, _
    ByVal strCity As String, _
    ByVal strCountry As String, _
    ByVal strZipCode As String, _
    ByVal strAddressLine1 As String, _
    ByVal strBAA As String, _
    ByVal strCurrency As String, _
    ByVal strPartner As String, _
    ByVal strOrganization As String, _
    ByVal strParentAccountID As String, _
    ByRef Error_Message As String) As String

        Try
            Dim oBOAccount As SiebelBusObject = Nothing, oBCAccount As SiebelBusComp = Nothing
            If Not getSiebelConn("Account", "Account", oBOAccount, oBCAccount, True) Then Return ""
            With oBCAccount
                .ActivateField("Region") : .ActivateField("Account ID") : .ActivateField("Name")
                .ActivateField("Location") : .ActivateField("Main Phone Number") : .ActivateField("Main Fax Number")
                .ActivateField("Type") : .ActivateField("Home Page") : .ActivateField("Account Status")
                .ActivateField("Sales Rep") : .ActivateField("City") : .ActivateField("Country")
                .ActivateField("Postal Code") : .ActivateField("Street Address")
                .ActivateField("Primary Biz App Area Id") : .ActivateField("Currency Code") : .ActivateField("Partner Flag")
                .ActivateField("Organization") : .ActivateField("Parent Account Id")
                .SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
                .ClearToQuery() : .NewRecord(1)
            End With

            With oBCAccount
                If strRegion <> "" Then .SetFieldValue("Region", strRegion) '.SetFieldValue("Account ID", strAccountID)
                .SetFieldValue("Name", strName)
                If strSite <> "" Then .SetFieldValue("Location", strSite)
                .SetFieldValue("Main Phone Number", strMainPhone)
                If strMainFax <> "" Then .SetFieldValue("Main Fax Number", strMainFax)
                If strURL <> "" Then .SetFieldValue("Home Page", strURL)
                .SetFieldValue("Account Status", strAccountStatus)
                .SetFieldValue("Currency Code", strCurrency)
                .SetFieldValue("Partner Flag", strPartner)
                .SetFieldValue("Parent Account Id", strParentAccountID)
                .SetFieldValue("Country", strCountry)
                If strCity <> "" Then .SetFieldValue("City", strCity)
                If strAddressLine1 <> "" Then .SetFieldValue("Street Address", strAddressLine1)
                If strZipCode <> "" Then .SetFieldValue("Postal Code", strZipCode)
                .SetFieldValue("Type", strAccountType)
            End With


            Dim oBCPick As SiebelBusObjectInterfaces.SiebelBusComp = Nothing

            Dim oBCMVG = Nothing
            oBCMVG = oBCAccount.GetMVGBusComp("Biz Application Area")
            oBCPick = Nothing
            oBCPick = oBCMVG.GetAssocBusComp
            oBCPick.ActivateField("Name")
            oBCPick.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
            oBCPick.ClearToQuery()
            oBCPick.SetSearchSpec("Name", strBAA)
            oBCPick.ExecuteQuery(1)
            If oBCPick.FirstRecord Then oBCPick.Associate(0)

            oBCMVG = Nothing
            oBCPick = Nothing
            oBCMVG = oBCAccount.GetMVGBusComp("Organization")
            oBCMVG.ActivateField("Name")
            oBCMVG.ActivateField("SSA Primary Field")
            oBCMVG.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
            oBCMVG.ClearToQuery()
            oBCMVG.SetSearchSpec("Name", strOrganization)
            oBCMVG.ExecuteQuery(1)
            Dim blnSetPrimaryOrg As Boolean = True
            If oBCMVG.FirstRecord Then
                If oBCMVG.GetFieldValue("SSA Primary Field") = "Y" Then blnSetPrimaryOrg = False
            Else
                oBCPick = oBCMVG.GetAssocBusComp
                oBCPick.ActivateField("Name")
                oBCPick.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
                oBCPick.ClearToQuery()
                oBCPick.SetSearchSpec("Name", strOrganization)
                oBCPick.ExecuteQuery(1)
                If oBCPick.FirstRecord Then oBCPick.Associate(0)
            End If
            If blnSetPrimaryOrg = True Then
                oBCMVG.ClearToQuery()
                oBCMVG.SetSearchSpec("Name", strOrganization)
                oBCMVG.ExecuteQuery(1)
                If oBCMVG.FirstRecord Then oBCMVG.SetFieldValue("SSA Primary Field", "Y")
            End If

            'Delete Old ACL Org - Add by Erika
            oBCMVG.ClearToQuery()
            oBCMVG.SetSearchSpec("Name", "ACL")
            oBCMVG.ExecuteQuery(1)
            If oBCMVG.FirstRecord Then oBCMVG.DeleteRecord()

            Dim oBOEmployee As SiebelBusObject = Nothing, oBCEmployee As SiebelBusComp = Nothing
            If Not getSiebelConn("Employee", "Employee", oBOEmployee, oBCEmployee, True) Then Return ""
            Dim strPositionID As String = ""
            oBCEmployee.ActivateField("Login Name")
            oBCEmployee.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
            oBCEmployee.ClearToQuery()
            oBCEmployee.SetSearchSpec("Login Name", strAccountTeam)
            oBCEmployee.ExecuteQuery(1)
            If oBCEmployee.FirstRecord Then strPositionID = oBCEmployee.GetFieldValue("Primary Position Id")

            oBCMVG = Nothing
            oBCPick = Nothing
            oBCMVG = oBCAccount.GetMVGBusComp("Sales Rep")
            oBCMVG.ActivateField("Active Login Name")
            oBCMVG.ActivateField("SSA Primary Field")
            oBCMVG.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
            oBCMVG.ClearToQuery()
            oBCMVG.SetSearchSpec("Active Login Name", strAccountTeam)
            oBCMVG.ExecuteQuery(1)
            If oBCMVG.FirstRecord Then
                If oBCMVG.GetFieldValue("SSA Primary Field") <> "Y" Then oBCAccount.SetFieldVale("Primary Position Id", strPositionID)
            Else
                oBCPick = oBCMVG.GetAssocBusComp
                oBCPick.ActivateField("Active Login Name")
                oBCPick.SetViewMode(SiebelApplicationServer.__MIDL___MIDL_itf_sappsrv_0000_0003.AllView)
                oBCPick.ClearToQuery()
                oBCPick.SetSearchSpec("Active Login Name", strAccountTeam)
                oBCPick.ExecuteQuery(1)
                If oBCPick.FirstRecord Then
                    oBCPick.Associate(0)
                    oBCAccount.SetFieldValue("Primary Position Id", strPositionID)
                End If
            End If

            oBCAccount.WriteRecord()

            Dim strAccountID As String = oBCAccount.GetFieldValue("Id")

            oBOAccount = Nothing
            oBCAccount = Nothing
            Return strAccountID
        Catch ex As Exception
            Error_Message = ex.ToString() : Return ""
        End Try
    End Function

    Public Shared Function getSiebelConn( _
   ByVal BusObjName As String, ByVal BusCompName As String, ByRef BusObj As SiebelBusObject, _
   ByRef BusComp As SiebelBusComp, Optional ByVal ConnectToACLSiebel As Boolean = False) As Boolean
        If Not ConnectToACLSiebel Then
            Dim OwnerID As String = ConfigurationManager.AppSettings("CRMEUId")
            Dim OwnerPassword As String = ConfigurationManager.AppSettings("CRMEUPwd")
            Dim connStr As String = "host=" + """siebel://" + ConfigurationManager.AppSettings("CRMEUConnString") + """"
            Dim lng As String = " lang=" + """ENU"""
            Dim SiebelApplication As New SiebelBusObjectInterfaces.SiebelDataControl
            Dim blnConnected As Boolean = SiebelApplication.Login(connStr + lng, OwnerID, OwnerPassword)
            If Not blnConnected Then
                Throw New Exception("Can't connect to Siebel")
            End If
            BusObj = SiebelApplication.GetBusObject(BusObjName) : BusComp = BusObj.GetBusComp(BusCompName)
            Return True
        Else
            Dim OwnerID As String = ConfigurationManager.AppSettings("CRMHQId")
            Dim OwnerPassword As String = ConfigurationManager.AppSettings("CRMHQPwd")
            Dim connStr As String = "host=" + """siebel://" + ConfigurationManager.AppSettings("CRMHQConnString") + """"
            Dim lng As String = " lang=" + """ENU"""
            Dim SiebelApplication As New SiebelBusObjectInterfaces.SiebelDataControl
            Dim blnConnected As Boolean = SiebelApplication.Login(connStr + lng, OwnerID, OwnerPassword)
            If Not blnConnected Then
                Throw New Exception("Can't connect to Siebel")
            End If
            BusObj = SiebelApplication.GetBusObject(BusObjName) : BusComp = BusObj.GetBusComp(BusCompName)
            Return True
        End If

    End Function

    Public Shared Function SyncSiebelOpty(ByVal rid As String) As Boolean
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct A.ROW_ID,  "))
            .AppendLine(String.Format(" A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, "))
            .AppendLine(String.Format(" A.NAME, "))
            .AppendLine(String.Format(" A.SUM_REVN_AMT,  "))
            .AppendLine(String.Format(" A.SUM_REVN_AMT as REVENUE_US_AMT, "))
            .AppendLine(String.Format(" A.SUM_WIN_PROB, "))
            .AppendLine(String.Format(" A.CURR_STG_ID,  "))
            .AppendLine(String.Format(" IsNull(B.NAME,'') as STAGE_NAME, "))
            .AppendLine(String.Format(" A.BU_ID, "))
            .AppendLine(String.Format(" C.NAME as BU_NAME, "))
            .AppendLine(String.Format(" A.CREATED, "))
            .AppendLine(String.Format(" E.LOGIN as CREATED_BY_LOGIN, "))
            .AppendLine(String.Format(" (select G.FST_NAME + ' ' + G.LAST_NAME  from S_CONTACT G where G.ROW_ID = E.ROW_ID) as CREATED_BY_NAME, "))
            .AppendLine(String.Format(" A.CURCY_CD, "))
            .AppendLine(String.Format(" IsNull(A.DESC_TEXT,'') as DESC_TEXT, "))
            .AppendLine(String.Format(" A.LAST_UPD, "))
            .AppendLine(String.Format(" F.LOGIN as LAST_UPD_BY_LOGIN, "))
            .AppendLine(String.Format(" (select H.FST_NAME + ' ' + H.LAST_NAME  from  S_CONTACT H where H.ROW_ID = F.ROW_ID) as LAST_UPD_BY_NAME, "))
            .AppendLine(String.Format(" A.PR_POSTN_ID, "))
            .AppendLine(String.Format(" D.POSTN_TYPE_CD, "))
            .AppendLine(String.Format(" IsNull(A.PR_PROD_ID,'') as PR_PROD_ID, "))
            .AppendLine(String.Format(" IsNull(A.REASON_WON_LOST_CD,'') as REASON_WON_LOST_CD, "))
            .AppendLine(String.Format(" A.STATUS_CD, "))
            .AppendLine(String.Format(" IsNull(A.STG_NAME,'') as STG_NAME, "))
            .AppendLine(String.Format(" I.LOGIN as SALES_TEAM_LOGIN, "))
            .AppendLine(String.Format(" (select J.FST_NAME + ' ' + J.LAST_NAME  from  S_CONTACT J where J.ROW_ID = I.ROW_ID) as SALES_TEAM_NAME, "))
            .AppendLine(String.Format(" A.MODIFICATION_NUM, "))
            .AppendLine(String.Format(" A.SUM_EFFECTIVE_DT, "))
            .AppendLine(String.Format(" IsNull(A.PAR_OPTY_ID,'') as PAR_OPTY_ID, "))
            .AppendLine(String.Format(" (case when isnull(A.SUM_WIN_PROB,0)= 0 then A.SUM_REVN_AMT*(A.SUM_WIN_PROB/100) else 0 end) as EXPECT_VAL, "))
            .AppendLine(String.Format(" IsNull((select convert(varchar(300),SCT.CRIT_SUCC_FACTORS) from  S_OPTY_T SCT where SCT.ROW_ID = SC.ROW_ID),'') as FACTOR, "))
            .AppendLine(String.Format(" IsNull((select top 1 CN.FST_NAME + ' ' + CN.LAST_NAME from S_CONTACT CN inner join S_OPTY_CON CON on CN.ROW_ID = CON.PER_ID where CON.OPTY_ID = A.ROW_ID),'') as CONTACT,  "))
            .AppendLine(String.Format(" (select top 1 CON.PER_ID from S_OPTY_CON CON where CON.OPTY_ID = A.ROW_ID) as CONTACT_ROW_ID, "))
            .AppendLine(String.Format(" A.SALES_METHOD_ID,  "))
            .AppendLine(String.Format(" IsNull((select SM.NAME from S_SALES_METHOD SM where SM.ROW_ID=A.SALES_METHOD_ID),'') as SALES_METHOD_NAME, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_10 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),'') as Assign_To_Partner, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_06 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),'') as BusinessGroup, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_22 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Incentive_For_RBU, "))
            .AppendLine(String.Format(" IsNull((select X.X_ATTRIB_53 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),'') as Indicator, "))
            .AppendLine(String.Format(" IsNull((select X.X_ATTRIB_54 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Product_Revenue, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_42 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Profile_Revenue, "))
            .AppendLine(String.Format(" IsNull((select X.ATTRIB_14 from S_OPTY_X X where X.ROW_ID=A.ROW_ID),0) as Quantity, "))
            .AppendLine(String.Format(" IsNull(A.CHANNEL_TYPE_CD,'') as Channel, "))
            .AppendLine(String.Format(" D.PR_EMP_ID, "))
            .AppendLine(String.Format(" A.PR_DEPT_OU_ID, "))
            .AppendLine(String.Format(" Year(A.CREATED) as CREATE_YEAR, "))
            .AppendLine(String.Format(" A.PR_PRTNR_ID,  "))
            .AppendLine(String.Format(" cast('' as nvarchar(100)) as PART_NO, "))
            .AppendLine(String.Format(" IsNull(X.ATTRIB_46,'') as ChannelContact,  "))
            .AppendLine(String.Format(" IsNull((select top 1 NAME from S_INDUST where ROW_ID=A.X_PR_OPTY_BAA_ID),'') as Primary_Opty_BAA "))
            .AppendLine(String.Format(" from  S_OPTY A left outer join S_OPTY_X X on A.ROW_ID=X.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_STG B on A.CURR_STG_ID = B.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_BU C on A.BU_ID = C.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_POSTN D on A.PR_POSTN_ID = D.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_USER E on A.CREATED_BY = E.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_USER F on A.LAST_UPD_BY = F.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_USER I on D.PR_EMP_ID = I.ROW_ID "))
            .AppendLine(String.Format(" left outer join  S_OPTY_T SC on SC.PAR_ROW_ID = A.ROW_ID  "))
            .AppendLine(String.Format(" where A.ROW_ID ='{0}' ", rid))
        End With
        Try
            Dim newOptyDt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
            If newOptyDt.Rows.Count > 0 Then
                Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                bk.DestinationTableName = "siebel_opportunity"
                dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_opportunity where row_id ='{0}'", rid))
                bk.WriteToServer(newOptyDt)
                Return True
                'Throw New Exception("Sync " + newOptyDt.Rows.Count.ToString())
            End If

        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "Sync Opty " + rid + " failed", ex.ToString(), False, "", "")
            'Throw ex
            Return False
        End Try
    End Function

    Public Shared Function CreateOpportunity(ByVal strPosid As String, ByVal strAdminEmail As String, ByVal strContactAccountId As String, _
                                            ByVal strContactId As String, ByVal strOptyName As String, ByVal strOptyComment As String, ByVal strSrcId As String) As String
        Dim strRBU As String = "ACL"
        If Not GetSalesOwnerRBU(strAdminEmail, strRBU) Then strRBU = "ACL"
        Dim eCovWs As New eCoverageWS.WSSiebel, emp As New eCoverageWS.EMPLOYEE, opty As New eCoverageWS.OPPTY
        emp.USER_ID = ConfigurationManager.AppSettings("CRMHQId") : emp.PASSWORD = ConfigurationManager.AppSettings("CRMHQPwd")
        With opty
            .ACC_ROW_ID = strContactAccountId : .CLOSE_DATE = DateAdd(DateInterval.Month, 1, Now) : .CON_ROW_ID = strContactId
            .CURRENCY_CODE = "USD" : .DESP = strOptyComment : .ORG = strRBU : .OWNER_EMAIL = strAdminEmail
            .PROJ_NAME = strOptyName : .SALES_METHOD = "Funnel Sales Methodology" : .SALES_STAGE = "5% New Lead"
            If String.IsNullOrEmpty(strSrcId) = False Then .SRC_ID = strSrcId
        End With
        Dim res As eCoverageWS.RESULT = eCovWs.AddOppty(emp, opty)
        Return res.ROW_ID
    End Function

    Public Shared Function GetSalesOwnerRBU(ByVal AdminEmail As String, ByRef AdminRBU As String) As Boolean
        Dim cmd As New SqlClient.SqlCommand( _
                   "select top 1 OrgId from SIEBEL_CONTACT where EMAIL_ADDRESS =@ADMINMAIL and OrgId is not null and OrgId<>'' order by ROW_ID ", _
                   New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("ADMINMAIL", AdminEmail)
        cmd.Connection.Open()
        Dim obj As Object = cmd.ExecuteScalar()
        cmd.Connection.Close()
        If obj IsNot Nothing Then
            AdminRBU = obj.ToString() : Return True
        End If
        Return False
    End Function
    Public Shared Function CreateAccount(ByRef Acc As eCoverageWS.ACCOUNT) As String
        Dim ws As New eCoverageWS.WSSiebel, emp As New eCoverageWS.EMPLOYEE
        emp.USER_ID = ConfigurationManager.AppSettings("CRMHQId") : emp.PASSWORD = ConfigurationManager.AppSettings("CRMHQPwd")
        Dim res As eCoverageWS.RESULT = Nothing, retstr As String = String.Empty
        Try
            res = ws.AddAccount(emp, Acc)
            If res IsNot Nothing AndAlso Not String.IsNullOrEmpty(res.ROW_ID) AndAlso Not String.Equals(res.ROW_ID, "null", StringComparison.InvariantCultureIgnoreCase) Then
                Threading.Thread.Sleep(3000)
                MYSIEBELDAL.SyncAccountFromSiebel2MyAdvantech(res.ROW_ID)
                retstr = res.ROW_ID
            End If
        Catch ex As Exception
            'Call MailUtil.Utility_EMailPage("ming.zhao@advantech.com.cn", "myadvantech@advantech.com", "", "ming.zhao@advantech.com.cn", "Create Siebel Account Faild: MySiebelDAL.vb lineno:587", "", ex.Message.ToString)
            Util.InsertMyErrLog("Create Siebel Account Faild: MySiebelDAL.vb lineno:587." + vbTab + ex.ToString)
        End Try
        Return retstr
    End Function
    Public Shared Function SyncAccountFromSiebel2MyAdvantech(ByVal RowId As String) As Boolean
        If String.IsNullOrEmpty(RowId) Then Return False
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select a.ROW_ID, "))
            .AppendLine(String.Format(" IsNull(b.ATTRIB_05,'') as ERP_ID,  "))
            .AppendLine(String.Format(" a.NAME as ACCOUNT_NAME,  "))
            .AppendLine(String.Format(" a.CUST_STAT_CD as ACCOUNT_STATUS, "))
            .AppendLine(String.Format(" IsNull(a.MAIN_FAX_PH_NUM, '') as FAX_NUM,  "))
            .AppendLine(String.Format(" IsNull(a.MAIN_PH_NUM, '') as PHONE_NUM,  "))
            .AppendLine(String.Format(" IsNull(a.OU_TYPE_CD, '') as OU_TYPE_CD,  "))
            .AppendLine(String.Format(" IsNull(a.URL, '') as URL,  "))
            .AppendLine(String.Format(" IsNull(b.ATTRIB_34, '') as BusinessGroup,  "))
            .AppendLine(String.Format(" IsNull(a.OU_TYPE_CD, '') as ACCOUNT_TYPE, "))
            .AppendLine(String.Format(" IsNull(c.NAME, '') as RBU, "))
            .AppendLine(String.Format(" IsNull( "))
            .AppendLine(String.Format(" 	( "))
            .AppendLine(String.Format(" 		select EMAIL_ADDR from S_CONTACT where ROW_ID in  "))
            .AppendLine(String.Format(" 		( "))
            .AppendLine(String.Format(" 			select PR_EMP_ID from S_POSTN where ROW_ID in  "))
            .AppendLine(String.Format(" 			( "))
            .AppendLine(String.Format(" 				select PR_POSTN_ID "))
            .AppendLine(String.Format(" 				from S_ORG_EXT  "))
            .AppendLine(String.Format(" 				where ROW_ID=a.ROW_ID "))
            .AppendLine(String.Format(" 			) "))
            .AppendLine(String.Format(" 		)  "))
            .AppendLine(String.Format(" 	) "))
            .AppendLine(String.Format(" ,'') as PRIMARY_SALES_EMAIL, "))
            .AppendLine(String.Format(" a.PAR_OU_ID as PARENT_ROW_ID, "))
            .AppendLine(String.Format(" IsNull(b.ATTRIB_09,'N') as MAJORACCOUNT_FLAG, "))
            .AppendLine(String.Format(" IsNull(a.CMPT_FLG,'N') as COMPETITOR_FLAG, "))
            .AppendLine(String.Format(" IsNull(a.PRTNR_FLG,'N') as PARTNER_FLAG, "))
            .AppendLine(String.Format(" IsNull(d.COUNTRY,'') as COUNTRY, "))
            .AppendLine(String.Format(" IsNull(d.CITY,'') as CITY, "))
            .AppendLine(String.Format(" IsNull(d.ADDR,'') as ADDRESS, "))
            .AppendLine(String.Format(" IsNull(d.STATE,'') as STATE, "))
            .AppendLine(String.Format(" IsNull(d.ZIPCODE,'') as ZIPCODE, "))
            .AppendLine(String.Format(" IsNull(d.PROVINCE,'') as PROVINCE, "))
            .AppendLine(String.Format(" IsNull( "))
            .AppendLine(String.Format(" 	( "))
            .AppendLine(String.Format(" 		select top 1 NAME from S_INDUST where ROW_ID=a.X_ANNIE_PR_INDUST_ID "))
            .AppendLine(String.Format(" 	),'N/A') as BAA, "))
            .AppendLine(String.Format(" a.CREATED, "))
            .AppendLine(String.Format(" a.LAST_UPD as LAST_UPDATED, "))
            .AppendLine(String.Format(" IsNull( "))
            .AppendLine(String.Format(" 	(			 "))
            .AppendLine(String.Format(" 		select top 1 e.NAME from S_PARTY e inner join S_POSTN f on e.ROW_ID=f.OU_ID where f.ROW_ID in  "))
            .AppendLine(String.Format(" 			( "))
            .AppendLine(String.Format(" 				select PR_POSTN_ID "))
            .AppendLine(String.Format(" 				from S_ORG_EXT  "))
            .AppendLine(String.Format(" 				where ROW_ID=a.ROW_ID "))
            .AppendLine(String.Format(" 			) "))
            .AppendLine(String.Format(" ),'')  as PriOwnerDivision, "))
            .AppendLine(String.Format(" PR_POSTN_ID as PriOwnerRowId, "))
            .AppendLine(String.Format(" IsNull( "))
            .AppendLine(String.Format(" 	(			 "))
            .AppendLine(String.Format(" 		select top 1 f.NAME from S_POSTN f where f.ROW_ID in  "))
            .AppendLine(String.Format(" 			( "))
            .AppendLine(String.Format(" 				select PR_POSTN_ID "))
            .AppendLine(String.Format(" 				from S_ORG_EXT  "))
            .AppendLine(String.Format(" 				where ROW_ID=a.ROW_ID "))
            .AppendLine(String.Format(" 			) "))
            .AppendLine(String.Format(" ),'')  as PriOwnerPosition,  "))
            .AppendLine(String.Format(" cast('' as nvarchar(10)) as LOCATION, '' as ACCOUNT_TEAM, "))
            .AppendLine(String.Format(" IsNull(d.ADDR_LINE_2,'') as ADDRESS2, IsNull(b.ATTRIB_36,'') as ACCOUNT_CC_GRADE, IsNull(a.BASE_CURCY_CD,'') as CURRENCY "))
            .AppendLine(String.Format(" from S_ORG_EXT a left join S_ORG_EXT_X b on a.ROW_ID=b.ROW_ID  "))
            .AppendLine(String.Format(" left join S_PARTY c on a.BU_ID=c.ROW_ID "))
            .AppendLine(String.Format(" left join S_ADDR_PER d on a.PR_ADDR_ID=d.ROW_ID "))
            .AppendLine(" where a.ROW_ID=@RID ")
        End With
        Dim sConn As New SqlConnection(ConfigurationManager.ConnectionStrings("CRMDB75").ConnectionString)
        Dim myConn As New SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim apt As New SqlDataAdapter(sb.ToString(), sConn)
        apt.SelectCommand.Parameters.AddWithValue("RID", RowId)
        Dim dt As New DataTable
        apt.Fill(dt)
        sConn.Close()
        If dt.Rows.Count = 1 Then
            Dim cmd As New SqlCommand("delete from siebel_account where row_id=@RID", myConn)
            cmd.Parameters.AddWithValue("RID", RowId)
            myConn.Open()
            cmd.ExecuteNonQuery()
            Dim bk As New SqlBulkCopy(myConn)
            bk.DestinationTableName = "SIEBEL_ACCOUNT"
            If myConn.State <> ConnectionState.Open Then myConn.Open()
            bk.WriteToServer(dt)
            myConn.Close()
            'Ming add 20140227 Sync SAP ErpID
            If dt.Rows(0).Item("ERP_ID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(dt.Rows(0).Item("ERP_ID")) Then
                Dim arrErpiD As New ArrayList
                arrErpiD.Add(dt.Rows(0).Item("ERP_ID").ToString.Trim)
                SAPDAL.syncSingleCompany.syncSingleSAPCustomer(arrErpiD, False, "")
            End If
            Return True
        End If
        Return False
    End Function

    Public Shared Function SyncContactFromSiebel2MyAdvantech(ByVal Email As String) As Boolean
        If Util.IsValidEmailFormat(Email) = False Then Return False
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT  A.ROW_ID, "))
            .AppendLine(String.Format(" IsNull(A.FST_NAME, '') AS 'FirstName',  "))
            .AppendLine(String.Format(" IsNull(A.MID_NAME, '') as 'MiddleName', "))
            .AppendLine(String.Format(" IsNull(A.LAST_NAME, '') AS 'LastName',  "))
            .AppendLine(String.Format(" IsNull(A.WORK_PH_NUM, '') as 'WorkPhone', "))
            .AppendLine(String.Format(" IsNull(A.CELL_PH_NUM, '') as 'CellPhone',  "))
            .AppendLine(String.Format(" IsNull(A.FAX_PH_NUM, '') as 'FaxNumber',  "))
            .AppendLine(String.Format(" IsNull(E.ATTRIB_37, '') as 'JOB_FUNCTION',  "))
            .AppendLine(String.Format(" IsNull(A.PAR_ROW_ID, '') as PAR_ROW_ID, "))
            .AppendLine(String.Format(" IsNull(D.ATTRIB_05, '') AS 'ERPID',   "))
            .AppendLine(String.Format(" IsNull(A.BU_ID, '') as 'PriOrgId',  "))
            .AppendLine(String.Format(" (select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) as 'OrgID',  "))
            .AppendLine(String.Format(" IsNull(A.PR_POSTN_ID, '') as 'OwnerId', "))
            .AppendLine(String.Format(" IsNull(E.ATTRIB_09, 'N') AS 'CanSeeOrder',  "))
            .AppendLine(String.Format(" IsNull(A.X_CONTACT_LOGIN_PASSWORD, '') AS Password,  "))
            .AppendLine(String.Format(" '' as 'Sales_Rep',  "))
            .AppendLine(String.Format(" IsNull(A.SUPPRESS_EMAIL_FLG, '') as NeverEmail, "))
            .AppendLine(String.Format(" IsNull(A.SUPPRESS_CALL_FLG,'') as NeverCall, "))
            .AppendLine(String.Format(" IsNull(A.SUPPRESS_FAX_FLG, '') as NeverFax, "))
            .AppendLine(String.Format(" IsNull(A.SUPPRESS_MAIL_FLG, '') as NeverMail,  "))
            .AppendLine(String.Format(" IsNull(A.JOB_TITLE, '') as JOB_TITLE,  "))
            .AppendLine(String.Format(" IsNull(A.EMAIL_ADDR, '') AS 'EMAIL_ADDRESS',  "))
            .AppendLine(String.Format(" B.ROW_ID as ACCOUNT_ROW_ID, "))
            .AppendLine(String.Format(" IsNull(B.NAME, '') AS ACCOUNT,  "))
            .AppendLine(String.Format(" IsNull(B.OU_TYPE_CD, '') AS 'ACCOUNT_TYPE',  "))
            .AppendLine(String.Format(" IsNull(B.CUST_STAT_CD, '') AS 'ACCOUNT_STATUS',  "))
            .AppendLine(String.Format(" IsNull(C.COUNTRY, '') AS COUNTRY, "))
            .AppendLine(String.Format(" IsNull(A.PER_TITLE, '') as Salutation, "))
            .AppendLine(String.Format(" A.EMP_FLG as EMPLOYEE_FLAG, "))
            .AppendLine(String.Format(" IsNull(A.ACTIVE_FLG,'N') as ACTIVE_FLG, "))
            .AppendLine(String.Format(" IsNull(A.DFLT_ORDER_PROC_CD,'') as User_Type, "))
            .AppendLine(String.Format(" IsNull(F.APPL_SRC_CD,'') as Reg_Source, "))
            .AppendLine(String.Format(" A.CREATED, "))
            .AppendLine(String.Format(" A.LAST_UPD as LAST_UPDATED, A.PR_REP_SYS_FLG as PRIMARY_FLAG  "))
            .AppendLine(String.Format(" FROM S_CONTACT A LEFT JOIN S_CONTACT_X E ON A.ROW_ID = E.ROW_ID  "))
            .AppendLine(String.Format(" LEFT JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID  "))
            .AppendLine(String.Format(" LEFT JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID  "))
            .AppendLine(String.Format(" LEFT JOIN S_ADDR_PER C ON A.PR_OU_ADDR_ID = C.ROW_ID  "))
            .AppendLine(String.Format(" LEFT JOIN S_PER_PRTNRAPPL F ON A.ROW_ID=F.ROW_ID "))
            .AppendLine(String.Format(" WHERE lower(A.EMAIL_ADDR)=@EM  "))
        End With
        Dim apt As New SqlDataAdapter(sb.ToString(), ConfigurationManager.ConnectionStrings("CRMDB75").ConnectionString)
        Dim dt As New DataTable
        apt.SelectCommand.Parameters.AddWithValue("EM", LCase(Email))
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        If dt.Rows.Count > 0 Then
            Dim cmd As New SqlCommand("delete from SIEBEL_CONTACT where email_address=@EM", New SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            cmd.Parameters.AddWithValue("EM", Email)
            cmd.Connection.Open()
            cmd.ExecuteNonQuery()
            Dim bk As New SqlBulkCopy(cmd.Connection)
            bk.DestinationTableName = "SIEBEL_CONTACT"
            If cmd.Connection.State <> ConnectionState.Open Then cmd.Connection.Open()
            bk.WriteToServer(dt)
            cmd.Connection.Close()
            Return True
        End If
        Return False
    End Function
    Shared Function GET_Account_info_By_ERPID(ByVal ERPID As String) As String
        Dim STR As String = String.Format("select top 1 a.ROW_ID AS ROW_ID, IsNull(c.NAME, '') as RBU, a.NAME as COMPANYNAME, IsNull(b.ATTRIB_05,'') as ERPID, " & _
                            " IsNull(d.COUNTRY,'') as CITY, Isnull(a.LOC,'') as LOCATION, " & _
                            " IsNull( " & _
                                   " ( " & _
                                          " select top 1 e.NAME from S_PARTY e inner join S_POSTN f on e.ROW_ID=f.OU_ID where f.ROW_ID in " & _
                                                 " ( " & _
                                                        " select PR_POSTN_ID " & _
                                                        " from S_ORG_EXT " & _
                                                        " where ROW_ID=a.ROW_ID " & _
                                                 " ) " & _
                            " ),'')  as PriOwnerDivision, " & _
                            " IsNull( " & _
                                   " ( " & _
                                          " select top 1 f.NAME from S_POSTN f where f.ROW_ID in " & _
                                                 " ( " & _
                                                        " select PR_POSTN_ID " & _
                                                        " from S_ORG_EXT " & _
                                                        " where ROW_ID=a.ROW_ID " & _
                                                 " ) " & _
                            " ),'')  as PriOwnerPosition, " & _
                            " IsNull((select top 1 S_ADDR_PER.ADDR from S_ADDR_PER where S_ADDR_PER.ROW_ID=a.PR_ADDR_ID),'') as ADDRESS, " & _
                            " IsNull((select top 1 S_ADDR_PER.COUNTRY from S_ADDR_PER where S_ADDR_PER.ROW_ID=a.PR_ADDR_ID),'') as COUNTRY, " & _
                            " IsNull((select top 1 S_ADDR_PER.CITY from S_ADDR_PER where S_ADDR_PER.ROW_ID=a.PR_ADDR_ID),'') as CITY, " & _
                            " IsNull((select top 1 S_ADDR_PER.STATE from S_ADDR_PER where S_ADDR_PER.ROW_ID=a.PR_ADDR_ID),'') as STATE, " & _
                            " IsNull((select top 1 S_ADDR_PER.ZIPCODE from S_ADDR_PER where S_ADDR_PER.ROW_ID=a.PR_ADDR_ID),'') as ZIPCODE " & _
                            " from S_ORG_EXT a left join S_ORG_EXT_X b on a.ROW_ID=b.ROW_ID " & _
                            " left join S_PARTY c on a.BU_ID=c.ROW_ID " & _
                            " left join S_ADDR_PER d on a.PR_ADDR_ID=d.ROW_ID " & _
                            " where Upper(isnull(b.ATTRIB_05,''))='{0}'", ERPID.ToUpper)
        Return STR
    End Function

End Class

Public Class Contact
    Public FirstName As String, LastName As String, MiddleName As String, WorkPhone As String, Company_ID As String, ORG_ID As String, CellPhone As String, _
    FaxNumber As String, JOB_FUNCTION As String, Sales_Rep As String, Par_Row_ID As String, ERP_ID As String, Pri_Org_ID As String, Owner_ID As String, _
    NeverEmail As String, ACCOUNT_ROW_ID As String, CanSeeOrder As String, Account As String, Country As String, IsEmployee As String, ActiveFlag As String, _
    Salutation As String, JOB_TITLE As String, NeverCall As String, NeverFax As String, NeverMail As String, UserType As String, Registration_Source As String, _
    Row_ID As String, Password As String, _email As String, suser As SSO.SSOUSER

    Public Sub New(ByVal email As String)
        _email = email
        'Dim tsk As Threading.Tasks.Task = Threading.Tasks.Task.Factory.StartNew(AddressOf GetUserSSO)
        email = Trim(email.Replace("'", "''"))
        Dim sql As String = " SELECT EMAIL_ADDRESS as USERID, isnull(erpid,'') as company_id, isnull(PriOrgId,'') as org_id, " + _
                            "isnull(FirstName,'') as FirstName, isnull(MiddleName,'') as MiddleName, isnull(LastName,'') as LastName, isnull(WorkPhone,'') as WorkPhone, " + _
                            "isnull(FaxNumber,'') as FaxNumber, isnull(CellPhone,'') as CellPhone, isnull(JOB_FUNCTION,'') as JOB_FUNCTION, " + _
                            "isnull(PAR_ROW_ID,'') as PAR_ROW_ID, isnull(ERPID,'') as ERPID, isnull(PriOrgId,'') as PriOrgId, isnull(OwnerId,'') as OwnerId, " + _
                            "isnull(CanSeeOrder,'') as CanSeeOrder, isnull(Password,'') as Password, isnull(Sales_Rep,'') as Sales_Rep, " + _
                            "isnull(NeverEmail,'') as NeverEmail, isnull(NeverCall,'') as NeverCall, isnull(NeverFax,'') as NeverFax, " + _
                            "isnull(NeverMail,'') as NeverMail, isnull(JOB_TITLE,'') as JOB_TITLE, isnull(ACCOUNT_ROW_ID,'') as ACCOUNT_ROW_ID, " + _
                            "isnull(Account,'') as Account, isnull(Country,'') as Country, isnull(Salutation,'') as Salutation, isnull(EMPLOYEE_FLAG,'') as EMPLOYEE_FLAG, " + _
                            "isnull(ACTIVE_FLAG,'') as ACTIVE_FLG, isnull(User_Type,'') as User_Type, isnull(reg_source,'') as Registration_Source, " + _
                            "password as LOGIN_PASSWORD, isnull(ROW_ID,'') as ROW_ID " + _
                            "FROM SIEBEL_CONTACT Where EMAIL_ADDRESS = '" + email + "'"

        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", sql)
        'tsk.Wait()
        Dim sso As New SSO.MembershipWebservice, suser As SSO.SSOUSER = Nothing
        sso.Timeout = -1
        Try
            suser = sso.getProfile(_email, "PZ")
        Catch ex As Exception
            suser = Nothing
        End Try
        If Not IsNothing(dt) And dt.Rows.Count > 0 Then
            With dt.Rows(0)
                Company_ID = .Item("company_id") : ORG_ID = .Item("org_id") : FirstName = .Item("FirstName")
                MiddleName = .Item("MiddleName") : LastName = .Item("LastName") : WorkPhone = .Item("WorkPhone") : FaxNumber = .Item("FaxNumber")
                CellPhone = .Item("CellPhone") : JOB_FUNCTION = .Item("JOB_FUNCTION") : Par_Row_ID = .Item("PAR_ROW_ID") : ERP_ID = .Item("ERPID")
                Pri_Org_ID = .Item("PriOrgId") : Owner_ID = .Item("OwnerId") : CanSeeOrder = .Item("CanSeeOrder") : Sales_Rep = .Item("Sales_Rep")
                NeverEmail = .Item("NeverEmail") : NeverCall = .Item("NeverCall") : NeverFax = .Item("NeverFax") : NeverMail = .Item("NeverMail")
                JOB_TITLE = .Item("JOB_TITLE") : ACCOUNT_ROW_ID = .Item("ACCOUNT_ROW_ID") : Account = .Item("Account") : Country = .Item("Country")
                Salutation = .Item("Salutation") : IsEmployee = .Item("EMPLOYEE_FLAG") : ActiveFlag = .Item("ACTIVE_FLG") : UserType = .Item("User_Type")
                Registration_Source = .Item("Registration_Source") : Password = .Item("LOGIN_PASSWORD") : Row_ID = .Item("ROW_ID")
            End With
            If suser IsNot Nothing Then
                With suser
                    Password = .login_password : Account = .company_name : Company_ID = .company_id
                End With
            End If
        Else
            If suser IsNot Nothing Then
                With suser
                    Password = .login_password : Account = .company_name : Company_ID = .company_id
                    ORG_ID = .primary_org_id : FirstName = .first_name : LastName = .last_name
                    MiddleName = "" : WorkPhone = .tel_no : FaxNumber = .fax_no : CellPhone = ""
                    Pri_Org_ID = .primary_org_id : CanSeeOrder = .canseeorder : JOB_TITLE = .job_title
                    JOB_FUNCTION = .job_function : Country = .country
                    Registration_Source = .source : Row_ID = .siebel_raw_id
                End With
            End If
        End If
    End Sub
End Class


Public Class SRUtil
    Public strSRNum As String, strSRAbstract As String, strSRDesc As String, strSRType As String, strSRCategory As String
    Public strProdModel As New StringBuilder, strOS As New StringBuilder
    Public SolutionDt As New DataTable
    Public DownloadFileHt As New Hashtable

    Public Sub SR_Download(ByVal sr_id As String)
        Dim SR_Dt As DataTable = dbUtil.dbGetDataTable("My", _
        " SELECT SR_ID, IsNull(SR_NUM, '') as SR_NUM, SR_CATEGORY, " + _
        " IsNull(ABSTRACT, '') as ABSTRACT, SR_DESCRIPTION, IsNull(SR_TYPE, '') as SR_TYPE, " + _
        " PUBLISH_SCOPE, SEARCH_TYPE, OWNER, CREATED_DATE, UPDATED_DATE FROM SIEBEL_SR_DOWNLOAD " + _
        " WHERE SR_ID = '" + sr_id + "'")

        If Not SR_Dt Is Nothing AndAlso SR_Dt.Rows.Count > 0 Then

            strSRNum = SR_Dt.Rows(0).Item("SR_NUM").ToString()

            'Set product models
            Dim pmDt As DataTable = dbUtil.dbGetDataTable("My", "SELECT * FROM SIEBEL_SR_PRODUCT WHERE SR_ID='" + sr_id + "'")
            If Not IsNothing(pmDt) AndAlso pmDt.Rows.Count > 0 Then
                For i As Integer = 0 To pmDt.Rows.Count - 1
                    If i > 0 Then
                        strProdModel.Append(", " + pmDt.Rows(i).Item("PART_NO").ToString())
                    Else
                        strProdModel.Append(pmDt.Rows(i).Item("PART_NO").ToString())
                    End If
                Next

            End If
            'Set abstract
            strSRAbstract = SR_Dt.Rows(0).Item("ABSTRACT").ToString()
            'Set description
            strSRDesc = Replace(SR_Dt.Rows(0).Item("SR_DESCRIPTION").ToString(), vbCrLf, "<br/>")

            'Get solution info
            SolutionDt = dbUtil.dbGetDataTable("My", _
            " SELECT C.SR_ID as SOLUTION_ID, C.NAME as SOLUTION_NAME, IsNull(C.FAQ_QUES_TEXT, '') as FAQ, " + _
            " IsNull(C.RESOLUTION_TEXT, '') as SOLUTION_DESC, C.CREATED as CREATED_DATE, C.PUBLISH_FLG as PUBLISH_FLAG " + _
            " FROM SIEBEL_SR_DOWNLOAD A, SIEBEL_SR_SOLUTION_RELATION B, SIEBEL_SR_SOLUTION C " + _
            " WHERE A.SR_ID = B.SR_ID AND B.SOLUTION_ID = C.SR_ID AND C.PUBLISH_FLG = 'Y' AND A.SR_ID = '" + sr_id + "' ")

            If Not IsNothing(SolutionDt) AndAlso SolutionDt.Rows.Count > 0 Then

                For Each r As DataRow In SolutionDt.Rows

                    Dim SolutionFileDt As DataTable = dbUtil.dbGetDataTable("My", _
                    " SELECT A.FILE_ID, IsNull(A.FILE_NAME, '') as FILE_NAME, IsNull(A.FILE_EXT, '') as FILE_EXT, " + _
                    " IsNull(A.FILE_SIZE, 0) as FILE_SIZE, IsNull(A.FILE_DESC, '') as FILE_DESC, A.CREATED_DATE " + _
                    " FROM SIEBEL_SR_SOLUTION_FILE AS A CROSS JOIN SIEBEL_SR_SOLUTION_FILE_RELATION AS B " + _
                    " WHERE (A.FILE_ID = B.FILE_ID) AND (A.PUBLISH_FLAG = 'Y') AND " + _
                    " (B.SOLUTION_ID = '" + r.Item("SOLUTION_ID").ToString() + "') ")

                    DownloadFileHt.Add(r.Item("SOLUTION_ID").ToString(), SolutionFileDt)
                Next
            End If
        End If
    End Sub

    Public Sub SR_Detail(ByVal sr_id As String)
        Dim SR_Dt As DataTable = dbUtil.dbGetDataTable("My", _
        " SELECT SR_ID, SR_NUM, IsNull(SR_CATEGORY, '') as SR_CATEGORY, IsNull(ABSTRACT, '') as ABSTRACT, " + _
        " SR_DESCRIPTION, IsNull(SR_TYPE, '') as SR_TYPE, " + _
        " PUBLISH_SCOPE, SEARCH_TYPE, OWNER, CREATED_DATE, UPDATED_DATE FROM SIEBEL_SR_DOWNLOAD " + _
        " WHERE SR_ID = '" + sr_id + "'")

        If Not SR_Dt Is Nothing AndAlso SR_Dt.Rows.Count > 0 Then

            strSRNum = SR_Dt.Rows(0).Item("SR_NUM").ToString()

            'Set product models
            Dim pmDt As DataTable = dbUtil.dbGetDataTable("My", _
            "SELECT * FROM SIEBEL_SR_PRODUCT WHERE SR_ID='" + sr_id + "'")
            If Not IsNothing(pmDt) AndAlso pmDt.Rows.Count > 0 Then
                For i As Integer = 0 To pmDt.Rows.Count - 1
                    If i > 0 Then
                        strProdModel.Append(", " + pmDt.Rows(i).Item("PART_NO").ToString())
                    Else
                        strProdModel.Append(pmDt.Rows(i).Item("PART_NO").ToString())
                    End If
                Next
            End If
            'Set type
            strSRType = SR_Dt.Rows(0).Item("SR_TYPE").ToString()
            'Set abstract
            strSRAbstract = SR_Dt.Rows(0).Item("ABSTRACT").ToString()
            'Set description
            strSRDesc = Replace(SR_Dt.Rows(0).Item("SR_DESCRIPTION").ToString(), vbCrLf, "<br/>")
            strSRCategory = Replace(SR_Dt.Rows(0).Item("SR_CATEGORY").ToString(), vbCrLf, "<br/>")
            'Get OS info
            Dim OsDt As DataTable = dbUtil.dbGetDataTable("My", _
            "SELECT SR_ID, IsNull(OS, '') as OS FROM siebel_SR_OS WHERE SR_ID='" + sr_id + "'")
            If Not IsNothing(OsDt) AndAlso OsDt.Rows.Count > 0 Then
                For i As Integer = 0 To OsDt.Rows.Count - 1
                    If i > 0 Then
                        strOS.Append(", " + OsDt.Rows(i).Item("OS").ToString())
                    Else
                        strOS.Append(OsDt.Rows(i).Item("OS").ToString())
                    End If
                Next
            End If
            'Get solution info
            SolutionDt = dbUtil.dbGetDataTable("My", _
            " SELECT C.SR_ID as SOLUTION_ID, C.NAME as SOLUTION_NAME, IsNull(C.FAQ_QUES_TEXT, '') as FAQ, " + _
            " IsNull(C.RESOLUTION_TEXT, '') as SOLUTION_DESC, C.CREATED as CREATED_DATE, C.PUBLISH_FLG as PUBLISH_FLAG " + _
            " FROM SIEBEL_SR_DOWNLOAD A, SIEBEL_SR_SOLUTION_RELATION B, SIEBEL_SR_SOLUTION C " + _
            " WHERE A.SR_ID = B.SR_ID AND B.SOLUTION_ID = C.SR_ID AND C.PUBLISH_FLG = 'Y' AND A.SR_ID = '" + sr_id + "' ")

            If Not IsNothing(SolutionDt) AndAlso SolutionDt.Rows.Count > 0 Then

                For Each r As DataRow In SolutionDt.Rows

                    Dim SolutionFileDt As DataTable = dbUtil.dbGetDataTable("My", _
                    " SELECT A.FILE_ID, IsNull(A.FILE_NAME, '') as FILE_NAME, IsNull(A.FILE_EXT, '') as FILE_EXT, " + _
                    " IsNull(A.FILE_SIZE, 0) as FILE_SIZE, IsNull(A.FILE_DESC, '') as FILE_DESC, A.CREATED_DATE " + _
                    " FROM SIEBEL_SR_SOLUTION_FILE AS A CROSS JOIN SIEBEL_SR_SOLUTION_FILE_RELATION AS B " + _
                    " WHERE (A.FILE_ID = B.FILE_ID) AND (A.PUBLISH_FLAG = 'Y') AND " + _
                    " (B.SOLUTION_ID = '" + r.Item("SOLUTION_ID").ToString() + "') ")

                    DownloadFileHt.Add(r.Item("SOLUTION_ID").ToString(), SolutionFileDt)

                Next
            End If
        End If
    End Sub
End Class
