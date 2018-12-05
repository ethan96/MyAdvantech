<%@ Control Language="VB" ClassName="PickPartNo" %>

<script runat="server">
    'Dim strObject As String = ""
    Public _strType As String = "", _strPartNO As String = ""
    
    Public Property Type() As String
        Get
            Return _strType
        End Get
        Set(ByVal value As String)
            _strType = value
        End Set
    End Property
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        
    End Sub
    
    Public Sub initialSearch()
        'Me.Global_inc1.ValidationStateCheck()
        _strPartNO = HttpUtility.HtmlEncode(txtPartNo.Text.Trim())
        Dim Block_Select As String = "", strModelNo As String = ""
        'If strObject <> "" And strPartNO <> "" Then
        If HttpUtility.HtmlEncode(txtModelNo.Text.Trim()) <> "" Then
            strModelNo = " and model_no like '%" + txtModelNo.Text + "%' "
        End If
        If _strPartNO <> "" Then
            If _strType.ToUpper = "UPLOADORDER" Then
                'Me.Global_inc1.dbGetDataTable("", "", "select distinct PART_NO, PRODUCT_DESC from product")
                If _strPartNO.Length >= 4 Then
                    Dim i As Integer = 1
                    Dim strWhere As String = " where (a.part_no like '%" & Left(_strPartNO, 4) & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo
                    
                    If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                        Block_Select = " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%' "
                    Else
                        Block_Select = ""
                    End If
                
                    strWhere = strWhere & " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%') " & _
                        " or (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo & " and (a.part_no like 'P-%' or a.part_no like '96*')) " & _
                        Block_Select
                    Me.SqlDataSource1.SelectCommand = "select distinct top 1000 a.PART_NO, PRODUCT_DESC, case (select count(*) from interested_product b where b.part_no=a.part_no and b.userid='" & Session("user_id") & "') when 0 then 'N' Else 'Y' End as IsMyInterest from siebel_product a " & strWhere & " order by a.part_no"
                    ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand     
                Else
                    Dim i As Integer = 1
                    Dim strWhere As String = " where (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo
                    
                    If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                        Block_Select = " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%' "
                    Else
                        Block_Select = ""
                    End If
                
                    strWhere = strWhere & " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%') " & _
                        " or (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo & " and (a.part_no like 'P-%' or a.part_no like '96*')) " & _
                        Block_Select
                    
                    Me.SqlDataSource1.SelectCommand = "select distinct top 1000 a.PART_NO, PRODUCT_DESC, case (select count(*) from interested_product b where b.part_no=a.part_no and b.userid='" & Session("user_id") & "') when 0 then 'N' Else 'Y' End as IsMyInterest from siebel_product a " & strWhere & " order by a.part_no"
                    ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
                End If
            ElseIf _strType.ToUpper = "CTOSCUSTOMER" Then
                If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                    Block_Select = " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%' "
                Else
                    Block_Select = ""
                End If
                
                Dim strWhere As String = " where (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%'" & " and status='A' " & strModelNo
                strWhere = strWhere & " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%') " & _
                     " or (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo & " and (a.part_no like 'P-%' or a.part_no like '96*')) " & _
                     Block_Select
                Me.SqlDataSource1.SelectCommand = "select distinct top 1000 a.PART_NO, PRODUCT_DESC, case (select count(*) from interested_product b where b.part_no=a.part_no and b.userid='" & Session("user_id") & "') when 0 then 'N' Else 'Y' End as IsMyInterest from siebel_product a " & strWhere & " order by a.part_no"
                ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
            ElseIf _strType.ToUpper = "CTOSNOTE" Then
                Me.SqlDataSource1.SelectCommand = "select distinct top 1000 a.PART_NO, PRODUCT_DESC, case (select count(*) from interested_product b where b.part_no=a.part_no and b.userid='" & Session("user_id") & "') when 0 then 'N' Else 'Y' End as IsMyInterest from siebel_product a where a.part_no like 'CTOS-%-N_' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%' " & " and status='A' " & strModelNo & " order by a.part_no"
                ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
            Else
                If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                    Block_Select = " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%' "
                Else
                    Block_Select = ""
                End If
                
                Dim strWhere As String = " where (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%'" & " and status='A' " & strModelNo
                strWhere = strWhere & " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%') " & _
                     " or (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo & " and (a.part_no like 'P-%' or a.part_no like '96*')) " & _
                     Block_Select
                Me.SqlDataSource1.SelectCommand = "select distinct top 1000 a.PART_NO, PRODUCT_DESC, case (select count(*) from interested_product b where b.part_no=a.part_no and b.userid='" & Session("user_id") & "') when 0 then 'N' Else 'Y' End as IsMyInterest from siebel_product a " & strWhere & " and a.STATUS not in ('I','O','S1','L','V') order by a.part_no"
                ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
            End If
        Else
            'Me.Global_inc1.dbGetDataTable("", "", "select distinct PART_NO, PRODUCT_DESC from product")
            If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                Block_Select = " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%' "
            Else
                Block_Select = ""
            End If
                
            Dim strWhere As String = " where (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%'" & " and status='A' " & strModelNo
            If _strType.ToUpper = "CTOSCUSTOMER" Then
                strWhere = strWhere & " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%') " & _
                     " or (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo & " and (a.part_no like 'P-%' or a.part_no like '96*')) " & _
                     Block_Select
            Else
                strWhere = strWhere & " and a.part_no not like 'T-%' and a.part_no not like 'W-%' and a.part_no not like '%-ES' and a.part_no not like 'ES-%') " & _
                     " or (a.part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & HttpUtility.HtmlEncode(txtDesc.Text.Trim()) & "%' " & " and status='A' " & strModelNo & " and (a.part_no like 'P-%' or a.part_no like '96*')) " & _
                     Block_Select
            End If
            Me.SqlDataSource1.SelectCommand = "select distinct top 500 a.PART_NO, PRODUCT_DESC, case (select count(*) from interested_product b where b.part_no=a.part_no and b.userid='" & Session("user_id") & "') when 0 then 'N' Else 'Y' End as IsMyInterest from siebel_product a " & strWhere & " and a.STATUS not in ('I','O','S1','L','V') order by a.part_no"
            ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
        End If
        'Me.Global_inc1.dbGetDataTable("", "", "select distinct PART_NO, PRODUCT_DESC from product")
        'response.write(Me.AdxDatagrid1.xSQL):response.end
        gv1.DataBind()
        'e.Item.Attributes.Add("onclick", "javascript:window.returnValue="+returnVal+";window.close();");
    End Sub
    
    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") = "" Then
            gv1.EmptyDataText = ""
        Else
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
            gv1.EmptyDataText = "No search results were found.<br /> Please try again or submit the feedback form to let us know what you need . "
        End If
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            If UCase(e.Row.Cells(3).Text) = "Y" Then
                CType(CType(e.Row.Cells(5).NamingContainer, GridViewRow).FindControl("lbAdd2Interest"), LinkButton).Text = "Remove From My Interests"
            End If
        End If
        If e.Row.RowType = DataControlRowType.DataRow Or e.Row.RowType = DataControlRowType.Header Then
            e.Row.Cells(3).Visible = False
        End If
    End Sub
    
    Public Event pick(ByVal part_no As String)
    Protected Sub gv1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        RaiseEvent pick(CType(gv1.SelectedRow.FindControl("Link1"), LinkButton).Text)
    End Sub
    
    Public Event update()
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            Call initialSearch()
        Else
            gv1.EmptyDataText = "No search results were found.<br /> Please try again or submit the feedback form to let us know what you need . "
        End If
        RaiseEvent update()
    End Sub

    Protected Sub lbAdd2Interest_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim part_no As String = CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnPartNo3"), HiddenField).Value.ToString()
        Dim IsMyInterest As String = CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnIsMyInterest"), HiddenField).Value.ToString()
        Dim userId As String = Page.User.Identity.Name
        If UCase(IsMyInterest) = "Y" Then
            Dim i As Integer = dbUtil.dbExecuteNoQuery("My", String.Format("delete from interested_product where USERID = '{0}' and part_no = '{1}'", userId, part_no))
            If i > 0 Then
                CType(sender, LinkButton).Text = "Add To My Interests"
            Else
                Util.JSAlert(Page, "Delete Error")
            End If
        Else
            Dim i As Integer = dbUtil.dbExecuteNoQuery("My", String.Format("insert into interested_product (userid,part_no,date) values ('{0}','{1}',getdate())", userId, part_no))
            If i > 0 Then
                CType(sender, LinkButton).Text = "Remove From My Interests"
            Else
                Util.JSAlert(Page, "Insert Error")
            End If
        End If
        CType(sender, LinkButton).DataBind()
    End Sub

    Protected Sub btnAdd2Cart_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Response.Redirect("/order/cart_add2cartline.aspx?part_no=" + CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("hdnPartNo2"), HiddenField).Value.ToString() + "&qty=1")
    End Sub

    Protected Sub lblClass_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim lbl As Label = CType(CType(CType(sender, Label).NamingContainer, GridViewRow).FindControl("lblClass"), Label)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", "select Class from Product where Part_no='" + lbl.Text + "'")
        'If Not IsNothing(dt) And dt.Rows.Count > 0 Then
        '    If dt.Rows(0).Item(0).ToString() = "A" Or dt.Rows(0).Item(0).ToString() = "B" Then
        '        lbl.Text = "<img src='/Images/Hot-orange.gif' />"
        '    Else
        '        lbl.Text = ""
        '    End If
        'Else
        '    lbl.Text = ""
        'End If
    End Sub
    
    Public Event close()
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        RaiseEvent close()
    End Sub
