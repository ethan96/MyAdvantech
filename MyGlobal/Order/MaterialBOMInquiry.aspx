<%@ Page Title="MyAdvantech – Material BOM Inquiry" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As New DataTable
        Dim er As String = ""
        dt = SAPtools.getCOMBOM(Me.txtPartNo.Text.Trim.ToUpper, Me.drpPlant.SelectedValue, er)
        If Not IsNothing(dt) Then
            Me.gv1.DataSource = dt : Me.gv1.DataBind()
        Else
            Me.lbMsg.Text = er
        End If
    End Sub
    
    Sub getPlantListByOrg()
        Dim PLANT As String = ""
        Me.drpPlant.Items.Add(New ListItem("Select...", ""))
        If Session("Org_id") IsNot Nothing Then
            If Session("Org_id") = "SG01" Then
                PLANT = "SGH1" : Me.drpPlant.Items.Add(PLANT) : PLANT = "TWH1" : Me.drpPlant.Items.Add(PLANT)
            ElseIf Session("Org_id") = "EU10" Or Session("company_id").ToString.StartsWith("E", StringComparison.OrdinalIgnoreCase) Then
                PLANT = "EUH1" : Me.drpPlant.Items.Add(PLANT) : PLANT = "TWH1" : Me.drpPlant.Items.Add(PLANT)
            Else
                PLANT = OrderUtilities.getPlant() : Me.drpPlant.Items.Add(PLANT)
            End If
        Else
            '20130118 TC: Add Kon2052@gmail.com   kozlov@prosoft.ru  fokeev@sgb.prosoft.ru Per tommy.chang & Selina.Hung's request
            '20121214 TC: Per IAG Selina.Hung and Jonhan.Wu's request allow customer Alex to access this page
            If String.Equals(User.Identity.Name, "alex_fedorushchenko@elko.spb.ru", StringComparison.CurrentCultureIgnoreCase) Or _
                String.Equals(User.Identity.Name, "kozlov@prosoft.ru", StringComparison.CurrentCultureIgnoreCase) Or _
                String.Equals(User.Identity.Name, "fokeev@sgb.prosoft.ru", StringComparison.CurrentCultureIgnoreCase) Or _
                String.Equals(User.Identity.Name, "Kon2052@gmail.com", StringComparison.CurrentCultureIgnoreCase) Or _
                String.Equals(User.Identity.Name, "fokeev@sgb.prosoft.ru", StringComparison.CurrentCultureIgnoreCase) Or _
                String.Equals(User.Identity.Name, "techsupp@startechgcc.com", StringComparison.CurrentCultureIgnoreCase) Or _
                String.Equals(User.Identity.Name, "kolchenko@prosoft.ru", StringComparison.CurrentCultureIgnoreCase) Then
                Me.drpPlant.Items.Add("TWH1")
            Else
                Response.Redirect("../home.aspx")
            End If
        End If
    End Sub
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(0).Text = e.Row.Cells(0).Text.TrimStart("0")
        End If
    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            getPlantListByOrg()
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <br />
    <br />
    <h2>
        Material BOM Inquiry
    </h2>
    <br />
    <br />
    <asp:Panel runat="server" ID="Panel1" DefaultButton="btnQuery">
        <table>
            <tr>
                <th align="left">
                    Part No:
                </th>
                <td>
                    <asp:TextBox ID="txtPartNo" runat="server" />
                    <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" TargetControlID="txtPartNo"
                        ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetPartNo" MinimumPrefixLength="2">
                    </ajaxToolkit:AutoCompleteExtender>
                </td>
            </tr>
            <tr>
                <th align="left">
                    Plant:
                </th>
                <td>
                    <asp:DropDownList ID="drpPlant" runat="server">
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Button ID="btnQuery" runat="server" Text="Query" OnClick="btnQuery_Click" />&nbsp;<asp:Label
                        ID="lbMsg" runat="server" Text="" ForeColor="Red" Font-Bold="true" />
                </td>
            </tr>
        </table>
    </asp:Panel>
    <asp:GridView runat="server" ID="gv1" Width="100%" AllowPaging="false" AutoGenerateColumns="false"
        ShowHeaderWhenEmpty="true" OnRowDataBound="gv1_RowDataBound">
        <Columns>
            <asp:BoundField DataField="IDNRK" HeaderText="Part No" ItemStyle-HorizontalAlign="left" />
            <asp:BoundField DataField="Ojtxp" HeaderText="Description" ItemStyle-HorizontalAlign="left" />
        </Columns>
    </asp:GridView>
</asp:Content>
