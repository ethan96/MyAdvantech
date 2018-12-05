<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Maintain Category List" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString
        If Not Page.IsPostBack Then
            OrderUtilities.SetSessionOrgForCbomEditor(Session("user_id"))
        End If
        If Me.txtCatalogName.Text = "" Then
            Me.txtCatalogName.Text = Request("txtCatalogName")
        Else
            Me.txtCatalogName.Text = Me.txtCatalogName.Text
        End If
        InitialDatagrid(Me.txtSearch.Text.Trim)
    End Sub
    
    Protected Sub InitialDatagrid(ByVal str As String)
        Dim strQuery As String = ""
        'strQuery = "select distinct category_name, category_type,category_desc,'' as WhereUse,'' as Config from CBOM_CATALOG_CATEGORY where category_name like '%" & Me.txtCatalogName.Text.Trim & "%'" & " and (category_type='Category') and (PARENT_CATEGORY_ID = '' or PARENT_CATEGORY_ID = 'root') order by category_name"
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'strQuery = "select distinct category_name, category_type,'' as category_desc,'' as WhereUse,'' as Config,UID,Parent_category_id from CBOM_CATALOG_CATEGORY where org='" & Session("org").ToString.ToUpper & "' and category_name like '%" & str.Replace("'", "''") & "%'" & " and (category_type='Category')  order by category_name"
        'strQuery = "select distinct category_name, category_type,'' as category_desc,'' as WhereUse,'' as Config,UID,Parent_category_id from CBOM_CATALOG_CATEGORY where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_name like '%" & str.Replace("'", "''") & "%'" & " and (category_type='Category')  order by category_name"
        strQuery = "select top 500 * from (select distinct category_name, category_type,'' as category_desc,'' as WhereUse,'' as Config,UID,Parent_category_id from CBOM_CATALOG_CATEGORY where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_name like '%" & str.Replace("'", "''") & "%'" & " and (category_type='Category')) a"
        ViewState("SqlCommand") = ""
        SqlDataSource1.SelectCommand = strQuery
        ViewState("SqlCommand") = SqlDataSource1.SelectCommand
        'Response.Write(strQuery)
        If Not Page.IsPostBack Or Me.Flag.Text = "YES" Then
            Me.Flag.Text = "NO"
            gv1.DataBind()
        End If
    End Sub

    Protected Sub Submit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.txtCatalogName.Text.Trim = "" Then Exit Sub
        Me.Flag.Text = "YES"
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim SQLString As String = "select * from CBOM_CATALOG_CATEGORY where org='" & Session("org").ToString.ToUpper & "' and CATEGORY_ID = " & "'" & Me.txtCatalogName.Text.Trim & "'"
        Dim SQLString As String = "select * from CBOM_CATALOG_CATEGORY where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and CATEGORY_ID = " & "'" & Me.txtCatalogName.Text.Trim & "'"
        Dim ExistDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, SQLString)
        If ExistDT.Rows.Count > 0 Then
            Util.JSAlert(Me.Page, "The Bto has exists!!")
        Else
            'SQLString = "insert into CBOM_CATALOG_CATEGORY(CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, PARENT_CATEGORY_ID,EXTENDED_DESC,org,uid) values(" & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & "Category" & "'," & "'" & "" & "'," & "'" & Me.txtCatalogName.Text.Trim & "','" & Session("org").ToString.ToUpper & "',newid())"
            SQLString = "insert into CBOM_CATALOG_CATEGORY(CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, PARENT_CATEGORY_ID,EXTENDED_DESC,org,uid) values(" & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & "Category" & "'," & "'" & "" & "'," & "'" & Me.txtCatalogName.Text.Trim & "','" & Left(Session("org_id").ToString.ToUpper, 2) & "',newid())"
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, SQLString)
        End If
        'log this aql clause
        SQLString = Replace(SQLString, "'", "''")
        Dim LogString As String = "insert into CbomMaintainLog values('" & Session("user_id") & "','" & _
                    Request.ServerVariables("REMOTE_HOST") & "','" & _
                    System.DateTime.Now & "','" & _
                    Request.ServerVariables("SCRIPT_NAME") & "','" & _
                    SQLString & "')"
        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, LogString)
    End Sub
    
    'Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    ModalPopupExtender1.Hide()
    '    up2.Update()
    'End Sub
    
    'Protected Sub SearchBTO()
    '    Dim strPartNO As String = Trim(txtPartNo.Text)
    '    'strObject = ""
    '    'strObject2 = ""
    '    Dim strQuery As String = ""
    '    strQuery = "select distinct category_id as part_no, category_desc as product_desc, " & _
    '        " category_id from cbom_catalog_category " & _
    '        " where org='" & Session("org").ToString.ToUpper & "' and category_id like '%" & strPartNO & "%' and category_type='Category' order by part_no"
        
    '    ViewState("SqlCommand1") = ""
    '    SqlDataSource2.SelectCommand = strQuery
    '    ViewState("SqlCommand1") = SqlDataSource2.SelectCommand
    'End Sub
    
    'Protected Sub btnPickBTO_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    txtPartNo.Text = Trim(txtCatalogName.Text)
    '    Call SearchBTO()
    '    ModalPopupExtender1.Show()
    '    up2.Update()
    'End Sub

    'Protected Sub SqlDataSource2_Load(ByVal sender As Object, ByVal e As System.EventArgs)
    '    If ViewState("SqlCommand1") <> "" Then SqlDataSource2.SelectCommand = ViewState("SqlCommand1")
    'End Sub

    'Protected Sub btnSearchBTO_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    Call SearchBTO()
    'End Sub

    'Protected Sub btnBTOClick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
    '    txtCatalogName.Text = CType(sender, LinkButton).Text
    '    txtCatalogDesc.Text = CType(CType(sender, LinkButton).NamingContainer, GridViewRow).Cells(2).Text
    '    ModalPopupExtender1.Hide()
    '    up1.Update()
    'End Sub
    

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub



    Protected Sub gv1_RowUpdating(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        Dim OriName As String = CType(Me.gv1.Rows(e.RowIndex).Cells(0).FindControl("txtOriName"), TextBox).Text.Trim
        Dim NewName As String = CType(Me.gv1.Rows(e.RowIndex).Cells(0).FindControl("txtNewName"), TextBox).Text.Trim
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim SqlStr As String = "update cbom_catalog_category set category_id='" & NewName & _
        '                       "',category_name='" & NewName & "' where org='" & Session("org").ToString.ToUpper & "' and category_id='" & OriName & "'"
        Dim SqlStr As String = "update cbom_catalog_category set category_id='" & NewName & _
                               "',category_name='" & NewName & "' where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & OriName & "'"

        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, SqlStr)
        'SqlStr = "update cbom_catalog_category set parent_category_id='" & NewName & "' where org='" & Session("org").ToString.ToUpper & "' and parent_category_id='" & OriName & "'"
        SqlStr = "update cbom_catalog_category set parent_category_id='" & NewName & "' where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and parent_category_id='" & OriName & "'"
        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, SqlStr)
    End Sub

    Protected Sub gv1_RowDeleting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim OriName As String = CType(Me.gv1.Rows(e.RowIndex).Cells(0).FindControl("txtOriName"), TextBox).Text.Trim
        'Dim sqlstr As String = "delete from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and category_id='" & OriName & "'"
        Dim sqlstr As String = "delete from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & OriName & "'"
        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, sqlstr)
        'sqlstr = "delete from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and parent_category_id='" & OriName & "'"
        sqlstr = "delete from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and parent_category_id='" & OriName & "'"
        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, sqlstr)
    End Sub

    Protected Sub Search_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gv1.DataBind()
    End Sub

    Protected Function isAssigned(ByVal str As String) As Boolean
        'Dim sqlstr As String = "select count(category_id) from cbom_catalog_category where org='" & Session("org").ToString.ToUpper & "' and category_id='" & str & "' and PARENT_CATEGORY_ID <> '' and PARENT_CATEGORY_ID <> 'root'"
        Dim sqlstr As String = "select count(category_id) from cbom_catalog_category where org='" & Left(Session("org_id").ToString.ToUpper, 2) & "' and category_id='" & str & "' and PARENT_CATEGORY_ID <> '' and PARENT_CATEGORY_ID <> 'root'"
        Dim oCount As String = dbUtil.dbExecuteScalar(CBOMSetting.DBConn, sqlstr)
        If oCount > 0 Then
            Return True
        End If
        Return False
    End Function
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Not isAssigned(CType(e.Row.Cells(0).FindControl("txtOriName"), TextBox).Text.Trim) Then
                e.Row.Cells(4).Text = "No Assigned"
            End If
        End If
        If e.Row.RowType = DataControlRowType.Pager Then
            e.Row.Attributes.Add("class", "sortbottom")
            e.Row.Cells(0).ColumnSpan = 2
            e.Row.Cells.Add(New TableCell())
            e.Row.Cells.Add(New TableCell())
            e.Row.Cells.Add(New TableCell())
            e.Row.Cells.Add(New TableCell())
            e.Row.Cells.Add(New TableCell())
            e.Row.Cells.Add(New TableCell())
        End If
    End Sub
    
    Protected Sub ibtn_Ex2Ex_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim DT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, ViewState("SqlCommand"))
        Util.DataTable2ExcelDownload(DT, "CBOM_CATEGORY.XLS")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

    <table height="620px" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="top" width="98%">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td><h1>Load Category</h1>
                        </td>
                    </tr>
                    <tr>
                        <td height="6">&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td align="left">
                            <table width="75%" border="0" cellspacing="1" cellpadding="1">
                                <tr>
                                    <td align="center" colspan="2" bgcolor="#b0c4de" height="30">
                                        <b>Load a Category</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>Category&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel">
										<table>
											<tr>
												<td>
                                                 <asp:TextBox runat="server" ID="txtCatalogName" ReadOnly="false" size="15" Width="300"></asp:TextBox>
									                                    <asp:TextBox runat="server" Visible="false" ID="txtCatalogDesc" />

													<%--<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                                        <ContentTemplate>
							                                <table>
								                                <tr>
									                                <td>
										                               
									                                </td>
									                                <td>
										                                <asp:Button runat="server" ID="btnPickBTO" Text="Pick" OnClick="btnPickBTO_Click" />
									                                    <asp:LinkButton runat="server" ID="link1" />
                                                                        <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" PopupControlID="Panel1" 
                                                                                     PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground" />
                                                                        <asp:Panel runat="server" ID="Panel1" style="display:none">
                                                                            <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                                                                <ContentTemplate>
                                                                                    <table width="700" height="480" border="0" cellpadding="0" cellspacing="0" bgcolor="f1f2f4">
                                                                                        <tr><td colspan="2" height="10">&nbsp</td></tr>
                                                                                        <tr>
                                                                                            <td align="right" width="50%">
                                                                                                &nbsp;&nbsp;<font size="2">Part NO : </font><asp:TextBox runat="server" ID="txtPartNo" />
                                                                                            </td>
                                                                                            <td align="left" width="50%">
                                                                                                <asp:Button runat="server" ID="btnSearchBTO" Text="Search" OnClick="btnSearchBTO_Click" />
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr><td colspan="2" height="10">&nbsp</td></tr>
                                                                                        <tr>
                                                                                            <td colspan="2" valign="top" align="center">
                                                                                                <sgv:SmartGridView ShowWhenEmpty="true" runat="server" ID="gv2" DataSourceID="SqlDataSource2" AutoGenerateColumns="false" EnableTheming="false" 
                                                                                                    HeaderStyle-HorizontalAlign="Center" AllowSorting="true" AllowPaging="true" PageSize="50" Width="96%">
                                                                                                    <Columns>
                                                                                                        <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                                                                            <headertemplate>
                                                                                                                No.
                                                                                                            </headertemplate>
                                                                                                            <itemtemplate>
                                                                                                                <%# Container.DataItemIndex + 1 %>
                                                                                                            </itemtemplate>
                                                                                                        </asp:TemplateField>
                                                                                                        <asp:TemplateField HeaderText="Part NO" ItemStyle-Width="300">
                                                                                                            <ItemTemplate>
                                                                                                                <asp:LinkButton runat="server" ID="btnBTOClick" CommandName="Select" Text='<%# Eval("PART_NO") %>' OnClick="btnBTOClick_Click" />
                                                                                                            </ItemTemplate>
                                                                                                        </asp:TemplateField>
                                                                                                        <asp:BoundField HeaderText="Product Description" DataField="PRODUCT_DESC" />
                                                                                                    </Columns>
                                                                                                    <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                                                                                    <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                                                                                    <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                                                                                    <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                                                                                                    <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                                                                                    <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                                                                                    <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                                                                                    <FixRowColumn TableHeight="400" FixRowType="Header" FixColumns="-1" FixRows="-1" />
                                                                                                </sgv:SmartGridView>
                                                                                                <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString="<%$ connectionStrings:B2B %>" 
                                                                                                    SelectCommand="" OnLoad="SqlDataSource2_Load">
                                                                                                </asp:SqlDataSource>
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td align="center" colspan="2"><asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" /></td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </ContentTemplate>
                                                                            </asp:UpdatePanel>
                                                                        </asp:Panel>
									                                </td>
								                                </tr>
							                                </table>
							                            </ContentTemplate>
							                        </asp:UpdatePanel>--%>
												</td>
											</tr>
										</table>
									</td>
                                </tr>                                
                                <tr>
                                    <td colspan="2" bgcolor="#e6e6fa" valign="middle" height="35" align="center">
                                        <asp:Label runat="server" ID="Flag" Text="NO" Visible="false"></asp:Label>
                                        <asp:Button runat="server" ID="Submit" Text="Create" OnClick="Submit_Click" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="6">&nbsp;
                        </td>
                    </tr>
                     <tr>
                        <td height="6">
                            Category : <asp:TextBox runat="server" ID="txtSearch"></asp:TextBox>
                            <asp:Button runat="server" ID="Search" Text="Search" OnClick="Search_Click" />
                            <asp:ImageButton ID="ibtn_Ex2Ex" ImageUrl="~/images/excel.gif" runat="server" OnClick="ibtn_Ex2Ex_Click" />
                        </td>
                    </tr>              
                    <tr>
                        <td width="100%">
                            <asp:GridView class="sortable" ShowWhenEmpty="true" runat="server" ID="gv1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false" 
                                HeaderStyle-HorizontalAlign="Center" AllowSorting="true" AllowPaging="true" PageSize="50" Width="100%" OnRowUpdating="gv1_RowUpdating" OnRowDeleting="gv1_RowDeleting" OnRowDataBound="gv1_RowDataBound">
				                <Columns>
				                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                        <headertemplate>
                                            No.
                                        </headertemplate>
                                        <itemtemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </itemtemplate>
                                    </asp:TemplateField>
                                    
                                  <asp:TemplateField >
                                        <headertemplate>
                                           Category Item
                                        </headertemplate>
                                        <ItemTemplate>
                                        <%#Eval("CATEGORY_NAME")%>
                                        <asp:TextBox runat = "server" ID="txtOriName" Text='<%# eval("CATEGORY_NAME") %>' Visible="false"></asp:TextBox>
                                        </ItemTemplate>
                                        <EditItemTemplate >
                                        <asp:TextBox runat = "server" ID="txtNewName" Text='<%# eval("CATEGORY_NAME") %>' Width="300px"></asp:TextBox>
                                        <asp:TextBox runat = "server" ID="txtOriName" Text='<%# eval("CATEGORY_NAME") %>' Visible="false"></asp:TextBox>
                                        </EditItemTemplate>
                                        </asp:TemplateField>
                                    <asp:BoundField HeaderText="Parent ID" DataField="parent_category_id" readonly="true"/>
                                    <asp:BoundField HeaderText="Category Type" DataField="CATEGORY_TYPE" readonly="true"/>
                                    <asp:BoundField HeaderText="Description" DataField="CATEGORY_DESC" readonly="true"/>
                                    <asp:HyperLinkField HeaderText="Where Use" DataNavigateUrlFields="CATEGORY_NAME" Text="Check" Target="_blank" DataNavigateUrlFormatString="~/product/Compatibility_Search.aspx?key={0}"/>
                                    <asp:HyperLinkField HeaderText="Config" ItemStyle-BackColor="#ffeeaa" ItemStyle-Font-Bold="true"
                                    DataNavigateUrlFields="UID" Text="Maintain"  DataNavigateUrlFormatString="CBOM_Editor.aspx?UID={0}" 
                                    ItemStyle-HorizontalAlign="Center" />
                                    
                                <asp:CommandField ShowEditButton="true" />
                                <asp:CommandField ShowDeleteButton ="true" DeleteText="&lt;div id=&quot;de&quot; onclick=&quot;JavaScript:return confirm('It will remove all references of this category as well,continue?')&quot;&gt;Delete&lt;/div&gt;"/>
                                </Columns>
				                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                <PagerStyle BackColor="#284775" ForeColor="Navy" HorizontalAlign="Justify"  />
                                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" Height="20px" />
                                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                <PagerSettings PageButtonCount="10" Position="Bottom" />
				            </asp:GridView>
				            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:B2B %>" 
				                SelectCommand="" OnLoad="SqlDataSource1_Load" UpdateCommand=" " DeleteCommand=" ">
				            </asp:SqlDataSource>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <SCRIPT src="../includes/tablesort.js" type="text/javascript"></SCRIPT>
</asp:Content>
