<%@ Control Language="VB" ClassName="GAFooter" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'TimerContent.Enabled = True
            If HttpContext.Current.User.Identity.Name IsNot Nothing AndAlso HttpContext.Current.User.Identity.Name <> "" Then tdCIS.Visible = True
        End If
    End Sub
    
    Public Function RuntimeSiteUrl() As String
        Dim url As String = ""
        Dim sdatetime As String = ""
        Dim clientIP As String = ""
        '取得client IP
        clientIP = Util.GetClientIP()
        
        '加入cache機制：時間設在cache住10分鐘
        If Cache(clientIP) IsNot Nothing AndAlso Cache(clientIP) <> "" Then
            url = CStr(Cache(clientIP))
        Else
            Cache.Insert(clientIP, Util.GetRuntimeSiteUrl(), Nothing, DateTime.Now.AddMinutes(10), Cache.NoSlidingExpiration)
            url = CStr(Cache(clientIP))
        End If
        
        Return url
    End Function
    
    
    'Protected Sub TimerContent_Tick(ByVal sender As Object, ByVal e As System.EventArgs)
    '    Try
    '        Dim toll_num As String = Util.GetTollNumber()
    '        lblPhone.Text = toll_num
            
    '    Catch ex As Exception
    '        lblPhone.Text = "1-888-576-9668"
    '        Util.InsertMyErrLog(ex.ToString)
    '    End Try
    '    TimerContent.Enabled = False
    'End Sub
  </script>
  <script type="text/javascript" src='./EC/Includes/jquery-latest.min.js'></script>
    <script type="text/javascript">
        $(function () {
            var sUrl = "<%=RuntimeSiteUrl()%>" + "/Services/InternalWebService.asmx/GetTollNumber";
            $.ajax({
                type: "POST",
                url: sUrl,
                //url: "http://localhost:23306/MyGlobal/Services/InternalWebService.asmx/GetTollNumber",
                contentType: "application/json; charset=utf-8",
                data: "{}",
                dataType: 'json',
                success: function (result) {

                    try {
                        $('#lblPhone').text(result.d);
                    }
                    catch (e) {
                        //alert(e);
                        return;
                    }
                },
                error: function (result, status, mag) {
                    //alert(mag);

                }
            });
        });
    </script>
