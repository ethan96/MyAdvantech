<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Protected Sub ownerSrc_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand").ToString <> "" Then
            ownerSrc.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim email As String = Trim(txtEmail.Text.Replace("'", ""))
        Dim name As String = Trim(txtName.Text.Replace("'", ""))
        If email <> "" Or name <> "" Then
            Dim sb As New StringBuilder
            sb.AppendFormat("select distinct a.email_address+' ('+a.row_id+')' as email, a.firstname+' '+a.lastname as name, a.job_title, a.account+' ('+isnull(a.account_row_id,'')+')' as account_info, a.account, a.account_type, a.account_status, a.country from siebel_contact a left join siebel_contact_rbu b on a.email_address=b.email_addr where 1=1 ")
            If Request("Flag") <> "PickContact" And Request("accid") = "" Then sb.AppendFormat(" and a.employee_flag='y' and b.rbu='ATW' and a.row_id in ('1-95','1-HXE9D','1-OUDC','1-Y4PD','1-PP5V9','1-24DUD9','1-2JOA6Z','1-J54TN') ")
            If email <> "" Then sb.AppendFormat(" and a.email_address like '{0}%'", email)
            If name <> "" Then sb.AppendFormat(" and (a.firstname like N'%{0}%' or a.lastname like N'%{0}%')", name)
            If Request("accid") <> "" And Request("Flag1") = "" Then sb.AppendFormat(" and a.account_row_id = '{0}'", Server.UrlEncode(Request("accid")).Split("(")(1).Replace(")", ""))
            If Request("accid") <> "" And Request("Flag1") = "gv" Then sb.AppendFormat(" and a.account_row_id = '{0}'", Server.UrlEncode(Request("accid")))
            sb.AppendFormat(" order by email")
            ownerSrc.SelectCommand = sb.ToString
            ViewState("SqlCommand") = sb.ToString
        Else
            ownerSrc.SelectCommand = ""
            ViewState("SqlCommand") = ""
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("Flag") <> "PickContact" Then
                ownerSrc.SelectCommand = "select distinct a.email_address+' ('+a.row_id+')' as email, a.firstname+' '+a.lastname as name, a.job_title, a.account+' ('+isnull(a.account_row_id,'')+')' as account_info, a.account, a.account_type, a.account_status, a.country from siebel_contact a left join siebel_contact_rbu b on a.email_address = b.email_addr where a.employee_flag='y' and b.RBU='ATW' and a.row_id in ('1-95','1-HXE9D','1-OUDC','1-Y4PD','1-PP5V9','1-24DUD9','1-2JOA6Z','1-J54TN') order by email"
            End If
            ViewState("SqlCommand") = ownerSrc.SelectCommand
            txtEmail.Focus()
        End If
    End Sub

    'Protected Sub gv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
    '    If e.Row.RowType = DataControlRowType.DataRow Then
    '        If Request("Flag") = "AccountTeam" Then e.Row.Cells(1).Text = "<a href='#' onclick='javascript:Pick(""" + e.Row.Cells(1).Text + """,""" + Request("Flag1") + """)'>" + e.Row.Cells(1).Text + "</a>"
    '        If Request("Flag") = "Owner" Then e.Row.Cells(1).Text = "<a href='#' onclick='javascript:Pick(""" + e.Row.Cells(1).Text + """,""" + Request("Flag1") + """)'>" + e.Row.Cells(1).Text + "</a>"
    '        If Request("Flag") = "PickContact" Then e.Row.Cells(1).Text = "<a href='#' onclick='javascript:PickContact(""" + e.Row.Cells(1).Text.Split("(")(0) + " (" + e.Row.Cells(2).Text + ")" + " (" + e.Row.Cells(1).Text.Split("(")(1).Replace(")", "") + ")"",""" + gv1.DataKeys(e.Row.RowIndex).Values(0).ToString + """,""" + Request("Flag1") + """)'>" + e.Row.Cells(1).Text + "</a>"
    '    End If
    '    If Request("Flag") = "PickContact" Then e.Row.Cells(3).Visible = True
    'End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Request("Flag") = "AccountTeam" Then e.Row.Cells(1).Text = "<a href='#' onclick='javascript:Pick(""" + e.Row.Cells(1).Text + """,""" + Request("Flag1") + """)'>" + e.Row.Cells(1).Text + "</a>"
            If Request("Flag") = "Owner" Then e.Row.Cells(1).Text = "<a href='#' onclick='javascript:Pick(""" + e.Row.Cells(1).Text + """,""" + Request("Flag1") + """)'>" + e.Row.Cells(1).Text + "</a>"
            If Request("Flag") = "PickContact" Then e.Row.Cells(1).Text = "<a href='#' onclick='javascript:PickContact(""" + e.Row.Cells(1).Text.Split("(")(0) + " (" + e.Row.Cells(2).Text + ")" + " (" + e.Row.Cells(1).Text.Split("(")(1).Replace(")", "") + ")"",""" + gv1.DataKeys(e.Row.RowIndex).Values(0).ToString + """,""" + Request("Flag1") + """)'>" + e.Row.Cells(1).Text + "</a>"
            If Request("Flag") <> "PickContact" Then e.Row.Cells(3).Visible = False
        End If
        If e.Row.RowType = DataControlRowType.Header Then
            If Request("Flag") <> "PickContact" Then e.Row.Cells(3).Visible = False
        End If
        
    End Sub
</script>
<script type="text/javascript" language="javascript">
    function Pick(email,flag)
    {
        window.opener.updateFromChildWindow(email,flag);
        self.close();
    }
    function PickContact(contact,account,flag)
    {
        window.opener.updateFromChildWindowContact(contact,account,flag);
        self.close();
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Pick Contact</title>
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
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td height="5" colspan="3">&nbsp;</td>
            </tr>
            <tr>
                <td colspan="3">
                    <asp:Panel runat="server" ID="Panel1" DefaultButton="btnSearch">
                        <table width="100%" border="0">
                            <tr>
                                <td width="50"><b>Email : </b></td>
                                <td align="left" width="150"><asp:TextBox runat="server" ID="txtEmail" /></td>
                                <td width="50"><b> Name : </b></td>
                                <td align="left" width="150"><asp:TextBox runat="server" ID="txtName" /></td>
                                <td align="left"><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
                            </tr>
                        </table>
                    </asp:Panel>
                </td>
            </tr>
            <tr><td height="5" colspan="3">&nbsp;</td></tr>
            <tr>
                <td width="5">&nbsp;</td>
                <td align="left">
                    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataSourceID="ownerSrc" AllowPaging="true" AllowSorting="true" PageSize="50" DataKeyNames="account_info" OnRowDataBound="gv1_RowDataBound">
                        <Columns>
                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                <headertemplate>
                                    No.
                                </headertemplate>
                                <itemtemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </itemtemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="email" HeaderText="Email" SortExpression="email" ItemStyle-Width="250" />
                            <asp:BoundField DataField="name" HeaderText="Name" />
                            <asp:BoundField DataField="account_info" HeaderText="Account" />
                            <asp:BoundField DataField="account" HeaderText="Account Name" SortExpression="account" Visible="false" />
                            <asp:BoundField DataField="account_type" HeaderText="Account Type" SortExpression="account_type" Visible="false" />
                            <asp:BoundField DataField="account_status" HeaderText="Account Status" SortExpression="account_status" Visible="false" />
                            <asp:BoundField DataField="country" HeaderText="Country" SortExpression="country" Visible="false" />
                        </Columns>
                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                    </asp:GridView>
                    <asp:SqlDataSource runat="server" ID="ownerSrc" ConnectionString="<%$ connectionStrings:RFM %>"
                         SelectCommand="" OnLoad="ownerSrc_Load">
                    </asp:SqlDataSource>
                </td>
                <td width="5">&nbsp;</td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
