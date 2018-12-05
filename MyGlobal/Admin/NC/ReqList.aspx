<%@ Page Title="MyAdvantech - New SAP Account Creation List" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="ReqList.aspx.cs" Inherits="Admin_NC_ReqList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td>
                <table></table>
            </td>
        </tr>
        <tr>
            <td>
                <asp:HyperLink runat="server" ID="hyCreateNewSAPAccount" Font-Size="Larger" Font-Bold="true" NavigateUrl="~/Admin/NC/NewSAPAccount.aspx" Text="Submit a new SAP account creation" />
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gvList" AutoGenerateColumns="false" Width="100%">
                            <Columns>
                                <asp:TemplateField HeaderText="Ticke No." ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <a href='NewSAPAccount.aspx?AppId=<%#Eval("ApplicationId") %>'><%#Eval("TicketId") %></a>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Applied By" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <%#Eval("CreatedBy") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Applied Date" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <%#Eval("AppliedDate") %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Detail" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="250px">
                                    <ItemTemplate>
                                        <table style="width:100%">
                                            <%#showDetail(Eval("ApplicationId").ToString()) %>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Sales Office" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <%#showSalesOffice(Eval("ApplicationId").ToString()) %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Approval Status" ItemStyle-HorizontalAlign="Center">
                                    <ItemTemplate>
                                        <%#NewSAPAccountUtil.getApprovalStatus(Eval("ApplicationId").ToString()) %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>