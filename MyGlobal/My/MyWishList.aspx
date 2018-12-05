<%@ Page Title="MyAdvantech - My Wish List" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>
<%@ Register TagName="GAContactBlocak" TagPrefix="uc1" Src="~/Includes/GAContactBlock.ascx" %>

<script runat="server">

    Protected Sub sql1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        sql1.SelectCommand = GetSQL()
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            Dim count As Integer = CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(distinct data_value) from my_viewed_list where page_type='{0}' and user_id='{1}'", MyLog.PageType.WishList.ToString, Session("user_id"))))
            Dim purchase As Integer = CInt(dbUtil.dbExecuteScalar("MY", String.Format("select count(distinct data_value) from my_viewed_list where page_type='{0}' and user_id='{1}' and data_value in (select z.part_no from ESTORE_ORDER_LOG z where z.User_ID='{1}')", MyLog.PageType.WishList.ToString, Session("user_id"))))
            ddlType.Items.Add(New ListItem(String.Format("All({0})", count.ToString), "0"))
            ddlType.Items.Add(New ListItem(String.Format("Purchased({0})", purchase.ToString), "1"))
            ddlType.Items.Add(New ListItem(String.Format("Unpurchased({0})", (count - purchase).ToString), "2"))
            
            FillCategory()
        End If
    End Sub

    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        sql1.SelectCommand = GetSQL()
    End Sub
    
    Private Function GetSQL() As String
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct a.type, a.data_value, d.model_name as model_no, d.model_desc, isnull(d.IMAGE_ID,'') as IMAGE_ID, ")
            .AppendFormat(" isnull((select z.FEATURE_DESC from [PIS].dbo.model_feature z where z.model_name=b.MODEL_NO and z.LANG_ID = 'enu' for XML path('')),'') as feature_desc, ")
            .AppendFormat(" ISNULL((select distinct z1.LITERATURE_ID+'|'+z1.lit_name as lit ")
            .AppendFormat(" from [PIS].dbo.v_LITERATURE z1 left join [PIS].dbo.v_CATALOG_CATEGORY_LIT z2 on z1.LITERATURE_ID=z2.Literature_ID left join [PIS].dbo.v_CATALOG_CATEGORY z3 on z2.Category_ID=z3.CATEGORY_ID where z3.category_name=d.model_name ")
            .AppendFormat(" and z1.lit_type like 'Product - Photo%' and z1.file_ext in ('jpg','jpeg','gif','png') ")
            .AppendFormat(" and z1.PRIMARY_LEVEL <> 'RBU' for XML path('')),'') as literature ")
            .AppendFormat(" from my_viewed_list a left join [PIS].dbo.model_product c on a.data_value=c.part_no left join SAP_PRODUCT b on a.data_value=b.PART_NO ")
            .AppendFormat(" left join [PIS].dbo.MODEL d on c.model_name=d.Model_name or b.MODEL_NO=d.Model_name ")
            .AppendFormat(" where a.page_type='{0}' and a.user_id='{1}' and c.relation='product' ", MyLog.PageType.WishList.ToString, Session("user_id"))
            If ddlCategory.SelectedValue <> "0" Then
                .AppendFormat(" and a.type='{0}' ", ddlCategory.SelectedValue)
            End If
        End With
        Return sb.ToString
    End Function

    Protected Sub btnDelete_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim part_no As String = CType(CType(CType(sender, LinkButton).NamingContainer, GridViewRow).FindControl("lblPartNo"), Label).Text
        dbUtil.dbExecuteNoQuery("MY", String.Format("delete from my_viewed_list where page_type='{0}' and user_id='{1}' and data_value='{2}'", MyLog.PageType.WishList.ToString, Session("user_id"), part_no))
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            CType(e.Row.FindControl("imgPic"), Image).ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + DataBinder.Eval(e.Row.DataItem, "image_id").ToString
            Dim model_no As String = DataBinder.Eval(e.Row.DataItem, "model_no").ToString
            If DataBinder.Eval(e.Row.DataItem, "IMAGE_ID") = "" Then
                Dim obj As Object = dbUtil.dbExecuteScalar("My", String.Format("select isnull(TUMBNAIL_IMAGE_ID,'') from PIS_SIEBEL_PRODUCT where part_no ='{0}' and type='model'", model_no))
                If obj IsNot Nothing Then
                    CType(e.Row.FindControl("imgPic"), Image).ImageUrl = "http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + obj.ToString
                End If
            End If
            Dim lbThumbnail As Label = CType(e.Row.FindControl("lblThumbnail"), Label)
            Dim literatures() As String = DataBinder.Eval(e.Row.DataItem, "literature").ToString.ToString.Replace("<lit>", ",").Split(",")
            For Each lit As String In literatures
                If lit.Trim.Replace("&nbsp;", "") <> "" Then
                    Try
                        lbThumbnail.Text += "<a href='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + lit.Split("|")(0) + "' rel='prettyPhoto[" + e.Row.RowIndex.ToString + "]'><img src='http://downloadt.advantech.com/download/downloadlit.aspx?lit_id=" + lit.Split("|")(0) + "' width='32' height='32' alt='" + lit.Split("|")(1).Replace("</lit>","") + "' style='border:1px; border-color:#CFCFCF; border-style:solid; margin-bottom:3px' /></a>&nbsp;&nbsp;"
                    Catch ex As Exception
                        
                    End Try
                End If
            Next
        End If
    End Sub
    
    <Services.WebMethod(EnableSession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPrice(ByVal PartNo As String) As String
        Dim RETPRICEDT As New DataTable
        SAPtools.getSAPPriceByTable(PartNo, 1, HttpContext.Current.Session("org_id"), HttpContext.Current.Session("company_id"), "", RETPRICEDT)
        Dim WSPTb As DataTable = RETPRICEDT
        Dim lp As Double = 0, up As Double = 0
        For Each r As DataRow In WSPTb.Rows
            up = FormatNumber(r.Item("Netwr"), 2).Replace(",", "")
            lp = FormatNumber(r.Item("Kzwi1"), 2).Replace(",", "")
            If up > lp Then lp = up
            If up > 0 Then
                If up < lp Then
                    Return "<font color='#fb6717'>Price : " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " <strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString() + "</font>"
                Else
                    Return "<font color='#fb6717'>Price : " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString() + "</font>"
                End If
                
            End If
        Next
        Return "TBD"
    End Function
    
    <Services.WebMethod(EnableSession:=True)> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetMultiPrice(ByVal PartNo As String) As String
        Dim strOrg As String = "", strCompId As String = ""
        If HttpContext.Current.Session("org_id") Is Nothing OrElse HttpContext.Current.Session("org_id").ToString() = "" Then
            strOrg = "TW01"
        Else
            strOrg = HttpContext.Current.Session("org_id")
        End If
        If HttpContext.Current.Session("company_id") Is Nothing OrElse HttpContext.Current.Session("company_id").ToString() = "" Then
            strCompId = ""
        Else
            strCompId = HttpContext.Current.Session("company_id")
        End If
        Dim dt As New DataTable
        dt.Columns.Add("part_no") : dt.Columns.Add("price")
        For Each pn As String In PartNo.Split("|")
            If pn <> "" Then
                Dim row As DataRow = dt.NewRow
                row.Item("part_no") = pn : row.Item("price") = "TBD"
                dt.Rows.Add(row)
            End If
        Next
        If HttpContext.Current.Session("company_id") IsNot Nothing AndAlso HttpContext.Current.Session("company_id").ToString() <> "" Then
            Dim pdt As DataTable = Util.GetMultiEUPrice(strCompId, strOrg, dt)
            If pdt IsNot Nothing Then
                Dim tmpPlant As String = Left(HttpContext.Current.Session("org_id"), 2) + "H1"
                For Each r As DataRow In dt.Rows
                    Dim part_no As String = "", lp As Double = 0, up As Double = 0
                    If Global_Inc.Format2SAPItem(Trim(UCase(r.Item("part_no")))) IsNot Nothing Then part_no = Global_Inc.Format2SAPItem(Trim(UCase(r.Item("part_no"))))
                    Dim rs() As DataRow = pdt.Select("Matnr='" + part_no + "'")
                    If rs.Length > 0 Then
                        If Double.TryParse(rs(0).Item("Netwr"), 0) AndAlso CDbl(rs(0).Item("Netwr")) > 0 Then
                            up = FormatNumber(rs(0).Item("Netwr"), 2).Replace(",", "")
                        End If
                        If Double.TryParse(rs(0).Item("Kzwi1"), 0) AndAlso CDbl(rs(0).Item("Kzwi1")) > 0 Then
                            lp = FormatNumber(rs(0).Item("Kzwi1"), 2).Replace(",", "")
                        End If
                        If up > lp Then
                            r.Item("price") = up.ToString
                        End If
                        If up > 0 Then
                            If up < lp Then
                                r.Item("price") = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " <strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                            Else
                                r.Item("price") = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + " " + up.ToString()
                            End If
                        End If
                    End If
                Next
                dt.AcceptChanges()
            End If
        End If
        Dim ret As String = ""
        For Each r As DataRow In dt.Rows
            ret += r.Item("price").ToString + "|"
        Next
        Return ret
    End Function
    
    Public Shared Function GetEUPrice(ByVal kunnr As String, ByVal org As String, ByVal matnr As String, ByVal sDate As Date) As DataTable
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
        With prec
            .Kunnr = kunnr : .Mandt = "168" : .Matnr = matnr.ToUpper() : .Mglme = 1 : .Prsdt = sDate.ToString("yyyyMMdd") : .Vkorg = org
        End With
        pin.Add(prec)
        'Next
        eup.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        eup.Connection.Open()
        Try
            eup.Z_Sd_Eupriceinquery("1", pin, pout)
        Catch ex As Exception
            eup.Connection.Close() : Return Nothing
        End Try
        eup.Connection.Close()
        Dim pdt As DataTable = pout.ToADODataTable()
        pdt.TableName = "EUPriceTable"
        Return pdt
    End Function

    Protected Sub ddlType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        FillCategory()
    End Sub
    
    Sub FillCategory()
        ddlCategory.Items.Clear()
        Dim sb As New StringBuilder
        With sb
            .AppendFormat(" select distinct type, count(distinct data_value) as counts from my_viewed_list where page_type='{0}' and user_id='{1}' ", MyLog.PageType.WishList.ToString, Session("user_id"))
            If ddlType.SelectedValue = "1" Then
                .AppendFormat(" and data_value in (select z.part_no from ESTORE_ORDER_LOG z where z.User_ID='{0}') ", Session("user_id"))
            ElseIf ddlType.SelectedValue = "2" Then
                .AppendFormat(" and data_value not in (select z.part_no from ESTORE_ORDER_LOG z where z.User_ID='{0}') ", Session("user_id"))
            End If
            .AppendFormat(" group by type order by type ")
        End With
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", sb.ToString)
        Dim count As Integer = 0
        For Each row As DataRow In dt.Rows
            ddlCategory.Items.Add(New ListItem(String.Format("{0}({1})", row.Item("type"), row.Item("counts")), row.Item("type")))
            count += CInt(row.Item("counts"))
        Next
        ddlCategory.Items.Insert(0, New ListItem(String.Format("All({0})", count.ToString), "0"))
    End Sub

    Public Sub PageIndexChanged(ByVal PageIndex As String)
        gv1.PageIndex = CInt(PageIndex) - 1
    End Sub

    Protected Sub btnP1_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP2_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP3_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP4_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP5_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP6_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub

    Protected Sub btnP7_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged(CType(sender, LinkButton).Text)
    End Sub
    
    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        Try
            If gv1.BottomPagerRow IsNot Nothing Then
                If gv1.PageIndex + 8 > gv1.PageCount Then
                    Dim MaxPageIndex As Integer = 0
                    Math.DivRem(gv1.PageCount, 7, MaxPageIndex)
                    For i As Integer = MaxPageIndex To 6
                        CType(gv1.BottomPagerRow.FindControl("btnP" + (i + 1).ToString), LinkButton).Visible = False
                    Next
                End If
                
                Dim quotient As Integer = Math.DivRem(gv1.PageIndex, 7, 0)
                For i As Integer = 0 To 6
                    CType(gv1.BottomPagerRow.FindControl("btnP" + (i + 1).ToString), LinkButton).Text = (quotient * 7) + i + 1
                Next
                Dim PageIndex As Integer = 0
                Math.DivRem(gv1.PageIndex, 7, PageIndex)
                Dim btn As LinkButton = CType(gv1.BottomPagerRow.FindControl("btnP" + (PageIndex + 1).ToString), LinkButton)
                btn.ForeColor = Drawing.Color.Black : btn.Font.Bold = True
                If gv1.PageIndex >= 7 Then CType(gv1.BottomPagerRow.FindControl("btnPre"), LinkButton).Visible = True
            End If
        Catch ex As Exception

        End Try
    End Sub
    
    Protected Sub btnNext_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged((gv1.PageIndex + 7 + 1).ToString)
    End Sub
    
    Protected Sub btnPre_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        PageIndexChanged((gv1.PageIndex - 7 + 1).ToString)
    End Sub

    Protected Sub btnBackMain_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Response.Redirect("~/home_ga.aspx")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
<script src="../Includes/jquery-1.11.1.min.js" type="text/javascript"></script> 
<script src="../Includes/jquery.prettyPhoto.js" type="text/javascript"></script> 
<link rel="stylesheet" type="text/css" href="../includes/prettyPhoto.css" />
<style type="text/css">
    #content #searchbar {
	    font-family: Arial, Helvetica, sans-serif;
	    font-size: 12px;
	    background-image: url(../images/search_bar.jpg);
	    background-repeat: no-repeat;
	    height: 40px;
	    margin-top: 10px;
	    background-position: left;
    }
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
    .red {
	    color: #F00;
	    font-weight: bold;
    }
    .PageButton 
    {
        color:#0032D0;
        border-width:1px;
        border-color:#CFCFCF;
        border-style:solid;
        background-color:#F7F7F7;
        font-style:normal;
        text-align:center;
        vertical-align:middle;
        display:table-cell;
        width:21px;
        height:25px;
    }
