<%@ Control Language="VB" ClassName="account_admin_block1" %>

<script runat="server">
    Dim strCompanyId As String, strOrgId As String
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        strCompanyId = Session("company_id")
        strOrgId = Session("company_org_id")
    End Sub
</script>

<span class="BLOCK">
	<!-- ******* Account Admin Navi (start) ********-->										
<table border="0" cellpadding="0" cellspacing="0" class="text" id="Table4">
	<tr>
		<td>
			<table width="200" border="0" cellpadding="0" cellspacing="0" id="Table5">
				<tr>
					<td width="19" align="right" valign="bottom"><img alt="" src="../images/ebiz.aeu.face/table_lefttop.gif" width="15" height="32"/></td>
					<td width="434" style="background-image:url(../images/ebiz.aeu.face/table_top.gif)" class="text">
						<div class="euNaviTableTitle">
							Account Admin Navi
						</div>
					</td>
					<td width="23" align="left" valign="bottom"><img alt="" src="../images/ebiz.aeu.face/table_righttop.gif" width="17" height="32"/></td>
				</tr>
				<tr>
					<td height="125" style="background-image: url(../Images/ebiz.aeu.face/table_left.gif);">
					</td>
					<td align="right" bgcolor="F5F6F7" valign="top">
						<table width="190" border="0" cellpadding="0" cellspacing="0" class="text" id="Table6">
							<tr>
								<td colspan="2" height="8"></td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" valign="middle" align="left"><a href="../admin/user_profile.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>"><div class="euNaviTableItem">Register New User</div>
									</a>
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" valign="middle" align="left"><a href="../admin/account_contact_new.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>"><div class="euNaviTableItem">Add New Contact</div>
									</a>
								</td>
							</tr>	
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" valign="middle" align="left"><div>&nbsp;Edit Company Profile</div>
								</td>
							</tr>
							<tr>
								<td width="22" height="20"><div align="center"><img alt="" src="../images/ebiz.aeu.face/square_blue.gif" width="6" height="6"/></div>
								</td>
								<td width="168" valign="middle" align="left"><a href="../admin/account_contact.aspx?company_id=<%=strCompanyId%>&org_id=<%=strOrgId%>"><div class="euNaviTableItem">Edit Contact Info</div>
									</a>
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
					<td style="background-image: url(../images/ebiz.aeu.face/table_down.gif)"></td>
					<td align="left" valign="top"><img alt="" src="../Images/ebiz.aeu.face/table_downright.gif" width="17" height="13"/></td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<!-- ******* Account Admin Navi (End) ********-->
</span>

