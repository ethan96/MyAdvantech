Imports Microsoft.VisualBasic
Imports System.Collections
Imports System

Public Class DataMiningUtil
    Public Shared Function GetRBU() As ArrayList
        Dim arRBU As New ArrayList
        If AuthUtil.IsHQAOnlineMkt() OrElse Util.IsAEUIT() Then
            Dim dtAllRBU As DataTable = dbUtil.dbGetDataTable("MY", "select RBU from SIEBEL_ACCOUNT where RBU is not null and RBU<>'' group by RBU having COUNT(row_id)>=20 order by RBU")
            For Each rowRBU As DataRow In dtAllRBU.Rows
                If Not arRBU.Contains(rowRBU.Item("RBU").ToString()) Then arRBU.Add(rowRBU.Item("RBU").ToString())
            Next
        End If
        If MailUtil.IsInRole("ITD.ACL") OrElse MailUtil.IsInRole("ATWCallCenter") OrElse MailUtil.IsInRole("DIRECTOR.ACL") Then
            If Not arRBU.Contains("ATW") Then arRBU.Add("ATW")
        End If
        If MailUtil.IsInRole("MARKETING.IAG.USA") OrElse MailUtil.IsInRole("MANAGERS.IAG.USA") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("AAC") Then arRBU.Add("AAC")
        End If
        If MailUtil.IsInRole("SALES.ECG.USA") OrElse MailUtil.IsInRole("SALES.NCG.USA") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("AENC") Then arRBU.Add("AENC")
        End If
        If MailUtil.IsInRole("Aonline.USA") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("ANADMF") Then arRBU.Add("ANADMF")
        End If
        If MailUtil.IsInRole("AEU.Marcoms") OrElse MailUtil.IsInRole("sales.AEU") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("ADL") Then arRBU.Add("ADL")
            If Not arRBU.Contains("AFR") Then arRBU.Add("AFR")
            If Not arRBU.Contains("AIT") Then arRBU.Add("AIT")
            If Not arRBU.Contains("AEE") Then arRBU.Add("AEE")
            If Not arRBU.Contains("ABN") Then arRBU.Add("ABN")
            If Not arRBU.Contains("AUK") Then arRBU.Add("AUK")
        End If
        If MailUtil.IsInRole("ajp_callcenter") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("AJP") Then arRBU.Add("AJP")
        End If
        If MailUtil.IsInRole("EMPLOYEE.AKR") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("AKR") Then arRBU.Add("AKR")
        End If
        If MailUtil.IsInRole("ASG Sales & Marcom") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("SAP") Then arRBU.Add("SAP")
            If Not arRBU.Contains("ASG") Then arRBU.Add("ASG")
            If Not arRBU.Contains("AMY") Then arRBU.Add("AMY")
        End If
        If MailUtil.IsInRole("InterCon.ALL") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("HQDC") Then arRBU.Add("HQDC")
            If Not arRBU.Contains("AIN") Then arRBU.Add("AIN")
            If Not arRBU.Contains("ARU") Then arRBU.Add("ARU")
            If Not arRBU.Contains("ABR") Then arRBU.Add("ABR")
        End If
        If MailUtil.IsInRole("EMPLOYEE.AAU") OrElse Util.IsAEUIT() Then
            If Not arRBU.Contains("AAU") Then arRBU.Add("AAU")
        End If

        'If String.Equals(HttpContext.Current.User.Identity.Name, "tanya.lin@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
        '    OrElse String.Equals(HttpContext.Current.User.Identity.Name, "ada.tang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
        '    OrElse String.Equals(HttpContext.Current.User.Identity.Name, "wen.chiang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
        '    OrElse String.Equals(HttpContext.Current.User.Identity.Name, "gary.lee@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
        '    OrElse String.Equals(HttpContext.Current.User.Identity.Name, "julie.fang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
        '    OrElse String.Equals(HttpContext.Current.User.Identity.Name, "mary.huang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) Then
        '    If Not arRBU.Contains("ATW") Then arRBU.Add("ATW")
        '    If Not arRBU.Contains("AAC") Then arRBU.Add("AAC")
        '    If Not arRBU.Contains("ANADMF") Then arRBU.Add("ANADMF")
        '    If Not arRBU.Contains("AAU") Then arRBU.Add("AAU")
        'End If

        For i As Integer = 0 To arRBU.Count - 1
            arRBU(i) = "'" + arRBU(i) + "'"
        Next
        Return arRBU
    End Function

