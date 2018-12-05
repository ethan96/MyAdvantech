<%@ Control Language="VB" ClassName="PickPN" %>
<%@ Import Namespace="System.Reflection" %>
<script runat="server">
    Function getProduct(ByVal partNo As String, ByVal DESC As String) As DataTable
        Dim DT As New DataTable
        Dim str As String = String.Format( _
           " select distinct TOP 50 a.Part_no, b.model_no, b.product_desc " + _
           " from SAP_PRODUCT_STATUS a inner join sap_product b ON A.PART_NO=B.PART_NO " + _
           " inner join SAP_PRODUCT_ABC c on a.PART_NO=c.PART_NO and a.DLV_PLANT=c.PLANT " + _
           " where a.part_no like '%{0}%' and b.product_desc like '%{2}%' and a.sales_org='{1}' " + _
           " and a.part_no not like '%-bto' and a.PRODUCT_STATUS in ('A','N','H','M1') " + _
           " and b.material_group not in ('ODM','T','ES','ZSRV','968MS')", partNo, Session("org_id"), DESC)
        'and b.PRODUCT_HIERARCHY!='EAPC-INNO-DPX'
        DT = dbUtil.dbGetDataTable("b2b", str)
        Return DT
    End Function
    
    
    Public Sub getData(ByVal partNo As String, ByVal Desc As String)
        Dim dt As DataTable = getProduct(partNo, Desc)
        Me.GridView1.DataSource = dt
    End Sub

    Public Sub ShowData(ByVal partNo As String, ByVal Desc As String)
        getData(partNo, Desc)
        Me.GridView1.DataBind()
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.GridView1.PageIndex = e.NewPageIndex
        ShowData(Me.txtName.Text.Trim.Replace("'", "''"), Me.txtDesc.Text.Trim.Replace("'", "''"))
    End Sub


    Protected Sub lbtnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim o As LinkButton = CType(sender, LinkButton)
        Dim row As GridViewRow = CType(o.NamingContainer, GridViewRow)
        Dim key As Object = Me.GridView1.DataKeys(row.RowIndex).Values
        Dim P As Page = Me.Parent.Page
        Dim TP As Type = P.GetType()
        Dim MI As MethodInfo = TP.GetMethod("PickProductEnd")
        Dim para(0) As Object
        para(0) = key
        MI.Invoke(P, para)
    End Sub

    Protected Sub btnSH_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ShowData(Me.txtName.Text.Trim.Replace("'", "''"), Me.txtDesc.Text.Trim.Replace("'", "''"))
    End Sub
</script>
<asp:Panel DefaultButton="btnSH" runat="server" ID="pldd">
    Part No:<asp:TextBox runat="server" ID="txtName"></asp:TextBox>
    <ajaxToolkit:AutoCompleteExtender ID="AutoCompleteExtender1" runat="server" TargetControlID="txtName"
                                ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetPartNo" MinimumPrefixLength="2">
                            </ajaxToolkit:AutoCompleteExtender>
    Desc:<asp:TextBox runat="server" ID="txtDesc"></asp:TextBox>
    <%--<asp:TextBox runat="server" ID="txtOrg" ReadOnly="true"></asp:TextBox>--%>
    <asp:Button runat="server" ID="btnSH" OnClick="btnSH_Click" Text="Search" />
</asp:Panel>
<asp:GridView DataKeyNames="Part_no" ID="GridView1" AllowPaging="true" PageIndex="0"
    PageSize="10" runat="server" AutoGenerateColumns="false" OnPageIndexChanging="GridView1_PageIndexChanging"
    Width="100%">
    <Columns>
        <asp:TemplateField>
            <HeaderTemplate>
                <asp:Label runat="server" ID="lbPick" Text="Pick"></asp:Label>
            </HeaderTemplate>
            <ItemTemplate>
                <asp:LinkButton runat="server" ID="lbtnPick" Text="Pick" OnClick="lbtnPick_Click"></asp:LinkButton>
            </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField HeaderText="Part No" DataField="part_no" ItemStyle-HorizontalAlign="Left" />
        <asp:BoundField HeaderText="Model No" DataField="model_no" ItemStyle-HorizontalAlign="Left" />
        <asp:BoundField HeaderText="Description" DataField="product_desc" ItemStyle-HorizontalAlign="Left" />
    </Columns>
</asp:GridView>
