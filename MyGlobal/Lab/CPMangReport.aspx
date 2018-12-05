<%@ Page Language="VB" %>

<!DOCTYPE html>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As EventArgs)

        Dim _sql As New StringBuilder
        _sql.AppendLine(" SELECT a.COMPANY_NAME as Customer, '' as Sales, c.PRODUCT_DIVISION as PD ")
        _sql.AppendLine(" , b.item_no as AdvantechPN,c.PRODUCT_DESC as [Description] ")
        _sql.AppendLine(" ,'' as [6MAverageQty],'' as SafetyStock, '' as OnHandStock ")
        _sql.AppendLine(" FROM SAP_DIMCOMPANY a inner join EAI_SALE_FACT b on a.COMPANY_ID=b.Customer_ID ")
        _sql.AppendLine(" left join SAP_PRODUCT c on b.item_no=c.PART_NO ")
        _sql.AppendLine(" where b.breakdown <= 0 ")
        _sql.AppendLine(" and a.COMPANY_ID='EIITAD01' ")
        _sql.AppendLine(" and b.order_date>= DATEADD(MONTH,-6,GETDATE()) ")
        _sql.AppendLine(" group by  a.COMPANY_NAME,b.item_no,c.PRODUCT_DIVISION,c.PRODUCT_DESC ")
        _sql.AppendLine(" order by item_no ")
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _sql.ToString)
        GV1.DataSource = dt
        GV1.DataBind()
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GV1" runat="server" AutoGenerateColumns="false">
                <Columns>
                    <asp:BoundField DataField="Customer" HeaderText="Customer" ItemStyle-HorizontalAlign="center" />
                    <asp:BoundField DataField="Sales" HeaderText="Sales" ItemStyle-HorizontalAlign="center" />
                    <asp:BoundField DataField="PD" HeaderText="PD" ItemStyle-HorizontalAlign="center" />
                    <asp:BoundField DataField="AdvantechPN" HeaderText="Advantech PN" ItemStyle-HorizontalAlign="center" />
                    <asp:BoundField DataField="Description" HeaderText="Description" ItemStyle-HorizontalAlign="center" />
                    <asp:BoundField DataField="6MAverageQty" HeaderText="6M Average Qty" ItemStyle-HorizontalAlign="center" />
                    <asp:BoundField DataField="SafetyStock" HeaderText="Safety Stock" ItemStyle-HorizontalAlign="center" />
                    <asp:BoundField DataField="OnHandStock" HeaderText="On-hand Stock " ItemStyle-HorizontalAlign="center" />
                    <asp:TemplateField ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            Foresee 3M
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:GridView ID="GV1_Sub" runat="server">
                                <Columns>
                                    <asp:BoundField DataField="line_no" HeaderText="Project registration" ItemStyle-HorizontalAlign="center" />
                                    <asp:BoundField DataField="line_no" HeaderText="Backlog" ItemStyle-HorizontalAlign="center" />
                                    <asp:BoundField DataField="line_no" HeaderText="Proposed Order Qty" ItemStyle-HorizontalAlign="center" />
                                    <asp:BoundField DataField="line_no" HeaderText="Advantech ATP for reference" ItemStyle-HorizontalAlign="center" />
                                </Columns>
                            </asp:GridView>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </form>
</body>
</html>