#Region "Full Text Search"

    Public Shared Function Top1NearKeyword(WrongKey As String, Optional MaxDistance As Integer = 3) As String
        WrongKey = Trim(LCase(WrongKey))
        Dim NearKeyPairs As Hashtable = HttpContext.Current.Cache("Near Key Pairs")
        If NearKeyPairs Is Nothing Then
            NearKeyPairs = New Hashtable
            HttpContext.Current.Cache.Add("Near Key Pairs", NearKeyPairs, Nothing, Now.AddHours(6), Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If

        If NearKeyPairs.ContainsKey(WrongKey) Then
            Return LCase(NearKeyPairs.Item(WrongKey).ToString())
        Else
            Dim sql As String = _
           " select top 1 Keyword  " + _
           " from " + _
           " ( " + _
           " 	select Keyword, COUNT(ROW_ID) as f,  dbo.CalcEditDistance(LOWER(Keyword),@WK) as d " + _
           " 	from CurationPool.dbo.GOOGLE_SEARCH_KEYWORDS  " + _
           " 	where dbo.CalcEditDistance(LOWER(Keyword),@WK)<=" + MaxDistance.ToString() + " and Keyword<>@WK  " + _
           " 	and Keyword in (select Keyword from CurationPool.dbo.GOOGLE_SEARCH_KEYWORDS group by Keyword having COUNT(ROW_ID)>=3) " + _
           " 	group by Keyword  " + _
           " ) a " + _
           " order by d, f desc "
            Dim cmd As New SqlClient.SqlCommand(sql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            cmd.Parameters.AddWithValue("WK", WrongKey)
            cmd.Connection.Open()
            Dim k As Object = cmd.ExecuteScalar()
            cmd.Connection.Close()
            If k IsNot Nothing Then
                NearKeyPairs.Add(WrongKey, k.ToString()) : Return k
            Else
                NearKeyPairs.Add(WrongKey, "")
            End If
        End If
        Return ""
    End Function

    Public Shared Function SuggestKeys(keys As String) As String()
        If String.IsNullOrEmpty(Trim(keys)) Then
            Return New String() {}
        End If
        Dim sbInsKeys As New System.Text.StringBuilder

        Dim ks() As String = Split(Trim(keys), " "), keysArray As New ArrayList

        For i As Integer = 0 To ks.Length - 1
            ks(i) = Trim(ks(i))
            If Not String.IsNullOrEmpty(ks(i)) AndAlso Not keysArray.Contains(ks(i)) Then
                sbInsKeys.AppendLine(" insert into @Keys select N'" + Replace(ks(i), "'", "''") + "' ")
                keysArray.Add(ks(i))
            End If
        Next
        If sbInsKeys.Length = 0 Or keysArray.Count >= 6 Then Return New String() {keys}
        Dim sql As String = _
             " DECLARE @Keys TABLE " + _
             " ( " + _
             "   keyword nvarchar(400) " + _
             " ) " + _
             "  " + _
             sbInsKeys.ToString() + _
             "  " + _
             " select top 3 KW as Keyword " + _
             " from MyLocal.dbo.GOOGLE_WWW_SEARCH_KEYWORDS (nolock) where REC_ID in " + _
             " (select REC_ID from MyLocal.dbo.GOOGLE_WWW_SEARCH_KEYWORDS (nolock) where KW=@LastKey) and KW not in (select Keyword from @Keys) " + _
             " group by KW having COUNT(REC_ID)>2 order by COUNT(REC_ID) desc "
        Dim apt As New SqlClient.SqlDataAdapter(sql, ConfigurationManager.ConnectionStrings("MYLOCAL").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("LastKey", keysArray(keysArray.Count - 1))
        Dim dtKeys As New DataTable
        apt.Fill(dtKeys)
        apt.SelectCommand.Connection.Close()
        If dtKeys.Rows.Count > 0 Then
            Dim RetStrings(dtKeys.Rows.Count - 1) As String
            For i As Integer = 0 To dtKeys.Rows.Count - 1
                RetStrings(i) = Trim(keys) + " " + dtKeys.Rows(i).Item("Keyword")
            Next
            Return RetStrings
            'Return Trim(keys) + " " + dtKeys.Rows(0).Item("Keyword")
        End If
        Return New String() {keys}
    End Function

    Public Shared Function SuggestKeysByDM(keys As String) As String()
        If String.IsNullOrEmpty(Trim(keys)) Then
            Return New String() {""}
        End If
        Dim sbInsKeys As New System.Text.StringBuilder

        Dim ks() As String = Split(Trim(keys), " "), keysArray As New ArrayList, KeysArrayForMatching As New ArrayList

        For i As Integer = 0 To ks.Length - 1
            ks(i) = Trim(ks(i))
            If Not String.IsNullOrEmpty(ks(i)) AndAlso Not DataMiningUtil.SearchArrayIgnoreCase(keysArray, ks(i)) Then
                keysArray.Add(ks(i))
            End If
        Next
        If keysArray.Count = 0 Or keysArray.Count >= 5 Then Return New String() {keys}

        Dim SuggestedKeysSet As New List(Of ArrayList)


        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter("", conn)

        conn.Open()
        Dim sqlClause As New System.Text.StringBuilder
        For Each k In keysArray
            sqlClause.AppendLine(" LHS like N'%" + Replace(k, "'", "''") + "%' and ")
        Next
        apt.SelectCommand.CommandText = _
            " select top 10 LHS, RHS from MyLocal.dbo.GOOGLE_SEARCHKEY_RELATION (nolock) " + _
            " where " + sqlClause.ToString().Substring(0, sqlClause.Length - 6) + _
            " order by SUPPORT+CONFIDENCE+LIFT desc "
        Dim dtDM As New DataTable
        apt.Fill(dtDM)
        If dtDM.Rows.Count > 0 Then
            For Each RowDM As DataRow In dtDM.Rows
                Dim SuggestedKeys As New ArrayList
                KeysArrayForMatching = keysArray.Clone()
                Dim lks() As String = Split(RowDM.Item("LHS"), ","), rks() As String = Split(RowDM.Item("RHS"), ",")
                For Each lk In lks

                    If Not DataMiningUtil.SearchArrayIgnoreCase(keysArray, Trim(lk)) And Not DataMiningUtil.SearchArrayIgnoreCase(SuggestedKeys, Trim(lk)) Then
                        SuggestedKeys.Add(Trim(lk))
                    End If

                    If DataMiningUtil.SearchArrayIgnoreCase(KeysArrayForMatching, Trim(lk)) Then DataMiningUtil.RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(lk))

                Next
                For Each rk In rks
                    If Not DataMiningUtil.SearchArrayIgnoreCase(keysArray, Trim(rk)) And Not DataMiningUtil.SearchArrayIgnoreCase(SuggestedKeys, Trim(rk)) Then
                        SuggestedKeys.Add(Trim(rk))
                    End If
                    If DataMiningUtil.SearchArrayIgnoreCase(KeysArrayForMatching, Trim(rk)) Then DataMiningUtil.RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(rk))
                Next
                If SuggestedKeys.Count > 0 And KeysArrayForMatching.Count = 0 Then
                    SuggestedKeysSet.Add(SuggestedKeys)
                End If
            Next
        Else
            sqlClause.Clear() : dtDM.Clear() : apt.SelectCommand.CommandText = ""
            For Each k In keysArray
                sqlClause.AppendLine(" LHS like N'%" + Replace(k, "'", "''") + "%' or RHS like N'%" + Replace(k, "'", "''") + "%' or ")
            Next
            apt.SelectCommand.CommandText = _
                " select top 10 LHS, RHS from MyLocal.dbo.GOOGLE_SEARCHKEY_RELATION " + _
                " where " + sqlClause.ToString().Substring(0, sqlClause.Length - 5) + _
                " order by SUPPORT+CONFIDENCE+LIFT desc "
            apt.Fill(dtDM)
            If dtDM.Rows.Count > 0 Then
                For Each RowDM As DataRow In dtDM.Rows
                    Dim SuggestedKeys As New ArrayList
                    KeysArrayForMatching = keysArray.Clone()
                    Dim lks() As String = Split(RowDM.Item("LHS"), ","), rks() As String = Split(RowDM.Item("RHS"), ",")
                    For Each lk In lks

                        If Not DataMiningUtil.SearchArrayIgnoreCase(keysArray, Trim(lk)) And Not DataMiningUtil.SearchArrayIgnoreCase(SuggestedKeys, Trim(lk)) Then
                            SuggestedKeys.Add(Trim(lk))
                        End If

                        If DataMiningUtil.SearchArrayIgnoreCase(KeysArrayForMatching, Trim(lk)) Then DataMiningUtil.RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(lk))

                    Next
                    For Each rk In rks
                        If Not DataMiningUtil.SearchArrayIgnoreCase(keysArray, Trim(rk)) And Not DataMiningUtil.SearchArrayIgnoreCase(SuggestedKeys, Trim(rk)) Then
                            SuggestedKeys.Add(Trim(rk))
                        End If
                        If DataMiningUtil.SearchArrayIgnoreCase(KeysArrayForMatching, Trim(rk)) Then DataMiningUtil.RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(rk))
                    Next
                    If SuggestedKeys.Count > 0 And KeysArrayForMatching.Count = 0 Then
                        SuggestedKeysSet.Add(SuggestedKeys)
                    End If
                Next
            End If
        End If
        conn.Close()
        Dim RetStrings(SuggestedKeysSet.Count - 1) As String
        For i As Integer = 0 To SuggestedKeysSet.Count - 1
            RetStrings(i) = keys + " " + String.Join(" ", SuggestedKeysSet(i).ToArray())
        Next
        Return RetStrings
    End Function

    Public Shared Function SuggestKeysByDM_Old(keys As String) As String()
        If String.IsNullOrEmpty(Trim(keys)) Then
            Return New String() {""}
        End If
        Dim sbInsKeys As New System.Text.StringBuilder

        Dim ks() As String = Split(Trim(keys), " "), keysArray As New ArrayList, KeysArrayForMatching As New ArrayList

        For i As Integer = 0 To ks.Length - 1
            ks(i) = Trim(ks(i))
            If Not String.IsNullOrEmpty(ks(i)) AndAlso Not SearchArrayIgnoreCase(keysArray, ks(i)) Then
                keysArray.Add(ks(i))
            End If
        Next
        If keysArray.Count = 0 Or keysArray.Count >= 5 Then Return New String() {keys}

        Dim SuggestedKeysSet As New List(Of ArrayList)


        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter("", conn)

        conn.Open()
        Dim sqlClause As New System.Text.StringBuilder
        For Each k In keysArray
            sqlClause.AppendLine(" LEFT_KEYS like N'%" + Replace(k, "'", "''") + "%' and ")
        Next
        apt.SelectCommand.CommandText = _
            " select top 10 LEFT_KEYS, RIGHT_KEYS from CurationPool.dbo.GOOGLE_SEARCH_KEYWORDS_ASSOCIATION " + _
            " where " + sqlClause.ToString().Substring(0, sqlClause.Length - 6) + _
            " order by NODE_SUPPORT+MSOLAP_NODE_SCORE desc "
        Dim dtDM As New DataTable
        apt.Fill(dtDM)
        If dtDM.Rows.Count > 0 Then
            For Each RowDM As DataRow In dtDM.Rows
                Dim SuggestedKeys As New ArrayList
                KeysArrayForMatching = keysArray.Clone()
                Dim lks() As String = Split(RowDM.Item("LEFT_KEYS"), ","), rks() As String = Split(RowDM.Item("RIGHT_KEYS"), ",")
                For Each lk In lks

                    If Not SearchArrayIgnoreCase(keysArray, Trim(lk)) And Not SearchArrayIgnoreCase(SuggestedKeys, Trim(lk)) Then
                        SuggestedKeys.Add(Trim(lk))
                    End If

                    If SearchArrayIgnoreCase(KeysArrayForMatching, Trim(lk)) Then RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(lk))

                Next
                For Each rk In rks
                    If Not SearchArrayIgnoreCase(keysArray, Trim(rk)) And Not SearchArrayIgnoreCase(SuggestedKeys, Trim(rk)) Then
                        SuggestedKeys.Add(Trim(rk))
                    End If
                    If SearchArrayIgnoreCase(KeysArrayForMatching, Trim(rk)) Then RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(rk))
                Next
                If SuggestedKeys.Count > 0 And KeysArrayForMatching.Count = 0 Then
                    SuggestedKeysSet.Add(SuggestedKeys)
                End If
            Next
        Else
            sqlClause.Clear() : dtDM.Clear() : apt.SelectCommand.CommandText = ""
            For Each k In keysArray
                sqlClause.AppendLine(" LEFT_KEYS like N'%" + Replace(k, "'", "''") + "%' or RIGHT_KEYS like N'%" + Replace(k, "'", "''") + "%' or ")
            Next
            apt.SelectCommand.CommandText = _
                " select top 10 LEFT_KEYS, RIGHT_KEYS from CurationPool.dbo.GOOGLE_SEARCH_KEYWORDS_ASSOCIATION " + _
                " where " + sqlClause.ToString().Substring(0, sqlClause.Length - 5) + _
                " order by NODE_SUPPORT+MSOLAP_NODE_SCORE desc "
            apt.Fill(dtDM)
            If dtDM.Rows.Count > 0 Then
                For Each RowDM As DataRow In dtDM.Rows
                    Dim SuggestedKeys As New ArrayList
                    KeysArrayForMatching = keysArray.Clone()
                    Dim lks() As String = Split(RowDM.Item("LEFT_KEYS"), ","), rks() As String = Split(RowDM.Item("RIGHT_KEYS"), ",")
                    For Each lk In lks

                        If Not SearchArrayIgnoreCase(keysArray, Trim(lk)) And Not SearchArrayIgnoreCase(SuggestedKeys, Trim(lk)) Then
                            SuggestedKeys.Add(Trim(lk))
                        End If

                        If SearchArrayIgnoreCase(KeysArrayForMatching, Trim(lk)) Then RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(lk))

                    Next
                    For Each rk In rks
                        If Not SearchArrayIgnoreCase(keysArray, Trim(rk)) And Not SearchArrayIgnoreCase(SuggestedKeys, Trim(rk)) Then
                            SuggestedKeys.Add(Trim(rk))
                        End If
                        If SearchArrayIgnoreCase(KeysArrayForMatching, Trim(rk)) Then RemoveArrayIgnoreCase(KeysArrayForMatching, Trim(rk))
                    Next
                    If SuggestedKeys.Count > 0 And KeysArrayForMatching.Count = 0 Then
                        SuggestedKeysSet.Add(SuggestedKeys)
                    End If
                Next
            End If
        End If
        conn.Close()
        Dim RetStrings(SuggestedKeysSet.Count - 1) As String
        For i As Integer = 0 To SuggestedKeysSet.Count - 1
            RetStrings(i) = keys + " " + String.Join(" ", SuggestedKeysSet(i).ToArray())
        Next
        Return RetStrings
    End Function

    Public Shared Function SuggestModelByLastKey(keys As String) As String()
        If String.IsNullOrEmpty(Trim(keys)) Then
            Return New String() {}
        End If
        Dim ks() As String = Split(Trim(keys), " "), keysArray As New ArrayList

        For i As Integer = 0 To ks.Length - 1
            ks(i) = Trim(ks(i))
            If Not String.IsNullOrEmpty(ks(i)) AndAlso Not keysArray.Contains(ks(i)) Then
                keysArray.Add(ks(i))
            End If
        Next
        If keysArray.Count = 0 Then
            Return New String() {keys}
        End If

        Dim LastKey As String = keysArray(keysArray.Count - 1)
        Dim sql As String = _
             " select distinct top 10 MODEL_NO  " + _
             " from SAP_PRODUCT (nolock) " + _
             " where MODEL_NO<>'' and MATERIAL_GROUP in ('PRODUCT') and isnumeric(LEFT(MODEL_NO,1))=0 and LEFT(part_no,1) not in ('#')  " + _
             " and isnumeric(LEFT(part_no,1))=0 and LEFT(MODEL_NO,1) not in ('#')  " + _
             " and PART_NO in (select top 100 [key] from freetexttable(SAP_PRODUCT, (MODEL_NO, PART_NO),  @LK) order by [RANK] desc)  " + _
             " order by MODEL_NO  "
        Dim apt As New SqlClient.SqlDataAdapter(sql, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("LK", LastKey)
        Dim dt As New DataTable
        apt.Fill(dt)
        apt.SelectCommand.Connection.Close()
        apt = New SqlClient.SqlDataAdapter("", ConfigurationManager.ConnectionStrings("MYLOCAL").ConnectionString)
        apt.SelectCommand.CommandText = _
            "select top 10 KW as MODEL_NO from MYLOCAL.dbo.GOOGLE_WWW_SEARCH_KEYWORDS (nolock) where KW like N'" + Replace(LastKey, "'", "''") + "%' group by KW order by COUNT(REC_ID) desc"
        Dim dt2 As New DataTable
        apt.Fill(dt2)
        apt.SelectCommand.Connection.Close()
        If dt.Rows.Count = 0 And dt2.Rows.Count = 0 Then Return New String() {keys}
        dt.Merge(dt2)
        Dim retStr(dt.Rows.Count - 1) As String
        Dim formattedKeys As String = String.Join(" ", keysArray.ToArray())
        For i As Integer = 0 To dt.Rows.Count - 1
            If keysArray.Count = 1 Then
                retStr(i) = dt.Rows(i).Item("MODEL_NO")
            Else
                retStr(i) = formattedKeys.Substring(0, formattedKeys.LastIndexOf(" ")) + " " + dt.Rows(i).Item("MODEL_NO")
            End If
        Next
        Return retStr
    End Function

    Public Shared Sub RemoveArrayIgnoreCase(ByRef Ary As ArrayList, SearchValue As String)
        For i As Integer = 0 To Ary.Count - 1
            If String.Equals(Ary(i), SearchValue, StringComparison.CurrentCultureIgnoreCase) Then
                Ary.RemoveAt(i) : Exit For
            End If
        Next
    End Sub

    Public Shared Function SearchArrayIgnoreCase(ByRef Ary As ArrayList, SearchValue As String) As Boolean
        For Each r As String In Ary
            If String.Equals(r, SearchValue, StringComparison.CurrentCultureIgnoreCase) Then Return True
        Next
        Return False
    End Function

    Public Class KeywordsSetAndSuggestList
        Implements IEquatable(Of KeywordsSetAndSuggestList)
        Public Property KeywordsSet As ArrayList : Public Property SuggestList As String()

        Public Sub New()
            KeywordsSet = New ArrayList
        End Sub

        Public Function Equals(other As KeywordsSetAndSuggestList) As Boolean Implements System.IEquatable(Of KeywordsSetAndSuggestList).Equals
            For Each k In Me.KeywordsSet
                Dim Matched As Boolean = False
                For Each ok In other.KeywordsSet
                    If String.Equals(k, ok, StringComparison.CurrentCultureIgnoreCase) Then
                        Matched = True : Exit For
                    End If
                Next
                If Not Matched Then Return False
            Next

            For Each k In other.KeywordsSet
                Dim Matched As Boolean = False
                For Each ok In Me.KeywordsSet
                    If String.Equals(k, ok, StringComparison.CurrentCultureIgnoreCase) Then
                        Matched = True : Exit For
                    End If
                Next
                If Not Matched Then Return False
            Next
            Return True
        End Function
    End Class

#End Region
End Class
