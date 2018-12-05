<%@ Control Language="VB" ClassName="incANAAdmin" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        HyperLink2.Visible =True 
    End Sub
</script>
<table cellpadding=0 cellspacing=0 width="98%">
    <tr>
		<!-- title folder -->
		<td>
			<table width="100%"  border="0" cellpadding="0" cellspacing="0" ID="Table1">
				<tr>
					<td width="28"><img src="../images/ebiz.aeu.face/titlefolder_left.gif" width="28" height="26"></td>
					<td width="142" background="../images/ebiz.aeu.face/titlefolder_middle.gif" class="text"><div align="center"><font color="000066"><b>ANA Administration</b></font></div></td>
					<td width="21"><img src="../images/ebiz.aeu.face/titlefolder_right.gif" width="21" height="26"></td>
					<td background="../images/ebiz.aeu.face/folder_line.gif">&nbsp;</td>
				</tr>
			</table>		
		</td>
	</tr>
	<tr><td height="8px"></td></tr>
    <tr>
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
											<td width="89%" align="left"><asp:HyperLink runat="server" ID="hl1" Text="Maintain Best Seller" NavigateUrl="~/Admin/AENC/ProductSelection.aspx" Font-Bold="true" ForeColor="#000099" /></td>
										</tr>
									</table>
								</td>
								<td width="50%">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table20">
											<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
												<td width="11%" height="22"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
												<td width="89%" align="left"><asp:HyperLink runat="server" ID="hl2" Text="ANA Sales Hierarchy" NavigateUrl="~/Admin/ANA/ANASalesHierarchy.aspx" Font-Bold="true" ForeColor="#000099" /></td>
											</tr>
									</table>
								</td>
							</tr>
						</table>	
					</td>
				</tr>
                <tr>
					<td valign="top" bgcolor="EEEEEE" align="left">
						<table width="100%" border="0" cellpadding="0" cellspacing="1" ID="Table4">
							<tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table19">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left"><asp:HyperLink runat="server" ID="hl3" Text="My Team's Project" NavigateUrl="~/Admin/ANA/MyTeamProject.aspx" Font-Bold="true" ForeColor="#000099" /></td>
										</tr>
									</table>
								</td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table19">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left"><asp:HyperLink runat="server" ID="hl4" Text="SyncSingleCBOMfromEUtoUS" NavigateUrl="~/WebCBOMEditor/SyncSingleCBOM.aspx" Font-Bold="true" ForeColor="#000099" /></td>
										</tr>
									</table>
                                </td>
							</tr>
						</table>	
					</td>
				</tr>
                 <tr>
					<td valign="top" bgcolor="EEEEEE" align="left">
						<table width="100%" border="0" cellpadding="0" cellspacing="1" ID="Table3">
							<tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table5">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left"><asp:HyperLink runat="server" ID="HyperLink1" Text="Special BTOS Admin" NavigateUrl="~/WEBCBOMEDITOR/Special.aspx" Font-Bold="true" ForeColor="#000099" /></td>
										</tr>
									</table>
								</td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table6">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HyperLink2" Text="Upload excel file of Pricelist" NavigateUrl="~/ADMIN/UploadANApricelist.aspx" Font-Bold="true" ForeColor="#000099" />
                                            </td>
										</tr>
									</table>
                                </td>
							</tr>
						</table>	
					</td>
				</tr>
                <tr>
					<td valign="top" bgcolor="EEEEEE" align="left">
						<table width="100%" border="0" cellpadding="0" cellspacing="1" ID="Table7">
							<tr bgcolor="#FFFFFF">
                                <td width="50%" height="25">
									<table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table8">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left">
                                            <asp:HyperLink runat="server" ID="HyperLink3" Text="Maintain Fast Delivery Items" NavigateUrl="~/ADMIN/AENC/FastDelivery.aspx" Font-Bold="true" ForeColor="#000099" />
                                            </td>
										</tr>
									</table>
								</td>
                                <td width="50%">
                                    <table width="100%" height="25" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table9">
										<tr onMouseOver="this.style.backgroundColor='#FFFBC0';"onMouseOut="this.style.backgroundColor='#FFFFFF'"> 
											<td width="11%"><div align="center"><img src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"></div></td>
											<td width="89%" align="left">
                                                <asp:HyperLink runat="server" ID="HyperLink4" Text="AMD Sales List Management" NavigateUrl="~/ADMIN/AMD_Sales_List.aspx" Font-Bold="true" ForeColor="#000099" />
                                            </td>
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