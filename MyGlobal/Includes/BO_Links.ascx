<%@ Control Language="VB" ClassName="BO_Links" %>
<script runat="server">
    
    Private _ClickLinkName As String = ""
    

    Public Property ClickLinkName() As String
 
        Get
            Return Me._ClickLinkName
        End Get
 
        Set(ByVal value As String)
            Me._ClickLinkName = value
        End Set
 
    End Property
    
    
    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)

       
        Select Case Me._ClickLinkName
            Case "BO_OrderTracking"
                Me.HyperLink1.CssClass = "h2"
                Me.HyperLink1.Text = ">" & Me.HyperLink1.Text.TrimStart(">")
            Case "BO_B2BOrderInquiry"
                Me.HyperLink2.CssClass = "h2"
                Me.HyperLink2.Text = ">" & Me.HyperLink2.Text.TrimStart(">")
            Case "BO_BackOrderInquiry"
                Me.HyperLink3.CssClass = "h2"
                Me.HyperLink3.Text = ">" & Me.HyperLink3.Text.TrimStart(">")
            Case "BO_InvoiceInquiry"
                Me.HyperLink4.CssClass = "h2"
                Me.HyperLink4.Text = ">" & Me.HyperLink4.Text.TrimStart(">")
            Case "ARInquiry_WS"
                Me.HyperLink5.CssClass = "h2"
                Me.HyperLink5.Text = ">" & Me.HyperLink5.Text.TrimStart(">")
            Case "ShippingCalendar"
                Me.HyperLink6.CssClass = "h2"
                Me.HyperLink6.Text = ">" & Me.HyperLink6.Text.TrimStart(">")
            Case "BO_SerialInquiry"
                Me.HyperLink7.CssClass = "h2"
                Me.HyperLink7.Text = ">" & Me.HyperLink7.Text.TrimStart(">")
            Case "BO_ForwarderTracking"
                Me.HyperLink8.CssClass = "h2"
                Me.HyperLink8.Text = ">" & Me.HyperLink8.Text.TrimStart(">")
            Case "RMAWarrantyLookup"
                Me.HyperLink9.CssClass = "h2"
                Me.HyperLink9.Text = ">" & Me.HyperLink9.Text.TrimStart(">")
            Case "MyWarrantyExpireItems"
                Me.HyperLink10.CssClass = "h2"
                Me.HyperLink10.Text = ">" & Me.HyperLink10.Text.TrimStart(">")

                
        End Select
        
    End Sub
</script>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td height="10">
        </td>
    </tr>
    <tr>
        <td height="24" class="menu_title">
            Order Tracking
        </td>
    </tr>
    <tr>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                <tr>
                    <td height="10">
                    </td>
                    <td>
                    </td>
                </tr>
                <tr>
                    <td width="5%" height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink1" runat="server" text="Order Tracking" navigateurl="~/Order/BO_OrderTracking.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="5%" height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink2" runat="server" text="My B2B Order" navigateurl="~/Order/BO_B2BOrderInquiry.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="5%" height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink3" runat="server" text="Back Order" navigateurl="~/Order/BO_BackOrderInquiry.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td width="5%" height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink4" runat="server" text="Invoice" navigateurl="~/Order/BO_InvoiceInquiry.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" alt="" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink5" runat="server" text="Account Payable"  navigateurl="~/Order/ARInquiry_WS.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" alt="" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink6" runat="server" text="Shipping Calendar" navigateurl="~/Order/ShippingCalendar.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" alt="" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink7" runat="server" text="Serial Number Inquiry" navigateurl="~/Order/BO_SerialInquiry.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" alt="" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink8" runat="server" text="Forwarder Number Tracking" navigateurl="~/Order/BO_ForwarderTracking.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" alt="" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink9" runat="server" text="Warranty Lookup" navigateurl="~/Order/RMAWarrantyLookup.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="25">
                    </td>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="8%" valign="top">
                                    <img src="../images/point_02.gif" alt="" width="7" height="14" />
                                </td>
                                <td class="menu_title02">
                                    <asp:HyperLink ID="HyperLink10" runat="server" text="Warranty Expire" navigateurl="~/Order/MyWarrantyExpireItems.aspx"></asp:HyperLink>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="15">
                    </td>
                    <td>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
