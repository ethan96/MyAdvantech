<%@ Page Title="MyAdvantech - Champion Club" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Import Namespace="System.IO" %>
<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
            'JJ 2014/4/16 Liliana/Adam那邊要求隱藏北美的Points Request
            Dim org As String = Session("org_id").ToString.Substring(0, 2)
            If AuthUtil.IsInterConUserV2() Then
                org = "InterCon"
            End If
        
            If org = "US" Then
                Me.Bt2Request.Visible = False
            End If
            
            Dim RBUStr As String = String.Empty
            Select Case Session("org_id").ToString.Substring(0, 2)
                Case "EU"
                    RBUStr = "ADL,AFR,AIT,AEE,ABN,AUK,DLOG,AINNOCORE,AEU,AMEA-MEDICAL"
                    'Case "ATW", "ACL", "AIN", "ASG", "AMY", "AID", "SAP", "AJP", "AKR", "HQDC", "ATH"
                    '    RBUStr = "TW01"
                Case "US"
                    RBUStr = "AENC,AACIAG,ANADMF,ABR,ANA,AAC,AMX,ALA"
                Case "CN"
                    RBUStr = "ABJ,ACN,ASH,ASZ,ACN-S,AHK,ACN-N,ACN-E,ACL,AHZ"
                    'Case "AAU"
                    '    ShowOrg = "AU01"
            End Select
            If AuthUtil.IsInterConUserV2() Then
                RBUStr = "HQDC,AJP,AIN,ARU,SAP,AKR,ATH"
            End If
            Dim MyDC As New MyChampionClubDataContext
            Dim MyCR As List(Of ChampionClub_PersonalInfo) = MyDC.ChampionClub_PersonalInfos.OrderByDescending(Function(P) P.CREATED_Date).ToList
        
            Dim CP As List(Of ChampionClub_PersonalInfo) =
                MyCR.Where(Function(p) RBUStr.Contains(p.ORG)).OrderByDescending(Function(p) p.TotalPointsX).ThenByDescending(Function(p) p.LatelyPointDateX).ToList().Take(10).ToList()
           
            Dim CP2 As List(Of ChampionClub_PersonalInfo) =
                MyCR.Where(Function(p) RBUStr.Contains(p.ORG)).OrderByDescending(Function(p) p.HistoryPointsX).ThenByDescending(Function(p) p.LatelyPointDateX).ToList.Take(10).ToList()
           
            CP2 = DirectCast(CP2, List(Of ChampionClub_PersonalInfo))
            For Each i As ChampionClub_PersonalInfo In CP
                Dim currentcp As ChampionClub_PersonalInfo = CP2.SingleOrDefault(Function(p) p.UserID = i.UserID)
                If currentcp Is Nothing Then
                    i.MovementX = 1
                Else
                    Dim Cindex As Integer = CP.FindIndex(Function(p) p.UserID = i.UserID)
                    Dim Hindex As Integer = CP2.FindIndex(Function(p) p.UserID = i.UserID)
                    If Cindex < Hindex Then
                        i.MovementX = 1
                    ElseIf Cindex = Hindex Then
                        i.MovementX = 0
                    Else
                        i.MovementX = -1
                    End If
                End If
            Next
            Rt1.DataSource = CP
            Rt1.DataBind()
        End If
    End Sub

    Protected Sub Bt2Request_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Response.Redirect("ReportsUpload.aspx")
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        /* original css */
        #container
        {
            width: 900px;
            margin: 0 auto;
        }
        /*----------------------------------------
  Heading
----------------------------------------*/
        #cpclub-heading-wrapper
        {
            width: 890px;
            padding: 5px 0px 15px 10px;
        }
        /*  Breadcrumb
----------------------------------------*/
        .cpclub-breadcrumb
        {
            height: 15px;
            line-height: 15px;
            list-style: none;
        }
        .cpclub-breadcrumb li
        {
            display: inline;
        }
        .cpclub-breadcrumb li.lastCrumb
        {
            font-weight: bold;
        }
        .cpclub-breadcrumb li a
        {
            color: #333;
        }
        /*----------------------------------------
  Content
----------------------------------------*/
        #cpclub-content-warpper
        {
            background: #FFF;
            margin-top: 20px;
            margin-bottom: 10px;
            width: 900px;
        }
        /*----------------------------------------
  Content Main
----------------------------------------*/
        .cpclub-content-main
        {
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
        .cpclub-content-main .intro-heading
        {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 15px;
            color: #f29702;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .cpclub-content-main .main-intro p
        {
            margin-top: 15px;
            font-size: 12px;
            line-height: 18px;
        }
        .cpclub-content-main .main-content .content-heading
        {
            margin-top: 30px;
            font-size: 14px;
            padding-bottom: 5px;
            border-bottom: 1px solid #ccc;
            font-weight: bold;
            color: #8c8c8c;
        }
        .cpclub-content-main .main-content ul
        {
            margin-top: 15px;
        }
        .cpclub-content-main .main-content ul li
        {
            margin-left: 20px;
            margin-bottom: 20px;
            list-style-type: decimal;
        }
        .cpclub-content-main .main-content2 .content-heading
        {
            margin-top: 30px;
            font-size: 14px;
            padding-bottom: 5px;
            border-bottom: 1px solid #ccc;
            font-weight: bold;
            color: #8c8c8c;
        }
        .cpclub-content-main .main-content2 ul
        {
            margin-top: 15px;
        }
        .cpclub-content-main .main-content2 ul li
        {
            margin-left: 20px;
            margin-bottom: 20px;
            list-style-type: square;
        }
        .cpclub-content-main .main-content p
        {
            margin-top: 10px;
            line-height: 16px;
        }
        /*----------------------------------------
  Table
----------------------------------------*/
        #Opp_table
        {
            border-left-width: 1px;
            border-bottom-width: 1px;
            margin-top: 15px;
            border-top-width: 1px;
            border-top-style: solid;
            border-bottom-style: solid;
            border-left-style: solid;
            border-top-color: #d7d0d0;
            border-bottom-color: #d7d0d0;
            border-left-color: #d7d0d0;
        }
        thead tr th
        {
            background: #dcdcdc;
            padding: 5px;
            text-align: center;
            color: #333;
            font-weight: bold;
            border-right: #ccc 1px solid;
        }
        tbody tr.odd1 td
        {
            border-top: #ccc 1px solid;
            text-align: center;
            background: #fff;
            color: #333;
            height: 50px;
            border-right: #ccc 1px solid;
        }
        tbody tr.odd2 td
        {
            text-align: center;
            background: #ebebeb;
            color: #333;
            height: 50px;
            border-top: #ccc 1px solid;
            border-right: #ccc 1px solid;
        }
        /*----------------------------------------
  Ranking List
----------------------------------------*/
        .rank_list
        {
            display: block;
            padding: 10px 50px 20px 50px;
            margin-bottom: 0px;
        }
        
        .cpclub-rank-title
        {
            height: 52px;
            line-height: 60px;
            background-image: url(img/icon_crown.gif);
            background-position: left bottom;
            background-repeat: no-repeat;
            color: #BC6600;
            font-size: 18px;
            font-weight: bold;
            padding-left: 95px;
        }
        
        .cpclub-repeat-head
        {
            display: block;
            background-color: #ffdea7;
            margin-bottom: 3px;
            height: 30px;
            line-height: 30px;
            color: #9f4200;
            font-weight: bold;
            font-size: 15px;
        }
        
        .cpclub-head-number
        {
            width: 10%;
            display: block;
            float: left;
            text-align: center;
            padding-left: 5%;
        }
        .cpclub-head-arrow
        {
            width: 16%;
            display: block;
            float: left;
            text-align: center;
            padding-left: 4%;
        }
        .cpclub-head-name
        {
            width: 28%;
            display: block;
            float: left;
            text-align: left;
            padding-left: 7%;
        }
        .cpclub-head-pointnum
        {
            width: 30%;
            display: block;
            float: left;
            text-align: center;
        }
        
        
        .cpclub-repeat-odd
        {
            display: block;
            background-color: #fff;
            margin-bottom: 3px;
            height: 30px;
            line-height: 30px;
            font-size: 14px;
        }
        .cpclub-repeat-even
        {
            display: block;
            background-color: #fff6ef;
            height: 30px;
            line-height: 30px;
            margin-bottom: 3px;
            font-size: 14px;
        }
        .cpclub-rank10-number
        {
            width: 10%;
            display: block;
            float: left;
            text-align: center;
            font-weight: bold;
            padding-left: 5%;
        }
        
        .rank_topthree
        {
            font-size: 16px;
            color: #CC0000;
        }
        
        
        .cpclub-rank10-arrow
        {
            width: 16%;
            display: block;
            float: left;
            text-align: center;
            padding-left: 4%;
        }
        .cpclub-rank10-name
        {
            width: 28%;
            display: block;
            float: left;
            padding-left: 7%;
        }
        .cpclub-rank10-pointnum
        {
            width: 30%;
            display: block;
            float: left;
            text-align: center;
            color: #6a61b2;
        }
        .sure_point
        {
            padding: 0px 5px;
            height: 24px;
            border: 0;
            float: right;
            color: #FFF;
            font-weight: bold;
            background: url(img/button.gif) repeat;
            cursor: pointer;
            margin-right: 50px;
            margin-bottom: 15px;
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
                        <div class="main-intro">
                            <div class="intro-heading">
                                Ranking List</div>
                            <!-- end .main-intro -->
                        </div>
                        <div class="main-content">
                        <div style="line-height: 20px; color: #FF0000">*The rankling list will update at the conclusion of every quarter when sales figures are collected and points have been entered into the system.</div>
                            <div class="rank_list">
                                <div class="cpclub-rank-title">
                                    Champion Club Ranking List</div>
                                <div class="cpclub-repeat-head clearfix">
                                    <div class="cpclub-head-number">
                                        Rank</div>
                                          <div class="cpclub-head-arrow">Movement</div>
                                    <div class="cpclub-head-name">
                                        Participant Name</div>
                                    <div class="cpclub-head-pointnum">
                                        Current Points</div>
                                </div>
                                <%--<h2 style="color:tomato; font-size:14px;  margin-top:30px; margin-bottom:20px;">2014 Ranking List will be renewed and released from the beginning of Q2.</h2>--%>
                                <asp:Repeater ID="Rt1" runat="server">
                                    <ItemTemplate>
                                        <div class="cpclub-repeat-odd clearfix">
                                            <div class="cpclub-rank10-number">
                                                <span class="<%# iif(Container.ItemIndex<3,"rank_topthree","") %>">No.
                                                    <%# Container.ItemIndex+1%></span></div>
                                             <div class="cpclub-rank10-arrow">
                                            <img src="img/<%# Eval("MovementX")%>.gif"  width="30" height="30" align="middle" />
                                            </div>
                                            <div class="cpclub-rank10-name">
                                                <%# Eval("FirstName")%>
                                                <%# Eval("LastName")%></div>
                                            <div class="cpclub-rank10-pointnum">
                                                <%# Eval("TotalPointsX")%></div>
                                        </div>
                                    </ItemTemplate>
                                    <AlternatingItemTemplate>
                                        <div class="cpclub-repeat-even clearfix">
                                            <div class="cpclub-rank10-number">
                                                <span class="<%# iif(Container.ItemIndex<3,"rank_topthree","") %>">No.
                                                    <%# Container.ItemIndex+1%></span></div>
                                              <div class="cpclub-rank10-arrow"><img src="img/<%# Eval("MovementX")%>.gif"  width="30" height="30" /></div>
                                            <div class="cpclub-rank10-name">
                                                <%# Eval("FirstName")%>
                                                <%# Eval("LastName")%></div>
                                            <div class="cpclub-rank10-pointnum">
                                                <%# Eval("TotalPointsX")%></div>
                                        </div>
                                    </AlternatingItemTemplate>
                                </asp:Repeater>
                            </div>
                        </div>
                        <asp:Button ID="Bt2Request" runat="server" Text="Go to Points Request" CssClass="sure_point"
                            OnClick="Bt2Request_Click" />
                        <div style="clear: both;">
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
