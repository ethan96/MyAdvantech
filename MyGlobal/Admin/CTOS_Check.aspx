<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master" Title="CBOM---Phase-Out Checking" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
      
        If Not Page.IsPostBack Then
            gv1.DataSource = getData()
            gv1.DataBind()
        End If
    End Sub
    
    Function getData() As DataTable
        Dim Getpart_no As String = "select * from eol_item where 1=1 "
        If po_no.Text <> "" Then
            Getpart_no = Getpart_no + "and eol_item='" & po_no.Text & "' "
        End If
        If C_CTOS.Text <> "" Then
            Getpart_no = Getpart_no + "and C_CTOS LIKE '%" & C_CTOS.Text & "%'"
        End If
        If W_CTOS.Text <> "" Then
            Getpart_no = Getpart_no + "and W_CTOS LIKE '%" & W_CTOS.Text & "%'"
        End If
    
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", Getpart_no)
        Return dt
    End Function
   
    

    Protected Sub submit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        gv1.DataSource = getData()
        gv1.DataBind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">

<table width="100%">
        <tr>
            <td style="vertical-align:top;"></td>
        </tr>
        <tr>
            <td style="vertical-align:top;" width="98%">
                <table width="100%">
                    <tr>
                        <td style="height:6px;"><a href="../home_old.aspx">Home</a>>>><a href="../Admin/B2B_Admin_portal.aspx">Admin</a>>>>PhaseOut</td>
                    </tr>
                    <tr>
                        <td><h2>Phase-Out Checking</h2></td>
                    </tr> 
                  
                    <tr>
                        <td style="height:6px;">&nbsp;</td>
                    </tr>
                     <tr >
						<td >
																
																	    <table width="100%" border="0" cellpadding="0" cellspacing="0">
																		<!--form name="ocfrm" action="OrderTracking.asp" method="post" ID="Form2"-->
																			<tr>
																				<td colspan="4" style="height:4px">
																				</td>
																			</tr>
																			<tr valign="middle">
																				<td style="width:5%;height:30px" align="right">
																					<img alt="" src="../images/ebiz.aeu.face/square_gray.gif" width="7" height="7"/>&nbsp;&nbsp;
																				</td>
																				<td style="width:20%">
																					<div class="euFormFieldCaption">Phased out p/n&nbsp;:</div>
																				</td>
																				<td style="width:40%">
																				    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"                                             
                                                                                        ServiceMethod="GetPhaseOutNo" TargetControlID="po_no" ServicePath="~/Services/AutoComplete.asmx" 
                                                                                        MinimumPrefixLength="0" CompletionInterval="1000" />
																					<asp:TextBox ID="po_no" runat="server" Width="120px"></asp:TextBox>
																				</td>
																				<td align="left">
																					<div class="euFormFieldDesc"></div>
																				</td>
																			</tr>
																			<tr valign="middle">
																				<td style="width:5%" style="height:30px" align="right">
																					<img alt="" src="../images/ebiz.aeu.face/square_gray.gif" width="7" height="7"/>&nbsp;&nbsp;
																				</td>
																				<td style="width:20%">
																					<div class="euFormFieldCaption"> C-CTOS p/n&nbsp;:</div>
																				</td>
																				<td style="width:40%">
																				    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace2"                                             
                                                                                        ServiceMethod="GetPhaseOutNo" TargetControlID="C_CTOS" ServicePath="~/Services/AutoComplete.asmx" 
                                                                                        MinimumPrefixLength="0" CompletionInterval="1000" />
																					<asp:TextBox ID="C_CTOS" runat="server" Width="120px"></asp:TextBox> 
																				</td>
																				<td align="left">
																					<div class="euFormFieldDesc"></div>
																				</td>
																			</tr>
																				<tr valign="middle">
																				<td style="width:5%" style="height:30px" align="right">
																					<img alt="" src="../images/ebiz.aeu.face/square_gray.gif" width="7" height="7"/>&nbsp;&nbsp;
																				</td>
																				<td style="width:20%">
																					<div class="euFormFieldCaption"> W-CTOS p/n&nbsp;:</div>
																				</td>
																				<td style="width:40%">
																			 <asp:TextBox ID="W_CTOS" runat="server" Width="120px"></asp:TextBox> 
																				</td>
																				<td align="left">
																					<div class="euFormFieldDesc"></div>
																				</td>
																			</tr>
																			<tr>
																				<td colspan="4" style="height:3px">
																				</td>
																			</tr>
																			<tr valign="middle">
                                                                              
																				<td style="width:5%;height:30px" align="right">
																				</td>
																				<td style="width:20%">
																				</td>
																				<td style="width:40%">
																					<asp:ImageButton runat="server" ID="submit" ImageUrl="../Images/ebiz.aeu.face/btn_search.gif" OnClick="submit_Click" />
																				</td>
																				<td align="left">
																				</td>
																			</tr>
																		
																			
																		<!--/form-->
																	    </table>
															
																</td>			
					</tr> 
                    <tr>
                        <td>
                           			<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align:middle" ID="Table3">
                    <tr>
                        <td style="padding-left:10px;border-bottom:#ffffff 1px solid;height:20px;background-color:#6699CC" align="left" valign="middle" class="text">
                        <font color="#ffffff"><b>Phase-Out-Component List</b></font></td></tr>
                    
                       <tr>
                       </tr>
                       
                        <tr><td>
                                           	 <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false" Width="100%"
								                >
								                <Columns>
								                    <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                        <headertemplate>
                                                            No.
                                                        </headertemplate>
                                                        <itemtemplate>
                                                            <%# Container.DataItemIndex + 1 %>
                                                        </itemtemplate>
                                                    </asp:TemplateField>
                                              		 <asp:BoundField HeaderText="EOL Item" DataField="EOL_Item" ItemStyle-Width="120"  SortExpression="Part_no" />
								                    <asp:BoundField HeaderText="Impacted C-CTOS p/n    "  ItemStyle-Width="800" DataField="C_CTOS" SortExpression="CATEGORY_NAME" />
								                   <asp:BoundField HeaderText="Impacted W-CTOS p/n    "  ItemStyle-Width="600" DataField="W_CTOS" SortExpression="CATEGORY_NAME" />
								                  	</Columns>
								                <FixRowColumn FixColumns="-1" FixRows="-1" TableHeight="400px" FixRowType="Header" />
								                <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
	                                            <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
	                                            <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
	                                            <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
	                                            <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
	                                            <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                                <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
								              
								            </sgv:SmartGridView>
								            
								            
										
										 
										 </td>
										 </tr>
										
										
				
										 </table>
                        </td>
                  	
                        <td style="height:6px;">
                           
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="vertical-align:bottom;"></td>
        </tr>
    </table>
        <script type="text/javascript" language="javascript">

 </script>
</asp:Content>

