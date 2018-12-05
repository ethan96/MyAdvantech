<%@ Page Title="MyAdvantech - All Registered Projects" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Function GetSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" Select top 1000 a.Request_id,a.Appliciant,a.Project_Name,a.CPartner,a.Contact,a.Phone,a.Email,a.City1,a.State1,a.AdvSalesContact, "))
            .AppendLine(String.Format(" a.Company,a.Address,a.City2,a.State2,a.Comment,a.Reject_Reason,ISNULL(CONVERT(varchar(100), a.Expire_Date, 101),'') as Expire_Date ,ISNULL(CONVERT(varchar(100), a.reg_date, 101),'') as reg_date , "))
            .AppendLine(String.Format(" case ISNULL(a.OPTY_ID,'N/A') when '' then 'N/A' else ISNULL(a.OPTY_ID,'N/A') end as OPTY_ID, a.Contact1,a.ContactPhone1,a.ContactEMail1,a.Contact2, "))
            .AppendLine(String.Format(" a.ContactPhone2,a.ContactEMail2,a.Prototype_Date,a.Production_Date,a.internal_comment,a.Org_ID,a.Approve_Code,a.Status, a.Expire_Date, "))
            .AppendLine(String.Format(" a.Approve_Date1,a.Approve_Date2,a.Reg_date, "))
            .AppendLine(String.Format(" IsNull((select top 1 z.account_name from siebel_account z where z.erp_id=a.CPartner and z.erp_id<>'' order by z.account_status),'') as CPName ,ISNULL(EndCustomer,'') as EndCustomer,"))
            .AppendLine(String.Format("  ISNULL( (select top 1 z.account_name from siebel_account z where z.ROW_ID=a.EndCustomer and z.erp_id<>'' and a.EndCustomer <>'' and a.EndCustomer is not null order by z.account_status ) ,a.Company) as EndCustomerName "))
            .AppendLine(String.Format(" From US_PrjReg_Mstr a  "))
            .AppendLine(String.Format(" where 1=1 "))
            If Util.IsInternalUser(Session("user_id")) Then
                If Util.IsANAPowerUser() = False And Util.IsAEUIT() = False Then
                    .AppendLine(String.Format( _
                                " and (a.CPartner in (select z.erp_id from siebel_account z " + _
                                " where z.erp_id<>'' and z.erp_id is not null " + _
                                " and z.primary_sales_email like '{0}@advantech%.%') or AdvSalesContact='{1}') ", _
                                Util.GetNameVonEmail(Session("user_id")), Session("user_id")))
                End If
            Else
                .AppendLine(String.Format(" and (a.Appliciant='{0}' or a.Email='{0}') ", Session("user_id")))
            End If
            If txtCPName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.CPartner in (select z.erp_id from siebel_account z where z.account_name like N'%{0}%' and z.erp_id<>'') ", txtCPName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            Dim expFrom As Date = DateAdd(DateInterval.Year, -1, Now), expTo As Date = DateAdd(DateInterval.Year, 1, Now)
            If txtExpDateFrom.Text.Trim() <> "" Then
                Date.TryParseExact(txtExpDateFrom.Text, "MM/dd/yyyy", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, expFrom)
            End If
            If txtExpDateTo.Text.Trim() <> "" Then
                Date.TryParseExact(txtExpDateTo.Text, "MM/dd/yyyy", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, expTo)
            End If
            .AppendLine(String.Format(" and a.Expire_Date between '{0}' and '{1}' ", expFrom.ToString("yyyy-MM-dd"), expTo.ToString("yyyy-MM-dd")))

            If dlAppStatus.SelectedIndex > 0 Then
                .AppendLine(String.Format(" and a.Status=N'{0}' ", dlAppStatus.SelectedValue.Replace("'", "''")))
            End If
            If dlQStage.SelectedIndex > 0 Then
                .AppendLine(String.Format(" and a.OPTY_ID in (select row_id from SIEBEL_OPPORTUNITY where CREATED>=GETDATE()-180 and STAGE_NAME=N'{0}') ", dlQStage.SelectedValue.Replace("'", "''")))
            End If
            'If Not USPrjRegUtil.IsSalesLeader(Session("RBU")) Then
            '    .AppendLine(String.Format(" and ( a.AdvSalesContact = '{0}'  or a.Appliciant ='{0}') ", Session("user_id")))
            'End If
            .AppendLine(String.Format(" order by EndCustomerName desc  "))
        End With
        'Response.Write(sb.ToString()) : Response.End()
        Return sb.ToString()
    End Function
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then

            If Session("user_id") Is Nothing OrElse Session("user_id").ToString() = "" Then
                Response.Redirect("../home.aspx?ReturnUrl=" + Request.ServerVariables("URL"))
                Response.End()
            End If

            'JJ 2014/4/3 如果是InterCon.ALL這個Group的人員在home_ez上是隱藏的，所以如果直接用URL連結就導回首頁
            If MailUtil.IsInMailGroup("InterCon.ALL", Session("user_id")) Then
                Response.Redirect("~/home.aspx")
                Response.End()
            End If

            If Session("org_id") <> "US01" Then
                Response.Redirect("InterCon/PrjList.aspx")
            End If
            If Util.IsInternalUser(Session("user_id")) = False Then
                If Session("account_status") <> "CP" Then
                    Server.Transfer("~/home.aspx")
                Else
                    If Session("RBU") <> "AENC" And Session("RBU") <> "AAC" Then
                        Server.Transfer("~/home.aspx")
                    End If
                End If
                hPTitle.InnerText = "My Registered Projects" : Me.Title = "My Registered Projects"
            End If
        End If
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then

            USPrjRegUtil.SyncUSPrjOpty()
            ' src1.SelectCommand = GetSql()      
            GVDataBind()
            If Util.IsInternalUser(Session("user_id")) = False Then
                txtCPName.Visible = False : THcp.Visible = False
            End If
            imgXls.Visible = txtCPName.Visible
        End If
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not Util.IsInternalUser2() Then
            e.Row.Cells(0).Visible = False
        End If
        If e.Row.RowType = DataControlRowType.DataRow Then
            If gv1.DataKeys(e.Row.RowIndex).Values(1).ToString.Trim = "N/A" Then
                e.Row.Cells(5).Text = "No submitted"
                e.Row.Cells(2).Text = String.Format("<a href=""ProjectRegDetail.aspx?req={0}"" target=""_blank"" >{1}</a>", gv1.DataKeys(e.Row.RowIndex).Values(0), e.Row.Cells(2).Text)
            Else
                e.Row.Cells(2).Text = String.Format("<a href=""ProjectApprove.aspx?req={0}"" target=""_blank"" >{1}</a>", gv1.DataKeys(e.Row.RowIndex).Values(0), e.Row.Cells(2).Text)
            End If
            If e.Row.Cells(5).Text = "Request" Then
                e.Row.Cells(5).BackColor = Drawing.Color.Tomato : e.Row.Cells(5).ForeColor = Drawing.Color.White
            End If
            e.Row.Cells(1).Width = 300
        End If
    End Sub
    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("UpdatedStage") IsNot Nothing Then
            Dim sp() As String = Split(ViewState("UpdatedStage"), "|")
            Try
                'CType(gv1.Rows(sp(1)).FindControl("lbRowStage"), Label).Text = sp(0)
                gv1.Rows(sp(1)).Cells(4).Text = sp(0)
            Catch ex As Exception
            End Try
            ViewState("UpdatedStage") = Nothing
        End If
    End Sub
    Protected Sub dlRowStage_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim tmpDl As DropDownList = CType(sender, DropDownList)
        Dim tmpGr As GridViewRow = CType(tmpDl.NamingContainer, GridViewRow)
        ' tmpDl.SelectedValue = gv1.DataKeys(tmpGr.RowIndex).Values(1).ToString()       
        If gv1.DataKeys(tmpGr.RowIndex).Values(1).ToString.Trim <> "N/A" Then
            Dim sql As String = " select NAME from S_STG where ROW_ID = (SELECT TOP 1 CURR_STG_ID FROM  S_OPTY  WHERE ROW_ID = '" + gv1.DataKeys(tmpGr.RowIndex).Values(1).ToString.Trim + "' )"
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMAPPDB", sql)
            If dt.Rows.Count > 0 Then
                tmpDl.SelectedValue = dt.Rows(0).Item("NAME").ToString
            End If

        End If
    End Sub
    Protected Sub gv1_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        If gv1.DataKeys(e.RowIndex).Values(1).ToString <> "N/A" Then
            Dim DL As DropDownList = CType(gv1.Rows(e.RowIndex).Cells(4).FindControl("dlRowStage"), DropDownList)
            Dim TB As TextBox = CType(gv1.Rows(e.RowIndex).Cells(8).FindControl("TB1"), TextBox)
            Dim TBEndCustomer As TextBox = CType(gv1.Rows(e.RowIndex).Cells(8).FindControl("TBEndCustomer"), TextBox)
            '------------------------- Check EndCustomer
            Dim Error_Str As String = ""
            If USPrjRegUtil.CheckEndCustomer(TBEndCustomer.Text, Error_Str) = False Then
                Util.AjaxJSAlert(upPrjList, Error_Str)
                src1.SelectCommand = GetSql()
                Exit Sub
            End If
            '--------------------------
            Dim M As New Us_Prjreg_M(gv1.DataKeys(e.RowIndex).Values(0).ToString.Trim)
            M.EndCustomer = TBEndCustomer.Text.Trim.Replace("'", "''")
            M.Expire_Date = CDate(TB.Text)
            M.Reject_Reason = ""
            M.UPDAYE_M()
            Dim b As Boolean = False
            b = USPrjRegUtil.update_Siebel(M.Request_id, DL.SelectedValue.ToString.Trim)
            If Not b Then
                Util.AjaxJSAlert(upPrjList, "Error creating Project Registration to Siebel")
            Else
                ViewState("UpdatedStage") = DL.SelectedValue.ToString.Trim() + "|" + e.RowIndex.ToString()
            End If
        End If
        'src1.SelectCommand = GetSql()
        GVDataBind()
    End Sub
    Protected Function GetData(ByVal obj As Object) As DataTable
        Dim sql As String = "select Part_no, Qty, cast(CPricing as numeric(18,2)) as CPricing, cast(SPPricing as numeric(18,2)) as SPPricing,  " + _
            " cast(TargetPricing as numeric(18,2)) as TargetPricing, cast(ApprovedPricing as numeric(18,2)) as ApprovedPricing, " + _
            " cast(DebitPricing as numeric(18,2)) as DebitPricing from US_PrjReg_Det  where request_id='" + obj.ToString() + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql)
        Return dt
    End Function

    Public Sub GVDataBind()
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", GetSql())
        If txtEndCustName.Text.Trim() <> "" Then
            dt.DefaultView.RowFilter = String.Format(" Company like '%{0}%'  or  EndCustomerName like '%{0}%'   ", txtEndCustName.Text.Trim().Replace("'", "''").Replace("*", "%"))
        End If
        gv1.DataSource = dt
        gv1.DataBind()
    End Sub
    Protected Sub gv1_RowEditing(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewEditEventArgs)
        gv1.EditIndex = e.NewEditIndex
        'src1.SelectCommand = GetSql()
        GVDataBind()
    End Sub

    Protected Sub gv1_RowCancelingEdit(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        gv1.EditIndex = -1
        'src1.SelectCommand = GetSql()
        GVDataBind()
    End Sub
    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gv1.PageIndex = e.NewPageIndex
        'src1.SelectCommand = GetSql()
        GVDataBind()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        'src1.SelectCommand = GetSql()
        GVDataBind()
    End Sub

    Protected Sub imgXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim sql As String = "select OPTY_ID as 'Opportunity ID', Project_Name as 'Project Name',Company,CPartner as 'Channel Partner',Status," & _
                                  "  Appliciant,Contact as 'Contact Person',Phone as 'Applicant Phone', Email as 'Applicant Email',City1 as 'Applicant City', " & _
                                  "  State1 as 'Applicant State',AdvSalesContact as 'Advantech Sales Contact',Address as 'Applicant Address', " & _
                                   " City2  AS 'Project City ', state2  AS 'Project State',  Comment,Reg_date,Reject_Reason as 'Reject Reason',Approve_Date1,Approve_Date2,Approve_Date3,Expire_Date, " & _
                                    " Contact1,ContactPhone1,ContactEMail1,Contact2,ContactPhone2,ContactEMail2,Approve_Code,internal_comment,Org_ID  " & _
                                     "   from  US_PrjReg_Mstr order by reg_date  "

        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", sql)
        Util.DataTable2ExcelDownload(dt, "Registered Project")
    End Sub

    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 240
    End Sub
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetStageDTbyRowIds(ByVal rowids As String) As DataTable
        If rowids.Trim() = "" Then Return New DataTable("ACCOUNTADDR")
        Dim P() As String = Split(rowids, ",") : Dim wherestr As String = ""
        For i As Integer = 0 To P.Length - 1
            If i = P.Length - 1 Then
                wherestr = wherestr + "'" + P(i).ToString.Trim.Replace("'", "") + "'"
            Else
                wherestr = wherestr + "'" + P(i).ToString.Trim.Replace("'", "") + "',"
            End If
        Next
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select b.ROW_ID ,a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID   "))
            .AppendLine(String.Format(" where b.ROW_ID in({0})  ", wherestr))

        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
        dt.TableName = "ACCOUNTADDR"
        Return dt
    End Function
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gv1.PageIndex = 0
        'src1.SelectCommand = GetSql()
        GVDataBind()
        'MailUtil.SendDebugMsg("", src1.SelectCommand)
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        .xd
        {
            position: relative;
            display: block;
        }
    </style>
    <script type="text/javascript" language="javascript">
        function loaditemstatus() {
            var redClassElements = getElementsByClassName("Stage", "<%=gv1.ClientID %>");
            var alertstr = "";
            var mycars = new Array()
            for (var i = 0; i < redClassElements.length; i++) {
                if (redClassElements[i].id != "") mycars.push(redClassElements[i].id);
            }
            for (var i = 0; i < mycars.length; ++i) {
                if (i == mycars.length - 1) { alertstr = alertstr + mycars[i]; }
                else { alertstr = alertstr + mycars[i] + ","; }
            }
            if (alertstr != "") {
                PageMethods.GetStageDTbyRowIds(alertstr, onresult, onerror, redClassElements);
            }
        }
        function onresult(result, objids) {
            var dt = result;
            if (dt != null && typeof (dt) == "object") {
                //alert(dt.rows.length);
                for (i = 0; i < objids.length; i++) {
                    for (j = 0; j < dt.rows.length; j++) {
                        if (objids[i].id == dt.rows[j].ROW_ID) {
                            objids[i].innerHTML = dt.rows[j].NAME;
                            break;
                        }
                    }
                }
            }
        }
        function onerror(error) {
            if (error !== null) {
                //  alert(error.get_message());
            }
        }
        window.onload = function () { loaditemstatus(); }
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(EndRequest);
        function EndRequest(sender, args) { loaditemstatus(); }
        function getElementsByClassName(className, outid) {
            var oBox = document.getElementById(outid);
            this.d = oBox || document;
            var children = this.d.getElementsByTagName('*') || document.all;
            var elements = new Array();
            for (var ii = 0; ii < children.length; ii++) {
                var child = children[ii];
                var classNames = child.className.split(' ');
                for (var j = 0; j < classNames.length; j++) {
                    if (classNames[j] == className) {
                        elements.push(child);
                        break;
                    }
                }
            }
            return elements;
        }
    </script>
    <table style="height: 100%" cellpadding="0" cellspacing="0" width="90%" border="0"
        align="center">
        <tr>
            <td valign="top">
                <table width="100%">
                    <tr>
                        <td style="height: 10px" colspan="2">
                        </td>
                    </tr>
                    <tr>
                        <td valign="top" colspan="2" style="width: 82%">
                            <h2 runat="server" id="hPTitle">
                                All Registered Projects</h2>
                        </td>
                    </tr>
                    <tr>
                        <td height="20">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td width="100%">
                            <table width="100%">
                                <tr>
                                    <td style="font-size: larger">
                                        <asp:HyperLink runat="server" ID="hlFeedbackLead" Text="[ Project Registration ]"
                                            NavigateUrl="./ProjectRegist.aspx" />
                                    </td>
                                    <td align="right">
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table runat="server" id="tbSearchForm">
                                <tr>
                                    <th align="left">
                                    </th>
                                </tr>
                                <tr>
                                    <th align="left">
                                        End Customer's Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtEndCustName" Width="150px" />
                                    </td>
                                    <th align="left" id="THcp" runat="server">
                                        Channel Partner's Name:
                                    </th>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtCPName" Width="150px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Sales Stage:
                                    </th>
                                    <td>
                                        <asp:DropDownList runat="server" ID="dlQStage">
                                            <asp:ListItem Text="All Stage" Selected="True" />
                                            <asp:ListItem Value="0% Lost" />
                                            <asp:ListItem Value="5% New Lead" />
                                            <asp:ListItem Value="10% Validating" />
                                            <asp:ListItem Value="25% Proposing/Quoting" />
                                            <asp:ListItem Value="40% Testing" />
                                            <asp:ListItem Value="50% Negotiating" />
                                            <asp:ListItem Value="75% Waiting for PO/Approval" />
                                            <asp:ListItem Value="90% Expected Flow Business" />
                                            <asp:ListItem Value="100% Won-PO Input in SAP" />
                                        </asp:DropDownList>
                                    </td>
                                    <th align="left">
                                        Expire Date:
                                    </th>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="calext1" TargetControlID="txtExpDateFrom"
                                            Format="MM/dd/yyyy" />
                                        <ajaxToolkit:CalendarExtender runat="server" ID="calext2" TargetControlID="txtExpDateTo"
                                            Format="MM/dd/yyyy" />
                                        <asp:TextBox runat="server" ID="txtExpDateFrom" Width="90px" />~<asp:TextBox runat="server"
                                            ID="txtExpDateTo" Width="90px" />
                                    </td>
                                </tr>
                                <tr>
                                    <th align="left">
                                        Approval Status:
                                    </th>
                                    <td colspan="2">
                                        <asp:DropDownList runat="server" ID="dlAppStatus">
                                            <asp:ListItem Text="All Status" />
                                            <asp:ListItem Text="Request" Value="Request" />
                                            <asp:ListItem Text="Approved by Sales Contact" Value="Approve1" />
                                            <asp:ListItem Text="Approved by Sales Head" Value="Approve2" />
                                            <asp:ListItem Text="Rejected by Sales Contact" Value="Reject1" />
                                            <asp:ListItem Text="Rejected by Sales Head" Value="Reject2" />
                                            <asp:ListItem Text="Won" Value="WON" />
                                            <asp:ListItem Text="Lost" Value="LOST" />
                                        </asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:ImageButton runat="server" ID="imgXls" AlternateText="Export to Excel" ImageUrl="~/Images/excel.gif"
                                OnClick="imgXls_Click" />
                            <sgv:SmartGridView runat="server" ID="gv1" DataKeyNames="Request_id,OPTY_ID" ShowWhenEmpty="true"
                                AutoGenerateColumns="false" AllowSorting="true" Width="100%" OnRowDataBound="gv1_RowDataBound"
                                OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting" OnRowEditing="gv1_RowEditing"
                                OnRowCancelingEdit="gv1_RowCancelingEdit" OnRowUpdating="gv1_RowUpdating" AllowPaging="True"
                                PageSize="30" OnDataBound="gv1_DataBound">
                                <Columns>
                                    <asp:CommandField HeaderText="Actions" ShowEditButton="false" EditText="Edit" ItemStyle-HorizontalAlign="Center" Visible="false" />
                                    <asp:BoundField HeaderText="Org." DataField="Org_ID" SortExpression="Org_ID" />
                                    <asp:BoundField HeaderText="Project Name" DataField="Project_Name" ReadOnly="true"
                                        ItemStyle-HorizontalAlign="Left" />
                                    <asp:TemplateField HeaderText="Stage">
                                        <ItemTemplate>
                                            <asp:Label runat="server" ID="lbRowStage" />
                                            <span id='<%#Eval("OPTY_ID") %>' class="Stage">
                                                <%# IIf(Eval("OPTY_ID") <> "N/A", "<img src='../images/loading2.gif' width='25' height='25' />", "")%>
                                            </span>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:DropDownList runat="server" ID="dlRowStage" OnDataBinding="dlRowStage_DataBinding">
                                                <asp:ListItem Value="0% Lost" />
                                                <asp:ListItem Value="5% New Lead" />
                                                <asp:ListItem Value="10% Validating" />
                                                <asp:ListItem Value="25% Proposing/Quoting" />
                                                <asp:ListItem Value="40% Testing" />
                                                <asp:ListItem Value="50% Negotiating" />
                                                <asp:ListItem Value="75% Waiting for PO/Approval" />
                                                <asp:ListItem Value="90% Expected Flow Business" />
                                                <asp:ListItem Value="100% Won-PO Input in SAP" />
                                            </asp:DropDownList>
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Channel Partner Name" DataField="CPName" ReadOnly="true" />
                                    <asp:BoundField HeaderText="End Customer's Name" DataField="EndCustomerName" ReadOnly="true"
                                        ItemStyle-HorizontalAlign="Left" />
                                    <asp:BoundField HeaderText="Status" DataField="Status" ReadOnly="true" ItemStyle-HorizontalAlign="Left" />
                                    <asp:BoundField HeaderText="Registration Date" DataField="reg_date" ReadOnly="true"
                                        ItemStyle-HorizontalAlign="Left" />
                                    <asp:TemplateField HeaderText="Expire Date">
                                        <ItemTemplate>
                                            <asp:Literal ID="lt1" runat="server" Text='<%# Eval("Expire_Date") %>'></asp:Literal>
                                        </ItemTemplate>
                                        <EditItemTemplate>
                                            <asp:TextBox runat="server" ID="TB1" Text='<%# Eval("Expire_Date") %>'></asp:TextBox>
                                            <ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="TB1" Format="MM/dd/yyyy" />
                                        </EditItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="Opportunity ID" DataField="OPTY_ID" ReadOnly="true" ItemStyle-Width="80px"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Advantech Sales Contact" DataField="AdvSalesContact"
                                        ReadOnly="true" SortExpression="AdvSalesContact" />
                                    <asp:TemplateField HeaderText="End Customer RowID" ItemStyle-HorizontalAlign="Left">
                                        <ItemTemplate>
                                            <%# Eval("EndCustomer")%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField ItemStyle-Width="80px" ItemStyle-Height="100%" ItemStyle-VerticalAlign="Middle"
                                        HeaderText="Product & Price">
                                        <ItemTemplate>
                                            <div class="xd" style="width: 100%; height: 100%;">
                                                <div style="text-align: center; cursor: pointer;" onclick="getdetail(this,'div<%# Eval("Request_id") %>');">
                                                    Show</div>
                                                <div style="display: none; position: absolute; left: -462px; top: -25px; border: 2px solid #FF0000;
                                                    padding: 3px; background-color: #FFFFFF;" id="div<%# Eval("Request_id") %>">
                                                    <asp:GridView runat="server" Width="450px" ID="gv2" DataSource='<%# GetData(Eval("Request_id")) %>'
                                                        AutoGenerateColumns="false">
                                                        <Columns>
                                                            <asp:BoundField HeaderText="Product Items" DataField="Part_no" ReadOnly="true" ItemStyle-HorizontalAlign="Left" />
                                                            <asp:BoundField HeaderText="Distributor PO Price" DataField="DebitPricing" ReadOnly="true"
                                                                ItemStyle-HorizontalAlign="Right" />
                                                            <asp:BoundField HeaderText="Annual Qty" DataField="Qty" ReadOnly="true" ItemStyle-HorizontalAlign="Center" />
                                                            <asp:BoundField HeaderText="Distributor Target Price" DataField="CPricing" ReadOnly="true"
                                                                ItemStyle-HorizontalAlign="Right" />
                                                            <asp:BoundField HeaderText="End user cost" DataField="TargetPricing" ReadOnly="true"
                                                                ItemStyle-HorizontalAlign="Right" />
                                                            <asp:BoundField HeaderText="Approved Pricing" DataField="ApprovedPricing" ReadOnly="true"
                                                                ItemStyle-HorizontalAlign="Right" />
                                                        </Columns>
                                                    </asp:GridView>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:TemplateField>                                    
                                </Columns>
                                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify" />
                                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                            </sgv:SmartGridView>
                            <asp:SqlDataSource runat="server" UpdateCommand="select getdate()" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>"
                                OnSelecting="src1_Selecting" />
                            <asp:UpdatePanel runat="server" ID="upPrjList" UpdateMode="Conditional">
                                <ContentTemplate>
                                </ContentTemplate>
                                <Triggers>
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <script language="javascript" type="text/javascript">
        function getdetail(obj, divid) {
            var div_detail = document.getElementById(divid)
            if (obj.innerHTML == "Show") {
                //alert("bb");

                if (div_detail.style.display != "block") {
                    div_detail.style.display = "block";
                }
                //alert("cc");
                obj.innerHTML = "Hide";

                return false;
            }

            if (obj.innerHTML == "Hide") {

                obj.innerHTML = "Show";
                if (div_detail.style.display != "none") {
                    div_detail.style.display = "none";
                }
                return false;
            }
        }
    </script>
</asp:Content>
