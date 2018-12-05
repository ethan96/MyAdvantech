<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech Search Center" %>

<script runat="server">
    Dim RequestCategory As String, RequestMatch_Method As String, RequestProduct_Status As String, RequestProduct_RoHs As String
    Dim Requestpart_no As String, RequestSBU As String, RequestUID As String, dtExport As New DataTable, mycart As New CartList("b2b", "CART_DETAIL_V2")
    Protected Sub btnAdd2Cart_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim part_no As String = ""
        Dim msg As String = ""
        For Each r As GridViewRow In AdgSearch.Rows
            If r.RowType = DataControlRowType.DataRow Then
                part_no = System.Text.RegularExpressions.Regex.Replace(r.Cells(2).Text, "<[^>]*>", String.Empty)
                If r.RowType = DataControlRowType.DataRow Then
                    Dim cb As CheckBox = CType(r.FindControl("item"), CheckBox)
                    Dim qty_TB As TextBox = CType(r.FindControl("tbRowQty"), TextBox)
                    If cb IsNot Nothing AndAlso cb.Checked AndAlso qty_TB IsNot Nothing AndAlso CInt(qty_TB.Text.Trim) > 0 Then
                        Dim qty As Integer = 0, ew_flag As Integer = 0, otype As Integer = 0, cate As String = "", CartId As String = Session("CART_ID")
                        part_no = part_no.ToUpper()
                        qty = CInt(qty_TB.Text.Trim)
                        If mycart.isBtoOrder(CartId) = 1 Then
                            otype = 1 : cate = "OTHERS"
                        End If
                   
                        Dim lineNo As Integer = MyCartOrderBizDAL.Add2Cart_BIZ(Session("CART_ID"), part_no, qty, ew_flag, otype, cate, 1, 1, Now, "", "", 0, False, msg)
                        If MyCartOrderBizDAL.IsSpecialADAM(part_no) Then
                            mycart.Update(String.Format("cart_Id='{0}' and line_no='{1}'", CartId, lineNo), String.Format("ew_Flag='99'"))
                        End If
                    End If
                End If
            End If
        Next
        If msg = "" Then
            Response.Redirect("../order/cart_listV2.aspx")
        Else
            Me.lbmsg.Text = msg
        End If
    End Sub
    Protected Sub AdgSearch_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.Header Then
           ' e.Row.Cells(10).Text = Server.HtmlDecode(Util.GenerateScript("Unit Price", AdgSearch, Me.Page))
        End If
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            If Trim(e.Row.Cells(7).Text) = "1" Then
                e.Row.Cells(7).Text = "<img src='../Images/rohs.jpg' alt='RoHS' />"
            Else
                e.Row.Cells(7).Text = ""
            End If
            If dbUtil.dbGetDataTable("My", "select count(*) as p from SIEBEL_CATALOG_CATEGORY where DISPLAY_NAME='" + e.Row.Cells(3).Text + "'").Rows.Count > 0 Then
                e.Row.Cells(3).Text = "<a href='/Product/Model_Detail.aspx?model_no=" + e.Row.Cells(3).Text + "' target='_blank'>" + e.Row.Cells(3).Text + "</a>"
            End If
            If Session("user_role") = "Administrator" Or Session("user_role") = "Logistics" Or Session("user_role") = "Sales" Then
                e.Row.Cells(2).Text = "<a href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" + e.Row.Cells(3).Text + "' target='_blank'>" + e.Row.Cells(2).Text + "</a>"
            End If
        End If
    End Sub
    Protected Sub AdgSearch_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles AdgSearch.DataBound
        Dim part_no As String = ""
        If 1 = 1 OrElse ViewState("PriceTable") Is Nothing Then
            Dim myprice As New MYSAPDAL
            Dim indt As New SAPDALDS.ProductInDataTable
            Dim xMultiPriceDT As New SAPDALDS.ProductOutDataTable
            Dim ErrorMessage As String = ""
            For Each r As GridViewRow In AdgSearch.Rows
                If r.RowType = DataControlRowType.DataRow Then
                    part_no = System.Text.RegularExpressions.Regex.Replace(r.Cells(3).Text, "<[^>]*>", String.Empty)
                    Dim r2 As DataRow = indt.NewRow
                    r2.Item("PART_NO") = part_no : r2.Item("QTY") = 1
                    indt.Rows.Add(r2)
                End If
            Next
            indt.AcceptChanges()
            If Session("company_id").ToString().Equals("UUAAESC", StringComparison.OrdinalIgnoreCase) Then
                myprice.GetListPrice(Session("org_id"), "", "EUR", indt, xMultiPriceDT, ErrorMessage)
            Else
                myprice.GetPrice(Session("company_id"), Session("company_id"), Session("org_id"), indt, xMultiPriceDT, ErrorMessage)
            End If
         
            If xMultiPriceDT.Rows.Count > 0 Then
                ViewState("PriceTable") = xMultiPriceDT
            End If
            For Each r As GridViewRow In AdgSearch.Rows
                If r.RowType = DataControlRowType.DataRow Then
                    part_no = System.Text.RegularExpressions.Regex.Replace(r.Cells(3).Text, "<[^>]*>", String.Empty)
                    Dim rs() As DataRow = xMultiPriceDT.Select(String.Format("part_no='{0}'", part_no))
                    Dim currency As String = Session("COMPANY_CURRENCY_SIGN")
                    Dim cuu As String = currency '"" ' PricingUtil.GetCurrencyCode(currency)
                    If rs.Length > 0 Then
                        If IsNumeric(rs(0).Item("unit_price")) AndAlso CDbl(rs(0).Item("unit_price").ToString()) > 0 Then
                            r.Cells(10).Text = cuu & rs(0).Item("unit_price").ToString()
                        Else
                            r.Cells(10).Text = "<a target='_blank' href='../Order/QueryPrice.aspx?part_no=" + part_no + "'><img src='/Images/btn_Call.GIF' alt='call' style='border:0px' /></a>"
                        End If
                    Else
                        r.Cells(10).Text = "<a target='_blank' href='../Order/QueryPrice.aspx?part_no=" + part_no + "'><img src='/Images/btn_Call.GIF' alt='call' style='border:0px' /></a>"
                    End If
                    If LCase(Session("user_id")) = "r.deraad@go4mobility.nl" Or LCase(Session("user_id")) = "j.sep@go4mobility.nl" Then
                        r.Cells(10).Text = "<a target='_blank' href='../Order/QueryPrice.aspx><img src='/Images/btn_Call.GIF' alt='call' style='border:0px' /></a>"
                    End If
                    If Session("user_role") = "Administrator" Or Session("user_role") = "Logistics" Or Session("user_role") = "Sales" Then
                        r.Cells(2).Text = "<a href='../DM/ProductDashboard.aspx?PN=" + part_no + "' target='_blank'>" + part_no + "</a>"
                    End If
                End If
            Next
        End If
        If Me.AdgSearch.Rows.Count > 0 Then
            If RequestUID <> "" Then
                btnToXls.Visible = True : btnToXls1.Visible = True
                btnAdd2Cart.Visible = False : btnAdd2Cart2.Visible = False
            Else
                btnToXls.Visible = True : btnToXls1.Visible = True
                btnAdd2Cart.Visible = True : btnAdd2Cart2.Visible = True
            End If
        Else
            btnAdd2Cart.Visible = False : btnAdd2Cart2.Visible = False : btnToXls.Visible = False : btnToXls1.Visible = False
        End If
        If LCase(Session("user_id")) = "r.deraad@go4mobility.nl" Or LCase(Session("user_id")) = "j.sep@go4mobility.nl" Then
            btnAdd2Cart.Visible = False : btnAdd2Cart2.Visible = False
        End If
    End Sub
    
    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") <> "" Then
            SqlDataSource1.SelectCommand = ViewState("SqlCommand").ToString()
        End If
    End Sub
    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Call InitialSearch()
    End Sub
    Protected Sub InitialSearch()
        Dim T_strSelect As String = "", Block_Select As String = "", strCategory As String = "", strMatch_Method As String = "", strProduct_Status As String = ""
        Dim strProcuct_RoHs As String = "", part_no As String = Me.part_no.Text.ToString.Trim.Replace("'", "''")
        If part_no = "" Then Exit Sub
        If LCase(Session("USER_ROLE")) <> "administrator" And LCase(Session("USER_ROLE")) <> "logistics" Then
            Block_Select = " and A.part_no not like 'T-%' and A.part_no not like 'W-%' and A.part_no not like '%-ES' and A.MATERIAL_GROUP<>'T' and IsNull(A.product_type,'') not like 'ZCTO'   and A.status<>'H'   "
        Else
            Block_Select = ""
        End If
        Dim SQL As String = " select distinct top 30 A.part_no, A.model_no,A.product_desc,B.PRODUCT_status AS status,A.rohs_FLAG,A.product_line, '' as  pricing, E.MFR_PART_NO"
        SQL += " From (( sap_product A INNER JOIN SAP_PRODUCT_STATUS B on A.PART_NO = B.PART_NO) inner join SAP_PRODUCT_STATUS_ORDERABLE C  on  A.PART_NO = C.PART_NO  AND B.SALES_ORG = C.SALES_ORG )  INNER JOIN SAP_PRODUCT_ORG D ON D.ORG_ID = B.SALES_ORG AND  D.PART_NO = A.PART_NO"
        SQL += " Left JOIN SAP_PRODUCT_MFRNR E ON A.PART_NO = E.PART_NO"
        SQL += " Where  D.B2BONLINE ='X'  and A.GENITEMCATGRP <>'ZSWL' and A.GENITEMCATGRP <>'DIEN'  AND  A." + Category.SelectedValue & String.Format(Match_Method.SelectedValue, part_no)
        SQL += String.Format(" and ({0} = 'A' or {0} = ' ' or {0} = '' or {0} = 'NE' or {0} = 'P' or {0} = 'S2' or {0} = 'H' or {0} = 'U' or {0} = 'N') ", "B.PRODUCT_STATUS")
        If Product_Status.SelectedValue.ToUpper <> "ALL" Then
            SQL += " AND " + Product_Status.SelectedValue
        End If
        If rblRoHs.SelectedValue = "Y" Then SQL += " and A.ROHS_FLAG ='1' "
        SQL += " AND B.SALES_ORG ='" + Session("org_id") + "' "
        If Request("SBU") IsNot Nothing Then
            Requestpart_no = part_no
            If UCase(RequestSBU) = "P-TD" Then
                Select Case (UCase(Trim(Requestpart_no)))
                    Case "P-DI"
                        T_strSelect =
                            "  and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV' " & _
                            " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')  and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                            " or ((part_no like '96SIM%' or part_no like '96DM%' or part_no like '96SS%' or part_no like '96DR%' or part_no like '96SD%' or part_no like '96D2%')    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                    Case "P-HD"
                        T_strSelect =
                            " and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV' " & _
                            " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')   and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                            " or ((part_no like '96HD%' or part_no like '96ND%' or part_no like '96RACK%')    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                    Case "P-FD"
                        T_strSelect =
                            " and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV'" & _
                            " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')   and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                            " or ((part_no like '96FDD%' or part_no like '96SFDD%' )    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                    Case "P-CD"
                        T_strSelect =
                            " and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                            " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                            " or ((part_no like '96CD%' or part_no like '96DV%' or part_no like '96COM%' or part_no like '96SDV%' or part_no like '96SCD%' or part_no like '96SCOM%')  and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                    Case "P-SS"
                        T_strSelect =
                            " and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV' " & _
                            " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*') and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                            " or ((part_no like '96DO%' or part_no like '96FD25%' or part_no like '96FD35%')    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                    Case "P-TM"
                        T_strSelect =
                            " and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV' " & _
                            " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')   and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                            " or ((part_no like '96LCD%' or part_no like '96CRT%')  and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                    Case Else
                        T_strSelect =
                         " and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                         " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                End Select
            Else
                If UCase(Trim(Requestpart_no)) = "P-MP" Then
                    T_strSelect =
                    "  and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV'   " & _
                    " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')   and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') " & _
                    " or (part_no like '96MP%'    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                Else
                    If LCase(Session("USER_ROLE")) <> "administrator" And LCase(Session("USER_ROLE")) <> "logistics" Then
                        T_strSelect = "  and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV' " & _
                         " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*') ) <> 'ZSLB'  and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV') "
                    Else
                        T_strSelect =
                         " and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV'    " & _
                         " or (part_no like '" & Requestpart_no & "%' and (part_no like 'P-%' or part_no like '96*')    and IsNull(product_type,'') <> 'ZCTO' and IsNull(product_type,'') <> 'ZSRV' )"
                    End If
                End If
            End If
        End If
        SQL += T_strSelect.Replace("part_no", "A.part_no").Replace("product_type", "A.product_type")
        SQL += Block_Select
        
        If Me.rbtnPType.SelectedValue <> "" Then
            SQL = SQL + " and a.material_group='" & Me.rbtnPType.SelectedValue & "' "
        End If
        
        ViewState("SqlCommand") = ""
        Me.SqlDataSource1.SelectCommand = SQL + " and A.PART_NO not like '%-bto' ORDER BY A.PART_NO "
        'Response.Write(SQL)
        ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
        AdgSearch.DataBind()
    End Sub
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If LCase(Session("USER_ROLE")) <> "administrator" And LCase(Session("USER_ROLE")) <> "logistics" Then
                With Me.Product_Status
                    .Items.Clear() : .Items.Add("All") : .Items(0).Value = "All" : .Items.Add("Available") : .Items(1).Value = " B.PRODUCT_STATUS ='A' " : .Items.Add("To-Be Phase Out") : .Items(2).Value = " B.PRODUCT_STATUS ='N' "
                End With
                
                'Frank 2012/03/30
                'Above with--end with statement will make Product_Status selectedindex=-1
                'If Product_Status(radio group) do not select any item, it will occurs sql not correct exception.
                Me.Product_Status.SelectedIndex = 0
                
            End If
            'If LCase(Session("user_id").ToString).StartsWith("erwin.vancreij") Or _
            '      LCase(Session("user_id").ToString).StartsWith("tam.tran") Or _
            '      LCase(Session("user_id").ToString).StartsWith("mike.bos") Or Util.IsAEUIT() Then
            '    Me.trPType.Visible = True
            'End If
        End If
        If Trim(Request("UID")) <> "" Then
            btnAdd2Cart.Visible = False : btnAdd2Cart2.Visible = False
            RequestUID = Trim(Request("UID"))
        End If
        '/ end
        If Not Page.IsPostBack Then
            'Category=PartNo&Part_No=P-TM&Match_Method=START_WITH&SBU=P-TD
            'If Request("Category") IsNot Nothing Then
            '    If Request("Category") = "ProductLine" Then
            '        Category.SelectedValue = "PRODUCT_LINE"
            '    End If
            '    If Request("Category") = "PartNo" Then
            '        Category.SelectedValue = "PART_NO"
            '    End If
            'End If
            'If Request("Part_No") IsNot Nothing Then
            '    part_no.Text = Request("Part_No")
            'End If
            'If Request("Match_Method") IsNot Nothing Then
            '    If Request("Match_Method") = "Whole" Then
            '        Match_Method.SelectedIndex = 0
            '    Else
            '        Match_Method.SelectedIndex = 2
            '    End If
            'End If
  
            Call InitialSearch()
        End If
    End Sub
    Private Function GetCheckATPLink(ByVal part_no As String) As String
        Return "/Product/QueryATP.aspx?part_no=" + part_no
    End Function
    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        'AdgSearch.Export2Excel("Products")
        If ViewState("SqlCommand") IsNot Nothing Then
            Dim dt As DataTable = GridView2DataTable(AdgSearch)
            For i As Integer = 0 To dt.Rows.Count - 1
                If dt.Rows(i).Item("Unit Price") IsNot Nothing AndAlso dt.Rows(i).Item("Unit Price").ToString.Trim.StartsWith("<a") Then
                    dt.Rows(i).Item("Unit Price") = ""
                End If
                If dt.Rows(i).Item("Model") IsNot Nothing AndAlso dt.Rows(i).Item("Model").ToString.Trim = "<a href='/Product/Model_Detail.aspx?model_no= ' target='_blank'> </a>" Then
                    dt.Rows(i).Item("Model") = ""
                End If
            Next
            dt.AcceptChanges()
            If dt.Columns.Contains("ColumnName") Then
                dt.Columns.Remove("ColumnName")
            End If
            'OrderUtilities.showDT(dt)
            dt.Columns.Remove("RoHS") : dt.Columns.Remove("Price & Availability") : dt.AcceptChanges()
            Util.DataTable2ExcelDownload(dt, "Products.xls")
        End If
    End Sub
    
    Public Shared Function GridView2DataTable(gv As GridView) As DataTable
        Dim table As New DataTable()
        Dim rowIndex As Integer = 0
        Dim cols As New List(Of String)()
        If Not gv.ShowHeader AndAlso gv.Columns.Count = 0 Then
            Return table
        End If
        Dim headerRow As GridViewRow = gv.HeaderRow
        Dim columnCount As Integer = headerRow.Cells.Count
        For i As Integer = 0 To columnCount - 1
            Dim text As String = GetCellText(headerRow.Cells(i))
            cols.Add(text.Trim())
        Next
        For Each r As GridViewRow In gv.Rows
            If r.RowType = DataControlRowType.DataRow Then
                Dim row As DataRow = table.NewRow()
                Dim j As Integer = 0
                For i As Integer = 0 To columnCount - 1
                    Dim text As String = GetCellText(r.Cells(i))
                    If 1 = 1 Then 'Not [String].IsNullOrEmpty(text) Then
                        If rowIndex = 0 Then
                            Dim columnName As String = cols(i)
                            'If [String].IsNullOrEmpty(columnName) Then
                            '    Continue For
                            'End If
                            'If table.Columns.Contains(columnName) Then
                            '    Continue For
                            'End If
                            Dim dc As DataColumn = table.Columns.Add()
                            dc.ColumnName = IIf(String.IsNullOrEmpty(columnName), "ColumnName", columnName)
                            dc.DataType = GetType(String)
                        End If
                        row(j) = text
                        j += 1
                    End If
                Next
                rowIndex += 1
                table.Rows.Add(row)
            End If
        Next
        Return table
    End Function
    Public Shared Function GetCellText(cell As TableCell) As String
        Dim text As String = cell.Text
        If Not String.IsNullOrEmpty(text) Then
            Return text
        End If
        For Each control As Control In cell.Controls
            If control IsNot Nothing AndAlso TypeOf control Is IButtonControl Then
                Dim btn As IButtonControl = TryCast(control, IButtonControl)
                text = btn.Text.Replace(vbCr & vbLf, "").Trim()
                Exit For
            End If
            If control IsNot Nothing AndAlso TypeOf control Is ITextControl Then
                Dim lc As LiteralControl = TryCast(control, LiteralControl)
                If lc IsNot Nothing Then
                    Continue For
                End If
                Dim l As ITextControl = TryCast(control, ITextControl)
                text = l.Text.Replace(vbCr & vbLf, "").Trim()
                Exit For
            End If
        Next
        Return text
    End Function
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:HiddenField runat="server" ID="xCount" Value="0" />
    <asp:HiddenField runat="server" ID="SeachFlag" />
    <table width="100%">
        <tr>
            <td>
                <table width="100%">
                    <tr valign="top">
                        <td align="left">
                            <asp:Panel runat="server" ID="searchPanel" DefaultButton="btnSearch">
                                <table width="80%">
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            Type:
                                        </td>
                                        <td>
                                            <asp:DropDownList runat="server" ID="Category">
                                                <asp:ListItem Text="Part No." Value="PART_NO" Selected="True" />
                                                <asp:ListItem Text="Model No." Value="MODEL_NO" />
                                                <asp:ListItem Text="Description" Value="PRODUCT_DESC" />
                                                <asp:ListItem Text="Product Line" Value="PRODUCT_LINE" />
                                                <%--   <asp:ListItem Text="Mrf P/N" Value="manufacturePN" />--%>
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            Search for:
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="part_no" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            Match Method:
                                        </td>
                                        <td>
                                            <asp:RadioButtonList runat="server" ID="Match_Method" RepeatDirection="Horizontal">
                                                <asp:ListItem Text="Whole" Value="='{0}' " />
                                                <asp:ListItem Text="Partial" Value=" like '%{0}%' " Selected="True" />
                                                <asp:ListItem Text="Start with" Value=" like '{0}%' " />
                                                <asp:ListItem Text="End With" Value=" like '%{0}' " />
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                    <tr id="trPType" runat = "server" visible="false">
                                        <td>
                                        </td>
                                        <td>
                                            Product Type:
                                        </td>
                                        <td>
                                            <asp:RadioButtonList runat="server" ID="rbtnPType" RepeatDirection="Horizontal" RepeatColumns="5">
                                                <asp:ListItem Text="All" Value="" />
                                                <asp:ListItem Text="Cable" Value="96OT" />
                                                <asp:ListItem Text="Memory" Value="96MM" />
                                                <asp:ListItem Text="Monitor + LCD Kit" Value="96MT" />
                                                <asp:ListItem Text="Hard Disk" Value="96HD" />
                                                <asp:ListItem Text="CPU" Value="96MP" />
                                                <asp:ListItem Text="Flash Memory" Value="968EM" />
                                                <asp:ListItem Text="CPU Board" Value="96CA" />
                                                <asp:ListItem Text="CD/DVD Rom" Value="96OD" />
                                                <asp:ListItem Text="Software" Value="96SW" />
                                                <asp:ListItem Text="Compact Flash" Value="96FM" />
                                                <asp:ListItem Text="Input Device" Value="96KB" />
                                                <asp:ListItem Text="Disk On Chip" Value="96SS" />
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            Product Status:
                                        </td>
                                        <td>
                                            <asp:RadioButtonList runat="server" ID="Product_Status" RepeatDirection="Horizontal"
                                                ForeColor="Orange">
                                                <asp:ListItem Value="ALL" Selected="True">ALL</asp:ListItem>
                                                <asp:ListItem Value=" B.PRODUCT_STATUS ='A' ">Active(=A)</asp:ListItem>
                                                <asp:ListItem Value=" B.PRODUCT_STATUS ='H' ">On-Hold(=H)</asp:ListItem>
                                                <asp:ListItem Value=" B.PRODUCT_STATUS ='N' ">To-Be Phase Out(=N)</asp:ListItem>
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            RoHS:
                                        </td>
                                        <td>
                                            <asp:RadioButtonList runat="server" ID="rblRoHs" RepeatDirection="Horizontal">
                                                <asp:ListItem Text="RoHS Only" Value="Y" Selected="True" />
                                                <asp:ListItem Text="All" Value="ALL" />
                                            </asp:RadioButtonList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" align="center">
                                            <asp:ImageButton runat="server" ID="btnSearch" ImageUrl="~/Images/btn7.jpg" AlternateText="Search"
                                                OnClick="btnSearch_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                        <td>
                            
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td align="left">
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:ImageButton runat="server" ID="btnToXls" ImageUrl="~/Images/icon_excel.jpg"
                                AlternateText="Export To Excel" OnClick="btnToXls_Click" Visible="false" />
                        </td>
                        <td width="5">
                        </td>
                        <td>
                            <asp:ImageButton runat="server" ID="btnAdd2Cart" ImageUrl="~/Images/btn_add2cart1.gif"
                                AlternateText="Add2Cart" OnClick="btnAdd2Cart_Click" Visible="false" />
                        </td>
                        <td width="500">
                        <asp:Label runat="server" ID="lbmsg" Font-Bold="true" ForeColor="Red"></asp:Label>
                        </td>
                        <td>
                        </td>
                        <td width="5">
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr valign="top">
            <td>
                <script src="/Includes/sortable.js" type="text/javascript"></script>
                <sgv:SmartGridView runat="server" ID="AdgSearch" AutoGenerateColumns="False" Width="97%"
                    AllowSorting="True" DataSourceID="SqlDataSource1" HeaderStyle-BackColor="#EBEADB"
                    DataKeyNames="part_no,model_no" OnRowDataBoundDataRow="AdgSearch_RowDataBoundDataRow"
                    colName='Unit Price,Model,Part No.,Description,Status,Product Line' class="sortable"
                    ShowWhenEmpty="False">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="2%" ItemStyle-HorizontalAlign="Center">
                            <HeaderTemplate>
                                No.
                            </HeaderTemplate>
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center" Width="2%"></ItemStyle>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center">
                            <HeaderTemplate>
                                <asp:CheckBox ID="all" runat="server" />
                            </HeaderTemplate>
                            <ItemTemplate>
                                <asp:CheckBox ID="item" runat="server" />
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Center"></HeaderStyle>
                            <ItemStyle HorizontalAlign="Center" Width="50px"></ItemStyle>
                        </asp:TemplateField>
                        <asp:BoundField HeaderText="Part No." DataField="part_no"    ItemStyle-CssClass="Tnowrap" />
                        <asp:BoundField HeaderText="Model" DataField="model_no"  ItemStyle-CssClass="Tnowrap" />
                        <asp:BoundField DataField="MFR_PART_NO" HeaderText="Manufacturer part no." />
                        <asp:BoundField DataField="product_desc" HeaderText="Description" ReadOnly="True" />
                        <asp:BoundField DataField="status" HeaderText="Status" ReadOnly="True" ItemStyle-HorizontalAlign="Center">
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:BoundField>
                        <asp:BoundField DataField="rohs_FLAG" HeaderText="RoHS" ReadOnly="True" SortExpression="rohs"
                            ItemStyle-HorizontalAlign="Center">
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:BoundField>
                        <%--        <asp:BoundField DataField="Class" HeaderText="Class" ReadOnly="True" SortExpression="Class" 
                                    ItemStyle-HorizontalAlign="Center"/>--%>
                        <asp:BoundField DataField="product_line" HeaderText="Product Line" ItemStyle-HorizontalAlign="Center"
                            ReadOnly="True">
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="Quantity" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:TextBox runat="server" ID="tbRowQty" Text="1" Width="40px" /><ajaxToolkit:FilteredTextBoxExtender
                                    runat="server" ID="ftbeQty" TargetControlID="tbRowQty" FilterType="Numbers" />
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>
                        <asp:BoundField DataField="pricing" HeaderText="Unit Price" ReadOnly="True" ItemStyle-HorizontalAlign="Center">
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:BoundField>
                        <asp:TemplateField HeaderText="Price & Availability" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <a href="../Order/PriceAndATP.aspx?Part_No=<%# Eval("part_no") %>" target="_blank">
                                    <img src="../Images/btn_check.gif" width="53" height="19" /></a>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center"></ItemStyle>
                        </asp:TemplateField>
                        <%--              <asp:BoundField DataField="manufacturePN" HeaderText="Mrf P/N" ItemStyle-HorizontalAlign="Center" 
                                    ReadOnly="True" />  --%>
                    </Columns>
                    <FixRowColumn FixRowType="Header" TableWidth="98%" TableHeight="500px" FixRows="-1"
                        FixColumns="0" />
                    <CustomPagerSettings PagingMode="default" TextFormat="{0} record per page/totla {1} records&nbsp;&nbsp;&nbsp;&nbsp;page {2}/total {3} page(s)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" />
                    <HeaderStyle BackColor="#EBEADB"></HeaderStyle>
                    <PagerSettings Position="Top" PageButtonCount="13" FirstPageText="First Page" PreviousPageText="Previous Page"
                        NextPageText="Next Page" LastPageText="Last Page" />
                    <PagerStyle BackColor="#C3DAF9" />
                    <CascadeCheckboxes>
                        <sgv:CascadeCheckbox ChildCheckboxID="item" ParentCheckboxID="all" />
                    </CascadeCheckboxes>
                </sgv:SmartGridView>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:B2B %>"
                    SelectCommand="" OnLoad="SqlDataSource1_Load"></asp:SqlDataSource>
            </td>
        </tr>
        <tr>
            <td align="left">
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="~/Images/icon_excel.jpg"
                                AlternateText="Export To Excel" OnClick="btnToXls_Click" Visible="false" />
                        </td>
            </td>
            <td width="5">
            </td>
            <td>
                <asp:ImageButton runat="server" ID="btnAdd2Cart2" ImageUrl="~/Images/btn_add2cart1.gif"
                    AlternateText="Add2Cart" OnClick="btnAdd2Cart_Click" Visible="false" />
            </td>
            <td width="5">
            </td>
            <td>
            </td>
            <td width="5">
            </td>
            <td>
            </td>
        </tr>
    </table>
    </td> </tr>
    <asp:PlaceHolder runat="server" ID="ph" />
    </table>
</asp:Content>
