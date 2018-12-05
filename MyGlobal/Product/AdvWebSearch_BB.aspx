<%@ Page Title="MyAdvantech - Search Advantech Websites" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    EnableEventValidation="false" %>

<script runat="server">
    Public Shared MaxRows As Integer = 200
    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function SuggestKeys(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim ks() As String = Split(Trim(prefixText), " "), keysArray As New ArrayList

        For i As Integer = 0 To ks.Length - 1
            ks(i) = Trim(ks(i))
            If Not String.IsNullOrEmpty(ks(i)) AndAlso Not DataMiningUtil.SearchArrayIgnoreCase(keysArray, ks(i)) Then
                keysArray.Add(ks(i))
            End If
        Next

        Dim CurrentKeySet As New DataMiningUtil.KeywordsSetAndSuggestList
        CurrentKeySet.KeywordsSet = keysArray

        Dim ksList As List(Of DataMiningUtil.KeywordsSetAndSuggestList) = HttpContext.Current.Cache("Site Search Suggestion Keywords")
        If ksList Is Nothing Then
            ksList = New List(Of DataMiningUtil.KeywordsSetAndSuggestList)
            HttpContext.Current.Cache.Add("Site Search Suggestion Keywords", ksList, Nothing, Now.AddHours(1), Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If

        If ksList.Contains(CurrentKeySet) Then
            Return ksList.Find(Function(x) x.Equals(CurrentKeySet)).SuggestList
        Else
            Dim AllKeys As New ArrayList
            Dim DmKeys() As String = SuggestKeysByDM_BB(prefixText)
            'Dim GrpKeys() As String = DataMiningUtil.SuggestKeys(prefixText)
            Dim ModelKeys() As String = DataMiningUtil.SuggestModelByLastKey(prefixText)
            For Each k As String In DmKeys
                If Not DataMiningUtil.SearchArrayIgnoreCase(AllKeys, k) Then AllKeys.Add(k)
            Next
            'For Each k As String In GrpKeys
            '    If Not DataMiningUtil.SearchArrayIgnoreCase(AllKeys, k) Then AllKeys.Add(k)
            'Next
            For Each k As String In ModelKeys
                If Not DataMiningUtil.SearchArrayIgnoreCase(AllKeys, k) Then AllKeys.Add(k)
            Next
            CurrentKeySet.SuggestList = AllKeys.ToArray(GetType(String))
            ksList.Add(CurrentKeySet)
            Return AllKeys.ToArray(GetType(String))
        End If

    End Function

    Public Shared Function SuggestKeysByDM_BB(keys As String) As String()
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
        apt.SelectCommand.CommandText =
            " select top 10 LHS, RHS from MyLocal.dbo.BB_SEARCHKEY_RELATION (nolock) " +
            " where " + sqlClause.ToString().Substring(0, sqlClause.Length - 6) +
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
            apt.SelectCommand.CommandText =
                " select top 10 LHS, RHS from MyLocal.dbo.BB_SEARCHKEY_RELATION " +
                " where " + sqlClause.ToString().Substring(0, sqlClause.Length - 5) +
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

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack AndAlso Request("key") IsNot Nothing Then
            Me.txtKey.Text = HttpUtility.UrlDecode(Request("key")) : btnSearch_Click(Nothing, Nothing)
            Dim isreadonly As Reflection.PropertyInfo = _
            GetType(System.Collections.Specialized.NameValueCollection).GetProperty("IsReadOnly", Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic)
            ' make collection editable
            isreadonly.SetValue(Me.Request.QueryString, False, Nothing)
            Me.Request.QueryString.Clear()
        End If
        'divHintKey.InnerHtml = "Do you mean <a href='" + IO.Path.GetFileName(Request.PhysicalPath) + "?Key=aaa&hk=1'>aaa</a>?"
    End Sub

    Public Shared Function ShortenTitle(Title As String) As String
        If Title.Length <= 50 Then Return Title
        If Title.Substring(51).IndexOf(" ") >= 0 Then
            Return Title.Substring(0, 51 + Title.Substring(51).IndexOf(" ")) + " ..."
        Else
            Return Left(Title, 50) + " ..."
        End If
    End Function

    Public Shared Function HighlightKeyWords(text As String, keywords As String, fullMatch As Boolean) As String
        If text = [String].Empty OrElse keywords = [String].Empty Then
            Return text
        End If
        'text = Regex.Replace(text, "<.*?>", String.Empty)
        Dim cssClass As String = "red"
        'keywords = Replace(keywords, " ", ",")
        Dim wds = keywords.Split(New String() {",", " "}, StringSplitOptions.RemoveEmptyEntries)
        wds = wds.Where(Function(p) p.Length > 2).ToArray()

        If Not fullMatch Then
            Return wds.Select(Function(word) word.Trim()).Aggregate(text, Function(current, pattern) Regex.Replace(current, pattern, String.Format("<span style=""color:{0}"">{1}</span>", cssClass, "$0"), RegexOptions.IgnoreCase))
        End If
        Return wds.Select(Function(word) "\b" & word.Trim() & "\b").Aggregate(text, Function(current, pattern) Regex.Replace(current, pattern, String.Format("<span style=""color:{0}"">{1}</span>", cssClass, "$0"), RegexOptions.IgnoreCase))

    End Function

    Public Shared Function MatchedOnly(text As String, keywords As String) As String
        Dim lines() As String = text.Split(New Char() {".", "?", "!", vbCr, vbLf, vbCrLf})
        Dim keys() As String = keywords.Split(New Char() {" "})
        Dim MatchedLines As New ArrayList
        Dim sb As New System.Text.StringBuilder
        'Dim MatchedTimes As Integer = 0
        For Each line In lines
            Dim ms As String = HighlightKeyWords(line, keywords, False)
            If ms.Contains("<span style=""color:red") Then
                For Each k As String In keys
                    Dim regex = New Regex("\s.{0,100}" + k + ".{0,100}\s", RegexOptions.IgnoreCase Or RegexOptions.Compiled)
                    Dim m As Match = regex.Match(line)
                    While m.Success
                        If Not MatchedLines.Contains(m.Value.Trim()) Then
                            MatchedLines.Add(m.Value.Trim())
                            sb.Append(m.Value.Trim() + "...<br/>") : Exit While
                        End If
                    End While
                Next
            End If
            'If MatchedTimes > 3 Then Exit For
        Next
        Return sb.ToString()
    End Function

    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        divHintKey.InnerHtml = ""
        gvSearchResult.PageIndex = 0 : gvSearchResult.DataSource = Nothing : gvSearchResult.DataBind() : txtSearchCount.Text = ""
        If String.IsNullOrEmpty(Trim(txtKey.Text)) Then Exit Sub

        Dim strNFKey As String = New eBizAEU.FullTextSearch(txtKey.Text).NormalForm
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select top " + (MaxRows + 10).ToString() + " a.Title, a.Meta_Description, a.k, a.r, a.TxtHLight, a.ResponseUri, a.Depth, a.APPNAME  ")
            .AppendLine(" from ")
            .AppendLine(" ( ")
            .AppendLine(" 	select a.Title, a.Meta_Description, b.k,  ")
            .AppendLine(" 	dbo.WeightUrl(a.ResponseUri,b.r) as r, ")
            .AppendLine(" 	IsNull(dbo.HighLightSearch(a.Text, @RAWTXT,'',150),left(a.Text,150)) as TxtHLight, ")
            .AppendLine(" 	a.ResponseUri, a.Depth, a.APPNAME, a.LastModified  ")
            .AppendLine(" 	from MY_WEB_SEARCH_BB a inner join  ")
            .AppendLine(" 	( ")
            .AppendLine(" 		select top 200 a.k, SUM(a.r) as r ")
            .AppendLine(" 		from ")
            .AppendLine(" 		(  ")
            .AppendLine(" 			SELECT [key] as k, [rank]*7 as r ")
            .AppendLine(" 			from freetexttable(MY_WEB_SEARCH_BB, (title),  @NFKEY) ")
            .AppendLine(" 			union ")
            .AppendLine(" 			SELECT [key] as k, [rank]*0.3 as r ")
            .AppendLine(" 			from freetexttable(MY_WEB_SEARCH_BB, (text),  @NFKEY)		 ")
            .AppendLine(" 		) a ")
            .AppendLine(" 		group by a.k order by SUM(a.r) desc ")
            .AppendLine(" 	) b on a.keyid=b.k   ")
            .AppendLine(" 	where 1=1 ")
            .AppendLine(" ) a ")
            .AppendLine(" where a.r>=30 ")
            .AppendLine(" ORDER BY a.r-a.Depth*50-DATEDIFF(dd,a.LastModified,getdate())*1.3 DESC  ")
        End With
        'trSQL.Visible = True
        'divSQL.InnerText = sb.ToString()
        'txtSql.InnerText = sb.ToString()
        'Response.Write(strNFKey)
        Dim apt As New SqlClient.SqlDataAdapter(sb.ToString(), ConfigurationManager.ConnectionStrings("MYLOCAL").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("NFKEY", strNFKey)
        apt.SelectCommand.Parameters.AddWithValue("RAWKEY", Replace(Replace(Trim(txtKey.Text), " ", "%"), "*", "%"))
        apt.SelectCommand.Parameters.AddWithValue("RAWTXT", txtKey.Text)
        Dim dtResult As New DataTable
        apt.Fill(dtResult)
        apt.SelectCommand.Connection.Close()

        If dtResult.Rows.Count > MaxRows Then
            dtResult = dtResult.Rows.Cast(Of System.Data.DataRow)().Take(MaxRows).CopyToDataTable()
            txtSearchCount.Text = "More than " + MaxRows.ToString() + " results"
        Else
            txtSearchCount.Text = dtResult.Rows.Count.ToString() + " results"
        End If
        gvSearchResult.DataSource = dtResult : gvSearchResult.DataBind()

        If dtResult.Rows.Count = 0 Then
            Dim ks() As String = Split(Trim(txtKey.Text), " "), keysArray As New ArrayList
            For i As Integer = 0 To ks.Length - 1
                ks(i) = Trim(ks(i))
                If Not String.IsNullOrEmpty(ks(i)) AndAlso Not keysArray.Contains(ks(i)) Then
                    keysArray.Add(ks(i))
                End If
            Next
            If keysArray.Count > 0 Then
                Dim arSuggestKeys As New ArrayList, GotNearKeyTimes As Integer = 0
                For i As Integer = 0 To keysArray.Count - 1
                    If i <= 3 Then
                        Dim sk As String = DataMiningUtil.Top1NearKeyword(keysArray(i))
                        If Not String.IsNullOrEmpty(sk) Then
                            arSuggestKeys.Add(sk) : GotNearKeyTimes += 1
                        Else
                            arSuggestKeys.Add(keysArray(i))
                        End If
                    Else
                        arSuggestKeys.Add(keysArray(i))
                    End If
                Next
                'If GotNearKeyTimes > 0 Then
                '    Dim NewKeys As String = String.Join(" ", arSuggestKeys.ToArray())
                '    divHintKey.InnerHtml = "Do you mean <a href='" + IO.Path.GetFileName(Request.PhysicalPath) + "?Key=" + NewKeys + "&hk=1'>" + NewKeys + "</a>?"
                'End If
            End If
        End If

        If ViewState("SearchResult") Is Nothing Then
            ViewState("SearchResult") = New DataTable
        Else
            CType(ViewState("SearchResult"), DataTable).Clear()
        End If
        ViewState("SearchResult") = dtResult

    End Sub

    Protected Sub gvSearchResult_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gvSearchResult.PageIndex = e.NewPageIndex : gvSearchResult.DataSource = SortDataTable(ViewState("SearchResult"), True) : gvSearchResult.DataBind()
    End Sub

    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") Is Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property

    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") Is Nothing, String.Empty, ViewState("SortExpression"))
        End Get
        Set(ByVal value As String)
            ViewState("SortExpression") = value
        End Set
    End Property

    Private Function GetSortDirection() As String
        Select Case GridViewSortDirection
            Case "ASC"
                GridViewSortDirection = "DESC"
            Case "DESC"
                GridViewSortDirection = "ASC"
        End Select
        Return GridViewSortDirection
    End Function

    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = Util.GetRuntimeSiteUrl + "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = Util.GetRuntimeSiteUrl + "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = Util.GetRuntimeSiteUrl + "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    dataView.Sort = GridViewSortExpression + " " + GetSortDirection()
                    'If String.Equals(GridViewSortExpression, "Vbeln", StringComparison.CurrentCultureIgnoreCase) Then
                    '    dataView.Sort = "Vbeln " + GetSortDirection() + ", Posnr asc"
                    'Else
                    '    dataView.Sort = GridViewSortExpression + " " + GetSortDirection() + ", Vbeln asc, Posnr asc"
                    'End If
                End If
            End If
            Return dataView
        Else
            Return New DataView()
        End If
    End Function

    Protected Sub gvSearchResult_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gvSearchResult.PageIndex
        gvSearchResult.DataSource = SortDataTable(ViewState("SearchResult"), False) : gvSearchResult.DataBind() : gvSearchResult.PageIndex = pageIndex
        'ScriptManager.RegisterStartupScript(upSearchResult, upSearchResult.GetType(), "calcTotalGRQty", "calcTotalGRQty();", True)
    End Sub

    Protected Sub gvSearchResult_DataBound(sender As Object, e As System.EventArgs)
        If gvSearchResult.Rows.Count = 0 Then
            gvSearchResult.Height = Unit.Pixel(300)
        Else
            gvSearchResult.Height = Unit.Percentage(100)
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td colspan="1">
                <asp:Panel runat="server" ID="PanelSearch" DefaultButton="btnSearch">
                    <table width="80%">
                        <tr>                            
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoSuggestKeys" TargetControlID="txtKey" MinimumPrefixLength="1" ServiceMethod="SuggestKeys" />
                                <asp:TextBox runat="server" ID="txtKey" Width="100%" />
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click"
                                    OnClientClick="this.disabled=true;" UseSubmitBehavior="false" />
                            </td>
                        </tr>
                        <tr runat="server" id="trSQL" visible="false">
                            <td colspan="2">
                                <div runat="server" ID="divSQL" style="width:100%; height:250px" />
                            </td>
                        </tr>
                    </table>
                    <script type="text/javascript">
                        var prm = Sys.WebForms.PageRequestManager.getInstance();
                        if (prm != null) {
                            prm.add_endRequest(enableQueryButton);
                        }

                        function enableQueryButton() {
                            document.getElementById('<%=btnSearch.ClientId %>').disabled = false;
                        }
                    </script>
                </asp:Panel>
            </td>
        </tr>
        <tr>            
            <td>
                <asp:Label runat="server" ID="txtSearchCount" ForeColor="#808080" />
                <div runat="server" id="divHintKey"></div>
                <asp:GridView runat="server" ID="gvSearchResult" AutoGenerateColumns="false" ShowHeader="false"
                    EnableTheming="false" BorderStyle="None" BorderWidth="0px" Width="100%" AllowPaging="true"
                    OnRowCreated="gvRowCreated" PageSize="10" PagerSettings-Position="Bottom" OnPageIndexChanging="gvSearchResult_PageIndexChanging"
                    OnSorting="gvSearchResult_Sorting" OnDataBound="gvSearchResult_DataBound">
                    <PagerStyle BorderStyle="None" BorderWidth="0px" />
                    <Columns>
                        <asp:TemplateField ItemStyle-BorderStyle="None">
                            <ItemTemplate>
                                <div style="width: 100%">
                                    <div style="font-size: larger; font-weight: bolder;">
                                        <a target="_blank" href='<%#Eval("ResponseUri") %>' title='<%#Eval("Title") %>'>
                                            <%# HighlightKeyWords(ShortenTitle(Eval("Title")), Me.txtKey.Text, False)%>
                                        </a>
                                    </div>
                                    <div style="height: 4px">
                                        <%--<%#Eval("r")%>--%>
                                    </div>
                                    <div>
                                        <a target="_blank" style="color: #006621;" href='<%#Eval("ResponseUri") %>'>
                                            <%#HighlightKeyWords(Eval("ResponseUri"), Me.txtKey.Text, False)%></a>
                                    </div>
                                    <div style="width: 60%;">
                                        <%#HighlightKeyWords(Eval("TxtHLight"), Me.txtKey.Text, False)%><br />
                                    </div>
                                    <div style="height: 6px">
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </td>
        </tr>
    </table>
</asp:Content>
