<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- B2B Order Inquiry" %>

<script runat="server">

    Private _Part_Number As String = "", _PlantID As String = "", _QUANTITY As String = "", _SALES_ORG As String = "", _F As String = "0"

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Request.IsAuthenticated Then
            'If user has logined already then check if it is internal user
            If Util.IsInternalUser2() = False Then
                'ICC For EU CP or KA users can see product detail
                If Session("ORG_ID").ToString.ToUpper.StartsWith("EU", StringComparison.OrdinalIgnoreCase) Then
                    If Session("account_status") <> "CP" AndAlso Session("account_status") <> "KA" Then
                        Response.Redirect(Request.ApplicationPath)
                    End If
                Else
                    'ICC Change Server.Transfer("~/home.aspx") to Response.Redirect(Request.ApplicationPath)
                    Response.Redirect(Request.ApplicationPath)
                End If
            End If
        Else
            'If user do not login then check check client ip
            Dim ip As String = Request.ServerVariables("REMOTE_ADDR"), internalIPStartWith As String = "172."
            '::1 means localhost of IPV6
            If ip = "::1" Then ip = internalIPStartWith

            If ip.StartsWith(internalIPStartWith) = False Then
                Server.Transfer("~/home.aspx")
            End If
        End If

        If Page.IsPostBack = False Then
            Me._Part_Number = Request.Params("Part_Number") 'ADAM - 4541 - AE
            Me._QUANTITY = Request.Params("QUANTITY") '18
            Me._SALES_ORG = Request.Params("SALES_ORG") ' US10
            Me._F = Request.Params("F")
            If String.IsNullOrEmpty(_Part_Number) Then
                Util.JSAlert(Me.Page, "Please input part no.") : Me.gv1.DataSource = Nothing : Me.gv1.DataBind() : Exit Sub
            End If

            If String.IsNullOrEmpty(_SALES_ORG) OrElse _SALES_ORG.Length < 2 Then
                _PlantID = "TWH1"
            Else
                _PlantID = _SALES_ORG.Substring(0, 2).ToUpper & "H1"
            End If
            If Not Integer.TryParse(Me._QUANTITY, 0) Then
                Me._QUANTITY = 0
            End If
            Dim prodListSql As New StringBuilder
            If Me._F = 1 Then
                With prodListSql
                    '.AppendLine(String.Format(" select part_no from [PIS].[dbo].[PRODUCT_FAMILY] where FAMILY_NAME=(select top 1 b.Relate_Family_Name from "))
                    '.AppendLine(String.Format(" [PIS].[dbo].[PRODUCT_FAMILY] A inner join [PIS].dbo.PRODUCT_FAMILY_GROUP_RELATION b on A.FAMILY_NAME=b.Family_Name "))
                    '.AppendLine(String.Format(" where A.PART_NO='{0}')", Me._Part_Number))
                    .AppendFormat(" SELECT PART_NO FROM  [PIS].[dbo].[PRODUCT_FAMILY] WHERE FAMILY_NAME =  ")
                    .AppendFormat(" (SELECT TOP 1  ALTERNATIVE_GROUP FROM  [PIS].[dbo].[PRODUCT_FAMILY] WHERE PART_NO='{0}' )  ", Me._Part_Number)
                End With
            Else
                With prodListSql
                    'Frank 20150806 roll back by Frank
                    '.AppendLine(String.Format(" 	select z.part_no  "))
                    '.AppendLine(String.Format(" 	from SAP_PRODUCT z  "))
                    '.AppendLine(String.Format(" 	where z.PART_NO='{0}'  ", Me._Part_Number))
                    '.AppendLine(String.Format(" 	or z.MODEL_NO in (select MODEL_NO from SAP_PRODUCT where PART_NO='{0}' and MODEL_NO is not null and MODEL_NO<>'')  ", Me._Part_Number))
                    '.AppendLine(String.Format(" 	or z.PART_NO in (select z2.PART_NO from PIS.dbo.PRODUCT_FAMILY z1 inner join PIS.dbo.PRODUCT_FAMILY z2 on z1.FAMILY_NAME=z2.FAMILY_NAME where z1.PART_NO='{0}') ", Me._Part_Number))
                    .AppendLine(String.Format("	Select z2.PART_NO from PIS.dbo.PRODUCT_FAMILY z1 inner join PIS.dbo.PRODUCT_FAMILY z2 on z1.FAMILY_NAME=z2.FAMILY_NAME where z1.PART_NO='{0}' ", Me._Part_Number))
                    .AppendLine(" Union ")
                    .AppendLine(String.Format("	Select distinct z2.PART_NO From PIS.dbo.model_product z1 inner join PIS.dbo.model_product z2 on z1.model_name=z2.model_name where z1.part_no='{0}' and z2.status='active' ", Me._Part_Number))

                    'JJ 2014/3/11：修改只單純用SAP_PRODUCT的Model查詢相同Family的料號以防Product沒有在PIS維護過就查不到資料
                    '.AppendLine(String.Format("	Select distinct sp.MODEL_NO from SAP_PRODUCT sp where sp.PART_NO='{0}' ", Me._Part_Number))

                End With
            End If

            Dim _sql As New StringBuilder
            If Me._F = 1 Then
                With _sql
                    .AppendLine(String.Format(" select a.PART_NO, a.PRODUCT_DESC, a.STATUS as PRODUCT_STATUS,  "))
                    .AppendLine(String.Format(" IsNull((select top 1 abc_indicator from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='TWH1'),'') as ABC_INDICATOR,  "))
                    'ICC 2014/10/15 Get safety_stock from SAP_PRODUCT_ABC
                    .AppendLine(String.Format(" (select safety_stock from SAP_PRODUCT_ABC b where b.PART_NO = a.PART_NO and b.PLANT='TWH1') as [Max_Alloc_Qty] "))
                    .AppendLine(String.Format(" from SAP_PRODUCT a  "))
                    'ICC 2014/10/28 Add MATERIAL_GROUP = PRODUCT to filter non-product items
                    .AppendLine(String.Format(" where a.PART_NO in ({0}) and a.STATUS in ('A','N','H','S5','M1') and a.MATERIAL_GROUP='PRODUCT' ", prodListSql))
                    'JJ 2014/9/25：非內部使用者才需要限制MATERIAL_GROUP = PRODUCT
                    If Util.IsInternalUser2() = False Then
                        .AppendLine(" and a.MATERIAL_GROUP in ('PRODUCT') ")
                    End If
                    .AppendLine(String.Format(" order by a.PART_NO  "))
                End With
            Else
                With _sql
                    .AppendLine(String.Format(" select a.PART_NO, a.PRODUCT_DESC, a.STATUS as PRODUCT_STATUS,  "))
                    .AppendLine(String.Format(" IsNull((select top 1 abc_indicator from SAP_PRODUCT_ABC z where z.PART_NO=a.PART_NO and z.PLANT='TWH1'),'') as ABC_INDICATOR,  "))
                    'ICC 2014/10/15 Get safety_stock from SAP_PRODUCT_ABC
                    .AppendLine(String.Format(" (select safety_stock from SAP_PRODUCT_ABC b where b.PART_NO = a.PART_NO and b.PLANT='TWH1') as [Max_Alloc_Qty] "))
                    .AppendLine(String.Format(" from SAP_PRODUCT a  "))
                    'ICC 2014/10/28 Add MATERIAL_GROUP = PRODUCT to filter non-product items
                    '.AppendLine(String.Format(" where a.MODEL_NO in ({0}) and a.STATUS in ('A','N','H','S5','M1') and a.MATERIAL_GROUP='PRODUCT' ", prodListSql))
                    .AppendLine(String.Format(" where a.PART_NO in ({0}) and a.STATUS in ('A','N','H','S5','M1') and a.MATERIAL_GROUP='PRODUCT' ", prodListSql))
                    'JJ 2014/9/25：非內部使用者才需要限制MATERIAL_GROUP = PRODUCT
                    If Util.IsInternalUser2() = False Then
                        .AppendLine(" and a.MATERIAL_GROUP in ('PRODUCT') ")
                    End If
                    .AppendLine(String.Format(" order by a.PART_NO  "))
                End With
            End If

            Dim _ProInfoDT As DataTable = dbUtil.dbGetDataTable("MY", _sql.ToString)
            Try
                Me.gv1.DataSource = _ProInfoDT
                Me.gv1.DataBind()

                If _ProInfoDT Is Nothing OrElse _ProInfoDT.Rows.Count = 0 Then Me.CheckBoxIsShowAllSpec.Visible = False

                '-----Get part_NOs for creating sepc table------
                Me.GenerateSpecMatrix()
                '-----Get part_NOs for creating sepc table End------

            Catch ex As Exception
                Dim _errstr As String = ex.Message : Me.lbmsg.Visible = True : Me.lbmsg.Text = _errstr
            End Try

        End If

    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)

        If e.Row.RowType = DataControlRowType.DataRow Then

            'Dim GV As GridView = e.Row.FindControl("gv2")
            Dim _CurrentRow_PartNO As String = CType(e.Row.Cells(1), DataControlFieldCell).Text



            'If _Part_Number.Equals(_CurrentRow_PartNO, StringComparison.InvariantCultureIgnoreCase) Then
            '    CType(e.Row.Cells(1), DataControlFieldCell).ForeColor = Drawing.Color.Red
            'End If

            'Frank: If this part has been inputed specification in PIS, then showing up the checkbox.
            Dim queryStr As String = "select top 1 productno,attrcatname,attrname,attrvaluename from  v_productmatrix " & _
                      " where productno ='" & _CurrentRow_PartNO & "'"
            queryStr += " and attrvaluename <> '0' group by productno,attrcatname,attrname,attrvaluename "
            Dim dt As DataTable = dbUtil.dbGetDataTable("PIS", queryStr)
            If dt Is Nothing OrElse dt.Rows.Count = 0 Then
                CType(e.Row.FindControl("CheckBoxIsShowSpec"), CheckBox).Enabled = False
                CType(e.Row.FindControl("CheckBoxIsShowSpec"), CheckBox).Visible = False
                CType(e.Row.FindControl("CheckBoxIsShowSpec"), CheckBox).Checked = False
                CType(e.Row.FindControl("CheckBoxIsShowSpecMSG"), Label).Text = "No Spec in PIS"
                CType(e.Row.FindControl("CheckBoxIsShowSpecMSG"), Label).Visible = True
            End If


            'Dim _mysapdal As SAPDAL.SAPDAL = New SAPDAL.SAPDAL, pin As New SAPDAL.SAPDALDS.ProductInDataTable
            'pin.AddProductInRow(_CurrentRow_PartNO, Me._QUANTITY, Me._PlantID)

            'Dim _dtInventory As SAPDAL.SAPDALDS.QueryInventory_OutputDataTable = Nothing, _errormsg As String = String.Empty
            'Dim _querystatus As Boolean = _mysapdal.QueryInventory(pin, Me._PlantID, _dtInventory, _errormsg)
            'If _errormsg <> "" Then Exit Sub

            'Dim _ds As New DataSet
            ''Frank 2012/05/31
            ''Get limit quantity
            'Dim _part() As String = {_CurrentRow_PartNO}
            '_mysapdal.QueryLimitQuantity(Me._SALES_ORG, _part, _ds, _errormsg)
            ''Add limit quantity column
            '_dtInventory.Columns.Add("Lmt_Qty", GetType(System.Int32))

            ''Dim _foundrow() As DataRow = Nothing

            'Dim _limqty As Integer = 0

            'If _ds.Tables(0) IsNot Nothing AndAlso _ds.Tables(0).Rows.Count > 0 Then
            '    _limqty = _ds.Tables(0).Rows(0).Item("zlmtqty")
            'End If


            ''Fill limit quantity into _dtInventory
            'For Each _row As DataRow In _dtInventory.Rows

            '    If _errormsg = "" Then
            '        _row.Item("Lmt_Qty") = _limqty
            '    Else
            '        _row.Item("Lmt_Qty") = 0
            '    End If

            'Next
            'GV.DataSource = _dtInventory : GV.DataBind()

            Dim rt As Timer = e.Row.FindControl("TimerRowATP")
            Dim hd As HiddenField = e.Row.FindControl("hd_RowPN")
            If rt IsNot Nothing AndAlso hd IsNot Nothing AndAlso hd.Value <> "" Then
                rt.Enabled = True
                If e.Row.RowIndex <= 10 Then
                    rt.Interval = 2000 + e.Row.RowIndex * 100
                Else
                    rt.Interval = 2000 + e.Row.RowIndex * 500
                End If

            End If

        End If

    End Sub


    Protected Sub GenerateSpecMatrix()

        Dim _CurrentRow_PartNO As String = String.Empty, _IsShowSpec As CheckBox = Nothing, _partnos_spec As String = String.Empty
        For Each _row As GridViewRow In Me.gv1.Rows

            _CurrentRow_PartNO = CType(_row.Cells(1), DataControlFieldCell).Text

            _IsShowSpec = CType(_row.FindControl("CheckBoxIsShowSpec"), CheckBox)
            If _partnos_spec.IndexOf("'" & _CurrentRow_PartNO & "'") = -1 AndAlso _IsShowSpec.Checked Then
                _partnos_spec &= "'" & _CurrentRow_PartNO & "',"
            End If

            'ICC 2014/10/16 當safety_stock 為0時, 改為空白, 若為1則不變, 其餘的除以2並捨去
            Dim qty As String = CType(_row.Cells(4), DataControlFieldCell).Text
            If Not String.IsNullOrEmpty(qty) Then
                If qty = "0" Then
                    CType(_row.Cells(4), DataControlFieldCell).Text = ""
                ElseIf qty = "1" Then

                Else
                    Dim n As Integer = 0
                    If Integer.TryParse(qty, n) Then
                        n = Fix(n / 2)
                    End If
                    CType(_row.Cells(4), DataControlFieldCell).Text = n.ToString
                End If
            End If
        Next

        If String.IsNullOrEmpty(_partnos_spec) OrElse String.IsNullOrWhiteSpace(_partnos_spec) Then
            lblProductSpec.Visible = False : Exit Sub
        End If


        _partnos_spec = _partnos_spec.TrimEnd(",")



        Dim dt As New DataTable
        Dim queryStr As String = "select productno,attrcatname,attrname,attrvaluename  from  v_productmatrix  " & _
                                    " where productno in ("
        'queryStr += partList
        queryStr += _partnos_spec
        queryStr += ") and attrvaluename <> '0' group by productno,attrcatname,attrname,attrvaluename "
        dt = dbUtil.dbGetDataTable("PIS", queryStr)
        If dt.Rows.Count > 0 Then
            Dim matrixHtml As New StringBuilder()
            matrixHtml.Append("<h1>Specifications</h1>")
            matrixHtml.Append("<table class=""prodSpecTable"">")
            Dim matrixTable As New DataTable()
            matrixTable.Columns.Add(New DataColumn("attrcatname", GetType(String)))
            matrixTable.Columns.Add(New DataColumn("attrname", GetType(String)))

            ' Get,fileter part no and generate
            Dim partNoList = dt.DefaultView.ToTable(True, "productno").Rows

            matrixHtml.Append("<tr class=""headerRow""><td colspan=""2"" style=""color:#666666;"">Part Number</td>")
            For j As Integer = 0 To partNoList.Count - 1
                'Me._Part_Number.Equals(partNoList(j)(0), StringComparison.InvariantCultureIgnoreCase)
                If Me._Part_Number = partNoList(j)(0) Then
                    matrixHtml.Append("<td style=""color:#666666;""><font color='red'>" & partNoList(j)(0) & "</font></td>")
                Else
                    matrixHtml.Append("<td style=""color:#666666;"">" & partNoList(j)(0) & "</td>")
                End If


                matrixTable.Columns.Add(New DataColumn(partNoList(j)(0), GetType(String)))
            Next
            matrixHtml.Append("</tr>")

            Dim dtDistinctCate, dtDistinctProduct As DataTable
            Dim tmpRow As DataRow
            dtDistinctCate = dt.DefaultView.ToTable(True, New String() {"attrcatname"})

            For Each row As DataRow In dtDistinctCate.Rows
                Dim dvAttrName As DataView = dt.DefaultView
                dvAttrName.RowFilter = String.Format("attrcatname='{0}'", row("attrcatname"))
                dtDistinctProduct = dvAttrName.ToTable(True, New String() {"attrname"})

                For Each attrRow As DataRow In dtDistinctProduct.Rows
                    tmpRow = matrixTable.NewRow
                    tmpRow(0) = row(0) : tmpRow(1) = attrRow(0) : matrixTable.Rows.Add(tmpRow)
                Next

            Next

            For m As Integer = 0 To partNoList.Count - 1
                Dim dvSpec As DataView = dt.DefaultView
                dvSpec.RowFilter = String.Format("productno='{0}'", partNoList(m)(0))
                dtDistinctProduct = dvSpec.ToTable()

                For Each item As DataRow In matrixTable.Rows

                    For Each ptRow As DataRow In dtDistinctProduct.Rows

                        If item(0) = ptRow(1) And item(1) = ptRow(2) Then
                            item(partNoList(m)(0)) = ptRow(3)
                        End If
                    Next
                Next
            Next
            Dim i As Integer = 0, k As Integer = 0
            Static oldItemType As String = String.Empty
            For Each item In matrixTable.Rows
                Dim itemType = item(0)
                If i = 0 Then
                    oldItemType = itemType
                    Dim itemCount = matrixTable.Select(String.Format("attrcatname='{0}'", itemType)).Count
                    If Math.IEEERemainder(k, 2) = 0 Then
                        matrixHtml.Append("<tr class=""prodSpecAltRow""><td class=""prodSpecC"" rowspan=""" & itemCount & """>" & item(0) & "</td><td class=""prodSpecC2"">" & item(1) & "</td>")
                    Else
                        matrixHtml.Append("<tr class=""prodSpecRow""><td class=""prodSpecC"" rowspan=""" & itemCount & """>" & item(0) & "</td><td class=""prodSpecC2"">" & item(1) & "</td>")
                    End If
                    For colIndex As Integer = 2 To matrixTable.Columns.Count - 1
                        matrixHtml.Append("<td class=""psdc"">" & item(colIndex) & "</td>")
                    Next
                    matrixHtml.Append("</tr>")
                Else
                    If oldItemType <> item(0) Then
                        i = 0
                        oldItemType = item(0)
                        Dim itemCount = matrixTable.Select(String.Format("attrcatname='{0}'", itemType)).Count
                        If Math.IEEERemainder(k, 2) = 0 Then
                            matrixHtml.Append("<tr class=""prodSpecAltRow""><td class=""prodSpecC"" rowspan=""" & itemCount & """>" & item(0) & "</td><td class=""prodSpecC2"">" & item(1) & "</td>")
                        Else
                            matrixHtml.Append("<tr class=""prodSpecRow""><td class=""prodSpecC"" rowspan=""" & itemCount & """>" & item(0) & "</td><td class=""prodSpecC2"">" & item(1) & "</td>")

                        End If
                        For colIndex As Integer = 2 To matrixTable.Columns.Count - 1
                            matrixHtml.Append("<td class=""psdc"">" & item(colIndex) & "</td>")
                        Next
                        matrixHtml.Append("</tr>")
                    Else
                        If Math.IEEERemainder(k, 2) = 0 Then
                            matrixHtml.Append("<tr class=""prodSpecAltRow""><td class=""prodSpecC2"">" & item(1) & "</td>")
                        Else
                            matrixHtml.Append("<tr class=""prodSpecRow""><td class=""prodSpecC2"">" & item(1) & "</td>")

                        End If
                        For colIndex As Integer = 2 To matrixTable.Columns.Count - 1
                            matrixHtml.Append("<td class=""psdc"">" & item(colIndex) & "</td>")
                        Next
                        matrixHtml.Append("</tr>")
                    End If
                End If
                i += 1
                k += 1
            Next
            matrixHtml.Append("</table>")
            lblProductSpec.Text = matrixHtml.ToString() : lblProductSpec.Visible = True
        Else
            lblProductSpec.Visible = False
        End If

        '_oPISLogic = Nothing
        dt = Nothing

        'Return dt

    End Sub

    Protected Sub CheckBoxIsShowSpec_CheckedChanged(sender As Object, e As System.EventArgs)

        'Dim _CurrentRow_PartNO As String = String.Empty, _changed_PartNO As String = String.Empty
        'Dim _checkStatus As Boolean = CType(sender, CheckBox).Checked
        'Dim _lineIndex As Integer = Integer.Parse(CType(sender, CheckBox).Text) - 1

        '_changed_PartNO = CType(Me.gv1.Rows(_lineIndex).Cells(1), DataControlFieldCell).Text

        'For Each _row As GridViewRow In Me.gv1.Rows

        '    _CurrentRow_PartNO = CType(_row.Cells(1), DataControlFieldCell).Text

        '    If _changed_PartNO.Equals(_CurrentRow_PartNO, StringComparison.InvariantCultureIgnoreCase) Then
        '        CType(_row.FindControl("CheckBoxIsShowSpec"), CheckBox).Checked = _checkStatus
        '    End If

        'Next

        Me.GenerateSpecMatrix()
    End Sub

    Protected Sub CheckBoxIsShowAllSpec_CheckedChanged(sender As Object, e As System.EventArgs)
        Dim _checkStatus As Boolean = CType(sender, CheckBox).Checked
        For Each _row As GridViewRow In Me.gv1.Rows
            If CType(_row.FindControl("CheckBoxIsShowSpec"), CheckBox).Enabled Then
                CType(_row.FindControl("CheckBoxIsShowSpec"), CheckBox).Checked = _checkStatus
            End If
        Next
        Me.GenerateSpecMatrix()
    End Sub

    Protected Sub lbtnProdFamily_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Me._Part_Number = Request.Params("Part_Number") 'ADAM - 4541 - AE
        Me._QUANTITY = Request.Params("QUANTITY") '18
        Me._SALES_ORG = Request.Params("SALES_ORG") ' US10
        Me._F = Request.Params("F")
        Response.Redirect(String.Format("~/Order/ProductATPInfo.aspx?Part_Number={0}&QUANTITY={1}&SALES_ORG={2}&F={3}", Me._Part_Number, Me._QUANTITY, Me._SALES_ORG, 1))
    End Sub
    Protected Sub TimerRowATP_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim tm As Timer = sender
        Dim pn As String = CType(tm.NamingContainer.FindControl("hd_RowPN"), HiddenField).Value
        Dim gv As GridView = tm.NamingContainer.FindControl("gvRowATP")
        Dim loadImg As Image = tm.NamingContainer.FindControl("imgRowLoadATP")
        tm.Interval = 999999
        Try
            SyncLock GetType(Integer)
                If ViewState("ConcurrentATPThreads") Is Nothing Then ViewState("ConcurrentATPThreads") = 0
                If ViewState("ConcurrentATPThreads") > 5 Then
                    For i As Integer = 0 To 10
                        If CInt(ViewState("ConcurrentATPThreads")) > 5 Then
                            Threading.Thread.Sleep(500)
                        Else
                            Exit For
                        End If
                    Next
                End If
                ViewState("ConcurrentATPThreads") = ViewState("ConcurrentATPThreads") + 1
            End SyncLock
            Dim adt As DataTable = GetATP(pn)
            gv.DataSource = adt : gv.DataBind()
            loadImg.Visible = False : gv.Visible = True : gv.EmptyDataText = "N/A"
            Dim intQty As Integer = 0
            For Each r As DataRow In adt.Rows
                intQty += r.Item("atp_qty")
            Next
            If intQty > 0 Then
                If intQty > 1 Then
                    'Me.lbInvTotal.Text = "Total: " + intQty.ToString() + " pcs"
                Else
                    'Me.lbInvTotal.Text = "Total: " + intQty.ToString() + " pc"
                End If
            End If
            SyncLock GetType(Integer)
                ViewState("ConcurrentATPThreads") = ViewState("ConcurrentATPThreads") - 1
            End SyncLock
        Catch ex As Exception
        End Try
        tm.Enabled = False
    End Sub

    Function GetATP(ByVal pn As String) As DataTable
        'imgInvLoad.Visible = True
        Dim gdt As New DataTable
        gdt.Columns.Add("plant") : gdt.Columns.Add("atp_date") : gdt.Columns.Add("atp_qty", Type.GetType("System.Double"))
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        pn = Global_Inc.Format2SAPItem(Trim(UCase(pn)))
        'Dim retDt As New DataTable("DueDate")
        Try
            Dim plants() As String = {"EUH1", "TWH1", "TLH1", "CNH1", "AUH1", "BRH1", "CNH3", "CKH2", "IDH1", "JPH1", "KRH1", "SGH1", "MYH1", "USH1"}
            For Each plant In plants
                'Dim culQty As Integer = 0
                Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable
                p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", pn, plant, "", "", "", "", "PC", "", 9999, "", "", _
                                              New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
                Dim adt As DataTable = atpTb.ToADODataTable()
                For Each r As DataRow In adt.Rows
                    If r.Item(4) > 0 And r.Item(4) < 99999999 Then
                        Dim r2 As DataRow = gdt.NewRow
                        r2.Item("plant") = plant
                        r2.Item("atp_date") = Date.ParseExact(r.Item(3).ToString(), "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
                        r2.Item("atp_qty") = CDbl(r.Item(4))
                        gdt.Rows.Add(r2)
                    End If
                Next
                'retDt.Merge(atpTb.ToADODataTable())
            Next
        Catch ex As Exception
        End Try
        p1.Connection.Close()
        'imgInvLoad.Visible = False
        Return gdt
    End Function
</script>
 
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
   <style>
        a
        {
            color: Blue;
        }
        h1
        {
            font-size: 20px;
            padding-left: 5px;
            border-left: 10px solid #FFC83C;
        }
        .prodSpecTable
        {
            /*border-width:0px;*/
            background-color: rgb(240, 240, 240);
            width: 100%;
            border-collapse: collapse;
        }
        .headerRow
        {
            background-color: White;
            font-weight: bold;
        }
        .prodSpecAltRow
        {
            min-height: 40px; /*border-bottom:solid 1px rgb(207, 209, 224);*/
            background-color: #f0f0f0;
        }
        .prodSpecRow
        {
            min-height: 40px;
            background-color: White; /*border-bottom:solid 1px rgb(207, 209, 224);*/
        }
        .prodSpecC
        {
            width: 15%;
            padding-left: 5px;
            font-weight: bold;
            background-color: #E0E0E0;
            border-left: solid 1px rgb(207, 209, 224);
            border-right: solid 1px rgb(207, 209, 224);
            border-bottom: solid 1px rgb(207, 209, 224);
        }
        .prodSpecC2
        {
            width: 15%;
            padding-left: 5px;
            font-weight: bold; /*background-color:#DDEEDB;*/
            border-bottom: solid 1px rgb(207, 209, 224);
            border-right: solid 1px rgb(207, 209, 224);
        }
        .psdc
        {
            border-bottom: solid 1px rgb(207, 209, 224);
            border-right: solid 1px rgb(207, 209, 224);
        }
    </style>
    <br/>
    <h1>Product Information</h1>
    <div>
        <table width="100%" >
            <tr>
                <td>
                    <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="False" Width="100%" EmptyDataText="No search results were found."
                        OnRowDataBound="gv1_RowDataBound" BackColor="White" BorderColor="#CCCCCC" BorderStyle="None"
                        BorderWidth="1px" CellPadding="3">
                        <Columns>
                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                    Show Spec
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="CheckBoxIsShowSpecMSG" runat="server" Visible="false" />
                                    <asp:CheckBox ID="CheckBoxIsShowSpec" AutoPostBack="true" runat="server" Checked="true" OnCheckedChanged="CheckBoxIsShowSpec_CheckedChanged" />
<%--                                    <%# Container.DataItemIndex + 1 %>
--%>                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center" Width="50px"></ItemStyle>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Part No" DataField="part_no" ItemStyle-HorizontalAlign="left" />
                <%--            <asp:BoundField HeaderText="Supply Hub" DataField="PlantID" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50" />--%>
                            <asp:TemplateField ItemStyle-HorizontalAlign="Center">
                                <HeaderTemplate>
                                   Inventory
                                </HeaderTemplate>
                                <ItemTemplate>
                              <%--      <asp:GridView runat="server" ID="gv2" AutoGenerateColumns="false" AllowPaging="false"
                                        Width="100%" EmptyDataText="N/A" EmptyDataRowStyle-Font-Size="Larger" EmptyDataRowStyle-Font-Bold="true">
                                        <Columns>
                                            <asp:BoundField HeaderText="Available Date" DataField="STOCK_DATE" DataFormatString="{0:yyyy/MM/dd}"
                                                ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Qty." DataField="STOCK" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Lmt Qty." DataField="Lmt_Qty" ItemStyle-HorizontalAlign="Center" />
                                        </Columns>
                                    </asp:GridView>--%>
                            <%--          <asp:UpdatePanel runat="server" ID="upRowATP" UpdateMode="Conditional">
                                    <ContentTemplate>--%>
                                        <asp:Timer runat="server" ID="TimerRowATP" Interval="25000" OnTick="TimerRowATP_Tick" Enabled="false" />
                                        <asp:HiddenField runat="server" ID="hd_RowPN" Value='<%#Eval("part_no") %>' />
                                        <asp:Image runat="server" ID="imgRowLoadATP" ImageUrl="~/Images/Loading2.gif" AlternateText="Loading Availability..." ImageAlign="Middle" />
                                        <asp:GridView runat="server" ID="gvRowATP" AutoGenerateColumns="false" Width="400px" Visible="false"
                                            AllowSorting="false" AllowPaging="false" PageSize="50" PagerSettings-Position="TopAndBottom" EmptyDataText="N/A">
                                            <Columns>
                                                <asp:BoundField HeaderText="Plant" DataField="Plant" SortExpression="Plant" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                <asp:BoundField HeaderText="Available Date" DataField="atp_date" SortExpression="atp_date" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                                <asp:BoundField HeaderText="Available Qty." DataField="atp_qty" SortExpression="atp_qty" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                                            </Columns>
                                        </asp:GridView>
                        <%--            </ContentTemplate>
                                </asp:UpdatePanel>--%>
                                </ItemTemplate>
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="ABC Indicator" DataField="ABC_INDICATOR" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50">
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            </asp:BoundField>
                            <asp:BoundField HeaderText="Max.Alloc.Qty" DataField="Max_Alloc_Qty" ItemStyle-HorizontalAlign="Center">
                                <ItemStyle HorizontalAlign="Center"></ItemStyle>
                            </asp:BoundField>
                            <asp:BoundField HeaderText="Product Desc" DataField="PRODUCT_DESC" ItemStyle-HorizontalAlign="left">
                                <ItemStyle HorizontalAlign="left"></ItemStyle>
                            </asp:BoundField>
                            <asp:BoundField HeaderText="Product Status" DataField="PRODUCT_STATUS" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50">
                                <ItemStyle HorizontalAlign="Center" />
                            </asp:BoundField>
                        </Columns>
                        <EmptyDataRowStyle Font-Bold="True" Font-Size="Larger"></EmptyDataRowStyle>
                        <FooterStyle BackColor="White" ForeColor="#000066" />
                        <HeaderStyle BackColor="#006699" Font-Bold="True" ForeColor="White" />
                        <PagerStyle BackColor="White" ForeColor="#000066" HorizontalAlign="Left" />
                        <RowStyle ForeColor="#000066" />
                        <SelectedRowStyle BackColor="#669999" Font-Bold="True" ForeColor="White" />
                        <SortedAscendingCellStyle BackColor="#F1F1F1" />
                        <SortedAscendingHeaderStyle BackColor="#007DBB" />
                        <SortedDescendingCellStyle BackColor="#CAC9C9" />
                        <SortedDescendingHeaderStyle BackColor="#00547E" />
                    </asp:GridView>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lbmsg" runat="server" Text="Label" ForeColor="#FF3300" 
                        Visible="False"></asp:Label>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:LinkButton runat="server" ID="lbtnProdFamily" Text="Product Family Recommend Group" OnClick="lbtnProdFamily_Click"></asp:LinkButton>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:CheckBox ID="CheckBoxIsShowAllSpec" AutoPostBack="true" runat="server" Checked="true" Text="Show Specifications of All Above Parts"  OnCheckedChanged="CheckBoxIsShowAllSpec_CheckedChanged" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblProductSpec" runat="server" Visible="false" />
                </td>
            </tr>
        </table>
    </div>

</asp:Content>
