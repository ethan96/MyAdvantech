<%@ Page Title="" Language="C#" MasterPageFile="~/Includes/MyMaster.master" AutoEventWireup="true" CodeFile="IoTSummitReport.aspx.cs" Inherits="Lab_IoTSummitReport" %>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <%--<script type="text/javascript">
        function Download() {
            <%if (this.IsAdmin == true)
        {%>
            $.ajax({
                url: 'http://aclecampaign2.advantech.corp:9000/api/Report/Download',
                type: "GET",
                success: function () {
                },
                error: function () {
                }
            });
            <%}%>
            return false;
        }
    </script>--%>
    <asp:HyperLink ID="hlDownload" runat="server" Target="_self" NavigateUrl="http://aclecampaign2.advantech.corp:9000/api/Report/Download">
        <asp:Image ID="img1" runat="server" ImageUrl="~/My/AOnline/Images/download.png" />
    </asp:HyperLink>
</asp:Content>

