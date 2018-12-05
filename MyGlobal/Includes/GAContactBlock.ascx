<%@ Control Language="VB" ClassName="GAContactBlock" %>

<script runat="server">
    Function GetCustContent(ByVal UseBaa As Boolean) As DataTable
        Dim userBaa As New ArrayList
        If UseBaa Then userBaa = Util.GetUserBaa()
        Dim strBaas As String = String.Join(",", CType(userBaa.ToArray(GetType(String)), String()))
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(String.Format(" SELECT distinct top 1 a.TITLE, a.RELEASE_DATE, a.LASTUPDATED,  "))
            .AppendLine(String.Format(" a.CATEGORY_NAME, a.RECORD_ID, a.RECORD_IMG, a.HYPER_LINK, "))
            .AppendLine(String.Format(" a.ABSTRACT, a.COUNTRY, a.CITY, a.BOOTH, a.CONTACT_NAME, "))
            .AppendLine(String.Format(" a.CONTACT_PHONE, a.CONTACT_EMAIL, a.AP_TYPE, a.CMS_TYPE, a.BAA, "))
            .AppendLine(String.Format(" a.HOURS, a.MINUTE, a.SECOND, a.CLICKTIME "))
            .AppendLine(String.Format(" FROM WWW_RESOURCES AS a "))
            .AppendLine(String.Format(" WHERE a.ABSTRACT<>''  "))
            If Session("lanG") = "KOR" Then
                .AppendLine(String.Format(" and a.RBU ='AKR' "))
            ElseIf Session("lanG") = "JAP" Then
                .AppendLine(String.Format(" and a.RBU ='AJP' "))
            Else
                .AppendLine(String.Format(" and a.RBU in ('AEU','AUS','AAU') "))
            End If
            .AppendLine(String.Format(" and a.CATEGORY_NAME='eCatalog'  "))
            If Session("account_status") <> "EZ" AndAlso userBaa.Count > 0 AndAlso UseBaa Then
                .AppendLine(String.Format(" and a.BAA in ({0}) ", strBaas))
            End If
        End With
        Return dbUtil.dbGetDataTable("MY", sb.ToString())
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        Dim cdt As DataTable = GetCustContent(True)
        Dim catalogDt As DataTable = cdt.Clone()
        Dim rTypes() As String = {"eCatalog"}
        Dim rTables() As DataTable = {catalogDt}
        Dim gvResources() As GridView = {gvCatalog}
        Dim rs() As DataRow = Nothing
        For i As Integer = 0 To rTypes.Length - 1
            rs = cdt.Select("CATEGORY_NAME='" + rTypes(i) + "'")
            If rs.Length > 0 Then
                For Each r As DataRow In rs
                    rTables(i).ImportRow(r)
                Next
            End If
        Next
        For i As Integer = 0 To rTypes.Length - 1
            If rTables(i).Rows.Count = 0 Then
                cdt = GetCustContent(False) : Exit For
            End If
        Next
        For i As Integer = 0 To rTypes.Length - 1
            If rTables(i).Rows.Count = 0 Then
                rs = cdt.Select("CATEGORY_NAME='" + rTypes(i) + "'")
                If rs.Length > 0 Then
                    For Each r As DataRow In rs
                        rTables(i).ImportRow(r)
                    Next
                End If
            End If
            gvResources(i).DataSource = rTables(i) : gvResources(i).DataBind()
        Next
        
        Dim ip As String = Util.GetClientIP()
        If ip Like "172.*" Or ip Like "127.*" Then
            divPhone.Visible = False
            If dbUtil.dbGetDataTable("MY", String.Format("select ID from ADVANTECH_ADDRESSBOOK where PrimarySmtpAddress = '{0}' and CompanyName='AJP'", Session("user_id"))).Rows.Count > 0 Then
                GetAJPContactInfo()
            End If
        Else
            divPhone.Visible = True
            Dim toll_num As String = Util.GetTollNumber()
            lblPhone.Text = toll_num
            If Util.IP2Nation = "JP" Then GetAJPContactInfo()
        End If
    End Sub
    
    Protected Sub lblCatalog_DataBinding(sender As Object, e As System.EventArgs)
        BindText(CType(sender, Label))
    End Sub
    
    Public Sub BindText(ByVal lbl As Label)
        If Len(lbl.Text) > 200 Then
            lbl.Text = lbl.Text.Substring(0, 200) + String.Format("<a href='javascript:void(0);' onclick='javascript:ShowText(""{0}"",""{1}"")'> ...</a>", lbl.ClientID, lbl.Text)
        End If
    End Sub

    Protected Sub hleCatalog_Load(sender As Object, e As System.EventArgs)
        Dim strLitType As Integer = 21
        If Session("account_status") Is Nothing Then
            strLitType = 11
        Else
            If Session("account_status") = "CP" Then strLitType = 19
            If Session("account_status") = "GA" Then strLitType = 11
        End If
        hleCatalog.NavigateUrl = "~/Product/MaterialSearch.aspx?key=&LitType=" + strLitType.ToString()
    End Sub
    
    Public Sub GetAJPContactInfo()
        divPhone.Visible = False
        Label1.Text = "お問い合わせは下記まで<br/>フリーコール <font color='#3399FF'>0800-500-1055</font><br/>メール<a href='mailto:ajp_callcener@advantech.com'>ajp_callcener@advantech.com</a>"
        Label2.Visible = False
        Label3.Text = "オンラインチャットを<br/>開始する<br/>"
        hlChat.Visible = True : _lpLiveCallBtn.Visible = False
        hlRequest.Visible = True
    End Sub
