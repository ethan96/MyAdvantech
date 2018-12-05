<%@ Page Title="MyAdvantech - Project Registration List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Public ReadOnly Property CanSeeProject As Boolean
        Get
            If Not String.IsNullOrEmpty(Session("company_id")) Then
                Dim sql As StringBuilder = New StringBuilder()
                sql.Append(" SELECT COUNT(*)  FROM SIEBEL_CONTACT_PRIVILEGE p INNER JOIN SIEBEL_CONTACT c ON p.ROW_ID = c.ROW_ID ")
                sql.Append(" INNER JOIN SIEBEL_ACCOUNT a ON c.ACCOUNT_ROW_ID = a.ROW_ID ")
                sql.AppendFormat(" WHERE p.EMAIL_ADDRESS = '{0}' AND PRIVILEGE = 'Can See Project' AND a.ERP_ID = '{1}' ", Session("user_id").ToString, Session("company_id").ToString)
                Dim count As Object = dbUtil.dbExecuteScalar("MY", sql.ToString)
                If count IsNot Nothing AndAlso Not String.IsNullOrEmpty(count.ToString) Then
                    Dim c As Integer = 0
                    Integer.TryParse(count.ToString, c)
                    If c > 0 Then Return True
                End If
            End If
            Return False
        End Get
    End Property

    Dim dataSource As InterConPrjReg.MY_PRJ_REG_MASTERDataTable = Nothing
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then

            If Session("user_id") Is Nothing OrElse Session("user_id").ToString() = "" Then
                Response.Redirect("~/home.aspx?ReturnUrl=" + Request.ServerVariables("URL"))
                Response.End()
            End If

            'JJ 2014/4/3 如果是InterCon.ALL這個Group的人員在home_ez上是隱藏的，所以如果直接用URL連結就導回首頁
            'ICC 2016/3/4 Remove this code for Stefanie to test
            'If MailUtil.IsInMailGroup("InterCon.ALL", Session("user_id")) Then
            '    Response.Redirect("~/home.aspx")
            '    Response.End()
            'End If

            BindGV()
        End If
    End Sub

    Protected Sub gvProjects_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If ViewState("SiebelDT") IsNot Nothing Then
                Dim dt As DataTable = CType(ViewState("SiebelDT"), DataTable)
                Dim drs() As DataRow = dt.Select("ROW_ID = '" + gvProjects.DataKeys(e.Row.RowIndex).Values(1) + "'")
                If drs.Length = 1 Then
                    e.Row.Cells(3).Text = drs(0).Item("NAME")
                    Dim dtdrv As System.Data.DataRowView = CType(e.Row.DataItem, System.Data.DataRowView)
                    Dim Curr As String = ""
                    If Not IsDBNull(dtdrv.DataView(e.Row.RowIndex)("PRJ_AMT_CURR")) Then
                        Curr = dtdrv.DataView(e.Row.RowIndex)("PRJ_AMT_CURR").ToString.Trim
                    End If
                    e.Row.Cells(4).Text = InterConPrjRegUtil.GetCurrencySign(Curr) + String.Format("{0:0.00}", drs(0).Item("AMT"))
                    If Date.TryParse(drs(0).Item("SUM_EFFECTIVE_DT"), Now) Then
                        e.Row.Cells(5).Text = CDate(drs(0).Item("SUM_EFFECTIVE_DT")).ToString("yyyy-MM-dd")
                    End If
                End If
            End If

            If Request("rowid") IsNot Nothing AndAlso Request("rowid").Trim = gvProjects.DataKeys(e.Row.RowIndex).Values(0) Then
                e.Row.Cells(0).BackColor = Drawing.Color.Yellow
            End If


            Dim drv As DataRowView = CType(e.Row.DataItem, DataRowView)
            If Not drv Is Nothing Then
                If Not IsDBNull(drv.DataView(e.Row.RowIndex)("CP_COMPANY_ID")) Then e.Row.Cells(6).Text = dbUtil.dbExecuteScalar("MY", String.Format("Select top 1 isnull(ACCOUNT_NAME,'') as name from SIEBEL_ACCOUNT where ERP_ID = '{0}' order by account_Status ", drv.DataView(e.Row.RowIndex)("CP_COMPANY_ID").ToString))
                Dim creator As String = "CREATED_BY"
                If Not IsDBNull(drv.DataView(e.Row.RowIndex)("CREATED_BY")) Then creator = drv.DataView(e.Row.RowIndex)("CREATED_BY").ToString
                e.Row.Attributes.Add("data-createdby", creator)

                Dim ddlRegistedBy As DropDownList = CType(gvProjects.HeaderRow.Cells(1).FindControl("ddlRegistedBy"), DropDownList)
                If Not ddlRegistedBy Is Nothing Then
                    Dim myItem As ListItem = New ListItem(creator, creator)
                    myItem.Attributes.Add("data", "data-createdby")
                    If Not ddlRegistedBy.Items.Contains(myItem) Then
                        Dim items As List(Of ListItem) = New List(Of ListItem)()
                        items.Add(myItem)
                        For Each item As ListItem In ddlRegistedBy.Items
                            items.Add(item)
                        Next
                        Dim sort As List(Of ListItem) = items.OrderBy(Function(i) i.Text).ToList()
                        ddlRegistedBy.Items.Clear()
                        ddlRegistedBy.Items.AddRange(sort.ToArray)
                    End If
                End If

                Dim optyStage As String = "OPTY_STAGE"
                If Not String.IsNullOrEmpty(e.Row.Cells(3).Text) AndAlso Not String.Equals("&nbsp;", e.Row.Cells(3).Text, StringComparison.OrdinalIgnoreCase) Then optyStage = e.Row.Cells(3).Text
                e.Row.Attributes.Add("data-stage", optyStage)
                Dim ddlOptyStage As DropDownList = CType(gvProjects.HeaderRow.Cells(3).FindControl("ddlOptyStage"), DropDownList)
                If Not ddlOptyStage Is Nothing Then
                    Dim myItem As ListItem = New ListItem(optyStage, optyStage)
                    myItem.Attributes.Add("data", "data-stage")
                    If Not ddlOptyStage.Items.Contains(myItem) Then
                        Dim items As List(Of ListItem) = New List(Of ListItem)()
                        items.Add(myItem)
                        For Each item As ListItem In ddlOptyStage.Items
                            items.Add(item)
                        Next
                        Dim sort As List(Of ListItem) = items.OrderBy(Function(i) i.Text).ToList()
                        ddlOptyStage.Items.Clear()
                        ddlOptyStage.Items.AddRange(sort.ToArray)
                    End If
                End If

                Dim companyName As String = "COMPANY_NAME"
                If Not String.IsNullOrEmpty(e.Row.Cells(6).Text.Trim) Then companyName = e.Row.Cells(6).Text.Trim
                e.Row.Attributes.Add("data-cpname", companyName)
                Dim ddlCompanyID As DropDownList = CType(gvProjects.HeaderRow.Cells(6).FindControl("ddlCompanyID"), DropDownList)
                If Not ddlCompanyID Is Nothing Then
                    Dim myItem As ListItem = New ListItem(companyName, companyName)
                    myItem.Attributes.Add("data", "data-cpname")
                    If Not ddlCompanyID.Items.Contains(myItem) Then
                        Dim items As List(Of ListItem) = New List(Of ListItem)()
                        items.Add(myItem)
                        For Each item As ListItem In ddlCompanyID.Items
                            items.Add(item)
                        Next
                        Dim sort As List(Of ListItem) = items.OrderBy(Function(i) i.Text).ToList()
                        ddlCompanyID.Items.Clear()
                        ddlCompanyID.Items.AddRange(sort.ToArray)
                    End If
                End If

                Dim custCountry As String = "ENDCUST_COUNTRY"
                If Not IsDBNull(drv.DataView(e.Row.RowIndex)("ENDCUST_COUNTRY")) Then custCountry = drv.DataView(e.Row.RowIndex)("ENDCUST_COUNTRY").ToString
                e.Row.Attributes.Add("data-endcountry", custCountry)
                Dim ddlCustCountry As DropDownList = CType(gvProjects.HeaderRow.Cells(8).FindControl("ddlCustCountry"), DropDownList)
                If Not ddlCustCountry Is Nothing Then
                    Dim myItem As ListItem = New ListItem(custCountry, custCountry)
                    myItem.Attributes.Add("data", "data-endcountry")
                    If Not ddlCustCountry.Items.Contains(myItem) Then
                        Dim items As List(Of ListItem) = New List(Of ListItem)()
                        items.Add(myItem)
                        For Each item As ListItem In ddlCustCountry.Items
                            items.Add(item)
                        Next
                        Dim sort As List(Of ListItem) = items.OrderBy(Function(i) i.Text).ToList()
                        ddlCustCountry.Items.Clear()
                        ddlCustCountry.Items.AddRange(sort.ToArray)
                    End If
                End If

                e.Row.Attributes.Add("class", "MyDiv")
            End If

        End If

        'If e.Row.RowType = DataControlRowType.Header Then
        '    Dim prj As InterConPrjReg.MY_PRJ_REG_MASTERDataTable = dataSource
        '    Dim ddlRegistedBy As DropDownList = CType(e.Row.FindControl("ddlRegistedBy"), DropDownList)
        '    Dim ddlOptyStage As DropDownList = CType(e.Row.FindControl("ddlOptyStage"), DropDownList)
        '    Dim ddlCompanyID As DropDownList = CType(e.Row.FindControl("ddlCompanyID"), DropDownList)
        '    Dim ddlCustCountry As DropDownList = CType(e.Row.FindControl("ddlCustCountry"), DropDownList)
        '    If prj IsNot Nothing Then

        '        If Not ddlRegistedBy Is Nothing Then
        '            Dim table As DataTable = prj.DefaultView.ToTable(True, "CREATED_BY")
        '            Dim dvDataSource As New DataView(table)
        '            dvDataSource.Sort = "CREATED_BY"
        '            ddlRegistedBy.DataSource = dvDataSource
        '            ddlRegistedBy.DataTextField = "CREATED_BY"
        '            ddlRegistedBy.DataValueField = "CREATED_BY"
        '            ddlRegistedBy.DataBind()
        '            ddlRegistedBy.Items.Insert(0, New ListItem(String.Empty, "CREATED_BY"))
        '        End If

        '    End If
        'End If
    End Sub
    Private Sub BindGV(Optional ByVal download As Boolean = False)
        Dim Prj_M_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter
        Dim Prj_M_DT As New InterConPrjReg.MY_PRJ_REG_MASTERDataTable
        'ICC 2016/11/17 Reset authority
        'For MyAdvantech & CM team can see all proejcts.
        'For internal users only can see current ERP ID projects.
        'For some customers can see cross ERP ID proejcts.
        'For normal customers only can see projects created by themself.
        If MailUtil.IsInRole("MyAdvantech") OrElse MailUtil.IsInRole("ChannelManagement.ACL") OrElse MailUtil.IsInRole("DMKT.ACL") Then
            Prj_M_DT = Prj_M_A.GetData()
        ElseIf Util.IsInternalUser2() AndAlso Not String.IsNullOrEmpty(Session("company_id")) Then
            Prj_M_DT = Prj_M_A.GetDataByERPID(Session("company_id").ToString)
        ElseIf Not String.IsNullOrEmpty(Session("company_id")) AndAlso Session("company_id").ToString().Equals("EIITME22", StringComparison.OrdinalIgnoreCase) Then 'ICC 2016/8/15 For some CPs, they can see others projects in same ERP ID.
            Prj_M_DT = Prj_M_A.GetDataByERPID(Session("company_id").ToString)
        ElseIf CanSeeProject = True Then
            Prj_M_DT = Prj_M_A.GetDataByERPID(Session("company_id").ToString)
        Else
            Prj_M_DT = Prj_M_A.GetByCreator(User.Identity.Name)
        End If
        If dlEndCustCountry.SelectedIndex > 0 Then
            For Each DR As DataRow In Prj_M_DT.Rows
                If Not IsDBNull(DR.Item("ENDCUST_COUNTRY")) AndAlso DR.Item("ENDCUST_COUNTRY").ToString.Trim = dlEndCustCountry.SelectedValue Then

                Else
                    DR.Delete()
                End If
            Next
            Prj_M_DT.AcceptChanges()
        End If
        Dim prj_opty_ids As String = ""
        For i As Integer = 0 To Prj_M_DT.Rows.Count - 1
            If Not IsDBNull(Prj_M_DT.Rows(i).Item("prj_opty_id")) AndAlso Not String.IsNullOrEmpty(Prj_M_DT.Rows(i).Item("prj_opty_id")) Then
                prj_opty_ids += "," + Prj_M_DT.Rows(i).Item("prj_opty_id").ToString.Trim
            End If
        Next
        Dim tempDT As DataTable = dbUtil.dbGetDataTable("MYLOCAL", "SELECT PRJ_ROW_ID FROM [MY_PRJ_REG_AUDIT] where [STATUS] = -1")
        Dim tempID As New List(Of String)
        For Each dr As DataRow In tempDT.Rows
            tempID.Add(dr(0).ToString)
        Next
        For i = Prj_M_DT.Rows.Count - 1 To 0 Step -1
            Dim dr As InterConPrjReg.MY_PRJ_REG_MASTERRow = Prj_M_DT.Rows(i)
            If tempID.Contains(dr.ROW_ID) Then
                dr.Delete()
                dr.AcceptChanges()
            End If
        Next
        GetStageDTbyOptyIDs(prj_opty_ids)
        If download = False Then
            gvProjects.DataSource = Prj_M_DT
            gvProjects.DataBind()
        Else
            Me.dataSource = Prj_M_DT
        End If

    End Sub
    Protected Sub dlEndCustCountry_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        BindGV()
    End Sub

    Public Function GetStageDTbyOptyIDs(ByVal rowids As String) As DataTable
        If ViewState("SiebelDT") IsNot Nothing Then Return CType(ViewState("SiebelDT"), DataTable)
        If rowids.Trim() = "" Then Return New DataTable("ACCOUNTADDR")
        Dim P() As String = Split(rowids, ",") : Dim wherestr As String = ""
        For i As Integer = 0 To P.Length - 1
            If Not String.IsNullOrEmpty(P(i).ToString.Trim) Then
                If i = P.Length - 1 Then
                    wherestr = wherestr + "'" + P(i).ToString.Trim.Replace("'", "") + "'"
                Else
                    wherestr = wherestr + "'" + P(i).ToString.Trim.Replace("'", "") + "',"
                End If
            End If
        Next
        Dim sql As New StringBuilder
        sql.AppendLine(" select  b.ROW_ID, b.SUM_EFFECTIVE_DT,isnull(b.SUM_MARGIN_AMT,0) as AMT ,a.NAME from S_STG as a inner join S_OPTY as b on a.ROW_ID = b. CURR_STG_ID ")
        sql.AppendFormat("  where b.ROW_ID in ({0})", wherestr)
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMAPPDB", sql.ToString())
        If dt.Rows.Count > 0 Then
            ViewState("SiebelDT") = dt
            'Return dt
        End If
        Return Nothing
    End Function
    Dim Prj_P_A As New InterConPrjRegTableAdapters.MY_PRJ_REG_PRODUCTSTableAdapter
    Protected Function GetData(ByVal obj As Object) As DataTable
        If obj IsNot Nothing AndAlso Trim(obj.ToString) <> String.Empty Then
            Return Prj_P_A.GetDataByPRJ_ROW_ID(obj.ToString)
        End If
        Return New DataTable
    End Function

    Protected Sub btnDownload_Click(sender As Object, e As EventArgs)
        Dim ddl As DropDownList = CType(gvProjects.HeaderRow.FindControl("ddlRegistedBy"), DropDownList)
        BindGV(True)
        If Not Me.dataSource Is Nothing AndAlso Me.dataSource.Rows.Count > 0 Then
            Dim dtDownload As New DataTable()
            dtDownload.Columns.Add("Project Name", GetType(String))
            dtDownload.Columns.Add("Requested By", GetType(String))
            dtDownload.Columns.Add("Requested on", GetType(String))
            dtDownload.Columns.Add("Stage", GetType(String))
            dtDownload.Columns.Add("Amount", GetType(String))
            dtDownload.Columns.Add("Close Date", GetType(String))
            dtDownload.Columns.Add("CP's name", GetType(String))
            dtDownload.Columns.Add("End customer's name", GetType(String))
            dtDownload.Columns.Add("End customer's country", GetType(String))
            dtDownload.Columns.Add("Opportunity ID", GetType(String))
            dtDownload.Columns.Add("Product(s)", GetType(String))

            For Each row As InterConPrjReg.MY_PRJ_REG_MASTERRow In Me.dataSource.Rows
                Dim dtRow As DataRow = dtDownload.NewRow()
                dtRow("Project Name") = row.PRJ_NAME
                dtRow("Requested By") = row.CREATED_BY
                dtRow("Requested on") = row.CREATED_DATE.ToString("yyyy-MM-dd")
                dtRow("End customer's name") = row.ENDCUST_NAME
                dtRow("End customer's country") = row.ENDCUST_COUNTRY
                dtRow("Opportunity ID") = row.PRJ_OPTY_ID
                Dim dtProduct As InterConPrjReg.MY_PRJ_REG_PRODUCTSDataTable = Me.GetData(row.ROW_ID)
                If Not dtProduct Is Nothing AndAlso dtProduct.Rows.Count > 0 Then
                    Dim sb As New StringBuilder()
                    For Each drProduct As InterConPrjReg.MY_PRJ_REG_PRODUCTSRow In dtProduct.Rows
                        sb.AppendFormat("Product: {0}  Qty: {1}, ", drProduct.PART_NO, drProduct.QTY)
                    Next
                    dtRow("Product(s)") = sb.ToString
                End If
                If ViewState("SiebelDT") IsNot Nothing Then
                    Dim dt As DataTable = CType(ViewState("SiebelDT"), DataTable)
                    Dim drs() As DataRow = dt.Select("ROW_ID = '" + row.PRJ_OPTY_ID + "'")
                    If drs.Length = 1 Then
                        dtRow("Stage") = drs(0).Item("NAME")
                        If Not String.IsNullOrEmpty(row.PRJ_AMT_CURR) Then
                            dtRow("Amount") = InterConPrjRegUtil.GetCurrencySign(row.PRJ_AMT_CURR) + String.Format("{0:0.00}", drs(0).Item("AMT"))
                        End If
                        If Date.TryParse(drs(0).Item("SUM_EFFECTIVE_DT"), Now) Then
                            dtRow("Close Date") = CDate(drs(0).Item("SUM_EFFECTIVE_DT")).ToString("yyyy-MM-dd")
                        End If
                    End If
                End If
                dtRow("CP's name") = dbUtil.dbExecuteScalar("MY", "Select top 1 isnull(ACCOUNT_NAME,'') as name from SIEBEL_ACCOUNT where ERP_ID='" + row.CP_COMPANY_ID + "' order by account_Status ")
                dtDownload.Rows.Add(dtRow)
            Next
            Util.DataTable2ExcelDownload(dtDownload, String.Format("MyProjectList-{0}.xls", DateTime.Now.ToString("yyyyMMdd")))
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script src="../../Includes/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="../../Includes/PrintArea.js" type="text/javascript"></script>
    <script language="javascript" type="text/javascript">
        $(document).ready(function () {
            $("div#print_button").click(function () {
                $("#myPrintArea").printArea();
            });

            $(".MyDropDownList").on("change", function () {
                var createdby = "";
                var stage = "";
                var cp = "";
                var country = "";
                $(".MyDropDownList").find(":selected").each(function () {
                    var dom = $(this);
                    switch (dom.attr("data")) {
                        case ("data-createdby"):
                            createdby = dom.text();
                            break;
                        case ("data-stage"):
                            stage = dom.text();
                            break;
                        case ("data-cpname"):
                            cp = dom.text();
                            break;
                        case ("data-endcountry"):
                            country = dom.text();
                            break;
                    }
                });

                $(".MyDiv").each(function () {
                    var dom = $(this);
                    dom.show();
                    if (createdby != "" && dom.attr("data-createdby") != createdby)
                        dom.hide();
                    if (stage != "" && dom.attr("data-stage") != stage)
                        dom.hide();
                    if (cp != "" && dom.attr("data-cpname") != cp)
                        dom.hide();
                    if (country != "" && dom.attr("data-endcountry") != country)
                        dom.hide();
                });

            });
        }); 
    </script>
    <table width="100%">
        <tr>
            <td style="font-size: larger" align="left">
                <table width="100%">
                    <tr>
                        <td>
                            <a href="./PrjReg.aspx">[ Project Registration ]</a>
                        </td>
                        <td align="right">
                            <div style="display:inline">
                                <asp:Button ID="btnDownload" runat="server" Text="Download excel" OnClick="btnDownload_Click" />
                            </div>
                            <div id="print_button" style="cursor: pointer; display:inline">
                                <img src="../../Images/print.gif" alt="Print" width="40" height="40" />
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:DropDownList runat="server" ID="dlEndCustCountry" OnSelectedIndexChanged="dlEndCustCountry_SelectedIndexChanged"
                    AutoPostBack="True">
                    <asp:ListItem Value="All Countries" />
                    <asp:ListItem Value="Albania" />
                    <asp:ListItem Value="Algeria" />
                    <asp:ListItem Value="Amer.Virgin Is." />
                    <asp:ListItem Value="Angola" />
                    <asp:ListItem Value="Argentina" />
                    <asp:ListItem Value="Armenia" />
                    <asp:ListItem Value="Australia" />
                    <asp:ListItem Value="Austria" />
                    <asp:ListItem Value="Azerbaijan" />
                    <asp:ListItem Value="Bahamas" />
                    <asp:ListItem Value="Bahrain" />
                    <asp:ListItem Value="Bangladesh" />
                    <asp:ListItem Value="Belarus" />
                    <asp:ListItem Value="Belgium" />
                    <asp:ListItem Value="Belize" />
                    <asp:ListItem Value="Bermuda" />
                    <asp:ListItem Value="Bolivia" />
                    <asp:ListItem Value="Bosnia-Herz." />
                    <asp:ListItem Value="Brazil" />
                    <asp:ListItem Value="Brit.Virgin Is." />
                    <asp:ListItem Value="Brunei Daruss." />
                    <asp:ListItem Value="Bulgaria" />
                    <asp:ListItem Value="Burkina-Faso" />
                    <asp:ListItem Value="Cambodia" />
                    <asp:ListItem Value="Canada" />
                    <asp:ListItem Value="Cayman Islands" />
                    <asp:ListItem Value="Chile" />
                    <asp:ListItem Value="China" />
                    <asp:ListItem Value="Colombia" />
                    <asp:ListItem Value="Costa Rica" />
                    <asp:ListItem Value="Croatia" />
                    <asp:ListItem Value="Cyprus" />
                    <asp:ListItem Value="Czech Republic" />
                    <asp:ListItem Value="Denmark" />
                    <asp:ListItem Value="Dominica" />
                    <asp:ListItem Value="Dominican Rep." />
                    <asp:ListItem Value="Dutch Antilles" />
                    <asp:ListItem Value="Ecuador" />
                    <asp:ListItem Value="Egypt" />
                    <asp:ListItem Value="El Salvador" />
                    <asp:ListItem Value="Estonia" />
                    <asp:ListItem Value="Falkland Islnds" />
                    <asp:ListItem Value="Fiji" />
                    <asp:ListItem Value="Finland" />
                    <asp:ListItem Value="France" />
                    <asp:ListItem Value="French S.Territ" />
                    <asp:ListItem Value="Georgia" />
                    <asp:ListItem Value="Germany" />
                    <asp:ListItem Value="Greece" />
                    <asp:ListItem Value="Greenland" />
                    <asp:ListItem Value="Grenada" />
                    <asp:ListItem Value="Guatemala" />
                    <asp:ListItem Value="Honduras" />
                    <asp:ListItem Value="Hong Kong" />
                    <asp:ListItem Value="Hungary" />
                    <asp:ListItem Value="Iceland" />
                    <asp:ListItem Value="India" />
                    <asp:ListItem Value="Indonesia" />
                    <asp:ListItem Value="Iran" />
                    <asp:ListItem Value="Iraq" />
                    <asp:ListItem Value="Ireland" />
                    <asp:ListItem Value="Israel" />
                    <asp:ListItem Value="Italy" />
                    <asp:ListItem Value="Jamaica" />
                    <asp:ListItem Value="Japan" />
                    <asp:ListItem Value="Jordan" />
                    <asp:ListItem Value="Kazakhstan" />
                    <asp:ListItem Value="Kenya" />
                    <asp:ListItem Value="Kuwait" />
                    <asp:ListItem Value="Kyrgyzstan" />
                    <asp:ListItem Value="Laos" />
                    <asp:ListItem Value="Latvia" />
                    <asp:ListItem Value="Lebanon" />
                    <asp:ListItem Value="Libya" />
                    <asp:ListItem Value="Liechtenstein" />
                    <asp:ListItem Value="Lithuania" />
                    <asp:ListItem Value="Luxembourg" />
                    <asp:ListItem Value="Macau" />
                    <asp:ListItem Value="Macedonia" />
                    <asp:ListItem Value="Madagascar" />
                    <asp:ListItem Value="Malawi" />
                    <asp:ListItem Value="Malaysia" />
                    <asp:ListItem Value="Maldives" />
                    <asp:ListItem Value="Malta" />
                    <asp:ListItem Value="Mauritania" />
                    <asp:ListItem Value="Mauritius" />
                    <asp:ListItem Value="Mexico" />
                    <asp:ListItem Value="Moldova" />
                    <asp:ListItem Value="Monaco" />
                    <asp:ListItem Value="Mongolia" />
                    <asp:ListItem Value="Morocco" />
                    <asp:ListItem Value="Nepal" />
                    <asp:ListItem Value="Netherlands" />
                    <asp:ListItem Value="New Caledonia" />
                    <asp:ListItem Value="New Zealand" />
                    <asp:ListItem Value="Nicaragua" />
                    <asp:ListItem Value="Niger" />
                    <asp:ListItem Value="Nigeria" />
                    <asp:ListItem Value="Norway" />
                    <asp:ListItem Value="Oman" />
                    <asp:ListItem Value="Pakistan" />
                    <asp:ListItem Value="Panama" />
                    <asp:ListItem Value="Paraguay" />
                    <asp:ListItem Value="Peru" />
                    <asp:ListItem Value="Philippines" />
                    <asp:ListItem Value="Poland" />
                    <asp:ListItem Value="Portugal" />
                    <asp:ListItem Value="Puerto Rico" />
                    <asp:ListItem Value="Qatar" />
                    <asp:ListItem Value="Romania" />
                    <asp:ListItem Value="Russia" />
                    <asp:ListItem Value="Saudi Arabia" />
                    <asp:ListItem Value="Serbia" />
                    <asp:ListItem Value="Sierra Leone" />
                    <asp:ListItem Value="Singapore" />
                    <asp:ListItem Value="Slovakia" />
                    <asp:ListItem Value="Slovenia" />
                    <asp:ListItem Value="Solomon Islands" />
                    <asp:ListItem Value="South Africa" />
                    <asp:ListItem Value="South Korea" />
                    <asp:ListItem Value="Spain" />
                    <asp:ListItem Value="Sri Lanka" />
                    <asp:ListItem Value="St. Martin" />
                    <asp:ListItem Value="Swaziland" />
                    <asp:ListItem Value="Sweden" />
                    <asp:ListItem Value="Switzerland" />
                    <asp:ListItem Value="Syria" />
                    <asp:ListItem Value="Taiwan" />
                    <asp:ListItem Value="Tajikistan" />
                    <asp:ListItem Value="Thailand" />
                    <asp:ListItem Value="Trinidad,Tobago" />
                    <asp:ListItem Value="Tunisia" />
                    <asp:ListItem Value="Turkey" />
                    <asp:ListItem Value="Uganda" />
                    <asp:ListItem Value="Ukraine" />
                    <asp:ListItem Value="United Kingdom" />
                    <asp:ListItem Value="Uruguay" />
                    <asp:ListItem Value="USA" />
                    <asp:ListItem Value="Utd.Arab Emir." />
                    <asp:ListItem Value="Uzbekistan" />
                    <asp:ListItem Value="Venezuela" />
                    <asp:ListItem Value="Vietnam" />
                    <asp:ListItem Value="Yugoslavia" />
                    <asp:ListItem Value="Zambia" />
                    <asp:ListItem Value="Zimbabwe" />
                </asp:DropDownList>
            </td>
        </tr>
        <tr>
            <td>
                <div id="myPrintArea">
                    <asp:GridView runat="server" ID="gvProjects" Width="100%" AutoGenerateColumns="false"
                        OnRowDataBound="gvProjects_RowDataBound" DataKeyNames="row_id,prj_opty_id">
                        <Columns>
                            <asp:TemplateField HeaderText="Project Name">
                                <ItemTemplate>
                                    <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl='<%# Eval("ROW_ID", "PrjDetail.aspx?ROW_ID={0}") %>'>
                                    <%# Eval("PRJ_NAME")%>
                                    </asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField SortExpression="CREATED_BY">
                                <HeaderTemplate>
                                    Registered By<br />
                                    <asp:DropDownList ID="ddlRegistedBy" runat="server" CssClass="MyDropDownList">
                                        <asp:ListItem Text="" Value="" Selected="True" data="data-createdby"></asp:ListItem>
                                    </asp:DropDownList>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("CREATED_BY")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Registered on" DataField="CREATED_DATE" SortExpression="CREATED_DATE"
                                DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    Stage
                                    <asp:DropDownList ID="ddlOptyStage" runat="server" CssClass="MyDropDownList">
                                        <asp:ListItem Text="" Value="" Selected="True" data="data-stage"></asp:ListItem>
                                    </asp:DropDownList>
                                </HeaderTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Amount" ItemStyle-HorizontalAlign="Right" ItemStyle-CssClass="Tnowrap">
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Close Date"></asp:TemplateField>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    CP's Name
                                    <asp:DropDownList ID="ddlCompanyID" runat="server" CssClass="MyDropDownList">
                                        <asp:ListItem Text="" Value="" Selected="True" data="data-cpname"></asp:ListItem>
                                    </asp:DropDownList>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("CP_COMPANY_ID")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="End Customer's Name" DataField="ENDCUST_NAME" SortExpression="ENDCUST_NAME" />
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    End Customer's Country
                                    <asp:DropDownList ID="ddlCustCountry" runat="server" CssClass="MyDropDownList">
                                        <asp:ListItem Text="" Value="" Selected="True" data="data-endcountry"></asp:ListItem>
                                    </asp:DropDownList>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("ENDCUST_COUNTRY")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Opportunity ID" DataField="prj_opty_id" SortExpression="prj_opty_id" />
                            <asp:TemplateField HeaderText="Product(s)">
                                <ItemTemplate>
                                    <asp:GridView runat="server" Width="150" ID="gvpartno" DataSource='<%# GetData(Eval("row_id")) %>'
                                        AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:BoundField HeaderText="Product Items" DataField="Part_no" ItemStyle-HorizontalAlign="Left" />
                                            <asp:BoundField HeaderText="Qty" DataField="Qty" ItemStyle-HorizontalAlign="Center" />
                                        </Columns>
                                    </asp:GridView>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </td>
        </tr>
    </table>
</asp:Content>
