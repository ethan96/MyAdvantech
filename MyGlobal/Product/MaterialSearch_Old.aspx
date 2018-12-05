<%@ Page Title="MyAdvantech- Marketing Material Search" Language="VB" MasterPageFile="~/Includes/MyMaster.master" EnableEventValidation="false" %>

<script runat="server">
    'Public Function Highlight(ByVal Search_Str As String, ByVal InputTxt As String) As String
    '    Dim RegExp As New Regex(Search_Str.Replace("*", "").Replace(" ", "|").Trim(), RegexOptions.IgnoreCase)
    '    Return RegExp.Replace(InputTxt, New MatchEvaluator(AddressOf ReplaceKeyWords))
    '    RegExp = Nothing
    'End Function
    
    'Public Function ReplaceKeyWords(ByVal m As Match) As String
    '    Return "<span style='background-color:Yellow'>" + m.Value + "</span>"
    'End Function
    
    Function GetSql() As String
        Dim getLit As Boolean = False, getTech As Boolean = False, getCMS As Boolean = False
        Dim fts As New eBizAEU.FullTextSearch(Server.HtmlEncode(txt_Key.Text.Replace("'", "''")))
        Dim strKey As String = fts.NormalForm
        Dim strLitTypes As String = "", strTechTypes As String = ""
        Dim arrTypes As New ArrayList
        
        'cblLitSearch選取項目數量
        hf_LitSearch.Value = CStr(Util.GetCheckedCountFromCheckBoxList(cblLitSearch))
                
        If Util.GetCheckedCountFromCheckBoxList(cblLitSearch) > 0 Then
            For Each li As ListItem In cblLitSearch.Items
                If li.Selected Then
                    Dim tmpType As String = li.Value.ToLower()
                    If tmpType = "photo" Then
                        Dim certTypeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct LIT_TYPE from pis.dbo.LITERATURE where LIT_TYPE like 'Product - Photo%'")
                        For Each ctr As DataRow In certTypeDt.Rows
                            arrTypes.Add("'" + ctr.Item("LIT_TYPE") + "'")
                        Next
                    Else
                        If tmpType Like "*certificate*" Then
                            Dim certTypeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct LIT_TYPE from pis.dbo.LITERATURE where LIT_TYPE like 'Certificate-%'")
                            For Each ctr As DataRow In certTypeDt.Rows
                                arrTypes.Add("'" + ctr.Item("LIT_TYPE") + "'")
                            Next
                            arrTypes.Add("'Certificate'")
                        Else
                            If tmpType Like "*report*" Then
                                Dim certTypeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct LIT_TYPE from pis.dbo.LITERATURE where LIT_TYPE like 'report-%'")
                                For Each ctr As DataRow In certTypeDt.Rows
                                    arrTypes.Add("'" + ctr.Item("LIT_TYPE") + "'")
                                Next
                            Else
                                If tmpType Like "*data*sheet*" Then
                                    Dim certTypeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct LIT_TYPE from pis.dbo.LITERATURE where LIT_TYPE like '%data%sheet%'")
                                    For Each ctr As DataRow In certTypeDt.Rows
                                        arrTypes.Add("'" + ctr.Item("LIT_TYPE") + "'")
                                    Next
                                End If
                            End If
                        End If
                    End If
                    If tmpType = "event poster" Then
                        Dim certTypeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct LIT_TYPE from pis.dbo.LITERATURE where LIT_TYPE like 'event poster%'")
                        For Each ctr As DataRow In certTypeDt.Rows
                            arrTypes.Add("'" + ctr.Item("LIT_TYPE") + "'")
                        Next
                    End If
                    arrTypes.Add("'" + tmpType + "'")
                    
                    'If tmpType = "poster" Then
                    '    Dim certTypeDt As DataTable = dbUtil.dbGetDataTable("MY", "select distinct LIT_TYPE from pis.dbo.LITERATURE where LIT_TYPE like 'poster%'")
                    '    For Each ctr As DataRow In certTypeDt.Rows
                    '        arrTypes.Add("'" + ctr.Item("LIT_TYPE") + "'")
                    '    Next
                    'End If
                    'arrTypes.Add("'" + tmpType + "'")
                    
                    If tmpType = "video" Or tmpType = "case study" Or tmpType = "news" Or tmpType = "white papers" Or tmpType = "webcast" Or tmpType = "image" Or _
                        tmpType = "podcast" Or tmpType = "ecatalog" Or tmpType = "edm / enewsletter" Or tmpType = "poster" Or tmpType = "presentation slide" Or _
                        tmpType = "corporate identity system (cis)" Then
                        getCMS = True
                    Else
                        getLit = True
                    End If
                End If
            Next
        End If
        
        If Util.GetCheckedCountFromCheckBoxList(cblBU) > 0 Then
            getCMS = True
        End If
        
        If Util.GetCheckedCountFromCheckBoxList(cblTechSearch) > 0 Then
            getTech = True
            For Each li As ListItem In cblTechSearch.Items
                If li.Selected Then
                    arrTypes.Add("'" + li.Value + "'")
                End If
            Next
        End If
        If arrTypes.Count > 0 Then
            If txt_Key.Text.Trim = "" Then strKey = "*"
        End If
        
        Dim arrSql As New ArrayList
        Dim BUList As New List(Of String)
        For i As Integer = 0 To cblBU.Items.Count - 1
            If cblBU.Items(i).Selected AndAlso cblBU.Items(i).Value <> "CORP" Then
                Select Case cblBU.Items(i).Value
                    Case "(BU)Embedded Boards & Design-in Services"
                        BUList.Add("'Emb''Core'")
                    Case "(BU)Industrial Automation"
                        BUList.Add("'IAG'")
                    Case "(BU)Intelligent Systems"
                        BUList.Add("'ISG'")
                    Case "(BU)Digital Healthcare"
                        BUList.Add("'D. Healthcare'")
                    Case "(BU)Digital Logistics & Digital Retail"
                        BUList.Add("'D. Logistics'") : BUList.Add("'D. Retail'")
                End Select
            End If
        Next
        
        
        If getLit Then arrSql.Add(GetLitSql(BUList))
        If getTech Then arrSql.Add(GetTechSql(BUList)) : arrSql.Add(GetSupportDownloadSql(BUList))
        If getCMS Then arrSql.Add(GetCMSSql(arrTypes))
        If Not getLit AndAlso Not getTech AndAlso Not getCMS Then
            With arrSql
                .Add(GetLitSql(BUList)) : .Add(GetTechSql(BUList)) : .Add(GetCMSSql(arrTypes)) : .Add(GetSupportDownloadSql(BUList))
            End With
        End If
        
        Dim sb As New System.Text.StringBuilder
        With sb
            If txt_Key.Text.Trim.Replace("*", "") <> "" Then
                .AppendFormat("select distinct top 500 t.LIT_ID, t.LIT_NAME, t.LAST_UPD, t.DESC_TEXT, t.LIT_TYPE, t.FILE_EXT, t.FILE_SIZE, t.FTP_URL, t.RECORD_IMG, t.RECORD_ID, t.SR_TYPE, t.HYPER_LINK ")
                .AppendFormat(" from (SELECT distinct * FROM ( {0} ) AS t1  ", String.Join(" union ", arrSql.ToArray()))
                .AppendLine(String.Format(" where (t1.part_no like '%{0}%' or t1.lit_name like N'%{0}%' or t1.products like '%{0}%' or t1.DESC_TEXT like '%{0}%' or t1.BAA like '%{0}%' or t1.txt_content like '%{0}%') ", txt_Key.Text.Trim.Replace("'", "").Replace("*", "%")))
                
                'If ddl1.SelectedValue <> "" Then
                '    If ddl2.SelectedValue <> "" Then
                '        .AppendFormat(" and t1.PD = '{0}' ", ddl2.SelectedValue)
                '    Else
                '        .AppendFormat(" and t1.PD in (SELECT DISTINCT [EDIVISION] as display_name FROM [SAP_PRODUCT] WHERE [EGROUP] = '{0}' AND [EDIVISION] is not null) ", ddl1.SelectedValue)
                '    End If
                'End If
                
                If arrTypes.Count > 0 Then
                    .AppendFormat(" and t1.LIT_TYPE in ({0}) and t1.LIT_ID not in (select z.Thumbnail_ID from PIS.dbo.LITERATURE_EXTEND z where z.Thumbnail_ID is not null or z.Thumbnail_ID !='') ", String.Join(",", arrTypes.ToArray()))
                End If
                If Not Session("account_status").ToString.Equals("CP", StringComparison.OrdinalIgnoreCase) AndAlso Not Session("account_status").ToString.Equals("EZ", StringComparison.OrdinalIgnoreCase) Then
                    .AppendFormat(" and t1.LIT_TYPE not in ('Presentation (For CP Only)') ")
                End If
                If ddlPeriod.SelectedValue = "0" Then
                    .AppendFormat(" and t1.LAST_UPD between dateadd(year,-2,getdate()) and getdate() ")
                End If
                
                '20110418 TC marked because many photos are not found in AAC
                'If Session("account_status") <> "EZ" AndAlso Session("org_id") = "US01" Then
                '    .AppendFormat(" and a.RBU = '{0}' ", Session("rbu"))
                'End If
                
                'If Session("lang_id") = "ENG" Then
                '    If Util.GetCheckedCountFromCheckBoxList(cblTechSearch) > 0 Then
                '        .AppendFormat(" and t1.LANG in ('ENU','ENG','ALL') and (t1.RBU='ACL' or t1.RBU='') ")
                '    Else
                '        .AppendFormat(" and t1.LANG in ('ENU','ENG','ALL') and t1.RBU='ACL' ")
                '    End If
                'End If
                If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(FLASHLEADS_RBU) from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU where SIEBEL_RBU in (select RBU from SIEBEL_ACCOUNT where ERP_ID ='{0}') and FLASHLEADS_RBU in ('AEU','ANA')", Session("COMPANY_ID")))) > 0 Then
                    .AppendFormat(" and t1.LANG in ('ENU','ENG','ALL') and t1.RBU in ('ADL','AUK','AIT','AFR','AEE','ABN','AMEA-Medical','AINNOCORE','AAC','AAU','AENC','ANADMF','AUK','ASG','AMY','ACL') ")
                End If
                
                .AppendLine(String.Format(" ) as t order by t.LAST_UPD desc, t.LIT_TYPE, t.LIT_NAME"))
            Else
                .AppendFormat("select distinct top 500 t.LIT_ID, t.LIT_NAME, t.LAST_UPD, t.DESC_TEXT, t.LIT_TYPE, t.FILE_EXT, t.FILE_SIZE, t.FTP_URL, t.RECORD_IMG, t.RECORD_ID, t.SR_TYPE, t.HYPER_LINK ")
                .AppendFormat(" from (SELECT distinct * FROM ( {0} ) AS t1  where 1=1 ", String.Join(" union ", arrSql.ToArray()))
                
                'If ddl1.SelectedValue <> "" Then
                '    If ddl2.SelectedValue <> "" Then
                '        .AppendFormat(" and t1.PD = '{0}' ", ddl2.SelectedValue)
                '    Else
                '        .AppendFormat(" and t1.PD in (SELECT DISTINCT [EDIVISION] as display_name FROM [SAP_PRODUCT] WHERE [EGROUP] = '{0}' AND [EDIVISION] is not null) ", ddl1.SelectedValue)
                '    End If
                'End If
                
                If arrTypes.Count > 0 Then
                    .AppendFormat(" and t1.LIT_TYPE in ({0}) and t1.LIT_ID not in (select z.Thumbnail_ID from PIS.dbo.LITERATURE_EXTEND z where z.Thumbnail_ID is not null or z.Thumbnail_ID !='') ", String.Join(",", arrTypes.ToArray()))
                End If
                If Not Session("account_status").ToString.Equals("CP", StringComparison.OrdinalIgnoreCase) AndAlso Not Session("account_status").ToString.Equals("EZ", StringComparison.OrdinalIgnoreCase) Then
                    .AppendFormat(" and t1.LIT_TYPE not in ('Presentation (For CP Only)') ")
                End If
                If ddlPeriod.SelectedValue = "0" Then
                    .AppendFormat(" and t1.LAST_UPD between dateadd(year,-2,getdate()) and getdate() ")
                End If
                
                'If arrTypes.Count = 0 AndAlso ddl1.SelectedValue = "" AndAlso ddl2.SelectedValue = "" Then .AppendFormat(" and 1!=1 ")
                
                'If Session("lang_id") = "ENG" Then
                '    If Util.GetCheckedCountFromCheckBoxList(cblTechSearch) > 0 Then
                '        .AppendFormat(" and t1.LANG in ('ENU','ENG','ALL') and (t1.RBU='ACL' or t1.RBU='') ")
                '    Else
                '        .AppendFormat(" and t1.LANG in ('ENU','ENG','ALL') and t1.RBU='ACL' ")
                '    End If
                'End If
               
                If CInt(dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(FLASHLEADS_RBU) from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU where SIEBEL_RBU in (select RBU from SIEBEL_ACCOUNT where ERP_ID ='{0}') and FLASHLEADS_RBU in ('AEU','ANA')", Session("COMPANY_ID")))) > 0 Then
                    .AppendFormat(" and t1.LANG in ('ENU','ENG','ALL') and t1.RBU in ('ADL','AUK','AIT','AFR','AEE','ABN','AMEA-Medical','AINNOCORE','AAC','AAU','AENC','ANADMF','AUK','ASG','AMY','ACL') ")
                End If
                
                .AppendLine(String.Format(" ) as t order by t.LAST_UPD desc, t.LIT_TYPE, t.LIT_NAME"))
            End If
        End With
        'If User.Identity.Name = "rudy.wang@advantech.com.tw" Then Response.Write(sb.ToString + "<br/>")
        Return sb.ToString()
        
    End Function
    
    Public Function GetLitSql(ByVal BUList As List(Of String)) As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" SELECT DISTINCT a.LITERATURE_ID AS LIT_ID, a.LIT_NAME, '' AS PRODUCTS, CONVERT(nvarchar, a.PART_NO) AS PART_NO, ")
            .AppendFormat(" a.LAST_UPDATED AS LAST_UPD, isnull(a.LIT_DESC, '') AS DESC_TEXT, a.FILE_EXT, a.FILE_NAME, a.FILE_LOCATION AS FILE_REV_NUM, ")
            .AppendFormat(" ISNull(a.FILE_SIZE, 0) AS FILE_SIZE, a.LIT_TYPE, a.PRIMARY_BU AS BU, '' AS PHOTO, 1000 AS score, ")
            .AppendFormat(" (SELECT TOP 1 z.edivision FROM sap_product z WHERE  z.part_no = CONVERT(nvarchar, a.part_no)) AS PD, '' AS RECORD_ID, ")
            .AppendFormat(" isnull(c.Thumbnail_ID, '') AS RECORD_IMG, '' AS HYPER_LINK, '' AS BAA, '' AS SR_NUM, '' AS SR_TYPE, ")
            .AppendFormat(" b.TXT_CONTENT, a.FTP_URL, a.PRIMARY_ORG_ID AS RBU, a.LANG ")
            .AppendFormat(" FROM (select a.* from PIS.dbo.v_LITERATURE a left join PIS.dbo.Model_lit b on a.LITERATURE_ID=b.literature_id) a LEFT JOIN SIEBEL_LITERATURE_DETAIL b ON a.LITERATURE_ID = b.LIT_ID ")
            .AppendFormat(" LEFT JOIN PIS.dbo.LITERATURE_EXTEND c ON a.LITERATURE_ID = c.LIT_ID ")
            If BUList IsNot Nothing AndAlso BUList.Count > 0 Then
                .AppendFormat(" LEFT JOIN PIS.dbo.Model_lit d on a.LITERATURE_ID=d.literature_id ")
                .AppendFormat(" LEFT JOIN PIS.dbo.MODELCATEGORY_INTERESTEDPRODUCT_MAPPING e on d.model_name=e.ITEM_DISPLAYNAME ")
                .AppendFormat(" LEFT JOIN CurationPool.dbo.LEADSFLASH_PRODUCTCATEGORY_INTERESTEDPRODUCT f on e.INTERESTED_PRODUCT_DISPLAY_NAME=f.Interested_Product ")
                .AppendFormat(" where f.Product_Group in ({0}) ", String.Join(",", BUList.ToArray()))
            End If
            
        End With
        Return sb.ToString
    End Function
    
    Public Function GetTechSql(ByVal BUList As List(Of String)) As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" SELECT DISTINCT Replace(a.SR_ID, '+', '%2B') AS LIT_ID, a.SOLUTION_NAME AS LIT_NAME, a.PRODUCTS, '' AS PART_NO, ")
            .AppendFormat(" dbo.DateOnly(a.UPDATED_DATE) AS LAST_UPD, isnull(a.SR_DESCRIPTION, '') AS DESC_TEXT, '' AS FILE_EXT, '' AS FILE_NAME, ")
            .AppendFormat(" '' AS FILE_REV_NUM, 0 AS FILE_SIZE, a.SEARCH_TYPE AS LIT_TYPE, '' AS BU, '' AS PHOTO, 1000 AS score, isnull(b.edivision, '') AS PD, ")
            .AppendFormat(" '' AS RECORD_ID, '' AS RECORD_IMG, '' AS HYPER_LINK, '' AS BAA, a.SR_NUM, a.SR_TYPE, '' AS TXT_CONTENT, ")
            .AppendFormat(" '' AS FTP_URL, '' AS RBU, 'ALL' AS LANG ")
            .AppendFormat(" FROM SIEBEL_SUPPORT AS a LEFT JOIN SAP_PRODUCT b ON a.PRODUCTS = b.MODEL_NO ")
            If BUList IsNot Nothing AndAlso BUList.Count > 0 Then
                .AppendFormat(" LEFT JOIN PIS.dbo.MODELCATEGORY_INTERESTEDPRODUCT_MAPPING e on b.MODEL_NO=e.ITEM_DISPLAYNAME ")
                .AppendFormat(" LEFT JOIN CurationPool.dbo.LEADSFLASH_PRODUCTCATEGORY_INTERESTEDPRODUCT f on e.INTERESTED_PRODUCT_DISPLAY_NAME=f.Interested_Product ")
                .AppendFormat(" where f.Product_Group in ({0}) ", String.Join(",", BUList.ToArray()))
            End If
        End With
        Return sb.ToString
    End Function
    
    Public Function GetCMSSql(ByVal arrTypes As ArrayList) As String
        Dim sb As New StringBuilder
        'With sb
        '    .AppendFormat(" SELECT DISTINCT '' AS LIT_ID, a.TITLE AS LIT_NAME, '' AS PRODUCTS, '' AS PART_NO, a.LASTUPDATED AS LAST_UPD, isnull(a.ABSTRACT,'') AS DESC_TEXT, ")
        '    .AppendFormat(" '' AS FILE_EXT, '' AS FILE_NAME, '' AS FILE_REV_NUM, 0 AS FILE_SIZE, a.CATEGORY_NAME AS LIT_TYPE, '' AS BU, '' AS PHOTO, ")
        '    .AppendFormat(" 1000 AS score, '' AS PD, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, a.BAA, '' AS SR_NUM, '' AS SR_TYPE, ")
        '    .AppendFormat(" b.CMS_CONTENT AS TXT_CONTENT, a.HYPER_LINK AS FTP_URL, a.RBU, 'ALL' AS LANG ")
        '    .AppendFormat(" FROM WWW_RESOURCES AS a LEFT JOIN WWW_RESOURCES_DETAIL b ON a.RECORD_ID = b.RECORD_ID ")
        '    If Not Session("account_status") = "EZ" Then .AppendFormat(" WHERE a.IS_INTERNAL_ONLY=0 ")
        'End With
        Dim iclbbu As Integer = Util.GetCheckedCountFromCheckBoxList(cblBU), pickCorp As Boolean = False
        If iclbbu = 1 Then
            For i As Integer = 0 To cblBU.Items.Count - 1
                If cblBU.Items(i).Selected AndAlso cblBU.Items(i).Value = "CORP" Then
                    pickCorp = True
                End If
            Next
        End If
        With sb
            .AppendFormat(" SELECT DISTINCT '' AS LIT_ID, a.TITLE COLLATE SQL_Latin1_General_CP1_CI_AS AS LIT_NAME , '' AS PRODUCTS, '' AS PART_NO, a.LASTUPDATED AS LAST_UPD, isnull(a.ABSTRACT COLLATE SQL_Latin1_General_CP1_CI_AS,'') AS DESC_TEXT, ")
            .AppendFormat(" '' AS FILE_EXT, '' AS FILE_NAME, '' AS FILE_REV_NUM, a.FILESIZE as FILE_SIZE, a.CATEGORY_NAME COLLATE SQL_Latin1_General_CP1_CI_AS AS LIT_TYPE , '' AS BU, '' AS PHOTO, ")
            .AppendFormat(" 1000 AS score, '' AS PD, a.RECORD_ID COLLATE SQL_Latin1_General_CP1_CI_AS as RECORD_ID, a.RECORD_IMG COLLATE SQL_Latin1_General_CP1_CI_AS as RECORD_IMG, a.HYPER_LINK COLLATE SQL_Latin1_General_CP1_CI_AS as HYPER_LINK, b.ATTRIBUTE COLLATE SQL_Latin1_General_CP1_CI_AS as BAA, '' AS SR_NUM, '' AS SR_TYPE, ")
            .AppendFormat(" e.CMS_CONTENT COLLATE SQL_Latin1_General_CP1_CI_AS AS TXT_CONTENT, a.HYPER_LINK COLLATE SQL_Latin1_General_CP1_CI_AS AS FTP_URL, c.ATTRIBUTE COLLATE SQL_Latin1_General_CP1_CI_AS as RBU, 'ALL' AS LANG ")
            .AppendFormat(" FROM [CurationPool].[dbo].CmsToMyAdv_Resources a ")
            .AppendFormat(" LEFT JOIN [CurationPool].[dbo].CmsToMyAdv_ResourcesExt b ON a.RECORD_ID=b.RECORD_ID and b.TYPE='BAA'")
            .AppendFormat(" LEFT JOIN [CurationPool].[dbo].CmsToMyAdv_ResourcesExt c ON a.RECORD_ID=c.RECORD_ID and c.TYPE='RBU'")
            .AppendFormat(" LEFT JOIN [CurationPool].[dbo].CmsToMyAdv_ResourcesExt d ON a.RECORD_ID=d.RECORD_ID and d.TYPE='LOCATION'")
            .AppendFormat(" LEFT JOIN [CurationPool].[dbo].CmsToMyAdv_ResourcesContent e ON a.RECORD_ID = e.RECORD_ID ")
            If pickCorp Then
                .AppendFormat(" LEFT JOIN [CurationPool].[dbo].CmsToMyAdv_ResourcesExt g ON a.RECORD_ID=g.RECORD_ID and g.TYPE='Corporate Level'")
            End If
            If iclbbu > 0 Then
                .AppendFormat(" LEFT JOIN [CurationPool].[dbo].CmsToMyAdv_ResourcesExt f ON a.RECORD_ID=f.RECORD_ID and f.TYPE='BU'")
            End If
            .AppendFormat(" WHERE 1=1 ")
            'If Not Session("account_status") = "EZ" Then .AppendFormat(" and d.ATTRIBUTE like '%MyAdvantech%' ")
            
            '2015-03-23 Iris:
            '所有CMS Corp. Site/MyAdvantech素材皆出現在Marketing Material Search
            '若有勾選Image/CIS, 則限定抓有MyAdvantech屬性的這兩個Type的資料
            Dim attrList As New List(Of String)
            If arrTypes.Count > 0 Then attrList.Add(" a.CATEGORY_NAME in (" + String.Join(",", arrTypes.ToArray()) + ") ")
            If arrTypes.Contains("'corporate identity system (cis)'") Or arrTypes.Contains("'image'") Then
                attrList.Add(" (d.ATTRIBUTE like '%Myadvantech%' and a.CATEGORY_NAME in ('image','corporate identity system (cis)')) ")
            End If
            
            Dim buList As New List(Of String)
            If iclbbu > 0 Then
                '2015-03-18 Wen: 若有勾選Corporate這個BU, 則只抓有CORP這個屬性和RBU='ACL'的資料
                '2016-02-02 Erica: 若有勾選Corporate這個BU, 資料不限RBU都可抓出
                If pickCorp Then buList.Add(" (g.ATTRIBUTE like 'CORP') ")
                
                Dim str As String = "", iBU As Integer = 0
                For i As Integer = 0 To cblBU.Items.Count - 1
                    If cblBU.Items(i).Selected AndAlso cblBU.Items(i).Value <> "CORP" Then
                        If iBU <> 0 Then '第一筆前面不用逗號，其他都要
                            str += ","
                        End If
                        
                        str += "'" + cblBU.Items(i).Value.Trim + "'"
                        iBU += 1
                    End If
                Next
                If str <> "" Then buList.Add(" f.ATTRIBUTE in (" + str + ") ")
                
            End If
            Dim sql As String = ""
            If attrList.Count > 0 Then sql += " and (" + String.Join(" or ", attrList.ToArray()) + ")"
            If buList.Count > 0 Then sql += " and (" + String.Join(" or ", buList.ToArray()) + ")"
            .AppendFormat(sql)
            
        End With
        Return sb.ToString
    End Function
    
    Public Function GetSupportDownloadSql(ByVal BUList As List(Of String)) As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" SELECT DISTINCT a.DOC_ID AS LIT_ID, a.DESCRIPTION AS LIT_NAME, a.SEARCH_KEY AS PRODUCTS, '' AS PART_NO, a.ISSUE_DATE AS LAST_UPD, isnull(a.DESCRIPTION,'') AS DESC_TEXT, ")
            .AppendFormat(" '' AS FILE_EXT, '' AS FILE_NAME, '' AS FILE_REV_NUM, 0 AS FILE_SIZE, a.DOC_TYPE AS LIT_TYPE, '' AS BU, '' AS PHOTO, ")
            .AppendFormat(" 1000 AS score, '' AS PD, a.DOC_ID as RECORD_ID, a.RECORD_IMG, '' AS HYPER_LINK, '' AS BAA, '' AS SR_NUM, a.SOURCE AS SR_TYPE, ")
            .AppendFormat(" '' AS TXT_CONTENT, '' AS FTP_URL, '' as RBU, 'ALL' AS LANG ")
            .AppendFormat(" FROM SUPPORT_DOWNLOAD a ")
            If BUList IsNot Nothing AndAlso BUList.Count > 0 Then
                .AppendFormat(" left join SIEBEL_SR_PRODUCT c on a.DOC_ID=c.SR_ID ")
                .AppendFormat(" left join PIS.dbo.model_product d on c.PART_NO=d.part_no or c.PART_NO=d.model_name ")
                .AppendFormat(" LEFT JOIN PIS.dbo.MODELCATEGORY_INTERESTEDPRODUCT_MAPPING e on d.model_name=e.ITEM_DISPLAYNAME ")
                .AppendFormat(" LEFT JOIN CurationPool.dbo.LEADSFLASH_PRODUCTCATEGORY_INTERESTEDPRODUCT f on e.INTERESTED_PRODUCT_DISPLAY_NAME=f.Interested_Product ")
                .AppendFormat(" where f.Product_Group in ({0}) ", String.Join(",", BUList.ToArray()))
            End If
        End With
        Return sb.ToString
    End Function
    
    Protected Sub btn_Search_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If dlSearchOption.SelectedIndex = 1 Then
            Try
                dbUtil.dbExecuteNoQuery("My", String.Format("insert into user_query_log (userid,keyword,ip,type) values ('{0}','{1}','{2}','{3}')", Session("user_id"), txt_Key.Text.Trim.Replace("'", "''"), Request.ServerVariables("REMOTE_ADDR"), "Literature"))
            Catch ex As Exception

            End Try
            gv1.PageIndex = 0 : src1.SelectCommand = GetSql()
            'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "MYLITSEARCH by " + User.Identity.Name, src1.SelectCommand, False, "", "")
            'If Me.txt_Key.Text.Length >= 3 Then Response.Filter = New eBizAEU.HighlighterFilter(Response.Filter, HttpUtility.UrlDecode(Me.txt_Key.Text))
            gv1.EmptyDataText = "No search results were found.<br /> Please try again or submit the feedback form to let us know what you need . "
        End If
        If dlSearchOption.SelectedIndex = 0 Then
            Response.Redirect("/Product/ProductSearch.aspx?key=" + Me.txt_Key.Text)
        End If
        If dlSearchOption.SelectedIndex = 2 Then
            Response.Redirect("/Product/AdvWebSearch.aspx?key=" + Me.txt_Key.Text)
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
    
    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
        If Me.txt_Key.Text.Length >= 3 Then Response.Filter = New eBizAEU.HighlighterFilter(Response.Filter, HttpUtility.UrlDecode(Me.txt_Key.Text))
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
                
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim img As Image = CType(e.Row.Cells(1).FindControl("imgPic"), Image)
            Dim lit_type As String = e.Row.Cells(3).Text.ToLower
            'Dim rbu As String = DataBinder.Eval(e.Row.DataItem, "RBU").ToString.ToLower()
            If Session("account_status") <> "EZ" AndAlso Session("org_id") = "US01" Then
                'If lit_type = "product - roadmap" AndAlso rbu <> Session("rbu").ToString.ToLower() Then e.Row.Visible = False
            End If
            '2015-03-31 Wen 要求顯示CIS圖片
            If lit_type = "video" Or lit_type = "case study" Or lit_type = "news" Or lit_type = "white papers" Or lit_type = "image" Or _
                lit_type Like "*corporate identity system (cis)*" Or lit_type = "presentation slide" Or _
                lit_type = "webcast" Or lit_type = "podcast" Or lit_type = "ecatalog" Or lit_type = "edm / enewsletter" Or lit_type = "poster" Then
                If DataBinder.Eval(e.Row.DataItem, "RECORD_IMG").ToString <> "" Then
                    If DataBinder.Eval(e.Row.DataItem, "RECORD_IMG").ToString = "http://wfcache.advantech.com/EZ/CMSUpLoadFiles/" _
                        OrElse DataBinder.Eval(e.Row.DataItem, "RECORD_IMG").ToString = "http://employeezone.advantech.com.tw/CMSUploadFiles/" Then
                        img.Visible = False
                    Else
                        img.ImageUrl = DataBinder.Eval(e.Row.DataItem, "RECORD_IMG").ToString
                        img.Visible = True
                    End If
                End If
                CType(e.Row.Cells(2).FindControl("lblDesc"), Label).Visible = True
                Dim url As String = "http://resources.advantech.com.tw/sso/autologin.aspx?tempid=" + Session("TempId") + "&id=" + Session("user_id") + "&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=" + DataBinder.Eval(e.Row.DataItem, "RECORD_ID")
                If lit_type = "white papers" Or lit_type = "corporate identity system (cis)" Then url = DataBinder.Eval(e.Row.DataItem, "HYPER_LINK")
                
                'JJ 2014/4/24：Wen要求取消內頁連結
                'CType(e.Row.Cells(2).FindControl("lblSubject"), Label).Text = "<a href='' id='" + CType(e.Row.Cells(2).FindControl("lblSubject"), Label).ClientID + "_link' onmouseover='javascript:GetUrl(""" + CType(e.Row.Cells(2).FindControl("lblSubject"), Label).ClientID + "_link" + """,""" + url + """)' onmousedown='javascript:TracePage(""cms"",""" + lit_type + """,""" + DataBinder.Eval(e.Row.DataItem, "RECORD_ID") + """,""" + CType(e.Row.Cells(2).FindControl("lblSubject"), Label).ClientID + "_link" + """,""" + url + """)'>" + CType(e.Row.Cells(2).FindControl("lblSubject"), Label).Text + "</a>"
                CType(e.Row.Cells(2).FindControl("lblSubject"), Label).Text = "<p style='font-weight: bold;'>" + CType(e.Row.Cells(2).FindControl("lblSubject"), Label).Text + "</p>"
                If lit_type = "news" Or lit_type = "case study" Then
                    CType(e.Row.Cells(2).FindControl("lblDesc"), Label).Text = CType(e.Row.Cells(2).FindControl("lblDesc"), Label).Text + "<br/>" + String.Format("<div id='{0}'><a href='javascript:void(0);' onclick=""GetNews('{0}', '{1}', '{2}');"">Read {2}</a><div>", "NewsNode_" + e.Row.RowIndex.ToString, DataBinder.Eval(e.Row.DataItem, "RECORD_ID").ToString, lit_type)
                End If
                If e.Row.Cells(6).Text <> "" Then
                    e.Row.Cells(6).Text = "<a href='" + e.Row.Cells(6).Text + "' target='_blank'>Go</a>"
                Else
                    e.Row.Cells(6).Text = ""
                End If
            Else
                Dim url As String = ""
                If lit_type = "bios" Or lit_type = "certificate" Or lit_type = "driver" Or lit_type = "faq" Or _
                    lit_type = "firmware" Or lit_type = "specification" Or lit_type = "utility" Or lit_type = "manual" Then
                   
                    If DataBinder.Eval(e.Row.DataItem, "SR_TYPE").ToString = "Knowledge Base" Then
                      
                        e.Row.Cells(6).Text = "<a href='http://" + Request.ServerVariables("HTTP_HOST") + "/Product/SR_Detail.aspx?SR_ID=" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString + "&C=" + lit_type + "' target='_blank'>Download</a>"
                    Else
                        If lit_type = "manual" AndAlso DataBinder.Eval(e.Row.DataItem, "SR_TYPE").ToString = "" Then
                            url = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString
                            e.Row.Cells(6).Text = "<a href='' id='" + e.Row.Cells(4).ClientID + "_link' onmouseover='javascript:GetUrl(""" + e.Row.Cells(4).ClientID + "_link" + """,""" + url + """)' onmousedown='javascript:TracePage(""lit"",""" + lit_type + """,""" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString + """,""" + e.Row.Cells(4).ClientID + "_link" + """,""" + url + """)'>Download</a>"
                          
                        Else
                            If lit_type = "certificate" AndAlso DataBinder.Eval(e.Row.DataItem, "SR_TYPE").ToString = "PLM" Then
                                e.Row.Cells(6).Text = "<a href='http://downloadt.advantech.com/productfile/PLM_Cer/" + DataBinder.Eval(e.Row.DataItem, "RECORD_IMG").ToString + "' target='_blank'>Download</a>"
                            Else
                               
                                e.Row.Cells(6).Text = "<a href='http://" + Request.ServerVariables("HTTP_HOST") + "/Product/SR_Download.aspx?SR_ID=" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString + "&C=" + lit_type + "' target='_blank'>Download</a>"
                            End If
                        End If
                    End If
                Else
                    'If DataBinder.Eval(e.Row.DataItem, "PHOTO").ToString <> "" Then
                    'img.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "PHOTO").ToString.Split(".")(0)
                    Dim file_ext As String = DataBinder.Eval(e.Row.DataItem, "FILE_EXT").ToString.ToUpper()
                    If file_ext = "JPG" Or file_ext = "GIF" Or file_ext = "JPEG" Or file_ext = "PNG" Or file_ext = "BMP" Then
                        img.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString.Split(".")(0)
                        img.Visible = True
                    ElseIf file_ext = "TIF" OrElse file_ext = "TIFF" Then
                        img.ImageUrl = "~/Includes/TIFF_Handler.ashx?LIT_ID=" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString.Split(".")(0)
                        img.Visible = True
                    ElseIf file_ext = "PDF" Then
                        If DataBinder.Eval(e.Row.DataItem, "RECORD_IMG").ToString <> "" Then
                            img.ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "RECORD_IMG").ToString
                            img.Visible = True
                        End If
                    End If
                    
                    'End If
                    If lit_type = "product - roadmap" OrElse lit_type = "product - sales kit" OrElse lit_type = "presentation (for cp only)" Then
                        url = Util.GetRuntimeSiteUrl + "/Includes/SpecialMaterialDownload.ashx?LIT_ID=" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString
                        e.Row.Cells(6).Text = "<a href='" + url + "' target='_blank'>Download</a>"
                    Else
                        url = Util.GetRuntimeSiteUrl + "/Product/Unzip_File.aspx?Literature_Id=" + DataBinder.Eval(e.Row.DataItem, "LIT_ID").ToString
                        e.Row.Cells(6).Text = "<a href='" + url + "' target='_blank'>" + CType(e.Row.Cells(4).FindControl("lb_format"), Label).Text + "</a>"
                        'e.Row.Cells(6).Text = "<a href='" + url + "' target='_blank'>Go</a>"
                    End If
                End If
                
            End If
            
            If e.Row.Cells(5).Text = "" Or e.Row.Cells(5).Text = "&nbsp;" Then
                e.Row.Cells(5).Text = "0k"
            Else
                e.Row.Cells(5).Text = FormatNumber(CDbl(e.Row.Cells(5).Text) / 1024, 0, , , -2) + "k"
            End If
            
            e.Row.Cells(7).Text = CDate(e.Row.Cells(7).Text).ToString("yyyy/MM/dd")
        End If
            If e.Row.RowType = DataControlRowType.Header Then
                If Session("account_status") = "EZ" Or Session("account_status") = "CP" Then
                    e.Row.Cells(6).Text = "Source"
                Else
                    e.Row.Cells(6).Text = "Download"
                End If
            End If
    End Sub
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetNewsContent(ByVal recid As String, ByVal Type As String) As String
        Try
            Return Util.GetCMSContent(recid, Type)
        Catch ex As Exception
            Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "Error GetWWWNews", "recid:" + recid + "<br/>" + ex.ToString, False, "", "")
        End Try
        Return "Content currently not available"
    End Function
    
    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 999999
    End Sub
    
    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If gv1.PageIndex = 0 And gv1.Rows.Count = 0 And txt_Key.Text.Trim <> "" Then
            txt_Key.Text = txt_Key.Text.Replace("*", "") + "*"
            src1.SelectCommand = GetSql()
        End If
        
        'JJ 2014/4/24：Wen 希望CMS不要出現type，但因為會有複合的狀況，所以就只有在單一筆的狀況隱藏
        'JJ 2014/4/24：Wen 希望只選eDM/eNewsletter時不需要Image,也不需要size
        'JJ 2014/4/29：Wen 希望poster時隱藏size
        If hf_LitSearch.Value <> "" Then
            If hf_LitSearch.Value = "1" Then
                      
                If cblLitSearch.SelectedValue = "eDM / eNewsletter" Then
                    'Image
                    gv1.HeaderRow.Cells(1).Visible = False 'image
                    gv1.HeaderRow.Cells(3).Visible = False 'type
                    gv1.HeaderRow.Cells(5).Visible = False 'size
                    For Each li As GridViewRow In gv1.Rows
                        li.Cells(1).Visible = False
                        li.Cells(3).Visible = False
                        li.Cells(5).Visible = False
                    Next
                Else
                    'JJ 2014/4/29：Wen 希望poster時隱藏size
                    If cblLitSearch.SelectedValue = "Poster" Then
                        gv1.HeaderRow.Cells(3).Visible = False 'Type
                        gv1.HeaderRow.Cells(5).Visible = False 'size
                        For Each li As GridViewRow In gv1.Rows
                            li.Cells(3).Visible = False
                            li.Cells(5).Visible = False
                        Next
                    Else
                        gv1.HeaderRow.Cells(3).Visible = False 'Type
                        For Each li As GridViewRow In gv1.Rows
                            li.Cells(3).Visible = False
                            
                        Next
                    End If
                End If
            Else
                gv1.HeaderRow.Cells(1).Visible = True
                gv1.HeaderRow.Cells(3).Visible = True
                gv1.HeaderRow.Cells(5).Visible = True
                For Each li As GridViewRow In gv1.Rows
                    li.Cells(3).Visible = True
                    li.Cells(1).Visible = True
                    li.Cells(5).Visible = True
                Next
            End If
        End If
        
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") = "rudy.wang@advantech.com.tw" Then Session("lang_id") = "ENG"
        If Session("user_id") = "" Then
            If cblLitSearch.Items.FindByText("Advertisement") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Advertisement"))
            If cblLitSearch.Items.FindByText("Banner") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Banner"))
            If cblLitSearch.Items.FindByText("Brochure") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Brochure"))
            If cblLitSearch.Items.FindByText("Catalogue") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Catalogue"))
            If cblLitSearch.Items.FindByText("DM") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("DM"))
            If cblLitSearch.Items.FindByText("Event Poster") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Event Poster"))
            If cblLitSearch.Items.FindByText("Event Presentation") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Event Presentation"))
            If cblLitSearch.Items.FindByText("Marketing Kit") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Marketing Kit"))
            If cblLitSearch.Items.FindByText("Product Roadmap") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Product Roadmap"))
            If cblLitSearch.Items.FindByText("Sales Kit") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Sales Kit"))
            If cblLitSearch.Items.FindByText("presentation slide") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("presentation slide"))
        Else
            If Session("account_status").ToString() = "GA" Then
                If cblLitSearch.Items.FindByText("Advertisement") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Advertisement"))
                If cblLitSearch.Items.FindByText("Banner") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Banner"))
                If cblLitSearch.Items.FindByText("Brochure") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Brochure"))
                If cblLitSearch.Items.FindByText("Catalogue") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Catalogue"))
                If cblLitSearch.Items.FindByText("DM") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("DM"))
                If cblLitSearch.Items.FindByText("Event Poster") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Event Poster"))
                If cblLitSearch.Items.FindByText("Event Presentation") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Event Presentation"))
                If cblLitSearch.Items.FindByText("Marketing Kit") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Marketing Kit"))
                If cblLitSearch.Items.FindByText("Product Roadmap") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Product Roadmap"))
                If cblLitSearch.Items.FindByText("Sales Kit") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Sales Kit"))
                If cblLitSearch.Items.FindByText("presentation slide") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("presentation slide"))
            End If
            If Session("account_status").ToString() = "CP" Then
                If cblLitSearch.Items.FindByText("Marketing Kit") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Marketing Kit"))
                If cblLitSearch.Items.FindByText("Sales Kit") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Sales Kit"))
            End If
            'Frank 2012/11/21: KA user can not search Sales Kit
            If Session("account_status").ToString().Equals("KA", StringComparison.InvariantCultureIgnoreCase) Then
                If cblLitSearch.Items.FindByText("Sales Kit") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Sales Kit"))
            End If
        End If
        If Session("account_status").ToString() <> "CP" AndAlso Session("account_status").ToString() <> "EZ" Then
            If cblLitSearch.Items.FindByText("Presentation (For CP Only)") IsNot Nothing Then cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Presentation (For CP Only)"))
        End If
        
        If Not Page.IsPostBack Then
            If Util.IsInternalUser(Session("user_id")) = False Then
                'If cblLitSearch.Items.FindByText("eDM") IsNot Nothing Then
                '    cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("eDM"))
                'End If
                If cblLitSearch.Items.FindByText("Event Report") IsNot Nothing Then
                    cblLitSearch.Items.Remove(cblLitSearch.Items.FindByText("Event Report"))
                End If
            End If
            If Request("key") IsNot Nothing Then
                Me.txt_Key.Text = HttpUtility.UrlDecode(Request("key")) + "*"
                If Request("LitType") <> "" Then
                    Dim arrLit() As String = Request("LitType").Split(",")
                    If arrLit.Length > 0 Then
                        For Each lit As String In arrLit
                            cblLitSearch.Items(CInt(lit)).Selected = True
                        Next
                    End If
                Else
                    cblLitSearch.Items.FindByValue("Product - Datasheet").Selected = True
                End If
                btn_Search_Click(Nothing, Nothing)
            End If
        End If
        'If Session("user_id") = "rudy.wang@advantech.com.tw" Then Session("account_status") = "CP"
    End Sub
    
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
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <link rel="stylesheet" href="../Includes/js/jquery-ui.css">
   <script type="text/javascript" src='../Includes/js/jquery-latest.min.js'></script>
   <script type="text/javascript" src='../Includes/js/jquery-ui.js'></script>
    <style>
    .chkBoxList tr
    {
       height:16px;
    }
    .chkBoxList td
    {
       width:300px;
    }
</style>

<script type="text/javascript">
    $(document).ready(function () {
    //收折Marking type項目
    $('#search').click(function () {
        $('#div_search').toggle('blind');
    });
});
    function TracePage(type, lit_type, rid, ID, url) {
        document.getElementById(ID).href = "javascript:void(0)";
        window.open("MaterialRedirectPage.aspx?Type=" + type + "&C=" + lit_type + "&rid=" + rid + "&url=" + url);
    }
    function GetUrl(ID, url) {
        document.getElementById(ID).href=url;
    }
</script>
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        > Material Search</div>
    <table width="100%">
        <tr align="center">
                        <td><img src="../Images/newlogo.gif" alt="" width="140" height="52" id="search"/></td>
        </tr>
        <tr style="height:2px">
                       <td></td>
        </tr>
        <tr>
            <td align="center">
              <div id="div_search">
                <table cellpadding="0" cellspacing="0" border="0">
                    
                    <tr align="center">
                        <td valign="middle">
                        
                            <asp:UpdatePanel runat="server" ID="upLitType" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <table width="100%" border="0">
                                        <tr>                                    
                                            <td align="center" colspan="2">
                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"                                             
                                                    ServiceMethod="GetPartNo" TargetControlID="txt_Key" ServicePath="~/Services/AutoComplete.asmx" 
                                                    MinimumPrefixLength="1" FirstRowSelected="true" />
                                                <asp:Panel runat="server" ID="PanelQueryBtn" DefaultButton="btn_Search">
                                                    <table>
                                                        <tr>
                                                            <td><asp:TextBox Height="16" ID="txt_Key" runat="server" Width="350"/></td>
                                                            <td width="5"></td>
                                                            <td>Published Date: </td>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="ddlPeriod" AutoPostBack="false">
                                                                    <asp:ListItem Text="In Two Years" Value="0" />
                                                                    <asp:ListItem Text="All" Value="1" />
                                                                </asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </td>
                                        </tr>
                                        <tr><td></td><td align="left"><font size="4" color="navy"><b>Material Type</b></font></td></tr>
                                        <tr align="center" runat="server" id="trAdvSearchRow" visible="true">
                                            <td></td>
                                            <td align="center">
                                                <table width="100%" align="center" border="0">
                                                    <tr>
                                                        <td align="left" valign="top">&nbsp;&nbsp;<font color="#3397EE" size="3">Technical Document</font></td>
                                                    </tr>
                                                    <tr valign="top">
                                                        <td valign="top" align="left">
                                                            <asp:CheckBoxList runat="server" ID="cblTechSearch" RepeatColumns="4" CssClass="chkBoxList" RepeatLayout="Table">
                                                                <asp:ListItem Text="BIOS" Value="BIOS" />
                                                                <asp:ListItem Text="Certificate (Product)" Value="Certificate" />
                                                                <asp:ListItem Text="Driver" Value="Driver" />
                                                                <asp:ListItem Text="FAQ" Value="FAQ" />
                                                                <asp:ListItem Text="Firmware" Value="Firmware" />
                                                                <asp:ListItem Text="Specification" Value="Specification" />
                                                                <asp:ListItem Text="Utility" Value="Utility" />
                                                                <asp:ListItem Text="User Manual" Value="Manual" />
                                                            </asp:CheckBoxList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="left" valign="top">&nbsp;&nbsp;<font color="#3397EE" size="3">Marketing</font></td>
                                                    </tr>
                                                    <tr valign="top">
                                                        <td valign="top" align="left">                                                            
                                                            <asp:CheckBoxList runat="server" ID="cblLitSearch" RepeatColumns="4" CssClass="chkBoxList" RepeatLayout="Table">
                                                                <%--<asp:ListItem Text="Advertisement" Value="Advertisement" />--%>
                                                                <%--<asp:ListItem Text="Banner" Value="Banner" />
                                                                <asp:ListItem Text="Brochure" Value="Brochure" />--%>
                                                                <asp:ListItem Text="Case Study" Value="Case Study" />
                                                                <%--<asp:ListItem Text="Catalogue" Value="Catalogue" />--%>
                                                                <asp:ListItem Text="Certificate Logo" Value="Certificate-" />
                                                                <asp:ListItem Text="Datasheet" Value="Product - Datasheet" />                                                                
                                                                <%--<asp:ListItem Text="DM" Value="DM" />--%>
                                                                <%--<asp:ListItem Text="eDM" Value="eDM" />--%>
                                                                <asp:ListItem Text="eDM / eNewsletter" Value="eDM / eNewsletter" />
                                                                <%--<asp:ListItem Text="Event Poster" Value="Event Poster" />
                                                                <asp:ListItem Text="Event Presentation" Value="Event Presentation" />--%>
                                                                <%--<asp:ListItem Text="Marketing Kit" Value="Marketing Kit" />--%>
                                                                <asp:ListItem Text="News" Value="News" />
                                                                <asp:ListItem Text="Photo" Value="Photo" />
                                                                <asp:ListItem Text="Podcast" Value="Podcast" />
                                                                <%--<asp:ListItem Text="Press Release" Value="Press Release" />--%>
                                                                <%--<asp:ListItem Text="Product Roadmap" Value="Product - Roadmap" />--%>
                                                                <asp:ListItem Text="Sales Kit" Value="Product - Sales Kit" />
                                                                <asp:ListItem Text="Video" Value="Video" />
                                                                <asp:ListItem Text="White Papers" Value="White Papers" />
                                                                <asp:ListItem Text="Webcast" Value="Webcast" />
                                                                <asp:ListItem Text="eCatalog" Value="eCatalog" />
                                                                <%--<asp:ListItem Text="Presentation (For CP Only)" Value="Presentation (For CP Only)" />--%>
                                                                <asp:ListItem Text="Poster" Value="Poster" />
                                                                <asp:ListItem Text="Presentation Slide" Value="presentation slide" />
                                                                <asp:ListItem Text="Image" Value="Image" />
                                                                <asp:ListItem Text="Corporate Identity System (CIS)" Value="Corporate Identity System (CIS)" />
                                                            </asp:CheckBoxList>                                                                                                      
                                                        </td>
                                                    </tr>
                                                     <tr>
                                                        <td align="left"><font size="4" color="navy"><b>Business Sector</b></font></td>
                                                    </tr>
                                                    <tr valign="top" style="width:100%;">
                                                        <td valign="top" align="left" style="width:100%;">                                                            
                                                            <asp:CheckBoxList runat="server" ID="cblBU" RepeatColumns="2" 
                                                                CssClass="chkBoxList" RepeatLayout="Table" Width="100%">
                                                                <asp:ListItem Text="(BU)Embedded Boards & Design-in Services" Value="(BU)Embedded Boards & Design-in Services" />
                                                                <asp:ListItem Text="(BU)Industrial Automation" Value="(BU)Industrial Automation" />
                                                                <asp:ListItem Text="(BU)Intelligent Systems" Value="(BU)Intelligent Systems" />
                                                                <asp:ListItem Text="(BU)Digital Healthcare" Value="(BU)Digital Healthcare" />
                                                                <asp:ListItem Text="(BU)Digital Logistics & Digital Retail" Value="(BU)Digital Logistics & Digital Retail" />
                                                                <asp:ListItem Text="Corporate" Value="CORP" />
                                                            </asp:CheckBoxList>                                                                                                      
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <%--<tr><td></td><td align="left"><font size="4" color="navy"><b>Product Category</b></font></td></tr>
                                        <tr>
                                            <td></td>
                                            <td align="left">
                                                <table cellpadding="0" cellspacing="0" width="100%" border="0">
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                        <td><span class="text">Product Group Section:</span></td>
                                                        <td align="left" colspan="2">
                                                            <asp:DropDownList runat="server" ID="ddl1" Width="280">
                                                            </asp:DropDownList>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                        <td><span class="text">Product Division Section:</span></td>
                                                        <td align="left" colspan="2"><asp:DropDownList runat="server" ID="ddl2" Width="280"></asp:DropDownList></td>
                                                    </tr>
                                                </table>
                                                <ajaxToolkit:CascadingDropDown runat="server" ID="cdd1" Category="Catalog" TargetControlID="ddl1" PromptText="All" LoadingText="Loading..." ServicePath="~/Services/ProductCatalog.asmx" ServiceMethod="getCatalog" />
                                                <ajaxToolkit:CascadingDropDown runat="server" ID="cdd2" Category="Category" TargetControlID="ddl2" PromptText="Please Select...." LoadingText="Loading..." ServicePath="~/Services/ProductCatalog.asmx" ServiceMethod="getCatalog" ParentControlID="ddl1" />
                                           </td>
                                        </tr>--%>
                                    </table>
                                </ContentTemplate>
                            </asp:UpdatePanel> 
                         
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
                                <asp:ListItem Value="Product" />
                                <asp:ListItem Value="Material" Selected="True" Text="Marketing material & Support" />
                                <asp:ListItem Value="Websites" Text="Websites" />
                            </asp:RadioButtonList> 
                        </td>
                    </tr>                    
                </table>
               </div>
            </td>
        </tr>
        <tr>
            <td>                
                <asp:Panel runat="server" ID="PanelGv">
                    <asp:GridView runat="server" ID="gv1" Width="100%" AutoGenerateColumns="False" HeaderStyle-HorizontalAlign="Center"
                        AllowPaging="True" AllowSorting="True" PageSize="100" DataSourceID="src1" PagerSettings-Position="TopAndBottom" 
                        OnPageIndexChanging="gv1_PageIndexChanging" OnSelectedIndexChanging="gv1_SelectedIndexChanging" 
                        OnRowDataBound="gv1_RowDataBound" OnSorting="gv1_Sorting" 
                        OnDataBound="gv1_DataBound" OnRowCreated="gv1_RowCreated">
                        <HeaderStyle HorizontalAlign="Center" />
                        <PagerSettings Position="TopAndBottom" />
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
                                <ItemStyle ForeColor="#636563" HorizontalAlign="Center" VerticalAlign="Top" 
                                    Width="50px" />
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Image">
                                <ItemTemplate>
                                    <asp:Image runat="server" ID="imgPic" Width="220px" Visible="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Description" SortExpression="lit_name">
                                <ItemTemplate>
                                    <table style="table-layout:fixed">
                                        <tr>
                                            <td valign="top">
                                                <asp:Label runat="server" ID="lblSubject" Text='<%#util.Highlight(txt_Key.Text, Eval("lit_name")) %>' Font-Bold="true" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top" style="width: 410; word-wrap: break-word"><asp:Label runat="server" ID="lblDesc" Text='<%#util.Highlight(txt_Key.Text, Eval("DESC_TEXT")) %>' Width="410px" Visible="false" /></td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Type" DataField="lit_type" 
                                SortExpression="lit_type" ItemStyle-HorizontalAlign="Center" >
                            <ItemStyle HorizontalAlign="Center" />
                            </asp:BoundField>
                            <asp:TemplateField HeaderText="Format" SortExpression="FILE_EXT" 
                                Visible="False">
                                <EditItemTemplate>
                                    <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("FILE_EXT") %>'></asp:TextBox>
                                </EditItemTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="lb_format" runat="server" Text='<%# Bind("FILE_EXT") %>'></asp:Label>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Size" DataField="FILE_SIZE" 
                                SortExpression="FILE_SIZE" ItemStyle-HorizontalAlign="Center" >
                            <ItemStyle HorizontalAlign="Center" />
                            </asp:BoundField>
                            <asp:BoundField DataField="FTP_URL" HeaderText="FTP_URL" >
                            <ItemStyle HorizontalAlign="Center" />
                            </asp:BoundField>
                            <asp:BoundField DataField="LAST_UPD" HeaderText="Last Updated Date" 
                                ItemStyle-HorizontalAlign="Center" SortExpression="LAST_UPD">
                            <ItemStyle HorizontalAlign="Center" />
                            </asp:BoundField>
                            <asp:HyperLinkField HeaderText="FTP_URL" DataTextField="FTP_URL" 
                                 DataNavigateUrlFields="FTP_URL" 
                                ItemStyle-HorizontalAlign="Center" DataTextFormatString="Go" 
                                Visible="False" >
                            <ItemStyle HorizontalAlign="Center" />
                            </asp:HyperLinkField>
                        </Columns>
                    </asp:GridView>
                    <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="src1_Selecting" />   
                    <asp:HiddenField ID="hf_LitSearch" runat="server" />
                </asp:Panel>
            </td>
        </tr>
    </table>
    <script type="text/javascript">
        function GetNews(nodeid, recid, cattype) {
            document.getElementById(nodeid).innerHTML = "<img src='/Images/loading2.gif' alt='Loading News...' width='35' height='35' />Loading...";
            PageMethods.GetNewsContent(recid, cattype,
                function (pagedResult, eleid, methodName) {
                    document.getElementById(nodeid).innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    //alert(error.get_message());
                    //document.getElementById('div_myrecentitems').innerHTML="";
                });
            }
            document.getElementById('<%= PanelGv.ClientID %>').scrollIntoView(true);
    </script>
</asp:Content>

