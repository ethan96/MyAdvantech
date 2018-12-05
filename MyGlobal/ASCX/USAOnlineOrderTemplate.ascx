<%@ Control Language="VB" ClassName="USAOnlineOrderTemplate" %>
<%@ Register Src="~/Includes/PITemplate/soldtoshipto.ascx" TagName="soldtoshipto"
    TagPrefix="uc1" %>
<%@ Register Src="~/Includes/PITemplate/OrderInfo.ascx" TagName="OrderInfo" TagPrefix="uc2" %>
<script runat="server">
        
    Private _currencySign As String = "", _OrderId As String = "", _IsInternalUserMode As Boolean = True, _IsBtosOrder As Boolean = False
    'Sold to
    'Private _lbSoldtoCompany As String = "", _lbSoldtoAddr As String, _lbSoldtoTel As String, _lbSoldtoMobile As String = "", _lbSoldtoAttention As String
    'Ship to
    'Private _lbShiptoCompany As String = "", _lbShiptoAddr As String, _lbShiptoTel As String, _lbShiptoMobile As String = "", _lbShiptoAttention As String, _lbShiptoCO As String = ""
    'Bill to
    Private _lbBilltoCompany As String = "", _lbBilltoAddr As String, _lbBilltoTel As String, _lbBilltoMobile As String = "", _lbBilltoAttention As String
    Private _SalesPerson As String, _lbExternalNote As String = "", _IsLumpSumOnly As Boolean = False, _RunTimeURL As String = Util.GetRuntimeSiteUrl
    Private _QuoteID As String = "", _QuotMaster As New DataSet, _pri_format As EnumSetting.USPrintOutFormat = EnumSetting.USPrintOutFormat.SUB_ITEM_WITH_SUB_ITEM_PRICE
    Private _IsFoucePrintFormat As Boolean = False
    'Private _TimeSpan As TimeSpan
    Public Property currencySign As String
        Get
            Return _currencySign
        End Get
        Set(value As String)
            _currencySign = value
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

    Public Property PrintFormat As EnumSetting.USPrintOutFormat
        Get
            Return _pri_format
        End Get
        Set(value As EnumSetting.USPrintOutFormat)
            If value = -1 Then
                _IsFoucePrintFormat = False
            Else
                _pri_format = value
                _IsFoucePrintFormat = True
            End If
        End Set
    End Property

    
    Public Property OrderId As String
        Get
            Return _OrderId
        End Get
        Set(value As String)
            _OrderId = value
        End Set
    End Property
    
    Dim aptOM As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter, aptOD As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
    Public Sub LoadData()
        'Frank 20120809:Get AUS time span
        'Me._TimeSpan = Util.GetTimeSpan("AUS")
        Dim dtM As MyOrderDS.ORDER_MASTERDataTable = aptOM.GetOrderMasterByOrderID(_OrderId)
        Dim dtDetail As MyOrderDS.ORDER_DETAILDataTable = aptOD.GetOrderDetailByOrderID(_OrderId)
        If aptOD.isBtosOrder(_OrderId) > 0 Then _IsBtosOrder = True
        If dtM.Count > 0 Then
            'Frank?
            _currencySign = Util.GET_CurrSign_By_Curr(dtM(0).CURRENCY)
            FillQuoteInfo(dtM(0), dtDetail) : initGV(dtDetail)
            SetColumnVisible()
        End If
    End Sub

    
    ' ''' <summary>
    ' ''' Showing up the office information by SaleOffice
    ' ''' </summary>
    ' ''' <param name="_SALESOFFICE"></param>
    ' ''' <remarks></remarks>
    'Private Sub SetOfficeInformation(ByVal _SALESOFFICE As String)
    '    If _SALESOFFICE Is Nothing Then _SALESOFFICE = ""
    '    Me.officeInformation_USA.Visible = False : Me.officeInformation_2410.Visible = False
    '    Select Case _SALESOFFICE
    '        Case "2410"
    '            Me.officeInformation_2410.Visible = True
    '        Case Else
    '            Me.officeInformation_USA.Visible = True
                
    '    End Select
    'End Sub
    
    Private Function GetSalesEmail(ByVal Sales_CODE As String) As String
        If String.IsNullOrEmpty(Sales_CODE) Then Return ""
        
        Dim retObj As Object = Nothing
        Dim cmd As New SqlClient.SqlCommand("select EMAIL From SAP_EMPLOYEE Where SALES_CODE=@SC", _
                                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("SC", Sales_CODE)
        cmd.Connection.Open() : retObj = cmd.ExecuteScalar : cmd.Connection.Close()
        If retObj IsNot Nothing Then
            Return retObj.ToString()
        End If
        
        Return ""

        
    End Function
    
    Protected Sub FillQuoteInfo(ByRef OrderMasterRow As MyOrderDS.ORDER_MASTERRow, ByRef OrderDetailTb As MyOrderDS.ORDER_DETAILDataTable)
        Dim decSubTotal As Decimal = aptOD.getTotalAmount(_OrderId)
        If OrderDetailTb.Count > 0 Then
            With OrderMasterRow
                'Frank 2012/07/16:Showing up the office information by SaleOffice
                'Me.SetOfficeInformation(.SALESOFFICE) : Me.LabelQuoteID.Text = .ORDER_ID
                Me.LabelOrderID.Text = .ORDER_ID
                'Frank 2012/08/09:Do not change the ORDER_DATE to local time 
                Me.ORDER_DATE.Text = .ORDER_DATE.ToString("MM/dd/yyyy")
                
                
                'Getting sold to, ship to and bill to data from [eQuotation].[dbo].[EQPARTNER]
                Me.soldtoshiptoUC.OrderID = _OrderId
                
                'Dim apt As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
                'Dim BillToTable As MyOrderDS.ORDER_PARTNERSDataTable = apt.GetPartnerByOrderIDAndType(_OrderId, "B")
                'If BillToTable.Count > 0 Then
                '    Dim BillToRow As MyOrderDS.ORDER_PARTNERSRow = BillToTable(0)
                '    Me._lbBilltoCompany = BillToRow.NAME
                '    If Not String.IsNullOrEmpty(BillToRow.ERPID) Then lblBillToERPID.Text = "<span style='background-color:#EFF580; font-weight:bold'>&nbsp;" + BillToRow.ERPID + "&nbsp;</span>"
                '    Me._lbBilltoAddr = BillToRow.ADDRESS : Me._lbBilltoTel = BillToRow.TEL
                '    Me._lbBilltoMobile = BillToRow.MOBILE : Me._lbBilltoAttention = BillToRow.ATTENTION
                'End If
                
                'Order information
                Me.Orderinfo1.IsInternalUserMode = Me._IsInternalUserMode
                Me.Orderinfo1.OrderID = _OrderId
                
                'Frank 2012/08/03：please do not remove below code.
                'Dim _salesEmail As String = Me.GetSalesEmail(.EMPLOYEEID)
                'If _salesEmail IsNot DBNull.Value AndAlso Not String.IsNullOrEmpty(_salesEmail) Then
                '    lblSalesPerson.Text = "Sales Representative: "
                '    Dim email_name As String = _salesEmail.ToString.Split("@")(0)
                '    If email_name.Contains(".") Then
                '        For Each name As String In email_name.Split(".")
                '            lblSalesPerson.Text += name.Substring(0, 1).ToUpper() + name.Substring(1, name.Length - 1).ToLower + " "
                '        Next
                '    Else
                '        lblSalesPerson.Text += email_name.Substring(0, 1).ToUpper() + email_name.Substring(1, email_name.Length - 1).ToLower
                '    End If
                'End If
                
                'Me.expiredDate.Text = .expiredDate.ToString("MM/dd/yyyy")
                'Me.shipTerm.Text = Me.GetShipMethodNameByValue(.SHIPMENT_TERM)
                'If Me.shipTerm.Text = "0" Then Me.shipTerm.Text = "TBD"
                
                ''payment Term
                'Me.paymentTerm.Text = Me.GetPaymentMethodNameByValue(.PAYTERM)
                'If Me.paymentTerm.Text = "0" Then Me.paymentTerm.Text = "TBD"
                
                'Me.freight.Text = IIf(IsDBNull(.FREIGHT) Or .FREIGHT = 0, "TBD", .FREIGHT.ToString())
                'Me.tax.Text = .tax.ToString()
                '20120711 TC: Use TBD first before we know how to calculate TAX
                If Double.TryParse(Me.tax.Text, 0) = False OrElse CDbl(Me.tax.Text) = 0 Then
                    Me.tax.Text = "TBD"
                End If
             
                
                Me.lbSubTotal.Text = _currencySign + FormatNumber(decSubTotal, 2)
                Dim t As Decimal = decSubTotal.ToString()
                'Me.lbTotal.Text = (decSubTotal + .FREIGHT + .tax).ToString()
                Me.lbTotal.Text = _currencySign + FormatNumber(decSubTotal + .FREIGHT, 2)
                'Me.freight.Text = "TBD"
                Me.tax.Text = "TBD"
                'Me.lbTaxRate.Text = "0"
                'If t <> 0 Then
                '    Me.lbTaxRate.Text = FormatNumber(.tax / t * 100, 2) & "%"
                'End If
                'Dim lt As Decimal = aptOD.getTotalListAmount(_OrderId)
                '20120719 Rudy: Load external note(Order Note)
                'Dim eqNoteAdt As New EQDSTableAdapters.QuotationNoteTableAdapter
                'Dim dtEqNote As EQDS.QuotationNoteDataTable = eqNoteAdt.GetNoteTextBYQuoteId(.quoteId)
                'For Each row As EQDS.QuotationNoteRow In dtEqNote.Rows
                '    If row.notetype.ToUpper = "ORDERNOTE" Then
                '        _lbExternalNote += row.notetext + "<br/>"
                '    End If
                'Next
                'If shipTerm.Text.ToUpper = "DUE" Then Me.tbSM.Visible = False
                'If _IsInternalUserMode = False Then Me.tdBill.Visible = False
            End With
        End If
    End Sub
    
    Public Function GetShipMethodNameByValue(ByVal ShipMethodValue As String) As String
        If ShipMethodValue.Equals("0") Then Return "TBD"
        Dim retObj As Object = Nothing
        Dim cmd As New SqlClient.SqlCommand("select top 1 SHIPTERMNAME from SAP_COMPANY_LOV where SHIPTERM=@SV", _
                                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("SV", ShipMethodValue)
        cmd.Connection.Open() : retObj = cmd.ExecuteScalar() : cmd.Connection.Close()
        If retObj IsNot Nothing Then
            Return retObj.ToString()
        End If
        Return ShipMethodValue
    End Function

    Public Function GetPaymentMethodNameByValue(ByVal PaymentMethodValue As String) As String
        If PaymentMethodValue.Equals("0") Then Return "TBD"
        Dim retObj As Object = Nothing
        Dim cmd As New SqlClient.SqlCommand("select top 1 PAYMENTTERMNAME from SAP_COMPANY_LOV where PAYMENTTERM=@SV", _
                                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("SV", PaymentMethodValue)
        cmd.Connection.Open() : retObj = cmd.ExecuteScalar() : cmd.Connection.Close()
        If retObj IsNot Nothing Then
            Return retObj.ToString()
        End If
        Return PaymentMethodValue
    End Function
    
    Public Function getTotalAmount_EW(ByVal order_id As String) As Decimal
        
        Dim DT As DataTable = aptOD.GetOrderDetail_ewFlagBiggerThanZero(order_id)
        
        If DT.Rows.Count > 0 Then
            Dim am As Decimal = 0
            For Each r As DataRow In DT.Rows
                Dim qty As Integer = r.Item("qty")
                Dim price As Decimal = r.Item("unit_Price")
                Dim month As Integer = r.Item("EXWARRANTY_FLAG")
                am += qty * price * getRateByEWItem(getEWItemByMonth(month))
            Next
            Return am
        End If
        Return 0
    End Function
    
    Private Function getEWItemByMonth(ByVal month As Integer) As String
        If IsNumeric(month) AndAlso month > 0 And month.ToString.Length < 3 Or month = 999 Then
            If month = 99 Then
                Return "AGS-EW-AD"
            End If
            If month = 999 Then
                Return "AGS-EW/DOA-03"
            End If
            Return "AGS-EW-" & month.ToString("00")
        End If
        Return ""
    End Function

    Private Function getRateByEWItem(ByVal itemNo As String) As Double
        Select Case itemNo.ToUpper.Trim()
            Case "AGS-EW-03"
                Return 0.02
            Case "AGS-EW-06"
                Return 0.035
            Case "AGS-EW-09"
                Return 0.05
            Case "AGS-EW-12"
                Return 0.06
            Case "AGS-EW-15"
                Return 0.07
            Case "AGS-EW-21"
                Return 0.08
            Case "AGS-EW-24"
                Return 0.1
            Case "AGS-EW-36"
                Return 0.15
            Case "AGS-EW-AD"
                Return 0.05
            Case "AGS-EW/DOA-03"
                Return 0.01
        End Select
        Return 0
    End Function
    
    Public Function getMaxLineNo(ByVal orderId As String, ByVal type As Integer) As Integer
        If type = -1 Then
            Return 100
        End If
        Dim o As Object = Nothing

        If type = 1 Then
            o = dbUtil.dbExecuteScalar("MY", String.Format("select max(line_No) from Order_Detail where Order_Id='{0}' and (ORDER_LINE_TYPE=1 or ORDER_LINE_TYPE=-1)", orderId))
        Else
            o = dbUtil.dbExecuteScalar("MY", String.Format("select max(line_No) from Order_Detail where Order_Id='{0}' and ORDER_LINE_TYPE='{1}'", orderId, type))
        End If
        

        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function

    
    Public Function getTotalPrice_EW(ByVal order_id As String) As Decimal
        Dim DT As DataTable = aptOD.GetOrderDetail_ewFlagBiggerThanZero(order_id)
        If DT.Rows.Count > 0 Then
            Dim am As Decimal = 0
            For Each r As DataRow In DT.Rows
                Dim price As Decimal = r.Item("unit_Price")
                Dim month As Integer = r.Item("EXWARRANTY_FLAG")
                am += price * getRateByEWItem(getEWItemByMonth(month))
            Next
            Return am
        End If
        Return 0
    End Function

    
    Protected Sub initGV(ByRef QuoteDetailTb As MyOrderDS.ORDER_DETAILDataTable)
        Dim myOD As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
        'Dim DT As DataTable = myOD.GetOrderDetailByOrderID(_OrderId)
        Dim DT As MyOrderDS.ORDER_DETAILDataTable = myOD.GetOrderDetailByOrderID(_OrderId)
        
        If DT IsNot Nothing AndAlso DT.Rows.Count > 0 Then
            
            'Add inventory column
            Util.FillANAPITemplaeProductInventory(DT)
            
            'Frank 2012/08/08:Get Quotation Master data
            Me._QuoteID = DT.Rows(0).Item("OptyID")
            Dim _EQWS As New quote.quoteExit
            _EQWS.getQuotationMasterById(Me._QuoteID, Me._QuotMaster)
            If Me._QuotMaster.Tables(0) IsNot Nothing AndAlso Me._QuotMaster.Tables(0).Rows.Count > 0 Then
                If Not _IsFoucePrintFormat Then Me._pri_format = Me._QuotMaster.Tables(0).Rows(0).Item("PRINTOUT_FORMAT")
            End If

            If _IsBtosOrder And getTotalAmount_EW(_OrderId) > 0 Then
                Dim R As DataRow = DT.NewRow
                With R
                    .Item("line_No") = getMaxLineNo(_OrderId, 1) + 1 : .Item("cate") = "Extended Warranty"
                    .Item("Part_No") = getEWItemByMonth(DT.Rows(DT.Rows.Count - 1).Item("EXWARRANTY_FLAG"))
                    .Item("description") = "Extended Warranty for " & DT.Rows(DT.Rows.Count - 1).Item("EXWARRANTY_FLAG") & " Months"
                    .Item("EXWARRANTY_FLAG") = DT.Rows(DT.Rows.Count - 1).Item("EXWARRANTY_FLAG")
                    .Item("list_Price") = getTotalPrice_EW(_OrderId) : .Item("unit_Price") = .Item("list_Price")
                    .Item("qty") = DT.Rows(DT.Rows.Count - 1).Item("qty")
                    .Item("REQUIRED_DATE") = Now.ToShortDateString : .Item("due_Date") = Now.ToShortDateString
                    .Item("ORDER_LINE_TYPE") = 1 : .Item("DeliveryPlant") = DT.Rows(0).Item("DeliveryPlant")
                End With
                DT.Rows.Add(R)
            End If
        End If
        Me.gv1.DataSource = DT : Me.gv1.DataBind()
    End Sub
    
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            
            Dim myOM As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter, myOD As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
            Dim dt As DataTable = myOM.GetOrderMasterByOrderID(_OrderId)

            
            Dim DBITEM As DataRowView = CType(e.Row.DataItem, DataRowView)
            Dim line_no As Integer = gv1.DataKeys(e.Row.RowIndex).Value, Mod_line_no As Integer = 0
            Dim part_no As String = e.Row.Cells(1).Text.Trim
            Dim ListPice As Decimal = CDbl(CType(e.Row.FindControl("lbListPrice"), Label).Text)
            Dim UnitPrice As Decimal = CDbl(CType(e.Row.FindControl("lbUnitPrice"), Label).Text)
            Dim qty As Decimal = CInt(CType(e.Row.FindControl("lbGVQty"), Label).Text)
            Dim Discount As Decimal = 0.0, SubTotal As Decimal = 0.0, ewPrice As Decimal = 0.0
            
            
            If DBITEM.Item("EXWARRANTY_FLAG") = 99 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "36"
            End If
            If DBITEM.Item("EXWARRANTY_FLAG") = 999 Then
                CType(e.Row.FindControl("lbew"), Label).Text = "3"
            End If
            
            ewPrice = FormatNumber(getRateByEWItem(getEWItemByMonth(CInt(CType(e.Row.FindControl("lbew"), Label).Text))) * UnitPrice, 2)
           
            CType(e.Row.FindControl("gv_lbEW"), Label).Text = ewPrice
            
            If ListPice = 0 Then
                CType(e.Row.FindControl("lbDisc"), Label).Text = "TBD"
            Else
                Discount = FormatNumber((ListPice - UnitPrice) / ListPice, 2)
                If ListPice < UnitPrice Then
                    Discount = 0
                End If
                CType(e.Row.FindControl("lbDisc"), Label).Text = Discount * 100 & "%"
            End If
            SubTotal = FormatNumber(qty * (UnitPrice + ewPrice), 2)
            CType(e.Row.FindControl("lbSubTotal"), Label).Text = SubTotal

            If myOD.IsBtoParentItem(_OrderId, line_no) = 1 Then
                CType(e.Row.FindControl("lbDisc"), Label).Text = ""
                Dim totalamont = myOD.getTotalAmount(_OrderId) + Me.getTotalAmount_EW(_OrderId)
                CType(e.Row.FindControl("lbSubTotal"), Label).Text = FormatNumber(totalamont, 2)
                CType(e.Row.FindControl("lbUnitPrice"), Label).Text = FormatNumber(totalamont / DBITEM.Item("qty"), 2)
            End If

            'Count the line no mod 100 value
            Mod_line_no = line_no Mod 100
            'Frank 2012/08/01:If line no is bigger than 100 then to show the category instead of the part_no
            If Mod_line_no > 0 AndAlso line_no > 100 Then
                e.Row.Cells(1).Text = DBITEM.Item("cate").ToString
                'ElseIf line_no < 100 Then 'do not execute the line_no * 100 for line no
                '    e.Row.Cells(0).Text = line_no * 100
            End If
            
            
            'Me._pri_format = EnumSetting.USPrintOutFormat.MAIN_ITEM_ONLY
            'Me._pri_format = EnumSetting.USPrintOutFormat.SUB_ITEM_WITH_SUB_ITEM_PRICE
            'Me._pri_format=EnumSetting.USPrintOutFormat.SUB_ITEM_WITHOUT_SUB_ITEM_PRICE
            Select Case Me._pri_format
                Case EnumSetting.USPrintOutFormat.MAIN_ITEM_ONLY
                    If Mod_line_no > 0 AndAlso line_no > 100 Then
                        'Frank this line could be moved to the begin of this event
                        e.Row.Visible = False
                    End If
                Case EnumSetting.USPrintOutFormat.SUB_ITEM_WITH_SUB_ITEM_PRICE
                    If Mod_line_no > 0 AndAlso line_no > 100 Then
                        e.Row.Cells(1).Text = DBITEM.Item("part_no").ToString
                    End If
                Case EnumSetting.USPrintOutFormat.SUB_ITEM_WITHOUT_SUB_ITEM_PRICE
                    If Mod_line_no > 0 AndAlso line_no > 100 Then
                        'e.Row.Cells(1).Text = "Other" 'Frank 2012/08/07 do not overwrite descript with Other
                        e.Row.Cells(7).Text = ""
                    End If
                Case EnumSetting.USPrintOutFormat.SUB_ITEM_WITHPARTNO_WITHOUT_SUB_ITEM_PRICE
                    If Mod_line_no > 0 AndAlso line_no > 100 Then
                        e.Row.Cells(1).Text = DBITEM.Item("part_no").ToString
                        e.Row.Cells(7).Text = ""
                    End If
            End Select
            
            
        End If
        
    End Sub

    Private Function isPhaseOut(ByVal pn As String, ByVal org As String) As Boolean
        Dim f As Boolean = False
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("MY", String.Format( _
                                     " select count(part_no) from SAP_PRODUCT_STATUS_ORDERABLE where part_no='{0}' and sales_org='{1}' ", pn, org))
        If dt.Rows.Count = 0 Then
            f = True
        Else

        End If
        Return f
    End Function

    
    Private Sub SetColumnVisible()
       
        Me.gv1.Columns(3).Visible = False : Me.gv1.Columns(6).Visible = False
        Me.gv1.Columns(8).Visible = False : Me.gv1.Columns(9).Visible = False 'Frank 2012/07/31: hiding Req Ship date
        Me.gv1.Columns(10).Visible = False

        If Not _IsInternalUserMode Then
            Me.gv1.Columns(4).Visible = False
        End If
        
    End Sub
    
</script>
<style type="text/css">
    table.contact
    {
        font: bold 13px/normal Arial,Helvetica,sans-serif;
        border-collapse: collapse;
        border-color: #ffffff;
        background: #FFFFFF;
        color: #333;
        width: 100%;
    }
    .contact th
    {
        width: 33%;
        border-collapse: collapse;
        background: #EFF4FB;
    }
    .contact td
    {
        font: 12px/normal Arial,Helvetica,sans-serif;
        border-collapse: collapse;
        background: #FFFFFF;
        color: #333;
    }
    
    table.estoretable
    {
        font: 13px/normal Arial,Helvetica,sans-serif;
        border-collapse: collapse;
        color: #333;
        width: 100%;
    }
    
    .estoretable th
    {
        padding: 3px;
        border-style: solid;
        border-width: 1px;
        border-color: #E5E5E5;
        text-align: center;
        background: #EFF4FB;
    }
    
    .estoretable td
    {
        padding: 3px;
        border-style: solid;
        border-width: 1px;
        border-color: #E5E5E5;
    }
    
    table.estoretable2
    {
        font: 13px/normal Arial,Helvetica,sans-serif;
        border-collapse: collapse;
        color: #333;
        width: 100%;
    }
    .estoretable2 td
    {
        padding: 3px;
        text-align: right;
    }
    
    .boder
    {
        border: 1px solid #E5E5E5;
    }
    
    .estoretable caption
    {
        padding: 0 0 .5em 0;
        text-align: left;
        text-transform: uppercase;
        color: #333;
        background: transparent;
    }
    .cartitem p
    {
        margin: 0;
        padding: 5px 0;
    }
    .cartitem label
    {
        font-weight: bold;
    }
</style>
<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="font-family: Arial, Helvetica, sans-serif">
    <tr>
        <td align="left">
            <img src='<%=Util.GetRuntimeSiteUrl() %>/Images/Advantech logo.jpg' alt="Advantech eStore" />
        </td>
    </tr>
    <tr>
        <td>
            <table width="100%" border="0" cellpadding="0" cellspacing="0" height="30">
                <tr>
                    <td bgcolor="#E5E5E5" style="background-color: #E5E5E5" height="30">
                        <a title="Home" href="http://buy.advantech.com/Default.htm" style="text-decoration: none">
                            <font size="2" color="#767677"><b>Home</b></font></a> &nbsp; &nbsp; &nbsp; <a title="About Us"
                                href="http://buy.advantech.com/AboutUs/Default.htm" style="text-decoration: none">
                                <font size="2" color="#767677"><font size="2" color="#767677"><b>About Us</b></font></a>
                        &nbsp; &nbsp; &nbsp; <a title="Support" href="http://support.advantech.com.tw/" style="text-decoration: none">
                            <font size="2" color="#767677"><font size="2" color="#767677"><b>Support</b></font></a>
                        &nbsp; &nbsp; &nbsp; <a title="Contact Us" href="http://buy.advantech.com/ContactUs/Default.htm"
                            style="text-decoration: none"><font size="2" color="#767677"><font size="2" color="#767677">
                                <b>Contact Us</b></font></a>
                    </td>
                </tr>
                <tr>
                    <td height="18" bgcolor="#708AAC" style="background-color: #708AAC; padding: 5px 10px">
                        <div style="color: #FFFFFF; font-size: 12px" id="officeInformation_USA" runat="server">
                            Advantech Corporation | 380 Fairview way, Milpitas, 95035 CA, US
                            <br />
                            1-888-576-9668 8 am- 8 pm (EST) Mon-Fri
                        </div>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="6" style="border: 1px solid #CCCCCC;
                background-color: #FFFFE6" bgcolor="#FFFFE6" align="center">
                <tr>
                    <td style="font-size: 13px;">
                        <div>
                            <b>Dear Customer</b></div>
                        <div style="padding-left: 10px">
                            <p>
                                <span lang="EN-US" style="font-size: 10.0pt; font-family: Arial,sans-serif">Thank you
                                    for choosing Advantech products and services!
                                    <br />
                                    The order number
                                    <%= _OrderId%>
                                    has been created upon your request. Please contact your Advantech Sales Team at
                                    (888)576-9668, should you have any questions regarding this order. </span>
                                <br />
                                <br />
                                <%-- <b>Comments: </b>
                                            <br />
                                            <asp:Label runat="server" ID="quoteNote"></asp:Label>--%>
                            </p>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td bgcolor="#FFFFFF">
                        <table width="100%" border="0" cellspacing="2" cellpadding="0">
                            <tr>
                                <td align="center" width="33%">
                                    <b>Order No:
                                        <asp:Label runat="server" ID="LabelOrderID"></asp:Label></b>
                                </td>
                                <td align="center" width="33%">
                                    <b>Order Date:
                                        <asp:Label runat="server" ID="ORDER_DATE"></asp:Label></b>
                                </td>
                                <%--                                <td align="center" width="33%"><b>Expiration Date: <asp:Label runat="server" ID="expiredDate"></asp:Label></b></td>
                                --%>
                            </tr>
                            <tr>
                                <td colspan="3" background="http://buy.advantech.com/App_Themes/AUS/line.gif" height="1">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <!-- Contact Info -->
                                    <table width="100%">
                                        <tr valign="top">
                                            <td style="width: 33%">
                                                <uc1:soldtoshipto runat="server" ID="soldtoshiptoUC" Visible="true" />
                                            </td>
<%--                                            <td style="width: 33%" runat="server" id="tdBill">
                                                <asp:Table ID="Table_BillTo" Width="100%" class="contact" runat="server" Visible="false">
                                                    <asp:TableHeaderRow>
                                                        <asp:TableHeaderCell ColumnSpan="2" Style="color: #333333;">
                                                            Bill to &nbsp;<asp:Label runat="server" ID="lblBillToERPID" />
                                                        </asp:TableHeaderCell>
                                                    </asp:TableHeaderRow>
                                                    <asp:TableRow>
                                                        <asp:TableHeaderCell Style="color: #333333;">Company:</asp:TableHeaderCell><asp:TableCell
                                                            ID="Cell_BillTo_Company"><%=_lbBilltoCompany%></asp:TableCell></asp:TableRow>
                                                    <asp:TableRow>
                                                        <asp:TableHeaderCell Style="color: #333333;">Address:</asp:TableHeaderCell><asp:TableCell
                                                            ID="Cell_BillTo_Address"><%=_lbBilltoAddr%></asp:TableCell></asp:TableRow>
                                                    <asp:TableRow>
                                                        <asp:TableHeaderCell Style="color: #333333;">Tel:</asp:TableHeaderCell><asp:TableCell
                                                            ID="Cell_BillTo_Tel"><%=_lbBilltoTel%></asp:TableCell></asp:TableRow>
                                                    <asp:TableRow>
                                                        <asp:TableHeaderCell Style="color: #333333;">Attention:</asp:TableHeaderCell><asp:TableCell
                                                            ID="Cell_BillTo_Attention"><%=_lbBilltoAttention%></asp:TableCell></asp:TableRow>
                                                </asp:Table>
                                            </td>
--%>                                    </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <uc2:OrderInfo runat="server" ID="Orderinfo1" Visible="true" />
                                </td>
                            </tr>
<%-- Frank先隱藏暫時保留                           <tr>
                                <td colspan="3">
                                    <span style="font-size: 14px; color: #003D7C"><b>order Detail:</b></span>&nbsp;&nbsp;&nbsp;<asp:Label runat="server" ID="lblSalesPerson" Font-Bold="true" />
                                </td>
                            </tr>
--%>                            <tr>
                                <td colspan="3">
                                    <asp:GridView DataKeyNames="line_no" ID="gv1" runat="server" AllowPaging="false"
                                        EmptyDataText="no Item." AutoGenerateColumns="false" OnRowDataBound="gv1_RowDataBound"
                                        Font-Size="10pt" Width="100%">
                                        <AlternatingRowStyle BackColor="#EBEBEB" />
                                        <Columns>
                                            <asp:BoundField DataField="line_no" HeaderText="No." ItemStyle-HorizontalAlign="center">
                                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                            </asp:BoundField>
                                            <asp:BoundField DataField="part_No" HeaderText="Part No" ItemStyle-HorizontalAlign="left">
                                                <ItemStyle HorizontalAlign="Left"></ItemStyle>
                                            </asp:BoundField>
                                            <asp:TemplateField HeaderText="Description">
                                                <ItemTemplate>
                                                    <asp:Label runat="server" ID="lbdescription" Text='<%#Bind("description") %>'></asp:Label>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Extended Warranty">
                                                <ItemTemplate>
                                                    <asp:Label runat="server" ID="lbew" Text='<%#Bind("EXWARRANTY_FLAG") %>'></asp:Label>months
                                                    <asp:Label runat="server" Text='<%#_currencySign %>' ID="lbEWSign"></asp:Label>
                                                    <asp:Label runat="server" ID="gv_lbEW"></asp:Label></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="inventory" HeaderText="Available Qty" ItemStyle-HorizontalAlign="center">
                                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                                            </asp:BoundField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    Qty.</HeaderTemplate><ItemTemplate>
                                                    <asp:Label runat="server" Text='<%#Bind("qty") %>' ID="lbGVQty"></asp:Label></ItemTemplate><HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Right"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    List Price</HeaderTemplate>
                                                <ItemTemplate>
                                                    <asp:Label runat="server" Text='<%#_currencySign %>' ID="lbListPriceSign"></asp:Label><asp:Label
                                                        runat="server" Text='<%#FormatNumber(Eval("list_price"),2) %>' ID="lbListPrice"></asp:Label></ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Right"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    Unit Price</HeaderTemplate><ItemTemplate>
                                                    <asp:Label runat="server" Text='<%#_currencySign %>' ID="lbUnitPriceSign"></asp:Label><asp:Label
                                                        runat="server" Text='<%#FormatNumber(Eval("unit_price"),2) %>' ID="lbUnitPrice"></asp:Label></ItemTemplate><HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Right"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    Disc.</HeaderTemplate><ItemTemplate>
                                                    <asp:Label runat="server" Text='' ID="lbDisc"></asp:Label></ItemTemplate><HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Right"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    Req.Ship Date</HeaderTemplate><ItemTemplate>
                                                    <asp:Label runat="server" Text='<%#CDate(Eval("due_date")).ToString("MM/dd/yyyy")%>'
                                                        ID="lbDueDate"></asp:Label></ItemTemplate><HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Right"></ItemStyle>
                                            </asp:TemplateField>
                                            <asp:TemplateField ItemStyle-HorizontalAlign="right" HeaderStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    Sub Total</HeaderTemplate><ItemTemplate>
                                                    <asp:Label runat="server" Text='<%#_currencySign %>' ID="lbSubTotalSign"></asp:Label><asp:Label
                                                        runat="server" Text="" ID="lbSubTotal"></asp:Label></ItemTemplate><HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                                                <ItemStyle HorizontalAlign="Right"></ItemStyle>
                                            </asp:TemplateField>
                                        </Columns>
                                        <HeaderStyle BackColor="#FF6600" ForeColor="White" />
                                    </asp:GridView>
                                    <br />
                                    <table width="100%">
                                        <tr class="cartitem">
                                            <td id="tbSM" style="text-align: left" rowspan="4" valign="top" width="45%" class="boder"
                                                runat="server">
<%--                                                Shipping Method:
                                                <asp:Label runat="server" ID="shipTerm"></asp:Label><br />
                                                Payment Method:
                                                <asp:Label runat="server" ID="paymentTerm"></asp:Label><br />
                                                <br />
                                                <asp:Table ID="Table_ExternalNote" CellPadding="0" BorderWidth="0" BorderColor="White"
                                                    runat="server" HorizontalAlign="Left">
                                                    <asp:TableRow>
                                                        <asp:TableCell HorizontalAlign="Left" VerticalAlign="Top" Width="100">Note:</asp:TableCell>
                                                        <asp:TableCell HorizontalAlign="Left" VerticalAlign="Top" Height="50" ID="Cell_ExternalNote"><%= _lbExternalNote%></asp:TableCell>
                                                    </asp:TableRow>
                                                </asp:Table>
--%>                                            </td>
                                            <td align="right">
                                                Sub Total:
                                            </td>
                                            <td align="right">
                                                <asp:Label runat="server" ID="lbSubTotal"></asp:Label>
                                            </td>
                                        </tr>
<%--                                        <tr class="cartitem">
                                            <td align="right">
                                                <font color="red">* </font>Freight:
                                            </td>
                                            <td align="right">
                                                <asp:Label runat="server" ID="freight"></asp:Label>
                                            </td>
                                        </tr>
--%>                                        
                                        <tr class="cartitem">
                                            <td align="right">
                                                <font color="red">* </font>Tax<%--(<asp:Label runat="server" ID="lbTaxRate"></asp:Label>)--%>:
                                            </td>
                                            <td align="right">
                                                <asp:Label runat="server" ID="tax"></asp:Label>
                                            </td>
                                        </tr>
                                        <tr class="cartitem">
                                            <td align="right">
                                                Total:
                                            </td>
                                            <td align="right" style="font-weight: bold; color: #FF0000;">
                                                <asp:Label runat="server" ID="lbTotal"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                    <!-- CART DETAIL / -->
                                </td>
                            </tr>
                        </table>
                        <div style="color: #333; padding-left: 10px">
                            <p>
                                <span lang="EN-US" style="font-size: 9.0pt; color: red">*</span><span lang="EN-US"
                                    style="font-size: 9.0pt; color: #333333"> Indicates an Estimated Value<o:p></o:p></span><br />
                                <span lang="EN-US" style="font-size: 9.0pt; color: red">*</span>
                                <span lang="EN-US" style="font-size: 9.0pt; color: #333333"> All prices are in US dollars, F.O.B. California, U.S.A.<o:p></o:p></span></p>

                            <p>
                                <span lang="EN-US" style="font-size: 9.0pt; color: #333333">Any orders that ship to the following jurisdictions are charged sales tax: AZ, CA, 
                                    CO, CT, FL, GA, IL, IN, KY, MD, MA, NC, NJ, OH, TN, TX, WA, and WI. If you are exempt from sales tax, select the Resale box during the checkout process. 
                                    Upon receiving the proper paperwork, Advantech will not include such taxes in the final invoices.<o:p></o:p></span></p>
                            <p>
                                <span lang="EN-US" style="font-size: 9.0pt; color: #333333">The export of any products or software purchased from Advantech must be made in 
                                    accordance with all relevant laws of the United States, including and without limitation, the US Export Administration Regulations. 
                                    This may require that you obtain a formal export license or make certain declarations to the United States Government regarding products to be exported, 
                                    their destination or their end-use.<o:p></o:p></span></p>
                            <p>
                                <span lang="EN-US" style="font-size: 9.0pt; color: #333333; font-weight:bold">Please refer questions regarding the provided quotation on 
                                    these terms and conditions to the indicated sales representative. <o:p></o:p></span></p>
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <span style="color:#000000; font-weight:bold">Best regards,</span>
                        <br />
                        <a href="http://my.advantech.com" style="text-decoration: none; font-weight: bold;
                            color: #000000">Advantech Corp</a> 
                    </td>
                </tr>
            </table>
            <div> 
            </div>
        </td>
    </tr>
    <!-- Footer -->
    <tr>
        <td height="15" bgcolor="#708AAC" style="background-color: #708AAC; text-align: center;
            color: #FFFFFF; font-size: 12px" align="center">
            <asp:Literal runat="server" ID="litOfficeTelTime2" />
        </td>
    </tr>
    <tr>
        <td height="30" style="text-align: center; border: 1px solid #CCCCCC; background-color: #FFFFE6"
            bgcolor="#FFFFE6" align="center" valign="middle">
            <a href="http://buy.advantech.com/resource/aus/terms_and_conditions_aus.pdf" style="text-decoration: none;
                font-size: 11px"><font color="#555555">Terms and Conditions</font>&nbsp;&nbsp;<font
                    color="#555555">|</font>&nbsp;&nbsp;</a><a href="http://buy.advantech.com/Info/ReturnPolicy.htm"
                        style="text-decoration: none; font-size: 11px"><font color="#555555">Return Policy</font></a>&nbsp;&nbsp;<font
                            color="#555555"><span style="font-size: 11px;">|</span></font>&nbsp;&nbsp;<a href="http://buy.advantech.com/Info/PrivacyPolicy.htm"
                                style="text-decoration: none; font-size: 11px"><font color="#555555">Privacy Policy</font></a>
        </td>
    </tr>
    <!-- Footer /-->
</table>

