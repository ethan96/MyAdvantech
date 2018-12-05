Imports Microsoft.VisualBasic

Public Class MyOrderX
    Public Shared Function GetOrderList(ByVal _orderid As String) As List(Of OrderItem)
        If Not String.IsNullOrEmpty(_orderid) Then
            Dim _orderlist As List(Of OrderItem) = MyUtil.Current.MyAContext.OrderItems.Where(Function(p) p.ORDER_ID = _orderid).OrderBy(Function(p) p.LINE_NO).ToList()
            If _orderlist IsNot Nothing Then Return _orderlist
        End If
        Return Nothing
    End Function
    Public Shared Function GetOrderListV2(ByVal _orderid As String) As List(Of OrderItem)
        If Not String.IsNullOrEmpty(_orderid) Then
            Dim _CurrentLing2Sql As MyLing2SqlDataContext = New MyLing2SqlDataContext()
            Dim _orderlist As List(Of OrderItem) = _CurrentLing2Sql.OrderItems.Where(Function(p) p.ORDER_ID = _orderid).OrderBy(Function(p) p.LINE_NO).ToList()
            If _orderlist IsNot Nothing Then Return _orderlist
        End If
        Return Nothing
    End Function
    Public Shared Function GetOrderItem(ByVal _orderid As String, ByVal LineNO As Object) As OrderItem
        If Not String.IsNullOrEmpty(LineNO.ToString) Then
            Dim _OrderItem As OrderItem = GetOrderList(_orderid).SingleOrDefault(Function(p) p.LINE_NO = Integer.Parse(LineNO) AndAlso p.ORDER_ID = _orderid)
            If _OrderItem IsNot Nothing Then Return _OrderItem
        End If
        Return Nothing
    End Function
    Public Shared Function GetCurrencySign(ByVal _OrderID As String) As String
        Dim TempSign As Dictionary(Of String, String) = CType(HttpContext.Current.Cache("TempSign2"), Dictionary(Of String, String))
        If TempSign Is Nothing Then
            TempSign = New Dictionary(Of String, String)
            HttpContext.Current.Cache("TempSign2") = TempSign
            HttpContext.Current.Cache.Add("TempSign2", TempSign, Nothing, DateTime.Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        If (TempSign.ContainsKey(_OrderID)) = False Then
            Dim _Sign As String = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN")
            Dim _obj As Object = dbUtil.dbExecuteScalar("MY", "select  top 1 CURRENCY   from ORDER_MASTER where ORDER_ID='" + _OrderID + "'")
            If _obj IsNot Nothing AndAlso Not String.IsNullOrEmpty(_obj) Then
                _Sign = Util.GetCurrencySignByCurrency(_obj)
            End If
            TempSign.Add(_OrderID, _Sign)
        End If
        Return TempSign.Item(_OrderID)
    End Function
    Public Shared Function IsHaveBtos(ByVal orderid As String) As Boolean
        If Not String.IsNullOrEmpty(orderid) Then
            Dim _OrderItem As OrderItem = MyUtil.Current.MyAContext.OrderItems.Where(Function(p) p.ORDER_LINE_TYPE = -1 AndAlso p.ORDER_ID = orderid).FirstOrDefault()
            If _OrderItem IsNot Nothing Then Return True
        End If
        Return False
    End Function
    Public Shared Function IsEUBtosOrder(ByVal orderid As String) As Boolean
        If HttpContext.Current.Session IsNot Nothing AndAlso String.Equals(HttpContext.Current.Session("org_id"), "EU10", StringComparison.CurrentCultureIgnoreCase) Then
            Return IsHaveBtos(orderid)
        End If
        Return False
    End Function
    Public Shared Function GetCart2OrderMaping(ByVal orderid As String) As Cart2OrderMaping
        Dim _cartMap As Cart2OrderMaping = MyUtil.Current.MyAContext.Cart2OrderMapings.Where(Function(p) p.OrderID = orderid).FirstOrDefault()
        If _cartMap IsNot Nothing Then Return _cartMap
        Return Nothing
    End Function
    Public Shared Function LogCart2OrderMaping(ByVal _Cart2OrderMaping As Cart2OrderMaping) As Boolean
        Try
            Dim _cartMap As Cart2OrderMaping = MyUtil.Current.MyAContext.Cart2OrderMapings.Where(Function(p) p.CartID = _Cart2OrderMaping.CartID).FirstOrDefault()
            If _cartMap IsNot Nothing Then
                _cartMap.CartID = _Cart2OrderMaping.CartID
                _cartMap.OrderID = _Cart2OrderMaping.OrderID
                _cartMap.OrderNo = _Cart2OrderMaping.OrderNo
                _cartMap.CreateTime = _Cart2OrderMaping.CreateTime
                _cartMap.CreateBy = _Cart2OrderMaping.CreateBy
            Else
                MyUtil.Current.MyAContext.Cart2OrderMapings.InsertOnSubmit(_Cart2OrderMaping)
            End If
            MyUtil.Current.MyAContext.SubmitChanges()
            Return True
        Catch ex As Exception
            Return False
        End Try
        Return False
    End Function
    Public Shared Function LogOrderMasterExtension(ByVal orderid As String, ByVal PI2CustomerFlag As Integer, ByVal OrderNoScheme As Integer, ByVal OrderTaxRate As Decimal) As Boolean
        ' Try
        Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = orderid).FirstOrDefault()
        Dim IsNew As Boolean = False
        If MasterExtension Is Nothing Then
            MasterExtension = New orderMasterExtensionV2
            IsNew = True
        End If
        MasterExtension.ORDER_ID = orderid
        MasterExtension.PI2CUSTOMER_FLAG = PI2CustomerFlag
        MasterExtension.OrderNoScheme = OrderNoScheme
        MasterExtension.OrderTaxRate = OrderTaxRate
        If IsNew Then
            MyUtil.Current.MyAContext.orderMasterExtensionV2s.InsertOnSubmit(MasterExtension)
        End If
        MyUtil.Current.MyAContext.SubmitChanges()
        Return True
        'Catch ex As Exception
        '    Return False
        'End Try
        Return False
    End Function
    Public Shared Function GetOrderMasterExtension(ByVal orderid As String) As orderMasterExtensionV2
        Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = orderid).FirstOrDefault()
        If MasterExtension Is Nothing Then
            Return MasterExtension
        End If
        Return Nothing
    End Function
