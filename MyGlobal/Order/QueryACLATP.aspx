<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- ACL ATP Inquiry" EnableEventValidation="false" ValidateRequest="false" %>

<%@ Register TagPrefix="uc1" TagName="PickPartNo" Src="~/Includes/PickPartNo.ascx" %>


<script runat="server">
    '20180306 TC: Added TWM8
    '20180319 TC: Per SCM Kelly and AEU Louis, hide all CKBX's ATP
    '20180621 Frank: Veronica.Shi want to show TWM9's inventory
    Dim strPlant As String = "EUH1,TWH1,TWM2,TWM3,TWM4,TWM8,TWM9,CNH1,CKH2,CNH1-SZ,CNH1-BJ,USH1,UBH1"
    Dim ArrayPlant() As String = Split(strPlant, ",")
    Dim cont As Integer = UBound(ArrayPlant)
    Dim table As New DataTable
    Dim iRet As Integer = 0, QTY As Integer = 0, requiredDate As String = ""
    ' Dim xmlInput As String = ""
    'Dim xmlOut As String = "", 
    Dim xmlLog As String = ""
    Dim WS As New aeu_ebus_dev9000.B2B_AEU_WS

    Dim strReturn As String = ""

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.AppendHeader("Cache-Control", "no-cache; private; no-store; must-revalidate; max-stale=0; post-check=0; pre-check=0; max-age=0")
        If Not Page.IsPostBack Then
            'Allow on EU CP/EZ/KA to check ACL ATP

            Dim _org_id As String = Session("org_id")

            'Frank 2012/06/01
            'To prevent null value exception when accessing the Session("org")
            If String.IsNullOrEmpty(_org_id) OrElse _org_id.Length < 2 Then
                Response.Redirect("../home.aspx")
            End If

            _org_id = Left(_org_id, 2).ToUpper

            'If Session("org").ToString.StartsWith("EU", StringComparison.OrdinalIgnoreCase) And Session("account_status") <> "GA" Then
            If Session("account_status") <> "GA" Then

            Else
                Response.Redirect("../home.aspx")
            End If
            Me.txtRequiredDate.Text = Global_Inc.FormatDate(System.DateTime.Now)
            If Request("PartNo") <> "" Then
                Me.txtPartNo.Text = Global_Inc.Format2SAPItem(Server.HtmlEncode(Request("PartNo")).ToUpper().Trim())
                If Request("ReqDate") <> "" Then
                    Me.txtRequiredDate.Text = CDate(Request("ReqDate"))
                End If
                'Dim strScript As String = "<Script Language='JavaScript'>"
                'strScript &= "__doPostBack('btnSubmit','');"
                'strScript &= "</"
                'strScript &= "Script>"
                'Page.ClientScript.RegisterStartupScript(Me.GetType(), "ClickQueryBtn", strScript)
            End If
        End If
        'Add jan 2009-1-15-------
        If Me.txtPartNo.Text <> "" Then


            'Dim sql As String = "Select a.EKGRP as GRP,b.eknam as Description  From  saprdp.MARC a INNER JOIN saprdp.T024 b on a.EKGRP=b.EKGRP WHERE  a.MATNR='" & Global_Inc.Format2SAPItem(UCase(Me.txtPartNo.Text).Replace("'", "''")) & "' AND a.WERKS='EUH1'"

            'Alex 20160613 Change Planner/Ship via sql: using getplant() to determine plant
            Dim sql As String = " select b.EKNAM as Description From  saprdp.MDKP a left join saprdp.T024 b on a.EKGRP=b.EKGRP where a.mandt=168 and b.mandt=168 and a.MATNR='" & Global_Inc.Format2SAPItem(UCase(Me.txtPartNo.Text).Replace("'", "''")) & "' and a.PLWRK='" & OrderUtilities.getPlant() & "'"
            Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sql.ToString())
            If dt.Rows.Count > 0 Then
                If dt.Rows(0).Item("Description").ToString().ToLower().IndexOf(",") <> -1 Then
                    Dim Description As Array
                    Description = Split(dt.Rows(0).Item("Description"), ",")
                    Label0.Text = Description(0)
                    Label1.Text = Description(1)
                ElseIf dt.Rows(0).Item("Description").ToString().ToLower().IndexOf("-") <> -1 Then
                    Dim Description As Array
                    Description = Split(dt.Rows(0).Item("Description"), "-")
                    Label0.Text = Description(0)
                    Label1.Text = Description(1)
                Else
                    'If Right(dt.Rows(0).Item("GRP"), 1) Mod 2 = 0 Then
                    '    Label1.Text = "Sea"
                    'Else
                    '    Label1.Text = "Air"
                    'End If
                    Label0.Text = dt.Rows(0).Item("Description")
                    Label1.Text = "N/A"
                End If

                PurGroup.Visible = True
                If Util.IsAEUIT() Or Util.IsInternalUser2() Then
                    PurGroup_1.Visible = True
                    PurGroup_2.Visible = True
                End If
            End If

            'Alex 20160613 removie ship via logic
            'ICC 2014/09/15 Change Ship via data source.
            dt.Clear()

            'sql = " SELECT BEZEI as ShipVia FROM saprdp.TMFGT a inner join saprdp.MARC b on a.mfrgr=b.mfrgr WHERE a.SPRAS='E' and b.MATNR='" & Global_Inc.Format2SAPItem(UCase(Me.txtPartNo.Text).Replace("'", "''")) & "' AND b.WERKS='TWH1'"
            'dt = OraDbUtil.dbGetDataTable("SAP_PRD", sql)
            'If dt.Rows.Count > 0 Then
            'Label1.Text = dt.Rows(0).Item("SHIPVIA").ToString()
            'End If
        Else
            PurGroup.Visible = False
        End If
        '-------------
    End Sub

    Function initRsATP(ByRef dt As DataTable, ByVal plant As String, ByVal partNO As String, ByVal QTY As String, ByVal requiredDate As String, ByVal Unit As String) As Integer
        'Me.iRet = Me.Global_inc1.InitRsATPi(dt)
        Dim dr As DataRow = dt.NewRow()
        dr.Item("WERK") = plant.ToUpper()
        'If IsNumeric(partNO.Trim().ToUpper()) Then
        'dr.Item("MATNR") = "00000000" & partNO.Trim().ToUpper()
        'Else
        dr.Item("MATNR") = partNO.Trim().ToUpper()
        'End If

        dr.Item("REQ_QTY") = QTY.ToString()
        dr.Item("REQ_DATE") = requiredDate.ToString()
        dr.Item("UNI") = Unit.ToString()
        'If stoc <> "" Then
        '    dr.Item("Stoc") = stoc.ToString
        'Else
        '    dr.Item("Stoc") = ""
        'End If
        dt.Rows.Add(dr)
    End Function

    Function CheckStatus(ByVal partNO As String) As Boolean

        Dim dt As New DataTable
        dt = dbUtil.dbGetDataTable("B2B", "select status from product where part_no='" & partNO & "'")
        If dt.Rows.Count >= 1 Then
            If dt.Rows(0).Item("status") = "A" Or dt.Rows(0).Item("status") = "N" Or dt.Rows(0).Item("status") = "H" Then
                CheckStatus = True
            Else
                CheckStatus = False
            End If
        Else
            CheckStatus = False
        End If
    End Function

    Protected Sub btnPick_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        CType(ucPickPartNo.FindControl("txtModelNo"), TextBox).Text = ""
        CType(ucPickPartNo.FindControl("txtDesc"), TextBox).Text = ""
        CType(ucPickPartNo.FindControl("txtPartNo"), TextBox).Text = Trim(txtPartNo.Text.Replace("'", ""))
        'ucPickPartNo._strPartNO = txtPartNo.Text
        ucPickPartNo.initialSearch()
        ucPickPartNo.Visible = True
        ModalPopupExtender1.Show()
        up2.Update()
    End Sub

    Protected Sub ucPickPartNo_pick(ByVal part_no As String)
        txtPartNo.Text = part_no
        ModalPopupExtender1.Hide()
        ucPickPartNo.Visible = False
        up1.Update() : up2.Update()
    End Sub

    Protected Sub ucPickPartNo_close()
        ucPickPartNo.Visible = False
        ModalPopupExtender1.Hide()
    End Sub

    Protected Sub ucPickPartNo_update()
        up2.Update()
    End Sub

    Protected Sub btnSubmit_Click(sender As Object, e As EventArgs)

        'Ryan 20160909 Add part no validation
        Dim refmsg As String = String.Empty
        Dim DefaultShipto As String = "", CountryCode As String = ""
        DefaultShipto = Advantech.Myadvantech.Business.UserRoleBusinessLogic.MYAgetShiptoIDBySoldtoID(Session("company_id").ToString(), Session("CART_ID").ToString)
        CountryCode = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getCountryCodeByERPID(DefaultShipto)
        If Advantech.Myadvantech.Business.PartBusinessLogic.IsInvalidParts(Session("company_id").ToString(), Session("org_id").ToString, Trim(Me.txtPartNo.Text.Replace("'", "")),
                 Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString), CountryCode, Util.IsInternalUser(Session("user_id")), refmsg) Then
            Me.Page.ClientScript.RegisterStartupScript(GetType(String), "alert", "<script>alert('" + refmsg + "');</" & "script")
            Exit Sub
        End If

        If Session("org_id").ToString() = "EU10" And Not txtPartNo.Text.Trim().ToUpper.StartsWith("BB-") Then
            ArrayPlant = ArrayPlant.Where(Function(val) val <> "UBH1").ToArray()
            cont = UBound(ArrayPlant)
        End If

        Dim dt As New DataTable
        'Dim ds As New DataSet()
        Dim view(ArrayPlant.Length - 1) As DataView
        ' If Not Page.IsPostBack Then
        ''If CheckStatus(Me.txtPartNo.Value.Trim()) = False Then
        ''    Exit Sub
        ''End If

        Me.iRet = Global_Inc.InitRsATPi(Me.table)
        'If IsNumeric(Me.txtQTY.Value) Then
        '    Me.QTY = Me.txtQTY.Value.Trim()
        'Else
        '    Me.QTY = "1"
        'End If
        Me.QTY = "99999"
        If Not IsDate(Me.txtRequiredDate.Text) Then
            Me.requiredDate = Global_Inc.FormatDate(System.DateTime.Now)
        Else
            Me.requiredDate = Global_Inc.FormatDate(CDate(Me.txtRequiredDate.Text))
        End If

        For i As Integer = 0 To cont
            '    Dim Stoc As String = ""
            '    If ArrayPlant(i) = "CNH1-BJ" Then
            '        ArrayPlant(i) = "CNH1"
            '        Stoc = "2000"
            '    ElseIf ArrayPlant(i) = "TWM3" Or ArrayPlant(i) = "TWM4" Then
            '        If Left(Session("org_id").ToString.ToUpper, 2) = "CN" Then
            '            Stoc = "0000"
            '        End If
            '    End If
            Me.iRet = Me.initRsATP(Me.table, ArrayPlant(i), Global_Inc.Format2SAPItem(Trim(Me.txtPartNo.Text.Replace("'", ""))), Me.QTY, Me.requiredDate, "PC")
        Next

        'Me.xmlInput = Global_Inc.DataTableToADOXML(Me.table)
        'Session("company_id") = "EFFRFA01"
        'GetMultiDueDate(UCase(session("company_id")), UCase(session("company_id")),"EU10", "10", "00", xATPInquiryXMLSend,xATPInquiryXMLReceive,xErrorLog)
        'Me.iRet = WS.GetMultiDueDate(UCase(Session("company_id")), UCase(Session("company_id")), "EU10", "10", "00", Me.xmlInput, Me.xmlOut, Me.xmlLog)
        'If Left(Session("org_id").ToString.ToUpper, 2) = "CN" Then
        '    Me.iRet = WS.GetMultiATP_ACN(Me.xmlInput, Me.xmlOut, Me.xmlLog)

        'Else
        'Nada 20131120 Migrating ws to SAP DAL
        Dim outDT As New DataTable
        Me.iRet = SAPDAL.CommonLogic.GetMultiATP_Newbytable(Me.table, outDT, Me.xmlLog)
        'End If

        'Response.Write("<br/>xmlInput:" & xmlInput)
        'Response.Write("<br/>xmlOut:" & xmlOut)
        If Me.iRet = -1 Then
            '---- ERROR HANDEL ----'
            Response.Write("Calling SAP function Error!<br>" & Me.xmlLog & "<br>")
        Else
            'If Session("user_id") = "nada.liu@advantech.com.cn" Then
            '    'Response.Write("xml:" & Me.xmlInput & "<br>" & Me.xmlOut):Response.End()
            'End If

            'Dim sr As System.IO.StringReader = New System.IO.StringReader(Me.xmlOut)
            'Dim ds As New DataSet()
            'Dim dv As New DataView()
            'ds.ReadXml(sr)
            'dv = ds.Tables(ds.Tables.Count - 1).DefaultView
            'dt = ds.Tables(ds.Tables.Count - 1)
        End If

        If outDT.Rows.Count = 0 Then
            Me.Page.ClientScript.RegisterStartupScript(GetType(String), "alert", "<script>alert('There is no ATP info for this item, please check if this is a wrong item.');</" & "script")
            'Page.Response.Redirect("../Order/queryGATP.aspx")
            Me.txtPartNo.Focus()
            Exit Sub
        End If
        ''Jackie add 2006/11/08 for wrong part no error handle
        'If ds.Tables(ds.Tables.Count - 1).TableName <> "row" Then
        '    Me.Page.ClientScript.RegisterStartupScript(GetType(String), "alert", "<script>alert('There is no ATP info for this item, please check if this is a wrong item.');</" & "script")
        '    'Page.Response.Redirect("../Order/queryGATP.aspx")
        '    Me.txtPartNo.Focus()
        '    Exit Sub
        'End If

        'Ryan 20160913 Get product status
        Dim str_status As String = "SELECT PART_NO,SALES_ORG,PRODUCT_STATUS,DLV_PLANT FROM SAP_PRODUCT_STATUS " + _
                                   " WHERE PART_NO = '" + Trim(Me.txtPartNo.Text.Replace("'", "")) + "' "
        Dim dt_status As DataTable = dbUtil.dbGetDataTable("MY", str_status)
        Dim defaultorgid As String = String.Empty



        For i As Integer = 0 To ArrayPlant.Length - 1
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Left(ArrayPlant(i), 2).ToUpper = Session("org").ToString.ToUpper Or Left(ArrayPlant(i), 2).ToUpper = "TW" _
            'Or (Session("org").ToString.ToUpper = "EU" And ArrayPlant(i).ToUpper = "CKH2") Then

            'Ryan 20160913 Set representative org name from plant
            defaultorgid = Session("org_id").ToString.ToUpper
            Select Case Left(ArrayPlant(i), 2).ToUpper
                Case "EU"
                    defaultorgid = "EU10"
                Case "US"
                    defaultorgid = "US01"
                Case "TW"
                    defaultorgid = "TW01"
                Case "CK"
                Case "CN"
                    defaultorgid = "CN10"
                Case "UB"
                    defaultorgid = "US10"
                Case Else
                    defaultorgid = "TW01"
            End Select

            'Ryan 20160429 Add P-Trade logic
            If (Advantech.Myadvantech.Business.QuoteBusinessLogic.IsPTradePart(Global_Inc.Format2SAPItem(Trim(Me.txtPartNo.Text.Replace("'", "")))) _
                AndAlso Left(Session("org_id").ToString.ToUpper, 2) = "EU") AndAlso (Left(ArrayPlant(i), 2).ToUpper = "TW" Or Left(ArrayPlant(i), 2).ToUpper = "EU" _
                                                                                     Or Left(ArrayPlant(i), 2).ToUpper = "CK") Then
                If Not Left(ArrayPlant(i), 2).ToUpper = "CK" And Not Left(ArrayPlant(i), 3).ToUpper = "TWM" Then
                    view(i) = outDT.DefaultView
                    view(i).RowFilter = " site='" & ArrayPlant(i) & "' and qty_atp<99999 and qty_atp>0  "
                    Dim table As DataTable = view(i).ToTable()

                    If table.Rows.Count > 0 AndAlso dt_status.Select("SALES_ORG = '" + defaultorgid + "' and PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + "").Count > 0 Then
                        Dim table1 As New DataTable
                        Dim columnDate As New DataColumn, columnQty As New DataColumn, columnIndex As New DataColumn
                        columnDate.ColumnName = "Available Date" : columnQty.ColumnName = "Availability" : columnIndex.ColumnName = "No."
                        table1.Columns.Add(columnIndex) : table1.Columns.Add(columnDate) : table1.Columns.Add(columnQty)
                        Dim row As DataRow
                        For j As Integer = 0 To table.Rows.Count - 1
                            row = table1.NewRow()
                            If Session("account_status") = "GA" Then
                                row("Available Date") = "To be confirmed within 3 days" : row("Availability") = "To be confirmed within 3 days" : row("No.") = j + 1
                                table1.Rows.Add(row)
                                Exit For
                            Else
                                row("Available Date") = table.Rows(j).Item("date") : row("Availability") = CInt(table.Rows(j).Item("qty_atp")) : row("No.") = j + 1
                            End If
                            table1.Rows.Add(row)
                        Next

                        Dim strHeader As String = "<table width=""550px"" border=""1px"">"
                        Dim HD As String = "<TD><b>NO.</b></TD><TD><b>Atp Date</b></TD><TD><b>Atp Qty (Cumulated)</b></TD>"
                        Dim strEnd As String = "</table>"

                        Dim plant As String = ArrayPlant(i)

                        strReturn &= "<BR>" & plant & "<BR/>"
                        strReturn &= strHeader
                        strReturn &= HD
                        Dim drc As DataRowCollection = table1.Rows
                        strReturn &= Glob.dataRow2HtmlRow(drc)
                        strReturn &= strEnd
                    Else
                        Dim plant As String = ArrayPlant(i)
                        strReturn &= "<BR>" & plant & "<BR/> (No Inventory.)"
                    End If
                    If strReturn = "" Then
                        strReturn = "No search results were found."
                    End If
                    view(i) = Nothing

                End If

            ElseIf Left(ArrayPlant(i), 2).ToUpper = Left(Session("org_id").ToString.ToUpper, 2) Or Left(ArrayPlant(i), 2).ToUpper = "TW" Or Left(ArrayPlant(i), 2).ToUpper = "CK" Or Left(ArrayPlant(i), 2).ToUpper = "UB" Then

                view(i) = outDT.DefaultView
                view(i).RowFilter = " site='" & ArrayPlant(i) & "' and qty_atp<99999 and qty_atp>0  "
                Dim table As DataTable = view(i).ToTable()

                If table.Rows.Count > 0 AndAlso dt_status.Select("SALES_ORG = '" + defaultorgid + "' and PRODUCT_STATUS in " + ConfigurationManager.AppSettings("CanOrderProdStatus") + "").Count > 0 Then
                    'If i = 0 TO 10 Then
                    Dim table1 As New DataTable
                    Dim columnDate As New DataColumn, columnQty As New DataColumn, columnIndex As New DataColumn
                    columnDate.ColumnName = "Available Date" : columnQty.ColumnName = "Availability" : columnIndex.ColumnName = "No."
                    table1.Columns.Add(columnIndex) : table1.Columns.Add(columnDate) : table1.Columns.Add(columnQty)
                    Dim row As DataRow
                    For j As Integer = 0 To table.Rows.Count - 1
                        row = table1.NewRow()
                        If Session("account_status") = "GA" Then
                            'If OrderUtilities.IsGA(Session("company_id")) Then
                            row("Available Date") = "To be confirmed within 3 days" : row("Availability") = "To be confirmed within 3 days" : row("No.") = j + 1
                            table1.Rows.Add(row)
                            Exit For
                        Else
                            row("Available Date") = table.Rows(j).Item("date") : row("Availability") = CInt(table.Rows(j).Item("qty_atp")) : row("No.") = j + 1
                        End If
                        table1.Rows.Add(row)
                    Next

                    Dim strHeader As String = "<table width=""550px"" border=""1px"">"
                    Dim HD As String = "<TD><b>NO.</b></TD><TD><b>Atp Date</b></TD><TD><b>Atp Qty (Cumulated)</b></TD>"
                    Dim strEnd As String = "</table>"

                    Dim plant As String = ArrayPlant(i)

                    strReturn &= "<BR>" & plant & "<BR/>"
                    strReturn &= strHeader
                    strReturn &= HD
                    Dim drc As DataRowCollection = table1.Rows
                    strReturn &= Glob.dataRow2HtmlRow(drc)
                    strReturn &= strEnd

                Else


                    Dim plant As String = ArrayPlant(i)

                    strReturn &= "<BR>" & plant & "<BR/> (No Inventory.)"


                    'If i = 0 Then td1.Visible = False
                    'If i = 1 Then td2.Visible = False
                    'If i = 10 Then td3.Visible = False
                End If
                'If Me.PlaceHolder1.Controls.Count = 0 Then
                '    Dim lbl As New Label
                If strReturn = "" Then
                    strReturn = "No search results were found."
                End If
                '    Me.PlaceHolder1.Controls.Add(lbl)
                'End If
                view(i) = Nothing
            End If
        Next
        'jan add 2008/12/29  by show the value of state null
        'If td1.Visible = False And td2.Visible = False And td3.Visible = False Then
        '    Dim table1 As New DataTable
        '    Dim columnDate As New DataColumn, columnQty As New DataColumn, columnIndex As New DataColumn
        '    columnDate.ColumnName = "Available Date" : columnQty.ColumnName = "Availability" : columnIndex.ColumnName = "No."
        '    table1.Columns.Add(columnIndex) : table1.Columns.Add(columnDate) : table1.Columns.Add(columnQty)
        '    Dim row As DataRow
        '    row = table1.NewRow()
        '    row("Available Date") = Now.ToString("yyyy/MM/dd") : row("Availability") = "No availability until this date, please contact Advantech for further check." : row("No.") = 1
        '    table1.Rows.Add(row)
        '    gv4.Visible = True
        '    gv4.DataSource = table1 : gv4.DataBind()
        'End If
    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <script type="text/javascript" language="javascript" src="../Includes/popcalendar.js"></script>

    <table align="center" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td width="10px"></td>
            <td></td>
            <td width="20px"></td>
        </tr>
        <tr>
            <td colspan="3" height="15"></td>
        </tr>
        <tr>
            <td width="10px" style="height: 26px"></td>
            <td style="height: 26px">
                <!--Page Title-->
                <div class="euPageTitle">
                    ACL Availability Inquiry
                </div>
            </td>
            <td width="20px" style="height: 26px"></td>
        </tr>
        <tr>
            <td colspan="3" height="15"></td>
        </tr>
        <tr>
            <td width="10px"></td>
            <td valign="top">
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr valign="top">
                        <td style="width: 536px">
                            <!--New Table Start-->
                            <table width="300" border="0" cellpadding="0" cellspacing="0" id="Table1">
                                <tr>
                                    <td style="width: 571px">
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text" id="Table2">
                                            <tr>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/bluefolder_left.jpg" width="7" height="23"></td>
                                                <td width="15%" valign="top" bgcolor="A3BFD4">
                                                    <img src="../images/ebiz.aeu.face/bluefolder_top.jpg" width="138" height="3"></td>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/bluefolder_right.jpg" width="7" height="23"></td>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/clear.gif" width="5" height="8"></td>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/skyfolder_left.jpg" width="6" height="23"></td>
                                                <td width="17%" bgcolor="E7EFF1">
                                                    <img src="../images/ebiz.aeu.face/skyfolder_top.jpg" width="140" height="3"></td>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/skyfolder_right.jpg" width="7" height="23"></td>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/clear.gif" width="5" height="8"></td>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/skyfolder_left.jpg" width="6" height="23"></td>
                                                <td width="31%" bgcolor="E7EFF1">
                                                    <img src="../images/ebiz.aeu.face/skyfolder_top.jpg" width="140" height="3"></td>
                                                <td width="2%" rowspan="2">
                                                    <img src="../images/ebiz.aeu.face/skyfolder_right.jpg" width="7" height="23"></td>
                                            </tr>
                                            <tr>
                                                <td class="euFormCaption">Inquiry Global ATP
                                                </td>

                                                <td width="17%" class="euFormCaptionInactive"></td>
                                                <td width="31%" class="euFormCaptionInactive">&nbsp;
                                                </td>

                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td height="5" bgcolor="#A0BFD3" style="width: 571px"></td>
                                </tr>
                                <tr>
                                    <td height="90" bgcolor="#A4B5BD" style="width: 571px">
                                        <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="1" id="Table3">
                                            <tr valign="top">
                                                <td height="100%" bgcolor="#F1F2F4">
                                                    <asp:Panel runat="server" ID="PanelSearch" DefaultButton="btnSubmit">
                                                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td colspan="5" height="4px"></td>
                                                            </tr>


                                                            <tr valign="middle">
                                                                <td width="5%" height="30px" align="right" valign="top">
                                                                    <img src="../images/ebiz.aeu.face/square_gray.gif" width="7" height="7">&nbsp;&nbsp;
                                                                </td>
                                                                <td style="width: 15%" valign="top">
                                                                    <div class="euFormFieldCaption" style="vertical-align: top; text-align: left">Material&nbsp;:</div>
                                                                </td>
                                                                <td width="40%" valign="top" colspan="2">
                                                                    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional" ChildrenAsTriggers="false">
                                                                        <ContentTemplate>
                                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1"
                                                                                ServiceMethod="GetPartNo" TargetControlID="txtPartNo" ServicePath="~/Services/AutoComplete.asmx"
                                                                                MinimumPrefixLength="2" FirstRowSelected="true" />
                                                                            <asp:TextBox ID="txtPartNo" runat="server"></asp:TextBox>&nbsp;
                                                                                        &nbsp;<asp:Button runat="server" ID="btnPick" Text="Pick" OnClick="btnPick_Click" />
                                                                            <asp:LinkButton runat="server" ID="link1" />
                                                                            <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1" PopupControlID="Panel1"
                                                                                PopupDragHandleControlID="Panel1" TargetControlID="link1" />
                                                                            <asp:Panel runat="server" ID="Panel1">
                                                                                <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                                                                    <ContentTemplate>
                                                                                        <uc1:PickPartNo runat="server" ID="ucPickPartNo" Type="queryPrice" Visible="false" Onpick="ucPickPartNo_pick" Onclose="ucPickPartNo_close" Onupdate="ucPickPartNo_update" />
                                                                                    </ContentTemplate>
                                                                                </asp:UpdatePanel>
                                                                            </asp:Panel>
                                                                        </ContentTemplate>
                                                                    </asp:UpdatePanel>
                                                                </td>

                                                            </tr>

                                                            <tr valign="middle">
                                                                <td width="5%" align="right" style="height: 29px">
                                                                    <img src="../images/ebiz.aeu.face/square_gray.gif" width="7" height="7">&nbsp;&nbsp;
                                                                </td>
                                                                <td style="height: 29px; width: 15%;">
                                                                    <div class="euFormFieldCaption">Require Date&nbsp;:</div>
                                                                </td>
                                                                <td width="40%" style="height: 29px" colspan="2">
                                                                    <asp:TextBox runat="server" ID="txtRequiredDate" onclick="javascript:popUpCalendar(this, this, 'yyyy/mm/dd')" />
                                                                    <asp:Button runat="server" ID="btnSubmit" Text="Query" OnClick="btnSubmit_Click" />
                                                                    <%--<input type="submit" name="ATP" class="euFormSubmit" value="Query" id="btnSubmit" onserverclick="btnSubmit_ServerClick" runat="server">--%>
                                                                </td>

                                                            </tr>
                                                            <tr>
                                                                <td colspan="5" height="4px"></td>
                                                            </tr>
                                                        </table>
                                                    </asp:Panel>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <!--New Table End-->
                        </td>
                        <td width="150px">
                            <br />
                            <br />
                            <br />
                            <br />
                            <br />

                            <table class="text" id="PurGroup" width="150px" style="background-color: #E2DED6" runat="server" visible="false">
                                <tr>

                                    <td id="PurGroup_1" runat="server" align="center" visible="false" style="background-color: #F7F6F3">
                                        <b>Planner</b></td>
                                    <td style="background-color: #F7F6F3" align="center">
                                        <b>Ship Via</b></td>
                                </tr>
                                <tr>
                                    <td id="PurGroup_2" runat="server" align="center" visible="false" style="background-color: #FFFFFF">
                                        <asp:Label ID="Label0" runat="server" ForeColor="Blue"></asp:Label></td>
                                    <td style="background-color: #FFFFFF" align="center">
                                        <asp:Label ID="Label1" runat="server" ForeColor="Blue"></asp:Label></td>
                                </tr>
                            </table>


                        </td>

                    </tr>
                </table>
            </td>
            <td width="20px"></td>
        </tr>
        <tr>
            <td colspan="3" height="15"></td>
        </tr>
        <tr>
            <td colspan="3" height="15">
                <%=strReturn%>
            </td>
        </tr>

    </table>

</asp:Content>
