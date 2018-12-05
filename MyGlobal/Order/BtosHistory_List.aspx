<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Cart History Detail" %>

<script runat="server">
    Dim T_strselect As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.Global_inc1.ValidationStateCheck()
        
        'T_strselect = " select '' as SNO,Category_Name,History_ID as Cart_Id ,Category_desc ,convert(varchar(10), CREATED, 111) as CREATED, 'CONFIGURE' as CONFIGURE , 'Add2Cart' as Add2Cart, 'DEL' as SCHK,History_ID " & _
        '       " from History_CATALOG_CATEGORY Where charindex('_BLKT_ORDER',History_ID,1) = 0 and Company_ID = '" & Session("COMPANY_ID") & "' and Parent_Category_id='Root' order by Created desc"
        T_strselect = " select Category_Name,History_ID as Cart_Id ,Category_desc ,convert(varchar(10), CREATED, 111) as CREATED, 'Add2Cart' as Add2Cart, 'DEL' as SCHK,History_ID " & _
           " from History_CATALOG_CATEGORY Where Company_ID = '" & Session("COMPANY_ID") & "' and Parent_Category_id='Root' order by Created desc"
        'If session("user_id") = "jackie.wu@advantech.com.cn" Then
        '    Response.write(T_strselect)
        'End If
        Me.SqlDataSource1.SelectCommand = Me.T_strselect
        
        'If Not Page.IsPostBack Then
        '    Me.AdxGrid1.VxDataGridBinding()
        'End If
        
    End Sub
    
    
    'Private Sub AdxGrid1_ItemDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.DataGridItemEventArgs) Handles AdxGrid1.ItemDataBound

    '    Dim oDataGridItem As DataGridItem = e.Item
    '    Dim retVal() As String

    '    Dim oType As ListItemType = e.Item.ItemType


    '    If (oType <> ListItemType.Header And oType <> ListItemType.Footer) Then
    '        retVal = Me.AdxGrid1.VxGetGridItemValue(oDataGridItem)
    '        AdxGrid1.VxUserFormat(oDataGridItem, 5, "<a href='BTOSHistory_Add2Configuration.aspx?Cart_Id=" & retVal(2) & "' >" & "Add2Cart" & "</a>")
    '    End If

    'End Sub
    
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType <> DataControlRowType.Pager Then
            e.Row.Cells(6).Visible = False
            e.Row.Cells(7).Visible = False
        End If
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(2).HorizontalAlign = HorizontalAlign.Left
            e.Row.Cells(5).Text = "<a href='BTOSHistory_Add2Configuration.aspx?Cart_Id=" & e.Row.Cells(2).Text & "' >" & "Add2Cart" & "</a>"
            'If Session("user_id") = "nada.liu@advantech.com.cn" Then
            '    e.Row.Cells(5).Text = "<a href='../Lab/Default4.aspx?Cart_Id=" & e.Row.Cells(2).Text.Replace("&", "!!_") & "' >" & "Add2Cart" & "</a>"
            'End If
        End If
        
    End Sub

    Protected Sub SqlDataSource1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 999999
    End Sub
