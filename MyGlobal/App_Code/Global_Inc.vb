Imports Microsoft.VisualBasic

Imports System.Reflection
Imports ADODB
Imports MSXML2
Imports System.IO
Imports System.Text
Imports System.Data.SqlClient
Imports Sgml
Imports System.Xml

Public Class Global_Inc
    Dim MailMsg As System.Net.Mail.MailMessage

    Public Shared Function GetComponentImageUrl(ByVal material_group As String, ByVal part_no As String) As String

        If UCase(part_no) Like "IPC-*" Or UCase(part_no) Like "PPC-*" Then
            Return "~/Images/eConfig_Icons_Advantech/chassis_adv.gif"
            Exit Function
        End If

        If UCase(part_no) Like "OPTION*" Or UCase(part_no) Like "S-WARRANTY*" Then
            Return "~/Images/eConfig_Icons_Advantech/serv_adv.gif"
            Exit Function
        End If

        Try
            If UCase(part_no) Like "P-*" Then
                Dim PType As String = Left(UCase(part_no), 4)
                Select Case PType
                    Case "P-MP"
                        Return "~/Images/eConfig_Icons_Advantech/cpu.gif"
                    Case "P-DI", "P-SI", "P-DR"
                        Return "~/Images/eConfig_Icons_Advantech/mem_adv.gif"
                    Case "P-HD"
                        Return "~/Images/eConfig_Icons_Advantech/harddisk_adv.gif"
                    Case "P-FD", "P-SS"
                        Return "~/Images/eConfig_Icons_Advantech/flash _adv.gif"
                    Case "P-FW"
                        Return "~/Images/eConfig_Icons_Advantech/storage.gif"
                    Case "P-CD", "P-VD", "P-CR", "P-VR"
                        Return "../Images/eConfig_Icons_Advantech/cd_dvd_adv.gif"
                    Case "P-TM"
                        Return "../Images/eConfig_Icons_Advantech/display.gif"
                    Case "P-SW"
                        Return "../Images/eConfig_Icons_Advantech/software.gif"
                    Case "P-MS"
                        Return "../Images/eConfig_Icons_Advantech/mouse_adv.gif"
                    Case "P-SA"
                        Return "../Images/eConfig_Icons_Advantech/soundcard_adv.gif"
                    Case "P-LN"
                        Return "../Images/eConfig_Icons_Advantech/network_card_adv.gif"
                    Case "P-SC"
                        Return "../Images/eConfig_Icons_Advantech/scsi_adv.gif"
                    Case "P-KB"
                        Return "../Images/eConfig_Icons_Advantech/keyboard_adv.gif"
                    Case "P-BR"
                        Return "../Images/eConfig_Icons_Advantech/mob_rack_adv.gif"
                    Case Else
                        Return "../Images/eConfig_Icons_Advantech/other.gif"
                End Select
            Else
                If part_no Like "96*" Then
                    Dim PType As String = Left(UCase(part_no), 4)
                    Select Case PType
                        Case "96MP"
                            Return "~/Images/eConfig_Icons_Advantech/cpu.gif"
                        Case "96MM"
                            Return "../Images/eConfig_Icons_Advantech/mem_adv.gif"
                        Case "96HD"
                            Return "../Images/eConfig_Icons_Advantech/harddisk_adv.gif"
                        Case "96FD"
                            Return "../Images/eConfig_Icons_Advantech/floppy_adv.gif"
                        Case "96OD"
                            Return "../Images/eConfig_Icons_Advantech/cd_dvd_adv.gif"
                        Case "96MT"
                            Return "../Images/eConfig_Icons_Advantech/display.gif"
                        Case "96SW"
                            Return "../Images/eConfig_Icons_Advantech/software.gif"
                        Case "968Q"
                            Return "../Images/eConfig_Icons_Advantech/license.gif"
                        Case "96SC"
                            Return "../Images/eConfig_Icons_Advantech/scsi_adv.gif"
                        Case "96BR"
                            Return "../Images/eConfig_Icons_Advantech/mob_rack_adv.gif"
                        Case Else
                            Return "../Images/eConfig_Icons_Advantech/other.gif"
                    End Select
                Else
                    If UCase(part_no) Like "PCI*" Then
                        Return "../Images/eConfig_Icons_Advantech/iocard_adv.gif"
                    Else
                        If UCase(part_no) Like "96RACK*" Then
                            Return "../Images/eConfig_Icons_Advantech/mob_rack_adv.gif"
                        Else
                            Return "../Images/eConfig_Icons_Advantech/other.gif"
                        End If

                    End If
                End If

            End If
            'End Select
        Catch ex As Exception
            'Response.Write("geturl:" & ex.Message & "<br>")
            Return "../Images/eConfig_Icons_Advantech/other.gif"
        End Try

    End Function

    Public Shared Function C_ShowRoHS() As Boolean
        Return True
    End Function

    Public Shared Function PromotionRelease() As Boolean
        Return True
    End Function

    Public Shared Function HotMarkRelease() As Boolean
        Dim flg As Boolean = False
        If LCase(HttpContext.Current.Session("user_id")) = "daive.wang@advantech.com.cn" _
          Or LCase(HttpContext.Current.Session("user_id")) = "tc.chen@advantech.com.tw" _
          Or LCase(HttpContext.Current.Session("user_id")) = "emil.hsu@advantech.com.tw" _
          Or LCase(HttpContext.Current.Session("user_id")) = "emil.hsu@advantech.com.de" _
          Or LCase(HttpContext.Current.Session("user_id")) = "jackie.wu@advantech.com.cn" _
          Then
            flg = True
        End If
        'flg=false 
        Return flg
    End Function

    'Public Shared Function CBOM_RETRIEVE(ByVal category_id As String, ByVal entity As String, ByVal db As String) As DataTable
    '    Return Util.GetQBOMSql(category_id)
    '    'Dim sqlConn As New SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
    '    'Dim da As New System.Data.SqlClient.SqlDataAdapter()
    '    'da.SelectCommand = New System.Data.SqlClient.SqlCommand
    '    'da.SelectCommand.Connection = sqlConn
    '    'da.SelectCommand.CommandType = CommandType.StoredProcedure
    '    'da.SelectCommand.CommandText = "CBOM_RETRIEVE"
    '    'Dim para1 As New System.Data.SqlClient.SqlParameter("@category_id", SqlDbType.Text)
    '    'para1.Direction = ParameterDirection.Input
    '    'para1.Value = category_id
    '    'da.SelectCommand.Parameters.Add(para1)
    '    'Dim dt As New DataTable
    '    'Try
    '    '    da.Fill(dt)
    '    'Catch ex As Exception
    '    '    sqlConn.Close()
    '    '    sqlConn.Dispose()
    '    '    Return New DataTable
    '    '    Exit Function
    '    'End Try
    '    'sqlConn.Close()
    '    'sqlConn.Dispose()
    '    'Return dt
    'End Function


    'Public Shared Sub InitSession()
    '    With HttpContext.Current
    '        Dim g_arrAttributeValue
    '        UserProfile_Get(.Session("USER_ID"), "Base", "JOB_FUNCTION", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            .Session("USER_ROLE") = g_arrAttributeValue(1)
    '        End If

    '        UserProfile_Get(.Session("USER_ID"), "Profile", "B2B User Role", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            .Session("USER_ROLE") = g_arrAttributeValue(1)
    '        End If

    '        '---- Company Session ----'
    '        UserProfile_Get(.Session("USER_ID"), "Base", "ORG_ID", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            .Session("COMPANY_ORG_ID") = g_arrAttributeValue(1)
    '        End If

    '        UserProfile_Get(.Session("USER_ID"), "Base", "COMPANY_ID", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            .Session("COMPANY_ID") = g_arrAttributeValue(1)
    '        End If

    '        CompanyProfile_Get(.Session("COMPANY_ORG_ID"), .Session("COMPANY_ID"), "Base", "PRICE_CLASS", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            'No use
    '            .Session("COMPANY_PRICE_CLASS") = g_arrAttributeValue(1)
    '        End If

    '        CompanyProfile_Get(.Session("COMPANY_ORG_ID"), .Session("COMPANY_ID"), "Base", "PTRADE_PRICE_CLASS", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            'No use
    '            .Session("COMPANY_PTRADE_PRICE_CLASS") = g_arrAttributeValue(1)
    '        End If


    '        CompanyProfile_Get(.Session("COMPANY_ORG_ID"), .Session("COMPANY_ID"), "Base", "CURRENCY", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            .Session("COMPANY_CURRENCY") = UCase(g_arrAttributeValue(1))
    '        End If

    '        CompanyProfile_Get(.Session("COMPANY_ORG_ID"), .Session("COMPANY_ID"), "Base", "COMPANY_NAME", g_arrAttributeValue)
    '        If g_arrAttributeValue(0) > 0 Then
    '            .Session("COMPANY_NAME") = g_arrAttributeValue(1)
    '        End If

    '        Select Case UCase(.Session("COMPANY_CURRENCY"))
    '            Case "NT"
    '                .Session("COMPANY_CURRENCY_SIGN") = "NT"
    '            Case "US", "USD"
    '                .Session("COMPANY_CURRENCY_SIGN") = "US$"
    '            Case "EUR"
    '                .Session("COMPANY_CURRENCY_SIGN") = "&euro;"
    '            Case "YEN"
    '                .Session("COMPANY_CURRENCY_SIGN") = "&yen;"
    '            Case "GBP"
    '                .Session("COMPANY_CURRENCY_SIGN") = "&pound;"
    '            Case Else
    '                .Session("COMPANY_CURRENCY_SIGN") = "&euro;"
    '        End Select

    '        Dim strUniqueId As String = ""

    '        '---- { 25-01-05 } TO "I"
    '        UniqueID_Get("EU", "L", 12, strUniqueId)
    '        .Session("CART_ID") = strUniqueId
    '        .Session("LOGISTICS_ID") = strUniqueId
    '        .Session("ORDER_ID") = strUniqueId

    '        Dim G_CATALOG_ID As String = ""

    '        UniqueID_Get("CF", "L", 12, G_CATALOG_ID)
    '        .Session("G_CATALOG_ID") = G_CATALOG_ID

    '        Dim l_strSQLCmd = "insert access_history (unique_id,session_id,login_date_time,userid,login_ip) " & _
    '                            "values(" & _
    '                            "'" & strUniqueId & "'," & _
    '                            "'" & CStr(.Session.SessionID) & "'," & _
    '                            "Getdate()," & _
    '                            "'" & .Session("USER_ID") & "'," & _
    '                            "'" & HttpContext.Current.Request.ServerVariables("REMOTE_HOST") & "')"
    '        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
    '        Cart_Initiate(.Session("CART_ID"), .Session("COMPANY_CURRENCY"))
    '        .Session.CodePage = 65001
    '    End With

    'End Sub

    Public Shared Function UserProfile_Get(ByVal strUser_Id, ByVal strAttribute_Type, ByVal strAttribute_Name, ByRef arrAttribute_Value)
        ReDim arrAttribute_Value(10)
        'Dim l_adoRs As SqlClient.SqlDataReader
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

        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        l_intCount = 0
        For i As Integer = 0 To dt.Rows.Count - 1
            l_intCount = l_intCount + 1
            arrAttribute_Value(l_intCount) = dt.Rows(i).Item("attri_value")
        Next
        arrAttribute_Value(0) = l_intCount
        UserProfile_Get = 1
        'l_adoRs = Nothing
        'cn.Close()
    End Function

    Public Shared Function CompanyProfile_Get(ByVal strOrg_Id, ByVal strCompany_Id, ByVal strAttribute_Type, ByVal strAttribute_Name, ByRef arrAttribute_Value)

        ReDim arrAttribute_Value(10)
        'Dim l_adoRs As SqlClient.SqlDataReader
        Dim l_strSQLCmd As String
        Dim l_intCount As Integer

        Select Case strAttribute_Type
            Case "Base"

                l_strSQLCmd = "select " & strAttribute_Name & " as attri_value from sap_dimcompany  " & _
                     " where company_id = '" & strCompany_Id & "' and company_type in ('Partner','Z001')"
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

        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", l_strSQLCmd)
        l_intCount = 0

        For i As Integer = 0 To dt.Rows.Count - 1
            l_intCount = l_intCount + 1
            arrAttribute_Value(l_intCount) = dt.Rows(i).Item("attri_value")
        Next
        arrAttribute_Value(0) = l_intCount
        CompanyProfile_Get = 1

    End Function

    Public Shared Function Cart_Initiate(ByVal strCart_Id, ByVal strCurrency)

        Dim l_adoRs
        Dim l_strSQLCmd

        l_strSQLCmd = "delete from cart_master where cart_id = '" & strCart_Id & "'"
        dbUtil.dbExecuteScalar("B2B", l_strSQLCmd)
        l_strSQLCmd = "delete from cart_detail where cart_id = '" & strCart_Id & "'"
        dbUtil.dbExecuteScalar("B2B", l_strSQLCmd)
        l_strSQLCmd = "insert cart_master (cart_id,currency,checkout_flag) " & _
            "values('" & strCart_Id & "'," & _
            "'" & strCurrency & "'," & _
            "'N')"
        dbUtil.dbExecuteScalar("B2B", l_strSQLCmd)
        Cart_Initiate = 1
        l_adoRs = Nothing

    End Function


    Public Shared Function SiteDefinition_Get(ByVal szSite_Parameter, ByRef szPara_Value)
        If szSite_Parameter = "SOFolder" Then
            szPara_Value = "c:\MyAdvantech\Files\so\" : Return szPara_Value
        End If
        If szSite_Parameter = "AeuEbizB2BWs" Then
            szPara_Value = "http://172.21.34.44:9000/B2B_SAP_WS.asmx"
            Return szPara_Value
        End If
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
        "select Site_Parameter,Para_Value from SITE_DEFINITION where Site_Parameter=" & "'" & szSite_Parameter & "'")
        If dt Is Nothing Then
            Return ""
            Exit Function
        End If
        If dt.Rows.Count = 0 Then
            Return ""
            Exit Function
        End If
        szPara_Value = dt.Rows(0).Item("Para_Value").ToString()
        Return 1

    End Function

    Public Shared Function SiteDefinition_Get(ByVal szSite_Parameter As String) As String
        Select Case szSite_Parameter.ToUpper()
            Case "SOFOLDER"
                Return "c:\MyAdvantech\Files\so\"
            Case "BTOSWORKINGDAYS"
                Return 5
            Case Else
        End Select
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
        "select Site_Parameter,Para_Value from SITE_DEFINITION where Site_Parameter=" & "'" & szSite_Parameter & "'")
        If dt Is Nothing Then
            Return ""
            Exit Function
        End If
        If dt.Rows.Count = 0 Then
            Return ""
            Exit Function
        End If
        Return dt.Rows(0).Item("Para_Value").ToString()
    End Function

    'Public Shared Function IsB2BOwner(ByVal user_id As String) As Boolean

    '    user_id = LCase(Trim(user_id))

    '    If user_id <> "emil.hsu@advantech.de" And _
    '       user_id <> "emil.hsu@advantech.com.tw" And _
    '       user_id <> "pri.supriyanto@advantech.de" And _
    '       user_id <> "daive.wang@advantech.com.cn" And _
    '       user_id <> "nada.liu@advantech.com.cn" And _
    '       user_id <> "ming.zhao@advantech.com.cn" And _
    '       user_id <> "tc.chen@advantech.com.tw" Then
    '        IsB2BOwner = False
    '    Else
    '        IsB2BOwner = True
    '    End If

    'End Function

    'Public Shared Function IsB2BSA(ByVal user_id)

    '    user_id = LCase(Trim(user_id))

    '    If user_id <> "emil.hsu@advantech.de" And _
    '       user_id <> "emil.hsu@advantech.com.tw" And _
    '       user_id <> "pri.supriyanto@advantech.de" And _
    '       user_id <> "daive.wang@advantech.com.cn" And _
    '       user_id <> "jackie.wu@advantech.com.cn" And _
    '       user_id <> "tc.chen@advantech.com.tw" And _
    '       user_id <> "maria.unger@advantech.de" And _
    '       user_id <> "antonios.tsetsos@advantech.de" And _
    '       user_id <> "pauline.dujardin@advantech.fr" And _
    '       user_id <> "sabine.lin@advantech.fr" And _
    '       user_id <> "leroy.boeren@advantech.nl" And _
    '       user_id <> "marco.pavesi@advantech.it" Then

    '        IsB2BSA = False
    '    Else
    '        IsB2BSA = True
    '    End If

    'End Function

    'Public Shared Function IsRLP(ByVal UserId As String, ByVal CompanyId As String) As Boolean
    '    If CompanyId Is Nothing Then Return False
    '    Select Case CompanyId.ToUpper
    '        Case "UUAAESC", "EUKADV", "EUKA001", "EFRA008", "EITW004", "EITW005", "EHLC001", "EHLA002", "ENLA001"
    '            If UserId.ToLower.IndexOf("maria.nger") = -1 And _
    '               UserId.ToLower.IndexOf("sabino.lobascio") = -1 And _
    '               UserId.ToLower.IndexOf("medet.boeluebasi") = -1 And _
    '               UserId.ToLower.IndexOf("yvonne.krall") = -1 And _
    '               UserId.ToLower.IndexOf("mehtap.sarcan") = -1 And _
    '               UserId.ToLower.IndexOf("andre.obler") = -1 And _
    '               UserId.ToLower.IndexOf("kristian.nikander") = -1 And _
    '               UserId.ToLower.IndexOf("pauline.dujardin") = -1 And _
    '               UserId.ToLower.IndexOf("sabine.lin") = -1 And _
    '               UserId.ToLower.IndexOf("sara.kailla") = -1 And _
    '               UserId.ToLower.IndexOf("marco.pavesi") = -1 And _
    '               UserId.ToLower.IndexOf("cristina.ravaioli") = -1 And _
    '               UserId.ToLower.IndexOf("michael.vanderveeken") = -1 And _
    '               UserId.ToLower.IndexOf("simone.vanas") = -1 And _
    '               UserId.ToLower.IndexOf("ans.groothedde") = -1 And _
    '               UserId.ToLower.IndexOf("leroy.boeren") = -1 Then
    '                IsRLP = True
    '            Else
    '                IsRLP = False
    '            End If
    '        Case Else
    '            IsRLP = False
    '    End Select
    'End Function
   
    Public Shared Function IsRBU(ByVal CompanyCode As String, ByRef RBUMailFormat As String) As Boolean
        'Dim tempCode As Object = dbUtil.dbExecuteScalar("my", "select company_id from RBUcompany where company_id='" & CompanyCode & "'")

        'If tempCode IsNot Nothing AndAlso tempCode <> "" Then
        '    Return True
        'End If
        Return False
        'Select Case UCase(CompanyCode)
        '    Case "UUAAESC"
        '        RBUMailFormat = "advantech.de"
        '        IsRBU = True

        '    Case "EUKA001", "EUKADV"
        '        RBUMailFormat = "advantech-uk.com"
        '        IsRBU = True

        '    Case "EFRA008"
        '        RBUMailFormat = "advantech.fr"
        '        IsRBU = True

        '    Case "EITW004", "EITW005"
        '        RBUMailFormat = "advantech.it"
        '        IsRBU = True

        '    Case "EHLC001", "EHLA002", "ENLA001"
        '        RBUMailFormat = "advantech.nl"
        '        IsRBU = True

        '        'Case "EPLA001"
        '        '    RBUMailFormat = "advantech.nl"
        '        '    IsRBU = True

        '    Case Else
        '        IsRBU = False

        'End Select

    End Function

    Public Shared Function IsInternalUser(ByVal User_Id) As Boolean
        Return Util.IsInternalUser2()
        'Dim uArray, MailDomain, role
        'uArray = Split(User_Id, "@")
        'On Error Resume Next
        'MailDomain = LCase(Trim(uArray(1)))
        'If Err.Number <> 0 Then
        '    IsInternalUser = False
        '    Exit Function
        'End If
        'On Error GoTo 0
        'Select Case LCase(MailDomain)
        '    Case "advantech.de", "advantech-uk.com", "advantech.fr", "advantech.it", "advantech.nl", "advantech-nl.nl", "advantech.com.tw", "advantech.com.cn", "advantech.com", "advantech.eu"
        '        IsInternalUser = True
        '    Case Else
        '        IsInternalUser = False
        'End Select
    End Function

    Public Shared Function IsInternalUser() As Boolean
        If Util.IsAEUIT() Or Util.IsInternalUser2() Then
            Return True
        Else
            Return False
        End If
        'If LCase(HttpContext.Current.Session("USER_ROLE")) = "logistics" Or LCase(HttpContext.Current.Session("USER_ROLE")) = "administrator" Then
        '    IsInternalUser = True
        'Else
        '    IsInternalUser = False
        'End If
    End Function



    Public Shared Function UniqueID_Get(ByVal strHeader, ByVal strFooter, ByVal intLen, ByRef strResult)

        strResult = System.Guid.NewGuid().ToString().ToUpper()
        strResult = Replace(strResult, "-", "")
        Return 1

    End Function

    Public Shared Function DataTableToADOXML(ByVal table1 As DataTable) As String

        Dim class1 As New DOMDocumentClass
        Dim class2 As New RecordsetClass
        Dim num1 As Integer
        For num1 = 0 To table1.Columns.Count - 1
            Select Case table1.Columns.Item(num1).DataType.ToString
                Case "System.Int16"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adSmallInt, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.SByte"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adTinyInt, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.Int32"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adInteger, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.Int64"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adBigInt, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.Single"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adSingle, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.Double"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adDouble, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.Decimal"
                    'class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adDecimal, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adCurrency, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.DateTime"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adDate, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.Object"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adVariant, 0, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case "System.String"
                    class2.Fields.Append(table1.Columns.Item(num1).ColumnName, DataTypeEnum.adVarChar, table1.Columns.Item(num1).MaxLength, FieldAttributeEnum.adFldUnspecified, Missing.Value)
                    GoTo Label_02EC
                Case Else
                    GoTo Label_02EC
            End Select

