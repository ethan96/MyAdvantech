Imports Microsoft.VisualBasic

Public Class CartList : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    'Protected Overloads Function Add(ByVal cart_id As String, _
    '                                    ByVal line_no As Integer, _
    '                                    ByVal part_no As String, _
    '                                    ByVal description As String, _
    '                                    ByVal qty As Integer, _
    '                                    ByVal list_price As Decimal, _
    '                                    ByVal unit_price As Decimal, _
    '                                    ByVal itp As Decimal, _
    '                                    ByVal delivery_plant As String, _
    '                                    ByVal category As String, _
    '                                    ByVal classABC As String, _
    '                                    ByVal rohs As Integer, _
    '                                    ByVal ew_flag As Integer, _
    '                                    ByVal req_date As Date, _
    '                                    ByVal due_date As Date, _
    '                                    ByVal satisfyFlag As Integer, _
    '                                    ByVal canbeConfirmed As Integer, _
    '                                    ByVal custMaterial As String, _
    '                                    ByVal inventory As Int32, _
    '                                    ByVal otype As Integer, _
    '                                    ByVal Model_no As String, _
    '                                    ByVal QUOTE_ID As String, _
    '                                    ByVal oUnit_Price As Decimal) As Integer
    '    Dim str As String = String.Format("insert into {0} (cart_id,line_no,part_no,description,qty,list_price,unit_price,itp,delivery_plant,category,class,rohs,ew_flag," & _
    '                                      "req_date,due_date,satisfyflag,canbeconfirmed,custmaterial,inventory,otype,model_no,quote_id,ounit_price) values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}','{22}','{23}')", _
    '                                      Me.tb, _
    '                                      cart_id, _
    '                                      line_no, _
    '                                      part_no, _
    '                                      description, _
    '                                      qty, _
    '                                      list_price, _
    '                                      unit_price, _
    '                                      itp, _
    '                                      delivery_plant, _
    '                                      category, _
    '                                      classABC, _
    '                                      rohs, _
    '                                      ew_flag, _
    '                                      req_date, _
    '                                      due_date, _
    '                                      satisfyFlag, _
    '                                      canbeConfirmed, _
    '                                      custMaterial, _
    '                                      inventory, _
    '                                      otype, _
    '                                      Model_no, _
    '                                      QUOTE_ID, _
    '                                      oUnit_Price)
    '    dbUtil.dbExecuteNoQuery(Me.conn, str)
    '    Return 1
    'End Function


    Protected Overloads Function Add_WithDelete(ByVal cart_id As String, _
                                    ByVal line_no As Integer, _
                                    ByVal part_no As String, _
                                    ByVal description As String, _
                                    ByVal qty As Integer, _
                                    ByVal list_price As Decimal, _
                                    ByVal unit_price As Decimal, _
                                    ByVal itp As Decimal, _
                                    ByVal delivery_plant As String, _
                                    ByVal category As String, _
                                    ByVal classABC As String, _
                                    ByVal rohs As Integer, _
                                    ByVal ew_flag As Integer, _
                                    ByVal req_date As Date, _
                                    ByVal due_date As Date, _
                                    ByVal satisfyFlag As Integer, _
                                    ByVal canbeConfirmed As Integer, _
                                    ByVal custMaterial As String, _
                                    ByVal inventory As Int32, _
                                    ByVal otype As Integer, _
                                    ByVal Model_no As String, _
                                    ByVal QUOTE_ID As String, _
                                    ByVal oUnit_Price As Decimal) As Integer

        Dim deletestr As String = String.Format("delete from {0} where cart_id='{1}' and line_no='{2}'", Me.tb, cart_id, line_no)

        Dim insertstr As String = String.Format("insert into {0} (cart_id,line_no,part_no,description,qty,list_price,unit_price,itp,delivery_plant,category,class,rohs,ew_flag," & _
                                          "req_date,due_date,satisfyflag,canbeconfirmed,custmaterial,inventory,otype,model_no,quote_id,ounit_price) values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}','{22}','{23}')", _
                                          Me.tb, _
                                          cart_id, _
                                          line_no, _
                                          part_no, _
                                          description, _
                                          qty, _
                                          list_price, _
                                          unit_price, _
                                          itp, _
                                          delivery_plant, _
                                          category, _
                                          classABC, _
                                          rohs, _
                                          ew_flag, _
                                          req_date, _
                                          due_date, _
                                          satisfyFlag, _
                                          canbeConfirmed, _
                                          custMaterial, _
                                          inventory, _
                                          otype, _
                                          Model_no, _
                                          QUOTE_ID, _
                                          oUnit_Price)
        dbUtil.dbExecuteNoQuery(Me.conn, deletestr & ";" & insertstr)
        Return 1
    End Function
    Protected Overloads Function Add_WithDelete_V2(ByVal cart_id As String, _
                                    ByVal line_no As Integer, _
                                    ByVal part_no As String, _
                                    ByVal description As String, _
                                    ByVal qty As Integer, _
                                    ByVal list_price As Decimal, _
                                    ByVal unit_price As Decimal, _
                                    ByVal itp As Decimal, _
                                    ByVal delivery_plant As String, _
                                    ByVal category As String, _
                                    ByVal classABC As String, _
                                    ByVal rohs As Integer, _
                                    ByVal ew_flag As Integer, _
                                    ByVal req_date As Date, _
                                    ByVal due_date As Date, _
                                    ByVal satisfyFlag As Integer, _
                                    ByVal canbeConfirmed As Integer, _
                                    ByVal custMaterial As String, _
                                    ByVal inventory As Int32, _
                                    ByVal otype As Integer, _
                                    ByVal Model_no As String, _
                                    ByVal QUOTE_ID As String, _
                                    ByVal oUnit_Price As Decimal, ByVal higherLevel As Integer) As Integer

        Dim deletestr As String = String.Format("delete from {0} where cart_id='{1}' and line_no='{2}'", Me.tb, cart_id, line_no)

        Dim insertstr As String = String.Format("insert into {0} (cart_id,line_no,part_no,description,qty,list_price,unit_price,itp,delivery_plant,category,class,rohs,ew_flag," & _
                                          "req_date,due_date,satisfyflag,canbeconfirmed,custmaterial,inventory,otype,model_no,quote_id,ounit_price,higherLevel) values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}','{22}','{23}',{24})", _
                                          Me.tb, _
                                          cart_id, _
                                          line_no, _
                                          part_no, _
                                          description, _
                                          qty, _
                                          list_price, _
                                          unit_price, _
                                          itp, _
                                          delivery_plant, _
                                          category, _
                                          classABC, _
                                          rohs, _
                                          ew_flag, _
                                          req_date, _
                                          due_date, _
                                          satisfyFlag, _
                                          canbeConfirmed, _
                                          custMaterial, _
                                          inventory, _
                                          otype, _
                                          Model_no, _
                                          QUOTE_ID, _
                                          oUnit_Price, higherLevel)
        dbUtil.dbExecuteNoQuery(Me.conn, deletestr & ";" & insertstr)
        Return 1
    End Function
    Public Function CopyCart(ByVal OrgCart_id As String, ByVal NewCart_id As String) As Integer
        Dim mycart As New CartList("b2b", "cart_detail")
        mycart.Delete(String.Format("cart_id='{0}'", NewCart_id))
        Dim dth As DataTable = mycart.GetDT(String.Format("cart_id='{0}'", OrgCart_id), "line_no")
        If dth.Rows.Count > 0 Then
            For Each r As DataRow In dth.Rows
                r.Item("cart_id") = NewCart_id
            Next
            Dim bk As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings(mycart.conn).ConnectionString)
            bk.DestinationTableName = mycart.tb
            bk.WriteToServer(dth)
        End If
        Return 1
    End Function
    Public Function CheckCartGPByCartId(ByVal cartid As String) As Boolean
        Dim mycart As New CartList("b2b", "cart_detail")
        Dim ws As New quote.quoteExit
        Dim struct_GP_Detail As New List(Of quote.struct_GP_Detail)
        Dim dt As DataTable = mycart.GetDT(String.Format("Cart_id='{0}'", cartid), "line_no")
        If mycart.IsExists(String.Format("cart_Id='{0}' and unit_price<ounit_price", cartid)) = 1 Then
            For Each x As DataRow In dt.Rows
                Dim struct_GP_Detail_Line As New quote.struct_GP_Detail
                struct_GP_Detail_Line.lineNo = x.Item("line_no")
                struct_GP_Detail_Line.PartNo = x.Item("part_no")
                struct_GP_Detail_Line.Price = x.Item("unit_price")
                struct_GP_Detail_Line.QTY = x.Item("qty")
                struct_GP_Detail_Line.Itp = x.Item("itp")
                struct_GP_Detail.Add(struct_GP_Detail_Line)
            Next

            ws.Timeout = -1
            Dim level As Integer = ws.getLevel("", HttpContext.Current.Session("company_id"), struct_GP_Detail.ToArray())
            If level > 0 Then
                Return True
            End If
        End If
        Return False
    End Function
   
    Public Function ADD2CART(ByVal cart_id As String, ByVal part_no As String, ByVal QTY As Integer, ByVal EW_FLAG As Integer _
                             , ByVal itemType As Integer, ByVal category As String, ByVal isSyncPrice As Integer _
                             , ByVal isSyncATP As Integer, Optional ByVal ReqDate As DateTime = #12:00:00 AM# _
                             , Optional ByVal description As String = "", Optional ByVal delivery_plant As String = "") As Integer
        If part_no.StartsWith(MyExtension.BuildIn, StringComparison.OrdinalIgnoreCase) Then Return 1
        If part_no.EndsWith("BTO") And itemType <> -1 Then
            Glob.ShowInfo("BTO Item cannot be added as component.")
            Return 0
        End If

        Dim mycart As New CartList("b2b", "cart_detail"), myproduct As New SAPProduct("b2b", "SAP_PRODUCT")
        Dim myproductABC As New SAPProduct("b2b", "SAP_PRODUCT_ABC"), myCustMaterial As New Cust_Material("b2b", "Cust_MaterialMapping")
        Dim ORG_ID As String = HttpContext.Current.Session("org_id"), COMPANY_ID As String = HttpContext.Current.Session("COMPANY_ID")
        Dim currency As String = HttpContext.Current.Session("COMPANY_Currency"), line_no As Integer = 0
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
            If (part_no.ToUpper.StartsWith("96MD") Or part_no.ToUpper.StartsWith("96HD")) And otype = 0 Then
                Glob.ShowInfo("Hard drive cannot be placed as component order")
                Return 0
            End If
        End If
    
        Dim strStatusCode As String = "", strStatusDesc As String = ""
        If (itemType = 0) And (Not OrderUtilities.Add2CartCheck(part_no, "", strStatusCode, strStatusDesc, otype)) Then
            Dim ExtensionDesc As String = String.Empty
            If Util.IsInternalUser2() Then ExtensionDesc = "  Status [ " + strStatusCode + " ], " + strStatusDesc
            Glob.ShowInfo("Invalid PN  : " & part_no + ExtensionDesc)
            Return 0
        End If
        If otype = -1 Then
            line_no = 100
        Else
            line_no = mycart.getMaxLineNo(cart_id) + 1
        End If
        QTY = CInt(QTY)
        Dim DTSAPPRODUCT As DataTable = myproduct.GetDT(String.Format("part_no='{0}'", part_no), "")
        If DTSAPPRODUCT.Rows.Count > 0 Then

            'Frank 2012/01/10
            'Product of product line DLGR can not be added to cart if current user is external user.
            If Util.IsInternalUser2() = False Then
                If DTSAPPRODUCT.Rows(0).Item("Product_line").ToString.Equals("DLGR", StringComparison.InvariantCultureIgnoreCase) Then
                    'Glob.ShowInfo("You have no permission to  place this product as order")
                    Return 0
                End If
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
        ' Ming add for Plant TWM6
        If String.Equals(HttpContext.Current.Session("org_id"), "TW01") AndAlso _
            (String.Equals(part_no, "LCDP-TMA-BTO", StringComparison.OrdinalIgnoreCase) Or String.Equals(part_no, "LCDP-V15011-BTO", StringComparison.OrdinalIgnoreCase)) Then
            delivery_plant = "TWM6"
        End If
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
            SAPtools.getSAPPriceByTable(part_no, 1, ORG_ID, COMPANY_ID, "", dtPriceRec)
            If dtPriceRec.Rows.Count > 0 Then
                unitprice = FormatNumber(dtPriceRec.Rows(0).Item("Netwr"), 2).Replace(",", "")
                listprice = FormatNumber(dtPriceRec.Rows(0).Item("Kzwi1"), 2).Replace(",", "")
            End If
        End If
        If isSyncATP = 1 Then
            'Nada20131210 pass in product status for TW01
            Dim PNStatus As String = ""
            If ORG_ID = "TW01" Then
                Dim strPNStatus As String = String.Format("select PRODUCT_STATUS from SAP_PRODUCT_STATUS where PART_NO='{0}' and SALES_ORG ='{1}'", part_no, ORG_ID)
                Dim O As Object = dbUtil.dbExecuteScalar("MY", strPNStatus)
                If Not IsNothing(O) Then
                    PNStatus = O.ToString
                End If
            End If
            SAPtools.getInventoryAndATPTable(part_no, delivery_plant, QTY, due_date, inventory, New DataTable, req_date, satisfyFlag, canbeConfirmed, "", PNStatus)
            '/Nada20131210
        End If
        Dim DTCUSTMATERIAL As DataTable = myCustMaterial.GetDT(String.Format("CustomerId='{0}' and MaterialNo='{1}'", COMPANY_ID, part_no), "")
        If DTCUSTMATERIAL.Rows.Count > 0 Then
            custMaterial = DTCUSTMATERIAL.Rows(0).Item("CustMaterialNo")
        End If

        If ORG_ID.StartsWith("EU") And otype <> -1 Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.EU)
            'If currency <> "EUR" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("EUR", currency).ToString, Decimal), 2)
            'End If
        End If
        If AuthUtil.IsJPAonlineSales(HttpContext.Current.Session("user_id")) Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.JP)
            'If itp = 0 Then
            '    Glob.ShowInfo("ITP can not be zero for Item '" & part_no & "'")
            '    Return 0
            'End If
            'If currency <> "JPY" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("JPY", currency).ToString, Decimal), 2)
            'End If
        End If
        If AuthUtil.IsUSAonlineSales(HttpContext.Current.Session("user_id")) Then
            Dim ws As New SAPDAL.SAPDAL
            Dim gpPrice As Decimal = ws.getPriceByProdLine(part_no, ws.getProdPricingGrp(part_no))
            If gpPrice <> 0 AndAlso gpPrice > unitprice Then
                unitprice = gpPrice
            End If
        End If
        'mycart.Delete(String.Format("cart_id='{0}' and line_no='{1}'", cart_id, line_no))
        'mycart.Add(cart_id, line_no, part_no, description, QTY, listprice, unitprice, itp, delivery_plant, category, classABC, ROHS, EW_FLAG, req_date, due_date, satisfyFlag, canbeConfirmed, custMaterial, inventory, otype, Model_NO, "", unitprice)
        mycart.Add_WithDelete(cart_id, line_no, part_no, description, QTY, listprice, unitprice, itp, delivery_plant, category, classABC, ROHS, EW_FLAG, req_date, due_date, satisfyFlag, canbeConfirmed, custMaterial, inventory, otype, Model_NO, "", unitprice)
        Return line_no
    End Function
   
    <Obsolete()> _
    Public Function ADD2CART_V2(ByVal cart_id As String, ByVal part_no As String, ByVal QTY As Integer, ByVal EW_FLAG As Integer _
                         , ByVal itemType As Integer, ByVal category As String, ByVal isSyncPrice As Integer _
                         , ByVal isSyncATP As Integer, ByVal ReqDate As DateTime _
                         , ByVal description As String, ByVal delivery_plant As String, ByVal higherLevel As Integer, Optional ByVal isautoaddEX As Boolean = False) As Integer
        If part_no.StartsWith(MyExtension.BuildIn, StringComparison.OrdinalIgnoreCase) Then Return 1
        If part_no.EndsWith("BTO") And itemType <> -1 Then
            Glob.ShowInfo("BTO Item cannot be added as component.")
            Return 0
        End If


        Dim mycart As New CartList("b2b", "CART_DETAIL_V2"), myproduct As New SAPProduct("b2b", "SAP_PRODUCT")
        Dim myproductABC As New SAPProduct("b2b", "SAP_PRODUCT_ABC"), myCustMaterial As New Cust_Material("b2b", "Cust_MaterialMapping")
        Dim ORG_ID As String = HttpContext.Current.Session("org_id"), COMPANY_ID As String = HttpContext.Current.Session("COMPANY_ID")
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
            If (part_no.ToUpper.StartsWith("96MD") Or part_no.ToUpper.StartsWith("96HD")) And otype = 0 Then
                Glob.ShowInfo("Hard drive cannot be placed as component order")
                Return 0
            End If
        End If
        Dim strStatusCode As String = "", strStatusDesc As String = ""
        If (itemType = 0) AndAlso (Not OrderUtilities.Add2CartCheck(part_no, "", strStatusCode, strStatusDesc, otype)) Then
            Dim ExtensionDesc As String = String.Empty
            If Util.IsInternalUser2() Then ExtensionDesc = "  Status [ " + strStatusCode + " ], " + strStatusDesc
            Glob.ShowInfo("Invalid PN  : " & part_no + ExtensionDesc)
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

            'Frank 2012/01/10
            'Product of product line DLGR can not be added to cart if current user is external user.
            If Util.IsInternalUser2() = False Then
                If DTSAPPRODUCT.Rows(0).Item("Product_line").ToString.Equals("DLGR", StringComparison.InvariantCultureIgnoreCase) Then
                    'Glob.ShowInfo("You have no permission to  place this product as order")
                    Return 0
                End If
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
            SAPtools.getSAPPriceByTable(part_no, 1, ORG_ID, COMPANY_ID, currency, dtPriceRec)
            If dtPriceRec.Rows.Count > 0 Then
                unitprice = FormatNumber(dtPriceRec.Rows(0).Item("Netwr"), 2).Replace(",", "")
                listprice = FormatNumber(dtPriceRec.Rows(0).Item("Kzwi1"), 2).Replace(",", "")
            End If
        End If
        If isSyncATP = 1 Then
            SAPtools.getInventoryAndATPTable(part_no, delivery_plant, QTY, due_date, inventory, New DataTable, req_date, satisfyFlag, canbeConfirmed)

        End If
        Dim DTCUSTMATERIAL As DataTable = myCustMaterial.GetDT(String.Format("CustomerId='{0}' and MaterialNo='{1}'", COMPANY_ID, part_no), "")
        If DTCUSTMATERIAL.Rows.Count > 0 Then
            custMaterial = DTCUSTMATERIAL.Rows(0).Item("CustMaterialNo")
        End If

        If ORG_ID.StartsWith("EU") And otype <> -1 Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.EU)
            'If currency <> "EUR" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("EUR", currency).ToString, Decimal), 2)
            'End If
        End If
        If AuthUtil.IsJPAonlineSales(HttpContext.Current.Session("user_id")) OrElse String.Equals(HttpContext.Current.Session("org_id"), "JP01") Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.JP)
            'If itp = 0 Then
            '    Glob.ShowInfo("ITP can not be zero for Item '" & part_no & "'")
            '    Return 0
            'End If
            'If currency <> "JPY" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("JPY", currency).ToString, Decimal), 2)
            'End If
        End If
        If otype <> CartItemType.BtosParent AndAlso AuthUtil.IsUSAonlineSales(HttpContext.Current.Session("user_id")) Then
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
        End If
        'mycart.Add_WithDelete_V2(cart_id, line_no, part_no, description, QTY, listprice, unitprice, itp, delivery_plant, category, classABC, ROHS, EW_FLAG, req_date, due_date, satisfyFlag, canbeConfirmed, custMaterial, inventory, otype, Model_NO, "", unitprice, higherLevel)
        Return line_no
    End Function

    Public Function ADD2CART_V3(ByVal cart_id As String, ByVal part_no As String, ByVal QTY As Integer, ByVal EW_FLAG As Integer _
                         , ByVal itemType As Integer, ByVal category As String, ByVal isSyncPrice As Integer _
                         , ByVal isSyncATP As Integer, ByVal ReqDate As DateTime _
                         , ByVal description As String, ByVal delivery_plant As String, ByVal higherLevel As Integer, ByVal isautoaddEX As Boolean, ByVal quoteid As String, ByRef CartList As List(Of CartItem)) As Integer
        If part_no.StartsWith(MyExtension.BuildIn, StringComparison.OrdinalIgnoreCase) Then Return 1
        If part_no.EndsWith("BTO") And itemType <> -1 Then
            Glob.ShowInfo("BTO Item cannot be added as component.")
            Return 0
        End If
        Dim myproduct As New SAPProduct("b2b", "SAP_PRODUCT") 'mycart As New CartList("b2b", "CART_DETAIL_V2"),
        Dim myproductABC As New SAPProduct("b2b", "SAP_PRODUCT_ABC"), myCustMaterial As New Cust_Material("b2b", "Cust_MaterialMapping")
        Dim ORG_ID As String = HttpContext.Current.Session("org_id"), COMPANY_ID As String = HttpContext.Current.Session("COMPANY_ID")
        Dim currency As String = MyCartX.GetCurrency(cart_id), line_no As Integer = 0
        Dim listprice As Decimal = 0.0, unitprice As Decimal = 0.0, itp As Decimal = 0.0
        'Dim delivery_plant As String = "", classABC As String = "", ROHS As Integer = 0, req_date As Date = Now.Date
        Dim classABC As String = "", ROHS As Integer = 0, req_date As Date = Now.Date
        Dim due_date As Date = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2)).Date, inventory As Int32 = 0, satisfyFlag As Integer = 0, canbeConfirmed As Integer = 0
        Dim custMaterial As String = "", otype As Integer = 0, Model_NO As String = ""
        part_no = part_no.ToUpper() : otype = itemType
        If ORG_ID = "EU10" Then
            If (part_no.ToUpper.StartsWith("96MD") Or part_no.ToUpper.StartsWith("96HD")) And otype = 0 Then
                Glob.ShowInfo("Hard drive cannot be placed as component order")
                Return 0
            End If
        End If
        Dim strStatusCode As String = "", strStatusDesc As String = ""
        If (itemType = 0) AndAlso (Not OrderUtilities.Add2CartCheck(part_no, "", strStatusCode, strStatusDesc)) Then
            Dim ExtensionDesc As String = String.Empty
            If Util.IsInternalUser2() Then ExtensionDesc = "  Status [ " + strStatusCode + " ], " + strStatusDesc
            Glob.ShowInfo("Invalid PN  : " & part_no + ExtensionDesc)
            Return 0
        End If
        If otype = CartItemType.BtosParent Then
            'line_no = MyCartX.getBtosParentLineNo(cart_id)
            Dim ParentLineNo As Integer = 0
            Do While True
                ParentLineNo = ParentLineNo + 100
                If CartList.Where(Function(p) p.Line_No = ParentLineNo).Count = 0 Then
                    Exit Do
                End If
            Loop
            line_no = ParentLineNo
        ElseIf otype = CartItemType.BtosPart Then
            'line_no = MyCartX.getBtosMaxLineNo(cart_id, higherLevel) + 1
            Dim objlineno As Object = (From i In CartList
                                        Where (i.higherLevel = higherLevel OrElse i.Line_No = higherLevel) AndAlso i.Cart_Id = cart_id).Max(Function(x) x.Line_No)
            line_no = Integer.Parse(objlineno) + 1
        Else
            ' line_no = MyCartX.getMaxLineNoV2(cart_id) + 1
            Dim objlineno As Object = CartList.Where(Function(p) p.Cart_Id = cart_id AndAlso otype = CartItemType.Part).Max(Function(p) p.Line_No)
            If IsNumeric(objlineno) Then
                line_no = Integer.Parse(objlineno) + 1
            Else
                line_no = 1
            End If
        End If
        QTY = CInt(QTY)
        Dim DTSAPPRODUCT As DataTable = myproduct.GetDT(String.Format("part_no='{0}'", part_no), "")
        If DTSAPPRODUCT.Rows.Count > 0 Then
            'Frank 2012/01/10
            'Product of product line DLGR can not be added to cart if current user is external user.
            If Util.IsInternalUser2() = False Then
                If DTSAPPRODUCT.Rows(0).Item("Product_line").ToString.Equals("DLGR", StringComparison.InvariantCultureIgnoreCase) Then
                    'Glob.ShowInfo("You have no permission to  place this product as order")
                    Return 0
                End If
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
        ' JJ add for Plant TW01
        If String.Equals(HttpContext.Current.Session("org_id"), "TW01") Then
            Dim sql As String = String.Format("select top 1 DELIVERYPLANT from SAP_PRODUCT_ORG where ORG_ID='TW01' and PART_NO = '{0}'", part_no)
            Dim obj As Object = dbUtil.dbExecuteScalar("MY", sql)
            If obj IsNot Nothing Then
                delivery_plant = obj.ToString()
            End If
        End If
        ' Ming add for Plant TWM6
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
            SAPtools.getSAPPriceByTable(part_no, 1, ORG_ID, COMPANY_ID, currency, dtPriceRec)
            If dtPriceRec.Rows.Count > 0 Then
                unitprice = FormatNumber(dtPriceRec.Rows(0).Item("Netwr"), 2).Replace(",", "")
                listprice = FormatNumber(dtPriceRec.Rows(0).Item("Kzwi1"), 2).Replace(",", "")
            End If
        End If
        If isSyncATP = 1 Then
            SAPtools.getInventoryAndATPTable(part_no, delivery_plant, QTY, due_date, inventory, New DataTable, req_date, satisfyFlag, canbeConfirmed)

        End If
        Dim DTCUSTMATERIAL As DataTable = myCustMaterial.GetDT(String.Format("CustomerId='{0}' and MaterialNo='{1}'", COMPANY_ID, part_no), "")
        If DTCUSTMATERIAL.Rows.Count > 0 Then
            custMaterial = DTCUSTMATERIAL.Rows(0).Item("CustMaterialNo")
        End If

        If ORG_ID.StartsWith("EU") And otype <> CartItemType.BtosParent Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.EU)
            'If currency <> "EUR" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("EUR", currency).ToString, Decimal), 2)
            'End If
        End If
        If AuthUtil.IsJPAonlineSales(HttpContext.Current.Session("user_id")) Then
            itp = SAPDAL.SAPDAL.getItp(ORG_ID, part_no, currency, COMPANY_ID, SAPDAL.SAPDAL.itpType.JP)
            'If itp = 0 Then
            '    Glob.ShowInfo("ITP can not be zero for Item '" & part_no & "'")
            '    Return 0
            'End If
            'If currency <> "JPY" Then
            '    itp = FormatNumber(itp * CType(Glob.get_exchangerate("JPY", currency).ToString, Decimal), 2)
            'End If
        End If
        If AuthUtil.IsUSAonlineSales(HttpContext.Current.Session("user_id")) Then
            Dim ws As New SAPDAL.SAPDAL
            Dim gpPrice As Decimal = ws.getPriceByProdLine(part_no, ws.getProdPricingGrp(part_no))
            If gpPrice <> 0 AndAlso gpPrice > unitprice Then
                unitprice = gpPrice
            End If
        End If
        'Dim _retBool As Boolean = MyCartX.DeleteCartItem(cart_id, line_no)
        Dim _currlineno As CartItem = CartList.Where(Function(p) p.Line_No = line_no).FirstOrDefault()
        If _currlineno IsNot Nothing Then CartList.Remove(_currlineno)

        Dim _cartItem As New CartItem
        With _cartItem
            .Cart_Id = cart_id
            .Line_No = line_no
            .Part_No = part_no
            .Description = description
            .Qty = QTY
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
            .QUOTE_ID = quoteid
            .Model_No = Model_NO
            .higherLevel = higherLevel
        End With
        'MyCartX.InsertCartItem(_cartItem)
        CartList.Add(_cartItem)
        If _cartItem.Ew_Flag > 0 AndAlso isautoaddEX AndAlso _cartItem.otype <> CartItemType.BtosPart Then
            Dim _EWcartitem As New CartItem
            With _EWcartitem
                .Cart_Id = _cartItem.Cart_Id
                .Line_No = _cartItem.Line_No + 1
                .Part_No = _cartItem.EWpartnoX.EW_PartNO
                .Description = "Extended Warranty for " + _cartItem.EWpartnoX.EW_Month.ToString() + " Months"
                .Qty = _cartItem.Qty
                .List_Price = _cartItem.EWpartnoX.EW_Rate * _cartItem.Unit_Price 'FormatNumber(_cartitem.EWpartnoX.EW_Rate * _cartitem.Unit_Price, 2)
                .otype = _cartItem.otype
                .higherLevel = _cartItem.higherLevel
                If _cartItem.otype = CartItemType.BtosParent Then
                   ' .List_Price = _cartItem.ChildExtendedWarrantyPriceX ' (_cartitem.EWpartnoX.EW_Rate * _cartitem.ChildSubListPriceX) / _cartitem.Qty
                    .List_Price = 0
                    Dim _cartlistBtosChild As List(Of CartItem) = CartList.Where(Function(p) p.higherLevel = _cartItem.Line_No AndAlso p.Cart_Id = _cartItem.Cart_Id).OrderBy(Function(p) p.Line_No).ToList()
                    If _cartlistBtosChild.Count > 0 Then
                        .List_Price = _cartItem.EWpartnoX.EW_Rate * _cartlistBtosChild.Sum(Function(p) p.Unit_Price * (p.Qty / _cartItem.Qty))
                    End If
                    .otype = CartItemType.BtosPart
                    .higherLevel = _cartItem.Line_No
                    Dim objlineno As Object = (From i In CartList
                                Where (i.higherLevel = higherLevel OrElse i.Line_No = higherLevel) AndAlso i.Cart_Id = cart_id).Max(Function(x) x.Line_No)
                    .Line_No = Integer.Parse(objlineno) + 1
                End If
                .Unit_Price = .List_Price
                '.Itp = itp
                .Delivery_Plant = _cartItem.Delivery_Plant
                '.Category = category
                '.class = classABC
                '.rohs = ROHS
                .Ew_Flag = 0
                .req_date = _cartItem.req_date
                .due_date = _cartItem.due_date
                .SatisfyFlag = _cartItem.SatisfyFlag
                .CanbeConfirmed = _cartItem.CanbeConfirmed
                .inventory = _cartItem.inventory
                .QUOTE_ID = quoteid
                .CustMaterial = ""
            End With
            CartList.Add(_EWcartitem)
        End If

        'mycart.Add_WithDelete_V2(cart_id, line_no, part_no, description, QTY, listprice, unitprice, itp, delivery_plant, category, classABC, ROHS, EW_FLAG, req_date, due_date, satisfyFlag, canbeConfirmed, custMaterial, inventory, otype, Model_NO, "", unitprice, higherLevel)
        Return line_no
    End Function
    Public Function isBtoOrder(ByVal cart_id As String) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and otype='-1'", cart_id), "")
        If dt.Rows.Count > 0 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isSBCBtoOrder(ByVal cart_id As String) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and otype='-1' and part_no = 'SBC-BTO'", cart_id), "")
        If dt.Rows.Count > 0 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isOnlyBtoOrder(ByVal cart_id As String) As Boolean
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and  otype=0  ", cart_id), "")
        If dt.Rows.Count > 0 Then
            Return False
        End If
        Return True
    End Function
    Public Function isOnlyComponentOrder(ByVal cart_id As String) As Boolean
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and (otype=-1 or otype =1)  ", cart_id), "")
        If dt.Rows.Count > 0 Then
            Return False
        End If
        Return True
    End Function
    Public Function isQuote2Order(ByVal cart_id As String, ByRef QuoteID As String) As Boolean
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and QUOTE_ID is not null and QUOTE_ID <> '' ", cart_id), "")
        If dt.Rows.Count > 0 Then
            QuoteID = dt.Rows(0).Item("QUOTE_ID").ToString
            Return True
        End If
        Return False
    End Function
    Public Function getMaxLineNo(ByVal cart_id As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(line_no) from {0} where cart_id='{1}'", Me.tb, cart_id))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Function getMaxLineNoV2(ByVal cart_id As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(line_no) from {0} where cart_id='{1}' and otype=0", Me.tb, cart_id))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Function getBtosAllParentLineNo(ByVal cart_id As String) As DataTable
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select  Line_No ,Part_No from  cart_detail where Cart_Id='{0}' and otype =-1 order by Line_No ", cart_id))
        Return dt
    End Function

    Public Function getBtosParentLineNo(ByVal cart_id As String) As Integer
        Dim ParentLineNo As Integer = 0
        Do While True
            ParentLineNo = ParentLineNo + 100
            If CInt( _
              dbUtil.dbExecuteScalar(Me.conn, String.Format("select count(Line_No) as counts from {0} where cart_id='{1}' and Line_No={2}", Me.tb, cart_id, ParentLineNo))
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return ParentLineNo
    End Function
    Public Function getBtosMaxLineNo(ByVal cart_id As String, ByVal HigherLevel As Integer) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(line_no) from {0} where cart_id='{1}' and (higherLevel={2} or Line_No={2})", Me.tb, cart_id, HigherLevel))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Function getEWFlagBTO(ByVal cart_id As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(ew_flag) from {0} where cart_id='{1}'", Me.tb, cart_id))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Function getEWFlagbyBtoHigherLevel(ByVal cart_id As String, ByVal HigherLevel As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(ew_flag) from {0} where cart_id='{1}' and Line_No={2} ", Me.tb, cart_id, HigherLevel))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Function getMaxDueDate(ByVal cart_id As String) As Date
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(due_date) from {0} where cart_id='{1}'", Me.tb, cart_id))
        If IsDate(o) Then
            Return CDate(o)
        End If
        Return Now
    End Function
    Public Function getMaxReqDate(ByVal cart_id As String) As Date
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(req_date) from {0} where cart_id='{1}'", Me.tb, cart_id))
        If IsDate(o) Then
            Return CDate(o)
        End If
        Return Now
    End Function
    Public Function getTotalAmount(ByVal cart_id As String) As Decimal
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select sum(qty * unit_price) from {0} where cart_id='{1}'", Me.tb, cart_id))
        If IsNumeric(o) Then
            Return CDec(o)
        End If
        Return 0
    End Function
    Public Function getTotalPrice_EW(ByVal cart_id As String) As Decimal
        Dim o As Decimal = getTotalAmount_EW(cart_id)
        Dim n As Integer = 1
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and otype=-1", cart_id), "")
        If dt.Rows.Count > 0 Then
            n = dt.Rows(0).Item("qty")
        End If
        Return o / n
    End Function
    Public Function getTotalAmount_EW(ByVal cart_id As String) As Decimal
        Dim DT As DataTable = Me.GetDT(String.Format("cart_id='{0}' and ew_flag>0", cart_id), "")
        If DT.Rows.Count > 0 Then
            Dim am As Decimal = 0
            For Each r As DataRow In DT.Rows
                Dim EWByReg As Boolean = False

                If HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("US") Then
                    EWByReg = True
                End If
                If EWByReg = False OrElse (EWByReg = True AndAlso SAPDAL.CommonLogic.isWarrantable(r.Item("part_No"))) Then
                    Dim qty As Integer = r.Item("qty")
                    Dim price As Decimal = r.Item("unit_price")
                    Dim month As Integer = r.Item("ew_flag")
                    am += qty * price * Glob.getRateByEWItem(Glob.getEWItemByMonth(month), r.Item("delivery_plant"))
                End If
            Next
            Return am
        End If
        Return 0
    End Function
    Public Function reSetLineNoAfterDel(ByVal cart_id As String, ByVal line_no As Integer) As Integer
        Me.Update(String.Format("cart_id='{0}' and line_no>'{1}'", cart_id, line_no), String.Format("line_no=line_no-1"))
        Return 1
    End Function
    Public Function reSetLineNoBeforeInsert(ByVal cart_id As String, ByVal line_no As Integer) As Integer
        Me.Update(String.Format("cart_id='{0}' and line_no>='{1}'", cart_id, line_no), String.Format("line_no=line_no+1"))
        Return 1
    End Function
    Public Function isItemWithEW(ByVal cart_id As String, ByVal line_no As Integer) As Integer
        Return Me.IsExists(String.Format("cart_id='{0}' and line_no='{1}' and ew_flag>0", cart_id, line_no))
    End Function
    Public Function exChangeLineNo(ByVal cart_id As String, ByVal line_no1 As Integer, ByVal line_no2 As Integer) As Integer
        Dim MaxLineNo As Integer = getMaxLineNo(cart_id)
        If line_no1 > 0 And line_no1 <= MaxLineNo And line_no2 > 0 And line_no2 <= MaxLineNo And line_no1 <> line_no2 Then
            If Me.IsExists(String.Format("cart_id='{0}' and line_no='{1}' and otype=-1", cart_id, line_no1)) = 0 And _
                Me.IsExists(String.Format("cart_id='{0}' and line_no='{1}' and otype=-1", cart_id, line_no2)) = 0 Then
                Me.Update(String.Format("cart_id='{0}' and line_no='{1}'", cart_id, line_no1), String.Format("line_no=-1"))
                Me.Update(String.Format("cart_id='{0}' and line_no='{1}'", cart_id, line_no2), String.Format("line_no='{0}'", line_no1))
                Me.Update(String.Format("cart_id='{0}' and line_no=-1", cart_id), String.Format("line_no='{0}'", line_no2))
            End If
        End If
        Return 1
    End Function
    Public Function isBtoParentItem(ByVal cart_id As String, ByVal line_no As Integer) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and line_no='{1}' and otype='-1'", cart_id, line_no), "")
        If dt.Rows.Count = 1 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isBtoChildItem(ByVal cart_id As String, ByVal line_no As Integer) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and line_no='{1}' and otype='1'", cart_id, line_no), "")
        If dt.Rows.Count = 1 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isStandItem(ByVal cart_id As String, ByVal line_no As Integer) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("cart_id='{0}' and line_no='{1}' and otype='0'", cart_id, line_no), "")
        If dt.Rows.Count = 1 Then
            Return 1
        End If
        Return 0
    End Function
