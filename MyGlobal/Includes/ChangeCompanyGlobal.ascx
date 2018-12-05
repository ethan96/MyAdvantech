<%@ Control Language="VB" ClassName="ChangeCompanyGlobal" %>

<script runat="server">
    Public Event ChangeCompleted()
    Public Property ChangeToERPIDNow() As String
        Get
            Return TargetCompanyId
        End Get
        Set(ByVal value As String)
            TargetCompanyId = value
            btnChangeCompany_Click(Me.btnChangeCompany, New EventArgs)
            RaiseEvent ChangeCompleted()
        End Set
    End Property
    
    Public Property TargetCompanyId() As String
        Get
            Return Me.txtCh2Company.Text
        End Get
        Set(ByVal value As String)
            Me.txtCh2Company.Text = value
        End Set
    End Property
    
    Public Shared Sub CompanyProfile_Get( _
    ByVal strOrg_Id As String, ByVal strCompany_Id As String, ByVal strAttribute_Type As String, _
    ByVal strAttribute_Name As String, ByRef arrAttribute_Value As String())

        ReDim arrAttribute_Value(10)
        'Dim l_adoRs As SqlClient.SqlDataReader
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

        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        l_intCount = 0

        For i As Integer = 0 To dt.Rows.Count - 1
            l_intCount = l_intCount + 1
            arrAttribute_Value(l_intCount) = dt.Rows(i).Item("attri_value")
        Next
        arrAttribute_Value(0) = l_intCount

    End Sub
    
    Public Function ChangeToCompanyId() As Boolean
        Dim iRet As String = dbUtil.dbExecuteScalar("RFM", _
        String.Format("select count(company_id) from sap_dimcompany where company_id = '{0}' and company_type='Z001'", Trim(txtCh2Company.Text)))
        If Integer.Parse(iRet) > 0 Then
            If Not IsInternalUser(Session("user_id")) Then Response.Redirect("/home.aspx")
            Session("company_id") = Trim(txtCh2Company.Text)
        End If
    End Function
    
    Public Sub btnChangeCompany_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If ChangeToCompanyId() Then
            If Request.ServerVariables("HTTP_REFERER") IsNot Nothing Then Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
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
        '    Case "advantech.de", "advantech.pl", "advantech-uk.com", "advantech.fr", "advantech.it", "advantech.nl", "advantech-nl.nl", "advantech.com.tw", "advantech.com.cn", "advantech.com", "advantech.eu"
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

    Protected Sub SearchCompany()
        Dim sql As String = "select distinct top 50 company_id, company_name from company where company_type='partner' "
        If Trim(txtCompanyID.Text) <> "" Or Trim(txtCompanyName.Text) <> "" Then
            If Trim(txtCompanyID.Text) <> "" Then sql += " and company_id like '%" + Trim(txtCompanyID.Text) + "%' "
            If Trim(txtCompanyName.Text) <> "" Then sql += " and company_name like '%" + Trim(txtCompanyName.Text) + "%' "
        End If
        ViewState("SqlCommand") = ""
        SqlDataSource1.SelectCommand = sql + " order by company_id"
        ViewState("SqlCommand") = SqlDataSource1.SelectCommand
    End Sub
    
    Protected Sub SearchAdminCompany()
        Dim rbuList As String = dbUtil.dbExecuteScalar("My", "select replace(cast(rbu.query('for $i in //rbu return data($i)') as varchar(max)),' ',', ') as rbu from account_admin where userid='" + Session("user_id") + "'")
        rbuList = rbuList.Replace("FUTURE, Engineering", "FUTURE Engineering")
        Dim rbuArray As New ArrayList
        If rbuList.Replace("&nbsp;", "") <> "" Then
            Dim rbu() As String = Trim(rbuList).Replace(", ", ",").Split(",")
            For i As Integer = 0 To rbu.Length - 1
                rbuArray.Add("'" + rbu(i) + "'")
            Next
            If rbuArray.Count > 0 Then
                If rbuArray.Item(0).ToString = "'All'" Then
                    Call SearchCompany()
                Else
                    Dim sql As String = MYSIEBELDAL.GetAdminCompany()
                    If Trim(txtCompanyID.Text) <> "" Or Trim(txtCompanyName.Text) <> "" Then
                        If Trim(txtCompanyID.Text) <> "" Then sql += " and a.erp_id like '%" + Trim(txtCompanyID.Text) + "%' "
                        If Trim(txtCompanyName.Text) <> "" Then sql += " and b.company_name like '%" + Trim(txtCompanyName.Text) + "%' "
                    End If
                    ViewState("SqlCommand") = ""
                    SqlDataSource1.SelectCommand = sql + " order by a.erp_id"
                    ViewState("SqlCommand") = SqlDataSource1.SelectCommand
                End If
            End If
        End If
    End Sub

    Protected Sub btnPickCompany_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtCompanyID.Text = Trim(txtCh2Company.Text)
        If LCase(Request.ServerVariables("URL")) = "/admin/profile_admin.aspx" Then
            Call SearchAdminCompany()
        Else
            Call SearchCompany()
        End If
        'Call SearchCompany()
        ModalPopupExtender1.Show()
        up2.Update()
    End Sub

    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        ModalPopupExtender1.Hide()
        up2.Update()
    End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub btnSearchCompanyID_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If LCase(Request.ServerVariables("URL")) = "/admin/profile_admin.aspx" Then
            Call SearchAdminCompany()
        Else
            Call SearchCompany()
        End If
        'Call SearchCompany()
    End Sub
        
    Protected Sub btnCompanyID_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        txtCh2Company.Text = CType(sender, LinkButton).Text
        ModalPopupExtender1.Hide()
        up1.Update()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If LCase(Request.ServerVariables("URL")) = "/admin/profile_admin.aspx" Then
            ac1.ServiceMethod = "GetAdminERPId"
        Else
            ac1.ServiceMethod = "GetERPId"
        End If
    End Sub
