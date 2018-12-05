<%@ Page Title="My Forecast List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
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
               String.Format("<tr><td>{0}</td><td>{1}</td><td><font color='red'>{2}</font></td></tr></table>", tmprow.Cells(1).Text, old_qty, new_qty.ToString) + _
                "<br/><br/>Best Regards,<br/><a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "'>MyAdvantech</a>"
        If old_qty <> new_qty Then
            Util.SendEmail(owner_email, "MyAdvantech@advantech.com", "A Forecast Catalog Request has been updated", body, True, Session("user_id"), "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw")
        End If
    End Sub
    
    Protected Sub Deleting(ByVal s As Object, ByVal e As GridViewDeleteEventArgs) Handles gv1.RowDeleting
        Dim tmprow As GridViewRow = gv1.Rows(e.RowIndex)
        sqlCatalogList.DeleteParameters.Item("ROW_ID").DefaultValue = CType(tmprow.FindControl("hdnRowId1"), HiddenField).Value
        
        Dim owner_email As String = CType(tmprow.FindControl("hdnOwnerEmail"), HiddenField).Value
        Dim body As String
        body = "Dears,<br/><br/>" + _
               "Your catalog and brochure order forecast quantity is deleted by " + Session("user_id") + " on " + Now.ToString + ".<br/><br/>" + _
               "<table border='1'><tr><td align='center'><b>Item</b></td><td align='center'><b>Qty</b></td></tr>" + _
               String.Format("<tr><td>{0}</td><td>{1}</td></tr></table>", tmprow.Cells(1).Text, CType(tmprow.FindControl("lblQty"), Label).Text) + _
                "<br/><br/>Best Regards,<br/><a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "'>MyAdvantech</a>"
        Util.SendEmail(owner_email, "MyAdvantech@advantech.com", "A Forecast Catalog Request has been deleted", body, True, Session("user_id"), "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw")
    End Sub
    
    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim DelBtn As LinkButton = CType(e.Row.Cells(0).Controls(2), LinkButton)
            If DelBtn.Text = "Delete" Then DelBtn.Attributes.Add("onclick", "return confirm('Are you sure you want to delete this record?')")
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
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
                                    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="false" ShowWhenEmpty="true" PagerSettings-Position="TopAndBottom" DataSourceID="sqlCatalogList" DataKeyNames="ROW_ID" OnRowDataBound="gv1_RowDataBound">
                                        <Columns>
                                            <asp:CommandField ShowEditButton="true" ShowDeleteButton="true" ButtonType="Link" />
                                            <asp:BoundField DataField="description" HeaderText="Catalogue Name" SortExpression="description" ReadOnly="true" />
                                            <asp:BoundField DataField="part_no" HeaderText="P/N" ItemStyle-Width="100" SortExpression="part_no" ReadOnly="true" />
                                            <asp:TemplateField HeaderText="Qty" ItemStyle-Width="100" SortExpression="Qty">
                                                <ItemTemplate>
                                                    <asp:HiddenField runat="server" ID="hdnRowId1" Value='<%#Eval("ROW_ID") %>' />
                                                    <asp:Label runat="server" ID="lblQty" Text='<%#Eval("Qty") %>' />
                                                </ItemTemplate>
                                                <EditItemTemplate>
                                                    <asp:HiddenField runat="server" ID="hdnOwnerEmail" Value='<%#Eval("OWNER_EMAIL") %>' />
                                                    <asp:HiddenField runat="server" ID="hdnQty" Value='<%#Eval("Qty") %>' />
                                                    <asp:HiddenField runat="server" ID="hdnRowId" Value='<%#Eval("ROW_ID") %>' />
                                                    <asp:TextBox runat="server" ID="txtQty" Width="50" Text='<%#Eval("Qty") %>' />
                                                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeQty" TargetControlID="txtQty" FilterMode="ValidChars" FilterType="Numbers" />
                                                </EditItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="AVAILABLE_DATE" HeaderText="Available Date" SortExpression="AVAILABLE_DATE" ReadOnly="true" />
                                            <asp:BoundField DataField="date" HeaderText="Order Date" SortExpression="date" ItemStyle-Width="100" ReadOnly="true" />
                                        </Columns>
                                    </asp:GridView>
                                    <asp:SqlDataSource runat="server" ID="sqlCatalogList" ConnectionString="<%$ connectionStrings:MY %>"
                                            SelectCommand="select b.PART_NO, b.DESCRIPTION, b.ROW_ID as CATALOG_ID, b.AVAILABLE_DATE, b.OWNER_EMAIL, a.ROW_ID, a.QTY, a.USER_ID, a.DATE from FORECAST_CATALOG_HISTORY_NEW a inner join FORECAST_CATALOG_LIST b on a.CATALOG_ID=b.ROW_ID where a.USER_ID=@USER_ID and a.is_disabled=0 and b.is_disabled=0"
                                            DeleteCommand="update FORECAST_CATALOG_HISTORY_NEW set is_disabled=1 where ROW_ID=@ROW_ID" 
                                            UpdateCommand="update FORECAST_CATALOG_HISTORY_NEW set QTY=@QTY where ROW_ID=@ROW_ID">
                                        <SelectParameters>
                                            <asp:SessionParameter Name="USER_ID" Type="String" SessionField="user_id" />
                                        </SelectParameters>
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

