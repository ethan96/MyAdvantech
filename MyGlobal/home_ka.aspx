<%@ Page Title="MyAdvantech - Key Account Home" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>
<%@ Register Src="~/Includes/MyEDM.ascx" TagPrefix="uc7" TagName="MyEDM" %>
<%@ Register Src="~/Includes/CustomContent.ascx" TagName="WCustContent" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/Opty/MyLeads.ascx" TagName="MyLeads" TagPrefix="uc7" %>
<%@ Register Src="~/Includes/ShipCalAjax.ascx" TagPrefix="uc1" TagName="ShipCalAjax" %>
<%@ Register Src="~/Includes/SupportBlock.ascx" TagName="SupportBlock" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/Banner.ascx" TagName="Banner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/AMDbanner.ascx" TagName="AMDBanner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/eLearningBanner.ascx" TagName="eLearningBanner" TagPrefix="uc10" %>
<%@ Register Src="~/Includes/BillboardBlock.ascx" TagName="BillboardBlock" TagPrefix="uc10" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If (Request.Browser.MSDomVersion.Major = 0) Then
            Response.Cache.SetNoStore()
            ' No client side cashing for non IE browsers 
        End If
        If Not Page.IsPostBack Then
            'If Session("user_id") = "rudy.wang@advantech.com.tw" Then Session("RBU") = "AENC" : Session("LanG") = "ENG"
            If Session("account_status").ToString() <> "KA" And Session("account_status").ToString() <> "EZ" Then Response.Redirect("home.aspx")
            'If Session("RBU") = "AENC" Then Response.Redirect("home_cp_aenc.aspx")
            Me.Master.EnableAsyncPostBackHolder = False
            'Me.SrcAddedPN.SelectCommand = GetAddedPNSql()
            If Session("company_id") = "T80087921" Then hyePricer.Visible = True
            If Session("company_id") = "UZISCHE01" Then trBTOSCust.Visible = True
            If Session("user_id") IsNot Nothing AndAlso Util.IsInternalUser(Session("user_id")) Then
            Else
                'LiT20_br.Visible = False : LiT20.Visible = False
            End If

            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.ToUpper = "US" Then
            If Session("ORG_ID") IsNot Nothing AndAlso Left(Session("ORG_ID").ToString.ToUpper, 2) = "US" Then
                MyLeadsTR.Visible = False
                If Session("RBU") = "AAC" Then

                Else
                    If Session("RBU") = "AENC" Then

                    End If
                End If
            End If
            '20131028 TC: Open Advanced Product Search to all KA
            trAdvProdSearch.Visible = True
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("ORG") IsNot Nothing AndAlso Session("ORG").ToString.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
            If Session("ORG_ID") IsNot Nothing AndAlso Session("ORG_ID").ToString.ToUpper.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
                tr_EUGATP.Visible = True : trQuoteHistory.Visible = True
                If User.Identity.Name.Equals("bbriani@arroweurope.com", StringComparison.OrdinalIgnoreCase) Then
                    trChgCompIdSILVERSTAR.Visible = True
                    dlChangeCompanyMultiErpId.Items.Clear()
                    Dim items() As ListItem = { _
                        New ListItem("SILVERSTAR S.R.L.", "EIITSI04"), _
                        New ListItem("ARROW NORDIC COMPONENTS AB", "ENSEAR02"), _
                        New ListItem("ARROW CENTRAL EUROPE GMBH", "EDDEAR09")}
                    For Each li As ListItem In items
                        If li.Value.Equals(Session("company_id").ToString(), StringComparison.OrdinalIgnoreCase) Then
                            li.Selected = True
                        End If
                        dlChangeCompanyMultiErpId.Items.Add(li)
                    Next
                Else
                    If User.Identity.Name.Equals("acantoni@irenesrl.it", StringComparison.OrdinalIgnoreCase) _
                        OrElse User.Identity.Name.Equals("damele@irenesrl.it", StringComparison.OrdinalIgnoreCase) Then
                        trChgCompIdSILVERSTAR.Visible = True
                        dlChangeCompanyMultiErpId.Items.Clear()
                        Dim items() As ListItem = { _
                            New ListItem("IRENE S.R.L. (EIITIR01)", "EIITIR01"), _
                            New ListItem("IRENE S.R.L. (EIITIR03)", "EIITIR03")}
                        For Each li As ListItem In items
                            If li.Value.Equals(Session("company_id").ToString(), StringComparison.OrdinalIgnoreCase) Then
                                li.Selected = True
                            End If
                            dlChangeCompanyMultiErpId.Items.Add(li)
                        Next
                    End If
                End If
                If User.Identity.Name.Equals("c.bruttomesso@digimax.it", StringComparison.OrdinalIgnoreCase) _
                        OrElse User.Identity.Name.Equals("l.gabrieletto@digimax.it", StringComparison.OrdinalIgnoreCase) _
                        OrElse User.Identity.Name.Equals("d.scalabrin@digimax.it", StringComparison.OrdinalIgnoreCase) Then
                    trChgCompIdSILVERSTAR.Visible = True
                    dlChangeCompanyMultiErpId.Items.Clear()
                    Dim items() As ListItem = { _
                        New ListItem("DIGIMAX SRL (EIITDI01)", "EIITDI01"), _
                        New ListItem("DIGIMAX SRL (EIITDI23)", "EIITDI23"), _
                        New ListItem("DIGIMAX Srl (EIITDI26)", "EIITDI26")}
                    For Each li As ListItem In items
                        If li.Value.Equals(Session("company_id").ToString(), StringComparison.OrdinalIgnoreCase) Then
                            li.Selected = True
                        End If
                        dlChangeCompanyMultiErpId.Items.Add(li)
                    Next
                End If
            End If

            'IC 2014/06/26 Selina.Shin ask all AKR's CP can not see hyEUGATP link (Check ACL Avaliability)
            If Session("ORG_ID") IsNot Nothing AndAlso Session("ORG_ID").ToString.ToUpper.StartsWith("KR", StringComparison.OrdinalIgnoreCase) Then
                tdHead.Visible = False
                tdhyEUGATP.Visible = False
            End If

            'ICC 2015/8/6 Champion club is no longer valid
            'If Util.IsPCPUser() Then trChampion.Visible = True : trChampion2.Visible = True

            If Util.IsInternalUser(Session("user_id")) = False Then
                If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then trUpdOrder.Visible = False
            End If

            'Alex 20180314 Tracy ask to hide some information for US10 
            If AuthUtil.IsBBUS Then
                trSysConfig_Orders.Visible = False
                trFuncToolsTitle.Visible = False
                trFuncTools.Visible = False
            End If


        End If
    End Sub

    Protected Sub dlChangeCompanyMultiErpId_SelectedIndexChanged(sender As Object, e As System.EventArgs)
        Dim au As New AuthUtil
        au.ChangeCompanyId(dlChangeCompanyMultiErpId.SelectedValue, "EU10")
        Response.Redirect("home_ka.aspx")
    End Sub

    Protected Sub dlChangeCompanyMultiErpId_DataBound(sender As Object, e As System.EventArgs)
        Dim curCompId As String = Session("company_id")
        For Each li As ListItem In dlChangeCompanyMultiErpId.Items
            li.Selected = False
            If li.Value.Equals(curCompId, StringComparison.OrdinalIgnoreCase) Then
                li.Selected = True
                Exit For
            End If
        Next
    End Sub

    Protected Sub Timer1_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Interval = 99999
        Dim dt As DataTable = MyCalData.GetBOAB(HttpContext.Current.Session("company_id"), HttpContext.Current.Session("org_id"), Now.ToString("yyyy-MM-dd"), DateAdd(DateInterval.Day, 30, Now).ToString("yyyy-MM-dd"), "", "", "")
        If dt.Rows.Count > 0 Then
            gv1.DataSource = dt : gv1.DataBind()
            ViewState("boDt") = dt
        End If
        Timer1.Enabled = False
        imgLoading.Visible = False
    End Sub

    Public Shared Function FDate(ByVal d As String) As String
        If Date.TryParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Now) Then
            Return Date.ParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
        End If
        Return d
    End Function

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs) Handles gv1.Sorting
        GridViewSortExpression = e.SortExpression
        Dim pageIndex As Integer = gv1.PageIndex
        gv1.DataSource = SortDataTable(ViewState("boDt"), False)
        gv1.DataBind()
        gv1.PageIndex = pageIndex
    End Sub

    Protected Function SortDataTable(ByVal dataTable As DataTable, ByVal isPageIndexChanging As Boolean) As DataView
        If Not dataTable Is Nothing Then
            Dim dataView As New DataView(dataTable)
            If GridViewSortExpression <> String.Empty Then
                If isPageIndexChanging Then
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GridViewSortDirection)
                Else
                    dataView.Sort = String.Format("{0} {1}", GridViewSortExpression, GetSortDirection())
                End If
            End If
            Return dataView
        Else
            Response.Write("no gv source!")
            Return New DataView()
        End If
    End Function

    Private Property GridViewSortDirection() As String
        Get
            Return IIf(ViewState("SortDirection") = Nothing, "ASC", ViewState("SortDirection"))
        End Get
        Set(ByVal value As String)
            ViewState("SortDirection") = value
        End Set
    End Property

    Private Property GridViewSortExpression() As String
        Get
            Return IIf(ViewState("SortExpression") = Nothing, String.Empty, ViewState("SortExpression"))
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

    Protected Sub gv1_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
        Timer1.Enabled = False
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gv1.PageIndex = e.NewPageIndex
        gv1.DataSource = ViewState("boDt")
        gv1.DataBind()
    End Sub

    'Shared Function BODateDetail(ByVal d As Date, ByVal rs As DataRow(), ByVal rmars As DataRow(), ByVal ShowDayDetail As Boolean) As String
    '    Dim sb As New System.Text.StringBuilder
    '    If ShowDayDetail Then sb.AppendLine("<div style='Width:100%; height:80px; overflow:auto;'>")
    '    sb.AppendLine("<table width='100%'>")
    '    Dim strDayTitle As New System.Text.StringBuilder
    '    If Not ShowDayDetail Then
    '        For Each r As DataRow In rs
    '            strDayTitle.AppendLine("Backorder: " + Global_Inc.DeleteZeroOfStr(r.Item("ProductId")) + " x " + CInt(r.Item("SchdLineConfirmQty")).ToString() + vbTab)
    '        Next
    '        For Each r As DataRow In rmars
    '            strDayTitle.AppendLine(String.Format("RMA No: {0} Product: {1} Status: {2}", r.Item("RMA_NO"), r.Item("PRODUCT_NAME"), r.Item("RMA_TYPE")))
    '        Next
    '    End If
    '    If rs.Length > 0 OrElse rmars.Length > 0 Then
    '        sb.AppendLine(String.Format("<tr><th><a href='javascript:void(0);'style='color:Black;' title='{1}' onclick='ShowDayFlyout(""{2}"");'>{0}</a></th></tr>", _
    '                                 d.Day.ToString(), strDayTitle.ToString(), d.ToString("yyyyMMdd")))
    '    Else
    '        sb.AppendLine(String.Format("<tr><td align='center'><a href='javascript:void(0);' title='{1}' onclick='ShowDayFlyout(""{2}"");'>{0}</a></td></tr>", _
    '                                d.Day.ToString(), strDayTitle.ToString(), d.ToString("yyyyMMdd")))
    '    End If
    '    If ShowDayDetail Then
    '        For Each r As DataRow In rs
    '            sb.AppendLine(String.Format("<tr><td><a target='_blank' href='Order/BO_BackorderInquiry.aspx?txtPN={0}&txtOrderDateFrom={1}'><b>{0}</b></a></td></tr>", Global_Inc.DeleteZeroOfStr(r.Item("ProductId")), d.ToString("yyyy/MM/dd")))
    '        Next
    '    End If
    '    sb.AppendLine("</table>")
    '    If ShowDayDetail Then sb.AppendLine("</div>")
    '    Return sb.ToString()
    'End Function

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(3).Text = CInt(e.Row.Cells(3).Text)
        End If
    End Sub

    Function GetAddedPNSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 10000 a.PART_NO, b.product_desc ,b.MODEL_NO  "))
            .AppendLine(String.Format(" from MYADVANTECH_PRODUCT_PROMOTION a inner join SAP_PRODUCT b on a.part_no=b.part_no  "))
            .AppendLine(String.Format(" where a.RBU='AENC' "))
            .AppendLine(String.Format(" order by a.PART_NO "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub gvAddedPN_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        'Me.SrcAddedPN.SelectCommand = GetAddedPNSql()
    End Sub

    Protected Sub gvAddedPN_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        'Me.SrcAddedPN.SelectCommand = GetAddedPNSql()
    End Sub
    Protected Sub LiTs_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Lit As Literal = CType(sender, Literal)
        Dim LiTstr As String = Util.GetLANGLiT_text(Lit.ID.ToString.Trim)
        If LiTstr.ToString.Trim <> "" Then
            Lit.Text = LiTstr
        End If
    End Sub

    Protected Sub btnWiki_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim ws As New SSO.MembershipWebservice
        Dim p As SSO.SSOUSER = ws.getProfile(Session("user_id"), "MY")
        If p IsNot Nothing Then
            Response.Redirect(String.Format("http://wiki.advantech.com/apiLoginAdv.php?action=loginAdv&lgname={0}&lgpassword={1}", Session("user_id"), p.login_password))
        End If
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function MyRecentOrderItems() As String
        Try
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 3 a.PART_NO, a.tumbnail_image_id, a.product_desc, a.model_no "))
                .AppendLine(String.Format(" from product_fulltext_new a inner join SAP_PRODUCT b on a.part_no=b.PART_NO "))
                .AppendLine(String.Format(" where a.model_no<>'' and a.material_group in ('PRODUCT') and a.tumbnail_image_id is not null and a.PRODUCT_LINE<>'' and a.PRODUCT_LINE in "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" select top 3 PRODUCT_LINE from estore_user_product where userid='{0}' group by product_line order by COUNT(PRODUCT_LINE)  desc ", HttpContext.Current.Session("user_id")))
                .AppendLine(String.Format(" ) "))
                .AppendLine(String.Format(" order by b.CREATE_DATE desc "))
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
            If dt.Rows.Count < 3 Then
                sb = New System.Text.StringBuilder
                With sb
                    .AppendLine(String.Format(" select top 3 a.PART_NO, a.tumbnail_image_id, a.product_desc, a.model_no "))
                    .AppendLine(String.Format(" from product_fulltext_new a inner join SAP_PRODUCT b on a.part_no=b.PART_NO "))
                    .AppendLine(String.Format(" where a.model_no<>'' and a.material_group in ('PRODUCT') and a.tumbnail_image_id is not null and a.PRODUCT_LINE<>'' "))
                    .AppendLine(String.Format(" order by b.CREATE_DATE desc "))
                End With
                Dim dt2 As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
                If dt2.Rows.Count >= 3 - dt.Rows.Count Then
                    For i As Integer = 0 To dt2.Rows.Count - 1
                        Dim r As DataRow = dt.NewRow()
                        For Each c As DataColumn In dt.Columns
                            r.Item(c.ColumnName) = dt2.Rows(i).Item(c.ColumnName)
                        Next
                        dt.Rows.Add(r)
                        If dt.Rows.Count = 3 Then Exit For
                    Next
                End If
            End If

            Dim SupportImgUrl As String = "my.advantech.eu"
            SupportImgUrl = "downloadt.advantech.com"
            Dim hsb As New System.Text.StringBuilder
            With hsb
                .AppendLine(String.Format("<table width='100%' border='0' cellspacing='0' cellpadding='0'>"))
                .AppendLine("<tr><td class='h3' height='30'>My Viewed Products</td></tr>")
                .AppendLine("<tr><td><table width='100%' border='0' cellspacing='0' cellpadding='0'><tbody><tr>")
                For i As Integer = 0 To dt.Rows.Count - 1
                    Dim dtImg As DataTable = dbUtil.dbGetDataTable("PIS", _
                        String.Format("select isnull(a.IMAGE_ID,'') from model a where a.MODEL_NAME='{0}'", dt.Rows(i).Item("model_no")))
                    .AppendLine("                           <td width='32%' align='left' valign='top'>")
                    .AppendLine("                               <table style='border-style:solid;border-color:#d7d0d0;border-width=1px' width='100%' height='100%'><tbody>")
                    If dtImg.Rows.Count > 0 Then
                        If dtImg.Rows(0).Item(0).ToString <> "" Then
                            .AppendLine(String.Format("                     <tr class=odd5><td><a href='/Product/Model_Detail.aspx?model_no={2}'><img style='height:120px;width:90px;border-width:0px;' src='http://" + SupportImgUrl + "/download/downloadlit.aspx?lit_id={0}' alt='{1}'/></a></td></tr>", dtImg.Rows(0).Item(0), dt.Rows(i).Item("part_no"), dt.Rows(i).Item("model_no")))
                        Else
                            .AppendLine(String.Format("                     <tr class=odd5><td><a href='/Product/Model_Detail.aspx?model_no={2}'><img style='height:120px;width:90px;border-width:0px;' src='http://" + SupportImgUrl + "/download/downloadlit.aspx?lit_id={0}' alt='{1}'/></a></td></tr>", dt.Rows(i).Item("tumbnail_image_id"), dt.Rows(i).Item("part_no"), dt.Rows(i).Item("model_no")))
                        End If
                    Else
                        .AppendLine(String.Format("                     <tr class=odd5><td><a href='/Product/Model_Detail.aspx?model_no={2}'><img style='height:120px;width:90px;border-width:0px;' src='http://" + SupportImgUrl + "/download/downloadlit.aspx?lit_id={0}' alt='{1}'/></a></td></tr>", dt.Rows(i).Item("tumbnail_image_id"), dt.Rows(i).Item("part_no"), dt.Rows(i).Item("model_no")))
                    End If

                    .AppendLine(String.Format("                     <TR class=odd6><td><a href='/Product/Model_Detail.aspx?model_no={0}'>{1}</a><br>{2}</td></TR>", dt.Rows(i).Item("model_no"), dt.Rows(i).Item("part_no"), dt.Rows(i).Item("product_desc").ToString.Replace(",", ", ")))
                    '.AppendLine(String.Format("                     <tr class=odd5><td valign='top' align='center' style='font-weight:bold;'><a href='/Product/Model_Detail.aspx?model_no={0}'>{1}</a></td></tr>", dt.Rows(i).Item("model_no"), dt.Rows(i).Item("part_no")))
                    '.AppendLine(String.Format("                     <tr><td valign='top' align='center'>{0}</td></tr>", dt.Rows(i).Item("product_desc")))
                    '.AppendLine(String.Format("                     <tr><td valign='middle' align='center'><a href='/Product/Model_Detail.aspx?model_no={2}'><img style='height:120px;width:90px;border-width:0px;' src='http://" + SupportImgUrl + "/download/downloadlit.aspx?lit_id={0}' alt='{1}'/></a></td></tr>", dt.Rows(i).Item("tumbnail_image_id"), dt.Rows(i).Item("part_no"), dt.Rows(i).Item("model_no")))
                    '.AppendLine(String.Format("                     <tr><th style='color:Navy' align='center'>{0}{1}</th></tr>", curcy_sign, Util.GetSAPPrice(r.Item("part_no"), cid)))
                    .AppendLine("                               </tbody></table>")
                    .AppendLine("                           </td>")
                    If i < dt.Rows.Count - 1 Then .AppendLine("<td width='2%'></td>")
                Next
                .AppendLine("</tr><tbody></table></td></tr>")
                .AppendLine(String.Format("         </table>"))
            End With
            Return hsb.ToString()
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Error Glob Myrecent items by " + HttpContext.Current.Session("user_id"), ex.ToString, False, "", "")
        End Try
        Return ""
    End Function
    Protected Sub TRMyDashboard_Load(sender As Object, e As System.EventArgs)
        If CInt(dbUtil.dbExecuteScalar("MY", String.Format( _
                                          " select count(company_id) as c from SAP_DIMCOMPANY " + _
                                          " where company_id='{0}' and salesgroup in ('311','320','321','313','314')", Session("company_id")))) > 0 Then
            TRMyDashboard.Visible = True
        Else
            TRMyDashboard.Visible = False
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        #nav {
            z-index: 50;
            position: absolute;
            vertical-align: bottom;
            text-align: right;
            top: 315px;
        }

            #nav a {
                margin: 0 5px;
                padding: 3px 5px;
                border: 1px solid #ccc;
                background: gray;
                text-decoration: none;
                color: White;
                font-weight: bold;
            }

                #nav a.activeSlide {
                    background: #aaf;
                }

                #nav a:focus {
                    outline: none;
                }
    </style>
    <script type="text/javascript" src='./EC/Includes/jquery-latest.min.js'></script>
    <script type="text/javascript" src='./EC/Includes/jquery.cycle.all.latest.js'></script>
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_beginRequest(beginRequest);
        function beginRequest() {
            prm._scrollPosition = null;
        }

        $(document).ready(function () {
            canAccessABRQuotation();
        }
        );


        function canAccessABRQuotation() {
            $("body").css("cursor", "progress");
            var user_id = '<%=User.Identity.Name %>';
            $("#<%=me.TRABRQuotation.ClientID %>").hide();
            $.ajax({
                type: "POST",
                url: "./Services/InternalWebService.asmx/CanAccessABRQuotation",
                data: JSON.stringify({
                    UserID: user_id,
                    RBU: '<%=Session("RBU") %>',
                    AccountStatus: '<%=Session("Account_Status") %>'
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var ATPTotalInfo = $.parseJSON(msg.d);

                    if (ATPTotalInfo) {
                        $("#<%=me.TRABRQuotation.ClientID %>").show();
                    }

                    $("body").css("cursor", "auto");
                },
                error: function (msg) {
                }
            }
            );
        }
    </script>
    <script type="text/javascript">
        var IE = document.all ? true : false;
        if (!IE) document.captureEvents(Event.MOUSEMOVE)
        //document.onmousemove = getMouseXY;
        var tempX = 0;
        var tempY = 0;
        $(function () {
            $('#slideshow').cycle({
                fx: 'fade',
                timeout: 300000000,
                pager: '#nav',
                slideExpr: 'table'
            });
        });
    </script>
    <div class="left">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td height="5"></td>
            </tr>
            <uc10:BillboardBlock runat="server" ID="ucBillboardBlock" />
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT0" runat="server" OnLoad="LiTs_Load">Online Ordering</asp:Literal>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login" style="font-weight: bold;">
                        <tr>
                            <td height="10"></td>
                            <td></td>
                        </tr>
            </tr>
            <tr>
                <td height="20" width="5%"></td>
                <td class="menu_list">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td class="menu_list">
                                <table width="100%" cellpadding="0" cellspacing="0" border="0">
                                    <tr>
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="../Order/cart_list.aspx">
                                                            <asp:Literal ID="LiT16" runat="server" OnLoad="LiTs_Load">Place Component Orders</asp:Literal>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="trSysConfig_Orders">
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="../Order/btos_portal.aspx">
                                                            <asp:Literal ID="LiT17" runat="server" OnLoad="LiTs_Load">System Configuration/Orders</asp:Literal>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="trBTOSCust" visible="false">
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="/Order/Configurator.aspx?BTOITEM=ODM-CPCI1109-BTO&QTY=1">
                                                            <asp:Literal ID="Literal1" runat="server" OnLoad="LiTs_Load">ODM-CPCI1109-BTO</asp:Literal>
                                                        </a>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="/Order/Configurator.aspx?BTOITEM=ODM-CPCI1202-BTO&QTY=1">
                                                            <asp:Literal ID="Literal2" runat="server" OnLoad="LiTs_Load">ODM-CPCI1202-BTO</asp:Literal>
                                                        </a>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="/Order/Configurator.aspx?BTOITEM=ODM-CPCI1203-BTO&QTY=1">
                                                            <asp:Literal ID="Literal10" runat="server" OnLoad="LiTs_Load">ODM-CPCI1203-BTO</asp:Literal>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="trUpdOrder">
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <asp:HyperLink runat="server" ID="hyUploadOrder" NavigateUrl="./order/UploadOrderFromExcel.aspx">
                                                            <asp:Literal ID="LiT32" runat="server" Text="Upload Order" OnLoad="LiTs_Load" />
                                                        </asp:HyperLink>

                                                    </td>

                                                </tr>

                                            </table>

                                        </td>
                                    </tr>
                                    <tr runat="server" id="trChkPrice_Aval">
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="../Order/PriceAndATP.aspx">
                                                            <asp:Literal ID="LiT15" runat="server" OnLoad="LiTs_Load">Check Price & Availability</asp:Literal></a></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="tr_EUGATP" visible="false">
                                        <td height="25" id="tdHead" runat="server"></td>
                                        <td id="tdhyEUGATP" runat="server">
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <asp:HyperLink runat="server" ID="hyEUGATP" NavigateUrl="~/Order/QueryACLATP.aspx"
                                                            Text="Check ACL Availability" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="../Order/BO_OrderTracking.aspx" runat="server" id="lnkMyBO">
                                                            <asp:Literal ID="LiT13" runat="server" OnLoad="LiTs_Load">Order Tracking</asp:Literal></a></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="trQuoteHistory">
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <asp:HyperLink runat="server" ID="hyCompanyQuoteHistory" NavigateUrl="~/Order/QuoteByCompany.aspx"
                                                            Text="Quotation History" />
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="../Order/CartHistory_List.aspx" runat="server" id="lnkCartHistory">
                                                            <asp:Literal ID="LiT34" runat="server" OnLoad="LiTs_Load">Cart & Configuration history</asp:Literal></a></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="TRMyDashboard" onload="TRMyDashboard_Load">
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="./my/MyDashboard.aspx">
                                                            <asp:Literal ID="LiT340" runat="server">My Dashboard</asp:Literal></a></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr runat="server" id="TRABRQuotation" visible="true">
                                        <td height="25"></td>
                                        <td>
                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                <tr>
                                                    <td width="5%" valign="top">
                                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                                    </td>
                                                    <td class="menu_title02">
                                                        <a href="./Order/ABRQuote/B2B_Quotation_List.aspx">
                                                            <asp:Literal ID="Literal11" runat="server">New Quotation</asp:Literal></a></td>
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
            <tr>
                <td height="10"></td>
                <td></td>
            </tr>
        </table>
        </td> </tr>
        <tr>
            <td height="5"></td>
        </tr>
        <tr runat="server" id="trChampion" visible="false">
            <td height="24" class="menu_title">
                <asp:Literal ID="Literal4" runat="server" OnLoad="LiTs_Load">Advantech Champion Club</asp:Literal></td>
        </tr>
        <tr runat="server" id="trChampion2" visible="false">
            <td>
                <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login" style="font-weight: bold;">
                    <tr>
                        <td height="10"></td>
                        <td></td>
                    </tr>
                    <tr>
                        <td width="5%" height="25"></td>
                        <td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink ID="HyperLink11" runat="server" NavigateUrl="~/My/ChampionClub/ChampionClub.aspx">
                                            <asp:Literal ID="Literal5" runat="server">Overview Introduction</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink ID="HyperLink10" runat="server" NavigateUrl="">
                                            <asp:Literal ID="Literal3" runat="server">Regional Program & Registration</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink ID="HyperLink12" runat="server" NavigateUrl="">
                                            <asp:Literal ID="Literal6" runat="server">Point Management</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink ID="HyperLink13" runat="server" NavigateUrl="">
                                            <asp:Literal ID="Literal7" runat="server">Redemption</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink ID="HyperLink14" runat="server" NavigateUrl="">
                                            <asp:Literal ID="Literal8" runat="server">Ranking List</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink ID="HyperLink15" runat="server" NavigateUrl="~/My/ChampionClub/ChampionClub_QA.aspx">
                                            <asp:Literal ID="Literal9" runat="server">FAQ</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="5"></td>
        </tr>
        <tr>
            <td height="24" class="menu_title">
                <asp:Literal ID="LiT3" runat="server" OnLoad="LiTs_Load">Product Info.</asp:Literal></td>
        </tr>
        <tr>
            <td>
                <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                    <tr>
                        <td width="5%" height="10"></td>
                        <td></td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="../Product/ProductSearch.aspx">
                                            <asp:Literal ID="LiT21" runat="server" OnLoad="LiTs_Load">Search</asp:Literal></a></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr runat="server" id="trAdvProdSearch" visible="false">
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink runat="server" ID="hyAdvProdSearch" Text="Advanced Product Search"
                                            NavigateUrl="~/Product/Search.aspx" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink runat="server" ID="hyPPhaseInOut" NavigateUrl="~/Product/Product_PhaseInOut.aspx"
                                            Text="Phase In/ Out" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <a href="../Product/New_Product.aspx">
                                            <asp:Literal ID="LiT23" runat="server" OnLoad="LiTs_Load">New Product Highlight</asp:Literal></a></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink ID="LiT24" runat="server" Text="Warranty Lookup" NavigateUrl="~/Order/RMAWarrantyLookup.aspx" />
                                        <%--<a href="../Order/MyWarrantyExpireItems.aspx">
                                            <asp:Literal ID="LiT24" runat="server" OnLoad="LiTs_Load">Warranty Lookup</asp:Literal></a>--%>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="10"></td>
                        <td></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="5"></td>
        </tr>
        <tr>
            <td height="24" class="menu_title">
                <asp:Literal ID="LiT4" runat="server" OnLoad="LiTs_Load">Support & Download</asp:Literal></td>
        </tr>
        <tr>
            <td>
                <uc9:SupportBlock runat="server" ID="ucSupportBlock" IsCP="true" />
                <asp:HyperLink runat="server" ID="hyePricer" Target="_blank" Text="ePricer" NavigateUrl="~/Includes/ToEIP.ashx?EIPPID=ePricer_SSO"
                    Visible="false" />
            </td>
        </tr>
        <tr>
            <td height="5"></td>
        </tr>
        <tr runat="server" id="trFuncToolsTitle">
            <td height="24" class="menu_title">
                <asp:Literal ID="LiT10" runat="server" OnLoad="LiTs_Load">Functional Tools</asp:Literal>

            </td>
        </tr>
        <tr runat="server" id="trFuncTools">
            <td>
                <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                    <tr>
                        <td height="10"></td>
                        <td></td>
                    </tr>
                    <tr>
                        <td width="5%" height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink runat="server" ID="hyPrjReg" Text="" NavigateUrl="~/My/ProjectRegist.aspx">
                                            <asp:Literal ID="LiT30" runat="server" OnLoad="LiTs_Load">Project Registration Request</asp:Literal><asp:Literal
                                                ID="LiT31" runat="server" OnLoad="LiTs_Load" Visible="false">Special Price Request</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td width="5%" height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink runat="server" ID="hyMyRegPrj" Text="" NavigateUrl="~/My/ProjectRegList.aspx">
                                            <asp:Literal ID="LiT36" runat="server" OnLoad="LiTs_Load">My Registered Projects</asp:Literal>
                                        </asp:HyperLink></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td width="5%" height="25"></td>
                        <td>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="5%" valign="top">
                                        <img src="images/point_02.gif" alt="" width="7" height="14" />
                                    </td>
                                    <td class="menu_title02">
                                        <asp:HyperLink runat="server" ID="hyLeadMgt" Text="Leads Management" NavigateUrl="~/My/MyLeads.aspx" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td height="10"></td>
        </tr>
        <tr runat="server" id="trChgCompIdSILVERSTAR" visible="false">
            <td>
                <b>Change Company:</b><br />
                <asp:DropDownList runat="server" ID="dlChangeCompanyMultiErpId" AutoPostBack="true"
                    OnSelectedIndexChanged="dlChangeCompanyMultiErpId_SelectedIndexChanged" OnDataBound="dlChangeCompanyMultiErpId_DataBound" />
            </td>
        </tr>
        <tr>
            <td>
                <uc10:AMDBanner runat="server" ID="ucAMDBanner" />
            </td>
        </tr>
        <tr>
            <td height="139">
                <asp:HyperLink runat="server" ID="hyDAQ" NavigateUrl="~/DAQ/Default.aspx">
                        <img src="images/DAQ_Your_Way.jpg" width="246" height="138" style="border:0px" />
                </asp:HyperLink></td>
        </tr>
        <tr>
            <td height="10"></td>
        </tr>
        <tr>
            <td height="139">
                <a href="http://adamforum.com/" target="_blank">
                    <img src="images/banner_adm.jpg" width="246" height="138" alt="" /></a> </td>
        </tr>
        <tr>
            <td height="10"></td>
        </tr>
        <tr>
            <td>
                <a href="http://iservicesblog.advantech.eu/IServiceBlog/" target="_blank">
                    <img src="images/promotionbutton1.jpg" /></a> </td>
        </tr>
        </table>
    </div>
    <div class="right">
        <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td>
                    <div class="rightcontant">
                        <div id="slideshow">
                            <table height="330">
                                <tr>
                                    <td valign="top">
                                        <iframe width="450" height="300" src="http://www.youtube.com/embed/FFd3qIWk4HE" frameborder="0" allowfullscreen></iframe>
                                    </td>
                                    <td width="10"></td>
                                    <td valign="top" style="padding-top: 10px">
                                        <a href="http://youtu.be/FFd3qIWk4HE" target="_blank">From Good to Great</a><br />
                                        <br />
                                        For 30 years, "Good to great" has always been Advantech's core philosophy, which
                                        lead us keep growing."Good to Great" is based on the 3-Circle Principle from Jim
                                        Collins' book. Advantech has put it into action by clearly defining Advantech's
                                        particular 3-Circle Principle. Watch the video to know more about Advantech's business
                                        philosophy! </td>
                                </tr>
                            </table>
                            <table height="340">
                                <tr>
                                    <td valign="top">
                                        <iframe width="450" height="300" src="http://www.youtube.com/embed/LyPsdwSN6wQ" frameborder="0" allowfullscreen></iframe>
                                        <%--<object width='450' height='300'>
                                            <param name='movie' value='https://youtube.googleapis.com/v/LyPsdwSN6wQ'></param>
                                            <param name='wmode' value='transparent'></param>
                                            <embed src='https://youtube.googleapis.com/v/LyPsdwSN6wQ' type='application/x-shockwave-flash'
                                                wmode='transparent' width='450' height='300'></embed></object>--%></td>
                                    <td width="10"></td>
                                    <td valign="top" style="padding-top: 5px">
                                        <a href="http://www.youtube.com/watch?v=LyPsdwSN6wQ" target="_blank">Visit Advantech's
                                            headquarter through the video with us.</a><br />
                                        <b>Advantech Mission:</b><br />
                                        <li>Enabling an intelligent Plant through our IoT and Embedded Platforms designed for
                                            system integrators.</li>
                                        <li>Working & Learning Toward a Beautiful Life under our Altruistic
                                                (LITA) Philosophy.</li>
                                        <b>Advantech Values:</b><br />
                                        <li>Customer Partnership and Talent Invigoration</li>
                                        <li>Integrity and Certitude</li>
                                        <li>Focused Leadership</li>
                                    </td>
                                </tr>
                            </table>
                            <table height="330">
                                <tr>
                                    <td valign="top">
                                        <iframe width="450" height="300" src="http://www.youtube.com/embed/hr_htF0_zdI" frameborder="0" allowfullscreen></iframe>
                                        <%--<object width='450' height='300'>
                                            <param name='movie' value='https://youtube.googleapis.com/v/hr_htF0_zdI'></param>
                                            <param name='wmode' value='transparent'></param>
                                            <embed src='https://youtube.googleapis.com/v/hr_htF0_zdI' type='application/x-shockwave-flash'
                                                wmode='transparent' width='450' height='300'></embed></object>--%></td>
                                    <td width="10"></td>
                                    <td valign="top" style="padding-top: 5px">
                                        <a href="http://www.youtube.com/watch?v=hr_htF0_zdI" target="_blank">Progressing the
                                            Advantech Story</a><br />
                                        <br />
                                        Established in 1983, Advantech has grown from a small business to an international
                                        enterprise. In the 30 years, the core spirit and management philosophy of Advantech
                                        Corporation is well presented in this corporate altruistic LITA tree.<br />
                                        <br />
                                        The video illustrates the story of what we have done in the past 30 years and our
                                        vision for the next 30 years. </td>
                                </tr>
                            </table>
                            <div id="nav">
                            </div>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr runat="server" id="tr_banner1">
                <td align="left">
                    <uc10:Banner runat="server" ID="ucBanner" />
                </td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr valign="top">
                <td align="left">
                    <uc9:WCustContent runat="server" ID="WCont1" />
                </td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr>
                <td valign="top" style="height: 200px">
                    <div id="div_myrecentitems" style="width: 100%;">
                        <center>
                            <img src="Images/loading2.gif" alt="Loading..." width="35" height="35" /></center>
                    </div>
                    <script type="text/javascript">
                        function gethtml() {
                            PageMethods.MyRecentOrderItems(
                                function (pagedResult, eleid, methodName) {
                                    document.getElementById('div_myrecentitems').innerHTML = pagedResult;
                                    //setTimeout("GetQuoteDraft();", 100);
                                },
                                function (error, userContext, methodName) {
                                    //alert(error.get_message());
                                    document.getElementById('div_myrecentitems').innerHTML = "";
                                });

                        }
                        gethtml();
                    </script>
                </td>
            </tr>
            <tr valign="top" id="MyLeadsTR" runat="server">
                <td>
                    <uc7:MyLeads runat="server" ID="MyLeads1" />
                </td>
            </tr>
            <tr>
                <td height="10"></td>
            </tr>
            <tr valign="top">
                <td>
                    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                        <ContentTemplate>
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="left" class="h3" height="30">My Backorder </td>
                                </tr>
                                <tr>
                                    <td valign="top">
                                        <asp:Timer runat="server" ID="Timer1" Interval="3500" OnTick="Timer1_Tick" />
                                        <table width="100%" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td align="center">
                                                    <asp:Image runat="server" ID="imgLoading" ImageUrl="~/Images/loading2.gif" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top">
                                                    <asp:GridView runat="server" Width="100%" ID="gv1" AutoGenerateColumns="false" AllowPaging="true"
                                                        EnableTheming="false" AllowSorting="true" PageSize="5" RowStyle-BackColor="#FFFFFF"
                                                        AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc" BorderWidth="1"
                                                        BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" PagerStyle-BackColor="#ffffff"
                                                        OnPageIndexChanging="gv1_PageIndexChanging" OnSorting="gv1_Sorting" OnRowCreated="gv1_RowCreated"
                                                        PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnRowDataBound="gv1_RowDataBound">
                                                        <Columns>
                                                            <asp:BoundField HeaderText="SO No." DataField="ORDERNO" SortExpression="ORDERNO" />
                                                            <asp:BoundField HeaderText="PO No." DataField="PONO" SortExpression="PONO" />
                                                            <asp:BoundField HeaderText="Part No." DataField="PRODUCTID" SortExpression="PRODUCTID" />
                                                            <asp:BoundField HeaderText="Qty." DataField="SCHDLINECONFIRMQTY" SortExpression="SCHDLINECONFIRMQTY"
                                                                ItemStyle-HorizontalAlign="Center" />
                                                            <asp:TemplateField HeaderText="Order Date" SortExpression="ORDERDATE" ItemStyle-HorizontalAlign="Center">
                                                                <ItemTemplate>
                                                                    <%# FDate(Eval("ORDERDATE"))%>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Due Date" SortExpression="DUEDATE" ItemStyle-HorizontalAlign="Center">
                                                                <ItemTemplate>
                                                                    <%# FDate(Eval("DUEDATE"))%>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
