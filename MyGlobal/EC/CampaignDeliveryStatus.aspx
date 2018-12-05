<%@ Page Title="MyAdvantech - Campaign Delivery Status" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Public Function GetSQL() As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select z.REGION, SUM(z.Sent_Number) as Sent_Number, sum(z.Amazon) as Amazon, SUM(z.ACL) as ACL, SUM(z.AEU2) as AEU2 from ( ")
            .AppendFormat(" select b.Region, count(a.contact_email) as Sent_Number, 0 as Amazon, 0 as ACL, 0 as AEU2 ")
            .AppendFormat(" from campaign_contact_list a inner join campaign_master b on a.campaign_row_id=b.row_id ")
            .AppendFormat(" where a.email_send_time between '{0} 00:00:00' and '{1} 23:59:59' ", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)
            .AppendFormat(" group by b.region ")
            .AppendFormat(" union ")
            .AppendFormat(" select b.Region, 0 as Sent_Number, COUNT(a.contact_email) as Amazon, 0 as ACL, 0 as AEU2 ")
            .AppendFormat(" from CAMPAIGN_SEND_LOG a left join campaign_master b on a.campaign_row_id=b.row_id ")
            .AppendFormat(" where a.SEND_DATE between '{0} 00:00:00' and '{1} 23:59:59' and a.FROM_SERVER='Amazon' ", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)
            .AppendFormat(" group by b.region ")
            .AppendFormat(" union ")
            .AppendFormat(" select b.Region, 0 as Sent_Number, 0 as Amazon, COUNT(a.contact_email) as ACL, 0 as AEU2 ")
            .AppendFormat(" from CAMPAIGN_SEND_LOG a left join campaign_master b on a.campaign_row_id=b.row_id ")
            .AppendFormat(" where a.SEND_DATE between '{0} 00:00:00' and '{1} 23:59:59' and a.FROM_SERVER='172.17.20.220' ", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)
            .AppendFormat(" group by b.region ")
            .AppendFormat(" union ")
            .AppendFormat(" select b.Region, 0 as Sent_Number, 0 as Amazon, 0 as ACL, COUNT(a.contact_email) as AEU2 ")
            .AppendFormat(" from CAMPAIGN_SEND_LOG a left join campaign_master b on a.campaign_row_id=b.row_id ")
            .AppendFormat(" where a.SEND_DATE between '{0} 00:00:00' and '{1} 23:59:59' and a.FROM_SERVER='172.21.34.78' ", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)
            .AppendFormat(" group by b.region) z group by z.REGION ")
        End With
        Return sb.ToString
    End Function
    
    Protected Sub sql1_Load(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        sql1.SelectCommand = GetSQL()
        gv1.DataBind()
        up1.Update()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            txtDateFrom.Text = DateAdd(DateInterval.Day, -7, Now).ToString("yyyy/MM/dd")
            txtDateTo.Text = Now.ToString("yyyy/MM/dd")
        End If
    End Sub

    Protected Sub gv1_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        If Page.IsPostBack Then
            Dim sent As Integer = CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(contact_email) from campaign_send_log where send_date between '{0} 00:00:00' and '{1} 23:59:59'", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)))
            Dim amazon As Integer = CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(contact_email) from campaign_send_log where send_date between '{0} 00:00:00' and '{1} 23:59:59' and FROM_SERVER='Amazon'", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)))
            Dim acl As Integer = CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(contact_email) from campaign_send_log where send_date between '{0} 00:00:00' and '{1} 23:59:59' and FROM_SERVER='172.17.20.220'", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)))
            Dim aeu2 As Integer = CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(contact_email) from campaign_send_log where send_date between '{0} 00:00:00' and '{1} 23:59:59' and FROM_SERVER='172.21.34.78'", txtDateFrom.Text.Replace("'", "''").Trim, txtDateTo.Text.Replace("'", "''").Trim)))
            Dim row As New GridViewRow(0, 0, DataControlRowType.DataRow, DataControlRowState.Normal)
            row.HorizontalAlign = HorizontalAlign.Center
            Dim cell As New TableCell
            cell.Text = "<b>Total</b>"
            row.Cells.Add(cell)
            Dim cell1 As New TableCell
            cell1.Text = "<font color='red'>" + sent.ToString + "</font>"
            row.Cells.Add(cell1)
            Dim cell2 As New TableCell
            cell2.Text = "<font color='red'>" + amazon.ToString + "</font>"
            row.Cells.Add(cell2)
            Dim cell3 As New TableCell
            cell3.Text = "<font color='red'>" + acl.ToString + "</font>"
            row.Cells.Add(cell3)
            Dim cell4 As New TableCell
            cell4.Text = "<font color='red'>" + aeu2.ToString + "</font>"
            row.Cells.Add(cell4)
            'Response.Write(gv1.Controls.Count.ToString)
            gv1.Controls(0).Controls.AddAt(gv1.Controls(0).Controls.Count - 1, row)
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="80%">
        <tr><td height="10"></td></tr>
        <tr>
            <td>
                <table>
                    <tr>
                        <th>Date: </th>
                        <td><asp:TextBox runat="server" ID="txtDateFrom" /><ajaxToolkit:CalendarExtender runat="server" ID="ceDateFrom" TargetControlID="txtDateFrom" Format="yyyy/MM/dd" /></td>
                        <td> ~ </td>
                        <td><asp:TextBox runat="server" ID="txtDateTo" /><ajaxToolkit:CalendarExtender runat="server" ID="ceDateTo" TargetControlID="txtDateTo" Format="yyyy/MM/dd" /></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr><td><asp:Button runat="server" ID="btnSubmit" Text="Submit" Width="50" OnClick="btnSubmit_Click" /></td></tr>
        <tr><td height="5"></td></tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="true" DataSourceID="sql1" Width="100%" OnPreRender="gv1_PreRender"></asp:GridView>
                        <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings: MY %>"
                            SelectCommand="" OnLoad="sql1_Load">
                        </asp:SqlDataSource>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSubmit" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr><td height="10"></td></tr>
    </table>
</asp:Content>

