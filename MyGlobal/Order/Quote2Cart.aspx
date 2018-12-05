<%@ Page Language="VB" %>

<%@ Import Namespace="quote" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    
    Protected Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect(String.Format("Quote2CartV3.aspx{0}", Request.Url.Query))
        Exit Sub
    End Sub
    Dim mycart As New CartList("b2b", "cart_detail")
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Exit Sub
        Dim quoteId As String = Request("UID")
        Dim MyQuoteMaster As QuotationMaster = eQuotationUtil.GetQuoteMasterByQuoteid(quoteId)
        If MyQuoteMaster IsNot Nothing Then
            Dim _IsQuote2_0 As Boolean = MyQuoteMaster.Is2_0X
            Session("Quote2_5") = Not _IsQuote2_0
        End If
        If Util.IsTestingQuote2Order() Then
            Response.Redirect(String.Format("Quote2CartV2.aspx{0}", Request.Url.Query))
        End If
        Dim WS As New quote.quoteExit : WS.Timeout = -1
        If Util.IsTesting() Then
            WS.Url = "http://eq.advantech.com:8100/Services/QuoteExit.asmx"
        End If
        If WS.isQuoteExpired(quoteId) Then
            Response.Write("Quotation '" & quoteId & "' is expired.") : Response.End()
        End If
      
        Dim QuoteMaster As EQDS.QuotationMasterDataTable = Nothing, QuoteDetail As EQDS.QuotationDetailDataTable = Nothing, QuotePartner As EQDS.EQPARTNERDataTable = Nothing, QuoteNotes As EQDS.QuotationNoteDataTable = Nothing
        Dim ReturnValue As Boolean = WS.getQuotationMasterByIdV4(quoteId, QuoteMaster, QuoteDetail, QuotePartner, QuoteNotes)
        If ReturnValue Then
            If QuoteDetail.Count > 0 Then
                'OrderUtilities.showDT(QuoteDetail)
                mycart.Delete(String.Format("cart_id='{0}'", Session("cart_id")))
                For Each x As EQDS.QuotationDetailRow In QuoteDetail.Rows
                    Dim isUpdatePrice As Integer = 0
                    If Util.IsFranchiser(QuoteMaster(0).createdBy, "") Then
                        isUpdatePrice = 1
                    End If
                    Dim line_no As Integer = mycart.ADD2CART(Session("cart_id"), x.partNo, x.qty, x.ewFlag, x.oType, IIf(IsDBNull(x.category), "", x.category), isUpdatePrice, 1, Now, x.description, x.deliveryPlant)
                    If isUpdatePrice = 0 Then
                        mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", Session("cart_id"), line_no), String.Format("list_price='{0}',unit_price='{1}',ounit_price='{1}'", x.Item("listprice"), x.Item("newunitprice")))
                    End If
                Next
                mycart.Update(String.Format("cart_id='{0}'", Session("cart_id")), String.Format("Quote_id='{0}'", quoteId))
                'dbUtil.dbExecuteNoQuery("b2b", String.Format("delete from quotation2cart_Log where QUOTE_ID ='{0}';insert into quotation2cart_Log values('{0}','{1}')", quoteId, Session("cart_id")))
                
                'Frank 2012/10/4:If quote id start with AUSQ or AMXQ then redirect page to /Order/Cart_list.aspx
                'Response.Redirect("~/Order/OrderInfo.aspx")
                If quoteId.StartsWith("AUSQ", StringComparison.InvariantCultureIgnoreCase) OrElse _
                   quoteId.StartsWith("AMXQ", StringComparison.InvariantCultureIgnoreCase) Then
                    Response.Redirect("~/Order/Cart_list.aspx")
                Else
                    Response.Redirect("~/Order/OrderInfo.aspx")
                End If
                
            End If

        End If
        
    End Sub
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
