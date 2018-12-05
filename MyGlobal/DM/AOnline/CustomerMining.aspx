﻿<%@ Page Title="DataMining - Customer Analysis" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    ValidateRequest="false" %>

<script runat="server">
    Dim cult As New System.Globalization.CultureInfo("en-US")
    Shared MaxPNCount As Integer = 6
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
        If Not Page.IsPostBack Then
            Dim apt As SqlClient.SqlDataAdapter = Nothing, conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim dt As DataTable = Nothing
            dt = New DataTable
            apt = New SqlClient.SqlDataAdapter("select account_status from SIEBEL_ACCOUNT where ACCOUNT_STATUS is not null group by ACCOUNT_STATUS having COUNT(row_id)>100 order by ACCOUNT_STATUS  ", conn)
            apt.Fill(dt) : cblAStatus.DataSource = dt : cblAStatus.DataBind()
            dt = New DataTable
            apt = New SqlClient.SqlDataAdapter("select VALUE as BAA from SIEBEL_ACCOUNT_BAA_LOV order by VALUE  ", conn)
            apt.Fill(dt) : cblBAA.DataSource = dt : cblBAA.DataBind()
        End If
    End Sub

    Protected Sub btnMoreOrderPN_Click(sender As Object, e As System.EventArgs)
        For i As Integer = 2 To MaxPNCount
            If i = MaxPNCount Then btnMoreOrderPN.Enabled = False
            Dim txtPN As TextBox = Me.Master.FindControl("_main").FindControl("txtOrderPN" + i.ToString())
            If txtPN Is Nothing Then
                btnMoreOrderPN.Enabled = False
            End If
            If txtPN.Visible = False Then
                txtPN.Visible = True : Exit For
            End If
        Next
    End Sub

    Protected Sub srcResult_Selecting(sender As Object, e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub btnQuery_Click(sender As Object, e As System.EventArgs)
        tbResult.Visible = True 'srcResult.SelectCommand = GetSql() : 
        gvResult.PageIndex = 0
        Try
            srcResult.SelectCommand = GetSql()
            txtSQL.Text = GetSql()
        Catch ex As Exception
            txtSQL.Text = ex.ToString()
        End Try

    End Sub

    Function GetSql() As String
        Dim arRBU As ArrayList = DataMiningUtil.GetRBU()
        If arRBU.Count = 0 Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT TOP 50000 a.ROW_ID, a.ERP_ID, a.ACCOUNT_NAME, a.ACCOUNT_STATUS, a.FAX_NUM,  "))
            .AppendLine(String.Format(" a.PHONE_NUM, a.OU_TYPE_CD, a.URL, a.BusinessGroup, a.ACCOUNT_TYPE, a.RBU, a.PRIMARY_SALES_EMAIL,  "))
            .AppendLine(String.Format(" a.COUNTRY, a.CITY, a.ADDRESS, a.STATE, a.ZIPCODE, a.PROVINCE, a.BAA, a.CREATED,  "))
            .AppendLine(String.Format(" a.LAST_UPDATED, a.PriOwnerDivision, a.PriOwnerPosition, a.LOCATION, ADDRESS2, a.CURRENCY "))
            .AppendLine(String.Format(" FROM SIEBEL_ACCOUNT AS a "))
            .AppendLine(String.Format(" where a.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
        End With
        AccountSql(sb)
        If IsOrderCriteriaSpecified() Then OrderSql(sb)
        If IsOptyCriteriaSpecified() Then OptySql(sb)
        If IsActCriteriaSpecified() Then ActSql(sb)
        sb.AppendLine(String.Format(" order by a.ROW_ID  "))
        Return sb.ToString()
    End Function

    Sub AccountSql(ByRef sb As System.Text.StringBuilder)
        With sb
            If Util.GetCheckedCountFromCheckBoxList(Me.cblAStatus) > 0 Then
                .AppendLine(String.Format(" and a.account_status in {0} ", Util.GetInStrinFromCheckBoxList(Me.cblAStatus)))
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
        End With
    End Sub

    Sub OrderSql(ByRef sb As System.Text.StringBuilder)
        With sb
            Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
            If Not String.IsNullOrEmpty(txtOrderFrom.Text) AndAlso Date.TryParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                ofrom = Date.ParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult)
            End If
            If Not String.IsNullOrEmpty(txtOrderTo.Text) AndAlso Date.TryParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                oto = Date.ParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult)
            End If
            Dim strOrderERPIDSql As String = ""
            If rblPNAndOr.SelectedValue = "AND" Then
                Dim sqlArr As New ArrayList
                For i As Integer = 1 To MaxPNCount
                    Dim txtPN As TextBox = Me.Master.FindControl("_main").FindControl("txtOrderPN" + i.ToString())
                    If i = 1 Or Trim(txtPN.Text) <> String.Empty Then
                        sqlArr.Add(GetOrderERPIDSql(txtPN.Text, ofrom, oto))
                    End If
                Next
                If sqlArr.Count > 0 Then
                    strOrderERPIDSql = String.Join(" and ", sqlArr.ToArray())
                End If
            Else
                Dim sqlArr As New ArrayList
                For i As Integer = 1 To MaxPNCount
                    Dim txtPN As TextBox = Me.Master.FindControl("_main").FindControl("txtOrderPN" + i.ToString())
                    If Trim(txtPN.Text) <> String.Empty Then
                        sqlArr.Add(String.Format(" z.item_no like '{0}%' ", Replace(Trim(txtPN.Text), "'", "''").Replace("*", "%")))
                    End If
                Next
                Dim subSb As New System.Text.StringBuilder
                subSb.AppendLine("  a.ERP_ID in (")
                subSb.AppendLine(String.Format(" select distinct Customer_ID  "))
                subSb.AppendLine(String.Format(" from EAI_ORDER_LOG z where Customer_ID is not null  "))
                subSb.AppendLine(String.Format(" and z.order_date between '{0}' and '{1}'  ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
                If sqlArr.Count > 0 Then
                    subSb.AppendLine(String.Format(" and ({0}) ", String.Join(" or ", sqlArr.ToArray())))
                End If
                subSb.AppendLine(")")
                strOrderERPIDSql = subSb.ToString()
            End If
            If strOrderERPIDSql <> String.Empty Then
                .AppendLine(String.Format(" and a.ERP_ID is not null and a.ERP_ID<>'' and ({0}) ", strOrderERPIDSql))
            End If
        End With
    End Sub

    Sub OptySql(ByRef sb As System.Text.StringBuilder)
        Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
        If Not String.IsNullOrEmpty(txtOptyCFrom.Text) AndAlso Date.TryParseExact(txtOptyCFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
            ofrom = Date.ParseExact(txtOptyCFrom.Text, "yyyy/MM/dd", cult)
        End If
        If Not String.IsNullOrEmpty(txtOptyCTo.Text) AndAlso Date.TryParseExact(txtOptyCTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
            oto = Date.ParseExact(txtOptyCTo.Text, "yyyy/MM/dd", cult)
        End If
        With sb
            .AppendLine(String.Format(" and a.ROW_ID in ( "))
            .AppendLine(String.Format("      select distinct z.account_row_id from SIEBEL_OPTY_LOG z  "))
            .AppendLine(String.Format("      where z.account_row_id is not null and z.CREATED between '{0}' and '{1}' ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
            If Trim(txtOptyName.Text) <> String.Empty Then .AppendLine(String.Format(" and z.NAME like N'%{0}%' ", Trim(txtOptyName.Text).Replace("'", "''").Replace("*", "%")))
            If rblOptyStatus.SelectedIndex > 0 Then
                .AppendLine(String.Format("     and z.DEAL_TYPE='{0}' ", rblOptyStatus.SelectedValue))
            End If
            .AppendLine(String.Format(" ) "))
        End With
    End Sub

    Sub ActSql(ByRef sb As System.Text.StringBuilder)
        Dim ofrom As Date = DateAdd(DateInterval.Year, -5, Now), oto As Date = Now
        If Not String.IsNullOrEmpty(txtActCFromDate.Text) AndAlso Date.TryParseExact(txtActCFromDate.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
            ofrom = Date.ParseExact(txtActCFromDate.Text, "yyyy/MM/dd", cult)
        End If
        If Not String.IsNullOrEmpty(txtActCToDate.Text) AndAlso Date.TryParseExact(txtActCToDate.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
            oto = Date.ParseExact(txtActCToDate.Text, "yyyy/MM/dd", cult)
        End If
        With sb
            .AppendLine(String.Format(" and a.ROW_ID in ( "))
            .AppendLine(String.Format("     select z.ACCOUNT_ROW_ID  "))
            .AppendLine(String.Format("     from SIEBEL_ACT_LOG z where z.ACCOUNT_ROW_ID is not null and z.CREATED between '{0}' and '{1}'  ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
            If Trim(txtActName.Text) <> String.Empty Then .AppendLine(String.Format("     and z.NAME like N'%{0}%' ", Trim(txtActName.Text).Replace("'", "''").Replace("*", "%")))
            If rblActType.SelectedIndex > 0 Then .AppendLine(String.Format(" and z.IN_OUT='{0}'  ", rblActType.SelectedValue))
            .AppendLine(String.Format("     group by z.ACCOUNT_ROW_ID having COUNT(z.ACCOUNT_ROW_ID)>0 "))
            .AppendLine(String.Format("  "))
            .AppendLine(String.Format(" ) "))
        End With
    End Sub

    Function GetOrderERPIDSql(ByVal PN As String, ByVal ofrom As Date, ByVal oto As Date) As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct Customer_ID  "))
            .AppendLine(String.Format(" from EAI_ORDER_LOG z where Customer_ID is not null  "))
            .AppendLine(String.Format(" and z.order_date between '{0}' and '{1}'  ", ofrom.ToString("yyyy-MM-dd"), oto.ToString("yyyy-MM-dd")))
            If Trim(PN) <> String.Empty Then .AppendLine(String.Format(" and z.item_no like '{0}%' ", Replace(Trim(PN), "'", "''").Replace("*", "%")))
        End With
        Return " a.ERP_ID in (" + sb.ToString() + ") "
    End Function

    Function IsOrderCriteriaSpecified() As Boolean
        If Not String.IsNullOrEmpty(txtOrderFrom.Text) OrElse Not String.IsNullOrEmpty(txtOrderTo.Text) Then Return True
        For i As Integer = 1 To MaxPNCount
            Dim txtPN As TextBox = Me.Master.FindControl("_main").FindControl("txtOrderPN" + i.ToString())
            If String.IsNullOrEmpty(txtPN.Text) = False Then Return True
        Next
        Return False
    End Function

    Function IsOptyCriteriaSpecified() As Boolean
        If Not String.IsNullOrEmpty(txtOptyCFrom.Text) OrElse Not String.IsNullOrEmpty(txtOptyCTo.Text) Then Return True
        If Not String.IsNullOrEmpty(txtOptyName.Text) Then Return True
        Return False
    End Function

    Function IsActCriteriaSpecified() As Boolean
        If Not String.IsNullOrEmpty(txtActCFromDate.Text) OrElse Not String.IsNullOrEmpty(txtActCToDate.Text) Then Return True
        If Not String.IsNullOrEmpty(txtActName.Text) Then Return True
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
                Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("MY", strSql), "Account_DataMining.xls")
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
            If Not String.IsNullOrEmpty(txtOrderFrom.Text) AndAlso Date.TryParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                ofrom = Date.ParseExact(txtOrderFrom.Text, "yyyy/MM/dd", cult)
            End If
            If Not String.IsNullOrEmpty(txtOrderTo.Text) AndAlso Date.TryParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult, System.Globalization.DateTimeStyles.None, Now) Then
                oto = Date.ParseExact(txtOrderTo.Text, "yyyy/MM/dd", cult)
            End If
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
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript">
        function ShowHide(id1, id2) {
            var trEle = document.getElementById(id1);
            var lnkBtn = document.getElementById(id2);
            if (trEle && lnkBtn) {
                if (trEle.style.display == 'block') {
                    //alert("a");
                    trEle.style.display = 'none';
                    lnkBtn.innerText = '+';
                    //alert("b");
                }
                else {
                    //alert("c");
                    trEle.style.display = 'block';
                    lnkBtn.innerText = '-';
                    //alert("s");
                }
            }
        }
    </script>
    <table width="100%">
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
                                        <asp:CheckBox runat="server" ID="cbAllAStatus" Text="All" AutoPostBack="true" OnCheckedChanged="cbAllAStatus_CheckedChanged" />&nbsp;
                                        <asp:UpdatePanel runat="server" ID="upAllStatus" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:CheckBoxList runat="server" ID="cblAStatus" RepeatColumns="4" RepeatDirection="Horizontal"
                                                    DataValueField="account_status" DataTextField="account_status" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="cbAllAStatus" EventName="CheckedChanged" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width: 20px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Business Application Area:
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
                                        &nbsp;
                                    </td>
                                    <td align="left">
                                        <b>Create Date:</b>&nbsp;
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender5" TargetControlID="txtAccCFrom"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender6" TargetControlID="txtAccCTo"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtAccCFrom" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtAccCTo" Width="80px" />
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
                            <table width="100%">
                                <tr>
                                    <th align="left">
                                        Order Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="calext1" TargetControlID="txtOrderFrom"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="calext2" TargetControlID="txtOrderTo"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtOrderFrom" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtOrderTo" Width="80px" />
                                    </td>
                                </tr>
                                <tr valign="top">
                                    <th align="left">
                                        Purchased Items:
                                    </th>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <td>
                                                    <asp:RadioButtonList runat="server" ID="rblPNAndOr" RepeatColumns="2" RepeatDirection="Horizontal">
                                                        <asp:ListItem Value="OR" Selected="True" />
                                                        <asp:ListItem Value="AND" />
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upOrderPN" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Button runat="server" ID="btnMoreOrderPN" Text="More" OnClick="btnMoreOrderPN_Click" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="txtOrderPN1"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender2" TargetControlID="txtOrderPN2"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender3" TargetControlID="txtOrderPN3"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender4" TargetControlID="txtOrderPN4"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender5" TargetControlID="txtOrderPN5"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender6" TargetControlID="txtOrderPN6"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender7" TargetControlID="txtOrderPN7"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender8" TargetControlID="txtOrderPN8"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender9" TargetControlID="txtOrderPN9"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender10" TargetControlID="txtOrderPN10"
                                                                MinimumPrefixLength="5" ServiceMethod="GetPartNo" ServicePath="~/Services/AutoComplete.asmx" />
                                                            <asp:TextBox runat="server" ID="txtOrderPN1" Width="80px" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN2" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN3" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN4" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN5" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN6" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN7" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN8" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN9" Width="80px" Visible="false" />&nbsp;
                                                            <asp:TextBox runat="server" ID="txtOrderPN10" Width="80px" Visible="false" />
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
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
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td colspan="4">
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" TargetControlID="txtOptyCFrom"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" TargetControlID="txtOptyCTo"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtOptyCFrom" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtOptyCTo" Width="80px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtOptyName" Width="200px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Status:
                                    </th>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblOptyStatus" RepeatColumns="3">
                                            <asp:ListItem Value="Not Specified" Selected="True" />
                                            <asp:ListItem Value="Won" />
                                            <asp:ListItem Value="Lost" />
                                        </asp:RadioButtonList>
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
                                    <th align="left">
                                        Create Date:
                                    </th>
                                    <td colspan="4">
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender3" TargetControlID="txtActCFromDate"
                                            Format="yyyy/MM/dd" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender4" TargetControlID="txtActCToDate"
                                            Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtActCFromDate" Width="80px" />~<asp:TextBox runat="server"
                                            ID="txtActCToDate" Width="80px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtActName" Width="200px" />
                                    </td>
                                    <td style="width: 10px">
                                        &nbsp;
                                    </td>
                                    <th align="left">
                                        Type:
                                    </th>
                                    <td>
                                        <asp:RadioButtonList runat="server" ID="rblActType" RepeatColumns="4">
                                            <asp:ListItem Text="Not specified" />
                                            <asp:ListItem Text="Inbound" Selected="True" Value="IN" />
                                            <asp:ListItem Text="Outbound" Value="OUT" />
                                            <asp:ListItem Text="Others" Value="TBD" />
                                        </asp:RadioButtonList>
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
            <td>
                <asp:UpdatePanel runat="server" ID="upSQL" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:TextBox Visible="false" runat="server" ID="txtSQL" Width="100%" TextMode="MultiLine"
                            Rows="10" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />
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
                                    <asp:GridView runat="server" ID="gvResult" DataSourceID="srcResult" Width="100%"
                                        PageSize="100" AllowPaging="true" AllowSorting="true" EmptyDataText="There is no result of your search, please refine your query criterias."
                                        OnPageIndexChanging="gvResult_PageIndexChanging" OnSorting="gvResult_Sorting"
                                        AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:HyperLinkField HeaderText="Account Name" SortExpression="account_name" DataNavigateUrlFields="ROW_ID"
                                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="account_name"
                                                Target="_blank" />
                                            <asp:BoundField HeaderText="Account Status" DataField="ACCOUNT_STATUS" SortExpression="ACCOUNT_STATUS" />
                                            <asp:BoundField HeaderText="Org." DataField="RBU" SortExpression="RBU" />
                                            <asp:BoundField HeaderText="Country" DataField="COUNTRY" SortExpression="COUNTRY" />
                                            <asp:BoundField HeaderText="City" DataField="CITY" SortExpression="CITY" />
                                            <asp:BoundField HeaderText="Address" DataField="ADDRESS" SortExpression="ADDRESS" />
                                            <asp:BoundField HeaderText="Primary BAA" DataField="BAA" SortExpression="BAA" />
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
                        <asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>
