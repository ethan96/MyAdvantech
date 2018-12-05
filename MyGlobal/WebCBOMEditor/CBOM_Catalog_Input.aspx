<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="Maintain CBOM List" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'If Not Page.IsPostBack Then
        '    OrderUtilities.SetSessionOrgForCbomEditor(Session("user_id"))
        'End If
        SqlDataSource2.ConnectionString = ConfigurationManager.ConnectionStrings(CBOMSetting.DBConn).ConnectionString
        If Me.txtCatalogName.Text = "" Then
            Me.txtCatalogName.Text = Request("txtCatalogName")
        Else
            Me.txtCatalogName.Text = Me.txtCatalogName.Text
        End If
        If Not Page.IsPostBack Then
            If Me.txtCatalogName.Text <> "" Then
                Dim xDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, "Select Distinct CATALOG_NAME,CATALOG_TYPE,CATALOG_DESC from CBOM_CATALOG where CATALOG_org='" & Left(Session("Org_id").ToString.ToUpper, 2) & "' AND CATALOG_NAME='" & Me.txtCatalogName.Text & "'")
                If xDT.Rows.Count > 0 Then
                    Me.txtGroupName.Text = xDT.Rows(0).Item("CATALOG_TYPE")
                    Me.txtCatalogDesc.Text = xDT.Rows(0).Item("CATALOG_DESC")
                Else
                End If
            End If
    
        End If

    End Sub
    Protected Sub Register_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim _org As String = Left(Session("Org_id").ToString.ToUpper, 2)
        If Me.chbxCopy.Checked = True Then
            Dim mystrSql As String = ""
            Dim mydt As New DataTable
            If Me.txtCopy.Text.Trim() = "" Then
                Glob.ShowInfo("Please input an BTO item.")
                Return
            End If
            mystrSql = "select * from cbom_catalog where CATALOG_org='" & _org & "' and catalog_id = '" & Me.txtCopy.Text.Trim() & "'"
            mydt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, mystrSql)
            If mydt.Rows.Count = 0 Then
                Glob.ShowInfo(Me.txtCopy.Text.Trim() & " dose not exist.")
                Return
            End If
            mystrSql = "select * from  cbom_catalog where CATALOG_org='" & _org & "' and catalog_id ='" & Me.txtCatalogName.Text.Trim() & "'"
            mydt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, mystrSql)
            If mydt.Rows.Count > 0 Then
                Glob.ShowInfo(Me.txtCatalogName.Text.Trim() & " already exists, can not overwrite it.")
                Return
            End If
            mystrSql = "select * from cbom_catalog_category where org='" & _org & "' and parent_category_id = '" & Me.txtCopy.Text.Trim() & "'"
            mydt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, mystrSql)
        
            If mydt.Rows.Count = 0 Then
                Glob.ShowInfo("Database error, please contact administrator!!")
                Return
            End If
        
            mystrSql = "delete from cbom_catalog_category where org='" & _org & "' and parent_category_id = '" & Me.txtCatalogName.Text.Trim() & "'"
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, mystrSql)
            mystrSql = "INSERT INTO CBOM_CATALOG_CATEGORY " & _
           "(CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, CATALOG_ID, CATEGORY_DESC, DISPLAY_NAME, IMAGE_ID, EXTENDED_DESC, CREATED, " & _
           "CREATED_BY, LAST_UPDATED, LAST_UPDATED_BY, SEQ_NO, PUBLISH_STATUS, DEFAULT_FLAG, CONFIGURATION_RULE, " & _
           "NOT_EXPAND_CATEGORY, SHOW_HIDE, EZ_FLAG, PARENT_CATEGORY_ID,org, uid) " & _
           "SELECT CATEGORY_ID, CATEGORY_NAME, CATEGORY_TYPE, CATALOG_ID, CATEGORY_DESC, DISPLAY_NAME, IMAGE_ID, EXTENDED_DESC, CREATED, " & _
           "'" & Session("user_id") & "' AS CREATED_BY, LAST_UPDATED, LAST_UPDATED_BY, SEQ_NO, PUBLISH_STATUS, DEFAULT_FLAG, CONFIGURATION_RULE, " & _
           "NOT_EXPAND_CATEGORY, SHOW_HIDE, 0, '" & Me.txtCatalogName.Text.Trim() & "' AS PARENT_CATEGORY_ID, '" & _org & "' as org, newid() as uid " & _
           "FROM CBOM_CATALOG_CATEGORY AS CBOM_CATALOG_CATEGORY_1 " & _
           "WHERE (PARENT_CATEGORY_ID = '" & Me.txtCopy.Text.Trim() & "') "

            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, mystrSql)
            
        End If
        
        Dim strExistSQL As String = ""
        'strExistSQL = "select * from CBOM_CATALOG where CATALOG_org='" & Session("Org").ToString.ToUpper & "' AND catalog_name ='" & Me.txtCatalogName.Text.Trim & "' and catalog_type='" & Me.txtGroupName.Text.Trim & "'"
        strExistSQL = "select * from CBOM_CATALOG where CATALOG_org='" & _org & "' AND catalog_name ='" & Me.txtCatalogName.Text.Trim & "' and catalog_type='" & Me.txtGroupName.Text.Trim & "'"
        Dim ExistDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, strExistSQL)
        Dim strSqlCmd As String = ""
        Dim ImageName As String = ""
        Dim ImgID As String = InsertImg()
        If ExistDT.Rows.Count < 1 Then
            strSqlCmd = "insert into CBOM_CATALOG " & _
              "(CATALOG_ID,CATALOG_NAME,CATALOG_TYPE,CATALOG_ORG,CATALOG_DESC,CREATED,CREATED_BY,IMAGE_ID,UID) " & _
              "values(" & _
              "'" & UCase(Me.txtCatalogName.Text.Trim).Replace("'", "''") & "'," & _
              "'" & UCase(Me.txtCatalogName.Text.Trim).Replace("'", "''") & "'," & _
              "'" & Trim(Me.txtGroupName.Text.Trim).Replace("'", "''") & "'," & _
              "'" & _org & "'," & _
              "'" & Trim(Me.txtCatalogDesc.Text.Trim).Replace("'", "''") & "'," & _
              "getdate()" & "," & _
              "'" & Session("USER_ID") & "'," & _
              "'" & UCase(ImgID) & "',NEWID())"

            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, strSqlCmd)
            gv1.DataBind()
        Else
      
            strSqlCmd = "Update CBOM_CATALOG Set " & _
                          "CATALOG_TYPE = '" & Me.txtGroupName.Text.Trim & "'," & _
                          "CATALOG_DESC = '" & Me.txtCatalogDesc.Text.Trim & "'," & _
                          "CREATED = getdate()," & _
                          "CREATED_BY = '" & Session("USER_ID") & "'," & _
                          "IMAGE_ID = '" & ImgID & "' " & _
                          "Where catalog_name ='" & Me.txtCatalogName.Text.Trim & "' and catalog_type='" & Me.txtGroupName.Text.Trim & "'"
       
            dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, strSqlCmd)
            gv1.DataBind()
        End If
        'log this aql clause
        strSqlCmd = Replace(strSqlCmd, "'", "''")
        Dim LogString As String = "insert into CbomMaintainLog values('" & Session("user_id") & "','" & _
                    Request.ServerVariables("REMOTE_HOST") & "','" & _
                    System.DateTime.Now & "','" & _
                    Request.ServerVariables("SCRIPT_NAME") & "','" & _
                    strSqlCmd & "')"
        dbUtil.dbExecuteNoQuery(CBOMSetting.DBConn, LogString)
    End Sub
    Private Function InsertImg() As String
        If Me.UploadImage.FileName <> "" Then
            Dim filedatastream As IO.Stream = UploadImage.PostedFile.InputStream
            Dim filelength As Integer = UploadImage.PostedFile.ContentLength
            Dim strFile_Size As String = UploadImage.FileBytes.Length()
            Dim fileData(filelength) As Byte
            filedatastream.Read(fileData, 0, filelength)
    
            Dim newrowid As String = Util.NewRowId("CBOM_CATALOG_IMAGES", CBOMSetting.DBConn)
            Dim sql As String = "INSERT INTO CBOM_CATALOG_IMAGES ([ROW_ID],[IMG_DATA],[LAST_UPDATED],[LAST_UPDATED_BY]) " _
                                & " VALUES ( '" + newrowid + "',@img,getdate(),'" + User.Identity.Name + "')"
            Dim img As New SqlClient.SqlParameter("img", SqlDbType.VarBinary)
            img.Value = fileData 'System.IO.File.ReadAllBytes(fileData)
            Dim paras() As SqlClient.SqlParameter = {img}
            Dim retInt As Integer = dbUtil.dbExecuteNoQuery2(CBOMSetting.DBConn, sql, paras)
            If retInt > 0 Then
                'System.IO.File.Delete(imgPath)
                Return newrowid
            End If
        End If
        Return ""
    End Function
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender1.Hide()
        up2.Update()
    End Sub

    Protected Sub SearchBTO()
        Dim strPartNO As String = Trim(txtBTO.Text)
        Dim strQuery As String = ""
        Dim strQuery1 As String = ""
        Dim strQuery2 As String = ""
        strQuery1 = "select distinct CATALOG_NAME as CATEGORY_Name,CATALOG_TYPE as Category_type,CATALOG_DESC as Extended_desc from CBOM_CATALOG where CATALOG_org='" & Left(Session("Org_id").ToString.ToUpper, 2) & "' AND (CATALOG_NAME like '%-BTO' or CATALOG_NAME like '%CTO%') and CATALOG_NAME like '%" & strPartNO & "%' "
        strQuery = strQuery1 & " order by CATEGORY_Name "

        ViewState("SqlCommand1") = ""
        
        SqlDataSource2.SelectCommand = strQuery
        ViewState("SqlCommand1") = SqlDataSource2.SelectCommand
    End Sub
    
    Protected Sub btnPickBTO_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtBTO.Text = Trim(txtCatalogName.Text)
        Call SearchBTO()
        ModalPopupExtender1.Show()
        up2.Update()
    End Sub

    Protected Sub SqlDataSource2_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand1") <> "" Then SqlDataSource2.SelectCommand = ViewState("SqlCommand1")
    End Sub

    Protected Sub btnSearchBTO_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Call SearchBTO()
    End Sub

    Protected Sub btnBTOClick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtCatalogName.Text = CType(sender, LinkButton).Text
        ModalPopupExtender1.Hide()
        up1.Update()
    End Sub
    
    Protected Sub gv2_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
        End If
    End Sub

    Protected Sub search(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim searchField As String = ""
        Select Case Me.drpModel.SelectedValue
            Case "BTO Item"
                searchField = "CATALOG_NAME"
            Case "Group Description"
                searchField = "CATALOG_type"
        End Select
        Dim whereStr As String = searchField & " LIKE '%" & Me.txtSearch.Text.Trim & "%'"
        Dim strQuery As String = " select isnull(CATALOG_NAME,'') as CATALOG_NAME,CATALOG_TYPE,CREATED, IMAGE_ID,uid" & _
                   " from CBOM_CATALOG where CATALOG_org='" & Left(Session("Org_id").ToString.ToUpper, 2) & "' AND " & whereStr & "AND CATALOG_NAME<>'' order by CATALOG_NAME asc"
        Dim xDT As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, strQuery)
        gv1.DataSource = xDT
        gv1.DataBind()
    End Sub
    Protected Sub gv1_RowEditing(sender As Object, e As System.Web.UI.WebControls.GridViewEditEventArgs)
        gv1.EditIndex = e.NewEditIndex
        search(Me.Button1, Nothing)
    End Sub
    Protected Sub gv1_RowUpdating(sender As Object, e As System.Web.UI.WebControls.GridViewUpdateEventArgs)
        Dim sqlstr As String = String.Format("update CBOM_CATALOG set CATALOG_TYPE='{0}' where uid='{1}' and CATALOG_ORG='{2}'", CType(gv1.Rows(e.RowIndex).Cells(2).Controls(0), TextBox).Text.ToString().Trim(), gv1.DataKeys(e.RowIndex).Values(0).ToString(), Left(Session("Org_id").ToString.ToUpper, 2))
        dbUtil.dbExecuteScalar(CBOMSetting.DBConn, sqlstr)
        gv1.EditIndex = -1
        search(Me.Button1, Nothing)
    End Sub
    Protected Sub gv1_RowDeleting(sender As Object, e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim sqlstr As String = String.Format("Delete From CBOM_CATALOG WHERE uid='{0}' and CATALOG_ORG='{1}'", gv1.DataKeys(e.RowIndex).Values(0).ToString(), Left(Session("Org_id").ToString.ToUpper, 2))
        dbUtil.dbExecuteScalar(CBOMSetting.DBConn, sqlstr)
        search(Me.Button1, Nothing)
    End Sub
    Protected Sub gv1_RowCancelingEdit(sender As Object, e As System.Web.UI.WebControls.GridViewCancelEditEventArgs)
        gv1.EditIndex = -1
        search(Me.Button1, Nothing)
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gv1.PageIndex = e.NewPageIndex
        search(Me.Button1, Nothing)
    End Sub

  
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table height="620px" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td valign="top" width="98%">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td>
                            <h1>
                                CBOM Grouping Administration</h1>
                        </td>
                    </tr>
                    <tr>
                        <td height="6">
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td align="left">
                            <table width="75%" border="0" cellspacing="1" cellpadding="1">
                                <tr>
                                    <td align="center" colspan="2" bgcolor="#b0c4de" height="30">
                                        <b>BTOS&nbsp;Information</b>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>BTO item&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel">
                                        <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                            <ContentTemplate>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:TextBox runat="server" ID="txtCatalogName" size="25"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            <asp:Button runat="server" ID="btnPickBTO" Text="Pick BTO" OnClick="btnPickBTO_Click" />
                                                            <asp:LinkButton runat="server" ID="link1" />
                                                            <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" PopupControlID="Panel1"
                                                                PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground" />
                                                            <asp:Panel runat="server" ID="Panel1" Style="display: none">
                                                                <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                                                    <ContentTemplate>
                                                                        <table width="900" height="480" border="0" cellpadding="0" cellspacing="0" bgcolor="f1f2f4">
                                                                            <tr>
                                                                                <td colspan="2" height="10">
                                                                                    &nbsp
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="right" width="50%">
                                                                                    &nbsp;&nbsp;<font size="2">BTO Item : </font>
                                                                                    <asp:TextBox runat="server" ID="txtBTO" />
                                                                                </td>
                                                                                <td align="left" width="50%">
                                                                                    <asp:Button runat="server" ID="btnSearchBTO" Text="Search" OnClick="btnSearchBTO_Click" />
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td colspan="2" height="10">
                                                                                    &nbsp
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td colspan="2" valign="top" align="center">
                                                                                    <sgv:SmartGridView ShowWhenEmpty="true" runat="server" ID="gv2" DataSourceID="SqlDataSource2"
                                                                                        AutoGenerateColumns="false" EnableTheming="false" HeaderStyle-HorizontalAlign="Center"
                                                                                        AllowSorting="true" AllowPaging="true" PageSize="50" Width="96%" OnRowDataBoundDataRow="gv2_RowDataBoundDataRow">
                                                                                        <Columns>
                                                                                            <asp:TemplateField ItemStyle-Width="30px" ItemStyle-HorizontalAlign="Center">
                                                                                                <HeaderTemplate>
                                                                                                    No.
                                                                                                </HeaderTemplate>
                                                                                                <ItemTemplate>
                                                                                                    <%# Container.DataItemIndex + 1 %>
                                                                                                </ItemTemplate>
                                                                                            </asp:TemplateField>
                                                                                            <asp:TemplateField HeaderText="BTO Item" ItemStyle-Width="120">
                                                                                                <ItemTemplate>
                                                                                                    <asp:LinkButton runat="server" ID="btnBTOClick" CommandName="Select" Text='<%# Eval("CATEGORY_NAME") %>'
                                                                                                        OnClick="btnBTOClick_Click" />
                                                                                                </ItemTemplate>
                                                                                            </asp:TemplateField>
                                                                                            <asp:BoundField HeaderText="Type Name" DataField="Category_type" ItemStyle-Width="120px" />
                                                                                            <asp:BoundField HeaderText="Desc" DataField="Extended_desc" />
                                                                                        </Columns>
                                                                                        <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                                                                        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                                                                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                                                                        <PagerStyle BackColor="#284775" ForeColor="Navy" HorizontalAlign="Justify" />
                                                                                        <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                                                                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                                                                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                                                                        <FixRowColumn TableHeight="400" FixRowType="Header" FixColumns="-1" FixRows="-1" />
                                                                                    </sgv:SmartGridView>
                                                                                    <asp:SqlDataSource runat="server" ID="SqlDataSource2" ConnectionString="<%$ connectionStrings:B2B %>"
                                                                                        SelectCommand="" OnLoad="SqlDataSource2_Load"></asp:SqlDataSource>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="center" colspan="2">
                                                                                    <asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </ContentTemplate>
                                                                </asp:UpdatePanel>
                                                            </asp:Panel>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            Copy BTO from :
                                        </div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel">
                                        &nbsp;<asp:TextBox runat="server" ID="txtCopy" />
                                        <asp:CheckBox ID="chbxCopy" runat="server" Checked="false" />
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Group Name&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel">
                                        &nbsp;<asp:TextBox runat="server" ID="txtGroupName" size="40"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Description&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel">
                                        &nbsp;<asp:TextBox runat="server" ID="txtCatalogDesc" TextMode="multiLine" Rows="6"
                                            Columns="57" MaxLength="180"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td bgcolor="#dcdcdc" align="right" width="120">
                                        <div class="mceLabel">
                                            <font color="red">*</font>Image&nbsp;:&nbsp;</div>
                                    </td>
                                    <td bgcolor="#e6e6fa" class="mceLabel">
                                        &nbsp;<asp:FileUpload runat="server" ID="UploadImage" size="30" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="center" colspan="2" bgcolor="#e6e6fa" valign="middle" height="35">
                                        <asp:Button runat="server" ID="Register" Text="Register" OnClick="Register_Click" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="6">
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Search By:<asp:DropDownList ID="drpModel" runat="server">
                                <asp:ListItem Value="BTO Item">BTO Item</asp:ListItem>
                                <asp:ListItem Value="Group Description">Group Description</asp:ListItem>
                            </asp:DropDownList>
                            <asp:TextBox ID="txtSearch" runat="server"></asp:TextBox><asp:Button ID="Button1"
                                runat="server" Text="Search" OnClick="search" />
                        </td>
                    </tr>
                    <tr>
                        <td width="100%">
                            <sgv:SmartGridView DataKeyNames="UID" ShowWhenEmpty="true" runat="server" ID="gv1"
                                AutoGenerateColumns="false" HeaderStyle-HorizontalAlign="Center" AllowSorting="true"
                                AllowPaging="true" PageSize="15" Width="100%" 
                                onrowediting="gv1_RowEditing" onrowupdating="gv1_RowUpdating" 
                                onrowdeleting="gv1_RowDeleting" onrowcancelingedit="gv1_RowCancelingEdit" OnPageIndexChanging="gv1_PageIndexChanging">
                                <Columns>
                                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                        <HeaderTemplate>
                                            No.
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField HeaderText="BTO Item" DataField="CATALOG_NAME" SortExpression="CATALOG_NAME"  ReadOnly="true" />
                                    <asp:BoundField HeaderText="Group Name" DataField="CATALOG_TYPE" SortExpression="CATALOG_TYPE" />
                                    <asp:BoundField HeaderText="Date" DataField="CREATED" SortExpression="CREATED" ReadOnly="true" />
                                    <asp:BoundField HeaderText="Image ID" DataField="IMAGE_ID" ReadOnly="true" />
                                    <asp:CommandField ShowDeleteButton="true" ShowEditButton="true" />
                                </Columns>
                                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                <PagerStyle BackColor="#284775" ForeColor="Navy" HorizontalAlign="Justify" />
                                <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                            </sgv:SmartGridView>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
