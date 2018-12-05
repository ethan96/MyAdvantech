<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Model Master" EnableEventValidation="false" ValidateRequest="false" %>
<%@ OutputCache Duration="7200" VaryByParam="category_id" %>
<script runat="server">
    
    Private _RunTimeURL As String = Util.GetRuntimeSiteUrl
    Private _Category_ID As String = String.Empty
    
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
        'Dim _Category_ID As String = Trim(Request("Category_ID"))
        _Category_ID = Trim(Request("Category_ID"))
        
        'Dim model As New ProductCategoryUtil_PIS(Request("Category_ID"))
        Dim model As New ProductCategoryUtil_PIS(_Category_ID)
        Lbl_Display_Name.Text = model.DisplayName
        lbl_Extended_Desc.Text = model.Extended_Desc
        'Lbl_Product_Line.Text = model.Product_Line
        ImgCat.ImageUrl = model.Image_Name
        gv1.DataSource = model.dtContent : gv1.DataBind()
        Try
            ''Frank 2012/03/06:Add level 6 category column and change the database form myadvan-global to PIS
            'Dim mdt As DataTable = dbUtil.dbGetDataTable("PIS", _
            '                                         String.Format( _
            '                                         " SELECT top 1 parent_category_id1, category_name1, category_type1, " + _
            '                                         " parent_category_id2, category_name2, category_type2, parent_category_id3,  " + _
            '                                         " category_name3, category_type3, parent_category_id4, category_name4, category_type4,  " + _
            '                                         " parent_category_id5, category_name5, category_type5, parent_category_id6, category_name6, category_type6 " + _
            '                                         " FROM CATEGORY_HIERARCHY " + _
            '                                         " WHERE parent_category_id1='{0}' or parent_category_id2='{0}' or parent_category_id3='{0}' or parent_category_id4='{0}' or parent_category_id5='{0}' or parent_category_id6='{0}' ", Replace(Request("Category_ID"), "'", "''")))
            'If mdt.Rows.Count > 0 Then
            '    Dim mAry As New ArrayList
            '    With mdt.Rows(0)
            '        For i As Integer = 1 To 6
            '            If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value _
            '                AndAlso .Item("parent_category_id" + i.ToString()).ToString() <> "root" Then
            '                Select Case .Item("category_type" + i.ToString())
            '                    Case "Subcategory"
            '                        mAry.Add(String.Format("<a href='" & _RunTimeURL & "/Product/Model_Master.aspx?category_id={0}'>{1}</a>", _
            '                                               .Item("parent_category_id" + i.ToString()), .Item("category_name" + i.ToString())))
            '                    Case "Category"
            '                        mAry.Add(String.Format("<a href='" & _RunTimeURL & "/Product/SubCategory.aspx?category_id={0}'>{1}</a>", _
            '                                               .Item("parent_category_id" + i.ToString()), .Item("category_name" + i.ToString())))
            '                    Case ""
            '                        mAry.Add(String.Format("<a href='" & _RunTimeURL & "/Product/Product_Line_New.aspx'>{0}</a>", .Item("category_name" + i.ToString())))
            '                End Select
                          
            '            Else
            '                If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value _
            '                    AndAlso .Item("parent_category_id" + i.ToString()).ToString() = "root" Then
            '                    mAry.Add(String.Format("<a href='" & _RunTimeURL & "/Product/Product_Line_New.aspx'>Product Lines</a>"))
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

    Protected Sub gv1_RowDataBound(ByVal s As Object, ByVal e As GridViewRowEventArgs) Handles gv1.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
        End If
    End Sub
    
    Protected Sub lblModelNum_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ModelNum As Label = CType(sender, Label)
        Dim strModelId As String = gv1.DataKeys(CType(ModelNum.NamingContainer, GridViewRow).RowIndex).Values("category_id")
        Dim strModelNo As String = gv1.DataKeys(CType(ModelNum.NamingContainer, GridViewRow).RowIndex).Values("display_name")
        Dim strModelType As String = gv1.DataKeys(CType(ModelNum.NamingContainer, GridViewRow).RowIndex).Values("category_type")
        Dim newMark As String = ""
        If Not IsDBNull(gv1.DataKeys(CType(ModelNum.NamingContainer, GridViewRow).RowIndex).Values("new_product_date")) Then
            If gv1.DataKeys(CType(ModelNum.NamingContainer, GridViewRow).RowIndex).Values("new_product_date") >= DateTime.Now() Then
                newMark = "<img src='" & _RunTimeURL & "/images/new2.gif'>"
            End If
        End If
        Select Case strModelType
            Case "Model", "Model ( with Buy Now logo )"
                'Frank 2012/09/13 Model name must to be Url encoded
                ModelNum.Text = "<a href=""Model_Detail.aspx?category_id=" & _Category_ID & "&model_no=" & HttpUtility.UrlEncode(strModelNo) & """>" & strModelNo & "</a>" & newMark
                
            Case "Model ( no product page )"
                ModelNum.Text = strModelNo & newMark
        End Select
    End Sub

    Protected Sub lblDesc_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ModelDesc As Label = CType(sender, Label)
        Dim strProdDesc As String = ""
        If IsDBNull(gv1.DataKeys(CType(ModelDesc.NamingContainer, GridViewRow).RowIndex).Values("entended_desc")) Or IsNothing(gv1.DataKeys(CType(ModelDesc.NamingContainer, GridViewRow).RowIndex).Values("entended_desc")) Then
            If IsDBNull(gv1.DataKeys(CType(ModelDesc.NamingContainer, GridViewRow).RowIndex).Values("product_desc")) Then
                strProdDesc = ""
            Else
                strProdDesc = gv1.DataKeys(CType(ModelDesc.NamingContainer, GridViewRow).RowIndex).Values("product_desc")
            End If
        Else
            strProdDesc = gv1.DataKeys(CType(ModelDesc.NamingContainer, GridViewRow).RowIndex).Values("extended_desc")
        End If
        Dim strModelType As String = gv1.DataKeys(CType(ModelDesc.NamingContainer, GridViewRow).RowIndex).Values("category_type")
        Dim strModelId As String = gv1.DataKeys(CType(ModelDesc.NamingContainer, GridViewRow).RowIndex).Values("category_id")
        ModelDesc.Text = strProdDesc
    End Sub

</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr><td><asp:Label ID="Lbl_Product_Line" runat="server" Text=""></asp:Label></td></tr>
	    <tr>
		    <td>
			    <table width="100%" cellpadding="4" cellspacing="0" border="0">
				    <tr>
					    <td width="84" valign="top" runat="server" id="TdCat1">
						    <asp:Image ID="ImgCat" runat="server" Height="80" Width="80" />
					    </td>
					    <td class="text" valign="top"><asp:Label ID="Lbl_Display_Name" runat="server" Text="" CssClass="title_med" ForeColor="blue"></asp:Label><br />
						    <asp:Label ID="lbl_Extended_Desc" runat="server" Text="" CssClass="text"></asp:Label>
					    </td>
				    </tr>
			    </table>
            </td>
        </tr>
        <tr>
		    <td valign="top">
			    <table width="100%" border="0" cellspacing="0" cellpadding="0">
				    <tr> 
					    <td>
					        <asp:GridView runat="server" ID="gv1" AlternatingRowStyle-BackColor="AliceBlue" AutoGenerateColumns="false" DataKeyNames="category_id,category_type,display_name,product_desc,extended_desc,new_product_date" Width="100%">
					            <Columns>
					                <asp:TemplateField HeaderText="Model Number" HeaderStyle-Width="25%" ItemStyle-Height="30">
					                    <ItemTemplate>
					                        <asp:Label runat="server" ID="lblModelNum" OnDataBinding="lblModelNum_DataBinding" />
					                    </ItemTemplate>
					                </asp:TemplateField>
					                <asp:TemplateField HeaderText="Description" HeaderStyle-Width="75%">
					                    <ItemTemplate>
					                        <asp:Label runat="server" ID="lblDesc" OnDataBinding="lblDesc_DataBinding" />
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