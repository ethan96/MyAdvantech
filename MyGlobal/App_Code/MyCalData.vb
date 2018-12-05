Imports Microsoft.VisualBasic

Public Class MyCalData

    Public Shared Function GetRMA(ByVal company_id As String, ByVal rmano As String, _
                                  ByVal FromOrderDate As Date, ByVal ToOrderDate As Date, _
                                  ByVal partno As String, ByVal sn As String, Optional ByVal top As Integer = 1000) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select top {0} replace(dbo.DateOnly(a.LAST_UPD_DATE),'-','/') as LAST_UPD_DATE, a.Order_NO+'-'+Cast(a.Item_No as varchar(4)) as RMA_NO, IsNull(a.Repair_Status,'') as Repair_Status,  ", top.ToString()))
            .AppendLine(String.Format(" replace(dbo.DateOnly(a.Order_Dt),'-','/') as Order_Date, IsNull(b.model_no,'') as model_no, "))
            .AppendLine(String.Format(" a.Product_Name, IsNull(a.rma_type,'') as RMA_TYPE, a.Barcode as Serial_Number, IsNull(a.Now_Stage,'Others') as Stage "))
            .AppendLine(String.Format(" from RMA_My_Request_OrderList a left join sap_product b on a.product_name=b.part_no "))
            .AppendLine(String.Format(" where a.Bill_ID='{0}' and (a.Order_Dt between '{1}' and '{2}' or a.LAST_UPD_DATE between '{1}' and '{2}' ) ", company_id, FromOrderDate.ToString("yyyy-MM-dd"), ToOrderDate.ToString("yyyy-MM-dd")))
            If rmano <> "" Then .AppendLine(String.Format(" a.Order_NO+'-'+Cast(a.Item_No as varchar(4)) like '%{0}%' ", rmano.Trim.Replace("'", "''").Replace("*", "%")))
            If partno <> "" Then .AppendLine(String.Format(" and a.Product_Name like '%{0}%' ", partno.Trim.Replace("'", "''").Replace("*", "%")))
            If sn <> "" Then .AppendLine(String.Format(" a.Barcode like '%{0}%' ", sn.Trim.Replace("'", "''").Replace("*", "%")))
            .AppendLine(" order by a.Order_Dt desc ")
        End With
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function

    Public Shared Function GetSR(ByVal company_id As String, ByVal srno As String, _
                                  ByVal FromOrderDate As Date, ByVal ToOrderDate As Date, _
                                  ByVal partno As String, ByVal userid As String, Optional ByVal top As Integer = 100) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT top {0}  ", top.ToString()))
            .AppendLine(String.Format(" IsNull((select count(c.row_id) from siebel_sr_solution c where c.sr_id=a.row_id),0) as Solutions, "))
            .AppendLine(String.Format(" a.ROW_ID, a.CREATED, a.SR_NUM, IsNull(a.SR_TITLE,'') as SR_TITLE, ISNULL(a.MODEL_NO, N'') AS MODEL_NO, a.LAST_UPD,  "))
            .AppendLine(String.Format(" ISNULL(a.ACT_CLOSE_DT, GETDATE()+ 365) AS Close_Date, a.DESC_TEXT, a.SR_TYPE, a.KBase, a.CATEGORY,  "))
            .AppendLine(String.Format(" a.SFUNCTION, a.HW_REVISION, a.SW_VERSION, a.PUBLISH_SCOPE,  "))
            .AppendLine(String.Format(" a.ABSTRACT, a.SR_DESCRIPTION, ISNULL(a.EMAIL, N'') AS AE_Email,  "))
            .AppendLine(String.Format(" ISNULL((SELECT top 1 EMAIL_ADDRESS FROM SIEBEL_CONTACT AS c WHERE (ROW_ID = a.CONTACT_ID)), N'') AS contact_email,  "))
            .AppendLine(String.Format(" a.SR_STAT_ID, a.SR_SUB_STAT_ID, a.SR_SUBTYPE_CD "))
            .AppendLine(String.Format(" FROM SIEBEL_SR AS a inner JOIN SIEBEL_ACCOUNT AS b ON a.ACCOUNT_ROW_ID = b.ROW_ID "))
            If company_id <> "" Then .AppendLine(String.Format(" WHERE b.ERP_ID<>'' and b.ERP_ID='{0}' ", company_id))
            .AppendLine(String.Format(" and a.CREATED between '{0}' and '{1}' ", FromOrderDate.ToString("yyyy-MM-dd"), ToOrderDate.ToString("yyyy-MM-dd")))
            If partno.Trim <> "" Then .AppendLine(String.Format(" and a.model_no like '%{0}%' ", partno.Trim.Replace("'", "''").Replace("*", "%")))
            If srno.Trim() <> "" Then .AppendLine(String.Format(" and a.SR_NUM='{0}' ", srno.Trim.Replace("'", "''")))
            'If LCase(userid) Like "*@advantech*" = False Then .AppendLine(" and a.publish_scope='EXTERNAL' ")
            .AppendLine(String.Format(" ORDER BY a.CREATED DESC "))
        End With
        'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "MYSR sql", sb.ToString(), False, "", "")
        Return dbUtil.dbGetDataTable("RFM", sb.ToString())
    End Function

    Public Shared Function GetMKTMaterial(ByVal FromOrderDate As Date, ByVal ToOrderDate As Date, _
                                          ByVal modelno As String, ByVal userid As String, _
                                          Optional ByVal top As Integer = 100) As DataTable
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT top {0} a.LIT_ID, a.LIT_NAME, a.PART_NO, a.PROD_ID, a.CREATED, a.LAST_UPD,  ", top.ToString()))
            .AppendLine(String.Format(" IsNull(a.DESC_TEXT,'') as DESC_TEXT, IsNull(a.FILE_NAME,'') as FILE_NAME, IsNull(a.FILE_EXT,'') as FILE_EXT, IsNull(a.FILE_SIZE,0) as FILE_SIZE, a.PHOTO, b.MODEL_NO "))
            .AppendLine(String.Format(" FROM SIEBEL_LITERATURE AS a INNER JOIN SIEBEL_PRODUCT AS b ON a.PROD_ID = b.PRODUCT_ID "))
            .AppendLine(String.Format(" WHERE a.PROD_ID <> '' and (b.model_no like '%{0}%' or a.part_no like '%{0}%' or a.FILE_NAME like '%{0}%') ", modelno.Replace("'", "''").Trim().Replace("*", "%")))
            .AppendLine(String.Format(" and a.CREATED between '{0}' and '{1}' ", FromOrderDate.ToString("yyyy-MM-dd"), ToOrderDate.ToString("yyyy-MM-dd")))
            .AppendLine(String.Format(" ORDER BY a.CREATED DESC "))
        End With
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function

    Public Shared Function GetBackOrderC( _
    ByVal kunnr As String, ByVal vkorg As String, ByVal FromDate As String, _
    ByVal ToDate As String, ByVal matnr As String, ByVal vbeln As String, ByVal bstnk As String) As DataTable
        Try
            Dim sb As New System.Text.StringBuilder
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
                .AppendFormat(" (VBAK.VKORG = '{0}') AND (VBAK.KUNNR='{1}') AND ", UCase(vkorg).Trim(), UCase(kunnr).Trim())
                .AppendFormat(" (VBEP.EDATU between '{0}' and '{1}') and VBUP.LFSTA ='C' ", FromDate, ToDate)
                If matnr <> "" Then .AppendFormat(" and VBAP.MATNR like '%{0}%' ", matnr)
                If vbeln <> "" Then .AppendFormat(" and VBAK.VBELN like '%{0}%' ", vbeln)
                If bstnk <> "" Then .AppendFormat(" and VBAK.BSTNK like '%{0}%' ", bstnk)
                .AppendFormat(" and VBAP.ABGRU = ' ' ")
                .AppendFormat(" ORDER BY ORDERLINE asc, DUEDATE desc")
            End With

            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
            For Each r As DataRow In dt.Rows
                If CInt(r.Item("DLV_QTY")) > 0 Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()

            Dim BRs() As DataRow = dt.Select("ORDERLINE >= 100", "OrderNo asc, ORDERLINE desc")
            If BRs.Length > 0 Then
                Dim btoUnitSum As Double = 0, btoAllSum As Double = 0, btoOrderLine As Integer = 0
                For Each sch As DataRow In BRs
                    If CInt(sch.Item("ORDERLINE")) <> btoOrderLine Then
                        btoOrderLine = CInt(sch.Item("ORDERLINE"))
                        If CInt(sch.Item("ORDERLINE")) > 100 Then
                            btoUnitSum += sch.Item("UNITPRICE") : btoAllSum += sch.Item("TOTALPRICE")
                            sch.Delete()
                        Else
                            sch.Item("UNITPRICE") = btoUnitSum : sch.Item("TOTALPRICE") = btoAllSum
                            btoUnitSum = 0 : btoAllSum = 0
                        End If
                    Else
                        sch.Delete()
                    End If
                Next
            End If
            dt.AcceptChanges()
            Return dt
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Public Shared Function GetBOABRealtime( _
    ByVal kunnr As String, ByVal vkorg As String, ByVal FromDate As String, _
    ByVal ToDate As String, ByVal matnr As String, ByVal vbeln As String, ByVal bstnk As String) As DataTable
        Try
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
                .AppendFormat(" (VBAK.VKORG = '{0}') AND (VBAK.KUNNR='{1}') AND ", UCase(vkorg).Trim(), UCase(kunnr).Trim())
                .AppendFormat(" (VBEP.EDATU between '{0}' and '{1}') and VBUP.LFSTA IN ('A','B') ", FromDate, ToDate)
                If matnr <> "" Then .AppendFormat(" and VBAP.MATNR like '%{0}%' ", matnr)
                If vbeln <> "" Then .AppendFormat(" and VBAK.VBELN like '%{0}%' ", vbeln)
                If bstnk <> "" Then .AppendFormat(" and VBAK.BSTNK like '%{0}%' ", bstnk)
                .AppendFormat(" and VBAP.ABGRU = ' ' ")
                .AppendFormat(" ORDER BY ORDERLINE asc, DUEDATE desc")
            End With

            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
            'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "", sb.ToString(), False, "", "")
            Dim BRs() As DataRow = dt.Select("DOC_STATUS='B'", "OrderNo ASC, ORDERLINE ASC, DUEDATE ASC")

            If BRs.Length > 1 Then
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
            BRs = dt.Select("DOC_STATUS='A' and SchedLineShipedQty=0 and SchdLineNo>1 and SchdLineOpenQty=0")
            For Each sch As DataRow In BRs
                sch.Delete()
            Next
            dt.AcceptChanges()

            BRs = dt.Select("ORDERLINE >= 100", "OrderNo asc, ORDERLINE desc")
            If BRs.Length > 0 Then
                Dim btoUnitSum As Double = 0, btoAllSum As Double = 0, btoOrderLine As Integer = 0
                For Each sch As DataRow In BRs
                    If CInt(sch.Item("ORDERLINE")) <> btoOrderLine Then
                        btoOrderLine = CInt(sch.Item("ORDERLINE"))
                        If CInt(sch.Item("ORDERLINE")) > 100 Then
                            btoUnitSum += sch.Item("UNITPRICE") : btoAllSum += sch.Item("TOTALPRICE")
                            sch.Delete()
                        Else
                            sch.Item("UNITPRICE") = btoUnitSum : sch.Item("TOTALPRICE") = btoAllSum
                            btoUnitSum = 0 : btoAllSum = 0
                        End If
                    Else
                        sch.Delete()
                    End If
                Next
            End If
            dt.AcceptChanges()
            Return dt
        Catch ex As Exception
            Return Nothing
        End Try
    End Function

    Public Shared Function GetBOAB( _
    ByVal kunnr As String, ByVal vkorg As String, ByVal FromDate As String, _
    ByVal ToDate As String, ByVal matnr As String, ByVal vbeln As String, ByVal bstnk As String) As DataTable
        Try
            Dim sb As New System.Text.StringBuilder
            With sb
                .AppendLine(String.Format(" SELECT ORDERNO, PONO, BILLTOID, SHIPTOID, ORDERDATE, CURRENCY, ORDERLINE, PRODUCTID, SCHDLINECONFIRMQTY, SCHDLINEOPENQTY,  "))
                .AppendLine(String.Format(" UNITPRICE, TOTALPRICE, DOC_STATUS, DUEDATE, ORIGINALDD, EXWARRANTY, SCHEDLINESHIPEDQTY, SCHDLINENO, DLV_QTY "))
                .AppendLine(String.Format(" FROM SAP_BACKORDER_AB "))
                .AppendFormat(" where BILLTOID='{0}' and ", UCase(kunnr).Trim())
                .AppendFormat(" (DUEDATE between '{0}' and '{1}') ", FromDate, ToDate)
                If matnr <> "" Then .AppendFormat(" and PRODUCTID like '%{0}%' ", matnr)
                If vbeln <> "" Then .AppendFormat(" and ORDERNO like '%{0}%' ", vbeln)
                If bstnk <> "" Then .AppendFormat(" and PONO like '%{0}%' ", bstnk)
                .AppendFormat(" ORDER BY ORDERLINE asc, DUEDATE desc")
            End With
            Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", sb.ToString())
            'Util.SendEmail("nada.liu@advantech.com.cn", "ebiz.aeu@advantech.eu", "", sb.ToString(), False, "", "")
            Dim BRs() As DataRow = dt.Select("DOC_STATUS='B'", "OrderNo ASC, ORDERLINE ASC, DUEDATE ASC")

            If BRs.Length > 1 Then
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
            BRs = dt.Select("DOC_STATUS='A' and SchedLineShipedQty=0 and SchdLineNo>1 and SchdLineOpenQty=0")
            For Each sch As DataRow In BRs
                sch.Delete()
            Next
            dt.AcceptChanges()
            If vkorg <> "US01" Then
                BRs = dt.Select("ORDERLINE >= 100", "OrderNo asc, ORDERLINE desc")
                If BRs.Length > 0 Then
                    Dim btoUnitSum As Double = 0, btoAllSum As Double = 0, btoOrderLine As Integer = 0
                    For Each sch As DataRow In BRs
                        If CInt(sch.Item("ORDERLINE")) <> btoOrderLine Then
                            btoOrderLine = CInt(sch.Item("ORDERLINE"))
                            If CInt(sch.Item("ORDERLINE")) > 100 Then
                                btoUnitSum += sch.Item("UNITPRICE") : btoAllSum += sch.Item("TOTALPRICE")
                                sch.Delete()
                            Else
                                sch.Item("UNITPRICE") = btoUnitSum : sch.Item("TOTALPRICE") = btoAllSum
                                btoUnitSum = 0 : btoAllSum = 0
                            End If
                        Else
                            sch.Delete()
                        End If
                    Next
                End If
            End If
            dt.AcceptChanges()
            Return dt
        Catch ex As Exception
            Return Nothing
        End Try
     
    End Function
End Class
