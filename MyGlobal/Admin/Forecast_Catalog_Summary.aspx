<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - All Catalog Summary" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If (Util.IsAEUIT() Or Util.IsInternalUser(Session("user_id"))) Then
            trSum.Visible = True : trNew.Visible = True
        Else
            'trSum.Visible = False : trNew.Visible = False
            'Response.Redirect("Forecast_Catalog.aspx")
            Response.Redirect(Request.ApplicationPath) 'ICC 2016/3/23 This page cannot be accessed by outer user.
        End If
    End Sub

    Private Function GetSQL() As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select b.row_id as catalog_id,b.part_no,b.description,b.AVAILABLE_DATE,sum(a.QTY) as QTY,b.owner from forecast_catalog_history_new a inner join forecast_catalog_list b on a.catalog_id=b.row_id where a.is_disabled=0 and b.is_disabled=0 ")
            If txtPN.Text.Trim.Replace("'", "''") <> "" Then .AppendFormat(" and (b.part_no like '%{0}%' or b.description like N'%{0}%') ", txtPN.Text.Trim.Replace("'", "''"))
            .AppendFormat(" group by b.row_id,b.PART_NO,b.DESCRIPTION,b.AVAILABLE_DATE,b.owner order by b.available_date desc")
        End With
        Return sb.ToString
    End Function
    
    Protected Sub sqlCatalogList_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        sqlCatalogList.SelectCommand = GetSQL()
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        sqlCatalogList.SelectCommand = GetSQL()
        gv1.DataBind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table>
        <tr>
            <td>
                <table border="0" cellspacing="0" cellpadding="0">
					<tr>
						<td><asp:HyperLink runat="server" ID="hlCatalogList" NavigateUrl="~/Admin/Forecast_Catalog.aspx" Text="Catalog List" /></td>
						<td width="15" align="center">></td>
						<td><asp:HyperLink runat="server" ID="hlCatalogSummary" NavigateUrl="~/Admin/Forecast_Catalog_Summary.aspx" Text="Catalog Forecast Summary" /></td>
						<td>&nbsp;
						</td>
					</tr>
				</table>
            </td>
        </tr>
        <tr><td height="3"></td></tr>
        <tr><td><div class="euPageTitle"><asp:Label runat="server" ID="lblTitle" /></div></td></tr>
        <tr><td height="3"></td></tr>
    </table>
    <table width="100%" height="380" border="0">
        <tr>
            <td width="20%" valign="top">
                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td height="24" class="menu_title">
                        <asp:Literal ID="LiT3" runat="server">Advantech Catalog</asp:Literal>
                        </td>
                    </tr>
                    <tr>
                        <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                            <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                            </tr>
                            <tr runat="server" id="trNew">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top"><img src="../Images/point_02.gif" alt="" width="7" height="14"/></td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hlNew" NavigateUrl="~/Admin/Forecast_Catalog_Create.aspx" Text="Create New Catalog" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            </tr>
                            <tr runat="server" id="trSum">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top"><img src="../Images/point_02.gif" alt="" width="7" height="14"/></td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hlSum" NavigateUrl="~/Admin/Forecast_Catalog_Summary.aspx" Text="Catalog Forecast Summary" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            </tr>
                            <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                            </tr>
                        </table>
                        </td>
                    </tr>
                </table>
            </td>
            <td valign="top" width="80%">
                <table width="100%">
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td>P/N or Catalog: </td>
                                    <td><asp:TextBox runat="server" ID="txtPN" Width="200px" /></td>
                                    <td><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="up1">
                                <ContentTemplate>
                                    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" AllowPaging="true" PageSize="10" ShowWhenEmpty="true" PagerSettings-Position="TopAndBottom" DataSourceID="sqlCatalogList">
                                        <Columns>
                                            <asp:BoundField DataField="part_no" HeaderText="P/N" ItemStyle-Width="100" />
                                            <asp:HyperLinkField DataTextField="description" HeaderText="Catalogue Name" DataNavigateUrlFields="catalog_id" DataNavigateUrlFormatString="Forecast_Catalog_Detail.aspx?catalog_id={0}" />
                                            <asp:BoundField DataField="available_date" HeaderText="Available Date" SortExpression="available_date" ItemStyle-Width="100" />
                                            <asp:BoundField DataField="Qty" HeaderText="Total" ItemStyle-Width="100" />
                                            <asp:BoundField DataField="owner" HeaderText="Owner" ItemStyle-Width="100" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlCatalogList" ConnectionString="<%$ connectionStrings:MY %>"
                                            SelectCommand="" OnLoad="sqlCatalogList_Load">
                                    </asp:SqlDataSource>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    
</asp:Content>

