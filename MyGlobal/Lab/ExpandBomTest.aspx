<%@ Page Language="VB" %>

<!DOCTYPE html>

<script runat="server">

    Protected Sub Button1_Click(sender As Object, e As EventArgs)
        'Dim dt As DataTable = Advantech.Myadvantech.Business.PartBusinessLogic.ExpandSchneiderSystemPartToCart(TextBox1.Text)
        Dim dt As New DataTable
        Me.GridView1.DataSource = dt
        Me.GridView1.DataBind()
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:TextBox ID="TextBox1" runat="server" Text="SES-BM2332-H842AE" />
        <asp:Button ID="Button1" runat="server" Text="Button" OnClick="Button1_Click" />
        <asp:GridView ID="GridView1" runat="server" />
    </div>
    </form>
</body>
</html>
