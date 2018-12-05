<%@ Page Title="Champion Club - Redemption Record" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">
    Dim MyDC As New MyChampionClubDataContext
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
            BindRtRecord()
        End If
    End Sub
    Private Sub BindRtRecord()
        Dim MyCR As List(Of ChampionClub_Reddem) = MyDC.ChampionClub_Reddems.Where(Function(P) P.CreateBy = Session("user_id").ToString).OrderByDescending(Function(P) P.CreateTime).ToList
        RtRecord.DataSource = MyCR
        RtRecord.DataBind()
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<link href="championclub.css" rel="stylesheet" type="text/css" />
    <link href="base.css" rel="stylesheet" type="text/css" />
<style type="text/css">
tbody tr.odd0 td{
	border-top:#ccc 1px solid;
    text-align: center;
	background: #fff;
	color: #333;
	height:25px;
	border-right:#ccc 1px solid;
}
tbody tr.odd1 td{
    text-align: center;
	background: #ebebeb;
	color: #333;
	height:25px;
	border-top:#ccc 1px solid;
	border-right:#ccc 1px solid;
}</style>
    <div id="cpclub-content-wrapper">
        <uc1:FunctionBlock runat="server" ID="ucFunctionBlock" />
        <div class="cpclub-content-main">
            <div class="main-intro">
                <div class="intro-heading">
                    Redemption Record</div>
                 <div class="prizePoint" style="padding-left:1px;">
                <ol>
                    <li>My Available Points:<span style="text-decoration: underline; color: #FF0000"> <%= MyChampionClubUtil.GetAvailablePoint(Session("user_id"))%></span>
                        Point</li>
                </ol>
            </div>
            </div>
            <div class="main-content">
          
                <div id="Opp_table">
                    <table width="100%">
                        <thead>
                            <tr>
                                <th width="5%" scope="col">
                                    #
                                </th>
                                <th width="15%" scope="col">
                                    Date
                                </th>
                                <th width="40%" scope="col">
                                    Prize Name
                                </th>
                                <th width="20%" scope="col">
                                    Point
                                </th>
                                <th width="20%" scope="col">
                                    Status
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                              <asp:Repeater ID="RtRecord" runat="server">
                <ItemTemplate>
                            <tr  class="odd<%# (Container.ItemIndex) mod 2 %>">
                                <td>
                                   <%# (Container.ItemIndex + 1)%>
                                </td>
                                <td>
                                     <%# CDate(Eval("CreateTime")).ToString("yyyy-MM-dd")%>
                                </td>
                                <td>
                                    <%# Eval("Prize_NameX")%>
                                </td>
                                <td>
                                   <%# Eval("Prize_PointX")%>
                                </td>
                                <td style="padding: 10px">
                            <%# Eval("StatusX")%>
                                </td>
                            </tr>
               </ItemTemplate>
            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
         
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cph1" Runat="Server">
</asp:Content>