Label_02EC:

        Next num1

        class2.CursorLocation = CursorLocationEnum.adUseClient
        class2.Open(Missing.Value, Missing.Value, CursorTypeEnum.adOpenUnspecified, LockTypeEnum.adLockUnspecified, -1)

        Dim num2 As Integer
        For num2 = 0 To table1.Rows.Count - 1
            class2.AddNew(Missing.Value, Missing.Value)
            Dim num3 As Integer
            For num3 = 0 To table1.Columns.Count - 1
                If (table1.Rows.Item(num2).Item(table1.Columns.Item(num3).ColumnName) Is DBNull.Value) Then
                    class2.Fields.Item(table1.Columns.Item(num3).ColumnName).Value = table1.Columns.Item(num3).DefaultValue
                Else
                    class2.Fields.Item(table1.Columns.Item(num3).ColumnName).Value = table1.Rows.Item(num2).Item(table1.Columns.Item(num3).ColumnName)
                End If
            Next num3
        Next num2

        class2.Save(class1, PersistFormatEnum.adPersistXML)
        Return class1.xml

    End Function

    Public Shared Function FormatDate(ByVal xDate) As String
        Dim xYear As String = "0000"
        Dim xMonth As String = "00"
        Dim xDay As String = "00"
        Try


            If IsDate(xDate) = True Then
                xYear = Year(xDate).ToString
                xMonth = Month(xDate).ToString
                xDay = Day(xDate).ToString
            Else
                Dim ArrDate() As String = xDate.Split("/")

                If ArrDate(0).Length = 4 Then
                    xYear = ArrDate(0)
                    xMonth = ArrDate(1)
                    xDay = ArrDate(2)
                ElseIf UBound(ArrDate) >= 2 Then
                    xYear = ArrDate(2)
                    xMonth = ArrDate(0)
                    xDay = ArrDate(1)
                ElseIf UBound(ArrDate) = 0 Then
                    If ArrDate(0).Length = 8 Then
                        xYear = Left(ArrDate(0), 4)
                        xMonth = Mid(ArrDate(0), 5, 2)
                        xDay = Right(ArrDate(0), 2)
                    End If
                End If
            End If

            If xMonth.Length = 1 Then
                xMonth = "0" & xMonth
            End If
            If xDay.Length = 1 Then
                xDay = "0" & xDay
            End If
        Catch ex As Exception

        End Try
        If xYear = "0000" And xMonth = "00" And xDay = "00" Then
            FormatDate = ""
        Else
            FormatDate = xYear & "/" & xMonth & "/" & xDay
        End If
    End Function

    Public Shared Function FormatDate_New(ByVal xDate) As String
        Dim xYear As String = "0000"
        Dim xMonth As String = "00"
        Dim xDay As String = "00"
        Try


            If IsDate(xDate) = True Then
                xYear = Year(xDate).ToString
                xMonth = Month(xDate).ToString
                xDay = Day(xDate).ToString
            Else
                Dim ArrDate() As String = xDate.Split("/")

                If ArrDate(0).Length = 4 Then
                    xYear = ArrDate(0)
                    xMonth = ArrDate(1)
                    xDay = ArrDate(2)
                ElseIf UBound(ArrDate) >= 2 Then
                    xYear = ArrDate(2)
                    xMonth = ArrDate(0)
                    xDay = ArrDate(1)
                ElseIf UBound(ArrDate) = 0 Then
                    If ArrDate(0).Length = 8 Then
                        xYear = Left(ArrDate(0), 4)
                        xMonth = Mid(ArrDate(0), 5, 2)
                        xDay = Right(ArrDate(0), 2)
                    End If
                End If
            End If

            If xMonth.Length = 1 Then
                xMonth = "0" & xMonth
            End If
            If xDay.Length = 1 Then
                xDay = "0" & xDay
            End If
        Catch ex As Exception

        End Try
        If xYear = "0000" And xMonth = "00" And xDay = "00" Then
            FormatDate_New = ""
        Else
            FormatDate_New = xYear & "-" & xMonth & "-" & xDay
        End If
    End Function

    Public Shared Function FormatDate(ByVal xDate, ByVal xFormat) As String
        Dim xYear As String = "0000"
        Dim xMonth As String = "00"
        Dim xDay As String = "00"

        If IsDate(xDate) = True Then
            xYear = Year(xDate).ToString
            xMonth = Month(xDate).ToString
            xDay = Day(xDate).ToString
        Else
            Dim ArrDate() As String = xDate.Split("/")

            If ArrDate(0).Length = 4 Then
                xYear = ArrDate(0)
                xMonth = ArrDate(1)
                xDay = ArrDate(2)
            ElseIf UBound(ArrDate) >= 2 Then
                xYear = ArrDate(2)
                xMonth = ArrDate(0)
                xDay = ArrDate(1)
            ElseIf UBound(ArrDate) = 0 Then
                If ArrDate(0).Length = 8 Then
                    xYear = Left(ArrDate(0), 4)
                    xMonth = Mid(ArrDate(0), 5, 2)
                    xDay = Right(ArrDate(0), 2)
                End If
            End If
        End If

        If xMonth.Length = 1 Then
            xMonth = "0" & xMonth
        End If
        If xDay.Length = 1 Then
            xDay = "0" & xDay
        End If
        Select Case LCase(xFormat)
            Case "yyyy/mm/dd"
                FormatDate = xYear & "/" & xMonth & "/" & xDay
            Case "mm/dd/yy"
                FormatDate = xMonth & "/" & xDay & "/" & xYear
            Case Else
                FormatDate = xYear & "/" & xMonth & "/" & xDay
        End Select
        If xYear = "0000" And xMonth = "00" And xDay = "00" Then
            FormatDate = ""
        Else
            FormatDate = xYear & "/" & xMonth & "/" & xDay
        End If
    End Function

    

    Public Shared Function HTMLEncode(ByVal fString As String) As String
        Return HttpContext.Current.Server.HtmlEncode(fString)
    End Function

    Public Shared Function CheckBTOSConfirmOrder(ByVal strID As String) As Boolean
        '----20070603 emil for server movement from aesc to aeu-hq
        'Dim dt As DataTable = Me.dbGetDataTable("172.21.32.4", "b2b_aesc_sap", _
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
        "select part_no from logistics_detail where logistics_id='" & strID & "' and line_no=100")
        If dt Is Nothing Then
            Return False
            Exit Function
        End If
        If dt.Rows.Count = 0 Then
            Return False
            Exit Function
        End If

        Return True
    End Function

    Public Shared Function HasAccountingView(ByVal part_no As String, ByVal Plant As String) As Boolean
        HasAccountingView = True
    End Function

    Public Shared Function InitRsATPi(ByRef p_oRsATPi As DataTable) As Integer

        Dim dt1 As New DataTable

        Dim col1 As New System.Data.DataColumn
        col1.MaxLength = 8
        col1.ColumnName = "WERK"
        col1.DataType = Type.GetType("System.String")
        dt1.Columns.Add(col1)

        Dim col2 As New System.Data.DataColumn
        col2.MaxLength = 100
        col2.ColumnName = "MATNR"
        col2.DataType = Type.GetType("System.String")
        dt1.Columns.Add(col2)

        Dim col3 As New System.Data.DataColumn

        col3.ColumnName = "REQ_QTY"
        col3.DataType = Type.GetType("System.Int32")
        dt1.Columns.Add(col3)

        Dim col4 As New System.Data.DataColumn
        col4.ColumnName = "REQ_DATE"
        col4.DataType = Type.GetType("System.DateTime")
        dt1.Columns.Add(col4)

        Dim col5 As New System.Data.DataColumn
        col5.MaxLength = 8
        col5.ColumnName = "UNI"
        col5.DataType = Type.GetType("System.String")
        dt1.Columns.Add(col5)

        'Dim col6 As New System.Data.DataColumn
        'col6.ColumnName = "Stoc"
        'col5.DataType = Type.GetType("System.String")
        'dt1.Columns.Add(col6)

        p_oRsATPi = dt1

        Return 1

    End Function

    Public Shared Function InitATPRs(ByRef p_oRsATPi As DataTable) As Integer

        Dim dt1 As New DataTable

        dt1.Columns.Add("entity", Type.GetType("System.String"))
        dt1.Columns.Item("entity").MaxLength = 8
        dt1.Columns.Add("part", Type.GetType("System.String"))
        dt1.Columns.Item("part").MaxLength = 20
        dt1.Columns.Add("site", Type.GetType("System.String"))
        dt1.Columns.Item("site").MaxLength = 8
        dt1.Columns.Add("type", Type.GetType("System.String"))
        dt1.Columns.Item("type").MaxLength = 10
        dt1.Columns.Add("date", Type.GetType("System.DateTime"))
        dt1.Columns.Add("flag", Type.GetType("System.Int32"))
        dt1.Columns.Add("qty_atb", Type.GetType("System.Int32"))
        dt1.Columns.Add("qty_atp", Type.GetType("System.Int32"))
        dt1.Columns.Add("qty_fullfil", Type.GetType("System.Int32"))
        dt1.Columns.Add("qty_lack", Type.GetType("System.Int32"))
        dt1.Columns.Add("flag_scm", Type.GetType("System.Int32"))
        dt1.Columns.Add("due_date", Type.GetType("System.DateTime"))
        dt1.Columns.Add("due_date_scm", Type.GetType("System.DateTime"))
        dt1.Columns.Add("atp_date_scm", Type.GetType("System.DateTime"))
        p_oRsATPi = dt1

        Return 1

    End Function

    Public Shared Function InitRsATPi_New(ByRef p_oRsATPi As DataTable) As Integer

        Dim dt1 As New DataTable
        dt1.Columns.Add("WERK", Type.GetType("System.String"))
        dt1.Columns.Add("MATNR", Type.GetType("System.String"))
        dt1.Columns.Add("REQ_QTY", Type.GetType("System.Int32"))
        dt1.Columns.Add("REQ_DATE", Type.GetType("System.DateTime"))
        dt1.Columns.Add("UNI", Type.GetType("System.String"))
        dt1.Columns.Add("Stge_Loc", Type.GetType("System.String"))
        dt1.Columns.Add("Hg_Lv_Item", Type.GetType("System.String"))
        dt1.Columns.Add("Dlv_Group", Type.GetType("System.String"))
        p_oRsATPi = dt1
        Return 1

    End Function

    ''' <summary>
    ''' Jackie add 02/23/2006
    ''' </summary>
    ''' <param name="part_no"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function IsPtrade(ByVal part_no) As Boolean
        part_no = Trim(part_no)
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("B2B", _
        " select material_group as certificate from sap_product " + _
        " where part_no='" & part_no & "' and material_group='BTOS'")
        If dt.Rows.Count > 0 Or UCase(Left(part_no, 2)) = "P-" Or UCase(Left(part_no, 4)) = "96SW" Or UCase(Left(part_no, 4)) = "96SS" Or UCase(Left(part_no, 4)) = "96MP" Or UCase(Left(part_no, 4)) = "96HD" Or UCase(Left(part_no, 4)) = "96CF" Or UCase(Left(part_no, 4)) = "96OD" Or UCase(Left(part_no, 4)) = "96MM" Or UCase(Left(part_no, 4)) = "96CA" Or UCase(Left(part_no, 3)) = "ZEU" Or UCase(Left(part_no, 3)) = "ZTW" Then
            IsPtrade = True
        Else
            IsPtrade = False
        End If
    End Function

    Public Shared Function IsPtdProduct(ByVal part_no As String) As Boolean
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("B2B", "select part_no from sap_product where part_no='" & part_no & "' and product_type='ZPER' ")
        If dt.Rows.Count > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function IsPromoting(ByVal xPartNO As String) As Boolean
        Dim xProDT As DataTable
        xProDT = dbUtil.dbGetDataTable("B2B", "select part_no,SPECIAL_FLAG from PROMOTION_PRODUCT_INFO where part_no='" & xPartNO & "' and ONHAND_QTY > 0 and START_DATE <= '" & Date.Today.Date() & "' and EXPIRE_DATE >= '" & Date.Today.Date() & "' and Status='Yes'")
        'response.write(xProDT.Rows.Count)
        'response.end
        If xProDT.Rows.Count > 0 Then
            If xProDT.Rows(0).Item("SPECIAL_FLAG") = 2 Then
                Dim xProSpecDT As DataTable = dbUtil.dbGetDataTable("B2B", "select * from PROMOTION_CUSTOMER_PRICE where part_no='" & xProDT.Rows(0).Item("part_no") & "' and COMPANY_ID='" & HttpContext.Current.Session("COMPANY_ID") & "'")
                If xProSpecDT.Rows.Count > 0 Then
                    IsPromoting = True
                    Exit Function
                End If
            Else
                IsPromoting = True
                Exit Function
            End If
        End If
        IsPromoting = False
    End Function

    Public Shared Function IsPromoting(ByVal xPartNO As String, ByVal xCompanyID As String) As Boolean
        Return False
        If xCompanyID = "" Then xCompanyID = HttpContext.Current.Session("COMPANY_ID")
        Dim xProDT As DataTable
        xProDT = dbUtil.dbGetDataTable("B2B", "select part_no,SPECIAL_FLAG from PROMOTION_PRODUCT_INFO where part_no='" & xPartNO & "' and ONHAND_QTY > 0 and START_DATE <= '" & Date.Today.Date() & "' and EXPIRE_DATE >= '" & Date.Today.Date() & "' and Status='Yes'")
        If xProDT.Rows.Count > 0 Then
            If xProDT.Rows(0).Item("SPECIAL_FLAG") = 2 Then
                Dim xProSpecDT As DataTable = dbUtil.dbGetDataTable("B2B", "select * from PROMOTION_CUSTOMER_PRICE where part_no='" & xProDT.Rows(0).Item("part_no") & "' and COMPANY_ID='" & xCompanyID & "'")
                If xProSpecDT.Rows.Count > 0 Then
                    IsPromoting = True
                    Exit Function
                End If
            Else
                IsPromoting = True
                Exit Function
            End If
        End If
        IsPromoting = False
    End Function

    Public Shared Function IsPromotingSMP(ByVal xPartNO As String, ByVal xCompanyID As String) As Boolean
        Return False
        If xCompanyID = "" Then xCompanyID = HttpContext.Current.Session("COMPANY_ID")
        Dim xProDT As DataTable
        xProDT = dbUtil.dbGetDataTable("B2B", "select part_no,SPECIAL_FLAG,PromotionType from PROMOTION_PRODUCT_INFO where part_no='" & xPartNO & "' and ONHAND_QTY > 0 and START_DATE <= '" & Date.Today.Date() & "' and EXPIRE_DATE >= '" & Date.Today.Date() & "' and Status='Yes'")
        If xProDT.Rows.Count > 0 AndAlso xProDT.Rows(0).Item("PromotionType") = "smp" Then
            If xProDT.Rows(0).Item("SPECIAL_FLAG") = 2 Then
                Dim xProSpecDT As DataTable = dbUtil.dbGetDataTable("B2B", "select * from PROMOTION_CUSTOMER_PRICE where part_no='" & xProDT.Rows(0).Item("part_no") & "' and COMPANY_ID='" & xCompanyID & "'")
                If xProSpecDT.Rows.Count > 0 Then
                    IsPromotingSMP = True
                    Exit Function
                End If
            Else
                IsPromotingSMP = True
                Exit Function
            End If
        End If
        IsPromotingSMP = False
    End Function

    Public Shared Function WeekDayFwd(ByRef inputDate As String, ByVal FwdDays As Integer)
        Dim tDate As String = ""
        Dim xYear As String = "0000"
        Dim xMonth As String = "00"
        Dim xDay As String = "00"

        If IsDate(inputDate) = True Then
            xYear = Year(inputDate).ToString
            xMonth = Month(inputDate).ToString
            xDay = Day(inputDate).ToString
        Else
            Dim ArrDate() As String = inputDate.Split("/")

            If ArrDate(0).Length = 4 Then
                xYear = ArrDate(0)
                xMonth = ArrDate(1)
                xDay = ArrDate(2)
            Else
                xYear = ArrDate(2)
                xMonth = ArrDate(0)
                xDay = ArrDate(1)
            End If
        End If

        If xMonth.Length = 1 Then
            xMonth = "0" & xMonth
        End If
        If xDay.Length = 1 Then
            xDay = "0" & xDay
        End If
        tDate = xYear & "-" & xMonth & "-" & xDay
        Dim exeFunc As Integer = 0
        exeFunc = CalculateSAPWorkingDate(tDate, FwdDays)
        inputDate = CDate(tDate)
        Return 1
    End Function

    Public Shared Function CalculateSAPWorkingDate(ByRef inputDate As String, ByVal Loading_Days As String)

        Dim iRtn As String = 0
        Dim SAP_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        'Try
        '    SAP_WS.Url = dbUtil.dbExecuteScalar("B2B", "select para_value from site_definition where site_parameter='AeuEbizB2bWs'")
        'Catch ex As Exception
        '    Throw ex
        'End Try
        Try
            iRtn = SAP_WS.Get_Next_WrokingDate(inputDate, Loading_Days)
        Catch ex As Exception
            CalculateSAPWorkingDate = -1
            Return CalculateSAPWorkingDate
        End Try
        CalculateSAPWorkingDate = 1
        Return CalculateSAPWorkingDate

    End Function

    Public Shared Function CalculateSAPWorkingDate(ByRef inputDate)

        Dim iRtn As String = 0
        Dim SAP_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        'SAP_WS.Url = "http://172.20.1.102/B2B_SAP_WS/B2B_SAP_WS.asmx?WSDL"
        Try
            SAP_WS.Url = dbUtil.dbExecuteScalar("B2B", "select para_value from site_definition where site_parameter='AeuEbizB2bWs'")
        Catch ex As Exception
            Throw ex
        End Try

        'make the conversion of the datatime
        Dim WorkDays As String = "5"
        Try
            WorkDays = dbUtil.dbExecuteScalar("B2B", "select para_value as BTOWorkDay from site_definition where site_parameter='BTOSWorkingDays'")
        Catch ex As Exception
            WorkDays = 5
        End Try

        Dim strMaxDD As String = ""
        strMaxDD = CDate(inputDate).Year & "-"
        If CInt(CDate(inputDate).Month) < 10 Then
            strMaxDD &= "0" & CDate(inputDate).Month
        Else
            strMaxDD &= CDate(inputDate).Month
        End If
        strMaxDD &= "-"
        If CInt(CDate(inputDate).Day) < 10 Then
            strMaxDD &= "0" & CDate(inputDate).Day
        Else
            strMaxDD &= CDate(inputDate).Day
        End If

        Try
            iRtn = SAP_WS.Get_Next_WrokingDate(strMaxDD, WorkDays)
            inputDate = strMaxDD
        Catch ex As Exception
            CalculateSAPWorkingDate = -1
            Return CalculateSAPWorkingDate
        End Try
        CalculateSAPWorkingDate = 1
        Return CalculateSAPWorkingDate

    End Function


    Public Shared Function Pause(ByVal IntervalSecond)
        Dim i As Integer = 0
        Dim s As Integer = 0
        Dim strNow As Date = Date.Now
        s = System.Math.Abs(CInt(IntervalSecond))
        Do While System.Math.Abs(DateDiff("s", Date.Now, strNow)) < s
            i = 1
            Do While i < 1000
                i = i + 1
            Loop
        Loop
        Return 1
    End Function

    Public Shared Function PhaseOutItem_Check(ByVal strOrder_Id As String) As Integer
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
        "select * from order_detail " & _
        "where " & _
        "auto_order_flag='U' " & _
        "and order_id='" & strOrder_Id & "'")
        If dt.Rows.Count > 0 Then
            Return 0
        Else : Return 1
        End If
    End Function

    Public Shared Function IsOverCreditLimit(ByVal SalesOrg, ByVal Company_Id) As Boolean

        Dim AEU_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        Dim iRtn As Integer = -1
        Dim clpercentage As String = ""
        Try
            iRtn = AEU_WS.GET_CREDITLIMIT_USED_PERCENTAGE(Trim(UCase(SalesOrg)), Trim(UCase(Company_Id)), clpercentage)
        Catch ex As Exception

        End Try

        If iRtn = 1 Then
            IsOverCreditLimit = True
        Else
            IsOverCreditLimit = False
        End If

    End Function

    Public Shared Function SiteDefinitionOrg_Get(ByVal szSite_Parameter, ByRef szPara_Value)
        Dim exeFunc As Integer = 0
        Dim pszPara_Value As String = ""
        exeFunc = SiteDefinition_Get(szSite_Parameter, pszPara_Value)

        If exeFunc = 1 Then
            szPara_Value = pszPara_Value
            SiteDefinitionOrg_Get = pszPara_Value
        Else
            szPara_Value = "N/A"
            SiteDefinitionOrg_Get = szPara_Value
        End If

    End Function

    Public Shared Function GetShiptoInfo(ByVal Shipto_Id, ByRef CountryCode, ByRef Postal)

        Dim sc3 As New aeu_ebus_dev9000.B2B_AEU_WS

        CountryCode = ""
        Postal = ""
        Dim iRtn As Integer = 0
        Try
            'iRtn = sc3.GET_CUSTOMER_COUNTRYPOSTAL_CODE(UCase(Trim(Shipto_Id)), CountryCode, Postal)
        Catch ex As Exception
            GetShiptoInfo = -1
            'Response.Write("GetShiptoInfo failed.")
            'Response.End()
            Exit Function
        End Try

        If Trim(CountryCode) = "" Or Trim(Postal) = "" Then
            'Response.Write(CountryCode & "<br>")
            'Response.Write(Postal & "<br>")
            'Response.Write("No info for this customer")
            'Response.End()
            GetShiptoInfo = 0
            Exit Function
        End If

        GetShiptoInfo = 1

    End Function

    Public Shared Function IsNonStandardPTrade(ByVal part_no)
        If part_no.ToUpper.StartsWith("207") Then
            IsNonStandardPTrade = True
        End If
        Dim pRs As DataTable = dbUtil.dbGetDataTable("RFM", _
        "select IsNull(GENITEMCATGRP, '') as item_category_group,isnull(GENITEMCATGRP,'') as GENITEMCATGROUP from sap_product where part_no='" & part_no & "'")
        If pRs.Rows.Count > 0 Then
            If UCase(pRs.Rows(0).Item("item_category_group")) = "ZSLB" Or (UCase(pRs.Rows(0).Item("item_category_group")) = "ZPTD" And Not (Util.IsInternalUser2())) Or (UCase(pRs.Rows(0).Item("item_category_group")) = "NORM" And UCase(pRs.Rows(0).Item("GENITEMCATGROUP")) = "ZSWL") Then
                IsNonStandardPTrade = True
            Else
                IsNonStandardPTrade = False
            End If
        Else
            IsNonStandardPTrade = False
        End If
        'return 1			
    End Function

    Public Shared Function DeleteZeroOfStr(ByVal strString)

        If IsNumericItem(Trim(strString)) Then
            Dim xStr As String
            Dim i As Integer
            For i = 1 To Len(Trim(strString))
                xStr = Mid(Trim(strString), i, 1)
                'response.write(i):response.end
                If xStr > 0 Then
                    Exit For
                End If

            Next
            DeleteZeroOfStr = Mid(Trim(strString), i)
        Else
            DeleteZeroOfStr = Trim(strString)
        End If
    End Function

    Public Shared Function AddZeroOfStr(ByVal strString, ByVal xLen)

        If IsNumericItem(Trim(strString)) Then
            Dim i As Integer
            For i = 1 To CInt(xLen)
                strString = "0" & strString
            Next
            AddZeroOfStr = strString
        Else
            AddZeroOfStr = Trim(strString)
        End If
    End Function

    Public Shared Function SONoBuildSAPFormat(ByVal xNumber)
        If IsNumericItem(xNumber) Then
            Dim i As Integer
            For i = 1 To 10 - Len(xNumber)
                xNumber = "0" & xNumber
            Next
            SONoBuildSAPFormat = xNumber
        Else
            SONoBuildSAPFormat = xNumber
        End If
    End Function

    Public Shared Function IsNumericItem_Expand(ByVal PartNO As String)
        If IsNumericItem(PartNO) Then
            Dim ZeroQty As Integer = 18 - PartNO.Length
            For i As Integer = 1 To ZeroQty
                PartNO = "0" & PartNO
            Next
        End If
        Return PartNO
    End Function

    Public Shared Function IsNumericItem_Shrink(ByVal PartNO As String)
        If IsNumericItem(PartNO) Then
            For i As Integer = 0 To PartNO.Length - 1
                If Not PartNO.Substring(i, 1).Equals("0") Then
                    PartNO = PartNO.Substring(i)
                    Exit For
                End If
            Next
        End If
        Return PartNO
    End Function

    'jackie add 04/24/2006 for execute multi-sql clause
    Public Shared Function ExecuteSqls(ByVal strSqls As System.Collections.Specialized.StringCollection)
        Dim g_adoConn As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
        'DBConn_Get("", "", g_adoConn)
        g_adoConn.Open()
        Dim dbCmd As New System.Data.SqlClient.SqlCommand
        'Dim myTrans As SqlTransaction = g_adoConn.BeginTransaction()
        Try
            dbCmd.Connection = g_adoConn
            'dbCmd.Transaction = myTrans
            For Each strSql As String In strSqls
                If Not Object.Equals(strSql, "") Then
                    dbCmd.CommandTimeout = 180
                    dbCmd.CommandText = strSql
                    dbCmd.ExecuteNonQuery()
                End If
            Next
            'myTrans.Commit()
        Catch ex As Exception
            '20060817 TC: Add rollback to avoid data non-integrity
            'myTrans.Rollback()
            'Response.Write("<Br/>" & ex.Message)
            'Response.End()
        End Try
        dbCmd.Dispose()
        g_adoConn.Close()
        g_adoConn.Dispose()

        Return 1
    End Function

    Public Shared Function ExecuteSqls( _
    ByVal ip As String, _
    ByVal DbName As String, _
    ByVal uid As String, _
    ByVal pwd As String, _
    ByVal strSqls As StringCollection)
        Dim g_adoConn As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
        g_adoConn.Open()
        Dim dbCmd As New System.Data.SqlClient.SqlCommand
        'Dim myTrans As SqlTransaction = g_adoConn.BeginTransaction()
        Try
            dbCmd.Connection = g_adoConn
            'dbCmd.Transaction = myTrans
            For Each strSql As String In strSqls
                If Not Object.Equals(strSql, "") Then
                    dbCmd.CommandTimeout = 180
                    dbCmd.CommandText = strSql
                    'If Session("user_id").ToString.ToLower.IndexOf("tc.chen") = 0 Or Session("user_id").ToString.ToLower.IndexOf("jackie.wu") = 0 Then
                    '    Response.Write(strSql + "<br/>")
                    'End If
                    dbCmd.ExecuteNonQuery()
                End If
            Next
            'myTrans.Commit()
        Catch ex As Exception
            '20060817 TC: Add rollback to avoid data non-integrity
            'myTrans.Rollback()
            'Response.Write("<Br/>" & ex.Message)
            'Response.End()
        End Try
        dbCmd.Dispose()
        g_adoConn.Close()
        g_adoConn.Dispose()

        Return 1
    End Function

    Public Shared Function RemoveZeroString(ByVal NumericPart_No As String) As String

        If IsNumericItem(NumericPart_No) Then
            For i As Integer = 0 To NumericPart_No.Length - 1
                If Not NumericPart_No.Substring(i, 1).Equals("0") Then
                    Return NumericPart_No.Substring(i)
                    Exit For
                End If
            Next
            Return NumericPart_No
        Else
            Return NumericPart_No
        End If

    End Function

    Public Shared Function Format2SAPItem(ByVal Part_No As String) As String

        Try
            If IsNumericItem(Part_No) And Not Part_No.Substring(0, 1).Equals("0") Then
                Dim zeroLength As Integer = 18 - Part_No.Length
                For i As Integer = 0 To zeroLength - 1
                    Part_No = "0" & Part_No
                Next
                Return Part_No
            Else
                Return Part_No
            End If
        Catch ex As Exception
            Return Part_No
        End Try

    End Function

    Public Shared Function Format2SAPItem2(ByVal Part_No As String) As String

        Try
            If IsNumericItem(Part_No) And Not Part_No.Substring(0, 1).Equals("0") Then
                Dim zeroLength As Integer = 10 - Part_No.Length
                For i As Integer = 0 To zeroLength - 1
                    Part_No = "0" & Part_No
                Next
                Return Part_No
            Else
                Return Part_No
            End If
        Catch ex As Exception
            Return Part_No
        End Try

    End Function

    Public Shared Function SAPDate2StdDate(ByVal sapDateString As String) As Date

        If sapDateString.Length <> 8 Then
            Exit Function
        End If
        Dim Y, M, D As String

        Try
            Y = Left(sapDateString, 4)
            M = Mid(sapDateString, 5, 2)
            D = Right(sapDateString, 2)
            Dim stdDate As Date = CDate(Y & "/" & M & "/" & D)
            Return stdDate
        Catch ex As Exception
            Exit Function
        End Try

    End Function

    Public Shared Function convertStr(ByRef obj)
        If InStr(obj, "'") > 0 Then
            obj = Replace(obj, "'", "''")
        End If
        Return 1
    End Function

    Public Shared Function IsNumericItem(ByVal part_no As String) As Boolean

        Dim pChar() As Char = part_no.ToCharArray()

        For i As Integer = 0 To pChar.Length - 1
            If Not IsNumeric(pChar(i)) Then
                Return False
                Exit Function
            End If
        Next

        Return True
    End Function

    '    AFR: EFRA008   *
    'AUK: EUKADV    *
    'AIT: EITW005, EITW005 *
    'ABN: EHLC001   * ENLA001
    'ADL: UUAAESC  *
    'APL: EPLA001
    'AESC: EHLA002  *
    Public Shared Function IsRBUSales(ByVal sales As String) As Boolean
        Return IsRBU(sales, "")
    End Function

    Public Shared Function stdDate2SAPDate(ByVal stdDate As Date) As String

        Dim strRetDate As String = ""
        strRetDate = stdDate.Year
        If stdDate.Month < 10 Then
            strRetDate &= "/0" & stdDate.Month
        Else
            strRetDate &= "/" & stdDate.Month
        End If
        If stdDate.Day < 10 Then
            strRetDate &= "/0" & stdDate.Day
        Else
            strRetDate &= "/" & stdDate.Day
        End If

        Return strRetDate

    End Function

    Public Shared Function GetCompanyForB2BGuest() As String
        Dim strSql As String = ""
        strSql = "Select Top 1 Company_Id from Company where Company_Type='partner' and Company_Id ='EDDEAA01'"
        Dim xDt As DataTable = dbUtil.dbGetDataTable("B2B", strSql)
        If xDt.Rows.Count > 0 Then
            Return xDt.Rows(0).Item("Company_Id").ToString
        Else
            Return ""
        End If
    End Function

    'Jackie add 2006/9/19
    Public Shared Sub FilterTable(ByVal ColumnName As String, ByRef dt As DataTable)
        If dt.Rows.Count <= 1 Then
            Exit Sub
        End If
        Dim i As Integer = 0
        While i < dt.Rows.Count - 1
            If dt.Rows.Count <= 1 Then
                Exit Sub
            End If
            If dt.Rows(i).Item(ColumnName) = dt.Rows(i + 1).Item(ColumnName) Then
                dt.Rows(i).Delete()
                dt.AcceptChanges()
            Else
                i += 1
            End If
        End While
    End Sub

    Public Shared Function GetRPL(ByVal CustomerId As String, ByVal xDate As Date) As String
        Dim dtRPL As DataTable = dbUtil.dbGetDataTable("B2B", "select top 30 convert(varchar(10),PKYear,111) as PKYear,Holiday from dbo.ShippingCalendarV2007 where " & _
        " plant='EUH1' and SalesOrg='EU10' and CustomerId='Default' and Holiday='N' and convert(smalldatetime,PKYear)>convert(smalldatetime,'" & _
                       xDate & "') order by PKYear asc")
        Dim RPL As String = FormatDate(DateAdd(DateInterval.Day, 30, DateTime.Today))
        If dtRPL.Rows.Count = 30 Then
            RPL = dtRPL.Rows(29).Item("PKYear")
        End If
        Dim dtSC As DataTable = dbUtil.dbGetDataTable("B2B", "select top 2 convert(varchar(10),PKYear,111) as PKYear,Holiday from dbo.ShippingCalendarV2007 where " & _
         " plant='EUH1' and SalesOrg='EU10' and CustomerId='" & CustomerId & "' and Holiday='N' and ShippingCalendarDay='Y' and convert(smalldatetime,PKYear)>=convert(smalldatetime,'" & _
                        CDate(RPL).ToString("yyyy/MM/dd") & "') order by PKYear asc")
        If dtSC.Rows.Count > 0 Then
            RPL = dtSC.Rows(0).Item("PKYear")
        End If
        Return RPL
    End Function


    Public Shared Function GetRPL(ByVal CustomerId As String, ByVal PartNo As String, ByVal xDate As Date) As String
        'if the planned delivery time and gr processing time are not maintained, we may do sth.
        Dim dtRPL As DataTable = dbUtil.dbGetDataTable("B2B", "select dateadd(day,(select top 1  " & _
            "(isnull(PLANNED_DEL_TIME,90) + isnull(GP_PROCESSING_TIME,1))" & _
            " as LeadTime from sap_product_abc where left(plant,2)='" + _
            Left(HttpContext.Current.Session("org_id"), 2) + "' and part_no='" & PartNo & "'),getdate())")
        Dim RPL As String = FormatDate(DateAdd(DateInterval.Day, 61, DateTime.Today))
        If Not IsNothing(dtRPL) And dtRPL.Rows.Count > 0 Then
            If Not IsDBNull(dtRPL.Rows(0).Item(0)) Then
                RPL = dtRPL.Rows(0).Item(0)
            End If
        End If

        Dim dtSC As DataTable = dbUtil.dbGetDataTable("B2B", "select top 2 convert(varchar(10),PKYear,111) as PKYear,Holiday from dbo.ShippingCalendarV2007 where " & _
         " plant='EUH1' and SalesOrg='EU10' and CustomerId='" & CustomerId & "' and Holiday='N' and ShippingCalendarDay='Y' and convert(smalldatetime,PKYear)>=convert(smalldatetime,'" & _
                       CDate(RPL).ToString("yyyy/MM/dd") & "') order by PKYear asc")
        '20071220 for Get Product's Lead Time : if have the shipping calendar 
        If Not IsNothing(dtSC) And dtSC.Rows.Count > 0 Then
            RPL = dtSC.Rows(0).Item("PKYear")
        Else
            dtSC = dbUtil.dbGetDataTable("B2B", "select top 2 convert(varchar(10),PKYear,111) as PKYear,Holiday from dbo.ShippingCalendarV2007 where " & _
            " plant='EUH1' and SalesOrg='EU10' and CustomerId='Default' and Holiday='N' and convert(smalldatetime,PKYear)>=convert(smalldatetime,'" & _
                       CDate(RPL).ToString("yyyy/MM/dd") & "') order by PKYear asc")
            If dtSC.Rows.Count > 0 Then
                RPL = dtSC.Rows(0).Item("PKYear")
            End If
        End If
        Return RPL
    End Function

    Shared Function ExecuteSqls(ByVal ConnectionName As String, ByVal strSqls As System.Collections.Specialized.StringCollection)
        Dim g_adoConn As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings(ConnectionName).ConnectionString)
        g_adoConn.Open()
        Dim dbCmd As New System.Data.SqlClient.SqlCommand
        Dim myTrans As SqlTransaction = g_adoConn.BeginTransaction()
        Try
            dbCmd.Connection = g_adoConn
            dbCmd.Transaction = myTrans
            For Each strSql As String In strSqls
                If Not Object.Equals(strSql, "") Then
                    dbCmd.CommandTimeout = 180
                    dbCmd.CommandText = strSql
                    dbCmd.ExecuteNonQuery()
                End If
            Next
            myTrans.Commit()
        Catch ex As Exception
            '20060817 TC: Add rollback to avoid data non-integrity
            myTrans.Rollback()
            Throw ex
            Return 0
        End Try
        dbCmd.Dispose()
        g_adoConn.Close()
        g_adoConn.Dispose()
        Return 1
    End Function

    Public Shared Function IsPTradeProduct(ByVal xPartNo As String) As Boolean
        Dim xIsPTrade As Boolean = False
        Dim xQuery As String = "SELECT Distinct Part_no,Product_Type FROM dbo.Product Where Part_no = '" & xPartNo & "' AND Product_Type = 'ZPER' "
        Dim xDT As DataTable = dbUtil.dbGetDataTable("B2B", xQuery)
        If xDT.Rows.Count > 0 Then
            xIsPTrade = True
        End If
        Return xIsPTrade
    End Function

    Public Shared Function IsSparePartProduct(ByVal xPartNo As String) As Boolean
        Dim xIsSparePart As Boolean = False
        Dim xQuery As String = "SELECT Distinct Part_no,Material_Group FROM dbo.Product Where Part_no = '" & xPartNo & "' AND Material_Group <= '968a' "
        Dim xDT As DataTable = dbUtil.dbGetDataTable("B2B", xQuery)
        If xDT.Rows.Count > 0 Then
            xIsSparePart = True
        End If
        Return xIsSparePart
    End Function

    Public Shared Function IgnoreSign(ByVal str) As String
        str = Replace(str, "%", "")
        str = Replace(str, "&euro;", "")
        str = Replace(str, "NT", "")
        str = Replace(str, "US$", "")
        str = Replace(str, "&yen;", "")
        str = Replace(str, "&pound;", "")
        Return str
    End Function

    Shared Function getHTTPDATA(ByVal URL As String) As String
        Dim sException As String = ""
        Dim sRslt As String = ""
        Dim oWebRps As System.Net.WebResponse = Nothing
        Dim oWebRqst As System.Net.WebRequest = System.Net.WebRequest.Create(URL)
        oWebRqst.Timeout = 50000
        Try
            oWebRps = oWebRqst.GetResponse()

        Catch ex As System.Net.WebException
            sException = ex.Message.ToString()
            HttpContext.Current.Response.Write(sException)
        Catch ex As Exception
            sException = ex.ToString()
            HttpContext.Current.Response.Write(sException)
        Finally
            If Not oWebRps Is Nothing Then
                Dim oStreamRd As New System.IO.StreamReader(oWebRps.GetResponseStream(), Encoding.GetEncoding("UTF-8"))
                sRslt = oStreamRd.ReadToEnd()
                oStreamRd.Close()
                oWebRps.Close()
            End If
        End Try
        Return sRslt
    End Function
    Shared Function HtmlStrToXML(ByVal MyString As String, ByRef XMLDOC As System.Xml.XmlDocument, ByVal elementName As String) As String

        Dim mysgmlReader As New SgmlReader
        Dim strWriter As New StringWriter()
        Dim xmlWriter As New XmlTextWriter(strWriter)
        Try

            mysgmlReader.DocType = elementName
            mysgmlReader.InputStream = New System.IO.StringReader(MyString)

            xmlWriter.Formatting = Formatting.Indented
            While mysgmlReader.Read()
                If mysgmlReader.NodeType <> XmlNodeType.Whitespace Then
                    xmlWriter.WriteNode(mysgmlReader, True)
                End If
            End While
            XMLDOC.LoadXml(strWriter.ToString)

        Catch EX As Exception

            Return "E:" & EX.ToString
        End Try
        Return "S"
    End Function
    Shared Function HtmlToXML(ByVal URL As String, ByRef XMLDOC As System.Xml.XmlDocument) As String
        Dim HtmlWriter As New StringWriter()
        Dim HtmlPage As String = ""
        Dim mysgmlReader As New SgmlReader
        Dim strWriter As New StringWriter()
        Dim xmlWriter As New XmlTextWriter(strWriter)
        Try
            HttpContext.Current.Server.Execute(URL, HtmlWriter)
            HtmlPage = HtmlWriter.ToString
            mysgmlReader.DocType = "HTML"
            mysgmlReader.InputStream = New System.IO.StringReader(HtmlPage)

            xmlWriter.Formatting = Formatting.Indented
            While mysgmlReader.Read()
                If mysgmlReader.NodeType <> XmlNodeType.Whitespace Then
                    xmlWriter.WriteNode(mysgmlReader, True)
                End If
            End While
            XMLDOC.LoadXml(strWriter.ToString)

        Catch EX As Exception

            Return "E:" & EX.ToString
        End Try
        Return "S"
    End Function
    Shared Function getXmlBlockByID(ByVal TYPE As String, ByVal ID As String, _
                                    ByVal XMLDOC As System.Xml.XmlDocument, ByRef retXMLBlock As String) As String
        Try
            Dim root As XmlNodeList = XMLDOC.DocumentElement.GetElementsByTagName(TYPE.ToLower)
            For Each x As XmlNode In root
                Dim ex As XmlElement = CType(x, XmlElement)
                If ex.Attributes("id") IsNot Nothing AndAlso ex.Attributes("id").Value.ToLower = ID.ToLower Then
                    retXMLBlock = x.OuterXml.ToString
                End If
            Next
            Return "S"
        Catch EX As Exception
            Return "E:" & EX.ToString
        End Try
    End Function

    Shared Function Datatable2excel(ByVal DT As DataTable)
        HttpContext.Current.Response.Clear()
        HttpContext.Current.Response.ContentType = "application/vnd.ms-excel"
        HttpContext.Current.Response.Charset = "utf-8"

        Dim oStringWriter As System.IO.StringWriter = New System.IO.StringWriter()
        Dim oHtmlTextWriter As System.Web.UI.HtmlTextWriter = New System.Web.UI.HtmlTextWriter(oStringWriter)

        Dim oDtGrid As New DataGrid
        oDtGrid.DataSource = DT
        oDtGrid.DataBind()

        oDtGrid.RenderControl(oHtmlTextWriter)
        HttpContext.Current.Response.Write(oStringWriter.ToString())
        HttpContext.Current.Response.End()
    End Function

    Shared Function getControl_Html(ByVal oControl As Control)
        Dim sw As StringWriter = New StringWriter()
        Dim writer As HtmlTextWriter = New HtmlTextWriter(sw)
        oControl.RenderControl(writer)
        Dim str As String = sw.ToString
        writer.Close()
        sw.Close()
        Return str
    End Function

End Class
