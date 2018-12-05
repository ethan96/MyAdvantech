<%@ Page Title="MyAdvantech AOnline Sales Portal - Add Content Report" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub gvRefContent_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            CType(e.Row.FindControl("rowSrc"), SqlDataSource).SelectParameters("UID").DefaultValue = CType(e.Row.FindControl("hdRowUserId"), HiddenField).Value
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <h2>Curated Content Referenced Dashboard</h2><br />
    <asp:GridView runat="server" ID="gvRefContent" Width="100%" DataSourceID="src1" AutoGenerateColumns="false" OnRowDataBound="gvRefContent_RowDataBound">
        <Columns>
            <asp:BoundField HeaderText="Sales Email" DataField="USERID" />
            <asp:BoundField HeaderText="Referenced Times" DataField="added_counts" ItemStyle-HorizontalAlign="Center" />
            <asp:TemplateField HeaderText="Referenced Articles" HeaderStyle-Width="600px">
                <ItemTemplate>
                    <asp:HiddenField runat="server" ID="hdRowUserId" Value='<%#Eval("USERID") %>' />
                    <asp:GridView runat="server" ID="gvRefLog" DataSourceID="rowSrc" AutoGenerateColumns="false" ShowHeader="false" Width="100%">
                        <Columns>                            
                            <asp:TemplateField HeaderText="Content Title">
                                <ItemTemplate>                                    
                                    <a href='<%#Eval("ORIGINAL_URL")%>' target="_blank">
                                        <%#Eval("CONTENT_TITLE")%></a>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Source" DataField="SOURCE_APP" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
                        </Columns>
                    </asp:GridView>
                    <asp:SqlDataSource runat="server" ID="rowSrc" ConnectionString="<%$ConnectionStrings:MyLocal_New %>" 
                        SelectCommand="select top 1000 ADDED_DATE, CONTENT_TITLE, SOURCE_ID, SOURCE_APP, ORIGINAL_URL from AONLINE_SALES_CONTENT_CART where USERID=@UID and ADDED_DATE>=getdate()-@ADD_DAYS order by ADDED_DATE desc">
                        <SelectParameters>
                            <asp:Parameter ConvertEmptyStringToNull="false" Name="UID" />
                            <asp:Parameter ConvertEmptyStringToNull="false" DefaultValue="30" Name="ADD_DAYS" Type="Int32" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                </ItemTemplate>
            </asp:TemplateField>            
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MyLocal_New %>" 
        SelectCommand="select userid, COUNT(SOURCE_ID) as added_counts from AONLINE_SALES_CONTENT_CART group by USERID order by  COUNT(SOURCE_ID) desc" />
</asp:Content>
