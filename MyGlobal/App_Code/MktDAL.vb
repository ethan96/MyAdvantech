Imports Microsoft.VisualBasic
Imports System.Windows.Forms
Imports System.Drawing
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Threading
#Region "PIS"

Public Class ModelUtil
    Public model_ID As String, model_No As String, language As String = "ENU"
    Public StrCatalogID As String, Product_Line As String, extended_desc As String, Model_Intro As String, New_Mark As String, Product_ID As String, Product_Desc As String, Image_Name As String
    Public dtFeature As DataTable, dtDownload As DataTable, dtFAQ As DataTable, dtLiteraure As DataTable, dtOrderInfo As DataTable
    Public isRoHSLogo As Boolean, arrPartNo As New ArrayList

    Sub New(ByVal model_id As String)
        If model_id = "" Then
            'HttpContext.Current.Response.Redirect("/Order/Product_Search.aspx")
            Throw New Exception("model id is mandatory")
        Else
            Me.model_ID = model_id
            Me.setModelNo()
        End If
        'Me.language = HttpContext.Current.Session("lang_id")
        Me.setModelInfo()
    End Sub

    Sub New(ByVal model_id As String, ByVal model_no As String)
        If model_id = "" And model_no = "" Then
            'HttpContext.Current.Response.Redirect("/Order/Product_Search.aspx")
            'Throw New Exception("please provide at least model id")
            Exit Sub
        End If
        If model_id = "" And model_no <> "" Then
            If dbUtil.dbGetDataTable("My", "SELECT isnull(DISPLAY_NAME,'') FROM SIEBEL_CATALOG_CATEGORY WHERE DISPLAY_NAME ='" + model_no + "'").Rows.Count > 0 Then
                Me.model_No = model_no
                Me.setModelID()
            Else
                Me.model_No = "" : Me.model_ID = ""
            End If
        End If
        If model_id <> "" And model_no = "" Then
            Me.model_ID = model_id
            Me.setModelNo()
        End If
        If model_no <> "" And model_id <> "" Then
            Me.model_ID = model_id : Me.model_No = model_no
        End If
        'Me.language = HttpContext.Current.Session("lang_id")
        Me.setModelInfo()
    End Sub

    Private Sub setModelID()
        Try
            Dim obj As Object = dbUtil.dbExecuteScalar("My", _
            " SELECT isnull(CATEGORY_ID,'') FROM SIEBEL_CATALOG_CATEGORY WHERE DISPLAY_NAME = '" + model_No + "' " + _
            " AND catalog_Id in (SELECT CATALOG_ID FROM CATALOG_SHOW)")
            If IsNothing(obj) Then
                obj = dbUtil.dbExecuteScalar("My", " SELECT isnull(CATEGORY_ID,'') FROM SIEBEL_CATALOG_CATEGORY WHERE DISPLAY_NAME = '" + model_No + "'")
            End If
            If Not IsNothing(obj) Then
                model_ID = obj.ToString()
            Else
                model_ID = ""
            End If
        Catch ex As Exception
            Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Set Model ID Error", ex.ToString, True, "", "")
        End Try

    End Sub

    Private Sub setModelNo()
        Dim DNDt As DataTable = dbUtil.dbGetDataTable("My", _
            " SELECT IsNull(DISPLAY_NAME, '') as DISPLAY_NAME " + _
            " FROM SIEBEL_CATALOG_CATEGORY WHERE CATEGORY_ID = '" + model_ID + "' " + _
            " AND catalog_Id in (SELECT CATALOG_ID FROM CATALOG_SHOW)")
        If Not IsNothing(DNDt) AndAlso DNDt.Rows.Count > 0 Then
            model_No = DNDt.Rows(0).Item("DISPLAY_NAME").ToString()
        End If
    End Sub

    Private Sub setModelInfo()
        Dim strSql As String
        If language = "ENU" Then
            strSql = _
            "Select CATALOG_ID,CATEGORY_ID,CATEGORY_NAME, " + _
            "DISPLAY_NAME, CATEGORY_DESC, IsNull(EXTENDED_DESC, '') as EXTENDED_DESC, IMAGE_ID, PARENT_CATEGORY_ID " + _
            "From SIEBEL_CATALOG_CATEGORY Where CATEGORY_ID = '" + model_ID + "'"
        Else
            strSql = _
            " Select a.CATALOG_ID,a.CATEGORY_ID,CATEGORY_NAME," & _
            " DISPLAY_NAME  = isnull(b.DISPLAY_NAME,a.DISPLAY_NAME)," & _
            " CATEGORY_DESC = isnull(b.CATEGORY_DESC,a.CATEGORY_DESC)," & _
            " EXTENDED_DESC = isnull(b.EXTENDED_DESC,a.EXTENDED_DESC)," & _
            " IMAGE_ID,PARENT_CATEGORY_ID " & _
            " From SIEBEL_CATALOG_CATEGORY a left join SIEBEL_CATALOG_CATEGORY_LANG b on a.CATEGORY_ID = b.CATEGORY_ID " & _
            " Where a.CATEGORY_ID  = '" & model_ID & "' " + _
            " and b.LANG_ID  = '" & language & "' "
        End If

        Dim dt As DataTable = dbUtil.dbGetDataTable("My", strSql)
        Dim parent_id As String = ""
        If dt.Rows.Count > 0 Then
            StrCatalogID = dt.Rows(0).Item("CATALOG_ID").ToString()
            Product_Line = dt.Rows(0).Item("DISPLAY_NAME") : model_No = dt.Rows(0).Item("DISPLAY_NAME")
            extended_desc = dt.Rows(0).Item("EXTENDED_DESC").ToString()
            parent_id = dt.Rows(0).Item("PARENT_CATEGORY_ID").ToString()
            Model_Intro = dt.Rows(0).Item("extended_desc").ToString()
            Try
                Dim dtPartNo As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("select distinct a.part_no from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO where b.ORG_ID='{0}' and model_no='{1}'", IIf(Not IsNothing(HttpContext.Current.Session("org_id")), HttpContext.Current.Session("org_id"), "EU10"), model_No))
                If dtPartNo.Rows.Count > 0 Then
                    For Each row As DataRow In dtPartNo.Rows
                        arrPartNo.Add("'" + row.Item("part_no") + "'")
                    Next
                End If
                'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "test", String.Join(",", arrPartNo.ToArray()), True, "", "")
            Catch ex As Exception
                'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "error", ex.ToString, True, "", "")
            End Try
        Else
            dt = dbUtil.dbGetDataTable("B2B", String.Format("select distinct a.part_no from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO where b.ORG_ID='{0}' and model_no='{1}'", IIf(Not IsNothing(HttpContext.Current.Session("org_id")), HttpContext.Current.Session("org_id"), "EU10"), model_No))
            If dt.Rows.Count > 0 Then
                For Each row As DataRow In dt.Rows
                    arrPartNo.Add("'" + row.Item("part_no") + "'")
                Next
                Dim sb As New StringBuilder
                With sb
                    .AppendFormat("Select isnull(CATALOG_ID,'') as CATALOG_ID,isnull(CATEGORY_ID,'') as CATEGORY_ID,isnull(CATEGORY_NAME,'') as CATEGORY_NAME,isnull(DISPLAY_NAME,'') as DISPLAY_NAME, isnull(CATEGORY_DESC,'') as CATEGORY_DESC, IsNull(EXTENDED_DESC, '') as EXTENDED_DESC, isnull(IMAGE_ID,'') as IMAGE_ID, isnull(PARENT_CATEGORY_ID,'') as PARENT_CATEGORY_ID From SIEBEL_CATALOG_CATEGORY Where CATEGORY_ID in ")
                    .AppendFormat("(select distinct category_id from SIEBEL_CATALOG_CATEGORY_PROD where PRODUCT_ID in (select distinct product_id from SIEBEL_PRODUCT where part_no in ({0})))", String.Join(",", arrPartNo.ToArray()))
                End With
                dt = dbUtil.dbGetDataTable("My", sb.ToString)
                If dt.Rows.Count > 0 Then
                    model_ID = dt.Rows(0).Item("CATEGORY_ID").ToString
                    model_No = dt.Rows(0).Item("DISPLAY_NAME").ToString
                    StrCatalogID = dt.Rows(0).Item("CATALOG_ID").ToString()
                    Product_Line = dt.Rows(0).Item("DISPLAY_NAME") : model_No = dt.Rows(0).Item("DISPLAY_NAME")
                    extended_desc = dt.Rows(0).Item("EXTENDED_DESC").ToString()
                    parent_id = dt.Rows(0).Item("PARENT_CATEGORY_ID").ToString()
                    Model_Intro = dt.Rows(0).Item("extended_desc").ToString()
                End If
                If Model_Intro = "" Then
                    Model_Intro = dbUtil.dbExecuteScalar("RFM", String.Format("select top 1 isnull(PRODUCT_DESC,'') as PRODUCT_DESC from SAP_PRODUCT where PART_NO in ({0}) order by last_upd_date desc, create_date desc", String.Join(",", arrPartNo.ToArray(GetType(System.String))))).ToString
                End If
            Else
                'Dim ex As New Exception
                'Util.SendEmail("rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw", "eBusiness.AEU@advantech.eu", "Model not found with model_ID : " + model_ID + " and model_NO : " + model_No, "<table><tr><td>http://my.advantech.eu/Product/Model_Detail.aspx?Model_ID=" + model_ID + "&Model_NO=" + model_No + "</td></tr><tr><td>" + HttpContext.Current.User.Identity.Name.ToString + "</td></tr><tr><td>" + DateTime.Now.ToString + "</td></tr></table>", True, "", "")
            End If
        End If

        'Frank 2012/01/17 shift ProductCategoryUtil to ProductCategoryUtil_PIS
        'ProductCategoryUtil.getHierarchyProductLine(parent_id, Product_Line)
        ProductCategoryUtil_PIS.getHierarchyProductLine(parent_id, Product_Line)


        Dim IMG_Dt As DataTable = _
        dbUtil.dbGetDataTable("My", _
        " Select a.PRODUCT_ID, TUMBNAIL_IMAGE_ID, PRODUCT_DESC=isnull(a.PRODUCT_DESC, ''), " & _
        " EXTENTED_DESC=isnull(a.EXTENTED_DESC, ''), IsNull(NEW_PRODUCT_DATE,'') as NEW_PRODUCT_DATE " & _
        " from SIEBEL_PRODUCT a, SIEBEL_PRODUCT_LANG b " & _
        " WHERE PART_NO = '" & model_No & "' AND a.PRODUCT_ID = b.PRODUCT_ID " + _
        IIf(language <> "", " and B.LANG_ID='" + language + "'", " ").ToString())

        If IsNothing(IMG_Dt) OrElse IMG_Dt.Rows.Count = 0 Then
            IMG_Dt = _
            dbUtil.dbGetDataTable("My", _
            " Select a.PRODUCT_ID, IsNull(TUMBNAIL_IMAGE_ID, '') as TUMBNAIL_IMAGE_ID, PRODUCT_DESC=isnull(a.PRODUCT_DESC, '')," & _
            " EXTENTED_DESC=isnull(a.EXTENTED_DESC, ''), IsNull(NEW_PRODUCT_DATE,'') as NEW_PRODUCT_DATE " & _
            " from SIEBEL_PRODUCT a left join SIEBEL_PRODUCT_LANG b on a.PRODUCT_ID = b.PRODUCT_ID " & _
            " WHERE PART_NO = '" & model_No & "' ")
        End If


        If Not IsNothing(IMG_Dt) AndAlso IMG_Dt.Rows.Count > 0 Then
            Product_ID = IMG_Dt.Rows(0).Item("PRODUCT_ID").ToString()
            If IMG_Dt.Rows(0).Item("EXTENTED_DESC").ToString() = "" Then
                Product_Desc = IMG_Dt.Rows(0).Item("PRODUCT_DESC").ToString()
            Else
                Product_Desc = IMG_Dt.Rows(0).Item("EXTENTED_DESC").ToString()
            End If
            Dim Image_ID As String = IMG_Dt.Rows(0).Item("TUMBNAIL_IMAGE_ID").ToString()
            'Me.Image_Name = UnzipFileUtil.UnzipLit(Image_ID)
            Me.Image_Name = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" & Image_ID
            'If Not IsNothing(IMG_Dt.Rows(0).Item("NEW_PRODUCT_DATE")) AndAlso _
            'DateDiff(DateInterval.Day, CDate(IMG_Dt.Rows(0).Item("NEW_PRODUCT_DATE")), Now()) >= 0 Then
            '    New_Mark = "<img src='/images/new.gif' alt=''/>"
            'End If
        End If

        Dim roHSObj As Object = dbUtil.dbExecuteScalar("My", _
        " Select IsNull(A.ROHS_STATUS, '') as RoHS " & _
        " from SIEBEL_PRODUCT A, SIEBEL_CATALOG_CATEGORY_PROD B " & _
        " WHERE A.PRODUCT_ID  = B.PRODUCT_ID AND B.CATEGORY_ID = '" & model_ID & "' And " + _
        " (A.STATUS Not In ('I','O','S1','L','V') or A.STATUS is null) " & _
        " And A.PART_NO Not Like '%-BTO' And A.ROHS_STATUS='Y'")
        If Not IsNothing(roHSObj) AndAlso roHSObj.ToString().ToUpper().Trim().Equals("Y") Then
            Me.isRoHSLogo = True
        Else
            Me.isRoHSLogo = False
        End If
    End Sub

    Public Function showRoHSLogo() As Boolean
        Dim roHSObj As Object = dbUtil.dbExecuteScalar("My", _
        " Select IsNull(A.ROHS_STATUS, '') as RoHS " & _
        " from SIEBEL_PRODUCT A, SIEBEL_CATALOG_CATEGORY_PROD B " & _
        " WHERE A.PRODUCT_ID  = B.PRODUCT_ID AND B.CATEGORY_ID = '" & model_ID & "' And " + _
        " (A.STATUS Not In ('I','O','S1','L','V') or A.STATUS is null) " & _
        " And A.PART_NO Not Like '%-BTO' And A.ROHS_STATUS='Y'")
        If Not IsNothing(roHSObj) AndAlso roHSObj.ToString().ToUpper().Trim().Equals("Y") Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Sub FillModelDetail()
        Dim connFeature As System.Data.SqlClient.SqlConnection = Nothing, dbcmdFeature As System.Data.SqlClient.SqlCommand = Nothing
        Dim connDownload As System.Data.SqlClient.SqlConnection = Nothing, dbcmdDownload As System.Data.SqlClient.SqlCommand = Nothing
        Dim connFAQ As System.Data.SqlClient.SqlConnection = Nothing, dbcmdFAQ As System.Data.SqlClient.SqlCommand = Nothing
        Dim connLiterature As System.Data.SqlClient.SqlConnection = Nothing, dbcmdLiterature As System.Data.SqlClient.SqlCommand = Nothing
        Dim connOrderInfo As System.Data.SqlClient.SqlConnection = Nothing, dbcmdOrderInfo As System.Data.SqlClient.SqlCommand = Nothing
        Dim iaFeature As IAsyncResult = Me.getModelFeatureAsync(connFeature, dbcmdFeature)
        Dim iaDownload As IAsyncResult = Me.getModelDownloadAsync(connDownload, dbcmdDownload)
        Dim iaFAQ As IAsyncResult = Me.getModelFAQAsync(connFAQ, dbcmdFAQ)
        Dim iaLiterature As IAsyncResult = Me.getModelLiteratureAsync(connLiterature, dbcmdLiterature)
        Dim iaOrderInfo As IAsyncResult = Me.getModelOrderInfoAsync(connOrderInfo, dbcmdOrderInfo)
        Try
            iaFeature.AsyncWaitHandle.WaitOne()
            iaDownload.AsyncWaitHandle.WaitOne()
            iaFAQ.AsyncWaitHandle.WaitOne()
            iaLiterature.AsyncWaitHandle.WaitOne()
            iaOrderInfo.AsyncWaitHandle.WaitOne()
            Me.dtFeature = dbUtil.Reader2DataTable(dbcmdFeature.EndExecuteReader(iaFeature))
            Me.dtDownload = dbUtil.Reader2DataTable(dbcmdDownload.EndExecuteReader(iaDownload))
            Me.dtFAQ = dbUtil.Reader2DataTable(dbcmdFAQ.EndExecuteReader(iaFAQ))
            Me.dtLiteraure = dbUtil.Reader2DataTable(dbcmdLiterature.EndExecuteReader(iaLiterature))
            Me.dtOrderInfo = dbUtil.Reader2DataTable(dbcmdOrderInfo.EndExecuteReader(iaOrderInfo))
        Catch ex As Exception

        End Try
        connFeature.Close() : connDownload.Close() : connFAQ.Close() : connLiterature.Close() : connOrderInfo.Close()
    End Sub

    Private Function getModelFeatureAsync(ByRef conn As System.Data.SqlClient.SqlConnection, ByRef dbcmd As System.Data.SqlClient.SqlCommand) As IAsyncResult
        Dim featureDt As DataTable = Nothing, strSql As String
        If language = "ENU" Then
            strSql = _
            " Select B.FEATURE_DESC from SIEBEL_PRODUCT A, SIEBEL_PRODUCT_FEATURE B " + _
            " WHERE A.PRODUCT_ID = B.PRODUCT_ID AND A.PART_NO = '" & model_No & "' AND B.LANG_ID IS NULL " + _
            " order by B.FEATURE_SEQ, B.LAST_UPDATED "
        Else
            strSql = _
            " Select B.FEATURE_DESC from SIEBEL_PRODUCT A, SIEBEL_PRODUCT_FEATURE B " & _
            " WHERE A.PRODUCT_ID = B.PRODUCT_ID  AND A.PART_NO = '" & model_No & "' " & _
            " AND B.LANG_ID = '" & language & "' order by B.FEATURE_SEQ, B.LAST_UPDATED "
            featureDt = dbUtil.dbGetDataTable("My", strSql)
            If IsNothing(featureDt) OrElse featureDt.Rows.Count = 0 Then
                strSql = _
                " Select B.FEATURE_DESC from SIEBEL_PRODUCT A, SIEBEL_PRODUCT_FEATURE B " & _
                " WHERE A.PRODUCT_ID = B.PRODUCT_ID AND A.PART_NO = '" & model_No & "' AND B.LANG_ID IS NULL " & _
                " order by B.FEATURE_SEQ, B.LAST_UPDATED "
            End If
        End If
        Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("MY", strSql, conn, dbcmd)
        Return ia
    End Function

    Private Function getModelDownloadAsync(ByRef conn As System.Data.SqlClient.SqlConnection, ByRef dbcmd As System.Data.SqlClient.SqlCommand) As IAsyncResult
        Dim Str_Channel As String = " AND B.PUBLISH_SCOPE='External' "
        Dim strSql As String = _
        " SELECT DISTINCT C_NO='', B.ABSTRACT as Description, A.SR_ID, SEARCH_TYPE as Type, SR_TYPE, UPDATED_DATE as [Date], " & _
        " TOT=" + _
        " (SELECT COUNT(*) FROM SIEBEL_SR_SOLUTION_RELATION X, SIEBEL_SR_SOLUTION_FILE_RELATION Y, SIEBEL_SR_SOLUTION_FILE Z " & _
        " WHERE X.SR_ID=A.SR_ID AND X.SOLUTION_ID=Y.SOLUTION_ID AND Y.FILE_ID=Z.FILE_ID AND Z.PUBLISH_FLAG='Y') " & _
        " FROM SIEBEL_SR_PRODUCT A, SIEBEL_SR_DOWNLOAD B " & _
        " WHERE A.PART_NO LIKE '%" & model_No & "%' AND A.SR_ID=B.SR_ID " & Str_Channel & " AND SR_TYPE='Download' AND B.ABSTRACT<>'' " & _
        " AND B.ABSTRACT IS NOT NULL ORDER BY SEARCH_TYPE "
        Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("MY", strSql, conn, dbcmd)
        Return ia
    End Function

    Private Function getModelFAQAsync(ByRef conn As System.Data.SqlClient.SqlConnection, ByRef dbcmd As System.Data.SqlClient.SqlCommand) As IAsyncResult
        Dim Str_Channel As String = " AND B.PUBLISH_SCOPE like 'External%' "
        Dim strSql As String = _
        " SELECT DISTINCT C_NO='', B.ABSTRACT as Question, A.SR_ID, SEARCH_TYPE, SR_TYPE, UPDATED_DATE as [Date] " & _
        " FROM SIEBEL_SR_PRODUCT A, SIEBEL_SR_DOWNLOAD B, SIEBEL_SR_SOLUTION_RELATION C, SIEBEL_SR_SOLUTION D " & _
        " WHERE A.PART_NO LIKE '%" & model_No & "%' AND A.SR_ID = B.SR_ID " & Str_Channel & _
        " AND SR_TYPE = 'Knowledge Base' AND SEARCH_TYPE='FAQ' AND B.ABSTRACT <> '' " & _
        " AND B.ABSTRACT IS NOT NULL AND B.SR_ID = C.SR_ID AND C.SOLUTION_ID = D.SR_ID " & _
        " AND D.PUBLISH_FLG = 'Y' ORDER BY B.ABSTRACT "
        Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("MY", strSql, conn, dbcmd)
        Return ia
    End Function

    Private Function getModelLiteratureAsync(ByRef conn As System.Data.SqlClient.SqlConnection, ByRef dbcmd As System.Data.SqlClient.SqlCommand) As IAsyncResult
        If Product_ID <> "" And Not IsNothing(Product_ID) Then
            Dim StrOrg As String = "ACL"
            Select Case language
                Case "CHS"
                    StrOrg = "ACN"
                Case "JP"
                    StrOrg = "AJP"
                Case Else
                    StrOrg = "ACL"
            End Select

            Dim OrgString As String = "'ACL','" + StrOrg + "'" ','" + Session("RBU") + "'"

            Dim strSql As String = _
            " select A.LITERATURE_ID, LIT_TYPE as [Literature Type], FILE_NAME as Name, LIT_DESC as Description, " + _
            " FILE_EXT as [File Type], FILE_SIZE as [File Size] " + _
            " from siebel_product_literature a, literature b " + _
            " where product_id = '" + Product_ID + "' " + _
            " and a.literature_id = b.literature_id " + _
            " and b.lit_type not in ('roadmap','sales kits') " + _
            " and b.PRIMARY_LEVEL <> 'RBU' " + _
            " and PRIMARY_ORG_ID IN (" + OrgString + ") " + _
            " and b.LIT_TYPE not in ('Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') " + _
            " order by LIT_TYPE,LAST_UPDATED DESC "
            Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("MY", strSql, conn, dbcmd)
            Return ia
        Else
            If String.Join(",", arrPartNo.ToArray()) <> "" Then
                Dim strSql As String = "select LIT_ID as LITERATURE_ID, LIT_TYPE as [Literature Type], FILE_NAME as Name, PRODUCT_DESC as Description, FILE_EXT as [File Type], FILE_SIZE as [File Size] from SIEBEL_LITERATURE where PART_NO in (" + String.Join(",", arrPartNo.ToArray()) + ")"
                'Util.SendEmail("rudy.wang@advantech.com.tw", "eBiz.AEU@advantech.eu", "sql", strSql, True, "", "")
                Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("RFM", strSql, conn, dbcmd)
                Return ia
            Else
                Dim strSql As String = "select LIT_ID as LITERATURE_ID, LIT_TYPE as [Literature Type], FILE_NAME as Name, PRODUCT_DESC as Description, FILE_EXT as [File Type], FILE_SIZE as [File Size] from SIEBEL_LITERATURE where PART_NO =''"
                'Util.SendEmail("rudy.wang@advantech.com.tw", "eBiz.AEU@advantech.eu", "sql", strSql, True, "", "")
                Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("RFM", strSql, conn, dbcmd)
                Return ia
            End If
        End If
    End Function

    Private Function getModelOrderInfoAsync(ByRef conn As System.Data.SqlClient.SqlConnection, ByRef dbcmd As System.Data.SqlClient.SqlCommand) As IAsyncResult
        Dim strSql As String
        'If model_ID <> "" And Not IsNothing(model_ID) Then
        '    If language = "ENU" Then
        '        strSql = _
        '        " Select isnull(A.PART_NO,'') as PART_NO, A.PRODUCT_DESC as Description1, " + _
        '        " PRODUCT_DESC2 as Description2, isnull(A.ROHS_STATUS,0) as RoHS, '' as Currency, '' as list_price, '' as unit_price " + _
        '        " from SIEBEL_PRODUCT A,SIEBEL_CATALOG_CATEGORY_PROD B " + _
        '        " WHERE A.PRODUCT_ID  = B.PRODUCT_ID  " + _
        '        " AND B.CATEGORY_ID = '" + model_ID + "'  " + _
        '        " And (A.STATUS Not In ('I','O','S1','L','V')) " + _
        '        " And A.PART_NO Not Like '%-BTO' " + _
        '        " ORDER BY A.PART_NO "
        '    End If
        '    'Util.SendEmail("rudy.wang@advantech.com.tw", "eBiz.AEU@advantech.eu", "sql", strSql, True, "", "")
        '    Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("MY", strSql, conn, dbcmd)
        '    Return ia
        'Else
        Try
            'Util.SendEmail("rudy.wang@advantech.com.tw", "eBiz.AEU@advantech.eu", "array", String.Join(",", arrPartNo.ToArray()), True, "", "")
            If String.Join(",", arrPartNo.ToArray()) <> "" Then
                strSql = String.Format("select a.PART_NO, isnull(a.PRODUCT_DESC,'') as Description1, '' as Description2, a.ROHS_FLAG as RoHS, '' as Currency, '' as list_price, '' as unit_price from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO where a.part_no in ({0}) and b.ORG_ID='{1}' and a.PART_NO Not Like '%-BTO' and (a.STATUS In ('A','N','H','M1')) ORDER BY a.PART_NO", String.Join(",", arrPartNo.ToArray()), IIf(Not IsNothing(HttpContext.Current.Session("org_id")), HttpContext.Current.Session("org_id"), "EU10"))
                'Util.SendEmail("rudy.wang@advantech.com.tw", "eBiz.AEU@advantech.eu", "sql", strSql, True, "", "")
                Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("B2B", strSql, conn, dbcmd)
                Return ia
            Else
                strSql = String.Format("select a.PART_NO, isnull(a.PRODUCT_DESC,'') as Description1, '' as Description2, a.ROHS_FLAG as RoHS, '' as Currency, '' as list_price, '' as unit_price from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO where a.part_no ='' and b.ORG_ID='{0}' and a.PART_NO Not Like '%-BTO' and (a.STATUS In ('A','N','H','M1')) ORDER BY a.PART_NO", IIf(Not IsNothing(HttpContext.Current.Session("org_id")), HttpContext.Current.Session("org_id"), "EU10"))
                'Util.SendEmail("rudy.wang@advantech.com.tw", "eBiz.AEU@advantech.eu", "sql", strSql, True, "", "")
                Dim ia As IAsyncResult = dbUtil.dbGetReaderAsync("B2B", strSql, conn, dbcmd)
                Return ia
            End If
        Catch ex As Exception
            'Util.SendEmail("rudy.wang@advantech.com.tw", "ebiz.aeu@advantech.eu", "Model OrderInfo Error", ex.tostring, True, "", "")
        End Try
        'End If
    End Function

    Public Sub FillModelFeature()
        Dim conn As System.Data.SqlClient.SqlConnection = Nothing, dbcmd As System.Data.SqlClient.SqlCommand = Nothing
        Dim ia As IAsyncResult = Me.getModelFeatureAsync(conn, dbcmd)
        ia.AsyncWaitHandle.WaitOne()
        Me.dtFeature = dbUtil.Reader2DataTable(dbcmd.EndExecuteReader(ia))
        conn.Close()
    End Sub

    Public Sub FillModelDownload()
        Dim conn As System.Data.SqlClient.SqlConnection = Nothing, dbcmd As System.Data.SqlClient.SqlCommand = Nothing
        Dim ia As IAsyncResult = Me.getModelDownloadAsync(conn, dbcmd)
        ia.AsyncWaitHandle.WaitOne()
        Me.dtDownload = dbUtil.Reader2DataTable(dbcmd.EndExecuteReader(ia))
        conn.Close()
    End Sub

    Public Sub FillModelFAQ()
        Dim conn As System.Data.SqlClient.SqlConnection = Nothing, dbcmd As System.Data.SqlClient.SqlCommand = Nothing
        Dim ia As IAsyncResult = Me.getModelFAQAsync(conn, dbcmd)
        ia.AsyncWaitHandle.WaitOne()
        Me.dtFAQ = dbUtil.Reader2DataTable(dbcmd.EndExecuteReader(ia))
        conn.Close()
    End Sub

    Public Sub FillModelLiterature()
        Dim conn As System.Data.SqlClient.SqlConnection = Nothing, dbcmd As System.Data.SqlClient.SqlCommand = Nothing
        Dim ia As IAsyncResult = Me.getModelLiteratureAsync(conn, dbcmd)
        ia.AsyncWaitHandle.WaitOne()
        Me.dtLiteraure = dbUtil.Reader2DataTable(dbcmd.EndExecuteReader(ia))
        conn.Close()
    End Sub

    Public Sub FillModelOrderInfo()
        Dim conn As System.Data.SqlClient.SqlConnection = Nothing, dbcmd As System.Data.SqlClient.SqlCommand = Nothing
        Dim ia As IAsyncResult = Me.getModelOrderInfoAsync(conn, dbcmd)
        ia.AsyncWaitHandle.WaitOne()
        Me.dtOrderInfo = dbUtil.Reader2DataTable(dbcmd.EndExecuteReader(ia))
        conn.Close()
    End Sub
