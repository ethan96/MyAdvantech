<%@ Control Language="VB" ClassName="Order_Info" %>
<%@ Import Namespace="MyOrderDS" %>
<%@ Import Namespace="MyOrderDSTableAdapters" %>
<script runat="server">
    Private _orderid As String, _QuoteID As String, _IsInternalUserMode As Boolean = True ', _TimeSpan As TimeSpan
    Public Property OrderID As String
        Get
            Return _orderid
        End Get
        Set(value As String)
            _orderid = value
        End Set
    End Property
    Public Property QuoteID As String
        Get
            Return _QuoteID
        End Get
        Set(ByVal value As String)
            _QuoteID = value
        End Set
    End Property

    Public Property IsInternalUserMode As Boolean
        Get
            Return _IsInternalUserMode
        End Get
        Set(value As Boolean)
            _IsInternalUserMode = value
        End Set
    End Property


    Public Shared Function GetPaymentMethodNameByValue(ByVal PaymentMethodValue As String) As String
        'If PaymentMethodValue.Equals("0") Then Return "TBD"
        Dim retObj As Object = Nothing
        Dim cmd As New SqlClient.SqlCommand("select top 1 PAYMENTTERMNAME from SAP_COMPANY_LOV where PAYMENTTERM=@SV",
                                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("SV", PaymentMethodValue)
        cmd.Connection.Open() : retObj = cmd.ExecuteScalar() : cmd.Connection.Close()
        If retObj IsNot Nothing Then
            Return retObj.ToString()
        End If
        Return PaymentMethodValue
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then

            Me.trEUOPN.Visible = False
            If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
                Me.trEUOPN.Visible = True
            End If

            If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                Me.trOrderNote.Visible = False
                Me.trSalesNote.Visible = True
                Me.trACN.Visible = True

                Dim OPTA As New ORDER_PARTNERSTableAdapter
                Dim OPTB As ORDER_PARTNERSDataTable = OPTA.GetPartnersByOrderID(Me.OrderID)
                If OPTB IsNot Nothing AndAlso OPTB.Rows.Count > 0 Then
                    For Each d As ORDER_PARTNERSRow In OPTB.Rows
                        If CType(d, ORDER_PARTNERSRow).TYPE.ToUpper.Equals("E") Then
                            Me.lbSalesCode.Text = CType(d, ORDER_PARTNERSRow).ERPID
                        ElseIf CType(d, ORDER_PARTNERSRow).TYPE.ToUpper.Equals("EM") Then
                            Me.lbEndCustomerName.Text = CType(d, ORDER_PARTNERSRow).NAME + " (" + CType(d, ORDER_PARTNERSRow).ERPID + ")"
                        End If
                    Next
                End If
            End If

            'Ryan 20170524 Show sales note for ACN
            If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.StartsWith("CN", StringComparison.OrdinalIgnoreCase) Then
                Me.trSalesNote.Visible = True
                Me.trACN.Visible = True

                Dim OPTA As New ORDER_PARTNERSTableAdapter
                Dim OPTB As ORDER_PARTNERSDataTable = OPTA.GetPartnersByOrderID(Me.OrderID)
                If OPTB IsNot Nothing AndAlso OPTB.Rows.Count > 0 Then
                    For Each d As ORDER_PARTNERSRow In OPTB.Rows
                        If CType(d, ORDER_PARTNERSRow).TYPE.ToUpper.Equals("E") Then
                            Me.lbSalesCode.Text = CType(d, ORDER_PARTNERSRow).ERPID
                        ElseIf CType(d, ORDER_PARTNERSRow).TYPE.ToUpper.Equals("EM") Then
                            Me.lbEndCustomerName.Text = CType(d, ORDER_PARTNERSRow).NAME
                        End If
                    Next
                End If
            End If

            'Frank 2012/10/18: Do not show Partial flag if it's US Aonline order
            If AuthUtil.IsUSAonlineOrderNo(OrderID) OrElse AuthUtil.IsUSAonlineSales(Session("user")) Then Me.trPartial.Visible = False

            If Not String.IsNullOrEmpty(OrderID) Then
                Dim OMta As New ORDER_MASTERTableAdapter, ODta As New ORDER_DETAILTableAdapter, OPta As New ORDER_PARTNERSTableAdapter
                Dim OMdt As ORDER_MASTERDataTable = OMta.GetOrderMasterByOrderID(Me.OrderID)
                Dim ODdt As ORDER_DETAILDataTable = ODta.GetOrderDetailByOrderID(Me.OrderID)
                If OMdt.Count > 0 Then
                    Dim dr As ORDER_MASTERRow = OMdt.Rows(0)
                    With dr
                        Me.lbPO.Text = .PO_NO
                        Dim SONO As String = ""
                        If .ORDER_STATUS <> "" Then
                            SONO = .ORDER_ID
                        End If

                        'Frank 2012/08/09:Do not change the ORDER_DATE to local time because ORDER_DATE already saved in local time
                        Me.lbOrderDate.Text = CDate(.ORDER_DATE).ToString("MM/dd/yyyy")
                        Me.lbPayTerm.Text = GetPaymentMethodNameByValue(.PAYTERM)
                        'Frank 2012/08/09:Do not change the REQUIRED_DATE to local time because REQUIRED_DATE already saved in local time
                        If Date.TryParse(.REQUIRED_DATE, Now) Then
                            Me.lbReqdate.Text = CDate(.REQUIRED_DATE).ToString("MM/dd/yyyy")
                            lbRequestDate.Text = Me.lbReqdate.Text
                        End If
                        Me.lbIncoterm.Text = Util.GetIncotermName(.INCOTERM) + " " + .INCOTERM_TEXT
                        Me.lbPlacedBy.Text = .CREATED_BY
                        'Me.lbIncotermText.Text = .INCOTERM_TEXT
                        Me.lbFreight.Text = .FREIGHT

                        'Ryan 20171019 Get Freight for BBUS
                        Dim objBBFreight As Object = dbUtil.dbExecuteScalar("MY", String.Format("select fvalue from FREIGHT where order_id = '{0}' and ftype = 'ZHD0'", .ORDER_ID))
                        If objBBFreight IsNot Nothing AndAlso Not String.IsNullOrEmpty(objBBFreight.ToString) AndAlso Double.TryParse(objBBFreight.ToString, 0) Then
                            Me.lbFreight.Text = objBBFreight.ToString
                        End If

                        'Me.lbSalesRep.Text = SAPDAL.SAPDAL.GetSalesRepresentativeByEmployeeID(.EMPLOYEEID, .CREATED_BY)
                        Dim OPdt As ORDER_PARTNERSDataTable = OPta.GetPartnerByOrderIDAndType(Me.OrderID, "E"), Sales_Code As String = String.Empty
                        If OPdt.Count > 0 Then Sales_Code = CType(OPdt.Rows(0), ORDER_PARTNERSRow).ERPID
                        Me.lbSalesRep.Text = SAPDAL.SAPDAL.GetSalesRepresentativeByEmployeeID(Sales_Code, .CREATED_BY)

                        If Double.TryParse(Me.lbFreight.Text, 0) AndAlso CDbl(Me.lbFreight.Text) = 0 Then Me.lbFreight.Text = "TBD"
                        'Me.lbChannel.Text = .DIST_CHAN
                        If CInt(.PARTIAL_FLAG) = 1 Then
                            Me.lbisPartial.Text = "Yes"
                        ElseIf CInt(.PARTIAL_FLAG) = 0 Then
                            Me.lbisPartial.Text = "No"
                        End If
                        Me.lbShipCond.Text = Glob.shipCode2Txt(.SHIP_CONDITION)
                        Me.lbOrderNote.Text = .ORDER_NOTE
                        Me.lbSalesNote.Text = .SALES_NOTE
                        Me.lbOPNote.Text = .OP_NOTE
                    End With
                End If

                If ODdt.Count > 0 Then
                    Dim _OMrow As ORDER_DETAILRow = ODdt.Rows(0)
                    If _OMrow.OptyID IsNot Nothing Then
                        Me.lbSO.Text = _OMrow.OptyID
                        Me.QuoteID = _OMrow.OptyID
                        If Not String.IsNullOrEmpty(_OMrow.OptyID) Then
                            Dim _QuotationMaster As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(_OMrow.OptyID)
                            If _QuotationMaster IsNot Nothing AndAlso _QuotationMaster.quoteNo IsNot Nothing AndAlso Not String.IsNullOrEmpty(_QuotationMaster.quoteNo) Then
                                Me.lbSO.Text = _QuotationMaster.quoteNo
                            End If
                        End If
                    End If
                End If


            End If
        End If
    End Sub
</script>
<div id="divOrderInfo" class="mytable">
    <div class="bk5">
    </div>
    <table width="100%">
        <tr>
            <td style="background-color: #ededed; font-weight: bold" colspan="4">
                Order Information
            </td>
        </tr>
        <tr>
            <td>
                PO No:
            </td>
            <td>
                <asp:Label runat="server" ID="lbPO"/>
            </td>
            <td>
                <asp:Literal runat="server" ID="litSO">Advantech Quote No:</asp:Literal>
            </td>
            <td>
                <asp:Label runat="server" ID="lbSO"/>
            </td>
        </tr>
        <tr>
            <td>
                Required Date:
            </td>
            <td>
                <asp:Label runat="server" ID="lbRequestDate"/>
            </td>
            <td>
                Payment Term:
            </td>
            <td>
                <asp:Label runat="server" ID="lbPayTerm"/>
            </td>
        </tr>
        <tr>
            <td>
                Placed By:
            </td>
            <td>
                <asp:Label runat="server" ID="lbPlacedBy"/>
            </td>
            <td>
                Incoterm:
            </td>
            <td>
                <asp:Label runat="server" ID="lbIncoterm"/>
            </td>
        </tr>
        <tr>
            <td>
                Freight:
            </td>
            <td>
                <asp:Label runat="server" ID="lbFreight"/>
            </td>

            <td>
                <asp:Label runat="server" ID="lbSalesRepTitle">Sales Representative:</asp:Label>
            </td>
            <td>
                <asp:Label runat="server" ID="lbSalesRep"/>
            </td>
        </tr>
        <tr id="trACN" runat="server" visible="false">
            <td>
                End Customer:
            </td>
            <td>
                <asp:Label runat="server" ID="lbEndCustomerName"/>
            </td>
            <td>
                Sales Code:
            </td>
            <td>
                <asp:Label runat="server" ID="lbSalesCode"/>
            </td>
        </tr>
        <tr id="trPartial" runat="server" visible="true">
            <td>
                Partial OK:
            </td>
            <td>
                <asp:Label runat="server" ID="lbisPartial"/>
            </td>
              <td>
                   Order Date:
            </td>
            <td>
                <asp:Label runat="server" ID="lbOrderDate"/>
            </td>
        </tr>
        <tr id="trOrderNote" runat="server">
            <td>
                Order Note (External Note):
            </td>
            <td colspan="3">
                <asp:Label runat="server" ID="lbOrderNote"/>
            </td>
<%--            <td>
                <asp:Label runat="server" ID="LabelChannelTitle" Visible="false">Channel:</asp:Label>
            </td>
            <td>
                <asp:Label runat="server" ID="lbChannel" Visible="false"></asp:Label>
            </td>
--%>        </tr>
<%--        <tr id="trPartial" runat="server" visible="false">
            <td>
                Partial OK:
            </td>
            <td>
                <asp:Label runat="server" ID="lbisPartial"></asp:Label>
            </td>
            <td>
                Incoterm Text:
            </td>
            <td>
                <asp:Label runat="server" ID="lbIncotermText"></asp:Label>
            </td>
        </tr>
--%>        <tr id="trReqdate" runat="server" visible="false">
            <td>
                Required Date:
            </td>
            <td>
                <asp:Label runat="server" ID="lbReqdate"/>
            </td>
            <td>
                <asp:Label runat="server" ID="LabelShipCondition" Visible="false">Ship Condition:</asp:Label>
            </td>
            <td>
                <asp:Label runat="server" ID="lbShipCond" Visible="false"/>
            </td>
        </tr>
        <tr id="trSalesNote" runat="server" visible="false">
            <td>
                Sales Note From Customer:
            </td>
            <td colspan="3">
                <asp:Label runat="server" ID="lbSalesNote"/>
            </td>
        </tr>
        <tr id="trEUOPN" runat="server">
            <td>
                EU OP Note:
            </td>
            <td colspan="3">
                <asp:Label runat="server" ID="lbOPNote"/>
            </td>
        </tr>
    </table>
    <%--    <table width="100%">
        <tr>
            <td style="background-color: #ededed; font-weight: bold" colspan="4">
                Order Information
            </td>
        </tr>
        <tr>
            <td>
                PO No.
            </td>
            <td>
                <asp:Label runat="server" ID="lbPO"></asp:Label>
            </td>
            <td>
                <asp:Literal runat="server" ID="litSO"> Advantech Quote No.</asp:Literal>
            </td>
            <td>
                <asp:Label runat="server" ID="lbSO"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Order Date
            </td>
            <td>
                <asp:Label runat="server" ID="lbOrderDate"></asp:Label>
            </td>
            <td>
                Payment Term
            </td>
            <td>
                <asp:Label runat="server" ID="lbPayTerm"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Required Date
            </td>
            <td>
                <asp:Label runat="server" ID="lbReqdate"></asp:Label>
            </td>
            <td>
                Incoterm
            </td>
            <td>
                <asp:Label runat="server" ID="lbIncoterm"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Placed By
            </td>
            <td>
                <asp:Label runat="server" ID="lbPlacedBy"></asp:Label>
            </td>
            <td>
                Incoterm Text
            </td>
            <td>
                <asp:Label runat="server" ID="lbIncotermText"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Freight
            </td>
            <td>
                <asp:Label runat="server" ID="lbFreight"></asp:Label>
            </td>
            <td>
                <asp:Label runat="server" ID="LabelChannelTitle">Channel</asp:Label>
            </td>
            <td>
                <asp:Label runat="server" ID="lbChannel"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Partial OK
            </td>
            <td>
                <asp:Label runat="server" ID="lbisPartial"></asp:Label>
            </td>
            <td>
                Ship Condition
            </td>
            <td>
                <asp:Label runat="server" ID="lbShipCond"></asp:Label>
            </td>
        </tr>
        <tr>
            <td>
                Order Note (External Note)
            </td>
            <td colspan="3">
                <asp:Label runat="server" ID="lbOrderNote"></asp:Label>
            </td>
        </tr>
        <tr id="trSalesNote" runat="server">
            <td>
                Sales Note From Customer
            </td>
            <td colspan="3">
                <asp:Label runat="server" ID="lbSalesNote"></asp:Label>
            </td>
        </tr>
        <tr id="trEUOPN" runat="server">
            <td>
                EU OP Note
            </td>
            <td colspan="3">
                <asp:Label runat="server" ID="lbOPNote"></asp:Label>
            </td>
        </tr>
    </table>--%>
</div>