End Class
Partial Public Class OrderItem
    Public ReadOnly Property ItemTypeX As OrderItemType
        Get
            If IsNumeric(Me.ORDER_LINE_TYPE) Then
                'If Me.otype = -1 Then
                'If [Enum].IsDefined(GetType(OrderItemType), Me.ORDER_LINE_TYPE) Then
                '    Return CType([Enum].ToObject(GetType(OrderItemType), Me.ORDER_LINE_TYPE), OrderItemType)
                'End If
                'End If
                If Me.ORDER_LINE_TYPE = 0 Then Return OrderItemType.Part
                If Me.ORDER_LINE_TYPE = -1 Then Return OrderItemType.BtosParent
                If Me.ORDER_LINE_TYPE = 1 Then Return OrderItemType.BtosPart
            End If
            Return OrderItemType.Part
        End Get
    End Property
    Public ReadOnly Property IsEWpartnoX As Boolean
        Get
            If Me.Part_No.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) Then
                Return True
            End If
            Return False
        End Get
    End Property
    Public ReadOnly Property ChildMaxDueDateX As DateTime
        Get
            If Me.ItemTypeX = OrderItemType.BtosParent Then
                '  Dim _CurrentLing2Sql As MyLing2SqlDataContext = New MyLing2SqlDataContext()
                Dim _Childlist As List(Of OrderItem) = MyUtil.Current.MyAContext.OrderItems.Where(Function(p) p.HigherLevel = Me.LINE_NO AndAlso p.ORDER_ID = Me.ORDER_ID).OrderBy(Function(p) p.LINE_NO).ToList()
                If _Childlist.Count > 0 Then
                    Dim _BtosEW As OrderItem = _Childlist.SingleOrDefault(Function(P) P.PART_NO.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase))
                    If _BtosEW IsNot Nothing Then
                        _Childlist.Remove(_BtosEW)
                    End If
                    Dim _MaxDuedate As DateTime = _Childlist.Max(Function(p) p.DUE_DATE)
                    'Dim MaxDUEDATE As String = MyCartOrderBizDAL.getBTOParentDueDate(_MaxDuedate.ToString("yyyy/MM/dd"))
                    Return _MaxDuedate
                End If
            End If
            Return Now
        End Get
    End Property
    Public ReadOnly Property ChildMaxDueDateAddBTOWorkingDateX As DateTime
        Get
            If Me.ItemTypeX = OrderItemType.BtosParent Then
                Dim _CurrentLing2Sql As MyLing2SqlDataContext = New MyLing2SqlDataContext()
                Dim _Childlist As List(Of OrderItem) = _CurrentLing2Sql.OrderItems.Where(Function(p) p.HigherLevel = Me.LINE_NO AndAlso p.ORDER_ID = Me.ORDER_ID).OrderBy(Function(p) p.LINE_NO).ToList()
                If _Childlist.Count > 0 Then
                    Dim _MaxDuedate As DateTime = _Childlist.Max(Function(p) p.DUE_DATE)
                    Dim MaxDUEDATE As String = MyCartOrderBizDAL.getBTOParentDueDate(_MaxDuedate.ToString("yyyy/MM/dd"))
                    Return MaxDUEDATE
                End If
            End If
            Return Now
        End Get
    End Property
    Public ReadOnly Property ChildListX As List(Of OrderItem)
        Get
            If Me.ItemTypeX = OrderItemType.BtosParent Then
                Dim _Childlist As List(Of OrderItem) = MyUtil.Current.MyAContext.OrderItems.Where(Function(p) p.HigherLevel = Me.LINE_NO AndAlso p.ORDER_ID = Me.ORDER_ID).OrderBy(Function(p) p.LINE_NO).ToList()
                If _Childlist.Count > 0 Then
                    Return _Childlist
                End If
            End If
            Return Nothing
        End Get
    End Property
End Class
Public Enum OrderItemType
    BtosParent = -1
    Part = 0
    BtosPart = 1
End Enum
