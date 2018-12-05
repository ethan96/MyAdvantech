<%@ Page Language="VB"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Dim PageName As String = ""
    Dim FormName As String = ""
    Dim ElementName As String = ""
    Dim CustIDCondition As String = ""
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        'GlobalInc.ValidationStateCheck()
        
        If Request.QueryString("Page") <> "" Then
            PageName = Request.QueryString("Page")
            Session("PageName") = PageName
        Else
            PageName = Session("PageName")
        End If
        If Request.QueryString("Form") <> "" Then
            FormName = Request.QueryString("Form")
            Session("FormName") = FormName
        Else
            FormName = Session("FormName")
        End If
        If Request.QueryString("Element") <> "" Then
            ElementName = Request.QueryString("Element")
            Session("ElementName") = ElementName
        Else
            ElementName = Session("ElementName")
        End If

        If Request.QueryString("CustID") <> "" Then
            CustIDCondition = " and (companyid like '%" & Request.QueryString("CustID") & "%' or companyname like '%" & Request.QueryString("CustID") & "%') "
        Else
            CustIDCondition = " "
        End If
        'Session("COMPANY_ID") = "UUAAESC"
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select company_id,company_name,address,attention from sap_dimcompany where  "))
            .AppendLine(String.Format(" ( "))
            .AppendLine(String.Format(" 	(parentcompanyid='{0}' AND company_Type in ('Ship_To','Z002'))  ", Session("company_ID")))
            .AppendLine(String.Format(" 	or  "))
            .AppendLine(String.Format(" 	company_id like '{0}%' ", Session("company_ID")))
            .AppendLine(String.Format(" ) and company_id not in ('EDDEDR05B','ENSEIN01H','EKSGVE01A','ENNLBO02G','ENNLBO02I') "))
        End With
        Dim strSqlCmd As String = sb.ToString()
        'strSqlCmd = "select company_id,company_name,address,attention from company where " & _
        '    "((parent_company_id='" & Session("company_ID") & "' AND company_Type='Ship_To') or company_id like '" & Session("company_ID") & "%') and company_id not in ('EDDEDR05B','ENSEIN01H','EKSGVE01A','ENNLBO02G','ENNLBO02I')"
        
        Me.SqlDataSource1.SelectCommand = strSqlCmd

        
    End Sub
    
   

    
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType <> DataControlRowType.Header And e.Row.RowType <> DataControlRowType.Footer Then
            Dim CompanyId As String = e.Row.Cells(0).Text
            Dim CompanyAttn As String = e.Row.Cells(3).Text.Replace(" ", "\.")
            CompanyAttn = CompanyAttn.Replace("'", "\'")
            e.Row.Cells(0).Text = "<a href=# onClick=copopulate('" & CompanyId & "','" & CompanyAttn & "') >" & e.Row.Cells(0).Text & "</a>"
        End If
    End Sub
</script>

<script type="text/javascript" language="javascript">
function copopulate(company,ShipToAttn)
   	{
   
  	//alert (company);
    //alert (ShipToAttn);
//window.opener.aspnetForm.ctl00$_main$DropShip.value=company;
window.opener.document.aspnetForm.ctl00$_main$DropShip.value=company;
//window.opener.aspnetForm.ctl00$_main$shiptoattention.value = ShipToAttn.replace('\.',' ');
window.opener.document.aspnetForm.ctl00$_main$shiptoattention.value = ShipToAttn.replace('\.',' ');
   	self.close();
   	}
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>B2B On-line commerce - Pick Company</title>
    <meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR"/>
	<meta content="Visual Basic .NET 7.1" name="CODE_LANGUAGE"/>
	<meta content="JavaScript" name="vs_defaultClientScript"/>
	<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema"/>
    <link rel="stylesheet" href="../includes/ebiz.aeu.style.css" />
</head>
<body>
    <form id="form1" runat="server">

    <div>
    <table width="100%" border="0" cellspacing="0" cellpadding="0" ID="Table1">
			<tr>
				<td style="width:100%;height:10px" valign="top" align="center">
					&nbsp;
				</td>
			</tr>
			<tr>
				
				<td style="width:100%" valign="top" align="center">
						
                    <asp:GridView ID="GridView1" runat="server" DataSourceID="SqlDataSource1" 
                        AutoGenerateColumns = "true" onrowdatabound="GridView1_RowDataBound" >
                    </asp:GridView>	
                    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>"></asp:SqlDataSource>
				</td>
                
			
			</tr>
			<tr>
				<td style="width:100%;height:10px" valign="top" align="center">
					&nbsp;
				</td>
			</tr>
			<tr valign="middle">
				<td align="center">
					
					&nbsp;&nbsp;<span class="PageMessageBar">
					*HINT:&nbsp;To query record, please click f-button, input key word, then click f-button again. You could pick the ship-to address by clicking Ship-To Id.
					</span>
					<p></p>
					
				</td>
			</tr>			
		</table>
    </div>
    </form>
</body>
</html>
