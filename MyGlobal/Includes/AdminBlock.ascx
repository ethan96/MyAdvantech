<%@ Control Language="VB" ClassName="AdminBlock" %>
<%@ Register src="~/Includes/ChangeCompany.ascx" tagname="ChangeCompany" tagprefix="uc1" %>

<script runat="server">
    Dim strFirstName As String = ""
    Dim strLastName As String = ""
    Dim strFullName As String = strFirstName & " " & strLastName
    Dim AdminFlag As String = "NO"
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim exeFunc As Integer = 0
        Dim g_arrAttributeValue
        exeFunc = UserProfile_Get(Session("USER_ID"), "Base", "FIRST_NAME", g_arrAttributeValue)
        If g_arrAttributeValue(0) > 0 Then
            Try
                strFirstName = g_arrAttributeValue(1)
            Catch ex As Exception
                Dim dt1 As DataTable = dbUtil.dbGetDataTable("B2B", _
                "select first_name from user_info where userid='" & Session("user_id") & "'")
                strLastName = dt1.Rows(0).Item(0).ToString()
            End Try
            
        End If
        exeFunc = UserProfile_Get(Session("USER_ID"), "Base", "LAST_NAME", g_arrAttributeValue)
        If g_arrAttributeValue(0) > 0 Then
            Try
                strLastName = g_arrAttributeValue(1)
            Catch ex As Exception
                Dim dtt As DataTable = dbUtil.dbGetDataTable("B2B", _
                "select last_name from user_info where userid='" & Session("user_id") & "'")
                strLastName = dtt.Rows(0).Item(0).ToString()
            End Try
            
        End If
        strFullName = strFirstName & " " & strLastName
        If Not Page.IsPostBack Then
            Me.company_id.text = Session("company_id")
        End If
        
        Dim AdminSQLCmd As String = ""
        AdminSQLCmd = "select distinct IsNull(parent_userid1,'') as userid, " & _
                      "IsNull(parent_userid1,'') as full_name " & _
                      "from em_dim_sales where parent_userid1 like '" & Session("user_id") & "' " & _
                      "union " & _
                      "select distinct IsNull(parent_userid2,'') as userid, " & _
                      "IsNull(parent_userid2,'') as full_name " & _
                      "from em_dim_sales where parent_userid2 like '" & Session("user_id") & "' "
        Dim AdminDT As DataTable = dbUtil.dbGetDataTable("my", AdminSQLCmd)
        
        If AdminDT.Rows.Count > 0 Then
            AdminFlag = "YES"
        Else
            AdminFlag = "NO"
        End If
        'If request("company_id")<>"" Then
        '    Me.company_id.text = Trim(request("company_id"))
        'Else
        '    Me.company_id.text = Session("company_id")
        'End If
        If LCase(Session("user_id")) = "tc.chen@advantech.com.tw" Or LCase(Session("user_id")) = "rudy.wang@advantech.com.tw" Or LCase(Session("user_id")).ToString.Contains("nada.liu@advantech") Or LCase(Session("user_id")).ToString.Contains("emil.hsu@advantech") Or LCase(Session("user_id")) = "pri.supriyanto@advantech.de" Or LCase(Session("user_id")) = "ceres.wang@advantech.com.tw" Then
            trMyKPI.Visible = True
        End If
        Dim dt As DataTable = dbUtil.dbGetDataTable("My", "select userid from account_admin")
        If dt.Select("userid = '" + Session("user_id") + "'").Length = 0 Then trAccountAdmin.Visible = False
    End Sub
    
    Protected Sub ChangeCompanyBtn_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim iRet As String = dbUtil.dbExecuteScalar("B2B", String.Format("select count(company_id) from company where company_id = '{0}' and company_type='partner'", Trim(company_id.Text)))
        If Integer.Parse(iRet) > 0 Then
            If Not Util.IsInternalUser2() Then Response.Redirect("/home.aspx")
            'jackie add 04/27/2006 for clear quotation_detail table
            dbUtil.dbExecuteNoQuery("B2B", "delete from quotation_detail where quote_id='" & Session("cart_id") & "'")
        
            Dim strCompanyID As String = Trim(Me.company_id.Text)
            Dim exeFunc As Integer = 0
            Dim g_arrAttributeValue
            exeFunc = Global_Inc.CompanyProfile_Get(Session("COMPANY_ORG_ID"), UCase(strCompanyID), "Base", "PRICE_CLASS", g_arrAttributeValue)
            'Response.Write(g_arrAttributeValue(0))
            'Response.End
            'g_arrAttributeValue(0) = 1
            If g_arrAttributeValue(0) > 0 Then
		         		
                Session("COMPANY_ID") = UCase(strCompanyID)
                Session("COMPANY_PRICE_CLASS") = g_arrAttributeValue(1)
			
            Else
                Response.Redirect("/home.aspx")
            End If

            exeFunc = Global_Inc.CompanyProfile_Get(Session("COMPANY_ORG_ID"), Session("COMPANY_ID"), "Base", "CURRENCY", g_arrAttributeValue)
            If g_arrAttributeValue(0) > 0 Then
                Session("COMPANY_CURRENCY") = g_arrAttributeValue(1)
            End If

            '---- 20030723 emil add ptrade price class for AESC ----'
            exeFunc = Global_Inc.CompanyProfile_Get(Session("COMPANY_ORG_ID"), strCompanyID, "Base", "PTRADE_PRICE_CLASS", g_arrAttributeValue)
            If g_arrAttributeValue(0) > 0 Then
                Session("COMPANY_PTRADE_PRICE_CLASS") = g_arrAttributeValue(1)
            End If

            '---- 20030723 emil add company name for AESC ----'
            exeFunc = Global_Inc.CompanyProfile_Get(Session("COMPANY_ORG_ID"), strCompanyID, "Base", "COMPANY_NAME", g_arrAttributeValue)
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
            Global_Inc.Cart_Initiate(Session("CART_ID"), Session("COMPANY_CURRENCY"))
            exeFunc = Configuration_Destroy(Session("G_CATALOG_ID"))
            'If Request("scrPage") = "" Then
            '    Response.Redirect("/home.aspx")
            'Else
            '    '--{2005-11-1}--Daive: this is only for CTOS to change company
            '    Response.Redirect(Request("scrPage") & "&RBU=" & strCompanyID & "")
            'End If
            'If Not (Session("RequestURL") Is Nothing) Then
            'Response.Redirect(Session("RequestURL"))
            'Session("RequestURL") = Nothing
            'Else
            Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
                
            'End If
        Else
        Util.JSAlert(Page, "Company ID Not Exist")
        End If
    End Sub   
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
        Dim i As Integer = 0
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
        Dim i As Integer = 0
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

    Protected Sub lnkePricer_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "PZ")
        Response.Redirect(String.Format("http://aclepartner.advantech.com.tw/Login1.asp?SWEusername={0}&SWEpassword={1}&SrcString=/pricing/epricer_entry.asp", Session("user_id"), p.login_password))
    End Sub

    Protected Sub lnkWiki_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "PZ")
        Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}&redirectpage", p.email_addr, p.login_password, ""))
    End Sub
    
