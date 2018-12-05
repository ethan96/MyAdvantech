Imports Microsoft.VisualBasic
Public Class Glob
    Public Shared Function ToDataTable(ByVal l As IList) As DataTable
        Dim result As DataTable = New DataTable
        If l.Count > 0 Then
            Dim po As System.Reflection.PropertyInfo() = l(0).GetType.GetProperties()
            For Each pi As System.Reflection.PropertyInfo In po
                result.Columns.Add(pi.Name, pi.PropertyType)
            Next
            For i As Integer = 0 To l.Count - 1
                Dim tl As New ArrayList
                For Each pi As System.Reflection.PropertyInfo In po
                    Dim o As Object = pi.GetValue(l(i), Nothing)
                    tl.Add(o)
                Next
                Dim arr As Object() = tl.ToArray
                result.LoadDataRow(arr, True)
            Next
        End If
        Return result
    End Function
    Public Shared Function GetTaxableAmount(ByVal orderId As String, ByVal ShiptoId As String) As Decimal
        Dim odDA As New MyOrderDSTableAdapters.ORDER_DETAILTableAdapter
        Dim DT As New MyOrderDS.ORDER_DETAILDataTable
        DT = odDA.GetOrderDetailByOrderID(orderId)
        Dim amount As Decimal = 0
        For Each r As MyOrderDS.ORDER_DETAILRow In DT.Rows
            If SAPDAL.SAPDAL.isTaxable(r.PART_NO, ShiptoId) Then
                amount += r.UNIT_PRICE * r.QTY
            End If
        Next
        Return amount
    End Function
    Public Shared Function IsPTD(ByVal PartNo As String) As Boolean
        Dim f As Boolean = False
        Dim STR As String = String.Format("select count(*) from SAP_PRODUCT where " & _
                                            " ((PRODUCT_TYPE = 'ZPER') " & _
                                            " OR " & _
                                            " ((PRODUCT_TYPE = 'ZFIN' OR PRODUCT_TYPE = 'ZOEM') AND (PART_NO LIKE 'BT%' OR PART_NO LIKE 'DSD%' OR PART_NO LIKE 'ES%' OR PART_NO LIKE 'EWM%' OR PART_NO LIKE 'GPS%' OR PART_NO LIKE 'SQF%' OR PART_NO LIKE 'WIFI%' OR PART_NO LIKE 'PMM%' OR PART_NO LIKE 'Y%')) " & _
                                            " OR " & _
                                            " ((PRODUCT_TYPE = 'ZRAW') AND (PART_NO LIKE '206Q%')) " & _
                                            " OR " & _
                                            " ((PRODUCT_TYPE = 'ZSEM') AND (PART_NO LIKE '968Q%'))) AND PART_NO = '{0}'", PartNo)
        Dim o As New Object
        o = dbUtil.dbExecuteScalar("B2B", STR)
        If CInt(o) > 0 Then
            f = True
        End If
        Return f
    End Function
    Shared Function getBTOWorkingDate() As Integer
        If HttpContext.Current.Session("org_id") IsNot Nothing Then
            If HttpContext.Current.Session("org_id").ToString.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                If MyUtil.Current.CurrentLocalTime.Hour > 13 Then
                    Return Integer.Parse(ConfigurationManager.AppSettings("USBTOSWorkingDay")) + 1
                End If
                Return Integer.Parse(ConfigurationManager.AppSettings("USBTOSWorkingDay"))
            End If
            If HttpContext.Current.Session("org_id").ToString.Equals("TW01", StringComparison.OrdinalIgnoreCase) Then
                Return Integer.Parse(ConfigurationManager.AppSettings("TWBTOSWorkingDay"))
            End If
            If HttpContext.Current.Session("org_id").ToString.StartsWith("CN", StringComparison.OrdinalIgnoreCase) Then
                Return Integer.Parse(ConfigurationManager.AppSettings("CNBTOSWorkingDay"))
            End If
        End If
        Return Integer.Parse(ConfigurationManager.AppSettings("BTOSWorkingDay"))
    End Function
    Shared Function getListPrice(ByVal partno As String, ByVal org As String, ByVal CURR As String) As Decimal
        Dim ListPrice As Decimal = -1, objLp As Object = Nothing
        Dim cmd As New SqlClient.SqlCommand( _
            "select TOP 1 LIST_PRICE from PRODUCT_LIST_PRICE where ORG=@ORG and CURRENCY=@CUR and PART_NO = @PN and LIST_PRICE>=0 order by LIST_PRICE desc", _
            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString))
        cmd.Parameters.AddWithValue("ORG", org) : cmd.Parameters.AddWithValue("CUR", CURR) : cmd.Parameters.AddWithValue("PN", partno)
        cmd.Connection.Open()
        objLp = cmd.ExecuteScalar()
        cmd.Connection.Close()
        If objLp IsNot Nothing Then
            Return DirectCast(objLp, Decimal)
        Else
            If org = "US01" Then
                Dim LpDt As DataTable = Nothing
                SAPtools.getSAPPriceByTable(partno, 1, org, "UEPP5001", CURR, LpDt)
                If LpDt IsNot Nothing AndAlso LpDt.Rows.Count > 0 Then
                    Return LpDt.Rows(0).Item("Kzwi1")
                End If
            End If
        End If
        Return -1
    End Function
    Shared Function getNextCustDelDate(ByVal ddate As String) As String
        Dim sql As New StringBuilder
        sql.AppendLine("select rtrim(MOAB1)+rtrim(MOBI1)+rtrim(MOAB2)+rtrim(MOBI2)  as Monday,")
        sql.AppendLine("rtrim(DIAB1)+rtrim(DIBI1)+rtrim(DIAB2)+rtrim(DIBI2)  as Tuesday,")
        sql.AppendLine("rtrim(MIAB1)+rtrim(MIBI1)+rtrim(MIAB2)+rtrim(MIBI2)  as Wednesday,")
        sql.AppendLine("rtrim(DOAB1)+rtrim(DOBI1)+rtrim(DOAB2)+rtrim(DOBI2)  as Thursday,")
        sql.AppendLine("rtrim(FRAB1)+rtrim(FRBI1)+rtrim(FRAB2)+rtrim(FRBI2)  as Friday,")
        sql.AppendLine("rtrim(SAAB1)+rtrim(SABI1)+rtrim(SAAB2)+rtrim(SABI2)  as Saturday,")
        sql.AppendLine("rtrim(SOAB1)+rtrim(SOBI1)+rtrim(SOAB2)+rtrim(SOBI2)  as Sunday")
        sql.AppendLine("from SAP_COMPANY_CALENDAR")
        sql.AppendLine(String.Format("where KUNNR='{0}'", HttpContext.Current.Session("COMPANY_ID")))
        Dim Dt As New DataTable
        Dt = dbUtil.dbGetDataTable("B2B", sql.ToString)
        If Dt.Rows.Count > 0 Then
            Dim n As Integer = 0
            For i As Integer = 0 To 6
                If CDate(ddate).DayOfWeek = DayOfWeek.Sunday Then
                    n = (7 - 1 + i) Mod 7
                Else
                    n = (CInt(CDate(ddate).DayOfWeek) - 1 + i) Mod 7
                End If

                If Dt.Rows(0).Item(n).ToString.Trim("0").Trim <> "" Then
                    ddate = DateAdd(DateInterval.Day, i, CDate(ddate))
                    Return ddate
                End If
            Next
        End If
        Return ddate
    End Function


    Shared Function getOrgByCompanyId(ByVal company As String) As String
        Dim org As String = ""
        Dim myCompany As New SAP_Company("b2b", "sap_dimcompany")
        org = myCompany.GetDT(String.Format("company_id='{0}'", company), "").Rows(0).Item("org_id")
        Return org
    End Function
    Shared Function GetNoByPrefix(ByVal Prefix As String) As String
        Dim num As String = ""
        Try
            'Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
            'ws.Timeout = -1
            'num = ws.SO_GetNumber(Prefix.ToUpper)
            'num = ws.SO_GetNumber("QT")

            'ICC 2015/6/17 Due to 172.20.1.31 is unavailable, the web service can not be used. We change to SAPDAL function.
            num = SAPDAL.SAPDAL.SO_GetNumber(Prefix.ToUpper)
        Catch ex As Exception
            Return ""
        End Try
        Return num
    End Function
    Shared Function ShowInfo(ByVal Message As String) As Integer
        Dim P As System.Web.UI.Page = DirectCast(HttpContext.Current.Handler, System.Web.UI.Page)
        If Not IsNothing(P) And Not IsNothing(P.Master) Then
            Dim MP As Label = P.Master.FindControl("lbErroMessage")
            If Not IsNothing(MP) Then
                MP.Text = Message
            End If
        End If
        Return 1
    End Function
    Shared Function get_exchangerate(ByVal C_FROM As String, ByVal C_TO As String) As Decimal
        Dim temp As Object = Nothing
        temp = dbUtil.dbExecuteScalar("B2B", "select top 1 UKURS from SAP_EXCHANGERATE" & _
                                                 " where fCURR='" & C_FROM & "' and TCURR='" & C_TO & "' order by exch_date desc")
        If temp IsNot Nothing AndAlso IsNumeric(temp) Then
            Return temp
        End If
        Return 0
    End Function
    Shared Function FormatTel(ByVal str As String) As String
        If str.Trim = "" Then
            Return str
        End If
        Dim c As Char() = str.ToCharArray
        str = ""
        For i As Integer = 0 To c.Length - 1
            If IsNumeric(c(i)) Or c(i) = "+" Or c(i) = "#" Or c(i) = " " Then
                str &= c(i)
            Else
                Exit For
            End If
        Next
        Return str
    End Function
    Shared Function dataRow2HtmlRow(ByVal drc As DataRowCollection) As String
        Dim str As String = ""
        If Not IsNothing(drc) AndAlso drc.Count > 0 Then
            For Each r As DataRow In drc
                str &= "<tr>"
                For i As Integer = 0 To r.ItemArray.Length - 1
                    str &= "<td>" & r.Item(i) & "</td>"
                Next
                str &= "</tr>"
            Next
        End If
        Return str
    End Function
    Shared Function Get_Country_List() As ArrayList
        Dim CL As New ArrayList()
        Dim DT As DataTable = dbUtil.dbGetDataTable("eCampaign", String.Format("select distinct country from dbo.DM_IP2INFO order by country asc"))
        For Each r As DataRow In DT.Rows
            CL.Add(r.Item("Country"))
        Next
        Return CL
    End Function
    Shared Function Get_City_List(ByVal Country As String) As ArrayList
        Dim CL As New ArrayList()
        Dim DT As DataTable = dbUtil.dbGetDataTable("eCampaign", String.Format("select distinct city from dbo.DM_IP2INFO where country='{0}' order by city asc", Country))
        For Each r As DataRow In DT.Rows
            CL.Add(r.Item("City"))
        Next
        Return CL
    End Function
    Shared Function DateFormat(ByVal DATESTR As String, ByVal FF As String, ByVal TF As String, ByVal FSP As String, ByVal TSP As String) As String
        Dim Year As String = ""
        Dim Month As String = ""
        Dim Day As String = ""

        If FF.ToUpper = "YYYYMMDD" Then
            If FSP = "" Then
                Year = Left(DATESTR, 4)
                Month = Mid(DATESTR, 5, 2)
                Day = Right(DATESTR, 2)
            Else
                Year = DATESTR.Split(FSP)(0)
                Month = DATESTR.Split(FSP)(1)
                Day = DATESTR.Split(FSP)(2)
            End If
        End If
        If FF.ToUpper = "MMDDYYYY" Then
            If FSP = "" Then
                Year = Right(DATESTR, 4)
                Month = Left(DATESTR, 2)
                Day = Mid(DATESTR, 3, 2)
            Else
                Year = DATESTR.Split(FSP)(2)
                Month = DATESTR.Split(FSP)(0)
                Day = DATESTR.Split(FSP)(1)
            End If

        End If
        If FF.ToUpper = "DDMMYYYY" Then
            If FSP = "" Then
                Year = Right(DATESTR, 4)
                Month = Mid(DATESTR, 3, 2)
                Day = Left(DATESTR, 2)
            Else
                Year = DATESTR.Split(FSP)(2)
                Month = DATESTR.Split(FSP)(1)
                Day = DATESTR.Split(FSP)(0)
            End If
        End If
        If FF.ToUpper = "YYYYDDMM" Then
            If FSP = "" Then
                Year = Left(DATESTR, 4)
                Month = Right(DATESTR, 2)
                Day = Mid(DATESTR, 5, 2)
            Else
                Year = DATESTR.Split(FSP)(0)
                Month = DATESTR.Split(FSP)(2)
                Day = DATESTR.Split(FSP)(1)
            End If

        End If
        If FF.ToUpper = "MMYYYYDD" Then
            If FSP = "" Then
                Year = Mid(DATESTR, 3, 4)
                Month = Left(DATESTR, 2)
                Day = Right(DATESTR, 2)
            Else
                Year = DATESTR.Split(FSP)(1)
                Month = DATESTR.Split(FSP)(0)
                Day = DATESTR.Split(FSP)(2)
            End If
        End If
        If FF.ToUpper = "DDYYYYMM" Then
            If FSP = "" Then
                Year = Mid(DATESTR, 3, 4)
                Month = Right(DATESTR, 2)
                Day = Left(DATESTR, 2)
            Else
                Year = DATESTR.Split(FSP)(1)
                Month = DATESTR.Split(FSP)(2)
                Day = DATESTR.Split(FSP)(0)
            End If
        End If

        If TF.ToUpper = "YYYYMMDD" Then
            Return Year & TSP & Month & TSP & Day
        End If
        If TF.ToUpper = "MMDDYYYY" Then
            Return Month & TSP & Day & TSP & Year
        End If
        If TF.ToUpper = "DDMMYYYY" Then
            Return Day & TSP & Month & TSP & Year
        End If
        If TF.ToUpper = "YYYYDDMM" Then
            Return Year & TSP & Day & TSP & Month
        End If
        If TF.ToUpper = "MMYYYYDD" Then
            Return Month & TSP & Year & TSP & Day
        End If
        If TF.ToUpper = "DDYYYYMM" Then
            Return Day & TSP & Year & TSP & Month
        End If
        Return ""
    End Function
    Shared Function isEmail(ByVal str As String) As Boolean
        Dim regExp As New RegularExpressions.Regex("^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$")
        If regExp.Match(str).Success Then
            Return True
        End If
        Return False
    End Function

    Shared Function getEWItemByMonth(ByVal month As Integer) As String
        Return SAPDAL.CommonLogic.getEWItemByMonth(month)
    End Function

    Shared Function getRateByEWItem(ByVal itemNo As String, ByVal Plant As String) As Double
        Return SAPDAL.CommonLogic.getRateByEWItem(itemNo, Plant)
    End Function
    Shared Function getMonthByEWItem(ByVal itemNo As String) As Double
        Select Case itemNo.ToUpper.Trim()
            Case "AGS-EW-03"
                Return 3
            Case "AGS-EW-06"
                Return 6
            Case "AGS-EW-09"
                Return 9
            Case "AGS-EW-12"
                Return 12
            Case "AGS-EW-15"
                Return 15
            Case "AGS-EW-21"
                Return 21
            Case "AGS-EW-24"
                Return 24
            Case "AGS-EW-36"
                Return 36
            Case "AGS-EW-AD"
                Return 99
            Case "AGS-EW/DOA-03"
                Return 999
        End Select
        Return 0
    End Function
    Shared Function shipCode2Txt(ByVal shipCode As String) As String
        Dim ret = ""
        Select Case shipCode.Trim()
            Case "01"
                ret = "Truck / Sea"
            Case "02"
                ret = "Pick up by customer"
            Case "03"
                ret = "Fedex"
            Case "04"
                ret = "UPS Economy"
            Case "05"
                ret = "DHL Economy"
            Case "06"
                ret = "By Material"
            Case "07"
                ret = "Air"
            Case "08"
                ret = "Service"
            Case "09"
                ret = "TNT Economy"
            Case "10"
                ret = "TNT Global"
            Case "11"
                ret = "UPS Global"
            Case "12"
                ret = "DHL Air Express"
            Case "13"
                ret = "Hand Carry"
            Case "14"
                ret = "Courier"
            Case "15"
                ret = "UPS Standard"
            Case "16"
                ret = "Cust. Own Forwarder"
            Case "17"
                ret = "TNT Economy Special"
            Case "18"
                ret = "By Sea to AKMC&ADMC"
            Case "19"
                ret = "By Sea/Air (to ACSC)"
            Case "20"
                ret = "UPS Express Saver"
            Case "21"
                ret = "UPS Expres Plus 9:00"
            Case "22"
                ret = "UPS Express 12:00"
            Case "23"
                ret = "DHL Europlus"
        End Select
        Return ret
    End Function
