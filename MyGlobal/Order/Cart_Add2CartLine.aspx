<%@ Page Language="VB" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

    Dim iRet As Integer = 0
    Dim mycart As New CartList("b2b", "cart_detail_v2")
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        'Ryan 20160829 Add is valid parts validation
        Dim refmsg As String = String.Empty
        Dim DefaultShipto As String = Advantech.Myadvantech.Business.UserRoleBusinessLogic.MYAgetShiptoIDBySoldtoID(Session("company_id").ToString(), Session("cart_id").ToString)
        Dim CountryCode As String = Advantech.Myadvantech.Business.UserRoleBusinessLogic.getCountryCodeByERPID(DefaultShipto)
        If Advantech.Myadvantech.Business.PartBusinessLogic.IsInvalidParts(Session("company_id").ToString(), Session("org_id").ToString, Request("part_no").ToString(),
                 Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString), CountryCode, Util.IsInternalUser(Session("user_id")), refmsg) Then
            Util.JSAlertRedirect(Me.Page, refmsg, "../Order/cart_listV2.aspx")
            Exit Sub
        End If

        'Ryan 20180309 Disable original TW01 rule, new function isTW01BTOSInvalidParts is applied
        If MyCartOrderBizDAL.isTW01BTOSInvalidParts(Request("part_no"), Advantech.Myadvantech.Business.UserRoleBusinessLogic.getPlantByOrg(Session("org_id").ToString)) Then
            If Util.IsInternalUser2 Then
                Util.JSAlertGoBack1(Me.Page, "Only A/B/C+ parts are allowed to be added to a configuration, please check again.")
            Else
                Util.JSAlertGoBack1(Me.Page, "This part is not allowed to be added to a configuration manually, please contact your sales representative for more information.")
            End If
            Exit Sub
        End If
        'If MyCartX.IsHaveBtos(Session("Cart_id")) Then
        '    If Session("org_id").ToString.Equals("TW01") AndAlso
        '        Not (Session("company_id").ToString().Equals("ADVAJP", StringComparison.OrdinalIgnoreCase) OrElse Session("company_id").ToString().Equals("ADVAMY", StringComparison.OrdinalIgnoreCase)) Then
        '        If Not (Request("part_no").StartsWith("X", StringComparison.InvariantCultureIgnoreCase) Or Request("part_no").StartsWith("Y", StringComparison.InvariantCultureIgnoreCase) _
        '                Or Request("part_no").StartsWith("17", StringComparison.InvariantCultureIgnoreCase)) Then
        '            Util.JSAlertGoBack1(Me.Page, "Only X/Y parts and cables/wires which part number start with 17 can be added to a configuration manually.")
        '            Exit Sub
        '        End If
        '    End If
        'End If


        ' If Request("part_no") Is Nothing OrElse Request("part_no").ToString().Trim() = "" OrElse OrderUtilities.BtosOrderCheck() = 1 Then
        If Request("part_no") Is Nothing OrElse Request("part_no").ToString().Trim() = "" Then
            Response.Redirect("../Order/cart_listV2.aspx")
        End If
        If OrderUtilities.IsMSSoft(Request("part_no").ToString()) Then
            Util.JSAlertRedirect(Me.Page, "MS Software cannot be bought at standalone basis", "../Order/cart_listV2.aspx")
            Exit Sub
        End If
        If (HttpContext.Current.Session("org_id").ToString.ToUpper.StartsWith("CN") AndAlso SAPDAL.CommonLogic.isMEDC(Request("part_no").ToString()) AndAlso Not Util.IsInternalUser2()) Then
            Util.JSAlertGoBack1(Me.Page, "Part No [" & Request("part_no").ToString() & "] cannot be added to cart, please contact sales.")
            Exit Sub
        End If

        Dim intCount As Integer = 0, intMaxLineNo As Integer = 0, intQty As Integer = 0, unit_price As Decimal = 0, list_price As Decimal = 0, iRet As Integer = 0

        Dim part_no As String = ""
        If Request("part_no") <> "" Then part_no = Request("part_no").Trim().ToUpper

        If IsNumeric(Request("qty")) Then
            intQty = CLng(Request("qty"))
        Else
            intQty = 1
        End If

        iRet = OrderUtilities.GetPrice(part_no, Session("company_id"), Session("org_id"), intQty, list_price, unit_price)

        Dim dr9 As DataTable = dbUtil.dbGetDataTable("B2B", "select isnull(max(line_no),0) As line_no from cart_detail where cart_id='" & Session("cart_id") & "' and line_no<100")
        If dr9.Rows.Count > 0 Then
            intMaxLineNo = CInt(dr9.Rows(0).Item("line_no")) + 1
        Else
            intMaxLineNo = 1
        End If

        If Request("cart_id") <> "" Then
            Dim dr99 As DataTable = dbUtil.dbGetDataTable("B2B", "select * from cart_detail where cart_id='" & Request("cart_id") & "'")
            For Each r_dr99 As DataRow In dr99.Rows
                Dim strPart_No = r_dr99.Item("part_no")
                'jackie add 2006/10/24 for btos add 2 cart cause line no begin from 1
                If OrderUtilities.Add2CartCheck(strPart_No, Session("user_id")) Then
                    intQty = CDbl(r_dr99.Item("qty"))
                    Dim dblListPrice As Decimal = 0
                    Dim dblUnitPrice As Decimal = 0
                    iRet = OrderUtilities.GetPrice(strPart_No, Session("company_id"), "EU10", intQty, dblListPrice, dblUnitPrice)
                    iRet = OrderUtilities.CartLine_Add(Session("cart_id"), intMaxLineNo, strPart_No, intQty, dblListPrice, dblUnitPrice, "EUH1", "0")
                    intMaxLineNo = intMaxLineNo + 1
                End If
            Next

            Response.Redirect("../order/cart_listV2.aspx")
            Exit Sub
        End If

        'iRet = OrderUtilities.CartLine_Add(Session("cart_id"), intMaxLineNo, part_no, intQty, list_price, unit_price, "EUH1", "0")

        Dim ew_flag As Integer = 0, higherLevel As Integer = 0
        Dim otype As Integer = 0
        Dim cate As String = ""
        If mycart.isBtoOrder(Session("cart_id")) = 1 Then
            otype = 1
            cate = "OTHERS"
            higherLevel = 100
        End If
        mycart.ADD2CART_V2(Session("cart_id"), part_no, intQty, ew_flag, otype, cate, 1, 1, Now, "", "", higherLevel, False)
        Response.Redirect("../order/cart_listV2.aspx")
    End Sub


</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
