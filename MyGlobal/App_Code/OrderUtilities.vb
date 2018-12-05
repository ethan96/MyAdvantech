Imports Microsoft.VisualBasic

Public Class OrderUtilities
    'Public Shared l_strSQLCmd As String = "", PszHTML As String = "", iRet As Integer = 0
    Public dTb As DataTable
   
    Shared Function CheckEWItem(ByVal item As String) As Boolean
        '¡°ZSRV¡±, ¡°968MS¡±, ¡°96SW¡±, ¡°98¡±, ¡°ZHD0¡±, ¡°ZSPC¡± and ¡°ZINS¡± 
       
        Dim strArr As String() = System.Configuration.ConfigurationManager.AppSettings("MaterialGroup").Split(",")
        Dim strSql As String = ""
        For i As Integer = 0 To strArr.Length - 1
            strSql &= " and material_group<>'" & strArr(i) & "' "
        Next
        'response.Write (strSql) : response.End
        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", "select material_group from sap_product where part_no='" & item & "'" & strSql)
        If dt.Rows.Count > 0 Then
            If dt.Rows.Count > 0 Then
                Return True
            Else
                Return False
            End If
        Else
            Return False
        End If
    End Function

    

    Public Shared Sub InitMultiPriceRs(ByRef MPRs As DataTable)
        MPRs = New DataTable
        With MPRs.Columns
            .Add("part", Type.GetType("System.String")) : .Add("qty_buy", Type.GetType("System.Decimal"))
            .Add("unit_Price", Type.GetType("System.Decimal")) : .Add("list_Price", Type.GetType("System.Decimal"))
        End With
    End Sub
    
    Public Shared Function GetPrice( _
    ByVal strPart_No As String, _
    ByVal strCompany_Id As String, _
    ByVal sales_org As String, _
    ByVal intQty As Double, _
    ByRef p_fltList_Price As Decimal, _
    ByRef p_fltUnit_Price As Decimal) As Integer
        Dim ws As New MYSAPDAL, pin As New SAPDALDS.ProductInDataTable, pout As New SAPDALDS.ProductOutDataTable, strErr As String = ""
        pin.AddProductInRow(strPart_No, intQty)
        If ws.GetPrice(strCompany_Id, strCompany_Id, sales_org, pin, pout, strErr) AndAlso pout IsNot Nothing AndAlso pout.Rows.Count > 0 Then
            Dim pOutRow1 As SAPDALDS.ProductOutRow = pout.Rows(0)
            If Decimal.TryParse(pOutRow1.LIST_PRICE, 0) Then p_fltList_Price = CDbl(pOutRow1.LIST_PRICE)
            If Decimal.TryParse(pOutRow1.UNIT_PRICE, 0) Then p_fltUnit_Price = CDbl(pOutRow1.UNIT_PRICE)
        Else
            Return -1
        End If

        'If (LCase(strCompany_Id) = "b2bguest" Or Global_Inc.IsRBU(strCompany_Id, "")) Then

        '    If LCase(strCompany_Id) = "uuaaesc" And (LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("esales/quote") Or LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("orderchangerequest")) Then
        '        'continue..
        '    Else
        '        p_fltList_Price = 0.0
        '        p_fltUnit_Price = 0.0
        '        Exit Function
        '    End If
        'End If

        'If strPart_No.Contains("|") Then
        'Else
        '    Dim sc3 As New aeu_ebus_dev9000.B2B_AEU_WS, WSDL_URL As String = ""
        '    'Global_Inc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        '    sc3.Url = "http://172.20.1.31:9000/B2B_SAP_WS.asmx"
        '    Try
        '        sc3.GetPriceRFC("168", sales_org, strCompany_Id, strPart_No, intQty, p_fltList_Price, p_fltUnit_Price)
        '    Catch ex As Exception
        '        p_fltList_Price = -1 : p_fltUnit_Price = -1 : Return -1 : Exit Function
        '    End Try

        '    'If LCase(OriginalCompanyId) = "b2bguest" Or Global_Inc.IsRLP(HttpContext.Current.Session("user_id"), HttpContext.Current.Session("COMPANY_ID")) Then
        '    '    strCompany_Id = tempCompanyId
        '    'End If

        '    If p_fltList_Price < 0 Then p_fltList_Price = 0
        '    If p_fltUnit_Price < 0 Then p_fltUnit_Price = 0

        '    '--{2006-08-25}--Daive: add customer "B2BGUEST", Use "UUAAESC" to get price. It just see the list price
        '    'Jackie add 2007/3/1 set the Unit_Price=List_Price for RBU company code
        '    If LCase(strCompany_Id) = "b2bguest" Or _
        '    Global_Inc.IsRLP(HttpContext.Current.Session("user_id"), strCompany_Id) And _
        '    Not (LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("esales/quote") Or LCase(HttpContext.Current.Request.ServerVariables("URL")).Contains("orderchangerequest")) _
        '    Then
        '        'If LCase(strCompany_Id) = "b2bguest" Then
        '        p_fltUnit_Price = p_fltList_Price
        '        If Global_Inc.IsRBU(strCompany_Id, "") Then
        '            p_fltList_Price = -1
        '        End If
        '    Else
        '        If p_fltList_Price < p_fltUnit_Price Then
        '            p_fltList_Price = p_fltUnit_Price
        '        End If

        '    End If
        'End If
    End Function

    Public Shared Function IsPhaseOut(ByVal strPart_No As String, ByVal sales_org As String, ByRef status As String) As Boolean

        Dim strSql As String = ""
        strSql = String.Format("select top 1 product_status as status from SAP_PRODUCT_STATUS where part_no='{0}' and sales_org like '{1}%'", strPart_No, Left(sales_org, 2))
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim dr1 As DataTable = dbUtil.dbGetDataTable("B2B", strSql)
        If dr1.Rows.Count > 0 Then
            If dr1.Rows(0).Item("status") <> "A" And dr1.Rows(0).Item("status") <> "N" _
            And dr1.Rows(0).Item("status") <> "H" And dr1.Rows(0).Item("status") <> "S5" Then
                Return True
            Else
                Return False
            End If
            status = dr1.Rows(0).Item("status")
        Else
            Return False
        End If
        'g_adoConn.Close()
    End Function

    Public Shared Function BtosOrderCheck() As Integer
        REM == Get Category Info ==
        'Dim l_strSQLCmd As String = ""
        Dim l_strSQLCmd2 As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection
        'Dim iDataReader As DataTable
        Dim jDataReader As DataTable

        'Frank 2012/06/27:logistics_detail was renamed to logistics_detail_old becuase this table was not in used.
        'l_strSQLCmd = " select * from logistics_detail where line_no >= 100 and logistics_id =" & "'" & HttpContext.Current.Session("LOGISTICS_ID") & "' order by line_no asc"
        'l_strSQLCmd2 = " select * from cart_detail where line_no >= 100 and CART_ID =" & "'" & HttpContext.Current.Session("CART_ID") & "' order by line_no asc"
        'Frank 2012/06/27:For performance issue, please do not "select *"
        l_strSQLCmd2 = " select count(line_no) from cart_detail where line_no >= 100 and CART_ID ='" & HttpContext.Current.Session("CART_ID").ToString.Replace("'", "''") & "'"
        'iDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        jDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd2)
        'If IDataReader.Rows.Count > 0 Or jDataReader.Rows.Count > 0 Then
        '    BtosOrderCheck = 1
        'Else
        '    BtosOrderCheck = 0
        'End If

        If CType(jDataReader.Rows(0).Item(0), Integer) > 0 Then
            BtosOrderCheck = 1
        Else
            BtosOrderCheck = 0
        End If

        'g_adoConn.Close()
    End Function

    Public Shared Function GetPIPreview(ByVal strPIId As String, ByVal strPIType As String, _
                                        ByRef p_strHTML As String, _
    ByRef account_flg As Boolean) As Integer
        Dim exeFunc As Integer = 0
        'Dim g_adoConn As New SqlClient.SqlConnection

        Dim l_strHTML As String = ""
        Dim l_strHTML1 As String = ""
        Dim l_strHTML2 As String = ""
        Dim l_strHTML3 As String = ""
        Dim l_strSQLCmd As String = ""

        Dim iDataTable As DataTable
        'exeFunc = DBConn_Get(strEntity_Id, "B2B", l_adoConn)
        'exeFunc = DBConn_Get("AEU", "B2B", l_adoConn)
        '---- prepare company info
        l_strSQLCmd = "select " & _
            "b.company_id, " & _
            "b.company_name," & _
            "(IsNull(b.address,'') + ' ' + IsNull(b.city,'') + ', ' + IsNull(b.country,'')) as address," & _
            "IsNull(b.tel_no,'') as tel_no, " & _
            "IsNull(b.fax_no,'') as fax_no," & _
            "IsNull(a.attention,'') as attention " & _
            "from logistics_master a " & _
            "inner join sap_dimcompany b " & _
            "on a.soldto_id = b.company_id and b.company_type in ('Partner','Z001') " & _
            "where a.logistics_id = '" & strPIId & "'"
        Dim STDataReader As DataTable
        STDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim strSTCompanyId As String = ""
        Dim strSTCompanyName As String = ""
        Dim strSTAddr As String = ""
        Dim strSTTelNo As String = ""
        Dim strSTFaxNo As String = ""
        Dim strSTAttention As String = ""
        If STDataReader.Rows.Count > 0 Then
            strSTCompanyId = STDataReader.Rows(0).Item("company_id")
            strSTCompanyName = STDataReader.Rows(0).Item("company_name")
            strSTAddr = STDataReader.Rows(0).Item("address")
            strSTTelNo = STDataReader.Rows(0).Item("tel_no")
            strSTFaxNo = STDataReader.Rows(0).Item("fax_no")
            strSTAttention = STDataReader.Rows(0).Item("attention")
        End If
        'g_adoConn.Close()
        'If LCase(HttpContext.Current.Session("user_id")) = "davie.wang@advantech.com.cn" Then
        '    HttpContext.Current.Response.Write("test") : Response.End()
        'End If
        '---- prepare company info
        l_strSQLCmd = "select " & _
            "a.shipto_id as company_id, " & _
            "b.company_name," & _
            "(IsNull(b.address,'') + ' ' + IsNull(b.city,'') + ', ' + IsNull(b.country,'')) as address," & _
            "IsNull(b.tel_no,'') as tel_no, " & _
            "IsNull(b.fax_no,'') as fax_no," & _
            "IsNull(a.customer_attention,'') as customer_attention " & _
            "from logistics_master a " & _
            "inner join sap_dimcompany b " & _
            "on a.shipto_id = b.company_id " & _
            "where a.logistics_id = '" & strPIId & "'"
        Dim SHDataReader As DataTable
        SHDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim strSHCompanyId As String = ""
        Dim strSHCompanyName As String = ""
        Dim strSHAddr As String = ""
        Dim strSHTelNo As String = ""
        Dim strSHFaxNo As String = ""
        Dim strSHAttention As String = ""
        If SHDataReader.Rows.Count > 0 Then
            strSHCompanyId = SHDataReader.Rows(0).Item("company_id")
            strSHCompanyName = SHDataReader.Rows(0).Item("company_name")
            strSHAddr = SHDataReader.Rows(0).Item("address")
            Try
                strSHTelNo = SHDataReader.Rows(0).Item("tel_no")
            Catch ex As Exception
                strSHTelNo = ""
            End Try
            strSHFaxNo = SHDataReader.Rows(0).Item("fax_no")
            strSHAttention = SHDataReader.Rows(0).Item("customer_attention")
        End If
        'g_adoConn.Close()
        If LCase(HttpContext.Current.Session("user_id")) = "nada.liu@advantech.com.cn" Then
            'HttpContext.Current.Response.Write(l_strSQLCmd&"<br>")
        End If
        l_strHTML1 = ""
        'l_strHTML1 = l_strHTML1 & "<table width=""736"" border=""0"" cellspacing=""0"" cellpadding=""0"" height=""20"">"
        'l_strHTML1 = l_strHTML1 & "<tr><td width=""10"" height=""18"" valign=""bottom"" bgcolor=""4F60B2"">&nbsp;</td>"
        'l_strHTML1 = l_strHTML1 & "<td bgcolor=""4F60B2"" height=""18"" width=""133"" >" 
        'l_strHTML1 = l_strHTML1 & "<div align=""center""><b><font color=""#FFFFFF"">Customer Information</font></b></div></td>"
        'l_strHTML1 = l_strHTML1 & "<td width=""54"" height=""18"" valign=""bottom""><img src=""/images/folder.jpg"" width=""8"" height=""19""></td>"
        'l_strHTML1 = l_strHTML1 & "<td width=""410"" height=""18"">&nbsp;</td></tr></table>"

        'l_strHTML1 = l_strHTML1 & "<table width=""737"" border=""0"" cellspacing=""0"" cellpadding=""0"" height=""737"" >"
        'l_strHTML1 = l_strHTML1 & "<tr><td height=""127"" valign=""top"" >"

        l_strHTML1 = l_strHTML1 & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML1 = l_strHTML1 & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" align=""left"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#ffffff""><b>Customer Information</b></font></td></tr>"
        l_strHTML1 = l_strHTML1 & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        'l_strHTML1 = l_strHTML1 & "<table width=""731"" border=""1"" cellspacing=""0"" cellpadding=""0"" bordercolor=""4F5FB1"">"
        'l_strHTML1 = l_strHTML1 & "<tr><td bgcolor=""FFFFFF"" height=""17"" >"

        l_strHTML1 = l_strHTML1 & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#F0F0F0"" colspan=""4"" align =""center"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Customer Information&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "</tr>"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Customer&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""60%"" align=""left"" >"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSTCompanyName & "(" & strSTCompanyId & ")</font></td>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Attention&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""20%""  align=""left"" >"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSTAttention & "</font></td>"
        l_strHTML1 = l_strHTML1 & "</tr>"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" rowspan=""2"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Address&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""60%"" rowspan=""2""  align=""left"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSTAddr & "</font></td>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%""  height=""10""  bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Tel No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10""  align=""left"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSTTelNo & "</font></td>"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" height=""7"" bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Fax No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10""  align=""left"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSTFaxNo & "</font></td>"
        l_strHTML1 = l_strHTML1 & "</tr>"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#F0F0F0"" colspan=""4"" align =""center"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Shipping Information&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "</tr>"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Customer&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""60%""   align=""left"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSHCompanyName & "(" & strSHCompanyId & ")</font></td>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Attention&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""20%""  align=""left"" >"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSHAttention & "</font></td>"
        l_strHTML1 = l_strHTML1 & "</tr>"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" rowspan=""2"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Address&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""60%"" rowspan=""2""  align=""left"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSHAddr & "</font></td>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%""  height=""10""  bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Tel No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10""  align=""left"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSHTelNo & "</font></td>"
        l_strHTML1 = l_strHTML1 & "</tr>"
        l_strHTML1 = l_strHTML1 & "<tr>"
        l_strHTML1 = l_strHTML1 & "<td width=""10%"" height=""7"" bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML1 = l_strHTML1 & "<b><font color=""#333333"">Fax No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML1 = l_strHTML1 & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10""  align=""left"">"
        l_strHTML1 = l_strHTML1 & "<font color=""#333333"">&nbsp;" & strSHFaxNo & "</font></td>"
        l_strHTML1 = l_strHTML1 & "</tr>"
        l_strHTML1 = l_strHTML1 & "</table>"
        l_strHTML1 = l_strHTML1 & "</td></tr></table>"
        '----- Order Section 
        '---- prepare company info
        l_strSQLCmd = "select " & _
            "a.po_no," & _
            "IsNull(a.po_date,'') as po_date," & _
            "a.due_date," & _
            "a.required_date," & _
            "a.ship_condition," & _
            "isnull(a.order_note,'') as order_note," & _
            "a.partial_flag," & _
            "a.remark, " & _
            "a.INCOTERM, " & _
            "a.INCOTERM_TEXT, " & _
            "a.SALES_NOTE, " & _
            "IsNull(a.freight,0) as freight, " & _
            "a.OP_NOTE,a.prj_note,isnull(a.DefaultSalesNote,'N') as DefaultSalesNote " & _
            "from logistics_master a " & _
            "inner join sap_dimcompany b " & _
            "on a.soldto_id = b.company_id and b.company_type='Z001' " & _
            "where a.logistics_id = '" & strPIId & "'"

        Dim OrderDataReader As DataTable
        OrderDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim strOrderNo As String = ""
        Dim strPoNo As String = ""
        Dim strPoDate As String = ""
        Dim dtOrderDate As String = ""
        Dim dtExpectedDate As String = ""
        Dim strOrderNote As String = ""
        '--{2005-9-28}--Daive: 
        Dim strSalesNote As String = ""
        Dim strOPNote As String = ""
        Dim strprjNote As String = ""
        Dim strRemark As String = ""
        Dim strIncotermText As String = ""
        Dim strShipCondition As String = ""
        Dim strIncoterm As String = ""
        Dim strPlacedBy As String = ""
        Dim flgPartialOK As String = "", DefaultSalesNote As String = "N"

        Dim dtRequiredDate As String = ""
        If OrderDataReader.Rows.Count > 0 Then
            strOrderNo = ""
            strPoNo = OrderDataReader.Rows(0).Item("po_no")
            strPoDate = OrderDataReader.Rows(0).Item("po_date")
            dtOrderDate = Global_Inc.FormatDate(Date.Now.Date)
            dtExpectedDate = Global_Inc.FormatDate(OrderDataReader.Rows(0).Item("due_date"))
            dtRequiredDate = Global_Inc.FormatDate(OrderDataReader.Rows(0).Item("required_date"))
            strOrderNote = OrderDataReader.Rows(0).Item("order_note")
            '--{2005-9-28}--Daive: 
            strSalesNote = OrderDataReader.Rows(0).Item("SALES_NOTE")
            strOPNote = OrderDataReader.Rows(0).Item("OP_NOTE")
            strprjNote = OrderDataReader.Rows(0).Item("prj_note")
            'jackie 20071009 for default sales note
            DefaultSalesNote = OrderDataReader.Rows(0).Item("DefaultSalesNote")

            strRemark = OrderDataReader.Rows(0).Item("remark")
            If LCase(OrderDataReader.Rows(0).Item("INCOTERM_TEXT")) = "blank" Then
                strIncotermText = ""
            Else
                strIncotermText = OrderDataReader.Rows(0).Item("INCOTERM_TEXT")
            End If

            strShipCondition = Mid(OrderDataReader.Rows(0).Item("ship_condition"), 3)
            strIncoterm = OrderDataReader.Rows(0).Item("INCOTERM")
            strPlacedBy = HttpContext.Current.Session("USER_ID")
            If OrderDataReader.Rows(0).Item("partial_flag") = "N" Then
                flgPartialOK = "<font color=""red"">No</font>"
            Else
                flgPartialOK = "Yes"
            End If
        End If

        l_strHTML2 = l_strHTML2 & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML2 = l_strHTML2 & "<tr><td  align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#ffffff""><b>Order Information</b></font></td></tr>"
        l_strHTML2 = l_strHTML2 & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        l_strHTML2 = l_strHTML2 & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">PO No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strPoNo & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Advantech SO&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strOrderNo & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Order Date&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & dtOrderDate & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Payment Term&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">&nbsp;Required Date&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & dtRequiredDate & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Incoterm&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strIncoterm & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Placed By&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strPlacedBy & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Incoterm Text&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strIncotermText & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Freight&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"" align='left'>"
        If OrderDataReader.Rows.Count > 0 AndAlso CDbl(OrderDataReader.Rows(0).Item("freight")) > 0 Then
            l_strHTML2 = l_strHTML2 & "<font color=""#333333"">" + FormatNumber(OrderDataReader.Rows(0).Item("freight"), 2).ToString() + "</font></td>"
        Else
            l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;</font></td>"
        End If

        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Channel&nbsp;&nbsp;</font></b></td>"
        '---- 271103e add for VISAM Case ----(Start)'
        Dim strAsmblyComp As String = ""
        Dim strOrderType As String = ""
        'exeFunc = GetAsmblyComp(1, strPIId, strAsmblyComp)
        'If UCase(strAsmblyComp) = "ADLVISAM" Then
        '	strOrderType="VISAM"                            
        'Else
        strOrderType = "SO"
        'End If		       

        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strOrderType & "</font></td>"
        '---- 271103e add for VISAM Case ----(End)'    
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Partial OK&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & flgPartialOK & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Ship Condition&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strShipCondition & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"

        '----------- judge for the sa case ----------Jackie 2005-12-07 --------------
        '     dim SA_Flag
        '     SA_Flag = false
        '     exeFunc = DBConn_Get("AEU","B2B",oConn)
        '	   xSQL = "select company_id from company_contact where userid = '" & HttpContext.Current.Session("user_id") &"'"
        '	   Set Rs_SA = oConn.Execute(xSQL)
        '	   If Not Rs_SA.EOF and Rs_SA("company_id")<>""
        '	   		SA_Flag = true
        '	   End If
        '	   Rs_SA.close
        '	   Set Rs_SA = Nothing			
        '	   oConn.close
        '     set oConn = nothing

        ' ----------------judge sa end here -----------------------
        If Util.IsInternalUser2() Or Util.IsAEUIT() Then
            If Not (strPoDate.ToString() Like "*9999*") Then
                l_strHTML2 = l_strHTML2 & "<tr>"
                l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
                l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">PO Date&nbsp;</font></b></td>"
                l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF""  align=""left"">"
                l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & strPoDate & "</font></td>"
                l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
                l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">&nbsp;</font></b></td>"
                l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
                l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;</font></td>"
                l_strHTML2 = l_strHTML2 & "</tr>"
            End If
        End If
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""top"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Order Note&nbsp;&nbsp;</font></b></td>"
        l_strHTML2 = l_strHTML2 & "<td  colspan=""3"" bgcolor=""#FFFFFF"" valign=""top""  align=""left"">"
        l_strHTML2 = l_strHTML2 & "<font color=""red""><b>" & Replace(Global_Inc.HTMLEncode(strOrderNote), "$$$$", "<br/>") & "</b></font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        '--{2005-9-28}--Daive: release Sales Note and OP Note to administrators and logistics
        '---------------------------------------------------------------------------------------------
        '--{2005-11-8}--Daive: All users can see Sales Note
        If Util.IsInternalUser2() Or Util.IsAEUIT() Then
            l_strHTML2 = l_strHTML2 & "<tr>"
            l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""middle"">"
            l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Sales Note&nbsp;&nbsp;</font></b></td>"
            l_strHTML2 = l_strHTML2 & "<td  colspan=""3""  valign=""top"" bgcolor=""#FFFFFF""  align=""left"">"
            If DefaultSalesNote = "Y" Then
                l_strHTML2 = l_strHTML2 & "<font color=""red""><b>" & strSalesNote & "</b></font></td>"
            Else
                l_strHTML2 = l_strHTML2 & "<font color=""red""><b>" & Global_Inc.HTMLEncode(strSalesNote) & "</b></font></td>"
            End If
            l_strHTML2 = l_strHTML2 & "</tr>"
            'if Lcase(HttpContext.Current.Session("USER_ROLE"))="logistics" or Lcase(HttpContext.Current.Session("USER_ROLE"))="administrator" then

            l_strHTML2 = l_strHTML2 & "<tr>"
            l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""middle"">"
            l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">OP Note&nbsp;&nbsp;</font></b></td>"
            l_strHTML2 = l_strHTML2 & "<td  colspan=""3""  valign=""top"" bgcolor=""#FFFFFF""  align=""left"">"
            l_strHTML2 = l_strHTML2 & "<font color=""red""><b>" & Global_Inc.HTMLEncode(strOPNote) & "</b></font></td>"
            l_strHTML2 = l_strHTML2 & "</tr>"

            l_strHTML2 = l_strHTML2 & "<tr>"
            l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""middle"">"
            l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Project Note&nbsp;&nbsp;</font></b></td>"
            l_strHTML2 = l_strHTML2 & "<td  colspan=""3""  valign=""top"" bgcolor=""#FFFFFF""  align=""left"">"
            l_strHTML2 = l_strHTML2 & "<font color=""red""><b>" & Global_Inc.HTMLEncode(strprjNote) & "</b></font></td>"
            l_strHTML2 = l_strHTML2 & "</tr>"
        End If
        '---------------------------------------------------------------------------------------------
        l_strHTML2 = l_strHTML2 & "</table>"
        l_strHTML2 = l_strHTML2 & "</td></tr></table>"


        '---- Detail Section
        l_strHTML3 = l_strHTML3 & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML3 = l_strHTML3 & "<tr><td  align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#ffffff""><b>Purchased Products</b></font></td></tr>"
        l_strHTML3 = l_strHTML3 & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        l_strHTML3 = l_strHTML3 & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML3 = l_strHTML3 & "<tr>"
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Seq</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""3%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Ln</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""17%"" bgcolor=""#F0F0F0""  align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Product</b></font></td>"

        '--CustomerPN
        l_strHTML3 = l_strHTML3 & "<td width=""17%"" bgcolor=""#F0F0F0""  align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Customer P\N</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""40%"" bgcolor=""#F0F0F0"" align =""center"">"

        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Description</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Due Date</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Required Date</b></font></td>"
        If Global_Inc.C_ShowRoHS = True Then
            l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>RoHS</b></font></td>"
        End If
        'DMF_FLAG
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Sales Leads from Advantech (DMF)</b></font></td>"

        'CLASS
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Class</b></font></td>"
        'Jackie add 2007/03/28
        If 1 = 1 Then
            l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Extended<br/>Warranty<br/>Months<br/></b></font></td>"
        End If
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Qty</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""right""><b>Price</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Subtotal</b></font></td>"
        l_strHTML3 = l_strHTML3 & "</tr>"
        'Const strSlowMoving As String = " + case max(c.attributea) when 'X' then '<br><FONT COLOR=#FF00OO>Last buy with special price please contact our Sales</FONT>' else '' end "
        Const strSlowMoving As String = ""
        l_strSQLCmd = "select " & _
       "a.currency, " & _
       "b.line_no, " & _
       "IsNull(b.DMF_Flag,'') as DMF_Flag, " & _
       "b.part_no, " & _
       "max(c.product_desc)" & strSlowMoving & " as product_desc," & _
       "IsNull(case c.RoHS_Flag when 1 then 'Y' else 'N' end,'') as RoHS, " & _
       "IsNull((select top 1 z.abc_indicator from sap_product_abc z where z.part_no=b.part_no),'') as Class, " & _
       "b.due_date, " & _
       "b.required_date, " & _
       "b.qty, " & _
       "isnull(b.auto_order_flag,'') as auto_order_flag, " & _
       "b.unit_price,isnull(b.exwarranty_flag,'0') as exwarranty_flag ,b.NoATPFlag  " & _
       "from logistics_master a " & _
       "inner join logistics_detail b " & _
       "on a.logistics_id = b.logistics_id " & _
       "left join sap_product c " & _
       "on b.part_no = c.part_no " + _
       " inner join sap_product_org d on c.part_no=d.part_no and d.org_id='" + HttpContext.Current.Session("org_id") + "' " & _
       "where a.logistics_id = '" & strPIId & "' " & _
       "group by a.currency,b.line_no,b.DMF_Flag,b.part_no,RoHS_Flag,b.due_date,b.required_date,b.qty,b.auto_order_flag,b.unit_price,exwarranty_flag ,b.NoATPFlag " & _
       "order by b.line_no "
        'HttpContext.Current.Response.Write(l_strSQLCmd)
        iDataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        '--{2006-08-21}-Daive: For Component Order, hide AGS-EW-**
        'If Global_Inc.IsB2BOwner(HttpContext.Current.Session("user_id")) Or LCase(HttpContext.Current.Session("user_id")) = "sabine.lin@advantech.fr" Then 
        'Jackie 20070117
        If 1 <> 1 Then
            If iDataTable.Rows.Count > 0 Then
                '--{2006/8/31}-Jackie:For BTOS Order, hide AGS-EW-xx
                'If CInt(iDataTable.Rows(0).Item("line_no")) < 100 Then
                Dim xRow As DataRow()
                '                xRow = iDataTable.Select("line_no < 100 and part_no like 'AGS-EW-%'")
                xRow = iDataTable.Select(" part_no like 'AGS-EW-%'")
                For i As Integer = 0 To xRow.Length - 1
                    iDataTable.Rows.Remove(xRow(i))
                Next
                iDataTable.AcceptChanges()
                'End If
            End If
        End If
        '--End------
        Dim flgStdExist As String = "No"
        Dim flgBTOSExist As String = "No"
        Dim flgCTOSExist As String = "No"
        Dim strCurrency As String = ""
        Dim strCurrSign As String = ""

        Dim flgBtosTBD As String = "No"
        Dim flgStdTBD As String = "No"
        Dim fltSubTotal As Decimal = 0
        Dim fltBTOSTotal As Decimal = 0
        Dim fltTotal As Decimal = 0

        If iDataTable.Rows.Count > 0 Then
            strCurrency = iDataTable.Rows(0).Item("currency")
            Select Case UCase(iDataTable.Rows(0).Item("currency"))
                Case "US", "USD"
                    strCurrSign = "$"
                Case "NT"
                    strCurrSign = "NT"
                Case "EUR"
                    strCurrSign = "&euro;"
                Case "GBP"
                    strCurrSign = "&pound;"
                Case Else
                    strCurrSign = "$"
            End Select

            Dim intX As Integer = 0
            ' this two flag is for account view judge jackie.wu add 12/27/2005
            Dim bto_alert As String
            Dim flg_count As Integer
            account_flg = True
            bto_alert = ""
            flg_count = 1

            Do While intX <= iDataTable.Rows.Count - 1
                '---------------------------------------------------
                '---- { 24-11-04 } MARK * FOR REAL REQ DATE (START) 
                '---------------------------------------------------
                'exeFunc = DBConn_Get("AEU", "B2B", oConn)
                Dim flgGenunieReq As String = ""
                If CDate(iDataTable.Rows(intX).Item("required_date")).Date <> Date.Today.Date Then
                    flgGenunieReq = "*"
                Else
                    flgGenunieReq = ""
                End If
                'Else
                '    flgGenunieReq = ""
                'End If
                'g_adoConn.Close()
                '-------------------------------------------------
                '---- { 24-11-04 } MARK * FOR REAL REQ DATE (END) 
                '-------------------------------------------------

                If iDataTable.Rows(intX).Item("line_no") >= 100 And flgStdExist = "Yes" And flgBTOSExist = "No" Then
                    l_strHTML3 = l_strHTML3 & "<tr>"
                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" colspan=""11""  align =""right"">"
                    If fltSubTotal <= 0 Then
                        l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>Sub Total:&nbsp;TBD</b></font></td>"
                    Else
                        If flgStdTBD = "Yes" Then
                            l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>Sub Total:&nbsp;" & strCurrSign & FormatNumber(fltSubTotal, 2) & " + TBD</b></font></td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>Sub Total:&nbsp;" & strCurrSign & FormatNumber(fltSubTotal, 2) & "</b></font></td>"
                        End If
                    End If
                    l_strHTML3 = l_strHTML3 & "</tr>"
                End If
                If Global_Inc.C_ShowRoHS = True Then l_strHTML3 = Replace(l_strHTML3, "colspan=""10""", "colspan=""12""")
                If iDataTable.Rows(intX).Item("line_no") < 100 Then
                    flgStdExist = "Yes"
                    If iDataTable.Rows(intX).Item("unit_price") <= 0 Then
                        l_strHTML3 = l_strHTML3 & "<tr style=""BACKGROUND-COLOR: #ccffff;WIDTH=100%"">"
                    Else
                        '**** 300304Emil Add for Geveke Issu ****'
                        'If DateDiff("d",CDate(l_adoRs("due_date")),CDate(date())) > 10 Then
                        '	l_strHTML3 = l_strHTML3 & "<tr style=""font-weight: bold;BACKGROUND-COLOR: #ffcccc;WIDTH=100%"">" 
                        'Else	
                        '	l_strHTML3 = l_strHTML3 & "<tr>" 
                        'End If
                        l_strHTML3 = l_strHTML3 & "<tr>"
                    End If
                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
                    l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & intX + 1 & "&nbsp;</font></td>"
                    '30-06-04 For TDS
                    Try
                        If iDataTable.Rows(intX).Item("auto_order_flag") = "T" Then
                            l_strHTML3 = l_strHTML3 & "<td width=""3%"" bgcolor=""#ccffff"" align =""right"" >"
                        Else
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""3%""  align =""right"">"
                        End If
                    Catch ex As Exception
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""3%""  align =""right"">"
                    End Try

                    l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & iDataTable.Rows(intX).Item("line_no") & "</font></td>"
                    '**** 22-06-04 Emil Revised for "U" code ****'
                    Try
                        If iDataTable.Rows(intX).Item("auto_order_flag") = "U" Then
                            l_strHTML3 = l_strHTML3 & "<td width=""17%"" style=""BACKGROUND-COLOR: #ffcccc""  align=""left"">"
                        Else
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""17%""  align=""left"">"
                        End If
                    Catch ex As Exception
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""17%""  align=""left"">"
                    End Try
                    If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & UCase(iDataTable.Rows(intX).Item("part_no")) & "'>" & UCase(iDataTable.Rows(intX).Item("part_no")) & "</a></font></td>"

                    Else
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & UCase(iDataTable.Rows(intX).Item("part_no")) & "</font></td>"

                    End If
                    '--CustomerPN
                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""17%""  align=""left"">"
                    ' l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & UCase(getCustomerNo(HttpContext.Current.Session("Company_id"), iDataTable.Rows(intX).Item("part_no"))) & "</font></td>"

                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""40%""    align=""left"">"
                    'ProductDesc_Get_I(ByVal strPart_No,ByRef p_strProduct_Desc,ByRef Hold_status)
                    'Jackie add 01/23/2006 for hold on issue
                    Dim Hold_status As Boolean = False
                    Dim p_strProduct_Desc As String = ""
                    exeFunc = ProductDesc_Get_I(iDataTable.Rows(intX).Item("part_no"), p_strProduct_Desc, Hold_status)
                    If Hold_status = True Then
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & iDataTable.Rows(intX).Item("product_desc") & "</font>" & "<b><font color='red'>&nbsp;&nbsp;(On-Hold)</font></b>"
                    Else
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & iDataTable.Rows(intX).Item("product_desc") & "</font>"
                    End If
                    '--{2005-8-22}--Daive: Create a Promotion Flag in description
                    '---------------------------------------------------------------------------------------------------------
                    'If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(HttpContext.Current.Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(HttpContext.Current.Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                    If Global_Inc.PromotionRelease() = True Then
                        Dim PromotionFlagSQL As String = ""
                        Dim PromotionFlagDatareader As DataTable
                        PromotionFlagSQL = "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE < '" & Date.Now().Date & "' and EXPIRE_DATE >= '" & Date.Now().Date & "' and PART_NO='" & UCase(iDataTable.Rows(intX).Item("part_no")) & "' and Status='Yes'"
                        PromotionFlagDatareader = dbUtil.dbGetDataTable("B2B", PromotionFlagSQL)
                        If PromotionFlagDatareader.Rows.Count > 0 Then
                            l_strHTML3 = l_strHTML3 & "<br><font color=""#FF8C00""><b>(Promotion Item)</b></font>"
                        End If
                        'g_adoConn.Close()
                    End If
                    'Jackie add 2007/03/28
                    If iDataTable.Rows(intX).Item("part_no").ToString.ToUpper.Trim.IndexOf("AGS-EW-") = 0 And intX < 100 Then
                        l_strHTML3 = l_strHTML3 & "<br><b> For Line" & iDataTable.Rows(intX - 1).Item("line_no").ToString.Trim & ", P/N=" & iDataTable.Rows(intX - 1).Item("part_no").ToString.Trim & "</b>"
                    End If
                    '---------------------------------------------------------------------------------------------------------
                    l_strHTML3 = l_strHTML3 & "</td>"
                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""center"">"

                    If IsGA(HttpContext.Current.Session("company_id")) Then
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">To be confirmed within 3 days</font></td>"
                    Else
                        If Global_Inc.FormatDate(iDataTable.Rows(intX).Item("due_date")) = "2020/10/10" Then
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;TBD</font></td>"
                        Else
                            '--jan add 2009-1-9
                            If iDataTable.Rows(intX).Item("NoATPFlag") = "Y" Then
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(iDataTable.Rows(intX).Item("due_date")) & "<br><font color=""#ff0000"">&nbsp;for reference only</font></font></td>"
                            Else
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(iDataTable.Rows(intX).Item("due_date")) & "</font></td>"
                            End If


                        End If
                    End If
                    If iDataTable.Rows(intX).Item("required_date") = iDataTable.Rows(intX).Item("due_date") Then
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%"" align =""center"">"
                    Else
                        l_strHTML3 = l_strHTML3 & "<td width=""10%"" align =""center"" style=""BACKGROUND-COLOR: #ffcccc"">"
                    End If
                    '---- { 24-11-04 } MARK REAL REQ DATE (flgGenunieReq)
                    l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & flgGenunieReq & Global_Inc.FormatDate(iDataTable.Rows(intX).Item("required_date")) & "</font></td>"
                    If Global_Inc.C_ShowRoHS = True Then
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If iDataTable.Rows(intX).Item("RoHS").ToUpper = "Y" Then
                            l_strHTML3 = l_strHTML3 & "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/></td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                        End If
                    End If

                    '<dmf_flag>
                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                    If iDataTable.Rows(intX).Item("DMF_Flag").ToUpper <> "" Then
                        l_strHTML3 = l_strHTML3 & "<Input type='checkbox' checked='checked' disabled='disabled'></td>"
                    Else
                        l_strHTML3 = l_strHTML3 & "<Input type='checkbox' disabled='disabled'></td>"
                    End If
                    '</dmf_flag>

                    '--Class
                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                    If iDataTable.Rows(intX).Item("Class").ToUpper = "A" Or iDataTable.Rows(intX).Item("Class").ToUpper = "B" Then
                        l_strHTML3 = l_strHTML3 & "<img  alt=""RoHs"" src=""../Images/Hot-Orange.gif""/></td>"
                    Else
                        l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                    End If
                    '-- Extended Warranty 'Jackie 2007/03/28
                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                    If iDataTable.Rows(intX).Item("part_no").ToUpper.ToString.Trim.IndexOf("AGS-EW-") = 0 Or _
                        iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "" Or _
                        iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "00" Or _
                        iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "0" Then
                        l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                    Else
                        'l_strHTML3 = l_strHTML3 & iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim & "&nbsp;</td>"
                        l_strHTML3 = l_strHTML3 & "<font color='red'>" & iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim & "&nbsp;M(s)" & "&nbsp;</td>"
                    End If

                    l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                    l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & iDataTable.Rows(intX).Item("qty") & "</font></td>"
                    If iDataTable.Rows(intX).Item("unit_price") <= 0 Then
                        fltSubTotal = fltSubTotal + 0
                        flgStdTBD = "Yes"
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""right"">&nbsp;TBD</font></td>"
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;TBD</font></td>"
                        fltBTOSTotal = fltBTOSTotal + 0
                    Else
                        fltSubTotal = fltSubTotal + iDataTable.Rows(intX).Item("qty") * iDataTable.Rows(intX).Item("unit_price")
                        l_strHTML3 = l_strHTML3 & "<td  bgcolor=""#FFFFFF""width=""10%""   align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(iDataTable.Rows(intX).Item("unit_price"), 2) & "</font></td>"
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(iDataTable.Rows(intX).Item("unit_price") * iDataTable.Rows(intX).Item("qty"), 2) & "</font></td>"
                    End If
                    l_strHTML3 = l_strHTML3 & "</tr>"

                    '--{2005-8-15}--Daive: when promotion item CART QTY is larger than ATP, then give customer a messange.
                    '---------------------------------------------------------------------------------------------------------
                    'Dim g_adoConn1 As New SqlClient.SqlConnection
                    'Dim g_adoConn2 As New SqlClient.SqlConnection
                    'Dim g_adoConn3 As New SqlClient.SqlConnection
                    'If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(HttpContext.Current.Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(HttpContext.Current.Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                    If Global_Inc.PromotionRelease() = True Then
                        Dim P_l_adoDR1 As DataTable = dbUtil.dbGetDataTable("B2B", "select PART_NO,QTY from LOGISTICS_DETAIL where PART_NO='" & UCase(iDataTable.Rows(intX).Item("part_no")) & "' and LOGISTICS_ID='" & HttpContext.Current.Session("CART_ID") & "'")
                        Dim P_l_adoDR2 As DataTable = dbUtil.dbGetDataTable("B2B", "select PART_NO,QTY from CART_DETAIL where PART_NO='" & UCase(iDataTable.Rows(intX).Item("part_no")) & "' and CART_ID='" & HttpContext.Current.Session("CART_ID") & "'")
                        Dim P_OnHand_DR5 As DataTable = dbUtil.dbGetDataTable("B2B", "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE < '" & Now().Date & "' and EXPIRE_DATE >= '" & Now().Date & "' and PART_NO='" & UCase(iDataTable.Rows(intX).Item("part_no")) & "'")
                        If P_l_adoDR1.Rows.Count > 0 And P_l_adoDR2.Rows.Count > 0 Then
                            If CDbl(P_l_adoDR1.Rows(0).Item("QTY")) <> CDbl(P_l_adoDR2.Rows(0).Item("QTY")) Then
                                If P_OnHand_DR5.Rows.Count > 0 Then
                                    l_strHTML3 = l_strHTML3 & "<tr>"
                                    l_strHTML3 = l_strHTML3 & "<td colspan=2 align =""left"" bgcolor=""#FFFFFF"">"
                                    l_strHTML3 = l_strHTML3 & "&nbsp;"
                                    l_strHTML3 = l_strHTML3 & "</td>"
                                    l_strHTML3 = l_strHTML3 & "<td colspan=7 align =""left"" bgcolor=""#FFFFFF"">"
                                    l_strHTML3 = l_strHTML3 & "<font color=""red""><b>The other customer has just consumed some ATP of item " & P_OnHand_DR5.Rows(0).Item("PART_NO") & " .We apologize for making your inconvenience.</b></font>"
                                    l_strHTML3 = l_strHTML3 & "</td>"
                                    l_strHTML3 = l_strHTML3 & "</tr>"
                                End If

                                Dim l_adoConn1 As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
                                Dim l_sqlCmd1 As System.Data.SqlClient.SqlCommand
                                l_adoConn1.Open()
                                l_sqlCmd1 = New System.Data.SqlClient.SqlCommand("update CART_DETAIL set QTY='" & _
                                P_l_adoDR1.Rows(0).Item("QTY") & "' where CART_ID='" & _
                                HttpContext.Current.Session("CART_ID") & "' and PART_NO='" & _
                                P_l_adoDR1.Rows(0).Item("PART_NO") & "'", l_adoConn1)

                                l_sqlCmd1.ExecuteNonQuery()
                                l_adoConn1.Close()
                                l_adoConn1.Dispose()
                            End If
                        End If
                        'g_adoConn.Close()
                    End If

                    '---------------------------------------------------------------------------------------------------------
                Else
                    flgBTOSExist = "Yes"
                    ' ===============Jackie.Wu add account view alert message 12/27/2005
                    '				dim bto_alert,accout_flg
                    '				account_flg = true
                    '				bto_alert = ""
                    If flg_count < 2 Then
                        If Global_Inc.CheckBTOSConfirmOrder(HttpContext.Current.Session("LOGISTICS_ID")) = False Then
                            account_flg = False
                            bto_alert = "<font color='red'>" & "Have no accounting view." & "</font>"
                        End If
                    End If
                    '				account_flg = false
                    '				bto_alert = "<font color='red'>" & "Have no accounting view. " & "</font>"
                    flg_count = flg_count + 1
                    ' ===============
                    If InStr(iDataTable.Rows(intX).Item("part_no"), "CTO") Then
                        flgCTOSExist = "Yes"
                    End If
                    If iDataTable.Rows(intX).Item("line_no") Mod 100 = 0 Then
                        Dim l_strSQLCmdSum As String = ""
                        Dim l_adoDTSum As DataTable
                        l_strSQLCmdSum = "select " & _
                            "max(b.due_date) as BTOItemDueDate, " & _
                            "sum(b.unit_price) as BTOItemSum, " & _
                            "sum(b.unit_price * b.qty) as BTOItemTotalSum " & _
                            "from logistics_master a " & _
                            "inner join logistics_detail b " & _
                            "on a.logistics_id = b.logistics_id " & _
                            "where " & _
                            "a.logistics_id = '" & strPIId & "' and " & _
                            "len(b.line_no) >=3 and " & _
                            "left(b.line_no,1) = left(" & iDataTable.Rows(intX).Item("line_no") & ",1) and " & _
                            "b.unit_price >= 0"
                        'HttpContext.Current.Response.Write(l_strSQLCmdSum)

                        l_adoDTSum = dbUtil.dbGetDataTable("B2B", l_strSQLCmdSum)
                        Dim dtBTOItemDueDate As String = ""
                        Dim fltBTOItemSum As Decimal = 0
                        Dim fltBTOItemTotalSum As Decimal = 0
                        If l_adoDTSum.Rows.Count > 0 Then
                            dtBTOItemDueDate = l_adoDTSum.Rows(0).Item("BTOItemDueDate")
                            fltBTOItemSum = l_adoDTSum.Rows(0).Item("BTOItemSum")
                            fltBTOItemTotalSum = l_adoDTSum.Rows(0).Item("BTOItemTotalSum")
                        Else
                            fltBTOItemSum = 0
                            fltBTOItemTotalSum = 0
                        End If
                        'g_adoConn.Close()
                        '**** 300304Emil Revise for Geveke Alert ****'
                        'If DateDiff("d",CDate(l_adoRs("due_date")),date()) > 10 Then
                        l_strHTML3 = l_strHTML3 & "<tr style=""font-weight: bold;BACKGROUND-COLOR: #ffcccc;WIDTH=100%"">"
                        'Else	
                        '	l_strHTML3 = l_strHTML3 & "<tr style=""font-weight: bold;BACKGROUND-COLOR: #ffffcc;WIDTH=100%"">" 
                        'End If
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""Center"">"
                        If flgCTOSExist = "Yes" Then
                            l_strHTML3 = l_strHTML3 & "<font color=""BLUE"">BTOS<br>(CTOS)</font>"
                        Else
                            l_strHTML3 = l_strHTML3 & "<font color=""BLUE"">BTOS</font>"
                        End If
                        '--{2005-8-22}--Daive: Create a Promotion Flag in description
                        '---------------------------------------------------------------------------------------------------------
                        'If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(HttpContext.Current.Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(HttpContext.Current.Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                        If Global_Inc.PromotionRelease() = True Then
                            Dim PromotionFlag_DR As DataTable
                            PromotionFlag_DR = dbUtil.dbGetDataTable("B2B", "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE < '" & Date.Now().Date & "' and EXPIRE_DATE >= '" & Date.Now().Date & "' and Status='Yes' and PART_NO in (select PART_NO from CART_DETAIL where LINE_NO='999' and CART_ID='" & HttpContext.Current.Session("CART_ID") & "')")
                            If PromotionFlag_DR.Rows.Count > 0 Then
                                l_strHTML3 = l_strHTML3 & "<br><font color=""#FF8C00""><b>(Promotion Item)</b></font>"
                            End If
                            'g_adoConn.Close()
                        End If
                        '---------------------------------------------------------------------------------------------------------
                        l_strHTML3 = l_strHTML3 & "</td>"
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""3%""  align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & iDataTable.Rows(intX).Item("line_no") & "</font></td>"
                        'bto_alert = ""
                        '**** 22-06-04 Emil Revised for "U" code ****'
                        If iDataTable.Rows(intX).Item("auto_order_flag") = "U" Then
                            l_strHTML3 = l_strHTML3 & "<td width=""17%"" style=""BACKGROUND-COLOR: #ffcccc""  align=""left"">"
                        Else
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""17%""  align=""left"">"
                        End If
                        'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & UCase(l_adoRs("part_no")) & "</font></td>"
                        If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & UCase(iDataTable.Rows(intX).Item("part_no")) & "' >" & UCase(iDataTable.Rows(intX).Item("part_no")) & "</a></font><br>" & bto_alert & "</td>" ' add account_view alert
                            bto_alert = ""
                        Else
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & UCase(iDataTable.Rows(intX).Item("part_no")) & "</font></td>"
                        End If
                        '--CustomerPN
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""17%""  align=""left"">"
                        'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & UCase(getCustomerNo(HttpContext.Current.Session("Company_id"), iDataTable.Rows(intX).Item("part_no"))) & "</font></td>"

                        'bto_alert = ""
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""40%""   align=""left"" >"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & iDataTable.Rows(intX).Item("product_desc") & "</font></td>"
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""center"">"
                        If IsGA(HttpContext.Current.Session("company_id")) Then
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">To be confirmed within 3 days</font></td>"
                        Else
                            '--jan add 2009-1-9
                            Dim NoATPFlag As String = "N"
                            For i As Integer = 0 To iDataTable.Rows.Count - 1
                                If iDataTable.Rows(i).Item("NoATPFlag") = "Y" Then
                                    NoATPFlag = "Y"
                                End If
                            Next
                            If NoATPFlag = "Y" Then
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(iDataTable.Rows(intX).Item("due_date")) & "<br><font color=""#ff0000"">&nbsp;for reference only</font></font></td>"
                            Else
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(iDataTable.Rows(intX).Item("due_date")) & "</font></td>"
                            End If

                        End If

                        If iDataTable.Rows(intX).Item("required_date") = iDataTable.Rows(intX).Item("due_date") Then
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%"" align =""center"">"
                        Else
                            l_strHTML3 = l_strHTML3 & "<td width=""10%"" align =""center"" style=""BACKGROUND-COLOR: #ffcccc"">"
                        End If
                        '---- { 24-11-04 } MARK REAL REQ DATE (flgGenunieReq)
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & flgGenunieReq & Global_Inc.FormatDate(iDataTable.Rows(intX).Item("required_date")) & "</font></td>"
                        If Global_Inc.C_ShowRoHS = True Then
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                            If iDataTable.Rows(intX).Item("RoHS").ToUpper = "Y" Then
                                l_strHTML3 = l_strHTML3 & "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/></td>"
                            Else
                                l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                            End If
                        End If

                        '<dmf_flag>
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If iDataTable.Rows(intX).Item("DMF_Flag").ToUpper <> "" Then
                            l_strHTML3 = l_strHTML3 & "<Input type='checkbox' checked='checked' disabled='disabled'></td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "<Input type='checkbox' disabled='disabled'></td>"
                        End If
                        '</dmf_flag>
                        '--Class
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If iDataTable.Rows(intX).Item("Class").ToUpper = "A" Or iDataTable.Rows(intX).Item("Class").ToUpper = "B" Then
                            l_strHTML3 = l_strHTML3 & "<img  alt=""RoHs"" src=""../Images/Hot-Orange.gif""/></td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                        End If
                        '-- Extended Warranty 'Jackie 2007/03/28 for btos parent item
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        If iDataTable.Rows(intX).Item("part_no").ToUpper.ToString.Trim.IndexOf("AGS-EW-") = 0 Or _
                            iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "" Or _
                            iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "00" Or _
                            iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "0" Then
                            l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "<font color='red'><b>" & iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim & "&nbsp;M</b>(s)" & "&nbsp;</td>"
                        End If

                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & iDataTable.Rows(intX).Item("qty") & "</font></td>"
                        Dim AverPrice As Decimal = 0
                        If fltBTOItemSum <= 0 Then
                            fltBTOSTotal = fltBTOSTotal + 0
                            flgBtosTBD = "Yes"
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""right"">&nbsp;TBD</font></td>"
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;TBD</font></td>"
                        Else
                            fltBTOSTotal = CDec(fltBTOSTotal) + CInt(iDataTable.Rows(intX).Item("qty")) * CDec(iDataTable.Rows(intX).Item("unit_price"))
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                            AverPrice = fltBTOItemTotalSum / CInt(iDataTable.Rows(intX).Item("qty"))
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(CDbl(AverPrice), 2) & "</font></td>"
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(fltBTOItemTotalSum, 2) & "</font></td>"
                        End If
                        '--{2005-8-15}--Daive: when promotion item CART QTY is larger than ATP, then give customer a messange.
                        '---------------------------------------------------------------------------------------------------------
                        'Dim g_adoConn1 As New SqlClient.SqlConnection
                        'Dim g_adoConn2 As New SqlClient.SqlConnection
                        'Dim g_adoConn3 As New SqlClient.SqlConnection
                        'If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(HttpContext.Current.Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(HttpContext.Current.Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                        If Global_Inc.PromotionRelease() = True Then
                            Dim P_l_adoDR3 As DataTable = dbUtil.dbGetDataTable("B2B", "select PART_NO,QTY from LOGISTICS_DETAIL where LINE_NO='" & UCase(iDataTable.Rows(intX).Item("line_no")) & "' and LOGISTICS_ID='" & HttpContext.Current.Session("CART_ID") & "'")
                            Dim P_l_adoDR4 As DataTable = dbUtil.dbGetDataTable("B2B", "select PART_NO,QTY from CART_DETAIL where LINE_NO='" & UCase(iDataTable.Rows(intX).Item("line_no")) & "' and CART_ID='" & HttpContext.Current.Session("CART_ID") & "'")
                            Dim P_OnHand_DR6 As DataTable = dbUtil.dbGetDataTable("B2B", "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE < '" & Now().Date & "' and EXPIRE_DATE >= '" & Now().Date & "' and PART_NO in (select PART_NO from CART_DETAIL where LINE_NO='999' and CART_ID='" & HttpContext.Current.Session("CART_ID") & "')")
                            If P_l_adoDR3.Rows.Count > 0 And P_l_adoDR4.Rows.Count > 0 Then
                                If P_l_adoDR3.Rows(0).Item("QTY") <> P_l_adoDR4.Rows(0).Item("QTY") Then
                                    l_strHTML3 = l_strHTML3 & "<tr>"
                                    l_strHTML3 = l_strHTML3 & "<td colspan=2 align =""left"">"
                                    l_strHTML3 = l_strHTML3 & "&nbsp;"
                                    l_strHTML3 = l_strHTML3 & "</td>"
                                    l_strHTML3 = l_strHTML3 & "<td colspan=7 align =""left"">"
                                    l_strHTML3 = l_strHTML3 & "<font color=""red""><b>The other customer has just consumed ATP of item " & P_OnHand_DR6.Rows(0).Item("PART_NO") & " .We apologize for making your inconvenience.</b></font>"
                                    l_strHTML3 = l_strHTML3 & "</td>"
                                    l_strHTML3 = l_strHTML3 & "</tr>"

                                    Dim l_adoConn2 As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
                                    Dim l_sqlCmd2 As System.Data.SqlClient.SqlCommand
                                    l_adoConn2.Open()
                                    l_sqlCmd2 = New System.Data.SqlClient.SqlCommand("update CART_DETAIL set QTY='" & P_l_adoDR3.Rows(0).Item("QTY") & "' where CART_ID='" & HttpContext.Current.Session("CART_ID") & "'", l_adoConn2)
                                    l_sqlCmd2.ExecuteNonQuery()
                                    l_adoConn2.Close()
                                    l_adoConn2.Dispose()
                                End If
                            End If
                            'g_adoConn.Close()
                        End If
                        'g_adoConn1.Close()
                        'g_adoConn1.Dispose()
                        'g_adoConn2.Close()
                        'g_adoConn1.Dispose()
                        'g_adoConn3.Close()
                        'g_adoConn1.Dispose()
                        '---------------------------------------------------------------------------------------------------------
                    Else
                        If iDataTable.Rows(intX).Item("unit_price") <= 0 Then
                            l_strHTML3 = l_strHTML3 & "<tr style=""BACKGROUND-COLOR: #ccffff;WIDTH=100%"">"
                        Else
                            l_strHTML3 = l_strHTML3 & "<tr>"
                        End If
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;</font></td>"
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""3%""  align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & iDataTable.Rows(intX).Item("line_no") & "</font></td>"
                        '**** 22-06-04 Emil Revised for "U" code ****'
                        If iDataTable.Rows(intX).Item("auto_order_flag") = "U" Then
                            l_strHTML3 = l_strHTML3 & "<td width=""17%"" style=""BACKGROUND-COLOR: #ffcccc"" align=""left"">"
                        Else
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""17%"" align=""left"">"
                        End If
                        If Util.IsInternalUser2() Or Util.IsAEUIT() Then

                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;<a TARGET='_BLANK' href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" & UCase(iDataTable.Rows(intX).Item("part_no")) & "' >" & UCase(iDataTable.Rows(intX).Item("part_no")) & "</a></font></td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & UCase(iDataTable.Rows(intX).Item("part_no")) & "</font></td>"

                        End If

                        '--CustomerPN
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""17%""  align=""left"">"
                        'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & UCase(getCustomerNo(HttpContext.Current.Session("Company_id"), iDataTable.Rows(intX).Item("part_no"))) & "</font></td>"


                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""40%""   colspan=""3"" align=""left"">"
                        '--{2005-9-26}--Daive: Set Extended Warranty Description
                        '----------------------------------------------------------------
                        If InStr(UCase(iDataTable.Rows(intX).Item("part_no")), "S-WARRANTY") <> 0 And BtosOrderCheck() = 1 Then
                            Dim EW_DescDR As DataTable
                            Dim strEWSQL As String = ""
                            strEWSQL = "Select CATEGORY_DESC from CONFIGURATION_CATALOG_CATEGORY where CATALOG_ID = '" & HttpContext.Current.Session("G_CATALOG_ID") & "' and CATEGORY_ID = '" & iDataTable.Rows(intX).Item("part_no") & "' and CATEGORY_TYPE = 'Component'"
                            EW_DescDR = dbUtil.dbGetDataTable("B2B", strEWSQL)
                            '---------{2005-10-24}--Jackie: get quotation ew_description
                            If EW_DescDR.Rows.Count > 0 Then
                                '-----------------------------------------------------
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & EW_DescDR.Rows(0).Item("CATEGORY_DESC") & "</font></td>"
                                '-----------------------------------------------------
                            Else
                                Dim EW_DescDR_Quote As DataTable

                                strEWSQL = "Select CATEGORY_DESC from QUOTATION_CATALOG_CATEGORY where CATALOG_ID = '" & HttpContext.Current.Session("G_CATALOG_ID") & "' and CATEGORY_ID = '" & iDataTable.Rows(intX).Item("part_no") & "' and CATEGORY_TYPE = 'Component'"
                                'Dim sqlConn As SqlClient.SqlConnection = Nothing
                                EW_DescDR_Quote = dbUtil.dbGetDataTable("B2B", strEWSQL)
                                'sqlConn.Close()
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & EW_DescDR_Quote.Rows(0).Item("CATEGORY_DESC") & "</font></td>"

                            End If
                            'g_adoConn.Close()
                            '-----------------------------------------------------				
                        Else
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & iDataTable.Rows(intX).Item("product_desc") & "</font></td>"
                        End If
                        'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & l_adoRs("product_desc") & "</font></td>"
                        'l_strHTML3 = l_strHTML3 & "<td width=""10%""   align =""center"">"
                        'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & FormatDate(l_adoRs("due_date")) & "</font></td>"
                        If Global_Inc.C_ShowRoHS = True Then
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                            If iDataTable.Rows(intX).Item("RoHS").ToUpper = "Y" Then
                                l_strHTML3 = l_strHTML3 & "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/></td>"
                            Else
                                l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                            End If
                        End If

                        '<dmf_flag>
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If iDataTable.Rows(intX).Item("DMF_Flag").ToUpper <> "" Then
                            l_strHTML3 = l_strHTML3 & "<Input type='checkbox' checked='checked' disabled='disabled'></td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "<Input type='checkbox' disabled='disabled'></td>"
                        End If
                        '</dmf_flag>
                        '--Class
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If iDataTable.Rows(intX).Item("Class").ToUpper = "A" Or iDataTable.Rows(intX).Item("Class").ToUpper = "B" Then
                            l_strHTML3 = l_strHTML3 & "<img  alt=""RoHs"" src=""../Images/Hot-Orange.gif""/></td>"
                        Else
                            l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                        End If
                        '-- Extended Warranty 'Jackie 2007/03/28 for btos component
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        If iDataTable.Rows(intX).Item("part_no").ToUpper.ToString.Trim.IndexOf("AGS-EW-") = 0 Or _
                            iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "" Or _
                            iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "00" Or _
                            iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim = "0" Then
                            l_strHTML3 = l_strHTML3 & "&nbsp;</td>"
                        Else
                            'l_strHTML3 = l_strHTML3 & iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim & "&nbsp;</td>"
                            l_strHTML3 = l_strHTML3 & "<font color='red'>" & iDataTable.Rows(intX).Item("Exwarranty_flag").ToUpper.ToString.Trim & "&nbsp;M(s)" & "&nbsp;</td>"
                        End If
                        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & iDataTable.Rows(intX).Item("qty") & "</font></td>"
                        If iDataTable.Rows(intX).Item("unit_price") <= 0 Then
                            fltBTOSTotal = CDec(fltBTOSTotal) + 0
                            flgBtosTBD = "Yes"
                            'l_strHTML3 = l_strHTML3 & "<td bgcolor=""FFFFFF"" width=""10%""   align =""left"" colspan=""2"">"
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""left"">"
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"" >&nbsp;(TBD)</font></td>"
                            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""left"">"
                            l_strHTML3 = l_strHTML3 & "<font color=""#333333"" >&nbsp;(TBD)</font></td>"
                        Else
                            fltBTOSTotal = CDec(fltBTOSTotal) + FormatNumber(CInt(iDataTable.Rows(intX).Item("qty")) * CDec(iDataTable.Rows(intX).Item("unit_price")), 2)
                            'l_strHTML3 = l_strHTML3 & "<td bgcolor=""FFFFFF"" width=""10%""   align =""right"" colspan=""2"">"

                            '----------------- this should add SA judge condition ----------------------------------------
                            If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                                l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;</font></td>"
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(iDataTable.Rows(intX).Item("unit_price"), 2) & "</font></td>"
                                l_strHTML3 = l_strHTML3 & "<td width=""15%"" bgcolor=""#FFFFFF""  align =""right"">"
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(iDataTable.Rows(intX).Item("unit_price") * iDataTable.Rows(intX).Item("qty"), 2) & "</font></td>"
                            Else
                                l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">&nbsp;</font></td>"
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""right""></font></td>"
                                l_strHTML3 = l_strHTML3 & "<td width=""15%"" bgcolor=""#FFFFFF""  align =""right"">"
                                l_strHTML3 = l_strHTML3 & "<font color=""#333333""></font></td>"
                            End If
                        End If
                        l_strHTML3 = l_strHTML3 & "</tr>"
                    End If
                End If
                intX = intX + 1
            Loop
        End If


        fltTotal = CDec(fltSubTotal) + CDec(fltBTOSTotal)
        '--{2006-08-21}-Daive: For Component Order, Show SubTotal, Extennded Warranty Fee and Total
        '--SubTotal
        'If Global_Inc.IsB2BOwner(HttpContext.Current.Session("user_id")) Or LCase(HttpContext.Current.Session("user_id")) = "sabine.lin@advantech.fr" Then 
        ' Jackie 20070117
        If 1 <> 1 Then
            Dim EWdt As DataTable
            EWdt = dbUtil.dbGetDataTable("B2B", _
                " select distinct Line_No as [Line No.]," + _
                "    Part_No as [Part No.]," + _
                "    QTY as [Qty]," + _
                "    exwarranty_flag as [Extended Months]," + _
                "    [Extended Warranty Fee] = " + _
                "    case when IsNull(EXWARRANTY_FLAG,'00') = '03' then" + _
                "            (Unit_Price * QTY * 1.25 / 100) " + _
                "         when IsNull(EXWARRANTY_FLAG,'00') = '06' then" + _
                "            (Unit_Price * QTY * 2.50 / 100) " + _
                "         when IsNull(EXWARRANTY_FLAG,'00') = '12' then" + _
                "            (Unit_Price * QTY * 5.00 / 100) " + _
                "         when IsNull(EXWARRANTY_FLAG,'00') = '24' then" + _
                "            (Unit_Price * QTY * 8.00 / 100) " + _
                "         when IsNull(EXWARRANTY_FLAG,'00') = '36' then" + _
                "            (Unit_Price * QTY * 12.00 / 100) " + _
                "    End" + _
                " from logistics_detail " + _
                " where exwarranty_flag>0 and logistics_id='" + strPIId + "'")
            'jackie revise 2006/8/31
            '" where line_no<100 and exwarranty_flag>0 and logistics_id='" + strPIId + "'")
            If EWdt.Rows.Count > 0 Then
                l_strHTML3 = l_strHTML3 & "<tr>"
                l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" colspan=""9""  align =""right"">"
                If fltTotal <= 0 Then
                    l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>(" & strCurrency & ") SubTotal:&nbsp;TBD</b></font></td>"
                Else
                    If flgStdTBD = "Yes" Or flgBtosTBD = "Yes" Then
                        l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>(" & strCurrency & ") SubTotal:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & " + TBD</b></font></td>"
                    Else
                        l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>(" & strCurrency & ") SubTotal:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & "</b></font></td>"
                    End If
                End If
                l_strHTML3 = l_strHTML3 & "</tr>"
                '--Extennded Warranty Fee
                Dim iEWFee As Decimal
                For iEW As Integer = 0 To EWdt.Rows.Count - 1
                    iEWFee = iEWFee + CDec(EWdt.Rows(iEW).Item(4))
                Next
                l_strHTML3 = l_strHTML3 & "<tr>"
                l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" colspan=""9""  align =""right"">"
                If iEWFee <= 0 Then
                    l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>(" & strCurrency & ") Extennded Warranty Fee:&nbsp;TBD</b></font></td>"
                Else
                    l_strHTML3 = l_strHTML3 & "<font colspan=""9"" color=""#333333""><b>(" & strCurrency & ") Extennded Warranty Fee:&nbsp;" & strCurrSign & FormatNumber(iEWFee, 2) & "</b></font></td>"
                End If
                l_strHTML3 = l_strHTML3 & "</tr>"
                fltTotal = fltTotal + iEWFee
            End If
        End If
        '----End-----
        l_strHTML3 = l_strHTML3 & "<tr>"
        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" colspan=""10""  align =""right"">"
        If fltTotal <= 0 Then
            l_strHTML3 = l_strHTML3 & "<font colspan=""10"" color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;TBD</b></font></td>"
        Else
            If flgStdTBD = "Yes" Or flgBtosTBD = "Yes" Then
                l_strHTML3 = l_strHTML3 & "<font colspan=""10"" color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & " + TBD</b></font></td>"
            Else
                l_strHTML3 = l_strHTML3 & "<font colspan=""10"" color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & "</b></font></td>"
            End If
        End If

        If Global_Inc.C_ShowRoHS = True Then l_strHTML3 = Replace(l_strHTML3, "colspan=""10""", "colspan=""14""")

        l_strHTML3 = l_strHTML3 & "</tr>"
        l_strHTML3 = l_strHTML3 & "</table>"
        'l_strHTML3 = l_strHTML3 & "</td></tr></table>"
        l_strHTML3 = l_strHTML3 & "</td></tr></table>"

        '---- main part
        '---- prepare company info
        l_strSQLCmd = "select distinct " & _
            "c.userid, " & _
            "(IsNull(c.first_name,'') + ' ' + IsNull(c.last_name,'')) as full_name," & _
            "IsNull(c.tel_no,'') as tel_no, " & _
            "IsNull(c.tel_ext,'') as tel_ext " & _
            "from logistics_master a " & _
            "inner join company_contact b " & _
            "on a.soldto_id = b.company_id " & _
            "inner join user_info c " & _
            "on b.userid = c.userid " & _
            "where a.logistics_id = '" & strPIId & "'  and b.role like 'SA%' order by tel_no,tel_ext"

        Dim ContactDataTable As DataTable
        ContactDataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        'Response.End

        l_strHTML = l_strHTML & "<html><body><center>"
        'l_strHTML = l_strHTML & "<link href=""http://b2b.advantech.eu/includes/layout/eBizStyle.css"" rel=""stylesheet"">"
        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td colspan=""3"" height=""30"">"
        l_strHTML = l_strHTML & "&nbsp;</td></tr>"
        l_strHTML = l_strHTML & "<tr><td valign=""top"" align=""left"">"
        l_strHTML = l_strHTML & "<div class=""euPageTitle"">Proforma Invoice Preview</div></td>"
        l_strHTML = l_strHTML & "<td width=""200"">"
        l_strHTML = l_strHTML & "</td>"
        l_strHTML = l_strHTML & "<td align=""right"">"
        l_strHTML = l_strHTML & "<b>Advantech Europe BV</b><br>"
        l_strHTML = l_strHTML & "Ekkersrijt 5708, 5692 Ep Son, The Netherlands " & "<br>"
        l_strHTML = l_strHTML & "Tel: +31 (0) 40 26 77 000&nbsp;&nbsp;Fax: +31 (0) 40 26 77 001" & "<br>"
        Dim intCount As Integer = 0
        Dim strUserId As String = ""
        Dim strUserName As String = ""
        Dim strTelExt As String = ""
        Dim strTelNo As String = ""
        Do While intCount <= ContactDataTable.Rows.Count - 1
            strUserId = ContactDataTable.Rows(intCount).Item("userid")
            strUserName = ContactDataTable.Rows(intCount).Item("full_name")
            strTelExt = ContactDataTable.Rows(intCount).Item("tel_ext")
            strTelNo = ContactDataTable.Rows(intCount).Item("tel_no")
            If intCount = 1 Then
                l_strHTML = l_strHTML & "Contact: "
            Else
                l_strHTML = l_strHTML & "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
            End If
            l_strHTML = l_strHTML & "<a href=""mailto:" & strUserId & """>" & strUserName & "</a>" & "&nbsp;(" & strTelNo & "+" & strTelExt & ")"
            If intCount Mod 2 = 0 Then
                l_strHTML = l_strHTML & "<br>"
            Else
                l_strHTML = l_strHTML & "<br>"
            End If
            intCount = intCount + 1
        Loop
        l_strHTML = l_strHTML & "</td></tr>"
        l_strHTML = l_strHTML & "</table><br>"
        l_strHTML = l_strHTML & l_strHTML1 & "<br>"
        l_strHTML = l_strHTML & l_strHTML2 & "<br>"
        l_strHTML = l_strHTML & l_strHTML3 & "<br>"
        l_strHTML = l_strHTML & "</center></body></html>"
        p_strHTML = l_strHTML
        GetPIPreview = 1
        'g_adoConn.Dispose()
    End Function

    ''================================================================================================='
    ''-------------------------------Function: GetPIPromotionErrorQTYline()----------------------------'
    ''  ByDef promotionErrorFlag                                                                       '
    ''  ByDef strPromotionPartNo                                                                       '
    ''  ByDef PIPromotionErrorQTYlineHTML                                                              '
    ''-------------------------------------------------------------------------------------------------'
    ''        Author: Daive Wang                                                                       '
    ''  Created Date: {2005-8-9}                                                                       '
    ''================================================================================================='
    'Public Shared Function GetPIPromotionErrorQTYline(ByRef promotionErrorFlag As String, ByRef strPromotionPartNo As String, ByRef PIPromotionErrorQTYlineHTML As String) As Integer
    '    'Dim g_adoConn As New SqlClient.SqlConnection
    '    'Pre-ConfigFlag=""
    '    Dim PIPromotionErrorQTYlineHTML1 As String = ""
    '    Dim PIPromotionErrorQTYlineHTML2 As String = ""
    '    Dim PIPromotionErrorQTYlineHTML3 As String = ""
    '    Dim PIPromotionErrorQTYlineHTML4 As String = ""

    '    Dim PromotionCartID As String = HttpContext.Current.Session("CART_ID")

    '    Dim exeFunc As Integer = 0
    '    promotionErrorFlag = "No"

    '    'exeFunc = DBConn_Get("B2BAESC", "B2B", F_PromotionError_adoConn)

    '    '--{2005-8-9}--Daive: Get the Company Currency
    '    Dim Curr_ListDR As DataTable
    '    Curr_ListDR = dbUtil.dbGetDataTable("B2B", "Select CURRENCY from LOGISTICS_MASTER where LOGISTICS_ID='" & PromotionCartID & "'")
    '    Dim xCurrency As String = "&euro;"
    '    If Curr_ListDR.Rows.Count > 0 Then
    '        Select Case Curr_ListDR.Rows(0).Item("CURRENCY")
    '            Case "EUR"
    '                xCurrency = "&euro;"
    '            Case "USD", "US"
    '                xCurrency = "$"
    '            Case "GBP"
    '                xCurrency = "&pound;"
    '            Case Else
    '                xCurrency = "&euro;"
    '        End Select
    '    End If
    '    'Curr_ListDR.Close()
    '    'g_adoConn.Close()
    '    Dim iDataTable As DataTable
    '    Dim xIndex As Integer = 0
    '    iDataTable = dbUtil.dbGetDataTable("B2B", "select LINE_NO,PART_NO,QTY,UNIT_PRICE from LOGISTICS_DETAIL where LOGISTICS_ID='" & PromotionCartID & "' order by LINE_NO ASC")
    '    If iDataTable.Rows.Count > 0 Then
    '        '--{2005-8-9}--Daive: Avoid Promotion Pre-Configuration QTY larger than ONHAND_QTY
    '        If CDbl(iDataTable.Rows(xIndex).Item("LINE_NO")) >= 100 Then
    '            Dim proPromotionProductInfo_ListDR1 As DataTable
    '            proPromotionProductInfo_ListDR1 = dbUtil.dbGetDataTable("B2B", "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE <= '" & Now().Date & "' and EXPIRE_DATE >= '" & Now().Date & "' and status='Yes' and PART_NO in (select PART_NO from CART_DETAIL where LINE_NO='999' and CART_ID='" & PromotionCartID & "')")
    '            If proPromotionProductInfo_ListDR1.Rows.Count > 0 Then
    '                If CDbl(iDataTable.Rows(xIndex).Item("QTY")) > CDbl(proPromotionProductInfo_ListDR1.Rows(0).Item("ONHAND_QTY")) Then

    '                    'Pre_ConfigFlag="Pre-Config"
    '                    strPromotionPartNo = strPromotionPartNo & proPromotionProductInfo_ListDR1.Rows(0).Item("PART_NO") & ","
    '                    xIndex = 0
    '                    Do While xIndex <= iDataTable.Rows.Count - 1
    '                        PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<tr>"
    '                        If CDbl(iDataTable.Rows(xIndex).Item("LINE_NO")) = 100 Then
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""5%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>BTOS</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""3%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("LINE_NO") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""17%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("PART_NO") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""40%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>The other customer has just consumed All ATP of item " & proPromotionProductInfo_ListDR1.Rows(0).Item("PART_NO") & " .We apologize for making your inconvenience.</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""10%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>" & proPromotionProductInfo_ListDR1.Rows(0).Item("ONHAND_QTY") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""10%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("QTY") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""5%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>" & proPromotionProductInfo_ListDR1.Rows(0).Item("ONHAND_QTY") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""10%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>" & xCurrency & FormatNumber(iDataTable.Rows(xIndex).Item("UNIT_PRICE"), 2) & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""15%"" bgcolor=""#ffcccc"" align =""center""><font color=""red""><b>" & xCurrency & FormatNumber(iDataTable.Rows(xIndex).Item("UNIT_PRICE") * proPromotionProductInfo_ListDR1.Rows(0).Item("ONHAND_QTY"), 2) & "</b></font></td>"
    '                        Else
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""5%"" align =""center""><font color=""red""><b>&nbsp;</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""3%"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("LINE_NO") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""17%"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("PART_NO") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""60%"" colspan=""6"" align =""center""><font color=""red""><b>The other customer has just consumed All ATP of item " & proPromotionProductInfo_ListDR1.Rows(0).Item("PART_NO") & " .We apologize for making your inconvenience.</b></font></td>"
    '                            'PIPromotionErrorQTYlineHTML3=PIPromotionErrorQTYlineHTML3 & "<td width=""5%"" align =""center""><font color=""red""><b>"&proPromotionProductInfo_ListRS1("ONHAND_QTY")&"</b></font></td>"
    '                            'PIPromotionErrorQTYlineHTML3=PIPromotionErrorQTYlineHTML3 & "<td width=""25%"" colspan=""2"" align =""center""><font color=""red""><b>&nbsp;</b></font></td>"
    '                        End If

    '                        PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "</tr>"
    '                        xIndex = xIndex + 1
    '                    Loop
    '                    '--{2005-8-9}--Daive: ==Pre-Configuration== if ONHAND_QTY = 0, delete all components
    '                    Dim Error_DBConn1 As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
    '                    Dim Error_Cmd1 As System.Data.SqlClient.SqlCommand
    '                    If CDbl(proPromotionProductInfo_ListDR1.Rows(0).Item("ONHAND_QTY")) = 0 Then
    '                        promotionErrorFlag = "Yes"
    '                        Error_DBConn1.Open()
    '                        Error_Cmd1 = New System.Data.SqlClient.SqlCommand("delete cart_detail where cart_id='" & PromotionCartID & "'", Error_DBConn1)
    '                        Error_Cmd1.ExecuteNonQuery()
    '                        Error_Cmd1 = New System.Data.SqlClient.SqlCommand("delete cart_master where cart_id='" & PromotionCartID & "'", Error_DBConn1)
    '                        Error_Cmd1.ExecuteNonQuery()
    '                        Error_Cmd1 = New System.Data.SqlClient.SqlCommand("delete logistics_detail where logistics_id='" & PromotionCartID & "'", Error_DBConn1)
    '                        Error_Cmd1.ExecuteNonQuery()
    '                        Error_Cmd1 = New System.Data.SqlClient.SqlCommand("delete logistics_master where logistics_id='" & PromotionCartID & "'", Error_DBConn1)
    '                        Error_Cmd1.ExecuteNonQuery()
    '                        Error_DBConn1.Close()
    '                    Else
    '                        Error_DBConn1.Open()
    '                        'F_PromotionError_adoConn.Execute("Update CART_DETAIL set QTY='"&proPromotionProductInfo_ListRS1("ONHAND_QTY")&"' where CART_ID='"&PromotionCartID&"'")
    '                        'F_PromotionError_adoConn.Execute("Update CART_MASTER set QTY='"&proPromotionProductInfo_ListRS1("ONHAND_QTY")&"' where CART_ID='"&PromotionCartID&"'")
    '                        Error_Cmd1 = New System.Data.SqlClient.SqlCommand("Update LOGISTICS_DETAIL set QTY='" & proPromotionProductInfo_ListDR1.Rows(0).Item("ONHAND_QTY") & "' where LOGISTICS_ID='" & PromotionCartID & "'", Error_DBConn1)
    '                        Error_Cmd1.ExecuteNonQuery()
    '                        'F_PromotionError_adoConn.Execute("Update LOGISTICS_MASTER set QTY='"&proPromotionProductInfo_ListRS1("ONHAND_QTY")&"' where LOGISTICS_ID='"&PromotionCartID&"'")
    '                        Error_DBConn1.Close()
    '                    End If
    '                    Error_DBConn1.Dispose()
    '                End If
    '            End If
    '            'g_adoConn.Close()

    '            '--{2005-8-9}--Daive: Avoid Single Item QTY larger than ONHAND_QTY
    '        Else
    '            xIndex = 0
    '            'TotalPrice=0
    '            Do While xIndex <= iDataTable.Rows.Count - 1
    '                Dim proPromotionProductInfo_ListDR2 As DataTable
    '                proPromotionProductInfo_ListDR2 = dbUtil.dbGetDataTable("B2B", "select PART_NO,ONHAND_QTY from PROMOTION_PRODUCT_INFO where START_DATE <= '" & Date.Now().Date & "' and EXPIRE_DATE >= '" & Date.Now().Date & "' and PART_NO='" & iDataTable.Rows(xIndex).Item("PART_NO") & "' and status='Yes'")
    '                If proPromotionProductInfo_ListDR2.Rows.Count > 0 Then
    '                    If CDbl(iDataTable.Rows(xIndex).Item("QTY")) > CDbl(proPromotionProductInfo_ListDR2.Rows(0).Item("ONHAND_QTY")) Then

    '                        'Pre_ConfigFlag="SingleItem"
    '                        strPromotionPartNo = strPromotionPartNo & proPromotionProductInfo_ListDR2.Rows(0).Item("PART_NO") & ","


    '                        Dim Error_DBConn2 As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
    '                        Dim Error_Cmd2 As System.Data.SqlClient.SqlCommand
    '                        '--{2005-8-9}--Daive: ==Single Item== if ONHAND_QTY = 0, Delete this product.
    '                        If CDbl(proPromotionProductInfo_ListDR2.Rows(0).Item("ONHAND_QTY")) = 0 Then
    '                            promotionErrorFlag = "Yes"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<tr>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""5%"" align =""center""><font color=""red""><b>" & xIndex + 1 & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""3%"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("LINE_NO") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""17%"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("PART_NO") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""40%"" align =""center""><font color=""red""><b>The other customer has just consumed All ATP of item " & proPromotionProductInfo_ListDR2.Rows(0).Item("PART_NO") & " .We apologize for making your inconvenience.</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""10%"" align =""center""><font color=""red""><b>" & proPromotionProductInfo_ListDR2.Rows(0).Item("ONHAND_QTY") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""10%"" align =""center""><font color=""red""><b>" & iDataTable.Rows(xIndex).Item("QTY") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""5%"" align =""center""><font color=""red""><b>" & proPromotionProductInfo_ListDR2.Rows(0).Item("ONHAND_QTY") & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""10%"" align =""center""><font color=""red""><b>" & xCurrency & FormatNumber(iDataTable.Rows(xIndex).Item("UNIT_PRICE"), 2) & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "<td width=""15%"" align =""center""><font color=""red""><b>" & xCurrency & FormatNumber(iDataTable.Rows(xIndex).Item("UNIT_PRICE") * proPromotionProductInfo_ListDR2.Rows(0).Item("ONHAND_QTY"), 2) & "</b></font></td>"
    '                            PIPromotionErrorQTYlineHTML3 = PIPromotionErrorQTYlineHTML3 & "</tr>"

    '                            Error_DBConn2.Open()
    '                            Error_Cmd2 = New System.Data.SqlClient.SqlCommand("delete cart_detail where cart_id='" & PromotionCartID & "' and PART_NO='" & proPromotionProductInfo_ListDR2.Rows(0).Item("PART_NO") & "'", Error_DBConn2)
    '                            Error_Cmd2.ExecuteNonQuery()
    '                            'F_PromotionError_adoConn.Execute("delete cart_master where cart_id='"&PromotionCartID&"' and PART_NO='"&proPromotionProductInfo_ListRS2("PART_NO")&"'")
    '                            Error_Cmd2 = New System.Data.SqlClient.SqlCommand("delete logistics_detail where logistics_id='" & PromotionCartID & "' and PART_NO='" & proPromotionProductInfo_ListDR2.Rows(0).Item("PART_NO") & "'", Error_DBConn2)
    '                            Error_Cmd2.ExecuteNonQuery()
    '                            'F_PromotionError_adoConn.Execute("delete logistics_master where logistics_id='"&PromotionCartID&"' and PART_NO='"&proPromotionProductInfo_ListRS2("PART_NO")&"'")
    '                            Error_DBConn2.Close()
    '                        Else
    '                            Error_DBConn2.Open()
    '                            'F_PromotionError_adoConn.Execute("Update CART_DETAIL set QTY='"&proPromotionProductInfo_ListRS2("ONHAND_QTY")&"' where PART_NO='"&proPromotionProductInfo_ListRS2("PART_NO")&"'")
    '                            'F_PromotionError_adoConn.Execute("Update CART_MASTER set QTY='"&proPromotionProductInfo_ListRS2("ONHAND_QTY")&"' where PART_NO='"&proPromotionProductInfo_ListRS2("PART_NO")&"'")
    '                            Error_Cmd2 = New System.Data.SqlClient.SqlCommand("Update LOGISTICS_DETAIL set QTY='" & proPromotionProductInfo_ListDR2.Rows(0).Item("ONHAND_QTY") & "' where PART_NO='" & proPromotionProductInfo_ListDR2.Rows(0).Item("PART_NO") & "'", Error_DBConn2)
    '                            Error_Cmd2.ExecuteNonQuery()
    '                            'F_PromotionError_adoConn.Execute("Update LOGISTICS_MASTER set QTY='"&proPromotionProductInfo_ListRS2("ONHAND_QTY")&"' where PART_NO='"&proPromotionProductInfo_ListRS2("PART_NO")&"'")
    '                        End If
    '                        Error_DBConn2.Dispose()
    '                    End If
    '                End If
    '                xIndex = xIndex + 1
    '            Loop
    '            'g_adoConn.Close()

    '        End If
    '    End If


    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<table width=""736"" border=""0"" cellspacing=""0"" cellpadding=""0"" height=""20"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<tr><td width=""10"" height=""18"" valign=""bottom"" bgcolor=""4F60B2"">&nbsp;</td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td bgcolor=""4F60B2"" height=""18"" width=""133"" >"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<div align=""center""><b><font color=""#FFFFFF"">Promotion Alert</font></b></div></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""54"" height=""18"" valign=""bottom""><img src=""/images/folder.jpg"" width=""8"" height=""19""></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""410"" height=""18"">&nbsp;</td></tr></table>"

    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<table width=""731"" border=""1"" cellspacing=""0"" cellpadding=""0"" bordercolor=""4F5FB1"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<tr><td bgcolor=""#FFFFFF"" height=""17"" >"

    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<table width=""732"" border=""1"" cellspacing=""0"" cellpadding=""2"" bordercolor=""CFCFCF"" height=""17"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<tr>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Seq</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""3%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Ln</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""17%"" bgcolor=""#F0F0F0""  align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Product</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""40%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Description</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Availability</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Cart Qty</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Qty</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333"" align =""right""><b>Price</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""center"">"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "<font color=""#333333""><b>Subtotal</b></font></td>"
    '    PIPromotionErrorQTYlineHTML1 = PIPromotionErrorQTYlineHTML1 & "</tr>"

    '    PIPromotionErrorQTYlineHTML4 = PIPromotionErrorQTYlineHTML4 & "<tr><td colspan=""9"" align =""center""><font color='red'>Tip: if availability is zero, the product is deleted from Purchased Products Block.</font></td></tr>"

    '    PIPromotionErrorQTYlineHTML2 = PIPromotionErrorQTYlineHTML2 & "</table>"
    '    PIPromotionErrorQTYlineHTML2 = PIPromotionErrorQTYlineHTML2 & "</td></tr>"
    '    PIPromotionErrorQTYlineHTML2 = PIPromotionErrorQTYlineHTML2 & "</table>"

    '    If promotionErrorFlag = "Yes" Then
    '        'if Pre_ConfigFlag="SingleItem" then	
    '        PIPromotionErrorQTYlineHTML = PIPromotionErrorQTYlineHTML1 & PIPromotionErrorQTYlineHTML3 & PIPromotionErrorQTYlineHTML4 & PIPromotionErrorQTYlineHTML2
    '        'end if
    '        'if Pre_ConfigFlag="Pre-Config" then

    '        'end if
    '    Else
    '        promotionErrorFlag = "No"
    '        PIPromotionErrorQTYlineHTML = ""
    '    End If
    '    GetPIPromotionErrorQTYline = 1
    '    'g_adoConn.Dispose()
    'End Function

    Public Shared Function ProductDesc_Get_I(ByVal strPart_No As String, ByRef p_strProduct_Desc As String, ByRef Hold_status As String) As Integer
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim l_adoDR As DataTable
        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = "select product_desc,status from sap_product where part_no  = '" & strPart_No & "' "
        l_adoDR = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If l_adoDR.Rows.Count > 0 Then
            p_strProduct_Desc = l_adoDR.Rows(0).Item("product_desc")
            If l_adoDR.Rows(0).Item("status") = "H" Then
                Hold_status = True
            End If
            ProductDesc_Get_I = 1
        Else
            p_strProduct_Desc = "&nbsp;"
            ProductDesc_Get_I = 0
        End If
        'g_adoConn.Close()
        'g_adoConn.Dispose()
    End Function

    Public Shared Function Show_ChangedMsgOfOrder(ByVal strOrderID As String, ByVal strOrderNO As String, ByRef m_strHTML As String) As Integer
        Dim l_strSQLCmd As String = ""
        Dim l_adoDT As New DataTable

        l_strSQLCmd = "select * from ORDER_DETAIL_CHANGED_IN_SAP where ORDER_NO='" & strOrderNO & "' and CHANGED_FLAG=2 order by LINE_NO"
        l_adoDT = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If l_adoDT.Rows.Count > 0 Then
            m_strHTML = ""
            'style=""FONT-SIZE: 16pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif""
            m_strHTML = m_strHTML & "<Table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" >"
            m_strHTML = m_strHTML & "<tr ><td align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC""><font color=""#ffffff""><b>Alert</b></font></td></tr>"
            m_strHTML = m_strHTML & "<tr ><td align=""left"" width=""100%"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""18"" bgcolor=""#d8e4f8""><font color=""#316ac5"">Purchased&nbsp;Products&nbsp;INFO&nbsp;Changed,&nbsp;Sorry for the inconvenience</font></td>"
            m_strHTML = m_strHTML & "</tr>"
            m_strHTML = m_strHTML & "<tr>"
            m_strHTML = m_strHTML & "<td>"
            m_strHTML = m_strHTML & "<table width=""100%"" cellspacing=""0"" cellpadding=""0"" style=""border:#CFCFCF 1px solid"" class=""text"" ID=""Table3"">"
            Dim i As Integer = 0
            While i <= l_adoDT.Rows.Count - 1
                m_strHTML = m_strHTML & "<tr><td align=""left"" bgcolor=""#ffffff"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                m_strHTML = m_strHTML & "<font color=""red"">Line&nbsp;" & l_adoDT.Rows(i).Item("LINE_NO") & ":&nbsp;"

                m_strHTML = m_strHTML & "&nbsp;For some exceptional reasons,&nbsp;Item&nbsp;" & l_adoDT.Rows(i).Item("PART_NO") & " is removed by SAP. Sorry for the inconvenience."

                m_strHTML = m_strHTML & "</font></td></tr>"
                i = i + 1
            End While

            m_strHTML = m_strHTML & "</Table>"
            m_strHTML = m_strHTML & "</td>"
            m_strHTML = m_strHTML & "</tr>"
            m_strHTML = m_strHTML & "</Table>"

        End If
        Return 1
    End Function
    'add jan
    Public Shared Function PcHTML(ByRef mes_strHTML1 As String) As Integer

        Dim dt1 As DataTable = dbUtil.dbGetDataTable("B2B", "select op_note from dbo.LOGISTICS_Master where logistics_id='" & HttpContext.Current.Session("cart_id") & "' and (op_note like '%High Performance%' or op_note like '%Great Scalability%' or op_note like '%Cost-effective%')")
        Dim strnote As String = ""
        Dim arrnote As Array
        Dim dtnote As DataTable
        Dim arrnote1 As Array
        Dim detail As String = ""
        If dt1.Rows.Count > 0 Then
            strnote = dt1.Rows(0).Item("op_note").ToString
            'strnote = Left(strnote, strnote.Length - 1)
            arrnote = Split(strnote, ".")
            mes_strHTML1 = mes_strHTML1 + "<br/><p><span style='color:#C0504D'>This is an IPC promotion order for channel partner. Following is the list of kits ordered by customer:</span></p>"
            For i As Integer = 0 To UBound(arrnote) - 1
                detail = ""
                strnote = arrnote(i)
                arrnote1 = Split(strnote, "×")
                mes_strHTML1 = mes_strHTML1 + "<p><span  style='font-family:Symbol;mso-fareast-font-family:Symbol;mso-bidi-font-family:Symbol;color:#C0504D'>·&nbsp;</span>"
                dtnote = dbUtil.dbGetDataTable("B2B", "select Part_No from PROMOTION_CP  where  parent_id='" & arrnote1(0) & "'and category='item'")
                If dtnote.Rows.Count > 0 Then
                    For J As Integer = 0 To dtnote.Rows.Count - 1
                        detail = detail + dtnote.Rows(J).Item("Part_No") + "+"
                    Next
                    detail = Left(detail, detail.Length - 1)
                End If

                mes_strHTML1 = mes_strHTML1 + "<span  style='color:#C0504D'>" & arrnote1(0) & "(</span><span lang='EN-US'style='font-size:8.5pt;color:#C0504D'>" & detail & ""
                mes_strHTML1 = mes_strHTML1 + "</span> <span lang='EN-US' style='color:#C0504D'>)&nbsp; ×" & arrnote1(1) & " </span></p>"

            Next
            'mes_strHTML1 = "<br/><font color='red'>" & dt1.Rows(0).Item("op_note") & "<br/>"
        End If
        Return 1
    End Function

    Public Shared Function SendPI(ByVal strPIId As String, ByVal strPIType As String, ByVal strSendTo As String) As Integer
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim exeFunc As Integer = 0, execFunc As Integer = 0, strStyle As String = "", m_strHTML As String = "", mes_strHTML As String = ""
        Dim t_strHTML As String = "", x_strHTML As String = "", FROM_Email As String = "", TO_Email As String = "", CC_Email As String = ""
        Dim BCC_Email As String = "", Subject_Email As String = "", AttachFile As String = "", MailBody As String = "", l_strSQLCmd As String = ""
        l_strSQLCmd = "select " & _
            "a.order_id, " & _
            "a.order_no, " & _
            "a.po_no, " & _
            "b.company_id, " & _
            "b.company_name " & _
            "from order_master a " & _
            "inner join sap_dimcompany b " & _
            "on a.soldto_id = b.company_id and b.company_type in ('Partner','Z001') " & _
            "where a.order_no = '" & strPIId & "'"

        Dim l_adoDR As DataTable
        l_adoDR = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim strSOID As String = "", strSONo As String = "", strPONo As String = "", strCompanyId As String = "", strCompanyName As String = ""
        If l_adoDR.Rows.Count > 0 Then
            strSOID = l_adoDR.Rows(0).Item("order_id") : strSONo = l_adoDR.Rows(0).Item("order_no") : strPONo = l_adoDR.Rows(0).Item("po_no")
            strCompanyId = l_adoDR.Rows(0).Item("company_id") : strCompanyName = l_adoDR.Rows(0).Item("company_name")
        End If
        '----------------------------------------------------------------
        exeFunc = Show_ChangedMsgOfOrder(strSOID, strSONo, m_strHTML)
        '----------------------------------------------------------------

        strStyle = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 8pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        strStyle = strStyle & "</style>"
        Dim strCC As String = ""
        If strPIType = "PI" Then
            strCC = ""
            l_strSQLCmd = "select distinct userid from company_contact " & _
                          "where company_id='" & strCompanyId & "'"
            Dim l_adoDT As New DataTable
            l_adoDT = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
            Dim h As Integer = 0
            Do While h <= l_adoDT.Rows.Count - 1
                strCC = strCC & l_adoDT.Rows(h).Item("userid") & ";"
                h = h + 1
            Loop
            '<Nada Added for PI send by SalesOffice>
            Dim temp As String = dbUtil.dbExecuteScalar("B2B", _
            "SELECT TOP 1 COMPANY_ID from sap_dimcompany where company_type in ('Partner','Z001') and Company_id='" & _
                                                      strCompanyId & "' and salesOffice in ('3600','3700')")
            If Len(temp) > 1 Or strCompanyId = "EDSISY01" Then
                strCC = strCC & "ales.rychtar@advantech.com;"
            End If

            '</Nada Added for PI send by SalesOffice>
        End If

        '-- jackie add 2005/12/15 for zero price and empty weight on PI begin
        Dim iRetVal As Integer = 0
        'Dim strWeightPrice As String = ""
        'iRetVal = GetPriceWeightZero(strPIId, strWeightPrice)
        '---------------- zero price and empty weight on PI end here

        '---------Jackie add for credit limit 2005-10-26-------------------------	
        mes_strHTML = ""
        If Global_Inc.IsOverCreditLimit("EU01", HttpContext.Current.Session("company_id")) Then
            mes_strHTML = mes_strHTML & "<br/><font color='red'>Please be informed that customer " & UCase(HttpContext.Current.Session("company_id")) & " has Credit or AR situation to verify with Advantech Europe.<br/>"
        End If
        Dim mes_strHTML1 As String = ""
        exeFunc = OrderUtilities.PcHTML(mes_strHTML1)
        '---------End of Jackie add for credit limit 2005-10-26------------------
        'jacke add 2007/08/28 for P T project send mail to TW
        'Amy:                    amy.yen@(advantech.com.tw)
        'Anne:                   anne.chung@(advantech.com.tw)
        Dim flg_acl As Boolean = False
        If dbUtil.dbGetDataTable("B2B", "select line_no from order_detail where order_id='" & strSOID & "' and DeliveryPlant like 'TW%'").Rows.Count > 0 Then
            flg_acl = True
        End If
        'Jackie add 20071116 for judge the btos/standard order
        Dim flg_btos As Boolean = False
        If dbUtil.dbGetDataTable("B2B", "select line_no from order_detail where order_id='" & strSOID & "' and line_no>=100 order by line_no").Rows.Count > 0 Then
            flg_btos = True
        End If

        'If LCase(HttpContext.Current.Session("USER_ROLE")) = "buyer" Or LCase(HttpContext.Current.Session("USER_ROLE")) = "guest" Or _
        'LCase(HttpContext.Current.Session("USER_ID")) Like "*@advantech.hg" Or _
        'LCase(HttpContext.Current.Session("USER_ID")) Like "*@advantech.gr" Then
        If Not Util.IsInternalUser(HttpContext.Current.Session("USER_ID")) Then
            Dim i As Integer
            For i = 1 To 2
                Select Case i
                    Case 1
                        HttpContext.Current.Session("xInternalFlag") = "external"
                        execFunc = GetPI(strPIId, strPIType, x_strHTML)
                        t_strHTML = Replace(x_strHTML, "<body>", "<body>" & strStyle)
                        't_strHTML = Replace(t_strHTML, "../images/", "")
                        HttpContext.Current.Session("xInternalFlag") = ""

                        FROM_Email = "eBusiness.AEU@advantech.eu"
                        TO_Email = HttpContext.Current.Session("USER_ID")
                        CC_Email = ""
                        BCC_Email = "Nada.liu@advantech.com.cn"
                        ''----------------------------------------------
                        ''---- { 14-01-05 } Extended Warranty (Start)
                        ''----------------------------------------------
                        If UCase(Left(strSONo, 2)) <> "EW" Then
                            'Subject_Email = "Advantech Order(" & strPONo & "/" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                            Subject_Email = "Advantech Order(" & strPONo & "/" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                        Else
                            'Subject_Email = "Advantech Warranty(" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                            Subject_Email = "Advantech Warranty(" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                        End If
                        ''----------------------------------------------
                        ''---- { 14-01-05 } Extended Warranty (End)
                        ''----------------------------------------------
                        'AttachFile = Server.MapPath("../images/") & "header_advantech_logo.gif"
                        MailBody = m_strHTML & "<br/>" & t_strHTML
                        If HttpContext.Current.Session("org_id").ToString.ToUpper = "TW01" Then
                            CC_Email &= "Iris.Wang@advantech.com.tw;Emma.Chen@advantech.com.tw"
                        End If
                        'Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
                        MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, "", MailBody)
                    Case 2
                        HttpContext.Current.Session("xInternalFlag") = "internal"
                        execFunc = GetPI(strPIId, strPIType, x_strHTML)
                        t_strHTML = Replace(x_strHTML, "<body>", "<body>" & strStyle)
                        't_strHTML = Replace(t_strHTML, "../images/", "")
                        HttpContext.Current.Session("xInternalFlag") = ""

                        FROM_Email = "eBusiness.AEU@advantech.eu"
                        TO_Email = strCC

                        CC_Email &= "eBusiness.AEU@advantech.eu;"

                        If flg_btos Then
                            'CC_Email &= "Stephen.Simms@advantech.eu;Michael.Zoon@advantech.eu;Erik.Smulders@advantech.eu;"
                        End If
                        'If flg_acl Or strCompanyId = "ENSEIN01" Then
                        '    CC_Email &= "amy.yen@advantech.com.tw;anne.chung@advantech.com.tw"
                        'End If
                        'BCC_Email = ""
                        BCC_Email = "Nada.liu@advantech.com.cn"
                        '----------------------------------------------
                        '---- { 14-01-05 } Extended Warranty (Start)
                        '----------------------------------------------
                        If UCase(Left(strSONo, 2)) <> "EW" Then
                            'Subject_Email = "Advantech Order(" & strPONo & "/" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                            Subject_Email = "Advantech Order(" & strPONo & "/" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                        Else
                            'Subject_Email = "Advantech Warranty(" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                            Subject_Email = "Advantech Warranty(" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                        End If
                        '----------------------------------------------
                        '---- { 14-01-05 } Extended Warranty (End)
                        '----------------------------------------------
                        'AttachFile = Server.MapPath("../images/") & "header_advantech_logo.gif"
                        '------------------------Jackie add 2005-10-27 for credit limit----------------
                        ' MailBody = mes_strHTML & "<br/>" & mes_strHTML1 & "<br/>" & strWeightPrice & m_strHTML & "<br/>" & t_strHTML
                        '------------------------------------------------------------------------------
                        If HttpContext.Current.Session("org_id").ToString.ToUpper = "TW01" Then
                            CC_Email &= "Iris.Wang@advantech.com.tw;Emma.Chen@advantech.com.tw"
                        End If
                        MailBody = m_strHTML & "<br/>" & t_strHTML
                        'Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
                        Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
                End Select
            Next
        Else

            HttpContext.Current.Session("xInternalFlag") = "internal"
            execFunc = GetPI(strPIId, strPIType, x_strHTML)
            t_strHTML = Replace(x_strHTML, "<body>", "<body>" & strStyle)
            't_strHTML = Replace(t_strHTML, "../images/", "")
            HttpContext.Current.Session("xInternalFlag") = ""

            FROM_Email = "myadvantech@advantech.com"
            TO_Email = HttpContext.Current.Session("USER_ID")
            'If flg_acl Then
            '    TO_Email &= ";amy.yen@advantech.com.tw;anne.chung@advantech.com.tw"
            'End If
            CC_Email = strCC & "eBusiness.AEU@advantech.eu;"
            If flg_btos Then
                'CC_Email &= "Stephen.Simms@advantech.eu;Michael.Zoon@advantech.eu;Erik.Smulders@advantech.eu;"
            End If
            If flg_acl Then
                'CC_Email &= "amy.yen@advantech.com.tw;anne.chung@advantech.com.tw;"
            End If
            'CC_Email = "myadvantech@advantech.com;"
            BCC_Email = "eBusiness.AEU@advantech.eu;"
            'BCC_Email = "Jackie.Wu@advantech.com.cn;Nada.liu@advantech.com.cn"
            '----------------------------------------------
            '---- { 14-01-05 } Extended Warranty (Start)
            '----------------------------------------------
            If UCase(Left(strSONo, 2)) <> "EW" Then
                'Subject_Email = "Advantech Order(" & strPONo & "/" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                Subject_Email = "Advantech Order(" & strPONo & "/" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
            Else
                'Subject_Email = "Advantech Warranty(" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
                Subject_Email = "Advantech Warranty(" & strSONo & ") for " & strCompanyName & " (" & strCompanyId & ")"
            End If
            '----------------------------------------------
            '---- { 14-01-05 } Extended Warranty (End)
            '----------------------------------------------
            'AttachFile = Server.MapPath("../images/") & "header_advantech_logo.gif"
            '----------------------------------------------------for credit limit Jackie 2005-10-27------------
            'MailBody = mes_strHTML & "<br/>" & mes_strHTML1 & "<br/>" & strWeightPrice & m_strHTML & "<br/>" & t_strHTML  '-------add credit limit
            '--------------------------------------------------------------------------------------------------
            If HttpContext.Current.Session("org_id").ToString.ToUpper = "TW01" Then
                CC_Email &= "Iris.Wang@advantech.com.tw;Emma.Chen@advantech.com.tw"
            End If
            MailBody = m_strHTML & "<br/>" & t_strHTML
            Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        End If
        'g_adoConn.Dispose()
        Return 1
    End Function

    Public Shared Function GetPI(ByVal strPIId As String, ByVal strPIType As String, ByRef p_strHTML As String) As Integer
        Dim l_strHTML As String = ""
        Dim l_strHTML1 As String = ""
        Dim l_strHTML2 As String = ""
        Dim l_strHTML3 As String = ""
        '--{2006-06-19}--daive: Add RoHS Agreement in PI
        Dim l_strHTML4 As String = ""
        Dim strOrderID As String = ""

        Dim exeFunc As Integer = 0
        Dim g_adoConn As New System.Data.SqlClient.SqlConnection
        'PI(NADA)
        exeFunc = GetPICustomerInfo(strPIId, strPIType, l_strHTML1)
        exeFunc = GetPIOrderInfo(strPIId, strPIType, l_strHTML2)
        exeFunc = GetPIOrderItemList(strPIId, strPIType, l_strHTML3)
        '--{2006-06-19}--daive: Add RoHS Agreement in PI
        If Global_Inc.C_ShowRoHS = True Then
            Dim RoHSDT As DataTable = dbUtil.dbGetDataTable("B2B", "select distinct order_id,IsNull(NONERoHS_ACCEPT,'') as NONERoHS_ACCEPT from order_master where order_no='" & strPIId & "'")
            If RoHSDT.Rows.Count > 0 Then
                If RoHSDT.Rows(0).Item("NONERoHS_ACCEPT").ToString.Trim.ToUpper = "Y" Then
                    GetRoHSTerms(RoHSDT.Rows(0).Item("order_id").ToString.Trim.ToUpper, "ORDER", l_strHTML4)
                    l_strHTML4 = "<table width=""100%"">" & _
                                 "<td style=""height:37px;width:98%;"">" & _
                                 "<div align=""center""><strong><u><font size=""+1"" color=""navy""> Non-RoHS Terms and " & _
                                 "Conditions of Advantech Europe </font></u></strong>" & _
                                 "</div>" & _
                                 "<br/>" & _
                                 "<br/>" & _
                                 "<div align=""center""><font color=""#FF0000""><u> Due to the local circumstances, these " & _
                                 "articles could be subject to change.<br/>" & _
                                 "Advantech will keep the right to change these articles at any time in order to " & _
                                 "comply to those circumstances. </u></font>" & _
                                 "</div>" & _
                                 "<br/>" & _
                                 "</td>" & _
                                 "</tr>" & _
                                 "<tr>" & _
                                 "<td width=""98%"">" & _
                                 l_strHTML4 & _
                                 "</td>" & _
                                 "</tr>" & _
                                 "</table>"
                End If
            End If
        End If
        Dim l_strSQLCmd As String = ""
        Dim l_adoDT As New DataTable

        '---- prepare company info
        l_strSQLCmd = "select distinct " & _
            "c.userid, " & _
            "(IsNull(c.firstname,'') + ' ' + IsNull(c.lastname,'')) as full_name," & _
            "IsNull(c.WorkPhone,'') as tel_no " & _
            "from order_master a " & _
            "inner join company_contact b " & _
            "on a.soldto_id = b.company_id " & _
            "inner join Contact c " & _
            "on b.userid = c.userid " & _
            "where a.order_no = '" & strPIId & "' and a.billto_id<>'disabled'"

        l_adoDT = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)

        l_strHTML = l_strHTML & "<html><body><center>"
        'l_strHTML = l_strHTML & "<link href=""http://b2b.advantech-nl.nl/includes/layout/eBizStyle.css"" rel=""stylesheet"">"
        'l_strHTML = l_strHTML & "<link href=""http://b2b.advantech-nl.nl/utility/ebiz.aeu.style.css"" rel=""stylesheet"">"
        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td valign=""top"" align=""left"" width=""50%"">"
        l_strHTML = l_strHTML & "<img src=""../images/header_advantech_logo.gif""/></td>"
        l_strHTML = l_strHTML & "<td align=""right"">"
        l_strHTML = l_strHTML & "</td>"
        l_strHTML = l_strHTML & "<td align=""right"">"
        l_strHTML = l_strHTML & "<b>Advantech Europe BV</b><br/>"
        l_strHTML = l_strHTML & "Ekkersrijt 5708, 5692 ER Son, The Netherlands " & "<br/>"
        l_strHTML = l_strHTML & "Tel: +31 (0) 40 26 77 000&nbsp;&nbsp;Fax: +31 (0) 40 26 77 001" & "<br/>"
        Dim intCount As Integer = 1
        Dim strUserId As String = ""
        Dim strUserName As String = ""
        Dim strTelExt As String = ""
        Dim strTelNo As String = ""
        Do While intCount <= l_adoDT.Rows.Count
            strUserId = l_adoDT.Rows(intCount - 1).Item("userid")
            strUserName = l_adoDT.Rows(intCount - 1).Item("full_name")
            strTelNo = l_adoDT.Rows(intCount - 1).Item("tel_no")
            If intCount = 1 Then
                l_strHTML = l_strHTML & "Contact: "
            Else
                l_strHTML = l_strHTML & "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
            End If
            l_strHTML = l_strHTML & "<a href=""mailto:" & strUserId & """>" & strUserName & "</a>" & "&nbsp;(" & strTelNo & ")"
            If intCount Mod 2 = 0 Then
                l_strHTML = l_strHTML & "<br/>"
            Else
                l_strHTML = l_strHTML & "<br/>"
            End If
            intCount = intCount + 1
        Loop
        l_strHTML = l_strHTML & "</td></tr>"
        l_strHTML = l_strHTML & "<tr><td colspan=""3"" height=""7"">"
        l_strHTML = l_strHTML & "&nbsp;</td></tr>"
        l_strHTML = l_strHTML & "<tr><td colspan=""3"" align=""left"">"
        l_strHTML = l_strHTML & "<div><font size=""5"" color=""#000000"" align=""left""><b>Proforma Invoice</b></font></div>" & "<br/><br/>"
        l_strHTML = l_strHTML & "</td></tr>"
        l_strHTML = l_strHTML & "</table>"
        l_strHTML = l_strHTML & l_strHTML1 & "<br/>"
        l_strHTML = l_strHTML & l_strHTML2 & "<br/>"
        l_strHTML = l_strHTML & l_strHTML3 & "<br/>" & "<font><a href=""http://" & HttpContext.Current.Request.ServerVariables("HTTP_HOST") & "/files/terms.aspx"" class=""text_mini"" target=_blank>- General Business Terms and Conditions for Advantech Europe</a></font><br/><br/>"
        l_strHTML = l_strHTML & l_strHTML4 & "<br/><br/>"
        '--------------------------------------------
        '---- { 14-02-05 } Price US Invoice(Start)
        '--------------------------------------------
        Dim xSQL As String = ""
        'Dim oDRUS1 As DataTable

        If strPIType <> "ORDER_CONFIRM" Then
            l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" bgcolor=""#7B8396"" cellspacing=""0"" cellpadding=""2"">"
            l_strHTML = l_strHTML & "<tr>"
            l_strHTML = l_strHTML & "<td colspan=""2"" align=""center"" class=""text_mini""><font color=""#ffffff"">"
            l_strHTML = l_strHTML & "<a href=""http://www.advantech.com/about"" class=""text_mini"" target=_blank><font color=#ffffff>Copyright &copy; 2003 Advantech Co., Ltd. All Rights Reserved</font></a></font>"
            l_strHTML = l_strHTML & "</td>"
            l_strHTML = l_strHTML & "</tr>"
            l_strHTML = l_strHTML & "</table>"
        End If
        l_strHTML = l_strHTML & "</center></body></html>"
        p_strHTML = l_strHTML
        l_strHTML = Nothing
        Return 1
    End Function


    Public Shared Function GetPICustomerInfo(ByVal strPIId As String, ByVal strPIType As String, ByRef p_strHTML As String) As Integer
        Dim l_strHTML As String = ""
        Dim l_strSQLCmd As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection
        '---- prepare company info
        l_strSQLCmd = "select " & _
            "b.company_id, " & _
            "b.company_name," & _
            "(IsNull(b.address,'') + ' ' + IsNull(b.city,'') + ', ' + IsNull(b.country,'')) as address," & _
            "IsNull(b.tel_no,'') as tel_no, " & _
            "IsNull(b.fax_no,'') as fax_no," & _
            "IsNull(a.attention,'') as attention " & _
            "from order_master a " & _
            "inner join sap_dimcompany b " & _
            "on a.soldto_id = b.company_id and b.company_type in ('Partner','Z001') " & _
            "where a.order_no = '" & strPIId & "' and a.billto_id<>'disabled'"
        Dim STDataReader As DataTable
        STDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim strSTCompanyId As String = ""
        Dim strSTCompanyName As String = ""
        Dim strSTAddr As String = ""
        Dim strSTTelNo As String = ""
        Dim strSTFaxNo As String = ""
        Dim strSTAttention As String = ""
        If STDataReader.Rows.Count > 0 Then
            strSTCompanyId = STDataReader.Rows(0).Item("company_id")
            strSTCompanyName = STDataReader.Rows(0).Item("company_name")
            strSTAddr = STDataReader.Rows(0).Item("address")
            strSTTelNo = STDataReader.Rows(0).Item("tel_no")
            strSTFaxNo = STDataReader.Rows(0).Item("fax_no")
            strSTAttention = STDataReader.Rows(0).Item("attention")
        End If
        'g_adoConn.Close()

        '---- prepare company info
        l_strSQLCmd = "select " & _
            "a.shipto_id as company_id, " & _
            "b.company_name," & _
            "(IsNull(b.address,'') + ' ' + IsNull(b.city,'') + ', ' + IsNull(b.country,'')) as address," & _
            "IsNull(b.tel_no,'') as tel_no, " & _
            "IsNull(b.fax_no,'') as fax_no," & _
            "IsNull(a.customer_attention,'') as customer_attention " & _
            "from order_master a " & _
            "left join sap_dimcompany b " & _
            "on a.shipto_id = b.company_id " & _
            "where a.order_no = '" & strPIId & "'"
        Dim SHDataReader As DataTable
        SHDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim strSHCompanyId As String = ""
        Dim strSHCompanyName As String = ""
        Dim strSHAddr As String = ""
        Dim strSHTelNo As String = ""
        Dim strSHFaxNo As String = ""
        Dim strSHAttention As String = ""
        If SHDataReader.Rows.Count > 0 Then
            strSHCompanyId = IIf(IsDBNull(SHDataReader.Rows(0).Item("company_id")), "", SHDataReader.Rows(0).Item("company_id"))
            strSHCompanyName = IIf(IsDBNull(SHDataReader.Rows(0).Item("company_name")), "", SHDataReader.Rows(0).Item("company_name"))
            strSHAddr = IIf(IsDBNull(SHDataReader.Rows(0).Item("address")), "", SHDataReader.Rows(0).Item("address"))
            Try
                strSHTelNo = SHDataReader.Rows(0).Item("tel_no")
            Catch ex As Exception
                strSHTelNo = ""
            End Try
            strSHFaxNo = SHDataReader.Rows(0).Item("fax_no")
            strSHAttention = SHDataReader.Rows(0).Item("customer_attention")
        End If
        'g_adoConn.Close()

        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" align=""left"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML = l_strHTML & "<font color=""#ffffff""><b>Customer Information</b></font></td></tr>"
        l_strHTML = l_strHTML & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td bgcolor=""#F0F0F0"" colspan=""4"" align =""center"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Customer Information&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Customer&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""60%""   align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTCompanyName & "(" & strSTCompanyId & ")</font></td>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Attention&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%""   align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTAttention & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" rowspan=""2"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Address&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""60%"" rowspan=""2""  align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTAddr & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""10%""  height=""10""  bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Tel No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10""  align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTTelNo & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" height=""7"" bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Fax No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10""  align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTFaxNo & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td bgcolor=""#F0F0F0"" colspan=""4"" align =""center"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Shipping Information&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Customer&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""60%""   align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSHCompanyName & "(" & strSHCompanyId & ")</font></td>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Attention&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%""   align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSHAttention & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" rowspan=""2"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Address&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""60%"" rowspan=""2""  align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSHAddr & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""10%""  height=""10""  bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Tel No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10"" align=""left"" >"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSHTelNo & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" height=""7"" bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Fax No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10"" align=""left"" >"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSHFaxNo & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "</table>"

        l_strHTML = l_strHTML & "</td></tr></table>"

        'HttpContext.Current.Response.Write l_strHTML
        p_strHTML = l_strHTML
        l_strHTML = Nothing
        Return 1
    End Function

    Public Shared Function GetPIOrderInfo(ByVal strPIId As String, ByVal strPIType As String, ByRef p_strHTML As String) As Integer
        Dim l_strHTML As String = ""
        Dim l_strHTML2 As String = ""
        Dim l_strSQLCmd As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection

        '---- prepare company info
        l_strSQLCmd = "select " & _
            "a.soldto_id, " & _
            "a.order_no, " & _
            "a.po_no," & _
            "IsNull(a.po_date,'') as po_date," & _
            "a.order_date, " & _
            "a.due_date," & _
            "a.required_date," & _
            "IsNull(a.ship_condition,'') as ship_condition," & _
            "IsNull(a.order_note,'') as order_note," & _
            "IsNull(a.created_by,'" & HttpContext.Current.Session("USER_ID") & "') as created_by," & _
            "a.partial_flag," & _
            "a.order_type," & _
            "IsNull(a.remark,'') as remark," & _
            "IsNull(a.INCOTERM,'') as INCOTERM, " & _
            "IsNull(a.freight,0) as freight, " & _
            "IsNull(a.INCOTERM_TEXT,'') as INCOTERM_TEXT, " & _
            "IsNull(a.SALES_NOTE,'') as SALES_NOTE,isnull(a.DefaultSalesNote,'N') as DefaultSalesNote, " & _
            "IsNull(a.OP_NOTE,'') as OP_NOTE " & _
            "from order_master a " & _
            "inner join sap_dimcompany b " & _
            "on a.soldto_id = b.company_id and b.company_type in ('Partner','Z001') " & _
            "where a.order_no = '" & strPIId & "' and a.billto_id<>'disabled'"

        Dim OrderDataReader As DataTable
        OrderDataReader = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim strOrderNo As String = ""
        Dim strPoNo As String = ""
        Dim strPoDate As String = ""
        Dim dtOrderDate As String = ""
        Dim dtExpectedDate As String = ""
        Dim strOrderNote As String = ""
        '--{2005-9-28}--Daive: 
        Dim strSalesNote As String = ""
        Dim strOPNote As String = ""
        Dim DefaultSalesNote As String = "N"

        Dim strRemark As String = ""
        Dim strIncotermText As String = ""
        Dim strShipCondition As String = ""
        Dim strIncoterm As String = ""
        Dim strPlacedBy As String = ""
        Dim flgPartialOK As String = ""
        Dim strOrderType As String = ""
        Dim dtRequiredDate As String = ""
        Dim Freight As String = ""
        If OrderDataReader.Rows.Count > 0 Then
            strOrderNo = OrderDataReader.Rows(0).Item("order_no")
            strPoNo = OrderDataReader.Rows(0).Item("po_no")
            strPoDate = OrderDataReader.Rows(0).Item("po_date")
            'Jackie revise 20070207
            dtOrderDate = Global_Inc.FormatDate(OrderDataReader.Rows(0).Item("order_date")) 'Global_Inc.FormatDate(Date.Now.Date)
            dtExpectedDate = Global_Inc.FormatDate(OrderDataReader.Rows(0).Item("due_date"))
            dtRequiredDate = Global_Inc.FormatDate(OrderDataReader.Rows(0).Item("required_date"))
            strOrderNote = OrderDataReader.Rows(0).Item("order_note")
            '--{2005-9-28}--Daive: 
            strSalesNote = OrderDataReader.Rows(0).Item("SALES_NOTE")
            strOPNote = OrderDataReader.Rows(0).Item("OP_NOTE")
            Freight = OrderDataReader.Rows(0).Item("freight")
            'jackie 20071009
            DefaultSalesNote = OrderDataReader.Rows(0).Item("DefaultSalesNote")

            strRemark = OrderDataReader.Rows(0).Item("remark")
            If LCase(OrderDataReader.Rows(0).Item("INCOTERM_TEXT")) = "blank" Then
                strIncotermText = ""
            Else
                strIncotermText = OrderDataReader.Rows(0).Item("INCOTERM_TEXT")
            End If
            strShipCondition = Mid(OrderDataReader.Rows(0).Item("ship_condition"), 3)
            strIncoterm = OrderDataReader.Rows(0).Item("INCOTERM")
            strPlacedBy = OrderDataReader.Rows(0).Item("created_by")
            strOrderType = OrderDataReader.Rows(0).Item("order_type")

            If OrderDataReader.Rows(0).Item("partial_flag") = "N" Then
                flgPartialOK = "<font color=""red"">No</font>"
            Else
                flgPartialOK = "Yes"
            End If
        End If
        'g_adoConn.Close()

        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#ffffff""><b>Order Information</b></font></td></tr>"
        l_strHTML = l_strHTML & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">PO No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strPoNo & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Advantech SO&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strOrderNo & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Order Date&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & dtOrderDate & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Payment Term&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">&nbsp;Required Date&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & dtRequiredDate & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Incoterm&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strIncoterm & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Placed By&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strPlacedBy & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Incoterm Text&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strIncotermText & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Freight&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Freight & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Channel&nbsp;&nbsp;</font></b></td>"
        '---- 271103e add for VISAM Case ----(Start)'
        'exeFunc = GetAsmblyComp(1,HttpContext.Current.Session("ORDER_ID"),strAsmblyComp)
        ''If UCase(strAsmblyComp) = "ADLVISAM" Then
        ''	strOrderType="VISAM"                            
        ''Else
        ''	strOrderType="SO"                            
        ''End If		

        'If UCase(strAsmblyComp) = "ADLVISAM" Then
        '	strOrderType="VISAM"                            
        'ElseIf UCase(strAsmblyComp) = "ADLGBM" Then
        strOrderType = "GBM"
        'ElseIf UCase(strAsmblyComp) = "ADLRAINB" Then
        '		strOrderType="RAINB"                            
        'ELSE
        '		strOrderType="SO"                            
        'End If		

        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        'l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strOrderType & "</font>"
        '---- 271103e add for VISAM Case ----(End)'    
        l_strHTML = l_strHTML & "</td></tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Partial OK&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & flgPartialOK & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Ship Condition&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strShipCondition & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"

        If HttpContext.Current.Session("xInternalFlag") = "internal" Or HttpContext.Current.Session("xInternalFlag") = "internal_C" Then
            If Not (CStr(strPoDate) Like "*9999*") Then
                l_strHTML = l_strHTML & "<tr>"
                l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
                l_strHTML = l_strHTML & "<b><font color=""#333333"">PO Date&nbsp;</font></b></td>"
                l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"" align=""left"">"
                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(strPoDate) & "</font></td>"
                l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
                l_strHTML = l_strHTML & "<b><font color=""#333333"">&nbsp;</font></b></td>"
                l_strHTML = l_strHTML & "<td width=""35%""  bgcolor=""#FFFFFF"">"
                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;</font></td>"
                l_strHTML = l_strHTML & "</tr>"
            End If
        End If
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""middle"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Order Note&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td  colspan=""3""  valign=""top"" bgcolor=""#FFFFFF"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""red""><b>" & Replace(Global_Inc.HTMLEncode(strOrderNote), "$$$$", "<br/>") & "</b></font></td>"
        l_strHTML = l_strHTML & "</tr>"
        '--{2005-9-28}--Daive: release Sales Note and OP Note to administrators and logistics
        '---------------------------------------------------------------------------------------------
        '--{2005-11-8}--Daive: All users can see Sales Note
        If HttpContext.Current.Session("xInternalFlag") = "internal" Or HttpContext.Current.Session("xInternalFlag") = "internal_C" Then
            l_strHTML = l_strHTML & "<tr>"
            l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""middle"">"
            l_strHTML = l_strHTML & "<b><font color=""#333333"">Sales Note&nbsp;&nbsp;</font></b></td>"
            l_strHTML = l_strHTML & "<td  colspan=""3""  valign=""top"" bgcolor=""#FFFFFF"" align=""left"">"
            If DefaultSalesNote = "Y" Then
                l_strHTML = l_strHTML & "<font color=""red""><b>" & strSalesNote & "</b></font></td>"
            Else
                l_strHTML = l_strHTML & "<font color=""red""><b>" & Global_Inc.HTMLEncode(strSalesNote) & "</b></font></td>"
            End If
            l_strHTML = l_strHTML & "</tr>"
            'if HttpContext.Current.Session("xInternalFlag")="internal" or HttpContext.Current.Session("xInternalFlag")="internal_C" then
            '  if IsDaive(HttpContext.Current.Session("USER_ID")) then

            l_strHTML = l_strHTML & "<tr>"
            l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""middle"">"
            l_strHTML = l_strHTML & "<b><font color=""#333333"">OP Note&nbsp;&nbsp;</font></b></td>"
            l_strHTML = l_strHTML & "<td  colspan=""3""  valign=""top"" bgcolor=""#FFFFFF"" align=""left"">"
            l_strHTML = l_strHTML & "<font color=""red""><b>" & Global_Inc.HTMLEncode(strOPNote) & "</b></font></td>"
            l_strHTML = l_strHTML & "</tr>"
            '  end if
        End If
        '---------------------------------------------------------------------------------------------
        l_strHTML = l_strHTML & "</table>"
        l_strHTML = l_strHTML & "</td></tr></table>"
        'HttpContext.Current.Response.Write l_strHTML
        p_strHTML = l_strHTML
        l_strHTML = Nothing
        Return 1
    End Function

    '----Jackie create 12/15/2005 for show Price & Weight which is 0 at PI
    'Public Shared Function GetPriceWeightZero(ByVal strPIId As String, ByRef strWeightPrice As String) As Integer
    '    Dim strWeight, strValue, strHold As String
    '    strWeight = "<font color='red'>"
    '    strValue = "<font color='red'>"
    '    strHold = "<font color='red'>"

    '    'Dim g_adoConn As New SqlClient.SqlConnection
    '    Dim l_strSQLCmd As String = ""
    '    Dim l_adoDT As New DataTable
    '    l_strSQLCmd = "select " & _
    '        "a.currency, " & _
    '        "a.order_id, " & _
    '        "b.line_no, " & _
    '        "b.part_no, " & _
    '        "IsNull((select top 1 z.product_desc from sap_product z where z.part_no=b.part_no),'') as product_desc," & _
    '        "b.due_date, " & _
    '        "b.required_date, " & _
    '        "b.auto_order_flag, " & _
    '        "b.qty, " & _
    '        "b.unit_price " & _
    '        "from order_master a " & _
    '        "inner join order_detail b " & _
    '        "on a.order_id = b.order_id " & _
    '        "where a.order_no = '" & strPIId & "' and line_no<>100 and (b.part_no not like 'S-warranty%' and b.part_no not like 'OPTION%' )" & _
    '        "group by a.currency,a.order_id,b.line_no, b.part_no,b.due_date,b.required_date,b.qty,b.auto_order_flag,b.unit_price " & _
    '        "order by b.line_no "

    '    l_adoDT = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
    '    Dim i As Integer = 1
    '    Do While i <= l_adoDT.Rows.Count
    '        If CDbl(l_adoDT.Rows(i - 1).Item("unit_price")) = 0 And InStr(LCase(l_adoDT.Rows(i - 1).Item("part_no")), "ags-ew") <= 0 Then
    '            strValue = strValue & "<b>" & l_adoDT.Rows(i - 1).Item("part_no") & "</b>" & "&nbsp;&nbsp;"
    '        End If
    '        Dim strSql As String = ""
    '        Dim l_ADODR As DataTable
    '        strSql = "select gross_weight as ship_weight from sap_product where part_no='" & l_adoDT.Rows(i - 1).Item("part_no") & "' and ( gross_weight is null or gross_weight = 0 ) and product_type<>'ZSRV'"
    '        l_ADODR = dbUtil.dbGetDataTable("B2B", strSql)
    '        If l_ADODR.Rows.Count > 0 Then
    '            strWeight = strWeight & "<b>" & l_adoDT.Rows(i - 1).Item("part_no") & "</b>" & "&nbsp;&nbsp;"
    '        End If
    '        'g_adoConn.Close()
    '        'jackie add 01/16/2006 for on-hold product issue
    '        If LCase(HttpContext.Current.Session("USER_ROLE")) = "logistics" Or LCase(HttpContext.Current.Session("USER_ROLE")) = "administrator" Then
    '            strSql = "select status from sap_product where part_no='" & l_adoDT.Rows(i - 1).Item("part_no") & "' and status='H'"
    '            Dim DR_hold As DataTable
    '            DR_hold = dbUtil.dbGetDataTable("B2B", strSql)
    '            If DR_hold.Rows.Count > 0 Then
    '                strHold = strHold & "<b>" & l_adoDT.Rows(i - 1).Item("part_no") & "</b>" & "&nbsp;&nbsp;"
    '            End If
    '            'g_adoConn.Close()
    '        End If
    '        i = i + 1
    '    Loop

    '    strWeight = ""
    '    If Len(strValue) > 18 Then
    '        strValue = strValue & " price is 0.</font><br>"
    '    Else
    '        strValue = ""
    '    End If
    '    If Len(strHold) > 18 Then
    '        strHold = strHold & " is On-Hold.</font><br>"
    '    Else
    '        strHold = ""
    '    End If
    '    strWeightPrice = strWeight & strValue & strHold
    '    'g_adoConn.Dispose()
    '    Return 1
    'End Function


    Public Shared Function GetPIOrderItemList(ByVal strPIId As String, ByVal strPIType As String, ByRef p_strHTML As String) As Integer
        Dim l_strHTML As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection

        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"" align=""left"">"
        l_strHTML = l_strHTML & "<font color=""#ffffff""><b>Purchased Products</b></font></td></tr>"
        l_strHTML = l_strHTML & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Seq</b></font></td>"
        l_strHTML = l_strHTML & "<td width=""3%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Ln</b></font></td>"
        l_strHTML = l_strHTML & "<td width=""17%"" bgcolor=""#F0F0F0""  align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Product</b></font></td>"

        '--CustomerPN
        l_strHTML = l_strHTML & "<td width=""17%"" bgcolor=""#F0F0F0""  align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Customer P\N</b></font></td>"

        l_strHTML = l_strHTML & "<td width=""30%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Description</b></font></td>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Due Date</b></font></td>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Required Date</b></font></td>"
        If Global_Inc.C_ShowRoHS = True Then
            l_strHTML = l_strHTML & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
            l_strHTML = l_strHTML & "<font color=""#333333""><b>RoHS</b></font></td>"
        End If
        'DMF_FLAG
        l_strHTML = l_strHTML & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Sales Leads from Advantech (DMF)</b></font></td>"

        l_strHTML = l_strHTML & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Class</b></font></td>"
        l_strHTML = l_strHTML & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Extended Warranty Months</b></font></td>"

        l_strHTML = l_strHTML & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Qty</b></font></td>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333"" align =""right""><b>Price</b></font></td>"
        l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML = l_strHTML & "<font color=""#333333""><b>Subtotal</b></font></td>"
        l_strHTML = l_strHTML & "</tr>"

        Dim l_strSQLCmd As String = ""
        Dim Item_DT As New DataTable
        'Const strSlowMoving As String = " + case max(c.attributea) when 'X' then '<br><FONT COLOR=#FF00OO>Last buy with special price please contact our Sales</FONT>' else '' end "
        Const strSlowMoving As String = ""
        l_strSQLCmd = "select " & _
            "a.currency, " & _
            "a.order_id, " & _
            "b.line_no, " & _
            "IsNull(b.DMF_Flag,'') as DMF_Flag, " & _
            "b.part_no, " & _
            "isnull(b.CustMaterialNo,'') as CustMaterialNo, " & _
            "max(c.product_desc)" & strSlowMoving & " as product_desc," & _
            "IsNull(b.RoHS_FLAG,'N') as RoHS_FLAG, " & _
            "IsNull(c.class,'N') as Class, " & _
            "b.due_date, " & _
            "b.required_date, " & _
            "b.auto_order_flag, " & _
            "b.qty, " & _
            "b.unit_price, " & _
            "IsNull(b.EXWARRANTY_FLAG,'') as EXWARRANTY_FLAG ,b.NoATPFlag " & _
            "from order_master a " & _
            "inner join order_detail b " & _
            "on a.order_id = b.order_id " + _
            "where a.order_no = '" & strPIId & "' and a.billto_id<>'disabled' " & _
            "group by a.currency,b.CustMaterialNo,a.order_id,b.line_no,b.dmf_flag,b.part_no,RoHS_FLAG,Class,b.due_date,b.required_date,b.qty,b.auto_order_flag,b.unit_price,IsNull(b.EXWARRANTY_FLAG,''),b.NoATPFlag  " & _
            "order by b.line_no "
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" select a.currency, a.order_id, b.line_no, IsNull(b.DMF_Flag,'') as DMF_Flag, b.part_no,  "))
            .AppendLine(String.Format(" isnull(b.CustMaterialNo,'') as CustMaterialNo, max(c.product_desc) as product_desc, "))
            .AppendLine(String.Format(" IsNull(case c.RoHS_FLAG when 1 then 'Y' else 'N' end,'N') as RoHS_FLAG,  "))
            .AppendLine(String.Format(" IsNull((select top 1 abc_indicator from sap_product_abc z where z.part_no=b.part_no and left(z.plant,2)='{0}'),'N') as Class,  ", Left(HttpContext.Current.Session("org_id"), 2)))
            .AppendLine(String.Format(" b.due_date, b.required_date, b.auto_order_flag, b.qty, b.unit_price,  "))
            .AppendLine(String.Format(" IsNull(b.EXWARRANTY_FLAG,'') as EXWARRANTY_FLAG, b.NoATPFlag  "))
            .AppendLine(String.Format(" from MyAdvantechGlobal.dbo.order_master a inner join MyAdvantechGlobal.dbo.order_detail b on a.order_id = b.order_id  "))
            .AppendLine(String.Format(" left join sap_product c on b.part_no = c.part_no  "))
            .AppendLine(String.Format(" inner join sap_product_org d on c.part_no=d.part_no and d.org_id='{0}' ", HttpContext.Current.Session("org_id")))
            .AppendLine(String.Format(" where a.order_no = '{0}' and a.billto_id<>'disabled'  ", strPIId))
            .AppendLine(String.Format(" group by a.currency,b.CustMaterialNo,a.order_id,b.line_no,b.dmf_flag, "))
            .AppendLine(String.Format(" b.part_no,c.RoHS_FLAG,b.due_date,b.required_date,b.qty,b.auto_order_flag, "))
            .AppendLine(String.Format(" b.unit_price,IsNull(b.EXWARRANTY_FLAG,''),b.NoATPFlag   "))
            .AppendLine(String.Format(" order by b.line_no  "))
        End With
        Item_DT = dbUtil.dbGetDataTable("B2B", sb.ToString())
        If HttpContext.Current.Session("user_id") = "tc.chen@advantech.com.tw" Then HttpContext.Current.Response.Write(l_strSQLCmd & "<br>")

        '--{2006-08-21}-Daive: For Component Order, hide AGS-EW-**
        'If Global_Inc.IsB2BOwner(HttpContext.Current.Session("user_id")) Or LCase(HttpContext.Current.Session("user_id")) = "sabine.lin@advantech.fr" Then 
        ' Jackie 2007/01/17
        If 1 <> 1 Then
            If Item_DT.Rows.Count > 0 Then
                'If CInt(Item_DT.Rows(0).Item("line_no")) < 100 Then
                Dim xRow As DataRow()
                xRow = Item_DT.Select("part_no like 'AGS-EW-%'")
                For i As Integer = 0 To xRow.Length - 1
                    Item_DT.Rows.Remove(xRow(i))
                Next
                Item_DT.AcceptChanges()
                'End If
            End If
        End If

        Dim flgStdExist As String = "No"
        Dim flgBTOSExist As String = "No"
        Dim flgCTOSExist As String = "No"
        Dim strCurrency As String = ""
        Dim strCurrSign As String = ""

        Dim flgBtosTBD As String = "No"
        Dim flgStdTBD As String = "No"
        Dim fltSubTotal As Decimal = 0
        Dim fltBTOSTotal As Decimal = 0
        Dim fltTotal As Decimal = 0

        If Item_DT.Rows.Count > 0 Then
            strCurrency = Item_DT.Rows(0).Item("currency")
            'Select Case UCase(Item_DT.Rows(0).Item("currency"))
            '    Case "US", "USD"
            '        strCurrSign = "$"
            '    Case "NT"
            '        strCurrSign = "NT"
            '    Case "EUR"
            '        strCurrSign = "&euro;"
            '    Case "GBP"
            '        strCurrSign = "&pound;"
            '    Case Else
            '        strCurrSign = "$"
            'End Select
            strCurrSign = Util.GET_CurrSign_By_Curr(UCase(strCurrency))
            flgBtosTBD = "No"
            flgStdTBD = "No"
            fltSubTotal = 0
            fltBTOSTotal = 0
            Dim intX As Integer = 1

            Do While intX <= Item_DT.Rows.Count
                '--{2005-10-10} Daive: Judge the Change Status
                '--------------------------------------------------------------
                Dim flgChanged As String = "No"
                Dim xChangedSQL As String
                xChangedSQL = "select CHANGED_FLAG from ORDER_DETAIL_CHANGED_IN_SAP where ORDER_NO='" & strPIId & "' and PART_NO='" & Item_DT.Rows(intX - 1).Item("PART_NO") & "'"
                Dim xChangedDR As DataTable
                xChangedDR = dbUtil.dbGetDataTable("B2B", xChangedSQL)
                If xChangedDR.Rows.Count > 0 Then
                    If xChangedDR.Rows(0).Item("CHANGED_FLAG") = 0 Then
                        flgChanged = "Yes"
                    End If
                End If
                'g_adoConn.Close()
                '---------------------------------------------------

                '---- { 24-11-04 } MARK * FOR REAL REQ DATE (START) 
                '---------------------------------------------------
                Dim flgGenunieReq As String = ""
                If CDate(Item_DT.Rows(intX - 1).Item("required_date")).Date <> Date.Today.Date Then
                    flgGenunieReq = "*"
                Else
                    flgGenunieReq = ""
                End If
                'Else
                '    flgGenunieReq = ""
                'End If
                'g_adoConn.Close()
                '-------------------------------------------------
                '---- { 24-11-04 } MARK * FOR REAL REQ DATE (END) 
                '-------------------------------------------------

                If Item_DT.Rows(intX - 1).Item("line_no") >= 100 And flgStdExist = "Yes" And flgBTOSExist = "No" Then
                    l_strHTML = l_strHTML & "<tr>"
                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" colspan=""8""  align =""right"">"
                    If fltSubTotal <= 0 Then
                        l_strHTML = l_strHTML & "<font colspan=""9"" color=""#333333""><b>Sub Total:&nbsp;TBD</b></font></td>"
                    Else
                        If flgStdTBD = "Yes" Then
                            l_strHTML = l_strHTML & "<font colspan=""9"" color=""#333333""><b>Sub Total:&nbsp;" & strCurrSign & FormatNumber(fltSubTotal, 2) & " + TBD</b></font></td>"
                        Else
                            l_strHTML = l_strHTML & "<font colspan=""9"" color=""#333333""><b>Sub Total:&nbsp;" & strCurrSign & FormatNumber(fltSubTotal, 2) & "</b></font></td>"
                        End If
                    End If
                    l_strHTML = l_strHTML & "</tr>"
                End If
                If Global_Inc.C_ShowRoHS = True Then l_strHTML = Replace(l_strHTML, "colspan=""9""", "colspan=""11""")
                If Item_DT.Rows(intX - 1).Item("line_no") < 100 Then
                    flgStdExist = "Yes"
                    '--{2005-10-12}--Daive: Show the Changed Item as bgcolor="#DDA0DD"
                    '---------------------------------------------------------------------------------
                    If Item_DT.Rows(intX - 1).Item("unit_price") <= 0 Then
                        If flgChanged = "Yes" And (HttpContext.Current.Session("xInternalFlag") = "internal_C" Or HttpContext.Current.Session("xInternalFlag") = "external_C") Then
                            l_strHTML = l_strHTML & "<tr style=""BACKGROUND-COLOR: #DDA0DD;WIDTH=100%"">"
                        Else
                            l_strHTML = l_strHTML & "<tr style=""BACKGROUND-COLOR: #ccffff;WIDTH=100%"">"
                        End If
                    Else
                        If flgChanged = "Yes" And (HttpContext.Current.Session("xInternalFlag") = "internal_C" Or HttpContext.Current.Session("xInternalFlag") = "external_C") Then
                            l_strHTML = l_strHTML & "<tr style=""BACKGROUND-COLOR: #DDA0DD;WIDTH=100%"">"
                        Else
                            l_strHTML = l_strHTML & "<tr>"
                        End If
                    End If
                    '---------------------------------------------------------------------------------
                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
                    l_strHTML = l_strHTML & "<font color=""#333333"">" & intX & "&nbsp;</font></td>"
                    '30-06-04 For TDS
                    If Item_DT.Rows(intX - 1).Item("auto_order_flag") = "T" Then
                        l_strHTML = l_strHTML & "<td width=""3%"" bgcolor=""#ccffff"" align =""right"" >"
                    Else
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""3%""  align =""right"">"
                    End If
                    l_strHTML = l_strHTML & "<font color=""#333333"">" & Item_DT.Rows(intX - 1).Item("line_no") & "</font></td>"
                    '**** 22-06-04 Emil Revised for "U" code ****'
                    If Item_DT.Rows(intX - 1).Item("auto_order_flag") = "U" Then
                        l_strHTML = l_strHTML & "<td width=""17%"" style=""BACKGROUND-COLOR: #ffcccc"" align=""left"">"
                    Else
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""17%"" align=""left"">"
                    End If
                    l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & UCase(Item_DT.Rows(intX - 1).Item("part_no")) & "</font></td>"

                    '--CustomerPN
                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""17%"" align=""left"">"
                    l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & UCase(Item_DT.Rows(intX - 1).Item("CustMaterialNo")) & "</font></td>"


                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""30%""   align=""left"">"
                    l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Item_DT.Rows(intX - 1).Item("product_desc") & "</font>"
                    '--{2005-8-22}--Daive: Create a Promotion Flag in description
                    '-----------------------------------------------------------------------------------
                    'If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(HttpContext.Current.Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(HttpContext.Current.Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                    If Global_Inc.PromotionRelease() = True Then
                        If Global_Inc.IsPromoting(UCase(Item_DT.Rows(intX - 1).Item("part_no"))) Then
                            l_strHTML = l_strHTML & "<br><font color=""#FF8C00""><b>(Promotion Item)</b></font>"
                        End If
                    End If

                    'Jackie add 2007/03/28
                    If Item_DT.Rows(intX - 1).Item("part_no").ToString.ToUpper.Trim.IndexOf("AGS-EW-") = 0 Then
                        l_strHTML = l_strHTML & "<br><b> For Line" & Item_DT.Rows(intX - 2).Item("line_no").ToString.Trim & ", P/N=" & Item_DT.Rows(intX - 2).Item("part_no").ToString.Trim & "</b>"
                    End If
                    '-----------------------------------------------------------------------------------
                    l_strHTML = l_strHTML & "</td>"
                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""center"">"
                    'jackie add 2007/08/27

                    If IsGA(HttpContext.Current.Session("Company_id")) Then
                        l_strHTML = l_strHTML & "<font color=""#333333"">To be confirmed within 3 days</font></td>"
                    Else
                        If Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("due_date")) = "2020/10/10" Then
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;TBD</font></td>"
                        Else
                            '--jan add 2009-1-9
                            If Item_DT.Rows(intX - 1).Item("NoATPFlag") = "Y" Then
                                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("due_date")) & "<br><font color=""#ff0000"">&nbsp;for reference only</font></font></td>"
                            Else
                                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("due_date")) & "</font></td>"
                            End If

                        End If
                    End If

                    If Item_DT.Rows(intX - 1).Item("required_date") = Item_DT.Rows(intX - 1).Item("due_date") Then
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%"" align =""center"">"
                    Else
                        l_strHTML = l_strHTML & "<td width=""10%"" align =""center"" style=""BACKGROUND-COLOR: #ffcccc"">"
                    End If
                    l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & flgGenunieReq & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("required_date")) & "</font></td>"
                    If Global_Inc.C_ShowRoHS = True Then
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If Item_DT.Rows(intX - 1).Item("RoHS_FLAG").ToUpper = "Y" Then
                            l_strHTML = l_strHTML & "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/></td>"
                        Else
                            l_strHTML = l_strHTML & "&nbsp;</td>"
                        End If
                        If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Then
                            HttpContext.Current.Response.Write(Item_DT.Rows(intX - 1).Item("RoHS_FLAG").ToUpper)
                        End If
                    End If
                    '<dmf_flag>
                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                    If Item_DT.Rows(intX - 1).Item("DMF_Flag").ToUpper <> "" Then
                        l_strHTML = l_strHTML & "<Input type='checkbox' checked='checked' disabled='disabled'></td>"
                    Else
                        l_strHTML = l_strHTML & "<Input type='checkbox' disabled='disabled'></td>"
                    End If
                    '</dmf_flag>
                    '--class
                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                    If Item_DT.Rows(intX - 1).Item("Class").ToUpper = "A" Or Item_DT.Rows(intX - 1).Item("Class").ToUpper = "B" Then
                        l_strHTML = l_strHTML & "<img  alt=""Hot"" src=""../Images/Hot-Orange.gif""/></td>"
                    Else
                        l_strHTML = l_strHTML & "&nbsp;</td>"
                    End If

                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                    If Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "" Or _
                        Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "0" Or _
                        Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "00" Or _
                        Item_DT.Rows(intX - 1).Item("part_no").ToString.Trim.ToUpper.IndexOf("AGS-EW-") = 0 Then
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;</font></td>"
                    Else
                        l_strHTML = l_strHTML & "<font color=""Red"">&nbsp;" & Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim & "&nbsp;M(s)</font></td>"
                    End If

                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                    l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Item_DT.Rows(intX - 1).Item("qty") & "</font></td>"
                    If Item_DT.Rows(intX - 1).Item("unit_price") <= 0 Then
                        fltSubTotal = CDec(fltSubTotal) + 0
                        flgStdTBD = "Yes"
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;TBD</font></td>"
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;TBD</font></td>"
                        fltBTOSTotal = CDec(fltBTOSTotal) + 0
                    Else
                        fltSubTotal = CDec(fltSubTotal) + CInt(Item_DT.Rows(intX - 1).Item("qty")) * CDec(Item_DT.Rows(intX - 1).Item("unit_price"))
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(Item_DT.Rows(intX - 1).Item("unit_price"), 2) & "</font></td>"
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(Item_DT.Rows(intX - 1).Item("unit_price") * Item_DT.Rows(intX - 1).Item("qty"), 2) & "</font></td>"
                    End If
                    l_strHTML = l_strHTML & "</tr>"
                    '--{2005-10-31}--Daive: Show Alert INFO for Changed Item
                    '--------------------------------------------------------------------------------------
                    Dim alert_SQLCmd As String = ""
                    Dim alert_RS As DataTable
                    'Jackie add 2007/08/27
                    'alert_SQLCmd = "select * from ORDER_DETAIL_CHANGED_IN_SAP where ORDER_NO='" & strPIId & "' and PART_NO='" & Item_DT.Rows(intX - 1).Item("part_no") & "' and order_no like 'FU%' and CHANGED_FLAG=1 order by LINE_NO"
                    'jackie revise 2007/08/30 only exclude TW plant
                    alert_SQLCmd = "select c.* ,d.NoATPFlag from ORDER_DETAIL_CHANGED_IN_SAP c inner join order_detail d " & _
                        " on c.order_id=d.order_id where c.ORDER_NO='" & strPIId & "' and c.LINE_NO='" & Item_DT.Rows(intX - 1).Item("LINE_NO") & "' and c.CHANGED_FLAG=1 and d.DeliveryPlant not like 'TW%' order by LINE_NO"
                    alert_RS = dbUtil.dbGetDataTable("B2B", alert_SQLCmd)
                    'HttpContext.Current.Response.Write(l_adoRs("part_no")&"||"&strOrderNO&"||Error in here!!!"):response.end
                    If alert_RS.Rows.Count > 0 Then
                        'HttpContext.Current.Response.Write("Error in here!!!"):response.end
                        'HttpContext.Current.Response.Write(strOrderNO&"222222222"):response.end
                        l_strHTML = l_strHTML & "<tr><td colspan=""2"" bgcolor=""#ffffff"">&nbsp;</td>"
                        If Global_Inc.C_ShowRoHS = True Then
                            l_strHTML = l_strHTML & "<td colspan=""9"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                        Else
                            l_strHTML = l_strHTML & "<td colspan=""8"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                        End If
                        l_strHTML = l_strHTML & "<font color=""#FF4500"">Line&nbsp;" & alert_RS.Rows(0).Item("LINE_NO") & ":&nbsp;"
                        'HttpContext.Current.Response.Write(strOrderID&strOrderNO):response.end
                        'jackie add 20071204 for z1 atp new rule
                        If alert_RS.Rows(0).Item("NoATPFlag").ToString.ToUpper = "N" Then
                            If DateDiff("d", alert_RS.Rows(0).Item("OLD_DUE_DATE"), alert_RS.Rows(0).Item("NEW_DUE_DATE")) <> 0 Then
                                l_strHTML = l_strHTML & "&nbsp;Due&nbsp;Date&nbsp;(" & Global_Inc.FormatDate(alert_RS.Rows(0).Item("OLD_DUE_DATE")) & "&nbsp;has been changed to&nbsp;" & Global_Inc.FormatDate(alert_RS.Rows(0).Item("NEW_DUE_DATE")) & ")&nbsp;&nbsp;"
                            End If
                        End If

                        If alert_RS.Rows(0).Item("OLD_QTY") <> alert_RS.Rows(0).Item("NEW_QTY") Then
                            If Right(l_strHTML, 1) = ")" Then
                                l_strHTML = l_strHTML & ";"
                            End If
                            l_strHTML = l_strHTML & "&nbsp;QTY&nbsp;(" & alert_RS.Rows(0).Item("OLD_QTY") & "&nbsp;has been changed to&&nbsp;" & alert_RS.Rows(0).Item("NEW_QTY") & ")&nbsp;&nbsp;"
                        End If

                        If FormatNumber(alert_RS.Rows(0).Item("OLD_UNIT_PRICE"), 2) <> FormatNumber(alert_RS.Rows(0).Item("NEW_UNIT_PRICE"), 2) Then
                            If Right(l_strHTML, 1) = ")" Then
                                l_strHTML = l_strHTML & ";"
                            End If
                            l_strHTML = l_strHTML & "&nbsp;Price&nbsp;(" & FormatNumber(alert_RS.Rows(0).Item("OLD_UNIT_PRICE"), 2) & "&nbsp;has been changed to&nbsp;" & FormatNumber(alert_RS.Rows(0).Item("NEW_UNIT_PRICE"), 2) & ")"
                        End If
                        l_strHTML = l_strHTML & "</font></td></tr>"
                        'HttpContext.Current.Response.Write(strOrderID&strOrderNO&"222222222"):response.end         
                    End If
                    'g_adoConn.Close()
                    '--------------------------------------------------------------------------------------
                Else
                    flgBTOSExist = "Yes"
                    If InStr(Item_DT.Rows(intX - 1).Item("part_no"), "CTO") Then
                        flgCTOSExist = "Yes"
                    End If

                    If Item_DT.Rows(intX - 1).Item("line_no") Mod 100 = 0 Then
                        Dim l_strSQLCmdSum As String = ""
                        Dim l_adoDrSum As DataTable
                        l_strSQLCmdSum = "select " & _
                            "max(b.due_date) as BTOItemDueDate, " & _
                            "sum(b.unit_price) as BTOItemSum, " & _
                            "sum(b.unit_price * b.qty) as BTOItemTotalSum " & _
                            "from order_master a " & _
                            "inner join order_detail b " & _
                            "on a.order_id = b.order_id " & _
                            "where " & _
                            "a.order_no = '" & strPIId & "' and " & _
                            "len(b.line_no) >=3 and " & _
                            "left(b.line_no,1) = left(" & Item_DT.Rows(intX - 1).Item("line_no") & ",1) and " & _
                            "b.unit_price >= 0"
                        'HttpContext.Current.Response.Write l_strSQLCmdSum
                        'Response.End
                        l_adoDrSum = dbUtil.dbGetDataTable("B2B", l_strSQLCmdSum)

                        Dim dtBTOItemDueDate As String = ""
                        Dim fltBTOItemSum As Decimal = 0
                        Dim fltBTOItemTotalSum As Decimal = 0

                        If l_adoDrSum.Rows.Count > 0 Then
                            dtBTOItemDueDate = l_adoDrSum.Rows(0).Item("BTOItemDueDate")
                            fltBTOItemSum = l_adoDrSum.Rows(0).Item("BTOItemSum")
                            fltBTOItemTotalSum = l_adoDrSum.Rows(0).Item("BTOItemTotalSum")
                        Else
                            fltBTOItemSum = 0
                            fltBTOItemTotalSum = 0
                        End If
                        l_strHTML = l_strHTML & "<tr style=""font-weight: bold;BACKGROUND-COLOR: #ffffcc;WIDTH=100%"">"
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""Center"">"
                        If flgCTOSExist = "Yes" Then
                            l_strHTML = l_strHTML & "<font color=""BLUE"">BTOS<br>(CTOS)</font>"
                        Else
                            l_strHTML = l_strHTML & "<font color=""BLUE"">BTOS</font>"
                        End If
                        '--{2005-8-22}--Daive: Create a Promotion Flag in description
                        '-----------------------------------------------------------------------------------
                        'If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(HttpContext.Current.Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(HttpContext.Current.Session("USER_ID")) = "emil.hsu@advantech.com.tw" Then
                        If Global_Inc.PromotionRelease() = True Then
                            If Global_Inc.IsPromoting(UCase(Item_DT.Rows(intX - 1).Item("part_no"))) Then
                                l_strHTML = l_strHTML & "<br><font color=""#FF8C00""><b>(Promotion Item)</b></font>"
                            End If
                        End If
                        '-----------------------------------------------------------------------------------
                        l_strHTML = l_strHTML & "</td>"
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""3%""  align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">" & Item_DT.Rows(intX - 1).Item("line_no") & "</font></td>"
                        '**** 22-06-04 Emil Revised for "U" code ****'
                        If Item_DT.Rows(intX - 1).Item("auto_order_flag") = "U" Then
                            l_strHTML = l_strHTML & "<td width=""17%"" style=""BACKGROUND-COLOR: #ffcccc"" align=""left"">"
                        Else
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""17%"" align=""left"">"
                        End If
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & UCase(Item_DT.Rows(intX - 1).Item("part_no")) & "</font></td>"

                        '--CustomerPN
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""17%"" align=""left"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & UCase(Item_DT.Rows(intX - 1).Item("CustMaterialNo")) & "</font></td>"


                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""30%""  align=""left"" >"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Item_DT.Rows(intX - 1).Item("product_desc") & "</font></td>"
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""center"">"
                        If IsGA(HttpContext.Current.Session("Company_id")) Then
                            l_strHTML = l_strHTML & "<font color=""#333333"">To be confirmed within 3 days</font></td>"
                        Else
                            '--jan add 2009-1-9
                            Dim NoATPFlag As String = "N"
                            For i As Integer = 0 To Item_DT.Rows.Count - 1
                                If Item_DT.Rows(i).Item("NoATPFlag") = "Y" Then
                                    NoATPFlag = "Y"
                                End If
                            Next
                            If NoATPFlag = "Y" Then
                                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("due_date")) & "<br><font color=""#ff0000"">&nbsp;for reference only</font></font></td>"
                            Else
                                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("due_date")) & "</font></td>"
                            End If

                        End If
                        If Item_DT.Rows(intX - 1).Item("required_date") = Item_DT.Rows(intX - 1).Item("due_date") Then
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%"" align =""center"">"
                        Else
                            l_strHTML = l_strHTML & "<td width=""10%"" align =""center"" style=""BACKGROUND-COLOR: #ffcccc"">"
                        End If
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & flgGenunieReq & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("required_date")) & "</font></td>"
                        If Global_Inc.C_ShowRoHS = True Then
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                            If Item_DT.Rows(intX - 1).Item("RoHS_FLAG").ToUpper = "Y" Then
                                l_strHTML = l_strHTML & "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/></td>"
                            Else
                                l_strHTML = l_strHTML & "&nbsp;</td>"
                            End If
                        End If
                        '<dmf_flag>
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If Item_DT.Rows(intX - 1).Item("DMF_Flag").ToUpper <> "" Then
                            l_strHTML = l_strHTML & "<Input type='checkbox' checked='checked' disabled='disabled'></td>"
                        Else
                            l_strHTML = l_strHTML & "<Input type='checkbox' disabled='disabled'></td>"
                        End If
                        '</dmf_flag>
                        '--class
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If Item_DT.Rows(intX - 1).Item("Class").ToUpper = "A" Or Item_DT.Rows(intX - 1).Item("Class").ToUpper = "B" Then
                            l_strHTML = l_strHTML & "<img  alt=""Hot"" src=""../Images/Hot-Orange.gif""/></td>"
                        Else
                            l_strHTML = l_strHTML & "&nbsp;</td>"
                        End If

                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        If Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "" Or Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "0" Or Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "00" Then
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;</font></td>"
                        Else
                            l_strHTML = l_strHTML & "<font color=""Red"">&nbsp;" & Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim & "&nbsp;M(s)</font></td>"
                        End If

                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Item_DT.Rows(intX - 1).Item("qty") & "</font></td>"
                        If fltBTOItemSum <= 0 Then
                            fltBTOSTotal = CDec(fltBTOSTotal) + 0
                            flgBtosTBD = "Yes"
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                            l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;TBD</font></td>"
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;TBD</font></td>"
                        Else
                            fltBTOSTotal = CDec(fltBTOSTotal) + CInt(Item_DT.Rows(intX - 1).Item("qty")) * CDec(Item_DT.Rows(intX - 1).Item("unit_price"))
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                            l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(fltBTOItemSum) & "</font></td>"
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(fltBTOItemTotalSum) & "</font></td>"
                        End If
                        l_strHTML = l_strHTML & "</tr>"
                        '--{2005-10-31}--Daive: Show Alert INFO for Changed Item
                        '--------------------------------------------------------------------------------------
                        Dim alert_SQLCmd As String = ""
                        Dim alert_RS As DataTable
                        'jackie add 2007/08/27
                        alert_SQLCmd = "select * from ORDER_DETAIL_CHANGED_IN_SAP where ORDER_NO='" & strPIId & "' and PART_NO='" & Item_DT.Rows(intX - 1).Item("part_no") & "' and order_no like 'FU%' and CHANGED_FLAG=1 order by LINE_NO"
                        alert_RS = dbUtil.dbGetDataTable("B2B", alert_SQLCmd)
                        If alert_RS.Rows.Count > 0 Then
                            If DateDiff("d", alert_RS.Rows(0).Item("OLD_DUE_DATE"), alert_RS.Rows(0).Item("NEW_DUE_DATE")) <> 0 Then

                                'HttpContext.Current.Response.Write(strOrderID&strOrderNO):response.end

                                ' l_strHTML = l_strHTML & "&nbsp;Due&nbsp;Date&nbsp;(" & Global_Inc.FormatDate(alert_RS.Rows(0).Item("OLD_DUE_DATE")) & "&nbsp;has been changed to&nbsp;" & Global_Inc.FormatDate(alert_RS.Rows(0).Item("NEW_DUE_DATE")) & ")&nbsp;&nbsp;"
                            End If
                            If alert_RS.Rows(0).Item("OLD_QTY") <> alert_RS.Rows(0).Item("NEW_QTY") Then
                                l_strHTML = l_strHTML & "<tr><td colspan=""2"" bgcolor=""#ffffff"">&nbsp;</td>"
                                If Global_Inc.C_ShowRoHS = True Then
                                    l_strHTML = l_strHTML & "<td colspan=""9"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                                Else
                                    l_strHTML = l_strHTML & "<td colspan=""8"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                                End If
                                l_strHTML = l_strHTML & "<font color=""#FF4500"">Line&nbsp;" & alert_RS.Rows(0).Item("LINE_NO") & ":&nbsp;"
                                If Right(l_strHTML, 1) = ")" Then
                                    l_strHTML = l_strHTML & ";"
                                End If
                                l_strHTML = l_strHTML & "&nbsp;QTY&nbsp;(" & alert_RS.Rows(0).Item("OLD_QTY") & "&nbsp;has been changed to&nbsp;" & alert_RS.Rows(0).Item("NEW_QTY") & ")&nbsp;&nbsp;"
                            End If
                            If FormatNumber(alert_RS.Rows(0).Item("OLD_UNIT_PRICE"), 2) <> FormatNumber(alert_RS.Rows(0).Item("NEW_UNIT_PRICE"), 2) Then
                                l_strHTML = l_strHTML & "<tr><td colspan=""2"" bgcolor=""#ffffff"">&nbsp;</td>"
                                If Global_Inc.C_ShowRoHS = True Then
                                    l_strHTML = l_strHTML & "<td colspan=""9"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                                Else
                                    l_strHTML = l_strHTML & "<td colspan=""8"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                                End If
                                l_strHTML = l_strHTML & "<font color=""#FF4500"">Line&nbsp;" & alert_RS.Rows(0).Item("LINE_NO") & ":&nbsp;"
                                If Right(l_strHTML, 1) = ")" Then
                                    l_strHTML = l_strHTML & ";"
                                End If
                                l_strHTML = l_strHTML & "&nbsp;Price&nbsp;(" & FormatNumber(alert_RS.Rows(0).Item("OLD_UNIT_PRICE"), 2) & "&nbsp;has been changed to&nbsp;" & FormatNumber(alert_RS.Rows(0).Item("NEW_UNIT_PRICE"), 2) & ")"
                            End If
                            l_strHTML = l_strHTML & "</font></td></tr>"
                            'HttpContext.Current.Response.Write(strOrderID&strOrderNO&"222222222"):response.end         
                        End If
                        'g_adoConn.Close()
                        '--------------------------------------------------------------------------------------
                    Else
                        '--{2005-10-12}--Daive: Show the Changed Item as bgcolor="#DDA0DD"
                        '---------------------------------------------------------------------------------
                        If Item_DT.Rows(intX - 1).Item("unit_price") <= 0 Then
                            If flgChanged = "Yes" And (HttpContext.Current.Session("xInternalFlag") = "internal_C" Or HttpContext.Current.Session("xInternalFlag") = "external_C") Then
                                l_strHTML = l_strHTML & "<tr style=""BACKGROUND-COLOR: #DDA0DD;WIDTH=100%"">"
                            Else
                                l_strHTML = l_strHTML & "<tr style=""BACKGROUND-COLOR: #ccffff;WIDTH=100%"">"
                            End If
                        Else
                            If flgChanged = "Yes" And (HttpContext.Current.Session("xInternalFlag") = "internal_C" Or HttpContext.Current.Session("xInternalFlag") = "external_C") Then
                                l_strHTML = l_strHTML & "<tr style=""BACKGROUND-COLOR: #DDA0DD;WIDTH=100%"">"
                            Else
                                l_strHTML = l_strHTML & "<tr>"
                            End If
                        End If
                        '---------------------------------------------------------------------------------
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;</font></td>"
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""3%""  align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">" & Item_DT.Rows(intX - 1).Item("line_no") & "</font></td>"
                        '**** 22-06-04 Emil Revised for "U" code ****'
                        If Item_DT.Rows(intX - 1).Item("auto_order_flag") = "U" Then
                            l_strHTML = l_strHTML & "<td width=""17%"" style=""BACKGROUND-COLOR: #ffcccc"" align=""left"">"
                        Else
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""17%"" align=""left"">"
                        End If
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & UCase(Item_DT.Rows(intX - 1).Item("part_no")) & "</font></td>"
                        '--CustomerPN
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""17%"" align=""left"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & UCase(Item_DT.Rows(intX - 1).Item("CustMaterialNo")) & "</font></td>"

                        If Left(strPIId, 2) = "FU" Then
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""35%""   colspan=""3"" align=""left"">"
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Item_DT.Rows(intX - 1).Item("product_desc") & "</font></td>"
                        Else
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""35%""  align=""left"" >"
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Item_DT.Rows(intX - 1).Item("product_desc") & "</font></td>"
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""center"">"
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("due_date")) & "</font></td>"
                            If Item_DT.Rows(intX - 1).Item("required_date") = Item_DT.Rows(intX - 1).Item("due_date") Then
                                l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%"" align =""center"">"
                            Else
                                l_strHTML = l_strHTML & "<td width=""10%"" align =""center"" style=""BACKGROUND-COLOR: #ffcccc"">"
                            End If
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(Item_DT.Rows(intX - 1).Item("required_date")) & flgGenunieReq & "</font></td>"
                        End If
                        If Global_Inc.C_ShowRoHS = True Then
                            l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                            If Item_DT.Rows(intX - 1).Item("RoHS_FLAG").ToUpper = "Y" Then
                                l_strHTML = l_strHTML & "<img  alt=""RoHs"" src=""../Images/rohs.jpg""/></td>"
                            Else
                                l_strHTML = l_strHTML & "&nbsp;</td>"
                            End If
                        End If
                        '<dmf_flag>
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If Item_DT.Rows(intX - 1).Item("DMF_Flag").ToUpper <> "" Then
                            l_strHTML = l_strHTML & "<Input type='checkbox' checked='checked' disabled='disabled'></td>"
                        Else
                            l_strHTML = l_strHTML & "<Input type='checkbox' disabled='disabled'></td>"
                        End If
                        '</dmf_flag>
                        '--class
                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""center"">"
                        If Item_DT.Rows(intX - 1).Item("Class").ToUpper = "A" Or Item_DT.Rows(intX - 1).Item("Class").ToUpper = "B" Then
                            l_strHTML = l_strHTML & "<img  alt=""Hot"" src=""../Images/Hot-Orange.gif""/></td>"
                        Else
                            l_strHTML = l_strHTML & "&nbsp;</td>"
                        End If

                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        If Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "" Or Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "0" Or Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim = "00" Then
                            l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;</font></td>"
                        Else
                            l_strHTML = l_strHTML & "<font color=""Red"">&nbsp;" & Item_DT.Rows(intX - 1).Item("EXWARRANTY_FLAG").ToString.Trim & "&nbsp;M(s)</font></td>"
                        End If

                        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""5%""   align =""right"">"
                        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & Item_DT.Rows(intX - 1).Item("qty") & "</font></td>"
                        If Item_DT.Rows(intX - 1).Item("unit_price") <= 0 Then
                            fltBTOSTotal = CDec(fltBTOSTotal) + 0
                            flgBtosTBD = "Yes"
                            If Left(strPIId, 2) = "FU" Then
                                'l_strHTML = l_strHTML & "<td bgcolor=""FFFFFF"" width=""10%""   align =""left"" colspan=""2"">"
                                'l_strHTML = l_strHTML & "<font color=""#333333"" >&nbsp;(TBD)</font></td>"
                                l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;(TBD)</font></td>"
                                l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;(TBD)</font></td>"
                            Else
                                l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;(TBD)</font></td>"
                                l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""15%""   align =""right"">"
                                l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;(TBD)</font></td>"
                            End If
                        Else
                            fltBTOSTotal = CDec(fltBTOSTotal) + CInt(Item_DT.Rows(intX - 1).Item("qty")) * CDec(Item_DT.Rows(intX - 1).Item("unit_price"))
                            If Left(strPIId, 2) = "FU" Then
                                'l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(Item_DT.Rows(intX - 1).Item("unit_price") * Item_DT.Rows(intX - 1).Item("qty"), 2) & "</font></td>"
                                If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(Item_DT.Rows(intX - 1).Item("unit_price"), 2) & "</font></td>"
                                    l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#FFFFFF""  align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(Item_DT.Rows(intX - 1).Item("unit_price") * Item_DT.Rows(intX - 1).Item("qty"), 2) & "</font></td>"
                                Else
                                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333"" align =""right""></font></td>"
                                    l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#FFFFFF""  align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333""></font></td>"
                                End If
                                ''end if

                            Else

                                If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333"" align =""right"">&nbsp;" & strCurrSign & FormatNumber(Item_DT.Rows(intX - 1).Item("unit_price"), 2) & "</font></td>"
                                    l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#FFFFFF""  align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strCurrSign & FormatNumber(Item_DT.Rows(intX - 1).Item("unit_price") * Item_DT.Rows(intX - 1).Item("qty"), 2) & "</font></td>"
                                Else
                                    l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""10%""   align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333"" align =""right""></font></td>"
                                    l_strHTML = l_strHTML & "<td width=""15%"" bgcolor=""#FFFFFF""  align =""right"">"
                                    l_strHTML = l_strHTML & "<font color=""#333333""></font></td>"
                                End If
                            End If
                        End If
                        l_strHTML = l_strHTML & "</tr>"
                        '--{2005-10-31}--Daive: Show Alert INFO for Changed Item
                        '--------------------------------------------------------------------------------------
                        Dim alert_SQLCmd As String = ""
                        Dim alert_RS As DataTable
                        alert_SQLCmd = "select * from ORDER_DETAIL_CHANGED_IN_SAP where ORDER_NO='" & strPIId & "' and PART_NO='" & Item_DT.Rows(intX - 1).Item("part_no") & "' and CHANGED_FLAG=1 order by LINE_NO"
                        alert_RS = dbUtil.dbGetDataTable("B2B", alert_SQLCmd)
                        If alert_RS.Rows.Count > 0 Then

                            If alert_RS.Rows(0).Item("OLD_QTY") <> alert_RS.Rows(0).Item("NEW_QTY") Or FormatNumber(alert_RS.Rows(0).Item("OLD_UNIT_PRICE"), 2) <> FormatNumber(alert_RS.Rows(0).Item("NEW_UNIT_PRICE"), 2) Then
                                l_strHTML = l_strHTML & "<tr><td colspan=""2"" bgcolor=""#ffffff"">&nbsp;</td>"
                                If Global_Inc.C_ShowRoHS = True Then
                                    l_strHTML = l_strHTML & "<td colspan=""10"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                                Else
                                    l_strHTML = l_strHTML & "<td colspan=""9"" bgcolor=""#ffffff"" align=""left"">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;+&nbsp;"
                                End If
                                l_strHTML = l_strHTML & "<font color=""#FF4500"">Line&nbsp;" & alert_RS.Rows(0).Item("LINE_NO") & ":&nbsp;"

                                If alert_RS.Rows(0).Item("OLD_QTY") <> alert_RS.Rows(0).Item("NEW_QTY") Then
                                    l_strHTML = l_strHTML & "&nbsp;QTY&nbsp;(" & alert_RS.Rows(0).Item("OLD_QTY") & "&nbsp;has been changed to&nbsp;" & alert_RS.Rows(0).Item("NEW_QTY") & ")&nbsp;&nbsp;"
                                End If
                                If FormatNumber(alert_RS.Rows(0).Item("OLD_UNIT_PRICE"), 2) <> FormatNumber(alert_RS.Rows(0).Item("NEW_UNIT_PRICE"), 2) Then
                                    If Right(l_strHTML, 1) = ")" Then
                                        l_strHTML = l_strHTML & ";"
                                    End If
                                    l_strHTML = l_strHTML & "&nbsp;Price&nbsp;(" & FormatNumber(alert_RS.Rows(0).Item("OLD_UNIT_PRICE"), 2) & "&nbsp;has been changed to&nbsp;" & FormatNumber(alert_RS.Rows(0).Item("NEW_UNIT_PRICE"), 2) & ")"
                                End If
                                l_strHTML = l_strHTML & "</font></td></tr>"
                            End If
                        End If
                        'g_adoConn.Close()
                        '--------------------------------------------------------------------------------------
                    End If
                End If
                intX = intX + 1
            Loop
        End If

        fltTotal = CDec(fltSubTotal) + CDec(fltBTOSTotal)
        '--{2006-08-21}-Daive: For Component Order, Show SubTotal, Extennded Warranty Fee and Total
        '--SubTotal
        'If Global_Inc.IsB2BOwner(HttpContext.Current.Session("user_id")) Or LCase(HttpContext.Current.Session("user_id")) = "sabine.lin@advantech.fr" Then 
        ' Jackie 20070117
        If 1 <> 1 Then
            Dim EWdt As DataTable
            EWdt = dbUtil.dbGetDataTable("B2B", _
                " select distinct a.Line_No as [Line No.]," + _
                "    a.Part_No as [Part No.]," + _
                "    a.QTY as [Qty]," + _
                "    a.exwarranty_flag as [Extended Months]," + _
                "    [Extended Warranty Fee] = " + _
                "    case when IsNull(a.EXWARRANTY_FLAG,'00') = '03' then" + _
                "            (a.Unit_Price * a.QTY * 1.25 / 100) " + _
                "         when IsNull(a.EXWARRANTY_FLAG,'00') = '06' then" + _
                "            (a.Unit_Price * a.QTY * 2.50 / 100) " + _
                "         when IsNull(a.EXWARRANTY_FLAG,'00') = '12' then" + _
                "            (a.Unit_Price * a.QTY * 5.00 / 100) " + _
                "         when IsNull(a.EXWARRANTY_FLAG,'00') = '24' then" + _
                "            (a.Unit_Price * a.QTY * 8.00 / 100) " + _
                "         when IsNull(a.EXWARRANTY_FLAG,'00') = '36' then" + _
                "            (a.Unit_Price * a.QTY * 12.00 / 100) " + _
                "    End" + _
                " from Order_detail a inner join Order_Master b " + _
                " on a.Order_ID = b.Order_Id" + _
                " where a.exwarranty_flag>0 and b.Order_no='" + strPIId + "'")
            '" where a.line_no<100 and a.exwarranty_flag>0 and b.Order_no='" + strPIId + "'")
            If EWdt.Rows.Count > 0 Then
                l_strHTML = l_strHTML & "<tr>"
                l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" colspan=""10""  align =""right"">"
                If fltTotal <= 0 Then
                    l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") SubTotal:&nbsp;TBD</b></font></td>"
                Else
                    If flgStdTBD = "Yes" Or flgBtosTBD = "Yes" Then
                        l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") SubTotal:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & " + TBD</b></font></td>"
                    Else
                        l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") SubTotal:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & "</b></font></td>"
                    End If
                End If
                l_strHTML = l_strHTML & "</tr>"
                '--Extennded Warranty Fee
                Dim iEWFee As Decimal
                For iEW As Integer = 0 To EWdt.Rows.Count - 1
                    iEWFee = iEWFee + CDec(EWdt.Rows(iEW).Item(4))
                Next
                l_strHTML = l_strHTML & "<tr>"
                l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" colspan=""10""  align =""right"">"
                If iEWFee <= 0 Then
                    l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") Extennded Warranty Fee:&nbsp;TBD</b></font></td>"
                Else
                    l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") Extennded Warranty Fee:&nbsp;" & strCurrSign & FormatNumber(iEWFee, 2) & "</b></font></td>"
                End If
                l_strHTML = l_strHTML & "</tr>"
                fltTotal = fltTotal + iEWFee
            End If
        End If
        '----End-----
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" colspan=""10""  align =""right"">"
        If fltTotal <= 0 Then
            l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;TBD</b></font></td>"
        Else
            If flgStdTBD = "Yes" Or flgBtosTBD = "Yes" Then
                l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & " + TBD</b></font></td>"
            Else
                l_strHTML = l_strHTML & "<font color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & FormatNumber(fltTotal, 2) & "</b></font></td>"
            End If
        End If
        If Global_Inc.C_ShowRoHS = True Then l_strHTML = Replace(l_strHTML, "colspan=""10""", "colspan=""14""")
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "</table>"
        'l_strHTML = l_strHTML & "</td></tr></table>"
        l_strHTML = l_strHTML & "</td></tr></table>"
        'HttpContext.Current.Response.Write l_strHTML
        p_strHTML = l_strHTML
        l_strHTML = Nothing
        'g_adoConn.Dispose()
        Return 1
    End Function

    '============RoHS Terms Version 2 {2006/08/01 - ????/??/??}
    Public Shared Function GetRoHSTerms(ByVal strLogistics_ID As String, ByVal xType As String, ByRef strRoHSTermsHTML As String) As String
        Dim strATCustomerHTML As String = ""
        Dim strATNonRoHSHTML As String = ""

        strRoHSTermsHTML = ""
        InitATCustomer(strLogistics_ID, xType, strATCustomerHTML)
        InitATNonRoHS(strLogistics_ID, xType, strATNonRoHSHTML)
        strRoHSTermsHTML &= "<table width=""100%"">"
        strRoHSTermsHTML &= "<tr>"
        strRoHSTermsHTML &= "    <td width=""100%"" align=""left"">"
        strRoHSTermsHTML &= "        <br />"
        strRoHSTermsHTML &= "        <h3>Acknowledgement of Non-RoHS conformed products</h3>"
        strRoHSTermsHTML &= "    </td>"
        strRoHSTermsHTML &= "</tr>"
        strRoHSTermsHTML &= "<tr>"
        strRoHSTermsHTML &= "    <td style=""height:6px"" align=""left"">"
        strRoHSTermsHTML &= "        <font size=""2"">Hereby the customer acknowledges the following Advantech products are not conformed to ROHS regulation and agrees to accept the shipments. </font><br /><br />"
        strRoHSTermsHTML &= "    </td>"
        strRoHSTermsHTML &= "</tr>"
        strRoHSTermsHTML &= "<tr>"
        strRoHSTermsHTML &= "    <td width=""100%"">"
        strRoHSTermsHTML &= strATCustomerHTML
        strRoHSTermsHTML &= "    </td>"
        strRoHSTermsHTML &= "</tr>"
        strRoHSTermsHTML &= "<tr>"
        strRoHSTermsHTML &= "    <td width=""100%"">"
        strRoHSTermsHTML &= strATNonRoHSHTML
        strRoHSTermsHTML &= "    </td>"
        strRoHSTermsHTML &= "</tr>"
        strRoHSTermsHTML &= "</table>"
        Return strRoHSTermsHTML

    End Function

    Protected Shared Sub InitATCustomer(ByVal strLogistics_ID As String, ByVal xType As String, ByRef ATCustomerHTML As String)
        Dim strSelect As String = ""
        strSelect = "select " & _
                    "b.company_id, " & _
                    "b.company_name," & _
                    "(IsNull(b.address,'') + ' ' + IsNull(b.city,'') + ', ' + IsNull(b.country,'')) as address," & _
                    "IsNull(b.tel_no,'') as tel_no, " & _
                    "IsNull(b.fax_no,'') as fax_no," & _
                    "IsNull(a.attention,'') as attention " & _
                    "from " & xType & "_master a " & _
                    "inner join sap_dimcompany b " & _
                    "on a.soldto_id = b.company_id and b.company_type='Partner' " & _
                    "where a." & xType & "_id = '" & strLogistics_ID & "'"

        Dim CustDT As DataTable = dbUtil.dbGetDataTable("B2B", strSelect)
        If CustDT.Rows.Count > 0 Then
            ATCustomerHTML &= "<table width=""100%"" border=""0"">"
            ATCustomerHTML &= "<tr>"
            ATCustomerHTML &= "<td width=""5%"" bgcolor=""#FFFFFF"" align=""left"">"
            ATCustomerHTML &= "<font size=""3""><b>Customer:</b></font>"
            ATCustomerHTML &= "</td>"
            ATCustomerHTML &= "<td align=""left"">"
            ATCustomerHTML &= CustDT.Rows(0).Item("company_name") & "&nbsp;(" & CustDT.Rows(0).Item("company_id") & ")"
            ATCustomerHTML &= "</td>"
            ATCustomerHTML &= "</tr>"
            ATCustomerHTML &= "</table>"
        End If
    End Sub

    Public Shared Sub InitATNonRoHS(ByVal strLogistics_ID As String, ByVal xType As String, ByRef ATNonRoHSHTML As String)
        Dim strSelect As String = ""
        strSelect = "select "
        If xType.ToUpper = "ORDER" Then
            strSelect &= "a.Order_NO,"
        End If
        strSelect &= "a.currency, " & _
                    "b.line_no, " & _
                    "b.part_no, " & _
                    "max(c.product_desc) as product_desc," & _
                    "b.due_date, " & _
                    "b.required_date, " & _
                    "b.qty, " & _
                    "b.unit_price " & _
                    "from " & xType & "_master a " & _
                    "inner join " & xType & "_detail b " & _
                    "on a." & xType & "_id = b." & xType & "_id " & _
                    "left join sap_product c " & _
                    " on b.part_no = c.part_no inner join sap_product_org d  " + _
                    " on c.part_no=d.part_no and d.org_id='" + HttpContext.Current.Session("org_id") + "' "

        If xType.ToUpper = "ORDER" Then
            strSelect &= "where a." & xType & "_id = '" & strLogistics_ID & "'and line_no<>100 and IsNull(b.RoHS_FLAG,'') = 'n' and b.part_no not like 'option%' and b.part_no not like 'AGS-EW-%' and b.part_no not like 'CTOS-%-N?' " & _
                         "group by a.Order_NO,a.currency,b.line_no, b.part_no,b.due_date,b.required_date,b.qty,b.unit_price " & _
                         "order by b.line_no "
        Else
            strSelect &= "where a." & xType & "_id = '" & strLogistics_ID & "'and line_no<>100 and IsNull(c.RoHS_Flag,0) <> 1 and b.part_no not like 'option%' and b.part_no not like 'AGS-EW-%' and b.part_no not like 'CTOS-%-N?' " & _
                         "group by a.currency,b.line_no, b.part_no,b.due_date,b.required_date,b.qty,b.unit_price " & _
                         "order by b.line_no "
        End If
        'HttpContext.Current.Response.Write(strSelect) : Response.End()
        Dim ItemDT As DataTable = dbUtil.dbGetDataTable("B2B", strSelect)
        If ItemDT.Rows.Count > 0 Then
            ATNonRoHSHTML &= "<table width=""100%"" border=""0"">"
            ATNonRoHSHTML &= "<tr>"
            ATNonRoHSHTML &= "<td  colspan=""6"" valign=""bottom"" align=""left"">"
            ATNonRoHSHTML &= "<font size=""3""><b>Products</b></font>"
            If xType.ToUpper = "ORDER" Then
                ATNonRoHSHTML &= "<font size=""3""><b>&nbsp;(Order Number:&nbsp;" & ItemDT.Rows(0).Item("Order_NO") & ")&nbsp;</b></font>"
            End If
            ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "</tr>"
            ATNonRoHSHTML &= "<tr>"
            ATNonRoHSHTML &= "<td  colspan=""6"" valign=""top"" align=""left"">"
            ATNonRoHSHTML &= "<hr/>"
            ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "</tr>"
            ATNonRoHSHTML &= "<tr>"
            'ATNonRoHSHTML &= "<td width=""10%"" bgcolor=""FFFFFF"" align=""left"">"
            'ATNonRoHSHTML &= "<b><u>Line NO.</u></b>"
            'ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "<td width=""30%"" align=""left"">"
            ATNonRoHSHTML &= "<b><u>Part NO</u></b>"
            ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "<td width=""40%"" align=""left"">"
            ATNonRoHSHTML &= "<b><u>Description</u></b>"
            ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "<td width=""10%"">"
            'ATNonRoHSHTML &= "<b><u>Quantity</u></b>"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "<td width=""10%"" rowspan=""2"">"
            'ATNonRoHSHTML &= "<b><u>Unit Price</u></b>"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "<td width=""10%""  rowspan=""2"">"
            'ATNonRoHSHTML &= "<b><u>Due Date</u></b>"
            'ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "<td width=""20%"" align=""left"">"
            ATNonRoHSHTML &= "<b><u>RoHS</u></b>"
            ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "</tr>"
            For i As Integer = 0 To ItemDT.Rows.Count - 1
                ATNonRoHSHTML &= "<tr>"
                'ATNonRoHSHTML &= "<td width=""10%"" bgcolor=""FFFFFF"" align=""left"">"
                'ATNonRoHSHTML &= ItemDT.Rows(i).Item("Line_NO")
                'ATNonRoHSHTML &= "</td>"
                ATNonRoHSHTML &= "<td width=""30%"" align=""left"">"
                ATNonRoHSHTML &= ItemDT.Rows(i).Item("Part_NO")
                ATNonRoHSHTML &= "</td>"
                ATNonRoHSHTML &= "<td width=""40%"" align=""left"">"
                ATNonRoHSHTML &= ItemDT.Rows(i).Item("product_desc")
                ATNonRoHSHTML &= "</td>"
                'ATNonRoHSHTML &= "<td width=""10%"">"
                'ATNonRoHSHTML &= ItemDT.Rows(i).Item("qty")
                'ATNonRoHSHTML &= "</td>"
                'ATNonRoHSHTML &= "<td width=""10%"" rowspan=""2"">"
                'ATNonRoHSHTML &= ItemDT.Rows(i).Item("unit_price")
                'ATNonRoHSHTML &= "</td>"
                'ATNonRoHSHTML &= "<td width=""10%""  rowspan=""2"">"
                'ATNonRoHSHTML &= ItemDT.Rows(i).Item("due_date")
                'ATNonRoHSHTML &= "</td>"
                ATNonRoHSHTML &= "<td width=""20%"" align=""left"">"
                ATNonRoHSHTML &= "<b><font color=""red"">Non-RoHS</font></b>"
                ATNonRoHSHTML &= "</td>"
                ATNonRoHSHTML &= "</tr>"
            Next
            ATNonRoHSHTML &= "<tr>"
            ATNonRoHSHTML &= "<td colspan=""7"">"
            ATNonRoHSHTML &= "&nbsp;"
            ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "</tr>"
            '2006-06-20 Emil 
            'ATNonRoHSHTML &= "<tr>"
            'ATNonRoHSHTML &= "<td colspan=""2"" align=""center""><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u>"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "<td colspan=""2"" align=""center""><u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u>"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "<td colspan=""3"">"
            'ATNonRoHSHTML &= "&nbsp;"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "</tr>"
            'ATNonRoHSHTML &= "<td colspan=""2"" align=""center"">"
            'ATNonRoHSHTML &= "place, signature"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "<td colspan=""2"" align=""center"">"
            'ATNonRoHSHTML &= "signature customer"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "<td colspan=""3"">"
            'ATNonRoHSHTML &= "&nbsp;"
            'ATNonRoHSHTML &= "</td>"
            'ATNonRoHSHTML &= "</tr>"
            ATNonRoHSHTML &= "<tr>"
            ATNonRoHSHTML &= "<td colspan=""7"">"
            ATNonRoHSHTML &= "<hr/>"
            ATNonRoHSHTML &= "</td>"
            ATNonRoHSHTML &= "</tr>"
            ATNonRoHSHTML &= "</table>"
        End If
    End Sub

    Public Shared Function LogisticsMaster_Update(ByVal strLogistics_ID As String, ByVal dtDue_Date As String, _
    ByVal dtRequired_Date As String, ByVal strCurrency As String, ByVal strSoldTo_ID As String, ByVal strBillTo_ID As String, _
    ByVal strShipTo_ID As String, ByVal strPO_NO As String, ByVal strPODate As String, ByVal dtTotal_ATP_Date As String, _
    ByVal fltTotal_Amount As Double, ByVal strAttention As String, ByVal strShipment_Term As String, ByVal strPartial_Flag As String, _
    ByVal strCombine_Order_Flag As String, ByVal strEarly_Ship_Flag As String, ByVal strShip_VIA As String, ByVal strRemark As String, _
    ByVal fltFreight As Double, ByVal fltInsurance As Double, ByVal strCustomer_Attention As String, ByVal strAuto_Order_Flag As String, _
    ByVal strPayment_Type As String, ByVal strOrder_Note As String, ByVal strINCOTERM As String, ByVal strINCOTERM_TEXT As String, _
    ByVal strSALES_NOTE As String, ByVal strOP_NOTE As String, ByVal strShip_Condition As String, ByVal Sales_Id As String, _
    ByVal ProjectFlag As String, ByVal Z7Sales As String, ByVal strPrjNote As String) As Integer
        Dim strSQL As String = ""
        strSQL = "Update Logistics_Master Set Due_Date = '" & dtDue_Date & "',Required_Date = '" & dtRequired_Date & _
        "',Currency = '" & strCurrency & "',SoldTo_ID = '" & strSoldTo_ID & "',BillTo_ID = '" & strBillTo_ID & _
        "',ShipTo_ID = '" & strShipTo_ID & "',PO_NO = '" & strPO_NO & "',PO_DATE = '" & strPODate & _
        "',Total_ATP_Date = '" & dtTotal_ATP_Date & "',Total_Amount = " & fltTotal_Amount & ",Attention = N'" & strAttention & _
        "',Shipment_Term = '" & strShipment_Term & "',Partial_Flag = '" & strPartial_Flag & "',Combine_Order_Flag = '" & _
        strCombine_Order_Flag & "',Early_Ship_Flag = '" & strEarly_Ship_Flag & "',Ship_VIA = '',Remark = N'" & strRemark & _
        "',Freight = " & fltFreight & ",Insurance = " & fltInsurance & ",Customer_Attention = N'" & strCustomer_Attention & _
        "' , Auto_Order_Flag = '" & strAuto_Order_Flag & "' , Payment_type = '" & strPayment_Type & "', Order_Note= '" & strOrder_Note & _
        "',INCOTERM= '" & strINCOTERM & "',prj_note= '" & strPrjNote & "',INCOTERM_TEXT= '" & strINCOTERM_TEXT & "',SALES_NOTE= '" & strSALES_NOTE & _
        "',OP_NOTE= '" & strOP_NOTE & "',SHIP_CONDITION='" & strShip_Condition & "',sales_id='" & Sales_Id & "'," & _
                 "ProjectFlag='" & ProjectFlag & "',Z7Sales='" & Z7Sales & "' " & _
                 "Where Logistics_ID = '" & strLogistics_ID & "'"
        Try
            dbUtil.dbExecuteNoQuery("B2B", strSQL)
        Catch ex As Exception
            LogisticsMaster_Update = -1
            Exit Function
        End Try
        LogisticsMaster_Update = 1
    End Function

    '--{2005-9-28}--Daive: Memory Incoterm,Incoterm_Text,SalesNote and OPNote to Order_Master
    '-----------------------------------------------------------------------------------------
    Shared Sub clearOrder(ByVal order_no As String)
        Dim dt As DataTable = dbUtil.dbGetDataTable("b2b", String.Format("select order_id from order_master where order_no='{0}'", order_no))
        If dt.Rows.Count > 0 Then
            For Each r As DataRow In dt.Rows
                dbUtil.dbExecuteNoQuery("b2b", String.Format("delete from order_detail where order_id='{0}'", r.Item("order_id")))
                dbUtil.dbExecuteNoQuery("b2b", String.Format("delete from order_master where order_id='{0}'", r.Item("order_id")))
            Next
        End If
    End Sub
    Public Shared Function OrderMaster_Insert(ByVal strOrder_ID As String, ByVal strOrder_No As String, ByVal strOrder_Type As String, _
    ByVal strPO_No As String, ByVal strPODate As String, ByVal strSoldTo_ID As String, ByVal strShipTo_ID As String, _
    ByVal strBillTo_ID As String, ByVal strSales_ID As String, ByVal dtOrder_Date As String, ByVal strPayment_Type As String, _
    ByVal strAttention As String, ByVal strPartial_Flag As String, ByVal strCombine_Order_Flag As String, _
    ByVal strEarly_Ship_Flag As String, ByVal fltFreight As Double, _
    ByVal fltInsurance As Double, ByVal strCustomer_Attention As String, ByVal strShipment_Term As String, ByVal strRemark As String, _
    ByVal strProduct_Site As String, ByVal dtDue_Date As String, ByVal dtRequired_Date As String, ByVal strShip_VIA As String, _
    ByVal strCurrency As String, ByVal strOrder_Note As String, ByVal strOrder_Status As String, ByVal fltTotal_Amount As Double, _
    ByVal intTotal_Line As Integer, ByVal strCreated_By As String, ByVal strAuto_Order_Flag As String, ByVal strIncoterm As String, _
    ByVal strIncoterm_Text As String, ByVal strSales_Note As String, ByVal strOP_Note As String, ByVal strShip_Condition As String) As Integer
        Dim strSQL As String = ""
        strSQL = "Insert into Order_Master(Order_ID, Order_No, Order_Type, PO_No, PO_DATE, SoldTo_ID, ShipTo_ID, BillTo_ID, Sales_ID, Order_Date, Payment_Type, Attention, Partial_Flag, Combine_Order_Flag, Early_Ship_Flag, Freight, Insurance, Customer_Attention, Shipment_Term, Remark, Product_Site, Due_Date , Required_Date, Ship_VIA, Currency, Order_Note, Order_Status, Total_Amount, Total_Line, Created_By,Auto_Order_Flag,INCOTERM,INCOTERM_TEXT,SALES_NOTE,OP_NOTE,SHIP_CONDITION)" & _
                 "values('" & strOrder_ID & "','" & strOrder_No & "','" & strOrder_Type & "','" & strPO_No & "','" & strPODate & "','" & strSoldTo_ID & "','" & strShipTo_ID & "','" & strBillTo_ID & "','" & strSales_ID & "','" & dtOrder_Date & "','" & strPayment_Type & "',N'" & strAttention & "','" & strPartial_Flag & "','" & strCombine_Order_Flag & "','" & strEarly_Ship_Flag & "'," & fltFreight & "," & fltInsurance & ",N'" & strCustomer_Attention & "','" & strShipment_Term & "',N'" & strRemark & "','" & strProduct_Site & "','" & dtDue_Date & "','" & dtRequired_Date & "',N'" & strShip_VIA & "','" & strCurrency & "',N'" & strOrder_Note & "','" & strOrder_Status & "'," & fltTotal_Amount & "," & intTotal_Line & ",'" & strCreated_By & "' , '" & strAuto_Order_Flag & "','" & strIncoterm & "','" & strIncoterm_Text & "',N'" & strSales_Note & "',N'" & strOP_Note & "','" & strShip_Condition & "' )"
        dbUtil.dbExecuteNoQuery("B2B", strSQL)
        Return 1
    End Function

    Public Shared Function OrderDetail_Insert(ByVal strOrder_ID As String, ByVal intLine_No As Integer, ByVal strProduct_Line As String, _
    ByVal strPart_No As String, ByVal strOrder_Line_type As String, ByVal intQTY As Integer, ByVal fltList_Price As Double, _
    ByVal fltUnit_Price As Double, ByVal dtDue_Date As String, ByVal strERP_Site As String, ByVal strERP_Location As String, _
    ByVal dtRequired_Date As String, ByVal strAuto_Order_Flag As String, ByVal intAuto_Order_QTY As Integer, _
    ByVal strSupplier_Due_Date As String, ByVal intLine_Partial_Flag As String) As Integer
        If IsDBNull(intLine_Partial_Flag) Or intLine_Partial_Flag = "" Or intLine_Partial_Flag <> 1 Then
            intLine_Partial_Flag = 0
        End If
        Dim strSQL As String = ""

        strSQL = "Insert into Order_Detail(Order_ID,Line_No,Product_Line,Part_No,Order_Line_type,QTY,List_Price,Unit_Price,Due_Date,ERP_Site,ERP_Location,Required_Date,Auto_Order_Flag,Auto_Order_QTY,Supplier_Due_Date,Line_Partial_Flag)" & _
                 "values('" & strOrder_ID & "'," & intLine_No & ",'" & strProduct_Line & "','" & strPart_No & "','" & strOrder_Line_type & "'," & intQTY & "," & fltList_Price & "," & fltUnit_Price & ",'" & dtDue_Date & "','" & strERP_Site & "','" & strERP_Location & "','" & dtRequired_Date & "','" & strAuto_Order_Flag & "'," & intAuto_Order_QTY & ",'" & strSupplier_Due_Date & "'," & intLine_Partial_Flag & ")"
        dbUtil.dbExecuteNoQuery("B2B", strSQL)
        Return 1
    End Function

    '--------------------------------------
    '---- Function: Logisticsinfo_ExportByDB()
    '----	1. ByVal strLogistics_ID
    '----	2. ByRef rsLogisticsMaster
    '----	3. ByRef rsLogisticsDetail

    Public Shared Function Logisticsinfo_ExportByDB(ByVal strLogistics_ID As String, ByRef dtLogisticsMaster As DataTable, _
    ByRef dtLogisticsDetail As DataTable) As String
        Logisticsinfo_ExportByDB = ""
        Dim strSQL As String = ""
        strSQL = "Select [LOGISTICS_ID],isnull([DUE_DATE],'') as [DUE_DATE],isnull([REQUIRED_DATE],'') as [REQUIRED_DATE],isnull([CURRENCY],'') as [CURRENCY],isnull([SOLDTO_ID],'') as [SOLDTO_ID],isnull([BILLTO_ID],'') as [BILLTO_ID],isnull([SHIPTO_ID],'') as [SHIPTO_ID],isnull([PO_NO],'') as [PO_NO],isnull([PO_DATE],'') as [PO_DATE],isnull([PAYMENT_TYPE],'') as [PAYMENT_TYPE],isnull([TOTAL_ATP_DATE],'') as [TOTAL_ATP_DATE],isnull([TOTAL_AMOUNT],'') as [TOTAL_AMOUNT],isnull([CREATED_DATE],'') as [CREATED_DATE],isnull([ATTENTION],'') as [ATTENTION],isnull([SHIPMENT_TERM],'') as [SHIPMENT_TERM],isnull([PARTIAL_FLAG],'') as [PARTIAL_FLAG],isnull([COMBINE_ORDER_FLAG],'') as [COMBINE_ORDER_FLAG],isnull([EARLY_SHIP_FLAG],'') as [EARLY_SHIP_FLAG],isnull([SHIP_VIA],'') as [SHIP_VIA],isnull([REMARK],'') as [REMARK],isnull([FREIGHT],'') as [FREIGHT],isnull([INSURANCE],'') as [INSURANCE],isnull([CUSTOMER_ATTENTION],'') as [CUSTOMER_ATTENTION],isnull([AUTO_ORDER_FLAG],'') as [AUTO_ORDER_FLAG],isnull([ORDER_NOTE],'') as [ORDER_NOTE],isnull([INCOTERM],'') as [INCOTERM],isnull([INCOTERM_TEXT],'') as [INCOTERM_TEXT],isnull([SALES_NOTE],'') as [SALES_NOTE],isnull([OP_NOTE],'') as [OP_NOTE],isnull([SHIP_CONDITION],'') as [SHIP_CONDITION],isnull([Sales_Id],'') as [Sales_Id],isnull([ProjectFlag],'') as [ProjectFlag],isnull([Z7Sales],'') as [Z7Sales],isnull([DefaultSalesNote],'') as [DefaultSalesNote] from Logistics_Master where Logistics_ID = '" & strLogistics_ID & "'"
        dtLogisticsMaster = dbUtil.dbGetDataTable("B2B", strSQL)

        If dtLogisticsMaster.Rows.Count <= 0 Then
            Logisticsinfo_ExportByDB = "0001"  ' could not find the record
        Else
            strSQL = ""
            strSQL = "Select * from Logistics_Detail where Logistics_ID = '" & strLogistics_ID & "' Order By Line_No"
            dtLogisticsDetail = dbUtil.dbGetDataTable("B2B", strSQL)
            If dtLogisticsDetail.Rows.Count <= 0 Then
                Logisticsinfo_ExportByDB = "0001"
            End If
        End If
        Return Logisticsinfo_ExportByDB
    End Function

    Public Shared Function NewOrderNo_Get(ByRef p_strOrder_No As String) As Integer
        Dim exeFunc As Integer = 0
        Dim strOrderPrifix As String = ""
        Dim strCurrentOrderSeq As String = ""
        Dim intCurrentOrderSeq As Long
        'Global_Inc.SiteDefinition_Get("SOPrifix", strOrderPrifix)
        strOrderPrifix = "QT"
        'jackie add 2007/08/27
        'Dim dt As New DataTable
        'dt = dbUtil.dbGetDataTable("B2B", "select DeliveryPlant from logistics_detail where logistics_id='" & _
        '                       HttpContext.Current.Session("logistics_id") & "' and DeliveryPlant like 'TW%'")
        'If dt.Rows.Count > 0 Then
        '    strOrderPrifix = "FT"
        'End If
        Global_Inc.SiteDefinition_Get("OrderSeqNo", strCurrentOrderSeq)
        intCurrentOrderSeq = CLng(strCurrentOrderSeq)
        dbUtil.dbExecuteNoQuery("B2B", "update site_definition set para_value='" & CStr(intCurrentOrderSeq + 1) & "' where  site_parameter='OrderSeqNo'")
        p_strOrder_No = strOrderPrifix & intCurrentOrderSeq

        Return 1
    End Function

    Public Shared Function SalesId_Get(ByVal strOrg_Id As String, ByVal strCompany_Id As String, ByRef p_strSales_Id As String) As Integer
        Dim l_strSqlCmd As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim adoDR As DataTable
        l_strSqlCmd = "select " & _
                      "sales_person1 from company_sales " & _
                      "where " & _
                      "org_id = '" & strOrg_Id & "' and " & _
                      "company_id = '" & strCompany_Id & "'"
        adoDR = dbUtil.dbGetDataTable("B2B", l_strSqlCmd)
        If adoDR.Rows.Count > 0 Then
            p_strSales_Id = adoDR.Rows(0).Item("sales_person1")
            SalesId_Get = 1
        Else
            SalesId_Get = 0
        End If
        'g_adoConn.Close()
        'g_adoConn.Dispose()
        Return SalesId_Get

    End Function

    'Public Shared Function TransferFromLogisticsToOrderByDB_new( _
    'ByVal strLogistics_ID As String, _
    'ByVal strOrder_ID As String, _
    'ByRef p_strOrder_No As String) As Integer
    '    p_strOrder_No = getOrderNumberOracle(strOrder_ID)
    '    'strOrder_ID = strLogistics_ID

    '    Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
    '    "select top 1 * from logistics_master where logistics_id='" + strLogistics_ID + "'")
    '    If dt Is Nothing Then Return 0 : Exit Function
    '    If dt.Rows.Count = 0 Then Return 0 : Exit Function

    '    dt = dbUtil.dbGetDataTable("B2B", _
    '            "select top 1 part_no from logistics_detail where logistics_id='" + strLogistics_ID + "'")
    '    If dt Is Nothing Then Return 0 : Exit Function
    '    If dt.Rows.Count = 0 Then Return 0 : Exit Function

    '    'NewOrderNo_Get(p_strOrder_No)
    '    'jackie add 20071218 for duplicated SO issue
    '    If dbUtil.dbGetDataTable("B2B", "select order_no from order_master where order_no='" & _
    '                p_strOrder_No & "'").Rows.Count > 0 Then
    '        Return -1
    '    End If

    '    Dim sc As New StringCollection
    '    sc.Add("delete order_master where order_id='" + strOrder_ID + "'")
    '    sc.Add("delete order_detail where order_id='" + strOrder_ID + "'")

    '    Dim strMaster As String = _
    '    "INSERT INTO order_master" + _
    '    "(order_id,order_no,order_type,po_no,po_date,soldto_id,shipto_id,billto_id,sales_id,order_date, " + _
    '    "attention,partial_flag,freight,insurance,due_date,required_date,shipment_term,ship_via," + _
    '    "currency,order_note,total_amount,created_date,created_by,customer_attention,auto_order_flag, " + _
    '    "incoterm,incoterm_text,sales_note,op_note,ship_condition,NONERoHs_ACCEPT,remark,ProjectFlag,Z7Sales,DefaultSalesNote,prj_note)" + _
    '    "SELECT logistics_id as order_id,'" + p_strOrder_No + _
    '    "' as order_no,'SO' as order_type,po_no,po_date,soldto_id,shipto_id, " + _
    '    "billto_id,sales_id,getdate() as order_date,attention,partial_flag,freight,insurance,due_date,required_date, " + _
    '    "shipment_term,ship_via,currency,order_note,total_amount,created_date,'" & HttpContext.Current.Session("USER_ID") & "' as created_by, " + _
    '    "attention as customer_attention,IsNull(auto_order_flag,'') as auto_order_flag,incoterm,incoterm_text,sales_note,op_note, " + _
    '    "ship_condition,''as NONRoHs_ACCEPT, '' as remark,ProjectFlag,Z7Sales,DefaultSalesNote,prj_note " + _
    '    "FROM logistics_master " + _
    '    "where logistics_id='" + strLogistics_ID + "'"
    '    sc.Add(strMaster)

    '    '--Daive: Add "CustMaterialNo"
    '    '--Jackie add Delivery Plant    2007/08/23 
    '    Dim strDetail As String = _
    '    "INSERT INTO order_detail" + _
    '    "(order_id,line_no,part_no,qty,list_price,unit_price,required_date,due_date,exwarranty_flag, " + _
    '    "line_partial_flag,auto_order_flag,CustMaterialNo,DeliveryPlant,NoATPFlag,DMF_Flag,Optyid) " + _
    '    "SELECT	l.logistics_id as order_id,l.line_no,l.part_no,l.qty,l.list_price,l.unit_price,l.required_date," + _
    '    "l.due_date, l.exwarranty_flag, 0 as line_partial_flag,IsNull(l.auto_order_flag,'N') as auto_order_flag,IsNull(c.CustMaterialNo,'') as CustMaterialNo,l.DeliveryPlant,l.NoATPFlag,l.DMF_Flag,l.optyid " + _
    '    "FROM logistics_detail l left join CustMaterialMapping c " + _
    '    "  ON l.PART_NO = c.MaterialNo and c.org='EU10' and c.DistrChannel='00' and c.CustomerId='" + HttpContext.Current.Session("COMPANY_ID") + "'" + _
    '    "where l.logistics_id='" + strLogistics_ID + "'"

    '    'Dim strDetail As String = _
    '    '"INSERT INTO order_detail" + _
    '    '"(order_id,line_no,part_no,qty,list_price,unit_price,required_date,due_date,exwarranty_flag, " + _
    '    '"line_partial_flag,auto_order_flag) " + _
    '    '"SELECT	logistics_id as order_id,line_no,part_no,qty,list_price,unit_price,required_date," + _
    '    '"due_date, exwarranty_flag, 0 as line_partial_flag,IsNull(auto_order_flag,'N') as auto_order_flag " + _
    '    '"FROM logistics_detail " + _
    '    '"where logistics_id='" + strLogistics_ID + "'"

    '    sc.Add(strDetail)
    '    Global_Inc.ExecuteSqls("172.21.34.9", "b2b_aesc_sap", "b2bsa", "@dvantech!", sc)
    '    Return 1

    'End Function

    'Public Shared Function TransferFromLogisticsToOrderByDB(ByVal strLogistics_ID As String, ByVal strOrder_ID As String, _
    'ByRef p_strOrder_No As String) As Integer
    '    Dim z As String = ""
    '    Dim dtLogisticsMaster, dtLogisticsDetail As New DataTable
    '    z = Logisticsinfo_ExportByDB(strLogistics_ID, dtLogisticsMaster, dtLogisticsDetail)
    '    If z = "0001" Then
    '        HttpContext.Current.Response.Write("Could not find the record!!")
    '    Else
    '        Dim i As Integer = 0
    '        While i <= dtLogisticsMaster.Rows.Count - 1

    '            Dim exeFunc As Integer = 0
    '            Dim strOrder_No As String = ""
    '            Dim strSalesId As String = ""
    '            Dim strERPProductSite As String = ""
    '            Dim strAsmblyComp As String = ""

    '            Dim strPO_No As String = ""
    '            Dim strOrder_Type As String = ""
    '            Dim strPO_Date As String = ""
    '            Dim strSoldTo_ID As String = ""
    '            Dim strShipTo_ID As String = ""
    '            Dim strBillTo_ID As String = ""
    '            Dim dtDue_Date As String = ""
    '            Dim strSales_ID As String = ""
    '            Dim dtOrder_Date As String = ""
    '            Dim strPayment_Type As String = ""
    '            Dim strAttention As String = ""
    '            Dim strPartial_Flag As String = ""
    '            Dim strCombine_Order_Flag As String = ""
    '            Dim strEarly_Ship_Flag As String = ""
    '            Dim fltFreight As String = ""
    '            Dim fltInsurance As Decimal = 0
    '            Dim strCustomer_Attention As String = ""
    '            Dim strShipment_Term As String = ""
    '            Dim strRemark As String = ""
    '            Dim strProduct_Site As String = ""
    '            Dim dtRequired_Date As String = ""
    '            Dim strShip_VIA As String = ""
    '            Dim strCurrency As String = ""
    '            Dim strOrder_Note As String = ""
    '            Dim strShipCondition As String = ""
    '            Dim strIncoterm As String = ""
    '            Dim strIncotermText As String = ""
    '            Dim strSalesNote As String = ""
    '            Dim strOPNote As String = ""
    '            Dim strOrder_Status As String = ""
    '            Dim fltTotal_Amount As String = ""
    '            Dim intTotal_Line As Integer = 0
    '            Dim strCreated_By As String = ""
    '            Dim strAuto_Order_Flag As String = ""

    '            exeFunc = NewOrderNo_Get(strOrder_No)
    '            exeFunc = SalesId_Get(HttpContext.Current.Session("COMPANY_ORG_ID"), HttpContext.Current.Session("COMPANY_ID"), strSalesId)
    '            p_strOrder_No = strOrder_No
    '            'Global_Inc.SiteDefinition_Get("ERPProductSite", strERPProductSite)
    '            'exeFunc = GetAsmblyComp(1, strLogistics_ID, strAsmblyComp)
    '            'If UCase(strAsmblyComp) = "ADLVISAM" Then
    '            '    strOrder_Type = "VISAM"
    '            'Else
    '            strOrder_Type = "SO"
    '            ' End If
    '            If (IsDBNull(dtLogisticsMaster.Rows(i).Item("PO_No")) Or dtLogisticsMaster.Rows(i).Item("PO_No") = "") Then
    '                strPO_No = strOrder_No
    '            Else
    '                strPO_No = dtLogisticsMaster.Rows(i).Item("PO_No")
    '            End If
    '            strPO_Date = Global_Inc.FormatDate(dtLogisticsMaster.Rows(i).Item("PO_DATE"))
    '            strSoldTo_ID = dtLogisticsMaster.Rows(i).Item("SoldTo_ID")
    '            strShipTo_ID = dtLogisticsMaster.Rows(i).Item("ShipTo_ID")
    '            strBillTo_ID = dtLogisticsMaster.Rows(i).Item("BillTo_ID")
    '            dtDue_Date = Global_Inc.FormatDate(dtLogisticsMaster.Rows(i).Item("Due_Date"))
    '            strSales_ID = strSalesId
    '            dtOrder_Date = Global_Inc.FormatDate(Date.Now().Date)
    '            strPayment_Type = dtLogisticsMaster.Rows(i).Item("Payment_Type")
    '            strAttention = dtLogisticsMaster.Rows(i).Item("Attention")
    '            strPartial_Flag = dtLogisticsMaster.Rows(i).Item("Partial_Flag")
    '            strCombine_Order_Flag = dtLogisticsMaster.Rows(i).Item("Combine_Order_Flag")
    '            strEarly_Ship_Flag = dtLogisticsMaster.Rows(i).Item("Early_Ship_Flag")
    '            fltFreight = dtLogisticsMaster.Rows(i).Item("Freight")
    '            fltInsurance = CDec(dtLogisticsMaster.Rows(i).Item("Insurance"))
    '            strCustomer_Attention = dtLogisticsMaster.Rows(i).Item("Customer_Attention")
    '            strShipment_Term = dtLogisticsMaster.Rows(i).Item("Shipment_Term")
    '            strRemark = dtLogisticsMaster.Rows(i).Item("Remark")
    '            strProduct_Site = strERPProductSite
    '            'Required_Date  = Original Required_date + 1 day
    '            dtRequired_Date = dtLogisticsMaster.Rows(i).Item("Required_Date")
    '            strShip_VIA = dtLogisticsMaster.Rows(i).Item("Ship_Via")
    '            strCurrency = dtLogisticsMaster.Rows(i).Item("Currency")
    '            strOrder_Note = dtLogisticsMaster.Rows(i).Item("Order_Note")
    '            strShipCondition = dtLogisticsMaster.Rows(i).Item("SHIP_CONDITION")
    '            '--{2005-9-28}--Daive: Memory Incoterm,Incoterm_Text,SalesNote and OPNote
    '            '----------------------------------------------------------------------------
    '            strIncoterm = dtLogisticsMaster.Rows(i).Item("INCOTERM")
    '            strIncotermText = dtLogisticsMaster.Rows(i).Item("INCOTERM_TEXT")
    '            strSalesNote = dtLogisticsMaster.Rows(i).Item("SALES_NOTE")
    '            strOPNote = dtLogisticsMaster.Rows(i).Item("OP_NOTE")
    '            '----------------------------------------------------------------------------
    '            strOrder_Status = "B2BOrder"
    '            fltTotal_Amount = dtLogisticsMaster.Rows(i).Item("Total_Amount")
    '            intTotal_Line = 0
    '            strCreated_By = HttpContext.Current.Session("USER_ID")
    '            strAuto_Order_Flag = dtLogisticsMaster.Rows(i).Item("Auto_Order_Flag")
    '            '---------------------------------------------------------------------
    '            '--{2005-9-28}--Daive: Memory Incoterm,Incoterm_Text,SalesNote and OPNote
    '            '----------------------------------------------------------------------------
    '            z = OrderMaster_Insert(strOrder_ID, strOrder_No, strOrder_Type, strPO_No, strPO_Date, strSoldTo_ID, strShipTo_ID, strBillTo_ID, strSales_ID, dtOrder_Date, strPayment_Type, strAttention, strPartial_Flag, strCombine_Order_Flag, strEarly_Ship_Flag, fltFreight, fltInsurance, strCustomer_Attention, strShipment_Term, strRemark, strProduct_Site, dtDue_Date, dtRequired_Date, strShip_VIA, strCurrency, strOrder_Note, strOrder_Status, fltTotal_Amount, intTotal_Line, strCreated_By, strAuto_Order_Flag, strIncoterm, strIncotermText, strSalesNote, strOPNote, strShipCondition)

    '            Dim intLine_No As Integer = 0
    '            Dim strProduct_Line As String = ""
    '            Dim strPart_No As String = ""
    '            Dim strOrder_Line_type As String = ""
    '            Dim intQTY As Integer = 0
    '            Dim fltList_Price As Decimal = 0
    '            Dim fltUnit_Price As Decimal = 0
    '            'Dim dtDue_Date As String = ""
    '            Dim strERP_Site As String = ""
    '            Dim strERP_Location As String = ""
    '            'Dim strAuto_Order_Flag As String = ""
    '            Dim intAuto_Order_QTY As Integer = 0
    '            Dim strSupplier_Due_Date As String = ""
    '            Dim intLine_Partial_Flag As String = ""
    '            Dim j As Integer = 0
    '            While j <= dtLogisticsDetail.Rows.Count - 1
    '                '---------------------------------------------------------------------
    '                intLine_No = dtLogisticsDetail.Rows(j).Item("Line_No")
    '                strProduct_Line = strERPProductSite
    '                strPart_No = dtLogisticsDetail.Rows(j).Item("Part_No")
    '                strOrder_Line_type = "B2B"  'B2B Or BTOS
    '                intQTY = dtLogisticsDetail.Rows(j).Item("QTY")
    '                fltList_Price = dtLogisticsDetail.Rows(j).Item("List_Price")
    '                fltUnit_Price = dtLogisticsDetail.Rows(j).Item("Unit_Price")
    '                dtDue_Date = Global_Inc.FormatDate(dtLogisticsDetail.Rows(j).Item("Due_Date"))
    '                strERP_Site = strERPProductSite
    '                strERP_Location = ""
    '                dtRequired_Date = dtLogisticsDetail.Rows(j).Item("Required_Date")
    '                If IsDBNull(dtLogisticsDetail.Rows(j).Item("Auto_Order_Flag")) Then
    '                    strAuto_Order_Flag = ""
    '                Else
    '                    strAuto_Order_Flag = dtLogisticsDetail.Rows(j).Item("Auto_Order_Flag")
    '                End If
    '                If IsDBNull(dtLogisticsDetail.Rows(j).Item("Auto_Order_QTY")) Then
    '                    intAuto_Order_QTY = 0
    '                Else
    '                    intAuto_Order_QTY = dtLogisticsDetail.Rows(j).Item("Auto_Order_QTY")
    '                End If
    '                If IsDBNull(dtLogisticsDetail.Rows(j).Item("Supplier_Due_date")) Then
    '                    strSupplier_Due_Date = ""
    '                Else
    '                    strSupplier_Due_Date = Global_Inc.FormatDate(dtLogisticsDetail.Rows(j).Item("Supplier_Due_date"))
    '                End If
    '                If IsDBNull(dtLogisticsDetail.Rows(j).Item("LINE_PARTIAL_FLAG")) Then
    '                    intLine_Partial_Flag = 0
    '                Else
    '                    intLine_Partial_Flag = dtLogisticsDetail.Rows(j).Item("LINE_PARTIAL_FLAG")
    '                End If

    '                '---------------------------------------------------------------------
    '                z = OrderDetail_Insert(strOrder_ID, intLine_No, strProduct_Line, strPart_No, strOrder_Line_type, intQTY, fltList_Price, fltUnit_Price, dtDue_Date, strERP_Site, strERP_Location, dtRequired_Date, strAuto_Order_Flag, intAuto_Order_QTY, strSupplier_Due_Date, intLine_Partial_Flag)
    '                j = j + 1
    '            End While
    '            i = i + 1
    '        End While
    '    End If

    '    '20051110 TC: Transfer logistics_partial records to order_partial table
    '    Dim lsDt As DataTable
    '    lsDt = dbUtil.dbGetDataTable("B2B", "select * from LOGISTICS_DETAIL_SCHEDULE where logistics_id='" & HttpContext.Current.Session("logistics_id") & "'")
    '    Dim m As Integer = 0
    '    Dim inSQL As String = ""
    '    Dim lsAdoConn As New System.Data.SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
    '    lsAdoConn.Open()
    '    Dim lsSQLCmd As System.Data.SqlClient.SqlCommand
    '    Do While m <= lsDt.Rows.Count - 1
    '        inSQL = " insert ORDER_DETAIL_SCHEDULE (ORDER_ID, LINE_NO, SCHEDULE_LINE_NO, REQUIRED_DATE, REQUIRED_QTY) " & _
    '            " values( '" & lsDt.Rows(m).Item("LOGISTICS_ID") & "', " & lsDt.Rows(m).Item("LINE_NO") & ", " & lsDt.Rows(m).Item("SCHEDULE_LINE_NO") & ", '" & Trim(lsDt.Rows(m).Item("REQUIRED_DATE")) & "', " & lsDt.Rows(m).Item("REQUIRED_QTY") & ")"
    '        lsSQLCmd = New System.Data.SqlClient.SqlCommand(inSQL, lsAdoConn)
    '        lsSQLCmd.ExecuteNonQuery()
    '        m = m + 1
    '    Loop
    '    lsAdoConn.Close()
    '    Return 1
    'End Function

    '---- 04-Oct-03 Emil Hsu in ADL 
    '---- Add this function to force syncing the BTOS lines
    '---- Calculate the assembly period outside this function

    Public Shared Function UnifyBTOSLineDueDate(ByVal strOrder_Id As String) As Integer
        Dim exeFunc As Integer = 0
        Dim strSQL As String = ""
        Dim dtBTOSLineDueDate As String = ""
        Dim intAssemblyDay As String = ""
        Dim adoDT As DataTable
        strSQL = "select " & _
                 "line_no/100 as BtosLineNo, max(due_date) as BtosLineDueDate " & _
                 "from order_detail " & _
                 "where order_id = '" & strOrder_Id & "' and line_no >= 100 " & _
                 "group by line_no/100 "
        adoDT = dbUtil.dbGetDataTable("B2B", strSQL)
        If adoDT.Rows.Count > 0 Then
            dtBTOSLineDueDate = Global_Inc.FormatDate(adoDT.Rows(0).Item("BtosLineDueDate"))
        Else
            Return -1
            Exit Function
        End If
        'HttpContext.Current.Response.Write(dtBTOSLineDueDate)
        Dim FwdDays As Integer = 0
        Dim compBTOSDD As String = ""
        Dim xFun As Integer = 0
        Dim i As Integer = 0
        Do While i <= adoDT.Rows.Count - 1

            FwdDays = -CInt(Global_Inc.SiteDefinition_Get("BTOSWorkingDays"))
            compBTOSDD = dtBTOSLineDueDate
            xFun = Global_Inc.WeekDayFwd(compBTOSDD, FwdDays)
            HttpContext.Current.Response.Write(compBTOSDD)
            'Response.End
            strSQL = "update order_detail set " & _
                     "due_date = '" & compBTOSDD & "' " & _
                     "where " & _
                     "order_id = '" & strOrder_Id & "' and line_no%100 <> 0 and line_no > 100 and " & _
                     "line_no/100 = " & adoDT.Rows(i).Item("BtosLineNo")
            dbUtil.dbExecuteNoQuery("B2B", strSQL)
            i = i + 1
        Loop
        Return 1
    End Function

    Function UnifyLineReqDate(ByVal strOrder_Id As String) As Integer
        Dim strSQLCmd As String = _
        " update order_detail set " & _
        " required_date = getdate() " & _
        " where " & _
        " order_id = '" & strOrder_Id & "' and line_no%100 <> 0 and line_no > 100 "
        dbUtil.dbExecuteNoQuery("B2B", strSQLCmd)
        Return 1
    End Function

    'jackie create 20071009
    Public Shared Function XmlCharEscape(ByVal xml As String) As String

        'Case "<"
        '    str_return = "&lt;"
        'Case ">"
        '    str_return = "&gt;"
        'Case "&"
        '    str_return = "&amp;"
        'Case "'"
        '    str_return = "&apos;"
        'Case """"
        '    str_return = "&quot;"
        xml = xml.Replace("<", "&lt;")
        xml = xml.Replace(">", "&gt;")
        xml = xml.Replace("&", "&amp;")
        xml = xml.Replace("'", "&apos;")
        xml = xml.Replace("""", "&quot;")
        Return xml
    End Function
    Public Shared Function getCountryByCompanyID(ByVal company_id As String) As String
        Dim STR As String = ""
        Try
            STR = dbUtil.dbExecuteScalar("B2B", "SELECT TOP 1 COUNTRY FROM COMPANY WHERE COMPANY_ID='" & company_id & "'")
        Catch ex As Exception
            Return ""
        End Try
        Return STR
    End Function
    Public Shared Function getTaxClassByCompanyID(ByVal company_id As String) As String
        Dim STR As String = ""
        Try
            STR = dbUtil.dbExecuteScalar("B2B", "SELECT TOP 1 TAX_CLASS FROM COMPANY WHERE COMPANY_ID='" & company_id & "'")
        Catch ex As Exception
            Return ""
        End Try
        Return STR
    End Function
    Shared Function getOrderNumberOracle(ByVal order_id As String) As String
        Dim num As Object = Nothing
        Dim preFix As String = ""
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'If HttpContext.Current.Session("ORG").ToString.ToUpper = "EU" Then
        '    preFix = "FU"
        '    num = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select NVL(max(vbak.vbeln),'{0}000000') FROM SAPRDP.VBAK where vbeln like '{0}6%'", preFix))
        'ElseIf HttpContext.Current.Session("ORG").ToString.ToUpper = "TW" Then
        '    preFix = "QT"
        '    num = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select NVL(max(vbak.vbeln),'{0}000000') FROM SAPRDP.VBAK where vbeln like '{0}1%'", preFix))
        'ElseIf HttpContext.Current.Session("ORG").ToString.ToUpper = "US" Then
        '    preFix = "BT"
        '    num = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select NVL(max(vbak.vbeln),'{0}000000') FROM SAPRDP.VBAK where vbeln like '{0}0%'", preFix))
        'End If
        Dim _org_id As String = Left(HttpContext.Current.Session("org_id").ToString.ToUpper, 2)
        If _org_id = "EU" Then
            preFix = "FU"
            num = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select NVL(max(vbak.vbeln),'{0}000000') FROM SAPRDP.VBAK where vbeln like '{0}6%'", preFix))
        ElseIf _org_id = "TW" Then
            preFix = "QT"
            num = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select NVL(max(vbak.vbeln),'{0}000000') FROM SAPRDP.VBAK where vbeln like '{0}1%'", preFix))
        ElseIf _org_id = "US" Then
            preFix = "BT"
            num = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format("select NVL(max(vbak.vbeln),'{0}000000') FROM SAPRDP.VBAK where vbeln like '{0}0%'", preFix))
        End If


        If Not IsNothing(num) AndAlso num.ToString.Trim.Length = 8 Then
            Dim temp As Int32 = Right(num.ToString.Trim, 6)
            temp += 1
            num = preFix & temp.ToString("000000")
        Else
            num = order_id
        End If
        While True
            If CInt(dbUtil.dbExecuteScalar("B2B", "select count(num) from oracleOrderNum where num='" + num.ToString() + "'")) = 0 Then
                Exit While
            End If
            Dim temp As Int32 = Right(num.ToString.Trim, 6)
            temp += 1
            num = preFix & temp.ToString("000000")
        End While
        dbUtil.dbExecuteNoQuery("b2b", String.Format("insert into oracleOrderNum values('{0}','{1}','{2}','{3}',{4})", order_id, num.ToString, Now(), HttpContext.Current.Session("user_id"), 0))
        Return num.ToString
    End Function
    Public Shared Function OrderXML_Create(ByVal strOrder_Type As String, ByVal strOrder_Id As String, ByVal strOrg_Id As String) As Integer
        Dim exeFunc As Integer = 0
        Dim strOrderXml As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim adoDT_OrderMaster, adoDT_OrderDetail As New DataTable
        exeFunc = OrderDataTable_Get(strOrder_Id, adoDT_OrderMaster, adoDT_OrderDetail)
        If adoDT_OrderMaster.Rows.Count = 0 Or adoDT_OrderDetail.Rows.Count = 0 Then Return -1

        Dim sales_org As String = UCase(strOrg_Id)
        Dim distr_chan As String = "10", division As String = "00"
        If Trim(sales_org).ToUpper() = "US01" Then
            'distr_chan = "30" : division = "10"
            Dim N As Integer = dbUtil.dbExecuteScalar("MY", String.Format("select COUNT(COMPANY_ID) from SAP_DIMCOMPANY where SALESOFFICE='2300' and COMPANY_ID='{0}' and ORG_ID='US01'", UCase(adoDT_OrderMaster.Rows(0).Item("soldto_id"))))
            If N > 0 Then
                distr_chan = "10" : division = "20"
            Else
                distr_chan = "30" : division = "10"
            End If
        End If

        '==== so ===='
        Select Case strOrder_Type
            Case "SO"
                strOrderXml = ""
                '---- header ----'
                strOrderXml = "<Order>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Order_Type>ZOR2</Order_Type>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Sales_Organization>" + sales_org + "</Sales_Organization>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Distribution_Channel>" + distr_chan + "</Distribution_Channel>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Division>" + division + "</Division>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Sales_Office></Sales_Office>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Delivery_Plant>EUH1</Delivery_Plant>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                If adoDT_OrderMaster.Rows.Count > 0 Then strOrderXml = strOrderXml & "<Ship_Condition>" & Left(adoDT_OrderMaster.Rows(0).Item("SHIP_CONDITION"), 2) & "</Ship_Condition>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                If adoDT_OrderMaster.Rows.Count > 0 Then strOrderXml = strOrderXml & "<Inco_Term1>" & adoDT_OrderMaster.Rows(0).Item("INCOTERM") & "</Inco_Term1>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                If adoDT_OrderMaster.Rows.Count > 0 AndAlso adoDT_OrderMaster.Rows(0).Item("INCOTERM_TEXT") = "" Then
                    strOrderXml = strOrderXml & "<Inco_Term2>blank</Inco_Term2>"
                Else
                    If adoDT_OrderMaster.Rows.Count > 0 Then strOrderXml = strOrderXml & "<Inco_Term2>" & adoDT_OrderMaster.Rows(0).Item("INCOTERM_TEXT") & "</Inco_Term2>"
                End If


                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Credit_Status/>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Delivery_Status/>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                If adoDT_OrderMaster.Rows.Count > 0 Then strOrderXml = strOrderXml & "<Order_Number>" & adoDT_OrderMaster.Rows(0).Item("order_no") & "</Order_Number>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                If adoDT_OrderMaster.Rows.Count > 0 Then strOrderXml = strOrderXml & "<Customer_ID>" & UCase(adoDT_OrderMaster.Rows(0).Item("soldto_id")) & "</Customer_ID>"

                'strOrderXml = strOrderXml & "<Customer_ID>EHLA002</Customer_ID>"
                'strOrderXml = strOrderXml & "<Customer_ID>EFFRFA01</Customer_ID>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                If adoDT_OrderMaster.Rows.Count > 0 Then strOrderXml = strOrderXml & "<Ship_To_ID>" & UCase(adoDT_OrderMaster.Rows(0).Item("shipto_id")) & "</Ship_To_ID>"
                Dim Company_Country As String = getCountryByCompanyID(UCase(adoDT_OrderMaster.Rows(0).Item("shipto_id")))
                If Company_Country.ToUpper = "NL" Then
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<Ship_To_Country>" & Company_Country & "</Ship_To_Country>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<TAX_Class>" & getTaxClassByCompanyID(UCase(adoDT_OrderMaster.Rows(0).Item("shipto_id"))) & "</TAX_Class>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<Triangular_Indicator>X</Triangular_Indicator>"
                Else
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<Ship_To_Country/>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<TAX_Class/>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<Triangular_Indicator/>"
                End If



                'strOrderXml = strOrderXml & "<Ship_To_ID>EHLA002</Ship_To_ID>"
                'strOrderXml = strOrderXml & "<Ship_To_ID>EFFRFA01A</Ship_To_ID>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Order_Date>" & Global_Inc.FormatDate(adoDT_OrderMaster.Rows(0).Item("order_date")) & "</Order_Date>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                'strOrderXml = strOrderXml & "<Require_Date>" & Global_Inc.FormatDate(DateAdd("d", 1, adoDT_OrderMaster.Rows(0).Item("order_date"))) & "</Require_Date>"
                If adoDT_OrderDetail.Rows(0).Item("line_no") < 100 Then
                    strOrderXml = strOrderXml & "<Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(0).Item("required_date")) & "</Require_Date>"
                Else
                    strOrderXml = strOrderXml & "<Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(0).Item("due_date")) & "</Require_Date>"
                End If
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                strOrderXml = strOrderXml & "<Ship_Term>" & adoDT_OrderMaster.Rows(0).Item("SHIP_VIA") & "</Ship_Term>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Remarks></Remarks>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                strOrderXml = strOrderXml & "<Comments></Comments>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                'jackie add 2007/10/4 for xml parse > < issue
                Dim salesNote As String = ""
                If Not IsDBNull(adoDT_OrderMaster.Rows(0).Item("SALES_NOTE")) Then salesNote = adoDT_OrderMaster.Rows(0).Item("SALES_NOTE")
                salesNote = XmlCharEscape(salesNote) 'salesNote.Replace(">", "&gt;") : salesNote = salesNote.Replace("<", "&lt;")
                Dim externalNote As String = ""
                If Not IsDBNull(adoDT_OrderMaster.Rows(0).Item("ORDER_NOTE")) Then externalNote = adoDT_OrderMaster.Rows(0).Item("ORDER_NOTE")
                externalNote = XmlCharEscape(externalNote) ' .Replace(">", "&gt;") : externalNote = externalNote.Replace("<", "&lt;")
                Dim opNote As String = ""
                If Not IsDBNull(adoDT_OrderMaster.Rows(0).Item("OP_NOTE")) Then opNote = adoDT_OrderMaster.Rows(0).Item("OP_NOTE")
                opNote = XmlCharEscape(opNote) '.Replace(">", "&gt;") : opNote = opNote.Replace("<", "&lt;")
                Dim prjNote As String = ""
                If Not IsDBNull(adoDT_OrderMaster.Rows(0).Item("prj_NOTE")) Then prjNote = adoDT_OrderMaster.Rows(0).Item("prj_NOTE")
                prjNote = XmlCharEscape(prjNote)

                strOrderXml = strOrderXml & "<Sales_Note>" & salesNote & "</Sales_Note>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<External_Note>" & externalNote & "</External_Note>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Op_Note>" & opNote & "</Op_Note>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<prj_Note>" & prjNote & "</prj_Note>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                '20071009 Jackie: add for customer sales note issue
                strOrderXml = strOrderXml & "<Default_SalesNote>" & adoDT_OrderMaster.Rows(0).Item("DefaultSalesNote") & "</Default_SalesNote>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                '20051207 TC: add sales person1
                Dim OrderSalesId As String = adoDT_OrderMaster.Rows(0).Item("sales_id").ToString.Trim.ToLower
                Dim salesDR As DataTable
                'salesDR = dbUtil.dbGetDataTable("B2B", "select distinct sales_person1 from company_sales where company_id='" & HttpContext.Current.Session("company_id") & "'")
                salesDR = dbUtil.dbGetDataTable("B2B", "select distinct sales_code from SAP_COMPANY_EMPLOYEE where company_id='" & HttpContext.Current.Session("company_id") & "' and partner_function='VE' and sales_org='" & HttpContext.Current.Session("Org_id") & "'")
                Dim sales_id
                If salesDR.Rows.Count > 0 Then
                    sales_id = UCase(Trim(salesDR.Rows(0).Item("sales_code"))).ToLower.Trim
                    If sales_id = OrderSalesId Then
                        sales_id = ""
                    Else
                        sales_id = OrderSalesId
                    End If
                Else
                    sales_id = ""
                End If
                'salesDR.Close()
                'g_adoConn.Close()

                strOrderXml = strOrderXml & "<Sale_Person_ID1>" & sales_id & "</Sale_Person_ID1>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Sale_Person_ID2></Sale_Person_ID2>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Sale_Person_ID3></Sale_Person_ID3>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Sale_Person_ID4></Sale_Person_ID4>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                If UCase(adoDT_OrderMaster.Rows(0).Item("currency")) Like "EU*" Then
                    strOrderXml = strOrderXml & "<Order_Currency>" & "EUR" & "</Order_Currency>"
                Else
                    If UCase(adoDT_OrderMaster.Rows(0).Item("currency")) Like "US*" Then
                        strOrderXml = strOrderXml & "<Order_Currency>" & "USD" & "</Order_Currency>"
                    Else
                        If UCase(adoDT_OrderMaster.Rows(0).Item("currency")) Like "NT*" Then
                            strOrderXml = strOrderXml & "<Order_Currency>" & "NTD" & "</Order_Currency>"
                        Else
                            strOrderXml = strOrderXml & "<Order_Currency>" & adoDT_OrderMaster.Rows(0).Item("currency") & "</Order_Currency>"
                        End If
                    End If
                End If
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Customer_PO_Number>" & adoDT_OrderMaster.Rows(0).Item("po_no") & "</Customer_PO_Number>"
                If Not (CStr(adoDT_OrderMaster.Rows(0).Item("po_date")) Like "*9999*") Then
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<Po_Date>" & Global_Inc.FormatDate(adoDT_OrderMaster.Rows(0).Item("po_date")) & "</Po_Date>"
                End If
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<TO_SITE>" & adoDT_OrderMaster.Rows(0).Item("product_site") & "</TO_SITE>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                If adoDT_OrderMaster.Rows(0).Item("partial_flag") = "N" Then
                    strOrderXml = strOrderXml & "<Partial_Shipment>NO</Partial_Shipment>"
                Else
                    strOrderXml = strOrderXml & "<Partial_Shipment>YES</Partial_Shipment>"
                End If
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<FOB_Point>" & adoDT_OrderMaster.Rows(0).Item("shipment_term") & "</FOB_Point>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                'jackie add 2007/09/12 for project SO request
                'project
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Project>" & adoDT_OrderMaster.Rows(0).Item("ProjectFlag") & "</Project>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                'Z7Sales
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Z7Sales>" & adoDT_OrderMaster.Rows(0).Item("Z7Sales") & "</Z7Sales>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                strOrderXml = strOrderXml & "<Freight>" & Chr(13) & Chr(10)

                'Nada ADDED FOR Freight Fee
                If HttpContext.Current.Session("Freight_Fee") IsNot Nothing And HttpContext.Current.Session("Freight_Fee") <> "" Then
                    Dim FreightTemp = HttpContext.Current.Session("Freight_Fee").ToString.Split("|")
                    strOrderXml = strOrderXml & "<Type>" & FreightTemp(0) & "</Type>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<Amount>" & FreightTemp(1) & "</Amount>"
                    HttpContext.Current.Session("Freight_Fee") = ""
                Else

                    strOrderXml = strOrderXml & "<Type></Type>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    strOrderXml = strOrderXml & "<Amount></Amount>"
                End If
                '/Nada ADDED FOR Freight Fee
                strOrderXml = strOrderXml & "</Freight>" & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & Chr(13)
                Dim BTOLINE As String = ""
                Dim parentDD_DR As DataTable
                Dim dArray As String()
                Dim compDD As String
                Dim Line_Seq As Integer = 1
                'Jackie add 2007/1/15
                Dim Delivery_Group As Integer = 10, even As Integer = 1
                Do While Line_Seq <= adoDT_OrderDetail.Rows.Count


                    strOrderXml = strOrderXml & Chr(10) & "<Order_Line>"
                    strOrderXml = strOrderXml & "<Order_Number>" & adoDT_OrderMaster.Rows(0).Item("order_no") & "</Order_Number>"
                    strOrderXml = strOrderXml & "<Item_Category />"
                    'Jackie remark 2007/08/27
                    'strOrderXml = strOrderXml & "<Higher_Level />"
                    If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) Mod 100 = 0 Then
                        BTOLINE = adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")
                        strOrderXml = strOrderXml & "<Higher_Level>" & "" & "</Higher_Level>" & Chr(13) & Chr(10)
                        '20050719 TC: Change storage location for spare part and p-trade for auto-po
                        If Global_Inc.IsNumericItem(Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2)) And Not _
                        (adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") Like "96*") Then
                            strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                        Else
                            If Global_Inc.IsPtrade(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                                strOrderXml = strOrderXml & "<Storage_Location>" & "B000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            Else
                                strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            End If
                        End If

                    Else
                        If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) >= 100 Then
                            strOrderXml = strOrderXml & "<Higher_Level>" & BTOLINE & "</Higher_Level>" & Chr(13) & Chr(10)
                            'strOrderXml = strOrderXml & "<Higher_Level></Higher_Level>" & Chr(13) & Chr(10)
                            'strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            If Global_Inc.IsNumericItem(Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2)) And _
                            Not (adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") Like "96*") Then
                                strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            Else
                                If Global_Inc.IsPtrade(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "B000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                Else
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                End If
                            End If

                        Else
                            'strOrderXml = strOrderXml & "<Higher_Level>" & adoRs_OrderDetail("line_no") & "</Higher_Level>" & Chr(13) & Chr(10)
                            strOrderXml = strOrderXml & "<Higher_Level>" & "" & "</Higher_Level>" & Chr(13) & Chr(10)
                            'strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            If Global_Inc.IsNumericItem(Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2)) And _
                            Not (adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") Like "96*") Then
                                strOrderXml = strOrderXml & "<Storage_Location>" & "" & "</Storage_Location>" & Chr(13) & Chr(10)
                            Else
                                If Global_Inc.IsPtrade(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "P000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                Else
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                End If
                            End If
                            '20051110 TC: For partial line purpose
                            If adoDT_OrderDetail.Rows(Line_Seq - 1).Item("LINE_PARTIAL_FLAG") = 1 And CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) < 100 Then
                                strOrderXml = strOrderXml & "<Partial_Line>YES</Partial_Line>" & Chr(13) & Chr(10)
                            End If

                            'Jackie add 2007/1/15
                            If adoDT_OrderDetail.Rows(Line_Seq - 1).Item("ExWarranty_Flag") <> "0" And adoDT_OrderDetail.Rows(Line_Seq - 1).Item("ExWarranty_Flag") <> "00" Then
                                strOrderXml &= "<Delivery_Group>" & Delivery_Group & "</Delivery_Group>" & Chr(13) & Chr(10)
                                If (even Mod 2 = 0) Then
                                    Delivery_Group += 10
                                End If
                                even += 1
                            Else
                                'strOrderXml &= "<Delivery_Group>0</Delivery_Group>" & chr(13) & chr(10)
                            End If

                        End If
                    End If
                    strOrderXml = strOrderXml & "<Line>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no") & "</Line>"
                    strOrderXml = strOrderXml & "<Line_Seq>" & Line_Seq & "</Line_Seq>"

                    If Global_Inc.IsNumericItem(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                        strOrderXml = strOrderXml & "<Item_Number>" & "00000000" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") & "</Item_Number>"
                    Else
                        strOrderXml = strOrderXml & "<Item_Number>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") & "</Item_Number>"
                    End If
                    strOrderXml = strOrderXml & "<Qty>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("qty") & "</Qty>"
                    If adoDT_OrderDetail.Rows(Line_Seq - 1).Item("unit_price") = -1 Then
                        strOrderXml = strOrderXml & "<Unit_Price>0</Unit_Price>"
                    Else
                        strOrderXml = strOrderXml & "<Unit_Price>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("unit_price") & "</Unit_Price>"
                    End If

                    If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) < 100 Then
                        strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("required_date")) & "</Line_Require_Date>"
                        '>=100
                    Else
                        If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) Mod 100 = 0 Then
                            If (UCase(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Like "W-CTOS*") Then
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("required_date")) & "</Line_Require_Date>"
                            Else
                                '<Nada modified for btos first date>
                                'strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("due_date")) & "</Line_Require_Date>"
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("required_date")) & "</Line_Require_Date>"

                                '</Nada modified for btos first date>
                                Dim strMaxDD As String = ""
                                '<Nada modified for btos first date>
                                'dArray = Split(Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("due_date")), "/")
                                dArray = Split(Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("required_date")), "/")
                                '</Nada modified for btos first date>
                                compDD = dArray(0)
                                If Len(dArray(1)) = 2 Then
                                    compDD = compDD & "-" & dArray(1)
                                Else
                                    compDD = compDD & "-0" & dArray(1)
                                End If

                                If Len(dArray(2)) = 2 Then
                                    compDD = compDD & "-" & dArray(2)
                                Else
                                    compDD = compDD & "-0" & dArray(2)
                                End If

                                Dim WorkDays As String = "5"
                                Global_Inc.SiteDefinition_Get("BTOSWorkingDays", WorkDays)
                                Dim sc3 As New aeu_ebus_dev9000.B2B_AEU_WS
                                Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", sc3.Url)
                                sc3.Get_Next_WrokingDate(compDD, -WorkDays)

                                If Now.Date > CDate(compDD) Then
                                    compDD = Year(Now()) & "/"
                                    If Month(Now()) < 10 Then
                                        compDD &= "0" & Month(Now()) & "/"
                                    Else
                                        compDD &= Month(Now()) & "/"
                                    End If
                                    If Day(Now()) < 10 Then
                                        compDD &= "0" & Day(Now()) & "/"
                                    Else
                                        compDD &= Day(Now())
                                    End If
                                Else
                                    Dim tempCompDD As String = compDD
                                    compDD = Year(CDate(tempCompDD)) & "/"
                                    If Month(CDate(tempCompDD)) < 10 Then
                                        compDD &= "0" & Month(CDate(tempCompDD)) & "/"
                                    Else
                                        compDD &= Month(CDate(tempCompDD)) & "/"
                                    End If
                                    If Day(CDate(tempCompDD)) < 10 Then
                                        compDD &= "0" & Day(CDate(tempCompDD)) & "/"
                                    Else
                                        compDD &= Day(CDate(tempCompDD))
                                    End If
                                End If
                                compDD = Replace(compDD, "-", "/")
                            End If
                        Else
                            If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) < 100 Then
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(Date.Now.Date) & _
                                "</Line_Require_Date>"
                            Else
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & compDD & "</Line_Require_Date>"
                                'parentDD_DR.Close()
                            End If

                        End If
                    End If

                    strOrderXml = strOrderXml & "<Line_Due_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("due_date")) & "</Line_Due_Date>"
                    strOrderXml = strOrderXml & "<Request_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("required_date")) & "</Request_Date>"
                    If HttpContext.Current.Session("CBOM_SITE") = "ATW" And CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) >= 100 Then
                        If Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2) = "P-" Then
                            strOrderXml = strOrderXml & "<Line_To_Site_ID>0000</Line_To_Site_ID>"
                        Else
                            strOrderXml = strOrderXml & "<Line_To_Site_ID>1000</Line_To_Site_ID>"
                        End If
                        strOrderXml = strOrderXml & "<Line_Location>BTOS</Line_Location>"
                    End If

                    '--Daive: Add "CustMaterialNo"
                    Try
                        strOrderXml = strOrderXml & "<CustMaterialNo>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("CustMaterialNo") & "</CustMaterialNo>"
                    Catch ex As Exception
                        strOrderXml = strOrderXml & "<CustMaterialNo></CustMaterialNo>"
                    End Try


                    '--Jackie: Add "DeliveryPlant" 2007/08/27
                    Try
                        strOrderXml = strOrderXml & "<Plant>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("DeliveryPlant") & "</Plant>"
                    Catch ex As Exception
                        strOrderXml = strOrderXml & "<Plant></Plant>"
                    End Try
                    '--Nada: Add "DMF_Flag" 
                    Try
                        strOrderXml = strOrderXml & "<DMF>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("DMF_Flag") & "</DMF>"
                    Catch ex As Exception
                        strOrderXml = strOrderXml & "<DMF></DMF>"
                    End Try

                    Try
                        strOrderXml = strOrderXml & "<OptyID>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("Optyid") & "</OptyID>"
                    Catch ex As Exception
                        strOrderXml = strOrderXml & "<OptyID></OptyID>"
                    End Try

                    '20051110 TC: Put schedule lines for partial line purpose
                    If adoDT_OrderDetail.Rows(Line_Seq - 1).Item("LINE_PARTIAL_FLAG") = 1 And CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) < 100 Then
                        Dim ScheduleLineDT As New DataTable
                        ScheduleLineDT = dbUtil.dbGetDataTable("B2B", "select * from ORDER_DETAIL_SCHEDULE where order_id = '" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("order_id") & "' and line_no = " & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no"))
                        Dim x As Integer = 0
                        Do While x <= ScheduleLineDT.Rows.Count - 1
                            strOrderXml = strOrderXml & "<Schedule_Line>" & Chr(13) & Chr(10)
                            strOrderXml = strOrderXml & "<Itm_Number>" & ScheduleLineDT.Rows(x).Item("LINE_NO") & "</Itm_Number>"
                            strOrderXml = strOrderXml & "<Sched_Line>" & ScheduleLineDT.Rows(x).Item("SCHEDULE_LINE_NO") & "</Sched_Line>"
                            strOrderXml = strOrderXml & "<Req_Date>" & Global_Inc.FormatDate(ScheduleLineDT.Rows(x).Item("REQUIRED_DATE")) & "</Req_Date>"
                            strOrderXml = strOrderXml & "<Req_Qty>" & ScheduleLineDT.Rows(x).Item("REQUIRED_QTY") & "</Req_Qty>"
                            strOrderXml = strOrderXml & Chr(13) & Chr(10) & "</Schedule_Line>" & Chr(13) & Chr(10)
                            x = x + 1
                        Loop
                    End If
                    'End of schedule line

                    strOrderXml = strOrderXml & "</Order_Line>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    Line_Seq = Line_Seq + 1
                Loop
                strOrderXml = strOrderXml & "</Order>" & Chr(10)
                Dim strSOPath As String = ""
                Dim strFileName As String = ""
                Global_Inc.SiteDefinition_Get("SOFolder", strSOPath)
                'strSOPath = "C:\MyAdvantech\Files\SO\"
                strFileName = adoDT_OrderMaster.Rows(0).Item("order_no") & ".xml"
                exeFunc = Util.SaveString2File(strOrderXml, strSOPath, strFileName)
                'response.end
                '20050426 TC: Case SupplierSO for creating XML order file for SAP	          
            Case Else
                Return -1
        End Select
        Return 1
    End Function

    Public Shared Function OrderDataTable_Get(ByVal strOrder_Id As String, ByRef dtOrderMaster As DataTable, ByRef dtOrderDetail As DataTable) As Integer
        OrderDataTable_Get = 1
        Dim strSQL As String = ""
        strSQL = "select * from order_master where order_id = '" & strOrder_Id & "'"
        dtOrderMaster = dbUtil.dbGetDataTable("B2B", strSQL)
        If dtOrderMaster.Rows.Count < 1 Then
            OrderDataTable_Get = 0
        Else
            strSQL = "select * from order_detail where order_id = '" & strOrder_Id & "' order by line_no"
            dtOrderDetail = dbUtil.dbGetDataTable("B2B", strSQL)
            If dtOrderDetail.Rows.Count < 1 Then
                OrderDataTable_Get = 0
            End If
        End If
        Return OrderDataTable_Get
    End Function

    '---Daive: This is the old one.
    Public Shared Function ERPOrder_Integrate(ByVal strOrder_Type As String, ByVal strOrder_No As String) As Integer
        Dim strOrderFileName As String = ""
        Dim strERPHost As String = ""
        Dim strERPSOFolder As String = ""
        Dim strSOFolder As String = ""
        Dim strERPIntegrateId As String = ""
        Dim Proc_Status_Xml As String = ""
        Dim Order_Status_Xml As String = ""
        Dim exeFunc As Integer = 0
        Dim retValue As Integer = 0
        Dim xStatus As Integer = 0
        Dim xFunc As Integer = 0
        Select Case strOrder_Type

            Case "SO"
                'Global_Inc.SiteDefinition_Get("ERPHost", strERPHost)
                'Global_Inc.SiteDefinition_Get("ERPSOFolder", strERPSOFolder)
                'Global_Inc.SiteDefinition_Get("SOFolder", strSOFolder)
                strSOFolder = "c:\MyAdvantech\Files\so\"
                strOrderFileName = strOrder_No & ".xml"
                'Global_Inc.SiteDefinition_Get("ERPIntegrateId", strERPIntegrateId)

                'Start to transfer order to SAP
                Proc_Status_Xml = ""
                Order_Status_Xml = ""
                'HttpContext.Current.Session("retValue") = ""

                retValue = ERPOrder_Process(strSOFolder, strOrderFileName, Proc_Status_Xml)
                If retValue = -1 Then
                    HttpContext.Current.Response.Write("Order creation process failed. Please contact myadvantech@advantech.com.tw.")
                    If (IsDBNull(Trim(Proc_Status_Xml)) Or Trim(Proc_Status_Xml) = "") And retValue = 1 Then

                    Else
                        xStatus = 0
                        xFunc = ProcStatus_Save(Proc_Status_Xml, strOrder_No, xStatus)
                    End If
                    xFunc = OrderXML_Update(strOrder_No)
                    xFunc = SendFailedOrderMail(strOrder_No)
                    'HttpContext.Current.Response.Write("Internet Error!!!"):response.end	
                    ERPOrder_Integrate = 0
                    Exit Function
                Else
                    If retValue = 0 Then
                        If (IsDBNull(Trim(Proc_Status_Xml)) Or Trim(Proc_Status_Xml) = "") And retValue = 1 Then

                        Else
                            xStatus = 0
                            xFunc = ProcStatus_Save(Proc_Status_Xml, strOrder_No, xStatus)
                        End If
                        xFunc = OrderXML_Update(strOrder_No)
                        xFunc = SendFailedOrderMail(strOrder_No)
                        'HttpContext.Current.Response.Write("SAP System Error!!!"):response.end		
                        ERPOrder_Integrate = 0
                        Exit Function
                        'Response.Redirect("/order/Order_Recovery.asp?so_no=" & strOrder_No & "&Proc_Status_Xml=" & Proc_Status_Xml)					 		
                    End If
                End If
                '---------------------------------------------------------------------

                If retValue = 1 Then
                    System.Threading.Thread.Sleep(2000)
                    '20060816 TC: Start to insert warranty flag to SAP table for sales order(VBAP-ZZ_GUARA)
                    '{Jackie--2006/09/07} Add Sabine 
                    'If Global_inc1.IsB2BOwner(HttpContext.Current.Session("user_id")) Or LCase(HttpContext.Current.Session("user_id")) = "sabine.lin@advantech.fr" Then 
                    If 1 = 1 Then
                        'Jackie add 2007/11/16
                        Dim ew_tb As New DataTable
                        ew_tb = dbUtil.dbGetDataTable("B2B", "select part_no from order_detail where order_id='" & HttpContext.Current.Session("order_id") & "' and line_no<100 and part_no like 'AGS-EW-%' ")
                        If ew_tb.Rows.Count > 0 Then
                            Dim edt As DataTable = dbUtil.dbGetDataTable("B2B", _
                            " select IsNull(a.order_no,'') as so_no, IsNull(b.line_no,'1') as line_no, " + _
                            " IsNull(b.exwarranty_flag,'') as exwarranty_flag " + _
                            " from order_master a, order_detail b " + _
                            " where a.order_id=b.order_id and " + _
                            " (b.exwarranty_flag='00' or b.exwarranty_flag='0') and " + _
                            " b.order_id='" + HttpContext.Current.Session("order_id") + "' order by b.line_no")
                            ' jackie revise 2006/8/31
                            '" where a.order_id=b.order_id and b.line_no<100 and " + _
                            Dim ew_status As String = "", retCode As Boolean = False
                            If edt.Rows.Count > 0 Then
                                Dim EW_Ws As New aeu_ebus_dev9000.B2B_AEU_WS
                                EW_Ws.Timeout = 999999999
                                EW_Ws.UpdateSOWarrantyFlag( _
                                Global_Inc.DataTableToADOXML(edt), ew_status, retCode)
                                If Not retCode Then
                                    HttpContext.Current.Response.Write(ew_status) : HttpContext.Current.Response.End()
                                End If
                            End If
                        End If
                    End If

                    If (IsDBNull(Trim(Proc_Status_Xml)) Or Trim(Proc_Status_Xml) = "") And retValue = 1 Then

                    Else
                        xStatus = 1
                        xFunc = ProcStatus_Save(Proc_Status_Xml, strOrder_No, xStatus)
                    End If
                    'Get SAP order status to compare with B2B order status
                    '---{2006-04-25}--Daive: Combine GetStatus and SO Create <Start>
                    'exeFunc = Global_Inc.Pause(5)
                    retValue = GetERPOrderStatus(strOrder_No, Order_Status_Xml)

                    'If retValue = -1 Then
                    If Trim(Proc_Status_Xml) = "" Or retValue = -1 Then
                        HttpContext.Current.Response.Write("Query order status failed. Please contact myadvantech@advantech.com.tw.")
                        '--{2005-10-7}--Daive:
                        'send one mail to administrator to tell us B2B didn't get Data from SAP because of ...
                        xFunc = OrderXML_Update(strOrder_No)
                        xFunc = GetOrderStatusFailed_SendMail(strOrder_No)
                        'HttpContext.Current.Response.Write("Query order status failed!!!"):response.end		
                        ERPOrder_Integrate = 0
                        Exit Function
                    Else
                        If retValue = 0 Then
                            HttpContext.Current.Response.Write("No order record in SAP.")
                            '--{2005-10-7}--Daive:
                            'send one mail to administrator to tell us Order insert successfully, but B2B didn't get Data from SAP because of ...
                            xFunc = OrderXML_Update(strOrder_No)
                            xFunc = GetOrderStatusFailed_SendMail(strOrder_No)
                            'HttpContext.Current.Response.Write("No order record in SAP."):response.end	
                            ERPOrder_Integrate = 0
                            Exit Function
                        End If
                    End If
                    '---{2006-04-25}--Daive: Combine GetStatus and SO Create <End>
                Else
                    Order_Status_Xml = ""
                End If
                'Response.End
                'Use this xml to compare SAP and B2B order status
                'Create Table "ORDER_DETAIL_CHANGED_IN_SAP"
                'Save the changed Records in Table "ORDER_DETAIL_CHANGED_IN_SAP" and change the ORDER_DATAIL
                xFunc = OrderDetailChangedInSAP_Save(strOrder_No, Order_Status_Xml)

            Case "SupplierSO"

        End Select
        ERPOrder_Integrate = 1
    End Function

    '--{2006-04-26}--Daive: This is for WS which combined GetOrderStatus and SO_Create
    Public Shared Function ERPOrder_Integrate(ByVal strOrder_Type As String, ByVal strOrder_No As String, ByVal Func2Flg As String) As Integer
        Dim strOrderFileName As String = ""
        Dim strERPHost As String = ""
        Dim strERPSOFolder As String = ""
        Dim strSOFolder As String = ""
        Dim strERPIntegrateId As String = ""
        Dim Proc_Status_Xml As String = ""
        Dim Order_Status_Xml As String = ""
        Dim exeFunc As Integer = 0
        Dim retValue As Integer = 0
        Dim xStatus As Integer = 0
        Dim xFunc As Integer = 0
        Select Case strOrder_Type

            Case "SO"
                'Global_Inc.SiteDefinition_Get("SOFolder", strSOFolder)
                strOrderFileName = strOrder_No & ".xml"
                'Start to transfer order to SAP
                Proc_Status_Xml = ""
                Order_Status_Xml = ""

                '---{2006-04-25}--Daive: Combine GetStatus and SO Create <Start>
                retValue = ERPOrder_Process(strSOFolder, strOrderFileName, Proc_Status_Xml, Order_Status_Xml)
                '---{2006-04-25}--Daive: Combine GetStatus and SO Create <End>

                If retValue = -1 Then
                    HttpContext.Current.Response.Write("Order creation process failed. Please contact myadvantech@advantech.com.tw.")
                    '--{2005-10-7}--Daive:
                    'send one mail to administrator to tell us this order didn't insert into SAP because of ...
                    'Response.End
                    If (IsDBNull(Trim(Proc_Status_Xml)) Or Trim(Proc_Status_Xml) = "") Then

                    Else
                        xStatus = 0
                        xFunc = ProcStatus_Save(Proc_Status_Xml, strOrder_No, xStatus)
                    End If
                    xFunc = OrderXML_Update(strOrder_No)
                    xFunc = SendFailedOrderMail(strOrder_No)
                    'HttpContext.Current.Response.Write("Internet Error!!!"):response.end	
                    ERPOrder_Integrate = 0
                    Exit Function
                Else
                    If retValue = 0 Then
                        If (IsDBNull(Trim(Proc_Status_Xml)) Or Trim(Proc_Status_Xml) = "") Then

                        Else
                            xStatus = 0
                            xFunc = ProcStatus_Save(Proc_Status_Xml, strOrder_No, xStatus)
                        End If
                        xFunc = OrderXML_Update(strOrder_No)
                        xFunc = SendFailedOrderMail(strOrder_No)
                        'HttpContext.Current.Response.Write("SAP System Error!!!"):response.end		
                        ERPOrder_Integrate = 0
                        Exit Function
                        'Response.Redirect("/order/Order_Recovery.asp?so_no=" & strOrder_No & "&Proc_Status_Xml=" & Proc_Status_Xml)					 		
                    End If
                End If
                '---------------------------------------------------------------------

                If retValue = 1 Then
                    If (IsDBNull(Trim(Proc_Status_Xml)) Or Trim(Proc_Status_Xml) = "") And retValue = 1 Then

                    Else
                        xStatus = 1
                        xFunc = ProcStatus_Save(Proc_Status_Xml, strOrder_No, xStatus)
                    End If
                    'Get SAP order status to compare with B2B order status
                    '---{2006-04-25}--Daive: Combine GetStatus and SO Create <Start>

                    If Trim(Order_Status_Xml) = "" Or Order_Status_Xml.Trim.ToUpper = "EMPTY" Then
                        HttpContext.Current.Response.Write("Query order status failed. Please contact myadvantech@advantech.com.tw.")
                        '--{2005-10-7}--Daive:
                        'send one mail to administrator to tell us B2B didn't get Data from SAP because of ...
                        xFunc = OrderXML_Update(strOrder_No)
                        xFunc = GetOrderStatusFailed_SendMail(strOrder_No)
                        'HttpContext.Current.Response.Write("Query order status failed!!!"):response.end		
                        ERPOrder_Integrate = 0
                        Exit Function
                    End If
                    '---{2006-04-25}--Daive: Combine GetStatus and SO Create <End>
                Else
                    Order_Status_Xml = ""
                End If
                'Response.End
                'Use this xml to compare SAP and B2B order status
                'Create Table "ORDER_DETAIL_CHANGED_IN_SAP"
                'Save the changed Records in Table "ORDER_DETAIL_CHANGED_IN_SAP" and change the ORDER_DATAIL
                xFunc = OrderDetailChangedInSAP_Save(strOrder_No, Order_Status_Xml)

            Case "SupplierSO"

        End Select
        ERPOrder_Integrate = 1
    End Function

    Public Shared Function ERPOrder_Process(ByVal strLocal_Folder As String, ByVal strLocal_Filename As String, ByRef ProcStatusXml As String) As Integer
        Dim order_xmlString As String = ""
        Dim proc_status_xml As String = ""
        Dim iRtn As Integer = 0
        Dim obj_FSO As System.IO.FileInfo = New System.IO.FileInfo(strLocal_Folder & UCase(strLocal_Filename))
        Dim objFStrm As System.IO.StreamReader
        'Dim AEU_WS As New aeu_ebus_dev9000.b2b_sap_ws
        'Dim AEU_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        'Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", AEU_WS.Url)
        Dim AEU_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        'AEU_WS.Url = "http://172.21.34.44:9000/b2b_sap_ws.asmx"
        AEU_WS.Timeout = 999999999
        Try
            objFStrm = obj_FSO.OpenText
            order_xmlString = objFStrm.ReadToEnd()
            objFStrm.Close()
            'iRtn = AEU_WS.SO_CREATE_TEST(order_xmlString, proc_status_xml)
            'If LCase(HttpContext.Current.Session("USER_ID")) = "daive.wang@advantech.com.cn" Or LCase(HttpContext.Current.Session("USER_ID")) = "tc.chen@advantech.com.tw" Or LCase(HttpContext.Current.Session("USER_ID")) = "jackie.wu@advantech.com.cn" Then
            If LCase(HttpContext.Current.Session("USER_ID")) = "nada.liu@advantech.com.cn" Then
                'If 1 <> 1 Then
                'HttpContext.Current.Response.Write("aa") : HttpContext.Current.Response.End()
                'iRtn = AEU_WS.SO_CREATE_TEST(order_xmlString, proc_status_xml)
                iRtn = AEU_WS.SO_CREATE(order_xmlString, proc_status_xml)
            Else
                iRtn = AEU_WS.SO_CREATE(order_xmlString, proc_status_xml)
            End If

        Catch ex As Exception
            If proc_status_xml = "" Or proc_status_xml = "EMPTY" Then
                proc_status_xml &= "<Error>"
                proc_status_xml &= "<Number>0</Number>"
                proc_status_xml &= "<MESSAGE>" & ex.Message.ToString & "</MESSAGE>"
                proc_status_xml &= "</Error>"
            End If
            ProcStatusXml = proc_status_xml
            ERPOrder_Process = -1
            'jackie add 2007/10/07 add send failed mail
            MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", "nada.liu@advantech.com.cn;tc.chen@advantech.com.tw;rudy.wang@advantech.com.tw", "", "", "create so failed" & strLocal_Filename, "", "maybe parse xml error! or <br/>" & proc_status_xml)
            Exit Function
        End Try

        ProcStatusXml = proc_status_xml

        If iRtn = 0 Then
            ERPOrder_Process = 0
        Else
            ERPOrder_Process = 1
        End If
    End Function

    Public Shared Function ERPOrder_Process(ByVal strLocal_Folder As String, ByVal strLocal_Filename As String, _
    ByRef ProcStatusXml As String, ByRef OrderStatusXml As String) As Integer
        Dim order_xmlString As String = ""
        Dim proc_status_xml As String = ""
        Dim Order_Status_Xml As String = ""
        Dim iRtn As Integer = 0
        Dim obj_FSO As System.IO.FileInfo = New System.IO.FileInfo(strLocal_Folder & UCase(strLocal_Filename))
        Dim objFStrm As System.IO.StreamReader
        Dim AEU_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", AEU_WS.Url)
        Try
            objFStrm = obj_FSO.OpenText
            order_xmlString = objFStrm.ReadToEnd()
            objFStrm.Close()
            'iRtn = AEU_WS.SO_CREATE(order_xmlString, proc_status_xml)
            iRtn = AEU_WS.SO_CREATE_NEW(order_xmlString, proc_status_xml, Order_Status_Xml)
        Catch ex As Exception
            If proc_status_xml = "" Or proc_status_xml = "EMPTY" Then
                proc_status_xml &= "<Error>"
                proc_status_xml &= "<Number>0</Number>"
                proc_status_xml &= "<MESSAGE>" & ex.Message.ToString & "</MESSAGE>"
                proc_status_xml &= "</Error>"
            End If
            ProcStatusXml = proc_status_xml
            ERPOrder_Process = -1
            Exit Function
        End Try

        ProcStatusXml = proc_status_xml
        OrderStatusXml = Order_Status_Xml

        If iRtn = 0 Then
            ERPOrder_Process = 0
        Else
            ERPOrder_Process = 1
        End If
    End Function

    Public Shared Function ProcStatus_Save(ByVal Proc_Status_Xml As String, ByVal strOrderNO As String, ByVal xStatus As String) As Integer
        Dim xDataTable As New DataTable
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim xmlDoc As New System.Xml.XmlDocument
        Try
            xmlDoc.LoadXml(Proc_Status_Xml)
            Dim xmlNR As System.Xml.XmlNodeReader = New System.Xml.XmlNodeReader(xmlDoc)
            Dim xDataSet As New DataSet
            xDataSet.ReadXml(xmlNR)
            xDataTable = xDataSet.Tables(xDataSet.Tables.Count - 1)
            Dim LineSEQ As Integer = 0
            Dim MaxLineSeqDR As DataTable
            MaxLineSeqDR = dbUtil.dbGetDataTable("B2B", "Select top 1 * from ORDER_PROC_STATUS where ORDER_NO='" & strOrderNO & "' Order by LINE_SEQ DESC")
            If MaxLineSeqDR.Rows.Count > 0 Then
                LineSEQ = CInt(MaxLineSeqDR.Rows(0).Item("LINE_SEQ"))
            End If
            'g_adoConn.Close()
            LineSEQ = LineSEQ + 1
            '
            'g_adoConn.Open()
            Dim i As Integer = 0
            While i <= xDataTable.Rows.Count - 1
                dbUtil.dbExecuteNoQuery("B2B", "Insert into ORDER_PROC_STATUS values( '" & strOrderNO & "', " & LineSEQ & ", " & CInt(xDataTable.Rows(i).Item("Number")) & ",'" & xDataTable.Rows(i).Item("MESSAGE") & "', getdate()," & xStatus & " )")
                'g_adoCmd.ExecuteNonQuery()
                i = i + 1
            End While
            'g_adoConn.Close()
        Catch ex As Exception
            ProcStatus_Save = -1
            Exit Function
        End Try
        ProcStatus_Save = 1
        'g_adoConn.Dispose()
    End Function

    Public Shared Function OrderXML_Update(ByVal strOrderNO As String) As Integer
        Dim order_xmlString As String = ""
        Dim obj_FSOR As System.IO.FileInfo = New System.IO.FileInfo("c:/MyAdvantech/files/so/" & UCase(strOrderNO) & ".xml")
        Dim obj_FSOW As System.IO.FileInfo = New System.IO.FileInfo("c:/MyAdvantech/files/so/" & UCase(strOrderNO) & "_Original.xml")
        Dim objFStrmR As System.IO.StreamReader
        Dim objFStrmW As System.IO.StreamWriter
        Try
            objFStrmR = obj_FSOR.OpenText
            order_xmlString = objFStrmR.ReadToEnd()
            objFStrmR.Close()
            objFStrmW = obj_FSOW.CreateText
            objFStrmW.WriteLine(order_xmlString)
            objFStrmW.Close()
        Catch ex As Exception
            OrderXML_Update = -1
            Exit Function
        End Try
        OrderXML_Update = 1
    End Function

#Region "B2BACL Function"



    Public Shared Function B2BACL_GetPrice_ABR(ByVal strPart_No As String, ByVal strCompany_Id As String, ByVal sales_org As String, ByVal intQty As Double, ByRef p_fltList_Price As Decimal, ByRef p_fltUnit_Price As Decimal) As Integer

        'Dim tempCompanyId As String = ""

        'Try
        '    If LCase(HttpContext.Current.Session("COMPANY_ID")) = "b2bguest" Then
        '        tempCompanyId = strCompany_Id
        '        strCompany_Id = Me.Global_inc1.GetCompanyForB2BGuest()
        '    End If
        'Catch ex As Exception
        '    ''response.write(strCompany_Id)
        '    ''response.end()
        'End Try

        'Dim sc3 As New b2b_ajp_ws.B2B_AJP_WS

        'Dim sc3 As New b2b_ws.B2B_AJP_WS
        'Dim WSDL_URL As String = ""

        ''Me.Global_inc1.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        'Util.GetSiteDefinition("AeuEbizB2BWs", WSDL_URL)

        'sc3.Url = WSDL_URL
        Try
            SAPDAL.SAPDAL.GetPriceRFC_ABR("168", sales_org, strCompany_Id, strPart_No, intQty, p_fltList_Price, p_fltUnit_Price)
        Catch ex As Exception
            p_fltList_Price = -1
            p_fltUnit_Price = -1
            Return -1
            Exit Function
        End Try

        'If LCase(HttpContext.Current.Session("COMPANY_ID")) = "b2bguest" Then
        '    strCompany_Id = tempCompanyId
        'End If


        p_fltList_Price = p_fltList_Price
        p_fltUnit_Price = p_fltUnit_Price


        If p_fltList_Price < 0 Then
            p_fltList_Price = 0
        End If

        If p_fltUnit_Price < 0 Then
            p_fltUnit_Price = 0
        End If
        ''--{2006-08-25}--Daive: add customer "B2BGUEST", Use "UUAAESC" to get price. It just see the list price
        'If LCase(HttpContext.Current.Session("COMPANY_ID")) = "b2bguest" Then
        '    p_fltUnit_Price = p_fltList_Price
        'Else
        If p_fltList_Price < p_fltUnit_Price Then
            p_fltList_Price = p_fltUnit_Price
        End If

        'If Global_inc1.IsRBU(strCompany_Id, "") Then
        If B2BACL_IsRBU(strCompany_Id, "") Then
            p_fltList_Price = -1
        End If
        'End If

        Return 1

    End Function

    Public Shared Function B2BACL_IsRBU(ByVal CompanyCode As String, ByRef RBUMailFormat As String) As Boolean
        Dim IsRBU As Boolean = False
        Select Case UCase(CompanyCode)
            Case "UUAAESC"
                RBUMailFormat = "advantech.de"
                IsRBU = True

            Case "EUKADV"
                RBUMailFormat = "advantech-uk.com"
                IsRBU = True

            Case "EFRA008"
                RBUMailFormat = "advantech.fr"
                IsRBU = True

            Case "EITW004"
                RBUMailFormat = "advantech.it"
                IsRBU = True

            Case "EHLC001"
                RBUMailFormat = "advantech.nl"
                IsRBU = True

            Case Else
                IsRBU = False

        End Select

        Return IsRBU

    End Function

#End Region

    Public Shared Function GetERPOrderStatus(ByVal OrderNo As String, ByRef ERPOrderStatusXml As String) As Integer
        Dim exeFunc As Integer = 0
        Dim iRtn As Integer = 0
        Dim AEU_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        'Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", AEU_WS.Url)
        AEU_WS.Timeout = 999999999
        'Try
        '    AEU_WS.Url = Global_Inc.dbExecuteScalar("", "", "select para_value from site_definition where site_parameter='AeuEbizB2bWs'")
        'Catch ex As Exception
        '    HttpContext.Current.Response.Write("<Br/>" & ex.Message)
        'End Try
        'Dim WSDL_URL As String = ""
        'Global_Inc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        'AEU_WS.Url = WSDL_URL
        Try
            exeFunc = Global_Inc.Pause(3)
            iRtn = AEU_WS.SALESORDER_GETSTATUS_old(OrderNo, ERPOrderStatusXml)
        Catch ex As Exception
            GetERPOrderStatus = -1
            Exit Function
        End Try

        If CInt(iRtn) = 0 Then
            GetERPOrderStatus = 0
            Exit Function
        End If
        GetERPOrderStatus = 1
    End Function

    '===================================================================================
    '  Function: Save Item changed in SAP to ORDER_DETAIL_CHANGED_IN_SAP
    '  little Skills: 
    '       1> Set All Item "Changed_Flag=2"    
    '       2> Set Item which exists in SAP_Order_Status_Xml "Changed_Flag=0" 
    '       3> Set Changed Item "Changed_Flag=1"
    '  Changed_Flag: 0--->Not Changed Item    1---> Changed Item    2---> Item Deleted
    '===================================================================================
    Public Shared Function OrderDetailChangedInSAP_Save(ByVal strOrder_No As String, ByVal SAP_Order_Status_Xml As String) As Integer
        'Dim g_adoConn As New SqlClient.SqlConnection
        'Dim g_adoCmd As SqlClient.SqlCommand
        'Global_Inc.DBConn_Get("", "", g_adoConn)
        'g_adoConn.Open()

        Dim OrderID_DR As DataTable
        OrderID_DR = dbUtil.dbGetDataTable("B2B", "select * from ORDER_MASTER where ORDER_NO='" & strOrder_No & "'")
        Dim strOrder_ID As String = ""
        Dim strOrder_Curr As String = ""
        If OrderID_DR.Rows.Count > 0 Then
            strOrder_ID = OrderID_DR.Rows(0).Item("ORDER_ID")
            strOrder_Curr = OrderID_DR.Rows(0).Item("Currency")
        End If
        'OrderID_DR.Close()
        Dim Order_Detail_DT As DataTable
        Order_Detail_DT = dbUtil.dbGetDataTable("B2B", "Select LINE_NO,PART_NO,QTY,DUE_DATE,UNIT_PRICE from ORDER_DETAIL where ORDER_ID = '" & strOrder_ID & "' order by LINE_NO")
        If Order_Detail_DT.Rows.Count > 0 Then
            Dim strInsertSQL As String = ""
            Dim i As Integer = 0
            While i <= Order_Detail_DT.Rows.Count - 1
                strInsertSQL = "Insert into ORDER_DETAIL_CHANGED_IN_SAP " & _
                               "Values('" & strOrder_ID & "','" & strOrder_No & "'," & Order_Detail_DT.Rows(i).Item("LINE_NO") & ",0,'" & Order_Detail_DT.Rows(i).Item("PART_NO") & "'," & Order_Detail_DT.Rows(i).Item("QTY") & ",'" & Order_Detail_DT.Rows(i).Item("DUE_DATE") & "'," & Order_Detail_DT.Rows(i).Item("UNIT_PRICE") & "," & Order_Detail_DT.Rows(i).Item("QTY") & ",'" & Order_Detail_DT.Rows(i).Item("DUE_DATE") & "'," & Order_Detail_DT.Rows(i).Item("UNIT_Price") & ",2)"
                dbUtil.dbExecuteNoQuery("B2B", strInsertSQL)
                'g_adoCmd.ExecuteNonQuery()
                i = i + 1
            End While
        End If

        If Not IsDBNull(SAP_Order_Status_Xml) And Trim(SAP_Order_Status_Xml) <> "" Then
            Dim xmlDoc As New System.Xml.XmlDocument
            xmlDoc.LoadXml(SAP_Order_Status_Xml)
            Dim xmlNR As System.Xml.XmlNodeReader = New System.Xml.XmlNodeReader(xmlDoc)
            Dim xDataSet As New DataSet
            xDataSet.ReadXml(xmlNR)

            Dim SAP_Order_Status_DT As DataTable
            SAP_Order_Status_DT = xDataSet.Tables(7)
            SAP_Order_Status_DT.DefaultView.Sort = "Itm_Number"
            '--{2006-08-21}-Daive: For Component Order, hide AGS-EW-**
            'If Global_Inc.IsB2BOwner(HttpContext.Current.Session("user_id")) Or LCase(HttpContext.Current.Session("user_id")) = "sabine.lin@advantech.fr" Then 
            If 1 = 1 Then
                If SAP_Order_Status_DT.Rows.Count > 0 Then
                    If CInt(SAP_Order_Status_DT.Rows(0).Item("Itm_Number")) < 100 Then

                    End If
                End If
            End If
            '--End------
            Dim Order_Detail_DR1 As DataTable
            If SAP_Order_Status_DT.Rows.Count > 0 Then
                Dim j As Integer = 0

                While j <= SAP_Order_Status_DT.Rows.Count - 1

                    'Dim g_adoConn1 As New SqlClient.SqlConnection
                    Order_Detail_DR1 = dbUtil.dbGetDataTable("B2B", "select * from Order_Detail where ORDER_ID = '" & strOrder_ID & "' and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")))
                    If Order_Detail_DR1.Rows.Count > 0 Then
                        'Dim sqlConn2 As SqlClient.SqlConnection = Nothing
                        dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL_CHANGED_IN_SAP Set CHANGED_FLAG =0 where ORDER_NO='" & strOrder_No & "' and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")) & "")
                        If SAP_Order_Status_DT.Rows(j).Item("Req_Qty") <> Order_Detail_DR1.Rows(0).Item("QTY") Then
                            dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL Set QTY = '" & SAP_Order_Status_DT.Rows(j).Item("Req_Qty") & "' where ORDER_ID = '" & strOrder_ID & "' and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")) & "")
                            dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL_CHANGED_IN_SAP Set NEW_QTY=" & SAP_Order_Status_DT.Rows(j).Item("Req_Qty") & ",CHANGED_FLAG =1 where ORDER_NO='" & strOrder_No & "' and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")) & "")
                        End If
                        'jackie add 2007/08/30 for P T issue
                        'jackie add 2007/12/04 for Z1 atp new rule
                        If Left(Order_Detail_DR1.Rows(0).Item("DeliveryPlant").ToString.ToUpper, 2) <> "TW" _
                            And Order_Detail_DR1.Rows(0).Item("NoATPFlag").ToString.ToUpper = "N" Then
                            If DateDiff("d", SAP_Order_Status_DT.Rows(j).Item("Req_Date"), Order_Detail_DR1.Rows(0).Item("DUE_DATE")) <> 0 Then
                                If BtosOrderCheck() = 1 Then
                                Else
                                    dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL Set DUE_DATE = '" & SAP_Order_Status_DT.Rows(j).Item("Req_Date") & "' where ORDER_ID = '" & strOrder_ID & "' and (Line_no<=100 or Line_no=900) and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")) & "")
                                End If
                                dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL_CHANGED_IN_SAP Set NEW_DUE_DATE='" & SAP_Order_Status_DT.Rows(j).Item("Req_Date") & "',CHANGED_FLAG =1 where ORDER_NO='" & strOrder_No & "' and (Line_no<=100 or Line_no=900) and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")) & "")
                            End If
                        End If
                        If FormatNumber(SAP_Order_Status_DT.Rows(j).Item("Net_Price"), 2) <> FormatNumber(Order_Detail_DR1.Rows(0).Item("UNIT_PRICE"), 2) Then
                            dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL Set UNIT_PRICE = " & CurrencySAP(SAP_Order_Status_DT.Rows(j).Item("Net_Price"), strOrder_Curr) & " where ORDER_ID = '" & strOrder_ID & "' and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")) & "")
                            dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL_CHANGED_IN_SAP Set NEW_UNIT_PRICE=" & CurrencySAP(SAP_Order_Status_DT.Rows(j).Item("Net_Price"), strOrder_Curr) & ",CHANGED_FLAG =1 where ORDER_NO='" & strOrder_No & "' and line_no=" & CInt(SAP_Order_Status_DT.Rows(j).Item("Itm_Number")) & "")
                        End If
                        'sqlConn2.Close()
                    End If
                    j = j + 1
                    'g_adoConn1.Close()
                    'g_adoConn1.Dispose()
                End While
            End If
            Dim strDeleteSQL As String = ""
            strDeleteSQL = "Delete from Order_Detail where ORDER_ID = '" & strOrder_ID & "' and PART_NO in " & _
                           "(Select PART_NO from ORDER_DETAIL_CHANGED_IN_SAP where ORDER_NO='" & strOrder_No & "' and CHANGED_FLAG=2)"
            'Dim sqlConn As SqlClient.SqlConnection = Nothing
            dbUtil.dbExecuteNoQuery("B2B", strDeleteSQL)
            'sqlConn.Close()
        End If
        If IsDBNull(SAP_Order_Status_Xml) Or SAP_Order_Status_Xml = "" Then
            'Dim sqlConn As SqlClient.SqlConnection = Nothing
            dbUtil.dbExecuteNoQuery("B2B", "Update ORDER_DETAIL_CHANGED_IN_SAP Set CHANGED_FLAG =0 where ORDER_NO='" & strOrder_No & "'")
            'sqlConn.Close()
        End If
        Return 1
    End Function
    Public Shared Function CurrencySAP(ByVal money As Double, ByVal curr As String) As Decimal
        'Return money
        Dim factor As String = dbUtil.dbGetDataTable("MY", String.Format("select isnull(factor,'') from SAP_TCURX where currency='{0}'", curr)).Rows(0).Item(0).ToString
        Return CDbl(money) * Math.Pow(10, (2 - IIf(factor = "", 2, CInt(factor))))
    End Function
    Public Shared Function IsNumericItem_Expand(ByVal PartNO As String) As String
        If Global_Inc.IsNumericItem(PartNO) Then
            IsNumericItem_Expand = "00000000" & PartNO
        Else
            IsNumericItem_Expand = PartNO
        End If
    End Function

    Public Shared Function IsNumericItem_Shrink(ByVal PartNO As String) As String
        If Global_Inc.IsNumericItem(PartNO) Then
            IsNumericItem_Shrink = Mid(PartNO, 9)
        Else
            IsNumericItem_Shrink = PartNO
        End If
    End Function

    Public Shared Function SendFailedOrderMail(ByVal strOrderNO As String) As Integer
        Dim strStyle As String = ""
        Dim strBody As String = ""
        Dim t_strHTML As String = ""

        Dim FROM_Email As String = ""
        Dim TO_Email As String = ""
        Dim CC_Email As String = ""
        Dim BCC_Email As String = ""
        Dim Subject_Email As String = ""
        Dim AttachFile As String = ""
        Dim MailBody As String = ""

        '--Mail Style  
        strStyle = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 8pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        strStyle = strStyle & "</style>"
        '--Mail Style
        '--Mail Body	
        strBody = strBody & "<html><body><center>"
        '	strBody = strBody & "<link href=""http://b2b.advantech-nl.nl/utility/ebiz.aeu.style.css"" rel=""stylesheet"">"
        strBody = strBody & "<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        strBody = strBody & "<tr><td colspan=""3"">"
        strBody = strBody & "&nbsp;<font size=5 color=""#000000""><b>Failed Order Message</b></font>&nbsp;&nbsp;&nbsp;&nbsp;" & "<br><br>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"


        strBody = strBody & "<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        strBody = strBody & "<tr><td align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC""><font color=""#ffffff"">"
        strBody = strBody & "&nbsp;<b>Message</b>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td align=""left"" width=""100%"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""18"" bgcolor=""#d8e4f8""><font color=""#316ac5"">"
        strBody = strBody & "&nbsp;<b>Order Process Message(<font color=""green"">" & strOrderNO & "</font>)</b>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td>"
        strBody = strBody & "<table width=""731"" bgcolor=""#DCDCDC"" style=""border:#CFCFCF 1px solid"" class=""text"" cellspacing=""0"" cellpadding=""0"">"
        Dim strCC As String = ""
        Dim l_strSQLCmd As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection
        'Dim g_adoCmd As New SqlClient.SqlCommand
        Dim CC_DT As New DataTable
        'Global_Inc.DBConn_Get("", "", g_adoConn)
        'g_adoConn.Open()
        l_strSQLCmd = "select distinct userid from company_contact " & _
                  "where company_id='" & HttpContext.Current.Session("COMPANY_ID") & "'"
        CC_DT = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim i As Integer = 0
        Do While i <= CC_DT.Rows.Count - 1
            strCC = strCC & CC_DT.Rows(i).Item("userid") & ";"
            i = i + 1
        Loop
        'g_adoConn.Close()

        Dim LineSEQ_DR As DataTable
        Dim LineSEQ As Integer = 0
        Dim Message_DT As New DataTable
        LineSEQ_DR = dbUtil.dbGetDataTable("B2B", "select IsNull(max(LINE_SEQ),0) as MAXLINE_SEQ from ORDER_PROC_STATUS where ORDER_NO='" & strOrderNO & "'")
        If LineSEQ_DR.Rows.Count > 0 Then
            LineSEQ = LineSEQ_DR.Rows(0).Item("MAXLINE_SEQ")
        End If
        'g_adoConn.Close()
        Dim NoMessageFlag As Boolean = False
        Try
            If LineSEQ = 0 Then
                NoMessageFlag = True
            Else
                Message_DT = dbUtil.dbGetDataTable("B2B", "select * from ORDER_PROC_STATUS where LINE_SEQ=" & LineSEQ & " and ORDER_NO='" & strOrderNO & "'")
            End If
        Catch ex As Exception
            HttpContext.Current.Response.Write("select * from ORDER_PROC_STATUS where LINE_SEQ=" & LineSEQ & " and ORDER_NO='" & strOrderNO & "'")
            HttpContext.Current.Response.End()
        End Try

        If NoMessageFlag <> True Then
            Dim j As Integer = 0
            While j <= Message_DT.Rows.Count - 1
                strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
                strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & Message_DT.Rows(j).Item("MESSAGE")
                strBody = strBody & "</font></td></tr>"
                j = j + 1
            End While
        End If

        If NoMessageFlag = True Then
            strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
            strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">" & "No message"
            strBody = strBody & "</font></td></tr>"
        End If

        strBody = strBody & "<tr><td height=""5"" bgcolor=""#ffffff"">"
        strBody = strBody & "&nbsp;"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td height=""5"" align=""center"" bgcolor=""#ffffff""><font size=3><i><u>"
        'strBody = strBody & "<a href=""http://b2b.advantech-nl.nl/order/Order_Recovery_sap.asp?Order_No="&strOrderNO&"""><i><b><font size=4 color=""red"">Press Link To Recover This Order</font></b></i></a>"
        strBody = strBody & "<a href=""http://" & HttpContext.Current.Request.ServerVariables("HTTP_HOST") & "/order/Order_Recovery_v6.aspx?Order_No=" & strOrderNO & """><i><b><font size=4 color=""red"">Press Link To Recover This Order</font></b></i></a>"
        'strBody = strBody & "<a href=""http://172.21.34.33/order/Order_Recovery_v6.aspx?Order_No=" & strOrderNO & """><i><b><font size=4 color=""red"">Press Link To Recover This Order</font></b></i></a>"
        strBody = strBody & "</u></i></font></td></tr>"

        strBody = strBody & "</table>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"
        strBody = strBody & "</body></html>"

        t_strHTML = Replace(strBody, "<body>", "<body>" & strStyle)
        '--Mail Body
        Dim CompanyInfo_DR As DataTable
        CompanyInfo_DR = dbUtil.dbGetDataTable("B2B", "select * from ORDER_MASTER where ORDER_NO='" & strOrderNO & "'")
        Dim strPONo As String = ""
        Dim strCompanyId As String = ""
        If CompanyInfo_DR.Rows.Count > 0 Then
            strPONo = CompanyInfo_DR.Rows(0).Item("PO_NO")
            strCompanyId = CompanyInfo_DR.Rows(0).Item("SOLDTO_ID")
        End If
        'g_adoConn.Close()

        Dim CompanyName_DR As DataTable
        CompanyName_DR = dbUtil.dbGetDataTable("B2B", "select COMPANY_NAME from sap_dimcompany where COMPANY_ID='" & strCompanyId & "'")
        Dim strCompanyName As String = ""
        If CompanyName_DR.Rows.Count > 0 Then
            strCompanyName = CompanyName_DR.Rows(0).Item("COMPANY_NAME")
        Else
            strCompanyName = strCompanyId
        End If
        'g_adoConn.Close()

        FROM_Email = "myadvantech@advantech.com"
        TO_Email = strCC
        CC_Email = "eBusiness.AEU@advantech.eu;AESC.SCM@advantech.com"
        'Subject_Email = "Advantech Failed Order(" & strPONo & "/" & strOrderNO & ") for " & strCompanyName & " (" & strCompanyId & ")"
        Subject_Email = "Advantech Failed Order(" & strPONo & "/" & strOrderNO & ") for " & strCompanyName & " (" & strCompanyId & ")"
        AttachFile = ""
        MailBody = t_strHTML
        If NoMessageFlag <> True Then
            'Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
            Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        End If

        Return 1
    End Function

    Public Shared Function GetOrderStatusFailed_SendMail(ByVal strOrderNO As String) As Integer
        Dim strStyle As String = ""
        Dim strBody As String = ""
        Dim t_strHTML As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection

        Dim FROM_Email As String = ""
        Dim TO_Email As String = ""
        Dim CC_Email As String = ""
        Dim BCC_Email As String = ""
        Dim Subject_Email As String = ""
        Dim AttachFile As String = ""
        Dim MailBody As String = ""

        '--Mail Style  
        strStyle = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 8pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        strStyle = strStyle & "</style>"
        '--Mail Style
        '--Mail Body	
        strBody = strBody & "<html><body><center>"
        '	strBody = strBody & "<link href=""http://b2b.advantech-nl.nl/utility/ebiz.aeu.style.css"" rel=""stylesheet"">"
        strBody = strBody & "<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        strBody = strBody & "<tr><td colspan=""3"">"
        strBody = strBody & "&nbsp;<font size=5 color=""#000000""><b>Geting Order Status From SAP Failed</b></font>&nbsp;&nbsp;&nbsp;&nbsp;" & "<br><br>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"

        strBody = strBody & "<table width=""731"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        strBody = strBody & "<tr><td align=""left"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC""><font color=""#ffffff"">"
        strBody = strBody & "&nbsp;<b>Message</b>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td align=""left"" width=""100%"" style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""18"" bgcolor=""#d8e4f8""><font color=""#316ac5"">"
        strBody = strBody & "&nbsp;<b>Tip (<font color=""green"">" & strOrderNO & "</font>)</b>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td>"
        strBody = strBody & "<table width=""731"" bgcolor=""#DCDCDC"" style=""border:#CFCFCF 1px solid"" class=""text"" cellspacing=""0"" cellpadding=""0"">"

        strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
        strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">You can press the following link to check the order status in SAP."
        strBody = strBody & "</font></td></tr>"
        strBody = strBody & "<tr><td bgcolor=""#ffffff""><font size=3>"
        strBody = strBody & "&nbsp;&nbsp;+&nbsp;<font color=""red"">You can also query the order status in SAP by this order number."
        strBody = strBody & "</font></td></tr>"

        strBody = strBody & "<tr><td height=""5"" bgcolor=""#ffffff"">"
        strBody = strBody & "&nbsp;"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "<tr><td height=""5"" align=""center"" bgcolor=""#ffffff""><font size=3><i><u>"
        'strBody = strBody & "<a href=""http://" & Request.ServerVariables("HTTP_HOST") & "/order/inquiryOrderStatus2.aspx?txtOrderNo=" & strOrderNO & """><i><b><font size=4 color=""red"">Press Link To Check This Order Status In SAP</font></b></i></a>"
        strBody = strBody & "<a href=""http://b2b.advantech.eu/order/inquiryOrderStatus2.aspx?txtOrderNo=" & strOrderNO & """><i><b><font size=4 color=""red"">Press Link To Check This Order Status In SAP</font></b></i></a>"
        strBody = strBody & "</u></i></font></td></tr>"

        strBody = strBody & "</table>"
        strBody = strBody & "</td></tr>"
        strBody = strBody & "</table>"
        strBody = strBody & "</body></html>"

        t_strHTML = Replace(strBody, "<body>", "<body>" & strStyle)
        '--Mail Body

        Dim CompanyInfo_DR As DataTable
        CompanyInfo_DR = dbUtil.dbGetDataTable("B2B", "select * from ORDER_MASTER where ORDER_NO='" & strOrderNO & "'")
        Dim strPONo As String = ""
        Dim strCompanyId As String = ""
        If CompanyInfo_DR.Rows.Count > 0 Then
            strPONo = CompanyInfo_DR.Rows(0).Item("PO_NO")
            strCompanyId = CompanyInfo_DR.Rows(0).Item("SOLDTO_ID")
        End If
        'g_adoConn.Close()


        Dim CompanyName_DR As DataTable
        CompanyName_DR = dbUtil.dbGetDataTable("B2B", "select * from sap_dimCOMPANY where COMPANY_ID='" & strCompanyId & "'")
        Dim strCompanyName As String = ""
        If CompanyName_DR.Rows.Count > 0 Then
            strCompanyName = CompanyName_DR.Rows(0).Item("COMPANY_NAME")
        Else
            strCompanyName = strCompanyId
        End If
        'g_adoConn.Close()

        FROM_Email = "myadvantech@advantech.com"
        TO_Email = "tc.chen@advantech.com.tw;jackie.wu@advantech.com.cn;"
        CC_Email = "ebusiness.aeu@advantech.eu;"
        BCC_Email = "emil.hsu@advantech.com.tw;jackie.wu@advantech.com.cn;"
        'Subject_Email = "Geting Order Status From SAP Failed(" & strPONo & "/" & strOrderNO & " for " & strCompanyName & " " & strCompanyId & ")"
        Subject_Email = "Geting Order Status From SAP Failed(" & strPONo & "/" & strOrderNO & " for " & strCompanyName & " " & strCompanyId & ")"
        AttachFile = ""
        MailBody = t_strHTML

        'Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        Call MailUtil.Utility_EMailPage(FROM_Email, TO_Email, CC_Email, BCC_Email, Subject_Email, AttachFile, MailBody)
        'g_adoConn.Dispose()
        Return 1
    End Function

    Public Shared Function ConfigurationSheetHtml_Get(ByRef HSTR As String) As String
        '------------- check is phase out begin
        Dim str_mes As String = ""
        Dim iRet As Integer = 0
        Dim iRtn As Integer = 0
        'Dim g_adoConn As New SqlClient.SqlConnection
        iRet = StrPhaseOut(str_mes)

        HSTR = ""
        HSTR = HSTR & "<HTML>"
        HSTR = HSTR & "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>"
        HSTR = HSTR & "	<HEAD>"
        HSTR = HSTR & "		<TITLE>Configuration & QC Inspection Sheet</TITLE></HEAD><BODY bgcolor='#ffffff'>"
        HSTR = HSTR & "		<center>"

        Dim l_strSQLCmd As String = ""
        Dim l_adoRs_seq As DataTable
        l_strSQLCmd = "select * from configuration_catalog_category where catalog_id =" & "'" & HttpContext.Current.Session("G_CATALOG_ID") & "'" & " and parent_category_id='root' order by catalogcfg_seq"
        'HttpContext.Current.Response.Write (l_strSQLCmd)
        l_adoRs_seq = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)

        Dim szCompany_Name As String = ""
        Dim PszCategory_Id As String = ""
        Dim PszDueDate As String = ""
        Dim PszRequireDueDate As String = ""
        Dim szCategory_Name As String = ""
        Dim szQty As Integer = 0
        Dim Root_Category_Name As String = ""
        Dim l_adoDT_detail As New DataTable
        Dim i As Integer = 0
        Dim CountNo As Integer = 0
        Dim l_strSQLCmd_Child As String = ""
        Dim l_adoRs_detail_child As DataTable
        Dim Product_site As String = ""
        Dim l_strSQLCmd_Prd As String = ""
        Dim l_adoRs_detail_Prd As DataTable
        Dim szCF_Name As String = ""
        Dim StrSiteURL As String = ""
        Dim ChildCategory_Name As String = ""

        For Each r As DataRow In l_adoRs_seq.Rows
            HSTR = HSTR & str_mes       ' jackie add 2005/12/15 for phase out check
            HSTR = HSTR & "		<TABLE width='620' border='0' cellspacing='0' cellpadding='0' id='TABLE1'>"
            HSTR = HSTR & "				<TR>"
            HSTR = HSTR & "					<TD><TABLE width='620' border='0' cellspacing='0' cellpadding='0' ID='Table2'>"
            HSTR = HSTR & "							<TR>"
            HSTR = HSTR & "								<TD width='201'><img src='../images/btos_logo.jpg'/></TD>"
            HSTR = HSTR & "								<TD align='middle' colspan='2' valign='bottom' width='419'><B><FONT face='Arial, Helvetica, sans-serif' size='3'>CONFIGURATION "
            HSTR = HSTR & "											&amp; QC INSPECTION SHEET </FONT></B>"
            HSTR = HSTR & "								</TD>"
            HSTR = HSTR & "							</TR>"
            HSTR = HSTR & "							<TR>"
            HSTR = HSTR & "								<TD colspan='3'><HR size='1' noshade>"
            HSTR = HSTR & "								</TD>"
            HSTR = HSTR & "							</TR>"
            HSTR = HSTR & "							<TR>"
            HSTR = HSTR & "								<TD colspan='3'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1'><B>Advantech Europe BV "
            HSTR = HSTR & "											</B></FONT><FONT face='Arial, Helvetica, sans-serif' size='1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
            HSTR = HSTR & "										Ekkersrijt 5708, 5692 Ep Son, The Netherlands  "
            HSTR = HSTR & "										&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tel: +31 40-26-77-022&nbsp;Fax: +31 40-26-77-006 "
            HSTR = HSTR & "										</FONT></TD>"
            HSTR = HSTR & "							</TR>"
            HSTR = HSTR & "						</TABLE>"
            HSTR = HSTR & "					</TD>"
            HSTR = HSTR & "				</TR>"
            HSTR = HSTR & "				<TR>"
            HSTR = HSTR & "					<TD>&nbsp;</TD>"
            HSTR = HSTR & "				</TR>"
            HSTR = HSTR & "				<TR>"
            HSTR = HSTR & "					<TD><TABLE width='627' border='1' cellspacing='0' cellpadding='0' ID='Table3'>"
            HSTR = HSTR & "							<TR>"
            iRtn = CompanyName_Get(HttpContext.Current.Session("COMPANY_ID"), szCompany_Name)
            HSTR = HSTR & "								<TD colspan='3' height='20' valign='center'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;SOLD "
            HSTR = HSTR & "										TO:</FONT><FONT face='Verdana, Arial, Helvetica, sans-serif' size='2' color='#333333'>&nbsp;" & szCompany_Name & "</B></FONT><B>&nbsp;</B></TD>"
            HSTR = HSTR & "								<TD colspan='2' width='182'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;COMPANY "
            HSTR = HSTR & "											CODE: " & HttpContext.Current.Session("COMPANY_ID") & "</B></FONT></TD>"
            HSTR = HSTR & "							</TR>"
            HSTR = HSTR & "							<TR>"
            HSTR = HSTR & "								<TD width='101'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;SALES:</B></FONT></TD>"
            HSTR = HSTR & "								<TD width='163'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;ORDER "
            HSTR = HSTR & "											NO:" & HttpContext.Current.Session("Order_No") & "</B></FONT>&nbsp;</TD>"
            HSTR = HSTR & "								<TD width='164'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;Placed "
            HSTR = HSTR & "											By: " & HttpContext.Current.Session("USER_ID") & "</B></FONT></TD>"


            iRtn = LogisticsDueDate_Get(HttpContext.Current.Session("G_CATALOG_ID"), r.Item("CATEGORY_ID"), PszDueDate)
            iRtn = LogisticsRequiredt_Get(HttpContext.Current.Session("G_CATALOG_ID"), r.Item("CATEGORY_ID"), PszRequireDueDate)

            HSTR = HSTR & "								<TD colspan='2' width='182'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;SHIPPING "
            HSTR = HSTR & "											DATE:" & PszDueDate & "</B><BR><B>&nbsp;REQUIRED DATE:" & PszRequireDueDate & "</B></FONT></TD>"
            HSTR = HSTR & "							</TR>"
            HSTR = HSTR & "						</TABLE>"
            HSTR = HSTR & "					</TD>"
            HSTR = HSTR & "				</TR>"
            HSTR = HSTR & "				<TR>"
            HSTR = HSTR & "					<TD>&nbsp;<TABLE width='627' border='1' cellspacing='0' cellpadding='0' ID='Table4'>"
            HSTR = HSTR & "							<TR>"
            HSTR = HSTR & "								<TD height='20'><table width='100%' border='0' cellspacing='1' cellpadding='1' ID='Table5'>"
            HSTR = HSTR & "										<tr bgcolor='#33CCCC'>"
            iRtn = Root_CategoryName_Get(r.Item("catalogcfg_seq"), HttpContext.Current.Session("G_CATALOG_ID"), szCategory_Name, szQty)
            Root_Category_Name = szCategory_Name
            HSTR = HSTR & "											<td colspan='6' align='center'><font face='Arial, Helvetica, sans-serif' size='2'><B>BTOS "
            HSTR = HSTR & "														Configuration for <font color='blue'>" & szCategory_Name & "</font>&nbsp;x" & szQty & "</B></font></td>"
            HSTR = HSTR & "										</tr>"
            HSTR = HSTR & "										<tr bgcolor='#33CCCC'>"
            HSTR = HSTR & "											<td width='5%' align='left'><font face='Arial, Helvetica, sans-serif' size='1'>#</font></td>"
            HSTR = HSTR & "											<td width='30%'><font face='Arial, Helvetica, sans-serif' size='1'>Category</font></td>"
            HSTR = HSTR & "											<td width='20%'><font face='Arial, Helvetica, sans-serif' size='1'>Advantech No.</font></td>"
            HSTR = HSTR & "											<td width='30%'><font face='Arial, Helvetica, sans-serif' size='1'>Description</font></td>"
            HSTR = HSTR & "											<td width='5%' align='center'><font face='Arial, Helvetica, sans-serif' size='1'>QTY</font></td>"
            HSTR = HSTR & "											<td width='5%' align='center'><font face='Arial, Helvetica, sans-serif' size='1'>Site</font></td>"
            HSTR = HSTR & "										</tr>"

            l_strSQLCmd = "select category_id,category_name,isnull(category_desc,'') as category_desc,category_qty,parentseqno,seq_no from configuration_catalog_category where catalog_id =" & _
               "'" & HttpContext.Current.Session("G_CATALOG_ID") & "'" & " and category_type='category' and parent_category_id<>'root' " & _
               " and category_id not like '%S-WARRANTY%' and catalogcfg_seq=" & r.Item("catalogcfg_seq") & _
               " group by category_id,category_name,category_desc,category_qty,parentseqno,seq_no Order by Seq_no,parentseqno"
            'HttpContext.Current.Response.Write ("<BR>" & l_strSQLCmd)
            REM == Show on General items ==
            l_adoDT_detail = New DataTable
            l_adoDT_detail = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
            REM == Initial CountNo ==
            CountNo = 0
            i = 0
            Do While i <= l_adoDT_detail.Rows.Count - 1
                Dim g_adoConn1 As New System.Data.SqlClient.SqlConnection
                l_strSQLCmd_Child = "select * from configuration_catalog_category where catalog_id =" & "'" & HttpContext.Current.Session("G_CATALOG_ID") & "'" & _
                   " and category_type='component' and parent_category_id = '" & l_adoDT_detail.Rows(i).Item("category_id") & _
                   "' and parentseqno=" & l_adoDT_detail.Rows(i).Item("parentseqno") & " and catalogcfg_seq=" & r.Item("catalogcfg_seq") & " Order by Seq_no"

                l_adoRs_detail_child = dbUtil.dbGetDataTable("B2B", l_strSQLCmd_Child)
                'l_adoRs_detail_child.Read()
                szCategory_Name = l_adoDT_detail.Rows(i).Item("category_name")
                If InStr(UCase(szCategory_Name), "KEYBOARD") = 0 And InStr(UCase(szCategory_Name), "POWER CODE") = 0 And InStr(UCase(szCategory_Name), "MOUSE") = 0 And InStr(UCase(szCategory_Name), "MONITOR") = 0 Then
                    ChildCategory_Name = l_adoRs_detail_child.Rows(0).Item("category_name")
                    CountNo = CountNo + 1
                    HSTR = HSTR & "										<tr bgcolor='#DDDDDD'>"
                    HSTR = HSTR & "											<td width='5%' align='left'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & CountNo & "</b></font></td>"
                    HSTR = HSTR & "											<td width='30%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & szCategory_Name & " </b></font></td>"
                    HSTR = HSTR & "											<td width='20%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & l_adoRs_detail_child.Rows(0).Item("category_name") & "</b></font></td>"
                    HSTR = HSTR & "											<td width='30%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & l_adoRs_detail_child.Rows(0).Item("category_desc") & "</b></font></td>"
                    HSTR = HSTR & "											<td width='5%' align='center'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & FormatNumber(l_adoRs_detail_child.Rows(0).Item("category_qty") / szQty, 0) & "</b></font></td>"
                    Dim g_adoConn2 As New System.Data.SqlClient.SqlConnection
                    'l_strSQLCmd_Prd = "select IsNull(product_site,'') as product_site from product where part_no ='" & ChildCategory_Name & "'"
                    'l_adoRs_detail_Prd = dbUtil.dbGetDataTable("B2B", l_strSQLCmd_Prd)
                    'If l_adoRs_detail_Prd.Rows.Count = 0 Then
                    '    Product_site = "1000"
                    'Else
                    '    Product_site = l_adoRs_detail_Prd.Rows(0).Item("Product_site")
                    'End If
                    Product_site = 1000
                    HSTR = HSTR & "											<td width='5%' align='right'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & Product_site & "&nbsp;</b></font></td>"
                    HSTR = HSTR & "										</tr>"
                End If
                i = i + 1
            Loop

            REM == Show on Accessory  items ==			
            HSTR = HSTR & "										<tr bgcolor='#33CCCC'>"
            HSTR = HSTR & "											<td colspan='6' align='center'><font face='Arial, Helvetica, sans-serif' size='2'><B>  "
            HSTR = HSTR & "														<font color='black'>Accessory</font></B></font></td>"
            HSTR = HSTR & "										</tr>"

            i = 0
            CountNo = 0
            Do While i <= l_adoDT_detail.Rows.Count - 1
                Dim g_adoConn1 As New System.Data.SqlClient.SqlConnection
                l_strSQLCmd_Child = "select * from configuration_catalog_category where catalog_id =" & "'" & HttpContext.Current.Session("G_CATALOG_ID") & "'" & _
                   " and category_type='component' and parent_category_id = '" & l_adoDT_detail.Rows(i).Item("category_id") & _
                   "' and parentseqno=" & l_adoDT_detail.Rows(i).Item("parentseqno") & " and catalogcfg_seq=" & r.Item("catalogcfg_seq") & " Order by Seq_no"

                l_adoRs_detail_child = dbUtil.dbGetDataTable("B2B", l_strSQLCmd_Child)
                'l_adoRs_detail_child.Read()

                szCategory_Name = l_adoDT_detail.Rows(i).Item("category_name")
                If InStr(UCase(szCategory_Name), "KEYBOARD") = 1 Or InStr(UCase(szCategory_Name), "POWER CODE") = 1 Or InStr(UCase(szCategory_Name), "MOUSE") = 1 Or InStr(UCase(szCategory_Name), "MONITOR") = 1 Then
                    CountNo = CountNo + 1
                    HSTR = HSTR & "										<tr bgcolor='#DDDDDD'>"
                    HSTR = HSTR & "											<td width='5%' align='left'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & CountNo & "</b></font></td>"
                    HSTR = HSTR & "											<td width='30%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & szCategory_Name & " </b></font></td>"
                    HSTR = HSTR & "											<td width='20%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & l_adoRs_detail_child.Rows(0).Item("category_name") & "</b></font></td>"
                    HSTR = HSTR & "											<td width='30%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & l_adoRs_detail_child.Rows(0).Item("category_desc") & "</b></font></td>"
                    HSTR = HSTR & "											<td width='5%' align='center'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & l_adoRs_detail_child.Rows(0).Item("category_qty") & "</b></font></td>"

                    Product_site = ""
                    HSTR = HSTR & "											<td width='5%' align='right'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & Product_site & "&nbsp;</b></font></td>"
                    HSTR = HSTR & "										</tr>"
                End If
                i = i + 1
            Loop

            REM == Configutaion File to Get ==
            HSTR = HSTR & "										<tr bgcolor='#DDDDDD'>"
            HSTR = HSTR & "											<td width='5%' align='left'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & "***" & "</b></font></td>"
            HSTR = HSTR & "											<td width='20%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & "Configuration File" & "</b></font></td>"
            iRtn = ConfigurationFile_Get(r.Item("catalogcfg_seq"), Root_Category_Name, szCF_Name)
            HSTR = HSTR & "											<td width='30%' colspan=5><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b><a href='http://172.20.1.31/cbom/CFiles/" & szCF_Name & "'>" & szCF_Name & "</a></b></font></td>"
            HSTR = HSTR & "										</tr>"

            HSTR = HSTR & "							<tr bgcolor='#33CCCC'>"
            HSTR = HSTR & "								<td width='90%' align='middle' colspan='6'>"
            REM HSTR = HSTR & "									<textarea width='100%' name='Notes' rows='5' cols='60' ID='Textarea1'>" & HttpContext.Current.Session("CONFIGURATION_NOTE") & "</textarea>"
            REM 20040729 HSTR = HSTR & "								
            HSTR = HSTR & "									<textarea width='100%' name='Notes' rows='5' cols='60' ID='Textarea1'>" & " " & "</textarea>"
            HSTR = HSTR & "								</td>"
            HSTR = HSTR & "							</tr>"
            HSTR = HSTR & "						</TABLE>"
            HSTR = HSTR & "					</TD>"
            HSTR = HSTR & "				</TR>"
            HSTR = HSTR & "			</TABLE>"
            HSTR = HSTR & "			</TD></TR><TR>"
            HSTR = HSTR & "				<TD></TD>"
            HSTR = HSTR & "			</TR>"
            HSTR = HSTR & "			<TR>"
            HSTR = HSTR & "				<TD>&nbsp;</TD>"
            HSTR = HSTR & "			</TR>"
            HSTR = HSTR & "			<TR>"
            HSTR = HSTR & "				<TD><TABLE width='100%' border='1' cellspacing='0' cellpadding='0' ID='Table6'>"
            HSTR = HSTR & "						<TR>"
            HSTR = HSTR & "							<TD width='211'>&nbsp;<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>ASSEMBLER:</B></FONT></TD>"
            HSTR = HSTR & "							<TD width='203'>&nbsp;<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>QC#1:</B></FONT></TD>"
            HSTR = HSTR & "							<TD width='198'>&nbsp;<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>Checked "
            HSTR = HSTR & "										By:</B></FONT></TD>"
            HSTR = HSTR & "						</TR>"
            HSTR = HSTR & "					</TABLE>"
            HSTR = HSTR & "				</TD>"
            HSTR = HSTR & "			</TR>"
            HSTR = HSTR & "			<TR align='right'>"
            HSTR = HSTR & "				<TD><FONT face='Arial, Helvetica, sans-serif' size='1' color='#333333'>Advantech Configuration "
            HSTR = HSTR & "						&amp; QC Inspection Sheet, Rev. A02, 03-27-00</FONT></TD>"
            HSTR = HSTR & "			</TR>"
            HSTR = HSTR & "			<TR>"
            HSTR = HSTR & "				<TD>&nbsp;</TD>"
            HSTR = HSTR & "			</TR>"
            'HSTR = HSTR & "			<TR>"
            'HSTR = HSTR & "				<TD>&nbsp;</TD>"
            'HSTR = HSTR & "			</TR>"
            HSTR = HSTR & "			</TR><TR align='right'>"
            HSTR = HSTR & "				<TD><FONT face='Arial, Helvetica, sans-serif' size='1' color='#333333'>Rev.A0,&amp;&amp;S-001-A001-F003</FONT></TD>"
            HSTR = HSTR & "			</TR>"
            'HSTR = HSTR & "			<TR>"
            'HSTR = HSTR & "				<TD>&nbsp;"
            'HSTR = HSTR & "				</TD>"
            'HSTR = HSTR & "			</TR>"
            HSTR = HSTR & "			</TABLE>"
        Next


        HSTR = HSTR & "			</center>"
        HSTR = HSTR & "	</BODY>"
        HSTR = HSTR & "</HTML>"
        Return 1
    End Function

    Public Shared Function FirstComponentInfo_Get(ByVal Root_CATEGORY_ID As String, ByRef szCategory_Id As String) As Integer
        Dim l_strSQLCmd As String = ""
        Dim l_cate As DataTable
        REM == Get Category Info ==
        l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC FROM CONFIGURATION_CATALOG_CATEGORY WHERE (PARENT_CATEGORY_ID = '" & Root_CATEGORY_ID & "')"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & HttpContext.Current.Session("G_CATALOG_ID") & "'" & " Order by SEQ_NO "
        l_cate = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        Dim l_com As DataTable
        If l_cate.Rows.Count > 0 Then
            l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC FROM CONFIGURATION_CATALOG_CATEGORY WHERE (PARENT_CATEGORY_ID = '" & l_cate.Rows(0).Item("CATEGORY_ID") & "')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & HttpContext.Current.Session("G_CATALOG_ID") & "'"
            l_com = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
            If l_com.Rows.Count > 0 Then
                szCategory_Id = l_com.Rows(0).Item("CATEGORY_ID")
            Else
                Return -1
                Exit Function
            End If
        Else
            Return -1
            Exit Function
        End If
        Return 1
    End Function

    Public Shared Function LogisticsDueDate_Get(ByVal g_Catalog_Id As String, ByVal szCATEGORY_ID As String, ByRef szDueDate As String) As Integer
        REM == Select from Cart_Detail_Btos table to get Line_no and Cart_ID==
        LogisticsDueDate_Get = 1
        Dim SQLString As String = ""
        Dim dr As DataTable
        SQLString = "select CART_ID,CATEGORY_ID,CONFIG_ID,LINE_NO from CART_DETAIL_BTOS where CATEGORY_ID=" & "'" & szCATEGORY_ID & "'" & " and CONFIG_ID=" & "'" & g_Catalog_Id & "' order by line_no"
        dr = dbUtil.dbGetDataTable("B2B", SQLString)
        Dim dr_Logistcis As DataTable
        If dr.Rows.Count > 0 Then
            SQLString = "select isnull(Due_Date,'1900-1-1') as due_date from order_DETAIL where order_Id=" & "'" & dr.Rows(0).Item("CART_ID") & "'" & " And Line_No=" & "'" & dr.Rows(0).Item("LINE_NO") & "'"
            dr_Logistcis = dbUtil.dbGetDataTable("B2B", SQLString)
            If dr_Logistcis.Rows.Count > 0 Then
                szDueDate = dr_Logistcis.Rows(0).Item("Due_date")
            Else
                LogisticsDueDate_Get = 0
            End If
        Else
            LogisticsDueDate_Get = 0
        End If
        szDueDate = Global_Inc.FormatDate(szDueDate)
    End Function

    Public Shared Function LogisticsRequiredt_Get(ByVal g_Catalog_Id As String, ByVal szCATEGORY_ID As String, ByRef szDueDate As String) As Integer
        REM == Select from Cart_Detail_Btos table to get Line_no and Cart_ID==
        LogisticsRequiredt_Get = 1
        Dim SQLString As String = ""
        Dim dr As DataTable
        SQLString = "select CART_ID,CATEGORY_ID,CONFIG_ID,LINE_NO from CART_DETAIL_BTOS where CATEGORY_ID=" & "'" & szCATEGORY_ID & "'" & " and CONFIG_ID=" & "'" & g_Catalog_Id & "' order by line_no"
        dr = dbUtil.dbGetDataTable("B2B", SQLString)
        Dim dr_Logistcis As DataTable
        If dr.Rows.Count > 0 Then
            SQLString = "select isnull(Required_Date,'1900-1-1') as Required_Date from order_DETAIL where order_Id=" & "'" & dr.Rows(0).Item("CART_ID") & "'" & " And Line_No=" & "'" & dr.Rows(0).Item("LINE_NO") & "'"
            dr_Logistcis = dbUtil.dbGetDataTable("B2B", SQLString)
            If dr_Logistcis.Rows.Count > 0 Then
                szDueDate = dr_Logistcis.Rows(0).Item("Required_Date")
            Else
                LogisticsRequiredt_Get = 0
            End If
        Else
            LogisticsRequiredt_Get = 0
        End If
        szDueDate = Global_Inc.FormatDate(szDueDate)
    End Function

    Public Shared Function Root_CategoryName_Get(ByVal Catalogcfg_seq As Integer, ByVal g_Catalog_Id As String, _
    ByRef szCategory_Name As String, ByRef szCategory_Qty As Integer) As Integer
        REM == Get Category Info ==
        Dim l_strSQLCmd As String = ""
        Dim l_cate As DataTable
        l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC,CATEGORY_QTY FROM CONFIGURATION_CATALOG_CATEGORY WHERE (PARENT_CATEGORY_ID = '" & "Root" & "')"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & Catalogcfg_seq
        l_cate = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If l_cate.Rows.Count > 0 Then
            szCategory_Name = l_cate.Rows(0).Item("CATEGORY_Name")
            szCategory_Qty = l_cate.Rows(0).Item("CATEGORY_QTY")
            Root_CategoryName_Get = 1
        Else
            Root_CategoryName_Get = 0
        End If
    End Function

    Public Shared Function Parent_CategoryName_Get(ByVal Catalogcfg_seq As Integer, ByVal g_Catalog_Id As String, _
    ByVal szCategory_Id As String, ByRef szCategory_Name As String) As Integer
        REM == Get Category Info ==
        Dim l_strSQLCmd As String = ""
        Dim l_cate As DataTable
        l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC FROM CONFIGURATION_CATALOG_CATEGORY WHERE (CATEGORY_ID = '" & szCategory_Id & "')"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & Catalogcfg_seq
        l_cate = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If l_cate.Rows.Count > 0 Then
            szCategory_Name = l_cate.Rows(0).Item("CATEGORY_Name")
            Parent_CategoryName_Get = 1
        Else
            Parent_CategoryName_Get = 0
        End If
    End Function

    Public Shared Function ConfigurationFile_Get(ByVal Catalogcfg_seq As Integer, ByVal szCategory_Name As String, ByVal szCF_Name As String) As Integer
        REM == Get Category Info ==
        Dim l_strSQLCmd As String = ""
        Dim l_cate As DataTable
        l_strSQLCmd = " SELECT isnull(IMAGE_ID,'') as IMAGE_ID,isnull(Category_ID,'') as Category_ID,isnull(CATEGORY_Name,'') as CATEGORY_Name,isnull(Category_type,'') as Category_type,isnull(Parent_Category_id,'') as Parent_Category_id,isnull(CATEGORY_DESC,'') as CATEGORY_DESC FROM CONFIGURATION_CATALOG_CATEGORY WHERE (CATEGORY_Name = '" & szCategory_Name & "')"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & Catalogcfg_seq
        l_strSQLCmd = l_strSQLCmd & " AND (PARENT_CATEGORY_ID = '" & "Root" & "')"
        l_cate = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If l_cate.Rows.Count > 0 Then
            szCF_Name = l_cate.Rows(0).Item("IMAGE_ID")
            ConfigurationFile_Get = 1
        Else
            ConfigurationFile_Get = 0
        End If
    End Function

    Public Shared Function CTOS_ConfigurationSheetHtml_Get(ByRef HSTR As String) As Integer

        '------------- check is phase out begin
        Dim str_mes As String = ""
        Dim iRetVal As Integer = 0
        iRetVal = StrPhaseOut(str_mes)

        Dim iRtn As Integer = 0
        Dim Cust_Company_Name As String = ""
        iRtn = CompanyName_Get(HttpContext.Current.Session("COMPANY_ID"), Cust_Company_Name)
        HSTR = "<HTML>"
        HSTR = HSTR & "<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>"
        HSTR = HSTR & "<HEAD>"
        HSTR = HSTR & "<TITLE>Configuration & QC Inspection Sheet</TITLE>"
        HSTR = HSTR & "</HEAD>"
        HSTR = HSTR & "<BODY bgcolor='#ffffff'>		"
        HSTR = HSTR & "<center>"
        HSTR = HSTR & str_mes ' jackie add 2005/12/15 phase out check
        HSTR = HSTR & "<TABLE width='620' border='0' cellspacing='0' cellpadding='0' id='TABLE1'>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD><TABLE width='620' border='0' cellspacing='0' cellpadding='0' ID='Table2'>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD width='201'><IMG src='../images/btos_logo.jpg'></TD>"
        HSTR = HSTR & "<TD align='middle' colspan='2' valign='bottom' width='419'><B><FONT face='Arial, Helvetica, sans-serif' size='3'>"
        HSTR = HSTR & "CONFIGURATION 	&amp; QC INSPECTION SHEET </FONT></B>"
        HSTR = HSTR & "</TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD colspan='3'><HR size='1' noshade>"
        HSTR = HSTR & "</TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD colspan='3'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1'><B>Advantech Europe BV"
        HSTR = HSTR & "</B></FONT><FONT face='Arial, Helvetica, sans-serif' size='1'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        HSTR = HSTR & "Ekkersrijt 5708, 5692 Ep Son, The Netherlands"
        HSTR = HSTR & "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Tel: +31 40-26-77-022&nbsp;Fax: +31 40-26-77-006"
        HSTR = HSTR & "</FONT></TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "</TABLE>"
        HSTR = HSTR & "</TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD>&nbsp;"
        HSTR = HSTR & "</TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD><TABLE width='627' border='1' cellspacing='0' cellpadding='0' ID='Table3'>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD colspan='3' height='20' valign='center'>"
        HSTR = HSTR & "<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'>"
        HSTR = HSTR & "<B>&nbsp;SOLD TO:</FONT>"
        HSTR = HSTR & "<FONT face='Verdana, Arial, Helvetica, sans-serif' size='2' color='#333333'>&nbsp;" & Cust_Company_Name & "</B>"
        HSTR = HSTR & "</FONT><B>&nbsp;</B></TD>"
        HSTR = HSTR & "<TD colspan='2' width='182'>"
        HSTR = HSTR & "<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'>"
        HSTR = HSTR & "<B>&nbsp;COMPANY CODE: " & HttpContext.Current.Session("company_id") & "</B></FONT></TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD width='101'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;SALES:</B></FONT></TD>"
        HSTR = HSTR & "<TD width='163'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>&nbsp;ORDER NO:" & HttpContext.Current.Session("Order_No") & "</B></FONT>&nbsp;</TD>"
        HSTR = HSTR & "<TD width='164'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'>"
        HSTR = HSTR & "<B>&nbsp;Placed By: " & HttpContext.Current.Session("USER_ID") & "</B></FONT></TD>"
        HSTR = HSTR & "<TD colspan='2' width='182'><FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'>"

        Dim drDateRs As DataTable
        'drDateRs = dbUtil.dbGetDataReader("B2B", "select * from logistics_detail where logistics_id='" & HttpContext.Current.Session("logistics_id") & "' order by line_no asc",g_adoConn)
        drDateRs = dbUtil.dbGetDataTable("B2B", "select IsNull(due_date,'') as due_date, IsNull(required_date,'') as required_date, part_no, qty from order_detail where order_id='" & HttpContext.Current.Session("logistics_id") & "' order by line_no asc")
        If drDateRs.Rows.Count > 0 Then
            HSTR = HSTR & "<B>&nbsp;SHIPPING DATE:" & drDateRs.Rows(0).Item("due_date") & "</B>"
            HSTR = HSTR & "<BR><B>&nbsp;REQUIRED DATE:" & drDateRs.Rows(0).Item("required_date") & "</B></FONT>"
            HSTR = HSTR & "</TD>"
            HSTR = HSTR & "</TR>"
            HSTR = HSTR & "</TABLE>"
            HSTR = HSTR & "</TD>"
            HSTR = HSTR & "</TR>"
            HSTR = HSTR & "<TR>"
            HSTR = HSTR & "<TD>&nbsp;"
            HSTR = HSTR & "<TABLE width='627' border='1' cellspacing='0' cellpadding='0' ID='Table4'>"
            HSTR = HSTR & "<TR>"
            HSTR = HSTR & "<TD height='20'><table width='100%' border='0' cellspacing='1' cellpadding='1' ID='Table5'>"
            HSTR = HSTR & "<tr bgcolor='#33CCCC'>"
            HSTR = HSTR & "<td colspan='6' align='center'><font face='Arial, Helvetica, sans-serif' size='2'>"
            HSTR = HSTR & "<B>CTOS Configuration for <font color='blue'>" & drDateRs.Rows(0).Item("part_no") & "</font>&nbsp;x" & drDateRs.Rows(0).Item("qty") & "</B></font>"
            HSTR = HSTR & "</td>"
            HSTR = HSTR & "</tr>"

            HSTR = HSTR & "<tr bgcolor='#33CCCC'>"
            HSTR = HSTR & "<td width='5%' align='left'><font face='Arial, Helvetica, sans-serif' size='1'>#</font></td>"
            HSTR = HSTR & "<td width='30%'><font face='Arial, Helvetica, sans-serif' size='1'>Categoryt</font></td>"
            HSTR = HSTR & "<td width='20%'><font face='Arial, Helvetica, sans-serif' size='1'>Advantech No.</font></td>"
            HSTR = HSTR & "<td width='30%'><font face='Arial, Helvetica, sans-serif' size='1'>Description</font></td>"
            HSTR = HSTR & "<td width='5%' align='center'><font face='Arial, Helvetica, sans-serif' size='1'>QTY</font></td>"
            HSTR = HSTR & "<td width='5%' align='center'><font face='Arial, Helvetica, sans-serif' size='1'>Site</font></td>"
            HSTR = HSTR & "</tr>"
        End If
        Dim requiredDT As DataTable
        requiredDT = dbUtil.dbGetDataTable("B2B", "select distinct a.line_no, a.part_no, a.qty, IsNull(c.product_site,'') as product_site, isnull(c.product_desc,'') as category_desc from logistics_detail a, product c where a.part_no=c.part_no and a.logistics_id='" & HttpContext.Current.Session("logistics_id") & "'")
        'BOM_Count = 1
        Dim BOM_Category_Name As String = ""
        Dim BOM_Category_NameDr As DataTable
        Dim i As Integer = 0
        Do While i <= requiredDT.Rows.Count - 1

            BOM_Category_Name = ""
            BOM_Category_NameDr = dbUtil.dbGetDataTable("B2B", "select distinct parent_category_id from cbom_catalog_category where category_id='" & requiredDT.Rows(i).Item("part_no") & "'")
            If BOM_Category_NameDr.Rows.Count > 0 Then
                BOM_Category_Name = BOM_Category_NameDr.Rows(0).Item("parent_category_id")
            End If

            HSTR = HSTR & "<tr bgcolor='#DDDDDD'>"
            HSTR = HSTR & "<td width='5%' align='left'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & CInt(requiredDT.Rows(i).Item("line_no")) & "</b></font></td>"
            HSTR = HSTR & "<td width='30%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & BOM_Category_Name & "</b></font></td>"
            HSTR = HSTR & "<td width='20%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & requiredDT.Rows(i).Item("part_no") & "</b></font></td>"
            HSTR = HSTR & "<td width='30%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'>"
            HSTR = HSTR & "<b>" & requiredDT.Rows(i).Item("category_desc") & "</b></font>"
            HSTR = HSTR & "</td>"
            HSTR = HSTR & "<td width='5%' align='center'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & requiredDT.Rows(i).Item("qty") & "</b></font></td>"
            HSTR = HSTR & "<td width='5%' align='right'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>" & requiredDT.Rows(i).Item("product_site") & "&nbsp;</b></font>"
            HSTR = HSTR & "</td>"
            HSTR = HSTR & "</tr>"
            i = i + 1
        Loop

        HSTR = HSTR & "<tr bgcolor='#33CCCC'>"
        HSTR = HSTR & "<td colspan='6' align='center'><font face='Arial, Helvetica, sans-serif' size='2'><B>"
        HSTR = HSTR & "<font color='black'>Accessory</font></B></font>"
        HSTR = HSTR & "</td>"
        HSTR = HSTR & "</tr>"
        HSTR = HSTR & "<tr bgcolor='#DDDDDD'>"
        HSTR = HSTR & "<td width='5%' align='left'>"
        HSTR = HSTR & "<font color='gray' face='Arial, Helvetica, sans-serif' size='1'><b>***</b></font></td>"
        HSTR = HSTR & "<td width='20%'><font color='gray' face='Arial, Helvetica, sans-serif' size='1'>"
        HSTR = HSTR & "<b>Configuration File</b></font></td>"
        HSTR = HSTR & "<td width='30%' colspan=5><font color='gray' face='Arial, Helvetica, sans-serif' size='1'>"
        HSTR = HSTR & "<b><a href='http://b2b.advantech-nl.nl/cbom/CFiles/'></a></b></font></td>"
        HSTR = HSTR & "</tr><tr bgcolor='#33CCCC'>"
        HSTR = HSTR & "<td width='90%' align='middle' colspan='6'>"
        HSTR = HSTR & "<textarea width='100%' name='Notes' rows='5' cols='60' ID='Textarea1'> </textarea>"
        HSTR = HSTR & "</td>"
        HSTR = HSTR & "</tr>"
        HSTR = HSTR & "</TABLE>"
        HSTR = HSTR & "</TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "</TABLE>"
        HSTR = HSTR & "</TD></TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD></TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD>&nbsp;</TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD><TABLE width='100%' border='1' cellspacing='0' cellpadding='0' ID='Table6'>"
        HSTR = HSTR & "<TR>"
        HSTR = HSTR & "<TD width='211'>&nbsp;<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>ASSEMBLER:</B></FONT></TD>"
        HSTR = HSTR & "<TD width='203'>&nbsp;<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'><B>QC#1:</B></FONT></TD>"
        HSTR = HSTR & "<TD width='198'>&nbsp;<FONT face='Verdana, Arial, Helvetica, sans-serif' size='1' color='#333333'>"
        HSTR = HSTR & "<B>Checked By:</B></FONT></TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "</TABLE>"
        HSTR = HSTR & "</TD>"
        HSTR = HSTR & "</TR>"
        HSTR = HSTR & "<TR align='right'>"
        HSTR = HSTR & "<TD><FONT face='Arial, Helvetica, sans-serif' size='1' color='#333333'>"
        HSTR = HSTR & "Advantech Configuration 	&amp; QC Inspection Sheet, Rev. A02, 03-27-00</FONT>"
        HSTR = HSTR & "</TD>"
        HSTR = HSTR & "</TR>"
        Return 1
    End Function

    Public Shared Function StrPhaseOut(ByRef str_Mes As String) As Integer
        'dim str_Mes
        Dim iRet As Integer = 0
        Dim l_strSQLCmd As String = ""
        Dim dt As DataTable
        l_strSQLCmd = "select * from configuration_catalog_category where catalog_id ='" & HttpContext.Current.Session("G_CATALOG_ID") & "' and category_type='component' and parent_category_id <> 'root' and category_id not like 'S-Warranty%' and category_id not like 'option%' Order by Seq_no"
        dt = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        str_Mes = "<div name='div1' align='middle'><font color='red'>Please be informed Item "
        StrPhaseOut = False
        Dim pstatus As String = ""
        Dim i As Integer = 0
        Do While i <= dt.Rows.Count - 1
            iRet = IsPhaseOut(dt.Rows(i).Item("category_id"), "EU10", pstatus)
            If pstatus = "O" Then
                StrPhaseOut = True
                Exit Do
            End If
            i = i + 1
        Loop
        If StrPhaseOut = False Then
            str_Mes = ""
            Exit Function
        End If
        i = 0
        Do While i <= dt.Rows.Count - 1
            iRet = IsPhaseOut(dt.Rows(i).Item("category_id"), "EU10", pstatus)
            If pstatus = "O" Then
                str_Mes = str_Mes & "<b>" & dt.Rows(i).Item("category_name") & "</b>" & "&nbsp;&nbsp;"
            End If
            i = i + 1
        Loop
        StrPhaseOut = True
        str_Mes = str_Mes & " is phase out.</font></div>"
    End Function

    Public Shared Function CompanyName_Get(ByVal Company_id As String, ByRef szCompany_Name As String) As Integer
        Dim l_strSQLCmd As String = ""
        Dim l_cate As DataTable
        l_strSQLCmd = " SELECT * FROM sap_dimCOMPANY WHERE (COMPANY_ID = '" & Company_id & "')"
        l_cate = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        If l_cate.Rows.Count > 0 Then
            szCompany_Name = l_cate.Rows(0).Item("Company_Name")
            CompanyName_Get = 1
        Else
            CompanyName_Get = 0
        End If
    End Function

    Public Shared Function createExtendedWarrantyOrder(ByVal vxTranId As String, ByRef pxEWOrderNO As String) As Integer
        'Get order no
        Dim xEWOrderNo As String = ""
        Dim xEWOrderPrefix As String = ""
        Dim xEWOrderOrderNo As String = ""
        xEWOrderPrefix = "EW"

        Dim xSQL As String = ""
        Dim rsOrderMaster As DataTable
        xSQL = "select * from order_master where order_id = '" & vxTranId & "'"
        rsOrderMaster = dbUtil.dbGetDataTable("B2B", xSQL)
        If rsOrderMaster.Rows.Count > 0 Then
            xEWOrderNo = xEWOrderPrefix & Right(rsOrderMaster.Rows(0).Item("order_no"), 6)
            pxEWOrderNO = xEWOrderNo
        Else
            createExtendedWarrantyOrder = -1
            Exit Function
        End If

        'Get extended warranty
        'Dim rsExtendedWarranty As DataTable
        'xSQL = "select * from e_wr where tran_id = '" & vxTranId & "' and is_extwr='Yes'"
        'rsExtendedWarranty = dbUtil.dbGetDataTable("B2B", xSQL)
        'If rsExtendedWarranty.Rows.Count < 1 Then
        '    createExtendedWarrantyOrder = -2
        '    Exit Function
        'End If

        Dim flgExist As String = "No"
        Dim nLineNo As String = ""
        Dim xProdLine As String = ""
        Dim xPartNo As String = ""
        Dim xOrderLineType As String = ""
        Dim nQty As String = ""
        Dim dSupDueDate As String = ""
        Dim dDueDate As String = ""
        Dim dReqDate As String = ""
        Dim xProdLoc As String = ""
        Dim flgSupOrder As String = ""
        Dim nSupOrderQty As Integer = 0
        Dim mListPrice As Decimal = 0
        Dim mUnitPrice As Decimal = 0
        Dim xProdSite As String = ""
        Dim mTotalAmt As Decimal = 0
        Dim nTotalLine As Integer = 0
        Dim xLinePartial As Integer = 0

        'Dim rsTemp As DataTable
        'Dim exeFunc As Integer = 0
        Dim i As Integer = 0
        'Do While i <= rsExtendedWarranty.Rows.Count - 1
        '    nLineNo = rsExtendedWarranty.Rows(i).Item("line_no")
        '    xProdLine = "C100"
        '    xPartNo = rsExtendedWarranty.Rows(i).Item("wr_id")
        '    xOrderLineType = "Service"
        '    nQty = rsExtendedWarranty.Rows(i).Item("qty")
        '    dSupDueDate = "1970/09/10"
        '    '-----------------------'
        '    '---- 16-01-05 Emil ----'		
        '    '-----------------------'
        '    xSQL = "select due_date, required_date from order_detail where order_id = '" & vxTranId & "' and line_no=" & rsExtendedWarranty.Rows(i).Item("line_no")
        '    rsTemp = dbUtil.dbGetDataTable("B2B", xSQL)
        '    If rsTemp.Rows.Count > 0 Then
        '        dDueDate = rsTemp.Rows(0).Item("due_date")
        '        dReqDate = rsTemp.Rows(0).Item("required_date")
        '    Else
        '        dDueDate = Global_Inc.FormatDate(Date.Now)
        '        dReqDate = Global_Inc.FormatDate(Date.Now)
        '    End If

        '    xProdLoc = ""
        '    flgSupOrder = "N"
        '    nSupOrderQty = 0
        '    mListPrice = CDec(FormatNumber(rsExtendedWarranty.Rows(i).Item("wr_fee"), 2))
        '    mUnitPrice = CDec(FormatNumber(rsExtendedWarranty.Rows(i).Item("wr_fee"), 2))
        '    xProdSite = "C100"
        '    mTotalAmt = mTotalAmt + CDec(mListPrice)
        '    nTotalLine = nTotalLine + 1
        '    xLinePartial = 0
        '    exeFunc = OrderDetail_Insert(xEWOrderNo, nLineNo, xProdSite, xPartNo, xOrderLineType, nQty, mListPrice, mUnitPrice, dDueDate, xProdSite, xProdLoc, dReqDate, flgSupOrder, nSupOrderQty, dSupDueDate, xLinePartial)
        '    flgExist = "Yes"
        '    i = i + 1
        'Loop


        If flgExist = "Yes" Then
            xSQL = "insert into order_master " & _
               "select " & _
               "'" & xEWOrderNo & "'," & _
               "'" & xEWOrderNo & "'," & _
               "'Warranty'," & _
               "'" & xEWOrderNo & "'," & _
               "soldto_id," & _
               "shipto_id," & _
               "billto_id," & _
               "sales_id," & _
               "order_date," & _
               "payment_type," & _
               "attention," & _
               "partial_flag," & _
               "combine_order_flag," & _
               "early_ship_flag," & _
               "freight," & _
               "insurance," & _
               "remark," & _
               "product_site," & _
               "due_date," & _
               "required_date," & _
               "shipment_term," & _
               "ship_via," & _
               "currency," & _
               "order_note," & _
               "order_status," & _
               mTotalAmt & "," & _
               nTotalLine & "," & _
               "last_updated," & _
               "created_date," & _
               "created_by," & _
               "customer_attention," & _
               "'N' " & _
               "from  order_master where order_id = '" & vxTranId & "'"
            'HttpContext.Current.Response.Write "<br>" & xSql & "<br>"
            Dim sqlConn As System.Data.SqlClient.SqlConnection = Nothing
            dbUtil.dbExecuteNoQuery("B2B", xSQL)
            sqlConn.Close()
            createExtendedWarrantyOrder = 1
        Else
            createExtendedWarrantyOrder = 0
        End If
    End Function

    Public Shared Function Cart_Destroy(ByVal strCart_Id As String) As Integer
        Dim l_adoRs As String = ""
        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = "delete from cart_master where cart_id = '" & strCart_Id & "'"
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        l_strSQLCmd = "delete from cart_detail where cart_id = '" & strCart_Id & "'"
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        Cart_Destroy = 1
        'sqlConn.Close()
    End Function

    Public Shared Function Logistics_Destroy(ByVal strLogistics_Id As String) As Integer
        Dim l_adoRs As String = ""
        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = "delete from logistics_master where logistics_id = '" & strLogistics_Id & "'"
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        l_strSQLCmd = "delete from logistics_detail where logistics_id = '" & strLogistics_Id & "'"
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        'sqlConn.Close()
        Logistics_Destroy = 1
    End Function

    Public Shared Function Configuration_Destroy(ByVal G_CATALOG_ID As String) As Integer
        REM == Get Category Info ==
        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = " Delete FROM CONFIGURATION_CATALOG_CATEGORY WHERE (CATALOG_ID = '" & G_CATALOG_ID & "')"
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        'sqlConn.Close()
        Configuration_Destroy = 1
    End Function

    Public Shared Function ConfigurationPage_Get(ByVal FuncID As Integer, ByVal g_CATALOG_ID As String, _
    ByVal CATALOGCFG_SEQ As Integer, ByRef ConfigurationHTML As String) As Integer
        Dim BTOCount = 100
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim intSpan As Integer, iRtn As Integer
        Dim l_strSQLCmd As String = ""

        If CATALOGCFG_SEQ = 99 Then
            l_strSQLCmd = " SELECT CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,Category_desc,Category_price,Category_qty,parentseqno FROM CONFIGURATION_CATALOG_CATEGORY WHERE (PARENT_CATEGORY_ID = 'ROOT')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'"
            'Dim l_adoRs As SqlClient.SqlDataReader = dbUtil.dbGetDataReader("B2B", l_strSQLCmd)
        Else
            l_strSQLCmd = " SELECT CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,Category_desc,Category_price,Category_qty,parentseqno FROM CONFIGURATION_CATALOG_CATEGORY WHERE (PARENT_CATEGORY_ID = 'ROOT')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & CATALOGCFG_SEQ
        End If
        Dim l_adoRs As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        'ConfigurationHTML = l_strSQLCmd
        Dim lf = Chr(13) & Chr(10)
        Dim CurrSign As String = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN")
        If Not IsNothing(HttpContext.Current.Session("isQuote_Currency")) Then
            Dim DT As DataTable = dbUtil.dbGetDataTable("B2B", Op_Quotation.GET_Quotation_Master_by_ID(HttpContext.Current.Session("isQuote_Currency")))
            If DT.Rows.Count > 0 Then
                CurrSign = DT.Rows(0).Item("currency_sign")

            End If
        End If
        If CurrSign.ToUpper = "US$" Then
            CurrSign = "$"
        End If
        For Each r As DataRow In l_adoRs.Rows

            ConfigurationHTML = ConfigurationHTML & "<span class='List_Corp'>" & lf

            ConfigurationHTML = ConfigurationHTML & "<table cellSpacing='0' cellPadding='0' width='100%' align='center' border='0'>" & lf
            ConfigurationHTML = ConfigurationHTML & "	<tr class='AppletBlank'>" & lf
            ConfigurationHTML = ConfigurationHTML & "		<td class='AppletTitle' vAlign='top' width='8'><img alt src='../images/Spacer.gif' width='8' height='10'></td>" & lf
            ConfigurationHTML = ConfigurationHTML & "		<td class='AppletTitle' noWrap>Configuration Page</td>" & lf
            ConfigurationHTML = ConfigurationHTML & "		<td class='AppletTitle' vAlign='top' align='right' width='22'><img alt src='../images/aplt_folder_r.gif' width='22' height='18'></td>" & lf
            ConfigurationHTML = ConfigurationHTML & "		<td class='AppletBlank' align='right' width='100%'>&nbsp;&nbsp;&nbsp;&nbsp;</td>" & lf
            ConfigurationHTML = ConfigurationHTML & "	</tr>" & lf
            ConfigurationHTML = ConfigurationHTML & "</table>" & lf
            ConfigurationHTML = ConfigurationHTML & "<table class='AppletStyle1' valign='top' width='100%' cellpadding='0' cellspacing='0' border='0'>" & lf
            ConfigurationHTML = ConfigurationHTML & "	<tr><td class='AppletButtons'><img src='../images/spacer.gif' width='2' height='2'></td></tr>" & lf
            ConfigurationHTML = ConfigurationHTML & "</table>" & lf
            ConfigurationHTML = ConfigurationHTML & "</span>" & lf

            ConfigurationHTML = ConfigurationHTML & "<span class='List_Corp'>" & lf
            ConfigurationHTML = ConfigurationHTML & "<table width='100%' cellspacing='0' cellpadding='0' border='0' align='center'>" & lf
            ConfigurationHTML = ConfigurationHTML & "	<tr><td width='100%' class='AppletButtons' align='right'><img src='../images/spacer.gif' height='3'></td></tr>" & lf
            ConfigurationHTML = ConfigurationHTML & "</table>" & lf

            ConfigurationHTML = ConfigurationHTML & "<table width='100%' cellpadding='0' cellspacing='1' border='0' valign='top' bgcolor='#cccccc'>" & lf
            ConfigurationHTML = ConfigurationHTML & "	<tr valign='top'><td width='100%'>" & lf
            ConfigurationHTML = ConfigurationHTML & "		<table width='100%' cellpadding='2' cellspacing='1' border='0' valign='top'>" & lf
            ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>" & lf
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center'>#</td>" & lf

            Select Case FuncID
                Case 2, 3
                    intSpan = 4
                Case Else
                    intSpan = 5
            End Select

            ConfigurationHTML = ConfigurationHTML & "				<td align='Center' width='85%' colspan =4>BTO DESCRIPTION</td>" & lf
            REM == Add BTO Master Qty For Update ==
            If Global_Inc.C_ShowRoHS = True Then
                ConfigurationHTML = ConfigurationHTML & "				<td align='Center' colspan=3>Quantity</td>" & lf
            Else
                ConfigurationHTML = ConfigurationHTML & "				<td align='Center' >Quantity</td>" & lf
            End If
            If FuncID = 2 Or FuncID = 3 Then
                ConfigurationHTML = ConfigurationHTML & "			<td align='Center'>Expected Shipping Date</td>" & lf
                ConfigurationHTML = ConfigurationHTML & "			<td align='Center'>Required Date</td>" & lf
            End If

            ConfigurationHTML = ConfigurationHTML & "				<td align='Center'>Unit Price</td>" & lf
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center'>SubTotal</td>" & lf
            ConfigurationHTML = ConfigurationHTML & "			</tr>" & lf
            ConfigurationHTML = ConfigurationHTML & "			<tr bgcolor='#FFFFFF'>" & lf
            If FuncID = 1 Then
                ConfigurationHTML = ConfigurationHTML & "		" & lf
                ConfigurationHTML = ConfigurationHTML & "		<Input type='hidden' name='Sub_Category_id' value='" & r.Item("Category_Id") & "'> " & lf
                ConfigurationHTML = ConfigurationHTML & "		<Input type='hidden' name='Sub_CATALOGCFG_SEQ' value=" & r.Item("CATALOGCFG_SEQ") & "> " & lf
                'ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center'><Input type='Submit' name='DelConfiguration' value='DEL'></td>"
                ''strHTML = ""
                ' ''---- 2005-07-15 Emil Revise for New Cart
                ''If InStr(Request.ServerVariables("PATH_INFO"), "/cart_list.asp") <= 0 And InStr(Request.ServerVariables("PATH_INFO"), "/cart_list_sap.asp") <= 0 Then
                ''    tmp = AddButton(strHTML, "<font color=red>Del</font>", "ON", "this.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.submit();")
                ''Else
                ''    '---- 2005-07-15 Emil Revise for New Cart
                ''    tmp = AddButton(strHTML, "<font color=red>Del</font>", "ON", "this.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.submit();", "FORM_SMALL_STD")
                ''End If

                ' ''tmp = AddButton (strHTML, "<font color=red>Del</font>", "ON" , "DelConfigForm.submit();")
                Dim strHTML = "<input type='button' value='Del' name='del' onclick='Del()'>"
                ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center'>" & strHTML & "</td>" & lf
                ' strHTML = ""
                ConfigurationHTML = ConfigurationHTML & "		 " & lf
            Else
                REM == Add for FuncID -> 2 ==
                ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center'>" & "&nbsp;&nbsp;" & "</td>" & lf
            End If
            ConfigurationHTML = ConfigurationHTML & "				<td class='Row' align='center' colspan =4>" & r.Item("Category_Name") & " X" & r.Item("Category_qty") & "</td>" & lf

            If FuncID = 1 Then
                REM == Add BTO Master Qty For Update ==
                If Global_Inc.C_ShowRoHS = True Then
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center' colspan =3>" & "<Input type='text' size=2 name='ConfigQty" & r.Item("CATALOGCFG_SEQ") & r.Item("Category_Id") & "' style='text-align:right;width=30' value="
                Else
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & "<Input type='text' size=2 name='ConfigQty" & r.Item("CATALOGCFG_SEQ") & r.Item("Category_Id") & "' style='text-align:right;width=30' value="
                End If
                ConfigurationHTML = ConfigurationHTML & r.Item("Category_qty") & " onchange='return ConfigQty_onchange(""" & r.Item("Category_qty") & """,this)'></td>" & lf
                'ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & "<Input type='text' size=2 name='ConfigQty" & l_adoRs("CATALOGCFG_SEQ") & l_adoRs("Category_Id") & "' style='text-align:right;width=30' value="
                'ConfigurationHTML = ConfigurationHTML & l_adoRs("Category_qty") & " ' runat='server' id='confige_qty' OnTextChanged='confige_qty_TextChanged' AutoPostBack='True'></td>" & lf

            Else
                ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & r.Item("Category_qty") & "</td>" & lf
            End If

            If FuncID = 2 Or FuncID = 3 Then
            End If
            Dim PszPrice As Decimal = 0, StrPszPrice As String = "", StrSubTotal As String = ""

            iRtn = ConfigurationTotalPrice_Get(r.Item("parentseqno"), g_CATALOG_ID, r.Item("CATALOGCFG_SEQ"), r.Item("Category_Id"), 0, PszPrice, "Config")
            ' exeFunc = GetSubTotalAmt4Config(g_CATALOG_ID, l_adoRs("CATALOGCFG_SEQ"), PszPrice)
            If (iRtn = 0) Or (PszPrice < 0) Then
                StrPszPrice = "TBD"
                'StrSubTotal = "TBD"
            Else
                StrSubTotal = FormatNumber(CDbl(PszPrice) * CInt(r.Item("Category_qty")), 2)
                StrPszPrice = CStr(FormatNumber(PszPrice, 2))
            End If
            'PszPrice = SubPszPrice / l_adoRs("Category_qty")

            'Dim PszPrice As Decimal = 0, SubPszPrice As Decimal = 0

            ConfigurationHTML = ConfigurationHTML & "				<td class='Row' align='Center'>" & CurrSign & StrPszPrice & "</td>"
            ConfigurationHTML = ConfigurationHTML & "				<td class='Row' align='Center' >" & CurrSign & StrSubTotal & "</td>"
            ConfigurationHTML = ConfigurationHTML & "			</tr>"

            ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>"
            If FuncID = 1 Then
                'If Global_Inc.C_ShowRoHS = True Then
                ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=10>BTOS Configuration for " & r.Item("Category_Name") & "</td>"
                'Else
                'ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=8>BTOS Configuration for " & l_adoRs("Category_Name") & "</td>"
                'End If
            End If

            If FuncID = 2 Or FuncID = 3 Then
                'If Global_Inc.C_ShowRoHS = True Then
                ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=12>BTOS Configuration for " & r.Item("Category_Name") & "</td>"
                'Else
                '    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=10>BTOS Configuration for " & l_adoRs("Category_Name") & "</td>"
                'End If
            End If

            ConfigurationHTML = ConfigurationHTML & "			</tr>"

            ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>"
            If FuncID = 1 Then
                'If Global_Inc.C_ShowRoHS = True Then
                ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=10>"
                'Else
                '    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=8>"
                'End If
                ConfigurationHTML = ConfigurationHTML & "<A HREF='BTOSHistorySave_input.aspx?g_CATALOG_ID=" & HttpContext.Current.Session("G_CATALOG_ID") & "&CATALOGCFG_SEQ=" & r.Item("CATALOGCFG_SEQ") & "&Category_Id=" & r.Item("Category_Id") & "&Category_Name=" & r.Item("Category_Name") & "'>>>Save Configuration<<</A></td>"
            End If

            'If FuncID = 2 Or FuncID = 3 Then
            '    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=10>>>Save Configuration<<</td>"
            'End If

            ConfigurationHTML = ConfigurationHTML & "			</tr>"

            '<!-- Detail Page -->

            ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>"
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center' width='5%'>#</td>"
            ConfigurationHTML = ConfigurationHTML & "				<td width='20%'>Category</td>"
            ConfigurationHTML = ConfigurationHTML & "				<td width='15%'>Part No</td>"

            Select Case FuncID
                Case 1
                    ConfigurationHTML = ConfigurationHTML & "			<td width='40%' colspan=3>Description</td>"
                Case 2
                    ConfigurationHTML = ConfigurationHTML & "			<td width='35%' colspan=4>Description</td>"
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' width='15%'>Promise Date</td>"
                Case 3
                    ConfigurationHTML = ConfigurationHTML & "			<td width='40%' colspan=7>Description</td>"
            End Select

            If FuncID = 1 Or FuncID = 2 Then
                '--{2005-10-31}--Daive: show all items price to Buyer
                '-----------------------------------------------------------------------------------
                'if UCASE(HttpContext.Current.Session("USER_ROLE"))= "BUYER" then
                'ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='15%' colspan=2>Quantity</td>"
                'else	   
                'If Global_Inc.C_ShowRoHS = True Then
                'ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='5%'>RoHS</td>"
                ''End If
                'ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='5%'>Class</td>"
                'Nada RECENT
                ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='5%'>Quantity</td>"
                ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='10%'>Unit Price</td>"
                ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='10%' COLSPAN='2'>Inventory</td>"
                'end if
            End If

            ConfigurationHTML = ConfigurationHTML & "			</tr>"

            Dim Root_Category_Id As String = r.Item("Category_id")
            Dim PszHTML As String = ""
            'iRtn = ConfigurationDetail(FuncID, Root_Category_Id, l_adoRs("CATALOGCFG_SEQ"), "FIRST", "", PszHTML, "Config")
            iRtn = ConfigurationDetail(FuncID, Root_Category_Id, 1, r.Item("CATALOGCFG_SEQ"), "FIRST", "", PszHTML, "Config")
            'exf=GetPartNo(FuncID,Root_Category_Id,l_adoRs("CATALOGCFG_SEQ"),"FIRST",pno_set,pno_set_count)

            ConfigurationHTML = ConfigurationHTML & PszHTML
            PszHTML = ""

            ConfigurationHTML = ConfigurationHTML & "		</table>"
            ConfigurationHTML = ConfigurationHTML & "	</td></tr>"
            ConfigurationHTML = ConfigurationHTML & "</table>"

            ConfigurationHTML = ConfigurationHTML & "<table width='100%' cellspacing='0' cellpadding='0' border='0'  align='center'>"
            ConfigurationHTML = ConfigurationHTML & "	<tr><td class='AppletButtons' align='right'><img src='../images/spacer.gif' height='2'></td></tr>"
            ConfigurationHTML = ConfigurationHTML & "</table>"

            ConfigurationHTML = ConfigurationHTML & "</span>"

            'l_adoRs.MoveNext()
            BTOCount = BTOCount + 100
            ConfigurationHTML = ConfigurationHTML & "<BR>"
            'If Global_Inc.IsB2BOwner(HttpContext.Current.Session("user_id")) Then ConfigurationHTML = ConfigurationHTML & "<a target=""_blank"" href=""BTOS_Export2Excel.aspx"">Export2Excel</a><br/>"
            'If LCase(HttpContext.Current.Session("USER_ROLE")) = "logistics" Or LCase(HttpContext.Current.Session("USER_ROLE")) = "administrator" Then
            ConfigurationHTML = ConfigurationHTML & "<a target=""_blank"" href=""BTOS_Export2Excel.aspx"">Export2Excel</a><br/>"

        Next
        ConfigurationPage_Get = 1
    End Function

    Public Shared Function ConfigurationTotalPrice_Get(ByVal perentseqno As Integer, ByVal g_Catalog_Id As String, ByVal szCATALOGCFG_SEQ As Integer, ByVal szParent_Catalog_Id As String, ByVal szPrice As Double, ByRef PszPrice As Double, ByVal flg As String) As Integer

        PszPrice = szPrice
        Dim iRet As Integer
        Dim table As String = "", l_strSQLCmd As String = ""
        REM == Get Category Info ==
        If flg = "Quote" Then
            table = "QUOTATION_CATALOG_CATEGORY"
        ElseIf flg = "history" Then
            table = "QUOTATION_CATALOG_CATEGORY_history"
        Else
            table = "CONFIGURATION_CATALOG_CATEGORY"
        End If
        If dbUtil.dbGetDataTable("B2B", "select parentseqno from " & table & " where CATALOG_ID=" & "'" & g_Catalog_Id & _
                                            "' and category_id='" & szParent_Catalog_Id & "' and ParentRoot='1'").Rows.Count > 0 Then
            l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC,parentSeqNO FROM " & table
            l_strSQLCmd = l_strSQLCmd & " WHERE (PARENT_CATEGORY_ID = '" & szParent_Catalog_Id & "')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ
        Else

            l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC,parentSeqNO FROM " & table
            l_strSQLCmd = l_strSQLCmd & " WHERE (PARENT_CATEGORY_ID = '" & szParent_Catalog_Id & "')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " and parentseqno=" & perentseqno
        End If
        'l_adoRs_detail = g_adoConn.Execute(l_strSQLCmd)
        Dim l_adoRs_detail As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        'Do While Not l_adoRs_detail.EOF
        'HttpContext.Current.Response.Write(szParent_Catalog_Id & "<br/>")

        ' OrderUtilities.showDT(l_adoRs_detail)

        For Each r As DataRow In l_adoRs_detail.Rows
            Dim Detail_Category_Id As String = r.Item("CATEGORY_ID")


            REM == Get Component Info ==
            l_strSQLCmd = " SELECT distinct seq_no,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,isnull(CATEGORY_DESC,'') as CATEGORY_DESC,isnull(Category_price,0) as CATEGORY_Price,Category_qty,parentseqNO,last_updated_by  FROM " & table & " WHERE (PARENT_CATEGORY_ID = '" & Detail_Category_Id & "')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " and ParentSeqNo=" & r.Item("parentSeqNO").ToString

            Dim l_adoRs_detail_com As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd) 'g_adoConn.Execute(l_strSQLCmd)
            'HttpContext.Current.Response.Write("com:")

            'OrderUtilities.showDT(l_adoRs_detail_com)
            Dim Detail_Price As String = "0"
            For Each r2 As DataRow In l_adoRs_detail_com.Rows
                Dim Detail_PartNo = r2.Item("CATEGORY_Name")
                Dim Detail_Desc = Trim(r2.Item("CATEGORY_DESC"))
                'try
                Detail_Price = Trim(r2.Item("CATEGORY_Price"))
                If Detail_Price = 0 Then
                    'PszPrice = 0
                    ConfigurationTotalPrice_Get = 0
                    ' Exit Function
                End If

                PszPrice = PszPrice + Detail_Price
                ' HttpContext.Current.Response.Write(r2.Item("CATEGORY_Name") & ":" & PszPrice & "<br/>")
                iRet = ConfigurationTotalPrice_Get(r2.Item("parentseqno"), g_Catalog_Id, szCATALOGCFG_SEQ, r2.Item("CATEGORY_ID"), PszPrice, PszPrice, flg)

            Next
            l_adoRs_detail_com = Nothing
        Next

        l_adoRs_detail = Nothing
        ConfigurationTotalPrice_Get = 1
    End Function

    Public Shared Function ConfigurationTotalPrice_Get(ByVal g_Catalog_Id As String, ByVal szCATALOGCFG_SEQ As Integer, ByVal szParent_Catalog_Id As String, ByVal szPrice As Double, ByRef PszPrice As Double, ByVal flg As String) As Integer

        PszPrice = szPrice
        Dim iRet As Integer
        Dim table As String = "", l_strSQLCmd As String = ""
        REM == Get Category Info ==
        If flg = "Quote" Then
            table = "QUOTATION_CATALOG_CATEGORY"
        ElseIf flg = "history" Then
            table = "QUOTATION_CATALOG_CATEGORY_history"
        Else
            table = "CONFIGURATION_CATALOG_CATEGORY"
        End If

        l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC,parentSeqNO FROM " & table
        l_strSQLCmd = l_strSQLCmd & " WHERE (PARENT_CATEGORY_ID = '" & szParent_Catalog_Id & "')"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
        l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ

        'l_adoRs_detail = g_adoConn.Execute(l_strSQLCmd)
        Dim l_adoRs_detail As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        'Do While Not l_adoRs_detail.EOF
        'HttpContext.Current.Response.Write(szParent_Catalog_Id & "<br/>")

        ' OrderUtilities.showDT(l_adoRs_detail)

        For Each r As DataRow In l_adoRs_detail.Rows
            Dim Detail_Category_Id As String = r.Item("CATEGORY_ID")


            REM == Get Component Info ==
            l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,isnull(CATEGORY_DESC,'') as CATEGORY_DESC,isnull(Category_price,0) as CATEGORY_Price,Category_qty,parentseqNO FROM " & table & " WHERE (PARENT_CATEGORY_ID = '" & Detail_Category_Id & "')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " and ParentSeqNo=" & r.Item("parentSeqNO").ToString

            Dim l_adoRs_detail_com As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd) 'g_adoConn.Execute(l_strSQLCmd)
            'HttpContext.Current.Response.Write("com:")

            'OrderUtilities.showDT(l_adoRs_detail_com)
            Dim Detail_Price As String = "0"
            For Each r2 As DataRow In l_adoRs_detail_com.Rows
                Dim Detail_PartNo = r2.Item("CATEGORY_Name")
                Dim Detail_Desc = Trim(r2.Item("CATEGORY_DESC"))
                'try
                Detail_Price = Trim(r2.Item("CATEGORY_Price"))
                If Detail_Price = 0 Then
                    'PszPrice = 0
                    ConfigurationTotalPrice_Get = 0
                    ' Exit Function
                End If

                PszPrice = PszPrice + Detail_Price
                ' HttpContext.Current.Response.Write(r2.Item("CATEGORY_Name") & ":" & PszPrice & "<br/>")
                iRet = ConfigurationTotalPrice_Get(g_Catalog_Id, szCATALOGCFG_SEQ, r2.Item("CATEGORY_ID"), PszPrice, PszPrice, flg)

            Next
            l_adoRs_detail_com = Nothing
        Next

        l_adoRs_detail = Nothing
        ConfigurationTotalPrice_Get = 1
    End Function

    Public Shared Function ConfigurationDetail(ByVal FuncID As Integer, ByVal szParent_Catalog_Id As String, ByVal szparentseqno As Integer, _
    ByVal szCATALOGCFG_SEQ As Integer, ByVal level As String, ByVal HTMLString As String, ByRef PszHTML As String, ByVal flg As String) As Integer
        Dim lf = Chr(13) & Chr(10)
        Dim g_CATALOG_ID As String = ""
        If HttpContext.Current.Request("flg") = "history" Then
            g_CATALOG_ID = HttpContext.Current.Request("Quote_ID")
        Else
            g_CATALOG_ID = HttpContext.Current.Session("G_CATALOG_ID")
        End If

        Dim BTOCount = 1
        Dim szChildCategory_Id As String = ""
        Dim strHTML As String, szCartLine As Integer, intCost As Integer
        Dim table As String = ""
        'Dim g_adoConn As New SqlClient.SqlConnection
        If flg = "Quote" Then
            table = "QUOTATION_CATALOG_CATEGORY"
        ElseIf flg = "history" Then
            table = "QUOTATION_CATALOG_CATEGORY_history"
        Else
            table = "CONFIGURATION_CATALOG_CATEGORY"
        End If
        Dim l_strSQLCmd As String = ""
        REM == Get Category Info ==
        If dbUtil.dbGetDataTable("B2B", "select parentseqno from " & table & " where CATALOG_ID=" & "'" & g_CATALOG_ID & _
                                            "' and category_id='" & szParent_Catalog_Id & "' and ParentRoot='1'").Rows.Count > 0 Then
            l_strSQLCmd = "SELECT CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,parentseqno,CATEGORY_DESC " & _
            "  FROM " & table & _
            " WHERE (PARENT_CATEGORY_ID = '" & szParent_Catalog_Id & "'" & _
            " )  AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'" & _
            "   AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " Order by SEQ_NO"
        Else
            l_strSQLCmd = "SELECT CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,parentseqno,CATEGORY_DESC " & _
           "  FROM " & table & _
           " WHERE (PARENT_CATEGORY_ID = '" & szParent_Catalog_Id & "' and parentseqno=" & szparentseqno & _
           " )  AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'" & _
           "   AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " Order by SEQ_NO"
        End If


        Dim l_adoRs_detail As DataTable = Nothing
        For xyz As Integer = 0 To 3
            Try
                l_adoRs_detail = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
                Exit For
            Catch ex As Exception
                If xyz = 3 Then Throw ex
            End Try
        Next
        Dim CurrSign As String = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN")
        If Not IsNothing(HttpContext.Current.Session("isQuote_Currency")) Then
            Dim DT As DataTable = dbUtil.dbGetDataTable("B2B", Op_Quotation.GET_Quotation_Master_by_ID(HttpContext.Current.Session("isQuote_Currency")))
            If DT.Rows.Count > 0 Then

                CurrSign = DT.Rows(0).Item("currency_sign")

            End If
        End If
        If CurrSign.ToUpper = "US$" Then
            CurrSign = "$"
        End If
        'OrderUtilities.showDT(l_adoRs_detail)
        For Each r As DataRow In l_adoRs_detail.Rows
            Dim Detail_Category = r.Item("CATEGORY_Name")
            Dim Detail_Category_Id = r.Item("CATEGORY_ID")
            Dim Detail_CATALOGCFG_SEQ = r.Item("CATALOGCFG_SEQ")
            Dim Detail_parentseqno = r.Item("parentseqno")
            Dim Detail_CategoryType = r.Item("Category_Type")

            If level = "FIRST" Then
                HTMLString = ""
                'HTMLString = HTMLString & "<tr class='Header'>"
                'HTMLString = HTMLString & "	<td class='Row' align='Center'>&nbsp;" & "</td>"
                'If FuncID = 1 Then
                '    If flg = "Quote" Or flg = "history" Then
                '        'If Global_Inc.C_ShowRoHS = True Then
                '        HTMLString = HTMLString & "	<td class='Row' colspan=11>Sub Category for " & Detail_Category & "</td>"
                '        'Else
                '        '    HTMLString = HTMLString & "	<td class='Row' colspan=9>Sub Category for " & Detail_Category & "</td>"
                '        'End If
                '    Else
                '        'If Global_Inc.C_ShowRoHS = True Then
                '        HTMLString = HTMLString & "	<td class='Row' colspan=9>Sub Category for " & Detail_Category & "</td>"
                '        'Else
                '        'HTMLString = HTMLString & "	<td class='Row' colspan=7>Sub Category for " & Detail_Category & "</td>"
                '        'End If
                '    End If
                'End If
                'If FuncID = 2 Or FuncID = 3 Then
                '    'If Global_Inc.C_ShowRoHS = True Then
                '    HTMLString = HTMLString & "	<td class='Row' colspan=11>Sub Category for " & Detail_Category & "</td>"
                '    'Else
                '    '    HTMLString = HTMLString & "	<td class='Row' colspan=9>Sub Category for " & Detail_Category & "</td>"
                '    'End If
                'End If
                'HTMLString = HTMLString & "</tr>"
                'HttpContext.Current.Response.Write(HTMLString)
                PszHTML = PszHTML & HTMLString
            End If

            REM == Get Component Info ==	
            l_strSQLCmd = " SELECT distinct SEQ_NO,CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,parentseqno,isnull(CATEGORY_DESC,'')" & _
                "as CATEGORY_DESC,isnull(Category_price,0) as Category_price,Category_qty,last_updated_by FROM " & table & " WHERE (PARENT_CATEGORY_ID = '" & _
                Detail_Category_Id & "' and ParentSeqNo=" & Detail_parentseqno & " )"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " Order by SEQ_NO"


            Dim l_adoRs_detail_com As New DataTable
            l_adoRs_detail_com = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
            'g_adoConn.Execute(l_strSQLCmd)
            'If Not l_adoRs_detail_com.EOF Then
            If l_adoRs_detail_com.Rows.Count > 0 Then
                For icount As Integer = 0 To l_adoRs_detail_com.Rows.Count - 1
                    'jackie add this per Tc's EZ Configuration request 2006/7/11

                    Dim Detail_PartNo = l_adoRs_detail_com.Rows(icount).Item("CATEGORY_Name")

                    Dim Detail_Desc = Trim(l_adoRs_detail_com.Rows(icount).Item("CATEGORY_DESC"))
                    Dim Detail_Category_ID_COM = l_adoRs_detail_com.Rows(icount).Item("Category_ID")
                    Dim Detail_Category_SeqNumber = l_adoRs_detail_com.Rows(icount).Item("parentseqno")
                    Dim Detail_Category_CategoryType = l_adoRs_detail_com.Rows(icount).Item("Category_Type")

                    HTMLString = ""
                    HTMLString = HTMLString & "<tr bgcolor='#FFFFFF'>"
                    Dim iRet As Integer
                    If FuncID = 1 Then
                        REM == Change for Component Reconfig
                        HTMLString = HTMLString & "         " & lf
                        'HTMLString = HTMLString & "	          <Input type='hidden' name='Sub_Category_id' value='" & Detail_Category_Id & "'> " & lf
                        'HTMLString = HTMLString & "	          <Input type='hidden' name='Sub_CATALOGCFG_SEQ' value=" & Detail_CATALOGCFG_SEQ & "> " & lf
                        HTMLString = HTMLString & "	<td class='Row' valign=center>"
                        REM HTMLString = HTMLString & "               <input type='image' SRC='/images/icon_Config.gif' WIDTH='80' HEIGHT='40' BORDER='2' ALT='Config again'> "
                        iRet = PhaseOutItemCheck(Detail_PartNo) ' iRtn = 0 meam phase out
                        If iRet = 0 Then
                            HTMLString = HTMLString & "               <input type='button' value='Re-Config' onclick=" & Chr(34) & "ReConfigure('" & Detail_Category_Id & "')" & Chr(34) & " > " '<input type='image' SRC='/images/icon_Config.gif' WIDTH='80' HEIGHT='40' BORDER='2' ALT='Config again'> "
                        End If

                        iRet = HasChildComponent_CBOM(Detail_Category_ID_COM, szChildCategory_Id)
                        If iRet = 1 Then
                            'HTMLString = HTMLString & "	          <Input type='submit' name='Reconfig' value=" & "CHANGE" & "> "
                            strHTML = "" & lf
                            REM == Marked 04152004 ==
                            REM tmp = AddButton (strHTML, "<font color=Blue>Change</font>", "ON" , "this.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.submit();")

                            HTMLString = HTMLString & strHTML & lf
                            strHTML = ""
                        Else
                            REM HTMLString = HTMLString & "	          <A href='/btos/ReConfigurator_Component.asp'>" & "<Input type='button' name='Reconfig_Compoment' value=" & "CHANGE_COM" & "> " & "</a>"
                            'strHTML = ""
                            'tmp=AddButton (strHTML, "Pick Product", "ON" , "PickRe_Configuration('Knader','Gary')")

                            'HTMLString = HTMLString & "<input type=button name=Kaner onclick=""PickRe_Configuration('" & Detail_CATALOGCFG_SEQ & "'," & "'" & Detail_Category_Id & "'," & "'" & Detail_Category_ID_COM & "' );"" value='CHANGE'>"
                            strHTML = ""
                            'tmp = AddButton (strHTML, "<font color=Blue>Change</font>", "ON" , "alert(escape('" & Detail_Category_Id & "'));")
                            REM == Marked 04152004 ==
                            REM tmp = AddButton (strHTML, "<font color=Blue>Change</font>", "ON" , "PickRe_Configuration('" & Detail_CATALOGCFG_SEQ & "'," & "'" & Detail_Category_Id & "'," & "'" & Detail_Category_ID_COM & "' );")
                            HTMLString = HTMLString & strHTML
                            strHTML = ""
                            'HTMLString = HTMLString & strHTML
                        End If
                        HTMLString = HTMLString & "	</td>"
                        HTMLString = HTMLString & "	    "
                    Else
                        ''REM == Retrive Line number ==
                        ''iRtn = ConfigurationLineNo_Get(g_CATALOG_ID, Detail_CATALOGCFG_SEQ, Detail_PartNo, LineNo)
                        ''HTMLString = HTMLString & "	<td class='Row' valign=center>&nbsp;" & LineNo & "</td>"
                    End If
                    HTMLString = HTMLString & "	<td class='Row'>" & Detail_Category & "</td>"
                    If FuncID = 1 Then
                        ''REM == Check Phase Out product ==
                        iRet = PhaseOutItemCheck(Detail_PartNo) ' iRtn = 0 meam phase out
                        ' ''---- 261103e Add for VISAM case ----'    
                        If iRet = 1 Then 'Or Detail_PartNo = "Assembly Fee Visam" Then
                            HTMLString = HTMLString & "	<td class='Row'>" & Detail_PartNo & "</td>"
                        Else
                            HTMLString = HTMLString & "	<td class='Row'>" & "<Font color ='Red'><B>" & Detail_PartNo & "<br>(Phase Out)" & "</B></Font>" & "</td>"
                            HttpContext.Current.Session("HISTORY_PHASE_OUT") = 0
                        End If
                        ''REM == End Check ==
                    Else
                        HTMLString = HTMLString & "	<td class='Row'>" & Detail_PartNo & "</td>"
                    End If

                    'HTMLString = HTMLString & "	<td class='Row'>" & Detail_PartNo   & "</td>"
                    Select Case FuncID
                        Case 1
                            'Dim SlowMovingSDT As DataTable = dbUtil.dbGetDataTable("B2B", "select top 1 IsNull(ATTRIBUTEA,'N') as SlowMoving from product where part_no='" & l_adoRs_detail_com.Rows(icount).Item("CATEGORY_ID") & "'")
                            'If SlowMovingSDT.Rows.Count > 0 Then
                            If flg = "Quote" Or flg = "history" Then
                                'If SlowMovingSDT.Rows(0).Item("SlowMoving").Trim().ToUpper() = "X" Then
                                '    HTMLString = HTMLString & "	<td class='Row' colspan=5>" & Detail_Desc & "<br><FONT COLOR=#FF00OO>Last buy with special price please contact our Sales</FONT></td>"
                                'Else
                                HTMLString = HTMLString & "	<td class='Row' colspan=5>" & Detail_Desc & "</td>"
                                'End If
                            Else
                                'If SlowMovingSDT.Rows(0).Item("SlowMoving").Trim().ToUpper() = "X" Then
                                '    HTMLString = HTMLString & "	<td class='Row' colspan=3>" & Detail_Desc & "<br><FONT COLOR=#FF00OO>Last buy with special price please contact our Sales</FONT></td>"
                                'Else
                                HTMLString = HTMLString & "	<td class='Row' colspan=3>" & Detail_Desc & "</td>"
                                'End If
                            End If

                            'End If
                        Case 2
                            ''    REM == Get Due Date From Logistics Table ==			        
                            ''    iRtn = LogisticsDueDate_Get(HttpContext.Current.Session("G_CATALOG_ID"), l_adoRs_detail_com("CATEGORY_ID"), PszDueDate)
                            ''    REM == End Get ==
                            ''    HTMLString = HTMLString & "	<td class='Row' colspan=4>" & Detail_Desc & "</td>"
                            ''    HTMLString = HTMLString & "	<td class='Row'>" & PszDueDate & "</td>"
                            ''Case 3
                            ''    HTMLString = HTMLString & "	<td class='Row' colspan=7>" & Detail_Desc & "</td>"
                    End Select

                    If (FuncID = 1) Then
                        If flg <> "Quote" Then
                            iRet = CartLineFromBTOS_Get(HttpContext.Current.Session("G_CATALOG_ID"), l_adoRs_detail_com.Rows(icount).Item("CATEGORY_ID"), szCartLine)
                        End If
                        'If Global_Inc.C_ShowRoHS = True Then
                        '--RoHS
                        '--Class
                        Dim RoHSDT As DataTable = dbUtil.dbGetDataTable("B2B", "select top 1 case RoHS_Flag when 1 then 'y' else 'n' end as RoHS,'' as Class from sap_product where part_no='" & l_adoRs_detail_com.Rows(icount).Item("CATEGORY_ID") & "'")
                        'NADA RECENT
                        'If RoHSDT.Rows.Count > 0 Then
                        '    If RoHSDT.Rows(0).Item("RoHS").Trim().ToUpper() = "Y" Then
                        '        HTMLString = HTMLString & "	<td class='Row' align='center'><img alt='RoHS' src='../Images/rohs.jpg'/></td>"
                        '    Else
                        '        HTMLString = HTMLString & "	<td class='Row' align='center'>&nbsp;</td>"
                        '    End If
                        '    If RoHSDT.Rows(0).Item("Class").Trim().ToUpper() = "A" Or RoHSDT.Rows(0).Item("Class").Trim().ToUpper() = "B" Then
                        '        HTMLString = HTMLString & "	<td class='Row' align='center'><img alt='Class' src='../Images/Hot-Orange.gif'/></td>"
                        '    Else
                        '        HTMLString = HTMLString & "	<td class='Row' align='center'>&nbsp;</td>"
                        '    End If
                        'Else
                        '    HTMLString = HTMLString & "	<td class='Row' align='center'>&nbsp;</td>"
                        '    HTMLString = HTMLString & "	<td class='Row' align='center'>&nbsp;</td>"
                        'End If
                        'End If
                        If Util.IsInternalUser2() Or Util.IsAEUIT() Then
                            HTMLString = HTMLString & "	<td class='Row' align='center'>" & l_adoRs_detail_com.Rows(0).Item("CATEGORY_QTY") & "</td>"
                            '--{2005-09-23}--Daive: Avoid user change Extended Warranty Fee
                            '-------------------------------------------------------------------------
                            'If InStr(UCase(Trim(l_adoRs_detail_com.Rows(0).Item("CATEGORY_ID"))), "S-WARRANTY") <> 0 Then
                            If InStr(UCase(Trim(l_adoRs_detail_com.Rows(icount).Item("CATEGORY_ID"))), "AGS-EW-") <> 0 Then
                                '---- Emil 2005-10-13 if Lcase(HttpContext.Current.Session("USER_ID"))="daive.wang@advantech.com.cn" or Lcase(HttpContext.Current.Session("USER_ID"))="tc.chen@advantech.com.tw" or Lcase(HttpContext.Current.Session("USER_ID"))="emil.hsu@advantech.com.tw" or Lcase(HttpContext.Current.Session("USER_ID"))="emil.hsu@advantech.com.de" then	
                                HTMLString = HTMLString & "	<td class='Row' align='center'>" & FormatNumber(l_adoRs_detail_com.Rows(icount).Item("CATEGORY_Price"), 2) & "</td>"
                                '---- Emil 2005-10-13end if
                            Else
                                HTMLString = HTMLString & "	<td class='Row' align='center'>" & "<Input type='text' name='LinePrice" & l_adoRs_detail_com.Rows(icount).Item("CATALOGCFG_SEQ") & l_adoRs_detail_com.Rows(icount).Item("CATEGORY_ID") & "' style='text-align=right' size=3 value="
                                'z = Cost_MFG_Get(l_adoRs_detail_com("CATEGORY_ID"), intCost)
                                'HttpContext.Current.Response.Write ("<BR>" & "intCost:" & intCost)
                                'Response.end

                                HTMLString = HTMLString & FormatNumber(l_adoRs_detail_com.Rows(icount).Item("CATEGORY_Price"), 2) & " readonly='true' onchange='return LinePrice_onchange(""" & szCartLine & """,""" & intCost & """,this)'></td>"
                            End If
                        Else

                            '--{2005-10-31}--Daive: Show price to buyer
                            '-------------------------------------------------------------------------
                            'HTMLString = HTMLString & "	<td class='Row' align='center' colspan=2>" & l_adoRs_detail_com("CATEGORY_QTY") & "</td>"
                            HTMLString = HTMLString & "	<td class='Row' align='center'>" & l_adoRs_detail_com.Rows(icount).Item("CATEGORY_QTY") & "</td>"
                            REM == Don't Show Price Field ==
                            HTMLString = HTMLString & "	<td class='Row' align='right'>" & CurrSign & FormatNumber(l_adoRs_detail_com.Rows(icount).Item("CATEGORY_Price"), 2) & "</td>"

                        End If
                        HTMLString = HTMLString & "	<td class='Row' align='center' colspan='2'><img src='/Images/loading2.gif' height='20' id='imgTEST' onload='GetATPP(""" & l_adoRs_detail_com.Rows(icount).Item("CATEGORY_ID") & """,this)'></td>"

                    End If
                    If (FuncID = 2) Then
                        'REM == Mask Price ==
                        'HTMLString = HTMLString & "	<td class='Row' align='center'>" & l_adoRs_detail_com("CATEGORY_QTY") & "</td>"
                        'HTMLString = HTMLString & "	<td class='Row' align='center'>" & FormatNumber(l_adoRs_detail_com("CATEGORY_Price"), 2) & "</td>"
                    End If

                    HTMLString = HTMLString & "</tr>"
                    PszHTML = PszHTML & HTMLString
                    iRet = ConfigurationDetail(FuncID, l_adoRs_detail_com.Rows(0).Item("CATEGORY_ID"), Detail_Category_SeqNumber, szCATALOGCFG_SEQ, "SECOND", HTMLString, PszHTML, flg)

                Next
            End If
            l_adoRs_detail_com = Nothing


            'l_adoRs_detail.MoveNext()
        Next
        l_adoRs_detail = Nothing
        ConfigurationDetail = 1
        ' g_adoConn.Close()
        'g_adoConn.Dispose()
    End Function

    Public Shared Function HasChildComponent_CBOM(ByVal CATEGORY_ID As String, ByRef szCategory_Id As String) As Integer

        Dim l_strSQLCmd As String = ""
        l_strSQLCmd = " SELECT Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC FROM CBOM_CATALOG_CATEGORY WHERE (PARENT_CATEGORY_ID = '" & CATEGORY_ID & "')"
        'HttpContext.Current.Response.Write l_strSQLCmd
        'Response.End
        'l_cate = g_adoConn.Execute(l_strSQLCmd)
        Dim l_cate As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        'If Not l_cate.eof Then
        If l_cate.Rows.Count > 0 Then
            szCategory_Id = l_cate.Rows(0).Item("CATEGORY_ID")
            HasChildComponent_CBOM = 1
        Else
            szCategory_Id = "N/A"
            HasChildComponent_CBOM = 0
        End If
    End Function

    Public Shared Function CartLineFromBTOS_Get(ByVal g_Catalog_Id As String, ByVal szCATEGORY_ID As String, ByRef szCartLine As Integer) As Integer

        CartLineFromBTOS_Get = 1
        Dim l_strSQLCmd As String = "select CART_ID,CATEGORY_ID,CONFIG_ID,LINE_NO from CART_DETAIL_BTOS where CATEGORY_ID=" & "'" & szCATEGORY_ID & "'" & " and CONFIG_ID=" & "'" & g_Catalog_Id & "'"
        'HttpContext.Current.Response.Write ("<BR>" & SQLString & "<BR>")
        'rs = g_adoConn.Execute(SQLString)
        Dim rs As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        'If Not rs.EOF Then
        If rs.Rows.Count > 0 Then
            szCartLine = rs.Rows(0).Item("LINE_NO")
            CartLineFromBTOS_Get = 1
        Else
            CartLineFromBTOS_Get = 0
        End If
        rs = Nothing
    End Function

    Public Shared Function TransformConfigurationToCart(ByVal g_Catalog_Id, ByVal flg)

        'Dim PszPrice As Decimal = 0
        'REM == Clear Existed BTOS Items from Cart ==
        'Dim l_strSQLCmd As String = " SELECT cart_id FROM Cart_detail_btos WHERE (Config_id = '" & g_Catalog_Id & "')"

        ''l_adoRs_detail = g_adoConn.Execute(l_strSQLCmd)
        'Dim l_adoRs_detail As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        ''If Not l_adoRs_detail.EOF Then
        'If l_adoRs_detail.Rows.Count > 0 Then
        '    Dim btos_cart_id As String = l_adoRs_detail.Rows(0).Item("cart_id")
        '    REM == Delete cart_detail_btos ==
        '    l_strSQLCmd = " delete FROM Cart_detail_btos WHERE (Config_id = '" & g_Catalog_Id & "')"
        '    'l_adoRs_detail = g_adoConn.Execute(l_strSQLCmd)
        '    'Dim sqlConn As SqlClient.SqlConnection = Nothing
        '    dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        '    REM == Delete cart_detail ==
        '    l_strSQLCmd = "delete FROM cart_detail WHERE (Cart_id = '" & btos_cart_id & "') "
        '    'l_adoRs_detail = g_adoConn.Execute(l_strSQLCmd)
        '    dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        '    'sqlConn.Close()
        'End If
        'REM == End Clear ==
        'Dim table As String = ""
        'If flg = "quote" Then
        '    table = "QUOTATION_CATALOG_CATEGORY"
        'Else
        '    table = "CONFIGURATION_CATALOG_CATEGORY"
        'End If

        'l_strSQLCmd = " SELECT isnull(CATALOGCFG_SEQ,0) as CATALOGCFG_SEQ,isnull(CATEGORY_Id,'') as CATEGORY_Id,isnull(CATEGORY_Name,'') as CATEGORY_Name,isnull(Category_qty,1) as Category_qty,isnull(CATEGORY_Price,0) as CATEGORY_Price,isnull(parent_category_id,'root') as parent_category_id FROM " & table & " WHERE (PARENT_CATEGORY_ID = '" & "Root" & "')"
        'l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'" & " order by SEQ_NO"

        ''HttpContext.Current.Response.Write "&sql" & l_strSQLCmd
        ''response.end


        'HttpContext.Current.Session("nBtos_LineNo") = 100
        'HttpContext.Current.Session("nBtos_LineNo_Visam") = 900
        'HttpContext.Current.Session("nBtos_LineNo_General") = 100

        'Dim NextBtos_LineNo = HttpContext.Current.Session("nBtos_LineNo")
        'Dim NextBtos_LineNo_Visam = HttpContext.Current.Session("nBtos_LineNo_Visam")
        'Dim NextBtos_LineNo_General = HttpContext.Current.Session("nBtos_LineNo_General")

        'l_adoRs_detail = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)  'g_adoConn.Execute(l_strSQLCmd)

        'Dim iRet As Integer = CartMaster_insert(HttpContext.Current.Session("CART_ID"), HttpContext.Current.Session("COMPANY_CURRENCY"), "N", 0)
        ''showDT(l_adoRs_detail) : HttpContext.Current.Response.End()
        'If flg = "NEWQUOTE" Then
        '    Dim STR As String = String.Format("delete from quotation_detail where quote_id='{0}'", HttpContext.Current.Session("UID"))
        '    dbUtil.dbExecuteNoQuery("B2B", STR)
        'End If
        'For Each r As DataRow In l_adoRs_detail.Rows
        '    Dim szCATALOGCFG_SEQ = r.Item("CATALOGCFG_SEQ")
        '    '' this is for add the -bto item
        '    If flg = "NEWQUOTE" Then
        '        Dim ITP As Decimal = 0
        '        Op_Quotation.ADD_Quote_Line(HttpContext.Current.Session("UID"), HttpContext.Current.Session("nBtos_LineNo"), r.Item("CATEGORY_Name"), Trim(r.Item("Category_qty")), Trim(r.Item("CATEGORY_Price")), Trim(r.Item("CATEGORY_Price")), Trim(r.Item("parent_category_id")), 0, "", 0, "", ITP, Trim(r.Item("CATEGORY_Price")), 0, ITP)

        '    Else
        '        iRet = CartDetail_insert(r.Item("CATALOGCFG_SEQ"), g_Catalog_Id, r.Item("CATEGORY_Id"), HttpContext.Current.Session("CART_ID"), HttpContext.Current.Session("COMPANY_CURRENCY"), r.Item("CATEGORY_Name"), Trim(r.Item("Category_qty")), Trim(r.Item("CATEGORY_Price")), Trim(r.Item("CATEGORY_Price")))
        '    End If

        '    'end if
        '    'Function CartDetail_insert(ByVal szCATALOGCFG_SEQ,ByVal g_Catalog_Id, ByVal Detail_Category_Id, ByVal CartId, ByVal CountyCurrency, ByVal PartNo, ByVal CategoryQty, ByVal CategoryListPrice, ByVal CategoryUnitPrice)
        '    '----------------end-------------------------------------------------------------------

        '    'iRet = Transform_Detail(g_Catalog_Id, szCATALOGCFG_SEQ, l_adoRs_detail("Category_ID"), 0, PszPrice, flg)

        '    iRet = Transform_Detail(g_Catalog_Id, szCATALOGCFG_SEQ, r.Item("Category_ID"), 1, 0, PszPrice, flg)

        'Next

        'Return 1
    End Function


    Public Shared Function CartMaster_insert(ByVal CartId As String, ByVal CountryCurrency As String, ByVal CHECKOUT_FLAG As String, ByVal TOTAL_PRICE As Double) As Integer
        'Dim g_adoConn As New SqlClient.SqlConnection
        REM == Insert to Cart table ==
        Dim l_strSQLCmd As String = "select * from Cart_Master where cart_id =" & "'" & CartId & "'"
        'rs = g_adoConn.Execute(SQLString)
        Dim rs As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        'If rs.EOF Then
        If Not rs.Rows.Count > 0 Then
            l_strSQLCmd = "insert into CART_MASTER(CART_ID,CURRENCY, CHECKOUT_FLAG,TOTAL_PRICE) values(" & "'" & CartId & "'," & "'" & CountryCurrency & "'," & "'" & "N" & "'," & "0" & ")"
            'Dim sqlConn As SqlClient.SqlConnection = Nothing
            dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
            'sqlConn.Close()
        End If
        ' g_adoConn.Close()
        'g_adoConn.Dispose()
        Return 1
    End Function

    Public Shared Function CartDetail_insert(ByVal szCATALOGCFG_SEQ As Integer, _
                                             ByVal g_Catalog_Id As String, _
                                             ByVal Detail_Category_Id As String, _
                                             ByVal CartId As String, _
                                             ByVal CountyCurrency As String, _
                                             ByVal PartNo As String, _
                                             ByVal CategoryQty As Integer, _
                                             ByVal CategoryListPrice As Double, _
                                             ByVal CategoryUnitPrice As Double) As Integer
        REM == Insert to Cart_Detail table ==
        Dim l_strSQLCmd As String = ""
        If InStr(UCase(Trim(PartNo)), "OPTION_NO_CAL") <= 0 Then
            l_strSQLCmd = "insert into CART_DETAIL(CART_ID,LINE_NO,PART_NO,QTY,LIST_PRICE,UNIT_PRICE,TYPE,UPDATE_PRICE) "
            l_strSQLCmd = l_strSQLCmd & " values(" & "'" & CartId & "'," & HttpContext.Current.Session("nBtos_LineNo") & ",'" & PartNo & "'," & CategoryQty & "," & CategoryListPrice & "," & CategoryUnitPrice & "," & "'BTOS'" & ",1)"
        ElseIf InStr(PartNo, "Assembly Fee Visam") > 0 Then
            '***** 191203e ****'
            l_strSQLCmd = "insert into CART_DETAIL(CART_ID,LINE_NO,PART_NO,QTY,LIST_PRICE,UNIT_PRICE,TYPE,UPDATE_PRICE) "
            l_strSQLCmd = l_strSQLCmd & " values(" & "'" & CartId & "'," & HttpContext.Current.Session("nBtos_LineNo") & ",'" & PartNo & "'," & CategoryQty & "," & CategoryListPrice & "," & CategoryUnitPrice & "," & "'BTOS'" & ",1)"
        Else
            l_strSQLCmd = "insert into CART_DETAIL(CART_ID,LINE_NO,PART_NO,QTY,LIST_PRICE,UNIT_PRICE,TYPE,UPDATE_PRICE) "
            l_strSQLCmd = l_strSQLCmd & " values(" & "'" & CartId & "'," & HttpContext.Current.Session("nBtos_LineNo") & ",'" & PartNo & "'," & CategoryQty & "," & CategoryListPrice & "," & CategoryUnitPrice & "," & "'BTOS'" & ",0)"
        End If


        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)

        REM == Insert to Cart_Detail_Btos table ==
        l_strSQLCmd = "insert into CART_DETAIL_BTOS(CATALOGCFG_SEQ,CART_ID,CATEGORY_ID,CONFIG_ID,LINE_NO) "
        l_strSQLCmd = l_strSQLCmd & " values(" & szCATALOGCFG_SEQ & "," & "'" & CartId & "','" & PartNo & "','" & g_Catalog_Id & "'," & HttpContext.Current.Session("nBtos_LineNo") & ")"
        'SQLString = SQLString & " values(" & szCATALOGCFG_SEQ & "," & "'" & CartId & "','" & Detail_Category_Id & "','" & g_Catalog_Id & "'," & HttpContext.Current.Session("nBtos_LineNo") & ")"    
        'rs = g_adoConn.Execute(SQLString)
        dbUtil.dbExecuteNoQuery("B2B", l_strSQLCmd)
        'sqlConn.Close()
        HttpContext.Current.Session("nBtos_LineNo") = HttpContext.Current.Session("nBtos_LineNo") + 1
        Return 1
    End Function

    Public Shared Function Transform_Detail(ByVal g_Catalog_Id As String, ByVal szCATALOGCFG_SEQ As Integer, _
    ByVal szParent_Catalog_Id As String, ByVal szParentSeqNo As Integer, ByVal szPrice As Double, ByRef PszPrice As Double, _
        ByVal flg As String) As Integer
        '    Dim table As String = ""
        '    REM == Get Category Info ==
        '    If flg = "quote" Then
        '        table = "QUOTATION_CATALOG_CATEGORY"
        '    Else
        '        table = "CONFIGURATION_CATALOG_CATEGORY"
        '    End If
        '    Dim l_strSQLCmd As String = ""

        '    If dbUtil.dbGetDataTable("B2B", "select parentseqno from " & table & " where CATALOG_ID=" & "'" & g_Catalog_Id & _
        '                                    "' and category_id='" & szParent_Catalog_Id & "' and ParentRoot='1'").Rows.Count > 0 Then
        '        l_strSQLCmd = "SELECT CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,parentseqno,isnull(CATEGORY_DESC,'') as CATEGORY_DESC " & _
        '        "  FROM " & table & _
        '        " WHERE (PARENT_CATEGORY_ID = '" & szParent_Catalog_Id & "'" & _
        '        " )  AND CATALOG_ID=" & "'" & g_Catalog_Id & "'" & _
        '        "   AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " Order by SEQ_NO"

        '    Else
        '        l_strSQLCmd = "SELECT CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,parentseqno,CATEGORY_DESC " & _
        '       "  FROM " & table & _
        '       " WHERE (PARENT_CATEGORY_ID = '" & szParent_Catalog_Id & "' and parentseqno=" & szParentSeqNo & _
        '       " )  AND CATALOG_ID=" & "'" & g_Catalog_Id & "'" & _
        '       "   AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " Order by SEQ_NO"
        '        'HttpContext.Current.Response.Write(l_strSQLCmd)
        '        'HttpContext.Current.Response.Write("<br>")
        '    End If
        '    Dim l_adoRs_detail As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        '    'HttpContext.Current.Response.Write("AAA")
        '    'showDT(l_adoRs_detail)

        '    For Each r As DataRow In l_adoRs_detail.Rows
        '        Dim Detail_Category_Id = r.Item("CATEGORY_ID")
        '        Dim Detail_ParentSeqNo = r.Item("ParentSeqNo")

        '        REM == Get Component Info ==
        '        l_strSQLCmd = " SELECT distinct SEQ_NO ,Category_ID,isnull(CATEGORY_Name,'') as CATEGORY_Name,IsNull(Category_type,'') as category_type, " & _
        '        " Parent_Category_id,IsNull(CATEGORY_DESC,'') as CATEGORY_DESC, " & _
        '        " IsNull(Category_price,0) as category_price, IsNull(Category_qty, 1) as category_qty,ParentSeqNo,last_updated_by FROM " & table & _
        '        " WHERE (PARENT_CATEGORY_ID = '" & Detail_Category_Id & "' and ParentSeqNo='" & Detail_ParentSeqNo & "')"
        '        l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_Catalog_Id & "'"
        '        l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & szCATALOGCFG_SEQ & " Order by SEQ_NO"

        '        Dim l_adoRs_detail_com As DataTable = dbUtil.dbGetDataTable("B2B", l_strSQLCmd) 'g_adoConn.Execute(l_strSQLCmd)
        '        'HttpContext.Current.Response.Write("BBB")
        '        'showDT(l_adoRs_detail_com)

        '        For Each r2 As DataRow In l_adoRs_detail_com.Rows
        '            Detail_Category_Id = r2.Item("CATEGORY_Id")
        '            Dim Detail_PartNo = r2.Item("CATEGORY_Name")
        '            Dim Detail_Qty = Trim(r2.Item("Category_qty"))
        '            Dim Detail_Price = Trim(r2.Item("CATEGORY_Price"))
        '            Dim DetailParentSeqNo = Trim(r2.Item("ParentSeqNo"))
        '            Dim ParentCategory = Trim(r2.Item("parent_category_id"))
        '            Dim iRet As Integer = 0
        '            If flg = "NEWQUOTE" Then
        '                HttpContext.Current.Session("nBtos_LineNo") = HttpContext.Current.Session("nBtos_LineNo") + 1
        '                Dim ITP As Decimal = 0
        '                Op_Quotation.ADD_Quote_Line(HttpContext.Current.Session("UID"), HttpContext.Current.Session("nBtos_LineNo"), Detail_PartNo, Detail_Qty, Detail_Price, Detail_Price, ParentCategory, 0, "", 0, "", ITP, Detail_Price, 0, ITP)
        '            Else
        '                iRet = CartDetail_insert(szCATALOGCFG_SEQ, g_Catalog_Id, Detail_Category_Id, HttpContext.Current.Session("CART_ID"), HttpContext.Current.Session("COMPANY_CURRENCY"), Detail_PartNo, Detail_Qty, Detail_Price, Detail_Price)
        '            End If
        '            REM == End Transform ==
        '            iRet = Transform_Detail(g_Catalog_Id, szCATALOGCFG_SEQ, r2.Item("CATEGORY_ID"), DetailParentSeqNo, PszPrice, PszPrice, flg)

        '        Next
        '        l_adoRs_detail_com = Nothing
        '    Next

        '    l_adoRs_detail = Nothing
        Transform_Detail = 1
    End Function

    Public Shared Function GetCustomerInfo(ByRef strHTML As String) As Integer
        'exeFunc = DBConn_Get(strEntity_Id, "B2B", l_adoConn)
        Dim strSTCompanyId As String = "", strSTCompanyName As String = "", strSTAddr As String = "", strSTTelNo As String = ""
        Dim strSTFaxNo As String = "", strSTAttention As String = "", l_strHTML As String = ""

        Dim strSQL = "select IsNull(company_id,'') as company_id,IsNull(company_name,'') as company_name,IsNull(address,'') as address,IsNull(tel_no,'') as tel_no,IsNull(fax_no,'') as fax_no,IsNull(attention,'') as attention  from company where company_id='" & HttpContext.Current.Session("company_id") & "' and company_type='Partner' "
        'Dim g_adoConn As New SqlClient.SqlConnection
        Dim l_adoRs As DataTable = dbUtil.dbGetDataTable("B2B", strSQL) '.execute(strSQL)
        If l_adoRs.Rows.Count > 0 Then 'Not l_adoRs.EOF Then
            strSTCompanyId = l_adoRs.Rows(0).Item("company_id")
            strSTCompanyName = l_adoRs.Rows(0).Item("company_name")
            strSTAddr = l_adoRs.Rows(0).Item("address")
            strSTTelNo = l_adoRs.Rows(0).Item("tel_no")
            strSTFaxNo = l_adoRs.Rows(0).Item("fax_no")
            strSTAttention = l_adoRs.Rows(0).Item("attention")
        End If

        l_strHTML = "<Br>"
        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td valign='top'><img src='../images/header_advantech_logo.gif'>"
        l_strHTML = l_strHTML & "<div class=""euPageTitle""><font style='font-size: 22px;line-height: 23px;font-weight: bold;'>Advantech Quotation</font></div></td>"
        l_strHTML = l_strHTML & "<td width=""200"">"
        l_strHTML = l_strHTML & "</td>"
        l_strHTML = l_strHTML & "<td align=""right"">"
        l_strHTML = l_strHTML & "<b>Advantech Europe BV</b><br>"
        l_strHTML = l_strHTML & "Ekkersrijt 5708, 5692 Ep Son, The Netherlands " & "<br>"
        l_strHTML = l_strHTML & "Tel: +31 40-26-77-022&nbsp;&nbsp;Fax: +31 40-26-77-006" & "<br>"
        l_strHTML = l_strHTML & "</td></tr>"
        l_strHTML = l_strHTML & "</table><br>"
        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML = l_strHTML & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML = l_strHTML & "<font color=""#ffffff""><b>Customer Information</b></font></td></tr>"
        l_strHTML = l_strHTML & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        l_strHTML = l_strHTML & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td bgcolor=""#F0F0F0"" colspan=""4"" align =""center"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Customer Information&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Customer&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""60%""  >"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTCompanyName & "(" & strSTCompanyId & ")</font></td>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Attention&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%""  >"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTAttention & "</font></td>"
        l_strHTML = l_strHTML & "</tr>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" bgcolor=""#F0F0F0"" rowspan=""2"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Address&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""60%"" rowspan=""2"" >"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTAddr & "</font></td>"
        l_strHTML = l_strHTML & "<td width=""10%""  height=""10""  bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Tel No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10"" >"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTTelNo & "</font></td>"
        l_strHTML = l_strHTML & "<tr>"
        l_strHTML = l_strHTML & "<td width=""10%"" height=""7"" bgcolor=""#F0F0F0"" align =""right"">"
        l_strHTML = l_strHTML & "<b><font color=""#333333"">Fax No.&nbsp;&nbsp;</font></b></td>"
        l_strHTML = l_strHTML & "<td bgcolor=""#FFFFFF"" width=""20%"" height=""10"" >"
        l_strHTML = l_strHTML & "<font color=""#333333"">&nbsp;" & strSTFaxNo & "</font></td>"
        l_strHTML = l_strHTML & "</tr></table>"
        l_strHTML = l_strHTML & "</td></tr></table>"

        strHTML = l_strHTML & "<br>"
        Return 1
    End Function

    'Jackie  Add for print component quotation
    Public Shared Function stand_quote(ByVal StrID As String, ByRef strHTML As String) As Integer
        Dim l_strHTML3 As String = ""
        l_strHTML3 = l_strHTML3 & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML3 = l_strHTML3 & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#ffffff""><b>Product List</b></font></td></tr>"
        l_strHTML3 = l_strHTML3 & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"

        l_strHTML3 = l_strHTML3 & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML3 = l_strHTML3 & "<tr>"
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>No</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Part No.</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""25%"" bgcolor=""#F0F0F0""  align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Description</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>List Price</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Disc</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Unit Price</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Qty</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""left""><b>Availability</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""left""><b>Due Date</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>Subtotal</b></font></td>"
        l_strHTML3 = l_strHTML3 & "</tr>"

        Dim strCurrency = HttpContext.Current.Session("COMPANY_CURRENCY")
        Dim strCurrSign = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN")

        ' get detail
        Dim strSQL = "select distinct q.part_no as part_no,max(isnull(p.product_desc,'')) as pro_desc,q.list_price,q.unit_price,q.qty,q.atp_num,q.atp_date from quotation_detail q inner join product p on q.part_no=p.part_no and q.quote_id='" & StrID & "' and q.line_no <100 group by q.part_no,list_price,unit_price,qty,atp_num,atp_date"
        'HttpContext.Current.Response.Write sql
        'response.end
        'l_adoRs = g_adoConn.execute(sql)
        Dim l_adoR As DataTable = dbUtil.dbGetDataTable("B2B", strSQL)
        Dim intX = 0
        Dim total = 0
        Dim tbd_flg As Boolean = False
        For Each r As DataRow In l_adoR.Rows
            intX = intX + 1
            If r.Item("unit_price") <= 0 Then
                l_strHTML3 = l_strHTML3 & "<tr style=""BACKGROUND-COLOR: #ccffff;WIDTH=100%"">"
            Else
                l_strHTML3 = l_strHTML3 & "<tr>"
            End If
            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & intX & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""15%""  align =""left"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & UCase(r.Item("part_no")) & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""20%""  align =""left"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & UCase(r.Item("pro_desc")) & "&nbsp;</font></td>"

            Dim RBUMailFormat As String = "", list_price As String = "", disc As String = ""
            If CLng(r.Item("list_price")) = -1 Then
                If Global_Inc.IsRBU(HttpContext.Current.Session("company_id"), RBUMailFormat) Then
                    list_price = "N/A"
                Else
                    list_price = "TBD"
                End If
            Else
                list_price = strCurrSign & FormatNumber(r.Item("list_price"))
            End If
            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & list_price & "&nbsp;</font></td>"

            If r.Item("list_price") <= 0 Then
                disc = "--%"
            Else
                If CLng((1 - (r.Item("unit_price") / r.Item("list_price"))) * 100) >= 0 And _
                CLng((1 - (r.Item("unit_price") / r.Item("list_price"))) * 100) <= 100 Then
                    disc = CLng((1 - (r.Item("unit_price") / r.Item("list_price"))) * 100) & "%"
                Else
                    disc = 100 & "%"
                End If
            End If
            'end if

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & disc & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            If CDbl(r.Item("unit_price")) < 0 Then
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & "TBD" & "&nbsp;</font></td>"
                tbd_flg = True
                'if tbd_flg =True
            Else
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & strCurrSign & _
                FormatNumber(r.Item("unit_price")) & "&nbsp;</font></td>"
            End If

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & r.Item("qty") & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & r.Item("atp_num") & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""middle"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & Global_Inc.FormatDate(r.Item("atp_date")) & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            If CDbl(r.Item("unit_price")) >= 0 Then
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & strCurrSign & _
                FormatNumber(CDbl(r.Item("unit_price")) * CInt(r.Item("qty"))) & "&nbsp;</font></td>"
            Else
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & "TBD" & "&nbsp;</font></td>"
            End If
            If CDbl(r.Item("unit_price")) > 0 Then
                total = total + CDbl(r.Item("unit_price")) * CInt(r.Item("qty"))
            End If
        Next

        l_strHTML3 = l_strHTML3 & "<tr>"
        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" colspan=""10""  align =""right"">"
        If total <= 0 Then
            l_strHTML3 = l_strHTML3 & "<font  color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;TBD</b></font></td>"
        ElseIf tbd_flg = True Then
            l_strHTML3 = l_strHTML3 & "<font  color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & _
            FormatNumber(total, 2) & " + TBD</b></font></td>"
        Else
            l_strHTML3 = l_strHTML3 & "<font  color=""#333333""><b>(" & strCurrency & ") Total:&nbsp;" & strCurrSign & _
            FormatNumber(total, 2) & "</b></font></td>"
        End If

        l_strHTML3 = l_strHTML3 & "</tr>"
        l_strHTML3 = l_strHTML3 & "</table>"
        l_strHTML3 = l_strHTML3 & "</td></tr></table>" & "<br>"
        'HttpContext.Current.Response.Write l_strHTML3
        strHTML = l_strHTML3

    End Function

    'jackie 2000117
    Public Shared Function CartLine_Add(ByVal strCartId As String, ByVal line_no As Integer, ByVal part_no As String, _
    ByVal intQty As Integer, ByVal fltListPrice As Decimal, ByVal fltUnitPrice As Decimal, ByVal DeliveryPlant As String, _
    Optional ByVal EwMonth As String = "0") As Integer

        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
        " select IsNull(line_no, 1) as line_no " & _
        " from cart_detail where cart_id='" & strCartId & "' and line_no=" & line_no)
        If dt.Rows.Count > 0 Then line_no += 1

        Dim strSql As String = ""
        strSql &= "INSERT INTO CART_DETAIL "
        strSql &= "( CART_ID, LINE_NO, PART_NO, QTY, LIST_PRICE, UNIT_PRICE,DeliveryPlant,ExWarranty_Flag) "
        strSql &= "VALUES('" & strCartId & "', " & line_no & ", '" & part_no & "', " & intQty & ", " & fltListPrice & ", " & fltUnitPrice & ",'" & DeliveryPlant & "','" & EwMonth & "')"
        'Dim sqlConn As SqlClient.SqlConnection = Nothing
        dbUtil.dbExecuteNoQuery("B2B", strSql)
        'sqlConn.Close()
        Return 1
    End Function

    Public Shared Function CartLine_Add(ByVal strCartId As String, ByVal line_no As Integer, ByVal part_no As String, _
    ByVal intQty As Integer, ByVal fltListPrice As Decimal, ByVal fltUnitPrice As Decimal, ByVal intUpdate_Price As Integer) As Integer

        Dim dt As DataTable = dbUtil.dbGetDataTable("B2B", _
        " select IsNull(line_no, 1) as line_no " & _
        " from cart_detail where cart_id='" & strCartId & "' and line_no=" & line_no)
        If dt.Rows.Count > 0 Then line_no += 1

        Dim strSql As String = ""
        strSql &= "INSERT INTO CART_DETAIL "
        strSql &= "( CART_ID, LINE_NO, PART_NO, QTY, LIST_PRICE, UNIT_PRICE, Update_Price) "
        strSql &= "VALUES('" & strCartId & "', " & line_no & ", '" & part_no & "', " & intQty & ", " & fltListPrice & ", " & fltUnitPrice & "," & intUpdate_Price & ") "

        dbUtil.dbExecuteNoQuery("B2B", strSql)
        Return 1
    End Function

    'Public Shared Function CartPrice_Update(ByVal strCartId As String, ByVal strEntityId As String, _
    'ByVal strCompanyPriceClass As String, ByVal strCurrency As String) As Integer
    '    Dim strSQL As String = ""
    '    Dim CartDT As New DataTable
    '    strSQL = "Select Line_NO,Part_NO,QTY,List_Price,Unit_Price from Cart_Detail where Cart_ID='" & strCartId & "' and IsNull(update_price,0) <> 1"
    '    CartDT = dbUtil.dbGetDataTable("B2B", strSQL)
    '    If CartDT.Rows.Count >= 1 Then
    '        GetMultiPrice(CartDT, "")
    '        Dim i As Integer = 0
    '        While i <= CartDT.Rows.Count - 1
    '            strSQL = "Update Cart_Detail set List_Price=" & CartDT.Rows(i).Item("List_Price") & ",Unit_Price=" & CartDT.Rows(i).Item("Unit_Price") & " " & _
    '                     " where Cart_ID='" & strCartId & "' and Line_NO=" & CartDT.Rows(i).Item("Line_NO") & " and Part_NO='" & CartDT.Rows(i).Item("Part_NO") & "'"
    '            dbUtil.dbExecuteNoQuery("B2B", strSQL)
    '            i = i + 1
    '        End While
    '    End If
    'End Function


    Public Shared Function QuotationPage_Get(ByVal FuncID As Integer, ByVal g_CATALOG_ID As String, _
    ByVal CATALOGCFG_SEQ As Integer, ByRef ConfigurationHTML As String) As Integer

        Dim l_adoRs As New DataTable
        Dim required_date, intSpan
        Dim due_date As String = "00000000", max_due_date As String = ""
        Dim iRet As Integer
        Dim tb As String = ""

        If HttpContext.Current.Request("flg") = "history" Then
            'HttpContext.Current.Response.Write("yyyy")
            ' Response.End()
            tb = "Quotation_catalog_category_history"
        Else
            tb = "Quotation_catalog_category"


        End If
        Dim l_strSQLCmd As String = ""
        If CATALOGCFG_SEQ = 99 Then
            l_strSQLCmd = " SELECT distinct CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,Category_desc,Category_price,Category_qty,due_date,required_date FROM " & tb & " WHERE (PARENT_CATEGORY_ID = 'ROOT')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'"
            'l_adoRs = g_adoConn.Execute(l_strSQLCmd)
        Else
            l_strSQLCmd = " SELECT distinct CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,Category_desc,Category_price,Category_qty FROM " & tb & " WHERE (PARENT_CATEGORY_ID = 'ROOT')"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'"
            l_strSQLCmd = l_strSQLCmd & " AND CATALOGCFG_SEQ=" & CATALOGCFG_SEQ
            'l_adoRs = g_adoConn.Execute(l_strSQLCmd)
        End If

        l_adoRs = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        '============================== end here ===========================================================
        If l_adoRs.Rows.Count > 0 Then 'Do While Not l_adoRs.EOF

            If HttpContext.Current.Request.Form("textflg") <> "" Then
                required_date = HttpContext.Current.Request.Form("textflg")
            Else
                required_date = l_adoRs.Rows(0).Item("required_date") 'Global_Inc.FormatDate(System.DateTime.Now)  'dtDefaultReqDate
            End If

            ' for get the btos due date
            If HttpContext.Current.Request.Form("textflg") <> "" Then
                If CDate(HttpContext.Current.Request.Form("textflg")) <> CDate(l_adoRs.Rows(0).Item("required_date")) Then
                    iRet = GetBTOSDueDate(g_CATALOG_ID, required_date, l_adoRs.Rows(0).Item("Category_qty"), due_date)
                    iRet = Global_Inc.CalculateSAPWorkingDate(due_date, 9)
                    dbUtil.dbExecuteNoQuery("B2B", "update quotation_catalog_category set required_date='" & _
                    required_date & "',due_date='" & due_date & "' where catalog_id='" & _
                    HttpContext.Current.Session("g_CATALOG_ID") & "' and parent_category_id='root'")
                Else
                    due_date = l_adoRs.Rows(0).Item("due_date")
                End If
            Else
                due_date = l_adoRs.Rows(0).Item("due_date")
            End If


            Dim lf = Chr(13) & Chr(10)
            'Lcase(Request.ServerVariables("PATH_INFO")) Like "*cart_list*"

            ConfigurationHTML = ConfigurationHTML & "<span class='List_Corp'>" & lf
            If InStr(LCase(HttpContext.Current.Request.ServerVariables("PATH_INFO")), "quote_print") > 0 Or _
            HttpContext.Current.Request("email_flg") = "quote" Then ' this is for the quote print page
                ConfigurationHTML = ConfigurationHTML & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
                ConfigurationHTML = ConfigurationHTML & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"">"
                ConfigurationHTML = ConfigurationHTML & "<font color=""#ffffff""><b>BTOS Quotation</b></font></td></tr>"
                ConfigurationHTML = ConfigurationHTML & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"
                ConfigurationHTML = ConfigurationHTML & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
                ConfigurationHTML = ConfigurationHTML & "<tr class='Header'>" & lf
                ConfigurationHTML = ConfigurationHTML & "				<td align='Center'>NO</td>" & lf
            Else
                ConfigurationHTML = ConfigurationHTML & "<table cellSpacing='0' cellPadding='0' width='100%' align='center' border='0'>" & lf
                ConfigurationHTML = ConfigurationHTML & "	<tr class='AppletBlank'>" & lf
                ConfigurationHTML = ConfigurationHTML & "		<td class='AppletTitle' vAlign='top' width='8'><img alt src='../images/Spacer.gif' width='8' height='10'></td>" & lf
                If InStr(LCase(HttpContext.Current.Request.ServerVariables("PATH_INFO")), "QuoteHistory") > 0 Then
                    ConfigurationHTML = ConfigurationHTML & "		<td class='AppletTitle' noWrap>Quotation History Page</td>" & lf
                Else
                    ConfigurationHTML = ConfigurationHTML & "		<td class='AppletTitle' noWrap>Quotation Page</td>" & lf
                End If
                ConfigurationHTML = ConfigurationHTML & "		<td class='AppletTitle' vAlign='top' align='right' width='22'><img alt src='../images/aplt_folder_r.gif' width='22' height='18'></td>" & lf
                ConfigurationHTML = ConfigurationHTML & "		<td class='AppletBlank' align='right' width='100%'>&nbsp;&nbsp;&nbsp;&nbsp;</td>" & lf
                ConfigurationHTML = ConfigurationHTML & "	</tr>" '& xlsBtn & lf
                ConfigurationHTML = ConfigurationHTML & "</table>" & lf
                ConfigurationHTML = ConfigurationHTML & "<table class='AppletStyle1' valign='top' width='100%' cellpadding='0' cellspacing='0' border='0'>" & lf
                ConfigurationHTML = ConfigurationHTML & "	<tr><td class='AppletButtons'><img src='../images/spacer.gif' width='2' height='2'></td></tr>" & lf
                ConfigurationHTML = ConfigurationHTML & "</table>" & lf
                ConfigurationHTML = ConfigurationHTML & "</span>" & lf

                ConfigurationHTML = ConfigurationHTML & "<span class='List_Corp'>" & lf
                ConfigurationHTML = ConfigurationHTML & "<table width='100%' cellspacing='0' cellpadding='0' border='0' align='center'>" & lf
                ConfigurationHTML = ConfigurationHTML & "	<tr><td width='100%' class='AppletButtons' align='right'><img src='../images/spacer.gif' height='3'></td></tr>" & lf
                ConfigurationHTML = ConfigurationHTML & "</table>" & lf

                ConfigurationHTML = ConfigurationHTML & "<table width='100%' cellpadding='0' cellspacing='1' border='0' valign='top' bgcolor='#cccccc'>" & lf
                ConfigurationHTML = ConfigurationHTML & "	<tr valign='top'><td width='100%'>" & lf
                ConfigurationHTML = ConfigurationHTML & "		<table width='100%' cellpadding='2' cellspacing='1' border='0' valign='top'>" & lf
                ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>" & lf
                ConfigurationHTML = ConfigurationHTML & "				<td align='Center'>#</td>" & lf
            End If


            Select Case FuncID
                Case 2, 3
                    intSpan = 4
                Case Else
                    intSpan = 5
            End Select

            ConfigurationHTML = ConfigurationHTML & "				<td align='Center' width='50%' colspan =4>BTO DESCRIPTION</td>" & lf
            REM == Add BTO Master Qty For Update ==
            '*****************************Jackie Wu add atp field 2005/9/21
            'if request("sRequestDate")<>"" then
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center' >Due Date</td>" & lf
            'end if
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center' >Required Date</td>" & lf
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center' >Quantity</td>" & lf
            If FuncID = 2 Or FuncID = 3 Then
                ConfigurationHTML = ConfigurationHTML & "			<td align='Center'>Expected Shipping Date</td>" & lf
                ConfigurationHTML = ConfigurationHTML & "			<td align='Center'>Required Date</td>" & lf
            End If

            ConfigurationHTML = ConfigurationHTML & "				<td align='Center'>Unit Price</td>" & lf
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center'>SubTotal</td>" & lf
            ConfigurationHTML = ConfigurationHTML & "			</tr>" & lf

            ConfigurationHTML = ConfigurationHTML & "			<tr bgcolor='#FFFFFF'>" & lf

            If FuncID = 1 Then
                'ConfigurationHTML = ConfigurationHTML & "		<form action='/quote/Quotation_Del.asp' method='post' name='DelQuoteForm'>" & lf
                ConfigurationHTML = ConfigurationHTML & "		<Input type='hidden' name='Sub_Category_id' value='" & l_adoRs.Rows(0).Item("Category_Id") & "'> " & lf
                ConfigurationHTML = ConfigurationHTML & "		<Input type='hidden' name='Sub_CATALOGCFG_SEQ' value=" & l_adoRs.Rows(0).Item("CATALOGCFG_SEQ") & "> " & lf

                'tmp = AddButton (strHTML, "<font color=red>Del</font>", "ON" , "DelConfigForm.submit();")
                If InStr(LCase(HttpContext.Current.Request.ServerVariables("PATH_INFO")), "quote_print") <= 0 And HttpContext.Current.Request("email_flg") <> "quote" Then
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center'>" & "<input type='button' value='DEL' onclick='Del()'>" & "</td>" & lf
                Else
                    ConfigurationHTML = ConfigurationHTML & "			<td align='Center'>1</td>" & lf
                End If
                'strHTML = ""
                'ConfigurationHTML = ConfigurationHTML & "		</form> " & lf
            Else
                REM == Add for FuncID -> 2 ==
                'ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center'>" & "&nbsp;&nbsp;" & "</td>" & lf
            End If
            ConfigurationHTML = ConfigurationHTML & "				<td class='Row' align='center' colspan =4>" & l_adoRs.Rows(0).Item("Category_Name") & " X" & l_adoRs.Rows(0).Item("Category_qty") & "</td>" & lf

            If FuncID = 1 Then

                ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center' bgcolor='#FFCCFF'>" & Global_Inc.FormatDate(due_date) & "</td>"

                If InStr(LCase(HttpContext.Current.Request.ServerVariables("PATH_INFO")), "quotehistory") <= 0 And InStr(LCase(HttpContext.Current.Request.ServerVariables("PATH_INFO")), "quotation_list") <= 0 Then
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & _
                    "<Input type='text' size=10 readonly name='textflg' style='text-align:right;width=60' value='" & _
                    Global_Inc.FormatDate(required_date) & "' onclick=""" & _
                    "popUpCalendar(this, this, 'yyyy/mm/dd','" & required_date & "');""" & "></td>" & lf
                Else
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & _
                    Global_Inc.FormatDate(required_date) & "</td>" & lf
                End If

                '**********************************************************************************************************************
                If InStr(LCase(HttpContext.Current.Request.ServerVariables("PATH_INFO")), "quotehistory") <= 0 Then
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & "<Input type='text' size=2 name='ConfigQty" & l_adoRs.Rows(0).Item("CATALOGCFG_SEQ") & l_adoRs.Rows(0).Item("Category_Id") & "' style='text-align:right;width=30' value="
                    ConfigurationHTML = ConfigurationHTML & l_adoRs.Rows(0).Item("Category_qty") & " onchange='return ConfigQty_onchange(""" & l_adoRs.Rows(0).Item("Category_qty") & """,this)'></td>" & lf
                Else
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & l_adoRs.Rows(0).Item("Category_qty") & " </td>" & lf
                End If
            Else
                'ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='center'>" & l_adoRs("Category_qty") & "</td>" & lf
            End If
            'ConfigurationHTML = ConfigurationHTML & "</form>"


            Dim SubPszPrice As String = "", PszPrice As Decimal = 0, StrPszPrice As String = "", StrSubTotal As String = ""
            If HttpContext.Current.Request("flg") = "history" Then
                'iRet = Me.ConfigurationTotalPrice_Get(g_CATALOG_ID, l_adoRs.Rows(0).Item("CATALOGCFG_SEQ"), l_adoRs.Rows(0).Item("Category_Id"), 0, SubPszPrice, "history")
                iRet = ConfigurationTotalPrice_Get(g_CATALOG_ID, l_adoRs.Rows(0).Item("CATALOGCFG_SEQ"), l_adoRs.Rows(0).Item("Category_Id"), 0, PszPrice, "history")
            Else
                'iRet = Me.ConfigurationTotalPrice_Get(g_CATALOG_ID, l_adoRs.Rows(0).Item("CATALOGCFG_SEQ"), l_adoRs.Rows(0).Item("Category_Id"), 0, SubPszPrice, "Quote")
                iRet = ConfigurationTotalPrice_Get(g_CATALOG_ID, l_adoRs.Rows(0).Item("CATALOGCFG_SEQ"), l_adoRs.Rows(0).Item("Category_Id"), 0, PszPrice, "Quote")
            End If
            If (iRet = 0) Or (PszPrice < 0) Then
                StrPszPrice = "TBD"
                'StrSubTotal = "TBD"
            Else
                StrSubTotal = FormatNumber(CDbl(PszPrice) * CInt(l_adoRs.Rows(0).Item("Category_qty")), 2)
                StrPszPrice = CStr(FormatNumber(PszPrice, 2))
            End If

            'PszPrice = SubPszPrice / l_adoRs.Rows(0).Item("Category_qty")


            ConfigurationHTML = ConfigurationHTML & "				<td class='Row' align='Center'>" & HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") & StrPszPrice & "</td>"
            ConfigurationHTML = ConfigurationHTML & "				<td class='Row' align='Center' >" & HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") & StrSubTotal & "</td>"
            ConfigurationHTML = ConfigurationHTML & "			</tr>"
            PszPrice = 0
            SubPszPrice = 0
            ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>"
            If FuncID = 1 Then
                ConfigurationHTML = ConfigurationHTML & _
                "			<td class='Row' align='Center' colspan=10>BTOS Configuration for " & l_adoRs.Rows(0).Item("Category_Name") & _
                "</td>"

            End If

            If FuncID = 2 Or FuncID = 3 Then
                ConfigurationHTML = ConfigurationHTML & _
                "			<td class='Row' align='Center' colspan=11>BTOS Configuration for " & _
                l_adoRs.Rows(0).Item("Category_Name") & "</td>"
            End If

            ConfigurationHTML = ConfigurationHTML & "			</tr>"



            If LCase(HttpContext.Current.Request.ServerVariables("PATH_INFO")) Like "*quotation_list*" And _
            HttpContext.Current.Request("email_flg") <> "quote" Then
                ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>"
                If FuncID = 1 Then
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' colspan=10>"
                    ConfigurationHTML = ConfigurationHTML & "<A HREF='../order/BTOSHistorySave_input.aspx?g_CATALOG_ID=" & _
                    HttpContext.Current.Session("G_CATALOG_ID") & "&CATALOGCFG_SEQ=" & l_adoRs.Rows(0).Item("CATALOGCFG_SEQ") & _
                    "&Category_Id=" & l_adoRs.Rows(0).Item("Category_Id") & "&Category_Name=" & l_adoRs.Rows(0).Item("Category_Name") & _
                    "&flg=quote'>" & ">>Save Configuration<<</A></td>"
                End If
                ConfigurationHTML = ConfigurationHTML & "			</tr>"
            End If


            ' detail page

            ConfigurationHTML = ConfigurationHTML & "			<tr class='Header'>"
            ConfigurationHTML = ConfigurationHTML & "				<td align='Center' width='5%'>#</td>"
            ConfigurationHTML = ConfigurationHTML & "				<td width='20%'>Category</td>"
            ConfigurationHTML = ConfigurationHTML & "				<td width='15%'>Part No</td>"

            Select Case FuncID
                Case 1
                    '*******************************************Jackie Wu revise 2005-9-22
                    'ConfigurationHTML = ConfigurationHTML & "			<td width='40%' colspan=4>Description</td>"
                    ConfigurationHTML = ConfigurationHTML & "			<td width='40%' colspan=5>Description</td>"
                Case 2
                    ConfigurationHTML = ConfigurationHTML & "			<td width='35%' colspan=5>Description</td>"
                    ConfigurationHTML = ConfigurationHTML & "			<td class='Row' align='Center' width='15%'>Promise Date</td>"
                Case 3
                    ConfigurationHTML = ConfigurationHTML & "			<td width='40%' colspan=8>Description</td>"
            End Select

            If FuncID = 1 Or FuncID = 2 Then
                'If UCase(HttpContext.Current.Session("USER_ROLE")) = "BUYER" Then
                If HttpContext.Current.Request.IsAuthenticated Then
                    ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='15%' colspan=2>Quantity</td>"
                Else
                    ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='5%'>Quantity</td>"
                    ConfigurationHTML = ConfigurationHTML & "			<td align='Center' width='10%'>Unit Price</td>"
                End If
            End If

            ConfigurationHTML = ConfigurationHTML & "			</tr>"
            Dim PszHTML As String = ""
            Dim Root_Category_Id = l_adoRs.Rows(0)("Category_id")
            If HttpContext.Current.Request("flg") = "history" Then
                iRet = ConfigurationDetail(FuncID, Root_Category_Id, "1", l_adoRs.Rows(0).Item("CATALOGCFG_SEQ"), "FIRST", "", PszHTML, "history")

            Else
                iRet = ConfigurationDetail(FuncID, Root_Category_Id, "1", l_adoRs.Rows(0).Item("CATALOGCFG_SEQ"), "FIRST", "", PszHTML, "Quote")

            End If
            'exf=GetPartNo(FuncID,Root_Category_Id,l_adoRs("CATALOGCFG_SEQ"),"FIRST",pno_set,pno_set_count)

            ConfigurationHTML = ConfigurationHTML & PszHTML
            PszHTML = ""

            ConfigurationHTML = ConfigurationHTML & "		</table>"
            ConfigurationHTML = ConfigurationHTML & "	</td></tr>"
            ConfigurationHTML = ConfigurationHTML & "</table>"

            ConfigurationHTML = ConfigurationHTML & "<table width='100%' cellspacing='0' cellpadding='0' border='0'  align='center'>"
            ConfigurationHTML = ConfigurationHTML & "	<tr><td class='AppletButtons' align='right'><img src='../images/spacer.gif' height='2'></td></tr>"
            ConfigurationHTML = ConfigurationHTML & "</table>"

            ConfigurationHTML = ConfigurationHTML & "</span>"


            'BTOCount = BTOCount + 100
            ConfigurationHTML = ConfigurationHTML & "<BR>"
            If False Then ConfigurationHTML = ConfigurationHTML & "<a target=""_blank"" href=""BTOS_Export2Excel.aspx?flg=quote"">Export2Excel</a><br/>"
        End If

        QuotationPage_Get = 1
    End Function

    Public Shared Function PhaseOutItemCheck(ByVal StrPartNo As String) As Integer
        'Dim l_strSQLCmd As String = "select * from product where part_no='" & StrPartNo & "'"
        'Dim rs As New DataTable
        'rs = dbUtil.dbGetDataTable("B2B", l_strSQLCmd) 'g_adoConn.Execute(l_strSQLCmd)

        'If rs.Rows.Count > 0 Then
        '    If UCase(rs.Rows(0).Item("status")) = "A" Or UCase(rs.Rows(0).Item("status")) = "N" Or UCase(rs.Rows(0).Item("status")) = "H" Or UCase(rs.Rows(0).Item("status")) = "S5" Then
        '        PhaseOutItemCheck = 1
        '        Exit Function
        '    End If
        'End If
        PhaseOutItemCheck = 1
    End Function


    Public Shared Function GetBTOSDueDate(ByVal g_CATALOG_ID As String, ByVal required_date As String, ByVal qty As Integer, _
    ByRef due_date As String) As Integer
        Dim table As New DataTable
        Dim l_strSQLCmd As String = "SELECT CATALOGCFG_SEQ,Category_ID,CATEGORY_Name,Category_type,Parent_Category_id,CATEGORY_DESC,category_qty " & _
      "  FROM QUOTATION_CATALOG_CATEGORY " & _
      " WHERE CATEGORY_type = 'Component'" & _
      "   AND CATALOG_ID=" & "'" & g_CATALOG_ID & "'" & _
      "   AND category_type<>'Root' and (category_id not like 'S-WARRANTY-BS%' and category_id not like 'option%') Order by SEQ_NO "
        table = dbUtil.dbGetDataTable("B2B", l_strSQLCmd)
        qty = 1
        If Global_Inc.IsNumericItem(table.Rows(0).Item("category_qty")) Then
            qty = CInt(table.Rows(0).Item("category_qty"))
        End If
        Dim max_due_date As String = System.DateTime.Today.ToString() '"00000000"
        Dim first_qty As Integer = 0

        Dim oRsATPi As New DataTable
        Global_Inc.InitRsATPi(oRsATPi)

        For i As Integer = 0 To table.Rows.Count - 1
            Dim row1 As DataRow = oRsATPi.NewRow()
            row1.Item("WERK") = "EUH1"
            If Global_Inc.IsNumericItem(table.Rows(i).Item("Category_ID")) Then
                row1.Item("MATNR") = "00000000" & table.Rows(i).Item("Category_ID")
            Else
                row1.Item("MATNR") = UCase(table.Rows(i).Item("Category_ID"))
            End If
            'row1.Item("REQ_QTY") = CDbl(dr.Item("qty_sub"))
            row1.Item("REQ_QTY") = CDbl(qty)
            row1.Item("REQ_DATE") = CDate(required_date) 'System.DateTime.Today()
            row1.Item("UNI") = "PC"
            oRsATPi.Rows.Add(row1)
        Next
        Dim strSendXml As String = Global_Inc.DataTableToADOXML(oRsATPi)
        Dim strRecXml As String = ""
        Dim strRemark As String = ""
        'Dim sc3 As New ACLBI_B2B_SAP_WS.B2B_AEU_WS
        Dim sc3 As New aeu_ebus_dev9000.B2B_AEU_WS

        HttpContext.Current.Response.Write(strSendXml)
        Try
            Dim iRtn As Integer = _
            sc3.GetMultiDueDate(HttpContext.Current.Session("company_id"), HttpContext.Current.Session("company_id"), "EU10", "10", "00", strSendXml, strRecXml, strRemark)
        Catch ex As Exception
            HttpContext.Current.Response.Write(ex.ToString())
            HttpContext.Current.Response.End()
        End Try

        Dim ResultDs As New System.Data.DataSet
        Dim sr As New System.IO.StringReader(strRecXml)
        HttpContext.Current.Response.Write(strRecXml & "<br/>" & strRemark)
        'Response.End()
        ResultDs.ReadXml(sr)

        For i As Integer = 0 To ResultDs.Tables(ResultDs.Tables.Count - 1).Rows.Count - 1
            If CDate(max_due_date) < CDate(ResultDs.Tables(ResultDs.Tables.Count - 1).Rows(i).Item("date")) Then
                max_due_date = ResultDs.Tables(ResultDs.Tables.Count - 1).Rows(i).Item("date")
            End If
        Next
        due_date = max_due_date
        Return 1
    End Function



    Public Shared Function GetDueDate(ByVal partNO As String, ByVal QTY As String, _
                                      ByVal requiredDate As String, ByRef dueDate As String, _
                                      ByRef atpQTY As String) As Integer
        Dim dt As New DataTable
        Dim WS As New aeu_ebus_dev9000.B2B_AEU_WS  'aeu_ebus_dev9000.b2b_sap_ws 'B2B_AEU_WS.B2B_AEU_WS
        Dim WSDL_URL As String = ""
        Global_Inc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        WS.Url = WSDL_URL

        Dim iRet As Integer = initRsATP(dt, "EUH1", partNO, QTY, requiredDate, "PC")
        Dim xmlInput As String = Global_Inc.DataTableToADOXML(dt)
        Dim xmlout As String = ""
        Dim xmlLog As String = ""
        iRet = WS.GetMultiDueDate(UCase(HttpContext.Current.Session("company_id")), UCase(HttpContext.Current.Session("company_id")), "EU10", "10", "00", xmlInput, xmlout, xmlLog)

        If iRet = -1 Then
            '---- ERROR HANDEL ----'
            HttpContext.Current.Response.Write("Calling SAP function Error!<br>" & xmlLog & "<br>")
            Return 0
        Else
            'If Global_Inc.IsB2BOwner(HttpContext.Current.Session("user_id")) Then
            'HttpContext.Current.Response.Write("xml:" & xmlInput & "<br>" & xmlout)
            'End If            
            Dim sr As System.IO.StringReader = New System.IO.StringReader(xmlout)
            Dim ds As New DataSet()
            Dim dv As New DataView()
            ds.ReadXml(sr)
            Try
                'atpQTY = ds.Tables(ds.Tables.Count - 1).Rows(0).Item("qty_atb").ToString() & "(" & Global_Inc.FormatDate(ds.Tables(ds.Tables.Count - 1).Rows(0).Item("date").ToString()) & ")"
                atpQTY = Global_Inc.FormatDate(ds.Tables(ds.Tables.Count - 1).Rows(0).Item("date").ToString()) & "(" & ds.Tables(ds.Tables.Count - 1).Rows(0).Item("qty_atb").ToString() & ")"
            Catch ex As Exception
                atpQTY = Global_Inc.FormatDate(System.DateTime.Today) & "(0)"
            End Try
            Try
                For i As Integer = 0 To ds.Tables(ds.Tables.Count - 1).Rows.Count - 1
                    If CInt(QTY) <= CInt(ds.Tables(ds.Tables.Count - 1).Rows(i).Item("qty_atb").ToString()) Then
                        dueDate = ds.Tables(ds.Tables.Count - 1).Rows(i).Item("date").ToString()
                        Exit For
                    End If
                Next
                If CInt(QTY) >= 99999 Then
                    dueDate = ds.Tables(ds.Tables.Count - 1).Rows(ds.Tables(ds.Tables.Count - 1).Rows.Count - 1).Item("date").ToString()
                End If
            Catch ex As Exception
                dueDate = System.DateTime.Today.ToString()
            End Try
            If Right(atpQTY, 6) = "99999)" Then
                atpQTY = Global_Inc.FormatDate(System.DateTime.Today) & "(0)"
            End If
            Return 1
        End If
    End Function


    Public Shared Function GetDueDate(ByVal partNO As String, ByVal QTY As String, ByVal requiredDate As String, _
                                      ByRef dueDate As String) As Integer
        Dim dt As New DataTable
        Dim WS As New aeu_ebus_dev9000.B2B_AEU_WS 'aeu_ebus_dev9000.b2b_sap_ws 'B2B_AEU_WS.B2B_AEU_WS
        Dim WSDL_URL As String = ""
        Global_Inc.SiteDefinition_Get("AeuEbizB2BWs", WSDL_URL)
        WS.Url = WSDL_URL
        Dim iRet As Integer = initRsATP(dt, "EUH1", partNO, QTY, requiredDate, "PC")
        Dim xmlInput As String = Global_Inc.DataTableToADOXML(dt)
        Dim xmlout As String = ""
        Dim xmlLog As String = ""
        WS.Timeout = 99999999
        iRet = _
        WS.GetMultiDueDate(HttpContext.Current.Session("company_id"), HttpContext.Current.Session("company_id"), "EU10", "10", "00", _
        xmlInput, xmlout, xmlLog)

        If iRet = -1 Then
            HttpContext.Current.Response.Write("Calling SAP function Error!<br>" & xmlLog & "<br>")
            Return 0
        Else
            'HttpContext.Current.Response.Write("xml:" & xmlInput & "<br>" & xmlout)

            If partNO.Contains("|") Then
                'HttpContext.Current.Response.Write("xml:" & xmlInput & "<br>" & xmlout)
                'Response.End()
                Dim tmpDt As DataTable = Util.ADOXml2DataTable(xmlout)
                'Dim gv1 As New WebControls.GridView
                'gv1.DataSource = tmpDt
                'gv1.DataBind()
                'HttpContext.Current.Response.Write(SysUtil.GetHtmlOfControl(gv1))
                'Response.End()
                If Not tmpDt Is Nothing Then
                    Dim MaxDue As Date = Now()
                    Dim tmpItem() As String = Split(partNO, "|")
                    For Each item As String In tmpItem
                        'HttpContext.Current.Response.Write("handling:" + Trim(item) + "<br/>")
                        Try
                            Dim selDt As DataTable = tmpDt.Copy()
                            selDt.DefaultView.RowFilter = "part='" + Trim(item) + "' and qty_fulfill>=" + QTY
                            selDt = selDt.DefaultView.ToTable()
                            If selDt.Rows.Count > 0 Then
                                If DateDiff( _
                                DateInterval.Day, MaxDue, _
                                selDt.Rows(0).Item("date") _
                                ) > 0 Then
                                    MaxDue = selDt.Rows(0).Item("date")
                                    'HttpContext.Current.Response.Write(MaxDue.ToShortDateString() + "<br/>")
                                End If
                            Else
                                'jackie add 20071206 for Z1 issue
                                Dim tempMaxDue As Date = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), item, Today)
                                If DateDiff( _
                               DateInterval.Day, MaxDue, _
                               tempMaxDue _
                               ) > 0 Then
                                    MaxDue = tempMaxDue
                                    'HttpContext.Current.Response.Write(MaxDue.ToShortDateString() + "<br/>")
                                End If
                            End If
                        Catch ex As Exception
                            'HttpContext.Current.Response.Write(ex.ToString() + "<br/>")
                        End Try
                    Next
                    dueDate = MaxDue
                    'Response.End()
                Else
                    Dim MaxDue As Date = Now()
                    Dim tmpItem() As String = Split(partNO, "|")
                    For Each item As String In tmpItem
                        dueDate = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), item, Today)
                        If MaxDue < dueDate Then
                            MaxDue = dueDate
                        End If
                    Next
                End If
            Else
                Dim sr As System.IO.StringReader = New System.IO.StringReader(xmlout)
                Dim ds As New DataSet()
                Dim dv As New DataView()
                ds.ReadXml(sr)
                Dim dtZ1 As DataTable = ds.Tables("row")
                If dtZ1 Is Nothing Then
                    dueDate = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), partNO, Today)
                Else
                    Try
                        Dim flg As Boolean = False
                        For i As Integer = 0 To dtZ1.Rows.Count - 1
                            If CInt(QTY) <= CInt(dtZ1.Rows(i).Item("qty_atb").ToString()) Then
                                dueDate = dtZ1.Rows(i).Item("date").ToString()
                                flg = True
                                Exit For
                            End If
                        Next
                        If Not flg Then
                            dueDate = Global_Inc.GetRPL(HttpContext.Current.Session("company_id"), partNO, Today)
                            Return 1
                        End If
                        'If CInt(QTY) >= 99999 Then
                        '    dueDate = ds.Tables(ds.Tables.Count - 1).Rows(ds.Tables(ds.Tables.Count - 1).Rows.Count - 1).Item("date").ToString()
                        'End If
                    Catch ex As Exception
                        dueDate = System.DateTime.Today.ToString()
                    End Try
                    dueDate = Global_Inc.FormatDate(dueDate)
                End If
            End If
            Return 1
        End If
    End Function

    Public Shared Function initRsATP(ByRef dt As DataTable, ByVal plant As String, ByVal partNO As String, ByVal QTY As String, ByVal requiredDate As String, ByVal Unit As String) As Integer
        Dim iRet As Integer = Global_Inc.InitRsATPi(dt)
        If partNO IsNot Nothing AndAlso partNO.Contains("|") Then
            Dim tmpItem() As String = Split(partNO, "|")
            For Each item As String In tmpItem
                Dim dr As DataRow = dt.NewRow()
                dr.Item("WERK") = plant.ToUpper()
                If Global_Inc.IsNumericItem(Trim(UCase(item))) Then
                    dr.Item("MATNR") = "00000000" & Trim(UCase(item))
                Else
                    dr.Item("MATNR") = Trim(UCase(item))
                End If

                dr.Item("REQ_QTY") = QTY.ToString()
                dr.Item("REQ_DATE") = requiredDate.ToString()
                dr.Item("UNI") = Unit.ToString()

                dt.Rows.Add(dr)
            Next
        Else
            Dim dr As DataRow = dt.NewRow()
            dr.Item("WERK") = plant.ToUpper()
            If Global_Inc.IsNumericItem(partNO.Trim().ToUpper()) Then
                dr.Item("MATNR") = "00000000" & partNO.Trim().ToUpper()
            Else
                dr.Item("MATNR") = partNO.Trim().ToUpper()
            End If

            dr.Item("REQ_QTY") = QTY.ToString()
            dr.Item("REQ_DATE") = requiredDate.ToString()
            dr.Item("UNI") = Unit.ToString()

            dt.Rows.Add(dr)
        End If

        Return 1
    End Function

    Public Shared Function IsMSSoft(ByVal pn As String) As Boolean
        If pn.ToString.ToUpper = "96SW-DOS62E" Or _
           pn.ToString.ToUpper = "96SW-W2K-SP4-US-E" Or _
           pn.ToString.ToUpper = "96SW-WIN2K-SP4-GA1" Then
            Return True
        End If
        Dim MSOsPNs() As String = {"968QW7PROE", "968QW7PROR", "968QW7PROS", "968QW7PS1C", "968QW7PS1R", "968QW7PS1X", "968QW7ULTE", _
                                   "968QW7ULTR", "968QW7ULTS", "968QW7US1C", "968QW7US1R", "968QW7US1X", "968QXPEEMB", "968QXPESTD", _
                                   "968QXPPR64", "968QXPPRO3", "968QXPPROE", "968QXPPROR", "968QXPPROS", "968QXPPRU3", "968QXPRO2C", "968QXPRO3S"}
        For Each mspn As String In MSOsPNs
            If pn.Equals(mspn, StringComparison.OrdinalIgnoreCase) Then Return True
        Next

        If dbUtil.dbGetDataTable("MY", String.Format( _
                                    "select part_no from sap_product where material_group in ('968MS','96SW') and part_no='{0}'", Trim(pn).Replace("'", "''"))).Rows.Count > 0 Then
            Return True
        End If
        Return False
    End Function

    Public Shared Function Add2CartCheck(ByVal part_no As String, ByVal user_role As String, Optional ByRef strStatusCode As String = "", Optional ByRef strStatusDesc As String = "", Optional ByVal ItemType As CartItemType = CartItemType.Part) As Boolean
        If IsNothing(HttpContext.Current.Session("org_id")) Then
            Return False
        End If
        Dim ORG_ID As String = HttpContext.Current.Session("org_id")
        ' Dim strStatusCode As String = "", strStatusDesc As String = "", 
        Dim decATP As Decimal = 0
        If SAPDAL.SAPDAL.isInvalidPhaseOutV2(part_no, ORG_ID, strStatusCode, strStatusDesc, decATP, True, ItemType) Then
            Return False
        End If

        If (strStatusCode = "T" And Not Util.IsInternalUser2()) Then Return False

        If ItemType <> CartItemType.Part Then Return True

        'Return False
        If Left(part_no, 5) = "ctos-" Then
            Return False
        End If
        '\ (2011-10-6) Ming add for '968MS',,,,,,Nada 20140102 excluded 968T
        If Not part_no.ToUpper.StartsWith("968T") Then
            If dbUtil.dbGetDataTable("MY", " select top 1 PART_NO from SAP_PRODUCT where MATERIAL_GROUP='968MS' and PART_NO='" + part_no + "'").Rows.Count > 0 Then
                If dbUtil.dbGetDataTable("MY", " select top 1 company_id from SAP_COMPANY_CLA where COMPANY_ID='" + HttpContext.Current.Session("company_id") + "' and GETDATE() between BEGIN_DATE and END_DATE").Rows.Count > 0 Then
                    Return True
                End If
            End If
        End If
        '/
        'Dim checksql As String = String.Format(" select a.part_no from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.part_no=b.part_no " & _
        '                                       " inner join SAP_PRODUCT_STATUS_ORDERABLE c on  c.PART_NO = a.PART_NO  and c.SALES_ORG = b.ORG_ID " & _
        '                                       " where c.PRODUCT_STATUS IN " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " AND b.org_id='{0}' and a.part_no='{1}' and a.genitemcatgrp<>'zslb' " & _
        '                                       " {2}", _
        '                                       HttpContext.Current.Session("org_id"), part_no, _
        '                                       IIf(False, "", "and  GENITEMCATGRP  <> 'ZSWL' and (a.MATERIAL_GROUP not in ('968MS','96SW','206') OR a.PART_NO LIKE '968T%')")
        '                                       )


        '=================Ryan Comment out for 20161007 changement================================
        'Dim checksql As String = String.Format(" select a.part_no from SAP_PRODUCT a inner join SAP_PRODUCT_ORG b on a.part_no=b.part_no " & _
        '                                       " inner join SAP_PRODUCT_STATUS_ORDERABLE c on  c.PART_NO = a.PART_NO  and c.SALES_ORG = b.ORG_ID " & _
        '                                       " where c.PRODUCT_STATUS IN " + ConfigurationManager.AppSettings("CanOrderProdStatus") + " AND b.org_id='{0}' and a.part_no='{1}' " & _
        '                                       " and ( " & _
        '                                       "       ( " & _
        '                                       "         a.genitemcatgrp NOT IN ('zslb','ZSWL') " & _
        '                                       "         and " & _
        '                                       "         a.MATERIAL_GROUP not in ('968MS','96SW','206','968MS/SW') " & _
        '                                       "       ) " & _
        '                                       "       OR a.PART_NO LIKE '968T%' " & _
        '                                       "     ) ", _
        '                                       HttpContext.Current.Session("org_id"), part_no)


        'Dim fdt As DataTable = dbUtil.dbGetDataTable("MY", checksql)
        ''Dim fdt As DataTable = dbUtil.dbGetDataTable("MY", String.Format("select a.PART_NO, a.PRODUCT_STATUS  from SAP_PRODUCT_STATUS a inner join SAP_DIMCOMPANY b on a.SALES_ORG=b.ORG_ID  where a.PART_NO='{1}' and b.COMPANY_ID='{0}' and a.PRODUCT_STATUS in ('A','N','H')", HttpContext.Current.Session("company_id"), part_no))
        'If fdt.Rows.Count = 0 Then
        '    'Ming 20150804 US01下如果产品status为空，也可以添加到cart
        '    If ORG_ID.Equals("US01", StringComparison.InvariantCultureIgnoreCase) Then
        '        Dim statusX As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format(" select nvl(a.vmsta,'')  as status_code  from  saprdp.MVKE a  where  a.matnr='{0}' and a.vkorg='{1}' and rownum=1", part_no, ORG_ID))
        '        If statusX IsNot Nothing AndAlso String.IsNullOrEmpty(statusX.ToString().Trim()) Then
        '            Return True
        '        End If
        '    End If
        '    '{ Ming add 20131223 如果local Tables找不到此料号，就执行一次同步
        '    'Dim PNSYNC As New SAPDAL.syncSingleProduct
        '    Dim PNA As New ArrayList : PNA.Add(part_no)
        '    SAPDAL.syncSingleProduct.syncSAPProduct(PNA, ORG_ID.Substring(0, 2), False, strStatusDesc, False)
        '    fdt = dbUtil.dbGetDataTable("MY", checksql)
        '    If fdt.Rows.Count = 0 Then
        '        Return False
        '    End If
        '    '} end
        'End If
        '===============================End Ryan Comment out==================================


        'Ryan 20161007 Change MS SW check to new function isMSSWParts in PartBusinessLogic
        'Ryan 20170712 ACN won't need MS SW validation
        If ORG_ID.ToUpper.StartsWith("CN") Then

            'Ryan 20171120 Status O is no longer orderable for ACN
            If strStatusCode.Equals("O") Then Return False

        Else
            Dim PartList As New List(Of String)({part_no})
            Dim InvalidList As List(Of String) = Advantech.Myadvantech.Business.PartBusinessLogic.isMSSWParts(PartList, HttpContext.Current.Session("org_id"))

            If InvalidList.Count > 0 Then
                If ORG_ID.Equals("US01", StringComparison.InvariantCultureIgnoreCase) Then
                    Dim statusX As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", String.Format(" select nvl(a.vmsta,'')  as status_code  from  saprdp.MVKE a  where  a.matnr='{0}' and a.vkorg='{1}' and rownum=1", part_no, ORG_ID))
                    If statusX IsNot Nothing AndAlso String.IsNullOrEmpty(statusX.ToString().Trim()) Then
                        Return True
                    End If
                End If

                Dim PNA As New ArrayList : PNA.Add(part_no)
                SAPDAL.syncSingleProduct.syncSAPProduct(PNA, ORG_ID.Substring(0, 2), False, strStatusDesc, False)
                InvalidList = Advantech.Myadvantech.Business.PartBusinessLogic.isMSSWParts(PartList, HttpContext.Current.Session("org_id"))
                If InvalidList.Count > 0 Then
                    Return False
                End If
            End If
        End If



        If Left(UCase(part_no), 2) <> "T-" And Left(UCase(part_no), 2) <> "W-" And Right(UCase(part_no), 3) <> "-ES" And _
        IsOEM(part_no) = False And Not Global_Inc.IsNonStandardPTrade(part_no) Then
            'l_strSQLCmd = "select * from product where part_no='" & part_no & "'" ' And (IsNull(certificate,1) not like '%CTOS%' and IsNull(certificate,1) not like '%BTOS%') "
            Return True
        Else
            '---{2005-12-27}--Daive: Only SA can add T- and W- item into cart
            '------------------------------------------------------------------
            If (Left(UCase(part_no), 2) = "T-" Or Left(UCase(part_no), 2) = "W-" Or Right(UCase(part_no), 3) = "-ES" Or
                Left(UCase(part_no), 3) = "ES-" Or IsOEM(part_no)) And
                (Util.IsAEUIT() Or Util.IsInternalUser2() Or ORG_ID.ToUpper.StartsWith("CN")) Then
                'l_strSQLCmd = "select * from product where part_no='" & part_no & "' And (IsNull(certificate,1) not like '%CTOS%' and IsNull(certificate,1) not like '%BTOS%') "
                Return True
                'HttpContext.Current.Response.Write("82"):response.end
            Else
                'Response.Redirect("/cart/cart_list.asp")
                Return False
            End If
        End If
        'sqlConn.Close()
    End Function
    Public Shared Function getSalesEmployeeList(ByVal ORGID As String, ByVal SoldToERPID As String) As DataTable

        Dim _IsUSAOnline As Boolean = AuthUtil.IsUSAonlineSales(HttpContext.Current.User.Identity.Name)

        If AuthUtil.IsUSAonlineSales(HttpContext.Current.User.Identity.Name) Then
            'Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetUSAonlineSalesEmployee(SoldToERPID, HttpContext.Current.User.Identity.Name)
            Dim dt1 As DataTable = Nothing : Dim dt2 As DataTable = Nothing : Dim dt3 As DataTable = Nothing
            Dim _dttotal As New DataTable

            _dttotal.Columns.Add("SALES_CODE")
            _dttotal.Columns.Add("FULL_NAME")
            _dttotal.PrimaryKey = New DataColumn() {_dttotal.Columns("SALES_CODE")}

            If MailUtil.IsInMailGroup("AOnline.USA", HttpContext.Current.User.Identity.Name) Then
                dt1 = Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetUSAonlineSalesEmployee(Advantech.Myadvantech.DataAccess.AOnlineRegion.AUS_AOnline, SoldToERPID)
            End If
            If MailUtil.IsInMailGroup("Aonline.USA.IAG", HttpContext.Current.User.Identity.Name) Then
                dt2 = Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetUSAonlineSalesEmployee(Advantech.Myadvantech.DataAccess.AOnlineRegion.AUS_AOnline_IAG, SoldToERPID)
            End If
            If MailUtil.IsInMailGroup("Aonline.USA.iSystem", HttpContext.Current.User.Identity.Name) Then
                dt3 = Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetUSAonlineSalesEmployee(Advantech.Myadvantech.DataAccess.AOnlineRegion.AUS_AOnline_iSystem, SoldToERPID)
            End If
            'If dt1 IsNot Nothing AndAlso dt1.Rows.Count > 0 AndAlso dt2 IsNot Nothing AndAlso dt2.Rows.Count > 0 Then
            '    dt1.PrimaryKey = New DataColumn() {dt1.Columns("sale_id")}
            '    dt1.Merge(dt2)
            '    Return dt1
            'End If
            'If dt1 IsNot Nothing AndAlso dt1.Rows.Count > 0 AndAlso (dt2 Is Nothing OrElse dt2.Rows.Count = 0) Then
            '    Return dt1
            'End If
            'If dt2 IsNot Nothing AndAlso dt2.Rows.Count > 0 AndAlso (dt1 Is Nothing OrElse dt1.Rows.Count = 0) Then
            '    Return dt2
            'End If

            If dt1 IsNot Nothing AndAlso dt1.Rows.Count > 0 Then
                _dttotal.Merge(dt1)
            End If
            If dt2 IsNot Nothing AndAlso dt2.Rows.Count > 0 Then
                _dttotal.Merge(dt2)
            End If
            If dt3 IsNot Nothing AndAlso dt3.Rows.Count > 0 Then
                _dttotal.Merge(dt3)
            End If
            dt1 = Nothing : dt2 = Nothing : dt3 = Nothing
            _dttotal.DefaultView.Sort = "FULL_NAME"
            Return _dttotal.DefaultView.ToTable()

        End If

        'Frank 20150427 When ATW OP team place order, show all the sales. 
        'When ATW AOnline team place order, only show all AOnline sales
        'If String.Equals(ORGID, "TW01", StringComparison.CurrentCultureIgnoreCase) AndAlso SAPDOC.IsATWCustomer() Then
        '    Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetTWAonlineSalesEmployee(SoldToERPID)
        '    'Return getSalesEmployeeListForTWCustomer()
        'End If

        'Ryan 20160621 Validate if is TWA ONLINE or not. 
        If String.Equals(ORGID, "TW01", StringComparison.CurrentCultureIgnoreCase) AndAlso SAPDOC.IsATWCustomer() Then
            If MailUtil.IsTWAOnlineGroup(HttpContext.Current.User.Identity.Name) Then
                Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetTWAonlineSalesEmployee(SoldToERPID)
            Else
                Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetTWSalesEmployee(SoldToERPID)
            End If
        End If

        'Ryan 20170407 ACN Logic 
        If String.Equals(ORGID, "CN10", StringComparison.CurrentCultureIgnoreCase) OrElse
            String.Equals(ORGID, "CN30", StringComparison.CurrentCultureIgnoreCase) OrElse
            String.Equals(ORGID, "CN70", StringComparison.CurrentCultureIgnoreCase) Then
            Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetACNSalesEmployee(ORGID)
        End If

        'Ryan 20170407 ADLOG Logic 
        If String.Equals(ORGID, "EU80", StringComparison.CurrentCultureIgnoreCase) Then
            Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetADLOGSalesEmployee()
        End If

        'Ryan 20170918 BBUS Logic
        If AuthUtil.IsBBUS Then
            Return Advantech.Myadvantech.Business.UserRoleBusinessLogic.GetBBUSSalesEmployee()
        End If

        Dim str As String = " select distinct a.FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL " & _
                            " from SAP_EMPLOYEE a " & _
                            " where a.PERS_AREA like '" & Left(ORGID, 2) & "%' " & _
                            " order by a.FULL_NAME "
        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("B2B", str)
        Return dt
    End Function

    Public Shared Function getSalesEmployeeListForTWCustomer() As DataTable

        'Dim str As String = " select distinct a.SNAME as FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL " & _
        '                    " from SAP_EMPLOYEE a inner join EZ_EMPLOYEE b on a.EMAIL=b.EMAIL_ADDR " & _
        '                    " where a.PERS_AREA like 'TW%' " & _
        '                    " and SALES_CODE between '11000000' and '11999999' " & _
        '                    " order by a.SALES_CODE "

        Dim sqlstr As New StringBuilder
        sqlstr.AppendLine(" select distinct a.SNAME as FULL_NAME, a.SALES_CODE, IsNull(a.EMAIL,'') as EMAIL ")
        sqlstr.AppendLine(" From ATW_Aonline_SalesEmployee c inner join SAP_EMPLOYEE a on c.SALES_CODE=a.SALES_CODE ")
        sqlstr.AppendLine(" inner join EZ_EMPLOYEE b on a.EMAIL=b.EMAIL_ADDR ")
        sqlstr.AppendLine(" where a.PERS_AREA like 'TW%' ")
        'sqlstr.AppendLine(" and SALES_CODE between '11000000' and '11999999' ")
        'sqlstr.AppendLine(" and SALES_CODE between '11100001' and '11339999' ")
        'sqlstr.AppendLine(" and SALES_CODE not in (")
        'sqlstr.AppendLine("'11000003'")
        'sqlstr.AppendLine(",'11000009'")
        'sqlstr.AppendLine(",'11100001'")
        'sqlstr.AppendLine(",'11100002'")
        'sqlstr.AppendLine(",'11100003'")
        'sqlstr.AppendLine(",'11100006'")
        'sqlstr.AppendLine(",'11111115'")
        'sqlstr.AppendLine(",'11111118'")
        'sqlstr.AppendLine(",'11120104'")
        'sqlstr.AppendLine(",'11120106'")
        'sqlstr.AppendLine(",'11120108'")
        'sqlstr.AppendLine(",'11131002'")
        'sqlstr.AppendLine(",'11132003'")
        'sqlstr.AppendLine(",'11133003'")
        'sqlstr.AppendLine(",'11133005'")
        'sqlstr.AppendLine(",'11136005'")
        ''sqlstr.AppendLine(",'11136016'")
        'sqlstr.AppendLine(",'11136017'")
        'sqlstr.AppendLine(",'11136018'")
        'sqlstr.AppendLine(",'11136019'")
        'sqlstr.AppendLine(",'11150003'")
        'sqlstr.AppendLine(",'11150006'")
        'sqlstr.AppendLine(",'11160004'")
        'sqlstr.AppendLine(",'11220302'")
        'sqlstr.AppendLine(",'11230003')")
        sqlstr.AppendLine(" order by a.SALES_CODE ")


        Dim dt As New DataTable
        'dt = dbUtil.dbGetDataTable("B2B", str)
        dt = dbUtil.dbGetDataTable("B2B", sqlstr.ToString)
        Return dt
    End Function


    Public Shared Function IsOEM(ByVal item_no As String) As Boolean
        Dim rs As New DataTable
        rs = dbUtil.dbGetDataTable("RFM", "select IsNull(MATERIAL_GROUP,'') as material_group from sap_product where part_no='" & item_no.ToString().Trim() & "'")
        If rs.Rows.Count > 0 Then
            If Trim(rs.Rows(0).Item("MATERIAL_GROUP")) = "T" Then 'OR Trim(rs.Rows(0).Item("MATERIAL_GROUP")) = "ODM" Then
                IsOEM = True
            Else
                IsOEM = False
            End If
        Else
            IsOEM = False
        End If
    End Function


    Public Shared Function GetQuoteHeader(ByVal quote_id As String, ByRef strHTML As String)
        Dim quote_to, quote_date, del_date, ship_term, exp_date, payment, sales_contact, sales_phone, quote_note, quote_to_contact
        Dim Enquote_to, Enquote_date, Endel_date, Enship_term, Enexp_date, Enpayment, Ensales_contact, Ensales_phone, Enquote_note, Enquote_no, Ensales_email, Enquote_header, EnrelatedInfo
        Dim strSQL As String = "", quote_no As String = "", sales_email As String = "", table As String = "quotation_master"
        If HttpContext.Current.Request("flg") = "history" Then
            table = "quotation_master_history"
        End If
        strSQL = "select * from " & table & " where quote_id='" & quote_id & "'"

        Dim quote_language = dbUtil.dbExecuteScalar("B2B", "select quote_language from " & table & " where quote_id='" & quote_id & "'")
        Dim en As DataTable = dbUtil.dbGetDataTable("B2B", "select * from quote_language where quote_language='" & quote_language & "'")
        If en.Rows.Count > 0 Then
            Enquote_to = en.Rows(0).Item("customer_name")
            Enquote_date = en.Rows(0).Item("create_date")
            Endel_date = en.Rows(0).Item("del_date")
            Enship_term = en.Rows(0).Item("shipping_terms")
            Enexp_date = en.Rows(0).Item("exp_date")
            Enpayment = en.Rows(0).Item("payment_terms")
            Ensales_contact = en.Rows(0).Item("sales_contact")
            Ensales_phone = en.Rows(0).Item("tel_num")
            Enquote_note = en.Rows(0).Item("quote_note")
            Enquote_no = en.Rows(0).Item("quote_no")
            Ensales_email = en.Rows(0).Item("sales_email")

            Enquote_header = en.Rows(0).Item("quote_name")
            EnrelatedInfo = en.Rows(0).Item("related information")
        End If
        Dim g_adoConn As New System.Data.SqlClient.SqlConnection
        Dim l_adoR As DataTable = dbUtil.dbGetDataTable("B2B", strSQL)
        If l_adoR.Rows.Count > 0 Then
            quote_to = l_adoR.Rows(0).Item("quote_to_company")
            quote_date = l_adoR.Rows(0).Item("quote_date")
            del_date = l_adoR.Rows(0).Item("del_date")
            ship_term = l_adoR.Rows(0).Item("ship_term")
            exp_date = l_adoR.Rows(0).Item("exp_date")
            payment = l_adoR.Rows(0).Item("paymentterm")
            sales_contact = l_adoR.Rows(0).Item("sales_contact")
            sales_phone = l_adoR.Rows(0).Item("sales_phone")
            quote_note = l_adoR.Rows(0).Item("quote_note")
            quote_no = l_adoR.Rows(0).Item("quote_no")
            quote_to_contact = l_adoR.Rows(0).Item("quote_to_contact")
            sales_email = l_adoR.Rows(0).Item("sales_email")
        End If
        Dim l_strHTML2 As String = ""
        l_strHTML2 = l_strHTML2 & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML2 = l_strHTML2 & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#ffffff""><b>" & Enquote_header & "</b></font></td></tr>" 'Quotation Header
        l_strHTML2 = l_strHTML2 & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"
        l_strHTML2 = l_strHTML2 & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Enquote_to & "&nbsp;&nbsp;</font></b></td>"  'Quote To
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & quote_to & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Enquote_date & "&nbsp;&nbsp;</font></b></td>"  'Quote Date
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(quote_date) & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Endel_date & " &nbsp;&nbsp;</font></b></td>" 'Delivery Date
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(del_date) & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Enquote_no & "&nbsp;&nbsp;</font></b></td>" 'Quote Number
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & quote_no & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Enship_term & "&nbsp;&nbsp;</font></b></td>" 'Shipping Terms
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & ship_term & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Enexp_date & "&nbsp;&nbsp;</font></b></td>" 'Exp.Date
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & Global_Inc.FormatDate(exp_date) & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Enpayment & "&nbsp;</font></b></td>"     'Payment Terms
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & payment & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Ensales_contact & "&nbsp;&nbsp;</font></b></td>" 'Sales Contact
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & sales_contact & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""10"" align =""right"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Ensales_phone & "&nbsp;&nbsp;</font></b></td>" 'Direct Phone
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & sales_phone & "</font></td>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" height=""10"" >"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Ensales_email & "&nbsp;&nbsp;</font></b></td>" 'Sales Email
        l_strHTML2 = l_strHTML2 & "<td width=""35%""  bgcolor=""#FFFFFF"">"
        l_strHTML2 = l_strHTML2 & "<font color=""#333333"">&nbsp;" & sales_email & "</font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"


        'other info
        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""top"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & EnrelatedInfo & "&nbsp;&nbsp;</font></b></td>" 'Related Information
        l_strHTML2 = l_strHTML2 & "<td  colspan=""3"" bgcolor=""#FFFFFF"" valign=""top"">"
        l_strHTML2 = l_strHTML2 & "  &nbsp;<b>1.&nbsp;&nbsp;<a href='../Order/Terms.aspx'>Advantech Terms and Conditions</a></b><br />"
        l_strHTML2 = l_strHTML2 & "                                       &nbsp;<b>2.&nbsp;&nbsp;<a href='../Quote/rmaPolicy/rma_english.htm'>Advantech Warranty Policy</a></b></td>"

        l_strHTML2 = l_strHTML2 & "</tr>"

        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""right"" valign=""top"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">Quote to Contact &nbsp;&nbsp;</font></b></td>" 'Quote Note
        l_strHTML2 = l_strHTML2 & "<td  colspan=""3"" bgcolor=""#FFFFFF"" valign=""top"">"
        l_strHTML2 = l_strHTML2 & "<font color=""red""><b>" & Global_Inc.HTMLEncode(quote_to_contact) & "</b></font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"

        l_strHTML2 = l_strHTML2 & "<tr>"
        l_strHTML2 = l_strHTML2 & "<td width=""15%"" bgcolor=""#F0F0F0"" height=""50"" align =""right"" valign=""top"">"
        l_strHTML2 = l_strHTML2 & "<b><font color=""#333333"">" & Enquote_note & "&nbsp;&nbsp;</font></b></td>" 'Quote Note
        l_strHTML2 = l_strHTML2 & "<td  colspan=""3"" bgcolor=""#FFFFFF"" valign=""top"">"
        l_strHTML2 = l_strHTML2 & "<font color=""red""><b>" & Global_Inc.HTMLEncode(quote_note) & "</b></font></td>"
        l_strHTML2 = l_strHTML2 & "</tr>"

        '---------------------------------------------------------------------------------------------
        l_strHTML2 = l_strHTML2 & "</table>"
        l_strHTML2 = l_strHTML2 & "</td></tr></table><br />"

        strHTML = l_strHTML2

        Return 1
    End Function

    'Jackie  Add for print component quotation
    Public Shared Function QuoteList(ByVal StrID, ByRef strHTML)
        Dim g_adoConn As New System.Data.SqlClient.SqlConnection
        Dim l_strHTML3 As String = "", strSQL As String = ""

        ' get detail
        Dim table As String = "quotation_master", table_detail As String = "quotation_detail"
        If HttpContext.Current.Request("flg") = "history" Then
            table = "quotation_master_history"
            table_detail = "quotation_detail_history"
        End If
        'get the language
        'Part No. Description List Price Disc Unit Price QTY Due Date Sub Total 
        Dim Enpart_no As String = "", Endesc As String = "", Enlist_price As String = "", Enunit_price As String = "", Endisc As String = "", _
            Enqty As String = "", Endue_date As String = "", Ensub_total As String = "", Entotal As String = ""
        Dim quote_language = dbUtil.dbExecuteScalar("B2B", "select quote_language from " & table & " where quote_id='" & StrID & "'")
        Dim en As DataTable = dbUtil.dbGetDataTable("B2B", "select * from quote_language where quote_language='" & quote_language & "'")
        If en.Rows.Count > 0 Then
            Enpart_no = en.Rows(0).Item("product")
            Endesc = en.Rows(0).Item("product_desc")
            Enlist_price = en.Rows(0).Item("list_price")
            Enunit_price = en.Rows(0).Item("unit_price")
            Endisc = en.Rows(0).Item("discount")
            Enqty = en.Rows(0).Item("quantity")
            Endue_date = en.Rows(0).Item("due_date")
            Ensub_total = en.Rows(0).Item("subtotal")
            Entotal = en.Rows(0).Item("total")
        End If
        'l_strHTML3 = l_strHTML3 & "<link href=""http://b2b.advantech-nl.nl/includes/layout/eBizStyle.css"" rel=""stylesheet"">"
        l_strHTML3 = l_strHTML3 & "<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">"
        l_strHTML3 = l_strHTML3 & "<tr><td style=""padding-left:10px;border-bottom:#ffffff 1px solid"" valign=""middle"" height=""20"" bgcolor=""#6699CC"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#ffffff""><b>" & Enpart_no & "</b></font></td></tr>" 'Product List
        l_strHTML3 = l_strHTML3 & "<tr><td bgcolor=""#BEC4E3"" height=""17"" style=""border:#CFCFCF 1px solid"" >"


        l_strHTML3 = l_strHTML3 & "<table width=""100%"" border=""0"" cellspacing=""1"" cellpadding=""2"" height=""17"">"
        l_strHTML3 = l_strHTML3 & "<tr>"
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>No</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>" & Enpart_no & "</b></font></td>" 'Part No.
        l_strHTML3 = l_strHTML3 & "<td width=""25%"" bgcolor=""#F0F0F0""  align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>" & Endesc & "</b></font></td>" 'Description
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>" & Enlist_price & "</b></font></td>" 'List Price
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>" & Endisc & "</b></font></td>" 'Disc
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>" & Enunit_price & "</b></font></td>" 'Unit Price
        l_strHTML3 = l_strHTML3 & "<td width=""5%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>" & Enqty & "</b></font></td>" 'Qty
        'l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""F0F0F0"" align =""center"">"
        'l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""left""><b>Availability</b></font></td>"
        l_strHTML3 = l_strHTML3 & "<td width=""10%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333"" align =""left""><b>" & Endue_date & "</b></font></td>" 'Due Date
        l_strHTML3 = l_strHTML3 & "<td width=""15%"" bgcolor=""#F0F0F0"" align =""center"">"
        l_strHTML3 = l_strHTML3 & "<font color=""#333333""><b>" & Ensub_total & "</b></font></td>" 'Subtotal
        l_strHTML3 = l_strHTML3 & "</tr>"

        Dim strCurrency = HttpContext.Current.Session("COMPANY_CURRENCY")
        Dim strCurrSign = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN")
        strSQL = "select distinct q.line_no, q.part_no as part_no,max(isnull(p.product_desc,'')) as pro_desc,q.list_price,q.unit_price,q.qty,q.atp_num,q.atp_date from " & table_detail & " q inner join product p on q.part_no=p.part_no and q.quote_id='" & StrID & "' group by q.line_no,q.part_no,list_price,unit_price,qty,atp_num,atp_date"

        Dim l_adoR As DataTable = dbUtil.dbGetDataTable("B2B", strSQL)
        Dim intX = 0
        Dim total = 0
        Dim tbd_flg As Boolean = False
        For Each r As DataRow In l_adoR.Rows
            intX = intX + 1
            If r.Item("unit_price") <= 0 Then
                l_strHTML3 = l_strHTML3 & "<tr style=""BACKGROUND-COLOR: #ccffff;WIDTH=100%"">"
            Else
                l_strHTML3 = l_strHTML3 & "<tr>"
            End If
            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            '            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & intX & "&nbsp;</font></td>"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & r.Item("line_no") & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""15%""  align =""left"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & UCase(r.Item("part_no")) & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""20%""  align =""left"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & UCase(r.Item("pro_desc")) & "&nbsp;</font></td>"

            Dim RBUMailFormat As String = "", list_price As String = "", disc As String = ""
            If CLng(r.Item("list_price")) = -1 Then
                If Global_Inc.IsRBU(HttpContext.Current.Session("company_id"), RBUMailFormat) Then
                    list_price = "N/A"
                Else
                    list_price = "TBD"
                End If
            Else
                list_price = strCurrSign & FormatNumber(r.Item("list_price"))
            End If
            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & list_price & "&nbsp;</font></td>"

            If r.Item("list_price") <= 0 Then
                disc = "--%"
            Else
                If CLng((1 - (r.Item("unit_price") / r.Item("list_price"))) * 100) >= 0 And _
                CLng((1 - (r.Item("unit_price") / r.Item("list_price"))) * 100) <= 100 Then
                    disc = CLng((1 - (r.Item("unit_price") / r.Item("list_price"))) * 100) & "%"
                Else
                    disc = 100 & "%"
                End If
            End If

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & disc & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            If CDbl(r.Item("unit_price")) < 0 Then
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & "TBD" & "&nbsp;</font></td>"
                tbd_flg = True
            Else
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & strCurrSign & _
                FormatNumber(r.Item("unit_price")) & "&nbsp;</font></td>"
            End If

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & r.Item("qty") & "&nbsp;</font></td>"

            'l_strHTML3 = l_strHTML3 & "<td bgcolor=""FFFFFF"" width=""5%""  align =""right"">"
            'l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & l_adoRs("atp_num") & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""middle"">"
            l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & Global_Inc.FormatDate(r.Item("atp_date")) & "&nbsp;</font></td>"

            l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" width=""5%""  align =""right"">"
            If CDbl(r.Item("unit_price")) >= 0 Then
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & strCurrSign & _
                FormatNumber(CDbl(r.Item("unit_price")) * CInt(r.Item("qty"))) & "&nbsp;</font></td>"
            Else
                l_strHTML3 = l_strHTML3 & "<font color=""#333333"">" & "TBD" & "&nbsp;</font></td>"
            End If
            If CDbl(r.Item("unit_price")) > 0 Then
                total = total + CDbl(r.Item("unit_price")) * CInt(r.Item("qty"))
            End If
        Next

        l_strHTML3 = l_strHTML3 & "<tr>"
        l_strHTML3 = l_strHTML3 & "<td bgcolor=""#FFFFFF"" colspan=""10""  align =""right"">"
        If total <= 0 Then
            l_strHTML3 = l_strHTML3 & "<font  color=""#333333""><b>(" & strCurrency & ") " & Entotal & ":&nbsp;TBD</b></font></td>"
        ElseIf tbd_flg = True Then
            l_strHTML3 = l_strHTML3 & "<font  color=""#333333""><b>(" & strCurrency & ")" & Entotal & ":&nbsp;" & strCurrSign & FormatNumber(total, 2) & " + TBD</b></font></td>"
        Else
            l_strHTML3 = l_strHTML3 & "<font  color=""#333333""><b>(" & strCurrency & ") " & Entotal & ":&nbsp;" & strCurrSign & FormatNumber(total, 2) & "</b></font></td>"
        End If

        l_strHTML3 = l_strHTML3 & "</tr>"
        l_strHTML3 = l_strHTML3 & "</table>"
        l_strHTML3 = l_strHTML3 & "</td></tr></table>" & "<br>"
        strHTML = l_strHTML3
        Return 1
    End Function

    Public Shared Function GetB2bStyle() As String
        Dim strStyle As String = "<style>"
        strStyle = strStyle & "BODY,TD,INPUT,SELECT,TEXTAREA {FONT-SIZE: 8pt;FONT-FAMILY: Arial,Helvetica,Sans-Serif} "
        strStyle = strStyle & "A, A:visited {COLOR: #6666cc;TEXT-DECORATION: none} "
        strStyle = strStyle & "A:active  {TEXT-DECORATION: none} "
        strStyle = strStyle & "A:hover   {TEXT-DECORATION: underline} "
        'strStyle = strStyle & "</style>"

        strStyle = strStyle & ".List_Corp 						{BACKGROUND-COLOR: #ffffff ; COLOR: #ffffff; }"
        strStyle = strStyle & ".List_Corp .AppletBlank			{BACKGROUND-COLOR: #ffffff}"
        strStyle = strStyle & ".List_Corp .AppletTitle ,   "
        strStyle = strStyle & ".List_Corp .AppletTitle A ,"
        strStyle = strStyle & ".List_Corp .AppletTitle A:link ,"
        strStyle = strStyle & ".List_Corp .AppletTitle A:visited ,"
        strStyle = strStyle & ".List_Corp .AppletTitle A:hover	{FONT-WEIGHT: bold;FONT-SIZE: 10pt;COLOR: #FFFFFF;BACKGROUND-COLOR: #4F5FB1;TEXT-DECORATION: none}"
        strStyle = strStyle & ".List_Corp .AppletBack			{BACKGROUND-COLOR: #4F5FB1 }"
        strStyle = strStyle & ".List_Corp .AppletBorder		{ }	  "
        strStyle = strStyle & ".List_Corp .AppletButtons		{COLOR: #ffffff;BACKGROUND-COLOR: #4F5FB1; }"
        strStyle = strStyle & ".List_Corp .PageInfo 			{FONT-SIZE: 12px; BACKGROUND-COLOR: #4F5FB1 }"
        strStyle = strStyle & ".List_Corp .TableBorder 		{background-color: #BEC4E3;}"
        strStyle = strStyle & ".List_Corp .Header				{background-color:#f0f0f0; border:1px solid silver; border-top:none; border-right:none; color:black; cursor:default; font:8pt arial; font-weight:bold; padding-left:3px; padding-right:3px; }"
        strStyle = strStyle & ".List_Corp TR.listRowOff TD.Row	{BACKGROUND-COLOR: #FFFFFF;border:1px solid silver;border-top:none;border-right:none;cursor:default;padding-left:3px;padding-right:3px }"
        strStyle = strStyle & ".List_Corp TR.listRowOn  TD.Row	{BACKGROUND-COLOR: #efef99;border:1px solid silver;border-top:none;border-right:none;cursor:default;padding-left:3px;padding-right:3px }"
        strStyle = strStyle & "</style>"
        Return strStyle
    End Function

    Public Shared Function SAPDate2StdDate1(ByVal sapDateString As String, ByRef Res As String) As Date

        If sapDateString.Length <> 8 Then
            Exit Function
        End If
        Dim Y, M, D As String
        If sapDateString = "2" Then
        End If
        Try
            Y = Left(sapDateString, 4)
            M = Mid(sapDateString, 5, 2)
            D = Right(sapDateString, 2)
            Res = Y & "/" & M & "/" & D
            HttpContext.Current.Response.Write("x")
            HttpContext.Current.Response.End()
            Dim stdDate As Date = CDate(Y & "/" & M & "/" & D)
            Return stdDate
        Catch ex As Exception
            Exit Function
        End Try

    End Function
    Shared Function IsGA(ByVal Company_Code As String) As Boolean
        Dim GroupName As String = Company_getGroup(Company_Code)
        If GroupName <> "" Then
            If GroupName = "eP GA" Or GroupName = "GA eAutomation" Then
                Return True
            End If
        End If
        Return False
    End Function
    Shared Function Company_getGroup(ByVal Company_Code As String) As String
        Dim Group_id As Object = dbUtil.dbExecuteScalar("B2B", "Select SalesGroup from sap_dimcompany where company_id='" & Company_Code & "'")
        If Group_id IsNot Nothing AndAlso Group_id.ToString <> "" Then
            Select Case Group_id.ToString
                Case "310"
                    Return "PKA eAutomation"
                Case "311"
                    Return "PCP eAutomation"
                Case "312"
                    Return "KA eAutomation"
                Case "313"
                    Return "Dist eAutomation"
                Case "314"
                    Return "SI eAutomation"
                Case "315"
                    Return "GA eAutomation"
                Case "320"
                    Return "eP PCP"
                Case "321"
                    Return "eP CSF"
                Case "322"
                    Return "eP GA"
                Case "323"
                    Return "eP KA Embedded"
                Case "324"
                    Return "eP KA Medical"
                Case "325"
                    Return "eP KA Telecom"
                Case Else
                    Return ""
            End Select
        End If
        Return ""
    End Function
    'Debug Tool
    Shared Function getDTHtml(ByVal ODT As DataTable) As String
        Dim str As String = "<table border=""1""><tr>"
        For i As Integer = 0 To ODT.Columns.Count - 1
            str &= "<td>" & ODT.Columns(i).Caption & "</td>"
        Next
        str &= "</tr>"

        For j As Integer = 0 To ODT.Rows.Count - 1
            str &= "<tr>"
            For k As Integer = 0 To ODT.Columns.Count - 1
                str &= "<td>"
                str &= ODT.Rows(j)(k)
                str &= "<br/></td>"
            Next
            str &= "</tr>"
        Next
        str &= "</table>"
        Return str
    End Function
    Shared Function showDT(ByVal ODT As DataTable) As String
        HttpContext.Current.Response.Write("<table border=""1""><tr>")
        For i As Integer = 0 To ODT.Columns.Count - 1
            HttpContext.Current.Response.Write("<td>" & ODT.Columns(i).Caption & "</td>")
        Next
        HttpContext.Current.Response.Write("</tr>")

        For j As Integer = 0 To ODT.Rows.Count - 1
            HttpContext.Current.Response.Write("<tr>")
            For k As Integer = 0 To ODT.Columns.Count - 1
                HttpContext.Current.Response.Write("<td>")
                HttpContext.Current.Response.Write(ODT.Rows(j)(k))
                HttpContext.Current.Response.Write("<br/></td>")
            Next
            HttpContext.Current.Response.Write("</tr>")
        Next
        HttpContext.Current.Response.Write("</table>")
        Return "ok"
    End Function



    '---<eQuotation>

    Public Shared Function GetDueDate(ByVal company_id As String, ByVal partNO As String, _
                                     ByVal QTY As String, ByVal requiredDate As String, _
                                     ByRef dueDate As String, ByRef atpQTY As String) As Integer
        Dim dt As New DataTable
        Dim iRet As Integer
        'Dim WS As New B2B_AEU_WS.B2B_AEU_WS 'B2B_AEU_WS.B2B_AEU_WS 'B2B_AEU_WS.B2B_AEU_WS
        'WS.Url = ConfigurationManager.ConnectionStrings("B2B-AEU-WS").ToString()
        Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
        ws.Url = ConfigurationManager.AppSettings("aeu_ebus_dev9000.b2b_sap_ws").ToString
        ws.Timeout = 999999
        iRet = initRsATP(dt, "EUH1", partNO, QTY, requiredDate, "PC")
        Dim xmlInput As String = Global_Inc.DataTableToADOXML(dt)
        Dim xmlout As String = ""
        Dim xmlLog As String = ""
        iRet = ws.GetMultiDueDate(UCase(company_id), UCase(company_id), "EU10", "10", "00", xmlInput, xmlout, xmlLog)
        'If HttpContext.Current.Session("user_id").ToString.ToLower() = "nada.liu@advantech.com.cn" Then
        '    HttpContext.Current.Response.Write("xml:" & xmlInput & "<br>" & xmlout)
        '    HttpContext.Current.Response.End()
        'End If



        If iRet = -1 Then
            '---- ERROR HANDEL ----'
            HttpContext.Current.Response.Write("Calling SAP function Error!<br>" & xmlLog & "<br>")
            Return 0
        Else
            If partNO.Contains("|") Then
                'Response.Write("xml:" & xmlInput & "<br>" & xmlout)
                'Response.End()
                Dim tmpDt As DataTable = Util.ADOXml2DataTable(xmlout)
                'Dim gv1 As New WebControls.GridView
                'gv1.DataSource = tmpDt
                'gv1.DataBind()
                'Response.Write(SysUtil.GetHtmlOfControl(gv1))
                'Response.End()
                If Not tmpDt Is Nothing Then
                    Dim MaxDue As Date = Now()
                    Dim tmpItem() As String = Split(partNO, "|")
                    For Each item As String In tmpItem
                        'Response.Write("handling:" + Trim(item) + "<br/>")
                        Try
                            Dim selDt As DataTable = tmpDt.Copy()
                            selDt.DefaultView.RowFilter = "part='" + Trim(item) + "' and qty_fulfill>=" + QTY
                            selDt = selDt.DefaultView.ToTable()
                            If selDt.Rows.Count > 0 Then
                                If DateDiff( _
                                DateInterval.Day, MaxDue, _
                                selDt.Rows(0).Item("date") _
                                ) > 0 Then
                                    MaxDue = selDt.Rows(0).Item("date")
                                    'Response.Write(MaxDue.ToShortDateString() + "<br/>")
                                End If
                            Else
                                'jackie add 20071206 for Z1 issue
                                Dim tempMaxDue As Date = Global_Inc.GetRPL(company_id, item, Today)
                                If DateDiff( _
                               DateInterval.Day, MaxDue, _
                               tempMaxDue _
                               ) > 0 Then
                                    MaxDue = tempMaxDue
                                    'Response.Write(MaxDue.ToShortDateString() + "<br/>")
                                End If
                            End If
                        Catch ex As Exception
                            'Response.Write(ex.ToString() + "<br/>")
                        End Try
                    Next
                    dueDate = MaxDue
                    'Response.End()
                Else
                    Dim MaxDue As Date = Now()
                    Dim tmpItem() As String = Split(partNO, "|")
                    For Each item As String In tmpItem
                        dueDate = Global_Inc.GetRPL(company_id, item, Today)
                        If MaxDue < dueDate Then
                            MaxDue = dueDate
                        End If
                    Next
                End If
            Else

                Dim sr As System.IO.StringReader = New System.IO.StringReader(xmlout)
                Dim ds As New DataSet()
                Dim dv As New DataView()
                ds.ReadXml(sr)
                Try
                    'atpQTY = ds.Tables(ds.Tables.Count - 1).Rows(0).Item("qty_atb").ToString() & "(" & Global_Inc.FormatDate(ds.Tables(ds.Tables.Count - 1).Rows(0).Item("date").ToString()) & ")"
                    atpQTY = Global_Inc.FormatDate(ds.Tables(ds.Tables.Count - 1).Rows(0).Item("date").ToString()) & "(" & ds.Tables(ds.Tables.Count - 1).Rows(0).Item("qty_atb").ToString() & ")"
                Catch ex As Exception
                    atpQTY = Global_Inc.FormatDate(System.DateTime.Today) & "(0)"
                End Try
                Dim dtZ1 As DataTable = ds.Tables("row")
                If dtZ1 Is Nothing Then
                    dueDate = Global_Inc.GetRPL(UCase(company_id), partNO, Today)
                Else
                    Try
                        Dim flg As Boolean = False
                        For i As Integer = 0 To dtZ1.Rows.Count - 1
                            If CInt(QTY) <= CInt(dtZ1.Rows(i).Item("qty_atb").ToString()) Then
                                dueDate = dtZ1.Rows(i).Item("date").ToString()
                                flg = True
                                Exit For
                            End If
                        Next
                        If Not flg Then
                            dueDate = Global_Inc.GetRPL(UCase(company_id), partNO, Today)
                            Return 1
                        End If
                        'If CInt(QTY) >= 99999 Then
                        '    dueDate = ds.Tables(ds.Tables.Count - 1).Rows(ds.Tables(ds.Tables.Count - 1).Rows.Count - 1).Item("date").ToString()
                        'End If
                    Catch ex As Exception
                        dueDate = System.DateTime.Today.ToString()
                    End Try
                    dueDate = Global_Inc.FormatDate(dueDate)
                End If
                If Right(atpQTY, 6) = "99999)" Then
                    atpQTY = Global_Inc.FormatDate(System.DateTime.Today) & "(0)"
                End If
                Return 1
            End If
        End If
    End Function


    Public Shared Function QuotationDataTable_Get(ByVal Quote_Id As String, ByRef dtQuoteMaster As DataTable, ByRef dtQuoteDetail As DataTable) As Integer
        QuotationDataTable_Get = 1
        Dim strSQL As String = ""
        strSQL = "select * from Quotation_master where Quote_id = '" & Quote_Id & "'"
        dtQuoteMaster = dbUtil.dbGetDataTable("B2B", strSQL)
        If dtQuoteMaster.Rows.Count < 1 Then
            QuotationDataTable_Get = 0
        Else
            strSQL = "select * from Quotation_detail where Quote_id = '" & Quote_Id & "' order by line_no"
            dtQuoteDetail = dbUtil.dbGetDataTable("B2B", strSQL)
            If dtQuoteDetail.Rows.Count < 1 Then
                QuotationDataTable_Get = 0
            End If
        End If
        Return QuotationDataTable_Get
    End Function
    Public Shared Function QuotationXML_Create(ByVal strOrder_Type As String, ByVal strOrder_Id As String, _
                                               ByVal strOrg_Id As String, ByVal siebel_row_id As String) As Integer
        Dim exeFunc As Integer = 0
        Dim strOrderXml As String = ""
        Dim adoDT_OrderMaster, adoDT_OrderDetail As New DataTable
        exeFunc = QuotationDataTable_Get(strOrder_Id, adoDT_OrderMaster, adoDT_OrderDetail)
        Select Case strOrder_Type
            Case "AG"
                strOrderXml = ""
                '---- header ----'
                strOrderXml = "<Order>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Order_Type>AG</Order_Type>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Sales_Organization>EU10</Sales_Organization>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Distribution_Channel>10</Distribution_Channel>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Division>00</Division>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Sales_Office></Sales_Office>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Delivery_Plant>EUH1</Delivery_Plant>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Credit_Status/>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Delivery_Status/>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Order_Number>" & siebel_row_id & "</Order_Number>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Customer_ID>" & UCase(adoDT_OrderMaster.Rows(0).Item("Quote_to_company_id")) & "</Customer_ID>"

                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Order_Date>" & Global_Inc.FormatDate(adoDT_OrderMaster.Rows(0).Item("quote_date")) & "</Order_Date>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                If adoDT_OrderDetail.Rows(0).Item("line_no") < 100 Then
                    strOrderXml = strOrderXml & "<Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(0).Item("request_date")) & "</Require_Date>"
                Else
                    strOrderXml = strOrderXml & "<Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(0).Item("atp_date")) & "</Require_Date>"
                End If
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                strOrderXml = strOrderXml & "<Ship_Term>" & adoDT_OrderMaster.Rows(0).Item("SHIP_term") & "</Ship_Term>"

                strOrderXml = strOrderXml & Chr(13) & Chr(10)
                strOrderXml = strOrderXml & "<Remarks></Remarks>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                strOrderXml = strOrderXml & "<Comments></Comments>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)


                strOrderXml = strOrderXml & "<Sales_Note>" & adoDT_OrderMaster.Rows(0).Item("Quote_NOTE") & "</Sales_Note>"
                strOrderXml = strOrderXml & Chr(13) & Chr(10)

                If UCase(adoDT_OrderMaster.Rows(0).Item("currency")) Like "EU*" Then
                    strOrderXml = strOrderXml & "<Order_Currency>" & "EUR" & "</Order_Currency>"
                Else
                    If UCase(adoDT_OrderMaster.Rows(0).Item("currency")) Like "US*" Then
                        strOrderXml = strOrderXml & "<Order_Currency>" & "USD" & "</Order_Currency>"
                    Else
                        If UCase(adoDT_OrderMaster.Rows(0).Item("currency")) Like "NT*" Then
                            strOrderXml = strOrderXml & "<Order_Currency>" & "NTD" & "</Order_Currency>"
                        Else
                            strOrderXml = strOrderXml & "<Order_Currency>" & adoDT_OrderMaster.Rows(0).Item("currency") & "</Order_Currency>"
                        End If
                    End If
                End If


                Dim BTOLINE As String = ""
                Dim parentDD_DR As DataTable
                Dim dArray As String()
                Dim compDD As String
                Dim Line_Seq As Integer = 1
                'Jackie add 2007/1/15
                Dim Delivery_Group As Integer = 10, even As Integer = 1
                Do While Line_Seq <= adoDT_OrderDetail.Rows.Count


                    strOrderXml = strOrderXml & Chr(10) & "<Order_Line>"
                    strOrderXml = strOrderXml & "<Order_Number>" & siebel_row_id & "</Order_Number>"
                    strOrderXml = strOrderXml & "<Item_Category />"

                    If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) Mod 100 = 0 Then
                        BTOLINE = adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")
                        strOrderXml = strOrderXml & "<Higher_Level>" & "" & "</Higher_Level>" & Chr(13) & Chr(10)
                        If Global_Inc.IsNumericItem(Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2)) And Not _
                        (adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") Like "96*") Then
                            strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                        Else
                            If Global_Inc.IsPtrade(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                                strOrderXml = strOrderXml & "<Storage_Location>" & "B000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            Else
                                strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            End If
                        End If

                    Else
                        If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) >= 100 Then
                            strOrderXml = strOrderXml & "<Higher_Level></Higher_Level>" & Chr(13) & Chr(10)
                            If Global_Inc.IsNumericItem(Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2)) And _
                            Not (adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") Like "96*") Then
                                strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                            Else
                                If Global_Inc.IsPtrade(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "B000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                Else
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                End If
                            End If

                        Else
                            strOrderXml = strOrderXml & "<Higher_Level>" & "" & "</Higher_Level>" & Chr(13) & Chr(10)
                            If Global_Inc.IsNumericItem(Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2)) And _
                            Not (adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") Like "96*") Then
                                strOrderXml = strOrderXml & "<Storage_Location>" & "" & "</Storage_Location>" & Chr(13) & Chr(10)
                            Else
                                If Global_Inc.IsPtrade(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "P000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                Else
                                    strOrderXml = strOrderXml & "<Storage_Location>" & "0000" & "</Storage_Location>" & Chr(13) & Chr(10)
                                End If
                            End If


                        End If
                    End If
                    strOrderXml = strOrderXml & "<Line>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no") & "</Line>"
                    strOrderXml = strOrderXml & "<Line_Seq>" & Line_Seq & "</Line_Seq>"

                    If Global_Inc.IsNumericItem(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Then
                        strOrderXml = strOrderXml & "<Item_Number>" & "00000000" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") & "</Item_Number>"
                    Else
                        strOrderXml = strOrderXml & "<Item_Number>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no") & "</Item_Number>"
                    End If
                    strOrderXml = strOrderXml & "<Qty>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("qty") & "</Qty>"
                    If adoDT_OrderDetail.Rows(Line_Seq - 1).Item("unit_price") = -1 Then
                        strOrderXml = strOrderXml & "<Unit_Price>0</Unit_Price>"
                    Else
                        strOrderXml = strOrderXml & "<Unit_Price>" & adoDT_OrderDetail.Rows(Line_Seq - 1).Item("unit_price") & "</Unit_Price>"
                    End If

                    If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) < 100 Then
                        strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("request_date")) & "</Line_Require_Date>"
                        '>=100
                    Else
                        If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) Mod 100 = 0 Then
                            If (UCase(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no")) Like "W-CTOS*") Then
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("request_date")) & "</Line_Require_Date>"
                            Else
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("request_date")) & "</Line_Require_Date>"

                                Dim strMaxDD As String = ""
                                dArray = Split(Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("request_date")), "/")
                                compDD = dArray(0)
                                If Len(dArray(1)) = 2 Then
                                    compDD = compDD & "-" & dArray(1)
                                Else
                                    compDD = compDD & "-0" & dArray(1)
                                End If

                                If Len(dArray(2)) = 2 Then
                                    compDD = compDD & "-" & dArray(2)
                                Else
                                    compDD = compDD & "-0" & dArray(2)
                                End If

                                Dim WorkDays As String = "5"
                                Global_Inc.SiteDefinition_Get("BTOSWorkingDays", WorkDays)
                                Dim sc3 As New aeu_ebus_dev9000.B2B_AEU_WS
                                Global_Inc.SiteDefinition_Get("AeuEbizB2bWs", sc3.Url)
                                sc3.Get_Next_WrokingDate(compDD, -WorkDays)

                                If Now.Date > CDate(compDD) Then
                                    compDD = Year(Now()) & "/"
                                    If Month(Now()) < 10 Then
                                        compDD &= "0" & Month(Now()) & "/"
                                    Else
                                        compDD &= Month(Now()) & "/"
                                    End If
                                    If Day(Now()) < 10 Then
                                        compDD &= "0" & Day(Now()) & "/"
                                    Else
                                        compDD &= Day(Now())
                                    End If
                                Else
                                    Dim tempCompDD As String = compDD
                                    compDD = Year(CDate(tempCompDD)) & "/"
                                    If Month(CDate(tempCompDD)) < 10 Then
                                        compDD &= "0" & Month(CDate(tempCompDD)) & "/"
                                    Else
                                        compDD &= Month(CDate(tempCompDD)) & "/"
                                    End If
                                    If Day(CDate(tempCompDD)) < 10 Then
                                        compDD &= "0" & Day(CDate(tempCompDD)) & "/"
                                    Else
                                        compDD &= Day(CDate(tempCompDD))
                                    End If
                                End If
                                compDD = Replace(compDD, "-", "/")
                            End If
                        Else
                            If CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) < 100 Then
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & Global_Inc.FormatDate(Date.Now.Date) & _
                                "</Line_Require_Date>"
                            Else
                                strOrderXml = strOrderXml & "<Line_Require_Date>" & compDD & "</Line_Require_Date>"
                                'parentDD_DR.Close()
                            End If

                        End If
                    End If

                    strOrderXml = strOrderXml & "<Line_Due_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("ATP_date")) & "</Line_Due_Date>"
                    strOrderXml = strOrderXml & "<Request_Date>" & Global_Inc.FormatDate(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("REQUEST_date")) & "</Request_Date>"
                    If HttpContext.Current.Session("CBOM_SITE") = "ATW" And CInt(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("line_no")) >= 100 Then
                        If Left(adoDT_OrderDetail.Rows(Line_Seq - 1).Item("part_no"), 2) = "P-" Then
                            strOrderXml = strOrderXml & "<Line_To_Site_ID>0000</Line_To_Site_ID>"
                        Else
                            strOrderXml = strOrderXml & "<Line_To_Site_ID>1000</Line_To_Site_ID>"
                        End If
                        strOrderXml = strOrderXml & "<Line_Location>BTOS</Line_Location>"
                    End If


                    Try
                        strOrderXml = strOrderXml & "<Plant>" & "EUH1" & "</Plant>"
                    Catch ex As Exception
                        strOrderXml = strOrderXml & "<Plant></Plant>"
                    End Try


                    strOrderXml = strOrderXml & "</Order_Line>"
                    strOrderXml = strOrderXml & Chr(13) & Chr(10)
                    Line_Seq = Line_Seq + 1
                Loop
                strOrderXml = strOrderXml & "</Order>" & Chr(10)
                Dim strSOPath As String = ""
                Dim strFileName As String = ""

                strSOPath = "C:\MyAdvantech\ESALES\QuoteXML\"
                strFileName = siebel_row_id & ".xml"
                exeFunc = Util.SaveString2File(strOrderXml, strSOPath, strFileName)


            Case Else

                Return -1
                Exit Function
        End Select

        Return 1
    End Function
    Shared Function ERPQuotation_Process(ByVal strLocal_Folder As String, ByVal strLocal_Filename As String, ByRef ProcStatusXml As String) As Integer
        Dim order_xmlString As String = ""
        Dim proc_status_xml As String = ""
        Dim iRtn As Integer = 0
        Dim obj_FSO As System.IO.FileInfo = New System.IO.FileInfo(strLocal_Folder & UCase(strLocal_Filename))
        Dim objFStrm As System.IO.StreamReader
        Dim AEU_WS As New aeu_ebus_dev9000.B2B_AEU_WS
        AEU_WS.Timeout = 999999999

        objFStrm = obj_FSO.OpenText
        order_xmlString = objFStrm.ReadToEnd()
        objFStrm.Close()

        iRtn = AEU_WS.Quotation_CREATE(order_xmlString, proc_status_xml)

        ProcStatusXml = proc_status_xml
        Dim sr As System.IO.StringReader = New System.IO.StringReader(proc_status_xml)
        Dim StatusDS As New DataSet
        StatusDS.ReadXml(sr)
        Dim StatusDT As DataTable = StatusDS.Tables("row")
        'showDT(StatusDT) : HttpContext.Current.Response.End()
        If StatusDT.Rows(StatusDT.Rows.Count - 1).Item("Number") <> 311 Then
            Dim MassageStr As String = ""
            For Each dr As DataRow In StatusDT.Rows()
                MassageStr &= dr.Item("Message") & "<br/>"
            Next
            MailUtil.Utility_EMailPage("eBusiness.AEU@advantech.eu", _
                                            "nada.liu@advantech.com.cn;tc.chen@advantech.com.tw;rudy.wang@advantech.com.tw", _
                                            "", "", "create Quotation failed" & strLocal_Filename, "", _
                                            "Error: <br/>" & MassageStr)
        End If
        Dim strSOPath As String = "C:\MyAdvantech\ESALES\QuoteStatusXML\"
        Dim strFileName As String = strLocal_Filename
        Dim exeFunc As Integer = Util.SaveString2File(ProcStatusXml, strSOPath, strFileName)
        If iRtn = 0 Then
            ERPQuotation_Process = 0
        Else
            ERPQuotation_Process = 1
        End If
    End Function
    '---</eQuotation>
    'Shared Function IsEA(ByVal companyID As String) As Boolean
    '    Dim count As Object = dbUtil.dbExecuteScalar("B2B", "select count(company_id) from company where company_id='" & _
    '                                                      companyID & "' and salesGroup in ('310','311','312','313','314','315') ")
    '    If IsNumeric(count) Then
    '        If count > 0 Then
    '            Return True
    '        End If
    '    End If
    '    Return False
    'End Function
    'Shared Function IsEP(ByVal companyID As String) As Boolean
    '    Dim count As Object = dbUtil.dbExecuteScalar("B2B", "select count(company_id) from company where company_id='" & _
    '                                                      companyID & "' and salesGroup in ('320','321','322','323','324','325')")
    '    If IsNumeric(count) Then
    '        If count > 0 Then
    '            Return True
    '        End If
    '    End If
    '    Return False
    'End Function
    'Shared Function get_EA_Company_List() As DataTable
    '    Return dbUtil.dbGetDataTable("b2b", "select company_id from company where salesGroup in ('310','311','312','313','314','315')")
    'End Function
    'Shared Function get_EP_Company_List() As DataTable
    '    Return dbUtil.dbGetDataTable("b2b", "select company_id from company where salesGroup in ('320','321','322','323','324','325')")
    'End Function

    Shared Function getShipConditionByERPID(ByVal ERPID As String) As String
        Dim STR As String = String.Format("SELECT TOP 1 SHIPCONDITION FROM sap_dimcompany WHERE COMPANY_ID='{0}'", ERPID)
        Dim scCode As Object = dbUtil.dbExecuteScalar("RFM", STR)
        Dim Ret As String = "16Cust. Own Forwarder"
        If Not IsNothing(scCode) Then
            Select Case scCode.ToString()
                Case "01"
                    Ret = "01Truck / Sea"
                Case "02"
                    Ret = "02Pick up by customer"
                Case "03"
                    Ret = "03Fedex"
                Case "04"
                    Ret = "04UPS Economy"
                Case "05"
                    Ret = "05DHL Economy"
                Case "06"
                    Ret = "06By Material"
                Case "07"
                    Ret = "07Air"
                Case "08"
                    Ret = "08Service"
                Case "09"
                    Ret = "09TNT Economy"
                Case "10"
                    Ret = "10TNT Global"
                Case "11"
                    Ret = "11UPS Global"
                Case "12"
                    Ret = "12DHL Air Express"
                Case "13"
                    Ret = "13Hand Carry"
                Case "14"
                    Ret = "14Courier"
                Case "15"
                    Ret = "15UPS Standard"
                Case "16"
                    Ret = "16Cust. Own Forwarder"
                Case "17"
                    Ret = "17TNT Economy Special"
                Case "18"
                    Ret = "18By Sea to AKMC&ADMC"
                Case "19"
                    Ret = "19By Sea/Air (to ACSC)"
                Case "20"
                    Ret = "20UPS Express Saver"
                Case "21"
                    Ret = "21UPS Expres Plus 9:00"
                Case "22"
                    Ret = "22UPS Express 12:00"
                Case "23"
                    Ret = "23DHL Europlus"
            End Select
        End If
        Return Ret
    End Function

    'cbom
    Shared Sub CopyCategory(ByVal oldCategory As String, ByVal newCategory As String, ByVal org As String)
        If oldCategory = "" Or newCategory = "" Then
            Exit Sub
        End If
        Dim dtold As DataTable = dbUtil.dbGetDataTable("B2B", "SELECT * FROM CBOM_CATALOG_CATEGORY WHERE PARENT_CATEGORY_ID='" & oldCategory & "' and org='" & org & "'")
        dtold.AcceptChanges()
        If dtold.Rows.Count > 0 Then
            For i As Integer = 0 To dtold.Rows.Count - 1
                dtold.Rows(i).Item("Parent_category_id") = newCategory
                dtold.Rows(i).Item("uid") = System.Guid.NewGuid.ToString
            Next
            Dim bk As New System.Data.SqlClient.SqlBulkCopy(ConfigurationManager.ConnectionStrings("B2B").ConnectionString)
            bk.DestinationTableName = "CBOM_CATALOG_CATEGORY"
            bk.WriteToServer(dtold)
        End If
    End Sub

    Shared Sub SetSessionOrgForCbomEditor(ByVal userID As String)
        'If userID.ToString.ToUpper.StartsWith("BRIAN.TSAI@") OrElse _
        '    userID.ToString.ToUpper.StartsWith("NADA.LIU@") OrElse _
        '    userID.ToString.ToUpper.StartsWith("TC.CHEN@") OrElse _
        '    MailUtil.IsInRole("group ACL.ACG.RD") = True OrElse _
        '    userID.ToString.ToUpper.StartsWith("ETHAN.LIN@") Then
        '    HttpContext.Current.Session("ORG") = "TW"
        'ElseIf userID.ToString.ToUpper.Contains("TAM.TRAN") Then
        '    HttpContext.Current.Session("ORG") = "EU"
        'Else
        '    HttpContext.Current.Session("ORG") = "US"
        'End If
    End Sub
    '/cbom

    Shared Function getPartDefaultPlant(ByVal partno As String, ByVal org As String) As String
        Dim SQL As String = "select isnull(DELIVERYPLANT,'') as DELIVERYPLANT from SAP_PRODUCT_ORG where PART_NO='" & partno.Replace("'", "''") & "' and ORG_ID='" & org.Replace("'", "''") & "' "
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", SQL)
        Dim _plant As String = String.Empty
        If dt IsNot Nothing And dt.Rows.Count > 0 Then
            _plant = dt.Rows(0).Item("DELIVERYPLANT").ToString
        End If

        If String.IsNullOrEmpty(_plant) Then
            _plant = getPlant()
        End If

        Return _plant
    End Function

    Shared Function getPlant() As String
        'Frank 2012/06/04 Replacing Session("ORG") by Left(HttpContext.Current.Session("org_id"), 2)
        'left(session(“org_id”),2)

        If Not IsNothing(HttpContext.Current.Session("org_id")) Then
            'Ryan 20170317 New login for ACN, get plant by org.
            If Left(HttpContext.Current.Session("org_id"), 2) = "CN" Then
                If HttpContext.Current.Session("org_id").ToString.Equals("CN30") Then
                    Return "CNH3"
                Else
                    Return "CNH1"
                End If
            ElseIf Left(HttpContext.Current.Session("org_id"), 2) = "EU" Then
                If HttpContext.Current.Session("org_id").ToString.Equals("EU80") Then
                    Return "DLM1"
                Else
                    Return "EUH1"
                End If
            ElseIf Left(HttpContext.Current.Session("org_id"), 2) = "US" Then
                If HttpContext.Current.Session("org_id").ToString.Equals("US10") Then
                    Return "UBH1"
                Else
                    Return "USH1"
                End If
            End If
            Return Left(HttpContext.Current.Session("org_id"), 2).ToString.ToUpper & "H1"
        End If
        Return "TWH1"
    End Function
    'Shared Function getPlant() As String

    '    If Not IsNothing(HttpContext.Current.Session("ORG")) Then
    '        If HttpContext.Current.Session("ORG") = "CN" Then
    '            Return "CNH3"
    '        End If
    '        Return HttpContext.Current.Session("ORG").ToString.ToUpper & "H1"
    '    End If
    '    Return "TWH1"
    'End Function


    'Shared Function getCalendarbyOrg(ByVal org As String) As String
    '    Dim plant As String = org & "H1"
    '    Dim str As String = String.Format("select LAND1 from saprdp.t001w where WERKS='{0}' and mandt='168' and rownum=1", plant)
    '    Dim CID As Object = OraDbUtil.dbExecuteScalar("SAP_PRD", str)
    '    If Not IsNothing(CID) AndAlso CID.ToString <> "" Then
    '        Return CID.ToString
    '    End If
    '    Return "TW"
    'End Function


    Public Shared Function GetCurrencyCode(ByVal currency As String) As String
        Select Case currency
            Case "US", "USD"
                Return "$"
            Case "EUR"
                Return "&euro;"
            Case "GBP"
                Return "&pound;"
            Case "NT", "NTD"
                Return "NT"
            Case Else
                Return "$"
        End Select
    End Function

    Private Shared Function Op_Quotation() As Object
        Throw New NotImplementedException
    End Function
    Shared Sub SetDirect2SAPSession()
        If HttpContext.Current.Session("Direct2SAP") Is Nothing OrElse HttpContext.Current.Session("Direct2SAP") <> 1 Then
            HttpContext.Current.Session("Direct2SAP") = 1
        End If
    End Sub
    Shared Function IsDirect2SAP() As Boolean
        If HttpContext.Current.Session("Direct2SAP") IsNot Nothing AndAlso HttpContext.Current.Session("Direct2SAP") = 1 Then
            Return True
        End If
        Return False
    End Function
    Shared Function isANAPnBelowGP(ByVal PN As String, ByVal unitPrice As Decimal, ByRef gpPrice As Decimal) As Boolean
        If HttpContext.Current.Session("company_id") = "UZISCHE01" Then
            Return False
        End If
        Return SAPDAL.CommonLogic.isANAPnBelowGP(PN, unitPrice, gpPrice, "")
    End Function
    'Shared Function getANAGPPercByPN(ByVal pn As String, ByVal div As String) As Decimal
    '    Dim aptSapDs As New SAPDSTableAdapters.SAP_PRODUCTTableAdapter, pLine As String = aptSapDs.GetProductLineByPN(pn)
    '    If String.IsNullOrEmpty(pLine) Then pLine = "Other"
    '    Dim strSql As String = String.Format("select top 1 PPerc From ANAProductGP where CDiv=@DIV and PHrc=@PLINE", div)
    '    Dim sqlCmd As New SqlClient.SqlCommand(strSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString))
    '    sqlCmd.Parameters.AddWithValue("DIV", div) : sqlCmd.Parameters.AddWithValue("PLINE", pLine)
    '    sqlCmd.Connection.Open()
    '    Dim objPercentage As Object = sqlCmd.ExecuteScalar()
    '    sqlCmd.Connection.Close()
    '    If objPercentage IsNot Nothing Then
    '        Return CType(objPercentage, Decimal) / 100
    '    Else
    '        Select Case div
    '            Case 10
    '                Return 0.2
    '            Case 20
    '                Return 0.16
    '            Case Else
    '                Return 0
    '        End Select
    '    End If
    'End Function
    'Shared Function getCostForANAPn(ByVal PN As String, ByVal Plant As String) As Decimal
    '    Dim strSql As String = String.Format("select isnull(standard_price,0) AS P from PRODUCT_COST where PART_NO=@PN and PLANT =@PLANT", PN, Plant)
    '    Dim cmd As New SqlClient.SqlCommand(strSql, New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("EQ").ConnectionString))
    '    cmd.Parameters.AddWithValue("PN", PN) : cmd.Parameters.AddWithValue("PLANT", Plant)
    '    cmd.Connection.Open()
    '    Dim objCost As Object = cmd.ExecuteScalar()
    '    cmd.Connection.Close()
    '    If objCost IsNot Nothing Then
    '        Return CType(objCost, Decimal)
    '    Else
    '        Return 0
    '    End If
    'End Function
    Shared Function GetParsForUploadOrder(ByVal cartid As String, ByRef ShiptoID As String, ByRef PoNo As String, ByRef ShipCondition As String) As Integer
        Dim SQL As String = String.Format(" select CART_ID,PO,SHIP_CONDITION,SHIPTO_ID from UPLOAD_ORDER_PARA  WHERE CART_ID='{0}'", cartid)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", SQL)
        If dt.Rows.Count > 0 Then
            With dt.Rows(0)
                If Not IsDBNull(.Item("PO")) Then
                    PoNo = .Item("PO").ToString.Trim
                End If
                If Not IsDBNull(.Item("SHIPTO_ID")) Then
                    ShiptoID = .Item("SHIPTO_ID").ToString.Trim
                End If
                If Not IsDBNull(.Item("SHIP_CONDITION")) Then
                    ShipCondition = .Item("SHIP_CONDITION").ToString.Trim
                End If
            End With
            Return 1
        End If
        Return 0
    End Function
End Class
