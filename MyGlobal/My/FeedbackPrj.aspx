<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Feedback New Project" %>
<%@ Register Src="~/Includes/OptyUpdDraft.ascx" TagPrefix="uc1" TagName="OptyUpdDraft" %>
<%@ Register src="../Includes/ChangeCompany.ascx" tagname="ChangeCompany" tagprefix="uc1" %>
<script runat="server">

    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", _
              String.Format("select distinct top 1 row_id from siebel_account where erp_id='{0}' and row_id is not null order by row_id ", Session("company_id")))
        If dt.Rows.Count > 0 Then
            Dim tmpPrjName As String = Me.txtPrjName.Text.Trim
            Dim tmpPrjDesc As String = HttpContext.Current.Server.HtmlEncode(Me.txtDesc.Text.Trim)
            Dim tmpStatus As String = dlPrjStatus.SelectedItem.Text
            Dim tmpProb As Integer = CInt(dlProb.SelectedItem.Text)
            Dim tmpRev As Double = 0
            Dim tmpCloseDate As Date = DateAdd(DateInterval.Month, 1, Now)
            If tmpPrjName = "" Then
                lbMsg.Text = "Please input Project Name" : up2.Update()
                Exit Sub
            Else
                lbMsg.Text = "" : up2.Update()
            End If
            If Double.TryParse(txtRev.Text, 0) Then tmpRev = CDbl(txtRev.Text)
            If Date.TryParseExact(Me.txtPrjCloseDate.Text, "dd/MM/yyyy", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Now) Then
                tmpCloseDate = Date.ParseExact(Me.txtPrjCloseDate.Text, "dd/MM/yyyy", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None)
            End If
            Dim tmpId As String = NewOptyTmpId()
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" INSERT INTO CP_FEEDBACK_LEADS ")
                .AppendFormat(" (PROJECT_NAME, DESCRIPTION, STATUS, ")
                .AppendFormat("  PROBABILITY, REVENUE, CURRENCY, CLOSE_DATE, CREATE_DATE,  ")
                .AppendFormat("  CREATE_BY, LAST_UPD_BY, LAST_UPD_DATE, ROW_ID, ACCOUNT_ROW_ID, APPROVAL_STATUS, TEMP_ID) ")
                .AppendFormat(" VALUES (N'{0}', N'{1}', N'{2}', {3}, {4}, N'{5}', '{6}', " + _
                              " getdate(), N'{7}', N'{7}', getdate(), N'{8}', '{9}', 'DRAFT', '{10}') ", _
                              tmpPrjName.Replace("'", "''"), _
                              tmpPrjDesc.Replace("'", "''"), tmpStatus, tmpProb, _
                              tmpRev.ToString(), "EUR", tmpCloseDate.ToString("yyyy-MM-dd"), Session("user_id"), "", dt.Rows(0).Item("row_id"), tmpId)
            End With
            dbUtil.dbExecuteNoQuery("MY", sb.ToString())
            src1.SelectCommand = GetSql()
            up1.Update()
        End If
    End Sub
    
    Private Function GetSql() As String
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", _
        String.Format("select distinct row_id from siebel_account where erp_id='{0}' and row_id is not null ", Session("company_id")))
        If dt.Rows.Count > 0 Then
            Dim rid As New ArrayList
            For Each r As DataRow In dt.Rows
                rid.Add("'" + r.Item("row_id") + "'")
            Next
            Dim strRid As String = "(" + String.Join(",", CType(rid.ToArray(GetType(String)), String())) + ")"
            
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select a.temp_id, a.project_name, a.description, a.status, a.probability, a.revenue, a.close_date, a.create_date, a.create_by, a.account_row_id  ")
                .AppendFormat(" from CP_FEEDBACK_LEADS a ")
                .AppendFormat(" where a.account_row_id in {0} and approval_status='DRAFT' ", strRid)
                .AppendFormat(" order by a.create_date ")
            End With
            Return sb.ToString()
        End If
        Return ""
    End Function
    
    Protected Sub OptyUpdDraft1_OptyUpdatedEvent()
        src1.SelectCommand = GetSql() : gv1.DataBind() : up1.Update()
    End Sub
    
    Protected Sub txtPrjCloseDate_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            txtPrjCloseDate.Text = DateAdd(DateInterval.Month, 1, Now).ToString("dd/MM/yyyy")
        End If
    End Sub
    
    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_SelectedIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSelectEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_RowCancelingEdit(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_RowEditing(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewEditEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("RegisterLeads.aspx")
        If Not Page.IsPostBack Then
            src1.SelectCommand = GetSql()          
            If Util.IsInternalUser(Session("user_id")) OrElse Util.IsAEUIT() Then
                chgcompanypanel1.Visible = True
            End If
        End If
    End Sub

    Protected Sub dlRowStatus_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim tmpDl As DropDownList = CType(sender, DropDownList)
        Dim tmpGr As GridViewRow = CType(tmpDl.NamingContainer, GridViewRow)
        If Trim(DataBinder.Eval(tmpGr.DataItem, "STATUS").ToString()) <> "" Then
            Try
                tmpDl.SelectedValue = DataBinder.Eval(tmpGr.DataItem, "STATUS").ToString()
            Catch ex As Exception
                tmpDl.SelectedValue = ""
            End Try
        End If
    End Sub

    Protected Sub dlRowProb_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim tmpDl As DropDownList = CType(sender, DropDownList)
        Dim tmpGr As GridViewRow = CType(tmpDl.NamingContainer, GridViewRow)
        If Trim(DataBinder.Eval(tmpGr.DataItem, "PROBABILITY").ToString()) <> "" Then
            Try
                tmpDl.SelectedValue = DataBinder.Eval(tmpGr.DataItem, "PROBABILITY").ToString()
            Catch ex As Exception
                tmpDl.SelectedValue = ""
            End Try
        End If
    End Sub

    Protected Sub src1_Updating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceCommandEventArgs)
        Dim ws As New aeu_eai2000.Siebel_WS, gr As GridViewRow = gv1.Rows(gv1.EditIndex)
        ws.UseDefaultCredentials = True
        ws.Timeout = -1
        Dim AccountId As String = gv1.DataKeys(gr.RowIndex).Values("ACCOUNT_ROW_ID").ToString()
        Dim newName As String = gv1.DataKeys(gr.RowIndex).Values("PROJECT_NAME").ToString()
        Dim newStatus As String = CType(gr.FindControl("dlRowStatus"), DropDownList).SelectedValue
        Dim newDesc As String = HttpUtility.HtmlEncode(CType(gr.FindControl("txtRowDesc"), TextBox).Text).Replace(vbCrLf, vbCrLf)
        Dim newAmt As String = gv1.DataKeys(gr.RowIndex).Values("REVENUE").ToString()
        Dim newCloseDate As Date = HttpUtility.HtmlEncode(CDate(CType(gr.FindControl("txtRowCloseDate"), TextBox).Text))
        Dim newProb As String = CType(gr.FindControl("dlRowProb"), DropDownList).SelectedValue
        Dim strOwner As String = "MYADVANTECH", strPosId As String = ""
        Dim odt As DataTable = MYSIEBELDAL.GetOwnerOfAccount(AccountId)
        If odt.Rows.Count > 0 Then
            strOwner = odt.Rows(0).Item("USER_LOGIN")
            strPosId = odt.Rows(0).Item("POSITION_ID")
        End If
        Dim strOptyID As String = _
            ws.Import_Opportunity(strPosId, strOwner, AccountId, "", newName, newDesc, "Funnel Sales Methodology", _
                                  "25% Proposing/Quoting", newCloseDate, newAmt, "25", "Pending", "", "EUR")
        'Dim strOptyID As String = ws.CreateNewOpportunity4Quote(AccountId, newName, newDesc, "25% Proposing/Quoting", newAmt, "EUR", "", _
        'newStatus, newCloseDate, strOwner)
        If strOptyID <> "" Then
            dbUtil.dbExecuteNoQuery("MY", String.Format( _
            " update CP_FEEDBACK_LEADS " + _
            " set approval_status='UPDATED', row_id='{0}', last_upd_by='{1}', last_upd_date=getdate() " + _
            " where account_row_id='{2}' and temp_id='{3}' ", _
            strOptyID, Session("user_id"), AccountId, gv1.DataKeys(gr.RowIndex).Values("TEMP_ID").ToString()))
        Else
            
        End If
        'Util.AjaxJSAlert(up1, "ROWID:" + strOptyID)
        e.Cancel = True : Exit Sub
    End Sub
    
    Private Shared Function NewOptyTmpId() As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MY", "select count(*) as counts from CP_FEEDBACK_LEADS where TEMP_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    
    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Try
                If HttpContext.Current.User.Identity.Name = "gary.chen@advantech.com.tw" _
                OrElse HttpContext.Current.User.Identity.Name = "kander.kan@advantech.com.tw" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "172.16.7.48" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "172.16.2.208" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "59.115.129.139" _
                OrElse Request.ServerVariables("REMOTE_ADDR") = "59.124.232.162" Then
                    Response.End()
                End If
            Catch ex As Exception
                Response.End()
            End Try
        End If
    End Sub

    Protected Sub dlLeadFuncGrp_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect(dlLeadFuncGrp.SelectedValue, False)
    End Sub

    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 99999999
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="95%">
        <tr>            
            <th align="left" style="font-size:large; color:Navy; width:250px">Feedback New Projects</th>
            <td align="right">
                <table>
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="chgcompanypanel1" Visible="false" Width="250px" ScrollBars="Auto" BorderWidth="1px" HorizontalAlign="Left">
                               <%-- <asp:LoginView runat="server" ID="ChangeCompanyView">
                                    <RoleGroups>
                                        <asp:RoleGroup Roles="Logistics,Administrator">
                                            <ContentTemplate>--%>
                                                <b>Change Company:</b><uc1:ChangeCompany ID="ChangeCompany1" runat="server"/>
                                         <%--   </ContentTemplate>
                                        </asp:RoleGroup>
                                    </RoleGroups>
                                </asp:LoginView>--%>
                            </asp:Panel>  
                        </td>
                    </tr>
                    <tr>
                        <td>      
                            <asp:DropDownList runat="server" ID="dlLeadFuncGrp" Width="150px" AutoPostBack="true" OnSelectedIndexChanged="dlLeadFuncGrp_SelectedIndexChanged">
                                <asp:ListItem Text="My Leads" Value="/My/MyLeads.aspx" />
                                <asp:ListItem Text="My Projects" Value="/My/MyProject.aspx" />
                                <asp:ListItem Text="Feedback Leads" Value="/My/FeedbackPrj.aspx" Selected="True" />
                            </asp:DropDownList>                      
                        </td>
                    </tr>
                </table>                              
            </td>
        </tr>
        <tr align="right">
            <td colspan="2"><asp:HyperLink runat="server" ID="hyMyPrj" Text="My Project" NavigateUrl="~/My/MyProject.aspx" /></td>
        </tr>
        <tr>
            <td colspan="2">
                <table width="100%">
                    <tr>
                        <th align="left" style="width:150px">Project Name</th>
                        <td>
                            <asp:TextBox runat="server" ID="txtPrjName" Width="250px" />
                        </td>
                    </tr>
                    <tr>
                        <th align="left" style="width:150px">Description</th>
                        <td>
                            <asp:TextBox runat="server" ID="txtDesc" Width="600px" TextMode="MultiLine" Rows="8" />
                        </td>
                    </tr>
                    <tr>
                        <th align="left" style="width:150px">Status</th>
                        <td>
                            <asp:DropDownList runat="server" ID="dlPrjStatus" Width="200px">
                                <asp:ListItem Text="Accepted" Value="Accepted" />
                                <asp:ListItem Text="Lost" Value="Lost" />
                                <asp:ListItem Text="Pending" Value="Pending" />
                                <asp:ListItem Text="Rejected" Value="Rejected" />
                                <asp:ListItem Text="Won" Value="Won" />
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <th align="left" style="width:150px">Probability</th>
                        <td>
                            <asp:DropDownList runat="server" ID="dlProb" Width="200px">
                                <asp:ListItem Text="0" />
                                <asp:ListItem Text="25" />
                                <asp:ListItem Text="50" />
                                <asp:ListItem Text="75" />
                                <asp:ListItem Text="100" />
                            </asp:DropDownList>
                        </td>
                    </tr>
                    <tr>
                        <th align="left" style="width:150px">Total Revenue</th>
                        <td>
                            <asp:TextBox runat="server" ID="txtRev" Width="70px"  Text="0"/>
                        </td>
                    </tr>
                    <tr>
                        <th align="left" style="width:150px">Close Date</th>
                        <td>
                            <ajaxToolkit:CalendarExtender runat="server" ID="CalPrjCloseDateExt" TargetControlID="txtPrjCloseDate" Format="dd/MM/yyyy" />
                            <asp:TextBox runat="server" ID="txtPrjCloseDate" Width="80px" OnLoad="txtPrjCloseDate_Load" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Button runat="server" ID="btnAdd" Text="Submit" OnClick="btnAdd_Click" /></td>
                        <td>
                            <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" Width="90%" AllowPaging="true" 
                            AllowSorting="true" PageSize="10" PagerSettings-Position="TopAndBottom" DataSourceID="src1" 
                            DataKeyNames="ACCOUNT_ROW_ID,PROJECT_NAME,CREATE_DATE,REVENUE,TEMP_ID" OnSorting="gv1_Sorting" 
                            OnSelectedIndexChanging="gv1_SelectedIndexChanging" OnPageIndexChanging="gv1_PageIndexChanging" 
                            OnRowUpdating="gv1_RowUpdating" OnRowCancelingEdit="gv1_RowCancelingEdit" OnRowEditing="gv1_RowEditing">
                            <Columns>
                                <asp:CommandField HeaderStyle-Width="250px" HeaderText="Actions" ShowEditButton="true" EditText="Edit" 
                                    UpdateText="Write to Siebel" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="250px" />
                                <asp:BoundField HeaderText="Project Name" DataField="PROJECT_NAME" SortExpression="PROJECT_NAME" />
                                <asp:TemplateField HeaderText="Description" SortExpression="DESCRIPTION">
                                    <ItemTemplate>
                                        <asp:TextBox runat="server" ID="txtRowReadDesc" Width="350px" TextMode="MultiLine" Rows="5" Text='<%# Eval("DESCRIPTION") %>' ReadOnly="true" />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:TextBox runat="server" ID="txtRowDesc" Width="350px" TextMode="MultiLine" Rows="5" Text='<%# Eval("DESCRIPTION") %>' ReadOnly="false" />
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status" SortExpression="STATUS">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lbRowStatus" Text='<%# Eval("STATUS") %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:DropDownList runat="server" ID="dlRowStatus" OnDataBinding="dlRowStatus_DataBinding">
                                            <asp:ListItem Text="Accepted" Value="Accepted" />
                                            <asp:ListItem Text="Lost" Value="Lost" />
                                            <asp:ListItem Text="Pending" Value="Pending" />
                                            <asp:ListItem Text="Rejected" Value="Rejected" />
                                            <asp:ListItem Text="Won" Value="Won" />
                                        </asp:DropDownList>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Probability" SortExpression="PROBABILITY">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lbRowProb" Text='<%# Eval("PROBABILITY") %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <asp:DropDownList runat="server" ID="dlRowProb" OnDataBinding="dlRowProb_DataBinding">
                                            <asp:ListItem Text="0" />
                                            <asp:ListItem Text="25" />
                                            <asp:ListItem Text="50" />
                                            <asp:ListItem Text="75" />
                                            <asp:ListItem Text="100" />
                                        </asp:DropDownList>
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField ItemStyle-HorizontalAlign="Right" HeaderText="Revenue" DataField="REVENUE" SortExpression="REVENUE" />
                                <asp:TemplateField HeaderText="Close Date" SortExpression="CLOSE_DATE">
                                    <ItemTemplate>
                                        <asp:Label runat="server" ID="lbRowCloseDate" Text='<%# Eval("CLOSE_DATE") %>' />
                                    </ItemTemplate>
                                    <EditItemTemplate>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="acRowCalExt1" TargetControlID="txtRowCloseDate" Format="yyyy/MM/dd" PopupPosition="TopLeft" />
                                        <asp:TextBox runat="server" ID="txtRowCloseDate" Width="120px" Text='<%# CDate(Eval("CLOSE_DATE")).toString("yyyy/MM/dd") %>' />
                                    </EditItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderText="Create Date" DataField="CREATE_DATE" SortExpression="CREATE_DATE" ReadOnly="true" />
                                <asp:BoundField HeaderText="Create By" DataField="CREATE_BY" SortExpression="CREATE_BY" ReadOnly="true" />
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ ConnectionStrings:MY %>" SelectCommand="" UpdateCommand="select getdate()" OnUpdating="src1_Updating" OnSelecting="src1_Selecting" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>