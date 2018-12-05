<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CBOM_SharedCategory.ascx.cs" Inherits="Includes_CBOM_CBOM_SharedCategory" %>

<style type="text/css">
    .Field-Req {
        background-color: orange;
    }
</style>
<script type="text/javascript">
    function ResizeFunction() {
        $.fancybox.update();
    };

    function CheckField(node) {
        if (!$(node).val())
            $(node).addClass("Field-Req");
        else
            $(node).removeClass("Field-Req");
    };

    function ChooseCategory(node) {
        var $shared = $(node);
        $("#txtNewCategoryName").val($shared.attr("data-cid")).attr("data-id", $shared.attr("data-id")).attr("disabled", true);
        $("#txtNewCategoryDesc").val($shared.attr("data-note")).attr("disabled", true);
        $('#txtCategoryQty').val($shared.attr("data-qty")).attr("disabled", true);
        $('input[name=isCategoryExpand]').attr("disabled", true);
        $('input[name=isCategoryRequired]').attr("disabled", true);

        if ($shared.attr("data-required") == "0")
            $("input[name='isCategoryRequired'][value='0']").attr("checked", true);
        else
            $("input[name='isCategoryRequired'][value='1']").attr("checked", true);

        if ($shared.attr("data-expand") == "0")
            $("input[name='isCategoryExpand'][value='0']").attr("checked", true);
        else
            $("input[name='isCategoryExpand'][value='1']").attr("checked", true);
        $("#btnAddCategory").attr("data-type", '<%=Advantech.Myadvantech.DataAccess.CBOMAddType.CopySharedCategory%>');
        $.fancybox.close();
        return false;
    };
</script>
<table>
    <tr>
        <td>
            <h3>Please select or search category ID:</h3>
            <asp:TextBox ID="txtCategory" runat="server" autocomplete="off" class="input-field"></asp:TextBox>&nbsp;
            <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" />
            <asp:Button ID="btnInitial" runat="server" OnClick="btnInitial_Click" style="display:none;" />
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
                                        <th>Category ID</th>
                                        <th>Category Note</th>
                                        <% if (this.Admin == true)
                                           { %>
                                        <th>Edit</th>
                                        <th>Delete</th>
                                        <% } %>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <asp:HyperLink ID="hlCategoryID" runat="server" href="#" data-id='<%#Eval("ID") %>' data-cid='<%#Eval("CATEGORY_ID") %>' data-note='<%#Eval("CATEGORY_NOTE") %>'
                                        data-required='<%#Eval("REQUIRED_FLAG") %>' data-expand='<%#Eval("EXPAND_FLAG") %>' data-qty='<%#Eval("MAX_QTY") %>' Text='<%#Eval("CATEGORY_ID") %>' onclick="ChooseCategory(this);"></asp:HyperLink>
                                    <asp:TextBox ID="txtCategoryID" runat="server" CssClass="input-field" autocomplete="off" onblur="CheckField(this);" Visible="false"></asp:TextBox>
                                </td>
                                <td>
                                    <asp:Label ID="lbCategoryNote" runat="server" Text='<%#Eval("CATEGORY_NOTE") %>'></asp:Label>
                                    <asp:TextBox ID="txtCategoryNote" runat="server" CssClass="input-field" autocomplete="off" onblur="CheckField(this);" Visible="false"></asp:TextBox>
                                </td>
                                <% if (this.Admin == true)
                                   { %>
                                <td style="text-align:center;">
                                    <asp:ImageButton ID="btnEdit" runat="server" CommandName="Edit" CommandArgument='<%#Eval("ID")%>' ImageUrl="~/Images/edit.png" />&nbsp;
                                    <asp:ImageButton ID="btnUpdate" runat="server" CommandName="Update" CommandArgument='<%#Eval("ID") + "," + txtCategory.Text %>' ImageUrl="~/Images/go.png" Visible="false" />&nbsp;
                                    <asp:ImageButton ID="btnCancel" runat="server" CommandName="Cancel" CommandArgument='<%#Eval("ID")  %>' ImageUrl="~/Images/Wrong.jpg" Visible="false" /></td>
                                <td style="text-align:center;">
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
                    <span style="color: tomato"><%=this.ErrorMessage %></span>
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="btnSearch" />
                    <asp:AsyncPostBackTrigger ControlID="btnInitial" />
                </Triggers>
            </asp:UpdatePanel>
        </td>
    </tr>
</table>