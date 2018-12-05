<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech Product Search" 
    ValidateRequest="false" EnableEventValidation="false" %>

<script runat="server">

    'Public Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
    '    If Search_Str <> String.Empty AndAlso Search_Str.Trim <> "" AndAlso Search_Str <> "*" Then

    '        Dim _ortSearch_Str As String = Search_Str

    '        'Frank 2012/04/26:Fixed error ==>"{0,}fpm{0,}3191" - Quantifier {x,y} following nothing.
    '        'Search_Str = Replace(Search_Str, "*", "{0,}")
    '        Search_Str = Replace(Search_Str, "*", " ")
    '        Try
    '            Dim RegExp As New Regex(Search_Str.Replace(" ", "|").Trim(), RegexOptions.IgnoreCase)
    '            Return RegExp.Replace(InputTxt, New MatchEvaluator(AddressOf ReplaceKeyWords))
    '            RegExp = Nothing
    '        Catch ex As System.ArgumentException
    '            Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))

    '            'subject string can not contain new line character
    '            'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "Highlight error for search:" + Search_Str + ". inputTxt:" + InputTxt, ex.ToString())
    '            Dim _subject As String = "Highlight error for search:" + _ortSearch_Str + ". inputTxt:" + InputTxt
    '            _subject = _subject.Replace(vbNewLine, "")
    '            sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", _subject, ex.ToString())
    '            'sm.Send("tc.chen@advantech.com.tw", "frank.chung@advantech.com.tw", _subject, ex.ToString())
    '        End Try
    '    End If
    '    Return ""
    'End Function

    'Public Function ReplaceKeyWords(ByVal m As Match) As String
    '    Return "<span style='background-color:Yellow'>" + m.Value + "</span>"
    'End Function

    Function GetSql() As String
        If txt_Key.Text.Trim = "" Then Return ""
        If Session("org_id") Is Nothing OrElse Session("org_id").ToString() = "" Then Session("org_id") = "EU10"
        If Session("company_id") Is Nothing Then Session("company_id") = ""
        Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(txt_Key.Text))
        Dim strKey As String = fts.NormalForm.Replace("'", "''").Replace("*", "%")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select * from ( "))
            .AppendLine(String.Format(" SELECT distinct top 500 a.U_ID, ISNULL(b.[rank],0) as score1, case when a.part_no like '%{0}%' then 9999 else 0 end as score2, ", txt_Key.Text.Trim.Replace("'", "''").Replace("*", "%")))
            .AppendLine(String.Format(" case when a.material_group='PRODUCT' then 100 else 0 end as score3, "))
            .AppendLine(String.Format(" isnull(a.Part_NO,'') as Part_NO, isnull((select top 1 z.literature_id from [PIS].dbo.model_lit z left join [PIS].dbo.LITERATURE z1 on z.literature_id=z1.LITERATURE_ID where z1.LIT_TYPE in ('Product - Photo(Main)','Product - Photo(B)','Product - Photo(S)') and z.model_name=a.Model_No),'') as TUMBNAIL_IMAGE_ID, "))
            'Frank 2012/05/14: Do not display semi-finished products if product under DLGR product line
            '.AppendLine(String.Format(" isnull(a.ROHS_STATUS,'') as ROHS_STATUS, isnull(a.PRODUCT_DESC,'') as PRODUCT_DESC, isnull(a.FEATURES,'') as FEATURES, IsNull(a.EXTENTED_DESC,'') as EXTENTED_DESC, isnull(c.STATUS,'') as STATUS, isnull(a.Model_id,'') as Model_id, "))
            .AppendLine(String.Format(" isnull(a.ROHS_STATUS,'') as ROHS_STATUS, isnull(a.PRODUCT_DESC,'') as PRODUCT_DESC, isnull(a.FEATURES,'') as FEATURES, IsNull(a.EXTENTED_DESC,'') as EXTENTED_DESC, isnull(c.PRODUCT_STATUS,'') as STATUS, isnull(a.Model_id,'') as Model_id, "))
            .AppendLine(String.Format(" isnull(a.Model_No,'') as Model_No, isnull(a.CATALOG_ID,'') as CATALOG_ID, isnull(a.active_flg,'') as active_flg, isnull(a.CATEGORY_TYPE,'') as CATEGORY_TYPE, isnull(a.product_group,'') as product_group, "))
            .AppendLine(String.Format(" isnull(a.product_division,'') as product_division, isnull(a.product_line,'') as product_line, isnull(a.material_group,'') as material_group, d.LAST_UPD_DATE "))
            .AppendLine(String.Format(" FROM PRODUCT_FULLTEXT_NEW AS a left join "))
            .AppendLine(String.Format(" ( "))
            .AppendLine(String.Format(" 	SELECT [key], [rank]  "))
            .AppendLine(String.Format(" 	FROM CONTAINSTABLE( "))
            .AppendLine(String.Format(" 			PRODUCT_FULLTEXT_NEW,  "))
            .AppendLine(String.Format(" 			(part_no, Model_no, PRODUCT_DESC,FEATURES,EXTENTED_DESC),  "))
            .AppendLine(String.Format(" 			N'{0}') ", strKey))
            .AppendLine(String.Format(" ) b on a.U_ID=b.[key] "))
            'Frank 2012/05/14: Do not display semi-finished products if product under DLGR product line
            '.AppendLine(String.Format(" inner join SAP_PRODUCT_ORG c on a.part_no=c.PART_NO and c.ORG_ID='{0}'  ", Session("org_id")))
            .AppendLine(String.Format(" inner join SAP_PRODUCT_STATUS_ORDERABLE c on a.part_no=c.PART_NO and c.SALES_ORG='{0}'  ", Session("org_id")))
            .AppendLine(String.Format(" inner join SAP_PRODUCT d on a.part_no=d.PART_NO "))

            'Ryan 20160727 Block non-internal users viewing T/P indicator items
            If Not Util.IsInternalUser(Session("user_id")) Then
                .AppendLine(String.Format(" left join SAP_PRODUCT_ABC e on c.PART_NO=e.PART_NO and c.DLV_PLANT=e.PLANT "))
            End If

            'Frank 2012/05/14: Do not display semi-finished products if product under DLGR product line
            '.AppendLine(String.Format(" where a.part_no not like 'C-CTOS%' and c.STATUS in {0}  ", ConfigurationManager.AppSettings("CanOrderProdStatus")))
            .AppendLine(String.Format(" where a.part_no not like 'C-CTOS%' and c.PRODUCT_STATUS in {0}  ", ConfigurationManager.AppSettings("CanOrderProdStatus")))

            'Ryan 20160727 Block non-internal users viewing T/P indicator items
            'Frank 2012/01/09: Do not display products that under DLGR product line if not internal user.
            'Ryan 20160418 If is not internal user, X/Y parts are not visible.
            If Not Util.IsInternalUser(Session("user_id")) Then
                .AppendLine(String.Format(" and a.product_line != 'DLGR' and left(a.PART_NO,1) not in ('X','Y') "))
                'Ryan 20160727 Block non-internal users viewing T/P indicator items
                .AppendLine(String.Format(" and e.ABC_INDICATOR not in ('T','P') "))
                'Ryan 20171214 External users invalid material group settings here
                .AppendLine(String.Format(" and a.STATUS is not null and a.material_group not in ('ODM','ODM-P','T','ES','ZSRV','968MS','96SW','206') and d.PRODUCT_HIERARCHY!='EAPC-INNO-DPX' "))
            End If

            'Ryan 20160419 If current ERPID is defined in ZTSD_106C, then can't see 968T parts.
            If Not Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(Session("company_id").ToString()) Then
                .AppendLine(String.Format(" and a.PART_NO not like '968T%' "))
            End If

            .AppendLine(String.Format(" order by score2 desc, score3 desc, score1 desc, d.LAST_UPD_DATE desc "))
            .AppendLine(String.Format(" ) as tmp where score1>0 or score2>0 "))



        End With
        'Util.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "", sb.ToString(), False, "", "")
        'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "", sb.ToString(), True, "", "")
        Return sb.ToString()
    End Function

    Protected Sub btn_Search_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If dlSearchOption.SelectedIndex = 0 Then
            Try
                dbUtil.dbExecuteNoQuery("My", String.Format("insert into user_query_log (userid,keyword,ip,type) values ('{0}','{1}','{2}','{3}')", Session("user_id"), txt_Key.Text.Trim.Replace("'", "''"), Request.ServerVariables("REMOTE_ADDR"), "Product"))
            Catch ex As Exception

            End Try
            gv1.PageIndex = 0 : src1.SelectCommand = GetSql()

            gv1.EmptyDataText = "No search results were found.<br /> Please try again or submit the feedback form to let us know what you need . "
        Else
            If dlSearchOption.SelectedIndex = 1 Then
                Response.Redirect("/Product/MaterialSearch.aspx?key=" + Me.txt_Key.Text)
            End If
            If dlSearchOption.SelectedIndex = 2 Then
                Response.Redirect("/Product/AdvWebSearch.aspx?key=" + Me.txt_Key.Text)
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

            'Frank 2012/03/01
            'If model_no of current binding row is missing then getting model list that relate to this part_no by PIS
            If DataBinder.Eval(e.Row.DataItem, "model_no").ToString.Trim = "" Then


                Dim _dt As DataTable = PISDAL.GetModelByPartNo(DataBinder.Eval(e.Row.DataItem, "part_no").ToString())
                If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                    'If it can get model list then combine first model_name in NavigateUrl
                    Dim _newurl As String = CType(e.Row.Cells(2).FindControl("Model_Link"), HyperLink).NavigateUrl.Trim
                    CType(e.Row.Cells(2).FindControl("Model_Link"), HyperLink).NavigateUrl = _newurl & _dt.Rows(0).Item("model_name")
                Else
                    'If it can not get model list then disable Model_Link object
                    'CType(e.Row.Cells(2).FindControl("Model_Link"), HyperLink).NavigateUrl = ""
                    CType(e.Row.Cells(2).FindControl("Model_Link"), HyperLink).Enabled = False
                    'CType(e.Row.Cells(2).FindControl("Model_Link"), HyperLink).CssClass = ""
                    'CType(e.Row.Cells(2).FindControl("Label_Model_Link"), Label).Enabled = False
                    'CType(e.Row.Cells(2).FindControl("Label_Model_Link"), Label).CssClass = ""

                End If

                _dt = Nothing

            End If



            Dim upm As AuthUtil.UserPermission = AuthUtil.GetPermissionByUser()
            e.Row.Cells(2).FindControl("tdPrice").Visible = upm.CanSeeUnitPrice
            e.Row.Cells(2).FindControl("trToCart").Visible = upm.CanPlaceOrder
            If Session("company_id") = "" Then
                e.Row.Cells(2).FindControl("tdATP").Visible = False
            End If

            'Frank 20160421 Cannot add any items to BTOS cart
            If Session("CART_ID") IsNot Nothing AndAlso MyCartX.IsEUBtosCart(Session("CART_ID")) Then
                e.Row.Cells(2).FindControl("trToCart").Visible = False
            End If

            If DataBinder.Eval(e.Row.DataItem, "material_group").ToString() = "96SW" Or DataBinder.Eval(e.Row.DataItem, "material_group").ToString() = "968MS" Then
                e.Row.Visible = False
            End If

            'Frank 2012/01/09
            'TC建議不要在這處理，會影響到分頁機制
            'If DataBinder.Eval(e.Row.DataItem, "product_line").ToString() = "DLGR" And Util.IsInternalUser(Session("user_id")) = False Then
            'e.Row.Visible = False
            'End If


            '    Dim lbRowPrice As Label = e.Row.FindControl("lbRowPrices")
            '    Dim sb As New System.Text.StringBuilder
            '    With sb
            '        .AppendLine("<Script type='text/javascript'>")
            '        .AppendLine(String.Format("GetPrice('{0}','{1}');", DataBinder.Eval(e.Row.DataItem, "part_no").ToString(), lbRowPrice.ClientID))
            '        .AppendLine("<" + "/Script>")
            '    End With
            '    ClientScript.RegisterClientScriptBlock(GetType(Page), "", sb.ToString())
        End If

    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
        If Me.txt_Key.Text.Length >= 3 Then Response.Filter = New eBizAEU.HighlighterFilter(Response.Filter, HttpUtility.UrlDecode(Me.txt_Key.Text))
    End Sub

    Function IsROHSImage(ByVal rohsflag As String) As String
        If rohsflag = "Y" Then

            'Frank 2012/03/01:Use Util.GetRuntimeSiteUrl to generate url 
            'that can really show the image both on the development site and production site.
            'Return "<img src='/Images/Rohs.jpg' alt='RoHS'/>"
            Return "<img src='" & Util.GetRuntimeSiteUrl() & "/Images/Rohs.jpg' alt='RoHS'/>"
            'Return "<img src='" & Page.Request.ApplicationPath & "/Images/Rohs.jpg' alt='RoHS'/>"

        Else
            Return ""
        End If
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Me.txt_Key.Attributes("autocomplete") = "off"
            If Request("key") IsNot Nothing Then
                Me.txt_Key.Text = HttpUtility.UrlDecode(Request("key")) : btn_Search_Click(Nothing, Nothing)
            End If
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
        'Dim RETPRICEDT As New DataTable
        'SAPtools.getSAPPriceByTable(PartNo, HttpContext.Current.Session("org_id"), HttpContext.Current.Session("company_id"), RETPRICEDT)
        'Dim WSPTb As DataTable = RETPRICEDT
        'Dim lp As Double = 0, up As Double = 0
        'For Each r As DataRow In WSPTb.Rows
        '    up = FormatNumber(r.Item("Netwr"), 2).Replace(",", "")
        '    lp = FormatNumber(r.Item("Kzwi1"), 2).Replace(",", "")
        '    If up > lp Then lp = up
        '    If up > 0 Then
        '        If up < lp Then
        '            Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " <strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
        '        Else
        '            Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
        '        End If

        '    End If
        'Next
        'Return "TBD"

        Dim myprice As New MYSAPDAL, ErrorMessage As String = "", indt As New SAPDALDS.ProductInDataTable, outdt As New SAPDALDS.ProductOutDataTable
        Dim tmpCompanyId As String = HttpContext.Current.Session("company_id"), tmpOrgId As String = HttpContext.Current.Session("org_id"), retFlg As Boolean = False
        'for CN Block MEDC product to show price
        If Not (tmpOrgId.ToUpper.StartsWith("CN") AndAlso SAPDAL.CommonLogic.isMEDC(PartNo) AndAlso Not Util.IsInternalUser2()) Then
            indt.AddProductInRow(PartNo, 1)
        End If

        If tmpCompanyId.Equals("UUAAESC", StringComparison.OrdinalIgnoreCase) Then
            retFlg = myprice.GetListPrice(tmpOrgId, "", "EUR", indt, outdt, ErrorMessage)
        Else
            retFlg = myprice.GetPrice(tmpCompanyId, tmpCompanyId, tmpOrgId, indt, outdt, ErrorMessage)
        End If
        If retFlg AndAlso outdt.Rows.Count > 0 Then
            Dim lp As Double = 0, up As Double = 0, r As SAPDALDS.ProductOutRow = outdt.Rows(0)
            up = FormatNumber(r.UNIT_PRICE, 2).Replace(",", "")
            lp = FormatNumber(r.LIST_PRICE, 2).Replace(",", "")
            If up > lp Then lp = up
            If up > 0 Then
                If up < lp Then
                    Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " <strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                Else
                    Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                End If
            End If
        End If
        Return "TBD"
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetATP(ByVal PartNo As String) As String
        Dim plant As String = Left(HttpContext.Current.Session("org_id").ToString, 2) + "H1"
        Dim dtPartNo As New SAPDAL.SAPDALDS.ProductInDataTable
        dtPartNo.AddProductInRow(PartNo, 0, plant)
        Dim QueryResult As SAPDAL.SAPDALDS.QueryInventory_OutputDataTable = Nothing
        Dim ErrMsg As String = ""
        Dim retATP As String = "TBD"
        Dim mySAP As New SAPDAL.SAPDAL
        If mySAP.QueryInventory(dtPartNo, plant, QueryResult, ErrMsg) Then
            If QueryResult.Rows.Count > 0 Then retATP = CInt(QueryResult.Rows(0).Item("STOCK")).ToString + "pcs available on " + CDate(QueryResult.Rows(0).Item("STOCK_DATE")).ToString("yyyy/MM/dd")
        Else
            Throw New Exception(ErrMsg)
        End If
        Return retATP

        'Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        'p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        'Try
        '    p1.Connection.Open()
        '    Dim plant As String = "EUH1"
        '    If String.Compare(HttpContext.Current.Session("Org_id").ToString, "SG01", True) = 0 Then
        '        plant = "SGH1"
        '    ElseIf String.Compare(HttpContext.Current.Session("Org_id").ToString, "EU10", True) = 0 Or HttpContext.Current.Session("company_id").ToString.StartsWith("E", StringComparison.OrdinalIgnoreCase) Then
        '        plant = "EUH1"
        '    ElseIf String.Compare(HttpContext.Current.Session("Org_id").ToString, "TW01", True) = 0 Then
        '        plant = "TWH1"
        '    Else
        '        plant = OrderUtilities.getPlant()
        '    End If

        '    Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
        '    p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PartNo, plant, "", "", "", "", "PC", "", 9999, "", "", _
        '                                  New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
        '    Dim adt As DataTable = atpTb.ToADODataTable()
        '    Dim retATP As String = "TBD"
        '    For Each r As DataRow In adt.Rows
        '        If r.Item(4) > 0 And r.Item(4) < 99999999 Then
        '            retATP = CInt(r.Item(4)).ToString() + "pcs available on " + Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
        '            Exit For
        '            'r2.Item("plant") = plant
        '            'r2.Item("atp_date") = Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
        '            'r2.Item("atp_qty") = CDbl(r.Item(4))
        '        End If
        '    Next
        '    p1.Connection.Close()
        '    Return retATP
        'Catch ex As Exception
        '    p1.Connection.Close() : Return "TBD"
        'End Try
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

        If String.IsNullOrEmpty(PartNo) Then Return ""

        Dim LitTb As New StringBuilder

        Dim _part As String = PartNo.Replace("'", "''")
        Dim dt As New DataTable
        'Dim strSql As String = String.Format( _
        '   " select a.PART_NO as product_ID, a.LITERATURE_ID, a.LIT_TYPE as Literature_Type, isnull(a.FILE_NAME,'') as Name, isnull(a.LIT_DESC,'') as Description, " + _
        '   " a.FILE_EXT as File_Type, a.FILE_SIZE as File_Size  " + _
        '   " from v_LITERATURE a left join v_CATALOG_CATEGORY_LIT b on a.LITERATURE_ID=b.Literature_ID left join v_CATALOG_CATEGORY c on b.Category_ID=c.CATEGORY_ID where  (CONVERT(nvarchar, a.PART_NO) like N'%{0}%' or c.category_name=(select top 1 z1.model_name from dbo.model_product z1 where z1.part_no='{0}')) " + _
        '   " and a.lit_type not in ('roadmap','sales kits')  " + _
        '   " and a.PRIMARY_LEVEL <> 'RBU'  " + _
        '   " and a.LIT_TYPE not in ('Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') " + _
        '   " order by a.LIT_TYPE,a.LAST_UPDATED DESC ", PartNo)

        'Dim strSql As String = " select a.model_name as product_ID, b.LITERATURE_ID, b.LIT_TYPE as Literature_Type, isnull(b.FILE_NAME,'') as Name, isnull(b.LIT_DESC,'') as Description, " + _
        '   " b.FILE_EXT as File_Type, b.FILE_SIZE as File_Size  " + _
        '   " from Model_lit a left join LITERATURE b on a.LITERATURE_ID=b.Literature_ID" + _
        '   " where  a.model_name='" & ModelNo & "'" + _
        '   " and b.LIT_TYPE not in ('roadmap','sales kits','Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') " + _
        '   " order by b.LIT_TYPE,b.LAST_UPDATED DESC "

        ''Frank 2013/07/29: Get part's literatures base on part number instead of model name
        'Dim strSql As String = " Select a.model_name as product_ID, b.LITERATURE_ID, b.LIT_TYPE as Literature_Type, isnull(b.FILE_NAME,'') as Name, isnull(b.LIT_DESC,'') as Description, " + _
        '   " b.FILE_EXT as File_Type, b.FILE_SIZE as File_Size  " + _
        '   " From model_product c left join Model_lit a on c.model_name=a.model_name " + _
        '   " left join LITERATURE b on a.LITERATURE_ID=b.Literature_ID " + _
        '   " where c.part_no='" & PartNo & "' and c.relation='product' and c.[status]<>'deleted' " + _
        '   " and b.LIT_TYPE not in ('roadmap','sales kits','Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') " + _
        '   " order by b.LIT_TYPE,b.LAST_UPDATED DESC "

        'Frank 2014/03/27: In addition to the relation definition in PIS, also refer to definition in SAP
        Dim strsql As New StringBuilder
        strsql.AppendLine(" Select * from ( ")
        strsql.AppendLine(" Select a.model_name as product_ID, b.LITERATURE_ID, b.LIT_TYPE as Literature_Type, isnull(b.FILE_NAME,'') as Name, isnull(b.LIT_DESC,'') as Description, ")
        strsql.AppendLine(" b.FILE_EXT as File_Type, b.FILE_SIZE as File_Size,b.LAST_UPDATED  ")
        strsql.AppendLine(" From model_product c left join Model_lit a on c.model_name=a.model_name  ")
        strsql.AppendLine(" left join LITERATURE b on a.LITERATURE_ID=b.Literature_ID  ")
        strsql.AppendLine(" where c.part_no='" & _part & "' and c.relation='product' and c.[status]<>'deleted'  ")
        strsql.AppendLine(" and b.LIT_TYPE not in ('roadmap','sales kits','Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') ")
        strsql.AppendLine(" union ")
        strsql.AppendLine(" Select a.model_name as product_ID, b.LITERATURE_ID, b.LIT_TYPE as Literature_Type, isnull(b.FILE_NAME,'') as Name, isnull(b.LIT_DESC,'') as Description, ")
        strsql.AppendLine(" b.FILE_EXT as File_Type, b.FILE_SIZE as File_Size,b.LAST_UPDATED  ")
        strsql.AppendLine(" From MyAdvantechGlobal.dbo.SAP_PRODUCT c left join Model_lit a on c.MODEL_NO=a.model_name  ")
        strsql.AppendLine(" left join LITERATURE b on a.LITERATURE_ID=b.Literature_ID  ")
        strsql.AppendLine(" where c.part_no='" & _part & "'  ")
        strsql.AppendLine(" and b.LIT_TYPE not in ('roadmap','sales kits','Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') ")
        strsql.AppendLine(" ) s ")
        strsql.AppendLine(" group by s.product_ID,s.LITERATURE_ID,s.Literature_Type,s.Name,s.[Description],s.File_Type,s.File_Size,s.LAST_UPDATED ")
        strsql.AppendLine(" order by s.Literature_Type,s.LAST_UPDATED DESC ")


        dt = dbUtil.dbGetDataTable("PIS", strsql.ToString)

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
            'If Session("RBU") = "AENC" Then
            '    Response.Redirect("ProductSearch_AENC.aspx")
            'End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript">
        function ClickTab(Index,PartNo) {
            var child = document.getElementById(PartNo+"_boxgroup").getElementsByTagName("div");
            for (var i=0;i<child.length;i++)  
            {
                child[i].style.display = "none";
                document.getElementById(PartNo + "_h" + i).style.fontWeight = "normal";
            }
            document.getElementById(PartNo + "_box" + Index).style.display = "block";
            document.getElementById(PartNo + "_h" + Index).style.fontWeight = "bold";
        }  
        function GetPrice(PN, PE) { 
            PE.innerHTML="<img style='border:0px;' alt='loading' src='../images/loading2.gif' />";          
            PageMethods.GetPrice(PN, OnGetPriceComplete, OnGetPriceError, PE);  
            PE.href='/order/cart_add2cartline.aspx?part_no='+PN+'&qty=1';         
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
            PE.innerHTML="<img style='border:0px;' alt='loading' src='../images/loading2.gif' />";        
            PageMethods.GetATP(PN, OnGetATPComplete, OnGetATPError, PE);  
            PE.href='/Order/QueryATP.aspx?Part_No='+PN;
            PE.target='_blank';
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
            PE.innerHTML = "<table width='100%'><tr><td align='left'><a href='javascript:void(0);' onclick='HideFlyout('"+PN+"');'>Close</a></td></tr><tr><td><img style='border:0px;' alt='loading' src='../images/loading2.gif' />Loading</td></tr></table>";
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
        function HideFlyout(PartNo) { document.getElementById("div_"+PartNo).style.display = "none"; }
    </script>    
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        > Product Search</div>
    <table width="100%">
        <tr>
            <td align="center">
                <table cellpadding="0" cellspacing="0" border="0">
                    <tr align="center">
                        <td><img src="../Images/newlogo.gif" alt="" width="140" height="52" /></td>
                    </tr>
                    <tr style="height:2px">
                            <td></td>
                        </tr>
                    <tr align="center">
                        <td valign="middle">
                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"                                             
                                ServiceMethod="GetSearchSuggestionKeys" TargetControlID="txt_Key" ServicePath="~/Services/AutoComplete.asmx" 
                                MinimumPrefixLength="1" FirstRowSelected="true" />
                            <asp:Panel runat="server" ID="PanelQueryBtn" DefaultButton="btn_Search">
                                <asp:TextBox Height="16" ID="txt_Key" runat="server" Width="350"/>
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
                    <tr align="center">
                        <td colspan="1" valign="middle">
                            <asp:RadioButtonList Height="20" ID="dlSearchOption" runat="server" RepeatDirection="Horizontal" RepeatColumns="3">
                                <asp:ListItem Value="Product" Selected="True" />
                                <asp:ListItem Value="Literature" Text="Marketing material & Support" />
                                <asp:ListItem Value="Websites" />
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
                    OnPageIndexChanging="gv1_PageIndexChanging" OnSelectedIndexChanging="gv1_SelectedIndexChanging" 
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

                                                <asp:HyperLink ID="Model_Link" runat="server" 
                                                NavigateUrl='<%# Eval("model_no", "~/Product/Model_Detail.aspx?model_no={0}") %>'>
                                                    <asp:Image ID="Image_Model_Link" runat="server" ImageUrl="~/Images/arrow_l.gif" />
                                                    <asp:Label ID="Label_Model_Link" runat="server" Text='<%# Eval("part_no") %>'></asp:Label>
                                                </asp:HyperLink>

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
                                    <tr runat="server" id="trToCart">
                                        <td>                                            
                                            <a href='../order/cart_add2cartline.aspx?part_no=<%#Eval("part_no") %>&qty=1'><img alt="add2cart" src="../Images/add2cart_yellow_en.gif" style="border:0px; width:100px" /></a>                                                                                                                                    
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table>
                                                <tr>
                                                    <td width="70px" runat="server" id="tdPrice"><a href="javascript:GetPrice('<%#Eval("part_no") %>',document.getElementById('lbPrice_<%#Eval("part_no") %>_<%#Container.DataItemIndex.toString() %>'))" id='lbPrice_<%#Eval("part_no") %>_<%#Container.DataItemIndex.toString() %>'>Check Price</a></td>
                                                    <td width="95px" runat="server" id="tdATP"><a id='lbATP_<%#Eval("part_no") %>_<%#Container.DataItemIndex.toString() %>' href="javascript:GetATP('<%#Eval("part_no") %>',document.getElementById('lbATP_<%#Eval("part_no") %>_<%#Container.DataItemIndex.toString() %>'))">Check Availability</a></td>
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

