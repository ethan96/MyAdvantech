<%@ Page Title="MyAdvantech- My Viewed Product" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="GAContactBlocak" TagPrefix="uc1" Src="~/Includes/GAContactBlock.ascx" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", MyLog.GetViewProduct(""))
            If dt.Rows.Count > 0 Then
                Dim embedDt As DataTable = dt.Clone(), applDt As DataTable = dt.Clone(), indusDt As DataTable = dt.Clone(), designDt As DataTable = dt.Clone()
                Dim digiDt As DataTable = dt.Clone(), mediDt As DataTable = dt.Clone()
                Dim rTables() As DataTable = {embedDt, applDt, indusDt, designDt, digiDt, mediDt}
                Dim dlResources() As DataList = {dlEmbed, dlApplied, dlIndust, dlDesign, dlDigital, dlMedical}
                Dim panels() As Panel = {panelEmbed, panelApplied, panelIndest, panelDesign, panelDigital, panelMedical}
                Dim moreButtons() As ImageButton = {btnMoreEmbed, btnMoreApplied, btnMoreIndust, btnMoreDesign, btnMoreDigital, btnMoreMedical}
                Dim items() As DataRow = Nothing, count As Integer = 0
                For Each prod_type As String In [Enum].GetNames(GetType(MyLog.ModelCategory))
                    items = dt.Select(String.Format("type='{0}'", prod_type))
                    If items.Count = 0 Then
                        panels(count).Visible = False
                    Else
                        panels(count).Visible = True
                        If items.Count <= 3 Then
                            moreButtons(count).Visible = False
                        End If
                        Dim i As Integer = 0
                        For Each r As DataRow In items
                            If i < 3 Then rTables(count).ImportRow(r)
                            i += 1
                        Next
                    End If
                    dlResources(count).DataSource = rTables(count) : dlResources(count).DataBind()
                    count += 1
                Next
            End If
        End If
    End Sub

    Protected Sub btnMoreIndust_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", MyLog.GetViewProduct(MyLog.ModelCategory.IndustrialAutomation.ToString))
        If dt.Rows.Count > 0 Then
            dlIndust.DataSource = dt : dlIndust.DataBind()
        End If
        btnMoreIndust.Visible = False
    End Sub

    Protected Sub btnMoreApplied_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", MyLog.GetViewProduct(MyLog.ModelCategory.AppliedComputing.ToString))
        If dt.Rows.Count > 0 Then
            dlApplied.DataSource = dt : dlApplied.DataBind()
        End If
        btnMoreApplied.Visible = False
    End Sub

    Protected Sub btnMoreDesign_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", MyLog.GetViewProduct(MyLog.ModelCategory.DesignManufacturing.ToString))
        If dt.Rows.Count > 0 Then
            dlDesign.DataSource = dt : dlDesign.DataBind()
        End If
        btnMoreDesign.Visible = False
    End Sub

    Protected Sub btnMoreDigital_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", MyLog.GetViewProduct(MyLog.ModelCategory.DigitalSignage.ToString))
        If dt.Rows.Count > 0 Then
            dlDigital.DataSource = dt : dlDigital.DataBind()
        End If
        btnMoreDigital.Visible = False
    End Sub

    Protected Sub btnMoreEmbed_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", MyLog.GetViewProduct(MyLog.ModelCategory.EmbeddedBoards.ToString))
        If dt.Rows.Count > 0 Then
            dlEmbed.DataSource = dt : dlEmbed.DataBind()
        End If
        btnMoreEmbed.Visible = False
    End Sub

    Protected Sub btnMoreMedical_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", MyLog.GetViewProduct(MyLog.ModelCategory.MedicalComputing.ToString))
        If dt.Rows.Count > 0 Then
            dlMedical.DataSource = dt : dlMedical.DataBind()
        End If
        btnMoreMedical.Visible = False
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<style type="text/css">
    #content {
	    height: auto;
	    width: 690px;
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    line-height: 1.5em;
	    float: left;
	    margin-top: 10px;
    }
    #content #product {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    margin-top: 10px;
	    height: 300px;
	    width: 690px;
    }
    .bluetitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 15px;
	    font-weight: bold;
	    color: #3fb2e2;
    }
    #content #title {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 22px;
	    color: #000;
	    font-weight: bold;
    }
    #content #subtitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    margin-top: 10px;
    }
    #rightmenu {
	    float: left;
	    height: auto;
	    width: 195px;
	    margin-left: 5px;
	    margin-top: 10px;
    }
    #rightmenu #hline {
	    background-image: url(../images/line1.jpg);
	    background-repeat: no-repeat;
	    height: 5px;
    }
    #rightmenu #contact {
	    height: auto;
	    width: 190px;
	    margin-bottom: 10px;
    }
    #content #MedicalComputing {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #004a84;
	    background-image: url(../images/band_blue.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #Networks {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #0082d1;
	    background-image: url(../images/band_sky.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #AppliedComputing {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #f98800;
	    background-image: url(../images/band_orange.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #EmbeddedBoards {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #5b2b6e;
	    background-image: url(../images/band_purple.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #IndustrialAutomation {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #008736;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
	    background-position: 0px 15px;
    }
    #content #DigitalSignage {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    color: #f7b500;
	    background-image: url(../images/band_yellow.jpg);
	    background-repeat: no-repeat;
	    padding-left: 15px;
	    margin-top: 10px;
	    height: auto;
    }
    #content #product #product1 {
	    float: left;
	    height: 270px;
	    width: 220px;
	    margin-right: 10px;
    }
    #content #product #more {
	    float: left;
	    height: 30px;
	    width: 70px;
	    padding-left: 620px;
	    border-bottom-width: thin;
	    border-bottom-style: solid;
	    border-bottom-color: #CCC;
	    padding-top: 10px;
	    margin-bottom: 10px;
    }
    #rightmenu #ecatalog {
	    float: left;
	    height: auto;
	    width: 195px;
	    margin-top: 5px;
    }
    #rightmenu #ecatalog table tr td .bg {
	    background-image: url(images/ecatalog_bg.jpg);
	    background-repeat: repeat-y;
    }
    #content #productset {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    float: left;
	    height: auto;
	    width: 690px;
	    margin-top: 10px;
    }
    .producttitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 16px;
	    font-weight: bold;
	    color: #3fb2e2;
	    line-height: 2em;
    }
    .price {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 14px;
	    font-weight: bold;
	    color: #fb6717;
	    line-height: 2em;
    }
    #content #menu {
	    float: left;
	    height: auto;
	    width: 690px;
	    margin-top: 10px;
    }
    .tabletext {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 20px;
	    font-weight: normal;
    }
    .subtitle {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 16px;
	    font-weight: bold;
    }
    .bluetext {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 14px;
	    font-weight: bold;
	    color: #3fb2e2;
	    line-height: 1.3em;
    }
