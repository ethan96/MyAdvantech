﻿<%@ Page Title="DataMining - Customer Analysis" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    ValidateRequest="false" %>

<%@ Register Src="TransactionCriteria.ascx" TagName="TransactionCriteria" TagPrefix="uc1" %>
<script runat="server">
    Dim cult As New System.Globalization.CultureInfo("en-US")
    Shared MaxOptyCount As Integer = 3
    Shared MaxActCount As Integer = 3

    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    If TypeOf (cell.Controls(0)) Is LinkButton Then
                        Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                        If Not (button Is Nothing) Then
                            Dim image As New ImageButton
                            image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_1.jpg"
                            image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                            If GridView1.SortExpression = button.CommandArgument Then
                                If GridView1.SortDirection = SortDirection.Ascending Then
                                    image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_2.jpg"
                                Else
                                    image.ImageUrl = Util.GetRuntimeSiteUrl() + "/Images/sort_1.jpg"
                                End If
                            End If
                            cell.Controls.Add(image)
                        End If
                    End If

                End If
            Next
        End If
    End Sub

    Protected Sub cbAllAStatus_CheckedChanged(sender As Object, e As System.EventArgs)
        For Each li As ListItem In cblAStatus.Items
            li.Selected = cbAllAStatus.Checked
        Next
    End Sub

    Protected Sub cbAllBAA_CheckedChanged(sender As Object, e As System.EventArgs)
        For Each li As ListItem In cblBAA.Items
            li.Selected = cbAllBAA.Checked
        Next
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        'Response.Redirect("../../../home.aspx")

        If Not Page.IsPostBack Then
            If MailUtil.IsInRole("CRM.ACL") Then Response.Redirect(Util.GetRuntimeSiteUrl + "/home.aspx")
            If MailUtil.IsInRole("MyAdvantech") OrElse MailUtil.IsInRole("eStore.IT") _
                OrElse MailUtil.IsInRole("AOnline.estore") OrElse String.Equals(User.Identity.Name, "Tanya.Lin@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) Then
            Else
                Response.Redirect(Util.GetRuntimeSiteUrl + "/home.aspx")
            End If
        End If

        If Not Page.IsPostBack Then
            Dim apt As SqlClient.SqlDataAdapter = Nothing, conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim dt As DataTable = Nothing
            dt = New DataTable
            apt = New SqlClient.SqlDataAdapter("select account_status from SIEBEL_ACCOUNT where ACCOUNT_STATUS is not null group by ACCOUNT_STATUS having COUNT(row_id)>100 order by ACCOUNT_STATUS  ", conn)
            apt.Fill(dt) : cblAStatus.DataSource = dt : cblAStatus.DataBind()
            dt = New DataTable
            apt = New SqlClient.SqlDataAdapter("select account_type from SIEBEL_ACCOUNT where account_type is not null group by account_type having COUNT(row_id)>100 order by account_type  ", conn)
            apt.Fill(dt) : cblAccountType.DataSource = dt : cblAccountType.DataBind()
            dt = New DataTable
            apt = New SqlClient.SqlDataAdapter("select VALUE as BAA from SIEBEL_ACCOUNT_BAA_LOV order by VALUE  ", conn)
            apt.Fill(dt) : cblBAA.DataSource = dt : cblBAA.DataBind()
            dbUtil.dbExecuteNoQuery("MY", "delete from TM_TMP_ACCOUNT where ADDED_DATE<=GETDATE()-1")
            Dim arRBU As ArrayList = DataMiningUtil.GetRBU()
            For Each rbu In arRBU
                rbu = Replace(rbu, "'", "")
                Dim liRBU As New ListItem(rbu, rbu)
                liRBU.Selected = True
                cblRBUs.Items.Add(liRBU)
            Next
            'tbRBU.Visible = Util.IsAEUIT()
        End If
    End Sub

    Protected Sub srcResult_Selecting(sender As Object, e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub btnQuery_Click(sender As Object, e As System.EventArgs)
        Try
            lbMsg.Text = ""
            If Util.GetCheckedCountFromCheckBoxList(Me.cblAStatus) = 0 Then
                lbMsg.Text = "Please select at least one account status first"
                Exit Sub
            End If
            tbResult.Visible = True
            Dim strSql As String = GetSql()
            gvResult.PageIndex = 0 : srcResult.SelectCommand = strSql : txtSQL.Text = strSql
            MailUtil.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "AOnline Customer Analysis by " + User.Identity.Name, strSql, False, "", "")
        Catch ex As Exception
            If Util.IsAEUIT() Then txtSQL.Text = ex.ToString()
        End Try

    End Sub

    Function GetSql(Optional ByVal SelectAdvancedColumns As Boolean = False) As String
        Dim arRBU As New ArrayList
        For Each li As ListItem In cblRBUs.Items
            If li.Selected Then
                arRBU.Add("'" + li.Value + "'")
            End If
        Next
        If arRBU.Count = 0 Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT TOP 200 a.ROW_ID, a.ERP_ID, a.ACCOUNT_NAME, a.ACCOUNT_STATUS, a.FAX_NUM,  "))
            .AppendLine(String.Format(" a.PHONE_NUM, a.OU_TYPE_CD, a.URL, a.BusinessGroup, a.ACCOUNT_TYPE, a.RBU, a.PRIMARY_SALES_EMAIL,  "))
            .AppendLine(String.Format(" a.COUNTRY, a.CITY, a.ADDRESS, a.STATE, a.ZIPCODE, a.PROVINCE, a.BAA, a.CREATED,  "))
            .AppendLine(" (select top 1 z.FirstName+'.'+z.LastName from SIEBEL_CONTACT z where z.ROW_ID=b.EA_OWNER_EMP_ID and b.EA_OWNER_EMP_ID is not null) as EA_OWNER, " + _
                        " (select top 1 z.FirstName+'.'+z.LastName from SIEBEL_CONTACT z where z.ROW_ID=b.EP_OWNER_EMP_ID and b.EP_OWNER_EMP_ID is not null) as EP_OWNER, ")
            .AppendLine(String.Format(" a.LAST_UPDATED, a.PriOwnerDivision, a.PriOwnerPosition, a.LOCATION, ADDRESS2, a.CURRENCY"))
            If SelectAdvancedColumns Then
                If TransactionCriteria1.IsOrderCriteriaSpecified() Then
                    Dim obj() As Object = TransactionCriteria1.OrderSql(New System.Text.StringBuilder)
                    For i As Integer = 1 To TransactionCriteria.MaxPNCount
                        Dim txtPN As TextBox = TransactionCriteria1.FindControl("txtOrderPN" + i.ToString())
                        If i = 1 Or String.IsNullOrEmpty(txtPN.Text) = False Then
                            If Not .ToString.EndsWith(",") Then .Append(",")
                            .AppendLine(String.Format("replace(replace((" + _
                                "   select top 10 z.item_no+' on '+dbo.dateonly(z.order_date) as item_no from eai_order_log z where z.order_date between '{0}' and '{1}' " + _
                                "   and z.customer_id=a.erp_id {2} order by z.order_date desc for xml path('')),'<item_no>',''),'</item_no>',';') as order1_log{3}", _
                                CDate(obj(0)).ToString("yyyy-MM-dd"), CDate(obj(1)).ToString("yyyy-MM-dd"), _
                                IIf(Trim(txtPN.Text) <> "", String.Format(" and z.item_no like '{0}%' ", Replace(Replace(Trim(txtPN.Text), "'", "''"), "*", "%")), ""), i))
                        End If
                    Next
                End If
                If TransactionCriteria2.IsOrderCriteriaSpecified() Then
                    Dim obj() As Object = TransactionCriteria2.OrderSql(New System.Text.StringBuilder)
                    For i As Integer = 1 To TransactionCriteria.MaxPNCount
                        Dim txtPN As TextBox = TransactionCriteria2.FindControl("txtOrderPN" + i.ToString())
                        If i = 1 Or String.IsNullOrEmpty(txtPN.Text) = False Then
                            If Not .ToString.EndsWith(",") Then .Append(",")
                            .AppendLine(String.Format("replace(replace((" + _
                                "   select top 10 z.item_no+' on '+dbo.dateonly(z.order_date) as item_no from eai_order_log z where z.order_date between '{0}' and '{1}' " + _
                                "   and z.customer_id=a.erp_id {2} order by z.order_date desc for xml path('')),'<item_no>',''),'</item_no>',';') as order2_log{3}", _
                                CDate(obj(0)).ToString("yyyy-MM-dd"), CDate(obj(1)).ToString("yyyy-MM-dd"), _
                                IIf(Trim(txtPN.Text) <> "", String.Format(" and z.item_no like '{0}%' ", Replace(Replace(Trim(txtPN.Text), "'", "''"), "*", "%")), ""), i))
                        End If
                    Next
                End If
                If TransactionCriteria3.IsOrderCriteriaSpecified() Then
                    Dim obj() As Object = TransactionCriteria3.OrderSql(New System.Text.StringBuilder)
                    For i As Integer = 1 To TransactionCriteria.MaxPNCount
                        Dim txtPN As TextBox = TransactionCriteria3.FindControl("txtOrderPN" + i.ToString())
                        If i = 1 Or String.IsNullOrEmpty(txtPN.Text) = False Then
                            If Not .ToString.EndsWith(",") Then .Append(",")
                            .AppendLine(String.Format("replace(replace((" + _
                                "   select top 10 z.item_no+' on '+dbo.dateonly(z.order_date) as item_no from eai_order_log z where z.order_date between '{0}' and '{1}' " + _
                                "   and z.customer_id=a.erp_id {2} order by z.order_date desc for xml path('')),'<item_no>',''),'</item_no>',';') as order3_log{3}", _
                                CDate(obj(0)).ToString("yyyy-MM-dd"), CDate(obj(1)).ToString("yyyy-MM-dd"), _
                                IIf(Trim(txtPN.Text) <> "", String.Format(" and z.item_no like '{0}%' ", Replace(Replace(Trim(txtPN.Text), "'", "''"), "*", "%")), ""), i))
                        End If
                    Next
                End If

                For i As Integer = 1 To MaxOptyCount
                    Dim rblWithOrNot As RadioButtonList = Me.Master.FindControl("_main").FindControl("rblOptyWithOrNot" + i.ToString())
                    If rblWithOrNot.SelectedIndex = 0 Then
                        Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
                        Dim txtOptyCFrom As TextBox = Me.Master.FindControl("_main").FindControl("txtOptyCFrom" + i.ToString())
                        Dim txtOptyCTo As TextBox = Me.Master.FindControl("_main").FindControl("txtOptyCTo" + i.ToString())
                        Dim txtOptyName As TextBox = Me.Master.FindControl("_main").FindControl("txtOptyName" + i.ToString())
                        Dim rblOptyStatus As DropDownList = Me.Master.FindControl("_main").FindControl("rblOptyStatus" + i.ToString())
                        If Not String.IsNullOrEmpty(txtOptyCFrom.Text) AndAlso Date.TryParseExact(txtOptyCFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                            ofrom = Date.ParseExact(txtOptyCFrom.Text, "yyyy/MM/dd", cult)
                        End If
                        If Not String.IsNullOrEmpty(txtOptyCTo.Text) AndAlso Date.TryParseExact(txtOptyCTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                            oto = Date.ParseExact(txtOptyCTo.Text, "yyyy/MM/dd", cult)
                        End If
                        If Not .ToString.EndsWith(",") Then .Append(",")
                        .AppendLine(String.Format(" replace(replace((" + _
                                                  "     select top 10 z.NAME from SIEBEL_OPTY_LOG z where z.ACCOUNT_ROW_ID=a.ROW_ID " + _
                                                  "     and z.CREATED between '{0}' and '{1}' and z.NAME like N'%{2}%' " + _
                                           IIf(rblOptyStatus.SelectedIndex > 0, " and z.DEAL_TYPE='" + rblOptyStatus.SelectedValue + "' ", "") + _
                                                  "     order by z.CREATED desc for xml path('')" + _
                                                  " ),'<NAME>',''),'</NAME>',';') as Opty_log{3}", _
                                                  ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd"), _
                                                  Replace(Replace(Trim(txtOptyName.Text), "'", "''"), "*", "%"), i))
                    End If
                Next

                For i As Integer = 1 To MaxActCount
                    Dim rblWithOrNot As RadioButtonList = Me.Master.FindControl("_main").FindControl("rblActWithOrNot" + i.ToString())
                    If rblWithOrNot.SelectedIndex = 0 Then
                        Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
                        Dim txtActCFromDate As TextBox = Me.Master.FindControl("_main").FindControl("txtActCFromDate" + i.ToString())
                        Dim txtActCToDate As TextBox = Me.Master.FindControl("_main").FindControl("txtActCToDate" + i.ToString())
                        Dim txtActName As TextBox = Me.Master.FindControl("_main").FindControl("txtActName" + i.ToString())
                        Dim rblActType As DropDownList = Me.Master.FindControl("_main").FindControl("rblActType" + i.ToString())
                        If Not String.IsNullOrEmpty(txtActCFromDate.Text) AndAlso Date.TryParseExact(txtActCFromDate.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                            ofrom = Date.ParseExact(txtActCFromDate.Text, "yyyy/MM/dd", cult)
                        End If
                        If Not String.IsNullOrEmpty(txtActCToDate.Text) AndAlso Date.TryParseExact(txtActCToDate.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                            oto = Date.ParseExact(txtActCToDate.Text, "yyyy/MM/dd", cult)
                        End If
                        If Not .ToString.EndsWith(",") Then .Append(",")
                        .AppendLine(String.Format(" replace(replace((" + _
                                                  "     select top 10 z.NAME from SIEBEL_ACT_LOG z where z.ACCOUNT_ROW_ID=a.ROW_ID " + _
                                                  "     and z.CREATED between '{0}' and '{1}' and z.NAME like N'%{2}%' " + _
                                           IIf(rblActType.SelectedIndex > 0, " and z.IN_OUT='" + rblActType.SelectedValue + "' ", "") + _
                                                  "     order by z.CREATED desc for xml path('')" + _
                                                  " ),'<NAME>',''),'</NAME>',';') as Act_log{3}", _
                                                  ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd"), _
                                                  Replace(Replace(Trim(txtActName.Text), "'", "''"), "*", "%"), i))
                    End If
                Next


            End If
            .AppendLine(String.Format(" FROM SIEBEL_ACCOUNT AS a left join SIEBEL_ACCOUNT_EAEP_OWNER b on a.ROW_ID=b.ACCOUNT_ROW_ID "))
            .AppendLine(String.Format(" where a.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
            '.AppendLine(String.Format(" where a.RBU is not null "))
        End With
        AccountSql(sb)
        If TransactionCriteria1.IsOrderCriteriaSpecified() Then TransactionCriteria1.OrderSql(sb)
        If TransactionCriteria2.IsOrderCriteriaSpecified() Then TransactionCriteria2.OrderSql(sb)
        If TransactionCriteria3.IsOrderCriteriaSpecified() Then TransactionCriteria3.OrderSql(sb)
        If IsOptyCriteriaSpecified() Then OptySql(sb)
        If IsActCriteriaSpecified() Then ActSql(sb)
        sb.AppendLine(String.Format(" order by a.ROW_ID  "))
        Return sb.ToString()
    End Function

    Sub AccountSql(ByRef sb As System.Text.StringBuilder)
        With sb
            If Util.GetCheckedCountFromCheckBoxList(Me.cblAStatus) > 0 Then
                Dim arrAStatus As New ArrayList
                For Each li As ListItem In cblAStatus.Items
                    If li.Selected Then
                        arrAStatus.Add(li.Value)
                    End If
                Next
                For i As Integer = 0 To arrAStatus.Count - 1
                    arrAStatus(i) = "N'" + Replace(arrAStatus(i), "'", "''") + "'"
                Next
                .AppendLine(String.Format(" and a.account_status in {0} ", "(" + String.Join(",", arrAStatus.ToArray()) + ")"))
            End If
            If Util.GetCheckedCountFromCheckBoxList(Me.cblAccountType) > 0 Then
                .AppendLine(String.Format(" and a.account_type in {0} ", Util.GetInStrinFromCheckBoxList(Me.cblAccountType)))
            End If
            If Util.GetCheckedCountFromCheckBoxList(Me.cblBAA) > 0 Then
                .AppendLine(String.Format(" and a.row_id in (select account_row_id from siebel_account_baa where baa in {0}) ", Util.GetInStrinFromCheckBoxList(Me.cblBAA)))
            End If
            If Not String.IsNullOrEmpty(txtAccCFrom.Text) OrElse Not String.IsNullOrEmpty(txtAccCTo.Text) Then
                Dim cfrom As Date = DateAdd(DateInterval.Year, -5, Now), cto As Date = Now
                If Not String.IsNullOrEmpty(txtAccCFrom.Text) AndAlso Date.TryParseExact(txtAccCFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                    cfrom = Date.ParseExact(txtAccCFrom.Text, "yyyy/MM/dd", cult)
                End If
                If Not String.IsNullOrEmpty(txtAccCTo.Text) AndAlso Date.TryParseExact(txtAccCTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                    cto = Date.ParseExact(txtAccCTo.Text, "yyyy/MM/dd", cult)
                End If
                .AppendLine(String.Format(" and  a.CREATED between '{0}' and '{1}' ", cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            End If
            If String.IsNullOrEmpty(txtAccountName.Text) = False Then
                .AppendLine(String.Format(" and a.account_name like N'%{0}%' ", Replace(Replace(Trim(txtAccountName.Text), "'", "''"), "*", "%")))
            End If
            If String.IsNullOrEmpty(txtAOEAOwner.Text) = False Then
                .AppendLine(String.Format(" and a.row_id in " + _
                                          " ( " + _
                                          "     select distinct a.ACCOUNT_ROW_ID from SIEBEL_ACCOUNT_EAEP_OWNER a inner join SIEBEL_CONTACT b " + _
                                          "     on a.EA_OWNER_EMP_ID=b.ROW_ID where a.ACCOUNT_ROW_ID is not null and b.EMAIL_ADDRESS like '{0}%'" + _
                                          " ) ", Replace(Replace(Trim(txtAOEAOwner.Text), "'", "''"), "*", "%")))
            End If
            If String.IsNullOrEmpty(txtAOEPOwner.Text) = False Then
                .AppendLine(String.Format(" and a.row_id in " + _
                                          " ( " + _
                                          "     select distinct a.ACCOUNT_ROW_ID from SIEBEL_ACCOUNT_EAEP_OWNER a inner join SIEBEL_CONTACT b " + _
                                          "     on a.EP_OWNER_EMP_ID=b.ROW_ID where a.ACCOUNT_ROW_ID is not null and b.EMAIL_ADDRESS like '{0}%'" + _
                                          " ) ", Replace(Replace(Trim(txtAOEPOwner.Text), "'", "''"), "*", "%")))
            End If
        End With
    End Sub

    Sub OptySql(ByRef sb As System.Text.StringBuilder)
        For i As Integer = 1 To MaxOptyCount
            Dim rblWithOrNot As RadioButtonList = Me.Master.FindControl("_main").FindControl("rblOptyWithOrNot" + i.ToString())
            If rblWithOrNot.SelectedIndex >= 0 Then
                Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
                Dim txtOptyCFrom As TextBox = Me.Master.FindControl("_main").FindControl("txtOptyCFrom" + i.ToString())
                Dim txtOptyCTo As TextBox = Me.Master.FindControl("_main").FindControl("txtOptyCTo" + i.ToString())
                Dim txtOptyName As TextBox = Me.Master.FindControl("_main").FindControl("txtOptyName" + i.ToString())
                Dim rblOptyStatus As DropDownList = Me.Master.FindControl("_main").FindControl("rblOptyStatus" + i.ToString())
                If Not String.IsNullOrEmpty(txtOptyCFrom.Text) AndAlso Date.TryParseExact(txtOptyCFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                    ofrom = Date.ParseExact(txtOptyCFrom.Text, "yyyy/MM/dd", cult)
                End If
                If Not String.IsNullOrEmpty(txtOptyCTo.Text) AndAlso Date.TryParseExact(txtOptyCTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                    oto = Date.ParseExact(txtOptyCTo.Text, "yyyy/MM/dd", cult)
                End If
                With sb
                    .AppendLine(String.Format(" and a.ROW_ID {0} in ( ", IIf(rblWithOrNot.SelectedIndex = 1, "not", "")))
                    .AppendLine(String.Format("      select distinct z.account_row_id from SIEBEL_OPTY_LOG z  "))
                    .AppendLine(String.Format("      where z.account_row_id is not null and z.CREATED between '{0}' and '{1}' ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
                    If Trim(txtOptyName.Text) <> String.Empty Then .AppendLine(String.Format(" and z.NAME like N'%{0}%' ", Trim(txtOptyName.Text).Replace("'", "''").Replace("*", "%")))
                    If rblOptyStatus.SelectedIndex > 0 Then
                        .AppendLine(String.Format("     and z.DEAL_TYPE='{0}' ", rblOptyStatus.SelectedValue))
                    End If
                    .AppendLine(String.Format(" ) "))
                End With
            End If
        Next
    End Sub

    Sub ActSql(ByRef sb As System.Text.StringBuilder)
        For i As Integer = 1 To MaxActCount
            Dim rblWithOrNot As RadioButtonList = Me.Master.FindControl("_main").FindControl("rblActWithOrNot" + i.ToString())
            If rblWithOrNot.SelectedIndex >= 0 Then
                Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
                Dim txtActCFromDate As TextBox = Me.Master.FindControl("_main").FindControl("txtActCFromDate" + i.ToString())
                Dim txtActCToDate As TextBox = Me.Master.FindControl("_main").FindControl("txtActCToDate" + i.ToString())
                Dim txtActName As TextBox = Me.Master.FindControl("_main").FindControl("txtActName" + i.ToString())
                Dim rblActType As DropDownList = Me.Master.FindControl("_main").FindControl("rblActType" + i.ToString())
                If Not String.IsNullOrEmpty(txtActCFromDate.Text) AndAlso Date.TryParseExact(txtActCFromDate.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                    ofrom = Date.ParseExact(txtActCFromDate.Text, "yyyy/MM/dd", cult)
                End If
                If Not String.IsNullOrEmpty(txtActCToDate.Text) AndAlso Date.TryParseExact(txtActCToDate.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                    oto = Date.ParseExact(txtActCToDate.Text, "yyyy/MM/dd", cult)
                End If
                With sb
                    .AppendLine(String.Format(" and a.ROW_ID {0} in ( ", IIf(rblWithOrNot.SelectedIndex = 1, "not", "")))
                    .AppendLine(String.Format("     select z.ACCOUNT_ROW_ID  "))
                    .AppendLine(String.Format("     from SIEBEL_ACT_LOG z where z.ACCOUNT_ROW_ID is not null and z.CREATED between '{0}' and '{1}'  ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
                    If Trim(txtActName.Text) <> String.Empty Then .AppendLine(String.Format("     and z.NAME like N'%{0}%' ", Trim(txtActName.Text).Replace("'", "''").Replace("*", "%")))
                    If rblActType.SelectedIndex > 0 Then .AppendLine(String.Format(" and z.IN_OUT='{0}'  ", rblActType.SelectedValue))
                    .AppendLine(String.Format("     group by z.ACCOUNT_ROW_ID having COUNT(z.ACCOUNT_ROW_ID)>0 "))
                    .AppendLine(String.Format("  "))
                    .AppendLine(String.Format(" ) "))
                End With
            End If
        Next

    End Sub

    Function IsOptyCriteriaSpecified() As Boolean
        If rblOptyWithOrNot1.SelectedIndex >= 0 OrElse rblOptyWithOrNot2.SelectedIndex >= 0 OrElse rblOptyWithOrNot3.SelectedIndex >= 0 Then Return True
        'If Not String.IsNullOrEmpty(txtOptyCFrom.Text) OrElse Not String.IsNullOrEmpty(txtOptyCTo.Text) Then Return True
        'If Not String.IsNullOrEmpty(txtOptyName.Text) Then Return True
        Return False
    End Function

    Function IsActCriteriaSpecified() As Boolean
        If rblActWithOrNot1.SelectedIndex >= 0 OrElse rblActWithOrNot2.SelectedIndex >= 0 OrElse rblActWithOrNot3.SelectedIndex >= 0 Then Return True
        Return False
    End Function

    Protected Sub gvResult_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        srcResult.SelectCommand = GetSql()
    End Sub

    Protected Sub gvResult_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        srcResult.SelectCommand = GetSql()
    End Sub

    Protected Sub imgXls_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim strSql As String = GetSql()
        If String.IsNullOrEmpty(strSql) = False Then
            If rblXlsType.SelectedIndex = 0 Then
                Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("MY", GetSql(True)), "Account_DataMining.xls")
            Else
                Dim strContactSql As String = _
                    " SELECT top 5000 ROW_ID, FirstName, MiddleName, LastName, WorkPhone, CellPhone, " + _
                    " FaxNumber, JOB_FUNCTION, ERPID, OrgID, NeverEmail, JOB_TITLE, " + _
                    " EMAIL_ADDRESS, ACCOUNT_ROW_ID, ACCOUNT, ACCOUNT_TYPE, ACCOUNT_STATUS, COUNTRY, " + _
                    " Salutation, ACTIVE_FLAG, USER_TYPE, REG_SOURCE, CREATED, LAST_UPDATED" + _
                    " FROM SIEBEL_CONTACT a" + _
                    " where a.ACCOUNT_ROW_ID is not null and a.ACCOUNT_ROW_ID <>'' and a.ACCOUNT_ROW_ID in " + _
                    " (select row_id from (" + strSql + ") as tmp) " + _
                    " order by a.ACCOUNT_ROW_ID, a.EMAIL_ADDRESS "
                'MailUtil.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", strContactSql, False, "", "")
                Dim contactGv As DataTable = dbUtil.dbGetDataTable("MY", strContactSql)
                Util.DataTable2ExcelDownload(contactGv, "Contact_DataMining.xls")
            End If
        End If
    End Sub

    Protected Sub lnkBtnAccountDetail_Click(sender As Object, e As System.EventArgs)
        Dim rid As String = CType(CType(sender, LinkButton).NamingContainer.FindControl("hd_ROWID"), HiddenField).Value
        Dim erpid As String = CType(CType(sender, LinkButton).NamingContainer.FindControl("hd_ERPID"), HiddenField).Value
        div_Detail.Visible = True
        If Trim(erpid) <> "" Then
            Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
            'If Not String.IsNullOrEmpty(txtOrderFrom.Text) AndAlso Date.TryParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
            '    ofrom = Date.ParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult)
            'End If
            'If Not String.IsNullOrEmpty(txtOrderTo.Text) AndAlso Date.TryParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
            '    oto = Date.ParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult)
            'End If
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(" select top 50 item_no as [Part Number], dbo.dateonly(order_date) as [order date], Qty ")
                .AppendLine(String.Format(" from EAI_ORDER_LOG where Customer_ID='{0}' and order_date between '{1}' and '{2}' ", _
                                          erpid, ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
                .AppendLine(" order by order_date desc ")
            End With
            Dim orderDt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
            gvDetailOrder.DataSource = orderDt : gvDetailOrder.DataBind()
        End If
        Dim sb2 As New System.Text.StringBuilder
        With sb2
            .AppendLine(String.Format(" SELECT top 50 NAME, SUM_REVN_AMT as Amount, SUM_WIN_PROB as Probability, DEAL_TYPE as Status "))
            .AppendLine(String.Format(" FROM  SIEBEL_OPTY_LOG "))
            .AppendLine(String.Format(" WHERE ACCOUNT_ROW_ID = '" + rid + "' "))
            .AppendLine(String.Format(" ORDER BY   CREATED DESC "))
        End With
        Dim optyDt As DataTable = dbUtil.dbGetDataTable("MY", sb2.ToString())
        gvDetailOpty.DataSource = optyDt : gvDetailOpty.DataBind()
        sb2 = New System.Text.StringBuilder
        With sb2
            .AppendLine(String.Format(" SELECT top 50 NAME, CREATED, LAST_UPD, TODO_CD as [Activity Type], IN_OUT as Direction "))
            .AppendLine(String.Format(" FROM              SIEBEL_ACT_LOG "))
            .AppendLine(String.Format(" WHERE          (ACCOUNT_ROW_ID = '" + rid + "') "))
            .AppendLine(String.Format(" ORDER BY   CREATED DESC "))
        End With
        Dim actDt As DataTable = dbUtil.dbGetDataTable("MY", sb2.ToString())
        gvDetailAct.DataSource = actDt : gvDetailAct.DataBind()
    End Sub

    Protected Sub lnkCloseDetail_Click(sender As Object, e As System.EventArgs)
        div_Detail.Visible = False
    End Sub

    Protected Sub Page_Error(sender As Object, earg As System.EventArgs)
        Response.Write("page error:<br/>")
        Dim ex As Exception = Server.GetLastError().GetBaseException()
        If ex.GetType().ToString Like "*SqlException*" Then
            Dim e As SqlClient.SqlException = ex
            Dim errorMessages As String = ""
            Dim i As Integer

            For i = 0 To e.Errors.Count - 1
                errorMessages += "Index #" & i.ToString() & "<br />" _
                               & "Message: " & e.Errors(i).Message & "<br />" _
                               & "LineNumber: " & e.Errors(i).LineNumber & "<br />" _
                               & "Source: " & e.Errors(i).Source & "<br />" _
                               & "Procedure: " & e.Errors(i).Procedure & "<br />"
            Next i
            Response.Write("SqlException Detail:" + errorMessages)
        End If
    End Sub

    Protected Sub Page_PreRender(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Not Request.IsAuthenticated Then
                Session.Abandon() : FormsAuthentication.SignOut() : Server.Transfer("~/home.aspx")
            End If
        End If
    End Sub

    Protected Sub btnSaveNChkContact_Click(sender As Object, e As System.EventArgs)
        lbMsg.Text = ""
        Dim strSql As String = GetSql(True)
        If String.IsNullOrEmpty(strSql) = False Then
            Dim criteriaDt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
            Dim dt As New DataTable
            dt.Columns.Add("SESSIONID") : dt.Columns.Add("ACCOUNT_ROW_ID") : dt.Columns.Add("CRITERIA") : dt.Columns.Add("ADDED_DATE", GetType(DateTime))
            For Each r As GridViewRow In gvResult.Rows
                If r.RowType = DataControlRowType.DataRow Then
                    Dim cb As CheckBox = r.FindControl("cbRowCheckAccount")
                    Dim rid As String = CType(r.FindControl("hd_ROWID"), HiddenField).Value
                    If cb IsNot Nothing Then
                        If cb.Checked Then
                            Dim nr As DataRow = dt.NewRow()
                            nr.Item("SESSIONID") = Session.SessionID : nr.Item("ACCOUNT_ROW_ID") = rid
                            Dim rs() As DataRow = criteriaDt.Select("ROW_ID='" + rid + "'")
                            If rs.Length > 0 Then
                                Dim criValue As New System.Text.StringBuilder
                                For Each c As DataColumn In criteriaDt.Columns
                                    If c.ColumnName.Contains("log") Then
                                        If Not (rs(0).Item(c.ColumnName) Is DBNull.Value) Then
                                            criValue.AppendLine(rs(0).Item(c.ColumnName))
                                        End If
                                    End If
                                Next
                                nr.Item("CRITERIA") = criValue.ToString()
                            End If
                            nr.Item("ADDED_DATE") = Now
                            dt.Rows.Add(nr)
                        End If
                    End If
                End If
            Next
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            If dt.Rows.Count > 0 Then
                Dim cmd As New SqlClient.SqlCommand("delete from TM_TMP_ACCOUNT where SESSIONID='" + Session.SessionID + "'", conn)
                If conn.State <> ConnectionState.Open Then conn.Open()
                cmd.ExecuteNonQuery()
                Dim bk As New SqlClient.SqlBulkCopy(conn)
                bk.DestinationTableName = "TM_TMP_ACCOUNT"
                bk.WriteToServer(dt)
                conn.Close()
                Response.Redirect("ContactSelection.aspx")
            Else
                lbMsg.Text = "No account in search result"
            End If
        End If
    End Sub

    Protected Sub cbAllAccountType_CheckedChanged(sender As Object, e As System.EventArgs)
        For Each li As ListItem In cblAccountType.Items
            li.Selected = cbAllAccountType.Checked
        Next
    End Sub

    Protected Sub cbAllOrg_CheckedChanged(sender As Object, e As System.EventArgs)
        For Each li As ListItem In cblRBUs.Items
            li.Selected = cbAllOrg.Checked
        Next
    End Sub

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetEPOwner(ByVal prefixText As String, ByVal count As Integer) As String()
        Return GetEAPOwner(prefixText, count, False)
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetEAOwner(ByVal prefixText As String, ByVal count As Integer) As String()
        Return GetEAPOwner(prefixText, count, True)
    End Function

    Public Shared Function GetEAPOwner(ByVal prefixText As String, ByVal count As Integer, ByVal GetEA As Boolean) As String()
        Dim eapColumn As String = IIf(GetEA, "EA_OWNER_EMP_ID", "EP_OWNER_EMP_ID")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        " select distinct top 20 b.EMAIL_ADDRESS   " + _
        " from SIEBEL_ACCOUNT_EAEP_OWNER a inner join SIEBEL_CONTACT b on a." + eapColumn + "=b.ROW_ID  " + _
        " where LTRIM(b.EMAIL_ADDRESS)<>'' and b.EMAIL_ADDRESS like '{0}%' " + _
        " order by b.EMAIL_ADDRESS  ", prefixText.Trim().Replace("'", "").Replace("*", "%")))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    Protected Sub cbRowHeadCheckAccount_CheckedChanged(sender As Object, e As System.EventArgs)
        'Dim cbHead As CheckBox = sender
        'For Each r As GridViewRow In gvResult.Rows
        '    If r.RowType = DataControlRowType.DataRow Then
        '        Dim cb As CheckBox = r.FindControl("cbRowCheckAccount")
        '        If cb IsNot Nothing Then
        '            cb.Checked = cbHead.Checked
        '        End If
        '    End If
        'Next
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript">
        function ShowHide(id1, id2) {
            var trEle = document.getElementById(id1); var lnkBtn = document.getElementById(id2);            
            if (trEle && lnkBtn) {
                if (trEle.style.display == 'block') {                    
                    trEle.style.display = 'none'; lnkBtn.innerText = '+';                    
                }
                else {
                    trEle.style.display = 'block'; lnkBtn.innerText = '-';                    
                }
            }            
        }
        String.prototype.endsWith = function (str)
        { return (this.match(str + "$") == str) }
        function CheckAllResultAccount(cbObj) {
            var cbs = document.getElementsByTagName("input");
            for (var i = 0; i < cbs.length - 1; i++) {
                if (cbs[i].type == 'checkbox' && cbs[i].name.endsWith('cbRowCheckAccount')) {
                    cbs[i].checked = cbObj.checked;
                }
            }
        }
    </script>
    <table width="100%">
        <tr>
            <td style="color: Navy">
                <h2>
                    Target Marketing Account Analysis</h2>
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td colspan="2">
                            <h3>
                                <a href="javascript:void(0);" id="lnkShowHideAccount" onclick="ShowHide('trAccount','lnkShowHideAccount')">
                                    -</a>&nbsp;Account</h3>
                        </td>
                    </tr>
                    <tr id="trAccount" style="display: block">
                        <td>
                            <table width="100%">
                                <tr>
                                    <td style="width: 20px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Account Status:
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                    </td>
                                    <td>
                                        <hr />
                                    </td>
                                </tr>
                                <tr valign="top">
                                    <td style="width: 20px">
                                        &nbsp;
                                    </td>
                                    <td valign="top">
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <asp:CheckBox runat="server" ID="cbAllAStatus" Text="All" AutoPostBack="true" OnCheckedChanged="cbAllAStatus_CheckedChanged" />
                                                </td>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upAllStatus" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:CheckBoxList runat="server" ID="cblAStatus" RepeatColumns="4" RepeatDirection="Horizontal"
                                                                DataTextField="account_status" DataValueField="account_status">
                                                            </asp:CheckBoxList>
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="cbAllAStatus" EventName="CheckedChanged" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr style="display:none">
                                    <td style="width: 20px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Account Type:
                                    </th>
                                </tr>
                                <tr style="display:none">
                                    <td>
                                    </td>
                                    <td>
                                        <hr />
                                    </td>
                                </tr>
                                <tr valign="top" style="display:none">
                                    <td style="width: 20px">
                                        &nbsp;
                                    </td>
                                    <td valign="top">
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <asp:CheckBox runat="server" ID="cbAllAccountType" Text="All" AutoPostBack="true"
                                                        OnCheckedChanged="cbAllAccountType_CheckedChanged" />
                                                </td>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upAccountTypeList" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:CheckBoxList runat="server" ID="cblAccountType" RepeatColumns="4" RepeatDirection="Horizontal"
                                                                DataTextField="account_type" DataValueField="account_type">
                                                            </asp:CheckBoxList>
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="cbAllAccountType" EventName="CheckedChanged" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr style="display:none">
                                    <td style="width: 20px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Business Application Area:
                                    </th>
                                </tr>
                                <tr style="display:none">
                                    <td>
                                    </td>
                                    <td>
                                        <hr />
                                    </td>
                                </tr>
                                <tr valign="top" style="display:none">
                                    <td style="width: 20px">
                                        &nbsp;
                                    </td>
                                    <td valign="top">
                                        <asp:Panel runat="server" ID="panelBAA" Width="100%" Height="80px" ScrollBars="Auto">
                                            <asp:CheckBox runat="server" ID="cbAllBAA" Text="All" AutoPostBack="true" OnCheckedChanged="cbAllBAA_CheckedChanged" />&nbsp;
                                            <asp:UpdatePanel runat="server" ID="upAllBAA" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:CheckBoxList runat="server" ID="cblBAA" RepeatColumns="3" RepeatDirection="Horizontal"
                                                        DataValueField="BAA" DataTextField="BAA" />
                                                </ContentTemplate>
                                                <Triggers>
                                                    <asp:AsyncPostBackTrigger ControlID="cbAllBAA" EventName="CheckedChanged" />
                                                </Triggers>
                                            </asp:UpdatePanel>
                                        </asp:Panel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                    </td>
                                    <td>
                                        <hr />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width: 20px">
                                        <a href="javascript:void(0)" id="anchorEAEPOwner" onclick="ShowHide('anchorEAEPOwner', 'tdEAEPOwner')">+</a>
                                    </td>
                                    <td align="left" id="tdEAEPOwner" style="display:none">
                                        <table>
                                            <tr>
                                                <th align="left">
                                                    AOnline eP Owner:
                                                </th>
                                                <td>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="OwnerExtender1" TargetControlID="txtAOEPOwner"
                                                        MinimumPrefixLength="0" CompletionInterval="100" ServiceMethod="GetEPOwner" />
                                                    <asp:TextBox runat="server" ID="txtAOEPOwner" Width="220px" />
                                                </td>
                                                <th align="left">
                                                    AOnline eA Owner:
                                                </th>
                                                <td>
                                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="OwnerExtender2" TargetControlID="txtAOEAOwner"
                                                        MinimumPrefixLength="0" CompletionInterval="100" ServiceMethod="GetEAOwner" />
                                                    <asp:TextBox runat="server" ID="txtAOEAOwner" Width="220px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">
                                                    Create Date:
                                                </th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender5" TargetControlID="txtAccCFrom"
                                                        Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender6" TargetControlID="txtAccCTo"
                                                        Format="yyyy/MM/dd" />
                                                    <asp:TextBox runat="server" ID="txtAccCFrom" Width="80px" />~<asp:TextBox runat="server"
                                                        ID="txtAccCTo" Width="80px" />
                                                </td>
                                                <th align="left">
                                                    Account Name:
                                                </th>
                                                <td>
                                                    <asp:TextBox runat="server" ID="txtAccountName" Width="150px" />
                                                </td>
                                            </tr>
                                        </table>
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
                <hr />
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td colspan="2">
                            <h3>
                                <a href="javascript:void(0);" id="lnkShowHideOrder" onclick="ShowHide('trOrder','lnkShowHideOrder')">
                                    +</a>&nbsp;Transactional Log</h3>
                        </td>
                    </tr>
                    <tr id="trOrder" style="display: none">
                        <td style="width: 20px">
                            &nbsp;
                        </td>
                        <td>
                            <table>
                                <tr style="background-color: Gray">
                                    <th align="left">
                                        Criteria 1
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                        <uc1:TransactionCriteria ID="TransactionCriteria1" runat="server" />
                                    </td>
                                </tr>
                                <tr style="background-color: Gray">
                                    <th align="left">
                                        Criteria 2
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                        <uc1:TransactionCriteria ID="TransactionCriteria2" runat="server" />
                                    </td>
                                </tr>
                                <tr style="background-color: Gray">
                                    <th align="left">
                                        Criteria 3
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                        <uc1:TransactionCriteria ID="TransactionCriteria3" runat="server" />
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
                <hr />
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td colspan="2">
                            <h3>
                                <a href="javascript:void(0);" id="lnkShowHideOpty" onclick="ShowHide('trOpty','lnkShowHideOpty')">
                                    +</a>&nbsp;Opportunity</h3>
                        </td>
                    </tr>
                    <tr id="trOpty" style="display: none">
                        <td style="width: 20px">
                            &nbsp;
                        </td>
                        <td>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblOptyWithOrNot1" RepeatColumns="2" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="With" />
                                            <asp:ListItem Value="Without" />
                                        </asp:RadioButtonList>
                                    </td>
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" TargetControlID="txtOptyCFrom1"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" TargetControlID="txtOptyCTo1"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtOptyCFrom1" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtOptyCTo1" Width="80px" />
                                    </td>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOptyName1" Width="150px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Status:
                                    </th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="rblOptyStatus1">
                                            <asp:ListItem Value="Not Specified" Selected="True" />
                                            <asp:ListItem Value="Won" />
                                            <asp:ListItem Value="Lost" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblOptyWithOrNot2" RepeatColumns="2" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="With" />
                                            <asp:ListItem Value="Without" />
                                        </asp:RadioButtonList>
                                    </td>
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender7" TargetControlID="txtOptyCFrom2"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender8" TargetControlID="txtOptyCTo2"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtOptyCFrom2" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtOptyCTo2" Width="80px" />
                                    </td>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOptyName2" Width="150px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Status:
                                    </th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="rblOptyStatus2" epeatColumns="3">
                                            <asp:ListItem Value="Not Specified" Selected="True" />
                                            <asp:ListItem Value="Won" />
                                            <asp:ListItem Value="Lost" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblOptyWithOrNot3" RepeatColumns="2" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="With" />
                                            <asp:ListItem Value="Without" />
                                        </asp:RadioButtonList>
                                    </td>
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender9" TargetControlID="txtOptyCFrom3"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender10" TargetControlID="txtOptyCTo3"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtOptyCFrom3" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtOptyCTo3" Width="80px" />
                                    </td>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOptyName3" Width="150px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Status:
                                    </th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="rblOptyStatus3">
                                            <asp:ListItem Value="Not Specified" Selected="True" />
                                            <asp:ListItem Value="Won" />
                                            <asp:ListItem Value="Lost" />
                                        </asp:DropDownList>
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
                <hr />
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td colspan="2">
                            <h3>
                                <a href="javascript:void(0);" id="lnkShowHideAct" onclick="ShowHide('trAct','lnkShowHideAct')">
                                    +</a>&nbsp;Activity</h3>
                        </td>
                    </tr>
                    <tr id="trAct" style="display: none">
                        <td style="width: 20px">
                            &nbsp;
                        </td>
                        <td>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblActWithOrNot1" RepeatColumns="2" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="With" />
                                            <asp:ListItem Value="Without" />
                                        </asp:RadioButtonList>
                                    </td>
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender3" TargetControlID="txtActCFromDate1"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender4" TargetControlID="txtActCToDate1"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtActCFromDate1" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtActCToDate1" Width="80px" />
                                    </td>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtActName1" Width="150px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Type:
                                    </th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="rblActType1">
                                            <asp:ListItem Text="Not specified" />
                                            <asp:ListItem Text="Inbound" Selected="True" Value="IN" />
                                            <asp:ListItem Text="Outbound" Value="OUT" />
                                            <asp:ListItem Text="Others" Value="TBD" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblActWithOrNot2" RepeatColumns="2" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="With" />
                                            <asp:ListItem Value="Without" />
                                        </asp:RadioButtonList>
                                    </td>
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender11" TargetControlID="txtActCFromDate2"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender12" TargetControlID="txtActCToDate2"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtActCFromDate2" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtActCToDate2" Width="80px" />
                                    </td>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtActName2" Width="150px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Type:
                                    </th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="rblActType2">
                                            <asp:ListItem Text="Not specified" />
                                            <asp:ListItem Text="Inbound" Selected="True" Value="IN" />
                                            <asp:ListItem Text="Outbound" Value="OUT" />
                                            <asp:ListItem Text="Others" Value="TBD" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblActWithOrNot3" RepeatColumns="2" RepeatDirection="Horizontal">
                                            <asp:ListItem Value="With" />
                                            <asp:ListItem Value="Without" />
                                        </asp:RadioButtonList>
                                    </td>
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender13" TargetControlID="txtActCFromDate3"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender14" TargetControlID="txtActCToDate3"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtActCFromDate3" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtActCToDate3" Width="80px" />
                                    </td>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtActName3" Width="150px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Type:
                                    </th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="rblActType3">
                                            <asp:ListItem Text="Not specified" />
                                            <asp:ListItem Text="Inbound" Selected="True" Value="IN" />
                                            <asp:ListItem Text="Outbound" Value="OUT" />
                                            <asp:ListItem Text="Others" Value="TBD" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr style="display: block">
            <td>
                <table id="tbRBU" width="100%">
                    <tr>
                        <td>
                            <hr />
                        </td>
                    </tr>
                    <tr>
                        <th align="left">
                            <h3>
                                <a href="javascript:void(0);" id="lnkShowHideOrg" onclick="ShowHide('trOrg','lnkShowHideOrg');">
                                    +</a>&nbsp;Org.</h3>
                        </th>
                    </tr>
                    <tr id="trOrg" style="display: block">
                        <td>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:CheckBox runat="server" ID="cbAllOrg" Checked="true" AutoPostBack="true" Text="All"
                                            OnCheckedChanged="cbAllOrg_CheckedChanged" />
                                    </td>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upAllOrg" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:CheckBoxList runat="server" ID="cblRBUs" RepeatColumns="10" 
                                                    RepeatDirection="Horizontal" RepeatLayout="Table" CellPadding="1" CellSpacing="1" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="cbAllOrg" EventName="CheckedChanged" />
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
                <hr />
            </td>
        </tr>
        <tr>
            <td align="center">
                <asp:Button runat="server" ID="btnQuery" Text="Query" Font-Bold="true" Font-Size="Larger"
                    OnClick="btnQuery_Click" Width="100px" Height="30px" />
            </td>
        </tr>
        <tr>
            <td align="center">
                <asp:UpdatePanel runat="server" ID="upSQL" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                        <asp:TextBox Visible="false" runat="server" ID="txtSQL" Width="100%" TextMode="MultiLine"
                            Rows="10" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnQuery" /> 
                        <%--<asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />--%>
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upResult" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%" runat="server" id="tbResult" visible="false">
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <th align="left">
                                                Download
                                            </th>
                                            <td>
                                                <asp:RadioButtonList runat="server" ID="rblXlsType" RepeatColumns="2" RepeatDirection="Horizontal">
                                                    <asp:ListItem Value="Account" Selected="True" />
                                                    <asp:ListItem Value="Contact" />
                                                </asp:RadioButtonList>
                                            </td>
                                            <td>
                                                <asp:ImageButton runat="server" ID="imgXls" AlternateText="Download to Excel" ImageUrl="~/Images/excel.gif"
                                                    OnClick="imgXls_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%">
                                        <tr>
                                            <td align="center">
                                                <asp:Button runat="server" ID="btnSaveNChkContact" Text="Go to Contact Selection"
                                                    OnClick="btnSaveNChkContact_Click" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:GridView runat="server" ID="gvResult" DataSourceID="srcResult" Width="100%"
                                                    PageSize="100" AllowPaging="false" AllowSorting="true" 
                                                    EmptyDataText="There is no result of your search, please refine your query criterias."
                                                    OnPageIndexChanging="gvResult_PageIndexChanging" OnSorting="gvResult_Sorting"
                                                    OnRowCreated="gvRowCreated" AutoGenerateColumns="false">
                                                    <Columns>
                                                        <asp:TemplateField HeaderText="">
                                                            <HeaderTemplate>
                                                                <input type="checkbox" checked="checked" onclick="CheckAllResultAccount(this);" />
                                                            </HeaderTemplate>
                                                            <ItemTemplate>
                                                                <asp:CheckBox runat="server" ID="cbRowCheckAccount" Checked="true" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:HyperLinkField HeaderText="Account Name" SortExpression="account_name" DataNavigateUrlFields="ROW_ID"
                                                            DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="account_name"
                                                            Target="_blank" />
                                                        <asp:BoundField HeaderText="Account Status" DataField="ACCOUNT_STATUS" SortExpression="ACCOUNT_STATUS" />
                                                        <asp:BoundField HeaderText="Org." DataField="RBU" SortExpression="RBU" />
                                                        <asp:BoundField HeaderText="Country" DataField="COUNTRY" SortExpression="COUNTRY" />
                                                        <asp:BoundField HeaderText="City" DataField="CITY" SortExpression="CITY" />
                                                        <asp:BoundField HeaderText="Address" DataField="ADDRESS" SortExpression="ADDRESS" />
                                                        <asp:BoundField HeaderText="Primary BAA" DataField="BAA" SortExpression="BAA" />
                                                        <asp:TemplateField HeaderText="eA/eP Owner">
                                                            <ItemTemplate>
                                                                <b>eA:</b>&nbsp;<%#Eval("EA_OWNER")%><br />
                                                                <b>eP:</b>&nbsp;<%#Eval("EP_OWNER")%><br />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Detail">
                                                            <ItemTemplate>
                                                                <asp:HiddenField runat="server" ID="hd_ROWID" Value='<%#Eval("ROW_ID") %>' />
                                                                <asp:HiddenField runat="server" ID="hd_ERPID" Value='<%#Eval("ERP_ID") %>' />
                                                                <asp:LinkButton runat="server" ID="lnkBtnAccountDetail" Text="Click" OnClick="lnkBtnAccountDetail_Click" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="srcResult" ConnectionString="<%$ConnectionStrings:MY %>"
                                                    OnSelecting="srcResult_Selecting" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
                            TargetControlID="PanelDetail" HorizontalSide="Center" VerticalSide="Middle" HorizontalOffset="0"
                            VerticalOffset="0" />
                        <asp:Panel runat="server" ID="PanelDetail">
                            <div runat="server" id="div_Detail" visible="false" style="background-color: white;
                                border: solid 1px silver; padding: 10px; width: 800px; height: 620px; overflow: auto;">
                                <table width="100%">
                                    <tr>
                                        <td>
                                            <asp:LinkButton runat="server" ID="lnkCloseDetail" Text="Close" OnClick="lnkCloseDetail_Click" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <ajaxToolkit:TabContainer runat="server" ID="tabADetail">
                                                <ajaxToolkit:TabPanel runat="server" HeaderText="Transactional Log" ID="TabPanel1">
                                                    <ContentTemplate>
                                                        <asp:GridView runat="server" ID="gvDetailOrder" />
                                                    </ContentTemplate>
                                                </ajaxToolkit:TabPanel>
                                                <ajaxToolkit:TabPanel runat="server" HeaderText="Opportunities" ID="TabPanel2">
                                                    <ContentTemplate>
                                                        <asp:GridView runat="server" ID="gvDetailOpty" />
                                                    </ContentTemplate>
                                                </ajaxToolkit:TabPanel>
                                                <ajaxToolkit:TabPanel runat="server" HeaderText="Activities" ID="TabPanel3">
                                                    <ContentTemplate>
                                                        <asp:GridView runat="server" ID="gvDetailAct" />
                                                    </ContentTemplate>
                                                </ajaxToolkit:TabPanel>
                                            </ajaxToolkit:TabContainer>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="imgXls" />
                        <asp:PostBackTrigger ControlID="btnQuery" />
                        <asp:PostBackTrigger ControlID="btnSaveNChkContact" />
                        <%--<asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />--%>
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>