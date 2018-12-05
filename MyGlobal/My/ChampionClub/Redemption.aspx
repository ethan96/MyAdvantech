<%@ Page Title="Champion Club - Point Redemption" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">
    Dim AACimg As String = String.Empty
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
            If Session("org_id").ToString.StartsWith("CN") Then
                Lithead.Text = "心动大奖" : LitMAP.Text = "我的当前积分"
            End If
            BindRtpRize()
        End If
    End Sub
    Dim MyDC As New MyChampionClubDataContext
    Private Sub BindRtpRize()
        Dim org As String = Session("org_id").ToString.Substring(0, 2)
        If AuthUtil.IsInterConUserV2() Then
            org = "InterCon"
        End If
        
        'JJ 2014/4/8：因為Liliana有修改北美的遊戲規則，所以北美就導到另外一個頁面
        If org = "US" Then
            Response.Redirect("Redemption_US.aspx")
        End If
        
        Dim MyCR As List(Of ChampionClub_Prize) = MyDC.ChampionClub_Prizes.Where(Function(P) P.ORG = org).OrderBy(Function(P) P.Prize_Level).ToList
        RtpRize.DataSource = MyCR
        RtpRize.DataBind()
    End Sub
    Protected Sub LinkButtonPrize_Click(sender As Object, e As System.EventArgs)
        Dim BT As LinkButton = CType(sender, LinkButton)
        Dim ID As String = BT.CommandArgument
        Dim Prize As ChampionClub_Prize = MyDC.ChampionClub_Prizes.Where(Function(p) p.ID = ID).FirstOrDefault
        If Prize IsNot Nothing Then
            If (Integer.Parse(MyChampionClubUtil.GetAvailablePoint(Session("user_id"))) - Integer.Parse(Prize.Points)) < 0 Then
                Util.JSAlert(Me.Page, "You do not have enough points")
                Exit Sub
            End If
            Dim Reddem As New ChampionClub_Reddem
            Reddem.ReddemID = Replace(System.Guid.NewGuid().ToString().ToUpper(), "-", "")
            Reddem.PrizeID = Integer.Parse(ID)
            Reddem.Status = 0
            Reddem.CreateBy = Session("USER_ID").ToString
            Reddem.CreateTime = Now
            MyDC.ChampionClub_Reddems.InsertOnSubmit(Reddem)
            MyDC.SubmitChanges()
            MyChampionClubUtil.SendEmail(Session("user_id").ToString, 3, "", Reddem.ReddemID)
            Response.Redirect("PointManagement.aspx")
        End If
      
    End Sub

    Protected Sub RtpRize_ItemDataBound(sender As Object, e As System.Web.UI.WebControls.RepeaterItemEventArgs)
        If e.Item.ItemType = ListItemType.Item OrElse e.Item.ItemType = ListItemType.AlternatingItem Then
            If Session("org_id").ToString.StartsWith("CN") Then
                Dim lb As LinkButton = CType(e.Item.FindControl("LinkButtonPrize"), LinkButton)
                lb.Text = "兑换"
                Dim lip As HtmlControl = CType(e.Item.FindControl("lip"), HtmlControl)
                lip.Visible = False
                Dim libt As HtmlControl = CType(e.Item.FindControl("libt"), HtmlControl)
                libt.Visible = False
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
            <div class="intro-heading">
                <span class="intro-title">
                    <asp:Literal ID="Lithead" runat="server" Text="Prize Redemption"/></span></div>
            <!-- end .main-intro -->
                 <div class="prizePoint">
                <ol>
                    <li><asp:Literal ID="LitMAP" runat="server" Text="My Current Points"/>:<span style="text-decoration: underline; color: #FF0000"> <%= MyChampionClubUtil.GetAvailablePoint(Session("user_id"))%></span>
                        </li>
                </ol>
            </div>
            <div class="prize-select">
                <ol>

                   <asp:Repeater ID="RtpRize" runat="server" OnItemDataBound="RtpRize_ItemDataBound">
                <ItemTemplate>
                    <li>
                        <ul class="prize-list">
                            <li class="prizeListImg">
                                <input id="company" type="radio" name="company" value="" />
                                <img src="<%# Eval("PicUrl")%>" width="160" height="160" /></li>
                            <li class="prizeListCon">
                                <ul>
                                    <li><b><%# Eval("Prize_Level_Name")%></b></li>
                                    <li class="title01"><%# Eval("NAME")%></li>
                                    <%--<li class="rating-star"></li>--%>
                                    <li class="title02"  runat="server" id="lip" ><%# Eval("Points")%> Points</li>
                                    <li class="text">
                                     <%# Eval("Description")%> 
                                        </li>
                                    <li class="prizeButton" runat="server" id="libt">
                                        <asp:LinkButton ID="LinkButtonPrize" runat="server" CommandArgument='<%# Eval("ID")%>'  OnClick="LinkButtonPrize_Click">Redeem</asp:LinkButton>

                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </li>
            </ItemTemplate>
            </asp:Repeater>
    
           
                </ol>
            </div>
       
        </div>
        <!-- end #of-faq -->
    </div>
</asp:Content>
