<%@ Control Language="VB" ClassName="MyLeads" %>

<script runat="server">
    Function GetSql() As String
        If Session("account_status") Is Nothing OrElse (Session("account_status").ToString() <> "CP" And Session("account_status").ToString() <> "EZ") Then
            Return ""
        End If
        Return Util.GetMyLeadsSql(Session("company_id"), Session("user_id"), 0, 0)
    End Function
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Session("account_status") Is Nothing OrElse (Session("account_status").ToString() <> "CP" And Session("account_status").ToString() <> "EZ") Then
                imgLoading.Visible = False
            End If
        End If
    End Sub

    Protected Sub Timer1_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Interval = 99999 : src1.SelectCommand = GetSql() : Timer1.Enabled = False
        'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "", src1.SelectCommand, False, "", "")
        imgLoading.Visible = False
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
    End Sub
   
</script>
<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
    <ContentTemplate>
        <table width="100%" cellpadding="0" cellspacing="0" border="0">
            <tr>
                <td align="left" class="h3" height="30">My Sales Leads</td>
            </tr>
            <tr>
                <td>
                    <asp:Timer runat="server" ID="Timer1" Interval="1000" OnTick="Timer1_Tick" />
                    <center><asp:Image runat="server" ID="imgLoading" ImageUrl="~/Images/loading2.gif" /></center>
                    <asp:GridView runat="server" Width="100%" ID="gv1" AutoGenerateColumns="false" AllowPaging="true" EnableTheming="false" 
                        AllowSorting="true" PageSize="10" DataSourceID="src1" 
                        RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" 
                        BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                        PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White"
                        OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting">
                        <Columns>                           
                            <asp:BoundField HeaderText="Lead Name" DataField="NAME" SortExpression="NAME" />
                            <asp:TemplateField HeaderText="Amount" SortExpression="SUM_REVN_AMT">
                                <ItemTemplate>
                                    <%# Util.FormatMoney(Eval("SUM_REVN_AMT"), Eval("CURCY_CD"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Status" DataField="STATUS_CD" SortExpression="STATUS_CD" />
                        </Columns>
                    </asp:GridView>
                    <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:CRMAPPDB %>" />
                </td>
            </tr>
            <tr>
                <td align="right"><asp:HyperLink runat="server" ID="hyLeadMgt" Text="Detail..." NavigateUrl="~/My/MyLeads.aspx" /></td>
            </tr>
        </table>        
    </ContentTemplate>
</asp:UpdatePanel>
