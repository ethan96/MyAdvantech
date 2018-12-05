<%@ Page Title="MyAdvantech - Search Order History by Serial Number" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetSN(ByVal prefixText As String, ByVal count As Integer) As String()
        If True Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
        "select distinct top 10 barcode_no from RMA_SFIS where barcode_no like '{0}%' and barcode_no is not null and barcode_no<>'' order by barcode_no  ", prefixText.Trim().Replace("'", "''").Replace("*", "%")))
            If dt.Rows.Count > 0 Then
                Dim str(dt.Rows.Count - 1) As String
                For i As Integer = 0 To dt.Rows.Count - 1
                    str(i) = dt.Rows(i).Item(0)
                Next
                Return str
            End If
        End If
        Return Nothing
    End Function
    
    Function GetSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 10 a.barcode_no as serial_number, a.product_name as part_no, dbo.DateOnly(a.warranty_date) as warranty_date, "))
            .AppendLine(String.Format(" a.customer_no as company_id, a.order_no, dbo.DateOnly(a.In_Station_Time) as shipping_date,  "))
            .AppendLine(String.Format(" ISNULL((select top 1 z.company_name from sap_dimcompany z where z.company_id=a.customer_no),'') as company_name "))
            .AppendLine(String.Format(" from RMA_SFIS a "))
            .AppendLine(String.Format(" where barcode_no like '{0}%' order by barcode_no  ", txtSN.Text.Trim().Replace("'", "''").Replace("*", "%")))
        End With
        Return sb.ToString()
    End Function

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txtSN.Attributes("autocomplete") = "off"
        End If
    End Sub

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gv1.PageIndex = 0 : src1.SelectCommand = GetSql()
        gv1.EmptyDataText = "No Seach Result"
    End Sub

    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%" id="stb">
        <tr>
            <th align="left" style="color:Navy"><h2>Search Order History by Serial Number</h2></th>
        </tr>
        <tr valign="top">
            <td>
                <table>
                    <tr>
                        <th align="left">Serial Number</th>
                        <td>
                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" TargetControlID="txtSN" 
                                MinimumPrefixLength="0" CompletionInterval="200" ServiceMethod="GetSN" />
                            <asp:Panel runat="server" ID="Panel1" DefaultButton="btnQuery">
                                <asp:TextBox runat="server" ID="txtSN" Width="130px" />
                            </asp:Panel>                            
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" align="center"><asp:Button runat="server" ID="btnQuery" Text="Search" OnClick="btnQuery_Click" /></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr valign="top">
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" Width="90%" AutoGenerateColumns="false" DataSourceID="src1">
                            <Columns>
                                <asp:BoundField HeaderText="Serial Number" DataField="serial_number" SortExpression="serial_number" />
                                <asp:HyperLinkField HeaderText="Part No." DataNavigateUrlFields="part_no" 
                                    DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" DataTextField="part_no" Target="_blank" />   
                                <asp:HyperLinkField HeaderText="Account Name" DataNavigateUrlFields="company_id" 
                                    DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ERPID={0}" DataTextField="company_name" /> 
                                <asp:BoundField HeaderText="Shipping Date" DataField="shipping_date" SortExpression="shipping_date" />
                                <asp:BoundField HeaderText="Warranty Expire Date" DataField="warranty_date" SortExpression="warranty_date" />
                                <asp:HyperLinkField HeaderText="Order No." DataNavigateUrlFields="order_no" 
                                    DataNavigateUrlFormatString="~/DM/SingleOrderHistory.aspx?SONO={0}" 
                                    DataTextField="order_no" SortExpression="order_no" Target="_blank" />
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src1_Selecting" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        //document.getElementById('stb').style.height = Math.max(document.documentElement.scrollHeight, document.body.scrollHeight) - 160 + "px";
    </script>
</asp:Content>