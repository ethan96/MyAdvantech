Imports Microsoft.VisualBasic
Imports System.IO
Imports System.Data
Imports SAP.Connector
Imports System.Globalization
Imports System.Runtime.CompilerServices
Imports System.Text.RegularExpressions
Imports System.Web

Public Class Util

    Public Shared Function ELearingUrl() As String
        'Andrew 2015/9/17 modify Learning Passport url
        Dim user_id As String = HttpContext.Current.Session("user_id")
        Dim TempId As String = HttpContext.Current.Session("TempId")
        Return String.Format("http://elearning.advantech.com.tw/Training.aspx?id={0}&tempid={1}", user_id, TempId)
    End Function

    Public Shared Function ListToDataTable(Of T)(data As IList(Of T)) As DataTable
        Dim properties As ComponentModel.PropertyDescriptorCollection = ComponentModel.TypeDescriptor.GetProperties(GetType(T))
        Dim table As New DataTable()
        For Each prop As ComponentModel.PropertyDescriptor In properties
            table.Columns.Add(prop.Name, If(Nullable.GetUnderlyingType(prop.PropertyType), prop.PropertyType))
        Next
        For Each item As T In data
            Dim row As DataRow = table.NewRow()
            For Each prop As ComponentModel.PropertyDescriptor In properties
                row(prop.Name) = If(prop.GetValue(item), DBNull.Value)
            Next
            table.Rows.Add(row)
        Next
        Return table

    End Function

    Public Shared Function DataTableToList(Of T As New)(table As DataTable) As IList(Of T)
        Dim properties As IList(Of Reflection.PropertyInfo) = GetType(T).GetProperties().ToList()
        Dim result As IList(Of T) = New List(Of T)()

        '取得DataTable所有的row data
        For Each row In table.Rows
            Dim item = MappingItem(Of T)(DirectCast(row, DataRow), properties)
            result.Add(item)
        Next

        Return result
    End Function

    Private Shared Function MappingItem(Of T As New)(row As DataRow, properties As IList(Of Reflection.PropertyInfo)) As T
        Dim item As New T()
        For Each [property] In properties
            If row.Table.Columns.Contains([property].Name) Then
                '針對欄位的型態去轉換
                If [property].PropertyType = GetType(DateTime) Then
                    Dim dt As New DateTime()
                    If DateTime.TryParse(row([property].Name).ToString(), dt) Then
                        [property].SetValue(item, dt, Nothing)
                    Else
                        [property].SetValue(item, Nothing, Nothing)
                    End If
                ElseIf [property].PropertyType = GetType(Decimal) Then
                    Dim val As New Decimal()
                    Decimal.TryParse(row([property].Name).ToString(), val)
                    [property].SetValue(item, val, Nothing)
                ElseIf [property].PropertyType = GetType(Double) Then
                    Dim val As New Double()
                    Double.TryParse(row([property].Name).ToString(), val)
                    [property].SetValue(item, val, Nothing)
                ElseIf [property].PropertyType = GetType(Integer) Then
                    Dim val As New Integer()
                    Integer.TryParse(row([property].Name).ToString(), val)
                    [property].SetValue(item, val, Nothing)
                Else
                    If row([property].Name) IsNot DBNull.Value Then
                        [property].SetValue(item, row([property].Name), Nothing)
                        'Try

                        'Catch ex As Exception
                        '    HttpContext.Current.Response.Write("[property].Name:" + [property].Name)
                        '    HttpContext.Current.Response.End()
                        'End Try

                    End If
                End If
            End If
        Next
        Return item
    End Function
    Public Shared Function GetCurrencySignByCurrency(ByVal _Currency As String) As String
        Select Case UCase(_Currency)
            Case "NT", "TWD"
                Return "NT"
            Case "US", "USD"
                Return "$"
            Case "EUR"
                Return "&euro;"
            Case "YEN", "JPY", "RMB", "CNY"
                Return "&yen;"
            Case "GBP"
                Return "&pound;"
            Case "AUD"
                Return "AUD"
            Case "SGD"
                Return "SGD"
            Case "MYR"
                Return "RM"
                'Case Else
                '    Return "&euro;"
        End Select
        If HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") IsNot Nothing Then
            Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN")
        End If
        Return ""
    End Function
    Public Shared Function RemovePrecedingZeros(ByVal str As String) As String
        If Not str.StartsWith("0") Then Return str
        If str.Length > 1 Then
            Return RemovePrecedingZeros(str.Substring(1))
        Else
            Return str
        End If
    End Function

    Public Shared Function FormatToSAPPartNo(ByVal str As String) As String
        If Not Decimal.TryParse(str, 0) Then Return str
        While str.Length < 18
            str = "0" + str
        End While
        Return str
    End Function

    Public Shared Function DataTableToJSON(table As DataTable) As String
        Dim list As New List(Of Dictionary(Of String, Object))()

        For Each row As DataRow In table.Rows
            Dim dict As New Dictionary(Of String, Object)()

            For Each col As DataColumn In table.Columns
                dict(col.ColumnName) = row(col)
            Next
            list.Add(dict)
        Next
        Dim serializer As New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(list)
    End Function

    Public Shared Function IsMexicoT2Customer(ByVal CompanyID As String, ByRef ParentCompany As String) As Boolean
        If CompanyID.Trim.StartsWith("MXT2", StringComparison.CurrentCultureIgnoreCase) Then
            ParentCompany = "UUMM001"
            Return True
        End If
        Return False
    End Function
    Public Shared Function IsCJK(ByVal str As String) As Boolean
        If str.Length = 0 Then Return False
        Try
            Return ContainsChinese(str) Or ContainsJapanese(str) Or ContainsKorea(str)
        Catch ex As Exception
            Return False
        End Try
    End Function

    Public Shared Function ContainsChinese(ByVal str As String) As Boolean
        If str = "" Then Return False
        Dim index As Integer = 0
        Dim num2 As Integer = 0
        Do
            num2 = Char.ConvertToUtf32(str, index)
            If ((num2 >= CLng("&H4E00")) And (num2 <= CLng("&H9FFF"))) Then
                Return True
            End If
            index += 1
        Loop While (index < str.Length)
        Return False
    End Function


    Public Shared Function ContainsJapanese(ByVal str As String) As Boolean
        If str = "" Then Return False
        Dim index As Integer = 0
        Dim num2 As Integer = 0
        Do
            num2 = Char.ConvertToUtf32(str, index)
            If ((num2 >= CLng("&H0100")) And (num2 <= CLng("&HFFFF"))) Then
                Return True
            End If
            index += 1
        Loop While (index < str.Length)
        Return False
    End Function

    Public Shared Function ContainsKorea(ByVal str As String) As Boolean
        If str = "" Then Return False
        Dim index As Integer = 0
        Dim num2 As Integer = 0
        Do
            num2 = Char.ConvertToUtf32(str, index)
            If (Not ((num2 >= CLng("&H1100")) And (num2 <= CLng("&H11FF"))) AndAlso Not ((num2 >= CLng("&H3130")) And (num2 <= CLng("&H318F")))) Then
            End If
            If (IIf(((num2 >= CLng("&HAC00")) And (num2 <= CLng("&HD7AF"))), 1, 0) <> 0) Then
                Return True
            End If
            index += 1
        Loop While (index < str.Length)
        Return False
    End Function


    Public Shared Function IsTesting() As Boolean
        'If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
        '    OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False
        'Dim uid As String = HttpContext.Current.Session("user_id").ToString().ToLower()
        'Dim TestList As New ArrayList
        'With TestList
        '    '.Add("tc.chen@advantech.com.tw")
        '    .Add("ming.zhao@advantech.com.cn")
        '    .Add("frank.chung@advantech.com.tw")
        'End With
        'If TestList.Contains(uid) Then
        '    Return True
        'End If
        With HttpContext.Current
            If .Request.ServerVariables("SERVER_PORT") = "4002" Then
                Return True
            End If
        End With
        Return False
    End Function
    Public Shared Function IsTestingQuote2Order() As Boolean
        Return True
        With HttpContext.Current
            'If .Request.ServerVariables("SERVER_PORT") = "4002" Then
            '    Return True
            'End If
            If .Session("Quote2_5") IsNot Nothing Then
                Dim _IsQuote2_5 As Boolean = CType(.Session("Quote2_5"), Boolean)
                Return _IsQuote2_5
            End If
            If .Session("COMPANY_ID") IsNot Nothing Then
                If String.Equals(.Session("COMPANY_ID"), "UZISCHE01", StringComparison.CurrentCultureIgnoreCase) Then
                    Return True
                End If
            End If
        End With
        Return False
    End Function


    Public Shared Function GetLocalTime(ByVal org As String, ByVal ServerTime As DateTime) As DateTime
        If DateTime.TryParse(ServerTime, DateTime.Now) = False Then Return DateTime.Now
        org = org.ToUpper.Trim
        Dim utcTime As DateTime = DateTime.Now.ToUniversalTime()
        Dim Org2Timezone As Dictionary(Of String, String) = CType(HttpContext.Current.Cache("Org2Timezone"), Dictionary(Of String, String))
        If Org2Timezone Is Nothing Then
            Org2Timezone = New Dictionary(Of String, String)
            HttpContext.Current.Cache.Add("Org2Timezone", Org2Timezone, Nothing, DateTime.Now.AddHours(8), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        If Not Org2Timezone.ContainsKey(org) Then
            Dim timezone As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(timezonename,'') as timezonename from TIMEZONE where org like '%{0}'", org))
            If timezone IsNot Nothing AndAlso Not String.IsNullOrEmpty(timezone) Then
                Org2Timezone.Add(org, timezone.ToString)
            End If
        End If
        If Not String.IsNullOrEmpty(Org2Timezone.Item(org)) Then
            Dim TZ_Local As TimeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(Org2Timezone.Item(org))
            Dim TZI_Tw As TimeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById("Taipei Standard Time")
            Dim TimeDifference As TimeSpan = TZ_Local.GetUtcOffset(utcTime) - TZI_Tw.GetUtcOffset(utcTime)
            Return ServerTime.Add(TimeDifference)
        End If
        Return DateTime.Now
    End Function


    'Public Shared Function GetTimeSpan(ByVal org As String) As TimeSpan

    '    Dim utcTime As DateTime = DateTime.Now.ToUniversalTime()
    '    Dim timezone As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(timezonename,'') as timezonename from TIMEZONE where org like '%{0}'", org))
    '    If timezone IsNot Nothing AndAlso Not String.IsNullOrEmpty(timezone) Then
    '        Dim TZI As TimeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(timezone)
    '        Return TZI.GetUtcOffset(utcTime)
    '    End If

    '    Return Nothing
    'End Function

    'Public Shared Function TransferToLocalTime(ByVal _ts As TimeSpan, ByVal OriDate As DateTime) As DateTime
    '    OriDate = OriDate.Add(_ts)
    '    Return OriDate
    'End Function

    ''' <summary>
    ''' This function was moved from B2BACL
    ''' </summary>
    ''' <param name="szSite_Parameter"></param>
    ''' <param name="szPara_Value"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetSiteDefinition(ByVal szSite_Parameter As String, ByRef szPara_Value As String) As String

        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
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

    Public Shared Sub FillANAPITemplaeProductInventory(ByRef DT As MyOrderDS.ORDER_DETAILDataTable)

        Dim prod_input As New SAPDAL.SAPDALDS.ProductInDataTable, _sapdal As New SAPDAL.SAPDAL
        Dim _deliveryPlant As String = "USH1", _errormsg As String = String.Empty
        Dim inventory_out As New SAPDAL.SAPDALDS.QueryInventory_OutputDataTable

        'Add inventory column
        DT.Columns.Add(New DataColumn("inventory", GetType(System.Int16)))

        'Reading partno and require qty, fill into product in table
        For Each _row As MyOrderDS.ORDER_DETAILRow In DT.Rows
            If String.IsNullOrEmpty(_row.PART_NO) Then Continue For
            If _row.LINE_NO >= 100 And _row.LINE_NO Mod 100 = 0 Then Continue For
            prod_input.AddProductInRow(_row.PART_NO, _row.QTY, _row.DeliveryPlant)
        Next
        'Getting real time inventory
        _sapdal.QueryInventory_V2(prod_input, _deliveryPlant, Now, inventory_out, _errormsg)
        If inventory_out IsNot Nothing AndAlso inventory_out.Rows.Count > 0 Then
            Dim _foundrow() As DataRow = Nothing, _STOCK_DATE As String = String.Empty, _STOCK_DATE_NEXTHOLIDAY As String = String.Empty, _code As String = "TW"
            For Each _row As MyOrderDS.ORDER_DETAILRow In DT.Rows
                If String.IsNullOrEmpty(_row.PART_NO) Then Continue For
                _foundrow = inventory_out.Select("PART_NO='" & _row.PART_NO & "'")
                If _foundrow.Length > 0 Then
                    'update inventory and duedate by quoteid and line no
                    'myQD.UpdateProductAvaiableInfoByLineNo(_foundrow(0).Item("STOCK"), CDate(_foundrow(0).Item("STOCK_DATE")), _QuoteId, _row.Item("line_No"))
                    If Not _STOCK_DATE.Equals(CDate(_foundrow(0).Item("STOCK_DATE")).ToString("yyyy-MM-dd"), StringComparison.InvariantCultureIgnoreCase) Then
                        _STOCK_DATE = CDate(_foundrow(0).Item("STOCK_DATE")).ToString("yyyy-MM-dd")
                        _STOCK_DATE_NEXTHOLIDAY = _STOCK_DATE
                        'Maybe need to chahge _code by...?  in the future
                        SAPDAL.SAPDAL.Get_Next_WorkingDate_ByCode(_STOCK_DATE_NEXTHOLIDAY, 0, _code)
                    End If
                    _row.Item("inventory") = _foundrow(0).Item("STOCK")
                    'myQD.UpdateProductAvaiableInfoByLineNo(_foundrow(0).Item("STOCK"), _STOCK_DATE_NEXTHOLIDAY, _QuoteId, _row.Item("line_No"))
                Else
                    'If inventory can not be found
                    _row.Item("inventory") = 0
                End If
            Next
        End If

        'If _IsBTOS Then myQD.UpdateBTOSMainItemDueDate(_QuoteId)

    End Sub

    'Public Shared Function GetSalesRepresentativeByEmployeeID(ByVal employeeID As String, ByVal orderCreatorEmail As String) As String

    '    Dim _SalesPerson As String = String.Empty, _dt As DataTable = Nothing

    '    If Not String.IsNullOrEmpty(employeeID) Then

    '        _dt = dbUtil.dbGetDataTable("MY", String.Format("Select FULL_NAME,FIRST_NAME,LAST_NAME from SAP_EMPLOYEE where SALES_CODE='{0}'", employeeID))

    '        If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
    '            _SalesPerson = _dt.Rows(0).Item("FULL_NAME").ToString
    '            If String.IsNullOrEmpty(_SalesPerson) Then _SalesPerson = _dt.Rows(0).Item("FIRST_NAME") + " " + _dt.Rows(0).Item("LAST_NAME")
    '        End If

    '    End If

    '    If String.IsNullOrEmpty(_SalesPerson) Then
    '        'Get name from Siebel:This logic copy from eQuotation Util.GetSalesRepresentative

    '        Dim firstname As String = "", lastname As String = ""
    '        Util.GetInternalNamebyADAndSiebel(orderCreatorEmail, lastname, firstname)
    '        If lastname = "" AndAlso firstname = "" Then
    '            Dim email_name As String = orderCreatorEmail.ToString.Split("@")(0)
    '            If email_name.Contains(".") Then
    '                For Each name As String In email_name.Split(".")
    '                    _SalesPerson += name.Substring(0, 1).ToUpper() + name.Substring(1, name.Length - 1).ToLower + " "
    '                Next
    '            Else
    '                _SalesPerson += email_name.Substring(0, 1).ToUpper() + email_name.Substring(1, email_name.Length - 1).ToLower
    '            End If
    '        Else
    '            _SalesPerson += firstname + " " + lastname
    '        End If


    '    End If


    '    Return _SalesPerson

    'End Function


    Public Shared Sub GetInternalNamebyADAndSiebel(ByVal email As String, ByRef last_name As String, ByRef first_name As String)

        'Dim sql As String = String.Format("select isnull(b.firstname,'') as firstname, isnull(b.lastname,'') as lastname from ADVANTECH_ADDRESSBOOK b inner join ADVANTECH_ADDRESSBOOK_ALIAS a on a.ID=b.ID where a.Email ='{0}' or b.PrimarySmtpAddress ='{0}' ", email)
        Dim sql As String = String.Format("select isnull(b.firstname,'') as firstname, isnull(b.lastname,'') as lastname from AD_MEMBER b inner join AD_MEMBER_ALIAS a on a.EMAIL=b.PrimarySmtpAddress where a.ALIAS_EMAIL ='{0}' or b.PrimarySmtpAddress ='{0}' ", email)

        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        If dt.Rows.Count > 0 Then
            first_name = dt.Rows(0).Item("firstname").ToString : last_name = dt.Rows(0).Item("lastname").ToString
        End If
        If String.IsNullOrEmpty(first_name) AndAlso String.IsNullOrEmpty(last_name) Then
            sql = String.Format("select isnull(firstname,'') as firstname, isnull(lastname,'') as lastname from SIEBEL_CONTACT where EMAIL_ADDRESS='{0}' ", email)
            dt = dbUtil.dbGetDataTable("MY", sql)
            If dt.Rows.Count > 0 Then
                first_name = dt.Rows(0).Item("firstname").ToString : last_name = dt.Rows(0).Item("lastname").ToString
            End If
        End If
    End Sub

    Public Shared Function GetPositionNameBySalesCode(ByVal SalesCode As String, ByRef PositionName As String) As Boolean
        Dim email As String = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(EMAIL,'') as email  from dbo.SAP_EMPLOYEE where SALES_CODE ='{0}'", SalesCode)).ToString.Trim
        If String.IsNullOrEmpty(email) Then Return False
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY",
            "select top 1 PRIMARY_POSITION_NAME from SIEBEL_POSITION " +
            " where EMAIL_ADDR='" + email + "' and PRIMARY_POSITION_NAME is not null order by PRIMARY_FLG desc")
        If dt.Rows.Count = 1 Then
            PositionName = dt.Rows(0).Item("PRIMARY_POSITION_NAME") : Return True
        End If
        Return False
    End Function
    Public Shared Function GetRBUBySalesCode(ByVal SalesCode As String, ByRef RBU As String) As Boolean
        Dim email As String = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(EMAIL,'') as email  from dbo.SAP_EMPLOYEE where SALES_CODE ='{0}'", SalesCode)).ToString.Trim
        If String.IsNullOrEmpty(email) OrElse Not Util.IsValidEmailFormat(email) Then Return False
        Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", _
            "select top 1 c.NAME from S_USER a inner join S_CONTACT b on a.ROW_ID=b.ROW_ID inner join S_PARTY c on b.BU_ID=c.ROW_ID  " + _
            " where upper(b.EMAIL_ADDR)=upper('" + email + "')")
        If dt.Rows.Count = 1 Then
            RBU = dt.Rows(0).Item("NAME") : Return True
        End If
        Return False
    End Function
    ''' <summary>
    ''' Get Sentences By Keyword
    ''' </summary>
    ''' <param name="_text">Text</param>
    ''' <param name="_keyword">Key words</param>
    ''' <param name="_MaxLength">Sentence maxlength</param>
    ''' <param name="_CutLength">cut length of sentence, if sentence is more then _MaxLength</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetSentenceByKeyword(ByVal _text As String, ByVal _keyword() As String, ByVal _MaxLength As Integer, ByVal _CutLength As Integer) As String

        If _keyword Is Nothing OrElse _keyword.Length = 0 Then Return _text

        Dim _allkeyword As String = String.Empty

        For Each _item As String In _keyword
            _allkeyword &= _item & "|"
        Next
        _allkeyword = _allkeyword.TrimEnd("|")

        Dim _oritext As String = _text
        'Cut text into several sentences.
        Dim expression As String = "(\S.+?[.!?;。])(?=\s+|$)"

        'Dim _text As String = Me.TextBox_RegexExpressionInput.Text
        'replace <br> and newline to . 
        _text = Regex.Replace(_text, "<br.*?>", " . ", RegexOptions.IgnoreCase Or RegexOptions.Singleline)
        _text = Regex.Replace(_text, vbNewLine, " . ", RegexOptions.IgnoreCase Or RegexOptions.Singleline)


        Dim wordMatch As Regex = New Regex(expression, RegexOptions.IgnoreCase Or RegexOptions.Singleline)
        Dim subwordMatch As Regex = Nothing
        Dim _ReturnStr As String = String.Empty
        Dim _linesplitstring As String = "..."

        'cut sentence by _cutlength regular expression
        'Dim _maxlengthexpression As String = "((^.{0,30}|\w*.{30})\b(" + _allkeyword + ")\b(.{30}\w*|.{0,30}$))"
        Dim _maxlengthexpression As String = "((^.{0," & _CutLength & "}|\w*.{" & _CutLength & "})(" + _allkeyword + ")(.{" & _CutLength & "}\w*|.{0," & _CutLength & "}$))"


        For Each m As Match In wordMatch.Matches(_text)

            Dim b = Regex.Match(m.Value, _allkeyword, RegexOptions.IgnoreCase).Index

            If Regex.Match(m.Value, _allkeyword, RegexOptions.IgnoreCase).Success Then

                'If Sentence length is bigger the _maxlength then cut the sentence by _cutlength
                If m.Value.Length > _MaxLength Then

                    'subwordMatch = New Regex(_maxlengthexpression, RegexOptions.IgnoreCase Or RegexOptions.Singleline)
                    subwordMatch = New Regex(_maxlengthexpression, RegexOptions.IgnoreCase)

                    'A sentence may have more than 2 keywords therefore cut those sub sentence     
                    For Each mm As Match In subwordMatch.Matches(m.Value)
                        _ReturnStr &= mm.Value & _linesplitstring
                    Next

                Else
                    _ReturnStr &= m.Value & _linesplitstring
                End If

            End If

        Next

        If Not String.IsNullOrEmpty(_ReturnStr) Then
            Return _ReturnStr
        Else
            Return _oritext
        End If


    End Function

    Public Shared Function ReplaceSQLStringFunc(ByVal szMyString As String) As String

        szMyString = Replace(szMyString, """", "_")
        szMyString = Replace(szMyString, "'", "''")
        szMyString = Replace(szMyString, "/", "_")
        szMyString = Replace(szMyString, "\", "_")
        szMyString = Replace(szMyString, "&", " and ")

        Return szMyString

    End Function

    Public Shared Function GET_CurrSign_By_Curr(ByVal Curr As String) As String
        Select Case UCase(Curr)
            Case "TWD"
                Return "TWD"
            Case "NT"
                Return "NT"
            Case "US", "USD"
                Return "$"
            Case "EUR"
                Return "&euro;"
            Case "CNY", "RMB"
                Return "&yen;"
            Case "YEN", "JPY"
                Return "J.&yen;"
            Case "GBP"
                Return "&pound;"
            Case "AUD"
                Return "AUD"
            Case Else
                Return "$"
        End Select
    End Function

    Public Shared Function SaveString2File(ByVal strText As String, ByVal strPath As String, ByVal strFileName As String) As Integer
        Dim obj_FSO As System.IO.FileInfo = New System.IO.FileInfo(strPath & strFileName)
        Dim objFStrm As System.IO.StreamWriter
        objFStrm = obj_FSO.CreateText()
        objFStrm.WriteLine(strText)
        objFStrm.Close()
        Return 1
    End Function

    'Public Shared Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
    '    Dim RegExp As New Regex(Search_Str.Replace(" ", "|").Trim(), RegexOptions.IgnoreCase)
    '    Return RegExp.Replace(InputTxt, New MatchEvaluator(AddressOf ReplaceKeyWords))
    '    RegExp = Nothing
    'End Function

    Public Shared Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
        'Frank 2012/08/07 if Input text is null,empty then just return ""
        If InputTxt = String.Empty OrElse InputTxt.Trim = "" Then Return ""

        If Search_Str <> String.Empty AndAlso Search_Str.Trim <> "" AndAlso Search_Str <> "*" Then

            'Frank 2012/04/26:Fixed error Quantifier {x,y} following nothing.
            'Search_Str = Replace(Search_Str, "*", "{0,}")
            Search_Str = Replace(Search_Str, "*", " ").Replace("\r", " ").Replace("\n", " ").Replace("(", "").Replace(")", "")
            InputTxt = Replace(InputTxt, "*", " ").Replace("\r", " ").Replace("\n", " ").Replace("(", "").Replace(")", "")
            Try
                Dim RegExp As New Regex(Search_Str.Replace(" ", "|").Trim(), RegexOptions.IgnoreCase)
                Return RegExp.Replace(InputTxt, New MatchEvaluator(AddressOf ReplaceKeyWords))
                RegExp = Nothing
            Catch ex As System.ArgumentException
                Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
                sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", HttpUtility.HtmlEncode("Highlight error for search:" + Search_Str + ". inputTxt:" + InputTxt), ex.ToString())
            End Try
        End If
        Return InputTxt
    End Function

    Public Shared Function ReplaceKeyWords(ByVal m As Match) As String
        Return "<span style='background-color:Yellow'>" + m.Value + "</span>"
    End Function

    Public Shared Function GetClientIP() As String
        Dim _ip As String = HttpContext.Current.Request.ServerVariables("HTTP_X_FORWARDED_FOR")
        If _ip = "" OrElse _ip.ToLower = "unknown" Then
            _ip = HttpContext.Current.Request.ServerVariables("REMOTE_ADDR")
        End If
        Return _ip
    End Function

    Public Shared Function IP2Nation() As String
        Try
            Dim ws As New eStore_WS.eStoreWebService
            ws.UseDefaultCredentials = True : ws.Timeout = -1
            Return ws.IP2Nation(Util.GetClientIP())
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString)
            Return "N/A"
        End Try
    End Function

    Public Shared Function GetTollNumber() As String
        If HttpContext.Current.Session("Toll_Number") Is Nothing Then
            Dim na As String = ""
            If HttpContext.Current.Session("user_id") Is Nothing Then
                na = IP2Nation()
            Else
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(b.country,'') as country from SIEBEL_CONTACT a left join SIEBEL_ACCOUNT b on a.ACCOUNT_ROW_ID=b.ROW_ID where a.EMAIL_ADDRESS='{0}' and b.country <> '' and b.country is not null", HttpContext.Current.Session("user_id")))
                If obj IsNot Nothing Then
                    na = obj.ToString
                Else
                    na = IP2Nation()
                End If
            End If

            Dim advws As New ADVWWW.AdvantechWebService
            advws.UseDefaultCredentials = True : advws.Timeout = -1
            Dim ds As New DataSet

            '加入cache機制：時間設在cache住10分鐘
            If HttpContext.Current.Cache(na) IsNot Nothing Then
                ds = CType(HttpContext.Current.Cache(na), DataSet)
            Else
                Try
                    ds = advws.getRBUInfoByCountryBU(na, "eP")
                    HttpContext.Current.Cache.Insert(na, ds, Nothing, DateTime.Now.AddMinutes(10), Cache.NoSlidingExpiration)
                Catch ex As System.Exception
                    Try
                        '加入cache機制：時間設在cache住10分鐘
                        If HttpContext.Current.Cache(na) IsNot Nothing Then
                            ds = CType(HttpContext.Current.Cache(na), DataSet)
                        Else
                            ds = advws.getRBUInfoByCountryBU(na, "eP")
                            HttpContext.Current.Cache.Insert(na, ds, Nothing, DateTime.Now.AddMinutes(10), Cache.NoSlidingExpiration)
                        End If
                    Catch ex1 As System.Exception
                        Util.InsertMyErrLog(ex1.ToString)
                        HttpContext.Current.Session("Toll_Number") = "1-888-576-9668"
                        Return HttpContext.Current.Session("Toll_Number")
                    End Try
                End Try
            End If

            If ds.Tables.Count > 0 Then
                If ds.Tables(0).Rows.Count > 0 Then
                    HttpContext.Current.Session("Toll_Number") = ds.Tables(0).Rows(0).Item("toll_free").ToString
                Else
                    HttpContext.Current.Session("Toll_Number") = "1-888-576-9668"
                End If
            Else
                HttpContext.Current.Session("Toll_Number") = "1-888-576-9668"
            End If
        End If
        Return HttpContext.Current.Session("Toll_Number")
    End Function

    Public Shared Function DateOnly(ByVal strDate As String) As String
        If Date.TryParse(strDate, Now) Then
            Return CDate(strDate).ToString("yyyy/MM/dd")
        End If
        Return strDate
    End Function

    Public Shared Function TrimPhone(ByVal phone As String) As String
        Dim p() As String = Split(phone, vbLf)
        If p.Length > 0 Then Return p(0)
        Return phone
    End Function

    Public Shared Function InitSPRDataSet(ByRef endContactDt As DataTable, ByRef copContactDt As DataTable) As DataSet
        Dim ds As New DataSet("SPR")
        Dim dt1 As New DataTable("EndCustInfo")
        endContactDt = New DataTable("EndContacts")
        Dim dt2 As New DataTable("PrjInfo")
        Dim dt3 As New DataTable("CopInfo")
        copContactDt = New DataTable("CopContacts")
        Dim dt4 As New DataTable("ProdInfo")
        With dt1.Columns
            .Add("ROW_ID") : .Add("Company_Name") : .Add("Post_Code") : .Add("State") : .Add("Address") : .Add("Country")
            .Add("Contacts", GetType(DataTable))
        End With
        With endContactDt.Columns
            .Add("Last_Name") : .Add("First_Name") : .Add("Email") : .Add("Telephone")
        End With
        With dt2.Columns
            .Add("Project_Name") : .Add("Project_Description") : .Add("SPR_Reason") : .Add("Close_Date", GetType(Date)) : .Add("Total_Amount")
        End With
        With dt3.Columns
            .Add("Remarks") : .Add("Contacts", GetType(DataTable))
        End With
        With copContactDt.Columns
            .Add("Company_Name") : .Add("Model_No") : .Add("Selling_Price")
        End With
        With dt4.Columns
            .Add("Model_No") : .Add("Qty", GetType(Integer)) : .Add("End_Customer_Price", GetType(Double))
            .Add("Special_Price_Request", GetType(Double)) : .Add("CP_Price", GetType(Double)) : .Add("Advantech_Confirmed_Price", GetType(Double))
        End With
        ds.Tables.Add(dt1) : ds.Tables.Add(dt2) : ds.Tables.Add(dt3) : ds.Tables.Add(dt4)
        Return ds
    End Function

    Public Shared Function NewRowId(ByVal table_name As String, ByVal connName As String) As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
            If CInt( _
              dbUtil.dbExecuteScalar(connName, "select count(*) as counts from " + table_name + " where ROW_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function

    Public Shared Function GetNameVonEmail(ByVal email As String) As String
        If email.Contains("@") Then
            Dim strNamePart As String = Split(email, "@")(0)
            '字首改大寫，其他改小寫 ex:tc.chen ->Tc.Chen
            Dim strNameArry() As String = Split(strNamePart, ".")
            For i As Integer = 0 To strNameArry.Length - 1
                If strNameArry(i).Length > 1 Then
                    strNameArry(i) = strNameArry(i).Substring(0, 1).ToUpper() + strNameArry(i).Substring(1).ToLower()
                Else
                    strNameArry(i) = strNameArry(i).ToUpper()
                End If
            Next
            strNamePart = String.Join(".", strNameArry)
            Return strNamePart
        Else
            Return email
        End If
    End Function

    Public Shared Function FormatMoney(ByVal money As Double, ByVal currency As String) As String
        Select Case UCase(Trim(currency))
            Case "EUR"
                Return "&euro;" + money.ToString()
            Case "USD", "US"
                Return "$" + money.ToString()
            Case "YEN", "JPY"
                Return "&yen;" + money.ToString()
            Case "NTD", "TWD"
                Return "NT " + money.ToString()
            Case "RMB"
                Return "RMB " + money.ToString()
            Case "GBP"
                Return "&pound;" + money.ToString()
            Case "AUD"
                Return "AUD" + money.ToString()
            Case "MYR"
                Return "RM" + money.ToString()
            Case Else
                Return currency + " " + money.ToString()
        End Select
    End Function
    Public Shared Function GetCMSContent(ByVal recid As String, ByVal Type As String) As String
        Dim aspxpage As String = ""
        Select Case Type.ToLower()
            Case "news"
                aspxpage = "News"
            Case "case study"
                aspxpage = "applications"
        End Select
        Dim URL As String = String.Format("http://www.advantech.com.tw/ePlatform/{0}.aspx?doc_id={1}", aspxpage, recid)
        Dim client As New Net.WebClient()
        client.Headers.Add("Referer", "http://www.advantech.com.tw")
        Dim data As IO.Stream = client.OpenRead(URL)
        Dim reader As New IO.StreamReader(data)
        Dim strHtml As String = reader.ReadToEnd()
        'Console.WriteLine(strHtml)
        reader.Close()
        Dim doc1 As New HtmlAgilityPack.HtmlDocument
        doc1.LoadHtml(strHtml)
        Dim tds As HtmlAgilityPack.HtmlNodeCollection = doc1.DocumentNode.SelectNodes("//td")
        For Each tdnode As HtmlAgilityPack.HtmlNode In tds
            If tdnode.Attributes("class") IsNot Nothing _
            AndAlso tdnode.Attributes("valign") IsNot Nothing _
            AndAlso tdnode.Attributes("class").Value = "DivMainCenter2" _
            AndAlso tdnode.Attributes("valign").Value = "top" Then
                Select Case Type.ToLower()
                    Case "news"
                        Return tdnode.ChildNodes(1).ChildNodes(7).ChildNodes(7).InnerHtml
                    Case "case study"
                        Return tdnode.ChildNodes(1).ChildNodes(5).ChildNodes(7).InnerHtml
                End Select
            End If
        Next
        Return ""
    End Function


    'Public Shared Function IsPHIUser(ByVal email As String) As Boolean
    '    email = LCase(email)
    '    If email = "janelourd.h@advantech.com" Then
    '        Return True
    '    Else
    '        Return False
    '    End If
    'End Function

    Public Shared Function IsInternalUser(ByVal User_Id As String) As Boolean
        'Andrew 2015/9/4 set Mydashborader link for franchiser
        '為了判斷user的身分別,將原本的流程移入RecognizeUser
        Dim result As Boolean

        Dim users = RecognizeUser(User_Id)
        Select Case users
            Case UserType.Internal
                result = True
            Case UserType.Franchiser
                result = True
            Case UserType.Customer
                result = False
            Case Else
                result = False
        End Select

        Return result
    End Function

    ''' <summary>
    ''' Recognize User is internal user or franchiser or customer
    ''' </summary>
    ''' <param name="User_Id">user id</param>
    ''' <returns>the user type</returns>
    ''' <remarks>Andrew 2015/9/4 set Mydashborader link for franchiser; 2015/9/7 modify output</remarks>
    Public Shared Function RecognizeUser(ByVal User_Id As String) As UserType

        If LCase(User_Id) = "test.acl@advantech.com" Or LCase(User_Id) = "ncg@advantech.com" Then
            Return UserType.Internal
        End If
        If User_Id Is Nothing Then Return UserType.Customer

        'Frank 2012/10/01 Return True If login user is Franchiser
        If IsFranchiser(User_Id, "") Then Return UserType.Franchiser
        'If IsAINUser(User_Id) Then Return False
        'If IsPHIUser(User_Id) Then Return False
        Dim MailDomain As String = "", role As String = ""
        Dim uArray() As String = Split(User_Id, "@")
        Try
            MailDomain = LCase(Trim(uArray(1)))
        Catch ex As Exception
            Return UserType.Customer
        End Try

        Dim user As UserType = UserType.Customer
        Select Case LCase(MailDomain)
            'Andrew 2015/9/16 add cermate.com to internal list
            Case "cermate.com"
                user = UserType.Internal
            Case "advantech.de", "advantech.pl", "advantech-uk.com", "advantech.fr", "advantech.it",
                "advantech.nl", "advantech-nl.nl", "advantech.com.tw", "advantech.com.cn", "advantech.com", "advantech.com.mx",
                "advantech.eu", "advantech.co.jp", "advantech.kr", "advantech.my", "advantech.sg",
                "advantechsg.com.sg", "advantech.corp", "advantech.uk", "advantech.co.kr", "advantech.br", "advantech.ru",
                "innocoregaming.com", "advantech.com.br", "dlog.com", "gpegint.com", "advansus.com.tw", "advantech-dlog.com", "advanixs.com", "advanixs.com.tw",
                "advantech-bb.com", "advantech-bb.cz", "advantech.com.vn"
                '20170927 TC: include B+B Czech's domain
                '20160218 TC: added "advantech-dlog.com"
                'Ryan 20170116 Add "advantech-bb.com"
                Dim o As Object = dbUtil.dbExecuteScalar("EZ", String.Format("SELECT count(email_addr) FROM [Employee_New].[dbo].[EZ_PROFILE] where email_addr='{0}'", User_Id))
                If IsNumeric(o) AndAlso CInt(o) > 0 Then
                    user = UserType.Internal
                Else
                    user = UserType.Customer
                End If
            Case Else
                user = UserType.Customer
        End Select
        Return user
    End Function
    Public Shared Function IsInternalUser2() As Boolean
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
            OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False
        Return IsInternalUser(HttpContext.Current.Session("user_id").ToString().ToLower())

    End Function

    Public Shared Function IsValidEmailFormat(ByVal email As String) As Boolean
        Dim reg As String = "^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
        Dim options As RegexOptions = RegexOptions.Singleline
        If Regex.Matches(email, reg, options).Count = 0 Then
            Return False
        Else
            Return True
        End If
    End Function

    Public Shared Function IP2CountryCity(ByVal IP As String, ByRef Country As String, ByRef City As String) As Boolean
        If IP Like "172.*" Or IP Like "127.*" Then
            Country = "GERMANY" : City = "MUNICH" : Return True
        End If
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", _
        String.Format("select top 1 country_name, city from myadvantech_ip2city where {0} between ipfrom and ipto", Dot2LongIP(IP)))
        If dt.Rows.Count > 0 Then
            Country = dt.Rows(0).Item("country_name") : City = dt.Rows(0).Item("city") : Return True
        End If
        Country = "GERMANY" : City = "MUNICH" : Return False
    End Function
    Public Shared Function GetIncotermName(ByVal IncotermID As String) As String
        Dim SQL As String = String.Format(" select tinct.BEZEI from  saprdp.tinct where inco1='{0}' AND SPRAS='E' AND ROWNUM =1", IncotermID)
        Dim Incoterm As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", SQL)
        If Incoterm IsNot Nothing Then
            Return Incoterm
        End If
        Return ""
    End Function
    Shared Function GetAscxStr(ByVal OrderID As String, ByVal TypeInt As Integer) As String
        Dim path As String = ""
        If TypeInt = 0 Then
            path = "~/Includes/PITemplate/soldtoshipto.ascx"
        ElseIf TypeInt = 1 Then
            path = "~/Includes/PITemplate/OrderInfo.ascx"
        End If
        If String.IsNullOrEmpty(path) Then Return ""
        Dim pageHolder As New TBBasePage()
        pageHolder.IsVerifyRender = False
        Dim cw1 As UserControl = CType(pageHolder.LoadControl(path), UserControl)
        Dim viewControlType As Type = cw1.GetType
        Dim p_QuoteId As Reflection.PropertyInfo = viewControlType.GetProperty("OrderID")
        p_QuoteId.SetValue(cw1, OrderID, Nothing)
        pageHolder.Controls.Add(cw1)
        Dim output As New IO.StringWriter()
        HttpContext.Current.Server.Execute(pageHolder, output, False)
        Return output.ToString
    End Function
    Public Shared Function GetSalesID(ByVal userid As String) As String
        If userid Is Nothing OrElse userid.Contains("@") = False Then Return Nothing
        Dim namepart As String = GetNameVonEmail(userid)

        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
           "select top 1 SALES_CODE from SIEBEL_SAP_SALESCODE where SALES_EMAIL='{0}' and SALES_CODE<>''", userid))
        If dt.Rows.Count = 1 Then
            Dim retcode As String = ""
            If dt.Rows(0).Item("SALES_CODE").ToString().Contains("-") Then
                Dim pp() As String = Split(dt.Rows(0).Item("SALES_CODE").ToString(), "-")
                retcode = pp(0)
            Else
                retcode = dt.Rows(0).Item("SALES_CODE").ToString()
            End If
            If retcode.Trim() <> "" Then Return retcode.Trim()
        End If

        Dim obj As Object = dbUtil.dbExecuteScalar("MY", _
        String.Format(" select top 1 sales_code from sap_employee " + _
                      " where sname='{0}' or ename='{0}' or full_name='{0}' or email like '{0}%'", namepart))
        If obj IsNot Nothing Then Return obj.ToString()
        obj = dbUtil.dbExecuteScalar("MY", String.Format(" select top 1 a.SALES_CODE  " + _
                                     " from SAP_EMPLOYEE a inner join SIEBEL_CONTACT b on a.FIRST_NAME=b.FirstName and a.LAST_NAME=b.LastName  " + _
                                     " where b.EMAIL_ADDRESS like '{0}@advantech%.%' ", namepart))
        If obj IsNot Nothing Then Return obj.ToString()
        Return ""
    End Function

    Public Shared Function GetMyLeadsSql( _
    ByVal company_id As String, ByVal user_id As String, ByVal AllOrPart As Integer, _
    ByVal OpenOrClose As Integer, Optional ByVal Xls As Boolean = False) As String
        If user_id Is Nothing Then user_id = ""
        Dim sql As String = String.Format("select distinct row_id from siebel_account where erp_id='{0}' and erp_id<>'' and row_id is not null ", company_id)
        If company_id = "EIITSI04" Then sql = "select distinct row_id from siebel_account where erp_id in ('EIITSI04','EFFRTE02') and erp_id<>'' and row_id is not null "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        If dt.Rows.Count > 0 Then
            Dim rid As New ArrayList
            For Each r As DataRow In dt.Rows
                rid.Add("'" + r.Item("row_id") + "'")
            Next
            If company_id.ToUpper.StartsWith("EKGBEC0") Then
                rid.Add("'EKGBEC01'") : rid.Add("'EKGBEC02'") : rid.Add("'EKGBEC03'")
            End If
            Dim strRid As String = "(" + String.Join(",", rid.ToArray()) + ")"
            Dim sb As New System.Text.StringBuilder
            With sb
                If Xls Then
                    .AppendLine(String.Format("  select distinct A.ROW_ID, A.STATUS_CD as Status, A.NAME, A.CURCY_CD as Currency, cast(A.SUM_REVN_AMT as numeric(18,2)) as Amount,  "))
                    .AppendLine(String.Format("  IsNull((select top 1 Z.NAME from S_ORG_EXT Z where Z.ROW_ID=A.PR_DEPT_OU_ID),'') as [Account Name], "))
                    .AppendLine(String.Format("  IsNull((select top 1 IsNull(Z1.ADDR,'')+' '+IsNull(Z1.ADDR_LINE_2,'')+', '+IsNull(Z1.CITY,'')+', '+ IsNull(Z1.COUNTRY,'') from S_ADDR_PER Z1 inner join S_ORG_EXT Z2 on Z1.ROW_ID=Z2.PR_ADDR_ID where Z2.ROW_ID=A.PR_DEPT_OU_ID),'') as [ACCOUNT ADDRESS],  "))
                    .AppendLine(String.Format("  IsNull((select top 1 Z.MAIN_PH_NUM from S_ORG_EXT Z where Z.ROW_ID=A.PR_DEPT_OU_ID),'') as [Account Phone],  "))
                    .AppendLine(String.Format("  IsNull((select CN.FST_NAME + ' ' + CN.LAST_NAME from  S_CONTACT CN where CN.ROW_ID = CON.PER_ID),'') as CONTACT,  "))
                    .AppendLine(String.Format("  IsNull((select top 1 G.WORK_PH_NUM from S_CONTACT G where G.ROW_ID=CON.PER_ID),'') as CONTACT_PHONE,  "))
                    .AppendLine(String.Format("  IsNull((select top 1 G.EMAIL_ADDR from S_CONTACT G where G.ROW_ID=CON.PER_ID),'') as CONTACT_EMAIL,  "))
                    .AppendLine(String.Format("  A.CREATED, A.SUM_EFFECTIVE_DT, A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, IsNull(A.DESC_TEXT,'') as Description, "))
                    .AppendLine(String.Format("  (select J.FST_NAME + ' ' + J.LAST_NAME  from  S_CONTACT J where J.ROW_ID = I.ROW_ID) as SALES_TEAM_NAME,  "))
                    .AppendLine(String.Format("  IsNull((select top 1 G.EMAIL_ADDR from S_CONTACT G where G.ROW_ID=X.ATTRIB_46),'') as Assigned_Channel_Contact "))
                Else
                    .AppendLine(" select distinct A.ROW_ID, A.CREATED, A.PR_DEPT_OU_ID as ACCOUNT_ROW_ID, ")
                    .AppendLine(" IsNull((select top 1 Z.NAME from S_ORG_EXT Z where Z.ROW_ID=A.PR_DEPT_OU_ID),'') as ACCOUNT_NAME, ")
                    .AppendLine(" IsNull((select top 1 IsNull(Z1.ADDR,'')+' '+IsNull(Z1.ADDR_LINE_2,'')+', '+IsNull(Z1.CITY,'')+', '+ IsNull(Z1.COUNTRY,'') from S_ADDR_PER Z1 inner join S_ORG_EXT Z2 on Z1.ROW_ID=Z2.PR_ADDR_ID where Z2.ROW_ID=A.PR_DEPT_OU_ID),'') as ACCOUNT_ADDRESS,  ")
                    .AppendLine(" IsNull((select top 1 Z.MAIN_PH_NUM from S_ORG_EXT Z where Z.ROW_ID=A.PR_DEPT_OU_ID),'') as ACCOUNT_PHONE, ")
                    .AppendLine(" A.NAME, cast(A.SUM_REVN_AMT as numeric(18,2)) as SUM_REVN_AMT, A.SUM_WIN_PROB, ")
                    .AppendLine(" A.CURR_STG_ID, IsNull(B.NAME,'') as STAGE_NAME, A.SALES_METHOD_ID, A.PR_DEPT_OU_ID, ")
                    .AppendLine(" IsNull((select SM.NAME from S_SALES_METHOD SM where SM.ROW_ID=A.SALES_METHOD_ID),'') as SALES_METHOD_NAME, ")
                    .AppendLine(" IsNull(X.ATTRIB_10,'') as Assign_To_Partner, IsNull(X.ATTRIB_06,'') as BusinessGroup, ")
                    .AppendLine(" IsNull(X.ATTRIB_22,0) as Incentive_For_RBU, IsNull(X.X_ATTRIB_53,'') as Indicator, ")
                    .AppendLine(" IsNull(X.X_ATTRIB_54,0) as Product_Revenue, IsNull(X.ATTRIB_42,0) as Profile_Revenue, ")
                    .AppendLine(" IsNull(X.ATTRIB_14,0) as Quantity, IsNull(A.CHANNEL_TYPE_CD,'') as Channel, ")
                    .AppendLine(" A.BU_ID, C.NAME as BU_NAME, E.LOGIN as CREATED_BY_LOGIN, ")
                    .AppendLine(" IsNull((select top 1 G.WORK_PH_NUM from S_CONTACT G where G.ROW_ID=CON.PER_ID),'') as CONTACT_PHONE, ")
                    .AppendLine(" IsNull((select top 1 G.EMAIL_ADDR from S_CONTACT G where G.ROW_ID=CON.PER_ID),'') as CONTACT_EMAIL, ")
                    .AppendLine(" (select G.FST_NAME + ' ' + G.LAST_NAME  from S_CONTACT G where G.ROW_ID = E.ROW_ID) as CREATED_BY_NAME, ")
                    .AppendLine(" A.CURCY_CD, IsNull(A.DESC_TEXT,'') as DESC_TEXT, A.LAST_UPD, F.LOGIN as LAST_UPD_BY_LOGIN, ")
                    .AppendLine(" (select H.FST_NAME + ' ' + H.LAST_NAME  from  S_CONTACT H where H.ROW_ID = F.ROW_ID) as LAST_UPD_BY_NAME, ")
                    .AppendLine(" A.PR_POSTN_ID, D.POSTN_TYPE_CD, D.PR_EMP_ID, IsNull(A.PR_PROD_ID,'') as PR_PROD_ID, ")
                    .AppendLine(" IsNull(A.REASON_WON_LOST_CD,'') as REASON_WON_LOST_CD, A.STATUS_CD, IsNull(A.STG_NAME,'') as STG_NAME, ")
                    .AppendLine(" I.LOGIN as SALES_TEAM_LOGIN, ")
                    .AppendLine(" (select J.FST_NAME + ' ' + J.LAST_NAME  from  S_CONTACT J where J.ROW_ID = I.ROW_ID) as SALES_TEAM_NAME, A.MODIFICATION_NUM, A.SUM_EFFECTIVE_DT, ")
                    .AppendLine(" IsNull(A.PAR_OPTY_ID,'') as PAR_OPTY_ID, ")
                    .AppendLine(" EXPECT_VAL = (case when isnull(A.SUM_WIN_PROB,0)= 0 then A.SUM_REVN_AMT*(A.SUM_WIN_PROB/100) else 0 end), ")
                    .AppendLine(" IsNull((select convert(varchar(300),SCT.CRIT_SUCC_FACTORS) from  S_OPTY_T SCT where SCT.ROW_ID = SC.ROW_ID),'') as FACTOR, ")
                    .AppendLine(" IsNull((select CN.FST_NAME + ' ' + CN.LAST_NAME from  S_CONTACT CN where CN.ROW_ID = CON.PER_ID),'') as CONTACT, ")
                    .AppendLine(" CON.PER_ID as CONTACT_ROW_ID, A.PR_PRTNR_ID, X.ATTRIB_46, ")
                    .AppendLine(" IsNull((select top 1 G.EMAIL_ADDR from S_CONTACT G where G.ROW_ID=X.ATTRIB_46),'') as ChannelContact ")
                End If
                .AppendLine(" from  S_OPTY A inner join S_OPTY_X X on A.ROW_ID=X.ROW_ID ")
                .AppendLine(" left outer join  S_STG B on A.CURR_STG_ID = B.ROW_ID left outer join  S_BU C on A.BU_ID = C.ROW_ID ")
                .AppendLine(" left outer join  S_POSTN D on A.PR_POSTN_ID = D.ROW_ID left outer join  S_USER E on A.CREATED_BY = E.ROW_ID ")
                .AppendLine(" left outer join  S_USER F on A.LAST_UPD_BY = F.ROW_ID left outer join  S_USER I on D.PR_EMP_ID = I.ROW_ID ")
                .AppendLine(" left outer join  S_OPTY_T SC on SC.PAR_ROW_ID = A.ROW_ID left outer join  S_OPTY_CON CON on CON.OPTY_ID = A.ROW_ID ")
                .AppendLine(" where 1=1 ")
                If AllOrPart = 0 Then .AppendFormat(" and A.PR_PRTNR_ID in {0} ", strRid)
                Select Case OpenOrClose
                    Case 0
                        .AppendLine(" and A.SUM_WIN_PROB between 1 and 99 ")
                    Case 1
                        .AppendLine(" and (A.SUM_WIN_PROB=0 or A.SUM_WIN_PROB=100) ")
                    Case 2
                        .AppendLine(" and A.SUM_WIN_PROB between 0 and 100 ")
                End Select
                .AppendFormat(" and X.ATTRIB_10='Y' ")

                'ICC 2016/4/8 For CP customers only can see their opty
                'If HttpContext.Current.Session("org_id").ToString <> "EU10" Then
                If Util.IsInternalUser(user_id) = False Then
                    .AppendFormat(" and X.ATTRIB_46 in (select G.ROW_ID from S_CONTACT G where G.EMAIL_ADDR='{0}') ", user_id.ToString.Replace("'", "''"))
                End If
                'End If

                'If Not user_id Like "*@*advantech*" AndAlso Not dbUtil.dbGetDataTable("RFM", String.Format("select * from siebel_MyLeads where contact_email = '{0}' and company_id = '{1}'", user_id.ToString.Replace("'", "''"), company_id)).Rows.Count > 0 Then
                '    .AppendFormat(" and X.ATTRIB_46 in (select G.ROW_ID from S_CONTACT G where G.EMAIL_ADDR='{0}') ", user_id.ToString.Replace("'", "''"))
                'End If
                '.AppendFormat(" order by A.LAST_UPD desc, A.CREATED desc ")
                .AppendFormat(" order by  A.CREATED desc ")
            End With
            Return sb.ToString()
        End If
        Return ""
    End Function

    Public Shared Function WebControl2String(ByVal c As Control) As String
        Dim sw As New IO.StringWriter, htw As HtmlTextWriter = New HtmlTextWriter(sw)
        c.RenderControl(htw) : Return sw.ToString
    End Function

    Public Shared Function IsSRVItem(ByVal partno As String) As Boolean
        If CInt(dbUtil.dbExecuteScalar("RFM", String.Format("select count(*) as c from product where product_type='ZSRV' and part_no='{0}'", Trim(Replace(partno, "'", "''"))))) > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function GetSAPPrice(ByVal PartNo As String, ByVal Company_Id As String) As Double
        If PartNo = MyExtension.BuildIn OrElse PartNo.ToUpper.StartsWith("AGS-EW-") Then Return 0.0
        'Dim Org As String = Op_Quotation.GET_Company_Org_By_Compay_ID(Company_Id)
        Dim Org As String = "EU10"
        If PartNo.Contains("|") Then
            Dim ps() As String = Split(PartNo, "|"), retP As Double = 0.0
            For Each p As String In ps
                p = Global_Inc.Format2SAPItem(Trim(UCase(p)))
                Dim dt As DataTable = GetEUPrice(Company_Id, Org, p, Now)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    retP += CDbl(dt.Rows(0).Item("Netwr"))
                End If
            Next
            Return retP
        Else
            Dim pdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                " select COMPANY_ID, ORG_ID, PART_NO, QTY, LIST_PRICE, UNIT_PRICE, CURRENCY, PRICING_DATE from SAP_PRICE_CACHE " + _
                " where COMPANY_ID='{0}' and ORG_ID='{1}' and PART_NO='{2}' and PRICING_DATE>=GETDATE()-14", _
                Company_Id, Org, PartNo))
            If pdt.Rows.Count = 0 Then
                Dim dt As DataTable = GetEUPrice(Company_Id, Org, Global_Inc.Format2SAPItem(Trim(UCase(PartNo))), Now)
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Dim r As DataRow = pdt.NewRow()
                    With r
                        .Item("COMPANY_ID") = Company_Id : .Item("ORG_ID") = Org
                        .Item("PART_NO") = PartNo : .Item("QTY") = 1
                        .Item("LIST_PRICE") = dt.Rows(0).Item("Kzwi1") : .Item("UNIT_PRICE") = dt.Rows(0).Item("Netwr")
                        .Item("CURRENCY") = dt.Rows(0).Item("Waerk") : .Item("PRICING_DATE") = Now
                    End With
                    pdt.Rows.Add(r)
                    Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                    bk.DestinationTableName = "SAP_PRICE_CACHE" : bk.WriteToServer(pdt)
                    Return pdt.Rows(0).Item("UNIT_PRICE")
                End If
            Else
                Return pdt.Rows(0).Item("UNIT_PRICE")
            End If

            'Dim dt As DataTable = GetEUPrice(Company_Id, Org, Global_Inc.Format2SAPItem(Trim(UCase(PartNo))), Now)
            'If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            '    If CDbl(dt.Rows(0).Item("Netwr")) = 0.0 Then Return 0.0
            '    Dim retV As String = CDbl(dt.Rows(0).Item("Netwr"))
            '    Return retV
            'End If
        End If
        Return 0
    End Function

    Public Shared Function GetPriceByGradeRef(ByVal pn As String, ByVal pgrade As String, ByVal RBU As String, _
                                           ByVal currency As SAPCURRENCY, ByRef lp As Decimal, ByRef up As Decimal, Optional ByVal qty As Decimal = 1) As Boolean
        Dim dt As DataTable = GetPriceByGrade(pn, pgrade, RBU, currency, qty)
        If dt Is Nothing Then Return False
        lp = dt.Rows(0).Item("Kzwi1")
        up = dt.Rows(0).Item("Netwr")
        Return True
    End Function

    Public Shared Function GetPriceByGrade(ByVal pn As String, ByVal pgrade As String, ByVal RBU As String, _
                                           ByVal currency As SAPCURRENCY, Optional ByVal qty As Decimal = 1) As DataTable
        If pgrade.Length <> 8 Then Return Nothing
        Dim strKDGRP As String = "01", org As String = MYSAPBIZ.RBU2Org(RBU, HttpContext.Current.Session("org_id"))
        Select Case RBU.ToUpper()
            Case "ATW"
                strKDGRP = "03"
            Case "HQDC"
                strKDGRP = "D1"
            Case "ACN", "ABJ"
                strKDGRP = "05"
            Case "ADL", "AFR", "AEE", "ABN", "AUK", "APL"
                strKDGRP = "02"
            Case "AAC"
                strKDGRP = "10"
            Case "AENC"
                strKDGRP = "20"
            Case "ACL"
                strKDGRP = "01"
            Case "ABR"
                strKDGRP = "B1"
            Case "AKR"
                strKDGRP = "K1"
            Case "AJP"
                strKDGRP = "06"
            Case "SAP"
                strKDGRP = "07"
            Case "AAU"
                strKDGRP = "08"
            Case Else
                strKDGRP = "01"
        End Select

        pgrade = pgrade.Trim().ToUpper() : org = org.Trim().ToUpper()
        pn = Global_Inc.Format2SAPItem(pn).Trim().ToUpper()
        Dim pg As New PRICE_GRADE.PRICE_GRADE
        Dim qin As New PRICE_GRADE.ZSSD_01_PGTable
        Dim qout As New PRICE_GRADE.ZSSD_02Table
        Dim qinRow1 As New PRICE_GRADE.ZSSD_01_PG
        'C3V5P6L0
        With qinRow1
            .Matnr = pn : .Mglme = qty : .Kdkg1 = pgrade.Substring(0, 2) : .Kdkg2 = pgrade.Substring(2, 2)
            .Kdkg3 = pgrade.Substring(4, 2) : .Kdkg4 = pgrade.Substring(6, 2)
            .Mandt = "168" : .Vkorg = org : .Waerk = currency.ToString() ' .Kunnr = "EDDEVI07"
            .Kdgrp = strKDGRP
        End With
        qin.Add(qinRow1)

        pg.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        pg.Connection.Open()
        Try
            pg.Z_Sd_Priceinquery_Pg("1", qin, qout)
        Catch ex As Exception
            pg.Connection.Close() : Return Nothing
        End Try
        pg.Connection.Close()
        If qout.Count = 0 Then Return Nothing
        Return qout.ToADODataTable()
    End Function

    Public Shared Function GetEUPrice(ByVal kunnr As String, ByVal org As String, ByVal matnr As String, ByVal sDate As Date, Optional ByVal Qty As Integer = 1) As DataTable
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
        With prec
            .Kunnr = kunnr : .Mandt = "168" : .Matnr = matnr : .Mglme = Qty : .Prsdt = sDate.ToString("yyyyMMdd") : .Vkorg = org
        End With
        pin.Add(prec)
        'Next
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            eup.Connection.Close() : Return Nothing
        End Try
        eup.Connection.Close()
        Dim pdt As DataTable = pout.ToADODataTable()
        pdt.TableName = "EUPriceTable"
        Return pdt
    End Function

    Public Shared Function GetMultiEUPrice(ByVal kunnr As String, ByVal org As String, ByVal PartNumbers As DataTable) As DataTable
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        For Each p As DataRow In PartNumbers.Rows
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = kunnr : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(Trim(UCase(p.Item("part_no")))) : .Mglme = 1
                .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = org
            End With
            pin.Add(prec)
        Next
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            eup.Connection.Close() : Return Nothing
        End Try
        eup.Connection.Close()
        Dim pdt As DataTable = pout.ToADODataTable()
        pdt.TableName = "EUPriceTable"
        Return pdt
    End Function

    Public Shared Sub GetSAPATP(ByVal PartNo As String, ByVal ReqQty As Integer, ByRef MaxDate As Date, ByRef Qty As Integer)
        If PartNo = MyExtension.BuildIn OrElse PartNo.ToUpper.StartsWith("AGS-EW-") Then
            MaxDate = DateAdd(DateInterval.Day, 1, Now) : Qty = 100 : Exit Sub
        End If
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        Try
            Dim ps() As String = Split(PartNo, "|")
            Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0
            For Each p In ps
                p = Global_Inc.Format2SAPItem(Trim(UCase(p)))
                Dim culQty As Integer = 0
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", p, "EUH1", "", "", "", "", "PC", "", 9999, "", "", _
                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                Dim adt As DataTable = atpTb.ToADODataTable()
                For Each r As DataRow In adt.Rows
                    If r.Item(4) > 0 And r.Item(4) < 99999999 Then
                        culQty += r.Item(4)
                        If culQty >= ReqQty Then
                            Dim curQty As Integer = culQty
                            Dim curDate As Date = Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"))
                            If DateDiff(DateInterval.Day, retDate, curDate) > 0 Then
                                retDate = curDate : retQty = curQty
                            End If
                            Exit For
                        End If
                    End If
                Next
            Next
            MaxDate = retDate : Qty = retQty
        Catch ex As Exception
        End Try
        p1.Connection.Close()
    End Sub

    Public Shared Sub GetSAPATPByPlant(ByVal PartNo As String, ByVal ReqQty As Integer, ByVal Plant As String, ByRef MaxDate As Date, ByRef Qty As Integer)
        If PartNo = MyExtension.BuildIn OrElse PartNo.ToUpper.StartsWith("AGS-EW-") Then
            MaxDate = DateAdd(DateInterval.Day, 1, Now) : Qty = 100 : Exit Sub
        End If
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        Try
            Dim ps() As String = Split(PartNo, "|")
            Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0
            For Each p In ps
                p = Global_Inc.Format2SAPItem(Trim(UCase(p)))
                Dim culQty As Integer = 0
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", p, UCase(Plant), "", "", "", "", "PC", "", 9999, "", "", _
                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                Dim adt As DataTable = atpTb.ToADODataTable()
                For Each r As DataRow In adt.Rows
                    If r.Item(4) > 0 And r.Item(4) < 99999999 Then
                        culQty += r.Item(4)
                        If culQty >= ReqQty Then
                            Dim curQty As Integer = culQty
                            Dim curDate As Date = Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"))
                            If DateDiff(DateInterval.Day, retDate, curDate) > 0 Then
                                retDate = curDate : retQty = curQty
                            End If
                            Exit For
                        End If
                    End If
                Next
            Next
            MaxDate = retDate : Qty = retQty
        Catch ex As Exception
        End Try
        p1.Connection.Close()
    End Sub

    Public Shared Function GetSAPCompleteATP(ByVal PartNo As String, ByVal ReqQty As Integer) As DataTable
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        Dim retDt As New DataTable("DueDate")
        Try
            Dim ps() As String = Split(PartNo, "|")
            Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0
            For Each p In ps
                p = Global_Inc.Format2SAPItem(Trim(UCase(p)))
                Dim culQty As Integer = 0
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", p, "EUH1", "", "", "", "", "PC", "", 9999, "", "", _
                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                retDt.Merge(atpTb.ToADODataTable())
            Next
        Catch ex As Exception
        End Try
        p1.Connection.Close()
        Return retDt
    End Function

    Public Shared Function GetSAPCompleteATPByOrg(ByVal PartNo As String, ByVal ReqQty As Integer, ByVal plant As String, ByRef ErrMsg As String) As DataTable
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        Dim retDt As New DataTable("DueDate")
        Try
            Dim ps() As String = Split(PartNo, "|")
            Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0
            For Each p In ps
                p = Global_Inc.Format2SAPItem(Trim(UCase(p)))
                Dim culQty As Integer = 0
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", p, UCase(plant), "", "", "", "", "PC", "", 9999, "", "", _
                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                retDt.Merge(atpTb.ToADODataTable())
            Next
        Catch ex As Exception
            ErrMsg = ex.ToString() : Return Nothing
        End Try
        p1.Connection.Close()
        Return retDt
    End Function

    'Public Shared Function EXWrtyItemRate(ByVal AGSEXItem As String) As Double
    '    AGSEXItem.ToUpper.Trim()
    '    Select Case AGSEXItem
    '        Case "AGS-EW-03"
    '            Return 2
    '        Case "AGS-EW-06"
    '            Return 3.5
    '        Case "AGS-EW-09"
    '            Return 5
    '        Case "AGS-EW-12"
    '            Return 6
    '        Case "AGS-EW-15"
    '            Return 7
    '        Case "AGS-EW-24"
    '            Return 10
    '        Case "AGS-EW-36"
    '            Return 15
    '    End Select
    '    Return 30
    'End Function

    Public Shared Function GetCompDesc(ByVal comp As String) As String
        Dim ret As Object = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 product_desc from sap_product where part_no='{0}'", comp.Replace("'", "''").Trim()))
        If ret IsNot Nothing Then Return ret.ToString()
        Return comp
    End Function

    Public Shared Function IsItemCountForExWarranty(ByVal comp As String) As Boolean
        Dim mg() As String = Split(ConfigurationManager.AppSettings("MaterialGroup"), ",")
        For i As Integer = 0 To mg.Length - 1
            mg(i) = "'" + mg(i) + "'"
        Next
        If CInt(dbUtil.dbExecuteScalar("RFM", _
        String.Format(" select count(part_no) as p from sap_product " + _
                      " where part_no='{0}' and material_group not in ({1})", _
                      comp.Replace("'", "''").Trim(), String.Join(",", mg)))) > 0 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function IstScheisseEstoreBOM(ByVal RootCBOMId As String) As Boolean
        Dim i As Integer = dbUtil.dbExecuteScalar("RFM", String.Format("select count(category_id) as c from cbom_catalog_category where ez_flag=2 and parent_category_id='root' and category_id=N'{0}'", RootCBOMId.Replace("'", "''")))
        If i > 0 Then Return True
        Return False
    End Function
    Public Shared Function GetQBOMSql(ByVal PCatId As String, ByVal org As String, Optional ByVal isByReg As Boolean = False) As DataTable
        Dim qsb As New System.Text.StringBuilder
        With qsb
            .AppendLine(" SELECT a.PARENT_CATEGORY_ID, a.CATEGORY_ID, a.CATEGORY_NAME, a.CATEGORY_TYPE, a.CATEGORY_DESC, ")
            .AppendLine(" IsNull(a.DISPLAY_NAME,'') as DISPLAY_NAME, IsNull(a.SEQ_NO,0) as SEQ_NO, IsNull(a.DEFAULT_FLAG,0) as DEFAULT_FLAG, ")
            .AppendLine(" IsNull(a.CONFIGURATION_RULE,'') as CONFIGURATION_RULE, IsNull(a.NOT_EXPAND_CATEGORY,'') as NOT_EXPAND_CATEGORY, ")
            .AppendLine(" IsNull(a.SHOW_HIDE,0) as SHOW_HIDE, IsNull(a.EZ_FLAG,0) as EZ_FLAG, IsNull(b.STATUS,'') as STATUS_OLD, 0 as SHIP_WEIGHT,  ")
            .AppendLine(" 0 as NET_WEIGHT, IsNull(b.MATERIAL_GROUP,'') as MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as class,a.UID,a.org ")
            .AppendLine(" ,c.PRODUCT_STATUS as STATUS ")
            .AppendLine(" FROM CBOM_CATALOG_CATEGORY AS a LEFT OUTER JOIN ")
            .AppendLine(" SAP_PRODUCT AS b ON a.CATEGORY_ID = b.PART_NO ")
            .AppendFormat(" LEFT JOIN sap_product_status AS c on c.PART_NO = a.CATEGORY_ID and c.SALES_ORG = '{0}' ", HttpContext.Current.Session("org_id"))
            'Nada 20131121 PMsin cbom edit no need be controlled by org
            If isByReg Then
                .AppendLine(String.Format(" WHERE a.PARENT_CATEGORY_ID = N'{0}' and a.org='" & org & "' and a.CATEGORY_ID<>N'{0}' ", PCatId))
            Else
                .AppendLine(String.Format(" WHERE a.PARENT_CATEGORY_ID = N'{0}' and a.CATEGORY_ID<>N'{0}' ", PCatId))
            End If
            .AppendLine(" and (a.CATEGORY_TYPE='Category' or A.CATEGORY_TYPE='Component' or (a.CATEGORY_TYPE='Component' and (a.CATEGORY_ID='No Need' or a.CATEGORY_ID like '%|%'))) ")
            .AppendLine(" ORDER BY a.SEQ_NO ")
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable(CBOMSetting.DBConn, qsb.ToString())
        Dim compArray As New ArrayList
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE") = "Component" And r.Item("category_id").ToString.Contains("|") Then
                Dim ps() As String = Split(r.Item("category_id").ToString, "|")
                For Each p As String In ps
                    If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                        If CInt(dbUtil.dbExecuteScalar(CBOMSetting.DBConn, String.Format( _
                                                        "select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " + _
                                                       " where PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " and part_no in ('{0}') and SALES_ORG='{1}'", p.ToString, HttpContext.Current.Session("Org_id")))) <= 0 Then
                            r.Delete()
                        End If
                    End If
                Next
            ElseIf r.Item("CATEGORY_TYPE") = "Component" And Not r.Item("category_id").ToString.Contains("|") And Not r.Item("category_id").ToString.ContainsV2(MyExtension.BuildIn) Then
                If Not LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("webcbomeditor") Then
                    If CInt(dbUtil.dbExecuteScalar(CBOMSetting.DBConn, String.Format( _
                                                   " select count(part_no) as c from SAP_PRODUCT_STATUS_ORDERABLE " + _
                                                   " where PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " and part_no in ('{0}') and SALES_ORG='{1}'", r.Item("CATEGORY_ID").ToString, HttpContext.Current.Session("Org_id")))) <= 0 Then
                        r.Delete()
                    End If
                End If
            End If
        Next
        dt.AcceptChanges()
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE") = "Component" Then
                If compArray.Contains(r.Item("category_id").ToString()) = False Then
                    compArray.Add(r.Item("category_id").ToString())
                Else
                    r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        compArray.Clear()
        For Each r As DataRow In dt.Rows
            If r.Item("CATEGORY_TYPE") = "Category" Then
                If compArray.Contains(r.Item("category_id").ToString()) = False Then
                    compArray.Add(r.Item("category_id").ToString())
                Else
                    r.Delete()
                End If
            End If
        Next
        dt.AcceptChanges()
        'Nada 20131121 PMsin cbom edit no need be controlled by org
        Dim str As String = String.Format("select count(category_id) as c FROM CBOM_CATALOG_CATEGORY where parent_category_id='Root' and category_id='{0}'", Replace(PCatId, "'", "''"))
        If isByReg Then
            str = String.Format("select count(category_id) as c FROM CBOM_CATALOG_CATEGORY where org='" & org & "' and parent_category_id='Root' and category_id='{0}'", Replace(PCatId, "'", "''"))
        End If
        If (PCatId.ToUpper().EndsWith("-BTO") Or PCatId.ToUpper().StartsWith("C-CTOS-")) AndAlso CInt(dbUtil.dbExecuteScalar(CBOMSetting.DBConn, str)) > 0 Then
            Dim r As DataRow = dt.NewRow()
            With r
                .Item("CATEGORY_ID") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("CATEGORY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("CATEGORY_TYPE") = "Category"
                .Item("CATEGORY_DESC") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("DISPLAY_NAME") = "Extended Warranty for " + PCatId.ToUpper()
                .Item("SEQ_NO") = 99 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
            End With
            dt.Rows.Add(r)
            'If dbUtil.dbGetDataTable("RFM", String.Format("select category_name from cbom_catalog_category where org='" & org & "' and category_id not like '%-CTOS%' and category_id not like '%SYS-%' and category_id='{0}' and isnull(EZ_Flag,'0')<>'2'", Replace(PCatId, "'", "''"))).Rows.Count > 0 Then
            If dbUtil.dbGetDataTable(CBOMSetting.DBConn, String.Format("select category_name from cbom_catalog_category where category_id not like '%-CTOS%' and category_id not like '%SYS-%' and category_id='{0}' and isnull(EZ_Flag,'0')<>'2'", Replace(PCatId, "'", "''"))).Rows.Count > 0 Then
                Dim r2 As DataRow = dt.NewRow()
                With r2
                    .Item("CATEGORY_ID") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("CATEGORY_TYPE") = "Category"
                    .Item("CATEGORY_DESC") = "CTOS note for " + PCatId.ToUpper()
                    .Item("DISPLAY_NAME") = "CTOS note for " + PCatId.ToUpper()
                    .Item("SEQ_NO") = 100 : .Item("DEFAULT_FLAG") = "" : .Item("CONFIGURATION_RULE") = ""
                    .Item("NOT_EXPAND_CATEGORY") = "" : .Item("SHOW_HIDE") = 1 : .Item("EZ_FLAG") = 0
                    .Item("STATUS") = "" : .Item("SHIP_WEIGHT") = 0 : .Item("NET_WEIGHT") = 0
                    .Item("MATERIAL_GROUP") = "" : .Item("RoHS") = "n" : .Item("class") = ""
                End With
                dt.Rows.Add(r2)
            End If
        Else
            If PCatId.ToUpper().StartsWith("EXTENDED WARRANTY FOR") Then
                qsb = New System.Text.StringBuilder
                With qsb
                    .AppendLine(" SELECT PART_NO as CATEGORY_ID, PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                    .AppendLine(" PRODUCT_DESC as CATEGORY_DESC, PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                    .AppendLine(" '' as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(STATUS,'') as STATUS, ")
                    .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                    .AppendLine(" FROM  SAP_PRODUCT ")
                    .AppendLine(" WHERE PART_NO LIKE 'AGS-EW%' order by PART_NO ")
                End With
                dt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, qsb.ToString())
            Else
                If PCatId.ToUpper().StartsWith("CTOS NOTE FOR") Then
                    qsb = New System.Text.StringBuilder
                    With qsb
                        .AppendLine(" SELECT distinct a.PART_NO as CATEGORY_ID, a.PART_NO as CATEGORY_NAME, 'Component' as CATEGORY_TYPE, ")
                        .AppendLine(" b.PRODUCT_DESC as CATEGORY_DESC, b.PRODUCT_DESC as DISPLAY_NAME, 0 as SEQ_NO, 0 as DEFAULT_FLAG, ")
                        .AppendLine(" '' as CONFIGURATION_RULE, '' as NOT_EXPAND_CATEGORY, 1 as SHOW_HIDE, 0 as EZ_FLAG, IsNull(b.STATUS,'') as STATUS, ")
                        .AppendLine(" 0 as SHIP_WEIGHT, 0 as NET_WEIGHT, MATERIAL_GROUP, case RoHS_Flag when 1 then 'y' else 'n' end as RoHS, '' as Class ")
                        .AppendLine(" from CBOM_CATEGORY_CTOS_NOTE a left join SAP_PRODUCT b on a.part_no=b.part_no ")
                        .AppendLine(" order by a.PART_NO ")
                    End With
                    dt = dbUtil.dbGetDataTable(CBOMSetting.DBConn, qsb.ToString())
                End If
            End If
        End If
        Return dt
    End Function

    Public Shared Function GetConfigOrderCartDt() As DataTable
        Dim dt As New DataTable("ConfigCart")
        With dt.Columns
            .Add("CATEGORY_ID", GetType(String)) : .Add("CATEGORY_NAME", GetType(String))
            .Add("CATEGORY_TYPE")
            .Add("PARENT_CATEGORY_ID", GetType(String)) : .Add("CATALOG_ID", GetType(String))
            .Add("CATALOGCFG_SEQ", GetType(Integer)) : .Add("CATEGORY_DESC", GetType(String))
            .Add("DISPLAY_NAME", GetType(String)) : .Add("IMAGE_ID", GetType(String))
            .Add("EXTENDED_DESC", GetType(String)) : .Add("CREATED", GetType(DateTime))
            .Add("CREATED_BY", GetType(String)) : .Add("LAST_UPDATED", GetType(DateTime))
            .Add("LAST_UPDATED_BY", GetType(String)) : .Add("SEQ_NO", GetType(Integer))
            .Add("PUBLISH_STATUS", GetType(String)) : .Add("CATEGORY_PRICE", GetType(Double))
            .Add("CATEGORY_QTY", GetType(Integer)) : .Add("ParentSeqNo", GetType(Integer)) : .Add("ParentRoot", GetType(String))
        End With
        Return dt
    End Function
    Public Shared Function Get_Q_ConfigOrderCartDt() As DataTable
        Dim dt As New DataTable("ConfigCart")
        With dt.Columns
            .Add("CATEGORY_ID", GetType(String)) : .Add("CATEGORY_NAME", GetType(String))
            .Add("CATEGORY_TYPE")
            .Add("PARENT_CATEGORY_ID", GetType(String)) : .Add("CATALOG_ID", GetType(String))
            .Add("CATALOGCFG_SEQ", GetType(Integer)) : .Add("CATEGORY_DESC", GetType(String))
            .Add("DISPLAY_NAME", GetType(String)) : .Add("IMAGE_ID", GetType(String))
            .Add("EXTENDED_DESC", GetType(String)) : .Add("CREATED", GetType(DateTime))
            .Add("CREATED_BY", GetType(String)) : .Add("LAST_UPDATED", GetType(DateTime))
            .Add("LAST_UPDATED_BY", GetType(String)) : .Add("SEQ_NO", GetType(Integer))
            .Add("PUBLISH_STATUS", GetType(String)) : .Add("CATEGORY_PRICE", GetType(Double))
            .Add("CATEGORY_QTY", GetType(Integer)) : .Add("REQUIRED_DATE", GetType(DateTime)) : .Add("DUE_DATE", GetType(DateTime)) : .Add("flg", GetType(String))
        End With
        Return dt
    End Function

    Public Shared Function IsRBUCompanyID(ByVal erpid As String) As Boolean
        erpid = Trim(UCase(erpid))
        Dim rbuids() As String = {"UUAAESC", "EHLA002", "EATWAD01", "ENLA001", "EFRA008", "UUAAAC", "EITW005", "EGCS002", "EPLA001", "EUKA001", "EHYS002"}
        For Each bu As String In rbuids
            If erpid = bu Then Return True
        Next
        Return False
    End Function
    Public Shared Function Dot2LongIP(ByVal DottedIP As String) As Double
        Dim arrDec() As String
        Dim i As Integer
        Dim intResult As Long
        If DottedIP = "" Then
            Dot2LongIP = 0
        Else
            arrDec = DottedIP.Split(".")
            For i = arrDec.Length - 1 To 0 Step -1
                intResult = intResult + ((Int(arrDec(i)) Mod 256) * Math.Pow(256, 3 - i))
            Next
            Dot2LongIP = intResult
        End If
    End Function

    Public Shared Function ControlToHtml(ByVal gv1 As Control) As String
        Dim sw As New IO.StringWriter
        Dim htw As HtmlTextWriter = New HtmlTextWriter(sw)
        gv1.RenderControl(htw)
        Return sw.ToString
    End Function
    Public Shared Function GetLastDateOfMonth(ByVal d As Date) As Date
        Return DateAdd(DateInterval.Day, -1, CDate(DateAdd(DateInterval.Month, 1, d).ToString("yyyy-MM-01")))
    End Function

    Public Shared Function GenerateScript(ByVal columnName As String, ByVal gv As GridView, ByVal P As Page) As String
        Dim optionalParam As String = "Sort$" + columnName, sb As New StringBuilder()
        With sb
            .Append("<a href=""") : .Append("javascript:") : .Append(P.ClientScript.GetPostBackEventReference(gv, optionalParam, False))
            .Append(""">") : .Append(columnName) : .Append("</a>") : Return .ToString()
        End With
    End Function

    Public Shared Function XmlToDataTable(ByVal xml As String) As DataTable
        If xml = "" Then Throw New Exception("xml string is empty")
        Dim ds As New DataSet
        Try
            ds.ReadXml(New IO.StringReader(xml))
        Catch ex As Exception
            Throw New Exception("xml reading error")
        End Try
        If ds.Tables.Count > 0 Then
            Return ds.Tables(0)
        End If
        Throw New Exception("no xml or datatable")
    End Function
    Public Shared Function ADOXml2DataTable(ByVal xml As String) As DataTable

        Try
            Dim sr As New IO.StringReader(xml)
            Dim ds As New DataSet
            ds.ReadXml(sr)
            Dim dt As DataTable = Nothing

            dt = ds.Tables("row")
            dt.ParentRelations.Clear()
            dt.Constraints.Clear()
            dt.Columns.Remove("Insert_Id")
            Return dt

        Catch ex As Exception
            Return Nothing
            Exit Function
        End Try

    End Function
    Public Shared Function DataTableToXml(ByVal dt As DataTable) As String
        Dim ds As New DataSet("Xml") : ds.Tables.Add(dt) : Return ds.GetXml()
    End Function

    Public Shared Sub SendEmail( _
           ByVal SendTo As String, ByVal From As String, _
           ByVal Subject As String, ByVal Body As String, _
           ByVal IsBodyHtml As Boolean, _
           ByVal cc As String, _
           ByVal bcc As String, Optional ByVal NotifyOnFailure As Boolean = False)
        MailUtil.SendEmail(SendTo, From, Subject, Body, IsBodyHtml, cc, bcc, NotifyOnFailure)
        'Dim htmlMessage As Net.Mail.MailMessage, mySmtpClient As Net.Mail.SmtpClient
        'htmlMessage = New Net.Mail.MailMessage(From, SendTo, Subject, Body)
        'htmlMessage.IsBodyHtml = IsBodyHtml
        'If cc <> "" Then htmlMessage.CC.Add(cc)
        'Try
        '    If bcc <> "" Then htmlMessage.Bcc.Add(bcc)
        'Catch ex As Exception
        '    Throw New Exception("BCC:" + bcc + " caused error for sending email")
        'End Try

        'If NotifyOnFailure Then htmlMessage.DeliveryNotificationOptions = Net.Mail.DeliveryNotificationOptions.OnFailure
        ''htmlMessage.CC.Add("tc.chen@advantech.com.tw")
        ''htmlMessage.CC.Add("jackie.wu@advantech.com.cn")
        'mySmtpClient = New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        'Try
        '    mySmtpClient.Send(htmlMessage)
        'Catch ex As System.Net.Mail.SmtpException
        '    System.Threading.Thread.Sleep(100)
        '    mySmtpClient.Send(htmlMessage)
        'End Try
    End Sub

    Public Shared Function Xml2Datatable(ByVal xml As String) As DataTable
        Dim reader1 As New StringReader(xml)
        Dim set1 As New DataSet
        set1.ReadXml(reader1)
        Return set1.Tables(0)
    End Function

    Public Shared Sub JSAlert(ByVal Page As Page, ByVal msg As String)
        Dim jscript As String = _
        "<script type='text/javascript'>" + vbCrLf + _
        "alert('" + Replace(msg, "'", "''") + "');" + vbCrLf + _
        "</script>"
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSAlert", jscript)
    End Sub

    Public Shared Sub JSRedirect(ByVal Page As Page, ByVal url As String)
        Dim jscript As String = _
        "<script type='text/javascript'>" + vbCrLf + _
        "location.href = '" + url + "';" + vbCrLf + _
        "</script>"
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "redirect", jscript)
    End Sub

    Public Shared Sub JSAlertRedirect(ByVal Page As Page, ByVal msg As String, ByVal url As String)
        Dim jscript As String = _
        "<script type='text/javascript'>" + vbCrLf + _
        "alert('" + Replace(msg, "'", "''") + "');" + vbCrLf + _
        "location.href = '" + url + "';" + vbCrLf + _
        "</script>"
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSAlertRedirect", jscript)
    End Sub
    Public Shared Sub JSAlertGoBack(ByVal Page As Page, ByVal msg As String)
        Dim jscript As String = _
        "<script type='text/javascript'>" + vbCrLf + _
        "alert('" + Replace(msg, "'", "''") + "');" + vbCrLf + _
        "history.back();" + vbCrLf + _
        "</script>"
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSAlertRedirect", jscript)
    End Sub
    Public Shared Sub JSAlertGoBack1(ByVal Page As Page, ByVal msg As String)
        Dim jscript As String = _
        "<script type='text/javascript'>" + vbCrLf + _
        "function a(){" + vbCrLf + _
        "alert('" + Replace(msg, "'", "''") + "');" + vbCrLf + _
        "history.back();" + vbCrLf + _
        "}" + vbCrLf + _
        "a();" + vbCrLf + _
        "</script>"
        Page.ClientScript.RegisterClientScriptBlock(Page.GetType(), "JSAlertRedirect", jscript)
    End Sub
    Public Shared Sub AjaxRedirect(ByVal UpdatePanel1 As UpdatePanel, ByVal url As String)
        UI.ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "redirect", "location.href = '" + url + "'", True)
    End Sub

    Public Shared Sub AjaxJSAlert(ByVal UpdatePanel1 As UpdatePanel, ByVal msg As String)
        Dim jscript As String = _
        "<script type='text/javascript'>" + vbCrLf + _
        "alert('" + msg + "');" + vbCrLf + _
        "</script>"
        jscript = "alert('" + msg + "');"
        UI.ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "jalert", jscript, True)
    End Sub

    Public Shared Sub AjaxJSAlertRedirect(ByVal UpdatePanel1 As UpdatePanel, ByVal msg As String, ByVal url As String)
        Dim jscript As String = "alert('" + msg + "');"
        UI.ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "jalert", jscript, True)
        UI.ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "redirect", "location.href = '" + url + "'", True)
    End Sub
    Public Shared Sub AjaxJSConfirm(ByVal UpdatePanel1 As UpdatePanel, ByVal msg As String, ByVal url As String)
        Dim jscript As New StringBuilder
        jscript.Append("<script type='text/javascript'>")
        ' jscript.Append("function Delconfirm() {")
        jscript.Append(String.Format("if (confirm('{0}') == true) {1}", msg, "{"))
        jscript.Append(String.Format("location.href = '{0}';", url))
        jscript.Append("}")
        jscript.Append("else {")
        jscript.Append("return false;")
        jscript.Append("}")
        '  jscript.Append("}")
        jscript.Append("</script>")
        UI.ScriptManager.RegisterStartupScript(UpdatePanel1, UpdatePanel1.GetType(), "jalert", jscript.ToString(), False)
    End Sub

    Public Shared Function FormatDate(ByVal xDate As String) As String
        Dim arr() As String = Split(xDate, "/")
        Return arr(2).ToString & "/" & arr(1).ToString & "/" & arr(0).ToString
    End Function

    Public Shared Function SetSessionVariables(ByVal windowsid As String) As Boolean
        Dim dt As DataTable = dbUtil.dbGetDataTable("AEUEZ", _
        String.Format("select EMAILID from AEU_EMPLOYEE where WINDOWID='{0}'", windowsid))
        If dt.Rows.Count > 0 Then
            Dim Session As HttpSessionState = HttpContext.Current.Session
            With dt.Rows(0)
                Session("user_id") = .Item("EMAILID")
            End With
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function IsEUPSM() As Boolean
        Dim adminList As New ArrayList
        With adminList
            .Add("mory.lin@advantech.com.tw") : .Add("ally.huang@advantech.com.tw")
        End With
        If adminList.Contains(HttpContext.Current.Session("user_id")) Then
            Return True
        End If
        Return False
    End Function

    Public Shared Function IsBBCustomerCare() As Boolean
        If HttpContext.Current.User.Identity.Name.Equals("schen@advantech-bb.com", StringComparison.CurrentCultureIgnoreCase) Then Return True
        If HttpContext.Current.User.Identity.Name.Equals("thaas@advantech-bb.com", StringComparison.CurrentCultureIgnoreCase) Then Return True
        If HttpContext.Current.User.Identity.Name.Equals("d_lebeau@advantech-bb.com", StringComparison.CurrentCultureIgnoreCase) Then Return True
        Dim _group() As String = {"BB.CS.IL", "MyAdvantech", "DMKT.ACL"}
        Dim _IsInRoleResult As Boolean = MailUtil.IsInRole_V2(_group)
        Return _IsInRoleResult
    End Function

    Public Shared Function IsAdmin() As Boolean
        If HttpContext.Current.Session("user_id").ToString.Trim.ToLower = "adam.sturm@advantech.com" _
            OrElse HttpContext.Current.User.Identity.Name.Equals("judy.chen@advantech.com.tw", StringComparison.OrdinalIgnoreCase) Then Return True


        Dim _group() As String = {"MANAGERS.DMF.USA", "SALES.IAG.KA", "eBusiness.AEU",
                                  "eStore.IT", "Sales.IAG.USA", "Sales.AAC.USA", "SALES.ECG.USA",
                                  "MyAdvantech", "DMF-USA"}
        Dim _IsInRoleResult As Boolean = MailUtil.IsInRole_V2(_group)
        Return _IsInRoleResult


        'If MailUtil.IsInRole("MANAGERS.DMF.USA") _
        '    OrElse MailUtil.IsInRole("SALES.IAG.KA") _
        '    OrElse MailUtil.IsInRole("eBusiness.AEU") _
        '    OrElse MailUtil.IsInRole("eStore.IT") _
        '    OrElse MailUtil.IsInRole("Sales.IAG.USA") _
        '    OrElse MailUtil.IsInRole("Sales.AAC.USA") _
        '    OrElse MailUtil.IsInRole("SALES.ECG.USA") _
        '    OrElse MailUtil.IsInRole("MyAdvantech") _
        '    OrElse MailUtil.IsInRole("DMF-USA") Then

        '    Return True

        'End If

        'Return False

    End Function

    Public Shared Function IsMyAdvantechIT() As Boolean

        Dim _group() As String = {"MyAdvantech"}
        Dim _IsInRoleResult As Boolean = MailUtil.IsInRole_V2(_group)
        Return _IsInRoleResult

    End Function

    Public Shared Function IsAccountAdmin() As Boolean
        If CInt(dbUtil.dbExecuteScalar("My", String.Format("select count(*) from SIEBEL_CONTACT_PRIVILEGE where PRIVILEGE='Account Admin' and EMAIL_ADDRESS='{0}'", HttpContext.Current.Session("user_id")))) > 0 Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function GetXmlFromWeb(ByVal url As String) As System.Xml.XmlDocument
        Try
            Dim WebReq As System.Net.HttpWebRequest = CType(System.Net.WebRequest.Create(url), System.Net.HttpWebRequest)
            WebReq.Proxy = New Net.WebProxy("http://172.21.34.46:8080")
            WebReq.UserAgent = "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.8.1.4) Gecko/20070515 Firefox/2.0.0.4"
            Dim WebResponse As System.Net.HttpWebResponse = CType(WebReq.GetResponse(), System.Net.HttpWebResponse)
            Dim retXml As New System.Xml.XmlDocument
            retXml.Load(WebResponse.GetResponseStream())
            WebResponse.Close()
            Return retXml
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
    Public Shared Function GetEmailByUniqueId(ByVal uid As String) As String
        Dim email As Object = dbUtil.dbExecuteScalar("RFM", _
       String.Format("select top 1 email from email_uniqueid where hashvalue=N'{0}'", uid))
        If email IsNot Nothing Then
            Return email.ToString()
        Else
            Return ""
        End If
    End Function

    Public Shared Function GetCheckedCountFromCheckBoxList(ByVal lb As CheckBoxList) As Integer
        Dim i As Integer = 0
        For Each l As ListItem In lb.Items
            If l.Selected Then i += 1
        Next
        Return i
    End Function

    Public Shared Function GetInStrinFromCheckBoxList(ByVal lb As CheckBoxList) As String
        Dim al As New ArrayList
        For Each l As ListItem In lb.Items
            If l.Selected Then al.Add("N'" + Replace(l.Value, "'", "''") + "'")
        Next
        If al.Count = 0 Then Return ""
        Return "(" + String.Join(",", CType(al.ToArray(GetType(String)), String())) + ")"
    End Function


    Public Shared Function GetMultiDueDate( _
            ByVal customer_no As String, ByVal shipto_no As String, ByVal sales_org As String, _
            ByVal distr_chan As String, ByVal division As String, ByVal strXML As String, _
            ByRef strResult As String, ByRef strRemark As String) As Integer
        strRemark = ""
        strResult = ""

        If Trim(sales_org).ToUpper() = "US01" Then
            distr_chan = "30" : division = "10"
        End If

        'read ADOXML to dataset
        Dim reader1 As New StringReader(strXML)
        Dim set1 As New DataSet
        set1.ReadXml(reader1)
        Dim zssD_08Table1_New As New Due_Date_Inquiry.ZSSD_08Table
        Dim zssD_04Table1_New As New Due_Date_Inquiry.ZSSD_04Table
        Dim proxy1 As New Due_Date_Inquiry.Due_Date_Inquiry
        Dim retTable As New Due_Date_Inquiry.BAPIRETURN
        Try
            'retrive data from ADOXML string
            Dim table1 As DataTable = set1.Tables.Item("row")
            Dim num1 As Integer

            '20080907 TC:Special suck ATP
            Dim z_atp_table As New Check_Special_ATP.VBAPTable, k As Integer = 1
            Dim proxy2 As New Check_Special_ATP.Check_Special_ATP
            proxy2.Connection = New SAPConnection(ConfigurationManager.AppSettings("SAP_PRD").ToString)
            If table1 IsNot Nothing Then
                For num1 = 0 To table1.Rows.Count - 1
                    Dim zssd_1 As New Check_Special_ATP.VBAP
                    zssd_1.Posnr = k.ToString()
                    zssd_1.Matnr = table1.Rows.Item(num1).Item("MATNR").ToString
                    zssd_1.Werks = table1.Rows.Item(num1).Item("WERK").ToString
                    zssd_1.Lgort = ""
                    zssd_1.Zz_Edatu = table1.Rows.Item(num1).Item("REQ_Date").ToString
                    If Decimal.Parse(table1.Rows.Item(num1).Item("REQ_QTY").ToString) >= 50 Then
                        zssd_1.Kwmeng = 50
                    Else
                        zssd_1.Kwmeng = Decimal.Parse(table1.Rows.Item(num1).Item("REQ_QTY").ToString)
                    End If
                    z_atp_table.Add(zssd_1)
                    k += 1
                Next
            End If
            proxy2.Connection.Open() : proxy2.Zcheck_Specialrule_Atp(z_atp_table) : proxy2.Connection.Close()
            'Set Connection information              
            'Utility_EMailPage("ebiz.aeu@advantech.eu", "tc.chen@advantech.com.tw", "", "", "special ATP xml", "", Utilities.DataTableToADOXML(z_atp_table.ToADODataTable()))
            For k = 0 To z_atp_table.Count - 1
                If z_atp_table.Item(k).Zz_Atp = "Y" Then
                    Try
                        If table1 IsNot Nothing Then table1.Rows(k).Item("MATNR") = "fakeitemnoexist"
                    Catch ex As Exception
                        Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "", "", "m dd remove special ATP line error", "", z_atp_table.Item(k).Matnr + " " + z_atp_table.Item(k).Kmpmg.ToString() + " " + z_atp_table.Item(k).Zz_Edatu + " " + ex.ToString())
                    End Try
                End If
            Next
            If table1 IsNot Nothing Then table1.AcceptChanges()
            'End Special suck ATP

            proxy1.Connection = New SAPConnection(ConfigurationManager.AppSettings("SAP_PRD").ToString)
            proxy1.Connection.Open()
            'set RFC parameter
            If table1 IsNot Nothing Then
                For num1 = 0 To table1.Rows.Count - 1
                    Dim zssd_1 As New Due_Date_Inquiry.ZSSD_08
                    zssd_1.Werks = table1.Rows.Item(num1).Item("WERK").ToString
                    zssd_1.Matnr = Global_Inc.Format2SAPItem(table1.Rows.Item(num1).Item("MATNR").ToString)
                    zssd_1.Req_Qty = Decimal.Parse(table1.Rows.Item(num1).Item("REQ_QTY").ToString)
                    zssd_1.Req_Date = table1.Rows.Item(num1).Item("REQ_Date").ToString
                    zssd_1.Unit = table1.Rows.Item(num1).Item("UNI").ToString
                    zssD_08Table1_New.Add(zssd_1)
                Next num1
            End If


            proxy1.Z_Duedateinquiry( _
            distr_chan, division, customer_no, sales_org, shipto_no, retTable, zssD_08Table1_New, zssD_04Table1_New)

            proxy1.Connection.Close()

            'datetime formate transform
            Dim info1 As New CultureInfo("en-US")
            Dim num2 As Integer
            For num2 = 0 To zssD_04Table1_New.Count - 1
                Dim provider1 As New CultureInfo("fr-FR", True)
                Dim time1 As DateTime = DateTime.ParseExact(zssD_04Table1_New.Item(num2).Due_Date, "yyyyMMdd", provider1)
                '  Me.zssD_04Table1.Item(num2).Due_Date = time1.ToString("yyyy-MM-ddTHH:mm:ss")
                zssD_04Table1_New.Item(num2).Due_Date = time1.ToString("yyyy-MM-dd")
                zssD_04Table1_New.Item(num2).Matnr = Global_Inc.RemoveZeroString(zssD_04Table1_New.Item(num2).Matnr)
                Dim item As String = zssD_04Table1_New.Item(num2).Matnr.ToUpper()
                If (InStr(item, "S-WARRANTY") > 0 Or _
                InStr(item, "AGS-") > 0 Or _
                InStr(item, "OPTION") > 0 Or _
                InStr(item, "C-CTOS") Or _
                InStr(item, "CTOS-") Or _
                item.ToUpper.Substring(0, 3).Equals("IMG") Or _
                InStr(item, "-BTO")) And _
                InStr(item, "W-CTO") <= 0 Then
                    zssD_04Table1_New.Item(num2).Due_Date = DateAdd(DateInterval.Day, 1, Today()).ToString("yyyy-MM-dd")
                End If
                '<Nada add for Stock count date>
                If DateDiff(DateInterval.Day, CDate("2008-11-13"), CDate(zssD_04Table1_New.Item(num2).Due_Date)) = 0 Or _
                DateDiff(DateInterval.Day, CDate("2008-11-14"), CDate(zssD_04Table1_New.Item(num2).Due_Date)) = 0 Then
                    zssD_04Table1_New.Item(num2).Due_Date = "2008-11-17"
                End If
                '</Nada add for Stock count date>
                'If DateDiff(DateInterval.Day, CDate("2006/05/01"), CDate(zssD_04Table1_New.Item(num2).Due_Date)) = 0 Or DateDiff(DateInterval.Day, CDate("2006/05/02"), CDate(zssD_04Table1_New.Item(num2).Due_Date)) = 0 Then
                '    zssD_04Table1_New.Item(num2).Due_Date = "2006-05-03"
                'End If

            Next num2

            'field name mapping              
            Dim table2 As DataTable = DueDateTableFieldMapping(zssD_04Table1_New)
            'transform to ADOXML

            For i As Integer = 0 To table2.Rows.Count - 1
                table2.Rows(i).Item("part") = Global_Inc.RemoveZeroString(table2.Rows(i).Item("part").ToString())
            Next

            'If table2.Rows.Count = 0 Then
            '    Dim r As DataRow = table2.NewRow()
            '    r.Item("part") = "fakeitemnouse"
            '    r.Item("qty_atp") = 99999 : r.Item("date") = "2010/01/01"
            '    table2.Rows.Add(r)
            'End If

            strResult = Global_Inc.DataTableToADOXML(table2)
            strRemark &= retTable.Message
            'Utility_EMailPage("ebiz.aeu@advantech.eu", "tc.chen@advantech.com.tw", "", "", "m dd error", "", strResult)
        Catch exception1 As Exception
            '            Dim table1 As DataTable = Me.ATPTableFieldMapping(Me.zssD_04Table1)
            '           strResult = Me.DataTableToADOXML(table1)
            Try
                Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "", "", "m dd error", "", exception1.ToString())
                proxy1.Connection.Close()
                strRemark = exception1.ToString
            Catch ex As Exception

            End Try

            Return -1
        End Try

        Return 0

    End Function

    Public Shared Function GetDueDate(ByVal partNO As String, ByVal QTY As String, ByVal requiredDate As String, _
                                      ByRef dueDate As String) As Integer
        Dim dt As New DataTable
        'Dim WS As New aeu_ebus_dev9000.B2B_AEU_WS 'aeu_ebus_dev9000.b2b_sap_ws 'B2B_AEU_WS.B2B_AEU_WS
        'Dim WSDL_URL As String = ""
        'Global_Inc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        'WS.Url = WSDL_URL
        Dim iRet As Integer = OrderUtilities.initRsATP(dt, Left(HttpContext.Current.Session("org_id"), 2) & "H1", partNO, QTY, requiredDate, "PC")
        Dim xmlInput As String = Global_Inc.DataTableToADOXML(dt)
        Dim xmlout As String = ""
        Dim xmlLog As String = ""
        'WS.Timeout = 99999999
        iRet = _
        GetMultiDueDate(HttpContext.Current.Session("company_id"), HttpContext.Current.Session("company_id"), "EU10", "10", "00", _
        xmlInput, xmlout, xmlLog)

        If iRet = -1 Then
            HttpContext.Current.Response.Write("Calling SAP function Error!<br>" & xmlLog & "<br>")
            Return 0
        Else
            'HttpContext.Current.Response.Write("xml:" & xmlInput & "<br>" & xmlout)

            If partNO.Contains("|") Then
                'HttpContext.Current.Response.Write("xml:" & xmlInput & "<br>" & xmlout)
                'Response.End()
                Dim tmpDt As DataTable = Util.ADOXml2DataTable(xmlout)
                'Dim gv1 As New WebControls.GridView
                'gv1.DataSource = tmpDt
                'gv1.DataBind()
                'HttpContext.Current.Response.Write(SysUtil.GetHtmlOfControl(gv1))
                'Response.End()
                If Not tmpDt Is Nothing Then
                    Dim MaxDue As Date = Now()
                    Dim tmpItem() As String = Split(partNO, "|")
                    For Each item As String In tmpItem
                        'HttpContext.Current.Response.Write("handling:" + Trim(item) + "<br/>")
                        Try
                            Dim selDt As DataTable = tmpDt.Copy()
                            selDt.DefaultView.RowFilter = "part='" + Trim(item) + "' and qty_fulfill>=" + QTY
                            selDt = selDt.DefaultView.ToTable()
                            If selDt.Rows.Count > 0 Then
                                If DateDiff( _
                                DateInterval.Day, MaxDue, _
                                selDt.Rows(0).Item("date") _
                                ) > 0 Then
                                    MaxDue = selDt.Rows(0).Item("date")
                                    'HttpContext.Current.Response.Write(MaxDue.ToShortDateString() + "<br/>")
                                End If
                            Else
                                'jackie add 20071206 for Z1 issue
                                Dim tempMaxDue As Date = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), item, Today)
                                If DateDiff( _
                               DateInterval.Day, MaxDue, _
                               tempMaxDue _
                               ) > 0 Then
                                    MaxDue = tempMaxDue
                                    'HttpContext.Current.Response.Write(MaxDue.ToShortDateString() + "<br/>")
                                End If
                            End If
                        Catch ex As Exception
                            'HttpContext.Current.Response.Write(ex.ToString() + "<br/>")
                        End Try
                    Next
                    dueDate = MaxDue
                    'Response.End()
                Else
                    Dim MaxDue As Date = Now()
                    Dim tmpItem() As String = Split(partNO, "|")
                    For Each item As String In tmpItem
                        dueDate = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), item, Today)
                        If MaxDue < dueDate Then
                            MaxDue = dueDate
                        End If
                    Next
                End If
            Else
                Dim sr As System.IO.StringReader = New System.IO.StringReader(xmlout)
                Dim ds As New DataSet()
                Dim dv As New DataView()
                ds.ReadXml(sr)
                Dim dtZ1 As DataTable = ds.Tables("row")
                If dtZ1 Is Nothing Then
                    dueDate = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), partNO, Today)
                Else
                    Try
                        Dim flg As Boolean = False
                        For i As Integer = 0 To dtZ1.Rows.Count - 1
                            If CInt(QTY) <= CInt(dtZ1.Rows(i).Item("qty_atb").ToString()) Then
                                dueDate = dtZ1.Rows(i).Item("date").ToString()
                                flg = True
                                Exit For
                            End If
                        Next
                        If Not flg Then
                            dueDate = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), partNO, Today)
                            Return 1
                        End If
                        'If CInt(QTY) >= 99999 Then
                        '    dueDate = ds.Tables(ds.Tables.Count - 1).Rows(ds.Tables(ds.Tables.Count - 1).Rows.Count - 1).Item("date").ToString()
                        'End If
                    Catch ex As Exception
                        dueDate = System.DateTime.Today.ToString()
                    End Try
                    dueDate = Global_Inc.FormatDate(dueDate)
                End If
            End If
            Return 1
        End If
    End Function

    Public Shared Function DueDateTableFieldMapping(ByVal zssd_dt As Due_Date_Inquiry.ZSSD_04Table) As DataTable


        Dim table1 As DataTable = zssd_dt.ToADODataTable
        table1.Columns.Item("Vkorg").ColumnName = "entity"
        table1.Columns.Item("Matnr").ColumnName = "part"
        table1.Columns.Item("Werks").ColumnName = "site"
        table1.Columns.Item("Flag").ColumnName = "flag"
        ' table1.Columns.Add("date", Type.GetType("System.DateTime"))
        table1.Columns.Item("Due_Date").ColumnName = "date"
        table1.Columns.Item("Type").ColumnName = "type"
        table1.Columns.Item("Qty_Atb").ColumnName = "qty_atb"
        table1.Columns.Item("Av_Qty_Plt").ColumnName = "qty_atp"
        table1.Columns.Item("Menge").ColumnName = "qty_req"
        table1.Columns.Add("flag_scm", Type.GetType("System.Int32"))
        table1.Columns.Item("flag_scm").DefaultValue = 0
        table1.Columns.Add("due_date", Type.GetType("System.DateTime"))
        table1.Columns.Item("due_date").DefaultValue = "1999/12/31 12:00:00"
        table1.Columns.Add("due_date_scm", Type.GetType("System.DateTime"))
        table1.Columns.Item("due_date_scm").DefaultValue = "1999/12/31 12:00:00"
        table1.Columns.Add("atp_date_scm", Type.GetType("System.DateTime"))
        table1.Columns.Item("atp_date_scm").DefaultValue = "1999/12/31 12:00:00"
        Return table1
    End Function


    Public Shared Function GetITP(ByVal partno As String) As Double
        partno = Replace(UCase(Global_Inc.Format2SAPItem(partno)), "'", "")
        Dim currency As String = "EUR"
        Dim obj As Object = Nothing
        Dim ITPCompanyId As String = "UUAAESC"
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT b.kbetr as ITP "))
            .AppendLine(String.Format(" from saprdp.a545 a inner join saprdp.KONP b on a.KNUMH=b.KNUMH "))
            .AppendLine(String.Format(" WHERE rownum=1 and a.MANDT = '168' and b.mandt='168' AND a.KAPPL = 'V' AND a.KSCHL = 'ZPN0' AND a.VKORG = 'EU10' and a.waerk='EUR' "))
            .AppendLine(String.Format(" AND a.DATBI >= to_char(sysdate,'yyyymmdd') AND a.DATAB <= to_char(sysdate,'yyyymmdd')  "))
            .AppendLine(String.Format(" AND a.kunnr='{0}' and a.matnr='{1}' ", ITPCompanyId, partno))
        End With
        obj = OraDbUtil.dbExecuteScalar("SAP_PRD", sb.ToString())
        If obj IsNot Nothing AndAlso Double.TryParse(obj, 0) AndAlso CDbl(obj) > 0 Then Return CDbl(obj)
        obj = Nothing
        sb = New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT b.kbetr as ITP "))
            .AppendLine(String.Format(" from saprdp.a512 a inner join saprdp.KONP b on a.KNUMH=b.KNUMH  "))
            .AppendLine(String.Format(" WHERE rownum=1 and a.MANDT = '168' and b.mandt='168' AND a.KAPPL = 'V' AND a.KSCHL = 'ZPN0' AND a.VKORG = 'EU10' "))
            .AppendLine(String.Format(" AND a.DATBI >= to_char(sysdate,'yyyymmdd') AND a.DATAB <= to_char(sysdate,'yyyymmdd')  "))
            .AppendLine(String.Format(" AND a.kunnr='{0}' and a.matnr='{1}' ", ITPCompanyId, partno))
        End With
        obj = OraDbUtil.dbExecuteScalar("SAP_PRD", sb.ToString())
        If obj IsNot Nothing AndAlso Double.TryParse(obj, 0) AndAlso CDbl(obj) > 0 Then Return CDbl(obj)
        obj = Nothing
        sb = New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT b.kbetr as ITP  "))
            .AppendLine(String.Format(" from saprdp.a510 a inner join saprdp.KONP b on a.KNUMH=b.KNUMH inner join saprdp.kna1 c  "))
            .AppendLine(String.Format(" on a.KDKG1 = c.KDKG1 AND a.KDKG2 = c.KDKG2  AND a.KDKG3 = c.KDKG3  AND a.KDKG4 = c.KDKG4 "))
            .AppendLine(String.Format(" WHERE rownum=1 and a.MANDT = '168' and b.mandt='168' AND a.KAPPL = 'V' AND a.KSCHL = 'ZPN0' and c.kunnr='{0}' ", ITPCompanyId))
            .AppendLine(String.Format(" AND a.DATBI >= to_char(sysdate,'yyyymmdd') AND a.DATAB <= to_char(sysdate,'yyyymmdd')  "))
            .AppendLine(String.Format(" AND a.VKORG = 'EU10' AND a.KDGRP = '01'  "))
            .AppendLine(String.Format(" and b.LOEVM_KO = ' ' and a.matnr='{0}' ", partno))
        End With
        obj = OraDbUtil.dbExecuteScalar("SAP_PRD", sb.ToString())
        If obj IsNot Nothing AndAlso Double.TryParse(obj, 0) AndAlso CDbl(obj) > 0 Then Return CDbl(obj)
        obj = Nothing
        sb = New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT b.kbetr as ITP "))
            .AppendLine(String.Format(" from saprdp.a509 a inner join saprdp.KONP b on a.KNUMH=b.KNUMH  "))
            .AppendLine(String.Format(" WHERE rownum=1 and a.MANDT = '168' and b.mandt='168' AND a.KAPPL = 'V' AND a.KSCHL = 'ZPN0' AND a.VKORG = 'EU10' and a.waerk='{0}' ", currency))
            .AppendLine(String.Format(" AND a.DATBI >= to_char(sysdate,'yyyymmdd') AND a.DATAB <= to_char(sysdate,'yyyymmdd')  "))
            .AppendLine(String.Format(" AND a.matnr='{0}' ", partno))
        End With
        obj = OraDbUtil.dbExecuteScalar("SAP_PRD", sb.ToString())
        If obj IsNot Nothing AndAlso Double.TryParse(obj, 0) AndAlso CDbl(obj) > 0 Then Return CDbl(obj)
        obj = Nothing
        sb = New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT b.kbetr as ITP "))
            .AppendLine(String.Format(" from saprdp.a531 a inner join saprdp.KONP b on a.KNUMH=b.KNUMH  "))
            .AppendLine(String.Format(" WHERE rownum=1 and a.MANDT = '168' and b.mandt='168' AND a.KAPPL = 'V' AND a.KSCHL = 'ZPN0' AND a.VKORG = 'EU10'  "))
            .AppendLine(String.Format(" AND a.DATBI >= to_char(sysdate,'yyyymmdd') AND a.DATAB <= to_char(sysdate,'yyyymmdd')  "))
            .AppendLine(String.Format(" AND a.matnr='{0}' ", partno))
        End With
        obj = OraDbUtil.dbExecuteScalar("SAP_PRD", sb.ToString())
        If obj IsNot Nothing AndAlso Double.TryParse(obj, 0) AndAlso CDbl(obj) > 0 Then Return CDbl(obj)
        Return Util.GetSAPPrice(partno, "UUAAESC")
    End Function

    Public Shared Function ExcelFile2DataTable(ByVal fs As String, ByVal startRow As Integer, ByVal startColumn As Integer) As DataTable
        SetASPOSELicense()
        Dim dt As New DataTable
        Try
            Dim wb As New Aspose.Cells.Workbook
            wb.Open(fs)

            For i As Integer = startColumn To wb.Worksheets(0).Cells.Columns.Count - 1
                If wb.Worksheets(0).Cells(0, i).Value IsNot Nothing AndAlso wb.Worksheets(0).Cells(0, i).Value.ToString <> "" Then
                    dt.Columns.Add(wb.Worksheets(0).Cells(0, i).Value)
                Else
                    Exit For
                End If
            Next
            For i As Integer = startRow To wb.Worksheets(0).Cells.Rows.Count - 1
                Dim r As DataRow = dt.NewRow
                For j As Integer = 0 To dt.Columns.Count - 1
                    r.Item(j) = wb.Worksheets(0).Cells(i, j).Value
                Next
                dt.Rows.Add(r)
            Next
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "error reading excel to dt", ex.ToString(), False, "", "")
            Return Nothing
        End Try
        Return dt
    End Function
    Public Shared Function ExcelFile2DataTable(ByVal fs As System.IO.Stream, ByVal startRow As Integer, ByVal startColumn As Integer) As DataTable
        SetASPOSELicense()
        Dim dt As New DataTable
        Try
            Dim wb As New Aspose.Cells.Workbook
            wb.Open(fs)

            'Frank 2012/05/17: wb.Worksheets(0).Cells.Columns.Count is not a good value to know how many columns with data in a work sheet.
            'Using MaxColumn instead of Columns.Count
            'For i As Integer = startColumn To wb.Worksheets(0).Cells.Columns.Count - 1
            For i As Integer = startColumn To wb.Worksheets(0).Cells.MaxColumn
                If wb.Worksheets(0).Cells(0, i).Value IsNot Nothing AndAlso wb.Worksheets(0).Cells(0, i).Value.ToString <> "" Then
                    dt.Columns.Add(wb.Worksheets(0).Cells(0, i).Value)
                Else
                    Exit For
                End If
            Next

            'Frank 2012/05/17: wb.Worksheets(0).Cells.Rows.Count is not a good value to know how many rows with data in a work sheet.
            'Using MaxRow instead of Rows.Count
            'For i As Integer = startRow To wb.Worksheets(0).Cells.Rows.Count - 1
            For i As Integer = startRow To wb.Worksheets(0).Cells.MaxRow
                Dim r As DataRow = dt.NewRow
                For j As Integer = 0 To dt.Columns.Count - 1
                    r.Item(j) = wb.Worksheets(0).Cells(i, j).Value
                Next
                dt.Rows.Add(r)
            Next
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "error reading excel to dt", ex.ToString(), False, "", "")
            Return Nothing
        End Try
        Return dt
    End Function
    Public Shared Function ExcelFile2DataTable(ByVal fs As String) As DataTable
        SetASPOSELicense()
        Dim dt As New DataTable
        Try
            Dim wb As New Aspose.Cells.Workbook
            wb.Open(fs)
            For i As Integer = 0 To 50
                If wb.Worksheets(0).Cells(0, i).Value IsNot Nothing AndAlso wb.Worksheets(0).Cells(0, i).Value.ToString <> "" Then
                    dt.Columns.Add(wb.Worksheets(0).Cells(0, i).Value)
                Else
                    Exit For
                End If
            Next
            For i As Integer = 0 To wb.Worksheets(0).Cells.Rows.Count - 1
                Dim r As DataRow = dt.NewRow
                For j As Integer = 0 To dt.Columns.Count - 1
                    r.Item(j) = wb.Worksheets(0).Cells(i, j).Value
                Next
                dt.Rows.Add(r)
            Next
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "error reading excel to dt", ex.ToString(), False, "", "")
            Return Nothing
        End Try
        Return dt
    End Function

    Public Shared Function ExcelFile2DataTable(ByVal fs As IO.Stream) As DataTable
        SetASPOSELicense()
        Dim dt As New DataTable

        Dim wb As New Aspose.Cells.Workbook
        wb.Open(fs)
        For i As Integer = 0 To 5
            If wb.Worksheets(0) IsNot Nothing AndAlso wb.Worksheets(0).Cells(0, i) IsNot Nothing _
             AndAlso wb.Worksheets(0).Cells(0, i).Value IsNot Nothing AndAlso wb.Worksheets(0).Cells(0, i).Value.ToString <> "" Then
                dt.Columns.Add(wb.Worksheets(0).Cells(0, i).Value)
            Else
                Exit For
            End If
        Next
        For i As Integer = 0 To wb.Worksheets(0).Cells.Rows.Count - 1
            Dim r As DataRow = dt.NewRow
            For j As Integer = 0 To dt.Columns.Count - 1
                r.Item(j) = wb.Worksheets(0).Cells(i, j).Value
            Next
            dt.Rows.Add(r)
        Next

        Return dt
    End Function

    Public Shared Function DataTable2ExcelFile(ByVal dt As DataTable, ByVal path As String) As Boolean
        SetASPOSELicense()
        'Try
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        For i As Integer = 0 To dt.Columns.Count - 1
            wb.Worksheets(0).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
        Next
        For i As Integer = 0 To dt.Rows.Count - 1
            For j As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j).ToString())
            Next
        Next
        wb.Save(path)
        'With HttpContext.Current.Response
        '    .Clear()
        '    .ContentType = "application/vnd.ms-excel"
        '    .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", path))
        '    Try
        '        .BinaryWrite(wb.SaveToStream().ToArray)
        '    Catch ex As Exception
        '        .End()
        '    End Try
        'End With

        Return True
    End Function
    Public Shared Function DataTable2ExcelStream(ByVal dt As DataTable) As IO.MemoryStream
        SetASPOSELicense()
        Try
            Dim wb As New Aspose.Cells.Workbook
            wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
            For i As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(0).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
            Next
            For i As Integer = 0 To dt.Rows.Count - 1
                For j As Integer = 0 To dt.Columns.Count - 1
                    If dt.Rows(i).Item(j).ToString.StartsWith("=") Then
                        wb.Worksheets(0).Cells(i + 1, j).Formula = dt.Rows(i).Item(j).ToString()
                    Else
                        wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j))
                    End If
                Next
            Next
            Return wb.SaveToStream()
            'wb.Save(path)
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
    Shared Function GetPdfBytesFromHtmlString(ByVal str As String) As Byte()
        'Dim urlToConvert As String = URL
        Dim selectablePDF As Boolean = True
        Dim pdfConverter As Winnovative.WnvHtmlConvert.PdfConverter = New Winnovative.WnvHtmlConvert.PdfConverter()
        pdfConverter.LicenseKey = "BC81JDUkNTYyJDAqNCQ3NSo1Nio9PT09"
        pdfConverter.PdfDocumentOptions.GenerateSelectablePdf = selectablePDF
        Dim pdfBytes As Byte() = pdfConverter.GetPdfBytesFromHtmlString(str)
        Return pdfBytes

    End Function
    Public Shared Sub HTML2PDF(ByVal URL As String)
        Dim license As Aspose.Pdf.License = New Aspose.Pdf.License()
        license.SetLicense(HttpContext.Current.Server.MapPath("~/Files/Aspose.Total.lic"))

        Dim myPDF As New Aspose.Pdf.Pdf
        myPDF.BindHTMLFromUrl(HttpContext.Current.Server.MapPath("/") & "/_vti_inf.html")
        myPDF.Save("C:\MYADVANTECH\TEST.PDF")
    End Sub
    Public Shared Sub DataTable2ExcelDownload(ByVal dt As DataTable, ByVal FileName As String)
        SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        For i As Integer = 0 To dt.Columns.Count - 1
            wb.Worksheets(0).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
        Next
        For i As Integer = 0 To dt.Rows.Count - 1
            For j As Integer = 0 To dt.Columns.Count - 1

                If IsDate(dt.Rows(i).Item(j)) Then
                    wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j).ToString)
                Else
                    wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j))
                End If


            Next
        Next
        With HttpContext.Current.Response
            'If FileName.StartsWith("AEUIT") = False Then FileName = "AEUIT_" + FileName
            .Clear()
            .ContentType = "application/vnd.ms-excel"
            .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", FileName))
            .BinaryWrite(wb.SaveToStream().ToArray)
        End With
    End Sub
    Public Shared Sub MultiDataTable2ExcelDownload(ByVal dts As DataTable(), ByVal FileName As String, ByVal SheetNames As String())
        SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        For x As Integer = 0 To dts.Length - 1
            Dim dt As DataTable = dts(x)
            wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
            wb.Worksheets(x).Name = SheetNames(x)
            For i As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(x).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
            Next
            For i As Integer = 0 To dt.Rows.Count - 1
                For j As Integer = 0 To dt.Columns.Count - 1
                    wb.Worksheets(x).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j).ToString())
                Next
            Next
        Next
        With HttpContext.Current.Response
            If FileName.StartsWith("AEUIT") = False Then FileName = "AEUIT_" + FileName
            .Clear()
            .ContentType = "application/vnd.ms-excel"
            .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", FileName))
            .BinaryWrite(wb.SaveToStream().ToArray)
        End With
    End Sub
    Public Shared Function MultiDataTable2ExcelStream(ByVal dts As DataTable(), ByVal SheetNames As String()) As IO.MemoryStream
        SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        For x As Integer = 0 To dts.Length - 1
            If dts(x) IsNot Nothing AndAlso SheetNames(x) IsNot Nothing Then
                Dim dt As DataTable = dts(x)
                wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
                wb.Worksheets(x).Name = SheetNames(x)
                For i As Integer = 0 To dt.Columns.Count - 1
                    wb.Worksheets(x).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
                Next
                For i As Integer = 0 To dt.Rows.Count - 1
                    For j As Integer = 0 To dt.Columns.Count - 1
                        If Integer.TryParse(dt.Rows(i).Item(j), 0) OrElse Double.TryParse(dt.Rows(i).Item(j), 0) Then
                            wb.Worksheets(x).Cells(i + 1, j).PutValue(CDbl(dt.Rows(i).Item(j)))
                        Else
                            wb.Worksheets(x).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j).ToString())
                        End If

                    Next
                Next
            End If
        Next
        Return wb.SaveToStream()
    End Function

    Public Shared Sub DataTable2PivotExcelDownload( _
    ByVal dt As DataTable, ByVal RowFields As String, ByVal ColumnFields As String, _
    ByVal DataFields As String, ByVal FileName As String)
        SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        For i As Integer = 0 To dt.Columns.Count - 1
            wb.Worksheets(1).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
        Next
        For i As Integer = 0 To dt.Rows.Count - 1
            For j As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(1).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j))
            Next
        Next
        Dim pivotTables As Aspose.Cells.PivotTables = wb.Worksheets(0).PivotTables
        Dim index As Integer = pivotTables.Add("=Sheet2!A1:" + GetAlphabetBySeq(dt.Columns.Count - 1) + (dt.Rows.Count + 1).ToString(), "A1", "Sheet1")
        Dim pivotTable As Aspose.Cells.PivotTable = pivotTables(index)
        With pivotTable
            Dim RowFieldsSet() As String = Split(RowFields, "|"), ColFieldsSet() As String = Split(ColumnFields, "|"), DataFieldsSet() As String = Split(DataFields, "|")
            For Each f As String In RowFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Row, f)
            Next
            For Each f As String In ColFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Column, f)
            Next
            For Each f As String In DataFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Data, f)
            Next
            For i As Integer = 0 To .RowFields.Count - 1
                '.RowFields(i).AutoSortField = True
                '.RowFields(i).IsAscendSort = True
            Next
            For i As Integer = 0 To .ColumnFields.Count - 1
                '.ColumnFields(i).AutoSortField = True
                .ColumnFields(i).IsAscendSort = True
            Next
        End With

        With HttpContext.Current.Response
            If FileName.StartsWith("AEUIT") = False Then FileName = "AEUIT_" + FileName
            .Clear()
            .ContentType = "application/vnd.ms-excel"
            .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", FileName))
            Try
                .BinaryWrite(wb.SaveToStream().ToArray)
            Catch ex As Exception
                .End()
            End Try
        End With
        'End If
    End Sub

    Public Shared Sub DataTable2PivotExcel2007Download( _
    ByVal dt As DataTable, ByVal RowFields As String, ByVal ColumnFields As String, _
    ByVal DataFields As String, ByVal FileName As String)
        SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        For i As Integer = 0 To dt.Columns.Count - 1
            wb.Worksheets(1).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
        Next
        For i As Integer = 0 To dt.Rows.Count - 1
            For j As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(1).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j))
            Next
        Next
        Dim pivotTables As Aspose.Cells.PivotTables = wb.Worksheets(0).PivotTables
        Dim index As Integer = pivotTables.Add("=Sheet2!A1:" + GetAlphabetBySeq(dt.Columns.Count - 1) + (dt.Rows.Count + 1).ToString(), "A1", "Sheet1")
        Dim pivotTable As Aspose.Cells.PivotTable = pivotTables(index)
        With pivotTable
            Dim RowFieldsSet() As String = Split(RowFields, "|"), ColFieldsSet() As String = Split(ColumnFields, "|"), DataFieldsSet() As String = Split(DataFields, "|")
            For Each f As String In RowFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Row, f)
            Next
            For Each f As String In ColFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Column, f)
            Next
            For Each f As String In DataFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Data, f)
            Next
            For i As Integer = 0 To .RowFields.Count - 1
                '.RowFields(i).AutoSortField = True
                '.RowFields(i).IsAscendSort = True
            Next
            For i As Integer = 0 To .ColumnFields.Count - 1
                '.ColumnFields(i).AutoSortField = True
                .ColumnFields(i).IsAscendSort = True
            Next
        End With

        With HttpContext.Current.Response
            'If FileName.StartsWith("AEUIT") = False Then FileName = "AEUIT_" + FileName
            .Clear()
            .ContentType = "application/vnd.ms-excel"
            .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", FileName))
            .BinaryWrite(wb.SaveToStream().ToArray)
        End With

        'If FileName.StartsWith("AEUIT") = False Then FileName = "AEUIT_" + FileName
        'FileName = "C:\DataMining\Files\temp\" + HttpContext.Current.Session.SessionID + "_" + FileName
        'wb.Save(FileName, Aspose.Cells.FileFormatType.Excel2007Xlsx)
        'With HttpContext.Current.Response
        '    .Redirect(Replace(Replace(FileName, "C:\DataMining", ""), "\", "/"), False)
        'End With

    End Sub

    Public Shared Function DataTable2PivotExcelStream( _
   ByVal dt As DataTable, ByVal RowFields As String, ByVal ColumnFields As String, _
   ByVal DataFields As String) As Byte()
        SetASPOSELicense()
        Dim wb As New Aspose.Cells.Workbook
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
        For i As Integer = 0 To dt.Columns.Count - 1
            wb.Worksheets(1).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
        Next
        For i As Integer = 0 To dt.Rows.Count - 1
            For j As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(1).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j))
            Next
        Next
        Dim pivotTables As Aspose.Cells.PivotTables = wb.Worksheets(0).PivotTables
        Dim index As Integer = pivotTables.Add("=Sheet2!A1:" + GetAlphabetBySeq(dt.Columns.Count - 1) + (dt.Rows.Count + 1).ToString(), "A1", "Sheet1")
        Dim pivotTable As Aspose.Cells.PivotTable = pivotTables(index)
        With pivotTable
            Dim RowFieldsSet() As String = Split(RowFields, "|"), ColFieldsSet() As String = Split(ColumnFields, "|"), DataFieldsSet() As String = Split(DataFields, "|")
            For Each f As String In RowFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Row, f)
            Next
            For Each f As String In ColFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Column, f)
            Next
            For Each f As String In DataFieldsSet
                .AddFieldToArea(Aspose.Cells.PivotFieldType.Data, f)
            Next
            'For i As Integer = 0 To .RowFields.Count - 1
            '    .RowFields(i).SetSubtotals(Aspose.Cells.PivotFieldSubtotalType.Sum, True)
            'Next
            'For i As Integer = 0 To .ColumnFields.Count - 1
            '    .ColumnFields(i).SetSubtotals(Aspose.Cells.PivotFieldSubtotalType.Sum, True)
            'Next
        End With
        Return wb.SaveToStream().ToArray()
    End Function

    Public Shared Function GetAlphabetBySeq(ByVal idx As Integer) As String
        Dim ab() As String = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AP", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ", "BA", "BB", "BC", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BK", "BL", "BM", "BN", "BO", "BP", "BP", "BR", "BS", "BT", "BU", "BV", "BW", "BX", "BY", "BZ"}
        If idx <= 77 Then Return ab(idx)
        Return "AA"
    End Function
    Public Shared Function isCtosAdmin() As Boolean
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
           OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False
        Dim uid As String = HttpContext.Current.Session("user_id").ToString().ToLower()
        Dim f As Boolean = False

        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim str As String = String.Format("select email from CTOSADMIN where email='{0}' and org='{1}'", uid, HttpContext.Current.Session("org").ToString().ToUpper)
        Dim str As String = String.Format("select email from CTOSADMIN where email='{0}' and org='{1}'", uid, Left(HttpContext.Current.Session("org_id").ToString().ToUpper, 2))

        'HttpContext.Current.Response.Write(str)
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("MY", str)
        If dt.Rows.Count > 0 Then
            f = True
        End If
        Return f
    End Function
    Public Shared Function IsAEUIT() As Boolean
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
            OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False
        Dim uid As String = HttpContext.Current.Session("user_id").ToString().ToLower()
        Dim adminList As New ArrayList
        With adminList
            .Add("emil.hsu@advantech.eu")
            .Add("tc.chen@advantech.com.tw") : .Add("tc.chen@advantech.de") : .Add("yl.huang@advantech.com.tw")
            .Add("tc.chen@advantech.eu") : .Add("ming.zhao@advantech.com.cn") : .Add("frank.chung@advantech.com.tw")
            .Add("ic.chen@advantech.com.tw") : .Add("rudy.wang@advantech.com.tw") : .Add("jay.lee@advantech.com")
        End With
        If adminList.Contains(uid) Then
            Return True
        End If
        Return False
    End Function


    Public Shared Function IsAEUUser() As Boolean
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
            OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False
        Dim domain As String = HttpContext.Current.Session("user_id").ToString().ToLower().Split("@")(1)
        Dim adminList As New ArrayList
        With adminList
            .Add("advantech.pl") : .Add("advantech.it") : .Add("advantech.fr") : .Add("advantech.gr")
            .Add("advantech-nl.nl") : .Add("advantech-uk.com") : .Add("advantech.de")
            .Add("advantech.nl") : .Add("advantech.eu")
        End With
        If adminList.Contains(domain) Then
            Return True
        End If

        'Ryan 20170106 PL office users' domain has change to @advantech.com, original logic is not enough
        If MailUtil.IsInRole2("EMPLOYEE.APL", HttpContext.Current.Session("user_id").ToString()) Then
            Return True
        End If

        Return False
    End Function

    Public Shared Function IsANAPowerUser() As Boolean
        Return IsAdmin()
        'If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") Is Nothing _
        '    OrElse HttpContext.Current.Session("user_id").ToString() = "" Then Return False
        'Dim uid As String = HttpContext.Current.Session("user_id").ToString().ToLower()
        'Dim adminList As New ArrayList
        'With adminList
        '    .Add("lynette.andersen@advantech.com") : .Add("john.liou@advantech.com")
        '    .Add("ednag@advantech.com") : .Add("feik@advantech.com")
        '    .Add("tc.chen@advantech.com.tw") : .Add("ming.zhao@advantech.com.cn")
        '    .Add("charles.chi@advantech.com.tw") : .Add("charles.chi@advantech.com")
        'End With
        'If adminList.Contains(uid) Then
        '    Return True
        'End If
        'Return False
    End Function

    Public Shared Sub SetASPOSELicense()
        Try
            Dim license As Aspose.Cells.License = New Aspose.Cells.License()
            Dim strFPath As String = HttpContext.Current.Server.MapPath("~/Files/Aspose.Total.lic")
            If IO.File.Exists(strFPath) = False Then strFPath = "C:\MyAdvantech\Files\Aspose.Total.lic"
            license.SetLicense(strFPath)
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "MY GLOBAL: setting aspose license error", ex.ToString(), False, "", "")
        End Try
    End Sub

    Public Shared Function GetMD5Checksum(ByVal source As String) As String
        Dim md5Hasher As System.Security.Cryptography.MD5CryptoServiceProvider = System.Security.Cryptography.MD5CryptoServiceProvider.Create()

        ' Convert the input string to a byte array and compute the hash.
        Dim data As Byte() = md5Hasher.ComputeHash(Encoding.Unicode.GetBytes(source))

        ' Create a new Stringbuilder to collect the bytes
        ' and create a string.
        Dim sBuilder As New StringBuilder()

        ' Loop through each byte of the hashed data 
        ' and format each one as a hexadecimal string.
        Dim i As Integer
        For i = 0 To data.Length - 1
            sBuilder.Append(data(i).ToString("x2"))
        Next i

        ' Return the hexadecimal string.
        Return sBuilder.ToString()

        'Dim hashValue = (New System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash(Encoding.UTF8.GetBytes(source))
        'Dim buff As New StringBuilder
        'For Each hashByte As Byte In hashValue
        '    buff.Append(String.Format("{0:x2}", hashByte))
        'Next
        'Return buff.ToString()
    End Function

    Public Enum SAPCURRENCY
        AUD
        BRL
        CNY
        EUR
        GBP
        JPY
        KRW
        MYR
        SGD
        TWD
        USD
    End Enum

    Shared Function CURR2SAPCURR(ByVal CURR As String) As SAPCURRENCY
        Select Case CURR
            Case "AUD"
                Return SAPCURRENCY.AUD
            Case "BRL"
                Return SAPCURRENCY.BRL
            Case "CNY"
                Return SAPCURRENCY.CNY
            Case "EUR"
                Return SAPCURRENCY.EUR
            Case "GBP"
                Return SAPCURRENCY.GBP
            Case "JPY"
                Return SAPCURRENCY.JPY
            Case "KRW"
                Return SAPCURRENCY.KRW
            Case "MYR"
                Return SAPCURRENCY.MYR
            Case "SGD"
                Return SAPCURRENCY.SGD
            Case "TWD"
                Return SAPCURRENCY.TWD
            Case "USD"
                Return SAPCURRENCY.USD
        End Select
        Return SAPCURRENCY.USD
    End Function

    Shared Sub AjaxJSAlert(ByVal page As Page, ByVal p2 As String)
        Throw New NotImplementedException
    End Sub

    Public Shared Function SyncContactFromSiebel(ByVal RowId As String) As Boolean
        Try
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact where row_id='{0}'", RowId))
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT  A.ROW_ID,  " + _
              "IsNull(A.FST_NAME, '') AS 'FirstName',   " + _
              "IsNull(A.MID_NAME, '') as 'MiddleName',  " + _
              "IsNull(A.LAST_NAME, '') AS 'LastName',   " + _
              "IsNull(A.WORK_PH_NUM, '') as 'WorkPhone',  " + _
              "IsNull(A.CELL_PH_NUM, '') as 'CellPhone',   " + _
              "IsNull(A.FAX_PH_NUM, '') as 'FaxNumber',   " + _
              "IsNull(E.ATTRIB_37, '') as 'JOB_FUNCTION', " + _
              "IsNull(A.PAR_ROW_ID, '') as PAR_ROW_ID,  " + _
              "IsNull(D.ATTRIB_05, '') AS 'ERPID',  " + _
              "IsNull(A.BU_ID, '') as 'PriOrgId',  " + _
              "(select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) as 'OrgID',   " + _
              "IsNull(A.PR_POSTN_ID, '') as 'OwnerId',  " + _
              "IsNull(E.ATTRIB_09, 'N') AS 'CanSeeOrder',  " + _
              "IsNull(A.X_CONTACT_LOGIN_PASSWORD, '') AS Password,   " + _
              "'' as 'Sales_Rep',   " + _
              "IsNull(A.SUPPRESS_EMAIL_FLG, '') as NeverEmail,  " + _
              "IsNull(A.SUPPRESS_CALL_FLG,'') as NeverCall,  " + _
              "IsNull(A.SUPPRESS_FAX_FLG, '') as NeverFax,  " + _
              "IsNull(A.SUPPRESS_MAIL_FLG, '') as NeverMail,   " + _
              "IsNull(A.JOB_TITLE, '') as JOB_TITLE,   " + _
              "IsNull(A.EMAIL_ADDR, '') AS 'EMAIL_ADDRESS',   " + _
              "A.COMMENTS, B.ROW_ID as ACCOUNT_ROW_ID,  " + _
              "IsNull(B.NAME, '') AS ACCOUNT,   " + _
              "IsNull(B.OU_TYPE_CD, '') AS 'ACCOUNT_TYPE',   " + _
              "IsNull(B.CUST_STAT_CD, '') AS 'ACCOUNT_STATUS',   " + _
              "IsNull(C.COUNTRY, '') AS COUNTRY,  " + _
              "IsNull(A.PER_TITLE, '') as Salutation,  " + _
              "A.EMP_FLG as EMPLOYEE_FLAG,  " + _
              "IsNull(A.ACTIVE_FLG,'N') as ACTIVE_FLG,  " + _
              "IsNull(A.DFLT_ORDER_PROC_CD,'') as User_Type,  " + _
              "IsNull(F.APPL_SRC_CD,'') as Reg_Source,  " + _
              "A.CREATED,  " + _
              "A.LAST_UPD as LAST_UPDATED, A.PR_REP_SYS_FLG as PRIMARY_FLAG   " + _
              "FROM S_CONTACT A LEFT JOIN S_CONTACT_X E ON A.ROW_ID = E.ROW_ID   " + _
              "LEFT JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID   " + _
              "LEFT JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID   " + _
              "LEFT JOIN S_ADDR_PER C ON A.PR_OU_ADDR_ID = C.ROW_ID   " + _
              "LEFT JOIN S_PER_PRTNRAPPL F ON A.ROW_ID=F.ROW_ID  " + _
              "WHERE (A.ROW_ID = A.PAR_ROW_ID) and A.ROW_ID='{0}'", RowId))
            If dt.Rows.Count > 0 Then
                Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                BCopy.DestinationTableName = "SIEBEL_CONTACT"
                BCopy.WriteToServer(dt)
            End If
            'ICC 2015/7/6 No longer sync privilege data from SIEBEL
            'dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact_privilege where row_id='{0}'", RowId))
            'dt = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT a.PAR_ROW_ID as ROW_ID, b.EMAIL_ADDR as EMAIL_ADDRESS, " + _
            '        "IsNull((select top 1 z.VAL from S_LST_OF_VAL z where z.TYPE = 'CONTACT_MYADVAN_PVLG' and z.ROW_ID=a.NAME),'N/A') as PRIVILEGE  " + _
            '        "FROM S_CONTACT_XM a inner join S_CONTACT b on a.PAR_ROW_ID=b.ROW_ID " + _
            '        "WHERE a.TYPE = 'CONTACT_MYADVAN_PVLG' and a.PAR_ROW_ID='{0}'", RowId))
            'If dt.Rows.Count > 0 Then
            '    Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            '    BCopy.DestinationTableName = "SIEBEL_CONTACT_PRIVILEGE"
            '    BCopy.WriteToServer(dt)
            'End If
            Return True
        Catch ex As Exception
            Return False
        End Try

    End Function

    Public Shared Function SyncContactFromSiebelByEmail(ByVal email As String) As Boolean
        Try
            Dim sb As New StringBuilder
            With sb
                .AppendFormat("SELECT  A.ROW_ID, IsNull(A.FST_NAME, '') AS 'FirstName',IsNull(A.MID_NAME, '') as 'MiddleName', IsNull(A.LAST_NAME, '') AS 'LastName', ")
                .AppendFormat("IsNull(A.WORK_PH_NUM, '') as 'WorkPhone',IsNull(A.CELL_PH_NUM, '') as 'CellPhone',IsNull(A.FAX_PH_NUM, '') as 'FaxNumber', ")
                .AppendFormat("IsNull(E.ATTRIB_37, '') as 'JOB_FUNCTION', IsNull(A.PAR_ROW_ID, '') as PAR_ROW_ID,IsNull(D.ATTRIB_05, '') AS 'ERPID', ")
                .AppendFormat("IsNull(A.BU_ID, '') as 'PriOrgId',(select top 1 z.NAME from S_PARTY z where z.ROW_ID=A.BU_ID) as 'OrgID', ")
                .AppendFormat("IsNull(A.PR_POSTN_ID, '') as 'OwnerId',IsNull(E.ATTRIB_09, 'N') AS 'CanSeeOrder',IsNull(A.X_CONTACT_LOGIN_PASSWORD, '') AS Password,")
                .AppendFormat("'' as 'Sales_Rep',IsNull(A.SUPPRESS_EMAIL_FLG, '') as NeverEmail,IsNull(A.SUPPRESS_CALL_FLG,'') as NeverCall,")
                .AppendFormat("IsNull(A.SUPPRESS_FAX_FLG, '') as NeverFax,IsNull(A.SUPPRESS_MAIL_FLG, '') as NeverMail,IsNull(A.JOB_TITLE, '') as JOB_TITLE,")
                .AppendFormat("IsNull(A.EMAIL_ADDR, '') AS 'EMAIL_ADDRESS',B.ROW_ID as ACCOUNT_ROW_ID,IsNull(B.NAME, '') AS ACCOUNT,IsNull(B.OU_TYPE_CD, '') AS 'ACCOUNT_TYPE', ")
                .AppendFormat("IsNull(B.CUST_STAT_CD, '') AS 'ACCOUNT_STATUS',IsNull(C.COUNTRY, '') AS COUNTRY,IsNull(A.PER_TITLE, '') as Salutation,")
                .AppendFormat("A.EMP_FLG as EMPLOYEE_FLAG,IsNull(A.ACTIVE_FLG,'N') as ACTIVE_FLG,IsNull(A.DFLT_ORDER_PROC_CD,'') as User_Type, IsNull(F.APPL_SRC_CD,'') as Reg_Source,")
                .AppendFormat("A.CREATED, A.LAST_UPD as LAST_UPDATED, A.PR_REP_SYS_FLG as PRIMARY_FLAG   ")
                .AppendFormat("FROM S_CONTACT A LEFT JOIN S_CONTACT_X E ON A.ROW_ID = E.ROW_ID LEFT JOIN S_ORG_EXT B ON A.PR_DEPT_OU_ID = B.PAR_ROW_ID ")
                .AppendFormat("LEFT JOIN S_ORG_EXT_X D ON B.ROW_ID = D.ROW_ID LEFT JOIN S_ADDR_PER C ON A.PR_OU_ADDR_ID = C.ROW_ID LEFT JOIN S_PER_PRTNRAPPL F ON A.ROW_ID=F.ROW_ID ")
                .AppendFormat("WHERE A.ROW_ID = A.PAR_ROW_ID and upper(A.EMAIL_ADDR) = '{0}'", email.Trim.ToUpper())
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("CRMDB75", sb.ToString)
            dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact where email_address='{0}'", email.Trim))
            Dim BCopy As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            BCopy.DestinationTableName = "SIEBEL_CONTACT"
            BCopy.WriteToServer(dt)
            'ICC 2015/7/6 No longer sync privilege data from SIEBEL
            'dbUtil.dbExecuteNoQuery("MY", String.Format("delete from siebel_contact_privilege where EMAIL_ADDRESS ='{0}'", email.Trim))
            'dt = dbUtil.dbGetDataTable("CRMDB75", String.Format("SELECT a.PAR_ROW_ID as ROW_ID, b.EMAIL_ADDR as EMAIL_ADDRESS, " + _
            '        "IsNull((select top 1 z.VAL from S_LST_OF_VAL z where z.TYPE = 'CONTACT_MYADVAN_PVLG' and z.ROW_ID=a.NAME),'N/A') as PRIVILEGE  " + _
            '        "FROM S_CONTACT_XM a inner join S_CONTACT b on a.PAR_ROW_ID=b.ROW_ID " + _
            '        "WHERE a.TYPE = 'CONTACT_MYADVAN_PVLG' and upper(b.EMAIL_ADDR) ='{0}'", email.Trim.ToUpper()))
            'If dt.Rows.Count > 0 Then
            '    Dim BCopy1 As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            '    BCopy1.DestinationTableName = "SIEBEL_CONTACT_PRIVILEGE"
            '    BCopy1.WriteToServer(dt)
            'End If
            Return True
        Catch ex As Exception
            'Util.SendTestEmail("error", ex.ToString)
            Return False
        End Try

    End Function

    Public Shared Function GetLANGLiT_text(ByVal Unique_ID As String) As String
        If HttpContext.Current.Session("LanG") IsNot Nothing AndAlso HttpContext.Current.Session("LanG").ToString() <> "" Then
            Dim lang As String = HttpContext.Current.Session("LanG").ToString.Trim.ToUpper
            If lang = "ENG" Then
                Return ""
            End If
            Dim DT As DataTable = dbUtil.dbGetDataTable("my", "select Unique_ID,ENG,CHS,CHT,JAP,KOR from MY_MULTI_LANG WHERE Unique_ID ='" + Unique_ID + "'")
            If DT.Rows.Count > 0 Then
                If Not IsDBNull(DT.Rows(0).Item(lang)) Then
                    Return DT.Rows(0).Item(lang).ToString.Trim
                End If
            End If
        End If

        Return ""
    End Function
    Public Shared Function IsHotSelling(ByVal part_no As String, ByVal Org As String) As Boolean
        If Org <> "US" Then
            Return False
        End If

        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select * from MYADVANTECH_PRODUCT_PROMOTION where Part_no='{0}' and active_flag=1", part_no))
        If dt.Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function IsFastDelivery(ByVal part_no As String, ByVal Org As String) As Boolean
        If Org <> "US" Then
            Return False
        End If

        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select Part_no from MYADVANTECH_PRODUCT_FAST_DELIVERY where Part_no='{0}' and active_flag=1", part_no))
        If dt.Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function
    Shared Function IsAEUIT(ByVal p1 As Object) As Boolean
        Throw New NotImplementedException
    End Function

    'Public Shared Sub SendTestEmail(ByVal Subject As String, ByVal Content As String)
    '    Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", Subject, Content, True, "", "")
    'End Sub

    Public Shared Function IsValidDateFormat(ByVal strDate As String) As Boolean
        If Date.TryParseExact(strDate, "yyyy/MM/dd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Date.MaxValue) _
            OrElse Date.TryParseExact(strDate, "yyyy/M/d", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Date.MaxValue) _
            OrElse Date.TryParseExact(strDate, "MM/dd/yyyy", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Date.MaxValue) _
            OrElse Date.TryParseExact(strDate, "dd/MM/yyyy", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Date.MaxValue) Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function IsFranchiser(ByVal email As String, ByRef strCompanyId As String) As Boolean
        Return SAPDAL.SAPDAL.IsFranchiser(email, strCompanyId)
        'If email.EndsWith("@advantech.com", StringComparison.InvariantCultureIgnoreCase) Then
        '    Dim _myaccda As New MyAccountDSTableAdapters.FRANCHISERTableAdapter
        '    Dim _dt As MyAccountDS.FRANCHISERDataTable = _myaccda.GetDataByEMail(email)
        '    If _dt.Count > 0 Then
        '        strCompanyId = _dt(0).COMPANY_ID : Return True
        '    End If
        'End If
        'Return False
    End Function
    Public Shared Function IsPCP_Marcom(ByVal email As String, ByRef strCompanyId As String) As Boolean
        Dim MyDC As New MyChampionClubDataContext
        Dim PCP_Marcom As ChampionClub_PCP_Marcom = MyDC.ChampionClub_PCP_Marcoms.Where(Function(P) P.UserID = email).FirstOrDefault
        If PCP_Marcom IsNot Nothing Then
            strCompanyId = PCP_Marcom.CompanyID
            Return True
        End If
        Return False
    End Function
    'Public Shared Function IsAINUser(ByVal email As String) As Boolean
    '    email = LCase(email)
    '    If email = "suruchi.s@advantech.com" OrElse email = "sukumar.s@advantech.com" _
    '        OrElse email = "devendra.s@advantech.com" OrElse email = "ranveer.c@advantech.com" _
    '        OrElse email = "james.kou@advantech.com" OrElse email = "mohit.kumawat@advantech.com" Then
    '        Return True
    '    Else
    '        Return False
    '    End If
    'End Function

    'JJ 2014/6/3 ChampionClub_Admin當年度必須有參加
    Public Shared Function IsAdminUser() As Boolean
        If HttpContext.Current.Session("COMPANY_ID") IsNot Nothing Then
            If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(rowID) from ChampionClub_Admin where userID='{0}' and year={1}", HttpContext.Current.User.Identity.Name, CStr(Now.Year)))) > 0 Then Return True
        End If
        Return False
    End Function


    Public Shared Function IsPCPUser() As Boolean
        If HttpContext.Current.Session("COMPANY_ID") IsNot Nothing Then
            If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(company_id) from pcp_account where company_id='{0}'", HttpContext.Current.Session("COMPANY_ID")))) > 0 Then Return True
        End If
        Return False
    End Function

    'JJ 2014/3/10 home頁只要是下列company ID的就隱藏
    Public Shared Function NoShowProjectRegistrationUser(ByVal ERPID As String) As Boolean

        Dim strArr As String() = {"EURA004", "EGBR001", "ELVE001", "ELTG002", "EKZI003", "AHKP006", "ERUP002", "EURP001", "EURP011", "EUAJ001", "EURS006"}
        If Array.IndexOf(strArr, ERPID) >= 0 Then
            Return True
        End If

        Return False
    End Function

    Public Shared Function GetRegistEmailStr(ByVal FirstName As String, ByVal Email As String, ByVal PassWord As String, ByVal HTTP_HOST As String) As String
        Dim l_strHTML As String = ""
        l_strHTML = l_strHTML & "<html xmlns=""http://www.w3.org/1999/xhtml"">"
        l_strHTML = l_strHTML & "<body><table  width=""900"" border=""0"" cellspacing=""0"" cellpadding=""0"" style=""font-family:Arial Unicode MS""><tr><td>"
        l_strHTML = l_strHTML & "<img alt="""" src=""http://my-global.advantech.eu/Images/logo2.jpg"" /><br/></td>"
        l_strHTML = l_strHTML & "</tr><tr><td>"
        l_strHTML = l_strHTML & "Dear " & Trim(FirstName) & ",</td>"
        l_strHTML = l_strHTML & "</tr><tr><td>"
        l_strHTML = l_strHTML & "Welcome to MyAdvantech, your 360 self-service portal to Advantech.  This portal provides you quick access to your account information where you can view Advantech product and order information, order online, download resources, watch videos, and much more."
        l_strHTML = l_strHTML & "</td></tr>"
        l_strHTML = l_strHTML & "<tr><td height=""25"">"
        l_strHTML = l_strHTML & "Use the below login information to begin enjoying MyAdvantech, your personalized Advantech portal.</td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr><td height=""25"">"
        l_strHTML = l_strHTML & "Step 1: Go to the MyAdvantech "
        l_strHTML = l_strHTML & "<a href=""http://" + HTTP_HOST + "/home.aspx"" "
        l_strHTML = l_strHTML & "title=" + HTTP_HOST + "><span style=""color:#000099"">login</span></a> "
        l_strHTML = l_strHTML & " page.</td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr><td height=""25"">"
        l_strHTML = l_strHTML & "Step 2: Enter your ID and Password (provided below).</td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr><td><br>"
        l_strHTML = l_strHTML & "<table style="" width: 80.0%;background: silver;font-family:Arial Unicode MS"" border=""0"" cellspacing=""0""  cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""width: 150px ;background: #EEEEEE;border-right:solid 1px #cccccc"">ID(Email Address):</td><td style=""background: #EEEEEE""><span style=""color:navy""> &nbsp;" & Trim(Email) & "</span></td></tr>"
        l_strHTML = l_strHTML & "<tr><td  align=""center""style=""background: #D9D9D9;border-right:solid 1px #cccccc"">Password:</td> <td style=""background: #D9D9D9""><span style=""color:navy""> &nbsp;" & Trim(PassWord) & "</span></td></tr>"
        l_strHTML = l_strHTML & "</table></td></tr> <tr><td><br>"
        l_strHTML = l_strHTML & "<font color=""#404040"">To change password, please click on the link to update our  "
        l_strHTML = l_strHTML & "<a href=""http://" + HTTP_HOST + "/my/myprofile.aspx"" "
        l_strHTML = l_strHTML & "title=" + HTTP_HOST + "/My/MyProfile.aspx" + "><span style=""color:#000099"">profile</span></a> "
        l_strHTML = l_strHTML & " once logged into MyAdvantech. "

        l_strHTML = l_strHTML & "<br><br>If you have any questions about this portal, please contact your Advantech account manager "
        l_strHTML = l_strHTML & "<br><br><em>* Please note all information posted within the MyAdvantech portal is company confidential data.</em></font></td>"
        l_strHTML = l_strHTML & "</tr><tr><td></td> </tr>"
        l_strHTML = l_strHTML & "</table>"
        l_strHTML = l_strHTML & "</body>"
        l_strHTML = l_strHTML & "</html>"
        Return l_strHTML
    End Function

    Public Shared Function GetPTList() As ArrayList
        Dim arrPT As New ArrayList
        With arrPT
            .Add("96CA") : .Add("96CF") : .Add("96FM") : .Add("96HD") : .Add("96IDK")
            .Add("96KB") : .Add("96MM") : .Add("96MP") : .Add("96MT") : .Add("96OD")
            .Add("96OT") : .Add("96SS") : .Add("96SW") : .Add("PTRADE") : .Add("ZCN")
            .Add("ZHDO") : .Add("ZTW") : .Add("ZZ")
        End With
        Return arrPT
    End Function

    Public Shared Function GetUserBaa() As ArrayList
        Dim arrBaa As New ArrayList
        If HttpContext.Current.User.Identity.Name Is Nothing OrElse HttpContext.Current.User.Identity.Name = String.Empty Then Return arrBaa
        Dim strSql As String = _
            String.Format( _
            " select b.BAA  " + _
            " from SIEBEL_CONTACT a inner join SIEBEL_ACCOUNT_BAA b on a.ACCOUNT_ROW_ID=b.ACCOUNT_ROW_ID  " + _
            " where a.EMAIL_ADDRESS='{0}' " + _
            " union " + _
            " select b.NAME as BAA " + _
            " from SIEBEL_CONTACT a inner join SIEBEL_CONTACT_BAA b on a.ROW_ID=b.CONTACT_ROW_ID   " + _
            " where a.EMAIL_ADDRESS='{0}' ", HttpContext.Current.User.Identity.Name)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
        If arrBaa.Contains("N'Home Automation'") Then
            arrBaa.Add("N'Building Automation'")
        Else
            If arrBaa.Contains("N'Building Automation'") Then
                arrBaa.Add("N'Home Automation'")
            End If
        End If
        If arrBaa.Contains("N'Factory Automation'") Then
            arrBaa.Add("N'Machine Automation'")
        Else
            If arrBaa.Contains("N'Machine Automation'") Then
                arrBaa.Add("N'Factory Automation'")
            End If
        End If
        Return arrBaa
    End Function

    Public Shared Function GetRuntimeSiteUrl() As String
        With HttpContext.Current
            'Ryan 20180226 Check if url return should start with http or https
            Return String.Format("{0}://{1}{2}{3}",
                                 IIf(HttpContext.Current.Request.IsSecureConnection, "https", "http"),
                                 .Request.ServerVariables("SERVER_NAME"),
                                 IIf(.Request.ServerVariables("SERVER_PORT") = "80", "", ":" + .Request.ServerVariables("SERVER_PORT")),
                                 IIf(HttpRuntime.AppDomainAppVirtualPath = "/", "", HttpRuntime.AppDomainAppVirtualPath))
        End With

    End Function

    Public Shared Sub InsertMyErrLog(ByRef strEx As String)

        'Try
        Dim userid As String = ""
        If HttpContext.Current.User.Identity.IsAuthenticated AndAlso HttpContext.Current.User.Identity.Name IsNot Nothing AndAlso _
            HttpContext.Current.User.Identity.Name <> "" Then userid = HttpContext.Current.User.Identity.Name
        Dim iUrl As String = Left(HttpContext.Current.Request.ServerVariables("URL").Replace("'", "''"), 500), iQString As String = ""
        If HttpContext.Current.Request.QueryString.HasKeys Then
            For i As Integer = 0 To HttpContext.Current.Request.QueryString.Count - 1
                iQString += HttpContext.Current.Request.QueryString.Keys(i) & "=" & _
                         HttpContext.Current.Request.QueryString.Item(i) & "&"
            Next
            iQString.Replace("'", "&aps").Replace("'", "''")
        End If

        'Frank 2012/05/15
        'log user client information
        Dim _HTTP_USER_AGENT As String = "HTTP_USER_AGENT value is "
        If HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT") Is Nothing Then
            _HTTP_USER_AGENT &= "nothing"
        Else
            _HTTP_USER_AGENT &= HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT").Replace("'", "''")
        End If
        'Ming  2013/4/26 for Error: ScriptManager.SupportsPartialRendering
        If strEx.Contains("ScriptManager.SupportsPartialRendering") Then
            If HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT") IsNot Nothing Then
                strEx = HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT") + vbNewLine + strEx
            End If
            strEx = Util.GetClientIP() + vbNewLine + strEx
        End If
        'end
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        Dim cmd As New SqlClient.SqlCommand("INSERT INTO MY_ERR_LOG (ROW_ID, USERID, URL, QSTRING, EXMSG, APPID, CLIENT_INFO) VALUES (@UNIQID, @UID, @URL, @REQSTR, @ERRMSG, 'MY', @CLIENTINFO)", conn)

        With cmd.Parameters
            .AddWithValue("UNIQID", Left(System.Guid.NewGuid().ToString().Replace("-", ""), 10)) : .AddWithValue("UID", userid)
            .AddWithValue("URL", iUrl) : .AddWithValue("REQSTR", iQString) : .AddWithValue("ERRMSG", strEx) : .AddWithValue("CLIENTINFO", _HTTP_USER_AGENT)
        End With
        conn.Open() : cmd.ExecuteNonQuery() : conn.Close()
        'Catch ex As Exception

        'End Try
    End Sub
    Public Shared Function InsertMyErrLogV2(ByRef strEx As String) As String
        Dim userid As String = ""
        If HttpContext.Current.User.Identity.IsAuthenticated AndAlso HttpContext.Current.User.Identity.Name IsNot Nothing AndAlso _
            HttpContext.Current.User.Identity.Name <> "" Then userid = HttpContext.Current.User.Identity.Name
        Dim iUrl As String = Left(HttpContext.Current.Request.ServerVariables("URL").Replace("'", "''"), 500), iQString As String = ""
        If HttpContext.Current.Request.QueryString.HasKeys Then
            For i As Integer = 0 To HttpContext.Current.Request.QueryString.Count - 1
                iQString += HttpContext.Current.Request.QueryString.Keys(i) & "=" & _
                         HttpContext.Current.Request.QueryString.Item(i) & "&"
            Next
            iQString.Replace("'", "&aps").Replace("'", "''")
        End If
        'Frank 2012/05/15
        'log user client information
        Dim _HTTP_USER_AGENT As String = "HTTP_USER_AGENT value is "
        If HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT") Is Nothing Then
            _HTTP_USER_AGENT &= "nothing"
        Else
            _HTTP_USER_AGENT &= HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT").Replace("'", "''")
        End If
        'Ming  2013/4/26 for Error: ScriptManager.SupportsPartialRendering
        If strEx.Contains("ScriptManager.SupportsPartialRendering") Then
            If HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT") IsNot Nothing Then
                strEx = HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT") + vbNewLine + strEx
            End If
            strEx = Util.GetClientIP() + vbNewLine + strEx
        End If
        'end
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        Dim cmd As New SqlClient.SqlCommand("INSERT INTO MY_ERR_LOG (ROW_ID, USERID, URL, QSTRING, EXMSG, APPID, CLIENT_INFO) VALUES (@UNIQID, @UID, @URL, @REQSTR, @ERRMSG, 'MY', @CLIENTINFO)", conn)
        Dim RowID As String = Left(System.Guid.NewGuid().ToString().Replace("-", ""), 10)
        With cmd.Parameters
            .AddWithValue("UNIQID", RowID) : .AddWithValue("UID", userid)
            .AddWithValue("URL", iUrl) : .AddWithValue("REQSTR", iQString) : .AddWithValue("ERRMSG", strEx) : .AddWithValue("CLIENTINFO", _HTTP_USER_AGENT)
        End With
        conn.Open() : cmd.ExecuteNonQuery() : conn.Close()
        Return RowID
    End Function
    Public Shared Function ISIServices_Group_Account() As Boolean
        If CInt(dbUtil.dbExecuteScalar("my", "SELECT COUNT(*) as P FROM dbo.DB_iServices_Group  where " & _
                                       " CompayidOrEmail = '" + HttpContext.Current.Session("company_id") + "' " & _
                                       " or CompayidOrEmail ='" + HttpContext.Current.Session("user_id") + "'")) > 0 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function SendEmailWithAttachment( _
           ByVal SendTo As String, ByVal From As String, _
           ByVal Subject As String, ByVal Body As String, _
           ByVal IsBodyHtml As Boolean, _
           ByVal cc As String, _
           ByVal bcc As String, ByVal AttachmentStreams As System.IO.Stream, ByVal AttachmentName As String) As Boolean
        Dim oMail As New Net.Mail.MailMessage()
        oMail.From = New Net.Mail.MailAddress("myadvantech@advantech.com")
        oMail.To.Add("eBusiness.AEU@advantech.eu")
        'oMail.CC.Add("")
        oMail.Bcc.Add("ming.zhao@advantech.com.cn")
        oMail.Subject = Subject
        oMail.IsBodyHtml = IsBodyHtml
        oMail.Body = Body
        oMail.Attachments.Add(New Net.Mail.Attachment(AttachmentStreams, AttachmentName))
        Dim oSmpt As New Net.Mail.SmtpClient("aeuht1.aeu.advantech.corp")
        Try
            oSmpt.Send(oMail)
            Return True
        Catch ex As Exception
        End Try
        Return False
    End Function

    Public Shared Function IsRegularString(ByVal str As String) As Boolean
        If String.IsNullOrEmpty(str) Then str = " "

        Dim r As New Regex("^[a-zA-Z0-9@#$%&*+\-_(),|+':;?.,![\]\s\\/]{1,40}$")

        If r.IsMatch(str) Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Function StringFromWide2Narrow(ByVal str As String) As String
        Try
            Dim str_copy As String = str
            str_copy = StrConv(str_copy, VbStrConv.Narrow, 1028)
            Dim result As StringBuilder = New StringBuilder

            For i As Integer = 0 To str_copy.Length - 1
                Dim c As Char = str_copy(i)
                If Not c = "?" Then
                    result.Append(c)
                Else
                    result.Append(str(i))
                End If
            Next

            Return result.ToString
        Catch ex As Exception
            Return str
        End Try
    End Function
End Class
Public Class CISUTILITY
    Public Shared Function QueryDB(ByVal sql As [String], ByVal ConnName As [String], ByRef err As [String]) As DataTable
        Return dbUtil.dbGetDataTable(ConnName, sql)
    End Function
    Public Shared Sub UpdateDBArray(ByVal sql As [String](), ByVal ConnName As [String], ByRef err As [String])
        For i As Integer = 0 To sql.Length - 1
            dbUtil.dbExecuteNoQuery(ConnName, sql(i))
        Next
    End Sub
    Public Shared Function GetSchemaTable() As DataTable
        Dim dtFormField As New DataTable()
        dtFormField.ReadXmlSchema(HttpContext.Current.Server.MapPath("~/Product/CIS/FIELD_SCHEMA/") + "Components_SCHEMA.XML")
        dtFormField.ReadXml(HttpContext.Current.Server.MapPath("~/Product/CIS/FIELD_DEFINE/") + "Components.XML")
        Return dtFormField
    End Function

    Public Shared Sub UpdateDB(ByVal sql As [String], ByVal ConnName As [String], ByRef err As [String])
        dbUtil.dbExecuteNoQuery(ConnName, sql)
    End Sub

End Class
Public Class Regression
    Function Regress(ByVal xval() As Double, ByVal yval() As Double) As RegressionProcessInfo
        Dim sigmax As Double = 0.0
        Dim sigmay As Double = 0.0
        Dim sigmaxx As Double = 0.0
        Dim sigmayy As Double = 0.0
        Dim sigmaxy As Double = 0.0
        Dim x As Double
        Dim y As Double
        Dim n As Double = 0
        Dim ret As RegressionProcessInfo = New RegressionProcessInfo
        For arrayitem As Integer = LBound(xval) To UBound(xval)
            x = xval(arrayitem)
            y = yval(arrayitem)
            If x > ret.XRangeH Then
                ret.XRangeH = x
            End If
            If x < ret.XRangeL Then
                ret.XRangeL = x
            End If
            If y > ret.YRangeH Then
                ret.YRangeH = y
            End If
            If y < ret.YRangeL Then
                ret.YRangeL = y
            End If
            sigmax += x
            sigmaxx += x * x
            sigmay += y
            sigmayy += y * y
            sigmaxy += x * y
            n = n + 1
        Next

        ret.b = (n * sigmaxy - sigmax * sigmay) / (n * sigmaxx - sigmax * sigmax)
        ret.a = (sigmay - ret.b * sigmax) / n
        ret.SampleSize = CType(n, Integer)
        'calculate distances for each point (residual)
        For arr2 As Integer = LBound(xval) To UBound(xval)
            y = yval(arr2)
            x = xval(arr2)
            Dim yprime As Double = ret.a + ret.b * x 'prediction
            Dim Residual As Double = y - yprime
            ret.SigmaError += Residual * Residual
        Next
        ret.XMean = sigmax / n
        ret.YMean = sigmay / n
        ret.XStdDev = Math.Sqrt((CType(n * sigmaxx - sigmax * sigmax, Double)) / (CDbl(n) * CDbl(n) - 1.0))
        ret.YStdDev = Math.Sqrt((CType(n * sigmayy - sigmay * sigmay, Double)) / (CDbl(n) * CDbl(n) - 1.0))
        ret.StandardError = Math.Sqrt(ret.SigmaError / ret.SampleSize)
        Dim ssx As Double = sigmaxx - ((sigmax * sigmax) / n)
        Dim ssy As Double = sigmayy - ((sigmay * sigmay) / n)
        Dim ssxy As Double = sigmaxy - ((sigmax * sigmay) / n)
        ret.PearsonsR = ssxy / Math.Sqrt(ssx * ssy)
        ret.t = ret.PearsonsR / Math.Sqrt((1 - (ret.PearsonsR * ret.PearsonsR)) / (n - 2))
        Return ret
    End Function

End Class

Public Class RegressionProcessInfo
    Public SampleSize As Integer = 0
    Public SigmaError As Double
    Public XRangeL As Double = Double.MaxValue
    Public XRangeH As Double = Double.MinValue
    Public YRangeL As Double = Double.MaxValue
    Public YRangeH As Double = Double.MinValue
    Public StandardError As Double
    Public a As Double
    Public b As Double
    Public XStdDev As Double
    Public YStdDev As Double
    Public XMean As Double
    Public YMean As Double
    Public PearsonsR As Double
    Public t As Double
    Dim Residuals As ArrayList = New ArrayList

    Public Overrides Function ToString() As String
        Dim ret As String = "SampleSize=" & Me.SampleSize & vbCrLf & _
        "StandardError=" & Me.StandardError & vbCrLf & _
        "y=" & Me.a & " + " & Me.b & "x"
        Return ret
    End Function

End Class

Public Class Forum_Util

    Public Shared Function FormatPostHtml(ByVal htmlText As String, ByVal PostId As String) As String
        htmlText = Replace(htmlText, vbCrLf, "<br />")
        If htmlText.Contains("[code]") AndAlso htmlText.Contains("[/code]") Then
            htmlText = Replace(htmlText, "[code]", "<code>")
            htmlText = Replace(htmlText, "[/code]", "</code>")
            Dim hdoc As New HtmlAgilityPack.HtmlDocument
            hdoc.LoadHtml(htmlText)
            Dim nodes As HtmlAgilityPack.HtmlNodeCollection = hdoc.DocumentNode.SelectNodes("//code")
            If nodes IsNot Nothing AndAlso nodes.Count > 0 Then
                For i As Integer = 0 To nodes.Count - 1
                    Dim n As HtmlAgilityPack.HtmlNode = nodes(i)
                    Dim sb As New System.Text.StringBuilder
                    With sb
                        .AppendLine(String.Format("<div>"))
                        .AppendLine(String.Format(" <table width='80%' border='1'>"))
                        .AppendLine(String.Format("     <tr><th align='left'>Code:</th><td align='right'><a href='javascript:void(0);' onclick='copy_to_clipboard(""tdCode_{0}_{1}"")'>Copy to clipboard</a></td></tr>", PostId, i.ToString()))
                        .AppendLine(String.Format("     <tr><td colspan='2' id='tdCode_{0}_{1}'>{2}</td></tr>", PostId, i.ToString(), n.InnerHtml))
                        .AppendLine(String.Format(" </table>"))
                        .AppendLine(String.Format("</div>"))
                    End With
                    n.InnerHtml = sb.ToString()
                Next
                htmlText = hdoc.DocumentNode.OuterHtml
                htmlText = Replace(htmlText, "<code>", "")
                htmlText = Replace(htmlText, "</code>", "")
            End If
        End If
        Return htmlText
    End Function

    Public Shared Function LastPostBlock(ByVal title As String, ByVal by As String, ByVal pdate As Object, ByVal LastPid As String) As String
        If TypeOf (pdate) Is DBNull OrElse Date.TryParse(pdate, Now) = False Then
            Return ""
        Else
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format("<table width='100%'>"))
                .AppendLine(String.Format(" <tr align='center'>"))
                .AppendLine(String.Format("     <td>"))
                .AppendLine(String.Format("         <a href='ViewThread.aspx?tid=" + LastPid + "'>{0}</a>", title))
                .AppendLine(String.Format("     </td>"))
                .AppendLine(String.Format(" </tr>"))
                .AppendLine(String.Format(" <tr align='center'>"))
                .AppendLine(String.Format("     <td>{0}</td>", CDate(pdate).ToString("yyyy-MM-dd HH:mm")))
                .AppendLine(String.Format(" </tr>"))
                .AppendLine(String.Format(" <tr align='center'>"))
                .AppendLine(String.Format("     <td>by {0}</td>", Util.GetNameVonEmail(by)))
                .AppendLine(String.Format(" </tr>"))
                .AppendLine(String.Format("</table>"))
            End With
            Return sb.ToString()
        End If
    End Function

    Public Shared Function GetModerators(ByVal catid As String) As String
        Dim dt As Data.DataTable = dbUtil.dbGetDataTable("FORUM", "select moderator from forum_moderators where category_id='" + catid + "'")
        Dim arr As New ArrayList
        For Each r As Data.DataRow In dt.Rows
            arr.Add(Util.GetNameVonEmail(r.Item("moderator")))
        Next
        Return String.Join(",", arr.ToArray())
    End Function

    Public Shared Function ShowSubPage(ByVal rowid As String, ByVal catname As String, ByVal ForumType As String) As String
        If ForumType = "forum" Then
            Return String.Format("<a href='Forum_Posts.aspx?fid={0}'>{1}</a>", rowid, catname)
        Else
            Return String.Format("<a href='Forum_Sub.aspx?fid={0}'>{1}</a>", rowid, catname)
        End If
    End Function

    Public Shared Function IsForumAdmin() As Boolean
        If Util.IsAdmin() Then
            Select Case Util.GetNameVonEmail(HttpContext.Current.Session("user_id").ToString().ToUpper())
                Case "TC.CHEN", "WEN.CHIANG"
                    Return True
                Case Else
                    Return False
            End Select
        Else
            Return False
        End If
    End Function

    Public Shared Function IsCatModerator(ByVal CatId As String) As Boolean
        Dim c As Integer = dbUtil.dbExecuteScalar("FORUM", String.Format( _
        "select count(CATEGORY_ID) as c from FORUM_MODERATORS where CATEGORY_ID='{0}' and MODERATOR='" + HttpContext.Current.Session("user_id") + "'", CatId.Replace("'", "''")))
        If c > 0 Then Return True
        Return False
    End Function

    Public Function PostNewArticle(ByVal CatId As String, ByVal Subject As String, ByVal MsgType As String, ByVal UserId As String, _
                                   ByVal Content As String, ByRef FileDt As DataTable) As Boolean
        Subject = HttpUtility.HtmlEncode(Subject)
        Dim strNewId As String = Util.NewRowId("FORUM_POST_MASTER", "FORUM")
        Dim strSql As String = _
            " INSERT INTO FORUM_POST_MASTER " + _
            " (ROW_ID, CATEGORY_ID, SUBJECT, CREATED_BY, CREATED_DATE, MSG_TYPE) " + _
            " VALUES (N'" + strNewId + _
            "', N'" + CatId + "', N'" + Subject.Trim().Replace("'", "''") + "', N'" + UserId + "', GETDATE(), N'" + MsgType.Trim().Replace("'", "''") + "') "
        dbUtil.dbExecuteNoQuery("FORUM", strSql)
        Return ReplyArticle(strNewId, Content, UserId, FileDt)
    End Function

    Public Function EditArticle(ByVal RowId As String, ByVal Content As String, ByRef FileDt As DataTable) As Boolean
        dbUtil.dbExecuteNoQuery("FORUM", "update FORUM_POST_DETAIL set POST_CONTENT=N'" + Content.Replace("'", "''") + "' where row_id='" + RowId + "'")
        dbUtil.dbExecuteNoQuery("FORUM", "update FORUM_POST_MASTER  set LAST_REPLY_DATE=GETDATE() from FORUM_POST_MASTER a inner join FORUM_POST_DETAIL b on a.ROW_ID=b.POST_ID where b.ROW_ID='" + RowId + "'")
        Return SaveUploadFiles(RowId, FileDt)
    End Function

    Public Function ReplyArticle(ByVal PostId As String, ByVal Content As String, ByVal UserId As String, _
                                 ByRef FileDt As DataTable) As Boolean
        Dim strNewId2 As String = Util.NewRowId("FORUM_POST_DETAIL", "FORUM")
        Dim strSql As String = _
              " INSERT INTO FORUM_POST_DETAIL " + _
              " (POST_ID, ROW_ID, POST_CONTENT, POST_BY, POST_DATE) " + _
              " VALUES (N'" + PostId + "', N'" + strNewId2 + "', N'" + Content.Trim().Replace("'", "''") + _
              "', N'" + UserId + "', GETDATE()) "
        dbUtil.dbExecuteNoQuery("FORUM", strSql)
        dbUtil.dbExecuteNoQuery("FORUM", "update FORUM_POST_MASTER set LAST_REPLY_DATE=GETDATE() where row_id='" + PostId + "' ")
        Return SaveUploadFiles(strNewId2, FileDt)
    End Function

    Public Shared Function FileExt2FileType(ByVal fext As String) As String
        Select Case fext.ToLower()
            Case "7z", "tgz", "gz"
                Return "application/x-zip-compressed"
            Case "bmp"
                Return "image/bmp"
            Case "doc", "docx"
                Return "application/msword"
            Case "jpg", "jpeg"
                Return "image/jpeg"
            Case ""
                Return "application/empty"
            Case "wmv"
                Return "video/x-ms-wmv"
            Case "gif"
                Return "image/gif"
            Case "pdf"
                Return "application/pdf"
            Case "zip"
                Return "application/zip"
            Case "xls", "xlsx"
                Return "application/vnd.ms-excel"
            Case "png"
                Return "image/x-png"
            Case "ppt", "pptx"
                Return "application/vnd.ms-powerpoint"
            Case "txt"
                Return "text/plain"
            Case "rar"
                Return "application/x-rar-compressed"
            Case Else
                Return "application/x-download"
        End Select
    End Function

    Function SaveUploadFiles(ByVal postid As String, ByRef FileDt As DataTable) As Boolean
        'Dim mpContentPlaceHolder As ContentPlaceHolder = Me.Master.FindControl("_main")
        'If FileDt Is Nothing Then Return False
        Dim MaxSeq As Integer = dbUtil.dbExecuteScalar("FORUM", "select IsNull(max(seq_no),0) from FORUM_FILE_DOC_ATTACHMENTS where doc_id='" + postid + "'")
        MaxSeq += 1
        Dim g_adoConn As New Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("FORUM").ConnectionString)
        g_adoConn.Open()
        For Each r As DataRow In FileDt.Rows
            Dim fname As String = r.Item("FileName"), fext As String = "", fdesc As String = r.Item("Desc")
            If fname.Contains(".") Then
                fext = FileExt2FileType(Split(fname, ".")(1))
            Else
                fext = "application/x-download"
            End If
            Dim rid As String = Util.NewRowId("FORUM_FILE_DOC_ATTACHMENTS", "FORUM")
            Dim fb() As Byte = r.Item("FileBytes")
            Dim dbCmd As Data.SqlClient.SqlCommand = g_adoConn.CreateCommand()
            dbCmd.CommandText = _
                " INSERT INTO FORUM_FILE_DOC_ATTACHMENTS (ROW_ID, DOC_ID, FILE_NAME, FILE_DESC, FILE_EXT, FILE_SIZE, FILE_BIN, SEQ_NO) " + _
                " VALUES (N'" + rid + "', N'" + postid + "', N'" + fname.Replace("'", "''") + "', N'" + fdesc.Replace("'", "''") + "', " + _
                " N'" + fext.Replace("'", "''") + "', " + fb.Length.ToString() + ",@FBIN, " + MaxSeq.ToString() + ")"
            dbCmd.Parameters.Add(New Data.SqlClient.SqlParameter("FBIN", fb))
            Try
                dbCmd.ExecuteNonQuery()
                MaxSeq += 1
            Catch ex As Exception
                g_adoConn.Close() : Return False
            End Try
        Next
        g_adoConn.Close()
        Return True
    End Function

