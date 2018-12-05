<%@ Page Title="MyAdvantech - Download Price List" Language="VB" MasterPageFile="~/Includes/MyMaster.master"
    Async="true" EnableEventValidation="false" %>

<%@ Import Namespace="ICSharpCode.SharpZipLib.Zip" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="ICSharpCode.SharpZipLib.Core" %>
<%@ Import Namespace="System.Web.Services" %>
<script runat="server">

    Enum DownloadFormat
        Excel = 0
        Rar = 1
        Zip = 2
    End Enum
    
    Enum DownloadMethod
        Email = 0
        Download = 1
    End Enum
    Dim eup As Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY = Nothing

    <WebMethod()> _
    Public Function GetPriceList(ByVal CompanyId As String, ByVal Org As String, ByVal DownloadTargetPG As String) As DataTable
        
        Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        Org = UCase(Org).Trim() : CompanyId = UCase(CompanyId).Trim()

        Dim cmd As New SqlClient.SqlCommand("select count(*) from sap_dimcompany where company_id='" + CompanyId + "' and org_id='" + Org + "'", conn)
        If conn.State <> ConnectionState.Open Then conn.Open()
        Dim c As Integer = cmd.ExecuteScalar()
        conn.Close()
        
        If c = 0 Then
            Throw New Exception("CompanyID " & CompanyId & " is not exist.")
        End If

        eup = New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()

        'Org = "EU10" : CompanyId = "EDDEVI07"
        Dim strProducts As String = _
            " select distinct top 30000 a.PART_NO, a.model_no, a.product_desc, case a.ROHS_FLAG when 1 then 'y' else 'n' end as RoHS, a.PRODUCT_GROUP, " + _
            " a.PRODUCT_LINE, -1 as Unit_Price,  " + _
               " IsNull((select top 1 z.ABC_INDICATOR from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Org, 2) + "H1' ),'') as class, " + _
               " a.NET_WEIGHT, a.GROSS_WEIGHT " + _
               " from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO " + _
               " inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO and b.ORG_ID=c.SALES_ORG  " + _
               " where b.ORG_ID='" + Org + "' and c.PRODUCT_STATUS in ('A','N','H','M1') and a.PRODUCT_HIERARCHY<>'EAPC-INNO-DPX' " + _
               " and (a.material_group in ('PRODUCT','P-','968','968A','968EM','968MS','96CA','96CF','96FM','96HD','96KB', '96MM'," + _
               " '96MP','96MT','96OD','96OT','96SS','96SW','98','170') or a.PART_NO like 'P-%') and a.part_no not like '#%' "

        'Frank 2012/02/23:If user need query sub set product by SAP_PRODUCT.egroup.
        If DownloadTargetPG <> "" AndAlso DownloadTargetPG.Equals("All", StringComparison.InvariantCultureIgnoreCase) = False Then
            strProducts &= " and a.egroup='" & DownloadTargetPG & "'"
        End If
            
        Dim productDt As New DataTable, sapDt As New DataTable
        Dim apt As New SqlClient.SqlDataAdapter(strProducts, conn)
            
        'Frank
        'Setting CommandTimeout by 2 mins
        apt.SelectCommand.CommandTimeout = 120
                
        apt.Fill(productDt)
        Dim tmpProductDt As DataTable = productDt.Clone()
        Dim copyProductDt As DataTable = productDt.Copy()

        Dim _testdt As DataTable = Nothing
            
        For i As Integer = 0 To copyProductDt.Rows.Count - 1
            If tmpProductDt.Rows.Count >= 1000 Or i = copyProductDt.Rows.Count - 1 Then
                Dim lFt As DateTime = Now
                    
                    
                sapDt.Merge(GetMultiEUPrice(CompanyId, Org, tmpProductDt))
                    
                ' The performance of GetPrice is not good enought. so stop changing the code
                '_testdt = GetPriceByMYSAPDAL(CompanyId, CompanyId, Org, tmpProductDt)
                    
                Dim lTt As DateTime = Now

                tmpProductDt.Rows.Clear() : tmpProductDt.AcceptChanges()

            Else

                tmpProductDt.ImportRow(copyProductDt.Rows(i))

            End If
        Next

        'Get return datatable with no data
        Dim retDt As DataTable = GetResultDt()
        retDt.TableName = "PriceList"
        
        'Fill data into return datatable
        For Each prodRec As DataRow In productDt.Rows
            Dim priceRecords() As DataRow = sapDt.Select("Matnr='" + prodRec.Item("PART_NO") + "'")
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
                    If prodRec.Item("model_no").ToString().Trim() <> "" Then .Item("MODEL_LINK") = "http://my.advantech.com/Product/Model_Detail.aspx?Model_No=" + prodRec.Item("model_no")
                End With
                retDt.Rows.Add(resultRec)
            Else
                   
            End If
        Next
        eup.Connection.Close()
        
        Return retDt
        
    End Function

    
    
    <WebMethod()> _
    Public Sub SendPriceList(ByVal CompanyId As String, ByVal Org As String, ByVal request_email As String, ByVal DownloadFormat As DownloadFormat, ByVal DownloadMethod As DownloadMethod, ByVal DownloadTargetPG As String)
       
        Dim ft As DateTime = Now()
        Dim ms As New System.Net.Mail.SmtpClient("172.21.34.21")

        If Not request_email Like "*@*.*" Then
            Exit Sub
        End If

        Try

            'Getting price list as datatable
            Dim retDt As DataTable = Me.GetPriceList(CompanyId, Org, DownloadTargetPG)
            
            'Setting outpur file name
            Dim _XLSFileName As String = "PriceList_" + CompanyId + ".xls"
            Dim _ZIPFileName As String = "PriceList_" + CompanyId + ".zip"
            
            'Base on both the DownloadMethod and DownloadFormat, to decide how to output price data to user.
            Select Case DownloadMethod
                Case DownloadMethod.Email
                    '===Get price list file by email===

                    'Price datatable transforms to memorystream
                    Dim xls As IO.MemoryStream = DataTable2ExcelStream(retDt)
                    xls.Position = 0

                    Dim msg As New System.Net.Mail.MailMessage("myadvantech@advantech.com", request_email, "Price List of " + CompanyId, "")
                    msg.Bcc.Add("frank.chung@advantech.com.tw")

                    
                    Select Case DownloadFormat
                        Case DownloadFormat.Zip
                            '===Get price list as excel file with Zip compress by email===
                            'Price memorystream compress to zip streaming
                            Dim _mstm As MemoryStream = Me.CreateToMemoryStream(xls, _XLSFileName)
                            msg.Attachments.Add(New System.Net.Mail.Attachment(_mstm, _ZIPFileName))

                        Case DownloadFormat.Excel
                            '===Get price list as excel file with no compress by email===
                            msg.Attachments.Add(New System.Net.Mail.Attachment(xls, _XLSFileName))

                    End Select

                    'Sending email
                    ms.Send(msg)

                    
                Case Else
                    '===Download price list file===

                    Select Case DownloadFormat
                        Case DownloadFormat.Zip
                            '===Download price list as excel file with Zip compress===
                            'Price datatable transforms to memorystream
                            Dim xls As IO.MemoryStream = DataTable2ExcelStream(retDt)
                            xls.Position = 0
                            'Price memorystream compress to zip streaming
                            Dim _mstm As MemoryStream = Me.CreateToMemoryStream(xls, _XLSFileName)
                            With HttpContext.Current.Response
                                .Clear()
                                '.ContentType = "application/zip"
                                .ContentType = "application/octet-stream"
                                .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", _ZIPFileName))
                                .BinaryWrite(_mstm.ToArray)
                            End With
                            
                        Case DownloadFormat.Excel
                            '===Download price list as excel file with no compress===
                            Util.DataTable2ExcelDownload(retDt, _XLSFileName)
                            
                    End Select
                    
            End Select
            

            Dim tt As DateTime = Now()

        Catch ex As Exception
            eup.Connection.Close()
            ms.Send("myadvantech@advantech.com", "tc.chen@advantech.com.tw", _
                    String.Format("Get Price List failed.erpid:{0},org:{1},email:{2}", CompanyId, Org, request_email), ex.ToString())
        End Try
        'conn.Close()
    End Sub
    
    
    Public Function CreateToMemoryStream(memStreamIn As MemoryStream, zipEntryName As String) As MemoryStream

        Dim outputMemStream As New MemoryStream()
        Dim zipStream As New ZipOutputStream(outputMemStream)

        zipStream.SetLevel(3)       '0-9, 9 being the highest level of compression
        Dim newEntry As New ZipEntry(zipEntryName)
        newEntry.DateTime = DateTime.Now

        zipStream.PutNextEntry(newEntry)

        StreamUtils.Copy(memStreamIn, zipStream, New Byte(4095) {})
        zipStream.CloseEntry()

        zipStream.IsStreamOwner = False     ' False stops the Close also Closing the underlying stream.
        zipStream.Close()           ' Must finish the ZipOutputStream before using outputMemStream.
        outputMemStream.Position = 0
        Return outputMemStream

        '' Alternative outputs:
        '' ToArray is the cleaner and easiest to use correctly with the penalty of duplicating allocated memory.
        'Dim byteArrayOut As Byte() = outputMemStream.ToArray()

        '' GetBuffer returns a raw buffer raw and so you need to account for the true length yourself.
        'Dim byteArrayOut As Byte() = outputMemStream.GetBuffer()
        'Dim len As Long = outputMemStream.Length
    End Function
    
    Public Function GetMultiEUPrice(ByVal kunnr As String, ByVal org As String, ByVal PartNumbers As DataTable) As DataTable
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        For Each p As DataRow In PartNumbers.Rows
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = kunnr : .Mandt = "168" : .Matnr = Format2SAPItem(Trim(UCase(p.Item("part_no")))) : .Mglme = 1
                .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = org
            End With
            pin.Add(prec)
        Next
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            Return Nothing
        End Try
        Dim pdt As DataTable = pout.ToADODataTable()
        pdt.Columns.Remove("Mandt") : pdt.Columns.Remove("Kunnr") : pdt.Columns.Remove("Mglme")
        For Each r As DataRow In pdt.Rows
            r.Item("Matnr") = DeletePreZeros(r.Item("Matnr"))
        Next
        pdt.TableName = "EUPriceTable"
        Return pdt
    End Function

    Public Function DeletePreZeros(ByVal str As String) As String
        If Not str.StartsWith("0") Then Return str
        While str.StartsWith("0") And str.Length > 1
            str = str.Substring(1)
        End While
        Return str
    End Function

    Public Function GetResultDt() As DataTable
        Dim dt As New DataTable
        With dt.Columns
            .Add("Model No") : .Add("Part No") : .Add("Product Line") : .Add("Currency") : .Add("List Price", GetType(Double)) : .Add("Disc")
            .Add("Unit Price", GetType(Double)) : .Add("Product Desc") : .Add("ROHS")
            .Add("Net Weight", GetType(Double)) : .Add("Gross Weight", GetType(Double))
            .Add("Class") : .Add("Product Group") : .Add("Version") : .Add("MODEL_LINK")
        End With
        Return dt
    End Function
    
    Public Function DataTable2ExcelStream(ByVal dt As DataTable) As IO.MemoryStream
        Dim license As Aspose.Cells.License = New Aspose.Cells.License()
        Dim strFPath As String = Server.MapPath("~/Files/Aspose.Total.lic")
        license.SetLicense(strFPath)
        Try
            Dim wb As New Aspose.Cells.Workbook
            wb.Worksheets.Add(Aspose.Cells.SheetType.Worksheet)
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

    Public Function Format2SAPItem(ByVal Part_No As String) As String

        Try
            If IsNumericItem(Part_No) And Not Part_No.Substring(0, 1).Equals("0") Then
                Dim zeroLength As Integer = 18 - Part_No.Length
                For i As Integer = 0 To zeroLength - 1
                    Part_No = "0" & Part_No
                Next
                Return Part_No
            Else
                Return Part_No
            End If
        Catch ex As Exception
            Return Part_No
        End Try

    End Function

    Public Function IsNumericItem(ByVal part_no As String) As Boolean

        Dim pChar() As Char = part_no.ToCharArray()

        For i As Integer = 0 To pChar.Length - 1
            If Not IsNumeric(pChar(i)) Then
                Return False
                Exit Function
            End If
        Next

        Return True
    End Function
    
    
    
    Protected Sub btnDownload_Click(sender As Object, e As System.EventArgs)
        
        'Me.rblAsync.Enabled = False
        
        Dim _DownloadFormat As String = Me.rblFormats.SelectedValue
        Dim _DownloadMethod As String = Me.rblAsync.SelectedValue
        Dim _DownloadTargetPG As String = Me.rblPG.SelectedValue

        Dim _CompanyID As String = Session("company_id")
        Dim _Org As String = Session("org_id")
        Dim _RequestEMail As String = User.Identity.Name

        Dim _PriceOnDemand As New B2B_SAP_WS.PriceOnDemand

        'increase aspx and webservice timeout for 20 mins
        'web service timeout in milliseconds
        _PriceOnDemand.Timeout = 1200000
        'aspx timeout in seconds
        Server.ScriptTimeout = 1200
        
        If Integer.Parse(_DownloadMethod) = DownloadMethod.Email Then
            '***testing code***
            'Me.SendPriceList(_CompanyID, _Org, _RequestEMail, _DownloadFormat, _DownloadMethod, _DownloadTargetPG)
            
            'Use BeginSendPriceList2...for Async call because page ui can redener immediately after the function call.
            'Do not use SendPriceList2Async because Asp.Net is waiting for the BeginSendPriceList2 was done before it renders the page
            'Please reference http://weblogs.asp.net/stevewellens/archive/2010/04/02/calling-web-service-functions-asynchronously-from-a-web-page.aspx
            _PriceOnDemand.BeginSendPriceListByEmail(_CompanyID, _Org, _RequestEMail, _DownloadFormat, _DownloadTargetPG, New AsyncCallback(AddressOf AsyncCallback), _PriceOnDemand)

            Me.Label_BackToHome.Visible = True
            Me.HyperLink_BackToHome.Visible = True

        Else
            '***testing code***
            'Me.SendPriceList(_CompanyID, _Org, _RequestEMail, _DownloadFormat, _DownloadMethod, _DownloadTargetPG)

            'Setting outpur file name
            Dim _XLSFileName As String = "PriceList_" + _CompanyID + ".xls"
            Dim _ZIPFileName As String = "PriceList_" + _CompanyID + ".zip"

            'Getting price as datatable
            Dim retDt As DataTable = _PriceOnDemand.GetPriceList(_CompanyID, _Org, _DownloadTargetPG)
            
            Select Case Integer.Parse(_DownloadFormat)
                Case DownloadFormat.Zip
                    '===Download price list as excel file with Zip compress===
                    'Price datatable transforms to memorystream
                    Dim xls As IO.MemoryStream = DataTable2ExcelStream(retDt)
                    xls.Position = 0
                    'Price memorystream compress to zip streaming
                    Dim _mstm As MemoryStream = Me.CreateToMemoryStream(xls, _XLSFileName)
                    With HttpContext.Current.Response
                        .Clear()
                        .ContentType = "application/zip"
                        .AddHeader("Content-Disposition", String.Format("attachment; filename={0};", _ZIPFileName))
                        .BinaryWrite(_mstm.ToArray)
                    End With
                            
                Case DownloadFormat.Excel
                    '===Download price list as excel file with no compress===
                    Util.DataTable2ExcelDownload(retDt, _XLSFileName)
                            
            End Select
            

        End If
        
        
    End Sub

    ''' <summary>
    ''' Async call back event for when executing BeginSendPriceList2 was done.
    ''' </summary>
    ''' <param name="ar"></param>
    ''' <remarks></remarks>
    Public Sub AsyncCallback(ByVal ar As IAsyncResult)
        
        Dim cb As B2B_SAP_WS.PriceOnDemand = ar.AsyncState
        cb.EndSendPriceListByEmail(ar)
        
    End Sub
        


    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        'Me.Label_BackToHome.Visible = False
        'Me.HyperLink_BackToHome.Visible = False
    End Sub
    
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <th colspan="2">
                <h2>
                    Download Advantech Price List</h2>
            </th>
        </tr>
        <tr>
            <th align="left">
                Format:
            </th>
            <td>
                <asp:RadioButtonList runat="server" ID="rblFormats" RepeatColumns="3" RepeatDirection="Horizontal">
                    <asp:ListItem Text="Excel" Value="0" />
                    <asp:ListItem Text="Zip" Value="2" Selected="True" />
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr>
            <th align="left">
                Download Method:
            </th>
            <td>
                <asp:RadioButtonList runat="server" ID="rblAsync" RepeatColumns="2" RepeatDirection="Horizontal">
                    <asp:ListItem Text="Send to my mailbox" Value="0" Selected="True" />
                    <asp:ListItem Text="Download directly" Value="1" />
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr>
            <th align="left">
            </th>
            <td>
                <asp:RadioButtonList runat="server" ID="rblPG" RepeatColumns="7" RepeatDirection="Horizontal">
                    <asp:ListItem Text="All" Selected="True" />
                    <asp:ListItem Text="Embedded Systems" />
                    <asp:ListItem Text="Industrial Automation" />
                    <asp:ListItem Text="Embcore" />
                    <asp:ListItem Text="Network Computing" />
                    <asp:ListItem Text="Networks and Communication" />
                    <asp:ListItem Text="eServices & Applied Computing" />
                </asp:RadioButtonList>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Button runat="server" ID="btnDownload" Text="Process" OnClick="btnDownload_Click" OnClientClick="btnDownload_ClientClick()"  />
            </td>
            <td>
                <asp:Label ID="Label_BackToHome" runat="server" Text="Price List will be sent to you in few minutes. Back to"
                    Visible="false"></asp:Label>
                &nbsp
                <asp:HyperLink ID="HyperLink_BackToHome" runat="server" Text="MyAdvantech Home" NavigateUrl="~/home.aspx"
                    Visible="false"></asp:HyperLink>
            </td>
        </tr>
    </table>
<script type="text/javascript">

    function btnDownload_ClientClick() {
        window.setTimeout("DisBtn()", 2);
    }
    function DisBtn() {
        var btn = document.getElementById("<%=Me.btnDownload.ClientID %>");
        btn.disable = true;
    }

    function btnDownload_ClientClick_old() {

        //rblAsync
        
        var _downloadmethod = $("#<%=rblAsync.ClientID %>").find("input[checked]").val();

        var _Label_BackToHome = document.getElementById("<%=Me.Label_BackToHome.ClientID %>");

        var _HyperLink_BackToHome = document.getElementById("<%=Me.HyperLink_BackToHome.ClientID %>");

        if (_downloadmethod == 0) {
            //_Label_BackToHome.innerHTML = "Please wait a while for creating download file."
            _Label_BackToHome.innerText = "Please wait a while for creating download file."
        } else {
        
        }

    }
</script>

</asp:Content>
