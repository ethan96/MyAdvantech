<%@ Control Language="VB" ClassName="PickPartNoB2B" %>

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
        _strPartNO = txtPartNo.Text
        Dim Block_Select As String = ""
        'If strObject <> "" And strPartNO <> "" Then
        If _strPartNO <> "" Then
            If _strType.ToUpper = "UPLOADORDER" Then
                'Me.Global_inc1.dbGetDataTable("", "", "select distinct PART_NO, PRODUCT_DESC from product")
                If _strPartNO.Length >= 4 Then
                    Dim i As Integer = 1
                    Dim strWhere As String = " where (part_no like '%" & Left(_strPartNO, 4) & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%'"
                    
                    If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                        Block_Select = " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' "
                    Else
                        Block_Select = ""
                    End If
                
                    strWhere = strWhere & " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                        " or (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%' and (part_no like 'P-%' or part_no like '96*') and IsNull(GENITEMCATGROUP,'1') <> 'ZPTD' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                        Block_Select
                    Me.SqlDataSource1.SelectCommand = "select distinct top 1000 PART_NO, PRODUCT_DESC from product " & strWhere
                    ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
                Else
                    Dim i As Integer = 1
                    Dim strWhere As String = " where (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%'"
                    
                    If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                        Block_Select = " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' "
                    Else
                        Block_Select = ""
                    End If
                
                    strWhere = strWhere & " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                        " or (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%' and (part_no like 'P-%' or part_no like '96*') and IsNull(GENITEMCATGROUP,'1') <> 'ZPTD' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                        Block_Select
                    
                    Me.SqlDataSource1.SelectCommand = "select distinct top 1000 PART_NO, PRODUCT_DESC from product " & strWhere
                    ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
                End If
            ElseIf _strType.ToUpper = "CTOSCUSTOMER" Then
                If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                    Block_Select = " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' "
                Else
                    Block_Select = ""
                End If
                
                Dim strWhere As String = " where (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%'"
                strWhere = strWhere & " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' and product_type = 'ZCTO' and product_type <> 'ZSRV') " & _
                     " or (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%' and (part_no like 'P-%' or part_no like '96*') and IsNull(GENITEMCATGROUP,'1') <> 'ZPTD' and product_type = 'ZCTO' and product_type <> 'ZSRV') " & _
                     Block_Select
                Me.SqlDataSource1.SelectCommand = "select distinct top 1000 PART_NO, PRODUCT_DESC from product " & strWhere
                ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
            ElseIf _strType.ToUpper = "CTOSNOTE" Then
                Me.SqlDataSource1.SelectCommand = "select distinct top 1000 PART_NO, PRODUCT_DESC from product where part_no like 'CTOS-%-N_' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%'"
                ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
            Else
                If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                    Block_Select = " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' "
                Else
                    Block_Select = ""
                End If
                
                Dim strWhere As String = " where (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%'"
                strWhere = strWhere & " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                     " or (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%' and (part_no like 'P-%' or part_no like '96*') and IsNull(GENITEMCATGROUP,'1') <> 'ZPTD' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                     Block_Select
                Me.SqlDataSource1.SelectCommand = "select distinct top 1000 PART_NO, PRODUCT_DESC from product " & strWhere
                ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
            End If
        Else
            'Me.Global_inc1.dbGetDataTable("", "", "select distinct PART_NO, PRODUCT_DESC from product")
            If Not Util.IsAEUIT() And Not Util.IsInternalUser2() Then
                Block_Select = " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' "
            Else
                Block_Select = ""
            End If
                
            Dim strWhere As String = " where (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%'"
            If _strType.ToUpper = "CTOSCUSTOMER" Then
                strWhere = strWhere & " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' and product_type = 'ZCTO' and product_type <> 'ZSRV') " & _
                     " or (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%' and (part_no like 'P-%' or part_no like '96*') and IsNull(GENITEMCATGROUP,'1') <> 'ZPTD' and product_type = 'ZCTO' and product_type <> 'ZSRV') " & _
                     Block_Select
            Else
                strWhere = strWhere & " and part_no not like 'T-%' and part_no not like 'W-%' and part_no not like '%-ES' and part_no not like 'ES-%' and MATERIAL_GROUP<>'T' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                     " or (part_no like '%" & _strPartNO & "%' and PRODUCT_DESC like '%" & Trim(txtDesc.Text) & "%' and (part_no like 'P-%' or part_no like '96*') and IsNull(GENITEMCATGROUP,'1') <> 'ZPTD' and product_type <> 'ZCTO' and product_type <> 'ZSRV') " & _
                     Block_Select
            End If
            Me.SqlDataSource1.SelectCommand = "select distinct PART_NO, PRODUCT_DESC from product " & strWhere
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
        End If
    End Sub
    
    Public Event pick(ByVal part_no As String)
    Protected Sub gv1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        RaiseEvent pick(CType(gv1.SelectedRow.FindControl("Link1"), LinkButton).Text)
    End Sub

    Public Event close()
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        RaiseEvent close()
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
</script>

<div>
        <asp:TextBox runat="server" ID="txtPartNo" Visible="false" />
        <table width="520" height="480" border="0" cellspacing="0" cellpadding="0" bgcolor="f1f2f4" ID="Table1">
		    <tr>
			    <td width="100%" valign="top" align="right" height="10">
				    <asp:LinkButton runat="server" ID="btnClose" Text="Close" OnClick="btnClose_Click" />
			    </td>
		    </tr>
		    <tr>
		        <td width="100%">&nbsp;&nbsp;
		            <asp:Label runat="server" ID="lblDesc" Text="Product Description : " />&nbsp;&nbsp;
		            <asp:TextBox runat="server" ID="txtDesc" />&nbsp;&nbsp;
		            <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
		        </td>
		    </tr>
		    <tr><td width="100%" height="10"></td></tr>
		    <tr>
			    <!-- ******* center column (start) ********-->
			    <td width="100%" height="330" valign="top" align="center">
                    <asp:GridView runat="server" ID="gv1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="20" Width="100%" DataKeyNames="PART_NO"
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
	                    </Columns>
	                    <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                        <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
	                </asp:GridView>
	                <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ ConnectionStrings:B2B %>" SelectCommand="" OnLoad="SqlDataSource1_Load">
	                </asp:SqlDataSource>
                 </td>
			    <!-- ******* center column (end) ********-->
		    </tr>
		    <tr valign="middle">
			    <td align="center">
				    <!-- ******* page title (start) ********-->
				    &nbsp;&nbsp;<font color="red" size="2"><b>*HINT: Click 'Query' to input query string then 'Go'. Click 'Part No' to apply.</b></font>
				    <p></p>
				    <!-- ******* page title (end) ********-->
			    </td>
		    </tr>			
	    </table>
</div>
