<%@ Page Title="MyAdvantech Usage Report" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            
        End If
    End Sub

    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        Try
            sqlHasLogin.SelectCommand = GetHasLoginSQL()
            gvHasLogin.DataBind()
            sqlLoginByMonth.SelectCommand = GetLoginByMonthSQL()
            gvLoginByMonth.DataBind()
            sqlVisitHistory.SelectCommand = GetVisitHistorySQL()
            gvVisitHistory.DataBind()
            sqlOrder.SelectCommand = GetOrderSql()
            gvOrder.DataBind()
            sqlBTO.SelectCommand = GetBTOSql()
            gvBTO.DataBind()
        Catch ex As Exception
            Throw New Exception("Usage_Report.aspx error:" + ex.ToString())
        End Try
       
    End Sub
    
    Public Function GetRBU() As ArrayList
        Dim rbu As New ArrayList
        For Each item As ListItem In cblRBU.Items
            If item.Selected Then rbu.Add("'" + item.Value + "'")
        Next
        Return rbu
    End Function
    
    Public Function GetHasLoginSQL() As String
        Dim rbu As ArrayList = GetRBU()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select a.email_address, isnull(b.account_name,'') as account, b.rbu, count(c.userid) as login_times from  [aclsql6\sql2008R2].[MyAdvantechGlobal].dbo.siebel_contact a ")
            .AppendFormat(" left join [aclsql6\sql2008R2].[MyAdvantechGlobal].dbo.siebel_account b on a.account_row_id=b.row_id left join  [aclsql6\sql2008R2].[MyAdvantechGlobal].dbo.ACCESS_HISTORY_2013 c on a.email_address=c.userid ")
            .AppendFormat(" inner join SSO_MEMBER d on a.email_address=d.email_addr where d.user_status=1 ")
            If rbu.Count > 0 Then .AppendFormat(" and b.rbu in ({0}) ", String.Join(",", rbu.ToArray())) Else Return ""
            If cblUserType.Items(0).Selected And Not cblUserType.Items(1).Selected Then .AppendFormat(" and a.email_address not like '%@advantech%' ")
            If cblUserType.Items(1).Selected And Not cblUserType.Items(0).Selected Then .AppendFormat(" and a.email_address like '%@advantech%' ")
            .AppendFormat(" group by a.email_address, b.account_name, b.rbu order by a.email_address")
        End With
        Return sb.ToString
    End Function

    Protected Sub gvHasLogin_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        sqlHasLogin.SelectCommand = GetHasLoginSQL()
    End Sub

    Protected Sub gvHasLogin_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        sqlHasLogin.SelectCommand = GetHasLoginSQL()
    End Sub

    Protected Sub btnToExcelHasLogin_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("MyLocal", GetHasLoginSQL()), "Has Login.xls")
    End Sub
    
    Public Function GetLoginByMonthSQL() As String
        Dim rbu As ArrayList = GetRBU()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select distinct MONTH(a.TIMESTAMP) as month, a.USERID, b.account, b.ACCOUNT_STATUS, c.rbu ")
            .AppendFormat(" from DIM_USER_LOG a left join SIEBEL_CONTACT b on a.USERID=b.EMAIL_ADDRESS left join siebel_account c on b.account_row_id=c.row_id ")
            .AppendFormat(" where USERID != '' and year(a.TIMESTAMP)='{0}'  and b.ACCOUNT_STATUS != '' ", ddlYear.SelectedValue)
            If rbu.Count > 0 Then .AppendFormat(" and c.rbu in ({0}) ", String.Join(",", rbu.ToArray())) Else Return ""
            If cblUserType.Items(0).Selected And Not cblUserType.Items(1).Selected Then .AppendFormat(" and a.USERID not like '%@advantech%' ")
            If cblUserType.Items(1).Selected And Not cblUserType.Items(0).Selected Then .AppendFormat(" and a.USERID like '%@advantech%' ")
            .AppendFormat(" order by MONTH(a.TIMESTAMP), a.USERID")
        End With
        Return sb.ToString
    End Function

    Protected Sub gvLoginByMonth_SelectedIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewSelectEventArgs)
        sqlLoginByMonth.SelectCommand = GetLoginByMonthSQL()
    End Sub

    Protected Sub gvLoginByMonth_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        sqlLoginByMonth.SelectCommand = GetLoginByMonthSQL()
    End Sub

    Protected Sub btnToExcelLoginByMonth_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("My", GetLoginByMonthSQL()), "Login By Month.xls")
    End Sub
    
    Public Function GetVisitHistorySQL() As String
        Dim rbu As ArrayList = GetRBU()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select t.USERID, 'http://my.advantech.com'+t.URL as URL, t.TIMESTAMP, t.landing  from ")
            .AppendFormat(" ( ")
            .AppendFormat(" select distinct a.USERID, a.URL, a.TIMESTAMP, a.REFERRER, datediff(second,a.timestamp,(select top 1 z.TIMESTAMP from DIM_USER_LOG z where z.USERID=a.USERID and year(a.timestamp)+'-'+MONTH(a.timestamp)+'-'+day(a.timestamp)=year(z.timestamp)+'-'+MONTH(z.timestamp)+'-'+day(z.timestamp) and z.TIMESTAMP > a.TIMESTAMP)) as landing  ")
            .AppendFormat(" from DIM_USER_LOG a left join SIEBEL_CONTACT b on a.USERID=b.EMAIL_ADDRESS left join siebel_account c on b.account_row_id=c.row_id ")
            .AppendFormat(" where year(a.TIMESTAMP)='{0}' and USERID != '' and a.URL not like '%.asmx' ", ddlYear.SelectedValue)
            If cblUserType.Items(0).Selected And Not cblUserType.Items(1).Selected Then .AppendFormat(" and a.USERID not like '%@advantech%' ")
            If cblUserType.Items(1).Selected And Not cblUserType.Items(0).Selected Then .AppendFormat(" and a.USERID like '%@advantech%' ")
            If rbu.Count > 0 Then .AppendFormat(" and c.rbu in ({0}) ", String.Join(",", rbu.ToArray())) Else Return ""
            .AppendFormat(" ) as t where t.landing < 7200 ")
            .AppendFormat(" order by t.USERID, t.TIMESTAMP")
        End With
        Return sb.ToString
    End Function

    Protected Sub gvVisitHistory_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        sqlVisitHistory.SelectCommand = GetVisitHistorySQL()
    End Sub

    Protected Sub gvVisitHistory_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        sqlVisitHistory.SelectCommand = GetVisitHistorySQL()
    End Sub

    Protected Sub btnVisitHistory_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("My", GetVisitHistorySQL()), "Visit History.xls")
    End Sub
    
    Public Function GetOrderSql() As String
        Dim rbu As ArrayList = GetRBU()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select distinct a.order_no, c.PART_NO, (select top 1 z.ACCOUNT_NAME from SIEBEL_ACCOUNT z where z.ERP_ID=b.ERP_ID) as account_name ,a.SOLDTO_ID, b.RBU, a.ORDER_DATE, a.DUE_DATE, a.CREATED_BY, 'BTO' as Order_Type  ")
            .AppendFormat(" from order_master a left join SIEBEL_ACCOUNT b on a.SOLDTO_ID = b.ERP_ID left join ORDER_DETAIL c on a.ORDER_NO=c.ORDER_ID ")
            .AppendFormat(" where Year(a.order_date) = '{0}' and a.order_no != '' ", ddlYear.SelectedValue)
            .AppendFormat(" and c.line_no = 100 and c.part_no like '%-BTO' and a.ORDER_TYPE != 'AG' ")
            If rbu.Count > 0 Then .AppendFormat(" and b.rbu in ({0}) ", String.Join(",", rbu.ToArray())) Else Return ""
        End With
        Return sb.ToString
    End Function

    Protected Sub gvOrder_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        sqlOrder.SelectCommand = GetOrderSql()
    End Sub

    Protected Sub gvOrder_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        sqlOrder.SelectCommand = GetOrderSql()
    End Sub

    Protected Sub btnToExcelOrder_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("My", GetOrderSql()), "Order.xls")
    End Sub
    
    Public Function GetBTOSql() As String
        Dim rbu As ArrayList = GetRBU()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select distinct a.order_no, (select top 1 z.ACCOUNT_NAME from SIEBEL_ACCOUNT z where z.ERP_ID=b.ERP_ID) as account_name ,a.SOLDTO_ID, b.RBU, a.ORDER_DATE, a.DUE_DATE, a.CREATED_BY, 'Upload Order' as Order_Type ")
            .AppendFormat(" from order_master a left join SIEBEL_ACCOUNT b on a.SOLDTO_ID = b.ERP_ID ")
            .AppendFormat(" where Year(a.order_date) = '{0}' and a.order_no != '' ", ddlYear.SelectedValue)
            .AppendFormat(" and a.order_id not in (select distinct z.order_no ")
            .AppendFormat(" from order_master z left join SIEBEL_ACCOUNT b1 on z.SOLDTO_ID = b1.ERP_ID ")
            .AppendFormat(" where Year(z.order_date) = '{0}' and z.order_no != '' ", ddlYear.SelectedValue)
            .AppendFormat(" and z.order_id in (select order_id from order_detail where line_no = 100 and part_no like '%-BTO') and z.ORDER_TYPE != 'AG' ")
            If rbu.Count > 0 Then .AppendFormat(" and b1.RBU in ({0})) ", String.Join(",", rbu.ToArray())) Else Return ""
            If rbu.Count > 0 Then .AppendFormat(" and b.RBU in ({0}) and a.ORDER_TYPE != 'AG' ", String.Join(",", rbu.ToArray())) Else Return ""
        End With
        Return sb.ToString
    End Function

    Protected Sub gvBTO_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        sqlBTO.SelectCommand = GetBTOSql()
    End Sub

    Protected Sub gvBTO_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        sqlBTO.SelectCommand = GetBTOSql()
    End Sub

    Protected Sub btnToExcelBTO_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Util.DataTable2ExcelDownload(dbUtil.dbGetDataTable("My", GetBTOSql()), "BTO.xls")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table>
        <tr>
            <th>Year: </th>
            <td>
                <asp:DropDownList runat="server" ID="ddlYear">
                    <asp:ListItem Text="2011" Value="2011" />
                    <asp:ListItem Text="2010" Value="2010" />
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <th>RBU: </th>
            <td>
                <asp:CheckBoxList runat="server" ID="cblRBU" DataSourceID="sqlRBU" Width="800" RepeatColumns="8" RepeatDirection="Horizontal" DataTextField="text" DataValueField="value" />
                <asp:SqlDataSource runat="server" ID="sqlRBU" ConnectionString="<%$ connectionStrings:MY %>"
                     SelectCommand="select * from SIEBEL_ACCOUNT_RBU_LOV where text not in ('FUTURE Engineering')">
                </asp:SqlDataSource>
            </td>
        </tr>
        <tr>
            <th>User Type: </th>
            <td>
                <asp:CheckBoxList runat="server" ID="cblUserType" Width="150" RepeatDirection="Horizontal">
                    <asp:ListItem Text="Customer" Value="Customer" Selected="True" />
                    <asp:ListItem Text="Employee" Value="Employee" />
                </asp:CheckBoxList>
            </td>
        </tr>
        <tr>
            <td colspan="2"><asp:Button runat="server" ID="btnSearch" Text="Generate Report" Width="120" Height="30" OnClick="btnSearch_Click" /></td>
        </tr>
    </table>
    <br /><br />
    <ajaxToolkit:TabContainer runat="server" ID="TabContainer1">
        <ajaxToolkit:TabPanel runat="server" ID="tabHasLogin" TabIndex="0" HeaderText="Has Login">
            <ContentTemplate>
                <asp:UpdatePanel runat="server" ID="upHasLogin" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr><td><asp:ImageButton runat="server" ID="btnToExcelHasLogin" ImageUrl="~/Images/excel.gif" OnClick="btnToExcelHasLogin_Click" /></td></tr>
                            <tr>
                                <td>
                                    <asp:GridView runat="server" ID="gvHasLogin" Width="100%" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="50" DataSourceID="sqlHasLogin" OnPageIndexChanging="gvHasLogin_PageIndexChanging" OnSorting="gvHasLogin_Sorting">
                                        <Columns>
                                            <asp:BoundField DataField="email_address" HeaderText="Email" SortExpression="email_addr" />
                                            <asp:BoundField DataField="rbu" HeaderText="RBU" SortExpression="rbu" />
                                            <asp:BoundField DataField="account" HeaderText="Account" SortExpression="account" />
                                            <asp:BoundField DataField="login_times" HeaderText="# of Login Times" SortExpression="login_times" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlHasLogin" ConnectionString="<%$ connectionStrings:MYLocal %>"
                                            SelectCommand="">
                                    </asp:SqlDataSource>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                        <asp:PostBackTrigger ControlID="btnToExcelHasLogin" />
                    </Triggers>
                </asp:UpdatePanel>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabLoginByMonth" HeaderText="Login by Month">
            <ContentTemplate>
                <asp:UpdatePanel runat="server" ID="upLoginByMonth" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr><td><asp:ImageButton runat="server" ID="btnToExcelLoginByMonth" ImageUrl="~/Images/excel.gif" OnClick="btnToExcelLoginByMonth_Click" /></td></tr>
                            <tr>
                                <td>
                                    <asp:GridView runat="server" ID="gvLoginByMonth" Width="100%" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="50" DataSourceID="sqlLoginByMonth" OnSelectedIndexChanging="gvLoginByMonth_SelectedIndexChanging" OnSorting="gvLoginByMonth_Sorting">
                                        <Columns>
                                            <asp:BoundField DataField="month" HeaderText="Month" SortExpression="month" />
                                            <asp:BoundField DataField="userid" HeaderText="Email" SortExpression="userid" />
                                            <asp:BoundField DataField="account" HeaderText="Account" SortExpression="account" />
                                            <asp:BoundField DataField="account_status" HeaderText="Account Status" SortExpression="account_status" />
                                            <asp:BoundField DataField="rbu" HeaderText="RBU" SortExpression="rbu" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlLoginByMonth" ConnectionString="<%$ connectionStrings:MY %>"
                                            SelectCommand="">
                                    </asp:SqlDataSource>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                        <asp:PostBackTrigger ControlID="btnToExcelLoginByMonth" />
                    </Triggers>
                </asp:UpdatePanel>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabVisitHistory" HeaderText="Visit History">
            <ContentTemplate>
                <asp:UpdatePanel runat="server" ID="upVisitHistory" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr><td><asp:ImageButton runat="server" ID="btnToExcelVisitHistory" ImageUrl="~/Images/excel.gif" OnClick="btnVisitHistory_Click" /></td></tr>
                            <tr>
                                <td>
                                    <asp:GridView runat="server" ID="gvVisitHistory" Width="100%" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="50" DataSourceID="sqlVisitHistory" OnPageIndexChanging="gvVisitHistory_PageIndexChanging" OnSorting="gvVisitHistory_Sorting">
                                        <Columns>
                                            <asp:BoundField DataField="userid" HeaderText="Email" SortExpression="userid" />
                                            <asp:BoundField DataField="url" HeaderText="URL" SortExpression="url" />
                                            <asp:BoundField DataField="timestamp" HeaderText="Visit Time" SortExpression="timestamp" />
                                            <asp:BoundField DataField="landing" HeaderText="Landing Time" SortExpression="landing" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlVisitHistory" ConnectionString="<%$ connectionStrings:MY %>"
                                            SelectCommand="">
                                    </asp:SqlDataSource>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                        <asp:PostBackTrigger ControlID="btnToExcelVisitHistory" />
                    </Triggers>
                </asp:UpdatePanel>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabOrder" HeaderText="# of Orders">
            <ContentTemplate>
                <asp:UpdatePanel runat="server" ID="upOrder" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr><td><asp:ImageButton runat="server" ID="btnToExcelOrder" ImageUrl="~/Images/excel.gif" OnClick="btnToExcelOrder_Click" /></td></tr>
                            <tr>
                                <td>
                                    <asp:GridView runat="server" ID="gvOrder" Width="100%" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="50" DataSourceID="sqlOrder" OnPageIndexChanging="gvOrder_PageIndexChanging" OnSorting="gvOrder_Sorting">
                                        <Columns>
                                            <asp:BoundField DataField="order_no" HeaderText="Order NO" SortExpression="order_no" />
                                            <asp:BoundField DataField="part_no" HeaderText="Part NO" SortExpression="part_no" />
                                            <asp:BoundField DataField="account_name" HeaderText="Account" SortExpression="account_name" />
                                            <asp:BoundField DataField="SOLDTO_ID" HeaderText="SoldTo ID" SortExpression="SOLDTO_ID" />
                                            <asp:BoundField DataField="rbu" HeaderText="RBU" SortExpression="rbu" />
                                            <asp:BoundField DataField="ORDER_DATE" HeaderText="Order Date" SortExpression="ORDER_DATE" />
                                            <asp:BoundField DataField="DUE_DATE" HeaderText="Due Date" SortExpression="DUS_DATE" />
                                            <asp:BoundField DataField="CREATED_BY" HeaderText="Created By" SortExpression="CREATED_BY" />
                                            <asp:BoundField DataField="Order_Type" HeaderText="Order Type" SortExpression="Order_Type" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlOrder" ConnectionString="<%$ connectionStrings:MY %>"
                                            SelectCommand="">
                                    </asp:SqlDataSource>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                        <asp:PostBackTrigger ControlID="btnToExcelOrder" />
                    </Triggers>
                </asp:UpdatePanel>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
        <ajaxToolkit:TabPanel runat="server" ID="tabBTO" HeaderText="# of BTO">
            <ContentTemplate>
                <asp:UpdatePanel runat="server" ID="upBTO" UpdateMode="Conditional">
                    <ContentTemplate>
                        <table width="100%">
                            <tr><td><asp:ImageButton runat="server" ID="btnToExcelBTO" ImageUrl="~/Images/excel.gif" OnClick="btnToExcelBTO_Click" /></td></tr>
                            <tr>
                                <td>
                                    <asp:GridView runat="server" ID="gvBTO" Width="100%" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="50" DataSourceID="sqlBTO" OnPageIndexChanging="gvBTO_PageIndexChanging" OnSorting="gvBTO_Sorting">
                                        <Columns>
                                            <asp:BoundField DataField="order_no" HeaderText="Order NO" SortExpression="order_no" />
                                            <asp:BoundField DataField="account_name" HeaderText="Account" SortExpression="account_name" />
                                            <asp:BoundField DataField="SOLDTO_ID" HeaderText="SOLDTO ID" SortExpression="SOLDTO_ID" />
                                            <asp:BoundField DataField="rbu" HeaderText="RBU" SortExpression="rbu" />
                                            <asp:BoundField DataField="ORDER_DATE" HeaderText="Order Date" SortExpression="ORDER_DATE" />
                                            <asp:BoundField DataField="DUE_DATE" HeaderText="Due Date" SortExpression="DUS_DATE" />
                                            <asp:BoundField DataField="CREATED_BY" HeaderText="Created By" SortExpression="CREATED_BY" />
                                            <asp:BoundField DataField="Order_Type" HeaderText="Order Type" SortExpression="Order_Type" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlBTO" ConnectionString="<%$ connectionStrings:MY %>"
                                            SelectCommand="">
                                    </asp:SqlDataSource>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                        <asp:PostBackTrigger ControlID="btnToExcelBTO" />
                    </Triggers>
                </asp:UpdatePanel>
            </ContentTemplate>
        </ajaxToolkit:TabPanel>
    </ajaxToolkit:TabContainer>
</asp:Content>

