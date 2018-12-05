Imports Microsoft.VisualBasic
Public Class PricingUtil

    Public Shared Function GetMultiPrice(ByVal Org As String, ByVal CompanyId As String, _
                                         ByVal Products As DataTable, ByVal PricingDate As Date, ByRef ErrorMessage As String) As DataTable
        CompanyId = UCase(Trim(CompanyId)) : ErrorMessage = ""
        Dim strDistChann As String = "10", strDivision As String = "00"
        If Org = "US01" Then
            Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(COMPANY_ID) from SAP_DIMCOMPANY where SALESOFFICE in ('2300') and COMPANY_ID='{0}' and ORG_ID='US01'", CompanyId))
            If N > 0 Then
                strDistChann = "10" : strDivision = "20"
            Else
                strDistChann = "30" : strDivision = "10"
            End If
        Else

        End If

        Dim OutList As New DataTable("Output")
        With OutList.Columns
            .Add("Mandt") : .Add("Vkorg") : .Add("Kunnr") : .Add("Matnr") : .Add("Mglme", GetType(Double)) : .Add("Kzwi1", GetType(Double)) : .Add("Netwr", GetType(Double))
        End With
        Dim ZSWLItemSet As New DataTable
        With ZSWLItemSet.Columns
            .Add("PartNo") : .Add("Qty", GetType(Integer))
        End With
        Dim phaseOutItems As New ArrayList
        Dim proxy1 As New BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim OrderHeader As New BAPI_SALESORDER_SIMULATE.BAPISDHEAD, Partners As New BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable
        Dim ItemsIn As New BAPI_SALESORDER_SIMULATE.BAPIITEMINTable, ItemsOut As New BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable
        Dim Conditions As New BAPI_SALESORDER_SIMULATE.BAPICONDTable
        Dim SoldTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR, ShipTo As New BAPI_SALESORDER_SIMULATE.BAPIPARTNR
        Dim retDt As New BAPI_SALESORDER_SIMULATE.BAPIRET2Table
        With OrderHeader
            .Doc_Type = "ZOR" : .Sales_Org = Trim(UCase(Org)) : .Distr_Chan = strDistChann : .Division = strDivision
            .Price_Date = PricingDate.ToString("yyyyMMdd")
        End With
        Dim LineNo As Integer = 1
        Dim sqlMA As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        sqlMA.Open()
        For Each i As DataRow In Products.Rows
            'Check if item exists in current org, and if it is a non-standard p-trade ZSWL
            Dim chkSql As String = "select part_no, ITEM_CATEGORY_GROUP from sap_product_status where part_no='" + i.Item("PartNo").Trim().ToUpper() + "' and product_status in ('A','N','H','M1') and sales_org='" + Org + "'"
            Dim chkDt As New DataTable
            Dim sqlAptr As New SqlClient.SqlDataAdapter(chkSql, sqlMA)
            Try
                sqlAptr.Fill(chkDt)
            Catch ex As SqlClient.SqlException
                sqlMA.Close()
                Throw ex
            End Try
            If chkDt.Rows.Count > 0 Then
                If chkDt.Rows(0).Item("ITEM_CATEGORY_GROUP") <> "ZSWL" Then
                    Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                    item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(i.Item("PartNo").Trim().ToUpper())
                    item.Req_Qty = i.Item("Qty").ToString()
                    item.Req_Qty = CInt(item.Req_Qty) * 1000
                    ItemsIn.Add(item)
                    LineNo += 1
                Else
                    Dim zr As DataRow = ZSWLItemSet.NewRow()
                    zr.Item("PartNo") = i.Item("PartNo").Trim().ToUpper() : zr.Item("Qty") = i.Item("Qty") : ZSWLItemSet.Rows.Add(zr)
                End If
            Else
                phaseOutItems.Add(i.Item("PartNo").Trim().ToUpper())
            End If
        Next
        sqlMA.Close()
        Dim IsVirtualAdamUsed As Boolean = False, VirtualAdamLineNo As String = ""
        'Put non-standard p=trade to end of order lines, and point their higher level item to the first order line's line no.
        If ItemsIn.Count = 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
            item.Itm_Number = FormatItmNumber(LineNo) : item.Material = SAPDAL.SAPDAL.GetAHighLevelItemForPricing(Org)
            item.Req_Qty = 1 : item.Req_Qty = CInt(item.Req_Qty) * 1000 : ItemsIn.Add(item)
            IsVirtualAdamUsed = True : VirtualAdamLineNo = item.Itm_Number : LineNo += 1
        End If
        If ItemsIn.Count > 0 AndAlso ZSWLItemSet.Rows.Count > 0 Then
            For Each r As DataRow In ZSWLItemSet.Rows
                Dim item As New BAPI_SALESORDER_SIMULATE.BAPIITEMIN
                item.Itm_Number = FormatItmNumber(LineNo) : item.Material = Format2SAPItem(r.Item("PartNo").Trim().ToUpper())
                item.Req_Qty = r.Item("Qty").ToString()
                item.Req_Qty = CInt(item.Req_Qty) * 1000
                item.Hg_Lv_Item = "1"
                ItemsIn.Add(item)
                LineNo += 1
            Next
        End If
        SoldTo.Partn_Role = "AG" : SoldTo.Partn_Numb = CompanyId : ShipTo.Partn_Role = "WE" : ShipTo.Partn_Numb = CompanyId
        Partners.Add(SoldTo) : Partners.Add(ShipTo)

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
            Dim ConditionOut As DataTable = Conditions.ToADODataTable()
            'Dim PInDt As DataTable = ItemsIn.ToADODataTable()
            Dim POutDt As DataTable = ItemsOut.ToADODataTable()
            'MailUtil.SendEmail("tc.chen@advantech.com.tw", "ebiz.aeu@advantech.eu", "Price InOut", Util.DataTableToXml(POutDt) + Util.DataTableToXml(ItemsIn.ToADODataTable()), False, "", "")
            For Each r As DataRow In POutDt.Rows
                Dim outRow As DataRow = OutList.NewRow()
                outRow.Item("Mandt") = ""
                outRow.Item("Vkorg") = Org
                outRow.Item("Kunnr") = CompanyId
                outRow.Item("Matnr") = RemoveZeroString(r.Item("Material"))
                outRow.Item("Mglme") = 1.0
                outRow.Item("Kzwi1") = CDbl(r.Item("SUBTOTAL1")) / CDbl(r.Item("REQ_QTY"))
                outRow.Item("Netwr") = CDbl(r.Item("SUBTOTAL2")) / CDbl(r.Item("REQ_QTY"))
                If CDbl(outRow.Item("Kzwi1")) < CDbl(outRow.Item("Netwr")) Then outRow.Item("Kzwi1") = outRow.Item("Netwr")
                If Not IsVirtualAdamUsed OrElse (IsVirtualAdamUsed And r.Item("ITM_NUMBER").ToString() <> VirtualAdamLineNo) Then
                    OutList.Rows.Add(outRow)
                End If
            Next
        Catch ex As Exception
            ErrorMessage = ex.ToString()
        End Try
        proxy1.Connection.Close()

        Return OutList
    End Function

    Public Shared Function GetMultiPrice(ByVal Org As String, ByVal CompanyId As String, ByVal Products As DataTable, ByRef ErrorMessage As String) As DataTable
        Return GetMultiPrice(Org, CompanyId, Products, Now, ErrorMessage)
    End Function

    Public Shared Function FormatItmNumber(ByVal ItemNumber As Integer) As String
        Dim Zeros As Integer = 6 - ItemNumber.ToString.Length
        If Zeros = 0 Then Return ItemNumber.ToString()
        Dim strItemNumber As String = ItemNumber.ToString()
        For i As Integer = 0 To Zeros - 1
            strItemNumber = "0" + strItemNumber
        Next
        Return strItemNumber
    End Function

    Public Shared Function RemoveZeroString(ByVal NumericPart_No As String) As String

        If IsNumericItem(NumericPart_No) Then
            For i As Integer = 0 To NumericPart_No.Length - 1
                If Not NumericPart_No.Substring(i, 1).Equals("0") Then
                    Return NumericPart_No.Substring(i)
                    Exit For
                End If
            Next
            Return NumericPart_No
        Else
            Return NumericPart_No
        End If

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

    Public Shared Function GetProductsTableDef() As DataTable
        Dim dt As New DataTable("Products") : dt.Columns.Add("PartNo") : dt.Columns.Add("Qty", GetType(Double)) : Return dt
    End Function

End Class