</script>

<script type="text/javascript">
function PickCompanyID(xElement,xType,xCompanyID){
    var Url;
    //alert("test");
    //alert(document.getElementsByName("company_id").value);
    Url="/Includes/ChangeCompany.aspx?Element=" + xElement + "&Type=" + xType + "&CompanyID=" + document.getElementById('<%=Me.company_id.ClientID  %>').value + "";
    window.open(Url, "pop","height=570,width=480,scrollbars=yes");
}
function updateFromChildWindow(updateValue)
{
 document.getElementById('<%= Me.company_id.ClientID %>').value = updateValue;
}

</script>

<ajaxToolkit:CollapsiblePanelExtender ID="cpe" runat="Server"
    TargetControlID="PanelContent" ExpandControlID="PanelHeader" CollapseControlID="PanelHeader"
    CollapsedSize="0" Collapsed="false" ScrollContents="false" SuppressPostBack="true" ExpandDirection="Vertical" /> 
<asp:Panel runat="server" ID="PanelHeader">
    <table border="0" width="100%" cellspacing="0" cellpadding="0" onmouseover="this.style.cursor='hand'"> 
        <tr> 
          <td width="4" height="20" class="text"><p align="left"><img src="/images/table_fold_left.gif" width="4" height="24"></td> 
          <td width="192" height="20" background="/images/table_fold_top.gif" >
              <table width="100%"  border="0" cellpadding="0" cellspacing="0"class="text">
                <tr>
                  <td width="6%"><img src="/images/clear.gif" width="10" height="10"></td>
                  <td width="94%"><b>Admin</b></td>
                </tr>
              </table>                        
          </td>
          <td width="4" height="20" class="text"><img src="/images/table_top_right.gif" width="4" height="24"></td>
        </tr> 
    </table>
