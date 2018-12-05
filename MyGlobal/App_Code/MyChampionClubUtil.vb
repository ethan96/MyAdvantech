Imports Microsoft.VisualBasic

Public Class MyChampionClubUtil
    Public Enum CC_Status
        Cancel = -1
        Upload_Report = 0
        Get_Points = 1
    End Enum
    Public Enum CC_Reddem_Status
        Cancel_Redeem = -1
        New_Redemption = 0
        Approved = 1
        Delivered = 2
        Rejected = 3
    End Enum
    Public Shared Function GetAvailablePoint(ByVal userid As String) As Integer
        'Dim MyPoint As Object = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM  ChampionClub_Action where CreateBy ='{0}' and YEAR(CreateTime) >= (YEAR(getdate()) -1) and Status = 1", userid))
        'ICC 2015/2/24 Change sql rule. The total point should be collected from last year to new year.
        Dim MyPoint As Object = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM  ChampionClub_Action where CreateBy ='{0}' and YEAR(CreateTime) >= (YEAR(getdate()) -1) and Status = 1", userid))
        Dim _MyPoint As Integer = Integer.Parse(MyPoint)
        'MyPoint = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM ChampionClub_Prize where ID in ( select PrizeID  from  ChampionClub_Reddem where status <> -1 and status <> 3 and CreateBy ='{0}' and YEAR(CreateTime) = YEAR(getdate())) ", userid))
        'ICC 2015/3/6 Fixed UsedPoint logic.
        MyPoint = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM ChampionClub_Prize where ID in ( select PrizeID  from  ChampionClub_Reddem where status <> -1 and status <> 3 and CreateBy ='{0}' and YEAR(CreateTime) >= (YEAR(getdate()) -1)) ", userid))
        Dim _UsedPoint As Integer = Integer.Parse(MyPoint)
        Return _MyPoint - _UsedPoint
        Return 0
    End Function
    Public Shared Function SendEmail(ByVal user_id As String, ByVal StatusInt As Integer, ByVal ActionID As String, ByVal ReddemID As String) As Integer
        Dim MyDC As New MyChampionClubDataContext()
        Dim CR As ChampionClub_PersonalInfo = (From MyCR In MyDC.ChampionClub_PersonalInfos
                    Where MyCR.UserID = user_id).FirstOrDefault()
        With CR
            Dim strSubject As String = ""
            Dim strFrom As String = "eBusiness.AEU@advantech.eu"
            Dim strTo As String = ""
            Dim strCC As String = "Liliana.Wen@advantech.com.tw,Stefanie.Chang@advantech.com.tw"
            Dim strBcc As String = "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn,rudy.wang@advantech.com.tw"
            Dim mailbody As String = "<p></p>"
            Select Case StatusInt
                Case 1
                    strSubject = String.Format("{2} joined Champion Club. {0} ({1})", .CompanyX, .ErpID, .UserID)
                    strTo = .MarketingManagerMailX
                    'strCC = "Liliana.Wen@advantech.com.tw,Stefanie.Chang@advantech.com.tw"
                    mailbody = ""
                Case 2
                    Dim A As ChampionClub_Action = (From MyCR In MyDC.ChampionClub_Actions
                   Where MyCR.ID = ActionID).FirstOrDefault()
                    If A IsNot Nothing Then
                        strSubject = String.Format("A new Points Request is submitted by {0}.", user_id) ' (Revenue Achievement: {1})", user_id, A.RevenueAchievement)
                        strTo = .MarketingManagerMailX
                        'strCC = "Liliana.Wen@advantech.com.tw,Stefanie.Chang@advantech.com.tw"
                    End If
                    mailbody += String.Format("{0} current point is {1}.", user_id, MyChampionClubUtil.GetAvailablePoint(user_id))
                    mailbody += String.Format("<p></p> Please <a href=""{0}"">click</a> to check and approve this request. Thanks.", _
                     Util.GetRuntimeSiteUrl + String.Format("/My/ChampionClub/MarcomPlatform.aspx"))
                Case 3
                    Dim A As ChampionClub_Reddem = (From MyCR In MyDC.ChampionClub_Reddems
                Where MyCR.ReddemID = ReddemID).FirstOrDefault()
                    If A IsNot Nothing Then
                        strSubject = String.Format("{0} redeemed a {1} ", _
                                                                     user_id, A.Prize_NameX)
                        strTo = .MarketingManagerMailX
                        'strCC = "Liliana.Wen@advantech.com.tw,Stefanie.Chang@advantech.com.tw"
                    End If
                    '    mailbody = String.Format(" Please <a href=""{0}"">click</a> to view this request. Thanks.", Util.GetRuntimeSiteUrl + String.Format("/My/Campaign/CampaignRequest.aspx?REQUESTNO={0}", _
                    '                                                                          RequestNo))
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
    Public Shared Function GetFileSize(FileSizeOfB As Long) As String
        Dim FileSizeName As String = ""
        If FileSizeOfB >= 1 Then
            FileSizeName = FileSizeOfB.ToString("0.00") + "B"
        End If
        If FileSizeOfB <= 1024 Then
            FileSizeName = (FileSizeOfB * 1.0 / 1024).ToString("0.00") + "KB"
        Else
            FileSizeName = (FileSizeOfB * 1.0 / (1024 * 1024)).ToString("0.00") + "MB"
        End If
        Return FileSizeName
    End Function

