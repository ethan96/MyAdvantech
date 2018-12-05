﻿<%@ Page Title="My Sales Leads" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false"%>
<%@ Import Namespace="SiebelBusObjectInterfaces" %>
<%@ Register Src="~/Includes/OptyPtnrContact.ascx" TagName="OptyPtnrContact" TagPrefix="uc1" %>
<%@ Register src="../Includes/ChangeCompany.ascx" tagname="ChangeCompany" tagprefix="uc1" %>
<script runat="server">    
    
    Public Shared Function Isleadslists(ByVal company_id As String) As Boolean
        Dim CP As String() = {"EFFRFA01", "EFFRIN04", "EFESAD01", "EIITER01", "EIITBA01", "EIITIO01", "EGCS002", _
                                        "EIITAD01", "EIITDI01", "EIITCO03", "EIITSI04", "EFESNE01", "EFESAE01", "EFESAY01", "EFESTE01", "EITW005"}

        If CP.Contains(company_id.ToString.Trim) Then
            Isleadslists = True
        Else
            Isleadslists = False
        End If
    End Function
    
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'ming add for session("user_id") 20100713
            If Session("user_id") Is Nothing OrElse Session("user_id").ToString() = "" Then
                Response.Redirect("../home.aspx?ReturnUrl=" + Request.ServerVariables("URL"))
                Response.End()
            End If           
            
            'JJ 2014/4/3 如果是InterCon.ALL這個Group的人員在home_ez上是隱藏的，所以如果直接用URL連結就導回首頁
            'ICC 2016/3/31 Remove this code for Stefanie to test
            If MailUtil.IsInMailGroup("InterCon.ALL", Session("user_id")) AndAlso Not MailUtil.IsInRole("ChannelManagement.ACL") Then
                Response.Redirect("~/home.aspx")
                Response.End()
            End If
            
            OptySrc.SelectCommand = GetMyLeads()
            If Util.IsInternalUser(Session("user_id").ToString.Trim) Then
                LeadsMgrAdmin.Visible = True
            Else
                LeadsMgrAdmin.Visible = False
            End If
        End If
        If Util.IsInternalUser(Session("user_id").ToString.Trim) OrElse isexist(Session("user_id").ToString.Trim) Then
            OptyGv.Columns(OptyGv.Columns.Count - 1).Visible = True
            rblAllOrPart.Visible = False
        Else
            OptyGv.Columns(OptyGv.Columns.Count - 1).Visible = False : chgcompanypanel1.Width = Unit.Pixel(0)
            rblAllOrPart.Visible = False
          
        End If
        'If HttpContext.Current.User.Identity.Name = "tc.chen@advantech.com.tw" Then dlLeadFuncGrp.Visible = True
    End Sub
    Public Function isexist(ByVal contact_email As String) As Boolean
        If contact_email Is Nothing Then Return False
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select * from siebel_MyLeads where contact_email = '{0}' and company_id = '{1}'", contact_email, Session("company_id")))
        If dt.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function
    Private Function GetMyLeads(Optional ByVal Xls As Boolean = False) As String
        Dim retSql As String = Util.GetMyLeadsSql(Session("company_id"), Session("user_id"), rblAllOrPart.SelectedIndex, dlOpenCloseLeadOptions.SelectedIndex, Xls)
        Me.test.Text = retSql
        If True Then
            'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "GetMyLeads SQL", retSql, False, "", "")
        End If
        Return retSql       
    End Function
    
    Protected Sub dlRowStatus_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim tmpDl As DropDownList = CType(sender, DropDownList)
        Dim tmpGr As GridViewRow = CType(tmpDl.NamingContainer, GridViewRow)
        tmpDl.SelectedValue = OptyGv.DataKeys(tmpGr.RowIndex).Values(1).ToString()
    End Sub
    
    Protected Sub OptySrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        'OptySrc.SelectCommand = GetMyLeads()
        e.Command.CommandTimeout = 240
    End Sub

    Protected Sub OptyGv_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub OptyGv_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub OptyGv_SelectedIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSelectEventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub OptyGv_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub OptySrc_Updating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceCommandEventArgs)
       
        Dim gr As GridViewRow = OptyGv.Rows(OptyGv.EditIndex)

        Dim optyId As String = OptyGv.DataKeys(gr.RowIndex).Values(0).ToString()
        Dim newStatus As String = CType(gr.FindControl("dlRowStatus"), DropDownList).SelectedValue
        Dim newDesc As String = CType(gr.FindControl("txtRowDesc"), TextBox).Text
        Dim newAmt As String = HttpUtility.HtmlEncode(CType(gr.FindControl("txtRowAmt"), TextBox).Text)
        
        'Dim Account_RowID_List As List(Of Advantech.Myadvantech.DataAccess.SIEBEL_ACCOUNT) = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetSiebelAccountByERPID(Session("company_id"))
        'Dim Account_RowID As String = String.Empty
        'If (Account_RowID_List.Count > 0) Then
        '    Account_RowID = Account_RowID_List.Item(0).ROW_ID.ToString()
        'End If
                
        If Date.TryParse(CType(gr.FindControl("txtRowCloseDate"), TextBox).Text, Now) = False Then
            Util.AjaxJSAlert(up1, "Error Date Format") : e.Cancel = True : Exit Sub
        End If
        Dim newCloseDate As Date = CDate(CType(gr.FindControl("txtRowCloseDate"), TextBox).Text)
        
        If DateTime.Compare(newCloseDate, DateTime.Now) < 0 Then
            Util.AjaxJSAlert(up1, "Close date must be after today") : e.Cancel = True : Exit Sub
        End If
        
        Dim total As Decimal = 0
        Decimal.TryParse(newAmt, total)
        If total < 0 Then
            Util.AjaxJSAlert(up1, "Amount should not be negative") : e.Cancel = True : Exit Sub
        End If
        
        'ICC 2016/4/1 Update Amount, Status, Close date and Description
        Dim result As Tuple(Of Boolean, String) = Advantech.Myadvantech.DataAccess.SiebelDAL.UpdateSiebelOpty4PrjReg(optyId, newAmt, String.Empty, newStatus, newCloseDate, String.Empty, String.Empty, newDesc)
        
        If Not result.Item1 Then
            Util.SendEmail("MyAdvantech@advantech.com", "MyAdvantech@advantech.com", "Update Siebel opportunity failed about leads management!", result.Item2, True, String.Empty, String.Empty)
            Util.AjaxJSAlert(up1, "Error creating lead to Siebel(action), please contact MyAdvantech@advantech.com")
        Else
            'If Session("user_id") <> "tc.chen@advantech.com.tw" Then
            'End If
            SendCustUpdateOptyActionToSales(optyId, newStatus, newDesc, newAmt, newCloseDate, Session("user_id"))
            UpdateLocalOptyTable(optyId, newStatus, newDesc, newAmt, newCloseDate)
        End If
        Dim err1 As String = ""
        e.Cancel = True : Exit Sub
    End Sub

    Protected Sub OptyGv_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim optyId As String = DataBinder.Eval(OptyGv.SelectedRow, "ROW_ID")
        Session("OptyId") = optyId
        Util.AjaxRedirect(up1, "/Order/Cart_List.aspx")
    End Sub

    Protected Sub OptyGv_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub OptyGv_RowEditing(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewEditEventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub OptyGv_RowCancelingEdit(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub
    
    Private Function DateOnly(ByVal strDate As String) As String
        If Date.TryParse(strDate, Now) Then
            Return CDate(strDate).ToString("yyyy/MM/dd")
        End If
        Return strDate
    End Function
    
    Private Function TrimPhone(ByVal phone As String) As String
        Dim p() As String = Split(phone, vbLf)
        If p.Length > 0 Then Return p(0)
        Return phone
    End Function
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        ''''init
        
        ''''
        If Request("OPTYID") IsNot Nothing Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
            String.Format("select distinct row_id from siebel_account where erp_id='{0}' and row_id is not null ", Session("company_id")))
            If dt.Rows.Count > 0 Then
                Dim rid As New ArrayList
                For Each r As DataRow In dt.Rows
                    rid.Add("'" + r.Item("row_id") + "'")
                Next
                Dim strRid As String = "(" + String.Join(",", rid.ToArray()) + ")"
                Dim c As Object = dbUtil.dbExecuteScalar("CRMDB75", _
                String.Format("select count(A.ROW_ID) as OPTYCount from S_OPTY A where A.PR_PRTNR_ID in {0} and A.ROW_ID='{1}' ", strRid, Trim(Request("OPTYID")).Replace("'", "''")))
                
                'Ryan 20160325 Add for assigned user but is not maintained in Siebel
                If c Is Nothing OrElse CInt(c) = 0 Then
                    Dim MyAdt As DataTable = dbUtil.dbGetDataTable("MY", _
                    "select * from MyAdvantechGlobal.dbo.OPTY_ASSIGN_HISTORY where ROW_ID = '" & Session("company_id") & _
                    "' and CONTACT_EMAIL = '" & Session("user_id") & "'")
                    If MyAdt.Rows.Count > 0 Then
                        
                    Else
                        Response.Redirect("/Order/Cart_List.aspx")
                    End If
                End If
                'If c IsNot Nothing AndAlso CInt(c) = 1 Then
                '    Session("OptyId") = Trim(Request("OPTYID"))
                '    Session("DMFFlag") = True
                '    Response.Redirect("/Order/Cart_List.aspx")
                'End If
            End If
        End If
        If Session("user_id") = "ming.zhao@advantech.com.cn" Then
            'Me.test.Visible = True
        End If
    End Sub
    
    Public Function UpdateLocalOptyTable(ByVal OptyId As String, ByVal OptyStatus As String, ByVal OptyDesc As String, ByVal OptyAmt As String, ByVal OptyCloseDate As Date) As Boolean
        Dim sql As New StringBuilder : Dim OptyDesc_values As String = ""
        If OptyDesc.Replace("'", "''").Trim.Length > 2000 Then
            OptyDesc_values = OptyDesc.Replace("'", "''").Trim.Substring(0, 2000)
        Else
            OptyDesc_values = OptyDesc.Replace("'", "''").Trim
        End If
        With sql
            .AppendFormat("update siebel_opportunity set status_cd='{0}', desc_text='{1}', SUM_REVN_AMT='{2}', SUM_EFFECTIVE_DT='{3}' ", OptyStatus, OptyDesc_values, CDbl(OptyAmt), OptyCloseDate)
            If OptyStatus = "Won" Then .AppendFormat(", STAGE_NAME='100% Won-PO Input in SAP' ")
            If OptyStatus = "Lost" Then .AppendFormat(", STAGE_NAME='0% Lost' ")
            .AppendFormat(" where row_id='{0}'; ", OptyId)
            .AppendFormat(" INSERT INTO OPTY_UPDATE_LOG ")
            .AppendFormat(" (ROW_ID, STATUS, DESC_TEXT, SUM_AMOUNT, CLOSE_DATE, UPD_BY, UPD_DATE) ")
            .AppendFormat(" VALUES     (N'{0}', N'{1}', N'{2}', {3}, '{4}', N'{5}', GETDATE()) ", OptyId, OptyStatus, OptyDesc_values, CDbl(OptyAmt), OptyCloseDate, Session("user_id"))
        End With
        If dbUtil.dbExecuteNoQuery("MY", sql.ToString) > 0 Then
            Return True
        End If
        Return False
    End Function
    
    Public Sub SendCustUpdateOptyActionToSales(ByVal OptyId As String, ByVal NewStatus As String, ByVal NewDesc As String, ByVal NewAmt As String, ByVal NewCloseDate As Date, ByVal UpdateByEmail As String)
        Dim dt As DataTable = GetOptyDetail(OptyId)
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Dim salesEmail As String = dt.Rows(0).Item("sales_email")
            Dim salesName As String = dt.Rows(0).Item("sales")
            Dim accountName As String = dt.Rows(0).Item("account_name")
            'Dim creatorEmail As String = dt.Rows(0).Item("creator_email")
            Dim OptyName As String = dt.Rows(0).Item("name")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format("Dear {0},<br/><br/>", salesName))
                .AppendLine(String.Format(" Account: <b>{0}</b><br/>", accountName))
                .AppendLine(String.Format(" Contact: <b>{0}</b><br/> Updated sales leads <b>{1}</b> to status <b>{2}</b>.<br/>", UpdateByEmail, OptyName, NewStatus))
                .AppendLine(String.Format(" Revenue: <b>{0}</b><br/>", NewAmt))
                .AppendLine(String.Format(" Close Date: <b>{0}</b><br/>", NewCloseDate.ToString("yyyy/MM/dd")))
                .AppendLine(String.Format(" Reason/Description:<br/>{0}<br/>", NewDesc))
                .AppendLine(String.Format("<br/>"))
                .AppendLine(String.Format("Best regards,<br/>"))
                .AppendLine(String.Format("<b><a href='mailto:myadvantech@advantech.com'>MyAdvantech</a></b>"))
                '.AppendLine(String.Format(""))
            End With
            If Not salesEmail Like "*@*.*" Then
                salesEmail = "myadvantech@advantech.com"
            End If
            Dim ccemail As String = "myadvantech@advantech.com,ChannelManagement.ACL@advantech.com"
            'salesEmail = "chentc@gmail.com"
            If Session("company_id") IsNot Nothing Then
                Dim ISDt As DataTable = GetISFromCompanyId(Session("company_id"))
                Dim OptyTeamDt As DataTable = dbUtil.dbGetDataTable("MY", "select email from opty_team where company_id='" + Session("company_id") + "'")
                If ISDt.Rows.Count = 1 AndAlso salesEmail <> "" Then
                    salesEmail += "," + ISDt.Rows(0).Item("email")
                End If
                If OptyTeamDt.Rows.Count > 0 Then
                    For Each r As DataRow In OptyTeamDt.Rows
                        salesEmail += "," + r.Item("email")
                    Next
                End If
                'add  2009331            
                If Isleadslists(Session("company_id").ToString.Trim) Then
                    ccemail += "," + "cristina.ravaioli@advantech.it"
                End If
                'end
                
                'add other opty owners
                Dim dtOwner As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("select  IsNull(c.EMAIL_ADDR,'')  from S_OPTY_POSTN a inner join S_POSTN b on a.POSITION_ID=b.ROW_ID inner join S_CONTACT c on b.PR_EMP_ID=c.ROW_ID where a.OPTY_ID='{0}'", OptyId))
                For Each row As DataRow In dtOwner.Rows
                    If LCase(row.Item(0).ToString) <> LCase(dt.Rows(0).Item("sales_email").ToString) AndAlso Not String.IsNullOrEmpty(row.Item(0).ToString) Then
                        ccemail += "," + row.Item(0).ToString
                    End If
                Next
            End If
            If Util.IsTesting() Then
                Util.SendEmail("ic.chen@advantech.com.tw,yl.huang@advantech.com.tw,tc.chen@advantech.com.tw", "MyAdvantech@advantech.com", "MyAdvantech Sales Leads Updated By " + UpdateByEmail, _
                               "To Email: " + salesEmail + "<br/> CC: " + ccemail + "<br/>" + sb.ToString, True, "", "")
            Else
                Util.SendEmail(salesEmail, "MyAdvantech@advantech.com", "MyAdvantech Sales Leads Updated By " + UpdateByEmail, _
                               sb.ToString, True, ccemail, "")
            End If
        End If
    End Sub
    
    Public Function GetOptyDetail(ByVal OptyId As String) As DataTable
        'ICC 2016/4/8 Change SQL
        'Dim sb As New System.Text.StringBuilder
        'With sb
        '    .AppendLine(String.Format("  select a.ROW_ID, a.NAME, a.STATUS_CD, b.NAME as account_name, IsNull(a.DESC_TEXT,'') as desc_text,  a.PR_POSTN_ID, "))
        '    .AppendLine(String.Format("  IsNull((select top 1 z1.EMAIL_ADDR from S_CONTACT z1 inner join S_POSTN z2 on z1.ROW_ID=z2.PR_EMP_ID where z2.ROW_ID=a.PR_POSTN_ID),'ebusiness.aeu@advantech.eu') as SALES_EMAIL, "))
        '    .AppendLine(String.Format("  IsNull((select top 1 z1.EMAIL_ADDR from S_CONTACT z1 inner join S_POSTN z2 on z1.ROW_ID=z2.PR_EMP_ID where z2.ROW_ID=a.PR_POSTN_ID),'ebusiness.aeu@advantech.eu') as SALES, "))
        '    .AppendLine(String.Format("  IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID=a.CREATED_BY),'ebusiness.aeu@advantech.eu') as creator_email "))
        '    .AppendLine(String.Format("  from S_OPTY a inner join S_ORG_EXT b on a.PR_DEPT_OU_ID=b.ROW_ID   "))
        '    .AppendFormat(" where a.ROW_ID='{0}' ", OptyId)
        'End With
        'Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", _
        String.Format(" select a.ROW_ID, a.NAME, a.STATUS_CD, b.NAME as account_name, IsNull(a.DESC_TEXT,'') as desc_text, " + _
                      " IsNull(d.EMAIL_ADDR,'ebusiness.aeu@advantech.eu') as sales_email, IsNull(d.EMAIL_ADDR,'ebusiness.aeu@advantech.eu') as sales, " + _
                      " IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID=a.CREATED_BY),'ebusiness.aeu@advantech.eu') as creator_email " + _
                      " from S_OPTY a inner join S_ORG_EXT b on a.PR_PRTNR_ID=b.ROW_ID inner join S_POSTN c on b.PR_POSTN_ID=c.ROW_ID inner join S_CONTACT d on c.PR_EMP_ID=d.ROW_ID where a.ROW_ID='{0}' ", OptyId))
        For Each r As DataRow In dt.Rows
            If r.Item("sales").ToString Like "*@*" Then
                Dim mp() As String = Split(r.Item("sales").ToString(), "@")
                r.Item("sales") = mp(0).Trim()
            End If
        Next
        dt.AcceptChanges()
        Return dt
    End Function
    
    Protected Sub dlLeadFuncGrp_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect(dlLeadFuncGrp.SelectedValue, False)
    End Sub
    
    Public Function GetISFromCompanyId(ByVal companyid As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        "select top 1 b.sales_code, b.full_name, b.email " + _
        " from sap_company_employee a inner join sap_employee b on a.sales_code=b.sales_code " + _
        " where a.partner_function='Z2' and b.full_name not in ('OP CE.OP CENTRAL EUROPE','OP EE.OP EAST EUROPE','OP NE.OP NORTH EUROPE','OP SE.OP SOUTH EUROPE') and a.sales_org='EU10' and b.email like '%@%advantech%.%' and a.company_id in ('{0}')", _
        companyid))
        Return dt
    End Function
    
    Protected Sub lnkAddMe2OptyTeam_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        dbUtil.dbExecuteNoQuery("MY", String.Format("insert into OPTY_TEAM(company_id,email) values (N'{0}',N'{1}')", Session("company_id"), Session("user_id")))
        lnkAddMe2OptyTeam.Text = "You will be informed when customer update leads" : lnkAddMe2OptyTeam.Enabled = False
    End Sub

    Protected Sub lnkAddMe2OptyTeam_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim i As Integer = dbUtil.dbExecuteScalar("MY", String.Format("select count(*) from OPTY_TEAM where company_id='{0}' and email='{1}'", Session("company_id"), Session("user_id")))
        If i > 0 Then
            lnkAddMe2OptyTeam.Text = "You will be informed when customer update leads" : lnkAddMe2OptyTeam.Enabled = False
        End If
    End Sub

    Protected Sub rblAllOrPart_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub OptyGv_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        'If Not Page.IsPostBack AndAlso e.Row.RowType = DataControlRowType.DataRow Then
        '    If Request("ACTIONID") IsNot Nothing AndAlso DataBinder.Eval(e.Row.DataItem, "ROW_ID") = Trim(Request("ACTIONID")) Then
        '        e.Row.RowState = DataControlRowState.Edit
        '    End If
        'End If
    End Sub
    
    Function GetOptyDescFromLocalLog(ByVal OptyId As String, ByVal OptySiebelDesc As String) As String
        Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 desc_text from opty_update_log where row_id='{0}' order by upd_date desc", OptyId.Replace("'", "''")))
        If obj IsNot Nothing Then Return obj.ToString()
        Return OptySiebelDesc
    End Function

    Protected Sub dlOpenCloseLeadOptions_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        OptySrc.SelectCommand = GetMyLeads()
    End Sub

    Protected Sub btnXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)           
        Dim sql As String = GetMyLeads(True)      
        If IsNothing(sql) Or sql = "" Then
            Util.AjaxJSAlert(Me.up1, "No information to export")
        Else
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sql)
            If dt.Rows.Count > 0 Then
                dt.TableName = "MyLeads"             
                Util.DataTable2ExcelDownload(dt, "MyLeads_" + Now.ToString("dd-MM-yyyy") + ".xls")
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <style type="text/css">

