<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Sub initShipConDrp()
        'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
        'Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct VSBED AS SHIPCONDITION,'' as SHIPCONTXT from SAP_SHIPCONDITION_BY_PLANT where WERKS like '" & Session("org") & "%'"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("my", String.Format("select distinct VSBED AS SHIPCONDITION,'' as SHIPCONTXT from SAP_SHIPCONDITION_BY_PLANT where WERKS like '" & Left(Session("org_id"), 2) & "%'"))
        If dt.Rows.Count > 0 Then
            For I As Integer = 0 To dt.Rows.Count - 1
                dt.Rows(I).Item("SHIPCONTXT") = Glob.shipCode2Txt(dt.Rows(I).Item("SHIPCONDITION"))
            Next
        End If
        Me.drpShipCondition.DataSource = dt
        Me.drpShipCondition.DataTextField = "SHIPCONTXT"
        Me.drpShipCondition.DataValueField = "SHIPCONDITION"
        Me.drpShipCondition.DataBind()
    End Sub

    Protected Sub drpShipCondition_Load(sender As Object, e As System.EventArgs)
        For Each item As ListItem In drpShipCondition.Items
            item.Attributes.Add("onclick", "selectclick();")
        Next
    End Sub

    Protected Sub btnSentError_Click(sender As Object, e As System.EventArgs)
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Util.SendEmailWithAttachment("eBusiness.AEU@advantech.eu", "eBusiness.AEU@advantech.eu", "Error reading excel to dt", _
                          "", True, "", "ming.zhao@advantech.com.cn", New System.IO.MemoryStream(Me.FileUpload1.FileBytes), FileUpload1.PostedFile.FileName)
        End If
    End Sub
    Dim mycart As New CartList("b2b", "cart_detail_v2")
    Dim myOrderMaster As New order_Master("b2b", "order_master")
    Dim myOrderDetail As New order_Detail("b2b", "order_detail")
    Sub initDT(ByRef DT As DataTable)
        DT.Columns.Add("Part No", GetType(String))
        DT.Columns.Add("Qty", GetType(Integer))
        DT.Columns.Add("Request Date", GetType(Date))
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Util.IsInternalUser(Session("user_id")) = False Then
                'If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then Response.Redirect(Request.ServerVariables("HTTP_REFERER"))
                If AuthUtil.IsCanPlaceOrder(Session("user_id")) = False Then Response.Redirect("~/home.aspx")
            End If
            If Session("user_id") IsNot Nothing AndAlso Session("user_id") <> "ming.zhao@advantech.com.cn" Then
                btnSentError.Visible = False
            End If
            Dim dt As New DataTable
            initDT(dt)
            Me.gv1.DataSource = dt
            Me.gv1.DataBind()
            initShipConDrp()
        End If
    End Sub
    Function upload() As System.IO.Stream
        If Me.FileUpload1.PostedFile.ContentLength > 0 Then
            Dim MSM As New System.IO.MemoryStream(Me.FileUpload1.FileBytes)
            'Me.FileUpload1.SaveAs(fileName)
            Return MSM
        End If
        Return Nothing
    End Function
    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim filename As System.IO.Stream = upload()
        If Not IsNothing(filename) Then
            Try
                preview(filename)
            Catch ex As Exception
                If Me.FileUpload1.PostedFile.ContentLength > 0 Then
                    Util.SendEmailWithAttachment("eBusiness.AEU@advantech.eu", "eBusiness.AEU@advantech.eu", "UploadOrderFromExcel_Adv.aspx : Error reading excel to dt", _
                                  ex.ToString(), True, "", "ming.zhao@advantech.com.cn", New System.IO.MemoryStream(Me.FileUpload1.FileBytes), FileUpload1.PostedFile.FileName)
                End If
            End Try
        End If
    End Sub
    Sub preview(ByVal fileName As System.IO.Stream)
        Dim tempds As DataSet = ExcelFile2DataTable(fileName, 1, 0)
        If tempds Is Nothing Then Exit Sub
        Dim tempdt As DataTable = tempds.Tables(0)
        If tempdt.Rows.Count <= 0 Then
            Glob.ShowInfo("No data be uploaded.")
            Exit Sub
        End If
        If tempdt.Columns.Count < 2 Then
            Glob.ShowInfo("The uploaded excel file is in invalid format. Please download and use sample excel file.")
            Exit Sub
        End If
        'Dim dt As New DataTable
        'initDT(dt)
        'For Each r As DataRow In tempdt.Rows
        '    Dim rr As DataRow = dt.NewRow
        '    rr.Item("Part No") = r.Item(0)
        '    rr.Item("Qty") = CInt(r.Item(1))
        '    rr.Item("Request Date") = CDate(r.Item(2))
        '    dt.Rows.Add(rr)
        'Next
        'OrderUtilities.showDT(tempdt)
        Me.gv1.DataSource = tempdt
        ViewState("Cart") = tempdt
        Me.gv1.DataBind()
        If tempds.Tables.Count = 2 Then

            Dim tempdt2 As DataTable = tempds.Tables(1)
            ' OrderUtilities.showDT(tempdt2)
            Me.gv2.DataSource = tempdt2
            ViewState("CartInfo") = tempdt2
            Me.gv2.DataBind()
        End If
     
    End Sub

    Protected Sub btnImPort_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        import()
    End Sub
    Sub import()
        If Session("cart_id") Is Nothing OrElse Session("cart_id").ToString = "" Then Exit Sub
        Dim CartId As String = Session("cart_id").ToString()
        If Not IsNothing(ViewState("Cart")) Then
            Dim dttemp As DataTable = CType(ViewState("Cart"), DataTable)
            If dttemp.Rows.Count <= 0 Then
                Glob.ShowInfo("No data be uploaded.")
                Exit Sub
            End If
            'Dim dt As New DataTable
            'initDT(dt)
            'For Each r As DataRow In dttemp.Rows
            '    Dim rr As DataRow = dt.NewRow
            '    rr.Item("Part No") = r.Item(0)
            '    rr.Item("Qty") = r.Item(1)
            '    dt.Rows.Add(rr)
            'Next
            Dim dt As DataTable = dttemp
            If dt.Rows.Count > 0 Then
                'mycart.Delete(String.Format("cart_id='{0}'", CartId))
                MyCartX.DeleteCartAllItem(CartId)
                Dim msg As String = String.Empty
                For Each r As DataRow In dt.Rows
                    If Not IsDBNull(r.Item("Part No")) AndAlso r.Item("Part No") IsNot Nothing AndAlso r.Item("Part No").ToString() <> "" Then
                        Dim partNo As String = r.Item("Part No")
                        Dim qty As Integer = r.Item("Qty")
                        Dim EWFLAG As Integer = 0
                        Dim RequestDate As Date = #12:00:00 AM#
                        If Date.TryParse(r.Item("Request Date"), Now) Then
                            RequestDate = CDate(r.Item("Request Date"))
                        End If
                        'Response.Write(RequestDate.ToString())
                        'mycart.ADD2CART_V2(Session("cart_id"), partNo, qty, EWFLAG, 0, "", 1, 1, RequestDate, "", "", 0, False)
                        msg = ""
                        MyCartOrderBizDAL.Add2Cart_BIZ(Session("cart_id"), partNo, qty, EWFLAG, 0, "", 1, 1, RequestDate, "", "", 0, False, msg)
                    End If
                Next
                
                Dim dtCartInfo As DataTable = CType(ViewState("CartInfo"), DataTable)
                If dtCartInfo IsNot Nothing AndAlso dtCartInfo.Rows.Count > 0 Then
                    Dim _UPLOAD_ORDER_DA As New MyCartDSTableAdapters.UPLOAD_ORDER_PARATableAdapter
                    Dim _PO As String = dtCartInfo.Rows(0).Item("Customer PO").ToString
                    Dim _Ship_Condition As String = dtCartInfo.Rows(0).Item("Ship Condition").ToString
                    Dim _Ship_To As String = dtCartInfo.Rows(0).Item("Ship To").ToString
                    _UPLOAD_ORDER_DA.Delete(CartId)
                    _UPLOAD_ORDER_DA.Insert(CartId, _PO, _Ship_To, _Ship_Condition, Now, Session("User_ID"))
                End If
            End If
            Response.Redirect("~/Order/Cart_listV2.aspx")
            'DBfromCart2Order(CartId)
          
        End If
    End Sub
    
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsNothing(ViewState("Cart")) Then
            Try
                Dim dt As DataTable = CType(ViewState("Cart"), DataTable)
                If dt.Rows.Count > 0 Then
                    Me.btnImPort.Visible = True
                End If
            Catch ex As Exception

            End Try
        End If
    End Sub
    Public Shared Function ExcelFile2DataTable(ByVal fs As System.IO.Stream, ByVal startRow As Integer, ByVal startColumn As Integer) As DataSet
        Util.SetASPOSELicense()
        Dim ds As New DataSet
        Try
            For p As Integer = 0 To 1
                Dim dt As New DataTable
                Dim wb As New Aspose.Cells.Workbook
                wb.Open(fs)
                Dim SheetCurrentIndex As Integer = p
                For i As Integer = startColumn To wb.Worksheets(0).Cells.Columns.Count - 1
                    If wb.Worksheets(SheetCurrentIndex).Cells(0, i).Value IsNot Nothing AndAlso wb.Worksheets(SheetCurrentIndex).Cells(0, i).Value.ToString <> "" Then
                        dt.Columns.Add(wb.Worksheets(SheetCurrentIndex).Cells(0, i).Value)
                    Else
                        Exit For
                    End If
                Next
                For i As Integer = startRow To wb.Worksheets(SheetCurrentIndex).Cells.Rows.Count - 1
                    Dim r As DataRow = dt.NewRow
                    For j As Integer = 0 To dt.Columns.Count - 1
                        r.Item(j) = wb.Worksheets(SheetCurrentIndex).Cells(i, j).Value
                    Next
                    dt.Rows.Add(r)
                Next
                dt.AcceptChanges()
                ds.Tables.Add(dt)
            Next
        Catch ex As Exception
            Util.SendEmail("eBusiness.AEU@advantech.eu", "ebiz.aeu@advantech.eu", "error reading excel to dt", ex.ToString(), False, "", "")
            Return Nothing
        End Try
        Return ds
    End Function
    Sub DBfromCart2Order(ByVal Cart_ID As String)
        If Not IsNothing(ViewState("CartInfo")) Then
            Dim dtInfo As DataTable = CType(ViewState("CartInfo"), DataTable)
            If dtInfo.Rows.Count <= 0 Then
                Glob.ShowInfo("No data be uploaded!")
                Exit Sub
            End If
            myOrderMaster.Delete(String.Format("order_id='{0}'", Cart_ID))
            myOrderDetail.Delete(String.Format("order_id='{0}'", Cart_ID))
            Dim ORDER_ID As String = Cart_ID
            Dim ORDER_NO As String = ""
            Dim ORDER_TYPE As String = "ZOR2"
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Session("Org") = "US" And Session("RBU") <> "AAC" Then
            '    ORDER_TYPE = "AG"
            'End If
            'If Session("Org") = "CN" Then
            '    ORDER_TYPE = "ZOR"
            'End If
            If Left(Session("org_id"), 2) = "US" And Session("RBU") <> "AAC" Then
                ORDER_TYPE = "AG"
            End If
            If Left(Session("org_id"), 2) = "CN" Then
                ORDER_TYPE = "ZOR"
            End If

            Dim PO_NO As String = Util.ReplaceSQLStringFunc(dtInfo.Rows(0).Item("Customer PO"))
            Dim PO_DATE As DateTime = Now.Date ' IIf(Me.txtPODate.Text.Trim = "", Now.Date, Me.txtPODate.Text)
       
            Dim SOLDTO_ID As String = Session("company_id")
            Dim SHIPTO_ID As String = dtInfo.Rows(0).Item("Ship To").Trim.Replace("'", "''")
            If Not MYSAPBIZ.is_Valid_Company_Id_All(SHIPTO_ID) Then
                SHIPTO_ID = SOLDTO_ID
            End If
            Dim ATTENTION As String = "" 'Util.ReplaceSQLStringFunc(Me.txtAttention.Text.Trim)
            Dim PARTIALFLAG As String = "1" 'Me.rbtnIsPartial.SelectedValue
            Dim MREQDATE As Date = Now.Date ' CDate(IIf(Me.txtreqdate.Text.Trim = "", Now.Date, Me.txtreqdate.Text.Trim))
            Dim MDUEDATE As Date = Now.Date
            Dim SHIPVIA As String = ""
            Dim CURRENCY As String = Session("Company_currency")
            Dim ORDER_NOTE As String = "" ' Util.ReplaceSQLStringFunc(Me.txtOrderNote.Text.Trim)
            'If Me.chxNewShip.Checked Then
            '    Dim shipInfo As String = String.Format("[Addr:{0};Tel:{1}]", Util.ReplaceSQLStringFunc(Me.txtShipToAddr.Text.Trim), Util.ReplaceSQLStringFunc(Me.txtShipToTel.Text.Trim))
            '    ORDER_NOTE = ORDER_NOTE & " " & shipInfo
            'End If
            Dim INCOTERM As String = "" 'Me.drpIncoterm.SelectedValue
            Dim CUSTOMER_ATTENTION As String = "" 'Util.ReplaceSQLStringFunc(Me.txtShipToAttention.Text.Trim)
            Dim INCOTERM_TEXT As String = "" 'Util.ReplaceSQLStringFunc(Me.txtIncoterm.Text.Trim)
            Dim SALES_NOTE As String = "" 'Util.ReplaceSQLStringFunc(Me.txtSalesNote.Text.Trim)
            Dim OP_NOTE As String = "" 'Util.ReplaceSQLStringFunc(Me.txtOPNote.Text.Trim)
            Dim SHIP_CONDITION As String = "" 'Me.drpShipCondition.SelectedValue
            If Not IsDBNull(dtInfo.Rows(0).Item("Ship Condition")) AndAlso dtInfo.Rows(0).Item("Ship Condition").ToString.Trim <> "" Then
                Dim shiptext As String = dtInfo.Rows(0).Item("Ship Condition").ToString.Trim
                If drpShipCondition.Items.FindByText(shiptext) IsNot Nothing Then
                    Dim item As ListItem = drpShipCondition.Items.FindByText(shiptext)
                    SHIP_CONDITION = item.Value.Trim
                End If
            End If
            If SHIP_CONDITION.Trim = "" Then
                Glob.ShowInfo("The ship condition you uploaded does not match with any of our ship conditions.")
                Exit Sub
            End If
            Dim prj_Note As String = "" 'Util.ReplaceSQLStringFunc(Me.txtPJNote.Text.Trim)
            Dim ISESE As String = ""
            Dim ERE As String = ""
            Dim EC As String = ""
            Dim PAR1 As String = ""
            If Not IsNothing(Request("ISESE")) AndAlso Request("ISESE") <> "" Then
                ISESE = Request("ISESE")
            End If
            If Not IsNothing(Request("ERE")) AndAlso Request("ERE") <> "" Then
                ERE = Request("ERE")
            End If
            If Not IsNothing(Request("EC")) AndAlso Request("EC") <> "" Then
                EC = Request("EC")
            End If
            If Not IsNothing(Request("PAR1")) AndAlso Request("PAR1") <> "" Then
                PAR1 = Request("PAR1")
            End If
        
        
        
            Dim DT As DataTable = mycart.GetDT(String.Format("cart_id='{0}'", Cart_ID), "Line_no")
            If DT.Rows.Count > 0 Then
                Dim dtEW As New DataTable
                dtEW.Columns.Add("Line_No")
                dtEW.Columns.Add("Part_No")
                dtEW.Columns.Add("otype")
                dtEW.Columns.Add("qty")
                dtEW.Columns.Add("req_date")
                dtEW.Columns.Add("due_date")
                dtEW.Columns.Add("islinePartial")
                dtEW.Columns.Add("UNIT_PRICE", GetType(Decimal))
                dtEW.Columns.Add("delivery_plant")
                dtEW.Columns.Add("DMF_Flag")
                dtEW.Columns.Add("OptyID")
            
                Dim count As Integer = 0
                For Each r As DataRow In DT.Rows
                    Dim LINE_NO As Integer = r.Item("line_no")
                    Dim PRODUCT_LINE As String = ""
                    Dim PART_NO As String = r.Item("part_no")
                    Dim ORDER_LINE_TYPE As String = r.Item("otype")
                    Dim QTY As Integer = r.Item("qty")
                    Dim LIST_PRICE As Decimal = r.Item("list_price")
                    Dim UNIT_PRICE As Decimal = r.Item("unit_price")
                    Dim REQUIRED_DATE As Date = Now.Date
                    If IsDate(r.Item("req_date")) Then
                        MREQDATE = CDate(r.Item("req_date"))
                    End If
                    If r.Item("otype") = 0 Then
                        REQUIRED_DATE = MREQDATE
                    Else
                        Dim temp As String = MyCartOrderBizDAL.getBTOChildDueDate(MREQDATE.ToString("yyyy/MM/dd"), Session("org_id"))
                        If CDate(temp) > Now.Date Then
                            REQUIRED_DATE = temp
                        End If
                    End If
                    Dim DUE_DATE As Date = r.Item("due_date")
                    Dim ERP_SITE As String = ""
                    Dim ERP_LOCATION As String = ""
                    Dim AUTO_ORDER_FLAG As Char = ""
                    Dim AUTO_ORDER_QTY As Integer = 0
                    Dim SUPPLIER_DUE_DATE As Date = DUE_DATE
                    Dim LINE_PARTIAL_FLAG As Integer = 0
                    Dim RoHS_FLAG As String = r.Item("rohs")
                    Dim EXWARRANTY_FLAG As String = r.Item("ew_flag")
                    Dim CustMaterialNo As String = r.Item("custMaterial")
                    Dim DeliveryPlant As String = r.Item("delivery_plant")
                    If Session("company_id") = "SAID" Then
                        'DeliveryPlant = Me.drpDelPlant.SelectedValue
                    End If
                    Dim NoATPFlag As String = r.Item("satisfyflag")
                    Dim DMF_Flag As String = ""
                    Dim OptyID As String = r.Item("QUOTE_ID")
                    Dim Cate As String = r.Item("category")
                    SAPtools.getInventoryAndATPTable(PART_NO, DeliveryPlant, QTY, DUE_DATE, 0, Nothing, REQUIRED_DATE)
                    If MDUEDATE < DUE_DATE Then
                        MDUEDATE = DUE_DATE
                    End If
                
                    myOrderDetail.Add(ORDER_ID, LINE_NO, PRODUCT_LINE, PART_NO, ORDER_LINE_TYPE, QTY, LIST_PRICE, UNIT_PRICE, REQUIRED_DATE, DUE_DATE, ERP_SITE, ERP_LOCATION, AUTO_ORDER_FLAG, AUTO_ORDER_QTY, SUPPLIER_DUE_DATE, LINE_PARTIAL_FLAG, RoHS_FLAG, EXWARRANTY_FLAG, CustMaterialNo, DeliveryPlant, NoATPFlag, DMF_Flag, OptyID, Cate)
               
                    If CInt(EXWARRANTY_FLAG) > 0 Then
                        count = count + 1
                        If ORDER_LINE_TYPE <> -1 Then
                            Dim EWR As DataRow = dtEW.NewRow
                            EWR.Item("line_no") = LINE_NO + count
                            EWR.Item("part_no") = Glob.getEWItemByMonth(EXWARRANTY_FLAG)
                            EWR.Item("otype") = ORDER_LINE_TYPE
                            EWR.Item("qty") = QTY
                            EWR.Item("req_date") = REQUIRED_DATE
                            EWR.Item("due_date") = DUE_DATE
                            EWR.Item("islinePartial") = LINE_PARTIAL_FLAG
                            EWR.Item("unit_price") = Glob.getRateByEWItem(EWR.Item("part_no"), DeliveryPlant) * UNIT_PRICE
                            EWR.Item("delivery_plant") = DeliveryPlant
                            EWR.Item("DMF_Flag") = DMF_Flag
                            EWR.Item("OptyID") = OptyID
                            dtEW.Rows.Add(EWR)
                        End If
                    End If
                Next
                If dtEW.Rows.Count > 0 Then
                    If myOrderDetail.isBtoOrder(Cart_ID) Then
                        Dim Line_no As Integer = myOrderDetail.getMaxLineNo(Cart_ID) + 1
                        Dim part_no As String = dtEW.Rows(0).Item("part_no")
                        Dim otype As Integer = dtEW.Rows(0).Item("otype")
                        Dim qty As Integer = dtEW.Rows(0).Item("qty")
                        Dim req_date As DateTime = MREQDATE
                        Dim due_date As DateTime = MDUEDATE
                        Dim linePartialFlag As Integer = dtEW.Rows(0).Item("islinePartial")
                        Dim unit_Price As Decimal = dtEW.Compute("sum(unit_price)", "")
                        Dim delivery_plant As String = dtEW.Rows(0).Item("delivery_plant")
                        Dim dmf_flag As String = dtEW.Rows(0).Item("DMF_Flag")
                        Dim optyid As String = dtEW.Rows(0).Item("OptyID")
                        myOrderDetail.Add(ORDER_ID, Line_no, "", part_no, otype, qty, unit_Price, unit_Price, req_date, due_date, "", "", "", 0, due_date, linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid)
                    Else
                        For Each r As DataRow In dtEW.Rows
                            Dim line_no As Integer = r.Item("line_no")
                            Dim part_no As String = r.Item("part_no")
                            Dim otype As Integer = r.Item("otype")
                            Dim qty As Integer = r.Item("qty")
                            Dim req_date As DateTime = r.Item("req_date")
                            Dim due_date As DateTime = r.Item("due_date")
                            Dim linePartialFlag As Integer = r.Item("islinePartial")
                            Dim unit_price As Decimal = r.Item("unit_price")
                            Dim delivery_plant As String = r.Item("delivery_plant")
                            Dim dmf_flag As String = r.Item("DMF_Flag")
                            Dim optyid As String = r.Item("OptyID")
                            myOrderDetail.reSetLineNoBeforeInsert(Cart_ID, line_no)
                            myOrderDetail.Add(ORDER_ID, line_no, "", part_no, otype, qty, unit_price, unit_price, req_date, due_date, "", "", "", 0, due_date, linePartialFlag, 1, 0, "", delivery_plant, 0, dmf_flag, optyid)
                        Next
                    End If
                End If
            End If
            If myOrderDetail.isBtoOrder(ORDER_ID) Then
                MDUEDATE = MyCartOrderBizDAL.getBTOParentDueDate(MDUEDATE.ToString("yyyy/MM/dd"))
                If MDUEDATE < MREQDATE Then
                    MDUEDATE = MREQDATE
                End If
            End If
            myOrderMaster.Add(ORDER_ID, ORDER_NO, ORDER_TYPE, PO_NO, PO_DATE, SOLDTO_ID, SHIPTO_ID, CURRENCY, MREQDATE, "", "", Now, "", ATTENTION, PARTIALFLAG, "", "", 0, 0, "", "", MDUEDATE, "", SHIPVIA, ORDER_NOTE, "", 0, 0, Now, Now, Session("user_Id"), CUSTOMER_ATTENTION, "", INCOTERM, INCOTERM_TEXT, SALES_NOTE, OP_NOTE, SHIP_CONDITION, "", "", "", "", prj_Note, ISESE, ERE, EC, PAR1)
            myOrderDetail.Update(String.Format("ORDER_ID='{0}' and ORDER_LINE_TYPE=-1", ORDER_ID), String.Format("due_date='{0}',required_date='{1}'", MDUEDATE, MREQDATE))
        End If
        Response.Redirect("~/Order/DueDateReset.aspx?NO=" & Cart_ID)
    End Sub

    Protected Sub Page_PreInit(sender As Object, e As System.EventArgs)

    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table>
        <tr>
            <td class="menu_title">
                Upload Order File to Cart
            </td>
        </tr>
        <tr>
            <td style="border: 1px solid #d7d0d0; padding: 10px">
                <table>
                    <tr>
                        <td>
                            <asp:FileUpload ID="FileUpload1" runat="server" />
                            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
                            <asp:Button ID="btnSentError" runat="server" Text="Upload" OnClick="btnSentError_Click" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    <hr />
    <p style="margin-left: 10px">
    <table>
    <tr>
    <td valign="top">
    <b>Use this interface to upload your order via a MS Excel spreadsheet, listing product
            numbers and quantities. </b>
        <br />
        <br />
        1. Fill out the spreadsheet with the columns as shown below. (Note: It is necessary
        to use the full Advantech product numbers. Ex.: AIMB-554G2-00A1E)
        <br />
        2. Choose the File Format of your upload
        <br />
        3. Click "Browse" to choose the file on your system
        <br />
        4. Once selected, click "Upload"
    </td>
    <td width="0"  style="display:none;" valign="top" align="left"><b>Ship Condition: </b>
        <asp:ListBox runat="server" ID="drpShipCondition" Width="200" Height="90" OnLoad="drpShipCondition_Load"></asp:ListBox>
        <input  id="copydiv" style="width:200px;border: none;margin-top: 5px;"></input>
    </td>
    </tr>
    </table>
        
    </p>
    <asp:GridView runat="server" ID="gv1" Width="100%" AllowPaging="false" AutoGenerateColumns="true" ShowHeaderWhenEmpty="true">
    </asp:GridView>
    <hr />
    <asp:GridView runat="server" ID="gv2" Width="100%" AllowPaging="false" AutoGenerateColumns="true" ShowHeaderWhenEmpty="true">
    </asp:GridView>
    <table width="100%">
        <tr>
            <td align="center">
                <asp:Button ID="btnImPort" runat="server" Text="Import2Cart" OnClick="btnImPort_Click" Visible="false"/>
            </td>
        </tr>
    </table>
    <hr />
    <table>
      <tr>
    <td>
   <asp:HyperLink NavigateUrl="~/files/CartSample_new2012.xls" runat="server" ID="HLKExcelSample" Text="Click Here for Downloadable Sample (MS Excel)"></asp:HyperLink>
    </td>
    </tr>
    <tr>
    <td>
   <asp:Image ImageUrl="~/files/excelSample2.png" runat="server" ID="imgExcelSample" />
    </td>
    </tr>
    </table>
    <script language="javascript" type="text/javascript">
        document.getElementById("copydiv").value = "Click for Copy.";
        function selectclick() 
{
    var obj = document.getElementById("<%= drpShipCondition.ClientID %>");
    //alert(obj.value);
    //window.clipboardData.setData("Text", obj.value);

    //document.getElementById("copydiv").innerHTML = obj.text;


    fromlist = obj;
    var fromcount = fromlist.length;
  
    for (i = 0; i < fromcount; i++) {
        if (fromlist[i].selected == true) {
            //op.value = fromlist[i].value;
           // window.clipboardData.setData('text', "nininiiin");
            document.getElementById("copydiv").value = fromlist[i].text;
            document.getElementById("copydiv").select();

        }
    } 
} 
    </script>



</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" runat="Server">
</asp:Content>

