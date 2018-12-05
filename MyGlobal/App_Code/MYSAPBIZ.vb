Imports Microsoft.VisualBasic
Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports Advantech.Myadvantech.DataAccess
Imports Advantech.Myadvantech.Business
Imports System.Globalization
Imports System.Linq

Public Class MYSAPBIZ

    '20150722 TC: An order simulation function for getting both item out table and pricing conditions
    Public Class ItemOutAndPriceCondition
        Public Property ItemOut As List(Of BAPI_SALESORDER_SIMULATE.BAPIITEMEX) : Public Property Conditions As List(Of BAPI_SALESORDER_SIMULATE.BAPICOND)
        Public Sub New()
            ItemOut = New List(Of BAPI_SALESORDER_SIMULATE.BAPIITEMEX) : Conditions = New List(Of BAPI_SALESORDER_SIMULATE.BAPICOND)
        End Sub
        Public Sub New(ItemOut As BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable, Conditions As BAPI_SALESORDER_SIMULATE.BAPICONDTable)
            Me.ItemOut = New List(Of BAPI_SALESORDER_SIMULATE.BAPIITEMEX) : Me.Conditions = New List(Of BAPI_SALESORDER_SIMULATE.BAPICOND)
            For Each itemOutRec As BAPI_SALESORDER_SIMULATE.BAPIITEMEX In ItemOut
                Me.ItemOut.Add(itemOutRec)
            Next
            For Each condRec As BAPI_SALESORDER_SIMULATE.BAPICOND In Conditions
                Me.Conditions.Add(condRec)
            Next
        End Sub
    End Class

    Public Shared Function OrderSimulation(SoldToId As String, Org As String, DistChann As String, Division As String, PartNo As String) As ItemOutAndPriceCondition

        Dim result As Object
        Dim RootBTOItem As String = ""
        Dim cmd As New SqlClient.SqlCommand( _
            " select top 1 a.PART_NO from MyAdvantechGlobal.dbo.SAP_PRODUCT a (nolock) inner join MyAdvantechGlobal.dbo.SAP_PRODUCT_STATUS b (nolock) on a.PART_NO=b.PART_NO " + _
            " where a.MATERIAL_GROUP='BTOS' and b.PRODUCT_STATUS='A' and b.SALES_ORG=@ORG and a.PART_NO like 'IPC-%-BTO' ", _
            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("ORG", Org)
        'ICC 2017/3/3 Fixed null error after SQL execution.
        cmd.Connection.Open()
        result = cmd.ExecuteScalar()
        If Not result Is Nothing Then
            RootBTOItem = result.ToString()
        Else
            Return New ItemOutAndPriceCondition(New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable, New BAPI_SALESORDER_SIMULATE.BAPICONDTable)
        End If
        'RootBTOItem = cmd.ExecuteScalar().ToString()
        cmd.Connection.Close()

        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        With OrderHeader
            .Doc_Type = "ZOR" : .Sales_Org = Org : .Distr_Chan = DistChann
            .Division = Division : .Sales_Grp = "" : .Sales_Off = ""
        End With
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = SoldToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)

        Dim rootItem As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
        rootItem.Itm_Number = "100" : rootItem.Material = RootBTOItem : rootItem.Req_Qty = 1 : ItemsIn.Add(rootItem)
        Dim LineNo As Integer = 101, NewItem As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
        With NewItem
            .Itm_Number = LineNo.ToString() : .Material = Util.FormatToSAPPartNo(Trim(PartNo).ToUpper()) : .Req_Qty = 1 : .Hg_Lv_Item = "100"
        End With
        ItemsIn.Add(NewItem) : LineNo += 1
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE
        proxy1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        proxy1.Connection.Open()
        Try
            proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                           New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                           New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                           New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                           New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                           New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                           New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                           ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                           New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
        Catch ex As Exception
            proxy1.Connection.Close()
            Throw ex
        End Try

        proxy1.Connection.Close()
        Return New ItemOutAndPriceCondition(ItemsOut, Conditions)

    End Function

    Public Shared Function UpdateSOVersion(ByVal _SONO As String, ByVal _Version As String, ByVal _isTesting As Boolean, ByRef ReturnTable As DataTable) As Boolean
        Dim p1 As New Change_SD_Order.Change_SD_Order()
        Dim conn As String = ConfigurationManager.AppSettings("SAP_PRD")
        If _isTesting = True Then conn = ConfigurationManager.AppSettings("SAPConnTest")
        p1.Connection = New SAP.Connector.SAPConnection(conn)
        Dim OrderHeader As New Change_SD_Order.BAPISDH1, OrderHeaderX As New Change_SD_Order.BAPISDH1X
        Dim ItemIn As New Change_SD_Order.BAPISDITMTable, ItemInX As New Change_SD_Order.BAPISDITMXTable
        Dim PartNr As New Change_SD_Order.BAPIPARNRTable
        Dim Condition As New Change_SD_Order.BAPICONDTable, ScheLine As New Change_SD_Order.BAPISCHDLTable
        Dim ScheLineX As New Change_SD_Order.BAPISCHDLXTable, OrderText As New Change_SD_Order.BAPISDTEXTTable
        Dim sales_note As New Change_SD_Order.BAPISDTEXT, ext_note As New Change_SD_Order.BAPISDTEXT
        Dim op_note As New Change_SD_Order.BAPISDTEXT, retTable As New Change_SD_Order.BAPIRET2Table
        Dim ADDRTable As New Change_SD_Order.BAPIADDR1Table, PartnerChangeTable As New Change_SD_Order.BAPIPARNRCTable
        Dim Doc_Number As String = _SONO
        OrderHeader.Version = _Version
        OrderHeaderX.Version = "X"
        OrderHeaderX.Updateflag = "U"
        p1.Connection.Open()
        p1.Bapi_Salesorder_Change("", "", New Change_SD_Order.BAPISDLS, OrderHeader, OrderHeaderX, Doc_Number, "", Condition,
            New Change_SD_Order.BAPICONDXTable, New Change_SD_Order.BAPIPAREXTable, New Change_SD_Order.BAPICUBLBTable,
            New Change_SD_Order.BAPICUINSTable, New Change_SD_Order.BAPICUPRTTable, New Change_SD_Order.BAPICUCFGTable,
            New Change_SD_Order.BAPICUREFTable, New Change_SD_Order.BAPICUVALTable, New Change_SD_Order.BAPICUVKTable, ItemIn,
            New Change_SD_Order.BAPISDITMXTable, New Change_SD_Order.BAPISDKEYTable, OrderText, ADDRTable,
            PartnerChangeTable, PartNr, retTable, ScheLine, ScheLineX)
        p1.CommitWork()
        p1.Connection.Close()
        ReturnTable = retTable.ToADODataTable()
        For Each RetRow As DataRow In ReturnTable.Rows
            If RetRow.Item("Type").ToString().Equals("E") Then Return False
        Next
        Return True
    End Function

    Public Shared Function UpdateSOSpecId(ByVal SO_NO As String, ByVal SpecialIndicator As EnumSetting.EarlyShipmentSetting, ByRef ReturnTable As DataTable) As Boolean
        Dim strSpecialIndicator As String = "000" + CInt(SpecialIndicator).ToString()
        Dim p1 As New Change_SD_Order.Change_SD_Order()
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim OrderHeader As New Change_SD_Order.BAPISDH1, OrderHeaderX As New Change_SD_Order.BAPISDH1X
        Dim ItemIn As New Change_SD_Order.BAPISDITMTable, ItemInX As New Change_SD_Order.BAPISDITMXTable
        Dim PartNr As New Change_SD_Order.BAPIPARNRTable
        Dim Condition As New Change_SD_Order.BAPICONDTable, ScheLine As New Change_SD_Order.BAPISCHDLTable
        Dim ScheLineX As New Change_SD_Order.BAPISCHDLXTable, OrderText As New Change_SD_Order.BAPISDTEXTTable
        Dim sales_note As New Change_SD_Order.BAPISDTEXT, ext_note As New Change_SD_Order.BAPISDTEXT
        Dim op_note As New Change_SD_Order.BAPISDTEXT, retTable As New Change_SD_Order.BAPIRET2Table
        Dim ADDRTable As New Change_SD_Order.BAPIADDR1Table, PartnerChangeTable As New Change_SD_Order.BAPIPARNRCTable
        Dim Doc_Number As String = SO_NO
        OrderHeader.S_Proc_Ind = strSpecialIndicator
        OrderHeaderX.S_Proc_Ind = "X"
        OrderHeaderX.Updateflag = "U"
        p1.Connection.Open()
        p1.Bapi_Salesorder_Change("", "", New Change_SD_Order.BAPISDLS, OrderHeader, OrderHeaderX, Doc_Number, "", Condition, _
            New Change_SD_Order.BAPICONDXTable, New Change_SD_Order.BAPIPAREXTable, New Change_SD_Order.BAPICUBLBTable, _
            New Change_SD_Order.BAPICUINSTable, New Change_SD_Order.BAPICUPRTTable, New Change_SD_Order.BAPICUCFGTable, _
            New Change_SD_Order.BAPICUREFTable, New Change_SD_Order.BAPICUVALTable, New Change_SD_Order.BAPICUVKTable, ItemIn, _
            New Change_SD_Order.BAPISDITMXTable, New Change_SD_Order.BAPISDKEYTable, OrderText, ADDRTable, _
            PartnerChangeTable, PartNr, retTable, ScheLine, ScheLineX)
        p1.CommitWork()
        p1.Connection.Close()
        ReturnTable = retTable.ToADODataTable()
        For Each RetRow As DataRow In ReturnTable.Rows
            If RetRow.Item("Type").ToString().Equals("E") Then Return False
        Next
        Return True
    End Function

    Public Shared Function UpdateSOZeroPriceItems(ByVal SO_NO As String, ByRef ReturnTable As DataTable) As Boolean
        Dim aptOrderDetail As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
        Dim dtOrderDetail As MyOrderDS.ORDER_DETAILDataTable = aptOrderDetail.GetOrderDetailByOrderID(SO_NO)
        If dtOrderDetail.Count = 0 Then
            Return False
        End If
        Dim p1 As New Change_SD_Order.Change_SD_Order()
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim OrderHeader As New Change_SD_Order.BAPISDH1, OrderHeaderX As New Change_SD_Order.BAPISDH1X
        Dim ItemIn As New Change_SD_Order.BAPISDITMTable, ItemInX As New Change_SD_Order.BAPISDITMXTable
        Dim PartNr As New Change_SD_Order.BAPIPARNRTable
        Dim Condition As New Change_SD_Order.BAPICONDTable, ScheLine As New Change_SD_Order.BAPISCHDLTable
        Dim ScheLineX As New Change_SD_Order.BAPISCHDLXTable, OrderText As New Change_SD_Order.BAPISDTEXTTable
        Dim sales_note As New Change_SD_Order.BAPISDTEXT, ext_note As New Change_SD_Order.BAPISDTEXT
        Dim op_note As New Change_SD_Order.BAPISDTEXT, retTable As New Change_SD_Order.BAPIRET2Table
        Dim ADDRTable As New Change_SD_Order.BAPIADDR1Table, PartnerChangeTable As New Change_SD_Order.BAPIPARNRCTable
        Dim Doc_Number As String = SO_NO
        OrderHeaderX.Updateflag = "U"

        For Each OrderDetailRow As MyOrderDS.ORDER_DETAILRow In dtOrderDetail
            If OrderDetailRow.UNIT_PRICE = 0 AndAlso Not OrderDetailRow.PART_NO.EndsWith("-BTO") AndAlso Not OrderDetailRow.PART_NO.StartsWith("C-CTOS") Then
                Dim ItemInRow As New Change_SD_Order.BAPISDITM, ItemInRowX As New Change_SD_Order.BAPISDITMX
                With ItemInRow
                    .Itm_Number = OrderDetailRow.LINE_NO
                    .Material = Global_Inc.Format2SAPItem(OrderDetailRow.PART_NO)
                    .Item_Categ = "ZTN3"
                End With
                With ItemInRowX
                    .Itm_Number = OrderDetailRow.LINE_NO
                    .Item_Categ = "U"
                End With

                ItemIn.Add(ItemInRow) : ItemInX.Add(ItemInRowX)
            End If
        Next
        If ItemIn.Count > 0 Then
            p1.Connection.Open()
            p1.Bapi_Salesorder_Change("", "", New Change_SD_Order.BAPISDLS, OrderHeader, OrderHeaderX, Doc_Number, "", Condition, _
                New Change_SD_Order.BAPICONDXTable, New Change_SD_Order.BAPIPAREXTable, New Change_SD_Order.BAPICUBLBTable, _
                New Change_SD_Order.BAPICUINSTable, New Change_SD_Order.BAPICUPRTTable, New Change_SD_Order.BAPICUCFGTable, _
                New Change_SD_Order.BAPICUREFTable, New Change_SD_Order.BAPICUVALTable, New Change_SD_Order.BAPICUVKTable, ItemIn, _
                New Change_SD_Order.BAPISDITMXTable, New Change_SD_Order.BAPISDKEYTable, OrderText, ADDRTable, _
                PartnerChangeTable, PartNr, retTable, ScheLine, ScheLineX)
            p1.CommitWork()
            p1.Connection.Close()

            ReturnTable = retTable.ToADODataTable()
            For Each RetRow As DataRow In ReturnTable.Rows
                If RetRow.Item("Type").ToString().Equals("E") Then Return False
            Next
        End If

        Return True

    End Function

    Public Shared Function UpdateSAPSOShipToAttentionAddress( _
        ByVal SONO As String, ByVal ShipToId As String, ByVal Name As String, ByVal Attention As String, ByVal Street As String, ByVal Street2 As String, ByVal City As String, ByVal State As String, ByVal Zipcode As String, _
        ByVal Country As String, ByVal TaxJuri As String, ByRef ReturnTable As DataTable, Optional ByVal IsSAPProductionServer As Boolean = True) As Boolean
        Dim retbool As Boolean = False
        Dim dtDefaultAddrTable As SAPDAL.SalesOrder.PartnerAddressesDataTable = SAPDAL.SAPDAL.GetSAPPartnerAddressesTableByKunnr(ShipToId, IsSAPProductionServer)
        If dtDefaultAddrTable.Count > 0 Then
            Dim dtDefaultAddrRow = dtDefaultAddrTable(0)
            Dim p1 As New Change_SD_Order.Change_SD_Order()
            If IsSAPProductionServer Then
                p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            Else
                p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAPConnTest"))
            End If
            Dim OrderHeader As New Change_SD_Order.BAPISDH1, OrderHeaderX As New Change_SD_Order.BAPISDH1X
            Dim ItemIn As New Change_SD_Order.BAPISDITMTable, PartNr As New Change_SD_Order.BAPIPARNRTable
            Dim Condition As New Change_SD_Order.BAPICONDTable, ScheLine As New Change_SD_Order.BAPISCHDLTable
            Dim ScheLineX As New Change_SD_Order.BAPISCHDLXTable, OrderText As New Change_SD_Order.BAPISDTEXTTable
            Dim sales_note As New Change_SD_Order.BAPISDTEXT, ext_note As New Change_SD_Order.BAPISDTEXT
            Dim op_note As New Change_SD_Order.BAPISDTEXT, retTable As New Change_SD_Order.BAPIRET2Table
            Dim ADDRTable As New Change_SD_Order.BAPIADDR1Table, PartnerChangeTable As New Change_SD_Order.BAPIPARNRCTable
            Dim Doc_Number As String = SONO
            OrderHeaderX.Updateflag = "U"

            Dim ADDRRow1 As New Change_SD_Order.BAPIADDR1, PartnerChangeRow1 As New Change_SD_Order.BAPIPARNRC
            With ADDRRow1
                .Name = dtDefaultAddrRow.Name
                If Not String.IsNullOrEmpty(Name) Then
                    .Name = Name
                End If
                .Addr_No = "1" : .C_O_Name = Attention
                If String.IsNullOrEmpty(City) Then
                    .City = dtDefaultAddrRow.City
                Else
                    .City = City
                End If
                If String.IsNullOrEmpty(Country) Then
                    .Country = dtDefaultAddrRow.Country
                Else
                    .Country = Country
                End If
                If String.IsNullOrEmpty(Zipcode) Then
                    .Postl_Cod1 = dtDefaultAddrRow.Postl_Cod1
                Else
                    .Postl_Cod1 = Zipcode
                End If
                If String.IsNullOrEmpty(Street) Then
                    .Street = dtDefaultAddrRow.Street
                Else
                    .Street = Street
                End If
                If String.IsNullOrEmpty(Street2) Then
                    .Str_Suppl3 = dtDefaultAddrRow.Str_Suppl3
                Else
                    .Str_Suppl3 = Street2
                End If
                If String.IsNullOrEmpty(State) Then
                    .Region = dtDefaultAddrRow.Region_str
                Else
                    .Region = State
                End If
                If String.IsNullOrEmpty(TaxJuri) Then
                    .Taxjurcode = dtDefaultAddrRow.Taxjurcode
                Else
                    .Taxjurcode = TaxJuri
                End If
                .Comm_Type = dtDefaultAddrRow.Comm_Type : .Distrct_No = dtDefaultAddrRow.Distrct_No : .District = dtDefaultAddrRow.District
                .Dont_Use_P = dtDefaultAddrRow.Dont_Use_P : .Dont_Use_S = dtDefaultAddrRow.Dont_Use_S : .E_Mail = dtDefaultAddrRow.E_Mail
                .Fax_Extens = dtDefaultAddrRow.Fax_Extens : .Fax_Number = dtDefaultAddrRow.Fax_Number : .Floor = dtDefaultAddrRow.Floor
                .Langu = dtDefaultAddrRow.Langu : .Location = dtDefaultAddrRow.Location : .Name_2 = dtDefaultAddrRow.Name_2
                .Name_3 = dtDefaultAddrRow.Name_3 : .Name_4 = dtDefaultAddrRow.Name_4 : .Pboxcit_No = dtDefaultAddrRow.Pboxcit_No : .Pcode1_Ext = dtDefaultAddrRow.Pcode1_Ext
                .Pcode2_Ext = dtDefaultAddrRow.Pcode2_Ext : .Pcode3_Ext = dtDefaultAddrRow.Pcode3_Ext : .Po_Box = dtDefaultAddrRow.Po_Box
                .Po_Box_Cit = dtDefaultAddrRow.Po_Box_Cit : .Po_Box_Reg = dtDefaultAddrRow.Po_Box_Reg : .Pobox_Ctry = dtDefaultAddrRow.Pobox_Ctry
                .Postl_Cod2 = dtDefaultAddrRow.Postl_Cod2 : .Postl_Cod3 = dtDefaultAddrRow.Postl_Cod3 : .Regiogroup = dtDefaultAddrRow.Regiogroup
                .Tel1_Ext = dtDefaultAddrRow.Tel1_Ext : .Tel1_Numbr = dtDefaultAddrRow.Tel1_Numbr
                .Time_Zone = dtDefaultAddrRow.Time_Zone : .Title = dtDefaultAddrRow.Title : .Transpzone = dtDefaultAddrRow.Transpzone
            End With
            With PartnerChangeRow1
                .Document = Doc_Number : .Addr_Link = "1" : .Address = "" : .P_Numb_New = ShipToId : .P_Numb_Old = ShipToId : .Partn_Role = "WE" : .Updateflag = "U"
            End With

            ADDRTable.Add(ADDRRow1) : PartnerChangeTable.Add(PartnerChangeRow1)
            Try
                p1.Connection.Open()
                p1.Bapi_Salesorder_Change("", "", New Change_SD_Order.BAPISDLS, OrderHeader, OrderHeaderX, Doc_Number, "", Condition, _
                    New Change_SD_Order.BAPICONDXTable, New Change_SD_Order.BAPIPAREXTable, New Change_SD_Order.BAPICUBLBTable, _
                    New Change_SD_Order.BAPICUINSTable, New Change_SD_Order.BAPICUPRTTable, New Change_SD_Order.BAPICUCFGTable, _
                    New Change_SD_Order.BAPICUREFTable, New Change_SD_Order.BAPICUVALTable, New Change_SD_Order.BAPICUVKTable, ItemIn, _
                    New Change_SD_Order.BAPISDITMXTable, New Change_SD_Order.BAPISDKEYTable, OrderText, ADDRTable, _
                    PartnerChangeTable, PartNr, retTable, ScheLine, ScheLineX)
                p1.CommitWork() : p1.Connection.Close()
                retbool = True
            Catch ex As Exception
            End Try
            ReturnTable = retTable.ToADODataTable()
            Return retbool
        End If
    End Function

    Public Shared Function VerifyDistChannelDivisionGroupOffice(ByVal Org As String, ByVal SoldToId As String, ByVal ShipToId As String, ByVal strDistChann As String, _
                                       ByVal strDivision As String, ByVal OrderDocType As SAPDAL.SAPDAL.SAPOrderType, ByVal SalesGroup As String, ByVal SalesOffice As String, ByRef ReturnTable As DataTable) As Boolean
        If String.IsNullOrEmpty(ShipToId) Then ShipToId = SoldToId
        SoldToId = Trim(UCase(SoldToId)) : ShipToId = Trim(UCase(ShipToId))
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        With OrderHeader
            .Doc_Type = OrderDocType.ToString() : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann
            .Division = strDivision : .Sales_Grp = SalesGroup : .Sales_Off = SalesOffice
        End With
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = SoldToId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = ShipToId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)

        Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
        item.Itm_Number = "1" : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org) : item.Req_Qty = 1 : ItemsIn.Add(item)
        proxy1.Connection.Open()
        proxy1.Bapi_Salesorder_Simulate("", OrderHeader, New BAPI_SALESORDER_SIMULATE.BAPIPAYER, New BAPI_SALESORDER_SIMULATE.BAPIRETURN, "", _
                                            New BAPI_SALESORDER_SIMULATE.BAPISHIPTO, New BAPI_SALESORDER_SIMULATE.BAPISOLDTO, _
                                            New BAPI_SALESORDER_SIMULATE.BAPIPAREXTable, retDt, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICCARDTable, New BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUBLBTable, New BAPI_SALESORDER_SIMULATE.BAPICUINSTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUPRTTable, New BAPI_SALESORDER_SIMULATE.BAPICUCFGTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPICUVALTable, Conditions, New BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable, _
                                            ItemsIn, ItemsOut, Partners, New BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable, _
                                            New BAPI_SALESORDER_SIMULATE.BAPISCHDLTable, New BAPI_SALESORDER_SIMULATE.BAPIADDR1Table)
        proxy1.Connection.Close()
        ReturnTable = retDt.ToADODataTable()
        For Each retMsgRec As DataRow In ReturnTable.Rows
            If retMsgRec.Item("Type") = "E" Then
                Return False
            End If
        Next
        Return True
    End Function


    Shared Function is_Valid_Company_Id_All(ByVal company_id As String) As Boolean
        Dim str As String = String.Format("select top 1 COMPANY_ID from SAP_DIMCOMPANY where COMPANY_ID='{0}'", company_id)
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("RFM", str)
        If dt.Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function

    Public Shared Function RBU2Org(ByVal RBU As String, ByVal SAPOrg As String) As String
        RBU = UCase(RBU) : SAPOrg = UCase(SAPOrg)
        Dim ShowOrg As String = "EU10"
        Select Case RBU
            Case "ADL", "AFR", "AIT", "AEE", "ABN", "AUK", "DLOG", "AINNOCORE", "AEU", "AMEA-MEDICAL", "ABBEU"
                ShowOrg = "EU10"
            Case "ARU"
                ShowOrg = SAPOrg
                'Case "ATW", "AIN", "ASG", "AMY", "AID", "SAP", "AKR", "HQDC", "ATH", "LATAM", "ACL"
            Case "ATW", "AIN", "ASG", "AMY", "AID", "SAP", "HQDC", "ATH", "LATAM", "ACL"
                ShowOrg = "TW01"
            Case "AENC", "AACIAG", "ANADMF", "ANA", "AAC", "AMX", "ALA"
                ShowOrg = "US01"
            Case "ABJ", "ACN", "ASH", "ASZ", "ACN-S", "AHK", "ACN-N", "ACN-E"
                ShowOrg = "CN01"
            Case "AAU"
                ShowOrg = "AU01"
            Case "AJP"
                '20150331 TC: Per AJP Jack.Tsao's request, let AJP see ACL's CBOM directly
                ShowOrg = "TW01"
            Case "AKR"
                '20150331 TC: Per AJP Jack.Tsao's request, let AJP see ACL's CBOM directly
                ShowOrg = "KR01"
            Case "ABR"
                'Ryan 20160711 ABR's showorg will be independent and no longer belongs to US01
                ShowOrg = "BR01"
            Case "ABB"
                'Ryan 20160711 ABB's showorg will depend on its SAPORG
                If SAPOrg.ToString.StartsWith("TW") Then
                    ShowOrg = "TW01"
                ElseIf SAPOrg.ToString.StartsWith("US") Then
                    ShowOrg = "US01"
                ElseIf SAPOrg.ToString.StartsWith("EU") Then
                    ShowOrg = "EU10"
                Else
                    ShowOrg = "TW01"
                End If
        End Select

        'Ryan 20171107 Set showorg = TW01 for ALL TW ORG
        If SAPOrg.ToString.ToUpper.StartsWith("TW") Then
            ShowOrg = "TW01"
        End If

        Return ShowOrg
    End Function

    Shared Function is_Valid_Company_Id(ByVal company_id As String) As Boolean
        Dim str As String = String.Format("select COMPANY_ID from SAP_DIMCOMPANY where COMPANY_ID='{0}' and COMPANY_Type='Z001'", company_id)
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("MY", str)
        If dt.Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function

    Public Shared Function isCustomerCompleteDeliv(ByVal CompanyId As String, ByVal OrgId As String) As Boolean
        CompanyId = UCase(CompanyId) : OrgId = UCase(OrgId)
        Dim str As String = String.Format("select KUNNR from sapRDP.KNVV WHERE KUNNR='{0}' AND MANDT='168' and vkorg='{1}' and KZTLF='C'", CompanyId, OrgId)
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", str)
        If dt.Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function
    Shared Function GetCTOSAssemblyInstructionListByERPIdFromMyadvantech(ByVal _ERPID As String) As String
        Dim strSql As String = _
            " SELECT top 1 b.FILEP" + _
            " FROM SAP_CTOS_DOC a inner join SAP_CTOS_DOC_URL b on a.DOKNR=b.DOKNR and a.DOKVR=b.DOKVR" + _
            " WHERE 1=1 "
        If Not String.IsNullOrEmpty(_ERPID) Then strSql += " and a.DOKNR LIKE '" + _ERPID + "%'"
        'If Not String.IsNullOrEmpty(DocTxt) Then strSql += " and a.DKTXT LIKE N'%" + Replace(Replace(DocTxt, "'", "''"), "*", "%") + "%'"
        strSql += " AND a.DOKVR<>'00' Order by a.DOKNR,a.DOKVR desc"
        Dim O As Object = dbUtil.dbExecuteScalar("MY", strSql)
        If Not IsNothing(O) Then
            Return O.ToString.Trim
        End If
        Return ""
    End Function
    Public Shared Function getOrderNoteBySHTCProduct() As String
        Dim SHTCStr As String = ""
        'Dim str As String = String.Format("select distinct part_no from cart_detail where cart_id='{0}'", HttpContext.Current.Session("cart_id"))
        Dim str As String = String.Format("select distinct part_no,Description from cart_detail_V2 where cart_id='{0}'", HttpContext.Current.Session("cart_id"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", str)

        Dim str1 As String = ""

        If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
            Dim N As String = 0
            For Each arc As DataRow In dt.Rows
                str1 &= String.Format("select MATNR,PRAT6,PRAT9,PRATA from SAPRDP.MVKE WHERE MATNR = '{0}' AND VKORG='{1}' AND MANDT=168", SAPDAL.Global_Inc.Format2SAPItem(arc.Item("Part_No")).ToUpper, HttpContext.Current.Session("org_id"))
                If N < dt.Rows.Count - 1 Then
                    str1 &= " union "
                End If
                N = N + 1
            Next
        End If

        If str1.Trim <> "" Then
            Dim dto As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", str1)
            If Not IsNothing(dto) AndAlso dto.Rows.Count > 0 Then
                For Each r As DataRow In dt.Rows
                    If dto.Select("MATNR='" & SAPDAL.Global_Inc.Format2SAPItem(r.Item("Part_No")).ToUpper & "' and PRAT6='X'").Length > 0 Then
                        SHTCStr &= r.Item("Part_No").ToString & " (SHTC)"
                        SHTCStr &= vbNewLine
                    End If
                    If dto.Select("MATNR='" & SAPDAL.Global_Inc.Format2SAPItem(r.Item("Part_No")).ToUpper & "' and PRAT9='X'").Length > 0 Then
                        SHTCStr &= r.Item("Part_No").ToString & " (Battery : Dangerous cargo item, extra shipping cost may/will be charged)"
                        SHTCStr &= vbNewLine
                    End If
                    If dto.Select("MATNR='" & SAPDAL.Global_Inc.Format2SAPItem(r.Item("Part_No")).ToUpper & "' and PRATA='X'").Length > 0 Then
                        SHTCStr &= r.Item("Part_No").ToString & " (S01, Sensitive model ship to Iran and North Korea)"
                        SHTCStr &= vbNewLine
                    End If
                Next
            End If
        End If
        Return SHTCStr
    End Function
    Public Shared Function getSalesNotebyCustomer(ByVal companyID As String) As String
        Try
            Dim TXTObj As Object = dbUtil.dbExecuteScalar("MY",
                                                          String.Format("select top 1 TXT from SAP_COMPANY_SALESNOTE " & _
                                                                        "WHERE (COMPANY_ID = '{0}' or COMPANY_ID LIKE '{0} %') and TXT <> '' and TXT IS NOT NULL order by last_upd_date desc", companyID.Trim))
            If TXTObj IsNot Nothing AndAlso TXTObj.ToString <> "" Then
                Return TXTObj.ToString
            End If
        Catch ex As Exception
        End Try
        Return ""
    End Function

    Public Shared Function CanPlaceOrderOrg(ByVal org As String) As Boolean
        Dim orgs As String() = {"TW", "US", "SG", "JP", "EU", "KR", "MY", "CN"}
        Return orgs.Contains(org)
    End Function
End Class

<WebService(Namespace:="eBizAEU")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class SAPWS
    Inherits System.Web.Services.WebService

    <Services.WebMethod()> _
    Public Function GetOrderDetail(ByVal SONO As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select VBAK.VBELN AS ""Order No."", VBAK.BSTNK AS ""PO No."", "))
            .AppendLine(String.Format(" VBAK.AUDAT AS ""Order Date"", VBAK.WAERK AS Currency, cast(VBAP.POSNR as integer) AS ""Line No."",   "))
            .AppendLine(String.Format(" VBAP.MATNR AS ""Part No"",  "))
            .AppendLine(String.Format(" VBAP.NETPR AS ""Unit Price"",   "))
            .AppendLine(String.Format(" VBAP.NETWR AS ""Total Price"", VBUP.LFSTA AS ""Doc. Status"", VBEP.EDATU AS ""Due Date"",  "))
            .AppendLine(String.Format(" nvl((select SUM(LFIMG) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR),0) as ""Delivered Qty."",   "))
            .AppendLine(String.Format(" (select z.name1 || z.name2 as Company_Name from saprdp.kna1 z where z.kunnr=VBAK.KUNNR and rownum=1) AS ""Company Name"" "))
            .AppendLine(String.Format(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN   "))
            .AppendLine(String.Format(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN   "))
            .AppendLine(String.Format(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR   "))
            .AppendLine(String.Format(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND (VBUP.MANDT = '168')  AND VBAP.ABGRU = ' '  "))
            .AppendLine(String.Format(" and VBAK.VBELN='{0}' ", Global_Inc.SONoBuildSAPFormat(SONO)))
            .AppendLine(String.Format(" order by VBAP.POSNR "))
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        dt.TableName = "OrderDetail"
        Return dt
    End Function

    <WebMethod()> _
    Public Function GetBackOrder( _
    ByVal kunnr As String, ByVal vkorg As String, _
    ByVal txtPart_NO As String, ByVal txtSO_NO As String, ByVal txtPO_NO As String, _
    ByVal FromDate As String, ByVal ToDate As String, ByVal DueDateFrom As String, ByVal DueDateTo As String) As DataTable
        'Dim kunnr As String = UCase(Session("company_id")), vkorg As String = UCase(Session("org_id"))
        If kunnr = "" Or vkorg = "" Then Return New DataTable("BO")
        Dim matnr As String = Server.HtmlEncode(txtPart_NO.Trim().ToUpper())
        Dim vbeln As String = Server.HtmlEncode(txtSO_NO.Trim().ToUpper())
        Dim bstnk As String = Server.HtmlEncode(txtPO_NO.Trim().ToUpper())
        'Dim FromDate As String = DateAdd(DateInterval.Month, -3, Now).ToString("yyyyMMdd")
        'Dim ToDate As String = Now.ToString("yyyyMMdd")
        Dim tmpFrom As Date = Date.MinValue, tmpTo As Date = Date.MaxValue
        'If Date.TryParseExact(Me.txtOrderDateFrom.Text, "yyyy/MM/dd", New Globalization.CultureInfo("fr-FR"), Globalization.DateTimeStyles.None, tmpFrom) Then
        '    FromDate = tmpFrom.ToString("yyyyMMdd")
        'End If
        'If Date.TryParseExact(Me.txtOrderDateTo.Text, "yyyy/MM/dd", New Globalization.CultureInfo("fr-FR"), Globalization.DateTimeStyles.None, tmpTo) Then
        '    ToDate = tmpTo.ToString("yyyyMMdd")
        'End If
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.BSTNK AS PONO, VBAK.KUNNR as BILLTOID, ")
            .AppendFormat(" (select kunnr from saprdp.vbpa where vbpa.vbeln=vbak.vbeln and vbpa.parvw='WE' and rownum=1) AS SHIPTOID, ")
            .AppendFormat(" VBAK.AUDAT AS ORDERDATE, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS ORDERLINE, ")
            .AppendFormat(" VBAP.MATNR AS ProductId, VBAP.KWMENG AS SchdLineConfirmQty, ")
            .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, VBAP.NETPR AS UNITPRICE, ")
            .AppendFormat(" VBAP.NETWR AS TOTALPRICE, VBUP.LFSTA AS DOC_STATUS, VBEP.EDATU AS DUEDATE, VBEP.EDATU AS OriginalDD, VBAP.ZZ_GUARA AS ExWarranty, ")
            .AppendFormat(" nvl((select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1),0) as SchedLineShipedQty, ")
            .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
            .AppendFormat(" nvl((select SUM(LFIMG) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR),0) as DLV_QTY ")
            .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
            .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
            .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
            .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND (VBUP.MANDT = '168')  AND ")
            .AppendFormat(" (VBAK.VKORG = '{0}') AND (VBAK.KUNNR='{1}') AND ", vkorg, kunnr)
            .AppendFormat(" VBUP.LFSTA IN ('A','B') ")
            If FromDate <> "" And ToDate <> "" Then .AppendFormat(" AND (VBAK.AUDAT between '{0}' and '{1}') ", FromDate, ToDate)
            If DueDateFrom <> "" And DueDateTo <> "" Then .AppendFormat(" AND (VBEP.EDATU between '{0}' and '{1}') ", DueDateFrom, DueDateTo)
            If matnr <> "" Then .AppendFormat(" and VBAP.MATNR like '%{0}%' ", matnr)
            If vbeln <> "" Then .AppendFormat(" and VBAK.VBELN like '%{0}%' ", vbeln)
            If bstnk <> "" Then .AppendFormat(" and VBAK.BSTNK like '%{0}%' ", bstnk)
            .AppendFormat(" and VBAP.ABGRU = ' ' ")
            .AppendFormat(" ORDER BY ORDERLINE asc, DUEDATE desc")
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        'Response.Write(sb.ToString())
        Dim BRs() As DataRow = dt.Select("DOC_STATUS='B'", "OrderNo ASC, ORDERLINE ASC, DUEDATE ASC")

        If BRs.Length > 0 Then
            Dim curSO As String = "", curLine As String = "", curQty As Decimal = 0
            For Each sch As DataRow In BRs
                If sch.Item("OrderNo").ToString() <> curSO Or sch.Item("ORDERLINE").ToString() <> curLine Then
                    curSO = sch.Item("OrderNo").ToString() : curLine = sch.Item("ORDERLINE")
                    curQty = DirectCast(sch.Item("DLV_QTY"), Decimal)
                End If
                If CDbl(sch.Item("SchdLineOpenQty")) > curQty Then
                    sch.Item("SchdLineOpenQty") = sch.Item("SchdLineOpenQty") - curQty
                    curQty = 0
                Else
                    curQty = curQty - CDbl(sch.Item("SchdLineOpenQty"))
                    sch.Delete()
                End If
            Next
        End If
        dt.AcceptChanges()
        BRs = dt.Select("DOC_STATUS='A' and SchedLineShipedQty=0 and SchdLineNo=1")

        For Each sch As DataRow In BRs
            If dt.Select(String.Format("OrderNo='{0}' and ORDERLINE={1} and SchdLineNo>1", sch.Item("OrderNo"), sch.Item("ORDERLINE"))).Length > 0 Then
                sch.Delete()
            End If
        Next
        dt.AcceptChanges()

        sb = New StringBuilder()
        With sb
            .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.BSTNK AS PONO, VBAK.KUNNR as BILLTOID, ")
            .AppendFormat(" (select kunnr from saprdp.vbpa where vbpa.vbeln=vbak.vbeln and vbpa.parvw='WE' and rownum=1) AS SHIPTOID, ")
            .AppendFormat(" VBAK.AUDAT AS ORDERDATE, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS ORDERLINE, ")
            .AppendFormat(" VBAP.MATNR AS ProductId, VBAP.KWMENG AS SchdLineConfirmQty, ")
            .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, VBAP.NETPR AS UNITPRICE, ")
            .AppendFormat(" VBAP.NETWR AS TOTALPRICE, VBUP.LFSTA AS DOC_STATUS, VBEP.EDATU AS DUEDATE, VBEP.EDATU AS OriginalDD, VBAP.ZZ_GUARA AS ExWarranty, ")
            .AppendFormat(" (select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1) as SchedLineShipedQty, ")
            .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
            .AppendFormat(" nvl((select count(*) as n from SAPRDP.VBRP where VBRP.AUBEL = VBAK.VBELN and VBRP.AUPOS=VBAP.POSNR),0) as DLV_QTY ")
            .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
            .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
            .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
            .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND (VBUP.MANDT = '168')  AND ")
            .AppendFormat(" (VBAK.VKORG = '{0}') AND (VBAK.KUNNR='{1}') AND ", vkorg, kunnr)
            .AppendFormat(" VBUP.LFSTA ='C' ", FromDate, ToDate)
            If FromDate <> "" And ToDate <> "" Then .AppendFormat(" AND (VBAK.AUDAT between '{0}' and '{1}') ", FromDate, ToDate)
            If DueDateFrom <> "" And DueDateTo <> "" Then .AppendFormat(" AND (VBEP.EDATU between '{0}' and '{1}') ", DueDateFrom, DueDateTo)
            If matnr <> "" Then .AppendFormat(" and VBAP.MATNR like '%{0}%' ", matnr)
            If vbeln <> "" Then .AppendFormat(" and VBAK.VBELN like '%{0}%' ", vbeln)
            If bstnk <> "" Then .AppendFormat(" and VBAK.BSTNK like '%{0}%' ", bstnk)
            .AppendFormat(" and VBAP.ABGRU = ' ' ")
            .AppendFormat(" ORDER BY ORDERLINE asc, DUEDATE desc")
        End With
        'Response.Write(sb.ToString())
        Dim dt1 As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        For Each r As DataRow In dt1.Rows
            If CInt(r.Item("DLV_QTY")) > 0 Then
                r.Delete()
            End If
        Next
        dt1.AcceptChanges()

        dt.Merge(dt1)

        dt.TableName = "BO" : Return dt
    End Function
    <WebMethod()> _
    Public Function GetForwarder(ByVal txtSO_NO As String) As DataTable
        If txtSO_NO.Trim = "" Then Return New DataTable("Forwarder")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat(" select distinct b.vbeln as INVOICE_NO, ")
            .AppendFormat(" (SELECT VBAK.BSTNK FROM saprdp.vbak WHERE VBAK.VBELN=b.AUBEL AND ROWNUM=1 and VBAK.MANDT='168') as PO_NO, ")
            .AppendFormat(" b.aubel AS SO_NO,")
            .AppendFormat(" (select bolnr from saprdp.likp where vbeln= b.vgbel) as forwarder,")
            .AppendFormat("  a.fkdat AS ship_date ")
            .AppendFormat(" from saprdp.vbrk a inner join saprdp.vbrp b on a.vbeln=b.vbeln ")
            .AppendFormat(" where  a.mandt='168' and b.mandt='168'")
            .AppendFormat(" and b.aubel like '%" & Server.HtmlEncode(txtSO_NO.Trim.ToUpper) & "%'")
            .AppendFormat(" order by a.fkdat desc")
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        dt.TableName = "Forwarder" : Return dt
    End Function
    <WebMethod()> _
    Public Function GetInvoice(ByVal kunnr As String, ByVal vkorg As String, ByVal txtInv_NO As String, _
    ByVal txtPart_NO As String, ByVal txtSO_NO As String, ByVal txtPO_NO As String, ByVal txtDN_NO As String, _
    ByVal FromDate As String, ByVal ToDate As String) As DataTable
        If kunnr = "" Or vkorg = "" Then Return New DataTable("BO")
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat(" select b.vbeln as INVOICE_NO, ")
            .AppendFormat("(SELECT VBAK.BSTNK FROM saprdp.vbak WHERE VBAK.VBELN=b.AUBEL AND ROWNUM=1 and VBAK.MANDT='168') as PO_NO, ")
            .AppendFormat("b.aubel AS SO_NO,")
            .AppendFormat("b.vgbel as DN_NO,")
            .AppendFormat("a.WAERK as CURRENCY,")
            .AppendFormat("(SELECT MARA.PRDHA FROM SAPRDP.MARA WHERE MARA.MATNR=b.matnr AND ROWNUM=1 AND MARA.MANDT='168') as P_GROUP, ")
            .AppendFormat("b.posnr AS LINE_NO, b.matnr AS PART_NO, b.fkimg as INVOICE_QTY, b.kzwi2 As TOTAL_PRICE, a.fkdat AS INVOICE_DATE, '' as UNIT_PRICE ")
            .AppendFormat("from saprdp.vbrk a inner join saprdp.vbrp b on a.vbeln=b.vbeln ")
            .AppendFormat("where a.kunag ='{0}' and a.mandt='168' and b.mandt='168'", kunnr)
            .AppendFormat(" and a.fkdat BETWEEN '{0}' AND '{1}'", Replace(FromDate, "/", ""), Replace(ToDate, "/", ""))

            Dim inv_no As String = "00" & Server.HtmlEncode(txtInv_NO)
            If Server.HtmlEncode(txtInv_NO) <> "" Then
                .AppendFormat(" and  a.vbeln ='{0}'", Server.HtmlEncode(txtInv_NO.ToUpper())) '00" & Me.txtinv_no.Text.Trim & "' "
            End If
            If Server.HtmlEncode(txtSO_NO) <> "" Then
                .AppendFormat(" and b.aubel ='{0}'", Server.HtmlEncode(txtSO_NO.ToUpper()))
            End If
            If Server.HtmlEncode(txtDN_NO) <> "" Then
                .AppendFormat(" and b.vgbel like '%{0}%'", Server.HtmlEncode(txtDN_NO.ToUpper()))
            End If
            If Server.HtmlEncode(txtPart_NO) <> "" Then
                .AppendFormat(" and b.matnr like '%{0}%'", Server.HtmlEncode(txtPart_NO.ToUpper()))
            End If
            .AppendFormat(" and b.matnr not like '0%'")
        End With

        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())

        If Server.HtmlEncode(txtPO_NO) <> "" Then
            For Each r As DataRow In dt.Rows
                If r.Item("PO_NO") <> Server.HtmlEncode(txtPO_NO) Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()
        End If
        dt.TableName = "INV" : Return dt
    End Function

    <WebMethod()> _
    Public Function OrderTracking(ByVal kunnr As String, ByVal vkorg As String, ByVal txtSO_NO As String, ByVal txtPO_NO As String) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat(" select VBAK.VBELN AS OrderNo, VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS LINE_NO, ")
            .AppendFormat(" VBAP.MATNR AS PART_NO, VBAP.KWMENG AS ORDER_QTY, ")
            .AppendFormat(" VBAP.NETPR AS UNIT_PRICE, VBUP.LFSTA AS Status, ")
            .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, ")
            .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
            .AppendFormat(" VBEP.EDATU AS DUE_DATE2, VBAP.ZZ_GUARA AS ExWarranty, '' as SERIAL_NO, ")
            .AppendFormat(" nvl((select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1),0) as SchedLineShipedQty, ")
            .AppendFormat(" nvl((select VBRP.VBELN from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),'') as INVOICE_INFO1, ")
            .AppendFormat(" nvl((select VBRK.FKDAT from SAPRDP.VBRK INNER JOIN SAPRDP.VBRP on VBRK.VBELN=VBRP.VBELN WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRK.MANDT='168'),'9999-12-31') as INVOICE_INFO2, ")
            .AppendFormat(" nvl((select VBRP.FKIMG from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),0) as INVOICE_INFO3, ")
            .AppendFormat(" nvl((select SUM(LFIMG) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR),0) as DLV_QTY ")
            .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
            .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
            .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
            .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND ")
            .AppendFormat(" (VBAK.KUNNR='{0}') AND (VBAK.VKORG = '{1}') AND VBUP.LFSTA IN ('A','B') AND ", kunnr, vkorg)
            .AppendFormat(" VBAP.MATNR not like 'AGS-EW-%' ")
            If Server.HtmlEncode(txtSO_NO) <> "" Then .AppendFormat(" AND VBAK.VBELN = '{0}' ", Server.HtmlEncode(txtSO_NO.ToUpper()))
            If Server.HtmlEncode(txtPO_NO) <> "" Then .AppendFormat(" AND VBAK.BSTNK = '{0}' ", Server.HtmlEncode(txtPO_NO.ToUpper()))
            .AppendFormat(" and VBAP.ABGRU = ' ' ")
            .AppendFormat(" ORDER BY LINE_NO asc, DUE_DATE2 desc")
        End With

        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)

        Dim BRs() As DataRow = dt.Select("Status='B'", "OrderNo ASC, LINE_NO ASC, DUE_DATE2 ASC")

        If BRs.Length > 0 Then
            Dim curSO As String = "", curLine As String = "", curQty As Decimal = 0
            For Each sch As DataRow In BRs
                If sch.Item("LINE_NO").ToString() <> curLine Then
                    curLine = sch.Item("LINE_NO")
                    curQty = DirectCast(sch.Item("DLV_QTY"), Decimal)
                End If
                If CDbl(sch.Item("SchdLineOpenQty")) > curQty Then
                    sch.Item("SchdLineOpenQty") = sch.Item("SchdLineOpenQty") - curQty
                    curQty = 0
                Else
                    curQty = curQty - CDbl(sch.Item("SchdLineOpenQty"))
                    sch.Delete()
                End If
            Next
        End If
        dt.AcceptChanges()

        BRs = dt.Select("Status='A' and SchedLineShipedQty=0 and SchdLineOpenQty=0")
        'If Session("user_id") = "rudy.wang@advantech.com.tw" Then Response.Write(BRs.Length)
        For Each sch As DataRow In BRs
            If dt.Select(String.Format("LINE_NO={0} and OrderNo='{1}' and SchdLineNo>1", sch.Item("LINE_NO"), sch.Item("OrderNo"))).Length > 0 Then
                sch.Delete()
            End If
        Next
        dt.AcceptChanges()

        sb = New System.Text.StringBuilder
        With sb
            .AppendFormat(" select VBAK.WAERK AS CURRENCY, cast(VBAP.POSNR as integer) AS LINE_NO, ")
            .AppendFormat(" VBAP.MATNR AS PART_NO, VBAP.KWMENG AS ORDER_QTY, ")
            .AppendFormat(" VBAP.NETPR AS UNIT_PRICE, VBUP.LFSTA AS Status, ")
            .AppendFormat(" VBEP.BMENG AS SchdLineOpenQty, ")
            .AppendFormat(" cast(VBEP.ETENR as integer) as SchdLineNo, ")
            .AppendFormat(" VBEP.EDATU AS DUE_DATE2, VBAP.ZZ_GUARA AS ExWarranty, '' as SERIAL_NO, ")
            .AppendFormat(" nvl((select cast(LFIMG as integer) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR and rownum=1),0) as SchedLineShipedQty, ")
            .AppendFormat(" nvl((select VBRP.VBELN from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),'') as INVOICE_INFO1, ")
            .AppendFormat(" nvl((select VBRK.FKDAT from SAPRDP.VBRK INNER JOIN SAPRDP.VBRP on VBRK.VBELN=VBRP.VBELN WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRK.MANDT='168'),'9999-12-31') as INVOICE_INFO2, ")
            .AppendFormat(" nvl((select VBRP.FKIMG from SAPRDP.VBRP WHERE VBAK.VBELN=VBRP.AUBEL AND ROWNUM=1 and VBRP.MANDT='168'),0) as INVOICE_INFO3, ")
            .AppendFormat(" nvl((select SUM(LFIMG) from SAPRDP.LIPS where LIPS.VGBEL=VBAK.VBELN and LIPS.VGPOS=VBAP.POSNR),0) as DLV_QTY ")
            .AppendFormat(" FROM SAPRDP.VBAK INNER JOIN SAPRDP.VBAP ON VBAK.VBELN = VBAP.VBELN INNER JOIN ")
            .AppendFormat(" SAPRDP.VBEP ON VBAP.VBELN = VBEP.VBELN AND VBAP.POSNR = VBEP.POSNR INNER JOIN ")
            .AppendFormat(" SAPRDP.VBUP ON VBAP.VBELN = VBUP.VBELN AND VBAP.POSNR = VBUP.POSNR ")
            .AppendFormat(" WHERE (VBAK.MANDT = '168') AND (VBAP.MANDT = '168') AND (VBEP.MANDT = '168') AND ")
            .AppendFormat(" (VBAK.KUNNR='{0}') AND (VBAK.VKORG = '{1}') AND VBUP.LFSTA IN ('C') AND ", kunnr, vkorg)
            .AppendFormat(" VBAP.MATNR not like 'AGS-EW-%' ")
            If Server.HtmlEncode(txtSO_NO) <> "" Then .AppendFormat(" AND VBAK.VBELN = '{0}' ", Server.HtmlEncode(txtSO_NO.ToUpper()))
            If Server.HtmlEncode(txtPO_NO) <> "" Then .AppendFormat(" AND VBAK.BSTNK = '{0}' ", Server.HtmlEncode(txtPO_NO.ToUpper()))
            .AppendFormat(" and VBAP.ABGRU = ' ' ")
            .AppendFormat(" ORDER BY LINE_NO asc, DUE_DATE2 desc")
        End With

        Dim dt1 As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
        For Each r As DataRow In dt1.Rows
            If CInt(r.Item("DLV_QTY")) > 0 Then
                r.Delete()
            End If
        Next
        dt1.AcceptChanges()
        dt.Merge(dt1)

        dt.TableName = "Order" : Return dt
    End Function

    Private Function DateConvert(ByVal strVal As String) As String
        If IsDate(strVal) Then
            Dim yyyy As String = Year(strVal).ToString()
            Dim mm As String = ""
            Dim dd As String = ""
            Select Case Month(strVal).ToString().Length
                Case 1
                    mm = "0" & Month(strVal).ToString()
                Case 2
                    mm = Month(strVal).ToString()
            End Select
            Select Case Day(strVal).ToString().Length
                Case 1
                    dd = "0" & Day(strVal).ToString()
                Case 2
                    dd = Day(strVal).ToString()
            End Select
            DateConvert = yyyy & mm & dd
        Else
            DateConvert = "00000000"
        End If
    End Function

    <WebMethod()> _
    Public Function GetAR(ByVal kunnr As String, ByVal vkorg As String, ByVal type As String, ByVal Inv_NO As String, _
    ByVal ShippingDateFrom As String, ByVal ShippingDateTo As String, ByVal DueDateFrom As String, ByVal DueDateTo As String) As DataTable
        ShippingDateFrom = DateConvert(CDate(ShippingDateFrom))
        ShippingDateTo = DateConvert(CDate(ShippingDateTo))
        DueDateFrom = DateConvert(CDate(DueDateFrom))
        DueDateTo = DateConvert(CDate(DueDateTo))
        Dim salesOrg As String = "EU10"
        Dim disChannel As String = "10"
        Dim division As String = "00"

        Dim sql As String = String.Format("select distinct a.vkorg,a.vbeln,a.fkdat,nvl(a.netwr,0) as netwr,a.waerk,nvl(a.mwsbk,0) as mwsbk,a.kunag,a.kunrg,b.aubel,(select c.kunnr from SAPRDP.vbpa c where c.vbeln=b.aubel and rownum = 1 and c.parvw = 'WE') as kunnr,(select d.kunnr from SAPRDP.vbpa d where d.vbeln=b.aubel and rownum=1 and d.parvw = 'RE') as kunnr2,(select e.bstkd from SAPRDP.vbkd e where b.aubel = e.vbeln and rownum=1) as bstkd " + _
                                          " FROM SAPRDP.vbrk a inner join SAPRDP.vbrp b on a.vbeln = b.vbeln" + _
                                          " WHERE a.mandt='168' and b.mandt='168' and a.fksto = ' ' and a.sfakn = ' ' and a.vbeln <> ' ' and a.vkorg = '{0}' and a.vtweg = '{1}' and a.spart = '{2}' and a.kunag = '{3}' and a.fkdat between '{4}' and '{5}' order by a.fkdat desc", salesOrg, disChannel, division, kunnr, ShippingDateFrom, ShippingDateTo)
        'Response.Write(sql)
        Dim dt_vbrk As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sql)

        Dim dt_bsid As DataTable = Nothing, dt_bsad As DataTable = Nothing
        Dim arrInvoiceNo As New ArrayList()
        For Each r As DataRow In dt_vbrk.Rows
            If Not arrInvoiceNo.Contains("'" + r.Item("vbeln") + "'") Then arrInvoiceNo.Add("'" + r.Item("vbeln") + "'")
        Next
        If arrInvoiceNo.Count > 0 Then
            sql = "SELECT vbeln,budat,blart,xzahl,shkzg,nvl(wrbtr,0) as wrbtr,zfbdt,zbd1t,waers From SAPRDP.bsid where vbeln in (" + String.Join(",", arrInvoiceNo.ToArray(GetType(String))) + ")"
            'Response.Write(sql)
            dt_bsid = OraDbUtil.dbGetDataTable("SAP_PRD", sql)
        End If
        arrInvoiceNo.Clear()
        For Each r As DataRow In dt_vbrk.Rows
            If Not arrInvoiceNo.Contains("'" + r.Item("vbeln") + "'") Then arrInvoiceNo.Add("'" + r.Item("vbeln") + "'")
        Next
        If arrInvoiceNo.Count > 0 Then
            sql = "SELECT vbeln,budat,blart,nvl(wrbtr,0) as wrbtr,shkzg,waers,zfbdt,zbd1t From SAPRDP.bsad where vbeln in (" + String.Join(",", arrInvoiceNo.ToArray(GetType(String))) + ")"
            'Response.Write(sql)
            dt_bsad = OraDbUtil.dbGetDataTable("SAP_PRD", sql)
        End If

        Dim dt_ar As New DataTable
        dt_ar.Columns.Add("AR_NO", GetType(System.String))
        dt_ar.Columns.Add("AR_DATE", GetType(System.String))
        'dt_ar.Columns.Add("SOLDTO", GetType(System.String))
        dt_ar.Columns.Add("AMOUNT", GetType(System.Double))
        dt_ar.Columns.Add("CURRENCY", GetType(System.String))
        dt_ar.Columns.Add("AR_DUE_DATE", GetType(System.String))
        dt_ar.Columns.Add("LOCAL_AMOUNT", GetType(System.Double))
        dt_ar.Columns.Add("AR_STATUS", GetType(System.String))
        'dt_ar.Columns.Add("SONO", GetType(System.String))
        'dt_ar.Columns.Add("SHIPTO", GetType(System.String))
        'dt_ar.Columns.Add("BILLTO", GetType(System.String))
        'dt_ar.Columns.Add("PONO", GetType(System.String))

        If dt_bsad.Rows.Count > 0 Then
            For Each r As DataRow In dt_bsad.Rows
                Dim row As DataRow = dt_ar.NewRow()
                row.Item("AR_NO") = r.Item("vbeln")
                row.Item("AR_DATE") = Date.ParseExact(r.Item("budat"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd")
                row.Item("CURRENCY") = r.Item("waers")
                Dim dr() As DataRow = dt_vbrk.Select("vbeln='" + r.Item("vbeln") + "'")
                row.Item("AMOUNT") = dr(0).Item("netwr")
                For i As Integer = 0 To dr.Length - 1
                    row.Item("AMOUNT") += dr(i).Item("mwsbk")
                Next
                row.Item("AR_DUE_DATE") = DateAdd(DateInterval.Day, CDbl(r.Item("zbd1t")), Date.ParseExact(r.Item("zfbdt"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None)).ToString("yyyy/MM/dd")
                row.Item("LOCAL_AMOUNT") = row.Item("AMOUNT") - r.Item("wrbtr")
                row.Item("AR_STATUS") = "Cleared"
                dt_ar.Rows.Add(row)
            Next
        End If

        If dt_bsid.Rows.Count > 0 Then
            For Each r As DataRow In dt_bsid.Rows
                Dim row As DataRow = dt_ar.NewRow()
                row.Item("AR_NO") = r.Item("vbeln")
                row.Item("AR_DATE") = Date.ParseExact(r.Item("budat"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd")
                row.Item("CURRENCY") = r.Item("waers")
                Dim dr() As DataRow = dt_vbrk.Select("vbeln='" + r.Item("vbeln") + "'")
                row.Item("AMOUNT") = dr(0).Item("netwr")
                For i As Integer = 0 To dr.Length - 1
                    row.Item("AMOUNT") += dr(i).Item("mwsbk")
                Next
                row.Item("AR_DUE_DATE") = DateAdd(DateInterval.Day, CDbl(r.Item("zbd1t")), Date.ParseExact(r.Item("zfbdt"), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None)).ToString("yyyy/MM/dd")
                If r.Item("shkzg") = "H" Then
                    Dim oridr() As DataRow = dt_ar.Select("AR_NO='" + r.Item("vbeln") + "'")
                    If oridr.Length > 0 Then
                        row.Item("AR_DATE") = oridr(0).Item("AR_DATE")
                        row.Item("LOCAL_AMOUNT") = row.Item("AMOUNT") + r.Item("wrbtr")
                        dt_ar.Rows(dt_ar.Rows.IndexOf(oridr(0))).Delete()
                    End If
                Else
                    row.Item("LOCAL_AMOUNT") = r.Item("wrbtr")
                End If

                If IsDBNull(row.Item("LOCAL_AMOUNT")) Then
                    row.Item("AR_STATUS") = "Cleared"
                ElseIf row.Item("LOCAL_AMOUNT") = 0 Then
                    row.Item("AR_STATUS") = "Cleared"
                Else
                    If row.Item("AR_DUE_DATE") = "" Or IsDBNull(row.Item("AR_DUE_DATE")) Then
                        row.Item("AR_STATUS") = "Open"
                    Else
                        If row.Item("AMOUNT") - row.Item("LOCAL_AMOUNT") <> 0 Then
                            If CDate(row.Item("AR_DUE_DATE")) < Date.Today Then
                                row.Item("AR_STATUS") = "Partial Overdue"
                            Else
                                row.Item("AR_STATUS") = "Partially Cleared"
                            End If
                        Else
                            If CDate(row.Item("AR_DUE_DATE")) < Date.Today Then
                                row.Item("AR_STATUS") = "Overdue"
                            Else
                                row.Item("AR_STATUS") = "Open"
                            End If
                        End If
                    End If
                End If
                dt_ar.Rows.Add(row)
            Next
        End If

        Dim dr1() As DataRow = dt_ar.Select("AR_DUE_DATE < '" + Date.ParseExact(DueDateFrom, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd") + "' or AR_DUE_DATE > '" + Date.ParseExact(DueDateTo, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None).ToString("yyyy/MM/dd") + "'")
        For i As Integer = 0 To dr1.Length - 1
            dt_ar.Rows(dt_ar.Rows.IndexOf(dr1(i))).Delete()
        Next

        Dim status As String = "", no As String = ""
        Dim dv As DataView = New DataView()
        dv = dt_ar.DefaultView()
        dv.Sort = " ar_no,ar_date desc "
        Select Case type
            Case "Open"
                status = " ar_status like 'Open%' "
            Case "Over Due"
                'Me.status = " status = 'Overdue' or status = 'Partial Overdue'"
                status = " ar_status like '%Over%' "
            Case "All"
                status = " 1=1 "
        End Select
        no = " and ar_no like '%" & Server.HtmlEncode(Inv_NO.ToUpper()) & "%' "
        dv.RowFilter = status & no

        Return dv.ToTable("AR")
    End Function
    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub

    Public Sub New()
        If Not HttpContext.Current.Request.ServerVariables("REMOTE_ADDR") Like "172.21*" _
        And Not HttpContext.Current.Request.ServerVariables("REMOTE_ADDR") Like "172.20.1.21" _
        And Not HttpContext.Current.Request.ServerVariables("REMOTE_ADDR") Like "172.16.6.137" Then
            HttpContext.Current.Response.StatusCode = 403
        End If
    End Sub

    <WebMethod()> _
    Public Function SyncSAPCompanyContactFromSAP(ByVal vkorg As String) As DataTable
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("SELECT DISTINCT PA0105.USRID_LONG AS USERID, KNVP.KUNNR AS COMPANY_ID, PA0001.BUKRS AS ORG_ID, ")
            .AppendFormat("PA0105.USRID_LONG AS EMAIL_ADDR, PA0105.USRID_LONG AS PHONE, PA0002.NACHN AS LAST_NAME, ")
            .AppendFormat("PA0002.VORNA AS FIRST_NAME, 'SALES Employee' AS ROLE, PA0105.PERNR, PA0105.USRTY ")
            .AppendFormat("FROM SAPRDP.PA0105 INNER JOIN SAPRDP.KNVP ON PA0105.PERNR = KNVP.PERNR INNER JOIN ")
            .AppendFormat("SAPRDP.PA0001 ON PA0105.PERNR = PA0001.PERNR INNER JOIN SAPRDP. PA0002 ON PA0105.PERNR = PA0002.PERNR ")
            .AppendFormat("WHERE (KNVP.PARVW = 'VE') and PA0001.BUKRS='{0}' ", vkorg)
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
        dt.TableName = "SAPCompanyContact"
        Return dt
    End Function

    <WebMethod()> _
    Public Function SyncCompanyContactFromSAP(ByVal vkorg As String) As DataTable
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select pa0105.USRID_LONG AS USERID, knvp.kunnr AS COMPANY_ID, knvp.vkorg as org_id,'Yes' AS AutoUpdate ")
            .AppendFormat("from saprdp.knvp inner join saprdp.pa0001 on knvp.pernr=pa0001.pernr left join saprdp.pa0105 on pa0001.pernr=pa0105.pernr ")
            .AppendFormat("where knvp.vkorg='{0}' and knvp.parvw in ('VE','Z2','ZM') AND pa0105.subty ='MAIL'", vkorg)
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
        dt.TableName = "SAPCompanyContact"
        Return dt
    End Function

    <WebMethod()> _
    Public Function SyncCompanyFromSAP(ByVal vkorg As String) As DataTable
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select kna1.kunnr as Company_Id, knvv.vkorg as org_id, (select MIN(knvp.kunnr) from saprdp.knvp where knvp.kunn2 = kna1.kunnr and knvp.vkorg=knvv.vkorg AND knvp.parvw='WE') as ParentCompanyId, ")
            .AppendFormat("kna1.name1 || kna1.name2 as Company_Name, adrc.street || adrc.str_suppl3 || adrc.location as Address, ")
            .AppendFormat("kna1.telfx as fax_no, kna1.telf1 as tel_no, kna1.ktokd as company_type, kna1.kdkg1 || kna1.kdkg2 || kna1.kdkg3 || kna1.kdkg4 as price_class, ")
            .AppendFormat("knvv.waers as Currency, adrc.country as Country, adrc.post_code1 as Zip_Code, adrc.city1 as City, ")
            .AppendFormat("adrc.name_co as Attention, '0' as Credit_Limit, knvv.zterm as Credit_Term, knvv.inco1 || '  ' || knvv.inco2 as Ship_Via, ")
            .AppendFormat("kna1.knurl as Url, kna1.erdat as CreatedDate, kna1.ernam as Created_By, knvv.kdgrp as Company_Price_Type, ")
            .AppendFormat("knvv.vsbed as ShipCondition, kna1.KATR4 as attribute4, KNVV.VKBUR as SalesOffice, KNVV.VKGRP as SalesGroup ")
            .AppendFormat("from saprdp.knvv inner join saprdp.kna1 on knvv.kunnr=kna1.kunnr inner join saprdp.adrc on kna1.adrnr=adrc.addrnumber and kna1.land1=adrc.country ")
            .AppendFormat("where  knvv.vkorg = '{0}' and kna1.loevm = ' '", vkorg)
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
        dt.TableName = "SAPCompany"
        Return dt
    End Function

    <WebMethod()> _
    Public Function SyncProductFromSAP(ByVal vkorg As String, ByVal werks As String) As DataTable
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("SELECT DISTINCT to_char(mara.matnr) as part_no,makt.maktx as product_desc,to_char(mvke.vmsta) as status, ")
            .AppendFormat("to_char(mara.meins) as uom,to_char(mara.bismt) as model_no,mara.ihivi as highlyviscs,nvl(to_char(mvke.prodh),'') as product_hierachy, ")
            .AppendFormat("to_char(mara.mtart) as product_type,nvl(mara.brgew,0) as ship_weight,nvl(mara.ntgew,0) as net_weight,mara.volum as volum, ")
            .AppendFormat("marc.werks as plant,to_char(mara.mtpos_mara) as general_category_group,to_char(mara.matkl) as material_group, ")
            .AppendFormat("to_char(mvke.mtpos) as item_category_group,nvl(to_char(mara.zeifo),'') as rohs,mvke.PRAT1 as attribute1, ")
            .AppendFormat("mvke.PRAT2 as attribute2,mvke.PRAT3 as attribute3,mvke.PRAT4 as attribute4,nvl(to_char(mvke.PRAT5),'') as attribute5, ")
            .AppendFormat("mvke.PRAT6 as attribute6,mvke.PRAT7 as attribute7,mvke.PRAT8 as attribute8,mvke.PRAT9 as attribute9, ")
            .AppendFormat("nvl(to_char(mvke.PRATA),'') as attribute10,to_char(marc.MAABC) as ABCIndicator,mvke.DWERK as DeliveryPlant, ")
            .AppendFormat("nvl(mbew.stprs,0) as cost,to_char(mara.MFRPN)  as mfrpn,marc.PLIFZ as PlannedDelTime,marc.WEBAZ as GrProcessingTime, ")
            .AppendFormat("mvke.kondm as PricingGroup ")
            .AppendFormat("FROM saprdp.mara INNER JOIN saprdp.mvke ON mara.matnr = mvke.matnr INNER JOIN saprdp.makt ON ")
            .AppendFormat("mvke.matnr = makt.matnr INNER JOIN saprdp.marc ON makt.matnr = marc.matnr ")
            .AppendFormat("left join saprdp.mbew on mara.matnr=mbew.matnr and mbew.bwkey=marc.werks ")
            .AppendFormat("WHERE mara.mtart LIKE 'Z%' AND mvke.vmsta IN ('A','N','H','S5') AND makt.spras LIKE 'E%' AND ")
            .AppendFormat("mvke.vkorg = '{0}' AND marc.werks = '{1}' and mara.aenam<>'HUNTER.PENG'", vkorg, werks)
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString)
        dt.TableName = "SAPProduct"
        Return dt
    End Function

    <WebMethod()> _
    Public Function SyncPLMPhaseInProduct() As DataTable
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select CHANGE_NUMBER,RELEASE_DATE,REV_NUMBER,ITEM_NUMBER,DESCRIPTION,PART_CATEGORY,PROD_GROUP,PROD_DIVISION,")
            .AppendFormat("PROD_LINE,CHANGE_REASON from agile.PHASEIN2")
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("PLM", sb.ToString)
        dt.TableName = "PLMPhaseIn"
        Return dt
    End Function

    <WebMethod()> _
    Public Function SyncPLMPhaseOutProduct() As DataTable
        Dim sb As New StringBuilder
        With sb
            .AppendFormat("select CHANGE_NUMBER,RELEASE_DATE,REV_NUMBER,ITEM_NUMBER,DESCRIPTION,PART_CATEGORY,REPLACEMENT_MODEL,")
            .AppendFormat("LAST_SHIP_DATE,PROD_GROUP,PROD_DIVISION,PROD_LINE,CHANGE_REASON from agile.PHASEOUT2")
        End With
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("PLM", sb.ToString)
        dt.TableName = "PLMPhaseOut"
        Return dt
    End Function

    <WebMethod()> _
    Public Function GetEUPrice(ByVal kunnr As String, ByVal org As String, ByVal matnr As String, ByVal sDate As Date) As DataTable
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
        With prec
            .Kunnr = kunnr : .Mandt = "168" : .Matnr = matnr : .Mglme = 1 : .Prsdt = sDate.ToString("yyyyMMdd") : .Vkorg = org
        End With
        pin.Add(prec)
        'Next
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            eup.Connection.Close() : Return Nothing
        End Try
        eup.Connection.Close()
        Dim pdt As DataTable = pout.ToADODataTable()
        pdt.TableName = "EUPriceTable"
        Return pdt
    End Function

    <WebMethod()> _
    Public Function GetEUMultiPrice(ByVal kunnr As String, ByVal org As String, ByVal matnrDt As DataTable, ByVal sDate As Date) As DataTable
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        Dim strDate As String = sDate.ToString("yyyyMMdd")
        For Each m As DataRow In matnrDt.Rows
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = kunnr : .Mandt = "168" : .Matnr = m.Item(0).ToString() : .Mglme = 1 : .Prsdt = strDate : .Vkorg = org
            End With
            pin.Add(prec)
        Next
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            eup.Connection.Close() : Return Nothing
        End Try
        eup.Connection.Close()
        Dim pdt As DataTable = pout.ToADODataTable()
        pdt.TableName = "EUPriceTable"
        Return pdt
    End Function

    <WebMethod()> _
    Public Function QueryPrice(ByVal customer As String, ByVal sales_org As String, ByRef itemTb As DataTable) As DataTable
        Dim proxy1 As New Get_Price.Get_Price
        Dim TC_zssD_01Table1 As New Get_Price.ZSSD_01Table
        Dim Dist_Chann As String = "10", Division As String = "00"
        If sales_org = "US01" Then
            Dist_Chann = "30" : Division = "10"
        End If
        Dim ReturnTable As New Get_Price.BAPIRETURN
        For num1 As Integer = 0 To itemTb.Rows.Count - 1
            Dim zssd_1 As New Get_Price.ZSSD_01
            With zssd_1
                .Kunnr = customer : .Mandt = "168"
                .Matnr = Format2SAPItem(itemTb.Rows.Item(num1).Item("part").ToString)
                .Mglme = itemTb.Rows.Item(num1).Item("qty_buy")
                .Vkorg = sales_org
            End With
            TC_zssD_01Table1.Add(zssd_1)
        Next num1
        Dim TC_zssD_02Table1 As New Get_Price.ZSSD_02Table
        Try
            proxy1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
            proxy1.Connection.Open()
            proxy1.Z_Ebizaeu_Priceinquiry(Dist_Chann, Division, customer, sales_org, customer, ReturnTable, TC_zssD_01Table1, TC_zssD_02Table1)
            proxy1.Connection.Close()
        Catch ex As Exception
            proxy1.Connection.Close() : Return Nothing
        End Try
        Dim rdt As DataTable = TC_zssD_02Table1.ToADODataTable()
        rdt.TableName = "PriceTable"
        Return rdt
    End Function


    Public Shared Function IsNumericItem(ByVal part_no As String) As Boolean
        Dim pChar() As Char = part_no.ToCharArray()
        For i As Integer = 0 To pChar.Length - 1
            If Not IsNumeric(pChar(i)) Then
                Return False
                Exit Function
            End If
        Next
        Return True
    End Function
    Public Shared Function Format2SAPItem(ByVal Part_No As String) As String
        Try
            If IsNumericItem(Part_No) And Not Part_No.Substring(0, 1).Equals("0") Then
                Dim zeroLength As Integer = 18 - Part_No.Length
                For i As Integer = 0 To zeroLength - 1
                    Part_No = "0" & Part_No
                Next
                Return Part_No
            Else
                Return Part_No
            End If
        Catch ex As Exception
            Return Part_No
        End Try
    End Function

End Class

Public Class SAPDOC
    Shared Function replaceCartBTO(ByVal PN As String) As String
        'If HttpContext.Current.Session("Org") = "US" Then
        If PN.StartsWith("EZ-") Then PN = PN.Substring(3, PN.Length - 3)
        Dim vnumber As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 vnumber from EZ_CBOM_MAPPING where number='{0}' and ORG ='{1}'  order by ismanual  desc ", PN.ToString, HttpContext.Current.Session("org_id").ToString.ToUpper.Substring(0, 2)))
        If Not IsNothing(vnumber) AndAlso vnumber.ToString <> "" Then
            Return vnumber
        End If
        vnumber = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 vnumber from EZ_CBOM_MAPPING where number='{0}' and ORG ='{1}'  order by ismanual  desc ", PN.ToString.Trim + "-BTO", HttpContext.Current.Session("org_id").ToString.ToUpper.Substring(0, 2)))
        If Not IsNothing(vnumber) AndAlso vnumber.ToString <> "" Then
            Return vnumber
        End If
        If PN.Trim.EndsWith("-BTO") Then
            Dim Temp_PN = PN.Substring(0, PN.Length - 4)
            vnumber = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 vnumber from EZ_CBOM_MAPPING where number='{0}' and ORG ='{1}'  order by ismanual  desc ", Temp_PN, HttpContext.Current.Session("org_id").ToString.ToUpper.Substring(0, 2)))
            If Not IsNothing(vnumber) AndAlso vnumber.ToString <> "" Then
                Return vnumber
            End If
        Else
            Return PN
        End If
        Return PN
    End Function
    Shared Function getOrderNumberOracle(ByVal order_id As String) As String
        Dim Org As String = Left(HttpContext.Current.Session("org_id").ToString.ToUpper, 2)
        'Frank 20140922 comment out below codes because the US team still does not decide the specific ERP ID
        'Dim sql As String = String.Format("  select  top 1 ISNULL(SOLDTO_ID,'') as SoldTo  from   ORDER_MASTER where ORDER_ID ='{0}' ", order_id)
        'Dim obj As Object = dbUtil.dbExecuteScalar("MY", sql)
        'If obj IsNot Nothing AndAlso String.Equals(obj.ToString.Trim(), "AmazonErpid", StringComparison.CurrentCultureIgnoreCase) Then
        '    Return SAPDAL.SAPDAL.SO_GetNumber("AMZ")
        'End If
        'ICC 2015/2/10 Add variable order_id in getOrderPrefix function

        'Ryan 20160126 Add for Check-Point order number generation method and order status update.
        If AuthUtil.IsCheckPointOrder(HttpContext.Current.Session("user_id"), HttpContext.Current.Session("cart_id")) Then
            Dim so_no As String = Advantech.Myadvantech.Business.CPDBBusinessLogic.CheckPointOrder2Cart_getOrderNo(HttpContext.Current.Session("cart_id"))
            If Not String.IsNullOrEmpty(so_no) Then

                'Ryan 20161227 Delete order record to prevent pi mail duplicate issue if first order failed and re-order again.
                dbUtil.dbExecuteNoQuery("MY", "delete from ORDER_MASTER where ORDER_ID = '" + so_no + "' ; delete from ORDER_DETAIL where ORDER_ID = '" + so_no + "'")

                Return so_no
            End If
        End If

        'Ryan 20160822 Add for Latin America Qualified Customers special order no.
        If AuthUtil.IsUSAonlineSales(HttpContext.Current.Session("user_id")) AndAlso Not String.IsNullOrEmpty(Advantech.Myadvantech.Business.QuoteBusinessLogic.GetQuoteIDByCartID(order_id)) Then
            If Not String.IsNullOrEmpty(dbUtil.dbExecuteScalar("MY", "SELECT CompanyID FROM LatinQualifiedCustomer WHERE COMPANYID = '" + HttpContext.Current.Session("COMPANY_ID") + "'")) Then
                Return SAPDAL.SAPDAL.SO_GetNumber("LTAO")
            End If
        End If

        'Frank 20171221,ADloG's order's prefix number (ABXXXXXX)
        If AuthUtil.IsADloG() Then
            Return SAPDAL.SAPDAL.SO_GetNumber("AB")
        End If

        'Ryan 20170510 Extra Logic for ACN, external users order_no needs to add extra letter C
        If HttpContext.Current.Session("org_id").ToString.Trim.StartsWith("CN", StringComparison.OrdinalIgnoreCase) Then
            Dim ACNPrefix = getOrderPrefix(Org, order_id)
            Dim ACNOrderNo = SAPDAL.SAPDAL.SO_GetNumber(getOrderPrefix(Org, order_id))
            If Util.IsInternalUser2 Then
                Return ACNOrderNo
            Else
                ACNOrderNo = ACNOrderNo.Replace(ACNPrefix, "")
                Return ACNPrefix + "C" + ACNOrderNo
            End If
        Else
            Return SAPDAL.SAPDAL.SO_GetNumber(getOrderPrefix(Org, order_id))
        End If
    End Function
    Shared Function getOrderPrefix(ByVal orgid As String, ByVal order_id As String) As String
        Dim preFix As String = ""
        If orgid = "EU" Then
            preFix = "FU"
        ElseIf orgid = "TW" Then
            preFix = "SG"
        ElseIf orgid = "US" Then
            'Frank 2012/07/03:If login user is ANA sales, then the order number will be "AUSO" with 6 digit 
            'preFix = "BT"
            'If MailUtil.IsMexicoAonlineSale(HttpContext.Current.Session("user_id")) Then
            '    preFix = "AMXO"
            'ElseIf MailUtil.IsInRole("SALES.IAG.USA") Then
            '    'Frank 2014/11/05 :
            '    'Hi TC-
            '    'I think it is fine to go with AACQ and AACO. It will be clear to everyone what this means.
            '    '-Lynette
            '    preFix = "AACO"
            '    'Ming 20141201 添加对IAG群组的判断
            'ElseIf MailUtil.IsInRole("Aonline.USA") OrElse MailUtil.IsInRole("Aonline.USA.IAG") Then
            '    preFix = "AUSO"
            'Else
            '    preFix = "BT"
            'End If

            preFix = "BT"

            'If MailUtil.IsMexicoAonlineSale(HttpContext.Current.Session("user_id")) Then
            '    preFix = "AMXO"
            'Else
            '    Dim Ar As ArrayList = SAPDAL.UserRole.GetMailGroupByInternalUser(HttpContext.Current.Session("user_id"))
            '    Dim Siebelapt As New MYSIEBELTableAdapters.SIEBEL_ACCOUNTTableAdapter
            '    Dim siebeldt As MYSIEBEL.SIEBEL_ACCOUNTDataTable = Siebelapt.GetAccountByRowId(HttpContext.Current.Session("account_row_id"))
            '    If siebeldt.Rows.Count = 0 Then
            '        siebeldt = Siebelapt.GetAccountByERPID(HttpContext.Current.Session("account_row_id"))
            '        siebeldt.DefaultView.Sort = "ACCOUNT_STATUS"
            '        siebeldt = siebeldt.DefaultView.ToTable
            '    End If
            '    Dim _newaccenum As SAPDAL.UserRole.AccountStatus = SAPDAL.UserRole.AccountStatus.GA

            '    If siebeldt.Rows.Count > 0 Then
            '        Dim siebelrow As MYSIEBEL.SIEBEL_ACCOUNTRow = siebeldt.Rows(0)
            '        _newaccenum = SAPDAL.UserRole.GetAccountStatusEnum(siebelrow.ACCOUNT_STATUS)
            '    End If

            '    Select Case _newaccenum
            '        Case SAPDAL.UserRole.AccountStatus.CP, SAPDAL.UserRole.AccountStatus.KA
            '            preFix = SAPDAL.UserRole.GetAUSDocNumberPrefixStringByGroup(Ar, SAPDAL.UserRole.AccountStatus.CP, SAPDAL.UserRole.DocType.Order)
            '        Case Else
            '            preFix = SAPDAL.UserRole.GetAUSDocNumberPrefixStringByGroup(Ar, SAPDAL.UserRole.AccountStatus.GA, SAPDAL.UserRole.DocType.Order)
            '    End SelectC 
            'End If

            'ICC 2015/2/10 Modify the rule to if order_id is from eQuotation, then set the prefix string as quote
            'Ryan 20170330 Only if orders are generated from quotations need to apply order prefix logic.
            If MyCartX.IsQuote2Cart(order_id, "") Then
                Dim fix As String = Advantech.Myadvantech.Business.OrderBusinessLogic.GetUSAOnlineOrderPrefix(order_id)
                If Not String.IsNullOrEmpty(fix) Then
                    preFix = fix
                End If
            End If

            'Ryan 20170906 If is US10(B+B US) use its prefix
            If HttpContext.Current.Session("ORG_ID") IsNot Nothing AndAlso HttpContext.Current.Session("ORG_ID").ToString().Equals("US10") Then
                preFix = "BB"
            End If
        ElseIf orgid = "SG" Then
            preFix = "SP"
        ElseIf orgid = "JP" Then
            preFix = "AJ"
        ElseIf orgid = "CN" Then
            'Ryan 20170322 New logic for ACN order prefix, confirmed by Bruce.Li & Jingjing.Jiang
            '整機訂單-> KNxxxxxx(昆山CTOS, CN10, 北京研華), KSxxxxxx(昆山CTOS, CN30, 上海研華)
            '單品訂單-> DCxxxxxx(CN10), DSxxxxxx(CN30)
            If HttpContext.Current.Session("ORG_ID").ToString().Equals("CN10") Then
                If MyOrderX.IsHaveBtos(order_id) Then
                    If Not HttpContext.Current.Session("ACN_StorageLocation") Is Nothing AndAlso HttpContext.Current.Session("ACN_StorageLocation").ToString().Equals("1000") Then
                        preFix = "KN"
                    ElseIf Not HttpContext.Current.Session("ACN_StorageLocation") Is Nothing AndAlso HttpContext.Current.Session("ACN_StorageLocation").ToString().Equals("2000") Then
                        preFix = "CBN"
                    Else
                        preFix = "KN"
                    End If
                Else
                    If HttpContext.Current.Session("org_id").ToString.StartsWith("CN") AndAlso MyServices.IsACNOrderNeedsApproval(order_id, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(HttpContext.Current.Session("org_id").ToString), HttpContext.Current.Session("org_id")) Then
                        preFix = "QDC"
                    Else
                        preFix = "DC"
                    End If
                End If
            ElseIf HttpContext.Current.Session("ORG_ID").ToString().Equals("CN30") Then
                If MyOrderX.IsHaveBtos(order_id) Then
                    preFix = "KS"
                Else
                    If HttpContext.Current.Session("org_id").ToString.StartsWith("CN") AndAlso MyServices.IsACNOrderNeedsApproval(order_id, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(HttpContext.Current.Session("org_id").ToString), HttpContext.Current.Session("org_id")) Then
                        preFix = "QDS"
                    Else
                        preFix = "DS"
                    End If
                End If
            ElseIf HttpContext.Current.Session("ORG_ID").ToString().Equals("CN70") Then
                If MyOrderX.IsHaveBtos(order_id) Then
                    preFix = "KI"
                Else
                    If HttpContext.Current.Session("org_id").ToString.StartsWith("CN") AndAlso MyServices.IsACNOrderNeedsApproval(order_id, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(HttpContext.Current.Session("org_id").ToString), HttpContext.Current.Session("org_id")) Then
                        preFix = "QDI"
                    Else
                        preFix = "DI"
                    End If
                End If
            End If
        ElseIf orgid = "MY" Then
            preFix = "MY"
        ElseIf orgid = "VN" Then
            preFix = "VN"
        ElseIf orgid = "KR" Then

            preFix = "KR"

            'Ryan 20170731 New order prefix logic for AKR, depending on isBtos or not.
            If MyOrderX.IsHaveBtos(order_id) Then
                preFix = "KRC"
            Else
                preFix = "KR"
            End If

            'Ryan 20170727 Comment below out, take KR as prefix instead of AKRO
            'If AuthUtil.IsKRAonlineSales(HttpContext.Current.Session("user_id").ToString()) Then
            '    preFix = "AKRO"
            'End If
        End If
        If SAPDOC.IsATWCustomer() Then
            preFix = "TWO"
        End If
        If AuthUtil.IsHQDCiASales(HttpContext.Current.Session("user_id").ToString()) Then
            preFix = "AIAO"
        End If
        If AuthUtil.IsHQDCeCSales(HttpContext.Current.Session("user_id").ToString()) Then
            preFix = "AIEO"
        End If
        If MailUtil.IsAENCSale() Then
            preFix = "AENC"
        End If
        Return preFix
    End Function
    Public Shared Function GetLocalTime(ByVal org As String) As DateTime
        Dim localtime As DateTime = DateTime.Now
        Dim utcTime As DateTime = DateTime.Now.ToUniversalTime()
        Dim timezone As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 isnull(timezonename,'') as timezonename from TIMEZONE where org like '%{0}'", org))
        If timezone IsNot Nothing AndAlso Not String.IsNullOrEmpty(timezone) Then
            Dim TZI As TimeZoneInfo = TimeZoneInfo.FindSystemTimeZoneById(timezone)
            Dim TS As TimeSpan = TZI.GetUtcOffset(utcTime)
            localtime = utcTime.Add(TS)
        End If
        Return localtime
    End Function
    Public Shared Sub Get_disChannel_and_division(ByVal companyid As String, ByRef disChannel As String, ByRef division As String)
        disChannel = "10" : division = "00"
        companyid = UCase(companyid)
        Dim strOrg As String = HttpContext.Current.Session("Org_id").ToString().ToUpper(), strSalesGrp As String = "", strSalesOffice As String = ""
        Dim apt As New SqlClient.SqlDataAdapter("select top 1 COMPANY_ID, ORG_ID, SALESGROUP, SALESOFFICE from SAP_DIMCOMPANY where COMPANY_ID=@COMPANYID and ORG_ID=@ORGID", ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("COMPANYID", companyid) : apt.SelectCommand.Parameters.AddWithValue("ORGID", strOrg)
        Dim dt As New DataTable
        apt.Fill(dt)
        If dt.Rows.Count = 0 Then
            dt = OraDbUtil.dbGetDataTable("SAP_PRD",
                " select a.kunnr as COMPANY_ID, b.vkorg as ORG_ID, b.VKBUR as SALESOFFICE, b.VKGRP as SALESGROUP " +
                " from saprdp.kna1 a inner join saprdp.knvv b on a.kunnr=b.kunnr " +
                " where a.mandt='168' and b.mandt='168' and b.vkorg ='" + UCase(strOrg) + "'  " +
                " and a.ktokd in ('Z001','Z002') and a.kunnr='" + UCase(companyid) + "' and rownum=1 ")
        End If
        If dt.Rows.Count = 1 Then
            strOrg = dt.Rows(0).Item("ORG_ID") : strSalesGrp = dt.Rows(0).Item("SALESGROUP").ToString().ToUpper() : strSalesOffice = dt.Rows(0).Item("SALESOFFICE").ToString().ToUpper()
            If strOrg = "US01" Then
                Select Case strSalesOffice
                    Case "2100", "2700"
                        disChannel = "30" : division = "10"
                        If Not MYSAPBIZ.VerifyDistChannelDivisionGroupOffice(strOrg, companyid, companyid, disChannel, division,
                                                                             SAPDAL.SAPDAL.SAPOrderType.ZOR, strSalesGrp, strSalesOffice, Nothing) Then
                            Dim CandidateDt As New DataTable, CanApt As New SqlClient.SqlDataAdapter("", ConfigurationManager.ConnectionStrings("MY").ConnectionString)
                            CanApt.SelectCommand.CommandText =
                                " select distinct DIST_CHANN, DIVISION, SALESGROUP, SALESOFFICE " +
                                " from SAP_COMPANY_LOV " +
                                " where ORG_ID=@ORGID and SALESOFFICE=@SOFFICE and DIST_CHANN in ('10','30') and SALESGROUP=@SGRP " +
                                " order by DIST_CHANN, DIVISION "
                            With CanApt.SelectCommand.Parameters
                                .AddWithValue("ORGID", strOrg) : .AddWithValue("SOFFICE", strSalesOffice) : .AddWithValue("SGRP", strSalesGrp)
                            End With
                            CanApt.Fill(CandidateDt)
                            CanApt.SelectCommand.Connection.Close()
                            For Each CandidateRow As DataRow In CandidateDt.Rows
                                If MYSAPBIZ.VerifyDistChannelDivisionGroupOffice(strOrg, companyid, companyid, CandidateRow.Item("DIST_CHANN"), CandidateRow.Item("DIVISION"),
                                                                             SAPDAL.SAPDAL.SAPOrderType.ZOR, strSalesGrp, strSalesOffice, Nothing) Then
                                    disChannel = CandidateRow.Item("DIST_CHANN") : division = CandidateRow.Item("DIVISION")
                                    Exit For
                                End If
                            Next
                        End If
                    Case "2200", "2300"
                        '20120627 TC: Added office 2200 for US CheckPoint UZISCHE01
                        disChannel = "10" : division = "20"
                End Select
            Else

            End If
        End If
    End Sub

    Public Shared Function ISRBU(ByVal COMPANYID As String) As Boolean
        If COMPANYID.ToUpper = "UUAAESC" Or COMPANYID.ToUpper = "EUKA001" Or COMPANYID.ToUpper = "ENLA001" Or
            COMPANYID.ToUpper = "EPLA001" Or COMPANYID.ToUpper = "EITW005" Or COMPANYID.ToUpper = "EFRA005" Then
            Return True
        End If
        Return False
    End Function

    'Public Shared Function SOCreate1(ByVal Order_No As String, ByRef ErrMsg As String) As Boolean
    '    Dim IB As Integer = 0
    '    'Try

    '    Dim myOrderMaster As New order_Master("B2B", "Order_Master"), myOrderDetail As New order_Detail("B2B", "Order_Detail")
    '    Dim my_Company As New SAP_Company("b2b", "sap_dimcompany"), myFt As New Freight("b2b", "Freight")

    '    Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_No), "")
    '    Dim dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_No")
    '    Dim dtFt As DataTable = myFt.GetDT(String.Format("order_id='{0}'", Order_No), "")
    '    If dtMaster.Rows.Count = 0 Or dtDetail.Rows.Count = 0 Then
    '        ErrMsg = "RAW DATA ERROR!" : Return False
    '    End If

    '    Dim HDT As New CreateSAPDOC.SalesOrder1.OrderHeaderDataTable, DDT As New CreateSAPDOC.SalesOrder1.OrderLinesDataTable
    '    Dim PDT As New CreateSAPDOC.SalesOrder1.PartnerFuncDataTable, TDT As New CreateSAPDOC.SalesOrder1.HeaderTextsDataTable
    '    Dim CODT As New CreateSAPDOC.SalesOrder1.ConditionDataTable, CDT As New CreateSAPDOC.SalesOrder1.CreditCardDataTable
    '    'Header
    '    Dim HDR As CreateSAPDOC.SalesOrder1.OrderHeaderRow = HDT.NewRow
    '    With dtMaster
    '        Dim soldtoID As String = .Rows(0).Item("soldto_id")
    '        Dim DTcompany As DataTable = my_Company.GetDT(String.Format("company_id='{0}'", soldtoID), "")
    '        If DTcompany.Rows.Count <= 0 Then
    '            ErrMsg = "Invalid SoldTo!" : Return False
    '        End If
    '        Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id")), distr_chan As String = "10", division As String = "00"
    '        SAPDOC.Get_disChannel_and_division(soldtoID, distr_chan, division)
    '        HDR.ORDER_TYPE = .Rows(0).Item("Order_Type") : HDR.SALES_ORG = sales_org : HDR.DIST_CHAN = distr_chan : HDR.DIVISION = division
    '        HDR.INCO1 = .Rows(0).Item("INCOTERM")
    '        Dim INCO2 As String = "blank"
    '        If .Rows(0).Item("INCOTERM_TEXT") <> "" Then
    '            INCO2 = .Rows(0).Item("INCOTERM_TEXT")
    '        End If
    '        HDR.INCO2 = INCO2
    '        Dim Company_Country As String = ""
    '        If DTcompany.Rows(0).Item("COUNTRY_NAME") IsNot DBNull.Value Then Company_Country = DTcompany.Rows(0).Item("COUNTRY_NAME")
    '        If Company_Country.ToUpper = "NL" Then
    '            HDR.SHIPTO_COUNTRY = Company_Country.ToUpper : HDR.TRIANGULAR_INDICATOR = "X"
    '        End If
    '        HDR.TAX_CLASS = ""
    '        Dim rd As DateTime = Now
    '        If CDate(.Rows(0).Item("required_date")) > Now Then
    '            rd = CDate(.Rows(0).Item("required_date"))
    '        End If
    '        HDR.REQUIRE_DATE = rd.ToString("yyyy/MM/dd")

    '        HDR.SHIP_CONDITION = Left(.Rows(0).Item("SHIP_CONDITION"), 2)
    '        HDR.CUST_PO_NO = IIf(.Rows(0).Item("po_no") = "", Order_No, .Rows(0).Item("po_no"))
    '        HDR.SHIP_CUST_PO_NO = ""
    '        HDR.PO_DATE = Global_Inc.FormatDate(.Rows(0).Item("po_date"))
    '        If .Rows(0).Item("partial_flag") = "0" Then
    '            HDR.PARTIAL_SHIPMENT = "X"
    '        End If
    '        HDR.EARLY_SHIP = "0001"
    '        If .Rows(0).Item("SOLDTO_ID") = "SAID" Then
    '            HDR.TAXDEL_CTY = "SG" : HDR.TAXDES_CTY = "ID"
    '        End If

    '    End With
    '    HDT.Rows.Add(HDR)
    '    '/Header
    '    'Detail
    '    For Each R As DataRow In dtDetail.Rows
    '        Dim DR As CreateSAPDOC.SalesOrder1.OrderLinesRow = DDT.NewRow
    '        With R
    '            DR.PART_Dlv = ""
    '            'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then
    '            If .Item("ORDER_LINE_TYPE") = 1 Then
    '                DR.HIGHER_LEVEL = "100"
    '            End If
    '            'End If
    '            DR.LINE_NO = .Item("Line_No")
    '            If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then
    '                DR.DELIVERY_GROUP = "10"
    '            End If
    '            If dtMaster.Rows(0).Item("SOLDTO_ID") = "SAID" Then
    '                DR.PLANT = .Item("DeliveryPlant")
    '            End If

    '            If Global_Inc.IsNumericItem(.Item("part_no")) Then
    '                DR.MATERIAL = "00000000" & .Item("part_no")
    '            Else
    '                DR.MATERIAL = replaceCartBTO(.Item("part_no"))
    '            End If
    '            DR.CUST_MATERIAL = .Item("CustMaterialNo") : DR.DMF_FLAG = .Item("DMF_Flag") : DR.QTY = .Item("qty")
    '            Dim rd As DateTime = Now
    '            If CDate(.Item("required_date")) > Now Then
    '                rd = CDate(.Item("required_date"))
    '            End If
    '            DR.REQ_DATE = rd.ToString("yyyy/MM/dd") : DR.PRICE = .Item("unit_price") : DR.CURRENCY = dtMaster.Rows(0).Item("currency")
    '            'ODM Spacial setting 

    '            If MyCartOrderBizDAL.isODMOrder(Order_No) Then
    '                DR.PLANT = "TWM3" : DR.ShipPoint = "TWH1"                    'DR.StorageLoc = "0018"
    '            End If
    '            'End ODM Spacial setting
    '        End With
    '        DDT.Rows.Add(DR)
    '    Next
    '    '/Detail

    '    'Text
    '    With dtMaster
    '        Dim TR1 As CreateSAPDOC.SalesOrder1.HeaderTextsRow = TDT.NewRow
    '        TR1.TEXT_ID = "0001" 'SALESNOTE
    '        TR1.LANG_ID = "EN" : TR1.TEXT_LINE = .Rows(0).Item("SALES_NOTE")

    '        Dim TR2 As CreateSAPDOC.SalesOrder1.HeaderTextsRow = TDT.NewRow
    '        TR2.TEXT_ID = "0002" 'EXNOTE
    '        TR2.LANG_ID = "EN" : TR2.TEXT_LINE = .Rows(0).Item("ORDER_NOTE")

    '        Dim TR3 As CreateSAPDOC.SalesOrder1.HeaderTextsRow = TDT.NewRow
    '        TR3.TEXT_ID = "ZEOP" 'OPNOTE
    '        TR3.LANG_ID = "EN" : TR3.TEXT_LINE = .Rows(0).Item("OP_NOTE")

    '        Dim TR4 As CreateSAPDOC.SalesOrder1.HeaderTextsRow = TDT.NewRow
    '        TR4.TEXT_ID = "ZPRJ" 'PRJNOTE
    '        TR4.LANG_ID = "EN" : TR4.TEXT_LINE = .Rows(0).Item("prj_NOTE")
    '        TDT.Rows.Add(TR1) : TDT.Rows.Add(TR2) : TDT.Rows.Add(TR3) : TDT.Rows.Add(TR4)
    '    End With
    '    '/Text
    '    'Partner
    '    With dtMaster
    '        Dim PR1 As CreateSAPDOC.SalesOrder1.PartnerFuncRow = PDT.NewRow
    '        PR1.ROLE = "AG" : PR1.NUMBER = .Rows(0).Item("soldto_id").ToString.ToUpper : PDT.Rows.Add(PR1)

    '        Dim PR2 As CreateSAPDOC.SalesOrder1.PartnerFuncRow = PDT.NewRow
    '        PR2.ROLE = "WE" : PR2.NUMBER = .Rows(0).Item("shipto_id").ToString.ToUpper : PDT.Rows.Add(PR2)

    '        If .Rows(0).Item("ER_EMPLOYEE") <> "" Then
    '            Dim PR3 As CreateSAPDOC.SalesOrder1.PartnerFuncRow = PDT.NewRow
    '            PR3.ROLE = "ZM" : PR3.NUMBER = .Rows(0).Item("ER_EMPLOYEE") : PDT.Rows.Add(PR3)
    '        End If

    '        If .Rows(0).Item("END_CUST") <> "" Then
    '            Dim PR4 As CreateSAPDOC.SalesOrder1.PartnerFuncRow = PDT.NewRow
    '            PR4.ROLE = "EM" : PR4.NUMBER = .Rows(0).Item("END_CUST") : PDT.Rows.Add(PR4)
    '        End If

    '        If .Rows(0).Item("EMPLOYEEID") <> "" Then
    '            Dim PR5 As CreateSAPDOC.SalesOrder1.PartnerFuncRow = PDT.NewRow
    '            PR5.ROLE = "VE" : PR5.NUMBER = .Rows(0).Item("EMPLOYEEID") : PDT.Rows.Add(PR5)
    '        End If
    '    End With
    '    '/Partner
    '    'Condition
    '    For Each R As DataRow In dtFt.Rows
    '        Dim conLine As CreateSAPDOC.SalesOrder1.ConditionRow = CODT.NewRow
    '        With R
    '            conLine.TYPE = .Item("ftype") : conLine.VALUE = .Item("fvalue") : conLine.CURRENCY = dtMaster.Rows(0).Item("currency")
    '        End With
    '        CODT.Rows.Add(conLine)
    '    Next

    '    '/Condition
    '    Dim RDT As New DataTable
    '    RDT.TableName = "RDTABLE"
    '    Dim WS As New CreateSAPDOC.CreatSAPDOC
    '    WS.Timeout = -1
    '    Dim B As Boolean = False
    '    Dim REFORDERNO As String = Order_No
    '    If dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR2" Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR" Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR6" Then
    '        B = WS.CreateSO1(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, Nothing, RDT)
    '    ElseIf dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "AG" Then
    '        B = WS.CreateQuotation1(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
    '    Else
    '        ErrMsg = "DOC TYPE ERR!"
    '        Return False
    '    End If
    '    WS.Dispose()
    '    'OrderUtilities.showDT(RDT) : HttpContext.Current.Response.End()
    '    If B Then IB = 1
    '    ProcStatus_Save(RDT, Order_No, IB)
    '    'Catch ex As Exception
    '    '    ErrMsg = ex.ToString()
    '    '    Return False
    '    'End Try
    '    If IB = 1 Then
    '        Return True
    '    Else
    '        Return False
    '    End If
    'End Function
    Public Shared Function SOCreateV5(ByVal Order_No As String, ByRef ErrMsg As String, Optional ByVal isSimulate As Boolean = False, Optional ByVal QuoteID As String = "", Optional ByVal IsCreateSAPQuote As Boolean = False) As Boolean
        Dim IB As Integer = 0
        Dim myOrderMaster As New order_Master("B2B", "Order_Master"), myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim my_Company As New SAP_Company("b2b", "sap_dimcompany"), myFt As New Freight("b2b", "Freight")
        Dim LocalTime As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_No), ""), dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_No")
        Dim dtFt As DataTable = myFt.GetDT(String.Format("order_id='{0}'", Order_No), "")
        If dtMaster.Rows.Count = 0 Or dtDetail.Rows.Count = 0 Then
            ErrMsg = "RAW DATA ERROR!"
            ProcStatus_Save2(ErrMsg, Order_No, "TablesMD")
            Return False
        End If

        Dim HDT As New SAPDAL.SalesOrder.OrderHeaderDataTable, DDT As New SAPDAL.SalesOrder.OrderLinesDataTable, PDT As New SAPDAL.SalesOrder.PartnerFuncDataTable
        Dim TDT As New SAPDAL.SalesOrder.HeaderTextsDataTable, CODT As New SAPDAL.SalesOrder.ConditionDataTable, CDT As New SAPDAL.SalesOrder.CreditCardDataTable
        'Header
        Dim HDR As SAPDAL.SalesOrder.OrderHeaderRow = HDT.NewRow
        Dim soldtoID As String = String.Empty
        With dtMaster
            soldtoID = .Rows(0).Item("soldto_id")
            Dim DTcompany As DataTable = my_Company.GetDT(String.Format("company_id='{0}'", soldtoID), "")
            '\Ming add 2013-11-19 如果当前companyid搜索不到，就及时再同步一次
            Try
                If DTcompany.Rows.Count = 0 Then
                    Dim _errMsg As String = String.Empty
                    'Dim SC As New SAPDAL.syncSingleCompany
                    Dim CL As New ArrayList
                    CL.Add(soldtoID)
                    SAPDAL.syncSingleCompany.syncSingleSAPCustomer(CL, False, ErrMsg)
                    DTcompany = my_Company.GetDT(String.Format("company_id='{0}'", soldtoID), "")
                End If
            Catch ex As Exception
            End Try
            '/end
            If DTcompany.Rows.Count = 0 Then
                ErrMsg = "Invalid SoldTo!"
                ProcStatus_Save2(ErrMsg, Order_No, "S")
                Return False
            End If
            Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id")), distr_chan As String = "10", division As String = "00"
            SAPDOC.Get_disChannel_and_division(soldtoID, distr_chan, division)
            HDR.ORDER_TYPE = .Rows(0).Item("Order_Type") : HDR.SALES_ORG = sales_org : HDR.DIST_CHAN = distr_chan : HDR.DIVISION = division
            If IsCreateSAPQuote Then
                HDR.ORDER_TYPE = "AG"
                If Util.IsTestingQuote2Order() Then
                    Dim MyDC As New eQuotationDBDataContext
                    Dim CurrVersion As Object = (From QMlist In MyDC.QuotationMasters
                                                 Where QMlist.quoteNo = QuoteID AndAlso QMlist.Active = True
                                                 Select QMlist.Revision_Number).FirstOrDefault()
                    If CurrVersion IsNot Nothing AndAlso Not String.IsNullOrEmpty(CurrVersion) Then
                        HDR.VERSION = QuoteID + "V" + CurrVersion.ToString.Trim
                    End If
                End If
            Else
                'If String.Equals(sales_org, "TW01", StringComparison.CurrentCultureIgnoreCase) Then
                Dim _CartMaster As CartMaster = MyCartX.GetCartMaster(HttpContext.Current.Session("CART_ID").ToString.Trim)
                If Not IsNothing(_CartMaster) AndAlso _CartMaster.OpportunityID IsNot Nothing Then
                    HDR.VERSION = _CartMaster.OpportunityID
                End If
                'End If
            End If
            If Not String.IsNullOrEmpty(.Rows(0).Item("DIST_CHAN").ToString()) Then
                HDR.DIST_CHAN = .Rows(0).Item("DIST_CHAN").ToString() : HDR.DIVISION = .Rows(0).Item("DIVISION").ToString()
                HDR.SalesGroup = .Rows(0).Item("SALESGROUP").ToString() : HDR.SalesOffice = .Rows(0).Item("SALESOFFICE").ToString()
            End If
            HDR.INCO1 = .Rows(0).Item("INCOTERM")
            Dim INCO2 As String = "blank"
            If .Rows(0).Item("INCOTERM_TEXT") <> "" Then INCO2 = .Rows(0).Item("INCOTERM_TEXT")
            HDR.INCO2 = INCO2
            Dim Company_Country As String = ""
            If DTcompany.Rows(0).Item("COUNTRY_NAME") IsNot DBNull.Value Then Company_Country = DTcompany.Rows(0).Item("COUNTRY_NAME")
            If Company_Country.ToUpper = "NL" Then
                HDR.SHIPTO_COUNTRY = Company_Country.ToUpper : HDR.TRIANGULAR_INDICATOR = "X"
            End If
            If String.IsNullOrEmpty(.Rows(0).Item("PAYTERM").ToString()) = False Then
                HDR.PAYTERM = UCase(.Rows(0).Item("PAYTERM").ToString())
            End If
            HDR.TAX_CLASS = ""
            Dim rd As DateTime = LocalTime
            If CDate(.Rows(0).Item("required_date")) > rd Then
                rd = CDate(.Rows(0).Item("required_date"))
            End If
            HDR.REQUIRE_DATE = rd.ToString("yyyy/MM/dd") : HDR.SHIP_CONDITION = Left(.Rows(0).Item("SHIP_CONDITION"), 2)
            HDR.CUST_PO_NO = IIf(.Rows(0).Item("po_no") = "", Order_No, .Rows(0).Item("po_no")) : HDR.SHIP_CUST_PO_NO = ""
            HDR.PO_DATE = Global_Inc.FormatDate(.Rows(0).Item("po_date"))
            If .Rows(0).Item("partial_flag") = "0" Then HDR.PARTIAL_SHIPMENT = "X"
            HDR.EARLY_SHIP = "0001"
            If .Rows(0).Item("SOLDTO_ID") = "SAID" Then
                HDR.TAXDEL_CTY = "SG" : HDR.TAXDES_CTY = "ID"
            End If
            If Not IsDBNull(.Rows(0).Item("DISTRICT")) AndAlso .Rows(0).Item("DISTRICT") <> "" Then
                HDR.DISTRICT = .Rows(0).Item("DISTRICT").ToString
            End If
        End With
        If Not String.IsNullOrEmpty(QuoteID) AndAlso Not IsCreateSAPQuote Then
            HDR.Ref_Doc = QuoteID
        End If
        If Not String.IsNullOrEmpty(QuoteID) AndAlso isSimulate = True Then
            HDR.Ref_Doc = QuoteID
        End If
        If (Not dtMaster.Rows(0).Item("Created_By").ToString.ToLower.Contains("nada.liu")) AndAlso (Util.IsTesting() Or HttpContext.Current.Request.ServerVariables("SERVER_PORT").ToString() <> "80") Then
            HDR.DEST_TYPE = 1
        End If
        If dtMaster.Rows(0).Item("Created_By").ToString.ToLower.Contains("py.khor") Then
            HDR.DEST_TYPE = 0
        End If
        HDT.Rows.Add(HDR)
        '/Header
        'Detail
        For Each R As DataRow In dtDetail.Rows
            Dim DR As SAPDAL.SalesOrder.OrderLinesRow = DDT.NewRow
            With R
                DR.PART_Dlv = ""
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then
                If .Item("ORDER_LINE_TYPE") = 1 Then DR.HIGHER_LEVEL = "100"
                'End If
                DR.LINE_NO = .Item("Line_No")
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then DR.DELIVERY_GROUP = "10"
                'If dtMaster.Rows(0).Item("SOLDTO_ID") = "SAID" Then 
                If Not IsDBNull(.Item("DeliveryPlant")) AndAlso .Item("DeliveryPlant").ToString.Length > 0 Then
                    'DR.PLANT = .Item("DeliveryPlant")
                End If
                If Global_Inc.IsNumericItem(.Item("part_no")) Then
                    DR.MATERIAL = "00000000" & .Item("part_no")
                Else
                    DR.MATERIAL = replaceCartBTO(.Item("part_no"))
                End If
                If Not IsDBNull(.Item("Description")) Then
                    If Not .Item("Description").ToString.Trim.Length > 40 Then
                        DR.Description = .Item("Description").ToString.Trim
                    End If
                End If
                DR.CUST_MATERIAL = .Item("CustMaterialNo") : DR.DMF_FLAG = .Item("DMF_Flag") : DR.QTY = .Item("qty")
                Dim rd As DateTime = LocalTime
                If CDate(.Item("required_date")) > rd Then rd = CDate(.Item("required_date"))
                DR.REQ_DATE = rd.ToString("yyyy/MM/dd") : DR.PRICE = .Item("unit_price") : DR.CURRENCY = dtMaster.Rows(0).Item("currency")
                '\ 2013-8-26,MXT2****下單時，傳進SAP SO的part no的price传空值，为了就是能让SAP自动带出UUMM001的价格
                If Util.IsMexicoT2Customer(soldtoID, "") Then
                    DR.PRICE = "0"
                End If
                '/ end
                'ODM Spacial setting 
                If MyCartOrderBizDAL.isODMOrder(Order_No) Then
                    DR.PLANT = "TWM3" : DR.ShipPoint = "TWH1"
                    'DR.StorageLoc = "0018"
                End If
                'End ODM Spacial setting

                'Frank 2013/06/18: Set storage location to "1100" when creating sales order for SG01
                If UCase(HttpContext.Current.Session("Org_id")) = "SG01" Then
                    DR.StorageLoc = "1100"
                End If

            End With
            DDT.Rows.Add(DR)
        Next
        '/Detail

        'Text
        With dtMaster
            Dim TR1 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR2 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR3 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            Dim TR4 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR5 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            TR1.TEXT_ID = "0001" 'SALESNOTE
            TR1.LANG_ID = "EN" : TR1.TEXT_LINE = .Rows(0).Item("SALES_NOTE")
            TR2.TEXT_ID = "0002" 'EXNOTE
            TR2.LANG_ID = "EN" : TR2.TEXT_LINE = .Rows(0).Item("ORDER_NOTE")
            TR3.TEXT_ID = "ZEOP" 'OPNOTE
            TR3.LANG_ID = "EN" : TR3.TEXT_LINE = .Rows(0).Item("OP_NOTE")
            TR4.TEXT_ID = "ZPRJ" 'PRJNOTE
            TR4.LANG_ID = "EN" : TR4.TEXT_LINE = .Rows(0).Item("prj_NOTE")
            TR5.TEXT_ID = "ZBIL" 'Billing Instruction
            TR5.LANG_ID = "EN" : TR5.TEXT_LINE = .Rows(0).Item("BILLINGINSTRUCTION_INFO")
            TDT.Rows.Add(TR1) : TDT.Rows.Add(TR2) : TDT.Rows.Add(TR3) : TDT.Rows.Add(TR4) : TDT.Rows.Add(TR5)
            If Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD").ToString()) AndAlso Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString()) _
                AndAlso Date.TryParse(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString(), Now) Then
                CDT.AddCreditCardRow(.Rows(0).Item("CREDIT_CARD_HOLDER").ToString(), CDate(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString()).ToString("yyyyMMdd"),
                     .Rows(0).Item("CREDIT_CARD_TYPE").ToString(), .Rows(0).Item("CREDIT_CARD").ToString(), .Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString(), "", "", "")
            End If
        End With
        '/Text
        'Partner
        With dtMaster
            Dim PR1 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow, PR2 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow
            'ming get value from OrderPartners
            Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
            Dim OPdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(Order_No)
            If OPdt.Rows.Count = 0 Then
                ErrMsg = "Order without partner info"
                ProcStatus_Save2(ErrMsg, Order_No, "ORDER_PARTNERS")
                Return False
            End If
            Dim TempSOLDTO As String = String.Empty, TempB As String = String.Empty, KeyInPerson As String = String.Empty
            Dim ParentCompany As String = String.Empty
            For Each op As MyOrderDS.ORDER_PARTNERSRow In OPdt
                Dim PR As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow()
                PR.NUMBER = op.ERPID.ToUpper.Trim
                If op.TYPE.Equals("SOLDTO", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "AG"
                    TempSOLDTO = op.ERPID.ToUpper.Trim
                    '\2013-8-26,MXT2****在MyAdvantech下單時，傳進SAP SO的sold to要替換成UUMM001，其他參數都維持一樣
                    If Util.IsMexicoT2Customer(op.ERPID.ToUpper.Trim, ParentCompany) Then
                        PR.NUMBER = ParentCompany
                    End If
                    '/end
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("S", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "WE"
                    '\2013-8-26,MXT2****在MyAdvantech下單時，傳進SAP SO的sold to要替換成UUMM001，其他參數都維持一樣
                    If Util.IsMexicoT2Customer(op.ERPID.ToUpper.Trim, ParentCompany) Then
                        PR.NUMBER = ParentCompany
                    End If
                    '/end
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("B", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "RE"
                    TempB = op.ERPID.ToUpper.Trim
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "VE"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E2", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "Z2"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E3", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "Z3"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("KIP", StringComparison.OrdinalIgnoreCase) Then
                    KeyInPerson = op.ERPID.ToUpper.Trim
                ElseIf op.TYPE.Equals("EM", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "EM"
                    PDT.Rows.Add(PR)
                End If
                PDT.AcceptChanges()
            Next
            If Not String.IsNullOrEmpty(TempB) AndAlso Not String.IsNullOrEmpty(TempSOLDTO) Then ' AndAlso TempB <> TempSOLDTO Then
                Dim PR As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow()
                PR.NUMBER = TempB
                PR.ROLE = "RG"
                PDT.Rows.Add(PR)
                PDT.AcceptChanges()
            End If
            'Dim KeyInPerson As String = SAPDOC.GetKeyInPerson(dtMaster.Rows(0).Item("CREATED_BY").ToString)
            If Not String.IsNullOrEmpty(KeyInPerson) Then
                Dim PR6 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR6.ROLE = "ZR" : PR6.NUMBER = KeyInPerson : PDT.Rows.Add(PR6)
            End If
            If .Rows(0).Item("ER_EMPLOYEE") <> "" Then
                Dim PR3 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR3.ROLE = "ZM" : PR3.NUMBER = .Rows(0).Item("ER_EMPLOYEE") : PDT.Rows.Add(PR3)
            End If
            If .Rows(0).Item("END_CUST") <> "" Then
                Dim PR4 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR4.ROLE = "EM" : PR4.NUMBER = .Rows(0).Item("END_CUST") : PDT.Rows.Add(PR4)
            End If
            ' ming end
            'PR1.ROLE = "AG" : PR1.NUMBER = .Rows(0).Item("soldto_id").ToString.ToUpper : PDT.Rows.Add(PR1)
            'PR2.ROLE = "WE" : PR2.NUMBER = .Rows(0).Item("shipto_id").ToString.ToUpper : PDT.Rows.Add(PR2)

            'If .Rows(0).Item("EMPLOYEEID") <> "" Then
            '    Dim PR5 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR5.ROLE = "VE" : PR5.NUMBER = .Rows(0).Item("EMPLOYEEID") : PDT.Rows.Add(PR5)
            'End If
            'If Not IsDBNull(.Rows(0).Item("BILLTO_ID")) AndAlso .Rows(0).Item("BILLTO_ID").ToString <> "" AndAlso _
            '   Not .Rows(0).Item("BILLTO_ID").ToString.Trim.Equals(.Rows(0).Item("soldto_id").ToString, StringComparison.OrdinalIgnoreCase) Then
            '    Dim PR7 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR7.ROLE = "RE" : PR7.NUMBER = .Rows(0).Item("BILLTO_ID") : PDT.Rows.Add(PR7)
            'End If
        End With
        '/Partner
        'Condition
        For Each R As DataRow In dtFt.Rows
            Dim conLine As SAPDAL.SalesOrder.ConditionRow = CODT.NewRow
            With R
                conLine.TYPE = .Item("ftype") : conLine.VALUE = .Item("fvalue") : conLine.CURRENCY = dtMaster.Rows(0).Item("currency")
            End With
            CODT.Rows.Add(conLine)
        Next

        '/Condition
        Dim RDT As New DataTable : RDT.TableName = "RDTABLE"
        Dim WS As New SAPDAL.SAPDAL

        Dim B As Boolean = False
        Dim REFORDERNO As String = Order_No
        If IsCreateSAPQuote Then
            Dim Temp_QuoteID As String = QuoteID
            B = WS.CreateQuotation(QuoteID, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
            If B = False Then
                'Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Create SAP Quote Failed:" + Temp_QuoteID, ErrMsg, True, "", "")
                ProcStatus_Save(RDT, Temp_QuoteID, IB, "AG")
                SAPDOC.SendFailedOrderMail(QuoteID, Order_No)
            End If
            Return B
        End If
        If dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR2" Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR" _
            Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR6" Then
            If isSimulate Then
                B = WS.SimulateSO("SIMSO", ErrMsg, HDT, DDT, PDT, CODT, TDT, CDT, RDT, LocalTime)
            Else
                B = WS.CreateSO(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, CDT, RDT, LocalTime)
            End If
        ElseIf dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "AG" Then
            'B = WS.CreateQuotation(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
        Else
            ErrMsg = "DOC TYPE ERR!"
            Return False
        End If
        WS.Dispose()
        'OrderUtilities.showDT(RDT) : HttpContext.Current.Response.End()
        If B Then IB = 1
        ProcStatus_Save(RDT, Order_No, IB, dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper)
        'Catch ex As Exception
        '    ErrMsg = ex.ToString()
        '    Return False
        'End Try
        If IB = 1 Then
            Return True
        Else
            Return False
        End If
    End Function
    ''' <summary>
    ''' 
    ''' </summary>
    ''' <param name="Order_No"></param>
    ''' <param name="ErrMsg"></param>
    ''' <param name="isSimulate"></param>
    ''' <param name="QuoteID"></param>
    ''' <param name="IsCreateSAPQuote"></param>
    ''' <returns></returns>
    ''' <remarks></remarks>
    Public Shared Function SOCreateV6(ByVal Order_No As String, ByRef ErrMsg As String, Optional ByVal isSimulate As Boolean = False, Optional ByVal QuoteID As String = "", Optional ByVal IsCreateSAPQuote As Boolean = False) As Boolean
        Dim IB As Integer = 0
        Dim myOrderMaster As New order_Master("B2B", "Order_Master"), myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim my_Company As New SAP_Company("b2b", "sap_dimcompany"), myFt As New Freight("b2b", "Freight")
        Dim LocalTime As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_No), ""), dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_No")
        Dim dtFt As DataTable = myFt.GetDT(String.Format("order_id='{0}'", Order_No), "")
        Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id"))
        If dtMaster.Rows.Count = 0 Or dtDetail.Rows.Count = 0 Then
            ErrMsg = "RAW DATA ERROR!"
            ProcStatus_Save2(ErrMsg, Order_No, "TablesMD")
            Return False
        End If
        Dim _currency As String = String.Empty
        If dtMaster.Rows(0).Item("currency") IsNot Nothing Then
            _currency = dtMaster.Rows(0).Item("currency")
        End If
        Dim HDT As New SAPDAL.SalesOrder.OrderHeaderDataTable, DDT As New SAPDAL.SalesOrder.OrderLinesDataTable, PDT As New SAPDAL.SalesOrder.PartnerFuncDataTable
        Dim TDT As New SAPDAL.SalesOrder.HeaderTextsDataTable, CODT As New SAPDAL.SalesOrder.ConditionDataTable, CDT As New SAPDAL.SalesOrder.CreditCardDataTable
        'Header
        Dim HDR As SAPDAL.SalesOrder.OrderHeaderRow = HDT.NewRow
        Dim soldtoID As String = String.Empty

        Dim _IsUS01ORG As Boolean = False, USCompanyNextWorkingDate As Date, IsBTOSOrder As Boolean = MyOrderX.IsHaveBtos(Order_No)
        If HttpContext.Current.Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            _IsUS01ORG = True
            USCompanyNextWorkingDate = MyCartOrderBizDAL.getCompNextWorkDateV2(LocalTime, HttpContext.Current.Session("org_id"), 1)
        End If


        With dtMaster
            soldtoID = .Rows(0).Item("soldto_id")
            Dim DTcompany As DataTable = my_Company.GetDT(String.Format("company_id='{0}'", soldtoID), "")
            If DTcompany.Rows.Count = 0 Then
                ErrMsg = "Invalid SoldTo!"
                ProcStatus_Save2(ErrMsg, Order_No, "S")
                Return False
            End If
            Dim distr_chan As String = "10", division As String = "00"
            SAPDOC.Get_disChannel_and_division(soldtoID, distr_chan, division)
            HDR.ORDER_TYPE = .Rows(0).Item("Order_Type") : HDR.SALES_ORG = sales_org : HDR.DIST_CHAN = distr_chan : HDR.DIVISION = division
            HDR.Currency = _currency
            If IsCreateSAPQuote Then
                HDR.ORDER_TYPE = "AG"
                If Util.IsTestingQuote2Order() Then
                    Dim MyDC As New eQuotationDBDataContext
                    Dim CurrVersion As Object = (From QMlist In MyDC.QuotationMasters
                                                 Where QMlist.quoteNo = QuoteID AndAlso QMlist.Active = True
                                                 Select QMlist.Revision_Number).FirstOrDefault()
                    If CurrVersion IsNot Nothing AndAlso Not String.IsNullOrEmpty(CurrVersion) Then
                        HDR.VERSION = QuoteID + "V" + CurrVersion.ToString.Trim
                    End If
                End If
            Else
                'If Not IsNothing(HttpContext.Current.Session("OPTYID")) Then
                '    HDR.VERSION = HttpContext.Current.Session("OPTYID")
                'End If
                'If String.Equals(sales_org, "TW01", StringComparison.CurrentCultureIgnoreCase) Then
                Dim _CartMaster As CartMaster = MyCartX.GetCartMaster(HttpContext.Current.Session("CART_ID").ToString.Trim)
                If Not IsNothing(_CartMaster) AndAlso _CartMaster.OpportunityID IsNot Nothing AndAlso Not String.IsNullOrEmpty(_CartMaster.OpportunityID.Trim) Then
                    HDR.VERSION = _CartMaster.OpportunityID
                End If
                'End If
            End If
            If Not String.IsNullOrEmpty(.Rows(0).Item("DIST_CHAN").ToString()) Then
                HDR.DIST_CHAN = .Rows(0).Item("DIST_CHAN").ToString() : HDR.DIVISION = .Rows(0).Item("DIVISION").ToString()
                'HDR.SalesGroup = .Rows(0).Item("SALESGROUP").ToString() : HDR.SalesOffice = .Rows(0).Item("SALESOFFICE").ToString()
            End If

            'Ryan 20170511 ACN orders have to set sales_group and sales_office
            'ICC 2014/10/17 Only US order has to set sales_group and sales_office
            If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.StartsWith("US") OrElse HttpContext.Current.Session("ORG_ID").ToString.ToUpper.StartsWith("CN") Then
                HDR.SalesGroup = .Rows(0).Item("SALESGROUP").ToString() : HDR.SalesOffice = .Rows(0).Item("SALESOFFICE").ToString()
            End If

            HDR.INCO1 = .Rows(0).Item("INCOTERM")
            Dim INCO2 As String = "blank"
            If .Rows(0).Item("INCOTERM_TEXT") <> "" Then INCO2 = .Rows(0).Item("INCOTERM_TEXT")
            HDR.INCO2 = INCO2
            Dim Company_Country As String = ""
            If DTcompany.Rows(0).Item("COUNTRY_NAME") IsNot DBNull.Value Then Company_Country = DTcompany.Rows(0).Item("COUNTRY_NAME")
            If Company_Country.ToUpper = "NL" Then
                HDR.SHIPTO_COUNTRY = Company_Country.ToUpper : HDR.TRIANGULAR_INDICATOR = "X"
            End If
            If String.IsNullOrEmpty(.Rows(0).Item("PAYTERM").ToString()) = False Then
                HDR.PAYTERM = UCase(.Rows(0).Item("PAYTERM").ToString())
            End If

            'Frank 20140701: Control Order's taxable status 
            HDR.TAX_CLASS = ""
            If sales_org.ToUpper.StartsWith("US") Then
                HDR.TAX_CLASS = IIf(Integer.TryParse(.Rows(0).Item("isExempt"), 0) AndAlso CInt(.Rows(0).Item("isExempt")) = 1, 0, 1)

                If AuthUtil.IsBBUS Then
                    HDR.TAX_CLASS = IIf(Integer.TryParse(.Rows(0).Item("isExempt"), 0), .Rows(0).Item("isExempt"), 0)
                End If
            End If

            Dim rd As DateTime = LocalTime
            If CDate(.Rows(0).Item("required_date")) > rd Then
                rd = CDate(.Rows(0).Item("required_date"))
            End If

            '\Ming 20140929  检查页面停留时间过长，是不是已经过了13点。
            If _IsUS01ORG AndAlso Not IsBTOSOrder Then
                If DateDiff(DateInterval.Day, CDate(LocalTime.ToString("yyyy/MM/dd")), rd) <= 0 Then
                    If LocalTime.Hour >= 13 Then
                        rd = USCompanyNextWorkingDate.ToString("yyyy/MM/dd")
                    End If
                End If
            ElseIf AuthUtil.IsBBUS AndAlso Not IsBTOSOrder Then
                LocalTime = SAPDOC.GetLocalTime("BB") 'Get BBUS local time
                If DateDiff(DateInterval.Day, CDate(LocalTime.ToString("yyyy/MM/dd")), rd) <= 0 Then
                    If LocalTime.Hour >= 15 Then
                        rd = MyCartOrderBizDAL.getCompNextWorkDateV2(LocalTime, HttpContext.Current.Session("org_id"), 1)
                    End If
                End If
            End If

            HDR.REQUIRE_DATE = rd.ToString("yyyy/MM/dd") : HDR.SHIP_CONDITION = Left(.Rows(0).Item("SHIP_CONDITION"), 2)
            HDR.CUST_PO_NO = IIf(.Rows(0).Item("po_no") = "", Order_No, .Rows(0).Item("po_no")) : HDR.SHIP_CUST_PO_NO = ""
            HDR.PO_DATE = Global_Inc.FormatDate(.Rows(0).Item("po_date"))
            If .Rows(0).Item("partial_flag") = "0" Then HDR.PARTIAL_SHIPMENT = "X"

            'Ryan 20161018 Comment below code out due to new logic is applied in PartialDeliver.ascx
            'If HttpContext.Current.Session("org_id").ToString.Trim.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
            '    'Frank 20141002
            '    'If MyOrderX.IsHaveBtos(Order_No) Then HDR.PARTIAL_SHIPMENT = ""
            '    If IsBTOSOrder Then HDR.PARTIAL_SHIPMENT = ""
            'End If
            'End Comment out.

            HDR.EARLY_SHIP = "0001"
            If .Rows(0).Item("SOLDTO_ID") = "SAID" Then
                HDR.TAXDEL_CTY = "SG" : HDR.TAXDES_CTY = "ID"
            End If
            If Not IsDBNull(.Rows(0).Item("DISTRICT")) AndAlso .Rows(0).Item("DISTRICT") <> "" Then
                HDR.DISTRICT = .Rows(0).Item("DISTRICT").ToString
            End If
        End With
        If Not String.IsNullOrEmpty(QuoteID) AndAlso Not IsCreateSAPQuote Then
            HDR.Ref_Doc = QuoteID
        End If
        If Not String.IsNullOrEmpty(QuoteID) AndAlso isSimulate = True Then
            HDR.Ref_Doc = QuoteID
        End If
        If Util.IsTesting() Then
            HDR.DEST_TYPE = 1
        End If
        If dtMaster.Rows(0).Item("Created_By").ToString.ToLower.Contains("py.khor") Then
            HDR.DEST_TYPE = 0
        End If

        '20150326 TC: apply delivery block 20 (Verify BTO Config.) for AJP BTOS order if component is manually added to cart
        If HDR.SALES_ORG = "JP01" Then
            For Each R As DataRow In dtDetail.Rows
                If R.Item("ORDER_LINE_TYPE") = 1 Then
                    If Not IsDBNull(R.Item("HigherLevel")) AndAlso Integer.TryParse(R.Item("HigherLevel"), 0) Then
                        'Component line
                        If R.Item("Cate") Is DBNull.Value OrElse String.IsNullOrEmpty(Trim(R.Item("Cate").ToString())) _
                            OrElse String.Equals(R.Item("Cate").ToString(), "OTHERS", StringComparison.CurrentCultureIgnoreCase) Then
                            'If category is empty that means it's not transferred from eConfigurator, therefore must be manually added to cart by sales
                            '20150327 TC: Jack.Tsao doesn't need this block anymore, comment it first
                            'HDR.DLV_BLOCK = "20"
                            Exit For
                        End If
                    End If
                End If
            Next
        End If

        HDT.Rows.Add(HDR)
        '/Header
        'Detail
        'Dim sORG As String = UCase(HttpContext.Current.Session("Org_id"))
        'Dim carts As List(Of CartItem) = Nothing
        'If String.Equals(sales_org, "US01") AndAlso HttpContext.Current.Session("CART_ID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(HttpContext.Current.Session("CART_ID").ToString().Trim()) Then
        '    Dim currCartID As String = HttpContext.Current.Session("CART_ID").ToString.Trim
        '    carts = MyCartX.GetCartList(currCartID)
        '    If carts IsNot Nothing Then
        '        carts = carts.Where(Function(p) p.RecyclingFee.Value > 0).ToList()
        '    End If
        'End If


        'Ryan 20170216 Check AJP BTOS Order is AGS-CTOS-SYS-A or AGS-CTOS-SYS-B to decide further process
        Dim AJPBTOS_ZTM6 As Boolean = False
        If sales_org.Equals("JP01") AndAlso IsBTOSOrder AndAlso Advantech.Myadvantech.Business.OrderBusinessLogic.GetAJPOrderItemCategory(Order_No).Equals("ZTM6", StringComparison.OrdinalIgnoreCase) Then
            AJPBTOS_ZTM6 = True
        End If

        'Ming add 20150410 母階default plant並把子階的plant設定成跟母階一樣即可
        Dim ParentPlant As String = String.Empty
        For Each R As DataRow In dtDetail.Rows
            ParentPlant = String.Empty
            Dim DR As SAPDAL.SalesOrder.OrderLinesRow = DDT.NewRow
            With R
                DR.PART_Dlv = ""
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then
                If .Item("ORDER_LINE_TYPE") = 1 Then
                    If Not IsDBNull(.Item("HigherLevel")) AndAlso Integer.TryParse(.Item("HigherLevel"), 0) Then
                        DR.HIGHER_LEVEL = .Item("HigherLevel").ToString()
                    Else
                        DR.HIGHER_LEVEL = "100"
                    End If
                End If
                If .Item("ORDER_LINE_TYPE") = -1 Then
                    ParentPlant = .Item("DeliveryPlant")
                End If
                'End If
                DR.LINE_NO = .Item("Line_No")
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then DR.DELIVERY_GROUP = "10"
                'If dtMaster.Rows(0).Item("SOLDTO_ID") = "SAID" Then 
                If Not IsDBNull(.Item("DeliveryPlant")) AndAlso .Item("DeliveryPlant").ToString.Length > 0 Then
                    DR.PLANT = .Item("DeliveryPlant")
                    If .Item("ORDER_LINE_TYPE") = 1 Then
                        DR.PLANT = ParentPlant
                    End If
                End If
                If Global_Inc.IsNumericItem(.Item("part_no")) Then
                    'Ryan 20161117 Use Format2SAPItem instead of adding "00000000" to prevent error
                    DR.MATERIAL = Global_Inc.Format2SAPItem(.Item("part_no"))
                Else
                    'Frank 20150806 There is no need to change parent part number to virtual part number
                    If CInt(.Item("ORDER_LINE_TYPE")) = OrderItemType.BtosParent _
                        AndAlso Not sales_org.StartsWith("TW", StringComparison.InvariantCultureIgnoreCase) Then

                        ' DR.MATERIAL = replaceCartBTO(.Item("part_no"))
                        'Ming 20150306 统一使用SAPDAL里面的replace功能
                        DR.MATERIAL = SAPDAL.SAPDAL.replaceCartBTO(.Item("part_no"), HttpContext.Current.Session("org_id").ToString.Trim())
                    Else
                        DR.MATERIAL = .Item("part_no")
                    End If
                End If
                If Not IsDBNull(.Item("Description")) Then
                    If Not .Item("Description").ToString.Trim.Length > 40 Then
                        DR.Description = .Item("Description").ToString.Trim
                    End If
                End If
                DR.CUST_MATERIAL = .Item("CustMaterialNo") : DR.DMF_FLAG = .Item("DMF_Flag") : DR.QTY = .Item("qty")
                Dim rd As DateTime = LocalTime
                If CDate(.Item("required_date")) > rd Then rd = CDate(.Item("required_date"))
                DR.REQ_DATE = rd.ToString("yyyy/MM/dd") : DR.PRICE = .Item("unit_price") : DR.CURRENCY = dtMaster.Rows(0).Item("currency")

                '\Ming 20150601 针对US01: SO's UnintPrice = Cart’s UnintPrice - RecyclingFee
                'If carts IsNot Nothing AndAlso carts.Count > 0 AndAlso Integer.TryParse(.Item("Line_No"), 0) Then
                '    Dim currLineNo As Integer = Integer.Parse(.Item("Line_No"))
                '    Dim currCartItem As CartItem = carts.FirstOrDefault(Function(p) p.Line_No = currLineNo)
                '    If currCartItem IsNot Nothing Then
                '        DR.PRICE = .Item("unit_price") - currCartItem.RecyclingFee.Value
                '    End If
                'End If
                '/end

                'Ryan 20180606 Set AEU BTOS Order parent item required date as 2025/12/31 per Michael Zoon's request
                '\ 20140825 欧洲Btos Parent Item FirstDate 设置成 2020-12-31
                If MyOrderX.IsEUBtosOrder(Order_No) Then
                    If CInt(.Item("ORDER_LINE_TYPE")) = OrderItemType.BtosParent Then
                        DR.REQ_DATE = "2020/12/31"
                    End If
                End If
                '/end
                '\Ming 20140929  检查页面停留时间过长，是不是已经过了13点。
                If _IsUS01ORG AndAlso Not IsBTOSOrder Then
                    If DateDiff(DateInterval.Day, CDate(LocalTime.ToString("yyyy/MM/dd")), CDate(DR.REQ_DATE)) <= 0 Then
                        If LocalTime.Hour >= 13 Then
                            DR.REQ_DATE = USCompanyNextWorkingDate.ToString("yyyy/MM/dd")
                        End If
                    End If
                ElseIf AuthUtil.IsBBUS AndAlso Not IsBTOSOrder Then
                    LocalTime = SAPDOC.GetLocalTime("BB") 'Get BBUS local time
                    If DateDiff(DateInterval.Day, CDate(LocalTime.ToString("yyyy/MM/dd")), CDate(DR.REQ_DATE)) <= 0 Then
                        If LocalTime.Hour >= 15 Then
                            DR.REQ_DATE = MyCartOrderBizDAL.getCompNextWorkDateV2(LocalTime, HttpContext.Current.Session("org_id"), 1)
                        End If
                    End If
                End If
                '/end
                '\ 2013-8-26,MXT2****下單時，傳進SAP SO的part no的price传空值，为了就是能让SAP自动带出UUMM001的价格
                If Util.IsMexicoT2Customer(soldtoID, "") Then
                    DR.PRICE = "0"
                End If
                '/ end
                'ODM Spacial setting 
                If MyCartOrderBizDAL.isODMOrder(Order_No) Then
                    DR.PLANT = "TWM3" : DR.ShipPoint = "TWH1"
                    'DR.StorageLoc = "0018"
                End If
                'End ODM Spacial setting

                'Ryan 20180706 Only set storage location for SG01 "Channel Partners"
                'Ryan 2016/06/13: Only set storage location for non-service part.
                'Frank 2013/06/18: Set storage location to "1100" when creating sales order for SG01
                If UCase(HttpContext.Current.Session("Org_id")) = "SG01" Then
                    If HttpContext.Current.Session("company_account_status") IsNot Nothing AndAlso Not String.IsNullOrEmpty(HttpContext.Current.Session("company_account_status")) AndAlso HttpContext.Current.Session("company_account_status").ToString.Equals("01- Channel Partner", StringComparison.OrdinalIgnoreCase) Then
                        If Not Advantech.Myadvantech.Business.PartBusinessLogic.IsServicePart(.Item("part_no"), HttpContext.Current.Session("org_id").ToString.Trim()) Then
                            DR.StorageLoc = "1100"
                        End If
                    End If
                End If

                'JJ 2014/2/26：當TW01/TW20的單子有968T開頭的料號時，將ZTB1塞入ItCa欄位
                If (sales_org = "TW01" OrElse sales_org = "TW20") AndAlso Left(UCase(.Item("part_no")), 4) = "968T" Then
                    DR.ItCa = "ZTB1"
                End If
                'ICC 2014/10/24 Check ItemCategoryGroup. If it is SAMM then set ItCa = ZTN3
                Dim icg As Object = dbUtil.dbExecuteScalar("MY", String.Format("select ITEM_CATEGORY_GROUP from SAP_PRODUCT_STATUS where PART_NO='{0}' and SALES_ORG='{1}'", .Item("part_no"), sales_org))
                If Not icg Is Nothing AndAlso icg.ToString = "SAMM" Then
                    DR.ItCa = "ZTN3"
                End If

                'Ryan 20170216 Special settings for AJP                
                If sales_org = "JP01" Then
                    '1. Set BTOS Parent Item Category = ZTM6
                    '2. Set Storage Location to 1500 for all parts except Service parts
                    If AJPBTOS_ZTM6 Then
                        If CInt(.Item("ORDER_LINE_TYPE")) = OrderItemType.BtosParent Then
                            DR.ItCa = "ZTM6"
                            'DR.StorageLoc = "1500"
                        Else
                            If CInt(.Item("ORDER_LINE_TYPE")) = OrderItemType.BtosPart Then
                                If Not Advantech.Myadvantech.Business.PartBusinessLogic.IsServicePart(.Item("part_no"), sales_org) Then
                                    DR.StorageLoc = "1500"
                                    'Ryan 20170218 If is JP01 and set storage location, must set plant as well.
                                    If Not IsDBNull(.Item("DeliveryPlant")) AndAlso .Item("DeliveryPlant").ToString.Length > 0 AndAlso String.IsNullOrEmpty(DR.PLANT) Then
                                        DR.PLANT = .Item("DeliveryPlant")
                                    End If
                                End If
                            End If
                        End If
                    End If

                    'Ryan 20170224 If price is zero and is Btos Part or Loose Items, set Item category to ZTN3
                    If CInt(.Item("ORDER_LINE_TYPE")) = OrderItemType.BtosPart OrElse CInt(.Item("ORDER_LINE_TYPE")) = OrderItemType.Part Then
                        If DR.PRICE = 0 AndAlso Not Advantech.Myadvantech.Business.PartBusinessLogic.IsServicePart(.Item("part_no"), sales_org) Then
                            DR.ItCa = "ZTN3"
                        End If
                    End If
                End If

                'Ryan 20170323 Special Settings for ACN
                '整機訂單-> Storage Location = 1000 for CN10-1000 & CN30, Storage Location = 2000 for CN10-2000
                '單品訂單-> Storage Location = 1000 for both CN10/CN30
                If sales_org.StartsWith("CN") Then
                    Dim isServicePart As Boolean = Advantech.Myadvantech.Business.PartBusinessLogic.IsServicePart(.Item("part_no"), sales_org)

                    'Delivery Plant Settings
                    Dim dlvPlant As String = String.Empty
                    If Not IsDBNull(.Item("DeliveryPlant")) AndAlso .Item("DeliveryPlant").ToString.Length > 0 AndAlso String.IsNullOrEmpty(DR.PLANT) Then
                        dlvPlant = .Item("DeliveryPlant")
                    Else
                        dlvPlant = DR.PLANT
                    End If

                    'Item Category Settings for Special Parts
                    If .Item("part_no").ToString.ToUpper.StartsWith("968C") Then
                        Dim MG As Object = dbUtil.dbExecuteScalar("MY", String.Format("Select top 1 MATERIAL_GROUP from SAP_PRODUCT where PART_NO = '{0}'", .Item("part_no")))
                        If Not MG Is Nothing AndAlso MG.ToString = "968MS/SW" Then
                            DR.ItCa = "ZTB1"
                        End If
                    End If

                    If sales_org.ToString.Equals("CN10") Then
                        If HttpContext.Current.Session("ACN_StorageLocation") Is Nothing Then
                            HttpContext.Current.Session("ACN_StorageLocation") = "1000"
                        End If
                        If HttpContext.Current.Session("ACN_StorageLocation").ToString().Equals("1000") Then
                            If Not isServicePart Then
                                DR.StorageLoc = "1000"
                                'DR.ShipPoint = "CNS1"
                            End If
                            DR.PLANT = dlvPlant
                        ElseIf HttpContext.Current.Session("ACN_StorageLocation").ToString().Equals("2000") Then
                            If Not isServicePart Then
                                DR.StorageLoc = "2000"
                                'DR.ShipPoint = "CNS2"
                            End If
                            DR.PLANT = dlvPlant
                        End If
                    ElseIf sales_org.ToString.Equals("CN30") Then
                        If Not isServicePart Then
                            DR.StorageLoc = "1000"
                            'DR.ShipPoint = "CNH3"
                        End If
                        DR.PLANT = dlvPlant
                    ElseIf sales_org.ToString.Equals("CN70") Then
                        If Not isServicePart Then
                            DR.StorageLoc = "1000"
                        End If
                        DR.PLANT = dlvPlant
                    End If
                End If

                'Ryan 20180627 Settings for AVN                
                If sales_org = "VN01" Then
                    If CInt(.Item("ORDER_LINE_TYPE")) = OrderItemType.BtosParent Then
                        If dtMaster.Rows(0).Item("REMARK").ToString.Equals("ACL") Then
                            'Asseble in ACL then set itca as ZTM6
                            DR.ItCa = "ZTM6"
                        Else
                            'Asseble in AVN then set itca as ZTM5
                            DR.ItCa = "ZTM5"
                        End If
                    End If
                End If

            End With
            DDT.Rows.Add(DR)
        Next
        '/Detail

        'Text
        With dtMaster
            Dim TR1 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR2 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR3 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            Dim TR4 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR5 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            TR1.TEXT_ID = "0001" 'SALESNOTE
            TR1.LANG_ID = "EN" : TR1.TEXT_LINE = .Rows(0).Item("SALES_NOTE") : TR1.LINE_ID = String.Empty
            TR2.TEXT_ID = "0002" 'EXNOTE
            TR2.LANG_ID = "EN" : TR2.TEXT_LINE = .Rows(0).Item("ORDER_NOTE") : TR2.LINE_ID = String.Empty
            TR3.TEXT_ID = "ZEOP" 'OPNOTE
            TR3.LANG_ID = "EN" : TR3.TEXT_LINE = .Rows(0).Item("OP_NOTE") : TR3.LINE_ID = String.Empty
            TR4.TEXT_ID = "ZPRJ" 'PRJNOTE
            TR4.LANG_ID = "EN" : TR4.TEXT_LINE = .Rows(0).Item("prj_NOTE") : TR4.LINE_ID = String.Empty
            TR5.TEXT_ID = "ZBIL" 'Billing Instruction
            TR5.LANG_ID = "EN" : TR5.TEXT_LINE = .Rows(0).Item("BILLINGINSTRUCTION_INFO") : TR5.LINE_ID = String.Empty
            TDT.Rows.Add(TR1) : TDT.Rows.Add(TR2) : TDT.Rows.Add(TR3) : TDT.Rows.Add(TR4) : TDT.Rows.Add(TR5)

            'Ryan 20180727 For ACN to input Quote Number to GP Approval Reason field.
            If AuthUtil.IsACN Then
                Dim _CartMaster As CartMaster = MyCartX.GetCartMaster(HttpContext.Current.Session("CART_ID").ToString.Trim)
                If Not IsNothing(_CartMaster) AndAlso _CartMaster.QuoteID IsNot Nothing AndAlso Not String.IsNullOrEmpty(_CartMaster.QuoteID.Trim) Then
                    Dim ACNQuoteNo As Object = dbUtil.dbExecuteScalar("EQ", String.Format("select top 1 quoteNo from QuotationMaster where quoteId = '{0}'", _CartMaster.QuoteID))
                    If ACNQuoteNo IsNot Nothing AndAlso Not String.IsNullOrEmpty(ACNQuoteNo.ToString) Then
                        Dim TRGPR As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
                        TRGPR.TEXT_ID = "Z002"
                        TRGPR.LANG_ID = "EN"
                        TRGPR.TEXT_LINE = ACNQuoteNo.ToString
                        TRGPR.LINE_ID = String.Empty
                        TDT.Rows.Add(TRGPR)
                    End If
                End If
            End If

            'Ryan 20180724 For ASG BTO item material text
            If AuthUtil.IsASG Then
                Dim dtASGText As DataTable = dbUtil.dbGetDataTable("MY", "select * from asg_btosinstruction where ID = '" + Order_No + "'")
                If dtASGText IsNot Nothing AndAlso dtASGText.Rows.Count > 0 Then
                    For Each drASGText As DataRow In dtASGText.Rows
                        Dim TRSGText As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
                        TRSGText.TEXT_ID = "0001"
                        TRSGText.LANG_ID = "EN"
                        TRSGText.TEXT_LINE = drASGText("Text").ToString
                        TRSGText.LINE_ID = drASGText("LineNo").ToString
                        TDT.Rows.Add(TRSGText)
                    Next
                End If
            End If

            'Ryan 20171019 BBUS Forwarder Service Text Field Settings
            If AuthUtil.IsBBUS Then
                Dim OFS As Advantech.Myadvantech.DataAccess.OrderForwarderService = Advantech.Myadvantech.DataAccess.MyAdvantechDAL.GetOrderForwarderServiceByOrderId(Order_No)
                If OFS IsNot Nothing Then
                    ' First Line for Carrier
                    Dim TRBBFS_1 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
                    TRBBFS_1.TEXT_ID = "ZFDS"
                    TRBBFS_1.LANG_ID = "EN"
                    TRBBFS_1.TEXT_LINE = "CARRIER " + IIf(String.IsNullOrEmpty(OFS.FreightOption), "", OFS.FreightOption)
                    TRBBFS_1.LINE_ID = String.Empty
                    TDT.Rows.Add(TRBBFS_1)

                    ' Second Line for FREIGHT CHARGE BY
                    Dim TRBBFS_2 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
                    TRBBFS_2.TEXT_ID = "ZFDS"
                    TRBBFS_2.LANG_ID = "EN"
                    TRBBFS_2.TEXT_LINE = "FREIGHT CHARGE BY: " + IIf(String.IsNullOrEmpty(OFS.FreightChargeBy), "", OFS.FreightChargeBy)
                    TRBBFS_2.LINE_ID = String.Empty
                    TDT.Rows.Add(TRBBFS_2)

                    ' Third Line for CUSTOM CHARGE BY
                    Dim TRBBFS_3 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
                    TRBBFS_3.TEXT_ID = "ZFDS"
                    TRBBFS_3.LANG_ID = "EN"
                    TRBBFS_3.TEXT_LINE = "CUSTOM CHARGE BY: " + IIf(String.IsNullOrEmpty(OFS.CustomChargeBy), "", OFS.CustomChargeBy)
                    TRBBFS_3.LINE_ID = String.Empty
                    TDT.Rows.Add(TRBBFS_3)
                End If
            End If

            If Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD").ToString()) AndAlso Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString()) _
                AndAlso Date.TryParse(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString(), Now) Then
                If AuthUtil.IsBBUS Then
                    Dim AUTH_REFNO As String = "", AUTH_CCNO As String = ""
                    Dim Authinfo As Object = dbUtil.dbExecuteScalar("MY", "select ROWID from ORDER_PARTNERS where ORDER_ID = '" + Order_No + "' and type = 'B_CC' ")
                    If Authinfo IsNot Nothing AndAlso Not String.IsNullOrEmpty(Authinfo) Then
                        If Authinfo.ToString.Contains("|") Then
                            AUTH_REFNO = Authinfo.ToString.Split("|")(0)
                            AUTH_CCNO = Authinfo.ToString.Split("|")(1)
                        End If
                    End If


                    Dim orderamount As Decimal = 0, taxamount As Decimal = 0, freightamount As Decimal = 0
                    ' Order amount
                    orderamount = .Rows(0).Item("TOTAL_AMOUNT")

                    ' Freight amount
                    Dim dtFreight As DataTable = myFt.GetDT(String.Format("order_id='{0}'", Order_No), "")
                    If dtFreight IsNot Nothing AndAlso dtFreight.Rows.Count > 0 AndAlso dtFreight.Rows(0) IsNot Nothing Then
                        Dim freight As Decimal = dtFreight.Rows(0).Item("fvalue")
                        freightamount += freight
                    End If

                    ' Tax amount
                    Dim MasterExtension As orderMasterExtensionV2 = MyUtil.Current.MyAContext.orderMasterExtensionV2s.Where(Function(p) p.ORDER_ID = Order_No).FirstOrDefault()
                    If MasterExtension IsNot Nothing Then
                        taxamount = Decimal.Round(orderamount * Decimal.Parse(MasterExtension.OrderTaxRate), 2, MidpointRounding.AwayFromZero)
                    End If

                    Dim totalauthamount As Decimal = orderamount + freightamount + taxamount


                    'Alex 20171221: hide credicard number and verify number before insert to SAP
                    .Rows(0).Item("CREDIT_CARD") = "************" + .Rows(0).Item("CREDIT_CARD").Substring(.Rows(0).Item("CREDIT_CARD").Length - 4, 4)
                    .Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER") = "N/A"

                    'ICC Update CardNo, CardType, Total auth amount in BB_CREDITCARD_ORDER table
                    Dim creditInfoCount As Object = dbUtil.dbExecuteScalar("MY", String.Format("select count(*) from BB_CREDITCARD_ORDER where ORDER_NO='{0}'", Order_No))
                    If creditInfoCount IsNot Nothing AndAlso Integer.Parse(creditInfoCount.ToString) > 0 Then
                        dbUtil.dbExecuteNoQuery("MY", String.Format("update BB_CREDITCARD_ORDER set CARD_NO=N'{0}',CARD_TYPE=N'{1}',TOTAL_AUTH_AMOUNT={2} where ORDER_NO='{3}'", .Rows(0).Item("CREDIT_CARD").ToString, .Rows(0).Item("CREDIT_CARD_TYPE").ToString(), totalauthamount, Order_No))
                    End If

                    CDT.AddCreditCardRow(.Rows(0).Item("CREDIT_CARD_HOLDER").ToString(), CDate(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString()).ToString("yyyyMMdd"),
                                         .Rows(0).Item("CREDIT_CARD_TYPE").ToString(), .Rows(0).Item("CREDIT_CARD").ToString(), .Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString(),
                                         AUTH_REFNO, AUTH_CCNO, totalauthamount.ToString())
                Else
                    CDT.AddCreditCardRow(.Rows(0).Item("CREDIT_CARD_HOLDER").ToString(), CDate(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString()).ToString("yyyyMMdd"),
                     .Rows(0).Item("CREDIT_CARD_TYPE").ToString(), .Rows(0).Item("CREDIT_CARD").ToString(), .Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString(), "", "", "")
                End If
            End If
        End With
        '/Text
        'Partner
        With dtMaster
            Dim PR1 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow, PR2 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow
            'ming get value from OrderPartners
            Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
            Dim OPdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(Order_No)
            If OPdt.Rows.Count = 0 Then
                ErrMsg = "Order without partner info"
                ProcStatus_Save2(ErrMsg, Order_No, "ORDER_PARTNERS")
                Return False
            End If
            Dim TempSOLDTO As String = String.Empty, TempB As String = String.Empty, KeyInPerson As String = String.Empty
            Dim ParentCompany As String = String.Empty
            For Each op As MyOrderDS.ORDER_PARTNERSRow In OPdt
                Dim PR As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow()
                PR.NUMBER = op.ERPID.ToUpper.Trim
                If op.TYPE.Equals("SOLDTO", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "AG"
                    TempSOLDTO = op.ERPID.ToUpper.Trim
                    '\2013-8-26,MXT2****在MyAdvantech下單時，傳進SAP SO的sold to要替換成UUMM001，其他參數都維持一樣
                    If Util.IsMexicoT2Customer(op.ERPID.ToUpper.Trim, ParentCompany) Then
                        PR.NUMBER = ParentCompany
                    End If
                    '/end
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("S", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "WE"
                    '\2013-8-26,MXT2****在MyAdvantech下單時，傳進SAP SO的sold to要替換成UUMM001，其他參數都維持一樣
                    If Util.IsMexicoT2Customer(op.ERPID.ToUpper.Trim, ParentCompany) Then
                        PR.NUMBER = ParentCompany
                    End If
                    '/end
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("B", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "RE"
                    TempB = op.ERPID.ToUpper.Trim
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "VE"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E2", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "Z2"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E3", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "Z3"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("KIP", StringComparison.OrdinalIgnoreCase) Then
                    KeyInPerson = op.ERPID.ToUpper.Trim
                ElseIf op.TYPE.Equals("EM", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "EM"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("ZM", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "ZM"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("ZA", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "ZA"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("ZB", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "ZB"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("ZP", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "ZP"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("ZQ", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "ZQ"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("RG", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "RG"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("AP", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "AP"
                    PDT.Rows.Add(PR)
                End If
                PDT.AcceptChanges()
            Next

            '-----Ryan 20171013 Comment below codes out-----
            'If Not String.IsNullOrEmpty(TempB) AndAlso Not String.IsNullOrEmpty(TempSOLDTO) Then ' AndAlso TempB <> TempSOLDTO Then
            '    Dim PR As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow()
            '    PR.NUMBER = TempB
            '    PR.ROLE = "RG"
            '    PDT.Rows.Add(PR)
            '    PDT.AcceptChanges()
            'End If
            '-----End 20171013 Comment out-----

            'Dim KeyInPerson As String = SAPDOC.GetKeyInPerson(dtMaster.Rows(0).Item("CREATED_BY").ToString)
            If Not String.IsNullOrEmpty(KeyInPerson) Then
                Dim PR6 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR6.ROLE = "ZR" : PR6.NUMBER = KeyInPerson : PDT.Rows.Add(PR6)
            End If
            If .Rows(0).Item("ER_EMPLOYEE") <> "" Then
                Dim PR3 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR3.ROLE = "ZM" : PR3.NUMBER = .Rows(0).Item("ER_EMPLOYEE") : PDT.Rows.Add(PR3)
            End If
            If .Rows(0).Item("END_CUST") <> "" Then
                Dim PR4 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR4.ROLE = "EM" : PR4.NUMBER = .Rows(0).Item("END_CUST") : PDT.Rows.Add(PR4)
            End If
            ' ming end
            'PR1.ROLE = "AG" : PR1.NUMBER = .Rows(0).Item("soldto_id").ToString.ToUpper : PDT.Rows.Add(PR1)
            'PR2.ROLE = "WE" : PR2.NUMBER = .Rows(0).Item("shipto_id").ToString.ToUpper : PDT.Rows.Add(PR2)

            'If .Rows(0).Item("EMPLOYEEID") <> "" Then
            '    Dim PR5 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR5.ROLE = "VE" : PR5.NUMBER = .Rows(0).Item("EMPLOYEEID") : PDT.Rows.Add(PR5)
            'End If
            'If Not IsDBNull(.Rows(0).Item("BILLTO_ID")) AndAlso .Rows(0).Item("BILLTO_ID").ToString <> "" AndAlso _
            '   Not .Rows(0).Item("BILLTO_ID").ToString.Trim.Equals(.Rows(0).Item("soldto_id").ToString, StringComparison.OrdinalIgnoreCase) Then
            '    Dim PR7 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR7.ROLE = "RE" : PR7.NUMBER = .Rows(0).Item("BILLTO_ID") : PDT.Rows.Add(PR7)
            'End If
        End With
        '/Partner
        'Condition
        For Each R As DataRow In dtFt.Rows
            Dim conLine As SAPDAL.SalesOrder.ConditionRow = CODT.NewRow
            With R
                conLine.TYPE = .Item("ftype") : conLine.VALUE = .Item("fvalue") : conLine.CURRENCY = dtMaster.Rows(0).Item("currency")
            End With
            CODT.Rows.Add(conLine)
        Next

        '/Condition
        Dim RDT As New DataTable : RDT.TableName = "RDTABLE"
        Dim WS As New SAPDAL.SAPDAL

        Dim B As Boolean = False
        Dim REFORDERNO As String = Order_No
        Dim OMExt As orderMasterExtensionV2 = MyOrderX.GetOrderMasterExtension(Order_No)
        Dim UpdateOrderNoFlag As Boolean = False
        If OMExt IsNot Nothing AndAlso OMExt.OrderNoScheme = 1 Then
            REFORDERNO = "" : UpdateOrderNoFlag = True
        End If
        If IsCreateSAPQuote Then
            Dim Temp_QuoteID As String = QuoteID
            B = WS.CreateQuotation(QuoteID, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
            If B = False Then
                'Util.SendEmail("eBusiness.AEU@advantech.eu,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "Create SAP Quote Failed:" + Temp_QuoteID, ErrMsg, True, "", "")
                ProcStatus_Save(RDT, Temp_QuoteID, IB, "AG")
                SAPDOC.SendFailedOrderMail(QuoteID, Order_No)
            End If
            Return B
        End If
        If dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR2" Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR" _
            Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR6" Then
            If isSimulate Then
                Dim sno As String = "DMO"
                Dim RNO As New Random
                sno &= RNO.Next(0, 9999999).ToString("0000000")
                B = WS.SimulateSO(sno, ErrMsg, HDT, DDT, PDT, CODT, TDT, CDT, RDT, LocalTime)
            Else
                B = WS.CreateSO(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, CDT, RDT, LocalTime)
            End If
        ElseIf dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "AG" Then
            'B = WS.CreateQuotation(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
        Else
            ErrMsg = "DOC TYPE ERR!"
            Return False
        End If
        WS.Dispose()
        If B AndAlso UpdateOrderNoFlag Then
            Dim NewOrderNo = SAPDAL.Global_Inc.RemovePrecedingZeros(REFORDERNO)
            Dim sb As StringBuilder = New StringBuilder()
            sb.AppendFormat(" update ORDER_MASTER set ORDER_ID ='{0}', ORDER_NO='{0}' WHERE ORDER_ID='{1}';", NewOrderNo, Order_No)
            sb.AppendFormat(" update  ORDER_DETAIL set ORDER_ID ='{0}' where ORDER_ID='{1}' ", NewOrderNo, Order_No)
            dbUtil.dbExecuteNoQuery("MY", sb.ToString())
            Order_No = NewOrderNo
        End If
        'OrderUtilities.showDT(RDT) : HttpContext.Current.Response.End()
        Dim ordertype As String = dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper
        If Not String.IsNullOrEmpty(ErrMsg.ToString.Trim) Then
            ErrMsg = "Internal Error occurred:  " + ErrMsg.ToString.Trim
            Util.InsertMyErrLog("Create SO Failed " + Order_No + ": " + ErrMsg)
            Dim A As New MyOrderDSTableAdapters.ORDER_PROC_STATUS2TableAdapter
            A.Insert(Order_No, 1, 1, ErrMsg, Now.Date, 0, ordertype)
        End If
        If B Then IB = 1
        ProcStatus_Save(RDT, Order_No, IB, ordertype)
        'Catch ex As Exception
        '    ErrMsg = ex.ToString()
        '    Return False
        'End Try
        If IB = 1 Then
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Function SOCreateV2(ByVal Order_No As String, ByRef ErrMsg As String) As Boolean
        Dim IB As Integer = 0
        Dim myOrderMaster As New order_Master("B2B", "Order_Master"), myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim my_Company As New SAP_Company("b2b", "sap_dimcompany"), myFt As New Freight("b2b", "Freight")
        Dim LocalTime As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_No), ""), dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_No")
        Dim dtFt As DataTable = myFt.GetDT(String.Format("order_id='{0}'", Order_No), "")
        If dtMaster.Rows.Count = 0 Or dtDetail.Rows.Count = 0 Then
            ErrMsg = "RAW DATA ERROR!" : Return False
        End If

        Dim HDT As New SAPDAL.SalesOrder.OrderHeaderDataTable, DDT As New SAPDAL.SalesOrder.OrderLinesDataTable, PDT As New SAPDAL.SalesOrder.PartnerFuncDataTable
        Dim TDT As New SAPDAL.SalesOrder.HeaderTextsDataTable, CODT As New SAPDAL.SalesOrder.ConditionDataTable, CDT As New SAPDAL.SalesOrder.CreditCardDataTable
        'Header
        Dim HDR As SAPDAL.SalesOrder.OrderHeaderRow = HDT.NewRow
        With dtMaster
            Dim soldtoID As String = .Rows(0).Item("soldto_id"), DTcompany As DataTable = my_Company.GetDT(String.Format("company_id='{0}'", soldtoID), "")
            If DTcompany.Rows.Count = 0 Then
                ErrMsg = "Invalid SoldTo!" : Return False
            End If
            Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id")), distr_chan As String = "10", division As String = "00"
            SAPDOC.Get_disChannel_and_division(soldtoID, distr_chan, division)
            HDR.ORDER_TYPE = .Rows(0).Item("Order_Type") : HDR.SALES_ORG = sales_org : HDR.DIST_CHAN = distr_chan : HDR.DIVISION = division
            If Not String.IsNullOrEmpty(.Rows(0).Item("DIST_CHAN").ToString()) Then
                HDR.DIST_CHAN = .Rows(0).Item("DIST_CHAN").ToString() : HDR.DIVISION = .Rows(0).Item("DIVISION").ToString()
                HDR.SalesGroup = .Rows(0).Item("SALESGROUP").ToString() : HDR.SalesOffice = .Rows(0).Item("SALESOFFICE").ToString()
            End If
            HDR.INCO1 = .Rows(0).Item("INCOTERM")
            Dim INCO2 As String = "blank"
            If .Rows(0).Item("INCOTERM_TEXT") <> "" Then INCO2 = .Rows(0).Item("INCOTERM_TEXT")
            HDR.INCO2 = INCO2
            Dim Company_Country As String = ""
            If DTcompany.Rows(0).Item("COUNTRY_NAME") IsNot DBNull.Value Then Company_Country = DTcompany.Rows(0).Item("COUNTRY_NAME")
            If Company_Country.ToUpper = "NL" Then
                HDR.SHIPTO_COUNTRY = Company_Country.ToUpper : HDR.TRIANGULAR_INDICATOR = "X"
            End If
            If String.IsNullOrEmpty(.Rows(0).Item("PAYTERM").ToString()) = False Then
                HDR.PAYTERM = UCase(.Rows(0).Item("PAYTERM").ToString())
            End If
            HDR.TAX_CLASS = ""
            Dim rd As DateTime = LocalTime
            If CDate(.Rows(0).Item("required_date")) > rd Then
                rd = CDate(.Rows(0).Item("required_date"))
            End If
            HDR.REQUIRE_DATE = rd.ToString("yyyy/MM/dd") : HDR.SHIP_CONDITION = Left(.Rows(0).Item("SHIP_CONDITION"), 2)
            HDR.CUST_PO_NO = IIf(.Rows(0).Item("po_no") = "", Order_No, .Rows(0).Item("po_no")) : HDR.SHIP_CUST_PO_NO = ""
            HDR.PO_DATE = Global_Inc.FormatDate(.Rows(0).Item("po_date"))
            If .Rows(0).Item("partial_flag") = "0" Then HDR.PARTIAL_SHIPMENT = "X"
            HDR.EARLY_SHIP = "0001"
            If .Rows(0).Item("SOLDTO_ID") = "SAID" Then
                HDR.TAXDEL_CTY = "SG" : HDR.TAXDES_CTY = "ID"
            End If
        End With
        If Util.IsTesting() Then
            HDR.DEST_TYPE = 1
        End If
        HDT.Rows.Add(HDR)
        '/Header
        'Detail
        For Each R As DataRow In dtDetail.Rows
            Dim DR As SAPDAL.SalesOrder.OrderLinesRow = DDT.NewRow
            With R
                DR.PART_Dlv = ""
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then
                If .Item("ORDER_LINE_TYPE") = 1 Then DR.HIGHER_LEVEL = "100"
                'End If
                DR.LINE_NO = .Item("Line_No")
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then DR.DELIVERY_GROUP = "10"
                If dtMaster.Rows(0).Item("SOLDTO_ID") = "SAID" Then DR.PLANT = .Item("DeliveryPlant")
                If Global_Inc.IsNumericItem(.Item("part_no")) Then
                    DR.MATERIAL = "00000000" & .Item("part_no")
                Else
                    DR.MATERIAL = replaceCartBTO(.Item("part_no"))
                End If
                DR.Description = .Item("Description")
                DR.CUST_MATERIAL = .Item("CustMaterialNo") : DR.DMF_FLAG = .Item("DMF_Flag") : DR.QTY = .Item("qty")
                Dim rd As DateTime = LocalTime
                If CDate(.Item("required_date")) > rd Then rd = CDate(.Item("required_date"))
                DR.REQ_DATE = rd.ToString("yyyy/MM/dd") : DR.PRICE = .Item("unit_price") : DR.CURRENCY = dtMaster.Rows(0).Item("currency")
                'ODM Spacial setting 

                If MyCartOrderBizDAL.isODMOrder(Order_No) Then
                    DR.PLANT = "TWM3" : DR.ShipPoint = "TWH1"
                    'DR.StorageLoc = "0018"
                End If
                'End ODM Spacial setting
            End With
            DDT.Rows.Add(DR)
        Next
        '/Detail

        'Text
        With dtMaster
            Dim TR1 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR2 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR3 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            Dim TR4 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR5 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            TR1.TEXT_ID = "0001" 'SALESNOTE
            TR1.LANG_ID = "EN" : TR1.TEXT_LINE = .Rows(0).Item("SALES_NOTE")
            TR2.TEXT_ID = "0002" 'EXNOTE
            TR2.LANG_ID = "EN" : TR2.TEXT_LINE = .Rows(0).Item("ORDER_NOTE")
            TR3.TEXT_ID = "ZEOP" 'OPNOTE
            TR3.LANG_ID = "EN" : TR3.TEXT_LINE = .Rows(0).Item("OP_NOTE")
            TR4.TEXT_ID = "ZPRJ" 'PRJNOTE
            TR4.LANG_ID = "EN" : TR4.TEXT_LINE = .Rows(0).Item("prj_NOTE")
            TR5.TEXT_ID = "ZBIL" 'Billing Instruction
            TR5.LANG_ID = "EN" : TR5.TEXT_LINE = .Rows(0).Item("BILLINGINSTRUCTION_INFO")
            TDT.Rows.Add(TR1) : TDT.Rows.Add(TR2) : TDT.Rows.Add(TR3) : TDT.Rows.Add(TR4) : TDT.Rows.Add(TR5)
            If Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD").ToString()) AndAlso Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString()) _
                AndAlso Date.TryParse(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString(), Now) Then
                CDT.AddCreditCardRow(.Rows(0).Item("CREDIT_CARD_HOLDER").ToString(), CDate(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString()).ToString("yyyyMMdd"),
                     .Rows(0).Item("CREDIT_CARD_TYPE").ToString(), .Rows(0).Item("CREDIT_CARD").ToString(), .Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString(), "", "", "")
            End If
        End With
        '/Text
        'Partner
        With dtMaster
            Dim PR1 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow, PR2 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow
            'ming get value from OrderPartners
            Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
            Dim OPdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(Order_No)
            Dim TempSOLDTO As String = String.Empty
            Dim TempB As String = String.Empty
            For Each op As MyOrderDS.ORDER_PARTNERSRow In OPdt
                Dim PR As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow()
                PR.NUMBER = op.ERPID
                If op.TYPE.Equals("SOLDTO", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "AG"
                    TempSOLDTO = op.ERPID
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("S", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "WE"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("B", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "RE"
                    TempB = op.ERPID
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "VE"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E2", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "Z2"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("E3", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "Z3"
                    PDT.Rows.Add(PR)
                End If
                PDT.AcceptChanges()
            Next
            If Not String.IsNullOrEmpty(TempB) AndAlso Not String.IsNullOrEmpty(TempSOLDTO) AndAlso TempB <> TempSOLDTO Then
                Dim PR As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow()
                PR.NUMBER = TempB
                PR.ROLE = "RG"
                PDT.Rows.Add(PR)
                PDT.AcceptChanges()
            End If
            Dim KeyInPerson As String = SAPDOC.GetKeyInPerson("")
            If Not String.IsNullOrEmpty(KeyInPerson) Then
                Dim PR6 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR6.ROLE = "ZR" : PR6.NUMBER = KeyInPerson : PDT.Rows.Add(PR6)
            End If
            If .Rows(0).Item("ER_EMPLOYEE") <> "" Then
                Dim PR3 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR3.ROLE = "ZM" : PR3.NUMBER = .Rows(0).Item("ER_EMPLOYEE") : PDT.Rows.Add(PR3)
            End If
            If .Rows(0).Item("END_CUST") <> "" Then
                Dim PR4 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR4.ROLE = "EM" : PR4.NUMBER = .Rows(0).Item("END_CUST") : PDT.Rows.Add(PR4)
            End If
            ' ming end
            'PR1.ROLE = "AG" : PR1.NUMBER = .Rows(0).Item("soldto_id").ToString.ToUpper : PDT.Rows.Add(PR1)
            'PR2.ROLE = "WE" : PR2.NUMBER = .Rows(0).Item("shipto_id").ToString.ToUpper : PDT.Rows.Add(PR2)

            'If .Rows(0).Item("EMPLOYEEID") <> "" Then
            '    Dim PR5 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR5.ROLE = "VE" : PR5.NUMBER = .Rows(0).Item("EMPLOYEEID") : PDT.Rows.Add(PR5)
            'End If
            'If Not IsDBNull(.Rows(0).Item("BILLTO_ID")) AndAlso .Rows(0).Item("BILLTO_ID").ToString <> "" AndAlso _
            '   Not .Rows(0).Item("BILLTO_ID").ToString.Trim.Equals(.Rows(0).Item("soldto_id").ToString, StringComparison.OrdinalIgnoreCase) Then
            '    Dim PR7 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR7.ROLE = "RE" : PR7.NUMBER = .Rows(0).Item("BILLTO_ID") : PDT.Rows.Add(PR7)
            'End If
        End With
        '/Partner
        'Condition
        For Each R As DataRow In dtFt.Rows
            Dim conLine As SAPDAL.SalesOrder.ConditionRow = CODT.NewRow
            With R
                conLine.TYPE = .Item("ftype") : conLine.VALUE = .Item("fvalue") : conLine.CURRENCY = dtMaster.Rows(0).Item("currency")
            End With
            CODT.Rows.Add(conLine)
        Next

        '/Condition
        Dim RDT As New DataTable : RDT.TableName = "RDTABLE"
        Dim WS As New SAPDAL.SAPDAL

        Dim B As Boolean = False
        Dim REFORDERNO As String = Order_No
        If dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR2" Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR" _
            Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR6" Then
            B = WS.CreateSO(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, CDT, RDT, LocalTime)
        ElseIf dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "AG" Then
            'B = WS.CreateQuotation1(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
        Else
            ErrMsg = "DOC TYPE ERR!"
            Return False
        End If
        WS.Dispose()
        'OrderUtilities.showDT(RDT) : HttpContext.Current.Response.End()
        If B Then IB = 1
        ProcStatus_Save(RDT, Order_No, IB)
        'Catch ex As Exception
        '    ErrMsg = ex.ToString()
        '    Return False
        'End Try
        If IB = 1 Then
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Function SOCreateV4(ByVal Order_No As String, ByRef dtMsg As DataTable, ByRef ErrMsg As String, ByVal isSimulate As Boolean) As Boolean
        Dim IB As Integer = 0
        Dim myOrderMaster As New order_Master("B2B", "Order_Master"), myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim my_Company As New SAP_Company("b2b", "sap_dimcompany"), myFt As New Freight("b2b", "Freight")
        Dim LocalTime As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_No), ""), dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_No")
        Dim dtFt As DataTable = myFt.GetDT(String.Format("order_id='{0}'", Order_No), "")
        If dtMaster.Rows.Count = 0 Or dtDetail.Rows.Count = 0 Then
            ErrMsg = "RAW DATA ERROR!" : Return False
        End If

        Dim HDT As New SAPDAL.SalesOrder.OrderHeaderDataTable, DDT As New SAPDAL.SalesOrder.OrderLinesDataTable, PDT As New SAPDAL.SalesOrder.PartnerFuncDataTable
        Dim TDT As New SAPDAL.SalesOrder.HeaderTextsDataTable, CODT As New SAPDAL.SalesOrder.ConditionDataTable, CDT As New SAPDAL.SalesOrder.CreditCardDataTable
        'Header
        Dim HDR As SAPDAL.SalesOrder.OrderHeaderRow = HDT.NewRow
        With dtMaster
            Dim soldtoID As String = .Rows(0).Item("soldto_id"), DTcompany As DataTable = my_Company.GetDT(String.Format("company_id='{0}'", soldtoID), "")
            If DTcompany.Rows.Count = 0 Then
                ErrMsg = "Invalid SoldTo!" : Return False
            End If
            Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id")), distr_chan As String = "10", division As String = "00"
            SAPDOC.Get_disChannel_and_division(soldtoID, distr_chan, division)
            HDR.ORDER_TYPE = .Rows(0).Item("Order_Type") : HDR.SALES_ORG = sales_org : HDR.DIST_CHAN = distr_chan : HDR.DIVISION = division
            If Not String.IsNullOrEmpty(.Rows(0).Item("DIST_CHAN").ToString()) Then
                HDR.DIST_CHAN = .Rows(0).Item("DIST_CHAN").ToString() : HDR.DIVISION = .Rows(0).Item("DIVISION").ToString()
                HDR.SalesGroup = .Rows(0).Item("SALESGROUP").ToString() : HDR.SalesOffice = .Rows(0).Item("SALESOFFICE").ToString()
            End If
            HDR.INCO1 = .Rows(0).Item("INCOTERM")
            Dim INCO2 As String = "blank"
            If .Rows(0).Item("INCOTERM_TEXT") <> "" Then INCO2 = .Rows(0).Item("INCOTERM_TEXT")
            HDR.INCO2 = INCO2
            Dim Company_Country As String = ""
            If DTcompany.Rows(0).Item("COUNTRY_NAME") IsNot DBNull.Value Then Company_Country = DTcompany.Rows(0).Item("COUNTRY_NAME")
            If Company_Country.ToUpper = "NL" Then
                HDR.SHIPTO_COUNTRY = Company_Country.ToUpper : HDR.TRIANGULAR_INDICATOR = "X"
            End If
            If String.IsNullOrEmpty(.Rows(0).Item("PAYTERM").ToString()) = False Then
                HDR.PAYTERM = UCase(.Rows(0).Item("PAYTERM").ToString())
            End If
            HDR.TAX_CLASS = ""
            Dim rd As DateTime = LocalTime
            If CDate(.Rows(0).Item("required_date")) > rd Then
                rd = CDate(.Rows(0).Item("required_date"))
            End If
            HDR.REQUIRE_DATE = rd.ToString("yyyy/MM/dd") : HDR.SHIP_CONDITION = Left(.Rows(0).Item("SHIP_CONDITION"), 2)
            HDR.CUST_PO_NO = IIf(.Rows(0).Item("po_no") = "", Order_No, .Rows(0).Item("po_no")) : HDR.SHIP_CUST_PO_NO = ""
            HDR.PO_DATE = Global_Inc.FormatDate(.Rows(0).Item("po_date"))
            If .Rows(0).Item("partial_flag") = "0" Then HDR.PARTIAL_SHIPMENT = "X"
            HDR.EARLY_SHIP = "0001"
            If .Rows(0).Item("SOLDTO_ID") = "SAID" Then
                HDR.TAXDEL_CTY = "SG" : HDR.TAXDES_CTY = "ID"
            End If
        End With
        If Util.IsTesting() Then
            HDR.DEST_TYPE = 1
        End If
        HDT.Rows.Add(HDR)
        '/Header
        'Detail
        For Each R As DataRow In dtDetail.Rows
            Dim DR As SAPDAL.SalesOrder.OrderLinesRow = DDT.NewRow
            With R
                DR.PART_Dlv = ""
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then
                If .Item("ORDER_LINE_TYPE") = 1 Then DR.HIGHER_LEVEL = "100"
                'End If
                DR.LINE_NO = .Item("Line_No")
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then DR.DELIVERY_GROUP = "10"
                If dtMaster.Rows(0).Item("SOLDTO_ID") = "SAID" Then DR.PLANT = .Item("DeliveryPlant")
                If Global_Inc.IsNumericItem(.Item("part_no")) Then
                    DR.MATERIAL = "00000000" & .Item("part_no")
                Else
                    DR.MATERIAL = replaceCartBTO(.Item("part_no"))
                End If
                DR.Description = .Item("Description")
                DR.CUST_MATERIAL = .Item("CustMaterialNo") : DR.DMF_FLAG = .Item("DMF_Flag") : DR.QTY = .Item("qty")
                Dim rd As DateTime = LocalTime
                If CDate(.Item("required_date")) > rd Then rd = CDate(.Item("required_date"))
                DR.REQ_DATE = rd.ToString("yyyy/MM/dd") : DR.PRICE = .Item("unit_price") : DR.CURRENCY = dtMaster.Rows(0).Item("currency")
                'ODM Spacial setting 

                If MyCartOrderBizDAL.isODMOrder(Order_No) Then
                    DR.PLANT = "TWM3" : DR.ShipPoint = "TWH1"
                    'DR.StorageLoc = "0018"
                End If
                'End ODM Spacial setting
            End With
            DDT.Rows.Add(DR)
        Next
        '/Detail

        'Text
        With dtMaster
            Dim TR1 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR2 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR3 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            Dim TR4 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR5 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            TR1.TEXT_ID = "0001" 'SALESNOTE
            TR1.LANG_ID = "EN" : TR1.TEXT_LINE = .Rows(0).Item("SALES_NOTE")
            TR2.TEXT_ID = "0002" 'EXNOTE
            TR2.LANG_ID = "EN" : TR2.TEXT_LINE = .Rows(0).Item("ORDER_NOTE")
            TR3.TEXT_ID = "ZEOP" 'OPNOTE
            TR3.LANG_ID = "EN" : TR3.TEXT_LINE = .Rows(0).Item("OP_NOTE")
            TR4.TEXT_ID = "ZPRJ" 'PRJNOTE
            TR4.LANG_ID = "EN" : TR4.TEXT_LINE = .Rows(0).Item("prj_NOTE")
            TR5.TEXT_ID = "ZBIL" 'Billing Instruction
            TR5.LANG_ID = "EN" : TR5.TEXT_LINE = .Rows(0).Item("BILLINGINSTRUCTION_INFO")
            TDT.Rows.Add(TR1) : TDT.Rows.Add(TR2) : TDT.Rows.Add(TR3) : TDT.Rows.Add(TR4) : TDT.Rows.Add(TR5)
            If Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD").ToString()) AndAlso Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString()) _
                AndAlso Date.TryParse(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString(), Now) Then
                CDT.AddCreditCardRow(.Rows(0).Item("CREDIT_CARD_HOLDER").ToString(), CDate(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString()).ToString("yyyyMMdd"),
                     .Rows(0).Item("CREDIT_CARD_TYPE").ToString(), .Rows(0).Item("CREDIT_CARD").ToString(), .Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString(), "", "", "")
            End If
        End With
        '/Text
        'Partner
        With dtMaster
            Dim PR1 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow, PR2 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow
            PR1.ROLE = "AG" : PR1.NUMBER = .Rows(0).Item("soldto_id").ToString.ToUpper : PDT.Rows.Add(PR1)
            PR2.ROLE = "WE" : PR2.NUMBER = .Rows(0).Item("shipto_id").ToString.ToUpper : PDT.Rows.Add(PR2)
            If .Rows(0).Item("ER_EMPLOYEE") <> "" Then
                Dim PR3 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR3.ROLE = "ZM" : PR3.NUMBER = .Rows(0).Item("ER_EMPLOYEE") : PDT.Rows.Add(PR3)
            End If
            If .Rows(0).Item("END_CUST") <> "" Then
                Dim PR4 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR4.ROLE = "EM" : PR4.NUMBER = .Rows(0).Item("END_CUST") : PDT.Rows.Add(PR4)
            End If
            If .Rows(0).Item("EMPLOYEEID") <> "" Then
                Dim PR5 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR5.ROLE = "VE" : PR5.NUMBER = .Rows(0).Item("EMPLOYEEID") : PDT.Rows.Add(PR5)
            End If
            Dim KeyInPerson As String = SAPDOC.GetKeyInPerson("")
            If Not String.IsNullOrEmpty(KeyInPerson) Then
                Dim PR6 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR6.ROLE = "ZR" : PR6.NUMBER = KeyInPerson : PDT.Rows.Add(PR6)
            End If
            If Not IsDBNull(.Rows(0).Item("BILLTO_ID")) AndAlso .Rows(0).Item("BILLTO_ID").ToString <> "" AndAlso
               Not .Rows(0).Item("BILLTO_ID").ToString.Trim.Equals(.Rows(0).Item("soldto_id").ToString, StringComparison.OrdinalIgnoreCase) Then
                Dim PR7 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR7.ROLE = "RE" : PR7.NUMBER = .Rows(0).Item("BILLTO_ID") : PDT.Rows.Add(PR7)
            End If
        End With
        '/Partner
        'Condition
        For Each R As DataRow In dtFt.Rows
            Dim conLine As SAPDAL.SalesOrder.ConditionRow = CODT.NewRow
            With R
                conLine.TYPE = .Item("ftype") : conLine.VALUE = .Item("fvalue") : conLine.CURRENCY = dtMaster.Rows(0).Item("currency")
            End With
            CODT.Rows.Add(conLine)
        Next

        '/Condition
        'Dim RDT As New DataTable : RDT.TableName = "RDTABLE"
        Dim WS As New SAPDAL.SAPDAL

        Dim B As Boolean = False
        Dim REFORDERNO As String = Order_No
        If dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR2" Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR" _
            Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR6" Then
            If isSimulate Then
                B = WS.SimulateSO("SIMSO", ErrMsg, HDT, DDT, PDT, CODT, TDT, CDT, dtMsg, LocalTime)
            Else
                B = WS.CreateSO(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, CDT, dtMsg, LocalTime)
            End If
        ElseIf dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "AG" Then
            'B = WS.CreateQuotation1(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
        Else
            ErrMsg = "DOC TYPE ERR!"
            Return False
        End If
        WS.Dispose()
        'OrderUtilities.showDT(RDT) : HttpContext.Current.Response.End()
        If B Then IB = 1
        ProcStatus_Save(dtMsg, Order_No, IB)
        'Catch ex As Exception
        '    ErrMsg = ex.ToString()
        '    Return False
        'End Try
        If IB = 1 Then
            Return True
        Else
            Return False
        End If
    End Function


    Public Shared Function SOCreateV3(ByVal Order_No As String, ByRef ErrMsg As String) As Boolean
        Dim IB As Integer = 0
        Dim myOrderMaster As New order_Master("B2B", "Order_Master"), myOrderDetail As New order_Detail("B2B", "Order_Detail")
        Dim my_Company As New SAP_Company("b2b", "sap_dimcompany"), myFt As New Freight("b2b", "Freight")
        Dim LocalTime As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
        Dim dtMaster As DataTable = myOrderMaster.GetDT(String.Format("order_id='{0}'", Order_No), ""), dtDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_No")
        Dim dtFt As DataTable = myFt.GetDT(String.Format("order_id='{0}'", Order_No), "")
        If dtMaster.Rows.Count = 0 Or dtDetail.Rows.Count = 0 Then
            ErrMsg = "RAW DATA ERROR!" : Return False
        End If

        Dim HDT As New SAPDAL.SalesOrder.OrderHeaderDataTable, DDT As New SAPDAL.SalesOrder.OrderLinesDataTable, PDT As New SAPDAL.SalesOrder.PartnerFuncDataTable
        Dim TDT As New SAPDAL.SalesOrder.HeaderTextsDataTable, CODT As New SAPDAL.SalesOrder.ConditionDataTable, CDT As New SAPDAL.SalesOrder.CreditCardDataTable
        Dim PtAddressDT As New SAPDAL.SalesOrder.PartnerAddressesDataTable
        'Header
        Dim HDR As SAPDAL.SalesOrder.OrderHeaderRow = HDT.NewRow
        With dtMaster
            Dim soldtoID As String = .Rows(0).Item("soldto_id"), DTcompany As DataTable = my_Company.GetDT(String.Format("company_id='{0}'", soldtoID), "")
            If DTcompany.Rows.Count = 0 Then
                ErrMsg = "Invalid SoldTo!" : Return False
            End If
            Dim sales_org As String = UCase(HttpContext.Current.Session("Org_id")), distr_chan As String = "10", division As String = "00"
            SAPDOC.Get_disChannel_and_division(soldtoID, distr_chan, division)
            HDR.ORDER_TYPE = .Rows(0).Item("Order_Type") : HDR.SALES_ORG = sales_org : HDR.DIST_CHAN = distr_chan : HDR.DIVISION = division
            If Not String.IsNullOrEmpty(.Rows(0).Item("DIST_CHAN").ToString()) Then
                HDR.DIST_CHAN = .Rows(0).Item("DIST_CHAN").ToString() : HDR.DIVISION = .Rows(0).Item("DIVISION").ToString()
                HDR.SalesGroup = .Rows(0).Item("SALESGROUP").ToString() : HDR.SalesOffice = .Rows(0).Item("SALESOFFICE").ToString()
            End If
            If Not String.IsNullOrEmpty(.Rows(0).Item("DISTRICT").ToString()) Then
                HDR.DISTRICT = .Rows(0).Item("DISTRICT").ToString()
            End If
            HDR.INCO1 = .Rows(0).Item("INCOTERM")
            Dim INCO2 As String = "blank"
            If .Rows(0).Item("INCOTERM_TEXT") <> "" Then INCO2 = .Rows(0).Item("INCOTERM_TEXT")
            HDR.INCO2 = INCO2
            Dim Company_Country As String = ""
            If DTcompany.Rows(0).Item("COUNTRY_NAME") IsNot DBNull.Value Then Company_Country = DTcompany.Rows(0).Item("COUNTRY_NAME")
            If Company_Country.ToUpper = "NL" Then
                HDR.SHIPTO_COUNTRY = Company_Country.ToUpper : HDR.TRIANGULAR_INDICATOR = "X"
            End If
            If String.IsNullOrEmpty(.Rows(0).Item("PAYTERM").ToString()) = False Then
                HDR.PAYTERM = UCase(.Rows(0).Item("PAYTERM").ToString())
            End If
            HDR.TAX_CLASS = ""
            Dim rd As DateTime = LocalTime
            If CDate(.Rows(0).Item("required_date")) > rd Then
                rd = CDate(.Rows(0).Item("required_date"))
            End If
            HDR.REQUIRE_DATE = rd.ToString("yyyy/MM/dd") : HDR.SHIP_CONDITION = Left(.Rows(0).Item("SHIP_CONDITION"), 2)
            HDR.CUST_PO_NO = IIf(.Rows(0).Item("po_no") = "", Order_No, .Rows(0).Item("po_no")) : HDR.SHIP_CUST_PO_NO = ""
            HDR.PO_DATE = Global_Inc.FormatDate(.Rows(0).Item("po_date"))
            If .Rows(0).Item("partial_flag") = "0" Then HDR.PARTIAL_SHIPMENT = "X"
            HDR.EARLY_SHIP = "0001"
            If .Rows(0).Item("SOLDTO_ID") = "SAID" Then
                HDR.TAXDEL_CTY = "SG" : HDR.TAXDES_CTY = "ID"
            End If
        End With
        If Util.IsTesting() Then
            HDR.DEST_TYPE = 1
        End If
        HDT.Rows.Add(HDR)
        '/Header
        'Detail
        For Each R As DataRow In dtDetail.Rows
            Dim DR As SAPDAL.SalesOrder.OrderLinesRow = DDT.NewRow
            With R
                DR.PART_Dlv = ""
                'If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then
                If .Item("ORDER_LINE_TYPE") = 1 Then DR.HIGHER_LEVEL = "100"
                'End If
                DR.LINE_NO = .Item("Line_No")
                If UCase(HttpContext.Current.Session("Org_id")) <> "EU10" Then DR.DELIVERY_GROUP = "10"
                If dtMaster.Rows(0).Item("SOLDTO_ID") = "SAID" Then DR.PLANT = .Item("DeliveryPlant")
                If Global_Inc.IsNumericItem(.Item("part_no")) Then
                    DR.MATERIAL = "00000000" & .Item("part_no")
                Else
                    DR.MATERIAL = replaceCartBTO(.Item("part_no"))
                End If
                DR.Description = .Item("Description")
                DR.CUST_MATERIAL = .Item("CustMaterialNo") : DR.DMF_FLAG = .Item("DMF_Flag") : DR.QTY = .Item("qty")
                Dim rd As DateTime = LocalTime
                If CDate(.Item("required_date")) > rd Then rd = CDate(.Item("required_date"))
                DR.REQ_DATE = rd.ToString("yyyy/MM/dd") : DR.PRICE = .Item("unit_price") : DR.CURRENCY = dtMaster.Rows(0).Item("currency")
                'ODM Spacial setting 

                If MyCartOrderBizDAL.isODMOrder(Order_No) Then
                    DR.PLANT = "TWM3" : DR.ShipPoint = "TWH1"
                    'DR.StorageLoc = "0018"
                End If
                'End ODM Spacial setting
            End With
            DDT.Rows.Add(DR)
        Next
        '/Detail

        'Text
        With dtMaster
            Dim TR1 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR2 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR3 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            Dim TR4 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow, TR5 As SAPDAL.SalesOrder.HeaderTextsRow = TDT.NewRow
            TR1.TEXT_ID = "0001" 'SALESNOTE
            TR1.LANG_ID = "EN" : TR1.TEXT_LINE = .Rows(0).Item("SALES_NOTE")
            TR2.TEXT_ID = "0002" 'EXNOTE
            TR2.LANG_ID = "EN" : TR2.TEXT_LINE = .Rows(0).Item("ORDER_NOTE")
            TR3.TEXT_ID = "ZEOP" 'OPNOTE
            TR3.LANG_ID = "EN" : TR3.TEXT_LINE = .Rows(0).Item("OP_NOTE")
            TR4.TEXT_ID = "ZPRJ" 'PRJNOTE
            TR4.LANG_ID = "EN" : TR4.TEXT_LINE = .Rows(0).Item("prj_NOTE")
            TR5.TEXT_ID = "ZBIL" 'Billing Instruction
            TR5.LANG_ID = "EN" : TR5.TEXT_LINE = .Rows(0).Item("BILLINGINSTRUCTION_INFO")
            TDT.Rows.Add(TR1) : TDT.Rows.Add(TR2) : TDT.Rows.Add(TR3) : TDT.Rows.Add(TR4) : TDT.Rows.Add(TR5)
            If Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD").ToString()) AndAlso Not String.IsNullOrEmpty(.Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString()) _
                AndAlso Date.TryParse(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString(), Now) Then
                CDT.AddCreditCardRow(.Rows(0).Item("CREDIT_CARD_HOLDER").ToString(), CDate(.Rows(0).Item("CREDIT_CARD_EXPIRE_DATE").ToString()).ToString("yyyyMMdd"),
                     .Rows(0).Item("CREDIT_CARD_TYPE").ToString(), .Rows(0).Item("CREDIT_CARD").ToString(), .Rows(0).Item("CREDIT_CARD_VERIFY_NUMBER").ToString(), "", "", "")
            End If
        End With
        '/Text
        'Partner
        With dtMaster
            'Dim PR1 As SAPDAL.SalesOrder.SAP_BAPIPARNRRow = PDT.NewRow, PR2 As SAPDAL.SalesOrder.SAP_BAPIPARNRRow = PDT.NewRow
            'PR1.PARTN_ROLE = "AG" : PR1.PARTN_NUMB = .Rows(0).Item("soldto_id").ToString.ToUpper : PDT.Rows.Add(PR1)
            'PR2.PARTN_ROLE = "WE" : PR2.PARTN_NUMB = .Rows(0).Item("shipto_id").ToString.ToUpper : PDT.Rows.Add(PR2)
            Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
            Dim OPdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(Order_No)
            Dim ADDRNUMBER As String = "1"
            For Each op As MyOrderDS.ORDER_PARTNERSRow In OPdt
                Dim PR As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow()
                PR.NUMBER = op.ERPID
                If op.TYPE.Equals("SOLDTO", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "AG"
                    PDT.Rows.Add(PR)
                ElseIf op.TYPE.Equals("S", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "WE"
                    ' PR. = ADDRNUMBER
                    PDT.Rows.Add(PR)
                    'PDT.Rows.Add(PR.ItemArray)
                    Dim PtnrAdressdt As SAPDAL.SalesOrder.PartnerAddressesDataTable = SAPDAL.SAPDAL.GetSAPPartnerAddressesTableByKunnr(op.ERPID)
                    'Dim PtnrAdressRow As SAPDAL.SalesOrder.PartnerAddressesRow
                    If PtnrAdressdt.Rows.Count > 0 Then
                        Dim PtnrAdressRow As SAPDAL.SalesOrder.PartnerAddressesRow = PtnrAdressdt.Rows(0)
                        PtnrAdressRow.C_O_Name = op.ATTENTION
                        PtnrAdressRow.Addr_No = ADDRNUMBER
                        PtnrAdressdt.AcceptChanges()
                        PtAddressDT = PtnrAdressdt.Copy()
                    End If
                ElseIf op.TYPE.Equals("B", StringComparison.OrdinalIgnoreCase) Then
                    PR.ROLE = "RE"
                    PDT.Rows.Add(PR)
                End If
            Next
            If .Rows(0).Item("ER_EMPLOYEE") <> "" Then
                Dim PR3 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR3.ROLE = "ZM" : PR3.NUMBER = .Rows(0).Item("ER_EMPLOYEE") : PDT.Rows.Add(PR3)

            End If
            If .Rows(0).Item("END_CUST") <> "" Then
                Dim PR4 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR4.ROLE = "EM" : PR4.NUMBER = .Rows(0).Item("END_CUST") : PDT.Rows.Add(PR4)

            End If
            If .Rows(0).Item("EMPLOYEEID") <> "" Then
                Dim PR5 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR5.ROLE = "VE" : PR5.NUMBER = .Rows(0).Item("EMPLOYEEID") : PDT.Rows.Add(PR5)

            End If
            Dim KeyInPerson As String = SAPDOC.GetKeyInPerson("")
            If Not String.IsNullOrEmpty(KeyInPerson) Then
                Dim PR6 As SAPDAL.SalesOrder.PartnerFuncRow = PDT.NewRow : PR6.ROLE = "ZR" : PR6.NUMBER = KeyInPerson : PDT.Rows.Add(PR6)

            End If
        End With
        '/Partner
        'Condition
        For Each R As DataRow In dtFt.Rows
            Dim conLine As SAPDAL.SalesOrder.ConditionRow = CODT.NewRow
            With R
                conLine.TYPE = .Item("ftype") : conLine.VALUE = .Item("fvalue") : conLine.CURRENCY = dtMaster.Rows(0).Item("currency")
            End With
            CODT.Rows.Add(conLine)
        Next

        '/Condition
        Dim RDT As New DataTable : RDT.TableName = "RDTABLE"
        Dim WS As New SAPDAL.SAPDAL

        Dim B As Boolean = False
        Dim REFORDERNO As String = Order_No
        If dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR2" Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR" _
            Or dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "ZOR6" Then
            B = WS.CreateSOV2(REFORDERNO, ErrMsg, HDT, DDT, PDT, PtAddressDT, CODT, TDT, CDT, RDT, LocalTime)
        ElseIf dtMaster.Rows(0).Item("Order_Type").ToString.ToUpper = "AG" Then
            'B = WS.CreateQuotation1(REFORDERNO, ErrMsg, HDT, DDT, PDT, CODT, TDT, RDT)
        Else
            ErrMsg = "DOC TYPE ERR!"
            Return False
        End If
        WS.Dispose()
        'OrderUtilities.showDT(RDT) : HttpContext.Current.Response.End()
        If B Then IB = 1
        ProcStatus_Save(RDT, Order_No, IB)
        'Catch ex As Exception
        '    ErrMsg = ex.ToString()
        '    Return False
        'End Try
        If IB = 1 Then
            Return True
        Else
            Return False
        End If
    End Function

    Public Shared Sub updateEWFlag(ByVal Order_No As String)
        System.Threading.Thread.Sleep(2000)
        Dim myOrderDetail As New order_Detail("B2B", "order_Detail")
        Dim dt As New DataTable
        dt = myOrderDetail.GetDT(String.Format("order_id='{0}'", Order_No), "line_no")
        If dt.Rows.Count > 0 Then
            Dim nDT As New DataTable
            nDT.Columns.Add("so_no") : nDT.Columns.Add("line_no") : nDT.Columns.Add("exwarranty_flag")
            For Each R As DataRow In dt.Rows
                'ICC 2016/1/19 Don't send exwarranty_flag = 0 to SAP BAPI
                If R.Item("exwarranty_flag").ToString <> "0" Then
                    Dim rDT As DataRow = nDT.NewRow
                    rDT.Item("so_no") = R.Item("order_id")
                    rDT.Item("line_no") = R.Item("line_no")
                    rDT.Item("exwarranty_flag") = IIf(R.Item("exwarranty_flag") = "99", "36", CInt(R.Item("exwarranty_flag")).ToString("00"))
                    nDT.Rows.Add(rDT)
                End If
            Next
            'Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
            'ws.Timeout = -1
            'nDT.TableName = ("ewUp")
            'ws.UpdateSOWarrantyFlagByTable(nDT, "", True)
            If nDT.Rows.Count > 0 Then
                Dim errMsg As String = String.Empty
                SAPDAL.SAPDAL.UpdateSOWarrantyFlagByTable(nDT, errMsg, True)
                If Not String.IsNullOrEmpty(errMsg) Then Util.InsertMyErrLog(String.Format("Exception in updateEWFlag! Order_No: {0}. Erroro message: {1}", Order_No, errMsg))
            End If
        End If

    End Sub
    Public Shared Function UpdateScheduleFromSAP(ByVal OrderNo As String) As Boolean
        If Not MyOrderX.IsHaveBtos(OrderNo) Then
            Dim sql As New StringBuilder
            'sql.AppendFormat("select  b.vbeln  as so_no,count(*) as Schedule_Count,   cast(b.posnr as integer)  as so_line_no " + _
            '                                    " ,max(c.edatu) as max_sch_date,min(c.edatu) as min_sch_date" + _
            '                                    " from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln  " + _
            '                                    " inner join saprdp.vbep c on b.vbeln=c.vbeln and b.posnr=c.posnr   " + _
            '                                    " where a.mandt='168' and b.mandt='168' and c.mandt='168'" + _
            '                                    " and a.vbeln='{0}'" + _
            '                                    " group by b.vbeln, b.posnr" + _
            '                                    " order by b.posnr", OrderNo)

            sql.AppendLine(" select s.* from ( ")
            sql.AppendLine(" select b.vbeln  as so_no,count(*) as Schedule_Count, cast(b.posnr as integer)  as so_line_no ")
            sql.AppendLine(" ,max(c.edatu) as max_sch_date,min(c.edatu) as min_sch_date ")
            sql.AppendLine(" from saprdp.vbak a inner join saprdp.vbap b on a.vbeln=b.vbeln ")
            sql.AppendLine(" inner join saprdp.vbep c on b.vbeln=c.vbeln and b.posnr=c.posnr ")
            sql.AppendLine(" where a.mandt='168' and b.mandt='168' and c.mandt='168' ")
            sql.AppendLine(" and a.vbeln='" & OrderNo & "' ")
            sql.AppendLine(" group by b.vbeln, b.posnr ")
            sql.AppendLine(" ) s ")
            sql.AppendLine(" Where s.Schedule_Count>1 ")
            sql.AppendLine(" order by s.so_line_no ")
            Dim connstr As String = "SAP_PRD"
            If Util.IsTesting() Then connstr = "SAP_Test"
            Dim dt As DataTable = OraDbUtil.dbGetDataTable(connstr, sql.ToString)
            Dim Oitem As List(Of OrderItem) = MyOrderX.GetOrderListV2(OrderNo)
            Dim itemNote As String = String.Empty
            For Each dr As DataRow In dt.Rows
                Dim item As OrderItem = Oitem.FirstOrDefault(Function(p) p.LINE_NO = dr.Item("so_line_no"))
                If item IsNot Nothing Then
                    Dim Sstr As String = dr.Item("max_sch_date").ToString.Trim
                    If DateTime.TryParse(SAPDAL.Global_Inc.SAPDate2StdDate(Sstr), Now) Then
                        Dim Sdt As DateTime = DateTime.Parse(SAPDAL.Global_Inc.SAPDate2StdDate(Sstr))
                        item.DUE_DATE = Sdt
                        itemNote = item.LINE_NO.ToString() + vbTab + CDate(item.DUE_DATE).ToString("yyyy-MM-dd") + vbCrLf
                    End If
                End If
            Next
            If dt.Rows.Count > 0 Then MyUtil.Current.MyAContext.SubmitChanges()
            If Not String.IsNullOrEmpty(itemNote) Then
                Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", "update Schedule Date", OrderNo + vbCrLf + itemNote, True, "", "")
            End If
        End If
        Return True
    End Function
    Public Shared Function ProcessAfterOrderSuccess(ByVal Order_No As String, ByRef ErrMsg As String, Optional ByVal IsRecover As Boolean = False) As Boolean
        'Try
        '    UpdateScheduleFromSAP(Order_No)
        'Catch ex As Exception
        '    Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", "update Schedule line Failed:" + Order_No, ex.ToString, True, "", "")
        'End Try

        'Ryan 20170208 Move log check point order finished process here, not in SAPDOC.getOrderNumberOracle anymore
        If AuthUtil.IsCheckPointOrder(HttpContext.Current.Session("user_id"), HttpContext.Current.Session("cart_id")) Then
            Util.SendEmail("yl.huang@advantech.com.tw", "myadvantech@advantech.com", String.Format("Check Point Process after success SO:{0}", Order_No), "Check Point Process After success", True, "", "")
            Dim so_no As String = Advantech.Myadvantech.Business.CPDBBusinessLogic.CheckPointOrder2Cart_getOrderNo(HttpContext.Current.Session("cart_id"))
            If Not String.IsNullOrEmpty(so_no) Then
                Advantech.Myadvantech.Business.CPDBBusinessLogic.EditCheckPointOrder2Cart_Status(HttpContext.Current.Session("cart_id"))
                Dim cp As Advantech.Myadvantech.DataAccess.CPTEST.general = New Advantech.Myadvantech.DataAccess.CPTEST.general()
                cp.LOGSuccessSO(so_no)
            Else
                Util.SendEmail("yl.huang@advantech.com.tw", "myadvantech@advantech.com", String.Format("Check Point Process after success SO:{0}", Order_No), "Check Point Process After success Exception - so_no not found", True, "", "")
            End If
        End If

        Dim b1 As Boolean = False
        'updateEWFlag(Order_No)

        Dim myOrderMaster As New order_Master("B2B", "Order_Master"), myOrderDetail As New order_Detail("B2B", "order_Detail")
        Try
            myOrderMaster.Update(String.Format("order_id='{0}'", Order_No), String.Format("ORDER_STATUS='FINISH'"))
            SendPI(Order_No, IsRecover)
            If myOrderDetail.isBtoOrder(Order_No) AndAlso Not Util.IsTesting() Then
                sendSheet(Order_No)
            End If
        Catch ex As Exception
            Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", String.Format("Error in Process after success SO Step1:{0}", Order_No), "Exception:" + ex.ToString, True, "", "")
        End Try

        'Frank 20160120 Move this function to here, call this function after changing order status and sending PI mail
        updateEWFlag(Order_No)


        'Ryan 20170322 Update company ID back to SAP_COMPANY_ORG for ACN default ERPID settings
        If AuthUtil.IsACN Then
            Dim dtACN As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select * from SAP_COMPANY_ORG where COMPANY_ID ='{0}' AND ORG_ID = '{1}'", HttpContext.Current.Session("COMPANY_ID").ToString, HttpContext.Current.Session("ORG_ID").ToString))
            If dtACN IsNot Nothing AndAlso dtACN.Rows.Count > 0 Then
                dbUtil.dbExecuteNoQuery("MY", String.Format(" update SAP_COMPANY_ORG set IS_DEFAULT = '0' where COMPANY_ID = '{0}' ", HttpContext.Current.Session("COMPANY_ID").ToString))
                dbUtil.dbExecuteNoQuery("MY", String.Format(" update SAP_COMPANY_ORG set IS_DEFAULT = '1' where COMPANY_ID = '{0}' and ORG_ID = '{1}' ", HttpContext.Current.Session("COMPANY_ID").ToString, HttpContext.Current.Session("ORG_ID").ToString))
            End If
            'ICC 20170822 更改中科專案價格
            If MyOrderX.IsHaveBtos(Order_No) = True Then
                Dim items As List(Of OrderItem) = MyOrderX.GetOrderListV2(Order_No)
                If items IsNot Nothing AndAlso CType(dbUtil.dbExecuteScalar("MYLOCAL", "SELECT COUNT(*) FROM MY_PARAMETER WHERE ParaName = 'CN_SOC' AND ParaValue='Y'"), Integer) > 0 Then
                    For Each item As OrderItem In items
                        If Not String.IsNullOrEmpty(item.CustMaterialNo) AndAlso item.CustMaterialNo.StartsWith("CM-") Then
                            Dim children As List(Of OrderItem) = items.Where(Function(p) p.HigherLevel.Value = item.LINE_NO.Value).ToList()
                            Dim totalAmount As Decimal = children.Sum(Function(p) p.UNIT_PRICE.Value * Convert.ToDecimal(p.QTY.Value))
                            Dim sapAmount As Decimal = children.Sum(Function(p) Math.Round(p.UNIT_PRICE.Value / (1 + ConfigurationManager.AppSettings("ACNTaxRate")), 2, MidpointRounding.AwayFromZero) * Convert.ToDecimal(p.QTY.Value)) * (1 + ConfigurationManager.AppSettings("ACNTaxRate"))
                            Dim child As OrderItem = children.OrderBy(Function(p) p.QTY.Value).FirstOrDefault()
                            If child IsNot Nothing Then
                                Dim diff As Decimal = (totalAmount - sapAmount) / Convert.ToDecimal(child.QTY.Value)
                                Dim socList As New List(Of SAPDAL.SAPDAL.SOC_SOLine)
                                Dim soc As New SAPDAL.SAPDAL.SOC_SOLine()
                                soc.LineNo = child.LINE_NO.Value.ToString : soc.PartNo = child.PART_NO : soc.NewPrice = Math.Round(child.UNIT_PRICE.Value / (1 + ConfigurationManager.AppSettings("ACNTaxRate")), 2, MidpointRounding.AwayFromZero) + diff
                                soc.UpdatePN = False : soc.UpdateQty = False : soc.UpdateReqDate = False : soc.UpdatePrice = True : socList.Add(soc)
                                Dim sd As New SAPDAL.SAPDAL()
                                If soc.NewPrice > 0 Then
                                    Dim socMsg As String = String.Empty
                                    sd.UpdateSOLine(Order_No, socList, socMsg, Util.IsTesting)
                                    If Not String.IsNullOrEmpty(socMsg) Then Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", String.Format("Soc update process after success SO:{0}", Order_No), "Soc update messgae " + socMsg, True, "", "")
                                End If
                            End If
                        End If
                    Next
                End If
            End If
        End If

        'Ryan 20170629 Check if AJP orders need so update for revenue sharing
        If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("JP01") Then
            UpdateRevenueSplitOption2SAP(Order_No)
        End If

        'Ryan 20180322 For ADLOG revenue split
        If AuthUtil.IsADloG Then
            UpdateRevenueSplitOption2SAP(Order_No)
        End If

        If AuthUtil.IsBBUS() Then
            'Frank 20180105
            'Unticking SO's credit card's authorization block
            'try catch is implemented in function OrderBusinessLogic.UnblockSOCreditCard
            If OrderBusinessLogic.IsCreditCardPayment(Order_No) Then
                Dim sno As String = Global_Inc.SONoBuildSAPFormat(Order_No.Trim.ToUpper).ToString
                Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 * from BB_CREDITCARD_ORDER  where status = 'Success' and ORDER_NO='{0}' order by CREATED_DATE desc ", Order_No))
                If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
                    Dim cardNo As String = dt.Rows(0).Item("CARD_NO").ToString
                    Dim cardType As String = dt.Rows(0).Item("CARD_TYPE").ToString
                    Dim authCode As String = dt.Rows(0).Item("AUTH_CODE").ToString
                    Dim transID As String = dt.Rows(0).Item("TRANSACTION_ID").ToString
                    Dim amount As Decimal = 0
                    If Not IsDBNull(dt.Rows(0).Item("TOTAL_AUTH_AMOUNT")) Then
                        Decimal.TryParse(dt.Rows(0).Item("TOTAL_AUTH_AMOUNT").ToString, amount)
                    End If
                    If Not String.IsNullOrEmpty(cardNo) AndAlso Not String.IsNullOrEmpty(cardType) AndAlso Not String.IsNullOrEmpty(authCode) _
                        AndAlso Not String.IsNullOrEmpty(transID) AndAlso amount > 0 Then
                        Advantech.Myadvantech.Business.OrderBusinessLogic.AddCreditCardInfo2SAPSO(sno, authCode, transID, cardType, cardNo, amount, Util.IsTesting())
                    End If
                End If
                Advantech.Myadvantech.Business.OrderBusinessLogic.UnblockSOCreditCard(Order_No, Util.IsTesting())
            End If


            'Ryan 20180302 - Add email records to SAP ADR6 table with AP adrnr
            Dim objContacts As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ADDRESS from ORDER_PARTNERS where ORDER_ID = '{0}' and TYPE = 'Contact'", Order_No))
            If Not objContacts Is Nothing AndAlso Not String.IsNullOrEmpty(objContacts.ToString) Then
                Dim BBContacts As List(Of String) = objContacts.ToString.Split(";").ToList

                If BBContacts.Count > 0 Then
                    Dim objAdrnr As Object = OraDbUtil.dbExecuteScalar(IIf(Util.IsTesting, "SAP_Test", "SAP_PRD"), String.Format("select ADRNR from saprdp.vbpa where vbeln = '{0}' and PARVW = 'AP' and rownum = 1", Order_No))
                    If objAdrnr IsNot Nothing AndAlso Not String.IsNullOrEmpty(objAdrnr.ToString) Then
                        MYSAPDAL.AddSAPADR6RecordsByADRNR(objAdrnr.ToString, BBContacts, Util.IsTesting)
                    End If
                End If
            End If
        End If

        '20170419 Alex/Ryan: Move release GP Function logic to ProcessAfterOrderSuccess
        Dim quoteId As String = "", Msg = "", _QuoteNo = ""
        If myOrderDetail.isQuoteOrder(Order_No, quoteId, _QuoteNo) Then

            'Ryan/Alex 20180724 Add try catch
            Try
                Dim retbool = Advantech.Myadvantech.Business.QuoteBusinessLogic.LogQuote2Order(Order_No, quoteId, Msg)
                If Not retbool Then Util.InsertMyErrLog(Msg)
                Dim SAPDAL1 As New SAPDAL.SAPDAL()
                '20160921 TC: Always release SO's GP block because all orders entered to SAP via MyAdvantech should have been approved in advance
                '20161003 Frank: After discussion with TC, release the function to Intercon sales first.
                'If Util.IsTesting Then
                'AIAQ:Intercon IA's quote
                'AIEQ:Intercon EC's quote
                'AISQ:Intercon IService's quote
                If _QuoteNo.StartsWith("AIAQ", StringComparison.InvariantCultureIgnoreCase) OrElse
                                _QuoteNo.StartsWith("AIEQ", StringComparison.InvariantCultureIgnoreCase) OrElse
                                _QuoteNo.StartsWith("AISQ", StringComparison.InvariantCultureIgnoreCase) Then
                    'Ryan 20180628 Intercon take new function in SAPDAL.cs UnblockSOGP to unblock GP due to ZMIP should be check first
                    Advantech.Myadvantech.DataAccess.SAPDAL.UnblockSOGPWithZMIPCheck(Order_No, HttpContext.Current.Session("ORG_ID").ToString, Util.IsTesting)
                    'SAPDAL1.UnblockSOGP(Order_No, Util.IsTesting)
                ElseIf _QuoteNo.StartsWith("ACNQ", StringComparison.InvariantCultureIgnoreCase) Then
                    SAPDAL1.UnblockSOHeaderGP(Order_No, Util.IsTesting)
                ElseIf _QuoteNo.StartsWith("BBEQ", StringComparison.InvariantCultureIgnoreCase) Then
                    'Ryan 20180412 For B+B, unblock SO header GP and send SPR No to SAP
                    SAPDAL1.UnblockSOHeaderGP(Order_No, Util.IsTesting)
                    SAPDAL1.UpdateSPRNo(Order_No, quoteId, Util.IsTesting)
                End If
            Catch ex As Exception
                Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com", String.Format("Error in Process after success SO Step2:{0}", Order_No), "Exception:" + ex.ToString, True, "", "")
            End Try
        End If

        Dim OptyId As String = ""
        Dim dtOptyDetail As DataTable = myOrderDetail.GetDT(String.Format("order_id='{0}' and optyid<>''", Order_No), "")
        If dtOptyDetail.Rows.Count > 0 Then
            'Dim quoteID As String = dtOptyDetail.Rows(0).Item("optyid")
            quoteId = dtOptyDetail.Rows(0).Item("optyid")
            If Util.IsTestingQuote2Order() Then
                Dim optyQuote As optyQuote = eQuotationUtil.GetoptyQuoteByQuoteid(quoteId)
                If optyQuote IsNot Nothing Then OptyId = optyQuote.optyId
            Else
                Dim ws As New quote.quoteExit
                ws.Timeout = -1
                OptyId = ws.getOptyIdByQuoteId(quoteId)
                ws.Dispose()
            End If
        End If
        '\Ming add 2013-12-5 如果是sieble quote转过来，并且这个quote的opty是存在的，就update status：Won
        If HttpContext.Current.Session IsNot Nothing AndAlso HttpContext.Current.Session("OptyId") IsNot Nothing AndAlso Not String.IsNullOrEmpty(HttpContext.Current.Session("OptyId").ToString) Then
            OptyId = HttpContext.Current.Session("OptyId").ToString.Trim
        End If
        'end
        Dim OPTYrevenue As Decimal = 0.0
        If OptyId <> "" Then
            OPTYrevenue = dbUtil.dbExecuteScalar("B2B", "select SUM(QTY * UNIT_PRICE) from order_detail where order_id = '" & Trim(Order_No) & "'")
        End If
        'Ming 20140425 台湾客户要根据在eQuotation输入的Amount为准, 20150410 remove: and OpportunityAmount > 0
        Dim Quote_ID As String = String.Empty

        'Ryan 20180606 Add BBUS in case
        'ICC 20170310 Add EU order to get quote from eQuotation and update opportunity.
        'Ryan 20160323 If is ATW or US than get quoteid for further opportunity update.        
        If SAPDOC.IsATWCustomer() OrElse
           AuthUtil.IsUSAonlineSales(HttpContext.Current.User.Identity.Name) OrElse
           HttpContext.Current.Session("org_id").ToString.Equals("EU10", StringComparison.OrdinalIgnoreCase) OrElse
           AuthUtil.IsBBUS Then
            OPTYrevenue = 0
            Dim Optydt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select top 1 isnull(OpportunityID,'') as  optyid, ISNULL(QuoteID,'') as Quote_ID, isnull(OpportunityAmount,0) as  optyAmount  from CARTMASTERV2 where CartID ='{0}' ", HttpContext.Current.Session("cart_id")))
            If Optydt.Rows.Count = 1 Then
                OptyId = Optydt.Rows(0).Item("optyid").ToString.Trim
                'Frank 20140427 因為ATW 已開始把Siebel quote copy進eQ轉單，而有些opty預先在Sibel上建立好並且有revenue
                '因此加上此判斷來避免revenue被這段update opty蓋掉
                'OPTYrevenue = Decimal.Parse(Optydt.Rows(0).Item("optyAmount"))
                If Not IsDBNull(Optydt.Rows(0).Item("optyAmount")) Then
                    ' For US01 quotes, take order amount instead of quote amount
                    If HttpContext.Current.Session("ORG_ID").ToString.ToUpper.Equals("US01") Then
                        OPTYrevenue = dbUtil.dbExecuteScalar("B2B", "select SUM(QTY * UNIT_PRICE) from order_detail where order_id = '" & Trim(Order_No) & "'")
                    Else
                        Decimal.TryParse(Optydt.Rows(0).Item("optyAmount").ToString, OPTYrevenue)
                    End If
                End If

                Quote_ID = Optydt.Rows(0).Item("Quote_ID").ToString.Trim
            End If
        End If
        'ICC 20170310 Make sure quoteID is not null.
        If Not String.IsNullOrEmpty(OptyId) AndAlso Not String.IsNullOrEmpty(Quote_ID) Then
            Try
                'Dim wsOpty As New aeu_eai2000.Siebel_WS
                'wsOpty.Timeout = -1
                'wsOpty.UseDefaultCredentials = True
                'b1 = wsOpty.UpdateOpportunityStatusRevenue(OptyId, "100% Won-PO Input in SAP", OPTYrevenue, False)
                'Ming20150319調用新的WS.UpdateOptyStage
                'Advantech.Myadvantech.DataAccess.SiebelDAL.UpdateOptyStage(OptyId, "100% Won-PO Input in SAP", CType(OPTYrevenue, Integer))
                'Ming add 20150401 call IC's API
                If Not String.IsNullOrEmpty(Quote_ID) AndAlso String.Equals(OptyId, "new id", StringComparison.InvariantCultureIgnoreCase) Then
                    Dim optyidobj As Object = dbUtil.dbExecuteScalar("EQ", String.Format("select top 1 isnull(optyId,'') as optyid  from  optyQuote where quoteId ='{0}'", Quote_ID))
                    If optyidobj IsNot Nothing AndAlso Not String.IsNullOrEmpty(optyidobj.ToString) AndAlso Not String.Equals(optyidobj, "new id", StringComparison.InvariantCultureIgnoreCase) Then
                        OptyId = optyidobj.ToString.Trim
                    End If
                End If

                'Ryan 20180420 Optys with "new id" still need to be sent to update its status to "100% won"
                'ICC 20170310 Don't send "new id" to update opportunity
                If Not String.IsNullOrEmpty(Quote_ID) Then
                    Dim active As SiebelActive = New SiebelActive()
                    active.ActiveSource = SiebelActiveSource.MyAdvantech.ToString
                    active.ActiveType = SiebelActiveType.UpdateOpportunity.ToString
                    active.OptyID = OptyId
                    active.QuoteID = Quote_ID
                    active.OrderID = Order_No
                    active.OptyStage = "100% Won-PO Input in SAP"
                    If OPTYrevenue > 0 Then
                        active.Amount = CType(OPTYrevenue, Integer)
                    End If
                    active.CreateBy = HttpContext.Current.User.Identity.Name
                    'active.CreatedDate = Now
                    Dim result As Boolean = SiebelBusinessLogic.UpdateOpportunityCommand(active)
                    If Not result Then
                        Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com",
                                                      String.Format("Update Opty to Won for SO:{0} OptyID:{1}", Order_No, OptyId), "Create Siebel Active Failed", True, "", "")
                    End If
                End If
            Catch ex As Exception
                Util.SendEmail("myadvantech@advantech.com", "myadvantech@advantech.com",
                               String.Format("Update Opty to Won for SO:{0} OptyID:{1}", Order_No, OptyId), ex.ToString(), True, "", "")
            End Try
        End If

        If b1 Then
            Return True
        Else
            Return False
        End If
    End Function
    Public Shared Function UpdateSAPSOShipToAttention(ByVal Order_No As String, ByRef retTable As DataTable, ByVal IsSAPProductionServer As Boolean) As Boolean
        Dim ShipToId As String = "", Attention As String = ""
        Dim A As New MyOrderDSTableAdapters.ORDER_PARTNERSTableAdapter
        Dim OrderPartnerdt As MyOrderDS.ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(Order_No)
        Dim FirstRow As MyOrderDS.ORDER_PARTNERSRow = OrderPartnerdt.Select("TYPE='S'").FirstOrDefault()
        If FirstRow IsNot Nothing Then
            ShipToId = FirstRow.ERPID
            Attention = FirstRow.ATTENTION
        End If
        If Not String.IsNullOrEmpty(ShipToId) AndAlso Not String.IsNullOrEmpty(Attention) Then
            Try
                SAPDAL.SAPDAL.UpdateSAPSOShipToAttention(Order_No, ShipToId, Attention, retTable, IsSAPProductionServer)
            Catch ex As Exception
                Util.SendEmail("tc.chen@advantech.com.tw,ming.zhao@advantech.com.cn", "myadvanteh@advantech.com", "UpdateSAPSOShipToAttention Failed for OrderNo  " + Order_No, ex.ToString, True, "ebusiness.aeu@advantech.eu", "")
            End Try
        End If
        Return True
    End Function
    Public Shared Function ProcessAfterOrderFailed(ByVal Order_No As String, ByRef ErrMsg As String) As Boolean
        'If Not HttpContext.Current.User.Identity.Name.EndsWith("@advantech.com", StringComparison.CurrentCultureIgnoreCase) Then
        '    SendFailedOrderMail(Order_No)
        'End If
        'SendPI(Order_No)
        SendFailedOrderMail(Order_No)
        If Not Order_No.StartsWith("AUSO", StringComparison.CurrentCultureIgnoreCase) _
            AndAlso Not Order_No.StartsWith("AMXO", StringComparison.CurrentCultureIgnoreCase) _
             AndAlso Not Order_No.StartsWith("AIAG", StringComparison.CurrentCultureIgnoreCase) _
             AndAlso Not HttpContext.Current.Session("ORG_ID").ToString.StartsWith("CN") Then
            SendPI(Order_No)
        End If
        Return True
    End Function


    Public Shared Function ProcStatus_Save(ByVal Proc_Status_DT As DataTable, ByVal strOrderNO As String, ByVal xStatus As String, Optional ByVal type As String = "ZOR2") As Integer
        'Try
        'If Proc_Status_DT.Rows.Count > 0 Then
        '    Dim myOrderProcStatus As New ORDER_PROC_STATUS("b2b", "ORDER_PROC_STATUS")
        '    Dim LineSEQ As Integer = 0
        '    myOrderProcStatus.Delete(String.Format("order_no='{0}'", strOrderNO))

        '    For i As Integer = 0 To Proc_Status_DT.Rows.Count - 1
        '        LineSEQ = myOrderProcStatus.getMaxLineSeq(strOrderNO) + 1
        '        myOrderProcStatus.Add(strOrderNO, LineSEQ, CInt(Proc_Status_DT.Rows(i).Item("Number")), Proc_Status_DT.Rows(i).Item("MESSAGE"), Now.Date, xStatus)
        '    Next
        'End If
        If Proc_Status_DT.Rows.Count > 0 Then
            Dim A As New MyOrderDSTableAdapters.ORDER_PROC_STATUS2TableAdapter
            A.DeleteOrderNO(strOrderNO)
            For i As Integer = 0 To Proc_Status_DT.Rows.Count - 1
                A.Insert(strOrderNO, i + 1, CInt(Proc_Status_DT.Rows(i).Item("Number")), Proc_Status_DT.Rows(i).Item("MESSAGE"), Now.Date, xStatus, type)
            Next
        End If
        'Catch ex As Exception
        '    Return -1
        'End Try
        Return 1
    End Function
    Public Shared Function ProcStatus_Save2(ByVal message As String, ByVal strOrderNO As String, ByVal type As String) As Integer
        Try
            If Not String.IsNullOrEmpty(message) AndAlso Not String.IsNullOrEmpty(type) Then
                Dim A As New MyOrderDSTableAdapters.ORDER_PROC_STATUS2TableAdapter
                A.Insert(strOrderNO, 0, 0, message, Now, 0, type)
            End If
        Catch ex As Exception
        End Try
        Return 1
    End Function
    Public Shared Function SendSPR_NOPI(ByVal order_no As String) As Integer
        'If Util.IsTestingQuote2Order() Then
        '    SendSPR_NOPIv2(order_no)
        '    Return 1
        'End If
        Dim quote_id As Object = dbUtil.dbExecuteScalar("b2b", "select top 1 OptyID from order_detail where OptyID is not null and OptyID <> '' and ORDER_ID ='" + order_no + "'")
        If quote_id Is Nothing Then
            Return 0
            Exit Function
        End If
        Dim quoteId As String = quote_id.ToString()
        Dim IsSend As Boolean = False
        Dim WS As New quote.quoteExit
        WS.Timeout = -1
        If WS.isQuoteExpired(quoteId) Then
            Return 0
            Exit Function
        End If
        Dim ds As New DataSet
        WS.getQuotationDetailById(quoteId, ds)
        If ds.Tables.Count > 0 AndAlso ds.Tables(0).Rows.Count > 0 Then
            Dim DT As DataTable = ds.Tables(0)
            If DT.Rows.Count > 0 Then
                Dim MailBody As String = "<table width=""90%"" border=""1""><tr><td>Part_NO</td><td>Line</td><td>QTY</td><td>Spr_NO</td></tr>"
                For i As Integer = 0 To DT.Rows.Count - 1
                    With DT.Rows(i)
                        If Not IsDBNull(.Item("sprno")) AndAlso Not String.IsNullOrEmpty(.Item("sprno")) Then
                            MailBody += String.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>", .Item("partno"), .Item("line_no"), .Item("qty"), .Item("sprno"))
                            IsSend = True
                        End If
                    End With
                Next
                MailBody += "</table>"
                Dim Subject_Email As String = "Advantech Order(" + order_no + ") contains SPR Number"
                If IsSend Then
                    MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", "AESC.SCM@advantech.com", "", "ming.zhao@advantech.com.cn;tc.chen@advantech.com.tw", Subject_Email, "", MailBody)
                End If
                'MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", "ming.zhao@advantech.com.cn;nada.liu@advantech.com.cn;tc.chen@advantech.com.tw", "", "nada.liu@advantech.com.cn;tc.chen@advantech.com.tw", Subject_Email, "", MailBody)
            End If
        End If
        Return 1
    End Function
    Public Shared Function SendUSDSoPiforEU(ByVal subject As String, ByVal mailbody As String) As Boolean
        Try
            Dim FROM_Email As String = "eBusiness.AEU@advantech.eu", TO_Email As String = "AESC.SCM@advantech.com", CC_Email As String = String.Empty, BCC_Email As String = "myadvantech@advantech.com"
            If Util.IsTesting() Then
                Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
                MailUtil.Utility_EMailPage(FROM_Email, "myadvantech@advantech.com", "", "", subject, "", Expandstr + mailbody)
            Else
                MailUtil.Utility_EMailPage(FROM_Email, TO_Email, "", "myadvantech@advantech.com", subject, "", mailbody)
            End If
        Catch ex As Exception
            MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", "myadvantech@advantech.com", "", "", "Send USD SO PI for EU  error", "", subject + vbNewLine + ex.ToString())
            Return False
        End Try
        Return True
    End Function
    ''Public Shared Function SendSPR_NOPIv2(ByVal order_no As String) As Integer
    ''    Dim quote_id As Object = dbUtil.dbExecuteScalar("b2b", "select top 1 OptyID from order_detail where OptyID is not null and OptyID <> '' and ORDER_ID ='" + order_no + "'")
    ''    If quote_id Is Nothing Then
    ''        Return 0
    ''        Exit Function
    ''    End If
    ''    Dim quoteId As String = quote_id.ToString()
    ''    Dim IsSend As Boolean = False
    ''    'Dim WS As New quote.quote-Exit
    ''    'WS.Timeout = -1
    ''    'If WS.isQuoteExpired(quoteId) Then
    ''    '    Return 0
    ''    '    Exit Function
    ''    'End If
    ''    'Dim ds As New DataSet
    ''    'WS.getQuotationDetailById(quoteId, ds)
    ''    Dim MyQuoteMaster As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(quoteId)
    ''    If MyQuoteMaster.X_isExpired() Then
    ''        Return 0
    ''        Exit Function
    ''    End If
    ''    Dim MyQuoteDetail As List(Of QuotationDetail) = eQuotationUtil.GetQuoteDetailByQuoteid(quoteId)
    ''    If MyQuoteDetail.Count > 0 Then
    ''        If MyQuoteDetail.Count > 0 Then
    ''            Dim MailBody As String = "<table width=""90%"" border=""1""><tr><td>Part_NO</td><td>Line</td><td>QTY</td><td>Spr_NO</td></tr>"
    ''            For Each Q As QuotationDetail In MyQuoteDetail
    ''                With Q
    ''                    If Not IsDBNull(.sprNo) AndAlso Not String.IsNullOrEmpty(.sprNo) Then
    ''                        MailBody += String.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>", .partNo, .line_No, .qty, .sprNo)
    ''                        IsSend = True
    ''                    End If
    ''                End With
    ''            Next
    ''            MailBody += "</table>"
    ''            Dim Subject_Email As String = "Advantech Order(" + order_no + ") contains SPR Number"
    ''            If IsSend Then
    ''                MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", "AESC.SCM@advantech.com", "", "ming.zhao@advantech.com.cn;tc.chen@advantech.com.tw", Subject_Email, "", MailBody)
    ''            End If
    ''            'MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", "ming.zhao@advantech.com.cn;nada.liu@advantech.com.cn;tc.chen@advantech.com.tw", "", "nada.liu@advantech.com.cn;tc.chen@advantech.com.tw", Subject_Email, "", MailBody)
    ''        End If
    ''    End If
    ''    Return 1
    ''End Function 
    Public Shared Function SendPI(ByVal order_no As String, Optional ByVal IsRecover As Boolean = False) As Integer

        'Ryan 20180430 Comment below code out due to Louis requested not to send this notification to AEU anymore.
        'Try
        '    Dim returnint As Integer = SendSPR_NOPI(order_no)
        'Catch ex As Exception
        '    MailUtil.Utility_EMailPage("myadvantech@advantech.com", "myadvantech@advantech.com", "", "", "Send Sprno PI error", "", ex.ToString())
        'End Try

        Dim orderCompDt As New DataTable
        Dim apt As New SqlClient.SqlDataAdapter(
            " select top 1 a.PO_NO, a.SOLDTO_ID, a.CURRENCY,b.COMPANY_NAME from ORDER_MASTER a " +
            " inner join SAP_DIMCOMPANY b on a.SOLDTO_ID=b.COMPANY_ID where a.ORDER_NO=@ONO",
            ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("ONO", order_no)
        apt.Fill(orderCompDt) : apt.SelectCommand.Connection.Close()
        If orderCompDt.Rows.Count = 0 Then Return 0
        Dim FROM_Email As String = "myadvantech@advantech.com", TO_Email As String = HttpContext.Current.User.Identity.Name

        If HttpContext.Current.Session("org_id").ToString.Equals("SG01", StringComparison.OrdinalIgnoreCase) Then
            'SG01
            FROM_Email = "asg.op@advantech.com"
        ElseIf HttpContext.Current.Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
            'US01
            FROM_Email = HttpContext.Current.User.Identity.Name
            Dim EmployeeEmail As Object = dbUtil.dbExecuteScalar("MY", String.Format(" select top 1 A.EMAIL from  dbo.SAP_EMPLOYEE A INNER JOIN ORDER_MASTER B ON B.EMPLOYEEID=A.SALES_CODE where B.ORDER_ID= '{0}' and dbo.IsEmail(A.EMAIL)=1 and A.PERS_AREA='US01'", order_no))
            If EmployeeEmail IsNot Nothing AndAlso Not String.IsNullOrEmpty(EmployeeEmail) AndAlso Util.IsValidEmailFormat(EmployeeEmail.ToString.Trim) Then
                FROM_Email = EmployeeEmail
            End If
        ElseIf String.Equals(HttpContext.Current.Session("org_id"), "TW01", StringComparison.CurrentCultureIgnoreCase) Then
            'TW01
            FROM_Email = "b2badmin@advantech.com"
        ElseIf String.Equals(HttpContext.Current.Session("org_id"), "TW20", StringComparison.CurrentCultureIgnoreCase) Then
            'TW20
            FROM_Email = "b2badmin@advantech.com"
        ElseIf String.Equals(HttpContext.Current.Session("SAP Sales Office"), "3410") AndAlso String.Equals(HttpContext.Current.Session("org_id"), "EU10", StringComparison.CurrentCultureIgnoreCase) AndAlso True Then
            'EU10 & BBIR
            FROM_Email = "BB.Orders.IE@advantech.com"
        End If

        Dim CC_Email As String = "", BCC_Email As String = "myadvantech@advantech.com;"
        Dim pono As String = orderCompDt.Rows(0).Item("po_no"), compName As String = orderCompDt.Rows(0).Item("company_name"), soldtoId As String = orderCompDt.Rows(0).Item("SOLDTO_ID")
        Dim subject_email As String = "Advantech Order (" + pono + "/" + order_no + ") for " + compName + " (" + soldtoId + ")"
        Dim attachfile As String = "", mailbody As String = ""
        mailbody = GetPI(order_no, 0)
        Dim strCC As String = "", strCC_External As String = ""
        'Get receiver from SAP
        Dim j As Integer = GetPIcc(order_no, strCC, strCC_External)

        TO_Email = HttpContext.Current.Session("USER_ID")
        If String.IsNullOrEmpty(TO_Email) Then TO_Email = String.Empty

        If strCC_External.Trim <> "" Then
            TO_Email = TO_Email + ";" + strCC_External
        End If
        CC_Email = ""

        '-Ryan 2016/01/06 Add for Sending PI to ANA Aonline Manager
        Dim myOrderDetail1 As New order_Detail("B2B", "order_Detail")
        Dim Quote_id As String = String.Empty
        Dim IsUSAonlineQuote2Order As Boolean = False
        If AuthUtil.IsUSAonlineSales(HttpContext.Current.Session("USER_ID")) AndAlso myOrderDetail1.isQuoteOrder(order_no, Quote_id) Then
            IsUSAonlineQuote2Order = True
        End If
        '-End

        Dim TO_Email_Internal As String = "yl.huang@advantech.com.tw;frank.chung@advantech.com.tw;alex.chiu@advantech.com.tw"
        'Ryan 20170906 BBUS testing sites settings
        If AuthUtil.IsBBUS AndAlso Util.IsTesting Then
            TO_Email_Internal = TO_Email_Internal + ";" + HttpContext.Current.Session("USER_ID")
        End If

        'Ryan 20170705 ACN D/P/T quotations settings
        If HttpContext.Current.Session("org_id").ToString.StartsWith("CN") AndAlso MyServices.IsACNOrderNeedsApproval(order_no, Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(HttpContext.Current.Session("org_id").ToString), HttpContext.Current.Session("org_id")) Then
            subject_email = "Advantech ACN Quotations (" + pono + "/" + order_no + ") for " + compName + " (" + soldtoId + ")"
            mailbody = String.Format("This order contains D/P/T item(s) and needs IS approval.<hr/>Please provide this mail and related information to inside sales for further processing.<hr/>") + mailbody
        End If

        '第一次發信，發給外部(TO_Email = TO_Email + ";" + strCC_External)
        If Not IsRecover Then
            If Getorder_Master_Extension(order_no) Then
                If Util.IsTesting() OrElse IsUSAonlineQuote2Order Then
                    Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
                    MailUtil.Utility_EMailPage("myadvantech@advantech.com", TO_Email_Internal, "", "", subject_email, attachfile, Expandstr + mailbody)
                Else
                    MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)
                End If
            End If
        End If
        'Ryan 20180625 BCC: polar.yu for TW01/TW20
        If String.Equals(HttpContext.Current.Session("org_id"), "TW01", StringComparison.CurrentCultureIgnoreCase) OrElse
            String.Equals(HttpContext.Current.Session("org_id"), "TW20", StringComparison.CurrentCultureIgnoreCase) Then
            If Not HttpContext.Current.Session("company_id").ToString.StartsWith("T", StringComparison.CurrentCultureIgnoreCase) Then
                BCC_Email = BCC_Email & "polar.yu@advantech.com.tw; "
            End If
        End If
        TO_Email = strCC

        'CC_Email = "eBusiness.AEU@advantech.eu;"
        Dim myOrderDetail As New order_Detail("B2B", "order_Detail")
        Dim ISBTO As Integer = myOrderDetail.isBtoOrder(order_no)
        If HttpContext.Current.Session("org_id").ToString.Trim.ToUpper = "EU10" Then
            'CC_Email = CC_Email + "claudio.cerqueti@advantech.nl;"
            CC_Email = CC_Email + "order.AEU@advantech.com;"
            'If ISBTO = 0 Then '如果是單品
            '    CC_Email = CC_Email + "margot.vandommelen@advantech.nl;jos.vanberlo@advantech.nl;"
            'End If
            If orderCompDt.Rows(0).Item("CURRENCY") IsNot Nothing AndAlso String.Equals(orderCompDt.Rows(0).Item("CURRENCY"), "USD", StringComparison.CurrentCultureIgnoreCase) Then
                SendUSDSoPiforEU(subject_email, mailbody)
            End If
        End If
        If HttpContext.Current.Session("org_id").ToString.Equals("SG01", StringComparison.OrdinalIgnoreCase) Then
            CC_Email = CC_Email + "asg.op@advantech.com;"
        End If

        If ISBTO = 1 Then  '如果是組裝單
            '取得各區組裝單的收件者，請進到MyCartOrderBizDAL.GetBTOSOrderNotifyList中查看程式邏輯
            Dim arr As ArrayList = MyCartOrderBizDAL.GetBTOSOrderNotifyList(HttpContext.Current.Session("org_id"))
            TO_Email += String.Join(";", arr.ToArray())

            'Ryan 20170202 If is CN10 or CN30, send BTOS mail
            If HttpContext.Current.Session("org_id").ToString.StartsWith("CN") Then
                Dim ACNDOC As String = ACNUtil.GetACNBtosMailBody(order_no)
                Dim ACNBTOSReceiver As String = String.Empty

                ' Get Receiver by ORG and storage location
                If HttpContext.Current.Session("org_id").ToString.Equals("CN10", StringComparison.OrdinalIgnoreCase) Then
                    If HttpContext.Current.Session("ACN_StorageLocation") Is Nothing Then
                        HttpContext.Current.Session("ACN_StorageLocation") = "1000"
                    End If
                    If HttpContext.Current.Session("ACN_StorageLocation").ToString().Equals("1000") Then
                        ACNBTOSReceiver = "B2B.AKMC_CTOS@advantech.com.cn;"
                    ElseIf HttpContext.Current.Session("ACN_StorageLocation").ToString().Equals("2000") Then
                        ACNBTOSReceiver = "B2B.ABJ@advantech.corp;"
                    End If
                ElseIf HttpContext.Current.Session("org_id").ToString.Equals("CN30", StringComparison.OrdinalIgnoreCase) Then
                    ACNBTOSReceiver = "B2B.AKMC_CTOS@advantech.com.cn;"
                ElseIf HttpContext.Current.Session("org_id").ToString.Equals("CN70", StringComparison.OrdinalIgnoreCase) Then
                    ACNBTOSReceiver = "B2B.AKMC_CTOS@advantech.com.cn;"
                End If

                ' Send mail
                If Util.IsTesting() Then
                    Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>", FROM_Email, ACNBTOSReceiver)
                    MailUtil.Utility_EMailPage("myadvantech@advantech.com", TO_Email_Internal, "", "", "Advantech(China) 系统组装单 (" + order_no + ")", "", Expandstr + ACNDOC)
                Else
                    MailUtil.Utility_EMailPage("myadvantech@advantech.com", ACNBTOSReceiver, "", "myadvantech@advantech.com;", "Advantech(China) 系统组装单 (" + order_no + ")", "", ACNDOC)
                End If
            End If


            'Ryan 2017
            If HttpContext.Current.Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                Dim AJPSYS As String = Advantech.Myadvantech.Business.OrderBusinessLogic.GetAJPBTOSOrderAssemblyPlant(order_no)
                If Not String.IsNullOrEmpty(AJPSYS) Then
                    If AJPSYS.Equals("A") Then
                        CC_Email = CC_Email + "ajsc.ctos@advantech.com;eBusiness.AEU@advantech.eu;"
                    ElseIf AJPSYS.Equals("B") Then
                        CC_Email = CC_Email + "Brian.Tsai@advantech.com.tw;eBusiness.AEU@advantech.eu;"
                    Else

                    End If
                End If
            End If

        End If
        '20140220 Ming add current user's email when "send PI only internal" was checked for internal sales place order
        If Util.IsInternalUser2() Then
            Dim CurrentUser As String = HttpContext.Current.Session("USER_ID")
            If Not TO_Email.ToLower.Contains(CurrentUser.ToLower) Then
                TO_Email = TO_Email + ";" + CurrentUser
            End If
        End If
        'end

        'Ryan 20160420 Add Anne to to_email list if is Check Point order.
        If order_no.StartsWith("CP", StringComparison.CurrentCultureIgnoreCase) Then
            TO_Email = TO_Email + ";" + "Anne.Chung@advantech.com.tw"
        End If

        'Ryan 20170419 Send all JP01 order mail to YC
        If HttpContext.Current.Session("org_id").ToString.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
            TO_Email = TO_Email + ";" + "Yc.Liu@advantech.com"
        End If

        'Ryan 20170919
        If AuthUtil.IsBBUS Then
            TO_Email = TO_Email + ";" + "BB.Orders@advantech.com"

            If Util.IsTesting Then
                TO_Email_Internal = TO_Email_Internal + ";" + "BB.Orders@advantech.com"
                subject_email = "Testing order - " + subject_email
                mailbody = "This is an Testing order from MyAdvantech staging site.<hr/>" + mailbody
            End If
        End If

        'Ryan 20171006 Send mail to BB.Orders.IE@advantech.com if SAP Sales Office = 3410 (B+B Ireland)
        If HttpContext.Current.Session("SAP Sales Office") IsNot Nothing AndAlso HttpContext.Current.Session("SAP Sales Office") = "3410" Then
            TO_Email = TO_Email + ";" + "BB.Orders.IE@advantech.com"
        End If

        'Ryan 20180118 Only send mail to DLOG employees (end with @advantech-dlog.com)
        If AuthUtil.IsADloG Then
            'TO_EMAIL
            TO_Email = TO_Email + ";" + "order@advantech-dlog.com;"
            Dim listTO As List(Of String) = TO_Email.Split(";").ToList
            TO_Email = ""
            For Each s As String In listTO
                If Not String.IsNullOrEmpty(s) AndAlso s.EndsWith("@advantech-dlog.com", StringComparison.OrdinalIgnoreCase) AndAlso Not TO_Email.Contains(s) Then
                    TO_Email = TO_Email + s + ";"
                End If
            Next

            'CC_EMAIL
            Dim listCC As List(Of String) = CC_Email.Split(";").ToList
            CC_Email = ""
            For Each s As String In listCC
                If Not String.IsNullOrEmpty(s) AndAlso s.EndsWith("@advantech-dlog.com", StringComparison.OrdinalIgnoreCase) AndAlso Not CC_Email.Contains(s) Then
                    CC_Email = CC_Email + s + ";"
                End If
            Next
        End If

        'Ryan 20170707 Send internal email
        If AuthUtil.IsInterConUserV3 Then
            Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)

            'Get Attached file info from db
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format(" SELECT top 1 a.* FROM InterconUploadedFile a inner join Cart2OrderMaping b on a.Cart_ID = b.CartID where b.OrderNo = '{0}'", order_no))
            If Not dt Is Nothing AndAlso dt.Rows.Count > 0 Then
                Dim FileName As String = dt.Rows(0).Item("FileName").ToString
                Dim FileData As New System.IO.MemoryStream(CType(dt.Rows(0).Item("FileData"), Byte()))

                If Util.IsTesting Then
                    MailUtil.SendEmailV2("myadvantech@advantech.com", TO_Email_Internal, "", "", subject_email, "", Expandstr + mailbody, "", FileData, FileName)
                Else
                    MailUtil.SendEmailV2(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, "", mailbody, "", FileData, FileName)
                End If
            Else
                If Util.IsTesting Then
                    MailUtil.Utility_EMailPage("myadvantech@advantech.com", TO_Email_Internal, "", "", subject_email, attachfile, Expandstr + mailbody)
                Else
                    Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)
                End If
            End If
        ElseIf IsUSAonlineQuote2Order Then
            Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
            Dim TO_Email_Internal_Extend As String = String.Empty
            If OrderBusinessLogic.IsRiskOrder(order_no, RiskOrderInputType.Order) _
                AndAlso IsUSAonlineQuote2Order AndAlso QuoteBusinessLogic.IsFeiOffice(Quote_id) Then

                'Over write the PI mail body, 'ABCD indicator' and 'Is X/Y part' info will be included in the mail body 
                mailbody = GetPI(order_no, 3)
                subject_email = "Potential Risk Buy Order – Need your Attention"
                Expandstr = ""

                'If the site is running on production site, then send the PI(proforma invoice, 形式發票) mail to managers
                If Not Util.IsTesting() Then
                    TO_Email_Internal_Extend = ";tc.chen@advantech.com.tw;Fei.Khong@advantech.com;Denise.Kwong@advantech.com;Lyna.Nguyen@advantech.com;viridiana.valencia@advantech.com"
                End If
            End If
            MailUtil.Utility_EMailPage("myadvantech@advantech.com", TO_Email_Internal & TO_Email_Internal_Extend, "", "", subject_email, attachfile, Expandstr + mailbody)
        Else
            Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
            If Util.IsTesting Then
                Dim TO_Email_Internal_Extend As String = String.Empty
                MailUtil.Utility_EMailPage("myadvantech@advantech.com", TO_Email_Internal & TO_Email_Internal_Extend, "", "", subject_email, attachfile, Expandstr + mailbody)
            Else
                Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)
            End If
        End If

        'If Util.IsTesting() OrElse IsUSAonlineQuote2Order Then
        '    Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
        '    Dim TO_Email_Internal_Extend As String = String.Empty
        '    If OrderBusinessLogic.IsRiskOrder(order_no, RiskOrderInputType.Order) _
        '        AndAlso IsUSAonlineQuote2Order AndAlso QuoteBusinessLogic.IsFeiOffice(Quote_id) Then

        '        'Over write the PI mail body, 'ABCD indicator' and 'Is X/Y part' info will be included in the mail body 
        '        mailbody = GetPI(order_no, 3)
        '        subject_email = "Potential Risk Buy Order – Need your Attention"
        '        Expandstr = ""

        '        'If the site is running on production site, then send the PI(proforma invoice, 形式發票) mail to managers
        '        If Not Util.IsTesting() Then
        '            TO_Email_Internal_Extend = ";tc.chen@advantech.com.tw;Fei.Khong@advantech.com;Denise.Kwong@advantech.com;Kesy.Lee@advantech.com;Lyna.Nguyen@advantech.com"
        '        End If
        '    End If
        '    MailUtil.Utility_EMailPage("myadvantech@advantech.com", TO_Email_Internal & TO_Email_Internal_Extend, "", "", subject_email, attachfile, Expandstr + mailbody)
        'Else
        '    Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)
        'End If


        '\ Ming sent PI to 'UUMM001' for MexicoT2Customer 2013-08-26
        Dim ParentCompany As String = String.Empty
        If Util.IsMexicoT2Customer(soldtoId, ParentCompany) Then
            BCC_Email = "myadvantech@advantech.com" : CC_Email = ""
            TO_Email = GetContactsByCompanyID(ParentCompany)
            mailbody = GetPI(order_no, 1)
            If Util.IsTesting() Then
                Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
                MailUtil.Utility_EMailPage("myadvantech@advantech.com", "tc.chen@advantech.com.tw;ming.zhao@advantech.com.cn;frank.chung@advantech.com.tw", "", "", subject_email, attachfile, Expandstr + mailbody)
            Else
                MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)
            End If
        End If
        '/ end
        Return 1
    End Function
    Public Shared Function Getorder_Master_Extension(ByVal OrderNo As String) As Boolean
        'If Util.IsInternalUser2() Then Return True
        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", "select  top 1 isnull(PI2CUSTOMER_FLAG,'1') as FLAG  from order_Master_ExtensionV2 where ORDER_ID ='" + OrderNo + "'")
        If dt.Rows.Count = 1 AndAlso dt.Rows(0).Item("FLAG") = "1" Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function GetPIcc_old(ByVal Order_no As String, ByRef Str_cc As String, ByRef Str_cc_External As String) As Integer
        Dim InvalidOrg As String = ConfigurationManager.AppSettings("InvalidOrg").ToString.Trim()
        Dim CDT As DataTable = dbUtil.dbGetDataTable("my", "select distinct b.EMAIL  from SAP_COMPANY_PARTNERS a inner join SAP_EMPLOYEE b on a.SALES_CODE=b.SALES_CODE " _
                                                            & " and a.ORG_ID not in " + InvalidOrg + "" _
                                                            & " where a.COMPANY_ID='" + HttpContext.Current.Session("company_id") + "' and dbo.IsEmail(b.EMAIL)=1 ORDER BY b.EMAIL ")
        If CDT.Rows.Count > 0 Then
            For i As Integer = 0 To CDT.Rows.Count - 1
                With CDT.Rows(i)
                    If Not IsDBNull(.Item("EMAIL")) AndAlso .Item("EMAIL").ToString <> "" Then
                        Str_cc = Str_cc & .Item("EMAIL").ToString & ";"
                    End If
                End With
            Next
        End If
        Dim sql1 As String = "select CONTACT_EMAIL from SAP_COMPANY_CONTACTS where COMPANY_ID='" + HttpContext.Current.Session("company_id") + "'"
        Dim sql2 As String = "select a.EMAIL as KEYEmail from sap_employee a inner join order_master b on a.SALES_CODE=b.KEYPERSON WHERE a.PERS_AREA='" + HttpContext.Current.Session("org_id") + "'  and dbo.IsEmail(a.EMAIL)=1 and b.ORDER_ID='" + Order_no + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", sql1 + " UNION " + sql2)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                With dt.Rows(i)
                    If Not IsDBNull(.Item("CONTACT_EMAIL")) AndAlso .Item("CONTACT_EMAIL").ToString <> "" AndAlso Util.IsValidEmailFormat(.Item("CONTACT_EMAIL")) Then
                        If Util.IsInternalUser(.Item("CONTACT_EMAIL").ToString) Then
                            Str_cc = Str_cc & .Item("CONTACT_EMAIL").ToString & ";"
                        Else
                            Str_cc_External = Str_cc_External & .Item("CONTACT_EMAIL").ToString & ";"
                        End If
                    End If
                End With
            Next
        End If
        Return 1
    End Function
    Public Shared Function GetContactsByCompanyID(ByVal CompanyID As String) As String
        Dim sql As String = String.Format("select CONTACT_EMAIL from SAP_COMPANY_CONTACTS where COMPANY_ID='{0}'", CompanyID)
        Dim strTo As String = String.Empty
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", sql)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                With dt.Rows(i)
                    If Not IsDBNull(.Item("CONTACT_EMAIL")) AndAlso Not String.IsNullOrEmpty(.Item("CONTACT_EMAIL").ToString) AndAlso Util.IsValidEmailFormat(.Item("CONTACT_EMAIL")) Then
                        strTo = strTo & .Item("CONTACT_EMAIL").ToString.Trim & ";"
                    End If
                End With
            Next
        End If
        Return strTo
    End Function
    Public Shared Function GetPIcc(ByVal Order_no As String, ByRef Str_cc As String, ByRef Str_cc_External As String) As Integer

        'Ryan 20170309 Comment out entire TW01 special mail receiver logic, will take SAP settings just like other regions did.
        '\ming add for B2B 2013-8-8
        'If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso String.Equals(HttpContext.Current.Session("org_id"), "TW01", StringComparison.CurrentCultureIgnoreCase) Then
        '    '2016/3/30 ICC Exclude T16270654 (駿緯國際) company
        '    If IsATWCustomer() AndAlso Not String.Equals(HttpContext.Current.Session("company_id"), "T16270654") Then
        '        Dim sqlpartner As String = "select  a.EMAIL  from  SAP_EMPLOYEE a  inner join ORDER_PARTNERS b on b.ERPID = a.SALES_CODE where b.TYPE in ('E','E2','E3','KIP') and b.ORDER_ID ='" + Order_no + "' and dbo.IsEmail(a.EMAIL)=1  "
        '        Dim sqlWE As String = "  select  a.EMAIL  from  SAP_EMPLOYEE a  inner join SAP_COMPANY_EMPLOYEE b on b.SALES_CODE = a.SALES_CODE where b.COMPANY_ID ='" + HttpContext.Current.Session("company_id").ToString.Trim + "' and dbo.IsEmail(a.EMAIL)=1 and b.PARTNER_FUNCTION ='VE' and b.SALES_ORG='TW01'"
        '        Dim dtATW As DataTable = dbUtil.dbGetDataTable("MY", sqlpartner)
        '        If dtATW.Rows.Count > 0 Then
        '            For Each dr As DataRow In dtATW.Rows
        '                If Not Str_cc.Contains(dr.Item("EMAIL").ToString.Trim.ToLower) Then
        '                    Str_cc = Str_cc & dr.Item("EMAIL").ToString.Trim.ToLower & ";"
        '                End If
        '            Next
        '        End If
        '        dtATW = dbUtil.dbGetDataTable("MY", sqlWE)
        '        If dtATW.Rows.Count > 0 Then
        '            For Each dr As DataRow In dtATW.Rows
        '                If Not Str_cc.Contains(dr.Item("EMAIL").ToString.Trim.ToLower) Then
        '                    Str_cc = Str_cc & dr.Item("EMAIL").ToString.Trim.ToLower & ";"
        '                End If
        '            Next
        '        End If
        '        If HttpContext.Current.Session("company_id").ToString.StartsWith("T", StringComparison.CurrentCultureIgnoreCase) Then
        '            If String.Equals(HttpContext.Current.Session("company_id"), "T16270654") Then
        '                'Str_cc &= "Brian.Tsai@advantech.com.tw; Gary.Chen@advantech.com.tw; Vanage.Lin@advantech.com.tw; julia.lin@advantech.com.tw;winnie.tsai@advantech.com.tw;sandy.yao@advantech.com.tw;jenny.lin@advantech.com.tw;fenny.hsu@advantech.com.tw;iris.wang@advantech.com.tw;yih.wu@advantech.com.tw;"      ' Revised by Abow.wang     2009/09/24
        '                'Ming add 20140401 Vanage.Lin 要求更改
        '                'Str_cc &= "Sales.ATW.AOL-EP@advantech.com;Vanage.Lin@advantech.com.tw;"
        '                'ICC 2016/3/17 Remove [Sales.ATW.AOL-EP] mail group by Vanage's request
        '                Str_cc &= "Vanage.Lin@advantech.com.tw;"
        '            ElseIf String.Equals(HttpContext.Current.Session("company_id"), "T27284640") Then
        '                Str_cc &= "Vanage.Lin@advantech.com.tw;Evon.Tang@advantech.com.tw;"
        '            Else
        '                'Str_cc &= "Brian.Tsai@advantech.com.tw; Gary.Chen@advantech.com.tw; Vanage.Lin@advantech.com.tw; Alice.Chang@advantech.com.tw; Joyce.Chen@advantech.com.tw; julia.lin@advantech.com.tw;winnie.tsai@advantech.com.tw;sandy.yao@advantech.com.tw;jenny.lin@advantech.com.tw;fenny.hsu@advantech.com.tw;iris.wang@advantech.com.tw;yih.wu@advantech.com.tw;"      ' Revised by Abow.wang     2009/09/24
        '            End If
        '        End If
        '        Return 1
        '        Exit Function
        '    End If

        '    Dim dtB2Bcontact As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select userid from B2B_COMPANY_CONTACT where company_id='{0}'", HttpContext.Current.Session("company_id")))
        '    If dtB2Bcontact.Rows.Count > 0 Then
        '        For i As Integer = 0 To dtB2Bcontact.Rows.Count - 1
        '            With dtB2Bcontact.Rows(i)
        '                If Not IsDBNull(.Item("userid")) AndAlso Not String.IsNullOrEmpty(.Item("userid").ToString) AndAlso Util.IsValidEmailFormat(.Item("userid")) Then
        '                    If Util.IsInternalUser(.Item("userid").ToString) Then
        '                        Str_cc = Str_cc & .Item("userid").ToString & ";"
        '                    Else
        '                        Str_cc_External = Str_cc_External & .Item("userid").ToString & ";"
        '                    End If
        '                End If
        '            End With
        '        Next
        '    End If

        '    If Not Util.IsMexicoT2Customer(HttpContext.Current.Session("company_id"), "") Then
        '        Return 1
        '        Exit Function
        '    End If
        'End If


        If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso String.Equals(HttpContext.Current.Session("org_id"), "KR01", StringComparison.CurrentCultureIgnoreCase) Then
            If String.Equals(HttpContext.Current.Session("company_id"), "AKRCC0001") Then
                Str_cc &= "maria.choi@advantech.co.kr;"
            End If
        End If

        Dim InvalidOrg As String = ConfigurationManager.AppSettings("InvalidOrg").ToString.Trim()

        'First part of SAP select string
        Dim OracleSCP As New StringBuilder
        OracleSCP.AppendLine(" select b.kunnr as COMPANY_ID, b.vkorg as ORG_ID, b.vtweg as DIST_CHANN, ")
        OracleSCP.AppendLine(" b.spart as DIVISION, b.parvw as PARTNER_FUNCTION, b.kunn2 as PARENT_COMPANY_ID, ")
        OracleSCP.AppendLine(" b.lifnr as VENDOR_CREDITOR, b.pernr as SALES_CODE, b.parnr as PARTNER_NUMBER, b.KNREF,  ")
        OracleSCP.AppendLine(" b.DEFPA from saprdp.kna1 a inner join saprdp.knvp b on a.kunnr=b.kunnr ")
        OracleSCP.AppendLine(" where a.mandt='168' and b.mandt='168' ")
        'OracleSCP.AppendLine(" and b.vkorg in ('AU01','BR01','CN01','CN10','EU10','JP01','KR01','MY01','SG01','TL01','TW01','US01') ")
        OracleSCP.AppendFormat(" and b.vkorg in ('{0}') ", HttpContext.Current.Session("org_id"))

        'Ryan 20171101 Exclude partner type ZD (credit controller)
        OracleSCP.AppendLine(" and b.parvw <> 'ZD' ")

        'Ryan 20170309 Sales Co-Own CANNOT be added to mail list if customer is Alitek or Lima per Stefanie's suggestion.
        If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso
           (String.Equals(HttpContext.Current.Session("company_id"), "ETKL001") OrElse String.Equals(HttpContext.Current.Session("company_id"), "ETRA002")) Then
            OracleSCP.AppendLine(" and b.parvw <> 'ZW' ")
        End If

        'Second part of SAP select string
        Dim OracleSEM As New StringBuilder
        OracleSEM.AppendLine(" select a.pernr as sales_code, a.werks as pers_area, a.persg as emp_group, a.persk as sub_emp_group,  ")
        OracleSEM.AppendLine(" (select b.stras from saprdp.pa0006 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as address, ")
        OracleSEM.AppendLine(" (select b.land1 from saprdp.pa0006 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as country,  a.sname, a.ename, ")
        OracleSEM.AppendLine(" (select b.vorna from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as first_name, ")
        OracleSEM.AppendLine(" (select b.nachn from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and b.mandt='168') as last_name, ")
        OracleSEM.AppendLine(" concat(concat((select b.vorna from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and  ")
        OracleSEM.AppendLine(" b.mandt='168'),'.'),(select b.nachn from saprdp.pa0002 b where b.pernr=a.pernr and rownum=1 and b.mandt='168')) as full_name, ")
        OracleSEM.AppendLine(" (select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='0020' and rownum=1) as tel, ")
        OracleSEM.AppendLine(" decode((select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='MAIL'  ")
        OracleSEM.AppendLine(" and rownum=1),null,(select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and  ")
        OracleSEM.AppendLine(" b.subty='0010' and rownum=1),(select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='MAIL' and rownum=1)) as email, ")
        OracleSEM.AppendLine(" (select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='CELL' and rownum=1) as cellphone, ")
        OracleSEM.AppendLine(" (select b.usrid_long from saprdp.pa0105 b where b.pernr=a.pernr and b.subty='MPHN' and rownum=1) as otherphone, ")
        OracleSEM.AppendLine(" decode((select b.anzkd from saprdp.pa0002 b where b.mandt='168' and rownum=1 and b.pernr=a.pernr),null,0,(select b.anzkd from saprdp.pa0002 b where b.mandt='168' and rownum=1 and b.pernr=a.pernr)) as num_of_child, ")
        OracleSEM.AppendLine(" a.Abkrs as payr_area from saprdp.pa0001 a where a.mandt='168' ")

        Dim sql As String = "select distinct b.EMAIL  from (" + OracleSCP.ToString() + ") a inner join (" + OracleSEM.ToString() + ") b on a.SALES_CODE=b.SALES_CODE " _
                                                             & " and a.ORG_ID not in " + InvalidOrg + "" _
                                                             & " where a.COMPANY_ID='" + HttpContext.Current.Session("company_id") + "'  ORDER BY b.EMAIL " ') and dbo.IsEmail(b.EMAIL)=1
        Dim CDT As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sql)
        If CDT.Rows.Count > 0 Then
            For i As Integer = 0 To CDT.Rows.Count - 1
                With CDT.Rows(i)
                    If Not IsDBNull(.Item("EMAIL")) AndAlso Util.IsValidEmailFormat(.Item("EMAIL").ToString) Then
                        Str_cc = Str_cc & .Item("EMAIL").ToString & ";"
                    End If
                End With
            Next
        End If
        Dim sql1 As String = "select CONTACT_EMAIL from SAP_COMPANY_CONTACTS where COMPANY_ID='" + HttpContext.Current.Session("company_id") + "'"
        Dim sql2 As String = "select a.EMAIL as KEYEmail from sap_employee a inner join order_master b on a.SALES_CODE=b.KEYPERSON WHERE a.PERS_AREA='" + HttpContext.Current.Session("org_id") + "'  and dbo.IsEmail(a.EMAIL)=1 and b.ORDER_ID='" + Order_no + "'"
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", sql1 + " UNION " + sql2)
        If dt.Rows.Count > 0 Then
            For i As Integer = 0 To dt.Rows.Count - 1
                With dt.Rows(i)
                    If Not IsDBNull(.Item("CONTACT_EMAIL")) AndAlso .Item("CONTACT_EMAIL").ToString <> "" AndAlso Util.IsValidEmailFormat(.Item("CONTACT_EMAIL")) Then
                        If Util.IsInternalUser(.Item("CONTACT_EMAIL").ToString) Then
                            Str_cc = Str_cc & .Item("CONTACT_EMAIL").ToString & ";"
                        Else
                            'Ming 20150908  Order Placing (external) email: Remove email from general data
                            If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso String.Equals(HttpContext.Current.Session("org_id"), "EU10", StringComparison.CurrentCultureIgnoreCase) Then
                            Else
                                Str_cc_External = Str_cc_External & .Item("CONTACT_EMAIL").ToString & ";"
                            End If
                        End If
                    End If
                End With
            Next
        End If
        'Ming 20150908  Add Partner function = CP (Contact person) for AEU
        If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso String.Equals(HttpContext.Current.Session("org_id"), "EU10", StringComparison.CurrentCultureIgnoreCase) Then
            Dim sbCP As New StringBuilder()
            sbCP.AppendFormat(" select ADR6.smtp_addr as CONTACT_EMAIL from  saprdp.ADR6")
            sbCP.AppendFormat(" inner join  saprdp.knvk  on  ADR6.PERSNUMBER=knvk.PRSNR")
            sbCP.AppendFormat(" where knvk.kunnr='{0}'", HttpContext.Current.Session("company_id"))
            Dim CPdt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sbCP.ToString())
            If CPdt.Rows.Count > 0 Then
                For i As Integer = 0 To CPdt.Rows.Count - 1
                    With CPdt.Rows(i)
                        If Not IsDBNull(.Item("CONTACT_EMAIL")) AndAlso .Item("CONTACT_EMAIL").ToString <> "" AndAlso Util.IsValidEmailFormat(.Item("CONTACT_EMAIL")) Then
                            'If Util.IsInternalUser(.Item("CONTACT_EMAIL").ToString) Then
                            '    Str_cc = Str_cc & .Item("CONTACT_EMAIL").ToString & ";"
                            'Else
                            Str_cc_External = Str_cc_External & .Item("CONTACT_EMAIL").ToString & ";"
                            'End If
                        End If
                    End With
                Next
            End If
        End If

        'Ryan 20170309 Move TW01 orginal special logic for T16270654 & T27284640 to here.
        If HttpContext.Current.Session("company_id").ToString.StartsWith("T", StringComparison.CurrentCultureIgnoreCase) Then
            If String.Equals(HttpContext.Current.Session("company_id"), "T16270654") Then
                Str_cc &= "Vanage.Lin@advantech.com.tw;"
            ElseIf String.Equals(HttpContext.Current.Session("company_id"), "T27284640") Then
                Str_cc &= "Vanage.Lin@advantech.com.tw;Evon.Tang@advantech.com.tw;"
            End If
        End If

        'Ryan 20170327 Send PI to OrderPartner's employee and key-in person for ACN & AJP users
        If HttpContext.Current.Session("org_id") IsNot Nothing AndAlso
            (HttpContext.Current.Session("org_id").ToString.StartsWith("CN") Or HttpContext.Current.Session("org_id").ToString.Equals("JP01")) Then

            Dim OrderPartners As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select distinct b.EMAIL from ORDER_PARTNERS a inner join SAP_EMPLOYEE b on a.ERPID = b.SALES_CODE where ORDER_ID = '{0}' and a.TYPE in ('E','KIP')", Order_no))
            If Not OrderPartners Is Nothing AndAlso OrderPartners.Rows.Count > 0 Then
                For i As Integer = 0 To OrderPartners.Rows.Count - 1
                    With OrderPartners.Rows(i)
                        If Not IsDBNull(.Item("EMAIL")) AndAlso .Item("EMAIL").ToString <> "" AndAlso Util.IsValidEmailFormat(.Item("EMAIL")) Then
                            If Util.IsInternalUser(.Item("EMAIL").ToString) Then
                                Str_cc = Str_cc & .Item("EMAIL").ToString & ";"
                            End If
                        End If
                    End With
                Next
            End If
        End If

        'Ryan 20171219 Get Order Contact List for BBUS 
        If AuthUtil.IsBBUS Then

            'Reset external contact first, BBUS only send PI mail to selected contact
            Str_cc_External = ""

            Dim objContacts As Object = dbUtil.dbExecuteScalar("MY", String.Format("select top 1 ADDRESS from ORDER_PARTNERS where ORDER_ID = '{0}' and TYPE = 'Contact'", Order_no))
            If Not objContacts Is Nothing AndAlso Not String.IsNullOrEmpty(objContacts.ToString) Then
                Str_cc_External = Str_cc_External & objContacts.ToString & ";"
            End If
        End If

        Return 1
    End Function
    'Public Shared Function IsATWCustomer(ByVal companyid As String, ByVal orgid As String) As Boolean
    Public Shared Function IsATWCustomer(ByVal companyid As String) As Boolean
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", "SELECT  TOP 1  COMPANY_ID  FROM  SAP_DIMCOMPANY WHERE COMPANY_ID='" + companyid + "' AND ORG_ID IN ('TW01','TW20') and COUNTRY='TW'")
        If dt.Rows.Count = 1 Then
            Return True
        End If
        Return False
    End Function
    Public Shared Function IsATWCustomer() As Boolean
        If HttpContext.Current.Session("COMPANY_ID") Is Nothing OrElse HttpContext.Current.Session("org_id") Is Nothing Then Return False
        'Return IsATWCustomer(HttpContext.Current.Session("COMPANY_ID"), HttpContext.Current.Session("org_id"))
        Return IsATWCustomer(HttpContext.Current.Session("COMPANY_ID"))
    End Function
    Public Shared Function GetKeyInPerson(ByVal userid As String) As String
        userid = userid.Trim
        If userid IsNot Nothing AndAlso Not String.IsNullOrEmpty(userid) Then
            Dim sql As New StringBuilder
            sql.AppendLine(" select top 1 isnull(SALES_CODE,'') as SALES_CODE from SAP_EMPLOYEE  ")
            sql.AppendFormat("  where EMAIL='{0}'  order by SALES_CODE ", userid)
            Dim SALES_CODE As Object = dbUtil.dbExecuteScalar("MY", sql.ToString())
            If SALES_CODE IsNot Nothing Then
                Return SALES_CODE.ToString.Trim
            End If
        End If
        Return ""
    End Function
    Public Shared Function GetKeyInPersonV2(ByVal userid As String) As DataTable
        userid = userid.Trim
        'Nada 20130923 revised for get sales ID by alias in outlook
        'Dim str As String = " select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL " & _
        '                        " from SAP_EMPLOYEE a " & _
        '                        " where a.EMAIL='" & userid & "' " & _
        '                        " order by a.SALES_CODE desc "
        Dim sqlstr As New StringBuilder
        '    Dim str As String = "select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a where  a.EMAIL in " & _
        '" (select isnull(b.EMAIL,'') from ADVANTECH_ADDRESSBOOK_ALIAS b where b.ID in " & _
        '" (select isnull(c.id,'') from ADVANTECH_ADDRESSBOOK_ALIAS c where c.Email ='" & userid & "'))"


        'Ryan 20170707 new code applied
        If IsATWCustomer() Then
            'If it is a Taiwan customer's order, put CFC team member to the key in person drop down list
            sqlstr.AppendLine("select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a where  a.EMAIL in ")

            'sqlstr.AppendLine(" (select isnull(b.EMAIL,'') from ADVANTECH_ADDRESSBOOK_ALIAS b where b.ID in ")
            'sqlstr.AppendLine(" (select isnull(c.id,'') from ADVANTECH_ADDRESSBOOK_ALIAS c where c.Email ='" & userid & "')) ")

            sqlstr.AppendLine(" (select isnull(b.ALIAS_EMAIL,'') as EMAIL from AD_MEMBER_ALIAS b where b.EMAIL in ")
            sqlstr.AppendLine(" (select isnull(c.EMAIL,'') from AD_MEMBER_ALIAS c where c.ALIAS_EMAIL ='" & userid & "')) ")


            sqlstr.AppendLine(" union ")
            sqlstr.AppendLine("select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a where ")
            sqlstr.AppendLine(" a.SALES_CODE between '16100001' and '16100122' ")
            sqlstr.AppendLine(" and a.SALES_CODE not in ('16100011') ")
            sqlstr.AppendLine(" order by a.SALES_CODE ")
        ElseIf HttpContext.Current.Session("org_id") IsNot Nothing AndAlso HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN") Then

            sqlstr.AppendLine("select a.SALES_CODE, a.FULL_NAME, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a inner join EZ_EMPLOYEE b on a.EMAIL=b.EMAIL_ADDR ")
            sqlstr.AppendLine(" where SALES_CODE >= '41010000' and SALES_CODE <= '41399999' and SALESOFFICE >= '6100' and SALESOFFICE <= '6430' ")
            sqlstr.AppendLine(" Order by a.SALES_CODE")

        Else
            sqlstr.AppendLine("select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a where  a.EMAIL in ")

            'sqlstr.AppendLine(" (select isnull(b.EMAIL,'') from ADVANTECH_ADDRESSBOOK_ALIAS b where b.ID in ")
            'sqlstr.AppendLine(" (select isnull(c.id,'') from ADVANTECH_ADDRESSBOOK_ALIAS c where c.Email ='" & userid & "')) ")

            sqlstr.AppendLine(" (select isnull(b.ALIAS_EMAIL,'') as EMAIL from AD_MEMBER_ALIAS b where b.EMAIL in ")
            sqlstr.AppendLine(" (select isnull(c.EMAIL,'') from AD_MEMBER_ALIAS c where c.ALIAS_EMAIL ='" & userid & "')) ")

        End If

        '==============================Ryan 20170707 Comment below out==============================
        'If Not IsATWCustomer() Then
        '    sqlstr.AppendLine("select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a where  a.EMAIL in ")

        '    'sqlstr.AppendLine(" (select isnull(b.EMAIL,'') from ADVANTECH_ADDRESSBOOK_ALIAS b where b.ID in ")
        '    'sqlstr.AppendLine(" (select isnull(c.id,'') from ADVANTECH_ADDRESSBOOK_ALIAS c where c.Email ='" & userid & "')) ")

        '    sqlstr.AppendLine(" (select isnull(b.ALIAS_EMAIL,'') as EMAIL from AD_MEMBER_ALIAS b where b.EMAIL in ")
        '    sqlstr.AppendLine(" (select isnull(c.EMAIL,'') from AD_MEMBER_ALIAS c where c.ALIAS_EMAIL ='" & userid & "')) ")


        'Else
        '    'If it is a Taiwan customer's order, put CFC team member to the key in person drop down list
        '    sqlstr.AppendLine("select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a where  a.EMAIL in ")

        '    'sqlstr.AppendLine(" (select isnull(b.EMAIL,'') from ADVANTECH_ADDRESSBOOK_ALIAS b where b.ID in ")
        '    'sqlstr.AppendLine(" (select isnull(c.id,'') from ADVANTECH_ADDRESSBOOK_ALIAS c where c.Email ='" & userid & "')) ")

        '    sqlstr.AppendLine(" (select isnull(b.ALIAS_EMAIL,'') as EMAIL from AD_MEMBER_ALIAS b where b.EMAIL in ")
        '    sqlstr.AppendLine(" (select isnull(c.EMAIL,'') from AD_MEMBER_ALIAS c where c.ALIAS_EMAIL ='" & userid & "')) ")


        '    sqlstr.AppendLine(" union ")
        '    sqlstr.AppendLine("select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL from SAP_EMPLOYEE a where ")
        '    sqlstr.AppendLine(" a.SALES_CODE between '16100001' and '16100122' ")
        '    sqlstr.AppendLine(" and a.SALES_CODE not in ('16100010','16100011') ")
        '    sqlstr.AppendLine(" order by a.SALES_CODE ")
        'End If
        '==============================End Comment out==============================

        Dim dt As New DataTable
        'dt = dbUtil.dbGetDataTable("B2B", str)
        dt = dbUtil.dbGetDataTable("B2B", sqlstr.ToString)
        Return dt
    End Function
    Public Shared Function GetPI(ByVal Order_No As String, ByVal strPIType As Integer) As String
        Dim myDoc As New System.Xml.XmlDocument
        If IsATWCustomer() Then
            Dim _Cart2OrderMaping As Cart2OrderMaping = MyUtil.Current.MyAContext.Cart2OrderMapings.Where(Function(p) p.OrderNo = Order_No OrElse p.OrderID = Order_No).FirstOrDefault()
            If _Cart2OrderMaping IsNot Nothing Then
                Dim _cartmaster As CartMaster = MyCartX.GetCartMaster(_Cart2OrderMaping.CartID)
                If _cartmaster IsNot Nothing AndAlso _cartmaster.QuoteID IsNot Nothing AndAlso Not String.IsNullOrEmpty(_cartmaster.QuoteID) Then
                    strPIType = 2
                    'If eQuotationUtil.GetQuoteMasterByQuoteid(_cartmaster.QuoteID) IsNot Nothing Then
                    '    strPIType = 0
                    'End If
                End If
            End If
        End If
        Select Case strPIType
            Case 0
                Global_Inc.HtmlToXML("~/ORDER/PI_AEU.aspx?NO=" & Order_No, myDoc)
            Case 1
                Global_Inc.HtmlToXML("~/ORDER/PI_MexicoT2.aspx?NO=" & Order_No, myDoc)
            Case 2
                Global_Inc.HtmlToXML("~/ORDER/PI_ATW.aspx?NO=" & Order_No, myDoc)
            Case 3
                Global_Inc.HtmlToXML("~/ORDER/PI_AEU_SendUSPI.aspx?NO=" & Order_No, myDoc)
            Case Else
                Global_Inc.HtmlToXML("~/ORDER/PI_AEU.aspx?NO=" & Order_No, myDoc)
        End Select
        Return myDoc.OuterXml
    End Function
    Public Shared Function SendFailedOrderMail(ByVal strOrderNO As String, Optional ByVal refOrderno As String = "") As Integer
        Dim strStyle As String = "", strBody As String = "", t_strHTML As String = ""
        Dim FROM_Email As String = "", TO_Email As String = "", CC_Email As String = "", BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""
        Dim sbStyle As New System.Text.StringBuilder
        With sbStyle
            .AppendLine("<style>")
            .AppendLine("BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 8pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} ")
            .AppendLine("A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} ")
            .AppendLine("A:active  {TEXT-DECORATION: none} ")
            .AppendLine("A:hover   {TEXT-DECORATION: underline} ")
            .AppendLine("</style>")
        End With
        strStyle = sbStyle.ToString()
        Dim titlestr As String = "Order"
        If Not String.IsNullOrEmpty(refOrderno) Then
            titlestr = "Quote"
        End If
        Dim sbBody As New System.Text.StringBuilder
        With sbBody
            .AppendLine("<html><body><center>")
            .AppendLine("<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
            .AppendLine("<tr><td colspan=""3"">")
            .AppendLine("&nbsp;<font size=5 color=""#000000""><b>Failed " + titlestr + " Message</b></font>&nbsp;&nbsp;&nbsp;&nbsp;" & "<br><br>")
            .AppendLine("</td></tr>")
            .AppendLine("</table>")

            .AppendLine("<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
            .AppendLine("<tr><td align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC""><font color=""#ffffff"">")
            .AppendLine("&nbsp;<b>Message</b>")
            .AppendLine("</td></tr>")
            .AppendLine("<tr><td align=""left"" width=""100%"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""18"" bgcolor=""#d8e4f8""><font color=""#316ac5"">")
            .AppendLine("&nbsp;<b>Order Process Message(<font color=""green"">" & strOrderNO & "</font>)</b>")
            .AppendLine("</td></tr>")
            .AppendLine("<tr><td>")
            .AppendLine("<table width=""731"" bgcolor=""#DCDCDC"" style=""border:#CFCFCF 1px solid"" class=""text"" cellspacing=""0"" cellpadding=""0"">")
        End With
        strBody = sbBody.ToString()
        Dim strCC As String = "", l_strSQLCmd As String = "", strCC_External As String = ""
        Dim k As Integer = GetPIcc(strOrderNO, strCC, strCC_External)
        Dim Message_DT As New DataTable, myOrderStatus As New ORDER_PROC_STATUS("b2b", "ORDER_PROC_STATUS2")
        Message_DT = myOrderStatus.GetDT(String.Format("order_no='{0}'", strOrderNO), "LINE_SEQ")
        If Message_DT.Rows.Count > 0 Then
            Dim j As Integer = 0
            While j <= Message_DT.Rows.Count - 1
                strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
                strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & Message_DT.Rows(j).Item("MESSAGE")
                strBody = strBody & "</font></td></tr>"
                j = j + 1
            End While
        Else
            strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
            strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & "No message"
            strBody = strBody & "</font></td></tr>"
        End If
        If String.IsNullOrEmpty(refOrderno.Trim) Then
            strBody = strBody & "<tr><td height=""5"" bgcolor=""#ffffff"">"
            strBody = strBody & "&nbsp;"
            strBody = strBody & "</td></tr>"
            strBody = strBody & "<tr><td height=""5"" align=""center"" bgcolor=""#ffffff""><font size=3><i><u>"
            strBody = strBody & "<a href=""http://" & HttpContext.Current.Request.ServerVariables("HTTP_HOST") & "/order/Order_Recovery.aspx?NO=" & strOrderNO & """><i><b><font size=4 color=""red"">Press Link To Recover This Order</font></b></i></a>"
            strBody = strBody & "</u></i></font></td></tr>"
        End If
        strBody = strBody & "</table>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"
        strBody = strBody & "</body></html>"

        t_strHTML = Replace(strBody, "<body>", "<body>" & strStyle)

        Dim CompanyInfo_DR As DataTable, myOrderMaster As New order_Master("b2b", "order_master")
        CompanyInfo_DR = myOrderMaster.GetDT(String.Format("order_id='{0}'", strOrderNO), "")
        Dim strPONo As String = "", strCompanyId As String = ""
        If CompanyInfo_DR.Rows.Count > 0 Then
            strPONo = CompanyInfo_DR.Rows(0).Item("PO_NO") : strCompanyId = CompanyInfo_DR.Rows(0).Item("SOLDTO_ID")
        End If

        Dim CompanyName_DR As DataTable, myCompany As New SAP_Company("b2b", "sap_dimcompany")
        CompanyName_DR = myCompany.GetDT(String.Format("company_id='{0}'", strCompanyId), "")

        Dim strCompanyName As String = ""
        If CompanyName_DR.Rows.Count > 0 Then
            strCompanyName = CompanyName_DR.Rows(0).Item("COMPANY_NAME")
        Else
            strCompanyName = strCompanyId
        End If


        FROM_Email = "myadvantech@advantech.com" : TO_Email = strCC : CC_Email = "myadvantech@advantech.com;"
        Try
            Dim FailedNotifyList As ArrayList = MyCartOrderBizDAL.GetFailedOrderNotifyList(strCompanyId, HttpContext.Current.Session("org_id"))
            If FailedNotifyList.Count > 0 Then
                CC_Email += String.Join(";", FailedNotifyList.ToArray())
            End If
        Catch ex As Exception
            Util.InsertMyErrLog(ex.ToString)
        End Try

        'Ryan 20161216 Add current user to mail receiver, but only if user is internal user
        If Util.IsInternalUser2() AndAlso HttpContext.Current.Session("org_id") IsNot Nothing Then
            TO_Email = TO_Email.Trim(New Char() {";"})
            TO_Email = TO_Email + ";" + HttpContext.Current.Session("USER_ID")
        End If

        'Ryan 20180118 Only send mail to DLOG employees (end with @advantech-dlog.com)
        If AuthUtil.IsADloG Then
            'TO_EMAIL
            TO_Email = TO_Email + ";" + "order@advantech-dlog.com;"
            Dim listTO As List(Of String) = TO_Email.Split(";").ToList
            TO_Email = ""
            For Each s As String In listTO
                If Not String.IsNullOrEmpty(s) AndAlso s.EndsWith("@advantech-dlog.com", StringComparison.OrdinalIgnoreCase) AndAlso Not TO_Email.Contains(s) Then
                    TO_Email = TO_Email + s + ";"
                End If
            Next

            'CC_EMAIL
            Dim listCC As List(Of String) = CC_Email.Split(";").ToList
            CC_Email = ""
            For Each s As String In listCC
                If Not String.IsNullOrEmpty(s) AndAlso s.EndsWith("@advantech-dlog.com", StringComparison.OrdinalIgnoreCase) AndAlso Not CC_Email.Contains(s) Then
                    CC_Email = CC_Email + s + ";"
                End If
            Next
        End If

        BCC_Email = ""
        Subject_Email = "Advantech Failed Order(" & strPONo & "/" & strOrderNO & ") for " & strCompanyName & " (" & strCompanyId & ")"
        If strOrderNO.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase) _
                OrElse strOrderNO.StartsWith("AMXQ", StringComparison.CurrentCultureIgnoreCase) Then
            Subject_Email = "Create SAP Quote Failed: " & strOrderNO & " for (" & refOrderno & ")"
        End If
        AttachFile = "" : MailBody = t_strHTML
        If Util.IsTesting() OrElse strOrderNO.ToUpper.StartsWith("AUSO", StringComparison.CurrentCultureIgnoreCase) _
            OrElse strOrderNO.StartsWith("AUSQ", StringComparison.CurrentCultureIgnoreCase) _
            OrElse strOrderNO.StartsWith("AMXO", StringComparison.CurrentCultureIgnoreCase) _
            OrElse strOrderNO.StartsWith("AMXQ", StringComparison.CurrentCultureIgnoreCase) _
            OrElse strOrderNO.StartsWith("AIAG", StringComparison.CurrentCultureIgnoreCase) Then
            Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
            If Not Util.IsTesting() Then Expandstr = ""
            MailUtil.Utility_EMailPage(FROM_Email, "myadvantech@advantech.com;Mike.Liu@advantech.com", "", "", Subject_Email, AttachFile, Expandstr + MailBody)
        Else
            MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        End If
        Return 1
    End Function

    Public Shared Function SendFailedOrderMailForBBUS(ByVal strOrderNO As String, Optional ByVal refOrderno As String = "") As Integer
        Dim strStyle As String = "", strBody As String = "", t_strHTML As String = ""
        Dim FROM_Email As String = "", TO_Email As String = "", CC_Email As String = "", BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = ""
        Dim sbStyle As New System.Text.StringBuilder
        With sbStyle
            .AppendLine("<style>")
            .AppendLine("BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 8pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} ")
            .AppendLine("A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} ")
            .AppendLine("A:active  {TEXT-DECORATION: none} ")
            .AppendLine("A:hover   {TEXT-DECORATION: underline} ")
            .AppendLine("</style>")
        End With
        strStyle = sbStyle.ToString()
        Dim titlestr As String = "Order"
        If Not String.IsNullOrEmpty(refOrderno) Then
            titlestr = "Quote"
        End If
        Dim sbBody As New System.Text.StringBuilder
        With sbBody
            .AppendLine("<html><body><center>")
            .AppendLine("<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
            .AppendLine("<tr><td colspan=""3"">")
            .AppendLine("&nbsp;<font size=5 color=""#000000""><b>Failed " + titlestr + " Message</b></font>&nbsp;&nbsp;&nbsp;&nbsp;" & "<br><br>")
            .AppendLine("</td></tr>")
            .AppendLine("</table>")

            .AppendLine("<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
            .AppendLine("<tr><td align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC""><font color=""#ffffff"">")
            .AppendLine("&nbsp;<b>Message</b>")
            .AppendLine("</td></tr>")
            .AppendLine("<tr><td align=""left"" width=""100%"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""18"" bgcolor=""#d8e4f8""><font color=""#316ac5"">")
            .AppendLine("&nbsp;<b>Order Process Message(<font color=""green"">" & strOrderNO & "</font>)</b>")
            .AppendLine("</td></tr>")
            .AppendLine("<tr><td>")
            .AppendLine("<table width=""731"" bgcolor=""#DCDCDC"" style=""border:#CFCFCF 1px solid"" class=""text"" cellspacing=""0"" cellpadding=""0"">")
        End With
        strBody = sbBody.ToString()
        Dim l_strSQLCmd As String = ""
        Dim Message_DT As New DataTable, myOrderStatus As New ORDER_PROC_STATUS("b2b", "ORDER_PROC_STATUS2")
        Message_DT = myOrderStatus.GetDT(String.Format("order_no='{0}'", strOrderNO), "LINE_SEQ")
        If Message_DT.Rows.Count > 0 Then
            Dim j As Integer = 0
            While j <= Message_DT.Rows.Count - 1
                strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
                strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & Message_DT.Rows(j).Item("MESSAGE")
                strBody = strBody & "</font></td></tr>"
                j = j + 1
            End While
        Else
            strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
            strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & "No message"
            strBody = strBody & "</font></td></tr>"
        End If
        If String.IsNullOrEmpty(refOrderno.Trim) Then
            strBody = strBody & "<tr><td height=""5"" bgcolor=""#ffffff"">"
            strBody = strBody & "&nbsp;"
            strBody = strBody & "</td></tr>"
            strBody = strBody & "<tr><td height=""5"" align=""center"" bgcolor=""#ffffff""><font size=3><i><u>"
            strBody = strBody & "<a href=""http://" & HttpContext.Current.Request.ServerVariables("HTTP_HOST") & "/Order/BBorder/OrderList.aspx""><i><b><font size=4 color=""red"">Press Link To View Detail</font></b></i></a>"
            strBody = strBody & "</u></i></font></td></tr>"
        End If
        strBody = strBody & "</table>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"
        strBody = strBody & "</body></html>"

        t_strHTML = Replace(strBody, "<body>", "<body>" & strStyle)

        Dim CompanyInfo_DR As DataTable, myOrderMaster As New order_Master("b2b", "order_master")
        CompanyInfo_DR = myOrderMaster.GetDT(String.Format("order_id='{0}'", strOrderNO), "")
        Dim strPONo As String = "", strCompanyId As String = ""
        If CompanyInfo_DR.Rows.Count > 0 Then
            strPONo = CompanyInfo_DR.Rows(0).Item("PO_NO") : strCompanyId = CompanyInfo_DR.Rows(0).Item("SOLDTO_ID")
        End If

        Dim CompanyName_DR As DataTable, myCompany As New SAP_Company("b2b", "sap_dimcompany")
        CompanyName_DR = myCompany.GetDT(String.Format("company_id='{0}'", strCompanyId), "")

        Dim strCompanyName As String = ""
        If CompanyName_DR.Rows.Count > 0 Then
            strCompanyName = CompanyName_DR.Rows(0).Item("COMPANY_NAME")
        Else
            strCompanyName = strCompanyId
        End If


        FROM_Email = "myadvantech@advantech.com" : TO_Email = "BB.Orders@advantech.com" : CC_Email = "myadvantech@advantech.com;" : BCC_Email = ""
        Subject_Email = "Advantech Failed Order(" & strPONo & "/" & strOrderNO & ") for " & strCompanyName & " (" & strCompanyId & ")"

        AttachFile = "" : MailBody = t_strHTML
        If Util.IsTesting() Then
            Dim Expandstr As String = String.Format("From:{0}<hr/>To:{1}<hr/>CC:{2}<hr/>Bcc:{3}<hr/>", FROM_Email, TO_Email, CC_Email, BCC_Email)
            If Not Util.IsTesting() Then Expandstr = ""
            MailUtil.Utility_EMailPage(FROM_Email, "myadvantech@advantech.com", "", "", Subject_Email, AttachFile, Expandstr + MailBody)
        Else
            MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        End If
        Return 1
    End Function


    Shared Function GETSHEETINFO(ByVal ORDERNO As String) As String
        Dim MainBlock As String = ""
        Dim url As String = ""
        url = "btosSheet.aspx?NO=" & ORDERNO
        Dim MyDOC As New System.Xml.XmlDocument
        Global_Inc.HtmlToXML(url, MyDOC)
        Global_Inc.getXmlBlockByID("div", "divSheet", MyDOC, MainBlock)
        Return MainBlock
    End Function

    Shared Sub sendSheet(ByVal orderNo As String)
        Dim FROM_Email As String = "eBusiness.AEU@advantech.eu", TO_Email As String = "eBusiness.AEU@advantech.eu", CC_Email As String = ""
        Dim BCC_Email As String = "eBusiness.AEU@advantech.eu", subject_email As String = "Advantech Configuration Sheet (" & orderNo & ")"
        Dim attachfile As String = "", mailbody As String = ""
        mailbody = GETSHEETINFO(orderNo)
        Dim arr As ArrayList = MyCartOrderBizDAL.GetBTOSSheetNotifyList(HttpContext.Current.Session("org_id"))
        TO_Email = String.Join(";", arr.ToArray())
        MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, subject_email, attachfile, mailbody)
    End Sub

    Public Shared Sub UpdateRevenueSplitOption2SAP(ByVal Order_No)
        Dim dtAJP As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select * from ORDER_PARTNERS where ORDER_ID = '{0}' and TYPE = 'ZA'", Order_No))
        If dtAJP IsNot Nothing AndAlso dtAJP.Rows.Count > 0 Then
            Dim SAPAtr8 As String = dtAJP.Rows(0).Item("NAME").ToString
            If Not String.IsNullOrEmpty(SAPAtr8) Then
                Advantech.Myadvantech.DataAccess.SAPDAL.UpdateSAPSOforRevenueSplitting(Order_No, SAPAtr8, Util.IsTesting)
            End If
        End If
    End Sub

End Class