End Class


Public Class SAPProduct : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
End Class

Public Class SAPProduct_ABC : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

End Class

Public Class Cust_Material : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

End Class

Public Class cart_history : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Overloads Function Add(ByVal cart_id As String, _
                                       ByVal Company_id As String, _
                                       ByVal description As String, _
                                       ByVal Created_by As String, _
                                       ByVal Created_on As DateTime, _
                                       ByVal OSTATUS As Integer) As Integer
        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}','{4}','{5}','{6}','1')", _
                                          Me.tb, _
                                          cart_id, _
                                          Company_id, _
                                          description, _
                                          Created_by, _
                                          Created_on, _
                                          OSTATUS)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function

    Public Function SaveCartHistory(ByVal DSC As String, ByVal Status As Integer) As String
        Dim _cartid As String = HttpContext.Current.Session("cart_Id")
        'Dim mycart As New CartList("b2b", "cart_detail")
        Dim newCartID As String = Glob.GetNoByPrefix("CH")
        Me.Add(newCartID, HttpContext.Current.Session("company_id"), DSC, HttpContext.Current.Session("user_Id"), Now(), Status)
        'mycart.CopyCart(_cartid, newCartID)
        MyCartX.Copy2Cart(_cartid, newCartID)
        Return newCartID
    End Function
