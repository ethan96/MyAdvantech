Imports MyOrderDSTableAdapters
Imports MyOrderDS

Partial Class Order_PI_ATW
    Inherits System.Web.UI.Page
    Public OrderID As String = String.Empty
    Public CartID As String = String.Empty
    Protected Sub Order_PI_ATW_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Not Page.IsPostBack Then
            If Request("NO") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("NO")) Then
                OrderID = Request("NO").Trim
                Dim _Cart2OrderMaping As Cart2OrderMaping = MyUtil.Current.MyAContext.Cart2OrderMapings.Where(Function(p) p.OrderNo = OrderID OrElse p.OrderID = OrderID).FirstOrDefault()
                If _Cart2OrderMaping Is Nothing Then Exit Sub
                CartID = _Cart2OrderMaping.CartID
                Dim _cartmaster As CartMaster = MyCartX.GetCartMaster(_Cart2OrderMaping.CartID)
                If _cartmaster IsNot Nothing Then
                    Dim QM As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(_cartmaster.QuoteID)
                    If QM IsNot Nothing Then
                        Dim IsShowSiebleInfo As Boolean = False
                        Dim _dt = MYSIEBELDAL.GET_Contact_Info_by_RowID(QM.attentionRowId)
                        If _dt IsNot Nothing AndAlso _dt.Rows.Count > 0 Then
                            IsShowSiebleInfo = True
                            lbtel.Text = _dt.Rows(0).Item("WorkPhone").ToString.Split(Chr(10))(0)
                            ' Me.LitAccountContactFAX.Text = _dt.Rows(0).Item("FaxNumber").ToString.Split(Chr(10))(0)
                            lbLstName.Text = _dt.Rows(0).Item("LastName")
                            lbFstName.Text = _dt.Rows(0).Item("FirstName")
                        End If

                        Dim OrderMaster As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 *  from  ORDER_MASTER WHERE ORDER_ID='{0}'", OrderID))
                        If OrderMaster IsNot Nothing AndAlso OrderMaster.Rows.Count = 1 Then
                            With OrderMaster.Rows(0)
                                Dim dtcompany As DataTable = dbUtil.dbGetDataTable("CRMDB75", MYSIEBELDAL.GET_Account_info_By_ERPID(.Item("SOLDTO_ID").ToString()))
                                'dbUtil.dbGetDataTable("MY", String.Format("select top 1 *  from  SAP_DIMCOMPANY WHERE COMPANY_ID='{0}'", .Item("SOLDTO_ID")))
                                If dtcompany IsNot Nothing AndAlso dtcompany.Rows.Count = 1 Then
                                    lbAccount.Text = dtcompany.Rows(0).Item("COMPANYNAME")
                                End If
                                lbCurr.Text = .Item("CURRENCY")

                                'ICC 2015/4/20 If opty ID is [NEW ID] then go to eQuotation.optyQuote to find optyID. If it is still [NEW ID] then replace by Empty  
                                If String.IsNullOrEmpty(_cartmaster.OpportunityID) Then _cartmaster.OpportunityID = String.Empty
                                If _cartmaster.OpportunityID.ToUpper() = "NEW ID" Then
                                    Dim optyId As String = eQuotationUtil.GetOptyidQuoteByQuoteid(_cartmaster.QuoteID)
                                    If Not String.IsNullOrEmpty(optyId) AndAlso optyId.ToUpper() <> "NEW ID" Then
                                        _cartmaster.OpportunityID = optyId
                                    Else
                                        _cartmaster.OpportunityID = String.Empty
                                    End If
                                End If

                                lbOptyid.Text = _cartmaster.OpportunityID
                                ''''  lbDue.Text = CDate(.Item("DUE_DT")).ToString("yyyy/MM/dd") : lbEffDate.Text = CDate(.Item("Effective_Date")).ToString("yyyy/MM/dd")
                                Dim dtSales As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" select TOP 1 FIRST_NAME ,LAST_NAME,FULL_NAME,CELLPHONE  FROM  dbo.SAP_EMPLOYEE WHERE SALES_CODE =(select TOP 1 ERPID    from ORDER_PARTNERS WHERE ORDER_ID='{0}' and TYPE='E')", OrderID))
                                If dtSales IsNot Nothing AndAlso dtSales.Rows.Count = 1 Then
                                    'If Not IsShowSiebleInfo Then
                                    '    lbFstName.Text = dtSales.Rows(0).Item("FIRST_NAME") : lbLstName.Text = dtSales.Rows(0).Item("LAST_NAME")
                                    '    If Not IsDBNull(dtSales.Rows(0).Item("CELLPHONE")) Then
                                    '        lbtel.Text = dtSales.Rows(0).Item("CELLPHONE")
                                    '    End If
                                    'End If
                                    lbSalesPersonLstName.Text = dtSales.Rows(0).Item("FULL_NAME")
                                End If
                                If Not IsShowSiebleInfo Then
                                    If Not String.IsNullOrEmpty(OrderID) Then
                                        Dim A As New ORDER_PARTNERSTableAdapter
                                        Dim OPner As ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(Me.OrderID)
                                        For Each r As ORDER_PARTNERSRow In OPner.Select("type='S'")
                                            If r.TYPE.Equals("S", StringComparison.OrdinalIgnoreCase) Then
                                                lbtel.Text = r.TEL
                                                lbFstName.Text = r.ATTENTION
                                                lbLstName.Text = ""
                                            End If
                                        Next
                                    End If
                                End If
                                Dim dtOpty As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select  top 1 NAME  from  dbo.SIEBEL_OPPORTUNITY where ROW_ID ='{0}'", _cartmaster.OpportunityID))
                                If dtOpty IsNot Nothing AndAlso dtOpty.Rows.Count = 1 Then
                                    lbOptyName.Text = dtOpty.Rows(0).Item("NAME")
                                End If

                                lbQuoteName.Text = QM.quoteNo
                                'lbQuoteNum.Text = .Item("QUOTE_NUM") : lbQuoteStatus.Text = .Item("QUOTE_STATUS")
                                'lbSalesRep.Text = .Item("Sales_Rep")
                                Dim TotalAmount = dbUtil.dbExecuteScalar("MY", String.Format("SELECT  SUM(UNIT_PRICE * QTY) AS TotalAmount  FROM ORDER_DETAIL WHERE ORDER_ID='{0}'", OrderID))
                                If TotalAmount IsNot Nothing Then
                                    lbTotal.Text = FormatNumber(TotalAmount.ToString(), 2) '.Item("QUOTE_SUM")
                                End If

                                lbERPID.Text = .Item("SOLDTO_ID")
                                Dim dtAccount As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" select top 1  ROW_ID ,ADDRESS  from  SIEBEL_ACCOUNT where ERP_ID ='{0}'", .Item("SOLDTO_ID")))
                                If dtAccount IsNot Nothing AndAlso dtAccount.Rows.Count = 1 Then
                                    Labaccountrowid.Text = dtAccount.Rows(0).Item("ROW_ID")
                                    lbAdr.Text = dtAccount.Rows(0).Item("ADDRESS")
                                End If
                                lbnote.Text = .Item("SALES_NOTE")

                            End With
                        End If


                    Else
                        Dim qmDt As DataTable = GetQuoteHeader(_cartmaster.QuoteID)
                        If qmDt IsNot Nothing AndAlso qmDt.Rows.Count = 1 Then
                            With qmDt.Rows(0)
                                lbAccount.Text = .Item("ACCOUNT_NAME") : lbCurr.Text = .Item("Currency")
                                'If IsDBNull(.Item("DUE_DT")) OrElse IsDBNull(.Item("Effective_Date")) Then                      
                                'Else
                                lbDue.Text = CDate(.Item("DUE_DT")).ToString("yyyy/MM/dd") : lbEffDate.Text = CDate(.Item("Effective_Date")).ToString("yyyy/MM/dd")
                                'End If
                                lbOptyid.Text = qmDt.Rows(0).Item("OPTY_ID").ToString.Trim
                                lbFstName.Text = .Item("First_Name") : lbLstName.Text = .Item("Last_Name")
                                lbOptyName.Text = .Item("OPTY_NAME") : lbQuoteName.Text = .Item("NAME")
                                '  lbPickedQuoteName.Text = .Item("NAME")
                                lbQuoteNum.Text = .Item("QUOTE_NUM") : lbQuoteStatus.Text = .Item("QUOTE_STATUS")
                                lbSalesRep.Text = .Item("Sales_Rep")
                                lbTotal.Text = FormatNumber(_cartmaster.OpportunityAmount, 2) '.Item("QUOTE_SUM")
                                lbERPID.Text = .Item("ERPID")
                                lbSalesPersonLstName.Text = .Item("SalesName")
                                Labaccountrowid.Text = .Item("ACCOUNT_ROW_ID")
                                'Me.txtReqDate.Text = CDate(.Item("DUE_DT")).ToString("yyyy/MM/dd")
                                'If Not String.IsNullOrEmpty(lbOptyid.Text.Trim) Then
                                '    txtOptyName.Text = .Item("OPTY_NAME")
                                '    txtOptyRowID.Text = lbOptyid.Text
                                '    DDLOptyStage.Visible = False
                                '    LabelOptyStage.Visible = False
                                'End If
                            End With

                            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "SELECT  top 1 (City+' '+Address+' '+ZIPCODE ) as AddressStr,isnull(PHONE_NUM,'')  as Tel   FROM  SIEBEL_ACCOUNT WHERE ROW_ID ='" + Labaccountrowid.Text.Trim + "'")
                            Dim _tel As String = String.Empty
                            If dt.Rows.Count > 0 Then
                                lbAdr.Text = dt.Rows(0).Item("AddressStr")
                                'lbtel.Text = dt.Rows(0).Item("Tel")
                                _tel = dt.Rows(0).Item("Tel").ToString
                                If Not String.IsNullOrEmpty(_tel) Then
                                    lbtel.Text = _tel.Split(Chr(10))(0)
                                End If
                            End If
                        Else
                            lbMsg.Text = "Requested quotation does not exist in SIEBEL"
                        End If
                    End If

                End If
                Dim orderlist As List(Of OrderItem) = MyOrderX.GetOrderList(OrderID)
                gvItems.DataSource = orderlist
                gvItems.DataBind()
            End If
        End If
    End Sub
    Protected Sub gvItems_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim item As OrderItem = CType(e.Row.DataItem, OrderItem)
            If item.ItemTypeX = OrderItemType.BtosParent Then
                e.Row.Cells(3).Text = MyOrderX.GetCurrencySign(OrderID) + vbTab + lbTotal.Text
            ElseIf item.ItemTypeX = OrderItemType.Part Then
                If Decimal.TryParse(item.UNIT_PRICE, 0) Then
                    e.Row.Cells(3).Text = MyOrderX.GetCurrencySign(OrderID) + vbTab + FormatNumber(item.UNIT_PRICE, 2)
                End If
            End If

            'Alex 20160726: add remind message when BTOS Part is added manually
            If item.ORDER_LINE_TYPE = 1 And MyCartBtosManual.InCartBtosManual(CartID, item.PART_NO) And HttpContext.Current.Session("org_id") = "TW01" Then
                e.Row.Cells(1).Text = item.PART_NO & "<br/>" & "<font color='#FF0000'>(Add Manually)</font>"
            End If

        End If
    End Sub
    Function GetQuoteHeader(ByVal QuoteId As String) As System.Data.DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select a.QUOTE_NUM, a.TARGET_OU_ID as ACCOUNT_ROW_ID, b.NAME as ACCOUNT_NAME, IsNull(c.ATTRIB_05,'') as ERPID, "))
            .AppendLine(String.Format(" IsNull((select cast(sum(z.QTY_REQ*z.NET_PRI) as numeric(18,2)) from S_QUOTE_ITEM z where z.SD_ID=a.ROW_ID),0) as QUOTE_SUM, "))
            .AppendLine(String.Format(" a.NAME, IsNull(a.STATUS_DT,'') as QUOTE_STATUS,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.FST_NAME from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as First_Name,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.LAST_NAME from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as Last_Name,   "))
            .AppendLine(String.Format(" IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID=a.CON_PER_ID),'') as Contact_Email,  "))
            .AppendLine("  ISNULL((SELECT top 1 T.ATTRIB_04 FROM S_DOC_QUOTE_X T where T.ROW_ID=a.ROW_ID),'') as SalesName,  ")
            .AppendLine(String.Format(" a.CURCY_CD as Currency,  "))
            .AppendLine(String.Format(" IsNull(a.EFF_START_DT,GetDate()) as Effective_Date,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.NAME from S_OPTY z where z.ROW_ID=a.OPTY_ID),'') as OPTY_NAME, a.OPTY_ID,  "))
            .AppendLine(String.Format(" IsNull((select top 1 z.EMAIL_ADDR from S_CONTACT z where z.ROW_ID in (select z2.PR_EMP_ID from S_POSTN z2 where z2.ROW_ID=a.SALES_REP_POSTN_ID)),'') as Sales_Rep,  "))
            .AppendLine(String.Format(" a.CREATED, a.DESC_TEXT as QUOTE_DESC,IsNull(a.DUE_DT,GetDate()) as DUE_DT,a.EFF_END_DT, a.ACTIVE_FLG, "))
            .AppendLine(String.Format(" a.CREATED_BY, a.SALES_REP_POSTN_ID as OWNER_ID "))
            .AppendLine(String.Format(" from S_DOC_QUOTE a inner join S_ORG_EXT b on a.TARGET_OU_ID=b.ROW_ID  inner join S_ORG_EXT_X c on b.ROW_ID=c.ROW_ID	"))
            .AppendLine(String.Format(" where a.ROW_ID='{0}' ", QuoteId))
        End With
        Dim qmDt As DataTable = Nothing
        For i As Integer = 1 To 3
            Try
                qmDt = dbUtil.dbGetDataTable("CRMDB75", sb.ToString())
                Exit For
            Catch ex As System.Data.SqlClient.SqlException
                Threading.Thread.Sleep(500)
            End Try
        Next
        Return qmDt
    End Function
End Class
