<%@ Control Language="VB" ClassName="OrderTrackingNavi_Inc" %>

<script runat="server">
    Protected Sub hl2_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hl2.NavigateUrl = "/order/BO_b2borderinquiry.aspx?company_id=" & Session("COMPANY_ID")
    End Sub

    Protected Sub hl3_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hl3.NavigateUrl = "/order/BO_BackOrderInquiry.aspx?company_id=" & Session("COMPANY_ID")
    End Sub

    Protected Sub hl4_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hl4.NavigateUrl = "/order/BO_invoiceinquiry.aspx?company_id=" & Session("COMPANY_ID")
    End Sub

    Protected Sub hl5_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hl5.NavigateUrl = "/order/ARInquiry_WS.aspx?company_id=" & Session("COMPANY_ID")
    End Sub

    Protected Sub hl6_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hl6.NavigateUrl = "/order/BO_serialinquiry.aspx?company_id=" & Session("COMPANY_ID")
    End Sub

    Protected Sub hl7_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hl7.NavigateUrl = "/order/BO_forwardertracking.aspx?company_id=" & Session("COMPANY_ID")
    End Sub
</script>
<table border="0" cellpadding="0" cellspacing="0" class="text" id="Table1">
	<tr>
		<td>
			<table width="200" border="0" cellpadding="0" cellspacing="0" id="Table5">
				<tr>
					<td width="19" align="right" valign="bottom"><img alt="" src="../images/ebiz.aeu.face/table_lefttop.gif" width="15" height="32"/></td>
					<td width="434" style="background-image:url(../images/ebiz.aeu.face/table_top.gif);background-position: bottom;" class="text">
						<div class="euNaviTableTitle">
							Advantech Order Tracking
						</div>
					</td>
					<td width="23" align="left" valign="bottom"><img alt="" src="../images/ebiz.aeu.face/table_righttop.gif" width="17" height="32"/></td>
				</tr>
				<tr>
					<td height="125" style="background-image: url(../Images/ebiz.aeu.face/table_left.gif);">
					</td>
					<td align="right" bgcolor="F5F6F7" valign="top">
						<table width="190" border="0" cellpadding="0" cellspacing="0" class="text" id="Table4">
							<tr>
								<td colspan="2" height="8"></td>
							</tr>
							<tr style="display:none;">
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hl1" NavigateUrl="/Order/BO_OrderTracking.aspx" Text="Check Order Status" />
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hlShippingCalendar" NavigateUrl="/Order/ShippingCalendar.aspx" Text="Shipping Calendar" />
								</td>
							</tr>
							<tr style="display:none;">
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hl2" Text="My B2B Order" OnLoad="hl2_Load" />
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hlMyRMA" NavigateUrl="/Order/MyRMA.aspx" Text="My RMA Order" />
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hl3" Text="Back Order Inquiry" OnLoad="hl3_Load" />
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hl4" Text="Invoice Inquiry" OnLoad="hl4_Load" />
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hl5" Text="A/P Inquiry" OnLoad="hl5_Load" />
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hl6" Text="Serial Number Inquiry" OnLoad="hl6_Load" />
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" align="left">
								    <asp:HyperLink runat="server" ID="hl7" Text="Forwarder Number Tracking" OnLoad="hl7_Load" />
								</td>
							</tr>
							<tr>
								<td colspan="2" height="8"></td>
							</tr>
						</table>
					</td>
					<td style="background-image: url(../images/ebiz.aeu.face/table_right.gif)">
					</td>
				</tr>
				<tr>
					<td align="right" valign="top"><img alt="" src="../images/ebiz.aeu.face/table_downleft.gif" width="15" height="13"/></td>
					<td style="background-image: url(../images/ebiz.aeu.face/table_down.gif);background-position: top;"></td>
					<td align="left" valign="top"><img alt="" src="../Images/ebiz.aeu.face/table_downright.gif" width="17" height="13"/></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