End Class
Public Class order_Master_Extension : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Overloads Function Add(ByVal ORDER_ID As String, ByVal PI2CUSTOMER_FLAG As Integer) As Integer 
        Dim str As String = String.Format("DELETE FROM {0} WHERE ORDER_ID ='{1}';insert into {0} values (N'{1}',{2})", _
                                          Me.tb, _
                                            ORDER_ID, _
                                            PI2CUSTOMER_FLAG)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class
Public Class order_Master : Inherits tbBase

    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Overloads Function Add(ByVal ORDER_ID As String, ByVal ORDER_NO As String, ByVal ORDER_TYPE As String, ByVal PO_NO As String, _
                                   ByVal PO_DATE As DateTime, ByVal SOLDTO_ID As String, ByVal SHIPTO_ID As String, ByVal CURRENCY As String, _
                                   ByVal REQUIRED_DATE As Date, Optional ByVal BILLTO_ID As String = "", Optional ByVal SALES_ID As String = "", _
                                  Optional ByVal ORDER_DATE As DateTime = #12:00:00 AM#, Optional ByVal PAYMENT_TYPE As String = "", _
                                  Optional ByVal ATTENTION As String = "", Optional ByVal PARTIAL_FLAG As Char = "N", _
                                  Optional ByVal COMBINE_ORDER_FLAG As Char = "", Optional ByVal EARLY_SHIP_FLAG As Char = "", _
                                  Optional ByVal FREIGHT As Decimal = 0.0, Optional ByVal INSURANCE As Decimal = 0.0, Optional ByVal REMARK As String = "", _
                                  Optional ByVal PRODUCT_SITE As String = "", Optional ByVal DUE_DATE As Date = #12:00:00 AM#, Optional ByVal SHIPMENT_TERM As String = "", _
                                  Optional ByVal SHIP_VIA As String = "", Optional ByVal ORDER_NOTE As String = "", Optional ByVal ORDER_STATUS As String = "", _
                                  Optional ByVal TOTAL_AMOUNT As Decimal = 0.0, Optional ByVal TOTAL_LINE As Integer = 0, Optional ByVal LAST_UPDATED As DateTime = #12:00:00 AM#, _
                                  Optional ByVal CREATED_DATE As DateTime = #12:00:00 AM#, Optional ByVal CREATED_BY As String = "", Optional ByVal CUSTOMER_ATTENTION As String = "", _
                                  Optional ByVal AUTO_ORDER_FLAG As Char = "", Optional ByVal INCOTERM As String = "", Optional ByVal INCOTERM_TEXT As String = "", _
                                  Optional ByVal SALES_NOTE As String = "", Optional ByVal OP_NOTE As String = "", Optional ByVal SHIP_CONDITION As String = "", _
                                  Optional ByVal NONERoHS_ACCEPT As Char = "", Optional ByVal ProjectFlag As String = "", Optional ByVal Z7Sales As String = "", _
                                  Optional ByVal DefaultSalesNote As String = "N", Optional ByVal prj_Note As String = "", Optional ByVal EARLY_SHIP As String = "", _
                                  Optional ByVal ER_EMPLOYEE As String = "", Optional ByVal END_CUST As String = "", Optional ByVal KEYPERSON As String = "", _
                                  Optional ByVal CREDIT_CARD As String = "", Optional ByVal CREDIT_CARD_EXPIRE_DATE As DateTime = #12:00:00 AM#, _
                                  Optional ByVal CREDIT_CARD_VERIFY_NUMBER As String = "", Optional ByVal PayTerm As String = "", _
                                  Optional ByVal CreditCardType As String = "", Optional ByVal CreditCardHolderName As String = "", _
                                  Optional ByVal BillingInstructionInfo As String = "", Optional ByVal EmployeeID As String = "", _
                                  Optional ByVal DistChann As String = "", Optional ByVal Division As String = "", Optional ByVal SalesGroup As String = "", _
                                  Optional ByVal SalesOffice As String = "", Optional ByVal District As String = "", Optional ByVal IS_EARLYSHIP As Integer = 0, Optional ByVal isExampt As Integer = 0) As Integer
        If ORDER_DATE = #12:00:00 AM# Then
            ORDER_DATE = Now
        End If
        If DUE_DATE = #12:00:00 AM# Then
            DUE_DATE = Now
        End If
        If LAST_UPDATED = #12:00:00 AM# Then
            LAST_UPDATED = Now
        End If
        If CREATED_DATE = #12:00:00 AM# Then
            CREATED_DATE = Now
        End If
        If CREDIT_CARD_EXPIRE_DATE = #12:00:00 AM# Then
            CREDIT_CARD_EXPIRE_DATE = Now
        End If
        'Dim str As String = String.Format(" insert into {0} ( " + _
        '                                  " [ORDER_ID],[ORDER_NO],[ORDER_TYPE],[PO_NO],[PO_DATE],[SOLDTO_ID],[SHIPTO_ID],[BILLTO_ID],[SALES_ID]," + _
        '                                  " [ORDER_DATE],[PAYMENT_TYPE],[ATTENTION],[PARTIAL_FLAG],[COMBINE_ORDER_FLAG],[EARLY_SHIP_FLAG],[FREIGHT], " + _
        '                                  " [INSURANCE],[REMARK],[PRODUCT_SITE],[DUE_DATE],[REQUIRED_DATE],[SHIPMENT_TERM],[SHIP_VIA],[CURRENCY], " + _
        '                                  " [ORDER_NOTE],[ORDER_STATUS],[TOTAL_AMOUNT],[TOTAL_LINE],[LAST_UPDATED],[CREATED_DATE],[CREATED_BY], " + _
        '                                  " [CUSTOMER_ATTENTION],[AUTO_ORDER_FLAG],[INCOTERM],[INCOTERM_TEXT],[SALES_NOTE],[OP_NOTE],[SHIP_CONDITION], " + _
        '                                  " [NONERoHS_ACCEPT],[ProjectFlag],[Z7Sales],[DefaultSalesNote],[prj_Note],[EARLY_SHIP],[ER_EMPLOYEE], " + _
        '                                  " [END_CUST],[KEYPERSON],[CREDIT_CARD],[CREDIT_CARD_EXPIRE_DATE],[CREDIT_CARD_VERIFY_NUMBER], [PAYTERM], " + _
        '                                  " [CREDIT_CARD_TYPE], [CREDIT_CARD_HOLDER],[BILLINGINSTRUCTION_INFO],[EMPLOYEEID],[DIST_CHAN],[DIVISION],[SALESGROUP],[SALESOFFICE]) " + _
        '                                  " values (N'{1}',N'{2}',N'{3}',N'{4}',N'{5}',N'{6}',N'{7}',N'{8}',N'{9}',N'{10}',N'{11}',N'{12}', " + _
        '                                  " N'{13}',N'{14}',N'{15}',N'{16}',N'{17}',N'{18}',N'{19}',N'{20}',N'{21}',N'{22}',N'{23}',N'{24}', " + _
        '                                  " N'{25}',N'{26}',N'{27}',N'{28}',N'{29}',N'{30}',N'{31}',N'{32}',N'{33}',N'{34}',N'{35}',N'{36}', " + _
        '                                  " N'{37}',N'{38}',N'{39}',N'{40}',N'{41}',N'{42}',N'{43}',N'{44}',N'{45}',N'{46}',N'{47}',N'{48}', " + _
        '                                  " N'{49}',N'{50}', N'{51}', N'{52}', N'{53}',N'{54}',N'{55}',N'{56}',N'{57}',N'{58}',N'{59}')", _
        '                                  Me.tb, _
        '                                    ORDER_ID, ORDER_NO, ORDER_TYPE, PO_NO, PO_DATE, SOLDTO_ID, SHIPTO_ID, BILLTO_ID, SALES_ID, _
        '                                    ORDER_DATE, PAYMENT_TYPE, ATTENTION, PARTIAL_FLAG, COMBINE_ORDER_FLAG, EARLY_SHIP_FLAG, _
        '                                    FREIGHT, INSURANCE, REMARK, PRODUCT_SITE, DUE_DATE, REQUIRED_DATE, SHIPMENT_TERM, _
        '                                    SHIP_VIA, CURRENCY, ORDER_NOTE, ORDER_STATUS, TOTAL_AMOUNT, TOTAL_LINE, LAST_UPDATED, _
        '                                    CREATED_DATE, CREATED_BY, CUSTOMER_ATTENTION, AUTO_ORDER_FLAG, INCOTERM, INCOTERM_TEXT, _
        '                                    SALES_NOTE, OP_NOTE, SHIP_CONDITION, NONERoHS_ACCEPT, ProjectFlag, Z7Sales, DefaultSalesNote, _
        '                                    prj_Note, EARLY_SHIP, ER_EMPLOYEE, END_CUST, KEYPERSON, CREDIT_CARD, CREDIT_CARD_EXPIRE_DATE, _
        '                                    CREDIT_CARD_VERIFY_NUMBER, PayTerm, CreditCardType, Replace(CreditCardHolderName, "'", "''"), Replace(BillingInstructionInfo, "'", "''"), _
        '                                    Replace(EmployeeID, "'", "''"), Replace(DistChann, "'", "''"), Replace(Division, "'", "''"), Replace(SalesGroup, "'", "''"), Replace(SalesOffice, "'", "''"))
        'dbUtil.dbExecuteNoQuery(Me.conn, str)
        Dim A As New MyOrderDSTableAdapters.ORDER_MASTERTableAdapter
        A.Insert(ORDER_ID, ORDER_NO, ORDER_TYPE, PO_NO, PO_DATE, SOLDTO_ID, SHIPTO_ID, BILLTO_ID, _
                  SALES_ID, ORDER_DATE, PAYMENT_TYPE, ATTENTION, PARTIAL_FLAG, COMBINE_ORDER_FLAG, _
                  EARLY_SHIP_FLAG, FREIGHT, INSURANCE, REMARK, PRODUCT_SITE, DUE_DATE, REQUIRED_DATE, _
                  SHIPMENT_TERM, SHIP_VIA, CURRENCY, ORDER_NOTE, ORDER_STATUS, TOTAL_AMOUNT, TOTAL_LINE, LAST_UPDATED, _
CREATED_DATE, CREATED_BY, CUSTOMER_ATTENTION, AUTO_ORDER_FLAG, INCOTERM, INCOTERM_TEXT, _
SALES_NOTE, OP_NOTE, SHIP_CONDITION, NONERoHS_ACCEPT, ProjectFlag, Z7Sales, DefaultSalesNote,
prj_Note, EARLY_SHIP, ER_EMPLOYEE, END_CUST, KEYPERSON, CREDIT_CARD, CREDIT_CARD_EXPIRE_DATE, _
CREDIT_CARD_VERIFY_NUMBER, PayTerm, CreditCardHolderName, CreditCardType, BillingInstructionInfo, _
EmployeeID, DistChann, Division, SalesGroup, SalesOffice, District, IS_EARLYSHIP, isExampt)
        Return 1
    End Function
