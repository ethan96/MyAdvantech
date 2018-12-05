<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Model Detail" %>

<script runat="server"> 

    Private _RunTimeURL As String = Util.GetRuntimeSiteUrl
    Private _Category_ID As String = String.Empty

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        'Frank 2012/06/06: To prevent Invalid viewstate exception for firefox browser
        'If user browse this page by firefox, It might occurs below exception when refreshing this page.
        '"System.Web.UI.ViewStateException: Invalid viewstate"
        If Not Page.IsPostBack And Request.Browser.MSDomVersion.Major = 0 Then 'Non IE Browser
            Response.Cache.SetNoStore() 'No client side cashing for non IE browsers
        End If

    End Sub

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Request("model_no") IsNot Nothing AndAlso Request("model_no").ToString().Trim() <> "" Then

                _Category_ID = Trim(Request("Category_ID"))

                If Not String.IsNullOrEmpty(_Category_ID) Then
                    _Category_ID = _Category_ID.Replace("'", "''")
                End If

                Dim _model_no As String = Request("model_no")
                If Not String.IsNullOrEmpty(_model_no) Then
                    _model_no = _model_no.Replace("'", "''")
                End If


                '============Chech Model publish status=========================
                'Frank 2012/02/21
                'If the status is not published then redirect to http://my.advantech.com/Product/Product_Line_New.aspx
                Dim strSql As String = _
                String.Format("Select top 1 Model_name,Active_FLG from Model_Publish (nolock) where model_name='{0}' and Site_ID='ACL'", _model_no)
                Dim _dt_publish As DataTable = dbUtil.dbGetDataTable("PIS", strSql)
                Dim _IsPublishedStatus As Boolean = False
                If _dt_publish IsNot Nothing And _dt_publish.Rows.Count > 0 Then
                    If _dt_publish.Rows(0).Item("Active_FLG").ToString.Equals("Y", StringComparison.InvariantCultureIgnoreCase) Then
                        _IsPublishedStatus = True
                    End If
                End If
                _dt_publish = Nothing
                If Not _IsPublishedStatus Then Response.Redirect("~/Product/Product_Line_New.aspx")
                '==============================================================

                'Dim root As String = MyLog.GetModelRoot(Request("model_no"))
                Dim root As String = MyLog.GetModelRoot(_model_no)
                'MyLog.UpdateLog(Session("user_id"), root, Request("model_no"), MyLog.PageType.ViewProduct.ToString)
                MyLog.UpdateLog(Session("user_id"), root, _model_no, MyLog.PageType.ViewProduct.ToString)

                'Me.hd_Model.Value = HttpUtility.UrlDecode(Trim(Request("model_no"))).ToUpper()
                Me.hd_Model.Value = Trim(_model_no).ToUpper()
                Me.lbModelName.Text = Me.hd_Model.Value

                'Frank 2012/03/14
                'Do not execute this method as thread, because it will make Util.GetRuntimeSiteUrl return nothing
                'FillModelHierarchy is not slow after frank fine tune it.
                Me.FillModelHierarchy()


                'Dim tg As New ArrayList
                'Dim t1 As New Threading.Thread(AddressOf FillModelHierarchy)
                'Dim t2 As New Threading.Thread(AddressOf FillFeatures)
                'Dim t3 As New Threading.Thread(AddressOf FillModelProfile)
                Me.FillFeatures()
                Me.FillModelProfile()
                'Dim t4 As New Threading.Thread(AddressOf FillLiterature)
                'tg.Add(t1) : tg.Add(t2) : tg.Add(t3)
                'tg.Add(t2) : tg.Add(t3)
                'tg.Add(t4)
                'For Each t As Threading.Thread In tg
                '    t.Start()
                'Next
                'For Each t As Threading.Thread In tg
                '    t.Join()
                'Next
                FillLiterature()

                '20180330 TC: Get certificate data from PLM-REP db. This is per AEU Xiaochun's request, and per PLM Cindy and Tomato's help.
                Dim PLMurl As String = String.Format("http://support.advantech.com/support/SearchResult.aspx?keyword={0}&searchtabs=Certificate", hd_Model.Value)
                Dim dtPLMCert = OraDbUtil.dbGetDataTable("PLM-REP",
                    String.Format(" select OBJECT_NUMBER,DOCUMENT_NAME,TEST_ITEM_CERTIFICATION, RELEASE_DATE, '' as URL " +
                     " from addontbl.V_CERTIFICATION_REPORT_COVER " +
                     " where file_name is not null and key_name like '%{0}%' " +
                     " order by OBJECT_NUMBER", Me.hd_Model.Value, PLMurl))
                For Each dr As DataRow In dtPLMCert.Rows
                    dr("URL") = PLMurl
                Next
                dtPLMCert.AcceptChanges()


                'Ryan 20180711 Add certificate cover for download for BBUS
                Try
                    If AuthUtil.IsBBUS Then
                        Dim objWebClient As New System.Net.WebClient
                        Dim Url As String = String.Format("http://apis-corp.advantech.com/api/support/Document?type=Certificate&keyword={0}", hd_Model.Value)
                        Dim JsonStr As String = Encoding.UTF8.GetString(objWebClient.DownloadData(New Uri(Url.Trim())))

                        Dim objJson As Object = Newtonsoft.Json.JsonConvert.DeserializeObject(Of Object)(JsonStr)
                        If objJson IsNot Nothing AndAlso objJson("items") IsNot Nothing AndAlso objJson("items")(0) IsNot Nothing Then
                            Dim objJsonItem As Object = Newtonsoft.Json.JsonConvert.DeserializeObject(Of Object)(objJson("items")(0).ToString)
                            If objJsonItem IsNot Nothing AndAlso
                                objJsonItem("downloadUrl") IsNot Nothing AndAlso Not String.IsNullOrEmpty(objJsonItem("downloadUrl").ToString) _
                                AndAlso objJsonItem("documentId") IsNot Nothing AndAlso Not String.IsNullOrEmpty(objJsonItem("documentId").ToString) _
                                AndAlso objJsonItem("issueDate") IsNot Nothing AndAlso Not String.IsNullOrEmpty(objJsonItem("issueDate").ToString) Then
                                Dim downloadUrl As String = objJsonItem("downloadUrl").ToString
                                Dim documentId As String = objJsonItem("documentId").ToString
                                Dim issueDate As DateTime = Convert.ToDateTime(objJsonItem("issueDate").ToString)

                                Dim dr As DataRow = dtPLMCert.NewRow()
                                dtPLMCert.Clear()
                                dr("OBJECT_NUMBER") = documentId
                                dr("DOCUMENT_NAME") = "Certificate Cover"
                                dr("URL") = downloadUrl
                                dr("TEST_ITEM_CERTIFICATION") = "PDF"
                                dr("RELEASE_DATE") = issueDate.ToString("MM/dd/yyyy")
                                dtPLMCert.Rows.Add(dr)
                            End If
                        End If
                    End If
                Catch ex As Exception

                End Try

                gvCertificate.DataSource = dtPLMCert : gvCertificate.DataBind()

            End If
        End If
    End Sub

    Sub FillOrderInfo()
        Try
            If hd_Model.Value <> "" Then
                Dim strOrg As String = "", strCompId As String = ""
                If Request.IsAuthenticated = False OrElse Session("org_id") Is Nothing OrElse Session("org_id").ToString() = "" Then
                    strOrg = "TW01"
                Else
                    strOrg = Session("org_id")
                End If
                If Request.IsAuthenticated = False OrElse Session("company_id") Is Nothing OrElse Session("company_id").ToString() = "" Then
                    strCompId = ""
                Else
                    strCompId = Session("company_id")
                End If
                'Ryan 20160811 inner join PISBackend.dbo.model_product and check model name from this table
                Dim strSql As String = _
                String.Format( _
                    " select a.PART_NO, a.PRODUCT_DESC, a.ROHS_FLAG, 'TBD' as LP, 'TBD' as UP " + _
                    " from SAP_PRODUCT a with (NOLOCK) inner join SAP_PRODUCT_ORG b with (NOLOCK) on a.PART_NO=b.PART_NO  " + _
                    " inner join SAP_PRODUCT_STATUS_ORDERABLE c on a.PART_NO = c.PART_NO " + _
                    " inner join PISBackend.dbo.model_product d on a.PART_NO = d.part_no " + _
                    " where d.model_name='{0}' and b.ORG_ID='{1}' and a.MATERIAL_GROUP in ('PRODUCT','BTOS') " + _
                    " and a.PART_NO Not Like '%-BTO' and (b.STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + ") and a.PRODUCT_HIERARCHY!='EAPC-INNO-DPX' " + _
                    " and c.SALES_ORG = '{1}' and d.relation = 'product' " + _
                    " order by a.PART_NO  ", Replace(hd_Model.Value, "'", "''"), strOrg) 'ICC Restrict model_product condition for product
                Dim odt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
                'Ryan 20160811 Add double check with old str SQL
                If odt Is Nothing OrElse odt.Rows.Count = 0 Then
                    strSql = String.Format( _
                    " select a.PART_NO, a.PRODUCT_DESC, a.ROHS_FLAG, 'TBD' as LP, 'TBD' as UP " + _
                    " from SAP_PRODUCT a with (NOLOCK) inner join SAP_PRODUCT_ORG b with (NOLOCK) on a.PART_NO=b.PART_NO  " + _
                    " inner join SAP_PRODUCT_STATUS_ORDERABLE c on a.PART_NO = c.PART_NO " + _
                    " where a.MODEL_NO='{0}' and b.ORG_ID='{1}' and a.MATERIAL_GROUP in ('PRODUCT','BTOS') " + _
                    " and a.PART_NO Not Like '%-BTO' and (b.STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + ") and a.PRODUCT_HIERARCHY!='EAPC-INNO-DPX' " + _
                    " and c.SALES_ORG = '{1}' " + _
                    " order by a.PART_NO  ", Replace(hd_Model.Value, "'", "''"), strOrg)
                    odt = dbUtil.dbGetDataTable("MY", strSql)
                End If


                'MailUtil.SendDebugMsg("", strSql)
                If Request.IsAuthenticated Then
                    Dim pdt As DataTable = Util.GetMultiEUPrice(strCompId, strOrg, odt)
                    If pdt IsNot Nothing Then
                        Dim tmpPlant As String = Left(Session("org_id"), 2) + "H1"
                        For Each r As DataRow In odt.Rows
                            Dim part_no As String = ""
                            'for CN Block MEDC product to show price
                            If Not (Session("org_id").ToString.ToUpper.StartsWith("CN") AndAlso SAPDAL.CommonLogic.isMEDC(r.Item("part_no")) AndAlso Not Util.IsInternalUser2()) Then
                                If Global_Inc.Format2SAPItem(Trim(UCase(r.Item("part_no")))) IsNot Nothing Then part_no = Global_Inc.Format2SAPItem(Trim(UCase(r.Item("part_no"))))
                                Dim rs() As DataRow = pdt.Select("Matnr='" + part_no + "'")
                                If rs.Length > 0 Then
                                    If Double.TryParse(rs(0).Item("Netwr"), 0) AndAlso CDbl(rs(0).Item("Netwr")) > 0 Then
                                        r.Item("UP") = rs(0).Item("Netwr").ToString()
                                    End If
                                    If Double.TryParse(rs(0).Item("Kzwi1"), 0) AndAlso CDbl(rs(0).Item("Kzwi1")) > 0 Then
                                        r.Item("LP") = rs(0).Item("Kzwi1").ToString()
                                        If Double.TryParse(r.Item("UP"), 0) AndAlso CDbl(r.Item("UP")) > CDbl(r.Item("LP")) Then
                                            r.Item("UP") = r.Item("LP")
                                        End If
                                    End If
                                    If Double.TryParse(r.Item("UP"), 0) Then
                                        If Session("company_id") Is Nothing OrElse Session("company_id").ToString() = "" Then
                                            r.Item("UP") = r.Item("LP")
                                        End If
                                        r.Item("UP") = HttpUtility.HtmlDecode(Util.FormatMoney(r.Item("UP"), rs(0).Item("Waerk")))
                                    End If
                                    If Double.TryParse(r.Item("LP"), 0) Then
                                        r.Item("LP") = HttpUtility.HtmlDecode(Util.FormatMoney(r.Item("LP"), rs(0).Item("Waerk")))
                                    End If
                                End If
                            End If
                            'Dim tmpDate As Date = DateAdd(DateInterval.Month, 2, Now), tmpQty As Integer = 0
                            'Dim atpDt As DataTable = Util.GetSAPCompleteATPByOrg(r.Item("part_no"), 9999, tmpPlant, "")
                            'If atpDt IsNot Nothing AndAlso atpDt.Rows.Count > 0 AndAlso atpDt.Rows(0).Item("Com_Qty") > 0 Then
                            '    r.Item("ATP") = CInt(atpDt.Rows(0).Item("Com_Qty")).ToString()
                            'End If
                        Next
                    End If

                Else
                    Dim columncount As Integer = gvModelOrderInfo.Columns.Count
                    'For anonymous user hide price/atp/add2cart
                    'For i As Integer = 3 To 6
                    If columncount - 1 > 3 Then
                        For i As Integer = 3 To columncount - 1
                            gvModelOrderInfo.Columns(i).Visible = False
                        Next
                    End If
                End If

                If Session("company_id") Is Nothing OrElse Session("company_id").ToString() = "" Then

                End If
                gvModelOrderInfo.DataSource = odt : gvModelOrderInfo.DataBind()
                'pGV.DataSource = pdt : pGV.DataBind()
            End If
        Catch ex As Exception
            'Throw New Exception("Model_Detail.aspx Fill Order Info Failed error:" + ex.ToString())
            Util.InsertMyErrLog("Model_Detail.aspx Fill Order Info Failed error:" + ex.ToString)
        End Try

    End Sub
    Sub FillModelHierarchy()
        If hd_Model.Value <> "" Then
            Try

                ''Frank 2012/03/06:Add level 6 category column
                ''Dim mdt As DataTable = dbUtil.dbGetDataTable("MY", _
                ''                                         String.Format( _
                ''                                         " SELECT model_no, parent_category_id1, category_name1, category_type1,  " + _
                ''                                         " parent_category_id2, category_name2, category_type2, parent_category_id3,  " + _
                ''                                         " category_name3, category_type3, parent_category_id4, category_name4, category_type4,  " + _
                ''                                         " parent_category_id5, category_name5, category_type5, parent_category_id6, '' as category_type6 " + _
                ''                                         " FROM PIS_MODEL_HIERARCHY " + _
                ''                                         " WHERE model_no = '{0}' ", Replace(hd_Model.Value, "'", "''")))
                'Dim mdt As DataTable = dbUtil.dbGetDataTable("PIS", _
                '                         String.Format( _
                '                         " SELECT model_no, parent_category_id1, category_name1, category_type1,  " + _
                '                         " parent_category_id2, category_name2, category_type2, parent_category_id3,  " + _
                '                         " category_name3, category_type3, parent_category_id4, category_name4, category_type4,  " + _
                '                         " parent_category_id5, category_name5, category_type5, parent_category_id6, category_name6, category_type6 " + _
                '                         " FROM CATEGORY_HIERARCHY " + _
                '                         " WHERE model_no = '{0}' ", Replace(hd_Model.Value, "'", "''")))


                'If mdt.Rows.Count > 0 Then
                '    Dim mAry As New ArrayList
                '    With mdt.Rows(0)
                '        For i As Integer = 1 To 6
                '            If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value AndAlso .Item("parent_category_id" + i.ToString()).ToString() <> "root" Then
                '                If .Item("category_type" + i.ToString()) IsNot DBNull.Value Then
                '                    Select Case .Item("category_type" + i.ToString())
                '                        Case "Subcategory"
                '                            mAry.Add(String.Format("<a href='{2}/Product/Model_Master.aspx?category_id={0}'>{1}</a>", _
                '                                                   .Item("parent_category_id" + i.ToString()), .Item("category_name" + i.ToString()), _RunTimeURL))
                '                        Case "Category"
                '                            mAry.Add(String.Format("<a href='{2}/Product/SubCategory.aspx?category_id={0}'>{1}</a>", _
                '                                                   .Item("parent_category_id" + i.ToString()), .Item("category_name" + i.ToString()), _RunTimeURL))
                '                        Case ""
                '                            mAry.Add(String.Format("<a href='{1}/Product/Product_Line_New.aspx'>{0}</a>", .Item("category_name" + i.ToString()), _RunTimeURL))
                '                    End Select
                '                End If
                '            Else
                '                If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value _
                '                    AndAlso .Item("parent_category_id" + i.ToString()).ToString() = "root" Then
                '                    mAry.Add(String.Format("<a href='" & _RunTimeURL & "/Product/Product_Line_New.aspx'>Product Lines</a>"))
                '                    Exit For
                '                End If
                '            End If
                '        Next
                '        If mAry.Count > 0 Then
                '            For i As Integer = 0 To mAry.Count - 1
                '                litProdLine.Text += mAry.Item(mAry.Count - i - 1)
                '                If i < mAry.Count - 1 Then
                '                    litProdLine.Text += " > "
                '                End If
                '            Next
                '        End If

                '    End With
                'End If

                'Frank 2012/04/30: Add a new parameter "Category_ID", because one model can be related to multi-category
                Dim _LinkStr As String = PISDAL.GetCurrentProductNavigatePath(PISDAL.CurrentProductItemType.model, hd_Model.Value, _Category_ID)
                litProdLine.Text = _LinkStr


            Catch ex As Exception
                Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "global MA load prod hierarchy failed for " + hd_Model.Value, ex.ToString(), False, "", "")
            End Try
        End If
    End Sub

    Sub FillFeatures()
        If hd_Model.Value <> "" Then
            Try
                'JJ 2014/2/18：加入cache一天 - Main Feature & Intorduction
                'JJ：用TryCast继承另一個DataTable，如果DataTable是空的也不會跳InvalidCastException，而是返回Nothing
                Dim fdt As DataTable = TryCast(HttpContext.Current.Cache(hd_Model.Value + "_Features"), DataTable)
                'If fdt IsNot Nothing Then
                '    fdt = CType(HttpContext.Current.Cache(hd_Model.Value + "_Features"), DataTable)
                'Else
                If fdt Is Nothing Then
                    fdt = dbUtil.dbGetDataTable("PIS", String.Format( _
                  " Select  a.MODEL_DESC, a.EXTENDED_DESC, feature_desc  " + _
                  " From model A (nolock), model_FEATURE B (nolock)   " + _
                  " Where A.model_name = B.model_name AND B.LANG_ID = 'enu'and A.model_name='{0}' and feature_desc is not null and feature_desc<>'' " + _
                  " Order by B.FEATURE_SEQ ", Replace(hd_Model.Value, "'", "''")))

                    HttpContext.Current.Cache.Insert(hd_Model.Value + "_Features", fdt, Nothing, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
                End If

                gvModelFeatures.DataSource = fdt : gvModelFeatures.DataBind()


                ''JJ 2014/2/18：加入cache一天 - Intorduction
                'Dim pdt As DataTable
                'If HttpContext.Current.Cache(hd_Model.Value + "_Intro") IsNot Nothing Then
                '    pdt = CType(HttpContext.Current.Cache(hd_Model.Value + "_Intro"), DataTable)
                'Else
                '    pdt = dbUtil.dbGetDataTable("PIS", String.Format("select a.MODEL_DESC, a.EXTENDED_DESC from model a where a.MODEL_NAME='{0}'", Replace(hd_Model.Value, "'", "''")))
                '    HttpContext.Current.Cache.Insert(hd_Model.Value + "_Intro", pdt, Nothing, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
                'End If

                'Intorduction
                If fdt.Rows.Count > 0 Then
                    With fdt.Rows(0)
                        If .Item("model_desc") IsNot DBNull.Value Then lbModelDesc.Text = .Item("model_desc")
                        'If .Item("IMAGE_ID") <> "" Then
                        '    imgModelPic.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + .Item("IMAGE_ID")
                        'Else
                        '    Dim imgDt As DataTable = dbUtil.dbGetDataTable("My", String.Format("select isnull(TUMBNAIL_IMAGE_ID,'') from PIS_SIEBEL_PRODUCT where part_no ='{0}' and type='model'", hd_Model.Value))
                        '    If imgDt.Rows.Count > 0 Then
                        '        imgModelPic.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + imgDt.Rows(0).Item(0).ToString
                        '    Else
                        '        imgModelPic.Visible = False
                        '    End If
                        'End If

                        If .Item("EXTENDED_DESC") IsNot DBNull.Value And .Item("EXTENDED_DESC").ToString.Trim <> "" Then
                            litModelIntro.Text = .Item("EXTENDED_DESC")
                        Else
                            litModelIntro.Text = .Item("model_desc")
                        End If
                    End With
                    'Else
                    '    imgModelPic.Visible = False
                End If

            Catch ex As Exception
                Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "global MA load feature failed for " + hd_Model.Value, ex.ToString(), False, "", "")
            End Try
        End If
    End Sub

    Sub FillModelProfile()
        If hd_Model.Value <> "" Then
            Try
                ''JJ 2014/2/18：加入cache一天 - 主圖
                'Dim imgDt As DataTable
                'If HttpContext.Current.Cache(hd_Model.Value + "_Img") IsNot Nothing Then
                '    imgDt = CType(HttpContext.Current.Cache(hd_Model.Value + "_Img"), DataTable)
                'Else
                '    imgDt = dbUtil.dbGetDataTable("PIS", String.Format("select a.literature_id,b.LIT_TYPE  from model_lit a left join LITERATURE b on a.literature_id=b.LITERATURE_ID where b.LIT_TYPE in ('Product - Photo(Main)','Product - Photo(B)','Product - Photo(S)') and a.model_name='{0}'", Replace(hd_Model.Value, "'", "''")))
                '    HttpContext.Current.Cache.Insert(hd_Model.Value + "_Img", imgDt, Nothing, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
                'End If

                'If imgDt.Rows.Count > 0 Then
                '    imgModelPic.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id="
                '    Dim rs() As DataRow = imgDt.Select("LIT_TYPE='Product - Photo(Main)'")
                '    If rs.Count > 0 Then
                '        imgModelPic.ImageUrl += rs(0).Item(0).ToString
                '    Else
                '        rs = imgDt.Select("LIT_TYPE='Product - Photo(B)'")
                '        If rs.Count > 0 Then
                '            imgModelPic.ImageUrl += rs(0).Item(0).ToString
                '        Else
                '            rs = imgDt.Select("LIT_TYPE='Product - Photo(S)'")
                '            If rs.Count > 0 Then
                '                imgModelPic.ImageUrl += rs(0).Item(0).ToString
                '            Else
                '                imgModelPic.ViewStateMode = False
                '            End If
                '        End If
                '    End If
                'Else
                '    imgModelPic.Visible = False
                'End If


                'JJ 2014/2/18：加入cache一天 - 圖片
                'JJ：用TryCast继承另一個DataTable，如果DataTable是空的也不會跳InvalidCastException，而是返回Nothing
                Dim imgDt As DataTable = TryCast(HttpContext.Current.Cache(hd_Model.Value + "_LitImg"), DataTable)
                'If imgDt IsNot Nothing Then
                '    imgDt = CType(HttpContext.Current.Cache(hd_Model.Value + "_LitImg"), DataTable)
                'Else
                If imgDt Is Nothing Then
                    Dim sb As New StringBuilder
                    With sb
                        .AppendFormat(" select distinct z1.LITERATURE_ID, z1.lit_name ,z1.LIT_TYPE")
                        .AppendFormat(" from v_LITERATURE z1 (nolock) left join v_CATALOG_CATEGORY_LIT z2 (nolock) on z1.LITERATURE_ID=z2.Literature_ID " + _
                                      " left join v_CATALOG_CATEGORY z3 (nolock) on z2.Category_ID=z3.CATEGORY_ID where z3.category_name='{0}' ", hd_Model.Value)
                        .AppendFormat(" and z1.lit_type like 'Product - Photo%' and z1.file_ext in ('jpg','jpeg','gif','png') and z1.LIT_TYPE <> 'Product - Photo(Main) - Thumbnail' ")
                        .AppendFormat(" and z1.PRIMARY_LEVEL <> 'RBU' ")
                    End With
                    imgDt = dbUtil.dbGetDataTable("PIS", sb.ToString)
                    HttpContext.Current.Cache.Insert(hd_Model.Value + "_LitImg", imgDt, Nothing, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
                End If

                '主圖
                If imgDt.Rows.Count > 0 Then
                    imgModelPic.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id="
                    Dim rs() As DataRow = imgDt.Select("LIT_TYPE='Product - Photo(Main)'")
                    If rs.Count > 0 Then
                        imgModelPic.ImageUrl += rs(0).Item(0).ToString
                    Else
                        rs = imgDt.Select("LIT_TYPE='Product - Photo(B)'")
                        If rs.Count > 0 Then
                            imgModelPic.ImageUrl += rs(0).Item(0).ToString
                        Else
                            rs = imgDt.Select("LIT_TYPE='Product - Photo(S)'")
                            If rs.Count > 0 Then
                                imgModelPic.ImageUrl += rs(0).Item(0).ToString
                            Else
                                imgModelPic.ViewStateMode = False
                            End If
                        End If
                    End If
                Else
                    imgModelPic.Visible = False
                End If

                '小圖
                Dim count As Integer = 1
                For Each row As DataRow In imgDt.Rows
                    'lblThumbnail.Text += "<a href='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + row.Item("LITERATURE_ID").ToString + "' rel='prettyPhoto[gal]'><img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + row.Item("LITERATURE_ID").ToString + "' width='50' height='50' alt='" + row.Item("lit_name").ToString + "' style='border:1px; border-color:#CFCFCF; border-style:solid; margin-bottom:3px' /></a>&nbsp;&nbsp;"
                    lblThumbnail.Text += "<a href='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + row.Item("LITERATURE_ID").ToString + "' data-lightbox='roadtrip'><img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + row.Item("LITERATURE_ID").ToString + "' width='50' height='50' alt='" + row.Item("lit_name").ToString + "' style='border:1px; border-color:#CFCFCF; border-style:solid; margin-bottom:3px' /></a>&nbsp;&nbsp;"
                    If count = 5 Then lblThumbnail.Text += "<br/>" : count = 0
                    count += 1
                Next

            Catch ex As Exception
                Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "global MA load model profile failed for " + hd_Model.Value, ex.ToString(), False, "", "")
            End Try
        End If
    End Sub

    Protected Sub TimerOrderInfo_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerOrderInfo.Interval = 99999
        If hd_Model.Value = "" Then
            ImgLoadOrderInfo.Visible = False : TimerOrderInfo.Enabled = False : gvModelOrderInfo.EmptyDataText = "N/A"
            Exit Sub
        End If
        Try
            FillOrderInfo()
            ImgLoadOrderInfo.Visible = False : gvModelOrderInfo.Visible = True
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "global MA load model order dt failed " + hd_Model.Value, ex.ToString(), False, "", "")
        End Try
        ImgLoadOrderInfo.Visible = False : TimerOrderInfo.Enabled = False : gvModelOrderInfo.EmptyDataText = "N/A"
    End Sub

    Protected Sub gvModelOrderInfo_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
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

    Sub FillLiterature()
        If hd_Model.Value <> "" Then
            Try
                'JJ 2014/2/18：加入cache一天 - Literature
                'JJ：用TryCast继承另一個DataTable，如果DataTable是空的也不會跳InvalidCastException，而是返回Nothing
                Dim ldt As DataTable = TryCast(HttpContext.Current.Cache(hd_Model.Value + "_Literature"), DataTable)
                'If ldt IsNot Nothing Then
                '    ldt = CType(HttpContext.Current.Cache(hd_Model.Value + "_Literature"), DataTable)
                'Else
                If ldt Is Nothing Then
                    ldt = dbUtil.dbGetDataTable("PIS_NEW", String.Format(
                   " select a.PART_NO as product_ID, a.LITERATURE_ID, a.LIT_TYPE, a.FILE_NAME, a.LIT_DESC, a.FILE_EXT, a.FILE_SIZE,a.LAST_UPDATED  " +
                   " from v_LITERATURE a (nolock) left join v_CATALOG_CATEGORY_LIT b (nolock) on a.LITERATURE_ID=b.Literature_ID " +
                   " left join v_CATALOG_CATEGORY c (nolock) on b.Category_ID=c.CATEGORY_ID " +
                   " where  (CONVERT(nvarchar, a.PART_NO) like N'%{0}%' or c.category_name=N'{0}') " +
                   " and a.lit_type not in ('roadmap','sales kits')  " +
                   " and a.PRIMARY_LEVEL <> 'RBU'  " +
                   " and a.LIT_TYPE not in ('Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') " +
                   " and a.LIT_TYPE not like '%Certificate%' " +
                   " order by a.LIT_TYPE,a.LAST_UPDATED DESC ", hd_Model.Value))

                    HttpContext.Current.Cache.Insert(hd_Model.Value + "_Literature", ldt, Nothing, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
                End If

                gvLiterature.DataSource = ldt : gvLiterature.DataBind()
            Catch ex As Exception
                Util.SendEmail("tc.chen@advantech.com.tw,rudy.wang@advantech.com.tw", "ebusiness.aeu@advantech.eu", "global MA load model literature failed " + hd_Model.Value, ex.ToString(), False, "", "")
            End Try
        End If
    End Sub

    Sub FillDownload()
        If Me.hd_Model.Value <> "" Then
            'JJ 2014/2/18：加入cache一天 - Download
            'JJ：用TryCast继承另一個DataTable，如果DataTable是空的也不會跳InvalidCastException，而是返回Nothing
            Dim dt As DataTable = TryCast(HttpContext.Current.Cache(hd_Model.Value + "_Download"), DataTable)
            'If dt IsNot Nothing Then
            '    dt = CType(HttpContext.Current.Cache(hd_Model.Value + "_Download"), DataTable)
            'Else
            If dt Is Nothing Then
                dt = dbUtil.dbGetDataTable("MY", String.Format( _
                    " SELECT DISTINCT A.PART_NO, B.ABSTRACT as Description, A.SR_ID, SEARCH_TYPE as Type, SR_TYPE, UPDATED_DATE,   " + _
                    " TOT= (SELECT COUNT(*) FROM SIEBEL_SR_SOLUTION_RELATION X (nolock), SIEBEL_SR_SOLUTION_FILE_RELATION Y (nolock), SIEBEL_SR_SOLUTION_FILE Z (nolock)   " + _
                    " WHERE X.SR_ID=A.SR_ID AND X.SOLUTION_ID=Y.SOLUTION_ID AND Y.FILE_ID=Z.FILE_ID AND Z.PUBLISH_FLAG='Y')   " + _
                    " FROM SIEBEL_SR_PRODUCT A (nolock), SIEBEL_SR_DOWNLOAD B (nolock)   " + _
                    " WHERE A.PART_NO LIKE '%{0}%' AND A.SR_ID=B.SR_ID AND B.PUBLISH_SCOPE='External' AND SR_TYPE='Download' AND B.ABSTRACT<>''   " + _
                    " AND B.ABSTRACT IS NOT NULL ORDER BY SEARCH_TYPE ", Replace(hd_Model.Value, "'", "''")))

                HttpContext.Current.Cache.Insert(hd_Model.Value + "_Download", dt, Nothing, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
            End If

            gvDownloads.DataSource = dt : gvDownloads.DataBind()
            gvDownloads.EmptyDataText = "N/A" : gvDownloads.Visible = True
        End If
    End Sub

    Protected Sub TimerDownload_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerDownload.Interval = 99999
        If hd_Model.Value = "" Then
            TimerDownload.Enabled = False : ImgDownload.Visible = False : Exit Sub
        End If
        Try
            FillDownload()
        Catch ex As Exception
            MailUtil.SendDebugMsg("Global MA load model download fail " + hd_Model.Value, ex.ToString())
        End Try
        TimerDownload.Enabled = False : ImgDownload.Visible = False
    End Sub

    Sub FillDAQ()
        If Me.hd_Model.Value <> "" Then
            'JJ 2014/2/18：加入cache一天 - FAQ
            'JJ：用TryCast继承另一個DataTable，如果DataTable是空的也不會跳InvalidCastException，而是返回Nothing
            Dim dt As DataTable = TryCast(HttpContext.Current.Cache(hd_Model.Value + "_FAQ"), DataTable)
            'If dt IsNot Nothing Then
            '    dt = CType(HttpContext.Current.Cache(hd_Model.Value + "_FAQ"), DataTable)
            'Else
            If dt Is Nothing Then
                Dim Str_Channel As String = " AND B.PUBLISH_SCOPE like 'External%' "
                Dim strSql As String = _
                String.Format( _
                    " SELECT DISTINCT IsNull((select top 1 z.part_no from SIEBEL_SR_PRODUCT z (nolock) where z.SR_ID=A.SR_ID and z.PART_NO like '%{0}%'),'') as PART_NO, " + _
                    " B.ABSTRACT as Question, A.SR_ID, SEARCH_TYPE, SR_TYPE, UPDATED_DATE " & _
                    " FROM SIEBEL_SR_PRODUCT A (nolock), SIEBEL_SR_DOWNLOAD B (nolock), SIEBEL_SR_SOLUTION_RELATION C (nolock), SIEBEL_SR_SOLUTION D (nolock) " & _
                    " WHERE A.PART_NO LIKE '%{0}%' AND A.SR_ID = B.SR_ID " & Str_Channel & _
                    " AND SR_TYPE = 'Knowledge Base' AND SEARCH_TYPE='FAQ' AND B.ABSTRACT <> '' " & _
                    " AND B.ABSTRACT IS NOT NULL AND B.SR_ID = C.SR_ID AND C.SOLUTION_ID = D.SR_ID " & _
                    " AND D.PUBLISH_FLG = 'Y' ORDER BY B.ABSTRACT ", Replace(hd_Model.Value, "'", "''"))
                dt = dbUtil.dbGetDataTable("MY", strSql)

                HttpContext.Current.Cache.Insert(hd_Model.Value + "_FAQ", dt, Nothing, DateTime.Now.AddDays(1), Cache.NoSlidingExpiration)
            End If

            gvFAQ.DataSource = dt : gvFAQ.DataBind() : gvFAQ.EmptyDataText = "N/A" : gvFAQ.Visible = True
        End If
    End Sub

    Protected Sub TimerFAQ_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerFAQ.Interval = 99999
        If hd_Model.Value = "" Then
            TimerFAQ.Enabled = False : ImgFAQLoad.Visible = False : Exit Sub
        End If
        Try
            FillDAQ()
        Catch ex As Exception
            MailUtil.SendDebugMsg("Global MA load model FAQ fail " + hd_Model.Value, ex.ToString())
        End Try
        TimerFAQ.Enabled = False : ImgFAQLoad.Visible = False
    End Sub

    Protected Sub gvModelOrderInfo_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            Dim upm As AuthUtil.UserPermission = AuthUtil.GetPermissionByUser()
            gvModelOrderInfo.Columns(3).Visible = upm.CanSeeListPrice
            gvModelOrderInfo.Columns(4).Visible = upm.CanSeeUnitPrice
            gvModelOrderInfo.Columns(5).Visible = upm.CanPlaceOrder
        End If
    End Sub

    Protected Sub HtmlAnchor_Click(sender As Object, e As EventArgs)
        Dim btn As LinkButton = CType(sender, LinkButton)
        Dim url As String = btn.CommandArgument.ToString

        If AuthUtil.IsBBUS Then
            'Log download record to db
            Dim pSessionID As New SqlClient.SqlParameter("SESSION", SqlDbType.VarChar) : pSessionID.Value = HttpContext.Current.Session.SessionID
            Dim pTransID As New SqlClient.SqlParameter("TRANS", SqlDbType.VarChar) : pTransID.Value = "Certificate Download"
            Dim pUserID As New SqlClient.SqlParameter("USERID", SqlDbType.VarChar) : pUserID.Value = HttpContext.Current.User.Identity.Name
            Dim pUrl As New SqlClient.SqlParameter("URL", SqlDbType.VarChar) : pUrl.Value = Context.Request.ServerVariables("SCRIPT_NAME").ToLower()
            Dim pQuery As New SqlClient.SqlParameter("QUERY", SqlDbType.VarChar) : pQuery.Value = ""
            Dim pNote As New SqlClient.SqlParameter("NOTE", SqlDbType.VarChar) : pNote.Value = ""
            Dim pMethod As New SqlClient.SqlParameter("METHOD", SqlDbType.VarChar) : pMethod.Value = ""
            Dim pServerPort As New SqlClient.SqlParameter("SERVERPORT", SqlDbType.VarChar) : pServerPort.Value = Request.ServerVariables("SERVER_NAME") + ":" + Request.ServerVariables("SERVER_PORT")
            Dim pClientName As New SqlClient.SqlParameter("CLIENT", SqlDbType.VarChar) : pClientName.Value = Util.GetClientIP()
            Dim pAppID As New SqlClient.SqlParameter("APPID", SqlDbType.VarChar) : pAppID.Value = "MY"
            Dim pReferrer As New SqlClient.SqlParameter("REFERRER", SqlDbType.VarChar) : pReferrer.Value = url
            Dim sSQL As String = "insert into USER_LOG values(@SESSION,@TRANS,@USERID,GetDate(),@URL,@QUERY,@NOTE,@METHOD,@SERVERPORT,@CLIENT,@APPID,'N',@REFERRER)"
            Dim para() As SqlClient.SqlParameter = {pSessionID, pTransID, pUserID, pUrl, pQuery, pNote, pMethod, pServerPort, pClientName, pAppID, pReferrer}
            Try
                dbUtil.dbExecuteNoQuery2("MY", sSQL, para)
            Catch ex As Exception
                Util.SendEmail("yl.huang@advantech.com.tw", "myadvantech@advantech.com", "Insert Certificate download Log Failed", ex.ToString, True, "", "")
            End Try
        End If

        ScriptManager.RegisterClientScriptBlock(Me.Page, Me.Page.GetType(), "Script", "window.open ('" + url + "','_blank');", True)
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <script src="../Includes/jquery-1.11.1.min.js" type="text/javascript"></script>
    <script src="../Includes/lightbox/lightbox.min.js" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="../Includes/lightbox/lightbox.css" />
    <style type="text/css">
        .Labelcss {
            line-height: 30px;
            vertical-align: middle;
        }
    </style>
    <script type="text/javascript" charset="utf-8">
        $(document).ready(function () {
            //        $("a[rel^='prettyPhoto']").prettyPhoto({
            //            social_tools: false,
            //            gallery_markup: '',
            //            slideshow: 2000
            //        });
        });
    </script>
    <asp:HiddenField runat="server" ID="hd_Model" />
    <table width="95%">
        <tr>
            <td>
                <asp:Literal runat="server" ID="litProdLine" />
            </td>
        </tr>
        <tr>
            <td>
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Label runat="server" ID="lbModelName" CssClass="Labelcss" ForeColor="#114B9F" Font-Bold="true" Font-Size="XX-Large" /></td>
                        <td>
                            <asp:Image runat="server" ID="imgRoHSPic" ImageUrl="~/Images/rohs.jpg" Visible="false" /></td>
                    </tr>
                </table>
                <hr />
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%">
                    <tr>
                        <td colspan="2">
                            <asp:Label runat="server" ID="lbModelDesc" ForeColor="#6F7072" Font-Size="Large" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" height="5"></td>
                    </tr>
                    <tr runat="server" id="trModel" style="width: 100%">
                        <td style="width: 50%">
                            <table width="100%">
                                <tr>
                                    <td align="left">
                                        <a runat="server" id="imgLink" target="_blank">
                                            <asp:Image runat="server" ID="imgModelPic" Width="200" /><br />
                                            <br />
                                            <asp:Label runat="server" ID="lblThumbnail" />
                                        </a>
                                        <div id="content" style="position: absolute; z-index: 50; background-color: #D9E3ED">
                                            <asp:Label runat="server" ID="lblContent" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width: 50%" valign="top" align="left">
                            <table width="100%">
                                <tr valign="top">
                                    <th align="left" colspan="2" style="font-size: medium; color: #114B9F">Main Feature</th>
                                </tr>
                                <tr>
                                    <td style="width: 5px">&nbsp;</td>
                                    <td>
                                        <asp:GridView Width="100%" runat="server" AutoGenerateColumns="false" ID="gvModelFeatures" ShowHeader="false" ShowFooter="false" BorderWidth="0">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <ItemTemplate>
                                                        <li />
                                                        <%# Eval("feature_desc")%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr runat="server" id="trModel1">
                        <td width="100%" colspan="2">
                            <hr />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <ajaxToolkit:TabContainer runat="server" ID="TabContainer1">
                                <ajaxToolkit:TabPanel runat="server" ID="tbIntro" HeaderText="Introduction">
                                    <ContentTemplate>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td bgcolor="#F0F0F0">&nbsp;<asp:Literal runat="server" ID="litModelIntro" />
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </ajaxToolkit:TabPanel>
                                <ajaxToolkit:TabPanel runat="server" ID="tbLit" HeaderText="Literature">
                                    <ContentTemplate>
                                        <a name="Lit"></a>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td bgcolor="#F0F0F0">&nbsp;
                                                    <asp:GridView runat="server" ID="gvLiterature" Width="100%"
                                                        AutoGenerateColumns="false" DataKeyNames="LITERATURE_ID" EnableTheming="false"
                                                        RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc"
                                                        BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid"
                                                        PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                                        <Columns>
                                                            <asp:BoundField HeaderText="Literature Type" DataField="LIT_TYPE" SortExpression="LIT_TYPE" />
                                                            <asp:HyperLinkField HeaderText="Name" Target="_blank" SortExpression="FILE_NAME"
                                                                DataNavigateUrlFields="LITERATURE_ID,product_ID"
                                                                DataNavigateUrlFormatString="~/Product/Unzip_File.aspx?Literature_Id={0}&Part_NO={1}"
                                                                DataTextField="FILE_NAME" />
                                                            <asp:BoundField HeaderText="Description" DataField="LIT_DESC" SortExpression="LIT_DESC" />
                                                            <asp:BoundField HeaderText="File Type" DataField="FILE_EXT" SortExpression="FILE_EXT" />
                                                            <asp:TemplateField HeaderText="File Size">
                                                                <ItemTemplate>
                                                                    <%# FormatNumber(CDbl(Eval("FILE_SIZE")) / 1024, 0, , , -2) + "k"%>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </ajaxToolkit:TabPanel>
                                <ajaxToolkit:TabPanel runat="server" ID="tbDownload" HeaderText="Download">
                                    <ContentTemplate>
                                        <a name="Download"></a>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td bgcolor="#F0F0F0">&nbsp;
                                                    <asp:UpdatePanel runat="server" ID="upDownload" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Timer runat="server" ID="TimerDownload" Interval="300" OnTick="TimerDownload_Tick" />
                                                            <asp:Image runat="server" ID="ImgDownload" ImageUrl="~/Images/Loading2.gif" ImageAlign="Middle" AlternateText="Loading Download Data..." />
                                                            <asp:GridView runat="server" ID="gvDownloads" Width="100%" AutoGenerateColumns="false" Visible="false"
                                                                EnableTheming="false" RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb"
                                                                HeaderStyle-BackColor="#dcdcdc" BorderWidth="1" BorderColor="#d7d0d0"
                                                                HeaderStyle-ForeColor="Black" BorderStyle="Solid"
                                                                PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                                                <Columns>
                                                                    <asp:HyperLinkField HeaderText="Description" SortExpression="Description"
                                                                        DataNavigateUrlFields="SR_ID,PART_NO,TYPE" Target="_blank"
                                                                        DataNavigateUrlFormatString="~/Product/SR_Download.aspx?SR_ID={0}&Part_NO={1}&C={2}"
                                                                        DataTextField="Description" />
                                                                    <asp:BoundField HeaderText="Type" DataField="Type" SortExpression="Type" />
                                                                    <asp:TemplateField HeaderText="Date" SortExpression="UPDATED_DATE">
                                                                        <ItemTemplate>
                                                                            <%# CDate(Eval("UPDATED_DATE")).ToShortDateString()%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                            </asp:GridView>
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </ajaxToolkit:TabPanel>
                                <ajaxToolkit:TabPanel runat="server" ID="tbFAQ" HeaderText="FAQ">
                                    <ContentTemplate>
                                        <a name="FAQ"></a>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td bgcolor="#F0F0F0">&nbsp;
                                                    <asp:UpdatePanel runat="server" ID="upFAQ" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Timer runat="server" ID="TimerFAQ" Interval="600" OnTick="TimerFAQ_Tick" />
                                                            <asp:Image runat="server" ID="ImgFAQLoad" ImageUrl="~/Images/Loading2.gif" ImageAlign="Middle" AlternateText="Loading FAQ..." />
                                                            <asp:GridView runat="server" ID="gvFAQ" Width="100%" Visible="false" AutoGenerateColumns="false"
                                                                EnableTheming="false" RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb"
                                                                HeaderStyle-BackColor="#dcdcdc" BorderWidth="1" BorderColor="#d7d0d0"
                                                                HeaderStyle-ForeColor="Black" BorderStyle="Solid" EmptyDataText="N/A"
                                                                PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                                                <Columns>
                                                                    <asp:HyperLinkField HeaderText="Question" Target="_blank" SortExpression="Question"
                                                                        DataNavigateUrlFields="SR_ID,PART_NO"
                                                                        DataNavigateUrlFormatString="~/Product/SR_Detail.aspx?SR_ID={0}&Part_No={1}&C=FAQ"
                                                                        DataTextField="Question" />
                                                                    <asp:TemplateField HeaderText="Date" SortExpression="UPDATED_DATE">
                                                                        <ItemTemplate>
                                                                            <%# CDate(Eval("UPDATED_DATE")).ToShortDateString()%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                            </asp:GridView>
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </ajaxToolkit:TabPanel>
                                <ajaxToolkit:TabPanel runat="server" ID="tbPLMCert" HeaderText="Certificate">
                                    <ContentTemplate>
                                        <a name="Certificate"></a>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td bgcolor="#F0F0F0">&nbsp;
                                                    <asp:UpdatePanel runat="server" ID="upCertificate" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:GridView runat="server" ID="gvCertificate" Width="100%"
                                                                AutoGenerateColumns="false" EnableTheming="false"
                                                                RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc"
                                                                BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid"
                                                                PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                                                <Columns>
                                                                    <asp:TemplateField HeaderText="Doc. #">
                                                                        <ItemTemplate>
                                                                            <%#Eval("OBJECT_NUMBER") %>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Subject">
                                                                        <ItemTemplate>
<%--                                                                            <a target="_blank" href='<%#Eval("URL") %>' runat="server" onServerClick="UrlClick"><%#String.Format("({0}) {1}", Eval("TEST_ITEM_CERTIFICATION"), Eval("DOCUMENT_NAME")) %></a>--%>
                                                                            <asp:LinkButton runat="server" CommandArgument='<%#Eval("URL") %>' Text='<%# String.Format("({0}) {1}", Eval("TEST_ITEM_CERTIFICATION"), Eval("DOCUMENT_NAME")) %>' OnClick="HtmlAnchor_Click"></asp:LinkButton>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Date">
                                                                        <ItemTemplate>
                                                                            <%#CDate(Eval("RELEASE_DATE")).ToString("yyyy-MM-dd") %>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                            </asp:GridView>
                                                        </ContentTemplate>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </ajaxToolkit:TabPanel>
                            </ajaxToolkit:TabContainer>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td></td>
                    </tr>
                    <tr>
                        <td colspan="2"><a name="OrderInfo"></a>
                            <ajaxToolkit:CollapsiblePanelExtender ID="cpeOrderInfo" runat="Server"
                                TargetControlID="PanelContentOrderInfo" ExpandControlID="PanelHeaderOrderInfo" CollapseControlID="PanelHeaderOrderInfo"
                                CollapsedSize="0" Collapsed="false" ScrollContents="false" SuppressPostBack="true" ExpandDirection="Vertical" />
                            <asp:Panel runat="server" ID="PanelHeaderOrderInfo">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" onmouseover="this.style.cursor='hand'">
                                    <tr>
                                        <td>
                                            <div style="background-color: #D9E3ED; font-size: small;"><b>&nbsp;Ordering Information</b></div>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                            <asp:Panel runat="server" ID="PanelContentOrderInfo">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td bgcolor="#F0F0F0">&nbsp;
                                            <asp:UpdatePanel runat="server" ID="upOrderInfo" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <asp:Timer runat="server" ID="TimerOrderInfo" Interval="100" OnTick="TimerOrderInfo_Tick" />
                                                    <asp:Image runat="server" ID="ImgLoadOrderInfo" ImageUrl="~/Images/Loading2.gif" ImageAlign="Middle" />
                                                    <asp:GridView runat="server" ID="gvModelOrderInfo" Width="100%" Visible="false"
                                                        AutoGenerateColumns="false" DataKeyNames="part_no" EnableTheming="false"
                                                        RowStyle-BackColor="#FFFFFF" AlternatingRowStyle-BackColor="#ebebeb" HeaderStyle-BackColor="#dcdcdc"
                                                        BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid"
                                                        PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" OnRowCreated="gvModelOrderInfo_RowCreated" OnRowDataBound="gvModelOrderInfo_RowDataBound">
                                                        <Columns>
                                                            <asp:BoundField HeaderText="Part No." DataField="part_no" SortExpression="part_no" />
                                                            <asp:BoundField HeaderText="Description" DataField="product_desc" SortExpression="product_desc" />
                                                            <asp:TemplateField HeaderText="RoHS" SortExpression="RoHS_Flag" ItemStyle-HorizontalAlign="Center">
                                                                <ItemTemplate>
                                                                    <%# IIf(Eval("ROHS_FLAG").ToString() = "1", "<img src='/Images/RoHS.jpg' alt='RoHS Compliant' />", "")%>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:BoundField HeaderText="List Price" DataField="LP" SortExpression="LP" ItemStyle-HorizontalAlign="Right" />
                                                            <asp:BoundField HeaderText="Unit Price" DataField="UP" SortExpression="UP" ItemStyle-HorizontalAlign="Right" />
                                                            <%--<asp:BoundField HeaderText="Availability" DataField="ATP" SortExpression="ATP" ItemStyle-HorizontalAlign="Center" Visible="false" />--%>
                                                            <asp:TemplateField HeaderText="Add To Cart" ItemStyle-HorizontalAlign="Center">
                                                                <ItemTemplate>
                                                                    <a href='../order/cart_add2cartline.aspx?part_no=<%#Eval("part_no") %>&qty=1'>
                                                                        <img src="../Images/ebiz.aeu.face/btn_add2cart1.gif" alt="Add2Cart" width="99" height="20" />
                                                                    </a>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                    <asp:GridView runat="server" ID="pGV" />
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" height="5"></td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <hr />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
