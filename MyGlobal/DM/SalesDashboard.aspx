<%@ Page Title="MyAdvantech - My Sales Dashboard" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %> 

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If MailUtil.IsInRole("IT.ebusiness") Then Response.End()
            If Util.IsInternalUser(Session("user_id")) = False Then Response.Redirect("../home.aspx")
            Me.Master.EnableAsyncPostBackHolder = False
            Me.Master.LogoImgPath = "~/Images/dm_logo.JPG"
            Dim uid As String = ""
            If HttpContext.Current.Session Is Nothing _
            OrElse HttpContext.Current.Session("user_id") = "" _
            OrElse HttpContext.Current.Session("user_id").ToString.ToLower() Like "*@advantech*.*" = False _
            OrElse HttpContext.Current.Session("user_id") Like "*@*.*" = False Then
                Exit Sub
            End If
            uid = HttpContext.Current.Session("user_id")
            'If Util.IsAdmin() Then uid = "christoph.kuehn@advantech.eu"
            If (Util.IsAdmin() Or Util.IsEUPSM()) AndAlso Request("uid") IsNot Nothing Then
                uid = Trim(Request("uid")).Replace("'", "''")
            End If
            hd_myemail.Value = uid
            If hd_myemail.Value IsNot Nothing AndAlso hd_myemail.Value.Contains("@") Then
                Me.hd_salesode.Value = Util.GetSalesID(hd_myemail.Value)
                Me.hd_postnid.Value = GetPositionId(hd_myemail.Value)
            End If
            If uid <> "" Then
                GetMySiebelProfile()
                AccSrc.SelectCommand = GetAccountSql()
                dlPChartCurr_SelectedIndexChanged(Nothing, Nothing)
            Else
                OptyTimer.Enabled = False : PerfTimer.Enabled = False
                imgOptyLoading.Visible = False : imgPerfLoad.Visible = False
            End If
            
            For i As Integer = Now.AddYears(-2).Year To Now.AddYears(1).Year
                dlPChartYear.Items.Add(New ListItem(i, i))
                If i = Now.Year Then dlPChartYear.Items(dlPChartYear.Items.Count - 1).Selected = True
            Next
            
        End If
    End Sub
    
    Function GetPositionId(ByVal email As String) As String
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        " select top 1 position_id from SIEBEL_SALES_HIERARCHY where EMAIL='{0}' and POSITION_ID is not null and POSITION_ID<>''", email))
        If dt.Rows.Count = 1 Then
            Return dt.Rows(0).Item("position_id")
        Else
            dt = dbUtil.dbGetDataTable("MY", String.Format( _
                " select top 1 row_id as position_id from SIEBEL_POSITION where EMAIL_ADDR='{0}' and EMAIL_ADDR<>'' and row_id<>''", email))
            If dt.Rows.Count = 1 Then
                Return dt.Rows(0).Item("position_id")
            End If
        End If
        Return ""
    End Function
    
    Function GetOptySql() As String
        Dim uid As String = LCase(hd_myemail.Value)
        Dim cfrom As Date = DateAdd(DateInterval.Month, -3, Now)
        Dim cto As Date = Now
        If txtOptyCDateFrom.Text.Trim() <> "" AndAlso Date.TryParse(txtOptyCDateFrom.Text, Now) Then cfrom = CDate(txtOptyCDateFrom.Text)
        If txtOptyCDateTo.Text.Trim() <> "" AndAlso Date.TryParse(txtOptyCDateTo.Text, Now) Then cto = CDate(txtOptyCDateTo.Text)
        If uid.Contains("@") Then uid = Split(uid, "@")(0).Trim()
        'If Util.IsAdmin() Then uid = "axel.kaiser"
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 500 "))
            .AppendLine(String.Format(" A.ROW_ID, A.CREATED, A.LAST_UPD, A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, A.NAME, "))
            .AppendLine(String.Format(" A.CURCY_CD as currency, A.CURR_STG_ID, cast(A.SUM_WIN_PROB as int) as SUM_WIN_PROB, "))
            .AppendLine(String.Format(" cast(A.SUM_REVN_AMT as numeric(18,0)) as SUM_REVN_AMT, IsNull(X.ATTRIB_06,'') as BusinessGroup, "))
            .AppendLine(String.Format(" case when isnull(A.SUM_WIN_PROB,0)= 0 then A.SUM_REVN_AMT*(A.SUM_WIN_PROB/100) else 0 end as EXPECT_VAL, "))
            .AppendLine(String.Format(" IsNull((select top 1 B.NAME from S_STG B where B.ROW_ID=A.CURR_STG_ID),'') as STAGE_NAME, "))
            .AppendLine(String.Format(" A.PR_DEPT_OU_ID, A.STATUS_CD, z1.NAME as ACCOUNT_NAME, z1.ROW_ID as ACCOUNT_ROW_ID, "))
            .AppendLine(String.Format(" IsNull((select SM.NAME from S_SALES_METHOD SM where SM.ROW_ID=A.SALES_METHOD_ID),'') as SALES_METHOD_NAME, "))
            .AppendLine(String.Format(" IsNull(A.CHANNEL_TYPE_CD,'') as Channel, IsNull(A.DESC_TEXT,'') as DESC_TEXT, IsNull(A.REASON_WON_LOST_CD,'') as REASON_WON_LOST_CD, z4.EMAIL_ADDR "))
            .AppendLine(String.Format(" from S_OPTY A left outer join S_OPTY_X X on A.ROW_ID=X.ROW_ID "))
            .AppendLine(String.Format(" inner join S_ORG_EXT z1 on A.PR_DEPT_OU_ID=z1.ROW_ID  "))
            .AppendLine(String.Format(" inner join S_ACCNT_POSTN z2 on z1.ROW_ID=z2.OU_EXT_ID  "))
            .AppendLine(String.Format(" inner join S_POSTN z3 on z2.POSITION_ID=z3.ROW_ID  "))
            .AppendLine(String.Format(" inner join S_CONTACT z4 on z3.PR_EMP_ID=z4.ROW_ID "))
            .AppendLine(String.Format(" where (lower(z4.EMAIL_ADDR) like '{0}@%advantech%.%' {1} ) ", uid, _
                                      IIf(Me.hd_postnid.Value <> "", " or A.PR_POSTN_ID='" + hd_postnid.Value + "' ", " ")))
            '.AppendLine(String.Format(" and A.SUM_WIN_PROB between 1 and 99 and A.STATUS_CD not in ('Invalid') "))
            .AppendLine(String.Format(" and A.CREATED between '{0}' and '{1}' ", cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            If txtOptyName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (Upper(A.NAME) like N'%{0}%' or Upper(A.DESC_TEXT) like N'%{0}%') ", txtOptyName.Text.Trim().ToUpper().Replace("'", "''").Replace("*", "%")))
            End If
            If txtOptyAccountName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and Upper(z1.NAME) like N'%{0}%' ", txtOptyAccountName.Text.Trim().ToUpper().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by A.CREATED desc, A.ROW_ID "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub OptyTimer_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            OptyTimer.Interval = 99999 : optySrc.SelectCommand = GetOptySql() : OptyTimer.Enabled = False : imgOptyLoading.Visible = False
            gvOpty.EmptyDataText = "There is no Opportunity under your SIEBEL account"
        Catch ex As Exception
            OptyTimer.Enabled = False
        End Try
    End Sub
    
    Protected Sub gvOpty_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        optySrc.SelectCommand = GetOptySql()
    End Sub

    Protected Sub gvOpty_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        optySrc.SelectCommand = GetOptySql()
    End Sub
    
    Sub GetMySiebelProfile()
        If hd_myemail.Value.Contains("@") Then
            Dim myname As String = Split(hd_myemail.Value, "@")(0).Trim()
            Dim profDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
            " select top 1 IsNull(FirstName,'') as FirstName, IsNull(LastName,'') as LastName, IsNull(OrgID,'') as RBU, " + _
            " JOB_FUNCTION, IsNull(JOB_TITLE,'') as JOB_TITLE, EMAIL_ADDRESS, IsNull(ACCOUNT,'') as ACCOUNT " + _
            " from SIEBEL_CONTACT where EMAIL_ADDRESS like '{0}%.%' and EMPLOYEE_FLAG='Y'", myname.Replace("'", "''")))
            If profDt.Rows.Count = 1 Then
                lbMyName.Text = profDt.Rows(0).Item("FirstName") + " " + profDt.Rows(0).Item("LastName")
                lbMyEmail.Text = profDt.Rows(0).Item("EMAIL_ADDRESS") : lbMyRBU.Text = profDt.Rows(0).Item("RBU")
                lbMyTitle.Text = profDt.Rows(0).Item("JOB_TITLE") : lbMyDep.Text = profDt.Rows(0).Item("ACCOUNT")
            Else
                lbMyName.Text = "Profile cannot be found in SIEBEL"
            End If
        End If
    End Sub
    
    Protected Sub btnQueryOpty_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.Master.EnableAsyncPostBackHolder = True
        gvOpty.PageIndex = 0
        imgOptyLoading.Visible = True : optySrc.SelectCommand = GetOptySql() : imgOptyLoading.Visible = False
    End Sub

    Protected Sub imgExcelOpty_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", GetOptySql())
        If dt.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(dt, "AEUIT_MyOpty.xls")
        End If
    End Sub
    
    Function GetPerfSql() As String
        If hd_salesode.Value = "" Then Return ""
        Dim cfrom As Date = DateAdd(DateInterval.Month, -12, Now)
        Dim cto As Date = DateAdd(DateInterval.Month, 6, Now)
        If txtPerfDueFrom.Text.Trim() <> "" AndAlso Date.TryParse(txtPerfDueFrom.Text, Now) Then cfrom = CDate(txtPerfDueFrom.Text)
        If txtPerfDueTo.Text.Trim() <> "" AndAlso Date.TryParse(txtPerfDueTo.Text, Now) Then cto = CDate(txtPerfDueTo.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 1000 a.item_no as part_no, a.Product_Line, a.Customer_ID, a.tr_curr as currency, b.COMPANY_NAME,  "))
            .AppendLine(String.Format(" a.efftive_date as due_date, a.Tran_Type, cast(a.Qty as int) as Qty, a.sector, a.order_no, a.order_date,  "))
            .AppendLine(String.Format(" a.Us_amt, a.{0} as LOCAL_AMT, a.egroup as product_group, a.edivision as product_division, a.PO  ", dlMyPerfCurr.SelectedValue))
            .AppendLine(String.Format(" from EAI_SALE_FACT a inner join SAP_DIMCOMPANY b on a.Customer_ID=b.COMPANY_ID and a.org=b.ORG_ID   "))
            .AppendLine(String.Format(" where Sales_ID='{0}' and fact_1234=1  ", hd_salesode.Value))
            .AppendLine(String.Format(" and FACTYEAR>=Year('{0}') and a.efftive_date between '{0}' and '{1}'  ", cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            If txtPerfPN.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.item_no like '%{0}%' ", txtPerfPN.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtPerfCustName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and b.COMPANY_NAME like N'%{0}%' ", txtPerfCustName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If rblPerfType.SelectedIndex > 0 Then
                .AppendLine(String.Format(" and a.tran_type='{0}' ", rblPerfType.SelectedValue))
            End If
            .AppendLine(String.Format(" order by a.efftive_date desc "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub btnQueryPerf_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.Master.EnableAsyncPostBackHolder = True
        gvPerf.PageIndex = 0
        PerfSrc.SelectCommand = GetPerfSql()
    End Sub

    Protected Sub PerfTimer_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            PerfTimer.Interval = 99999 : PerfSrc.SelectCommand = GetPerfSql() : PerfTimer.Enabled = False : imgPerfLoad.Visible = False
            gvPerf.EmptyDataText = "No Data"
            Me.Master.EnableAsyncPostBackHolder = True
        Catch ex As Exception
            PerfTimer.Enabled = False
        End Try
    End Sub

    Protected Sub gvPerf_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        PerfSrc.SelectCommand = GetPerfSql()
    End Sub

    Protected Sub gvPerf_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        PerfSrc.SelectCommand = GetPerfSql()
    End Sub

    Protected Sub imgPerfXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetPerfSql())
        If dt.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(dt, "AEUIT_CustOrderHistory.xls")
        End If
    End Sub

   Protected Sub dlPChartCurr_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        imgPerfTrend.ImageUrl = "~/Includes/MySales.ashx?Year=" + dlPChartYear.SelectedValue + "&Currency=" + dlPChartCurr.SelectedValue + "&uid=" + hd_myemail.Value
    End Sub

    Protected Sub dlPChartYear_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        imgPerfTrend.ImageUrl = "~/Includes/MySales.ashx?Year=" + dlPChartYear.SelectedValue + "&Currency=" + dlPChartCurr.SelectedValue + "&uid=" + hd_myemail.Value
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
        PerfTimer.Enabled = False : OptyTimer.Enabled = False
    End Sub

    Protected Sub PerfSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub optySrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub
    
    Function GetAccountSql() As String
        Dim uid As String = LCase(hd_myemail.Value)
        If uid.Contains("@") Then uid = Split(uid, "@")(0).Trim()
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT a.ROW_ID, a.ERP_ID, a.ACCOUNT_NAME, a.ACCOUNT_STATUS, a.FAX_NUM, a.PHONE_NUM, a.OU_TYPE_CD, a.URL, a.BusinessGroup, "))
            .AppendLine(String.Format(" a.ACCOUNT_TYPE, a.RBU, a.PRIMARY_SALES_EMAIL, a.PARENT_ROW_ID, a.MAJORACCOUNT_FLAG, a.COMPETITOR_FLAG, a.PARTNER_FLAG, "))
            .AppendLine(String.Format(" a.COUNTRY, a.CITY, a.ADDRESS, a.STATE, a.ZIPCODE, a.PROVINCE, a.BAA, a.CREATED, a.LAST_UPDATED, a.PriOwnerDivision, a.PriOwnerRowId, "))
            .AppendLine(String.Format(" a.PriOwnerPosition, a.LOCATION, a.ACCOUNT_TEAM, a.ADDRESS2, a.ACCOUNT_CC_GRADE, a.CURRENCY, b.FAX_NO, "))
            .AppendLine(String.Format(" b.TEL_NO, b.PRICE_CLASS, b.CREATEDDATE, b.SHIPCONDITION, b.SALESOFFICE, b.SALESGROUP, b.CONTACT_EMAIL, b.DELETION_FLAG, "))
            .AppendLine(String.Format(" b.SALESOFFICENAME, b.SAP_SALESNAME, b.SAP_SALESCODE, b.SAP_ISNAME, b.SAP_OPNAME, b.FACT2008, b.FACT2009, b.FACT2010, "))
            .AppendLine(String.Format(" b.LAST_BUY_DATE, b.ORDERS_IN_PAST_YEAR, b.AMOUNT_IN_PAST_YEAR, b.ORDERS_IN_PAST_HALFYEAR, b.CUST_IND, "))
            .AppendLine(String.Format(" ISNULL((select COUNT(z.ROW_ID) from SIEBEL_OPPORTUNITY z where z.ACCOUNT_ROW_ID=a.ROW_ID and z.SUM_WIN_PROB between 1 and 99),0) as Open_Opportunities "))
            .AppendLine(String.Format(" FROM SIEBEL_ACCOUNT AS a LEFT OUTER JOIN SAP_DIMCOMPANY AS b ON a.ERP_ID = b.COMPANY_ID "))
            .AppendLine(String.Format(" WHERE a.PRIMARY_SALES_EMAIL LIKE '{0}@%advantech%.%' ", uid))
            If txtAccName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.account_name like N'%{0}%' ", txtAccName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" ORDER BY a.ACCOUNT_NAME "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub btnQueryAccount_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        AccSrc.SelectCommand = GetAccountSql() : gvAccount.PageIndex = 0
    End Sub

    Protected Sub gvAccount_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        AccSrc.SelectCommand = GetAccountSql()
    End Sub

    Protected Sub gvAccount_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        AccSrc.SelectCommand = GetAccountSql()
    End Sub

    Protected Sub imgXlsAccounts_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetAccountSql())
        If dt.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(dt, "AEUIT_MyAccounts.xls")
        End If
    End Sub

    Protected Sub AccSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <asp:HiddenField runat="server" ID="hd_myemail" />
    <asp:HiddenField runat="server" ID="hd_salesode" />
    <asp:HiddenField runat="server" ID="hd_siebelid" />
    <asp:HiddenField runat="server" ID="hd_postnid" />
    <ajaxToolkit:TabContainer runat="server" ID="tabc1" Width="100%">
        <ajaxToolkit:TabPanel runat="server" ID="tab1" HeaderText="My Profile">
            <ContentTemplate>
                <table width="100%">
                    <tr valign="top">
                        <td style="width:25%">
                            <table width="100%" style="border-style:groove;">
                                <tr align="center">
                                    <th style="background-color:#E5ECF9"><asp:Label runat="server" ID="lbMyName" Font-Bold="true" Font-Size="Larger" /></th>
                                </tr>
                                <tr>
                                    <th align="left">Email</th>
                                </tr>
                                <tr>
                                    <td><asp:Label runat="server" ID="lbMyEmail" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Title</th>
                                </tr>
                                <tr>
                                    <td><asp:Label runat="server" ID="lbMyTitle" /></td>
                                </tr>
                                <tr>
                                    <th align="left">RBU</th>
                                </tr>
                                <tr>
                                    <td><asp:Label runat="server" ID="lbMyRBU" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Department</th>
                                </tr>
                                <tr>
                                    <td><asp:Label runat="server" ID="lbMyDep" /></td>
                                </tr>
                            </table>
                        </td>
                        <td style="width:75%">
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">Year:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" AutoPostBack="true" ID="dlPChartYear" 
                                                        OnSelectedIndexChanged="dlPChartYear_SelectedIndexChanged" />
                                                </td>
                                                <th align="left">Currency:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" AutoPostBack="true" ID="dlPChartCurr" 
                                                        OnSelectedIndexChanged="dlPChartCurr_SelectedIndexChanged">
                                                        <asp:ListItem Text="USD" Value="US_AMT" Selected="True" />
                                                        <asp:ListItem Value="EUR" />
                                                        <asp:ListItem Value="TWD" />
                                                        <asp:ListItem Value="RMB" />
                                                        <asp:ListItem Value="JPY" />
                                                        <asp:ListItem Value="SGD" />
                                                        <asp:ListItem Value="AUD" />
                                                        <asp:ListItem Value="MYR" />
                                                        <asp:ListItem Value="BRL" />
                                                        <asp:ListItem Value="KRW" />
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upPerfChart" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Image runat="server" ID="imgPerfTrend" Height="400px" Width="750px" 
                                                    AlternateText="My Performance" ImageUrl="~/Includes/MySales.ashx?Year=2010&Currency=EUR" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="dlPChartCurr" EventName="SelectedIndexChanged" />
                                                <asp:AsyncPostBackTrigger ControlID="dlPChartYear" EventName="SelectedIndexChanged" />
                                            </Triggers>
                                        </asp:UpdatePanel>                                        
                                    </td>
                                </tr>
                            </table>                            
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tab11" HeaderText="My Accounts">
            <ContentTemplate>
                <table width="100%">
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <th align="left">Account Name:</th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtAccName" Width="250px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" align="center"><asp:Button runat="server" ID="btnQueryAccount" Text="Search" OnClick="btnQueryAccount_Click" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upMyAccounts" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:ImageButton runat="server" ID="imgXlsAccounts" AlternateText="Download" OnClick="imgXlsAccounts_Click" ImageUrl="~/Images/excel.gif" />
                                    <asp:GridView runat="server" ID="gvAccount" Width="100%" AutoGenerateColumns="false" PageSize="50" 
                                        AllowPaging="true" AllowSorting="true" PagerSettings-Position="TopAndBottom" DataSourceID="AccSrc" 
                                        OnPageIndexChanging="gvAccount_PageIndexChanging" OnSorting="gvAccount_Sorting">
                                        <Columns>
                                            <asp:HyperLinkField HeaderText="Account Name" DataNavigateUrlFields="ROW_ID" 
                                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" 
                                                DataTextField="ACCOUNT_NAME" Target="_blank" SortExpression="ACCOUNT_NAME" />
                                            <asp:BoundField HeaderText="Account Status" DataField="ACCOUNT_STATUS" SortExpression="ACCOUNT_STATUS" />
                                            <asp:BoundField HeaderText="Opportunities" DataField="Open_Opportunities" SortExpression="Open_Opportunities" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="ERP ID" DataField="ERP_ID" SortExpression="ERP_ID" />
                                            <asp:BoundField HeaderText="Phone Number" DataField="PHONE_NUM" SortExpression="PHONE_NUM" />
                                            <asp:BoundField HeaderText="Account Type" DataField="ACCOUNT_TYPE" SortExpression="ACCOUNT_TYPE" />
                                            <asp:BoundField HeaderText="RBU" DataField="RBU" SortExpression="RBU" />
                                            <asp:BoundField HeaderText="Country" DataField="COUNTRY" SortExpression="COUNTRY" />
                                            <asp:BoundField HeaderText="City" DataField="CITY" SortExpression="CITY" />
                                            <asp:BoundField HeaderText="Address" DataField="ADDRESS" SortExpression="ADDRESS" />
                                            <asp:BoundField HeaderText="State" DataField="STATE" SortExpression="STATE" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="AccSrc" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="AccSrc_Selecting" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:PostBackTrigger ControlID="imgXlsAccounts" />
                                    <asp:AsyncPostBackTrigger ControlID="btnQueryAccount" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tab2" HeaderText="My Opportunities">
            <ContentTemplate>
                <table width="100%">
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <th align="left">Opportunity Name or Description:</th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOptyName" Width="250px" />
                                    </td>                                    
                                </tr>
                                <tr>
                                    <th align="left">Created Date</th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" TargetControlID="txtOptyCDateFrom" Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" TargetControlID="txtOptyCDateTo" Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtOptyCDateFrom" Width="80px" />&nbsp;to&nbsp;<asp:TextBox runat="server" ID="txtOptyCDateTo" Width="80px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">Account Name</th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOptyAccountName" Width="200px" />
                                    </td>  
                                </tr>
                                <tr>
                                    <td colspan="2" align="center"><asp:Button runat="server" ID="btnQueryOpty" Text="Search" OnClick="btnQueryOpty_Click" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upOpty" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Timer runat="server" ID="OptyTimer" Interval="500" OnTick="OptyTimer_Tick" />
                                    <center><asp:Image runat="server" ID="imgOptyLoading" ImageUrl="~/Images/loading2.gif" /></center>
                                    <asp:ImageButton runat="server" ID="imgExcelOpty" AlternateText="Download" 
                                        OnClick="imgExcelOpty_Click" ImageUrl="~/Images/excel.gif" />
                                    <asp:GridView runat="server" Width="100%" ID="gvOpty" AutoGenerateColumns="false" AllowPaging="true" 
                                        AllowSorting="true" PagerSettings-Position="TopAndBottom" PageSize="50" DataSourceID="optySrc" 
                                        OnPageIndexChanging="gvOpty_PageIndexChanging" OnSorting="gvOpty_Sorting">
                                        <Columns>
                                            <asp:BoundField HeaderText="Project Name" DataField="NAME" SortExpression="NAME" />
                                            <asp:BoundField HeaderText="Created Date" DataField="CREATED" SortExpression="CREATED" /> 
                                            <asp:HyperLinkField HeaderText="Customer Name" SortExpression="ACCOUNT_NAME" 
                                                DataNavigateUrlFields="ACCOUNT_ROW_ID" DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" 
                                                DataTextField="ACCOUNT_NAME" Target="_blank" />                         
                                            <asp:TemplateField HeaderText="Total Revenue" SortExpression="Total Revenue" ItemStyle-HorizontalAlign="Right">
                                                <ItemTemplate>
                                                    <%# Util.FormatMoney(Eval("SUM_REVN_AMT"), Eval("currency"))%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="Status" DataField="STATUS_CD" SortExpression="STATUS_CD" ItemStyle-HorizontalAlign="Center" />
                                            <asp:TemplateField HeaderText="Probability (%)" SortExpression="STATUS_CD" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%# Eval("SUM_WIN_PROB").ToString() + "%"%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="optySrc" ConnectionString="<%$ConnectionStrings:CRMDB75 %>" OnSelecting="optySrc_Selecting" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnQueryOpty" EventName="Click" />
                                    <asp:PostBackTrigger ControlID="imgExcelOpty" />
                                </Triggers>
                            </asp:UpdatePanel>                            
                        </td>
                    </tr>
                </table>                
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tab3" HeaderText="My Performance">
            <ContentTemplate>
                <table width="100%">
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <th align="left">Customer Name</th>
                                    <td><asp:TextBox runat="server" ID="txtPerfCustName" Width="200px" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Part No.</th>
                                    <td><asp:TextBox runat="server" ID="txtPerfPN" Width="150px" /></td>
                                </tr>
                                <tr>
                                    <th align="left">Due Date</th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender3" TargetControlID="txtPerfDueFrom" Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender4" TargetControlID="txtPerfDueTo" Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtPerfDueFrom" Width="80px" />&nbsp;to&nbsp;<asp:TextBox runat="server" ID="txtPerfDueTo" Width="80px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">Local Currency</th>
                                    <td>
                                        <asp:DropDownList runat="server" AutoPostBack="false" ID="dlMyPerfCurr">
                                            <asp:ListItem Text="USD" Value="US_AMT" />
                                            <asp:ListItem Value="EUR" Selected="True" />
                                            <asp:ListItem Value="TWD" />
                                            <asp:ListItem Value="RMB" />
                                            <asp:ListItem Value="JPY" />
                                            <asp:ListItem Value="SGD" />
                                            <asp:ListItem Value="AUD" />
                                            <asp:ListItem Value="MYR" />
                                            <asp:ListItem Value="BRL" />
                                            <asp:ListItem Value="KRW" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">Backlog or Shipment?</th>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblPerfType" RepeatColumns="3" RepeatDirection="Horizontal">
                                            <asp:ListItem Text="Both" Selected="True" />
                                            <asp:ListItem Value="Backlog" />
                                            <asp:ListItem Value="Shipment" />
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" align="center">
                                        <asp:Button runat="server" ID="btnQueryPerf" Text="Search" OnClick="btnQueryPerf_Click" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upMyPerf" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Timer runat="server" ID="PerfTimer" Interval="1000" OnTick="PerfTimer_Tick" />
                                    <center><asp:Image runat="server" ID="imgPerfLoad" ImageUrl="~/Images/loading2.gif" /></center>
                                    <asp:ImageButton runat="server" ID="imgPerfXls" AlternateText="Download" 
                                        ImageUrl="~/Images/excel.gif" OnClick="imgPerfXls_Click" />
                                    <asp:GridView runat="server" ID="gvPerf" Width="100%" PageSize="50" AutoGenerateColumns="false"
                                        PagerSettings-Position="TopAndBottom" AllowPaging="true" AllowSorting="true" 
                                        DataSourceID="PerfSrc" OnPageIndexChanging="gvPerf_PageIndexChanging" OnSorting="gvPerf_Sorting">
                                        <Columns>
                                            <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="part_no" SortExpression="part_no" 
                                                DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" DataTextField="part_no" Target="_blank" /> 
                                            <asp:HyperLinkField HeaderText="ERP ID" SortExpression="Customer_ID" DataNavigateUrlFields="Customer_ID" 
                                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ERPID={0}" DataTextField="Customer_ID" Target="_blank" /> 
                                            <asp:HyperLinkField HeaderText="Customer Name" SortExpression="COMPANY_NAME" DataNavigateUrlFields="Customer_ID" 
                                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ERPID={0}" DataTextField="COMPANY_NAME" Target="_blank" />                                           
                                            <asp:TemplateField HeaderText="Due Date" SortExpression="due_date">
                                                <ItemTemplate>
                                                    <%# CDate(Eval("due_date")).ToString("yyyy/MM/dd")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="Transaction Type" DataField="Tran_Type" SortExpression="Tran_Type" />
                                            <asp:BoundField HeaderText="Qty." DataField="Qty" SortExpression="Qty" />
                                            <asp:BoundField HeaderText="Sector" DataField="sector" SortExpression="sector" />
                                            <asp:BoundField HeaderText="Order No." DataField="order_no" SortExpression="order_no" />
                                            <asp:TemplateField HeaderText="Order Date" SortExpression="order_date">
                                                <ItemTemplate>
                                                    <%# CDate(Eval("order_date")).ToString("yyyy/MM/dd")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="Currency" DataField="currency" SortExpression="currency" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="US Amount" DataField="Us_amt" SortExpression="Us_amt" />
                                            <asp:BoundField HeaderText="Local Amount" DataField="LOCAL_AMT" SortExpression="LOCAL_AMT" />
                                            <asp:BoundField HeaderText="Product Group" DataField="product_group" SortExpression="product_group" />
                                            <asp:BoundField HeaderText="Product Division" DataField="product_division" SortExpression="product_division" />
                                            <asp:BoundField HeaderText="Product Line" DataField="Product_Line" SortExpression="Product_Line" />
                                            <asp:BoundField HeaderText="PO" DataField="PO" SortExpression="PO" Visible="false" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="PerfSrc" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="PerfSrc_Selecting" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnQueryPerf" EventName="Click" />
                                    <asp:PostBackTrigger ControlID="imgPerfXls" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
    </ajaxToolkit:TabContainer>
</asp:Content>