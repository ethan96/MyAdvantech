<%@ Page Title="MyAdvantech - Search Advantech Websites" Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" %>

<script runat="server">
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetSuggestion(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt = dbUtil.dbGetDataTable("MY", String.Format("select distinct top 10 keyword from my_web_keywords where keyword like N'%{0}%' ", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    
    Public Function GetHighlightedSegment(ByVal str As String) As String
        If str.Contains("<span style='background-color:Yellow'>") Then
            If str.IndexOf("<span style='background-color:Yellow'>") > 10 Then
                Return str.Substring(str.IndexOf("<span style='background-color:Yellow'>") - 10)
            Else
                Return str
            End If
        Else
            Return str
        End If
    End Function
    
    'Public Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
    '    Dim RegExp As New Regex(Search_Str.Replace(" ", "|").Trim(), RegexOptions.IgnoreCase)
    '    Return RegExp.Replace(InputTxt, New MatchEvaluator(AddressOf ReplaceKeyWords))
    '    RegExp = Nothing
    'End Function
    
    Function ShowTextPreview(ByVal t As String) As String
        t = Util.Highlight(Me.txtKey.Text, HttpUtility.HtmlEncode(t))
        'If t.Length >= 100 Then
        '    t = Left(t, 100)
        'End If
        Return t
        'IIf(Eval("Text").ToString().Length >= 100, Left(GetHighlightedSegment(Highlight(Me.txtKey.Text, Eval("Text"))), 100) + "...", GetHighlightedSegment(Eval("Text")))
    End Function
    
    'Public Function ReplaceKeyWords(ByVal m As Match) As String
    '    Return "<span style='color:Red'><b>" + m.Value + "</b></span>"
    'End Function
    
    Function GetSql() As String
        If txtKey.Text.Trim = "" Then Return ""
        Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(txtKey.Text))
        Dim strKey As String = fts.NormalForm.Replace("'", "''")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 100 a.keyid, b.[rank], a.ContentType, a.APPNAME, a.Meta_Description, "))
            .AppendLine(String.Format(" a.Url, a.LastModified, "))
            .AppendLine(String.Format(" a.ResponseUri, a.Title, a.[Text], a.Crawl_Time from MY_WEB_SEARCH a inner join  "))
            .AppendLine(String.Format(" (  "))
            .AppendLine(String.Format(" 	SELECT top 500 [key], [rank]  "))
            .AppendLine(String.Format(" 	from freetexttable(MY_WEB_SEARCH, (title, text, Meta_Description),  "))
            .AppendLine(String.Format(" 	'{0}') order by [rank] desc ", strKey))
            .AppendLine(String.Format(" ) b on a.keyid=b.[key]  "))
            If rblWeb.SelectedIndex > 0 Then
                .AppendLine(String.Format(" where a.APPNAME='{0}' ", rblWeb.SelectedValue))
            End If
            .AppendLine(String.Format(" order by b.[rank] desc "))
        End With
        'Response.Write(sb.ToString())
        Return sb.ToString()
    End Function

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txtKey.Attributes("autocomplete") = "off"
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If txtKey.Text.Trim() = "" Then Exit Sub
        hd_FS.Value = "0"
        'If dbUtil.dbGetDataTable("MY", GetSql()).Rows.Count = 0 Then hd_FS.Value = "1"
        gv1.PageIndex = 0 : src1.SelectCommand = GetSql()
        gv1.EmptyDataText = "No Search Result. Please refine your search."
        If False Then
            lbSql.Visible = True : lbSql.Text = src1.SelectCommand
        End If
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        'If gv1.PageIndex = 0 AndAlso gv1.Rows.Count = 0 Then
        '    hd_FS.Value = "1" : src1.SelectCommand = GetSql()
        'End If
    End Sub
    
    Function FormatAppName(ByVal appvalue As String) As String
        Dim apname As String = "", apurl As String = ""
        Select Case UCase(appvalue)
            Case "ADVANTECH US"
                apname = "Corp. Website" : apurl = "http://www.advantech.com"
            Case "ESTORE US"
                apname = "eStore" : apurl = "http://buy.advantech.com"
            Case "SUPPORT"
                apname = "Support Portal" : apurl = "http://support.advantech.com"
            Case Else
                apname = "Others" : apurl = "http://www.advantech.com"
        End Select
        Return String.Format("<a target='_blank' href='{0}'>{1}</a>", apurl, apname)
    End Function
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript">
        function ShowHide(eid) {
            var e = document.getElementById(eid);
            if (e) {
                if (e.style.display == 'none') {
                    e.style.display = 'block';
                }
                else { e.style.display = 'none'; }
            }
        }        
    </script>
    <table width="100%" style="height:100%" id="stb">
        <asp:HiddenField runat="server" ID="hd_FS" Value="0" />
        <tr style="height:15px; vertical-align:middle;">
            <th align="left" style="color:Navy"><h2>Search Advantech Websites</h2></th>
        </tr>
        <tr valign="top">
            <td style="vertical-align:top">
                <table>
                    <tr valign="top">
                        <td>
                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" TargetControlID="txtKey" MinimumPrefixLength="2" CompletionInterval="500" ServiceMethod="GetSuggestion" />
                            <asp:Panel runat="server" ID="PanelSearchTextBox" DefaultButton="btnSearch">
                                <asp:TextBox runat="server" ID="txtKey" Width="500px" />
                            </asp:Panel>
                        </td>
                        <td><asp:Button runat="server" ID="btnSearch" Text="Search" OnClick="btnSearch_Click" /></td>                        
                    </tr>
                    <tr valign="top">
                        <td colspan="2" align="center">
                            <asp:RadioButtonList runat="server" ID="rblWeb" RepeatColumns="4" RepeatDirection="Horizontal">
                                <asp:ListItem Text="All Websites" Selected="True" />
                                <asp:ListItem Text="Corp. Website" Value="Advantech US" />
                                <asp:ListItem Text="eStore" Value="eStore US" />
                                <asp:ListItem Text="Support Portal" Value="Support" />
                            </asp:RadioButtonList>
                        </td>
                    </tr>                   
                </table>
            </td>
        </tr>
        <tr valign="top">
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Label runat="server" ID="lbSql" Visible="false" />
                        <asp:GridView runat="server" ID="gv1" Width="90%" AutoGenerateColumns="false" AllowPaging="true" EnableTheming="false" 
                            BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" 
                            PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" RowStyle-BackColor="#FFFFFF"  
                            PageSize="10" PagerSettings-Position="TopAndBottom" DataSourceID="src1" ShowHeader="false" OnPageIndexChanging="gv1_PageIndexChanging" OnDataBound="gv1_DataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <table width="100%">                                            
                                            <tr>
                                                <td>
                                                    <a target="_blank"  style="font-size:16px; text-decoration:underline" href='<%# Eval("ResponseUri") %>'><%# Util.Highlight(Me.txtKey.Text, Eval("title"))%></a>                                                                                                      
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <div style="width:95%; overflow:auto; height:100px">
                                                        <%# CDate(Eval("LastModified")).ToString("yyyy/MM/dd")%>...<%# ShowTextPreview(Eval("Text"))%>
                                                    </div>  
                                                </td>
                                            </tr>
                                            <tr>
                                                <td><%# FormatAppName(Eval("APPNAME"))%></td>
                                            </tr>
                                            <tr>
                                                <td style="color:#0E774A">
                                                    <%# Eval("ResponseUri") %>&nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src1_Selecting" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnSearch" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        document.getElementById('stb').style.height = Math.max(document.documentElement.scrollHeight, document.body.scrollHeight) - 200 + "px";
    </script>
</asp:Content>