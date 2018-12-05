<%@ Page Title="MyAdvantech - Champion Club" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Import Namespace="System.IO" %>
<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
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
                srFile = New StreamReader(Server.MapPath("Txt/IntroductionInterCon.txt"), System.Text.Encoding.[Default])
            Else
                srFile = New StreamReader(Server.MapPath("Txt/Introduction" + Org + ".txt"), System.Text.Encoding.[Default])
            End If
            LitIntroduction.Text = srFile.ReadToEnd()
            If srFile IsNot Nothing Then
                srFile.Dispose()
                srFile.Close()
            End If
        End If
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
/* original css */
#container {
	width: 900px;
	margin: 0 auto;
}
/*----------------------------------------
  Heading
----------------------------------------*/
#cpclub-heading-wrapper {
	width: 890px;
	padding: 5px 0px 15px 10px;
}
/*  Breadcrumb
----------------------------------------*/
.cpclub-breadcrumb {
	height:15px;
	line-height: 15px;
	list-style:none;
}
.cpclub-breadcrumb li {
	display:inline;
}
.cpclub-breadcrumb li.lastCrumb {
	font-weight: bold;
}
.cpclub-breadcrumb li a {
	color: #333;
}
/*----------------------------------------
  Content
----------------------------------------*/
#cpclub-content-warpper {
	background: #FFF;
	margin-top: 20px;
	margin-bottom:10px;	
	width: 900px;
}
/*----------------------------------------
  Content Main
----------------------------------------*/
.cpclub-content-main {
	width: 618px;
	background-image: url(../../Images/contantbg.jpg);
	background-repeat: repeat-x;
	padding: 20px;
	border: 1px solid #d7d0d0;
	list-style-type: decimal;
	margin-top: 23px;
}
/*----------------------------------------
  Content
----------------------------------------*/
.cpclub-content-main .intro-heading {
	font-family:Arial, Helvetica, sans-serif;
	font-size:15px;
	color:#f29702;
	font-weight:bold;
	margin-bottom: 20px;
	}
.cpclub-content-main .main-intro p{
	margin-top: 15px;
	font-size: 12px;
	line-height: 18px;
}
.cpclub-content-main .main-content .content-heading{
	margin-top: 30px;
	font-size: 14px;
	padding-bottom: 5px;
	border-bottom: 1px solid #ccc;
	font-weight:bold;
	color: #8c8c8c;
}
.cpclub-content-main .main-content ul{
	margin-top: 15px;	
}
.cpclub-content-main .main-content ul li{
	margin-left: 20px;
	margin-bottom: 20px;
	list-style-type: decimal;
}
.cpclub-content-main .main-content2 .content-heading{
	margin-top: 30px;
	font-size: 14px;
	padding-bottom: 5px;
	border-bottom: 1px solid #ccc;
	font-weight:bold;
	color: #8c8c8c;
}
.cpclub-content-main .main-content2 ul{
	margin-top: 15px;	
}
.cpclub-content-main .main-content2 ul li{
	margin-left: 20px;
	margin-bottom: 20px;
	list-style-type: square;
}
.cpclub-content-main .main-content p{
	margin-top: 10px;
	line-height: 16px;	
}
/*----------------------------------------
  Table
----------------------------------------*/
#Opp_table{
	border-left-width:1px;
	border-bottom-width:1px;
	margin-top: 15px;
	border-top-width: 1px;
	border-top-style: solid;
	border-bottom-style: solid;
	border-left-style: solid;
	border-top-color: #d7d0d0;
	border-bottom-color: #d7d0d0;
	border-left-color: #d7d0d0;
}
thead tr th {
	background:#dcdcdc;
	padding:5px;
	text-align: center;
	color: #333;
	font-weight: bold;
	border-right:#ccc 1px solid;
}
tbody tr.odd1 td{
	border-top:#ccc 1px solid;
    text-align: center;
	background: #fff;
	color: #333;
	height:50px;
	border-right:#ccc 1px solid;
}
tbody tr.odd2 td{
    text-align: center;
	background: #ebebeb;
	color: #333;
	height:50px;
	border-top:#ccc 1px solid;
	border-right:#ccc 1px solid;
}
}
</style>
    <div id="container">
        <!-- end .cpclub-breadcrumb -->
        <table>
            <tr>
                <td valign="top">
                    <uc1:FunctionBlock runat="server" ID="ucFunctionBlock" />
                </td>
                <td>
                    <div class="cpclub-content-main">
                        <asp:Literal ID="LitIntroduction" runat="server"></asp:Literal>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>

