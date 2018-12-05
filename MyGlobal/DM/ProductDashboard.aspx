<%@ Page Title="MyAdvantech - Product Dashboard" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %> 

<script runat="server">

    Protected Sub gvRowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
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

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If MailUtil.IsInRole("IT.ebusiness") Then Response.End()
            txtTopSalesShipFrom.Text = DateAdd(DateInterval.Year, -1, Now).ToString("yyyy/MM/dd")
            txtTopSalesShipTo.Text = Now.ToString("yyyy/MM/dd")
            If Util.IsInternalUser(Session("user_id")) = False Then Response.Redirect("../home.aspx")
            Me.txtPickPN.Attributes("autocomplete") = "off" : Me.txtChgPN.Attributes("autocomplete") = "off"
            If Request("PN") IsNot Nothing AndAlso Request("PN").ToString().Trim() <> "" Then
                Dim pnDt As DataTable = dbUtil.dbGetDataTable("MY", _
                String.Format("select top 1 part_no from sap_product where part_no='{0}' and part_no is not null", _
                              HttpUtility.UrlDecode(Replace(Request("PN"), "'", "''").Trim())))
                If pnDt.Rows.Count = 1 Then
                    hd_PN.Value = pnDt.Rows(0).Item("part_no").ToString().ToUpper()
                Else
                    pnDt = dbUtil.dbGetDataTable("MY", _
                              String.Format("select top 1 part_no, model_no from sap_product where model_no='{0}' and model_no is not null and model_no<>'' and material_group='PRODUCT' and status='A' ", _
                              HttpUtility.UrlEncode(Replace(Request("PN"), "'", "''").Trim())))
                    If pnDt.Rows.Count = 1 Then
                        hd_PN.Value = pnDt.Rows(0).Item("part_no").ToString().ToUpper()
                    Else
                        pnDt = dbUtil.dbGetDataTable("MY", _
                            String.Format("select top 1 part_no from PRODUCT_FULLTEXT_NEW where (model_no='{0}' or part_no='{0}') and part_no is not null and part_no<>'' ", _
                            HttpUtility.UrlEncode(Replace(Request("PN"), "'", "''").Trim())))
                        If pnDt.Rows.Count = 1 Then
                            hd_PN.Value = pnDt.Rows(0).Item("part_no").ToString().ToUpper()
                        Else

                        End If
                    End If
                End If
                If hd_PN.Value <> "" Then
                    'hyPIS.NavigateUrl = "http://pis.advantech.com/WS/ProductComparison.aspx?Part_Number=" + hd_PN.Value + "&Sales_Org=TW01"
                    ProfileSrc.SelectCommand = GetProdProfileSql()
                    dlPerfYear_SelectedIndexChanged(Nothing, Nothing)
                    If hd_PN.Value.EndsWith("-BTO") Or hd_PN.Value.StartsWith("SYS-") Or _
                        hd_PN.Value.StartsWith("C-CTOS") Or hd_PN.Value.StartsWith("W-CTOS") Then
                        If CInt(dbUtil.dbExecuteScalar("MY", "select COUNT(category_id) as c from CBOM_CATALOG_CATEGORY where parent_category_id='Root' and CATEGORY_ID='" + hd_PN.Value + "' ")) > 0 Then
                            Tab01.Visible = True
                            hyCTOSOrder.Visible = True : hyCTOSOrder.NavigateUrl = "~/DM/CTOSAnalysis.aspx?BTOITEM=" + hd_PN.Value : hyCTOSOrder.Text = "Check Order History of " + hd_PN.Value
                            If MailUtil.IsInRole("EMPLOYEES.Irvine") OrElse Util.IsAEUIT() Then
                                dlCBOMReg.SelectedIndex = 3
                            End If
                            dlCBOMReg_SelectedIndexChanged(Nothing, Nothing)
                        Else
                            Tab01.Visible = False
                        End If
                    Else
                        Tab01.Visible = False
                    End If
                Else
                    imgProdPerf.Visible = False
                    PerfTimer.Enabled = False : TimerForecast.Enabled = False : TimerInv.Enabled = False
                    imgForecastLoad.Visible = False : imgInvLoad.Visible = False : imgPerfLoad.Visible = False
                End If
            End If
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            SrcPickPN.SelectCommand = GetPickPNSql() : Me.Master.LogoImgPath = "~/Images/dm_logo.JPG"

            Me.dlPerfYear.Items.Clear()
            Dim _YearRangeStart As Integer = Now.Year - 3
            Dim _YearRangeEnd As Integer = Now.Year + 1
            Dim _ThisYear As Integer = Now.Year
            For i As Integer = _YearRangeStart To _YearRangeEnd
                Me.dlPerfYear.Items.Add(i)
            Next
            Me.dlPerfYear.SelectedValue = _ThisYear
        End If
    End Sub

    Function GetPLMPhaseInOutTable(ByVal partno As String) As String
        Dim pinDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select CHANGE_NUMBER, RELEASE_DATE, REV_NUMBER, DESCRIPTION, CHANGE_DESC from PLM_PHASEIN where ITEM_NUMBER='{0}'", partno.Trim().Replace("'", "''")))
        Dim poutDt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select CHANGE_NUMBER, RELEASE_DATE, REV_NUMBER, ITEM_NUMBER, DESCRIPTION, REPLACE_BY, LAST_BUY_DATE, CHANGE_DESC from PLM_PHASEOUT where ITEM_NUMBER='{0}'", partno.Trim().Replace("'", "''")))
        Dim sb As New System.Text.StringBuilder
        If pinDt.Rows.Count > 0 Then

        End If
        Return sb.ToString()
    End Function

    Function IsROHSImage(ByVal rohsflag As String) As String
        If rohsflag = "Y" Then
            Return "<img src='/Images/Rohs.jpg' alt='RoHS'/>"
        Else
            Return ""
        End If
    End Function

    Public Function GetThumbnailImg(ByVal TID As String, ByVal modelno As String) As String
        If TID.Trim() = "" Then Return ""
        Return String.Format("<img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id={0}' alt='{1}' style='height:220px;width:220px;border-width:0px;' />", TID, modelno)
    End Function

    Function GetProdProfileSql() As String
        If hd_PN.Value = "" Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT distinct top 1 a.U_ID, a.Part_NO, IsNull(a.TUMBNAIL_IMAGE_ID,'') as TUMBNAIL_IMAGE_ID,    "))
            .AppendLine(String.Format(" a.ROHS_STATUS, a.PRODUCT_DESC, a.FEATURES, a.EXTENTED_DESC, a.STATUS, a.Model_id,   "))
            .AppendLine(String.Format(" a.Model_No, a.CATALOG_ID, a.active_flg, a.CATEGORY_TYPE,   "))
            .AppendLine(String.Format(" a.material_group, b.PRODUCT_HIERARCHY, b.NET_WEIGHT, b.GROSS_WEIGHT, b.PRODUCT_TYPE  "))
            .AppendLine(String.Format(" FROM PRODUCT_FULLTEXT_NEW AS a inner join sap_product b on a.part_no=b.PART_NO  "))
            .AppendLine(String.Format(" where a.part_no='{0}'   ", hd_PN.Value))
            .AppendLine(String.Format(" order by a.Part_NO  "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub dlPerfYear_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim strTType As String = "1"
        If (cblPerfTranType.Items(0).Selected And cblPerfTranType.Items(1).Selected) Or _
            (Not cblPerfTranType.Items(0).Selected And Not cblPerfTranType.Items(1).Selected) Then
            strTType = "3"
        Else
            If cblPerfTranType.Items(0).Selected Then
                strTType = "1"
            Else
                If cblPerfTranType.Items(1).Selected Then
                    strTType = "2"
                End If
            End If
        End If
        imgProdPerf.ImageUrl = _
            "~/Includes/ProductChart.ashx?PN=" + hd_PN.Value + _
            "&Year=" + dlPerfYear.SelectedValue + _
            "&Org=" + dlPerfRegion.SelectedValue + _
            "&Unit=" + dlPerfUnit.SelectedValue + _
            "&Sector=" + dlPerfSector.SelectedValue + _
            "&TranType=" + strTType
    End Sub

    Protected Sub imgPerfChartXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If hd_PN.Value = "" Then Exit Sub
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 100000 a.Product_Line, left(a.org,2) as org, a.efftive_date as due_date, a.Tran_Type, cast(a.Qty as int) as Qty, a.Us_amt, a.sector, a.order_date, a.egroup as product_group, a.edivision as product_division"))
            '.AppendLine(String.Format(" select top 100000 a.item_no as part_no, a.Product_Line, a.Customer_ID, a.tr_curr as currency, b.COMPANY_NAME, IsNull(c.full_name,'') as sales_name, "))
            '.AppendLine(String.Format(" a.efftive_date as due_date, a.Tran_Type, cast(a.Qty as int) as Qty, a.sector, a.order_no, a.order_date,  "))
            '.AppendLine(String.Format(" a.Us_amt, a.EUR, a.egroup as product_group, a.edivision as product_division, a.PO  "))
            .AppendLine(String.Format(" from EAI_SALE_FACT a "))
            .AppendLine(String.Format(" where a.qty>0 and a.item_no='{0}' and fact_1234=1  ", hd_PN.Value))
            .AppendLine(String.Format(" and FACTYEAR={0} ", dlPerfYear.SelectedValue))
            If dlPerfRegion.SelectedValue <> "" Then
                .AppendLine(String.Format(" and left(a.org,2)='{0}' ", dlPerfRegion.SelectedValue))
            End If
            If dlPerfSector.SelectedValue <> "" Then
                .AppendLine(String.Format(" and a.sector='{0}' ", dlPerfSector.SelectedValue))
            End If
            .AppendLine(String.Format(" order by a.efftive_date desc "))
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        Util.DataTable2ExcelDownload(dt, "AEUIT_Perf_" + hd_PN.Value + ".xls")
    End Sub

    Protected Sub gvPIn_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If gvPIn.Rows.Count = 0 Then
            tr_PIn.Visible = False
        End If
    End Sub

    Protected Sub gvPOut_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        If gvPOut.Rows.Count = 0 Then
            tr_POut.Visible = False
        End If
    End Sub

    Function GetForecastSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 1000 a.CREATED, a.PART_NO, a.SALES_EMAIL, a.SALES_NAME, a.RBU, a.OPTY_NAME, a.DESC_TEXT,  "))
            .AppendLine(String.Format(" a.SUM_WIN_PROB, a.LAST_UPD, a.ACCOUNT_NAME, a.ACCOUNT_ROW_ID, a.CLOSE_DATE, a.TOTAL_QTY  "))
            .AppendLine(String.Format(" from SIEBEL_PRODUCT_FORECAST a  "))
            .AppendLine(String.Format(" where (a.PART_NO='{0}' or a.PART_NO in  ", hd_PN.Value))
            .AppendLine(String.Format(" ( "))
            .AppendLine(String.Format(" 	select z.model_no from SAP_PRODUCT z where z.PART_NO='{0}' and z.MODEL_NO<>'' ", hd_PN.Value))
            .AppendLine(String.Format(" )) "))
            If txtForOptyName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.OPTY_NAME like N'%{0}%' ", txtForOptyName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            .AppendLine(String.Format(" order by a.CREATED desc "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub TimerForecast_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If hd_PN.Value = "" Then
                TimerForecast.Enabled = False : Exit Sub
            End If
            TimerForecast.Interval = 99999 : SrcForecast.SelectCommand = GetForecastSql() : TimerForecast.Enabled = False : imgForecastLoad.Visible = False
            gvForecast.EmptyDataText = "No Data"
            Me.Master.EnableAsyncPostBackHolder = True
        Catch ex As Exception
            TimerForecast.Enabled = False
        End Try
    End Sub

    Protected Sub gvForecast_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SrcForecast.SelectCommand = GetForecastSql()
    End Sub

    Protected Sub gvForecast_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SrcForecast.SelectCommand = GetForecastSql()
    End Sub

    Protected Sub btnSearchForecast_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        SrcForecast.SelectCommand = GetForecastSql()
        gvForecast.PageIndex = 0
    End Sub

    Protected Sub imgForecastXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If hd_PN.Value = "" Then Exit Sub
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetForecastSql())
        Util.DataTable2ExcelDownload(dt, "AEUIT_Forecast_" + hd_PN.Value + ".xls")
    End Sub

    Protected Sub TimerInv_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If hd_PN.Value = "" Then
                TimerInv.Enabled = False : Exit Sub
            End If
            TimerInv.Interval = 9999
            Me.gvInv.EmptyDataText = "No Inventory"
            Dim adt As DataTable = GetATP()
            Me.gvInv.DataSource = adt : gvInv.DataBind()
            Dim intQty As Integer = 0
            For Each r As DataRow In adt.Rows
                intQty += r.Item("atp_qty")
            Next
            If intQty > 0 Then
                If intQty > 1 Then
                    Me.lbInvTotal.Text = "Total: " + intQty.ToString() + " pcs"
                Else
                    Me.lbInvTotal.Text = "Total: " + intQty.ToString() + " pc"
                End If
            End If
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select a.werks as plant, a.EISBE as safety_stock, a.EISLO as min_safety_stock, a.LGRAD as service_level "))
                .AppendLine(String.Format(" from saprdp.marc a  "))
                .AppendLine(String.Format(" where a.mandt='168' and a.matnr='{0}'  ", Global_Inc.Format2SAPItem(hd_PN.Value.ToUpper())))
                .AppendLine(String.Format(" order by a.werks "))
            End With
            Dim sdt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
            'gvSafetyStock.DataSource = sdt : gvSafetyStock.DataBind()
            dlstSafetyStock.DataSource = sdt : dlstSafetyStock.DataBind()
            TimerInv.Enabled = False
        Catch ex As Exception
            TimerInv.Enabled = False
        End Try
    End Sub

    Function GetATP() As DataTable
        imgInvLoad.Visible = True
        Dim gdt As New DataTable
        gdt.Columns.Add("plant") : gdt.Columns.Add("atp_date") : gdt.Columns.Add("atp_qty", Type.GetType("System.Double"))
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        Dim pn As String = Global_Inc.Format2SAPItem(Trim(UCase(hd_PN.Value)))
        'Dim retDt As New DataTable("DueDate")
        Try
            Dim plants() As String = { _
                "EUH1", "TWH1", "TWM1", "TWM2", "TWM3", "TWM4", "TWM5", "CNH1", "CNH2", "CKH1", "CKH2", _
                "CKM1", "CKM2", "CKM3", "CKM4", "CKM5", "CKM6", "CKM7", "CKM8", "JPH1", "KRH1", "SGH1", "MYH1", "USH1"}
            'Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0
            For Each plant In plants
                'Dim culQty As Integer = 0
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", pn, plant, "", "", "", "", "PC", "", 9999, "", "", _
                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                Dim adt As DataTable = atpTb.ToADODataTable()
                For Each r As DataRow In adt.Rows
                    If r.Item(4) > 0 And r.Item(4) < 99999999 Then
                        Dim r2 As DataRow = gdt.NewRow
                        r2.Item("plant") = plant
                        r2.Item("atp_date") = Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
                        r2.Item("atp_qty") = CDbl(r.Item(4))
                        gdt.Rows.Add(r2)
                    End If
                Next
                'retDt.Merge(atpTb.ToADODataTable())
            Next
        Catch ex As Exception
        End Try
        p1.Connection.Close()
        imgInvLoad.Visible = False
        Return gdt
    End Function

    Protected Sub gvInv_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        Me.gvInv.DataSource = GetATP()
        gvInv.PageIndex = e.NewPageIndex
        gvInv.DataBind()
    End Sub

    Protected Sub gvInv_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        Dim dt As DataTable = GetATP()
        Dim dv As DataView = dt.AsDataView()
        dv.Sort = e.SortExpression + " " + IIf(e.SortDirection = SortDirection.Ascending, "asc", "desc")
        Me.gvInv.DataSource = dv
        gvInv.DataBind()
    End Sub

    Function GetPerfSql() As String
        If hd_PN.Value = "" Then Return ""
        Dim cfrom As Date = DateAdd(DateInterval.Month, -6, Now)
        Dim cto As Date = DateAdd(DateInterval.Month, 6, Now)
        If txtPerfDueFrom.Text.Trim() <> "" AndAlso Date.TryParse(txtPerfDueFrom.Text, Now) Then cfrom = CDate(txtPerfDueFrom.Text)
        If txtPerfDueTo.Text.Trim() <> "" AndAlso Date.TryParse(txtPerfDueTo.Text, Now) Then cto = CDate(txtPerfDueTo.Text)
        Dim eaiTable As String = "EAI_SALE_FACT"
        If DateDiff(DateInterval.Day, New Date(2007, 12, 31), cfrom) > 0 Then
            eaiTable = "EAI_SALE_FACT"
        Else
            eaiTable = "EAI_SALE_FACT_VOR_2008"
        End If
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 1000 a.Product_Line, a.Customer_ID, a.org, a.tr_curr as currency, b.COMPANY_NAME, IsNull(c.full_name,'') as sales_name, "))
            .AppendLine(String.Format(" a.efftive_date as due_date, a.Tran_Type, cast(a.Qty as int) as Qty, a.sector, a.order_no, a.order_date,  "))
            .AppendLine(String.Format(" a.Us_amt, a.{0} as Local_Amt, a.egroup as product_group, a.edivision as product_division, a.PO  ", dlPerfCurr.SelectedValue))
            .AppendLine(String.Format(" from " + eaiTable + " a inner join SAP_DIMCOMPANY b on a.Customer_ID=b.COMPANY_ID and a.org=b.ORG_ID left join sap_employee c on a.Sales_ID=c.sales_code   "))
            .AppendLine(String.Format(" where a.item_no='{0}' and fact_1234=1  ", hd_PN.Value))
            .AppendLine(String.Format(" and FACTYEAR>=Year('{0}') and a.efftive_date between '{0}' and '{1}'  ", cfrom.ToString("yyyy-MM-dd"), cto.ToString("yyyy-MM-dd")))
            If txtPerfCustName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and b.COMPANY_NAME like N'%{0}%' ", txtPerfCustName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtPerfSalesName.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and c.full_name like N'%{0}%' ", txtPerfSalesName.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If rblPerfType.SelectedIndex > 0 Then
                .AppendLine(String.Format(" and a.tran_type='{0}' ", rblPerfType.SelectedValue))
            End If
            If dlOrderHistoryOrg.SelectedIndex > 0 Then
                .AppendLine(String.Format(" and left(a.org,2)='{0}' ", dlOrderHistoryOrg.SelectedValue))
            End If
            .AppendLine(String.Format(" order by a.efftive_date desc "))
        End With
        'MailUtil.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "PN perf", sb.ToString(), False, "", "")
        Return sb.ToString()
    End Function

    Protected Sub btnQueryPerf_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me.Master.EnableAsyncPostBackHolder = True
        gvPerf.PageIndex = 0
        PerfSrc.SelectCommand = GetPerfSql()
    End Sub

    Protected Sub PerfTimer_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If hd_PN.Value = "" Then
                PerfTimer.Enabled = False : Exit Sub
            End If
            PerfTimer.Interval = 99999 : PerfSrc.SelectCommand = GetPerfSql() : PerfTimer.Enabled = False : imgPerfLoad.Visible = False
            gvPerf.EmptyDataText = "No Data"
            Me.Master.EnableAsyncPostBackHolder = True
        Catch ex As Exception
            PerfTimer.Enabled = False
        End Try
    End Sub

    Protected Sub gvPerf_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        PerfSrc.SelectCommand = GetPerfSql()
    End Sub

    Protected Sub gvPerf_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        PerfSrc.SelectCommand = GetPerfSql()
    End Sub

    Protected Sub imgPerfXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", GetPerfSql())
        If dt.Rows.Count > 0 Then
            Util.DataTable2ExcelDownload(dt, "AEUIT_ProductPerformance.xls")
        End If
    End Sub

    Protected Sub PerfSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)
        'TimerForecast.Enabled = False : PerfTimer.Enabled = False : TimerInv.Enabled = False
    End Sub

    Protected Sub RMASrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SRSRc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Function GetPickPNSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top 1000 a.PART_NO, a.MODEL_NO, a.PRODUCT_DESC, a.PRODUCT_HIERARCHY, a.STATUS, a.CREATE_DATE, a.MATERIAL_GROUP    "))
            .AppendLine(String.Format(" from SAP_PRODUCT a "))
            .AppendLine(String.Format(" where a.PART_NO not like '#%' and a.part_no not like '$%' "))
            If txtPickPN.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and (a.PART_NO like '%{0}%') ", txtPickPN.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtPickPNDesc.Text.Trim() <> "" Then
                .AppendLine(String.Format(" and a.PRODUCT_DESC like N'%{0}%' ", txtPickPNDesc.Text.Trim().Replace("'", "''").Replace("*", "%")))
            End If
            If txtPickPN.Text.Trim() = "" And txtPickPNDesc.Text.Trim() = "" Then
                .AppendLine(String.Format(" and a.MATERIAL_GROUP='PRODUCT' and a.PRODUCT_HIERARCHY not like 'AGSG-%' and a.PRODUCT_HIERARCHY not like 'OTHR-%' and a.STATUS='A' "))
            Else
            End If
            .AppendLine(String.Format(" order by a.PART_NO, a.MODEL_NO  "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub btnSearchPN_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvPickPN.PageIndex = 0
        SrcPickPN.SelectCommand = GetPickPNSql()
    End Sub

    Protected Sub gvPickPN_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SrcPickPN.SelectCommand = GetPickPNSql()
    End Sub

    Protected Sub gvPickPN_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SrcPickPN.SelectCommand = GetPickPNSql()
    End Sub

    Protected Sub btnChgPN_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("ProductDashboard.aspx?PN=" + txtChgPN.Text, False)
    End Sub

    Protected Sub ProfileSrc_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SrcABCInd_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SrcForecast_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SrcPickPN_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub SrcPOut_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Function GetPriceSql() As String
        If hd_PN.Value = "" Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT ORG, GRADE, CURCY_CD, LIST_PRICE, cast(DISCOUNT1 as int) as DISCOUNT, AMT1 "))
            .AppendLine(String.Format(" FROM EPRICER_PRICE_BY_LEVEL "))
            .AppendLine(String.Format(" WHERE PART_NO = '{0}' AND YEAR = {1} AND QUARTER = {2} ", hd_PN.Value, dlPriceYear.SelectedValue, dlPriceQuarter.SelectedValue))
            .AppendLine(String.Format(" and CURCY_CD='{0}' ", dlPriceCurr.SelectedValue))
            .AppendLine(String.Format(" ORDER BY ORG, CURCY_CD, GRADE "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub btnChangePriceYQ_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        gvPricing.PageIndex = 0
        SrcPrice.SelectCommand = GetPriceSql()
    End Sub

    Protected Sub SrcPrice_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 600
    End Sub

    Protected Sub gvPricing_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        SrcPrice.SelectCommand = GetPriceSql()
    End Sub

    Protected Sub gvPricing_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        SrcPrice.SelectCommand = GetPriceSql()
    End Sub

    Protected Sub TimerPrice_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerPrice.Interval = 99999
        If hd_PN.Value = "" Then
            imgPriceLoad.Visible = False
            TimerPrice.Enabled = False : Exit Sub
        End If
        Try
            SrcPrice.SelectCommand = GetPriceSql() : TimerPrice.Enabled = False
            If Util.IsAEUIT() OrElse Util.GetClientIP().StartsWith("172.21.") Then
                Dim rlpDt As DataTable = Util.GetEUPrice("EDDEVI07", "EU10", hd_PN.Value, Now)
                Dim itpDt As DataTable = Util.GetEUPrice("UUAAESC", "EU10", hd_PN.Value, Now)
                If rlpDt.Rows.Count > 0 And itpDt.Rows.Count > 0 Then
                    lbEURLP.Text = rlpDt.Rows(0).Item("Kzwi1").ToString()
                    lbEURITP.Text = itpDt.Rows(0).Item("Netwr").ToString()
                    divLPITP.Visible = True
                End If
            End If
            If Util.IsAEUIT() Then
                Dim costDt As DataTable = Util.GetEUPrice("ASPA001", "TW01", hd_PN.Value, Now)
                If costDt.Rows.Count > 0 Then
                    lbUSDCost.Text = costDt.Rows(0).Item("Netwr").ToString()
                    divCost.Visible = True
                End If
            End If
        Catch ex As Exception
            TimerPrice.Enabled = False
            Util.SendEmail("tc.chen@advantech.com.tw", "ebusiness.aeu@advantech.eu", "global MA error TimerPrice in PDashboard by " + Request.LogonUserIdentity.Name, ex.ToString(), False, "", "")
        End Try
        imgPriceLoad.Visible = False
    End Sub

    Protected Sub TimerTopSales_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerTopSales.Interval = 99999
        If hd_PN.Value <> "" Then
            Try
                Dim sfrom As Date = DateAdd(DateInterval.Year, -1, Now), sto = Now
                If Date.TryParse(txtTopSalesShipFrom.Text, Now) Then sfrom = CDate(txtTopSalesShipFrom.Text)
                If Date.TryParse(txtTopSalesShipTo.Text, Now) Then sto = CDate(txtTopSalesShipTo.Text)
                Dim PieDt As DataTable = dbUtil.dbGetDataTable("MY", _
                    " select cast(SUM(a.qty) as int) as qty, LEFT(a.org,2) as org from eai_sale_fact a " + _
                    String.Format(" where a.tran_type='shipment' and a.fact_1234=1 and a.item_no='{0}' and a.efftive_date between '{1}' and '{2}'  ", _
                                   hd_PN.Value, sfrom.ToString("yyyy-MM-dd"), sto.ToString("yyyy-MM-dd")) + _
                    " group by LEFT(a.org,2) order by LEFT(a.org,2)  ")
                'gvTopSales.DataSource = TopDt : gvTopSales.DataBind()
                srcTopSales.SelectCommand = GetTopSalesSql() : gvTopSales.EmptyDataText = "No Sales Data"
                gvSaleByReg.DataSource = PieDt : gvSaleByReg.DataBind()
                If PieDt.Rows.Count > 0 Then
                    Dim data(PieDt.Rows.Count - 1) As Double
                    Dim labels(PieDt.Rows.Count - 1) As String
                    For i As Integer = 0 To PieDt.Rows.Count - 1
                        data(i) = PieDt.Rows(i).Item("qty") : labels(i) = PieDt.Rows(i).Item("org")
                    Next
                    Dim c As New ChartDirector.PieChart(600, 500)
                    c.setPieSize(350, 250, 200)
                    c.addTitle("Sales By Region")
                    c.set3D()
                    c.setData(data, labels)
                    c.setExplode(0)
                    PieSalesByRegion.Image = c.makeWebImage(Chart.PNG)
                    PieSalesByRegion.ImageMap = c.getHTMLImageMap("", "", "title='{label}: {value}pcs ({percent}%)'")
                End If
            Catch ex As Exception
                MailUtil.SendDebugMsg("global MA load pd statistics failed", ex.ToString())
            End Try
        End If
        imgLoadTopSales.Visible = False : gvTopSales.Visible = True : PieSalesByRegion.Visible = True : TimerTopSales.Enabled = False
    End Sub

    Function GetTopSalesSql() As String
        Dim sfrom As Date = DateAdd(DateInterval.Year, -1, Now), sto = Now
        If Date.TryParse(txtTopSalesShipFrom.Text, Now) Then sfrom = CDate(txtTopSalesShipFrom.Text)
        If Date.TryParse(txtTopSalesShipTo.Text, Now) Then sto = CDate(txtTopSalesShipTo.Text)
        Return String.Format( _
                    " select top 100 b.FULL_NAME as sales_name, left(a.org,2) as org, cast(SUM(a.qty) as int) as qty     " + _
                    " from EAI_SALE_FACT a inner join SAP_EMPLOYEE b on a.Sales_ID=b.SALES_CODE     " + _
                    " where a.tran_type='shipment' and a.fact_1234=1 and a.item_no='{0}' and   " + _
                    " a.efftive_date between '{1}' and '{2}' and a.qty>0  " + _
                    " group by b.FULL_NAME, left(a.org,2)     " + _
                    " order by SUM(a.qty) desc, left(a.org,2)   ", hd_PN.Value, sfrom.ToString("yyyy-MM-dd"), sto.ToString("yyyy-MM-dd"))
    End Function

    Protected Sub btnRunStat_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        TimerTopSales_Tick(Nothing, Nothing)
    End Sub

    Protected Sub gvTopSales_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        srcTopSales.SelectCommand = GetTopSalesSql()
    End Sub

    Protected Sub dlCBOMReg_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        tvCBOM.Nodes.Clear() : Dim rootN As New TreeNode(Me.hd_PN.Value, Me.hd_PN.Value) : tvCBOM.Nodes.Add(rootN) : AppendCBOMNode(rootN)
    End Sub

    Sub AppendCBOMNode(ByVal n As TreeNode, Optional ByVal Deeper As Boolean = False)
        If Not Deeper And n.Depth > 2 Then Exit Sub
        Dim strSql As String = ""
        If True Then
            strSql = String.Format( _
                " select a.CATEGORY_ID, IsNull(a.CATEGORY_TYPE,'') as CATEGORY_TYPE, IsNull(b.STATUS,'N/A') as status " + _
                " from CBOM_CATALOG_CATEGORY a left join SAP_PRODUCT b on a.category_id=b.part_no " + _
                " where a.PARENT_CATEGORY_ID='{0}' and a.ORG='{1}' and a.CATEGORY_ID is not null order by a.SEQ_NO  ", n.Value, dlCBOMReg.SelectedValue)
        End If
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", strSql)
        For Each r As DataRow In dt.Rows
            If r.Item("category_type") = "Category" Or _
                (r.Item("category_type") = "Component" And _
                 (r.Item("status") = "A" Or r.Item("status") = "N" Or r.Item("status") = "S5" Or r.Item("status") = "H")) Then
                Dim cn As New TreeNode(r.Item("category_id"), r.Item("category_id"))
                n.ChildNodes.Add(cn)
                AppendCBOMNode(cn)
            End If
        Next
    End Sub

    Protected Sub tvCBOM_SelectedNodeChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim n As TreeNode = tvCBOM.SelectedNode
        If n IsNot Nothing AndAlso n.ChildNodes.Count = 0 Then
            AppendCBOMNode(n, True) : n.ExpandAll()
        End If
    End Sub

    Function GetBasketAnalysisSql(Optional ByVal TopCount As Integer = 5) As String
        If hd_PN.Value = "" Then Return ""
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select distinct top {0} a.REF_PART_NO as cross_part_no, a.orders, a.US_AMOUNT, ", TopCount.ToString()))
            .AppendLine(String.Format(" IsNull((select top 1 z.product_desc from [ACLSTNR12].MyAdvantechGlobal.dbo.SAP_PRODUCT z where z.part_no=a.REF_PART_NO),'') as product_desc  "))
            .AppendLine(String.Format(" from DM_BASKET_ANALYSIS a  "))
            .AppendLine(String.Format(" where a.PART_NO='{0}' ", hd_PN.Value))
            .AppendLine(String.Format(" order by a.ORDERS desc "))
        End With
        Return sb.ToString()
    End Function

    Protected Sub TimerBS_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            TimerBS.Interval = 99999
            srcBS.SelectCommand = GetBasketAnalysisSql()
        Catch ex As Exception

        End Try
        TimerBS.Enabled = False : imgLoadBS.Visible = False 'gvBS.Visible = True : gvBS.EmptyDataText = "No Data"
        dlstBS.Visible = True : lnkMoreBS.Visible = True
    End Sub

    Protected Sub btnQBS_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        srcBS.SelectCommand = GetBasketAnalysisSql()
        dlstBS.Visible = True
    End Sub

    Protected Sub lnkMoreBS_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim intMore As Integer = 20
        If ViewState("intMore") IsNot Nothing Then intMore = ViewState("intMore")
        srcBS.SelectCommand = GetBasketAnalysisSql(intMore)
        ViewState("intMore") = intMore + 10
        If CInt(ViewState("intMore")) >= 200 Then ViewState("intMore") = 200
        'lnkMoreBS.Visible = False
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript">
        function ShowHide() {
            var div = document.getElementById('div_PickPN');
            if (div.style.display == 'block') {
                div.style.display = 'none';
            }
            else {
                div.style.display = 'block';
            }
        }        
    </script>
    <asp:HiddenField runat="server" ID="hd_PN" />
    <table width="100%">
        <tr>
            <td align="right">
                <asp:LinkButton runat="server" ID="lnkPickPN" Font-Bold="true" Font-Size="Larger" Text="Pick Product" OnClientClick="ShowHide(); return false;" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <div id="div_PickPN" style="display:none; position:absolute;left:20px;top:100px; 
                                background-color:white;border: solid 1px silver;padding:10px; 
                                width:95%; height:420px;overflow:auto;">
                    <table width="95%">
                        <tr>
                            <td colspan="3" align="center"><asp:LinkButton runat="server" ID="lnkClosePickPN" Text="Close" Font-Bold="true" OnClientClick="ShowHide(); return false;" /></td>
                        </tr>
                        <tr>
                            <td align="center">
                                <asp:Panel runat="server" ID="panelSearhPickPN" DefaultButton="btnSearchPN">
                                    <table>
                                        <tr>
                                            <th colspan="2" style="font-size:larger">Please pick a part number from below list</th>
                                        </tr>
                                        <tr>
                                            <th align="left">Part No.</th>
                                            <td>
                                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="acext1" TargetControlID="txtPickPN" 
                                                    CompletionInterval="100" MinimumPrefixLength="1" ServicePath="~/Services/AutoComplete.asmx" 
                                                    ServiceMethod="GetPartNo" />
                                                <asp:TextBox runat="server" ID="txtPickPN" Width="220px" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <th align="left">Product Description</th><td><asp:TextBox runat="server" ID="txtPickPNDesc" Width="150px" />&nbsp;<asp:Button runat="server" ID="btnSearchPN" Text="Search" OnClick="btnSearchPN_Click" /></td>
                                        </tr>
                                    </table>
                                </asp:Panel>                                
                            </td>
                        </tr>
                        <tr>
                            <td align="center">     
                                <asp:UpdatePanel runat="server" ID="upPickPN" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:GridView runat="server" ID="gvPickPN" Width="95%" AutoGenerateColumns="false" 
                                            DataSourceID="SrcPickPN" AllowPaging="true" AllowSorting="true" 
                                            PagerSettings-Position="TopAndBottom" PageSize="20" 
                                            OnPageIndexChanging="gvPickPN_PageIndexChanging" OnSorting="gvPickPN_Sorting" 
                                            EmptyDataText="No Search Result" OnRowCreated="gvRowCreated">
                                            <Columns>
                                                <asp:HyperLinkField HeaderText="Part No." SortExpression="part_no" DataNavigateUrlFields="part_no" 
                                                    DataNavigateUrlFormatString="~/DM/ProductDashboard.aspx?PN={0}" DataTextField="part_no" />
                                                <asp:BoundField HeaderText="Model No." DataField="model_no" SortExpression="model_no" />
                                                <asp:BoundField HeaderText="Product Description" DataField="product_desc" SortExpression="product_desc" />
                                                <asp:HyperLinkField HeaderText="Product Hierarchy" DataNavigateUrlFields="PRODUCT_HIERARCHY" 
                                                    DataNavigateUrlFormatString="~/DM/PDDashboard.aspx?PH={0}" DataTextField="PRODUCT_HIERARCHY" 
                                                    SortExpression="PRODUCT_HIERARCHY" Target="_blank" />
                                                <asp:BoundField HeaderText="Status" DataField="status" SortExpression="status" ItemStyle-HorizontalAlign="Center" />
                                                <asp:TemplateField HeaderText="Created Date" SortExpression="CREATE_DATE" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%# IIf(Date.TryParseExact(Eval("CREATE_DATE"), "yyyyMMdd", New System.Globalization.CultureInfo("en-US"), System.Globalization.DateTimeStyles.None, Now), Date.ParseExact(Eval("CREATE_DATE"), "yyyyMMdd", New System.Globalization.CultureInfo("en-US")).ToString("yyyy/MM/dd"), Eval("CREATE_DATE"))%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField HeaderText="Material Group" DataField="material_group" SortExpression="material_group" ItemStyle-HorizontalAlign="Center" />
                                            </Columns>
                                        </asp:GridView>
                                        <asp:SqlDataSource runat="server" ID="SrcPickPN" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="SrcPickPN_Selecting" />
                                    </ContentTemplate>
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="btnSearchPN" EventName="Click" />
                                    </Triggers>
                                </asp:UpdatePanel>     
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr>
            <td align="right">
                <table>
                    <tr>
                        <th align="left">Part Number:</th>
                        <td>
                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="aextChgPN" TargetControlID="txtChgPN" 
                                MinimumPrefixLength="1" CompletionInterval="100" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetPartNo" />
                            <asp:TextBox runat="server" ID="txtChgPN" Width="180px" />
                        </td>
                        <td><asp:Button runat="server" ID="btnChgPN" Text="Change Product" OnClick="btnChgPN_Click" /></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td align="left">
                <ajaxToolkit:TabContainer runat="server" ID="tabc1" Width="100%">
                    <ajaxToolkit:TabPanel runat="server" ID="TabPanel0" HeaderText="Product Profile">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="gvProfile" Width="98%" AutoGenerateColumns="false" ShowHeader="false" 
                                            AllowPaging="true" AllowSorting="true" PageSize="10" DataSourceID="ProfileSrc" 
                                            PagerSettings-Position="TopAndBottom" DataKeyNames="model_no,part_no" OnRowCreated="gvRowCreated">
                                            <RowStyle BorderWidth="0px" />
                                            <Columns>                                              
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
                                                                            <%#Eval("part_no")%>
                                                                        </a>  
                                                                    </b>
                                                                    <%#IsROHSImage(Eval("ROHS_STATUS"))%>
                                                                    &nbsp;
                                                                    <div style="font-size:11px; display:inline;"><%#Eval("PRODUCT_DESC")%></div>                                                     
                                                                </td>
                                                            </tr>                                                
                                                            <tr>
                                                                <td valign="top">
                                                                    <table width="90%">
                                                                        <td style="background-color:#EFF7FF;">
                                                                            <%#Eval("EXTENTED_DESC")%>
                                                                        </td>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table>
                                                                        <tr>
                                                                            <td style="width:10px">&nbsp;</td>
                                                                            <td><%#Eval("FEATURES")%></td>
                                                                        </tr>                                                            
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table>
                                                                        <tr>
                                                                            <th align="left" style="width:160px">Product Hierarchy:</th>
                                                                            <td style="width:180px"><a target="_blank" href='PDDashboard.aspx?PH=<%#Eval("PRODUCT_HIERARCHY") %>'><%#Eval("PRODUCT_HIERARCHY") %></a></td>  
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table>
                                                                        <tr>
                                                                            <th align="left" style="width:100px">Net Weight:</th>
                                                                            <td style="width:50px"><%# Eval("NET_WEIGHT")%></td>   
                                                                            <th align="left" style="width:110px">Gross Weight:</th>
                                                                            <td style="width:50px"><%# Eval("GROSS_WEIGHT")%></td>   
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table>
                                                                        <tr>
                                                                            <th align="left" style="width:100px">Status:</th>
                                                                            <td style="width:50px"><%# Eval("STATUS")%></td>
                                                                            <th align="left" style="width:120px">Material Group:</th>
                                                                            <td style="width:50px"><%# Eval("material_group")%></td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>
                                                                    <table>
                                                                        <tr>
                                                                            <td><a href="#AncBS">Basket Analysis</a>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                                            <td><a href="#AncPricing">Pricing Information</a>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                                                            <td><a href="#AncPInOutInfo">PLM Phase In/Out Information</a>&nbsp;&nbsp;</td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ItemTemplate>
                                                </asp:TemplateField>    
                                            </Columns>
                                        </asp:GridView>
                                        <asp:SqlDataSource runat="server" ID="ProfileSrc" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="ProfileSrc_Selecting" />
                                    </td>
                                </tr>                    
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">Product Performance &nbsp;<asp:ImageButton runat="server" ImageUrl="~/Images/excel.gif" ID="imgPerfChartXls" AlternateText="Download" OnClick="imgPerfChartXls_Click" /></th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <th align="left">Year:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPerfYear" AutoPostBack="true" 
                                                                    OnSelectedIndexChanged="dlPerfYear_SelectedIndexChanged">
                                                                    <asp:ListItem Value="2008" />
                                                                    <asp:ListItem Value="2009" />
                                                                    <asp:ListItem Value="2010" />
                                                                    <asp:ListItem Value="2011" />
                                                                    <asp:ListItem Value="2012" />
                                                                    <asp:ListItem Value="2013" />
                                                                    <asp:ListItem Value="2014" Selected="True"/>
                                                                </asp:DropDownList>
                                                            </td>
                                                            <th align="left">Region:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPerfRegion" AutoPostBack="true" 
                                                                    OnSelectedIndexChanged="dlPerfYear_SelectedIndexChanged">
                                                                    <asp:ListItem Text="Global" Value="" />
                                                                    <asp:ListItem Text="Australia" Value="AU" />
                                                                    <asp:ListItem Text="Brazil" Value="BR" />
                                                                    <asp:ListItem Text="China" Value="CN" />
                                                                    <asp:ListItem Text="Dlog" Value="DL" />
                                                                    <asp:ListItem Text="Europe" Value="EU" />
                                                                    <asp:ListItem Text="Japan" Value="JP" />
                                                                    <asp:ListItem Text="Korea" Value="KR" />
                                                                    <asp:ListItem Text="Malaysia" Value="MY" />
                                                                    <asp:ListItem Text="Singapore" Value="SG" />
                                                                    <asp:ListItem Text="Taiwan" Value="TW" />
                                                                    <asp:ListItem Text="US" Value="US" />
                                                                </asp:DropDownList>
                                                            </td>
                                                            <th align="left">Sector:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPerfSector" AutoPostBack="true"
                                                                    OnSelectedIndexChanged="dlPerfYear_SelectedIndexChanged">
                                                                    <asp:ListItem Text="All" Value="" />
                                                                    <asp:ListItem Value="AiS" />
                                                                    <asp:ListItem Value="CSF" />
                                                                    <asp:ListItem Value="DLoG" />
                                                                    <asp:ListItem Value="AOnline" />
                                                                    <asp:ListItem Value="DMS(E2E)" />
                                                                    <asp:ListItem Value="EmbCore" />
                                                                    <asp:ListItem Value="KA:eAutomation" />
                                                                    <asp:ListItem Value="KA:ePlatform" />
                                                                    <asp:ListItem Value="MA" />
                                                                    <asp:ListItem Value="Medical" />
                                                                    <asp:ListItem Value="Others(RMA)" />
                                                                    <asp:ListItem Value="Telecom/Network" />
                                                                    <asp:ListItem Value="Transportation" />
                                                                </asp:DropDownList>
                                                            </td>
                                                            <th align="left">Unit:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPerfUnit" AutoPostBack="true" 
                                                                    OnSelectedIndexChanged="dlPerfYear_SelectedIndexChanged">
                                                                    <asp:ListItem Text="Qty." Value="Qty" />
                                                                    <asp:ListItem Text="USD Amount" Value="US_AMT" />
                                                                </asp:DropDownList>
                                                            </td>                                                            
                                                            <td>
                                                                <asp:CheckBoxList runat="server" ID="cblPerfTranType" RepeatColumns="2" 
                                                                    RepeatDirection="Horizontal" AutoPostBack="true"
                                                                    OnSelectedIndexChanged="dlPerfYear_SelectedIndexChanged">
                                                                    <asp:ListItem Value="Shipment" Selected="True" />
                                                                    <asp:ListItem Value="Backlog" />
                                                                </asp:CheckBoxList>
                                                            </td>
                                                        </tr>                                                
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upChart" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Image runat="server" ID="imgProdPerf" Width="1000px" Height="500px" 
                                                                ImageUrl="~/Includes/ProductChart.ashx" />
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="dlPerfYear" EventName="SelectedIndexChanged" />
                                                            <asp:AsyncPostBackTrigger ControlID="dlPerfRegion" EventName="SelectedIndexChanged" />
                                                            <asp:AsyncPostBackTrigger ControlID="dlPerfSector" EventName="SelectedIndexChanged" />
                                                            <asp:AsyncPostBackTrigger ControlID="dlPerfUnit" EventName="SelectedIndexChanged" />
                                                            <asp:AsyncPostBackTrigger ControlID="cblPerfTranType" EventName="SelectedIndexChanged" />
                                                            <asp:PostBackTrigger ControlID="imgPerfChartXls" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>                                        
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <th align="left">Basket Analysis (Customers Who Bought This Item Also Bought)<a name="AncBS" /></th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table>                                                        
                                                        <tr>
                                                            <td><asp:Button runat="server" ID="btnQBS" Text="Run Analysis" OnClick="btnQBS_Click" Visible="false" /></td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td align="right">
                                                    <asp:UpdatePanel runat="server" ID="upBS" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Timer runat="server" ID="TimerBS" Interval="3000" OnTick="TimerBS_Tick" Enabled="true" />
                                                            <asp:Image runat="server" ID="imgLoadBS" AlternateText="Loading Basket Analysis Data..." 
                                                                ImageUrl="~/Images/Loading2.gif" Visible="false" />
                                                            <asp:DataList runat="server" ID="dlstBS" DataSourceID="srcBS" Visible="false" HorizontalAlign="Left" 
                                                                RepeatDirection="Horizontal" RepeatColumns="5">                                                                
                                                                <ItemTemplate>
                                                                    <table width="200px" style="height:110px; border-style:groove;">
                                                                        <tr valign="top" align="center" style="height:30px">
                                                                            <td valign="top">
                                                                                <a style="font-weight:bold; font-size:small; color:#114B9F" target="_blank" href='ProductDashboard.aspx?PN=<%# Eval("cross_part_no")%>'>
                                                                                    <%# Eval("cross_part_no")%>
                                                                                </a>
                                                                            </td>
                                                                        </tr>
                                                                        <tr valign="top" align="center" style="height:10px">
                                                                            <td><%# Eval("orders")%> <%# IIf(CInt(Eval("orders")) > 1, "orders", "order")%></td>
                                                                        </tr>
                                                                        <tr valign="top" align="center" style="height:60px">
                                                                            <td>
                                                                                <div style="overflow:auto; width:199px"><%# Eval("product_desc")%></div>                                                                                
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:DataList>                                                                                                                              
                                                            <asp:LinkButton runat="server" ID="lnkMoreBS" Text="more..." OnClick="lnkMoreBS_Click" Visible="false" />                                                      
                                                            <asp:SqlDataSource runat="server" ID="srcBS" ConnectionString="<%$ConnectionStrings:MYLOCAL %>" OnSelecting="SrcPrice_Selecting" />
                                                        </ContentTemplate>
                                                        <Triggers> 
                                                            <asp:AsyncPostBackTrigger ControlID="btnQBS" EventName="Click" />                                                           
                                                        </Triggers>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>                                            
                                        </table>
                                    </td>
                                </tr>
                                <tr style="display:none">
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <th align="left">Pricing Information<a name="AncPricing" /></th>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <table>
                                                        <tr>
                                                            <th align="left">Year:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPriceYear">
                                                                    <asp:ListItem Value="2011" Selected="True" />
                                                                    <asp:ListItem Value="2010" />
                                                                </asp:DropDownList>
                                                            </td>
                                                            <th align="left">Quarter:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPriceQuarter">
                                                                    <asp:ListItem Text="Q1" Value="1" />
                                                                    <asp:ListItem Text="Q2" Value="2" />
                                                                    <asp:ListItem Text="Q3" Value="3" Selected="True" />
                                                                    <asp:ListItem Text="Q4" Value="4" />
                                                                </asp:DropDownList>
                                                            </td>
                                                            <th align="left">Currency:</th>
                                                            <td>
                                                                <asp:DropDownList runat="server" ID="dlPriceCurr">
                                                                    <asp:ListItem Value="CNY" />
                                                                    <asp:ListItem Value="EUR" Selected="True" />
                                                                    <asp:ListItem Value="GBP" />
                                                                    <asp:ListItem Value="JPY" />
                                                                    <asp:ListItem Value="MYR" />
                                                                    <asp:ListItem Value="SGD" />
                                                                    <asp:ListItem Value="TWD" />
                                                                    <asp:ListItem Value="USD" />
                                                                </asp:DropDownList>                                                                
                                                            </td>
                                                            <td>
                                                                <asp:Button runat="server" ID="btnChangePriceYQ" Text="Check Price" OnClick="btnChangePriceYQ_Click" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>                                                
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:UpdatePanel runat="server" ID="upPrice" UpdateMode="Conditional">
                                                        <ContentTemplate>
                                                            <asp:Timer runat="server" ID="TimerPrice" Interval="12000" OnTick="TimerPrice_Tick" Enabled="false" />
                                                            <asp:Image runat="server" ID="imgPriceLoad" ImageUrl="~/Images/loading2.gif" AlternateText="Loading Price..." Visible="false" />
                                                            <asp:GridView AllowPaging="true" AllowSorting="true" runat="server" ID="gvPricing" 
                                                                AutoGenerateColumns="false" DataSourceID="SrcPrice" 
                                                                OnPageIndexChanging="gvPricing_PageIndexChanging" OnSorting="gvPricing_Sorting" 
                                                                PageSize="20" PagerSettings-Position="TopAndBottom" OnRowCreated="gvRowCreated">
                                                                <Columns>
                                                                    <asp:BoundField HeaderText="Org." DataField="ORG" SortExpression="ORG" ItemStyle-HorizontalAlign="Center" />
                                                                    <asp:BoundField HeaderText="Grade" DataField="GRADE" SortExpression="GRADE" ItemStyle-HorizontalAlign="Center" />
                                                                    <asp:BoundField HeaderText="Currency" DataField="CURCY_CD" SortExpression="CURCY_CD" ItemStyle-HorizontalAlign="Center" />
                                                                    <asp:BoundField HeaderText="List Price" DataField="LIST_PRICE" SortExpression="LIST_PRICE" ItemStyle-HorizontalAlign="Right" />
                                                                    <asp:BoundField HeaderText="Discount(%)" DataField="DISCOUNT" SortExpression="DISCOUNT" ItemStyle-HorizontalAlign="Center" />
                                                                    <asp:BoundField HeaderText="Unit Price" DataField="AMT1" SortExpression="AMT1" ItemStyle-HorizontalAlign="Right" />
                                                                </Columns>
                                                            </asp:GridView>
                                                            <asp:SqlDataSource runat="server" ID="SrcPrice" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="SrcPrice_Selecting" />
                                                            <div runat="server" id="divLPITP" visible="false">
                                                                <table>
                                                                    <tr>
                                                                        <th align="left">EUR List Price</th>
                                                                        <td><asp:Label runat="server" ID="lbEURLP" /></td>
                                                                        <th align="left">EUR ITP</th>
                                                                        <td><asp:Label runat="server" ID="lbEURITP" /></td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                            <div runat="server" id="divCost" visible="false">
                                                                <table>
                                                                    <tr>                                                                        
                                                                        <th align="left">USD Cost</th>
                                                                        <td><asp:Label runat="server" ID="lbUSDCost" /></td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </ContentTemplate>
                                                        <Triggers>
                                                            <asp:AsyncPostBackTrigger ControlID="btnChangePriceYQ" EventName="Click" />
                                                        </Triggers>
                                                    </asp:UpdatePanel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td><hr /></td></tr>
                                <tr>
                                    <td>
                                        <table width="100%">
                                            <tr>
                                                <th align="left">PLM Phase In/Out Information<a name="AncPInOutInfo" /></th>
                                            </tr>
                                            <tr runat="server" id="tr_PIn">
                                                <td>
                                                    <table width="100%">
                                                        <tr>
                                                            <th align="left">Phase In Information:</th>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:GridView runat="server" ID="gvPIn" AutoGenerateColumns="false" DataSourceID="SrcPIn" OnDataBound="gvPIn_DataBound" OnRowCreated="gvRowCreated">
                                                                    <Columns>
                                                                        <asp:BoundField HeaderText="Change Number" DataField="CHANGE_NUMBER" SortExpression="CHANGE_NUMBER" />
                                                                        <asp:BoundField HeaderText="Release Date" DataField="RELEASE_DATE" SortExpression="RELEASE_DATE" />
                                                                        <asp:BoundField HeaderText="Rev. Number" DataField="REV_NUMBER" SortExpression="REV_NUMBER" />
                                                                        <asp:BoundField HeaderText="Description" DataField="DESCRIPTION" SortExpression="DESCRIPTION" />
                                                                        <asp:BoundField HeaderText="Change Description" DataField="CHANGE_DESC" SortExpression="CHANGE_DESC" />
                                                                    </Columns>
                                                                </asp:GridView>
                                                                <asp:SqlDataSource runat="server" ID="SrcPIn" ConnectionString="<%$ConnectionStrings:MY %>"
                                                                    SelectCommand="select CHANGE_NUMBER, RELEASE_DATE, REV_NUMBER, DESCRIPTION, CHANGE_DESC from PLM_PHASEIN where ITEM_NUMBER=@PN">
                                                                    <SelectParameters>
                                                                        <asp:ControlParameter ControlID="hd_PN" ConvertEmptyStringToNull="false" Name="PN" PropertyName="Value" />
                                                                    </SelectParameters>
                                                                </asp:SqlDataSource> 
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr runat="server" id="tr_POut">
                                                <td>
                                                    <table width="100%">
                                                        <tr>
                                                            <th align="left">Phase Out Information:</th>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:GridView runat="server" ID="gvPOut" AutoGenerateColumns="false" DataSourceID="SrcPOut" OnDataBound="gvPOut_DataBound" OnRowCreated="gvRowCreated">
                                                                    <Columns>
                                                                        <asp:BoundField HeaderText="Change Number" DataField="CHANGE_NUMBER" SortExpression="CHANGE_NUMBER" />
                                                                        <asp:BoundField HeaderText="Release Date" DataField="RELEASE_DATE" SortExpression="RELEASE_DATE" />
                                                                        <asp:BoundField HeaderText="Rev. Number" DataField="REV_NUMBER" SortExpression="REV_NUMBER" />
                                                                        <asp:BoundField HeaderText="Description" DataField="DESCRIPTION" SortExpression="DESCRIPTION" />
                                                                        <asp:BoundField HeaderText="Replaced By" DataField="REPLACE_BY" SortExpression="REPLACE_BY" />
                                                                        <asp:BoundField HeaderText="Last Buy Date" DataField="LAST_BUY_DATE" SortExpression="LAST_BUY_DATE" />
                                                                        <asp:BoundField HeaderText="Change Description" DataField="CHANGE_DESC" SortExpression="CHANGE_DESC" />
                                                                    </Columns>
                                                                </asp:GridView>
                                                                <asp:SqlDataSource runat="server" ID="SrcPOut" ConnectionString="<%$ConnectionStrings:MY %>"
                                                                    SelectCommand="select CHANGE_NUMBER, RELEASE_DATE, REV_NUMBER, DESCRIPTION, REPLACE_BY, LAST_BUY_DATE, CHANGE_DESC from PLM_PHASEOUT where ITEM_NUMBER=@PN" OnSelecting="SrcPOut_Selecting">
                                                                    <SelectParameters>
                                                                        <asp:ControlParameter ControlID="hd_PN" ConvertEmptyStringToNull="false" Name="PN" PropertyName="Value" />
                                                                    </SelectParameters>
                                                                </asp:SqlDataSource> 
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td><hr /></td></tr>
                            </table>                
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="Tab01" HeaderText="CBOM" Visible="false">
                        <ContentTemplate>
                            <asp:UpdatePanel runat="server" ID="upCBOM" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <table width="100%">
                                        <tr>
                                            <th align="left">Region</th>
                                            <td>
                                                <asp:DropDownList runat="server" ID="dlCBOMReg" AutoPostBack="true" OnSelectedIndexChanged="dlCBOMReg_SelectedIndexChanged">
                                                    <asp:ListItem Text="Taiwan" Value="TW" Selected="True" />
                                                    <asp:ListItem Text="China" Value="CN" />
                                                    <asp:ListItem Text="US eStore" Value="US" />
                                                    <asp:ListItem Text="US MyAdvantech" Value="MYUS" />
                                                    <asp:ListItem Text="Europe" Value="EU" />
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <asp:TreeView runat="server" ID="tvCBOM" ExpandDepth="1" OnSelectedNodeChanged="tvCBOM_SelectedNodeChanged"></asp:TreeView>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </asp:UpdatePanel>                            
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="TabPanel1" HeaderText="Forecast">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">Opportunity Name</th><td><asp:TextBox runat="server" ID="txtForOptyName" /></td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" align="center"><asp:Button runat="server" ID="btnSearchForecast" Text="Search" OnClick="btnSearchForecast_Click" /></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upForecast" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:ImageButton runat="server" ID="imgForecastXls" ImageUrl="~/Images/excel.gif" AlternateText="Download" OnClick="imgForecastXls_Click" />
                                                <asp:Timer runat="server" ID="TimerForecast" Interval="4000" OnTick="TimerForecast_Tick" />
                                                <center><center><asp:Image runat="server" ID="imgForecastLoad" ImageUrl="~/Images/loading2.gif" /></center></center>
                                                <asp:GridView runat="server" ID="gvForecast" Width="100%" AutoGenerateColumns="false" AllowPaging="true" PageSize="50"
                                                    AllowSorting="true" PagerSettings-Position="TopAndBottom" DataSourceID="SrcForecast" OnRowCreated="gvRowCreated" 
                                                    OnPageIndexChanging="gvForecast_PageIndexChanging" OnSorting="gvForecast_Sorting">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="Part No." DataField="PART_NO" SortExpression="PART_NO" />
                                                        <asp:BoundField HeaderText="Sales" DataField="SALES_NAME" SortExpression="SALES_NAME" />
                                                        <asp:BoundField HeaderText="RBU" DataField="RBU" SortExpression="RBU" />
                                                        <asp:BoundField HeaderText="Opportunity Name" DataField="OPTY_NAME" SortExpression="OPTY_NAME" />
                                                        <asp:BoundField HeaderText="Description" DataField="DESC_TEXT" SortExpression="DESC_TEXT" />
                                                        <asp:BoundField HeaderText="Probability" DataField="SUM_WIN_PROB" SortExpression="SUM_WIN_PROB" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:HyperLinkField HeaderText="Account Name" SortExpression="account_name" DataNavigateUrlFields="ACCOUNT_ROW_ID" 
                                                            DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ROWID={0}" 
                                                            DataTextField="account_name" Target="_blank" />
                                                        <asp:BoundField HeaderText="Created Date" DataField="CREATED" SortExpression="CREATED" />
                                                        <asp:BoundField HeaderText="Last Updated Date" DataField="LAST_UPD" SortExpression="LAST_UPD" />
                                                        <asp:BoundField HeaderText="Close Date" DataField="CLOSE_DATE" SortExpression="CLOSE_DATE" />
                                                        <asp:BoundField HeaderText="Total Qty." DataField="TOTAL_QTY" SortExpression="TOTAL_QTY" ItemStyle-HorizontalAlign="Center" />
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="SrcForecast" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="SrcForecast_Selecting" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnSearchForecast" EventName="Click" />
                                                <asp:PostBackTrigger ControlID="imgForecastXls" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="TabPanel2" HeaderText="Inventory">
                        <ContentTemplate>
                            <asp:UpdatePanel runat="server" ID="upInv" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <asp:Timer runat="server" ID="TimerInv" Interval="8000" OnTick="TimerInv_Tick" />                                   
                                    <center><center><asp:Image runat="server" ID="imgInvLoad" ImageUrl="~/Images/loading2.gif" /></center></center>
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:GridView runat="server" ID="gvInv" AutoGenerateColumns="false" Width="800px" 
                                                    AllowSorting="false" AllowPaging="false" PageSize="50" PagerSettings-Position="TopAndBottom"                                                     
                                                    OnPageIndexChanging="gvInv_PageIndexChanging" OnSorting="gvInv_Sorting" OnRowCreated="gvRowCreated">
                                                    <Columns>
                                                        <asp:BoundField HeaderText="Plant" DataField="Plant" SortExpression="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Available Date" DataField="atp_date" SortExpression="atp_date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Available Qty." DataField="atp_qty" SortExpression="atp_qty" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                    </Columns>
                                                </asp:GridView>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right">
                                                <asp:Label runat="server" ID="lbInvTotal" Font-Bold="true" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <table width="100%">
                                                    <tr>
                                                        <th align="left">Safety Stock Setting</th>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:DataList runat="server" ID="dlstSafetyStock" HorizontalAlign="Left" 
                                                                RepeatDirection="Horizontal" RepeatColumns="5">                                                                
                                                                <ItemTemplate>
                                                                    <table width="200px" style="height:110px; border-style:groove;">
                                                                        <tr valign="top" align="center" style="height:10px">
                                                                            <td valign="top"><%# Eval("PLANT")%></td>
                                                                        </tr>
                                                                        <tr valign="top" align="center" style="height:10px">
                                                                            <td><%# Eval("SAFETY_STOCK")%></td>
                                                                        </tr>                                                                        
                                                                    </table>
                                                                </ItemTemplate>
                                                            </asp:DataList>                                                               
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>                                    
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="TabPanel3" HeaderText="Order History">
                        <ContentTemplate>
                            <table width="100%">
                                <tr>
                                    <td><asp:HyperLink runat="server" ID="hyCTOSOrder" Visible="false" Target="_blank" Font-Bold="true" Font-Size="Larger" /></td>
                                </tr>
                                <tr>
                                    <td>
                                        <table>
                                            <tr>
                                                <th align="left">Customer Name</th>
                                                <td><asp:TextBox runat="server" ID="txtPerfCustName" Width="150px" /></td>
                                                <th align="left">Sales Name</th>
                                                <td><asp:TextBox runat="server" ID="txtPerfSalesName" Width="100px" /></td>
                                            </tr>
                                            <tr>
                                                <th align="left">Due Date</th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender3" TargetControlID="txtPerfDueFrom" Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender4" TargetControlID="txtPerfDueTo" Format="yyyy/MM/dd" />
                                                    <asp:TextBox runat="server" ID="txtPerfDueFrom" Width="80px" />&nbsp;to&nbsp;<asp:TextBox runat="server" ID="txtPerfDueTo" Width="80px" />
                                                </td>
                                                <th align="left">Backlog or Shipment?</th>
                                                <td>
                                                    <asp:RadioButtonList runat="server" ID="rblPerfType" RepeatColumns="3" RepeatDirection="Horizontal">
                                                        <asp:ListItem Text="Both" Selected="True" />
                                                        <asp:ListItem Value="Backlog" />
                                                        <asp:ListItem Value="Shipment" />
                                                    </asp:RadioButtonList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left">Local Currency:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" AutoPostBack="false" ID="dlPerfCurr">
                                                        <asp:ListItem Text="USD" Value="US_AMT" Selected="True" />
                                                        <asp:ListItem Value="EUR" />
                                                        <asp:ListItem Value="TWD" />
                                                        <asp:ListItem Value="RMB" />
                                                        <asp:ListItem Value="JPY" />
                                                        <asp:ListItem Value="SGD" />
                                                        <asp:ListItem Value="AUD" />
                                                        <asp:ListItem Value="MYR" />
                                                        <asp:ListItem Value="BRL" />
                                                        <asp:ListItem Value="KRW" />
                                                    </asp:DropDownList>
                                                </td>
                                                <th align="left">Region:</th>
                                                <td>
                                                    <asp:DropDownList runat="server" ID="dlOrderHistoryOrg">
                                                        <asp:ListItem Value="All" />
                                                        <asp:ListItem Value="AU" />
                                                        <asp:ListItem Value="BR" />
                                                        <asp:ListItem Value="CN" />
                                                        <asp:ListItem Value="DL" />
                                                        <asp:ListItem Value="EU" />
                                                        <asp:ListItem Value="JP" />
                                                        <asp:ListItem Value="KR" />
                                                        <asp:ListItem Value="MY" />
                                                        <asp:ListItem Value="SG" />
                                                        <asp:ListItem Value="TW" />
                                                        <asp:ListItem Value="US" />
                                                    </asp:DropDownList>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="4" align="center">
                                                    <asp:Button runat="server" ID="btnQueryPerf" Text="Search" OnClick="btnQueryPerf_Click" />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:UpdatePanel runat="server" ID="upOrderHistory" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Timer runat="server" ID="PerfTimer" Interval="11000" OnTick="PerfTimer_Tick" />
                                                <center><asp:Image runat="server" ID="imgPerfLoad" ImageUrl="~/Images/loading2.gif" /></center>
                                                <asp:ImageButton runat="server" ID="imgPerfXls" AlternateText="Download" 
                                                    ImageUrl="~/Images/excel.gif" OnClick="imgPerfXls_Click" />
                                                <asp:GridView runat="server" ID="gvPerf" Width="100%" PageSize="50" AutoGenerateColumns="false" 
                                                    PagerSettings-Position="TopAndBottom" AllowPaging="true" AllowSorting="true" 
                                                    DataSourceID="PerfSrc" OnPageIndexChanging="gvPerf_PageIndexChanging" OnSorting="gvPerf_Sorting" OnRowCreated="gvRowCreated">
                                                    <Columns>
                                                        <asp:HyperLinkField HeaderText="Customer Name" DataNavigateUrlFields="Customer_ID" 
                                                            DataNavigateUrlFormatString="~/DM/CustomerDashboard.aspx?ERPID={0}" 
                                                            DataTextField="company_name" Target="_blank" />
                                                        <asp:TemplateField HeaderText="Org." SortExpression="org" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Left(Eval("org"),2) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField HeaderText="Sales Name" DataField="sales_name" SortExpression="sales_name" />                                     
                                                        <asp:TemplateField HeaderText="Due Date" SortExpression="due_date">
                                                            <ItemTemplate>
                                                                <%# CDate(Eval("due_date")).ToString("yyyy/MM/dd")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:BoundField HeaderText="Transaction Type" DataField="Tran_Type" SortExpression="Tran_Type" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Qty." DataField="Qty" SortExpression="Qty" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Sector" DataField="sector" SortExpression="sector" ItemStyle-HorizontalAlign="Center" />
                                                        <asp:BoundField HeaderText="Order No." DataField="order_no" SortExpression="order_no" />
                                                        <asp:TemplateField HeaderText="Order Date" SortExpression="order_date">
                                                            <ItemTemplate>
                                                                <%# CDate(Eval("order_date")).ToString("yyyy/MM/dd")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="US Amount" SortExpression="Us_amt">
                                                            <ItemTemplate>
                                                                <%#FormatNumber(Eval("Us_amt"),2) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Local Amount" SortExpression="Local_Amt">
                                                            <ItemTemplate>
                                                                <%#FormatNumber(Eval("Local_Amt"),2) %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField><%--
                                                        <asp:BoundField HeaderText="US Amount" DataField="Us_amt" SortExpression="Us_amt" ItemStyle-HorizontalAlign="Right" />
                                                        <asp:BoundField HeaderText="Local Amount" DataField="Local_Amt" SortExpression="Local_Amt" ItemStyle-HorizontalAlign="Right" />--%>
                                                        <asp:BoundField HeaderText="Product Group" DataField="product_group" SortExpression="product_group" />
                                                        <asp:BoundField HeaderText="Product Division" DataField="product_division" SortExpression="product_division" />
                                                        <asp:BoundField HeaderText="Product Line" DataField="Product_Line" SortExpression="Product_Line" />
                                                        <asp:BoundField HeaderText="PO" DataField="PO" SortExpression="PO" Visible="false" />
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:SqlDataSource runat="server" ID="PerfSrc" ConnectionString="<%$ConnectionStrings:MY %>" OnSelecting="PerfSrc_Selecting" />
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnQueryPerf" EventName="Click" />
                                                <asp:PostBackTrigger ControlID="imgPerfXls" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel runat="server" ID="tab7" HeaderText="Statistics">
                        <ContentTemplate>
                            <table>
                                <tr>
                                    <td colspan="3">
                                        <table width="400px">
                                            <tr>
                                                <th align="left">Shipment Date:</th>
                                                <td>
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="cextTopSalesFrom" TargetControlID="txtTopSalesShipFrom" Format="yyyy/MM/dd" />
                                                    <ajaxToolkit:CalendarExtender runat="server" ID="cextTopSalesTo" TargetControlID="txtTopSalesShipTo" Format="yyyy/MM/dd" />
                                                    <asp:TextBox runat="server" ID="txtTopSalesShipFrom" Width="80px" />~<asp:TextBox runat="server" ID="txtTopSalesShipTo" Width="80px" />
                                                </td>
                                                <td><asp:Button runat="server" ID="btnRunStat" Text="Run" OnClick="btnRunStat_Click" /></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:UpdatePanel runat="server" ID="upStat" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <asp:Timer runat="server" ID="TimerTopSales" Interval="30000" OnTick="TimerTopSales_Tick" Enabled="false" />
                                                <asp:Image runat="server" ID="imgLoadTopSales" Visible="false" ImageUrl="~/Images/Loading2.gif" AlternateText="Loading Top Sales" />
                                                <table>
                                                    <tr valign="center">
                                                        <td>
                                                            <asp:UpdatePanel runat="server" ID="upPie" UpdateMode="Conditional">
                                                                <ContentTemplate>
                                                                    <chartdir:WebChartViewer runat="server" ID="PieSalesByRegion" Visible="false" />
                                                                </ContentTemplate>
                                                            </asp:UpdatePanel>                                                            
                                                        </td>
                                                        <td>
                                                            <asp:GridView runat="server" ID="gvSaleByReg" Width="300px" AutoGenerateColumns="false" OnRowCreated="gvRowCreated">
                                                                <Columns>
                                                                    <asp:BoundField HeaderText="Region" DataField="org" ItemStyle-HorizontalAlign="Center" />
                                                                    <asp:BoundField HeaderText="Qty." DataField="qty" ItemStyle-HorizontalAlign="Center" />
                                                                </Columns>
                                                            </asp:GridView>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <th align="left" colspan="2">Top Sales</th>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <asp:UpdatePanel runat="server" ID="upTopSales" UpdateMode="Conditional">
                                                                <ContentTemplate>
                                                                    <asp:GridView runat="server" Width="600px" ID="gvTopSales" AutoGenerateColumns="false" AllowSorting="true" 
                                                                        Visible="false" DataSourceID="srcTopSales" OnSorting="gvTopSales_Sorting" OnRowCreated="gvRowCreated">
                                                                        <Columns>
                                                                            <asp:BoundField HeaderText="Sales Name" DataField="sales_name" SortExpression="sales_name" />
                                                                            <asp:BoundField HeaderText="Region" DataField="org" SortExpression="org" ItemStyle-HorizontalAlign="Center" />
                                                                            <asp:BoundField HeaderText="Qty." DataField="qty" SortExpression="qty" ItemStyle-HorizontalAlign="Center" />
                                                                        </Columns>
                                                                    </asp:GridView>   
                                                                    <asp:SqlDataSource runat="server" ID="srcTopSales" ConnectionString="<%$ConnectionStrings:MY %>" />
                                                                </ContentTemplate>
                                                            </asp:UpdatePanel>                                                            
                                                        </td>
                                                    </tr>
                                                </table>                                                                                             
                                            </ContentTemplate>
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnRunStat" EventName="Click" />
                                            </Triggers>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </td>
        </tr>
    </table>    
    <script type="text/javascript">
        setTimeout("ShowPickDivWhenPNNull();", 500);
        function ShowPickDivWhenPNNull() {
            if (document.getElementById('<%=hd_PN.ClientID %>').value == '') {
                document.getElementById('div_PickPN').style.display = 'block';
            }
        }        
    </script>
</asp:Content>