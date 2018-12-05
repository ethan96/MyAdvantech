Imports Microsoft.VisualBasic

Public Class MyLog
    Enum PageType
        CMS
        eDM
        DownloadDocument
        ViewProduct
        WishList
    End Enum

    Enum CMSCategory
        Video
        News
        eDM
        CaseStudy
        eCatalog
        Podcast
        WhitePaper
        Webcast
    End Enum

    Enum LiteratureType
        Advertisement
        Banner
        Brochure
        Catalogue
        CertificateLogo
        Datasheet
        DM
        eDM
        EventPoster
        EventPresentation
        MarketIntelligence
        Photo
        PressRelease
        ProductRoadmap
        SalesKit
    End Enum

    Enum TechnicalDocument
        BIOS
        Certificate
        Driver
        FAQ
        Firmware
        Specification
        Utility
        UserManual
    End Enum

    Enum ModelCategory
        EmbeddedBoards
        AppliedComputing
        IndustrialAutomation
        DesignManufacturing
        DigitalSignage
        MedicalComputing
    End Enum

    Enum eDMCategory
        IndustrialAutomation
        MedicalComputing
        Transportation
        Logistics
        DigitalSignage
        BuildingAutomation
        EmbeddedBoards
        Gaming
        Networks
        Industry4_0
        SmartEnvironment
        Embedded_IoT_News
        IntelligentHospital
    End Enum

    Public Shared Function GetSql(ByVal type As String) As String
        If [Enum].GetNames(GetType(MyLog.CMSCategory)).Contains(type) Then
            Return GetCMSSql(type)
        ElseIf [Enum].GetNames(GetType(MyLog.LiteratureType)).Contains(type) Then
            Return GetLitSql(type)
        ElseIf [Enum].GetNames(GetType(MyLog.TechnicalDocument)).Contains(type) Then
            Return GetTechSql(type)
        Else : Return ""
        End If
    End Function

    Public Shared Function GetCMSSql(ByVal cms_type As String) As String
        If cms_type = CMSCategory.eDM.ToString Then Return GetEDM()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct t.data_value as row_id, t.record_img as img_url, t.title, t.description, '' as file_ext from ")
            .AppendFormat(" (select top 1000 a.data_value, b.record_img, b.title, b.abstract as description ")
            .AppendFormat(" from my_viewed_list a left join www_resources b on a.data_value=b.record_id where b.RBU in ('ACL') ")
            .AppendFormat(" and a.user_id='{0}' and a.type='{1}' ", HttpContext.Current.Session("user_id"), cms_type)
            .AppendFormat(" order by a.log_date desc) as t ")
        End With
        Return sb.ToString
    End Function

    Public Shared Function GetEDM(Optional ByVal AllView As Boolean = False) As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select a.row_id, a.description, a.actual_send_date as timestamp, a.email_subject as title, '../Includes/GetThumbnail.ashx?RowId='+a.row_id as img_url, '' as file_ext ")
            .AppendFormat(" from campaign_master a ")
            If Not AllView Then .AppendFormat(" left join campaign_contact_list b on a.row_id=b.campaign_row_id ")
            .AppendFormat(" where a.is_public=1 and a.actual_send_date is not null ")
            If Not AllView Then .AppendFormat(" and b.email_issent=1 and b.contact_email = '{0}' ", HttpContext.Current.Session("user_id"))
            .AppendFormat(" order by a.actual_send_date desc")
        End With
        Return sb.ToString
    End Function

    Public Shared Function GetLitSql(ByVal lit_type As String) As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct t.data_value as row_id, t.record_img as img_url, t.title, t.description, t.file_ext from ")
            .AppendFormat(" (select top 1000 a.data_value, isnull(c.Thumbnail_ID, '') as record_img, b.LIT_NAME as title, isnull(b.LIT_DESC,'') as description, b.FILE_EXT ")
            .AppendFormat(" from my_viewed_list a left join PIS.dbo.v_LITERATURE b on a.data_value=b.literature_id LEFT JOIN PIS.dbo.LITERATURE_EXTEND c ON b.LITERATURE_ID = c.LIT_ID where ")
            .AppendFormat(" a.user_id='{0}' and a.type='{1}' ", HttpContext.Current.Session("user_id"), lit_type)
            .AppendFormat(" order by a.log_date desc) as t ")
        End With
        Return sb.ToString
    End Function

    Public Shared Function GetTechSql(ByVal tech_type As String) As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct t.data_value as row_id, t.record_img as img_url, t.title, t.description, t.file_ext from ")
            .AppendFormat(" (select top 1000 a.data_value, '' as record_img, isnull(b.FILE_NAME,'') as title, isnull(b.FILE_DESC,'') as description, isnull(b.FILE_EXT,'') as FILE_EXT ")
            .AppendFormat(" from my_viewed_list a left join SIEBEL_SR_SOLUTION_FILE b on a.data_value=b.file_id where ")
            .AppendFormat(" a.user_id='{0}' and a.type='{1}' ", HttpContext.Current.Session("user_id"), tech_type)
            .AppendFormat(" order by a.log_date desc) as t ")
        End With
        Return sb.ToString
    End Function

    Public Shared Function GetViewProduct(ByVal prod_type As String) As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select top 30 t.data_value as row_id, t.type, t.MODEL_DESC, t.IMAGE_ID, t.TUMBNAIL_IMAGE_ID from ")
            .AppendFormat(" (select distinct top 100 a.data_value, a.type, isnull(b.MODEL_DESC,'') as MODEL_DESC, isnull(b.IMAGE_ID,'') as IMAGE_ID, isnull(c.TUMBNAIL_IMAGE_ID,'') as TUMBNAIL_IMAGE_ID ")
            .AppendFormat(" , (select top 1 z.log_date from my_viewed_list z where z.data_value=a.data_value and z.user_id=a.user_id and z.page_type=a.page_type and z.type=a.type order by z.log_date desc) as log_date ")
            .AppendFormat(" from MY_VIEWED_LIST a left join [PIS].dbo.model b on a.data_value=b.MODEL_NAME left join PIS_SIEBEL_PRODUCT c on a.data_value=c.PART_NO ")
            .AppendFormat(" where a.user_id='{0}' and a.page_type='{1}' ", HttpContext.Current.Session("user_id"), PageType.ViewProduct.ToString)
            If prod_type <> "" Then .AppendFormat(" and a.type='{0}' ", prod_type.ToString)
            .AppendFormat(" ) as t order by t.log_date desc ")
        End With
        Return sb.ToString
    End Function

    Public Shared Function UpdateLog(ByVal user_id As String, ByVal type As String, ByVal data_value As String, ByVal page_type As String) As Boolean
        dbUtil.dbGetDataTable("MY", String.Format("insert into my_viewed_list (user_id, type, data_value, ip, page_type) values ('{0}','{1}','{2}','{3}','{4}')", user_id, type, data_value, Util.GetClientIP(), page_type))
        Return True
    End Function

    Public Shared Function GetCateType(ByVal type As String) As String
        Select Case LCase(type)
            Case "video"
                Return MyLog.CMSCategory.Video.ToString
            Case "news"
                Return MyLog.CMSCategory.News.ToString
            Case "case study"
                Return MyLog.CMSCategory.CaseStudy.ToString
            Case "white papers"
                Return MyLog.CMSCategory.WhitePaper.ToString
            Case "podcast"
                Return MyLog.CMSCategory.Podcast.ToString
            Case "webcast"
                Return MyLog.CMSCategory.Webcast.ToString
            Case "ecatalog"
                Return MyLog.CMSCategory.eCatalog.ToString
            Case "advertisement"
                Return MyLog.LiteratureType.Advertisement.ToString
            Case "banner"
                Return MyLog.LiteratureType.Banner.ToString
            Case "brochure"
                Return MyLog.LiteratureType.Brochure.ToString
            Case "catalogue"
                Return MyLog.LiteratureType.Catalogue.ToString
            Case "certificate logo"
                Return MyLog.LiteratureType.CertificateLogo.ToString
            Case "datasheet"
                Return MyLog.LiteratureType.Datasheet.ToString
            Case "dm"
                Return MyLog.LiteratureType.DM.ToString
            Case "edm"
                Return MyLog.LiteratureType.eDM.ToString
            Case "event poster"
                Return MyLog.LiteratureType.EventPoster.ToString
            Case "event presentation"
                Return MyLog.LiteratureType.EventPresentation.ToString
            Case "market intelligence"
                Return MyLog.LiteratureType.MarketIntelligence.ToString
            Case "photo"
                Return MyLog.LiteratureType.Photo.ToString
            Case "press release"
                Return MyLog.LiteratureType.PressRelease.ToString
            Case "product roadmap"
                Return MyLog.LiteratureType.ProductRoadmap.ToString
            Case "sales kit"
                Return MyLog.LiteratureType.SalesKit.ToString
            Case "bios"
                Return MyLog.TechnicalDocument.BIOS.ToString
            Case "certificate"
                Return MyLog.TechnicalDocument.Certificate.ToString
            Case "driver"
                Return MyLog.TechnicalDocument.Driver.ToString
            Case "faq"
                Return MyLog.TechnicalDocument.FAQ.ToString
            Case "firmware"
                Return MyLog.TechnicalDocument.Firmware.ToString
            Case "specification"
                Return MyLog.TechnicalDocument.Specification.ToString
            Case "utility"
                Return MyLog.TechnicalDocument.Utility.ToString
            Case "manual"
                Return MyLog.TechnicalDocument.UserManual.ToString
        End Select
        Return ""
    End Function

    Public Shared Function GetModelRoot(ByVal model_no As String) As String
        Dim mdt As DataTable = dbUtil.dbGetDataTable("MY", _
                                                String.Format( _
                                                " SELECT model_no, parent_category_id1, category_name1, category_type1,  " + _
                                                " parent_category_id2, category_name2, category_type2, parent_category_id3,  " + _
                                                " category_name3, parent_category_id4, category_name4,  " + _
                                                " parent_category_id5, category_name5, parent_category_id6 " + _
                                                " FROM PIS_MODEL_HIERARCHY " + _
                                                " WHERE model_no = '{0}' ", model_no))
        If mdt.Rows.Count > 0 Then
            With mdt.Rows(0)
                For i As Integer = 1 To 6
                    If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value Then
                        If .Item("parent_category_id" + i.ToString()).ToString() = "root" Then
                            Select Case .Item("category_name" + (i - 1).ToString())
                                Case "Applied Computing & Embedded Systems"
                                    Return MyLog.ModelCategory.AppliedComputing.ToString
                                Case "Embedded Boards & Design-in Services"
                                    Return MyLog.ModelCategory.EmbeddedBoards.ToString
                                Case "Design & Manufacturing / Networks & Telecom"
                                    Return MyLog.ModelCategory.DesignManufacturing.ToString
                                Case "Industrial Automation"
                                    Return MyLog.ModelCategory.IndustrialAutomation.ToString
                                Case "Digital Signage & Self-Service"
                                    Return MyLog.ModelCategory.DigitalSignage.ToString
                                Case "Medical Computing"
                                    Return MyLog.ModelCategory.MedicalComputing.ToString
                            End Select
                        End If
                    End If
                Next
            End With
        End If
        Return ""
    End Function

    Public Shared Function GetEDMSolutionMapping(ByVal type As eDMCategory) As ArrayList
        Dim solution() As String = GetENewsSolutionMappingList(type)
        For i As Integer = 0 To solution.Length - 1
            solution(i) = "'" + solution(i) + "'"
        Next
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select value, ID from CMS_SECTOR_LOV where value in ({0})", String.Join(",", solution)))
        Dim arrItem As New ArrayList
        For Each row As DataRow In dt.Rows
            arrItem.Add("'" + row.Item("ID") + "'")
        Next
        Return arrItem
    End Function

    Public Shared Function GetENewsSolutionMappingList(ByVal type As eDMCategory) As String()
        Select Case type
            Case eDMCategory.IndustrialAutomation
                Return {"(Sector)Environmental & Facility Management", "(Sector)Factory Automation", "(Sector)Machine Automation", "(Sector)Oil, Gas & Water", "(Sector)Power & Energy"}
            Case eDMCategory.MedicalComputing
                Return {"(Sector)AMiS", "(Sector)Digital Healthcare"}
            Case eDMCategory.Transportation
                Return {"(Sector)Intelligent Transportation"}
            Case eDMCategory.Logistics
                Return {"(Sector)Digital Logistics"}
            Case eDMCategory.DigitalSignage
                Return {"(Sector)Digital Retail & Hospitality"}
            Case eDMCategory.BuildingAutomation
                Return {"(Sector)Intelligent Building"}
            Case eDMCategory.EmbeddedBoards
                Return {"(Sector)Embedded Core", "(Sector)Video Solutions"}
            Case eDMCategory.Gaming
                Return {"(Sector)Gaming"}
            Case eDMCategory.Networks
                Return {"(Sector)Network & Telecom"}
        End Select
    End Function

    Public Shared Sub AddMyWishProduct(ByVal email As String, ByVal part_no As String)
        Try
            Dim model_no As String = ""
            Dim obj As Object = dbUtil.dbExecuteScalar("PIS", String.Format("select top 1 model_name from model_product where part_no ='{0}' and relation='product'", part_no))
            If obj IsNot Nothing And Not IsDBNull(obj) Then
                model_no = obj.ToString
            Else
                obj = dbUtil.dbExecuteScalar("MY", String.Format("select model_no from SAP_PRODUCT where part_no ='{0}'", part_no))
                If obj IsNot Nothing And Not IsDBNull(obj) Then model_no = obj.ToString
            End If
            If model_no <> "" Then
                Dim mdt As DataTable = dbUtil.dbGetDataTable("MY", _
                                                    String.Format( _
                                                    " SELECT model_no, parent_category_id1, category_name1, category_type1,  " + _
                                                    " parent_category_id2, category_name2, category_type2, parent_category_id3,  " + _
                                                    " category_name3, parent_category_id4, category_name4,  " + _
                                                    " parent_category_id5, category_name5, parent_category_id6 " + _
                                                    " FROM PIS_MODEL_HIERARCHY " + _
                                                    " WHERE model_no = '{0}' ", model_no))
                If mdt.Rows.Count > 0 Then
                    With mdt.Rows(0)
                        For i As Integer = 1 To 6
                            If .Item("parent_category_id" + i.ToString()) IsNot DBNull.Value Then
                                If .Item("parent_category_id" + i.ToString()).ToString() = "root" Then
                                    dbUtil.dbGetDataTable("MY", String.Format("insert into my_viewed_list (user_id, type, data_value, ip, page_type) values ('{0}','{1}','{2}','{3}','WishList')", email, .Item("category_name" + (i - 2).ToString()), part_no, Util.GetClientIP()))
                                End If
                            End If
                        Next
                    End With
                End If
            End If
        Catch ex As Exception
            Throw New Exception("Add Wish List failed:" + ex.ToString())
        End Try
    End Sub
End Class
