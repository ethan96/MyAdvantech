<%@ Page Title="Special BTOS" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim MySpecialBto As New SpecialBto("b2b", "SpecialBto")
    Dim IFName As String = ""
    Dim IFParent As String = ""
    Dim IFPrice As Decimal
    Function GetValFromForm() As Integer
        IFName = Util.ReplaceSQLStringFunc(Me.txtName.Text.Trim)
        If IFName = "" Then
            Glob.ShowInfo("Component Name Can not be Null!")
            Return 0
        End If
        IFParent = Util.ReplaceSQLStringFunc(Me.txtParent.Text.Trim)
        If IFParent = "" Then
            Glob.ShowInfo("Parent Bto Can not be Null!")
            Return 0
        End If
        If Not IsNumeric(Util.ReplaceSQLStringFunc(Me.txtPrice.Text.Trim)) Then
            Glob.ShowInfo("Price Should be a number!")
            Return 0
        End If
        IFPrice = Util.ReplaceSQLStringFunc(Me.txtPrice.Text.Trim)
        Return 1
    End Function
    
    Function SetValToForm(ByVal IFName As String, ByVal IFParent As String, ByVal IFPrice As Decimal) As Integer
        Me.txtName.Text = IFName
        Me.txtParent.Text = IFParent
        Me.txtPrice.Text = IFPrice
        Return 1
    End Function
    Protected Sub initGV()
        Dim dt As DataTable = MySpecialBto.GetDT("", "Parent,Name")
        Me.GridView1.DataSource = dt
        Me.GridView1.DataBind()
    End Sub
    Protected Sub btnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If GetValFromForm() = 1 Then
            Dim UID As String = System.Guid.NewGuid().ToString
            MySpecialBto.Add(UID, IFName, IFParent, IFPrice)
            initGV()
        End If
    End Sub
    
    Protected Sub initForm(ByVal UID As String)
        Dim dt As DataTable = MySpecialBto.GetDT(String.Format("UId='{0}'", UID), "")
        If dt.Rows.Count > 0 Then
            IFName = dt.Rows(0).Item("Name")
            IFParent = dt.Rows(0).Item("Parent")
            IFPrice = dt.Rows(0).Item("Price")
            SetValToForm(IFName, IFParent, IFPrice)
            Me.btnEdit.Visible = True
        End If
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Not IsNothing(Request("UID")) AndAlso Request("UID") <> "" Then
                initForm(Request("UID"))
            End If
            initGV()
        End If
    End Sub
    
    Protected Sub ibtnEdit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim o As ImageButton = CType(sender, ImageButton)
        Dim row As GridViewRow = CType(o.NamingContainer, GridViewRow)
        Dim key As String = Me.GridView1.DataKeys(row.RowIndex).Value
        Response.Redirect(String.Format("~/WebCbomEditor/Special.aspx?UID={0}", key))
    End Sub
    
    Protected Sub ibtnDelete_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim o As ImageButton = CType(sender, ImageButton)
        Dim row As GridViewRow = CType(o.NamingContainer, GridViewRow)
        Dim key As String = Me.GridView1.DataKeys(row.RowIndex).Value
        MySpecialBto.Delete(String.Format("UId='{0}'", key))
        initGV()
    End Sub
    
    
    Protected Sub btnEdit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If GetValFromForm() = 1 Then
            MySpecialBto.Update(String.Format("UId='{0}'", Request("UID")), String.Format("Name=N'{0}',Parent='{1}',Price='{2}'", IFName, IFParent, IFPrice))
            Response.Redirect("~/WebCbomEditor/Special.aspx")
        End If
    End Sub

    Protected Sub GridView1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.GridView1.PageIndex = e.NewPageIndex
        initGV()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table>
        <tr>
            <td class="menu_title">
                Special BTOS Definition
            </td>
        </tr>
        <tr>
            <td style="border: 1px solid #d7d0d0; padding: 10px">
                <table>
                    <tr>
                        <td>
                            <asp:Label runat="server" ID="lb1" Text="Component Name"></asp:Label>
                            :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtName"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label runat="server" ID="Label1" Text="Parent BTO"></asp:Label>
                            :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtParent"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label runat="server" ID="Label2" Text="Price"></asp:Label>
                            :
                        </td>
                        <td>
                            <asp:TextBox runat="server" ID="txtPrice"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <table>
                    <tr>
                        <td align="center">
                            <asp:Button ID="btnAdd" runat="server" Text="Add" OnClick="btnAdd_Click" />
                            <asp:Button ID="btnEdit" Visible="false" runat="server" Text="Edit" OnClick="btnEdit_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <hr />
    <asp:GridView DataKeyNames="UId" ID="GridView1" runat="server" AllowPaging="true"
        PageSize="50" PageIndex="0" AutoGenerateColumns="false" OnPageIndexChanging="GridView1_PageIndexChanging"
        Width="100%">
        <Columns>
            <asp:BoundField DataField="Name" HeaderText="Name" />
            <asp:BoundField DataField="Parent" HeaderText="Parent BTO" />
            <asp:BoundField DataField="Price" HeaderText="Price" />
            <asp:TemplateField>
                <HeaderTemplate>
                    <asp:Label runat="server" ID="lbHdEdit" Text="Edit"></asp:Label>
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:ImageButton ImageUrl="~/Images/edit.gif" runat="server" ID="ibtnEdit" OnClick="ibtnEdit_Click" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <HeaderTemplate>
                    <asp:Label runat="server" ID="lbHdDelete" Text="Delete"></asp:Label>
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:ImageButton ImageUrl="~/Images/del.gif" runat="server" ID="ibtnDelete" OnClick="ibtnDelete_Click" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
