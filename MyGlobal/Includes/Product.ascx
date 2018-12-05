<%@ Control Language="VB" ClassName="Product" %>
<%@ OutputCache Duration="7200" VaryByParam="none" %>
<script runat="server">

    Protected Sub DataList1_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs)
        Dim s As SqlDataSource = e.Item.FindControl("SqlDataSource2")
        s.SelectParameters("PARENT_CATEGORY_ID").DefaultValue = e.Item.DataItem("CATEGORY_ID")
    End Sub

    Protected Sub DataList2_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataListItemEventArgs)
        Dim s As SqlDataSource = e.Item.FindControl("SqlDataSource4")
        s.SelectParameters("PARENT_CATEGORY_ID").DefaultValue = e.Item.DataItem("CATEGORY_ID")
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim cnt As Integer = DataBinder.Eval(e.Row.DataItem, "CNT")
            If cnt > 0 Then
                CType(e.Row.Cells(0).FindControl("hl1"), HyperLink).NavigateUrl = "~/Product/Model_Master.aspx?category_id=" + DataBinder.Eval(e.Row.DataItem, "category_id")
                CType(e.Row.Cells(0).FindControl("HyperLink1"), HyperLink).NavigateUrl = "~/Product/Model_Master.aspx?category_id=" + DataBinder.Eval(e.Row.DataItem, "category_id")
            Else
                CType(e.Row.Cells(0).FindControl("hl1"), HyperLink).NavigateUrl = "~/Product/SubCategory.aspx?category_id=" + DataBinder.Eval(e.Row.DataItem, "category_id")
                CType(e.Row.Cells(0).FindControl("HyperLink1"), HyperLink).NavigateUrl = "~/Product/SubCategory.aspx?category_id=" + DataBinder.Eval(e.Row.DataItem, "category_id")
            End If
        End If
    End Sub

    Protected Sub lblImageID_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim imageID As Label = CType(sender, Label)
        If imageID.Text <> "" Then
            Dim imagePath As String = UnzipFileUtil.UnzipImage(imageID.Text)
            imageID.Text = "<img src=""http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + imageID.Text + """ width='50' height='50' border='0' />"
        End If
    End Sub

    Protected Sub lblSubCategoryName_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim subCategoryName As Label = CType(sender, Label)
        Dim sql As String = "select category_id,display_name,category_type, " + _
                            "CNT = (SELECT COUNT(*) FROM CATEGORY B WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y') " + _
                            "from category A where parent_category_id='" + subCategoryName.Text + "' And CATEGORY_TYPE in ('Category','SubCategory') " & _
                            " And ACTIVE_FLG = 'Y' "
        Dim dt As DataTable = dbUtil.dbGetDataTable("PIS", sql)
        If subCategoryName.Text = "1-CYAQBX" Then
            Dim dt1 As DataTable = dbUtil.dbGetDataTable("PIS", String.Format("select category_id,display_name,category_type,cnt=0 from category where parent_category_id='{0}' And ACTIVE_FLG = 'Y'", subCategoryName.Text))
            dt.Merge(dt1)
        End If
        Dim arName As New ArrayList
        If Not IsNothing(dt) And dt.Rows.Count > 0 Then
            subCategoryName.Text = ""
            For i As Integer = 0 To dt.Rows.Count - 1
                'Frank
                
                If dt.Rows(i).Item("category_type") = "Model" Then
                    'arName.Add("<a href='" & Util.GetRuntimeSiteUrl() & "/Product/Model_Detail.aspx?model_no=" + dt.Rows(i).Item("display_name").ToString + "' onmouseover=this.style.color='orange' onmouseout=this.style.color='gray' style='color:gray'>" + dt.Rows(i).Item("display_name").ToString + "</a>")
                    arName.Add("<a href='" & Util.GetRuntimeSiteUrl() & "/Product/Model_Detail.aspx?model_no=" + dt.Rows(i).Item("display_name").ToString + "' onmouseover=this.style.color='orange' onmouseout=this.style.color='gray' style='color:gray'>" + dt.Rows(i).Item("display_name").ToString + "</a>")
                Else
                    If dt.Rows(i).Item("CNT") > 0 Then
                        'arName.Add("<a href='./Product/SubCategory.aspx?category_id=" + dt.Rows(i).Item("category_id").ToString + "' onmouseover=this.style.color='orange' onmouseout=this.style.color='gray' style='color:gray'>" + dt.Rows(i).Item("display_name").ToString + "</a>")
                        arName.Add("<a href='" & Util.GetRuntimeSiteUrl() & "/Product/SubCategory.aspx?category_id=" + dt.Rows(i).Item("category_id").ToString + "' onmouseover=this.style.color='orange' onmouseout=this.style.color='gray' style='color:gray'>" + dt.Rows(i).Item("display_name").ToString + "</a>")
                    Else
                        'arName.Add("<a href='./Product/Model_Master.aspx?category_id=" + dt.Rows(i).Item("category_id").ToString + "' onmouseover=this.style.color='orange' onmouseout=this.style.color='gray' style='color:gray'>" + _
                        arName.Add("<a href='" & Util.GetRuntimeSiteUrl() & "/Product/Model_Master.aspx?category_id=" + dt.Rows(i).Item("category_id").ToString + "' onmouseover=this.style.color='orange' onmouseout=this.style.color='gray' style='color:gray'>" + _
                        dt.Rows(i).Item("display_name").ToString + "</a>")
                    End If
                End If
                
            Next
            subCategoryName.Text = String.Join(" <font color='gray'>|</font> ", arName.ToArray)
        Else
            Dim dtModel As DataTable = dbUtil.dbGetDataTable("PIS", "select a.DISPLAY_NAME from PIS.dbo.Model a inner join PIS.dbo.Category_Model b on a.MODEL_ID=b.model_id where b.Category_id='" + subCategoryName.Text + "'")
            If dtModel.Rows.Count > 0 Then
                For Each row As DataRow In dtModel.Rows
                    arName.Add("<a href='" & Util.GetRuntimeSiteUrl() & "/Product/Model_Detail.aspx?model_no=" + row.Item("display_name").ToString + "' onmouseover=this.style.color='orange' onmouseout=this.style.color='gray' style='color:gray'>" + row.Item("display_name").ToString + "</a>")
                Next
                subCategoryName.Text = String.Join(" <font color='gray'>|</font> ", arName.ToArray)
            End If
        End If
        
    End Sub
    
    Protected Sub ph1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select * from catalog_show order by seq_no")
        'If Not IsNothing(dt) And dt.Rows.Count > 0 Then
        '    For i As Integer = 0 To dt.Rows.Count - 1
        '        Dim hl As New HyperLink
        '        hl.NavigateUrl = "/Product/Product_Line_New.aspx#" + dt.Rows(i).Item("category_id")
        '        hl.Text = "<p><img src='/Images/icon.gif' />  <b>" + dt.Rows(i).Item("catalog_desc") + "</b></p><br/>"
        '        ph1.Controls.Add(hl)
        '    Next
        'End If
    End Sub

    Protected Sub imgIcon_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim li As String = dbUtil.dbExecuteScalar("MY", String.Format("select icon_li from catalog_show where category_id='{0}'", CType(sender, Image).ImageUrl))
        CType(sender, Image).ImageUrl = "../Images/" + li
    End Sub

    Protected Sub imgIcon1_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim li As String = dbUtil.dbExecuteScalar("MY", String.Format("select icon_li from catalog_show where category_id='{0}'", CType(sender, Image).ImageUrl))
        CType(sender, Image).ImageUrl = "../Images/" + li
    End Sub
