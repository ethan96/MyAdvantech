<%@ Control Language="VB" ClassName="ProjectProducts" %>
<script runat="server">

    Protected Sub GridView1_RowEditing(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewEditEventArgs) Handles gv1.RowEditing
        gv1.EditIndex = e.NewEditIndex
        bindsmg()
    End Sub

    Protected Sub GridView1_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs) Handles gv1.RowUpdating
        Dim Request_id As String = gv1.DataKeys(e.RowIndex).Values(0)
        Dim Line As Integer = CInt(gv1.DataKeys(e.RowIndex).Values(1))
        Dim Qty As Integer = CInt(CType(gv1.Rows(e.RowIndex).Cells(2).FindControl("TB_qty"), TextBox).Text)
        Dim DebitPricing As Double = 0 'Double.Parse(CType(gv1.Rows(e.RowIndex).Cells(3).FindControl("TB_deb"), TextBox).Text)
        Dim CPricing As Double = Double.Parse(CType(gv1.Rows(e.RowIndex).Cells(4).FindControl("TB_cp"), TextBox).Text)
        Dim ApprovedPricing = 0
        Dim TargetPricing As Double = Double.Parse(CType(gv1.Rows(e.RowIndex).Cells(5).FindControl("TB_ap"), TextBox).Text)
        Dim Comments As String = CType(gv1.Rows(e.RowIndex).Cells(6).FindControl("TB_comm"), TextBox).Text.Trim.Replace("'", "''")
        USPrjRegUtil.DTList_updateLine(Request_id, Line, Qty, DebitPricing, CPricing, ApprovedPricing, TargetPricing, Comments)
        gv1.EditIndex = -1
        bindsmg()
    End Sub
    Protected Sub dellink_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Request_id As String = gv1.DataKeys(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).RowIndex).Values(0)
        Dim Line As String = gv1.DataKeys(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).RowIndex).Values(1)
        USPrjRegUtil.DTList_DelLine(Request_id, Line)
        bindsmg()
    End Sub
    Public Sub bindsmg()
        If Request("req") IsNot Nothing Then
            Dim DtList As DataTable = USPrjRegUtil.GetDTList(Request("req"))
            If DtList.Rows.Count > 0 Then
                gv1.DataSource = DtList
                gv1.DataBind()
                Dim btnSubmitProj As Button = CType(Me.Parent.Parent.FindControl("btnSubmitProj"), Button)
                If btnSubmitProj IsNot Nothing Then
                    btnSubmitProj.Enabled = True
                End If
            Else
                gv1.DataSource = DtList
                gv1.DataBind()
            End If
        End If
    End Sub
    Protected Sub GridView1_RowCancelingEdit(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCancelEditEventArgs) Handles gv1.RowCancelingEdit
        gv1.EditIndex = -1
        bindsmg()
    End Sub
    Public Sub SetGV1(ByVal V As Boolean)
        gv1.Enabled = V
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            bindsmg()
            gv1.Enabled = False
            Dim M As New Us_Prjreg_M(Request("req"))
            If USPrjRegUtil.IsSalesContact(M.AdvSalesContact, M.Org_ID) Then
                gv1.Enabled = True
            End If
            If LCase(M.Appliciant.Trim) = Session("user_id").ToString.Trim.ToLower AndAlso (Not LCase(Request.ServerVariables("PATH_INFO")) Like "*projectapprove*") Then
                gv1.Enabled = True
            End If
        End If
    End Sub

    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Session("RBU") = "AAC" Then
            e.Row.Cells(4).Visible = False
            e.Row.Cells(5).Visible = False
        End If
    End Sub
</script>
<asp:TextBox runat="server" ID="hd1" Visible="false"></asp:TextBox>
<ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender8"
    TargetControlID="hd1" FilterType="Numbers" />
<sgv:SmartGridView runat="server" ID="gv1" DataKeyNames="Request_id,Line" ShowWhenEmpty="true"
    AutoGenerateColumns="false" AllowSorting="true" Width="100%" OnRowDataBound="gv1_RowDataBound">
    <Columns>
        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
            <HeaderTemplate>
                No.
            </HeaderTemplate>
            <ItemTemplate>
                <%# Container.DataItemIndex + 1 %>
            </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField HeaderText="Product Items" DataField="Part_no" ReadOnly="true" ItemStyle-HorizontalAlign="Left" />
        <asp:TemplateField ItemStyle-HorizontalAlign="Right" HeaderText="Distributor PO Price">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblRowdp" Text='<%# Eval("DebitPricing", "{0:N2}")%>'></asp:Label>
            </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderText="Annual Qty">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblRowqty" Text='<%# Eval("Qty")%>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox runat="server" ID="TB_qty" Text='<%# Eval("Qty")%>'> </asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField ItemStyle-HorizontalAlign="Right" HeaderText="Distributor Target Price">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblRowcp" Text='<%# Eval("CPricing", "{0:N2}")%>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox runat="server" ID="TB_cp" Text='<%# Eval("CPricing","{0:N2}")%>'> </asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField ItemStyle-HorizontalAlign="Right" HeaderText="End User Cost">
            <ItemTemplate>
                <asp:Label runat="server" ID="lblRowap" Text='<%# Eval("TargetPricing", "{0:N2}")%>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox runat="server" ID="TB_ap" Text='<%# Eval("TargetPricing","{0:N2}")%>'> </asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderText="Comments" ItemStyle-Width="305">
            <ItemTemplate>
                <asp:Panel runat="server" ID="cpanel" Height="100" Width="300" HorizontalAlign="Left"
                    ScrollBars="Vertical">
                    <%# Eval("Comments")%>
                </asp:Panel>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox runat="server" ID="TB_comm" Height="100" Width="300" Text='<%# Eval("Comments")%>'
                    TextMode="MultiLine"> </asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>
        <asp:CommandField ShowEditButton="true" ItemStyle-Width="30px" EditText="Edit" HeaderText="Edit"
            ItemStyle-HorizontalAlign="Center" ShowCancelButton="true" CancelText="Cancel"
            ShowDeleteButton="false" />
        <asp:TemplateField ItemStyle-Width="20px" ItemStyle-HorizontalAlign="Center">
            <HeaderTemplate>
                DEL
            </HeaderTemplate>
            <ItemTemplate>
                <asp:LinkButton runat="server" ID="dellink" OnClick="dellink_Click">Delete</asp:LinkButton>
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
