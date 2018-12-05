<%@ Control Language="VB" ClassName="PrjUpdate2Siebel" %>
<%@ Import Namespace="InterConPrjReg" %>
<script runat="server">
    Dim R As MY_PRJ_REG_MASTERRow = Nothing
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            If Request("ROW_ID") IsNot Nothing AndAlso Trim(Request("ROW_ID")) <> String.Empty Then
                Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
                R = Prj_M_A.GetDataByRowID(Request("ROW_ID")).Rows(0)
                Dim Prj_S_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_AUDITTableAdapter
                Dim Sdt As InterConPrjReg.MY_PRJ_REG_AUDITDataTable = Prj_S_A.GetByPRJ_ROW_ID(Request("ROW_ID"))
                btUpdate.Enabled = False
                If Sdt.Rows.Count > 0 Then
                    Dim Srow As MY_PRJ_REG_AUDITRow = Sdt.Rows(0)
                    Select Case Srow.STATUS
                        Case 0, 2
                        Case 1
                            If InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, R.CREATED_BY) Then
                                btUpdate.Enabled = True
                            End If
                            'ICC 2016/5/19 Change this function parameter
                            Dim strCPOwner As String = InterConPrjRegUtil.GetPriSalesOwnerOfAccount(R.ROW_ID)
                            If strCPOwner <> String.Empty Then
                                Dim strCPOwnerBoss As String = InterConPrjRegUtil.GetSalesOwnerDirectBoss(strCPOwner)
                                If strCPOwnerBoss = String.Empty Then strCPOwnerBoss = "sieowner@advantech.com.tw"
                                If InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwner) OrElse _
                                      InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, strCPOwnerBoss) OrElse _
                                       InterConPrjRegUtil.IsEquals(HttpContext.Current.User.Identity.Name, R.CREATED_BY) Then
                                    btUpdate.Enabled = True
                                End If
                            End If
                        Case Else
                    End Select
                    ''
                    Dim sql As New StringBuilder
                    sql.AppendLine(" select  b.ROW_ID, b.SUM_EFFECTIVE_DT,isnull(b.SUM_MARGIN_AMT,0) as SUM_MARGIN_AMT ,a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID ")
                    sql.AppendFormat("  where b.ROW_ID ='{0}'", R.PRJ_OPTY_ID)
                    Dim dt As DataTable = dbUtil.dbGetDataTable("CRMAPPDB", sql.ToString())
                    If dt.Rows.Count > 0 Then
                        With dt.Rows(0)
                            dlRowStage.SelectedValue = .Item("NAME").ToString
                            TBamount.Text = String.Format("{0:0.00}", .Item("SUM_MARGIN_AMT"))
                            TBcloseddate.Text = CDate(.Item("SUM_EFFECTIVE_DT")).ToString("yyy/MM/dd")
                        End With
                    End If
                End If
                'Bind Position
                'Dim strOwner As String = "", strPosId As String = ""
                'USPrjRegUtil.Get_Owner_PosId(R.CP_ACCOUNT_ROW_ID, strOwner, strPosId)
                'sqlPosition.SelectParameters.Item("LOGIN").DefaultValue = strOwner
                'Dim dtPos As DataTable = USPrjRegUtil.GetSiebelOpportunityPosition(R.PRJ_OPTY_ID)
                'If dtPos IsNot Nothing Then
                '    txtPosition.Text = dtPos.Rows(0).Item("NAME") : hdnPositionId.Value = dtPos.Rows(0).Item("ROW_ID")
                'End If
            End If
        End If
        'TBamount.Text = String.Format("{0:0.00}", InterConPrjRegUtil.GetTotalAmountByID(Request("ROW_ID")))
    End Sub

    Protected Sub btUpdate_Click(sender As Object, e As System.EventArgs)
        LabWarn.Text = ""
        If Date.Parse(TBcloseddate.Text) <= Date.Parse(Now()) Then
            LabWarn.Text = "Estimated close date must be greater than today" : Exit Sub
        End If
        If Decimal.TryParse(TBamount.Text.Trim, 0) = False Then
            LabWarn.Text = "Total Amount is empty or not a numeric number."
            Exit Sub
        End If
        InterConPrjRegUtil.UpdatePrj(Request("ROW_ID"), CDate(TBcloseddate.Text), Session("user_id"), System.DateTime.Now())
        InterConPrjRegUtil.update_Siebel(Request("ROW_ID"), dlRowStage.SelectedValue, Decimal.Parse(TBamount.Text.Trim), "", "", CDate(TBcloseddate.Text).ToString("MM/dd/yyyy"))
        
        'ICC 2016/3/22 After sales update opportunity, we will save this record in new table
        InterConPrjRegUtil.CreatePrjRegCourse(Request("ROW_ID"), dlRowStage.SelectedValue, Session("user_id"))
        
        ' Util.AjaxJSAlertRedirect(upSiebel, "Update successful", Util.GetRuntimeSiteUrl + String.Format("/My/InterCon/PrjDetail.aspx?ROW_ID={0}#updatesiebel", Request("ROW_ID")))
        System.Threading.Thread.Sleep(5000)
        LabWarn.Text = "Update successful"
        Dim PrjName As String = dbUtil.dbExecuteScalar("MYLOCAL", "SELECT top 1 isnull(PRJ_NAME,'') as curr from MY_PRJ_REG_MASTER where ROW_ID ='" + Request("ROW_ID") + "'")
        Dim MailSubject As String = String.Format("Project Name({0})'s Status is Updated by {1}  ", PrjName, Session("user_id"))
        Dim MailBody As String = String.Format("Stage:{0} <br />Total Amount:{1} <br />Estimated closed date:{2}", dlRowStage.SelectedValue, String.Format("{0:0.00}", TBamount.Text), TBcloseddate.Text)
        MailBody += "<br/>" + InterConPrjRegUtil.GetProductsHtml(Request("ROW_ID"))
        InterConPrjRegUtil.SendUpdateMail(Request("ROW_ID"), MailSubject, MailBody)

        Response.Redirect(String.Format(Util.GetRuntimeSiteUrl() + "/My/InterCon/PrjDetail.aspx?ROW_ID={0}", Request("ROW_ID")))
    End Sub
    Protected Sub Timer2_Tick(sender As Object, e As System.EventArgs)
        'If Not IsPostBack Then
        'Timer2.Enabled = False
        'End If
    End Sub

    'Protected Sub btnPickPisition_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    mpePosition.Show()
    'End Sub

    'Protected Sub btnClearPosition_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    txtPosition.Text = "" : hdnPositionId.Value = ""
    'End Sub

    'Protected Sub btnSetPosition_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    txtPosition.Text = CType(sender, LinkButton).Text
    '    hdnPositionId.Value = CType(CType(sender, LinkButton).NamingContainer, GridViewRow).Cells(0).Text
    '    mpePosition.Hide()
    'End Sub

    'Protected Sub btnSearchPosition_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    upPosition.Update()
    'End Sub
