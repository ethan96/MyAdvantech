<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub AccSrc_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand").ToString <> "" Then
            AccSrc.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            AccSrc.SelectCommand = String.Format("select distinct top 30 account_name + ' (' + row_id + ')' as account_name, erp_id,rbu,primary_sales_email from SIEBEL_ACCOUNT order by account_name + ' (' + row_id + ')'")
            ViewState("SqlCommand") = AccSrc.SelectCommand
            txtAccName.Focus()
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim name As String = txtAccName.Text.Trim().Replace("'", "''")
        Dim erpid As String = txtERPID.Text.Trim().Replace("'", "''")
        Dim sb As New StringBuilder
        sb.AppendFormat("select distinct a.account_name + ' (' + a.row_id + ')' as account_name, a.erp_id,a.rbu,a.primary_sales_email from SIEBEL_ACCOUNT a ")
        sb.AppendFormat(" where 1=1 ")
        If name <> "" Or erpid <> "" Then
            If name <> "" Then sb.AppendFormat(" and a.account_name like N'%{0}%'", name)
            If erpid <> "" Then sb.AppendFormat(" and a.erp_id like '{0}%'", erpid)
            sb.AppendFormat(" order by account_name")
            AccSrc.SelectCommand = sb.ToString
            ViewState("SqlCommand") = sb.ToString
        Else
            sb.AppendFormat(" order by account_name")
            AccSrc.SelectCommand = sb.ToString
            ViewState("SqlCommand") = sb.ToString
        End If
    End Sub

    Protected Sub gv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(1).Text = "<a href='#' onclick='javascript:Pick(""" + e.Row.Cells(1).Text + """)'>" + e.Row.Cells(1).Text + "</a>"
        End If
    End Sub
</script>
<script type="text/javascript" language="javascript">
    function Pick(accname)
    {
        window.opener.updateFromChildWindowAcc(accname);
        self.close();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Pick Account</title>
    <meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR"/>
	<meta content="Visual Basic .NET 7.1" name="CODE_LANGUAGE"/>
	<meta content="JavaScript" name="vs_defaultClientScript"/>
	<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema"/>
	<link runat="server" id="ebizCss" visible="true" href="../Includes/ebiz.aeu.style.css" rel="stylesheet" type="text/css" />
    <link href="../Includes/global.css" rel="Stylesheet" type="text/css" />   
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td height="5" colspan="3">&nbsp;</td>
            </tr>
            <tr>
                <td colspan="3">
                    <asp:Panel runat="server" ID="Panel1" DefaultButton="btnSearch">
                        <table width="100%" border="0">
                            <tr>
                                <td width="100"><b>Account Name : </b></td>
                                <td align="left" width="150"><asp:TextBox runat="server" ID="txtAccName" /></td>
                                <td width="80"><b>ERP ID : </b></td>
                                <td align="left" width="150"><asp:TextBox runat="server" ID="txtERPID" /></td>
                                <td><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
            </tr>
            <tr><td height="5" colspan="3">&nbsp;</td></tr>
            <tr>
                <td width="5">&nbsp;</td>
                <td align="left">
                    <sgv:SmartGridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataSourceID="AccSrc" AllowPaging="true" AllowSorting="true" PageSize="50" OnRowDataBoundDataRow="gv1_RowDataBoundDataRow">
                        <Columns>
                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                <headertemplate>
                                    No.
                                </headertemplate>
                                <itemtemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </itemtemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="account_name" HeaderText="Account Name" SortExpression="account_name" />
                            <asp:BoundField DataField="erp_id" HeaderText="ERP ID" SortExpression="erp_id" />
                            <asp:BoundField DataField="rbu" HeaderText="RBU" SortExpression="RBU" />
                            <asp:BoundField DataField="primary_sales_email" HeaderText="Primary Sales Email" SortExpression="primary_sales_email" />
                        </Columns>
                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                    </sgv:SmartGridView>
                    <asp:SqlDataSource runat="server" ID="AccSrc" ConnectionString="<%$ connectionStrings:RFM %>"
                         SelectCommand="" OnLoad="AccSrc_Load">
                    </asp:SqlDataSource>
                </td>
                <td width="5">&nbsp;</td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
