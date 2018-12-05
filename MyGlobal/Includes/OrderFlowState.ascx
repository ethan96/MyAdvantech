<%@ Control Language="VB" ClassName="OrderFlowState" %>

<script runat="server">
    
    Function FocusState(ByVal state As String) As Integer
        Select Case UCase(state)
            Case "CART"
                cart.Src = "../images/ebiz.aeu.face/cart_light.gif"
                oinfo.Src = "../images/ebiz.aeu.face/order_halfdark.gif"
            Case "ORDERINFO"
                oinfo.Src = "../images/ebiz.aeu.face/order_light.gif"
                ddcal.Src = "../images/ebiz.aeu.face/calculation_halfdark.gif"
            Case "DDCAL"
                ddcal.Src = "../images/ebiz.aeu.face/calculation_light.gif"
                piview.Src = "../images/ebiz.aeu.face/preview_halfdark_2.gif"
            Case "PIPREVIEW"
                piview.Src = "../images/ebiz.aeu.face/preview_light_2.gif"
                oconfirm.Src = "../images/ebiz.aeu.face/confirm_halfdark.gif"
            Case "ORDERCONFIRM"
                oconfirm.Src = "../images/ebiz.aeu.face/confirm_light.gif"
            Case Else
                
        End Select
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Lcase(Request.ServerVariables("PATH_INFO")) Like "*cart_list*" Then
            Me.FocusState("CART")
        Else
            If Lcase(Request.ServerVariables("PATH_INFO")) Like "*orderinfo_input*" Then
                Me.FocusState("ORDERINFO")
            Else
                If Lcase(Request.ServerVariables("PATH_INFO")) Like "*dd_cal*" Then
                    Me.FocusState("DDCAL")
                Else
                    If Lcase(Request.ServerVariables("PATH_INFO")) Like "*pi_preview*" Then
                        Me.FocusState("PIPREVIEW")
                    Else
                        If Lcase(Request.ServerVariables("PATH_INFO")) Like "*order_confirm*" Then
                            Me.FocusState("ORDERCONFIRM")
                        End If
                    End If
                End If
            End If
        End If
    End Sub
</script>

<table id="Table1" border="0" cellpadding="0" cellspacing="0" runat="server">
    <tr>
        <td>
            <img alt="cart" runat="server" id="cart" src="../images/ebiz.aeu.face/cart_dark.gif" /></td>
        <td>
            <img alt="orderinfo" runat="server" id="oinfo" src="../images/ebiz.aeu.face/order_dark.gif" /></td>
        <td>
            <img alt="ddcal" runat="server" id="ddcal" src="../images/ebiz.aeu.face/calculation_dark.gif" /></td>
        <td>
            <img alt="piview" runat="server" id="piview" src="../images/ebiz.aeu.face/preview_dark_2.gif" /></td>
        <td>
            <img runat="server" id="oconfirm" alt="orderconfirm" src="../images/ebiz.aeu.face/confirm_dark.gif" /></td>
    </tr>
</table>