End Class

<System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="eBizAEU")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class ModelUtilService
    Inherits System.Web.Services.WebService
    Public model_ID As String, model_No As String, language As String = "ENU", Product_ID As String
    Public strDtFeature As String, strDtDownload As String, strDtLiterature As String, strDtFAQ As String, strDtOrderInfo As String

    <WebMethod()> _
    Public Sub SetProductInfo(ByVal model_id As String, ByVal model_no As String, ByRef product_line As String, ByRef product_desc As String, _
                              ByRef image_name As String, ByRef model_intro As String, ByRef isRoHSLogo As Boolean, ByRef model_feature As String, _
                              ByRef model_lit As String, ByRef model_download As String, ByRef model_faq As String, ByRef model_orderInfo As String)
        If model_id = "" And model_no = "" Then
            'HttpContext.Current.Response.Redirect("/Order/Product_Search.aspx")
            'Throw New Exception("please provide at least model id")
        End If
        If model_id = "" And model_no <> "" Then
            Me.model_No = model_no
            Me.setModelID()
        End If
        If model_id <> "" And model_no = "" Then
            Me.model_ID = model_id
            Me.setModelNo()
        End If
        If model_no <> "" And model_id <> "" Then
            Me.model_ID = model_id : Me.model_No = model_no
        End If
        'Me.language = HttpContext.Current.Session("lang_id")
        If Not IsNothing(Me.model_ID) Then
            setModelInfo(product_line, product_desc, image_name, model_intro, isRoHSLogo)
            Dim t1 As New Thread(AddressOf setModelFeature), t2 As New Thread(AddressOf setModelLiterature), t3 As New Thread(AddressOf setModelFAQ)
            Dim t4 As New Thread(AddressOf setModelDownload), t5 As New Thread(AddressOf setModelOrderInfo)
            t1.Start() : t2.Start() : t3.Start() : t4.Start() : t5.Start()
            t1.Join() : t2.Join() : t3.Join() : t4.Join() : t5.Join()
        End If
        model_feature = strDtFeature : model_lit = strDtLiterature : model_faq = strDtFAQ : model_download = strDtDownload : model_orderInfo = strDtOrderInfo
    End Sub

    Public Sub setModelFeature()
        Dim featureDt As DataTable = Nothing, strSql As String
        If language = "ENU" Then
            strSql = _
            " Select B.FEATURE_DESC from SIEBEL_PRODUCT A, SIEBEL_PRODUCT_FEATURE B " + _
            " WHERE A.PRODUCT_ID = B.PRODUCT_ID AND A.PART_NO = '" & model_No & "' AND B.LANG_ID IS NULL " + _
            " order by B.FEATURE_SEQ, B.LAST_UPDATED "
        Else
            strSql = _
            " Select B.FEATURE_DESC from SIEBEL_PRODUCT A, SIEBEL_PRODUCT_FEATURE B " & _
            " WHERE A.PRODUCT_ID = B.PRODUCT_ID  AND A.PART_NO = '" & model_No & "' " & _
            " AND B.LANG_ID = '" & language & "' order by B.FEATURE_SEQ, B.LAST_UPDATED "
            featureDt = dbUtil.dbGetDataTable("My", strSql)
            If IsNothing(featureDt) OrElse featureDt.Rows.Count = 0 Then
                strSql = _
                " Select B.FEATURE_DESC from SIEBEL_PRODUCT A, SIEBEL_PRODUCT_FEATURE B " & _
                " WHERE A.PRODUCT_ID = B.PRODUCT_ID AND A.PART_NO = '" & model_No & "' AND B.LANG_ID IS NULL " & _
                " order by B.FEATURE_SEQ, B.LAST_UPDATED "
            End If
        End If
        strDtFeature = Util.DataTableToXml(dbUtil.dbGetDataTable("My", strSql))
    End Sub

    Public Sub setModelLiterature()
        Dim StrOrg As String = "ACL"
        Select Case language
            Case "CHS"
                StrOrg = "ACN"
            Case "JP"
                StrOrg = "AJP"
            Case Else
                StrOrg = "ACL"
        End Select

        Dim OrgString As String = "'ACL','" + StrOrg + "'" ','" + Session("RBU") + "'"

        Dim strSql As String = _
        " select A.LITERATURE_ID, LIT_TYPE as [Literature Type], FILE_NAME as Name, LIT_DESC as Description, " + _
        " FILE_EXT as [File Type], FILE_SIZE as [File Size] " + _
        " from siebel_product_literature a, literature b " + _
        " where product_id = '" + Product_ID + "' " + _
        " and a.literature_id = b.literature_id " + _
        " and b.lit_type not in ('roadmap','sales kits') " + _
        " and b.PRIMARY_LEVEL <> 'RBU' " + _
        " and PRIMARY_ORG_ID IN (" + OrgString + ") " + _
        " and b.LIT_TYPE not in ('Market Intellegence', 'Product - Roadmap','Corporate - Strategy','Product - Sales Kit','Market Intelligence') " + _
        " order by LIT_TYPE,LAST_UPDATED DESC "
        strDtLiterature = Util.DataTableToXml(dbUtil.dbGetDataTable("My", strSql))
    End Sub

    Public Sub setModelFAQ()
        Dim Str_Channel As String = " AND B.PUBLISH_SCOPE like 'External%' "
        Dim strSql As String = _
        " SELECT DISTINCT C_NO='',A.PART_NO, B.ABSTRACT as Question, A.SR_ID, SEARCH_TYPE, SR_TYPE, UPDATED_DATE as [Date] " & _
        " FROM SIEBEL_SR_PRODUCT A, SIEBEL_SR_DOWNLOAD B, SIEBEL_SR_SOLUTION_RELATION C, SIEBEL_SR_SOLUTION D " & _
        " WHERE A.PART_NO LIKE '%" & model_No & "%' AND A.SR_ID = B.SR_ID " & Str_Channel & _
        " AND SR_TYPE = 'Knowledge Base' AND SEARCH_TYPE='FAQ' AND B.ABSTRACT <> '' " & _
        " AND B.ABSTRACT IS NOT NULL AND B.SR_ID = C.SR_ID AND C.SOLUTION_ID = D.SOLUTION_ID " & _
        " AND D.PUBLISH_FLAG = 'Y' ORDER BY A.PART_NO "
        strDtFAQ = Util.DataTableToXml(dbUtil.dbGetDataTable("My", strSql))
    End Sub

    Public Sub setModelDownload()
        Dim Str_Channel As String = " AND B.PUBLISH_SCOPE='External' "
        Dim strSql As String = _
        " SELECT DISTINCT C_NO='', B.ABSTRACT as Description, A.SR_ID, SEARCH_TYPE as Type, SR_TYPE, UPDATED_DATE as [Date], " & _
        " TOT=" + _
        " (SELECT COUNT(*) FROM SIEBEL_SR_SOLUTION_RELATION X, SIEBEL_SR_SOLUTION_FILE_RELATION Y, SIEBEL_SR_SOLUTION_FILE Z " & _
        " WHERE X.SR_ID=A.SR_ID AND X.SOLUTION_ID=Y.SOLUTION_ID AND Y.FILE_ID=Z.FILE_ID AND Z.PUBLISH_FLAG='Y') " & _
        " FROM SIEBEL_SR_PRODUCT A, SIEBEL_SR_DOWNLOAD B " & _
        " WHERE A.PART_NO LIKE '%" & model_No & "%' AND A.SR_ID=B.SR_ID " & Str_Channel & " AND SR_TYPE='Download' AND B.ABSTRACT<>'' " & _
        " AND B.ABSTRACT IS NOT NULL ORDER BY SEARCH_TYPE "
        strDtDownload = Util.DataTableToXml(dbUtil.dbGetDataTable("My", strSql))
    End Sub

    Public Sub setModelOrderInfo()
        Dim strSql As String
        If language = "ENU" Then
            strSql = _
            " Select A.PART_NO, isnull(A.PRODUCT_DESC,'') as Description1, " + _
            " isnull(PRODUCT_DESC2,'') as Description2, isnull(A.ROHS_STATUS,'') as RoHS, '' as Currency, '' as list_price, '' as unit_price " + _
            " from SIEBEL_PRODUCT A,SIEBEL_CATALOG_CATEGORY_PROD B " + _
            " WHERE A.PRODUCT_ID  = B.PRODUCT_ID  " + _
            " AND B.CATEGORY_ID = '" + model_ID + "'  " + _
            " And (A.STATUS Not In ('I','O','S1','L','V') or A.STATUS is null) " + _
            " And A.PART_NO Not Like '%-BTO' " + _
            " ORDER BY A.PART_NO "
        Else
            strSql = _
             " Select A.PART_NO, isnull(A.PRODUCT_DESC,'') as Description1, " + _
             " isnull(PRODUCT_DESC2,'') as Description2, isnull(A.ROHS_STATUS,'') as RoHS, '' as Currency, '' as list_price, '' as unit_price " + _
             " from SIEBEL_PRODUCT A,SIEBEL_CATALOG_CATEGORY_PROD B " + _
             " WHERE A.PRODUCT_ID  = B.PRODUCT_ID  " + _
             " AND B.CATEGORY_ID = '" + model_ID + "'  " + _
             " And (A.STATUS Not In ('I','O','S1','L','V') or A.STATUS is null) " + _
             " And A.PART_NO Not Like '%-BTO' " + _
             " ORDER BY B.SEQ_NUM "
        End If
        strDtOrderInfo = Util.DataTableToXml(dbUtil.dbGetDataTable("My", strSql))
    End Sub

    Private Sub setModelID()
        Dim obj As Object = dbUtil.dbExecuteScalar("My", _
            " SELECT CATEGORY_ID FROM SIEBEL_CATALOG_CATEGORY WHERE DISPLAY_NAME = '" + model_No + "' " + _
            " AND catalog_Id in (SELECT CATALOG_ID FROM CATALOG_SHOW)")
        If IsNothing(obj) Then
            obj = dbUtil.dbExecuteScalar("My", " SELECT CATEGORY_ID FROM SIEBEL_CATALOG_CATEGORY WHERE DISPLAY_NAME = '" + model_No + "'")
        End If
        If Not IsNothing(obj) Then
            model_ID = obj.ToString()
        Else
            model_ID = ""
        End If
    End Sub

    Private Sub setModelNo()
        Dim DNDt As DataTable = dbUtil.dbGetDataTable("My", _
            " SELECT IsNull(DISPLAY_NAME, '') as DISPLAY_NAME " + _
            " FROM SIEBEL_CATALOG_CATEGORY WHERE CATEGORY_ID = '" + model_ID + "' " + _
            " AND catalog_Id in (SELECT CATALOG_ID FROM CATALOG_SHOW)")
        If Not IsNothing(DNDt) AndAlso DNDt.Rows.Count > 0 Then
            model_No = DNDt.Rows(0).Item("DISPLAY_NAME").ToString()
        End If
    End Sub

    Private Sub setModelInfo(ByRef product_line As String, ByRef product_desc As String, ByRef image_name As String, ByRef model_intro As String, _
                             ByRef isRoHSLogo As Boolean)
        Dim strSql As String
        If language = "ENU" Then
            strSql = _
            "Select CATALOG_ID,CATEGORY_ID,CATEGORY_NAME, " + _
            "DISPLAY_NAME, CATEGORY_DESC, IsNull(EXTENDED_DESC, '') as EXTENDED_DESC, IMAGE_ID, PARENT_CATEGORY_ID " + _
            "From SIEBEL_CATALOG_CATEGORY Where CATEGORY_ID = '" + model_ID + "'"
        Else
            strSql = _
            " Select a.CATALOG_ID,a.CATEGORY_ID,CATEGORY_NAME," & _
            " DISPLAY_NAME  = isnull(b.DISPLAY_NAME,a.DISPLAY_NAME)," & _
            " CATEGORY_DESC = isnull(b.CATEGORY_DESC,a.CATEGORY_DESC)," & _
            " EXTENDED_DESC = isnull(b.EXTENDED_DESC,a.EXTENDED_DESC)," & _
            " IMAGE_ID,PARENT_CATEGORY_ID " & _
            " From SIEBEL_CATALOG_CATEGORY a left join SIEBEL_CATALOG_CATEGORY_LANG b on a.CATEGORY_ID = b.CATEGORY_ID " & _
            " Where a.CATEGORY_ID  = '" & model_ID & "' " + _
            " and b.LANG_ID  = '" & language & "' "
        End If

        Dim dt As DataTable = dbUtil.dbGetDataTable("My", strSql)
        Dim parent_id As String = ""
        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            'StrCatalogID = dt.Rows(0).Item("CATALOG_ID").ToString()
            product_line = dt.Rows(0).Item("DISPLAY_NAME") : model_No = dt.Rows(0).Item("DISPLAY_NAME")
            'extended_desc = dt.Rows(0).Item("EXTENDED_DESC").ToString()
            parent_id = dt.Rows(0).Item("PARENT_CATEGORY_ID").ToString()
        Else
            'HttpContext.Current.Response.Redirect("/Order/Product_Search.aspx")
            Throw New Exception("Model not found with model_ID : " + model_ID + "and model_NO : " + model_No)
        End If

        'Frank 2012/01/17 shift ProductCategoryUtil to ProductCategoryUtil_PIS
        'ProductCategoryUtil.getHierarchyProductLine(parent_id, product_line)
        ProductCategoryUtil_PIS.getHierarchyProductLine(parent_id, product_line)
        model_intro = dt.Rows(0).Item("extended_desc").ToString()

        Dim IMG_Dt As DataTable = _
        dbUtil.dbGetDataTable("My", _
        " Select a.PRODUCT_ID, TUMBNAIL_IMAGE_ID, PRODUCT_DESC=isnull(a.PRODUCT_DESC, ''), " & _
        " EXTENTED_DESC=isnull(a.EXTENTED_DESC, ''), IsNull(NEW_PRODUCT_DATE,'') as NEW_PRODUCT_DATE " & _
        " from SIEBEL_PRODUCT a, SIEBEL_PRODUCT_LANG b " & _
        " WHERE PART_NO = '" & model_No & "' AND a.PRODUCT_ID = b.PRODUCT_ID " + _
        IIf(language <> "", " and B.LANG_ID='" + language + "'", " ").ToString())

        If IsNothing(IMG_Dt) OrElse IMG_Dt.Rows.Count = 0 Then
            IMG_Dt = _
            dbUtil.dbGetDataTable("My", _
            " Select a.PRODUCT_ID, IsNull(TUMBNAIL_IMAGE_ID, '') as TUMBNAIL_IMAGE_ID, PRODUCT_DESC=isnull(a.PRODUCT_DESC, '')," & _
            " EXTENTED_DESC=isnull(a.EXTENTED_DESC, ''), IsNull(NEW_PRODUCT_DATE,'') as NEW_PRODUCT_DATE " & _
            " from SIEBEL_PRODUCT a left join SIEBEL_PRODUCT_LANG b on a.PRODUCT_ID = b.PRODUCT_ID " & _
            " WHERE PART_NO = '" & model_No & "' ")
        End If

        If Not IsNothing(IMG_Dt) AndAlso IMG_Dt.Rows.Count > 0 Then
            Product_ID = IMG_Dt.Rows(0).Item("PRODUCT_ID").ToString()
            If IMG_Dt.Rows(0).Item("EXTENTED_DESC").ToString() = "" Then
                product_desc = IMG_Dt.Rows(0).Item("PRODUCT_DESC").ToString()
            Else
                product_desc = IMG_Dt.Rows(0).Item("EXTENTED_DESC").ToString()
            End If
            Dim Image_ID As String = IMG_Dt.Rows(0).Item("TUMBNAIL_IMAGE_ID").ToString()
            image_name = UnzipFileUtil.UnzipLit(Image_ID)
            'If Not IsNothing(IMG_Dt.Rows(0).Item("NEW_PRODUCT_DATE")) AndAlso _
            'DateDiff(DateInterval.Day, CDate(IMG_Dt.Rows(0).Item("NEW_PRODUCT_DATE")), Now()) >= 0 Then
            '    New_Mark = "<img src='/images/new.gif' alt=''/>"
            'End If
        End If

        Dim roHSObj As Object = dbUtil.dbExecuteScalar("My", _
        " Select IsNull(A.ROHS_STATUS, '') as RoHS " & _
        " from SIEBEL_PRODUCT A, SIEBEL_CATALOG_CATEGORY_PROD B " & _
        " WHERE A.PRODUCT_ID  = B.PRODUCT_ID AND B.CATEGORY_ID = '" & model_ID & "' And " + _
        " (A.STATUS Not In ('I','O','S1','L','V') or A.STATUS is null) " & _
        " And A.PART_NO Not Like '%-BTO' And A.ROHS_STATUS='Y'")
        If Not IsNothing(roHSObj) AndAlso roHSObj.ToString().ToUpper().Trim().Equals("Y") Then
            isRoHSLogo = True
        Else
            isRoHSLogo = False
        End If
    End Sub
