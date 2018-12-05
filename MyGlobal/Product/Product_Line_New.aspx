<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Product Line" %>
<%--<%@ Register TagPrefix="uc1" TagName="Product" Src="~/Includes/Product.ascx" %>--%>

<script runat="server">

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request.IsAuthenticated AndAlso Session("RBU") IsNot Nothing AndAlso Session("RBU") = "AENC" Then
                Server.Transfer("ProductSearch_AENC.aspx", False)
            End If
        End If
    End Sub

    Protected Sub DataList1_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs)
        Dim s As SqlDataSource = e.Item.FindControl("SqlDataSource2")
        s.SelectParameters("PARENT_CATEGORY_ID").DefaultValue = e.Item.DataItem("CATEGORY_ID")
    End Sub

    Protected Sub DataList2_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs)
        Dim s As SqlDataSource = e.Item.FindControl("SqlDataSource4")
        s.SelectParameters("PARENT_CATEGORY_ID").DefaultValue = e.Item.DataItem("CATEGORY_ID")
    End Sub

    Protected Sub DataList3_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs)
        Dim s As SqlDataSource = e.Item.FindControl("SqlDataSource6")
        s.SelectParameters("PARENT_CATEGORY_ID").DefaultValue = e.Item.DataItem("CATEGORY_ID")
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <style type="text/css">
        .header-nav {
            color: #4d4d4d;
            background-image: url(http://advcloudfiles.advantech.com/web/Images/common/arrow-megamenu.gif);
            background-repeat: no-repeat;
            background-position: center right;
            padding-right: 15px;
            font-weight: normal;
        }
    </style>
    <%--<uc1:Product runat="server" ID="ucProduct" />--%>
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td valign="top" width="30%">
                <asp:DataList runat="server" ID="DataList1" DataSourceID="SqlDataSource1" RepeatDirection="Vertical" CellPadding="10"
                    DataKeyField="Category_ID" OnItemDataBound="DataList1_ItemDataBound">
                    <ItemTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td valign="center">
                                    <a name='<%# Eval("CATEGORY_ID") %>'></a>
                                    <table>
                                        <tr>
                                            <td valign="center" class="title_med">
                                                <asp:Label runat="server" ID="lblCategoryDesc" Text='<%# Eval("DISPLAY_NAME") %>' CssClass="header-nav" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr><td height="5"></td></tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:DataList runat="server" ID="lv1" DataSourceID="SqlDataSource2" RepeatDirection="Vertical">
                                                    <ItemTemplate>
                                                        <a href='SubCategory.aspx?category_id=<%#Eval("CATEGORY_ID") %>' target="_blank"><%#Eval("DISPLAY_NAME") %></a>
                                                    </ItemTemplate>
                                                </asp:DataList>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ connectionStrings:PIS %>"
                            SelectCommand="SELECT [CATEGORY_ID], [CATEGORY_NAME], [DISPLAY_NAME], [IMAGE_ID], [SEQ_NO], [PARENT_CATEGORY_ID] FROM CATEGORY A WHERE (([PARENT_CATEGORY_ID] = @PARENT_CATEGORY_ID) AND ([ACTIVE_FLG] = @ACTIVE_FLG) AND ([CATEGORY_TYPE] in ('Category','Subcategory') ) ) order by SEQ_NO">
                            <SelectParameters>
                                <asp:Parameter Name="PARENT_CATEGORY_ID" />
                                <asp:Parameter DefaultValue="Y" Name="ACTIVE_FLG" Type="String" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </ItemTemplate>
                </asp:DataList>
                <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:My %>"
                    SelectCommand="SELECT * FROM PIS.dbo.[CATEGORY] where CATEGORY_ID in ('1-2JKJPU','1e2d285b-ec20-470b-a206-4813131e700e') ORDER BY [SEQ_NO]">
                </asp:SqlDataSource>
            </td>
            <td width="5%">
                &nbsp;
            </td>
            <td valign="top" width="35%">
                <asp:DataList runat="server" ID="DataList2" DataSourceID="SqlDataSource3" RepeatDirection="Vertical" CellPadding="10"
                    DataKeyField="Category_ID" OnItemDataBound="DataList2_ItemDataBound">
                    <ItemTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td valign="center">
                                    <a name='<%# Eval("CATEGORY_ID") %>'></a>
                                    <table>
                                        <tr>
                                            <td valign="center" class="title_med">
                                                <asp:Label runat="server" ID="lblCategoryDesc" Text='<%# Eval("DISPLAY_NAME") %>' CssClass="header-nav" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr><td height="5"></td></tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:DataList runat="server" ID="lv2" DataSourceID="SqlDataSource4" RepeatDirection="Vertical">
                                                    <ItemTemplate>
                                                        <a href='SubCategory.aspx?category_id=<%#Eval("CATEGORY_ID") %>' target="_blank"><%#Eval("DISPLAY_NAME") %></a>
                                                    </ItemTemplate>
                                                </asp:DataList>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <asp:SqlDataSource ID="SqlDataSource4" runat="server" ConnectionString="<%$ connectionStrings:PIS %>"
                            SelectCommand="SELECT [CATEGORY_ID], [CATEGORY_NAME], [DISPLAY_NAME], [IMAGE_ID], [SEQ_NO], [PARENT_CATEGORY_ID] FROM CATEGORY A WHERE (([PARENT_CATEGORY_ID] = @PARENT_CATEGORY_ID) AND ([ACTIVE_FLG] = @ACTIVE_FLG) AND ([CATEGORY_TYPE] in ('Category','Subcategory') ) ) order by SEQ_NO">
                            <SelectParameters>
                                <asp:Parameter Name="PARENT_CATEGORY_ID" />
                                <asp:Parameter DefaultValue="Y" Name="ACTIVE_FLG" Type="String" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </ItemTemplate>
                </asp:DataList>
                <asp:SqlDataSource runat="server" ID="SqlDataSource3" ConnectionString="<%$ connectionStrings:My %>"
                    SelectCommand="SELECT * FROM PIS.dbo.[CATEGORY] where CATEGORY_ID in ('1-2MLJWW','ce4163f1-8fa9-407d-9407-1b047023f500','1-2JKQNX') ORDER BY [SEQ_NO],DISPLAY_NAME">
                </asp:SqlDataSource>
            </td>
            <td width="5%">
                &nbsp;
            </td>
            <td valign="top" width="30%">
                <asp:DataList runat="server" ID="DataList3" DataSourceID="SqlDataSource5" RepeatDirection="Vertical" CellPadding="10"
                    DataKeyField="Category_ID" OnItemDataBound="DataList3_ItemDataBound">
                    <ItemTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td valign="center">
                                    <a name='<%# Eval("CATEGORY_ID") %>'></a>
                                    <table>
                                        <tr>
                                            <td valign="center" class="title_med">
                                                <asp:Label runat="server" ID="lblCategoryDesc" Text='<%# Eval("DISPLAY_NAME") %>' CssClass="header-nav" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr><td height="5"></td></tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:DataList runat="server" ID="lv3" DataSourceID="SqlDataSource6" RepeatDirection="Vertical">
                                                    <ItemTemplate>
                                                        <a href='SubCategory.aspx?category_id=<%#Eval("CATEGORY_ID") %>' target="_blank"><%#Eval("DISPLAY_NAME") %></a>
                                                    </ItemTemplate>
                                                </asp:DataList>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <asp:SqlDataSource ID="SqlDataSource6" runat="server" ConnectionString="<%$ connectionStrings:PIS %>"
                            SelectCommand="SELECT [CATEGORY_ID], [CATEGORY_NAME], [DISPLAY_NAME], [IMAGE_ID], [SEQ_NO], [PARENT_CATEGORY_ID] FROM CATEGORY A WHERE (([PARENT_CATEGORY_ID] = @PARENT_CATEGORY_ID) AND ([ACTIVE_FLG] = @ACTIVE_FLG) AND ([CATEGORY_TYPE] in ('Category','Subcategory') ) ) order by SEQ_NO">
                            <SelectParameters>
                                <asp:Parameter Name="PARENT_CATEGORY_ID" />
                                <asp:Parameter DefaultValue="Y" Name="ACTIVE_FLG" Type="String" />
                            </SelectParameters>
                        </asp:SqlDataSource>
                    </ItemTemplate>
                </asp:DataList>
                <asp:SqlDataSource runat="server" ID="SqlDataSource5" ConnectionString="<%$ connectionStrings:My %>"
                    SelectCommand="SELECT * FROM PIS.dbo.[CATEGORY] where CATEGORY_ID in ('Medical_Computing','Digital_Signage_Self-Service','5fb16123-b5bb-40b2-85fa-2ead6fca6427','53730b94-72c2-4ff3-93f1-1f2b997c3bdf') ORDER BY [SEQ_NO],DISPLAY_NAME">
                </asp:SqlDataSource>
            </td>
        </tr>
    </table>
</asp:Content>