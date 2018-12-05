Imports Microsoft.VisualBasic

Public Class CampaignUtil
    Public Shared Function InsertLog(ByVal REQUESTNO As String, ByVal REQUES_STATUS As String, ByVal Submitted_by As String) As Boolean
        Dim MyDC As New MyCampaignDBDataContext()
        Dim CRlog As New CAMPAIGN_REQUEST_Log
        CRlog.REQUES_STATUS = REQUES_STATUS
        CRlog.REQUESTNO = REQUESTNO
        CRlog.Submitted_by = Submitted_by
        CRlog.Submitted_date = Now
        MyDC.CAMPAIGN_REQUEST_Logs.InsertOnSubmit(CRlog)
        MyDC.SubmitChanges()
        Return False
    End Function
    Public Shared Function GetLog(ByVal REQUESTNO As String) As List(Of CAMPAIGN_REQUEST_Log)
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCRlog As List(Of CAMPAIGN_REQUEST_log) = MyDC.CAMPAIGN_REQUEST_Logs.Where(Function(p) p.REQUESTNO = REQUESTNO).OrderBy(Function(p) p.Submitted_date).ToList
        Return MyCRlog
    End Function
    Public Shared Function GetRequestNO() As String
        Dim SQL As String = String.Format(" select ISNULL(MAX(CONVERT(INT,REPLACE(REQUESTNO,'CR',''))),0) as REQUESTNO  from  CAMPAIGN_REQUEST where REQUESTNO is not null and REQUESTNO <> '' and REQUESTNO like 'CR%' ", "")
        Dim NUM As Object = dbUtil.dbExecuteScalar("MY", SQL)
        If NUM IsNot Nothing AndAlso IsNumeric(NUM) Then
            Return "CR" & (CDbl(NUM) + 1).ToString("00000")
        End If
        Return ""
    End Function
    Public Shared Function IsAdmin() As Boolean
        'If HttpContext.Current.Session("user_id").ToString().ToLower() = "ming.zhao@advantech.com.cn" Then Return False
        If Util.IsAEUIT() Then Return True
        Dim uid As String = HttpContext.Current.Session("user_id").ToString().ToLower()
        Dim adminList As New ArrayList
        With adminList
            .Add("ming.zhao@advantech.com.cn")
        End With
        If adminList.Contains(uid) Then
            Return True
        End If
        Return False
    End Function
    Shared Function getCompanyName(ByVal Company_id As String) As String
        Dim CompanyName As Object = dbUtil.dbExecuteScalar("MY", "select top 1 isnull(company_name,'') as companyname  from SAP_DIMCOMPANY where company_id='" & Company_id & "'")
        If Not IsNothing(CompanyName) Then
            Return CompanyName
        End If
        Return ""
    End Function
    Shared Function getCampaignName(ByVal CampaignID As String) As String
        Dim CampaignName As Object = dbUtil.dbExecuteScalar("MY", "select top 1 isnull(Name,'') as CampaignName  from UNICADBP.dbo.UA_Campaign where CampaignID='" & CampaignID & "'")
        If Not IsNothing(CampaignName) Then
            Return CampaignName
        End If
        Return ""
    End Function
    Shared Function GetSBUOwne(ByVal CampaignID As String) As String
        Dim sb As New StringBuilder
        sb.Append(" select top 1 B.name   from UNICADBP.dbo.UA_Campaign A INNER JOIN UNICAMPP.dbo.USM_USER B ON A.CreateBy=B.ID ")
        sb.AppendFormat(" WHERE A.CampaignID ={0} ", CampaignID)
        Dim obj As Object = dbUtil.dbExecuteScalar("My", sb.ToString)
        If obj IsNot Nothing Then
            Return obj.ToString.Trim
        End If
        Return ""
    End Function
    Public Enum CR_Status
        New_Request = -1
        Further_Edit = 0
        Pending = 1
        In_Preparation = 2
        Ongoing = 3
        Closed = 4
        Canceled = 5
        Rejected = 6
    End Enum
    Public Shared Function SendEmail(ByVal RequestNo As String, ByVal StatusInt As Integer) As Integer
        Dim MyDC As New MyCampaignDBDataContext()
        Dim CR As CAMPAIGN_REQUEST = (From MyCR In MyDC.CAMPAIGN_REQUESTs
                    Where MyCR.REQUESTNO = RequestNo).FirstOrDefault()
        With CR
            Dim strSubject As String = ""
            Dim strFrom As String = "eBusiness.AEU@advantech.eu"
            Dim strTo As String = ""
            Dim strCC As String = ""
            Dim strBcc As String = "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn"
            Dim mailbody As String = ""
            Select Case StatusInt
                Case 1
                    strSubject = String.Format("Your new campaign request being processed. Campaign Name: {0} ({1})", .CampaignNameX, .REQUESTNO)
                    strTo = .REQUEST_BY
                    strCC = ""
                    mailbody = ""
                Case 100  ' send owner
                    strSubject = String.Format("A new campaign request is applied by {0} and request for your approval. Campaign Name: {1}({2})", .LAST_UPD_BY, .CampaignNameX, .REQUESTNO)
                    strTo = .MarketingManagerMailX + "," + .AdvantechChannelSalesX 'GetSBUOwne(.CAMPAIGNID)
                    strCC = ""
                    mailbody = String.Format(" Please <a href=""{0}"">click</a> to check and approve this request. Thanks.", _
                                             Util.GetRuntimeSiteUrl + String.Format("/My/Campaign/CampaignRequest.aspx?REQUESTNO={0}", RequestNo))
                Case 200 ' send CP
                    strSubject = String.Format("Your campaign request is changed by {0} and new Status is ""{3}"". Campaign Name: {1}({2})", _
                                               .LAST_UPD_BY, .CampaignNameX, .REQUESTNO, .StatusX)
                    strTo = .REQUEST_BY
                    strCC = ""
                    mailbody = String.Format(" Please <a href=""{0}"">click</a> to view this request. Thanks.", Util.GetRuntimeSiteUrl + String.Format("/My/Campaign/CampaignRequest.aspx?REQUESTNO={0}", _
                                                                                          RequestNo))
            End Select
            mailbody += "<br/><p></p>"
            If Util.IsTesting() Then
                Call MailUtil.Utility_EMailPage(strFrom, HttpContext.Current.Session("user_id"), "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "", strSubject.Trim(), "", "TO:" + strTo + "<BR/>CC:" + strCC + "<BR/>BCC:" + strBcc + "<HR/>" + mailbody.Trim())
            Else
                Call MailUtil.Utility_EMailPage(strFrom, strTo, strCC, strBcc, strSubject.Trim(), "", mailbody.Trim())
            End If
        End With
        Return 1
    End Function
    Public Shared Function SendEmailV2(ByVal RequestNo As String, ByVal StatusInt As Integer, ByVal _mailbody As String) As Integer
        Dim MyDC As New MyCampaignDBDataContext()
        Dim CR As CAMPAIGN_REQUEST = (From MyCR In MyDC.CAMPAIGN_REQUESTs
                    Where MyCR.REQUESTNO = RequestNo).FirstOrDefault()
        With CR
            Dim strSubject As String = ""
            Dim strFrom As String = "eBusiness.AEU@advantech.eu"
            Dim strTo As String = ""
            Dim strCC As String = ""
            Dim strBcc As String = "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn"
            Dim mailbody As String = ""
            Select Case StatusInt
                Case 0
                    strSubject = String.Format("Message Answer for Campaign Request, Campaign Name: {0} ({1})", .CampaignNameX, .REQUESTNO)
                    strTo = .REQUEST_BY
                    strCC = ""
                    mailbody = _mailbody
                Case 1  ' send owner
                    strSubject = String.Format("A new Message Board is submitted by {0} , Campaign Name: {1}({2})", .LAST_UPD_BY, .CampaignNameX, .REQUESTNO)
                    strTo = .MarketingManagerMailX + "," + .REQUEST_BY 'GetSBUOwne(.CAMPAIGNID)
                    strCC = ""
                    mailbody = _mailbody + String.Format("<br/> Please <a href=""{0}"">click</a> to check . Thanks.", _
                                             Util.GetRuntimeSiteUrl + String.Format("/My/Campaign/CampaignRequest.aspx?REQUESTNO={0}", RequestNo))
                Case 200 ' send CP
                    strSubject = String.Format("Your campaign request is changed by {0} and new Status is ""{3}"". Campaign Name: {1}({2})", _
                                               .LAST_UPD_BY, .CampaignNameX, .REQUESTNO, .StatusX)
                    strTo = .REQUEST_BY
                    strCC = ""
                    mailbody = String.Format(" Please <a href=""{0}"">click</a> to view this request. Thanks.", Util.GetRuntimeSiteUrl + String.Format("/My/Campaign/CampaignRequest.aspx?REQUESTNO={0}", _
                                                                                          RequestNo))
            End Select
            mailbody += "<br/><p></p>"
            If Util.IsTesting() Then
                Call MailUtil.Utility_EMailPage(strFrom, HttpContext.Current.Session("user_id"), "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "", strSubject.Trim(), "", "TO:" + strTo + "<BR/>CC:" + strCC + "<BR/>BCC:" + strBcc + "<HR/>" + mailbody.Trim())
            Else
                Call MailUtil.Utility_EMailPage(strFrom, strTo, strCC, strBcc, strSubject.Trim(), "", mailbody.Trim())
            End If
        End With
        Return 1
    End Function
End Class
Partial Public Class CAMPAIGN_REQUEST_log
    Public ReadOnly Property REQUES_STATUSX As String
        Get
            If IsNumeric(Me.REQUES_STATUS) Then
                Return [Enum].GetName(GetType(CampaignUtil.CR_Status), Me.REQUES_STATUS).Replace("_", " ")
            End If
            Return Me.REQUES_STATUS.ToString
        End Get
    End Property
End Class
Partial Public Class CAMPAIGN_REQUEST
    Public ReadOnly Property StatusX As String
        Get
            If IsNumeric(Me.STATUS) Then
                Return [Enum].GetName(GetType(CampaignUtil.CR_Status), Me.STATUS).Replace("_", " ")
            End If
            Return Me.STATUS.ToString
        End Get
    End Property
    Public ReadOnly Property SBUOwnerX As String
        Get
            Return CampaignUtil.GetSBUOwne(Me.CAMPAIGNID)
        End Get
    End Property
    Public ReadOnly Property ErpNameX As String
        Get
            If Not String.IsNullOrEmpty(Me.ERPID) Then
                Return CampaignUtil.getCompanyName(Me.ERPID)
            End If
            Return Me.ERPID
        End Get
    End Property
    Public ReadOnly Property CampaignNameX As String
        Get
            If Not String.IsNullOrEmpty(Me.CAMPAIGNID) Then
                Return CampaignUtil.getCampaignName(Me.CAMPAIGNID)
            End If
            Return Me.CAMPAIGNID
        End Get
    End Property
    Public ReadOnly Property MarketingManagerMailX As String
        Get
            If Not String.IsNullOrEmpty(Me.RBU) Then
                Dim MyDC As New MyCampaignDBDataContext()
                Dim EmailStr As String = String.Empty
                Dim result = From MM In MyDC.CAMPAIGN_REQUEST_MarketingManagers
                                     Join RBU In MyDC.CAMPAIGN_Request_MarketingManager_RBUs
                                     On MM.ID Equals RBU.MarketingManagerID
                                     Where RBU.RBU = Me.RBU
                                     Select MM
                For Each i In result
                    If Util.IsValidEmailFormat(i.Email) Then
                        EmailStr += "," + i.Email
                    End If
                Next
                Return EmailStr.Trim(New Char() {","})
            End If
            Return ""
        End Get
    End Property
    Public ReadOnly Property AdvantechChannelSalesX As String
        Get
            If Not String.IsNullOrEmpty(Me.ERPID) Then
                Dim MyDC As New MyCampaignDBDataContext()
                Dim EmailStr As String = String.Empty
                Dim sql As New StringBuilder
                sql.Append(" select distinct  c.EMAIL_ADDRESS ")
                sql.Append(" from SIEBEL_ACCOUNT_OWNER a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID inner join SIEBEL_CONTACT c on a.OWNER_ID=c.ROW_ID  ")
                sql.AppendFormat(" where b.ERP_ID='{0}' ", Me.ERPID)
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString)
                If dt.Rows.Count > 0 Then
                    For Each dr As DataRow In dt.Rows
                        If Util.IsValidEmailFormat(dr.Item("EMAIL_ADDRESS")) Then
                            EmailStr += "," + dr.Item("EMAIL_ADDRESS")
                        End If
                    Next
                End If
                Return EmailStr.Trim(New Char() {","})
            End If
            Return ""
        End Get
    End Property
End Class