</style>
<table>
    <tr>
        <td valign="top">
            <div id="navtext"><a style="color:Black" href="../home_ga.aspx">Home</a>> My Viewed Products</div>
            <div id="content">
                <div id="title">
                    My Viewed Products</div>
                <div id="subtitle">
                    Click the product images to link to the product pages you have visited.</div>
            </div>
            <table><tr><td height="10"></td></tr></table>
            <asp:Panel runat="server" ID="panelDigital" Visible="false">
                <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="../images/band_yellow.jpg" /></td><td width="10"></td><td style="color: #f7b500; font-size:20px">Digital Signage & Self-Service</td></tr>
                </table>
                <div id="productDigital" runat="server" style="height:350px;overflow:auto;">
                    <asp:UpdatePanel runat="server" ID="upDigital" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:DataList runat="server" ID="dlDigital" RepeatDirection="Horizontal">
                                <ItemTemplate>
                                    <table width="220" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="230">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank">
                                                    <img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=<%#Eval("TUMBNAIL_IMAGE_ID") %>' width="220px" height="220px" />
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" valign="top" class="bluetitle">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank" style="color:#3FB2E2">
                                                    <%#Eval("ROW_ID")%>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <%#Eval("MODEL_DESC")%>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:DataList>
                            <table width="100%"><tr><td align="right"><asp:ImageButton runat="server" ID="btnMoreDigital" ImageUrl="~/Images/btn_more.jpg" width="54" height="21" OnClick="btnMoreDigital_Click" /></td></tr></table>
                            <hr />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:Panel>
            <asp:Panel runat="server" ID="panelMedical" Visible="false">
                <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="../images/band_blue.jpg" /></td><td width="10"></td><td style="color: #004a84; font-size:20px">Medical Computing</td></tr>
                </table>
                <div id="productMedical" runat="server" style="height:350px;overflow:auto;">
                    <asp:UpdatePanel runat="server" ID="upMedical" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:DataList runat="server" ID="dlMedical" RepeatDirection="Horizontal">
                                <ItemTemplate>
                                    <table width="220" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="230">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank">
                                                    <img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=<%#Eval("TUMBNAIL_IMAGE_ID") %>' width="220" height="220" />
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" class="bluetitle">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank" style="color:#3FB2E2">
                                                    <%#Eval("ROW_ID")%>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <%#Eval("MODEL_DESC")%>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:DataList>
                            <table width="100%"><tr><td align="right"><asp:ImageButton runat="server" ID="btnMoreMedical" ImageUrl="~/Images/btn_more.jpg" width="54" height="21" OnClick="btnMoreMedical_Click" /></td></tr></table>
                            <hr />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:Panel>
            <asp:Panel runat="server" ID="panelIndest" Visible="false">
                <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="../images/band_green.jpg" /></td><td width="10"></td><td style="color: #008736; font-size:20px">Industrial Automation</td></tr>
                </table>
                <div id="productIndust" runat="server" style="height:350px;overflow:auto;">
                    <asp:UpdatePanel runat="server" ID="upIndust" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:DataList runat="server" ID="dlIndust" RepeatDirection="Horizontal" RepeatColumns="3">
                                <ItemTemplate>
                                    <table width="220" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="230" height="230">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank">
                                                    <img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=<%#Eval("TUMBNAIL_IMAGE_ID") %>' width="220" height="220" />
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" valign="top" class="bluetitle">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank" style="color:#3FB2E2">
                                                    <%#Eval("ROW_ID")%>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <%#Eval("MODEL_DESC")%>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:DataList>
                            <table width="100%"><tr><td align="right"><asp:ImageButton runat="server" ID="btnMoreIndust" ImageUrl="~/Images/btn_more.jpg" width="54" height="21" OnClick="btnMoreIndust_Click" /></td></tr></table>
                            <hr />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:Panel>
            <asp:Panel runat="server" ID="panelEmbed" Visible="false">
                <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="../images/band_purple.jpg" /></td><td width="10"></td><td style="color: #5b2b6e; font-size:20px">Embedded Boards & Design-in Services</td></tr>
                </table>
                <div id="productEmbed" runat="server" style="height:350px;overflow:auto;">
                    <asp:UpdatePanel runat="server" ID="upEmbed" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:DataList runat="server" ID="dlEmbed" RepeatDirection="Horizontal">
                                <ItemTemplate>
                                    <table width="220" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="230">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank">
                                                    <img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=<%#Eval("TUMBNAIL_IMAGE_ID") %>' width="220" height="220" />
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" class="bluetitle">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank" style="color:#3FB2E2">
                                                    <%#Eval("ROW_ID")%>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <%#Eval("MODEL_DESC")%>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:DataList>
                            <table width="100%"><tr><td align="right"><asp:ImageButton runat="server" ID="btnMoreEmbed" ImageUrl="~/Images/btn_more.jpg" width="54" height="21" OnClick="btnMoreEmbed_Click" /></td></tr></table>
                            <hr />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:Panel>
            <asp:Panel runat="server" ID="panelApplied" Visible="false">
                <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="../images/band_orange.jpg" /></td><td width="10"></td><td style="color: #f98800; font-size:20px">Applied Computing & Embedded Systems</td></tr>
                </table>
                <div id="productApplied" runat="server" style="height:350px;overflow:auto;">
                    <asp:UpdatePanel runat="server" ID="upApplied" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:DataList runat="server" ID="dlApplied" RepeatDirection="Horizontal">
                                <ItemTemplate>
                                    <table width="220" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="230">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank">
                                                    <img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=<%#Eval("TUMBNAIL_IMAGE_ID") %>' width="220" height="220" />
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" class="bluetitle">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank" style="color:#3FB2E2">
                                                    <%#Eval("ROW_ID")%>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <%#Eval("MODEL_DESC")%>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:DataList>
                            <table width="100%"><tr><td align="right"><asp:ImageButton runat="server" ID="btnMoreApplied" ImageUrl="~/Images/btn_more.jpg" width="54" height="21" OnClick="btnMoreApplied_Click" /></td></tr></table>
                            <hr />
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:Panel>
            <asp:Panel runat="server" ID="panelDesign" Visible="false">
                <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="../images/band_sky.jpg" /></td><td width="10"></td><td style="color: #0082d1; font-size:20px">Design & Manufacturing/Networks & Telecom</td></tr>
                </table>
                <div id="productDesign" runat="server" style="height:350px;overflow:auto;">
                    <asp:UpdatePanel runat="server" ID="upDesign" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:DataList runat="server" ID="dlDesign" RepeatDirection="Horizontal">
                                <ItemTemplate>
                                    <table width="220" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="230">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank">
                                                    <img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=<%#Eval("TUMBNAIL_IMAGE_ID") %>' width="220" height="220" />
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" class="bluetitle">
                                                <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("ROW_ID")%>' target="_blank" style="color:#3FB2E2">
                                                    <%#Eval("ROW_ID")%>
                                                </a>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <%#Eval("MODEL_DESC")%>
                                            </td>
                                        </tr>
                                    </table>
                                </ItemTemplate>
                            </asp:DataList>
                            <table width="100%"><tr><td align="right"><asp:ImageButton runat="server" ID="btnMoreDesign" ImageUrl="~/Images/btn_more.jpg" width="54" height="21" OnClick="btnMoreDesign_Click" /></td></tr></table>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </asp:Panel>
        </td>
        <td valign="top">
            <uc1:GAContactBlocak runat="server" ID="ucGAContactBlock" />
        </td>
    </tr>
</table>
</asp:Content>

