<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Order Confirmation" %>
<%@ Register TagPrefix="uc3" TagName="OrderFlowState" Src="~/Includes/OrderFlowState.ascx" %>

<script runat="server">
    Dim strThanks As String = ""
    Dim strLink As String = ""
    Dim m_strHTML As String = ""
    Dim x_strHTML As String = ""
    Dim g_strMessage As String = ""
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Me.GlobalInc.ValidationStateCheck()
        
        Dim exefuncM As Integer = 0
        Dim exefuncX As Integer = 0
        Dim exef As Integer = 0
        Dim strOrderId As String = Request("order_id")
        Dim strOrderNo As String = Request("order_no")
        Dim flagExist As String = Request("flag")
        If flagExist = "Yes" Then
            strThanks = "You have placed the same order twice ! We will keep your first order only."
            strLink = "<a href=""..\home.aspx"">|&nbsp;Back To Home</a>&nbsp;|&nbsp;<a href=""cart_list.aspx"">Place New Order</a>&nbsp;|"
            'execFunc = GetPI(strOrderNo,"ORDER_CONFIRM",x_strHTML)

            '------------------------------------------------------------------------------------------
            'added by prie to display the link of pb2b order list, 08.04.05
            If Request.QueryString("msg_id") <> "" Then
                strLink = strLink & "&nbsp;<a href='\pb2b\pb2bOrderDetail.aspx?msg_id=" & Request.QueryString("msg_id") & "'>More Orders</a>&nbsp;|"
            End If
            'added by prie to display the link of pb2b order list, 08.04.05
            '------------------------------------------------------------------------------------------
	
        ElseIf flagExist = "Empty" Then
            strThanks = "There is no line in the order, please place it again."
            strLink = "<a href=""..\home.aspx"">|&nbsp;Back To Home</a>&nbsp;|&nbsp;<a href=""cart_list.aspx"">Place Order</a>&nbsp;|"

            '------------------------------------------------------------------------------------------
            'added by prie to display the link of pb2b order list, 08.04.05
            If Request.QueryString("msg_id") <> "" Then
                strLink = strLink & "&nbsp;<a href='\pb2b\pb2bOrderDetail.aspx?msg_id=" & Request.QueryString("msg_id") & "'>More Orders</a>&nbsp;|"
            End If
            'added by prie to display the link of pb2b order list, 08.04.05
            '------------------------------------------------------------------------------------------
        Else
            strThanks = "Thanks for your order: " & strOrderNo & "."
            strLink = "<a href='javascript:void DoPrint();'>Print</a>&nbsp;" & "|&nbsp;<a href=""..\home.aspx"">Back To Home</a>&nbsp;|&nbsp;<a href=""cart_list.aspx"">Place New Order</a>&nbsp;|"

            '------------------------------------------------------------------------------------------
            'added by prie to display the link of pb2b order list, 08.04.05
            If Request.QueryString("msg_id") <> "" Then
                strLink = strLink & "&nbsp;<a href='\pb2b\pb2bOrderDetail.aspx?msg_id=" & Request.QueryString("msg_id") & "'>More Orders</a>&nbsp;|"
            End If
            'added by prie to display the link of pb2b order list, 08.04.05
            '------------------------------------------------------------------------------------------
            '--{2005-10-12}--Daive: create Changed Msg Form
            '-------------------------------------------------------------
            exefuncM = OrderUtilities.Show_ChangedMsgOfOrder(strOrderId, strOrderNo, m_strHTML)
            'response.write("Error in here!!!"):response.end
            '-------------------------------------------------------------
            ' If LCase(Session("USER_ROLE")) = "buyer" Or LCase(Session("USER_ROLE")) = "guest" Then
            If Request.IsAuthenticated Or Request.IsAuthenticated = False Then
                Session("xInternalFlag") = "external_C"
                exefuncX = OrderUtilities.GetPI(strOrderNo, "ORDER_CONFIRM", x_strHTML)
                Session("xInternalFlag") = ""
            Else
                Session("xInternalFlag") = "internal_C"
                exefuncX = OrderUtilities.GetPI(strOrderNo, "ORDER_CONFIRM", x_strHTML)
                Session("xInternalFlag") = ""
            End If
        End If
        g_strMessage = g_strMessage + ""
    End Sub

</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main"> 
<div>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr valign="top">
				<td>
					
    	            
				</td>
			</tr>			
			<tr>	
				<td>
				   <uc3:OrderFlowState runat="server" id="OrderFlowState1" />
				</td>
			</tr>
			<tr valign="top">
				<td>
					<table width="100%" ID="Table2">						
						<tr valign="top">
							<td height="2">&nbsp;
							</td>
						</tr>
						<tr valign="top">
							<td class="euPageTitle"> 
								Order Confirmation<span class="PageMessageBar"><%=g_strMessage%></span>
							</td>
						</tr>
						<tr valign="top">
							<td height="2">&nbsp;
							</td>
						</tr>
						<tr valign="top">
							<td height="2">
								<table>
									<tr>
										<td width="150">
											&nbsp;
										</td>
										<td colspan="2" width="450">
											<font size="3" color="green">
												<b><%=strThanks%></b>
											</font>	
										</td>
										<td align="right"><font size='2' color="green"><b>
											<%=strLink%>
											</b></font>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr valign="top">
							<td height="2">&nbsp;
							</td>
						</tr>
						<tr valign="top">
							<td height="2">&nbsp;<hr>
							</td>
						</tr>
						
	
				
						<tr valign="top">
							<td height="2">&nbsp;
							</td>
						</tr>
						<tr valign="top">
							<td align="center" valign="center">
                               <div name="PrintArea2" id="PrintArea2" >								
								<%
								    m_strHTML = "<link href=""http://my.advantech.eu/INCLUDES/ebiz.aeu.style.css"" rel=""stylesheet"">" & m_strHTML
								    Response.Write(m_strHTML)
								%>
                               </div>
							</td>
						</tr>	
						<tr valign="top">
							<td height="2">&nbsp;
							</td>
						</tr>
			
			
						<tr valign="top">
							<td align="center" valign="center">
                               <div name="PrintArea" id="PrintArea" >
								<%
								    x_strHTML = "<link href=""http://my.advantech.eu/INCLUDES/ebiz.aeu.style.css"" rel=""stylesheet"">" & x_strHTML%>
								<%=x_strHTML%>
                               </div>
							</td>
						</tr>	

						<tr valign="top">
							<td height="2">
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr valign="top">
				<td height="2">&nbsp;
				</td>
			</tr>
	
			<tr valign="top">
				<td>
					
		            
				</td>
			</tr>
		</table></div>
<script type="text/javascript" language='JavaScript'>
	function DoPrint()
	{
		var text;
		var text1;
		text = PrintArea.innerHTML;	
		
		text1 = PrintArea2.innerHTML;	
				document.open();
				document.write("");
				document.write(text1+text);
				document.close();
			    print();
				window.location.href = window.location.href;
	}
</script>
</asp:Content>