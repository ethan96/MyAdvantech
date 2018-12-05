<%@ Control Language="VB" ClassName="soldtoshipto" %>
<%@ Import Namespace="MyOrderDS" %>
<%@ Import Namespace="MyOrderDSTableAdapters" %>
<script runat="server">
    Private _orderid As String
    Public Property OrderID As String
        Get
            Return _orderid
        End Get
        Set(value As String)
            _orderid = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not IsPostBack Then
            If Not String.IsNullOrEmpty(OrderID) Then
                Dim A As New ORDER_PARTNERSTableAdapter
                Dim OPner As ORDER_PARTNERSDataTable = A.GetPartnersByOrderID(Me.OrderID)
                For Each r As ORDER_PARTNERSRow In OPner
                    If r.TYPE.Equals("SOLDTO", StringComparison.OrdinalIgnoreCase) Then
                        litsoldto.Text = r.ERPID
                        litsoldtocompany.Text = r.NAME
                        litsoldtotel.Text = r.TEL
                        litsoldtoattention.Text = r.ATTENTION
                        If AuthUtil.IsBBUS Then
                            litsoldtoaddress.Text = r.STREET + " " + r.STREET2
                            Dim addr2 As StringBuilder = New StringBuilder()
                            If Not String.IsNullOrEmpty(r.CITY) Then addr2.AppendFormat("{0}, ", r.CITY)
                            If Not String.IsNullOrEmpty(r.STATE) Then addr2.AppendFormat("{0}, ", r.STATE)
                            If Not String.IsNullOrEmpty(r.ZIPCODE) Then addr2.AppendFormat("{0}, ", r.ZIPCODE)
                            If Not String.IsNullOrEmpty(r.COUNTRY) Then addr2.Append(r.COUNTRY)
                            litsholdtoaddress2.Text = addr2.ToString
                        Else
                            litsoldtoaddress.Text = r.STREET + " " + r.CITY + " " + r.STATE + " " + r.COUNTRY + " " + r.ZIPCODE
                            litsholdtoaddress2.Text = r.STREET2
                        End If
                    End If
                    If r.TYPE.Equals("S", StringComparison.OrdinalIgnoreCase) Then
                        litshipto.Text = r.ERPID
                        litshiptocompany.Text = r.NAME
                        litshiptotel.Text = r.TEL
                        litshiptoattention.Text = r.ATTENTION
                        If AuthUtil.IsBBUS Then
                            litshiptoaddress.Text = r.STREET + " " + r.STREET2
                            Dim addr2 As StringBuilder = New StringBuilder()
                            If Not String.IsNullOrEmpty(r.CITY) Then addr2.AppendFormat("{0}, ", r.CITY)
                            If Not String.IsNullOrEmpty(r.STATE) Then addr2.AppendFormat("{0}, ", r.STATE)
                            If Not String.IsNullOrEmpty(r.ZIPCODE) Then addr2.AppendFormat("{0}, ", r.ZIPCODE)
                            If Not String.IsNullOrEmpty(r.COUNTRY) Then addr2.Append(r.COUNTRY)
                            litshiptoaddress2.Text = addr2.ToString
                        Else
                            litshiptoaddress.Text = r.STREET + " " + r.CITY + " " + r.STATE + " " + r.COUNTRY + " " + r.ZIPCODE
                            litshiptoaddress2.Text = r.STREET2
                        End If
                    End If
                    'If r.TYPE.Equals("EM", StringComparison.OrdinalIgnoreCase) AndAlso AuthUtil.IsAJP Then
                    '    'Enable all visibility
                    '    tdendcustomerhead.Visible = True : tdendcustomer.Visible = True
                    '    tdendcustomercompanyhead.Visible = True : tdendcustomercompany.Visible = True
                    '    tdendcustomeraddresshead.Visible = True : tdendcustomeraddress.Visible = True
                    '    tdendcustomeraddress2head.Visible = True : tdendcustomeraddress2.Visible = True
                    '    tdendcustomertelhead.Visible = True : tdendcustomertel.Visible = True
                    '    tdendcustomerattentionhead.Visible = True

                    '    litendcustomer.Text = r.ERPID
                    '    litendcustomercompany.Text = r.NAME
                    '    litendcustomertel.Text = r.TEL
                    '    If AuthUtil.IsBBUS Then
                    '        litendcustomeraddress.Text = r.STREET + " " + r.STREET2
                    '        Dim addr2 As StringBuilder = New StringBuilder()
                    '        If Not String.IsNullOrEmpty(r.CITY) Then addr2.AppendFormat("{0}, ", r.CITY)
                    '        If Not String.IsNullOrEmpty(r.STATE) Then addr2.AppendFormat("{0}, ", r.STATE)
                    '        If Not String.IsNullOrEmpty(r.ZIPCODE) Then addr2.AppendFormat("{0}, ", r.ZIPCODE)
                    '        If Not String.IsNullOrEmpty(r.COUNTRY) Then addr2.Append(r.COUNTRY)
                    '        litendcustomeraddress2.Text = addr2.ToString
                    '    Else
                    '        litendcustomeraddress.Text = r.STREET + " " + r.CITY + " " + r.STATE + " " + r.COUNTRY + " " + r.ZIPCODE
                    '        litendcustomeraddress2.Text = r.STREET2
                    '    End If
                    'End If
                Next
            End If
        End If
    End Sub
    'Function getCompanyName(ByVal Company_id As String) As String
    '    Dim CompanyName As Object = dbUtil.dbExecuteScalar("MY", "select top 1 isnull(company_name,'') from SAP_DIMCOMPANY where company_id='" & Company_id & "'")
    '    If Not IsNothing(CompanyName) Then
    '        Return CompanyName
    '    End If
    '    Return ""
    'End Function
