<%@ Page Title="MyAdvantech - Customer Credit Info Inquiry" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetSODetailRecords(SONO As String) As String
        Dim dtSODetail = GetOrderDetail(SONO)
        Return Util.DataTableToJSON(dtSODetail)
    End Function

    Public Class SAPCompany
        Public Property CompanyId As String : Public Property CompanyName As String : Public Property SalesOrg As String
    End Class

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function SearchSAPCompany(CompanyName As String, CompanyId As String) As String
        Dim CompanyList As New List(Of SAPCompany)
        Dim sql As String = "select top 20 a.company_id, a.company_name, a.org_id from sap_dimcompany a (nolock) where a.company_type='Z001' "
        If Not String.IsNullOrEmpty(CompanyName) Then sql += " and a.company_name like N'%" + Trim(CompanyName).Replace("'", "''").Replace("*", "%") + "%' "
        If Not String.IsNullOrEmpty(CompanyId) Then sql += " and a.company_id like N'" + Trim(CompanyId).Replace("'", "''").Replace("*", "%") + "%' "
        sql += " order by a.company_id, a.org_id"
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql)
        For Each r As DataRow In dt.Rows
            Dim SAPCompany1 As New SAPCompany()
            SAPCompany1.CompanyId = r.Item("company_id") : SAPCompany1.CompanyName = r.Item("company_name") : SAPCompany1.SalesOrg = r.Item("org_id")
            CompanyList.Add(SAPCompany1)
        Next
        Dim serializer As New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(CompanyList)
    End Function

    Protected Sub btnCheck_Click(sender As Object, e As EventArgs)
        lbMsg.Text = "" : tabcon1.Visible = False
        If String.IsNullOrEmpty(Trim(txtCustomerID.Text)) Then
            lbMsg.Text = "Please input a customer id first" : Exit Sub
        End If
        If Util.GetCheckedCountFromCheckBoxList(cblDocTypes) = 0 Then
            lbMsg.Text = "Please select at least one document type first" : Exit Sub
        End If
        Dim CompanyId = Trim(txtCustomerID.Text).ToUpper()

        Dim dtVKORG As DataTable = dbUtil.dbGetDataTable("MY", _
                                                         "select distinct ORG_ID from sap_dimcompany a (nolock) " + _
                                                         " where a.company_id='" + Replace(CompanyId, "'", "''") + "' order by ORG_ID")

        If dtVKORG.Rows.Count = 0 Then
            lbMsg.Text = CompanyId + " is an invalid customer id" : Exit Sub
        End If

        cblVKORG.Items.Clear()
        For Each orgRow As DataRow In dtVKORG.Rows
            Dim itemOrg As New ListItem(orgRow.Item("ORG_ID"), orgRow.Item("ORG_ID")) : itemOrg.Selected = True
            cblVKORG.Items.Add(itemOrg)
        Next

        tabcon1.Visible = True
        gvCustMemo.EmptyDataText = "No Data" : gvCreditInfo.EmptyDataText = "No Data"
        StartQueryThreads()
    End Sub

    Sub StartQueryThreads()
        Dim ThreadMemoReq As New Threading.Thread(AddressOf ShowMemoRequest), ThreadCreditInfo As New Threading.Thread(AddressOf ShowCreditLimit)

        ThreadMemoReq.Start() : ThreadCreditInfo.Start()
        ThreadMemoReq.Join() : ThreadCreditInfo.Join()
    End Sub

    Public Sub ShowCreditLimit()
        Try
            Dim CompanyId = Trim(txtCustomerID.Text).ToUpper()
            Dim dtOrgList = dbUtil.dbGetDataTable("MY", "select distinct org_id, currency from sap_dimcompany a (nolock) where a.company_id='" + Replace(CompanyId, "'", "''") + "' order by org_id")
            Dim dtCreditInfo As New DataTable
            With dtCreditInfo.Columns
                .Add("SalesOrg") : .Add("Currency") : .Add("CreditLimit", GetType(Decimal)) : .Add("CreditExposure", GetType(Decimal)) : .Add("Percentage")
            End With
            Dim SAPDAL1 As New SAPDAL.SAPDAL
            For Each orgRow As DataRow In dtOrgList.Rows
                Dim VKOrgListItem As ListItem = cblVKORG.Items.FindByText(orgRow.Item("org_id"))
                If VKOrgListItem IsNot Nothing AndAlso VKOrgListItem.Selected Then
                    Dim creditLimit As Decimal, creditExposure As Decimal, percentage As String = String.Empty
                    If SAPDAL1.GetCustomerCreditExposure(CompanyId, orgRow.Item("org_id"), creditLimit, creditExposure, percentage) Then
                        Dim CreditRow As DataRow = dtCreditInfo.NewRow()
                        With CreditRow
                            .Item("SalesOrg") = orgRow.Item("org_id") : .Item("Currency") = orgRow.Item("Currency")
                            .Item("CreditLimit") = creditLimit : .Item("CreditExposure") = creditExposure : .Item("percentage") = percentage
                        End With
                        dtCreditInfo.Rows.Add(CreditRow)
                    End If
                End If
            Next
            gvCreditInfo.DataSource = dtCreditInfo : gvCreditInfo.DataBind()
        Catch ex As Exception
            lbMsg.Text += "Error when running sub ShowCreditLimit. " + ex.ToString()
        End Try
    End Sub

    Public Sub ShowMemoRequest()
        Try
            Dim CompanyId = Trim(txtCustomerID.Text).ToUpper()
            Dim dtMemo = SearchCustMemoOrders(CompanyId)
            gvCustMemo.DataSource = dtMemo : gvCustMemo.DataBind()
        Catch ex As Exception
            lbMsg.Text += "Error when running sub ShowMemoRequest. " + ex.ToString()
        End Try
    End Sub

    Public Shared Function FormatToSAPSODNNo(ByVal str As String) As String
        If String.IsNullOrEmpty(str) Then Return ""
        str = UCase(str)
        If Not Decimal.TryParse(str.Substring(0, 1), 0) Then Return str
        While str.Length < 10
            str = "0" + str
        End While
        Return str
    End Function

    Public Shared Function GetOrderDetail(SONO As String) As DataTable
        Dim sql As String = _
           " select distinct a.vbeln as SO_NO, b.matnr as PART_NO, a.WAERK as CURRENCY, b.posnr AS LINE_NO,  " + _
            " c.vbeln as INVOICE_NO, c.fkimg as INVOICE_QTY, b.netwr as TOTAL_PRICE, b.NETPR as UNIT_PRICE, " + _
            " b.KWMENG as ORDER_QTY, b.ZMENG as TARGET_QTY, d.fkdat AS INVOICE_DATE " + _
            " from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln " + _
            " left join saprdp.vbrp c on a.vbeln=c.aubel and b.posnr=c.posnr left join saprdp.vbrk d on d.vbeln=c.vbeln " + _
            " where a.mandt='168' and a.vbeln='" + FormatToSAPSODNNo(SONO) + "' order by b.posnr "
        Dim dtOrderDetail As New DataTable
        Dim aptSAP As New Oracle.DataAccess.Client.OracleDataAdapter(sql, ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
        aptSAP.Fill(dtOrderDetail)
        aptSAP.SelectCommand.Connection.Close()

        With dtOrderDetail.Columns
            .Add("TOTAL_PRICE_CURR") : .Add("ZPN0") : .Add("ZPR0") : .Add("ZMIP")
        End With


        Dim SAPCurrencyFactors = New List(Of CurrencyFactor)
        Dim dtSAPCurrencyFactor = dbUtil.dbGetDataTable("MY", "select CURRENCY, FACTOR from SAP_TCURX (nolock)")
        For Each r As DataRow In dtSAPCurrencyFactor.Rows
            Dim f1 As New CurrencyFactor()
            f1.Currency = Trim(r.Item("CURRENCY")) : f1.Factor = r.Item("FACTOR")
            SAPCurrencyFactors.Add(f1)
        Next

        Dim rfc1 As New BAPISDORDER_GETDETAILEDLIST.BAPISDORDER_GETDETAILEDLIST(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim bapi_view As New BAPISDORDER_GETDETAILEDLIST.ORDER_VIEW
        With bapi_view
            .Sdcond = "X"
        End With

        Dim salesKeyTable As New BAPISDORDER_GETDETAILEDLIST.SALES_KEYTable, salesKey1 As New BAPISDORDER_GETDETAILEDLIST.SALES_KEY
        salesKey1.Vbeln = FormatToSAPSODNNo(SONO)
        Dim conditionOut As New BAPISDORDER_GETDETAILEDLIST.BAPISDCONDTable
        Dim scheduleTab As New BAPISDORDER_GETDETAILEDLIST.BAPISDHEDUTable
        salesKeyTable.Add(salesKey1)
        rfc1.Connection.Open()
        rfc1.Bapisdorder_Getdetailedlist(bapi_view, "", New BAPISDORDER_GETDETAILEDLIST.BAPIPAREXTable, New BAPISDORDER_GETDETAILEDLIST.BAPISDCOADTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPISDBPLDTable, New BAPISDORDER_GETDETAILEDLIST.BAPISDBPLTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPISDBUSITable, New BAPISDORDER_GETDETAILEDLIST.BAPICUBLBMTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPICUCFGMTable, New BAPISDORDER_GETDETAILEDLIST.BAPICUINSMTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPICUPRTMTable, New BAPISDORDER_GETDETAILEDLIST.BAPICUREFMTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPICUVALMTable, New BAPISDORDER_GETDETAILEDLIST.BAPICUVKMTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPICONDHDTable, New BAPISDORDER_GETDETAILEDLIST.BAPICONDITTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPICONDQSTable, New BAPISDORDER_GETDETAILEDLIST.BAPICONDVSTable, _
                                         conditionOut, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPISDCNTRTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPICCARDMTable, New BAPISDORDER_GETDETAILEDLIST.BAPISDFLOWTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPISDHDTable, New BAPISDORDER_GETDETAILEDLIST.BAPISDITTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPISDPARTTable, _
                                         scheduleTab, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPISDHDSTTable, New BAPISDORDER_GETDETAILEDLIST.BAPISDITSTTable, _
                                         New BAPISDORDER_GETDETAILEDLIST.BAPISDTEHDTable, New BAPISDORDER_GETDETAILEDLIST.BAPITEXTLITable, _
                                         salesKeyTable)

        rfc1.Connection.Close()

        Dim PriceCondList As New List(Of BAPISDORDER_GETDETAILEDLIST.BAPISDCOND)
        For Each pcond In conditionOut
            PriceCondList.Add(pcond)
        Next

        'GridView1.DataSource = conditionOut.ToADODataTable() : GridView1.DataBind()
        For Each r As DataRow In dtOrderDetail.Rows
            Dim f = From q In SAPCurrencyFactors Where q.Currency = r.Item("CURRENCY")
            If f.Count > 0 Then
                r.Item("TOTAL_PRICE_CURR") = Util.FormatMoney(r.Item("TOTAL_PRICE") * Math.Pow(10, 2 - f.First.Factor), r.Item("CURRENCY"))
                r.Item("UNIT_PRICE") = r.Item("UNIT_PRICE") * Math.Pow(10, 2 - f.First.Factor)
            Else
                r.Item("TOTAL_PRICE_CURR") = Util.FormatMoney(r.Item("TOTAL_PRICE"), r.Item("CURRENCY"))
            End If

            If r.Item("INVOICE_DATE") IsNot DBNull.Value Then r.Item("INVOICE_DATE") = Global_Inc.SAPDate2StdDate(r.Item("INVOICE_DATE")).ToString("yyyy/MM/dd")

            Dim zpn0 = From q In PriceCondList Where q.Cond_Type = "ZPN0" And q.Itm_Number = r.Item("LINE_NO")
            If zpn0.Count > 0 Then r.Item("ZPN0") = Util.FormatMoney(Math.Round(zpn0.First.Cond_Value, 2), zpn0.First.Currency)
            Dim zpr0 = From q In PriceCondList Where q.Cond_Type = "ZPR0" And q.Itm_Number = r.Item("LINE_NO")
            If zpr0.Count > 0 Then r.Item("ZPR0") = Util.FormatMoney(Math.Round(zpr0.First.Cond_Value, 2), zpr0.First.Currency)
            Dim zmip = From q In PriceCondList Where q.Cond_Type = "ZMIP" And q.Itm_Number = r.Item("LINE_NO")
            If zmip.Count > 0 Then r.Item("ZMIP") = Util.FormatMoney(Math.Round(zmip.First.Cond_Value, 2), zmip.First.Currency)
        Next
        Return dtOrderDetail
    End Function

    Function SearchCustMemoOrders(CompanyId As String) As DataTable
        Dim VKORGInStr As String = Util.GetInStrinFromCheckBoxList(cblVKORG)
        Dim sql As String = _
            " select a.vbeln as SO_NO, a.auart as DOC_TYPE, b.bezei as doc_type_desc,  " + _
            " a.erdat as ORDER_DATE, a.NETWR, a.WAERK, a.VKORG " + _
            " from saprdp.vbak a inner join saprdp.tvakt b on a.auart=b.auart  " + _
            " where a.mandt='168' and b.mandt='168' and a.kunnr='" + Replace(CompanyId, "'", "''") + "' and b.spras='E' " + _
            " and a.auart in " + Util.GetInStrinFromCheckBoxList(cblDocTypes) + " and rownum<=500 " + _
            " and a.vkorg in " + VKORGInStr + " "

        Dim cult As New System.Globalization.CultureInfo("en-US")
        If Not String.IsNullOrEmpty(txtOrderDateFrom.Text) AndAlso Date.TryParseExact(txtOrderDateFrom.Text, calext1.Format, cult, System.Globalization.DateTimeStyles.None, Now) Then
            Dim OrderFromDate = Date.ParseExact(txtOrderDateFrom.Text, calext1.Format, cult)
            sql += " and a.erdat>='" + OrderFromDate.ToString("yyyyMMdd") + "' "
        End If
        If Not String.IsNullOrEmpty(txtOrderDateTo.Text) AndAlso Date.TryParseExact(txtOrderDateTo.Text, calext1.Format, cult, System.Globalization.DateTimeStyles.None, Now) Then
            Dim OrderToDate = Date.ParseExact(txtOrderDateTo.Text, calext1.Format, cult)
            sql += " and a.erdat<='" + OrderToDate.ToString("yyyyMMdd") + "' "
        End If

        sql += " order by a.erdat desc "
        'lbMsg.Text = sql : Return Nothing
        Dim dtMemo As New DataTable
        Dim aptSAP As New Oracle.DataAccess.Client.OracleDataAdapter(sql, ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
        aptSAP.Fill(dtMemo)
        aptSAP.SelectCommand.Connection.Close()
        Dim DocTypes = GetSAPDocTypeCache()
        Dim SAPCurrencyFactors As List(Of CurrencyFactor) = GetSAPCurrencyFactorCache()
        For Each r As DataRow In dtMemo.Rows
            Dim f = From q In SAPCurrencyFactors Where q.Currency = r.Item("WAERK")
            If f.Count > 0 Then
                r.Item("NETWR") = r.Item("NETWR") * Math.Pow(10, 2 - f.First.Factor)
            End If
            Dim m = From q In DocTypes Where q.AUART = r.Item("DOC_TYPE")
            r.Item("DOC_TYPE") = m.First.AUART_SPR
        Next

        Return dtMemo
    End Function

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not Page.IsPostBack Then
            If Not MailUtil.IsInRole("OPLeader.GBS.ACL") AndAlso Not MailUtil.IsInRole("OP.CFR.ACL") AndAlso Not MailUtil.IsInRole("MyAdvantech") Then
                Response.Redirect(Util.GetRuntimeSiteUrl() + "/home.aspx")
            End If

            Dim DocTypes = GetSAPDocTypeCache()
            For Each docType In DocTypes
                If docType.AUART_SPR.StartsWith("ZCR") Or docType.AUART_SPR = "CR" Or docType.AUART_SPR = "CRB" Then
                    cblDocTypes.Items.Add(New ListItem(docType.AUART_SPR + " (" + docType.Desc + ")", docType.AUART))
                    cblDocTypes.Items(cblDocTypes.Items.Count - 1).Selected = True
                End If
            Next
            txtOrderDateFrom.Text = Now.AddYears(-2).ToString(calext1.Format)
            txtOrderDateTo.Text = Now.ToString(calext2.Format)
        End If
    End Sub

    Function GetSAPDocTypeCache() As List(Of SAPDocType)
        Dim SAPDocTypes As List(Of SAPDocType) = Nothing
        Try
            SAPDocTypes = System.Web.HttpRuntime.Cache("SAP Doc Types")
        Catch ex As InvalidCastException
            SAPDocTypes = Nothing
        End Try
        If SAPDocTypes Is Nothing Then
            SAPDocTypes = New List(Of SAPDocType)
            Dim dtSAPDocTypes = OraDbUtil.dbGetDataTable("SAP_PRD", "select auart, bezei from saprdp.tvakt where mandt='168' and spras='E' order by auart")
            Dim Mapping = Get_SAP_TAUUM()
            For Each r As DataRow In dtSAPDocTypes.Rows
                Dim f1 As New SAPDocType()
                f1.AUART = Trim(r.Item("auart")) : f1.Desc = r.Item("bezei")
                Dim map = From q In Mapping Where q.AUART = r.Item("auart")
                If map.Count > 0 Then
                    f1.AUART_SPR = map.First.AUART_SPR
                Else
                    f1.AUART_SPR = f1.AUART
                End If
                SAPDocTypes.Add(f1)
            Next
            Cache.Add("SAP Doc Types", SAPDocTypes, Nothing, Now.AddDays(5), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        Return SAPDocTypes
    End Function

    Function GetSAPCurrencyFactorCache() As List(Of CurrencyFactor)
        Dim SAPCurrencyFactors As List(Of CurrencyFactor) = Nothing
        Try
            SAPCurrencyFactors = Cache("SAP Currency Factors")
        Catch ex As InvalidCastException
            SAPCurrencyFactors = Nothing
        End Try
        If SAPCurrencyFactors Is Nothing Then
            SAPCurrencyFactors = New List(Of CurrencyFactor)
            Dim dtSAPCurrencyFactor = dbUtil.dbGetDataTable("MY", "select CURRENCY, FACTOR from SAP_TCURX (nolock)")
            For Each r As DataRow In dtSAPCurrencyFactor.Rows
                Dim f1 As New CurrencyFactor()
                f1.Currency = Trim(r.Item("CURRENCY")) : f1.Factor = r.Item("FACTOR")
                SAPCurrencyFactors.Add(f1)
            Next
            Cache.Add("SAP Currency Factors", SAPCurrencyFactors, Nothing, Now.AddDays(5), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        Return SAPCurrencyFactors
    End Function

    Public Class CurrencyFactor
        Public Property Currency As String : Public Property Factor As Integer
    End Class

    Public Class SAPDocType
        Public Property AUART As String : Public Property AUART_SPR As String : Public Property Desc As String
    End Class

    Public Class AUART_AUART_SPR
        Public Property AUART As String : Public Property AUART_SPR As String
    End Class

    Public Shared Function Get_SAP_TAUUM() As List(Of AUART_AUART_SPR)
        Dim SAPRFCClient1 As New Read_Sap_Table.Read_Sap_Table
        Dim readData As New Read_Sap_Table.TAB512Table, queryOptions As New Read_Sap_Table.RFC_DB_OPTTable, fields As New Read_Sap_Table.RFC_DB_FLDTable
        Dim queryOption1 As New Read_Sap_Table.RFC_DB_OPT
        queryOption1.Text = "SPRAS EQ 'E'" : queryOptions.Add(queryOption1)
        Dim field1 As New Read_Sap_Table.RFC_DB_FLD : field1.Fieldname = "AUART" : fields.Add(field1)
        Dim field2 As New Read_Sap_Table.RFC_DB_FLD : field2.Fieldname = "AUART_SPR" : fields.Add(field2)

        SAPRFCClient1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
        SAPRFCClient1.Connection.Open()
        SAPRFCClient1.Rfc_Read_Table("|", "", "TAUUM", 0, 0, readData, fields, queryOptions)
        SAPRFCClient1.Connection.Close()

        Dim TAUUM_List As New List(Of AUART_AUART_SPR)
        For Each r As Read_Sap_Table.TAB512 In readData
            Dim dataFields() As String = Split(r.Wa, "|")
            Dim AUART_AUART_SPR1 As New AUART_AUART_SPR
            AUART_AUART_SPR1.AUART = dataFields(0).Trim() : AUART_AUART_SPR1.AUART_SPR = dataFields(1).Trim() : TAUUM_List.Add(AUART_AUART_SPR1)
        Next
        Return TAUUM_List
    End Function

    Public Shared Function AUART_To_AUART_SPR(ByRef TAUUM_List As List(Of AUART_AUART_SPR), AUART As String) As String
        Dim result = From q In TAUUM_List Where String.Equals(q.AUART, AUART, StringComparison.CurrentCultureIgnoreCase)
        If result.Count > 0 Then Return result.First.AUART_SPR
        Return AUART
    End Function

    Public Shared Function AUART_SPR_To_AUART(ByRef TAUUM_List As List(Of AUART_AUART_SPR), AUART_SPR As String) As String
        Dim result = From q In TAUUM_List Where String.Equals(q.AUART_SPR, AUART_SPR, StringComparison.CurrentCultureIgnoreCase)
        If result.Count > 0 Then Return result.First.AUART
        Return AUART_SPR
    End Function

    Protected Sub cblVKORG_SelectedIndexChanged(sender As Object, e As EventArgs)
        If Util.GetCheckedCountFromCheckBoxList(cblVKORG) > 0 Then StartQueryThreads()
    End Sub

    Protected Sub btnOrderDateRange_Click(sender As Object, e As EventArgs)
        StartQueryThreads()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
    <script type="text/javascript" src="<%=Util.GetRuntimeSiteUrl()%>/EC/jquery-latest.min.js"></script>
    <script type="text/javascript" src="<%=Util.GetRuntimeSiteUrl()%>/EC/jquery-ui.js"></script>
    <script type="text/javascript" src="<%=Util.GetRuntimeSiteUrl()%>/EC/json2.js"></script>
    <script type="text/javascript">

        $(document).ready(function () {
            resizePickWindow();
            $("#txtSearchCustName").keypress(
                function (event) {
                    if (event.keyCode == 13) { searchCompany(); event.preventDefault(); }
                }
            );
            $("#txtSearchCustId").keypress(
                function (event) {
                    if (event.keyCode == 13) { searchCompany(); event.preventDefault(); }
                }
            );

            $("#cbAllDocTypes").bind("click",
                    function () {
                        CheckAll('cbAllDocTypes', '<%=cblDocTypes.ClientID%>');
                    }
                );

        }
        );

        function busyMode(mode) {
            (mode == true) ? $("#ctl00_UpdateProgress2").css("visibility", "visible") : $("#ctl00_UpdateProgress2").css("visibility", "hidden");
            (mode == true) ? $("#imgLoading").css("style", "block") : $("#imgLoading").css("style", "none");
        }

        function resizePickWindow() {
            $("#divPickCust").width($(window).width() * 0.9).height($(window).height() * 0.9);
        }

        function showPickCust() {
            //$("#divPickCust").width($(window).width() * 0.9).height($(window).height() - 250);
            $("#divPickCust").dialog({ modal: true, width: $(window).width() * 0.9, height: $(window).height() * 0.9 });
        }

        function pickCustId(anchorObject) {
            var custId = $(anchorObject).text();
            $("#<%=txtCustomerID.ClientID%>").val(custId);
            $("#divPickCust").dialog('close');
        }

        function searchCompany() {
            $("#tbSearchedCompanyList").empty();
            var postData = JSON.stringify({ CompanyName: $("#txtSearchCustName").val(), CompanyId: $("#txtSearchCustId").val() });
            $.ajax(
                {
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/SearchSAPCompany", data: postData, contentType:
                    "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        var lines = $.parseJSON(retData.d); var tbhtml = "";
                        $.each(lines, function (idx, item) {
                            tbhtml += "<tr><td align='center'><a href='javascript:void(0);' onclick='pickCustId(this);' style='color:Navy'>" + item.CompanyId + "</a></td><td>" + item.CompanyName + "</td><td align='center'>" + item.SalesOrg + "</td></tr>";
                        }
                        );
                        $("#tbSearchedCompanyList").html(tbhtml);
                    }
                }
            );
        }

        var prm = Sys.WebForms.PageRequestManager.getInstance();
        if (prm != null) {
            prm.add_endRequest(enableQueryButton);
        }

        function enableQueryButton() {
            document.getElementById('<%=btnCheck.ClientId %>').disabled = false;
        }

        function CheckAll(AllId, CblId) {
            var IsChecked = $("#" + AllId).prop("checked"); var cbs = $("#" + CblId).find("input:checkbox");
            $.each(cbs,
                function (index, item) {
                    if ($(item).attr("disabled") != "disabled") {
                        $(item).prop("checked", IsChecked);
                    }
                }
            );
        }

        function showOrderDetail(anchorObject) {
            busyMode(true);
            var sono = $(anchorObject).text();
            $("#tbSODetail").empty();

            var postData = JSON.stringify({ SONO: sono });
            $.ajax(
                {
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetSODetailRecords", data: postData, contentType:
                    "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        var lines = $.parseJSON(retData.d); var tbhtml = "";
                        $.each(lines, function (idx, item) {
                            tbhtml += "<tr>" +
                                        "<td align='center'>"  + item.INVOICE_NO + "</td>" +
                                        "<td align='center'>" + item.LINE_NO + "</td>" +
                                        "<td align='center'>" + item.PART_NO + "</td>" +
                                        "<td align='center'>" + item.INVOICE_QTY + "</td>" +
                                        "<td align='center'>" + item.ORDER_QTY + "</td>" +
                                        "<td align='center'>" + item.TARGET_QTY + "</td>" +
                                        "<td align='center'>" + item.TOTAL_PRICE_CURR + "</td>" +
                                        "<td align='center'>" + item.UNIT_PRICE + "</td>" +
                                        "<td align='center'>" + item.ZPN0 + "</td>" +
                                        "<td align='center'>" + item.ZMIP + "</td>" +
                                        "<td align='center'>" + item.INVOICE_DATE + "</td>" +
                                      "</tr>";
                        }
                        );
                        $("#tbSODetail").html(tbhtml);
                        $("#divSODetail").dialog({ modal: true, width: $(window).width() * 0.9, height: $(window).height() * 0.9, title: sono });
                        busyMode(false);
                    }
                }
            );
            
        }

    </script>
    <asp:GridView runat="server" ID="gvtest" />
    <table width="100%">
        <tr style="height:50px">
            <td valign="top">&nbsp;<h2 style="color: navy">SAP Customer Credit History Inquiry</h2>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Panel runat="server" ID="PanelCheck" DefaultButton="btnCheck">
                    <table width="100%">
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <th align="left">Customer ID:</th>
                                        <td>
                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoext1" TargetControlID="txtcustomerID"
                                                MinimumPrefixLength="1" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetERPId" />
                                            <asp:TextBox runat="server" ID="txtCustomerID" Width="90px" />&nbsp;<a href="javascript:void(0);" onclick="showPickCust()">Pick</a>
                                        </td>
                                    </tr>
                                </table>
                            </td>

                        </tr>
                        <tr>                            
                            <td>
                                <table>
                                    <tr><th colspan="2" align="left">Doc. Types</th></tr>
                                    <tr>
                                        <td>All&nbsp;<input type="checkbox" id="cbAllDocTypes" title="all" checked="checked" /></td>
                                        <td>
                                            <asp:CheckBoxList runat="server" ID="cblDocTypes" RepeatColumns="4" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>     
                        <tr>
                            <td>
                                <asp:Button runat="server" ID="btnCheck" Text="Check" OnClick="btnCheck_Click" UseSubmitBehavior="false" OnClientClick="this.disabled=true;" />
                            </td>
                        </tr>                 
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upMsg" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnCheck" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upInfo" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:CheckBoxList runat="server" ID="cblVKORG" RepeatColumns="20" OnSelectedIndexChanged="cblVKORG_SelectedIndexChanged" AutoPostBack="true" />
                        <ajaxToolkit:TabContainer runat="server" ID="tabcon1" Visible="false">
                            <ajaxToolkit:TabPanel runat="server" ID="tabMemo" HeaderText="Memo Requests">
                                <ContentTemplate>
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <ajaxToolkit:CalendarExtender runat="server" ID="calext1" TargetControlID="txtOrderDateFrom" Format="yyyy/MM/dd" />
                                                <ajaxToolkit:CalendarExtender runat="server" ID="calext2" TargetControlID="txtOrderDateTo" Format="yyyy/MM/dd" />
                                                <table>
                                                    <tr>
                                                        <td>Order Date</td>
                                                        <th align="left">From:</th>
                                                        <td><asp:TextBox runat="server" ID="txtOrderDateFrom" Width="75px" /></td>
                                                        <th align="left">To:</th>
                                                        <td><asp:TextBox runat="server" ID="txtOrderDateTo" Width="75px" /></td>
                                                        <td><asp:Button runat="server" ID="btnOrderDateRange" Text="Refresh" OnClick="btnOrderDateRange_Click" /></td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:GridView runat="server" ID="gvCustMemo" Width="100%" AutoGenerateColumns="false">
                                                    <Columns>
                                                        <asp:TemplateField HeaderText="SO No." ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <a href="javascript:void(0);" onclick="showOrderDetail(this);"><%#Util.RemovePrecedingZeros(Eval("SO_NO"))%></a>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Doc. Type" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Eval("DOC_TYPE")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Order Date" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Global_Inc.SAPDate2StdDate(Eval("ORDER_DATE")).ToString("yyyy/MM/dd")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Amount" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Util.FormatMoney(Eval("NETWR"), Eval("WAERK"))%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Sales Org" ItemStyle-HorizontalAlign="Center">
                                                            <ItemTemplate>
                                                                <%#Eval("VKORG")%>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </td>
                                        </tr>
                                    </table>
                                </ContentTemplate>
                            </ajaxToolkit:TabPanel>
                            <ajaxToolkit:TabPanel runat="server" ID="tabCredit" HeaderText="Credit Limit">
                                <ContentTemplate>
                                    <asp:GridView runat="server" ID="gvCreditInfo" Width="100%" AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Org" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("SalesOrg")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Currency" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("Currency")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Credit Limit" ItemStyle-HorizontalAlign="Right">
                                                <ItemTemplate>
                                                    <%#Eval("CreditLimit")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Credit Exposure" ItemStyle-HorizontalAlign="Right">
                                                <ItemTemplate>
                                                    <%#Eval("CreditExposure")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Percentage" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#FormatNumber(Eval("Percentage"), 0)%>%
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </ajaxToolkit:TabPanel>
                        </ajaxToolkit:TabContainer>

                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnCheck" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
    <div id="divPickCust" style="overflow: auto; background-color: #E7E8EC; display: none">
        <table width="100%">
            <tr>
                <td>
                    <table>
                        <tr>
                            <th align="left">Company Name:</th>
                            <td>
                                <input type="text" id="txtSearchCustName" />
                            </td>
                            <th align="left">Company Id:</th>
                            <td>
                                <input type="text" id="txtSearchCustId" />
                            </td>
                            <td>
                                <input type="button" id="btnSearchCompany" value="Search" onclick="searchCompany()" /></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%">
                        <thead>
                            <tr>
                                <th>Company Id</th>
                                <th>Company Name</th>
                                <th>Sales Org</th>
                            </tr>
                        </thead>
                        <tbody id="tbSearchedCompanyList"></tbody>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    <div id="divSODetail" style="overflow: auto; background-color: #E7E8EC; display: none">
        <table width="100%">
            <thead>
                <tr>
                    <th>Invoice No.</th>
                    <th>Line No.</th>
                    <th>Part No.</th>
                    <th>Invoice Qty.</th>
                    <th>Order Qty.</th>
                    <th>Target Qty.</th>
                    <th>Total Price</th>
                    <th>Unit Price</th>
                    <th>ZPN0</th>
                    <th>ZMIP</th>
                    <th>Billing Date</th>
                </tr>
            </thead>
            <tbody id="tbSODetail"></tbody>
        </table>
    </div>
</asp:Content>
