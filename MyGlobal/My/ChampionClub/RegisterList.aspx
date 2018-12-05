<%@ Page Title="Champion Club - Register List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
          
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr><td><asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" /> > <asp:HyperLink runat="server" ID="hlChampion" NavigateUrl="~/My/ChampionClub/ChampionClub.aspx" Text="Champion Club" /></td></tr>
        <tr><td height="5"></td></tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" AllowPaging="true" PageSize="50" AllowSorting="true" DataSourceID="sql1">
                    <Columns>
                        <asp:BoundField HeaderText="User ID" DataField="USER_ID" SortExpression="USER_ID" />
                        <asp:TemplateField HeaderText="Personal Info." ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Left">
                            <ItemTemplate>
                                <table width="100%">
                                    <tr>
                                        <th align="left">User Name: </th><td colspan="3"><asp:Label runat="server" ID="lblUserName" Text='<%#Eval("USER_NAME") %>' /> </td>
                                    </tr>
                                    <tr>
                                        <th align="left">First Name: </th><td><asp:Label runat="server" ID="lblFirstName" Text='<%#Eval("FIRST_NAME") %>' /></td>
                                        <th align="left">Last Name: </th><td><asp:Label runat="server" ID="lblLastName" Text='<%#Eval("LAST_NAME") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Country: </th><td><asp:Label runat="server" ID="lblCountry" Text='<%#Eval("COUNTRY") %>' /></td>
                                        <th align="left">City: </th><td><asp:Label runat="server" ID="lblCity" Text='<%#Eval("CITY") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">State: </th><td><asp:Label runat="server" ID="lblState" Text='<%#Eval("STATE") %>' /></td>
                                        <th align="left">Zip Code: </th><td><asp:Label runat="server" ID="lblZip" Text='<%#Eval("ZIP_CODE") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Address: </th><td colspan="3"><asp:Label runat="server" ID="lblAddress" Text='<%#Eval("ADDRESS") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Telephone: </th><td><asp:Label runat="server" ID="lblPhone" Text='<%#Eval("PHONE") %>' /></td>
                                        <th align="left">Email: </th><td><asp:Label runat="server" ID="lblEmail" Text='<%#Eval("EMAIL") %>' /></td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Company Info." ItemStyle-VerticalAlign="Top" ItemStyle-HorizontalAlign="Left">
                            <ItemTemplate>
                                <table width="100%">
                                    <tr>
                                        <th align="left">Company Name: </th><td><asp:Label runat="server" ID="lblCompanyName" Text='<%#Eval("COMPANY_NAME") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Address: </th><td><asp:Label runat="server" ID="lblCompanyAddr" Text='<%#Eval("COMPANY_ADDRESS") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Country: </th><td><asp:Label runat="server" ID="lblCompanyCountry" Text='<%#Eval("COMPANY_COUNTRY") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">City: </th><td><asp:Label runat="server" ID="lblCompanyCity" Text='<%#Eval("COMPANY_CITY") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">State: </th><td><asp:Label runat="server" ID="lblCompanyState" Text='<%#Eval("COMPANY_STATE") %>' /></td>
                                    </tr>
                                    <tr>
                                        <th align="left">Zip Code: </th><td><asp:Label runat="server" ID="CompanyZip" Text='<%#Eval("COMPANY_ZIP") %>' /></td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="REQUEST_DATE" HeaderText="Joined Date" SortExpression="REQUEST_DATE" />
                    </Columns>
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ ConnectionStrings: MY %>"
                    SelectCommand="select * from CHAMPION_CLUB_REGISTER"></asp:SqlDataSource>
            </td>
        </tr>
    </table>
</asp:Content>

