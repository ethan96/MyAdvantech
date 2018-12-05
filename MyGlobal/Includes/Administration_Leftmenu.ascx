<%@ Control Language="vb" Debug="true" ClassName="Administration_Leftmenu"%>
<script runat="server">
    Dim strFirstName As String = ""
    Dim strLastName As String = ""
    Dim strFullName As String = strFirstName & " " & strLastName
    dim AdminFlag as string = "NO"
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim exeFunc As Integer = 0
        Dim g_arrAttributeValue
        exeFunc = UserProfile_Get(Session("USER_ID"), "Base", "FIRST_NAME", g_arrAttributeValue)
        If g_arrAttributeValue(0) > 0 Then
            Try
                strFirstName = g_arrAttributeValue(1)
            Catch ex As Exception
                Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
                "select first_name from user_info where userid='" & Session("user_id") & "'")
                strLastName = dt.Rows(0).Item(0).ToString()
            End Try
            
        End If
        exeFunc = UserProfile_Get(Session("USER_ID"), "Base", "LAST_NAME", g_arrAttributeValue)
        If g_arrAttributeValue(0) > 0 Then
            Try
                strLastName = g_arrAttributeValue(1)
            Catch ex As Exception
                Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
                "select last_name from user_info where userid='" & Session("user_id") & "'")
                strLastName = dt.Rows(0).Item(0).ToString()
            End Try
            
        End If
        strFullName = strFirstName & " " & strLastName
        If Not Page.IsPostBack Then
            Me.company_id.text = Session("company_id")
        End If
        
        dim AdminSQLCmd as string = ""
        AdminSQLCmd = "select distinct IsNull(parent_userid1,'') as userid, " & _
                      "IsNull(parent_userid1,'') as full_name " & _
                      "from ESALES.dbo.em_dim_sales where parent_userid1 like '" & Session("user_id") & "' " & _
                      "union " & _
                      "select distinct IsNull(parent_userid2,'') as userid, " & _
                      "IsNull(parent_userid2,'') as full_name " & _
                      "from ESALES.dbo.em_dim_sales where parent_userid2 like '" & Session("user_id") & "' "
        Dim AdminDT As DataTable = dbUtil.dbGetDataTable("B2B", AdminSQLCmd)
        
        if AdminDT.Rows.Count > 0 then
           AdminFlag = "YES"
        else
           AdminFlag = "NO"
        end if
        'If request("company_id")<>"" Then
        '    Me.company_id.text = Trim(request("company_id"))
        'Else
        '    Me.company_id.text = Session("company_id")
        'End If
    End Sub
    
    Protected Sub ChangeCompanyBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Redirect("/Order/Cart_List.aspx")
        If Not IsInternalUser(Session("user_id")) Then Response.Redirect("home.aspx")
        'jackie add 04/27/2006 for clear quotation_detail table
        dbUtil.dbExecuteNoQuery("B2B", "delete from quotation_detail where quote_id='" & Session("cart_id") & "'")
        
        Dim strCompanyID As String = Trim(Me.company_id.text)
        Dim exeFunc As Integer = 0
        Dim g_arrAttributeValue
        exeFunc = CompanyProfile_Get(Session("COMPANY_ORG_ID"), UCase(strCompanyID), "Base", "PRICE_CLASS", g_arrAttributeValue)
        'Response.Write(g_arrAttributeValue(0))
        'Response.End
        'g_arrAttributeValue(0) = 1
        If g_arrAttributeValue(0) > 0 And Len(strCompanyID) <= 8 Then
		         		
            Session("COMPANY_ID") = UCase(strCompanyID)
            Session("COMPANY_PRICE_CLASS") = g_arrAttributeValue(1)
			
        Else
            Response.Redirect("home.aspx")
        End If

        exeFunc = CompanyProfile_Get(Session("COMPANY_ORG_ID"), Session("COMPANY_ID"), "Base", "CURRENCY", g_arrAttributeValue)
        If g_arrAttributeValue(0) > 0 Then
            Session("COMPANY_CURRENCY") = g_arrAttributeValue(1)
        End If

        '---- 20030723 emil add ptrade price class for AESC ----'
        exeFunc = CompanyProfile_Get(Session("COMPANY_ORG_ID"), strCompanyID, "Base", "PTRADE_PRICE_CLASS", g_arrAttributeValue)
        If g_arrAttributeValue(0) > 0 Then
            Session("COMPANY_PTRADE_PRICE_CLASS") = g_arrAttributeValue(1)
        End If

        '---- 20030723 emil add company name for AESC ----'
        exeFunc = CompanyProfile_Get(Session("COMPANY_ORG_ID"), strCompanyID, "Base", "COMPANY_NAME", g_arrAttributeValue)
        If g_arrAttributeValue(0) > 0 Then
            Session("COMPANY_NAME") = g_arrAttributeValue(1)
        End If
        'Response.End

        Select Case UCase(Session("COMPANY_CURRENCY"))
            Case "NT"
                Session("COMPANY_CURRENCY_SIGN") = "NT"
            Case "US", "USD"
                Session("COMPANY_CURRENCY_SIGN") = "US$"
            Case "EUR"
                Session("COMPANY_CURRENCY_SIGN") = "&euro;"
            Case "YEN"
                Session("COMPANY_CURRENCY_SIGN") = "&yen;"
            Case "GBP"
                Session("COMPANY_CURRENCY_SIGN") = "&pound;"
            Case Else
                Session("COMPANY_CURRENCY_SIGN") = "&euro;"
        End Select

        '---- Id Generation
        'exeFunc  = SiteDef_Get()
        Dim strUniqueId As String = ""
        '---- { 25-01-05 } TO "J"
        exeFunc = Global_Inc.UniqueID_Get("EU", "L", 12, strUniqueId)
        Session("CART_ID") = strUniqueId
        Session("LOGISTICS_ID") = strUniqueId
        Session("ORDER_ID") = strUniqueId

        '----- BTOS Configuration ID ---'
        '---- { 25-01-05 } TO "J"
        Dim G_CATALOG_ID As String = ""
        exeFunc = Global_Inc.UniqueID_Get("CF", "L", 12, G_CATALOG_ID)
        Session("G_CATALOG_ID") = G_CATALOG_ID

        Dim l_strSQLCmd = "insert access_history (unique_id,session_id,login_date_time,userid,login_ip) " & _
                            "values(" & _
                            "'" & strUniqueId & "'," & _
                            "'" & CStr(Session.SessionID) & "'," & _
                            "Getdate()," & _
                            "'" & Session("USER_ID") & "'," & _
                            "'" & Request.ServerVariables("REMOTE_HOST") & "')"
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        'sqlConn.Close()

        '-------------------------
        '    Modules Initiation
        '-------------------------

        '---- Initiate Cart ----'
        Cart_Initiate(Session("CART_ID"), Session("COMPANY_CURRENCY"))
        exeFunc = Configuration_Destroy(Session("G_CATALOG_ID"))
        If Request("scrPage") = "" Then
            Response.Redirect("../home/home.aspx")
        Else
            '--{2005-11-1}--Daive: this is only for CTOS to change company
            Response.Redirect(Request("scrPage") & "&RBU=" & strCompanyID & "")
        End If
    End Sub
    
    Function IsInternalUser(ByVal User_Id As String) As Boolean
        Return Util.IsInternalUser2()
        'Dim uArray, MailDomain, role
        'uArray = Split(User_Id, "@")

        'Try
        '    MailDomain = LCase(Trim(uArray(1)))
        'Catch ex As Exception
        '    IsInternalUser = False
        '    Exit Function
        'End Try
        
        'role = LCase(Session("user_role"))

        'Select Case LCase(MailDomain)
        '    Case "advantech.de", "advantech-uk.com", "advantech.fr", "advantech.it", "advantech.nl", "advantech-nl.nl", "advantech.com.tw", "advantech.com.cn", "advantech.com", "advantech.eu"
        '        IsInternalUser = True
        '    Case Else
        '        IsInternalUser = False
        'End Select
    End Function
    
    Function CompanyProfile_Get(ByVal strOrg_Id, ByVal strCompany_Id, ByVal strAttribute_Type, ByVal strAttribute_Name, ByRef arrAttribute_Value)

        ReDim arrAttribute_Value(10)
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim l_adoRs As DataTable
        Dim l_strSQLCmd As String
        Dim l_intCount As Integer

        Select Case strAttribute_Type
            Case "Base"

                l_strSQLCmd = "select " & strAttribute_Name & " as attri_value from company  " & _
                     " where company_id = '" & strCompany_Id & "' and company_type ='Partner'"
            Case Else

                l_strSQLCmd = "select a.attri_value from company_profile a " & _
                   " inner join profile_attribute_value b" & _
                   " on a.attri_id = b.attri_id and a.attri_value_id = b.attri_value_id " & _
                   " inner join profile_attribute c" & _
                   " on a.attri_id = c.attri_id " & _
                   " where c.profile_type = 'Company' " & _
                   " and c.attri_name = '" & strAttribute_Name & "' " & _
                   " and a.company_id = '" & strCompany_Id & "'"
        End Select

        l_adoRs = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        l_intCount = 0
        Dim i as Integer = 0
        Do While i <= l_adoRs.Rows.Count - 1
            l_intCount = l_intCount + 1
            arrAttribute_Value(l_intCount) = l_adoRs.Rows(i).Item("attri_value")
            i = i + 1
        Loop
        arrAttribute_Value(0) = l_intCount
        CompanyProfile_Get = 1
        'l_adoRs = Nothing
        'g_adoConn.Close()
        'g_adoConn.Dispose() 

    End Function
    
    Function UserProfile_Get(ByVal strUser_Id, ByVal strAttribute_Type, ByVal strAttribute_Name, ByRef arrAttribute_Value)
        ReDim arrAttribute_Value(10)
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim l_adoRs As DataTable
        Dim l_strSQLCmd As String
        Dim l_intCount As Integer

        Select Case strAttribute_Type
            Case "Base"
                l_strSQLCmd = "select " & strAttribute_Name & " as attri_value from user_info " & _
                   " where userid = '" & strUser_Id & "' "
            Case Else
                l_strSQLCmd = "select b.attri_value from user_profile a " & _
                   " inner join profile_attribute_value b" & _
                   " on a.attri_id = b.attri_id and a.attri_value_id = b.attri_value_id " & _
                   " inner join profile_attribute c" & _
                   " on a.attri_id = c.attri_id " & _
                   " where c.profile_type = 'User' " & _
                   " and c.attri_name = '" & strAttribute_Name & "' " & _
                   " and a.userid = '" & strUser_Id & "'"
        End Select
        
        l_adoRs = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        l_intCount = 0
        Dim i as Integer = 0
        Do While i <= l_adoRs.Rows.Count - 1
            l_intCount = l_intCount + 1
            arrAttribute_Value(l_intCount) = l_adoRs.Rows(i).Item("attri_value")
            i = i + 1
        Loop
        arrAttribute_Value(0) = l_intCount
        UserProfile_Get = 1
        'l_adoRs = Nothing
        'g_adoConn.Close()
        'g_adoConn.Dispose()

    End Function
    
    Function Cart_Initiate(ByVal strCart_Id, ByVal strCurrency)

        Dim l_adoRs
        Dim l_strSQLCmd
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        l_strSQLCmd = "delete from cart_master where cart_id = '" & strCart_Id & "'"
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        l_strSQLCmd = "delete from cart_detail where cart_id = '" & strCart_Id & "'"
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        l_strSQLCmd = "insert cart_master (cart_id,currency,checkout_flag) " & _
            "values('" & strCart_Id & "'," & _
            "'" & strCurrency & "'," & _
            "'N')"
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        'sqlConn.Close()
        Cart_Initiate = 1
        l_adoRs = Nothing

    End Function
    
    Function Configuration_Destroy(ByVal G_CATALOG_ID As String) As Integer
        REM == Get Category Info ==
        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = " Delete FROM CONFIGURATION_CATALOG_CATEGORY WHERE (CATALOG_ID = '" & G_CATALOG_ID & "')"
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        'sqlConn.Close()
        Configuration_Destroy = 1
    End Function
    
