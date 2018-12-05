<%@ Control Language="VB" ClassName="PartialDeliver" %>

<script runat="server">
    'Private _isFromExcel As Boolean = False
    'Public Property isFromExcel As Boolean
    '    Get
    '        Return _isFromExcel
    '    End Get
    '    Set(ByVal value As Boolean)
    '        _isFromExcel = value
    '    End Set
    'End Property
    Dim CartId As String = "", mycart As New CartList("b2b", "cart_detail")
    Dim _IsHaveBtos As String = False
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        CartId = Session("cart_id")
        _IsHaveBtos = MyCartX.IsHaveBtos(CartId)
        If Not IsPostBack Then

            'Ryan 20161018 New logic for partial button control
            If Not Session("org_id").ToString.Trim.Equals("US01", StringComparison.OrdinalIgnoreCase) Then
                If _IsHaveBtos Then
                    rbtnIsPartial.SelectedValue = "1"
                    rbtnIsPartial.Enabled = False
                Else
                    If Session("org_id").ToString.Trim.Equals("SG01", StringComparison.OrdinalIgnoreCase) Or
                       Session("org_id").ToString.Trim.Equals("ID01", StringComparison.OrdinalIgnoreCase) Or
                       Session("org_id").ToString.Trim.Equals("MY01", StringComparison.OrdinalIgnoreCase) Or
                       Session("org_id").ToString.Trim.Equals("TL01", StringComparison.OrdinalIgnoreCase) Then
                        rbtnIsPartial.SelectedValue = "1"
                    End If
                End If

                '20141103 Show  關於組裝單設定邏輯裡，請幫忙跟單品一樣，統一設定為可partial shipment=Y 這樣串單至SAP時, 才可以先吃到部份庫存  
                If SAPDOC.IsATWCustomer() Then
                    rbtnIsPartial.SelectedValue = "1"
                    rbtnIsPartial.Enabled = True
                End If

                'Ryan 20170516 AJP Logic
                If Session("org_id").ToString.Trim.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
                    rbtnIsPartial.SelectedValue = "1"
                    rbtnIsPartial.Enabled = True
                End If
            Else
                'Ryan 20161020 US01 "MUST" set partial to default false!
                rbtnIsPartial.SelectedValue = "0"
            End If

            'Ryan 20161018 Comment below code out due to new logic is applied.
            'If Session("org_id").ToString.Trim.Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
            '    If _IsHaveBtos OrElse MYSAPBIZ.isCustomerCompleteDeliv(Session("Company_id"), Session("Org_id")) Then
            '        rbtnIsPartial.SelectedValue = "0"
            '        rbtnIsPartial.Enabled = False
            '    End If
            'Else
            '    rbtnIsPartial.SelectedValue = "0"
            'End If

            ''20150526 Alex add: if current ORG id is SG01 or ID01 or MY01 or TL01 and the shopping cart has loose items only(no system in the cart), set Partial OK to Y as default.
            'If Session("org_id").ToString.Trim.Equals("TW01", StringComparison.OrdinalIgnoreCase) Or
            '   Session("org_id").ToString.Trim.Equals("SG01", StringComparison.OrdinalIgnoreCase) Or
            '   Session("org_id").ToString.Trim.Equals("ID01", StringComparison.OrdinalIgnoreCase) Or
            '   Session("org_id").ToString.Trim.Equals("MY01", StringComparison.OrdinalIgnoreCase) Or
            '   Session("org_id").ToString.Trim.Equals("TL01", StringComparison.OrdinalIgnoreCase) Then
            '    If _IsHaveBtos Then
            '        rbtnIsPartial.SelectedValue = "0"
            '    Else
            '        rbtnIsPartial.SelectedValue = "1"
            '    End If
            'ElseIf Session("org_id").ToString.Trim.Equals("JP01", StringComparison.OrdinalIgnoreCase) Then
            '    'Ryan 20161017 Set radio button to disable for JP01 BTOS Order.
            '    If _IsHaveBtos Then
            '        rbtnIsPartial.SelectedValue = "1"
            '        rbtnIsPartial.Enabled = False
            '    End If
            'End If
            'End Ryan 20161018 Comment out.

        End If

    End Sub
</script>
<table width="100%" cellpadding="0" cellspacing="0" id="pdtb" runat="server">
    <tr>
        <td class="h5" style="width: 25%; white-space: nowrap">Partial OK?:
        </td>
        <td>
            <asp:RadioButtonList runat="server" ID="rbtnIsPartial" RepeatDirection="Horizontal">
                <asp:ListItem Value="1" Selected="True">Y</asp:ListItem>
                <asp:ListItem Value="0">N</asp:ListItem>
            </asp:RadioButtonList>
        </td>
    </tr>
</table>
