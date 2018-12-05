<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Maintain CBOM List" %>

<script runat="server">
    
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString
        If IsNothing(Session("user_id")) Then
            Response.Redirect("~/home.aspx")
        End If
        If Not Page.IsPostBack Then
            OrderUtilities.SetSessionOrgForCbomEditor(Session("user_id"))
            If Me.txtCatalogName.Text = "" Then
                Me.txtCatalogName.Text = Request("txtCatalogName")
            Else
                Me.txtCatalogName.Text = Me.txtCatalogName.Text
            End If
            InitialDatagrid(Me.txtItem.Text.Trim, Me.txtGroup.Text)
            InitGV2(Me.txtCatalogName.Text.Trim)
        End If
        
    End Sub
    
    Protected Sub InitialDatagrid(ByVal CategoryID As String, ByVal GROUP As String)
        initGV1(CategoryID, GROUP)
       
        
        Me.Flag.Text = "NO"
        gv1.DataBind()
        
    End Sub
    Public Sub initGV1(ByVal PN As String, ByVal GP As String)
        Dim strQuery As String = ""

        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'strQuery = " select isnull(CATALOG_NAME,'') as CATALOG_NAME,CATALOG_TYPE, IMAGE_ID,'' as QTY,'' as Config  " & _
        '           " from CBOM_CATALOG where CATALOG_ORG='" & Session("ORG").ToString.ToUpper & "' AND CATALOG_NAME<>'' " & _
        '           " and catalog_name like '%" & PN.Replace("'", "''") & "%' and catalog_type like '%" & GP.Replace("'", "''") & "%'" & _
        '           " order by CATALOG_NAME asc"
        strQuery = " select isnull(CATALOG_NAME,'') as CATALOG_NAME,CATALOG_TYPE, IMAGE_ID,'' as QTY,'' as Config  " & _
           " from CBOM_CATALOG where CATALOG_ORG='" & Left(Session("ORG_ID").ToString.ToUpper, 2) & "' AND CATALOG_NAME<>'' " & _
           " and catalog_name like '%" & PN.Replace("'", "''") & "%' and catalog_type like '%" & GP.Replace("'", "''") & "%'" & _
           " order by CATALOG_NAME asc"

        
        SqlDataSource1.SelectCommand = strQuery
        ViewState("SqlCommand") = SqlDataSource1.SelectCommand
        'Response.Write(strQuery)
    End Sub
    Protected Sub gv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            e.Row.Cells(3).Text = "<img alt="""" src=""../images/CBOM/" & e.Row.Cells(3).Text & """ width='110' height='100' border=0/>"
        End If
    End Sub

    Protected Sub Submit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.txtCatalogName.Text.Trim = "" Then Exit Sub
        Me.Flag.Text = "YES"
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim SQLString As String = "select * from CBOM_CATALOG_CATEGORY where ORG='" & Session("ORG").ToString.ToUpper & "' AND CATEGORY_ID = " & "'" & Me.txtCatalogName.Text.Trim & "'"
        Dim SQLString As String = "select * from CBOM_CATALOG_CATEGORY where ORG='" & Left(Session("ORG_ID").ToString.ToUpper, 2) & "' AND CATEGORY_ID = " & "'" & Me.txtCatalogName.Text.Trim & "'"
        Dim ExistDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, SQLString)
        If ExistDT.Rows.Count > 0 Then
            ClientScript.RegisterStartupScript(GetType(String), "showSaveMessage", "<script language=""JavaScript"">alert('The BTO root Has existed!!);" & "<" & "/" & "script>")
        Else
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'SQLString = "insert into CBOM_CATALOG_CATEGORY(CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, PARENT_CATEGORY_ID,EXTENDED_DESC,ORG,UID) values(" & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & "Component" & "'," & "'" & "Root" & "'," & "'" & Me.txtCatalogName.Text.Trim & "','" & Session("ORG").ToString.ToUpper & "',NEWID())"
            SQLString = "insert into CBOM_CATALOG_CATEGORY(CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, PARENT_CATEGORY_ID,EXTENDED_DESC,ORG,UID) values(" & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & Me.txtCatalogName.Text.Trim & "'," & "'" & "Component" & "'," & "'" & "Root" & "'," & "'" & Me.txtCatalogName.Text.Trim & "','" & Left(Session("ORG_ID").ToString.ToUpper, 2) & "',NEWID())"
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, SQLString)
            'log this aql clause
            SQLString = Replace(SQLString, "'", "''")
            Dim LogString As String = "insert into CbomMaintainLog values('" & Session("user_id") & "','" & _
                        Request.ServerVariables("REMOTE_HOST") & "','" & _
                        System.DateTime.Now & "','" & _
                        Request.ServerVariables("SCRIPT_NAME") & "','" & _
                        SQLString & "')"
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, LogString)
        End If
    End Sub


    Protected Sub btnConfigClick_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Response.Redirect("/Order/Configurator.aspx?BTOItem=" + CType(CType(sender, ImageButton).NamingContainer, GridViewRow).Cells(1).Text + "&QTY=" + CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("txtQty"), TextBox).Text)
    End Sub
    
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender1.Hide()
        up2.Update()
    End Sub
    Protected Sub InitGV2(ByVal strPartNO As String)
        Dim strQuery As String = ""

        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)

        'strQuery = "select distinct category_name,category_type,category_desc from " & _
        '            "CBOM_CATALOG_CATEGORY where ORG='" & Session("ORG").ToString.ToUpper & "' AND category_name like '" & strPartNO & _
        '            "%'" & " and category_type='Component' and parent_category_id='root' and " & _
        '            "(Category_name like '%BTO' or Category_name like '%CTO%' or ez_flag='1') order by category_name"

        strQuery = "select distinct category_name,category_type,category_desc from " & _
                    "CBOM_CATALOG_CATEGORY where ORG='" & Left(Session("ORG_ID").ToString.ToUpper, 2) & "' AND category_name like '" & strPartNO & _
                    "%'" & " and category_type='Component' and parent_category_id='root' and " & _
                    "(Category_name like '%BTO' or Category_name like '%CTO%' or ez_flag='1') order by category_name"
        'SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString
        SqlDataSource2.SelectCommand = strQuery
        gv2.DataBind()
        'Response.Write(strQuery)
    End Sub
    
    Protected Sub SearchBTO(ByVal pn As String)
        InitGV2(pn)
    End Sub
    
    Protected Sub btnPickBTO_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtBTO.Text = Trim(txtCatalogName.Text)
        Call SearchBTO(Trim(txtCatalogName.Text))
        ModalPopupExtender1.Show()
        up2.Update()
    End Sub

    'Protected Sub SqlDataSource2_Load(ByVal sender As Object, ByVal e As System.EventArgs)
    '    If ViewState("SqlCommand1") <> "" Then SqlDataSource2.SelectCommand = ViewState("SqlCommand1")
    'End Sub

    Protected Sub btnSearchBTO_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Call SearchBTO(Me.txtBTO.Text.Trim)
    End Sub

    Protected Sub btnBTOClick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtCatalogName.Text = CType(sender, LinkButton).Text
        txtCatalogDesc.Text = CType(CType(sender, LinkButton).NamingContainer, GridViewRow).Cells(3).Text
        ModalPopupExtender1.Hide()
        up1.Update()
    End Sub
    
    'Protected Sub gv2_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
    '    If e.Row.RowType = DataControlRowType.DataRow Then
    '        e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
    '        e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
    '    End If
    'End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        initGV1(Me.txtItem.Text.Trim, Me.txtGroup.Text)
        gv1.DataBind()
    End Sub

    Protected Sub ibtn_Ex2Ex_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim DT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, ViewState("SqlCommand"))
        Util.DataTable2ExcelDownload(DT, "CBOM_CATALOG.XLS")
    End Sub

    Protected Sub btnMaintain_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write()
        Dim BTOName As String = CType(sender, Button).CommandArgument.ToString.Trim
        MaintainS(BTOName)
    End Sub

    Sub MaintainS(ByVal BTOName As String)
        If BTOName = "" Then Exit Sub
        Me.Flag.Text = "YES"
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim SQLString As String = "select * from CBOM_CATALOG_CATEGORY where ORG='" & Session("ORG").ToString.ToUpper & "' AND CATEGORY_ID = " & "'" & BTOName & "'"
        Dim SQLString As String = "select * from CBOM_CATALOG_CATEGORY where ORG='" & Left(Session("ORG_ID").ToString.ToUpper, 2) & "' AND CATEGORY_ID = " & "'" & BTOName & "'"
        Dim ExistDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, SQLString)
        If ExistDT.Rows.Count > 0 Then
            Response.Redirect("CBOM_Editor.aspx?BTOItem=" & BTOName)
        Else
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'SQLString = "insert into CBOM_CATALOG_CATEGORY(CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, PARENT_CATEGORY_ID,EXTENDED_DESC,ORG,UID) values(" & "'" & BTOName & "'," & "'" & BTOName & "'," & "'" & "Component" & "'," & "'" & "Root" & "'," & "'" & BTOName & "','" & Session("ORG").ToString.ToUpper & "',NEWID())"
            SQLString = "insert into CBOM_CATALOG_CATEGORY(CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, PARENT_CATEGORY_ID,EXTENDED_DESC,ORG,UID) values(" & "'" & BTOName & "'," & "'" & BTOName & "'," & "'" & "Component" & "'," & "'" & "Root" & "'," & "'" & BTOName & "','" & Left(Session("ORG_ID").ToString.ToUpper, 2) & "',NEWID())"
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, SQLString)
            'log this aql clause
            SQLString = Replace(SQLString, "'", "''")
            Dim LogString As String = "insert into CbomMaintainLog values('" & Session("user_id") & "','" & _
                        Request.ServerVariables("REMOTE_HOST") & "','" & _
                        System.DateTime.Now & "','" & _
                        Request.ServerVariables("SCRIPT_NAME") & "','" & _
                        SQLString & "')"
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, LogString)
            Response.Redirect("CBOM_Editor.aspx?BTOItem=" & BTOName)
        End If
    End Sub

    Protected Sub Maintain_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim BTOName As String = Me.txtCatalogName.Text.Trim
        MaintainS(BTOName)
    End Sub

    Protected Sub gv2_PageIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        InitGV2(Me.txtBTO.Text.Trim)
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table height="620px" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="top" width="98%">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td><h1>Load CBOM</h1>
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
                                        <b>Load a CBOM</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
											<div class="mceLabel"><font color="red">*</font>CBOM BTO item&nbsp;:&nbsp;</div>
									</td>
									<td bgcolor="#e6e6fa" class="mceLabel">
                                    <asp:UpdatePanel ID="up1" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                     <asp:TextBox runat="server" ID="txtCatalogName" ReadOnly="false" size="20"></asp:TextBox>
                                     </ContentTemplate>
                                     </asp:UpdatePanel>
									 <asp:TextBox runat="server" Visible="false" ID="txtCatalogDesc" /> <asp:Button runat="server" ID="btnPickBTO" Text="Pick" OnClick="btnPickBTO_Click" />
						
									                        <asp:LinkButton runat="server" ID="link1" />
                                                            <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" PopupControlID="Panel1" 
                                                                         PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground" />
                                                            <asp:Panel runat="server" ID="Panel1" style="display:none">
                                                             <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                                                    <ContentTemplate>
                                                                        <table width="900" height="480" border="0" cellpadding="0" cellspacing="0" bgcolor="f1f2f4">
                                                                            <tr><td colspan="2" height="10">&nbsp</td></tr>
                                                                            <tr>
                                                                                <td align="right" width="50%">
                                                                                    &nbsp;&nbsp;<font size="2">BTO Item : </font><asp:TextBox runat="server" ID="txtBTO" />
                                                                                </td>
                                                                                <td align="left" width="50%">
                                                                                    <asp:Button runat="server" ID="btnSearchBTO" Text="Search" OnClick="btnSearchBTO_Click" />
                                                                                </td>
                                                                            </tr>
                                                                            <tr><td colspan="2" height="10">&nbsp</td></tr>
                                                                            <tr>
                                                                                <td colspan="2" valign="top" align="center">
                                                                                    <sgv:SmartGridView ShowWhenEmpty="true" runat="server" ID="gv2" DataSourceID="SqlDataSource2" AutoGenerateColumns="false" EnableTheming="false" 
                                                                                        HeaderStyle-HorizontalAlign="Center" AllowSorting="true" AllowPaging="true" PageSize="20" Width="96%" OnPageIndexChanged="gv2_PageIndexChanged">
                                                                                        <Columns>
                                                                                            <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                                                                <headertemplate>
                                                                                                    No.
                                                                                                </headertemplate>
                                                                                                <itemtemplate>
                                                                                                    <%# Container.DataItemIndex + 1 %>
                                                                                                </itemtemplate>
                                                                                            </asp:TemplateField>
                                                                                            <asp:TemplateField HeaderText="BTO Item" ItemStyle-Width="120">
                                                                                                <ItemTemplate>
                                                                                                    <asp:LinkButton runat="server" ID="btnBTOClick" CommandName="Select" Text='<%# Eval("CATEGORY_NAME") %>' OnClick="btnBTOClick_Click" />
                                                                                                </ItemTemplate>
                                                                                            </asp:TemplateField>
                                                                                            <asp:BoundField HeaderText="Type Name" DataField="Category_type" ItemStyle-Width="120px" />
                                                                                            <asp:BoundField HeaderText="Desc" DataField="category_desc" />
                                                                                        </Columns>
                                                                                        <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                                                                        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                                                                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                                                                        <PagerStyle BackColor="#284775" ForeColor="Navy" HorizontalAlign="Justify"  />
                                                                                        <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                                                                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                                                                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                                                                        <FixRowColumn TableHeight="400" FixRowType="Header" FixColumns="-1" FixRows="-1" />
                                                                                    </sgv:SmartGridView>
                                                                                    <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString="<%$ connectionStrings:B2B %>" 
                                                                                        SelectCommand="">
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
                                <tr>
                                    <td align="center" colspan="2" bgcolor="#e6e6fa" valign="middle" height="35">
                                        <asp:Label runat="server" ID="Flag" Text="NO" Visible="false"></asp:Label>
                                        <asp:Button runat="server" ID="Submit" Text="Create" OnClick="Submit_Click" />&nbsp;&nbsp;&nbsp;
                                     <asp:Button runat="server" ID="Maintain" Text="Maintain" OnClick="Maintain_Click" />
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
                        <td height="6">Item : <asp:TextBox runat="server" ID="txtItem"></asp:TextBox>  Group : <asp:TextBox runat="server" ID="txtGroup"></asp:TextBox> 
                            <asp:Button runat="server" Text="Search" ID="btnSearch" OnClick="btnSearch_Click" /> <asp:ImageButton ID="ibtn_Ex2Ex" ImageUrl="~/images/excel.gif" runat="server" OnClick="ibtn_Ex2Ex_Click" />
                        </td>
                    </tr>
                    <tr>
                        <td width="100%">
                            <sgv:SmartGridView ShowWhenEmpty="true" runat="server" ID="gv1" DataSourceID="SqlDataSource1" AutoGenerateColumns="false" 
                                HeaderStyle-HorizontalAlign="Center" AllowSorting="true" AllowPaging="true" PageSize="50" Width="100%" OnRowDataBoundDataRow="gv1_RowDataBoundDataRow" >
				                <Columns>
				                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                        <headertemplate>
                                            No.
                                        </headertemplate>
                                        <itemtemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </itemtemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="BTO Item" DataField="CATALOG_NAME" />
                                    <asp:BoundField HeaderText="Group Description" DataField="CATALOG_TYPE" />
                                    <asp:BoundField HeaderText="Image Name" DataField="IMAGE_ID" ItemStyle-HorizontalAlign="Center" />
                                    <asp:TemplateField HeaderText="QTY" ItemStyle-HorizontalAlign="Right">
                                        <ItemTemplate>
                                            <asp:TextBox runat="server" ID="txtQty" Text="1" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Config" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:ImageButton runat="server" ID="btnConfigClick" ImageUrl="/images/ebiz.aeu.face/btn_config.gif" OnClick="btnConfigClick_Click" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Config" ItemStyle-HorizontalAlign="Center">
                                        <ItemTemplate>
                                            <asp:Button runat="server" Text="Maintain" ID="btnMaintain" CommandArgument ='<%# Eval("CATALOG_NAME") %>' OnClick="btnMaintain_Click" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
				                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                <PagerStyle BackColor="#284775" ForeColor="Navy" HorizontalAlign="Justify"  />
                                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
				            </sgv:SmartGridView>
				            <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:B2B %>" 
				                SelectCommand="" OnLoad="SqlDataSource1_Load">
				            </asp:SqlDataSource>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
