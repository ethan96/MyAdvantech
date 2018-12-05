<%@ Control Language="VB" ClassName="CreateSAPContact" %>
<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txtCompanyID.Text = Session("company_id")
        End If
    End Sub

    Protected Sub btnCreate_Click(sender As Object, e As EventArgs)
        Me.lbMsg.Text = String.Empty

        ' Input fields validations.
        If Not Util.IsValidEmailFormat(Me.txtEmail.Text) Then
            ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "alert(""Email format incorrect, please check again."");", True)
            Exit Sub
        ElseIf String.IsNullOrEmpty(Me.txtCompanyID.Text) Then
            ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "alert(""Company ID can not be empty, please check again."");", True)
            Exit Sub
        ElseIf Not String.IsNullOrEmpty(Me.txtEmail.Text) Then
            Dim sql As New StringBuilder
            sql.AppendFormat(" select count(c.smtp_addr) as count ")
            sql.AppendFormat(" from saprdp.kna1 a inner join saprdp.knvk b on a.kunnr=b.kunnr ")
            sql.AppendFormat(" inner join saprdp.adr6 c on a.adrnr=c.addrnumber and b.prsnr=c.persnumber ")
            sql.AppendFormat(" inner join saprdp.tsabt d on b.abtnr=d.abtnr inner join saprdp.TPFKT e on b.pafkt=e.pafkt ")
            sql.AppendFormat(" where a.kunnr = '{0}' and d.spras='E' and e.spras='E' ", Session("company_id").ToString)
            sql.AppendFormat(" and a.mandt='168' and b.mandt='168' and d.mandt='168' and e.mandt='168' ")
            sql.AppendFormat(" and upper(c.smtp_addr) = '{0}' ", Me.txtEmail.Text.ToUpper)
            sql.AppendFormat(" order by b.namev, b.parnr ")

            If Convert.ToInt32(OraDbUtil.dbExecuteScalar("SAP_PRD", sql.ToString)) > 0 Then
                ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "alert(""Email address already exists."");", True)
                Exit Sub
            End If
        End If

        ' Call RFC and create to SAP.
        Advantech.Myadvantech.DataAccess.SAPDAL.CreateSAPContact(Util.IsTesting, Me.txtCompanyID.Text, Me.txtFirstName.Text, Me.txtLastName.Text, Me.txtEmail.Text, Me.txtTelNo.Text, Me.txtTelExtNo.Text, Me.ddlDepartmentCode.SelectedValue, Me.ddlJobTitleCode.SelectedValue)
        Dim tokenid As String = Me.txtEmail.Text
        Dim tokenname As String = Me.txtEmail.Text + " (" + Me.txtFirstName.Text + " " + Me.txtLastName.Text + ")"

        ' Reset all fields.
        Me.txtFirstName.Text = String.Empty : Me.txtLastName.Text = String.Empty
        Me.txtEmail.Text = String.Empty : Me.txtTelNo.Text = String.Empty
        Me.txtTelExtNo.Text = String.Empty
        Me.ddlDepartmentCode.SelectedIndex = 4
        Me.ddlJobTitleCode.SelectedIndex = 0

        ' Add result back to OrderInfoV2.aspx token textbox
        ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "SetBBContactTokenFromASCX('" + tokenid + "','" + tokenname + "'); $.fancybox.close();", True)
    End Sub
</script>