End Class
Partial Public Class ChampionClub_PersonalInfo
    Public ReadOnly Property CompanyX As String
        Get
            If Not IsDBNull(Me.ErpID) Then
                Return dbUtil.dbExecuteScalar("my", String.Format("select top 1 isnull(COMPANY_NAME,'') as name from  sap_dimcompany where COMPANY_ID='{0}'", Me.ErpID))
                End If
            Return Me.ErpID.ToString
        End Get
    End Property
    Public ReadOnly Property JobTitleX As String
        Get
            If Not IsDBNull(Me.UserID) Then
                Return dbUtil.dbExecuteScalar("my", String.Format("select top 1 isnull(JOB_FUNCTION,'') as JOBTITLE  from SIEBEL_CONTACT WHERE EMAIL_ADDRESS ='{0}'", Me.UserID))
            End If
            Return Me.UserID.ToString
        End Get
    End Property
    Public ReadOnly Property MarketingManagerMailX As String
        Get
            If Not String.IsNullOrEmpty(Me.ORG) Then
                Dim MyDC As New MyCampaignDBDataContext()
                Dim EmailStr As String = String.Empty
                Dim result = From MM In MyDC.CAMPAIGN_REQUEST_MarketingManagers
                                     Join RBU In MyDC.CAMPAIGN_Request_MarketingManager_RBUs
                                     On MM.ID Equals RBU.MarketingManagerID
                                     Where RBU.RBU = Me.ORG
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
End Class
Partial Public Class ChampionClub_Reddem
    Public ReadOnly Property StatusX As String
        Get
            If IsNumeric(Me.Status) Then
                If Me.Status = 0 Then
                    Return "<font color=""#FF0000"">" + [Enum].GetName(GetType(MyChampionClubUtil.CC_Reddem_Status), Me.Status).Replace("_", " ") + "</font>"
                End If
                Return [Enum].GetName(GetType(MyChampionClubUtil.CC_Reddem_Status), Me.Status).Replace("_", " ")
            End If
            Return Me.Status.ToString
        End Get
    End Property
    Public ReadOnly Property Prize_NameX As String
        Get
            If IsNumeric(Me.PrizeID) Then
                Dim MyDC As New MyChampionClubDataContext
                Dim F As ChampionClub_Prize = MyDC.ChampionClub_Prizes.Where(Function(P) P.ID = Me.PrizeID).FirstOrDefault
                If F IsNot Nothing Then
                    Return F.NAME
                End If
            End If
            Return ""
        End Get
    End Property

    Public ReadOnly Property ErpIDX As String
        Get
            If Not IsDBNull(Me.CreateBy) Then
                Dim MyDC As New MyChampionClubDataContext
                Dim F As ChampionClub_PersonalInfo = MyDC.ChampionClub_PersonalInfos.Where(Function(P) P.UserID = Me.CreateBy).FirstOrDefault
                If F IsNot Nothing Then
                    Return F.ErpID
                End If
            End If
            Return Me.CreateBy.ToString
        End Get
    End Property
    Public ReadOnly Property CompanyX As String
        Get
            If Not IsDBNull(Me.CreateBy) Then
                Dim MyDC As New MyChampionClubDataContext
                Dim F As ChampionClub_PersonalInfo = MyDC.ChampionClub_PersonalInfos.Where(Function(P) P.UserID = Me.CreateBy).FirstOrDefault
                If F IsNot Nothing Then
                    Return dbUtil.dbExecuteScalar("my", String.Format("select top 1 isnull(COMPANY_NAME,'') as name from  sap_dimcompany where COMPANY_ID='{0}'", F.ErpID))
                End If
            End If
            Return Me.CreateBy.ToString
        End Get
    End Property
    Public ReadOnly Property Prize_PointX As Integer
        Get
            If Me.Status = -1 OrElse Me.Status = 3 Then
                Return 0
            End If
            If IsNumeric(Me.PrizeID) Then
                Dim MyDC As New MyChampionClubDataContext
                Dim F As ChampionClub_Prize = MyDC.ChampionClub_Prizes.Where(Function(P) P.ID = Me.PrizeID).FirstOrDefault
                If F IsNot Nothing Then
                    Return F.Points
                End If
            End If
            Return Me.PrizeID
        End Get
    End Property