End Class
Public Class PISDAL

    Enum CurrentProductItemType
        category = 0
        model = 1
        other = -1
    End Enum

    ''' <summary>
    ''' Getting navigate path of current category or model
    ''' </summary>
    ''' <param name="_ItemType"> Enum CurrentProductItemType</param>
    ''' <param name="_ItemID">CategoryID or ModelID</param>
    ''' <returns>if _ItemType=CurrentProductItemType.other then return ""</returns>
    ''' <remarks></remarks>
    Public Shared Function GetCurrentProductNavigatePath(ByVal _ItemType As CurrentProductItemType, ByVal _ItemID As String, Optional _Model_ParentCategoryID As String = "") As String

        If _ItemType = CurrentProductItemType.other Then Return ""

        Dim _ReturnStr As New StringBuilder
        Dim _SQL As New StringBuilder

        _SQL.AppendLine("SELECT top 1")
        _SQL.AppendLine(" model_no")
        _SQL.AppendLine(", parent_category_id1, category_name1, category_type1")
        _SQL.AppendLine(", parent_category_id2, category_name2, category_type2")
        _SQL.AppendLine(", parent_category_id3, category_name3, category_type3")
        _SQL.AppendLine(", parent_category_id4, category_name4, category_type4")
        _SQL.AppendLine(", parent_category_id5, category_name5, category_type5")
        _SQL.AppendLine(", parent_category_id6, category_name6, category_type6")
        _SQL.AppendLine(" FROM CATEGORY_HIERARCHY")
        _SQL.AppendLine(" Where")
        Select Case _ItemType
            Case CurrentProductItemType.category
                _SQL.AppendLine(" parent_category_id1=@ItemID")
                _SQL.AppendLine(" or parent_category_id2=@ItemID ")
                _SQL.AppendLine(" or parent_category_id3=@ItemID ")
                _SQL.AppendLine(" or parent_category_id4=@ItemID ")
                _SQL.AppendLine(" or parent_category_id5=@ItemID ")
                _SQL.AppendLine(" or parent_category_id6=@ItemID ")
            Case Else
                _SQL.AppendLine(" model_no =@ItemID")
                If Not String.IsNullOrEmpty(_Model_ParentCategoryID) Then
                    _SQL.AppendLine(" And parent_category_id1=@Model_ParentCategoryID")
                End If
        End Select

        Dim mdt As New DataTable("Category_hierarchy")

        Dim _conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("PIS").ConnectionString)
        _conn.Open()
        Dim apt As New SqlClient.SqlDataAdapter(_SQL.ToString, _conn)
        apt.SelectCommand.Parameters.AddWithValue("@ItemID", _ItemID)

        If _ItemType = CurrentProductItemType.model AndAlso (Not String.IsNullOrEmpty(_Model_ParentCategoryID)) Then
            apt.SelectCommand.Parameters.AddWithValue("@Model_ParentCategoryID", _Model_ParentCategoryID)
        End If

        apt.Fill(mdt)
        _conn.Close()
        _SQL = Nothing

        If mdt IsNot Nothing AndAlso mdt.Rows.Count > 0 Then

            Dim mAry As New ArrayList

            Dim _i_startindex As Integer = 1
            Dim _isEqualsClickCategoryID As Boolean = False
            'Dim _RuntimeSiteUrl As String = Util.GetRuntimeSiteUrl
            Dim _Current_parent_category_id As String = String.Empty
            Dim _Current_category_type As String = String.Empty
            Dim _Current_category_name As String = String.Empty

            'put link item into array
            With mdt.Rows(0)
                For i As Integer = _i_startindex To 6

                    _Current_parent_category_id = .Item("parent_category_id" + i.ToString()).ToString
                    _Current_category_type = .Item("category_type" + i.ToString()).ToString
                    _Current_category_name = .Item("category_name" + i.ToString()).ToString

                    If _ItemType = CurrentProductItemType.category And _isEqualsClickCategoryID = False Then
                        If _Current_parent_category_id <> _ItemID Then
                            Continue For
                        Else
                            _isEqualsClickCategoryID = True
                        End If
                    End If


                    If String.IsNullOrEmpty(_Current_parent_category_id) = False AndAlso _Current_parent_category_id <> "root" Then

                        Select Case _Current_category_type.ToLower

                            Case "category", "subcategory"
                                If i = 1 Then
                                    'mAry.Add(GetNavigateItemLink("Model_Master", _Current_parent_category_id, _Current_category_name))
                                    mAry.Add(GetNavigateItemLink(CurrentProductItemType.model, _Current_parent_category_id, _Current_category_name))
                                Else
                                    'mAry.Add(GetNavigateItemLink("SubCategory", _Current_parent_category_id, _Current_category_name))
                                    mAry.Add(GetNavigateItemLink(CurrentProductItemType.category, _Current_parent_category_id, _Current_category_name))
                                End If

                            Case ""
                                mAry.Add(GetNavigateItemLink(CurrentProductItemType.other, "", _Current_category_name))
                        End Select

                    Else
                        If String.IsNullOrEmpty(_Current_parent_category_id) = False AndAlso _Current_parent_category_id = "root" Then
                            mAry.Add(GetNavigateItemLink(CurrentProductItemType.other, "", "Product Lines"))
                            Exit For
                        End If
                    End If
                Next

            End With

            'Generating link string
            If mAry.Count > 0 Then
                For i As Integer = 0 To mAry.Count - 1
                    _ReturnStr.Append(mAry.Item(mAry.Count - i - 1))
                    If i < mAry.Count - 1 Then
                        _ReturnStr.Append(" > ")
                    End If
                Next
            End If

        End If

        Return _ReturnStr.ToString

    End Function

    ''' <summary>
    ''' Get Navigate Item Link String
    ''' </summary>
    ''' <param name="ItemType">CurrentProductItemType</param>
    ''' <param name="category_id">category_id</param>
    ''' <param name="category_name">category display name</param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Private Shared Function GetNavigateItemLink(ByVal ItemType As CurrentProductItemType, ByVal category_id As String, ByVal category_name As String) As String

        Dim _RuntimeSiteUrl As String = Util.GetRuntimeSiteUrl
        Dim returnstr As String = ""
        Select Case ItemType
            'Case "model_master"
            Case CurrentProductItemType.model
                returnstr = String.Format("<a href='" & _RuntimeSiteUrl & "/Product/Model_Master.aspx?category_id={0}'>{1}</a>", _
                                                      category_id, category_name)
                'Case "subcategory"
            Case CurrentProductItemType.category
                returnstr = String.Format("<a href='" & _RuntimeSiteUrl & "/Product/SubCategory.aspx?category_id={0}'>{1}</a>", _
                                                      category_id, category_name)
            Case Else
                returnstr = String.Format("<a href='" & _RuntimeSiteUrl & "/Product/Product_Line_New.aspx'>{0}</a>", category_name)

        End Select
        Return returnstr
    End Function




    Public Shared Function GetModelByPartNo(ByVal PN As String) As DataTable
        Dim _SQL As String = String.Empty
        _SQL &= "Select a.model_name,a.part_no,b.Site_ID,b.Active_FLG"
        _SQL &= " From model_product a left join Model_Publish b"
        _SQL &= " on a.model_name=b.Model_name"
        _SQL &= " where a.part_no=@PN "
        _SQL &= " And b.active_flg='Y'"
        _SQL &= " And b.Site_ID='ACL'"
        _SQL &= " Group by a.model_name,a.part_no,b.Site_ID,b.Active_FLG"
        Dim apt As New SqlClient.SqlDataAdapter(_SQL, ConfigurationManager.ConnectionStrings("PIS").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("PN", PN)
        Dim _dt As New DataTable
        apt.Fill(_dt)
        apt.SelectCommand.Connection.Close()
        Return _dt
    End Function
End Class

Public Class ProductCategoryUtil_PIS
    Public Shared language As String = "ENU"
    Public Product_Line As String, DisplayName As String, Extended_Desc As String, Image_Name As String, Category_Type As String
    Public dtContent As DataTable

    Sub New(ByVal Category_ID As String)
        'language = HttpContext.Current.Session("lang_id")
        Dim sql As String = ""
        If language = "ENU" Then
            sql = "Select isnull(A.CATEGORY_ID,'') as CATEGORY_ID, " + _
                " isnull(A.CATEGORY_NAME,'') as CATEGORY_NAME,isnull(A.CATEGORY_TYPE,'') as CATEGORY_TYPE, " + _
                " isnull(A.PARENT_CATEGORY_ID,'') as PARENT_CATEGORY_ID,isnull(A.DISPLAY_NAME,'') as DISPLAY_NAME, " + _
                " IsNull(A.EXTENDED_DESC,'') as EXTENDED_DESC,isnull(A.IMAGE_ID,'') as IMAGE_ID, " & _
            " CNT = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID " + _
            " AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y')" & _
            "  From v_SIEBEL_CATALOG_CATEGORY A " & _
            " Where CATEGORY_ID = '" & Category_ID.Replace("'", "''") & "' "

        Else
            'sql = "Select a.CATALOG_ID,a.CATEGORY_ID,CATEGORY_NAME,CATEGORY_TYPE," & _
            '  "       PARENT_CATEGORY_ID,DISPLAY_NAME=isnull(b.DISPLAY_NAME,a.DISPLAY_NAME)," & _
            '  "       EXTENDED_DESC=isnull(b.EXTENDED_DESC,a.EXTENDED_DESC),IMAGE_ID, " & _
            '  "       CNT = (SELECT COUNT(*) FROM SIEBEL_CATALOG_CATEGORY C WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y') " & _
            '  "  From v_SIEBEL_CATALOG_CATEGORY a left join v_SIEBEL_CATALOG_CATEGORY_LANG b" & _
            '  "   on a.CATEGORY_ID = b.CATEGORY_ID " & _
            '  " Where a.CATEGORY_ID  = '" & Category_ID.Replace("'", "''") & "' " & _
            '  "   and b.LANG_ID      = '" & language & "' "
        End If

        Dim Parent_Id = "", Catalog_Id = ""
        Dim Rs_Category As DataTable = dbUtil.dbGetDataTable("PIS", sql)
        If Not IsNothing(Rs_Category) And Rs_Category.Rows.Count > 0 Then
            Me.Product_Line = Rs_Category.Rows(0).Item("DISPLAY_NAME").ToString()
            Parent_Id = Rs_Category.Rows(0).Item("PARENT_CATEGORY_ID").ToString()
            'Catalog_Id = Rs_Category.Rows(0).Item("CATALOG_ID").ToString()
            Me.DisplayName = Rs_Category.Rows(0).Item("DISPLAY_NAME").ToString()
            Me.Category_Type = Rs_Category.Rows(0).Item("CATEGORY_TYPE").ToString()

            If Not IsDBNull(Rs_Category.Rows(0).Item("IMAGE_ID")) Then
                Me.Image_Name = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + Rs_Category.Rows(0).Item("IMAGE_ID")
            End If

            Me.Extended_Desc = Rs_Category.Rows(0).Item("EXTENDED_DESC").ToString()
        Else
            Throw New Exception("Category Not Found")
        End If
        'getHierarchyProductLine(Parent_Id, Product_Line)

        If Rs_Category.Rows(0).Item("CNT") > 0 Then
            If language = "ENU" Then
                'Frank 2012/01/11 not use this sql command because query proformance is no good.
                'sql = "Select distinct A.CATEGORY_ID, isnull(A.CATEGORY_NAME,'') as CATEGORY_NAME, " + _
                '    " isnull(A.CATEGORY_TYPE,'') as CATEGORY_TYPE,isnull(DISPLAY_NAME,'') as DISPLAY_NAME," + _
                '    " IsNull(A.EXTENDED_DESC,'') as EXTENDED_DESC,IsNull(c.PRODUCT_DESC,'') as PRODUCT_DESC, " + _
                '    " IsNull(a.IMAGE_ID,'') as IMAGE_ID,isnull(SEQ_NO,'') as SEQ_NO,c.NEW_PRODUCT_DATE " & _
                '      "       ,CNT = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B " + _
                '      " WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y') " & _
                '          "       ,CNT1 = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B " + _
                '        " WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Model') And ACTIVE_FLG = 'Y') " + _
                '      "  From v_SIEBEL_CATALOG_CATEGORY A left join v_SIEBEL_PRODUCT c on a.DISPLAY_NAME = c.PART_NO " & _
                '      " Where PARENT_CATEGORY_ID = '" & Category_ID & "' " & _
                '      "   And CATEGORY_TYPE in ('Category','SubCategory') " & _
                '      "   And ACTIVE_FLG = 'Y' " & _
                '      "  Order by SEQ_NO,DISPLAY_NAME"

                'Frank 2012/01/11
                'To change query pis data from view to table for improving performance.
                sql = "Select a.CATEGORY_ID,isnull(A.CATEGORY_NAME,'') as CATEGORY_NAME,isnull(A.CATEGORY_TYPE,'') as CATEGORY_TYPE,isnull(DISPLAY_NAME,'') as DISPLAY_NAME," + _
                    "IsNull(A.EXTENDED_DESC,'') as EXTENDED_DESC, isnull(SEQ_NO,'') as SEQ_NO, b.LITERATURE_ID as IMAGE_ID" + _
                    ",CNT = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y')" + _
                    ",CNT1 = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Model') And ACTIVE_FLG = 'Y')" + _
                    " From CATEGORY a inner join CATEGORY_LIT b on a.CATEGORY_ID = b.CATEGORY_ID" + _
                    " Where a.PARENT_CATEGORY_ID='" & Category_ID & "'" + _
                      "  And a.ACTIVE_FLG='Y'" + _
                      "  Order by SEQ_NO"


            Else
                'sql = "Select A.CATEGORY_ID,CATEGORY_NAME,CATEGORY_TYPE," & _
                '      "       DISPLAY_NAME=isnull(b.DISPLAY_NAME,a.DISPLAY_NAME), " & _
                '      "       EXTENDED_DESC=isnull(b.EXTENDED_DESC,a.EXTENDED_DESC)," & _
                '      "       IsNull(IMAGE_ID,'') as IMAGE_ID,SEQ_NO " & _
                '      "       ,CNT = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY C " + _
                '      " WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y') " & _
                '      "  From v_SIEBEL_CATALOG_CATEGORY A,v_SIEBEL_CATALOG_CATEGORY_LANG B" & _
                '      " Where PARENT_CATEGORY_ID = '" & Category_ID & "' " & _
                '      "   And CATEGORY_TYPE      in ('Category','SubCategory')" & _
                '      "   And ACTIVE_FLG         = 'Y' " & _
                '      "   AND A.CATEGORY_ID     *= B.CATEGORY_ID " & _
                '      "   and b.LANG_ID      = '" & language & "' " & _
                '      "  Order by SEQ_NO,isnull(b.DISPLAY_NAME,a.DISPLAY_NAME)"
            End If
        Else
            If language = "ENU" Then

                'Frank 2012/01/11 not use this sql command because query proformance is no good.
                'sql = "Select distinct isnull(A.CATEGORY_ID,'') as CATEGORY_ID,isnull(A.CATEGORY_NAME,'') as CATEGORY_NAME, " + _
                '    " isnull(A.CATEGORY_TYPE,'') as CATEGORY_TYPE,isnull(DISPLAY_NAME,'') as DISPLAY_NAME, " + _
                '    " isnull(CATEGORY_DESC,'') as CATEGORY_DESC,isnull(a.IMAGE_ID,'') as IMAGE_ID, " + _
                '    " PRODUCT_DESC=IsNull(PRODUCT_DESC,a.EXTENDED_DESC),isnull(c.EXTENDED_DESC,'') as EXTENDED_DESC," + _
                '    " isnull(SEQ_NO,'') as SEQ_NO,c.NEW_PRODUCT_DATE " & _
                '      "       ,CNT = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B " + _
                '      " WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y') " & _
                '       "       ,CNT1 = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B " + _
                '        " WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Model') And ACTIVE_FLG = 'Y') " + _
                '      "  From v_SIEBEL_CATALOG_CATEGORY a left join v_SIEBEL_PRODUCT c " & _
                '      "   on a.DISPLAY_NAME = c.PART_NO " & _
                '      " Where PARENT_CATEGORY_ID = '" & Category_ID & "' " & _
                '      "   And CATEGORY_TYPE like 'Model%' " & _
                '      "   And ACTIVE_FLG = 'Y' and c.TUMBNAIL_IMAGE_ID is not null " & _
                '      "  Order by SEQ_NO,DISPLAY_NAME"


                'Frank 2012/01/11
                'To change query pis data from view to table for improving performance.
                'Query View need about 6 sec. Query table need about 1 sec.
                sql = "Select Distinct b.MODEL_ID as CATEGORY_ID, b.MODEL_NAME as CATEGORY_NAME" + _
                    ", CATEGORY_TYPE='Model', b.MODEL_NAME as DISPLAY_NAME, isnull(b.MODEL_DESC,'') as CATEGORY_DESC" + _
                    ", isnull(b.MODEL_DESC,'') as EXTENDED_DESC, isnull(b.MODEL_DESC,'') as PRODUCT_DESC, a.SEQ as SEQ_NO " + _
                    ", IMAGE_ID='', c.EndDate as NEW_PRODUCT_DATE, CNT=0, CNT1=0" + _
                    " From Category_Model a inner join model b On a.model_Name = b.MODEL_Name" + _
                    " left join Model_Publish c On a.model_name = c.MODEL_name " + _
                    " Where a.Category_id='" & Category_ID & "'" + _
                    " and c.Active_FLG= 'Y' and  c.Site_ID='ACL'" + _
                    " Order by a.SEQ"

            Else
                'sql = "Select a.CATEGORY_ID,a.CATEGORY_NAME,CATEGORY_TYPE,DISPLAY_NAME=isnull(c.DISPLAY_NAME,a.DISPLAY_NAME)," & _
                '      "       CATEGORY_DESC=isnull(c.CATEGORY_DESC,a.CATEGORY_DESC), a.IMAGE_ID, " & _
                '      "       PRODUCT_DESC=IsNull(isnull((select d.PRODUCT_DESC from PRODUCT_LANG d " + _
                '      " where d.product_id=b.product_id and d.lang_id='" & language & "'),b.PRODUCT_DESC),isnull(c.EXTENDED_DESC,a.EXTENDED_DESC))," & _
                '      "       PRODUCT_DESC1=isnull((select d.EXTENTED_DESC from PRODUCT_LANG d " + _
                '      " where d.product_id=b.product_id and d.lang_id='" & language & "'),b.EXTENTED_DESC)," & _
                '      "       SEQ_NO,b.NEW_PRODUCT_DATE " & _
                '      "  From SIEBEL_CATALOG_CATEGORY a,SIEBEL_PRODUCT b,SIEBEL_CATALOG_CATEGORY_LANG c " & _
                '      " Where PARENT_CATEGORY_ID = '" & Category_ID & "' " & _
                '      "   And CATEGORY_TYPE like 'Model%' " & _
                '      "   And ACTIVE_FLG      = 'Y' " & _
                '      "   ANd a.DISPLAY_NAME = b.PART_NO " & _
                '      "   AND a.CATEGORY_ID = c.CATEGORY_ID and b.TUMBNAIL_IMAGE_ID is not null " & _
                '      "   and c.LANG_ID      = '" & language & "' " & _
                '      "  Order by SEQ_NO,isnull(c.DISPLAY_NAME,a.DISPLAY_NAME)"
            End If
        End If
        Me.dtContent = dbUtil.dbGetDataTable("PIS", sql)
    End Sub

    Public Shared Sub getHierarchyProductLine(ByVal Parent_Id As String, ByRef Product_Line As String)

        Do
            Dim strSql As String = ""
            If language = "ENU" Then
                'Frank 2012/01/11 not use this sql command because query proformance is no good.
                ' strSql = _
                '" Select A.CATEGORY_ID, IsNull(A.DISPLAY_NAME, '') as DISPLAY_NAME, IsNull(A.CATEGORY_TYPE, '') as CATEGORY_TYPE, " + _
                '" IsNull(A.PARENT_CATEGORY_ID, '') as PARENT_CATEGORY_ID, " + _
                '" CNT = (SELECT COUNT(*) FROM v_SIEBEL_CATALOG_CATEGORY B WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y')" + _
                '" From v_SIEBEL_CATALOG_CATEGORY A " + _
                '" Where CATEGORY_ID = '" + Parent_Id + "'"

                'Frank 2012/01/11
                'To change query pis data from view to table for improving performance.
                strSql = "Select a.CATEGORY_ID, a.DISPLAY_NAME, a.CATEGORY_TYPE, a.PARENT_CATEGORY_ID" + _
                        " , CNT = (SELECT COUNT(*) FROM Categorty B WHERE PARENT_CATEGORY_ID=A.CATEGORY_ID AND CATEGORY_TYPE in ('Category','SubCategory') And ACTIVE_FLG = 'Y')" + _
                        " From CATEGORY a Where CATEGORY_ID='" + Parent_Id + "'"

            Else
                'strSql = _
                '" Select a.CATALOG_ID,a.CATEGORY_ID,CATEGORY_NAME, " & _
                '" DISPLAY_NAME  = isnull(b.DISPLAY_NAME,a.DISPLAY_NAME), " & _
                '" CATEGORY_DESC = isnull(b.CATEGORY_DESC,a.CATEGORY_DESC), " & _
                '" EXTENDED_DESC = isnull(b.EXTENDED_DESC,a.EXTENDED_DESC), " & _
                '" IMAGE_ID,PARENT_CATEGORY_ID " & _
                '" From SIEBEL_CATALOG_CATEGORY a left join SIEBEL_CATALOG_CATEGORY_LANG b on  a.CATEGORY_ID = b.CATEGORY_ID " & _
                '" Where a.CATEGORY_ID  = '" & parent_category_id & "' " & _
                '" and b.LANG_ID      = '" & GetSiebelLang(strLang) & "' "
            End If
            Dim dt As DataTable = dbUtil.dbGetDataTable("PIS", strSql)
            If dt.Rows.Count > 0 Then
                Dim category_type As String = dt.Rows(0).Item("CATEGORY_TYPE").ToString()
                If Not IsNothing(dt) And dt.Rows.Count > 0 Then
                    If category_type = "" Then
                        Product_Line = "<a href='/Product/Product_Line_New.aspx'>" + dt.Rows(0).Item("DISPLAY_NAME").ToString() + "</a>" + " > " & Product_Line
                        Exit Do
                    Else
                        If dt.Rows(0).Item("CNT") > 0 Then
                            Product_Line = "<a href='/Product/SubCategory.aspx?Category_ID=" + dt.Rows(0).Item("CATEGORY_ID").ToString() + "'>" + dt.Rows(0).Item("DISPLAY_NAME").ToString() + "</a>" + " > " & Product_Line
                            Parent_Id = dt.Rows(0).Item("PARENT_CATEGORY_ID")
                        Else
                            Product_Line = "<a href='/Product/Model_Master.aspx?Category_ID=" + dt.Rows(0).Item("CATEGORY_ID").ToString() + "'>" + dt.Rows(0).Item("DISPLAY_NAME").ToString() + "</a>" + " > " & Product_Line
                            Parent_Id = dt.Rows(0).Item("PARENT_CATEGORY_ID")
                        End If
                    End If
                Else
                    Exit Do
                End If
            Else
                Exit Do
            End If
        Loop
        Product_Line = "<a href='/Product/Product_Line_New.aspx'>Product Lines</a> > " & Product_Line

    End Sub

End Class

#End Region

#Region "eCampaign"
Public Class eCampaignReportingUtility
    Public Shared Function GetCampaignOverview(ByRef arrRBU As ArrayList, ByRef arrENews As ArrayList, ByVal FromDate As Date, ByVal ToDate As Date, _
                                 Optional ByVal is_formatNumber As Boolean = False) As DataTable
        Dim sql As String = ""
        Dim sbWhere As New StringBuilder
        With sbWhere
            .AppendFormat(" where a.actual_send_date is not null ")
            If arrRBU.Count > 0 Then
                .AppendFormat(" and a.region in ({0}) ", String.Join(",", arrRBU.ToArray()))
            Else
                .AppendFormat(" and 1<>1 ")
            End If
            If arrENews.Count > 0 Then
                .AppendFormat(" and a.enews in ({0})  ", String.Join(",", arrENews.ToArray()))
            End If
            .AppendFormat(" and a.actual_send_date between '{0}' and '{1}' ", FromDate.ToString("yyyy-MM-dd"), ToDate.ToString("yyyy-MM-dd"))
        End With

        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select top 200 a.row_id, a.campaign_name, isnull(a.source_name,'') as parent_campaign, a.actual_send_date, DATEPART(ww,actual_send_date) as week, a.eNews, isnull(a.region,'') as region, a.created_by, ")
            .AppendFormat(" (select COUNT(contact_email) from campaign_contact_list b where b.campaign_row_id=a.row_id and b.EMAIL_ISSENT=1) as recipients, ")
            .AppendFormat(" ((select COUNT(contact_email) from campaign_contact_list b where b.campaign_row_id=a.row_id and b.EMAIL_ISSENT=1)-a.sum_invalid) as email_delivered, ")
            .AppendFormat(" a.sum_invalid as hard_bounced, '0.00%' as delivery_rate, ")
            .AppendFormat(" (select COUNT(contact_email) from campaign_contact_list b where b.campaign_row_id=a.row_id and b.email_isopened=1) as recipient_opens, '0.00%' as open_rate, ")
            .AppendFormat(" (select count(email) from campaign_openlink_log b where b.campaign_row_id=a.row_id) as total_clicks, ")
            .AppendFormat(" a.rece_click_all as recipient_clicks, '0.00%' as click_rate, '0.00%' as click_rate_per_open, ")
            .AppendFormat(" (select count(email) from unsubscribe_email b where b.campaign_row_id=a.row_id) as unsubscribe, '0.00%' as unsubscribe_rate, ")
            .AppendFormat(" (select count(distinct b.EMAIL) from (select distinct z.EMAIL from CAMPAIGN_OPENLINK_LOG z where z.campaign_row_id=a.row_id) as b left join SIEBEL_CONTACT c on b.EMAIL=c.EMAIL_ADDRESS where c.account_status in ('03-Premier Key Account','04-Premier Key Account','06G-Golden Key Account(ACN)','06-Key Account')) as KA_clicks, ")
            .AppendFormat(" (select count(distinct b.EMAIL) from (select distinct z.EMAIL from CAMPAIGN_OPENLINK_LOG z where z.campaign_row_id=a.row_id) as b left join SIEBEL_CONTACT c on b.EMAIL=c.EMAIL_ADDRESS where c.account_status in ('05-DMS General Account','07-General Account','08-General Account(List Price)','12-Leads','11-Prospect')) as GA_clicks, ")
            .AppendFormat(" (select count(distinct b.EMAIL) from (select distinct z.EMAIL from CAMPAIGN_OPENLINK_LOG z where z.campaign_row_id=a.row_id) as b left join SIEBEL_CONTACT c on b.EMAIL=c.EMAIL_ADDRESS where c.account_status in ('01-Platinum Channel Partner','01-Premier Channel Partner','02-Gold Channel Partner','03-Certified Channel Partner')) as CP_clicks, ")
            .AppendFormat(" (select count(distinct b.EMAIL) from (select distinct z.EMAIL from CAMPAIGN_OPENLINK_LOG z where z.campaign_row_id=a.row_id) as b left join SIEBEL_CONTACT c on b.EMAIL=c.EMAIL_ADDRESS where c.account_status in ('10-Sales Contact','11-Sales Contact')) as Sales_contacts_clicks, ")
            .AppendFormat(" (select count(distinct b.EMAIL) from (select distinct z.EMAIL from CAMPAIGN_OPENLINK_LOG z where z.campaign_row_id=a.row_id) as b left join SIEBEL_CONTACT c on b.EMAIL=c.EMAIL_ADDRESS where (c.account_status is null or c.account_status not in ('01-Platinum Channel Partner','01-Premier Channel Partner','02-Gold Channel Partner','03-Certified Channel Partner','03-Premier Key Account','04-Premier Key Account','06G-Golden Key Account(ACN)','06-Key Account','05-DMS General Account','07-General Account','08-General Account(List Price)','10-Sales Contact','11-Sales Contact','12-Leads','11-Prospect'))) as other_clicks ")
            .AppendFormat(" from CAMPAIGN_MASTER a ")
            .AppendFormat(sbWhere.ToString())
            .AppendFormat(" order by a.actual_send_date desc, a.campaign_name")
        End With

        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString)
        Try
            If dt.Rows.Count > 0 Then
                For Each r As DataRow In dt.Rows
                    If CInt(r.Item("email_delivered")) = 0 Then

                    Else
                        Dim open_rate As Double = 0.0, click_rate As Double = 0.0, deli_rate As Double = 0.0
                        r.Item("open_rate") = CDbl(r.Item("recipient_opens")) / CDbl(r.Item("email_delivered"))
                        r.Item("click_rate") = CDbl(r.Item("recipient_clicks")) / CDbl(r.Item("email_delivered"))
                        r.Item("delivery_rate") = CDbl(r.Item("email_delivered")) / CDbl(r.Item("recipients"))
                        If CDbl(r.Item("recipient_opens")) = 0 Or CDbl(r.Item("recipient_clicks")) = 0 Then
                            r.Item("click_rate_per_open") = 0
                        Else
                            r.Item("click_rate_per_open") = CDbl(r.Item("recipient_clicks")) / CDbl(r.Item("recipient_opens"))
                        End If
                        r.Item("unsubscribe_rate") = CDbl(r.Item("unsubscribe")) / CDbl(r.Item("email_delivered"))
                    End If
                    r.AcceptChanges()
                Next
            End If
        Catch ex As Exception
            Throw New Exception("MktDal - Get campaign overview dt failed:" + ex.ToString())
        End Try
        Return dt
    End Function

    'Private Function SQLWhere(ByRef arrRBU As ArrayList, ByRef arrENews As ArrayList, ByVal FromDate As Date, ByVal ToDate As Date) As String
    '    Dim sb As New StringBuilder
    '    With sb
    '        .AppendFormat(" where a.actual_send_date is not null ")
    '        'Dim arrRBU As New ArrayList
    '        'For Each item As ListItem In cblRBU.Items
    '        '    If item.Selected Then arrRBU.Add("'" + item.Value + "'")
    '        'Next
    '        If arrRBU.Count > 0 Then
    '            .AppendFormat(" and a.region in ({0}) ", String.Join(",", arrRBU.ToArray()))
    '        Else
    '            .AppendFormat(" and 1<>1 ")
    '        End If
    '        If dleNews.SelectedValue <> "All" Then
    '            .AppendFormat(" and a.enews=N'{0}' ", dleNews.SelectedValue)
    '        End If
    '        .AppendFormat(" and a.actual_send_date between '{0}' and '{1}' ", FromDate.ToString("yyyy-MM-dd"), ToDate.ToString("yyyy-MM-dd"))
    '    End With
    '    Return sb.ToString
    'End Function
End Class

Public Class eCampaignContact
    Public Shared Function GetContactBouncedTimes(ByVal ContactEmail As String) As Integer
        If String.IsNullOrEmpty(ContactEmail) Then Return 0
        Dim cmd As New SqlClient.SqlCommand( _
            "select IsNull(counts,0) from INVALID_EMAIL_UNIQUE where EMAIL=@EM", _
            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("EM", Trim(ContactEmail))
        cmd.Connection.Open()
        Dim ret As Object = cmd.ExecuteScalar()
        cmd.Connection.Close()
        If ret Is Nothing Then
            Return 0
        Else
            Return CInt(ret)
        End If
    End Function
End Class
Public Class WebsiteThumbnail
    Protected _url As String, _width As Integer, _height As Integer, _thumbWidth As Integer, _thumbHeight As Integer, _bmp As Bitmap
    Public Shared Function GetThumbnail(url As String, width As Integer, height As Integer, thumbWidth As Integer, thumbHeight As Integer) As Bitmap
        Dim thumbnail As New WebsiteThumbnail(url, width, height, thumbWidth, thumbHeight)
        Return thumbnail.GetThumbnail()
    End Function

    Protected Sub New(url As String, width As Integer, height As Integer, thumbWidth As Integer, thumbHeight As Integer)
        _url = url : _width = width : _height = height : _thumbWidth = thumbWidth : _thumbHeight = thumbHeight
    End Sub

    Protected Function GetThumbnail() As Bitmap
        Dim thread As New Threading.Thread(New ThreadStart(AddressOf GetThumbnailWorker))
        thread.SetApartmentState(ApartmentState.STA)
        thread.Start() : thread.Join()
        Return TryCast(_bmp.GetThumbnailImage(_thumbWidth, _thumbHeight, Nothing, IntPtr.Zero), Bitmap)
    End Function

    Protected Sub GetThumbnailWorker()
        Using browser As New WebBrowser()
            Try
                browser.ClientSize = New Size(_width, _height) : browser.ScrollBarsEnabled = False : browser.ScriptErrorsSuppressed = True
                browser.Navigate(_url)
                While (browser.ReadyState <> WebBrowserReadyState.Complete)
                    Application.DoEvents()
                End While
                If browser.Document IsNot Nothing Then
                    browser.Document.ExecCommand("SelectAll", False, "null") : browser.Document.ExecCommand("FontName", False, "Arial") : browser.Document.ExecCommand("Unselect", False, "null")
                End If
                _bmp = New Bitmap(_width, _height)
                browser.DrawToBitmap(_bmp, New Rectangle(0, 0, _width, _height))
            Catch ex As Exception
                Threading.Thread.Sleep(100)
                Try
                    browser.DrawToBitmap(_bmp, New Rectangle(0, 0, _width, _height))
                Catch ex1 As Exception
                    Threading.Thread.Sleep(100)
                    Try
                        browser.DrawToBitmap(_bmp, New Rectangle(0, 0, _width, _height))
                    Catch ex2 As Exception
                        'MailUtil.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "GetThumbnailWorker error", ex2.ToString(), False, "", "")
                    End Try
                End Try
            End Try

        End Using
    End Sub
End Class

Public Class QREC
    Public Class ClientProperties
        Public IP As String, Browser As String, Languages() As String, IsMobile As Boolean, mDeviceMf As String, mDeviceModel As String, BrowserPlatform As String
        Public Sub New()

        End Sub
        Public Sub New(ByVal iIP As String, ByVal iBrowser As String, ByVal iLanguages() As String, _
                       ByVal iIsMobile As Boolean, ByVal imDeviceMf As String, ByVal imDeviceModel As String, ByVal iBrowserPlatform As String)
            IP = iIP : Browser = iBrowser : Languages = iLanguages : IsMobile = iIsMobile : mDeviceMf = imDeviceMf
            mDeviceModel = imDeviceModel : BrowserPlatform = iBrowserPlatform
            If Browser Is Nothing OrElse Browser = String.Empty Then Browser = ""
            If mDeviceMf Is Nothing OrElse mDeviceMf = String.Empty Then mDeviceMf = ""
            If mDeviceModel Is Nothing OrElse mDeviceModel = String.Empty Then mDeviceModel = ""
            If BrowserPlatform Is Nothing OrElse BrowserPlatform = String.Empty Then BrowserPlatform = ""
            If Languages Is Nothing Then Languages = New String() {""}
        End Sub
        Public Sub EnsureNoEmptyValue()
            If Browser Is Nothing OrElse Browser = String.Empty Then Browser = ""
            If mDeviceMf Is Nothing OrElse mDeviceMf = String.Empty Then mDeviceMf = ""
            If mDeviceModel Is Nothing OrElse mDeviceModel = String.Empty Then mDeviceModel = ""
            If BrowserPlatform Is Nothing OrElse BrowserPlatform = String.Empty Then BrowserPlatform = ""
            If Languages Is Nothing Then Languages = New String() {""}
        End Sub
    End Class

    Public Function HandleQRCampaignURL(ByVal RequestUrl As String, ByRef CP As ClientProperties, ByRef ReturnUrl As String) As Boolean
        RequestUrl = RequestUrl.ToLower()
        'Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "Handle QRURL request", RequestUrl, False, "", "")
        Try
            CP.EnsureNoEmptyValue()
            If RequestUrl.EndsWith(".jsp") Then
                Dim sUrl = RequestUrl.Substring(0, RequestUrl.Length - 4)
                Dim rid As String = Replace(sUrl, "/ec/qr_", "")
                Select Case rid.Substring(0, 2)
                    Case "a_"
                        rid = rid.Substring(2)
                        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _
                      " select top 1 a.LANDING_URL from QR_CAMPAIGN_MASTER a " + _
                      " where a.ROW_ID='" + rid + "'")
                        If dt.Rows.Count = 1 Then
                            Dim tmpCountry As String = "", tmpCity As String = ""
                            Util.IP2CountryCity(CP.IP, tmpCountry, tmpCity)
                            dbUtil.dbExecuteNoQuery("MYLOCAL", _
                                " INSERT INTO QR_VISIT_LOG " + _
                                " (CAMPAIGN_ROW_ID, CONTACT_ROW_ID, IP, BROWSER, LANGUAGES, IS_MOBILE, " + _
                                " MDEVICE_MF, MDEVICE_MODEL, BROWSER_PLATFORM, VISIT_DATE, IP2COUNTRY, IP2CITY) " + _
                                " VALUES (N'" + rid + "', null, '" + CP.IP + "', N'" + CP.Browser + "', " + _
                                " N'" + String.Join("|", CP.Languages) + "', " + IIf(CP.IsMobile, 1, 0).ToString() + ", " + _
                                " N'" + CP.mDeviceMf + "', N'" + CP.mDeviceModel + "', " + _
                                " N'" + CP.BrowserPlatform + "', GETDATE(), " + _
                                " N'" + Replace(tmpCountry, "'", "''") + "', N'" + Replace(tmpCity, "'", "''") + "') ")
                            ReturnUrl = HttpUtility.UrlDecode(dt.Rows(0).Item(0)) : Return True
                        Else
                            Return False
                        End If
                    Case "b_"
                        rid = rid.Substring(2)
                        Dim dt As DataTable = dbUtil.dbGetDataTable("MYLOCAL", _
                       " select top 1 b.ROW_ID as CAMPAIGN_ROW_ID, b.LANDING_URL from QR_CAMPAIGN_CONTACT a inner join QR_CAMPAIGN_MASTER b " + _
                       " on a.CAMPAIGN_ROW_ID=b.ROW_ID where a.ROW_ID='" + rid + "'")
                        If dt.Rows.Count = 1 Then
                            dbUtil.dbExecuteNoQuery("MYLOCAL", _
                                " update QR_CAMPAIGN_CONTACT set IS_VISITED=1, LAST_VISIT_DATE=getdate(), " + _
                                " VISIT_TIMES=VISIT_TIMES+1, LAST_VISIT_IP='" + CP.IP + "' where ROW_ID='" + rid + "'")
                            dbUtil.dbExecuteNoQuery("MYLOCAL", _
                               " INSERT INTO QR_VISIT_LOG " + _
                               " (CAMPAIGN_ROW_ID, CONTACT_ROW_ID, IP, BROWSER, LANGUAGES, IS_MOBILE, MDEVICE_MF, MDEVICE_MODEL, BROWSER_PLATFORM, VISIT_DATE) " + _
                               " VALUES (N'" + dt.Rows(0).Item("CAMPAIGN_ROW_ID") + "', N'" + rid + "', '" + CP.IP + "', N'" + CP.Browser + "', " + _
                               " N'" + String.Join("|", CP.Languages) + "', " + IIf(CP.IsMobile, 1, 0).ToString() + ", " + _
                               " N'" + CP.mDeviceMf + "', N'" + CP.mDeviceModel + "', N'" + CP.BrowserPlatform + "', GETDATE()) ")
                            ReturnUrl = HttpUtility.UrlDecode(dt.Rows(0).Item("LANDING_URL")) : Return True
                        Else
                            Return False
                        End If
                End Select

            Else
                Return False
            End If
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "Handle QRURL request error " + RequestUrl, ex.ToString(), False, "", "")
        End Try
        'Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "Handle QRURL request", RequestUrl, False, "", "")
        Return False
    End Function
End Class
#End Region

#Region "CMS"
Public Class CMSDAL
    Public Class CMSArticle
        Public RecordId As String, Abstract As String, Content As String, Title As String
        Public Sub New(ByVal RID As String)
            RecordId = RID
            Abstract = "" : Content = "" : Title = ""
        End Sub
    End Class
    Public Shared Function GetCMSContentByRecordId(ByVal RecordId As String, ByRef CA As CMSArticle) As Boolean
        Dim MyConn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("My").ConnectionString)
        Dim apt As New SqlClient.SqlDataAdapter( _
            " SELECT top 1 TITLE, CATEGORY_NAME, RECORD_IMG, HYPER_LINK, IsNull(ABSTRACT,'') as ABSTRACT,  " + _
            " CMS_TYPE, ISNULL(b.CMS_CONTENT,'') as  CMS_CONTENT " + _
            " FROM  WWW_RESOURCES a left join WWW_RESOURCES_DETAIL b on a.RECORD_ID=b.RECORD_ID  " + _
            " WHERE a.RECORD_ID = @RID  " + _
            " order by a.RBU ", MyConn)
        apt.SelectCommand.Parameters.AddWithValue("RID", RecordId)
        Dim dt As New DataTable
        apt.Fill(dt)
        If dt.Rows.Count = 1 Then
            CA = New CMSArticle(RecordId)
            CA.Abstract = dt.Rows(0).Item("Abstract") : CA.Content = dt.Rows(0).Item("CMS_CONTENT") : CA.Title = dt.Rows(0).Item("TITLE")
            Return True
        End If
        Return False
    End Function
End Class
#End Region

#Region "AENC Home Page"

Public Class AENCHomePage

    ' ''' <summary>
    ' ''' Get new product list under some product line from PIS
    ' ''' </summary>
    ' ''' <param name="_NewProductCount">Max count is 50</param>
    ' ''' <returns></returns>
    ' ''' <remarks></remarks>
    'Public Shared Function GetNewProductList(ByVal _NewProductCount As Integer) As DataTable
    Public Shared Function GetNewProductList() As DataTable

        'If _NewProductCount > 50 Then _NewProductCount = 50

        Dim _SQL As String = String.Empty
        Dim _SQL_Order As String = String.Empty
        Dim _SubSQL1 As String = String.Empty
        'Frank 2012/05/25
        'besides the IAG product line, get new product from below product line
        Dim _rootcategory() As String = New String() {"1-2JKJPU", "1-2JKQNX", "Medical_Computing", "1-2JKFKR", "Digital_Signage_Self-Service"}

        _SQL &= "Select top 1 c.PART_NO, c.PRODUCT_DESC, c.CREATED_DATE, b.MODEL_NAME"

        'Get Model literature(Main Photo)
        _SQL &= ", ISNULL((Select top 1 LITERATURE.LITERATURE_ID from Model_lit inner join LITERATURE"
        _SQL &= " ON MODEL_LIT.LITERATURE_ID = LITERATURE.LITERATURE_ID"
        _SQL &= " WHERE(MODEL_LIT.MODEL_NAME = b.model_name)"
        _SQL &= " And literature.FILE_EXT in ('jpg','JPG','gif', 'GIF','png')"
        _SQL &= " And literature.LIT_TYPE in ('Product - Photo(Main)','Product - Photo(B)','Product - Photo(S)')"
        _SQL &= " Order by (case when LITERATURE.LIT_TYPE='Product - Photo(Main)' then 0 else 1 end)"
        _SQL &= " ),N'') as Main_Image_LiteratureID"


        _SQL &= " FROM CATEGORY_HIERARCHY a left join model_product b on a.model_no=b.model_name"
        _SQL &= " left join PRODUCT_LOGISTICS_NEW c on b.part_no=c.PART_NO"
        _SQL &= " left join Model_Publish d on b.model_name=d.Model_name"
        _SQL &= " Where"
        _SQL &= " b.relation='product' and d.Active_FLG='Y' And d.Site_ID='ACL' and c.STATUS in ('N', 'A', 'H')"


        _SQL_Order &= " Group by c.PART_NO, c.PRODUCT_DESC, c.CREATED_DATE, b.MODEL_NAME"
        _SQL_Order &= " Order by c.CREATED_DATE desc"


        '1-2JKJPU=Embedded Boards & Design-in Services
        '1-2JKQNX=Applied Computing & Embedded Systems
        'Medical_Computing=Medical Computing
        '1-2JKFKR=Design & Manufacturing / Networks & Telecom
        'Digital_Signage_Self-Service=Digital Signage & Self-Service

        'Dim apt As New SqlClient.SqlDataAdapter
        'apt.
        Dim _dt As New DataTable

        For Each _productline As String In _rootcategory
            _SubSQL1 = ""
            _SubSQL1 &= " And ("
            _SubSQL1 &= " a.parent_category_id2 = '" & _productline & "'"
            _SubSQL1 &= " or a.parent_category_id3 = '" & _productline & "'"
            _SubSQL1 &= " or a.parent_category_id4 = '" & _productline & "'"
            _SubSQL1 &= " or a.parent_category_id5 = '" & _productline & "'"
            _SubSQL1 &= " or a.parent_category_id6 = '" & _productline & "'"
            _SubSQL1 &= " )"

            _dt.Merge(dbUtil.dbGetDataTable("PIS", _SQL & _SubSQL1 & _SQL_Order))

        Next

        Return _dt


        '_SQL &= " And ("
        '_SQL &= " a.parent_category_id2 = '1-2JKEUF'"
        '_SQL &= " or a.parent_category_id2 = '1-GTLN5K'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKOHS'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKOJO'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKPQY'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKJP8'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKNE8'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKFH2'"
        '_SQL &= " or a.parent_category_id2 = 'Ubiquitous_Touch_Computers'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKEVU'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKJ91'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKJ9E'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKKHO'"
        '_SQL &= " or a.parent_category_id2 = 'MIO_Extension_Single_Board_Computers'"
        '_SQL &= " or a.parent_category_id2 = 'RISC_Computing_Solutions'"
        '_SQL &= " or a.parent_category_id2 = 'Semi-Industrial_Motherboards'"
        '_SQL &= " or a.parent_category_id2 = '1-2MLJZA'"
        '_SQL &= " or a.parent_category_id2 = 'Machine_Automation'"
        '_SQL &= " or a.parent_category_id2 = '1-2JKLN6'"

        '_SQL &= " or a.parent_category_id3 = '1-2JKBY5'"
        '_SQL &= " or a.parent_category_id3 = '1-2JKOGC'"
        '_SQL &= " or a.parent_category_id3 = '1-2JKNE8'"
        '_SQL &= " or a.parent_category_id3 = 'Ubiquitous_Touch_Computers'"
        '_SQL &= " or a.parent_category_id3 = '1-2JKJ91'"
        '_SQL &= " or a.parent_category_id3 = '1-2MLJXQ'"
        '_SQL &= " )"


        'Below sql to get product category
        'SELECT
        '	a.category_name1,a.parent_category_id1, a.category_name2,a.parent_category_id2
        '	, a.category_name3,a.parent_category_id3
        '	, a.category_name4,a.parent_category_id4

        'FROM 
        '  [PIS].[dbo].[CATEGORY_HIERARCHY] a left join model_product b on a.model_no=b.model_name
        '  left join PRODUCT_LOGISTICS_NEW c on b.part_no=c.PART_NO
        '  left join Model_Publish d on b.model_name=d.Model_name

        'Where
        '  b.relation='product' and d.Active_FLG='Y' And d.Site_ID='ACL'
        '  and a.catalog_id in('1-2JKBQD','1-2MLAX2') and c.STATUS in ('N', 'A', 'H')
        '  and 
        '  		(c.PART_NO like 'AIMB-2%'
        '        or c.PART_NO like 'AIMB-5%'
        '        or c.PART_NO like 'SIMB-%'
        '        or c.PART_NO like 'PCM-3%'
        '        or c.PART_NO like 'PCM-4%'
        '       or c.PART_NO like 'PCM-5%'
        '        or c.PART_NO like 'PCM-9%'
        '       or c.PART_NO like 'MIO-%'
        '        or c.PART_NO like 'SOM-%'
        '        or c.PART_NO like 'ARK-1%'
        '        or c.PART_NO like 'ARK-3%'
        '        or c.PART_NO like 'ARK-5%'
        '        or c.PART_NO like 'IPC-%'
        '        or c.PART_NO like 'APC-%'
        '        or c.PART_NO like 'ASM-%'
        '        or c.PART_NO like 'HPC-%'
        '        or c.PART_NO like 'PEC-%'
        '        or c.PART_NO like 'PCA-6%'
        '        or c.PART_NO like 'PCI-7%'
        '        or c.PART_NO like 'AIMB-7%'
        '        or c.PART_NO like 'ARK-DS%'
        '        or c.PART_NO like 'ARK-VH%'
        '        or c.PART_NO like 'PIT-%'
        '        or c.PART_NO like 'UTC-%'
        '        or c.PART_NO like 'HIT-%'
        '        or c.PART_NO like 'DSA-%'
        '        or c.PART_NO like 'S10%'
        '        or c.PART_NO like 'POC-%'
        '        or c.PART_NO like 'MICA-%'
        '        or c.PART_NO like 'MPC-%'
        '        or c.PART_NO like 'PDC-%')
        'Group by 
        'a.category_name1,a.parent_category_id1, a.category_name2,a.parent_category_id2
        ', a.category_name3,a.parent_category_id3
        ',a.parent_category_id4, a.category_name4
        'Order by a.category_name4,a.category_name3,a.category_name2,a.category_name1





        '_SQL &= "Select top " & _NewProductCount & " a.PART_NO, a.PRODUCT_DESC, a.CREATED_DATE, c.MODEL_NAME"
        '_SQL &= ", ISNULL((Select top 1 LITERATURE.LITERATURE_ID from Model_lit inner join LITERATURE"
        '_SQL &= " ON MODEL_LIT.LITERATURE_ID = LITERATURE.LITERATURE_ID"
        '_SQL &= " WHERE(MODEL_LIT.MODEL_NAME = c.model_name)"
        '_SQL &= " And literature.FILE_EXT in ('jpg','JPG','gif', 'GIF','png')"
        '_SQL &= " And literature.LIT_TYPE in ('Product - Photo(Main)','Product - Photo(B)','Product - Photo(S)')"
        '_SQL &= " Order by (case when LITERATURE.LIT_TYPE='Product - Photo(Main)' then 0 else 1 end)"
        '_SQL &= " ),N'') as Main_Image_LiteratureID"
        '_SQL &= " From PRODUCT_LOGISTICS_NEW a left join model_product b on a.PART_NO=b.PART_NO"
        '_SQL &= " left join model c on b.model_name=c.model_name"
        '_SQL &= " left join model_publish d on c.model_name=d.model_name"
        '_SQL &= " Where d.active_flg='Y' And d.Site_ID='ACL' and b.relation='product'"
        '_SQL &= " And (a.PART_NO like 'AIMB-2%'"
        '_SQL &= " or a.PART_NO like 'AIMB-5%'"
        '_SQL &= " or a.PART_NO like 'SIMB%'"
        '_SQL &= " or a.PART_NO like 'PCM-3%'"
        '_SQL &= " or a.PART_NO like 'PCM-4%'"
        '_SQL &= " or a.PART_NO like 'PCM-5%'"
        '_SQL &= " or a.PART_NO like 'PCM-9%'"
        '_SQL &= " or a.PART_NO like 'MIO%'"
        '_SQL &= " or a.PART_NO like 'SOM-%'"
        '_SQL &= " or a.PART_NO like 'ARK-1%'"
        '_SQL &= " or a.PART_NO like 'ARK-3%'"
        '_SQL &= " or a.PART_NO like 'ARK-5%'"
        '_SQL &= " or a.PART_NO like 'IPC-%'"
        '_SQL &= " or a.PART_NO like 'APC-%'"
        '_SQL &= " or a.PART_NO like 'ASM%'"
        '_SQL &= " or a.PART_NO like 'HPC%'"
        '_SQL &= " or a.PART_NO like 'PEC%'"
        '_SQL &= " or a.PART_NO like 'PCA-6%'"
        '_SQL &= " or a.PART_NO like 'PCI-7%'"
        '_SQL &= " or a.PART_NO like 'AIMB-7%'"
        '_SQL &= " or a.PART_NO like 'ARK-DS%'"
        '_SQL &= " or a.PART_NO like 'ARK-VH%'"
        '_SQL &= " or a.PART_NO like 'PIT%'"
        '_SQL &= " or a.PART_NO like 'UTC%'"
        '_SQL &= " or a.PART_NO like 'HIT%'"
        '_SQL &= " or a.PART_NO like 'DSA-%'"
        '_SQL &= " or a.PART_NO like 'S10%'"
        '_SQL &= " or a.PART_NO like 'POC%'"
        '_SQL &= " or a.PART_NO like 'MICA%'"
        '_SQL &= " or a.PART_NO like 'MPC%'"
        '_SQL &= " or a.PART_NO like 'PDC%'"
        '_SQL &= " )"
        '_SQL &= " Group by a.PART_NO, a.PRODUCT_DESC,a.CREATED_DATE,c.MODEL_NAME"
        '_SQL &= " Order by a.CREATED_DATE desc"

        'Dim apt As New SqlClient.SqlDataAdapter(_SQL, ConfigurationManager.ConnectionStrings("PIS").ConnectionString)
        ''apt.SelectCommand.Parameters.AddWithValue("PN", PN)
        'Dim _dt As New DataTable
        'apt.Fill(_dt)
        'apt.SelectCommand.Connection.Close()
        'Return _dt


    End Function

    ''' <summary>
    ''' Get video from CMS
    ''' </summary>
    ''' <param name="UseBaa"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetVideo(ByVal UseBaa As Boolean) As DataTable

        Dim userBaa As New ArrayList
        If UseBaa Then userBaa = Util.GetUserBaa()
        Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" SELECT distinct top 1 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  ")
            .AppendLine(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, ")
            .AppendLine(" a.ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, ")
            .AppendLine(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, ")
            .AppendLine(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME ")
            .AppendLine(" FROM WWW_RESOURCES AS a ")
            .AppendLine(" WHERE a.ABSTRACT<>'' and a.RECORD_IMG<>'' ")
            'If HttpContext.Current.Session("lanG") = "KOR" Then
            '    .AppendLine(String.Format(" and a.RBU ='AKR' "))
            'ElseIf HttpContext.Current.Session("lanG") = "JAP" Then
            '    .AppendLine(String.Format(" and a.RBU ='AJP' "))
            'Else
            '    .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU','AESC') "))
            'End If
            '.AppendLine(" and a.RBU in ('AENC','AAC','ANADMF') ")
            .AppendLine(" and a.RBU in ('AENC') ")
            .AppendLine(" and a.CATEGORY_NAME='Video'  ")
            If HttpContext.Current.Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            .AppendLine(" order by a.RELEASE_DATE desc")
        End With

        Return dbUtil.dbGetDataTable("MY", sb.ToString())


    End Function

    ''' <summary>
    ''' Get case study from CMS
    ''' </summary>
    ''' <param name="UseBaa"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCaseStudy(ByVal UseBaa As Boolean) As DataTable

        Dim userBaa As New ArrayList
        If UseBaa Then userBaa = Util.GetUserBaa()
        Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" SELECT distinct top 2 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  ")
            .AppendLine(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, ")
            .AppendLine(" '' as ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, ")
            .AppendLine(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, ")
            .AppendLine(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME ")
            .AppendLine(" FROM WWW_RESOURCES AS a ")
            .AppendLine(" WHERE a.ABSTRACT<>''  ")
            'If HttpContext.Current.Session("lanG") = "KOR" Then
            '    .AppendLine(String.Format(" and a.RBU ='AKR' "))
            'ElseIf HttpContext.Current.Session("lanG") = "JAP" Then
            '    .AppendLine(String.Format(" and a.RBU ='AJP' "))
            'Else
            '    .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU','AESC') "))
            'End If
            '.AppendLine(" and a.RBU in ('AENC','AAC','ANADMF') ")
            .AppendLine(" and a.RBU in ('AENC') ")
            .AppendLine(" and a.CATEGORY_NAME='Case Study'  ")
            If HttpContext.Current.Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            .AppendLine(" order by a.RELEASE_DATE desc ")
        End With

        Return dbUtil.dbGetDataTable("MY", sb.ToString())

    End Function

    ''' <summary>
    ''' Get white paper from CMS
    ''' </summary>
    ''' <param name="UseBaa"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetWhitePaper(ByVal UseBaa As Boolean) As DataTable

        Dim userBaa As New ArrayList
        If UseBaa Then userBaa = Util.GetUserBaa()
        Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" SELECT distinct top 2 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  ")
            .AppendLine(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, ")
            .AppendLine(" '' as ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, ")
            .AppendLine(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, ")
            .AppendLine(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME ")
            .AppendLine(" FROM WWW_RESOURCES AS a ")
            .AppendLine(" WHERE a.ABSTRACT<>''  ")
            'If HttpContext.Current.Session("lanG") = "KOR" Then
            '    .AppendLine(String.Format(" and a.RBU ='AKR' "))
            'ElseIf HttpContext.Current.Session("lanG") = "JAP" Then
            '    .AppendLine(String.Format(" and a.RBU ='AJP' "))
            'Else
            '    .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU','AESC') "))
            'End If
            '.AppendLine(" and a.RBU in ('AENC','AAC','ANADMF') ")
            .AppendLine(" and a.RBU in ('AENC') ")
            .AppendLine(" and a.CATEGORY_NAME='White Papers'  ")
            If HttpContext.Current.Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            .AppendLine(" order by a.RELEASE_DATE desc")
        End With

        Return dbUtil.dbGetDataTable("MY", sb.ToString())


    End Function

    ''' <summary>
    ''' get eDM from CMS
    ''' </summary>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GeteDM() As DataTable

        Dim strSql As String = ""
        If HttpContext.Current.Session("user_id") Is Nothing Then
            strSql = "select top 2 b.row_id, b.email_subject from CAMPAIGN_MASTER b where CAMPAIGN_NAME Like N'%eStore%' and ACTUAL_SEND_DATE is not null and CLICK_CUST>100 order by CREATED_DATE desc"
        Else
            strSql = String.Format( _
            " select top 2 b.row_id, a.contact_email, b.email_subject " + _
            " from campaign_contact_list a inner join campaign_master b on a.campaign_row_id=b.row_id " + _
            " where a.contact_email='{0}' order by a.email_send_time desc", HttpContext.Current.User.Identity.Name)
        End If

        Return dbUtil.dbGetDataTable("MY", strSql)


    End Function

    ''' <summary>
    ''' Get eCatalog from CMS
    ''' </summary>
    ''' <param name="UseBaa"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetCatalogsBrochures(ByVal UseBaa As Boolean) As DataTable

        Dim sb As New System.Text.StringBuilder
        With sb

            Dim userBaa As New ArrayList
            If UseBaa Then userBaa = Util.GetUserBaa()
            Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
            .AppendLine(" SELECT distinct top 2 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  ")
            .AppendLine(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, ")
            .AppendLine(" '' as ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, ")
            .AppendLine(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, ")
            .AppendLine(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME ")
            .AppendLine(" FROM WWW_RESOURCES AS a ")
            .AppendLine(" WHERE a.ABSTRACT<>''  ")

            '.AppendLine(" and a.RBU in ('AENC','AAC','ANADMF') ")
            .AppendLine(" and a.RBU in ('AENC') ")

            .AppendLine(" and a.CATEGORY_NAME='eCatalog'  ")
            If HttpContext.Current.Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            .AppendLine(" order by a.RELEASE_DATE desc ")
        End With

        Return dbUtil.dbGetDataTable("MY", sb.ToString())

    End Function

    ''' <summary>
    ''' Get USA events from CMS
    ''' </summary>
    ''' <param name="UseBaa"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetEvents(ByVal UseBaa As Boolean) As DataTable

        Dim userBaa As New ArrayList
        If UseBaa Then userBaa = Util.GetUserBaa()
        Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" SELECT top 10 a.TITLE, convert(VARCHAR(10),a.RELEASE_DATE,111) as [RELEASE_DATE], a.LASTUPDATED,  ")
            .AppendLine(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, ")
            .AppendLine(" '' as ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, ")
            .AppendLine(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, ")
            .AppendLine(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME ")
            .AppendLine(" FROM WWW_RESOURCES AS a ")
            .AppendLine(" WHERE a.ABSTRACT<>''  ")

            '.AppendLine(" and a.RBU in ('AENC','AAC','ANADMF') ")
            .AppendLine(" and a.RBU in ('AENC') ")

            .AppendLine(" and a.CATEGORY_NAME='Events'  ")
            .AppendLine(" and a.Country='USA'  ")

            If HttpContext.Current.Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
            .AppendLine(" order by a.RELEASE_DATE desc")
        End With

        Return dbUtil.dbGetDataTable("MY", sb.ToString())


    End Function


End Class
#End Region