End Class
Public Class order_Detail : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Overloads Function Add(ByVal ORDER_ID As String, _
                                    ByVal LINE_NO As Integer, _
                                    ByVal PRODUCT_LINE As String, _
                                    ByVal PART_NO As String, _
                                    ByVal ORDER_LINE_TYPE As String, _
                                    ByVal QTY As Integer, _
                                    ByVal LIST_PRICE As Decimal, _
                                    ByVal UNIT_PRICE As Decimal, _
                                    ByVal REQUIRED_DATE As Date, _
                                    ByVal DUE_DATE As Date, _
                                    ByVal ERP_SITE As String, _
                                    ByVal ERP_LOCATION As String, _
                                    ByVal AUTO_ORDER_FLAG As Char, _
                                    ByVal AUTO_ORDER_QTY As Integer, _
                                    ByVal SUPPLIER_DUE_DATE As Date, _
                                    ByVal LINE_PARTIAL_FLAG As Integer, _
                                    ByVal RoHS_FLAG As String, _
                                    ByVal EXWARRANTY_FLAG As String, _
                                    ByVal CustMaterialNo As String, _
                                    ByVal DeliveryPlant As String, _
                                    ByVal NoATPFlag As String, _
                                    ByVal DMF_Flag As String, _
                                    ByVal OptyID As String, _
                                    Optional ByVal cate As String = "", Optional ByVal Description As String = "", Optional ByVal HigherLevel As Integer = 0) As Integer

        'Frank 2012/07/28 Use the ORDER_DETAILTableAdapter to insert a record of table Order_Detail
        Dim _ODTA As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
        Return _ODTA.Insert(ORDER_ID, LINE_NO, _
                                            PRODUCT_LINE, _
                                            PART_NO, _
                                            ORDER_LINE_TYPE, _
                                            QTY, _
                                            LIST_PRICE, _
                                            UNIT_PRICE, _
                                            REQUIRED_DATE, _
                                            DUE_DATE, _
                                            ERP_SITE, _
                                            ERP_LOCATION, _
                                            AUTO_ORDER_FLAG, _
                                            AUTO_ORDER_QTY, _
                                            SUPPLIER_DUE_DATE, _
                                            LINE_PARTIAL_FLAG, _
                                            RoHS_FLAG, _
                                            EXWARRANTY_FLAG, _
                                            CustMaterialNo, _
                                            DeliveryPlant, _
                                            NoATPFlag, _
                                            DMF_Flag, _
                                            OptyID, _
                                            cate, _
                                            Description, HigherLevel)

        'Dim str As String = String.Format("insert into {0} ([ORDER_ID],[LINE_NO],[PRODUCT_LINE],[PART_NO],[ORDER_LINE_TYPE],[QTY],[LIST_PRICE],[UNIT_PRICE],[REQUIRED_DATE] ,[DUE_DATE] " & _
        '                                   "  ,[ERP_SITE] ,[ERP_LOCATION],[AUTO_ORDER_FLAG],[AUTO_ORDER_QTY],[SUPPLIER_DUE_DATE],[LINE_PARTIAL_FLAG],[RoHS_FLAG] ,[EXWARRANTY_FLAG] ,[CustMaterialNo]  " & _
        '                                   "  ,[DeliveryPlant],[NoATPFlag] ,[DMF_Flag] ,[OptyID] ,[Cate],[Description] " & _
        '                                   " ) " & _
        '                                   " values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}','{22}','{23}','{24}',N'{25}')", _
        '                                    Me.tb, _
        '                                    ORDER_ID, _
        '                                    LINE_NO, _
        '                                    PRODUCT_LINE, _
        '                                    PART_NO, _
        '                                    ORDER_LINE_TYPE, _
        '                                    QTY, _
        '                                    LIST_PRICE, _
        '                                    UNIT_PRICE, _
        '                                    REQUIRED_DATE, _
        '                                    DUE_DATE, _
        '                                    ERP_SITE, _
        '                                    ERP_LOCATION, _
        '                                    AUTO_ORDER_FLAG, _
        '                                    AUTO_ORDER_QTY, _
        '                                    SUPPLIER_DUE_DATE, _
        '                                    LINE_PARTIAL_FLAG, _
        '                                    RoHS_FLAG, _
        '                                    EXWARRANTY_FLAG, _
        '                                    CustMaterialNo, _
        '                                    DeliveryPlant, _
        '                                    NoATPFlag, _
        '                                    DMF_Flag, _
        '                                    OptyID, _
        '                                    cate, Description)
        'dbUtil.dbExecuteNoQuery(Me.conn, str)
        'Return 1
    End Function
    Public Overloads Function Add_V2(ByVal ORDER_ID As String, _
                                    ByVal LINE_NO As Integer, _
                                    ByVal PRODUCT_LINE As String, _
                                    ByVal PART_NO As String, _
                                    ByVal ORDER_LINE_TYPE As String, _
                                    ByVal QTY As Integer, _
                                    ByVal LIST_PRICE As Decimal, _
                                    ByVal UNIT_PRICE As Decimal, _
                                    ByVal REQUIRED_DATE As Date, _
                                    ByVal DUE_DATE As Date, _
                                    ByVal ERP_SITE As String, _
                                    ByVal ERP_LOCATION As String, _
                                    ByVal AUTO_ORDER_FLAG As Char, _
                                    ByVal AUTO_ORDER_QTY As Integer, _
                                    ByVal SUPPLIER_DUE_DATE As Date, _
                                    ByVal LINE_PARTIAL_FLAG As Integer, _
                                    ByVal RoHS_FLAG As String, _
                                    ByVal EXWARRANTY_FLAG As String, _
                                    ByVal CustMaterialNo As String, _
                                    ByVal DeliveryPlant As String, _
                                    ByVal NoATPFlag As String, _
                                    ByVal DMF_Flag As String, _
                                    ByVal OptyID As String, _
                                     ByVal cate As String, ByVal Description As String, ByVal HigherLevel As Integer) As Integer

        'Frank 2012/07/28 Use the ORDER_DETAILTableAdapter to insert a record of table Order_Detail
        Dim _ODTA As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
        Return _ODTA.Insert(ORDER_ID, LINE_NO, _
                                            PRODUCT_LINE, _
                                            PART_NO, _
                                            ORDER_LINE_TYPE, _
                                            QTY, _
                                            LIST_PRICE, _
                                            UNIT_PRICE, _
                                            REQUIRED_DATE, _
                                            DUE_DATE, _
                                            ERP_SITE, _
                                            ERP_LOCATION, _
                                            AUTO_ORDER_FLAG, _
                                            AUTO_ORDER_QTY, _
                                            SUPPLIER_DUE_DATE, _
                                            LINE_PARTIAL_FLAG, _
                                            RoHS_FLAG, _
                                            EXWARRANTY_FLAG, _
                                            CustMaterialNo, _
                                            DeliveryPlant, _
                                            NoATPFlag, _
                                            DMF_Flag, _
                                            OptyID, _
                                            cate, _
                                            Description, HigherLevel)

        'Dim str As String = String.Format("insert into {0} ([ORDER_ID],[LINE_NO],[PRODUCT_LINE],[PART_NO],[ORDER_LINE_TYPE],[QTY],[LIST_PRICE],[UNIT_PRICE],[REQUIRED_DATE] ,[DUE_DATE] " & _
        '                                   "  ,[ERP_SITE] ,[ERP_LOCATION],[AUTO_ORDER_FLAG],[AUTO_ORDER_QTY],[SUPPLIER_DUE_DATE],[LINE_PARTIAL_FLAG],[RoHS_FLAG] ,[EXWARRANTY_FLAG] ,[CustMaterialNo]  " & _
        '                                   "  ,[DeliveryPlant],[NoATPFlag] ,[DMF_Flag] ,[OptyID] ,[Cate],[Description] " & _
        '                                   " ) " & _
        '                                   " values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}','{22}','{23}','{24}',N'{25}')", _
        '                                    Me.tb, _
        '                                    ORDER_ID, _
        '                                    LINE_NO, _
        '                                    PRODUCT_LINE, _
        '                                    PART_NO, _
        '                                    ORDER_LINE_TYPE, _
        '                                    QTY, _
        '                                    LIST_PRICE, _
        '                                    UNIT_PRICE, _
        '                                    REQUIRED_DATE, _
        '                                    DUE_DATE, _
        '                                    ERP_SITE, _
        '                                    ERP_LOCATION, _
        '                                    AUTO_ORDER_FLAG, _
        '                                    AUTO_ORDER_QTY, _
        '                                    SUPPLIER_DUE_DATE, _
        '                                    LINE_PARTIAL_FLAG, _
        '                                    RoHS_FLAG, _
        '                                    EXWARRANTY_FLAG, _
        '                                    CustMaterialNo, _
        '                                    DeliveryPlant, _
        '                                    NoATPFlag, _
        '                                    DMF_Flag, _
        '                                    OptyID, _
        '                                    cate, Description)
        'dbUtil.dbExecuteNoQuery(Me.conn, str)
        'Return 1
    End Function
    Public Function getMaxLineNo(ByVal Order_id As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(line_no) from {0} where order_id='{1}'", Me.tb, Order_id))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Function getMaxDueDate(ByVal order_id As String) As Date
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(due_date) from {0} where order_id='{1}'", Me.tb, order_id))
        If IsDate(o) Then
            Return CDate(o)
        End If
        Return Now
    End Function
    Public Function getMaxDueDateWithout100Line(ByVal order_id As String) As Date
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(due_date) from {0} where order_id='{1}' and LINE_NO<>100", Me.tb, order_id))
        If IsDate(o) Then
            Return CDate(o)
        End If
        Return Now
    End Function
    Public Function get100LineReqDate(ByVal order_id As String) As Date
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select required_date from {0} where order_id='{1}'", Me.tb, order_id))
        If IsDate(o) Then
            Return CDate(o)
        End If
        Return Now
    End Function
    Public Function getMaxReqDateWithout100Line(ByVal order_id As String) As Date
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(required_date) from {0} where order_id='{1}' and LINE_NO<>100", Me.tb, order_id))
        If IsDate(o) Then
            Return CDate(o)
        End If
        Return Now
    End Function
    Public Function getMaxReqDate(ByVal order_id As String) As Date
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(required_date) from {0} where order_id='{1}'", Me.tb, order_id))
        If IsDate(o) Then
            Return CDate(o)
        End If
        Return Now
    End Function
    Public Function getTotalAmount(ByVal order_id As String) As Decimal
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select sum(qty * unit_price) from {0} where order_id='{1}'", Me.tb, order_id))
        If IsNumeric(o) Then
            Return CDec(o)
        End If
        Return 0
    End Function
    Public Function getTotalAmountV2(ByVal order_id As String, ByVal higherLevel As String) As Decimal
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select sum(qty * unit_price) from {0} where order_id='{1}' and higherLevel = {2}", Me.tb, order_id, higherLevel))
        If IsNumeric(o) Then
            Return CDec(o)
        End If
        Return 0
    End Function
    Public Function getTotalPrice(ByVal order_id As String) As Decimal
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select sum(unit_price) from {0} where order_id='{1}'", Me.tb, order_id))
        If IsNumeric(o) Then
            Return CDec(o)
        End If
        Return 0
    End Function
    Public Function getTotalPriceV2(ByVal order_id As String, ByVal higherLevel As String) As Decimal
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select sum(unit_price) from {0} where order_id='{1}' and higherLevel = {2}", Me.tb, order_id, higherLevel))
        If IsNumeric(o) Then
            Return CDec(o)
        End If
        Return 0
    End Function
    Public Function reSetLineNoAfterDel(ByVal order_Id As String, ByVal line_no As Integer) As Integer
        Me.Update(String.Format("order_id='{0}' and line_no>'{1}'", order_Id, line_no), String.Format("line_no=line_no-1"))
        Return 1
    End Function
    Public Function reSetLineNoBeforeInsert(ByVal order_Id As String, ByVal line_no As Integer) As Integer
        Me.Update(String.Format("order_id='{0}' and line_no>='{1}'", order_Id, line_no), String.Format("line_no=line_no+1"))
        Return 1
    End Function

    Public Function isBtoOrder(ByVal order_id As String) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("order_id='{0}' and ORDER_LINE_TYPE='-1'", order_id), "")
        If dt.Rows.Count = 1 Then
            Return 1
        End If
        Return 0
    End Function
  
    Public Function isBtoParentItem(ByVal order_id As String, ByVal line_no As Integer) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("order_id='{0}' and line_no='{1}' and ORDER_LINE_TYPE='-1'", order_id, line_no), "")
        If dt.Rows.Count = 1 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isBtoNotSatisfy(ByVal order_id As String) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("order_id='{0}' and noATPflag=1", order_id), "")
        If dt.Rows.Count > 0 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isBtoChildItem(ByVal order_id As String, ByVal line_no As Integer) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("order_id='{0}' and line_no='{1}' and ORDER_LINE_TYPE='1'", order_id, line_no), "")
        If dt.Rows.Count = 1 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isStandItem(ByVal order_id As String, ByVal line_no As Integer) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("order_id='{0}' and line_no='{1}' and ORDER_LINE_TYPE='0'", order_id, line_no), "")
        If dt.Rows.Count = 1 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isOrderWithEW(ByVal order_id As String) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("order_id='{0}' and part_no like 'AGS-EW%' and ORDER_LINE_TYPE='0'", order_id), "")
        If dt.Rows.Count > 0 Then
            Return 1
        End If
        Return 0
    End Function
    Public Function isQuoteOrder(ByVal orderid As String, ByRef QuoteID As String, Optional ByRef QuoteNo As String = "") As Boolean
        Dim dt As DataTable = Me.GetDT(String.Format("order_id='{0}' and optyid is not null and optyid <> '' ", orderid), "")
        If dt.Rows.Count > 0 Then
            QuoteID = dt.Rows(0).Item("optyid").ToString
            If Not String.IsNullOrEmpty(QuoteID) Then
                Dim MyQuoteMaster As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(QuoteID)
                If MyQuoteMaster IsNot Nothing Then
                    QuoteNo = MyQuoteMaster.quoteNo
                End If
            End If
            Return True
        End If
        Return False
    End Function
