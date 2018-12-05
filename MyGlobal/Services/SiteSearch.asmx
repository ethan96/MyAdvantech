<%@ WebService Language="VB" Class="SiteSearch" %>

Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="MyAdvantech")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
Public Class SiteSearch
    Inherits System.Web.Services.WebService
    
    <WebMethod()> _
    Public Function HelloKitty() As String
        Return "Hello Kitty"
    End Function
    
    Public Shared intRowsPerPage As Integer = 10
    
    Public Class SearchCriteria
        Public Property Keyword As String : Public Property StartIdx As Integer
    End Class
    
    Public Class SearchResult
        Public Property Records As List(Of SearchRecord) : Public Property TotalMatchedRows As Integer
    End Class
    
    Public Class SearchRecord
        Implements IComparable(Of SearchRecord)
        Public Property Title As String : Public Property MetaDesc As String : Public Property Rank As Integer : Public Property Uri As String : Public Property Idx As Integer

        Public Function CompareTo(other As SearchRecord) As Integer Implements System.IComparable(Of SearchRecord).CompareTo
            If Me.Idx > other.Idx Then
                Return 1
            ElseIf Me.Idx < other.Idx Then
                Return -1
            Else
                Return 0
            End If
        End Function
    End Class
    
    <WebMethod()> _
    Public Function SearchUSWWWSite(ByVal SearchCriteria1 As SearchCriteria) As List(Of SearchRecord)
        
        If SearchCriteria1.Keyword.ToUpper().Contains("DMS") Then Return SearchUSWWWSiteV2(SearchCriteria1)
        
        Dim Results As New List(Of SearchRecord), tmpResults As List(Of SearchRecord) = Nothing
        If String.IsNullOrEmpty(SearchCriteria1.Keyword) Then Return Results
        'HttpContext.Current.Cache("SiteSearchCache") = Nothing
        Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Dim SiteSearchCache As Dictionary(Of String, List(Of SearchRecord)) = Nothing
        Try
            SiteSearchCache = CType(HttpContext.Current.Cache("SiteSearch9"), Dictionary(Of String, List(Of SearchRecord)))
        Catch ex As InvalidCastException
            SiteSearchCache = Nothing : HttpContext.Current.Cache.Remove("SiteSearch9")
        End Try
        If SiteSearchCache Is Nothing Then
            SiteSearchCache = New Dictionary(Of String, List(Of SearchRecord))
            HttpContext.Current.Cache.Add("SiteSearch9", SiteSearchCache, Nothing, DateTime.Now.AddMinutes(5), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        
        If SiteSearchCache.ContainsKey(SearchCriteria1.Keyword) Then
            tmpResults = SiteSearchCache.Item(SearchCriteria1.Keyword)
            'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Got cache for " + SearchCriteria1.Keyword, tmpResults.Count.ToString())
        Else
            'If False Then
            '    tmpResults = SiteSearchV30(SearchCriteria1.Keyword)
            'Else
            SearchCriteria1.Keyword = Replace(SearchCriteria1.Keyword, "*", "%")
            Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(Replace(SearchCriteria1.Keyword, "*", "%")))
            Dim strKey As String = fts.NormalForm.Replace("'", "''")
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 1000 a.Title, a.Meta_Description, b.[rank], a.ResponseUri, ROW_NUMBER() OVER(ORDER BY b.[rank]-a.Depth DESC) AS idx "))
                .AppendLine(String.Format(" from MY_WEB_SEARCH a inner join "))
                .AppendLine(String.Format(" (  "))
                .AppendLine(String.Format(" 	SELECT top 1000 [key], [rank]  "))
                .AppendLine(String.Format(" 	from freetexttable(MY_WEB_SEARCH, (title, text, Meta_Description),  "))
                .AppendLine(String.Format(" 	N'{0}') order by [rank] desc ", strKey))
                .AppendLine(String.Format(" ) b on a.keyid=b.[key]  "))
                .AppendLine(" where a.APPNAME='Advantech US' ")
                .AppendLine(String.Format(" order by b.[rank]-a.Depth desc "))
            End With
            Dim dt As New DataTable("Result")
            'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Site Search Sql " + SearchCriteria1.Keyword, sb.ToString())
            Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            apt.Fill(dt)
            
            If dt.Rows.Count = 0 Then
                sb = New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select top 1000 a.Title, a.Meta_Description, b.[rank], a.ResponseUri, ROW_NUMBER() OVER(ORDER BY b.[rank]-a.Depth DESC) AS idx "))
                    .AppendLine(String.Format(" from MY_WEB_SEARCH a inner join "))
                    .AppendLine(String.Format(" (  "))
                    .AppendLine(String.Format("     select top 1000 z.keyid as [key], 1000 as [rank] "))
                    .AppendLine(String.Format("     from MY_WEB_SEARCH z where (z.Title like N'%{0}%' or z.Text like N'%{0}%')  ", SearchCriteria1.Keyword.Trim().Replace("'", "''").Replace("*", "%")))
                    .AppendLine(String.Format("     order by z.Title "))
                    .AppendLine(String.Format(" ) b on a.keyid=b.[key]  "))
                    .AppendLine(" where a.APPNAME='Advantech US' ")
                    .AppendLine(String.Format(" order by b.[rank]-a.Depth desc "))
                End With
                If apt.SelectCommand.Connection.State <> ConnectionState.Open Then apt.SelectCommand.Connection.Open()
                apt.SelectCommand.CommandText = sb.ToString()
                apt.Fill(dt)
            End If
            
            apt.SelectCommand.Connection.Close()
            tmpResults = New List(Of SearchRecord)
            For Each r As DataRow In dt.Rows
                Dim SearchRecord1 As New SearchRecord
                With SearchRecord1
                    .Title = r.Item("Title") : .MetaDesc = r.Item("Meta_Description") : .Uri = r.Item("ResponseUri") : .Rank = r.Item("Rank") : .Idx = r.Item("idx")
                End With
                tmpResults.Add(SearchRecord1)
            Next
            SiteSearchCache.Add(SearchCriteria1.Keyword, tmpResults)
            'End If
           
        End If
        
        For Each SearchRecord1 As SearchRecord In tmpResults
            If SearchRecord1.Idx >= SearchCriteria1.StartIdx And SearchRecord1.Idx < SearchCriteria1.StartIdx + intRowsPerPage Then
                Results.Add(SearchRecord1)
            End If
        Next
        Results.Sort()
        Return Results
    End Function
    
    <WebMethod()> _
    Public Function SearchUSWWWSiteJSon(ByVal KeyObject As String) As String
        Dim serializer As New Script.Serialization.JavaScriptSerializer()
        Dim SearchCriteria1 As SearchCriteria = serializer.Deserialize(Of SearchCriteria)(KeyObject)
        Dim Results As List(Of SearchRecord) = SearchUSWWWSite(SearchCriteria1)
        Return serializer.Serialize(Results)
    End Function
    
    
    <WebMethod()> _
    Public Function SearchUSWWWSiteV2(ByVal SearchCriteria1 As SearchCriteria) As List(Of SearchRecord)
        
        If Not SearchCriteria1.Keyword.ToUpper().Contains("DMS") Then Return New List(Of SearchRecord)
        
        Dim Results As New List(Of SearchRecord), tmpResults As List(Of SearchRecord) = Nothing
        If String.IsNullOrEmpty(SearchCriteria1.Keyword) Then Return Results
        'HttpContext.Current.Cache("SiteSearchCache") = Nothing
        Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        Dim SiteSearchCache As Dictionary(Of String, List(Of SearchRecord)) = Nothing
        Try
            SiteSearchCache = CType(HttpContext.Current.Cache("SiteSearch9"), Dictionary(Of String, List(Of SearchRecord)))
        Catch ex As InvalidCastException
            SiteSearchCache = Nothing : HttpContext.Current.Cache.Remove("SiteSearch9")
        End Try
        If SiteSearchCache Is Nothing Then
            SiteSearchCache = New Dictionary(Of String, List(Of SearchRecord))
            HttpContext.Current.Cache.Add("SiteSearch9", SiteSearchCache, Nothing, DateTime.Now.AddMinutes(5), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        
        If Not SiteSearchCache.ContainsKey(SearchCriteria1.Keyword) Then
            tmpResults = SiteSearchV30(SearchCriteria1.Keyword)
            SiteSearchCache.Add(SearchCriteria1.Keyword, tmpResults)
        End If
        
        If SiteSearchCache.ContainsKey(SearchCriteria1.Keyword) Then
            tmpResults = SiteSearchCache.Item(SearchCriteria1.Keyword)
        
        End If
        
        For Each SearchRecord1 As SearchRecord In tmpResults
            If SearchRecord1.Idx >= SearchCriteria1.StartIdx And SearchRecord1.Idx < SearchCriteria1.StartIdx + intRowsPerPage Then
                Results.Add(SearchRecord1)
            End If
        Next
        Results.Sort()
        
        Threading.Thread.Sleep((New Random).Next(1, 5432))
        
        Return Results
    End Function
    
    Public Shared MaxRows As Integer = 200
    
    Private Shared Function SiteSearchV30(ByVal txtKey As String) As List(Of SearchRecord)
        Dim strNFKey As String = New eBizAEU.FullTextSearch(txtKey).NormalForm
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select top " + (MaxRows + 10).ToString() + " a.Title, a.Meta_Description, a.k, a.r, a.TxtHLight, a.ResponseUri, " + _
                        " a.Depth, a.APPNAME, ROW_NUMBER() OVER(ORDER BY a.r-a.Depth*50-DATEDIFF(dd,a.LastModified,getdate())*1.3 DESC) AS idx   ")
            .AppendLine(" from ")
            .AppendLine(" ( ")
            .AppendLine(" 	select a.Title, a.Meta_Description, b.k,  ")
            .AppendLine(" 	dbo.WeightUrl(a.ResponseUri,b.r) as r, ")
            .AppendLine(" 	IsNull(dbo.HighLightSearch(a.Text, @RAWTXT,'',150),left(a.Text,150)) as TxtHLight, ")
            .AppendLine(" 	a.ResponseUri, a.Depth, a.APPNAME, a.LastModified  ")
            .AppendLine(" 	from MY_WEB_SEARCH a inner join  ")
            .AppendLine(" 	( ")
            .AppendLine(" 		select top 99999 a.k, SUM(a.r) as r ")
            .AppendLine(" 		from ")
            .AppendLine(" 		(  ")
            .AppendLine(" 			SELECT [key] as k, [rank]*6 as r ")
            .AppendLine(" 			from freetexttable(MY_WEB_SEARCH, (PRODUCT,title),  @NFKEY) ")
            .AppendLine(" 			union ")
            .AppendLine(" 			SELECT [key] as k, [rank]*1 as r ")
            .AppendLine(" 			from freetexttable(MY_WEB_SEARCH, (Meta_Description, Meta_Keywords, ResponseUri),  @NFKEY) ")
            .AppendLine(" 			union ")
            .AppendLine(" 			SELECT [key] as k, [rank]*0.7 as r ")
            .AppendLine(" 			from freetexttable(MY_WEB_SEARCH, (text),  @NFKEY)		 ")
            .AppendLine(" 		) a ")
            .AppendLine(" 		group by a.k order by SUM(a.r) desc ")
            .AppendLine(" 	) b on a.keyid=b.k   ")
            .AppendLine(" 	where (a.APPNAME = 'Advantech US') ")
            .AppendLine(" ) a ")
            .AppendLine(" where a.r>=60 ")
            .AppendLine(" ORDER BY a.r-a.Depth*50-DATEDIFF(dd,a.LastModified,getdate())*1.3 DESC  ")
        End With
        'txtSql.InnerText = sb.ToString()
        'Response.Write("Key:" + strKey)
        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("NFKEY", strNFKey)
        apt.SelectCommand.Parameters.AddWithValue("RAWKEY", Replace(Replace(Trim(txtKey), " ", "%"), "*", "%"))
        apt.SelectCommand.Parameters.AddWithValue("RAWTXT", txtKey)
        Dim dtResult As New DataTable
        apt.Fill(dtResult)
        apt.SelectCommand.Connection.Close()
        
        Dim SearchRecords As New List(Of SearchRecord)
        For Each r As DataRow In dtResult.Rows
            Dim SearchRecord1 As New SearchRecord
            With SearchRecord1
                .Title = r.Item("Title") : .MetaDesc = r.Item("Meta_Description") : .Uri = r.Item("ResponseUri") : .Rank = r.Item("r") : .Idx = r.Item("idx")
            End With
            SearchRecords.Add(SearchRecord1)
        Next
        Return SearchRecords
    End Function

End Class