</script>
<script type="text/javascript">
    function ShowText(id, text) {
        document.getElementById(id).innerText = text;
    }
</script>
<link href="../Includes/styles.css" rel="Stylesheet" type="text/css" />
<link href="../Includes/main.css" rel="Stylesheet" type="text/css" />
<link href="../Includes/systemselection.css" rel="Stylesheet" type="text/css" />
<style type="text/css">
    ul.sign
    {
        list-style: none;
        margin: 0;
        padding: 0;
        display: block;
    }
    ul.sign li
    {
        display: block;
        background: none;
        margin: 0;
        padding: 0;
        line-height: normal;
    }
    ul.sign li a
    {
        display: block;
        outline: none;
        margin: 0;
        text-decoration: none;
        color: #3399FF;
    }
    ul.sign li a:hover, ul.sign li a:active, ul.sign li a:focus
    {
        color: #CC0000;
        text-decoration: none;
    }
    .at-box{
	    box-shadow: 0 0 4px rgba(0, 0, 0, 0.1);
	    -moz-box-shadow: 0 0 4px rgba(0, 0, 0, 0.1);
    }
    .at-box {
	    padding:10px;
	    margin-bottom:10px;
	    margin-top:10px;
	    position:relative;
	    position: relative;
	    color:#656;
	    background:#fff;
	    border:1px solid #d7d7d7;
	    -moz-border-radius: 4px;
    }
</style>

