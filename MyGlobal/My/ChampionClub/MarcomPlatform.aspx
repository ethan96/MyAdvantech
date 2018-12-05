<%@ Page Title="" ValidateRequest="false" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register Namespace="eBizAEUControls" TagPrefix="uc1" %>
<script runat="server">
   
    Dim MyDC As New MyChampionClubDataContext
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Util.IsAEUIT() OrElse Util.IsPCP_Marcom(Session("user_id"), "") Then
            Else
                Response.Redirect("~/home.aspx")
            End If
            
            LB4.ForeColor = Drawing.Color.Red
            td1.BgColor = "#DDD9C3"
            td2.BgColor = "#DDD9C3"
            td3.BgColor = "#DDD9C3"
            td4.BgColor = "#C4BD97"
            td4.Visible = True
            Panel1.Visible = False
            Panel2.Visible = False
            Panel3.Visible = False
            Panel4.Visible = True
            BindRt4()
            
            'JJ 2014/5/27：Participants List只有Liliana和Stefanie才能看到
            'If String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) OrElse String.Equals(Session("user_id"), "liliana.wen@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
            '    tr1.Visible = True
            'Else
            '    tr1.Visible = False
            'End If
            
            'JJ 2014/5/27：Participants List內的Delete功能只有Liliana和Stefanie才能使用
            If String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) OrElse String.Equals(Session("user_id"), "liliana.wen@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
                hf_del.Value = "1"
            Else
                hf_del.Value = "0"
            End If
            
            
            'BTsendemail1.Visible = False
            'If Util.IsAEUIT() Then BTsendemail1.Visible = True
        End If
        If Session("org_id").ToString.StartsWith("CN") Then
            Othercss = ""
        End If
    End Sub
    Public Function GetMarcomRBUS() As String()
        Dim RBUS As String() = New String() {}
        Dim MyMMDC As New MyCampaignDBDataContext()
        Dim MyMMRBU As Object = From P In MyMMDC.CAMPAIGN_REQUEST_MarketingManagers
                                Join R In MyMMDC.CAMPAIGN_Request_MarketingManager_RBUs
                                On P.ID Equals R.MarketingManagerID
                                Where P.Email = Session("USER_ID").ToString.Trim
                                Select R
        Dim strArray As New ArrayList
        For Each i In MyMMRBU
            strArray.Add(i.RBU.ToString.Trim)
        Next
        RBUS = CType(strArray.ToArray(GetType(String)), String())
        Return RBUS
    End Function
    
    '取得ChampionClub_Admin中當年度的Sales
    Public Function GetAdminUser() As String()
        Dim USER As String() = New String() {}
        Dim MyMMDC As New MyChampionClubDataContext()
        Dim MyMMRBU As Object = From P In MyMMDC.ChampionClub_Admins
                                Where P.year = CStr(DateTime.Now.Year)
                                Select P.userID
        Dim strArray As New ArrayList
        For Each i In MyMMRBU
            strArray.Add(i.ToString.Trim)
        Next
        USER = CType(strArray.ToArray(GetType(String)), String())
        Return USER
    End Function
    
    Public Shared Function GetMarcomRBUS2() As String()
        Dim RBUS As String() = New String() {}
        Dim MyMMDC As New MyCampaignDBDataContext()
        Dim MyMMRBU As Object = From P In MyMMDC.CAMPAIGN_REQUEST_MarketingManagers
                                Join R In MyMMDC.CAMPAIGN_Request_MarketingManager_RBUs
                                On P.ID Equals R.MarketingManagerID
                                Where P.Email = HttpContext.Current.User.Identity.Name
                                Select R
        Dim strArray As New ArrayList
        For Each i In MyMMRBU
            strArray.Add(i.RBU.ToString.Trim)
        Next
        RBUS = CType(strArray.ToArray(GetType(String)), String())
        Return RBUS
    End Function
    
    Private Sub BindRt1()
        Dim MyCR As List(Of ChampionClub_PersonalInfo) = MyDC.ChampionClub_PersonalInfos.OrderByDescending(Function(P) P.CREATED_Date).ToList
        If String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) OrElse String.Equals(Session("user_id"), "liliana.wen@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
         
            Rt1.DataSource = MyCR
        Else
           
            Rt1.DataSource = MyCR.Where(Function(p) GetMarcomRBUS().Contains(p.ORG)).ToList
        End If
        Rt1.DataBind()
    End Sub
    Private Sub BindRt2(pageIndex As Integer)
        Dim MyCR As List(Of ChampionClub_Action)
        Dim result As IQueryable(Of ChampionClub_Action)
        Dim recordCount As Integer
        Dim salesname As String
        'IC 2014/5/21：Liliana要求提供輸入框，供搜尋業務名稱做過濾條件，若沒有輸入業務名稱，則改用下拉選單所選年份進行過濾
        If Rt2SalesNameSearchBox.Text <> Nothing Then
            salesname = Trim(Rt2SalesNameSearchBox.Text)
            MyCR = MyDC.ChampionClub_Actions.Where(Function(p) p.Status <> MyChampionClubUtil.CC_Status.Cancel).Where(Function(x) x.CreateBy.IndexOf(salesname) > -1).OrderByDescending(Function(P) P.CreateTime).ToList
        Else
            MyCR = MyDC.ChampionClub_Actions.Where(Function(p) p.Status <> MyChampionClubUtil.CC_Status.Cancel).Where(Function(x) x.CreateTime.Value.Year.ToString() = Rt2DatetimeList.SelectedItem.Value).OrderByDescending(Function(P) P.CreateTime).ToList
        End If
        
        If Util.IsAEUIT() OrElse String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) OrElse String.Equals(Session("user_id"), "liliana.wen@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
            'IC 2014/5/21：Repeater分頁設定
            recordCount = MyCR.Count
            If pageIndex * 10 > MyCR.Count - 1 Then
                MyCR = MyCR.GetRange(10 * (pageIndex - 1), MyCR.Count - 10 * (pageIndex - 1))
            Else
                MyCR = MyCR.GetRange(10 * (pageIndex - 1), 10)
            End If
            Rt2.DataSource = MyCR
        Else
            If Rt2SalesNameSearchBox.Text <> Nothing Then
                salesname = Trim(Rt2SalesNameSearchBox.Text)
                result = From A In MyDC.ChampionClub_Actions
                                   Join P In MyDC.ChampionClub_PersonalInfos On P.UserID Equals A.CreateBy
                                   Where GetMarcomRBUS().Contains(P.ORG) AndAlso A.Status <> MyChampionClubUtil.CC_Status.Cancel AndAlso A.CreateBy.IndexOf(salesname) > -1
                                   Order By A.CreateTime Descending
                                    Select A
            Else
                result = From A In MyDC.ChampionClub_Actions
                                   Join P In MyDC.ChampionClub_PersonalInfos On P.UserID Equals A.CreateBy
                                   Where GetMarcomRBUS().Contains(P.ORG) AndAlso A.Status <> MyChampionClubUtil.CC_Status.Cancel AndAlso A.CreateTime.Value.Year.ToString() = Rt2DatetimeList.SelectedItem.Value
                                   Order By A.CreateTime Descending
                                    Select A
            End If
            recordCount = result.Count
            If pageIndex * 10 > result.Count - 1 Then
                Rt2.DataSource = result.ToList().GetRange(10 * (pageIndex - 1), result.Count - 10 * (pageIndex - 1))
                MyCR = result.ToList().GetRange(10 * (pageIndex - 1), result.Count - 10 * (pageIndex - 1))
            Else
                Rt2.DataSource = result.ToList().GetRange(10 * (pageIndex - 1), 10)
                MyCR = result.ToList().GetRange(10 * (pageIndex - 1), 10)
            End If
        End If
        Rt2.DataBind()
        Me.Rt2PopulatePager(recordCount, pageIndex) 'IC 2014/5/21：Repeater分頁設定
        
        For i As Integer = 0 To MyCR.Count - 1
            Dim _cr As ChampionClub_Action = MyCR.Item(i)
            Dim MyP As ChampionClub_PersonalInfo = MyDC.ChampionClub_PersonalInfos.Where(Function(P) P.UserID = _cr.CreateBy).FirstOrDefault
            If MyP IsNot Nothing Then
                CType(Rt2.Items(i).FindControl("LitPD"), Literal).Text = MyP.PD_Group
            End If
            Dim MyCRA As List(Of ChampionClub_Action_Achievement) = MyDC.ChampionClub_Action_Achievements.Where(Function(P) P.ACTION_ID = _cr.ID).ToList
            Dim achievement As Integer = 0
            For Each CRA As ChampionClub_Action_Achievement In MyCRA
                Dim _cra As ChampionClub_Action_Achievement = CRA
                If Not IsDBNull(_cra.RULE_ID) Then
                    CType(Rt2.Items(i).FindControl("TBRule" + _cra.RULE_ID.ToString), TextBox).Text = _cra.ACHIEVEMENT : achievement += CInt(_cra.ACHIEVEMENT)
                    CType(Rt2.Items(i).FindControl("TBPoint" + _cra.RULE_ID.ToString), TextBox).Text = _cra.POINT
                End If
            Next
            CType(Rt2.Items(i).FindControl("TBTotal"), TextBox).Text = achievement.ToString
            Dim ProfileList As List(Of ChampionClub_PersonalInfo) = MyDC.ChampionClub_PersonalInfos.Where(Function(P) P.UserID = _cr.CreateBy).ToList
            If ProfileList.Count > 0 Then
                Dim Profile As ChampionClub_PersonalInfo = ProfileList.Item(0)
                If Profile.ORG.Equals("AAC", StringComparison.OrdinalIgnoreCase) OrElse Profile.ORG.Equals("AENC", StringComparison.OrdinalIgnoreCase) _
                    OrElse Profile.ORG.Equals("ANA", StringComparison.OrdinalIgnoreCase) OrElse Profile.ORG.Equals("ANADMF", StringComparison.OrdinalIgnoreCase) Then
                    For j As Integer = 4 To 9
                        CType(Rt2.Items(i).FindControl("trRule" + j.ToString), HtmlTableRow).Visible = True
                    Next
                End If
            End If
        Next
        
        'Rt2.DataBind()
    End Sub
    Private Sub BindRt3(pageIndex As Integer)
        Dim MyCR As List(Of ChampionClub_Reddem)
        Dim result As IQueryable(Of ChampionClub_Reddem)
        Dim recordCount As Integer
        Dim salesname As String
        'IC 2014/5/21：Liliana要求提供輸入框，供搜尋業務名稱做過濾條件，若沒有輸入業務名稱，則改用下拉選單所選年份進行過濾
        If Rt3SalesNameSearchBox.Text <> Nothing Then
            salesname = Trim(Rt3SalesNameSearchBox.Text)
            MyCR = MyDC.ChampionClub_Reddems.Where(Function(c) c.CreateBy.IndexOf(salesname) > -1).OrderByDescending(Function(P) P.CreateTime).ToList
        Else
            MyCR = MyDC.ChampionClub_Reddems.Where(Function(p) p.CreateTime.Value.Year.ToString() = Rt3DatetimeList.SelectedItem.Value).OrderByDescending(Function(P) P.CreateTime).ToList
        End If
        If Util.IsAEUIT() OrElse String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) OrElse String.Equals(Session("user_id"), "liliana.wen@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
            'IC 2014/5/21：Repeater分頁設定
            recordCount = MyCR.Count
            If pageIndex * 10 > MyCR.Count - 1 Then
                MyCR = MyCR.GetRange(10 * (pageIndex - 1), MyCR.Count - 10 * (pageIndex - 1))
            Else
                MyCR = MyCR.GetRange(10 * (pageIndex - 1), 10)
            End If
            Rt3.DataSource = MyCR
            
        Else
            If Rt3SalesNameSearchBox.Text <> Nothing Then
                salesname = Trim(Rt3SalesNameSearchBox.Text)
                result = From R In MyDC.ChampionClub_Reddems
                                 Join P In MyDC.ChampionClub_PersonalInfos On P.UserID Equals R.CreateBy
                                 Where GetMarcomRBUS().Contains(P.ORG) AndAlso R.CreateBy.IndexOf(salesname) > -1
                                  Select R
            Else
                result = From R In MyDC.ChampionClub_Reddems
                                 Join P In MyDC.ChampionClub_PersonalInfos On P.UserID Equals R.CreateBy
                                 Where GetMarcomRBUS().Contains(P.ORG) AndAlso R.CreateTime.Value.Year.ToString() = Rt3DatetimeList.SelectedItem.Value
                                  Select R
            End If
            recordCount = result.Count
            If pageIndex * 10 > result.Count - 1 Then
                Rt3.DataSource = result.ToList().GetRange(10 * (pageIndex - 1), result.Count - 10 * (pageIndex - 1))
            Else
                Rt3.DataSource = result.ToList().GetRange(10 * (pageIndex - 1), 10)
            End If
        End If
        Rt3.DataBind()
        Me.Rt3PopulatePager(recordCount, pageIndex) 'IC 2014/5/21：Repeater分頁設定
    End Sub

    Private Sub BindRt4()
        'JJ 2014/5/24：初始化下拉選單-取出非本年度的
        Rt4DatetimeList.Items.Clear()
        Rt4DatetimeList.Items.Add(New ListItem("Please select year", ""))
        Dim result As Object
        
        If Util.IsAEUIT() OrElse String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
            result = (From A In MyDC.ChampionClub_Admins
                      Where A.year <> DateTime.Now.Year
                      Select A.year).Distinct()
        Else
            result = (From A In MyDC.ChampionClub_Admins
                     Where (GetMarcomRBUS().Contains(A.ORG) And A.year <> DateTime.Now.Year)
                     Select A.year).Distinct()
        End If
        
        For Each obj In result
            Rt4DatetimeList.Items.Add(obj.ToString())
        Next
        
        'JJ 2014/5/29：取出Marcom相關的sales
        ddl_sales.Items.Clear()
        ddl_sales.Items.Add(New ListItem("Please select Sales", ""))
        If Util.IsAEUIT() OrElse String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
            result = (From A In MyDC.ChampionClub_PersonalInfos
                      Where (Not GetAdminUser().Contains(A.UserID))
                      Select A.UserID, Name = A.LastName + A.FirstName).Distinct()
        Else
            result = (From A In MyDC.ChampionClub_PersonalInfos
                     Where (GetMarcomRBUS().Contains(A.ORG) And Not GetAdminUser().Contains(A.UserID))
                     Select A.UserID, Name = A.LastName + " " + A.FirstName).Distinct()
        End If
        For Each obj In result
            'ddl_sales.Items.Add(obj.ToString())
            ddl_sales.Items.Add(New ListItem(obj.UserID, obj.Name))
        Next
    End Sub
    
    Protected Sub Rt3_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim drv As ChampionClub_Reddem = CType(e.Item.DataItem, ChampionClub_Reddem)
            If drv.Status = -1 Then e.Item.Visible = False
            Dim DDlSTATUS As DropDownList = CType(e.Item.FindControl("DDlSTATUS"), DropDownList)
            For Each myCode As Integer In [Enum].GetValues(GetType(MyChampionClubUtil.CC_Reddem_Status))
                Dim strName As String = [Enum].GetName(GetType(MyChampionClubUtil.CC_Reddem_Status), myCode).ToString.Replace("_", " ")
                Dim strVaule As String = myCode.ToString
                DDlSTATUS.Items.Add(New ListItem(strName, strVaule))
            Next
            Dim TBMarcomContent As TextBox = CType(e.Item.FindControl("TBMarcomContent"), TextBox)
            Dim BtSubmit As Button = CType(e.Item.FindControl("BtSubmit"), Button)
            Dim hideCreateTime As Label = CType(e.Item.FindControl("hideCreateTime"), Label)
            'IC 2014/5/21：比對如果是今年以前的資料，不可修改或刪除
            If DateTime.Now.Year > Integer.Parse(hideCreateTime.Text) Then
                DDlSTATUS.Enabled = False
                TBMarcomContent.Enabled = False
                BtSubmit.Enabled = False
            Else
                DDlSTATUS.Enabled = True
                TBMarcomContent.Enabled = True
                BtSubmit.Enabled = True
            End If
        End If
    End Sub
    
    Protected Sub Rt2_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim btdiv As HtmlGenericControl = CType(e.Item.FindControl("btdiv"), HtmlGenericControl)
            Dim pamc As HtmlGenericControl = CType(e.Item.FindControl("pamc"), HtmlGenericControl)
            Dim hideCreateTime As Label = CType(e.Item.FindControl("hideCreateTime"), Label)
            Dim mypoints As Label = CType(e.Item.FindControl("myPoints"), Label)
            'IC 2014/5/21：比對如果是今年以前的資料，不可修改或刪除
            If DateTime.Now.Year > Integer.Parse(hideCreateTime.Text) Then
                mypoints.Visible = True
                btdiv.Visible = False
                pamc.Visible = False
            Else
                mypoints.Visible = False
                btdiv.Visible = True
            End If
        End If
    End Sub
    
    Protected Sub BtSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim bt As Button = CType(sender, Button)
        Dim _RepeaterItem As RepeaterItem = CType(bt.NamingContainer, RepeaterItem)
        'Dim drv As DataRowView = CType(_RepeaterItem.DataItem, DataRowView)
        Dim ReddemID As String = bt.CommandArgument
        Dim ddl As DropDownList = CType(_RepeaterItem.FindControl("DDlSTATUS"), DropDownList)
        Dim TB As TextBox = CType(_RepeaterItem.FindControl("TBMarcomContent"), TextBox)
        Dim Reddem As ChampionClub_Reddem = MyDC.ChampionClub_Reddems.Where(Function(P) P.ReddemID = ReddemID).FirstOrDefault
        If Reddem IsNot Nothing Then
            Reddem.Status = Integer.Parse(ddl.SelectedValue)
            Reddem.MarcomContent = TB.Text.Replace("'", "''")
            Reddem.UpdateBy = Session("USER_ID").ToString
            Reddem.UpdateTime = Now
        End If
        MyDC.SubmitChanges()
        BindRt3(1)
    End Sub

    Protected Sub BtSubmit2_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim bt As Button = CType(sender, Button)
        Dim _RepeaterItem As RepeaterItem = CType(bt.NamingContainer, RepeaterItem)
        'Dim drv As DataRowView = CType(_RepeaterItem.DataItem, DataRowView)
        Dim id As String = bt.CommandArgument
        'Dim TBpoint As TextBox = CType(_RepeaterItem.FindControl("TBpoint"), TextBox)
        'If Integer.TryParse(TBpoint.Text.Trim, 0) = False Then
        '    Util.JSAlert(Me.Page, "invalid  number")
        '    Exit Sub
        'End If
        Dim TB As TextBox = CType(_RepeaterItem.FindControl("TBMarcomComments"), TextBox)
        Dim Action As ChampionClub_Action = MyDC.ChampionClub_Actions.Where(Function(P) P.ID = id).FirstOrDefault
        If Action IsNot Nothing Then
            Action.Status = 1
            Action.MarcomComments = TB.Text.Replace("'", "''")
            Dim _TotalPoint As Double = 0
            For i As Integer = 1 To 9
                Dim TR As HtmlTableRow = CType(_RepeaterItem.FindControl("trRule" + i.ToString), HtmlTableRow)
                If TR.Visible = True Then
                    Dim TBR As TextBox = CType(_RepeaterItem.FindControl("TBRule" + i.ToString), TextBox)
                    Dim TBP As TextBox = CType(_RepeaterItem.FindControl("TBPoint" + i.ToString), TextBox)
                    Dim point As Double = 0
                    If TBR.Text.Trim <> "" AndAlso TBP.Text.Trim <> "" AndAlso Double.TryParse(TBP.Text.Trim, point) = True Then
                        _TotalPoint += point
                        Dim rule_id As Integer = i
                        Dim Upd_Achievement As ChampionClub_Action_Achievement = MyDC.ChampionClub_Action_Achievements.Where(Function(P) P.ACTION_ID = id And P.RULE_ID = rule_id).FirstOrDefault
                        If Upd_Achievement IsNot Nothing Then
                            With Upd_Achievement
                                .ACHIEVEMENT = TBR.Text.Trim
                                .POINT = point
                                .UPLOADED_BY = HttpContext.Current.User.Identity.Name
                                .UPLOADED_DATE = Now
                            End With
                        Else
                            Dim Achievement As New ChampionClub_Action_Achievement
                            With Achievement
                                .ACTION_ID = id
                                .RULE_ID = rule_id
                                .ACHIEVEMENT = TBR.Text.Trim
                                .POINT = point
                                .CREATED_BY = HttpContext.Current.User.Identity.Name
                                .CREATED_DATE = Now
                            End With
                            MyDC.ChampionClub_Action_Achievements.InsertOnSubmit(Achievement)
                        End If
                        MyDC.SubmitChanges()
                    Else
                        Dim rule_id As Integer = i
                        Dim Upd_Achievement As ChampionClub_Action_Achievement = MyDC.ChampionClub_Action_Achievements.Where(Function(P) P.ACTION_ID = id And P.RULE_ID = rule_id).FirstOrDefault
                        If Upd_Achievement IsNot Nothing Then
                            MyDC.ChampionClub_Action_Achievements.DeleteOnSubmit(Upd_Achievement)
                            MyDC.SubmitChanges()
                        End If
                    End If
                End If
            Next
            Action.Points = _TotalPoint
        End If
        MyDC.SubmitChanges()
        BindRt2(1)
    End Sub

    Protected Sub LB_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim LB As LinkButton = CType(sender, LinkButton)
        Dim LBid As String = LB.ID
        LB1.ForeColor = Drawing.Color.Blue
        LB2.ForeColor = Drawing.Color.Blue
        LB3.ForeColor = Drawing.Color.Blue
        LB4.ForeColor = Drawing.Color.Blue
        LB.ForeColor = Drawing.Color.Red
        Panel1.Visible = False
        Panel2.Visible = False
        Panel3.Visible = False
        Panel4.Visible = False
        If LBid = "LB1" Then
            Panel1.Visible = True
            td1.BgColor = "#C4BD97"
            td2.BgColor = "#DDD9C3"
            td3.BgColor = "#DDD9C3"
            td4.BgColor = "#DDD9C3"
            BindRt1()
        End If
        If LBid = "LB2" Then
            Panel2.Visible = True
            td1.BgColor = "#DDD9C3"
            td2.BgColor = "#C4BD97"
            td3.BgColor = "#DDD9C3"
            td4.BgColor = "#DDD9C3"
            'BindRt2()
            'IC 2014/5/21：剛進入畫面時不顯示資料
            Rt2.DataSource = Nothing
            Rt2.DataBind()
            Rt2Pager.DataSource = Nothing
            Rt2Pager.DataBind()
            'IC 2014/5/21：初始化下拉選單
            Rt2DatetimeList.Items.Clear()
            Rt2DatetimeList.Items.Add(New ListItem("Please select year", Nothing))
            Dim result As Object = (From A In MyDC.ChampionClub_Actions
                             Where A.Status <> MyChampionClubUtil.CC_Status.Cancel
                              Select A.CreateTime.Value.Year).Distinct()
            For Each obj In result
                Rt2DatetimeList.Items.Add(obj.ToString())
            Next
            SalesNameList.Items.Clear()
            Dim sales As Object = From A In MyDC.ChampionClub_PersonalInfos
                                   Where A.ORG = "AAC"
                                   Select A.UserID
            For Each obj In sales
                SalesNameList.Items.Add(obj.ToString())
            Next
            'ICC 2015/2/24 Add year selector
            CreateYear.Items.Clear()
            Dim yy As Integer = DateTime.Now.Year
            For i As Integer = 0 To 1
                CreateYear.Items.Add(New ListItem(yy.ToString, yy.ToString))
                yy = yy - 1
            Next
            'IC 2014/5/21：比對如果org是US的，才會顯示新增欄位
            Dim org As String = Session("org_id").ToString.Substring(0, 2)
            If AuthUtil.IsInterConUserV2() Then
                org = "InterCon"
            End If
            If org = "US" Then
                UsPanel.Visible = True
            Else
                UsPanel.Visible = False
            End If
        End If
        If LBid = "LB3" Then
            Panel3.Visible = True
            td1.BgColor = "#DDD9C3"
            td2.BgColor = "#DDD9C3"
            td3.BgColor = "#C4BD97"
            td4.BgColor = "#DDD9C3"
            'BindRt3()
            Rt3.DataSource = Nothing
            Rt3.DataBind()
            Rt3Pager.DataSource = Nothing
            Rt3Pager.DataBind()
            Rt3DatetimeList.Items.Clear()
            Rt3DatetimeList.Items.Add(New ListItem("Please select year", Nothing))
            Dim result As Object = (From A In MyDC.ChampionClub_Reddems
                                    Where A.Status <> MyChampionClubUtil.CC_Status.Cancel
                                    Select A.CreateTime.Value.Year).Distinct()
            For Each obj In result
                Rt3DatetimeList.Items.Add(obj.ToString())
            Next
        End If
        If LBid = "LB4" Then
            Panel4.Visible = True
            td1.BgColor = "#DDD9C3"
            td2.BgColor = "#DDD9C3"
            td3.BgColor = "#DDD9C3"
            td4.BgColor = "#C4BD97"
            BindRt4()
        End If
    End Sub
    Dim Othercss As String = "hide"
    Protected Sub BTsendemail1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sendbtid As String = CType(sender, Button).ID
        Dim strSubject As String = TBSubject.Text
        Dim strFrom As String = Session("user_id").ToString
        Dim strTo As String = ""
        Dim CCemails As String() = TBCC.Text.Trim.Trim(New Char() {","}).Split(New Char() {","})
        For Each email As String In CCemails
            If Not Util.IsValidEmailFormat(email) Then
                Util.JSAlert(Me.Page, "CC Is not valid email address.")
            End If
        Next
        Dim strCC As String = TBCC.Text.Trim.Trim(New Char() {","}) + "," + Session("user_id").ToString '"Liliana.Wen@advantech.com.tw,Stefanie.Chang@advantech.com.tw"
        Dim strBcc As String = "tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn"
        Dim mailbody As String = String.Empty
        Dim userid As String = Request.Form("ckuserid")
        Dim Cids As String() = userid.Split(","c)
        Dim smClient As Net.Mail.SmtpClient = New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Dim AmazonClient As Amazon.SimpleEmail.AmazonSimpleEmailServiceClient = Nothing
        For i As Integer = 0 To Cids.Length - 1
            Dim curruser As ChampionClub_PersonalInfo = MyDC.ChampionClub_PersonalInfos.Where(Function(P) P.UserID = Cids(i)).FirstOrDefault
            If curruser IsNot Nothing Then
                Dim mailbodystr As String = "<style type=""text/css"">body{font-family: Arial,Calibri;font-size: 12px;margin: 0px;} p{line-height: 20px;}</style>"
                mailbodystr += "<span style=""font-family: Arial,Calibri;"">" + TBGreeting.Text.Trim.Replace("$Customer_First_Name$", curruser.FirstName) + "</span><br/>" ' String.Format("Dear {0}", curruser.FirstName)
                Dim curruserpoint As Integer = curruser.CurrentPointX 'MyChampionClubUtil.GetAvailablePoint(curruser.UserID)
                If Not CBnotshowpoint.Checked Then
                    mailbodystr += "<br/>" + TBPoint.Text.Trim.Replace("$Customer_Point$", curruserpoint) 'you points is {0}, ", curruserpoint)   
                End If
                'Dim ShowOrg As String = Left(MYSAPBIZ.RBU2Org(curruser.ORG, ""), 2)
                'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("SELECT TOP 1 name, points FROM dbo.ChampionClub_Prize where ORG ='{0}' AND points >{1} ORDER BY prize_level", ShowOrg, curruserpoint))
                'If dt.Rows.Count > 0 Then
                '    mailbodystr += String.Format("you will get ""{0}(Points:{1})"" next phase.", dt.Rows(0).Item("name"), dt.Rows(0).Item("points"))
                'End If
                mailbody = mailbodystr + "<span style=""font-family: Arial,Calibri;"">" + HFbody.Value  + "</span><br/>"
              mailbody = mailbody.Replace("ShowFile.ashx?", String.Format("ShowFile.ashx?UID={0}&", curruser.UserID))
                strTo = curruser.UserID
                If Util.IsValidEmailFormat(strTo) Then
                    Dim msg As New Net.Mail.MailMessage()
                    msg.Subject = strSubject : msg.IsBodyHtml = True
                    If String.Equals(sendbtid, "BTsendemail1") Then
                        msg.To.Add(HttpContext.Current.Session("user_id"))
                        msg.CC.Add(strCC)
                        msg.Bcc.Add("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn")
                        msg.Body = "TO:" + msg.To.ToString + "<BR/>CC:" + msg.CC.ToString + "<BR/>BCC:" + msg.Bcc.ToString + "<HR/>" + mailbody.Trim()
                    Else
                        msg.To.Add(strTo)
                        msg.CC.Add(strCC)
                        msg.Bcc.Add(strBcc)
                        msg.Body = mailbody
                    End If
                    If String.Equals(sendbtid, "BTpreview") Then
                        Me.UPPickAccount.Update() : Me.MPPickAccount.Show()
                        LitPreview.Text = mailbody.Trim
                        Exit Sub
                    End If
                    Dim ErrorMessage As String = String.Empty
                    'If strTo Like "*@advantech*" Then
                    '    MailUtil.SendFromACLSMTP(msg, strFrom, strFrom, smClient, ErrorMessage)
                    'Else
                    'ICC 2015/3/6 Amazon mail service is no longer valid since 2013. Replace mail server to ACL smtp server. Also capture error message to db
                    'MailUtil.SendFromAmazon(msg, strFrom, strFrom, AmazonClient, ErrorMessage)
                    Dim sendresult As Boolean = MailUtil.SendFromACLSMTP(msg, strFrom, strFrom, smClient, ErrorMessage)
                    
                    If sendresult Then
                        Dim MailsHistory As New ChampionClub_SendMail_History
                        With MailsHistory
                            .MailFrom = strFrom : .MailTO = strTo : .MailCC = strCC : .MailBCC = strBcc
                            .Subject = msg.Subject : .Body = msg.Body : .Sender = Session("user_id") : .SendTime = Now
                        End With
                        MyDC.ChampionClub_SendMail_Histories.InsertOnSubmit(MailsHistory)
                        MyDC.SubmitChanges()
                    Else
                        Util.InsertMyErrLog(ErrorMessage) 'If sent message fail, then insert ErrLog
                        Util.JSAlert(Me.Page, "Sent failed")
                        Exit Sub
                    End If
                    
                End If
            End If
        Next
        Util.JSAlert(Me.Page, "Sent successfully.")
    End Sub

    Protected Sub CBnotshowpoint_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        CBnotshowpoint.Attributes.Add("onclick","check2(this)")
    End Sub
    <Services.WebMethod()> _
  <Web.Script.Services.ScriptMethod()> _
    Public Shared Function DelAction(ByVal id As String) As String
        Dim jsr As New Script.Serialization.JavaScriptSerializer
        Dim hash As New Hashtable()
        Try
            Dim MyDC As New MyChampionClubDataContext
            Dim Action As ChampionClub_Action = MyDC.ChampionClub_Actions.Where(Function(P) P.ID = id).FirstOrDefault
            If Action IsNot Nothing Then
                Action.Status = MyChampionClubUtil.CC_Status.Cancel
                MyDC.SubmitChanges()
            End If
            hash("error") = 1
            hash("desc") = "Sucess"
        Catch ex As Exception
            hash("error") = 0
            hash("desc") = ex.Message.ToString
        End Try
        Return jsr.Serialize(hash)
    End Function
    
    <Services.WebMethod()> _
 <Web.Script.Services.ScriptMethod()> _
    Public Shared Function DelParticipants(ByVal userid As String) As String
        Dim jsr As New Script.Serialization.JavaScriptSerializer
        Dim hash As New Hashtable()
        Try
            'JJ 2014/3/25：Liliana要求要有刪除的功能
            Dim MyDC As New MyChampionClubDataContext
            Dim Action As ChampionClub_PersonalInfo = MyDC.ChampionClub_PersonalInfos.Where(Function(P) P.UserID = userid).FirstOrDefault
            If Action IsNot Nothing Then
                MyDC.ChampionClub_PersonalInfos.DeleteOnSubmit(Action)
                MyDC.SubmitChanges()
            End If
            hash("error") = 1
            hash("desc") = "Sucess"
        Catch ex As Exception
            hash("error") = 0
            hash("desc") = ex.Message.ToString
        End Try
        Return jsr.Serialize(hash)
    End Function

    Protected Sub SearchPoint_Click(sender As Object, e As System.EventArgs)
        BindRt2(1)
    End Sub
    
    Private Sub Rt2PopulatePager(recordCount As Integer, currentPage As Integer)
        Dim dblPageCount As Double = CDbl(CDec(recordCount) / Convert.ToDecimal(10))
        Dim pageCount As Integer = CInt(Math.Ceiling(dblPageCount))
        Dim pages As New List(Of ListItem)()
        If pageCount > 0 Then
            For i As Integer = 1 To pageCount
                pages.Add(New ListItem(i.ToString(), i.ToString(), i <> currentPage))
            Next
        End If
        Rt2Pager.DataSource = pages
        Rt2Pager.DataBind()
    End Sub
    
    Protected Sub Rt2Page_Changed(sender As Object, e As EventArgs)
        Dim pageIndex As Integer = Integer.Parse(TryCast(sender, LinkButton).CommandArgument)
        Me.BindRt2(pageIndex)
    End Sub

    Protected Sub SearchExchange_Click(sender As Object, e As System.EventArgs)
        BindRt3(1)
    End Sub
    
    Private Sub Rt3PopulatePager(recordCount As Integer, currentPage As Integer)
        Dim dblPageCount As Double = CDbl(CDec(recordCount) / Convert.ToDecimal(10))
        Dim pageCount As Integer = CInt(Math.Ceiling(dblPageCount))
        Dim pages As New List(Of ListItem)()
        If pageCount > 0 Then
            For i As Integer = 1 To pageCount
                pages.Add(New ListItem(i.ToString(), i.ToString(), i <> currentPage))
            Next
        End If
        Rt3Pager.DataSource = pages
        Rt3Pager.DataBind()
    End Sub
    
    Protected Sub Rt3Page_Changed(sender As Object, e As EventArgs)
        Dim pageIndex As Integer = Integer.Parse(TryCast(sender, LinkButton).CommandArgument)
        Me.BindRt3(pageIndex)
    End Sub
    
    <Services.WebMethod()> _
<Web.Script.Services.ScriptMethod()> _
    Public Shared Function CreateAction(ByVal desc As String, ByVal p As String, ByVal mc As String, ByVal ra As String, ByVal sid As String) As String
        Dim jsr As New Script.Serialization.JavaScriptSerializer
        Dim hash As New Hashtable()
        Try
            'IC 2014/5/21：Liliana要求org是US可以新增
            Dim MyDC As New MyChampionClubDataContext
            Dim Action As New ChampionClub_Action
            Action.Description = Trim(desc)
            Action.Points = Double.Parse(Trim(p))
            Action.MarcomComments = Trim(mc)
            Action.RevenueAchievement = Trim(ra)
            Action.Status = MyChampionClubUtil.CC_Status.Get_Points
            Action.CreateBy = sid
            Action.CreateTime = DateTime.Now
            If Action IsNot Nothing Then
                MyDC.ChampionClub_Actions.InsertOnSubmit(Action)
                MyDC.SubmitChanges()
            End If

            hash("error") = 1
            hash("desc") = "Sucess"
        Catch ex As Exception
            hash("error") = 0
            hash("desc") = ex.Message.ToString
        End Try
        Return jsr.Serialize(hash)
    End Function

    Protected Sub btn_create_Click(sender As Object, e As System.EventArgs)

        'Points必填
        If Points.Text = "" Then
            Util.JSAlert(Me.Page, "The points is Empty!")
        Else
            'IC 2014/5/21：Liliana要求org是AAC可以新增
            Dim MyDC As New MyChampionClubDataContext
            Dim Action As New ChampionClub_Action
            
            If Reve.Text <> "" Then
                Action.RevenueAchievement = Trim(Reve.Text)
            End If
            If Desc.Text <> "" Then
                Action.Description = Trim(Desc.Text)
            End If
            
            Action.Points = Double.Parse(Trim(Points.Text))
            
            If Comm.Text <> "" Then
                Action.MarcomComments = Trim(Comm.Text)
            End If
            
            Action.Status = MyChampionClubUtil.CC_Status.Get_Points
            Action.CreateBy = SalesNameList.SelectedItem.Text
            'Action.CreateTime = DateTime.Now
            'ICC 2015/2/24 Modify create time rule. If selected year is past year, then set create time as past year 12/31
            If CreateYear.SelectedItem.Value = DateTime.Now.Year.ToString Then
                Action.CreateTime = DateTime.Now
            Else
                Dim beforyear As Integer = DateTime.Now.Year - 1
                Action.CreateTime = New DateTime(beforyear, 12, 31)
            End If
            
            If Action IsNot Nothing Then
                MyDC.ChampionClub_Actions.InsertOnSubmit(Action)
                MyDC.SubmitChanges()
            End If
        
            '更新table表
            BindRt2(1)
            '清空欄位
            Reve.Text = ""
            Desc.Text = ""
            Points.Text = ""
            Comm.Text = ""
            Util.JSAlert(Me.Page, "Sucess!")
        End If
        
    End Sub
    
    <Services.WebMethod()> _
<Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetData1(ByVal _SalesName As String, ByVal _Year As String) As String
        Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
        Dim rows As New List(Of Dictionary(Of String, Object))
        Dim row As Dictionary(Of String, Object) = Nothing
        Dim result As New Dictionary(Of String, Object)
        Dim sql As String = String.Format("select * from ChampionClub_Admin where year ='{0}' ", _Year)
        Dim dt As DataTable
       
        '不是liliana、stefanie或IT就限制ORG
        If Util.IsAEUIT() OrElse String.Equals(HttpContext.Current.User.Identity.Name, "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
        Else
            Dim arrORG As String() = GetMarcomRBUS2()
            Dim strORG As String = "("
            For i As Integer = 0 To arrORG.Count - 1
                If strORG = "(" Then
                    strORG += "'" + arrORG(i) + "'"
                Else
                    strORG += ",'" + arrORG(i) + "'"
                End If
            Next
            strORG += ")"
        
            If strORG <> "()" Then
                sql += " and ORG in " + strORG
            End If
        End If
        
        'salesName不為空就是要找該sales
        If Not String.IsNullOrEmpty(_SalesName) Then
            sql += " and userID like '%" + _SalesName + "%'"
        End If
        
        dt = dbUtil.dbGetDataTable("MY", sql)
        For i As Integer = 0 To dt.Rows.Count - 1
            Dim dr As DataRow = dt.Rows(i)
            row = New Dictionary(Of String, Object)
            For Each col As DataColumn In dt.Columns
                row.Add(col.ColumnName.Trim(), dr(col))
            Next
            rows.Add(row)
        Next
        result.Add("rows", rows)
        Return serializer.Serialize(result)
    End Function
    
    <Services.WebMethod()> _
<Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetData2() As String
        Dim year As String = CStr(Now.Year)
        Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
        Dim rows As New List(Of Dictionary(Of String, Object))
        Dim row As Dictionary(Of String, Object) = Nothing
        Dim result As New Dictionary(Of String, Object)
        Dim sql As String = String.Format("select * from ChampionClub_Admin where year ='{0}' ", year)
        Dim dt As DataTable
       
        '不是stefanie或IT就限制ORG
        If Util.IsAEUIT() OrElse String.Equals(HttpContext.Current.User.Identity.Name, "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
        Else
            Dim arrORG As String() = GetMarcomRBUS2()
            Dim strORG As String = "("
            For i As Integer = 0 To arrORG.Count - 1
                If strORG = "(" Then
                    strORG += "'" + arrORG(i) + "'"
                Else
                    strORG += ",'" + arrORG(i) + "'"
                End If
            Next
            strORG += ")"
        
            If strORG <> "()" Then
                sql += " and ORG in " + strORG
            End If
        End If
                
        dt = dbUtil.dbGetDataTable("MY", sql)
        For i As Integer = 0 To dt.Rows.Count - 1
            Dim dr As DataRow = dt.Rows(i)
            row = New Dictionary(Of String, Object)
            For Each col As DataColumn In dt.Columns
                row.Add(col.ColumnName.Trim(), dr(col))
            Next
            rows.Add(row)
        Next
        result.Add("rows", rows)
        Return serializer.Serialize(result)
    End Function
    
    <Services.WebMethod()> _
<Web.Script.Services.ScriptMethod()> _
    Public Shared Function AddSales(ByVal _SalesEmail As String, ByVal _SalesName As String) As String
        Dim year As String = CStr(Now.Year)
        Dim ReAddSales As New ReAddSales("", "", "", "")
        Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
               
        '先判斷是否有該筆資料了
        Dim sql As String = String.Format("select UserID,ORG from ChampionClub_Admin where UserID ='{0}' and year={1} ", _SalesEmail, year)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        If dt.Rows.Count = 0 Then
            '取出在總表內的個人資料
            Dim sql1 As String = String.Format("select UserID,LastName + ' ' + FirstName as Name,ORG from ChampionClub_PersonalInfo where UserID ='{0}' ", _SalesEmail)
            Dim dt1 As DataTable = dbUtil.dbGetDataTable("MY", sql1)
            
            If dt1.Rows.Count <> 0 Then
                Dim sql2 As String = String.Format("Insert into ChampionClub_Admin(userID,userName,year,ORG,CREATED_BY,CREATED_DATE)values('{0}','{1}',{2},'{3}','{4}',getdate())", CStr(dt1.Rows(0)(0)), CStr(dt1.Rows(0)(1)), year, CStr(dt1.Rows(0)(2)), HttpContext.Current.User.Identity.Name)
                Dim intAdd As Integer = dbUtil.dbExecuteNoQuery("MY", sql2)
                '大於0表示新增成功
                If intAdd > 0 Then
                    Dim sql3 As String = String.Format("select rowID,UserID,UserName from ChampionClub_Admin where UserID ='{0}' and year={1} ", _SalesEmail, year)
                    Dim dt3 As DataTable = dbUtil.dbGetDataTable("MY", sql3)
                    
                    If dt3.Rows.Count <> 0 Then
                        ReAddSales.errmag = ""
                        ReAddSales.rowid = CStr(dt3.Rows(0)(0))
                        ReAddSales.userid = CStr(dt3.Rows(0)(1))
                        ReAddSales.username = CStr(dt3.Rows(0)(2))
                    Else
                        '新增成功但查詢不到該Sales的資料
                        ReAddSales.errmag = "Add Sales is Success but sreach Sales data is empty!"
                    End If
                Else
                    '新增失敗
                    ReAddSales.errmag = "Add Sales failing!"
                End If
            Else
                '查無此Sales的資料
                ReAddSales.errmag = "This data of Sales is Empty!"
            End If
            
        Else
            '如果該sales已經存在
            ReAddSales.errmag = "This Sales has been Exist!"
        End If
       
        Return serializer.Serialize(ReAddSales)
    End Function
    
    <Services.WebMethod()> _
     <Web.Script.Services.ScriptMethod()> _
    Public Shared Function DelSales(ByVal _rowid As String) As String
        
        Dim ReAddSales As New ReAddSales("", "", "", "")
        Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
        
        If _rowid <> "" Then
            Dim sql As String = String.Format("delete from ChampionClub_Admin where rowID ={0} ", _rowid)
            Dim intAdd As Integer = dbUtil.dbExecuteNoQuery("MY", sql)
            
            '大於0表示刪除成功
            If intAdd > 0 Then
                ReAddSales.errmag = ""
                ReAddSales.rowid = _rowid
            Else
                '刪除失敗
                ReAddSales.errmag = "delete Sales failing!"
            End If
        Else
            '刪除失敗-因為沒有rowID
            ReAddSales.errmag = "delete Sales failing - not rowID!"
        End If
        
        
        Return serializer.Serialize(ReAddSales)
    End Function
    
    Public Sub Rt1_ItemDataBound(Sender As Object, e As RepeaterItemEventArgs)
        Dim item As RepeaterItem = e.Item
        Dim td1 As HtmlTableCell = DirectCast(item.FindControl("td_del"), HtmlTableCell)
        '只有Liliana和Stefanie才使用Delete，隱藏表身、表頭在JavaScript內隱藏
        If String.Equals(Session("user_id"), "Stefanie.Chang@advantech.com.tw", StringComparison.OrdinalIgnoreCase) OrElse String.Equals(Session("user_id"), "liliana.wen@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then
            td1.Visible = True
        Else
            td1.Visible = False
        End If
        
        'HtmlTableCell td = e.Item.FindControl("tdUserName") as HtmlTableCell; 
    End Sub
    
    Class ReAddSales
        Public errmag As String : Public rowid As String : Public userid As String : Public username As String
        Public Sub New(errmag As String, rowid As String, userid As String, username As String)
            errmag = errmag : rowid = rowid : userid = userid : username = username
        End Sub
    End Class
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
<script src="../../Includes/js/json2.js" type="text/javascript"></script>
    <script src="../../Includes/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="../../EC/redactor/redactor.min.js" type="text/javascript"></script>     
    <link href="../../Includes/EasyUI/themes/icon.css" rel="stylesheet" type="text/css" />
     <link href="../../Includes/EasyUI/themes/bootstrap/easyui.css" rel="stylesheet" type="text/css" />
     <script src="../../Includes/EasyUI/jquery.easyui.min.js" type="text/javascript"></script>  
<script type="text/javascript" charset="utf-8">

    $(function () {

        //只有Liliana和Stefanie才使用Delete，隱藏表頭、表身在Rt1_ItemDataBound內隱藏
        if ($("#<%=hf_del.ClientID %>").val() == "1") {
        } else {
            $("#th_del").hide();
        }


        var opt = $('#grid1');
        opt.datagrid({
            title: ' ', //標題
            width: $(window).width() / 3, //自動寬度
            height: 400,  //固定高度
            nowrap: false, //不截斷內文
            striped: true,  //列背景切換
            fitColumns: false,  //自動適應欄寬
            singleSelect: true,  //單選列
            remoteSort: false, //true發送命令到服務器請求排序數據，false本地自己排序
            method: 'post',
            idField: 'rowID',  //主索引
            pageSize: 20,
            pageList: [10, 20, 30, 40, 50], //每頁顯示筆數清單
            pagination: false, //是否啟用分頁
            rownumbers: true, //是否顯示列數
            remoteSort: false, //true發送命令到服務器請求排序數據，false本地自己排序
            columns: [[
                            { field: 'rowID', title: '<span class="txtcenter"><b>rowID</b></span>', width: 150, align: 'left', sortable: true },
                            { field: 'userName', title: '<span class="txtcenter"><b>Sales Name</b></span>', width: 120, align: 'center', sortable: true },
                            { field: 'userID', title: '<span class="txtcenter"><b>Sales Email</b></span>', width: 230, align: 'center', sortable: true },
                            { field: 'function', title: 'Add', sortable: false, width: 50, align: 'center',
                                formatter:
                               function (value, row, index) {
                                   var fan = "<input type='button' name='btnGVAdd' value='add' onclick='AddSalesForOld(" + index + ")'/><br />";
                                   return fan;
                               }
                            }
                    ]],
            onLoadSuccess: function (data) {
                //title置中
                $(".txtcenter").parent().parent().css("text-align", "center");
            }
        });
        //隱藏欄位
        opt.datagrid('hideColumn', 'rowID');

        var opt1 = $('#grid2');
        opt1.datagrid({
            title: '<span class="txtcenter"><b><%=Now.year %></b></span>', //標題
            width: $(window).width() / 3, //自動寬度
            height: 400,  //固定高度
            nowrap: false, //不截斷內文
            striped: true,  //列背景切換
            fitColumns: false,  //自動適應欄寬
            singleSelect: true,  //單選列
            remoteSort: false, //true發送命令到服務器請求排序數據，false本地自己排序
method:  'post',
            loader: function (param, success, error) {
                getData2(param, success, error);
            },
idField:  'rowID',  //主索引
            pageSize: 20,
            pageList: [10, 20, 30, 40, 50], //每頁顯示筆數清單
            pagination: false, //是否啟用分頁
            rownumbers: true, //是否顯示列數
            remoteSort: false, //true發送命令到服務器請求排序數據，false本地自己排序
            columns: [[
                            { field: 'rowID', title: '<span class="txtcenter"><b>rowID</b></span>', width: 150, align: 'left', sortable: true },
                            { field: 'userName', title: '<span class="txtcenter"><b>Sales Name</b></span>', width: 120, align: 'center', sortable: true },
                            { field: 'userID', title: '<span class="txtcenter"><b>Sales Email</b></span>', width: 230, align: 'center', sortable: true },
                            { field: 'function', title: 'Delete', sortable: false, width: 50, align: 'center',
formatter:
                               function (value, row, index) {
                                   var fan = "<input type='button' name='btnDel' value='del' onclick='delSales(" + index + ")'/><br />";
                                   return fan;
                               }
                            }

                    ]],
            onLoadSuccess: function (data) {
                //title置中
                $(".txtcenter").parent().parent().css("text-align", "center");
            }
        });
        //隱藏欄位
        opt1.datagrid('hideColumn', 'rowID');
    });

     function Query() {
                       
        $("#btnQry").attr("disabled", true);
        var sTitle = "<span class='txtcenter'><b> " + $.trim($("#<%=Rt4DatetimeList.ClientID %>").find(":selected").val()) + "</b></span>";
        var opt = $('#grid1');
        opt.datagrid({
            title: sTitle,
            //title: '<span class="txtcenter"><b><%=Now.year %></b></span>', //標題
            loader: function (param, success, error) {
                getData1(param, success, error);
            }
        });
        $("#btnQry").attr("disabled", false);
        return false;
    }

    function getData1(param, success, error) {
        
        $("#btnQry").attr("disabled", true);

        jQuery.ajax({
            type: "POST",
            url: '/My/ChampionClub/<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetData1',
            data: JSON.stringify({ _SalesName: $.trim($("#txtSalesName").val()), _Year: $.trim($("#<%=Rt4DatetimeList.ClientID %>").find(":selected").val()) }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                $("#btnQry").attr("disabled", false);
                //debugger;
                oColumns = $.parseJSON(data.d);
//                $.each(oColumns.rows,
//                    function (index, item) {
//                        //debugger;
//                        $("#<%=ddl_sales.ClientID%> option[value='" + item.userID + "']").remove();
//                    });

                success(oColumns);
            },
            error: function (msg) {
                $("#btnQry").attr("disabled", false);
            }
        });
    }

    function getData2(param, success, error) {

        jQuery.ajax({
            type: "POST",
url:    '/My/ChampionClub/<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetData2',
data:   '',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
               oColumns = $.parseJSON(data.d); success(oColumns);
            },
            error: function (msg) {
            }
        });
    }

    function AddSalesForOld(index) {
        var row = $('#grid1').datagrid('getData').rows[index]; //取得選取的列
        //由去年度或之前加入當年度中
        var SalesEmail = $.trim(row.userID); //由選取的列來取得Sales Email
        var SalesName = $.trim(row.userName); //由選取的列來取得Sales Name
        if (SalesEmail != "") {
            
            jQuery.ajax({
                type: "POST",
                 url: '/My/ChampionClub/<%=IO.Path.GetFileName(Request.PhysicalPath) %>/AddSales',
                data: JSON.stringify({ _SalesEmail: SalesEmail, _SalesName: SalesName }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    var result = $.parseJSON(data.d);
                    //errmag如果空白就是有成功
                    if (result.errmag == "") {
                        $("#<%=ddl_sales.ClientID%> option[value='" + result.username + "']").remove();
                        $('#grid1').datagrid('reload', data);
                        $('#grid2').datagrid('reload', data);
                    } else {
                        alert(result.errmag);
                    }
                },
                error: function (msg) {
                    alert('Add failed!');
                }
            });
        } else {
            alert('Please select a sales');
        }
    }

    function AddSalesForDDL() {
        //由總表內新增進當年度
        var SalesEmail = $.trim($("#<%=ddl_sales.ClientID %>").find(":selected").text());
        var SalesName = $.trim($("#<%=ddl_sales.ClientID %>").find(":selected").val());
        if (SalesEmail != "") {
            $("#btnAdd").attr("disabled", true);

            jQuery.ajax({
                type: "POST",
                url: '/My/ChampionClub/<%=IO.Path.GetFileName(Request.PhysicalPath) %>/AddSales',
                data: JSON.stringify({ _SalesEmail: SalesEmail, _SalesName: SalesName }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    var result = $.parseJSON(data.d);
                    //errmag如果空白就是有成功
                    if (result.errmag == "") {
                        //                        $('#AdminList').datagrid('insertRow', {
                        //                            index: 0,
                        //                            row: {
                        //                                rowID: result.rowid,
                        //                                userID: result.userid
                        //                            }
                        //                        });
                        //var data = $('#grid2').datagrid("getData");
                        debugger;
                        $("#<%=ddl_sales.ClientID%> option[value='" + result.username + "']").remove();
                        $('#grid2').datagrid('reload', data);
                    } else {
                        alert(result.errmag);
                    }

                    $("#btnAdd").attr("disabled", false);
                },
                error: function (msg) {
                    alert('Add failed!');
                    $("#btnAdd").attr("disabled", false);
                }
            });
        } else {
            alert('Please select a sales');
        }
    }

    function delSales(index) {
        
        var msg = "Do you really want to delete it?";
        if (confirm(msg) == true) {
            // return true;
        } else {
            return false;
        }
        var row = $('#grid2').datagrid('getData').rows[index]; //取得選取的列
        jQuery.ajax({
            type: "POST",
url:        '/My/ChampionClub/<%=IO.Path.GetFileName(Request.PhysicalPath) %>/DelSales',
            data: JSON.stringify({ _rowid: row.rowID }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (data) {
                
                var result = $.parseJSON(data.d);
                //errmag如果空白就是有成功
                if (result.errmag == "") {
                    //刪除後重新整理
                    //加回去總表的sales名單
                    var appenddata1 = "";
                    appenddata1 += "<option value = '" + $.trim(row.userName) + " '>" + $.trim(row.userID) + " </option>";
                    $("#<%=ddl_sales.ClientID%>").append(appenddata1);
                    $('#grid1').datagrid('reload', data); //去年度
                    $('#grid2').datagrid('reload', data); //當年度
                } else {
                    alert(result.errmag);
                }
            },
            error: function (msg) {
                alert('delete failed!');
            }
        });
    }
    

    function Participants_Del(UserID, number) {
        //JJ 2014/3/25：Liliana提出需要刪除參加者的功能
        var msg = "Do you really want to delete it?";
        if (confirm(msg) == true) {
            // return true;
        } else {
            return false;
        }

        var postData = JSON.stringify({ userid: UserID });

        $.ajax({
            type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/My/ChampionClub/MarcomPlatform.aspx/DelParticipants", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
            beforeSend: function (XMLHttpRequest) { },
            success: function (retData) {
                if ($.trim(retData.d) != "") {
                    var jsonObj = $.parseJSON(retData.d);
                    if (jsonObj.error == 1) {

                        //刪除後隱藏該列
                        $("#PL_" + number).hide("slow");

                    }
                    alert(jsonObj.desc);
                }
            },
            error: function (retData) {
                if ($.trim(retData.d) != "") {
                    alert(retData.d);
                }
            }
        });

    }
</script>
    <h2> Marcom Platform</h2>
    <table width="100%" border="1">
        <tr>
            <td height="35" valign="middle" align="center" id="td1" runat="server">
                <asp:LinkButton ID="LB1" runat="server" OnClick="LB_Click"><strong>Participants List</strong></asp:LinkButton>
            </td>
             <td height="35" valign="middle" align="center" id="td4" runat="server">
                <asp:LinkButton ID="LB4" runat="server" OnClick="LB_Click"><strong>Admin List</strong></asp:LinkButton>
            </td>
            <td align="center" id="td2" runat="server">
                <asp:LinkButton ID="LB2" runat="server" OnClick="LB_Click"><strong>Evaluation & Points Allocation</strong></asp:LinkButton>
            </td>
            <td align="center" id="td3" runat="server">
                <asp:LinkButton ID="LB3" runat="server" OnClick="LB_Click"><strong>Redeem Approval</strong></asp:LinkButton>
            </td>
        </tr>
        <tr>
            <td colspan="4" style="padding: 5px;">
                <asp:HiddenField ID="hf_del" runat="server" />
                <asp:Panel ID="Panel1" runat="server">
                    <table width="100%">
                        <thead>
                            <tr>
                                <th scope="col">
                                    #
                                </th>
                                <th>
                                </th>
                                <th scope="col">
                                    Joined Date
                                </th>
                                <th scope="col">
                                    Company
                                </th>
                                <th scope="col">
                                    ERPID
                                </th>
                                <th scope="col">
                                    Sales Name
                                </th>
                                <th scope="col">
                                    Current Point
                                </th>
                                <th scope="col">
                                    Job Title
                                </th>
                                <th scope="col">
                                    E-mail
                                </th>
                                <th scope="col">
                                    Tel.#
                                </th>
                                <th scope="col">
                                    PD Group
                                </th>
                                <th id="th_del" scope="col">
                                    Delete
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="Rt1" runat="server" onitemdatabound="Rt1_ItemDataBound">
                                <ItemTemplate>
                                    <tr class="odd<%# (Container.ItemIndex) mod 2 %>" id="PL_<%# (Container.ItemIndex + 1)%>">
                                        <td>
                                            <%# (Container.ItemIndex + 1)%>
                                        </td>
                                        <td>
                                            <input id="Checkbox1" type="checkbox" name="ckuserid" value="<%# Eval("UserID")%>" />
                                        </td>
                                        <td>
                                            <%# CDate(Eval("CREATED_Date")).ToString("yyyy-MM-dd")%>
                                        </td>
                                        <td>
                                            <%# Eval("CompanyX")%>
                                        </td>
                                        <td>
                                            <%# Eval("ErpID")%>
                                        </td>
                                        <td>
                                            <%# Eval("FirstName")%>
                                            <%# Eval("LastName")%>
                                        </td>
                                        <td>
                                            <%# Eval("CurrentPointX")%>
                                        </td>
                                        <td>
                                            <%# Eval("JobTitleX")%>
                                        </td>
                                        <td>
                                            <%# Eval("UserID")%>
                                        </td>
                                        <td>
                                            <%# Eval("Telephone")%>
                                        </td>
                                        <td>
                                            <%# Eval("PD_Group")%>
                                        </td>
                                        <td id="td_del" runat="server">
                                            <input id="btn_delete" type="button" value="Delete" onclick="return Participants_Del('<%# Eval("UserID")%>','<%# (Container.ItemIndex + 1)%>');" />
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                               <tr>
                                <td colspan="11" height="25" valign="middle" style="padding-top:20PX;">
                                    <img src="../../Images/gn.gif" /> <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/My/ChampionClub/MailsHistoryV2.aspx" Target="_blank" ForeColor="Red" Font-Underline="True">View the history </asp:HyperLink>
                                </td>
                                </tr>
                            <tr>
                                <td colspan="11">
                                    <table width="100%" style="margin-top: 10px;">
                                        <tr>
                                            <td width="50">
                                                <b>Subject:</b>
                                            </td>
                                            <td align="left">
                                                <asp:TextBox ID="TBSubject" runat="server" Width="95%"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="50">
                                                <b>CC:</b>
                                            </td>
                                            <td align="left">
                                                <asp:TextBox ID="TBCC" runat="server" Width="95%"></asp:TextBox>
                                                <asp:Label ID="Label3" runat="server" Width="95%" ForeColor="Red">(For example: Name1@advantech.com,Name2@advantech.com)</asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                            </td>
                                            <td align="left">
                                                <br />
                                                <asp:Label ID="TBGreeting" runat="server" Width="95%">Dear $Customer_First_Name$,</asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="tr1">
                                            <td>
                                            </td>
                                            <td align="left">
                                                <asp:Label ID="TBPoint" runat="server" Width="95%">Your current point is $Customer_Point$.</asp:Label>
                                            </td>
                                        </tr>
                                        <tr id="tr2">
                                            <td>
                                            </td>
                                            <td align="left">
                                                <asp:Label ID="Label1" runat="server" Width="95%" ForeColor="Red">(Your message will include the above two sentences, please always remember to press ‘preview’ before you send it)</asp:Label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right" valign="bottom" style="padding-top: 3px;">
                                                <asp:CheckBox ID="CBnotshowpoint" runat="server" OnLoad="CBnotshowpoint_Load" />&nbsp;&nbsp;
                                            </td>
                                            <td align="left">
                                           Don’t show current point
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>Body:</b>
                                            </td>
                                            <td align="left">
                                                <asp:HiddenField ID="HFbody" runat="server" />
                                                <div id="editor1" style="height:300px"  >
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="50">
                                            </td>
                                            <td valign="middle">
                                                <asp:Button ID="BTpreview" runat="server" Text="Preview" Width="150" Height="25"
                                                    OnClick="BTsendemail1_Click" OnClientClick="return check();" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                <asp:Button ID="BTsendemail1" runat="server" Text="Test sending" Width="150" Height="25"
                                                    OnClick="BTsendemail1_Click" OnClientClick="return check();" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                                <asp:Button ID="BTsendemail2" runat="server" Text="Send" Width="150" Height="25"
                                                    OnClick="BTsendemail1_Click" OnClientClick="return check();" />
                                                <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                                                    <ContentTemplate>
                                                    </ContentTemplate>
                                                    <Triggers>
                                                        <asp:AsyncPostBackTrigger ControlID="BTpreview" EventName="Click" />
                                                    </Triggers>
                                                </asp:UpdatePanel>
                                            </td>
                                        </tr>
                                    </table>
                                    <asp:Panel ID="PLPickAccount" runat="server" Style="display: none" CssClass="modalPopup"
                                        Width="700" Height="500">
                                        <div style="text-align: right;">
                                            <asp:ImageButton ID="CancelButtonAccount" runat="server" ImageUrl="~/Images/del.gif" />
                                        </div>
                                        <div>
                                            <asp:UpdatePanel ID="UPPickAccount" runat="server" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <div style="padding-left: 10px;">
                                                        <asp:Panel ID="prepanel" runat="server" ScrollBars="Auto" Width="680" Height="440">
                                                            <asp:Literal ID="LitPreview" runat="server"></asp:Literal>
                                                        </asp:Panel>
                                                    </div>
                                                    <br />
                                                    <asp:Label ID="Label2" runat="server" Width="95%" ForeColor="Red">(Since you have selected for many receivers, this default will only show the first person as an example)</asp:Label>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </div>
                                    </asp:Panel>
                                    <asp:LinkButton ID="lbDummyAccount" runat="server" />
                                    <ajaxToolkit:ModalPopupExtender ID="MPPickAccount" runat="server" TargetControlID="lbDummyAccount"
                                        PopupControlID="PLPickAccount" BackgroundCssClass="modalBackground" CancelControlID="CancelButtonAccount" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <script language="javascript" type="text/javascript">
                        function check() {
                            var trlist = document.getElementsByTagName("input");
                            var checkedCount = 0;
                            for (var i = 0; i < trlist.length; i++) {
                                if (trlist[i].type == "checkbox" && trlist[i].name == "ckuserid" && trlist[i].checked == true) {
                                    checkedCount++;
                                }
                            }
                            if (checkedCount < 1) {
                                alert("Please choose user");
                                return false;
                            }
                            document.getElementById('<%=HFbody.ClientID%>').value = $("#editor1").html();
                        }
                        function check2(obj) {
                            var objck = document.getElementById("<%=CBnotshowpoint.ClientID %>");
                            var tr1 = document.getElementById("tr1");
                            var tr2 = document.getElementById("tr2");
                            if (objck.checked) {
                                tr1.style.display = "none";
                                tr2.style.display = "none";
                            }
                            else {
                                tr1.style.display = "";
                                tr2.style.display = "";
                            }
                        }
                    </script>
                </asp:Panel>
                <asp:Panel ID="Panel2" runat="server">
                    <asp:Panel ID="UsPanel" runat="server">
                        <table style="background-color:#D9D9D9; ">
                            <tr>
                                <td style="height:60px; width:90px" align="center"><strong>Create New Action: </strong></td>
                                <td><strong>Sales name: </strong><asp:DropDownList ID="SalesNameList" runat="server"></asp:DropDownList></td>
                                <td><strong>Year : </strong><asp:DropDownList ID="CreateYear" runat="server"></asp:DropDownList></td>
                                <td><strong>Revenue Achievement: </strong><asp:TextBox ID="Reve" runat="server" MaxLength="50"></asp:TextBox>
                                </td>
                                <td><strong>Achievement Description: </strong><asp:TextBox ID="Desc" runat="server" MaxLength="500"></asp:TextBox>
                                </td>
                                <td><strong>Points: </strong><asp:TextBox ID="Points" runat="server" Width="40px"></asp:TextBox>
                                </td>
                                <td><strong>Marcom Comments: </strong><asp:TextBox ID="Comm" runat="server" MaxLength="500"></asp:TextBox>
                                </td>
                                <td><%--<input id="btn_create" type="button" value="Create" onclick="return Action_Create();" />--%>
                                    <asp:Button ID="btn_create" runat="server" Text="Create"  onclick="btn_create_Click" />
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                    <div><strong>Year select : </strong>
                        <asp:DropDownList ID="Rt2DatetimeList" runat="server"></asp:DropDownList>
                        <strong>Sales Name : </strong>
                        <asp:TextBox ID="Rt2SalesNameSearchBox" runat="server" 
                            placeholder="Please input sales name" Width="150px" AutoCompleteType="Disabled"></asp:TextBox>
                        <asp:Button ID="SearchPoint" runat="server" Text="Search" onclick="SearchPoint_Click" />
                    </div>
                    <table width="100%">
                        <thead>
                            <tr>
                                <th scope="col">
                                    #
                                </th>
                                <th scope="col" width="70">
                                    Date/Time
                                </th>
                                <th scope="col">
                                    Sales Name
                                </th>
                                <th scope="col">
                                    PD Group
                                </th>
                                 <th scope="col" class="<%=Othercss%>">
                                    Files
                                </th>
                                <th scope="col">
                                    Revenue Achievement
                                </th>
                                <th scope="col">
                                    Achievement Description
                                </th>
                                <th scope="col">
                                    Status
                                </th>
                                <th scope="col" width="126">
                                    Points Allocation <br />& Marcom Comments
                                </th>
                                <th scope="col" width="50">
                                    Delete
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="Rt2" runat="server" OnItemDataBound="Rt2_ItemDataBound">
                                <ItemTemplate>
                                    <tr class="odd<%# (Container.ItemIndex) mod 2 %>" id="Action<%# Eval("id")%>">
                                        <td>
                                            <%# (Container.ItemIndex + 1)%>
                                        </td>
                                        <td id="dateTime<%# Eval("id")%>">
                                            <%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>
                                            <asp:Label ID="hideCreateTime" runat="server" Text='<%# CDate(Eval("CreateTime")).ToString("yyyy")%>' Visible="false"></asp:Label>
                                        </td>
                                        <td>
                                            <%# Eval("CreateBy")%>
                                        </td>
                                        <td>
                                            <asp:Literal runat="server" ID="LitPD" />
                                        </td>
                                        <td class="<%=Othercss%>">
                                            <a href="Files.aspx?id=<%# Eval("FileID")%>">
                                                <%# Eval("File_NameX")%></a><br /><font color="gray"><%# Eval("File_SizeX")%></font>
                                        </td>
                                        <td>
                                            <%# Eval("RevenueAchievement")%>
                                        </td>
                                        <td>
                                            <%# Eval("Description")%>
                                        </td>
                                        <td>
                                            <%# Eval("StatusX")%>
                                        </td>
                                        <td align="center" style="padding-left: 5px; text-align: left;">
                                        <asp:Label ID="myPoints" runat="server" Text='<%# String.Format("Total Points ： {0}", Eval("points"))%>'></asp:Label>
                                        <div id="pamc" runat="server">
                                        <%--<div class="div_appove" style="position: relative; cursor: pointer;text-align: center;" onmouseover="showDiv('<%# Eval("id")%>');"  onmouseout="document.getElementById('divrs<%# Eval("id")%>').style.display='none';">--%>
                                         <div style="position: relative; cursor: pointer;text-align: center;" onmouseover="document.getElementById('divrs<%# Eval("id")%>').style.display='';"  onmouseout="document.getElementById('divrs<%# Eval("id")%>').style.display='none';">
                                    Total Points：<%# Eval("points")%><img alt="?" src="../../Images/EditDocument.png" width="30" height="30">
                                    <div  id="divrs<%# Eval("id")%>" style="padding: 2px 2px 5px 2px; border: 2px solid #FF9933; position: absolute; width: 200px; display: none; z-index: 999; background-color: #FFFFFF; ">
                                        <table border="0" width="100%" style="border-width: 0px; border-color: White;">
                                                <tr runat="server" id="trRule1">
                                                    <td align="left">
                                                        Rule 1:&nbsp;<asp:TextBox runat="server" ID="TBRule1" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint1" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender1" TargetControlID="TBRule1" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender10"
                                                            TargetControlID="TBPoint1" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule2">
                                                    <td align="left">
                                                        Rule 2:&nbsp;<asp:TextBox runat="server" ID="TBRule2" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint2" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender2" TargetControlID="TBRule2" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender11"
                                                            TargetControlID="TBPoint2" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule3">
                                                    <td align="left">
                                                        Rule 3:&nbsp;<asp:TextBox runat="server" ID="TBRule3" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint3" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender3" TargetControlID="TBRule3" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender12"
                                                            TargetControlID="TBPoint3" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule4" visible="false">
                                                    <td align="left">
                                                        Rule 4:&nbsp;<asp:TextBox runat="server" ID="TBRule4" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint4" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender4" TargetControlID="TBRule4" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender13"
                                                            TargetControlID="TBPoint4" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule5" visible="false">
                                                    <td align="left">
                                                        Rule 5:&nbsp;<asp:TextBox runat="server" ID="TBRule5" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint5" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender5" TargetControlID="TBRule5" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender14"
                                                            TargetControlID="TBPoint5" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule6" visible="false">
                                                    <td align="left">
                                                        Rule 6:&nbsp;<asp:TextBox runat="server" ID="TBRule6" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint6" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender6" TargetControlID="TBRule6" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender15"
                                                            TargetControlID="TBPoint6" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule7" visible="false">
                                                    <td align="left">
                                                        Rule 7:&nbsp;<asp:TextBox runat="server" ID="TBRule7" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint7" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender7" TargetControlID="TBRule7" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender16"
                                                            TargetControlID="TBPoint7" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule8" visible="false">
                                                    <td align="left">
                                                        Rule 8:&nbsp;<asp:TextBox runat="server" ID="TBRule8" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint8" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender8" TargetControlID="TBRule8" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender17"
                                                            TargetControlID="TBPoint8" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr runat="server" id="trRule9" visible="false">
                                                    <td align="left">
                                                        Rule 9:&nbsp;<asp:TextBox runat="server" ID="TBRule9" Width="50" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBPoint9" Width="40" /><ajaxToolkit:FilteredTextBoxExtender runat="server"
                                                                ID="FilteredTextBoxExtender9" TargetControlID="TBRule9" FilterMode="ValidChars"
                                                                FilterType="Custom,Numbers" ValidChars="." />
                                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender18"
                                                            TargetControlID="TBPoint9" FilterMode="ValidChars" FilterType="Custom,Numbers"
                                                            ValidChars="." />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td align="left">
                                                        Total:&nbsp;<asp:TextBox runat="server" ID="TBTotal" Width="50" ReadOnly="true" Enabled="false" />&nbsp;K&nbsp;&nbsp;&nbsp;Point:&nbsp;<asp:TextBox
                                                            runat="server" ID="TBTPoint" Width="40" Text='<%#Eval("Points") %>' ReadOnly="true"
                                                            Enabled="false" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td valign="top" style="padding-top: 5px;">
                                                        Comment: &nbsp;
                                                        <asp:TextBox ID="TBMarcomComments" runat="server" Width="150" Height="40" Text='<%# Eval("MarcomComments")%>'
                                                            TextMode="MultiLine"></asp:TextBox>
                                                        <asp:Button ID="BtSubmit2" runat="server" Text="Submit" CommandArgument=' <%# Eval("ID")%>'
                                                            OnClick="BtSubmit2_Click" />
                                                    </td>
                                                </tr>
                                            </table>
                                    </div>
                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div id="btdiv" runat="server">
                                            <input id="btdelete" type="button" value="Delete" onclick="return delAction('<%# Eval("id")%>');" />
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Repeater ID="Rt2Pager" runat="server">
                                <ItemTemplate>
                                        <asp:LinkButton ID="Rt2lnkPage" runat="server" Text='<%#Eval("Text") %>' CommandArgument='<%# Eval("Value") %>'
                                            CssClass='<%# If(Convert.ToBoolean(Eval("Enabled")), "page_enabled", "page_disabled")%>'
                                            OnClick="Rt2Page_Changed" OnClientClick='<%# If(Not Convert.ToBoolean(Eval("Enabled")), "return false;", "") %>'></asp:LinkButton>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <script language="javascript">
                        //                        function IsShow(id) {
                        //                            var value1 = document.getElementById("dateTime" + id).innerHTML;
                        //                            var sYear = parseInt(value1.substr(0, 4));
                        //                            var date = new Date();
                        //                            var tYear = date.getFullYear();
                        //                            if (tYear > sYear) {
                        //                                document.getElementById('divrs' + id).style.display = 'none';
                        //                            }
                        //                            else
                        //                                document.getElementById('divrs' + id).style.display = '';
                        //                        }
                        function delAction(id) {
                            var msg = "Do you really want to delete it?";
                            if (confirm(msg) == true) {
                                //  return true;
                            } else {
                                return false;
                            }
                            var postData = JSON.stringify({ id: id });
                            $.ajax(
                                        {
                                            type: "POST", url: "<%= Util.GetRuntimeSiteUrl()%>/My/ChampionClub/MarcomPlatform.aspx/DelAction", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                                            beforeSend: function (XMLHttpRequest) { },
                                            success: function (retData) {
                                                if ($.trim(retData.d) != "") {
                                                    var jsonObj = $.parseJSON(retData.d);
                                                    if (jsonObj.error == 1) {

                                                        $("#Action" + id).hide("slow");

                                                    }
                                                    alert(jsonObj.desc);
                                                }
                                            },
                                            error: function (retData) {
                                                if ($.trim(retData.d) != "") {
                                                    alert(retData.d);
                                                }
                                            }
                                        });
                        }
                    </script>
                </asp:Panel>
                <asp:Panel ID="Panel3" runat="server">
                     <div><strong>Year select : </strong>
                        <asp:DropDownList ID="Rt3DatetimeList" runat="server"></asp:DropDownList>
                        <strong>Sales Name : </strong>
                        <asp:TextBox ID="Rt3SalesNameSearchBox" runat="server" 
                            placeholder="Please input sales name" Width="150px" 
                             AutoCompleteType="Disabled"></asp:TextBox>
                        <asp:Button ID="SearchExchange" runat="server" Text="Search" 
                             onclick="SearchExchange_Click"/>
                    </div>
                    <table width="100%">
                        <thead>
                            <tr>
                                <th scope="col">
                                    #
                                </th>
                                <th scope="col">
                                    Date
                                </th>
                                <th scope="col">
                                    Sales Name
                                </th>
                                <th scope="col">
                                    Company
                                </th>
                                <th scope="col">
                                    ERPID
                                </th>
                                <th scope="col">
                                    Prize Name
                                </th>
                                <th scope="col">
                                    Point
                                </th>
                                <th scope="col">
                                    Status
                                </th>
                                <th scope="col">
                                    Action
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="Rt3" runat="server" OnItemDataBound="Rt3_ItemDataBound">
                                <ItemTemplate>
                                    <tr class="odd<%# (Container.ItemIndex) mod 2 %>">
                                        <td>
                                            <%# (Container.ItemIndex + 1)%>
                                        </td>
                                        <td>
                                            <%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>
                                             <asp:Label ID="hideCreateTime" runat="server" Text='<%# CDate(Eval("CreateTime")).ToString("yyyy")%>' Visible="false"></asp:Label>
                                        </td>
                                        <td>
                                            <%# Eval("CreateBy")%>
                                        </td>
                                        <td>
                                            <%# Eval("CompanyX")%>
                                        </td>
                                        <td>
                                            <%# Eval("ErpIDX")%>
                                        </td>
                                        <td>
                                            <%# Eval("Prize_NameX")%>
                                        </td>
                                        <td>
                                            <%# Eval("Prize_PointX")%>
                                        </td>
                                        <td>
                                            <%# Eval("StatusX")%>
                                        </td>
                                        <td width="182" align="left" style="padding-left: 5px; text-align: left;">
                                            <asp:DropDownList ID="DDlSTATUS" runat="server" Width="130">
                                            </asp:DropDownList>
                                            <asp:TextBox ID="TBMarcomContent" runat="server" Width="128" Height="25" Text='<%# Eval("MarcomContent")%>'
                                                TextMode="MultiLine"></asp:TextBox>
                                            <asp:Button ID="BtSubmit" runat="server" Text="Submit" CommandArgument=' <%# Eval("ReddemID")%>'
                                                OnClick="BtSubmit_Click" />
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Repeater ID="Rt3Pager" runat="server">
                                <ItemTemplate>
                                        <asp:LinkButton ID="Rt3lnkPage" runat="server" Text='<%#Eval("Text") %>' CommandArgument='<%# Eval("Value") %>'
                                            CssClass='<%# If(Convert.ToBoolean(Eval("Enabled")), "page_enabled", "page_disabled")%>'
                                            OnClick="Rt3Page_Changed" OnClientClick='<%# If(Not Convert.ToBoolean(Eval("Enabled")), "return false;", "") %>'></asp:LinkButton>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </asp:Panel>
                <asp:Panel ID="Panel4" runat="server">
                    <table style="width:100%;">
                        <tr>
                            <td width="50%">
                                <strong>Year:</strong>
                                <asp:DropDownList ID="Rt4DatetimeList" runat="server"></asp:DropDownList>
                                <strong>Sales Email : </strong>
                                <input id="txtSalesName" type="text" style="width: 120px" />
                                    <input id="btnQry" type="button" value="Search" onclick="return Query();" />
                            </td>
                            <td>
                                <strong>Sales Email : </strong>
                                <asp:DropDownList ID="ddl_sales" runat="server" Width="150px">
                                </asp:DropDownList>
                                 <input id="btnAdd" type="button" value="Add" onclick="return AddSalesForDDL();" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <table id="grid1"></table></td>
                            <td>
                                <table id="grid2"></table></td>
                        </tr>
                    </table>

                </asp:Panel>
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
    <link href="championclub.css" rel="stylesheet" type="text/css" />
    <link href="base.css" rel="stylesheet" type="text/css" />
    <link href="../../EC/redactor/redactor.css" rel="stylesheet" type="text/css" />
                                  	
		<script type="text/javascript">
		    $(function () {
		        $('#editor1').redactor({
		            // imageGetJson: './json/ImgUpload.ashx',
		            imageUpload: './json/FileUpload.ashx?type=0',
		            fileUpload: './json/FileUpload.ashx?type=1'
		        });
		    });
   </script>
    <style type="text/css">
        tbody tr.odd0 td
        {
            border-top: #ccc 1px solid;
            text-align: center;
            background: #fff;
            color: #333;
            height: 40px;
            border-right: #ccc 1px solid;
        }
        tbody tr.odd1 td
        {
            text-align: center;
            background: #ebebeb;
            color: #333;
            height: 40px;
            border-top: #ccc 1px solid;
            border-right: #ccc 1px solid;
        }
    </style>
</asp:Content>