</style>
<script type="text/javascript" charset="utf-8">
    $(document).ready(function () {
        $("a[rel^='prettyPhoto']").prettyPhoto({
            social_tools: false,
            gallery_markup: '',
            slideshow: 2000
        });
        var pnlist = "";
        var pelist = "";
        labels = document.getElementsByTagName("a");
        for (var i = 0; i < labels.length; i++) {
            if (labels[i].id.indexOf("lbPrice_") !== -1) {
                var target = document.getElementById(labels[i].id);
                var pn = labels[i].id.replace("lbPrice_", "");
                //target.onclick = GetPrice(pn, document.getElementById(labels[i].id));
                pnlist += pn + "|";
                pelist += labels[i].id + "|";
            }
        }
        target.onclick = GetMultiPrice(pnlist, pelist);
    });
    function GetPrice(PN, PE) {
        PE.innerHTML = "<img style='border:0px;' alt='loading' src='../images/loading2.gif' />"; 
        PageMethods.GetPrice(PN, OnGetPriceComplete, OnGetPriceError, PE); 
    } 
    function OnGetPriceComplete(result, price, methodName) { 
        price.innerHTML = result; 
    } 
    function OnGetPriceError(error, userContext, methodName) { 
        if (error !== null) { 
            //alert(error.get_message()); 
        }
    }
    function GetMultiPrice(PN, PE) {
        PageMethods.GetMultiPrice(PN, OnGetMultiPriceComplete, OnGetMultiPriceError, PE); 
    }
    function OnGetMultiPriceComplete(result, price, methodName) {
        pn = price.split("|");
        pe = result.split("|");
        for (var i = 0; i < 5; i++) {
            document.getElementById(pn[i]).innerHTML = "<font color='#fb6717'>Price : " + pe[i] + "</font>";
        }
    }
    function OnGetMultiPriceError(error, userContext, methodName) {
        if (error !== null) {
            //alert(error.get_message()); 
        }
    }