End Class

Public Class SAP_Company : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
End Class

Public Class ORDER_PROC_STATUS : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Function getMaxLineSeq(ByVal Order_id As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(line_seq) from {0} where order_no='{1}'", Me.tb, Order_id))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function

    Public Overloads Function Add(ByVal ORDER_NO As String, _
                                 ByVal LINE_SEQ As Integer, _
                                 ByVal NUMBER As Integer, _
                                 ByVal MESSAGE As String, _
                                 ByVal CREATED_DATE As DateTime, _
                                 ByVal STATUS As Integer) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}','{4}','{5}','{6}')", _
                                            Me.tb, _
                                            ORDER_NO, _
                                            LINE_SEQ, _
                                            NUMBER, _
                                            MESSAGE, _
                                            CREATED_DATE, _
                                            STATUS)

        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class

Public Class ORDER_DETAIL_CHANGED_IN_SAP : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Overloads Function Add(ByVal ORDER_ID As String, _
                               ByVal order_no As String, _
                               ByVal LINE_NO As Integer, _
                               ByVal SCHEDULE_LINE_NO As Integer, _
                               ByVal PART_NO As String, _
                               ByVal OLD_QTY As Integer, _
                               ByVal OLD_DUE_DATE As DateTime, _
                               ByVal OLD_UNIT_PRICE As Decimal, _
                               ByVal NEW_QTY As Integer, _
                               ByVal NEW_DUE_DATE As DateTime, _
                               ByVal NEW_UNIT_PRICE As Decimal, _
                               ByVal CHANGED_FLAG As Integer) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}')", _
                                            Me.tb, _
                                            ORDER_ID, _
                                            order_no, _
                                            LINE_NO, _
                                            SCHEDULE_LINE_NO, _
                                            PART_NO, _
                                            OLD_QTY, _
                                            OLD_DUE_DATE, _
                                            OLD_UNIT_PRICE, _
                                            NEW_QTY, _
                                            NEW_DUE_DATE, _
                                            NEW_UNIT_PRICE, _
                                            CHANGED_FLAG)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function

