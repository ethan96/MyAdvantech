<%@ Page Title="MyAdvantech - Customer Dashboard" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %> 

<script runat="server">
    Protected Sub ProfileGv_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            CType(e.Row.FindControl("ChildAccountSrc"), SqlDataSource).SelectParameters("ParentAccountId").DefaultValue = hd_ROWID.Value
        End If
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If MailUtil.IsInRole("IT.ebusiness") Then Response.End()
            If Util.IsInternalUser(Session("user_id")) = False Then Response.Redirect("../home.aspx")
            
            txtActCreateFrom.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd") : txtActCreateTo.Text = Now.ToString("yyyy/MM/dd")
            txtPerfDueFrom.Text = DateAdd(DateInterval.Year, -1, Now).ToString("yyyy/MM/dd") : txtPerfDueTo.Text = DateAdd(DateInterval.Month, 6, Now).ToString("yyyy/MM/dd")
            Me.SrcPickCust.SelectCommand = GetPickAccountSql()
            Me.Master.EnableAsyncPostBackHolder = False
            If Request("ERPID") IsNot Nothing AndAlso Request("ERPID").ToString() <> "" Then
                'ICC 2014/11/25 Redirect this page to AOnline page to reduce repeat development
                Response.Redirect(String.Format("http://unica.advantech.com.tw/AOnline/CustomerDashboard.aspx?ERPID={0}", Request("ERPID").ToString()))
                Dim erpDt As DataTable = dbUtil.dbGetDataTable("MY", _
                String.Format("select top 1 a.ROW_ID from SIEBEL_ACCOUNT a inner join SAP_DIMCOMPANY b on a.ERP_ID=b.COMPANY_ID where b.company_id='{0}' order by a.account_status ", _
                              Request("ERPID").ToString().Trim().Replace("'", "")))
                If erpDt.Rows.Count = 1 Then
                    Server.Transfer("CustomerDashboard.aspx?ROWID=" + erpDt.Rows(0).Item("ROW_ID"))
                Else
                   
                End If
            End If
            If Request("ROWID") IsNot Nothing AndAlso Request("ROWID").ToString() <> "" Then
                'ICC 2014/11/25 Redirect this page to AOnline page to reduce repeat development
                Response.Redirect(String.Format("http://unica.advantech.com.tw/AOnline/CustomerDashboard.aspx?ROWID={0}", Request("ROWID").ToString()))
                hd_ROWID.Value = HttpUtility.UrlEncode(Request("ROWID").ToUpper().ToString().Trim().Replace("'", ""))
                Dim erpDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 b.COMPANY_ID from SIEBEL_ACCOUNT a inner join SAP_DIMCOMPANY b on a.ERP_ID=b.COMPANY_ID where a.ROW_ID='{0}'", hd_ROWID.Value))
                If erpDt.Rows.Count = 1 Then
                    hd_ERPID.Value = erpDt.Rows(0).Item("company_id")
                    tr_AssignedLeads.Visible = True
                    TimerLeads.Enabled = True
                    txtWarrantyShipFromDate.Text = DateAdd(DateInterval.Month, -6, DateAdd(DateInterval.Year, -2, Now)).ToString("yyyy/MM/dd")
                    txtWarrantyShipToDate.Text = DateAdd(DateInterval.Month, 6, DateAdd(DateInterval.Year, -2, Now)).ToString("yyyy/MM/dd")
                    txtWarrantyExpFromDate.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd")
                    txtWarrantyExpToDate.Text = DateAdd(DateInterval.Month, 6, Now).ToString("yyyy/MM/dd")
                    srcTopPN.SelectCommand = GetTopPNSql()
                Else
                    gvPerf.EmptyDataText = "ERPID for this account is either empty or incorrect"
                    imgPerfLoad.Visible = False : imgRMALoad.Visible = False
                    tr_AssignedLeads.Visible = False
                    TimerLeads.Enabled = False : TimerWarranty.Enabled = False : imgLoadWarranty.Visible = False
                    tr_TopPN.Visible = False
                End If
                dlPerfYear_SelectedIndexChanged(Nothing, Nothing)
            End If
            'ICC 2014/11/25 Redirect this page to AOnline page to reduce repeat development
            Response.Redirect(String.Format("http://unica.advantech.com.tw/AOnline/CustomerDashboard.aspx"))
            If hd_ROWID.Value = "" Then
                OptyTimer.Enabled = False : PerfTimer.Enabled = False : TimerContact.Enabled = False : TimerLeads.Enabled = False : TimerRMA.Enabled = False : TimerSR.Enabled = False
                imgContactLoading.Visible = False : imgOptyLoading.Visible = False : imgPerfLoad.Visible = False : imgRMALoad.Visible = False : imgSRLoad.Visible = False
            Else
                'TC: permission check
                If Util.IsAdmin() = False AndAlso MailUtil.IsInRole("DMF.eCoverage") = False _
                    AndAlso MailUtil.IsInRole("Sales.ATW (e-Coverage)") = False Then
                    'Dim uid As String = LCase(Session("user_id"))
                    'If uid.Contains("@") Then uid = Split(uid, "@")(0).Trim()
                    'uid = uid.Replace("'", "''")
                    'Dim sb As New System.Text.StringBuilder
                    'With sb
                    '    .AppendLine(String.Format(" select top 1 b.ROW_ID from SIEBEL_ACCOUNT_OWNER a inner join SIEBEL_CONTACT b on a.OWNER_ID=b.ROW_ID   "))
                    '    .AppendLine(String.Format(" where b.ACTIVE_FLAG='Y' and a.ACCOUNT_ROW_ID='{0}'  ", hd_ROWID.Value))
                    '    .AppendLine(String.Format(" and ( "))
                    '    .AppendLine(String.Format(" 		b.EMAIL_ADDRESS like '{0}@advantech%.%' or  ", uid))
                    '    .AppendLine(String.Format(" 		b.FirstName+'.'+b.LastName='{0}' or ", uid))
                    '    .AppendLine(String.Format(" 		b.FirstName+' '+b.LastName='{0}' or ", uid))
                    '    .AppendLine(String.Format(" 		b.LastName+'.'+b.FirstName='{0}' or ", uid))
                    '    .AppendLine(String.Format(" 		b.LastName+' '+b.FirstName='{0}' ", uid))
                    '    .AppendLine(String.Format(" 	) "))
                    'End With
                    'If dbUtil.dbGetDataTable("MY", sb.ToString()).Rows.Count = 0 AndAlso Util.IsAEUIT() = False Then
                    '    Response.Redirect("SalesDashboard.aspx")
                    'End If
                End If
            End If
        End If
    End Sub
    
    Function GetContactSql() As String
        'If Me.hd_ROWID.Value = "" Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" SELECT top 100000 a.ROW_ID, IsNull(a.EMAIL_ADDRESS,'') as EMAIL_ADDRESS, a.country, a.OrgId, a.CellPhone, a.WorkPhone, ")
            .AppendFormat(" IsNull(b.RBU,'') as RBU, ")
            .AppendFormat(" IsNull(b.state, '') as US_State, ")
            .AppendFormat(" IsNull(b.BusinessGroup,'') as BizGroup, ")
            .AppendFormat(" a.ACCOUNT as ACCOUNT_NAME, IsNull(a.ACCOUNT_TYPE,'') as account_type, IsNull(a.ACCOUNT_STATUS,'') as account_status, ")
            .AppendFormat(" a.Salutation, a.FirstName, a.MiddleName,  a.LastName, IsNull(a.JOB_FUNCTION,'') as job_function, ")
            .AppendFormat(" a.ACCOUNT_ROW_ID as ACCOUNT_ROW_ID, IsNull(a.JOB_TITLE,'') as job_title, ")
            .AppendFormat(" IsNull(b.primary_sales_email,'') as PrimaryOwner ")
            .AppendLine(" FROM SIEBEL_CONTACT AS a inner join SIEBEL_ACCOUNT b on a.account_row_id=b.row_id ")
            .AppendLine(String.Format(" where b.row_id='{0}' ", Me.hd_ROWID.Value))
            If txtContactName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.FirstName like N'%{0}%' or a.MiddleName like N'%{0}%' or a.LastName like N'%{0}%' or a.FirstName+' '+a.LastName like N'%{0}%' or a.LastName+' '+a.FirstName like N'%{0}%') ", txtContactName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtContactEmail.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.EMAIL_ADDRESS like N'%{0}%' ", txtContactEmail.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtContactTel.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.WorkPhone like N'%{0}%' or a.CellPhone like N'%{0}%') ", txtContactTel.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by a.row_id "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub gvContact_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        ContactSrc.SelectCommand = GetContactSql()
    End Sub

    Protected Sub gvContact_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        ContactSrc.SelectCommand = GetContactSql()
    End Sub

    Protected Sub TimerContact_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            TimerContact.Interval = 99999 : ContactSrc.SelectCommand = GetContactSql() : TimerContact.Enabled = False : imgContactLoading.Visible = False
            gvContact.EmptyDataText = "There is no contact under this account"
        Catch ex As Exception
            TimerContact.Enabled = False
            MailUtil.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "", ex.ToString(), False, "", "")
        End Try
    End Sub

    Protected Sub imgExcelContact_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetContactSql())
        If dt.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(dt, "AEUIT_Contacts.xls")
        End If
    End Sub

    Protected Sub btnQueryContact_Click(ByVal sender As Object, ByVal e As System.EventArgs)
         Me.Master.EnableAsyncPostBackHolder = True
        ContactSrc.SelectCommand = GetContactSql()
        gvContact.PageIndex = 0
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.TimerContact.Enabled = False : OptyTimer.Enabled = False : PerfTimer.Enabled = False : TimerRMA.Enabled = False
        TimerSR.Enabled = False
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

    Protected Sub imgXlsTop10CustPN_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim strSql as String = GetTopPNSql(1000)
        If strSql<>"" Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
            If dt.Rows.Count > 0 Then
                Util.DataTable2ExcelDownload(dt, "AEUIT_CustTopPN.xls")
            End If
        End If        
    End Sub
    
    Function GetOptySql() As String
        'If hd_ROWID.Value = "" Then Return ""
        Dim cfrom As Date = DateAdd(DateInterval.Month, -3, Now)
        Dim cto As Date = Now
        If txtOptyCDateFrom.Text.Trim() <> "" AndAlso Date.TryParse(txtOptyCDateFrom.Text, Now) Then cfrom = CDate(txtOptyCDateFrom.Text)
        If txtOptyCDateTo.Text.Trim() <> "" AndAlso Date.TryParse(txtOptyCDateTo.Text, Now) Then cto = CDate(txtOptyCDateTo.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 500 "))
            .AppendLine(String.Format(" A.ROW_ID, A.CREATED, A.LAST_UPD, A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, A.NAME, "))
            .AppendLine(String.Format(" A.CURCY_CD as currency, A.CURR_STG_ID, cast(A.SUM_WIN_PROB as int) as SUM_WIN_PROB, "))
            .AppendLine(String.Format(" cast(A.SUM_REVN_AMT as numeric(18,0)) as SUM_REVN_AMT, IsNull(X.ATTRIB_06,'') as BusinessGroup, "))
            .AppendLine(String.Format(" case when isnull(A.SUM_WIN_PROB,0)= 0 then A.SUM_REVN_AMT*(A.SUM_WIN_PROB/100) else 0 end as EXPECT_VAL, "))
            .AppendLine(String.Format(" IsNull((select top 1 B.NAME from S_STG B where B.ROW_ID=A.CURR_STG_ID),'') as STAGE_NAME, "))
            .AppendLine(String.Format(" A.PR_DEPT_OU_ID, A.STATUS_CD, "))
            .AppendLine(String.Format(" IsNull((select SM.NAME from S_SALES_METHOD SM where SM.ROW_ID=A.SALES_METHOD_ID),'') as SALES_METHOD_NAME, "))
            .AppendLine(String.Format(" IsNull(A.CHANNEL_TYPE_CD,'') as Channel, IsNull(A.DESC_TEXT,'') as DESC_TEXT, IsNull(A.REASON_WON_LOST_CD,'') as REASON_WON_LOST_CD "))
            .AppendLine(String.Format(" from S_OPTY A left outer join S_OPTY_X X on A.ROW_ID=X.ROW_ID "))
            '.AppendLine(String.Format(" inner join S_ORG_EXT z1 on A.PR_DEPT_OU_ID=z1.ROW_ID  "))
            '.AppendLine(String.Format(" inner join S_ACCNT_POSTN z2 on z1.ROW_ID=z2.OU_EXT_ID  "))
            '.AppendLine(String.Format(" inner join S_POSTN z3 on z2.POSITION_ID=z3.ROW_ID  "))
            '.AppendLine(String.Format(" inner join S_CONTACT z4 on z3.PR_EMP_ID=z4.ROW_ID "))
            .AppendLine(String.Format(" where A.PR_DEPT_OU_ID='{0}' ", Me.hd_ROWID.Value))
            '.AppendLine(String.Format(" and A.SUM_WIN_PROB between 1 and 99 and A.STATUS_CD not in ('Invalid') "))
            .AppendLine(String.Format(" and A.CREATED between '{0}' and '{1}' ", cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            If txtOptyName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (Upper(A.NAME) like N'%{0}%' or Upper(A.DESC_TEXT) like N'%{0}%') ", txtOptyName.Text.Trim().ToUpper().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by A.CREATED desc, A.ROW_ID "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub gvLeads_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        LeadsSrc.SelectCommand = Util.GetMyLeadsSql(hd_ERPID.Value, Session("user_id"), 0, 2, False)
    End Sub

    Protected Sub gvLeads_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        LeadsSrc.SelectCommand = Util.GetMyLeadsSql(hd_ERPID.Value, Session("user_id"), 0, 2, False)
    End Sub
    
    Protected Sub OptyTimer_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            OptyTimer.Interval = 99999 : optySrc.SelectCommand = GetOptySql()
            OptyTimer.Enabled = False : imgOptyLoading.Visible = False
            gvOpty.EmptyDataText = "There is no Opportunity under this account"
        Catch ex As Exception
            OptyTimer.Enabled = False
        End Try
    End Sub
    
    Protected Sub TimerLeads_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If hd_ERPID.Value <> "" Then
                TimerLeads.Interval = 99999 : LeadsSrc.SelectCommand = Util.GetMyLeadsSql(hd_ERPID.Value, Session("user_id"), 0, 2, False)
                TimerLeads.Enabled = False 'imgOptyLoading.Visible = False
                gvLeads.EmptyDataText = "There is no leads assigned to this account"
            End If
        Catch ex As Exception
            TimerLeads.Enabled = False
        End Try
        
    End Sub
    
    Protected Sub gvOpty_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        optySrc.SelectCommand = GetOptySql()
    End Sub

    Protected Sub gvOpty_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        optySrc.SelectCommand = GetOptySql()
    End Sub
    
    Function GetPerfSql() As String
        If hd_ERPID.value = "" Then Return ""
        Dim cfrom As Date = DateAdd(DateInterval.Year, -1, Now)
        Dim cto As Date = DateAdd(DateInterval.Month, 6, Now)
        If txtPerfDueFrom.Text.Trim() <> "" AndAlso Date.TryParse(txtPerfDueFrom.Text, Now) Then cfrom = CDate(txtPerfDueFrom.Text)
        If txtPerfDueTo.Text.Trim() <> "" AndAlso Date.TryParse(txtPerfDueTo.Text, Now) Then cto = CDate(txtPerfDueTo.Text)
        Dim eaiTable As String = "EAI_SALE_FACT"
        If DateDiff(DateInterval.Day, New Date(2007, 12, 31), cfrom) > 0 Then
            eaiTable = "EAI_SALE_FACT"
        Else
            eaiTable = "EAI_SALE_FACT_VOR_2008"
        End If
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 1000 a.item_no as part_no, a.Product_Line, a.Customer_ID, a.tr_curr as currency, b.COMPANY_NAME, IsNull(c.full_name,'') as sales_name, "))
            .AppendLine(String.Format(" a.efftive_date as due_date, a.Tran_Type, cast(a.Qty as int) as Qty, a.sector, a.order_no, a.order_date,  "))
            .AppendLine(String.Format(" a.Us_amt, a.{0} as LOCAL_AMT, a.egroup as product_group, a.edivision as product_division, a.PO  ", dlCustCurr.SelectedValue))
            .AppendLine(String.Format(" from " + eaiTable + " a inner join SAP_DIMCOMPANY b on a.Customer_ID=b.COMPANY_ID and a.org=b.ORG_ID left join sap_employee c on a.Sales_ID=c.sales_code   "))
            .AppendLine(String.Format(" where a.customer_id='{0}' and fact_1234=1  ", hd_ERPID.Value))
            .AppendLine(String.Format(" and FACTYEAR>=Year('{0}') and a.efftive_date between '{0}' and '{1}'  ", cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            If txtPerfPN.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.item_no like '%{0}%' ", txtPerfPN.Text.Trim().Replace("'", "''").Replace("*", "%")))
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
            If hd_ERPID.Value = "" Then
                PerfTimer.Enabled = False : Exit Sub
            End If
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
            Util.DataTable2ExcelDownload(dt, "AEUIT_MyPerformance.xls")
        End If
    End Sub
    
    Function GetRMASql() As String
        If hd_ERPID.Value = "" Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            Dim tmpFrom As Date = Date.MinValue, tmpTo As Date = Date.MaxValue
            .AppendLine(" select top 1000 a.Order_NO+'-'+Cast(a.Item_No as varchar(4)) as RMA_NO, ")
            .AppendLine(" dbo.DateOnly(a.Order_Dt) as Order_Date, a.Product_Name, a.Barcode, a.Now_Stage ")
            .AppendLine(" from RMA_My_Request_OrderList a ")
            .AppendLine(String.Format(" where a.Bill_ID='{0}' ", hd_ERPID.Value))
            If Me.txtRMAPartNo.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.Order_NO+'-'+Cast(a.Item_No as varchar(4)) like '%{0}%' ", Me.txtRMAPartNo.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If Me.txtRMAPartNo.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.Product_Name like '%{0}%' ", Me.txtRMAPartNo.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtRMASN.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.Barcode like '%{0}%' ", Me.txtRMASN.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If Date.TryParseExact(Trim(Me.txtRMAOrderFrom.Text), "yyyy/MM/dd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, tmpFrom) Then
                .AppendLine(String.Format(" and a.Order_Dt>='{0}' ", tmpFrom.ToString("yyyy-MM-dd")))
            End If
            If Date.TryParseExact(Trim(Me.txtRMAOrderTo.Text), "dd/MM/yyyy", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, tmpTo) Then
                .AppendLine(String.Format(" and a.Order_Dt<='{0}' ", tmpTo.ToString("yyyy-MM-dd")))
            End If
            If dlRMAStatus.SelectedValue <> "" Then
                .AppendLine(String.Format(" and a.Now_Stage='{0}' ", dlRMAStatus.SelectedValue))
            End If
            .AppendFormat(" order by a.order_dt desc ")
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub btnQueryRMA_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        RMASrc.SelectCommand = GetRMASql()
        gvRMA.PageIndex = 0
    End Sub

    Protected Sub imgRMAXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If hd_ERPID.Value = "" Then Exit Sub
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetRMASql())
        If dt.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(dt, "AEUIT_RMAOrder.xls")
        End If
    End Sub

    Protected Sub TimerRMA_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If hd_ERPID.Value = "" Then
                gvRMA.EmptyDataText = "ERPID for this account is either empty or incorrect"
                TimerRMA.Enabled = False : Exit Sub
            End If
            TimerRMA.Interval = 99999 : RMASrc.SelectCommand = GetRMASql() : TimerRMA.Enabled = False : imgRMALoad.Visible = False
            gvRMA.EmptyDataText = "No Data"
            Me.Master.EnableAsyncPostBackHolder = True
            TimerRMA.Enabled = False
        Catch ex As Exception
            TimerRMA.Enabled = False
        End Try
    End Sub

    Protected Sub gvRMA_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        RMASrc.SelectCommand = GetRMASql()
    End Sub

    Protected Sub gvRMA_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        RMASrc.SelectCommand = GetRMASql()
    End Sub
    
    Function GetSRSql() As String
        If hd_ROWID.Value = "" Then Return ""
        Dim oFrom As Date = DateAdd(DateInterval.Month, -3, Now), oTo As Date = Now
        If Date.TryParse(txtSRCreateFromDate.Text, Now) Then oFrom = CDate(txtSRCreateFromDate.Text)
        If Date.TryParse(txtSRCreateToDate.Text, Now) Then oTo = CDate(txtSRCreateToDate.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT TOP 1000 ROW_ID, CREATED, CREATED_BY, CREATOR_LOGIN,  "))
            .AppendLine(String.Format(" CREATOR_NAME, LAST_UPD, LAST_UPD_BY, BU_NAME, SR_NUM, ACT_CLOSE_DT,  "))
            .AppendLine(String.Format(" OWNER_EMP_ID, OWNER_LOGIN, OWNER_NAME, SR_STAT_ID, SR_SUB_STAT_ID, SR_TITLE,  "))
            .AppendLine(String.Format(" SR_SUBTYPE_CD, DESC_TEXT, MODEL_NO, PRODUCT_GROUP, PRODUCT_DIVISION,  "))
            .AppendLine(String.Format(" PRODUCT_LINE, SR_TYPE, KBase, CATEGORY, SFUNCTION, HW_REVISION, SW_VERSION,  "))
            .AppendLine(String.Format(" PUBLISH_SCOPE, CREATE_YEAR, ABSTRACT, SR_DESCRIPTION, CONTACT_ID, EMAIL, ALIAS_NAME "))
            .AppendLine(String.Format(" FROM SIEBEL_SR "))
            .AppendLine(String.Format(" WHERE ACCOUNT_ROW_ID = '{0}' and CREATED between '{1}' and '{2}' ", hd_ROWID.Value, oFrom.ToString("yyyy-MM-dd"), oTo.ToString("yyyy-MM-dd")))
            If txtSRModel.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and MODEL_NO like N'%{0}%'  ", txtSRModel.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtSRName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (SR_TITLE like N'%{0}%' or DESC_TEXT like N'%{0}%')  ", txtSRName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtSRNo.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and SR_NUM like N'%{0}%'  ", txtSRNo.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" ORDER BY CREATED DESC "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub btnQuerySR_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        SRSRc.SelectCommand = GetSRSql()
        gvSR.PageIndex = 0
    End Sub

    Protected Sub TimerSR_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If hd_ROWID.Value = "" Then
                TimerSR.Enabled = False : Exit Sub
            End If
            TimerSR.Interval = 99999 : SRSRc.SelectCommand = GetSRSql() : TimerSR.Enabled = False : imgSRLoad.Visible = False
            gvSR.EmptyDataText = "No Data"
            Me.Master.EnableAsyncPostBackHolder = True
        Catch ex As Exception
            imgSRLoad.Visible = False : TimerSR.Enabled = False
        End Try
    End Sub

    Protected Sub gvSR_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SRSRc.SelectCommand = GetSRSql()
    End Sub

    Protected Sub gvSR_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SRSRc.SelectCommand = GetSRSql()
    End Sub

    Protected Sub imgSRXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If hd_ROWID.Value = "" Then Exit Sub
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetSRSql())
        If dt.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(dt, "AEUIT_SR.xls")
        End If
    End Sub

    Protected Sub ContactSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub optySrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub PerfSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub ProfileSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub RMASrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SRSRc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub dlPerfYear_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        imgChart.ImageUrl = "~/Includes/CustChart.ashx?ROWID=" + hd_ROWID.Value + "&Year=" + dlPerfYear.SelectedValue + "&Curr=" + dlPerfCurr.SelectedValue
    End Sub
    
    Protected Sub ChildAccountGv_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim gv As GridView = sender
        Dim panel As Panel = gv.NamingContainer.FindControl("ChildAccountPanel")
        If gv.Rows.Count < 10 Then
            panel.Height = Unit.Pixel(35 + gv.Rows.Count * 10)
        Else
            panel.Height = Unit.Pixel(110)
        End If
    End Sub

    Protected Sub btnSearchCust_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvPickCust.PageIndex = 0
        SrcPickCust.SelectCommand = GetPickAccountSql()
    End Sub
    
    Function GetPickAccountSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 500 a.ROW_ID, a.ACCOUNT_NAME, a.ERP_ID, a.PRIMARY_SALES_EMAIL, a.RBU, a.ACCOUNT_STATUS  "))
            .AppendLine(String.Format(" from SIEBEL_ACCOUNT a  "))
            .AppendLine(" where 1=1 ")
            If txtpickCust.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.ACCOUNT_NAME like N'%{0}%' ", txtpickCust.Text.Replace("'", "''").Trim().Replace("*", "%")))
            End If
            If txtpickERPID.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.ERP_ID like N'%{0}%' ", txtpickERPID.Text.Trim().Replace("'", "").Replace("*", "%")))
            End If
            If txtPickOrg.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.RBU like N'%{0}%' ", txtPickOrg.Text.Trim().Replace("'", "").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by a.ACCOUNT_NAME, a.ACCOUNT_STATUS  "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub gvPickCust_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SrcPickCust.SelectCommand = GetPickAccountSql()
    End Sub

    Protected Sub gvPickCust_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SrcPickCust.SelectCommand = GetPickAccountSql()
    End Sub

    Protected Sub ChildAccountSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub LeadsSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SrcAccTeam_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SrcPickCust_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    'Protected Sub TimerEDM_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
    '    TimerEDM.Interval = 99999
    '    If hd_ROWID.Value = "" Then
    '        TimerEDM.Enabled = False : Exit Sub
    '    End If
    '    Try
    '        Dim ecws As New eCampaign_New.EC
    '        ecws.Timeout = 9999 : ecws.UseDefaultCredentials = True
    '        gvContactEDM.EmptyDataText = "There is no eDM sent to this account via eCampaign"
    '        gvContactEDM.DataSource = ecws.GetMyContactEDM(Me.hd_ROWID.Value)
    '        gvContactEDM.DataBind()
    '        TimerEDM.Enabled = False
    '    Catch ex As Exception
    '        MailUtil.SendDebugMsg("global MA custdashboard err", ex.ToString(), "tc.chen@advantech.com.tw")
    '        TimerEDM.Enabled = False : Exit Sub
    '    End Try
       
    'End Sub

    Function GetWarrantySql() As String
        If hd_ERPID.Value = "" Then Return ""
        Dim expFrom As Date = DateAdd(DateInterval.Month, -6, Now), expTo As Date = DateAdd(DateInterval.Month, 6, Now)
        If Date.TryParse(txtWarrantyExpFromDate.Text, Now) Then expFrom = CDate(txtWarrantyExpFromDate.Text)
        If Date.TryParse(txtWarrantyExpToDate.Text, Now) Then expTo = CDate(txtWarrantyExpToDate.Text)
        Dim shipFrom As Date = DateAdd(DateInterval.Month, -6, DateAdd(DateInterval.Year, -2, Now)), shipTo As Date = DateAdd(DateInterval.Month, 6, DateAdd(DateInterval.Year, -2, Now))
        If Date.TryParse(txtWarrantyShipFromDate.Text, Now) Then shipFrom = CDate(txtWarrantyShipFromDate.Text)
        If Date.TryParse(txtWarrantyShipToDate.Text, Now) Then shipTo = CDate(txtWarrantyShipToDate.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 5000 a.barcode_no, a.product_name as part_no, a.warranty_date, a.order_no, a.In_Station_Time as shipment_date "))
            .AppendLine(String.Format(" from RMA_SFIS a  "))
            .AppendLine(String.Format(" where a.customer_no='{0}' and a.warranty_date is not null ", hd_ERPID.Value))
            .AppendLine(String.Format(" and a.warranty_date between '{0}' and '{1}' ", expFrom.ToString("yyyy-MM-dd"), expTo.ToString("yyyy-MM-dd")))
            .AppendLine(String.Format(" and a.In_Station_Time between '{0}' and '{1}' ", shipFrom.ToString("yyyy-MM-dd"), shipTo.ToString("yyyy-MM-dd")))
            .AppendLine(String.Format(" order by a.warranty_date  "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub TimerWarranty_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        imgLoadWarranty.Visible = False : TimerWarranty.Interval = 99999
        Try
            SrcWarranty.SelectCommand = GetWarrantySql()
            gvWarranty.Visible = True : gvWarranty.EmptyDataText = "No Data"
        Catch ex As Exception
            MailUtil.SendDebugMsg("Error load global MA customer dashboard warranty exp", ex.ToString(), "tc.chen@advantech.eu")
        End Try
        TimerWarranty.Enabled = False
    End Sub

    Protected Sub btnQWarranty_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvWarranty.PageIndex = 0 : SrcWarranty.SelectCommand = GetWarrantySql()
    End Sub

    Protected Sub gvWarranty_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SrcWarranty.SelectCommand = GetWarrantySql()
    End Sub

    Protected Sub gvWarranty_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SrcWarranty.SelectCommand = GetWarrantySql()
    End Sub

    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub imgXlsWarranty_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If hd_ERPID.Value <> "" Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetWarrantySql())
            Util.DataTable2ExcelDownload(dt, "AEUIT_WExpire_" + hd_ERPID.Value + ".xls")
        End If
    End Sub

    Protected Sub SrcWarranty_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub
    
    Function GetActSql() As String
        If hd_ROWID.Value = "" Then Return ""
        Dim actFrom As Date = DateAdd(DateInterval.Month, -6, Now), actTo As Date = Now
        If Date.TryParse(txtActCreateFrom.Text, Now) Then actFrom = CDate(txtActCreateFrom.Text)
        If Date.TryParse(txtActCreateTo.Text, Now) Then actTo = CDate(txtActCreateTo.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT TOP 500 a.ROW_ID, a.APPT_START_DT, a.CAL_TYPE_CD, a.EVT_STAT_CD,  "))
            .AppendLine(String.Format(" a.NAME, a.OWNER_LOGIN, a.BU_NAME, a.CREATED, a.LAST_UPD, a.TODO_CD,  "))
            .AppendLine(String.Format(" a.CREATED_BY, a.COMMENTS_LONG, a.TODO_PLAN_START_DT, "))
            .AppendLine(String.Format(" a.TARGET_PER_ID as CONTACT_ROW_ID, IsNull(b.FirstName,'')+' '+IsNull(b.LastName,'') as CONTACT_NAME "))
            .AppendLine(String.Format(" FROM SIEBEL_ACTIVITY a left join SIEBEL_CONTACT b on a.TARGET_PER_ID=b.ROW_ID "))
            .AppendLine(String.Format(" WHERE a.TARGET_OU_ID='{0}' AND a.CREATE_YEAR >={1} and a.CREATED between '{2}' and '{3}' ", _
                                      hd_ROWID.Value, actFrom.Year.ToString(), actFrom.ToString("yyyy-MM-dd"), actTo.ToString("yyyy-MM-dd")))
            If txtActNameComment.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.NAME like N'%{0}%' or a.COMMENTS_LONG like N'%{0}%') ", _
                   Replace(Replace(txtActNameComment.Text, "'", "''"), "*", "%").Trim()))
            End If
            .AppendLine(String.Format(" ORDER BY a.CREATED DESC "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub btnQAct_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvAct.PageIndex = 0 : srcAct.SelectCommand = GetActSql()
    End Sub

    Protected Sub TimerAct_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            TimerAct.Interval = 99999
            imgLoadAct.Visible = False : gvAct.Visible = True
            srcAct.SelectCommand = GetActSql()
        Catch ex As Exception
            MailUtil.SendDebugMsg("global MA custdb load act error by " + User.Identity.Name, ex.ToString())
        End Try
        TimerAct.Enabled = False
    End Sub

    Protected Sub gvAct_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        srcAct.SelectCommand = GetActSql()
    End Sub

    Protected Sub gvAct_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        srcAct.SelectCommand = GetActSql()
    End Sub

    Protected Sub dlTopPNFactYear_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        srcTopPN.SelectCommand = GetTopPNSql()
    End Sub
    
    Function GetTopPNSql(Optional ByVal TopCount As Integer = 10) As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top "+ TopCount.ToString() +" a.item_no as part_no, cast(SUM(a.qty) as int) as qty, cast(SUM(a.us_amt) as numeric(18,2)) as US_Amt  "))
            .AppendLine(String.Format(" from EAI_SALE_FACT a  "))
            .AppendLine(String.Format(" where a.Customer_ID='{0}' and a.FACTYEAR={1} and a.Qty>0 ", hd_ERPID.Value, dlTopPNFactYear.SelectedValue))
            .AppendLine(String.Format(" group by a.item_no "))
            .AppendLine(String.Format(" order by SUM(a.qty) desc "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.Master.LogoImgPath = "~/Images/dm_logo.JPG"
        End If
    End Sub

    Protected Sub Page_PreRender(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Not Util.IsAEUIT() _
                And Not String.Equals(User.Identity.Name, "mary.huang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
                And Not String.Equals(User.Identity.Name, "tanya.lin@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
                And Not String.Equals(User.Identity.Name, "angus.hsu@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
                And Not MailUtil.IsInRole("AOnline") Then 'ICC 2014/10/14 Add AOnline users can see detail gridview
                If MailUtil.IsInRole("CRM.ACL") Then Response.Redirect("../home.aspx")
                Dim reqAccountId As String = Request("ROWID"), reqERPId As String = Request("ERPID")
                If String.IsNullOrEmpty(reqAccountId) And String.IsNullOrEmpty(reqERPId) Then
                   
                End If
                If String.Equals(User.Identity.Name, "marielle.severac@advantech.fr", StringComparison.CurrentCultureIgnoreCase) _
                    OrElse MailUtil.IsInRole("FINANCE.AEU") Then
                    If String.IsNullOrEmpty(reqAccountId) And Not String.IsNullOrEmpty(reqERPId) Then
                        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                        "select top 1 ROW_ID, ACCOUNT_NAME, RBU from SIEBEL_ACCOUNT where ERP_ID='" + reqERPId.Replace("'", "''") + "' and RBU in ('ADL','AFR','ABN','AEE','AIT','AUK','AMEA-Medical','ADLOG','AEU')")
                        If dt.Rows.Count = 0 Then
                            Response.Redirect("../home.aspx") : Exit Sub
                        End If
                    Else
                        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                        "select top 1 ROW_ID, ACCOUNT_NAME, RBU from SIEBEL_ACCOUNT where ROW_ID='" + reqAccountId.Replace("'", "''") + "' and RBU in ('ADL','AFR','ABN','AEE','AIT','AUK','AMEA-Medical','ADLOG','AEU')")
                        If dt.Rows.Count = 0 Then
                            Response.Redirect("../home.aspx") : Exit Sub
                        End If
                    End If
                Else
                    If String.IsNullOrEmpty(reqAccountId) And Not String.IsNullOrEmpty(reqERPId) Then
                        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                            " select top 1 a.OWNER_ID, b.EMAIL_ADDRESS " + _
                            " from SIEBEL_ACCOUNT_OWNER a inner join SIEBEL_CONTACT b on a.OWNER_ID=b.ROW_ID " + _
                            " inner join SIEBEL_ACCOUNT c on a.ACCOUNT_ROW_ID=c.ROW_ID " + _
                            " where c.ERP_ID='" + reqERPId.Replace("'", "''") + "' and b.EMAIL_ADDRESS='" + User.Identity.Name + "'")
                        If dt.Rows.Count = 0 Then
                            Response.Redirect("../home.aspx") : Exit Sub
                        End If
                    Else
                        If Not String.IsNullOrEmpty(reqAccountId) Then
                            Dim dt As DataTable = Nothing
                            If MailUtil.IsInMailGroup("ATWCallCenter", User.Identity.Name) Then
                                dt = dbUtil.dbGetDataTable("MY", _
                                " select top 1 a.ACCOUNT_NAME,a.ROW_ID,a.ERP_ID,a.RBU " + _
                                " from SIEBEL_ACCOUNT a  " + _
                                " where a.ROW_ID='" + reqAccountId.Replace("'", "''") + "' and a.RBU='ATW' ")
                            Else
                                dt = dbUtil.dbGetDataTable("MY", _
                                " select top 1 a.OWNER_ID, b.EMAIL_ADDRESS " + _
                                " from SIEBEL_ACCOUNT_OWNER a inner join SIEBEL_CONTACT b on a.OWNER_ID=b.ROW_ID " + _
                                " where a.ACCOUNT_ROW_ID='" + reqAccountId.Replace("'", "''") + "' and b.EMAIL_ADDRESS='" + User.Identity.Name + "'")
                            End If
                            If dt.Rows.Count = 0 Then
                                Response.Redirect("../home.aspx") : Exit Sub
                            End If
                        End If
                    End If
                End If
            End If
        End If
    End Sub

    Protected Sub gvPickCust_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then '一定要在
            For Each column As DataControlField In gvPickCust.Columns
                If column.HeaderText = "Account Name" Then
                    Dim h1 As HyperLink = CType(e.Row.Cells(0).Controls(0), HyperLink)
                    Dim sUrl As String = h1.NavigateUrl.Split("=")(0) + "=" + Server.UrlEncode(h1.NavigateUrl.Split("=")(1))
                    h1.NavigateUrl = sUrl
                End If
            Next
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript">       
        function ShowHide() {
            var div = document.getElementById('div_pickCust');
            if(div.style.display=='block'){
                div.style.display = 'none';
            }
            else {
                div.style.display = 'block';
            }
        } 
    </script>
    <asp:HiddenField runat="server" ID="hd_ROWID" />
    <asp:HiddenField runat="server" ID="hd_ERPID" />
    <table width="100%">
        <tr>
            <td align="right">
                <asp:LinkButton runat="server" ID="lnkPickCust" Font-Bold="true" Font-Size="Larger" Text="Pick Account" OnClientClick="ShowHide(); return false;" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <div id="div_pickCust" style="display:none; position:absolute;left:20px;top:100px; 
                                background-color:white;border: solid 1px silver;padding:10px; 
                                width:95%; height:420px;overflow:auto;">
                    <table width="95%">
                        <tr>
                            <td colspan="3" align="center"><asp:LinkButton runat="server" ID="lnkClosepickCust" Text="Close" Font-Bold="true" OnClientClick="ShowHide(); return false;" /></td>
                        </tr>
                        <tr>
                            <td align="center">
                                <asp:Panel runat="server" ID="panelSearhpickCust" DefaultButton="btnSearchCust">
                                    <table>
                                        <tr>
                                            <th align="left">Account Name</th>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtpickCust" Width="150px" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="left">ERP ID</th>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtpickERPID" Width="120px" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="left">Org</th>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtPickOrg" Width="100px" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:Button runat="server" ID="btnSearchCust" Text="Search" OnClick="btnSearchCust_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>                                
                            </td>
                        </tr>
                        <tr>
                            <td align="center">     
                                <asp:UpdatePanel runat="server" ID="upPickCust" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:GridView runat="server" ID="gvPickCust" Width="95%" 
                                            AutoGenerateColumns="false" DataSourceID="SrcPickCust" 
                                            AllowPaging="true" AllowSorting="true" 
                                            PagerSettings-Position="TopAndBottom" PageSize="20" 
                                            EmptyDataText="No Search Result" 
                                            OnPageIndexChanging="gvPickCust_PageIndexChanging" 
                                            OnSorting="gvPickCust_Sorting" onrowdatabound="gvPickCust_RowDataBound">
                                            <Columns>
                                                <asp:HyperLinkField HeaderText="Account Name" DataNavigateUrlFields="row_id" 
                                                    DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="account_name" />
                                                <asp:BoundField HeaderText="Primary Sales" DataField="primary_sales_email" SortExpression="primary_sales_email" />
                                                <asp:BoundField HeaderText="RBU" DataField="RBU" SortExpression="RBU" />
                                                <asp:BoundField HeaderText="ERP ID" DataField="ERP_ID" SortExpression="ERP_ID" />
                                                <asp:BoundField HeaderText="Account Status" DataField="account_status" SortExpression="account_status" /> 
                                            </Columns>
                                        </asp:GridView>
                                        <asp:SqlDataSource runat="server" ID="SrcPickCust" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="SrcPickCust_Selecting" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="btnSearchCust" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>     
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <ajaxToolkit:TabContainer runat="server" ID="tabc1" Width="100%">
                    <ajaxToolkit:TabPanel runat="server" ID="tab1" HeaderText="Account Profile">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="ProfileGv" AutoGenerateColumns="False" DataSourceID="ProfileSrc" 
                                            OnRowDataBound="ProfileGv_RowDataBoundDataRow" Width="900px" 
                                            ShowHeader="False">
                                            <Columns>
                                                <asp:TemplateField HeaderText="Profile">
                                                    <ItemTemplate>
                                                        <table width="95%">
                                                            <tr>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Name</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("ACCOUNT_NAME")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Type</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("ACCOUNT_TYPE")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Status</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("ACCOUNT_STATUS")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Major Account</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("MAJORACCOUNT_FLAG")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="4">
                                                                    <b>Address:</b> <%#Eval("ACCOUNT_ADDRESS")%>,&nbsp;<%# Eval("CITY")%>,&nbsp;<%# Eval("COUNTRY")%></td>                                                                                    
                                                            </tr>
                                                            <tr>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">ERP Id</th></tr>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:TextBox runat="server" ID="txtTmpERPId" Text='<%#Eval("ERP_ID") %>' />
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Fax Number</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("FAX_NUM")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Phone Number</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("PHONE_NUM")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Primary Sales</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("PRIMARY_SALES_EMAIL")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>                                                
                                                            <tr>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Url</th></tr>
                                                                        <tr>
                                                                            <td><a target="_blank" href='<%#Eval("URL")%>'><%#Eval("URL")%></a></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Biz. Group</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("BusinessGroup")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">RBU</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("RBU")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Partner</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("PARTNER_FLAG")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Competitor</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("COMPETITOR_FLAG")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Country</th></tr>
                                                                        <tr>
                                                                            <td><%#Eval("COUNTRY")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Parent Account</th></tr>
                                                                        <tr>
                                                                            <td>
                                                                                <a target="_blank" href='CustomerDashboard.aspx?ROWID=<%#Eval("PARENT_ROW_ID") %>'><%# Eval("PARENT_NAME")%></a>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td style="width:25%" valign="top">
                                                                    <table width="100%">
                                                                        <tr><th align="left" style="width:180px">Child Accounts</th></tr>
                                                                        <tr>
                                                                            <td>
                                                                                <asp:Panel runat="server" ID="ChildAccountPanel" Width="100%" Height="100px" ScrollBars="Auto">
                                                                                    <asp:GridView runat="server" ID="ChildAccountGv" DataSourceID="ChildAccountSrc" Width="99%" AutoGenerateColumns="false" OnDataBound="ChildAccountGv_DataBound">
                                                                                        <Columns>
                                                                                            <asp:HyperLinkField HeaderText="Account Name" DataNavigateUrlFields="ROW_ID" 
                                                                                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" 
                                                                                                DataTextField="account_name" Target="_blank" />
                                                                                        </Columns>
                                                                                    </asp:GridView> 
                                                                                    <asp:SqlDataSource runat="server" ID="ChildAccountSrc" ConnectionString="<%$ ConnectionStrings:MY %>" 
                                                                                        SelectCommand="select a.ROW_ID,IsNull(a.ERP_ID,'') as [ERP ID], ACCOUNT_NAME
                                                                                        FROM SIEBEL_ACCOUNT a where a.PARENT_ROW_ID=@ParentAccountId order by account_name" OnSelecting="ChildAccountSrc_Selecting">
                                                                                        <SelectParameters>
                                                                                            <asp:Parameter Name="ParentAccountId" Type="String" />
                                                                                        </SelectParameters>
                                                                                    </asp:SqlDataSource> 
                                                                                </asp:Panel>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>                                                
                                                        </table>
                                                    </ItemTemplate>                                                                            
                                                    <HeaderStyle HorizontalAlign="Left" />
                                                </asp:TemplateField>                                      
                                            </Columns>                                        
                                        </asp:GridView>
                                        <asp:SqlDataSource ID="ProfileSrc" runat="server" 
                                            ConnectionString="<%$ ConnectionStrings:MY %>" SelectCommand="
                                            SELECT     ROW_ID, ERP_ID, ACCOUNT_NAME, ACCOUNT_STATUS, FAX_NUM, PHONE_NUM, OU_TYPE_CD, URL, BusinessGroup, ACCOUNT_TYPE, RBU, 
                                            PRIMARY_SALES_EMAIL, IsNull(PARENT_ROW_ID,'') as PARENT_ROW_ID, MAJORACCOUNT_FLAG, COMPETITOR_FLAG, PARTNER_FLAG, COUNTRY, CITY, ADDRESS as ACCOUNT_ADDRESS, BAA, 
                                            CREATED, LAST_UPDATED, PriOwnerDivision, PriOwnerRowId, IsNull((select top 1 z.ACCOUNT_NAME from SIEBEL_ACCOUNT z where z.ROW_ID=a.PARENT_ROW_ID),'') as PARENT_NAME
                                            FROM         SIEBEL_ACCOUNT a
                                            WHERE     (ROW_ID = @AccountRowId)" OnSelecting="ProfileSrc_Selecting">
                                            <SelectParameters>
                                                <asp:ControlParameter ControlID="hd_ROWID" ConvertEmptyStringToNull="False" 
                                                    PropertyName="Value" Name="AccountRowId" />
                                            </SelectParameters>
                                        </asp:SqlDataSource>
                                    </td>
                                </tr>                    
                                <tr>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <th align="left">Performance</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <th align="left">Year:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPerfYear" AutoPostBack="True" 
                                                                    OnSelectedIndexChanged="dlPerfYear_SelectedIndexChanged">
                                                                    <asp:ListItem Value="2008" />
                                                                    <asp:ListItem Value="2009" />
                                                                    <asp:ListItem Value="2010" />
                                                                    <asp:ListItem Value="2011" />
                                                                    <asp:ListItem Value="2012" />
                                                                    <asp:ListItem Value="2013" />
                                                                    <asp:ListItem Value="2014" Selected="True" />
                                                                </asp:DropDownList>
                                                            </td>
                                                            <th align="left">Currency:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" AutoPostBack="True" ID="dlPerfCurr" 
                                                                    OnSelectedIndexChanged="dlPerfYear_SelectedIndexChanged">
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
                                                            <asp:Image runat="server" ID="imgChart" ImageUrl="~/Includes/CustChart.ashx" />
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="dlPerfYear" EventName="SelectedIndexChanged" />
                                                            <asp:AsyncPostBackTrigger ControlID="dlPerfCurr" EventName="SelectedIndexChanged" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr runat="server" id="tr_TopPN">
                                    <td runat="server">
                                        <table width="100%">
                                            <tr>
                                                <th align="left">Top 10 Products Customer Bought</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <th align="left">Shipment Year</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlTopPNFactYear" AutoPostBack="True" 
                                                                    OnSelectedIndexChanged="dlTopPNFactYear_SelectedIndexChanged">
                                                                    <asp:ListItem Value="2014" />
                                                                    <asp:ListItem Value="2013" />
                                                                    <asp:ListItem Value="2012" />
                                                                    <asp:ListItem Value="2011" Selected="True" />
                                                                    <asp:ListItem Value="2010" />
                                                                    <asp:ListItem Value="2009" />
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td><asp:ImageButton runat="server" ID="imgXlsTop10CustPN" ImageUrl="~/Images/excel.gif" AlternateText="Download" OnClick="imgXlsTop10CustPN_Click" /></td>
                                                        </tr>
                                                        <tr>
                                                            <td colspan="3">
                                                                <asp:UpdatePanel runat="server" ID="upTopPN" UpdateMode="Conditional">
                                                                    <ContentTemplate>
                                                                        <asp:GridView runat="server" ID="gvTopPN" AutoGenerateColumns="false" DataSourceID="srcTopPN">
                                                                            <Columns>
                                                                                <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="part_no" 
                                                                                    DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" 
                                                                                    DataTextField="part_no" Target="_blank" SortExpression="part_no" />
                                                                                <asp:BoundField HeaderText="Qty." DataField="Qty" SortExpression="Qty" ItemStyle-HorizontalAlign="Center" />
                                                                                <asp:BoundField HeaderText="USD Amount" DataField="US_Amt" SortExpression="US_Amt" ItemStyle-HorizontalAlign="Right" />
                                                                            </Columns>
                                                                        </asp:GridView>
                                                                        <asp:SqlDataSource runat="server" ID="srcTopPN" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="SrcWarranty_Selecting" />
                                                                    </ContentTemplate>
                                                                    <Triggers>
                                                                        <asp:AsyncPostBackTrigger ControlID="dlTopPNFactYear" EventName="SelectedIndexChanged" />
                                                                        <asp:PostBackTrigger ControlID="imgXlsTop10CustPN" />
                                                                    </Triggers>
                                                                </asp:UpdatePanel>                                                                
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <th align="left">Account Team</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:GridView runat="server" ID="gvAccountTeam" AutoGenerateColumns="False" 
                                                        DataSourceID="SrcAccTeam" Width="90%">
                                                        <Columns>
                                                            <asp:BoundField HeaderText="Primary Flag" DataField="PRIMARY_FLAG" 
                                                                SortExpression="PRIMARY_FLAG" >
                                                            <ItemStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:HyperLinkField HeaderText="Email" DataNavigateUrlFields="EMAIL_ADDRESS" DataNavigateUrlFormatString="mailto:{0}" DataTextField="EMAIL_ADDRESS" />
                                                            <asp:BoundField HeaderText="Job Title" DataField="JOB_TITLE" SortExpression="JOB_TITLE" />
                                                            <asp:BoundField HeaderText="RBU" DataField="OrgID" SortExpression="OrgID" >
                                                            <ItemStyle HorizontalAlign="Center" />
                                                            </asp:BoundField>
                                                            <asp:BoundField HeaderText="Position" DataField="PRIMARY_POSITION_NAME" SortExpression="PRIMARY_POSITION_NAME" />
                                                        </Columns>
                                                    </asp:GridView>
                                                    <asp:SqlDataSource runat="server" ID="SrcAccTeam" 
                                                        ConnectionString="<%$ ConnectionStrings:MY %>" OnSelecting="SrcWarranty_Selecting"
                                                        
                                                        SelectCommand="select a.PRIMARY_FLAG, b.EMAIL_ADDRESS, b.JOB_TITLE, b.OrgID, c.PRIMARY_POSITION_NAME from SIEBEL_ACCOUNT_OWNER a left join SIEBEL_CONTACT b on a.OWNER_ID=b.ROW_ID left join SIEBEL_POSITION c on a.POSITION_ID=c.ROW_ID where a.OWNER_ID<>'1-1RURW' and a.ACCOUNT_ROW_ID=@ACCROWID order by a.PRIMARY_FLAG desc, b.EMAIL_ADDRESS  ">
                                                        <SelectParameters>
                                                            <asp:ControlParameter ControlID="hd_ROWID" ConvertEmptyStringToNull="False" 
                                                                Name="ACCROWID" PropertyName="Value" />
                                                        </SelectParameters>
                                                    </asp:SqlDataSource>
                                                </td>
                                            </tr>
                                        </table>                            
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tab2" HeaderText="Contacts">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">Contact Name</th>
                                                <td><asp:TextBox runat="server" ID="txtContactName" Width="100px" /></td>
                                            </tr>
                                            <tr>
                                                <th align="left">Contact Email</th>
                                                <td><asp:TextBox runat="server" ID="txtContactEmail" Width="150px" /></td>
                                            </tr>
                                            <tr>
                                                <th align="left">Phone</th>
                                                <td><asp:TextBox runat="server" ID="txtContactTel" Width="100px" /></td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" align="center"><asp:Button runat="server" ID="btnQueryContact" Text="Search" OnClick="btnQueryContact_Click" /></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upContact" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Timer runat="server" ID="TimerContact" Interval="100" OnTick="TimerContact_Tick" />
                                                <center><asp:Image runat="server" ID="imgContactLoading" ImageUrl="~/Images/loading2.gif" /></center>
                                                <asp:ImageButton runat="server" ID="imgExcelContact" AlternateText="Download" 
                                                    ImageUrl="~/Images/excel.gif" OnClick="imgExcelContact_Click" />
                                                <asp:GridView runat="server" ID="gvContact" Width="100%" AutoGenerateColumns="false" 
                                                    AllowSorting="true" DataSourceID="ContactSrc" OnPageIndexChanging="gvContact_PageIndexChanging" 
                                                    OnSorting="gvContact_Sorting" EnableTheming="true" OnRowCreated="gvRowCreated" 
                                                    RowStyle-BackColor="#FEFEFE" AlternatingRowStyle-BackColor="#DCDBDB" HeaderStyle-BackColor="#6589C3" 
                                                    BorderWidth="0" HeaderStyle-ForeColor="White" BorderStyle="None" PagerStyle-BackColor="#6589C3">
                                                    <Columns>
                                                        <asp:HyperLinkField HeaderText="ROW ID" DataNavigateUrlFields="ROW_ID" SortExpression="ROW_ID" 
                                                            DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="ROW_ID" Target="_blank" />
                                                        <asp:HyperLinkField HeaderText="Email" DataNavigateUrlFields="EMAIL_ADDRESS" SortExpression="EMAIL_ADDRESS" 
                                                            DataNavigateUrlFormatString="ContactDashboard.aspx?EMAIL={0}" DataTextField="EMAIL_ADDRESS" Target="_blank" />
                                                        <asp:HyperLinkField HeaderText="First Name" DataNavigateUrlFields="ROW_ID" SortExpression="FirstName" 
                                                            DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="FirstName" Target="_blank" />
                                                        <asp:HyperLinkField HeaderText="Last Name" DataNavigateUrlFields="ROW_ID" SortExpression="LastName" 
                                                            DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="LastName" Target="_blank" />
                                                        <asp:HyperLinkField HeaderText="Job Title" DataNavigateUrlFields="ROW_ID" SortExpression="JOB_TITLE" 
                                                            DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="JOB_TITLE" Target="_blank" />
                                                        <asp:BoundField HeaderText="Job Function" DataField="JOB_FUNCTION" SortExpression="JOB_FUNCTION" />
                                                        <asp:BoundField HeaderText="Country" DataField="country" SortExpression="country" />
                                                        <asp:BoundField HeaderText="Work Phone" DataField="WorkPhone" SortExpression="WorkPhone" />
                                                        <asp:BoundField HeaderText="Cell Phone" DataField="CellPhone" SortExpression="CellPhone" />                                                                        
                                                        <asp:BoundField DataField="OrgId" HeaderText="Contact Org." SortExpression="OrgId" />
                                                        <asp:BoundField DataField="US_State" HeaderText="State" SortExpression="US_State" />
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="ContactSrc" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="ContactSrc_Selecting" />                                                
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnQueryContact" EventName="Click" />
                                                <asp:PostBackTrigger ControlID="imgExcelContact" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <%--<tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upEDM" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <b>eCampaign Sent Log</b>
                                                <asp:Timer runat="server" ID="TimerEDM" Interval="2000" OnTick="TimerEDM_Tick" Enabled="false" />
                                                <asp:GridView runat="server" ID="gvContactEDM" AutoGenerateColumns="false" Width="85%" 
                                                    EnableTheming="true" RowStyle-BackColor="#FEFEFE" AlternatingRowStyle-BackColor="#DCDBDB" 
                                                    HeaderStyle-BackColor="#6589C3" BorderWidth="0" HeaderStyle-ForeColor="White" 
                                                    BorderStyle="None" PagerStyle-BackColor="#6589C3" OnRowCreated="gvRowCreated">
                                                    <Columns>
                                                        <asp:HyperLinkField HeaderText="eDM Subject" SortExpression="email_subject" 
                                                            DataNavigateUrlFields="campaign_row_id,contact_email" 
                                                            DataNavigateUrlFormatString="~/Includes/GetTemplate.ashx?Rowid={0}&Email={1}" 
                                                            Target="_blank" DataTextField="email_subject" />
                                                        <asp:BoundField HeaderText="Send Time" DataField="email_send_time" SortExpression="email_send_time" />
                                                        <asp:HyperLinkField HeaderText="Email" DataNavigateUrlFields="contact_email" SortExpression="contact_email" 
                                                            DataNavigateUrlFormatString="ContactDashboard.aspx?EMAIL={0}" DataTextField="contact_email" />
                                                        <asp:BoundField HeaderText="eDM Opened?" DataField="email_isopened" SortExpression="email_isopened" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Sent By" DataField="created_by" SortExpression="created_by" />
                                                    </Columns>
                                                </asp:GridView> 
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>--%>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tab21" HeaderText="Activities">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">Created Date:</th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="extActFrom" TargetControlID="txtActCreateFrom" Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="extActTo" TargetControlID="txtActCreateTo" Format="yyyy/MM/dd" />
                                                    <asp:TextBox runat="server" ID="txtActCreateFrom" Width="80px" />~<asp:TextBox runat="server" ID="txtActCreateTo" Width="80px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">Name/Comment:</th>
                                                <td><asp:TextBox runat="server" ID="txtActNameComment" Width="150px" /></td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" align="center"><asp:Button runat="server" ID="btnQAct" Text="Search" OnClick="btnQAct_Click" /></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <td>
                                                    
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upAct" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Timer runat="server" ID="TimerAct" Interval="1500" OnTick="TimerAct_Tick" />
                                                            <asp:Image runat="server" ID="imgLoadAct" ImageUrl="~/Images/Loading2.gif" AlternateText="Loading Activities" />
                                                            <asp:GridView runat="server" DataSourceID="srcAct" ID="gvAct" Width="99%" 
                                                                AllowPaging="true" AllowSorting="true" PageSize="100" 
                                                                PagerSettings-Position="TopAndBottom" AutoGenerateColumns="false" 
                                                                Visible="false" EmptyDataText="No Data" OnRowCreated="gvRowCreated" OnPageIndexChanging="gvAct_PageIndexChanging" OnSorting="gvAct_Sorting">
                                                                <Columns>
                                                                    <asp:BoundField HeaderText="Name" DataField="NAME" SortExpression="NAME" />
                                                                    <asp:BoundField HeaderText="Created Date" DataField="CREATED" SortExpression="CREATED" />
                                                                    <asp:BoundField HeaderText="Type" DataField="TODO_CD" SortExpression="TODO_CD" />
                                                                    <asp:BoundField HeaderText="Owner" DataField="OWNER_LOGIN" SortExpression="OWNER_LOGIN" />
                                                                    <asp:BoundField HeaderText="Comment" DataField="COMMENTS_LONG" SortExpression="COMMENTS_LONG" />
                                                                    <asp:HyperLinkField HeaderText="Contact" DataNavigateUrlFields="CONTACT_ROW_ID" 
                                                                        SortExpression="CONTACT_NAME" DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" 
                                                                        DataTextField="CONTACT_NAME" Target="_blank" />
                                                                </Columns>
                                                            </asp:GridView>
                                                            <asp:SqlDataSource runat="server" ID="srcAct" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="SrcWarranty_Selecting" />
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="btnQAct" EventName="Click" />
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
                    <ajaxToolkit:TabPanel runat="server" ID="tab3" HeaderText="Opportunities">
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
                                                <td colspan="2" align="center"><asp:Button runat="server" ID="btnQueryOpty" Text="Search" OnClick="btnQueryOpty_Click" /></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td align="left">
                                        <asp:UpdatePanel runat="server" ID="upOpty" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Timer runat="server" ID="OptyTimer" Interval="4000" OnTick="OptyTimer_Tick" />
                                                <center><asp:Image runat="server" ID="imgOptyLoading" ImageUrl="~/Images/loading2.gif" /></center>
                                                <asp:ImageButton runat="server" ID="imgExcelOpty" AlternateText="Download" 
                                                    OnClick="imgExcelOpty_Click" ImageUrl="~/Images/excel.gif" />
                                                <asp:GridView runat="server" Width="100%" ID="gvOpty" AutoGenerateColumns="false" AllowPaging="true" EnableTheming="true" 
                                                    AllowSorting="true" PageSize="50" DataSourceID="optySrc" OnPageIndexChanging="gvOpty_PageIndexChanging" OnSorting="gvOpty_Sorting"
                                                    RowStyle-BackColor="#FEFEFE" AlternatingRowStyle-BackColor="#DCDBDB" HeaderStyle-BackColor="#6589C3" 
                                                    BorderWidth="0" HeaderStyle-ForeColor="White" BorderStyle="None" PagerStyle-BackColor="#6589C3" OnRowCreated="gvRowCreated">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="Project Name" DataField="NAME" SortExpression="NAME" />
                                                        <asp:BoundField HeaderText="Created Date" DataField="CREATED" SortExpression="CREATED" />                         
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
                                <tr runat="server" id="tr_AssignedLeads" visible="false">
                                    <td>
                                        <table width="90%">
                                            <tr style="height:5px"><td><hr /></td></tr>
                                            <tr>
                                                <th align="left">Leads Assigned to this account</th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upMyLeads" UpdateMode="Conditional">
                                                        <ContentTemplate>  
                                                            <asp:Timer runat="server" ID="TimerLeads" Interval="9000" OnTick="TimerLeads_Tick" />                                              
                                                             <asp:GridView runat="server" ID="gvLeads" Width="98%" PageSize="10" AllowPaging="true" 
                                                                DataKeyNames="ROW_ID,STAGE_NAME,NAME,SALES_TEAM_LOGIN,DESC_TEXT,SUM_REVN_AMT,ACCOUNT_ROW_ID,CONTACT_ROW_ID,BU_NAME" 
                                                                AllowSorting="true" DataSourceID="LeadsSrc" AutoGenerateColumns="false" EnableTheming="true"
                                                                PagerSettings-Position="TopAndBottom" OnPageIndexChanging="gvLeads_PageIndexChanging" OnSorting="gvLeads_Sorting" 
                                                                RowStyle-BackColor="#FEFEFE" AlternatingRowStyle-BackColor="#DCDBDB" HeaderStyle-BackColor="#6589C3" 
                                                                BorderWidth="0" HeaderStyle-ForeColor="White" BorderStyle="None" PagerStyle-BackColor="#6589C3" OnRowCreated="gvRowCreated">
                                                                <Columns>                                                                                   
                                                                    <asp:TemplateField HeaderText="Stage" SortExpression="STAGE_NAME">
                                                                        <ItemTemplate>
                                                                            <asp:Label runat="server" ID="lbRowStage" Text='<%# Eval("STAGE_NAME") %>'/>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>                                
                                                                    <asp:BoundField DataField="ROW_ID" HeaderText="ROW ID" ReadOnly="True" SortExpression="ROW_ID" Visible="false" />
                                                                    <asp:BoundField DataField="NAME" HeaderText="Name" SortExpression="NAME" ReadOnly="true" /> 
                                                                    <asp:BoundField DataField="CURCY_CD" HeaderText="Currency" SortExpression="CURCY_CD" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />                               
                                                                    <asp:TemplateField HeaderText="Amount" SortExpression="SUM_REVN_AMT" ItemStyle-HorizontalAlign="Right">
                                                                        <ItemTemplate>
                                                                            <asp:Label runat="server" ID="lbRowAmt" Text='<%#Eval("SUM_REVN_AMT") %>' />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField DataField="SUM_WIN_PROB" HeaderText="Probability" SortExpression="SUM_WIN_PROB" Visible="false" ReadOnly="true" ItemStyle-HorizontalAlign="Right" />                                
                                                                    <asp:TemplateField HeaderText="Account & Contact" SortExpression="ACCOUNT_NAME" HeaderStyle-VerticalAlign="Top" HeaderStyle-Width="250px">
                                                                        <ItemTemplate>
                                                                            <table width="100%">
                                                                                <tr>
                                                                                    <th align="left" style="width:80px; color:Navy;">Account Name</th>
                                                                                    <td><%#Eval("ACCOUNT_NAME")%></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="width:80px; color:Navy;">Account Address</th>
                                                                                    <td><%#Eval("ACCOUNT_ADDRESS")%></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="width:80px; color:Navy;">Account Phone</th>
                                                                                    <td><%# Util.TrimPhone(Eval("ACCOUNT_PHONE"))%></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="width:80px; color:Navy;">Lead Contact</th>
                                                                                    <td><a href='mailto:<%#Eval("CONTACT_EMAIL")%>'><%#Eval("CONTACT")%></a></td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <th align="left" style="width:80px; color:Navy;">Contact Phone</th>
                                                                                    <td><%# Util.TrimPhone(Eval("CONTACT_PHONE"))%></td>
                                                                                </tr>                                            
                                                                            </table>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField DataField="CURR_STG_ID" HeaderText="Current Stage" Visible="false" SortExpression="CURR_STG_ID" />
                                                                    <asp:BoundField DataField="STAGE_NAME" HeaderText="Current Stage" Visible="false" ReadOnly="True" SortExpression="STAGE_NAME" />
                                                                    <asp:BoundField DataField="BU_ID" HeaderText="BU_ID" SortExpression="BU_ID" Visible="false" />
                                                                    <asp:BoundField DataField="BU_NAME" HeaderText="BU NAME" SortExpression="BU_NAME" Visible="false" ReadOnly="true" />
                                                                    <asp:TemplateField HeaderText="Create Date" SortExpression="CREATED" ItemStyle-HorizontalAlign="Center" 
                                                                        ItemStyle-Width="80px" HeaderStyle-Width="80px">
                                                                        <ItemTemplate>
                                                                            <asp:Label runat="server" ID="lbCDate1" Text='<%#Util.DateOnly(Eval("CREATED")) %>' />
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:Label runat="server" ID="lbCDate2" Text='<%#Util.DateOnly(Eval("CREATED")) %>' />
                                                                        </EditItemTemplate>
                                                                    </asp:TemplateField> 
                                                                    <asp:TemplateField HeaderText="Close Date" SortExpression="SUM_EFFECTIVE_DT" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="80px" HeaderStyle-Width="80px">
                                                                        <ItemTemplate>
                                                                            <asp:Label runat="server" ID="lbRowCloseDate" Text='<%#Util.DateOnly(Eval("SUM_EFFECTIVE_DT")) %>' />
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:TextBox runat="server" ID="txtRowCloseDate" Text='<%#Util.DateOnly(Eval("SUM_EFFECTIVE_DT")) %>' />
                                                                            <ajaxToolkit:CalendarExtender runat="server" ID="ceRowCloseDate" TargetControlID="txtRowCloseDate" Format="yyyy/MM/dd" />
                                                                        </EditItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField DataField="CREATED_BY_LOGIN" HeaderText="CREATED_BY_LOGIN" Visible="false" SortExpression="CREATED_BY_LOGIN" />
                                                                    <asp:BoundField DataField="CREATED_BY_NAME" HeaderText="Created By" Visible="false" ReadOnly="True" SortExpression="CREATED_BY_NAME" />                                
                                                                    <asp:TemplateField HeaderText="Description" SortExpression="DESC_TEXT">
                                                                        <ItemTemplate>
                                                                            <asp:Label runat="server" ID="lblRowDesc" Text='<%#Eval("DESC_TEXT") %>' />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField DataField="LAST_UPD" HeaderText="Last Updated Date" Visible="false" SortExpression="LAST_UPD" />
                                                                    <asp:BoundField DataField="LAST_UPD_BY_LOGIN" HeaderText="LAST_UPD_BY_LOGIN" Visible="false" SortExpression="LAST_UPD_BY_LOGIN" />
                                                                    <asp:BoundField DataField="LAST_UPD_BY_NAME" HeaderText="LAST_UPD_BY_NAME" Visible="false" ReadOnly="True" SortExpression="LAST_UPD_BY_NAME" />
                                                                    <asp:BoundField DataField="PR_POSTN_ID" HeaderText="PR_POSTN_ID" Visible="false" SortExpression="PR_POSTN_ID" />
                                                                    <asp:BoundField DataField="POSTN_TYPE_CD" HeaderText="POSTN_TYPE_CD" Visible="false" SortExpression="POSTN_TYPE_CD" />
                                                                    <asp:BoundField DataField="PR_PROD_ID" HeaderText="PR_PROD_ID" ReadOnly="True" Visible="false" SortExpression="PR_PROD_ID" />
                                                                    <asp:BoundField DataField="REASON_WON_LOST_CD" HeaderText="Reason Won/Lost" Visible="false" ReadOnly="True" SortExpression="REASON_WON_LOST_CD" />                                
                                                                    <asp:BoundField DataField="STG_NAME" HeaderText="STG_NAME" ReadOnly="True" Visible="false" SortExpression="STG_NAME" />
                                                                    <asp:BoundField DataField="SALES_TEAM_LOGIN" HeaderText="SALES_TEAM_LOGIN" Visible="false" SortExpression="SALES_TEAM_LOGIN" />
                                                                    <asp:BoundField DataField="SALES_TEAM_NAME" HeaderText="Sales Team" ReadOnly="True" SortExpression="SALES_TEAM_NAME" />
                                                                    <asp:BoundField DataField="MODIFICATION_NUM" HeaderText="MODIFICATION_NUM" Visible="false" SortExpression="MODIFICATION_NUM" />
                                                                    <asp:BoundField DataField="SUM_EFFECTIVE_DT" HeaderText="SUM_EFFECTIVE_DT" Visible="false" SortExpression="SUM_EFFECTIVE_DT" />
                                                                    <asp:BoundField DataField="PAR_OPTY_ID" HeaderText="PAR_OPTY_ID" Visible="false" ReadOnly="True" SortExpression="PAR_OPTY_ID" />
                                                                    <asp:BoundField DataField="EXPECT_VAL" HeaderText="Expected Value" ReadOnly="True" SortExpression="EXPECT_VAL" Visible="false" ItemStyle-HorizontalAlign="Right" />
                                                                    <asp:BoundField DataField="FACTOR" HeaderText="FACTOR" ReadOnly="True" Visible="false" SortExpression="FACTOR" /> 
                                                                    <asp:BoundField DataField="ChannelContact" HeaderText="Contact" SortExpression="ChannelContact" />
                                                                </Columns>
                                                            </asp:GridView>
                                                            <asp:SqlDataSource runat="server" ID="LeadsSrc" ConnectionString="<%$ ConnectionStrings:CRMDB75 %>" OnSelecting="LeadsSrc_Selecting" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tab4" HeaderText="Order History">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table>
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
                                                <th align="left">Local Currency</th>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlCustCurr">
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
                                        <asp:UpdatePanel runat="server" ID="upOrderHistory" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Timer runat="server" ID="PerfTimer" Interval="6000" OnTick="PerfTimer_Tick" />
                                                <center><asp:Image runat="server" ID="imgPerfLoad" ImageUrl="~/Images/loading2.gif" /></center>
                                                <asp:ImageButton runat="server" ID="imgPerfXls" AlternateText="Download" 
                                                    ImageUrl="~/Images/excel.gif" OnClick="imgPerfXls_Click" />
                                                <asp:GridView runat="server" ID="gvPerf" Width="100%" PageSize="50" AutoGenerateColumns="false" EnableTheming="true" 
                                                    PagerSettings-Position="TopAndBottom" AllowPaging="true" AllowSorting="true" OnRowCreated="gvRowCreated"
                                                    DataSourceID="PerfSrc" OnPageIndexChanging="gvPerf_PageIndexChanging" OnSorting="gvPerf_Sorting"
                                                    RowStyle-BackColor="#FEFEFE" AlternatingRowStyle-BackColor="#DCDBDB" HeaderStyle-BackColor="#6589C3" 
                                                    BorderWidth="0" HeaderStyle-ForeColor="White" BorderStyle="None" PagerStyle-BackColor="#6589C3">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="Sales Name" DataField="sales_name" SortExpression="sales_name" />                                           
                                                        <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="part_no" 
                                                            DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" DataTextField="part_no" Target="_blank" />                                         
                                                        <asp:TemplateField HeaderText="Due Date" SortExpression="due_date">
                                                            <ItemTemplate>
                                                                <%# CDate(Eval("due_date")).ToString("yyyy/MM/dd")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField HeaderText="Transaction Type" DataField="Tran_Type" SortExpression="Tran_Type" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Qty." DataField="Qty" SortExpression="Qty" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Sector" DataField="sector" SortExpression="sector" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Order No." DataField="order_no" SortExpression="order_no" />
                                                        <asp:TemplateField HeaderText="Order Date" SortExpression="order_date">
                                                            <ItemTemplate>
                                                                <%# CDate(Eval("order_date")).ToString("yyyy/MM/dd")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField HeaderText="Currency" DataField="currency" SortExpression="currency" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="US Amount" DataField="Us_amt" SortExpression="Us_amt" ItemStyle-HorizontalAlign="Right" />
                                                        <asp:BoundField HeaderText="Local Amount" DataField="LOCAL_AMT" SortExpression="LOCAL_AMT" ItemStyle-HorizontalAlign="Right" />
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
                    <ajaxToolkit:TabPanel runat="server" ID="tab5" HeaderText="RMA Orders">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table width="50%">
                                            <tr>
                                                <th align="left">Order No.</th>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRMAOrderNo" Width="200px"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">Serial No.</th>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRMASN" Width="200px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">Part No.</th>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtRMAPartNo" Width="200px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">Status</th>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlRMAStatus" Width="200px">
                                                        <asp:ListItem Text="All" Value=""/>                                
                                                        <asp:ListItem Text="Receive" Value="Receive"/>
                                                        <asp:ListItem Text="Back Receive" Value="Back Receive" />
                                                        <asp:ListItem Text="Ship" Value="Ship"/>
                                                        <asp:ListItem Text="Back Ship" Value="Back Ship"/>
                                                        <asp:ListItem Text="Repair" Value="Repair"/>
                                                        <asp:ListItem Text="Back Repair" Value="Back Repair"/>
                                                        <asp:ListItem Text="Accounting" Value="Accounting"/>                                
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">Order Date</th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="cal1" TargetControlID="txtRMAOrderFrom" Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="cal2" TargetControlID="txtRMAOrderTo" Format="yyyy/MM/dd" />
                                                    From:&nbsp;<asp:TextBox runat="server" ID="txtRMAOrderFrom" Width="100px" />&nbsp;
                                                    To:&nbsp;<asp:TextBox runat="server" ID="txtRMAOrderTo" Width="100px" />&nbsp;
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" align="center">
                                                    <asp:Button runat="server" ID="btnQueryRMA" Text="Search" OnClick="btnQueryRMA_Click" />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upRMA" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Timer runat="server" ID="TimerRMA" Interval="7000" OnTick="TimerRMA_Tick" />
                                                <center><asp:Image runat="server" ID="imgRMALoad" ImageUrl="~/Images/loading2.gif" /></center>
                                                <asp:ImageButton runat="server" ID="imgRMAXls" AlternateText="Download" ImageUrl="~/Images/excel.gif" OnClick="imgRMAXls_Click" />
                                                <asp:GridView PagerSettings-Position="TopAndBottom" runat="server" ID="gvRMA" AutoGenerateColumns="False" Width="100%" AllowPaging="true" PageSize="50"
                                                    DataSourceID="RMASrc" OnPageIndexChanging="gvRMA_PageIndexChanging" OnSorting="gvRMA_Sorting" EnableTheming="true"
                                                    RowStyle-BackColor="#FEFEFE" AlternatingRowStyle-BackColor="#DCDBDB" HeaderStyle-BackColor="#6589C3" 
                                                    BorderWidth="0" HeaderStyle-ForeColor="White" BorderStyle="None" PagerStyle-BackColor="#6589C3">
                                                    <Columns>
                                                        <asp:HyperLinkField HeaderText="RMA No." Target="_blank" DataNavigateUrlFields="RMA_NO" 
                                                            DataNavigateUrlFormatString="http://erma.advantech.com.tw/WorkSpace/rma_display_summary.asp?rmano={0}" 
                                                            DataTextField="RMA_NO" SortExpression="RMA_NO" />
                                                        <asp:BoundField DataField="Order_Date" HeaderText="Order Date" 
                                                            SortExpression="Order_Date" />
                                                        <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="Product_Name" 
                                                            DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" DataTextField="Product_Name" Target="_blank" />  
                                                        <asp:BoundField DataField="Now_Stage" HeaderText="Status" 
                                                            SortExpression="Now_Stage" />  
                                                        <asp:BoundField DataField="Barcode" HeaderText="Barcode" 
                                                            SortExpression="Barcode" />                       
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource ID="RMASrc" runat="server" ConnectionString="<%$ ConnectionStrings:MY %>" OnSelecting="RMASrc_Selecting" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnQueryRMA" EventName="Click" />
                                                <asp:PostBackTrigger ControlID="imgRMAXls" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tab6" HeaderText="Service Requests">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">SR Name or Description:</th>
                                                <td><asp:TextBox runat="server" ID="txtSRName" Width="200px" /></td>
                                            </tr>
                                            <tr>
                                                <th align="left">Created Date:</th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender6" TargetControlID="txtSRCreateFromDate" Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender5" TargetControlID="txtSRCreateToDate" Format="yyyy/MM/dd" />
                                                    <asp:TextBox runat="server" ID="txtSRCreateFromDate" Width="80px" />&nbsp;to&nbsp;<asp:TextBox runat="server" ID="txtSRCreateToDate" Width="80px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">SR#:</th>
                                                <td><asp:TextBox runat="server" ID="txtSRNo" Width="120px" /></td>
                                            </tr>
                                            <tr>
                                                <th align="left">Model No.:</th>
                                                <td><asp:TextBox runat="server" ID="txtSRModel" Width="150px" /></td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" align="center"><asp:Button runat="server" ID="btnQuerySR" Text="Search" OnClick="btnQuerySR_Click" /></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upSR" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Timer runat="server" ID="TimerSR" Interval="8600" OnTick="TimerSR_Tick" />
                                                <center><asp:Image runat="server" ID="imgSRLoad" ImageUrl="~/Images/loading2.gif" /></center>
                                                <asp:ImageButton runat="server" ID="imgSRXls" AlternateText="Download" ImageUrl="~/Images/excel.gif" OnClick="imgSRXls_Click" />
                                                <asp:GridView PagerSettings-Position="TopAndBottom" runat="server" ID="gvSR" AutoGenerateColumns="False" Width="100%" 
                                                    AllowPaging="true" PageSize="50"
                                                    DataSourceID="SRSRc" EnableTheming="true"
                                                    RowStyle-BackColor="#FEFEFE" AlternatingRowStyle-BackColor="#DCDBDB" HeaderStyle-BackColor="#6589C3" 
                                                    BorderWidth="0" HeaderStyle-ForeColor="White" BorderStyle="None" PagerStyle-BackColor="#6589C3" OnPageIndexChanging="gvSR_PageIndexChanging" OnSorting="gvSR_Sorting">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="SR Title" DataField="SR_TITLE" SortExpression="SR_TITLE" />    
                                                        <asp:BoundField HeaderText="Description" DataField="DESC_TEXT" SortExpression="DESC_TEXT" />
                                                        <asp:BoundField HeaderText="Created Date" DataField="CREATED" SortExpression="CREATED" />
                                                        <asp:BoundField HeaderText="Created By" DataField="CREATOR_NAME" SortExpression="CREATOR_NAME" />
                                                        <asp:BoundField HeaderText="SR#" DataField="SR_NUM" SortExpression="SR_NUM" />
                                                        <asp:BoundField HeaderText="Owner" DataField="OWNER_NAME" SortExpression="OWNER_NAME" />     
                                                        <asp:BoundField HeaderText="Type" DataField="SR_TYPE" SortExpression="SR_TYPE" />  
                                                        <asp:BoundField HeaderText="Category" DataField="CATEGORY" SortExpression="CATEGORY" /> 
                                                        <asp:HyperLinkField HeaderText="Model No." DataNavigateUrlFields="MODEL_NO" 
                                                            DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" DataTextField="MODEL_NO" Target="_blank" />            
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource ID="SRSRc" runat="server" ConnectionString="<%$ ConnectionStrings:MY %>" OnSelecting="SRSRc_Selecting" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnQuerySR" EventName="Click" />
                                                <asp:PostBackTrigger ControlID="imgSRXls" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tab7" HeaderText="Warranty Expired Products">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">Shipping Date</th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="wexpdt1" TargetControlID="txtWarrantyShipFromDate" Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="wexpdt2" TargetControlID="txtWarrantyShipToDate" Format="yyyy/MM/dd" />
                                                    <asp:TextBox runat="server" ID="txtWarrantyShipFromDate" Width="80px" />~<asp:TextBox runat="server" ID="txtWarrantyShipToDate" Width="80px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">Warranty Expire Date</th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="wexpdt3" TargetControlID="txtWarrantyExpFromDate" Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="wexpdt4" TargetControlID="txtWarrantyExpToDate" Format="yyyy/MM/dd" />
                                                    <asp:TextBox runat="server" ID="txtWarrantyExpFromDate" Width="80px" />~<asp:TextBox runat="server" ID="txtWarrantyExpToDate" Width="80px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="3" align="center">
                                                    <asp:Button runat="server" ID="btnQWarranty" Text="Search" OnClick="btnQWarranty_Click" />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <td><asp:ImageButton runat="server" ID="imgXlsWarranty" ImageUrl="~/Images/excel.gif" AlternateText="Download Expired Warranty Products" OnClick="imgXlsWarranty_Click" /></td>                                                
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upWarranty" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Image runat="server" ID="imgLoadWarranty" ImageUrl="~/Images/Loading2.gif" AlternateText="Loading..." ImageAlign="Middle" />
                                                            <asp:Timer runat="server" ID="TimerWarranty" Interval="5888" OnTick="TimerWarranty_Tick" />
                                                            <asp:GridView runat="server" ID="gvWarranty" Visible="false" Width="99%" AutoGenerateColumns="false" AllowPaging="true" 
                                                                AllowSorting="true" PageSize="200" PagerSettings-Position="TopAndBottom" 
                                                                DataSourceID="SrcWarranty" OnPageIndexChanging="gvWarranty_PageIndexChanging" 
                                                                OnSorting="gvWarranty_Sorting" OnRowCreated="gvRowCreated" EnableTheming="true" 
                                                                RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" 
                                                                BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid"
                                                                PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                                                <Columns>
                                                                    <asp:HyperLinkField HeaderText="Part No." SortExpression="part_no" Target="_blank" 
                                                                        DataNavigateUrlFields="part_no" DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" 
                                                                        DataTextField="part_no" />
                                                                    <asp:BoundField HeaderText="Warranty Expire Date" DataField="warranty_date" SortExpression="warranty_date" />
                                                                    <asp:HyperLinkField HeaderText="Order No." DataNavigateUrlFields="order_no" 
                                                                        DataNavigateUrlFormatString="~/DM/SingleOrderHistory.aspx?SONO={0}" 
                                                                        DataTextField="order_no" SortExpression="order_no" Target="_blank" />
                                                                    <asp:BoundField HeaderText="Serial Number" DataField="barcode_no" SortExpression="barcode_no" />
                                                                    <asp:BoundField HeaderText="Shipping Date" DataField="shipment_date" SortExpression="shipment_date" />
                                                                </Columns>
                                                            </asp:GridView>
                                                            <asp:SqlDataSource runat="server" ID="SrcWarranty" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="SrcWarranty_Selecting" />
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="btnQWarranty" EventName="Click" />
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
                </ajaxToolkit:TabContainer>
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        setTimeout("ShowPickDivWhenPNNull();", 500);
        function ShowPickDivWhenPNNull() {
            if (document.getElementById('<%=hd_ROWID.ClientID %>').value == '') {
                document.getElementById('div_pickCust').style.display = 'block';
            }
        }        
    </script>
</asp:Content>