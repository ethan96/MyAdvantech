<%@ Page Language="VB" Title="MyAdvantech - Pick Company" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    Dim xCompanyID As String = ""
    Dim Type As String = ""
    Dim ElementName As String = ""
    Dim CustIDCondition As String = ""
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'If Request.QueryString("CompanyID") <> "" Then
            xCompanyID = Request.QueryString("CompanyID")
            txtCompanyID.Text = xCompanyID
            '    Session("CompanyID") = xCompanyID
            'Else
            '    xCompanyID = Session("CompanyID")
            'End If
            'If Request.QueryString("Type") <> "" Then
            Type = Request.QueryString("Type")
            ViewState("Type") = Type
            '    Session("Type") = Type
            'Else
            '    Type = Session("Type")
            'End If
            'If Request.QueryString("Element") <> "" Then
            ElementName = Request.QueryString("Element")
            '    Session("ElementName") = ElementName
            'Else
            '    ElementName = Session("ElementName")
            'End If

            'If Request.QueryString("CustID") <> "" Then
            '    CustIDCondition = " and (companyid like '%" & Request.QueryString("CustID") & "%' or companyname like '%" & Request.QueryString("CustID") & "%') "
            'Else
            '    CustIDCondition = " "
            'End If
            'Session("COMPANY_ID") = "UUAAESC"
        End If
        Call initialSearch()
    End Sub
    Function getERPID_From_Siebel_byName(ByVal KeyStr As String) As DataTable
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("RFM", String.Format("Select distinct top 10 (ERP_ID) FROM SIEBEL_ACCOUNT where len(erp_id)>3 and Account_Name like N'%{0}%'", KeyStr))
        Return dt
    End Function
    
    Function ConcatenateField2Str(ByVal dt As DataTable) As String
        Dim STR As String = "''"
        If dt.Rows.Count > 0 Then
            STR = ""
            For Each R As DataRow In dt.Rows
                STR &= "'" & R.Item(0).ToString & "'"
                STR &= ","
            Next
            Return STR.Trim(",")
        End If
        Return STR
    End Function
    Protected Sub initialSearch()
        Dim companylist As String = ""
        
        companylist = ConcatenateField2Str(getERPID_From_Siebel_byName(xCompanyID))
        
        Dim strSqlCmd As String
        If UCase(ViewState("Type")) = "SHIPTO" Then
            strSqlCmd = "select top 100 company_id,company_name,org_id,address,attention from sap_dimcompany where ( company_id like '%" & xCompanyID & "%' or company_name like N'%" & xCompanyID & "%' or company_id in (" & companylist & ")) AND company_Type in ('Ship_To','Z002') AND company_name not like '*INVALID*%'"
        ElseIf UCase(ViewState("Type")) = "SOLDTO" Then
            strSqlCmd = "select top 100 company_id,company_name,org_id,address,attention from sap_dimcompany where ( company_id like '%" & xCompanyID & "%' or company_name like N'%" & xCompanyID & "%' or company_id in (" & companylist & ")) AND company_Type in ('Partner','Z001') AND company_name not like '*INVALID*%' "
        Else
            strSqlCmd = "select top 100 company_id,company_name,org_id,address,attention from sap_dimcompany where ( company_id like '%" & xCompanyID & "%' or company_name like N'%" & xCompanyID & "%' or company_id in (" & companylist & ")) AND company_name not like '*INVALID*%' "
        End If
     
        'Response.Write(strSqlCmd)
        ViewState("SqlCommand") = ""
        SqlDataSource1.SelectCommand = strSqlCmd
        ViewState("SqlCommand") = SqlDataSource1.SelectCommand
        If Not Page.IsPostBack Then
            sgv1.DataBind()
        End If
    End Sub
    
    Protected Sub Search_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Dim strSqlCmd As String
        'strSqlCmd = "select company_id,company_name,org_id,address,attention from company where " & Me.ddlSearchType.selectedValue & " like '%" & Me.txtKeyWord.text.Trim() & "%'"
        'Me.DropShip.xSQL = strSqlCmd
        'Me.DropShip.CurrentPageIndex=0
        'Me.DropShip.VxDataGridBinding()
    End Sub

    Protected Sub sgv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        Dim xCompanyID As String = ""
        Dim xOrg_ID As String = ""
        Dim xCompanyAttn As String = ""
        Dim xAccountName As String = ""
        If e.Row.RowType = DataControlRowType.DataRow Then
            
            xCompanyID = e.Row.Cells(1).Text
            xCompanyAttn = e.Row.Cells(5).Text
            xOrg_ID = e.Row.Cells(6).Text
            Dim StrLink As String = ""
            StrLink = " 'javascript:vorg_id(0);' onClick=" & Chr(34) & "copopulate(" & "'" & ElementName & "','" & xCompanyID & "','" & xOrg_ID & "'" & "," & "'" & xCompanyAttn & "'" & ")" & Chr(34) & "," & _
                      Chr(34) & xCompanyAttn & Chr(34) & ")'"
            e.Row.Cells(1).Text = "<a href='#' & " & StrLink & " >" & UCase(xCompanyID) & "</a>"
            Dim dt As New DataTable
            dt = dbUtil.dbGetDataTable("eCampaign", String.Format("select distinct Account_Name from Siebel_Account where ERP_ID='{0}'", xCompanyID))
            If dt.Rows.Count > 0 Then
                Dim n = 1
                For Each r As DataRow In dt.Rows
                    xAccountName &= n & ". " & r.Item(0) & "<br/>"
                    n = n + 1
                Next
            End If
            e.Row.Cells(4).Text = xAccountName
        End If
    End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        xCompanyID = Trim(txtCompanyID.Text)
        Call initialSearch()
    End Sub
