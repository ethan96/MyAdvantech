<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="AEU OP Maintenance" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        lbErrorMsg.Text = String.Empty

        If Not Page.IsPostBack Then
            GetData()
        End If
    End Sub

    Protected Sub GetData()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", " select * FROM [AEU_OPMapping] ORDER BY SalesGroup, SalesOffice ")
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Me.gvData.DataSource = dt
            Me.gvData.DataBind()
        End If
    End Sub

    Protected Sub btnAdd_Click(sender As Object, e As EventArgs)
        Dim SalesGroup As Integer = 0
        Dim SalesOffice As Integer = 0
        Dim SalesCode As Integer = 0

        If Integer.TryParse(Me.txtSalesGroup.Text, SalesGroup) AndAlso Integer.TryParse(Me.txtSalesOffice.Text, SalesOffice) AndAlso Integer.TryParse(Me.txtSalesCode.Text, SalesCode) Then
            Try
                Dim count As Integer = Convert.ToInt32(dbUtil.dbExecuteScalar("MY", String.Format("select count(*) as c from AEU_OPMapping Where SalesGroup='{0}' and SalesOffice='{1}' and SalesCode = {2} ", SalesGroup, SalesOffice, SalesCode)))
                If count = 0 Then
                    Dim strSql As String = String.Format("insert into AEU_OPMapping values ('{0}','{1}', '{2}')", SalesGroup, SalesOffice, SalesCode)
                    dbUtil.dbExecuteNoQuery("MY", strSql)
                    GetData()
                    Me.upDatablock.Update()
                Else
                    lbErrorMsg.Text = "Same data already exists in database."
                    Exit Sub
                End If
            Catch ex As Exception
                lbErrorMsg.Text = ex.ToString
                Exit Sub
            End Try
        Else
            lbErrorMsg.Text = "Please fill In all fields first."
            Exit Sub
        End If
    End Sub

    Protected Sub btnDelete_Click(sender As Object, e As EventArgs)
        Try
            Dim btn As Button = CType(sender, Button)
            Dim row As GridViewRow = CType(btn.NamingContainer, GridViewRow)

            Dim SalesGroup As Integer = row.Cells(0).Text
            Dim SalesOffice As Integer = row.Cells(1).Text
            Dim SalesCode As Integer = row.Cells(2).Text

            Dim strSql As String = String.Format("delete from AEU_OPMapping where SalesGroup = '{0}' and SalesOffice = '{1}' and SalesCode = '{2}'", SalesGroup, SalesOffice, SalesCode)
            dbUtil.dbExecuteNoQuery("MY", strSql)
            GetData()
            Me.upDatablock.Update()
        Catch ex As Exception

        End Try
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <br />

    <div id="divMaintainblock">
        <table>
            <tr>
                <td style="width: 75px">
                    <b>Sales Group: </b>
                </td>
                <td>
                    <asp:TextBox ID="txtSalesGroup" runat="server"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td style="width: 75px">
                    <b>Sales Office: </b>
                </td>
                <td>
                    <asp:TextBox ID="txtSalesOffice" runat="server"></asp:TextBox>
                </td>
            </tr>
            <tr>
                <td style="width: 75px">
                    <b>Sales Code: </b>
                </td>
                <td>
                    <asp:TextBox ID="txtSalesCode" runat="server"></asp:TextBox>
                    <asp:Button ID="btnAdd" runat="server" Text="Add" OnClick="btnAdd_Click" />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Label ID="lbErrorMsg" runat="server" ForeColor="Red" Font-Size="Large"></asp:Label>
                </td>
            </tr>
        </table>
    </div>
    <br />
    <div id="divDatablock">
        <asp:UpdatePanel ID="upDatablock" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:GridView ID="gvData" runat="server" AutoGenerateColumns="false" AllowPaging="false" AllowSorting="true" Width="100%">
                    <Columns>
                        <asp:BoundField DataField="SalesGroup" HeaderText="SalesGroup" ItemStyle-HorizontalAlign="center" />
                        <asp:BoundField DataField="SalesOffice" HeaderText="SalesOffice" ItemStyle-HorizontalAlign="center" />
                        <asp:BoundField DataField="SalesCode" HeaderText="SalesCode" ItemStyle-HorizontalAlign="center" />
                        <asp:TemplateField ItemStyle-Width="5%">
                            <ItemTemplate>
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClick="btnDelete_Click" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>

    <script type="text/javascript">

</script>
</asp:Content>