End Class
Public Class company_contact : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

End Class


Public Class quotation_master : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Overloads Function Add(ByVal QUOTE_ID As String, _
                                    ByVal CURRENCY_SIGN As String, _
                                    ByVal Quote_To_Company As String, _
                                    ByVal Quote_Date As String, _
                                    ByVal Del_Date As String, _
                                    ByVal Quote_NO As String, _
                                    ByVal Ship_Term As String, _
                                    ByVal Exp_Date As String, _
                                    ByVal PaymentTerm As String, _
                                    ByVal Sales_Contact As String, _
                                    ByVal product_warranty As String, _
                                    ByVal Sales_Phone As String, _
                                    ByVal Quote_Note As String, _
                                    ByVal Quote_Company_Type As String, _
                                    ByVal Quote_language As String, _
                                    ByVal Sales_Email As String, _
                                    ByVal Quote_To_Company_ID As String, _
                                    ByVal Currency As String, _
                                    ByVal rbu_company As String, _
                                    ByVal ListPriceShowFlag As String, _
                                    ByVal DiscShowFlag As String, _
                                    ByVal DueDateShowFlag As String, _
                                    ByVal CurChangeFlag As String, _
                                    ByVal ExchangeRate As String, _
                                    ByVal Quote_To_Customer_Id As String, _
                                    ByVal ModifiedFlag As String, _
                                    ByVal DraftFlag As String, _
                                    ByVal isSAPFlag As String, _
                                    ByVal LumpSUMFlag As String, _
                                    ByVal Owner As String, _
                                    ByVal description As String, _
                                    ByVal Quote_to_contact As String, _
                                    ByVal s_catalog_id As String, _
                                    ByVal Account_RowID As String, _
                                    ByVal NextApprover As String, _
                                    ByVal ProductSplit As String, _
                                    ByVal SpecialITP As String, _
                                    ByVal Org As String, _
                                    ByVal NEW_GP As String, _
                                    ByVal AccountTeam As String, _
                                    ByVal Created_By As String, _
                                    ByVal Opty_ID As String, _
                                    ByVal Opty_Name As String, _
                                    ByVal vid As String, _
                                    ByVal related_info As String, _
                                    ByVal bank_info As String, _
                                    ByVal freight As String, _
                                    ByVal insurance As String, _
                                    ByVal specialCharge As String, _
                                    ByVal tax As String) As Integer

        Dim str As String = String.Format("insert into quotation_MASTER values('{0}','{1}',N'{2}','{3}','{4}','{5}','{6}','{7}',N'{8}','{9}','{10}','{11}',N'{12}','{13}','{14}','{15}','{16}','{17}','{18}','{19}','{20}','{21}','{22}','{23}','{24}','{25}','{26}','{27}','{28}','{29}',N'{30}',N'{31}','{32}',N'{33}','{34}','{35}','{36}','{37}','{38}','{39}','{40}','{41}',N'{42}','{43}',N'{44}',N'{45}','{46}','{47}','{48}','{49}')", _
                                            QUOTE_ID, _
                                            CURRENCY_SIGN, _
                                            Quote_To_Company, _
                                            Quote_Date, _
                                            Del_Date, _
                                            Quote_NO, _
                                            Ship_Term, _
                                            Exp_Date, _
                                            PaymentTerm, _
                                            Sales_Contact, _
                                            product_warranty, _
                                            Sales_Phone, _
                                            Quote_Note, _
                                            Quote_Company_Type, _
                                            Quote_language, _
                                            Sales_Email, _
                                            Quote_To_Company_ID, _
                                            Currency, _
                                            rbu_company, _
                                            ListPriceShowFlag, _
                                            DiscShowFlag, _
                                            DueDateShowFlag, _
                                            CurChangeFlag, _
                                            ExchangeRate, _
                                            Quote_To_Customer_Id, _
                                            ModifiedFlag, _
                                            DraftFlag, _
                                            isSAPFlag, _
                                            LumpSUMFlag, _
                                            Owner, _
                                            description, _
                                            Quote_to_contact, _
                                            s_catalog_id, _
                                            Account_RowID, _
                                            NextApprover, _
                                            ProductSplit, _
                                            SpecialITP, _
                                            Org, _
                                            NEW_GP, _
                                            AccountTeam, _
                                            Created_By, _
                                            Opty_ID, _
                                            Opty_Name, _
                                            vid, _
                                            related_info, _
                                            bank_info, _
                                            freight, _
                                            insurance, _
                                            specialCharge, _
                                            tax)

        dbUtil.dbExecuteNoQuery("MY", str)
        Return 1
    End Function
