<%@ Control Language="VB" ClassName="ChangeCompany1" %>

<script runat="server">
    Protected Sub btnChangeCompany_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim iRet As String = dbUtil.dbExecuteScalar("B2B", String.Format("select count(company_id) from company where company_id = '{0}' and company_type='partner'", Trim(txtCh2Company.Text)))
        If Integer.Parse(iRet) > 0 Then
            If Not IsInternalUser(Session("user_id")) Then Response.Redirect("/home.aspx")
            'jackie add 04/27/2006 for clear quotation_detail table
            dbUtil.dbExecuteNoQuery("B2B", "delete from quotation_detail where quote_id='" & Session("cart_id") & "'")
        
            Dim strCompanyID As String = Trim(Me.txtCh2Company.Text)
            Dim exeFunc As Integer = 0
            Dim g_arrAttributeValue
            exeFunc = Global_Inc.CompanyProfile_Get(Session("COMPANY_ORG_ID"), UCase(strCompanyID), "Base", "PRICE_CLASS", g_arrAttributeValue)
            'Response.Write(g_arrAttributeValue(0))
            'Response.End
            'g_arrAttributeValue(0) = 1
            If g_arrAttributeValue(0) > 0 And Len(strCompanyID) <= 8 Then
		         		
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
            If Request("scrPage") = "" Then
                Response.Redirect("/home.aspx")
            Else
                '--{2005-11-1}--Daive: this is only for CTOS to change company
                Response.Redirect(Request("scrPage") & "&RBU=" & strCompanyID & "")
            End If
            Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
        Else
            Util.JSAlert(Page, "Company ID Not Exist")
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
<ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" ServicePath="~/Services/AutoComplete.asmx" FirstRowSelected="true" 
    ServiceMethod="GetERPId" CompletionInterval="1000" TargetControlID="txtCh2Company" MinimumPrefixLength="2" />
<asp:Panel runat="server" ID="ChgCompPanel" DefaultButton="btnChangeCompany">
    <table width="100%"> 
        <tr> 
            <td width="21" height="33" align="center">&nbsp; </td> 
            <td> 
                <p align="left">
                    <asp:TextBox runat="server" ID="txtCh2Company" Width="110px" Height="17px"/> 
                    <asp:ImageButton runat="server" ID="btnChangeCompany" ImageUrl="~/Images/go.gif" AlternateText="Change" Width="19px" Height="17px" BorderWidth="0px" OnClick="btnChangeCompany_Click" />
                </p>  
            </td> 
        </tr>
    </table>
</asp:Panel>