End Class

Public Class SAPtools
    Public Shared Function getInventoryAndATPTable(ByVal PartNo As String, _
                                            ByVal Plant As String, _
                                            ByVal reqQty As Integer, _
                                            Optional ByRef DueDate As String = "", _
                                            Optional ByRef Inventory As Integer = 0, _
                                            Optional ByRef ATPtable As DataTable = Nothing, _
                                            Optional ByVal reqDate As String = "", _
                                            Optional ByRef satisFlag As Integer = 1, _
                                            Optional ByRef qtyCanBeConfirm As Int64 = 0, Optional ByVal stoc As String = "", Optional ByVal PNStatus As String = "") As Integer

        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        Dim LocalDate As DateTime = SAPDOC.GetLocalTime(HttpContext.Current.Session("org_id").ToString.Substring(0, 2))
        ' Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now),
        Dim retQty As Integer = 0
        PartNo = Global_Inc.Format2SAPItem(Trim(UCase(PartNo)))
        Dim culQty As Integer = 0
        Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
        Dim rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
        rOfretTb.Req_Qty = reqQty
        If reqDate <> "" AndAlso IsDate(reqDate) Then
            rOfretTb.Req_Date = CDate(reqDate).ToString("yyyyMMdd")
        End If
        ' Ming add 2013-11-28  如果reqdate是空字符，就默认是今天
        If reqDate.Trim = String.Empty Then
            rOfretTb.Req_Date = LocalDate.ToString("yyyyMMdd")
        End If
        'end
        retTb.Add(rOfretTb)
        p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PartNo, UCase(Plant), "", "", stoc, "", "PC", "", Inventory, "", "", _
                                      New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
        p1.Connection.Close()
        ATPtable = atpTb.ToADODataTable()
        If PartNo.ToUpper.StartsWith("AGS-") Then
            DueDate = LocalDate.Date.ToString("yyyy-MM-dd")
        Else
            If ATPtable.Rows.Count > 0 Then
                For Each r As DataRow In ATPtable.Rows
                    qtyCanBeConfirm += CType(r.Item("com_qty"), Int64)
                Next
                If qtyCanBeConfirm > 0 Then
                    DueDate = Glob.DateFormat(ATPtable.Rows(ATPtable.Rows.Count - 1).Item("Com_Date").ToString, "YYYYMMDD", "YYYYMMDD", "", "-")
                Else
                    DueDate = "1900-01-01"
                End If
            Else
                DueDate = "1900-01-01"
            End If
        End If
        'Nada 20131210 if Org=TW and status=H always show reference only and use Replenishment lead time to get duedate

        If HttpContext.Current.Session("org_id") = "TW01" AndAlso PNStatus = "H" Then
            DueDate = "1900-01-01"
        End If
        '/Nada 20131210
        If DueDate = "1900-01-01" Then
            DueDate = LocalDate.Date.AddDays(getLeadTime(PartNo, Plant))
        End If
        Dim _DueDate As DateTime = CDate(DueDate)
        DueDate = MyCartOrderBizDAL.getCompNextWorkDateV2(_DueDate, HttpContext.Current.Session("org_id"))
        If reqQty > qtyCanBeConfirm Then
            satisFlag = 0
        Else
            satisFlag = 1
        End If
        'Nada 20131210 if Org=TW and status=H always show reference only and use Replenishment lead time to get duedate
        If HttpContext.Current.Session("org_id") = "TW01" AndAlso PNStatus = "H" Then
            satisFlag = 0
        End If
        '/Nada 20131210
        Return 1
    End Function

    <Obsolete()> _
    Public Shared Function getLeadTime_Old(ByVal pn As String, ByVal plant As String) As Integer
        Dim N As Integer = 0
        Dim str As String = String.Format("select (PLANNED_DEL_TIME + GP_PROCESSING_TIME) from dbo.SAP_PRODUCT_ABC where PART_NO='{0}' AND PLANT='{1}'", pn, plant)
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("MY", str)
        If dt.Rows.Count > 0 Then
            N = dt.Rows(0).Item(0)
        End If
        Return N
    End Function

    Class PNLeadTime
        Public Property PartNo As String : Public Property Plant As String : Public Property LeadDays As Integer
        Public Sub New()

        End Sub
        Public Sub New(ByVal pn As String, ByVal plant As String, ByVal LDays As Integer)
            PartNo = pn : Me.Plant = plant : LeadDays = LDays
        End Sub
    End Class

    Public Shared Function getLeadTime(ByVal pn As String, ByVal plant As String) As Integer
        pn = Global_Inc.RemoveZeroString(pn)
        Dim PNLeadTimeList As List(Of PNLeadTime) = HttpContext.Current.Cache("PNLeadTimeList")
        If PNLeadTimeList Is Nothing Then
            PNLeadTimeList = New List(Of PNLeadTime)
            HttpContext.Current.Cache.Add("PNLeadTimeList", PNLeadTimeList, Nothing, Now.AddHours(12), System.Web.Caching.Cache.NoSlidingExpiration, CacheItemPriority.Default, Nothing)
        End If

        Dim result = From q In PNLeadTimeList Where q.Plant = plant And q.Plant = pn

        If result.Count = 0 Then
            Dim cmd As New SqlClient.SqlCommand("select (PLANNED_DEL_TIME + GP_PROCESSING_TIME) from dbo.SAP_PRODUCT_ABC where PART_NO=@PN AND PLANT=@DlvPlant", _
                                                New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
            cmd.Parameters.AddWithValue("PN", pn) : cmd.Parameters.AddWithValue("DlvPlant", plant)
            cmd.Connection.Open()
            Dim LDayObj As Object = cmd.ExecuteScalar()
            cmd.Connection.Close()
            If LDayObj IsNot Nothing Then
                PNLeadTimeList.Add(New PNLeadTime(pn, plant, CInt(LDayObj)))
            End If
        End If

        result = From q In PNLeadTimeList Where q.PartNo = pn And q.Plant = plant

        If result.Count > 0 Then
            Return result(0).LeadDays
        End If
        Return 30
    End Function

    
    Public Shared Function getSAPPriceByTable(ByVal partNoStr As String, ByVal qty As Integer, ByVal org As String, ByVal company As String, ByVal Currency As String, ByRef retTable As DataTable) As Integer
        retTable = New DataTable
        With retTable.Columns
            .Add("Mandt") : .Add("Vkorg") : .Add("Kunnr") : .Add("Matnr") : .Add("Mglme", GetType(Integer))
            .Add("Kzwi1", GetType(Double)) : .Add("Netwr", GetType(Double))
        End With

        Dim WS As New SAPDAL.SAPDAL, ProdInDt As New SAPDAL.SAPDALDS.ProductInDataTable, ProdOutDt As New SAPDAL.SAPDALDS.ProductOutDataTable, strErrMsg As String = ""
        'ProdInDt.AddProductInRow(partNoStr, 1, "")
        ProdInDt.AddProductInRow(partNoStr, qty, "")
        Dim retFlg As Boolean = WS.GetPrice(company, company, org, Currency, "", ProdInDt, ProdOutDt, strErrMsg)

        Dim _IsShowWebPrice As Boolean = IIf(AuthUtil.IsBBUS, Advantech.Myadvantech.Business.OrderBusinessLogic.IsBBShowWebPrice(company), False)

        If retFlg Then
            For Each pOutRow As SAPDAL.SAPDALDS.ProductOutRow In ProdOutDt.Rows
                Dim retRow As DataRow = retTable.NewRow()
                retRow.Item("Mandt") = "168" : retRow.Item("Vkorg") = org : retRow.Item("Kunnr") = company
                retRow.Item("Matnr") = pOutRow.PART_NO : retRow.Item("Mglme") = 1
                retRow.Item("Kzwi1") = pOutRow.LIST_PRICE : retRow.Item("Netwr") = pOutRow.UNIT_PRICE

                'Frank 20171226 replace original list price by L1 price grade
                If _IsShowWebPrice Then
                    Dim _webprice As Decimal = Advantech.Myadvantech.Business.PartBusinessLogic.GetBBWebPrice(pOutRow.PART_NO)
                    Dim _oriLP As Decimal = 0
                    Decimal.TryParse(pOutRow.LIST_PRICE, _oriLP)
                    If _webprice > _oriLP Then
                        retRow.Item("Kzwi1") = _webprice
                    End If
                End If

                retTable.Rows.Add(retRow)
            Next
            Return 1
        Else
            Return 0
        End If
    End Function

    Public Shared Function getGradePriceByTable(ByVal partNoStr As String, ByVal RBU As String, ByVal company As String, ByVal pGrade As String, ByVal CURR As String, ByRef retTable As DataTable) As Integer
        If pGrade.Length <> 8 Then Return Nothing
        Dim strKDGRP As String = "01", org As String = MYSAPBIZ.RBU2Org(RBU, HttpContext.Current.Session("org_id"))

        Select Case RBU.ToUpper()
            Case "ATW"
                strKDGRP = "03"
            Case "HQDC"
                strKDGRP = "D1"
            Case "ACN", "ABJ"
                strKDGRP = "05"
            Case "ADL", "AFR", "AEE", "ABN", "AUK", "APL"
                strKDGRP = "02"
            Case "AAC"
                strKDGRP = "10"
            Case "AENC"
                strKDGRP = "20"
            Case "ACL"
                strKDGRP = "01"
            Case "ABR"
                strKDGRP = "B1"
            Case "AKR"
                strKDGRP = "K1"
            Case "AJP"
                strKDGRP = "06"
            Case "SAP"
                strKDGRP = "07"
            Case "AAU"
                strKDGRP = "08"
            Case Else
                strKDGRP = "01"
        End Select

        Dim pg As New PRICE_GRADE.PRICE_GRADE
        Dim qin As New PRICE_GRADE.ZSSD_01_PGTable
        Dim qout As New PRICE_GRADE.ZSSD_02Table

        'C3V5P6L0

        pGrade = pGrade.Trim().ToUpper() : org = org.Trim().ToUpper()
        Dim part_noArr() As String = partNoStr.Trim().Trim("|").Split("|")
        For Each p As String In part_noArr

            Dim qinRow1 As New PRICE_GRADE.ZSSD_01_PG
            With qinRow1
                .Matnr = Global_Inc.Format2SAPItem(p.Trim) : .Mglme = 1
                .Kdkg1 = pGrade.Substring(0, 2) : .Kdkg2 = pGrade.Substring(2, 2)
                .Kdkg3 = pGrade.Substring(4, 2) : .Kdkg4 = pGrade.Substring(6, 2)
                .Mandt = "168" : .Vkorg = org : .Waerk = CURR.ToString().ToUpper  ' .Kunnr = "EDDEVI07"
                .Kdgrp = strKDGRP
            End With
            qin.Add(qinRow1)
        Next

        pg.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        pg.Connection.Open()
        Try
            pg.Z_Sd_Priceinquery_Pg("1", qin, qout)
        Catch ex As Exception
            pg.Connection.Close() : Return Nothing
        End Try
        pg.Connection.Close()

        retTable = qout.ToADODataTable()
        Return 1
    End Function

    <Obsolete()> _
    Public Shared Function getEpricerPrice(ByVal partNoStr As String, ByVal PRI_LST As String, ByVal pGrade As String, ByVal RBU As String, ByVal YEAR As String, ByVal QUARTER As String, ByVal CURR As String, ByRef retDT As DataTable) As Integer
        retDT.Columns.Clear()
        retDT.Columns.Add("PART_NO")
        retDT.Columns.Add("LIST_PRICE")
        retDT.Columns.Add("UNIT_PRICE")
        If pGrade = "" Then
            pGrade = "L0L0L0L0"
        End If
        Dim part_noArr() As String = partNoStr.Trim().Trim("|").Split("|")
        For Each p As String In part_noArr
            'Dim DT As DataTable = dbUtil.dbGetDataTable("my", String.Format("select top 1 convert(decimal(10,2),AMT1) AS AMT1,convert(decimal(10,2),LIST_PRICE) AS LIST_PRICE from epricer_price where GRADE_NAME = '{0}' AND PROD_NAME='{1}' and org='{2}' and curcy_cd='{3}' AND AMT1 IS NOT NULL AND LIST_PRICE IS NOT NULL ORDER BY YEAR DESC,QUARTER DESC", GRADE, PN, org, CURR))

            Dim R As DataRow = retDT.NewRow()
            R.Item("PART_NO") = p
            R.Item("LIST_PRICE") = 0
            R.Item("UNIT_PRICE") = 0
            If PRI_LST <> "" And YEAR <> "" And QUARTER <> "" Then
                Dim pdt As DataTable = dbUtil.dbGetDataTable("MY", _
                " select top 1 LIST_PRICE, AMT1 from EPRICER_PRICE " + _
                String.Format(" where LIST_PRICE is not null and AMT1 is not null and PROD_NAME='{0}' and PRI_LST='{1}' and GRADE_NAME='{2}' ", _
                          p, PRI_LST, pGrade) + _
                String.Format(" and ORG='{0}' and YEAR={1} and QUARTER={2} and CURCY_CD='{3}'", IIf(RBU = "AEU" Or RBU = "ADL" Or RBU = "AIT" Or RBU = "AFR" Or RBU = "ABN" Or RBU = "AEE" Or RBU = "AUK", "AESC", RBU), YEAR, QUARTER, CURR))
                If pdt.Rows.Count > 0 Then
                    R.Item("LIST_PRICE") = pdt.Rows(0).Item("LIST_PRICE")
                    R.Item("UNIT_PRICE") = pdt.Rows(0).Item("AMT1")
                End If
            End If
            retDT.Rows.Add(R)
        Next

        Dim PartNoStrWithPriceZero As String = ""
        For Each R As DataRow In retDT.Rows()
            If R.Item("UNIT_PRICE") = 0 Then
                PartNoStrWithPriceZero &= R.Item("part_no") & "|"
            End If
        Next

        Dim RETTABLE As New DataTable
        getGradePriceByTable(PartNoStrWithPriceZero, RBU, "", pGrade, CURR, RETTABLE)
        If RETTABLE.Rows.Count > 0 Then
            For Each R As DataRow In RETTABLE.Rows()
                If R.Item("Netwr") > 0 Then
                    For Each rr As DataRow In retDT.Select(String.Format("PART_NO='{0}'", R.Item("MATNR").ToString.TrimStart("0")))
                        rr.Item("LIST_PRICE") = R.Item("Kzwi1")
                        rr.Item("UNIT_PRICE") = R.Item("Netwr")
                        retDT.AcceptChanges()
                    Next
                End If
            Next
        End If
        Return 1
    End Function

    Public Shared Function getCOMBOM(ByVal Component As String, ByVal Plant As String, ByRef er As String) As DataTable
        Dim MyComBom As New ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZPP_BOM_EXPL_MAT_V2_RFC_CKD
        Dim dtret As New ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60Table
        MyComBom.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        MyComBom.Connection.Open()
        MyComBom.Zpp_Bom_Expl_Mat_V2_Rfc("", "", Component, Plant, er, dtret)
        MyComBom.Connection.Close()
        Return dtret.ToADODataTable
    End Function
End Class


'Public Class TBase

'End Class

'Public Class TFrame : Inherits TBase

'End Class

'Public Class TDataDest : Inherits TFrame
'    Property command As String
'    Property serverName As String
'    Property tbName As String
'    Property row() As ArrayList()
'    Property culomn() As ArrayList()
'End Class

'Public Class TDataCommand

'End Class

'Public Class TOthers : Inherits TBase

'End Class

'Public Class SeqExChanger : Inherits TOthers

'End Class