<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>


<script runat="server">

    Dim num_acc As Int16 = 0
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.Global_Inc1.ValidationStateCheck()
        If Not Page.IsPostBack Then
            'ICC 2014/09/22 To prevent user data is not complete in siebel_contact
            If Session("RBU") Is Nothing OrElse Session("Account_Status") Is Nothing Then
                Response.Redirect("~/home.aspx")
            End If
            Dim ws As New InternalWebService
            If Not ws.CanAccessABRQuotation(User.Identity.Name, Session("RBU"), Session("Account_Status")) Then
                Response.Redirect("~/home.aspx")
            End If
            gvQuoDataList_Bind(0)
        End If
    End Sub
    
    Private Sub gvQuoDataList_Bind(ByVal pageInx As Int16)
        Dim dt As New DataTable
        
        'dt = Me.Global_Inc1.dbGetDataTable("", "", "SELECT SEQ,UNICODE_ID,COMPANY_ID,COMPANY_NAME,HEADER_DESC,HEADER_AMOUNT,CREATE_TIME,QuotationID FROM QUOTATION_HEADER WHERE CREATER = '" & Session("user_id") & "' ORDER BY SEQ DESC")
        dt = dbUtil.dbGetDataTable("EQ", "SELECT SEQ,UNICODE_ID,COMPANY_ID,COMPANY_NAME,HEADER_DESC,HEADER_AMOUNT,CREATE_TIME,QuotationID FROM QUOTATION_HEADER_ABR WHERE CREATER = '" & Session("user_id") & "' ORDER BY SEQ DESC")
        
        gvQuoList.DataSource = dt
        gvQuoList.PageIndex = pageInx
        gvQuoList.DataBind()
        'SqlDataSource1.SelectCommand = "SELECT SEQ,UNICODE_ID,COMPANY_ID,COMPANY_NAME,HEADER_DESC,HEADER_AMOUNT,CREATE_TIME,QuotationID FROM QUOTATION_HEADER WHERE CREATER = '" & Session("user_id") & "' ORDER BY SEQ DESC"
        'gvQuoList.PageIndex = pageInx
        
    End Sub
    
    Protected Sub gvQuoList_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        
        
        If (e.Row.RowType = DataControlRowType.DataRow Or e.Row.RowType = DataControlRowType.Header) Then
            e.Row.Cells(0).Visible = False
            e.Row.Cells(1).Visible = False
            If (e.Row.RowType = DataControlRowType.DataRow) Then
                Me.num_acc = Me.num_acc + 1
                e.Row.Cells(2).Text = Me.num_acc.ToString()
                Try
                    If e.Row.Cells(5).Text.Length > 50 Then
                        e.Row.Cells(5).Text = e.Row.Cells(5).Text.ToString().Substring(0, 50) & "..."
                    End If
                    
                    'e.Row.Cells(8).Text = "<a href='../../Files/ABRQuotationFile/" & e.Row.Cells(8).Text & ".pdf' target=_blank>" & e.Row.Cells(8).Text & "</a>"
                Catch ex As Exception
                    'do nothing
                End Try
            End If
        End If
    End Sub

    Protected Sub gvQuoList_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gvQuoDataList_Bind(e.NewPageIndex)
    End Sub
    
    Protected Sub gvQuoList_RowEditing(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewEditEventArgs)
        Response.Redirect("./b2b_quotation.aspx?unicodeid=" & Me.gvQuoList.Rows(e.NewEditIndex).Cells(1).Text)
    End Sub
    
    Protected Sub gvQuoList_RowDeleting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewDeleteEventArgs)
        Dim strSQL As String = ""
        strSQL = "DELETE QUOTATION_HEADER_ABR WHERE SEQ = '" & Me.gvQuoList.Rows(e.RowIndex).Cells(0).Text & "' AND CREATER = '" & Session("user_id") & "'"
        
        'Me.Global_Inc1.dbDataReader("", "", strSQL)
        dbUtil.dbExecuteNoQuery("EQ", strSQL)
        
        strSQL = "DELETE QUOTATION_LIST_ABR WHERE UNICODE_ID = '" & Me.gvQuoList.Rows(e.RowIndex).Cells(1).Text & "'"

        'Me.Global_Inc1.dbDataReader("", "", strSQL)
        dbUtil.dbExecuteNoQuery("EQ", strSQL)

        strSQL = "DELETE QUOTATION_LIST_TEMP_ABR WHERE UNICODE_ID = '" & Me.gvQuoList.Rows(e.RowIndex).Cells(1).Text & "'"

        'Me.Global_Inc1.dbDataReader("", "", strSQL)
        dbUtil.dbExecuteNoQuery("EQ", strSQL)

        gvQuoDataList_Bind(0)
    End Sub
   
    Protected Sub LBDownloadPDF_Click(sender As Object, e As System.EventArgs)
        
        Dim obj As LinkButton = CType(sender, LinkButton), row As GridViewRow = CType(obj.NamingContainer, GridViewRow)
        
        Dim _sql As New StringBuilder
        _sql.AppendLine("Select top 1 UNICODE_ID,QuotationID,FILE_DATA,LAST_UPDATED,LAST_UPDATED_BY From QUOTATION_FILE_ABR")
        _sql.AppendLine(" Where UNICODE_ID='" & row.Cells(1).Text & "'")
        _sql.AppendLine(" Order by LAST_UPDATED Desc")
        
        Dim dt As DataTable = dbUtil.dbGetDataTable("EQ", _sql.ToString)
        
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            Response.Clear()
            Response.Buffer = True
            Response.ContentType = ""
            Response.AddHeader("content-disposition", "attachment;filename=" + dt.Rows(0).Item("QuotationID") + ".pdf")     ' to open file prompt Box open or Save file         
            Response.Charset = ""
            Response.Cache.SetCacheability(HttpCacheability.NoCache)
            Response.BinaryWrite(dt.Rows(0).Item("FILE_DATA"))
            Response.End()

        End If
 
        
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%" border="0" cellspacing="0" cellpadding="0"> 
	<tr> 
	    <td> 
	        <%--<hdr:header runat="server" ID="Hearder1"></hdr:header >--%>
	    </td> 
	</tr>
	<tr> 
	    <td style="height:3px"> 
	        <!--Buffer--> &nbsp; 
	    </td> 
	</tr> 
	
	<tr> 
	    <td> 
	        <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0"> 
	            <tr> 
	                <td style="width:10px"></td> 
	                <td></td> 
	                <td style="width:20px"></td> 
	            </tr> 
	            <tr> 
	                <td colspan="3" style="height:15px"> </td> 
	            </tr> 
	            <tr> 
	                <td style="width:10px"></td> 
	                <td> <!--Page Title--> 
	                    <div class="euPageTitle">Quotation List</div> 
	                </td> 
	                <td style="width:20px"></td> 
	            </tr> 
	            <tr> 
	                <td colspan="3" style="height:15px"> </td> 
	            </tr> 
	            <tr> 
	                <td style="width:10px"> </td> 
	                <td valign="top"> 
	                    <table border="0" cellpadding="0" cellspacing="0"> 
	                        <tr>
	                            <td>
	                                <table width="100%" border="0" cellpadding="0" cellspacing="0" id="Table3" style="vertical-align:top"> 
	                                    <tr> 
	                                        <td style="width:300px"> 
	                                            <table width="300px" border="0" cellpadding="0" cellspacing="0" class="text" id="Table4"> 
	                                                <tr> 
	                                                    <td style="width:1%" rowspan="2"><img alt="" src="../../images/ebiz.aeu.face/bluefolder_left.jpg" width="7" height="23"/></td> 
	                                                    <td style="width:98%; background-color:#A3BFD4"  valign="top"><img alt="" src="../../images/bluefolder_top.jpg" width="138" height="3"/></td> 
	                                                    <td style="width:1%"  rowspan="2"><img alt="" src="../../images/bluefolder_right.jpg" width="7" height="23"/></td> 
	                                                </tr> 
	                                                <tr>
	                                                    <td class="euFormCaption" style="height: 19px" align="right">List</td>	
													</tr>		
												</table>
											</td>
											<td style="width:300px" align="right">
											    <a href ="B2B_Quotation.aspx"><b>Create New Quotation</b></a>
											</td>
										</tr>
										<tr>
										    <td style="height:5px; width:900px; background-color:#A0BFD3" colspan="2" ></td>
										</tr>
										<tr>
										    <td style="height:50px;border:#A4B5BD 1px solid" colspan="2">
                                                <asp:Panel ID="pnlList" runat="server">
                                                    <table style="height:100%;border:#F1F2F4 1px solid; vertical-align:top" border="0" cellpadding="0" cellspacing="1">
											        <tr>
											            <td style="height:100px" valign="top">
											                <asp:GridView ID="gvQuoList" runat="server" AutoGenerateColumns ="False" Width="900px" 
											                     PageSize = "15" AllowPaging="true"
											                     OnRowDataBound="gvQuoList_RowDataBound" 
											                     OnPageIndexChanging="gvQuoList_PageIndexChanging" 
											                     OnRowDeleting="gvQuoList_RowDeleting" 
											                     OnRowEditing="gvQuoList_RowEditing" CellPadding="4" ForeColor="#333333" GridLines="None">
											                    <Columns>
											                        <asp:BoundField DataField = "SEQ" HeaderText = "SEQ" ReadOnly ="True" />
											                            
											                        <asp:BoundField DataField = "UNICODE_ID" HeaderText = "UNICODE" ReadOnly ="True" />
											                        <asp:BoundField HeaderText = "NO" ReadOnly ="True" >
											                            <ItemStyle HorizontalAlign="Left" Height="20px" />
											                            <HeaderStyle HorizontalAlign="Center" Width ="20px"/>
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "company_id" HeaderText = "Company ID" ReadOnly ="True" >
											                            <ItemStyle HorizontalAlign="Center" Height="20px" />
											                            <HeaderStyle HorizontalAlign="Center" Width ="80px"/>
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "company_name" HeaderText = "Company Name" ReadOnly ="True" >
											                            <ItemStyle HorizontalAlign="Left" Height="20px" />
											                            <HeaderStyle HorizontalAlign="Center" Width ="200px" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "header_desc" HeaderText = "Description" ReadOnly ="True">
											                            <ItemStyle HorizontalAlign="Left" Width="300px" />
											                            <HeaderStyle HorizontalAlign="Center" Width ="300px"/>
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "header_amount" HeaderText = "Amount" ReadOnly ="True">
											                            <ItemStyle HorizontalAlign="Right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="Center" Width ="80px" />
											                        </asp:BoundField>
											                        <asp:BoundField DataField = "create_time" HeaderText = "Create Time" ReadOnly ="True" >
											                            <ItemStyle HorizontalAlign="Right" Height="20px" />
											                            <HeaderStyle HorizontalAlign="Center" Width ="100px" />
											                        </asp:BoundField>
                                                                    <asp:TemplateField>
                                                                        <HeaderTemplate>
                                                                            <asp:Label runat="server" ID="lbPDF" Text="PDF"></asp:Label>
                                                                        </HeaderTemplate>
                                                                        <ItemTemplate>
                                                                            <asp:LinkButton ID="LBDownloadPDF" runat="server" Text='<%#Bind("QUOTATIONID")%>'  OnClick="LBDownloadPDF_Click" />
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:CommandField ButtonType="Image" HeaderText="Action" ShowDeleteButton="True"
                                                                        DeleteImageUrl="~/Images/16-circle-red-remove.png" EditImageUrl="~/Images/16-em-pencil.png"
                                                                        ShowEditButton="True">
                                                                        <HeaderStyle HorizontalAlign="Center" />
                                                                        <ItemStyle HorizontalAlign="Center" />
                                                                    </asp:CommandField>
                                                                </Columns>
                                                                <PagerStyle CssClass="pgr" BackColor="#2461BF" ForeColor="#0033CC" 
                                                                    HorizontalAlign="Center" />
											                    <AlternatingRowStyle CssClass="alt" BackColor="White" />
                                                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                                                <RowStyle BackColor="#EFF3FB" />
                                                                <EditRowStyle BackColor="#2461BF" />
                                                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                                                <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
											                </asp:GridView>
											            </td>
											            
											        </tr>
											        <tr id = "trErrMsg" visible="true" style="height:20px; width:290px" runat="server">
											            <td valign="top" id = "tdErrMsg" runat="server" style="color:Red"></td>
											        </tr>
											    </table>
                                                </asp:Panel>
											    
											</td>
									    </tr>	
									</table>
	                            </td>
	                        </tr>
	                    </table>
					</td>
					<td style="width:20px"></td>
				</tr>
	        </table>
		</td>
	</tr>
	<tr>
	    <td align="center" style="height:20px" >
		    <!--Footer-->
			<!--include virtual='/utility/footer_inc.asp' -->
			<%--<ftr:footer runat="server" ID="Footer1" ></ftr:footer >--%>
        </td>
	</tr>
	</table>
 </asp:Content>