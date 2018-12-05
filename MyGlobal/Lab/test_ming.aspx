<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">    

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Dim WiseOrderUtil1 As New WiseOrderUtil()
        Dim Input1 As New WiseOrderUtil.WISEPoint2OrderV2Input()
        With Input1
            .AssetId = "1-179N4BW"
            .MembershipEmail = "ivan@tanking.com.tw"
            .Qty = 1
            .RedeemPartNo = "WA-X80-U300E"
            .RedeemPoints = 36
            .WisePointOrderSONO = "0001166978"
        End With
        Dim Result1 = WiseOrderUtil1.WISEPoint2OrderV3(Input1)
    End Sub


</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    
</asp:Content>