</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main"> 
<div>
<table width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">
			<!-- ******* page header (start) ********-->
			<tr valign="top">
				<td colspan=3>
                   
					<!--include virtual="/utility/header_inc.asp" -->
				</td>
			</tr>
			<tr valign="top">
				<td width="15px"></td>
				<td>
					<table cellpadding=0 cellspacing=0 width="100%">

						<!-- ******* page header (end) ********-->
						<tr valign="top">
							<td>
								<!-- ******* main pane (start) ********-->
								<table width="100%" ID="Table2">
									<tr valign="top">
										<td height="2">&nbsp;
										</td>
									</tr>
									<!-- ******* page title (start) ********-->
									<tr valign="top">
										<td><div class="euPageTitle"> 
											Btos History</div>&nbsp;&nbsp;&nbsp;<span class="PageMessageBar"></span>
										</td>
									</tr>
									<!-- ******* page title (end) ********-->
									<!-- Jackie Wu modify 2005-8-5
											wipe "/includesV2/forms/search_formV2.asp" and "/includesV2/forms/template_block.asp" 
									-->
									<!-- ******* record list1 (start) ********-->
									<tr valign="top">
										<td align="center">
										
										<table cellpadding="1"  width="100%"><tr><td style="background-color:#666666">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align:middle" ID="Table3">
                    <tr>
                        <td style="padding-left:10px;border-bottom:#ffffff 1px solid;height:20px;background-color:#6699CC" align="left" valign="middle" class="text">
                        <font color="#ffffff"><b>BtosHistory List</b></font></td></tr>
                        <tr><td>
                                            <asp:GridView runat="server" ID="GridView1" 
                                                            DataSourceID ="SqlDataSource1" 
                                                onrowdatabound="GridView1_RowDataBound" AllowPaging="True" PageIndex="0" PageSize="30" DataKeyNames="History_ID" Width="100%">
                                                <Columns>
                                                    <asp:CommandField ShowDeleteButton="True" HeaderText="Del"/>
                                                </Columns>
                                            </asp:GridView>		
								
								
								
														
                                            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>" DeleteCommand="DELETE FROM History_CATALOG_CATEGORY WHERE History_ID = @History_ID" OnSelecting="SqlDataSource1_Selecting">
                                           <DeleteParameters >
                                           <asp:Parameter Type="String" Name="History_ID" />
                                           </DeleteParameters>
                                            </asp:SqlDataSource>
								 </td></tr><tr><td id="tdTotal" align="right" style="background-color:#ffffff" runat="server"></td></tr></table>
				</td></tr></table>
            						
														<!-- include virtual = "/btos/btoshistory_list_new_main.asp" -->
				<%--<adl:AdxDataGrid id="AdxGrid1" runat="server" xnavipage="true" xshowfooter="true" xconnectionstring="ADLSERVER"
					xtitletext="Configuration History" xpagesize="40" xDebugSQL="false" xImgUrl="../Images/" 
					xDeleteSQL="delete from History_CATALOG_CATEGORY " xShowDelete="true" xDeleteKey="History_ID" 
					 xAdd="false">	
									
					<adl:AdxColumn runat="server" id="Category_Name" xwidth="110" xalign="center" xdatasource="Category_Name"
					xSearch="true" xSortable="true" xheadertext="Configuration Name">
					</adl:AdxColumn>					
					<adl:AdxColumn runat="server" id="Cart_Id" xwidth="0" xdatasource="Cart_Id" xSearch="true" xSortable="true"
					xheadertext="Description"></adl:AdxColumn>
					<adl:AdxColumn runat="server" id="Category_desc" xwidth="0" xdatasource="Category_desc" xSearch="true" xSortable="true"
					xheadertext="Desc"></adl:AdxColumn>
					<adl:AdxColumn runat="server" id="CREATED" xwidth="70" xdatasource="CREATED" xSearch="true" xheadertext="CREATED" xDateFormat="yyyy/MM/dd"></adl:AdxColumn>
					<adl:AdxColumn runat="server" id="Add2Cart" xwidth="70" xdatasource="Add2Cart" xSearch="false" xheadertext="Add2Cart" xalign="center" ></adl:AdxColumn>
					<adl:AdxColumn runat="server" id="History_ID" xwidth="0" xdatasource="History_ID" xSearch="true" xSortable="true"
					xheadertext="History_ID" xVisible="false"></adl:AdxColumn>
					
				</adl:AdxDataGrid>--%>				
														
														
										</td>
									</tr>
									<!-- ******* record list1 (end) ********-->
									<tr valign="top">
										<td height="2">&nbsp;
										</td>
									</tr>
								</table>
								<!-- ******* main pane (end) ********-->
							</td>
						</tr>
					
					</table>
				</td>
				<td width="15px"></td>
			</tr>
			<tr valign="top">
				<td height="125">&nbsp;
				</td>
			</tr>
			<!-- *******  page footer (start) ********-->
			<tr valign="top">
				<td colspan=3>
                    
					<!--include virtual="/utility/footer_inc.asp" -->
				</td>
			</tr>
			<!-- *******  page footer (end) ********-->
		</table></div></asp:Content>