<style type="text/css">
    .iplanet_online_order {
	    FLOAT: right; COLOR: #666
    }
    .iplanet_online_content {
	    CLEAR: both
    }
    .iplanet_online_main {
	    FLOAT: left; WIDTH: 698px
    }
    .iplanet_online_product_table {
	    BORDER-RIGHT: #c7c7c7 1px solid; BORDER-TOP: #c7c7c7 1px; BORDER-LEFT: #c7c7c7 1px solid; BORDER-BOTTOM: #c7c7c7 1px solid
    }
    .iplanet_online_product_table TD {
	    FONT-SIZE: 100%; VERTICAL-ALIGN: top
    }
    .iplanet_online_product_title {
	    BORDER-RIGHT: #c7c7c7 1px solid; BORDER-TOP: #c7c7c7 1px solid; MARGIN-TOP: 12px; FONT-WEIGHT: bold; FONT-SIZE: 125%; BORDER-LEFT: #c7c7c7 1px solid; LINE-HEIGHT: normal; BORDER-BOTTOM: #c7c7c7 1px; BACKGROUND-COLOR: #e3f4fe
    }
    .iplanet_online_product_title TD {
	    VERTICAL-ALIGN: top
    }
    .iplanet_online_fontstyledescription UL {
	    PADDING-RIGHT: 10px; PADDING-LEFT: 10px; LIST-STYLE-POSITION: inside; PADDING-BOTTOM: 10px; PADDING-TOP: 10px
    }
    .iplanet_online_product_new {
	    BORDER-RIGHT: #c7c7c7 1px solid; PADDING-RIGHT: 10px; BORDER-TOP: #c7c7c7 1px solid; MARGIN-TOP: 12px; PADDING-LEFT: 10px; BACKGROUND-IMAGE: url(new_product_title.jpg); PADDING-BOTTOM: 5px; BORDER-LEFT: #c7c7c7 1px solid; PADDING-TOP: 40px; BORDER-BOTTOM: #c7c7c7 1px solid; BACKGROUND-REPEAT: no-repeat; HEIGHT: 200px
    }
    .iplanet_online_product_new LI {
	
    }
    .iplanet_online_product_Other {
	    CLEAR: both; BORDER-RIGHT: #c7c7c7 1px solid; BORDER-TOP: #c7c7c7 1px solid; MARGIN-TOP: 12px; BORDER-LEFT: #c7c7c7 1px solid; BORDER-BOTTOM: #c7c7c7 1px solid; BACKGROUND-REPEAT: no-repeat; BACKGROUND-COLOR: #ebebeb
    }
    .iplanet_online_product_Other UL {
	    PADDING-RIGHT: 0px; PADDING-LEFT: 0px; FONT-SIZE: 100%; PADDING-BOTTOM: 0px; MARGIN: 5px 0px 0px; COLOR: #666; PADDING-TOP: 0px; LIST-STYLE-TYPE: none
    }
    .iplanet_online_product_help02 {
	    BORDER-RIGHT: #c7c7c7 1px solid; FLOAT: left; MARGIN: 0px 10px; WIDTH: 190px
    }
    .iplanet_online_product_service {
	    PADDING-RIGHT: 10px; PADDING-LEFT: 14px; FLOAT: left; PADDING-BOTTOM: 15px; WIDTH: 130px; PADDING-TOP: 10px
    }
    .iplanet_online_product_service LI {
	
    }
    .iplanet_online_product_help01 {
	    MARGIN-TOP: 12px; PADDING-LEFT: 3px; BACKGROUND-IMAGE: url(get_live_help_bg01.jpg); WIDTH: 177px; PADDING-TOP: 73px; BACKGROUND-REPEAT: no-repeat; HEIGHT: 30px
    }
    .iplanet_online_right_style01 {
	    BORDER-RIGHT: #c7c7c7 1px solid; PADDING-RIGHT: 10px; BORDER-TOP: #c7c7c7 1px solid; MARGIN-TOP: 12px; PADDING-LEFT: 10px; PADDING-BOTTOM: 10px; BORDER-LEFT: #c7c7c7 1px solid; WIDTH: 158px; PADDING-TOP: 5px; BORDER-BOTTOM: #c7c7c7 1px solid; HEIGHT: auto; BACKGROUND-COLOR: #f4f4f4
    }
    .iplanet_online_right_style01 UL {
	    PADDING-RIGHT: 0px; PADDING-LEFT: 0px; FONT-SIZE: 100%; LIST-STYLE-IMAGE: url(arrow.gif); PADDING-BOTTOM: 0px; MARGIN: 5px 0px 0px 12px; COLOR: #666; PADDING-TOP: 0px
    }
    .iplanet_online_right_style01 LI {
	    MARGIN-TOP: 5px
    }
    .iplanet_online_footer {
	    CLEAR: both
    }
    .iplanet_online_fontstyle01 {
	    FONT-WEIGHT: bold; FONT-SIZE: 120%; COLOR: #f39700
    }
    .iplanet_online_fontstyle02 {
	    HEIGHT: 65px
    }
    .iplanet_online_fontstyle03 {
	    FONT-WEIGHT: bold; MARGIN-LEFT: 5px
    }
    .iplanet_online_fontstyle04 {
	    FONT-SIZE: 90%; MARGIN: 5px 0px 0px 5px; COLOR: #666
    }
    .iplanet_online_imgstyle01 {
	    VERTICAL-ALIGN: top; HEIGHT: 70px
    }
    .iplanet_online_right_style02 {
	    BORDER-RIGHT: #c7c7c7 1px solid; PADDING-RIGHT: 10px; BORDER-TOP: #c7c7c7 1px solid; MARGIN-TOP: 12px; PADDING-LEFT: 10px; PADDING-BOTTOM: 10px; BORDER-LEFT: #c7c7c7 1px solid; WIDTH: 158px; PADDING-TOP: 5px; BORDER-BOTTOM: #c7c7c7 1px solid; HEIGHT: auto; BACKGROUND-COLOR: #f4f4f4
    }
    .iplanet_online_right_style02 TABLE {
	    MARGIN-TOP: 10px
    }
    .iplanet_online_right_style02 IMG {
	    BORDER-RIGHT: #c7c7c7 1px solid; BORDER-TOP: #c7c7c7 1px solid; BORDER-LEFT: #c7c7c7 1px solid; BORDER-BOTTOM: #c7c7c7 1px solid
    }
    .iplanet_online_right_style02 TD {
	    VERTICAL-ALIGN: top
    }
    .at-expert-box {
	    BORDER-RIGHT: #d7d7d7 1px solid; BORDER-TOP: #d7d7d7 1px solid; BACKGROUND: #fff; BORDER-LEFT: #d7d7d7 1px solid; COLOR: #666; BORDER-BOTTOM: #d7d7d7 1px solid
    }
    .iplanet_online_call_title {
	    PADDING-RIGHT: 10px; PADDING-LEFT: 10px; FONT-SIZE: 10px; PADDING-BOTTOM: 10px; LINE-HEIGHT: 12px; PADDING-TOP: 10px; -webkit-text-size-adjust: none
    }
    .iplanet_online_call {
	    PADDING-RIGHT: 0px; PADDING-LEFT: 25px; FONT-WEIGHT: bold; FONT-SIZE: 12px; PADDING-BOTTOM: 0px; LINE-HEIGHT: 16px; PADDING-TOP: 0px; HEIGHT: 30px
    }
    .iplanet_online_chat {
	    PADDING-RIGHT: 0px; PADDING-LEFT: 20px; FONT-WEIGHT: bold; FONT-SIZE: 12px; BACKGROUND: url(../images/chat_bg.jpg) no-repeat; PADDING-BOTTOM: 0px; LINE-HEIGHT: 16px; PADDING-TOP: 18px; HEIGHT: 76px
    }
    .iplanet_online_call02 {
	    MARGIN-TOP: 8px; FONT-WEIGHT: normal; FONT-SIZE: 11px; MARGIN-LEFT: -10px
    }
