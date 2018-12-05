<%@ Page Title="Champion Club - Personal info" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
            If Session("org_id").ToString.StartsWith("CN") Then
                If Request("PD") Is Nothing OrElse Request("PD") = "" Then Response.Redirect("ProgramCriteria.aspx")
                For Each i As ListItem In RBstype.Items
                    If i.Value = 1 Then
                        i.Text = "寄送到公司地址"
                    End If
                    If i.Value = 0 Then
                        i.Text = "寄送到个人地址"
                    End If
                Next
                LitLN.Text = "姓" : LitFN.Text = "名" : Litaddr1.Text = "地址" : Litaddr2.Text = "地址" : LitID.Text = "登入帐号"
                LitCountry.Text = "国家" : LitCity.Text = "县/市" : LitState.Text = "省份" : LitZipCode.Text = "邮编"
                LitTelephone.Text = "电话" : btsubmit.Text = "提交" : btcancel.Text = "重填"
                Lithead.Text = "个人信息 (请仔细填写以便奖品能顺利送达) " : LitJob.Text = "职称" : LitCompany.Text = "公司名称"
            End If
            Dim dtCountry As DataTable = dbUtil.dbGetDataTable("MY", "select distinct COUNTRY, isnull(country_name,'') as  country_name  from SAP_DIMCOMPANY WHERE  country_name IS NOT NULL  order by country_name")
            dlCountry.DataSource = dtCountry
            dlCountry.DataBind()
            TBUserID.Text = User.Identity.Name
            Dim P As ChampionClub_PersonalInfo = (From MyP In MyDC.ChampionClub_PersonalInfos
                     Where MyP.UserID = Session("user_id").ToString).FirstOrDefault()
            If P IsNot Nothing Then
                BindPersonalInfo(P)
                RBstype.ClearSelection()
                RBstype.SelectedValue = Convert.ToInt32(P.Stype).ToString()
                Panel1.Visible = True
                btsubmit.Text = "Update"
                If Session("org_id").ToString.StartsWith("CN") Then
                    btsubmit.Text = "更新"
                End If
            Else
                Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select isnull(FirstName,'') as FirstName,isnull(LastName,'') as LastName,isnull(WorkPhone,'') as WorkPhone, ERPID, isnull(JOB_TITLE,'') as JOB_TITLE, isnull(ACCOUNT,'') as ACCOUNT  from SIEBEL_CONTACT WHERE EMAIL_ADDRESS ='{0}'", Session("user_id")))
                If dt.Rows.Count > 0 Then
                    TBlastname.Text = dt.Rows(0).Item("LastName")
                    TBfirstname.Text = dt.Rows(0).Item("FirstName")
                    TBtel.Text = dt.Rows(0).Item("WorkPhone")
                    TBJobTitle.Text = dt.Rows(0).Item("JOB_TITLE")
                    TBCompanyName.Text = dt.Rows(0).Item("ACCOUNT")
                End If
                BindAccount()
            End If
        End If
    End Sub
    Sub BindPersonalInfo(ByVal P As ChampionClub_PersonalInfo)
        TBlastname.Text = P.LastName
        TBfirstname.Text = P.FirstName
        TBAddress1.Text = P.Address1
        TBAddress2.Text = P.Address2
        dlCountry.SelectedValue = P.Country
        TBCity.Text = P.City
        TBState.Text = P.State
        TBzip.Text = P.ZipCode
        TBtel.Text = P.Telephone
        TBJobTitle.Text = P.JobTitle
        TBCompanyName.Text = P.CompanyName
    End Sub
    Sub BindAccount()
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select isnull(City,'') as City,isnull(State,'') as State,isnull(ZIPCODE,'') as ZIPCODE, isnull(ADDRESS,'') as ADDRESS, isnull(ADDRESS2,'') as ADDRESS2  from SIEBEL_ACCOUNT WHERE ERP_ID ='{0}'", Session("company_id")))
        If dt.Rows.Count > 0 Then
            TBAddress1.Text = dt.Rows(0).Item("ADDRESS")
            TBAddress2.Text = dt.Rows(0).Item("ADDRESS2")
            TBCity.Text = dt.Rows(0).Item("CITY")
            TBState.Text = dt.Rows(0).Item("STATE")
            TBzip.Text = dt.Rows(0).Item("ZIPCODE")
        End If
    End Sub
    Dim MyDC As New MyChampionClubDataContext
    Protected Sub btsubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim SendMail As Boolean = False
        Dim P As ChampionClub_PersonalInfo = (From MyP In MyDC.ChampionClub_PersonalInfos
                      Where MyP.UserID = Session("user_id").ToString).FirstOrDefault()
        If P IsNot Nothing Then
            P.LAST_UPD_BY = Session("user_id")
            P.LAST_UPD_DATE = Now
        Else
            P = New ChampionClub_PersonalInfo
            P.UserID = Session("user_id")
            P.CREATED_BY = Session("user_id")
            P.CREATED_Date = Now
            MyDC.ChampionClub_PersonalInfos.InsertOnSubmit(P)
            SendMail = True
        End If
        P.Stype = RBstype.SelectedValue
        P.ErpID = Session("company_id")
        P.ORG = Session("RBU")
        P.LastName = TBlastname.Text.Replace("'", "''")
        P.FirstName = TBfirstname.Text.Replace("'", "''")
        P.Address1 = TBAddress1.Text.Replace("'", "''")
        P.Address2 = TBAddress2.Text.Replace("'", "''")
        P.Country = dlCountry.SelectedValue.Replace("'", "''")
        P.City = TBCity.Text.Replace("'", "''")
        P.State = TBState.Text.Replace("'", "''")
        P.ZipCode = TBzip.Text.Replace("'", "''")
        P.Telephone = TBtel.Text.Replace("'", "''")
        P.JobTitle = TBJobTitle.Text.Replace("'", "''").Trim
        P.CompanyName = TBCompanyName.Text.Replace("'", "''").Trim
        If Session("org_id").ToString.StartsWith("CN") Then
            If Request("PD") = "IAG" Then P.PD_Group = "IAG"
            If Request("PD") = "ESG" Then P.PD_Group = "ESG"
        End If
        MyDC.SubmitChanges()
        
        'JJ 2014/6/16：註冊的地方要順便新增進Admin裡面，才不用User註冊後Marcom還要到後台再新增一次
        'JJ 2014/6/16：先判斷是否有該筆資料了
        Dim sql As String = String.Format("select UserID,ORG from ChampionClub_Admin where UserID ='{0}' and year={1} ", Session("user_id"), CStr(Now.Year))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        'JJ 2014/6/16：如果Admin沒有該筆資料
        If dt.Rows.Count = 0 Then
            Dim sql2 As String = String.Format("Insert into ChampionClub_Admin(userID,userName,year,ORG,CREATED_BY,CREATED_DATE)values('{0}','{1}',{2},'{3}','{4}',getdate())", CStr(Session("user_id")), CStr(TBlastname.Text.Replace("'", "''") + " " + TBfirstname.Text.Replace("'", "''")), CStr(Now.Year), CStr(Session("RBU")), HttpContext.Current.User.Identity.Name)
            Dim intAdd As Integer = dbUtil.dbExecuteNoQuery("MY", sql2)
        End If
        
        
        ' add free 5 points
        If Now <= CDate("2013-04-20") Then
            Dim MyActive As New ChampionClub_Action
            MyActive.Description = "Free For Point : 5"
            MyActive.RevenueAchievement = "0 k"
            MyActive.Points = 5
            MyActive.Status = 1
            MyActive.MarcomComments = "Free For Point : 5,join before 20/04/2013"
            If Session("org_id").ToString.StartsWith("CN") Then
                MyActive.Description = "免费赠送5分"
                MyActive.MarcomComments = "2013年4月20号之前加入活动，免费赠送5分."
            End If
            MyActive.CreateBy = Session("user_id")
            MyActive.CreateTime = Now
            MyDC.ChampionClub_Actions.InsertOnSubmit(MyActive)
            MyDC.SubmitChanges()
        End If
        ' end
        If SendMail Then MyChampionClubUtil.SendEmail(Session("user_id").ToString, 1, "", "")
        Util.AjaxJSAlertRedirect(up1, " Succeed. ", "PointManagement.aspx")
    End Sub

    Protected Sub btcancel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        TBlastname.Text = ""
        TBfirstname.Text = ""
        TBAddress1.Text = ""
        TBAddress2.Text = ""
        TBCity.Text = ""
        TBState.Text = ""
        TBzip.Text = ""
        TBtel.Text = ""
    End Sub

    Protected Sub RBstype_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Panel1.Visible = True
        Dim P As ChampionClub_PersonalInfo = (From MyP In MyDC.ChampionClub_PersonalInfos
                     Where MyP.UserID = Session("user_id").ToString).FirstOrDefault()
        If P IsNot Nothing Then
            Select Case Convert.ToInt32(P.Stype).ToString()
                Case "1"
                    If RBstype.SelectedValue = "0" Then
                        TBAddress1.Text = ""
                        TBAddress2.Text = ""
                        TBCity.Text = ""
                        TBState.Text = ""
                        TBzip.Text = ""
                        TBtel.Text = ""
                    Else
                        BindPersonalInfo(P)
                    End If
                Case "0"
                    If RBstype.SelectedValue = "1" Then
                        BindAccount()
                    Else
                        BindPersonalInfo(P)
                    End If
            End Select
        Else
            If RBstype.SelectedValue = "0" Then
                TBAddress1.Text = ""
                TBAddress2.Text = ""
                TBCity.Text = ""
                TBState.Text = ""
                TBzip.Text = ""
                TBtel.Text = ""
            Else
                BindAccount()
            End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link href="championclub.css" rel="stylesheet" type="text/css" />
    <link href="base.css" rel="stylesheet" type="text/css" />
    <div id="cpclub-content-wrapper">
        <uc1:FunctionBlock runat="server" ID="ucFunctionBlock" />
        <!-- end .cpclub-content-sidebar -->
        <div class="cpclub-content-main">
            <div class="intro-heading">
                <span class="intro-title">
                    <asp:Literal ID="Lithead" runat="server">Personal Address (for prize shipping) </asp:Literal></span>
            </div>
            <!-- end .main-intro -->
            <div class="prize-select">
                <ol>
                    <li>
                        <table cellpadding="0" cellspacing="0" border="0" width="534" class="prize_table">
                            <tr>
                                <td width="81" class="table_title01">
                                   <asp:Literal ID="LitID" runat="server" Text="User ID"/> :
                                </td>
                                <td>
                                    <asp:TextBox ID="TBUserID" runat="server" ReadOnly="true" Enabled="false" Width="250"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td width="81" class="table_title01">
                                   <asp:Literal ID="LitLN" runat="server" Text="Last Name"/> :
                                </td>
                                <td>
                                    <asp:TextBox ID="TBlastname" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td width="81" class="table_title01">
                                        <asp:Literal ID="LitFN" runat="server" Text="First Name"/> :
                                </td>
                                <td>
                                     <asp:TextBox ID="TBfirstname" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td width="81" class="table_title01">
                                        <asp:Literal ID="LitJob" runat="server" Text="Job Title"/> :
                                </td>
                                <td>
                                     <asp:TextBox ID="TBJobTitle" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr style="display:none;">
                                <td width="81" class="table_title01">
                                        <asp:Literal ID="LitCompany" runat="server" Text="Company"/> :
                                </td>
                                <td>
                                     <asp:TextBox ID="TBCompanyName" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr><td height="5" colspan="2"></td></tr>
                        </table>
                    </li>
                    <li>
                        <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                            <ContentTemplate>
                                <table>
                                    <tr>
                                        <td class="select-type" colspan="2">
                                               <asp:RadioButtonList ID="RBstype" runat="server" AutoPostBack="true" OnSelectedIndexChanged="RBstype_SelectedIndexChanged">
                                            <asp:ListItem Value="1"> Send to your company.</asp:ListItem>
                                              <asp:ListItem Value="0" > Send to other address,please fill in bellow.</asp:ListItem>
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                    <tr><td height="5" colspan="2"></td></tr>
                                </table>
                                <asp:Panel runat="server" ID="Panel1" Visible="false">
                                    <table cellpadding="0" cellspacing="0" border="0" width="534" class="prize_table">
                                        <tr>
                                            <td width="81" class="table_title01">
                                                <asp:Literal ID="Litaddr1" runat="server" Text="Address"/>1 :
                                            </td>
                                            <td>
                                         <asp:TextBox ID="TBAddress1" runat="server" Width="400"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="81" class="table_title01">
                                                <asp:Literal ID="Litaddr2" runat="server" Text="Address"/>2 :
                                            </td>
                                            <td>
                                                    <asp:TextBox ID="TBAddress2" runat="server" Width="400"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="81" class="table_title01">
                                                <asp:Literal ID="LitCountry" runat="server" Text='Country'/> :
                                            </td>
                                            <td>
                                              <asp:DropDownList ID="dlCountry" runat="server"  DataTextField="country_name" DataValueField="COUNTRY">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="81" class="table_title01">
                                                <asp:Literal ID="LitCity" runat="server" Text='City'/> :
                                            </td>
                                            <td>
                                                <asp:TextBox ID="TBCity" runat="server"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="81" class="table_title01">
                                                <asp:Literal ID="LitState" runat="server" Text='State'/> :
                                            </td>
                                            <td>
                                            <asp:TextBox ID="TBState" runat="server"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="81" class="table_title01">
                                                <asp:Literal ID="LitZipCode" runat="server" Text='Zip Code'/> :
                                            </td>
                                            <td>
                                              <asp:TextBox ID="TBzip" runat="server"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="81" class="table_title01">
                                                <asp:Literal ID="LitTelephone" runat="server" Text='Telephone'/> :
                                            </td>
                                            <td>
                                               <asp:TextBox ID="TBtel" runat="server"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2" align="right">
                                                <asp:Button ID="btcancel" runat="server" Text="Cancel" CssClass="sure" OnClick="btcancel_Click" />
                                                <asp:Button ID="btsubmit" runat="server" Text="Submit" CssClass="sure" OnClick="btsubmit_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="RBstype" EventName="SelectedIndexChanged" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </li>
                </ol>
            </div>
        </div>
        <!-- end #of-faq -->
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
