<%@ Page Title="MyAdvantech - eStore SYS CBOM Type Editor" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    
    Function getsql() As String
        Return "select * from cbom_ipc_type order by category_id"
    End Function
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function AutoSuggestSYS(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        "select top 20 number from ez_cbom_mapping where NUMBER like 'SYS-%' and number is not null and number like N'{0}%' order by NUMBER  ", prefixText.Trim().Replace("'", "").Replace("*", "%")))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If txtBTO.Text.Trim() = "" Then Exit Sub
        dbUtil.dbExecuteNoQuery("MY", String.Format(" delete from CBOM_IPC_TYPE where category_id=N'{0}';" + _
                                                    " INSERT INTO CBOM_IPC_TYPE (CATEGORY_ID, CATEGORY_TYPE) VALUES     (N'{0}', N'{1}',{2})", _
                                                    txtBTO.Text.Trim().Replace("'", "''"), dlType.SelectedValue.Replace("'", "''"), Me.txtSeq.Text))
        Me.src1.SelectCommand = getsql()
        txtBTO.Text="":Me.txtBTO.Focus()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.src1.SelectCommand = getsql()
        If Not Page.IsPostBack Then
            
            Me.txtBTO.Attributes("autocomplete") = "off"
        End If
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        Me.src1.SelectCommand = getsql()
    End Sub

    Protected Sub gv1_RowDeleting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Me.src1.SelectCommand = getsql()
        'gv1.DataBind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td>
                <table>
                    <tr>
                        <th align="left">Type:</th>
                        <td>
                            <asp:DropDownList runat="server" ID="dlType">
                                <asp:ListItem Value="1U (up to 3 Slots)" />
                                <asp:ListItem Value="2U (up to 5 Slots)" />
                                <asp:ListItem Value="4U MB Rackmount (up to 7-Slots)" />
                                <asp:ListItem Value="4U BP Rackmount (up to 14-Slots)" />
                                <asp:ListItem Value="4U BP Rackmount (up to 20-Slots)" />
                                <asp:ListItem Value="Wallmount (up to 6 Slots)" />
                                <asp:ListItem Value="Wallmount (up to 7 Slots)" />
                                <asp:ListItem Value="Wallmount (up to 8 Slots)" />
                            </asp:DropDownList>
                        </td>
                        <th>System Name:</th>
                        <td>
                            <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Panel runat="server" ID="panel1" DefaultButton="btnAdd">
                                        <ajaxToolkit:AutoCompleteExtender runat="server" ID="ext1" TargetControlID="txtBTO" 
                                            MinimumPrefixLength="1" 
                                            CompletionInterval="500" ServiceMethod="AutoSuggestSYS" />
                                        <asp:TextBox runat="server" ID="txtBTO" Width="150px" />
                                    </asp:Panel>                                    
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                </Triggers>
                            </asp:UpdatePanel>                            
                        </td>
                    <th>Seq No.</th>
                        <td>
                    <asp:TextBox ID="txtSeq" runat ="server"  Width="50px"></asp:TextBox>
                        </td>
                    </tr>

                    <tr>
                        <td colspan="4">
                            <asp:Button runat="server" ID="btnAdd" Text="Add" OnClick="btnAdd_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" DataSourceID="src1" AutoGenerateColumns="false" Width="600px" 
                            AllowSorting="true" OnSorting="gv1_Sorting" DataKeyNames="category_id" OnRowDeleting="gv1_RowDeleting">
                            <Columns>
                                <asp:CommandField ShowEditButton ="true" />
                                <asp:CommandField ShowDeleteButton="true" />
                                <asp:HyperLinkField HeaderText="System Name" DataNavigateUrlFields="category_id" SortExpression="category_id" 
                                    DataNavigateUrlFormatString="~/Order/ConfiguratorNew.aspx?BTOITEM={0}&QTY=1" 
                                    DataTextField="category_id" Target="_blank" />
                                <asp:BoundField HeaderText="Type" DataField="category_type" SortExpression="category_type" />

                                <asp:BoundField HeaderText="Seq" DataField="seq" SortExpression="seq" />
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" 
                            DeleteCommand="delete from cbom_ipc_type where category_id=@category_id" 
                            UpdateCommand="update cbom_ipc_type set category_type=@category_type ,seq=@seq where category_id=@category_id">
                            <UpdateParameters>
                            <asp:Parameter Name = "category_type" />
                            <asp:Parameter Name= "seq" />
                            </UpdateParameters>
                            </asp:SqlDataSource>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>