</script>
<a name="updatesiebel" id="updatesiebel"></a>
<asp:UpdatePanel runat="server" ID="upSiebel" UpdateMode="Conditional">
    <ContentTemplate>
    <h2> Update Project Status  &nbsp;&nbsp;&nbsp;&nbsp;<asp:Label runat="server" ID="LabWarn" ForeColor="Tomato" Font-Size="11px"></asp:Label></h2>     
        <%--<asp:Timer runat="server" ID="Timer2" Interval="300"   OnTick="Timer2_Tick" />--%>
        <table width="100%" align="center" height="35">
            <tr>
                <td>
                    <table width="100%">
                        <tr>
                            <td align="center">
                                Stage:
                            </td>
                            <td>
                                <asp:DropDownList runat="server" ID="dlRowStage">
                                    <asp:ListItem Value="0% Lost" />
                                    <asp:ListItem Value="5% New Lead" />
                                    <asp:ListItem Value="10% Validating" />
                                    <asp:ListItem Value="25% Proposing/Quoting" />
                                    <asp:ListItem Value="40% Testing" />
                                    <asp:ListItem Value="50% Negotiating" />
                                    <asp:ListItem Value="75% Waiting for PO/Approval" />
                                    <asp:ListItem Value="90% Expected Flow Business" />
                                    <asp:ListItem Value="100% Won-PO Input in SAP" />
                                    <asp:ListItem Value="Rejected by Sales" />
                                    <asp:ListItem Value="Rejected by Partner" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                Total Amount:  <%= InterConPrjRegUtil.GetCurrencySign()%>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="TBamount" ></asp:TextBox>
                            </td>
                            <td>
                                Estimated closed date:
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="TBcloseddate"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender runat="server" ID="cext1" TargetControlID="TBcloseddate"
                                    Format="yyyy/MM/dd" />
                            </td>
                        </tr>
                    </table><%--
                    <table>
                        <tr>
                            <td>Primary Position: </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtPosition" Enabled="false" Width="250px" /><asp:Button runat="server" ID="btnPickPisition" Text="Pick" OnClick="btnPickPisition_Click" /><asp:Button runat="server" id="btnClearPosition" text="Clear" OnClick="btnClearPosition_Click" />
                                <asp:HiddenField runat="server" ID="hdnPositionId" />
                            </td>
                        </tr>
                    </table>--%>
                </td>
                <td>
                    <asp:Button ID="btUpdate" runat="server" Text="Update" Font-Bold="true" Font-Size="Larger"
                        Width="120px" Height="28px" OnClick="btUpdate_Click" />
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel><%--
<asp:UpdatePanel runat="server" ID="upPosition" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:LinkButton runat="server" ID="link1"></asp:LinkButton>
        <ajaxToolkit:ModalPopupExtender runat="server" ID="mpePosition" TargetControlID="link1" PopupControlID="PanelPosition" CancelControlID="btnCancelPosition" BackgroundCssClass="modalBackground"></ajaxToolkit:ModalPopupExtender>
        <asp:Panel runat="server" ID="PanelPosition" Width="400" BorderWidth="1" BorderColor="Black" BorderStyle="Solid" BackColor="White">
            <table cellpadding="5">
                <tr><td>Siebel Login ID: <asp:TextBox runat="server" ID="txtSearchPosition" /><asp:Button runat="server" ID="btnSearchPosition" Text="Search" OnClick="btnSearchPosition_Click" /></td></tr>
                <tr>
                    <td>
                        <asp:GridView runat="server" ID="gvPosition" DataSourceID="sqlPosition" PageSize="30" AutoGenerateColumns="false" AllowPaging="true">
                            <Columns>
                                <asp:BoundField HeaderText="Position ID" DataField="ROW_ID" />
                                <asp:TemplateField HeaderText="Position Name">
                                    <ItemTemplate>
                                        <asp:LinkButton runat="server" ID="btnSetPosition" Text='<%#Eval("NAME") %>' OnClick="btnSetPosition_Click" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="User" DataField="LOGIN" />
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="sqlPosition" ConnectionString="<%$connectionStrings: CRMDB75 %>"
                            SelectCommand="select a.ROW_ID, a.NAME, b.LOGIN from S_POSTN a left join S_USER b on a.PR_EMP_ID=b.ROW_ID where b.LOGIN like '%' + @LOGIN + '%' order by b.LOGIN">
                            <SelectParameters>
                                <asp:ControlParameter Name="LOGIN" ControlID="txtSearchPosition" Type="String" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </td>
                </tr>
                <tr><td align="center"><asp:Button runat="server" ID="btnCancelPosition" Text="Close" Width="50" /></td></tr>
            </table>
        </asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>--%>