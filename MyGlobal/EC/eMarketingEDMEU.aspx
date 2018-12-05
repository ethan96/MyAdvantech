<%@ Page Title="MyAdvantech - eDM for EU Channel Partner" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(0).Text = CDate(e.Row.Cells(0).Text).ToString("yyyy/MM/dd")
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table Width="100%">
        <tr><td><div id="navtext"><a style="color:Black" href="../home_cp.aspx">Home</a> > eDM list</div></td></tr>
        <tr><td height="10"></td></tr>
        <tr><td align="left" style="FONT-WEIGHT: bold; FONT-SIZE: 14px; COLOR: #004b85; LINE-HEIGHT: 18px; FONT-FAMILY: Arial, Helvetica, sans-serif; TEXT-DECORATION: none">eDM's available for customization by Advantech Channel Partners</th></tr>
        <tr><td height="5"></td></tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataSourceID="sql1" AllowSorting="true" OnRowDataBound="gv1_RowDataBound">
                    <Columns>
                        <asp:BoundField HeaderText="Release Date" DataField="actual_send_date" SortExpression="actual_send_date" ItemStyle-HorizontalAlign="Center" />
                        <asp:BoundField HeaderText="Subject" DataField="email_subject" SortExpression="email_subject" />
                        <asp:HyperLinkField HeaderText="View eDM online" DataNavigateUrlFields="row_id" DataNavigateUrlFormatString="~/Includes/GetTemplate.ashx?RowId={0}" DataTextField="row_id" DataTextFormatString="View" Target="_blank" ItemStyle-HorizontalAlign="Center" />
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings: My %>"
                    SelectCommand="select distinct a.row_id, a.EMAIL_SUBJECT, a.actual_send_date from CAMPAIGN_MASTER a where a.REGION in ('AEU','ADL','AEE','AFR','AIT','AUK') and a.ACTUAL_SEND_DATE is not null and a.IS_PUBLIC=1 order by a.actual_send_date desc">
                </asp:SqlDataSource>
            </td>
        </tr>
        <tr><td height="10"></td></tr>
    </table>
</asp:Content>