</asp:Panel>
<asp:Panel runat="server" ID="PanelContent">
    <table border="0" width="100%" cellspacing="0" cellpadding="0"> 
        <tr> 
          <td width="4" background="/images/table_line_left.gif"></td> 
          <td width="192"> 
              <table border="0" width="89%" cellspacing="0" cellpadding="0" class="text"> 
                <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td width="141"><asp:HyperLink runat="server" ID="hlAdmin" Text="Admin" NavigateUrl="~/Admin/b2b_admin_portal.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                  </tr> 
                  <%--<tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td width="141"><asp:HyperLink runat="server" ID="KPILink" Text="MyAdvantech KPI" NavigateUrl="~/Admin/MyAdvantechKPI.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                  </tr> --%>
                  <tr runat="server" id="trAccountAdmin"> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:HyperLink runat="server" ID="hlAccountAdmin" Text="Account Admin" NavigateUrl="/Admin/Account_Admin.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                  </tr>
                  <tr runat="server" id="trMyKPI" visible="false"> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:HyperLink runat="server" ID="hlMyKPI" Text="MyAdvantech KPI" NavigateUrl="http://aeu-ebus-dev:7000/DataMining/MyKPI.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                  </tr> 
                  <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:HyperLink runat="server" ID="ECLink" Text="eCampaign" NavigateUrl="http://aeu-ebus-dev:7000/EC/Campaign_Admin.aspx" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                  </tr> 
                  <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:HyperLink runat="server" ID="CustDBLink" Text="Customer Dashboard" NavigateUrl="http://aeu-ebus-dev:7000/Admin/AccountProfile.aspx?ERPID=EFFRFA01" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                  </tr>
                  <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:HyperLink runat="server" ID="ProdDBLink" Text="Product Dashboard" NavigateUrl="http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=ADAM-4520-D2E" ForeColor="#4D6D94" Font-Bold="true" /></td> 
                  </tr>  
                  <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td> <font color="#4D6D94"><b>Change Company</b></font></td> 
                  </tr>
                  <tr> 
                    <td colspan="2">
                        <%--<uc1:ChangeCompany ID="ChangeCompany1" runat="server"/>--%>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" ID="Table2"">
					        <tr>
						        <td height="30px" align="center" width="78%">
						            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" ServicePath="~/Services/AutoComplete.asmx" FirstRowSelected="true" 
                                        ServiceMethod="GetERPId" CompletionInterval="1000" TargetControlID="company_id" MinimumPrefixLength="2" />
                                    &nbsp;<asp:TextBox ID="company_id" runat="server"></asp:TextBox></td>
						        <td><input name="Pick" style="cursor:hand" value="Pick" type="button" onclick="PickCompanyID('leftmenu_company_id','SOLDTO','');" id="Button11"/>&nbsp;<asp:Button ID="ChangeCompanyBtn" runat="server" OnClick="ChangeCompanyBtn_Click" Text="Go"/></td>
					        </tr>
				        </table>
                    </td>
                  </tr> 
                  <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:LinkButton runat="server" ID="lnkePricer" Text="ePricer" OnClick="lnkePricer_Click" ForeColor="#4D6D94" Font-Bold="true"  /></td> 
                  </tr>
                  <tr> 
                    <td align="center" width="21"><img border="0" src="/images/icon_add.gif" width="12" height="12"></td> 
                    <td><asp:LinkButton runat="server" ID="lnkWiki" Text="AdvantechWiki" OnClick="lnkWiki_Click" ForeColor="#4D6D94" Font-Bold="true"  /></td> 
                  </tr>
              </table>
          </td> 
          <td width="4" background="/images/table_line_right.gif"></td> 
        </tr> 
        <tr> 
          <td colspan="3"><img src="/images/folder_down.gif" width="100%" height="5"></td> 
        </tr> 
    </table>
</asp:Panel>