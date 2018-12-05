<%@ Page Title="MyAdvantech - Channel Partner Home" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<%@ MasterType VirtualPath="~/Includes/MyMaster.master" %>
<%@ Register Src="~/Includes/CustomContent_Premier.ascx" TagName="WCustContent" TagPrefix="uc9" %>
<%@ Register Src="~/Includes/Banner.ascx" TagName="Banner" TagPrefix="uc10" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If (Request.Browser.MSDomVersion.Major = 0) Then
            Response.Cache.SetNoStore()
            ' No client side cashing for non IE browsers 
        End If

        If Not Page.IsPostBack Then
            'If Session("account_status").ToString() <> "CP" AndAlso Session("account_status").ToString() <> "EZ" Then
            '    Response.Redirect("home.aspx")
            'End If
            Me.Master.EnableAsyncPostBackHolder = False

            trAdvProdSearch.Visible = True

        End If
    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        'ICC 2015/10/26 Hide some server controls from master page. By Peter.Kim's request
        Dim btnSearch As ImageButton = CType(Master.FindControl("btnSearch"), ImageButton)
        If btnSearch IsNot Nothing Then btnSearch.Visible = False

        Dim PanelSearch As Panel = CType(Master.FindControl("PanelSearch"), Panel)
        If PanelSearch IsNot Nothing Then PanelSearch.Visible = False

        Dim dlSearchOption As DropDownList = CType(Master.FindControl("dlSearchOption"), DropDownList)
        If dlSearchOption IsNot Nothing Then dlSearchOption.Visible = False

        Dim tdSearch As HtmlTableCell = CType(Master.FindControl("tdSearch"), HtmlTableCell)
        If tdSearch IsNot Nothing Then tdSearch.Visible = False

        Dim tdAdmin1 As HtmlTableCell = CType(Master.FindControl("ADMIN1_TR"), HtmlTableCell)
        If tdAdmin1 IsNot Nothing Then tdAdmin1.Visible = False

        Dim tdAdmin2 As HtmlTableCell = CType(Master.FindControl("ADMIN2_TR"), HtmlTableCell)
        If tdAdmin2 IsNot Nothing Then tdAdmin2.Visible = False

        Dim tdAdminBuyer As HtmlTableCell = CType(Master.FindControl("tdAdminBuyer"), HtmlTableCell)
        If tdAdminBuyer IsNot Nothing Then tdAdminBuyer.Visible = False

        Dim tdAdminBuyer1 As HtmlTableCell = CType(Master.FindControl("tdAdminBuyer1"), HtmlTableCell)
        If tdAdminBuyer1 IsNot Nothing Then tdAdminBuyer1.Visible = False

        Dim tdeQuotation As HtmlTableCell = CType(Master.FindControl("tdeQuotation"), HtmlTableCell)
        If tdeQuotation IsNot Nothing Then tdeQuotation.Visible = False

        Dim tdeQuotation1 As HtmlTableCell = CType(Master.FindControl("tdeQuotation1"), HtmlTableCell)
        If tdeQuotation1 IsNot Nothing Then tdeQuotation1.Visible = False

        Dim tdHomeProduct As HtmlTableCell = CType(Master.FindControl("tdHomeProduct"), HtmlTableCell)
        If tdHomeProduct IsNot Nothing Then tdHomeProduct.Visible = False

        Dim tdHomeProduct1 As HtmlTableCell = CType(Master.FindControl("tdHomeProduct1"), HtmlTableCell)
        If tdHomeProduct1 IsNot Nothing Then tdHomeProduct1.Visible = False

        Dim tdHomeResource As HtmlTableCell = CType(Master.FindControl("tdHomeResource"), HtmlTableCell)
        If tdHomeResource IsNot Nothing Then tdHomeResource.Visible = False

        Dim tdHomeResource1 As HtmlTableCell = CType(Master.FindControl("tdHomeResource1"), HtmlTableCell)
        If tdHomeResource1 IsNot Nothing Then tdHomeResource1.Visible = False

        Dim tdHomeSupport As HtmlTableCell = CType(Master.FindControl("tdHomeSupport"), HtmlTableCell)
        If tdHomeSupport IsNot Nothing Then tdHomeSupport.Visible = False

        Dim tdHomeSupport1 As HtmlTableCell = CType(Master.FindControl("tdHomeSupport1"), HtmlTableCell)
        If tdHomeSupport1 IsNot Nothing Then tdHomeSupport1.Visible = False

    End Sub

    Public Shared Function FDate(ByVal d As String) As String
        If Date.TryParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR"), System.Globalization.DateTimeStyles.None, Now) Then
            Return Date.ParseExact(d, "yyyyMMdd", New System.Globalization.CultureInfo("fr-FR")).ToString("yyyy/MM/dd")
        End If
        Return d
    End Function

    Protected Sub gv1_RowCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If Not (e.Row Is Nothing) AndAlso e.Row.RowType = DataControlRowType.Header Then
            Dim GridView1 As GridView = sender
            For Each cell As TableCell In e.Row.Cells
                If cell.HasControls Then
                    Dim button As LinkButton = DirectCast(cell.Controls(0), LinkButton)
                    If Not (button Is Nothing) Then
                        Dim image As New ImageButton
                        image.ImageUrl = "/Images/sort_1.jpg"
                        image.CommandArgument = button.CommandArgument : image.CommandName = button.CommandName
                        If GridView1.SortExpression = button.CommandArgument Then
                            If GridView1.SortDirection = SortDirection.Ascending Then
                                image.ImageUrl = "/Images/sort_2.jpg"
                            Else
                                image.ImageUrl = "/Images/sort_1.jpg"
                            End If
                        End If
                        cell.Controls.Add(image)
                    End If
                End If
            Next
        End If
    End Sub

    Protected Sub LiTs_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim Lit As Literal = CType(sender, Literal)
        Dim LiTstr As String = Util.GetLANGLiT_text(Lit.ID.ToString.Trim)
        If LiTstr.ToString.Trim <> "" Then
            Lit.Text = LiTstr
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <style type="text/css">
        #nav {
            z-index: 50;
            position: absolute;
            vertical-align: bottom;
            text-align: right;
            top: 315px;
        }

            #nav a {
                margin: 0 5px;
                padding: 3px 5px;
                border: 1px solid #ccc;
                background: gray;
                text-decoration: none;
                color: White;
                font-weight: bold;
            }

                #nav a.activeSlide {
                    background: #aaf;
                }

                #nav a:focus {
                    outline: none;
                }
    </style>
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_beginRequest(beginRequest);
        function beginRequest() {
            prm._scrollPosition = null;
        }
    </script>
    <script type="text/javascript" src='./EC/Includes/jquery-latest.min.js'></script>
    <script type="text/javascript" src='./EC/Includes/jquery.cycle.all.latest.js'></script>
    <script type="text/javascript">
        $(document).ready(function () {
            var sidebar = $('#sidebar-connect');
            sidebar.hide();
            $('#slideshow').cycle({
                fx: 'fade',
                timeout: 300000000,
                pager: '#nav',
                slideExpr: 'table'
            });
        }
        );


    </script>
    <div class="left">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td>
                    <img src="Images/Arrow-260.png" alt="Arrow" style="margin-left: 27px" />
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <%--ICC Change Online Ordering to Online Tools--%>
                    <asp:Literal ID="LiT0" runat="server">Online Tools</asp:Literal>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <%--ICC Add parameter for PriceAndATP URL--%>
                                            <asp:HyperLink runat="server" ID="HyCheckPrice" Text="Check Price" NavigateUrl="~/Order/PriceAndATP.aspx?status=Price" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <%--ICC Add parameter for PriceAndATP URL--%>
                                            <asp:HyperLink runat="server" ID="HyperLink1" Text="Check Inventory" NavigateUrl="~/Order/PriceAndATP.aspx?status=Inventory" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table> 
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT3" runat="server">Product Info.</asp:Literal></td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink7" runat="server" NavigateUrl="~/Product/ProductSearch.aspx">
                                                <asp:Literal ID="LiT21" runat="server" OnLoad="LiTs_Load">Search</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr runat="server" id="trAdvProdSearch" visible="false">
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyAdvProdSearch" Text="Advanced Product Search"
                                                NavigateUrl="~/Product/Search.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyPPhaseInOut" NavigateUrl="~/Product/Product_PhaseInOut.aspx"
                                                Text="Phase In/ Out" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink8" runat="server" NavigateUrl="~/Product/New_Product.aspx">
                                                <asp:Literal ID="LiT23" runat="server">New Product Highlight</asp:Literal>
                                            </asp:HyperLink></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <img src="images/point_02.gif" alt="" width="7" height="14" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink ID="HyperLink9" runat="server" Text="Warranty Lookup" NavigateUrl="~/Order/RMAWarrantyLookup.aspx" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <tr>
                <td height="24" class="menu_title">
                    <asp:Literal ID="LiT4" runat="server" OnLoad="LiTs_Load">Support & Download</asp:Literal></td>
            </tr>
            <tr>
                <td>
                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                        <tr>
                            <td width="5%" height="10"></td>
                            <td></td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <asp:Image runat="server" ID="Image8" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                                        </td>
                                        <td class="menu_title02">
                                            <%--ICC 2015/10/30 Add a new link for Arrow customers to upload price list--%>
                                            <asp:HyperLink runat="server" ID="hyUlPriceList" NavigateUrl="~/Admin/UploadANApricelist.aspx" Text="">
                                                <asp:Literal ID="Literal27" runat="server" OnLoad="LiTs_Load">Upload Price List</asp:Literal>
                                            </asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <asp:Image runat="server" ID="Image7" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                                        </td>
                                        <td class="menu_title02">
                                            <%--ICC Add a new link for Arrow customers to download price list--%>
                                            <asp:HyperLink runat="server" ID="hyDlPriceList" NavigateUrl="~/order/Price_List.aspx" Text="">
                                                <asp:Literal ID="LiT26" runat="server" OnLoad="LiTs_Load">Download Price List</asp:Literal>
                                            </asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <%--ICC 2015/10/26 Add PremierDatasheet page. For Arrow's customer to upload & download datasheet--%>
                        <tr>
                            <td height="25"></td>
                            <td>
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td width="5%" valign="top">
                                            <asp:Image runat="server" ID="Image6" ImageUrl="~/Images/point_02.gif" AlternateText="point" />
                                        </td>
                                        <td class="menu_title02">
                                            <asp:HyperLink runat="server" ID="hyDataSheet" NavigateUrl="~/My/Premier/PremierDatasheet.aspx" Text="">
                                                <asp:Literal ID="LiT28" runat="server" OnLoad="LiTs_Load">Download & upload datasheet</asp:Literal>
                                            </asp:HyperLink>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td height="5"></td>
            </tr>
            <!-- ICC 2015/10/26 Remove Interal Function function (eMarketing & eDM tool). By Peter.Kim's request-->
        </table>
    </div>
    <div class="right">
        <table width="100%" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                            <td height="10"></td>
                        </tr>
                        <tr>
                            <td>
                                <div class="rightcontant">
                                    <div id="slideshow">
                                        <table height="330">
                                            <tr>
                                                <td valign="top">
                                                    <iframe width="450" height="300" src="http://www.youtube.com/embed/FFd3qIWk4HE" frameborder="0" allowfullscreen></iframe>
                                                    </td><td width="10"></td>
                                                <td valign="top" style="padding-top: 10px">
                                                    <a href="http://youtu.be/FFd3qIWk4HE" target="_blank">From Good to Great</a><br /> <br />For 30 years, "Good to great" has always been Advantech's core philosophy, which
                                                    lead us keep growing."Good to Great" is based on the 3-Circle Principle from Jim
                                                    Collins' book. Advantech has put it into action by clearly defining Advantech's
                                                    particular 3-Circle Principle. Watch the video to know more about Advantech's business
                                                    philosophy! </td></tr></table><table height="340">
                                            <tr>
                                                <td valign="top">
                                                    <iframe width="450" height="300" src="http://www.youtube.com/embed/LyPsdwSN6wQ" frameborder="0" allowfullscreen></iframe>
                                                    <%--<object width='450' height='300'>
                                                        <param name='movie' value='https://youtube.googleapis.com/v/LyPsdwSN6wQ'></param>
                                                        <param name='wmode' value='transparent'></param>
                                                        <embed src='https://youtube.googleapis.com/v/LyPsdwSN6wQ' type='application/x-shockwave-flash'
                                                            wmode='transparent' width='450' height='300'></embed></object>--%></td><td width="10"></td>
                                                <td valign="top" style="padding-top: 5px">
                                                    <a href="http://www.youtube.com/watch?v=LyPsdwSN6wQ" target="_blank">Visit Advantech's
                                                        headquarter through the video with us.</a><br /> <b>Advantech Mission:</b><br /> <li>Enabling an intelligent Plant through our IoT and Embedded Platforms designed for
                                                        system integrators.</li><li>Working & Learning Toward a Beautiful Life under our Altruistic
                                                            (LITA) Philosophy.</li><b>Advantech Values:</b><br /> <li>Customer Partnership and Talent Invigoration</li><li>Integrity and Certitude</li><li>Focused Leadership</li></td></tr></table><table height="330">
                                            <tr>
                                                <td valign="top">
                                                    <iframe width="450" height="300" src="http://www.youtube.com/embed/hr_htF0_zdI" frameborder="0" allowfullscreen></iframe>
                                                    <%--<object width='450' height='300'>
                                                        <param name='movie' value='https://youtube.googleapis.com/v/hr_htF0_zdI'></param>
                                                        <param name='wmode' value='transparent'></param>
                                                        <embed src='https://youtube.googleapis.com/v/hr_htF0_zdI' type='application/x-shockwave-flash'
                                                            wmode='transparent' width='450' height='300'></embed></object>--%></td><td width="10"></td>
                                                <td valign="top" style="padding-top: 5px">
                                                    <a href="http://www.youtube.com/watch?v=hr_htF0_zdI" target="_blank">Progressing the
                                                        Advantech Story</a><br /> <br />Established in 1983, Advantech has grown from a small business to an international
                                                    enterprise. In the 30 years, the core spirit and management philosophy of Advantech
                                                    Corporation is well presented in this corporate altruistic LITA tree.<br /> <br />The video illustrates the story of what we have done in the past 30 years and our
                                                    vision for the next 30 years. </td></tr></table><div id="nav">
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                        </tr>
                        <tr runat="server" id="tr_banner1">
                            <td align="left">
                                <uc10:Banner runat="server" ID="ucBanner" />
                            </td>
                        </tr>
                        <tr>
                            <td height="10"></td>
                        </tr>
                        <tr valign="top">
                            <td align="left">
                                <uc9:WCustContent runat="server" ID="WCont1" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
