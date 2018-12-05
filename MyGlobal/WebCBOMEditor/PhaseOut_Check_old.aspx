<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master" Title="CBOM---Phase-Out Checking" %>

<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Write("on Developing...") : Response.End()
        Dim strSQLQry As String = ""
        strSQLQry &= "select distinct top 20 category_name " & _
                     "from CBOM_CATALOG_CATEGORY " & _
                     "where (category_type='Category' or Category_name like '%BTO') " & _
                     "and category_name like '" & Me.txtPartNO.Text.Trim & "%'" & _
                     "order by category_name"
        Dim CBOMDT As DataTable = dbUtil.dbGetDataTable("b2b", strSQLQry)
       
        Me.Element_List.DataSource = CBOMDT.DefaultView
        Me.Element_List.DataTextField = "category_name"
        Me.Element_List.DataValueField = "category_name"
        If Not Page.IsPostBack Then
            Me.Element_List.DataBind()
        End If
        'Dim dRow As DataRow
        'Dim lstItem As System.Web.UI.WebControls.ListItem
        'For Each dRow In CBOMDT.Rows
        '    lstItem = New System.Web.UI.WebControls.ListItem
        '    lstItem.Text = dRow.Item(0)
        '    lstItem.Value = dRow.Item(0)
        '    Me.Element_List.Items.Add(lstItem)
        'Next
        InitialDg()
        'If Not Page.IsPostBack Then
        '    Me.lstCBOM.DataBind()
        'End If
        
    End Sub
    
    Protected Sub InitialDg()
        Dim StrCategory As String = ""
        'Response.Write(Request("ctl00$_main$lstParticipants"))
        If Request("ctl00$_main$lstParticipants") <> "" Then
            
            Me.ViewState("lstElement") = Request("ctl00$_main$lstParticipants")
            Dim ArrEle() As String
            ArrEle = Me.ViewState("lstElement").Split(",")
            Dim i As Integer = 0
            Me.lstParticipants.Items.Clear()
            Dim lstItem As System.Web.UI.WebControls.ListItem
            For i = 0 To ArrEle.Length - 1
                'Response.Write(Request("ctl00$_main$lstParticipants")(i))
                lstItem = New System.Web.UI.WebControls.ListItem
                lstItem.Text = ArrEle(i)
                lstItem.Value = ArrEle(i)
                Me.lstParticipants.Items.Add(lstItem)
                If i = 0 Then
                    StrCategory = StrCategory & "'" & ArrEle(i) & "'"
                Else
                    StrCategory = StrCategory & ",'" & ArrEle(i) & "'"
                End If
            Next
        End If
        If StrCategory = "" Then
            StrCategory = "''"
        End If
        Dim T_strSelect As String = ""
        Dim T_strSelect1 As String = ""
        Dim T_strSelect2 As String = ""
        T_strSelect1 = " Select C.CATEGORY_NAME,P.Status,C.CATEGORY_DESC,C.Parent_Category_ID as PARENT_CATEGORY_ID" & _
                      " from CBOM_CATALOG_CATEGORY as C, Product as P " & _
                      " where Category_Type='Component'  " & _
                      " and C.Parent_Category_Id in  (" & StrCategory & ") " & _
                      " and P.Part_No = C.Category_id and P.Status not in ('A','H','N') "
        T_strSelect2 = " Select C.CATEGORY_NAME,'O' as STATUS,C.CATEGORY_DESC,C.Parent_Category_ID as PARENT_CATEGORY_ID" & _
                      " from CBOM_CATALOG_CATEGORY as C " & _
                      " where Category_Type='Component'  " & _
                      " and C.Parent_Category_Id in  (" & StrCategory & ") " & _
                      " and C.Category_id not in (select distinct p.part_no from product p where p.status in ('A','H','N')) "
        T_strSelect = T_strSelect1 & " UNION " & T_strSelect2 & " order by C.CATEGORY_NAME"
        'Response.Write(T_strSelect)
        'Me.AdxDg_ElementList.xSQL = T_strSelect
        'If Not Page.IsPostBack Or Me.lblPostFlag.Text = "YES" Then
        '    Me.lblPostFlag.Text = "NO"
        '    Me.AdxDg_ElementList.CurrentPageIndex = 0
        '    Me.AdxDg_ElementList.VxDataGridBinding()
        'Response.Write(T_strSelect)
        SqlDataSource1.SelectCommand = T_strSelect
        Me.GridView1.DataBind()
        'If Not Page.IsPostBack Or Me.lblPostFlag.Text = "YES" Then
        '    Me.lblPostFlag.Text = "NO"
        '    Me.GridView1.DataBind()
        'End If
    End Sub

    Protected Sub btnSubmit_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.lblPostFlag.Text = "YES"
        InitialDg()
    End Sub
   
    Protected Sub GridView1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script type="text/javascript" language="javascript">