</script>

<div>
        <table width="750" border="0" cellspacing="0" cellpadding="0" bgcolor="f1f2f4" ID="Table1">
            
		    <tr>
		        <td width="100%" align="center">
		            <asp:Panel runat="server" ID="searchPanel" DefaultButton="btnSearch">
		                <table border="0" cellpadding="0" cellspacing="0" width="100%">
		                    <tr>
		                        <td>&nbsp;&nbsp;<asp:label runat="server" ID="lblModelNo" Text="Model NO : " /><asp:TextBox runat="server" ID="txtModelNo" /></td>&nbsp;&nbsp;
		                        <td><asp:label runat="server" ID="lblPartNo" Text="Part NO : " /><asp:TextBox runat="server" ID="txtPartNo" /></td>&nbsp;&nbsp;
		                        <td>
		                            <asp:label runat="server" ID="lblDesc" Text="Description : " />
		                            <asp:TextBox runat="server" ID="txtDesc" />&nbsp;&nbsp;
		                            <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
		                        </td>
		                    </tr>
		                </table>
		            </asp:Panel>
		        </td>
		    </tr>
		   
		    <tr>
			    <!-- ******* center column (start) ********-->
			    <td width="100%" valign="top" align="center">
			        <asp:UpdatePanel runat="server" ID="up3">
	                    <ContentTemplate>
                            <sgv:SmartGridView runat="server" ID="gv1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="10" Width="700" DataKeyNames="PART_NO,IsMyInterest"
	                             EmptyDataRowStyle-Font-Size="Larger" EmptyDataRowStyle-Font-Bold="true" OnRowDataBound="gv1_RowDataBound" Font-Size="Smaller" OnSelectedIndexChanged="gv1_SelectedIndexChanged">
	                            <Columns>
	                                <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                        <headertemplate>
                                            No.
                                        </headertemplate>
                                        <itemtemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </itemtemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Part NO" SortExpression="PART_NO">
                                        <ItemTemplate>
                                            <asp:Linkbutton runat="server" ID="link1" CommandName="Select" Text='<%# Eval("PART_NO") %>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
	                                <asp:BoundField HeaderText="Product Description" DataField="PRODUCT_DESC" ItemStyle-HorizontalAlign="Left" />
	                                <asp:BoundField DataField="IsMyInterest" />
	                                <asp:TemplateField HeaderText="HOT" HeaderStyle-Width="20" Visible="false">
	                                    <ItemTemplate>
	                                        <asp:Label runat="server" ID="lblClass" Text='<%# Eval("PART_NO") %>' OnDataBinding="lblClass_DataBinding" />
	                                    </ItemTemplate>
	                                </asp:TemplateField>
	                                <asp:TemplateField>
	                                    <ItemTemplate>
	                                        <asp:HiddenField runat="server" ID="hdnPartNo3" Value='<%# Eval("PART_NO") %>' />
	                                        <asp:HiddenField runat="server" ID="hdnIsMyInterest" Value='<%# Eval("IsMyInterest") %>' />
        	                            </ItemTemplate>
	                                </asp:TemplateField>
	                                <asp:TemplateField HeaderText="Check Price">
	                                    <ItemTemplate>
	                                        <a href="/Order/QueryPrice.aspx?part_no=<%# Eval("PART_NO") %>" target="_blank"><img src="/Images/btn_check.gif" /></a>
	                                    </ItemTemplate>
	                                </asp:TemplateField>
	                                <asp:TemplateField>
	                                    <ItemTemplate>
	                                        <asp:ImageButton runat="server" ID="btnAdd2Cart" ImageUrl="/Images/btn_add2cart1.gif" OnClick="btnAdd2Cart_Click" />
	                                        <asp:HiddenField runat="server" ID="hdnPartNo2" Value='<%# Eval("PART_NO") %>' />
	                                    </ItemTemplate>
	                                </asp:TemplateField>
	                            </Columns>
	                            
	                            <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
	                        </sgv:SmartGridView>
	                        <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ ConnectionStrings:My %>" SelectCommand="" OnLoad="SqlDataSource1_Load">
	                        </asp:SqlDataSource>
	                    </ContentTemplate>
	                </asp:UpdatePanel>
                 </td>
			   
		    </tr>
		    <tr valign="middle">
			    <td align="center">
				   
				    &nbsp;&nbsp;<font color="red" size="2"><b>*HINT: Input query string then 'Search'. Click 'Part No' to apply.</b></font>
				    <p></p>
				   
			    </td>
		    </tr>
		    
		    <tr>
			    <td width="100%" valign="top" align="center">
			        <asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" />
				</td>
		    </tr>			
	    </table>
</div>
