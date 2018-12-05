<%@ Page Title="MyAdvantech - Catalog Detail" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If (Util.IsAEUIT() Or Util.IsInternalUser(Session("user_id"))) Then
            trSum.Visible = True : trNew.Visible = True
        Else
            trSum.Visible = False : trNew.Visible = False
            Response.Redirect("Forecast_Catalog.aspx")
        End If
    End Sub

    Protected Sub sqlCatalogList_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        sqlCatalogList.SelectCommand = String.Format("select a.USER_ID, a.DATE, a.QTY, a.ROW_ID, a.IS_DISABLED, z.ROW_ID as CATALOG_ID, z.AVAILABLE_DATE, z.OWNER, z.PART_NO, z.DESCRIPTION, z.OWNER_EMAIL , isnull((select top 1 b.erpid from SIEBEL_CONTACT b where b.EMAIL_ADDRESS=a.user_id),'') as erpid,isnull((select top 1 b.orgid from SIEBEL_CONTACT b where b.EMAIL_ADDRESS=a.user_id),'') as orgid,isnull((select top 1 b.account from SIEBEL_CONTACT b where b.EMAIL_ADDRESS=a.user_id),'') as account,isnull((select top 1 b.LastName+' '+b.firstname from SIEBEL_CONTACT b where b.EMAIL_ADDRESS=a.user_id),'') as name from FORECAST_CATALOG_HISTORY_NEW a inner join FORECAST_CATALOG_LIST z on a.CATALOG_ID=z.ROW_ID where a.catalog_id='{0}' and a.is_disabled=0 ", Request("catalog_id"))
    End Sub

    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim DelBtn As LinkButton = CType(e.Row.Cells(0).Controls(2), LinkButton)
            If DelBtn.Text = "Delete" Then DelBtn.Attributes.Add("onclick", "return confirm('Are you sure you want to delete this record?')")
        End If
    End Sub
    
    Protected Sub Updating(ByVal s As Object, ByVal e As GridViewUpdateEventArgs) Handles gv1.RowUpdating
        Dim tmprow As GridViewRow = gv1.Rows(e.RowIndex)
        Dim new_qty As Integer = CInt(CType(tmprow.FindControl("txtQty"), TextBox).Text)
        sqlCatalogList.UpdateParameters.Item("QTY").DefaultValue = new_qty
        sqlCatalogList.UpdateParameters.Item("ROW_ID").DefaultValue = CType(tmprow.FindControl("hdnRowId"), HiddenField).Value
        Dim owner_email As String = CType(tmprow.FindControl("hdnOwnerEmail"), HiddenField).Value
        Dim old_qty As String = CType(tmprow.FindControl("hdnQty"), HiddenField).Value
        Dim body As String
        body = "Dears,<br/><br/>" + _
               "A catalog and brochure order forecast quantity is updated by " + Session("user_id") + " on " + Now.ToString + ".<br/><br/>" + _
               "<table border='1'><tr><td align='center'><b>Item</b></td><td align='center'><b>Old Qty</b></td><td align='center'><b>New Qty</b></td></tr>" + _
               String.Format("<tr><td>{0}</td><td>{1}</td><td><font color='red'>{2}</font></td></tr></table>", tmprow.Cells(6).Text, old_qty, new_qty.ToString) + _
                "<br/><br/>Best Regards,<br/><a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "'>MyAdvantech</a>"
        If old_qty <> new_qty Then
            Util.SendEmail(tmprow.Cells(5).Text, "MyAdvantech@advantech.com", "A Forecast Catalog Request has been updated", body, True, owner_email, "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw")
        End If
    End Sub
    
    Protected Sub Deleting(ByVal s As Object, ByVal e As GridViewDeleteEventArgs) Handles gv1.RowDeleting
        Dim tmprow As GridViewRow = gv1.Rows(e.RowIndex)
        sqlCatalogList.DeleteParameters.Item("ROW_ID").DefaultValue = CType(tmprow.FindControl("hdnRowId1"), HiddenField).Value
        
        Dim owner_email As String = CType(tmprow.FindControl("hdnOwnerEmail1"), HiddenField).Value
        Dim body As String
        body = "Dears,<br/><br/>" + _
               "Your catalog and brochure order forecast quantity is deleted by " + Session("user_id") + " on " + Now.ToString + ".<br/><br/>" + _
               "<table border='1'><tr><td align='center'><b>Item</b></td><td align='center'><b>Qty</b></td></tr>" + _
               String.Format("<tr><td>{0}</td><td>{1}</td></tr></table>", tmprow.Cells(6).Text, CType(tmprow.FindControl("lblQty"), Label).Text) + _
                "<br/><br/>Best Regards,<br/><a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "'>MyAdvantech</a>"
        Util.SendEmail(tmprow.Cells(5).Text, "MyAdvantech@advantech.com", "A Forecast Catalog Request has been deleted", body, True, owner_email, "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw")
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
						<td><asp:HyperLink runat="server" ID="hlCatalogSummary" NavigateUrl="~/Admin/Forecast_Catalog_Summary.aspx" Text="Catalog Forecast Summary" /></td>
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
    <table width="100%" height="380" border="0">
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
                                            <asp:HyperLink runat="server" ID="hlNew" NavigateUrl="~/Admin/Forecast_Catalog_Create.aspx" Text="Create New Catalog" />
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
            <td valign="top" width="80%">
                <table width="100%">
                    <tr>
                        <td>
                            <asp:UpdatePanel runat="server" ID="up1">
                                <ContentTemplate>
                                    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" ShowWhenEmpty="true" PagerSettings-Position="TopAndBottom" DataSourceID="sqlCatalogList" DataKeyNames="ROW_ID,OWNER_EMAIL,QTY" OnRowDataBound="gv1_RowDataBound">
                                        <Columns>
                                            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ButtonType="Link" />
                                            <asp:BoundField DataField="orgid" HeaderText="Org Id" SortExpression="orgid" ReadOnly="true" />
                                            <asp:BoundField DataField="erpid" HeaderText="Company Id" SortExpression="erpid" ReadOnly="true" />
                                            <asp:BoundField DataField="account" HeaderText="Company Name" SortExpression="account" ReadOnly="true" />
                                            <asp:BoundField DataField="name" HeaderText="User Name" SortExpression="name" ReadOnly="true" />
                                            <asp:BoundField DataField="USER_ID" HeaderText="Email" SortExpression="USER_ID" ReadOnly="true" />
                                            <asp:BoundField DataField="description" HeaderText="Catalogue Name" SortExpression="description" ReadOnly="true" />
                                            <asp:BoundField DataField="part_no" HeaderText="P/N" ItemStyle-Width="100" SortExpression="part_no" ReadOnly="true" />
                                            <asp:TemplateField HeaderText="Qty" ItemStyle-Width="100" SortExpression="Qty">
                                                <ItemTemplate>
                                                    <asp:HiddenField runat="server" ID="hdnRowId1" Value='<%#Eval("ROW_ID") %>' />
                                                    <asp:HiddenField runat="server" ID="hdnOwnerEmail1" Value='<%#Eval("OWNER_EMAIL") %>' />
                                                    <asp:Label runat="server" ID="lblQty" Text='<%#Eval("Qty") %>' />
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:HiddenField runat="server" ID="hdnRowId" Value='<%#Eval("ROW_ID") %>' />
                                                    <asp:HiddenField runat="server" ID="hdnOwnerEmail" Value='<%#Eval("OWNER_EMAIL") %>' />
                                                    <asp:HiddenField runat="server" ID="hdnQty" Value='<%#Eval("Qty") %>' />
                                                    <asp:TextBox runat="server" ID="txtQty" Width="50" Text='<%#Eval("Qty") %>' />
                                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeQty" TargetControlID="txtQty" FilterMode="ValidChars" FilterType="Numbers" />
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="date" HeaderText="Date" SortExpression="date" ItemStyle-Width="100" ReadOnly="true" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlCatalogList" ConnectionString="<%$ connectionStrings:MY %>"
                                            SelectCommand="" 
                                            DeleteCommand="update FORECAST_CATALOG_HISTORY_NEW set is_disabled = 1 where ROW_ID=@ROW_ID" 
                                            UpdateCommand="update FORECAST_CATALOG_HISTORY_NEW set QTY=@QTY where ROW_ID=@ROW_ID" OnLoad="sqlCatalogList_Load">
                                        <UpdateParameters>
                                            <asp:Parameter Name="QTY" Type="Int32" />
                                            <asp:Parameter Name="ROW_ID" Type="String" />
                                        </UpdateParameters>
                                        <DeleteParameters>
                                            <asp:Parameter Name="ROW_ID" Type="String" />
                                        </DeleteParameters>
                                    </asp:SqlDataSource>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>

