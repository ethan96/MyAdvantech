<%@ Control Language="VB" ClassName="MySalesOpty" %>

<script runat="server">
    Function GetSql() As String
        If Session("account_status") Is Nothing OrElse Session("account_status").ToString() <> "EZ" Then
            Return ""
        End If
        Dim uid As String = LCase(HttpContext.Current.Session("user_id"))
        Dim cfrom As Date = DateAdd(DateInterval.Month, -3, Now)
        Dim cto As Date = Now
        If uid.Contains("@") Then uid = Split(uid, "@")(0).Trim()
        If Util.IsAdmin() Then uid = "axel.kaiser"
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top 100 "))
            .AppendLine(String.Format(" A.ROW_ID, A.CREATED, A.LAST_UPD, A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, A.NAME, "))
            .AppendLine(String.Format(" A.CURCY_CD as currency, A.CURR_STG_ID, cast(A.SUM_WIN_PROB as int) as SUM_WIN_PROB, "))
            .AppendLine(String.Format(" cast(A.SUM_REVN_AMT as numeric(18,0)) as SUM_REVN_AMT, IsNull(X.ATTRIB_06,'') as BusinessGroup, "))
            .AppendLine(String.Format(" case when isnull(A.SUM_WIN_PROB,0)= 0 then A.SUM_REVN_AMT*(A.SUM_WIN_PROB/100) else 0 end as EXPECT_VAL, "))
            .AppendLine(String.Format(" IsNull((select top 1 B.NAME from S_STG B where B.ROW_ID=A.CURR_STG_ID),'') as STAGE_NAME, "))
            .AppendLine(String.Format(" A.PR_DEPT_OU_ID, A.STATUS_CD, z1.NAME as ACCOUNT_NAME, z1.ROW_ID as ACCOUNT_ROW_ID, "))
            .AppendLine(String.Format(" IsNull((select SM.NAME from S_SALES_METHOD SM where SM.ROW_ID=A.SALES_METHOD_ID),'') as SALES_METHOD_NAME, "))
            .AppendLine(String.Format(" IsNull(A.CHANNEL_TYPE_CD,'') as Channel, IsNull(A.DESC_TEXT,'') as DESC_TEXT, IsNull(A.REASON_WON_LOST_CD,'') as REASON_WON_LOST_CD, z4.EMAIL_ADDR "))
            .AppendLine(String.Format(" from S_OPTY A left outer join S_OPTY_X X on A.ROW_ID=X.ROW_ID "))
            .AppendLine(String.Format(" inner join S_ORG_EXT z1 on A.PR_DEPT_OU_ID=z1.ROW_ID  "))
            .AppendLine(String.Format(" inner join S_ACCNT_POSTN z2 on z1.ROW_ID=z2.OU_EXT_ID  "))
            .AppendLine(String.Format(" inner join S_POSTN z3 on z2.POSITION_ID=z3.ROW_ID  "))
            .AppendLine(String.Format(" inner join S_CONTACT z4 on z3.PR_EMP_ID=z4.ROW_ID "))
            .AppendLine(String.Format(" where lower(z4.EMAIL_ADDR) like '{0}@%advantech%.%' ", uid))
            .AppendLine(String.Format(" and A.SUM_WIN_PROB between 1 and 99 and A.STATUS_CD not in ('Invalid') "))
            .AppendLine(String.Format(" and A.CREATED between '{0}' and '{1}' ", cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            .AppendLine(String.Format(" order by A.CREATED desc, A.ROW_ID "))
        End With
        Return sb.ToString()
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'If Session("account_status") IsNot Nothing AndAlso Session("account_status").ToString() = "EZ" Then
            '    If Session("sales_id") Is Nothing Then
            '        Session("sales_id") = Util.GetSalesID(Session("user_id"))
            '        If Session("sales_id") Is Nothing OrElse Session("sales_id") = "" Then Session("sales_id") = "gy78787878"
            '        If Util.IsAdmin() Then Session("sales_id") = "34013004"
            '    End If
            'End If
        End If
    End Sub

    Protected Sub Timer1_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Interval = 99999 : src1.SelectCommand = GetSql() : Timer1.Enabled = False : imgLoading.Visible = False
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Public Shared Function FDate(ByVal d As String) As String
        If Date.TryParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Now) Then
            Return Date.ParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("M/dd/yyyy")
        End If
        Return d
    End Function

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Enabled = False
    End Sub
</script>
<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
    <ContentTemplate>
        <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
                <td align="left" class="h3" height="30">My Opportunities</td>
            </tr>
            <tr>
                <td>
                    <asp:Timer runat="server" ID="Timer1" Interval="15" OnTick="Timer1_Tick" />
                    <center><asp:Image runat="server" ID="imgLoading" ImageUrl="~/Images/loading2.gif" /></center>
                    <asp:GridView runat="server" Width="100%" ID="gv1" AutoGenerateColumns="false" AllowPaging="true" EnableTheming="false" 
                        AllowSorting="true" PageSize="10" DataSourceID="src1" OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting"
                        RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" 
                        BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                        PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                        <Columns>
                            <asp:BoundField HeaderText="Project Name" DataField="NAME" SortExpression="NAME" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                            <asp:HyperLinkField HeaderText="Customer Name" DataNavigateUrlFields="ACCOUNT_ROW_ID" 
                                DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" DataTextField="ACCOUNT_NAME" Target="_blank" />
                            <asp:TemplateField HeaderText="Total Revenue" SortExpression="Total Revenue" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <%# Util.FormatMoney(Eval("SUM_REVN_AMT"), Eval("currency"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Status" DataField="STATUS_CD" SortExpression="STATUS_CD" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                            <asp:TemplateField HeaderText="Probability (%)" SortExpression="STATUS_CD" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <%# Eval("SUM_WIN_PROB").ToString() + "%"%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:CRMAPPDB %>" />
                </td>
            </tr>
        </table>        
    </ContentTemplate>
</asp:UpdatePanel>