</script>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td valign="top" width="49%">
            <asp:DataList runat="server" ID="DataList1" DataSourceID="SqlDataSource1" RepeatDirection="Vertical"
                DataKeyField="Category_ID" OnItemDataBound="DataList1_ItemDataBound">
                <ItemTemplate>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td valign="center" class="title_med" bgcolor='<%# Eval("BGCOLOR") %>' width="5">
                            </td>
                            <td valign="center" class="title_med" bgcolor='<%# Eval("BGCOLOR") %>'>
                                <a name='<%# Eval("CATEGORY_ID") %>'></a>
                                <table>
                                    <tr>
                                        <td>
                                            <img src="../Images/<%#Eval("ICON") %>" />
                                        </td>
                                        <td valign="center" class="title_med">
                                            <asp:Label runat="server" ID="lblCategoryDesc" Text='<%# Eval("CATALOG_DESC") %>'
                                                Font-Bold="true" ForeColor="White" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr height="5">
                            <td valign="center" class="title_med" bgcolor='<%# Eval("BGCOLOR") %>' colspan="2">
                            </td>
                        </tr>
                    </table>
                    <asp:GridView runat="server" ID="gv1" DataSourceID="SqlDataSource2" AutoGenerateColumns="false"
                        Width="100%" BorderWidth="0" ShowHeader="false" BackColor="AliceBlue" OnRowDataBound="gv1_RowDataBound"
                        DataKeyNames="CNT,CATEGORY_ID">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <table width="99%" border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="60">
                                                <asp:HyperLink runat="server" ID="hl1">
                                                    <asp:Label runat="server" ID="lblImageID" Text='<%# Eval("IMAGE_ID") %>' OnDataBinding="lblImageID_DataBinding" />
                                                </asp:HyperLink>
                                            </td>
                                            <td>
                                                <asp:Image runat="server" ID="imgIcon" ImageUrl='<%# Eval("PARENT_CATEGORY_ID") %>'
                                                    OnDataBinding="imgIcon_DataBinding" />&nbsp;&nbsp;<asp:HyperLink ID="HyperLink1"
                                                        runat="server" Text='<%# Eval("DISPLAY_NAME") %>' NavigateUrl='<%# Eval("CATEGORY_ID","~/Product/SubCategory.aspx?category_id={0}") %>'
                                                        CssClass="text" Font-Bold="true" ForeColor="#4D79BB"></asp:HyperLink></li>
                                                <br />
                                                <asp:Label runat="server" ID="lblSubCategoryName" Text='<%# Eval("CATEGORY_ID") %>'
                                                    CssClass="text" OnDataBinding="lblSubCategoryName_DataBinding" />
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ connectionStrings:PIS %>"
                        SelectCommand="SELECT [CATEGORY_ID], [CATEGORY_NAME], [DISPLAY_NAME], [IMAGE_ID], [SEQ_NO], [PARENT_CATEGORY_ID], CNT = (SELECT COUNT(*) FROM CATEGORY B WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE = 'Model' And ACTIVE_FLG = 'Y') FROM CATEGORY A WHERE (([PARENT_CATEGORY_ID] = @PARENT_CATEGORY_ID) AND ([ACTIVE_FLG] = @ACTIVE_FLG) AND ([CATEGORY_TYPE] in ('Category','Subcategory') ) ) order by SEQ_NO">
                        <SelectParameters>
                            <asp:Parameter Name="PARENT_CATEGORY_ID" />
                            <asp:Parameter DefaultValue="Y" Name="ACTIVE_FLG" Type="String" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                </ItemTemplate>
            </asp:DataList>
            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:My %>"
                SelectCommand="SELECT * FROM [CATALOG_SHOW] where seq_no in ('1','2','5') ORDER BY [SEQ_NO]">
            </asp:SqlDataSource>
        </td>
        <td width="2%">
            &nbsp;
        </td>
        <td valign="top" width="49%">
            <asp:DataList runat="server" ID="DataList2" DataSourceID="SqlDataSource3" RepeatDirection="Vertical"
                DataKeyField="Category_ID" OnItemDataBound="DataList2_ItemDataBound">
                <ItemTemplate>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td valign="center" class="title_med" bgcolor='<%# Eval("BGCOLOR") %>' width="5">
                            </td>
                            <td valign="center" class="title_med" bgcolor='<%# Eval("BGCOLOR") %>'>
                                <a name='<%# Eval("CATEGORY_ID") %>'></a>
                                <table>
                                    <tr>
                                        <td>
                                            <img src="../Images/<%#Eval("ICON") %>" />
                                        </td>
                                        <td valign="center" class="title_med">
                                            <asp:Label runat="server" ID="lblCategoryDesc2" Text='<%# Eval("CATALOG_DESC") %>'
                                                Font-Bold="true" ForeColor="White" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr height="5">
                            <td valign="center" class="title_med" bgcolor='<%# Eval("BGCOLOR") %>' colspan="2">
                            </td>
                        </tr>
                    </table>
                    <asp:GridView runat="server" ID="gv2" DataSourceID="SqlDataSource4" AutoGenerateColumns="false"
                        Width="100%" DataKeyNames="PARENT_CATEGORY_ID" BorderWidth="0" ShowHeader="false"
                        BackColor="AliceBlue">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <table width="99%" border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="60">
                                                <a href="/Product/SubCategory.aspx?category_id=<%# Eval("CATEGORY_ID") %>">
                                                    <asp:Label runat="server" ID="lblImageID2" Text='<%# Eval("IMAGE_ID") %>' OnDataBinding="lblImageID_DataBinding" />
                                                </a>
                                            </td>
                                            <td>
                                                <asp:Image runat="server" ID="imgIcon1" ImageUrl='<%# Eval("PARENT_CATEGORY_ID") %>'
                                                    OnDataBinding="imgIcon1_DataBinding" />&nbsp;&nbsp;<asp:HyperLink ID="HyperLink12"
                                                        runat="server" Text='<%# Eval("DISPLAY_NAME") %>' NavigateUrl='<%# Eval("CATEGORY_ID","~/Product/SubCategory.aspx?category_id={0}") %>'
                                                        CssClass="text" Font-Bold="true" ForeColor="#4D79BB"></asp:HyperLink></li>
                                                <br />
                                                <asp:Label runat="server" ID="lblSubCategoryName2" Text='<%# Eval("CATEGORY_ID") %>'
                                                    CssClass="text" OnDataBinding="lblSubCategoryName_DataBinding" />
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    <asp:SqlDataSource ID="SqlDataSource4" runat="server" ConnectionString="<%$ connectionStrings:PIS %>"
                        SelectCommand="SELECT [CATEGORY_ID], [CATEGORY_NAME], [DISPLAY_NAME], [IMAGE_ID], [SEQ_NO], [PARENT_CATEGORY_ID] FROM CATEGORY WHERE (([PARENT_CATEGORY_ID] = @PARENT_CATEGORY_ID) AND ([ACTIVE_FLG] = @ACTIVE_FLG) AND ([CATEGORY_TYPE] in ('Category','Subcategory') ) ) order by SEQ_NO">
                        <SelectParameters>
                            <asp:Parameter Name="PARENT_CATEGORY_ID" />
                            <asp:Parameter DefaultValue="Y" Name="ACTIVE_FLG" Type="String" />
                        </SelectParameters>
                    </asp:SqlDataSource>
                </ItemTemplate>
            </asp:DataList>
            <asp:SqlDataSource runat="server" ID="SqlDataSource3" ConnectionString="<%$ connectionStrings:My %>"
                SelectCommand="SELECT * FROM [CATALOG_SHOW] where seq_no in ('3','4','6','7') ORDER BY [SEQ_NO]">
            </asp:SqlDataSource>
        </td>
    </tr>
</table>
