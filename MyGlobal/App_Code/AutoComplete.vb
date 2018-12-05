Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://my.advantech.eu/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<System.Web.Script.Services.ScriptService()> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class AutoComplete
    Inherits System.Web.Services.WebService

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetERPId(ByVal prefixText As String, ByVal count As Integer) As String()
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Exit Function
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt = dbUtil.dbGetDataTable("RFM", String.Format("select distinct top 10 company_id from sap_dimcompany (nolock) where company_id like '{0}%' and company_type in ('partner','Z001')", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetAdminERPId(ByVal prefixText As String, ByVal count As Integer) As String()
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Exit Function
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", MYSIEBELDAL.GetAdminCompany.Replace("top 50", "top 10") + " and company_id like '" + prefixText + "%'")
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetPhaseOutNo(ByVal prefixText As String, ByVal count As Integer) As String()
        'If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Exit Function
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("select distinct top 10 CATEGORY_ID from dbo.CBOM_CATALOG_CATEGORY where CATEGORY_ID like '{0}%' AND CATEGORY_TYPE='Component' order by CATEGORY_ID desc", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetModelNo(ByVal prefixText As String, ByVal count As Integer) As String()
        'If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Exit Function
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format("select distinct BISMT from SAPRDP.MARA where BISMT like '%{0}%' and rownum<=10", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = Global_Inc.DeleteZeroOfStr(dt.Rows(i).Item(0))
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetSAPPN(ByVal prefixText As String, ByVal count As Integer) As String()
        'If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Exit Function
        prefixText = UCase(Replace(Trim(prefixText), "'", "''"))
        prefixText = UCase(Replace(Trim(prefixText), "*", "%"))
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format("select distinct MATNR from SAPRDP.MARA where MATNR like '%{0}%' and rownum<=10", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = Global_Inc.DeleteZeroOfStr(dt.Rows(i).Item(0))
            Next
            Return str
        End If
        Return Nothing
    End Function
    <WebMethod(enablesession:=True)> _
<Web.Script.Services.ScriptMethod()> _
    Public Function GetSAPPNForABR(ByVal prefixText As String, ByVal count As Integer) As String()
        'If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Exit Function
        prefixText = UCase(Replace(Trim(prefixText), "'", "''"))
        prefixText = UCase(Replace(Trim(prefixText), "*", "%"))
        'Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format("select distinct MATNR from SAPRDP.MARA where MATNR like '{0}%' and rownum<=10", prefixText))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 10 PART_NO  from  dbo.SAP_PRODUCT_STATUS where PART_NO like '{0}%' and SALES_ORG ='BR01'", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetRMAOrderNo(ByVal prefixText As String, ByVal count As Integer) As String()
        If HttpContext.Current.Session Is Nothing OrElse HttpContext.Current.Session("user_id") = "" Then Exit Function
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MYPRD", _
        String.Format("select RMA_NO=Order_NO+'-'+Cast(Item_No as varchar(4)) from RMA_My_Request_OrderList where Bill_ID='{0}' and Order_NO+'-'+Cast(Item_No as varchar(4)) like '%{1}%'", HttpContext.Current.Session("company_id"), prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <Services.WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetSearchSuggestionKeys(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As DataTable = Nothing
        If prefixText.EndsWith(" ") Then
            Dim ps() As String = Split(prefixText, " ")
            Dim arr As New ArrayList
            If ps.Length > 1 Then
                If ps.Length >= 7 Then Return New String() {prefixText}
                For Each s As String In ps
                    arr.Add("'" + s.Trim().Replace("'", "''").Replace("*", "%") + "'")
                Next
            Else
                Return New String() {prefixText}
            End If

            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 10 display_term  "))
                .AppendLine(String.Format(" from PRODUCT_FULLTEXT_KEYWORDS  "))
                .AppendLine(String.Format(" where display_term not in ('END OF FILE','br','li') and document_id in "))
                .AppendLine(String.Format(" ( "))
                .AppendLine(String.Format(" 	select document_id "))
                .AppendLine(String.Format(" 	from PRODUCT_FULLTEXT_KEYWORDS "))
                .AppendLine(String.Format(" 	where display_term=N'{0}' ", ps(ps.Length - 2)))
                .AppendLine(String.Format(" ) and display_term not in ({0}) ", String.Join(",", arr.ToArray())))
                .AppendLine(String.Format(" group by display_term order by COUNT(distinct document_id) desc "))
            End With
            dt = dbUtil.dbGetDataTable("FORUM", sb.ToString())
            For Each r As DataRow In dt.Rows
                r.Item("display_term") = prefixText + " " + r.Item("display_term")
            Next
        Else
            prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
            dt = dbUtil.dbGetDataTable("MY", String.Format("select top 10 display_term from PRODUCT_FULLTEXT_KEYWORDS_FREQUENCY where display_term like N'%{0}%' order by frequency desc", prefixText))
        End If
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return New String() {prefixText}
    End Function

    <WebMethod(enablesession:=True)> _
   <Web.Script.Services.ScriptMethod()> _
    Public Function GetTaxJuri(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format("select NVL((CASE WHEN XSKFN='X' THEN '' ELSE TXJCD END),' ') AS TAXJ from saprdp.TTXJ WHERE TXJCD LIKE '{0}%' and MANDT=168 and rownum<=10", prefixText.ToUpper))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                If Not IsDBNull(dt.Rows(i).Item(0)) Then
                    str(i) = dt.Rows(i).Item(0)
                End If
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetPartNo(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As DataTable = Nothing
        If HttpContext.Current.Session Is Nothing Then
            Return Nothing
        End If
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct top 10 A.part_no from  dbo.SAP_PRODUCT A INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE B ON A.PART_NO=B.PART_NO  ")
        sql.AppendFormat(" where A.PART_NO like '{0}%' ", prefixText)
        sql.AppendFormat(" and  B.PRODUCT_STATUS in {0}", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        sql.AppendFormat(" AND B.SALES_ORG ='{0}' ", HttpContext.Current.Session("org_id"))
        If Not Util.IsInternalUser2() Then
            sql.AppendLine(" and A.material_group not in ('T','ODM') ")
        End If
        sql.AppendLine(" order by part_no ")
        'dt = dbUtil.dbGetDataTable("RFM", String.Format( _
        '"select distinct top 10 part_no from sap_product where part_no like '{0}%' and material_group not in ('T','ODM') and status in ('A','N') order by part_no desc", prefixText))
        dt = dbUtil.dbGetDataTable("B2B", sql.ToString())
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetSO(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("select top 20 Order_No from Order_Master where Order_No like '{0}%' and Soldto_ID = '{1}' order by Order_Date desc", prefixText, HttpContext.Current.Session("company_id")))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetDN(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("select distinct top 20 referencedoc from factShipment where referencedoc like '%{0}%' and CustomerID = '{1}' order by referencedoc desc", prefixText, HttpContext.Current.Session("company_id")))

        If dt.Rows.Count > 0 Then

            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetPO(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("select top 20 PO_NO from Order_Master where PO_NO like '{0}%' and Soldto_ID = '{1}' order by Order_Date desc", prefixText, HttpContext.Current.Session("company_id")))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Function GetInvoiceNo(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", String.Format("select distinct top 20 InvoiceNo from factShipment where InvoiceNo like '00{0}%' and CustomerID = '{1}' order by InvoiceNo desc", prefixText, HttpContext.Current.Session("company_id")))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    <WebMethod(enablesession:=True)>
    <Web.Script.Services.ScriptMethod()>
    Public Function GetEmployeeEmail(ByVal prefixText As String, ByVal count As Integer) As String()
        Dim dt As DataTable = Nothing
        If HttpContext.Current.Session Is Nothing Then
            Return Nothing
        End If
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct  top 10 EMAIL   from  SAP_EMPLOYEE  ")
        sql.AppendFormat(" where EMAIL like '{0}%' ", prefixText)
        sql.AppendLine(" order by EMAIL ")
        dt = dbUtil.dbGetDataTable("B2B", sql.ToString())
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <WebMethod(EnableSession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputSAPSoldToId()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()
        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()

        Dim _org_id As String = HttpContext.Current.Session("org_id")

        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select top 10 company_id, company_name, org_id from sap_dimcompany a (nolock) ")
        sql.AppendLine(String.Format(" where a.company_type='Z001' and (company_id like '{0}%' or company_name like '%{0}%') ", keyword))

        'Frank 20180312, limit accout result by sales org for ADLoG first, TBD for other orgs
        If _org_id.Equals("EU80", StringComparison.InvariantCultureIgnoreCase) Then
            sql.AppendLine(" and a.ORG_ID='" & _org_id & "' ")
        End If

        sql.AppendLine(" order by company_id ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString())
        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item("company_id"), dt.Rows(i).Item("company_name") + " (" + dt.Rows(i).Item("org_id") + ")", ""))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function

    <WebMethod(EnableSession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputSalesId()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()
        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()

        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select top 10 sales_code, full_name, pers_area from sap_employee a (nolock) ")
        sql.AppendLine(String.Format(" where (sales_code like '{0}%' or full_name like N'%{0}%')  ", keyword))
        sql.AppendLine(" order by sales_code ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString())
        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item("sales_code"), dt.Rows(i).Item("full_name") + " (" + dt.Rows(i).Item("pers_area") + ")", ""))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function


    <WebMethod(enablesession:=True)> _
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)> _
    Public Function GetTokenInputPartNo()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()

        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()

        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct top 10 A.PART_NO, A.PRODUCT_DESC from dbo.SAP_PRODUCT A (nolock) INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE B (nolock) ON A.PART_NO=B.PART_NO  ")
        sql.AppendFormat(" where A.PART_NO like '{0}%' ", keyword)
        sql.AppendFormat(" and  B.PRODUCT_STATUS in {0}", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        sql.AppendFormat(" AND B.SALES_ORG ='{0}' ", HttpContext.Current.Session("org_id"))
        If Not Util.IsInternalUser2() AndAlso Not HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN") Then
            sql.AppendLine(" and A.material_group not in ('T','ODM') ")
        End If
        sql.AppendLine(" order by part_no ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql.ToString())
        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item(1), dt.Rows(i).Item(0), ""))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function

    <WebMethod(enablesession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputBTOSPartNo()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()

        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()

        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct top 10 A.PART_NO, A.PRODUCT_DESC from dbo.SAP_PRODUCT A INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE B ON A.PART_NO=B.PART_NO  ")
        sql.AppendFormat(" where A.PART_NO like '%-BTO' AND A.PART_NO like '{0}%' ", keyword)
        sql.AppendFormat(" and  B.PRODUCT_STATUS in {0}", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        sql.AppendFormat(" AND B.SALES_ORG ='{0}' ", HttpContext.Current.Session("org_id"))
        If Not Util.IsInternalUser2() Then
            sql.AppendLine(" and A.material_group not in ('T','ODM') ")
        End If
        sql.AppendLine(" order by part_no ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql.ToString())
        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item(1), dt.Rows(i).Item(0), ""))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function

    <WebMethod(EnableSession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputPartNoWithLegacePN()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()
        Dim erpid As String = Session("company_id").ToString
        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()
        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%").ToUpper

        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct top 4 a.PART_NO, a.PRODUCT_DESC, ISNULL(C.MATNR_P,'') as LegacyPN ")
        sql.AppendLine(" From dbo.SAP_PRODUCT a (nolock) INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE b (nolock) ON a.PART_NO=b.PART_NO ")
        sql.AppendLine(" left join SAP_PRODUCT_AFFILIATE_MAPPING c (nolock) on a.PART_NO = c.MATNR ")
        sql.AppendFormat(" where a.PART_NO Like '%{0}%' ", keyword)
        sql.AppendFormat(" and  b.PRODUCT_STATUS in {0}", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        sql.AppendFormat(" AND b.SALES_ORG ='{0}' ", HttpContext.Current.Session("org_id"))
        If Not Util.IsInternalUser2() Then
            sql.AppendLine(" and a.material_group not in ('T','ODM') ")
        End If
        sql.AppendLine(" union ")
        sql.AppendLine(" select distinct top 2 a.PART_NO, a.PRODUCT_DESC, ISNULL(C.MATNR_P,'') as LegacyPN ")
        sql.AppendLine(" From dbo.SAP_PRODUCT a (nolock) INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE b (nolock) ON a.PART_NO=a.PART_NO ")
        sql.AppendLine(" left join SAP_PRODUCT_AFFILIATE_MAPPING c (nolock) on a.PART_NO = c.MATNR ")
        sql.AppendFormat(" where c.MATNR_P Like '%{0}%' ", keyword)
        sql.AppendFormat(" and  b.PRODUCT_STATUS in {0}", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        sql.AppendFormat(" AND b.SALES_ORG ='{0}' ", HttpContext.Current.Session("org_id"))
        If Not Util.IsInternalUser2() Then
            sql.AppendLine(" and a.material_group not in ('T','ODM') ")
        End If
        sql.AppendLine(" order by part_no ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql.ToString())

        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item(1), dt.Rows(i).Item(0), dt.Rows(i).Item(2)))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function

    <WebMethod(enablesession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputPartNoForBB()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()
        Dim dt As DataTable = Nothing
        Dim erpid As String = Session("company_id").ToString

        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()
        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%").ToUpper

        'Get Advantech PN, B+B PN and Parts desc from SAP.
        'Dim str As String = "select a.MATNR as PART_NO, b.MAKTG as PRODUCT_DESC , a.KDMAT as BBPN from saprdp.knmt a left join saprdp.makt b " + _
        '                    " on a.matnr = b.matnr where a.kunnr = '" + erpid + "' and a.kdmat like '" + keyword + "%' and b.spras = 'E' order by a.kdmat"
        Dim str As String = "select distinct a.MATNR as PART_NO, b.MAKTG as PRODUCT_DESC , a.KDMAT as BBPN from saprdp.knmt a left join saprdp.makt b " +
                            " on a.matnr = b.matnr where a.kunnr in ('ADVBBUS','ADVBBIR') and a.kdmat like '" + keyword + "%' and b.spras = 'E' order by a.kdmat"
        dt = OraDbUtil.dbGetDataTable("SAP_PRD", str)

        'Get Standard Parts' info from ACLSTNR12.
        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct top 10 A.PART_NO, A.PRODUCT_DESC, '' as BBPN from dbo.SAP_PRODUCT A (nolock) INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE B (nolock) ON A.PART_NO=B.PART_NO  ")
        sql.AppendFormat(" where A.PART_NO like '{0}%' ", keyword)
        sql.AppendFormat(" and  B.PRODUCT_STATUS in {0}", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        sql.AppendFormat(" AND B.SALES_ORG ='{0}' ", HttpContext.Current.Session("org_id"))
        If Not Util.IsInternalUser2() Then
            sql.AppendLine(" and A.material_group not in ('T','ODM') ")
        End If
        sql.AppendLine(" order by part_no ")
        Dim standard_dt As DataTable = dbUtil.dbGetDataTable("B2B", sql.ToString())

        'Merge two table to one
        dt.Merge(standard_dt)

        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item(1), dt.Rows(i).Item(0), dt.Rows(i).Item(2)))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function

    <WebMethod(EnableSession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputCBOMPartNo()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()

        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()

        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%")
        Dim sql As New StringBuilder
        sql.AppendLine(" select distinct top 10 A.PART_NO, A.PRODUCT_DESC from dbo.SAP_PRODUCT A (nolock) INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE B (nolock) ON A.PART_NO=B.PART_NO  ")
        sql.AppendFormat(" where A.PART_NO like '{0}%' ", keyword)
        sql.AppendFormat(" and  B.PRODUCT_STATUS in {0} ", ConfigurationManager.AppSettings("CanOrderProdStatus"))
        If HttpContext.Current.Session("org_id").ToString.StartsWith("CN") Then
            sql.AppendFormat(" AND B.SALES_ORG in ('CN10','CN30') ")
            sql.AppendFormat(" AND B.PRODUCT_STATUS <> 'O' ")
            sql.AppendFormat(" AND ((select count(*) from SAP_PRODUCT_STATUS (nolock) where PRODUCT_STATUS = 'O' and SALES_ORG in ('CN10','CN30') and PART_NO like '{0}' )  < 1) ", keyword)
        Else
            sql.AppendFormat(" AND B.SALES_ORG ='{0}' ", HttpContext.Current.Session("org_id"))
        End If
        sql.AppendLine(" order by part_no ")
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", sql.ToString())
        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item(1), dt.Rows(i).Item(0), ""))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function

    <WebMethod(EnableSession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputCBOMBTOS()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()

        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()

        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%").ToUpper

        Dim orgid As String = HttpContext.Current.Session("org_id").ToString.Substring(0, 2).ToUpper
        If Session("org_id_cbom") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Session("org_id_cbom").ToString) Then
            orgid = Session("org_id_cbom").ToString.ToUpper.Substring(0, 2)
        End If
        Dim str As String = "DECLARE @Child hierarchyid " +
                         " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                         " WHERE ID = '" + orgid + "_BTOS' " +
                         " SELECT ID, CATEGORY_ID, CATEGORY_NOTE FROM CBOM_CATALOG_CATEGORY_V2 " +
                         " WHERE HIE_ID.GetAncestor(1) = @Child AND CATEGORY_ID LIKE '" + keyword + "%' " +
                         " Order by CATEGORY_ID "
        Dim dt As DataTable = dbUtil.dbGetDataTable("CBOMV2", str)

        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item(0), dt.Rows(i).Item(1), dt.Rows(i).Item(2)))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list))
        End If
        HttpContext.Current.Response.End()
    End Function

    <WebMethod(EnableSession:=True)>
    <Web.Script.Services.ScriptMethod(ResponseFormat:=Script.Services.ResponseFormat.Json)>
    Public Function GetTokenInputCompanyContact()
        If HttpContext.Current.Request.IsAuthenticated = False OrElse HttpContext.Current.Session Is Nothing Then HttpContext.Current.Response.End()

        Dim keyword = String.Empty
        If Not String.IsNullOrEmpty(Context.Request("q")) Then keyword = Context.Request("q").ToString().Trim()

        keyword = Replace(Replace(Trim(keyword), "'", "''"), "*", "%")
        If Not String.IsNullOrEmpty(keyword) Then keyword = keyword.ToUpper
        'Ryan 20180619 Comment out join saprdp.TPFKT, unnecessary.
        Dim sql As New StringBuilder
        sql.AppendFormat(" select DISTINCT upper(b.namev) as namev, upper(b.name1) as name1, b.abtnr, d.vtext as department, b.pafkt, c.smtp_addr ")
        'sql.AppendFormat(" , e.vtext ")
        sql.AppendFormat(" from saprdp.kna1 a inner join saprdp.knvk b on a.kunnr=b.kunnr ")
        sql.AppendFormat(" inner join saprdp.adr6 c on a.adrnr=c.addrnumber and b.prsnr=c.persnumber ")
        sql.AppendFormat(" inner join saprdp.tsabt d on b.abtnr=d.abtnr ")
        'sql.AppendFormat(" inner join saprdp.TPFKT e on b.pafkt=e.pafkt ")
        sql.AppendFormat(" where a.kunnr = '{0}' and d.spras='E' ", Session("company_id").ToString)
        'sql.AppendFormat(" and e.spras='E' and e.mandt='168' ")
        sql.AppendFormat(" and a.mandt='168' and b.mandt='168' and d.mandt='168' ")
        sql.AppendFormat(" and upper(c.smtp_addr) like '{0}%' ", keyword)
        'sql.AppendFormat(" order by b.namev, b.parnr ")

        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sql.ToString)
        If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
            Dim list As New List(Of TokeInputPartNo)
            For i As Integer = 0 To dt.Rows.Count - 1
                list.Add(New TokeInputPartNo(dt.Rows(i).Item("smtp_addr"), dt.Rows(i).Item("smtp_addr") + " (" + dt.Rows(i).Item("namev") + " " + dt.Rows(i).Item("name1") + ")", ""))
            Next
            HttpContext.Current.Response.Clear() : HttpContext.Current.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(list.OrderBy(Function(p) p.id)))
        End If
        HttpContext.Current.Response.End()
    End Function

    Public Sub New()

    End Sub
End Class

Public Class TokeInputPartNo
    Private myid As String
    Public Property id As String
        Get
            Return myid
        End Get
        Set(ByVal value As String)
            myid = value
        End Set
    End Property

    Private myname As String
    Public Property name As String
        Get
            Return myname
        End Get
        Set(ByVal value As String)
            myname = value
        End Set
    End Property

    Private mycpn As String
    Public Property cpn As String
        Get
            Return mycpn
        End Get
        Set(ByVal value As String)
            mycpn = value
        End Set
    End Property

    Sub New()

    End Sub

    Sub New(ByVal partno As String, ByVal desc As String, ByVal cpn As String)
        Me.id = partno
        Me.name = desc
        Me.cpn = cpn
    End Sub
End Class
