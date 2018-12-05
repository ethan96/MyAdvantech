<%@ Page Title="Champion Club - Point Redemption" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ Register TagName="FunctionBlock" TagPrefix="uc1" Src="~/My/ChampionClub/FunctionBlock.ascx" %>
<script runat="server">
    Dim AACimg As String = String.Empty
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Util.IsPCPUser() AndAlso Not Util.IsAEUIT() Then Response.Redirect("~/home.aspx")
        'If Not Util.IsPCP_Marcom(Session("user_id").ToString, "") AndAlso Not Util.IsAEUIT() AndAlso Not Util.IsAdminUser() Then Response.Redirect("~/home.aspx")
        If Not IsPostBack Then
          
        End If
    End Sub
    Dim MyDC As New MyChampionClubDataContext
   
    Protected Sub LinkButtonPrize_Click(sender As Object, e As System.EventArgs)
        Dim BT As LinkButton = CType(sender, LinkButton)
        Dim ID As String = BT.CommandName
        Dim Points As String = BT.CommandArgument
        'Dim Prize As ChampionClub_Prize = MyDC.ChampionClub_Prizes.Where(Function(p) p.ID = ID).FirstOrDefault
        
        If (Integer.Parse(MyChampionClubUtil.GetAvailablePoint(Session("user_id"))) - Integer.Parse(Points)) < 0 Then
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
       
      
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link href="championclub.css" rel="stylesheet" type="text/css" />
    <link href="base.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .prizeListCon{
	width: 590px;
	float: left;
    }
       
    </style>
    <div id="cpclub-content-wrapper">
        <uc1:FunctionBlock runat="server" ID="ucFunctionBlock" />
        <div class="cpclub-content-main">
            <div class="intro-heading">
                <span class="intro-title">
                    <asp:Literal ID="Lithead" runat="server" Text="Prize Redemption"/>
                </span>
            </div>
            <div>
             <span class="intro-title">Winners may select any product from any included brand at the prize level value reached. Please select and redeem the prize value(s) of your choosing. Once your redemption request is received, Adam Sturm will contact you to complete the process and place the order for your desired products. Example – 100 points may be redeemed for a $200 item from Apple, Coach, North Face, or Swiss Army.<br /> &nbsp;</span></div>
            <!-- end .main-intro -->
                 <div class="prizePoint">
                <ol>
                    <li><asp:Literal ID="LitMAP" runat="server" Text="My Current Points"/>:<span style="text-decoration: underline; color: #FF0000"> <%= MyChampionClubUtil.GetAvailablePoint(Session("user_id"))%></span>
                        </li>
                </ol>
            </div>
            <div class="prize-select">
               <ol>
                    <ul class="prize-list">
                            <li  style="float: left;width:130px;">
                                <img src="img/apple.jpg" width="90%" height="120" />
                            </li>
                             <li style="float: left;width:130px;">
                                <img src="img/coach.jpg" width="90%" height="120" />
                            </li>
                             <li style="float: left;width:130px;">
                                <img src="img/THE_NORTH_FACE.jpg" width="90%" height="120" />
                            </li>
                             <li style="float: left;width:130px;">
                                <img src="img/VICTORINOX.jpg" width="90%" height="120" />
                            </li>
                    </ul>
               </ol>
                <ol>
                     <ul class="prize-list">
                        <li class="prizeListCon">
                          <ul>
                          <li  style="float: left;width:45%;">
                               <ul>
                                    <li><b>LEVEL 1</b></li>
                                    <li class="title02"  runat="server" id="lip" style="color: #000000" >$200 prize(100 points required)</li>
                                    <li class="text">
                                     $200 item of your choice from the brands above 
                                        </li>
                                    <li class="prizeButton" runat="server" id="libt">
                                        <asp:LinkButton ID="LinkButton1"  runat="server" CommandArgument='100'  
                                            OnClick="LinkButtonPrize_Click" CommandName="26">Redeem</asp:LinkButton>
                                    </li>
                                </ul>
                                <hr />
                                 <ul>
                                    <li><b>LEVEL 2</b></li>
                                    <li class="title02"  runat="server" id="li3" style="color: #000000" >$400 prize(200 points required)</li>
                                    <li class="text">
                                     $400 item of your choice from the brands above 
                                        </li>
                                    <li class="prizeButton" runat="server" id="li4">
                                        <asp:LinkButton ID="LinkButton2"  runat="server" CommandArgument='200'  
                                            OnClick="LinkButtonPrize_Click" CommandName="27">Redeem</asp:LinkButton>
                                    </li>
                                </ul>
                          </li>
                          <li  style="float: left;width:45%;">
                                <ul>
                                    <li><b>LEVEL 3</b></li>
                                    <li class="title02"  runat="server" id="li1" style="color: #000000" >$600 prize(300 points required)</li>
                                    <li class="text">
                                     $600 item of your choice from the brands above 
                                        </li>
                                    <li class="prizeButton" runat="server" id="li2">
                                        <asp:LinkButton ID="LinkButton3"  runat="server" CommandArgument='300'  
                                            OnClick="LinkButtonPrize_Click" CommandName="28">Redeem</asp:LinkButton>
                                    </li>
                                </ul>
                                 <hr />
                                <ul>
                                    <li><b>LEVEL 4</b></li>
                                    <li class="title02"  runat="server" id="li5" style="color: #000000" >$800 prize(400 points required)</li>
                                    <li class="text">
                                     $800 item of your choice from the brands above 
                                        </li>
                                    <li class="prizeButton" runat="server" id="li6">
                                        <asp:LinkButton ID="LinkButton4"  runat="server" CommandArgument='400'  
                                            OnClick="LinkButtonPrize_Click" CommandName="29">Redeem</asp:LinkButton>
                                    </li>
                                </ul>
                            </li>
                          </ul>
                        </li>
                     </ul>
                   
    
           
                </ol>
            </div>
       
        </div>
        <!-- end #of-faq -->
    </div>
</asp:Content>
