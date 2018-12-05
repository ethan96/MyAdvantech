<%@ Page Title="MyAdvantech - Intel Portal Login Check" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If IntelPortal.IsIntelUser() Then
                Response.Redirect("home.aspx")
            Else
                
            End If
        End If
    End Sub

    Protected Sub btnRequest_Click(sender As Object, e As System.EventArgs)

    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
        Click to Send authentication Email:&nbsp;<asp:Button runat="server" ID="btnRequest" OnClick="btnRequest_Click" Text="Click" />
</asp:Content>