End Class

Public Class CharSetConverter
    Friend Const LOCALE_SYSTEM_DEFAULT As Integer = &H800
    Friend Const LCMAP_SIMPLIFIED_CHINESE As Integer = &H2000000
    Friend Const LCMAP_TRADITIONAL_CHINESE As Integer = &H4000000

    ''' <summary>
    ''' 使用OS的kernel.dll做為簡繁轉換工具，只要有裝OS就可以使用，不用額外引用dll，但只能做逐字轉換，無法進行詞意的轉換
    ''' <para>所以無法將電腦轉成計算機</para>
    ''' </summary>
    <Runtime.InteropServices.DllImport("kernel32", CharSet:=Runtime.InteropServices.CharSet.Auto, SetLastError:=True)> _
    Friend Shared Function LCMapString(Locale As Integer, dwMapFlags As Integer, lpSrcStr As String, _
                                           cchSrc As Integer, <Runtime.InteropServices.Out()> lpDestStr As String, cchDest As Integer) As Integer
    End Function

    ''' <summary>
    ''' 繁體轉簡體
    ''' </summary>
    ''' <param name="pSource">要轉換的繁體字：體</param>
    ''' <returns>轉換後的簡體字：体</returns>
    Public Shared Function ToSimplified(pSource As String) As String
        Dim tTarget As New [String](" "c, pSource.Length)
        Dim tReturn As Integer = LCMapString(LOCALE_SYSTEM_DEFAULT, LCMAP_SIMPLIFIED_CHINESE, pSource, pSource.Length, tTarget, pSource.Length)
        Return tTarget
    End Function

    ''' <summary>
    ''' 簡體轉繁體
    ''' </summary>
    ''' <param name="pSource">要轉換的繁體字：体</param>
    ''' <returns>轉換後的簡體字：體</returns>
    Public Shared Function ToTraditional(pSource As String) As String
        Dim tTarget As New [String](" "c, pSource.Length)
        Dim tReturn As Integer = LCMapString(LOCALE_SYSTEM_DEFAULT, LCMAP_TRADITIONAL_CHINESE, pSource, pSource.Length, tTarget, pSource.Length)
        Return tTarget
    End Function

