<%@ Page Title="MyAdvantech - SBU Campaign Overview" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub gvCampaigns_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.Header Then

        End If
        If e.Row.RowType = DataControlRowType.DataRow Then
            'CType(e.Row.FindControl("srcRowCMS"), SqlDataSource).SelectParameters("UCID").DefaultValue = CType(e.Row.FindControl("hdUCID"), HiddenField).Value
            If CType(e.Row.FindControl("lblMReadyTime"), Label).Text = "" Then
                If Not Integer.TryParse(e.Row.Cells(0).Text, 0) Then
                    'CType(e.Row.FindControl("lblMReadyTime"), Label).Text = "<i><font color='red'>Ready by " +
                        'dbUtil.dbExecuteScalar("MY", "select top 1 CONVERT(VARCHAR, a.StartDate, 111) from UNICADBP.dbo.UA_Campaign a where a.CampaignCode='" + e.Row.Cells(0).Text + "'") + "</font/</i>"
                Else
                    CType(e.Row.FindControl("lblMReadyTime"), Label).Text = "<i><font color='red'>Ready by " +
                    dbUtil.dbExecuteScalar("UCAMP", "select top 1 CONVERT(VARCHAR, a.CREATED_DATE, 111) from CAMPAIGN a where a.Campaign_ID='" + e.Row.Cells(0).Text + "'") + "</font/</i>"
                End If
                CType(e.Row.FindControl("btnDownload"), ImageButton).Visible = False
            End If
            Dim hlOffer As HyperLink = CType(e.Row.FindControl("hlOffer"), HyperLink)
            hlOffer.NavigateUrl = "UNICA_SBU_Campaigns_New.aspx?Type=P&CMSID=" + CType(e.Row.FindControl("hdnCMSID"), HiddenField).Value
            If e.Row.Cells(0).Text = "C000000369" Then
                hlOffer.Text = hlOffer.Text.Replace("2013Q1_iService Campaign_", "")
            Else
                If hlOffer.Text <> "" AndAlso hlOffer.Text.Contains("_") Then hlOffer.Text = hlOffer.Text.Substring(hlOffer.Text.LastIndexOf("_") + 1)
            End If
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Util.IsInternalUser(HttpContext.Current.User.Identity.Name) Then btnToXls.Visible = True
        If Request("CMSID") IsNot Nothing Then
            Dim CWS As New CorpAdminWS.AdminWebService
            Dim ws As New WWWLocal.AdvantechWebServiceLocal
            Dim strUrl As String = ""
            Try
                'strUrl = CWS.Get_EDM_Source_File_By_CMD_ID(Request("CMSID"))
                'If String.IsNullOrEmpty(strUrl) Then
                '    Response.Clear()
                '    Response.Write("Cannot find URL for CMS ID:" + Request("CMSID"))
                '    Response.End()
                'Else

                'End If
                If Request("Type") = "P" Then
                    Try
                        Dim ds As DataSet = ws.getCMSMaster(Request("CMSID"))
                        If ds.Tables.Count > 0 AndAlso ds.Tables(0).Rows.Count > 0 AndAlso ds.Tables(0).Rows(0).Item("HYPER_LINK").ToString <> "" Then
                            strUrl = ds.Tables(0).Rows(0).Item("HYPER_LINK").ToString
                            'Response.Redirect(ds.Tables(0).Rows(0).Item("HYPER_LINK").ToString)
                        Else
                            'Response.Write("Cannot find URL for CMS ID:" + Request("CMSID"))
                        End If
                    Catch ex As Exception

                    End Try

                    If strUrl = "" OrElse strUrl = "http://" Then
                        Dim objUrl As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(HYPER_LINK,'') from CurationPool.dbo.CmsToMyAdv_Resources where RECORD_ID='{0}'", Request("CMSID")))
                        If objUrl IsNot Nothing AndAlso objUrl.ToString <> "http://" Then
                            Response.Redirect(objUrl.ToString)
                        Else
                            Response.Write("Cannot find URL for CMS ID:" + Request("CMSID"))
                        End If
                    Else
                        Response.Redirect(strUrl)
                    End If
                ElseIf Request("Type") = "D" Then
                    'Response.Redirect(strUrl)
                End If
            Catch ex As Exception
                'Response.Write("Cannot find URL for CMS ID:" + Request("CMSID") + "<br/>" + ex.ToString)
            End Try
        End If

    End Sub

    Function GetSQL() As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select * from ( ")
            '.AppendFormat("     select a.CampaignID, a.CampaignCode, a.Name as CampaignName, a.Description,  c.NAME as Creator, d.NAME as LastUpdBy,  ")
            '.AppendFormat("     CONVERT(VARCHAR, (select top 1 z1.CreateDate from [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer z inner join [ACLSTNR12].UNICADBP.dbo.UA_Offer z1 on z.OfferID=z1.OfferID where z.CampaignID=a.CampaignID order by z1.CreateDate), 111) As MaterialCreateDate,  ")
            '.AppendFormat("     IsNull((Select top 1 Case z.StringValue When 'Emb’Core' then 'Emb''Core' when 'NCG' then 'NC & DMS' when 'Logistics' then 'D. Logistics' when 'iService' then 'D. Retail' when 'Medical' then 'D. Healthcare' else z.StringValue end from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=100),'') as ProductGroup,  ")
            '.AppendFormat("     IsNull((Select top 1 z.StringValue from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID And z.AttributeID=111),'') as CampaignType,  ")
            '.AppendFormat("     b.Name as SBU_Name, a.CreateDate, a.StartDate, a.EndDate, f.Name as OfferName, case when f.OfferCode1 is null then '' else f.OfferCode1+'-'+f.OfferCode2+'-'+f.OfferCode3+'-'+f.OfferCode4+'-'+f.OfferCode5 end as CMS_Content_Id   ")
            '.AppendFormat("     from [ACLSTNR12].UNICADBP.dbo.UA_Campaign a inner join [ACLSTNR12].UNICADBP.dbo.UA_Folder b on a.FolderID=b.FolderID inner join [ACLSTNR12].UNICAMPP.dbo.USM_USER c on a.CreateBy=c.ID  ")
            '.AppendFormat("     inner join [ACLSTNR12].UNICAMPP.dbo.USM_USER d on a.UpdateBy=d.ID  ")
            '.AppendFormat("     left join [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer e on e.CampaignID=a.CampaignID left join [ACLSTNR12].UNICADBP.dbo.UA_Offer f on e.OfferID=f.OfferID  ")
            '.AppendFormat("     where b.FolderID in ('891','892','893','894','895','896','897','902') and a.CampaignID not in ('8','743','226')  ")
            '.AppendFormat("     union all ")
            .AppendFormat("     select a.CAMPAIGN_ID as CampaignID, cast(a.CAMPAIGN_ID as varchar) as CampaignCode, a.NAME as CampaignName, a.DESCRIPTION as Description,  ")
            .AppendFormat("     c.EMAIL_ADDRESS As Creator, d.EMAIL_ADDRESS As LastUpdBy,  ")
            .AppendFormat("     Convert(VARCHAR, (select top 1 z1.CREATED_DATE from CAMPAIGN_OFFER z inner join OFFER z1 on z.OFFER_ID=z1.OFFER_ID where z.CAMPAIGN_ID=a.CAMPAIGN_ID order by z1.CREATED_DATE), 111) as MaterialCreateDate, ")
            .AppendFormat("     e.NAME As ProductGroup, f.NAME As CAMPAIGN_TYPE, b.NAME As SBU_NAME, ")
            .AppendFormat("     a.CREATED_DATE as CreateDate, a.CREATED_DATE as StartDate, dateadd(month,1,a.CREATED_DATE) as EndDate,  ")
            .AppendFormat("     h.NAME As OfferName, h.CMS_ID as CMS_Content_Id  ")
            .AppendFormat("     from CAMPAIGN a inner join CAMPAIGN_GROUP b on a.GROUP_ID=b.GROUP_ID ")
            .AppendFormat("     inner join USER_PROFILE c on a.CREATED_BY=c.USER_ID ")
            .AppendFormat("     left join USER_PROFILE d on a.LAST_UPDATED_BY=d.USER_ID ")
            .AppendFormat("     inner join CAMPAIGN_ATTRIBUTE e on a.PRODUCT_GROUP=e.ATTRIBUTE_ID ")
            .AppendFormat("     inner join CAMPAIGN_ATTRIBUTE f on a.CAMPAIGN_TYPE=f.ATTRIBUTE_ID ")
            .AppendFormat("     left join CAMPAIGN_OFFER g on a.CAMPAIGN_ID=g.CAMPAIGN_ID ")
            .AppendFormat("     left join OFFER h on g.OFFER_ID=h.OFFER_ID ")
            .AppendFormat("     where b.GROUP_ID in (22,23,24,27,28,29,30) ")
            .AppendFormat(" ) as t where 1=1 ")
            If hdnProductGroup.Value <> "" Then
                If hdnProductGroup.Value = "eStore" Then
                    .AppendFormat(" and t.SBU_Name='HQ_eStore' ")
                ElseIf hdnProductGroup.Value = "ISG" Then
                    .AppendFormat(" and (t.ProductGroup='ESG' or t.ProductGroup='ISG') ")
                Else

                    .AppendFormat(" and t.ProductGroup='{0}' ", hdnProductGroup.Value.Replace("'", "''"))
                End If
            End If
            If hdnCampType.Value <> "" Then
                .AppendFormat(" and t.CampaignType='{0}' ", hdnCampType.Value)
            End If
            If hdnDateFrom.Value <> "" AndAlso hdnDateTo.Value = "" AndAlso Date.TryParse(hdnDateFrom.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate>='{0}' ", hdnDateFrom.Value)
            End If
            If hdnDateTo.Value <> "" AndAlso hdnDateFrom.Value = "" AndAlso Date.TryParse(hdnDateTo.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate<='{0}' ", hdnDateTo.Value)
            End If
            If hdnDateFrom.Value <> "" AndAlso hdnDateTo.Value <> "" AndAlso Date.TryParse(hdnDateFrom.Value, Now) = True AndAlso Date.TryParse(hdnDateTo.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate between '{0} 00:00:00' and '{1} 23:59:59' ", hdnDateFrom.Value, hdnDateTo.Value)
            End If
            If hdnOwner.Value = "1" Then
                .AppendFormat(" and t.Creator='{0}' ", HttpContext.Current.User.Identity.Name.Split("@")(0))
            End If
            .AppendFormat(" order by t.MaterialCreateDate desc, t.OfferName ")
        End With
        Return sb.ToString
    End Function

    Protected Sub gvCampaigns_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim IsSBUUser As Boolean = False, IsRBU As Boolean = False, IsCustomer As Boolean = False, arrAccessRBU As New List(Of String)
        If Not Util.IsInternalUser(HttpContext.Current.User.Identity.Name) Then
            IsCustomer = True
        Else
            If IsSBU(HttpContext.Current.User.Identity.Name) Then
                IsSBUUser = True
            End If
            If Not IsSBU(HttpContext.Current.User.Identity.Name) AndAlso Not IsITOwner() AndAlso Not IsSystemOwner() Then
                IsRBU = True
                ddlRollOutRBU.Items.Clear()
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select distinct b.FLASHLEADS_RBU from EC_USER_PRIVILEGE a inner join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') b on a.LOV=b.SIEBEL_RBU where a.LOV_TYPE='ACCESS_RBU' and b.FLASHLEADS_RBU is not null and b.FLASHLEADS_RBU<>'SAP' and a.USERID like '{0}@%'", HttpContext.Current.User.Identity.Name.Split("@")(0)))
                For Each row As DataRow In dt.Rows
                    ddlRollOutRBU.Items.Add(New ListItem(row.Item("FLASHLEADS_RBU"), row.Item("FLASHLEADS_RBU")))
                    arrAccessRBU.Add(row.Item("FLASHLEADS_RBU").ToString)
                Next
            End If
        End If

        Dim i As Integer = 1, odd As Boolean = True, duplicate As Boolean = False
        Dim dtSBURBU As DataTable = dbUtil.dbGetDataTable("CP", "select distinct FLASHLEADS_RBU from LEADSFLASHRBU_SIEBELRBU where FLASHLEADS_RBU is not null and FLASHLEADS_RBU<>'SAP' order by FLASHLEADS_RBU")
        Dim dtRBUCamp As DataTable = dbUtil.dbGetDataTable("UCAMP", " select * from (  " +
                                                                    " Select distinct a.SBU_CAMPAIGN_CODE , 'Material Download' as TYPE, CONVERT(VARCHAR(10), a.REQUEST_DATE, 111) as DATE,  " +
                                                                    " e.FLASHLEADS_RBU from [ACLSTNR12].CurationPool.dbo.SBU_CAMPAIGN_DOWNLOAD a left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') e on a.RBU=e.SIEBEL_RBU  " +
                                                                    " where a.REQUEST_TYPE='DOWNLOAD' and e.FLASHLEADS_RBU is not null  " +
                                                                    " union  " +
                                                                    " select distinct a.SBU_CAMPAIGN_CODE , 'Target Roll-out Date' as TYPE, CONVERT(VARCHAR(10), convert(datetime,a.VALUE,111), 111) as DATE,  " +
                                                                    " e.FLASHLEADS_RBU from [ACLSTNR12].CurationPool.dbo.SBU_CAMPAIGN_DOWNLOAD a left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') e on a.RBU=e.SIEBEL_RBU  " +
                                                                    " where a.REQUEST_TYPE='ROLLOUT' and e.FLASHLEADS_RBU is not null  " +
                                                                    " union  " +
                                                                    " select * from (  " +
                                                                    " select distinct c.SBU_CAMPAIGN_CODE , '1-0 Flowchart Created Date' as TYPE, CONVERT(VARCHAR(10), (select top 1 z2.CREATED_DATE from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_UNICA z1 inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER z2 on z1.CAMPAIGN_ROW_ID=z2.ROW_ID where z1.SBU_CAMPAIGN_CODE=c.SBU_CAMPAIGN_CODE and (select top 1 z.FLASHLEADS_RBU from (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') z where z.SIEBEL_RBU=z2.REGION)=e.FLASHLEADS_RBU order by z2.CREATED_DATE), 111) as DATE,  " +
                                                                    " e.FLASHLEADS_RBU from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_UNICA c inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER d on c.CAMPAIGN_ROW_ID=d.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') e on d.REGION=e.SIEBEL_RBU  " +
                                                                    " where c.SBU_CAMPAIGN_NAME is not null and c.SBU_CAMPAIGN_CODE not in ('N/A','none','NA','ATW only','local campaign','0','.','.no') and d.IS_DISABLED=0  " +
                                                                    " ) a where a.DATE Is Not null  " +
                                                                    " union " +
                                                                    " select * from (  " +
                                                                    " select distinct cast(c2.CAMPAIGN_ID as varchar) as SBU_CAMPAIGN_CODE , '1-0 Flowchart Created Date' as TYPE, CONVERT(VARCHAR(10), (select top 1 z2.CREATED_DATE from ECAMPAIGN z1 inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER z2 on z1.ECAMPAIGN_ID=z2.ROW_ID where z1.ECAMPAIGN_ID=c.ECAMPAIGN_ID and (select top 1 z.FLASHLEADS_RBU from (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') z where z.SIEBEL_RBU=z2.REGION)=e.FLASHLEADS_RBU order by z2.CREATED_DATE), 111) as DATE,  " +
                                                                    " e.FLASHLEADS_RBU from ECAMPAIGN c inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER d on c.ECAMPAIGN_ID=d.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') e on d.REGION=e.SIEBEL_RBU  " +
                                                                    " inner join CELL c1 on c.CELL_ID=c1.CELL_ID inner join FLOWCHART c2 on c1.FLOWCHART_ID=c2.FLOWCHART_ID " +
                                                                    " where c2.CAMPAIGN_ID Is Not null And d.IS_DISABLED=0 and e.FLASHLEADS_RBU is not null  " +
                                                                    " ) a where a.DATE is not null  " +
                                                                    " union  " +
                                                                    " select distinct a.SBU_CAMPAIGN_CODE, 'Delivery' as TYPE, CONVERT(VARCHAR(10), b.ACTUAL_SEND_DATE, 111) as DATE, c.FLASHLEADS_RBU  " +
                                                                    " from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_UNICA a inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU " +
                                                                    " where b.ACTUAL_SEND_DATE is not null and a.SBU_CAMPAIGN_NAME is not null and a.SBU_CAMPAIGN_CODE not in ('N/A','none','NA','ATW only','local campaign','0','.','.no') and b.REGION<>'ACL'  " +
                                                                    " union " +
                                                                    " select distinct cast(a2.CAMPAIGN_ID as varchar) as SBU_CAMPAIGN_CODE, 'Delivery' as TYPE, CONVERT(VARCHAR(10), b.ACTUAL_SEND_DATE, 111) as DATE, c.FLASHLEADS_RBU  " +
                                                                    " from ECAMPAIGN a inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.ECAMPAIGN_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  " +
                                                                    " inner join CELL a1 on a.CELL_ID=a1.CELL_ID inner join FLOWCHART a2 on a1.FLOWCHART_ID=a2.FLOWCHART_ID " +
                                                                    " where b.ACTUAL_SEND_DATE is not null and a2.CAMPAIGN_ID is not null and b.REGION<>'ACL' and c.FLASHLEADS_RBU is not null  " +
                                                                    " union   " +
                                                                    " select g.SBU_CAMPAIGN_CODE, 'Delivery' as TYPE, 'Overdue' as DATE, g.RBU from (select * from [ACLSTNR12].CurationPool.dbo.SBU_CAMPAIGN_DOWNLOAD where REQUEST_TYPE='ROLLOUT' and RBU <>'') g  " +
                                                                    " left join (select cast(d2.CAMPAIGN_ID as varchar) as SBU_CAMPAIGN_CODE, f.FLASHLEADS_RBU, replace(replace(replace(replace(e.CREATED_BY,'ADVANTECH\',''),'AUS\',''),'AESC_NT\',''),'ACN\','') as CREATED_BY, d.ECAMPAIGN_ID as CAMPAIGN_ROW_ID  " +
                                                                    " from ECAMPAIGN d inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER e on d.ECAMPAIGN_ID=e.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') f on e.REGION=f.SIEBEL_RBU  " +
                                                                    " inner join CELL d1 on d.CELL_ID=d1.CELL_ID inner join FLOWCHART d2 on d1.FLOWCHART_ID=d2.FLOWCHART_ID inner join CAMPAIGN d3 on d2.CAMPAIGN_ID=d3.CAMPAIGN_ID inner join CAMPAIGN_GROUP d4 on d3.GROUP_ID=d4.GROUP_ID " +
                                                                    " where d4.GROUP_ID in (22,23,24,27,28,29,30) and e.ACTUAL_SEND_DATE is not null) as a on g.SBU_CAMPAIGN_CODE=a.SBU_CAMPAIGN_CODE and g.RBU=a.FLASHLEADS_RBU and g.REQUEST_BY like a.CREATED_BY+'%'  " +
                                                                    " where g.VALUE<GETDATE() And a.CAMPAIGN_ROW_ID Is null and a.FLASHLEADS_RBU is not null " +
                                                                    " ) as t order by t.DATE ")

        '                                                        " select a.SBU_CAMPAIGN_CODE, a.TYPE, case when b.SBU_CAMPAIGN_CODE is not null then 'Overdue' else a.DATE end as DATE, a.FLASHLEADS_RBU from " + _
        '                                                        " (select distinct a.SBU_CAMPAIGN_CODE, 'Delivery' as TYPE, CONVERT(VARCHAR(10), b.ACTUAL_SEND_DATE, 111) as DATE, " + _
        '                                                        " c.FLASHLEADS_RBU from CAMPAIGN_UNICA a inner join CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU " + _
        '                                                        " where b.ACTUAL_SEND_DATE is not null and a.SBU_CAMPAIGN_NAME is not null and a.SBU_CAMPAIGN_CODE not in ('N/A','none','NA')) as a left join " + _
        '                                                        " (select distinct a.SBU_CAMPAIGN_CODE , c.FLASHLEADS_RBU " + _
        '                                                        " from CAMPAIGN_UNICA a inner join CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU where a.CAMPAIGN_CODE in (select a.CAMPAIGN_CODE from CAMPAIGN_UNICA a group by a.CAMPAIGN_CODE having COUNT(a.CAMPAIGN_ROW_ID)=1) " + _
        '                                                        " and DATEADD(day,10,b.ACTUAL_SEND_DATE)<GETDATE() and a.SBU_CAMPAIGN_NAME is not null and a.SBU_CAMPAIGN_CODE not in ('N/A','none','NA')) as b on a.SBU_CAMPAIGN_CODE=b.SBU_CAMPAIGN_CODE and a.FLASHLEADS_RBU=b.FLASHLEADS_RBU "

        If IsCustomer Then gvCampaigns.Columns(7).Visible = False : gvCampaigns.Columns(9).Visible = False
        'If IsSBUUser OrElse IsRBU Then gvCampaigns.Columns(7).Visible = False

        For Each wkItem As GridViewRow In gvCampaigns.Rows
            If CInt(wkItem.RowIndex) = 0 Then
                wkItem.Cells(0).RowSpan = 1 : wkItem.Cells(1).RowSpan = 1 : wkItem.Cells(2).RowSpan = 1 : wkItem.Cells(3).RowSpan = 1 : wkItem.Cells(4).RowSpan = 1
                wkItem.Cells(7).RowSpan = 1 : wkItem.Cells(8).RowSpan = 1 : wkItem.Cells(9).RowSpan = 1
                If Not IsCustomer Then BindRBUCamp(dtSBURBU, dtRBUCamp, wkItem.Cells(0).Text, wkItem, IsRBU, arrAccessRBU)
            Else
                If wkItem.Cells(0).Text.Trim() = gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(0).Text.Trim() Then
                    gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(0).RowSpan += 1 : gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(1).RowSpan += 1
                    gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(2).RowSpan += 1 : gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(3).RowSpan += 1
                    gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(4).RowSpan += 1 : gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(7).RowSpan += 1
                    gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(8).RowSpan += 1 : gvCampaigns.Rows(CInt(wkItem.RowIndex) - i).Cells(9).RowSpan += 1

                    wkItem.Cells(0).Visible = False : wkItem.Cells(1).Visible = False : wkItem.Cells(2).Visible = False : wkItem.Cells(3).Visible = False : wkItem.Cells(4).Visible = False
                    wkItem.Cells(7).Visible = False : wkItem.Cells(8).Visible = False : wkItem.Cells(9).Visible = False
                    i = i + 1
                Else
                    If odd = True Then odd = False Else odd = True
                    wkItem.Cells(0).RowSpan = 1 : wkItem.Cells(1).RowSpan = 1 : wkItem.Cells(2).RowSpan = 1 : wkItem.Cells(3).RowSpan = 1 : wkItem.Cells(4).RowSpan = 1
                    wkItem.Cells(7).RowSpan = 1 : wkItem.Cells(8).RowSpan = 1 : wkItem.Cells(9).RowSpan = 1

                    If Not IsCustomer Then BindRBUCamp(dtSBURBU, dtRBUCamp, wkItem.Cells(0).Text, wkItem, IsRBU, arrAccessRBU)
                    i = 1
                End If
                If odd = False Then gvCampaigns.Rows(CInt(wkItem.RowIndex)).BackColor = System.Drawing.Color.FromName("#ebebeb")
            End If
        Next

        CType(gvCampaigns.HeaderRow.FindControl("ddlProductGroup"), DropDownList).SelectedValue = hdnProductGroup.Value
        If hdnShowQDate.Value = "1" Then CType(gvCampaigns.HeaderRow.FindControl("PanelDate"), Panel).Visible = True
        CType(gvCampaigns.HeaderRow.FindControl("txtDateFrom"), TextBox).Text = hdnDateFrom.Value
        CType(gvCampaigns.HeaderRow.FindControl("txtDateTo"), TextBox).Text = hdnDateTo.Value
        CType(gvCampaigns.HeaderRow.FindControl("ddlOwner"), DropDownList).SelectedValue = hdnOwner.Value
        'CType(gvCampaigns.HeaderRow.FindControl("ddlCampType"), DropDownList).SelectedValue = hdnCampType.Value

    End Sub

    Sub BindRBUCamp(ByVal dtSBURBU As DataTable, ByVal dtRBUCamp As DataTable, ByVal SBU_Campaign_Code As String, ByVal wkItem As GridViewRow, _
                    ByVal IsRBU As Boolean, ByVal arrAccessRBU As List(Of String))
        If IsRBU Then
            Dim gv As GridView = CType(wkItem.FindControl("gvRBUCamp"), GridView) : gv.Width="300"
            For i As Integer = 1 To gv.Columns.Count - 1
                If Not arrAccessRBU.Contains(gv.Columns(i).HeaderText) Then gv.Columns(i).Visible = False
            Next
        End If
        Dim dt As New DataTable
        With dt.Columns
            .Add("TYPE")
            For Each row As DataRow In dtSBURBU.Rows
                .Add(row.Item("FLASHLEADS_RBU").ToString)
            Next
            .Add("SAP")
        End With

        Dim r0 As DataRow = dt.NewRow() : r0.Item("TYPE") = "Material Download" : dt.Rows.Add(r0)
        Dim r1 As DataRow = dt.NewRow() : r1.Item("TYPE") = "Target Roll-out Date" : dt.Rows.Add(r1)
        Dim r2 As DataRow = dt.NewRow() : r2.Item("TYPE") = "1-0 Flowchart Created Date" : dt.Rows.Add(r2)
        Dim r3 As DataRow = dt.NewRow() : r3.Item("TYPE") = "Delivery" : dt.Rows.Add(r3)

        Dim camps() As DataRow = dtRBUCamp.Select("SBU_CAMPAIGN_CODE='" + SBU_Campaign_Code + "'")
        If camps.Count > 0 Then
            For Each row As DataRow In camps
                Dim rows() As DataRow = dt.Select("TYPE='" + row.Item("TYPE") + "'")
                Dim Type As String = ""
                Select Case row.Item("TYPE").ToString
                    Case "Material Download"
                        Type = "1"
                    Case "Target Roll-out Date"
                        Type = "2"
                    Case "1-0 Flowchart Created Date"
                        Type = "3"
                    Case "Delivery"
                        Type = "4"
                End Select
                Dim _date As String = row.Item("DATE").ToString
                If _date = "Overdue" Then _date = "<font color='red'>" + _date + "</font>"
                _date = "<a href='javascript:void(0);' onclick=""ShowDetail('" + SBU_Campaign_Code + "','" + row.Item("FLASHLEADS_RBU").ToString + "','" + Type + "');"">" + _date + "</a>"
                If rows.Count > 0 Then
                    rows(0).Item(row.Item("FLASHLEADS_RBU")) = _date
                Else
                    Dim r As DataRow = dt.NewRow()
                    r.Item("TYPE") = row.Item("TYPE")
                    r.Item(row.Item("FLASHLEADS_RBU")) = _date
                    dt.Rows.Add(r)
                End If
            Next
        End If
        If dt IsNot Nothing Then
            CType(wkItem.FindControl("gvRBUCamp"), GridView).DataSource = dt
            CType(wkItem.FindControl("gvRBUCamp"), GridView).DataBind()
        End If

    End Sub

    Protected Sub ddlProductGroup_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        hdnProductGroup.Value = CType(sender, DropDownList).SelectedValue
        srcCamp.SelectCommand = GetSQL()
    End Sub

    Protected Sub srcCamp_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        srcCamp.SelectCommand = GetSQL()
    End Sub

    Protected Sub btnSubmitDate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim gv As GridViewRow = CType(CType(sender, Button).NamingContainer, GridViewRow)
        hdnDateFrom.Value = CType(gv.FindControl("txtDateFrom"), TextBox).Text
        hdnDateTo.Value = CType(gv.FindControl("txtDateTo"), TextBox).Text
        srcCamp.SelectCommand = GetSQL()
    End Sub

    Protected Sub btnExpandDate_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        hdnShowQDate.Value = "1"
    End Sub

    Protected Sub ddlOwner_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        hdnOwner.Value = CType(sender, DropDownList).SelectedValue
        srcCamp.SelectCommand = GetSQL()
    End Sub

    Protected Sub btnDownload_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim SBUCampaignCode As String = CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("hdnCampaignCode"), HiddenField).Value
        Dim CMSID As String = CType(CType(CType(sender, ImageButton).NamingContainer, GridViewRow).FindControl("hdnCMSID"), HiddenField).Value
        If Util.IsInternalUser(HttpContext.Current.User.Identity.Name) AndAlso Not IsSBU(HttpContext.Current.User.Identity.Name) _
            AndAlso Not IsITOwner() Then
            'Check if Roll-out
            Dim dtRollOut As DataTable = dbUtil.dbGetDataTable("CP", String.Format("select * from SBU_CAMPAIGN_DOWNLOAD where REQUEST_BY='{0}' and SBU_CAMPAIGN_CODE='{1}' and REQUEST_TYPE='ROLLOUT'", HttpContext.Current.User.Identity.Name, SBUCampaignCode))
            If dtRollOut.Rows.Count = 0 Then
                'Get Roll Out RBU
                hdnRollOutCampaignCode.Value = SBUCampaignCode : hdnRollOutCMSID.Value = CMSID

                txtRollOutDate.Text = "" : lblErrMsg.Text = ""
                PanelRollOut.Visible = True
            Else
                DownloadCMS(SBUCampaignCode, CMSID, dtRollOut.Rows(0).Item("RBU").ToString)
            End If
        Else
            Dim RBU As String = "ATW"
            If Not Util.IsInternalUser(HttpContext.Current.User.Identity.Name) Then
                Dim obj As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ORGID from siebel_contact where email_address='{0}' and account_status<>'' and account_status is not null order by account_status ", HttpContext.Current.User.Identity.Name))
                If obj Is Nothing Then
                    obj = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ORGID from siebel_contact where email_address='{0}'", HttpContext.Current.User.Identity.Name))
                End If
                RBU = obj.ToString
            End If
            DownloadCMS(SBUCampaignCode, CMSID, RBU)
        End If
    End Sub

    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PanelRollOut.Visible = False
    End Sub

    Protected Sub btnSubmitRollOut_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Date.TryParse(txtRollOutDate.Text, Now) = False Then lblErrMsg.Text = "Roll-out date is not in a valid date format." : Exit Sub
        If ddlRollOutRBU.SelectedValue Is Nothing AndAlso ddlRollOutRBU.SelectedValue = "" Then lblErrMsg.Text = "No eDM access right. Please contact IT Owner Rudy.Wang or TC.Chen" : Exit Sub
        dbUtil.dbExecuteNoQuery("CP", String.Format("insert into SBU_CAMPAIGN_DOWNLOAD (SBU_CAMPAIGN_CODE, CMS_ID, REQUEST_BY, REQUEST_TYPE, VALUE, RBU) values ('{0}','{1}','{2}','ROLLOUT','{3}','{4}')", hdnRollOutCampaignCode.Value, hdnRollOutCMSID.Value, HttpContext.Current.User.Identity.Name, txtRollOutDate.Text, ddlRollOutRBU.SelectedValue))
        PanelRollOut.Visible = False
        DownloadCMS(hdnRollOutCampaignCode.Value, hdnRollOutCMSID.Value, ddlRollOutRBU.SelectedValue)
    End Sub

    Sub DownloadCMS(ByVal CampaignCode As String, ByVal CMSID As String, ByVal RBU As String)
        Try
            Dim CWS As New CorpAdminWS.AdminWebService
            Dim ws As New WWWLocal.AdvantechWebServiceLocal
            Dim strUrl As String = CWS.Get_EDM_Source_File_By_CMD_ID(CMSID)
            If String.IsNullOrEmpty(strUrl) Then
                Util.AjaxJSAlert(up1, "Cannot find URL for CMS ID:" + CMSID)
                gvCampaigns.DataBind()
            Else
                If Not IsSBU(HttpContext.Current.User.Identity.Name) AndAlso Not IsITOwner() AndAlso Not IsSystemOwner() AndAlso Not Util.IsInternalUser(HttpContext.Current.User.Identity.Name) Then
                    dbUtil.dbExecuteNoQuery("CP", String.Format("insert into SBU_CAMPAIGN_DOWNLOAD (SBU_CAMPAIGN_CODE, CMS_ID, REQUEST_BY, REQUEST_TYPE, RBU) values ('{0}','{1}','{2}','DOWNLOAD','{3}')", CampaignCode, CMSID, HttpContext.Current.User.Identity.Name, RBU))
                End If
                gvCampaigns.DataBind()
                Util.AjaxRedirect(up1, strUrl)
            End If
        Catch ex As Exception
            Util.AjaxJSAlert(up1, "Cannot find CMS ID")
        End Try

    End Sub

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function ShowDetail(ByVal CampaignCode As String, ByVal RBU As String, ByVal Type As String) As String
        Dim dt As New DataTable
        Select Case Type
            Case "1"
                'dt = dbUtil.dbGetDataTable("CP", String.Format("select a.REQUEST_BY as [Downloaded By], b.Name as [eDM], a.REQUEST_DATE as [Downloaded Time] from SBU_CAMPAIGN_DOWNLOAD a inner join UNICADBP.dbo.UA_Offer b on a.CMS_ID=(b.OfferCode1+'-'+b.OfferCode2+'-'+b.OfferCode3+'-'+b.OfferCode4+'-'+b.OfferCode5) inner join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on a.RBU=c.SIEBEL_RBU where a.SBU_CAMPAIGN_CODE='{0}' and a.REQUEST_TYPE='DOWNLOAD' and c.FLASHLEADS_RBU='{1}' order by a.REQUEST_DATE desc", CampaignCode, RBU))
                'dt.TableName = "Material Download"
            Case "2"
                dt = dbUtil.dbGetDataTable("CP", String.Format("select a.REQUEST_BY as [Request By], a.value as [Roll-out Date] from SBU_CAMPAIGN_DOWNLOAD a inner join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') b on a.RBU=b.SIEBEL_RBU where a.SBU_CAMPAIGN_CODE='{0}' and a.REQUEST_TYPE='ROLLOUT' and b.FLASHLEADS_RBU='{1}' order by a.REQUEST_DATE desc", CampaignCode, RBU))
                dt.TableName = "Target Roll-out Date"
            Case "3"
                If CampaignCode.StartsWith("C") Then
                    dt = dbUtil.dbGetDataTable("MY", String.Format("select a.CREATED_BY as [Created By], a.CREATED_DATE as [Created Date], '<a href=''http://ec.advantech.eu/EC/Statistics.aspx?campid='+a.row_id+''' target=''_blank''>'+a.CAMPAIGN_NAME+'</a>' as [Campaign Name], '<a href=''http://unica.advantech.com.tw/AOnline/Dashboard/Campaign_Dashboard.aspx?CampaignCode='+b.CAMPAIGN_CODE+''' target=''_blank''>Unica Report</a>' as [Unica Dashboard] from CAMPAIGN_MASTER a inner join (select distinct CAMPAIGN_CODE,(select top 1 z.ROW_ID from CAMPAIGN_MASTER z where z.ROW_ID in (select z1.CAMPAIGN_ROW_ID from CAMPAIGN_UNICA z1 where z1.CAMPAIGN_CODE=a.CAMPAIGN_CODE) order by z.CREATED_DATE) as CAMPAIGN_ROW_ID from CAMPAIGN_UNICA a inner join CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  where a.SBU_CAMPAIGN_CODE='{0}' and c.FLASHLEADS_RBU='{1}') as b on a.ROW_ID=b.CAMPAIGN_ROW_ID order by a.CREATED_DATE desc", CampaignCode, RBU))
                Else
                    dt = dbUtil.dbGetDataTable("UCAMP", String.Format(" select a.CREATED_BY as [Created By], a.CREATED_DATE as [Created Date], " +
                                                                        " '<a href=''http://ec.advantech.eu/EC/Statistics.aspx?campid='+a.row_id+''' target=''_blank''>'+a.CAMPAIGN_NAME+'</a>' as [Campaign Name], " +
                                                                        " '<a href=''http://unica.advantech.com.tw/AOnline/Dashboard/Campaign_Dashboard.aspx?CampaignCode='+b.CAMPAIGN_CODE+''' target=''_blank''>Unica Report</a>' as [Unica Dashboard]  " +
                                                                        " from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER a inner join (Select distinct cast(a2.CAMPAIGN_ID As varchar) As CAMPAIGN_CODE,(Select top 1 z.ROW_ID from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER z inner join ECAMPAIGN z1 On z1.ECAMPAIGN_ID=z.ROW_ID order by z.CREATED_DATE) As CAMPAIGN_ROW_ID from ECAMPAIGN a inner join CELL a1 On a.CELL_ID=a1.CELL_ID inner join FLOWCHART a2 On a1.FLOWCHART_ID=a2.FLOWCHART_ID inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b On a.ECAMPAIGN_ID=b.ROW_ID left join (Select Case z.SIEBEL_RBU When 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  where a2.CAMPAIGN_ID='{0}' and c.FLASHLEADS_RBU='{1}') as b on a.ROW_ID=b.CAMPAIGN_ROW_ID  " +
                                                                        " order by a.CREATED_DATE desc", CampaignCode, RBU))
                End If

                dt.TableName = "1-0 Flowchart Created Date"
            Case "4"
                'dt = dbUtil.dbGetDataTable("MY", String.Format(" select distinct a.CREATED_BY as [Delivered By], case when b.SBU_CAMPAIGN_CODE is not null then a.DATE+' <font color=''red''>Overdue</font>' else a.DATE end as [Delivery Date], '<a href=''http://ec.advantech.eu/EC/Statistics.aspx?campid='+a.CAMPAIGN_ROW_ID+''' target=''_blank''>'+a.CAMPAIGN_NAME+'</a>' as [Campaign Name], '<a href=''http://unica.advantech.com.tw/AOnline/Dashboard/Campaign_Dashboard.aspx?CampaignCode='+a.CAMPAIGN_CODE+''' target=''_blank''>Unica Report</a>' as [Unica Dashboard], a.DATE from  " + _
                '                                                " (select distinct a.SBU_CAMPAIGN_CODE, 'Delivery' as TYPE, a.CAMPAIGN_ROW_ID, b.CAMPAIGN_NAME,a.CAMPAIGN_CODE,b.CREATED_BY,CONVERT(VARCHAR(10), b.ACTUAL_SEND_DATE, 111) as DATE,  " + _
                '                                                " c.FLASHLEADS_RBU from CAMPAIGN_UNICA a inner join CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  " + _
                '                                                " where b.ACTUAL_SEND_DATE is not null and a.SBU_CAMPAIGN_NAME is not null and a.SBU_CAMPAIGN_CODE not in ('N/A','none','NA')) as a left join  " + _
                '                                                " (select distinct a.SBU_CAMPAIGN_CODE , c.FLASHLEADS_RBU, a.CAMPAIGN_ROW_ID  " + _
                '                                                " from CAMPAIGN_UNICA a inner join CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU where a.CAMPAIGN_CODE in (select a.CAMPAIGN_CODE from CAMPAIGN_UNICA a group by a.CAMPAIGN_CODE having COUNT(a.CAMPAIGN_ROW_ID)=1) " + _
                '                                                " and DATEADD(day,10,b.ACTUAL_SEND_DATE)<GETDATE() and a.SBU_CAMPAIGN_NAME is not null and a.SBU_CAMPAIGN_CODE not in ('N/A','none','NA')) as b on a.SBU_CAMPAIGN_CODE=b.SBU_CAMPAIGN_CODE and a.FLASHLEADS_RBU=b.FLASHLEADS_RBU " + _
                '                                                " where a.SBU_CAMPAIGN_CODE='{0}' and a.FLASHLEADS_RBU='{1}' order by a.DATE desc", CampaignCode, RBU))
                If CampaignCode.StartsWith("C") Then
                    dt = dbUtil.dbGetDataTable("MY", String.Format(" select distinct b.CREATED_BY as [Delivered By], CONVERT(VARCHAR(10), b.ACTUAL_SEND_DATE, 111) as [Delivery Date], '<a href=''http://ec.advantech.eu/EC/Statistics.aspx?campid='+a.CAMPAIGN_ROW_ID+''' target=''_blank''>'+b.CAMPAIGN_NAME+'</a>' as [Campaign Name], '<a href=''http://unica.advantech.com.tw/AOnline/Dashboard/Campaign_Dashboard.aspx?CampaignCode='+a.CAMPAIGN_CODE+''' target=''_blank''>Unica Report</a>' as [Unica Dashboard], b.ACTUAL_SEND_DATE " +
                                                        " from CAMPAIGN_UNICA a inner join CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU " +
                                                        " where b.ACTUAL_SEND_DATE is not null and a.SBU_CAMPAIGN_NAME is not null and a.SBU_CAMPAIGN_CODE not in ('N/A','none','NA') " +
                                                        " and a.SBU_CAMPAIGN_CODE='{0}' and c.FLASHLEADS_RBU='{1}' order by b.ACTUAL_SEND_DATE desc ", CampaignCode, RBU))
                Else
                    dt = dbUtil.dbGetDataTable("UCAMP", String.Format(" select distinct b.CREATED_BY as [Delivered By], CONVERT(VARCHAR(10), b.ACTUAL_SEND_DATE, 111) as [Delivery Date], '<a href=''http://ec.advantech.eu/EC/Statistics.aspx?campid='+a.ECAMPAIGN_ID+''' target=''_blank''>'+b.CAMPAIGN_NAME+'</a>' as [Campaign Name], '<a href=''http://unica.advantech.com.tw/AOnline/Dashboard/Campaign_Dashboard.aspx?CampaignCode='+cast(a2.CAMPAIGN_ID as varchar)+''' target=''_blank''>Unica Report</a>' as [Unica Dashboard], b.ACTUAL_SEND_DATE " +
                                                                        " from ECAMPAIGN a inner join CELL a1 on a.CELL_ID=a1.CELL_ID inner join FLOWCHART a2 on a1.FLOWCHART_ID=a2.FLOWCHART_ID inner join ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.ECAMPAIGN_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  " +
                                                                        " where b.ACTUAL_SEND_DATE is not null   " +
                                                                        " and a2.CAMPAIGN_ID='{0}' and c.FLASHLEADS_RBU='{1}' order by b.ACTUAL_SEND_DATE desc", CampaignCode, RBU))
                End If


                dt.TableName = "Delivery Date"
                dt.Columns.RemoveAt(dt.Columns.Count - 1)
        End Select
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat("<table width='100%'><tr><th align='center'>{0}</th></tr></table>", dt.TableName)
            .AppendLine("<table class='dataTable' width='100%' border='0' cellspacing='1' cellpadding='0' style='border-style:solid; border-width:1px; border-color:gray'><tr>")
            For Each col As DataColumn In dt.Columns
                .AppendFormat("<th style='background-color:#999999; color:white'>{0}</th>", col.ColumnName)
            Next
            .AppendLine("</tr>")
            For Each row As DataRow In dt.Rows
                .AppendLine("<tr>")
                For i As Integer = 0 To dt.Columns.Count - 1
                    .AppendFormat("<td align='center'>{0}</td>", row.Item(i).ToString)
                Next
                .AppendLine("</tr>")
            Next
            .AppendLine("</table>")
        End With

        'Get Overdue
        Dim sbOverdue As New StringBuilder
        If Type = "4" Then
            If CampaignCode.StartsWith("C") Then
                'dt = dbUtil.dbGetDataTable("MY", String.Format(" select g.VALUE as [Target Roll-Out Date], g.REQUEST_BY as [Requested By] from (select * from CurationPool.dbo.SBU_CAMPAIGN_DOWNLOAD where REQUEST_TYPE='ROLLOUT') g left join (select d.SBU_CAMPAIGN_CODE, f.FLASHLEADS_RBU, replace(replace(replace(replace(e.CREATED_BY,'ADVANTECH\',''),'AUS\',''),'AESC_NT\',''),'ACN\','') as CREATED_BY, d.CAMPAIGN_ROW_ID from UNICADBP.dbo.UA_Campaign a inner join UNICADBP.dbo.UA_Folder b on a.FolderID=b.FolderID " +
                                                            '" left join CAMPAIGN_UNICA d on a.CampaignCode=d.SBU_CAMPAIGN_CODE inner join CAMPAIGN_MASTER e on d.CAMPAIGN_ROW_ID=e.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') f on e.REGION=f.SIEBEL_RBU " +
                                                            '" where b.FolderID in ('891','892','893','894','895','896','897','902') and a.CampaignID not in ('8','743','226') and e.ACTUAL_SEND_DATE is not null) as a on g.SBU_CAMPAIGN_CODE=a.SBU_CAMPAIGN_CODE and g.RBU=a.FLASHLEADS_RBU and g.REQUEST_BY like a.CREATED_BY+'%' " +
                                                            '" where g.VALUE<GETDATE() and a.CAMPAIGN_ROW_ID is null and g.SBU_CAMPAIGN_CODE='{0}' and g.RBU='{1}' " +
                                                            '" order by g.VALUE ", CampaignCode, RBU))
            Else
                dt = dbUtil.dbGetDataTable("UCAMP", String.Format(" select g.VALUE as [Target Roll-Out Date], g.REQUEST_BY as [Requested By] from (select * from [ACLSTNR12].CurationPool.dbo.SBU_CAMPAIGN_DOWNLOAD where REQUEST_TYPE='ROLLOUT') g left join (select cast(d2.CAMPAIGN_ID as varchar) as SBU_CAMPAIGN_CODE, f.FLASHLEADS_RBU, replace(replace(replace(replace(e.CREATED_BY,'ADVANTECH\',''),'AUS\',''),'AESC_NT\',''),'ACN\','') as CREATED_BY, d.ECAMPAIGN_ID as CAMPAIGN_ROW_ID " +
                                                                    " from ECAMPAIGN d inner join CELL d1 on d.CELL_ID=d1.CELL_ID inner join FLOWCHART d2 on d1.FLOWCHART_ID=d2.FLOWCHART_ID inner join CAMPAIGN d3 on d2.CAMPAIGN_ID=d3.CAMPAIGN_ID inner join CAMPAIGN_GROUP d4 on d3.GROUP_ID=d4.GROUP_ID inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER e on d.ECAMPAIGN_ID=e.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') f on e.REGION=f.SIEBEL_RBU  " +
                                                                    " where d4.GROUP_ID in (22,23,24,27,28,29,30) and e.ACTUAL_SEND_DATE is not null) as a on g.SBU_CAMPAIGN_CODE=a.SBU_CAMPAIGN_CODE and g.RBU=a.FLASHLEADS_RBU and g.REQUEST_BY like a.CREATED_BY+'%'  " +
                                                                    " where g.VALUE<GETDATE() And a.CAMPAIGN_ROW_ID Is null And g.SBU_CAMPAIGN_CODE='{0}' and g.RBU='{1}'  " +
                                                                    " order by g.VALUE", CampaignCode, RBU))
            End If

            If dt.Rows.Count > 0 Then
                dt.TableName = "Overdue"
                With sbOverdue
                    .AppendFormat("<table width='100%'><tr><th align='center'><font color='red'>{0}</font></th></tr></table>", dt.TableName)
                    .AppendLine("<table class='dataTable' width='100%' border='0' cellspacing='1' cellpadding='0' style='border-style:solid; border-width:1px; border-color:gray'><tr>")
                    For Each col As DataColumn In dt.Columns
                        .AppendFormat("<th style='background-color:#999999; color:white'>{0}</th>", col.ColumnName)
                    Next
                    .AppendLine("</tr>")
                    For Each row As DataRow In dt.Rows
                        .AppendLine("<tr>")
                        For i As Integer = 0 To dt.Columns.Count - 1
                            .AppendFormat("<td align='center'>{0}</td>", row.Item(i).ToString)
                        Next
                        .AppendLine("</tr>")
                    Next
                    .AppendLine("</table><br/><br/>")
                End With
            End If
        End If

        Return sbOverdue.ToString + sb.ToString()
    End Function

    Public Function IsSBU(ByVal UserId As String) As Boolean
        If UserId Is Nothing Then Return False
        
        If CInt(dbUtil.dbExecuteScalar("UCAMP", String.Format("select COUNT(a.USER_ID) from USER_PROFILE a inner join USER_PERMISSION b on a.USER_ID=b.USER_ID where b.ATTRIBUTE_ID in (6,7,8,9,10,11,12) and a.EMAIL_ADDRESS='{0}' ", UserId))) > 0 Then
            Return True
        End If
        Return False
    End Function

    Public Function IsSystemOwner() As Boolean
        Dim SysOwners() As String = {"wen.chiang@advantech.com.tw", "mary.huang@advantech.com.tw", "gary.lee@advantech.com.tw", "tanya.lin@advantech.com.tw", "julie.fang@advantech.com.tw"}
        For Each it As String In SysOwners
            If String.Equals(HttpContext.Current.User.Identity.Name, it, StringComparison.OrdinalIgnoreCase) Then Return True
        Next
        Return False
    End Function

    Public Function IsITOwner() As Boolean
        Dim ITOwners() As String = {"tc.chen@advantech.com.tw", "rudy.wang@advantech.com.tw", "jay.lee@advantech.com", "frank.chung@advantech.com.tw"}
        For Each it As String In ITOwners
            If String.Equals(HttpContext.Current.User.Identity.Name, it, StringComparison.OrdinalIgnoreCase) Then Return True
        Next
        Return False
    End Function

    Protected Sub ddlCampType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        hdnCampType.Value = CType(sender, DropDownList).SelectedValue
        srcCamp.SelectCommand = GetSQL()
    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim arrAccessRBU As New List(Of String)
        Dim dtRBU As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select distinct b.FLASHLEADS_RBU from EC_USER_PRIVILEGE a inner join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') b on a.LOV=b.SIEBEL_RBU where a.LOV_TYPE='ACCESS_RBU' and b.FLASHLEADS_RBU is not null and b.FLASHLEADS_RBU<>'SAP' and a.USERID like '{0}@%'", HttpContext.Current.User.Identity.Name.Split("@")(0)))
        For Each row As DataRow In dtRBU.Rows
            arrAccessRBU.Add("'" + row.Item("FLASHLEADS_RBU").ToString + "'")
        Next

        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct * from ( ")
            '.AppendFormat(" select distinct t.SBU_ProductGroup as ProductGroup, t.SBU_CampaignCode, t.SBU_CampaignName, t.SBU_Owner, a.CAMPAIGN_NAME as Local_CampaignName, a.CAMPAIGN_CODE as Local_CampaignCode, a.FIRST_START_DATE from ( ")
            ''.AppendFormat(" select distinct t.*, a.CAMPAIGN_CODE, a.CAMPAIGN_NAME, a.FLASHLEADS_RBU from ( ")
            '.AppendFormat(" select distinct a.CampaignCode as SBU_CampaignCode, a.Name as SBU_CampaignName,  ")
            '.AppendFormat(" IsNull((select top 1 case z.StringValue when 'Emb’Core' then 'Emb''Core' when 'NCG' then 'NC & DMS' when 'Logistics' then 'ACG' when 'iService' then 'iServices' else z.StringValue end from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=100),'') as SBU_ProductGroup,  ")
            '.AppendFormat(" IsNull((select top 1 z.StringValue from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=111),'') as CampaignType,  ")
            '.AppendFormat(" c.NAME As SBU_Owner, Convert(VARCHAR, (select top 1 z1.CreateDate from [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer z inner join [ACLSTNR12].UNICADBP.dbo.UA_Offer z1 on z.OfferID=z1.OfferID where z.CampaignID=a.CampaignID order by z1.CreateDate), 111) As MaterialCreateDate,  ")
            '.AppendFormat(" REPLACE(REPLACE((Select z.Name+' : '+'http://my.advantech.com/My/AOnline/UNICA_SBU_Campaigns_New.aspx?Type=P&CMSID='+ case when z.OfferCode1 is null then '' else z.OfferCode1+'-'+z.OfferCode2+'-'+z.OfferCode3+'-'+z.OfferCode4+'-'+z.OfferCode5 end as Offer from [ACLSTNR12].UNICADBP.dbo.UA_OFFER z inner join [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer z1 on z.OfferID=z1.OfferID where z1.CampaignID=a.CampaignID for xml path('')),'<Offer>',''),'</Offer>','; ') as Offer  ")
            '.AppendFormat(" from [ACLSTNR12].UNICADBP.dbo.UA_Campaign a inner join [ACLSTNR12].UNICADBP.dbo.UA_Folder b on a.FolderID=b.FolderID inner join [ACLSTNR12].UNICAMPP.dbo.USM_USER c on a.CreateBy=c.ID  ")
            '.AppendFormat(" inner join [ACLSTNR12].UNICAMPP.dbo.USM_USER d on a.UpdateBy=d.ID  ")
            '.AppendFormat(" left join [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer e on e.CampaignID=a.CampaignID left join ACLSTNR12].UNICADBP.dbo.UA_Offer f on e.OfferID=f.OfferID  ")
            '.AppendFormat(" where b.FolderID in ('891','892','893','894','895','896','897','902') and a.CampaignID not in ('8','743','226') ")
            'If hdnProductGroup.Value <> "" Then
                'If hdnProductGroup.Value = "eStore" Then
                    '.AppendFormat(" and b.Name='HQ_eStore' ")
                'End If
            'End If
            '.AppendFormat(" union all ")
            .AppendFormat(" select distinct CAST(a.CAMPAIGN_ID as varchar) as SBU_CampaignCode, a.NAME as SBU_CampaignName, ")
            .AppendFormat(" g.NAME As SBU_ProductGroup, h.NAME As CampaignType,  ")
            .AppendFormat(" c.EMAIL_ADDRESS as SBU_Owner, CONVERT(VARCHAR, f.CREATED_DATE, 111) as MaterialCreateDate,  ")
            .AppendFormat(" REPLACE(REPLACE((select z.Name+' : '+'http://my.advantech.com/My/AOnline/UNICA_SBU_Campaigns_New.aspx?Type=P&CMSID='+ case when z.CMS_ID is null then '' else z.CMS_ID end as Offer from OFFER z inner join CAMPAIGN_OFFER z1 on z.OFFER_ID=z1.OFFER_ID where z1.CAMPAIGN_ID=a.CAMPAIGN_ID for xml path('')),'<Offer>',''),'</Offer>','; ') as Offer  ")
            .AppendFormat(" from CAMPAIGN a inner join CAMPAIGN_GROUP b On a.GROUP_ID=b.GROUP_ID inner join USER_PROFILE c On a.CREATED_BY=c.USER_ID ")
            .AppendFormat(" inner join USER_PROFILE d On a.LAST_UPDATED_BY=d.USER_ID   ")
            .AppendFormat(" left join CAMPAIGN_OFFER e On e.CAMPAIGN_ID=a.CAMPAIGN_ID left join OFFER f On e.OFFER_ID=f.OFFER_ID  ")
            .AppendFormat(" inner join CAMPAIGN_ATTRIBUTE g On a.PRODUCT_GROUP=g.ATTRIBUTE_ID ")
            .AppendFormat(" inner join CAMPAIGN_ATTRIBUTE h On a.CAMPAIGN_TYPE=h.ATTRIBUTE_ID ")
            .AppendFormat(" where b.GROUP_ID In (22, 23, 24, 27, 28, 29, 30)")
            .AppendFormat(" ) As t left join ")
            .AppendFormat(" ( ")
            .AppendFormat(" Select * from ")
            .AppendFormat(" ( ")
            '.AppendFormat(" Select distinct a.SBU_CAMPAIGN_CODE, a.CAMPAIGN_CODE, a.CAMPAIGN_NAME, c.FLASHLEADS_RBU,  ")
            '.AppendFormat(" (Select top 1 z.ACTUAL_SEND_DATE from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER z where z.ROW_ID In (Select z1.CAMPAIGN_ROW_ID from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_UNICA z1 where z1.CAMPAIGN_CODE= a.CAMPAIGN_CODE) order by z.ACTUAL_SEND_DATE) As FIRST_START_DATE,  ")
            '.AppendFormat(" IsNull((Select top 1 Case z.StringValue When 'Emb’Core' then 'Emb''Core' when 'NCG' then 'NC & DMS' when 'Logistics' then 'ACG' when 'iService' then 'iServices' else z.StringValue end from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=(select top 1 z1.CampaignID from [ACLSTNR12].UNICADBP.dbo.UA_Campaign z1 where z1.CampaignCode=a.CAMPAIGN_CODE) and z.AttributeID=100),'') as ProductGroup  ")
            '.AppendFormat(" from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_UNICA a inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID  ")
            '.AppendFormat(" left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  ")
            '.AppendFormat(" where a.TEST_FLAG='0' ")
            '.AppendFormat(" union all ")
            .AppendFormat(" Select distinct cast(a3.PARENT_CAMPAIGN_ID As varchar) As SBU_CAMPAIGN_CODE, cast(a3.CAMPAIGN_ID As varchar) As CAMPAIGN_CODE, a3.NAME As CAMPAIGN_NAME, c.FLASHLEADS_RBU,  ")
            .AppendFormat(" (Select top 1 z.ACTUAL_SEND_DATE from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER z where z.ROW_ID In (Select z1.ECAMPAIGN_ID from ECAMPAIGN z1 inner join CELL z2 on z1.CELL_ID=z2.CELL_ID inner join FLOWCHART z3 on z2.FLOWCHART_ID=z3.FLOWCHART_ID where z3.CAMPAIGN_ID=a2.CAMPAIGN_ID) order by z.ACTUAL_SEND_DATE) As FIRST_START_DATE,  ")
            .AppendFormat(" a4.NAME as ProductGroup  ")
            .AppendFormat(" from ECAMPAIGN a inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.ECAMPAIGN_ID=b.ROW_ID  ")
            .AppendFormat(" left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  ")
            .AppendFormat(" inner join CELL a1 on a.CELL_ID=a1.CELL_ID inner join FLOWCHART a2 on a1.FLOWCHART_ID=a2.FLOWCHART_ID inner join CAMPAIGN a3 on a2.CAMPAIGN_ID=a3.CAMPAIGN_ID ")
            .AppendFormat(" inner join CAMPAIGN_GROUP a4 On a3.GROUP_ID=a4.GROUP_ID ")
            '.AppendFormat(" where b.ACTUAL_SEND_DATE Is Not null ")
            .AppendFormat(" ) As a where 1=1 ")
            If arrAccessRBU.Count > 0 Then
                .AppendFormat(" And a.FLASHLEADS_RBU In ({0}) ", String.Join(",", arrAccessRBU.ToArray()))
            End If
            .AppendFormat(" ) As a ")
            .AppendFormat(" On t.SBU_CampaignCode=a.SBU_CAMPAIGN_CODE where t.SBU_ProductGroup<>'' ")
            If hdnProductGroup.Value <> "" Then
                If hdnProductGroup.Value <> "eStore" Then
                    .AppendFormat(" and t.SBU_ProductGroup='{0}' ", hdnProductGroup.Value.Replace("'", "''"))
                End If
            End If
            If hdnCampType.Value <> "" Then
                .AppendFormat(" and t.CampaignType='{0}' ", hdnCampType.Value)
            End If
            If hdnDateFrom.Value <> "" AndAlso hdnDateTo.Value = "" AndAlso Date.TryParse(hdnDateFrom.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate>='{0}' ", hdnDateFrom.Value)
            End If
            If hdnDateTo.Value <> "" AndAlso hdnDateFrom.Value = "" AndAlso Date.TryParse(hdnDateTo.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate<='{0}' ", hdnDateTo.Value)
            End If
            If hdnDateFrom.Value <> "" AndAlso hdnDateTo.Value <> "" AndAlso Date.TryParse(hdnDateFrom.Value, Now) = True AndAlso Date.TryParse(hdnDateTo.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate between '{0} 00:00:00' and '{1} 23:59:59' ", hdnDateFrom.Value, hdnDateTo.Value)
            End If
            If hdnOwner.Value = "1" Then
                .AppendFormat(" and t.SBU_Owner='{0}' ", HttpContext.Current.User.Identity.Name.Split("@")(0))
            End If
            .AppendLine(" union all ")
            .AppendFormat(" select distinct t.SBU_ProductGroup as ProductGroup, t.SBU_CampaignCode, t.SBU_CampaignName, t.SBU_Owner, a.CAMPAIGN_NAME as Local_CampaignName, a.CAMPAIGN_CODE as Local_CampaignCode, a.FIRST_START_DATE from ( ")
            .AppendFormat(" select * from ")
            .AppendFormat(" ( ")
            '.AppendFormat(" select distinct a.SBU_CAMPAIGN_CODE, a.CAMPAIGN_CODE, a.CAMPAIGN_NAME, c.FLASHLEADS_RBU, (select top 1 z.ACTUAL_SEND_DATE from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER z where z.ROW_ID in (select z1.CAMPAIGN_ROW_ID from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_UNICA z1 where z1.CAMPAIGN_CODE=a.CAMPAIGN_CODE) order by z.ACTUAL_SEND_DATE) as FIRST_START_DATE,  ")
            '.AppendFormat(" IsNull((select top 1 case z.StringValue when 'Emb’Core' then 'Emb''Core' when 'NCG' then 'NC & DMS' when 'Logistics' then 'ACG' when 'iService' then 'iServices' else z.StringValue end from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=(select top 1 z1.CampaignID from [ACLSTNR12].UNICADBP.dbo.UA_Campaign z1 where z1.CampaignCode=a.CAMPAIGN_CODE) and z.AttributeID=100),'') as ProductGroup  ")
            '.AppendFormat(" from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_UNICA a inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.CAMPAIGN_ROW_ID=b.ROW_ID left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU where a.TEST_FLAG='0' ")
            '.AppendFormat(" union all ")
            .AppendFormat(" Select distinct cast(a3.PARENT_CAMPAIGN_ID As varchar) As SBU_CAMPAIGN_CODE, cast(a3.CAMPAIGN_ID As varchar) As CAMPAIGN_CODE, a3.NAME As CAMPAIGN_NAME, c.FLASHLEADS_RBU,  ")
            .AppendFormat(" (select top 1 z.ACTUAL_SEND_DATE from [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER z where z.ROW_ID in (Select z1.ECAMPAIGN_ID from ECAMPAIGN z1 inner join CELL z2 on z1.CELL_ID=z2.CELL_ID inner join FLOWCHART z3 on z2.FLOWCHART_ID=z3.FLOWCHART_ID where z3.CAMPAIGN_ID=a2.CAMPAIGN_ID) order by z.ACTUAL_SEND_DATE) As FIRST_START_DATE,  ")
            .AppendFormat(" a4.NAME as ProductGroup  ")
            .AppendFormat(" from ECAMPAIGN a inner join [ACLSTNR12].MyAdvantechGlobal.dbo.CAMPAIGN_MASTER b on a.ECAMPAIGN_ID=b.ROW_ID  ")
            .AppendFormat(" left join (select case z.SIEBEL_RBU when 'ASG' then 'ASG' when 'AMY' then 'AMY' when 'ATH' then 'ATH' else z.FLASHLEADS_RBU end as FLASHLEADS_RBU, z.SIEBEL_RBU from [ACLSTNR12].CurationPool.dbo.LEADSFLASHRBU_SIEBELRBU z where z.SIEBEL_RBU<>'SAP') c on b.REGION=c.SIEBEL_RBU  ")
            .AppendFormat(" inner join CELL a1 on a.CELL_ID=a1.CELL_ID inner join FLOWCHART a2 on a1.FLOWCHART_ID=a2.FLOWCHART_ID inner join CAMPAIGN a3 on a2.CAMPAIGN_ID=a3.CAMPAIGN_ID ")
            .AppendFormat(" inner join CAMPAIGN_GROUP a4 on a3.GROUP_ID=a4.GROUP_ID ")
            '.AppendFormat(" where b.ACTUAL_SEND_DATE is not null ")
            .AppendFormat(" ) as a where 1=1 ")
            If arrAccessRBU.Count > 0 Then
                .AppendFormat(" and a.FLASHLEADS_RBU in ({0}) ", String.Join(",", arrAccessRBU.ToArray()))
            End If
            .AppendFormat(" ) as a left join ")
            .AppendFormat(" ( ")
            '.AppendFormat(" select distinct a.CampaignCode as SBU_CampaignCode, a.Name as SBU_CampaignName,  ")
            '.AppendFormat(" IsNull((select top 1 case z.StringValue when 'Emb’Core' then 'Emb''Core' when 'NCG' then 'NC & DMS' when 'Logistics' then 'ACG' when 'iService' then 'iServices' else z.StringValue end from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID and z.AttributeID=100),'') as SBU_ProductGroup,  ")
            '.AppendFormat(" IsNull((Select top 1 z.StringValue from [ACLSTNR12].UNICADBP.dbo.UA_CampAttribute z where z.CampaignID=a.CampaignID And z.AttributeID=111),'') as CampaignType,  ")
            '.AppendFormat(" c.NAME As SBU_Owner, Convert(VARCHAR, (select top 1 z1.CreateDate from [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer z inner join [ACLSTNR12].UNICADBP.dbo.UA_Offer z1 on z.OfferID=z1.OfferID where z.CampaignID=a.CampaignID order by z1.CreateDate), 111) As MaterialCreateDate,  ")
            '.AppendFormat(" REPLACE(REPLACE((select z.Name+' : '+'http://my.advantech.com/My/AOnline/UNICA_SBU_Campaigns_New.aspx?Type=P&CMSID='+ case when z.OfferCode1 is null then '' else z.OfferCode1+'-'+z.OfferCode2+'-'+z.OfferCode3+'-'+z.OfferCode4+'-'+z.OfferCode5 end as Offer from [ACLSTNR12].UNICADBP.dbo.UA_OFFER z inner join [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer z1 on z.OfferID=z1.OfferID where z1.CampaignID=a.CampaignID for xml path('')),'<Offer>',''),'</Offer>','; ') as Offer  ")
            '.AppendFormat(" from [ACLSTNR12].UNICADBP.dbo.UA_Campaign a inner join [ACLSTNR12].UNICADBP.dbo.UA_Folder b on a.FolderID=b.FolderID inner join [ACLSTNR12].UNICAMPP.dbo.USM_USER c on a.CreateBy=c.ID  ")
            '.AppendFormat(" inner join [ACLSTNR12].UNICAMPP.dbo.USM_USER d on a.UpdateBy=d.ID  ")
            '.AppendFormat(" left join [ACLSTNR12].UNICADBP.dbo.UA_CampToOffer e on e.CampaignID=a.CampaignID left join [ACLSTNR12].UNICADBP.dbo.UA_Offer f on e.OfferID=f.OfferID  ")
            '.AppendFormat(" where b.FolderID in ('891','892','893','894','895','896','897','902') and a.CampaignID not in ('8','743','226') ")
            'If hdnProductGroup.Value <> "" Then
                'If hdnProductGroup.Value = "eStore" Then
                    '.AppendFormat(" and b.Name='HQ_eStore' ")
                'End If
            'End If
            '.AppendFormat(" union all ")
            .AppendFormat(" select distinct cast(a.CAMPAIGN_ID as varchar) as SBU_CampaignCode, a.NAME as SBU_CampaignName,  ")
            .AppendFormat(" g.NAME As SBU_ProductGroup, h.NAME As CampaignType,  ")
            .AppendFormat(" c.EMAIL_ADDRESS as SBU_Owner, CONVERT(VARCHAR, (select top 1 z1.CREATED_DATE from CAMPAIGN_OFFER z inner join OFFER z1 on z.OFFER_ID=z1.OFFER_ID where z.CAMPAIGN_ID=a.CAMPAIGN_ID order by z1.CREATED_DATE), 111) as MaterialCreateDate,  ")
            .AppendFormat(" REPLACE(REPLACE((select z.NAME+' : '+'http://my.advantech.com/My/AOnline/UNICA_SBU_Campaigns_New.aspx?Type=P&CMSID='+ case when z.CMS_ID is null then '' else z.CMS_ID end as Offer from OFFER z inner join CAMPAIGN_OFFER z1 on z.OFFER_ID=z1.OFFER_ID where z1.CAMPAIGN_ID=a.CAMPAIGN_ID for xml path('')),'<Offer>',''),'</Offer>','; ') as Offer  ")
            .AppendFormat(" from CAMPAIGN a inner join CAMPAIGN_GROUP b on a.GROUP_ID=b.GROUP_ID inner join USER_PROFILE c on a.CREATED_BY=c.USER_ID  ")
            .AppendFormat(" inner join USER_PROFILE d on a.LAST_UPDATED_BY=d.USER_ID  ")
            .AppendFormat(" left join CAMPAIGN_OFFER e on e.CAMPAIGN_ID=a.CAMPAIGN_ID left join OFFER f on e.OFFER_ID=f.OFFER_ID  ")
            .AppendFormat(" inner join CAMPAIGN_ATTRIBUTE g on a.PRODUCT_GROUP=g.ATTRIBUTE_ID ")
            .AppendFormat(" inner join CAMPAIGN_ATTRIBUTE h on a.CAMPAIGN_TYPE=h.ATTRIBUTE_ID ")
            .AppendFormat(" where b.GROUP_ID In (22, 23, 24, 27, 28, 29, 30) ")
            .AppendFormat(" ) As t ")
            .AppendFormat(" On a.SBU_CAMPAIGN_CODE= t.SBU_CampaignCode where 1=1 ")
            If hdnProductGroup.Value <> "" Then
                If hdnProductGroup.Value <> "eStore" And hdnProductGroup.Value <> "ISG" Then
                    .AppendFormat(" And t.SBU_ProductGroup='{0}' ", hdnProductGroup.Value.Replace("'", "''"))
                End If
                If hdnProductGroup.Value = "ISG" Then
                    .AppendFormat(" and t.SBU_ProductGroup='ESG' ")
                End If
            End If
            If hdnCampType.Value <> "" Then
                .AppendFormat(" and t.CampaignType='{0}' ", hdnCampType.Value)
            End If
            If hdnDateFrom.Value <> "" AndAlso hdnDateTo.Value = "" AndAlso Date.TryParse(hdnDateFrom.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate>='{0}' ", hdnDateFrom.Value)
            End If
            If hdnDateTo.Value <> "" AndAlso hdnDateFrom.Value = "" AndAlso Date.TryParse(hdnDateTo.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate<='{0}' ", hdnDateTo.Value)
            End If
            If hdnDateFrom.Value <> "" AndAlso hdnDateTo.Value <> "" AndAlso Date.TryParse(hdnDateFrom.Value, Now) = True AndAlso Date.TryParse(hdnDateTo.Value, Now) = True Then
                .AppendFormat(" and t.MaterialCreateDate between '{0} 00:00:00' and '{1} 23:59:59' ", hdnDateFrom.Value, hdnDateTo.Value)
            End If
            If hdnOwner.Value = "1" Then
                .AppendFormat(" and t.SBU_Owner='{0}' ", HttpContext.Current.User.Identity.Name.Split("@")(0))
            End If
            .AppendLine(" ) as t ")
            .AppendFormat(" order by t.ProductGroup ")
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("UCAMP", sb.ToString)
        'For Each row As DataRow In dt.Rows
        '    row.Item("Offer") = row.Item("Offer").ToString.Replace("&lt;", "<").Replace("&gt;", ">").Replace("&amp;", "&")
        'Next
        dt.AcceptChanges()
        Util.DataTable2ExcelDownload(dt, "SBU Campaign Overview.xls")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <br />
    <h2>SBU Campaign Overview</h2><br />
    <img src="../../Images/excel.gif" />&nbsp;<asp:LinkButton runat="server" ID="btnToXls" Text="Export to Excel" Visible="false" OnClick="btnToXls_Click" /><br />
    <asp:HyperLink runat="server" ID="hyMyCampaigns" NavigateUrl="~/My/Campaign/CampaignList.aspx" Text="My Campaigns" />
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:LinkButton runat="server" ID="link1" />
            <asp:HiddenField runat="server" ID="hdnProductGroup" /><asp:HiddenField runat="server" ID="hdnCampType" /><asp:HiddenField runat="server" ID="hdnShowQDate" /><asp:HiddenField runat="server" ID="hdnDateFrom" /><asp:HiddenField runat="server" ID="hdnDateTo" /><asp:HiddenField runat="server" ID="hdnOwner" />
            <asp:GridView runat="server" ID="gvCampaigns" AutoGenerateColumns="false" EnableTheming="false" DataSourceID="srcCamp"
                OnRowDataBound="gvCampaigns_RowDataBound" OnPreRender="gvCampaigns_PreRender" ShowHeaderWhenEmpty="true" RowStyle-BackColor="#FFFFFF" 
                HeaderStyle-BackColor="#dcdcdc" RowStyle-Height="50" Font-Names="Tahoma" Font-Size="X-Small" Width="1000"
                BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" ForeColor="Black" CellPadding="3"
                PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White" >
                <Columns>
                    <asp:BoundField HeaderText="Campaign ID" DataField="CampaignCode" SortExpression="CampaignCode" />
                    <asp:TemplateField HeaderText="Product Group" SortExpression="ProductGroup" ItemStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            <table width="100%">
                                <tr><td align="center">Product Group</td></tr>
                                <tr>
                                    <td align="center">
                                        <asp:DropDownList runat="server" ID="ddlProductGroup" AutoPostBack="true" Width="120" DataSourceID="sqlProductGroup" DataTextField="text" DataValueField="value" OnSelectedIndexChanged="ddlProductGroup_SelectedIndexChanged">
                                        </asp:DropDownList>
                                        <asp:SqlDataSource runat="server" ID="sqlProductGroup" ConnectionString="<%$ connectionStrings: CP %>"
                                            SelectCommand="select * from (select 'All' as text , '' as value union select product_group as text, product_group as value from LEADSFLASH_PRODUCTCATEGORY union select 'eStore' as text, 'eStore' as value) as t order by t.value"></asp:SqlDataSource>
                                    </td>
                                </tr>
                            </table>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Label runat="server" ID="lblProductGroup" Text='<%#Eval("ProductGroup") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Campaign Type" SortExpression="CampaignType" ItemStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            <table width="100%">
                                <tr><td align="center">Campaign Type</td></tr>
                                <tr>
                                    <%--<td align="center">
                                        <asp:DropDownList runat="server" ID="ddlCampType" AutoPostBack="true" Width="120" DataSourceID="sqlCampType" DataTextField="text" DataValueField="value" OnSelectedIndexChanged="ddlCampType_SelectedIndexChanged">
                                        </asp:DropDownList>
                                        <asp:SqlDataSource runat="server" ID="sqlCampType" ConnectionString="<%$ connectionStrings: MY %>"
                                            SelectCommand="select * from (select 'All' as text , '' as value union select distinct StringValue as text, StringValue as value from UNICADBP.dbo.UA_EnumAttrValues where AttributeID='111') as t order by t.value"></asp:SqlDataSource>
                                    </td>--%>
                                </tr>
                            </table>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <%--<asp:Label runat="server" ID="lblCampType" Text='<%#Eval("CampaignType") %>' />--%>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Campaign Name" SortExpression="CampaignName">
                        <ItemTemplate>
                            <table><tr><td style="width: 150; word-wrap: break-word"><asp:Label runat="server" ID="lblCampName" Text='<%#Eval("CampaignName") %>' /></td></tr></table>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Materials Ready Time" ItemStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            <table width="100%">
                                <tr><td align="center">Materials Ready Time</td></tr>
                                <tr>
                                    <td align="center">
                                        <asp:LinkButton runat="server" ID="btnExpandDate" Text="Filter by Date" OnClick="btnExpandDate_Click" />
                                        <asp:Panel runat="server" ID="PanelDate" Visible="false">
                                            <table cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td>From </td>
                                                    <td><asp:TextBox runat="server" ID="txtDateFrom" /><ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtDateFrom" Format="yyyy/MM/dd" /></td>
                                                    <td> ~ </td>
                                                </tr>
                                                <tr>
                                                    <td>To </td>
                                                    <td><asp:TextBox runat="server" ID="txtDateTo" /><ajaxToolkit:CalendarExtender runat="server" ID="ce2" TargetControlID="txtDateTo" Format="yyyy/MM/dd" /></td>
                                                    <td><asp:Button runat="server" ID="btnSubmitDate" Text="Submit" OnClick="btnSubmitDate_Click" /></td>
                                                </tr>
                                            </table>
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Label runat="server" ID="lblMReadyTime" Text='<%#Eval("MaterialCreateDate") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="eDM Preview">
                        <ItemTemplate>
                            <asp:HyperLink runat="server" ID="hlOffer" Text='<%#Eval("OfferName")%>' Target="_blank" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Material Download" ItemStyle-HorizontalAlign="Center" ItemStyle-VerticalAlign="Middle">
                        <ItemTemplate>
                            <asp:HiddenField runat="server" ID="hdUCID" Value='<%#Eval("CampaignID") %>' />
                            <asp:HiddenField runat="server" ID="hdnCampaignCode" Value='<%#Eval("CampaignCode") %>' />
                            <asp:HiddenField runat="server" ID="hdnCMSID" Value='<%#Eval("CMS_Content_Id") %>' />
                            <asp:ImageButton runat="server" ID="btnDownload" ImageUrl="~/My/AOnline/Images/download.png" Width="80" AlternateText="Download" OnClick="btnDownload_Click" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="HQ SBU Owner" ItemStyle-HorizontalAlign="Center">
                        <HeaderTemplate>
                            <table width="100%">
                                <tr><td align="center">HQ SBU Owner</td></tr>
                                <tr>
                                    <td align="center">
                                        <asp:DropDownList runat="server" ID="ddlOwner" AutoPostBack="true" OnSelectedIndexChanged="ddlOwner_SelectedIndexChanged">
                                            <asp:ListItem Text="All" Value="0" />
                                            <asp:ListItem Text="My" Value="1" />
                                        </asp:DropDownList>
                                    </td>
                                </tr>
                            </table>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:Label runat="server" ID="lblOwner" Text='<%#Eval("Creator") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Run Nurturing Campaign " ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                        <ItemTemplate>
                            <asp:HyperLink ID="HLRequest" Target="_blank" runat="server" NavigateUrl='<%# Eval("CampaignID", "../Campaign/CampaignRequest.aspx?CampaignID={0}") %>'>
                                            Request
                            </asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="RBU Roll-out Status" HeaderStyle-BackColor="#DBE5F1" ItemStyle-Width="300">
                        <ItemTemplate>
                            <asp:Panel runat="server" ID="PanelRBUCamp" Width="300" Height="100%" ScrollBars="Auto">
                                <asp:GridView runat="server" ID="gvRBUCamp" AutoGenerateColumns="false" EnableTheming="false" ShowHeaderWhenEmpty="true" RowStyle-BackColor="#FFFFFF" 
                                    HeaderStyle-BackColor="#DBE5F1" RowStyle-Height="50" Font-Names="Tahoma" Font-Size="X-Small" Width="1200" Height="100%"
                                    BorderWidth="1" BorderColor="#d7d0d0" HeaderStyle-ForeColor="Black" BorderStyle="Solid" ForeColor="Black" CellPadding="3"
                                    PagerStyle-BackColor="#ffffff" PagerStyle-BorderWidth="0" PagerStyle-BorderColor="White">
                                    <Columns>
                                        <asp:BoundField DataField="TYPE" ItemStyle-Font-Bold="true" ItemStyle-Width="120" />
                                        <asp:BoundField HeaderText="ANA" DataField="ANA" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="AEU" DataField="AEU" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="ACN" DataField="ACN" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="ATW" DataField="ATW" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="AJP" DataField="AJP" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="AKR" DataField="AKR" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="AAU" DataField="AAU" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="ASG" DataField="ASG" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="AMY" DataField="AMY" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="ATH" DataField="ATH" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="SAP" DataField="SAP" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="ABR" DataField="ABR" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="AIN" DataField="AIN" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="ARU" DataField="ARU" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                        <asp:BoundField HeaderText="InterCon" DataField="InterCon" ItemStyle-Width="90" ItemStyle-HorizontalAlign="Center" HtmlEncode="false" />
                                    </Columns>
                                </asp:GridView>
                            </asp:Panel>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
                <asp:SqlDataSource runat="server" ID="srcCamp" ConnectionString="<%$ connectionStrings: UCAMP %>"
                SelectCommand="" OnLoad="srcCamp_Load"></asp:SqlDataSource>
                <ajaxToolkit:AlwaysVisibleControlExtender runat="server" ID="avce1" TargetControlID="PanelRollOut" HorizontalSide="Center" VerticalSide="Middle" />
                <asp:Panel runat="server" ID="PanelRollOut" Visible="false">
                    <table cellpadding="2" cellspacing="0" style="background-color:#BFBFBF;border-color:#385D8A; border-width:1px; border-style:solid">
                        <tr><td height="2" colspan="4"></td></tr>
                        <tr><td colspan="4">&nbsp;&nbsp;<asp:LinkButton runat="server" ID="btnCancel" Text="Close" OnClick="btnCancel_Click" /></td></tr>
                        <tr><td height="10" colspan="4"></td></tr>
                        <tr>
                            <td valign="middle">&nbsp;&nbsp;Please submit your roll-out date</td>
                            <td valign="middle"><asp:TextBox runat="server" ID="txtRollOutDate" Height="20" /></td>
                            <td><asp:ImageButton runat="server" ID="imgCal" ImageUrl="~/My/AOnline/Images/Calendar.jpg" Height="20" Width="20" /><ajaxToolkit:CalendarExtender runat="server" ID="ce1" TargetControlID="txtRollOutDate" PopupButtonID="imgCal" Format="yyyy/MM/dd" /></td>
                            <td valign="middle" width="100"><asp:Button runat="server" ID="btnSubmitRollOut" Text="Submit" Height="25" Width="60" OnClick="btnSubmitRollOut_Click" /></td>
                        </tr>
                        <tr>
                            <td align="right">Roll-out RBU</td>
                            <td colspan="3">
                                <asp:DropDownList runat="server" ID="ddlRollOutRBU" />
                                <br /><asp:Label runat="server" ID="lblErrMsg" ForeColor="Tomato" />
                                <asp:HiddenField runat="server" ID="hdnRollOutCampaignCode" />
                                <asp:HiddenField runat="server" ID="hdnRollOutCMSID" />
                            </td>
                        </tr>
                        <tr><td height="40" colspan="4"></td></tr>
                    </table>
                </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
    <ajaxToolkit:AlwaysVisibleControlExtender ID="AlwaysVisibleControlExtender1" runat="server"
        TargetControlID="PanelDetail" HorizontalSide="Center" VerticalSide="Top"
        HorizontalOffset="50" VerticalOffset="20" />
    <asp:Panel runat="server" ID="PanelDetail">
        <div id="divDetail" style="display: none; background-color: white;
            border: solid 1px silver; padding: 10px; width: 700px; height: 400px; overflow: auto;">
            <table width="100%">
                <tr>
                    <td><a href="javascript:void(0);" onclick="CloseDetail();">Close</a></td>
                </tr>
                <tr>
                    <td>
                        <div id="divDetailContent"></div>
                    </td>
                </tr>
            </table>
        </div>
    </asp:Panel> 
    <script type="text/javascript">
        function ShowDetail(campaign_code, rbu, type) {
            var divDetail = document.getElementById('divDetail');
            divDetail.style.display = 'block';
            var divDetailContent = document.getElementById('divDetailContent');
            divDetailContent.innerHTML = "<center><img src='../../Images/loading2.gif' alt='Loading...' width='35' height='35' />Loading...</center> ";

            PageMethods.ShowDetail(campaign_code, rbu, type,
                function (pagedResult, eleid, methodName) {
                    //alert(pagedResult);    
                    divDetailContent.innerHTML = pagedResult;
                },
                function (error, userContext, methodName) {
                    alert(error.get_message());
                    //divMozDetail.innerHTML = error.get_message();
                });
        }
        function CloseDetail() {
            var divDetail = document.getElementById('divDetail');
            divDetail.style.display = 'none';
        }
    </script>
</asp:Content>

