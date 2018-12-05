<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="PrjTmpList.aspx.cs" Inherits="My_InterCon_PrjTmpList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script src="../../Includes/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(function () {
            $(".NoAccess").click(function () {
                alert("The project only can be edited by the creator.");
                return false;
            });
        });
    </script>
    <table width="100%">
        <tr>
            <td>
                <div>
                    <asp:GridView ID="gvTempList" runat="server" AutoGenerateColumns="false" OnRowDataBound="gvTempList_RowDataBound">
                        <Columns>
                            <asp:TemplateField HeaderText="Project Name" HeaderStyle-Width="200px">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hlUrl" runat="server" NavigateUrl='<%# Eval("ROW_ID", "PrjReg.aspx?ROW_ID={0}") %>'>
                                    <%# Eval("PRJ_NAME")%>
                                    </asp:HyperLink>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="CP's Name" HeaderStyle-Width="180px">
                                <ItemTemplate>
                                    <%# Eval("CP_COMPANY_ID")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="End Customer's Name" DataField="ENDCUST_NAME" SortExpression="ENDCUST_NAME" />
                            <asp:TemplateField HeaderText="Amount" ItemStyle-HorizontalAlign="Right" ItemStyle-CssClass="Tnowrap">
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Saved on" DataField="CREATED_DATE" SortExpression="CREATED_DATE"
                                DataFormatString="{0:yyyy-MM-dd}" />
                            <asp:TemplateField HeaderText="Saved by" HeaderStyle-Width="180px">
                                <ItemTemplate>
                                    <%# Eval("CREATED_BY")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </td>
        </tr>
    </table>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

