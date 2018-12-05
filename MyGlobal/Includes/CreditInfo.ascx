<%@ Control Language="VB" ClassName="CreditInfo" %>

<script runat="server">
    Public isBalanceExpired As Boolean = False

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)

        If Not Page.IsPostBack Then
            Dim companyID As String = Session("company_id")
            Dim OrgID As String = Session("org_id")

            Dim cld As Advantech.Myadvantech.DataAccess.CreditLimitData = Advantech.Myadvantech.Business.QuoteBusinessLogic.GetCustomerCreditExposure(companyID, OrgID)

            Me.lbERPID.Text = companyID
            Me.lbOrgID.Text = OrgID
            Me.lbCreditControlArea.Text = cld.CreditControlAreaOption.ToString
            Me.lbCurrency.Text = cld.Currency.ToString
            Me.lbCreditLimit.Text = cld.CreditLimit
            Me.lbCreditExposure.Text = cld.CreditExposure
            'Me.lbPercentage.Text = cld.Percentage
            Me.lbPercentage.Text = Math.Round(cld.CreditLimitUsed * 100, 2, MidpointRounding.AwayFromZero) & " %"
            Me.lbReceivables.Text = cld.Receivables
            Me.lbSpecialLiability.Text = cld.SpecialLiability
            Me.lbSalesValue.Text = cld.SalesValue
            Me.lbRiskCategory.Text = cld.RiskCategory

            If cld.Blocked Then
                Me.lbBlocked.Text = "Yes"
            Else
                Me.lbBlocked.Text = ""
            End If

            If cld.CreditLimitUsed > 1 Then
                Me.isBalanceExpired = True
                Me.lbPercentage.BackColor = Drawing.Color.Yellow
            End If
        End If

    End Sub


</script>

<div>

    <style type="text/css">
        .style1 {
            border-color: black;
            border-width: 1px;
            border-style: Solid;
            width: 90%;
            border-collapse: collapse;
            margin: 0 auto;
        }

        .style2 {
            border-color: black;
            border-width: 1px;
            border-style: Solid;
            width: 15%;
            border-collapse: collapse;
            background-color: #F85C12;
            color: white;
            font-size: 14px;
        }

        .style3 {
            border-color: black;
            border-width: 1px;
            border-style: Solid;
            width: 35%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .style4 {
            height:30px;
        }
    </style>

    <table class="style1">
        <tr class="style4">
            <th align="left" colspan="4" style="color: black; font-size: 18px;">Customer's Credit Info.</th>
        </tr>
        <tr class="style4">
            <td class="style2">ORG :
            </td>
            <td class="style3">
                <asp:Label ID="lbOrgID" runat="server" Text="" />
            </td>
            <td class="style2">ERP ID :
            </td>
            <td class="style3">
                <asp:Label ID="lbERPID" runat="server" Text="" />
            </td>
        </tr>
        <tr class="style4">
            <td class="style2">Credit Control Area :
            </td>
            <td class="style3">
                <asp:Label ID="lbCreditControlArea" runat="server" Text="" />
            </td>
            <td class="style2">Currency :
            </td>
            <td class="style3">
                <asp:Label ID="lbCurrency" runat="server" Text="" />
            </td>
        </tr>

        <tr class="style4">
            <td class="style2">Credit Limit :
            </td>
            <td class="style3">
                <asp:Label ID="lbCreditLimit" runat="server" Text="" />
            </td>
            <td class="style2">Credit Exposure :
            </td>
            <td class="style3">
                <asp:Label ID="lbCreditExposure" runat="server" Text="" />
            </td>
        </tr>
        <tr class="style4">
            <td class="style2">Credit limit used :
            </td>
            <td class="style3">
                <asp:Label ID="lbPercentage" runat="server" Text="" />
            </td>
            <td class="style2">Receivables :
            </td>
            <td class="style3">
                <asp:Label ID="lbReceivables" runat="server" Text="" />
            </td>
        </tr>
        <tr class="style4">
            <td class="style2">Special Liability :
            </td>
            <td class="style3">
                <asp:Label ID="lbSpecialLiability" runat="server" Text="" />
            </td>
            <td class="style2">Sales Value :
            </td>
            <td class="style3">
                <asp:Label ID="lbSalesValue" runat="server" Text="" />
            </td>
        </tr>
        <tr class="style4">
            <td class="style2">Risk Category :
            </td>
            <td class="style3">
                <asp:Label ID="lbRiskCategory" runat="server" Text="" />
            </td>
            <td class="style2">Blocked :
            </td>
            <td class="style3">
                <asp:Label ID="lbBlocked" runat="server" Text="" />
            </td>
        </tr>
    </table>

    <br />    
</div>
