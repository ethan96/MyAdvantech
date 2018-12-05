<%@ Page Language="VB" %>

<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="quote" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    'Private _strb As New StringBuilder
    'Private mWatch As Stopwatch = New Stopwatch
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)

        'mWatch.Start()
        '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : Page_PreRender<br />")

        Dim QuoteId As String = Request("UID")
        Dim USER As String = Request("USER")
        Dim Company As String = Request("COMPANY")
        Dim ORG As String = Request("ORG")
        'Function Access(USER, Company, ORG) need to be executed before transfer quote to cart
        'Becuase it will create new cart_id and keep in Session("cart_id")

        '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : Request Parameters<br />")
        Access(USER, Company, ORG)
        '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : Access(USER, Company, ORG)<br />")

        Dim _cartid As String = Session("cart_id").ToString
        Dim _IsCheckingExpiredQuote As Boolean = True

        Dim MyQuoteMaster As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(QuoteId)
        Dim MyQuoteDetail As List(Of QuotationDetail) = eQuotationUtil.GetQuoteDetailByQuoteid(QuoteId)
        If MyQuoteMaster IsNot Nothing AndAlso MyQuoteDetail IsNot Nothing Then

            If MyQuoteMaster.quoteNo.StartsWith("TWQ") OrElse MyQuoteMaster.quoteNo.StartsWith("ACNQ") Then
                _IsCheckingExpiredQuote = False
            End If

            If _IsCheckingExpiredQuote AndAlso MyQuoteMaster.X_isExpired() Then
                Response.Write("Quotation '" & QuoteId & "' is expired.") : Response.End()
            End If

            Dim _IsQuote2_0 As Boolean = MyQuoteMaster.Is2_0X
            '抛弃2.0quote时，只需要注释掉下面这段逻辑就行
            If _IsQuote2_0 Then
                Response.Redirect(String.Format("Quote2CartV2.aspx{0}", Request.Url.Query))
            End If
            'end
            Dim _ISautoaddEX As Boolean = False

            If MyQuoteDetail.Count > 0 Then
                MyCartX.DeleteCartAllItem(_cartid)
                Dim _EWlist As List(Of EWPartNo) = MyCartX.GetExtendedWarranty()
                Dim currentItemType As Integer = 0, EW_Flag2_0Btos As Integer = 0

                Dim _CartV2DetailDT As DataTable = dbUtil.dbGetDataTable("MY", "Select * from CART_DETAIL_V2 Where ID='-1'")
                Dim _row As DataRow = Nothing

                For Each _QuoteDetailRow As QuotationDetail In MyQuoteDetail
                    Dim isUpdatePrice As Integer = 0, _higherLevel As Integer = 0
                    Dim CurrentCartList As New List(Of CartItem)

                    If _IsQuote2_0 Then
                        _ISautoaddEX = True
                        If _QuoteDetailRow.oType = -1 Then
                            currentItemType = CartItemType.BtosParent
                            _ISautoaddEX = False
                        ElseIf _QuoteDetailRow.oType = 1 Then
                            currentItemType = CartItemType.BtosPart
                            _ISautoaddEX = False
                        Else
                            currentItemType = CartItemType.Part
                        End If
                    Else
                        If _QuoteDetailRow.ItemType = 1 Then
                            currentItemType = CartItemType.BtosParent
                        ElseIf _QuoteDetailRow.line_No > 100 AndAlso _QuoteDetailRow.line_No Mod 100 > 0 Then
                            currentItemType = CartItemType.BtosPart
                        Else
                            currentItemType = CartItemType.Part
                        End If
                    End If
                    If _QuoteDetailRow.HigherLevel IsNot Nothing AndAlso IsNumeric(_QuoteDetailRow.HigherLevel) Then
                        _higherLevel = _QuoteDetailRow.HigherLevel
                    End If

                    If currentItemType = CartItemType.BtosPart Then
                        Dim ParentItem As CartItem = CurrentCartList.Where(Function(p) p.otype = CartItemType.BtosParent).OrderByDescending(Function(p) p.Line_No).FirstOrDefault()
                        If ParentItem IsNot Nothing Then _higherLevel = ParentItem.Line_No
                    End If
                    Dim EW_Flag As Integer = 0
                    If _QuoteDetailRow.ewFlag > 0 Then
                        For Each _ew As EWPartNo In _EWlist
                            If _ew.EW_Month = _QuoteDetailRow.ewFlag Then
                                EW_Flag = _ew.ID
                                'If currentItemType = CartItemType.BtosParent Then
                                '    EW_Flag2_0Btos = EW_Flag
                                'End If
                                Exit For
                            End If
                        Next
                    End If
                    _row = _CartV2DetailDT.NewRow()

                    _row.Item("Cart_Id") = _cartid
                    _row.Item("Line_No") = _QuoteDetailRow.line_No
                    _row.Item("Part_No") = _QuoteDetailRow.partNo
                    _row.Item("Description") = _QuoteDetailRow.description
                    _row.Item("Qty") = _QuoteDetailRow.qty
                    If currentItemType = CartItemType.BtosParent Then
                        _row.Item("List_Price") = 0
                        _row.Item("Unit_Price") = 0
                        _row.Item("Itp") = 0
                    Else
                        _row.Item("List_Price") = _QuoteDetailRow.listPrice
                        _row.Item("Unit_Price") = _QuoteDetailRow.newUnitPrice
                        _row.Item("Itp") = _QuoteDetailRow.itp

                        'Ryan 20170823 AKR quotations special setting
                        If MyQuoteMaster.quoteNo.ToUpper.StartsWith("AKRQ") AndAlso MyQuoteMaster.isShowListPrice = 1 Then
                            _row.Item("List_Price") = _QuoteDetailRow.listPrice
                            _row.Item("Unit_Price") = _QuoteDetailRow.listPrice
                            _row.Item("Itp") = _QuoteDetailRow.itp
                        End If
                    End If
                    _row.Item("Delivery_Plant") = _QuoteDetailRow.deliveryPlant
                    _row.Item("Category") = _QuoteDetailRow.category
                    _row.Item("class") = _QuoteDetailRow.classABC
                    _row.Item("rohs") = _QuoteDetailRow.rohs
                    _row.Item("Ew_Flag") = EW_Flag
                    _row.Item("req_date") = _QuoteDetailRow.reqDate
                    _row.Item("due_date") = _QuoteDetailRow.dueDate
                    _row.Item("SatisfyFlag") = _QuoteDetailRow.satisfyFlag
                    _row.Item("CanbeConfirmed") = _QuoteDetailRow.canBeConfirmed
                    _row.Item("CustMaterial") = _QuoteDetailRow.custMaterial
                    _row.Item("inventory") = _QuoteDetailRow.inventory

                    '_row.Item("otype") = IIf(_QuoteDetailRow.oType Is Nothing, DBNull.Value, _QuoteDetailRow.oType)
                    _row.Item("otype") = currentItemType
                    _row.Item("Model_No") = _QuoteDetailRow.modelNo
                    _row.Item("QUOTE_ID") = _QuoteDetailRow.quoteId
                    _row.Item("oUnit_Price") = 0 '_QuoteDetailRow.unitPrice
                    If Not IsDBNull(_QuoteDetailRow.unitPrice) AndAlso _QuoteDetailRow.unitPrice IsNot Nothing AndAlso Decimal.TryParse(_QuoteDetailRow.unitPrice, 0) Then
                        _row.Item("oUnit_Price") = _QuoteDetailRow.unitPrice
                    End If
                    '_row.Item("higherLevel") = _QuoteDetailRow.HigherLevel
                    _row.Item("higherLevel") = _higherLevel
                    'Ming 20150601 sync RecyclingFee from Quote
                    _row.Item("RecyclingFee") = 0
                    'If String.Equals(ORG, "US01") Then
                    '    If Not IsDBNull(_QuoteDetailRow.RecyclingFee) AndAlso _QuoteDetailRow.RecyclingFee IsNot Nothing AndAlso Decimal.TryParse(_QuoteDetailRow.RecyclingFee, 0) Then
                    '        _row.Item("RecyclingFee") = _QuoteDetailRow.RecyclingFee
                    '    End If
                    'End If
                    _CartV2DetailDT.Rows.Add(_row)
                Next
                Dim bk As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                bk.DestinationTableName = "CART_DETAIL_V2"
                bk.WriteToServer(_CartV2DetailDT)

                '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : SqlBulkCopy<br />")

                Session("Quote2_5") = True
                'Ming 20120114 CartMaster
                Dim _CartMaster As New CartMaster
                _CartMaster.CartID = _cartid
                _CartMaster.ErpID = MyQuoteMaster.quoteToErpId
                _CartMaster.CreatedDate = Now
                _CartMaster.QuoteID = MyQuoteMaster.quoteId
                _CartMaster.Currency = Session("COMPANY_CURRENCY")
                If MyQuoteMaster.currency IsNot Nothing AndAlso Not String.IsNullOrEmpty(MyQuoteMaster.currency) Then
                    _CartMaster.Currency = MyQuoteMaster.currency
                End If
                _CartMaster.CreatedBy = Session("user_id")
                _CartMaster.LastUpdatedDate = Now
                _CartMaster.LastUpdatedBy = Session("user_id")
                _CartMaster.OpportunityID = eQuotationUtil.GetOptyidQuoteByQuoteid(MyQuoteMaster.quoteId)
                MyCartX.LogCartMaster(_CartMaster)


                '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : MyCartX.LogCartMaster(_CartMaster)<br />")
                'mWatch.Stop()
                'Response.Write(_strb.ToString) : Response.End()

                'Ryan 20161005 Add items validation for MS items like 206Q-
                If String.Equals(Session("org_id"), "EU10") Then
                    Dim CartList As List(Of CartItem) = MyCartX.GetCartList(_cartid)
                    Dim LoosePartsList As List(Of String) = CartList.Where(Function(p) p.Line_No < 100).Select(Function(p) p.Part_No).ToList
                    Dim invalidSWparts As List(Of String) = Advantech.Myadvantech.Business.PartBusinessLogic.isMSSWParts(LoosePartsList, Session("org_id").ToString)
                    If invalidSWparts.Count > 0 Then
                        Response.Redirect("~/Order/Cart_listV2.aspx")
                        Exit Sub
                    End If
                End If


                If MyQuoteMaster.QuoteNoX.StartsWith("GQ", StringComparison.InvariantCultureIgnoreCase) Then
                    Response.Redirect("~/Order/OrderInfo.aspx")
                Else
                    Response.Redirect("~/Order/Cart_listV2.aspx")
                End If
            End If

        End If
    End Sub


    Sub Access(ByVal User As String, ByVal Company As String, ByVal ORG As String)
        FormsAuthentication.SetAuthCookie(User, False)

        '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : FormsAuthentication.SetAuthCookie(User, False)<br />")

        'Frank: If company does not exist in local table sap_dimcompany, then executing the real time syne company function
        Dim SyncCompanyErrMsg As String = String.Empty
        If Not MYSAPBIZ.is_Valid_Company_Id(Company) Then
            'Dim sc As New SAPDAL.syncSingleCompany
            Dim cl As New ArrayList
            cl.Add(Company)
            Dim ds As SAPDAL.DimCompanySet = SAPDAL.syncSingleCompany.syncSingleSAPCustomer(cl, False, SyncCompanyErrMsg)
            If ds Is Nothing OrElse IsNothing(ds.Company) OrElse ds.Company.Count <= 0 Then
                Response.Write("Company id " & Company & " is invalid and cannot be synced from SAP. " & SyncCompanyErrMsg) : Response.End()
            End If
        End If

        Try

            'Frank 20150724 If account in local table Siebel_Account does not have ERPID, then re-sync Siebel account to MyA
            'This is because eQ real-time get account information from Siebel so the quote should be converted order without any issue from changing company function.
            Dim strSqlSiebelContact As String = String.Format(" select top 1 RBU, row_id as account_row_id, isnull(account_name,'') as account_name " & _
                                                      " from siebel_account where RBU is not null and RBU<>'' and ERP_ID='{0}' " & _
                                                      " order by account_status", Company)
            Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim SiebDt As New DataTable
            Dim da As New SqlClient.SqlDataAdapter(strSqlSiebelContact, sqlMA)
            da.Fill(SiebDt)
            If SiebDt.Rows.Count = 0 Then
                Dim _AccountSql As String = String.Format("select  top 1 IsNull(a.ROW_ID,'') as ROWID  from  S_ORG_EXT a inner  join  S_ORG_EXT_X b on a.ROW_ID=b.ROW_ID  where b.ATTRIB_05='{0}'", Company)
                Dim _AccountRowID As Object = dbUtil.dbExecuteScalar("CRMAPPDB", _AccountSql)
                If _AccountRowID IsNot Nothing AndAlso Not String.IsNullOrEmpty(_AccountRowID.ToString.Trim) Then
                    MYSIEBELDAL.SyncAccountFromSiebel2MyAdvantech(_AccountRowID.ToString.Trim)
                End If
            End If
        Catch ex As Exception
        End Try


        If MYSAPBIZ.is_Valid_Company_Id(Company) Then
            AuthUtil.SetSessionById(User, "", Company)
            '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : AuthUtil.SetSessionById(User)<br />")
        Else
            Response.Write("Company id " & Company & " is invalid and cannot be changed to.") : Response.End()
        End If

        '_strb.AppendLine(mWatch.ElapsedMilliseconds & " : au.ChangeCompanyId(Company, ORG)<br />")


        'If Not IsNothing(Request("ORG")) AndAlso Request("ORG") <> "" Then
        '    Dim au As New AuthUtil : au.ChangeCompanyId(Session("company_id"), Request("ORG"))
        'End If

        'If Not IsNothing(Request("RURL")) AndAlso Request("RURL") <> "" Then
        '    Response.Redirect(Request("RURL"))
        'Else
        '    Response.Redirect("~/home.aspx")
        'End If
    End Sub

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    </form>
</body>
</html>
