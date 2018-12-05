<%@ Page Language="VB" %>

<%--<%@ Register TagPrefix="Glob" TagName="Inc" Src="~/Utility/Global_inc.ascx" %>
<%@ Register TagPrefix="adl" Namespace="AdxInheritsDataGrid" Assembly="clsAdxInheritsDataGrid" %>--%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    Dim xCompanyID As String = ""
    Dim Type As String = ""
    Dim ElementName As String = ""
    Dim CustIDCondition As String = ""
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.GlobalInc.ValidationStateCheck()

        xCompanyID = Request.QueryString("CompanyID")
        Type = Request.QueryString("Type")
        ElementName = Request.QueryString("Element")
        Dim xOrgID = Request.QueryString("orgID")
        'If Session("user_id") = "tc.chen@advantech.com.tw" Then
        xOrgID = "BR01"
        'Dim strSqlCmd As String
        'If UCase(Type) = "SHIPTO" Then
        '    strSqlCmd = "select company_id,company_name,org_id,address,attention from company where ( company_id like '%" & xCompanyID & "%' or company_name like '%" & xCompanyID & "%') AND company_Type = 'Ship_To' AND company_name not like '*INVALID*%'"
        'If UCase(Type) = "SOLDTO" Then
        '    strSqlCmd = "select TOP 1000 company_id,company_name,org_id,address,attention from SAP_DIMCOMPANY where ( company_id like '%" & xCompanyID & "%' or company_name like '%" & xCompanyID & "%') AND company_Type = 'Z001' AND company_name not like '*INVALID*%' AND org_id ='BR01' "
        'Else
        '    strSqlCmd = "select TOP 1000  company_id,company_name,org_id,address,attention from SAP_DIMCOMPANY where ( company_id like '%" & xCompanyID & "%' or company_name like '%" & xCompanyID & "%') AND company_name not like '*INVALID*%' AND org_id like '" & xOrgID & "' "
        'End If
        'SqlDataSource1.SelectCommand = strSqlCmd 'dbUtil.dbGetDataTable("MY", strSqlCmd)
        'Me.DropShip.DataBind()
        If Not Page.IsPostBack Then
            Dim ws As New InternalWebService
            If Not ws.CanAccessABRQuotation(User.Identity.Name, Session("RBU"), Session("Account_Status")) Then
                Response.Redirect("~/home.aspx")
            End If
            Bind()
        End If

    End Sub
    Public Sub Bind()
        Dim _keywords As String = Me.TBkeywords.Text.Trim.Replace("'", "''").Replace("*", "")
        ' xCompanyID = Request.QueryString("CompanyID")
        Dim strSqlCmd As String = "select TOP 1000 company_id,company_name,org_id,address,attention,PAYMENT_TERM_CODE from SAP_DIMCOMPANY where ( company_id like '%" & _keywords & "%' or company_name like '%" & _keywords & "%') AND company_Type = 'Z001' AND company_name not like '*INVALID*%' AND org_id ='BR01' "
        SqlDataSource1.SelectCommand = strSqlCmd 'dbUtil.dbGetDataTable("MY", strSqlCmd)
        Me.DropShip.DataBind()
    End Sub
    'Protected Sub AdxGrid1_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs)
    '    Dim xDataGridItem As DataGridItem = e.Item
    '    Dim retVal() As String
    '    Dim xType As ListItemType = e.Item.ItemType
    '    Dim xCompanyID As String = ""
    '    Dim xCompanyName As String = ""
    '    Dim xOrg_ID As String = ""
    '    Dim xCompanyAttn As String = ""
    '    If xType <> ListItemType.Header And xType <> ListItemType.Footer Then
    '        retVal = Me.DropShip.VxGetGridItemValue(xDataGridItem)
    '        xCompanyID = retVal(1)
    '        xCompanyName = retVal(2)
    '        xCompanyAttn = retVal(4)
    '        xOrg_ID = retVal(5)
    '        Dim StrLink As String = ""
    '        StrLink = " 'javascript:vorg_id(0);' onClick=" & Chr(34) & "copopulate(" & "'" & ElementName & "','" & xCompanyID & "','" & xOrg_ID & "'" & "," & "'" & xCompanyAttn & "'" & "," & "'" & xCompanyName & "'" & ")" & Chr(34) & "," & _
    '                  Chr(34) & xCompanyAttn & Chr(34) & ")'"
    '        'me.DropShip.VxUserFormat(xDataGridItem,1,"<a href='#' onClick=copopulate('" & xCompanyID & "','" & xCompanyAttn & "') >" & UCase(xCompanyID) & "</a>")
    '        me.DropShip.VxUserFormat(xDataGridItem,1,"<a href='#' & " & StrLink & " >" & UCase(xCompanyID) & "</a>")
    '    End If
    'End Sub

    Protected Sub Search_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim strSqlCmd As String
        'strSqlCmd = "select company_id,company_name,org_id,address,attention from company where " & Me.ddlSearchType.selectedValue & " like '%" & Me.txtKeyWord.text.Trim() & "%'"
        'Me.DropShip.xSQL = strSqlCmd
        'Me.DropShip.CurrentPageIndex=0
        'Me.DropShip.VxDataGridBinding()
    End Sub

    Protected Sub DropShip_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim DBITEM As DataRowView = CType(e.Row.DataItem, DataRowView)
            Dim xCompanyID As String = DBITEM.Item("company_id")
            Dim xCompanyName As String = DBITEM.Item("company_name")
            Dim xCompanyAttn As String = String.Empty
            Dim xOrg_ID As String = DBITEM.Item("org_id")
            Dim xpayment_term_code As String = DBITEM.Item("PAYMENT_TERM_CODE")
            Dim StrLink As String = ""
            StrLink = " 'javascript:vorg_id(0);' onClick=" & Chr(34) & "copopulate(" & "'" & ElementName & "','" & xCompanyID & "','" & xOrg_ID & "'" & "," & "'" & xCompanyAttn & "'" & "," & "'" & xCompanyName & "'" & "," & "'" & xpayment_term_code & "'" & ")" & Chr(34) & "," &
                      Chr(34) & xCompanyAttn & Chr(34) & ")'"
            'me.DropShip.VxUserFormat(xDataGridItem,1,"<a href='#' onClick=copopulate('" & xCompanyID & "','" & xCompanyAttn & "') >" & UCase(xCompanyID) & "</a>")
            'Me.DropShip.VxUserFormat(xDataGridItem, 1, "<a href='#' & " & StrLink & " >" & UCase(xCompanyID) & "</a>")
            e.Row.Cells(1).Text = "<a href='#' & " & StrLink & " >" & UCase(xCompanyID) & "</a>"
        End If
    End Sub

    Protected Sub BTsearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Bind()
    End Sub

    Protected Sub DropShip_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        DropShip.PageIndex = e.NewPageIndex
        Bind()
    End Sub
