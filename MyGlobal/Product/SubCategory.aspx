<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Sub Category" %>
<%@ OutputCache Duration="7200" VaryByParam="category_id" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim _Category_ID As String = Trim(Request("Category_ID"))
        Dim sub_category As New ProductCategoryUtil_PIS(_Category_ID)
        Lbl_Display_Name.Text = sub_category.DisplayName
        lbl_Extended_Desc.Text = sub_category.Extended_Desc
        'Lbl_Product_Line.Text = sub_category.Product_Line

        'Redirect if necessary
        For Each item As DataRow In sub_category.dtContent.Rows
            If item.Item("CNT") = 0 And item.Item("CNT1") = 0 Then
                Response.Redirect("/Product/Model_Master.aspx?Category_ID=" + _Category_ID)
            End If
        Next

        gv1.DataSource = sub_category.dtContent : gv1.DataBind()
        Try

            'Dim mdt As DataTable = dbUtil.dbGetDataTable("PIS", _
            '                                         String.Format( _
            '                                         " SELECT top 1 parent_category_id2, category_name2, category_type2, parent_category_id3,  " + _
            '                                         " category_name3, category_type3, parent_category_id4, category_name4, category_type4,  " + _
            '                                         " parent_category_id5, category_name5, category_type5, parent_category_id6 " + _
            '                                         " FROM CATEGORY_HIERARCHY " + _
            '                                         " WHERE parent_category_id2='{0}' or parent_category_id3='{0}' or parent_category_id4='{0}' or parent_category_id5='{0}' or parent_category_id6='{0}' ", Replace(Request("Category_ID"), "'", "''")))
            'If mdt.Rows.Count > 0 Then
            '    Dim mAry As New ArrayList
            '    With mdt.Rows(0)
            '        For i As Integer = 2 To 6
            '            If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value _
            '                AndAlso .Item("parent_category_id" + i.ToString()).ToString() <> "root" Then
            '                Select Case .Item("category_type" + i.ToString())
            '                    Case "Subcategory"
            '                        mAry.Add(String.Format("<a href='" & Util.GetRuntimeSiteUrl & "/Product/Model_Master.aspx?category_id={0}'>{1}</a>", _
            '                                               .Item("parent_category_id" + i.ToString()), .Item("category_name" + i.ToString())))
            '                    Case "Category"
            '                        mAry.Add(String.Format("<a href='" & Util.GetRuntimeSiteUrl & "/Product/SubCategory.aspx?category_id={0}'>{1}</a>", _
            '                                               .Item("parent_category_id" + i.ToString()), .Item("category_name" + i.ToString())))
            '                    Case ""
            '                        mAry.Add(String.Format("<a href='" & Util.GetRuntimeSiteUrl & "/Product/Product_Line_New.aspx'>{0}</a>", .Item("category_name" + i.ToString())))
            '                End Select

            '            Else
            '                If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value _
            '                    AndAlso .Item("parent_category_id" + i.ToString()).ToString() = "root" Then
            '                    mAry.Add(String.Format("<a href='" & Util.GetRuntimeSiteUrl & "/Product/Product_Line_New.aspx'>Product Lines</a>"))
            '                    Exit For
            '                End If
            '            End If
            '        Next
            '        If mAry.Count > 0 Then
            '            For i As Integer = 0 To mAry.Count - 1
            '                Lbl_Product_Line.Text += mAry.Item(mAry.Count - i - 1)
            '                If i < mAry.Count - 1 Then
            '                    Lbl_Product_Line.Text += " > "
            '                End If
            '            Next
            '        End If

            '    End With
            'End If

            Dim _LinkStr As String = PISDAL.GetCurrentProductNavigatePath(PISDAL.CurrentProductItemType.category, _Category_ID)
            Lbl_Product_Line.Text = _LinkStr

        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw", "ebusiness.aeu@advantech.eu", "global MA load prod hierarchy failed for " + Request("Category_ID"), ex.ToString(), False, "", "")
        End Try
    End Sub

    Protected Sub lblImageID_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim imageID As Label = CType(sender, Label)
        Dim Image_Id As String = gv1.DataKeys(CType(imageID.NamingContainer, GridViewRow).RowIndex).Values("image_id")
        'Dim imagePath As String = UnzipFileUtil.UnzipImage(Image_Id)
        Dim category_id As String = gv1.DataKeys(CType(imageID.NamingContainer, GridViewRow).RowIndex).Values("category_id")
        If Image_Id <> "" Then
            If gv1.DataKeys(CType(imageID.NamingContainer, GridViewRow).RowIndex).Values(4) > 0 Then
                imageID.Text = "<a href='" & Util.GetRuntimeSiteUrl & "/Product/SubCategory.aspx?Category_ID=" + category_id + "'><img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + Image_Id + "' width='50' height='50' border='0' /></a>"
            Else
                imageID.Text = "<a href='" & Util.GetRuntimeSiteUrl & "/Product/Model_Master.aspx?Category_ID=" + category_id + "'><img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + Image_Id + "' width='50' height='50' border='0' /></a>"
            End If
        Else
            imageID.Text = "<img src='" & Util.GetRuntimeSiteUrl & "/Images/clear.gif' width='50' height='50' border='0' />"
        End If
    End Sub

    Protected Sub hlCatName_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim hlName As HyperLink = CType(sender, HyperLink)
        Dim strCategoryID As String = gv1.DataKeys(CType(hlName.NamingContainer, GridViewRow).RowIndex).Values(1)
        Dim strCategoryName As String = gv1.DataKeys(CType(hlName.NamingContainer, GridViewRow).RowIndex).Values(2)
        If gv1.DataKeys(CType(hlName.NamingContainer, GridViewRow).RowIndex).Values(4) > 0 Then
            hlName.NavigateUrl = "~/Product/SubCategory.aspx?Category_ID=" & strCategoryID
        Else
            If gv1.DataKeys(CType(hlName.NamingContainer, GridViewRow).RowIndex).Values(5) > 0 Then
                hlName.NavigateUrl = "~/Product/Model_Master.aspx?Category_ID=" & strCategoryID
            End If
        End If
        hlName.Text = strCategoryName
    End Sub

    Protected Sub lblCatDesc_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim lblDesc As Label = CType(sender, Label)
        Dim strCategoryDesc As String = gv1.DataKeys(CType(lblDesc.NamingContainer, GridViewRow).RowIndex).Values(3)
        lblDesc.Text = strCategoryDesc
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td>
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
	                <tr><td><asp:Label ID="Lbl_Product_Line" runat="server" Text=""></asp:Label></td></tr>
	                <tr><td height=10></td></tr>
	                <tr>
		                <td>
			                <table width="100%" border="0" cellspacing="0" cellpadding="0">
				                <tr>
					                <td bgcolor="EEEEEE">
						                <asp:Label ID="Lbl_Display_Name" runat="server" ForeColor="#114B9F" Font-Bold="true" Font-Size="X-Large"></asp:Label>
					                </td>
				                </tr>
			                </table>
		                </td>
	                </tr>
                </table>
                <table width="100%" cellpadding="4" cellspacing="0" border="0" bgcolor="EEEEEE">
	                <tr><td class="text"><asp:Label ID="lbl_Extended_Desc" runat="server" Text=""></asp:Label></td></tr>
                </table>
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td>
                            <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" Width="100%" BorderWidth="0" DataKeyNames="image_id,category_id,display_name,extended_desc,cnt,cnt1">
                                <Columns>
                                    <asp:TemplateField>
                                        <ItemTemplate>
                                            <table>
                                                <tr>
                                                    <td><asp:Label runat="server" ID="lblImageID" OnDataBinding="lblImageID_DataBinding" /></td>
                                                    <td>
                                                        <asp:HyperLink runat="server" ID="hlCatName" OnDataBinding="hlCatName_DataBinding" /><br />
                                                        <asp:Label runat="server" ID="lblCatDesc" OnDataBinding="lblCatDesc_DataBinding" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    
</asp:Content>