</style>
<div class="iplanet_online_product_Other">
    <table cellpadding="0" cellspacing="0">
        <tr>
            <td width="10"></td>
            <td valign="top">
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td valign="top" width="190" style="border:#c7c7c7 1px solid; background-color:White">
                            <div class="iplanet_online_call">
                                <table border="0" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <img id="eStoreFooter_Image1" src="../images/call_icon.jpg" />
                                        </td>
                                        <td width="5">
                                        </td>
                                        <td>
                                            <font color="#666666">Call Advantech</font><br />
                                            <span style="color: #3399FF;">
                                             <%--   <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                                                    <ContentTemplate>
                                                        <asp:Timer runat="server" ID="TimerContent" Interval="200" OnTick="TimerContent_Tick" />--%>
                                                        <asp:Label runat="server" ID="lblPhone" ClientIDMode="Static" />
                                                <%--      </ContentTemplate>
                                                </asp:UpdatePanel>--%>
                                            </span>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="iplanet_online_chat">
                                <font color="#666666">Ask an Expert</font>
                                <table border="0" cellpadding="0" cellspacing="0" class="iplanet_online_call02">
                                    <tr>
                                        <td>
                                            <img id="eStoreFooter_Image2" src="../images/chat_icon.jpg" />
                                        </td>
                                        <td width="5">
                                        </td>
                                        <td>
                                            <a href="https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToChat&amp;site=68676965&amp;byhref=1&amp;SESSIONVAR!skill=&amp;imageUrl=https://buy.advantech.com/images/AUS/livechat/&#39; target=&#39;chat68676965&#39; " id="_lpChatBtn" onclick="lpButtonCTTUrl = &#39;https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToChat&amp;site=68676965&amp;SESSIONVAR!skill=&amp;imageUrl=https://buy.advantech.com/images/AUS/livechat/&amp;referrer=&#39;+escape(document.location); lpButtonCTTUrl = (typeof(lpAppendVisitorCookies) != &#39;undefined&#39; ? lpAppendVisitorCookies(lpButtonCTTUrl) : lpButtonCTTUrl); window.open(lpButtonCTTUrl,&#39;chat68676965&#39;,&#39;width=475,height=400,resizable=yes&#39;);return false;"><font color="#4D79BB">Chat Online Now</font></a>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3" height="2">
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <img id="eStoreFooter_Image3" src="../images/call_icon_02.jpg" />
                                        </td>
                                        <td width="5">
                                        </td>
                                        <td>
                                            <a href="https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToTalk&amp;site=68676965&amp;SESSIONVAR!skill=Voice PBX&amp;onlineURL=https://server.iad.liveperson.net/hcp/voice/forms/precall.asp?site=68676965%26identifier=1&amp;ResponseURL=https://server.iad.liveperson.net/hcp/voice/forms/callStatus.asp&amp;byhref=1&amp;imageUrl=https://buy.advantech.com/images/AUS/livetalk/&#39; target=&#39;call68676965&#39;" id="_lpLiveCallBtn" onclick="javascript:window.open(&#39;https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToTalk&amp;site=68676965&amp;SESSIONVAR!skill=Voice PBX&amp;onlineURL=https://server.iad.liveperson.net/hcp/voice/forms/precall.asp?site=68676965%26identifier=1%26ResponseURL=https://server.iad.liveperson.net/hcp/voice/forms/callStatus.asp&amp;imageUrl=https://buy.advantech.com/images/AUS/livetalk/&amp;referrer=&#39;+escape(document.location),&#39;call68676965&#39;,&#39;width=475,height=420&#39;);return false;"><font color="#4D79BB">Request Call Back</font></a>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
            <td>
                <div class="iplanet_online_product_service">
                    <ul>
                        <li><b><font color="Black">Customer Service</font></b></li>
                    </ul>
                    <ul style="width:150px">
                        <li><a href="http://buy.advantech.com/information.aspx?type=ProductEvaluation"><font color="#4D79BB">Evaluation Program</font></a></li>
                        <li><a href="http://buy.advantech.com/resource/aus/terms_and_conditions_aus.pdf"><font color="#4D79BB">Terms
                            and Conditions</font></a></li>
                        <li><a href="http://buy.advantech.com/information.aspx?type=WarrantyPolicy"><font color="#4D79BB">Warranty
                            Policy</font></a></li>
                        <li><a href="http://buy.advantech.com/information.aspx?type=EstablishAccount"><font color="#4D79BB">Net Term
                            Application</font></a></li>
                        <li><a href="http://buy.advantech.com/information.aspx?type=ReturnPolicy"><font color="#4D79BB">Return Policy</font></a></li>
                        <li><a href="http://support.advantech.com.tw/support/default.aspx"><font color="#4D79BB">Download Center</font></a></li>
                    </ul>
                </div>
            </td>
            <td>
                <div class="iplanet_online_product_service">
                    <ul>
                        <li><font color="Black"><b>Order Information</b></font></li>
                    </ul>
                    <ul>
                        <li><a href="http://buy.advantech.com/Cart/myorders.aspx"><font color="#4D79BB">My Order</font></a></li>
                        <li><a href="http://buy.advantech.com/Quotation/myquotation.aspx"><font color="#4D79BB">My Quote</font></a></li>
                        <li><a href="http://buy.advantech.com/Cart/Cart.aspx"><font color="#4D79BB">View Cart</font></a></li>
                        <li><a href="http://buy.advantech.com/Compare.aspx"><font color="#4D79BB">Compare List</font></a></li>
                        <li><a href="http://buy.advantech.com/Product/OrderbyPartNO.aspx"><font color="#4D79BB">Order by Part Number</font></a></li>
                    </ul>
                </div>
            </td>
            <td>
                <div class="iplanet_online_product_service">
                    <ul>
                        <li><font color="Black"><b>Get Involved</b></font></li>
                    </ul>
                    <ul>
                        <li><a href="http://buy.advantech.com/ContactUS.aspx?tabs=general-inquiries"><font color="#4D79BB">Share Your Ideas</font></a></li>
                        <li><a href="http://forum.adamcommunity.com/index.php"><font color="#4D79BB">Community</font></a></li>
                    </ul>
                </div>
            </td>
            <td runat="server" id="tdCIS" visible="false">
                <div class="iplanet_online_product_service">
                    <ul>
                        <li><font color="Black"><b>Material CIS</b></font></li>
                    </ul>
                    <ul>
                        <li><asp:HyperLink runat="server" ID="hl1" NavigateUrl="~/Product/CIS/How to use Material-CIS.pdf" Text="How to use" ForeColor="#4D79BB" /></li>
                        <li><asp:HyperLink runat="server" ID="hl2" NavigateUrl="~/Product/CIS/CIS_QUERY.aspx" ForeColor="#4D79BB" Text="CIS Home" /></li>
                        <li><asp:HyperLink runat="server" ID="hl3" NavigateUrl="~/Product/CIS/CIS_TEMPLATE.aspx" ForeColor="#4D79BB" Text="Search Template" /></li>
                    </ul>
                </div>
            </td>
        </tr>
    </table>
    <div class="clear">
    </div>
</div>
<div class="AOnlineHeaderLine">
</div>
