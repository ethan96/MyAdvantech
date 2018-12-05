<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech Product Search for AENC Customers" 
    ValidateRequest="false" EnableEventValidation="false" %>

<script runat="server">

    Function GetSql() As String
        'If txt_Key.Text.Trim = "" Then Return ""
        If Session("org_id") Is Nothing OrElse Session("org_id").ToString() = "" Then Session("org_id") = "US01"
        Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(txt_Key.Text))
        Dim strKey As String = fts.NormalForm.Replace("'", "''")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select * from ( "))
            .AppendLine(String.Format(" SELECT distinct top 500 a.U_ID, ISNULL(b.[rank],0) as score1, case when a.part_no like '%{0}%' then 9999 else 0 end as score2, ", txt_Key.Text.Trim.Replace("'", "''").Replace("*", "%")))
            .AppendLine(String.Format(" case when a.material_group='PRODUCT' then 100 else 0 end as score3, "))
            .AppendLine(String.Format(" a.Part_NO, IsNull(a.TUMBNAIL_IMAGE_ID,'') as TUMBNAIL_IMAGE_ID,  "))
            .AppendLine(String.Format(" a.ROHS_STATUS, a.PRODUCT_DESC, a.FEATURES, IsNull(a.EXTENTED_DESC,'') as EXTENTED_DESC, c.STATUS, a.Model_id, "))
            .AppendLine(String.Format(" a.Model_No, a.CATALOG_ID, a.active_flg, a.CATEGORY_TYPE, a.product_group, "))
            .AppendLine(String.Format(" a.product_division, a.product_line, a.material_group, d.LAST_UPD_DATE "))
            .AppendLine(String.Format(" FROM PRODUCT_FULLTEXT_NEW AS a left join "))
            .AppendLine(String.Format(" ( "))
            .AppendLine(String.Format(" 	SELECT [key], [rank]  "))
            .AppendLine(String.Format(" 	FROM CONTAINSTABLE( "))
            .AppendLine(String.Format(" 			PRODUCT_FULLTEXT_NEW,  "))
            .AppendLine(String.Format(" 			(part_no, Model_no, PRODUCT_DESC,FEATURES,EXTENTED_DESC),  "))
            .AppendLine(String.Format(" 			N'{0}') ", strKey))
            .AppendLine(String.Format(" ) b on a.U_ID=b.[key] "))
            .AppendLine(String.Format(" inner join SAP_PRODUCT_ORG c on a.part_no=c.PART_NO and c.ORG_ID='{0}'  ", Session("org_id")))
            .AppendLine(String.Format(" inner join SAP_PRODUCT d on a.part_no=d.PART_NO inner join MYADVANTECH_PRODUCT_PROMOTION e on a.part_no=e.part_no "))
            .AppendLine(String.Format(" where a.part_no not like 'C-CTOS%' and c.STATUS in {0}  ", ConfigurationManager.AppSettings("CanOrderProdStatus")))
            .AppendLine(String.Format(" and e.RBU='AENC' and a.STATUS is not null and a.material_group not in ('ODM','T','ES','ZSRV','968MS')  "))
            'If Session("RBU") = "AENC" Or Session("RBU") = "AACIAG" Then
            '    Dim tmpOrg As String = ""
            '    If Session("RBU") = "AENC" Then
            '        tmpOrg = "ECG"
            '    Else
            '        tmpOrg = "IA-EX"
            '    End If
            '    .AppendLine(String.Format(" and (a.product_line in " + _
            '                              "         (select distinct product_line from SAP_EAEP_PLINE where PRODUCT_LINE is not null and PRODUCT_LINE<>'' and BIZGRP='{0}') " + _
            '                              "             or a.product_line in (select distinct product_line from SAP_CUST_PLINE_EXCEPTION where COMPANY_ID='{1}')) ", tmpOrg, Session("company_id")))
            'End If
            .AppendLine(String.Format(" order by score2 desc, score3 desc, score1 desc, d.LAST_UPD_DATE desc "))
            .AppendLine(String.Format(" ) as tmp where score1>0 or score2>0 "))
        End With
        'Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "", sb.ToString(), False, "", "")
        Return sb.ToString()
    End Function

    Protected Sub btn_Search_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If dlSearchOption.SelectedIndex = 0 Then
            gv1.PageIndex = 0 : src1.SelectCommand = GetSql()
            'If Not User.IsInRole("Administrator") Or True Then Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "MYPRODSEARCH by " + User.Identity.Name, src1.SelectCommand, False, "", "")
            If User.IsInRole("Administrator") Then
                lbSql.Text = Replace(src1.SelectCommand, vbCrLf, "<br/>")
                lbSql.Visible = True
            End If
            'ViewState("SearchResultPN") = Nothing
            'If Me.txt_Key.Text.Length >= 3 Then Response.Filter = New eBizAEU.HighlighterFilter(Response.Filter, HttpUtility.UrlDecode(Me.txt_Key.Text))
            gv1.EmptyDataText = "No search results were found.<br /> Please try again or submit the feedback form to let us know what you need . "
        Else
            If dlSearchOption.SelectedIndex = 1 Then
                Response.Redirect("/Product/LiteratureSearch.aspx?key=" + Me.txt_Key.Text)
            Else
                If dlSearchOption.SelectedIndex = 2 Then
                    Response.Redirect("/Product/SupportSearch.aspx?key=" + Me.txt_Key.Text)
                End If
            End If
        End If
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
        'If Me.txt_Key.Text.Length >= 3 Then Response.Filter = New eBizAEU.HighlighterFilter(Response.Filter, HttpUtility.UrlDecode(Me.txt_Key.Text))
    End Sub

    Protected Sub gv1_SelectedIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSelectEventArgs)
        src1.SelectCommand = GetSql()
        'If Me.txt_Key.Text.Length >= 3 Then Response.Filter = New eBizAEU.HighlighterFilter(Response.Filter, HttpUtility.UrlDecode(Me.txt_Key.Text))
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If DataBinder.Eval(e.Row.DataItem, "material_group").ToString() = "96SW" Or _
                DataBinder.Eval(e.Row.DataItem, "material_group").ToString() = "968MS" Then
                CType(e.Row.FindControl("RowPriceATPTimer"), Timer).Enabled = False
                e.Row.Visible = False
            Else
                CType(e.Row.FindControl("RowPriceATPTimer"), Timer).Interval = 100 + 20 * e.Row.RowIndex
            End If
        End If

    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
        'If Me.txt_Key.Text.Length >= 3 Then Response.Filter = New eBizAEU.HighlighterFilter(Response.Filter, HttpUtility.UrlDecode(Me.txt_Key.Text))
    End Sub

    Function IsROHSImage(ByVal rohsflag As String) As String
        If rohsflag = "Y" Then
            Return "<img src='/Images/Rohs.jpg' alt='RoHS'/>"
        Else
            Return ""
        End If
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txt_Key.Attributes("autocomplete") = "off"
            If Request("key") IsNot Nothing Then
                Me.txt_Key.Text = HttpUtility.UrlDecode(Request("key"))
            End If
            btn_Search_Click(Nothing, Nothing)
        End If
    End Sub

    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 999999
    End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If gv1.PageIndex = 0 And gv1.Rows.Count = 0 And txt_Key.Text.Trim <> "" Then
            txt_Key.Text = txt_Key.Text.Replace("*", "") + "*"
            src1.SelectCommand = GetSql()
        End If
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPrice(ByVal PartNo As String) As String
        Dim cid As String = ""
        Dim lp As Double = 0, up As Double = 0
        If HttpContext.Current IsNot Nothing AndAlso HttpContext.Current.Session("company_id") IsNot Nothing _
            AndAlso HttpContext.Current.Session("company_id").ToString() <> "EDDEAA01" Then
            cid = HttpContext.Current.Session("company_id").ToString()
            If Util.IsRBUCompanyID(cid) Then cid = "EDDEAA01"
            Dim dt As DataTable = Util.GetEUPrice(cid, HttpContext.Current.Session("org_id"), PartNo, Now)
            If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") = "US$"
                lp = dt.Rows(0).Item("Kzwi1").ToString() : up = dt.Rows(0).Item("Netwr").ToString()
                If up > lp Then lp = up
                If up > 0 Then
                    If up < lp Then
                        Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " <strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                    Else
                        Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                    End If
                End If
            Else
                Return "TBD"
            End If
        Else
            If Util.GetPriceByGradeRef(PartNo, "L0L0L0L0", HttpContext.Current.Session("RBU"), Util.SAPCURRENCY.USD, lp, up) Then
                If up > lp Then lp = up
                If up > 0 Then
                    If up < lp Then
                        Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " <strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                    Else
                        Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                    End If
                End If
            Else
                Return "TBD"
            End If
        End If
        Return "TBD"
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetATP(ByVal PartNo As String) As String
        If HttpContext.Current.Session("org_id") Is Nothing Then HttpContext.Current.Session("org_id") = "USH1"
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        Try
            p1.Connection.Open()
            Dim plant As String = Left(HttpContext.Current.Session("org_id").ToString(), 2) + "H1"
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PartNo, plant, "", "", "", "", "PC", "", 9999, "", "", _
                                          New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            Dim adt As DataTable = atpTb.ToADODataTable()
            Dim retATP As String = "TBD"
            For Each r As DataRow In adt.Rows
                If r.Item(4) > 0 And r.Item(4) < 99999999 Then
                    retATP = CInt(r.Item(4)).ToString() + "pcs available on " + Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
                    Exit For
                    'r2.Item("plant") = plant
                    'r2.Item("atp_date") = Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
                    'r2.Item("atp_qty") = CDbl(r.Item(4))
                End If
            Next
            p1.Connection.Close()
            Return retATP
        Catch ex As Exception
            p1.Connection.Close() : Return "TBD"
        End Try
    End Function

    Public Function GetThumbnailImg(ByVal TID As String, ByVal modelno As String) As String
        If TID.Trim() = "" Then Return ""
        Return String.Format("<img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id={0}' alt='{1}' style='height:220px;width:220px;border-width:0px;' />", TID, modelno)
    End Function

    Protected Sub hlMM_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim h As HyperLink = CType(sender, HyperLink)
        'h.NavigateUrl = "/Product/Model_Detail.aspx?model_no=" + gv1.DataKeys(CType((h.NamingContainer), GridViewRow).RowIndex).Values("model_no").ToString
        Dim part_no As String = gv1.DataKeys(CType((h.NamingContainer), GridViewRow).RowIndex).Values("part_no").ToString
        Dim model_no As String = gv1.DataKeys(CType((h.NamingContainer), GridViewRow).RowIndex).Values("model_no").ToString
        h.Attributes.Add("onclick", "GetMM('" + part_no + "', '" + model_no + "',document.getElementById('MM_" + part_no + "'));")
    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetMM(ByVal PartNo As String, ByVal ModelNo As String) As String
        Dim returnHtml As String = "<table width='100%'><tr><td align='left'><a href='javascript:void(0);' onclick='HideFlyout(""" + PartNo + """);'>Close</a></td></tr></table>"
        returnHtml += "<div id='content' style='width:600px;height:300px'>"
        returnHtml += "<div class='tab' title='Marketing Material' style='font-weight:bold;'>"
        returnHtml += "<a id='" + PartNo + "_h0' href='javascript:void(0);' onclick='ClickTab(""0"",""" + PartNo + """)' style='font-weight:bold'>Literature</a>"
        returnHtml += "</div>"
        returnHtml += "<div class='tab'><a id='" + PartNo + "_h1' href='javascript:void(0);' onclick='ClickTab(""1"",""" + PartNo + """)'>Download</a></div>"
        returnHtml += "<div class='tab'><a id='" + PartNo + "_h2' href='javascript:void(0);' onclick='ClickTab(""2"",""" + PartNo + """)'>FAQ</a></div>"
        returnHtml += "<div class='boxholder' id='" + PartNo + "_boxgroup'>"
        returnHtml += "<div class='box' id='" + PartNo + "_box0' style='display: block'>" + GetLit(ModelNo, PartNo) + "</div>"
        returnHtml += "<div class='box' id='" + PartNo + "_box1' style='display: none'>" + GetDownload(ModelNo) + "</div>"
        returnHtml += "<div class='box' id='" + PartNo + "_box2' style='display: none'>" + GetFAQ(ModelNo) + "</div>"
        returnHtml += "</div>"
        returnHtml += "</div>"
        Return returnHtml
    End Function

    Public Shared Function GetLit(ByVal ModelNo As String, ByVal PartNo As String) As String
        Dim LitTb As New StringBuilder
        Dim IMG_Dt As DataTable = _
            dbUtil.dbGetDataTable("MY", _
            " Select a.PRODUCT_ID from SIEBEL_PRODUCT a left join SIEBEL_PRODUCT_LANG b on a.PRODUCT_ID = b.PRODUCT_ID " & _
            " WHERE PART_NO = '" & ModelNo & "' ")
        Dim Product_ID As String = ""
        If IMG_Dt.Rows.Count > 0 Then
            Product_ID = IMG_Dt.Rows(0).Item(0).ToString
        End If
        Dim dt As New DataTable
        If Product_ID <> "" And Not IsNothing(Product_ID) Then
            Dim strSql As String = _
            " select A.LITERATURE_ID, LIT_TYPE as Literature_Type, isnull(FILE_NAME,'') as Name, isnull(LIT_DESC,'') as Description, " + _
            " FILE_EXT as File_Type, FILE_SIZE as File_Size " + _
            " from siebel_product_literature a, literature b " + _
            " where product_id = '" + Product_ID + "' " + _
            " and a.literature_id = b.literature_id " + _
            " and b.lit_type not in ('roadmap','sales kits') " + _
            " and b.PRIMARY_LEVEL <> 'RBU' " + _
            " and PRIMARY_ORG_ID ='ACL' " + _
            " and b.LIT_TYPE not in ('Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') " + _
            " order by LIT_TYPE,LAST_UPDATED DESC "
            dt = dbUtil.dbGetDataTable("MY", strSql)
        Else
            Dim strSql As String = "select LIT_ID as LITERATURE_ID, LIT_TYPE as Literature_Type, isnull(FILE_NAME,'') as Name, isnull(PRODUCT_DESC,'') as Description, FILE_EXT as File_Type, FILE_SIZE as File_Size from SIEBEL_LITERATURE where PART_NO ='" + PartNo + "'"
            dt = dbUtil.dbGetDataTable("MY", strSql)
        End If
        If dt.Rows.Count > 0 Then
            LitTb.AppendFormat("<table width='590px'>")
            LitTb.AppendFormat("<tr><th>Literature Type</th><th>Name</th><th>File Type</th><th>File Size</th></tr>")
            For Each row As DataRow In dt.Rows
                Dim file_size As String = ""
                If row.Item("file_size").ToString <> "&nbsp;" Then
                    file_size = FormatNumber(CDbl(row.Item("file_size").ToString) / 1024, 0, , , -2) + "k"
                Else
                    file_size = row.Item("file_size").ToString
                End If
                LitTb.AppendFormat("<tr><td>{0}</td><td><a target='_blank' href='/Product/Unzip_File.aspx?Literature_Id={4}&Part_NO={5}'>{1}</a></td><td>{2}</td><td>{3}</td></tr>", row.Item("literature_type").ToString, row.Item("name").ToString, row.Item("file_type").ToString, file_size, row.Item("literature_id").ToString, ModelNo)
            Next
            LitTb.AppendFormat("</table>")
        End If
        Return LitTb.ToString
    End Function

    Public Shared Function GetDownload(ByVal ModelNo As String) As String
        Dim DownloadTb As New StringBuilder
        Dim strSql As String = _
        " SELECT DISTINCT C_NO='', B.ABSTRACT as Description, A.SR_ID, SEARCH_TYPE as Type, SR_TYPE, UPDATED_DATE as [Date], " & _
        " TOT=" + _
        " (SELECT COUNT(*) FROM SIEBEL_SR_SOLUTION_RELATION X, SIEBEL_SR_SOLUTION_FILE_RELATION Y, SIEBEL_SR_SOLUTION_FILE Z " & _
        " WHERE X.SR_ID=A.SR_ID AND X.SOLUTION_ID=Y.SOLUTION_ID AND Y.FILE_ID=Z.FILE_ID AND Z.PUBLISH_FLAG='Y') " & _
        " FROM SIEBEL_SR_PRODUCT A, SIEBEL_SR_DOWNLOAD B " & _
        " WHERE A.PART_NO LIKE '%" & ModelNo & "%' AND A.SR_ID=B.SR_ID AND B.PUBLISH_SCOPE='External' AND SR_TYPE='Download' AND B.ABSTRACT<>'' " & _
        " AND B.ABSTRACT IS NOT NULL ORDER BY SEARCH_TYPE "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
        If dt.Rows.Count > 0 Then
            DownloadTb.AppendFormat("<table width='590px'>")
            DownloadTb.AppendFormat("<tr><th>Description</th><th>Type</th><th>Date</th></tr>")
            For Each row As DataRow In dt.Rows
                Dim sdate As String = ""
                If IsDate(row.Item("date")) Then
                    sdate = CDate(row.Item("date")).ToString("yyyy/MM/dd")
                Else
                    sdate = row.Item("date").ToString
                End If
                DownloadTb.AppendFormat("<tr><td><a target='_blank' href='/Product/SR_Download.aspx?SR_ID={3}&Part_NO={4}'>{0}</a></td><td>{1}</td><td>{2}</td></tr>", row.Item("description").ToString, row.Item("type").ToString, sdate, row.Item("sr_id").ToString, ModelNo)
            Next
            DownloadTb.AppendFormat("</table>")
        End If
        Return DownloadTb.ToString
    End Function

    Public Shared Function GetFAQ(ByVal ModelNo As String) As String
        Dim FAQTb As New StringBuilder
        Dim strSql As String = _
        " SELECT DISTINCT C_NO='', B.ABSTRACT as Question, A.SR_ID, SEARCH_TYPE, SR_TYPE, UPDATED_DATE as [Date] " & _
        " FROM SIEBEL_SR_PRODUCT A, SIEBEL_SR_DOWNLOAD B, SIEBEL_SR_SOLUTION_RELATION C, SIEBEL_SR_SOLUTION D " & _
        " WHERE A.PART_NO LIKE '%" & ModelNo & "%' AND A.SR_ID = B.SR_ID AND B.PUBLISH_SCOPE like 'External%'" & _
        " AND SR_TYPE = 'Knowledge Base' AND SEARCH_TYPE='FAQ' AND B.ABSTRACT <> '' " & _
        " AND B.ABSTRACT IS NOT NULL AND B.SR_ID = C.SR_ID AND C.SOLUTION_ID = D.SR_ID " & _
        " AND D.PUBLISH_FLG = 'Y' ORDER BY B.ABSTRACT "

        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
        If dt.Rows.Count > 0 Then
            FAQTb.AppendFormat("<table width='590px'>")
            FAQTb.AppendFormat("<tr><th>Question</th><th>Date</th></tr>")
            For Each row As DataRow In dt.Rows
                Dim sdate As String = ""
                If IsDate(row.Item("date")) Then
                    sdate = CDate(row.Item("date")).ToString("yyyy/MM/dd")
                Else
                    sdate = row.Item("date").ToString
                End If
                FAQTb.AppendFormat("<tr><td><a target='_blank' href='/Product/SR_Detail.aspx?SR_ID={2}&Part_No={3}'>{0}</a></td><td>{1}</td></tr>", row.Item("question").ToString, sdate, Replace(row.Item("sr_id").ToString, "+", "%2B"), ModelNo)
            Next
            FAQTb.AppendFormat("</table>")
        End If
        Return FAQTb.ToString
    End Function

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'If Session("RBU") <> "AENC" AndAlso Util.IsInternalUser(Session("user_id")) = False Then
            '    Response.Redirect("ProductSearch.aspx")
            'End If
        End If
    End Sub

    Protected Sub RowPriceATPTimer_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim tmr As Timer = sender
        tmr.Interval = 99999
        Try
            Dim lbATP As Label = tmr.NamingContainer.FindControl("lbRowATP")
            Dim lbPrice As Label = tmr.NamingContainer.FindControl("lbRowPrice")
            Dim tmpPN As String = CType(tmr.NamingContainer.FindControl("lbRowPN"), Label).Text
            Dim tmpPrice As Double = -1
            Dim atp1 As New GlobalATP(tmpPN, "USH1")
            atp1.Query() : tmpPrice = Util.GetSAPPrice(tmpPN, Session("company_id"))
            If atp1.rdt IsNot Nothing AndAlso atp1.rdt.Rows.Count > 0 AndAlso Double.TryParse(atp1.rdt.Rows(0).Item("atp_qty"), 0) Then
                Dim tmpQty As Integer = atp1.rdt.Rows(0).Item("atp_qty")
                If tmpQty > 1 Then
                    lbATP.Text = atp1.rdt.Rows(0).Item("atp_qty").ToString() + "pcs"
                Else
                    lbATP.Text = atp1.rdt.Rows(0).Item("atp_qty").ToString() + "pc"
                End If
            Else
                lbATP.Text = "No Inventory"
            End If
            If tmpPrice > 0 Then
                lbPrice.Text = "$" + tmpPrice.ToString()
            Else
                lbPrice.Text = "Price is TBD"
            End If
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Get AENC price ATP error", ex.ToString(), False, "", "")
        End Try
        CType(tmr.NamingContainer.FindControl("imgRowPriceATPLoad"), Image).Visible = False
        tmr.Enabled = False
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript">
        function ClickTab(Index, PartNo) {
            var child = document.getElementById(PartNo + "_boxgroup").getElementsByTagName("div");
            for (var i = 0; i < child.length; i++) {
                child[i].style.display = "none";
                document.getElementById(PartNo + "_h" + i).style.fontWeight = "normal";
            }
            document.getElementById(PartNo + "_box" + Index).style.display = "block";
            document.getElementById(PartNo + "_h" + Index).style.fontWeight = "bold";
        }
        function GetPrice(PN, PE) {
            PE.innerHTML = "<img style='border:0px;' alt='loading' src='../images/loading2.gif' />";
            PageMethods.GetPrice(PN, OnGetPriceComplete, OnGetPriceError, PE);
            PE.href = '/order/cart_add2cartline.aspx?part_no=' + PN + '&qty=1';
        }
        function OnGetPriceComplete(result, price, methodName) {
            price.innerHTML = result;
        }
        function OnGetPriceError(error, userContext, methodName) {
            if (error !== null) {
                //alert(error.get_message());
            }
        }
        function GetATP(PN, PE) {
            PE.innerHTML = "<img style='border:0px;' alt='loading' src='../images/loading2.gif' />";
            PageMethods.GetATP(PN, OnGetATPComplete, OnGetATPError, PE);
            PE.href = '/Order/QueryATP.aspx?Part_No=' + PN;
            PE.target = '_blank';
        }
        function OnGetATPComplete(result, atp, methodName) {
            //alert(atp.innerHTML);
            atp.innerHTML = result;
        }
        function OnGetATPError(error, userContext, methodName) {
            if (error !== null) {
                alert(error.get_message());
            }
        }
        function GetMM(PN, MN, PE) {
            document.getElementById("div_" + PN).style.display = "block";
            PE.innerHTML = "<table width='100%'><tr><td align='left'><a href='javascript:void(0);' onclick='HideFlyout('" + PN + "');'>Close</a></td></tr><tr><td><img style='border:0px;' alt='loading' src='../images/loading2.gif' />Loading</td></tr></table>";
            PageMethods.GetMM(PN, MN, OnGetPriceComplete, OnGetPriceError, PE);
        }
        function OnGetMMComplete(result, mm, methodName) {
            mm.innerHTML = result;
        }
        function OnGetMMError(error, userContext, methodName) {
            if (error !== null) {
                //alert(error.get_message());
            }
        }
        function HideFlyout(PartNo) { document.getElementById("div_" + PartNo).style.display = "none"; }
        function KeySelected(source, eventArgs) {
            //alert(" Key : " + eventArgs.get_text() + " Value : " + eventArgs.get_value());
            document.getElementById('<%=txt_Key.ClientID %>').value = eventArgs.get_text();
        }
    </script>    
    <table width="100%">
        <tr>
            <td align="right">
                
            </td>
        </tr>
        <tr>
            <td align="center">
                <table cellpadding="0" cellspacing="0" border="0">
                    <tr align="center">
                        <td><img src="../Images/newlogo.gif" alt="" width="140" height="52" /></td>
                    </tr>                    
                    <tr align="center">
                        <td valign="middle">
                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" OnClientItemSelected="KeySelected"                                            
                                ServiceMethod="GetSearchSuggestionKeys" TargetControlID="txt_Key" ServicePath="~/Services/AutoComplete.asmx" 
                                MinimumPrefixLength="1" FirstRowSelected="true" />
                            <asp:Panel runat="server" ID="PanelQueryBtn" DefaultButton="btn_Search">
                                <asp:TextBox Height="16" ID="txt_Key" runat="server" Width="350" />
                            </asp:Panel>                            
                        </td>
                    </tr>
                    <tr style="height:2px">
                        <td></td>
                    </tr>
                    <tr align="center">
                        <td colspan="1" valign="middle">                            
                            <asp:ImageButton ID="btn_Search" runat="server" AlternateText="Search" ImageUrl="~/Images/newgo.gif" OnClick="btn_Search_Click" />                            
                        </td>
                    </tr>                    
                    <tr align="center" style="display:none">
                        <td colspan="1" valign="middle">
                            <asp:RadioButtonList Height="20" ID="dlSearchOption" runat="server" RepeatDirection="Horizontal" RepeatColumns="3">
                                <asp:ListItem Value="Product" Selected="True" />
                                <asp:ListItem Value="Literature" Text="Marketing material" />
                                <asp:ListItem Value="Support" />
                            </asp:RadioButtonList> 
                        </td>
                    </tr>                    
                </table>
            </td>
        </tr>
        <tr>
            <td>       
                <asp:GridView runat="server" ID="gv1" Width="98%" AutoGenerateColumns="false" ShowHeader="false" 
                    AllowPaging="true" AllowSorting="true" PageSize="10" DataSourceID="src1" PagerSettings-Position="TopAndBottom" 
                    OnPageIndexChanging="gv1_PageIndexChanging" OnSelectedIndexChanging="gv1_SelectedIndexChanging" BorderWidth="1px" 
                    OnRowDataBound="gv1_RowDataBound" OnSorting="gv1_Sorting" OnDataBound="gv1_DataBound" DataKeyNames="model_no,part_no">
                    <RowStyle BorderWidth="0px" />
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-ForeColor="#636563" 
                            ItemStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Top">
                            <headertemplate>
                                No.
                            </headertemplate>
                            <itemtemplate>
                                <%# Container.DataItemIndex + 1 %>.
                            </itemtemplate>
                        </asp:TemplateField>                         
                        <asp:TemplateField>
                            <ItemTemplate>
                                <%#GetThumbnailImg(Eval("TUMBNAIL_IMAGE_ID"), Eval("MODEL_NO"))%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description" SortExpression="model_no" ItemStyle-Width="100%" ItemStyle-VerticalAlign="Top">
                            <ItemTemplate>
                                <table width="100%">
                                    <tr>                                                
                                        <td>
                                            <b>
                                                <a style="font-size:14px" target="_blank" 
                                                    href='/Product/Model_Detail.aspx?model_no=<%#Eval("model_no") %>' 
                                                    onclick="this.style.color='#9c6531'">
                                                    <img src="../Images/arrow_l.gif" alt="" style="border:0px" width="12" height="16" />
                                                    <%# Util.Highlight(Me.txt_Key.Text, Eval("part_no"))%>
                                                </a>  
                                                <asp:Label runat="server" ID="lbRowPN" Text='<%#Eval("part_no") %>' Visible="false" />
                                            </b>
                                            <%#IsROHSImage(Eval("ROHS_STATUS"))%>
                                            &nbsp;
                                            <div style="font-size:11px; display:inline;"><%# Util.Highlight(Me.txt_Key.Text, Eval("PRODUCT_DESC"))%></div>                                                     
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top">
                                            <table width="90%">
                                                <td style="background-color:#EFF7FF;">
                                                    <%# Util.Highlight(Me.txt_Key.Text, Eval("EXTENTED_DESC"))%>
                                                </td>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>                                            
                                            <a href='/order/cart_add2cartline.aspx?part_no=<%#Eval("part_no") %>&qty=1'><img alt="add2cart" src="../Images/add2cart_yellow_en.gif" style="border:0px; width:100px" /></a>                                                                                                                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table>
                                                <tr>
                                                    <td width="200px">
                                                        <asp:UpdatePanel runat="server" ID="upRowPriceATP" UpdateMode="Conditional">
                                                            <ContentTemplate>
                                                                <asp:Timer runat="server" ID="RowPriceATPTimer" Interval="100" OnTick="RowPriceATPTimer_Tick" />                                                                
                                                                <table>
                                                                    <tr>
                                                                        <th align="left">Price:</th>
                                                                        <th align="left">
                                                                            <asp:Image runat="server" ID="imgRowPriceATPLoad" ImageUrl="~/Images/loading2.gif" />
                                                                            <asp:Label runat="server" ID="lbRowPrice" Font-Bold="true" />
                                                                        </th>
                                                                    </tr>                                                                   
                                                                    <tr>
                                                                        <th>Inventory:</th>
                                                                        <th><asp:Label runat="server" ID="lbRowATP" Font-Bold="true" /></th>
                                                                    </tr>
                                                                </table>
                                                            </ContentTemplate>                                                            
                                                        </asp:UpdatePanel>
                                                    </td>
                                                    <td>
                                                        <asp:HyperLink runat="server" ID="hlMM" NavigateUrl="javascript:void(0);" Text="Marketing Material" OnDataBinding="hlMM_DataBinding" />
                                                        <div id="div_<%#Eval("part_no") %>" style="display:none; position:absolute">
                                                             <div id='MM_<%#Eval("part_no") %>' style="background-color:white;border: solid 1px silver;padding:10px; width:650px; height:300px;overflow:auto;">
                                                                    
                                                             </div>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table>
                                                <tr valign="top">
                                                    <td style="width:5px">&nbsp;</td>
                                                    <td>
                                                        <%#Eval("FEATURES")%>
                                                    </td>
                                                </tr>
                                            </table>
                                            
                                        </td>
                                    </tr>
                                </table>
                            </ItemTemplate>
                        </asp:TemplateField>    
                    </Columns>
                    <%--<FixRowColumn FixColumns="-1" FixRows="-1" TableHeight="500px" TableWidth="99%" />--%>
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src1_Selecting" />                
            </td>
        </tr>
    </table>
    <asp:Label runat="server" ID="lbSql" Width="90%" ForeColor="LightGray" />  
</asp:Content>

