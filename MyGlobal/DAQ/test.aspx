<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "select * from DAQ_products where SKU <> ''")
        gv1.DataSource = dt
        gv1.DataBind()
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim DDL As Image = DirectCast(e.Row.Cells(0).FindControl("Image1"), Image)
            DDL.ImageUrl = "http://my-global.advantech.eu/download/downloadlit.aspx?pn=" + gv1.DataKeys(e.Row.RowIndex).Values(0).ToString + ""
        End If
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
</head>
<body >
    <form id="form1" runat="server">
 
    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false"  DataKeyNames="sku" onrowdatabound="gv1_RowDataBound">
        <Columns>
            <asp:TemplateField>
               
                <ItemTemplate>
                    <asp:Image ID="Image1" Width="50px" Height="50px" runat="server"  />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="sku" />
        </Columns>

    </asp:GridView>
    </form>
</body>
</html>
