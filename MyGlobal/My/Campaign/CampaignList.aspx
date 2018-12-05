<%@ Page Title="MyAdvantech - My Campaigns" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            BindGV()
        End If
    End Sub
    Private Sub BindGV()
        Dim MyDC As New MyCampaignDBDataContext()
        Dim MyCR As List(Of CAMPAIGN_REQUEST) = MyDC.CAMPAIGN_REQUESTs.OrderByDescending(Function(p) p.REQUEST_DATE).ToList
        If Not CampaignUtil.IsAdmin() Then
            Dim objRBU As Object = dbUtil.dbExecuteScalar("MY", String.Format("SELECT TOP 1 RBU FROM CAMPAIGN_REQUEST_MarketingManager_RBU WHERE   MarketingManagerID IN(SELECT ID FROM CAMPAIGN_REQUEST_MarketingManager where EMAIL='{0}')", Session("USER_ID")))
            If objRBU IsNot Nothing AndAlso Not String.IsNullOrEmpty(objRBU.ToString) Then
                MyCR = MyDC.CAMPAIGN_REQUESTs.Where(Function(p) p.RBU = objRBU.ToString).OrderByDescending(Function(p) p.REQUEST_DATE).ToList
            ElseIf IsAdvantechChannelSales() Then
                MyCR = MyDC.CAMPAIGN_REQUESTs.Where(Function(p) p.ERPID = Session("company_id").ToString).OrderByDescending(Function(p) p.REQUEST_DATE).ToList
            Else
                hyMarketingManager.Visible = False
                MyCR = MyDC.CAMPAIGN_REQUESTs.Where(Function(p) p.REQUEST_BY = Session("user_id").ToString).OrderByDescending(Function(p) p.REQUEST_DATE).ToList
            End If
        End If
        gv1.DataSource = MyCR
        gv1.DataBind()
    End Sub
    Public Function IsAdvantechChannelSales() As Boolean   'For Advantech Channel Sales
        Dim sql As New StringBuilder
        sql.Append(" select distinct  c.EMAIL_ADDRESS ")
        sql.Append(" from SIEBEL_ACCOUNT_OWNER a inner join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID inner join SIEBEL_CONTACT c on a.OWNER_ID=c.ROW_ID  ")
        sql.AppendFormat(" where b.ERP_ID='{0}' ", Session("company_id"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString)
        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows
                If Util.IsValidEmailFormat(dr.Item("EMAIL_ADDRESS")) Then
                    If String.Equals(dr.Item("EMAIL_ADDRESS"), Session("user_id")) Then
                        Return True
                    End If
                End If
            Next
        End If
        Return False
    End Function
    Protected Function Getlink(ByVal Status As String, ByVal RequestNo As String) As String
        If IsNumeric(Status) Then
            If Integer.Parse(Status) > 1 AndAlso Not (Integer.Parse(Status) = 4 OrElse Integer.Parse(Status) = 5 OrElse Integer.Parse(Status) = 6) Then
                Return String.Format("<a  href=""UploadTAlist.aspx?REQUESTNO={0}"" target=""_blank"">Upload TA list</a>", RequestNo)
            End If
        End If
        Return ""
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td align="left">
                <asp:HyperLink runat="server" ID="hySBUCampaignList" NavigateUrl="~/My/AOnline/UNICA_SBU_Campaigns_New.aspx"
                    Text="SBU Campaign Overview" />
            </td>
            <td align="right">
                <asp:HyperLink runat="server" ID="hyMarketingManager" NavigateUrl="~/My/Campaign/CampainMarketingManager.aspx"
                    Text="Marketing Manager" Target="_blank" />
            </td>
        </tr>
    </table>
    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" DataKeyNames="REQUESTNO">
        <Columns>
            <asp:TemplateField HeaderText="Ticket Number" ItemStyle-HorizontalAlign="Center"
                HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:HyperLink ID="HyperLink1" Target="_blank" runat="server" NavigateUrl='<%# Eval("REQUESTNO", "CampaignRequest.aspx?REQUESTNO={0}") %>'>
                                    <%# Eval("REQUESTNO")%>
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="Status" DataField="STATUSX" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Campaign Name" DataField="REQUEST_BY" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="ERP Name" DataField="ErpNameX" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Registered By" DataField="REQUEST_BY" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Registered on" DataField="REQUEST_DATE" SortExpression="REQUEST_DATE"
                DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
            <asp:TemplateField HeaderText="TA List" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <%# Getlink(Eval("STATUS"), Eval("REQUESTNO"))%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Performance Report" ItemStyle-HorizontalAlign="Center"
                HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:HyperLink ID="hlpr"  runat="server" NavigateUrl='#'>
                                Report
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>
