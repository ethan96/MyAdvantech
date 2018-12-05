<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not IsPostBack Then
            If Request("QuoteID") IsNot Nothing AndAlso Not String.IsNullOrEmpty(Request("QuoteID")) Then
                Dim objcontext As New SiebelQuoteDataContext()
                Dim strcartId As String = Session("CART_ID"), i As Integer = 0
                Dim mycart As New CartList("b2b", "cart_detail_V2")
                MyCartX.DeleteCartAllItem(strcartId)
                Dim Master As SiebelQuoteMaster = objcontext.SiebelQuoteMasters.FirstOrDefault(Function(p) p.id = Request("QuoteID"))
                If Master Is Nothing Then
                    Response.Write("Quote id " & Request("QuoteID") & " is invalid and cannot be found.") : Response.End()
                    Exit Sub
                End If
                Dim ishaveBtos As Boolean = False, ASGPartNo As String = String.Empty
                Dim _EWlist As List(Of EWPartNo) = MyCartX.GetExtendedWarranty()
                Dim Quotes As List(Of SiebelQuoteDetail) = objcontext.SiebelQuoteDetails.Where(Function(p) p.MasterID = Request("QuoteID")).OrderBy(Function(p) p.Line_NO).ToList()
                For Each item As SiebelQuoteDetail In Quotes
                    If String.Equals(item.PartNO, "PTRADE-BTO") Then
                        ishaveBtos = True
                    End If
                    If item.PartNO.ToString.StartsWith("AGS-EW-", StringComparison.InvariantCultureIgnoreCase) Then
                        If ishaveBtos Then
                            ASGPartNo = item.PartNO
                            Continue For        
                        End If

                        Dim EWid As Integer = 0
                        For Each _ew As EWPartNo In _EWlist
                            If String.Equals(_ew.EW_PartNO, item.PartNO.Trim, StringComparison.CurrentCultureIgnoreCase) Then
                                EWid = _ew.ID
                                Exit For
                            End If
                        Next
                        If EWid <> 0 Then
                            Dim maxLineno As Integer = MyCartX.getBtosMaxLineNo(strcartId, 0)
                            Dim ParentItem As CartItem = MyCartX.GetCartItem(strcartId, maxLineno)
                            If ParentItem IsNot Nothing Then
                                MyCartX.addExtendedWarrantyV2(ParentItem, EWid)
                            End If
                        End If
                        Continue For
                    End If

                    Dim line_no As Integer = MyCartOrderBizDAL.Add2Cart_BIZ(strcartId, item.PartNO, item.QTY, 0, item.ItemType, "", 1, 0, Now, item.Description, "", item.HigherLevel, False)
                    If Decimal.TryParse(item.UnitPrice, 0) AndAlso Decimal.Parse(item.UnitPrice) > 0 AndAlso item.ItemType = CartItemType.Part Then
                        mycart.Update(String.Format("cart_id='{0}' and line_no='{1}'", strcartId, line_no), String.Format("unit_price='{0}'", item.UnitPrice))
                    End If
            
                    
                Next
                If ishaveBtos AndAlso Not String.IsNullOrEmpty(ASGPartNo) Then
                    Dim EWid As Integer = 0
                    For Each _ew As EWPartNo In _EWlist
                        If String.Equals(_ew.EW_PartNO, ASGPartNo.Trim, StringComparison.CurrentCultureIgnoreCase) Then
                            EWid = _ew.ID
                            Exit For
                        End If
                    Next
                    If EWid <> 0 AndAlso ishaveBtos Then
                        Dim PTRADE_ParentItem As CartItem = MyCartX.GetCartItem(strcartId, 100)
                        If PTRADE_ParentItem IsNot Nothing Then
                            MyCartX.addExtendedWarrantyV2(PTRADE_ParentItem, EWid)
                        End If
                    End If
                End If
                
                Dim _CartMaster As New CartMaster
                _CartMaster.CartID = strcartId
                _CartMaster.ErpID = Master.AccountErpid
                _CartMaster.CreatedDate = Now
                _CartMaster.QuoteID = Master.QuoteRowid
                _CartMaster.Currency = Session("COMPANY_CURRENCY")
                _CartMaster.CreatedBy = Session("user_id")
                _CartMaster.LastUpdatedDate = Now
                _CartMaster.LastUpdatedBy = Session("user_id")
                _CartMaster.OpportunityID = ""
                If Master.OptyID IsNot Nothing AndAlso Not String.Equals(Master.OptyID, "NEW ID", StringComparison.CurrentCultureIgnoreCase) Then
                    _CartMaster.OpportunityID = Master.OptyID
                End If
                _CartMaster.OpportunityAmount = Master.OptyAmount
                MyCartX.LogCartMaster(_CartMaster)
                Response.Redirect("~/Order/Cart_ListV2.aspx")
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

