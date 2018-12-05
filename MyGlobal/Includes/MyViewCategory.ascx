<%@ Control Language="VB" ClassName="MyViewCategory" %>

<script runat="server">
    Public _cms As MyLog.CMSCategory, _lit As MyLog.LiteratureType, _tech As MyLog.TechnicalDocument, _is_cms As Boolean = False, _is_lit As Boolean = False, _is_tech As Boolean = False
    Public showBig As Boolean = False
    Public Property CMSCategory As MyLog.CMSCategory
        Get
            Return _cms
        End Get
        Set(ByVal value As MyLog.CMSCategory)
            _cms = value
        End Set
    End Property
    
    Public Property LiteratureCategory As MyLog.LiteratureType
        Get
            Return _lit
        End Get
        Set(ByVal value As MyLog.LiteratureType)
            _lit = value
        End Set
    End Property
    
    Public Property TechnicalCategory As MyLog.TechnicalDocument
        Get
            Return _tech
        End Get
        Set(ByVal value As MyLog.TechnicalDocument)
            _tech = value
        End Set
    End Property
    
    Public Property ShowCMS As Boolean
        Get
            Return _is_cms
        End Get
        Set(ByVal value As Boolean)
            _is_cms = value
        End Set
    End Property
    
    Public Property ShowLit As Boolean
        Get
            Return _is_lit
        End Get
        Set(ByVal value As Boolean)
            _is_lit = value
        End Set
    End Property
    
    Public Property ShowTech As Boolean
        Get
            Return _is_tech
        End Get
        Set(ByVal value As Boolean)
            _is_tech = value
        End Set
    End Property

    Protected Sub gv1_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim lblt As Label = CType(e.Row.Cells(0).FindControl("lblTitle"), Label)
            Dim lblt1 As Label = CType(e.Row.Cells(0).FindControl("lblTitle1"), Label)
            Dim url As String = "", like_url As String = "", otherHeader As String = ""
            Dim hlt As HtmlControl = CType(e.Row.Cells(0).FindControl("hlTitle"), HtmlControl)
            Dim imgS As Image = CType(e.Row.Cells(0).FindControl("imgSmall"), Image)
            Dim imgS1 As Image = CType(e.Row.Cells(0).FindControl("imgSmall1"), Image)
            Dim imgB As Image = CType(e.Row.Cells(0).FindControl("imgBig"), Image)
            
            If ShowCMS Then
                otherHeader = CMSCategory.ToString
                If CMSCategory = MyLog.CMSCategory.eDM Then
                    url = "http://" + Request.ServerVariables("HTTP_HOST") + "/Includes/GetTemplate.ashx?RowId=" + DataBinder.Eval(e.Row.DataItem, "ROW_ID")
                    like_url = url
                Else
                    url = "http://resources.advantech.com.tw/sso/autologin.aspx?tempid=" + Session("TempId") + "&id=" + Session("user_id") + "&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=" + DataBinder.Eval(e.Row.DataItem, "ROW_ID")
                    like_url = "http://resources.advantech.com/Resources/Details.aspx?rid=" + DataBinder.Eval(e.Row.DataItem, "ROW_ID")
                End If
                If CMSCategory = MyLog.CMSCategory.eDM OrElse CMSCategory = MyLog.CMSCategory.Video OrElse CMSCategory = MyLog.CMSCategory.eCatalog Then
                    hlt.Visible = True : e.Row.Cells(0).FindControl("tdImg").Visible = True
                    imgS.Height = 90
                End If
                If CMSCategory = MyLog.CMSCategory.News OrElse CMSCategory = MyLog.CMSCategory.CaseStudy Then
                    CType(e.Row.Cells(0).FindControl("lblDesc"), Label).Text = CType(e.Row.Cells(0).FindControl("lblDesc"), Label).Text + "<br>" + String.Format("<a href='{0}' target='_blank'>...(Read more)</a>", url)
                End If
            ElseIf ShowLit Then
                otherHeader = LiteratureCategory.ToString
                Dim file_ext As String = DataBinder.Eval(e.Row.DataItem, "FILE_EXT").ToString.ToUpper()
                url = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "ROW_ID").ToString
                like_url = url
                Dim hasImage As Boolean = False
                If file_ext = "JPG" Or file_ext = "GIF" Or file_ext = "JPEG" Or file_ext = "PNG" Or file_ext = "BMP" Then
                    imgS.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "ROW_ID").ToString
                    hasImage = True
                ElseIf file_ext = "TIF" OrElse file_ext = "TIFF" Then
                    imgS.ImageUrl = "~/Includes/TIFF_Handler.ashx?LIT_ID=" + DataBinder.Eval(e.Row.DataItem, "ROW_ID").ToString
                    hasImage = True
                ElseIf file_ext = "PDF" Then
                    If DataBinder.Eval(e.Row.DataItem, "IMG_URL").ToString <> "" Then
                        imgS.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "IMG_URL").ToString
                        hasImage = True
                    Else
                        imgS.Visible = False : imgB.Visible = False
                    End If
                Else
                    imgS.Visible = False : imgB.Visible = False
                End If
                
                If hasImage Then
                    If showBig Then
                        imgB.ImageUrl = imgS.ImageUrl
                        hlt.Visible = True : e.Row.Cells(0).FindControl("tdImg").Visible = True
                    Else
                        imgS1.ImageUrl = imgS.ImageUrl : e.Row.Cells(0).FindControl("tdImg").Visible = False : imgS1.Visible = True
                    End If
                End If
            ElseIf ShowTech Then
                otherHeader = TechnicalCategory.ToString
                url = "http://downloadt.advantech.com/download/downloadsr.aspx?File_Id=" + DataBinder.Eval(e.Row.DataItem, "ROW_ID").ToString
                like_url = url
                imgS.Visible = False : imgB.Visible = False
            End If
            CType(e.Row.Cells(0).FindControl("lblOtherHeader"), Label).Text = otherHeader
            
            lblt.Text = "<a target='_blank' href='" + url + "'><font color='#3fb2e2'>" + lblt.Text + "</font></a>"
            lblt1.Text = "<a target='_blank' href='" + url + "'><font color='#000000'>" + lblt1.Text + "</font></a>"
            hlt.Attributes("href") = url
            
            If e.Row.Cells(0).FindControl("fblike") IsNot Nothing Then
                CType(e.Row.Cells(0).FindControl("fblike"), HtmlControl).Attributes("src") = "http://www.facebook.com/plugins/like.php?href=" + like_url + "&layout=standard&show_faces=true&width=350&action=like&colorscheme=light&height=25"
            End If
            '<a runat="server" id="twitter" href="http://twitter.com/share" class="twitter-share-button" data-url="">Tweet</a>
            If e.Row.Cells(0).FindControl("divTwitter") IsNot Nothing Then
                Dim lb As New Label
                lb.Text = "<a href='http://twitter.com/share' class='twitter-share-button' data-url='" + like_url + "'>Tweet</a>"
                CType(e.Row.Cells(0).FindControl("divTwitter"), HtmlControl).Controls.Add(lb)
            End If
            If e.Row.Cells(0).FindControl("divGoogle") IsNot Nothing Then
                Dim lb As New Label
                lb.Text = "<g:plusone size='medium' href='" + like_url + "'></g:plusone>"
                CType(e.Row.Cells(0).FindControl("divGoogle"), HtmlControl).Controls.Add(lb)
            End If
            If e.Row.RowIndex = 0 Then
                If showBig Then
                    CType(e.Row.Cells(0).FindControl("MultiViewCategory"), MultiView).ActiveViewIndex = 1
                End If
                
                'Dim desc As String = ""
                'If CMSCategory = MyLog.CMSCategory.News Then
                '    desc = Util.GetCMSContent(DataBinder.Eval(e.Row.DataItem, "ROW_ID"), "news")
                '    If desc <> "" Then CType(e.Row.Cells(0).FindControl("lblDesc1"), Label).Text = desc.Substring(0, 400) + "<br>" + String.Format("<div id='{0}'><a href='javascript:void(0);' onclick=""GetNews('{0}', '{1}', '{2}');"">...(Read more)</a><div>", CType(e.Row.Cells(0).FindControl("lblDesc1"), Label).ClientID, DataBinder.Eval(e.Row.DataItem, "ROW_ID").ToString, "news")
                'End If
                'If CMSCategory = MyLog.CMSCategory.CaseStudy Then
                '    desc = Util.GetCMSContent(DataBinder.Eval(e.Row.DataItem, "ROW_ID"), "case study")
                '    If desc <> "" Then CType(e.Row.Cells(0).FindControl("lblDesc1"), Label).Text = desc.Substring(0, 400) + "<br>" + String.Format("<div id='{0}'><a href='javascript:void(0);' onclick=""GetNews('{0}', '{1}', '{2}');"">...(Read more)</a><div>", CType(e.Row.Cells(0).FindControl("lblDesc1"), Label).ClientID, DataBinder.Eval(e.Row.DataItem, "ROW_ID").ToString, "case study")
                'End If
            End If
            If e.Row.RowIndex = 1 AndAlso showBig Then
                CType(e.Row.Cells(0).FindControl("panelOtherHeader"), Panel).Visible = True
            End If
        End If
    End Sub

    Protected Sub sql1_Load(sender As Object, e As System.EventArgs)
        Dim sql As String = ""
        If ShowCMS Then
            sql = MyLog.GetSql(CMSCategory.ToString)
        ElseIf ShowLit Then
            sql = MyLog.GetSql(LiteratureCategory.ToString)
        ElseIf ShowTech Then
            sql = MyLog.GetSql(TechnicalCategory.ToString)
        End If
        sql1.SelectCommand = sql
    End Sub
    
    Public Sub PageIndexChanged(ByVal PageIndex As String)
        gv1.PageIndex = CInt(PageIndex) - 1
    End Sub

    Protected Sub btnP1_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP2_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP3_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP4_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP5_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP6_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP7_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub gv1_DataBound(sender As Object, e As System.EventArgs)
        Try
            If gv1.BottomPagerRow IsNot Nothing Then
                
                Dim quotient As Integer = Math.DivRem(gv1.PageIndex, 7, 0)
                For i As Integer = 0 To 6
                    CType(gv1.BottomPagerRow.FindControl("btnP" + (i + 1).ToString), LinkButton).Text = (quotient * 7) + i + 1
                Next
                Dim PageIndex As Integer = 0
                Math.DivRem(gv1.PageIndex, 7, PageIndex)
                If CInt(CType(gv1.BottomPagerRow.FindControl("btnP1"), LinkButton).Text) + 7 > gv1.PageCount Then
                    Dim MaxPageIndex As Integer = 0
                    Math.DivRem(gv1.PageCount, 7, MaxPageIndex)
                    For i As Integer = MaxPageIndex To 6
                        CType(gv1.BottomPagerRow.FindControl("btnP" + (i + 1).ToString), LinkButton).Visible = False
                    Next
                End If
                
                Dim btn As LinkButton = CType(gv1.BottomPagerRow.FindControl("btnP" + (PageIndex + 1).ToString), LinkButton)
                btn.ForeColor = Drawing.Color.Black : btn.Font.Bold = True
                If gv1.PageIndex >= 7 Then CType(gv1.BottomPagerRow.FindControl("btnPre"), LinkButton).Visible = True
            End If
        Catch ex As Exception

        End Try
        
    End Sub

    Protected Sub btnNext_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged((gv1.PageIndex + 7 + 1).ToString)
    End Sub

    Protected Sub btnViewAll_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)

    End Sub

    Protected Sub btnPre_Click(sender As Object, e As System.EventArgs)
        PageIndexChanged((gv1.PageIndex - 7 + 1).ToString)
    End Sub

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If ShowCMS Then
            If CMSCategory = MyLog.CMSCategory.eCatalog Or CMSCategory = MyLog.CMSCategory.eDM Or CMSCategory = MyLog.CMSCategory.Video Then showBig = True
        End If
        If ShowLit Then
            If LiteratureCategory = MyLog.LiteratureType.Banner Or LiteratureCategory = MyLog.LiteratureType.Photo Then showBig = True
        End If
        If showBig Then
            gv1.PageSize = 6
        End If
    End Sub
