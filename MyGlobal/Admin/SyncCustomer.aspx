<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Synchronize Company From SAP to MyAdvantech" %>

<script runat="server">
    
    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetERPId(ByVal prefixText As String, ByVal count As Integer) As String()
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Return Nothing
        prefixText = Replace(Trim(prefixText), "'", "").ToUpper()
        Dim dt = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format("select distinct kunnr from saprdp.kna1 where rownum<=20 and kunnr like 'E%' and kunnr like '{0}%' order by kunnr", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
   
    Protected Sub btnSync_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim errMsg As String = ""
        'Dim SC As New SAPDAL.syncSingleCompany
        Dim CL As New ArrayList
        CL.Add(Me.txtCustId.Text.Trim)
        Dim ds As SAPDAL.DimCompanySet = SAPDAL.syncSingleCompany.syncSingleSAPCustomer(CL, False, errMsg)
        If IsNothing(ds) Then
            Me.lbMsg.Text = errMsg
            Exit Sub
        End If

        GridView1.DataSource = ds.Company : GridView1.DataBind()
        lbMsg.Text = "Company Id synchronized successfully"
        Dim dt2 As DataTable = dbUtil.dbGetDataTable("my", "select top 1 * from dbo.SAP_DIMCOMPANY where COMPANY_ID = '" + txtCustId.Text.Trim.Replace("'", "").ToUpper() + "'")
        GridView2.DataSource = dt2 : GridView2.DataBind()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Request("companyid") IsNot Nothing AndAlso Request("companyid").ToString <> "" Then
                txtCustId.Text = Request("companyid").ToString.Trim
                If Request("auto") IsNot Nothing AndAlso Request("auto").ToString = "1" Then
                    Me.btnSync_Click(Me.btnSync, Nothing)
                End If
            End If
        End If
      
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">		
		<tr valign="top">
			<td>
				<table width="100%">
					<tr valign="top">
						<td height="2">&nbsp;
						</td>
					</tr>
					<tr valign="top">
						<td class="pagetitle">
							<table width="100%" id="Table1">
								<tr>
									<td>
										&nbsp;&nbsp;<img src="../images/title-dot.gif" width="25" height="17" alt="" />
										<font size=5 color="#000080"><b>Synchronize Customer and Ship-to</b></font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;										
									</td>
									<td align="right" valign="bottom">
									    <font face="Arial" color="RoyalBlue"></font> 										
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
						<td valign="top">
							<table width="1000px">
								<tr>
									<td align="right" width="200">&nbsp;&nbsp;&nbsp;<font size="2"><b>Customer ID:</b></font>&nbsp;
									</td>
									<td width="30">
									    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" TargetControlID="txtCustId" MinimumPrefixLength="2" ServiceMethod="GetERPId" CompletionInterval="1000" />
										<asp:TextBox runat="server" ID="txtCustId" Width="200px" />
									</td>
									<td>
										<asp:Button runat="server" ID="btnSync" Text="Synchronize" OnClick="btnSync_Click" />
									</td>
									<td>
									    <font face="Arial" size="2" color="Crimson">
										   <%-- <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
										        <ContentTemplate>--%>
										            <asp:Label runat="server" ID="lbMsg" Font-Bold="true" />
										        <%--</ContentTemplate>
										        <Triggers>
										            <asp:AsyncPostBackTrigger ControlID="btnSync" EventName="Click" />
										        </Triggers>
										    </asp:UpdatePanel>	--%>									    
										</font>
									</td> 
								</tr>
							</table>			
                        </td>
					</tr>	                   
				</table>
			</td>
		</tr>
		<tr valign="top">
			<td height="350">
                <asp:GridView ID="GridView1" Visible="false" runat="server">
                </asp:GridView>
                <asp:GridView ID="GridView2" Visible="false" runat="server">
                </asp:GridView>
            </td>
		</tr>
	</table>
</asp:Content>

