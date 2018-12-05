<%@ Page Title="MyAdvantech - Contact Dashboard" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>
<script runat="server">

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
    
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If MailUtil.IsInRole("IT.eBusiness") Then Response.End()
            SrcPickContact.SelectCommand = GetPickContactSql()
            If Request("ROWID") IsNot Nothing AndAlso Request("ROWID").ToString().Trim() <> "" Then
                Dim sb As New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select top 1 a.ROW_ID, a.EMAIL_ADDRESS, b.ROW_ID as account_row_id, c.COMPANY_ID  "))
                    .AppendLine(String.Format(" from SIEBEL_CONTACT a left join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID "))
                    .AppendLine(String.Format(" left join SAP_DIMCOMPANY c on b.ERP_ID=c.COMPANY_ID "))
                    .AppendLine(String.Format(" where a.ROW_ID='{0}'  ", Replace(HttpUtility.UrlDecode(Request("ROWID").ToString().Trim()), "'", "''")))
                    .AppendLine(String.Format(" order by a.ACCOUNT_STATUS "))
                End With
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
                If dt.Rows.Count = 1 Then
                    With dt.Rows(0)
                        hd_ROWID.Value = .Item("ROW_ID")
                        If .Item("EMAIL_ADDRESS") IsNot DBNull.Value Then
                            hd_EMAIL.Value = .Item("EMAIL_ADDRESS")
                        End If
                        If .Item("account_row_id") IsNot DBNull.Value Then
                            hd_ACROWID.Value = .Item("account_row_id")
                        End If
                        If .Item("COMPANY_ID") IsNot DBNull.Value Then
                            hd_ERPID.Value = .Item("COMPANY_ID")
                        End If
                    End With
                End If
            Else
                If Request("EMAIL") IsNot Nothing AndAlso Request("EMAIL").ToString().Trim() <> "" Then
                    Dim sb As New System.Text.StringBuilder
                    With sb
                        .AppendLine(String.Format(" select top 1 a.ROW_ID, a.EMAIL_ADDRESS, b.ROW_ID as account_row_id, c.COMPANY_ID  "))
                        .AppendLine(String.Format(" from SIEBEL_CONTACT a left join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID "))
                        .AppendLine(String.Format(" left join SAP_DIMCOMPANY c on b.ERP_ID=c.COMPANY_ID "))
                        .AppendLine(String.Format(" where a.EMAIL_ADDRESS='{0}'  ", Replace(HttpUtility.UrlDecode(Request("EMAIL").ToString().Trim()), "'", "''")))
                        .AppendLine(String.Format(" order by a.ACCOUNT_STATUS "))
                    End With
                    Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
                    If dt.Rows.Count = 1 Then
                        With dt.Rows(0)
                            hd_ROWID.Value = .Item("ROW_ID")
                            If .Item("EMAIL_ADDRESS") IsNot DBNull.Value Then
                                hd_EMAIL.Value = .Item("EMAIL_ADDRESS")
                            End If
                            If .Item("account_row_id") IsNot DBNull.Value Then
                                hd_ACROWID.Value = .Item("account_row_id")
                            End If
                            If .Item("COMPANY_ID") IsNot DBNull.Value Then
                                hd_ERPID.Value = .Item("COMPANY_ID")
                            End If
                        End With
                    End If
                End If
            End If
            hd_EMAIL.Value = Replace(hd_EMAIL.Value, "'", "")
            If hd_ROWID.Value <> "" Then
                Me.txtActCreateFrom.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd")
                Me.txtActCreateTo.Text = Now.ToString("yyyy/MM/dd")
                Me.txtOptyCDateFrom.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd")
                Me.txtOptyCDateTo.Text = Now.ToString("yyyy/MM/dd")
                srcProf.SelectCommand = GetProfSql()
                TimerAct.Enabled = True : TimerOpty.Enabled = True
                If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(*) as c from ESTORE_MEMBER where EMAIL_ADDR='{0}'", hd_EMAIL.Value))) > 0 Then
                    tab4.Visible = True : TimerOrder.Enabled = True
                    txtOrderFrom.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd") : txtOrderTo.Text = Now.ToString("yyyy/MM/dd")
                Else
                    tab4.Visible = False : TimerOrder.Enabled = False
                End If
            End If
        End If
    End Sub
    
    Protected Sub gvPickContact_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SrcPickContact.SelectCommand = GetPickContactSql()
    End Sub

    Protected Sub gvPickContact_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SrcPickContact.SelectCommand = GetPickContactSql()
    End Sub
    
    Function GetPickContactSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 500 a.ROW_ID, a.FirstName, a.LastName, a.EMAIL_ADDRESS,  "))
            .AppendLine(String.Format(" a.JOB_TITLE, IsNull(b.ACCOUNT_NAME, a.account) as account_name, b.PRIMARY_SALES_EMAIL,  "))
            .AppendLine(String.Format(" IsNull(b.RBU,a.OrgId) as RBU, IsNull(b.ROW_ID,'') as ACCOUNT_ROW_ID,  "))
            .AppendLine(String.Format(" b.COUNTRY, b.CITY, b.STATE, b.ZIPCODE    "))
            .AppendLine(String.Format(" from SIEBEL_CONTACT a left join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID  "))
            .AppendLine(String.Format(" where 1=1 "))
            If txtPickAccName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.account like N'%{0}%' ", txtPickAccName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtpickContact.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.FirstName like N'%{0}%' or a.LastName like N'%{0}%' or a.FirstName+''+a.LastName like N'%{0}%' or a.LastName+''+a.FirstName like N'%{0}%') ", txtpickContact.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtPickEmail.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.EMAIL_ADDRESS like N'%{0}%' ", txtPickEmail.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtPickRBU.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.OrgId like '%{0}%') ", txtPickAccName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by a.EMAIL_ADDRESS desc  "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub btnSearchContact_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvPickContact.PageIndex = 0 : SrcPickContact.SelectCommand = GetPickContactSql()
    End Sub
    
    Function GetProfSql() As String
        If hd_ROWID.Value = "" Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT a.ROW_ID, a.FirstName, a.MiddleName, a.LastName, a.WorkPhone, a.CellPhone, a.FaxNumber, a.JOB_FUNCTION, a.OrgID, a.CanSeeOrder,  "))
            .AppendLine(String.Format(" a.NeverEmail, a.NeverCall, a.NeverFax, a.NeverMail, a.JOB_TITLE, a.EMAIL_ADDRESS, a.ACCOUNT, a.ACCOUNT_TYPE, a.ACCOUNT_STATUS,  "))
            .AppendLine(String.Format(" a.COUNTRY, a.Salutation, a.EMPLOYEE_FLAG, a.ACTIVE_FLAG, a.USER_TYPE, a.REG_SOURCE, a.CREATED, a.LAST_UPDATED,  "))
            .AppendLine(String.Format(" b.COUNTRY AS Account_Country, b.RBU, b.CITY, a.ACCOUNT_ROW_ID, b.STATE,  b.ACCOUNT_TYPE, b.ZIPCODE, b.PROVINCE, b.PRIMARY_SALES_EMAIL "))
            .AppendLine(String.Format(" FROM SIEBEL_CONTACT AS a LEFT OUTER JOIN SIEBEL_ACCOUNT AS b ON a.ACCOUNT_ROW_ID = b.ROW_ID "))
            .AppendLine(String.Format(" WHERE (a.ROW_ID = '{0}' " + IIf(hd_EMAIL.Value <> "", " or a.EMAIL_ADDRESS='" + hd_EMAIL.Value + "' ", "") + " ) ", hd_ROWID.Value))
            .AppendLine(String.Format(" ORDER BY a.ROW_ID "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub gvProf_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim rrid As String = CType(e.Row.FindControl("hd_RowROWID"), HiddenField).Value
            Dim srcBaa As SqlDataSource = e.Row.FindControl("srcRowBAA")
            Dim srcNews As SqlDataSource = e.Row.FindControl("srcRowENews")
            Dim srcIP As SqlDataSource = e.Row.FindControl("srcRowIP")
            Dim srcPrivi As SqlDataSource = e.Row.FindControl("srcRowPrivi")
            srcBaa.SelectParameters("RID").DefaultValue = rrid
            srcNews.SelectParameters("RID").DefaultValue = rrid
            srcIP.SelectParameters("RID").DefaultValue = rrid
            srcPrivi.SelectParameters("RID").DefaultValue = rrid
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.Master.LogoImgPath = "~/Images/dm_logo.JPG"
            If hd_ROWID.Value <> "" Or hd_EMAIL.Value <> "" Then
                If MailUtil.IsInRole("DMF.eCoverage") = False AndAlso MailUtil.IsInRole("ATWCallCenter") = False _
                   AndAlso MailUtil.IsInRole("DIRECTOR.ACL") = False AndAlso Util.IsAEUIT() = False Then
                    Dim csb As New System.Text.StringBuilder
                    With csb
                        .AppendLine(String.Format(" select top 1 a.ROW_ID, a.EMAIL_ADDRESS, c.OWNER_ID, d.EMAIL_ADDRESS    "))
                        .AppendLine(String.Format(" from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID  "))
                        .AppendLine(String.Format(" inner join SIEBEL_ACCOUNT_OWNER c on b.ROW_ID=c.ACCOUNT_ROW_ID inner join SIEBEL_CONTACT d on c.OWNER_ID=d.ROW_ID  "))
                        .AppendLine(String.Format(" where (a.ROW_ID='1+AA+1029' or a.EMAIL_ADDRESS='kwafer@houstonoverseas.com') and d.EMAIL_ADDRESS='lawrence.liang@advantech.com' "))
                    End With
                    'dbUtil.dbExecuteScalar("MY", "")
                End If
            End If
        End If
    End Sub

    Protected Sub TimerAct_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            srcAct.SelectCommand = GetActSql()
        Catch ex As Exception
        End Try
        imgLoadAct.Visible = False : gvAct.Visible = True : TimerAct.Interval = 99999 : TimerAct.Enabled = False
    End Sub
    
    Function GetActSql() As String
        If hd_ROWID.Value = "" Then Return ""
        Dim actFrom As Date = DateAdd(DateInterval.Month, -6, Now), actTo As Date = Now
        If Date.TryParse(txtActCreateFrom.Text, Now) Then actFrom = CDate(txtActCreateFrom.Text)
        If Date.TryParse(txtActCreateTo.Text, Now) Then actTo = CDate(txtActCreateTo.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT top 1000 a.ROW_ID, a.APPT_START_DT, a.CAL_TYPE_CD, a.EVT_STAT_CD, a.NAME,  "))
            .AppendLine(String.Format(" a.OWNER_LOGIN, a.BU_NAME, a.SRA_SR_ID, a.CREATED, a.LAST_UPD,  "))
            .AppendLine(String.Format(" a.TARGET_OU_ID, a.TODO_CD, a.OPTY_ID, a.CREATED_BY, a.OWNER_PER_ID,  "))
            .AppendLine(String.Format(" a.Sales_leads, a.COMMENTS_LONG, a.TODO_PLAN_START_DT,  "))
            .AppendLine(String.Format(" a.CAMP_ID, a.TARGET_PER_ID, a.CREATE_YEAR, a.ERP_ID "))
            .AppendLine(String.Format(" FROM SIEBEL_ACTIVITY AS a "))
            .AppendLine(String.Format(" WHERE a.TARGET_PER_ID = '{0}' AND a.CREATE_YEAR >= {1} AND a.CREATED BETWEEN '{2}' AND '{3}' ", _
                                      hd_ROWID.Value, actFrom.Year.ToString(), actFrom.ToString("yyyy-MM-dd"), actTo.ToString("yyyy-MM-dd")))
            If txtActName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.NAME like N'%{0}%' or a.COMMENTS_LONG like N'%{0}%') ", _
                   Replace(Replace(txtActName.Text, "'", "''"), "*", "%").Trim()))
            End If
            If txtActType.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.TODO_CD like N'%{0}%' ", Replace(Replace(txtActType.Text, "'", "''"), "*", "%").Trim()))
            End If
            .AppendLine(String.Format(" ORDER BY a.CREATED DESC "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub btnQAct_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvAct.PageIndex = 0 : srcAct.SelectCommand = GetActSql()
    End Sub
    
    Protected Sub gvAct_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        srcAct.SelectCommand = GetActSql()
    End Sub

    Protected Sub gvAct_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        srcAct.SelectCommand = GetActSql()
    End Sub

    Protected Sub TimerEDM_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerEDM.Interval = 99999 : TimerEDM.Enabled = False
        If hd_EMAIL.Value = "" Then Exit Sub
        'Try
        '    Dim ws As New eCampaign_New.EC
        '    ws.UseDefaultCredentials = True
        '    Dim dt As DataTable = ws.GetMyEDM(Me.hd_EMAIL.Value)
        '    gvEDM.DataSource = dt : gvEDM.DataBind()
        'Catch ex As Exception
        '    MailUtil.SendDebugMsg("global MA load contact EDM", ex.ToString(), "tc.chen@advantech.com.tw")
        'End Try
        imgLoadEDM.Visible = False : gvEDM.Visible = True
    End Sub

    Protected Sub TimerOpty_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerOpty.Interval = 99999 : TimerOpty.Enabled = False
        Try
            srcOpty.SelectCommand = GetOptySql()
        Catch ex As Exception
            MailUtil.SendDebugMsg("global MA load Opty error", ex.ToString(), "tc.chen@advantech.com.tw")
        End Try
        imgLoadOpty.Visible = False : gvOpty.Visible = True
    End Sub
    
    Function GetOptySql() As String
        If hd_ROWID.Value = "" Then Return ""
        Dim cfrom As Date = DateAdd(DateInterval.Month, -3, Now)
        Dim cto As Date = Now
        If txtOptyCDateFrom.Text.Trim() <> "" AndAlso Date.TryParse(txtOptyCDateFrom.Text, Now) Then cfrom = CDate(txtOptyCDateFrom.Text)
        If txtOptyCDateTo.Text.Trim() <> "" AndAlso Date.TryParse(txtOptyCDateTo.Text, Now) Then cto = CDate(txtOptyCDateTo.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT TOP 100 a.ROW_ID, a.ACCOUNT_ROW_ID, a.NAME, a.SUM_REVN_AMT, a.REVENUE_US_AMT, cast(a.SUM_WIN_PROB as numeric(4,0)) as SUM_WIN_PROB, a.CURR_STG_ID,  "))
            .AppendLine(String.Format(" a.STAGE_NAME, a.BU_ID, a.BU_NAME, a.CREATED, a.CREATED_BY_LOGIN, a.CREATED_BY_NAME, a.CURCY_CD as currency, a.DESC_TEXT, a.LAST_UPD,  "))
            .AppendLine(String.Format(" a.LAST_UPD_BY_LOGIN, a.LAST_UPD_BY_NAME, a.PR_POSTN_ID, a.POSTN_TYPE_CD, a.PR_PROD_ID, a.REASON_WON_LOST_CD, a.STATUS_CD,  "))
            .AppendLine(String.Format(" a.STG_NAME, a.SALES_TEAM_LOGIN, a.SALES_TEAM_NAME, a.MODIFICATION_NUM, a.SUM_EFFECTIVE_DT, a.PAR_OPTY_ID, a.EXPECT_VAL,  "))
            .AppendLine(String.Format(" a.FACTOR, a.CONTACT, a.CONTACT_ROW_ID, a.SALES_METHOD_ID, a.SALES_METHOD_NAME, a.Assign_To_Partner, a.BusinessGroup,  "))
            .AppendLine(String.Format(" a.Incentive_For_RBU, a.Indicator, a.Product_Revenue, a.Profile_Revenue, a.Quantity, a.Channel, a.PR_EMP_ID, a.PR_DEPT_OU_ID, a.CREATE_YEAR,  "))
            .AppendLine(String.Format(" a.PR_PRTNR_ID, a.PART_NO, a.ChannelContact, a.Primary_Opty_BAA "))
            .AppendLine(String.Format(" FROM SIEBEL_OPPORTUNITY AS a INNER JOIN SIEBEL_ACCOUNT AS b ON a.ACCOUNT_ROW_ID = b.ROW_ID "))
            .AppendLine(String.Format(" WHERE a.CONTACT_ROW_ID = '{0}'  ", hd_ROWID.Value))
            .AppendLine(String.Format(" AND a.CREATE_YEAR >= {0} AND a.CREATED BETWEEN '{1}' AND '{2}' ", _
                                      cfrom.Year.ToString(), cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            If txtOptyName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.NAME like N'%{0}%' or a.DESC_TEXT like N'%{0}%') ", _
                                          txtOptyName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by a.CREATED desc "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub btnQOpty_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvOpty.PageIndex = 0 : srcOpty.SelectCommand = GetOptySql()
    End Sub

   
    Protected Sub gvOpty_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        srcOpty.SelectCommand = GetOptySql()
    End Sub

    Protected Sub gvOpty_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        srcOpty.SelectCommand = GetOptySql()
    End Sub
    
    Function GetBuyOrderSql() As String
        If hd_EMAIL.Value = "" Then Return ""
        Dim cfrom As Date = DateAdd(DateInterval.Month, -6, Now)
        Dim cto As Date = Now
        If txtOrderFrom.Text.Trim() <> "" AndAlso Date.TryParse(txtOrderFrom.Text, Now) Then cfrom = CDate(txtOrderFrom.Text)
        If txtOrderTo.Text.Trim() <> "" AndAlso Date.TryParse(txtOrderTo.Text, Now) Then cto = CDate(txtOrderTo.Text)
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT top 1000 a.Store_Id, a.ORDER_ID, a.ORDER_NO, a.ORDER_TYPE, a.PO_NO, a.User_ID, a.SOLDTO_ID, a.SHIPTO_ID, a.BILLTO_ID, a.SALES_ID,  "))
            .AppendLine(String.Format(" a.ORDER_DATE, a.PAYMENT_TYPE, a.ATTENTION, a.PARTIAL_FLAG, a.COMBINE_ORDER_FLAG, a.EARLY_SHIP_FLAG, a.FREIGHT, a.INSURANCE,  "))
            .AppendLine(String.Format(" a.TAX, a.REMARK, a.PRODUCT_SITE, dbo.DateOnly(a.DUE_DATE) as DUE_DATE, a.REQUIRED_DATE, a.SHIPMENT_TERM, a.SHIP_VIA, a.CURRENCY, a.ORDER_NOTE,  "))
            .AppendLine(String.Format(" a.ORDER_STATUS, a.TOTAL_AMOUNT, a.TOTAL_LINE, a.LAST_UPDATED, a.CREATED_DATE, a.CREATED_BY, a.CUSTOMER_ATTENTION,  "))
            .AppendLine(String.Format(" a.AUTO_ORDER_FLAG, a.Payment_ID, a.Reseller_ID, a.CBOM_MESSAGE, a.ChannelName, a.CartID, a.LINE_NO, a.PRODUCT_LINE, a.PART_NO,  "))
            .AppendLine(String.Format(" a.ORDER_LINE_TYPE, a.QTY, cast(a.LIST_PRICE as numeric(18,2)) as LIST_PRICE, cast(a.UNIT_PRICE as numeric(18,2)) as UNIT_PRICE, a.Line_Required_Date, a.Line_Due_Date, a.PARENT_LINE_NO, a.id "))
            .AppendLine(String.Format(" FROM ESTORE_ORDER_LOG AS a "))
            .AppendLine(String.Format(" WHERE a.User_ID = '{0}' ", hd_EMAIL.Value))
            .AppendLine(String.Format(" and a.ORDER_DATE between '{0}' and '{1}' ", cfrom.ToString("yyyy/MM/dd"), cto.ToString("yyyy/MM/dd")))
            If txtOrderPN.Text.Trim() <> "" Then
                .AppendLine(String.Format("and a.part_no like '%{0}%'  ", Replace(Replace(txtOrderPN.Text, "'", "''"), "*", "%").Trim()))
            End If
            If txtOrderNo.Text.Trim() <> "" Then
                .AppendLine(String.Format("and a.ORDER_NO like '%{0}%'  ", Replace(Replace(txtOrderNo.Text, "'", "''"), "*", "%").Trim()))
            End If
            .AppendLine(String.Format(" ORDER BY a.ORDER_DATE DESC, a.LINE_NO "))
        End With
        Return sb.ToString()
    End Function
    
    Protected Sub TimerOrder_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerOrder.Interval = 99999 : TimerOrder.Enabled = False
        Try
            srcOrder.SelectCommand = GetBuyOrderSql()
        Catch ex As Exception

        End Try
        imgLoadOrder.Visible = False : gvOrder.Visible = True
    End Sub

    Protected Sub btnQBuyOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvOrder.PageIndex = 0 : srcOrder.SelectCommand = GetBuyOrderSql()
    End Sub

    Protected Sub gvOrder_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        srcOrder.SelectCommand = GetBuyOrderSql()
    End Sub

    Protected Sub gvOrder_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        srcOrder.SelectCommand = GetBuyOrderSql()
    End Sub

    Protected Sub src_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub
       
    Protected Sub btnGetEDM_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        btnGetEDM.Visible = False : TimerEDM.Enabled = True : imgLoadEDM.Visible = True
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript">
        function ShowHide() {
            var div = document.getElementById('div_pickContact');
            if (div.style.display == 'block') {
                div.style.display = 'none';
            }
            else {
                div.style.display = 'block';
            }
        } 
    </script>
    <asp:HiddenField runat="server" ID="hd_ROWID" />
    <asp:HiddenField runat="server" ID="hd_EMAIL" />
    <asp:HiddenField runat="server" ID="hd_ERPID" />
    <asp:HiddenField runat="server" ID="hd_ACROWID" />
    <asp:LinkButton runat="server" ID="lnkPickContact" Font-Bold="true" Font-Size="Larger" Text="Pick Contact" OnClientClick="ShowHide(); return false;" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <div id="div_pickContact" style="display:none; position:absolute;left:20px;top:100px; 
        background-color:white;border: solid 1px silver;padding:10px; 
        width:95%; height:420px;overflow:auto;">
        <table width="95%">
            <tr>
                <td colspan="3" align="center"><asp:LinkButton runat="server" ID="lnkClosepickContact" Text="Close" Font-Bold="true" OnClientClick="ShowHide(); return false;" /></td>
            </tr>
            <tr>
                <td align="center">
                    <asp:Panel runat="server" ID="panelSearhpickContact" DefaultButton="btnSearchContact">
                        <table>
                            <tr>
                                <th align="left">Contact Name:</th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtpickContact" Width="150px" />
                                </td>
                                <th align="left">Email:</th>
                                <td><asp:TextBox runat="server" ID="txtPickEmail" Width="200px" /></td>
                            </tr>
                            <tr>
                                <th align="left">RBU:</th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtPickRBU" Width="150px" />
                                </td>
                                <th align="left">Account Name:</th>
                                <td>
                                    <asp:TextBox runat="server" ID="txtPickAccName" Width="150px" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4" align="center">
                                    <asp:Button runat="server" ID="btnSearchContact" Text="Search" OnClick="btnSearchContact_Click" />
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>                                
                </td>
            </tr>
            <tr>
                <td align="center">     
                    <asp:UpdatePanel runat="server" ID="upPickContact" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:GridView runat="server" ID="gvPickContact" Width="95%" AutoGenerateColumns="false" DataSourceID="SrcPickContact" 
                                PagerSettings-Position="TopAndBottom" PageSize="50" AllowPaging="true" AllowSorting="true" 
                                EmptyDataText="No Search Result" OnPageIndexChanging="gvPickContact_PageIndexChanging" 
                                OnSorting="gvPickContact_Sorting" OnRowCreated="gvRowCreated">
                                <Columns>
                                    <asp:HyperLinkField HeaderText="ROW ID" DataNavigateUrlFields="ROW_ID" SortExpression="ROW_ID" 
                                        DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="ROW_ID" />
                                    <asp:HyperLinkField HeaderText="Email" DataNavigateUrlFields="EMAIL_ADDRESS" SortExpression="EMAIL_ADDRESS" 
                                        DataNavigateUrlFormatString="ContactDashboard.aspx?EMAIL={0}" DataTextField="EMAIL_ADDRESS" />
                                    <asp:HyperLinkField HeaderText="First Name" DataNavigateUrlFields="ROW_ID" SortExpression="FirstName" 
                                        DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="FirstName" />
                                    <asp:HyperLinkField HeaderText="Last Name" DataNavigateUrlFields="ROW_ID" SortExpression="LastName" 
                                        DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="LastName" />
                                    <asp:HyperLinkField HeaderText="Job Title" DataNavigateUrlFields="ROW_ID" SortExpression="JOB_TITLE" 
                                        DataNavigateUrlFormatString="ContactDashboard.aspx?ROWID={0}" DataTextField="JOB_TITLE" />
                                    <asp:BoundField HeaderText="RBU" DataField="RBU" SortExpression="RBU" />
                                    <asp:HyperLinkField HeaderText="Account" DataNavigateUrlFields="account_row_id" SortExpression="account_name" 
                                        DataNavigateUrlFormatString="CustomerDashboard.aspx?ROWID={0}" DataTextField="account_name" />
                                    <asp:BoundField HeaderText="Sales Rep." DataField="PRIMARY_SALES_EMAIL" SortExpression="PRIMARY_SALES_EMAIL" />
                                </Columns>
                            </asp:GridView>
                            <asp:SqlDataSource runat="server" ID="SrcPickContact" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnSearchContact" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>     
                </td>
            </tr>
        </table>
    </div> 
    <ajaxToolkit:TabContainer runat="server" ID="tabcon1" Width="100%">
        <ajaxToolkit:TabPanel runat="server" ID="tab1" HeaderText="Contact Profile">
            <ContentTemplate>
                <asp:GridView runat="server" ID="gvProf" Width="99%" AutoGenerateColumns="false" 
                    ShowHeader="false" DataSourceID="srcProf" OnRowDataBound="gvProf_RowDataBound">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:HiddenField runat="server" ID="hd_RowROWID" Value='<%#Eval("ROW_ID") %>' />
                                <table width="100%">
                                    <tr>
                                        <th align="left" colspan="4" style="border-style:groove">ROW ID:<%# Eval("ROW_ID")%></th>
                                    </tr>
                                    <tr valign="top">
                                        <th align="left" style="width:25%">Email</th>
                                        <th align="left" style="width:25%">First Name</th>
                                        <th align="left" style="width:25%">Middle Name</th>
                                        <th align="left" style="width:25%">Last Name</th>
                                    </tr>
                                    <tr valign="top">
                                        <td style="width:25%"><%# Eval("EMAIL_ADDRESS")%></td>
                                        <td style="width:25%"><%# Eval("FirstName")%></td>
                                        <td style="width:25%"><%# Eval("MiddleName")%></td>
                                        <td style="width:25%"><%# Eval("LastName")%></td>
                                    </tr>
                                    <tr valign="top">
                                        <th align="left" style="width:25%">Account</th>
                                        <th align="left" style="width:25%">Account Status</th>
                                        <th align="left" style="width:25%">Account Type</th>
                                        <th align="left" style="width:25%">Account Country</th>
                                    </tr>
                                    <tr valign="top">
                                        <td style="width:25%"><a target="_blank" href='CustomerDashboard.aspx?ROWID=<%#Eval("account_row_id") %>'><%# Eval("Account")%></a></td>
                                        <td style="width:25%"><%# Eval("account_status")%></td>
                                        <td style="width:25%"><%# Eval("account_type")%></td>
                                        <td style="width:25%"><%# Eval("Account_Country")%></td>
                                    </tr>
                                    <tr valign="top">
                                        <th align="left" style="width:25%">Work Phone</th>
                                        <th align="left" style="width:25%">Cell Phone</th>
                                        <th align="left" style="width:25%">Fax Number</th>
                                        <th align="left" style="width:25%">Job Function</th>
                                    </tr>
                                    <tr valign="top">
                                        <td style="width:25%"><%# Eval("WorkPhone")%></td>
                                        <td style="width:25%"><%# Eval("CellPhone")%></td>
                                        <td style="width:25%"><%# Eval("FaxNumber")%></td>
                                        <td style="width:25%"><%# Eval("JOB_FUNCTION")%></td>
                                    </tr>
                                    <tr valign="top">
                                        <th align="left" style="width:25%">Job Title</th>
                                        <th align="left" style="width:25%">Contact Org.</th>
                                        <th align="left" style="width:25%">Account Org.</th>
                                        <th align="left" style="width:25%">Never Email?</th>                                        
                                    </tr>
                                    <tr valign="top">
                                        <td style="width:25%"><%# Eval("JOB_TITLE")%></td>
                                        <td style="width:25%"><%# Eval("OrgID")%></td>
                                        <td style="width:25%"><%# Eval("RBU")%></td>
                                        <td style="width:25%"><%# Eval("NeverEmail")%></td>
                                    </tr>
                                    <tr valign="top">
                                        <th align="left" colspan="4">Primary Sales Rep.</th>
                                    </tr>
                                    <tr>
                                        <td colspan="4"><a href='mailto:<%#Eval("PRIMARY_SALES_EMAIL") %>'><%# Eval("PRIMARY_SALES_EMAIL")%></a></td>
                                    </tr>
                                    <tr valign="top">
                                        <th align="left">Interested eNews</th>
                                        <th align="left">Interested Products</th>
                                        <th align="left">BAA</th>
                                        <th align="left">MyAdvantech Priviledge</th>
                                    </tr>
                                    <tr valign="top">
                                        <td>
                                            <asp:Panel runat="server" ID="panRowENews" Width="100%" Height="150px" ScrollBars="Auto">
                                                <asp:GridView runat="server" ID="gvRowENews" Width="100%" AutoGenerateColumns="false" DataSourceID="srcRowENews" EmptyDataText="N/A">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="eNews Name" DataField="Name" />
                                                        <asp:BoundField HeaderText="Primary Flag" DataField="PRIMARY_FLAG" ItemStyle-HorizontalAlign="Center" />
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="srcRowENews" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" 
                                                    SelectCommand="select name, case primary_flag when 1 then 'Y' else 'N' end as primary_flag from SIEBEL_CONTACT_INTERESTED_ENEWS where CONTACT_ROW_ID=@RID order by NAME">
                                                    <SelectParameters>
                                                        <asp:Parameter ConvertEmptyStringToNull="false" Name="RID" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>  
                                            </asp:Panel>                                            
                                        </td>
                                        <td>
                                            <asp:Panel runat="server" ID="panRowIP" Width="100%" Height="150px" ScrollBars="Auto">
                                                <asp:GridView runat="server" ID="gvRowIP" Width="100%" AutoGenerateColumns="false" DataSourceID="srcRowIP" EmptyDataText="N/A">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="Product" DataField="Name" />
                                                        <asp:BoundField HeaderText="Primary Flag" DataField="PRIMARY_FLAG" ItemStyle-HorizontalAlign="Center" />
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="srcRowIP" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" 
                                                    SelectCommand="select name, case primary_flag when 1 then 'Y' else 'N' end as primary_flag from SIEBEL_CONTACT_INTERESTED_PRODUCT where CONTACT_ROW_ID=@RID order by NAME">
                                                    <SelectParameters>
                                                        <asp:Parameter ConvertEmptyStringToNull="false" Name="RID" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>
                                            </asp:Panel>                                             
                                        </td>
                                        <td>
                                            <asp:Panel runat="server" ID="panRowBAA" Width="100%" Height="150px" ScrollBars="Auto">
                                                <asp:GridView runat="server" ID="gvRowBAA" Width="100%" AutoGenerateColumns="false" DataSourceID="srcRowBAA" EmptyDataText="N/A">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="BAA" DataField="Name" />
                                                        <asp:BoundField HeaderText="Primary Flag" DataField="PRIMARY_FLAG" ItemStyle-HorizontalAlign="Center" />
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="srcRowBAA" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" 
                                                    SelectCommand="select name, case primary_flag when 1 then 'Y' else 'N' end as primary_flag from SIEBEL_CONTACT_BAA where CONTACT_ROW_ID=@RID order by NAME">
                                                    <SelectParameters>
                                                        <asp:Parameter ConvertEmptyStringToNull="false" Name="RID" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>
                                            </asp:Panel>                                             
                                        </td>
                                        <td>
                                            <asp:Panel runat="server" ID="panRowPrivi" Width="100%" Height="150px" ScrollBars="Auto">
                                                <asp:GridView runat="server" ID="gvRowPrivi" Width="100%" AutoGenerateColumns="false" DataSourceID="srcRowPrivi" EmptyDataText="N/A">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="Privilege" DataField="PRIVILEGE" />
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="srcRowPrivi" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" 
                                                    SelectCommand="select PRIVILEGE from SIEBEL_CONTACT_PRIVILEGE where ROW_ID=@RID order by PRIVILEGE">
                                                    <SelectParameters>
                                                        <asp:Parameter ConvertEmptyStringToNull="false" Name="RID" />
                                                    </SelectParameters>
                                                </asp:SqlDataSource>
                                            </asp:Panel>                                             
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="srcProf" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" />
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tab2" HeaderText="Activity & eDM">
            <ContentTemplate>
                <table width="100%">
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="panQAct" DefaultButton="btnQAct">
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
                                        <td><asp:TextBox runat="server" ID="txtActName" Width="200px" /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Type:</th>
                                        <td><asp:TextBox runat="server" ID="txtActType" Width="200px" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" align="center">
                                            <asp:Button runat="server" ID="btnQAct" Text="Search" OnClick="btnQAct_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>                            
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upAct" UpdateMode="Conditional">
                                <ContentTemplate>                                    
                                    <asp:Image runat="server" ID="imgLoadAct" ImageUrl="~/Images/Loading2.gif" />
                                    <asp:Timer runat="server" ID="TimerAct" Interval="200" Enabled="false" OnTick="TimerAct_Tick" />
                                    <asp:GridView runat="server" ID="gvAct" Width="99%" AutoGenerateColumns="false" 
                                    Visible="false" EmptyDataText="No Data" DataSourceID="srcAct" AllowPaging="true" AllowSorting="true" PageSize="50" 
                                    OnPageIndexChanging="gvAct_PageIndexChanging" OnSorting="gvAct_Sorting" OnRowCreated="gvRowCreated">
                                        <Columns>
                                            <asp:BoundField HeaderText="Name" DataField="NAME" SortExpression="NAME" />
                                            <asp:BoundField HeaderText="Created Date" DataField="CREATED" SortExpression="CREATED" />
                                            <asp:BoundField HeaderText="Type" DataField="TODO_CD" SortExpression="TODO_CD" />
                                            <asp:BoundField HeaderText="Owner" DataField="OWNER_LOGIN" SortExpression="OWNER_LOGIN" />
                                            <asp:BoundField HeaderText="Comment" DataField="COMMENTS_LONG" SortExpression="COMMENTS_LONG" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="srcAct" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnQAct" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr><td><hr /></td></tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upEDM" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Button runat="server" ID="btnGetEDM" Text="Check eDM Sent to this contact" OnClick="btnGetEDM_Click" Visible="false" />
                                    <asp:Image runat="server" ID="imgLoadEDM" ImageUrl="~/Images/Loading2.gif" Visible="false" />
                                    <asp:Timer runat="server" ID="TimerEDM" Interval="2000" OnTick="TimerEDM_Tick" />
                                    <asp:GridView runat="server" ID="gvEDM" AutoGenerateColumns="false" Visible="false">
                                        <Columns>
                                            <asp:HyperLinkField HeaderText="eDM Subject" SortExpression="email_subject" 
                                                DataNavigateUrlFields="row_id,contact_email"
                                                DataNavigateUrlFormatString="~/Includes/GetTemplate.ashx?Rowid={0}&Email={1}" 
                                                Target="_blank" DataTextField="email_subject" />
                                            <asp:BoundField HeaderText="Send Time" DataField="email_send_time" SortExpression="email_send_time" />
                                            <asp:BoundField HeaderText="eDM Opened?" DataField="email_isopened" SortExpression="email_isopened" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Sent By" DataField="created_by" SortExpression="created_by" />
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel> 
        <ajaxToolkit:TabPanel runat="Server" ID="tab3" HeaderText="Opportunity">
            <ContentTemplate>
                <table width="100%">
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="PanQOpty" DefaultButton="btnQOpty">
                                <table>
                                    <tr>
                                        <th align="left">Name/Comment:</th>
                                        <td><asp:TextBox runat="server" ID="txtOptyName" Width="200px" /></td>
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
                                        <td colspan="2" align="center">
                                            <asp:Button runat="server" ID="btnQOpty" Text="Search" OnClick="btnQOpty_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>                            
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upOpty" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Image runat="server" ID="imgLoadOpty" ImageUrl="~/Images/Loading2.gif" />
                                    <asp:Timer runat="server" ID="TimerOpty" Interval="4000" Enabled="false" OnTick="TimerOpty_Tick" />
                                    <asp:GridView runat="server" ID="gvOpty" Width="99%" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" 
                                    Visible="false" EmptyDataText="No Data" DataSourceID="srcOpty" OnPageIndexChanging="gvOpty_PageIndexChanging" 
                                    OnSorting="gvOpty_Sorting" OnRowCreated="gvRowCreated" PageSize="50">
                                        <Columns>
                                            <asp:BoundField HeaderText="Project Name" DataField="NAME" SortExpression="NAME" />
                                            <asp:BoundField HeaderText="Created Date" DataField="CREATED" SortExpression="CREATED" />                         
                                            <asp:TemplateField HeaderText="Total Revenue" SortExpression="Total Revenue" ItemStyle-HorizontalAlign="Right">
                                                <ItemTemplate>
                                                    <%# Util.FormatMoney(Eval("SUM_REVN_AMT"), Eval("currency"))%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="Status" DataField="STATUS_CD" SortExpression="STATUS_CD" ItemStyle-HorizontalAlign="Center" />
                                            <asp:TemplateField HeaderText="Probability (%)" SortExpression="SUM_WIN_PROB" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%# Eval("SUM_WIN_PROB").ToString() + "%"%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="srcOpty" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnQOpty" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="Server" ID="tab4" HeaderText="eStore Order History">
            <ContentTemplate>
                <table width="100%">
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="PanQOrder" DefaultButton="btnQBuyOrder">
                                <table>
                                    <tr>
                                        <th align="left">Order Date:</th>
                                        <td>
                                            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender3" TargetControlID="txtOrderFrom" Format="yyyy/MM/dd" />
                                            <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender4" TargetControlID="txtOrderTo" Format="yyyy/MM/dd" />                                        
                                            <asp:TextBox runat="server" ID="txtOrderFrom" Width="80px" />~<asp:TextBox runat="server" ID="txtOrderTo" Width="80px" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <th align="left">Order No.</th>
                                        <td><asp:TextBox runat="server" ID="txtOrderNo" Width="120px" /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Part No.</th>
                                        <td><asp:TextBox runat="server" ID="txtOrderPN" Width="150px" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" align="center">
                                            <asp:Button runat="server" ID="btnQBuyOrder" Text="Search" OnClick="btnQBuyOrder_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>                            
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="upOrder" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Image runat="server" ID="imgLoadOrder" ImageUrl="~/Images/Loading2.gif" />
                                    <asp:Timer runat="server" ID="TimerOrder" Interval="6000" Enabled="false" OnTick="TimerOrder_Tick" />
                                    <asp:GridView runat="server" ID="gvOrder" Width="99%" AutoGenerateColumns="false" 
                                        Visible="false" EmptyDataText="No Data" DataSourceID="srcOrder" OnRowCreated="gvRowCreated" 
                                        OnPageIndexChanging="gvOrder_PageIndexChanging" OnSorting="gvOrder_Sorting" 
                                        AllowPaging="true" AllowSorting="true" PageSize="50">
                                        <Columns>
                                            <asp:BoundField HeaderText="Order No." DataField="order_no" SortExpression="order_no" />
                                            <asp:BoundField HeaderText="Order Type" DataField="order_type" SortExpression="order_type" />
                                            <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="part_no" 
                                                DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" 
                                                DataTextField="part_no" Target="_blank" SortExpression="part_no" />
                                            <asp:BoundField HeaderText="Line No." DataField="line_no" SortExpression="line_no" />
                                            <asp:BoundField HeaderText="Order Date" DataField="order_date" SortExpression="order_date" />
                                            <asp:BoundField HeaderText="Due Date" DataField="due_date" SortExpression="due_date" />
                                            <asp:BoundField HeaderText="Currency" DataField="currency" SortExpression="currency" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Qty." DataField="qty" SortExpression="qty" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="List Price" DataField="list_price" SortExpression="list_price" ItemStyle-HorizontalAlign="Right" />
                                            <asp:BoundField HeaderText="Unit Price" DataField="unit_price" SortExpression="unit_price" ItemStyle-HorizontalAlign="Right" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="srcOrder" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src_Selecting" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnQBuyOrder" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
    </ajaxToolkit:TabContainer>
    <script type="text/javascript">
        setTimeout("ShowPickDivWhenPNNull();", 500);
        function ShowPickDivWhenPNNull() {
            if (document.getElementById('<%=hd_ROWID.ClientID %>').value == '') {
                document.getElementById('div_pickContact').style.display = 'block';
            }
        }        
    </script>
</asp:Content>