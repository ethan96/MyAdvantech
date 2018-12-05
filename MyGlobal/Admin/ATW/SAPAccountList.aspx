<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="SAPAccountList.aspx.cs" Inherits="Admin_ATW_SAPAccountList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false">
        <Columns>
            <asp:TemplateField HeaderText="Ticket Number" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <asp:HyperLink ID="HyperLink1" Target="_blank" runat="server" NavigateUrl='<%# Eval("ApplicationID", "CreateSAPAccount.aspx?ID={0}") %>'>
                                    <%# Eval("ApplicationNo")%>
                    </asp:HyperLink>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="Company Name" DataField="CompanyName" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Company ID" DataField="CompanyID" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
            <asp:TemplateField HeaderText="Status" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <%# GetSTATUS(Eval("Status"))%>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="Registered By" DataField="RequestBy" SortExpression="REQUEST_BY"
                HeaderStyle-HorizontalAlign="Center" />
            <asp:BoundField HeaderText="Registered on" DataField="RequestDate" SortExpression="REQUEST_DATE"
                DataFormatString="{0:yyyy-MM-dd}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
        </Columns>
    </asp:GridView>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

