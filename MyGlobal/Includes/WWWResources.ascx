<%@ Control Language="VB" ClassName="WWWResources" %>

<script runat="server">    
    Public userBaa As New ArrayList
    Public Shared Function ShowOrHideViewLink(ByVal url As String, ByVal recid As String) As String
        If IsValidUrlFormat(url) Then
            Return String.Format("<a href='/Includes/RecLink.ashx?RECID={0}' target='_blank'>View</a>", recid)
        Else
            Return ""
        End If
    End Function
    
    Public Shared Function IsValidUrlFormat(ByVal url As String) As Boolean
        Dim reg As String = "(http:\/\/([\w.]+\/?)\S*)"
        Dim options As RegexOptions = RegexOptions.Singleline
        If Regex.Matches(url, reg, options).Count = 0 Then
            Return False
        Else
            Return True
        End If
    End Function
    
    Function GetSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT distinct top 1 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK,  "))
            .AppendLine(String.Format(" a.ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME,  "))
            .AppendLine(String.Format(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA,  "))
            .AppendLine(String.Format(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME "))
            .AppendLine(String.Format(" FROM WWW_RESOURCES AS a  "))
            .AppendLine(String.Format(" WHERE a.ABSTRACT<>'' "))
            If Session("lanG") = "KOR" Then
                .AppendLine(String.Format(" and a.RBU ='AKR' "))
            ElseIf Session("lanG") = "JAP" Then
                .AppendLine(String.Format(" and a.RBU ='AJP' "))
            Else
                .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU') "))
            End If
            .AppendLine(String.Format(" and a.CATEGORY_NAME='Video' "))
            
            'If Not Page.IsPostBack Then
            'Dim userBaa As ArrayList = GetUserBAA()
            'userBaa.Add("N'Machine Automation'")
            If userBaa.Count > 0 Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))))
            End If
            'End If
            
            .AppendLine(String.Format(" order by lastupdated desc, release_date desc "))
        End With
        
        'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "", sb.ToString, False, "", "")
        Return sb.ToString()
    End Function
    
    Shared Function RecImgTdStyle(ByVal rectype As String) As String
        Select Case rectype.ToUpper()
            Case "VIDEO"
                Return "width:113px; display:block;"
            Case Else
                Return "width:0px; display:none;"
        End Select
    End Function
    
    Function GetUserBAA() As ArrayList
        Dim arrBaa As New ArrayList
        If Session IsNot Nothing AndAlso Session("user_id") <> "" Then
            If Session("company_id") <> "" And Session("company_id") <> "EDDEAA01" Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select b.baa from siebel_account a inner join siebel_account_baa b on a.row_id=b.account_row_id where a.erp_id<>'' and a.erp_id='{0}' and b.baa<>'' and b.baa<>'N/A'", Session("company_id")))
                For Each r As DataRow In dt.Rows
                    arrBaa.Add("N'" + r.Item("BAA") + "'")
                Next
            End If
            If arrBaa.Count = 0 Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select a.NAME as BAA from siebel_contact_baa a inner join siebel_contact b on a.contact_row_id=b.row_id and b.email_address='{0}' and a.NAME<>'' and a.NAME<>'N/A'", Session("user_id")))
                For Each r As DataRow In dt.Rows
                    arrBaa.Add("N'" + r.Item("BAA") + "'")
                Next
            End If
        End If
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

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        hlUpdateProfile.NavigateUrl = "https://member.advantech.com/profile.aspx?pass=my&id=" + Session("user_id") + "&lang=en&tempid=" + Session("TempId")
        If Not Page.IsPostBack Then
            'Me.Master.SearchDlSelIdx = 3
            'If Request("key") IsNot Nothing Then
            '    Me.txtKey.Text = HttpUtility.UrlDecode(Request("key"))
            'End If
            userBaa = GetUserBAA()
            src1.SelectCommand = GetSql()
            
            'Dim userBaa As ArrayList = GetUserBAA()
            Dim sb As New System.Text.StringBuilder, sb1 As New StringBuilder
            With sb
                .AppendLine(String.Format(" SELECT distinct top 1 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
                .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, a.ABSTRACT "))
                .AppendLine(String.Format(" FROM WWW_RESOURCES AS a  "))
                .AppendLine(String.Format(" WHERE a.ABSTRACT<>'' "))
                If Session("lanG") = "KOR" Then
                    .AppendLine(String.Format(" and a.RBU ='AKR' "))
                ElseIf Session("lanG") = "JAP" Then
                    .AppendLine(String.Format(" and a.RBU ='AJP' "))
                Else
                    .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU') "))
                End If
                .AppendLine(String.Format(" and a.CATEGORY_NAME='News' "))
                If Session("account_status") <> "EZ" Then
                    If userBaa.Count > 0 Then
                        sb1.Append(sb.ToString)
                        .AppendLine(String.Format(" and a.BAA in ({0}) ", String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))))
                        If dbUtil.dbGetDataTable("MY", sb.ToString).Rows.Count = 0 Then
                            sb = New StringBuilder
                            sb.AppendFormat(sb1.ToString)
                        End If
                    End If
                End If
                
                .AppendLine(String.Format(" order by lastupdated desc, release_date desc "))
            End With
            
            'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "sql", sb.ToString, True, "", "")
            'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "sql", sb.ToString + "<br/>" + Session("lanG"), True, "", "")
            sqlNews.SelectCommand = sb.ToString         
            sb = New StringBuilder : sb1 = New StringBuilder
            With sb
                .AppendLine(String.Format(" SELECT distinct top 2 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
                .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, a.ABSTRACT "))
                .AppendLine(String.Format(" FROM WWW_RESOURCES AS a  "))
                .AppendLine(String.Format(" WHERE a.ABSTRACT<>'' "))
                If Session("lanG") = "KOR" Then
                    .AppendLine(String.Format(" and a.RBU ='AKR' "))
                ElseIf Session("lanG") = "JAP" Then
                    .AppendLine(String.Format(" and a.RBU ='AJP' "))
                Else
                    .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU') "))
                End If
                .AppendLine(String.Format(" and a.CATEGORY_NAME='Case Study' "))
                If Session("account_status") <> "EZ" Then
                    If userBaa.Count > 0 Then
                        sb1.Append(sb.ToString)
                        .AppendLine(String.Format(" and a.BAA in ({0}) ", String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))))
                        If dbUtil.dbGetDataTable("MY", sb.ToString).Rows.Count = 0 Then
                            sb = New StringBuilder
                            sb.AppendFormat(sb1.ToString)
                        End If
                    End If
                End If
                
                .AppendLine(String.Format(" order by lastupdated desc, release_date desc "))
            End With
            sqlCaseStudy.SelectCommand = sb.ToString
            'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "sql", sb.ToString + "<br/>" + Session("lanG"), True, "", "")
            sb = New StringBuilder : sb1 = New StringBuilder
            With sb
                .AppendLine(String.Format(" SELECT distinct top 2 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
                .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, a.ABSTRACT "))
                .AppendLine(String.Format(" FROM WWW_RESOURCES AS a  "))
                .AppendLine(String.Format(" WHERE a.ABSTRACT<>'' "))
                If Session("lanG") = "KOR" Then
                    .AppendLine(String.Format(" and a.RBU ='AKR' "))
                ElseIf Session("lanG") = "JAP" Then
                    .AppendLine(String.Format(" and a.RBU ='AJP' "))
                Else
                    .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU') "))
                End If
                .AppendLine(String.Format(" and a.CATEGORY_NAME='White Papers' "))
                If Session("account_status") <> "EZ" Then
                    If userBaa.Count > 0 Then
                        sb1.Append(sb.ToString)
                        .AppendLine(String.Format(" and a.BAA in ({0}) ", String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))))
                        If dbUtil.dbGetDataTable("MY", sb.ToString).Rows.Count = 0 Then
                            sb = New StringBuilder
                            sb.AppendFormat(sb1.ToString)
                        End If
                    End If
                End If
                
                .AppendLine(String.Format(" order by lastupdated desc, release_date desc "))
            End With
            'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "sql", sb.ToString + "<br/>" + Session("lanG"), True, "", "")
            sqlWhitePapers.SelectCommand = sb.ToString
            
            If Session("user_id") = "" Then
                sqlEDM.SelectCommand = "select top 4 b.row_id, a.contact_email, b.email_subject from campaign_contact_list a inner join campaign_master b on a.campaign_row_id=b.row_id where a.contact_email='tc.chen@advantech.com.tw' order by a.email_send_time desc"
            Else
                sqlEDM.SelectCommand = "select top 4 b.row_id, a.contact_email, b.email_subject from campaign_contact_list a inner join campaign_master b on a.campaign_row_id=b.row_id where a.contact_email='" + Session("user_id") + "' order by a.email_send_time desc"
            End If
            'If Session IsNot Nothing AndAlso Session("user_id") = "tc.chen@advantech.com.tw" Then lbSql.Visible = True
        Else
            'gv1.EmptyDataText = "No result, please refine your search"
        End If
        
        
    End Sub
    
    Shared Function RecLength(ByVal hour As Integer, ByVal minute As Integer, _
                                        ByVal sec As Integer) As String
        If hour = 0 And minute = 0 And sec = 0 Then Return "N/A"
        Return String.Format("{0}''{1}'{2}", hour, minute, sec)
    End Function
    
    Public Shared Function ShowAbstract(ByVal abstract As String, ByVal rectype As String, ByVal recid As String, ByVal GvRowIdx As Integer) As String
        If rectype.ToLower() = "news" Or rectype.ToLower() = "case study" Then
            Dim aspxpage As String = ""
            Select Case rectype.ToLower()
                Case "news"
                    aspxpage = "News"
                Case "case study"
                    aspxpage = "applications"
            End Select
            Dim URL As String = String.Format("http://www.advantech.com.tw/ePlatform/{0}.aspx?doc_id={1}", aspxpage, recid)
            'Return abstract
        Else
            
        End If
        abstract = HttpContext.Current.Server.HtmlEncode(abstract)
        If abstract.Length > 300 Then abstract = abstract.Substring(0, 300) + String.Format(" <a href='http://resources.advantech.com/Resources/Details.aspx?rid={0}' target='_blank'>...</a>", recid)
        Return abstract
    End Function

    Protected Sub RowRateCMS_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim record_id As String = CType(CType(CType(sender, AjaxControlToolkit.Rating).NamingContainer, GridViewRow).FindControl("hdnRecordId"), HiddenField).Value
        Try
            Dim ws As New ADVWS.AdvantechWebService
            ws.UseDefaultCredentials = True : ws.Timeout = 50000
            CType(sender, AjaxControlToolkit.Rating).CurrentRating = ws.GetRating2(record_id)
        Catch ex As Exception
        End Try
    End Sub

    Protected Sub RowRateCMS_Changed(ByVal sender As Object, ByVal e As AjaxControlToolkit.RatingEventArgs)
        Dim record_id As String = CType(CType(CType(sender, AjaxControlToolkit.Rating).NamingContainer, GridViewRow).FindControl("hdnRecordId"), HiddenField).Value
        Try
            Dim ws As New ADVWS.AdvantechWebService
            ws.UseDefaultCredentials = True : ws.Timeout = 50000
            Dim ret As Boolean = ws.AddRating2("MyAdvantech", record_id, CType(sender, AjaxControlToolkit.Rating).CurrentRating, Session("user_id"), "", Context.Request.ServerVariables("REMOTE_ADDR"), Session("user_id"), "vote")
            Dim sb As New StringBuilder
            With sb
                .Append("<table align='left'>")
                .Append("<tr><th align='left'>Record ID: </th><td align='left'>" + record_id + "</td></tr>")
                .Append("<tr><th align='left'>Rating: </th><td align='left'>" + CType(sender, AjaxControlToolkit.Rating).CurrentRating.ToString + "</td></tr>")
                .Append("<tr><th align='left'>Email: </th><td align='left'>" + Session("user_id") + "</td></tr>")
                .Append("<tr><th align='left'>IP: </th><td align='left'>" + Context.Request.ServerVariables("REMOTE_ADDR") + "</td></tr>")
                .Append("</table>")
            End With
            'If ret = False And Not Context.Request.ServerVariables("REMOTE_ADDR").ToString.StartsWith("172.") Then Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Update Failed : MyAdvantech Global Comment Rating", sb.ToString, True, "", "")
        Catch ex As Exception
        End Try
    End Sub

    Protected Sub btnAddComment_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim record_id As String = gv1.DataKeys(CType(CType(sender, Button).NamingContainer, GridViewRow).RowIndex).Values("RECORD_ID").ToString
        Dim comment As String = CType(CType(CType(sender, Button).NamingContainer, GridViewRow).FindControl("txtComment"), TextBox).Text.Replace(vbCrLf, "<br/>")
        Dim ws As New ADVWS.AdvantechWebService
        ws.UseDefaultCredentials = True : ws.Timeout = 5000
        Dim ret As Boolean = ws.Comment_AddByRecord_IDandUser_ID(record_id, 0, Session("user_id"), comment, "")
        src1.SelectCommand = GetSql()
        gv1.DataBind()
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Not Page.IsPostBack Then
                e.Row.Cells(0).FindControl("tbContent").Visible = False
                CType(e.Row.Cells(0).FindControl("btnCollapse"), ImageButton).Visible = False
            Else
                If Session("user_id") <> "" Then
                    Dim gvC As GridView = CType(e.Row.Cells(0).FindControl("gvComment"), GridView)
                    Dim record_id As String = gv1.DataKeys(e.Row.RowIndex).Values("RECORD_ID").ToString
                    Dim ws As New ADVWS.AdvantechWebService
                    ws.UseDefaultCredentials = True : ws.Timeout = 50000
                    Dim ds As DataSet = ws.Comment_GetByRecord_ID(record_id)
                    Dim dt As DataTable = ds.Tables(0)
                    gvC.DataSource = dt : gvC.DataBind()
                End If
            End If
        End If
    End Sub

    Protected Sub btnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sid As String = CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnSID"), HiddenField).Value
        Dim ws As New ADVWS.AdvantechWebService
        ws.UseDefaultCredentials = True : ws.Timeout = 5000
        Dim ds As DataSet = ws.Comment_GetReplyBySID(CInt(sid))
        Dim dt As DataTable = ds.Tables(0)
        If dt.Rows.Count > 0 Then
            For Each row As DataRow In dt.Rows
                ws.Comment_DeleteBySID(CInt(row.Item("SID")))
            Next
        End If
        ws.Comment_DeleteBySID(CInt(sid))
        src1.SelectCommand = GetSql()
        gv1.DataBind()
    End Sub

    Protected Sub btnReply_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("trReply").Visible = True Then
            CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("trReply").Visible = False
        Else
            CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("trReply").Visible = True
        End If
    End Sub

    Protected Sub gvComment_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Page.IsPostBack Then
                Dim gvC As GridView = CType(e.Row.Cells(0).FindControl("gvReplyComment"), GridView)
                Dim sid As String = CType(e.Row.Cells(0).FindControl("hdnSID"), HiddenField).Value
                Dim ws As New ADVWS.AdvantechWebService
                ws.UseDefaultCredentials = True : ws.Timeout = 5000
                Dim ds As DataSet = ws.Comment_GetReplyBySID(CInt(sid))
                Dim dt As DataTable = ds.Tables(0)
                gvC.DataSource = dt : gvC.DataBind()
            End If
        End If
    End Sub

    Protected Sub btnReplyComment_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sid As String = CType(CType(CType(sender, Button).NamingContainer, GridViewRow).FindControl("hdnSID"), HiddenField).Value
        Dim comment As String = CType(CType(CType(sender, Button).NamingContainer, GridViewRow).FindControl("txtReplyComment"), TextBox).Text.Replace(vbCrLf, "<br/>")
        Dim ws As New ADVWS.AdvantechWebService
        ws.UseDefaultCredentials = True : ws.Timeout = 5000
        Dim ret As Boolean = ws.Comment_AddByRecord_IDandUser_ID("", CInt(sid), Session("user_id"), comment, "")
        src1.SelectCommand = GetSql() : gv1.DataBind()
    End Sub

    Protected Sub btnDeleteReply_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim sid As String = CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnReplySID"), HiddenField).Value
        Dim ws As New ADVWS.AdvantechWebService
        ws.UseDefaultCredentials = True : ws.Timeout = 5000
        ws.Comment_DeleteBySID(CInt(sid))
        src1.SelectCommand = GetSql() : gv1.DataBind()
    End Sub

    Protected Sub RowRateCMS_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") = "" Or IsNothing(Session("user_id")) Then
            CType(sender, AjaxControlToolkit.Rating).Visible = False
        Else
            CType(sender, AjaxControlToolkit.Rating).Visible = True
        End If
    End Sub

    Protected Sub PanelHeader_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") = "" Or IsNothing(Session("user_id")) Then
            CType(sender, Panel).Visible = False
        Else
            CType(sender, Panel).Visible = True
        End If
    End Sub

    Protected Sub PanelContent_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") = "" Or IsNothing(Session("user_id")) Then
            CType(sender, Panel).Visible = False
        Else
            CType(sender, Panel).Visible = True
        End If
    End Sub

    Protected Sub btnDelete_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnCreateBy"), HiddenField).Value <> "" Then
            If Session("user_id") <> CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnCreateBy"), HiddenField).Value Then
                CType(sender, LinkButton).Visible = False
            End If
        End If
    End Sub

    Protected Sub btnDeleteReply_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnReplyCreateBy"), HiddenField).Value <> "" Then
            If Session("user_id") <> CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("hdnReplyCreateBy"), HiddenField).Value Then
                CType(sender, LinkButton).Visible = False
            End If
        End If
    End Sub

    Protected Sub PanelVideo_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        If LCase(gv1.DataKeys(CType(CType(sender, Panel).NamingContainer, GridViewRow).RowIndex).Values("CATEGORY_NAME")) = "video" Then
            CType(sender, Panel).Visible = True
        Else
            CType(sender, Panel).Visible = False
        End If
    End Sub

    Protected Sub btnExpand_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        CType(sender, ImageButton).Visible = False
        CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("btnCollapse"), ImageButton).Visible = True
        CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("tbContent").Visible = True
        CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("upComment"), UpdatePanel).Update()
    End Sub

    Protected Sub btnCollapse_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        CType(sender, ImageButton).Visible = False
        CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("btnExpand"), ImageButton).Visible = True
        CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("tbContent").Visible = False
        CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("upComment"), UpdatePanel).Update()
    End Sub
    Protected Sub LiTs_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Lit As Literal = CType(sender, Literal)
        Dim LiTstr As String = Util.GetLANGLiT_text(Lit.ID.ToString.Trim)
        If LiTstr.ToString.Trim <> "" Then
            Lit.Text = LiTstr
        End If
    End Sub

    Protected Sub hlWhitePaper_Load(sender As Object, e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink)
        If Session("account_status") IsNot Nothing Then
            If Session("account_status") = "GA" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=8"
            ElseIf Session("account_status") = "CP" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=17"
            Else
                
            End If
        Else
            hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=8"
        End If
    End Sub

    Protected Sub hlVideo_Load(sender As Object, e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink)
        If Session("account_status") IsNot Nothing Then
            If Session("account_status") = "GA" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=7"
            ElseIf Session("account_status") = "CP" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=15"
            Else
                
            End If
        Else
            hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=7"
        End If
    End Sub

    Protected Sub hlNews_Load(sender As Object, e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink)
        If Session("account_status") IsNot Nothing Then
            If Session("account_status") = "GA" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=3"
            ElseIf Session("account_status") = "CP" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=10"
            Else
                
            End If
        Else
            hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=3"
        End If
    End Sub

    Protected Sub hlCaseStudy_Load(sender As Object, e As System.EventArgs)
        Dim hl As HyperLink = CType(sender, HyperLink)
        If Session("account_status") IsNot Nothing Then
            If Session("account_status") = "GA" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=0"
            ElseIf Session("account_status") = "CP" Then
                hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=3"
            Else
                
            End If
        Else
            hl.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=0"
        End If
    End Sub
