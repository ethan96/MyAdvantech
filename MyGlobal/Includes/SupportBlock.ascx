<%@ Control Language="VB" ClassName="SupportBlock" %>
<script runat="server">
    Public _isCP As Boolean
    Property IsCP() As Boolean
        Get
            Return _isCP
        End Get
        Set(ByVal value As Boolean)
            _isCP = value
        End Set
    End Property

    Public Property RMALinkVisible As Boolean
        Get
            Return tbRMArec.Visible
        End Get
        Set(ByVal value As Boolean)
            tbRMArec.Visible = value : tdRMAline.Visible = value
        End Set
    End Property

    Private Sub VisibilityControl()
        'If Session("org_id") IsNot Nothing AndAlso Session("ORG") IsNot Nothing Then
        If Session("org_id") IsNot Nothing Then
            Dim _org_id As String = Left(Session("org_id").ToString.ToUpper, 2)
            If _org_id = "EU" OrElse _org_id = "US" _
                OrElse _org_id = "TW" OrElse _org_id = "JP" _
                OrElse _org_id = "AU" Then
            Else
                tr_DlPriceList.Visible = False
            End If

            Dim reqUrl As String = Request.Url.ToString().ToLower(), accStatus As String = Session("account_status").ToString().ToUpper()
            If reqUrl.EndsWith("home_ga.aspx") Then accStatus = "GA"
            If reqUrl.EndsWith("home_cp.aspx") Then
                If Session("RBU") = "ANA" Then
                    trMyAUserGuide.Visible = True
                    trAACProductInfoVideo.Visible = True : trAACSysTrainingVideo.Visible = True
                End If

                'Alex 20180314 Tracy ask to hide some information for US10 
                If AuthUtil.IsBBUS Then
                    tr_DlPriceList.Visible = False
                End If
            End If
            If reqUrl.EndsWith("home_ka.aspx") Then

                'Alex 20180314 Tracy ask to hide some information for US10 
                If AuthUtil.IsBBUS Then
                    tr_DlPriceList.Visible = False
                End If
            End If

            If Not AuthUtil.IsACN Then
                Me.trACNPackingList.Visible = False
                Me.trACNTestReport.Visible = False
            End If

            Select Case accStatus
                Case "GA"
                    tr_DlPriceList.Visible = False : hyLitReq.NavigateUrl = "http://www.advantech.com/catalogs/default.aspx" : MCT_TR.Visible = False
                    Exit Select
                Case "CP"
                    'hyDlPriceList.NavigateUrl = "~/order/Price_List3.aspx"
                    If Session("org_id") <> "US01" Then
                        trLitReq.Visible = False : MCT_TR.Visible = False
                    End If
                    If Session("org_id").ToString().Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
                        'tr_EUKickOff.Visible = True
                    End If
                    'Frank 2012/10/01: AAC User's Guide download link only for AAC CP


                    If Session("RBU") = "HQDC" And AuthUtil.IsCanSeeCost(Session("user_id")) = False Then tr_DlPriceList.Visible = False



                    Exit Select
                Case "KA"
                    If Session("org_id") <> "US01" Then
                        trLitReq.Visible = False : MCT_TR.Visible = False
                    End If
                    If Session("org_id").ToString().Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
                        'tr_EUKickOff.Visible = True
                    End If
                    If Session("RBU") = "ANA" Or Session("RBU") = "ANA" Then
                        tr_DlPriceList.Visible = False : hyLitReq.NavigateUrl = "http://www.advantech.com/catalogs/default.aspx"
                    End If
                    If Session("RBU") = "ANA" Then trMyAUserGuide.Visible = True

                    Exit Select
                Case "EZ"
                    If Session("org_id") <> "US01" Then
                        trLitReq.Visible = False : MCT_TR.Visible = False
                    End If
                    If Session("org_id").ToString().Equals("EU10", StringComparison.OrdinalIgnoreCase) Then
                        'tr_EUKickOff.Visible = True
                    End If
                    If Session("RBU") = "ANA" Then hyLitReq.NavigateUrl = "http://www.advantech.com/catalogs/default.aspx"
                    If Session("RBU") = "ANA" Then trMyAUserGuide.Visible = True

                    Exit Select
            End Select
        Else
            tr_DlPriceList.Visible = False
        End If
        If Session("RBU") = "ANA" OrElse Session("RBU") = "ANA" OrElse (Session("RBU") = "ANA" AndAlso Not AuthUtil.IsInterConUser()) Then trElearning.Visible = False

        '20170823 TC: If SAP sales office=2100 (AAC) then link to AAC lit req page
        If Session("SAP Sales Office") IsNot Nothing AndAlso Session("SAP Sales Office").ToString() = "2100" Then
            Me.hyLitReq.NavigateUrl = "~/admin/LitReqLarge1.aspx"
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            'MailUtil.SendEmail("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", Request.Url.ToString(), "", False, "", "")
            VisibilityControl()
        End If

        'Frank 2012/03/15:Set Terms And Conditions Link Target by region
        'Me.SetTermsAndConditionsLinkTarget()

    End Sub

    ' ''' <summary>
    ' ''' Set Terms And Conditions Link Target by region
    ' ''' </summary>
    ' ''' <remarks></remarks>
    'Public Sub SetTermsAndConditionsLinkTarget()
    '    'Frank 2012/03/15: Terms and Conditions control
    '    Dim _org_id As String = Session("org_id")
    '    If String.IsNullOrEmpty(_org_id) Then
    '        _org_id = "US"
    '    Else
    '        If _org_id.Length > 1 Then
    '            _org_id = _org_id.Substring(0, 2).ToUpper
    '        Else
    '            _org_id = "US"
    '        End If
    '    End If

    '    Select Case _org_id
    '        Case "EU"
    '            HyperLink2.NavigateUrl = "~/files/Terms.aspx"
    '        Case "TW"
    '            HyperLink2.NavigateUrl = "~/files/Terms_TW.aspx"
    '        Case Else
    '            'US and other Region(not include EU and TW) show Terms of USA
    '            HyperLink2.NavigateUrl = "~/files/Terms_USA.aspx"
    '    End Select

    'End Sub


    Protected Sub LiTs_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Lit As Literal = CType(sender, Literal)
        Dim LiTstr As String = Util.GetLANGLiT_text(Lit.ID.ToString.Trim)
        If LiTstr.ToString.Trim <> "" Then
            Lit.Text = LiTstr
        End If
    End Sub