End Class

Public Class quotation_detail : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
    Public Overloads Function Add(ByVal QUOTE_ID As String, _
                                        ByVal LINE_NO As String, _
                                        ByVal PART_NO As String, _
                                        ByVal QTY As String, _
                                        ByVal LIST_PRICE As String, _
                                        ByVal UNIT_PRICE As String, _
                                        ByVal TYPE As String, _
                                        ByVal UPDATE_PRICE As String, _
                                        ByVal ATP_DATE As String, _
                                        ByVal ATP_NUM As String, _
                                        ByVal Request_Date As String, _
                                        ByVal ITP As String, _
                                        ByVal Reset_unit_price As String, _
                                        ByVal EXwarranty_FLAG As String, _
                                        ByVal reset_itp As String, _
                                        ByVal category As String) As Integer
        Dim str As String = String.Format("insert into quotation_DETAIL values('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}')", _
                                            QUOTE_ID, _
                                            LINE_NO, _
                                            PART_NO, _
                                            QTY, _
                                            LIST_PRICE, _
                                            UNIT_PRICE, _
                                            TYPE, _
                                            UPDATE_PRICE, _
                                            ATP_DATE, _
                                            ATP_NUM, _
                                            Request_Date, _
                                            ITP, _
                                            Reset_unit_price, _
                                            EXwarranty_FLAG, _
                                            reset_itp, _
                                            category)

        dbUtil.dbExecuteNoQuery("MY", str)
        Return 1
    End Function
    Public Function getMaxLineNo(ByVal quote_id As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(line_no) from {0} where quote_id='{1}'", Me.tb, quote_id))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function
    Public Function UpLineNo(ByVal quote_id As String, ByVal line_no As Integer) As Integer
        Dim line_no1 As Integer = line_no
        Dim line_no2 As Integer = line_no - 1
        If Me.IsExists(String.Format("quote_id='{0}' and line_no='{1}' and part_no like 'AGS-EW%'", quote_id, line_no2)) = 1 Then
            line_no2 = line_no2 - 1
        End If
        Dim MaxLineNo As Integer = getMaxLineNo(quote_id)
        If line_no1 > 0 And line_no1 <= MaxLineNo And line_no2 > 0 And line_no2 <= MaxLineNo And line_no1 <> line_no2 Then
            If Me.IsExists(String.Format("quote_id='{0}' and line_no='{1}' and type=-1", quote_id, line_no1)) = 0 And _
                Me.IsExists(String.Format("quote_id='{0}' and line_no='{1}' and type=-1", quote_id, line_no2)) = 0 Then
                Dim lewflg As Integer = 0
                Dim sewflg As Integer = 0

                lewflg = isItemWithEW(quote_id, line_no1)
                sewflg = isItemWithEW(quote_id, line_no2)
                If lewflg = 1 Then
                    Me.Delete(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no1 + 1))
                    Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no1), String.Format("EXwarranty_FLAG='0'"))
                    reSetLineNoAfterDel(quote_id, line_no1 + 1)
                End If
                If sewflg = 1 Then
                    Me.Delete(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no2 + 1))
                    Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no2), String.Format("EXwarranty_FLAG='0'"))
                    reSetLineNoAfterDel(quote_id, line_no2 + 1)
                End If

                Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no1), String.Format("line_no=-1"))
                Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no2), String.Format("line_no='{0}'", line_no1))
                Me.Update(String.Format("quote_id='{0}' and line_no=-1", quote_id), String.Format("line_no='{0}'", line_no2))
            End If
        End If
        Return 1
    End Function
    Public Function DownLineNo(ByVal quote_id As String, ByVal line_no As Integer) As Integer
        Dim line_no1 As Integer = line_no
        Dim line_no2 As Integer = line_no + 1
        If Me.IsExists(String.Format("quote_id='{0}' and line_no='{1}' and part_no like 'AGS-EW%'", quote_id, line_no2)) = 1 Then
            line_no2 = line_no2 + 1
        End If
        Dim MaxLineNo As Integer = getMaxLineNo(quote_id)
        If line_no1 > 0 And line_no1 <= MaxLineNo And line_no2 > 0 And line_no2 <= MaxLineNo And line_no1 <> line_no2 Then
            If Me.IsExists(String.Format("quote_id='{0}' and line_no='{1}' and type=-1", quote_id, line_no1)) = 0 And _
                Me.IsExists(String.Format("quote_id='{0}' and line_no='{1}' and type=-1", quote_id, line_no2)) = 0 Then
                Dim lewflg As Integer = 0
                Dim sewflg As Integer = 0

                lewflg = isItemWithEW(quote_id, line_no2)
                sewflg = isItemWithEW(quote_id, line_no1)
                If lewflg = 1 Then
                    Me.Delete(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no2 + 1))
                    Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no2), String.Format("EXwarranty_FLAG='0'"))
                    reSetLineNoAfterDel(quote_id, line_no2 + 1)
                End If
                If sewflg = 1 Then
                    Me.Delete(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no1 + 1))
                    Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no1), String.Format("EXwarranty_FLAG='0'"))
                    reSetLineNoAfterDel(quote_id, line_no1 + 1)
                End If

                Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no1), String.Format("line_no=-1"))
                Me.Update(String.Format("quote_id='{0}' and line_no='{1}'", quote_id, line_no2), String.Format("line_no='{0}'", line_no1))
                Me.Update(String.Format("quote_id='{0}' and line_no=-1", quote_id), String.Format("line_no='{0}'", line_no2))
            End If
        End If
        Return 1
    End Function

    Public Function reSetLineNoAfterDel(ByVal QUOTE_id As String, ByVal line_no As Integer) As Integer
        Me.Update(String.Format("QUOTE_id='{0}' and line_no>'{1}'", QUOTE_id, line_no), String.Format("line_no=line_no-1"))
        Return 1
    End Function
    Public Function reSetLineNoBeforeInsert(ByVal QUOTE_id As String, ByVal line_no As Integer) As Integer
        Me.Update(String.Format("QUOTE_id='{0}' and line_no>='{1}'", QUOTE_id, line_no), String.Format("line_no=line_no+1"))
        Return 1
    End Function
    Public Function isItemWithEW(ByVal QUOTE_id As String, ByVal line_no As Integer) As Integer
        Return Me.IsExists(String.Format("QUOTE_id='{0}' and line_no='{1}' and EXwarranty_FLAG>0", QUOTE_id, line_no))
    End Function

    Public Function getBtoTotalPice(ByVal quote_id As String) As Decimal
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select sum(unit_price) from {0} where quote_id='{1}'", Me.tb, quote_id))
        If IsNumeric(o) Then
            Return CDec(o)
        End If
        Return 0
    End Function

    Public Function isBtoOrder(ByVal quote_id As String) As Integer
        Dim dt As DataTable = Me.GetDT(String.Format("quote_id='{0}' and type='-1'", quote_id), "")
        If dt.Rows.Count > 0 Then
            Return 1
        End If
        Return 0
    End Function
