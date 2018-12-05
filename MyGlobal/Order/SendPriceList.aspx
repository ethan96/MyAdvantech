<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    'Sub SendPriceList()
    '    Try
    '        Dim sapWs As New aeu_ebus_dev9000.PriceOnDemand
    '        sapWs.SendPriceListAsync(Session("company_id"), Session("org_id"), User.Identity.Name)
    '    Catch ex As Exception
    '    End Try
        
    'End Sub
   
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Dim t1 As New Threading.Thread(AddressOf SendPriceListClass)
        t1.Start() : t1.Join()
        Response.Write("Price List will be sent to you in few minutes. Back to <a href='../home.aspx'>MyAdvantech Home</a>")
        Response.End()
        Exit Sub
    End Sub
    
    Sub SendPriceListClass()
        Try
            SendPriceList(Session("company_id"), Session("org_id"), User.Identity.Name)
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString())
        End Try
    End Sub
    
    Public Sub SendPriceList(ByVal CompanyId As String, ByVal Org As String, ByVal request_email As String)
       
        Dim ft As DateTime = Now()
        Dim ms As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        'ms.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw", "Start PriceOnDemand for " + CompanyId + " " + Org + "," + request_email, "")
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Org = UCase(Org).Trim() : CompanyId = UCase(CompanyId).Trim()
        If Not request_email Like "*@*.*" Then
            'MsgBox("email is not in valid format")
            Exit Sub
        End If

        Dim cmd As New SqlClient.SqlCommand("select count(*) from sap_dimcompany where company_id='" + CompanyId + "' and org_id='" + Org + "'", conn)
        If conn.State <> ConnectionState.Open Then conn.Open()
        Dim c As Integer = cmd.ExecuteScalar()
        conn.Close()
        If c = 0 Then
            'Frank 2012/02/17
            'Do not use MsgBox in web method
            'MsgBox("companyid/orgid invalid") : Exit Sub
            Exit Sub
        End If

        'Frank 2012/05/08
        'Get price update in which year/quarter
        'If can not get data from eprice then exit sub
        Dim pYear As String = "2011", pQuarter As String = "3", _EPriceOrg As String = Org
        If Me.GetCurrentPriceYearQuarter(pYear, pQuarter, _EPriceOrg) = False Then
            Exit Sub
        End If

        'ICC 2015/6/26
        Dim SendGridCache As List(Of MySendGrid) = Cache("SendPriceCache")
        If SendGridCache Is Nothing Then
            SendGridCache = New List(Of MySendGrid)
            Cache.Add("SendPriceCache", SendGridCache, Nothing, Now.AddHours(1), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        
        For Each sg As MySendGrid In SendGridCache
            Dim myHour As Integer = DateDiff(DateInterval.Hour, DateTime.Now, sg.Dtime)
            'If sg.User.IndexOf("advantech.com") < 0 Then
            '    If sg.User.Equals(User.Identity.Name, System.StringComparison.OrdinalIgnoreCase) AndAlso myHour < 1 Then
            '        Exit Sub
            '    End If
            'Else
            '    If sg.Company.Equals(CompanyId, System.StringComparison.OrdinalIgnoreCase) AndAlso myHour < 1 Then
            '        Exit Sub
            '    End If
            'End If
            'IC 2015/7/8 Use exist function to check internal user.
            If Util.IsInternalUser2() Then
                If sg.Company.Equals(CompanyId, System.StringComparison.OrdinalIgnoreCase) AndAlso myHour < 1 Then
                    Exit Sub
                End If
            Else
                If sg.User.Equals(User.Identity.Name, System.StringComparison.OrdinalIgnoreCase) AndAlso myHour < 1 Then
                    Exit Sub
                End If
            End If
        Next
        
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Try
            eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            eup.Connection.Open()

            'Org = "EU10" : CompanyId = "EDDEVI07"
            Dim strProducts As String = _
                " select distinct top 30000 a.PART_NO, a.model_no," + _
                 " (select top 1 (CASE WHEN ISNULL(EXTENDED_DESC,'')='' THEN a.product_desc ELSE SAP_PRODUCT_EXT_DESC.extended_desc END) AS TT from SAP_PRODUCT_EXT_DESC " + _
                " where SAP_PRODUCT_EXT_DESC.PART_NO=a.PART_NO ) as product_desc, " + _
                    " case a.ROHS_FLAG when 1 then 'y' else 'n' end as RoHS, a.PRODUCT_GROUP, " + _
                " a.PRODUCT_LINE, -1 as Unit_Price,  " + _
                   " IsNull((select top 1 z.ABC_INDICATOR from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Org, 2) + "H1' ),'') as class, " + _
                   " IsNull((select top 1 z.COUNTRY_ORIGIN from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Org, 2) + "H1' ),'') as COUNTRY_ORIGIN, " + _
                   " IsNull((select top 1 z.FREIGHT_METHOD from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Org, 2) + "H1' ),'') as FREIGHT_METHOD, " + _
                   " a.NET_WEIGHT, a.GROSS_WEIGHT ,a.SIZE_DIMENSIONS,a.SOURCE_LOCATION ,'' AS CNCODE " + _
                   " from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO " + _
                   " inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO and b.ORG_ID=c.SALES_ORG  " + _
                   " where b.ORG_ID='" + Org + "' and c.PRODUCT_STATUS in ('A','N','H') and a.PRODUCT_HIERARCHY<>'EAPC-INNO-DPX' " + _
                   " and (a.material_group in ('PRODUCT','P-','968','968A','968EM','968MS','96CA','96CF','96FM','96HD','96KB', '96MM'," + _
                   " '96MP','96MT','96OD','96OT','96SS','96SW','98','170') or a.PART_NO like 'P-%') and a.part_no not like '#%' "
            Dim productDt As New DataTable, sapDt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(strProducts, conn)
            
            'Frank
            'increase command timout
            apt.SelectCommand.CommandTimeout = 1200
                
            apt.Fill(productDt)
            Dim tmpProductDt As DataTable = productDt.Clone()
            Dim copyProductDt As DataTable = productDt.Copy()

            For i As Integer = 0 To copyProductDt.Rows.Count - 1
                If tmpProductDt.Rows.Count >= 1000 Or i = copyProductDt.Rows.Count - 1 Then
                    Dim lFt As DateTime = Now
                    sapDt.Merge(Util.GetMultiEUPrice(CompanyId, Org, tmpProductDt))
                    Dim lTt As DateTime = Now
                    'Frank 2012/02/17
                    'Do not use Console.WriteLine in web method
                    'Console.WriteLine(DateDiff(DateInterval.Second, lFt, lTt).ToString())
                    tmpProductDt.Rows.Clear() : tmpProductDt.AcceptChanges()
                Else
                    tmpProductDt.ImportRow(copyProductDt.Rows(i))
                End If
            Next
            'Dim sapDt As DataTable = GetMultiEUPrice(CompanyId, Org, productDt)

            Dim retDt As DataTable = GetResultDt1(), _Part_No As String = String.Empty
            For Each prodRec As DataRow In productDt.Rows
                
                'Frank 2013/03/11
                'Dim priceRecords() As DataRow = sapDt.Select("Matnr='" + prodRec.Item("PART_NO") + "'")
                _Part_No = prodRec.Item("PART_NO").ToString
                If String.IsNullOrEmpty(_Part_No) = False Then _Part_No = _Part_No.Replace("'", "''")
                Dim priceRecords() As DataRow = sapDt.Select("Matnr='" + _Part_No + "'")
                
                If priceRecords.Length > 0 Then
                    Dim priceRecord As DataRow = priceRecords(0)
                    Dim resultRec As DataRow = retDt.NewRow()
                    With resultRec
                        .Item("Part No") = prodRec.Item("PART_NO") : .Item("Net Weight") = prodRec.Item("NET_WEIGHT")
                        .Item("Gross Weight") = prodRec.Item("GROSS_WEIGHT") : .Item("Product Line") = prodRec.Item("PRODUCT_LINE")
                        .Item("Currency") = priceRecord.Item("Waerk") : .Item("List Price") = priceRecord.Item("Kzwi1")
                        .Item("Unit Price") = priceRecord.Item("Netwr")
                        If priceRecord.Item("Kzwi1") < priceRecord.Item("Netwr") Then
                            .Item("List Price") = .Item("Unit Price")
                        End If
                        If .Item("List Price") > 0 Then
                            .Item("Disc") = FormatNumber((CDbl(.Item("List Price")) - CDbl(.Item("Unit Price"))) / CDbl(.Item("List Price")) * 100, 0) + "%"
                        End If
                        .Item("Product Desc") = prodRec.Item("product_desc") : .Item("ROHS") = ""
                        .Item("Class") = prodRec.Item("class") : .Item("Product Group") = prodRec.Item("PRODUCT_GROUP")
                        .Item("Version") = ""
                        .Item("CN Code") = prodRec.Item("CNCODE")
                        .Item("Country of Origin") = prodRec.Item("COUNTRY_ORIGIN")
                        .Item("Dimensions") = prodRec.Item("SIZE_DIMENSIONS")
                        .Item("Source Location") = prodRec.Item("SOURCE_LOCATION")
                        .Item("Freight Method") = prodRec.Item("FREIGHT_METHOD")
                        If prodRec.Item("model_no").ToString().Trim() <> "" Then .Item("MODEL_LINK") = "http://my.advantech.com/Product/Model_Detail.aspx?Model_No=" + prodRec.Item("model_no")
                    End With
                    retDt.Rows.Add(resultRec)
                Else
                   
                End If
            Next
            eup.Connection.Close()
            
            'Frank 2012/05/08
            'Generating sheet name
            Dim _SheetName As String = _EPriceOrg & "_" & pYear & "_Q" & pQuarter

            
            Dim xls As IO.MemoryStream = DataTable2ExcelStream(retDt, _SheetName)
            xls.Position = 0
            Dim msg As New System.Net.Mail.MailMessage("myadvantech@advantech.com", request_email, "Price List of " + CompanyId + "(" + _SheetName + ")", "")
            msg.Bcc.Add("ming.zhao@advantech.com.cn")
            msg.Bcc.Add("ic.chen@advantech.com.tw")
            msg.Attachments.Add(New System.Net.Mail.Attachment(xls, "PriceList_" + CompanyId + ".xls"))
            
            'ICC 2015/6/26 Change mail server to SendGrid, because ACL smtp server has maximum size restriction.
            'ms.Send(msg)
            Dim credentials As New Net.NetworkCredential(ConfigurationManager.AppSettings("SendGridID"), ConfigurationManager.AppSettings("SendGridKey"))
            Dim mySmtpClient As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SendGridServer"), Integer.Parse(ConfigurationManager.AppSettings("SendGridPort")))
            mySmtpClient.Credentials = credentials
            mySmtpClient.Send(msg)
            
            'ms.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw", "End PriceOnDemand for " + CompanyId + " " + Org + "," + request_email, "")
            'Dim tt As DateTime = Now()
            'Console.WriteLine("sent:" + DateDiff(DateInterval.Second, ft, tt).ToString())
            
            'ICC 2015/6/26 Update Cache data
            Dim exist As List(Of MySendGrid) = SendGridCache.Where(Function(sg) sg.User.Equals(User.Identity.Name, System.StringComparison.OrdinalIgnoreCase) AndAlso sg.Company.Equals(CompanyId, System.StringComparison.OrdinalIgnoreCase)).ToList()
            'ICC 2015/6/30 Add SyncLock
            SyncLock SendGridCache
                If exist.Count > 0 Then
                    For Each sg As MySendGrid In exist
                        SendGridCache.Remove(sg)
                    Next
                End If
                SendGridCache.Add(New MySendGrid(User.Identity.Name, CompanyId, DateTime.Now))
            End SyncLock
            
        Catch ex As Exception
            eup.Connection.Close()
            'Console.WriteLine(ex.ToString())
            Util.InsertMyErrLog(ex.ToString())
            ms.Send("myadvantech@advantech.com", "myadvantech@advantech.com", _
                    String.Format("Get Price List failed.erpid:{0},org:{1},email:{2}", CompanyId, Org, request_email), ex.ToString())
        End Try
        conn.Close()
    End Sub
    
    Public Function GetResultDt1() As DataTable
        Dim dt As New DataTable
        With dt.Columns
            .Add("Model No") : .Add("Part No") : .Add("Product Line") : .Add("Currency") : .Add("List Price", GetType(Double)) : .Add("Disc")
            .Add("Unit Price", GetType(Double)) : .Add("Product Desc") : .Add("ROHS")
            .Add("Net Weight", GetType(Double)) : .Add("Gross Weight", GetType(Double))
            .Add("Class") : .Add("Product Group") : .Add("Version")
            .Add("CN Code")
            .Add("Country of Origin") : .Add("Dimensions") : .Add("Source Location") : .Add("Freight Method")
            .Add("MODEL_LINK")
        End With
        Return dt
    End Function
    
    Function GetCurrentPriceYearQuarter(ByRef pYear As String, ByRef pQuarter As String, ByRef Org As String) As Boolean
        Dim pRBU As String = ""
        'Select Case UCase(Session("Org"))
        
        Org = Left(Org, 2)
        
        Select Case UCase(Org)
            Case "AH"
                pRBU = ""
            Case "AU"
                pRBU = "AAU"
            Case "BR"
                pRBU = "ABR"
            Case "CN"
                pRBU = "ABJ"
            Case "DL"
                pRBU = ""
            Case "EU"
                pRBU = "AESC"
            Case "IN"
                pRBU = "HQDC"
            Case "JP"
                pRBU = "AJP"
            Case "KR"
                pRBU = "AKR"
            Case "MY"
                pRBU = "AMY"
            Case "SG"
                pRBU = "ASG"
            Case "TL"
                pRBU = ""
            Case "TW"
                pRBU = "ATW"
            Case "US"
                pRBU = "AAC"
            Case Else
                pRBU = ""
                Return False
        End Select
        If pRBU <> "" Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("EPRICER", _
                                  " select pricec_dts_year, pricec_dts_quarter, org from Price_Control " + _
                                  " where org='" + pRBU + "' and GETDATE()>=pricec_start_date and GETDATE()<pricec_end_date+1")
            If dt.Rows.Count = 1 Then
                pYear = dt.Rows(0).Item("pricec_dts_year").ToString()
                pQuarter = dt.Rows(0).Item("pricec_dts_quarter").ToString()
                Org = pRBU
                Return True
            End If
        End If
        Return False
    End Function
    
    Public Function DataTable2ExcelStream(ByVal dt As DataTable, Optional ByVal sheetname As String = "") As IO.MemoryStream
        Dim license As Aspose.Cells.License = New Aspose.Cells.License()
        Dim strFPath As String = Server.MapPath("~/Files/Aspose.Total.lic")
        license.SetLicense(strFPath)
        Try
            Dim wb As New Aspose.Cells.Workbook
            wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
            
            'Frank 2012/05/08
            'If inputed the sheet name then set inputed sheet name for Worksheets(0)
            If Not String.IsNullOrEmpty(sheetname) Then
                wb.Worksheets(0).Name = sheetname
            End If
            
            For i As Integer = 0 To dt.Columns.Count - 1
                wb.Worksheets(0).Cells(0, i).PutValue(dt.Columns(i).ColumnName)
            Next
            For i As Integer = 0 To dt.Rows.Count - 1
                For j As Integer = 0 To dt.Columns.Count - 1
                    If dt.Rows(i).Item(j).ToString.StartsWith("=") Then
                        wb.Worksheets(0).Cells(i + 1, j).Formula = dt.Rows(i).Item(j).ToString()
                    Else
                        wb.Worksheets(0).Cells(i + 1, j).PutValue(dt.Rows(i).Item(j))
                    End If
                Next
            Next
            Return wb.SaveToStream()
            'wb.Save(path)
        Catch ex As Exception
            Return Nothing
        End Try
    End Function
    
    Public Class MySendGrid
        Private userID As String
        Public Property User() As String
            Get
                Return userID
            End Get
            Set(ByVal value As String)
                userID = value
            End Set
        End Property

        Private companyID As String
        Public Property Company() As String
            Get
                Return companyID
            End Get
            Set(ByVal value As String)
                companyID = value
            End Set
        End Property

        Private downloadtime As DateTime
        Public Property Dtime() As DateTime
            Get
                Return downloadtime
            End Get
            Set(ByVal value As DateTime)
                downloadtime = value
            End Set
        End Property
        
        Public Sub New(ByVal ID As String, ByVal comID As String, ByVal dt As DateTime)
            Me.User = ID
            Me.Company = comID
            Me.Dtime = dt
        End Sub
        Public Sub New()
            
        End Sub
    End Class
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