</script>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
    <tr>
        <td height="10">
        </td>
        <td>
        </td>
    </tr>
    <tr>
        <td height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image7" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="hyLitSearch" NavigateUrl="~/Product/MaterialSearch.aspx"
                            Text="">
                            <asp:Literal ID="LiT26" runat="server" OnLoad="LiTs_Load">Resource Library</asp:Literal>
                        </asp:HyperLink>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image6" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <a href="http://erma.advantech.com.tw/" target="_blank">
                            <asp:Literal ID="LiT27" runat="server" OnLoad="LiTs_Load">Return, Repair, Warranty</asp:Literal>
                        </a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td height="20" runat="server" id="tdRMAline">
        </td>
        <td class="menu_list">
            <table width="100%" border="0" cellspacing="0" cellpadding="0" runat="server" id="tbRMArec">
                <tr>
                    <td width="10%">
                    </td>
                    <td class="menu_list">
                        <asp:HyperLink runat="server" ID="hyRMA" Text="My RMA Record" NavigateUrl="~/Order/MyRMA.aspx" />
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr runat="server" id="tr_DlPriceList">
        <td width="5%" height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image5" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="hyDlPriceList" NavigateUrl="~/order/Price_List.aspx"
                            Text="">
                            <asp:Literal ID="litD" runat="server" OnLoad="LiTs_Load">Download Price List</asp:Literal>
                        </asp:HyperLink>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr runat="server" id="trLitReq">
        <td width="5%" height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image4" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="hyLitReq" Target="_blank" NavigateUrl="~/admin/LitReqLarge1.aspx. "
                            Text="">
                            <asp:Literal ID="Literal1" runat="server" OnLoad="LiTs_Load">Order Literature</asp:Literal>
                        </asp:HyperLink>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td width="5%" height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image3" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="HyperLink2" Target="_blank" NavigateUrl="~/files/Terms_Index.aspx" Text="Terms & Conditions">
                        </asp:HyperLink>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr id="MCT_TR" runat="server">
        <td width="5%" height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image2" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="HyperLink3" Target="_blank" NavigateUrl="~/product/USA_Training.aspx"
                            Text="">
                            <asp:Literal ID="Literal3" runat="server" OnLoad="LiTs_Load">Channel Training</asp:Literal>
                        </asp:HyperLink>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr id="trAACSysTrainingVideo" runat="server" visible="false">
        <td width="5%" height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image10" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="HyperLink1" Target="_blank" NavigateUrl="https://www.youtube.com/playlist?list=PLfSyeb6482zhv15C7zl0tEmj4VKHa9ek7"
                            Text="">
                            <asp:Literal ID="Literal2" runat="server" OnLoad="LiTs_Load">Systems Training Videos</asp:Literal>
                        </asp:HyperLink>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr id="trAACProductInfoVideo" runat="server" visible="false">
        <td width="5%" height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image11" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="HyperLink4" Target="_blank" NavigateUrl="https://www.youtube.com/playlist?list=PLfSyeb6482zhsZe7rXACE39dcGTjEIWJT"
                            Text="">
                            <asp:Literal ID="Literal4" runat="server" OnLoad="LiTs_Load">Product Information Videos</asp:Literal>
                        </asp:HyperLink>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr runat="server" id="trElearning" visible="true">
        <td height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image1" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <%--ICC 2015/5/4 Change eLearning link--%>
                        <a href="http://elearning.advantech.com.tw"
                            target="_blank">Learning Passport</a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
     <tr runat="server" id="trCSM" visible="true">
        <td height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image9" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">                        
                        <a href="/product/CMSList.aspx"
                            target="_blank">CMS Video</a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr runat="server" id="tr_EUKickOff" visible="false">
        <td></td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="ImgPoint1" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="hyKickOffLnk" NavigateUrl="~/Files/Advantech Europe Channel Workshop.htm" 
                                Text="Advantech Europe Channel Workshop" />
                    </td>
                </tr>
            </table>            
        </td>
    </tr>
    <tr runat="server" id="trMyAUserGuide" visible="false">
        <td></td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image8" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">
                        <asp:HyperLink runat="server" ID="hyMyAUserGuide" NavigateUrl="http://edm.advantech.com/4waGnD_ce34dcd408_27.jsp" 
                                Text="MyAdvantech User Guide" Target="_blank" />
                    </td>
                </tr>
            </table>            
        </td>
    </tr>
    <tr runat="server" id="trACNPackingList" visible="true">
        <td height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image12" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">                        
                        <asp:HyperLink runat="server" ID="hlACNPackingList" NavigateUrl="http://ictos.advantech.com.cn/Report/SearchPacking" 
                                Text="Packing List" Target="_blank" />
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr runat="server" id="trACNTestReport" visible="true">
        <td height="25">
        </td>
        <td>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td width="5%" valign="top">
                        <asp:Image runat="server" ID="Image13" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                    </td>
                    <td class="menu_title02">                        
                        <asp:HyperLink runat="server" ID="HyperLink5" NavigateUrl="http://ictos.advantech.com.cn/Report/SearchTest" 
                                Text="Test Report" Target="_blank" />
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td height="10">
        </td>
        <td>
        </td>
    </tr>
</table>
