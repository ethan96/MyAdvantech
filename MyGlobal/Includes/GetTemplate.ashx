<%@ WebHandler Language="VB" Class="GetTemplate" %>

Imports System
Imports System.Web

Public Class GetTemplate : Implements IHttpHandler
    
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        Dim strHtml As String = ""
        With Context
            If .Request("RowId") IsNot Nothing Then
                
                If .Request("UID") IsNot Nothing Then
                    Dim ws As New aclecampaign.EC
                    ws.UseDefaultCredentials = True : ws.Timeout = -1
                    ws.Url = "http://172.20.1.21:7000/Service/EC.asmx"
                    Dim objEmail As Object = dbUtil.dbExecuteScalar("MY", "select top 1 a.EMAIL from EMAIL_UNIQUEID a where a.HASHVALUE='" + .Request("UID").Replace("'", "") + "'")
                    If objEmail IsNot Nothing Then
                        strHtml = ws.GetEDMContent(.Request("RowId"), objEmail.ToString)
                    End If
                Else
                    Dim dt As New DataTable
                    Dim aptEC As New SqlClient.SqlDataAdapter(
                        "  select top 1 IsNull(TEMPLATE_FILE_TEXT,'') as TEMPLATE_FILE_TEXT,  IsNull(IS_PUBLIC,0) as IS_PUBLIC from campaign_master where row_id=@ROWID ", ConfigurationManager.ConnectionStrings("RFM").ConnectionString)
                    aptEC.SelectCommand.Parameters.AddWithValue("ROWID", .Request("RowId"))
                    aptEC.Fill(dt)
                    aptEC.SelectCommand.Connection.Close()

                    If dt.Rows.Count > 0 Then
                        strHtml = dt.Rows(0).Item("TEMPLATE_FILE_TEXT").ToString
                        If .Request("txtKey") IsNot Nothing AndAlso String.IsNullOrEmpty(Trim(.Request("txtKey"))) = False Then
                            strHtml = Util.Highlight(.Request("txtKey"), strHtml)
                        End If
                    End If
                End If
                '.Response.End()
            End If
            If .Request("CMSID") IsNot Nothing Or .Request("CMSURL") IsNot Nothing Then
                Dim URL As String = ""
                If .Request("CMSID") IsNot Nothing Then
                    Dim objURL As Object = dbUtil.dbExecuteScalar("CMS", "select top 1 URL from Master where CmsID='" + .Request("CMSID") + "'")
                    If objURL IsNot Nothing Then
                        URL = objURL.ToString
                    End If
                ElseIf .Request("CMSURL") IsNot Nothing Then
                    URL = .Request("CMSURL")
                End If
                If URL <> "" Then
                    Dim client As New Net.WebClient, doc As New HtmlAgilityPack.HtmlDocument
                    Dim ms As IO.MemoryStream = Nothing
                    Try
                        ms = New IO.MemoryStream(client.DownloadData(URL))
                    Catch ex As Exception
                        strHtml = "Cannot read html content from " + URL
                    End Try
                    If ms IsNot Nothing Then
                        doc.Load(ms, True)

                        Dim ccn As HtmlAgilityPack.HtmlNodeCollection = doc.DocumentNode.SelectNodes("//img")
                        If Not IsNothing(ccn) AndAlso ccn.Count > 0 Then
                            For Each n As HtmlAgilityPack.HtmlNode In ccn
                                If n.HasAttributes AndAlso (n.Attributes("src") IsNot Nothing OrElse n.Attributes("background") IsNot Nothing) Then
                                    Dim srcAttribute As String = IIf(n.Attributes("src") IsNot Nothing, "src", "background")
                                    Dim curi As New Uri(n.Attributes(srcAttribute).Value, UriKind.RelativeOrAbsolute)
                                    If Not curi.IsAbsoluteUri Then
                                        curi = New Uri(New Uri(URL), n.Attributes(srcAttribute).Value)
                                    End If
                                    n.Attributes(srcAttribute).Value = curi.AbsoluteUri
                                End If
                            Next
                        End If

                        ccn = doc.DocumentNode.SelectNodes("//link")
                        Dim docR As New HtmlAgilityPack.HtmlDocument
                        If Not IsNothing(ccn) AndAlso ccn.Count > 0 Then
                            For Each n As HtmlAgilityPack.HtmlNode In ccn
                                If n.HasAttributes AndAlso n.Attributes("type") IsNot Nothing AndAlso n.Attributes("type").Value Like "*css" AndAlso
                                    n.Attributes("href") IsNot Nothing Then
                                    Try
                                        Dim headNode As HtmlAgilityPack.HtmlNode = doc.DocumentNode.SelectSingleNode("//head")
                                        If headNode IsNot Nothing Then
                                            Dim curi As New Uri(n.Attributes("href").Value, UriKind.RelativeOrAbsolute)
                                            If Not curi.IsAbsoluteUri Then
                                                curi = New Uri(New Uri(URL), n.Attributes("href").Value)
                                            End If
                                            Dim httpReq As System.Net.HttpWebRequest = System.Net.WebRequest.Create(curi.AbsoluteUri)
                                            httpReq.AllowAutoRedirect = False
                                            Dim httpRes As System.Net.HttpWebResponse = httpReq.GetResponse()
                                            If httpRes.StatusCode <> System.Net.HttpStatusCode.NotFound Then
                                                Dim msCss As New System.IO.MemoryStream(client.DownloadData(curi.AbsoluteUri))
                                                docR.Load(msCss, System.Text.Encoding.UTF8)
                                                Dim strCss As String = docR.DocumentNode.OuterHtml
                                                If Not strCss.Contains("Advantech - Page Not Found") Then
                                                    Dim NewCssNode As HtmlAgilityPack.HtmlNode =
                                                        HtmlAgilityPack.HtmlNode.CreateNode("<style type='text/css'>" + vbCrLf + Replace(strCss, vbCr, vbCrLf) + vbCrLf + "</style>")
                                                    headNode.AppendChild(NewCssNode)
                                                End If
                                            End If
                                            httpRes.Close()
                                        End If
                                    Catch ex As Exception
                                    End Try
                                End If
                            Next
                        End If

                        strHtml = doc.DocumentNode.OuterHtml
                    End If
                End If
            End If

            If .Request("CELL_ID") IsNot Nothing Then
                strHtml = dbUtil.dbExecuteScalar("UCAMP", String.Format("select top 1 isnull(a.TEMPLATE_CONTENT,'') from ECAMPAIGN a where a.CELL_ID='{0}'", .Request("CELL_ID")))
            End If

            If .Request("UID") IsNot Nothing Then
                'Add Email Code to links
                Dim CampaignImagePath As String = "http://edm.advantech.com/"
                strHtml = Replace(strHtml, CampaignImagePath + .Request("RowId"), CampaignImagePath + .Request("UID") + "_" + .Request("RowId"))
            End If

            .Response.Write(strHtml)
        End With
    End Sub
    
    'Public Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
    '    If Search_Str <> String.Empty AndAlso Search_Str.Trim <> "" AndAlso Search_Str <> "*" Then
    '        Search_Str = Replace(Search_Str, "*", "{0,}")
    '        Try
    '            Dim RegExp As New Regex(Search_Str.Replace(" ", "|").Trim(), RegexOptions.IgnoreCase)
    '            Return RegExp.Replace(InputTxt, New MatchEvaluator(AddressOf ReplaceKeyWords))
    '            RegExp = Nothing
    '        Catch ex As System.ArgumentException
              
    '        End Try
    '    End If
    '    Return ""
    'End Function
    
    'Public Function ReplaceKeyWords(ByVal m As Match) As String
    '    Return "<span style='background-color:Yellow'>" + m.Value + "</span>"
    'End Function
 
    
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property

End Class