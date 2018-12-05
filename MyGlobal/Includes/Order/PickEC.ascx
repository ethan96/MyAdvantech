<%@ Control Language="VB" ClassName="PickEC" %>
<%@ Import Namespace="System.Reflection" %>
<script runat="server">
    Dim myCompany As New SAP_Company("b2b", "SAP_dimCompany")
    Public Sub getData(ByVal Company_Name As String)
        Dim SQLSTR As String = String.Format("select distinct COMPANY_ID,COMPANY_NAME,ADDRESS from {0} WHERE org_id='{2}' AND (COMPANY_NAME LIKE '%{1}%' OR COMPANY_ID LIKE '%{1}%')", myCompany.tb, Company_Name, Session("ORG_ID"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", SQLSTR)
        Me.GridView1.DataSource = dt
    End Sub

    Public Sub ShowData(ByVal Company_Name As String)
        getData(Company_Name)
        Me.GridView1.DataBind()
    End Sub
    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.GridView1.PageIndex = e.NewPageIndex
        ShowData(Me.txtSH.Text.Replace("'", "''"))
    End Sub


    Protected Sub lbtnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim o As LinkButton = CType(sender, LinkButton)
        Dim row As GridViewRow = CType(o.NamingContainer, GridViewRow)
        Dim key As Object = Me.GridView1.DataKeys(row.RowIndex).Value
        Dim P As Page = Me.Parent.Page
        Dim TP As Type = P.GetType()
        Dim MI As MethodInfo = TP.GetMethod("PickECEnd")
        Dim para(0) As Object
        para(0) = key
        MI.Invoke(P, para)
    End Sub

    Protected Sub btnSH_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ShowData(Me.txtSH.Text.Replace("'", "''"))
    End Sub
</script>
Company Name/ID:<asp:TextBox runat="server" ID="txtSH"></asp:TextBox><asp:Button runat="server" ID="btnSH" OnClick="btnSH_Click" Text="Search" />
<asp:GridView DataKeyNames="COMPANY_ID" ID="GridView1" AllowPaging="true" PageIndex="0"
    PageSize="10" runat="server" AutoGenerateColumns="false" OnPageIndexChanging="GridView1_PageIndexChanging" Width="100%">
     <Columns>
    <asp:TemplateField>
    <HeaderTemplate>
     <asp:Label runat="server" ID="lbPick" Text="Pick"></asp:Label>
    </HeaderTemplate>
    <ItemTemplate>
    <asp:LinkButton runat="server" ID="lbtnPick" Text="Pick" OnClick="lbtnPick_Click"></asp:LinkButton>
    </ItemTemplate>
    </asp:TemplateField>
        <asp:BoundField HeaderText="ID" DataField="COMPANY_ID" ItemStyle-HorizontalAlign="Left" />
        <asp:BoundField HeaderText="Name" DataField="COMPANY_NAME" ItemStyle-HorizontalAlign="Left" />
        <asp:BoundField HeaderText="Address" DataField="ADDRESS" ItemStyle-HorizontalAlign="Left" />
    </Columns>
</asp:GridView>
