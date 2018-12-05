<%@ Page Language="VB" %>

<%@ Register Src="~/Includes/PITemplate/soldtoshipto.ascx" TagName="soldtoshipto"
    TagPrefix="uc1" %>
<%@ Register Src="~/Includes/PITemplate/OrderInfo.ascx" TagName="OrderInfo" TagPrefix="uc2" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    Dim myOrderMaster As New order_Master("b2b", "order_master"), myOrderDetail As New order_Detail("b2b", "order_detail")
    Dim myCompany As New SAP_Company("b2b", "sap_dimcompany"), myProduct As New SAPProduct("b2b", "sap_product")
    Dim isANA As Boolean = False
    Private CurrencySign As String = "", _OrderId As String = "", _IsInternalUserMode As Boolean = True
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(Request("NO")) AndAlso Request("NO") <> "" Then
            _OrderId = Request("NO")
            CurrencySign = MyOrderX.GetCurrencySign(_OrderId)
            If AuthUtil.IsUSAonlineSales(Session("user_id")) Then
                isANA = True
            End If
            If String.Equals(Session("org_id"), "US01") AndAlso Not String.Equals(Session("company_id"), "UZISCHE01") Then
                Me.trTax.Visible = True
            End If
            initInterface()
        End If
    End Sub
    Sub initInterface()
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
        Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Request("NO")), "line_no")
        If dtMaster.Rows.Count > 0 And dtDetail.Rows.Count > 0 Then

            'Sold to and ship to information
            Me.soldtoshiptoUC.OrderID = _OrderId
            'Order information
            Me.Orderinfo1.IsInternalUserMode = True : Me.Orderinfo1.OrderID = _OrderId

            '    Dim soldTo As String = dtMaster.Rows(0).Item("SOLDTO_ID")
            '    Dim shipTo As String = dtMaster.Rows(0).Item("SHIPTO_ID")
            '    Dim dtSoldTo As DataTable = myCompany.GetDT(String.Format("company_id='{0}'", soldTo), "")
            '    Dim dtshipTo As DataTable = myCompany.GetDT(String.Format("company_id='{0}'", shipTo), "")
            '    If dtSoldTo.Rows.Count > 0 And dtshipTo.Rows.Count > 0 Then
            '        Me.lbSoldName.Text = dtSoldTo.Rows(0).Item("company_name") & "(" & dtSoldTo.Rows(0).Item("company_id") & ")"
            '        Me.lbSoldAtt.Text = dtMaster.Rows(0).Item("Attention")
            '        Me.lbSoldAddr.Text = dtSoldTo.Rows(0).Item("Address")
            '        Me.lbSoldTel.Text = dtSoldTo.Rows(0).Item("tel_no")
            '        Me.lbSoldFax.Text = dtSoldTo.Rows(0).Item("fax_no")

            '        Me.lbShipName.Text = dtshipTo.Rows(0).Item("company_name") & "(" & dtshipTo.Rows(0).Item("company_id") & ")"
            '        Me.lbShipAtt.Text = dtMaster.Rows(0).Item("customer_Attention")
            '        Me.lbShipAddr.Text = dtshipTo.Rows(0).Item("Address")
            '        Me.lbShipTel.Text = dtshipTo.Rows(0).Item("tel_no")
            '        Me.lbShipFax.Text = dtshipTo.Rows(0).Item("fax_no")
            '    End If
            '    Me.lbPO.Text = dtMaster.Rows(0).Item("PO_NO")
            '    Dim SONO As String = ""
            '    If dtMaster.Rows(0).Item("ORDER_STATUS") <> "" Then
            '        SONO = dtMaster.Rows(0).Item("Order_ID")
            '    End If
            '    Me.lbSO.Text = SONO
            '    Me.lbOrderDate.Text = CDate(dtMaster.Rows(0).Item("Order_date")).ToString("yyyy/MM/dd")
            '    Me.lbPayTerm.Text = ""
            '    Me.lbReqdate.Text = CDate(dtMaster.Rows(0).Item("Required_date")).ToString("yyyy/MM/dd")
            '    Me.lbIncoterm.Text = dtMaster.Rows(0).Item("INCOTERM")
            '    Me.lbPlacedBy.Text = dtMaster.Rows(0).Item("CREATED_BY")
            '    Me.lbIncotermText.Text = dtMaster.Rows(0).Item("INCOTERM_TEXT")
            '    Me.lbFreight.Text = dtMaster.Rows(0).Item("FREIGHT")
            '    If Double.TryParse(Me.lbFreight.Text, 0) AndAlso CDbl(Me.lbFreight.Text) = 0 Then Me.lbFreight.Text = "TBD"
            '    Me.lbChannel.Text = ""
            '    Me.lbisPartial.Text = dtMaster.Rows(0).Item("PARTIAL_FLAG")
            '    Me.lbShipCond.Text = Glob.shipCode2Txt(dtMaster.Rows(0).Item("SHIP_CONDITION"))
            '    Me.lbOrderNote.Text = dtMaster.Rows(0).Item("ORDER_NOTE")
            '    Me.lbSalesNote.Text = dtMaster.Rows(0).Item("SALES_NOTE")
            '    Me.lbOPNote.Text = dtMaster.Rows(0).Item("OP_NOTE")
            '    'Me.lbPJNote.Text = dtMaster.Rows(0).Item("prj_Note")
        End If
        Me.gv1.DataSource = dtDetail
        Me.gv1.DataBind()
        'Me.trEUOPN.Visible = False
        'If Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
        '    Me.trEUOPN.Visible = True
        'End If
    End Sub

    Public Function getDescForPN(ByVal PN As String, ByVal Description As Object) As String
        If Not IsDBNull(Description) AndAlso Description IsNot Nothing AndAlso Not String.IsNullOrEmpty(Description.ToString.Trim) Then
            Return Description
        End If
        Dim DTSAPPRODUCT As DataTable = myProduct.GetDT(String.Format("part_no='{0}'", PN), "")
        If DTSAPPRODUCT.Rows.Count > 0 Then
            Return DTSAPPRODUCT.Rows(0).Item("Product_desc")
        End If
        Return ""
    End Function

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim total As Decimal = myOrderDetail.getTotalAmount(Request("NO"))
        Dim freight As Decimal = 0
        freight = getFreight()
        If freight > 0 Then
            Me.trFreight.Visible = True
            Me.lbFt.Text = freight
            'Me.lbFreight.Text = freight
        End If
        Dim taxA As Decimal = 0
        Dim taxR As Decimal = 0
        If Session("Org_Id") = "US01" AndAlso Util.IsInternalUser(Session("user_id")) Then
            taxA = Glob.GetTaxableAmount(Request("NO"), getShipTo)
            taxR = getTax()
        End If
        Me.lbtax.Text = IIf(taxR = 0, "N/A", FormatNumber(taxR, 4) * 100 & "%")

        If AuthUtil.IsBBUS Then
            taxA = 0 : taxR = 0
            Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = Request("NO")).FirstOrDefault()
            If MasterExtension IsNot Nothing AndAlso Decimal.TryParse(MasterExtension.OrderTaxRate, taxR) AndAlso MasterExtension.OrderTaxRate <> 0 Then
                taxR = MasterExtension.OrderTaxRate
                taxA = myOrderDetail.getTotalAmount(Request("NO"))

                trTax.Visible = True : lbtax.Text = taxA
            End If

            Me.TaxTitle.InnerText = "Tax：" + CurrencySign
            Me.lbtax.Text = Decimal.Round(taxA * taxR, 2, MidpointRounding.AwayFromZero)
        End If

        Me.lbTotal.Text = FormatNumber(total + freight + (taxA * taxR), 2)
    End Sub
    Function getShipTo() As String
        Dim myMastapt As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        Dim myMast As New MyOrderDS.ORDER_MASTERDataTable
        myMast = myMastapt.GetOrderMasterByOrderID(Request("NO"))
        Dim myOPartnerApt As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        Dim strShiptoId As String = ""
        Dim OPartner As MyOrderDS.ORDER_PARTNERSDataTable
        OPartner = myOPartnerApt.GetPartnerByOrderIDAndType(Request("NO"), "S")
        If OPartner.Count = 0 Then
            strShiptoId = myMast(0).Item("SOLDTO_ID")
        Else
            strShiptoId = OPartner(0).ERPID
        End If
        Return strShiptoId
    End Function
    Function getTax() As String
        Dim taxr As Decimal = 0
        Dim myMastapt As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        Dim myMast As New MyOrderDS.ORDER_MASTERDataTable
        myMast = myMastapt.GetOrderMasterByOrderID(Request("NO"))
        If myMast.Rows.Count > 0 Then
            If myMast(0).isExempt = 0 Then
                Dim _txtTempZipCode As String = SAPDAL.SAPDAL.getUSZipcodeByShipToID(getShipTo())
                If Not String.IsNullOrEmpty(_txtTempZipCode) Then
                    taxr = SAPDAL.SAPDAL.getSalesTaxByZIP(_txtTempZipCode)
                End If
            End If
        End If
        Return taxr
    End Function
    Protected Function getFreight() As Decimal
        Dim v As Decimal = 0
        Dim myFT As New Freight("MY", "FREIGHT")
        Dim DT As New DataTable
        DT = myFT.GetDT(String.Format("order_id='{0}'", Request("NO")), "")
        If DT.Rows.Count > 0 Then
            For Each X As DataRow In DT.Rows
                If X.Item("FTYPE") = "ZHDA" Then
                    v = v - 0
                Else
                    v = v + X.Item("FVALUE")
                End If
            Next
        End If
        Return v
    End Function

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim DBITEM As DataRowView = CType(e.Row.DataItem, DataRowView)
            If DBITEM.Item("EXWARRANTY_FLAG") = 99 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "36"
            End If
            If DBITEM.Item("EXWARRANTY_FLAG") = 999 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "3"
            End If
            Dim dueDate As String = Now.Date
            dueDate = IIf(CDate(DBITEM.Item("due_date")).ToString("yyyy/MM/dd") = "1900/01/01", "TBD", IIf(isANA, CDate(DBITEM.Item("due_date")).ToString("MM/dd/yyyy"), CDate(DBITEM.Item("due_date")).ToString("yyyy/MM/dd")))
            If Not DBITEM.Item("part_no").ToString.StartsWith("AGS-") And myOrderDetail.isBtoParentItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) = 0 And DBITEM.Item("NOATPFLAG") = 0 And dueDate <> "TBD" Then
                e.Row.Cells(5).Text = "<font color='#FF0000'>For Reference Only</font>" & "<br/>" & dueDate
            End If

            If myOrderDetail.isBtoParentItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) = 1 And myOrderDetail.isBtoNotSatisfy(Request("NO")) = 1 Then
                e.Row.Cells(5).Text = "<font color='#FF0000'>For Reference Only</font>" & "<br/>" & dueDate
            End If

            If myOrderDetail.isBtoChildItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) Then
                e.Row.Cells(5).Text = ""
                e.Row.Cells(6).Text = ""
                e.Row.Cells(9).Text = ""
                e.Row.Cells(10).Text = ""
            End If
            If myOrderDetail.isBtoParentItem(Request("NO"), Me.gv1.DataKeys(e.Row.RowIndex).Value) Then
                If Util.IsTestingQuote2Order() AndAlso DBITEM.Item("Line_No") IsNot Nothing Then
                    Dim SubTotal As Decimal = myOrderDetail.getTotalAmountV2(Request("NO"), DBITEM.Item("Line_No").ToString)
                    ' e.Row.Cells(9).Text = Session("company_currency_sign") & FormatNumber(myOrderDetail.getTotalPriceV2(Request("NO"), DBITEM.Item("Line_No").ToString), 2)
                    e.Row.Cells(10).Text = CurrencySign & FormatNumber(SubTotal, 2)
                    If DBITEM.Item("qty") IsNot Nothing AndAlso Integer.TryParse(DBITEM.Item("qty"), 0) AndAlso Integer.Parse(DBITEM.Item("qty")) > 0 Then
                        e.Row.Cells(9).Text = CurrencySign & FormatNumber(SubTotal / Integer.Parse(DBITEM.Item("qty").ToString), 2)
                    End If
                Else
                    e.Row.Cells(9).Text = CurrencySign & FormatNumber(myOrderDetail.getTotalPrice(Request("NO")), 2)
                    e.Row.Cells(10).Text = CurrencySign & FormatNumber(myOrderDetail.getTotalAmount(Request("NO")), 2)
                End If
            End If

            ''Alex 20160726: add remind message when BTOS Part is added manually
            Dim _Cart2OrderMaping As Cart2OrderMaping = MyUtil.Current.MyAContext.Cart2OrderMapings.Where(Function(p) p.OrderNo = _OrderId OrElse p.OrderID = _OrderId).FirstOrDefault()
            If _Cart2OrderMaping IsNot Nothing Then
                If DBITEM.Item("ORDER_LINE_TYPE") = 1 And MyCartBtosManual.InCartBtosManual(_Cart2OrderMaping.CartID, DBITEM.Item("part_no")) And HttpContext.Current.Session("org_id") = "TW01" Then
                    e.Row.Cells(2).Text = DBITEM.Item("part_no") & "<br/>" & "<font color='#FF0000'>(Add Manually)</font>"
                End If
            End If


        End If
        If Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            If e.Row.RowType = DataControlRowType.Header Then
                CType(e.Row.FindControl("lbHDueDate"), Label).Text = "Available Date"
                CType(e.Row.FindControl("lbHReqDate"), Label).Text = "Req deliv date"
            End If
            If e.Row.RowType <> DataControlRowType.EmptyDataRow Then
                e.Row.Cells(7).Visible = False
            End If

            'Ryan 20170710 Hide cell 5 (due date column for US01 per Jay's request.)
            e.Row.Cells(5).Visible = False
        End If

        'Ryan 20170329 AJP特例，AJP不需使用CPN，欄位實際上儲存的是cust_po_no
        If e.Row.RowType = DataControlRowType.Header Then
            If Session("org_id").ToString.Trim.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                e.Row.Cells(3).Text = "Customer PO No."
            End If
        End If

    End Sub
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        .mytable table
        {
            border-collapse: collapse;
        }
        
        .mytable tr td
        {
            background: #ffffff;
            border: #cccccc 1px solid;
            padding: 2px;
            font-family: Arial;
            font-size:12px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    .
    <div id="divHeader">
        <table>
            <tr>
                <td>
                    <img src="/images/header_advantech_logo.gif" alt="Advantech"/>
                </td>
            </tr>
        </table>
    </div>
    <div id="divCustInfo" class="mytable">
        <br />
        <uc1:soldtoshipto runat="server" ID="soldtoshiptoUC" Visible="true" />
<%--        <table width="100%">
            <tr>
                <td style="background-color: #ededed; font-weight: bold">
                    Customer Information
                </td>
            </tr>
            <tr>
                <td style="text-align: center">
                    Customer Information
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%">
                        <tr>
                            <td>
                                Customer
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbSoldName"></asp:Label>
                            </td>
                            <td>
                                Attention
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbSoldAtt"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td rowspan="2">
                                Address
                            </td>
                            <td rowspan="2">
                                <asp:Label runat="server" ID="lbSoldAddr"></asp:Label>
                            </td>
                            <td>
                                Tel No.
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbSoldTel"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Fax No.
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbSoldFax"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="text-align: center">
                    Shipping Information
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%">
                        <tr>
                            <td>
                                Customer
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbShipName"></asp:Label>
                            </td>
                            <td>
                                Attention
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbShipAtt"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td rowspan="2">
                                Address
                            </td>
                            <td rowspan="2">
                                <asp:Label runat="server" ID="lbShipAddr"></asp:Label>
                            </td>
                            <td>
                                Tel No.
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbShipTel"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                Fax No.
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbShipFax"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                </td>
            </tr>
        </table>--%>
    </div>
    <div id="divOrderInfo" class="mytable">
        <br />
        <uc2:OrderInfo runat="server" ID="Orderinfo1" Visible="true" />
<%--        <table width="100%">
            <tr>
                <td style="background-color: #ededed; font-weight: bold">
                    Order Information
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%">
                        <tr>
                            <td>
                                PO No.
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbPO"></asp:Label>
                            </td>
                            <td>
                                Advantech SO
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
                                Channel
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
                        <tr>
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
                        <tr>
                            <td>
                                Project Note
                            </td>
                            <td colspan="3">
                                <asp:Label runat="server" ID="lbPJNote"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>--%>
    </div>
    <div id="divDetailInfo" class="mytable">
        <br />
        <table width="100%">
            <tr>
                <td style="background-color: #ededed; font-weight: bold">
                    Purchased Products
                </td>
            </tr>
            <tr>
                <td>
                    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="false"
                        AllowSorting="true" Width="100%" EmptyDataText="No Order Line." DataKeyNames="line_no" OnDataBound="gv1_DataBound" OnRowDataBound="gv1_RowDataBound">
                        <Columns>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Seq.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Container.DataItemIndex + 1 %>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Line No.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Line_no")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    Product
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Part_no")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    Customer P/N
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("CustMaterialNo")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    Description
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# getDescForPN(Eval("PART_NO"), Eval("Description"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    <asp:Label runat="server" ID="lbHDueDate">Due Date</asp:Label>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# IIf(CDate(Eval("due_date")).ToString("yyyy/MM/dd") = "1900/01/01", "TBD", IIf(isANA, CDate(Eval("due_date")).ToString("MM/dd/yyyy"), CDate(Eval("due_date")).ToString("yyyy/MM/dd")))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="left">
                                <HeaderTemplate>
                                    <asp:Label runat="server" ID="lbHReqDate"> Required Date </asp:Label>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# IIf(isANA, CDate(Eval("required_date")).ToString("MM/dd/yyyy"), CDate(Eval("required_date")).ToString("yyyy/MM/dd"))%>
                                </ItemTemplate>
                            </asp:TemplateField>
                          <%--  <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Sales Leads from Advantech (DMF)
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("DMF_Flag")%>
                                </ItemTemplate>
                            </asp:TemplateField>--%>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Extended Warranty Months
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lbew" Text='<%#Bind("EXWARRANTY_FLAG") %>'></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Qty.
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <%# Eval("Qty")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Price
                                </HeaderTemplate>
                                <ItemTemplate>
                                     <asp:Label runat="server" Text='<%# CurrencySign%>' ID="lbUnitPriceSign"></asp:Label> <%# FormatNumber(Eval("Unit_price"), 2)%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Sub Total
                                </HeaderTemplate>
                                <ItemTemplate>
                                     <asp:Label runat="server" Text='<%# CurrencySign%>' ID="lbSubTotalSign"></asp:Label> <%# FormatNumber(Eval("Unit_price") * Eval("Qty"), 2)%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </td>
            </tr>
            <tr>
                <td align="right" runat="server" id="trFreight" visible="false">
                    Freight：<%= CurrencySign%>
                    <asp:Label runat="server" ID="lbFt"></asp:Label>
                </td>
            </tr>
            <tr>
                <td align="right" runat="server" id="trTax" visible="false"> 
                    <span id="TaxTitle" runat="server">Tax Rate：</span>
                    <asp:Label runat="server" ID="lbtax"></asp:Label>
                </td>
            </tr>
            <tr>
                <td align="right"> 
                    Total：<%= CurrencySign%>
                    <asp:Label runat="server" ID="lbTotal"></asp:Label>
                </td>
            </tr>
        </table>
    </div>
    <div id="divFooter">
        <br />
    </div>
    .
    </form>
</body>
</html>
