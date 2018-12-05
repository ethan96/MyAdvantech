<%@ Page Title="MyAdvantech - Price List Download" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Timer1_Tick(sender As Object, e As EventArgs)
        Timer1.Interval = 500
        Try
            If ViewState("PriceListTask") IsNot Nothing Then
                Dim PriceListTask1 As PriceListTask = TryCast(ViewState("PriceListTask"), PriceListTask)
                If PriceListTask1 Is Nothing Then
                    imgXls.Visible = False : Me.lbProgress.Text = "No Price List is being generated" : Timer1.Enabled = False : Exit Sub
                End If
                Dim rnd As New Random()

                Dim NotProcPriceRecords = From q In PriceListTask1.ProductPriceRecordList Where q.ProcFlag = False Take rnd.Next(300, 1500)

                If NotProcPriceRecords.Count > 0 Then
                    Dim priceDt As New DataTable
                    priceDt.Columns.Add("part_no")

                    For Each rec In NotProcPriceRecords
                        Dim pr As DataRow = priceDt.NewRow()
                        pr.Item("part_no") = rec.PART_NO
                        priceDt.Rows.Add(pr)
                    Next

                    Dim priceOutDt As DataTable = Util.GetMultiEUPrice(PriceListTask1.CompanyId, PriceListTask1.Org, priceDt)

                    For Each rec In NotProcPriceRecords
                        rec.ProcFlag = True
                        Dim matchedRows() As DataRow = priceOutDt.Select("matnr='" + Global_Inc.Format2SAPItem(Trim(UCase(rec.PART_NO))) + "'")

                        If matchedRows.Length > 0 Then
                            rec.UNIT_PRICE = matchedRows(0).Item("Netwr") : rec.LIST_PRICE = matchedRows(0).Item("Kzwi1")
                            If rec.LIST_PRICE < rec.UNIT_PRICE Then
                                rec.LIST_PRICE = rec.UNIT_PRICE
                            End If
                            rec.Currency = matchedRows(0).Item("Waerk")
                        End If
                    Next

                    Dim ProcCount = From q In PriceListTask1.ProductPriceRecordList Where q.ProcFlag = True

                    Me.lbProgress.Text = String.Format("Processed {0} items, total {1} items", ProcCount.Count, PriceListTask1.ProductPriceRecordList.Count)
                Else
                    Me.lbProgress.Text = "Price list is ready to be downloaded" : Timer1.Enabled = False : imgXls.Visible = True
                End If

            End If
        Catch ex As Exception
            Timer1.Enabled = False : Me.lbProgress.Text = ex.ToString() : imgXls.Visible = False
        End Try
    End Sub

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not Page.IsPostBack Then
            Dim PriceListTask1 As New PriceListTask(Session("company_id"), Session("org_id"), User.Identity.Name)
            ViewState("PriceListTask") = PriceListTask1
        End If
    End Sub

    <Serializable()> _
    Public Class ProductPriceRecord
        Public Property PART_NO As String : Public Property MODEL_NO As String
        Public ReadOnly Property Model_Link As String
            Get
                If Not String.IsNullOrEmpty(Me.MODEL_NO.Trim) Then Return "http://my.advantech.com/Product/Model_Detail.aspx?Model_No=" + Me.MODEL_NO
                Return ""
            End Get
        End Property

        Public Property PRODUCT_DIVISION As String
        Public Property PRODUCT_DESC As String : Public Property RoHS As String
        Public Property PRODUCT_GROUP As String : Public Property PRODUCT_LINE As String : Public Property LIST_PRICE As Decimal : Public Property UNIT_PRICE As Decimal
        Public ReadOnly Property Discount As String
            Get
                If Me.LIST_PRICE > 0 Then
                    Return FormatNumber((Me.LIST_PRICE - Me.UNIT_PRICE) / Me.LIST_PRICE * 100, 0) + "%"
                End If
                Return ""
            End Get
        End Property
        Public Property Currency As String : Public Property [CLASS] As String : Public Property COUNTRY_ORIGIN As String : Public Property FREIGHT_METHOD As String
        Public Property NET_WEIGHT As Double : Public Property GROSS_WEIGHT As Double : Public Property SIZE_DIMENSIONS As String
        Public Property SOURCE_LOCATION As String : Public Property CNCODE As String : Public Property ProcFlag As Boolean
        Public Property MOQ As Integer
        Public Sub New()
            ProcFlag = False : LIST_PRICE = 0 : UNIT_PRICE = 0
        End Sub

    End Class

    <Serializable()> _
    Public Class PriceListTask
        Public Property CompanyId As String : Public Property Org As String : Public Property UserId As String : Public Property RequestTimeStamp As DateTime
        Public Property ProductPriceRecordList As List(Of ProductPriceRecord)
        Public Sub New(CompanyId As String, OrgId As String, UserId As String)
            Me.CompanyId = CompanyId : Me.Org = OrgId : Me.UserId = UserId : RequestTimeStamp = Now

            Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Org = UCase(Org).Trim() : CompanyId = UCase(CompanyId).Trim()

            Dim strProducts As String =
                 " select distinct top 30000 a.PART_NO, a.model_no, a.EDIVISION as product_division , " +
                 " (select top 1 (CASE WHEN ISNULL(EXTENDED_DESC,'')='' THEN a.product_desc ELSE SAP_PRODUCT_EXT_DESC.extended_desc END) AS TT from SAP_PRODUCT_EXT_DESC (nolock) " +
                 " where SAP_PRODUCT_EXT_DESC.PART_NO=a.PART_NO ) as product_desc, " +
                 " case a.ROHS_FLAG when 1 then 'y' else 'n' end as RoHS, a.PRODUCT_GROUP, " +
                 " a.PRODUCT_LINE, -1 as Unit_Price,  " +
                 " IsNull((select top 1 z.ABC_INDICATOR from SAP_PRODUCT_ABC z (nolock) where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Org, 2) + "H1' ),'') as class, " +
                 " IsNull((select top 1 z.COUNTRY_ORIGIN from SAP_PRODUCT_ABC z (nolock) where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Org, 2) + "H1' ),'') as COUNTRY_ORIGIN, " +
                 " IsNull((select top 1 z.FREIGHT_METHOD from SAP_PRODUCT_ABC z (nolock) where z.PART_NO=a.PART_NO and z.PLANT='" + Left(Org, 2) + "H1' ),'') as FREIGHT_METHOD, " +
                 " a.NET_WEIGHT, a.GROSS_WEIGHT ,a.SIZE_DIMENSIONS,a.SOURCE_LOCATION ,'' AS CNCODE, cast(c.MIN_ORDER_QTY as int) as MOQ " +
                 " from SAP_PRODUCT a (nolock) inner join SAP_PRODUCT_ORG b (nolock) on a.PART_NO=b.PART_NO " +
                 " inner join SAP_PRODUCT_STATUS c (nolock) on b.PART_NO=c.PART_NO and b.ORG_ID=c.SALES_ORG  " +
                 IIf(Util.IsInternalUser2(), " ", " left join SAP_PRODUCT_ABC z on a.PART_NO = z.PART_NO ") +
                 IIf(Util.IsInternalUser2(), " ", " inner join SAP_PRODUCT_STATUS_ORDERABLE d on a.PART_NO = d.PART_NO and d.SALES_ORG = '" + Org + "' ") +
                 " where b.ORG_ID='" + Org + "' and c.PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " and a.PRODUCT_HIERARCHY<>'EAPC-INNO-DPX' " +
                 " and (a.material_group in ('PRODUCT','P-','968','968A','968EM','968MS','96CA','96CF','96FM','96HD','96KB', '96MM'," +
                 " '96MP','96MT','96OD','96OT','96SS','96SW','98','170','BBPROD','P-PRODUCT') or a.PART_NO like 'P-%') and a.part_no not like '#%' "

            'Ryan 20160422 If not internal user, block X/Y parts.
            If Not Util.IsInternalUser2() Then
                strProducts += " and left(a.PART_NO,1) not in ('X','Y') "
                strProducts += " and isnull(z.ABC_INDICATOR,'') not IN ('T','P') "
            End If

            'Ryan 20160422 If company is defined in SAP ZTSD_106C, then block 968T parts for viewing.
            If Not Advantech.Myadvantech.Business.UserRoleBusinessLogic.CanSee968TParts(CompanyId) Then
                strProducts += " and a.part_no not like '968T%' "
            End If


            Dim productDt As New DataTable, sapDt As New DataTable
            Dim apt As New SqlClient.SqlDataAdapter(strProducts, conn)

            'Frank
            'increase command timout
            apt.SelectCommand.CommandTimeout = 1200

            apt.Fill(productDt)
            conn.Close()

            Me.ProductPriceRecordList = Util.DataTableToList(Of ProductPriceRecord)(productDt)
        End Sub
    End Class

    Protected Sub imgXls_Click(sender As Object, e As ImageClickEventArgs)
        If ViewState("PriceListTask") IsNot Nothing Then
            Dim PriceListTask1 As PriceListTask = TryCast(ViewState("PriceListTask"), PriceListTask)
            If PriceListTask1 IsNot Nothing AndAlso PriceListTask1.ProductPriceRecordList IsNot Nothing AndAlso PriceListTask1.ProductPriceRecordList.Count > 0 Then
                Dim priceDt As DataTable = Util.ListToDataTable(PriceListTask1.ProductPriceRecordList)
                priceDt.Columns.Remove("procFlag")

                '20180118 TC: For B+B to display scale price
                If HttpContext.Current.Session("org_id").ToString().Equals("US10") Then
                    Dim sqlScale =
                    "  select d.PART_NO, b.BREAKDOWN_QTY, b.BREAKDOWN_DISCOUNTRATE  " +
                    "  from SAP_DIMCOMPANY a (nolock) inner join SAP_PRICE_BREAKDOWN b (nolock)  " +
                    "  on a.PRICE_LIST=b.PRICE_LIST and a.PRICE_GRP=b.PRICE_GROUP and a.ORG_ID=b.ORG_ID  " +
                    "  inner join SAP_PRODUCT c (nolock) on c.PRODUCT_LINE=b.PRODUCT_LINE  " +
                    "  inner join SAP_PRODUCT_ORG d (nolock) on a.ORG_ID=d.ORG_ID and b.MAT_PRI_GRP=d.PRICINGGROUP and c.PART_NO=d.PART_NO  " +
                    "  where a.ORG_ID='" + HttpContext.Current.Session("org_id").ToString() + "' " +
                    "  and a.COMPANY_ID='" + HttpContext.Current.Session("company_id").ToString() + "' and b.BREAKDOWN_QTY>1  " +
                    "  and d.STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " " +
                    "  order by d.PART_NO, b.BREAKDOWN_QTY  "
                    Dim conn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                    Dim apt As New SqlClient.SqlDataAdapter(sqlScale, conn)

                    apt.SelectCommand.CommandText = sqlScale
                    Dim dtScale = New DataTable
                    apt.Fill(dtScale)
                    If (dtScale.Rows.Count > 0) Then
                        With priceDt.Columns
                            .Add("List Price") : .Add("1 Piece Price") : .Add("1 Piece Discount")
                            .Add("Scale1 Qty") : .Add("Scale1 Price")
                            .Add("Scale2 Qty") : .Add("Scale2 Price")
                            .Add("Scale3 Qty") : .Add("Scale3 Price")
                        End With
                        For Each rowPNPrice As DataRow In priceDt.Rows
                            rowPNPrice("List Price") = rowPNPrice("LIST_PRICE")
                            rowPNPrice("1 Piece Price") = rowPNPrice("UNIT_PRICE")
                            rowPNPrice("1 Piece Discount") = rowPNPrice("Discount")
                            Dim scaleRows = dtScale.Select("PART_NO='" + rowPNPrice.Item("PART_NO").ToString() + "'")
                            For intScale As Integer = 0 To scaleRows.Length - 1
                                If intScale > 2 Then Exit For
                                rowPNPrice.Item(String.Format("Scale{0} Qty", (intScale + 1).ToString())) = scaleRows(intScale).Item("BREAKDOWN_QTY")
                                rowPNPrice.Item(String.Format("Scale{0} Price", (intScale + 1).ToString())) =
                                    rowPNPrice.Item("LIST_PRICE") * (1.0 + CDbl(scaleRows(intScale).Item("BREAKDOWN_DISCOUNTRATE")))
                            Next
                        Next
                        With priceDt.Columns
                            .Remove("LIST_PRICE") : .Remove("UNIT_PRICE") : .Remove("Discount") : .Remove("FREIGHT_METHOD")
                        End With
                    End If
                End If


                'ICC 2017/08/01 Change to NPOI function for XLSX
                'Util.DataTable2ExcelDownload(priceDt, "PriceList.xls")
                Try
                    Dim ms As System.IO.MemoryStream = Advantech.Myadvantech.DataAccess.ExcelUtil.DataTableToMemoryStream(priceDt)
                    Response.AddHeader("Content-Disposition", "attachment; filename=PriceList.xlsx")
                    Response.BinaryWrite(ms.ToArray())
                    ms.Close()
                    ms.Dispose()
                Catch ex As Exception
                    Util.JSAlert(Me.Page, "Download failed! Error message: " + ex.Message)
                End Try
                Response.Flush()
                Response.End()
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Timer runat="server" ID="Timer1" OnTick="Timer1_Tick" Interval="500" />
            <table>
                <tr>
                    <td>
                        <asp:Label runat="server" ID="lbProgress" Font-Bold="true" Text="Starting to generate price list..." />&nbsp;<asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download" Visible="false" OnClick="imgXls_Click" />
                    </td>
                </tr>
            </table>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="imgXls" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>

