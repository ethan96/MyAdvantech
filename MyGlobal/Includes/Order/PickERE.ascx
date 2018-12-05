<%@ Control Language="VB" ClassName="PickERE" %>
<%@ import Namespace="System.Reflection" %>
<script runat="server">
    Public Sub getData(ByVal Name As String)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("Select sales_code,full_name from sap_employee WHERE PERS_AREA='{0}' and full_name like '%{0}%'", Name, Session("org_id").ToString))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("Select sales_code,full_name from sap_employee WHERE  SNAME like N'%{0}%' or SALES_CODE like N'%{0}%' or FULL_NAME like N'%{0}%' or EMAIL like N'%{0}%'", Name.Trim))
        Me.GridView1.DataSource = dt
    End Sub

    Public Sub ShowData(ByVal Name As String)
        getData(Name)
        Me.GridView1.DataBind()
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.GridView1.PageIndex = e.NewPageIndex
        ShowData(Me.txtSH.Text.Replace("'", "''"))
        Me.GridView1.DataBind()
    End Sub


    Protected Sub lbtnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim o As LinkButton = CType(sender, LinkButton)
        Dim row As GridViewRow = CType(o.NamingContainer, GridViewRow)
        Dim key As Object = Me.GridView1.DataKeys(row.RowIndex).Value
        Dim P As Page = Me.Parent.Page
        Dim TP As Type = P.GetType()
        Dim MI As MethodInfo = TP.GetMethod("PickEREEnd")
        Dim para(0) As Object
        para(0) = key
        MI.Invoke(P, para)
    End Sub
    Protected Sub btnSH_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ShowData(Me.txtSH.Text.Replace("'", "''"))
    End Sub
</script>
Name or Sales Code: <asp:TextBox runat="server" ID="txtSH"></asp:TextBox><asp:Button runat="server" ID="btnSH" OnClick="btnSH_Click" Text="Search" />
<asp:GridView DataKeyNames="SALES_CODE" ID="GridView1" AllowPaging="true" PageIndex="0" PageSize="10" runat="server" 
    AutoGenerateColumns="false" OnPageIndexChanging="GridView1_PageIndexChanging" Width="100%">
    <Columns>
    <asp:TemplateField>
    <HeaderTemplate>
     <asp:Label runat="server" ID="lbPick" Text="Pick"></asp:Label>
    </HeaderTemplate>
    <ItemTemplate>
    <asp:LinkButton runat="server" ID="lbtnPick" Text="Pick" OnClick="lbtnPick_Click"></asp:LinkButton>
    </ItemTemplate>
    </asp:TemplateField>
        <asp:BoundField DataField="FULL_NAME" HeaderText="Name" />
        <asp:BoundField DataField="SALES_CODE" HeaderText="Code" />
    </Columns>
</asp:GridView>