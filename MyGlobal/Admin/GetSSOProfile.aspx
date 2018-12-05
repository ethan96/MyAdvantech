<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - SSO User Profile Inquiry" %>

<script runat="server">

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(txtEmail.Text.Trim(), dlApp.SelectedItem.Text), pmFlag As Boolean = False
        If p Is Nothing Then
            p = ws.getProfile(txtEmail.Text.Trim(), "my") : pmFlag = True
        End If
        lbIsExist.Text = ws.isExist(txtEmail.Text.Trim(), "MY").ToString()
        If p IsNot Nothing Then
            Dim dt As New DataTable
            With dt.Columns
                .Add("canseeorder") : .Add("company_id") : .Add("company_name") : .Add("email_addr") : .Add("erpid")
                .Add("first_name") : .Add("last_name") : .Add("login_password") : .Add("PriOrgId") : .Add("Status")
            End With
            Dim r As DataRow = dt.NewRow
            With r
                .Item("canseeorder") = p.canseeorder
                
                .Item("company_id") = p.company_id
                .Item("company_name") = p.company_name
                .Item("email_addr") = p.email_addr
                .Item("erpid") = p.erpid
                .Item("first_name") = p.first_name
                .Item("last_name") = p.last_name
                .Item("login_password") = p.login_password
                .Item("PriOrgId") = p.primary_org_id
                .Item("Status") = p.user_status
            End With
            dt.Rows.Add(r)
            gv1.DataSource = dt : gv1.DataBind() : lbMsg.Text = ""
            If pmFlag Then lbMsg.Text = "User exists only in MyAdvantech but PZ"
        Else
            gv1.DataSource = Nothing : gv1.DataBind()
            lbMsg.Text = "User not found"
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsAEUIT() Then Response.End()
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <table width="100%">
        <tr>
            <td>
                Email:<asp:TextBox runat="server" ID="txtEmail" Width="250px" />&nbsp;
                <asp:DropDownList runat="server" ID="dlApp">
                    <asp:ListItem Text="PZ" />
                    <asp:ListItem Text="MY" />
                    <asp:ListItem Text="RMA" />
                    <asp:ListItem Text="EZ" />
                </asp:DropDownList>
                <asp:Button runat="server" ID="btnQuery" Text="Query" OnClick="btnQuery_Click" />
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label runat="server" ID="lbMsg" />&nbsp:Is Exist?<asp:Label runat="server" ID="lbIsExist" Font-Bold="true" />
                <asp:GridView runat="server" ID="gv1" Width="70%" />
            </td>
        </tr>
    </table>
</asp:Content>