</script>

<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
    <ContentTemplate>
        <ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" ServicePath="~/Services/AutoComplete.asmx" FirstRowSelected="true" 
            ServiceMethod="" CompletionInterval="1000" TargetControlID="txtCh2Company" MinimumPrefixLength="2" />
        <asp:Panel runat="server" ID="ChgCompPanel" DefaultButton="btnChangeCompany">
            <table width="100%"> 
                <tr> 
                    <td width="21" height="33" align="center">&nbsp; </td> 
                    <td> 
                        <p align="left">
                            <asp:TextBox runat="server" ID="txtCh2Company" Width="110px" Height="17px"/> 
                            <asp:Button runat="server" ID="btnPickCompany" Text="Pick" OnClick="btnPickCompany_Click" />
                            <asp:Button runat="server" ID="btnChangeCompany" Text="Change" OnClick="btnChangeCompany_Click" />
                            <asp:LinkButton runat="server" ID="link1" />
                            <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" PopupControlID="Panel1" 
                                         PopupDragHandleControlID="Panel1" TargetControlID="link1" BackgroundCssClass="modalBackground" />
                            <asp:Panel runat="server" ID="Panel1">
                                <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <table width="550" height="460" border="0" cellpadding="0" cellspacing="0" bgcolor="f1f2f4">
                                            <tr><td colspan="3" height="10">&nbsp</td></tr>
                                            <tr>
                                                <td>
                                                    &nbsp;&nbsp;<font size="2">Company ID : </font><asp:TextBox runat="server" ID="txtCompanyID" />
                                                </td>
                                                <td>
                                                    <font size="2">Company Name : </font><asp:TextBox runat="server" ID="txtCompanyName" />
                                                </td>
                                                <td>
                                                    <asp:Button runat="server" ID="btnSearchCompanyID" Text="Search" OnClick="btnSearchCompanyID_Click" />
                                                </td>
                                            </tr>
                                            <tr><td colspan="3" height="10">&nbsp</td></tr>
                                            <tr>
                                                <td colspan="3" valign="top" align="center">
                                                    <asp:GridView runat="server" ID="sgv1" AutoGenerateColumns="false" AllowPaging="true" AllowSorting="true" PageSize="10"
                                                         Width="97%" DataSourceID="SqlDataSource1">
                                                        <Columns>
                                                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                                <headertemplate>
                                                                    No.
                                                                </headertemplate>
                                                                <itemtemplate>
                                                                    <%# Container.DataItemIndex + 1 %>
                                                                </itemtemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Company ID" SortExpression="company_id" ItemStyle-HorizontalAlign="Left">
                                                                <ItemTemplate>
                                                                    <asp:LinkButton runat="server" ID="btnCompanyID" CommandName="Select" Text='<%# Eval("company_id") %>' OnClick="btnCompanyID_Click" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:BoundField DataField="company_name" HeaderText="Company Name" SortExpression="company_name" ItemStyle-HorizontalAlign="Left" />
                                                        </Columns>                                                       
                                                    </asp:GridView>
                                                    <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ connectionStrings:B2B %>"
                                                         SelectCommand="" OnLoad="SqlDataSource1_Load">
                                                    </asp:SqlDataSource>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="center" colspan="3"><asp:LinkButton runat="server" ID="btnClose" Text="[Close]" OnClick="btnClose_Click" /></td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </asp:Panel>
                        </p>  
                    </td> 
                </tr>
            </table>
        </asp:Panel>
    </ContentTemplate>
</asp:UpdatePanel>