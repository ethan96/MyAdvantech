<%@ Page Title="MyAdvantech - Create New Catalog Forecast" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<%@ Import Namespace="System.IO" %>
<%@ Register TagPrefix="Upload" Namespace="Brettle.Web.NeatUpload" Assembly="Brettle.Web.NeatUpload" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            txtDate.Text = Now.ToString("yyyy/MM/dd")
            If Util.IsAEUIT() Or Util.IsInternalUser(Session("user_id")) Then
                
            Else
                'Response.Redirect("Forecast_Catalog.aspx")
                Response.Redirect(Request.ApplicationPath) 'ICC 2016/3/23 This page cannot be accessed by outer user.
            End If
        End If
    End Sub
    
    Private Shared Function NewId(ByVal db As String) As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MY", "select count(ROW_ID) as counts from " + db + " where ROW_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    
    Protected Sub btnCreate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If txtPartNO.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Part No. is required.") : Exit Sub
        If txtItem.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Item is required.") : Exit Sub
        If txtDate.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Available Date is required.") : Exit Sub
        If txtOwner.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Owner is required.") : Exit Sub
        If txtOwnerEmail.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Owner Email is required.") : Exit Sub
        If Not Util.IsValidEmailFormat(txtOwnerEmail.Text) Then Util.JSAlert(Me.Page, "Owner Email is not a valid email format.") : Exit Sub
        'If hdnCatalogId.Value = "" Then Util.JSAlert(Me.Page, "Please select a WWW eCatalog mapping.") : Exit Sub
        'If txtPage.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Page info. is required.") : Exit Sub
        'If txtDimen.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Dimensions is required.") : Exit Sub
        'If txtWeight.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Weight is required.") : Exit Sub
        'If txtPiece.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Piece per carton info. is required.") : Exit Sub
        'If txtCarton.Text.Trim.Replace("'", "") = "" Then Util.JSAlert(Me.Page, "Carton is required.") : Exit Sub
        If Not if1.HasFile Then Util.JSAlert(Me.Page, "Please upload a thumbnail.") : Exit Sub
        If Not if1.FileName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase) AndAlso Not if1.FileName.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase) _
             AndAlso Not if1.FileName.EndsWith(".gif", StringComparison.OrdinalIgnoreCase) AndAlso Not if1.FileName.EndsWith(".bmp", StringComparison.OrdinalIgnoreCase) _
              AndAlso Not if1.FileName.EndsWith(".png", StringComparison.OrdinalIgnoreCase) AndAlso Not if1.FileName.EndsWith(".tif", StringComparison.OrdinalIgnoreCase) _
               AndAlso Not if1.FileName.EndsWith(".tiff", StringComparison.OrdinalIgnoreCase) Then
            Util.JSAlert(Me.Page, "Thumbnail has to be an image file.") : Exit Sub
        End If
        Dim row_id As String = NewId("forecast_catalog_list")
        Dim pThumbnail As New SqlClient.SqlParameter("THUMBNAIL", SqlDbType.VarBinary) : pThumbnail.Value = if1.FileBytes
        Dim paras() As SqlClient.SqlParameter = {pThumbnail}
        Dim retInt As Integer = dbUtil.dbExecuteNoQuery2("My", String.Format("insert into forecast_catalog_list (row_id,part_no,description,available_date,owner,owner_email,www_ecatalog,created_by,page,dimension,weight,piece,carton,note,thumbnail) values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',N'{8}',N'{9}',N'{10}',N'{11}',N'{12}',N'{13}',@THUMBNAIL)", row_id, HttpUtility.HtmlEncode(txtPartNO.Text.Trim()), HttpUtility.HtmlEncode(txtItem.Text.Trim().Replace("&amp;", "&")), HttpUtility.HtmlEncode(txtDate.Text.Trim()), HttpUtility.HtmlEncode(txtOwner.Text.Trim()), HttpUtility.HtmlEncode(txtOwnerEmail.Text.Trim()), hdnCatalogId.Value, Session("user_id"), txtPage.Text.Trim.Replace("'", "''"), txtDimen.Text.Trim.Replace("'", "''"), txtWeight.Text.Trim.Replace("'", "''"), txtPiece.Text.Trim.Replace("'", "''"), txtCarton.Text.Trim.Replace("'", "''"), txtComment.Text.Trim.Replace("'", "''")), paras)
        If retInt > 0 Then Util.JSAlert(Me.Page, "Catalog " + HttpUtility.HtmlEncode(txtItem.Text.Trim().Replace("&amp;", "&")) + " has been created.")
    End Sub
    
    
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender1.Hide()
        upSearchCatalog.Update()
    End Sub

    Public Function GetCatalogSql() As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct a.TITLE, a.RECORD_IMG, a.HYPER_LINK, a.ABSTRACT, a.RECORD_ID ")
            .AppendFormat(" from CurationPool.dbo.CmsToMyAdv_Resources a left join CurationPool.dbo.CmsToMyAdv_ResourcesExt b on a.RECORD_ID=b.RECORD_ID ")
            .AppendFormat(" where a.CATEGORY_NAME='ecatalog' ")
            If ddlRBU.SelectedIndex = 0 And txtCatalog.Text.Trim.Replace("'", "") = "" Then .AppendFormat(" and 1 <> 1 ")
            If ddlRBU.SelectedIndex <> 0 Then .AppendFormat(" and b.TYPE='RBU' and b.ATTRIBUTE='{0}' ", ddlRBU.SelectedValue)
            If txtCatalog.Text.Trim.Replace("'", "") <> "" Then .AppendFormat(" and a.TITLE like N'{0}%' ", txtCatalog.Text.Trim.Replace("'", "''"))
            .AppendFormat("order by a.TITLE")
        End With
        Return sb.ToString
    End Function
    
    Protected Sub btnPickCatalog_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim ws As New ADVWWWLocal.AdvantechWebServiceLocal
        'ws.Timeout = -1
        'gv3.DataSource = ws.getCMSBy("eCatalog", "ACL", {"CORP"}, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, "", 0).Tables(0)
        'gv3.DataBind()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetCatalogSql())
        'gv1.DataSource = ws.getCMSBy("eCatalog", "ACL", {"CORP"}, Nothing, Nothing, Nothing, Nothing, Nothing, Nothing, "", 0).Tables(0)
        gv1.DataBind()
        gv1.Visible = True
        ModalPopupExtender1.Show()
        upSearchCatalog.Update()
    End Sub

    Protected Sub btnCancelCatalog_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lbleCatalog.Text = "" : hdnCatalogId.Value = ""
        btnCancelCatalog.Visible = False
        upPick.Update()
    End Sub
    
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetCatalogSql())
        gv1.DataSource = dt
        gv1.DataBind()
    End Sub

    Protected Sub btnCatalogName_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        lbleCatalog.Text = CType(sender, LinkButton).Text
        hdnCatalogId.Value = CType(CType(sender, LinkButton).NamingContainer, GridViewRow).Cells(1).Text
        btnCancelCatalog.Visible = True
        ModalPopupExtender1.Hide()
        upPick.Update()
    End Sub

    Protected Sub btnPickPartNo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender2.Show()
        gv2.Visible = True
        upSearchPartNo.Update()
    End Sub

    Protected Sub btnSearchPartNo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select distinct part_no, product_desc, gross_weight, weight_unit, size_dimensions from sap_product where product_hierarchy in ('AGSG-CTOS-0000','OTHR-MEMO-0000') and (part_no like '2000%' or part_no like '86%')")
            If txtSearchPartNo.Text.Trim.Replace("'", "") <> "" Then .AppendFormat(" and part_no like '{0}%' ", txtSearchPartNo.Text.Trim.Replace("'", "''"))
            If txtSearchDesc.Text.Trim.Replace("'", "") <> "" Then .AppendFormat(" and product_desc like '%{0}%' ", txtSearchDesc.Text.Trim.Replace("'", "''"))
            .AppendFormat(" order by part_no")
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString)
        gv2.DataSource = dt
        gv2.DataBind()
    End Sub

    Protected Sub btnPartNo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim btn As LinkButton = CType(sender, LinkButton)
        txtPartNO.Text = btn.Text
        txtWeight.Text = CType(btn.NamingContainer, GridViewRow).Cells(3).Text + " " + CType(btn.NamingContainer, GridViewRow).Cells(4).Text
        txtDimen.Text = CType(btn.NamingContainer, GridViewRow).Cells(5).Text
        btnCancelPartNo.Visible = True
        ModalPopupExtender2.Hide()
        upPartNo.Update() : upPacking.Update()
    End Sub

    Protected Sub btnCancelPartNo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtPartNO.Text = "" : txtDimen.Text = "" : txtWeight.Text = ""
        btnCancelPartNo.Visible = False
        upPartNo.Update() : upPacking.Update()
    End Sub

    Protected Sub btnClosePartNo_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender2.Hide()
        upSearchPartNo.Update()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<table>
    <tr>
        <td>
            <table border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td><asp:HyperLink runat="server" ID="hlCatalogList" NavigateUrl="~/Admin/Forecast_Catalog.aspx" Text="Catalog List" /></td>
					<td width="15" align="center">></td>
					<td><asp:HyperLink runat="server" ID="hlCatalogSummary" NavigateUrl="~/Admin/Forecast_Catalog_Create.aspx" Text="Create Catalog Forecast" /></td>
					<td>&nbsp;
					</td>
				</tr>
			</table>
        </td>
    </tr>
    <tr><td height="3"></td></tr>
    <tr><td><div class="euPageTitle"><asp:Label runat="server" ID="lblTitle" /></div></td></tr>
    <tr><td height="3"></td></tr>