End Class
Partial Public Class ChampionClub_Action
    Public ReadOnly Property StatusX As String
        Get
            If IsNumeric(Me.Status) Then
                Return [Enum].GetName(GetType(MyChampionClubUtil.CC_Status), Me.Status).Replace("_", " ")
            End If
            Return Me.Status.ToString
        End Get
    End Property
    Public ReadOnly Property File_NameX As String
        Get
            If IsNumeric(Me.FileID) Then
                Dim MyDC As New MyChampionClubDataContext
                Dim F As ChampionClub_File = MyDC.ChampionClub_Files.Where(Function(P) P.FileID = Me.FileID).FirstOrDefault
                If F IsNot Nothing Then
                    Return F.File_Name
                End If
            End If
            Return Me.FileID.ToString
        End Get
    End Property
    Public ReadOnly Property File_SizeX As String
        Get
            If IsNumeric(Me.FileID) Then
                Dim MyDC As New MyChampionClubDataContext
                Dim F As ChampionClub_File = MyDC.ChampionClub_Files.Where(Function(P) P.FileID = Me.FileID).FirstOrDefault
                If F IsNot Nothing Then
                    If IsNumeric(F.File_Size) Then
                        Return MyChampionClubUtil.GetFileSize(F.File_Size)
                    End If
                End If
            End If
            Return Me.FileID.ToString
        End Get
    End Property
End Class
Partial Public Class ChampionClub_PersonalInfo
    Public ReadOnly Property CurrentPointX As Integer
        Get
            'ICC 2015/3/6 Change current point logic to [GetAvailablePoint] function
            'Dim MyPoint As Object = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM  ChampionClub_Action where CreateBy ='{0}' and YEAR(CreateTime) >= 2014", Me.UserID))
            'Dim _MyPoint As Integer = Integer.Parse(MyPoint)
            'MyPoint = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM ChampionClub_Prize where ID in ( select PrizeID  from  ChampionClub_Reddem where status <> -1 and status <> 3 and CreateBy ='{0}'   and YEAR(CreateTime) >=2014  and MONTH(CreateTime)>10) ", Me.UserID))
            'Dim _UsedPoint As Integer = Integer.Parse(MyPoint)
            'Return _MyPoint - _UsedPoint
            'Return 0
            Return MyChampionClubUtil.GetAvailablePoint(Me.UserID)
        End Get
    End Property
    Public ReadOnly Property TotalPointsX As Integer
        Get
            Dim MyPoint As Object = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM  ChampionClub_Action where CreateBy ='{0}'  and YEAR(CreateTime) >= 2014 and Status = 1 ", Me.UserID))
            Dim _MyPoint As Integer = Integer.Parse(MyPoint) 
            Return _MyPoint
            Return 0
        End Get
    End Property
    Public ReadOnly Property HistoryPointsX As Integer
        Get
            Dim MyPoint As Object = dbUtil.dbExecuteScalar("my", String.Format("SELECT isnull(SUM(points),0) as point FROM  ChampionClub_Action where CreateTime < dateadd(d,-day(getdate())+1,getdate()) and CreateBy ='{0}'  and YEAR(CreateTime) >= 2014 and Status = 1 ", Me.UserID))
            Dim _MyPoint As Integer = Integer.Parse(MyPoint)
            Return _MyPoint
            Return 0
        End Get
    End Property
    Property _MovementX As Integer
    Public Property MovementX As Integer
        Get
            Return _MovementX
        End Get
        Set(ByVal value As Integer)
            _MovementX = value
        End Set
    End Property

    Public ReadOnly Property LatelyPointDateX As DateTime
        Get
            Dim MyLatelyPointDate As Object = dbUtil.dbExecuteScalar("my", String.Format("select TOP 1 CreateTime FROM  ChampionClub_Action where createby ='{0}' ORDER BY CreateTime DESC ", Me.UserID))
            If MyLatelyPointDate IsNot Nothing AndAlso Date.TryParse(MyLatelyPointDate, Now) Then
                Return CDate(MyLatelyPointDate)
            End If
            Return DateTime.MinValue
        End Get
    End Property
End Class

