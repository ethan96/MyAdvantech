<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Admin Portal" %>
<%@ Register Src="~/Includes/incAPAdminB2B.ascx" TagName="incAPAdminB2B" TagPrefix="uc1" %>
<%@ Register Src="~/Includes/incAPAdmin.ascx" TagName="incAPAdmin" TagPrefix="uc2" %>
<%@ Register Src="~/Includes/incESalesAdmin.ascx" TagName="incESalesdmin" TagPrefix="uc5" %>
<%@ Register Src="~/Includes/incAPAdminSys.ascx" TagName="incAPAdminSys" TagPrefix="uc3" %>
<%@ Register src="~/Includes/OrderingBlock.ascx" tagname="OrderingBlock" tagprefix="uc7" %>
<%@ Register src="~/Includes/ProductInfoBlock.ascx" tagname="ProductInfoBlock" tagprefix="uc8" %>
<%@ Register Src="~/Includes/BillboardBlock.ascx" TagName="BillboardBlock" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/incANAAdmin.ascx" TagName="ANABlock" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/incHQDCAdmin.ascx" TagName="HQDCBlock" TagPrefix="uc11" %>
<%@ Register Src="~/Includes/incCBOMV2Admin.ascx" TagName="CBOMV2Block" TagPrefix="uc12" %>
<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'If IsNothing(Session("user_role")) Then
        '    Response.Redirect("~/home.aspx")
        'End If
        'If Session("user_role").ToString().ToLower() <> "administrator" And Session("user_role").ToString().ToLower() <> "logistics" Then
        If (Not Util.IsAEUIT()) AndAlso (Not Util.IsInternalUser2()) Then
            Response.Redirect("~/home.aspx")
        End If
        If Util.IsANAPowerUser() = True Or Util.IsAEUIT() = True Then
            incANAAdmin.Visible = True
        End If
        If Util.IsAEUIT() = True Or MailUtil.IsInRole("InterCon.ALL") Then
            incHQDCAdmin.Visible = True
        End If
    End Sub
    Protected Function isCtosAdmin() As Boolean
        If Util.IsAEUIT() OrElse MailUtil.IsInRole("AEU.CTOS") OrElse Util.isCtosAdmin() OrElse MailUtil.IsInRole("group ACL.ACG.RD") = True OrElse MailUtil.IsInRole("PM.EICG.ACL") OrElse MailUtil.IsInRole("CTOS.PE") Then
            Return True
        Else
            Return False
        End If
    End Function

    Protected Function isCBOMV2Admin() As Boolean
        If Util.IsAEUIT() OrElse MailUtil.IsInRole("CTOS.PE") Then
            Return True
        Else
            Dim ORGID As String = Session("org_id").ToString().ToUpper().Substring(0, 2)
            If Session("org_id_cbom") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Session("org_id_cbom").ToString()) Then
                ORGID = Session("org_id_cbom").ToString().ToUpper().Substring(0, 2)
            End If
            Dim obj As Object = dbUtil.dbExecuteScalar("CBOMV2", "select count(*) from CBOM_Admin where USERID = '" + Session("user_id").ToString() + "' and ORGID = '" + ORGID + "'")
            If obj IsNot Nothing AndAlso Convert.ToInt32(obj.ToString()) > 0 Then
                Return True
            Else
                Return False
            End If
        End If
    End Function
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
 <table border="0" width="100%"  cellspacing="0" cellpadding="0"> 
    <tr>
		<td>
			
		</td>
	</tr>
	<tr>
		<td height="3" colspan="1"></td>
	</tr>
    <tr align="left">
		<td width="100%" valign="top">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td align="center" valign="top" style="width: 90%">
                        &nbsp;<uc1:incAPAdminB2B ID="IncAPAdminB2B1" runat="server" />											 
					</td>
				</tr>
				<%If isCtosAdmin() = True Then%>
				<tr>
					<td height="15" style="width: 90%"></td>
				</tr>
				<tr>
					<td valign="top" align="center" style="width: 90%">
                        &nbsp;
                        <uc2:incAPAdmin ID="IncAPAdmin1" runat="server" />
					</td>
				</tr>
				<%End If%>
                <%If isCBOMV2Admin() = True Then%>
				<tr>
					<td height="15" style="width: 90%"></td>
				</tr>
				<tr>
					<td valign="top" align="center" style="width: 90%">
                        &nbsp;
                        <uc12:CBOMV2Block ID="IncCBOMV2Admin" runat="server" />
					</td>
				</tr>
				<%End If%>
				<!-- Order Change Request -->
				<tr>
					<td height="15" style="width: 90%"></td>
				</tr>
				<tr>
					<td valign="top" align="center" style="width: 90%">
                        &nbsp;
                        <%--<uc5:incESalesdmin ID="incESalesdmin1" runat="server" />--%>
                        <uc10:ANABlock runat="server" ID="incANAAdmin" Visible="false" />
					</td>
				</tr>
				<!-- System Admin -->
				<tr>
					<td height="15" style="width: 90%"></td>
				</tr>
                <tr>
					<td valign="top" align="center" style="width: 90%">
                        &nbsp;
                        <%--<uc5:incESalesdmin ID="incESalesdmin1" runat="server" />--%>
                        <uc11:HQDCBlock runat="server" ID="incHQDCAdmin" Visible="false" />
					</td>
				</tr>                    
			</table>
		</td>
	</tr>
	<tr>
		<td height="10" colspan="1"></td>
	</tr>
	<tr>
		<td colspan="1">
			
		</td>
	</tr>
</table>
</asp:Content>

