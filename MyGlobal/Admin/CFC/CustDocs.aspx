<%@ Page Title="MyAdvantech - Customer's SAP Document Records" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As EventArgs)
        If Not Page.IsPostBack Then
            'If Not MailUtil.IsInRole("OPLeader.GBS.ACL") AndAlso Not MailUtil.IsInRole("OP.CFR.ACL") _
            '    AndAlso Not MailUtil.IsInRole("Auditing") AndAlso Not MailUtil.IsInRole("MyAdvantech") Then
            '    Response.Redirect(Util.GetRuntimeSiteUrl() + "/home.aspx")
            'End If
            If Request("cid") IsNot Nothing AndAlso String.IsNullOrEmpty(Request("cid")) = False Then
                hdERPID.Value = HttpUtility.UrlDecode(Trim(Request("cid")).ToUpper()).Replace("'", "")
                FillBasicData()
            End If
        End If
    End Sub

    Public Class CreditLimitData
        Public Property CustomerId As String : Public CreditControlAreaOption As CreditControlAreaOptions : Public Property HorizonDate As Date
        Public Property Currency As String : Public Property CreditLimit As Decimal : Public Property Delta2Limit As Decimal : Public Property Percentage As String
        Public Property Receivables As Decimal : Public Property SpecialLiability As Decimal
        Public Property OpenDelivery As Decimal : Public Property OpenDeliverySecure As Decimal : Public Property OpenInvoice As Decimal
        Public Property OpenInvoiceSecure As Decimal : Public Property OpenOrders As Decimal : Public Property OpenOrderSecure As Decimal : Public Property SumOpen As Decimal
        Public ReadOnly Property CreditControlArea As String
            Get
                Return Me.CreditControlAreaOption.ToString()
            End Get
        End Property
        Public ReadOnly Property CreditExposure As Decimal
            Get
                Return CreditLimit - Delta2Limit
            End Get
        End Property
        Public ReadOnly Property SalesValue As Decimal
            Get
                Return Me.CreditExposure - Receivables - SpecialLiability
            End Get
        End Property

        Public Sub New(CustomerId As String, CreditControlArea As CreditControlAreaOptions)
            Me.CustomerId = Trim(CustomerId).ToUpper() : Me.CreditControlAreaOption = CreditControlArea : Me.HorizonDate = New Date(9999, 12, 31)
        End Sub

        Public Sub New(CustomerId As String, CreditControlArea As CreditControlAreaOptions, HorizonDate As Date)
            Me.CustomerId = Trim(CustomerId).ToUpper() : Me.CreditControlAreaOption = CreditControlArea : Me.HorizonDate = HorizonDate
        End Sub

        Public Function GetCreditData() As Boolean
            Dim p As New GetCreditExposure.GetCreditExposure(ConfigurationManager.AppSettings("SAP_PRD"))
            Dim dtKnkk As GetCreditExposure.KNKK = Nothing, Knkli As String = ""
            p.Connection.Open()
            p.Zcredit_Exposure(HorizonDate.ToString("yyyyMMdd"), CreditControlArea, CustomerId, Currency, CreditLimit, Delta2Limit, dtKnkk, Knkli, OpenDelivery, OpenDeliverySecure, _
                       OpenInvoice, OpenInvoiceSecure, Receivables, OpenOrders, OpenOrderSecure, SpecialLiability, Percentage, SumOpen)
            p.Connection.Close()
            Return True
        End Function

    End Class

    Public Enum CreditControlAreaOptions
        CNC1
        CNC2
        CNC3
        CNC4
        CN01
        CN02
        CN08
        HK05
        ID01
        IN01
        EU01
        EU80
        USC1
        USC2
        TW01
        TW02
        TW03
        TW04
        TW05
        TW06
        TW07
        TW08
        TW09
        TW10
        TW16
        TW99
        JP01
        KR01
        MY01
        SG01
        TL01
        AU01
        BR01
    End Enum


    Sub FillBasicData()
        FillCustProfile() : FillCreditMemoList()
        FillCreditDocList()
    End Sub

    Sub FillCustProfile()
        Dim dt = dbUtil.dbGetDataTable("MY", "select top 1 company_name, address, country_name, city from sap_dimcompany where company_id='" + hdERPID.Value + "'")
        If dt.Rows.Count > 0 Then
            lbCustName.Text = String.Format("{0} ({1})", dt.Rows(0).Item("company_name"), hdERPID.Value)
            lbAddr.Text = String.Format("{0}, {1}, {2}", dt.Rows(0).Item("country_name"), dt.Rows(0).Item("city"), dt.Rows(0).Item("address"))
        End If
    End Sub

    Sub FillCreditMemoList()
        Dim creditdataCNC1 As New CreditLimitData(Me.hdERPID.Value, CreditControlAreaOptions.CNC1)
        Dim creditdataCNC3 As New CreditLimitData(Me.hdERPID.Value, CreditControlAreaOptions.CNC3)
        creditdataCNC1.GetCreditData() : creditdataCNC3.GetCreditData()
        Dim creditDataList As New List(Of CreditLimitData)
        creditDataList.Add(creditdataCNC1) : creditDataList.Add(creditdataCNC3)
        gvCustCredit.DataSource = creditDataList : gvCustCredit.DataBind()
    End Sub

    Sub FillCreditDocList()
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
        " select a.SALES_ORG, a.SO_NO, a.ORDER_TYPE, a.CREATED_DATE, a.CURRENCY, IsNull(a.INVOICE_DATE,'') as INVOICE_DATE, " + _
        " SUM(a.TOTAL_PRICE) as TotalAmount, SUM(a.TOTAL_PRICE_USD) as TotalAmountUSD " + _
        " from CurationPool.dbo.CN_MEMO a (nolock)  " + _
        " where a.COMPANY_ID='" + hdERPID.Value + "' and a.ORDER_TYPE in ('G2','ZDR','ZRE1') " + _
        " group by a.SALES_ORG, a.SO_NO, a.ORDER_TYPE, a.CREATED_DATE, a.CURRENCY, a.INVOICE_DATE  " + _
        " order by a.INVOICE_DATE desc, a.CREATED_DATE desc ")
        gvCreditDocList.DataSource = dt : gvCreditDocList.DataBind()
    End Sub

    Public Shared Function SAPDateToDateStr(SAPDate As String) As String
        Dim cult As New System.Globalization.CultureInfo("en-US")
        If Date.TryParseExact(SAPDate, "yyyyMMdd", cult, System.Globalization.DateTimeStyles.None, Now) Then
            Return Date.ParseExact(SAPDate, "yyyyMMdd", cult).ToString("yyyy/MM/dd")
        End If
        Return ""
    End Function

    Sub GetPrevSOList()

    End Sub

    Protected Sub gvCreditDocList_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim sono As String = CType(e.Row.FindControl("hdRowSONO"), HiddenField).Value
            Dim gvRowItemList As GridView = CType(e.Row.FindControl("gvRowItemList"), GridView)
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", _
                " select PART_NO, LINE_NO, TARGET_QTY, ORDER_QTY, IsNull(INVOICE_NO,'') as INVOICE_NO, CURRENCY, TOTAL_PRICE, TOTAL_PRICE_USD " + _
                " from CurationPool.dbo.CN_MEMO where SO_NO='" + sono + "' order by LINE_NO, PART_NO ")
            gvRowItemList.DataSource = dt : gvRowItemList.DataBind()
        End If
    End Sub

    Function GetSOByCreditDoc(CompanyId As String, CreditDocNo As String, PrevMonths As Integer) As DataTable
        Dim docCreatedDateStr As String = OraDbUtil.dbExecuteScalar("SAP_PRD", "select erdat from saprdp.vbak where vbeln='" + CreditDocNo + "'")
        Dim CreditDocDate As Date = Date.ParseExact(docCreatedDateStr, "yyyyMMdd", New System.Globalization.CultureInfo("en-US"))
        Dim sql As String = _
        " select distinct a.vbeln as SO_NO, a.erdat " + _
        " from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln     " + _
        " where rownum<=30 and a.mandt='168' and a.kunnr='" + CompanyId + "' and a.auart like 'ZOR%' " + _
        " and b.matnr in (select distinct matnr from saprdp.vbap where vbeln='" + CreditDocNo + "') " + _
        " order by a.erdat desc "
        Dim dtSONO = OraDbUtil.dbGetDataTable("SAP_PRD", sql)

        Dim dtSOList As New DataTable
        For Each soRow As DataRow In dtSONO.Rows
            Dim dtSODetail As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
                " select distinct a.vbeln as SO_NO, b.matnr as PART_NO, a.WAERK as CURRENCY, b.posnr AS LINE_NO, " + _
                " c.vbeln as INVOICE_NO, c.fkimg as INVOICE_QTY, b.netwr as TOTAL_PRICE, b.NETPR as UNIT_PRICE, " + _
                " b.KWMENG as ORDER_QTY, b.ZMENG as TARGET_QTY, a.erdat as ORDER_DATE, d.fkdat AS INVOICE_DATE  " + _
                " from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln  " + _
                " inner join saprdp.vbrp c on a.vbeln=c.aubel and b.posnr=c.posnr inner join saprdp.vbrk d on d.vbeln=c.vbeln  " + _
                " where a.mandt='168' and a.kunnr='" + CompanyId + "'  " + _
                " and a.auart like 'ZOR%' " + _
                " and d.fkdat>='" + CreditDocDate.AddMonths(PrevMonths * -1).ToString("yyyyMMdd") + "' and d.fkdat<='" + CreditDocDate.ToString("yyyyMMdd") + "' " + _
                " and a.vbeln='" + soRow.Item("SO_NO") + "' " + _
                " order by a.vbeln, b.posnr ")
            dtSOList.Merge(dtSODetail)
        Next

        Return dtSOList
    End Function

    Protected Sub lnkSalesOrders_Click(sender As Object, e As EventArgs)
        Dim lnkSalesOrders As LinkButton = CType(sender, LinkButton)
        Dim prevMonths As Integer = CInt(CType(lnkSalesOrders.NamingContainer.FindControl("dlPrevOrderMonth"), DropDownList).SelectedValue)
        Dim sono As String = CType(lnkSalesOrders.NamingContainer.FindControl("hdRowSONO"), HiddenField).Value
        Dim dt = GetSOByCreditDoc(hdERPID.Value, sono, prevMonths)
        Dim gvRowSOList As GridView = CType(lnkSalesOrders.NamingContainer.FindControl("gvRowSOList"), GridView)
        gvRowSOList.EmptyDataText = "No Data"
        gvRowSOList.DataSource = dt : gvRowSOList.DataBind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">    
    <asp:HiddenField runat="server" ID="hdERPID" />
    <table width="100%" style="border-color:#D7D0D0;border-width:1px;border-style:Solid;width:100%;border-collapse:collapse;">
        <tr style="color:Black;background-color:Gainsboro;">
            <td style="border: 1px solid #EBEBEB;">
                <table width="100%">
                    <tr style="background-color:#EBEBEB;">
                        <th align="left" style="width:20%">Company Name</th>
                        <td><asp:Label runat="server" ID="lbCustName" Font-Bold="true" /></td>
                    </tr>
                    <tr style="background-color:#EBEBEB;">
                        <th align="left" style="width:20%">Address</th>
                        <td><asp:Label runat="server" ID="lbAddr" /></td>
                    </tr>
                </table>                
            </td>
        </tr>
        <tr><td><hr /></td></tr>
        <tr>
            <td>
                <asp:GridView runat="server" ID="gvCustCredit" Width="100%" AutoGenerateColumns="false">
                    <Columns>
                        <asp:TemplateField HeaderText="Credit Control Area" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("CreditControlArea")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Currency" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("Currency")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Credit Limit" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("CreditLimit")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Credit Exposure" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("CreditExposure")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Credit Percentage" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("Percentage")%>%
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Receivables" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("Receivables")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Special Liability" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("SpecialLiability")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Sales Value" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <%#Eval("SalesValue")%>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </td>
        </tr>
        <tr><td><hr /></td></tr>
        <tr>
            <td>
                <h4>List of Credit Return & Memo Documents</h4>
                <asp:UpdatePanel runat="server" ID="upCreditList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:GridView runat="server" ID="gvCreditDocList" Width="100%" AutoGenerateColumns="false" 
                            OnRowDataBound="gvCreditDocList_RowDataBound" EmptyDataText="No Data">
                            <Columns>
                                <asp:TemplateField HeaderText="Doc. Info." ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="30%">
                                    <ItemTemplate>
                                        <table width="100%">
                                            <tr>
                                                <th align="left" style="width:30%">Doc. No.</th>
                                                <td>
                                                    <%#Util.RemovePrecedingZeros(Eval("SO_NO"))%>&nbsp;
                                                    (<%#IIf(Eval("ORDER_TYPE") = "G2", "Credit Memo", _
                                                        IIf(Eval("ORDER_TYPE") = "ZDR", "Debit Memo", _
                                                            IIf(Eval("ORDER_TYPE") = "ZRE1", "Sales Return", Eval("ORDER_TYPE"))))%>)
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left" style="width:30%">Created Date</th>
                                                <td>
                                                    <%#SAPDateToDateStr(Eval("CREATED_DATE"))%>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left" style="width:30%">Invoice Date</th>
                                                <td>
                                                    <%#SAPDateToDateStr(Eval("INVOICE_DATE"))%>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th align="left" style="width:30%">Total Amount</th>
                                                <td>
                                                    <%#Eval("CURRENCY")%>&nbsp;<%#Eval("TotalAmount")%><br />
                                                    $<%#Eval("TotalAmountUSD")%>
                                                </td>
                                            </tr>
                                        </table>
                                    </ItemTemplate>
                                </asp:TemplateField>                                
                                <asp:TemplateField HeaderText="Item List" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="30%" ItemStyle-VerticalAlign="Top">
                                    <ItemTemplate>
                                        <asp:HiddenField runat="server" ID="hdRowSONO" Value='<%#Eval("SO_NO")%>' />
                                        <asp:GridView runat="server" ID="gvRowItemList" Width="100%" AutoGenerateColumns="false">
                                            <Columns>
                                                <asp:TemplateField HeaderText="Part No." ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#Util.RemovePrecedingZeros(Eval("PART_NO"))%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Line No." ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#Util.RemovePrecedingZeros(Eval("LINE_NO"))%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Qty." ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <b>Target:</b><%#CInt(Eval("TARGET_QTY"))%><br />
                                                        <b>Order</b>:<%#CInt(Eval("ORDER_QTY"))%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Invoice No." ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#Util.RemovePrecedingZeros(Eval("INVOICE_NO"))%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:TemplateField HeaderText="Amount" ItemStyle-HorizontalAlign="Center">
                                                    <ItemTemplate>
                                                        <%#Eval("CURRENCY")%>&nbsp;<%#Eval("TOTAL_PRICE")%><br />
                                                        $<%#Eval("TOTAL_PRICE_USD")%>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Previous Sales Orders" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="40%" ItemStyle-VerticalAlign="Top">
                                    <ItemTemplate>                                        
                                        <asp:UpdatePanel runat="server" ID="upRowGvSO" UpdateMode="Conditional">
                                            <ContentTemplate>
                                                <table width="100%">
                                                    <tr>
                                                        <td align="center">
                                                            <table>
                                                                <tr>
                                                                    <td>
                                                                        Orders in past
                                                                    </td>
                                                                    <td>
                                                                        <asp:DropDownList runat="server" ID="dlPrevOrderMonth">
                                                                            <asp:ListItem Text="6 months" Selected="True" Value="6" />
                                                                            <asp:ListItem Text="1 year" Value="12" />
                                                                            <asp:ListItem Text="2 years" Value="24" />
                                                                            <asp:ListItem Text="3 years" Value="36" />
                                                                        </asp:DropDownList>
                                                                    </td>
                                                                    <td>
                                                                        <asp:LinkButton runat="server" ID="lnkSalesOrders" Text="Search" OnClick="lnkSalesOrders_Click" />
                                                                    </td>
                                                                </tr>
                                                            </table>                                                            
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:GridView runat="server" ID="gvRowSOList" Width="100%" AutoGenerateColumns="false">
                                                                <Columns>
                                                                    <asp:TemplateField HeaderText="SO No." ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <%#Util.RemovePrecedingZeros(Eval("SO_NO"))%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Order/Invoice Date" ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <b>Order:</b><%# SAPDateToDateStr(Eval("ORDER_DATE"))%><br />
                                                                            <b>Invoice:</b><%#SAPDateToDateStr(Eval("INVOICE_DATE"))%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Line No." ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <%#Util.RemovePrecedingZeros(Eval("LINE_NO"))%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Part No." ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <%#Util.RemovePrecedingZeros(Eval("PART_NO"))%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Total Price" ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <%#Eval("CURRENCY")%>&nbsp;<%#Eval("TOTAL_PRICE")%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Qty." ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <b>Order:</b><%#CInt(Eval("ORDER_QTY"))%><br />
                                                                            <b>Invoice:</b><%#CInt(Eval("INVOICE_QTY"))%>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                            </asp:GridView>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>