</script>
<style type="text/css">
    .PageButton 
    {
        color:#0032D0;
        border-width:1px;
        border-color:#CFCFCF;
        border-style:solid;
        background-color:#F7F7F7;
        font-style:normal;
        text-align:center;
        vertical-align:middle;
        display:table-cell;
        width:21px;
        height:25px;
    }
</style>

<asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:GridView runat="server" ID="gv1" EnableTheming="false" ShowHeader="false" ShowFooter="false" BorderWidth="0" BorderColor="White" RowStyle-Width="0" AutoGenerateColumns="false" 
            PageSize="10" AllowPaging="true" DataSourceID="sql1" OnRowDataBound="gv1_RowDataBound" OnDataBound="gv1_DataBound" CellPadding="10">
            <Columns>
                <asp:TemplateField ItemStyle-BorderColor="White">
                    <ItemTemplate>
                        <asp:Panel runat="server" ID="panelOtherHeader" Visible="false">
                            <table width="630" border="0" align="center" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td>
                                        <img src="../images/hline1.jpg" width="630" height="5" style="border:0px" />
                                    </td>
                                </tr>
                                <tr>
                                    <td height="10">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="630" border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td width="19">
                                                    <img src="../images/band_sky1.jpg" width="7" height="21" style="border:0px" />
                                                </td>
                                                <td width="621" class="subtitle">
                                                    Other <asp:Label runat="server" ID="lblOtherHeader" /> You Have Also Seen
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="10">
                                    </td>
                                </tr>
                            </table>
                        </asp:Panel>
                        <asp:MultiView runat="server" ID="MultiViewCategory" ActiveViewIndex="0">
                            <asp:View runat="server" ID="View1">
                                <table width="630" border="0" align="center" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="21%" rowspan="2" runat="server" id="tdImg" visible="false">
                                            <asp:Image runat="server" ID="imgSmall" ImageUrl='<%#Eval("img_url") %>' width="121" />
                                        </td>
                                        <td width="79%" class="bluetext">
                                            <asp:Label runat="server" ID="lblTitle" Text='<%#Eval("title") %>' />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top">
                                            <asp:Label runat="server" ID="lblDesc" Text='<%#Eval("description") %>' />
                                            <br />
                                            <asp:Image runat="server" ID="imgSmall1" ImageUrl='<%#Eval("img_url") %>' width="121" Visible="false" />
                                        </td>
                                    </tr>
                                    <tr><td height="5"></td></tr>
                                </table>
                            </asp:View>
                            <asp:View runat="server" ID="View2">
                                <table width="630" border="0" align="center" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td width="629" height="10">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="tabletext">
                                            <asp:Label runat="server" ID="lblTitle1" Text='<%#Eval("title") %>' />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            &nbsp;
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center">
                                            <a href='' runat="server" ID="hlTitle" Target="_blank" CssClass="bluetext" visible="false">
                                                <asp:Image runat="server" ID="imgBig" ImageUrl='<%#Eval("img_url") %>' Width="250" />
                                            </a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="10">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblDesc1" Text='<%#Eval("description") %>' />
                                            <br />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="10">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table width="630" border="0" align="center" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td width="142" bgcolor="#f6f6f6">
                                                        &nbsp;
                                                    </td>
                                                    <td bgcolor="#f6f6f6">
                                                        <div runat="server" id="divTwitter"></div>
                                                    </td>
                                                    <td bgcolor="#f6f6f6">
                                                        <div runat="server" id="divGoogle"></div>
                                                    </td>
                                                    <td bgcolor="#f6f6f6">
                                                        <iframe allowtransparency="" frameborder="0" runat="server" id="fbLike" scrolling="no" src="" style="border-bottom: medium none; border-left: medium none; width: 250px; height: 30px; overflow: hidden; border-top: medium none; border-right: medium none"></iframe>
                                                    </td>
                                                    <td width="61" bgcolor="#f6f6f6">
                                                        &nbsp;
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="10">
                                        </td>
                                    </tr>
                                </table>
                            </asp:View>
                        </asp:MultiView>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <PagerTemplate>
                <table width="100%">
                    <tr>
                        <td align="center">
                            <table>
                                <tr>
                                    <td width="30">&nbsp;</td>
                                    <td><asp:LinkButton runat="server" ID="btnPre" cssClass="blue" Text="Previous Page" OnClick="btnPre_Click" Visible="false" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnP1" CssClass="PageButton" OnClick="btnP1_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnP2" CssClass="PageButton" OnClick="btnP2_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnP3" CssClass="PageButton" OnClick="btnP3_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnP4" CssClass="PageButton" OnClick="btnP4_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnP5" CssClass="PageButton" OnClick="btnP5_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnP6" CssClass="PageButton" OnClick="btnP6_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnP7" CssClass="PageButton" OnClick="btnP7_Click" /></td>
                                    <td><asp:LinkButton runat="server" ID="btnNext" cssClass="blue" Text="Next Page" OnClick="btnNext_Click" /></td>
                                    <td><asp:ImageButton runat="server" ID="btnViewAll" ImageUrl="~/images/btn_see-all-videos.jpg" width="159" height="30" OnClick="btnViewAll_Click" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </PagerTemplate>
            <PagerStyle BorderWidth="0" BorderColor="White" />
            <RowStyle BorderColor="White" BorderWidth="0" />
        </asp:GridView>
        <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings: MY %>"
            SelectCommand="" OnLoad="sql1_Load">
        </asp:SqlDataSource>

        
    </ContentTemplate>
</asp:UpdatePanel>