</script>
<script type="text/javascript" language="javascript">
    function copopulate(xElement, company, org_id, ShipToAttn, company_name, payment_term_code) {
        //xElement="company_id*org_id"
        var retValue = xElement.split("*");
        var i;
        i = 0;
        //alert(retValue.length + "||" + retValue[0] + "||" + retValue[1]);
        for (i = 0; i < retValue.length; i++) {
            //alert(payment_term_code);
            //alert("retValue" + i + ":" + retValue[i].toUpperCase());
            switch (retValue[i].toUpperCase()) {
                case "CTL00__MAIN_COMPANY_ID":
                    {
                        var obj = eval("window.opener.document.aspnetForm." + retValue[i]);
                        obj.value = company;
                        continue;
                    }
                case "ORG_ID":
                    {
                        window.opener.form1.elements("org_id").value = org_id;
                        //alert("org_id:" + org_id);
                        continue;
                    }
                case "ATTENTION":
                    {
                        window.opener.form1.elements("attention").value = ShipToAttn;
                        //alert("attention:" + ShipToAttn);
                        continue;
                    }
                case "CTL00__MAIN_COMPANY_NAME":
                    {
                        var obj = eval("window.opener.document.aspnetForm." + retValue[i]);
                        obj.value = company_name;
                        continue;
                    }
                case "CTL00__MAIN_DDLPAYMENTTERM":
                    {
                        //alert(payment_term_code);
                        var obj = eval("window.opener.document.aspnetForm." + retValue[i]);
                        //obj.value = company_name;
                        obj.value = payment_term_code;
                        continue;
                    }

                    
                default:
                    {
                        continue;
                    }
            }
        }
        //window.opener.form1.elements(xElement).value = company;
        //alert("self.close()");
        self.close()
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>B2B On-line commerce - Pick Company</title>
</head>
<body>
    <form id="form1" runat="server">
    <style>
        BODY
        {
            font-size: 8pt;
            text-indent: 4px;
            font-family: Arial;
        }
    </style>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" id="Table1">
        <tr>
            <td style="width: 100%; height: 10px" valign="top" align="center">
                <b>keywords:</b>
                <asp:TextBox ID="TBkeywords" runat="server"></asp:TextBox>
                <asp:Button ID="BTsearch" runat="server" Text="Search" OnClick="BTsearch_Click" />
            </td>
        </tr>
        <tr>
            <!-- ******* center column (start) ********-->
            <td style="width: 100%" valign="top" align="center">
                <asp:GridView ID="DropShip" runat="server" AllowPaging="True" PageSize="20" Width="100%"
                    DataSourceID="SqlDataSource1" AutoGenerateColumns="false" HeaderStyle-HorizontalAlign="Center"
                    OnRowDataBound="DropShip_RowDataBound" OnPageIndexChanging="DropShip_PageIndexChanging">
                    <Columns>
                        <asp:TemplateField HeaderText="NO." ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%# (Container.DataItemIndex+1).ToString()%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="company_id" HeaderText="Company ID" />
                        <asp:BoundField DataField="company_name" HeaderText="Company Name" />
                        <asp:BoundField DataField="Address" HeaderText="Address" />
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:MY %>">
                </asp:SqlDataSource>
            </td>
            <!-- ******* center column (end) ********-->
        </tr>
        <tr>
            <td style="width: 100%; height: 10px" valign="top" align="center">
                &nbsp;
            </td>
        </tr>
        <tr valign="middle">
            <td align="center">
                <!-- ******* page title (start) ********-->
                &nbsp;&nbsp;<span class="PageMessageBar">*HINT: Click 'Query' to input query string
                    then 'Go'. Click 'Ship Id' to apply.</span>
                <p>
                </p>
                <!-- ******* page title (end) ********-->
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