</table>
<table width="100%">
    <tr>
        <td width="20%" valign="top">
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>
                    <td height="24" class="menu_title">
                    <asp:Literal ID="LiT3" runat="server">Advantech Catalog</asp:Literal>
                    </td>
                </tr>
                <tr>
                    <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                        <td width="5%" height="10"></td>
                        <td></td>
                        </tr>
                        <tr runat="server" id="trNew">
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top"><img src="../Images/point_02.gif" alt="" width="7" height="14"/></td>
                                    <td class="menu_title02">
                                        <asp:HyperLink runat="server" ID="hlNew" NavigateUrl="~/Admin/Forecast_Catalog.aspx" Text="Catalog Forecast List" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        </tr>
                        <tr runat="server" id="trSum">
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top"><img src="../Images/point_02.gif" alt="" width="7" height="14"/></td>
                                    <td class="menu_title02">
                                        <asp:HyperLink runat="server" ID="hlSum" NavigateUrl="~/Admin/Forecast_Catalog_Summary.aspx" Text="Catalog Forecast Summary" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        </tr>
                        <tr>
                        <td width="5%" height="10"></td>
                        <td></td>
                        </tr>
                    </table>
                    </td>
                </tr>
            </table>
        </td>
        <td width="5%"></td>
        <td align="left">
            <table>
                <tr>
                    <td align="left"><div class="euPageTitle">Create New Catalog</div></td>
                </tr>
                <tr>
                    <td align="left">
                        <table cellpadding="3" cellspacing="3">
                            <tr>
	                            <td><font color="red">*</font><b>Part NO : </b></td>
                                <td>
                                    <asp:UpdatePanel runat="server" ID="upPartNo" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <ContentTemplate>
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:TextBox runat="server" ID="txtPartNO" Enabled="false" />
                                                        <asp:LinkButton runat="server" ID="btnPickPartNo" Text="Pick" OnClick="btnPickPartNo_Click" />
                                                        <asp:LinkButton runat="server" ID="btnCancelPartNo" Text="Clear" Visible="false" OnClick="btnCancelPartNo_Click" />
                                                        <asp:LinkButton runat="server" ID="link2" />
                                                        <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender2" PopupControlID="PanelSearchPartNo" 
                                                            TargetControlID="link2" BackgroundCssClass="modalBackground" />
                                                        <asp:Panel runat="server" ID="PanelSearchPartNo" Width="400px" Height="400" DefaultButton="btnSearchPartNo">
                                                            <asp:UpdatePanel runat="server" ID="upSearchPartNo" UpdateMode="Conditional">
                                                                <ContentTemplate>
                                                                    <table style="background-color:White; width:650px">
                                                                        <tr>
                                                                            <td align="right"><asp:LinkButton runat="server" ID="btnClosePartNo" Text="[Close]" OnClick="btnClosePartNo_Click" />&nbsp;&nbsp;</td>
                                                                        </tr>
                                                                    </table>
                                                                    <table style="background-color:White; width:650px">
                                                                        <tr><td>Part No: <asp:TextBox runat="server" ID="txtSearchPartNo" />&nbsp;&nbsp;Description: <asp:TextBox runat="server" ID="txtSearchDesc" /><asp:Button runat="server" ID="btnSearchPartNo" Text="Search" OnClick="btnSearchPartNo_Click" /></td></tr>
                                                                    </table>
                                                                    <table style="background-color:White; width:650px">
                                                                        <tr>
                                                                            <td>
                                                                                <sgv:SmartGridView runat="server" ID="gv2" Width="100%" Visible="false" AutoGenerateColumns="false">
                                                                                    <Columns>
                                                                                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                                            <headertemplate>
                                                                                                No.
                                                                                            </headertemplate>
                                                                                            <itemtemplate>
                                                                                                <%# Container.DataItemIndex + 1 %>
                                                                                            </itemtemplate>
                                                                                        </asp:TemplateField>
                                                                                        <asp:TemplateField HeaderText="Part No.">
                                                                                            <ItemTemplate>
                                                                                                <asp:LinkButton runat="server" ID="btnPartNo" CommandName="Select" Text='<%#Eval("part_no") %>' OnClick="btnPartNo_Click" />
                                                                                            </ItemTemplate>
                                                                                        </asp:TemplateField>
                                                                                        <asp:BoundField DataField="product_desc" HeaderText="description" />
                                                                                        <asp:BoundField DataField="gross_weight" HeaderText="Weight" />
                                                                                        <asp:BoundField DataField="weight_unit" HeaderText="Weight Unit" />
                                                                                        <asp:BoundField DataField="size_dimensions" HeaderText="Dimension" />
                                                                                    </Columns>
                                                                                    <FixRowColumn TableHeight="400px" FixColumns="-1" FixRows="-1" />
                                                                                </sgv:SmartGridView>
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
                                <td><font color="red">*</font><b>WWW eCatalog: </b></td>
                                <td>
                                    <asp:UpdatePanel runat="server" ID="upPick" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                        <ContentTemplate>
                                            <table>
                                                <tr>
                                                    <td>
                                                        <asp:Label runat="server" ID="lbleCatalog" ForeColor="blue" Font-Bold="true" /><asp:HiddenField runat="server" ID="hdnCatalogId" />
                                                        <asp:LinkButton runat="server" ID="btnPickCatalog" Text="Pick" OnClick="btnPickCatalog_Click" />
                                                        <asp:LinkButton runat="server" ID="btnCancelCatalog" Text="Cancel" Visible="false" OnClick="btnCancelCatalog_Click" />
                                                        <asp:LinkButton runat="server" ID="link1" />
                                                        <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" PopupControlID="PanelSearchCatalog" 
                                                                        TargetControlID="link1" BackgroundCssClass="modalBackground" />
                                                        <asp:Panel runat="server" ID="PanelSearchCatalog" Width="400px" Height="400">
                                                            <asp:UpdatePanel runat="server" ID="upSearchCatalog" UpdateMode="Conditional">
                                                                <ContentTemplate>
                                                                    <table style="background-color:White; width:650px">
                                                                        <tr>
                                                                            <td align="right"><asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" />&nbsp;&nbsp;</td>
                                                                        </tr>
                                                                        <tr><td>Catalog Name: <asp:TextBox runat="server" ID="txtCatalog" /></td></tr>
                                                                        <tr><td>RBU: 
                                                                                <asp:DropDownList runat="server" ID="ddlRBU" DataSourceID="sqlCatalog" DataTextField="text" DataValueField="value">
                                                                                </asp:DropDownList>
                                                                                <asp:SqlDataSource runat="server" ID="sqlCatalog" ConnectionString="<%$ connectionStrings:MY %>"
                                                                                    SelectCommand="select '-----' as text, '' as value union select text, value from siebel_account_rbu_lov">
                                                                                </asp:SqlDataSource>
                                                                                <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" />
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <sgv:SmartGridView runat="server" ID="gv1" Width="100%" Visible="false" AutoGenerateColumns="false">
                                                                                    <Columns>
                                                                                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                                            <headertemplate>
                                                                                                No.
                                                                                            </headertemplate>
                                                                                            <itemtemplate>
                                                                                                <%# Container.DataItemIndex + 1 %>
                                                                                            </itemtemplate>
                                                                                        </asp:TemplateField>
                                                                                        <asp:BoundField DataField="RECORD_ID" HeaderText="ID" />
                                                                                        <asp:TemplateField HeaderText="Catalog Name">
                                                                                            <ItemTemplate>
                                                                                                <asp:LinkButton runat="server" ID="btnCatalogName" CommandName="Select" Text='<%#Eval("title") %>' OnClick="btnCatalogName_Click" />
                                                                                            </ItemTemplate>
                                                                                        </asp:TemplateField>
                                                                                        <asp:BoundField DataField="abstract" HeaderText="Description" />
                                                                                        <asp:TemplateField HeaderText="Image">
                                                                                            <ItemTemplate>
                                                                                                <asp:Image runat="server" ID="imgCatalog" ImageUrl='<%#Eval("RECORD_IMG") %>' Width="150" />
                                                                                            </ItemTemplate>
                                                                                        </asp:TemplateField>
                                                                                        <asp:HyperLinkField DataNavigateUrlFields="HYPER_LINK" DataTextFormatString="Download" DataTextField="HYPER_LINK" HeaderText="PDF" Target="_blank" />
                                                                                    </Columns>
                                                                                    <FixRowColumn TableHeight="400px" FixColumns="-1" FixRows="-1" />
                                                                                </sgv:SmartGridView>
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
	                            <td><font color="red">*</font><b>Description : </b></td><td><asp:TextBox runat="server" ID="txtItem" Width="250px" /></td>
	                        </tr>
	                        <tr>
	                            <td><font color="red">*</font><b>Available Date : </b></td>
	                            <td>
	                                <asp:TextBox runat="server" ID="txtDate" />
	                                <ajaxToolkit:CalendarExtender runat="server" ID="ceDate" TargetControlID="txtDate" Format="yyyy/MM/dd" />
	                            </td>
	                        </tr>
	                        <tr>
	                            <td><font color="red">*</font><b>Owner : </b></td><td><asp:TextBox runat="server" ID="txtOwner" Width="200px" /> (Split by ";" if there is more than one owner)</td>
	                        </tr>
	                        <tr>
	                            <td><font color="red">*</font><b>Owner's Email : </b></td><td><asp:TextBox runat="server" ID="txtOwnerEmail" Width="300px" /> (Split by ";" if there is more than one email)</td>
	                        </tr>
                            <tr><td colspan="2" height="10"></td></tr>
                            <tr><th colspan="2" align="left" style="color:Blue;">Packing information</th></tr>
                            <tr>
                                <td colspan="2" align="left">
                                    <table width="100%">
                                        <tr>
                                            <td colspan="2">
                                                <asp:UpdatePanel runat="server" ID="upPacking" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <table cellpadding="3" cellspacing="3">
                                                            <tr><td align="left" width="110"><b>Pages: </b></td><td align="left"><asp:TextBox runat="server" ID="txtPage" Width="300px" /></td><td>ex: 572 (cover page: 4; full color page: 36; inside dual color pages: 532)</td></tr>
                                                            <tr><td height="2"></td></tr>
                                                            <tr><td align="left"><b>Dimensions: </b></td><td align="left"><asp:TextBox runat="server" ID="txtDimen" Width="300px" /></td><td>ex: 215 * 280 *12 mm</td></tr>
                                                            <tr><td align="left"><b>Weight: </b></td><td align="left"><asp:TextBox runat="server" ID="txtWeight" Width="300px" /></td><td>ex: 1150g</td></tr>
                                                            <tr><td align="left"><b>Pieces/per Carton: </b></td><td align="left"><asp:TextBox runat="server" ID="txtPiece" Width="300px" /></td><td>ex: 20 copies per carton</td></tr>
                                                            <tr><td align="left"><b>Carton (L x W x H): </b></td><td align="left"><asp:TextBox runat="server" ID="txtCarton" Width="300px" /></td><td>ex: 44.5 * 32.5 * 20.5 cm</td></tr>
                                                            <tr><td align="left"><b>Special Note: </b></td><td align="left"><asp:TextBox runat="server" ID="txtComment" Width="300px" /></td><td></td></tr>
                                                        </table>
                                                    </ContentTemplate>
                                                </asp:UpdatePanel>
                                            </td>
                                        </tr>
                                        <tr><td align="left"><font color="red">*</font><b>Thumbnail: </b></td><td align="left"><asp:FileUpload runat="server" ID="if1" /></td><td></td></tr>
                                    </table>
                                </td>
                            </tr>
	                        <tr>
	                            <td colspan="2"><asp:Button runat="server" ID="btnCreate" Text="Submit" Width="80" Height="30" OnClick="btnCreate_Click" /></td>
	                        </tr>
                        </table>
                        <%--<asp:UpdatePanel runat="server" ID="up1">
                            <ContentTemplate>
                                <table>
                                    <tr><td><asp:Label runat="server" ID="lblMsg" ForeColor="Red" /></td></tr>
                                </table>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="btnCreate" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>--%>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>

</asp:Content>

