<%@ Page Title="" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    Dim serializer As New Script.Serialization.JavaScriptSerializer()
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
       
        gv1.DataSource = eQuotationUtil.GetQuoteMasterByCompanyid("EIITHA04", "")
        gv1.DataBind()
    End Sub

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">       
    <asp:GridView runat="server" ID="gv1" />
</asp:Content>
