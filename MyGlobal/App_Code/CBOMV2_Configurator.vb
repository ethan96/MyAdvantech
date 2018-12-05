Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Web.Script.Services
Imports Advantech.Myadvantech.DataAccess
Imports Advantech.Myadvantech.DataAccess.DataCore
Imports Newtonsoft.Json

' To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://tempuri.org/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class CBOMV2_Configurator
    Inherits System.Web.Services.WebService

    <WebMethod()> _
    Public Function HelloWorld() As String
        Return "Hello World"
    End Function

    <WebMethod(EnableSession:=True)>
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)>
    Public Sub GetConfigRecord(RootID As String, SalesOrg As String, CBOMOrg As String, Type As Integer)
        Context.Response.Clear()

        If Not String.IsNullOrEmpty(RootID) AndAlso Not String.IsNullOrEmpty(SalesOrg) AndAlso Not String.IsNullOrEmpty(CBOMOrg) Then
            Context.Response.Write(JsonConvert.SerializeObject(CBOMV2_ConfiguratorDAL.GetConfigRecord(RootID, SalesOrg, CBOMOrg, Type)))
        Else
            Context.Response.Write(JsonConvert.SerializeObject(New List(Of EasyUITreeNode())))
        End If

        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub Add2Cart(SelectedItems As String, SelectedOther As Boolean)
        Context.Response.Clear()
        Dim ERPID As String = Session("company_id").ToString().ToUpper()
        Dim ORGID As String = Session("org_id").ToString
        Dim CARTID As String = Session("CART_ID").ToString
        Dim CURRENCY As String = Session("Company_currency").ToString
        Dim HigherLevel As Integer = MyCartX.getBtosParentLineNo(CARTID)


        Dim updateresult = New Advantech.Myadvantech.DataAccess.UpdateDBResult

        If Not String.IsNullOrEmpty(SelectedItems) Then
            Dim result As Object = CBOMV2_ConfiguratorDAL.Configurator2Cart(SelectedItems, ERPID, CARTID, CURRENCY, ORGID)

            ' Can't move whole MyCartX to API level, so do add EW process here......
            Dim cartlist As List(Of CartItem) = MyCartX.GetCartList(CARTID)
            Dim _EWlist As List(Of EWPartNo) = MyCartX.GetExtendedWarranty()
            Dim EWFlag As Integer = 0

            For Each c As CartItem In cartlist
                For Each _ew As EWPartNo In _EWlist
                    If String.Equals(_ew.EW_PartNO, c.Part_No) Then
                        EWFlag = _ew.ID
                    End If
                Next
            Next

            If EWFlag > 0 Then
                Dim _cartBtosParentitem As CartItem = MyCartX.GetCartItem(CARTID, HigherLevel)
                _cartBtosParentitem.Ew_Flag = EWFlag
                MyCartX.addExtendedWarrantyV2(_cartBtosParentitem, EWFlag)
            End If

            Context.Response.Write(JsonConvert.SerializeObject(result))
        Else
            updateresult.IsUpdated = False
            updateresult.ServerMessage = "Input is empty."
            Context.Response.Write(JsonConvert.SerializeObject(updateresult))
        End If

        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub GetPriceATP(ComponentName As String, ConfigQty As Integer)
        Context.Response.Clear()

        If Not String.IsNullOrEmpty(ComponentName) AndAlso IsNumeric(ConfigQty) Then
            Dim objPriceATP As MyCBOMDAL.PriceATP = MyCBOMDAL.GetCompPriceATP(ComponentName, ConfigQty)
            Context.Response.Write(JsonConvert.SerializeObject(objPriceATP))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub GetSRPConfigRecord(RootID As String)
        Context.Response.Clear()

        If Context.User.Identity.IsAuthenticated = True AndAlso Not String.IsNullOrEmpty(RootID) AndAlso Not String.IsNullOrEmpty(Session("ORG_ID")) Then
            Context.Response.Write(JsonConvert.SerializeObject(CBOMV2_ConfiguratorDAL.GetSRPConfigRecord(RootID, Session("ORG_ID").ToString.Substring(0, 2))))
        Else
            Context.Response.Write(JsonConvert.SerializeObject(New SRPBTO()))
        End If

        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub GetSRPPrice(PartNo As String, Qty As Integer)
        Context.Response.Clear()
        'Get currency sign
        Dim result As Boolean = False
        Dim currencysign As String = String.Empty
        result = Me.GetCurrencySign(PartNo, currencysign)
        'Get list pirce and unit price
        Dim listprice As Decimal = 0
        Dim unitprice As Decimal = 0
        Me.GetSRPListPriceAndUnitPrice(PartNo, listprice, unitprice)

        Dim priceFormat As String = "{0:n}"
        If currencysign.ToUpper() = "NT" Then priceFormat = "{0:n0}"

        Context.Response.Write(JsonConvert.SerializeObject(New With {.result = result, .currencysign = currencysign, .listprice = String.Format(priceFormat, listprice * Qty), .unitprice = String.Format(priceFormat, unitprice * Qty)}))
        Context.Response.End()
    End Sub

    Public Function GetCurrencySign(ByVal PartNo As String, ByRef CurrencySign As String) As Boolean
        If Context.User.Identity.IsAuthenticated = True AndAlso Not String.IsNullOrEmpty(PartNo) Then
            If PartNo.StartsWith("AGS-EW", StringComparison.CurrentCultureIgnoreCase) Then
                CurrencySign = String.Empty
                Return True
            Else
                CurrencySign = HttpContext.Current.Session("company_currency_sign")
                Return False
            End If
        End If
        CurrencySign = String.Empty
        Return True
    End Function

    Public Sub GetSRPListPriceAndUnitPrice(ByVal PartNo As String, ByRef ListPrice As Decimal, ByRef UnitPrice As Decimal)
        ListPrice = 0
        UnitPrice = 0
        If Context.User.Identity.IsAuthenticated = True AndAlso Not String.IsNullOrEmpty(PartNo) Then
            If String.Equals(PartNo, "Build In", StringComparison.CurrentCultureIgnoreCase) Then
                'All 0
            ElseIf PartNo.ToUpper.StartsWith("AGS-EW") Then
                ListPrice = Glob.getRateByEWItem(PartNo, Left(HttpContext.Current.Session("org_id"), 2) + "H1") * 100
                UnitPrice = ListPrice
            Else
                If Global_Inc.IsNumericItem(PartNo) Then
                    PartNo = Global_Inc.RemoveZeroString(PartNo)
                End If

                Dim WS As New MYSAPDAL, ProdInDt As New SAPDALDS.ProductInDataTable, ProdOutDt As New SAPDALDS.ProductOutDataTable, strErrMsg As String = ""
                ProdInDt.AddProductInRow(PartNo, 1)
                Dim retFlg As Boolean = WS.GetPrice(HttpContext.Current.Session("company_id"), HttpContext.Current.Session("company_id"), HttpContext.Current.Session("org_id"), ProdInDt, ProdOutDt, strErrMsg)
                If retFlg AndAlso ProdOutDt.Rows.Count > 0 Then
                    Dim upm As AuthUtil.UserPermission = AuthUtil.GetPermissionByUser()
                    'Calculate list price first
                    For Each r As SAPDALDS.ProductOutRow In ProdOutDt
                        If Decimal.TryParse(r.LIST_PRICE, 0) Then
                            ListPrice += Decimal.Parse(r.LIST_PRICE)
                        End If
                    Next
                    'Check permission to get unit pirce. If user didn't have permission to see cost, then set unit price as list price.
                    If upm.CanSeeUnitPrice = True Then
                        For Each r As SAPDALDS.ProductOutRow In ProdOutDt
                            If Decimal.TryParse(r.UNIT_PRICE, 0) Then
                                UnitPrice += Decimal.Parse(r.UNIT_PRICE)
                            End If
                        Next
                    Else
                        UnitPrice = ListPrice
                    End If
                End If
            End If
        End If
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub CalculateTotalPrice(ListPrices As String, UnitPrices As String)
        Context.Response.Clear()
        Dim listprice As Decimal = 0D
        Dim unitprice As Decimal = 0D
        Dim CurrencySign As String = String.Empty
        If Context.User.Identity.IsAuthenticated = True Then
            Try
                CurrencySign = HttpContext.Current.Session("company_currency_sign")
                listprice = CBOMV2_ConfiguratorDAL.CalculatePrice(ListPrices)
            Catch ex As Exception

            End Try
            Try
                unitprice = CBOMV2_ConfiguratorDAL.CalculatePrice(UnitPrices)
            Catch ex As Exception

            End Try
        End If

        Dim priceFormat As String = "{0:n}"
        If CurrencySign.ToUpper() = "NT" Then priceFormat = "{0:n0}"

        Context.Response.Write(JsonConvert.SerializeObject(New With {.listprice = String.Format(priceFormat, listprice), .unitprice = String.Format(priceFormat, unitprice)}))
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub Add2CartForSRP(SelectedItems As String, LanguagePack As String)
        Context.Response.Clear()

        Dim ERPID As String = Session("company_id").ToString().ToUpper()
        Dim ORGID As String = Session("org_id").ToString
        Dim CARTID As String = Session("CART_ID").ToString
        Dim CURRENCY As String = Session("Company_currency").ToString

        Dim updateresult = New Advantech.Myadvantech.DataAccess.UpdateDBResult

        'ICC 2017/01/16 Exclude checking language pack. 
        If String.IsNullOrWhiteSpace(SelectedItems) Then
            updateresult.IsUpdated = False
            updateresult.ServerMessage = "Input is empty."
            Context.Response.Write(JsonConvert.SerializeObject(updateresult))
        Else
            Context.Response.Write(JsonConvert.SerializeObject(CBOMV2_ConfiguratorDAL.ConfiguratorSRP2Cart(SelectedItems, ERPID, CARTID, CURRENCY, ORGID, LanguagePack)))
        End If

        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub CheckCompatibility(ByVal PartNo As String, ByVal SelectedItem As String)
        If Not String.IsNullOrWhiteSpace(PartNo) AndAlso Not String.IsNullOrWhiteSpace(SelectedItem) Then
            'Prepare selected list
            Dim list As List(Of String) = New List(Of String)()
            For Each item As String In SelectedItem.Split(",")
                For Each i As String In item.Split("|")
                    list.Add(i.Trim())
                Next
            Next
            'Get/Set Cache
            Dim pcList As List(Of Advantech.Myadvantech.DataAccess.PRODUCT_COMPATIBILITY) = Context.Cache("PRODUCT_COMPATIBILITY")
            If pcList Is Nothing Then
                pcList = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetProductCompatibility(Compatibility.Incompatible)
                Context.Cache.Add("PRODUCT_COMPATIBILITY", pcList, Nothing, Now.AddMinutes(30), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
            End If
            'Check compatibility
            Dim result As Tuple(Of Boolean, String) = CBOMV2_ConfiguratorDAL.CheckCompatibility(PartNo.Trim(), list, pcList)
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = result.Item1, Key .Message = IIf(result.Item1, String.Format("This part - {0} is {1} with {2}.", PartNo, Compatibility.Incompatible.ToString().ToLower(), result.Item2), String.Empty)}))
        Else
            Context.Response.Write(Newtonsoft.Json.JsonConvert.SerializeObject(New With {Key .Result = False, Key .Message = String.Empty}))
        End If
        Context.Response.End()
    End Sub

    <WebMethod(EnableSession:=True)> _
    <ScriptMethod(ResponseFormat:=ResponseFormat.Json, UseHttpGet:=True, XmlSerializeString:=False)> _
    Public Sub AddProject2Cart(ByVal PartNo As String)

        If Not String.IsNullOrEmpty(PartNo) Then
            Dim ERPID As String = Session("company_id").ToString().ToUpper()
            Dim ORGID As String = Session("org_id").ToString
            Dim CARTID As String = Session("CART_ID").ToString
            Dim CURRENCY As String = Session("Company_currency").ToString
            MyCartX.DeleteCartAllItem(CARTID)
            Dim HigherLevel As Integer = MyCartX.getBtosParentLineNo(CARTID)
            Dim result As Advantech.Myadvantech.DataAccess.UpdateDBResult = Advantech.Myadvantech.DataAccess.DataCore.CBOMV2_ConfiguratorDAL.AddProject2Cart(PartNo, ERPID, CARTID, CURRENCY, ORGID)
            If result.IsUpdated = True Then

                Dim cartlist As List(Of CartItem) = MyCartX.GetCartList(CARTID)
                Dim _EWlist As List(Of EWPartNo) = MyCartX.GetExtendedWarranty()
                Dim EWFlag As Integer = 0

                For Each c As CartItem In cartlist
                    For Each _ew As EWPartNo In _EWlist
                        If String.Equals(_ew.EW_PartNO, c.Part_No) Then
                            EWFlag = _ew.ID
                        End If
                    Next
                Next

                If EWFlag > 0 Then
                    Dim _cartBtosParentitem As CartItem = MyCartX.GetCartItem(CARTID, HigherLevel)
                    _cartBtosParentitem.Ew_Flag = EWFlag
                    MyCartX.addExtendedWarrantyV2(_cartBtosParentitem, EWFlag)
                End If
            End If

            Context.Response.Write(JsonConvert.SerializeObject(result))
        Else
            Dim result As New Advantech.Myadvantech.DataAccess.UpdateDBResult()
            result.IsUpdated = False
            result.ServerMessage = "Part No error"
            Context.Response.Write(JsonConvert.SerializeObject(result))
        End If
        Context.Response.End()
        'Dim bomDT As DataTable = Advantech.Myadvantech.DataAccess.DataCore.CBOMV2_ConfiguratorDAL.ExpandBOM(PartNo, "TWH1")
        'If Not bomDT Is Nothing AndAlso bomDT.Rows.Count > 0 Then
        '    Dim custDT As DataTable = OracleProvider.GetDataTable("SAP_PRD", String.Format("select distinct mast.matnr as Parent_item, stpo.idnrk as child_item, stpo.potx1 as memo from saprdp.mast inner join saprdp.stas  on stas.stlal = mast.stlal AND stas.stlnr = mast.stlnr INNER JOIN saprdp.stpo on stpo.stlkn = stas.stlkn AND stpo.stlnr = stas.stlnr AND stpo.stlty = stas.stlty where stas.LKENZ<>'X' and mast.matnr='{0}'", PartNo))
        '    Dim excludeList As New List(Of String)
        '    For Each dr As DataRow In custDT.Rows
        '        Dim custPN As String = dr("child_item").ToString().Trim()
        '        custPN = Global_Inc.RemoveZeroString(custPN)
        '        If (custPN.IndexOf("耗材") > -1 Or custPN.IndexOf("客供") > -1) AndAlso Not excludeList.Contains(custPN) Then
        '            excludeList.Add(custPN)
        '        End If
        '    Next
        '    Dim partNos As New List(Of String)
        '    For Each dr As DataRow In bomDT.Rows
        '        Dim pn As String = dr("IDNRK").ToString().Trim()
        '        pn = Global_Inc.RemoveZeroString(pn)
        '        If Not excludeList.Contains(pn) Then
        '            partNos.Add(pn)
        '        End If
        '    Next
        'Else

        'End If
        'Dim result As Advantech.Myadvantech.DataAccess.UpdateDBResult = Advantech.Myadvantech.DataAccess.DataCore.CBOMV2_ConfiguratorDAL.AddProject2Cart(ID, ERPID, CARTID, CURRENCY, ORGID)

    End Sub
End Class