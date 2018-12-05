<%@ Page Title="My Contact List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register src="AOnlineFunctionLinks.ascx" tagname="AOnlineFunctionLinks" tagprefix="uc1" %>
<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("ListID") IsNot Nothing AndAlso Trim(Request("ListID")) <> "" Then
                src1.SelectParameters("LID").DefaultValue = Trim(Request("ListID"))
            End If
        End If
    End Sub

    Protected Sub lnkRowDelete_Click(sender As Object, e As System.EventArgs)
        Dim lnk As LinkButton = sender
        Dim hd As String = CType(lnk.NamingContainer.FindControl("hdRowId"), HiddenField).Value
        dbUtil.dbExecuteNoQuery("MyLocal_New", "delete from AONLINE_SALES_CONTACTLIST_DETAIL where LIST_ID='" + src1.SelectParameters("LID").DefaultValue + "' and ROW_ID='" + hd + "'")
        gvContact.DataBind()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr align="right"><td align="right"><uc1:AOnlineFunctionLinks ID="AOnlineFunctionLinks1" runat="server" /></td></tr>
    </table>
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:GridView runat="server" ID="gvContact" DataSourceID="src1" AutoGenerateColumns="false"
                AllowPaging="true" AllowSorting="true" PageSize="100" Width="80%">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:HiddenField runat="server" ID="hdRowId" Value='<%#Eval("row_id") %>' />
                            <asp:LinkButton runat="server" ID="lnkRowDelete" Text="Delete" OnClick="lnkRowDelete_Click" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Email">
                        <ItemTemplate>
                            <a target="_blank" href='../../DM/ContactDashboard.aspx?EMAIL=<%#Eval("contact_email") %>'>
                                <%#Eval("contact_email")%></a>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField HeaderText="First Name" DataField="firstname" />
                    <asp:BoundField HeaderText="Last Name" DataField="lastname" />
                    <asp:BoundField HeaderText="Account Name" DataField="account" />
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MyLocal_New %>"
                SelectCommand="select distinct top 9999 a.contact_email, a.row_id, (select top 1 z.firstname from [ACLSTNR12].MyAdvantechGlobal.dbo.siebel_contact z where z.email_address=a.contact_email) as firstname, (select top 1 z.lastname from [ACLSTNR12].MyAdvantechGlobal.dbo.siebel_contact z where z.email_address=a.contact_email) as lastname, (select top 1 z.account from [ACLSTNR12].MyAdvantechGlobal.dbo.siebel_contact z where z.email_address=a.contact_email) as account from AONLINE_SALES_CONTACTLIST_DETAIL a where list_id=@LID order by row_id">
                <SelectParameters>
                    <asp:Parameter ConvertEmptyStringToNull="false" Name="LID" />
                </SelectParameters>
            </asp:SqlDataSource>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