</script>
<table>
    <tr>
        <td valign="top">
            <div id="navtext"><a style="color:Black" href="../home_ga.aspx">Home</a>> My Wish List</div>
            <div id="content">
                <div id="title">My Wish List</div>
                <div id="subtitle">This is a great place for you to store all the Advantech products that you really want while browsing our websites. <br />
                  To use this function, you must <a href="../home.aspx"><span class="red">log-in</span></a> or <a href="https://member.advantech.com/profile.aspx?lang=EN" target="_blank"><span class="red">register</span></a> to be a member of MyAdvantech.
                </div>
                <div id="searchbar">
                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                        <tr>
                            <td colspan="5" height="10">
                            </td>
                        </tr>
                        <tr>
                            <td align="center">
                                <table cellpadding="0">
                                    <tr>
                                        <td>
                                            <asp:UpdatePanel runat="server" ID="up2" UpdateMode="Conditional">
                                                <ContentTemplate>
                                                    <table cellpadding="0">
                                                        <tr>
                                                            <td>
                                                                Show:
                                                                <label for="select">
                                                                </label>
                                                                <asp:DropDownList runat="server" ID="ddlType" AutoPostBack="true" OnSelectedIndexChanged="ddlType_SelectedIndexChanged">
                                                                </asp:DropDownList>
                                                            </td>
                                                            <td width="5"></td>
                                                            <td>
                                                                Category:
                                                                <label for="select2">
                                                                </label>
                                                                <asp:DropDownList runat="server" ID="ddlCategory"></asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ContentTemplate>
                                            </asp:UpdatePanel>
                                        </td>
                                        <td width="5"></td>
                                        <td>
                                            <asp:ImageButton runat="server" ID="btnSearch" ImageUrl="~/Images/btn_go1.jpg" Width="27" Height="16" OnClick="btnSearch_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
                <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="true"  EnableTheming="false" ShowHeader="false" 
                    ShowFooter="false" BorderWidth="0" BorderColor="White" RowStyle-Width="0" PageSize="5" DataSourceID="sql1" Width="100%" OnRowDataBound="gv1_RowDataBound" OnDataBound="gv1_DataBound">
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <div id="productset">
                                    <table width="680" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="680" bgcolor="#CCCCCC">
                                                <table width="680" border="0" cellspacing="1" cellpadding="0">
                                                    <tr>
                                                        <td width="20" height="222" bgcolor="#E4E4E4" class="bold">
                                                            <%# Container.DataItemIndex + 1 %>
                                                        </td>
                                                        <td width="665" valign="top" bgcolor="#FFFFFF">
                                                            <table width="666" border="0" cellspacing="0" cellpadding="0">
                                                                <tr>
                                                                    <td width="234">
                                                                        <asp:image runat="server" ID="imgPic" width="220" height="220" />
                                                                    </td>
                                                                    <td width="432" valign="top">
                                                                        <table width="418" border="0" cellspacing="0" cellpadding="0">
                                                                            <tr>
                                                                                <td height="10">
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td width="418" class="producttitle">
                                                                                    <a href='../Product/Model_Detail.aspx?model_no=<%#Eval("model_no") %>' target="_blank"><asp:Label runat="server" ID="lblPartNo" Text='<%#Eval("data_value") %>' ForeColor="#3fb2e2" /></a>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <%# Eval("model_desc")%>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td width="70px" runat="server" id="tdPrice" class="price"><a href="javascript:GetPrice('<%#Eval("data_value") %>',document.getElementById('lbPrice_<%#Eval("data_value") %>'))" id='lbPrice_<%#Eval("data_value") %>'><img style='border:0px;' alt='loading' src='../images/loading2.gif' /></a></td>
                                                                            </tr>
                                                                            <tr>
                                                                                <%--<td>
                                                                                    • 6 differential channels<br />
                                                                                    • 16-bit effective resolution<br />
                                                                                    • Isolation Voltage: 2,000 VDC<br />
                                                                                    • Sampling Rate: 10 samples/sec.
                                                                                </td>--%>
                                                                                <td>
                                                                                    <%# Replace(Eval("feature_desc"), "FEATURE_DESC", "li")%>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td>
                                                                        <table width="220" border="0" cellspacing="0" cellpadding="0">
                                                                            <tr>
                                                                                <td width="10"></td>
                                                                                <td>
                                                                                    <asp:Label runat="server" ID="lblThumbnail" />
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td colspan="2" align="center" height="15">
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td>
                                                                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                            <tr>
                                                                                <td width="26%">
                                                                                    <img src="../images/btn_add-quote.jpg" width="103" height="29" />
                                                                                </td>
                                                                                <td width="24%">
                                                                                    <img src="../images/btn_add-cart.jpg" width="97" height="29" />
                                                                                </td>
                                                                                <td width="50%">
                                                                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                                        <tr>
                                                                                            <td width="12%">
                                                                                                <img src="../images/btn_delete.jpg" width="26" height="22" />
                                                                                            </td>
                                                                                            <td width="88%">
                                                                                                <asp:LinkButton runat="server" ID="btnDelete" Text="Delete this Item" CssClass="blue" OnClick="btnDelete_Click" />
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerTemplate>
                        <table width="100%">
                            <tr>
                                <td align="center">
                                    <table>
                                        <tr>
                                            <td width="30">&nbsp;</td>
                                            <td><asp:LinkButton runat="server" ID="btnPre" cssClass="blue" Text="Previous Page" OnClick="btnPre_Click" Visible="false" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnP1" CssClass="PageButton" OnClick="btnP1_Click" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnP2" CssClass="PageButton" OnClick="btnP2_Click" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnP3" CssClass="PageButton" OnClick="btnP3_Click" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnP4" CssClass="PageButton" OnClick="btnP4_Click" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnP5" CssClass="PageButton" OnClick="btnP5_Click" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnP6" CssClass="PageButton" OnClick="btnP6_Click" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnP7" CssClass="PageButton" OnClick="btnP7_Click" /></td>
                                            <td><asp:LinkButton runat="server" ID="btnNext" cssClass="blue" Text="Next Page" OnClick="btnNext_Click" /></td>
                                            <td><asp:ImageButton runat="server" ID="btnBackMain" ImageUrl="~/images/btn_back.jpg" width="160" height="31" OnClick="btnBackMain_Click" /></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </PagerTemplate>
                    <PagerStyle BorderWidth="0" BorderColor="White" />
                    <RowStyle BorderColor="White" BorderWidth="0" />
                </asp:GridView>
                <asp:SqlDataSource runat="server" ID="sql1" ConnectionString="<%$ connectionStrings: MY %>"
                    SelectCommand="" OnLoad="sql1_Load">
                </asp:SqlDataSource>
            </div>
        </td>
        <td valign="top">
            <uc1:GAContactBlocak runat="server" ID="ucGAContactBlock" />
        </td>
    </tr>
</table>
</asp:Content>