</script>
<div id="divCustInfo" class="mytable">
    <div class="bk5">
    </div>
    <table width="100%">
        <tr>
            <td style="background-color: #ededed; font-weight: bold" colspan="4">
                Customer Information
            </td>
        </tr>
        <tr>
            <td class="h5">
                Sold to:
            </td>
            <td>
                <asp:Literal runat="server" ID="litsoldto"></asp:Literal>
            </td>
            <td class="h5">
                Ship to:
            </td>            
            <td>
                <asp:Literal runat="server" ID="litshipto"></asp:Literal>
            </td>
<%--            <td class="h5" runat="server" id="tdendcustomerhead" visible="false">
                End Customer:
            </td>
            <td runat="server" id="tdendcustomer" visible="false">
                <asp:Literal runat="server" ID="litendcustomer"></asp:Literal>
            </td>--%>
        </tr>
        <tr>
            <td class="h5">
                Company:
            </td>
            <td>
                <asp:Literal runat="server" ID="litsoldtocompany"></asp:Literal>
            </td>
            <td class="h5">
                Company:
            </td>
            <td>
                <asp:Literal runat="server" ID="litshiptocompany"></asp:Literal>
            </td>
<%--            <td class="h5" runat="server" id="tdendcustomercompanyhead" visible="false">
                Company:
            </td>
            <td runat="server" id="tdendcustomercompany" visible="false">
                <asp:Literal runat="server" ID="litendcustomercompany"></asp:Literal>
            </td>--%>
        </tr>
        <tr>
            <td class="h5">
                Address1:
            </td>
            <td>
                <asp:Literal runat="server" ID="litsoldtoaddress"></asp:Literal>
            </td>
            <td class="h5">
                Address1:
            </td>
            <td>
                <asp:Literal runat="server" ID="litshiptoaddress"></asp:Literal>
            </td>
<%--            <td class="h5"  runat="server" id="tdendcustomeraddresshead" visible="false">
                Address1:
            </td>
            <td  runat="server" id="tdendcustomeraddress" visible="false">
                <asp:Literal runat="server" ID="litendcustomeraddress"></asp:Literal>
            </td>--%>
        </tr>
        <tr>
            <td class="h5">
                Address2:
            </td>
            <td>
                <asp:Literal runat="server" ID="litsholdtoaddress2"></asp:Literal>
            </td>
            <td class="h5">
                Address2:
            </td>
            <td>
                <asp:Literal runat="server" ID="litshiptoaddress2"></asp:Literal>
            </td>
<%--            <td class="h5"  runat="server" id="tdendcustomeraddress2head" visible="false">
                Address2:
            </td>
            <td  runat="server" id="tdendcustomeraddress2" visible="false">
                <asp:Literal runat="server" ID="litendcustomeraddress2"></asp:Literal>
            </td>--%>
        </tr>
        <tr>
            <td class="h5">
                Tel:
            </td>
            <td>
                <asp:Literal runat="server" ID="litsoldtotel"></asp:Literal>
            </td>
            <td class="h5">
                Tel:
            </td>
            <td>
                <asp:Literal runat="server" ID="litshiptotel"></asp:Literal>
            </td>
<%--            <td class="h5"  runat="server" id="tdendcustomertelhead" visible="false">
                Tel:
            </td>
            <td  runat="server" id="tdendcustomertel" visible="false">
                <asp:Literal runat="server" ID="litendcustomertel"></asp:Literal>
            </td>--%>
        </tr>
        <tr>
            <td colspan="2">
                <asp:Literal runat="server" ID="litsoldtoattention" Visible="false"></asp:Literal>
            </td>
            <td class="h5">
                Attention:
            </td>
            <td>
                <asp:Literal runat="server" ID="litshiptoattention"></asp:Literal>
            </td>
<%--            <td colspan="2"  runat="server" id="tdendcustomerattentionhead" visible="false">
                <asp:Literal runat="server" ID="litendcustomerattention" Visible="false"></asp:Literal>
            </td>--%>
        </tr>
    </table>
</div>