</script>

<script type="text/javascript" language="javascript">

window.document.onkeydown = CheckEnter;

function CheckEnter()
{

     if(event.keyCode == 13)

          return false;

     return true;

}



function copopulate(xElement,company,org_id,ShipToAttn)
   	{
   	//xElement="company_id*org_id"
   	var retValue;
   	retValue = xElement.split("*");
   	var i;
   	i = 0;
   	//alert(retValue.length + "||" + retValue[0] + "||" + retValue[1]);
   	for (i = 0; i < retValue.length; i++){
   	  //alert("retValue" + i + ":" + retValue[i].toUpperCase());
   	  switch (retValue[i].toUpperCase()){
   	     case "COMPANY_ID":
   	     {
   	       //alert("company_id:" + company_id);
   	       window.opener.form1.elements("ctl00__main_ucAdmin_company_id").value = company;
   	       continue;
   	     }
   	     case "ORG_ID":
   	     {
   	       window.opener.form1.elements("org_id").value = org_id;
   	       //alert("org_id:" + org_id);
   	       continue;
   	     }
   	     case "ATTENTION":
   	     {
   	       window.opener.form1.elements("attention").value = ShipToAttn;
   	       //alert("attention:" + ShipToAttn);
   	       continue;
   	     }
   	     default:
   	     {
   	       try{
   	           
   	          //window.opener.form1.elements("ctl00__main_ucAdmin_company_id").value = company;
   	          window.opener.updateFromChildWindow(company);
   	       }
   	       catch (e){
   	       
   	       }
   	       finally {
   	       
   	       }
   	       continue;
   	     }
   	  }
   	}
   	//window.opener.form1.elements(xElement).value = company;
   	//alert("self.close()");
   	
   	self.close()
   	}
</script>
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>B2B On-line commerce - Pick Company</title>
    <meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR"/>
	<meta content="Visual Basic .NET 7.1" name="CODE_LANGUAGE"/>
	<meta content="JavaScript" name="vs_defaultClientScript"/>
	<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema"/>
	<link runat="server" id="ebizCss" visible="true" href="../Includes/ebiz.aeu.style.css" rel="stylesheet" type="text/css" />
    <link href="../Includes/global.css" rel="Stylesheet" type="text/css" />   
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
			<tr><td height="5">&nbsp;</td></tr>
			<tr>
			    <td>
			        <table border="0" cellpadding="0" cellspacing="0" width="100%">
			            <tr>
			                <td width="5">&nbsp;</td>
			                <td>Company ID or Company Name: <asp:TextBox runat="server" ID="txtCompanyID" /></td>
			                <td width="5">&nbsp;</td>
			                <td><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>
			            </tr>
			        </table>
			    </td>
			</tr>
			<tr>
			    <td height="10">&nbsp;</td>
			</tr>
			<tr>
				<!-- ******* center column (start) ********-->
				<td style="width:100%" valign="top" align="center">
					<!--include file="PickDropShip_main.asp"-->
					<sgv:SmartGridView runat="server" ID="sgv1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="50"
                         Width="97%" DataSourceID="SqlDataSource1" OnRowDataBoundDataRow="sgv1_RowDataBoundDataRow">
                        <Columns>
                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                <headertemplate>
                                    No.
                                </headertemplate>
                                <itemtemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </itemtemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Company ID" DataField="company_id" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Company Name" DataField="company_name" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Address" DataField="address" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Account Name" DataField="address" ItemStyle-HorizontalAlign="Left" />
                            <asp:BoundField HeaderText="Attention" DataField="attention" Visible="false" />
                            <asp:BoundField HeaderText="Sales Org." DataField="Org_id" Visible="false" />
                        </Columns>
                        <FixRowColumn FixRowType="Header" FixColumns="-1" FixRows="-1" />
                        <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                        <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify"  />
                        <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                    </sgv:SmartGridView>
                    <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:RFM %>"
                         SelectCommand="" OnLoad="SqlDataSource1_Load">
                    </asp:SqlDataSource>			
				</td>
				<!-- ******* center column (end) ********-->
			</tr>
			<tr>
				<td style="width:100%;height:10px" valign="top" align="center">
					&nbsp;
				</td>
			</tr>
			<tr valign="middle">
				<td align="center">
					<!-- ******* page title (start) ********-->
					&nbsp;&nbsp;<span class="PageMessageBar">*HINT: Click 'Query' to input query string then 'Go'. Click 'Ship Id' to apply.</span>
					<p></p>
					<!-- ******* page title (end) ********-->
				</td>
			</tr>			
		</table>
    </div>
    </form>
</body>
</html>