.aa {
	border-bottom-width: 1px;
	border-bottom-style: solid;
	border-bottom-color: Navy;
}
</style>
    
    <asp:TextBox ID="HiddenField1" Visible="false" runat="server"></asp:TextBox>
     <ajaxToolkit:CalendarExtender runat="server" ID="HiddenField1calendar"  TargetControlID="HiddenField1" Format="yyyy/MM/dd" />
       <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="HiddenField1Filtered" FilterMode="ValidChars" 
                                           TargetControlID="HiddenField1" ValidChars="012345689." />
    <table width="100%">
        <tr>            
            <th align="left" style="font-size:large; color:Navy; width:150px">My Sales Leads</th>
            <td align="right">
                <table>
                    <tr>
                        <td colspan="2">
                            <asp:Panel runat="server" ID="chgcompanypanel1" Width="250px" ScrollBars="Auto" BorderWidth="1px" HorizontalAlign="Left">
                                <asp:LoginView runat="server" ID="ChangeCompanyView">
                                    <RoleGroups>
                                        <asp:RoleGroup Roles="Logistics,Administrator">
                                            <ContentTemplate>
                                                <b>Change Company:</b><uc1:ChangeCompany ID="ChangeCompany1" runat="server"/><br />
                                                <asp:UpdatePanel runat="server" ID="upAddMeOptyTeam" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        &nbsp;<asp:LinkButton runat="server" ID="lnkAddMe2OptyTeam" Text="Inform me when customer update leads" OnClick="lnkAddMe2OptyTeam_Click" OnInit="lnkAddMe2OptyTeam_Init" />                                                        
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>                                                
                                            </ContentTemplate>
                                        </asp:RoleGroup>
                                    </RoleGroups>
                                </asp:LoginView>
                            </asp:Panel>  
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:HyperLink runat="server" ID="hyCPGuide" Text="Sales Leads Management User Guide" NavigateUrl="~/Files/leads_mgt_cp.pdf" />
                        </td>
                        <td>
                            <asp:DropDownList Visible="false" runat="server" ID="dlLeadFuncGrp" Width="150px" AutoPostBack="true" OnSelectedIndexChanged="dlLeadFuncGrp_SelectedIndexChanged">
                                <asp:ListItem Text="My Leads" Value="/My/MyLeads.aspx" Selected="True" />
                                <asp:ListItem Text="My Projects" Value="/My/MyProject.aspx" />
                                <asp:ListItem Text="Feedback Leads" Value="/My/FeedbackPrj.aspx" Enabled="false" />
                            </asp:DropDownList>      
                        </td>
                    </tr>
                    <tr><td colspan="2"><asp:HyperLink ID="LeadsMgrAdmin"  Font-Underline="True" Font-Size="12px"  Target="_blank" ForeColor="Red" Visible="false" runat="server" NavigateUrl="LeadsMgrAdmin.aspx">Channel Partner Leads Manager Administration</asp:HyperLink></td></tr>
                </table>                              
            </td>
        </tr>
        <tr>            
            <td colspan="2">
                <asp:UpdatePanel runat="server" ID="up1" >
                    <ContentTemplate>
                <%--     </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnXls" />
                    </Triggers>
                </asp:UpdatePanel>--%>
                 
                        <asp:RadioButtonList Visible="false" AutoPostBack="true" runat="server" ID="rblAllOrPart" RepeatColumns="2" RepeatDirection="Horizontal" OnSelectedIndexChanged="rblAllOrPart_SelectedIndexChanged">
                            <asp:ListItem Text="Leads assigned to current partner" Selected="True" />
                            <asp:ListItem Text="All Leads assigned to partner" />
                        </asp:RadioButtonList>
                        <asp:DropDownList runat="server" ID="dlOpenCloseLeadOptions" Width="170px" AutoPostBack="true" OnSelectedIndexChanged="dlOpenCloseLeadOptions_SelectedIndexChanged">
                            <asp:ListItem Text="Unclosed/Pending Leads" Selected="True"/>
                            <asp:ListItem Text="Closed/Won or Lost Leads" />
                            <asp:ListItem Text="All Leads"   />
                        </asp:DropDownList><br />
                        <asp:ImageButton runat="server" ID="btnXls" ImageUrl="~/Images/excel.gif" AlternateText="Download Excel" OnClick="btnXls_Click" />
                        <asp:GridView runat="server" ID="OptyGv" Width="98%" PageSize="10" AllowPaging="true" 
                            DataKeyNames="ROW_ID,STATUS_CD,NAME,SALES_TEAM_LOGIN,DESC_TEXT,SUM_REVN_AMT" 
                            AllowSorting="true" DataSourceID="OptySrc" AutoGenerateColumns="false" 
                            OnSorting="OptyGv_Sorting" PagerSettings-Position="TopAndBottom" 
                            OnPageIndexChanging="OptyGv_PageIndexChanging" 
                            OnSelectedIndexChanging="OptyGv_SelectedIndexChanging" OnRowUpdating="OptyGv_RowUpdating" 
                            OnSelectedIndexChanged="OptyGv_SelectedIndexChanged" OnPageIndexChanged="OptyGv_PageIndexChanged" 
                            OnRowEditing="OptyGv_RowEditing" OnRowCancelingEdit="OptyGv_RowCancelingEdit" OnRowDataBound="OptyGv_RowDataBound">
                            <Columns>
                                <asp:CommandField HeaderText="Actions" ShowEditButton="true" EditText="Edit" ItemStyle-HorizontalAlign="Center" />  
                                <asp:TemplateField HeaderText="Order" SortExpression="ROW_ID" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <a href='MyLeads.aspx?OPTYID=<%# Eval("ROW_ID") %>'>Go</a> 
                                    </ItemTemplate>
                                </asp:TemplateField>                               
                                <asp:TemplateField HeaderText="Description" >
                                    <ItemTemplate>
                                       
               <table width="100%" border="0">
               <tr><td width="70" align="right"> <b style="color:Navy;">Status:</b></td> <td width="70" align="left"><span  class="aa"> <%# Eval("STATUS_CD") %></span></td>     
                   <td width="70" align="right"> <b style="color:Navy;">Name:</b></td><td align="left"> <span  class="aa"><%# Eval("NAME") %></span></td>
               </tr>              
               <tr><td align="right"><b style="color:Navy;">Currency:</b></td><td align="left"><span  class="aa"><%#Eval("CURCY_CD")%></span></td>
                  <td  align="right"> <b style="color:Navy;">Amount:</b></td><td align="left"><span  class="aa"><%#Eval("SUM_REVN_AMT") %></span></td>
               </tr>                
               <tr><td align="right"><b style="color:Navy;">Create Date:</b></td><td align="left"><span  class="aa"><%#DateOnly(Eval("CREATED")) %></span></td>
                 <td  align="right"><b style="color:Navy;">Close Date:</b></td><td align="left"> <span  class="aa"><%#DateOnly(Eval("SUM_EFFECTIVE_DT")) %></span></td>                
               </tr>               
                 <tr><td> <b style="color:Navy;">Description:</b></td>
                     <td colspan="3"> <%#GetOptyDescFromLocalLog(Eval("ROW_ID"),Eval("DESC_TEXT")) %>
                   
                     </td>
                 </tr>             
                                
                   </table>     
                              
                                    </ItemTemplate>                                                                  
                                    <EditItemTemplate>
                <table width="100%" border="0" bgcolor="#FFFFCC">
               <tr>
                   <td align="right"><b style="color:Navy;">Status:</b></td><td> <asp:DropDownList runat="server" ID="dlRowStatus" OnDataBinding="dlRowStatus_DataBinding">
                                            <asp:ListItem Text="Accepted" Value="Accepted" />
                                            <asp:ListItem Text="Invalid" Value="Invalid" Enabled="false" />
                                            <asp:ListItem Text="Lost" Value="Lost" />
                                            <asp:ListItem Text="Pass/Assign" Value="Pass/Assign" Enabled="false" />
                                            <asp:ListItem Text="Pending" Value="Pending" />
                                            <asp:ListItem Text="Rejected" Value="Rejected" />
                                            <asp:ListItem Text="Rerouted" Value="Rerouted" Enabled="false" />
                                            <asp:ListItem Text="Won" Value="Won" />
                                        </asp:DropDownList></td>
                   <td align="right"> <b style="color:Navy;">Name:</b></td><td><span  class="aa"><%# Eval("NAME") %></span></td>
               </tr>
                 <tr>
                   <td align="right"> <b style="color:Navy;">Currency:</b></td><td><span  class="aa"><%#Eval("CURCY_CD")%></span></td>
                   <td align="right"><b style="color:Navy;">Amount:</b></td>
                   <td><asp:TextBox runat="server" ID="txtRowAmt" Text='<%#Eval("SUM_REVN_AMT") %>' />
                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeRowAmt" FilterMode="ValidChars" 
                                           TargetControlID="txtRowAmt" ValidChars="0123456789." />
                   </td>
               </tr>
                 <tr>
                   <td align="right"><b style="color:Navy;">Create Date:</b></td><td><span  class="aa"><%#DateOnly(Eval("CREATED")) %></span></td>
                   <td align="right"> <b style="color:Navy;">Close Date:</b></td>
                   <td>
                     <asp:TextBox runat="server" ID="txtRowCloseDate" Text='<%#DateOnly(Eval("SUM_EFFECTIVE_DT")) %>' />
                     <ajaxToolkit:CalendarExtender runat="server" ID="ceRowCloseDate"  TargetControlID="txtRowCloseDate" Format="yyyy/MM/dd" PopupPosition="BottomRight" />
                   </td>
               </tr>
               <tr><td colspan="4"> <b style="color:Navy;">Description:</b></td> </tr>
               <tr>  <td colspan="4">                                                                             
                      <asp:TextBox runat="server" MaxLength="220" ID="txtRowDesc" Text='<%#GetOptyDescFromLocalLog(Eval("ROW_ID"),Eval("DESC_TEXT")) %>' Width="550"  Height="230" Rows="50" TextMode="MultiLine" /> 
                    </td>         
               </tr>
               </table>
                                         
                        
                                    </EditItemTemplate>
                                </asp:TemplateField>                                
                                <asp:BoundField DataField="ROW_ID" HeaderText="ROW ID" ReadOnly="True" SortExpression="ROW_ID" />
                              <%--  <asp:BoundField DataField="NAME" HeaderText="Name" SortExpression="NAME" ReadOnly="true" /> 
                                <asp:BoundField DataField="CURCY_CD" HeaderText="Currency" SortExpression="CURCY_CD" ReadOnly="true" ItemStyle-HorizontalAlign="Center" /> --%>                              
                               <%-- <asp:TemplateField HeaderText="Amount" SortExpression="SUM_REVN_AMT" ItemStyle-HorizontalAlign="Right">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lbRowAmt" Text='<%#Eval("SUM_REVN_AMT") %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:TextBox runat="server" ID="txtRowAmt" Text='<%#Eval("SUM_REVN_AMT") %>' />
                                        <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeRowAmt" FilterMode="ValidChars" FilterType="Custom,Numbers" TargetControlID="txtRowAmt" ValidChars="." />
                                    </EditItemTemplate>
                                </asp:TemplateField>--%>
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
                                                <td><%#TrimPhone(Eval("ACCOUNT_PHONE"))%></td>
                                            </tr>
                                            <tr>
                                                <th align="left" style="width:80px; color:Navy;">Lead Contact</th>
                                                <td><a href='mailto:<%#Eval("CONTACT_EMAIL")%>'><%#Eval("CONTACT")%></a></td>
                                            </tr>
                                            <tr>
                                                <th align="left" style="width:80px; color:Navy;">Contact Phone</th>
                                                <td><%#TrimPhone(Eval("CONTACT_PHONE"))%></td>
                                            </tr>                                            
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="CURR_STG_ID" HeaderText="Current Stage" Visible="false" SortExpression="CURR_STG_ID" />
                                <asp:BoundField DataField="STAGE_NAME" HeaderText="Current Stage" Visible="false" ReadOnly="True" SortExpression="STAGE_NAME" />
                                <asp:BoundField DataField="BU_ID" HeaderText="BU_ID" SortExpression="BU_ID" Visible="false" />
                                <asp:BoundField DataField="BU_NAME" HeaderText="BU NAME" SortExpression="BU_NAME" Visible="false" ReadOnly="true" />
                                <%--<asp:TemplateField HeaderText="Create Date" SortExpression="CREATED" ItemStyle-HorizontalAlign="Center" 
                                    ItemStyle-Width="80px" HeaderStyle-Width="80px">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lbCDate1" Text='<%#DateOnly(Eval("CREATED")) %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:Label runat="server" ID="lbCDate2" Text='<%#DateOnly(Eval("CREATED")) %>' />
                                    </EditItemTemplate>
                                </asp:TemplateField>--%> 
                                <%--<asp:TemplateField HeaderText="Close Date" SortExpression="SUM_EFFECTIVE_DT" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="80px" HeaderStyle-Width="80px">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lbRowCloseDate" Text='<%#DateOnly(Eval("SUM_EFFECTIVE_DT")) %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:TextBox runat="server" ID="txtRowCloseDate" Text='<%#DateOnly(Eval("SUM_EFFECTIVE_DT")) %>' />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="ceRowCloseDate" TargetControlID="txtRowCloseDate" Format="yyyy/MM/dd" />
                                    </EditItemTemplate>
                                </asp:TemplateField>--%>
                                <asp:BoundField DataField="CREATED_BY_LOGIN" HeaderText="CREATED_BY_LOGIN" Visible="false" SortExpression="CREATED_BY_LOGIN" />
                                <asp:BoundField DataField="CREATED_BY_NAME" HeaderText="Created By" Visible="false" ReadOnly="True" SortExpression="CREATED_BY_NAME" />                                
                               <%-- <asp:TemplateField HeaderText="Description" SortExpression="DESC_TEXT">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lblRowDesc" Text='<%#GetOptyDescFromLocalLog(Eval("ROW_ID"),Eval("DESC_TEXT")) %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                      
                                            <asp:TextBox runat="server" MaxLength="2000" ID="txtRowDesc" Text='<%#GetOptyDescFromLocalLog(Eval("ROW_ID"),Eval("DESC_TEXT")) %>' Width="300"  Height="250" Rows="50" TextMode="MultiLine" />
                                                                           
                                    </EditItemTemplate>
                                </asp:TemplateField>--%>
                                <asp:BoundField DataField="LAST_UPD" HeaderText="Last Updated Date" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:yyyy/MM/dd}"  ReadOnly="True" Visible="true" SortExpression="LAST_UPD" />
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
                                <asp:TemplateField HeaderText="Lead Partner Contact" SortExpression="ChannelContact">
                                    <ItemTemplate>
                                        <asp:UpdatePanel runat="server" ID="OptyPtnrContactUp" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <uc1:OptyPtnrContact runat="server" ID="rowOptyContact" AccountRowId='<%#Eval("PR_PRTNR_ID") %>' 
                                                    ContactRowId='<%#Eval("ATTRIB_46") %>' OptyRowId='<%#Eval("ROW_ID") %>' />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>                                        
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <%--<asp:BoundField HeaderText="Contact Id" DataField="ATTRIB_46" />--%>
                            </Columns>
                            <%--<FixRowColumn FixColumns="-1" FixRows="-1" FixRowType="Header" TableHeight="300px" TableWidth="99%" />--%>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="OptySrc" ConnectionString="<%$ ConnectionStrings:CRMAPPDB %>"                             
                            SelectCommand="" UpdateCommand="select getdate()" OnSelecting="OptySrc_Selecting" OnUpdating="OptySrc_Updating">
                        </asp:SqlDataSource>
                           <asp:Label runat="server" ID="test"  Visible="false"   ></asp:Label>
                           <asp:Label runat="server" ID="test2" Visible="false"   ></asp:Label>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnXls" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
 
</asp:Content>

