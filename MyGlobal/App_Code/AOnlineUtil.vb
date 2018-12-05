Imports Microsoft.VisualBasic

Public Class AOnlineUtil
    Public Enum SearchType
        ByProduct
        ByContent
    End Enum

    Public Enum MktLanguageType
        ENU
        CHT
        CHS
        JP
        KR
        DE
        FR
        RUS
        ESP
    End Enum

    Public Shared Function MktLangType2ECampaignLang(ByVal MktLang As MktLanguageType) As String
        Select Case MktLang
            Case MktLanguageType.ENU
                Return "English"
            Case MktLanguageType.CHS
                Return "SimplifiedChinese"
            Case MktLanguageType.CHT
                Return "TraditionalChinese"
            Case MktLanguageType.JP
                Return "Japanese"
            Case MktLanguageType.DE
                Return "German"
            Case MktLanguageType.FR
                Return "French"
            Case MktLanguageType.ESP
                Return "Spanish"
            Case MktLanguageType.KR
                Return "Korean"
            Case Else
                Return "All"
        End Select
    End Function

    Public Shared Function MktLangType2BUList(ByVal MktLang As MktLanguageType) As ArrayList
        Dim arRBU As New ArrayList
        Select Case MktLang
            Case MktLanguageType.ENU
                With arRBU
                    .Add("AAC") : .Add("AAU") : .Add("AENC") : .Add("ANADMF") : .Add("AUK") : .Add("ACL") : .Add("ASG") : .Add("AMY")
                End With
            Case MktLanguageType.CHS
                With arRBU
                    .Add("ABJ") ': .Add("ABJ") : .Add("ASH") : .Add("AKMC")
                End With
            Case MktLanguageType.CHT
                With arRBU
                    .Add("ATW")
                End With
            Case MktLanguageType.DE
                arRBU.Add("ADL")
            Case MktLanguageType.ESP
                'arRBU.Add("")
            Case MktLanguageType.FR
                arRBU.Add("AFR")
            Case MktLanguageType.JP
                arRBU.Add("AJP")
            Case MktLanguageType.KR
                arRBU.Add("AKR")
            Case MktLanguageType.RUS
                arRBU.Add("ARU")
        End Select
        Return arRBU
    End Function

    Public Class ContentSearch
        Public strKeywords As String, strSourceName As String, strSourceType As String, strSessionId As String, strUserId As String, strSearchDatetime As DateTime
        Public ResultDt As DataTable, strSearchRowId As String, strWebAppName As String, SearchFlg As Boolean, strErrMsg As String, _CatIdSet As ArrayList, _LitTypeSet As ArrayList
        Public enumSearchType As SearchType, _SearchLanguage As List(Of MktLanguageType)
        Public strSearchSector As String = String.Empty, strSearchTagKwyword As String = String.Empty
        Public ContentCreatedIn As Integer = 7

        Public Sub New(ByVal kw As String, ByVal SessId As String, ByVal SearchRid As String)
            _CatIdSet = New ArrayList : enumSearchType = SearchType.ByProduct : _LitTypeSet = New ArrayList : _SearchLanguage = New List(Of MktLanguageType)
            strKeywords = kw : strSessionId = SessId : strSearchDatetime = Now : strSearchRowId = SearchRid
            If strKeywords = String.Empty Then strKeywords = "*"
            SearchFlg = False : strErrMsg = "" : strWebAppName = ""
        End Sub

        Public Property CatIdSet As ArrayList
            Set(value As ArrayList)
                _CatIdSet = value.Clone()
            End Set
            Get
                Return _CatIdSet
            End Get
        End Property

        Public Property LitTypeSet As ArrayList
            Set(value As ArrayList)
                _LitTypeSet = value.Clone()
            End Set
            Get
                Return _LitTypeSet
            End Get
        End Property

        Public Sub SearchNewContent()
            Dim strLitTypeIn As String = ""
            If LitTypeSet IsNot Nothing AndAlso LitTypeSet.Count > 0 Then
                For i As Integer = 0 To LitTypeSet.Count - 1
                    LitTypeSet(i) = "'" + LitTypeSet(i) + "'"
                Next
                strLitTypeIn = String.Join(",", LitTypeSet.ToArray())
            End If
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select * from ( ")
                If strLitTypeIn.Contains("eDM") Then
                    .AppendFormat(" select distinct '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, a.ROW_ID as SOURCE_ID, 'eDM' as SOURCE_TYPE,  ")
                    .AppendFormat(" case when a.IS_PUBLIC=0 then '<font color=''red'' size=''3''><b>(Internal Only) </b></font>' + a.EMAIL_SUBJECT else a.EMAIL_SUBJECT end as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, 'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL,  ")
                    .AppendFormat(" '' as THUMBNAIL_URL, a.ACTUAL_SEND_DATE as LAST_UPD_DATE, ")
                    .AppendFormat(" isnull(a.DESCRIPTION,'') as DESCRIPTION ")
                    If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 _
                               AndAlso Not MktLangType2ECampaignLang(_SearchLanguage.Item(0)).Equals("All", StringComparison.OrdinalIgnoreCase) Then
                        .AppendFormat(", a.LANGUAGE as LANG ")
                    Else
                        .AppendLine(" ,'' as LANG ")
                    End If
                    .AppendFormat(" from campaign_master a ")
                    .AppendFormat(" where a.ACTUAL_SEND_DATE between '{0}' and '{1}' ", Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd"), Now.ToString("yyyy/MM/dd"))
                    If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 _
                               AndAlso Not MktLangType2ECampaignLang(_SearchLanguage.Item(0)).Equals("All", StringComparison.OrdinalIgnoreCase) Then
                        .AppendLine(String.Format(" and a.LANGUAGE=N'{0}' ", MktLangType2ECampaignLang(_SearchLanguage.Item(0))))
                    End If
                    .AppendFormat(" union ")
                End If
                .AppendFormat(" select distinct '" + strSearchRowId + "' as SOURCE_ROW_ID, 'PIS' as SOURCE_APP, a.LITERATURE_ID as SOURCE_ID, a.GEN_LIT_TYPE as SOURCE_TYPE,   ")
                .AppendFormat(" a.LIT_NAME as NAME, left(cast(isnull(a.LIT_TXT_CONTENT,'') as nvarchar(max)),12000) as CONTENT_TEXT,   ")
                .AppendFormat(" 'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id='+a.LITERATURE_ID as URL, '' as THUMBNAIL_URL, a.LAST_UPD_DATE,  ")
                .AppendFormat(" isnull(a.LIT_DESC,'') as DESCRIPTION ")
                .AppendFormat(", '' as LANG ")
                .AppendFormat(" From PIS_LIT_KM a ")
                .AppendFormat(" Where a.LAST_UPD_DATE>='" & Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd") & "' ")
                .AppendFormat(" and a.GEN_LIT_TYPE in (" + strLitTypeIn + ") ")
                If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                    .AppendLine(" and a.LITERATURE_ID in (select distinct z.LITERATURE_ID from PIS.dbo.LITERATURE z where z.LANG=N'" + _SearchLanguage.Item(0).ToString() + "' and z.LITERATURE_ID is not null) ")
                End If
                .AppendFormat(" union ")
                .AppendFormat(" select distinct '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  ")
                .AppendFormat(" a.TITLE as NAME, left(cast(IsNull(a.ABSTRACT,'') as nvarchar(max)),8000) as CONTENT_TEXT,  ")
                .AppendFormat(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, a.LASTUPDATED as LAST_UPD_DATE, ")
                .AppendFormat(" isnull(a.ABSTRACT,'') as DESCRIPTION ")
                If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then .AppendFormat(", case a.RBU when 'ABJ' then 'CHS' when 'ATW' then 'CHT' when 'ADL' then 'DE' when 'AFR' then 'FR' when 'AJP' then 'JP' when 'AKR' then 'KR' when 'ARU' then 'RUS' else 'ENU' end as LANG ") Else .AppendFormat(" ,'' as LANG ")
                .AppendFormat(" from WWW_RESOURCES a  ")
                .AppendFormat(" Where a.LASTUPDATED>='" & Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd") & "' ")
                .AppendFormat(" and a.CATEGORY_NAME in (" + strLitTypeIn + ") ")
                If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                    Dim arRBU As ArrayList = MktLangType2BUList(_SearchLanguage.Item(0))
                    If arRBU IsNot Nothing AndAlso arRBU.Count > 0 Then
                        For i As Integer = 0 To arRBU.Count - 1
                            arRBU(i) = "'" + arRBU(i) + "'"
                        Next
                        .AppendLine(String.Format(" and a.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
                    End If

                End If
                .AppendFormat(" ) as t ")
                .AppendFormat(" where t.source_type not in ('Video','eCatalog','Product - Datasheet') ")
                .AppendFormat(" and t.NAME not like '%(Internal Only)%' ")
                .AppendFormat(" order by t.LAST_UPD_DATE desc ")
            End With
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            Dim dt As New DataTable
            apt.Fill(dt)
            ResultDt = dt.Copy()
        End Sub


        Public Sub SearchTopRefContent(ByVal Type As String)
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendFormat(" select a.SOURCE_TYPE,  ")
                .AppendFormat(" (select top 1 z.CONTENT_TITLE from AONLINE_SALES_CAMPAIGN_SOURCES z where z.SOURCE_APP=a.SOURCE_APP and z.SOURCE_ID=a.SOURCE_ID) as CONTENT_TITLE, ")
                .AppendFormat(" (select top 1 z.ORIGINAL_URL from AONLINE_SALES_CAMPAIGN_SOURCES z where z.SOURCE_APP=a.SOURCE_APP and z.SOURCE_ID=a.SOURCE_ID) as ORIGINAL_URL, ")
                .AppendFormat(" a.SOURCE_OWNER, COUNT(distinct a.CAMPAIGN_ROW_ID) as RefCounts, a.SOURCE_APP, a.SOURCE_ID, '' as DESCRIPTION ")
                .AppendFormat(" from AONLINE_SALES_CAMPAIGN_SOURCES a left join CAMPAIGN_MASTER b on a.SOURCE_ID=b.ROW_ID ")
                .AppendFormat(" left join WWW_RESOURCES c on a.SOURCE_ID=c.RECORD_ID left join PIS_LIT_KM d on a.SOURCE_ID=d.LITERATURE_ID ")
                .AppendFormat(" where a.ADDED_DATE >='" & Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd") & "' ")
                If Type <> "" Then .AppendFormat(" and a.source_type='{0}' ", Type)
                .AppendFormat(" and a.source_type not in ('Video','eCatalog','Product - Datasheet') ")
                If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                    .AppendFormat(" and ( ")
                    Dim arrLangSql As New ArrayList
                    If Not MktLangType2ECampaignLang(_SearchLanguage.Item(0)).Equals("All", StringComparison.OrdinalIgnoreCase) Then
                        arrLangSql.Add(String.Format(" b.LANGUAGE=N'{0}' ", MktLangType2ECampaignLang(_SearchLanguage.Item(0))))
                    End If
                    Dim arRBU As ArrayList = MktLangType2BUList(_SearchLanguage.Item(0))
                    If arRBU IsNot Nothing AndAlso arRBU.Count > 0 Then
                        For i As Integer = 0 To arRBU.Count - 1
                            arRBU(i) = "'" + arRBU(i) + "'"
                        Next
                        arrLangSql.Add(String.Format(" c.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
                    End If
                    arrLangSql.Add(" d.LITERATURE_ID in (select distinct z.LITERATURE_ID from PIS.dbo.LITERATURE z where z.LANG=N'" + _SearchLanguage.Item(0).ToString() + "' and z.LITERATURE_ID is not null) ")
                    .AppendFormat(" {0} )", String.Join("or", arrLangSql.ToArray()))
                End If
                .AppendFormat(" group by a.SOURCE_APP, a.SOURCE_ID, a.SOURCE_TYPE, a.SOURCE_OWNER order by COUNT(distinct a.CAMPAIGN_ROW_ID) desc, a.SOURCE_TYPE ")
            End With
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            Dim dt As New DataTable
            apt.Fill(dt)
            ResultDt = dt.Copy()
        End Sub

        Public Sub SearchNewEDM()

            Try

                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)

                Dim dt As New DataTable

                Dim sb As New System.Text.StringBuilder
                With sb

                    .AppendLine(String.Format(" select top 200 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, a.ROW_ID as SOURCE_ID, 'eDM' as SOURCE_TYPE,  "))
                    .AppendLine(String.Format(" a.EMAIL_SUBJECT as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, 'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL,  "))
                    .AppendLine(String.Format(" '' as THUMBNAIL_URL, a.ACTUAL_SEND_DATE as LAST_UPD_DATE   "))
                    .AppendLine(String.Format(" From CAMPAIGN_MASTER a "))

                    .AppendLine(String.Format("  Where (a.CREATED_DATE>='" & Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd") & "'"))
                    .AppendLine(String.Format("  or a.ACTUAL_SEND_DATE>='" & Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd") & "')"))
                    .AppendLine(" and a.ACTUAL_SEND_DATE is not null")
                    '.AppendLine(String.Format("  And CAMPAIGN_TYPE in ('Press Release','Brochure','Product - Roadmap','Product - Datasheet','Report','Certificate','Event Presentation','Product - Sales Kit','White Paper')"))
                    .AppendLine(String.Format("  order by a.CREATED_DATE desc, a.ACTUAL_SEND_DATE desc "))
                End With

                Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                apt.Fill(dt)
                conn.Close()
                ResultDt = dt.Copy()
                SearchFlg = True
            Catch ex As Exception
                SearchFlg = False : strErrMsg = ex.ToString()
            End Try

        End Sub


        Public Sub SearchNewMKTLit()

            Try

                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)

                Dim dt As New DataTable

                Dim sb As New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select top 200 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'PIS' as SOURCE_APP, a.LITERATURE_ID as SOURCE_ID, a.GEN_LIT_TYPE as SOURCE_TYPE,   "))
                    .AppendLine(String.Format("  a.LIT_NAME as NAME, left(cast(isnull(a.LIT_TXT_CONTENT,'') as nvarchar(max)),12000) as CONTENT_TEXT,   "))
                    .AppendLine(String.Format("  'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id='+a.LITERATURE_ID as URL, '' as THUMBNAIL_URL, a.LAST_UPD_DATE   "))
                    .AppendLine(String.Format("  From PIS_LIT_KM a "))
                    .AppendLine(String.Format("  Where a.LAST_UPD_DATE>='" & Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd") & "'"))
                    .AppendLine(String.Format("  And GEN_LIT_TYPE in ('Press Release','Brochure','Product - Roadmap','Product - Datasheet','Report','Certificate','Event Presentation','Product - Sales Kit','White Paper')"))
                    .AppendLine(String.Format("  order by a.LAST_UPD_DATE desc, a.LITERATURE_ID "))
                End With

                Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                apt.Fill(dt)
                conn.Close()
                ResultDt = dt.Copy()
                SearchFlg = True
            Catch ex As Exception
                SearchFlg = False : strErrMsg = ex.ToString()
            End Try

        End Sub


        Public Sub SearchNewCMS()

            Try

                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)

                Dim dt As New DataTable

                Dim sb As New System.Text.StringBuilder
                With sb

                    .AppendLine(String.Format(" select distinct top 200 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  "))
                    .AppendLine(String.Format(" a.TITLE as NAME, left(cast(IsNull(a.abstract,'') as nvarchar(max)),8000) as CONTENT_TEXT,  "))
                    .AppendLine(String.Format(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, a.LASTUPDATED as LAST_UPD_DATE  "))
                    .AppendLine(String.Format(" from WWW_RESOURCES a inner join WWW_RESOURCES_DETAIL b on a.RECORD_ID =b.RECORD_ID "))


                    .AppendLine(String.Format("  Where a.LASTUPDATED>='" & Format(DateAdd(DateInterval.Day, -(ContentCreatedIn), Now), "yyyy/MM/dd") & "'"))
                    .AppendLine(String.Format("  And CMS_TYPE in ('Case Study','News','Flash Demo','eCatalog','Video','Curated Content')"))
                    .AppendLine(String.Format("  order by a.LASTUPDATED desc "))
                End With

                Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                apt.Fill(dt)
                conn.Close()
                ResultDt = dt.Copy()
                SearchFlg = True
            Catch ex As Exception
                SearchFlg = False : strErrMsg = ex.ToString()
            End Try

        End Sub

        Public Sub SearchEDM()
            Try
                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                Dim fts As New eBizAEU.FullTextSearch(strKeywords)
                Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
                Dim strCatIdIn As String = ""
                If CatIdSet IsNot Nothing AndAlso CatIdSet.Count > 0 Then
                    For i As Integer = 0 To CatIdSet.Count - 1
                        CatIdSet(i) = "'" + CatIdSet(i) + "'"
                    Next
                    strCatIdIn = String.Join(",", CatIdSet.ToArray())
                End If
                Dim dt As New DataTable
                Dim sb As New System.Text.StringBuilder

                Select Case enumSearchType
                    Case SearchType.ByProduct
                        With sb
                            .AppendLine(String.Format(" select top 200 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, " + _
                                                      " a.ROW_ID as SOURCE_ID, 'eDM' as SOURCE_TYPE, "))
                            .AppendLine(String.Format(" case when a.IS_PUBLIC=0 then '<font color=''red'' size=''3''><b>(Internal Only) </b></font>' + a.EMAIL_SUBJECT else a.EMAIL_SUBJECT end as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, " + _
                                                      "'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL,  "))
                            .AppendLine(String.Format(" '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.ACTUAL_SEND_DATE as LAST_UPD_DATE, "))
                            .AppendLine(String.Format(" isnull(a.DESCRIPTION,'') as DESCRIPTION ")) 'Frank:add description column
                            .AppendLine(String.Format(" from CAMPAIGN_MASTER a  "))
                            .AppendLine(String.Format(" where a.ACTUAL_SEND_DATE is not null and a.ROW_ID in " + _
                                                      " (   select distinct z.campaign_row_id from CAMPAIGN_MODEL_CAT_META z " + _
                                                      "     where z.MODEL_NO like N'%" + Replace(Replace(strKeywords, "'", "''"), "*", "%") + "%' " + _
                                                      IIf(strCatIdIn <> "", " and z.CATEGORY_ID in (" + strCatIdIn + ") ", "") + " ) "))
                            If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 _
                                AndAlso Not MktLangType2ECampaignLang(_SearchLanguage.Item(0)).Equals("All", StringComparison.OrdinalIgnoreCase) Then
                                .AppendLine(String.Format(" and a.LANGUAGE=N'{0}' ", MktLangType2ECampaignLang(_SearchLanguage.Item(0))))
                            End If
                            .AppendLine(String.Format(" order by a.ACTUAL_SEND_DATE desc "))
                        End With
                        'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                        apt.Fill(dt)
                        If strKey = "*" Then
                            sb = New System.Text.StringBuilder
                            With sb
                                .AppendLine(String.Format(" select top 200 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, a.ROW_ID as SOURCE_ID, 'eDM' as SOURCE_TYPE,  "))
                                .AppendLine(String.Format(" case when a.IS_PUBLIC=0 then '<font color=''red'' size=''3''><b>(Internal Only) </b></font>' + a.EMAIL_SUBJECT else a.EMAIL_SUBJECT end as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, 'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL,  "))
                                .AppendLine(String.Format(" '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.ACTUAL_SEND_DATE as LAST_UPD_DATE, "))
                                .AppendLine(String.Format(" isnull(a.DESCRIPTION,'') as DESCRIPTION ")) 'Frank:add description column
                                .AppendLine(String.Format(" from CAMPAIGN_MASTER a "))
                                .AppendLine(String.Format(" where a.ACTUAL_SEND_DATE is not null and a.TEMPLATE_FILE_TEXT like N'%" + Replace(Replace(strKeywords, "'", "''"), "*", "%") + "%' "))
                                If strCatIdIn <> "" Then
                                    .AppendLine(String.Format(" and a.ROW_ID in (select distinct z.campaign_row_id from CAMPAIGN_MODEL_CAT_META z where z.CATEGORY_ID in (" + strCatIdIn + ") ) "))
                                End If
                                If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 _
                               AndAlso Not MktLangType2ECampaignLang(_SearchLanguage.Item(0)).Equals("All", StringComparison.OrdinalIgnoreCase) Then
                                    .AppendLine(String.Format(" and a.LANGUAGE=N'{0}' ", MktLangType2ECampaignLang(_SearchLanguage.Item(0))))
                                End If
                                .AppendLine(String.Format(" order by a.ACTUAL_SEND_DATE desc, a.EMAIL_SUBJECT "))
                            End With
                            Dim dt2 As New DataTable
                            'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                            apt = New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                            apt.Fill(dt2)
                            dt.Merge(dt2)
                        End If
                    Case SearchType.ByContent
                        With sb
                            .AppendLine(String.Format(" select top 200 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, a.ROW_ID as SOURCE_ID, 'eDM' as SOURCE_TYPE,  "))
                            .AppendLine(String.Format(" case when a.IS_PUBLIC=0 then '<font color=''red'' size=''3''><b>(Internal Only) </b></font>' + a.EMAIL_SUBJECT else a.EMAIL_SUBJECT end as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, 'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL,  "))
                            .AppendLine(String.Format(" '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.ACTUAL_SEND_DATE as LAST_UPD_DATE, "))
                            .AppendLine(String.Format(" isnull(a.DESCRIPTION,'') as DESCRIPTION ")) 'Frank:add description column
                            .AppendLine(String.Format(" from CAMPAIGN_MASTER a inner join  "))
                            .AppendLine(String.Format(" (  "))
                            .AppendLine(String.Format(" 	SELECT top 99999 [key] as k, [rank] as r   "))
                            .AppendLine(String.Format(" 	from freetexttable(CAMPAIGN_MASTER, (TEMPLATE_FILE_TEXT, EMAIL_SUBJECT, CAMPAIGN_NAME), N'{0}') ", strKey))
                            .AppendLine(String.Format(" 	order by [rank] desc  "))
                            .AppendLine(String.Format("  )as b on a.ROW_ID=b.k  "))
                            .AppendLine(String.Format(" where a.ACTUAL_SEND_DATE is not null  "))
                            If strCatIdIn <> "" Then
                                .AppendLine(String.Format(" and a.ROW_ID in (select distinct z.campaign_row_id from CAMPAIGN_MODEL_CAT_META z where z.CATEGORY_ID in (" + strCatIdIn + ") ) "))
                            End If
                            If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 _
                               AndAlso Not MktLangType2ECampaignLang(_SearchLanguage.Item(0)).Equals("All", StringComparison.OrdinalIgnoreCase) Then
                                .AppendLine(String.Format(" and a.LANGUAGE=N'{0}' ", MktLangType2ECampaignLang(_SearchLanguage.Item(0))))
                            End If
                            .AppendLine(String.Format(" order by b.r desc, a.ACTUAL_SEND_DATE desc "))
                        End With
                        'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                        apt.Fill(dt)
                        sb = New System.Text.StringBuilder
                        With sb
                            .AppendLine(String.Format(" select top 200 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, a.ROW_ID as SOURCE_ID, 'eDM' as SOURCE_TYPE,  "))
                            .AppendLine(String.Format(" case when a.IS_PUBLIC=0 then '<font color=''red'' size=''3''><b>(Internal Only) </b></font>' + a.EMAIL_SUBJECT else a.EMAIL_SUBJECT end as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, 'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL,  "))
                            .AppendLine(String.Format(" '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.ACTUAL_SEND_DATE as LAST_UPD_DATE, "))
                            .AppendLine(String.Format(" isnull(a.DESCRIPTION,'') as DESCRIPTION ")) 'Frank:add description column
                            .AppendLine(String.Format(" from CAMPAIGN_MASTER a "))
                            .AppendLine(String.Format(" where a.ACTUAL_SEND_DATE is not null and a.TEMPLATE_FILE_TEXT like N'%" + Replace(Replace(strKeywords, "'", "''"), "*", "%") + "%' "))
                            If strCatIdIn <> "" Then
                                .AppendLine(String.Format(" and a.ROW_ID in (select distinct z.campaign_row_id from CAMPAIGN_MODEL_CAT_META z where z.CATEGORY_ID in (" + strCatIdIn + ") ) "))
                            End If
                            If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 _
                               AndAlso Not MktLangType2ECampaignLang(_SearchLanguage.Item(0)).Equals("All", StringComparison.OrdinalIgnoreCase) Then
                                .AppendLine(String.Format(" and a.LANGUAGE=N'{0}' ", MktLangType2ECampaignLang(_SearchLanguage.Item(0))))
                            End If
                            .AppendLine(String.Format(" order by a.ACTUAL_SEND_DATE desc, a.EMAIL_SUBJECT "))
                        End With
                        Dim dt2 As New DataTable
                        'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                        apt = New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                        apt.Fill(dt2)
                        dt.Merge(dt2)
                End Select

                'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                If conn.State <> ConnectionState.Closed Then conn.Close()
                Dim ridSet As New ArrayList
                For Each r As DataRow In dt.Rows
                    If ridSet.Contains(r.Item("SOURCE_ID")) Then
                        r.Delete()
                    Else
                        ridSet.Add(r.Item("SOURCE_ID"))
                    End If
                Next
                dt.AcceptChanges()
                ResultDt = dt.Copy()
                SearchFlg = True
            Catch ex As Exception
                SearchFlg = False : strErrMsg = ex.ToString()
            End Try
        End Sub






        Public Sub SearchMKTLit()
            Try
                Dim strCatIdIn As String = "", strLitTypeIn As String = ""
                If CatIdSet IsNot Nothing AndAlso CatIdSet.Count > 0 Then
                    For i As Integer = 0 To CatIdSet.Count - 1
                        CatIdSet(i) = "'" + CatIdSet(i) + "'"
                    Next
                    strCatIdIn = String.Join(",", CatIdSet.ToArray())
                End If
                If LitTypeSet IsNot Nothing AndAlso LitTypeSet.Count > 0 Then
                    For i As Integer = 0 To LitTypeSet.Count - 1
                        LitTypeSet(i) = "'" + LitTypeSet(i) + "'"
                    Next
                    strLitTypeIn = String.Join(",", LitTypeSet.ToArray())
                End If
                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                Dim fts As New eBizAEU.FullTextSearch(strKeywords)
                Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
                Dim dt As New DataTable
                Select Case enumSearchType
                    Case SearchType.ByProduct
                        Dim sb As New System.Text.StringBuilder
                        With sb
                            .AppendLine(String.Format("  select top 1000 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'PIS' as SOURCE_APP, a.LITERATURE_ID as SOURCE_ID, a.GEN_LIT_TYPE as SOURCE_TYPE,   "))
                            .AppendLine(String.Format("  a.LIT_NAME as NAME, left(cast(isnull(a.LIT_TXT_CONTENT,'') as nvarchar(max)),12000) as CONTENT_TEXT,   "))
                            .AppendLine(String.Format("  'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id='+a.LITERATURE_ID as URL, '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.LAST_UPD_DATE, "))
                            .AppendLine(String.Format("  isnull(a.LIT_DESC,'') as DESCRIPTION ")) 'Frank:add description column
                            .AppendLine(String.Format("  from PIS_LIT_KM a  "))
                            .AppendLine(String.Format("  where 1=1 "))
                            If strKeywords <> String.Empty And strKeywords <> "*" Then
                                .AppendLine(String.Format("  and a.LITERATURE_ID in (select distinct z.literature_id from PIS.dbo.Model_lit z " + _
                                                          " where z.model_name like N'%" + Replace(Replace(strKeywords, "'", "''"), "*", "%") + "%') "))
                            End If
                            If strCatIdIn <> "" Then
                                .AppendLine(String.Format("  and a.model_name in " + _
                                                          " (   select distinct z.model_name from PIS.dbo.Category_Model z " + _
                                                          "     where z.CATEGORY_ID in (" + strCatIdIn + ")) "))
                            End If
                            If strLitTypeIn <> "" Then
                                .AppendLine(String.Format("  and a.GEN_LIT_TYPE in (" + strLitTypeIn + ") "))
                            End If
                            If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                                .AppendLine(" and a.LITERATURE_ID in (select distinct z.LITERATURE_ID from PIS.dbo.LITERATURE z where z.LANG=N'" + _SearchLanguage.Item(0).ToString() + "' and z.LITERATURE_ID is not null) ")
                            End If
                            .AppendLine(String.Format("  order by a.LAST_UPD_DATE desc, a.LITERATURE_ID "))
                        End With
                        'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                        apt.Fill(dt)
                    Case SearchType.ByContent
                        Dim sb As New System.Text.StringBuilder
                        With sb
                            .AppendLine(String.Format(" select top 1000 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'PIS' as SOURCE_APP, a.LITERATURE_ID as SOURCE_ID, a.GEN_LIT_TYPE as SOURCE_TYPE,   "))
                            .AppendLine(String.Format("  a.LIT_NAME as NAME, left(cast(isnull(a.LIT_TXT_CONTENT,'') as nvarchar(max)),12000) as CONTENT_TEXT,   "))
                            .AppendLine(String.Format("  'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id='+a.LITERATURE_ID as URL, '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.LAST_UPD_DATE,   "))
                            .AppendLine(String.Format("  isnull(a.LIT_DESC,'') as DESCRIPTION ")) 'Frank:add description column
                            .AppendLine(String.Format("  from PIS_LIT_KM a inner join "))
                            .AppendLine(String.Format("  ( "))
                            .AppendLine(String.Format(" 	SELECT top 99999 [key] as k, [rank] as r "))
                            .AppendLine(String.Format("     from freetexttable(PIS_LIT_KM, (LIT_NAME, LIT_TXT_CONTENT, PIS_PN, SAP_PN, CATEGORIES), N'{0}')  ", strKey))
                            .AppendLine(String.Format("     order by [rank] desc "))
                            .AppendLine(String.Format("  ) b on a.ROW_ID=b.k "))
                            .AppendLine(String.Format("  where 1=1 "))
                            If strKeywords <> String.Empty And strKeywords <> "*" Then
                                .AppendLine(String.Format("  and a.LITERATURE_ID in (select distinct z.literature_id from PIS.dbo.Model_lit z " + _
                                                          " where z.model_name like N'%" + Replace(Replace(strKeywords, "'", "''"), "*", "%") + "%') "))
                            End If
                            If strCatIdIn <> "" Then
                                .AppendLine(String.Format("  and a.model_name in " + _
                                                          " (   select distinct z.model_name from PIS.dbo.Category_Model z " + _
                                                          "     where z.CATEGORY_ID in (" + strCatIdIn + ")) "))
                            End If
                            If strLitTypeIn <> "" Then
                                .AppendLine(String.Format("  and a.GEN_LIT_TYPE in (" + strLitTypeIn + ") "))
                            End If
                            If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                                .AppendLine(" and a.LITERATURE_ID in (select distinct z.LITERATURE_ID from PIS.dbo.LITERATURE z where z.LANG=N'" + _SearchLanguage.Item(0).ToString() + "' and z.LITERATURE_ID is not null) ")
                            End If
                            .AppendLine(String.Format("  order by a.LAST_UPD_DATE desc, a.LITERATURE_ID "))
                        End With
                        'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                        apt.Fill(dt)
                        sb = New System.Text.StringBuilder
                        With sb
                            .AppendLine(String.Format("  select top 1000 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'PIS' as SOURCE_APP, a.LITERATURE_ID as SOURCE_ID, a.GEN_LIT_TYPE as SOURCE_TYPE,   "))
                            .AppendLine(String.Format("  a.LIT_NAME as NAME, left(cast(isnull(a.LIT_TXT_CONTENT,'') as nvarchar(max)),12000) as CONTENT_TEXT,   "))
                            .AppendLine(String.Format("  'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id='+a.LITERATURE_ID as URL, '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.LAST_UPD_DATE,  "))
                            .AppendLine(String.Format("  isnull(a.LIT_DESC,'') as DESCRIPTION ")) 'Frank:add description column
                            .AppendLine(String.Format("  from PIS_LIT_KM a  "))
                            .AppendLine(String.Format("  where 1=1 and a.GEN_LIT_TYPE not in ('eDM') "))
                            If strKeywords <> String.Empty And strKeywords <> "*" Then
                                .AppendLine(String.Format("  and a.LIT_TXT_CONTENT like N'%" + Replace(Replace(strKeywords, "'", "''"), "*", "%") + "%' "))
                            End If
                            If strCatIdIn <> "" Then
                                .AppendLine(String.Format("  and a.model_name in " + _
                                                          " (   select distinct z.model_name from PIS.dbo.Category_Model z " + _
                                                          "     where z.CATEGORY_ID in (" + strCatIdIn + ")) "))
                            End If
                            If strLitTypeIn <> "" Then
                                .AppendLine(String.Format("  and a.GEN_LIT_TYPE in (" + strLitTypeIn + ") "))
                            End If
                            If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                                .AppendLine(" and a.LITERATURE_ID in (select distinct z.LITERATURE_ID from PIS.dbo.LITERATURE z where z.LANG=N'" + _SearchLanguage.Item(0).ToString() + "' and z.LITERATURE_ID is not null) ")
                            End If
                            .AppendLine(String.Format("  order by a.LAST_UPD_DATE desc, a.LITERATURE_ID "))
                        End With
                        'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                        apt = New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                        Dim dt2 As New DataTable
                        apt.Fill(dt2)
                        dt.Merge(dt2)
                End Select
                conn.Close()
                Dim ridSet As New ArrayList
                For Each r As DataRow In dt.Rows
                    If ridSet.Contains(r.Item("SOURCE_ID")) Then
                        r.Delete()
                    Else
                        ridSet.Add(r.Item("SOURCE_ID"))
                    End If
                Next
                dt.AcceptChanges()
                ResultDt = dt.Copy()
                SearchFlg = True
            Catch ex As Exception
                SearchFlg = False : strErrMsg = ex.ToString()
            End Try
        End Sub

        Public Sub SearchCMS()
            Try
                Dim strCatIdIn As String = "", strLitTypeIn As String = ""
                If CatIdSet IsNot Nothing AndAlso CatIdSet.Count > 0 Then
                    For i As Integer = 0 To CatIdSet.Count - 1
                        CatIdSet(i) = "'" + CatIdSet(i) + "'"
                    Next
                    strCatIdIn = String.Join(",", CatIdSet.ToArray())
                End If
                If LitTypeSet IsNot Nothing AndAlso LitTypeSet.Count > 0 Then
                    For i As Integer = 0 To LitTypeSet.Count - 1
                        LitTypeSet(i) = "'" + LitTypeSet(i) + "'"
                    Next
                    strLitTypeIn = String.Join(",", LitTypeSet.ToArray())
                End If
                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                Dim fts As New eBizAEU.FullTextSearch(strKeywords)
                Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
                Dim sb As New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select distinct top 1000 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  "))
                    .AppendLine(String.Format(" a.TITLE as NAME, left(cast(IsNull(a.abstract,'') as nvarchar(max)),8000) as CONTENT_TEXT,  "))
                    .AppendLine(String.Format(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, c.r as RANK_VALUE, a.LASTUPDATED as LAST_UPD_DATE, "))
                    .AppendLine(String.Format(" isnull(a.ABSTRACT,'') as DESCRIPTION ")) 'Frank:add description column
                    .AppendLine(String.Format(" from WWW_RESOURCES a inner join WWW_RESOURCES_DETAIL b on a.RECORD_ID =b.RECORD_ID inner join  "))
                    .AppendLine(String.Format(" ( "))
                    .AppendLine(String.Format(" 	SELECT top 1000 [key] as k, [rank] as r  "))
                    .AppendLine(String.Format(" 	from freetexttable(WWW_RESOURCES_DETAIL, (CMS_CONTENT), N'{0}')  ", strKey))
                    .AppendLine(String.Format(" 	order by [rank] desc "))
                    .AppendLine(String.Format(" ) c on b.RECORD_ID=c.k "))
                    .AppendLine(" where 1=1 ")
                    If strLitTypeIn <> "" Then
                        .AppendLine(String.Format(" and a.CATEGORY_NAME in (" + strLitTypeIn + ") "))
                    End If
                    If strCatIdIn <> "" Then
                        .AppendLine(String.Format(" and a.record_id in (select z.record_id from V_CMS_PROD_CATEGORY z where z.category_id in (" + strCatIdIn + ") ) "))
                    End If
                    If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                        Dim arRBU As ArrayList = MktLangType2BUList(_SearchLanguage.Item(0))
                        If arRBU IsNot Nothing AndAlso arRBU.Count > 0 Then
                            For i As Integer = 0 To arRBU.Count - 1
                                arRBU(i) = "'" + arRBU(i) + "'"
                            Next
                            .AppendLine(String.Format(" and a.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
                        End If

                    End If
                    .AppendLine(String.Format(" order by c.r desc, a.RECORD_ID  "))
                End With
                'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                Dim dt As New DataTable
                Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
                apt.Fill(dt)
                sb = New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select distinct top 1000 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  "))
                    .AppendLine(String.Format(" a.TITLE as NAME, left(cast(IsNull(a.ABSTRACT,'') as nvarchar(max)),8000) as CONTENT_TEXT,  "))
                    .AppendLine(String.Format(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.LASTUPDATED as LAST_UPD_DATE, "))
                    .AppendLine(String.Format(" isnull(a.ABSTRACT,'') as DESCRIPTION ")) 'Frank:add description column
                    .AppendLine(String.Format(" from WWW_RESOURCES a inner join  "))
                    .AppendLine(String.Format(" ( "))
                    .AppendLine(String.Format(" 	SELECT top 1000 [key] as k, [rank] as r  "))
                    .AppendLine(String.Format(" 	from freetexttable(WWW_RESOURCES, (ABSTRACT,TITLE), N'{0}')  ", strKey))
                    .AppendLine(String.Format(" 	order by [rank] desc "))
                    .AppendLine(String.Format(" ) b on a.ROW_ID=b.k  "))
                    .AppendLine(" where 1=1 ")
                    If strLitTypeIn <> "" Then
                        .AppendLine(String.Format(" and a.CATEGORY_NAME in (" + strLitTypeIn + ") "))
                    End If
                    If strCatIdIn <> "" Then
                        .AppendLine(String.Format(" and a.record_id in (select z.record_id from V_CMS_PROD_CATEGORY z where z.category_id in (" + strCatIdIn + ") ) "))
                    End If
                    If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                        Dim arRBU As ArrayList = MktLangType2BUList(_SearchLanguage.Item(0))
                        If arRBU IsNot Nothing AndAlso arRBU.Count > 0 Then
                            For i As Integer = 0 To arRBU.Count - 1
                                arRBU(i) = "'" + arRBU(i) + "'"
                            Next
                            .AppendLine(String.Format(" and a.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
                        End If

                    End If
                    .AppendLine(String.Format(" order by b.r desc, a.RECORD_ID  "))
                End With
                'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                apt.SelectCommand.CommandText = sb.ToString()
                Dim dt2 As New DataTable
                If conn.State <> ConnectionState.Open Then conn.Open()
                apt.Fill(dt2)

                sb = New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select distinct top 1000 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  "))
                    .AppendLine(String.Format(" a.TITLE as NAME, left(cast(IsNull(a.ABSTRACT,'') as nvarchar(max)),8000) as CONTENT_TEXT,  "))
                    .AppendLine(String.Format(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.LASTUPDATED as LAST_UPD_DATE, "))
                    .AppendLine(String.Format(" isnull(a.ABSTRACT,'') as DESCRIPTION ")) 'Frank:add description column
                    .AppendLine(String.Format(" from WWW_RESOURCES a left join WWW_RESOURCES_DETAIL b on a.record_id=b.record_id "))
                    .AppendLine(String.Format(" where (a.TITLE like N'%{0}%' or a.abstract like N'%{0}%' or b.CMS_CONTENT like N'%{0}%') ", Replace(Replace(strKeywords, "'", "''"), "*", "%")))
                    If strLitTypeIn <> "" Then
                        .AppendLine(String.Format(" and a.CATEGORY_NAME in (" + strLitTypeIn + ") "))
                    End If
                    If strCatIdIn <> "" Then
                        .AppendLine(String.Format(" and a.record_id in (select z.record_id from V_CMS_PROD_CATEGORY z where z.category_id in (" + strCatIdIn + ") ) "))
                    End If
                    If _SearchLanguage IsNot Nothing AndAlso _SearchLanguage.Count > 0 Then
                        Dim arRBU As ArrayList = MktLangType2BUList(_SearchLanguage.Item(0))
                        If arRBU IsNot Nothing AndAlso arRBU.Count > 0 Then
                            For i As Integer = 0 To arRBU.Count - 1
                                arRBU(i) = "'" + arRBU(i) + "'"
                            Next
                            .AppendLine(String.Format(" and a.RBU in ({0}) ", String.Join(",", arRBU.ToArray())))
                        End If

                    End If
                    .AppendLine(String.Format(" order by a.TITLE  "))
                End With
                'Util.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "sql", sb.ToString(), False, "", "")
                apt.SelectCommand.CommandText = sb.ToString()
                dt2 = New DataTable
                If conn.State <> ConnectionState.Open Then conn.Open()
                apt.Fill(dt2)
                conn.Close()
                dt.Merge(dt2)
                Dim ridSet As New ArrayList
                For Each r As DataRow In dt.Rows
                    If ridSet.Contains(r.Item("SOURCE_ID")) Then
                        r.Delete()
                    Else
                        ridSet.Add(r.Item("SOURCE_ID"))
                    End If
                Next
                dt.AcceptChanges()
                ResultDt = dt.Copy()
                SearchFlg = True
            Catch ex As Exception
                SearchFlg = False : strErrMsg = ex.ToString()
            End Try
        End Sub

    End Class

    Class AOnlineSalesCampaign
        Public CampaignRowId As String
        Public Shared strLinkTags() As String = {"//a", "//area", "//iframe"}, strImgTags() As String = {"//img", "//td", "//tr", "//table", "input"}
        Public Shared strAOCampaignPregfixURL As String = Util.GetRuntimeSiteUrl() + "/ec/ao_DummyContactId_"
        Public Sub New(ByVal UserId As String)
            Dim tmpRowId As String = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
            Dim strCmd As String = _
                " delete from AONLINE_SALES_CAMPAIGN where CREATED_BY=@CBY and IS_DRAFT=1; " + _
                " INSERT INTO AONLINE_SALES_CAMPAIGN " + _
                " (ROW_ID, CREATED_BY) " + _
                " VALUES (@ROWID, @CBY) "
            Dim cmd As New SqlClient.SqlCommand(strCmd, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            With cmd.Parameters
                .AddWithValue("ROWID", tmpRowId) : .AddWithValue("CBY", UserId)
            End With
            cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
            CampaignRowId = tmpRowId
        End Sub

        Public Shared Function GetCampaignAllDetail(ByVal CampaignId As String) As DataSet
            Dim ds As New DataSet("CampaignAll")
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal_New").ConnectionString)
            Dim dtCampaign As New DataTable("AONLINE_SALES_CAMPAIGN"), dtContacts As New DataTable("AONLINE_SALES_CAMPAIGN_CONTACT")
            Dim dtClickLog As New DataTable("AONLINE_CAMPAIGN_OPENCLICK_LOG"), dtMktRef As New DataTable("AONLINE_SALES_CAMPAIGN_SOURCES")
            ds.Tables.Add(dtCampaign) : ds.Tables.Add(dtContacts) : ds.Tables.Add(dtClickLog) : ds.Tables.Add(dtMktRef)
            Dim apt As New SqlClient.SqlDataAdapter("", conn)
            'apt.SelectCommand.Connection = conn
            apt.SelectCommand.CommandText = _
                " select top 1 a.ROW_ID, a.CREATED_BY, a.CREATED_DATE, a.SUBJECT, a.CONTENT_TEXT, a.ACTUAL_SEND_DATE " + _
                " from AONLINE_SALES_CAMPAIGN a where a.ROW_ID=@CID "
            apt.SelectCommand.Parameters.AddWithValue("CID", CampaignId)
            apt.Fill(dtCampaign)
            If dtCampaign.Rows.Count = 1 Then
                apt.SelectCommand.CommandText = _
                    " select top 200 a.ROW_ID, a.CONTACT_EMAIL, a.IS_CLICKED, a.IS_OPENED, a.SENT_DATE, a.LAST_OPENED_TIME, a.LAST_CLICKED_TIME  " + _
                    " from AONLINE_SALES_CAMPAIGN_CONTACT a  " + _
                    " where a.CAMPAIGN_ROW_ID=@CID " + _
                    " order by a.CONTACT_EMAIL  "
                apt.SelectCommand.Parameters.Clear()
                apt.SelectCommand.Parameters.AddWithValue("CID", CampaignId)
                apt.Fill(dtContacts)
                apt.SelectCommand.CommandText = _
                    " select top 1000 a.URL, a.LOG_TIME, b.CONTACT_EMAIL " + _
                    " from AONLINE_CAMPAIGN_OPENCLICK_LOG a inner join AONLINE_SALES_CAMPAIGN_CONTACT b on a.CONTACT_ID=b.ROW_ID  " + _
                    " where a.CAMPAIGN_ROW_ID=@CID " + _
                    " order by a.LOG_TIME desc "
                apt.SelectCommand.Parameters.Clear()
                apt.SelectCommand.Parameters.AddWithValue("CID", CampaignId)
                apt.Fill(dtClickLog)
                apt.SelectCommand.CommandText = _
                    " select SOURCE_ID, SOURCE_APP, CONTENT_TITLE, ORIGINAL_URL, ADDED_DATE from AONLINE_SALES_CAMPAIGN_SOURCES a where a.CAMPAIGN_ROW_ID=@CID order by a.ADDED_DATE "
                apt.SelectCommand.Parameters.Clear()
                apt.SelectCommand.Parameters.AddWithValue("CID", CampaignId)
                apt.Fill(dtMktRef)
                Return ds
            End If
        End Function

        Public Shared Function CreateMyContactList(ByVal ListName As String) As String
            Dim tmpRowId As String = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
            Dim strCmd As String = _
                " INSERT INTO AONLINE_SALES_CONTACTLIST_MASTER (ROW_ID, USERID, LIST_NAME) VALUES (@ROWID, @CBY, @LISTNAME) "
            Dim cmd As New SqlClient.SqlCommand(strCmd, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            With cmd.Parameters
                .AddWithValue("ROWID", tmpRowId) : .AddWithValue("CBY", HttpContext.Current.User.Identity.Name) : .AddWithValue("LISTNAME", ListName)
            End With
            cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
            Return tmpRowId
        End Function

        Public Shared Function DeleteMyContactList(ByVal ListID As String) As Boolean
            Dim tmpRowId As String = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
            Dim strCmd As String = _
                " delete from AONLINE_SALES_CONTACTLIST_MASTER where row_id=@RID; delete from AONLINE_SALES_CONTACTLIST_DETAIL where LIST_ID=@RID "
            Dim cmd As New SqlClient.SqlCommand(strCmd, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            With cmd.Parameters
                .AddWithValue("RID", ListID)
            End With
            cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
            Return True
        End Function

        Public Shared Function AddContactEmails2ContactList(ByVal ListId As String, ByRef EmailArrayList As ArrayList) As Boolean
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
            conn.Open()
            Dim cmd As New SqlClient.SqlCommand("select count(ROW_ID) from AONLINE_SALES_CONTACTLIST_MASTER where ROW_ID=@RID", conn)
            cmd.Parameters.AddWithValue("RID", ListId)
            If CInt(cmd.ExecuteScalar()) = 1 Then
                For Each m As String In EmailArrayList
                    If Util.IsValidEmailFormat(m) Then
                        cmd = New SqlClient.SqlCommand( _
                            "delete from AONLINE_SALES_CONTACTLIST_DETAIL where LIST_ID=@LID and CONTACT_EMAIL=@MAIL; " + _
                            "INSERT INTO AONLINE_SALES_CONTACTLIST_DETAIL (ROW_ID, LIST_ID, CONTACT_EMAIL) VALUES (@RID, @LID, @MAIL)", _
                            conn)
                        cmd.Parameters.AddWithValue("RID", System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30))
                        cmd.Parameters.AddWithValue("LID", ListId) : cmd.Parameters.AddWithValue("MAIL", m)
                        cmd.ExecuteNonQuery()
                    End If
                Next
                conn.Close() : Return True
            End If
            conn.Close() : Return False
        End Function

        Public Shared Function ImportContacts(ByVal RowId As String, UserId As String, ByRef arrContact As ArrayList) As Boolean
            If arrContact.Count > 0 Then
                Dim impDt As New DataTable
                With impDt.Columns
                    .Add("CAMPAIGN_ROW_ID") : .Add("ROW_ID") : .Add("CONTACT_EMAIL")
                End With
                Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
                Dim cmd As New SqlClient.SqlCommand("delete from AONLINE_SALES_CAMPAIGN_CONTACT where campaign_row_id=@RID", conn)
                cmd.Parameters.AddWithValue("RID", RowId)
                conn.Open()
                cmd.ExecuteNonQuery()
                For Each c As String In arrContact
                    Dim nr As DataRow = impDt.NewRow()
                    nr.Item("CAMPAIGN_ROW_ID") = RowId : nr.Item("ROW_ID") = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10) : nr.Item("CONTACT_EMAIL") = c
                    impDt.Rows.Add(nr)
                Next
                Dim bk As New SqlClient.SqlBulkCopy(conn)
                bk.DestinationTableName = "AONLINE_SALES_CAMPAIGN_CONTACT"
                bk.WriteToServer(impDt)
                conn.Close()
                Return True
            End If
            Return False
        End Function

        Public Shared Function ReplaceAndUpdateCampaignContentHyperlinkImg(ByVal StrContent As String, ByVal strCampaignId As String, ByRef strReplacedContent As String) As DataTable
            
            Dim dtCampaignLink As New DataTable
            With dtCampaignLink.Columns
                .Add("campaign_row_id") : .Add("row_id") : .Add("url")
            End With
            Dim doc1 As New HtmlAgilityPack.HtmlDocument
            doc1.LoadHtml(StrContent)
            For Each strLink As String In strLinkTags
                Dim linkNodes As HtmlAgilityPack.HtmlNodeCollection = doc1.DocumentNode.SelectNodes(strLink)
                If linkNodes IsNot Nothing AndAlso linkNodes.Count > 0 Then
                    For Each linkNode As HtmlAgilityPack.HtmlNode In linkNodes
                        If linkNode.HasAttributes Then
                            If linkNode.Attributes("href") IsNot Nothing AndAlso linkNode.Attributes("href").Value IsNot Nothing _
                                AndAlso Not String.IsNullOrEmpty(linkNode.Attributes("href").Value) AndAlso _
                                ( _
                                    linkNode.Attributes("href").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                    linkNode.Attributes("href").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                    ) Then
                                Dim newHrefRow As DataRow = dtCampaignLink.NewRow()
                                newHrefRow.Item("campaign_row_id") = strCampaignId
                                newHrefRow.Item("row_id") = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
                                newHrefRow.Item("url") = linkNode.Attributes("href").Value
                                dtCampaignLink.Rows.Add(newHrefRow)
                                linkNode.Attributes("href").Value = strAOCampaignPregfixURL + strCampaignId + "_" + newHrefRow.Item("row_id") + ".jsp"
                            Else
                                If linkNode.Attributes("src") IsNot Nothing AndAlso linkNode.Attributes("src").Value IsNot Nothing _
                                    AndAlso Not String.IsNullOrEmpty(linkNode.Attributes("src").Value) AndAlso _
                                    ( _
                                        linkNode.Attributes("src").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                        linkNode.Attributes("src").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                        ) Then
                                    Dim newHrefRow As DataRow = dtCampaignLink.NewRow()
                                    newHrefRow.Item("campaign_row_id") = strCampaignId
                                    newHrefRow.Item("row_id") = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
                                    newHrefRow.Item("url") = linkNode.Attributes("src").Value
                                    dtCampaignLink.Rows.Add(newHrefRow)
                                    linkNode.Attributes("src").Value = strAOCampaignPregfixURL + strCampaignId + "_" + newHrefRow.Item("row_id") + ".jsp"
                                End If
                            End If
                        End If
                    Next
                End If
            Next
            For Each strImg As String In strImgTags
                Dim imgNodes As HtmlAgilityPack.HtmlNodeCollection = doc1.DocumentNode.SelectNodes(strImg)
                If imgNodes IsNot Nothing AndAlso imgNodes.Count > 0 Then
                    For Each imgNode As HtmlAgilityPack.HtmlNode In imgNodes
                        If imgNode.HasAttributes Then
                            If imgNode.Attributes("background") IsNot Nothing AndAlso imgNode.Attributes("background").Value IsNot Nothing _
                                AndAlso Not String.IsNullOrEmpty(imgNode.Attributes("background").Value) AndAlso _
                                ( _
                                    imgNode.Attributes("background").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                    imgNode.Attributes("background").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                    ) Then
                                Dim newImgfRow As DataRow = dtCampaignLink.NewRow()
                                newImgfRow.Item("campaign_row_id") = strCampaignId
                                newImgfRow.Item("row_id") = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
                                newImgfRow.Item("url") = imgNode.Attributes("background").Value
                                dtCampaignLink.Rows.Add(newImgfRow)
                                imgNode.Attributes("background").Value = strAOCampaignPregfixURL + strCampaignId + "_" + newImgfRow.Item("row_id") + ".jsp"
                            Else
                                If imgNode.Attributes("src") IsNot Nothing AndAlso imgNode.Attributes("src").Value IsNot Nothing _
                                    AndAlso Not String.IsNullOrEmpty(imgNode.Attributes("src").Value) AndAlso _
                                    ( _
                                        imgNode.Attributes("src").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                        imgNode.Attributes("src").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                        ) Then
                                    Dim newImgfRow As DataRow = dtCampaignLink.NewRow()
                                    newImgfRow.Item("campaign_row_id") = strCampaignId
                                    newImgfRow.Item("row_id") = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 30)
                                    newImgfRow.Item("url") = imgNode.Attributes("src").Value
                                    dtCampaignLink.Rows.Add(newImgfRow)
                                    imgNode.Attributes("src").Value = strAOCampaignPregfixURL + strCampaignId + "_" + newImgfRow.Item("row_id") + ".jsp"
                                End If
                            End If
                        End If
                    Next
                End If
            Next
            strReplacedContent = doc1.DocumentNode.OuterHtml
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
            Dim cmd As New SqlClient.SqlCommand("update AONLINE_SALES_CAMPAIGN set content_text=@CT where row_id=@RID", conn)
            cmd.Parameters.AddWithValue("CT", strReplacedContent) : cmd.Parameters.AddWithValue("RID", strCampaignId)
            conn.Open()
            cmd.ExecuteNonQuery()
            Dim bk As New SqlClient.SqlBulkCopy(conn)
            bk.DestinationTableName = "AONLINE_SALES_CAMPAIGN_URL"
            If conn.State <> ConnectionState.Open Then conn.Open()
            bk.WriteToServer(dtCampaignLink)
            conn.Close()
            Return dtCampaignLink
        End Function

        Public Shared Function ReplaceHyperlinkImgWithContactRowId(ByVal StrContent As String, ByVal ContactRowId As String, ByRef strReplacedContent As String) As Boolean
            Dim doc1 As New HtmlAgilityPack.HtmlDocument
            doc1.LoadHtml(StrContent)
            For Each strLink As String In strLinkTags
                Dim linkNodes As HtmlAgilityPack.HtmlNodeCollection = doc1.DocumentNode.SelectNodes(strLink)
                If linkNodes IsNot Nothing AndAlso linkNodes.Count > 0 Then
                    For Each linkNode As HtmlAgilityPack.HtmlNode In linkNodes
                        If linkNode.HasAttributes Then
                            If linkNode.Attributes("href") IsNot Nothing AndAlso linkNode.Attributes("href").Value IsNot Nothing _
                                AndAlso Not String.IsNullOrEmpty(linkNode.Attributes("href").Value) AndAlso _
                                ( _
                                    linkNode.Attributes("href").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                    linkNode.Attributes("href").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                    ) Then
                                linkNode.Attributes("href").Value = Replace(linkNode.Attributes("href").Value, "/ec/ao_DummyContactId_", "/ec/ao_" + ContactRowId + "_")
                                'linkNode.Attributes("href").Value =""
                            Else
                                If linkNode.Attributes("src") IsNot Nothing AndAlso linkNode.Attributes("src").Value IsNot Nothing _
                                    AndAlso Not String.IsNullOrEmpty(linkNode.Attributes("src").Value) AndAlso _
                                    ( _
                                        linkNode.Attributes("src").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                        linkNode.Attributes("src").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                        ) Then

                                    linkNode.Attributes("src").Value = Replace(linkNode.Attributes("src").Value, "/ec/ao_DummyContactId_", "/ec/ao_" + ContactRowId + "_")
                                End If
                            End If
                        End If
                    Next
                End If
            Next
            For Each strImg As String In strImgTags
                Dim imgNodes As HtmlAgilityPack.HtmlNodeCollection = doc1.DocumentNode.SelectNodes(strImg)
                If imgNodes IsNot Nothing AndAlso imgNodes.Count > 0 Then
                    For Each imgNode As HtmlAgilityPack.HtmlNode In imgNodes
                        If imgNode.HasAttributes Then
                            If imgNode.Attributes("background") IsNot Nothing AndAlso imgNode.Attributes("background").Value IsNot Nothing _
                                AndAlso Not String.IsNullOrEmpty(imgNode.Attributes("background").Value) AndAlso _
                                ( _
                                    imgNode.Attributes("background").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                    imgNode.Attributes("background").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                    ) Then
                                imgNode.Attributes("background").Value = Replace(imgNode.Attributes("background").Value, "/ec/ao_DummyContactId_", "/ec/ao_" + ContactRowId + "_")
                            Else
                                If imgNode.Attributes("src") IsNot Nothing AndAlso imgNode.Attributes("src").Value IsNot Nothing _
                                    AndAlso Not String.IsNullOrEmpty(imgNode.Attributes("src").Value) AndAlso _
                                    ( _
                                        imgNode.Attributes("src").Value.StartsWith("http://", StringComparison.OrdinalIgnoreCase) OrElse _
                                        imgNode.Attributes("src").Value.StartsWith("https://", StringComparison.OrdinalIgnoreCase) _
                                        ) Then
                                    imgNode.Attributes("src").Value = Replace(imgNode.Attributes("src").Value, "/ec/ao_DummyContactId_", "/ec/ao_" + ContactRowId + "_")
                                End If
                            End If
                        End If
                    Next
                End If
            Next
            strReplacedContent = doc1.DocumentNode.OuterHtml
            Return True
        End Function

        Public Shared Function ExportContactFromMyContactList(ByVal ListId As String, ByRef arrContact As ArrayList) As Integer
            arrContact = New ArrayList
            Dim apt As New SqlClient.SqlDataAdapter("select distinct CONTACT_EMAIL from AONLINE_SALES_CONTACTLIST_DETAIL where LIST_ID=@LID order by CONTACT_EMAIL", _
                                                    New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            Dim dt As New DataTable
            apt.SelectCommand.Parameters.AddWithValue("LID", ListId)
            apt.Fill(dt)
            apt.SelectCommand.Connection.Close()
            For Each r As DataRow In dt.Rows
                arrContact.Add(r.Item("CONTACT_EMAIL"))
            Next
            Return arrContact.Count
        End Function

        Public Shared Function Draft2Formal(ByVal RowId As String, ByVal UserId As String) As Boolean
            Dim cmd As New SqlClient.SqlCommand( _
               "update AONLINE_SALES_CAMPAIGN set IS_DRAFT=0, LAST_UPD_BY=@LBY, LAST_UPD_DATE=getdate(), ACTUAL_SEND_DATE=getdate() where ROW_ID=@RID", _
               New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            With cmd.Parameters
                .AddWithValue("RID", RowId) : .AddWithValue("LBY", UserId)
            End With
            cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
            Return True
        End Function

        Public Shared Function UpdateContent(ByVal RowId As String, ByVal Subject As String, ByVal Greeting As String, ByVal Content As String, _
                                             ByVal Signature As String, ByVal UserId As String) As Boolean
            Dim cmd As New SqlClient.SqlCommand( _
              " update AONLINE_SALES_CAMPAIGN set SUBJECT=@TITLE, CONTENT_TEXT=@CONT, GREETING=@GT, SIGNATURE=@SG, LAST_UPD_BY=@LBY, LAST_UPD_DATE=getdate() where ROW_ID=@RID; " + _
              " delete from AONLINE_SALES_CAMPAIGN_SOURCES where campaign_row_id=@RID; " + _
              " insert into AONLINE_SALES_CAMPAIGN_SOURCES " + _
              " select @RID as campaign_row_id, SOURCE_ID, SOURCE_APP, CONTENT_TITLE, ORIGINAL_URL, GETDATE() as ADDED_DATE, " + _
              " case when SOURCE_APP='eCampaign' then 'eDM' when SOURCE_APP='PIS' then (select top 1 LIT_TYPE from [ACLSQL6\SQL2008R2].[PIS].dbo.LITERATURE where LITERATURE_ID=SOURCE_ID) when SOURCE_APP='CMS' then (select top 1 CMS_TYPE from [ACLSQL6\SQL2008R2].[MyAdvantechGlobal].dbo.WWW_RESOURCES where RECORD_ID=SOURCE_ID) end as source_type, " + _
              " case when SOURCE_APP='eCampaign' then (select top 1 b.PrimarySmtpAddress from [ACLSQL6\SQL2008R2].[MyAdvantechGlobal].dbo.CAMPAIGN_MASTER a LEFT join [ACLSQL6\SQL2008R2].[MyAdvantechGlobal].dbo.ADVANTECH_ADDRESSBOOK b on (select top 1 z.data from dbo.Split(a.CREATED_BY,'\') z where z.id=2)=(select top 1 z.data from dbo.Split(b.PrimarySmtpAddress,'@') z where z.id=1) where a.ROW_ID=SOURCE_ID) when SOURCE_APP='PIS' then (select top 1 CREATED_BY from [ACLSQL6\SQL2008R2].[PIS].dbo.LITERATURE where LITERATURE_ID=SOURCE_ID) when SOURCE_APP='CMS' then (select top 1 AUTHOR_EMAIL from [ACLSQL6\SQL2008R2].[MyAdvantechGlobal].dbo.WWW_RESOURCES_AUTHOR where RECORD_ID=SOURCE_ID) end as source_owner from AONLINE_SALES_CONTENT_CART where SESSIONID=@SID; " + _
              " delete from AONLINE_SALES_CONTENT_CART where SESSIONID=@SID ", _
              New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            With cmd.Parameters
                .AddWithValue("RID", RowId) : .AddWithValue("LBY", UserId) : .AddWithValue("TITLE", Subject) : .AddWithValue("CONT", Content)
                .AddWithValue("GT", Greeting) : .AddWithValue("SG", Signature) : .AddWithValue("SID", HttpContext.Current.Session.SessionID)

            End With
            cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
            Return True
        End Function

        Public Shared Function AddContentToMyContentCart(ByVal SourceId As String, ByVal Content_Title As String, ByVal SourceApp As String, ByVal OriginalUrl As String) As Boolean
            Dim cmd As New SqlClient.SqlCommand( _
              " delete from AONLINE_SALES_CONTENT_CART where sessionid=@SEID and source_id=@SRCID; " + _
              " insert into AONLINE_SALES_CONTENT_CART (SESSIONID, SOURCE_ID, CONTENT_TITLE, SOURCE_APP, USERID,ADDED_DATE, ORIGINAL_URL) " + _
              " values (@SEID, @SRCID, @CT, @STYPE, @UID, getdate(), @OURL)", _
              New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            With cmd.Parameters
                .AddWithValue("SEID", HttpContext.Current.Session.SessionID) : .AddWithValue("SRCID", SourceId) : .AddWithValue("CT", Content_Title)
                .AddWithValue("STYPE", SourceApp) : .AddWithValue("UID", HttpContext.Current.User.Identity.Name) : .AddWithValue("OURL", OriginalUrl)
            End With
            cmd.Connection.Open() : cmd.ExecuteNonQuery() : cmd.Connection.Close()
            Return True
        End Function

        Public Shared Function MyContentCartCount() As Integer
            Dim cmd As New SqlClient.SqlCommand( _
              " select count(source_id) from AONLINE_SALES_CONTENT_CART where SESSIONID=@SEID", _
              New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString))
            With cmd.Parameters
                .AddWithValue("SEID", HttpContext.Current.Session.SessionID)
            End With
            cmd.Connection.Open() : Dim i As Integer = cmd.ExecuteScalar() : cmd.Connection.Close()
            Return i
        End Function

        Public Shared Function MyContentCartContents() As String
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MYLOCAL_NEW").ConnectionString)
            Dim conn2 As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim apt As New SqlClient.SqlDataAdapter( _
              " select top 100 SOURCE_ID, SOURCE_APP from AONLINE_SALES_CONTENT_CART where SESSIONID=@SEID order by ADDED_DATE desc", conn)
            apt.SelectCommand.Parameters.AddWithValue("SEID", HttpContext.Current.Session.SessionID)
            Dim dt As New DataTable
            apt.Fill(dt)
            Dim sb As New System.Text.StringBuilder
            sb.AppendLine("<table width='100%'>")
            For Each r As DataRow In dt.Rows
                Dim cmd As New SqlClient.SqlCommand("", conn2)
                cmd.Parameters.AddWithValue("RID", r.Item("SOURCE_ID"))
                Dim tmpContent As String = String.Empty
                If conn2.State <> ConnectionState.Open Then conn2.Open()
                Select Case r.Item("SOURCE_APP")
                    Case "PIS"
                        cmd.CommandText = "select top 1 IsNull(LIT_TXT_CONTENT,'') as c from PIS_LIT_KM where row_id=@RID"
                        tmpContent = cmd.ExecuteScalar()
                    Case "eCampaign"
                        cmd.CommandText = "select top 1 IsNull(TEMPLATE_FILE_TEXT,'') as c from campaign_master where row_id=@RID"
                        tmpContent = cmd.ExecuteScalar()
                    Case "CMS"
                        Dim CA As CMSDAL.CMSArticle = Nothing
                        If CMSDAL.GetCMSContentByRecordId(r.Item("SOURCE_ID"), CA) Then
                            tmpContent = _
                                "<table width='100%'>" + _
                                "   <tr><td>" + CA.Abstract + "</td></tr>" + _
                                "   <tr><td>" + CA.Content + "</td></tr>" + _
                                "</table>"
                        End If
                        'cmd.CommandText = "select top 1 IsNull(CMS_CONTENT,'') as c from WWW_RESOURCES_DETAIL where RECORD_ID=@RID"
                        'tmpContent = cmd.ExecuteScalar()
                        'If tmpContent Is Nothing OrElse String.IsNullOrEmpty(tmpContent) Then
                        '    cmd.CommandText = "select top 1 IsNull(ABSTRACT,'') as c from WWW_RESOURCES where RECORD_ID=@RID"
                        '    tmpContent = cmd.ExecuteScalar()
                        'End If

                End Select
                If tmpContent IsNot Nothing AndAlso tmpContent <> String.Empty Then
                    sb.AppendLine("<tr><td>" + tmpContent + "</td></tr>")
                End If
            Next
            sb.AppendLine("</table>")
            If conn.State <> ConnectionState.Closed Then conn.Close()
            If conn2.State <> ConnectionState.Closed Then conn2.Close()
            If dt.Rows.Count > 0 Then Return sb.ToString()
            Return ""
        End Function

        Public Shared Function SendAOnlineEDM(ByRef ToList() As CampaignSendToEmail, ByVal Subject As String, ByVal Body As String, _
                                              ByVal IsHtml As Boolean, ByRef Attachments() As System.Net.Mail.Attachment, _
                                              ByRef CcList() As String, ByRef BccList() As String, ByRef ErrMsg As String) As Boolean
            If HttpContext.Current.User.Identity.IsAuthenticated = False Then
                ErrMsg = "Not yet logged in" : Return False
            End If
            ErrMsg = ""
            Dim AmazonClient As New Amazon.SimpleEmail.AmazonSimpleEmailServiceClient("AKIAIKMEOIM7JRSWOFIA", "HjIuHdUQ5GEG7w/volh/mgOvOmmqbRvH2lH9KX6S")
            Dim ACLSMTPClient As Net.Mail.SmtpClient = Nothing
            Dim sender_email As String = HttpContext.Current.User.Identity.Name, sender_name As String = Util.GetNameVonEmail(sender_email)
            For Each email As CampaignSendToEmail In ToList
                Dim AmazonSendErr As String = "", ACLSMTPErr As String = ""
                Dim htmlMessage As New Net.Mail.MailMessage(sender_email, email.SendToEmail.Address, Subject, Body)
                If Attachments IsNot Nothing AndAlso Attachments.Length > 0 Then
                    For Each att As System.Net.Mail.Attachment In Attachments
                        att.ContentStream.Position = 0
                        htmlMessage.Attachments.Add(New System.Net.Mail.Attachment(att.ContentStream, att.Name))
                    Next
                End If
                If CcList IsNot Nothing AndAlso CcList.Length > 0 Then
                    For Each cc As String In CcList
                        If Util.IsValidEmailFormat(cc) Then htmlMessage.CC.Add(cc)
                    Next
                End If
                If BccList IsNot Nothing AndAlso BccList.Length > 0 Then
                    For Each bcc As String In BccList
                        If Util.IsValidEmailFormat(bcc) Then htmlMessage.Bcc.Add(bcc)
                    Next
                End If
                Dim ReplyMail As New Net.Mail.MailAddress(sender_email, sender_name, Text.Encoding.UTF8)
                htmlMessage.ReplyTo = ReplyMail : htmlMessage.IsBodyHtml = IsHtml
                If Util.IsInternalUser(email.SendToEmail.Address) = False AndAlso eCampaignContact.GetContactBouncedTimes(email.SendToEmail.Address) = 0 Then
                    If MailUtil.SendFromAmazon(htmlMessage, sender_email, sender_name, AmazonClient, AmazonSendErr) Then
                        email.SendStatus = True : email.SendVia = "Amazon"
                    Else
                        email.SendStatus = False : email.ErrorMsg = AmazonSendErr : ErrMsg += AmazonSendErr
                        If MailUtil.SendFromACLSMTP(htmlMessage, sender_email, sender_name, ACLSMTPClient, ACLSMTPErr) Then
                            email.SendStatus = True : email.SendVia = ACLSMTPClient.Host
                        Else
                            ErrMsg += AmazonSendErr + ";" + ACLSMTPErr
                            email.SendStatus = False
                        End If
                    End If
                Else
                    If Util.IsInternalUser(email.SendToEmail.Address) = False Then
                        email.SendStatus = MailUtil.SendFromACLSMTP(htmlMessage, sender_email, sender_name, ACLSMTPClient, ACLSMTPErr)
                        If email.SendStatus = False Then email.SendStatus = MailUtil.SendFromAEUExchange(htmlMessage, sender_email, sender_name, ACLSMTPClient, ACLSMTPErr)
                    Else
                        email.SendStatus = MailUtil.SendFromAEUSMTP(htmlMessage, sender_email, sender_name, ACLSMTPClient, ACLSMTPErr)
                    End If
                    If email.SendStatus Then
                        email.SendVia = ACLSMTPClient.Host
                    Else
                        ErrMsg += AmazonSendErr + ";" + ACLSMTPErr
                    End If
                End If
            Next
            If ErrMsg = "" Then
                Return True
            Else
                Return False
            End If
        End Function

        Public Enum AOnlineEDMLinkType
            URL
            IMG
        End Enum

        Public Shared Function IsPC(ByVal Client_Agent As String, ByRef platform As String) As Boolean
            Dim u As String = Client_Agent
            Dim d As New Regex("Windows|FreeBSD|SunOS|Linux |Macintosh|Mac_PowerPC|QNX|BeOS|OS/2", RegexOptions.IgnoreCase)
            If d.IsMatch(u) Then platform = d.Match(u).Value : Return True
            Return False
        End Function

        Public Shared Function IsMobile(ByVal Client_Agent As String, ByRef platform As String) As Boolean
            Dim u As String = Client_Agent
            Dim d As New Regex("iPod|iPhone|iPad|BlackBerry|HTC|Nokia|Samsung|XiaoMi|Motorola|BenQ|SonyEricsson|Huawe|LG|Lenovo", RegexOptions.IgnoreCase)
            Dim v As New Regex("Android|Windows Phone", RegexOptions.IgnoreCase)
            If d.IsMatch(u) Then
                platform = d.Match(u).Value : Return True
            Else
                If v.IsMatch(u) Then
                    Select Case v.Match(u).Value
                        Case "Android"
                            platform = "Other Andriod Phone"
                        Case "Windows Phone"
                            platform = "Other Windows Phone"
                        Case Else
                            platform = "Others"
                    End Select
                    Return True
                End If
            End If

            Return False
        End Function

        Public Shared Function IsRobot(ByVal Client_Agent As String, ByRef platform As String) As Boolean
            Dim u As String = Client_Agent
            Dim d As New Regex("nuhk|Googlebot|Yammybot|Openbot|Slurp|MSNBot|Ask Jeeves/Teoma|ia_archiver", RegexOptions.IgnoreCase)
            If d.IsMatch(u) Then platform = d.Match(u).Value : Return True
            Return False
        End Function

        Public Shared Function GetAndLogAOnlineEDMContactOpenClickLink(ByVal RequestLink As String, ByVal ClientIP As String, ByRef LinkType As AOnlineEDMLinkType, ByVal ClientAgent As String) As String
            'LinkType = AOnlineEDMLinkType.URL
            'Dim strProcLink As String = RequestLink.Substring(RequestLink.LastIndexOf("/") + 1)
            'strProcLink = strProcLink.Substring(0, strProcLink.Length - (strProcLink.Length - strProcLink.LastIndexOf(".")))
            'Dim strLinkParts() As String = Split(strProcLink, "_")
            'Dim ContactId As String = strLinkParts(1)
            'Dim CampaignId As String = strLinkParts(2)
            'Dim LinkId As String = strLinkParts(3)
            'Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            'Dim cmd As New SqlClient.SqlCommand("select top 1 URL from AONLINE_SALES_CAMPAIGN_URL where CAMPAIGN_ROW_ID=@CID and ROW_ID=@RID", conn)
            'cmd.Parameters.AddWithValue("CID", CampaignId) : cmd.Parameters.AddWithValue("RID", LinkId)
            'conn.Open()
            'Dim tmpUrl As String = cmd.ExecuteScalar()
            'conn.Close()
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim num As Integer = 0
            Dim tmpUrl As String = RequestLink

            '預設跑30圈，抓出實體URL(圖片)就馬上跳出
            For i As Integer = 0 To 30
                Dim strProcLink As String = tmpUrl.Substring(tmpUrl.LastIndexOf("/") + 1)
                strProcLink = strProcLink.Substring(0, strProcLink.Length - (strProcLink.Length - strProcLink.LastIndexOf(".")))
                Dim strLinkParts() As String = Split(strProcLink, "_")
                Dim ContactId As String = strLinkParts(1)
                Dim CampaignId As String = strLinkParts(2)
                Dim LinkId As String = strLinkParts(3)
                tmpUrl = CheckAOnlineEDMContactOpenClickLink(CampaignId, LinkId, ClientIP, LinkType)

                If String.IsNullOrEmpty(tmpUrl) = False Then
                    If tmpUrl.Contains(".") Then
                        Dim strExtType As String = tmpUrl.Substring(tmpUrl.LastIndexOf(".") + 1).ToLower()
                        Dim PicTypes() As String = {"jpg", "gif", "png", "bmp", "tiff", "jpeg"}
                        If PicTypes.Contains(strExtType) Or strExtType Like "ashx*" Then 'JJ 2014/6/27：加入.ashx因為也能轉出圖片，所以也算正常可以導回了
                            LinkType = AOnlineEDMLinkType.IMG
                        Else
                            LinkType = AOnlineEDMLinkType.URL
                        End If
                    End If

                    '第一次才需要寫入
                    If num = 0 Then
                        Dim platform As String = "", device As String = ""
                        If ClientAgent IsNot Nothing AndAlso ClientAgent <> "" Then
                            If IsMobile(ClientAgent, platform) Then
                                device = "Mobile"
                            ElseIf IsPC(ClientAgent, platform) Then
                                device = "PC"
                            ElseIf IsRobot(ClientAgent, platform) Then
                                device = "Robot"
                            End If
                        End If
                        Dim cmd As New SqlClient.SqlCommand( _
                         IIf(ContactId.Equals("dummycontactid", StringComparison.OrdinalIgnoreCase) OrElse LinkType = AOnlineEDMLinkType.IMG, "", _
                            " insert into AONLINE_CAMPAIGN_OPENCLICK_LOG (campaign_row_id, contact_id, URL, CLIENT_IP, CLIENT_AGENT, CLIENT_DEVICE, CLIENT_PLATFORM) values(@CAMPID,@CONTACTID,@URL,@CIP,@AGENT,@DEVICE,@PLATFORM); ") + _
                            " update AONLINE_SALES_CAMPAIGN_CONTACT set IS_OPENED=1, LAST_OPENED_TIME=getdate() where CAMPAIGN_ROW_ID=@CAMPID and ROW_ID=@CONTACTID; " + _
                            IIf(LinkType = AOnlineEDMLinkType.URL, _
                            " update AONLINE_SALES_CAMPAIGN_CONTACT set IS_CLICKED=1, LAST_CLICKED_TIME=getdate() where CAMPAIGN_ROW_ID=@CAMPID and ROW_ID=@CONTACTID; ", ""), conn)
                        With cmd.Parameters
                            .AddWithValue("CAMPID", CampaignId) : .AddWithValue("CONTACTID", ContactId) : .AddWithValue("URL", tmpUrl) : .AddWithValue("CIP", ClientIP)
                            .AddWithValue("AGENT", ClientAgent) : .AddWithValue("DEVICE", device) : .AddWithValue("PLATFORM", platform)
                        End With
                        conn.Open() : cmd.ExecuteNonQuery() : conn.Close()
                        num += 1
                    End If

                End If

                If LinkType = AOnlineEDMLinkType.IMG OrElse _
                    (LinkType = AOnlineEDMLinkType.URL AndAlso Not (tmpUrl.ToLower.Contains("/ec/qr_") OrElse tmpUrl.ToLower.Contains("/ec/ao_"))) Then
                    Exit For
                End If
            Next

            Return tmpUrl
        End Function

        Public Shared Function CheckAOnlineEDMContactOpenClickLink(ByVal CampaignId As String, ByVal LinkId As String, ByVal ClientIP As String, ByRef LinkType As AOnlineEDMLinkType) As String
            LinkType = AOnlineEDMLinkType.URL

            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim cmd As New SqlClient.SqlCommand("select top 1 URL from AONLINE_SALES_CAMPAIGN_URL where CAMPAIGN_ROW_ID=@CID and ROW_ID=@RID", conn)
            cmd.Parameters.AddWithValue("CID", CampaignId) : cmd.Parameters.AddWithValue("RID", LinkId)
            conn.Open()
            Dim tmpUrl As String = cmd.ExecuteScalar()
            conn.Close()
            Return tmpUrl
        End Function

    End Class

End Class

Public Class KM_Search
    Public strKeywords As String, strSourceName As String, strSourceType As String, strSessionId As String, strUserId As String, strSearchDatetime As DateTime
    Public ResultDt As DataTable, strSearchRowId As String
    Public strWebAppName As String
    Public SearchFlg As Boolean, strErrMsg As String
    Public Sub New(ByVal kw As String, ByVal SessId As String, ByVal SearchRid As String)
        strKeywords = kw : strSessionId = SessId : strSearchDatetime = Now : strSearchRowId = SearchRid
        If strKeywords = String.Empty Then strKeywords = "*"
        SearchFlg = False : strErrMsg = "" : strWebAppName = ""
    End Sub

    Public Sub SearchAEFTP()
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim fts As New eBizAEU.FullTextSearch(strKeywords)
            Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'FTP' as SOURCE_APP, a.ROW_ID as SOURCE_ID, " + _
                                          " 'FTP' as SOURCE_TYPE, left(a.FILE_NAME,500) as NAME,  "))
                .AppendLine(String.Format(" LEFT(IsNull(a.file_content,''),4000) as CONTENT_TEXT, 'ftp://ftp.advantech.com.tw'+REMOTE_PATH as ORIGINAL_URL, '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.FILE_DATE as LAST_UPD_DATE "))
                .AppendLine(String.Format(" from AE_FTP_CONTENT a inner join "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	SELECT top 99999 [key] as k, [rank] as r  "))
                .AppendLine(String.Format(" 	from freetexttable(AE_FTP_CONTENT, (FILE_NAME, file_content), N'{0}')  ", strKey))
                .AppendLine(String.Format(" 	order by [rank] desc "))
                .AppendLine(String.Format(" ) as b on a.ROW_ID=b.k where 1=1 "))
                .AppendLine(String.Format(" order by b.r desc, a.FILE_DATE desc  "))
            End With
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            apt.Fill(dt)
            conn.Close()
            Dim ridSet As New ArrayList
            For Each r As DataRow In dt.Rows
                If ridSet.Contains(r.Item("SOURCE_ID")) Then
                    r.Delete()
                Else
                    ridSet.Add(r.Item("SOURCE_ID"))
                End If
            Next
            dt.AcceptChanges()
            ResultDt = dt.Copy()
            SearchFlg = True
        Catch ex As Exception
            SearchFlg = False : strErrMsg = ex.ToString()
        End Try
    End Sub

    Public Sub SearchWEB()
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim fts As New eBizAEU.FullTextSearch(strKeywords)
            Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'WEB' as SOURCE_APP, a.KEYID as SOURCE_ID, " + _
                                          " a.APPNAME as SOURCE_TYPE, left(a.Title,500) as NAME,  "))
                .AppendLine(String.Format(" LEFT(IsNull(a.text,''),4000) as CONTENT_TEXT, left(a.ResponseUri,1000) as ORIGINAL_URL, '' as THUMBNAIL_URL, ISNULL((b.r+a.GOOGLE_PAGERANK),0) as RANK_VALUE, a.LastModified as LAST_UPD_DATE "))
                .AppendLine(String.Format(" from MY_WEB_SEARCH a inner join "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	SELECT top 99999 [key] as k, [rank] as r  "))
                .AppendLine(String.Format(" 	from freetexttable(MY_WEB_SEARCH, (title, text, Meta_Description), N'{0}')  ", strKey))
                .AppendLine(String.Format(" 	order by [rank] desc "))
                .AppendLine(String.Format(" ) as b on a.KEYID=b.k where 1=1 "))
                If strWebAppName <> String.Empty Then .AppendLine(String.Format(" and a.APPNAME='" + strWebAppName + "' "))
                .AppendLine(String.Format(" order by (b.r+a.GOOGLE_PAGERANK) desc, a.KEYID  "))
            End With
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            apt.Fill(dt)

            sb = New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'WEB' as SOURCE_APP, a.KEYID as SOURCE_ID, " + _
                                          " a.APPNAME as SOURCE_TYPE, left(a.Title,500) as NAME,  "))
                .AppendLine(String.Format(" LEFT(isnull(a.text,''),4000) as CONTENT_TEXT, left(a.ResponseUri,1000) as ORIGINAL_URL, '' as THUMBNAIL_URL, ISNULL(a.GOOGLE_PAGERANK,0)+200 as RANK_VALUE, a.LastModified as LAST_UPD_DATE "))
                .AppendLine(String.Format(" from MY_WEB_SEARCH a "))
                .AppendLine(String.Format(" where (a.Title like N'%{0}%' or a.Meta_Keywords like N'%{0}%' or a.Meta_Keywords like N'%{0}%') ", _
                                          Replace(Replace(strKeywords, "'", "''"), "*", "%")))
                If strWebAppName <> String.Empty Then .AppendLine(String.Format(" and a.APPNAME=N'" + strWebAppName + "' "))
                .AppendLine(String.Format(" order by a.GOOGLE_PAGERANK desc "))
            End With
            apt.SelectCommand.CommandText = sb.ToString()
            Dim dt2 As New DataTable
            If conn.State <> ConnectionState.Open Then conn.Open()
            apt.Fill(dt2)
            dt.Merge(dt2)
            conn.Close()
            Dim ridSet As New ArrayList
            For Each r As DataRow In dt.Rows
                If ridSet.Contains(r.Item("SOURCE_ID")) Then
                    r.Delete()
                Else
                    ridSet.Add(r.Item("SOURCE_ID"))
                End If
            Next
            dt.AcceptChanges()
            ResultDt = dt.Copy()
            SearchFlg = True
        Catch ex As Exception
            SearchFlg = False : strErrMsg = ex.ToString()
        End Try
    End Sub

    Public Sub SearchEDM()
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim fts As New eBizAEU.FullTextSearch(strKeywords)
            Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, a.ROW_ID as SOURCE_ID, a.CAMPAIGN_TYPE as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" a.EMAIL_SUBJECT as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, 'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL, '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.ACTUAL_SEND_DATE as LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from CAMPAIGN_MASTER a inner join "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	SELECT top 99999 [key] as k, [rank] as r  "))
                .AppendLine(String.Format(" 	from freetexttable(CAMPAIGN_MASTER, (EMAIL_SUBJECT, TEMPLATE_FILE_TEXT, CAMPAIGN_NAME), N'{0}')  ", strKey))
                .AppendLine(String.Format(" 	order by [rank] desc "))
                .AppendLine(String.Format("  )as b on a.ROW_ID=b.k "))
                .AppendLine(String.Format(" where a.IS_PUBLIC=1 and a.ACTUAL_SEND_DATE is not null "))
                .AppendLine(String.Format(" order by b.r desc, a.EMAIL_SUBJECT "))
            End With
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            apt.Fill(dt)

            sb = New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'eCampaign' as SOURCE_APP, a.ROW_ID as SOURCE_ID, a.CAMPAIGN_TYPE as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" a.EMAIL_SUBJECT as NAME, LEFT(isnull(a.TEMPLATE_FILE_TEXT,''), 12000) as CONTENT_TEXT, 'http://my.advantech.com/Includes/GetTemplate.ashx?RowId='+a.ROW_ID as URL, '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.ACTUAL_SEND_DATE as LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from CAMPAIGN_MASTER a "))
                .AppendLine(String.Format(" where a.IS_PUBLIC=1 and a.ACTUAL_SEND_DATE is not null and  "))
                .AppendLine(String.Format(" (a.EMAIL_SUBJECT like N'%{0}%' or a.TEMPLATE_FILE_TEXT like N'%{0}%' or a.CAMPAIGN_NAME like N'%{0}%') ", _
                                          Replace(Replace(strKeywords, "'", "''"), "*", "%")))
                .AppendLine(String.Format(" order by a.ACTUAL_SEND_DATE desc "))
            End With
            apt.SelectCommand.CommandText = sb.ToString()
            Dim dt2 As New DataTable
            If conn.State <> ConnectionState.Open Then conn.Open()
            apt.Fill(dt2)
            conn.Close()
            dt.Merge(dt2)
            Dim ridSet As New ArrayList
            For Each r As DataRow In dt.Rows
                If ridSet.Contains(r.Item("SOURCE_ID")) Then
                    r.Delete()
                Else
                    ridSet.Add(r.Item("SOURCE_ID"))
                End If
            Next
            dt.AcceptChanges()
            ResultDt = dt.Copy()
            SearchFlg = True
        Catch ex As Exception
            SearchFlg = False : strErrMsg = ex.ToString()
        End Try
    End Sub

    Public Sub SearchMKTLit()
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim fts As New eBizAEU.FullTextSearch(strKeywords)
            Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'PIS' as SOURCE_APP, a.LITERATURE_ID as SOURCE_ID, a.LIT_TYPE as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" a.LIT_NAME as NAME, left(cast(isnull(a.LIT_TXT_CONTENT,'') as nvarchar(max)),12000) as CONTENT_TEXT,  "))
                .AppendLine(String.Format(" 'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id='+a.LITERATURE_ID as URL, '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from PIS_LIT_KM a inner join "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	SELECT top 99999 [key] as k, [rank] as r  "))
                .AppendLine(String.Format(" 	from freetexttable(PIS_LIT_KM, (LIT_NAME, LIT_TXT_CONTENT, PIS_PN, SAP_PN, CATEGORIES), N'{0}')  ", strKey))
                .AppendLine(String.Format(" 	order by [rank] desc "))
                .AppendLine(String.Format(" )as b on a.ROW_ID=b.k "))
                .AppendLine(String.Format(" order by b.r desc "))
            End With
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            apt.Fill(dt)

            sb = New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'PIS' as SOURCE_APP, a.LITERATURE_ID as SOURCE_ID, a.LIT_TYPE as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" a.LIT_NAME as NAME, left(cast(isnull(a.LIT_TXT_CONTENT,'') as nvarchar(max)),12000) as CONTENT_TEXT,  "))
                .AppendLine(String.Format(" 'http://downloadt.advantech.com/download/downloadlit.aspx?lit_id='+a.LITERATURE_ID as URL, '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from PIS_LIT_KM a "))
                .AppendLine(String.Format(" where (a.LIT_NAME like N'%{0}%' or a.PIS_PN like N'%{0}%') ", Replace(Replace(strKeywords, "'", "''"), "*", "%")))
                .AppendLine(String.Format(" order by a.ROW_ID "))
            End With
            apt.SelectCommand.CommandText = sb.ToString()
            Dim dt2 As New DataTable
            If conn.State <> ConnectionState.Open Then conn.Open()
            apt.Fill(dt2)
            dt.Merge(dt2)
            conn.Close()
            Dim ridSet As New ArrayList
            For Each r As DataRow In dt.Rows
                If ridSet.Contains(r.Item("SOURCE_ID")) Then
                    r.Delete()
                Else
                    ridSet.Add(r.Item("SOURCE_ID"))
                End If
            Next
            dt.AcceptChanges()
            ResultDt = dt.Copy()
            SearchFlg = True
        Catch ex As Exception
            SearchFlg = False : strErrMsg = ex.ToString()
        End Try
    End Sub

    Public Sub SearchSR()
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim fts As New eBizAEU.FullTextSearch(strKeywords)
            Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'SR' as SOURCE_APP, a.ROW_ID as SOURCE_ID, a.SR_TYPE as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" IsNull(a.SR_TITLE,'') as NAME, left(cast(isnull(a.DESC_TEXT,'') as nvarchar(max)),4000) as CONTENT_TEXT, '' as URL, '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.LAST_UPD as LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from SIEBEL_SR a inner join "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	SELECT top 99999 [key] as k, [rank] as r  "))
                .AppendLine(String.Format(" 	from freetexttable(SIEBEL_SR, (SR_TITLE, DESC_TEXT, MODEL_NO), N'{0}')  ", strKey))
                .AppendLine(String.Format(" 	order by [rank] desc "))
                .AppendLine(String.Format(" )as b on a.ROW_ID=b.k "))
                .AppendLine(String.Format(" order by b.r desc, a.created desc, a.ROW_ID  "))

            End With
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            apt.Fill(dt)

            sb = New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 50 '" + strSearchRowId + "' as SOURCE_ROW_ID, 'SR' as SOURCE_APP, a.ROW_ID as SOURCE_ID, a.SR_TYPE as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" IsNull(a.SR_TITLE,'') as NAME, left(cast(isnull(a.DESC_TEXT,'') as nvarchar(max)),4000) as CONTENT_TEXT, '' as URL, '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.LAST_UPD as LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from SIEBEL_SR a  "))
                .AppendLine(String.Format(" where (a.SR_TITLE like N'%{0}%' or a.DESC_TEXT like N'%{0}%' or a.MODEL_NO like N'%{0}%') ", Replace(Replace(strKeywords, "'", "''"), "*", "%")))
                .AppendLine(String.Format(" order by a.CREATED desc, a.ROW_ID  "))
            End With
            apt.SelectCommand.CommandText = sb.ToString()
            Dim dt2 As New DataTable
            If conn.State <> ConnectionState.Open Then conn.Open()
            apt.Fill(dt2)
            conn.Close()
            dt.Merge(dt2)
            Dim ridSet As New ArrayList
            For Each r As DataRow In dt.Rows
                If ridSet.Contains(r.Item("SOURCE_ID")) Then
                    r.Delete()
                Else
                    ridSet.Add(r.Item("SOURCE_ID"))
                End If
            Next
            dt.AcceptChanges()
            ResultDt = dt.Copy()
            SearchFlg = True
        Catch ex As Exception
            SearchFlg = False : strErrMsg = ex.ToString()
        End Try
    End Sub

    Public Sub SearchCMS()
        Try
            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim fts As New eBizAEU.FullTextSearch(strKeywords)
            Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select distinct top 50 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" a.TITLE as NAME, left(cast(IsNull(b.CMS_CONTENT,'') as nvarchar(max)),8000) as CONTENT_TEXT,  "))
                .AppendLine(String.Format(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, c.r as RANK_VALUE, a.LASTUPDATED as LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from WWW_RESOURCES a inner join WWW_RESOURCES_DETAIL b on a.RECORD_ID =b.RECORD_ID inner join  "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	SELECT top 500 [key] as k, [rank] as r  "))
                .AppendLine(String.Format(" 	from freetexttable(WWW_RESOURCES_DETAIL, (CMS_CONTENT), N'{0}')  ", strKey))
                .AppendLine(String.Format(" 	order by [rank] desc "))
                .AppendLine(String.Format(" ) c on b.RECORD_ID=c.k "))
                .AppendLine(String.Format(" order by c.r desc, a.RECORD_ID  "))
            End With
            Dim dt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), conn)
            apt.Fill(dt)
            sb = New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select distinct top 50 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" a.TITLE as NAME, left(cast(IsNull(a.ABSTRACT,'') as nvarchar(max)),8000) as CONTENT_TEXT,  "))
                .AppendLine(String.Format(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, b.r as RANK_VALUE, a.LASTUPDATED as LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from WWW_RESOURCES a inner join  "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	SELECT top 500 [key] as k, [rank] as r  "))
                .AppendLine(String.Format(" 	from freetexttable(WWW_RESOURCES, (ABSTRACT,TITLE), N'{0}')  ", strKey))
                .AppendLine(String.Format(" 	order by [rank] desc "))
                .AppendLine(String.Format(" ) b on a.ROW_ID=b.k  "))
                .AppendLine(String.Format(" order by b.r desc, a.RECORD_ID  "))
            End With
            apt.SelectCommand.CommandText = sb.ToString()
            Dim dt2 As New DataTable
            If conn.State <> ConnectionState.Open Then conn.Open()
            apt.Fill(dt2)

            sb = New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select distinct top 50 '" + strSearchRowId + "' as SEARCH_ROW_ID, 'CMS' as SOURCE_APP, a.RECORD_ID as SOURCE_ID, a.CATEGORY_NAME as SOURCE_TYPE,  "))
                .AppendLine(String.Format(" a.TITLE as NAME, left(cast(IsNull(a.ABSTRACT,'') as nvarchar(max)),8000) as CONTENT_TEXT,  "))
                .AppendLine(String.Format(" 'http://resources.advantech.com/Resources/Details.aspx?rid='+a.RECORD_ID as URL, '' as THUMBNAIL_URL, 1000 as RANK_VALUE, a.LASTUPDATED as LAST_UPD_DATE  "))
                .AppendLine(String.Format(" from WWW_RESOURCES a  "))
                .AppendLine(String.Format(" where a.TITLE like N'%{0}%' ", Replace(Replace(strKeywords, "'", "''"), "*", "%")))
                .AppendLine(String.Format(" order by a.TITLE  "))
            End With
            apt.SelectCommand.CommandText = sb.ToString()
            dt2 = New DataTable
            If conn.State <> ConnectionState.Open Then conn.Open()
            apt.Fill(dt2)
            conn.Close()
            dt.Merge(dt2)
            Dim ridSet As New ArrayList
            For Each r As DataRow In dt.Rows
                If ridSet.Contains(r.Item("SOURCE_ID")) Then
                    r.Delete()
                Else
                    ridSet.Add(r.Item("SOURCE_ID"))
                End If
            Next
            dt.AcceptChanges()
            ResultDt = dt.Copy()
            SearchFlg = True
        Catch ex As Exception
            SearchFlg = False : strErrMsg = ex.ToString()
        End Try
    End Sub

End Class