</script>
<div class="rightcontant">
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td>
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                    <tr>
                        <td height="20" /><td /><td />
                    </tr>
                    <tr>
                        <td width="3%" />
                        <td width="94%" class="h2">
                            <asp:Literal ID="LiT5" runat="server" OnLoad="LiTs_Load">Customized Content</asp:Literal>
                        </td>
                        <td width="3%" />
                    </tr>
                    <tr>
                        <td height="5" /><td /><td />
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td>
                            MyAdvantech provides you with customized content based on your personal profile.
                            If you would like to update your profile so more relevant content is displayed below,
                            please
                            <asp:HyperLink runat="server" ID="hlUpdateProfile" Text="click" Target="_blank" />
                            here!
                        </td>
                        <td>
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" height="20px" />
                    </tr>
                    <tr>
                        <td width="3%" />
                        <td width="94%">
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr valign="top">
                                    <td>
                                        <asp:GridView runat="server" ID="gv1" Width="100%" EnableTheming="false" AutoGenerateColumns="false"
                                            ShowHeader="false" BorderWidth="0" CellPadding="0" CellSpacing="0" DataKeyNames="RECORD_ID,CATEGORY_NAME,RECORD_IMG"
                                            DataSourceID="src1" AllowPaging="true" AllowSorting="true" BorderColor="White"
                                            PageSize="5" PagerSettings-Position="TopAndBottom" OnRowDataBound="gv1_RowDataBound">
                                            <Columns>
                                                <asp:TemplateField SortExpression="title">
                                                    <ItemTemplate>
                                                        <table width="100%">
                                                            <tr valign="top">
                                                                <td colspan="2" align="left" style="width: 15%" class="h3">
                                                                    <%#Eval("category_name")%>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="2">
                                                                    <hr />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <a href="http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackupurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>"
                                                                        target="_blank">
                                                                        <img width="143" height="108" src='<%#Eval("RECORD_IMG") %>' alt='' /></a>
                                                                </td>
                                                                <td>
                                                                    <table width="100%">
                                                                        <tr>
                                                                            <td align="left" class="h4">
                                                                                <a href='http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackupurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                                                                    target='_blank'>
                                                                                    <%#Trim(Eval("title"))%></a>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td style="height: 60px" valign="top" align="left">
                                                                                <table cellpadding="0" cellspacing="0">
                                                                                    <tr>
                                                                                        <td valign="top">
                                                                                            <%#ShowAbstract(Eval("abstract"), Eval("category_name"), Eval("record_id"), Container.DataItemIndex)%>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="2" valign="top" align="left">
                                                                    <table width="100%" border="0">
                                                                        <tr>
                                                                            <td width="7%">
                                                                                Views:
                                                                            </td>
                                                                            <td width="3%">
                                                                                <%# Eval("CLICKTIME")%>
                                                                            </td>
                                                                            <td width="5%">
                                                                                Date:
                                                                            </td>
                                                                            <td width="12%">
                                                                                <%# CDate(Eval("RELEASE_DATE")).ToString("M/dd/yyyy")%>
                                                                            </td>
                                                                            <td width="11%">
                                                                                Your Rate:
                                                                            </td>
                                                                            <td width="15%">
                                                                                <asp:UpdatePanel runat="server" ID="upRating">
                                                                                    <ContentTemplate>
                                                                                        <asp:HiddenField runat="server" ID="hdnRecordId" Value='<%#Eval("record_id") %>' />
                                                                                        <ajaxToolkit:Rating ID="RowRateCMS" runat="server" AutoPostBack="true" CurrentRating="0"
                                                                                            MaxRating="5" StarCssClass="ratingStar" WaitingStarCssClass="savedRatingStar"
                                                                                            FilledStarCssClass="filledRatingStar" EmptyStarCssClass="emptyRatingStar" OnDataBinding="RowRateCMS_DataBinding"
                                                                                            OnChanged="RowRateCMS_Changed" OnLoad="RowRateCMS_Load" />
                                                                                    </ContentTemplate>
                                                                                </asp:UpdatePanel>
                                                                            </td>
                                                                            <td>
                                                                                <asp:Panel runat="server" ID="PanelHeader" OnLoad="PanelHeader_Load">
                                                                                    <%--<asp:Label runat="server" ID="lblCpComment" Text="Comment" ForeColor="Blue" onmouseover="this.style.cursor='hand'" />--%>
                                                                                    <asp:UpdatePanel runat="server" ID="upContent" UpdateMode="Conditional">
                                                                                        <ContentTemplate>
                                                                                            <table cellpadding="0" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:ImageButton runat="server" ID="btnExpand" ImageUrl="~/Images/expand.jpg" OnClick="btnExpand_Click" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <asp:ImageButton runat="server" ID="btnCollapse" ImageUrl="~/Images/collapse.jpg"
                                                                                                            OnClick="btnCollapse_Click" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <asp:Label runat="server" ID="lblClickComment" Text="Comment" ForeColor="Blue" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                            <%--<asp:LinkButton runat="server" ID="lclCpComment" Text="Comment" OnClick="lclCpComment_Click" />--%>
                                                                                        </ContentTemplate>
                                                                                    </asp:UpdatePanel>
                                                                                </asp:Panel>
                                                                            </td>
                                                                            <td align="right">
                                                                                <asp:HyperLink runat="server" ID="hlVideo" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=17"
                                                                                    ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlVideo_Load" />
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td colspan="8">
                                                                                <asp:Panel runat="server" ID="PanelContent" OnLoad="PanelContent_Load">
                                                                                    <asp:UpdatePanel runat="server" ID="upComment" UpdateMode="Conditional">
                                                                                        <ContentTemplate>
                                                                                            <table width="100%" runat="server" id="tbContent">
                                                                                                <tr>
                                                                                                    <th align="left">
                                                                                                        Text Comment :
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:GridView runat="server" ID="gvComment" EnableTheming="false" AutoGenerateColumns="false"
                                                                                                            ShowHeader="false" BorderWidth="0" BorderColor="White" Visible="false" OnRowDataBound="gvComment_RowDataBound">
                                                                                                            <Columns>
                                                                                                                <asp:TemplateField>
                                                                                                                    <ItemTemplate>
                                                                                                                        <asp:HiddenField runat="server" ID="hdnSID" Value='<%#Eval("SID") %>' />
                                                                                                                        <asp:HiddenField runat="server" ID="hdnCreateBy" Value='<%#Eval("CreateDateBy") %>' />
                                                                                                                        <table>
                                                                                                                            <tr>
                                                                                                                                <th>
                                                                                                                                    <font color='blue'>
                                                                                                                                        <%# Eval("CreateDateBy")%></font>
                                                                                                                                </th>
                                                                                                                                <td>
                                                                                                                                    <font color='gray'>
                                                                                                                                        <%# Eval("CreateDated")%></font>
                                                                                                                                </td>
                                                                                                                                <td width="100px">
                                                                                                                                </td>
                                                                                                                                <td>
                                                                                                                                    <asp:LinkButton runat="server" ID="btnReply" Text="Reply" OnClick="btnReply_Click" />&nbsp;&nbsp;<asp:LinkButton
                                                                                                                                        runat="server" ID="btnDelete" Text="Delete" OnClick="btnDelete_Click" OnLoad="btnDelete_Load" />
                                                                                                                                </td>
                                                                                                                            </tr>
                                                                                                                            <tr>
                                                                                                                                <td colspan="4">
                                                                                                                                    <table>
                                                                                                                                        <tr>
                                                                                                                                            <td colspan="2">
                                                                                                                                                <%# Eval("Comments")%>
                                                                                                                                            </td>
                                                                                                                                        </tr>
                                                                                                                                        <tr>
                                                                                                                                            <td width="10px">
                                                                                                                                            </td>
                                                                                                                                            <td>
                                                                                                                                                <asp:GridView runat="server" ID="gvReplyComment" EnableTheming="false" AutoGenerateColumns="false"
                                                                                                                                                    ShowHeader="false" BorderWidth="1" BorderColor="Gray">
                                                                                                                                                    <Columns>
                                                                                                                                                        <asp:TemplateField>
                                                                                                                                                            <ItemTemplate>
                                                                                                                                                                <asp:HiddenField runat="server" ID="hdnReplySID" Value='<%#Eval("SID") %>' />
                                                                                                                                                                <asp:HiddenField runat="server" ID="hdnReplyCreateBy" Value='<%#Eval("CreateDateBy") %>' />
                                                                                                                                                                <table>
                                                                                                                                                                    <tr>
                                                                                                                                                                        <th>
                                                                                                                                                                            <font color='blue'>
                                                                                                                                                                                <%# Eval("CreateDateBy")%></font>
                                                                                                                                                                        </th>
                                                                                                                                                                        <td>
                                                                                                                                                                            <font color='gray'>
                                                                                                                                                                                <%# Eval("CreateDated")%></font>
                                                                                                                                                                        </td>
                                                                                                                                                                        <td width="30px">
                                                                                                                                                                        </td>
                                                                                                                                                                        <td>
                                                                                                                                                                            <asp:LinkButton runat="server" ID="btnDeleteReply" Text="Delete" OnClick="btnDeleteReply_Click"
                                                                                                                                                                                OnLoad="btnDeleteReply_Load" />
                                                                                                                                                                        </td>
                                                                                                                                                                    </tr>
                                                                                                                                                                    <tr>
                                                                                                                                                                        <td colspan="4">
                                                                                                                                                                            <%# Eval("Comments")%>
                                                                                                                                                                        </td>
                                                                                                                                                                    </tr>
                                                                                                                                                                </table>
                                                                                                                                                            </ItemTemplate>
                                                                                                                                                        </asp:TemplateField>
                                                                                                                                                    </Columns>
                                                                                                                                                </asp:GridView>
                                                                                                                                            </td>
                                                                                                                                        </tr>
                                                                                                                                    </table>
                                                                                                                                </td>
                                                                                                                            </tr>
                                                                                                                            <tr runat="server" id="trReply" visible="false">
                                                                                                                                <td colspan="4">
                                                                                                                                    <table>
                                                                                                                                        <tr>
                                                                                                                                            <td>
                                                                                                                                                <asp:TextBox runat="server" ID="txtReplyComment" TextMode="MultiLine" Width="400px"
                                                                                                                                                    Height="100px" />
                                                                                                                                            </td>
                                                                                                                                        </tr>
                                                                                                                                        <tr>
                                                                                                                                            <td>
                                                                                                                                                <asp:Button runat="server" ID="btnReplyComment" Text="Reply Comment" OnClick="btnReplyComment_Click" />
                                                                                                                                            </td>
                                                                                                                                        </tr>
                                                                                                                                    </table>
                                                                                                                                </td>
                                                                                                                            </tr>
                                                                                                                            <tr>
                                                                                                                                <td colspan="4">
                                                                                                                                    <hr />
                                                                                                                                </td>
                                                                                                                            </tr>
                                                                                                                        </table>
                                                                                                                    </ItemTemplate>
                                                                                                                </asp:TemplateField>
                                                                                                            </Columns>
                                                                                                        </asp:GridView>
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <th align="left">
                                                                                                        Comment on this video
                                                                                                    </th>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:TextBox runat="server" ID="txtComment" TextMode="MultiLine" Width="400px" Height="100px" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:Button runat="server" ID="btnAddComment" Text="Post Comment" OnClick="btnAddComment_Click" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </ContentTemplate>
                                                                                    </asp:UpdatePanel>
                                                                                </asp:Panel>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                        <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="3%">
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" height="20">
                        </td>
                    </tr>
                    <tr>
                        <td width="3%">
                        </td>
                        <td width="94%" class="h3">
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="50%" class="h3">
                                        <asp:Literal ID="LiT6" runat="server" OnLoad="LiTs_Load">News</asp:Literal>
                                    </td>
                                    <td class="h3">
                                        <asp:Literal ID="LiT7" runat="server" OnLoad="LiTs_Load">New eDM</asp:Literal>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="3%">
                        </td>
                    </tr>
                    <tr>
                        <td width="3%">
                        </td>
                        <td width="94%">
                            <hr />
                        </td>
                        <td width="3%">
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" height="5">
                        </td>
                    </tr>
                    <tr>
                        <td width="3%">
                            &nbsp;
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td height="43" valign="top">
                                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                            <td width="50%" valign="top">
                                                                <asp:GridView runat="server" ID="gvNews" EnableTheming="false" AutoGenerateColumns="false"
                                                                    ShowHeader="false" DataSourceID="sqlNews" BorderColor="White" BorderWidth="0">
                                                                    <Columns>
                                                                        <asp:TemplateField>
                                                                            <ItemTemplate>
                                                                                <table width="90%" border="0" cellspacing="0" cellpadding="0">
                                                                                    <tr>
                                                                                        <td height="45" valign="top">
                                                                                            <a href='http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                                                                                target='_blank'>
                                                                                                <%#Trim(Eval("title"))%></a>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <%#ShowAbstract(Eval("abstract"), Eval("category_name"), Eval("record_id"), Container.DataItemIndex)%>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td align="right">
                                                                                            <asp:HyperLink runat="server" ID="hlNews" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=12"
                                                                                                ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlNews_Load" />
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                    </Columns>
                                                                </asp:GridView>
                                                                <asp:SqlDataSource runat="server" ID="sqlNews" ConnectionString="<%$ConnectionStrings: RFM %>"
                                                                    SelectCommand="" />
                                                            </td>
                                                            <td valign="top">
                                                                <asp:GridView runat="server" ID="gvEDM" EnableTheming="false" AutoGenerateColumns="false"
                                                                    ShowHeader="false" DataSourceID="sqlEDM" BorderColor="White" BorderWidth="0">
                                                                    <Columns>
                                                                        <asp:TemplateField>
                                                                            <ItemTemplate>
                                                                                <table width="90%" border="0" cellspacing="0" cellpadding="0">
                                                                                    <tr>
                                                                                        <td width="4%">
                                                                                            <img src="images/point.png" alt="" width="7" height="8" />
                                                                                        </td>
                                                                                        <td width="96%">
                                                                                            <a href='http://my.advantech.com/Includes/GetTemplate.ashx?RowId=<%#Eval("row_id") %>&Email=tc.chen@advantech.com.tw'
                                                                                                target='_blank'>
                                                                                                <%# Trim(Eval("email_subject"))%></a>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                        </td>
                                                                                        <td height="8" style="background-image: url(images/line02.jpg); background-repeat: repeat-x;
                                                                                            background-position: center">
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                    </Columns>
                                                                </asp:GridView>
                                                                <asp:SqlDataSource runat="server" ID="sqlEDM" ConnectionString="<%$ConnectionStrings: RFM %>"
                                                                    SelectCommand="" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <a href="#" class="h4"></a>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="3%">
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" height="20">
                        </td>
                    </tr>
                    <tr>
                        <td width="3%">
                        </td>
                        <td width="94%" class="h3">
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="50%" class="h3">
                                        <asp:Literal ID="LiT8" runat="server" OnLoad="LiTs_Load">Case Study</asp:Literal>
                                    </td>
                                    <td class="h3">
                                        <asp:Literal ID="LiT9" runat="server" OnLoad="LiTs_Load">White Papers</asp:Literal>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="3%">
                        </td>
                    </tr>
                    <tr>
                        <td width="3%">
                        </td>
                        <td width="94%">
                            <hr />
                        </td>
                        <td width="3%">
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" height="5">
                        </td>
                    </tr>
                    <tr>
                        <td width="3%">
                            &nbsp;
                        </td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td height="43" valign="top">
                                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                            <td width="50%" valign="top">
                                                                <asp:GridView runat="server" ID="gvCaseStudy" EnableTheming="false" Width="100%"
                                                                    AutoGenerateColumns="false" DataSourceID="sqlCaseStudy" BorderColor="White" BorderWidth="0"
                                                                    ShowHeader="false">
                                                                    <Columns>
                                                                        <asp:TemplateField>
                                                                            <ItemTemplate>
                                                                                <table width="90%" border="0" cellspacing="0" cellpadding="0">
                                                                                    <tr>
                                                                                        <td width="4%">
                                                                                            <img src="images/point.png" alt="" width="7" height="8" />
                                                                                        </td>
                                                                                        <td width="96%">
                                                                                            <a href='http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                                                                                target='_blank'>
                                                                                                <%#Trim(Eval("title"))%></a>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                        </td>
                                                                                        <td height="8" style="background-image: url(images/line02.jpg); background-repeat: repeat-x;
                                                                                            background-position: center">
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                    </Columns>
                                                                </asp:GridView>
                                                                <asp:SqlDataSource runat="server" ID="sqlCaseStudy" ConnectionString="<%$ ConnectionStrings:RFM %>"
                                                                    SelectCommand="" />
                                                                <table width="90%" border="0" cellspacing="0" cellpadding="0">
                                                                    <tr>
                                                                        <td>
                                                                            &nbsp;
                                                                        </td>
                                                                        <td align="right">
                                                                            <asp:HyperLink runat="server" ID="hlCaseStudy" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=3"
                                                                                ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlCaseStudy_Load" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                            <td valign="top">
                                                                <asp:GridView runat="server" ID="gvWhitePapers" EnableTheming="false" AutoGenerateColumns="false"
                                                                    DataSourceID="sqlWhitePapers" BorderColor="White" BorderWidth="0" ShowHeader="false">
                                                                    <Columns>
                                                                        <asp:TemplateField>
                                                                            <ItemTemplate>
                                                                                <table width="90%" border="0" cellspacing="0" cellpadding="0">
                                                                                    <tr>
                                                                                        <td width="4%">
                                                                                            <img src="images/point.png" alt="" width="7" height="8" />
                                                                                        </td>
                                                                                        <td width="96%">
                                                                                            <a href='http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                                                                                target='_blank'>
                                                                                                <%#Trim(Eval("title"))%></a>
                                                                                        </td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                        </td>
                                                                                        <td height="8" style="background-image: url(images/line02.jpg); background-repeat: repeat-x;
                                                                                            background-position: center">
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                    </Columns>
                                                                </asp:GridView>
                                                                <asp:SqlDataSource runat="server" ID="sqlWhitePapers" ConnectionString="<%$ ConnectionStrings:RFM %>"
                                                                    SelectCommand="" />
                                                                <table width="90%" border="0" cellspacing="0" cellpadding="0">
                                                                    <tr>
                                                                        <td>
                                                                            &nbsp;
                                                                        </td>
                                                                        <td align="right">
                                                                            <asp:HyperLink runat="server" ID="hlWhitePaper" NavigateUrl="~/Product/MaterialSearch.aspx?key=&LitType=19"
                                                                                ImageUrl="~/images/more_btn.jpg" Width="30" Height="12" OnLoad="hlWhitePaper_Load" />
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="3%">
                            &nbsp;
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>
