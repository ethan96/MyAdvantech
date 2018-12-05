<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CBOM_SharedComponent.ascx.cs" Inherits="Includes_CBOM_CBOM_SharedComponent" %>

<script type="text/javascript">
    function ResizeFunction() {
        $.fancybox.update();
    };

    function ChooseComponent(node) {
        var $shared = $(node);
        $("#txtComponentName").tokenInput("clear");
        $("#txtComponentName").data("settings").tokenLimit = 1;
        $("#txtComponentName").tokenInput("add", { id: $shared.attr("data-id"), name: $shared.attr("data-cid") });
        $("#txtComponentDesc").val($shared.attr("data-note")).attr("data-id", $shared.attr("data-id")).attr("disabled", true);
        $('input[name=isComponentDefault]').attr("disabled", true);
        $('input[name=isComponentExpand]').attr("disabled", true);
        $('input[name=ComponentPlant]').attr("disabled", true);
        $("input[name='ComponentPlant'][value='0']").attr("checked", true);

        if ($shared.attr("data-default") == "0")
            $("input[name='isComponentDefault'][value='0']").attr("checked", true);
        else
            $("input[name='isComponentDefault'][value='1']").attr("checked", true);

        if ($shared.attr("data-expand") == "0")
            $("input[name='isComponentExpand'][value='0']").attr("checked", true);
        else
            $("input[name='isComponentExpand'][value='1']").attr("checked", true);

        if ($shared.attr("data-configrule") == "0")
            $("input[name='ComponentPlant'][value='0']").attr("checked", true);
        else if ($shared.attr("data-configrule") == "1")
            $("input[name='ComponentPlant'][value='1']").attr("checked", true);
        else
            $("input[name='ComponentPlant'][value='2']").attr("checked", true);

        $("#btnAddComponent").attr("data-type", '<%=Advantech.Myadvantech.DataAccess.CBOMAddType.CopySharedComponent%>');
        $.fancybox.close();
        return false;
    };
</script>
<table>
    <tr>
        <td>
            <h3>Please select or search part No.:</h3>
            <asp:TextBox ID="txtCategory" runat="server" autocomplete="off" class="input-field"></asp:TextBox>&nbsp;
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
            <asp:Button ID="btnInitial" runat="server" OnClick="btnInitial_Click" Style="display: none;" />
        </td>
    </tr>
    <tr>
        <td>
            <asp:UpdatePanel ID="upSharedCategory" runat="server">
                <ContentTemplate>
                    <asp:Repeater ID="rpSharedCategory" runat="server" OnItemCommand="rpSharedCategory_ItemCommand">
                        <HeaderTemplate>
                            <table>
                                <thead>
                                    <tr>
                                        <th>Part No.</th>
                                        <th>Part Desc</th>
                                        <% if (this.Admin == true)
                                           { %>
                                        <th>Delete</th>
                                        <% } %>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <a href="#" data-id="<%#Eval("ID") %>" data-cid="<%#Eval("CATEGORY_ID") %>" data-note="<%#Eval("CATEGORY_NOTE") %>" data-default="<%#Eval("DEFAULT_FLAG") %>" data-expand="<%#Eval("EXPAND_FLAG") %>"
                                        data-qty="<%#Eval("MAX_QTY") %>" data-configrule="<%#Eval("CONFIGURATION_RULE") %>" onclick="ChooseComponent(this);"><%#Eval("CATEGORY_ID") %></a>
                                </td>
                                <td><%#Eval("CATEGORY_NOTE") %></td>
                                <% if (this.Admin == true)
                                   { %>
                                <td style="text-align: center;">
                                    <asp:ImageButton ID="btnDelete" runat="server" CommandName="Delete" CommandArgument='<%#Eval("ID") + "," + txtCategory.Text %>' ImageUrl="~/Images/delete.jpg" OnClientClick="return confirm('Are you sure?')" />
                                </td>
                                <% } %>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                            </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="btnSearch" />
                    <asp:AsyncPostBackTrigger ControlID="btnInitial" />
                </Triggers>
            </asp:UpdatePanel>
        </td>
    </tr>
</table>
