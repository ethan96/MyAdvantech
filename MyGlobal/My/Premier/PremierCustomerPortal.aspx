<%@ Page Title="MyAdvantech - Premier Customer Portal" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="ChartDirector" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim t1 As New Threading.Thread(AddressOf DrawPerfChart)
            Dim t2 As New Threading.Thread(AddressOf GetATP)
            Dim t3 As New Threading.Thread(AddressOf GetRMA)
            Dim t4 As New Threading.Thread(AddressOf GetBackLog)
            Dim t5 As New Threading.Thread(AddressOf GetAdvContact)
            Dim t6 As New Threading.Thread(AddressOf GetAR)
            t1.Start() : t2.Start() : t3.Start() : t4.Start() : t5.Start() : t6.Start()
            t1.Join() : t2.Join() : t3.Join() : t4.Join() : t5.Join() : t6.Join()
        End If
    End Sub

    Protected Sub Page_Init(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Dim au As New AuthUtil
            'au.ChangeCompanyId("UCAPRO008", "US01")
        End If
    End Sub
    
    Sub GetATP()
        Try
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" select top 5 a.PART_NO, a.PRODUCT_DESC, 0 as ATP  "))
                .AppendLine(String.Format(" from SAP_PRODUCT a  "))
                .AppendLine(String.Format(" where a.PART_NO in ('1950015483N001','9680006904','96D3-8G1066ER-AT','96MPXE-2.9-12M13T','96ND500G-ST-WD5K', '96ND500G-ST-WD5K2','FWA-3210-PC00E','FWA3210PC00E-ES','FWA-6500-PC03E','FWA-6500-PC04E','FWA-6500-PC05E','FWA-6500-PC06E','FWA651021E-ES','NAEM-1001E','NAEM1001E0001E-T','NMC-1002-PC00E','NMC-1003-PC00E') "))
                .AppendLine(String.Format(" order by a.CREATE_DATE desc, a.PART_NO  "))
            End With
            Dim ws As New SAPDAL.SAPDAL, pInDt As New SAPDAL.SAPDALDS.ProductInDataTable, pOutDt As New SAPDAL.SAPDALDS.QueryInventory_OutputDataTable, strErr As String = ""
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
            For Each r As DataRow In dt.Rows
                pInDt.AddProductInRow(r.Item("PART_NO"), 9999, "USH1")
            Next
            'pInDt.AddProductInRow("NAEM0102E0001E-T", 1)
            If ws.QueryInventory(pInDt, "USH1", pOutDt, strErr) Then
                For Each r As DataRow In dt.Rows
                    Dim rs() As SAPDALDS.QueryInventory_OutputRow = pOutDt.Select("part_no='" + r.Item("part_no") + "'")
                    If rs.Length > 0 Then
                        r.Item("ATP") = CDbl(rs(0).STOCK)
                    End If
                Next
                gvATP.DataSource = dt : gvATP.DataBind()
            End If
        Catch ex As Exception

        End Try
       
    End Sub
    
    Sub GetAR()
        Try
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                " select INVOICE_NO, dbo.dateonly(INVOICE_DATE) as inv_date, dbo.dateonly(DUE_DATE) as due_date, AMOUNT " + _
                " from SAP_CUSTOMER_AR a where a.COMPANY_ID='{0}' " + _
                " order by a.DUE_DATE ", Session("company_id")))
            gvAR.DataSource = dt : gvAR.DataBind()
        Catch ex As Exception

        End Try
       
    End Sub
    
    Sub DrawPerfChart()
        Try
            Dim labels() As String = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
            Dim dataPerf() As Double = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
            Dim sqlInvoice As String = String.Format(" select month(efftive_date) as m, sum({1}) as Amount from EAI_ORDER_LOG " + _
                                                     " where " & _
                                                     " Customer_Id='{0}' and tran_type='Shipment' " & _
                                                     " and year(efftive_date)='2011' " & _
                                                     " and qty<>0 " & _
                                                     " group by month(efftive_date) order by month(efftive_date)", Session("company_id"), "US_Amt")
            Dim invDt As DataTable = dbUtil.dbGetDataTable("MY", sqlInvoice)
            For Each r As DataRow In invDt.Rows
                dataPerf(CInt(r.Item("m")) - 1) = CDbl(String.Format("{0:F}", CDbl(r.Item("Amount")) / 1000))
            Next
            Dim c As XYChart = New XYChart(700, 250, &HFFFFFF, &HC7D5F1)
            With c
                .setPlotArea(50, 70, 600, 150, &HFFFFFF, -1, -1, &HC0C0C0, -1) : .addLegend(35, 20, False, "", 8).setBackground(Chart.Transparent)
                .addTitle(Session("company_name") + " 2011 Performance", "Arial Bold Italic", 11, &H333333).setBackground(&HECECEC, &HC7D5F1)
                .yAxis().setTitle("Amount (Unit=1K USD)") : .xAxis().setLabels(labels) : .xAxis().setTitle(" ")
            End With
            Dim layer As LineLayer = c.addLineLayer2()
            With layer
                .setLineWidth(2)
                .addDataSet(dataPerf, GetLineColor("Performance"), "Performance").setDataSymbol(Chart.DiamondSymbol, 6, GetLineColor("Performance"))
            End With
            WebChartViewer1.Image = c.makeWebImage(Chart.PNG)
            WebChartViewer1.ImageMap = c.getHTMLImageMap("", "", "title='[{dataSetName}] Month {xLabel}: {value} Account'")
        Catch ex As Exception

        End Try
       
    End Sub
    
    Private Function GetLineColor(ByVal category As String) As Integer
        Select Case category
            Case "Performance"
                Return &HCC00
            Case "Backlog"
                Return &HDE0023
            Case "Order Entry"
                Return &HFF9900
            Case Else
                Return &HFF
        End Select
    End Function
    
    Sub GetAdvContact()
        Try
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(" select b.FULL_NAME as 'Sales Name', lower(b.EMAIL) as 'Email' ")
                .AppendLine(" from SAP_COMPANY_EMPLOYEE a inner join SAP_EMPLOYEE b on a.SALES_CODE=b.SALES_CODE  ")
                .AppendLine(" where a.COMPANY_ID='" + Session("company_id") + "' and a.PARTNER_FUNCTION='VE' ")
                .AppendLine(" order by b.EMAIL ")
            End With
        Catch ex As Exception

        End Try
       
        'Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
        'gvAdvContact.DataSource = dt : gvAdvContact.DataBind()
    End Sub
    
    Sub GetRMA()
        Try
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(" select top 999 RMA_NO=a.Order_NO+'-'+Cast(a.Item_No as varchar(4)), ")
                .AppendLine(" dbo.DateOnly(a.Order_Dt) as Order_Date, a.Product_Name, a.Barcode, a.Now_Stage ")
                .AppendLine(" from RMA_My_Request_OrderList a ")
                .AppendLine(String.Format(" where a.Bill_ID='{0}' ", Session("company_id")))
                .AppendFormat(" order by a.order_dt desc ")
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
            gvRMA.DataSource = dt : gvRMA.DataBind()
        Catch ex As Exception

        End Try
      
    End Sub
    
    Sub GetBackLog()
        Try
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(" SELECT top 999 a.ORDERNO, a.PRODUCTID, b.PRODUCT_DESC, cast(a.SCHDLINECONFIRMQTY as int) as Confirmed_Qty, a.PONO,  ")
                .AppendLine(" dbo.dateonly(cast(a.DUEDATE as datetime)) as DUEDATE, a.PONO,dbo.dateonly(cast(a.ORDERDATE as datetime)) as ORDERDATE ")
                .AppendLine(" FROM SAP_BACKORDER_AB AS a INNER JOIN SAP_PRODUCT AS b ON a.PRODUCTID = b.PART_NO ")
                .AppendLine(" WHERE a.BILLTOID = '" + Session("company_id") + "' ")
                .AppendLine(" ORDER BY a.DUEDATE, a.ORDERDATE  ")
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString())
            gvBacklog.DataSource = dt : gvBacklog.DataBind()
        Catch ex As Exception

        End Try
      
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr valign="top">            
            <td style="width: 20%">
                <table width="100%">
                    <tr><td><h4>PROCERA NETWORKS, INC.</h4></td></tr>
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td>
                                        <asp:Image runat="server" ID="imgLogo" ImageUrl="~/My/Premier/Procera.jpg" Width="150px" Height="30px" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td><hr /></td>
                    </tr> 
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td><h4>Advantech Contact</h4></td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%" style="border-width:1px; border-style:solid">
                                            <tr valign="top" style="border-width:1px; border-style:solid">
                                                <th align="left" style="border-width:1px; border-style:solid">Name:</th>
                                                <td style="border-width:1px; border-style:solid">Adam Powell, California Regional Manager</td>
                                            </tr>
                                            <tr valign="top" style="border-width:1px; border-style:solid">
                                                <th align="left" style="border-width:1px; border-style:solid">Phone:</th>
                                                <td style="border-width:1px; border-style:solid">(858) 353-2324</td>
                                            </tr>
                                            <tr valign="top" style="border-width:1px; border-style:solid">
                                                <th align="left" style="border-width:1px; border-style:solid">Fax:</th>
                                                <td style="border-width:1px; border-style:solid">(949)789-7178</td>
                                            </tr>
                                            <tr valign="top" style="border-width:1px; border-style:solid">
                                                <th align="left" style="border-width:1px; border-style:solid">Email:</th>
                                                <td style="border-width:1px; border-style:solid"><a href="mailto:Adamp@advantech.com">Adamp@advantech.com</a></td>
                                            </tr>
                                            <tr valign="top" style="border-width:1px; border-style:solid">
                                                <th align="left" style="border-width:1px; border-style:solid">Address:</th>
                                                <td style="border-width:1px; border-style:solid">
                                                    ADVANTECH Corporation 38 Tesla, Suite 100, Irvine, CA 92618  Phone: 1(800)866-6008 FAX:(949)789-7179
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="gvAdvContact" AutoGenerateColumns="true">
                                            <Columns></Columns>
                                        </asp:GridView>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>                   
                </table>
            </td>
            <td style="width: 80%">
                <table width="100%">
                    <tr>
                        <td>
                            <chartdir:WebChartViewer runat="server" ID="WebChartViewer1"/>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%">
                                <tr>
                                    <th align="left">
                                        <h3>
                                            Product Availability</h3>
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:GridView runat="server" ID="gvATP" Width="100%" AutoGenerateColumns="false" AllowPaging="false" PageSize="5">
                                            <Columns>
                                                <asp:BoundField HeaderText="Part Number" DataField="part_no" />
                                                <asp:BoundField HeaderText="Description" DataField="PRODUCT_DESC" />
                                                <asp:BoundField HeaderText="Inventory" DataField="ATP" ItemStyle-HorizontalAlign="Center" />
                                            </Columns>
                                        </asp:GridView>
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
                                    <th align="left">
                                        <h3>
                                            My Backorder</h3>
                                    </th>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="PanelMyBo" Width="100%" Height="100px" ScrollBars="Auto">
                                            <asp:GridView runat="server" ID="gvBacklog" Width="100%" AutoGenerateColumns="false">
                                                <Columns>
                                                    <asp:BoundField HeaderText="PO No." DataField="PONO" />
                                                    <asp:BoundField HeaderText="Part No." DataField="PRODUCTID" />
                                                    <asp:BoundField HeaderText="Due Date" DataField="DUEDATE" />
                                                    <asp:BoundField HeaderText="Qty." DataField="Confirmed_Qty" />
                                                    <asp:BoundField HeaderText="Order Date" DataField="ORDERDATE" />
                                                </Columns>
                                            </asp:GridView>
                                        </asp:Panel>
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
                                    <th align="left"><h3>My A/P</h3></th>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="PanelAR" Width="100%" Height="100px" ScrollBars="Auto">
                                            <asp:GridView runat="server" ID="gvAR" Width="100%" AutoGenerateColumns="false">
                                                <Columns>
                                                    <asp:BoundField HeaderText="Invoice No." DataField="INVOICE_NO" />
                                                    <asp:BoundField HeaderText="Invoice Date" DataField="inv_date" />
                                                    <asp:BoundField HeaderText="Due Date" DataField="due_date" />
                                                    <asp:BoundField HeaderText="Amount" DataField="AMOUNT" />
                                                </Columns>
                                            </asp:GridView>
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%">
                                <tr>
                                    <th align="left"><h3>My RMA Order</h3></th>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Panel runat="server" ID="Panel1" Width="100%" Height="100px" ScrollBars="Auto">
                                            <asp:GridView runat="server" ID="gvRMA" Width="100%" AutoGenerateColumns="false">
                                                <Columns>
                                                    <asp:HyperLinkField HeaderText="RMA No." Target="_blank" DataNavigateUrlFields="RMA_NO"
                                                        DataNavigateUrlFormatString="http://erma.advantech.com.tw/WorkSpace/rma_display_summary.asp?rmano={0}"
                                                        DataTextField="RMA_NO" SortExpression="RMA_NO" />
                                                    <asp:BoundField DataField="Now_Stage" HeaderText="Status" SortExpression="Now_Stage" />
                                                    <asp:BoundField DataField="Barcode" HeaderText="Barcode" SortExpression="Barcode" />
                                                </Columns>
                                            </asp:GridView>
                                        </asp:Panel>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>                                 
        </tr>
    </table>
</asp:Content>
