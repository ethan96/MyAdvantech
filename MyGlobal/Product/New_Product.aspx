<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech New Product Highlight"%>

<script runat="server">
    Protected Sub lblImageID_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim imageID As Label = CType(sender, Label)
        Dim IMG_Dt As DataTable = _
        dbUtil.dbGetDataTable("My", _
        " Select TUMBNAIL_IMAGE_ID from SIEBEL_PRODUCT WHERE PART_NO = '" & imageID.Text & "'")

        If IsNothing(IMG_Dt) OrElse IMG_Dt.Rows.Count = 0 Then
            IMG_Dt = _
            dbUtil.dbGetDataTable("My", _
            " Select IsNull(TUMBNAIL_IMAGE_ID, '') as TUMBNAIL_IMAGE_ID from SIEBEL_PRODUCT WHERE PART_NO = '" & imageID.Text & "' ")
        End If
        
        If Not IsNothing(IMG_Dt) AndAlso IMG_Dt.Rows.Count > 0 Then
            If imageID.Text <> "" Then
                Dim LitUrl As String = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" & IMG_Dt.Rows(0).Item("TUMBNAIL_IMAGE_ID").ToString()
                'Dim imagePath As String = UnzipFileUtil.UnzipImage(IMG_Dt.Rows(0).Item("TUMBNAIL_IMAGE_ID").ToString())
                'imageID.Text = "<img src='" + ConfigurationManager.AppSettings("MyAdvantech") + "/SiebelImage.aspx?ID=" + imagePath + "' width='50' height='50' border='0' />"
                imageID.Text = "<img src='" + LitUrl + "' width='50' height='50' border='0' />"
            End If
        End If
        
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        > New Product</div>
    <table border="0" cellspacing="0" cellpadding="0" style="width: 600px">
		<tr valign="middle">
			<td class="title_big">
				<br/>
				&nbsp;&nbsp;<font size="4">New&nbsp;Product&nbsp;Highlight</font>&nbsp;&nbsp;&nbsp;
				<p>&nbsp;</p>
			</td>
		</tr>
	</table>
	<table border="0" cellpadding="0" cellspacing="0" style="width: 600px">
	    <tr>
	        <td>&nbsp;&nbsp;</td>
	        <td>
	            <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" DataSourceID="SqlDataSource1" EnableTheming="false" BorderWidth="0" BorderColor="White">
	                <Columns>
	                    <asp:TemplateField>
	                        <ItemTemplate>
	                            <ajaxToolkit:CollapsiblePanelExtender ID="cpe" runat="Server"
                                    TargetControlID="PanelContent" ExpandControlID="PanelHeader" CollapseControlID="PanelHeader" 
                                    CollapsedSize="0" Collapsed="False" ImageControlID="FoldImg" TextLabelID="FoldLabel" ScrollContents="false"              
                                    ExpandedImage="/Images/up_arrow_s.jpg" SuppressPostBack="true"
                                    CollapsedImage="/Images/down_arrow_s.jpg" ExpandDirection="Vertical" /> 
                                <asp:Panel runat="server" ID="PanelHeader" Width="100%">
                                    <asp:Image runat="server" ID="FoldImg" ImageUrl="/Images/down_arrow_s.jpg" 
                                        Width="17px" Height="16px" AlternateText="expand" onmouseover="this.style.cursor='hand'"/> 
                                    <asp:Label runat="server" ID="FoldLabel" Text='<%# Eval("Catalog_Desc") %>' Font-Size="Medium" Font-Bold="true" />  
                                    <asp:Label runat="server" ID="lblCategory" Text='<%# Eval("Category_ID") %>' visible="false" />
                                </asp:Panel>
	                            <asp:Panel runat="server" ID="PanelContent" Width="100%">
	                                <asp:GridView runat="server" ID="gv2" DataSourceID="SqlDataSource2" AutoGenerateColumns="false" EnableTheming="false" BorderWidth="0" BorderColor="White">
	                                    <Columns>
	                                        <asp:TemplateField>
	                                            <ItemTemplate>
	                                                <table border="0" cellpadding="0" cellspacing="0" width="100%">
	                                                    <tr>
	                                                        <td width="60" valign="top">
	                                                            <a href='<%# Eval("DISPLAY_NAME","/Product/Model_Detail.aspx?model_no={0}") %>'>
	                                                                <%--<asp:Label runat="server" ID="lblImageID" Text='<%# Eval("DISPLAY_NAME") %>' OnDataBinding="lblImageID_DataBinding" />--%>
                                                                    <img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=<%#Eval("TUMBNAIL_IMAGE_ID") %>' width='50' height='50' border='0' />
	                                                            </a>
	                                                        </td>
	                                                        <td align="left" width="85%"><asp:HyperLink runat="server" ID="hl1" NavigateUrl='<%# Eval("DISPLAY_NAME","~/Product/Model_Detail.aspx?model_no={0}") %>' Text='<%# Eval("DISPLAY_NAME") %>' />
	                                                            <br />
	                                                            <asp:Label runat="server" ID="lbl1" Text='<%# Eval("PRODUCT_DESC") %>' />
	                                                        </td>
	                                                        <td><asp:HyperLink runat="server" ID="hl2" NavigateUrl='<%# Eval("DISPLAY_NAME","~/Product/Model_Detail.aspx?model_no={0}") %>' ImageUrl="~/Images/new2.gif" /></td>
	                                                    </tr>
	                                                    <tr><td colspan="3"><hr /></td></tr>
	                                                </table>
	                                            </ItemTemplate>
	                                        </asp:TemplateField>
	                                    </Columns>
	                                </asp:GridView>
	                                <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString="<%$ connectionStrings:PIS %>" 
	                                    SelectCommand="SELECT distinct a.MODEL_ID as MODEL_CATEGORY_ID,a.MODEL_NAME as display_name, PRODUCT_DESC = isnull(a.EXTENDED_DESC,a.MODEL_DESC),isnull(e.LITERATURE_ID,'') as TUMBNAIL_IMAGE_ID FROM model a left join Category_HIERARCHY c on c.model_no=a.MODEL_NAME left join Model_lit d on a.MODEL_NAME=d.model_name left join LITERATURE e on d.literature_id=e.LITERATURE_ID WHERE (parent_category_id1=@category_id or parent_category_id2=@category_id or parent_category_id3=@category_id or parent_category_id4=@category_id or parent_category_id5=@category_id or parent_category_id6=@category_id) And (a.created >=getdate()-90 or a.LAST_UPDATED >= getdate()-90) and e.LIT_TYPE='Product - Photo(Main)'">
	                                    <SelectParameters>
	                                        <asp:ControlParameter ControlID="lblCategory" Name="category_id" PropertyName="text" Type="String" />
	                                    </SelectParameters>
	                                </asp:SqlDataSource>
	                            </asp:Panel>
	                            <br />
	                        </ItemTemplate>
	                    </asp:TemplateField>
	                </Columns>
	            </asp:GridView>
	            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:My %>" 
	                SelectCommand="select * from catalog_show order by SEQ_NO">
	            </asp:SqlDataSource>
	        </td>
	    </tr>
	</table>
</asp:Content>