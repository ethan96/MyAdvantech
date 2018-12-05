Imports Microsoft.VisualBasic

Public Class MyCartX
    Public Shared Function GetCartList(ByVal _caitid As String) As List(Of CartItem)
        If Not String.IsNullOrEmpty(_caitid) Then
            Dim _cartlist As List(Of CartItem) = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.Cart_Id = _caitid).OrderBy(Function(p) p.Line_No).ToList()
            If _cartlist IsNot Nothing Then Return _cartlist
        End If
        Return Nothing
    End Function
    Public Shared Function GetCartItem(ByVal _caitid As String, ByVal LineNO As Object) As CartItem
        If Not String.IsNullOrEmpty(LineNO.ToString) Then
            Dim _CartItem As CartItem = GetCartList(_caitid).SingleOrDefault(Function(p) p.Line_No = Integer.Parse(LineNO) AndAlso p.Cart_Id = _caitid)
            If _CartItem IsNot Nothing Then Return _CartItem
        End If
        Return Nothing
    End Function
    Public Shared Function DeleteCartItem(ByVal cartid As String, ByVal LineNO As Object) As Boolean
        If Not String.IsNullOrEmpty(LineNO.ToString) Then
            Try
                Dim _CurrentLing2Sql = MyUtil.Current.MyAContext
                Dim _CartItem As CartItem = _CurrentLing2Sql.CartItems.SingleOrDefault(Function(p) p.Line_No = LineNO.ToString AndAlso p.Cart_Id = cartid)
                If _CartItem IsNot Nothing Then
                    If _CartItem.ItemTypeX = CartItemType.BtosParent Then
                        Dim _cartlist As List(Of CartItem) = _CurrentLing2Sql.CartItems.Where(Function(p) (p.Line_No = _CartItem.Line_No OrElse p.higherLevel = _CartItem.Line_No) AndAlso p.Cart_Id = cartid).ToList()
                        _CurrentLing2Sql.CartItems.DeleteAllOnSubmit(_cartlist)
                    Else
                        _CurrentLing2Sql.CartItems.DeleteOnSubmit(_CartItem)
                    End If
                    _CurrentLing2Sql.SubmitChanges()
                    If _CartItem.otype = 0 Then
                        Dim EW_item As CartItem = GetCartItem(_CartItem.Cart_Id, _CartItem.Line_No + 1)
                        If EW_item IsNot Nothing AndAlso EW_item.IsEWpartnoX Then
                            _CurrentLing2Sql.CartItems.DeleteOnSubmit(EW_item)
                            _CurrentLing2Sql.SubmitChanges()
                        End If

                        'ICC 2017/01/16 For SRP solution package, if default item (SRP-) has been removed, we also have to remove option items.
                        If _CartItem.Part_No.ToUpper.StartsWith("SRP-") Then
                            dbUtil.dbExecuteNoQuery("MY", String.Format("DELETE FROM SRP_ORDER_LANGUAGE WHERE Cart_ID='{0}' AND Line_No = {1};", cartid, LineNO))
                            Dim _cartlist As List(Of CartItem) = _CurrentLing2Sql.CartItems.Where(Function(p) (p.Line_No = _CartItem.Line_No OrElse p.higherLevel = _CartItem.Line_No) AndAlso p.Cart_Id = cartid).ToList()
                            _CurrentLing2Sql.CartItems.DeleteAllOnSubmit(_cartlist)
                            _CurrentLing2Sql.SubmitChanges()
                        End If

                    End If
                    If _CartItem.ItemTypeX = CartItemType.BtosPart Then
                        Dim items As List(Of CartItem) = MyCartX.GetCartList(_CartItem.Cart_Id).Where(Function(p) p.higherLevel = _CartItem.higherLevel).ToList()
                        Dim EWitem As CartItem = Nothing
                        For Each i As CartItem In items
                            If i.IsEWpartnoX Then
                                EWitem = i : Exit For
                            End If
                        Next
                        If EWitem IsNot Nothing Then
                            Dim BtosParent As CartItem = MyCartX.GetCartItem(_CartItem.Cart_Id, EWitem.higherLevel)
                            If BtosParent IsNot Nothing Then
                                EWitem.Unit_Price = BtosParent.ChildExtendedWarrantyPriceX
                                EWitem.List_Price = EWitem.Unit_Price
                                MyUtil.Current.MyAContext.SubmitChanges()
                            End If

                        End If
                    End If
                End If
                Return True
            Catch ex As Exception
                Return False
            End Try
        End If
        Return False
    End Function
    Public Shared Function DeleteCartAllItem(ByVal cartid As String) As Boolean
        If Not String.IsNullOrEmpty(cartid) Then
            Try
                dbUtil.dbExecuteNoQuery("MY", String.Format("delete from CART_DETAIL_V2 where cart_id='{0}'", cartid))
                Return True
            Catch ex As Exception
                Return False
            End Try
        End If
        Return False
    End Function
    Public Shared Function InsertCartItem(ByVal _CartItem As CartItem) As Boolean
        Try

            MyUtil.Current.MyAContext.CartItems.InsertOnSubmit(_CartItem)
            MyUtil.Current.MyAContext.SubmitChanges()
            If _CartItem.otype = 1 Then
                Dim _cartlist As List(Of CartItem) = Nothing
                Dim EW_item As CartItem = GetCartItem(_CartItem.Cart_Id, _CartItem.Line_No - 1)
                If EW_item IsNot Nothing Then
                    If EW_item.IsEWpartnoX Then
                        Dim cuurent_item As CartItem = GetCartItem(_CartItem.Cart_Id, _CartItem.Line_No)
                        If cuurent_item IsNot Nothing Then
                            EW_item.Line_No = EW_item.Line_No + 1
                            cuurent_item.Line_No = cuurent_item.Line_No - 1
                            _cartlist.Add(cuurent_item)
                            _cartlist.Add(EW_item)
                            DeleteCartItem(cuurent_item.Cart_Id, cuurent_item.Line_No)
                            DeleteCartItem(EW_item.Cart_Id, EW_item.Line_No)
                            MyUtil.Current.MyAContext.CartItems.InsertAllOnSubmit(_cartlist)
                            MyUtil.Current.MyAContext.SubmitChanges()
                        End If
                    End If
                End If
            End If
            Return True
        Catch ex As Exception
            Return False
        End Try
        Return False
    End Function
    Public Shared Function addExtendedWarranty(ByVal _cartitem As CartItem) As Boolean
        If _cartitem Is Nothing Then Return False
        If _cartitem.Ew_Flag = 0 Then Return False
        Dim _EWcartitem As New CartItem
        With _EWcartitem
            .Cart_Id = _cartitem.Cart_Id
            .Line_No = _cartitem.Line_No + 1
            .Part_No = _cartitem.EWpartnoX.EW_PartNO
            .Description = "Extended Warranty for " + _cartitem.EWpartnoX.EW_Month.ToString() + " Months"
            .Qty = _cartitem.Qty
            .List_Price = _cartitem.EWpartnoX.EW_Rate * _cartitem.Unit_Price 'FormatNumber(_cartitem.EWpartnoX.EW_Rate * _cartitem.Unit_Price, 2)
            .otype = _cartitem.otype
            .higherLevel = _cartitem.higherLevel
            If _cartitem.otype = CartItemType.BtosParent Then
                .List_Price = _cartitem.ChildExtendedWarrantyPriceX ' (_cartitem.EWpartnoX.EW_Rate * _cartitem.ChildSubListPriceX) / _cartitem.Qty
                .otype = CartItemType.BtosPart
                .higherLevel = _cartitem.Line_No
                .Line_No = MyCartX.getBtosMaxLineNo(_cartitem.Cart_Id, _cartitem.Line_No) + 1
            End If
            .List_Price = Decimal.Round(Convert.ToDecimal(.List_Price), 2)
            .Unit_Price = .List_Price
            '.Itp = itp
            .Delivery_Plant = _cartitem.Delivery_Plant
            '.Category = category
            '.class = classABC
            '.rohs = ROHS
            .Ew_Flag = 0
            .req_date = _cartitem.req_date
            .due_date = _cartitem.due_date
            .SatisfyFlag = _cartitem.SatisfyFlag
            .CanbeConfirmed = _cartitem.CanbeConfirmed
            .inventory = _cartitem.inventory
            .CustMaterial = ""

            If HttpContext.Current.Session("org_id").ToString.Equals("JP01") Then
                .Itp = .Unit_Price
                .oUnit_Price = .Unit_Price
            End If

        End With
        MyCartX.InsertCartItem(_EWcartitem)
        Return True
    End Function
    Public Shared Function addExtendedWarrantyV2(ByVal _cartitem As CartItem, ByVal EW_id As Integer) As Boolean

        If _cartitem Is Nothing Then Return False
        If _cartitem.otype = CartItemType.Part Then
            If _cartitem.Ew_Flag > 0 Then
                DeleteCartItem(_cartitem.Cart_Id, _cartitem.Line_No + 1)
                _cartitem.Ew_Flag = EW_id
                MyUtil.Current.MyAContext.SubmitChanges()
                addExtendedWarranty(_cartitem)
            End If
            If _cartitem.Ew_Flag = 0 Then
                Dim _EWcartitem As CartItem = GetCartItem(_cartitem.Cart_Id, _cartitem.Line_No + 1)
                If _EWcartitem IsNot Nothing AndAlso _EWcartitem.IsEWpartnoX Then
                    DeleteCartItem(_cartitem.Cart_Id, _cartitem.Line_No + 1)
                End If
                Dim _cartlistdanpin As List(Of CartItem) = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.Cart_Id = _cartitem.Cart_Id AndAlso p.Line_No > _cartitem.Line_No AndAlso p.otype = _cartitem.otype).OrderBy(Function(p) p.Line_No).ToList()
                For Each _cartitemdanpin As CartItem In _cartlistdanpin
                    _cartitemdanpin.Line_No = _cartitemdanpin.Line_No + 1
                Next
                _cartitem.Ew_Flag = EW_id
                MyUtil.Current.MyAContext.SubmitChanges()
                addExtendedWarranty(_cartitem)
            End If
        End If
        If _cartitem.otype = CartItemType.BtosParent Then
            ' If _cartitem.Ew_Flag > 0 Then
            Dim _cartlistbotspart As List(Of CartItem) = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.Cart_Id = _cartitem.Cart_Id AndAlso p.higherLevel = _cartitem.Line_No).OrderBy(Function(p) p.Line_No).ToList()
            For Each _cartitembtospart As CartItem In _cartlistbotspart
                If _cartitembtospart.IsEWpartnoX Then
                    DeleteCartItem(_cartitem.Cart_Id, _cartitembtospart.Line_No)
                Else
                    If _cartitembtospart.isWarrantable() Then
                        _cartitembtospart.Ew_Flag = EW_id
                    End If
                End If
            Next
            ' End If
            _cartitem.Ew_Flag = EW_id

            MyUtil.Current.MyAContext.SubmitChanges()
            addExtendedWarranty(_cartitem)
            MyUtil.Current.MyAContext.SubmitChanges()
        End If
        Return True
    End Function
    ''' <summary>
    ''' 获取但前cart中的所有Btos ParentItem的cartitems
    ''' </summary>
    ''' <param name="caitid"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetBtosParentItems(ByVal caitid As String) As List(Of CartItem)
        If Not String.IsNullOrEmpty(caitid) Then
            Dim _cartlist As List(Of CartItem) = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.Cart_Id = caitid AndAlso p.otype = -1).OrderBy(Function(p) p.Line_No).ToList()
            If _cartlist IsNot Nothing Then Return _cartlist
        End If
        Return Nothing
    End Function
    Public Shared Function getBtosParentLineNo(ByVal cart_id As String) As Integer
        '''
        'Dim ParentLineNo As Integer = 0
        'Dim _cartlist As List(Of CartItem) = GetBtosParentItems(cart_id)
        'Do While True
        '    ParentLineNo = ParentLineNo + 100
        '    Dim _CartItem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = ParentLineNo AndAlso p.Cart_Id = cart_id)
        '    If _CartItem Is Nothing Then
        '        Exit Do
        '    End If
        'Loop
        '''
        Dim ParentLineNo As Integer = 0
        Do While True
            ParentLineNo = ParentLineNo + 100
            If CInt(
              dbUtil.dbExecuteScalar("MY", String.Format("select count(Line_No) as counts from {0} where cart_id='{1}' and Line_No={2}", "CART_DETAIL_V2", cart_id, ParentLineNo))
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return ParentLineNo
    End Function
    Public Shared Function getBtosMaxLineNo(ByVal cart_id As String, ByVal HigherLevel As Integer) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar("MY", String.Format("select max(line_no) from {0} where cart_id='{1}' and (higherLevel={2} or Line_No={2})", "CART_DETAIL_V2", cart_id, HigherLevel))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    ''' <summary>
    ''' 获取单品lineno的最大值
    ''' </summary>
    ''' <param name="cart_id"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function getMaxLineNoV2(ByVal cart_id As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar("MY", String.Format("select max(line_no) from {0} where cart_id='{1}' and otype=0", "CART_DETAIL_V2", cart_id))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Shared Function ReSetLineNo(ByVal _Cartid As String) As Integer
        Dim _cartlist As List(Of CartItem) = GetCartList(_Cartid)
        Dim _cartlistdanpin As List(Of CartItem) = _cartlist.Where(Function(p) p.otype = 0 AndAlso p.Cart_Id = _Cartid).OrderBy(Function(p) p.Line_No).ToList()
        Dim i As Integer = 1
        Dim _srpDictionary As New Dictionary(Of Integer, Integer)
        For Each _cartitem As CartItem In _cartlistdanpin

            'ICC 2017/01/16 For SRP solution package, if default item (SRP-) has been removed, we also have to reset option items' higherlevel no.
            If _cartitem.Part_No.StartsWith("SRP-") AndAlso Not _srpDictionary.ContainsKey(_cartitem.Line_No) Then
                _srpDictionary.Add(_cartitem.Line_No, i)
                dbUtil.dbExecuteNoQuery("MY", String.Format("UPDATE SRP_ORDER_LANGUAGE SET Line_No = {0} WHERE Cart_ID = '{1}' AND Line_No = {2} ", i, _Cartid, _cartitem.Line_No))
            ElseIf Not _srpDictionary Is Nothing AndAlso _srpDictionary.ContainsKey(_cartitem.higherLevel) Then
                Dim newhigherlevel As Integer = 0
                _srpDictionary.TryGetValue(_cartitem.higherLevel, newhigherlevel)
                _cartitem.higherLevel = newhigherlevel
            End If

            _cartitem.Line_No = i
            i = i + 1
        Next
        MyUtil.Current.MyAContext.SubmitChanges()

        Dim _cartlistBtosParentitems As List(Of CartItem) = _cartlist.Where(Function(p) p.otype = -1 AndAlso p.Cart_Id = _Cartid).OrderBy(Function(p) p.Line_No).ToList()

        For Each _cartitem As CartItem In _cartlistBtosParentitems
            i = _cartitem.Line_No + 1
            Dim lineno As Integer = _cartitem.Line_No
            Dim _cartlistBtoslines As List(Of CartItem) = _cartlist.Where(Function(p) p.higherLevel = lineno AndAlso p.Cart_Id = _Cartid).OrderBy(Function(p) p.Line_No).ToList()
            For Each _cartline As CartItem In _cartlistBtoslines
                _cartline.Line_No = i
                i = i + 1
            Next
        Next
        MyUtil.Current.MyAContext.SubmitChanges()
        'If _CartItem.IsBtosParentItemX Then Return 1
        'Dim _cartlist As List(Of CartItem) = Nothing
        'If _CartItem.otype = 0 Then
        '    _cartlist = MyUtil.Current.MyAContext.CartItems.Where(Function(p) (p.Line_No > _CartItem.Line_No AndAlso p.Line_No < 100) AndAlso p.Cart_Id = _CartItem.Cart_Id).ToList()
        'End If
        'If _CartItem.otype = 1 Then
        '    _cartlist = MyUtil.Current.MyAContext.CartItems.Where(Function(p) (p.Line_No > _CartItem.Line_No AndAlso p.higherLevel = _CartItem.higherLevel) AndAlso p.Cart_Id = _CartItem.Cart_Id).ToList()
        'End If
        'For Each _cartitem1 As CartItem In _cartlist
        '    _cartitem1.Line_No = _cartitem1.Line_No - 1
        'Next
        'If _cartlist.Count > 0 Then
        '    MyUtil.Current.MyAContext.SubmitChanges()
        'End If
        Return 1
    End Function
    Public Shared Function GetExtendedWarranty() As List(Of EWPartNo)
        If HttpContext.Current.Session("org_id") IsNot Nothing Then
            Dim org As String = Left(HttpContext.Current.Session("org_id"), 2)
            'ICC 2014/09/15 RemoveTW org because it has data in ExtendedWarrantyPartNo_V2

            Dim _EWlist As List(Of EWPartNo) = Nothing
            If HttpContext.Current.Cache("EWPartNoList") Is Nothing Then
                _EWlist = MyUtil.Current.MyAContext.EWPartNos.ToList
                HttpContext.Current.Cache.Insert("EWPartNoList", _EWlist, Nothing, DateTime.Now.AddHours(8), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
            Else
                _EWlist = CType(HttpContext.Current.Cache("EWPartNoList"), List(Of EWPartNo))
            End If
            Dim _CurrEWlist As List(Of EWPartNo) = _EWlist.Where(Function(p) p.Plant.StartsWith(org)).OrderBy(Function(p) p.SeqNO).ToList()
            If _CurrEWlist IsNot Nothing Then Return _CurrEWlist
        End If
        Return Nothing
    End Function
    Public Shared Function GetExtendedWarrantyPartno(ByVal EWPartNoID As Integer) As EWPartNo
        Dim _EWPartNo As EWPartNo = GetExtendedWarranty().SingleOrDefault(Function(p) p.ID = EWPartNoID)
        If _EWPartNo IsNot Nothing Then
            Return _EWPartNo
        End If
        Return Nothing
    End Function
    ''' <summary>
    ''' 获取cart unitprice总和
    ''' </summary>
    ''' <param name="_cartid"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function GetTotalAmount(ByVal _cartid As String) As Decimal
        Dim _cartlist As List(Of CartItem) = GetCartList(_cartid)
        If _cartlist.Count > 0 Then
            Return _cartlist.Sum(Function(p) p.Unit_Price * p.Qty)
        End If
        Return 0
    End Function
    Public Shared Function UpOrDownLineNo(ByVal cartid As String, ByVal lineno As Integer, ByVal willdo As String) As Boolean
        If Not String.IsNullOrEmpty(cartid) Then
            Dim _cartlist As List(Of CartItem) = GetCartList(cartid)
            If _cartlist.Count > 0 Then
                Select Case willdo
                    Case "up"
                        Dim _up2cartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno - 2 AndAlso p.Cart_Id = cartid)
                        Dim _up1cartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno - 1 AndAlso p.Cart_Id = cartid)
                        Dim _currentcartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno AndAlso p.Cart_Id = cartid)
                        Dim _dn1cartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno + 1 AndAlso p.Cart_Id = cartid)
                        If _currentcartitem IsNot Nothing AndAlso _up1cartitem IsNot Nothing AndAlso _currentcartitem.otype = CartItemType.Part Then
                            If _currentcartitem.Ew_Flag > 0 Then
                                If _up1cartitem IsNot Nothing AndAlso Not _up1cartitem.IsEWpartnoX Then
                                    _currentcartitem.Line_No = lineno - 1
                                    _up1cartitem.Line_No = lineno + 1
                                    _dn1cartitem.Line_No = lineno
                                End If
                                If _up1cartitem IsNot Nothing AndAlso _up1cartitem.IsEWpartnoX Then
                                    _currentcartitem.Line_No = lineno - 2
                                    _dn1cartitem.Line_No = lineno - 1
                                    _up2cartitem.Line_No = lineno
                                    _up1cartitem.Line_No = lineno + 1
                                End If
                            End If
                            If _currentcartitem.Ew_Flag = 0 Then
                                If _up1cartitem IsNot Nothing AndAlso Not _up1cartitem.IsEWpartnoX Then
                                    _currentcartitem.Line_No = lineno - 1
                                    _up1cartitem.Line_No = lineno
                                End If
                                If _up1cartitem IsNot Nothing AndAlso _up1cartitem.IsEWpartnoX Then
                                    _currentcartitem.Line_No = lineno - 2
                                    _up2cartitem.Line_No = lineno - 1
                                    _up1cartitem.Line_No = lineno
                                End If
                            End If
                        End If
                        If _currentcartitem.otype = CartItemType.BtosPart Then
                            If _up1cartitem IsNot Nothing Then
                                If _up1cartitem.otype <> CartItemType.BtosParent Then
                                    _currentcartitem.Line_No = lineno - 1
                                    _up1cartitem.Line_No = lineno
                                End If
                            End If
                        End If

                    Case "down"

                        Dim _currentcartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno AndAlso p.Cart_Id = cartid)
                        Dim _dn1cartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno + 1 AndAlso p.Cart_Id = cartid)
                        Dim _dn2cartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno + 2 AndAlso p.Cart_Id = cartid)
                        Dim _dn3cartitem As CartItem = _cartlist.SingleOrDefault(Function(p) p.Line_No = lineno + 3 AndAlso p.Cart_Id = cartid)
                        If _currentcartitem IsNot Nothing AndAlso _currentcartitem.otype = CartItemType.Part Then
                            If _currentcartitem.Ew_Flag > 0 Then
                                If _dn2cartitem IsNot Nothing AndAlso _dn2cartitem.Ew_Flag = 0 Then
                                    _dn2cartitem.Line_No = lineno
                                    _currentcartitem.Line_No = lineno + 1
                                    _dn1cartitem.Line_No = lineno + 2
                                End If
                                If _dn2cartitem IsNot Nothing AndAlso _dn2cartitem.Ew_Flag > 0 Then
                                    _dn2cartitem.Line_No = lineno
                                    _dn3cartitem.Line_No = lineno + 1
                                    _currentcartitem.Line_No = lineno + 2
                                    _dn1cartitem.Line_No = lineno + 3
                                End If
                            End If
                            If _currentcartitem.Ew_Flag = 0 AndAlso _dn1cartitem IsNot Nothing Then
                                If _dn1cartitem.Ew_Flag = 0 Then
                                    _dn1cartitem.Line_No = lineno
                                    _currentcartitem.Line_No = lineno + 1
                                End If
                                If _dn1cartitem.Ew_Flag > 0 Then
                                    _dn1cartitem.Line_No = lineno
                                    _dn2cartitem.Line_No = lineno + 1
                                    _currentcartitem.Line_No = lineno + 2
                                End If
                            End If

                        End If
                        If _currentcartitem.otype = CartItemType.BtosPart Then
                            If _dn1cartitem IsNot Nothing AndAlso Not _dn1cartitem.IsEWpartnoX Then
                                _currentcartitem.Line_No = lineno + 1
                                _dn1cartitem.Line_No = lineno
                            End If
                        End If
                End Select
                MyUtil.Current.MyAContext.SubmitChanges()

            End If
        End If
        Return False
    End Function
    Public Shared Function ResetDueDate(ByVal _cartitem As CartItem) As Boolean
        Dim duedate As String = "", inventory As Integer = 0, satisflag As Integer = 0, qtyCanbeConfirmed As Integer = 0, req_date As String = _cartitem.req_date.ToString()
        SAPtools.getInventoryAndATPTable(_cartitem.Part_No, _cartitem.Delivery_Plant, _cartitem.Qty, duedate, inventory, Nothing, req_date, satisflag, qtyCanbeConfirmed)
        _cartitem.due_date = duedate
        _cartitem.inventory = inventory
        _cartitem.SatisfyFlag = satisflag
        _cartitem.CanbeConfirmed = qtyCanbeConfirmed
        MyUtil.Current.MyAContext.SubmitChanges()
        Return True
    End Function
    Public Shared Function IsHaveBtos(ByVal cartid As String) As Boolean
        If Not String.IsNullOrEmpty(cartid) Then
            Dim _CartItem As CartItem = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.otype = -1 AndAlso p.Cart_Id = cartid).FirstOrDefault()
            If _CartItem IsNot Nothing Then Return True
        End If
        Return False
    End Function

    Public Shared Function IsComboCart(ByVal cartid As String) As Boolean
        If Not String.IsNullOrEmpty(cartid) Then
            'Frank 20160302 Get loose item
            Dim _LooseItem As CartItem = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.otype = 0 AndAlso p.Cart_Id = cartid).FirstOrDefault()
            'Frank 20160302 Get system parent item
            Dim _BTOSParentItem As CartItem = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.otype = -1 AndAlso p.Cart_Id = cartid).FirstOrDefault()
            If _BTOSParentItem IsNot Nothing AndAlso _LooseItem IsNot Nothing Then Return True
        End If
        Return False
    End Function



    Public Shared Function IsEUBtosCart(ByVal cartid As String) As Boolean
        If HttpContext.Current.Session IsNot Nothing AndAlso String.Equals(HttpContext.Current.Session("org_id"), "EU10", StringComparison.CurrentCultureIgnoreCase) Then
            Return IsHaveBtos(cartid)
        End If
        Return False
    End Function
    Public Shared Function IsHaveSBCB(ByVal cartid As String) As Boolean
        If Not String.IsNullOrEmpty(cartid) Then
            Dim _CartItem As CartItem = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.otype = -1 AndAlso p.Cart_Id = cartid AndAlso p.Part_No = "SBC-BTO").FirstOrDefault()
            If _CartItem IsNot Nothing Then Return True
        End If
        Return False
    End Function
    Public Shared Function IsHaveItems(ByVal cartid As String) As Boolean
        If Not String.IsNullOrEmpty(cartid) Then
            Dim _cartlist As List(Of CartItem) = GetCartList(cartid)
            If _cartlist.Count > 0 Then Return True
        End If
        Return False
    End Function
    Public Shared Function IsQuote2Cart(ByVal cartid As String, ByRef Quoteid As String) As Boolean
        If Not String.IsNullOrEmpty(cartid) Then
            Dim _CartItem As CartItem = MyCartX.GetCartList(cartid).Where(Function(p) p.QUOTE_ID <> "" AndAlso p.QUOTE_ID IsNot Nothing AndAlso p.Cart_Id = cartid).OrderBy(Function(p) p.Line_No).FirstOrDefault()
            If _CartItem IsNot Nothing Then
                Quoteid = _CartItem.QUOTE_ID.ToString.Trim
                Return True
            End If
        End If
        Return False
    End Function
    ' CartMaster
    Public Shared Function LogCartMaster(ByVal _CartMaster As CartMaster) As Boolean
        Try
            Dim _cartM As CartMaster = MyUtil.Current.MyAContext.CartMasters.Where(Function(p) p.CartID = _CartMaster.CartID).FirstOrDefault()
            If _cartM IsNot Nothing Then
                _cartM.ErpID = _CartMaster.ErpID
                _cartM.QuoteID = _CartMaster.QuoteID
                _cartM.OpportunityID = _CartMaster.OpportunityID
                _cartM.Currency = _CartMaster.Currency
                _cartM.CreatedDate = _CartMaster.CreatedDate
                _cartM.CreatedBy = _CartMaster.CreatedBy
                _cartM.LastUpdatedDate = _CartMaster.LastUpdatedDate
                _cartM.LastUpdatedBy = _CartMaster.LastUpdatedBy
            Else
                MyUtil.Current.MyAContext.CartMasters.InsertOnSubmit(_CartMaster)
            End If
            MyUtil.Current.MyAContext.SubmitChanges()
            Return True
        Catch ex As Exception
            Return False
        End Try
        Return False
    End Function
    Public Shared Function GetCartMaster(ByVal _CartID As String) As CartMaster
        Dim _CartMaster As CartMaster = MyUtil.Current.MyAContext.CartMasters.Where(Function(p) p.CartID = _CartID).FirstOrDefault()
        If _CartMaster IsNot Nothing Then
            Return _CartMaster
        End If
        Return Nothing
    End Function
    Public Shared Function Copy2Cart(ByVal _oldCartID As String, ByVal _newCartID As String) As Boolean
        Dim mycart As New CartList("b2b", "CART_DETAIL_V2")
        Dim ORG As String = HttpContext.Current.Session("org_id").ToString.Trim, COMPANY_ID As String = HttpContext.Current.Session("COMPANY_ID")
        Dim currency As String = MyCartX.GetCurrency(_newCartID)
        Dim ReqDate As DateTime = SAPDOC.GetLocalTime(ORG.Substring(0, 2))
        ReqDate = MyCartOrderBizDAL.getCompNextWorkDate(DateAdd(DateInterval.Day, 1, ReqDate), ORG)
        Dim lineNo As Integer = 0
        Dim _CartList As List(Of CartItem) = MyCartX.GetCartList(_oldCartID)
        Dim Ew_Flag As Integer = 0
        Dim _EWlist As List(Of EWPartNo) = MyCartX.GetExtendedWarranty()
        'Dim cartEX As CartItem = _CartList.Where(Function(p) p.Part_No.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase)).FirstOrDefault()
        If _CartList.Count > 0 Then
            MyCartX.DeleteCartAllItem(_newCartID)
            For Each i As CartItem In _CartList
                If Not i.IsEWpartnoX Then
                    'Dim EXpartNo As EWPartNo = _EWlist.Where(Function(p) p.ID = i.Ew_Flag).FirstOrDefault()
                    'If EXpartNo IsNot Nothing Then
                    '        Ew_Flag = EXpartNo.ID
                    'Else
                    '        Ew_Flag = 0
                    '    End If
                    'lineNo = mycart.ADD2CART_V2(_newCartID, i.Part_No, i.Qty, Ew_Flag, i.otype, i.Category, 1, 1, ReqDate, "", "", i.higherLevel, False)

                    'ICC 2015/5/18 Fix [Save My Cart] function. Only have to copy cart data from CART_DETAIL_V2 and replace cart id from session to new id.
                    Dim dtPriceRec As New DataTable, unitprice As Decimal = 0, listprice As Decimal = 0
                    SAPtools.getSAPPriceByTable(i.Part_No, 1, ORG, COMPANY_ID, currency, dtPriceRec)
                    If dtPriceRec.Rows.Count > 0 Then
                        unitprice = FormatNumber(dtPriceRec.Rows(0).Item("Netwr"), 2).Replace(",", "")
                        listprice = FormatNumber(dtPriceRec.Rows(0).Item("Kzwi1"), 2).Replace(",", "")
                    End If
                    Dim _cartItem As New CartItem
                    With _cartItem
                        .Cart_Id = _newCartID
                        .Line_No = i.Line_No
                        .Part_No = i.Part_No
                        .Description = i.Description
                        .Qty = i.Qty
                        .List_Price = listprice
                        .Unit_Price = unitprice
                        .Itp = i.Itp
                        .Delivery_Plant = i.Delivery_Plant
                        .Category = i.Category
                        .class = i.class
                        .rohs = i.rohs
                        .Ew_Flag = i.Ew_Flag
                        .req_date = i.req_date
                        .due_date = i.due_date
                        .SatisfyFlag = i.SatisfyFlag
                        .CanbeConfirmed = i.CanbeConfirmed
                        .CustMaterial = i.CustMaterial
                        .inventory = i.inventory
                        .otype = i.otype
                        .Model_No = i.Model_No
                        .higherLevel = i.higherLevel
                    End With
                    MyCartX.InsertCartItem(_cartItem)
                Else
                    'Ryan 20170315 Recalculate EW items price
                    Dim unitprice As Decimal = 0, listprice As Decimal = 0
                    Dim targetitem As New CartItem, targetlineno As Integer
                    If i.Line_No < 100 Then
                        targetlineno = i.Line_No - 1
                        targetitem = MyCartX.GetCartItem(_oldCartID, targetlineno)
                        listprice = targetitem.EWpartnoX.EW_Rate * targetitem.Unit_Price
                    ElseIf i.Line_No > 100 Then
                        targetlineno = i.higherLevel
                        targetitem = MyCartX.GetCartItem(_oldCartID, targetlineno)
                        listprice = targetitem.ChildExtendedWarrantyPriceX
                    End If
                    listprice = Decimal.Round(listprice, 2)
                    unitprice = listprice

                    Dim _cartItem As New CartItem
                    With _cartItem
                        .Cart_Id = _newCartID
                        .Line_No = i.Line_No
                        .Part_No = i.Part_No
                        .Description = i.Description
                        .Qty = i.Qty
                        .List_Price = listprice
                        .Unit_Price = unitprice
                        .Itp = i.Itp
                        .Delivery_Plant = i.Delivery_Plant
                        .Category = i.Category
                        .class = i.class
                        .rohs = i.rohs
                        .Ew_Flag = i.Ew_Flag
                        .req_date = i.req_date
                        .due_date = i.due_date
                        .SatisfyFlag = i.SatisfyFlag
                        .CanbeConfirmed = i.CanbeConfirmed
                        .CustMaterial = i.CustMaterial
                        .inventory = i.inventory
                        .otype = i.otype
                        .Model_No = i.Model_No
                        .higherLevel = i.higherLevel
                    End With
                    MyCartX.InsertCartItem(_cartItem)
                End If
            Next
            'Dim _CartListV2 As List(Of CartItem) = MyCartX.GetCartList(_newCartID)
            'If _CartListV2.Count > 0 Then
            '    For Each i As CartItem In _CartListV2

            '    Next
            'End If
        End If
        Return True
    End Function
    Public Shared Function GetCurrency(ByVal _CartID As String) As String
        Dim _CartMaster As CartMaster = GetCartMaster(_CartID)
        If _CartMaster IsNot Nothing AndAlso Not String.IsNullOrEmpty(_CartMaster.Currency) Then
            Return _CartMaster.Currency
        End If
        Return HttpContext.Current.Session("COMPANY_CURRENCY")
    End Function
    Public Shared Function GetCurrencySign(ByVal _CartID As String) As String
        Dim TempSign As Dictionary(Of String, String) = CType(HttpContext.Current.Cache("TempSign"), Dictionary(Of String, String))
        If TempSign Is Nothing Then
            TempSign = New Dictionary(Of String, String)
            HttpContext.Current.Cache("TempSign") = TempSign
            HttpContext.Current.Cache.Add("TempSign", TempSign, Nothing, DateTime.Now.AddHours(2), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If
        If (TempSign.ContainsKey(_CartID)) = False Then
            Dim _Sign As String = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN")
            Dim _CartMaster As CartMaster = GetCartMaster(_CartID)
            If _CartMaster IsNot Nothing AndAlso Not String.IsNullOrEmpty(_CartMaster.Currency) Then
                _Sign = Util.GetCurrencySignByCurrency(_CartMaster.Currency)
            End If
            TempSign.Add(_CartID, _Sign)
        End If
        Return TempSign.Item(_CartID)
    End Function

    Public Shared Function GetTotalITP(ByVal _cartid As String) As Decimal
        Dim _cartlist As List(Of CartItem) = GetCartList(_cartid)
        If _cartlist.Count > 0 Then
            Return _cartlist.Sum(Function(p) p.Itp * p.Qty)
        End If
        Return 0
    End Function

    Public Shared Function GetTotalMargin(ByVal _cartid As String) As Decimal
        Dim _cartlist As List(Of CartItem) = GetCartList(_cartid)
        If _cartlist.Count > 0 Then
            Dim sumAmt As Decimal = 0, sumITP As Decimal = 0

            For Each c As CartItem In _cartlist
                sumAmt += c.Unit_Price * c.Qty
                sumITP += c.Itp * c.Qty
            Next
            If Not sumAmt = 0 Then
                Return (sumAmt - sumITP) / sumAmt
            Else
                Return 0
            End If
        End If
        Return 0
    End Function

End Class
Partial Public Class CartItem
    Private _X As String
    Public Property X As String
        Get
            Return _X
        End Get
        Set(ByVal value As String)
            _X = value
        End Set
    End Property
    Public ReadOnly Property ItemTypeX As CartItemType
        Get
            If IsNumeric(Me.otype) Then
                If Me.otype = -1 Then Return CartItemType.BtosParent
                If Me.otype = 1 Then Return CartItemType.BtosPart
                If Me.otype = 0 Then Return CartItemType.Part
                'If [Enum].IsDefined(GetType(CartItemType), Me.otype) Then
                '    Return CType([Enum].ToObject(GetType(CartItemType), Me.otype), CartItemType)
                'End If
                'End If
            End If
            Return CartItemType.Part
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
    Public ReadOnly Property isWarrantable As Boolean
        Get
            If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso SAPDAL.CommonLogic.isWarrantableV3(Me.Part_No, HttpContext.Current.Session("org_id")) Then
                Return True
            End If
            Return False
        End Get
    End Property
    Public ReadOnly Property EWpartnoX As EWPartNo
        Get
            If IsNumeric(Me.Ew_Flag) AndAlso Me.Ew_Flag > 0 Then
                Return MyCartX.GetExtendedWarrantyPartno(Me.Ew_Flag)
            End If
            Return Nothing
        End Get
    End Property
    Public ReadOnly Property ChildListX As List(Of CartItem)
        Get
            If Me.ItemTypeX = CartItemType.BtosParent Then
                Dim _Childlist As List(Of CartItem) = MyUtil.Current.MyAContext.CartItems.Where(Function(p) p.higherLevel = Me.Line_No AndAlso p.Cart_Id = Me.Cart_Id).OrderBy(Function(p) p.Line_No).ToList()
                If _Childlist.Count > 0 Then
                    Return _Childlist
                End If
            End If
            Return Nothing
        End Get
    End Property

    Public ReadOnly Property ChildSubListPriceX As Decimal
        Get
            If Me.ItemTypeX = CartItemType.BtosParent Then
                Dim _CurrentLing2Sql As MyLing2SqlDataContext = New MyLing2SqlDataContext()
                Dim _cartlistBtosChild As List(Of CartItem) = _CurrentLing2Sql.CartItems.Where(Function(p) p.higherLevel = Me.Line_No AndAlso p.Cart_Id = Me.Cart_Id).OrderBy(Function(p) p.Line_No).ToList()
                If _cartlistBtosChild.Count > 0 Then
                    'Me.List_Price = _cartlistBtosChild.Sum(Function(p) p.List_Price)
                    Return _cartlistBtosChild.Sum(Function(p) p.List_Price * p.Qty)
                End If

            End If
            Return 0
        End Get
    End Property
    Public ReadOnly Property ChildSubUnitPriceX As Decimal
        Get
            If Me.ItemTypeX = CartItemType.BtosParent Then
                Dim _CurrentLing2Sql As MyLing2SqlDataContext = New MyLing2SqlDataContext()
                Dim _cartlistBtosChild As List(Of CartItem) = _CurrentLing2Sql.CartItems.Where(Function(p) p.higherLevel = Me.Line_No AndAlso p.Cart_Id = Me.Cart_Id).OrderBy(Function(p) p.Line_No).ToList()
                If _cartlistBtosChild.Count > 0 Then
                    ' Me.Unit_Price = _cartlistBtosChild.Sum(Function(p) p.Unit_Price)
                    Return _cartlistBtosChild.Sum(Function(p) p.Unit_Price * p.Qty)
                End If
            End If
            Return 0
        End Get
    End Property
    Public ReadOnly Property ChildExtendedWarrantyPriceX As Decimal
        Get
            If Me.ItemTypeX = CartItemType.BtosParent Then
                Dim _CurrentLing2Sql As MyLing2SqlDataContext = New MyLing2SqlDataContext()
                Dim _cartlistBtosChild As List(Of CartItem) = _CurrentLing2Sql.CartItems.Where(Function(p) p.higherLevel = Me.Line_No AndAlso p.Cart_Id = Me.Cart_Id).OrderBy(Function(p) p.Line_No).ToList()
                If _cartlistBtosChild.Count > 0 Then
                    'Me.List_Price = _cartlistBtosChild.Sum(Function(p) p.List_Price)
                    Return Me.EWpartnoX.EW_Rate * _cartlistBtosChild.Where(Function(p) p.isWarrantable = True).Sum(Function(p) p.Unit_Price * (p.Qty / Me.Qty))
                End If

            End If
            Return 0
        End Get
    End Property
    Public ReadOnly Property IsSpecialADAMX As Boolean
        Get
            If Me.otype = CartItemType.Part Then
                Return MyCartOrderBizDAL.IsSpecialADAM(Me.Part_No)
            End If
            Return False
        End Get
    End Property
    Public ReadOnly Property SpecialADAM_EW As List(Of EWPartNo)
        Get
            Dim _EWlist As List(Of EWPartNo) = MyCartX.GetExtendedWarranty().Where(Function(p) p.ID = 19).ToList
            If _EWlist.Count > 0 Then Return _EWlist
            Return Nothing
        End Get
    End Property

    Private Indicator As String = String.Empty
    Private PartType As Boolean = False
    Public Property ABC_Indicator As String
        Get
            Return Indicator
        End Get
        Set(value As String)
            Indicator = value
        End Set
    End Property
    Public Property Is_NCNR_Part As Boolean
        Get
            Return PartType
        End Get
        Set(value As Boolean)
            PartType = value
        End Set
    End Property

End Class
Public Enum CartItemType
    BtosParent = -1
    Part = 0
    BtosPart = 1
End Enum