</script>
<script type="text/javascript">
	function ChangeCompany() {
		window.event.returnValue = false ;
		document.change_company.submit();
	}	

	function ChangeUser() {
		window.event.returnValue = false ;
		document.change_user.submit();
	}
	
	function showChangeCompany(o)
	{
		if (o.style.display == "block")
			o.style.display = "none";
		else
			o.style.display = "block";
	}
	function MapCompany(Url, form)
{
    Url = Url + "&CustID=" + form.company_id.value;
    window.open(Url, "pop","height=370,width=280,scrollbars=yes");
}

function PickCompanyID(xElement,xType,xCompanyID){
    var Url;
    //alert("test");
    //alert(document.getElementsByName("company_id").value);
    Url="../Order/PickCompanyID.aspx?Element=" + xElement + "&Type=" + xType + "&CompanyID=" + document.getElementById("leftmenu_company_id").value + "";
    window.open(Url, "pop","height=570,width=480,scrollbars=yes");
}
</script>

<table width="100%" border="0" cellpadding="0" cellspacing="0" ID="Table1" style="border:#CCCCCC 1px solid">
    <tr>
		<td valign="top" bgcolor="DEE4EC">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" ID="Table3">
				<tr>
					<td colspan="2" height=5></td>
					</tr>
				<tr>
					<td width="10" rowspan="3"><img src="../images/ebiz.aeu.face/clear.gif" width="10" height="10"></td>
					<td width="177" class="text_mini">Welcome</td>
				</tr>
				<tr>
					<td class="text"><b><font color="F6632A"><%=strFirstName & " " & strLastName%></font></b></td>
				</tr>
				<tr>
					<td class="text"><b><font color="003881"><%=Ucase(SESSION("COMPANY_NAME")) %></font></b></td>
				</tr>
				<tr>
					<td colspan="2" height=5></td>
				</tr>
			</table>
		</td>
    </tr>
    <tr>
		<td valign="top" bgcolor="EEEFF1">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="text" ID="Table4">
				<tr valign="middle">
					<td width="10" rowspan="9"><img src="../images/ebiz.aeu.face/clear.gif" width="8" height="10"></td>
					<td colspan="2" height=8></td>
				</tr>
				<tr valign="middle">
					<td width="15" height="17"><div align="left"><img src="../images/ebiz.aeu.face/table_arrow.gif" width="8" height="5"></div></td>
					<td width="165"><a href="../Admin/User_Profile_Update.aspx"><font color="403F3F">Update My Profile</font></a></td>
				</tr>
				<tr valign="middle">
					<td height="17"><div align="left"><img src="../images/ebiz.aeu.face/table_arrow.gif" width="8" height="5"></div></td>
					<td><a href="../Admin/user_company.aspx"><font color="403F3F">My Company's Users</font></a></td>
				</tr>
				<%If Util.IsAEUIT() Or Util.IsInternalUser2() Or AdminFlag = "YES" Then%>
				<tr valign="middle">
					<td height="17"><div align="left"><img src="../images/ebiz.aeu.face/table_arrow.gif" width="8" height="5"></div></td>
					<td><a href="../admin/b2badmin.aspx"><font color="403F3F">B2B Administration</font></a></td>
				</tr>
				<%End If%>
				<%If UCase(Session("USER_ID")) = "NADA.LIU@ADVANTECH.COM.CN" Or UCase(Session("USER_ID")) = "JACKIE.WU@ADVANTECH.COM.CN" Then%>
				<tr valign="middle">
					<td height="17"><div align="left"><img src="../images/ebiz.aeu.face/table_arrow.gif" width="8" height="5"></div></td>
					<td><a href="../Order/pi_present.aspx"><font color="403F3F">PI Resend</font></a></td>
				</tr>
				<tr valign="middle">
					<td height="17"><div align="left"><img src="../images/ebiz.aeu.face/table_arrow.gif" width="8" height="5"></div></td>
					<td><a href="../lab/promotion_register.aspx"><font color="403F3F">ePromotion Admin</font></a></td>
				</tr>
				<%end if %>
				<tr valign="middle">
					<%If Global_Inc.IsInternalUser(Session("user_id")) And Session("company_id").ToString.ToUpper <> "B2BGUEST" Then%>
						<td height="17"><div align="left"><img src="../images/ebiz.aeu.face/table_arrow.gif" width="8" height="5"></div></td>
						<td><a href="javascript:showChangeCompany(divSetCompany);"><font color="403F3F">Change Company</font></a></td>
					<%Else%>
					<%End If%>
				</tr>
				<tr>
					<td colspan="3" height=8></td>
				</tr>
			</table>
		</td>
    </tr>
	<tr>	
		<td align=center valign=middle>
			<div id="divSetCompany" style="display:none">
				<table width="100%" border="0" bgcolor="DEE4EC" cellpadding="0" cellspacing="0" ID="Table2" style="border-top:#CCCCCC 1px solid">
					<tr>
						<td height="30px" align="center" width="78%">
                            &nbsp;<asp:TextBox ID="company_id" runat="server"></asp:TextBox></td>
						<td><input name="Pick" style="cursor:hand" value="Pick" type="button" onclick="PickCompanyID('leftmenu_company_id','SOLDTO','');" id="Button11"/>&nbsp;<asp:Button ID="ChangeCompanyBtn" runat="server" OnClick="ChangeCompanyBtn_Click" Text="Go"/></td>
					</tr>
				</table>
			</div>	
		</td>
	</tr>
</table>