<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="true">
    <ContentTemplate>
        <table width="800px">
            <tr>
                <td colspan="4" style="font-size: 20px; color: #003377; text-align: center;">Create New Contact
                </td>
            </tr>
            <tr>
                <td colspan="4" style="height: 20px"></td>
            </tr>
            <tr>
                <th align="left" style="width: 15%">Company ID:
                </th>
                <td>
                    <asp:TextBox runat="server" ID="txtCompanyID" Enabled="false" Width="200px" />
                </td>
                <th align="left" style="width: 15%">EMail:
                </th>
                <td>
                    <asp:TextBox runat="server" ID="txtEmail" Width="200px" />
                </td>
            </tr>
            <tr>
                <th align="left" style="width: 15%">First Name:
                </th>
                <td>
                    <asp:TextBox runat="server" ID="txtFirstName" Width="200px" />
                </td>
                <th align="left" style="width: 15%">Last Name:
                </th>
                <td>
                    <asp:TextBox runat="server" ID="txtLastName" Width="200px" />
                </td>
            </tr>
            <tr>
                <th align="left" style="width: 15%">Tel No.:
                </th>
                <td>
                    <asp:TextBox runat="server" ID="txtTelNo" Width="200px" />
                </td>
                <th align="left" style="width: 15%">Tel Ext No.:
                </th>
                <td>
                    <asp:TextBox runat="server" ID="txtTelExtNo" Width="200px" />
                </td>
            </tr>
            <tr runat="server">
                <th align="left" style="width: 15%">Department Code:
                </th>
                <td style="width: 35%">
                    <asp:DropDownList ID="ddlDepartmentCode" runat="server">
                        <asp:ListItem Value="0001" Text="0001 - Sales"></asp:ListItem>
                        <asp:ListItem Value="0002" Text="0002 - Finance"></asp:ListItem>
                        <asp:ListItem Value="0003" Text="0003 - Engineering"></asp:ListItem>
                        <asp:ListItem Value="0004" Text="0004 - R&D"></asp:ListItem>
                        <asp:ListItem Value="0005" Text="0005 - Purchasing" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="0006" Text="0006 - IT"></asp:ListItem>
                        <asp:ListItem Value="0007" Text="0007 - Quality Assurance"></asp:ListItem>
                        <asp:ListItem Value="0008" Text="0008 - RMA"></asp:ListItem>
                        <asp:ListItem Value="0009" Text="0009 - Human Resources"></asp:ListItem>
                    </asp:DropDownList>
                </td>
                <th align="left" style="width: 15%">Job Title Code:
                </th>
                <td style="width: 35%">
                    <asp:DropDownList ID="ddlJobTitleCode" runat="server">
                        <asp:ListItem Value="" Text="Select..."></asp:ListItem>
                        <asp:ListItem Value="01" Text="01 - Executive Board"></asp:ListItem>
                        <asp:ListItem Value="02" Text="02 - Head of Purchasing"></asp:ListItem>
                        <asp:ListItem Value="03" Text="03 - Head of Sales"></asp:ListItem>
                        <asp:ListItem Value="04" Text="04 - Head of Personnel"></asp:ListItem>
                        <asp:ListItem Value="05" Text="05 - Janitor"></asp:ListItem>
                        <asp:ListItem Value="06" Text="06 - Head of the Canteen"></asp:ListItem>
                        <asp:ListItem Value="07" Text="07 - Personal Assistant"></asp:ListItem>
                        <asp:ListItem Value="08" Text="08 - EDP Manager"></asp:ListItem>
                        <asp:ListItem Value="09" Text="09 - Fin. Accounting Manager"></asp:ListItem>
                        <asp:ListItem Value="10" Text="10 - Marketing Manager"></asp:ListItem>
                        <asp:ListItem Value="11" Text="11 - Send e-Invoice Only"></asp:ListItem>
                        <asp:ListItem Value="12" Text="12 - Both Paper & e-Invoice"></asp:ListItem>
                        <asp:ListItem Value="13" Text="13 - Engineer"></asp:ListItem>
                        <asp:ListItem Value="14" Text="14 - Sales"></asp:ListItem>
                        <asp:ListItem Value="15" Text="15 - Accounting"></asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td colspan="4" style="height: 20px"></td>
            </tr>
            <tr>
                <td colspan="4" style="text-align: center">
                    <asp:Label ID="lbMsg" runat="server" ForeColor="Red" Font-Size="15px"></asp:Label>
                </td>
            </tr>
            <tr>
                <td colspan="4" style="text-align: center">
                    <asp:Button ID="btnCreate" runat="server" Text="Create to SAP" OnClick="btnCreate_Click" />
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
