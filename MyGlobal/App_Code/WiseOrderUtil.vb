Imports Microsoft.VisualBasic

Public Class WiseOrderUtil
    Private Shared WisePortalProductConn As String = "Data Source=172.20.0.21;Initial Catalog=WISE_PaaS_Marketplace_V2;Persist Security Info=True;User ID=WPS2MyAdv;Password=w9$2my@dv;async=true;Connect Timeout=300;pooling='true'"
    Public IsToSAPPRD As Boolean = False

    Public Class SOAssetPair
        Public Property SONO As String : Public Property AssetId As String : Public Property CreatedDate As Date : Public Property ERPID As String
    End Class

    Public Shared Function GetSOByAssetId(AssetId As String) As List(Of SOAssetPair)
        Dim SOAssetPairList = New List(Of SOAssetPair)
        AssetId = AssetId.Trim().ToUpper().Replace("'", "")
        If String.IsNullOrEmpty(AssetId) Then Return SOAssetPairList
        Dim strSql =
            " Select distinct b.VBELN, c.ERDAT, c.KUNNR, a.BSTKD " +
            " From saprdp.vbkd a inner Join saprdp.vbap b on a.vbeln=b.vbeln And a.posnr=b.posnr inner join saprdp.vbak c on b.vbeln=c.vbeln " +
            " Where a.mandt='168' and b.mandt='168' and c.mandt='168' and a.BSTKD ='" + AssetId + "' and a.vbeln like 'WISE%' and c.auart='ZOR2' " +
            " order by b.VBELN"
        Dim dtSOList = OraDbUtil.dbGetDataTable("SAP_PRD", strSql)
        For Each dr As DataRow In dtSOList.Rows
            SOAssetPairList.Add(
                New SOAssetPair() With {
                    .AssetId = dr("BSTKD"), .CreatedDate = Date.ParseExact(dr("ERDAT"), "yyyyMMdd", New System.Globalization.CultureInfo("en-US")),
                                .ERPID = dr("KUNNR"), .SONO = Global_Inc.RemoveZeroString(dr("VBELN"))
                }
            )
        Next
        Threading.Thread.Sleep((New Random()).Next(578, 2266))
        Return SOAssetPairList
    End Function

    Public Function WISEPoint2OrderEnSaaS(InputV2 As WISEPoint2OrderEnSaaSInput) As ReturnResult
        Dim SAPRFCConn = "SAPConnTest", SAPDbConn = "SAP_Test"
        If IsToSAPPRD Then
            SAPRFCConn = "SAP_PRD" : SAPDbConn = "SAP_PRD"
        End If

        Dim ReturnResult1 As New ReturnResult(), jsr As New Script.Serialization.JavaScriptSerializer()
        If String.IsNullOrEmpty(InputV2.WisePointOrderSONO) Then Throw New WisePoint2OrderException("Please input WisePointOrderSONO")
        If InputV2.RedeemItemList.Count = 0 Then Throw New WisePoint2OrderException("There is No Item in the input redeem item list")
        Dim WisePointPN = ""
        Dim IsZeroPointRedeem As Boolean = False
        If InputV2.RedeemItemList.Sum(Function(p) p.RedeemPoints) = 0 Then
            IsZeroPointRedeem = True  'Input.RedeemPoints = 1
        End If

        '20171017 TC: If input SO is a pure numeric one, append zero to 10 digits
        InputV2.WisePointOrderSONO = Global_Inc.SONoBuildSAPFormat(InputV2.WisePointOrderSONO)
        Dim proxy0 As New Z_VBRP_SELECT_01.Z_VBRP_SELECT_01(ConfigurationManager.AppSettings(SAPRFCConn))
        Dim ZVBRP As New Z_VBRP_SELECT_01.ZVBRPVB_T
        proxy0.Connection.Open()
        proxy0.Z_Vbrp_Select_01("20160101", "99991231", "98DP", ZVBRP)
        proxy0.Connection.Close()
        Dim VBRPRecords As New List(Of Z_VBRP_SELECT_01.ZVBRPVB)
        For Each vbrprec As Z_VBRP_SELECT_01.ZVBRPVB In ZVBRP
            VBRPRecords.Add(vbrprec)
        Next

        '20161004 TC: Per Poki's advise, added two new point items 98DPWSPAP1 & 98DPWAP1H
        Dim LatestOrder = From q In VBRPRecords Where String.Equals(q.Aubel, InputV2.WisePointOrderSONO, StringComparison.CurrentCultureIgnoreCase) _
                And q.Netwr > 0 And
                (q.Matnr = "98DPWAP1H" Or q.Matnr = "98DPWAP2K" _
                                                    Or q.Matnr = "98DPWSPA0A" Or q.Matnr = "98DPWSPAP1" _
                                                    Or q.Matnr = "98DPWAP4K" Or q.Matnr = "98DPWSPA1A") _
                And q.Shkzg <> "X" Order By q.Fkdat Descending Take 1

        If LatestOrder.Count = 0 Then
            Throw New WisePoint2OrderException("Cannot find WISE point order record")
        End If

        Dim Currency = LatestOrder.First.Waerk

        WisePointPN = LatestOrder.First.Matnr
        Dim PointsOfItem As Integer = 0
        Select Case WisePointPN
            Case "98DPWAP1H", "98DPWSPAP1"
                PointsOfItem = 100
            Case "98DPWAP2K", "98DPWSPA0A"
                PointsOfItem = 2000
            Case "98DPWAP4K", "98DPWSPA1A"
                PointsOfItem = 5000
        End Select
        Dim AmountPerPoint = LatestOrder.First.Netwr / PointsOfItem / LatestOrder.First.Fkimg
        '20171219 WISE- PaaS Vivienne Liao: 在最後結算時, 需針對Premium客戶沖down payment 20%, 
        '此為內部作業, 資訊不會顯示給客戶.例如Premium客戶結帳點數為 32+36 = 68; 轉換成金額為 (68*10)*0.8=$544
        'If WisePointPN = "98DPWAP4K" Or WisePointPN = "98DPWSPA1A" Then
        '    AmountPerPoint = AmountPerPoint * 0.8
        'End If

        'Dim TotalAmountPerPiece = AmountPerPoint * CType(Input.RedeemItemList.Sum(Function(p) p.RedeemPoints), Decimal)

        Dim OrgId = LatestOrder.First.Vkorg
        Dim ERPId = LatestOrder.First.Kunag

        If IsToSAPPRD Then
            For Each RedeemItem As RedeemItemPointQty In InputV2.RedeemItemList
                Dim sqlCheckWisePN As String = "select count(*) from [WISE_PaaS_Marketplace_V2].[dbo].[WISE_PaaS_PackagePlan] where PISID=@PN"
                Dim cmdMyLocal As New SqlClient.SqlCommand(sqlCheckWisePN, New SqlClient.SqlConnection(WisePortalProductConn))
                cmdMyLocal.Parameters.AddWithValue("PN", RedeemItem.RedeemPartNo)
                cmdMyLocal.Connection.Open()
                Dim chkCount As Integer = CInt(cmdMyLocal.ExecuteScalar())
                cmdMyLocal.Connection.Close()
                If chkCount = 0 Then
                    Throw New WisePoint2OrderException(String.Format("{0} is not a WISE Portal Part Number", RedeemItem.RedeemPartNo))
                End If
            Next
        End If

        ReturnResult1.ERPID = ERPId : ReturnResult1.OrgId = OrgId

        '20170510 TC: Per WISE PM and Chris's request, force TW02 to TW01
        If OrgId = "TW02" Then OrgId = "TW01"

        Dim proxy1 As New SO_CREATE_COMMIT.SO_CREATE_COMMIT, OrderHeader As New SO_CREATE_COMMIT.BAPISDHD1, ItemIn As New SO_CREATE_COMMIT.BAPISDITMTable
        Dim PartNr As New SO_CREATE_COMMIT.BAPIPARNRTable, ScheLine As New SO_CREATE_COMMIT.BAPISCHDLTable, Conditions As New SO_CREATE_COMMIT.BAPICONDTable

        Dim distr_chan As String = "10", division As String = "00"

        If Trim(OrgId).ToUpper() = "US01" Then
            '20160526 TC: To be implemented
            Dim OfficeDivisionDt As DataTable = OraDbUtil.dbGetDataTable(SAPDbConn,
                                                                             "select VKBUR, SPART from saprdp.knvv where kunnr='" + ReturnResult1.ERPID + "' and vkorg='US01'")

            If OfficeDivisionDt.Rows.Count > 0 Then
                Dim SalesOffice = OfficeDivisionDt.Rows(0).Item("VKBUR").ToString() : Dim SAPCustDivision = OfficeDivisionDt.Rows(0).Item("SPART").ToString()

                If SalesOffice = "2300" OrElse SAPCustDivision = "20" Then
                    distr_chan = "10" : division = "20"
                Else
                    distr_chan = "30" : division = "10"
                End If
            End If

        End If
        '20160617 TC: Per Fanny.Tseng's request for ATHI001 (IBCON)'s order's org shall be SG01 from now on
        'If ERPId = "ATHI001" Then OrgId = "TW01"
        With OrderHeader
            .Doc_Type = "ZOR2" : .Sales_Org = OrgId : .Distr_Chan = distr_chan : .Division = division : .Currency = Currency
            '20160323 TC: Chris asked to tick complete delivery for WISE Point's SO
            .Compl_Dlv = "X"
            '20160527 TC: For CN10 always set group 600 office 6100, per Poki/Chris/Alice.Wang's request
            If OrgId = "CN10" Then
                .Sales_Grp = "600" : .Sales_Off = "6100"
            End If

        End With

        'ERPId = "T00694868"
        Dim PartNr_Ship_Record As New SO_CREATE_COMMIT.BAPIPARNR
        PartNr_Ship_Record.Partn_Role = "WE" : PartNr_Ship_Record.Partn_Numb = ERPId
        PartNr.Add(PartNr_Ship_Record)
        Dim PartNr_Sold_Record As New SO_CREATE_COMMIT.BAPIPARNR
        PartNr_Sold_Record.Partn_Role = "AG" : PartNr_Sold_Record.Partn_Numb = ERPId
        PartNr.Add(PartNr_Sold_Record)

        '20160527 TC: For CN10 always insert end customer, per Poki/Chris/Alice.Wang's request
        If OrgId = "CN10" Then
            Dim PartNr_EndCust_Record As New SO_CREATE_COMMIT.BAPIPARNR
            PartNr_Sold_Record.Partn_Role = "EM" : PartNr_Sold_Record.Partn_Numb = ERPId
            PartNr.Add(PartNr_Sold_Record)
        End If

        '20160923 TC: If VE is not maintained for current customer on SAP, find latest WISE point order's VE, and if also no, block the order
        Dim DtVE As DataTable = OraDbUtil.dbGetDataTable(SAPDbConn,
                " select pernr from saprdp.knvp " +
                " where kunnr='" + ERPId + "' and vkorg='" + OrgId + "' and parvw='VE' and pernr<>'00000000'")
        '20171002 TC: Per AJP YC's request, always use wisepoint order's VE sales code for redeem order's VE sales code
        If DtVE.Rows.Count = 0 Or OrgId = "JP01" Then
            Dim SalesPernr As New SO_CREATE_COMMIT.BAPIPARNR
            SalesPernr.Partn_Role = "VE" : SalesPernr.Partn_Numb = LatestOrder.First.Pernr
            PartNr.Add(SalesPernr)
        End If

        Dim LineNo As Integer = 2
        Dim TotalAmount As Decimal = 0
        For Each RedeemItem As RedeemItemPointQty In InputV2.RedeemItemList
            Dim Item_Record_WISE As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_WISE As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_WISE As New SO_CREATE_COMMIT.BAPICOND
            Item_Record_WISE.Material = Global_Inc.Format2SAPItem(RedeemItem.RedeemPartNo)
            Item_Record_WISE.Itm_Number = LineNo
            '20171222 TC: Per Poki's suggestion record point in SAP will help better trace historical log
            Item_Record_WISE.Ref_1 = RedeemItem.RedeemPoints.ToString()
            Item_Record_WISE.Purch_No_C = InputV2.AssetId
            If IsZeroPointRedeem Then
                Item_Record_WISE.Item_Categ = "ZTN3"
            End If
            '20170829 TC: ASG Guo-Lu request to set stor. loc. to 1100 which means good will be shipped from TW directly
            If OrgId = "SG01" Then
                Item_Record_WISE.Store_Loc = "1100" : Item_Record_WISE.Plant = "SGH1"
            End If
            ItemIn.Add(Item_Record_WISE)

            ScheLine_Record_WISE.Itm_Number = Item_Record_WISE.Itm_Number
            ScheLine_Record_WISE.Req_Qty = RedeemItem.Qty : ScheLine_Record_WISE.Req_Date = Now.ToString("yyyyMMdd")

            ScheLine.Add(ScheLine_Record_WISE)

            S_ConditionRow_WISE.Itm_Number = Item_Record_WISE.Itm_Number : S_ConditionRow_WISE.Cond_Type = "ZPN0" : S_ConditionRow_WISE.Currency = Currency
            If Currency = "TWD" Or Currency = "JPY" Then
                S_ConditionRow_WISE.Cond_Value = Math.Ceiling(RedeemItem.RedeemPoints * AmountPerPoint / RedeemItem.Qty)
            Else
                S_ConditionRow_WISE.Cond_Value = RedeemItem.RedeemPoints * AmountPerPoint / RedeemItem.Qty
                S_ConditionRow_WISE.Cond_Value = Math.Round(S_ConditionRow_WISE.Cond_Value, 2)
            End If

            TotalAmount += S_ConditionRow_WISE.Cond_Value * ScheLine_Record_WISE.Req_Qty
            If Not IsZeroPointRedeem Then
                Conditions.Add(S_ConditionRow_WISE)
            End If
            LineNo += 1
        Next

        If Not IsZeroPointRedeem Then
            Dim Item_Record_DownPay As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_DownPay As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_DownPay As New SO_CREATE_COMMIT.BAPICOND
            Item_Record_DownPay.Material = WisePointPN
            Item_Record_DownPay.Itm_Number = "1" : Item_Record_DownPay.Ref_1 = "MyAdvantech"
            Item_Record_DownPay.Purch_No_C = InputV2.AssetId
            ItemIn.Add(Item_Record_DownPay)
            ScheLine_Record_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number
            ScheLine_Record_DownPay.Req_Qty = 1 : ScheLine_Record_DownPay.Req_Date = Now.ToString("yyyyMMdd")
            ScheLine.Add(ScheLine_Record_DownPay)
            S_ConditionRow_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number : S_ConditionRow_DownPay.Cond_Type = "ZPN0" : S_ConditionRow_DownPay.Currency = Currency
            S_ConditionRow_DownPay.Cond_Value = TotalAmount * -1 : Conditions.Add(S_ConditionRow_DownPay)
        End If


        proxy1.Connection = New SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings(SAPRFCConn))
        proxy1.Connection.Open()
        Dim strError As String = "", strRelationType As String = "", strPConvert As String = "", strpintnumassign As String = ""
        Dim strPTestRun As String = "", Doc_Number As String = ""
        Dim retTable As New SO_CREATE_COMMIT.BAPIRET2Table
        Dim refDoc_Number As String = SAPDAL.SAPDAL.SO_GetNumber("WISE")
        Doc_Number = refDoc_Number

        ReturnResult1.SONO = refDoc_Number

        proxy1.Bapi_Salesorder_Createfromdat2(
                strError, strRelationType, strPConvert, strpintnumassign, New SO_CREATE_COMMIT.BAPISDLS,
                OrderHeader, New SO_CREATE_COMMIT.BAPISDHD1X, Doc_Number, New SO_CREATE_COMMIT.BAPI_SENDER,
                strPTestRun, refDoc_Number, New SO_CREATE_COMMIT.BAPIPAREXTable, New SO_CREATE_COMMIT.BAPICCARDTable,
                New SO_CREATE_COMMIT.BAPICUBLBTable, New SO_CREATE_COMMIT.BAPICUINSTable, New SO_CREATE_COMMIT.BAPICUPRTTable,
                New SO_CREATE_COMMIT.BAPICUCFGTable, New SO_CREATE_COMMIT.BAPICUREFTable, New SO_CREATE_COMMIT.BAPICUVALTable,
                New SO_CREATE_COMMIT.BAPICUVKTable, Conditions, New SO_CREATE_COMMIT.BAPICONDXTable, ItemIn,
                New SO_CREATE_COMMIT.BAPISDITMXTable, New SO_CREATE_COMMIT.BAPISDKEYTable, PartNr, ScheLine,
                New SO_CREATE_COMMIT.BAPISCHDLXTable, New SO_CREATE_COMMIT.BAPISDTEXTTable, New SO_CREATE_COMMIT.BAPIADDR1Table, retTable)

        proxy1.CommitWork()
        proxy1.Connection.Close()

        Dim SOReturnList As New List(Of SO_CREATE_COMMIT.BAPIRET2)
        SOReturnList.AddRange(Util.DataTableToList(Of SO_CREATE_COMMIT.BAPIRET2)(retTable.ToADODataTable()))

        Dim SOErrors = From q In SOReturnList Where q.Type = "E"

        If SOErrors.Count > 0 Then
            ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when creating SO:"
            For Each er In SOErrors
                ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
            Next
            Throw New WisePoint2OrderException(ReturnResult1.ErrorMessage)
        End If

        '20170825 Poki: After discussion with Samantha, only material type = ZINT AND material group 32 need to add inventory 
        '20160310 Poki: 灌庫存部分, 必須是自製軟體才能灌庫存, 請用material type = ZINT 判斷, 其他的不需要灌庫存
        For Each RedeemItem As RedeemItemPointQty In InputV2.RedeemItemList
            Dim SAPApt As New Oracle.DataAccess.Client.OracleDataAdapter(
                "select MTART, MATKL from saprdp.mara where matnr='" + Global_Inc.Format2SAPItem(RedeemItem.RedeemPartNo) + "'", ConfigurationManager.ConnectionStrings(SAPDbConn).ConnectionString)
            Dim dtMaterialType As New DataTable
            SAPApt.Fill(dtMaterialType)
            SAPApt.SelectCommand.Connection.Close()
            If dtMaterialType.Rows.Count > 0 AndAlso dtMaterialType.Rows(0).Item("MTART") = "ZINT" AndAlso dtMaterialType.Rows(0).Item("MATKL") = "32" Then
                Dim proxy2 As New ZBAPI_GOODSMVT_CREATE.ZBAPI_GOODSMVT_CREATE(ConfigurationManager.AppSettings(SAPRFCConn))
                Dim GOODSMVT_HEADER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_01()
                Dim GOODSMVT_CODE As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_CODE()
                Dim GOODSMVT_ITEM As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATETable()
                Dim GOODSMVT_SERIALNUMBER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_SERIALNUMBERTable()
                Dim GOODSMVT_Return As New ZBAPI_GOODSMVT_CREATE.BAPIRET2Table()
                Dim GOODSMVT_HEADRET As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_RET()
                Dim MATERIALDOCUMENT As String = "", MATDOCUMENTYEAR As String = ""

                With GOODSMVT_HEADER
                    .Pstng_Date = Now.ToString("yyyyMMdd")  '實際過帳日期
                    .Doc_Date = Now.ToString("yyyyMMdd")    '單據日期
                    .Pr_Uname = "b2baeu"
                    '20171026 TC: Per Poki's suggestion, input SO No. to inventory material doc.'s header text field, so it can be tracked which added inventory isa for which SO No.
                    .Header_Txt = Doc_Number
                End With
                GOODSMVT_CODE.Gm_Code = "05"    'fix "05" 

                Dim GOODSMVTItem1 As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATE()
                With GOODSMVTItem1
                    .Material = Global_Inc.Format2SAPItem(RedeemItem.RedeemPartNo) : .Plant = Left(OrgId, 2) + "H1"
                    .Stge_Loc = "0000" : .Move_Type = "913" : .Entry_Qnt = RedeemItem.Qty
                End With
                GOODSMVT_ITEM.Add(GOODSMVTItem1)

                proxy2.Connection.Open()
                proxy2.Zbapi_Goodsmvt_Create(GOODSMVT_CODE, GOODSMVT_HEADER, "", GOODSMVT_HEADRET, MATDOCUMENTYEAR, MATERIALDOCUMENT, GOODSMVT_ITEM, GOODSMVT_SERIALNUMBER, GOODSMVT_Return)
                proxy2.Connection.Close()

                Dim GoodMVTReturn As New List(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)
                GoodMVTReturn.AddRange(Util.DataTableToList(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)(GOODSMVT_Return.ToADODataTable()))

                Dim GoodMVTErrors = From q In GoodMVTReturn Where q.Type = "E"

                If GoodMVTErrors.Count > 0 Then
                    ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when adding inventory:"
                    For Each er In GoodMVTErrors
                        ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
                    Next
                    Throw New WisePoint2OrderException(ReturnResult1.ErrorMessage)
                Else
                    'ReturnResult1.InventoryMatDoc = GOODSMVT_HEADRET.Mat_Doc
                End If
            Else
                'ReturnResult1.InventoryMatDoc = "No need"
            End If
        Next



        '20160323 TC: Check if any order line has GP block, call RFC to unblock it
        Threading.Thread.Sleep(10000)
        If IsToSAPPRD Then
            UnblockSOGP(ReturnResult1.SONO)
        End If

        SendWisePortalPIEmailV2("", InputV2.RedeemItemList(0).RedeemPartNo, ReturnResult1.SONO, LatestOrder.First.Aubel)
        ReturnResult1.IsSuccess = True
        LogWisePointRedeemRequest("", InputV2.WisePointOrderSONO, WisePointPN, InputV2.RedeemItemList(0).RedeemPartNo, InputV2.RedeemItemList(0).Qty, TotalAmount, InputV2.AssetId, ReturnResult1)

        Return ReturnResult1
    End Function

    Public Function WISEPoint2OrderV3(Input As WISEPoint2OrderV2Input) As ReturnResult
        Dim ReturnResult1 As New ReturnResult(), jsr As New Script.Serialization.JavaScriptSerializer()
        Dim WisePointPN = "", TotalAmount = 0
        Dim IsZeroPointRedeem As Boolean = False
        If Input.RedeemPoints = 0 Then
            IsZeroPointRedeem = True : Input.RedeemPoints = 1
        End If
        Try
            If String.IsNullOrEmpty(Input.WisePointOrderSONO) Then Throw New WisePoint2OrderException("Please input WisePointOrderSONO")
            '20171017 TC: If input SO is a pure numeric one, append zero to 10 digits
            Input.WisePointOrderSONO = Global_Inc.SONoBuildSAPFormat(Input.WisePointOrderSONO)

            Dim proxy0 As New Z_VBRP_SELECT_01.Z_VBRP_SELECT_01(ConfigurationManager.AppSettings("SAP_PRD"))
            Dim ZVBRP As New Z_VBRP_SELECT_01.ZVBRPVB_T
            proxy0.Connection.Open()
            proxy0.Z_Vbrp_Select_01("20160101", "99991231", "98DP", ZVBRP)
            proxy0.Connection.Close()
            Dim VBRPRecords As New List(Of Z_VBRP_SELECT_01.ZVBRPVB)
            For Each vbrprec As Z_VBRP_SELECT_01.ZVBRPVB In ZVBRP
                VBRPRecords.Add(vbrprec)
            Next

            '20161004 TC: Per Poki's advise, added two new point items 98DPWSPAP1 & 98DPWAP1H
            Dim LatestOrder = From q In VBRPRecords Where String.Equals(q.Aubel, Input.WisePointOrderSONO, StringComparison.CurrentCultureIgnoreCase) _
                And q.Netwr > 0 And
                (q.Matnr = "98DPWAP1H" Or q.Matnr = "98DPWAP2K" Or q.Matnr = "98DPWSPA0A" Or q.Matnr = "98DPWSPAP1") _
                And q.Shkzg <> "X" Order By q.Fkdat Descending Take 1

            If LatestOrder.Count = 0 Then
                Throw New WisePoint2OrderException("Cannot find WISE point order record")
            End If

            Dim Currency = LatestOrder.First.Waerk
            'Dim CurrencyFactor = dbUtil.dbExecuteScalar("MY", "select FACTOR from SAP_TCURX where CURRENCY='" + Currency + "'")
            'If CurrencyFactor IsNot Nothing Then LatestOrder.First.Netwr = LatestOrder.First.Netwr * Math.Pow(10, 2 - CInt(CurrencyFactor))
            WisePointPN = LatestOrder.First.Matnr
            Dim PointsOfItem As Integer = 0
            Select Case WisePointPN
                Case "98DPWAP1H", "98DPWSPAP1"
                    PointsOfItem = 100
                Case "98DPWAP2K", "98DPWSPA0A"
                    PointsOfItem = 2000
            End Select
            Dim AmountPerPoint = LatestOrder.First.Netwr / PointsOfItem / LatestOrder.First.Fkimg
            Dim TotalAmountPerPiece = AmountPerPoint * Input.RedeemPoints / Input.Qty
            TotalAmount = TotalAmountPerPiece * Input.Qty

            '20160516 TC: Adopt Wise Point SO's org for resolving's TW02 case
            Dim OrgId = LatestOrder.First.Vkorg
            Dim ERPId = LatestOrder.First.Kunag

            Dim sqlCheckWisePN As String = "select count(*) from [WISE_PaaS_Marketplace_V2].[dbo].[WISE_PaaS_PackagePlan] where PISID=@PN"
            Dim cmdMyLocal As New SqlClient.SqlCommand(sqlCheckWisePN, New SqlClient.SqlConnection(WisePortalProductConn))
            cmdMyLocal.Parameters.AddWithValue("PN", Input.RedeemPartNo)
            cmdMyLocal.Connection.Open()
            Dim chkCount As Integer = CInt(cmdMyLocal.ExecuteScalar())
            cmdMyLocal.Connection.Close()
            If chkCount = 0 Then
                Throw New WisePoint2OrderException(String.Format("{0} is not a WISE Portal Part Number", Input.RedeemPartNo))
            End If

            ReturnResult1.ERPID = ERPId : ReturnResult1.OrgId = OrgId

            '20170510 TC: Per WISE PM and Chris's request, force TW02 to TW01
            If OrgId = "TW02" Then OrgId = "TW01"

            Dim proxy1 As New SO_CREATE_COMMIT.SO_CREATE_COMMIT, OrderHeader As New SO_CREATE_COMMIT.BAPISDHD1, ItemIn As New SO_CREATE_COMMIT.BAPISDITMTable
            Dim PartNr As New SO_CREATE_COMMIT.BAPIPARNRTable, ScheLine As New SO_CREATE_COMMIT.BAPISCHDLTable, Conditions As New SO_CREATE_COMMIT.BAPICONDTable

            Dim distr_chan As String = "10", division As String = "00"

            If Trim(OrgId).ToUpper() = "US01" Then
                '20160526 TC: To be implemented
                Dim OfficeDivisionDt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD",
                                                                             "select VKBUR, SPART from saprdp.knvv where kunnr='" + ReturnResult1.ERPID + "' and vkorg='US01'")

                If OfficeDivisionDt.Rows.Count > 0 Then
                    Dim SalesOffice = OfficeDivisionDt.Rows(0).Item("VKBUR").ToString() : Dim SAPCustDivision = OfficeDivisionDt.Rows(0).Item("SPART").ToString()

                    If SalesOffice = "2300" OrElse SAPCustDivision = "20" Then
                        distr_chan = "10" : division = "20"
                    Else
                        distr_chan = "30" : division = "10"
                    End If
                End If

            End If
            '20160617 TC: Per Fanny.Tseng's request for ATHI001 (IBCON)'s order's org shall be SG01 from now on
            'If ERPId = "ATHI001" Then OrgId = "TW01"
            With OrderHeader
                .Doc_Type = "ZOR2" : .Sales_Org = OrgId : .Distr_Chan = distr_chan : .Division = division : .Currency = Currency
                '20160323 TC: Chris asked to tick complete delivery for WISE Point's SO
                .Compl_Dlv = "X"
                '20160527 TC: For CN10 always set group 600 office 6100, per Poki/Chris/Alice.Wang's request
                If OrgId = "CN10" Then
                    .Sales_Grp = "600" : .Sales_Off = "6100"
                End If

            End With

            'ERPId = "T00694868"
            Dim PartNr_Ship_Record As New SO_CREATE_COMMIT.BAPIPARNR
            PartNr_Ship_Record.Partn_Role = "WE" : PartNr_Ship_Record.Partn_Numb = ERPId
            PartNr.Add(PartNr_Ship_Record)
            Dim PartNr_Sold_Record As New SO_CREATE_COMMIT.BAPIPARNR
            PartNr_Sold_Record.Partn_Role = "AG" : PartNr_Sold_Record.Partn_Numb = ERPId
            PartNr.Add(PartNr_Sold_Record)

            '20160527 TC: For CN10 always insert end customer, per Poki/Chris/Alice.Wang's request
            If OrgId = "CN10" Then
                Dim PartNr_EndCust_Record As New SO_CREATE_COMMIT.BAPIPARNR
                PartNr_Sold_Record.Partn_Role = "EM" : PartNr_Sold_Record.Partn_Numb = ERPId
                PartNr.Add(PartNr_Sold_Record)
            End If

            '20160923 TC: If VE is not maintained for current customer on SAP, find latest WISE point order's VE, and if also no, block the order
            Dim DtVE As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD",
                " select pernr from saprdp.knvp " +
                " where kunnr='" + ERPId + "' and vkorg='" + OrgId + "' and parvw='VE' and pernr<>'00000000'")
            '20171002 TC: Per AJP YC's request, always use wisepoint order's VE sales code for redeem order's VE sales code
            If DtVE.Rows.Count = 0 Or OrgId = "JP01" Then
                Dim SalesPernr As New SO_CREATE_COMMIT.BAPIPARNR
                SalesPernr.Partn_Role = "VE" : SalesPernr.Partn_Numb = LatestOrder.First.Pernr
                PartNr.Add(SalesPernr)
            End If

            Dim LineNo As Integer = 1

            'For Each WPItem In WISEPointItems
            If Not IsZeroPointRedeem Then
                Dim Item_Record_DownPay As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_DownPay As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_DownPay As New SO_CREATE_COMMIT.BAPICOND

                Item_Record_DownPay.Material = WisePointPN
                Item_Record_DownPay.Itm_Number = LineNo : Item_Record_DownPay.Ref_1 = "MyAdvantech"
                Item_Record_DownPay.Purch_No_C = Input.AssetId
                ItemIn.Add(Item_Record_DownPay)

                ScheLine_Record_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number
                ScheLine_Record_DownPay.Req_Qty = Input.Qty : ScheLine_Record_DownPay.Req_Date = Now.ToString("yyyyMMdd")

                ScheLine.Add(ScheLine_Record_DownPay)

                S_ConditionRow_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number : S_ConditionRow_DownPay.Cond_Type = "ZPN0" : S_ConditionRow_DownPay.Currency = Currency
                S_ConditionRow_DownPay.Cond_Value = TotalAmountPerPiece * -1 : Conditions.Add(S_ConditionRow_DownPay)
                LineNo += 1
                'Next
            Else

            End If


            Dim Item_Record_WISE As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_WISE As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_WISE As New SO_CREATE_COMMIT.BAPICOND

            Item_Record_WISE.Material = Global_Inc.Format2SAPItem(Input.RedeemPartNo)
            Item_Record_WISE.Itm_Number = LineNo : Item_Record_WISE.Ref_1 = "MyAdvantech"
            Item_Record_WISE.Purch_No_C = Input.AssetId
            If IsZeroPointRedeem Then
                Item_Record_WISE.Item_Categ = "ZTN3"
            End If
            '20170829 TC: ASG Guo-Lu request to set stor. loc. to 1100 which means good will be shipped from TW directly
            If OrgId = "SG01" Then
                Item_Record_WISE.Store_Loc = "1100" : Item_Record_WISE.Plant = "SGH1"
            End If
            ItemIn.Add(Item_Record_WISE)

            ScheLine_Record_WISE.Itm_Number = Item_Record_WISE.Itm_Number
            ScheLine_Record_WISE.Req_Qty = Input.Qty : ScheLine_Record_WISE.Req_Date = Now.ToString("yyyyMMdd")

            ScheLine.Add(ScheLine_Record_WISE)

            S_ConditionRow_WISE.Itm_Number = Item_Record_WISE.Itm_Number : S_ConditionRow_WISE.Cond_Type = "ZPN0" : S_ConditionRow_WISE.Currency = Currency
            S_ConditionRow_WISE.Cond_Value = TotalAmountPerPiece
            If Not IsZeroPointRedeem Then
                Conditions.Add(S_ConditionRow_WISE)
            End If


            proxy1.Connection = New SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings("SAPConnTest"))
            If IsToSAPPRD Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
            proxy1.Connection.Open()
            Dim strError As String = "", strRelationType As String = "", strPConvert As String = "", strpintnumassign As String = ""
            Dim strPTestRun As String = "", Doc_Number As String = ""
            Dim retTable As New SO_CREATE_COMMIT.BAPIRET2Table
            Dim refDoc_Number As String = SAPDAL.SAPDAL.SO_GetNumber("WISE")
            Doc_Number = refDoc_Number

            ReturnResult1.SONO = refDoc_Number

            proxy1.Bapi_Salesorder_Createfromdat2(
                strError, strRelationType, strPConvert, strpintnumassign, New SO_CREATE_COMMIT.BAPISDLS,
                OrderHeader, New SO_CREATE_COMMIT.BAPISDHD1X, Doc_Number, New SO_CREATE_COMMIT.BAPI_SENDER,
                strPTestRun, refDoc_Number, New SO_CREATE_COMMIT.BAPIPAREXTable, New SO_CREATE_COMMIT.BAPICCARDTable,
                New SO_CREATE_COMMIT.BAPICUBLBTable, New SO_CREATE_COMMIT.BAPICUINSTable, New SO_CREATE_COMMIT.BAPICUPRTTable,
                New SO_CREATE_COMMIT.BAPICUCFGTable, New SO_CREATE_COMMIT.BAPICUREFTable, New SO_CREATE_COMMIT.BAPICUVALTable,
                New SO_CREATE_COMMIT.BAPICUVKTable, Conditions, New SO_CREATE_COMMIT.BAPICONDXTable, ItemIn,
                New SO_CREATE_COMMIT.BAPISDITMXTable, New SO_CREATE_COMMIT.BAPISDKEYTable, PartNr, ScheLine,
                New SO_CREATE_COMMIT.BAPISCHDLXTable, New SO_CREATE_COMMIT.BAPISDTEXTTable, New SO_CREATE_COMMIT.BAPIADDR1Table, retTable)

            proxy1.CommitWork()
            proxy1.Connection.Close()

            Dim SOReturnList As New List(Of SO_CREATE_COMMIT.BAPIRET2)
            SOReturnList.AddRange(Util.DataTableToList(Of SO_CREATE_COMMIT.BAPIRET2)(retTable.ToADODataTable()))

            Dim SOErrors = From q In SOReturnList Where q.Type = "E"

            If SOErrors.Count > 0 Then
                ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when creating SO:"
                For Each er In SOErrors
                    ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
                Next
                Throw New WisePoint2OrderException(ReturnResult1.ErrorMessage)
            End If

            '20170825 Poki: After discussion with Samantha, only material type = ZINT AND material group 32 need to add inventory 
            '20160310 Poki: 灌庫存部分, 必須是自製軟體才能灌庫存, 請用material type = ZINT 判斷, 其他的不需要灌庫存
            Dim SAPApt As New Oracle.DataAccess.Client.OracleDataAdapter("select MTART, MATKL from saprdp.mara where matnr='" + Item_Record_WISE.Material + "'", ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
            Dim dtMaterialType As New DataTable
            SAPApt.Fill(dtMaterialType)
            SAPApt.SelectCommand.Connection.Close()
            If dtMaterialType.Rows.Count > 0 AndAlso dtMaterialType.Rows(0).Item("MTART") = "ZINT" AndAlso dtMaterialType.Rows(0).Item("MATKL") = "32" Then
                Dim proxy2 As New ZBAPI_GOODSMVT_CREATE.ZBAPI_GOODSMVT_CREATE(ConfigurationManager.AppSettings("SAPConnTest"))
                If IsToSAPPRD Then proxy2.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
                Dim GOODSMVT_HEADER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_01()
                Dim GOODSMVT_CODE As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_CODE()
                Dim GOODSMVT_ITEM As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATETable()
                Dim GOODSMVT_SERIALNUMBER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_SERIALNUMBERTable()
                Dim GOODSMVT_Return As New ZBAPI_GOODSMVT_CREATE.BAPIRET2Table()
                Dim GOODSMVT_HEADRET As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_RET()
                Dim MATERIALDOCUMENT As String = "", MATDOCUMENTYEAR As String = ""

                With GOODSMVT_HEADER
                    .Pstng_Date = Now.ToString("yyyyMMdd")  '實際過帳日期
                    .Doc_Date = Now.ToString("yyyyMMdd")    '單據日期
                    .Pr_Uname = "b2baeu"
                    '20171026 TC: Per Poki's suggestion, input SO No. to inventory material doc.'s header text field, so it can be tracked which added inventory isa for which SO No.
                    .Header_Txt = Doc_Number
                End With
                GOODSMVT_CODE.Gm_Code = "05"    'fix "05" 

                Dim GOODSMVTItem1 As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATE()
                With GOODSMVTItem1
                    .Material = Item_Record_WISE.Material : .Plant = Left(OrgId, 2) + "H1" : .Stge_Loc = "0000" : .Move_Type = "913" : .Entry_Qnt = Input.Qty
                End With
                GOODSMVT_ITEM.Add(GOODSMVTItem1)

                proxy2.Connection.Open()
                proxy2.Zbapi_Goodsmvt_Create(GOODSMVT_CODE, GOODSMVT_HEADER, "", GOODSMVT_HEADRET, MATDOCUMENTYEAR, MATERIALDOCUMENT, GOODSMVT_ITEM, GOODSMVT_SERIALNUMBER, GOODSMVT_Return)
                proxy2.Connection.Close()

                Dim GoodMVTReturn As New List(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)
                GoodMVTReturn.AddRange(Util.DataTableToList(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)(GOODSMVT_Return.ToADODataTable()))

                Dim GoodMVTErrors = From q In GoodMVTReturn Where q.Type = "E"

                If GoodMVTErrors.Count > 0 Then
                    ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when adding inventory:"
                    For Each er In GoodMVTErrors
                        ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
                    Next
                    Throw New WisePoint2OrderException(ReturnResult1.ErrorMessage)
                Else
                    ReturnResult1.InventoryMatDoc = GOODSMVT_HEADRET.Mat_Doc
                End If
            Else
                ReturnResult1.InventoryMatDoc = "No need"
            End If


            '20160323 TC: Check if any order line has GP block, call RFC to unblock it
            Threading.Thread.Sleep(10000)
            If IsToSAPPRD Then
                UnblockSOGP(ReturnResult1.SONO)
            End If

            SendWisePortalPIEmailV2(Input.MembershipEmail, Input.RedeemPartNo, ReturnResult1.SONO, LatestOrder.First.Aubel)
            ReturnResult1.IsSuccess = True
        Catch ex As WisePoint2OrderException
            ReturnResult1.IsSuccess = False : ReturnResult1.ErrorMessage = ex.ErrorMessage
        Catch ex2 As Exception
            ReturnResult1.IsSuccess = False : ReturnResult1.ErrorMessage = "Runtime error:" + ex2.ToString()
        End Try
        LogWisePointRedeemRequest(Input.MembershipEmail, Input.WisePointOrderSONO, WisePointPN, Input.RedeemPartNo, Input.Qty, TotalAmount, Input.AssetId, ReturnResult1)
        ReturnResult1.ERPID = "" : ReturnResult1.InventoryMatDoc = "" : ReturnResult1.OrgId = "" : ReturnResult1.SONO = ""
        Return ReturnResult1

    End Function

    Public Function WISEPoint2OrderV2(Input As WISEPoint2OrderV2Input) As ReturnResult
        Dim ReturnResult1 As New ReturnResult(), jsr As New Script.Serialization.JavaScriptSerializer()
        Dim WisePointPN = "", TotalAmount = 0
        Try
            Dim ERPId As String = String.Empty, OrgId As String = String.Empty ', SAPPartNo As String = String.Empty
            Dim sqlGetERPId As String =
                " select distinct top 1 b.COMPANY_ID, b.ORG_ID, b.salesoffice, b.CURRENCY " +
                " from SIEBEL_CONTACT a (nolock) inner join SAP_DIMCOMPANY b (nolock) on a.ERPID=b.COMPANY_ID  " +
                " where a.EMAIL_ADDRESS not like '%@advantech%.%' and a.ACTIVE_FLAG='Y' and b.COMPANY_TYPE='Z001' " +
                " and b.ORG_ID not in ('CN02','CN11','CN12','CN13','CN20','CN30','CN40','EU20','EU30','EU31','EU32','EU33','EU34','EU50','TW02','TW03','TW04','TWCP','TW07') " +
                " and dbo.IsEmail(a.EMAIL_ADDRESS)=1 " +
                " and a.EMAIL_ADDRESS=@EMAIL " +
                " order by b.ORG_ID  "
            Dim AptSiebel As New SqlClient.SqlDataAdapter(sqlGetERPId, ConfigurationManager.ConnectionStrings("MY").ConnectionString)
            Dim dtERPId As New DataTable
            AptSiebel.SelectCommand.Parameters.AddWithValue("EMAIL", Input.MembershipEmail)
            AptSiebel.Fill(dtERPId)
            AptSiebel.SelectCommand.Connection.Close()
            If dtERPId.Rows.Count = 0 Then
                Throw New WisePoint2OrderException("Cannot find a valid ERPID for this customer from Siebel")
            Else
                ERPId = dtERPId.Rows(0).Item("COMPANY_ID") : OrgId = dtERPId.Rows(0).Item("ORG_ID")
            End If

            Dim proxy0 As New Z_VBRP_SELECT_01.Z_VBRP_SELECT_01(ConfigurationManager.AppSettings("SAP_PRD"))
            Dim ZVBRP As New Z_VBRP_SELECT_01.ZVBRPVB_T
            proxy0.Connection.Open()
            proxy0.Z_Vbrp_Select_01("20160101", "99991231", "98DP", ZVBRP)
            proxy0.Connection.Close()
            Dim VBRPRecords As New List(Of Z_VBRP_SELECT_01.ZVBRPVB)
            For Each vbrprec As Z_VBRP_SELECT_01.ZVBRPVB In ZVBRP
                VBRPRecords.Add(vbrprec)
            Next
            Dim LatestOrder = From q In VBRPRecords Where q.Kunag = ERPId And q.Netwr > 0 And (q.Matnr = "98DPWAP1H" Or q.Matnr = "98DPWAP2K") Order By q.Fkdat Descending Take 1

            If LatestOrder.Count = 0 Then
                Throw New WisePoint2OrderException("Cannot find WISE point order record")

            End If

            Dim Currency = LatestOrder.First.Waerk
            Dim CurrencyFactor = dbUtil.dbExecuteScalar("MY", "select FACTOR from SAP_TCURX where CURRENCY='" + Currency + "'")
            If CurrencyFactor IsNot Nothing Then LatestOrder.First.Netwr = LatestOrder.First.Netwr * Math.Pow(10, 2 - CInt(CurrencyFactor))
            WisePointPN = LatestOrder.First.Matnr
            Dim AmountPerPoint = LatestOrder.First.Netwr / IIf(WisePointPN = "98DPWAP1H", 100, 2000) / LatestOrder.First.Fkimg
            Dim TotalAmountPerPiece = AmountPerPoint * Input.RedeemPoints / Input.Qty
            TotalAmount = TotalAmountPerPiece * Input.Qty

            If dtERPId.Rows.Count = 0 Then
                Throw New WisePoint2OrderException("Cannot find a valid ERPID for this customer from Siebel")
            Else
                ERPId = dtERPId.Rows(0).Item("COMPANY_ID") : OrgId = dtERPId.Rows(0).Item("ORG_ID")
            End If

            '20160516 TC: Adopt Wise Point SO's org for resolving's TW02 case
            OrgId = LatestOrder.First.Vkorg

            Dim sqlCheckWisePN As String = "select count(*) from WISE_PORTAL_PRODUCT where PART_NO=@PN"
            Dim cmdMyLocal As New SqlClient.SqlCommand(sqlCheckWisePN, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString))
            cmdMyLocal.Parameters.AddWithValue("PN", Input.RedeemPartNo)
            cmdMyLocal.Connection.Open()
            Dim chkCount As Integer = CInt(cmdMyLocal.ExecuteScalar())
            cmdMyLocal.Connection.Close()
            If chkCount = 0 Then
                Throw New WisePoint2OrderException(String.Format("{0} is not a WISE Portal Part Number", Input.RedeemPartNo))
            End If

            ReturnResult1.ERPID = ERPId : ReturnResult1.OrgId = OrgId

            Dim proxy1 As New SO_CREATE_COMMIT.SO_CREATE_COMMIT, OrderHeader As New SO_CREATE_COMMIT.BAPISDHD1, ItemIn As New SO_CREATE_COMMIT.BAPISDITMTable
            Dim PartNr As New SO_CREATE_COMMIT.BAPIPARNRTable, ScheLine As New SO_CREATE_COMMIT.BAPISCHDLTable, Conditions As New SO_CREATE_COMMIT.BAPICONDTable

            Dim distr_chan As String = "10", division As String = "00"

            If Trim(OrgId).ToUpper() = "US01" Then
                If dtERPId.Rows(0).Item("salesoffice") = "2300" Then
                    distr_chan = "10" : division = "20"
                Else
                    distr_chan = "30" : division = "10"
                End If
            End If
            If ERPId = "ATHI001" Then OrgId = "TW01"
            With OrderHeader
                .Doc_Type = "ZOR2" : .Sales_Org = OrgId : .Distr_Chan = distr_chan : .Division = division : .Currency = Currency
                '20160323 TC: Chris asked to tick complete delivery for WISE Point's SO
                .Compl_Dlv = "X"
            End With

            'ERPId = "T00694868"
            Dim PartNr_Ship_Record As New SO_CREATE_COMMIT.BAPIPARNR
            PartNr_Ship_Record.Partn_Role = "WE" : PartNr_Ship_Record.Partn_Numb = ERPId
            PartNr.Add(PartNr_Ship_Record)
            Dim PartNr_Sold_Record As New SO_CREATE_COMMIT.BAPIPARNR
            PartNr_Sold_Record.Partn_Role = "AG" : PartNr_Sold_Record.Partn_Numb = ERPId
            PartNr.Add(PartNr_Sold_Record)

            Dim LineNo As Integer = 1

            'For Each WPItem In WISEPointItems
            Dim Item_Record_DownPay As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_DownPay As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_DownPay As New SO_CREATE_COMMIT.BAPICOND

            Item_Record_DownPay.Material = WisePointPN
            Item_Record_DownPay.Itm_Number = LineNo : Item_Record_DownPay.Ref_1 = "MyAdvantech"
            Item_Record_DownPay.Purch_No_C = Input.AssetId
            ItemIn.Add(Item_Record_DownPay)

            ScheLine_Record_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number
            ScheLine_Record_DownPay.Req_Qty = Input.Qty : ScheLine_Record_DownPay.Req_Date = Now.ToString("yyyyMMdd")

            ScheLine.Add(ScheLine_Record_DownPay)

            S_ConditionRow_DownPay.Itm_Number = Item_Record_DownPay.Itm_Number : S_ConditionRow_DownPay.Cond_Type = "ZPN0" : S_ConditionRow_DownPay.Currency = Currency
            S_ConditionRow_DownPay.Cond_Value = TotalAmountPerPiece * -1 : Conditions.Add(S_ConditionRow_DownPay)
            LineNo += 1
            'Next

            Dim Item_Record_WISE As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record_WISE As New SO_CREATE_COMMIT.BAPISCHDL, S_ConditionRow_WISE As New SO_CREATE_COMMIT.BAPICOND

            Item_Record_WISE.Material = Global_Inc.Format2SAPItem(Input.RedeemPartNo)
            Item_Record_WISE.Itm_Number = LineNo : Item_Record_WISE.Ref_1 = "MyAdvantech"
            Item_Record_WISE.Purch_No_C = Input.AssetId
            ItemIn.Add(Item_Record_WISE)

            ScheLine_Record_WISE.Itm_Number = Item_Record_WISE.Itm_Number
            ScheLine_Record_WISE.Req_Qty = Input.Qty : ScheLine_Record_WISE.Req_Date = Now.ToString("yyyyMMdd")

            ScheLine.Add(ScheLine_Record_WISE)

            S_ConditionRow_WISE.Itm_Number = Item_Record_WISE.Itm_Number : S_ConditionRow_WISE.Cond_Type = "ZPN0" : S_ConditionRow_WISE.Currency = Currency
            S_ConditionRow_WISE.Cond_Value = TotalAmountPerPiece : Conditions.Add(S_ConditionRow_WISE)

            proxy1.Connection = New SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings("SAPConnTest"))
            If IsToSAPPRD Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
            proxy1.Connection.Open()
            Dim strError As String = "", strRelationType As String = "", strPConvert As String = "", strpintnumassign As String = ""
            Dim strPTestRun As String = "", Doc_Number As String = ""
            Dim retTable As New SO_CREATE_COMMIT.BAPIRET2Table
            Dim refDoc_Number As String = SAPDAL.SAPDAL.SO_GetNumber("WISE")
            Doc_Number = refDoc_Number

            ReturnResult1.SONO = refDoc_Number

            proxy1.Bapi_Salesorder_Createfromdat2(
                strError, strRelationType, strPConvert, strpintnumassign, New SO_CREATE_COMMIT.BAPISDLS,
                OrderHeader, New SO_CREATE_COMMIT.BAPISDHD1X, Doc_Number, New SO_CREATE_COMMIT.BAPI_SENDER,
                strPTestRun, refDoc_Number, New SO_CREATE_COMMIT.BAPIPAREXTable, New SO_CREATE_COMMIT.BAPICCARDTable,
                New SO_CREATE_COMMIT.BAPICUBLBTable, New SO_CREATE_COMMIT.BAPICUINSTable, New SO_CREATE_COMMIT.BAPICUPRTTable,
                New SO_CREATE_COMMIT.BAPICUCFGTable, New SO_CREATE_COMMIT.BAPICUREFTable, New SO_CREATE_COMMIT.BAPICUVALTable,
                New SO_CREATE_COMMIT.BAPICUVKTable, Conditions, New SO_CREATE_COMMIT.BAPICONDXTable, ItemIn,
                New SO_CREATE_COMMIT.BAPISDITMXTable, New SO_CREATE_COMMIT.BAPISDKEYTable, PartNr, ScheLine,
                New SO_CREATE_COMMIT.BAPISCHDLXTable, New SO_CREATE_COMMIT.BAPISDTEXTTable, New SO_CREATE_COMMIT.BAPIADDR1Table, retTable)

            proxy1.CommitWork()
            proxy1.Connection.Close()

            Dim SOReturnList As New List(Of SO_CREATE_COMMIT.BAPIRET2)
            SOReturnList.AddRange(Util.DataTableToList(Of SO_CREATE_COMMIT.BAPIRET2)(retTable.ToADODataTable()))

            Dim SOErrors = From q In SOReturnList Where q.Type = "E"

            If SOErrors.Count > 0 Then
                ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when creating SO:"
                For Each er In SOErrors
                    ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
                Next
                Throw New WisePoint2OrderException(ReturnResult1.ErrorMessage)
            End If

            '20160310 Poki: 灌庫存部分, 必須是自製軟體才能灌庫存, 請用material type = ZINT 判斷, 其他的不需要灌庫存
            Dim SAPApt As New Oracle.DataAccess.Client.OracleDataAdapter("select MTART from saprdp.mara where matnr='" + Item_Record_WISE.Material + "'", ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
            Dim dtMaterialType As New DataTable
            SAPApt.Fill(dtMaterialType)
            SAPApt.SelectCommand.Connection.Close()
            If dtMaterialType.Rows.Count > 0 AndAlso dtMaterialType.Rows(0).Item("MTART") = "ZINT" Then
                Dim proxy2 As New ZBAPI_GOODSMVT_CREATE.ZBAPI_GOODSMVT_CREATE(ConfigurationManager.AppSettings("SAPConnTest"))
                If IsToSAPPRD Then proxy1.ConnectionString = ConfigurationManager.AppSettings("SAP_PRD")
                Dim GOODSMVT_HEADER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_01()
                Dim GOODSMVT_CODE As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_CODE()
                Dim GOODSMVT_ITEM As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATETable()
                Dim GOODSMVT_SERIALNUMBER As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_SERIALNUMBERTable()
                Dim GOODSMVT_Return As New ZBAPI_GOODSMVT_CREATE.BAPIRET2Table()
                Dim GOODSMVT_HEADRET As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_HEAD_RET()
                Dim MATERIALDOCUMENT As String = "", MATDOCUMENTYEAR As String = ""

                With GOODSMVT_HEADER
                    .Pstng_Date = Now.ToString("yyyyMMdd")  '實際過帳日期
                    .Doc_Date = Now.ToString("yyyyMMdd")    '單據日期
                    .Pr_Uname = "b2baeu"
                End With
                GOODSMVT_CODE.Gm_Code = "05"    'fix "05" 

                Dim GOODSMVTItem1 As New ZBAPI_GOODSMVT_CREATE.BAPI2017_GM_ITEM_CREATE()
                With GOODSMVTItem1
                    .Material = Item_Record_WISE.Material : .Plant = Left(OrgId, 2) + "H1" : .Stge_Loc = "0000" : .Move_Type = "913" : .Entry_Qnt = Input.Qty
                End With
                GOODSMVT_ITEM.Add(GOODSMVTItem1)

                proxy2.Connection.Open()
                proxy2.Zbapi_Goodsmvt_Create(GOODSMVT_CODE, GOODSMVT_HEADER, "", GOODSMVT_HEADRET, MATDOCUMENTYEAR, MATERIALDOCUMENT, GOODSMVT_ITEM, GOODSMVT_SERIALNUMBER, GOODSMVT_Return)
                proxy2.Connection.Close()

                Dim GoodMVTReturn As New List(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)
                GoodMVTReturn.AddRange(Util.DataTableToList(Of ZBAPI_GOODSMVT_CREATE.BAPIRET2)(GOODSMVT_Return.ToADODataTable()))

                Dim GoodMVTErrors = From q In GoodMVTReturn Where q.Type = "E"

                If GoodMVTErrors.Count > 0 Then
                    ReturnResult1.ErrorMessage += vbCrLf + "Error occurred when adding inventory:"
                    For Each er In GoodMVTErrors
                        ReturnResult1.ErrorMessage += String.Format("{0}" + vbCrLf, er.Message)
                    Next
                    Throw New WisePoint2OrderException(ReturnResult1.ErrorMessage)
                Else
                    ReturnResult1.InventoryMatDoc = GOODSMVT_HEADRET.Mat_Doc
                End If
            Else
                ReturnResult1.InventoryMatDoc = "No need"
            End If


            '20160323 TC: Check if any order line has GP block, call RFC to unblock it
            Threading.Thread.Sleep(10000)
            If IsToSAPPRD Then
                UnblockSOGP(ReturnResult1.SONO)
            End If

            'SendWisePortalPIEmail(Input.MembershipEmail, Input.RedeemPartNo, ReturnResult1.SONO)
            ReturnResult1.IsSuccess = True
        Catch ex As WisePoint2OrderException
            ReturnResult1.IsSuccess = False : ReturnResult1.ErrorMessage = ex.ErrorMessage
        Catch ex2 As Exception
            ReturnResult1.IsSuccess = False : ReturnResult1.ErrorMessage = "Runtime error:" + ex2.ToString()
        End Try
        LogWisePointRedeemRequest(Input.MembershipEmail, Input.WisePointOrderSONO, "", Input.RedeemPartNo, Input.Qty, TotalAmount, Input.AssetId, ReturnResult1)
        ReturnResult1.ERPID = "" : ReturnResult1.InventoryMatDoc = "" : ReturnResult1.OrgId = "" : ReturnResult1.SONO = ""
        Return ReturnResult1

    End Function

    Function SendWisePortalPIEmailV2(ContactEmail As String, WisePN As String, RedeemSONO As String, BoughtPointSONO As String) As Boolean

        Dim SAPRFCConn = "SAPConnTest", SAPDbConn = "SAP_Test"
        If IsToSAPPRD Then
            SAPRFCConn = "SAP_PRD" : SAPDbConn = "SAP_PRD"
        End If

        Dim sqlSOSalesEmail As String =
            " select distinct b.usrid_long as email  " +
            " from saprdp.vbpa a inner join saprdp.pa0105 b on a.pernr=b.pernr " +
            " where a.vbeln in ('" + Global_Inc.SONoBuildSAPFormat(RedeemSONO) + "','" + Global_Inc.SONoBuildSAPFormat(BoughtPointSONO) + "') and a.pernr<>'00000000' and b.subty in ('0010','MAIL') and b.usrid_long like '%@%.%' "
        Dim SAPApt As New Oracle.DataAccess.Client.OracleDataAdapter(sqlSOSalesEmail, ConfigurationManager.ConnectionStrings(SAPDbConn).ConnectionString)
        Dim dtSOEmails As New DataTable, dtCust As New DataTable, dtSODetail As New DataTable
        SAPApt.Fill(dtSOEmails)

        SAPApt.SelectCommand.CommandText =
            " select a.name1, a.name2, a.kunnr " +
            " from saprdp.kna1 a inner join saprdp.vbak b on a.kunnr=b.kunnr " +
            " where a.mandt='168' and b.vbeln='" + Global_Inc.SONoBuildSAPFormat(RedeemSONO) + "'"
        SAPApt.Fill(dtCust)

        SAPApt.SelectCommand.CommandText =
            " select a.posnr as line_no, a.matnr as part_no, a.arktx as product_desc,  " +
            " b.mtart as material_type, a.kwmeng as order_qty, a.waerk as currency, a.netpr as unit_price " +
            " from saprdp.vbap a inner join saprdp.mara b on a.matnr=b.matnr " +
            " where a.mandt='168' and a.vbeln='" + Global_Inc.SONoBuildSAPFormat(RedeemSONO) + "' " +
            " order by a.posnr "
        SAPApt.Fill(dtSODetail)

        For Each OrderRow As DataRow In dtSODetail.Rows
            Select Case OrderRow.Item("currency")
                Case "TWD"
                    OrderRow.Item("unit_price") = Math.Pow(10, 2 - 0) * CDbl(OrderRow.Item("unit_price"))
            End Select
            OrderRow.Item("line_no") = Global_Inc.RemoveZeroString(OrderRow.Item("line_no"))
            OrderRow.Item("part_no") = Global_Inc.RemoveZeroString(OrderRow.Item("part_no"))
        Next

        SAPApt.SelectCommand.Connection.Close()
        If dtCust.Rows.Count = 0 Or dtSODetail.Rows.Count = 0 Then Return False

        Dim sbMailBody As New System.Text.StringBuilder

        With sbMailBody
            .AppendFormat("Dear Sales/OP,<br/><br/>")
            .Append(String.Format("Customer {0} just used wise point to convert to product: {1}, SO No.: {2}.<br/>", ContactEmail, WisePN, RedeemSONO))
            .Append("Following is the order detail:<br/>")
            .Append("<table border='1' style='width:100%'>")
            .Append("<tr><th>Line No.</th><th>Part No.</th><th>Desc.</th><th>material type</th><th>qty.</th><th>unit price</th></tr>")
            For Each OrderRow As DataRow In dtSODetail.Rows
                .AppendFormat("<tr><td align='center'>{0}</td><td>{1}</td><td>{2}</td><td align='center'>{3}</td><td align='center'>{4}</td><td align='right'>{5}{6}</td></tr>",
                              OrderRow.Item("line_no"), OrderRow.Item("part_no"), OrderRow.Item("product_desc"), OrderRow.Item("material_type"),
                              OrderRow.Item("order_qty"), OrderRow.Item("currency"), OrderRow.Item("unit_price"))
            Next
            .Append("</table>")
            .Append("<br/>Thank you.<br/>")
            .Append("<a href='mailto:myadvantech@advantech.com'>MyAdvantech IT Team</a>")
        End With

        Dim msg As New System.Net.Mail.MailMessage()
        msg.IsBodyHtml = True
        msg.Body = sbMailBody.ToString()
        msg.From = New Net.Mail.MailAddress("MyAdvantech@advantech.com")

        If dtSOEmails.Rows.Count > 0 Then
            For Each EmailRow As DataRow In dtSOEmails.Rows
                msg.To.Add(EmailRow.Item("email"))
                If Not IsToSAPPRD Then msg.Body = EmailRow.Item("email") + "<br/>" + msg.Body
            Next
        Else
            msg.To.Add("tc.chen@advantech.com.tw")
        End If

        If IsToSAPPRD Then msg.CC.Add("wa.marketplace.acl@advantech.com")

        msg.Bcc.Add("tc.chen@advantech.com.tw")
        msg.Bcc.Add("Frank.Chung@advantech.com.tw")
        msg.Bcc.Add("yl.huang@advantech.com.tw")
        msg.Bcc.Add("marketplace.it@advantech.com")

        msg.SubjectEncoding = Text.Encoding.UTF8 : msg.BodyEncoding = Text.Encoding.UTF8
        msg.Subject = String.Format("WISE Point Order ({0}) for {1} {2}({3}){4}", RedeemSONO, dtCust.Rows(0).Item("name1"), dtCust.Rows(0).Item("name2"), dtCust.Rows(0).Item("kunnr"), IIf(IsToSAPPRD, "", " (TEST)"))
        Dim smtpServer As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        If Not IsToSAPPRD Then msg.To.Clear()
        smtpServer.Send(msg)
        smtpServer.Dispose()
        Return True
    End Function

    Public Function RejectSO(ByVal SONO As String, RejectReason As RejectSO_Reason, ByRef UpdateSOResult As String) As Boolean
        SONO = Trim(UCase(SONO))
        Dim SAPConnName = IIf(IsToSAPPRD, "SAP_PRD", "SAP_Test")
        Dim SAPRFCConnName As String = IIf(IsToSAPPRD, "SAP_PRD", "SAPConnTest")
        If Not SONO.StartsWith("WISE") Then
            UpdateSOResult = "Invalid SO No., should start with WISE" : Return False
        End If
        Dim vbakDt = OraDbUtil.dbGetDataTable(SAPConnName, "select ernam from saprdp.vbak where vbeln='" + Global_Inc.SONoBuildSAPFormat(SONO) + "'")
        If vbakDt.Rows.Count = 0 Then
            UpdateSOResult = "SO doesn't exist" : Return False
        End If
        If vbakDt.Rows(0).Item(0).ToString() <> "B2BAEU" And vbakDt.Rows(0).Item(0).ToString() <> "TC.CHEN" Then
            UpdateSOResult = "Not an SO created via MyAdvantech" : Return False
        End If
        Dim ReasonCodeStr As String = IIf(CInt(RejectReason) < 10, "0" + CInt(RejectReason).ToString(), RejectReason.ToString())
        If CInt(OraDbUtil.dbExecuteScalar(SAPConnName, "select count(*) from saprdp.lips a where a.vgbel='" + Global_Inc.SONoBuildSAPFormat(SONO) + "'")) > 0 Then
            UpdateSOResult = "DN has been created thus cannot be rejected" : Return False
        End If

        Dim vbapDt = OraDbUtil.dbGetDataTable(SAPConnName, "select posnr from saprdp.vbap where vbeln='" + SONO + "'")

        Dim p1 As New BAPI_SALESORDER_CHANGE.BAPI_SALESORDER_CHANGE()
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings(SAPRFCConnName))
        Dim OrderHeader As New BAPI_SALESORDER_CHANGE.BAPISDH1, OrderHeaderX As New BAPI_SALESORDER_CHANGE.BAPISDH1X, ItemIn As New BAPI_SALESORDER_CHANGE.BAPISDITMTable,
        ItemInX As New BAPI_SALESORDER_CHANGE.BAPISDITMXTable, PartNr As New BAPI_SALESORDER_CHANGE.BAPIPARNRTable, Condition As New BAPI_SALESORDER_CHANGE.BAPICONDTable,
        ConditionX As New BAPI_SALESORDER_CHANGE.BAPICONDXTable, ScheLine As New BAPI_SALESORDER_CHANGE.BAPISCHDLTable, ScheLineX As New BAPI_SALESORDER_CHANGE.BAPISCHDLXTable,
        OrderText As New BAPI_SALESORDER_CHANGE.BAPISDTEXTTable, sales_note As New BAPI_SALESORDER_CHANGE.BAPISDTEXT, ext_note As New BAPI_SALESORDER_CHANGE.BAPISDTEXT,
        op_note As New BAPI_SALESORDER_CHANGE.BAPISDTEXT, retTable As New BAPI_SALESORDER_CHANGE.BAPIRET2Table, ADDRTable As New BAPI_SALESORDER_CHANGE.BAPIADDR1Table,
        PartnerChangeTable As New BAPI_SALESORDER_CHANGE.BAPIPARNRCTable
        'Dim Doc_Number As String = "0007018108"
        OrderHeaderX.Updateflag = "U"
        For Each vbupRow As DataRow In vbapDt.Rows
            Dim ItemInRow As New BAPI_SALESORDER_CHANGE.BAPISDITM, ItemInRowX As New BAPI_SALESORDER_CHANGE.BAPISDITMX
            With ItemInRow
                .Itm_Number = vbupRow.Item("posnr").ToString() : .Reason_Rej = ReasonCodeStr
            End With
            With ItemInRowX
                .Itm_Number = vbupRow.Item("posnr").ToString() : .Updateflag = "U" : .Reason_Rej = "X"
            End With
            ItemIn.Add(ItemInRow) : ItemInX.Add(ItemInRowX)
        Next

        p1.Connection.Open()

        'p1.Bapi_Salesorder_Change("","",New BAPI_SALESORDER_CHANGE.BAPISDLS, "",
        p1.Bapi_Salesorder_Change("", "", New BAPI_SALESORDER_CHANGE.BAPISDLS, "", OrderHeader, OrderHeaderX, SONO, "", Condition,
                              ConditionX, New BAPI_SALESORDER_CHANGE.BAPIPAREXTable, New BAPI_SALESORDER_CHANGE.BAPICUBLBTable,
                              New BAPI_SALESORDER_CHANGE.BAPICUINSTable, New BAPI_SALESORDER_CHANGE.BAPICUPRTTable, New BAPI_SALESORDER_CHANGE.BAPICUCFGTable,
                              New BAPI_SALESORDER_CHANGE.BAPICUREFTable, New BAPI_SALESORDER_CHANGE.BAPICUVALTable, New BAPI_SALESORDER_CHANGE.BAPICUVKTable, ItemIn,
                              ItemInX, New BAPI_SALESORDER_CHANGE.BAPISDKEYTable, OrderText, ADDRTable,
                              PartnerChangeTable, PartNr, retTable, ScheLine, ScheLineX)
        p1.CommitWork()

        For Each retRow As BAPI_SALESORDER_CHANGE.BAPIRET2 In retTable
            If retRow.Type = "E" Then UpdateSOResult += retRow.Message + ";"
        Next

        If Not String.IsNullOrEmpty(UpdateSOResult) Then Return False

        Return True

    End Function

    'select * from saprdp.tvagt where mandt='168' and spras='E' order by abgru
    Public Enum RejectSO_Reason As Integer
        Delivery_date_too_late = 1
        Poor_quality = 2
        Price_issue_cause_the_order_cancel = 3
        Competitor_better = 4
        PN_change_for_RohsNon_Rohs = 6
        Change_delivery_plant = 7
        MOQ_limitation_refuese_to_accept_order = 8
        Spec_uncompatible = 9
        GP_blocked_and_rekey_in_to_new_line = 10
        Change_to_alternative_PN = 11
        Typing_error_and_system_error = 12
        Per_customer_request = 13
        Item_phased_out_wo_supply = 14
        Buffer_Order_Completion = 15
    End Enum


    <Obsolete()>
    Function SendWisePortalPIEmail_Obsolete(ContactEmail As String, WisePN As String, SONO As String) As Boolean
        Dim sqlSOSalesEmail As String =
            " select distinct b.usrid_long as email  " +
            " from saprdp.vbpa a inner join saprdp.pa0105 b on a.pernr=b.pernr " +
            " where a.vbeln='" + Global_Inc.SONoBuildSAPFormat(SONO) + "' and a.pernr<>'00000000' and b.subty in ('0010','MAIL') and b.usrid_long like '%@%.%' "
        Dim SAPApt As New Oracle.DataAccess.Client.OracleDataAdapter(sqlSOSalesEmail, ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
        Dim dtSOEmails As New DataTable, dtCust As New DataTable, dtSODetail As New DataTable
        SAPApt.Fill(dtSOEmails)

        SAPApt.SelectCommand.CommandText =
            " select a.name1, a.name2, a.kunnr " +
            " from saprdp.kna1 a inner join saprdp.vbak b on a.kunnr=b.kunnr " +
            " where a.mandt='168' and b.vbeln='" + Global_Inc.SONoBuildSAPFormat(SONO) + "'"
        SAPApt.Fill(dtCust)

        SAPApt.SelectCommand.CommandText =
            " select a.posnr as line_no, a.matnr as part_no, a.arktx as product_desc,  " +
            " b.mtart as material_type, a.kwmeng as order_qty, a.waerk as currency, a.netpr as unit_price " +
            " from saprdp.vbap a inner join saprdp.mara b on a.matnr=b.matnr " +
            " where a.mandt='168' and a.vbeln='" + Global_Inc.SONoBuildSAPFormat(SONO) + "' " +
            " order by a.posnr "
        SAPApt.Fill(dtSODetail)

        For Each OrderRow As DataRow In dtSODetail.Rows
            Select Case OrderRow.Item("currency")
                Case "TWD"
                    OrderRow.Item("unit_price") = Math.Pow(10, 2 - 0) * CDbl(OrderRow.Item("unit_price"))
            End Select
            OrderRow.Item("line_no") = Global_Inc.RemoveZeroString(OrderRow.Item("line_no"))
            OrderRow.Item("part_no") = Global_Inc.RemoveZeroString(OrderRow.Item("part_no"))
        Next

        SAPApt.SelectCommand.Connection.Close()
        If dtCust.Rows.Count = 0 Or dtSODetail.Rows.Count = 0 Then Return False

        Dim sbMailBody As New System.Text.StringBuilder

        With sbMailBody
            .AppendFormat("Dear Sales/OP,<br/><br/>")
            .Append(String.Format("Customer {0} just used wise point to convert to product: {1}, SO No.: {2}.<br/>", ContactEmail, WisePN, SONO))
            .Append("Following is the order detail:<br/>")
            .Append("<table border='1' style='width:100%'>")
            .Append("<tr><th>Line No.</th><th>Part No.</th><th>Desc.</th><th>material type</th><th>qty.</th><th>unit price</th></tr>")
            For Each OrderRow As DataRow In dtSODetail.Rows
                .AppendFormat("<tr><td align='center'>{0}</td><td>{1}</td><td>{2}</td><td align='center'>{3}</td><td align='center'>{4}</td><td align='right'>{5}{6}</td></tr>",
                              OrderRow.Item("line_no"), OrderRow.Item("part_no"), OrderRow.Item("product_desc"), OrderRow.Item("material_type"),
                              OrderRow.Item("order_qty"), OrderRow.Item("currency"), OrderRow.Item("unit_price"))
            Next
            .Append("</table>")
            .Append("<br/>Thank you.<br/>")
            .Append("<a href='mailto:myadvantech@advantech.com'>MyAdvantech IT Team</a>")
        End With

        Dim msg As New System.Net.Mail.MailMessage()
        msg.IsBodyHtml = True
        msg.Body = sbMailBody.ToString()
        msg.From = New Net.Mail.MailAddress("MyAdvantech@advantech.com")

        If dtSOEmails.Rows.Count > 0 Then
            For Each EmailRow As DataRow In dtSOEmails.Rows
                msg.To.Add(EmailRow.Item("email"))
                If Not IsToSAPPRD Then msg.Body = EmailRow.Item("email") + "<br/>" + msg.Body
            Next
        Else
            msg.To.Add("tc.chen@advantech.com.tw")
        End If

        If IsToSAPPRD Then msg.CC.Add("wa.marketplace.acl@advantech.com")

        msg.Bcc.Add("tc.chen@advantech.com.tw")
        msg.Bcc.Add("Frank.Chung@advantech.com.tw")
        msg.Bcc.Add("yl.huang@advantech.com.tw")
        msg.Bcc.Add("marketplace.it@advantech.com")

        msg.SubjectEncoding = Text.Encoding.UTF8 : msg.BodyEncoding = Text.Encoding.UTF8
        msg.Subject = String.Format("WISE Point Order ({0}) for {1} {2}({3}){4}", SONO, dtCust.Rows(0).Item("name1"), dtCust.Rows(0).Item("name2"), dtCust.Rows(0).Item("kunnr"), IIf(IsToSAPPRD, "", " (TEST)"))
        Dim smtpServer As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        If Not IsToSAPPRD Then msg.To.Clear()
        smtpServer.Send(msg)
        smtpServer.Dispose()
        Return True
    End Function

    Sub LogWisePointRedeemRequest(
                                MembershipEmail As String, WisePointSONO As String, WISEPointItem As String,
                                WISE_PartNo As String, Qty As Integer, Amount As Decimal, AssetId As String,
                                ReturnResult1 As ReturnResult)
        Dim WiseRec1 As New WISE_PORTAL_REDEEM_RECORD_V2(MembershipEmail + "," + WisePointSONO, WISEPointItem, WISE_PartNo, Qty, Amount, AssetId, ReturnResult1)
        Dim WiseRecords As New List(Of WISE_PORTAL_REDEEM_RECORD_V2)
        WiseRecords.Add(WiseRec1)
        Dim dtWiseRec As DataTable = Util.ListToDataTable(Of WISE_PORTAL_REDEEM_RECORD_V2)(WiseRecords)
        Dim bk As New SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("MyLocal").ConnectionString)
        bk.DestinationTableName = "WISE_PORTAL_REDEEM_RECORD_V2"
        bk.WriteToServer(dtWiseRec)
        bk.Close()
    End Sub

    Function UnblockSOGP(SONO As String) As Boolean
        Dim sqlSOGPBlockLines As String =
            " select POSNR, LSSTA from saprdp.vbup where LSSTA='C' and vbeln='" + Global_Inc.SONoBuildSAPFormat(SONO) + "' "
        Dim SAPGPApt As New Oracle.DataAccess.Client.OracleDataAdapter(sqlSOGPBlockLines, ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)
        Dim dtSOGPLines As New DataTable
        SAPGPApt.Fill(dtSOGPLines)
        SAPGPApt.SelectCommand.Connection.Close()
        If dtSOGPLines.Rows.Count > 0 Then
            Dim pro1 As New Z_RELEASE_GP_ITEM.Z_RELEASE_GP_ITEM(ConfigurationManager.AppSettings("SAP_PRD"))
            pro1.Connection.Open()
            For Each GPLineRow As DataRow In dtSOGPLines.Rows
                pro1.Z_Release_Gp_Item(GPLineRow.Item("POSNR"), SONO, "", 0)
            Next
            pro1.Connection.Close()
        End If
        Return True
    End Function

    <Serializable()>
    Public Class ReturnResult
        Public Property IsSuccess As Boolean : Public Property ErrorMessage As String
        Public Property ERPID As String : Public Property OrgId As String : Public Property SONO As String : Public Property InventoryMatDoc As String
        Public Sub New()
            Me.IsSuccess = False : Me.ErrorMessage = ""
        End Sub
    End Class

    Public Class WisePoint2OrderException
        Inherits Exception
        Public ErrorMessage As String
        Public Sub New(ErrorMessage As String)
            Me.ErrorMessage = ErrorMessage
        End Sub
    End Class

    Public Class WISEPoint2OrderEnSaaSInput
        Public Property AssetId As String : Public Property WisePointOrderSONO As String
        Public Property RedeemItemList As List(Of RedeemItemPointQty)
        Public Sub New()
            AssetId = "" : WisePointOrderSONO = "" : RedeemItemList = New List(Of RedeemItemPointQty)
        End Sub
    End Class

    Public Class RedeemItemPointQty
        Public Property Qty As Integer : Public Property RedeemPartNo As String : Public Property RedeemPoints As Double
    End Class


    Public Class WISEPoint2OrderV2Input
        Public Property MembershipEmail As String : Public Property Qty As Integer : Public Property RedeemPartNo As String
        Public Property RedeemPoints As Integer : Public Property AssetId As String
        Public Property WisePointOrderSONO As String
        Public Sub New()
            MembershipEmail = "" : WisePointOrderSONO = ""
        End Sub
    End Class

    Public Class WISE_PORTAL_REDEEM_RECORD_V2
        Public Property ROW_ID As Integer : Public Property CONTACT_EMAIL As String : Public Property WISEPointItem As String
        Public Property WisePN As String : Public Property Qty As Integer : Public Property Amount As Decimal
        Public Property AssetId As String : Public Property Redeem_Date As DateTime : Public Property IsSuccess As Boolean
        Public Property ErrorMessage As String : Public Property ERPID As String : Public Property OrgId As String
        Public Property SONO As String : Public Property InventoryMatDoc As String : Public Property LastProcDate As DateTime
        Public Property LastProcBy As String : Public Property WSClientIP As String
        Public Sub New(MembershipEmail As String, WISEPointItem As String,
                                 WISE_PartNo As String, Qty As Integer, Amount As Decimal, AssetId As String,
                                 ReturnResult1 As ReturnResult)
            Dim jsr As New Script.Serialization.JavaScriptSerializer()
            Me.CONTACT_EMAIL = MembershipEmail : Me.WISEPointItem = WISEPointItem : Me.WisePN = WISE_PartNo
            Me.Qty = Qty : Me.Amount = Amount : Me.AssetId = AssetId : Me.Redeem_Date = Now
            With ReturnResult1
                Me.IsSuccess = .IsSuccess : Me.ErrorMessage = .ErrorMessage : Me.ERPID = .ERPID
                Me.OrgId = .OrgId : Me.SONO = .SONO : Me.InventoryMatDoc = .InventoryMatDoc
                Me.LastProcDate = Me.Redeem_Date
            End With
            Me.WSClientIP = Util.GetClientIP()
            'Me.WISEPointItems = ""
        End Sub
    End Class

    Function RejectSO(SONO As String) As String
        'reject every line item of an SO - VBAP-ABGRU=13 
        'Then call Zbapi_Goodsmvt_Create with movement type 914
    End Function
End Class