End Class


Namespace IpRangeUtility
    Public Class IPRange
        Public Sub New(ipRange__1 As String)
            If ipRange__1 Is Nothing Then
                Throw New ArgumentNullException()
            End If

            If Not TryParseCIDRNotation(ipRange__1) AndAlso Not TryParseSimpleRange(ipRange__1) Then
                Throw New ArgumentException()
            End If
        End Sub

        Public Function GetBeginIP() As Net.IPAddress
            Return New Net.IPAddress(New Byte() {CByte(beginIP(0)), CByte(beginIP(1)), CByte(beginIP(2)), CByte(beginIP(3))})
        End Function

        Public Function GetEndIP() As Net.IPAddress
            Return New Net.IPAddress(New Byte() {CByte(endIP(0)), CByte(endIP(1)), CByte(endIP(2)), CByte(endIP(3))})
        End Function

        Public Function GetAllIP() As IEnumerable(Of Net.IPAddress)
            Dim capacity As Integer = 1
            For i As Integer = 0 To 3
                capacity *= endIP(i) - beginIP(i) + 1
            Next

            Dim ips As New List(Of Net.IPAddress)(capacity)
            For i0 As Integer = beginIP(0) To endIP(0)
                For i1 As Integer = beginIP(1) To endIP(1)
                    For i2 As Integer = beginIP(2) To endIP(2)
                        For i3 As Integer = beginIP(3) To endIP(3)
                            ips.Add(New Net.IPAddress(New Byte() {CByte(i0), CByte(i1), CByte(i2), CByte(i3)}))
                        Next
                    Next
                Next
            Next

            Return ips
        End Function

        ''' <summary>
        ''' Parse IP-range string in CIDR notation.
        ''' For example "12.15.0.0/16".
        ''' </summary>
        ''' <param name="ipRange"></param>
        ''' <returns></returns>
        Private Function TryParseCIDRNotation(ipRange As String) As Boolean
            Dim x As String() = ipRange.Split("/"c)

            If x.Length <> 2 Then
                Return False
            End If

            Dim bits As Byte = Byte.Parse(x(1))
            Dim ip As UInteger = 0
            Dim ipParts0 As [String]() = x(0).Split("."c)
            For i As Integer = 0 To 3
                ip = ip << 8
                ip += UInteger.Parse(ipParts0(i))
            Next

            Dim shiftBits As Byte = CByte(32 - bits)
            Dim ip1 As UInteger = (ip >> shiftBits) << shiftBits

            If ip1 <> ip Then
                ' Check correct subnet address
                Return False
            End If

            Dim ip2 As UInteger = ip1 >> shiftBits
            For k As Integer = 0 To shiftBits - 1
                ip2 = (ip2 << 1) + 1
            Next

            beginIP = New Byte(3) {}
            endIP = New Byte(3) {}

            For i As Integer = 0 To 3
                beginIP(i) = CByte((ip1 >> (3 - i) * 8) And 255)
                endIP(i) = CByte((ip2 >> (3 - i) * 8) And 255)
            Next

            Return True
        End Function

        ''' <summary>
        ''' Parse IP-range string "12.15-16.1-30.10-255"
        ''' </summary>
        ''' <param name="ipRange"></param>
        ''' <returns></returns>
        Private Function TryParseSimpleRange(ipRange As String) As Boolean
            Dim ipParts As [String]() = ipRange.Split("."c)

            beginIP = New Byte(3) {}
            endIP = New Byte(3) {}
            For i As Integer = 0 To 3
                Dim rangeParts As String() = ipParts(i).Split("-"c)

                If rangeParts.Length < 1 OrElse rangeParts.Length > 2 Then
                    Return False
                End If

                beginIP(i) = Byte.Parse(rangeParts(0))
                endIP(i) = If((rangeParts.Length = 1), beginIP(i), Byte.Parse(rangeParts(1)))
            Next

            Return True
        End Function

        Private beginIP As Byte()
        Private endIP As Byte()
    End Class
End Namespace


Public Module Extensions

    Private _lockObjForIDictionary As Object = New Object()

    Private _lockObjForIList As Object = New Object()

    ''' <summary>
    ''' Custom IDictionary add funciton for mutiple thread environment
    ''' </summary>
    ''' <typeparam name="T">Tkey</typeparam>
    ''' <typeparam name="T1">Tvalue</typeparam>
    ''' <param name="maninObj">The IDictionary object</param>
    ''' <param name="value">value</param>
    ''' <param name="key">key</param>
    ''' <returns>The IDictionary object which has added the key and value</returns>
    ''' <remarks></remarks>
    <Extension>
    Public Function CollectionAdd(Of T, T1)(ByVal maninObj As IDictionary(Of T, T1), ByVal value As Object, Optional ByVal key As Object = Nothing) As IDictionary(Of T, T1)

        SyncLock _lockObjForIDictionary
            If (maninObj.ContainsKey(key)) Then

            ElseIf (key Is Nothing) Then
                maninObj.Add(value)
            Else
                maninObj.Add(key, value)
            End If
        End SyncLock

        Return maninObj
    End Function

    ''' <summary>
    ''' Custom IList add funciton for mutiple thread environment
    ''' </summary>
    ''' <typeparam name="T">Tvalue</typeparam>
    ''' <param name="maninObj">The IList object</param>
    ''' <param name="value">value</param>
    ''' <returns>The IList object which has added the key and value</returns>
    ''' <remarks></remarks>
    <Extension>
    Public Function CollectioinAdd(Of T)(ByRef maninObj As List(Of T), ByVal value As Object) As ICollection(Of T)

        SyncLock _lockObjForIList
            maninObj.Add(value)
        End SyncLock

        Return maninObj
    End Function



End Module