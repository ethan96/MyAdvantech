Imports Microsoft.VisualBasic

Public Class MyCartOrderBizDAL

    Public Shared Function IsEUStockingProgram(ByVal PartNO As String, ByVal QTY As Integer) As Boolean
        Dim SQL As String = String.Format("select count(*) from ADMIN_PREFERENTIAL_PRODS where COMPANY_ID='{0}' and  PART_NO ='{1}' and {2}>=MIN_ORDER_QTY", _
                                          HttpContext.Current.Session("COMPANY_ID").ToString, PartNO, QTY)
        Dim obj As Object = dbUtil.dbExecuteScalar("MYLOCAL", SQL)
        If obj IsNot Nothing AndAlso CInt(obj) > 0 Then Return True
        Return False
    End Function
    Public Shared Function Add2Cart_BIZ(ByVal cart_id As String, ByVal part_no As String, ByVal QTY As Integer, ByVal EW_FLAG As Integer _
                        , ByVal itemType As Integer, ByVal category As String, ByVal isSyncPrice As Integer _
                        , ByVal isSyncATP As Integer, ByVal ReqDate As DateTime _
                        , ByVal description As String, ByVal delivery_plant As String, ByVal higherLevel As Integer, Optional ByVal isautoaddEX As Boolean = False, Optional ByRef msg As String = "", Optional ByVal Parent_item_selected As Boolean = False) As Integer
        'for CN Block MEDC product to show price
        'If (HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN") AndAlso SAPDAL.CommonLogic.isMEDC(part_no) AndAlso Not Util.IsInternalUser2()) Then
        '    msg = "Part No '" & part_no & "' cannot be added to cart, please contact sales."
        '    Return 0
        'End If
        If part_no.StartsWith("Build In", StringComparison.OrdinalIgnoreCase) Then Return 1

        Dim mycart As New CartList("b2b", "CART_DETAIL_V2"), myproduct As New SAPProduct("b2b", "SAP_PRODUCT")
        Dim myproductABC As New SAPProduct("b2b", "SAP_PRODUCT_ABC")
        Dim ORG_ID As String = HttpContext.Current.Session("org_id"), COMPANY_ID As String = HttpContext.Current.Session("COMPANY_ID")
        If itemType = CartItemType.Part AndAlso Not SAPDAL.CommonLogic.isAllowedAddEW(part_no, "", ORG_ID) Then
            EW_FLAG = 0
        End If
        Dim currency As String = MyCartX.GetCurrency(cart_id) ' HttpContext.Current.Session("COMPANY_Currency")
        Dim line_no As Integer = 0
        Dim listprice As Decimal = 0.0, unitprice As Decimal = 0.0, itp As Decimal = 0.0
        'Dim delivery_plant As String = "", classABC As String = "", ROHS As Integer = 0, req_date As Date = Now.Date
        Dim classABC As String = "", ROHS As Integer = 0, req_date As Date = Now.Date
        Dim due_date As Date = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2)).Date, inventory As Int32 = 0, satisfyFlag As Integer = 0, canbeConfirmed As Integer = 0
        Dim custMaterial As String = "", otype As Integer = 0, Model_NO As String = ""
        part_no = part_no.ToUpper() : otype = itemType
        'If (itemType <> -1) Then
        '    Dim ws As New quote.quoteExit
        '    ws.Timeout = -1
        '    If ws.isPhaseOut(part_no, ORG_ID) Then
        '        Glob.ShowInfo("Phase Out : " & part_no)
        '        Return 0
        '    End If
        'End If
        If ORG_ID = "EU10" Then
            ' Unblock 96HD 20140505
            If otype = 0 Then
                If part_no.ToUpper.StartsWith("96MD") Then 'And otype = 0 Then
                    'If (part_no.ToUpper.StartsWith("96MD") Or part_no.ToUpper.StartsWith("96HD")) And otype = 0 Then
                    msg = "Hard drive cannot be placed as component order"
                    Return 0
                End If
                If part_no.ToUpper.StartsWith("IMG-") OrElse part_no.ToUpper.StartsWith("IMG ") Then ' And otype = 0 Then
                    msg = "Software image cannot be placed as component order"
                    Return 0
                End If
            End If
        End If
        Dim strStatusCode As String = "", strStatusDesc As String = "", ExtensionDesc As String = String.Empty
        'If (itemType = 0) AndAlso (Not OrderUtilities.Add2CartCheck(part_no, "", strStatusCode, strStatusDesc, otype)) Then
        If Not OrderUtilities.Add2CartCheck(part_no, "", strStatusCode, strStatusDesc, otype) Then
            If Util.IsInternalUser2() Then ExtensionDesc = "  Status [ " + strStatusCode + " ], " + strStatusDesc
            msg = "Invalid PN  : " & part_no + ExtensionDesc
            Return 0
        End If

        If otype = CartItemType.BtosParent Then
            line_no = MyCartX.getBtosParentLineNo(cart_id)
        ElseIf otype = CartItemType.BtosPart Then
            line_no = MyCartX.getBtosMaxLineNo(cart_id, higherLevel) + 1
        Else
            line_no = MyCartX.getMaxLineNoV2(cart_id) + 1
        End If
        QTY = CInt(QTY)
        Dim DTSAPPRODUCT As DataTable = myproduct.GetDT(String.Format("part_no='{0}'", part_no), "")
        If DTSAPPRODUCT.Rows.Count > 0 Then

            'Ryan 20180706 Disable below logic for ADLoG external launch
            'Frank 2012/01/10
            'Product of product line DLGR can not be added to cart if current user is external user.
            'If Util.IsInternalUser2() = False Then
            '    If DTSAPPRODUCT.Rows(0).Item("Product_line").ToString.Equals("DLGR", StringComparison.InvariantCultureIgnoreCase) Then
            '        'Glob.ShowInfo("You have no permission to  place this product as order")
            '        Return 0
            '    End If
            'End If

            'Ryan 20180418 Part with material group = BTOS is not allowed to add
            If itemType <> -1 AndAlso DTSAPPRODUCT.Rows(0).Item("MATERIAL_GROUP").ToString.Equals("BTOS", StringComparison.InvariantCultureIgnoreCase) Then
                msg = "BTO Item cannot be added as component."
                Return 0
            End If

            If String.IsNullOrEmpty(description) Then
                If Not IsDBNull(DTSAPPRODUCT.Rows(0).Item("Product_desc")) Then
                    description = DTSAPPRODUCT.Rows(0).Item("Product_desc")

                Else
                    description = ""
                End If
            End If
            description = description.Replace("'", "''")
            ROHS = IIf(IsNumeric(DTSAPPRODUCT.Rows(0).Item("rohs_flag")), DTSAPPRODUCT.Rows(0).Item("rohs_flag"), 0)
            Model_NO = DTSAPPRODUCT.Rows(0).Item("Model_no")
        End If

        itp = 0.0
        'If String.IsNullOrEmpty(delivery_plant) Then delivery_plant = OrderUtilities.getPlant()
        If String.IsNullOrEmpty(delivery_plant) Then delivery_plant = OrderUtilities.getPartDefaultPlant(part_no, HttpContext.Current.Session("org_id"))

        If String.Equals(HttpContext.Current.Session("org_id"), "TW01") Then
            ' JJ 2014/2/27：TW01的組裝單，子階料號請設定delivery plant=TWH1，不從SAP帶default delivery plant過來
            If otype = CartItemType.BtosParent OrElse otype = CartItemType.BtosPart Then
                delivery_plant = "TWH1"
            Else
                Dim sql As String = String.Format("select top 1 DELIVERYPLANT from SAP_PRODUCT_ORG where ORG_ID='TW01' and PART_NO = '{0}'", part_no)

                Dim obj As Object = dbUtil.dbExecuteScalar("MY", sql)
                If obj IsNot Nothing Then
                    delivery_plant = obj.ToString()
                End If
            End If
        ElseIf String.Equals(HttpContext.Current.Session("org_id"), "US10") Then
            If otype = CartItemType.BtosParent OrElse otype = CartItemType.BtosPart Then
                delivery_plant = "USH1"
            End If
        End If

        'If String.Equals(HttpContext.Current.Session("org_id"), "TW01") Then
        '    Dim sql As String = String.Format("select top 1 DELIVERYPLANT from SAP_PRODUCT_ORG where ORG_ID='TW01' and PART_NO = '{0}'", part_no)
        '    Dim obj As Object = dbUtil.dbExecuteScalar("MY", sql)
        '    If obj IsNot Nothing Then
        '        delivery_plant = obj.ToString()
        '    End If
        'End If

        '' Ming add for Plant TWM6
        'If String.Equals(HttpContext.Current.Session("org_id"), "TW01") AndAlso _
        '    (String.Equals(part_no, "LCDP-TMA-BTO", StringComparison.OrdinalIgnoreCase) Or String.Equals(part_no, "LCDP-V15011-BTO", StringComparison.OrdinalIgnoreCase)) Then
        '    delivery_plant = "TWM6"
        'End If
        ' END
        Dim DTSAPPRODUCTABC As DataTable = myproductABC.GetDT(String.Format("part_no='{0}' and Plant='{1}'", part_no, delivery_plant), "")
        If DTSAPPRODUCTABC.Rows.Count > 0 Then
            classABC = DTSAPPRODUCTABC.Rows(0).Item("ABC_INDICATOR")
        End If
        If IsDate(ReqDate) AndAlso ReqDate <> #12:00:00 AM# Then
            req_date = MyCartOrderBizDAL.getCompNextWorkDate(ReqDate, ORG_ID, 0)
        End If
        If isSyncPrice = 1 And otype <> -1 Then
            Dim dtPriceRec As New DataTable
            SAPtools.getSAPPriceByTable(part_no, QTY, ORG_ID, COMPANY_ID, currency, dtPriceRec)
            If dtPriceRec.Rows.Count > 0 Then
                unitprice = FormatNumber(dtPriceRec.Rows(0).Item("Netwr"), 2).Replace(",", "")
                listprice = FormatNumber(dtPriceRec.Rows(0).Item("Kzwi1"), 2).Replace(",", "")
            End If
        End If
        If isSyncATP = 1 Then
            SAPtools.getInventoryAndATPTable(part_no, delivery_plant, QTY, due_date, inventory, New DataTable, req_date, satisfyFlag, canbeConfirmed)

        End If
        Dim CM As New CustMaterialDataContext

        Dim DTCUSTMATERIAL As Cust_MaterialMapping = CM.Cust_MaterialMappings.SingleOrDefault(Function(x As Cust_MaterialMapping) x.CustomerId = COMPANY_ID AndAlso x.MaterialNo = part_no)
        If Not IsNothing(DTCUSTMATERIAL) Then
            custMaterial = DTCUSTMATERIAL.CustMaterialNo
        End If

        If ORG_ID.StartsWith("EU") And otype <> -1 Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.EU)
            'If currency <> "EUR" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("EUR", currency).ToString, Decimal), 2)
            'End If
        End If
        If ORG_ID.ToUpper.Equals("JP01") OrElse AuthUtil.IsJPAonlineSales(HttpContext.Current.Session("user_id")) Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.JP)
            'If itp = 0 Then
            '    Glob.ShowInfo("ITP can not be zero for Item '" & part_no & "'")
            '    Return 0
            'End If
            'If currency <> "JPY" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("JPY", currency).ToString, Decimal), 2)
            'End If
        End If
        If ORG_ID.StartsWith("CN") Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.CN)
        End If
        If AuthUtil.IsUSAonlineSales(HttpContext.Current.Session("user_id")) Then
            Dim ws As New SAPDAL.SAPDAL
            Dim gpPrice As Decimal = ws.getPriceByProdLine(part_no, ws.getProdPricingGrp(part_no))
            If gpPrice <> 0 AndAlso gpPrice > unitprice Then
                unitprice = gpPrice
            End If
        End If
        Dim _retBool As Boolean = MyCartX.DeleteCartItem(cart_id, line_no)
        If _retBool Then
            Dim _cartItem As New CartItem
            With _cartItem
                .Cart_Id = cart_id
                .Line_No = line_no
                .Part_No = part_no
                .Description = description
                .Qty = QTY
                .oUnit_Price = unitprice
                .List_Price = listprice
                .Unit_Price = unitprice
                .Itp = itp
                .Delivery_Plant = delivery_plant
                .Category = category
                .class = classABC
                .rohs = ROHS
                .Ew_Flag = EW_FLAG
                .req_date = req_date
                .due_date = due_date
                .SatisfyFlag = satisfyFlag
                .CanbeConfirmed = canbeConfirmed
                .CustMaterial = custMaterial
                .inventory = inventory
                .otype = otype
                .Model_No = Model_NO
                .higherLevel = higherLevel
            End With
            MyCartX.InsertCartItem(_cartItem)
            If _cartItem.Ew_Flag > 0 AndAlso isautoaddEX AndAlso _cartItem.otype <> CartItemType.BtosPart Then
                MyCartX.addExtendedWarranty(_cartItem)
            End If
            If Parent_item_selected = True Then
                Dim _CartBtosByManual As New Cart_BtosPart_Manual
                With _CartBtosByManual
                    .Cart_Id = cart_id
                    .Part_No = part_no
                    .Description = description
                    .OrgID = HttpContext.Current.Session("org_id")
                    .COMPANY_ID = HttpContext.Current.Session("company_id")
                    .Created_Date = DateTime.Now.ToString
                    .Created_By = HttpContext.Current.Session("User_id")
                End With
                MyCartBtosManual.InsertCartBtosManual(_CartBtosByManual)
            End If
            'Ming 20151027 change EW price when adding new parts for Btos
            If _cartItem.Ew_Flag > 0 AndAlso _cartItem.otype = CartItemType.BtosPart Then
                ' Dim addEWPrice As Decimal = _cartItem.EWpartnoX.EW_Rate * _cartItem.Unit_Price
                Dim items As List(Of CartItem) = MyCartX.GetCartList(cart_id).Where(Function(p) p.higherLevel = _cartItem.higherLevel).ToList()
                Dim EWitem As CartItem = Nothing
                For Each i As CartItem In items
                    If i.IsEWpartnoX Then
                        EWitem = i : Exit For
                    End If
                Next
                If EWitem IsNot Nothing Then
                    Dim BtosParent As CartItem = MyCartX.GetCartItem(_cartItem.Cart_Id, EWitem.higherLevel)
                    If BtosParent IsNot Nothing Then
                        EWitem.Unit_Price = BtosParent.ChildExtendedWarrantyPriceX
                        EWitem.List_Price = EWitem.Unit_Price
                        MyUtil.Current.MyAContext.SubmitChanges()
                    End If

                End If
            End If
        End If
        'mycart.Add_WithDelete_V2(cart_id, line_no, part_no, description, QTY, listprice, unitprice, itp, delivery_plant, category, classABC, ROHS, EW_FLAG, req_date, due_date, satisfyFlag, canbeConfirmed, custMaterial, inventory, otype, Model_NO, "", unitprice, higherLevel)
        Return line_no
    End Function
    Public Shared Function IsSpecialADAM(ByVal PartNO As String) As Boolean
        Return False
        If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso _
            HttpContext.Current.Session("org_id").ToString().Equals("EU10", StringComparison.OrdinalIgnoreCase) Then Return False
        Dim ADAMList As String() = New String() {"ADAM-40", "ADAM-41", "ADAM-60", "ADAM-61", "PCI-17", "PCL-7", "PCL-81"}
        For Each PN As String In ADAMList
            If PartNO.ToString.Trim.ToUpper.StartsWith(PN) Then
                Return True
            End If
        Next
        Return False
    End Function

    'Shared Function getCompNextWorkDate(ByVal reqDate As String, ByVal org As String, Optional ByVal days As Integer = 0) As String
    '    reqDate = CDate(reqDate).ToString("yyyy-MM-dd")
    '    Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
    '    ws.Timeout = -1
    '    Dim C As String = OrderUtilities.getCalendarbyOrg(Left(org, 2))

    '    ws.Get_Next_WorkingDate_ByCode(reqDate, days, C)
    '    ws.Dispose()
    '    Return CDate(reqDate).ToString("yyyy/MM/dd")
    'End Function
    Shared Function getCompNextWorkDate(ByVal reqDate As DateTime, ByVal org As String, Optional ByVal days As Integer = 0) As String
        reqDate = CDate(reqDate) '.ToString("yyyy-MM-dd")
        'Dim LandStr As String = OrderUtilities.getCalendarbyOrg(Left(org, 2))
        Dim LandStr As String = SAPDAL.SAPDAL.GetCalendarIDbyOrg(Left(org, 2))
        SAPDAL.SAPDAL.Get_Next_WorkingDate_ByCode(reqDate, days, LandStr)
        Return CDate(reqDate).ToString("yyyy/MM/dd")
    End Function
    Shared Function getCompNextWorkDateV2(ByVal reqDate As DateTime, ByVal org As String, Optional ByVal days As Integer = 0) As DateTime
        'reqDate = CDate(reqDate).ToString("yyyy-MM-dd")
        'Dim LandStr As String = OrderUtilities.getCalendarbyOrg(Left(org, 2))
        Dim LandStr As String = SAPDAL.SAPDAL.GetCalendarIDbyOrg(Left(org, 2))
        SAPDAL.SAPDAL.Get_Next_WorkingDate_ByCode(reqDate, days, LandStr)
        'Return CDate(reqDate).ToString("yyyy/MM/dd")
        ''Ming 20140402 TW時不再檢查shipping calendar
        If Not String.Equals(Left(org, 2), "TW") Then
            Dim sql As New StringBuilder
            sql.AppendLine(" select rtrim(SOAB1)+rtrim(SOBI1)+rtrim(SOAB2)+rtrim(SOBI2)  as Sunday, ")
            sql.AppendLine(" rtrim(MOAB1)+rtrim(MOBI1)+rtrim(MOAB2)+rtrim(MOBI2)  as Monday, ")
            sql.AppendLine(" rtrim(DIAB1)+rtrim(DIBI1)+rtrim(DIAB2)+rtrim(DIBI2)  as Tuesday, ")
            sql.AppendLine(" rtrim(MIAB1)+rtrim(MIBI1)+rtrim(MIAB2)+rtrim(MIBI2)  as Wednesday, ")
            sql.AppendLine(" rtrim(DOAB1)+rtrim(DOBI1)+rtrim(DOAB2)+rtrim(DOBI2)  as Thursday, ")
            sql.AppendLine(" rtrim(FRAB1)+rtrim(FRBI1)+rtrim(FRAB2)+rtrim(FRBI2)  as Friday, ")
            sql.AppendLine(" rtrim(SAAB1)+rtrim(SABI1)+rtrim(SAAB2)+rtrim(SABI2)  as Saturday ")
            sql.AppendLine(" from SAP_COMPANY_CALENDAR ")
            sql.AppendLine(String.Format(" where KUNNR='{0}'", HttpContext.Current.Session("company_id")))
            Dim Dt_sap_company_calendar As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString)
            ' If DateDiff(DateInterval.Day, reqDate, Now) = 0 Then reqDate = DateAdd(DateInterval.Day, 1, Now)
            ' Dim NextWeeklyShipDate As DateTime = reqDate
            If Dt_sap_company_calendar.Rows.Count > 0 Then
                Dim intOnOffWeekDays() As Integer = {0, 0, 0, 0, 0, 0, 0}, blHasValue As Boolean = False
                For i As Integer = 0 To 6
                    If Not Dt_sap_company_calendar.Rows(0).Item(i).ToString().Equals("000000000000000000000000") Then
                        intOnOffWeekDays(i) = 1 : blHasValue = True
                    End If
                Next
                If blHasValue = False Then
                    'Return False
                Else
                    'Dim intPlusDays As Integer = 0
                    Dim retbool As Boolean = True
                    While retbool ' intPlusDays < 7
                        'Dim tmpDate As Date = DateAdd(DateInterval.Day, intPlusDays, reqDate)
                        If intOnOffWeekDays(DatePart(DateInterval.Weekday, reqDate) - 1) = 1 Then
                            'NextWeeklyShipDate = tmpDate
                            retbool = False
                            'Return True
                        Else
                            SAPDAL.SAPDAL.Get_Next_WorkingDate_ByCode(reqDate, 1, LandStr)
                        End If
                        '  intPlusDays += 1
                    End While
                    'Return False
                End If
            End If
        End If
        Return reqDate
        ''''''''''''
    End Function


    Shared Function getBTOParentDueDate(ByVal reqDate As String) As String
        Dim curr_ReqDate As DateTime = CDate(reqDate) '.ToString("yyyy-MM-dd")
        'Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
        'ws.Timeout = -1
        Dim org_id As String = String.Empty
        If HttpContext.Current.Session("org_id") IsNot Nothing Then
            org_id = HttpContext.Current.Session("org_id").ToString.Trim.ToUpper
        End If
        'Dim C As String = OrderUtilities.getCalendarbyOrg(Left(org_id, 2))
        Dim C As String = SAPDAL.SAPDAL.GetCalendarIDbyOrg(Left(org_id, 2))
        SAPDAL.SAPDAL.Get_Next_WorkingDate_ByCode(curr_ReqDate, Glob.getBTOWorkingDate(), C)
        curr_ReqDate = getCompNextWorkDateV2(curr_ReqDate, org_id)
        'ws.Dispose()
        Return CDate(curr_ReqDate).ToString("yyyy/MM/dd")
    End Function
    'Shared Function getBTOChildDueDate(ByVal reqDate As String, ByVal org As String) As String
    '    reqDate = CDate(reqDate).ToString("yyyy-MM-dd")
    '    Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
    '    ws.Timeout = -1
    '    'Dim C As String = "NL"
    '    'If org = "US01" Then
    '    '    C = "US"
    '    'End If
    '    Dim C As String = OrderUtilities.getCalendarbyOrg(Left(org, 2))
    '    ws.Get_Next_WorkingDate_ByCode(reqDate, "-" & Glob.getBTOWorkingDate(), C)
    '    ws.Dispose()
    '    'If org = "US01" Then
    '    '    If CDate(reqDate) <= Now Then
    '    '        reqDate = Now.Date.ToShortDateString()
    '    '    End If
    '    'End If
    '    Return CDate(reqDate).ToString("yyyy/MM/dd")
    'End Function

    Shared Function getBTOChildDueDate(ByVal reqDate As String, ByVal org As String) As String
        reqDate = CDate(reqDate).ToString("yyyy-MM-dd")
        'Dim C As String = OrderUtilities.getCalendarbyOrg(Left(org, 2))
        Dim C As String = SAPDAL.SAPDAL.GetCalendarIDbyOrg(Left(org, 2))
        SAPDAL.SAPDAL.Get_Next_WorkingDate_ByCode(reqDate, "-" & Glob.getBTOWorkingDate(), C)
        Return CDate(reqDate).ToString("yyyy/MM/dd")
    End Function


    '20120503 TC: If company id has weekly ship date setup in SAP, then get nearest ship week date - used in OrderInfo.aspx
    Public Shared Function GetNextWeeklyShippingDate(ByVal reqDate As Date, ByRef NextWeeklyShipDate As Date) As Boolean
        '[ Ming 20131209 TW01跳過shipping calendar檢查
        If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso HttpContext.Current.Session("org_id").ToString.StartsWith("TW", StringComparison.OrdinalIgnoreCase) Then
            Return True
        End If
        '] end
        Dim LocalTime As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
        If DateDiff(DateInterval.Day, reqDate, LocalTime) = 0 Then reqDate = DateAdd(DateInterval.Day, 1, LocalTime)
        NextWeeklyShipDate = reqDate
        Dim sql As New StringBuilder
        sql.AppendLine(" select rtrim(SOAB1)+rtrim(SOBI1)+rtrim(SOAB2)+rtrim(SOBI2)  as Sunday, ")
        sql.AppendLine(" rtrim(MOAB1)+rtrim(MOBI1)+rtrim(MOAB2)+rtrim(MOBI2)  as Monday, ")
        sql.AppendLine(" rtrim(DIAB1)+rtrim(DIBI1)+rtrim(DIAB2)+rtrim(DIBI2)  as Tuesday, ")
        sql.AppendLine(" rtrim(MIAB1)+rtrim(MIBI1)+rtrim(MIAB2)+rtrim(MIBI2)  as Wednesday, ")
        sql.AppendLine(" rtrim(DOAB1)+rtrim(DOBI1)+rtrim(DOAB2)+rtrim(DOBI2)  as Thursday, ")
        sql.AppendLine(" rtrim(FRAB1)+rtrim(FRBI1)+rtrim(FRAB2)+rtrim(FRBI2)  as Friday, ")
        sql.AppendLine(" rtrim(SAAB1)+rtrim(SABI1)+rtrim(SAAB2)+rtrim(SABI2)  as Saturday ")
        sql.AppendLine(" from SAP_COMPANY_CALENDAR ")
        sql.AppendLine(String.Format(" where KUNNR='{0}'", HttpContext.Current.Session("company_id")))
        Dim Dt_sap_company_calendar As DataTable = dbUtil.dbGetDataTable("MY", sql.ToString)
        If Dt_sap_company_calendar.Rows.Count > 0 Then
            Dim intOnOffWeekDays() As Integer = {0, 0, 0, 0, 0, 0, 0}, blHasValue As Boolean = False
            For i As Integer = 0 To 6
                If Not Dt_sap_company_calendar.Rows(0).Item(i).ToString().Equals("000000000000000000000000") Then
                    intOnOffWeekDays(i) = 1 : blHasValue = True
                End If
            Next
            If blHasValue = False Then
                Return False
            Else
                Dim intPlusDays As Integer = 0
                While intPlusDays < 7
                    Dim tmpDate As Date = DateAdd(DateInterval.Day, intPlusDays, reqDate)
                    If intOnOffWeekDays(DatePart(DateInterval.Weekday, tmpDate) - 1) = 1 Then
                        NextWeeklyShipDate = tmpDate
                        Return True
                    End If
                    intPlusDays += 1
                End While
                Return False
            End If
        Else
            Return False
        End If
    End Function

    Public Shared Function isODMCart(ByVal CartID As String) As Boolean
        Dim mycart As New CartList("b2b", "CART_DETAIL_V2")
        Dim DTCart As New DataTable
        If mycart.IsExists(String.Format("cart_id='{1}' and otype=-1 and part_no='{0}'", "ODM-CPCI1109-BTO", CartID)) = 1 And HttpContext.Current.Session("company_id") = "UZISCHE01" Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function isODMCartV2(ByVal CartID As String) As Boolean
        Dim mycart As New CartList("b2b", "CART_DETAIL_V2")
        Dim DTCart As New DataTable
        If mycart.IsExists(String.Format("cart_id='{1}' and otype=-1 and part_no='{0}'", "ODM-CPCI1109-BTO", CartID)) = 1 And HttpContext.Current.Session("company_id") = "UZISCHE01" Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function isODMOrder(ByVal Order_No As String) As Boolean
        Dim myOrderMaster As New order_Master("B2B", "Order_Master")
        Dim myOrderDetail As New order_Detail("B2B", "Order_Detail")
        'Dim dtMaster As New DataTable
        'dtMaster = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_No), "")
        'Dim dtDetail As New DataTable
        'dtDetail = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_No")
        'Nada 20131125 see regardless btos or component as ODM and assign TWM3 as delivery plant
        'If myOrderMaster.IsExists(String.Format("Order_ID='{0}' and soldto_id='{1}'", Order_No, "UZISCHE01")) = 1 And _
        '    myOrderDetail.IsExists(String.Format("Order_ID='{0}' and ORDER_LINE_TYPE=-1 and part_no='{1}'", Order_No, "ODM-CPCI1109-BTO")) Then
        If myOrderMaster.IsExists(String.Format("Order_ID='{0}' and soldto_id='{1}'", Order_No, "UZISCHE01")) = 1 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function GetBTOSOrderNotifyList(ByVal SAPOrg As String) As ArrayList

        Dim arr As New ArrayList

        Select Case Left(UCase(SAPOrg), 2)
            Case "EU"


                If AuthUtil.IsADloG Then
                    arr.Add("order@advantech-dlog.com")
                Else
                    arr.Add("tam.tran@advantech.eu") ': arr.Add("jos.vanberlo@advantech.nl") : arr.Add("Erika.Molnarova@advantech.nl")
                    arr.Add("e-btos@advantech.eu") ': arr.Add("Michael.Zoon@advantech.eu") : arr.Add("AESC.SCM@advantech.eu") : arr.Add("erik.smulders@advantech.nl")

                End If

            Case "SG", "MY"
                arr.Add("asg.op@advantech.com")
            Case "US"
                'Frank 2012/07/02:If AOnline sales place the CTOS order, then just cc to Mark
                'Ming 20140530 UZISCHE01是特殊大客戶, Javian不希望除了他跟Adam.Powell以外的人可以看到訂單及價格
                If Not String.Equals(HttpContext.Current.Session("company_id"), "UZISCHE01") Then
                    If MailUtil.IsInRole("Aonline.USA") Then
                        arr.Add("Mark.Yang@advantech.com")
                    ElseIf MailUtil.IsInRole("SALES.IAG.USA") Then
                        'Frank 2012/07/02:If ANA iA KA CP sales place the CTOS order, then just cc to Shufen.Chen

                    Else
                        arr.Add("Mark.Yang@advantech.com")
                    End If
                End If
            Case "CN"

            Case Else
                'arr.Add("ebusiness.aeu@advantech.eu")
                arr.Add("brian.tsai@advantech.com.tw")
        End Select
        Return arr
    End Function

    Public Shared Function GetBTOSSheetNotifyList(ByVal SAPOrg As String) As ArrayList

        Dim arr As New ArrayList

        Select Case Left(UCase(SAPOrg), 2)
            Case "EU"
                arr.Add("tam.tran@advantech.eu") : arr.Add("e-btos.AESC@advantech-nl.nl")
            Case "SG", "MY"
                arr.Add("asg.op@advantech.com")
            Case "US"
                'Frank 2012/07/02:If AOnline sales place the CTOS order, then just cc to Marks
                If MailUtil.IsInRole("Aonline.USA") Then
                    arr.Add("Mark.Yang@advantech.com")
                Else
                    arr.Add("Mark.Yang@advantech.com") : arr.Add("Dale.Chiang@advantech.com")
                End If
            Case Else
                arr.Add("ebusiness.aeu@advantech.eu") : arr.Add("brian.tsai@advantech.com.tw")
        End Select
        Return arr
    End Function

    Public Shared Function GetFailedOrderNotifyList(ByVal CompanyId As String, ByVal Org As String, Optional ByVal IsComponentOrder As Boolean = True) As ArrayList
        Dim arr As New ArrayList
        Select Case Left(UCase(Org), 2)
            Case "EU"
                arr.Add("AESC.SCM@advantech.com") ': arr.Add("Jos.vanBerlo@advantech.nl")
                arr.Add("order.AEU@advantech.com")
            Case "SG", "MY"
                If CompanyId.Equals("AMLA004", StringComparison.OrdinalIgnoreCase) Then
                    arr.Add("CL.Ong@ Advantech.com") : arr.Add("SH.Tan@ Advantech.com") : arr.Add("Candy.Tong@ Advantech.com")
                Else
                    arr.Add("asg.op@advantech.com")
                End If
            Case "US"
                arr.Add("Jay.Lee@advantech.com") : arr.Add("Mike.Liu@advantech.com")
            Case "JP"
                arr.Add("Yc.Liu@advantech.com")
            Case "CN"
                arr.Add("jingjing.jiang@advantech.com.cn")
            Case Else
                arr.Add("ebusiness.aeu@advantech.eu")
        End Select
        Return arr
    End Function

    Public Shared Function isTW01BTOSInvalidParts(ByVal _PartNo As String, ByVal _Plant As String) As Boolean

        If HttpContext.Current.Session("org_id").ToString.Equals("TW01") Then
            If Not (HttpContext.Current.Session("company_id").ToString().Equals("ADVAJP", StringComparison.OrdinalIgnoreCase) _
                    OrElse HttpContext.Current.Session("company_id").ToString().Equals("ADVAMY", StringComparison.OrdinalIgnoreCase) _
                    OrElse HttpContext.Current.Session("company_id").ToString().Equals("ADVASG", StringComparison.OrdinalIgnoreCase)) Then
                If MyCartX.IsHaveBtos(HttpContext.Current.Session("Cart_id")) Then
                    Dim ABC_Indicator As String = Advantech.Myadvantech.Business.PartBusinessLogic.GetABCIndicator(_PartNo, _Plant)
                    If Not (ABC_Indicator.Equals("A") OrElse ABC_Indicator.Equals("B") OrElse ABC_Indicator.Equals("C+")) Then
                        Return True
                    End If
                End If
            End If
        End If

        Return False
    End Function

End Class


'Public Class PartNoQtyReqDate
'    Public Property PartNo As String : Public Property Qty As Integer : Public Property RequiredDate As Date
'End Class

'Public Class PRMRepOrderReturnMessage
'    Public Property RequestRowId As String : Public Property ErrorMessage As String : Public Property IsSuccessful As Boolean
'End Class

'Public Class PRMReqOrderDetail
'    Public Property ContactId As String : Public Property ContactEmail As String : Public Property ProductRecords As New List(Of PartNoQtyReqDate)
'End Class