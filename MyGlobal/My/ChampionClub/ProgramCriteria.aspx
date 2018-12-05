<%@ Page Title="Champion Club - Region Program Criteria" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.IO" %>

<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
            Dim srFile As StreamReader = Nothing
            Dim Org As String = "EU"
            If Session("org_id").ToString.StartsWith("US") Then
                Org = "US"
            End If
            If Session("org_id").ToString.StartsWith("CN") Then
                Org = "CN"
            End If
            If AuthUtil.IsInterConUserV2() Then
                srFile = New StreamReader(Server.MapPath("Txt/CriteriaInterCon.txt"), System.Text.Encoding.[Default])
            Else
                srFile = New StreamReader(Server.MapPath("Txt/Criteria" + Org + ".txt"), System.Text.Encoding.[Default])
            End If
            LitCriteria.Text = srFile.ReadToEnd()
            If srFile IsNot Nothing Then
                srFile.Dispose()
                srFile.Close()
            End If
        End If
    End Sub   
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link href="championclub.css" rel="stylesheet" type="text/css" />
    <link href="base.css" rel="stylesheet" type="text/css" />
    <div id="cpclub-content-wrapper">
        <uc1:FunctionBlock runat="server" ID="ucFunctionBlock" />
        <div class="cpclub-content-main">
            <asp:Literal ID="LitCriteria" runat="server"></asp:Literal>
        </div>
    </div>
</asp:Content>