function Change_List( strKey ) {
		var i = 0 ;
		var Obj = document.getElementById("ctl00__main_Element_List");
		
		var len = strKey.length ;
		for( i=0 ; i<Obj.length ; i++ ) {
			if ( Obj.options[i].value.substring(0 ,len).toUpperCase() == strKey.toUpperCase() ) {
				Obj.selectedIndex = i ;
				break ;
			}
		}
	}

function BtnMovOut_onclick(frm_mail) {
	for (var i = frm_mail.ctl00__main_Element_List.length - 1 ; i >= 0 ; i--){
	var idx ;
	if (frm_mail.ctl00__main_Element_List.options[i].selected == true)
	{
	idx = frm_mail.ctl00__main_lstParticipants.length
	frm_mail.ctl00__main_lstParticipants.options[idx] = new Option(frm_mail.ctl00__main_Element_List[i].text, frm_mail.ctl00__main_Element_List[i].value);
	frm_mail.ctl00__main_Element_List.options[i] = null ;

	}
	}
	}
	
function BtnMovIn_onclick(frm_mail) {
	for (var i = frm_mail.ctl00__main_lstParticipants.length - 1 ; i >= 0 ; i--){
	var idx ;
	if (frm_mail.ctl00__main_lstParticipants.options[i].selected == true)
	{
		if (frm_mail.ctl00__main_lstParticipants.options[i].value != "")
		{
	idx = frm_mail.ctl00__main_Element_List.length;
	frm_mail.ctl00__main_Element_List.options[idx] = new Option(frm_mail.ctl00__main_lstParticipants[i].text, frm_mail.ctl00__main_lstParticipants[i].value);
	frm_mail.ctl00__main_lstParticipants.options[i] = null ;

		}
	}
	}
	}
	
function DataSheet(frm_mail)
{
	for (var i = frm_mail.ctl00__main_lstParticipants.length - 1 ; i >= 0 ; i--){
		frm_mail.ctl00__main_lstParticipants.options[i].selected = true ;
	}
}	
</script>
<table width="100%">
        <tr>
            <td style="vertical-align:top;"></td>
        </tr>
        <tr>
            <td style="vertical-align:top;" width="98%">
                <table width="100%">
                    <tr>
                        <td style="height:6px;"><a href="../home_old.aspx">Home</a>>>><a href="../Admin/B2B_Admin_portal.aspx">Admin</a>>>>PhaseOut</td>
                    </tr>
                    <tr>
                        <td><h2>Phase-Out Checking</h2></td>
                    </tr>
                    <tr>
                        <td style="height:6px;">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                            <fieldset style="width:900px">
                            <legend style="background-color:White;">CBOM Select</legend>
                                <table width="100%">                                        
                                    <tr>
                                        <td colspan="3">
                                            <asp:TextBox runat="server" ID="txtPartNO" Width="180px" onkeyup="Change_List( this.value )"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <hr />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width:350px">
                                            <asp:ListBox ID="Element_List" runat="server" Rows="10" Width="350px" multiple="true" ondblclick="BtnMovOut_onclick(this.form);"></asp:ListBox>
                                        </td>
                                        <td style="width:150px" valign="middle" align="center">
                                            <input type="button" id="btnMoveOut" name="btnMoveOut" value="Join >>" onclick="BtnMovOut_onclick(this.form);"/><br /><br />
                                            <input type="button" id="btnMoveIn" name="btnMoveIn" value="<< Remove" onclick="BtnMovIn_onclick(this.form);"/><br /><br />
                                            <asp:Button runat="server" ID="btnSubmit" Text="Check" OnClick="btnSubmit_Click"/>
                                            <asp:Label runat="server" ID="lblPostFlag" Text="NO" Visible="false"></asp:Label>
                                        </td>
                                        <td style="width:350px">
                                            <asp:ListBox ID="lstParticipants" runat="server" Rows="10" Width="350px" multiple="true" ondblclick="BtnMovIn_onclick(this.form);"></asp:ListBox></td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                    </tr>
                    <tr>
                        <td style="height:6px;">&nbsp;</td>
                    </tr>
                    <tr>
                        <td>
                           			<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align:middle" ID="Table3">
                    <tr>
                        <td style="padding-left:10px;border-bottom:#ffffff 1px solid;height:20px;background-color:#6699CC" align="left" valign="middle" class="text">
                        <font color="#ffffff"><b>BtosHistory List</b></font></td></tr>
                        <tr><td>
                                            <asp:GridView runat="server" ID="GridView1" 
                                                            DataSourceID ="SqlDataSource1" 
                                                onrowdatabound="GridView1_RowDataBound" AllowPaging="True" PageIndex="0" PageSize="30" Width="100%">
                                                
                                            </asp:GridView>		
								
								
								
														
                                            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>">
                                           
                                            </asp:SqlDataSource>
								 </td></tr><tr><td id="tdTotal" align="right" style="background-color:#ffffff" runat="server"></td></tr></table>
                        </td>
                    </tr>
                    <tr>
                        <td style="height:6px;">&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="vertical-align:bottom;"></td>
        </tr>
    </table>
</asp:Content>