End Class



Public Class TreeMap : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub
   
    Public Overloads Function Add(ByVal UID As String, _
                                 ByVal Name As String, _
                                 ByVal PUID As String, _
                                 ByVal Seq As Integer) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}','{4}')", _
                                            Me.tb, _
                                            UID, _
                                            Name, _
                                            PUID, _
                                            Seq)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class

Public Class CustProduct : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

    Public Overloads Function Add(ByVal UID As String, _
                                 ByVal Name As String, _
                                 ByVal Price As Decimal) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}')", _
                                            Me.tb, _
                                            UID, _
                                            Name, _
                                            Price)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class

Public Class CustCategory : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

    Public Overloads Function Add(ByVal UID As String, _
                                 ByVal Name As String) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}')", _
                                            Me.tb, _
                                            UID, _
                                            Name)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class

Public Class CustCatalog : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

    Public Overloads Function Add(ByVal UID As String, _
                                 ByVal Name As String) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}')", _
                                            Me.tb, _
                                            UID, _
                                            Name)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class

Public Class SpecialBto : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

    Public Overloads Function Add(ByVal UID As String, _
                                 ByVal Name As String, _
                                 ByVal Parent As String, _
                                 ByVal Price As Decimal) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}','{4}')", _
                                            Me.tb, _
                                            UID, _
                                            Name, _
                                            Parent, _
                                            Price)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function

End Class
Public Class Freight : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

    Public Overloads Function Add(ByVal order_id As String, _
                                  ByVal ftype As String, _
                                  ByVal fvalue As Decimal) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}')", _
                                            Me.tb, _
                                            order_id, _
                                           ftype, _
                                           fvalue)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class
Public Class VSO_MASTER : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

    Public Overloads Function Add(ByVal UID As String, _
                                  ByVal Company As String, _
                                  ByVal Currency As String, _
                                  ByVal CloseDate As Date, _
                                  ByVal CreatedDate As DateTime, _
                                  ByVal CreatedBy As String, _
                                  ByVal orderNo As String) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}','{4}','{5}','{6}','{7}')", _
                                            Me.tb, _
                                            UID, _
                                            Company, _
                                            Currency, _
                                            CloseDate.ToShortDateString, _
                                            CreatedDate, _
                                            CreatedBy, _
                                            orderNo)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
End Class
Public Class VSO_DETAIL : Inherits tbBase
    Sub New(ByVal conn As String, ByVal tb As String)
        Me.conn = conn
        Me.tb = tb
    End Sub

    Public Overloads Function Add(ByVal UID As String, _
                                 ByVal line_No As Integer, _
                                 ByVal partNo As String, _
                                 ByVal qty As Integer) As Integer


        Dim str As String = String.Format("insert into {0} values ('{1}','{2}','{3}','{4}')", _
                                            Me.tb, _
                                            UID, _
                                            line_No, _
                                            partNo, _
                                            qty)
        dbUtil.dbExecuteNoQuery(Me.conn, str)
        Return 1
    End Function
    Public Function getMaxLineNo(ByVal Uid As String) As Integer
        Dim o As Object = dbUtil.dbExecuteScalar(Me.conn, String.Format("select max(line_no) from {0} where UID='{1}'", Me.tb, Uid))
        If IsNumeric(o) Then
            Return CInt(o)
        End If
        Return 0
    End Function

End Class