<table cellpadding="0" cellspacing="0"><tr><td height="3"></td></tr></table>
<div class="at-expert-box">
    <div class="iplanet_online_call_title">
        <asp:Label runat="server" ID="Label1" Text="Our Sales Engineers have the technical knowledge and skills required to be your
        project liaison from concept to completion." /></div>
    <div class="iplanet_online_call" runat="server" id="divPhone" visible="false">
        <table border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <img src="../images/call_icon.jpg" />
                </td>
                <td width="5">
                </td>
                <td>
                    Call Advantech<br />
                    <span style="color: #3399FF;"><asp:Label runat="server" ID="lblPhone" /></span>
                </td>
            </tr>
        </table>
    </div>
    <div class="iplanet_online_chat">
        <asp:label runat="server" ID="Label2" Text="Ask an Expert" />
        <table border="0" cellpadding="0" cellspacing="0" class="iplanet_online_call02">
            <tr>
                <td>
                    <img src="../images/chat_icon.jpg" />
                </td>
                <td width="5">
                </td>
                <td>
                    <a href="https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToChat&amp;site=68676965&amp;byhref=1&amp;SESSIONVAR!skill=&amp;imageUrl=https://buy.advantech.com/images/AUS/livechat/&#39; target=&#39;chat68676965&#39; " id="_lpChatBtn" onclick="lpButtonCTTUrl = &#39;https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToChat&amp;site=68676965&amp;SESSIONVAR!skill=&amp;imageUrl=https://buy.advantech.com/images/AUS/livechat/&amp;referrer=&#39;+escape(document.location); lpButtonCTTUrl = (typeof(lpAppendVisitorCookies) != &#39;undefined&#39; ? lpAppendVisitorCookies(lpButtonCTTUrl) : lpButtonCTTUrl); window.open(lpButtonCTTUrl,&#39;chat68676965&#39;,&#39;width=475,height=400,resizable=yes&#39;);return false;" style="color: #3399FF"><asp:Label runat="server" ID="Label3" Text="Chat Online Now" /></a>
                    <asp:HyperLink runat="server" ID="hlChat" Text=">> チャットの使い方はこちら" NavigateUrl="http://www.advantech.co.jp/news/mail/120201contact/index.htm#livechat" Target="_blank" Visible="false" ForeColor="#3399FF" Font-Size="10px" />
                </td>
            </tr>
            <tr>
                <td colspan="3" height="2">
                </td>
            </tr>
            <tr>
                <td>
                    <img src="../images/call_icon_02.jpg" />
                </td>
                <td width="5">
                </td>
                <td>
                    <a runat="server" href="https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToTalk&amp;site=68676965&amp;SESSIONVAR!skill=Voice PBX&amp;onlineURL=https://server.iad.liveperson.net/hcp/voice/forms/precall.asp?site=68676965%26identifier=1&amp;ResponseURL=https://server.iad.liveperson.net/hcp/voice/forms/callStatus.asp&amp;byhref=1&amp;imageUrl=https://buy.advantech.com/images/AUS/livetalk/&#39; target=&#39;call68676965&#39;" id="_lpLiveCallBtn" onclick="javascript:window.open(&#39;https://server.iad.liveperson.net/hc/68676965/?cmd=file&amp;file=visitorWantsToTalk&amp;site=68676965&amp;SESSIONVAR!skill=Voice PBX&amp;onlineURL=https://server.iad.liveperson.net/hcp/voice/forms/precall.asp?site=68676965%26identifier=1%26ResponseURL=https://server.iad.liveperson.net/hcp/voice/forms/callStatus.asp&amp;imageUrl=https://buy.advantech.com/images/AUS/livetalk/&amp;referrer=&#39;+escape(document.location),&#39;call68676965&#39;,&#39;width=475,height=420&#39;);return false;" style="color: #3399FF">Request Call Back</a>
                    <asp:HyperLink runat="server" ID="hlRequest" Text="お問い合わせフォームから問い合わせる" NavigateUrl="http://www.advantech.co.jp/contact/default.aspx?page=contact_form2&subject=Price+and+Quotation" Target="_blank" Visible="false" ForeColor="#3399FF" Font-Size="10px" />
                </td>
            </tr>
        </table>
    </div>
</div>
<div class="shadow1">
    <div class="at-box">
        <div class="box-title-wrapper">
            <div class="box-title-wrapper2">
                <div class="box-title-wrapper3">
                    <h2 class="title box-title">
                        <font size="4">eCatalog</font></h2>
                </div>
            </div>
        </div>
        <div class="module-content">
            <asp:GridView runat="server" ID="gvCatalog" EnableTheming="false" AutoGenerateColumns="false"
                ShowHeader="false" BorderColor="White" BorderWidth="0" RowStyle-Width="0">
                <Columns>
                    <asp:TemplateField ItemStyle-BorderColor="White">
                        <ItemTemplate>
                            <a href='http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                target='_blank'>
                                <img src='<%#Eval("RECORD_IMG") %>' alt="eCatalog" width="154" class="at-img"
                                    style="padding: 8px 0;">
                            </a>
                            <br />
                            <a href='http://resources.advantech.com.tw/sso/autologin.aspx?tempid=<%=Session("TempId") %>&id=<%=Session("user_id") %>&pass=MY&callbackurl=http://resources.advantech.com/Resources/Details.aspx?rid=<%#Eval("record_id") %>'
                                target='_blank'>
                                <font color="#196fac"><%#Trim(Eval("title"))%></font></a><br />
                            <asp:Label runat="server" ID="lblCatalog" Text='<%#Eval("abstract") %>' ForeColor="#666666" OnDataBinding="lblCatalog_DataBinding" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <div style="text-align: right">
                <asp:HyperLink runat="server" ID="hleCatalog" Target="_blank" OnLoad="hleCatalog_Load">
                    <img src="../images/btn_more-catalog.jpg" width="99" height="24" />
                </asp:HyperLink>
            </div>
            <div class="clear">
            </div>
        </div>
    </div>
    <!-- //RIGHT COLUMN -->
</div>