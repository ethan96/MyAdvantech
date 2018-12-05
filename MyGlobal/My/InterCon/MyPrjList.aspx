<%@ Page Title="MyAdvantech - My Registered Projects" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Response.Redirect("./PrjList.aspx")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:GridView runat="server" ID="gvMyPrj" Width="100%">
        <Columns>
            <asp:BoundField HeaderText="Project Name" DataField="PRJ_NAME" SortExpression="PRJ_NAME" />
            <asp:BoundField HeaderText="Registered By" DataField="CREATED_BY" SortExpression="CREATED_BY" />
            <asp:BoundField HeaderText="Registered on" DataField="CREATED_DATE" SortExpression="CREATED_DATE"
                DataFormatString="{0:yyyy-MM-dd}" />
            <asp:BoundField HeaderText="CP's Name" DataField="CP_COMPANY_ID" SortExpression="CP_COMPANY_ID" />
            <asp:BoundField HeaderText="End Customer's Name" DataField="ENDCUST_NAME" SortExpression="ENDCUST_NAME" />
            <asp:BoundField HeaderText="Opportunity ID" DataField="prj_opty_id" SortExpression="prj_opty_id" />
        </Columns>
    </asp:GridView>
</asp:Content>
