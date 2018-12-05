<%@ Page Title="MyAdvantech - Place CKD Order for BRAVIEW INDUSTRIA DE PRODUTOS"
    Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">    
    Dim AllowedCompanyIDs() As String = {"AHKD004", "ADVABR"}
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Not Util.IsInternalUser2() Then Response.Redirect("../home.aspx")
            If Not AllowedCompanyIDs.Contains(HttpContext.Current.Session("company_id").ToString.ToUpper()) Then
                Response.Redirect("../home.aspx")
            End If
            divCompName.InnerText = Session("company_name")
        End If
    End Sub

    Function GetMaterialBomAndMoQ(ByVal strPartNo As String, ByVal strDlvPlant As String, ByRef dtMBOM As DataTable) As Boolean
        Dim dtMBomRaw As New DataTable, strErr As String = ""
        Dim intCKDQty As Integer = IIf(Integer.TryParse(txtQty.Text, 0) AndAlso CInt(txtQty.Text) > 0, CInt(txtQty.Text), 1)
        Dim MyComBom As New ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZPP_BOM_EXPL_MAT_V2_RFC_CKD, dtret As New ZPP_BOM_EXPL_MAT_V2_RFC_CKD.ZTPP_60Table
        MyComBom.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        MyComBom.Connection.Open()
        MyComBom.Zpp_Bom_Expl_Mat_V2_Rfc("", "X", UCase(strPartNo), strDlvPlant, strErr, dtret)
        MyComBom.Connection.Close()

        tabcon1.Visible = False : btnOrder.Enabled = False
        Dim dt As DataTable = dtret.ToADODataTable()
        If dt IsNot Nothing AndAlso dt.Rows.Count > 0 Then
            tabcon1.Visible = True : btnOrder.Enabled = True
            With dtMBomRaw.Columns
                .Add("PART_NO") : .Add("MOQ", GetType(Integer)) : .Add("USD_COST", GetType(Double)) : .Add("PRODUCT_STATUS") : .Add("IsOrderable", GetType(Boolean))
                .Add("BOM_QTY", GetType(Double)) : .Add("PRODUCT_DESC") : .Add("PEINH_USD", GetType(Decimal))
            End With

            Dim sapConn As New Oracle.DataAccess.Client.OracleConnection(ConfigurationManager.ConnectionStrings("SAP_PRD").ConnectionString)

            For Each r As DataRow In dt.Rows
                'Hermit commented on 20130524
                '這還要判斷個logic.因有替代料, 若為副料不予考慮.
                '故要判斷
                '若(ALPGR <> space and EWAHR = 100) or ALPGR = space
                '才要用component 的Qty * Order qty.
                '欄位是MENGE.  乘完後一律無條件進入. 以避免有小數點問題.
                Dim strRowAlpgr As String = Trim(r.Item("Alpgr").ToString()), strRowEwahr As String = r.Item("Ewahr").ToString()
                If (Not String.IsNullOrEmpty(strRowAlpgr) And strRowEwahr = "100") Or String.IsNullOrEmpty(strRowAlpgr) Then
                    Dim strRawPN As String = r.Item("Idnrk").ToString()
                    Dim strPN As String = Global_Inc.RemoveZeroString(strRawPN)
                    Dim sapCmd As New Oracle.DataAccess.Client.OracleCommand("select VMSTA from saprdp.mvke where matnr='" + Replace(strRawPN, "'", "''") + "' and vkorg='TW01'", sapConn)
                    If sapConn.State <> ConnectionState.Open Then sapConn.Open()
                    Dim objStatus As Object = sapCmd.ExecuteScalar()
                    Dim strPStatus As String = ""
                    If objStatus IsNot Nothing Then
                        strPStatus = objStatus.ToString()
                    End If

                    Dim nr As DataRow = dtMBomRaw.NewRow()
                    nr.Item("PART_NO") = strPN : nr.Item("MOQ") = r.Item("Bstmi") : nr.Item("USD_COST") = r.Item("Stprs_Usd")
                    nr.Item("PRODUCT_STATUS") = strPStatus : nr.Item("BOM_QTY") = r.Item("Menge") : nr.Item("PRODUCT_DESC") = r.Item("OJTXP")
                    If CDbl(r.Item("PEINH")) > 0 Then nr.Item("USD_COST") = Math.Round(r.Item("Stprs_Usd") / r.Item("PEINH_USD"), 5)

                    '20170224 TC: Per Sabrina's request markup 36% 
                    nr.Item("USD_COST") = nr.Item("USD_COST") * 1.36

                    nr.Item("PEINH_USD") = r.Item("PEINH_USD")
                    Dim blOrderable As Boolean = False
                    Dim intMinLotSize As Integer = IIf(r.Item("Bstmi") = 0, 1, r.Item("Bstmi"))
                    Select Case UCase(strPStatus)
                        Case "A", "N", "H"
                            If False Then
                                blOrderable = False
                            Else
                                blOrderable = True
                            End If
                        Case "O"
                            If intCKDQty < intMinLotSize Then
                                blOrderable = False
                            Else
                                Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
                                p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
                                p1.Connection.Open()
                                Dim retDate As Date = DateAdd(DateInterval.Day, -1, Now), retQty As Integer = 0
                                Dim culQty As Integer = 0, decInventory As Decimal = 0
                                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                                Dim rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
                                rOfretTb.Req_Qty = intCKDQty
                                rOfretTb.Req_Date = Now.ToString("yyyyMMdd")
                                retTb.Add(rOfretTb)
                                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", strRawPN, "TWM4", "", "", "", "", "PC", "", decInventory, "", "", _
                                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                                p1.Connection.Close()
                                Dim intATP As Integer = 0
                                For Each atpRow As GET_MATERIAL_ATP.BAPIWMDVE In atpTb
                                    intATP += atpRow.Com_Qty
                                Next
                                If intATP = 0 Then
                                    blOrderable = False
                                Else
                                    If intCKDQty <= intATP Then
                                        blOrderable = True
                                    Else
                                        blOrderable = False
                                    End If
                                End If
                            End If
                        Case Else
                            blOrderable = False
                    End Select
                    nr.Item("IsOrderable") = blOrderable
                    dtMBomRaw.Rows.Add(nr)
                End If
            Next
            dtMBOM = dtMBomRaw
            sapConn.Close()
            Return True
        End If
        Return False
    End Function

    Protected Sub btnCheckBOM_Click(sender As Object, e As System.EventArgs)
        lbMsg.Text = ""
        Dim dtMBOM As New DataTable, dlvPlant As String = "TWM8"
        dlvPlant = ""
        '20170206 TC: Per Sabrina.Lin's request add new item FWA-3231-CM00E for AHKD004, dlv-plant should be TWM8
        'If dlCKDPN.SelectedValue = "ARK-1120L-N5A1E" Then dlvPlant = "CKB3"
        'If dlCKDPN.SelectedValue = "9697BTK501E" Then dlvPlant = "ADM1"
        If GetMaterialBomAndMoQ(dlCKDPN.SelectedValue, dlvPlant, dtMBOM) Then
            ViewState("dtBOM") = dtMBOM
            gvBOM.DataSource = ViewState("dtBOM") : gvBOM.DataBind()
            Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "CalcSubTotal", "setTimeout('calcSubTotal(0);',500);", True)
            Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "EnableOrderButton", "$('#btnOrder2').prop('disabled',false);", True)
        Else
            lbMsg.Text = "No BOM data"
            Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "EnableOrderButton", "$('#btnOrder2').prop('disabled',true);", True)
        End If
    End Sub

    Function initFinalOrderQty(ByVal dBomQty As Double, ByVal intMoQ As Integer) As Integer
        Dim intQty As String = txtQty.Text
        If intMoQ = 0 Then intMoQ = 1
        'If Not Integer.TryParse(intQty, 0) OrElse CInt(intQty) <= 0 Then
        '    intQty = 1
        'End If

        ''20130826 TC: Per Sabrina's request that: Final order qty. doesn't need to consider MOQ at all, Final qty. column just carry exactly Request Qty. column data.
        'Dim intReqQty As Integer = Math.Ceiling(CInt(intQty) * dBomQty)
        'If intReqQty <= intQty Then
        '    Return intQty
        'Else
        '    Return intReqQty
        'End If
        '20170316 TC: Per Sabrina's request set final order qty=min. lot size
        Return intMoQ
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function PM_PlaceOrder(OrderLines As List(Of JSOrderLine), OrderQty As Integer, CKDMainItem As String) As String
        'Return "CKDMainItem:" + CKDMainItem
        Try
            Dim proxy1 As New SO_CREATE_COMMIT.SO_CREATE_COMMIT, OrderHeader As New SO_CREATE_COMMIT.BAPISDHD1, ItemIn As New SO_CREATE_COMMIT.BAPISDITMTable
            Dim PartNr As New SO_CREATE_COMMIT.BAPIPARNRTable, ScheLine As New SO_CREATE_COMMIT.BAPISCHDLTable, ConditionTable As New SO_CREATE_COMMIT.BAPICONDTable
            Dim strSoldToId As String = HttpContext.Current.Session("company_id"), strShipToId As String = HttpContext.Current.Session("company_id")
            Dim intCKDQty As Integer = IIf(OrderQty <= 0, 1, OrderQty)
            Dim strDlvPlant As String = "TWM8"
            OrderHeader.Doc_Type = "ZOR2" : OrderHeader.Sales_Org = "TW01" : OrderHeader.Distr_Chan = "10" : OrderHeader.Division = "00"
            'If strSoldToId = "T23164594" Then
            '    'For Advansus
            '    OrderHeader.Doc_Type = "ZOR" : OrderHeader.Sales_Org = "TW07" : OrderHeader.Distr_Chan = "10" : strDlvPlant = "ADM1"
            'Else
            '    'For ABR
            '    OrderHeader.Sales_Grp = "150" : OrderHeader.Sales_Off = "1500"
            'End If
            OrderHeader.Currency = "USD"

            Dim PartNr_Ship_Record As New SO_CREATE_COMMIT.BAPIPARNR
            PartNr_Ship_Record.Partn_Role = "WE" : PartNr_Ship_Record.Partn_Numb = strSoldToId
            PartNr.Add(PartNr_Ship_Record)
            Dim PartNr_Sold_Record As New SO_CREATE_COMMIT.BAPIPARNR
            PartNr_Sold_Record.Partn_Role = "AG" : PartNr_Sold_Record.Partn_Numb = strShipToId
            PartNr.Add(PartNr_Sold_Record)

            Dim intLineNo As Integer = 1

            For Each orderLine As JSOrderLine In OrderLines
                If orderLine.intIsOrderable = 1 Then
                    Dim Item_Record As New SO_CREATE_COMMIT.BAPISDITM, ScheLine_Record As New SO_CREATE_COMMIT.BAPISCHDL, conditionRow As New SO_CREATE_COMMIT.BAPICOND

                    Item_Record.Material = Global_Inc.Format2SAPItem(Trim(UCase(orderLine.strPN)))
                    Item_Record.Itm_Number = intLineNo.ToString()
                    '20140129 Hermit: ABR CKD Order's dlv plant should be always TWM4 for the time being
                    Item_Record.Plant = strDlvPlant
                    conditionRow.Itm_Number = intLineNo.ToString() : conditionRow.Cond_Type = "ZPN0" : conditionRow.Currency = "USD"
                    conditionRow.Cond_P_Unt = CDbl(orderLine.PriceUnit)
                    'conditionRow.Cond_Unit = "1"
                    'conditionRow.Cd_Unt_Iso = "ST" : conditionRow.Cond_P_Unt = "ST"
                    If orderLine.intFinalQty = 0 Then
                        conditionRow.Cond_Value = 0
                    Else
                        conditionRow.Cond_Value = orderLine.decSubTotal / orderLine.intFinalQty * CDbl(orderLine.PriceUnit)
                        'conditionRow.Cond_Value = orderLine.decSubTotal
                    End If
                    ConditionTable.Add(conditionRow)

                    Dim intCompQty As Integer = 0, intMinLotSize As Integer = IIf(orderLine.intMOQ = 0, 1, orderLine.intMOQ)
                    'intCompQty = IIf(orderLine.intFinalQty < orderLine.intMOQ, orderLine.intMOQ, orderLine.intFinalQty)
                    '20130806 TC: Per Sabrina's request, release MOQ constraint
                    intCompQty = orderLine.intFinalQty
                    ScheLine_Record.Itm_Number = Item_Record.Itm_Number
                    ScheLine_Record.Req_Qty = intCompQty
                    ScheLine_Record.Req_Date = Now.ToString("yyyyMMdd")
                    Item_Record.Ref_1 = "TC1234"
                    ItemIn.Add(Item_Record) : ScheLine.Add(ScheLine_Record)
                    intLineNo += 1

                End If
            Next

            'Util.DataTable2ExcelFile(ConditionTable.ToADODataTable(), HttpContext.Current.Server.MapPath("~/Files/") + "CKD_Cond_" + Now.ToString("yyyyMMddHHmmss") + ".xls")
            'Return ""
            'Dim ws As New aeu_ebus_dev9000.B2B_AEU_WS
            'ws.Timeout = -1
            'Dim strSONO As String = ""
            'If strSoldToId <> "T23164594" Then strSONO = ws.SO_GetNumber("QT")

            'Ryan 20180801 Get order number with new function
            Dim strSONO As String = ""
            If strSoldToId <> "T23164594" Then strSONO = SAPDAL.SAPDAL.SO_GetNumber("QT")


            proxy1.Connection = New SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings("SAP_PRD")) : proxy1.Connection.Open()
            Dim strError As String = "", strRelationType As String = "", strPConvert As String = "", strpintnumassign As String = ""
            Dim strPTestRun As String = "", Doc_Number As String = strSONO
            Dim retTable As New SO_CREATE_COMMIT.BAPIRET2Table
            Dim refDoc_Number As String = ""
            'Dim retDatatable As New DataTable
            OrderHeader.Compl_Dlv = "X"
            proxy1.Bapi_Salesorder_Createfromdat2( _
                strError, strRelationType, strPConvert, strpintnumassign, New SO_CREATE_COMMIT.BAPISDLS, _
                OrderHeader, New SO_CREATE_COMMIT.BAPISDHD1X, Doc_Number, New SO_CREATE_COMMIT.BAPI_SENDER, _
                strPTestRun, refDoc_Number, New SO_CREATE_COMMIT.BAPIPAREXTable, New SO_CREATE_COMMIT.BAPICCARDTable, _
                New SO_CREATE_COMMIT.BAPICUBLBTable, New SO_CREATE_COMMIT.BAPICUINSTable, New SO_CREATE_COMMIT.BAPICUPRTTable, _
                New SO_CREATE_COMMIT.BAPICUCFGTable, New SO_CREATE_COMMIT.BAPICUREFTable, New SO_CREATE_COMMIT.BAPICUVALTable, _
                New SO_CREATE_COMMIT.BAPICUVKTable, ConditionTable, New SO_CREATE_COMMIT.BAPICONDXTable, ItemIn, _
                New SO_CREATE_COMMIT.BAPISDITMXTable, New SO_CREATE_COMMIT.BAPISDKEYTable, PartNr, ScheLine, _
                New SO_CREATE_COMMIT.BAPISCHDLXTable, New SO_CREATE_COMMIT.BAPISDTEXTTable, New SO_CREATE_COMMIT.BAPIADDR1Table, retTable)

            If String.IsNullOrEmpty(refDoc_Number) = False Then
                proxy1.CommitWork()
            End If
            'dtSAPOrderProc = retTable.ToADODataTable()
            proxy1.Connection.Close()
            Dim HasErrReturn As Boolean = False
            For Each retRec As SO_CREATE_COMMIT.BAPIRET2 In retTable
                If retRec.Type = "E" Then
                    HasErrReturn = True : Exit For
                End If
            Next
            '******************Send Order Notice********************
            If String.IsNullOrEmpty(refDoc_Number) = False And HasErrReturn = False Then
                'Dim rsNonOrderRows As DataRow() = dtMBOM.Select("IsOrderable=0")
                Dim dtOrderLines As DataTable = Nothing
                While True
                    dtOrderLines = OraDbUtil.dbGetDataTable("SAP_PRD", _
                    " select a.posnr, a.matnr, a.arktx, a.netwr, a.waerk, a.kwmeng " + _
                    " from saprdp.vbap a where a.mandt='168' and a.VBELN='" + strSONO + "' order by a.posnr")
                    If dtOrderLines IsNot Nothing AndAlso dtOrderLines.Rows.Count > 0 Then Exit While
                    Threading.Thread.Sleep(1000)
                End While

                Dim blHasNonOrderable As Boolean = False
                For Each orderline As JSOrderLine In OrderLines
                    If orderline.intIsOrderable = 0 Then
                        blHasNonOrderable = True : Exit For
                    End If
                Next

                Dim sbMailBody As New System.Text.StringBuilder
                With sbMailBody
                    .AppendLine("Dear all,<br/><br/>")
                    .AppendFormat("{0} has placed a CKD order for Braview, SO No. is {1}, Part number is {2} x {3} pc(s).<br/><br/>", _
                                  HttpContext.Current.User.Identity.Name, strSONO, CKDMainItem, intCKDQty)

                    If blHasNonOrderable Then
                        .AppendLine("<font color='red'>Some of components are either phased out without inventory or not yet orderable:</font><br/>")
                        .AppendLine("<table width='400px' style='border-width:thin; border-style:solid'>")
                        .AppendLine("<tr><th>Part number</th></tr>")
                        For Each orderline As JSOrderLine In OrderLines
                            .AppendLine(String.Format("<tr><td>{0}</td></tr>", orderline.strPN))
                        Next
                        .AppendLine("</table>")
                    End If
                    Dim decTotal As Decimal = 0
                    .AppendLine("<br/><h3>Order Detail</h3><br/>")
                    .AppendLine("<table width='600px' style='border-width:thin; border-style:solid'>")
                    .AppendLine("<tr><th>Part number</th><th>Qty.</th><th>Subtotal (USD)</th></tr>")
                    For Each rowOrderLine As DataRow In dtOrderLines.Rows
                        .AppendLine(String.Format("<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>", _
                                                  Global_Inc.DeleteZeroOfStr(rowOrderLine.Item("matnr")), _
                                                  CInt(rowOrderLine.Item("kwmeng")).ToString(), FormatNumber(rowOrderLine.Item("netwr"), 2)))
                        decTotal += rowOrderLine.Item("netwr")
                    Next
                    .AppendFormat("<tr><td colspan='3' align='right'>Total ${0}</td></tr>", FormatNumber(decTotal, 2))
                    .AppendLine("</table>")


                    .AppendLine("<br/>Thank you.<br/>")
                    .AppendLine("<a mailto:'MyAdvantech@advantech.com'>MyAdvantech IT Team</a><br/>")
                End With
                Dim sm As New Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
                Dim msg As New Net.Mail.MailMessage("myadvantech@advantech.com", HttpContext.Current.User.Identity.Name)
                msg.IsBodyHtml = True
                msg.Body = sbMailBody.ToString()
                msg.Subject = "CKD order for Braview. SO NO: " + strSONO
                msg.CC.Add(HttpContext.Current.User.Identity.Name)
                msg.Bcc.Add("myadvantech@advantech.com")
                sm.Send(msg)
                sm.Dispose()
                Return "Order has been created, SO NO: " + refDoc_Number
            Else
                Dim sbSAPError As New System.Text.StringBuilder
                For Each retRow As SO_CREATE_COMMIT.BAPIRET2 In retTable
                    If retRow.Type = "E" Then
                        sbSAPError.Append(retRow.Message + ";")
                    End If
                Next
                'Util.DataTable2ExcelFile(ItemIn.ToADODataTable(), "D:\ItemInErr.xls")
                Return "Failed to create order. Reason: " + sbSAPError.ToString()
            End If
        Catch ex As Exception
            Return "Runtime error: " + ex.ToString()
        End Try

    End Function

    Public Class JSOrderLine
        Public Property intFinalQty As Integer : Public Property decSubTotal As Decimal : Public Property intMOQ As Integer
        Public Property strPN As String : Public Property intIsOrderable As Integer : Public Property PriceUnit As String
    End Class

    Protected Sub txtQty_TextChanged(sender As Object, e As System.EventArgs)
        If gvBOM.Rows.Count > 0 Then btnCheckBOM_Click(btnCheckBOM, New EventArgs())
    End Sub

    Protected Sub imgXls_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        If ViewState("dtBOM") Is Nothing Then
            Dim dtMBOM As New DataTable
            If GetMaterialBomAndMoQ(dlCKDPN.SelectedValue, "TWM4", dtMBOM) Then
                ViewState("dtBOM") = dtMBOM
            End If
        End If
        If ViewState("dtBOM") IsNot Nothing Then
            Util.DataTable2ExcelDownload(ViewState("dtBOM"), dlCKDPN.SelectedValue + "_BOM.xls")
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript" src="http://code.jquery.com/jquery-latest.min.js"></script>
    <script type="text/javascript">
        $(document).ready(
            function () {

                //$('#<%=lbMsg.ClientID %>').html("haha");
                $('#<%=btnCheckBOM.ClientID %>').click(
                    function () {
                        setTimeout("disableBtn('<%=btnCheckBOM.ClientID %>');", 100);
                    }
                );

                $('#<%=btnOrder.ClientID %>').click(
                    function () {
                        setTimeout("disableBtn('<%=btnCheckBOM.ClientID %>');", 100);
                    }
                );

                $('#btnOrder2').click(
                    function () {
                        $(this).prop('disabled', true); $('#imgLoadingOrder').css('display', 'block'); $("body").css("cursor", "progress");
                        var orderQty = $('#<%=txtQty.ClientID %>').val(); var ckdMainItem = $('#<%=dlCKDPN.ClientID %>').val();
                        //console.log('ckdMainItem:'+ckdMainItem);
                        var orderLines = new Array(); var dataindex = 0; var bomrows = $('.bomrow');
                        if (bomrows) {
                            bomrows.each(function () {
                                //orderLines.push(new orderLine($(this).find('.finalqty').prop('value'), $(this).find('.subtotal').prop('value')));
                                var isOrderable = $(this).find('.isorderable').prop('value');
                                var orderLine = {
                                    intFinalQty: $(this).find('.finalqty').prop('value'), decSubTotal: $(this).find('.subtotal').prop('value'),
                                    intMOQ: $(this).find('.moq').prop('value'), strPN: $(this).find('.partno').prop('value'),
                                    intIsOrderable: isOrderable, PriceUnit: $(this).find('.priceunit').prop('value')
                                };
                                orderLines.push(orderLine);

                            }
                            );
                        }
                        var postData = JSON.stringify({ OrderLines: orderLines, OrderQty: orderQty, CKDMainItem: ckdMainItem });
                        //console.log(dataToSend);
                        $.ajax({
                            type: "POST", url: "CKD_Ordering.aspx/PM_PlaceOrder", data: postData, contentType: "application/json; charset=utf-8", dataType: "json",
                            success: function (msg) {
                                //console.log('called PM_PlaceOrder ok:' + msg.d);
                                $(this).prop('disabled', false); $('#<%=lbMsg.ClientID %>').html(msg.d); $('#imgLoadingOrder').css('display', 'none'); $("body").css("cursor", "auto");
                            },
                            error: function (msg) {
                                //console.log('err calling PM_PlaceOrder ' + msg);
                                $(this).prop('disabled', false); $('#<%=lbMsg.ClientID %>').html(msg.d); $('#imgLoadingOrder').css('display', 'none'); $("body").css("cursor", "auto");
                            }
                        });
                    }
                );
                //calcSubTotal(0);
            }
        );

                    function disableBtn(btnid) {
                        $('#' + btnid).prop('disabled', true);
                    }

                    function calcSubTotal(rowIdx) {
                        //console.log('calc');
                        var bomrows = $('.bomrow');
                        if (bomrows) {
                            bomrows.each(
                                function (index, value) {
                                    if (rowIdx == 0 || rowIdx == index) {
                                        calcRowSubTotal($(this).find('.subtotal'), $(this).find('.finalqty'), $(this).find('.usdcost'));
                                        $(this).find('.finalqty').change(function () {
                                            calcSubTotal(index);
                                        }
                                    );
                                    }
                                }
                            );
                        }
                    }

                    function calcRowSubTotal(subTotalNode, finalQtyNode, usdCostNode) {
                        subTotalNode.prop('value', (finalQtyNode.prop('value') * usdCostNode.prop('innerText')).toFixed(5));
                    }

    </script>
    <asp:Panel runat="server" ID="panel1" DefaultButton="btnCheckBOM">
        <h2>Place CKD Order for
            <div runat="server" id="divCompName" style="display: inline"></div>
        </h2>
        <table>
            <tr>
                <th align="right">Part Number:
                </th>
                <td>
                    <asp:DropDownList runat="server" ID="dlCKDPN">
                        <asp:ListItem Value="FWA-3231-CM00E" Selected="True" />
                        <asp:ListItem Value="MIO-5271UT-S9A1E" />
                        <asp:ListItem Value="DAC-BT02N-LC0A2E" Enabled="false" />
                        <asp:ListItem Value="POD-A803-00A2E" Enabled="false" />
                        <asp:ListItem Value="ARK-1120L-N5A1E" Enabled="false" />
                        <asp:ListItem Value="9697BTK501E" Enabled="false" />
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <th align="right">Qty:
                </th>
                <td>
                    <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="filter1" TargetControlID="txtQty"
                        FilterType="Numbers" FilterMode="ValidChars" />
                    <asp:TextBox runat="server" ID="txtQty" Text="1" Width="30px" AutoPostBack="true" OnTextChanged="txtQty_TextChanged" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Button runat="server" ID="btnCheckBOM" Text="Explode BOM" OnClick="btnCheckBOM_Click" />
                </td>
                <td>
                    <table style="display:none">
                        <tr>
                            <td>
                                <input type="button" id="btnOrder2" value="Place Order" disabled="disabled" />
                                <asp:Button runat="server" ID="btnOrder" Text="Order" Enabled="false" Visible="false" />
                            </td>
                            <td>
                                <img src="../Images/loading.gif" style="display: none" alt="Loading..." id="imgLoadingOrder" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <asp:Label runat="server" ID="lbMsg" Font-Bold="true" ForeColor="Tomato" Width="800px" />
        <br />
        <ajaxToolkit:TabContainer runat="server" ID="tabcon1" Visible="false">
            <ajaxToolkit:TabPanel runat="server" ID="tabBOM" HeaderText="BOM">
                <ContentTemplate>
                    <asp:ImageButton runat="server" ID="imgXls" ImageUrl="~/Images/excel.gif" AlternateText="Download Excel" OnClick="imgXls_Click" />
                    <asp:GridView runat="server" ID="gvBOM" Width="100%" AutoGenerateColumns="false"
                        RowStyle-CssClass="bomrow">
                        <Columns>
                            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <%#Container.DataItemIndex + 1%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Component" DataField="PART_NO" ItemStyle-Width="20%" />
                            <asp:BoundField HeaderText="Description" DataField="PRODUCT_DESC" ItemStyle-Width="10%" />
                            <asp:BoundField HeaderText="BOM Qty." DataField="BOM_QTY" ItemStyle-Width="10%" />
                            <asp:TemplateField HeaderText="Request Qty." ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <p class="bomqty">
                                        <%#Math.Ceiling(Eval("BOM_QTY") * CInt(txtQty.Text))%>
                                    </p>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Minimum Lot Size" DataField="MOQ" ItemStyle-HorizontalAlign="Center"
                                ItemStyle-Width="20%" />
                            <asp:TemplateField HeaderText="Final Order Qty." ItemStyle-Width="10%">
                                <ItemTemplate>
                                    <input type="text" class="finalqty" value='<%#initFinalOrderQty(Eval("BOM_QTY"),Eval("MOQ")) %>'
                                        style="width: 50px" />
                                    <%--<input type="text" class="finalqty" value='<%#initFinalOrderQty(Eval("PART_NO")) %>'
                                        style="width: 50px" />--%>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="USD Cost (per piece)" ItemStyle-HorizontalAlign="Right"
                                ItemStyle-Width="15%">
                                <ItemTemplate>
                                    <p class="usdcost">
                                        <%#Eval("USD_COST")%>
                                    </p>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Subtotal (USD)" ItemStyle-Width="10%">
                                <ItemTemplate>
                                    <input class="subtotal" type="text" value='' style="width: 90px" />
                                    <input type="hidden" class="isorderable" value='<%#IIf(Eval("IsOrderable") = True, 1, 0)%>' />
                                    <input type="hidden" class="moq" value='<%#Eval("MOQ") %>' />
                                    <input type="hidden" class="partno" value='<%#Eval("PART_NO") %>' />
                                    <input type="hidden" class="priceunit" value='<%#Eval("PEINH_USD") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Product Status" DataField="PRODUCT_STATUS" ItemStyle-Width="15%"
                                ItemStyle-HorizontalAlign="Center" />
                            <asp:TemplateField HeaderText="Is Orderable?" ItemStyle-Width="10%" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <%#IIf(Eval("IsOrderable") = True, "Y", "N")%>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel runat="server" ID="tabSAPProc" HeaderText="Order Process Result"
                Visible="false">
                <ContentTemplate>
                    <asp:GridView runat="server" ID="gvSAPProcLog" Visible="false" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel runat="server" ID="tabOrderHeader" HeaderText="Order Header"
                Visible="false">
                <ContentTemplate>
                    <div id="divHeader">
                    </div>
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel runat="server" ID="tabPartner" HeaderText="Partner" Visible="false">
                <ContentTemplate>
                    <asp:GridView runat="server" ID="gvPartner" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel runat="server" ID="tabCond" HeaderText="Conditions" Visible="false">
                <ContentTemplate>
                    <asp:GridView runat="server" ID="gvCond" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel runat="server" ID="tabSch" HeaderText="Schedules" Visible="false">
                <ContentTemplate>
                    <asp:GridView runat="server" ID="gvSch" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
            <ajaxToolkit:TabPanel runat="server" ID="tabItems" HeaderText="Items" Visible="false">
                <ContentTemplate>
                    <asp:GridView runat="server" ID="gvItems" />
                </ContentTemplate>
            </ajaxToolkit:TabPanel>
        </ajaxToolkit:TabContainer>
    </asp:Panel>
</asp:Content>
