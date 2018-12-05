<%@ Control Language="VB" ClassName="incESalesAdminl" %>

<script runat="server">

</script>
<table cellpadding=0 cellspacing=0 width="98%">
	<tr>
		<!-- title folder -->
		<td>
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" ID="Table1">
				<tr>
					<td width="28"><img src="../images/ebiz.aeu.face/titlefolder_left.gif" width="28" height="26"></td>
					<td width="142" background="../images/ebiz.aeu.face/titlefolder_middle.gif" class="text"><div align="center"><font color="000066"><b>Order Change Request</b></font></div></td>
					<td width="21"><img src="../images/ebiz.aeu.face/titlefolder_right.gif" width="21" height="26"></td>
					<td background="../images/ebiz.aeu.face/folder_line.gif">&nbsp;</td>
				</tr>
			</table>		
		</td>
	</tr>
	<tr><td height="8px"></td></tr>
	<tr>
		<!-- main table -->
		<td>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" ID="Table2">
				<tr>
					<td valign="top" bgcolor="EEEEEE">
						<table width="100%" border="0" cellpadding="0" cellspacing="1" ID="Table18">
							<tr bgcolor="#FFFFFF">
								<td width="50%" height="25">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table19">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left"><a href="../OrderChangeRequest/srOrderChange.aspx"><b><font color="000099">New Order Change Request</font></b></a></td>
										</tr>
									</table>
								</td>
								<td width="50%">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table20">
											<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
												<td width="11%" height="22"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
												<td width="89%" align="left"><a href="../OrderChangeRequest/srMyOrderChange.aspx"><b><font color="000099">My Order Change Requests</font></b></a></td>
											</tr>
									</table>
								</td>
							</tr>
						</table>	
					</td>
				</tr>
				<tr>
					<td valign="top" bgcolor="EEEEEE">
						<table width="100%" border="0" cellpadding="0" cellspacing="1" ID="Table4">
							<tr bgcolor="#FFFFFF">
								<td width="50%" height="25">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table5">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left"><a href="../OrderChangeRequest/srManagerOrderChange.aspx"><b><font color="000099">Order Change Manager</font></b></a></td>
										</tr>
									</table>
								</td>
								<td width="50%">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table6">
											<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
												<td width="11%" height="22"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
												<td width="89%" align="left"><a href="../OrderChangeRequest/srAdminOrderChange.aspx"><b><font color="000099">All Order Change Requests</font></b></a></td>
											</tr>
									</table>
								</td>
							</tr>
						</table>	
					</td>
				</tr>
				<tr>
					<td valign="top" bgcolor="EEEEEE">
						<table width="100%" border="0" cellpadding="0" cellspacing="1" ID="Table3">
							<tr bgcolor="#FFFFFF">
								<td width="50%" height="25">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table7">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left"><a href="../OrderChangeRequest/srAdminOrderChangeLine.aspx"><b><font color="000099">All Order Change Lines</font></b></a></td>
										</tr>
									</table>
								</td>
								<td width="50%">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table8">
											<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
												<%--<td width="11%" height="22"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
												<td width="89%" align="left"><a href=""><b><font color="000099"></font></b></a></td>--%>
											</tr>
									</table><table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table9">
                                        <tr>
                                            <td width="11%">
                                                <div align="center">
                                                    <img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div>
                                            </td>
                                            <td width="89%" align="left"><a href="OrdersChangedInSAP.aspx">
                                                <b><font color="000099">Changes in Orders within SAP</font></b></a> </td>
                                        </tr>
                                    </table>
								</td>
							</tr>
						</table>	
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>