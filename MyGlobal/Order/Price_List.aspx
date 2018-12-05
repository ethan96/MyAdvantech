<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Download Price List" Culture="auto" UICulture="auto" Async="true" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">

    Function GetCurrentPriceYearQuarter(ByRef pYear As String, pQuarter As String) As Boolean
        Dim pRBU As String = ""

        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Select Case UCase(Session("Org"))
        Select Case Left(UCase(Session("Org_id")), 2)
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
                Return True
            End If
        End If
        Return False
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'ICC 2015/11/11 For Arrow users, they only can download price list from Andy's file.
        If Session("COMPANY_ID") IsNot Nothing AndAlso AuthUtil.IsArrowCompanyUser(Session("COMPANY_ID").ToString().Trim()) Then
            Dim fdt As DataTable = dbUtil.dbGetDataTable("MyLocal", String.Format( _
                 " SELECT top 1 File_Name,File_Ext,File_Size,File_Data " + _
                 " FROM PRICE_FILES where File_Name='ARROW_PriceList' and File_Data is not null and File_Name<>'' and File_Ext in('XLS','XLSX') ")) 'ICC 2015/10/23 Since XLSX can be upload, this SQL should change to XLS & XLSX.
            If fdt.Rows.Count = 1 Then
                Dim r As DataRow = fdt.Rows(0)
                Dim FileNameFull As String = r.Item("File_Name") + "." + r.Item("File_Ext")
                Response.AddHeader("content-type", "application/vnd.ms-excel;")
                Response.AddHeader("Content-Disposition", "inline;filename=" + _
                                   System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(FileNameFull)))
                Response.AddHeader("content-length", r.Item("File_Size"))
                Response.BinaryWrite(r.Item("File_Data"))
            Else
                Util.JSAlert(Me.Page, "Cannot find this document on server")
            End If
            'Response.End()
        End If

        '--For  American customer
        If Session("RBU") IsNot Nothing AndAlso (Session("RBU").ToString.ToUpper = "ANA") AndAlso Not MailUtil.IsInMailGroup("ChannelManagement.ACL", Session("user_id").ToString) Then
            If Session("SAP Sales Office") IsNot Nothing AndAlso Session("SAP Sales Office").ToString() = "2100" Then
                Dim fdt As DataTable = dbUtil.dbGetDataTable("MyLocal", String.Format(
            " SELECT top 1 File_Name,File_Ext,File_Size,File_Data " +
            " FROM PRICE_FILES where File_Name='{0}' and File_Data is not null and File_Name<>'' and File_Ext in('XLS','XLSX') ", "AAC_PriceList")) 'ICC 2015/10/23 Since XLSX can be upload, this SQL should change to XLS & XLSX.
                If fdt.Rows.Count = 1 Then
                    Dim r As DataRow = fdt.Rows(0)
                    Dim FileNameFull As String = r.Item("File_Name") + "." + r.Item("File_Ext")
                    Response.AddHeader("content-type", "application/vnd.ms-excel;")
                    Response.AddHeader("Content-Disposition", "inline;filename=" +
                                       System.Web.HttpUtility.UrlEncode(Request.ContentEncoding.GetBytes(FileNameFull)))
                    Response.AddHeader("content-length", r.Item("File_Size"))
                    Response.BinaryWrite(r.Item("File_Data"))
                    Response.End()
                End If
            End If
        End If
        '-- End
        If Request("ERPID") IsNot Nothing AndAlso Request("ERPID").ToString() <> "" AndAlso Util.IsInternalUser(Session("user_id")) Then
            Dim erpid As String = Trim(Request("ERPID"))
            Dim au As New AuthUtil
            au.ChangeCompanyId(erpid)
        End If
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'If Session("ORG") IsNot Nothing AndAlso _
        '    (Session("ORG").ToString.ToUpper = "EU" Or Session("ORG").ToString.ToUpper = "US" Or Session("ORG").ToString.ToUpper = "TW" _
        '     Or Session("ORG").ToString.ToUpper = "JP" Or Session("ORG").ToString.ToUpper = "AU" Or Session("ORG").ToString.ToUpper = "SG") Then
        'Else
        '    Tab1.Visible = True
        '    'Response.Write("Org:" + Session("ORG"))
        '    HyperLink1.NavigateUrl = Request.UrlReferrer.ToString
        '    Exit Sub
        'End If
        Dim _org_id As String = Session("org_id")
        If _org_id IsNot Nothing AndAlso _
        (Left(_org_id.ToUpper, 2) = "EU" Or Left(_org_id.ToUpper, 2) = "US" Or Left(_org_id.ToUpper, 2) = "TW" _
        Or Left(_org_id.ToUpper, 2) = "JP" Or Left(_org_id.ToUpper, 2) = "AU" Or Left(_org_id.ToUpper, 2) = "SG") Then
        Else
            Tab1.Visible = True
            'Response.Write("Org:" + Session("ORG"))
            HyperLink1.NavigateUrl = Request.UrlReferrer.ToString
            Exit Sub
        End If

        ' If Session("account_status") <> "EZ" And Session("account_status") <> "CP" And Session("account_status") <> "FC" Then Response.End()
        ' Ming 20141013 修改成只有GA不能進來即可
        If String.Equals(Session("account_status"), "GA") Then Response.End()
        Dim infoDt As DataTable = dbUtil.dbGetDataTable("MY", _
        " select top 1 price_class, IsNull(currency,'EUR') as currency from sap_dimcompany " + _
        " where company_id='" + Session("company_id") + "' and org_id='" + Session("org_id") + "'")
        If infoDt.Rows.Count > 0 Then
            '20150713 TC: redirect user to price list download page and no more send to customer by email
            Response.Redirect("PriceListDL.aspx")
            'Response.Redirect("SendPriceList.aspx")
            Dim pgrade As String = infoDt.Rows(0).Item("price_class")
            Dim strCurr As String = infoDt.Rows(0).Item("currency").ToString.ToUpper()
            Dim pYear As String = "2011", pQuarter As String = "3"
            If Not GetCurrentPriceYearQuarter(pYear, pQuarter) Then
                Response.Clear()
                'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
                'Response.Write("cannot get current pricing year and quarter for org " + Session("org") + "</br>Please contact <a href='mailto:MyAdvantech@advantech.com'>MyAdvantech@advantech.com</a>.")
                Response.Write("cannot get current pricing year and quarter for org " + Left(Session("org_id"), 2) + "</br>Please contact <a href='mailto:MyAdvantech@advantech.com'>MyAdvantech@advantech.com</a>.")
                Response.End()
            End If
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" SELECT PROD_NAME as [Part No], PROD_LN as [Product Line], CURCY_CD as Currency,  "))
                .AppendLine(String.Format(" cast(LIST_PRICE as numeric(18,2)) as [List Price], cast(AMT1 as numeric(18,2)) as [Unit Price],  "))
                .AppendLine(String.Format(" cast(DISCOUNT1 as integer) as [Disc], DESC_TXT as [Product Desc], '' as ROHS, '' as Class, '' as [Product Group], "))
                .AppendLine(String.Format(" YEAR+' Q'+QUARTER as Version, '' as MODEL_LINK "))
                .AppendLine(String.Format(" FROM Price "))
                .AppendLine(String.Format(" WHERE (GRADE_NAME = '{0}') AND (ORG = 'AESC') AND (YEAR = '{1}') AND (QUARTER = '{2}') AND (CURCY_CD = '{3}') ", _
                                          pgrade, pYear, pQuarter, strCurr))

            End With
            Dim ePricerDt As DataTable = dbUtil.dbGetDataTable("EPRICER", sb.ToString())
            Dim ptradeDt As DataTable = dbUtil.dbGetDataTable("MY", _
               " select distinct a.PART_NO, a.product_desc, case a.ROHS_FLAG when 1 then 'y' else 'n' end as RoHS, a.PRODUCT_GROUP, a.PRODUCT_LINE, -1 as Unit_Price,  " + _
               " IsNull((select top 1 z.ABC_INDICATOR from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Session("org_id"), 2) + "H1' ),'') as class " + _
               " from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO " + _
               " inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO and b.ORG_ID=c.SALES_ORG  " + _
               " where b.ORG_ID='" + Session("org_id") + "' and c.PRODUCT_STATUS in ('A','N','H','M1')  " + _
               " and ( " + _
               " 		a.PRODUCT_HIERARCHY like 'AGSG-PAPS-%' or  " + _
               " 		a.MATERIAL_GROUP in ('P-','968','968A','968EM','968MS','96CA','96CF','96FM','96HD','96KB', " + _
               " 			'96MM','96MP','96MT','96OD','96OT','96SS','96SW','98') or  " + _
               " 			a.PART_NO like 'P-%' " + _
               " 	) " + _
               " order by a.PART_NO  ")
            Dim sapDt As DataTable = Util.GetMultiEUPrice(Session("company_id"), Session("org_id"), ptradeDt)
            'Util.DataTable2ExcelDownload(sapDt, "PriceList.xls")
            For Each r As DataRow In ptradeDt.Rows
                Dim rs() As DataRow = sapDt.Select("Matnr='" + Global_Inc.Format2SAPItem(r.Item("part_no")) + "'")
                If rs.Length > 0 Then
                    r.Item("Unit_Price") = rs(0).Item("Netwr")
                End If
            Next
            ptradeDt.AcceptChanges()
            Dim allPnDt As DataTable = dbUtil.dbGetDataTable("MY", _
            " select a.part_no, case a.ROHS_FLAG when 1 then 'y' else 'n' end as RoHS,  " + _
            " IsNull((select top 1 z.ABC_INDICATOR from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Session("org_id"), 2) + "H1' ),'') as class, a.product_group, a.MODEL_NO  " + _
            " from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.PART_NO=b.PART_NO  " + _
            " inner join SAP_PRODUCT_STATUS c on b.PART_NO=c.PART_NO and b.ORG_ID=c.SALES_ORG  " + _
            " where b.ORG_ID='" + Session("org_id") + "' and c.PRODUCT_STATUS in ('A','N','H','M1')  ")
            Dim dtcopy As New DataTable
            dtcopy = ePricerDt.Clone
            For Each r As DataRow In ePricerDt.Rows
                Dim rs() As DataRow = allPnDt.Select("part_no='" + r.Item("Part No") + "'")
                If rs.Length > 0 Then
                    r.Item("ROHS") = rs(0).Item("rohs")
                    r.Item("Class") = rs(0).Item("class")
                    r.Item("Product Group") = rs(0).Item("product_group")
                    If rs(0).Item("model_no").ToString() <> "" Then
                        r.Item("MODEL_LINK") = "http://" + Request.ServerVariables("HTTP_HOST").ToString + "/Product/Model_Detail.aspx?model_no=" + rs(0).Item("model_no")
                    End If
                    dtcopy.ImportRow(r)
                End If
            Next
            For Each r As DataRow In ptradeDt.Rows
                If dtcopy.Select("[Part No]='" + r.Item("part_no") + "'").Length = 0 Then
                    Dim nr As DataRow = dtcopy.NewRow()
                    With nr
                        .Item("Part No") = r.Item("part_no")
                        .Item("Product Line") = r.Item("PRODUCT_LINE")
                        .Item("Currency") = strCurr
                        .Item("List Price") = r.Item("Unit_Price")
                        .Item("Unit Price") = r.Item("Unit_Price")
                        .Item("Product Desc") = r.Item("product_desc")
                        .Item("ROHS") = r.Item("rohs")
                        .Item("Class") = r.Item("class")
                        .Item("Product Group") = r.Item("product_group")
                    End With
                    dtcopy.Rows.Add(nr)
                End If
            Next
            Dim str(0) As String
            str(0) = pYear + " Q" + pQuarter
            Util.DataTable2ExcelDownload(dtcopy, "ANAIT_PriceList.xls")
        End If

    End Sub

    Sub SendPriceList()
        'Dim thread1 As New Threading.Thread(AddressOf SendPriceListClass)
        'thread1.Start()
        Dim sapWs As New aeu_ebus_dev9000.PriceOnDemand
        sapWs.SendPriceListAsync(Session("company_id"), Session("org_id"), User.Identity.Name)
    End Sub

</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <table width="50%" border="0" height="200"  align="center" id="Tab1" runat="server" visible="false" >
      <tr>
        <td>
            Your user account may not have sufficient privileges to access this page,
            <asp:HyperLink  ID="HyperLink1"  Font-Underline="true" runat="server" ForeColor="Red" Font-Size="Large">Back</asp:HyperLink>.
        </td>
      </tr>
    </table>
</asp:Content>
