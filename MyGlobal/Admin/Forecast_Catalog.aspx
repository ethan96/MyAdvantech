<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Forecast Catalog" %>

<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'If Session("user_id") IsNot Nothing AndAlso Util.IsInternalUser(Session("user_id")) Then         
        'Else
        '    Tab1.Visible = True
        '    HyperLink1.NavigateUrl = Request.UrlReferrer.ToString
        '    Tab2.Visible = False
        '    Exit Sub
        'End If
        btnSave.Attributes.Add("onclick", "this.disabled=true;" + Page.ClientScript.GetPostBackEventReference(btnSave, ""))
        If Not Page.IsPostBack Then
            If Util.IsAEUIT() Or Util.IsInternalUser(Session("user_id")) Then
                trSum.Visible = True : trNew.Visible = True
            Else
                'trSum.Visible = False : trNew.Visible = False
                Response.Redirect(Request.ApplicationPath) 'ICC 2016/3/23 This page cannot be accessed by outer user.
            End If
        End If
    End Sub

    Protected Sub gv1_RowDataBoundDataRow(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If LCase(Session("user_id")) <> LCase(DataBinder.Eval(e.Row.DataItem, "OWNER_EMAIL").ToString) AndAlso _
                LCase(Session("user_id")) <> LCase(DataBinder.Eval(e.Row.DataItem, "CREATED_BY").ToString) AndAlso Util.IsAdmin() = False Then
                CType(e.Row.Cells(0).Controls(0), LinkButton).ForeColor = Drawing.Color.Gray : CType(e.Row.Cells(0).Controls(0), LinkButton).Enabled = False
                CType(e.Row.Cells(0).Controls(2), LinkButton).ForeColor = Drawing.Color.Gray : CType(e.Row.Cells(0).Controls(2), LinkButton).Enabled = False
            End If
            If CType(e.Row.Cells(6).FindControl("hlOwner"), HyperLink) IsNot Nothing Then
                CType(e.Row.Cells(6).FindControl("hlOwner"), HyperLink).Text = DataBinder.Eval(e.Row.DataItem, "OWNER").ToString.Replace(";", "; ")
                CType(e.Row.Cells(6).FindControl("hlOwner"), HyperLink).NavigateUrl = "mailto:" + DataBinder.Eval(e.Row.DataItem, "OWNER_EMAIL").ToString
                Dim rpn As String = CType(e.Row.FindControl("hd_PN"), HiddenField).Value
                'Dim lbPrice As Label = e.Row.FindControl("lbPrice")
                'lbPrice.Text = "TBD"
                'If Trim(rpn) <> "" Then
                '    Dim dt As DataTable = PricingUtil.GetProductsTableDef(), err As String = ""
                '    Dim r As DataRow = dt.NewRow()
                '    r.Item("PartNo") = rpn : r.Item("Qty") = 1 : dt.Rows.Add(r)
                '    Dim rdt As DataTable = PricingUtil.GetMultiPrice("TW01", "UUAASC", dt, err)
                '    'lbPrice.Text = rpn
                '    If rdt IsNot Nothing AndAlso rdt.Rows.Count > 0 _
                '        AndAlso Trim(err) = "" AndAlso Double.TryParse(rdt.Rows(0).Item("Netwr"), 0) _
                '        AndAlso CDbl(rdt.Rows(0).Item("Netwr")) > 0 Then
                '        lbPrice.Text = "$" + rdt.Rows(0).Item("Netwr").ToString()
                '    End If
                '    'e.Row.Cells(7).Visible = Util.IsInternalUser2()
                'End If
                If Trim(rpn) = "" Then
                    e.Row.Cells(7).Text = "TBD"
                End If
            End If
        End If
    End Sub
    
    Protected Sub Updating(ByVal s As Object, ByVal e As GridViewUpdateEventArgs) Handles gv1.RowUpdating
        Dim tmprow As GridViewRow = gv1.Rows(e.RowIndex)
        sqlCatalogList.UpdateParameters.Item("DATE").DefaultValue = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtRowEditDate"), TextBox).Text)
        sqlCatalogList.UpdateParameters.Item("OWNER").DefaultValue = HttpUtility.HtmlEncode(CType(tmprow.FindControl("txtOwner"), TextBox).Text)
    End Sub

    Protected Sub btnClear_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        For i As Integer = 0 To gv1.Rows.Count - 1
            If Util.IsAEUIT() Or Util.IsInternalUser(Session("user_id")) Then
                CType(gv1.Rows(i).Cells(1).FindControl("chkItem"), CheckBox).Checked = False
                CType(gv1.Rows(i).Cells(5).FindControl("txtQty"), TextBox).Text = "0"
            Else
                CType(gv1.Rows(i).Cells(0).FindControl("chkItem"), CheckBox).Checked = False
                CType(gv1.Rows(i).Cells(4).FindControl("txtQty"), TextBox).Text = "0"
            End If
        Next
    End Sub

    Private Shared Function NewId(ByVal db As String) As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MY", "select count(ROW_ID) as counts from " + db + " where ROW_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    
    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") IsNot Nothing Or Not IsDBNull(Session("user_id")) Then
            Dim isCheck As Boolean = False
            For i As Integer = 0 To gv1.Rows.Count - 1
                If Util.IsAEUIT() Or Util.IsInternalUser(Session("user_id")) Then
                    If CType(gv1.Rows(i).Cells(1).FindControl("chkItem"), CheckBox).Checked Then isCheck = True
                Else
                    If CType(gv1.Rows(i).Cells(0).FindControl("chkItem"), CheckBox).Checked Then isCheck = True
                End If
            Next
            If isCheck = False Then
                'Util.AjaxJSAlert(up1, "Please select at least one catalog.")
                Util.JSAlert(Me.Page, "Please select at least one catalog.")
                btnSave.Enabled = True : Exit Sub
            Else
                Dim mailbody As String = "<table border='1'><tr><td align='center'><b>Item</b></td><td align='center'><b>Qty</b></td></tr>"
                Dim arrMailCC As New ArrayList
                For i As Integer = 0 To gv1.Rows.Count - 1
                    If CType(gv1.Rows(i).Cells(1).FindControl("chkItem"), CheckBox).Checked Then
                        Dim sb As New StringBuilder
                        sb.AppendFormat("<Catalog id=""{0}"">", gv1.DataKeys(i).Values("ROW_ID").ToString) : mailbody += "<tr>"
                        sb.AppendFormat("<part_no>{0}</part_no>", gv1.Rows(i).Cells(2).Text.Replace("&nbsp;", ""))
                        sb.AppendFormat("<description>{0}</description>", gv1.Rows(i).Cells(3).Text.Replace("&nbsp;", "").Replace(" ", "@")) : mailbody += "<td>" + gv1.Rows(i).Cells(3).Text.Replace("&nbsp;", "") + "</td>"
                        sb.AppendFormat("<date>{0}</date>", CType(gv1.Rows(i).Cells(4).FindControl("lblRowDate"), Label).Text.Replace("&nbsp;", ""))
                        sb.AppendFormat("<qty>{0}</qty>", IIf(CInt(CType(gv1.Rows(i).Cells(5).FindControl("txtQty"), TextBox).Text) = 0, 1, CInt(CType(gv1.Rows(i).Cells(5).FindControl("txtQty"), TextBox).Text))) : mailbody += "<td align='center'>" + IIf(CInt(CType(gv1.Rows(i).Cells(5).FindControl("txtQty"), TextBox).Text) = 0, "1", CInt(CType(gv1.Rows(i).Cells(5).FindControl("txtQty"), TextBox).Text).ToString) + "</td>"
                        sb.AppendFormat("</Catalog>")
                        mailbody += "</tr>"
                        Dim MailTo As String() = gv1.DataKeys(i).Values("OWNER_EMAIL").ToString.Replace("&nbsp;", "").Split(";")
                        For j As Integer = 0 To MailTo.Length - 1
                            If Not arrMailCC.Contains(MailTo(j).Trim()) Then arrMailCC.Add(MailTo(j).Trim())
                        Next
                        If Session("RBU") IsNot Nothing AndAlso Session("RBU") = "HQDC" Then arrMailCC.Add("Liliana.Wen@advantech.com.tw")
                        dbUtil.dbExecuteNoQuery("My", String.Format("insert into FORECAST_CATALOG_HISTORY_NEW (USER_ID,DATE,CATALOG_ID,PART_NO,DESCRIPTION,AVAILABLE_DATE,QTY,ROW_ID) values ('{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}')", Session("user_id"), Now, gv1.DataKeys(i).Values("ROW_ID").ToString, gv1.Rows(i).Cells(2).Text.Replace("&nbsp;", ""), gv1.Rows(i).Cells(3).Text.Replace("&nbsp;", "").Replace("&amp;", "&"), CType(gv1.Rows(i).Cells(4).FindControl("lblRowDate"), Label).Text.Replace("&nbsp;", ""), IIf(CInt(CType(gv1.Rows(i).Cells(5).FindControl("txtQty"), TextBox).Text) = 0, 1, CInt(CType(gv1.Rows(i).Cells(5).FindControl("txtQty"), TextBox).Text)), NewId()))
                        'dbUtil.dbExecuteNoQuery("My", String.Format("update forecast_catalog_history_new set detail.modify('insert {0} into (/Catalogs)[last()]') where row_id='{1}'", sb.ToString, row_id))
                    End If
                Next
                mailbody += "</table>"
                'Util.AjaxJSAlert(up1, "This record is created successfully.")
                Util.JSAlert(Page, "This record has been created successfully.")
                SendMail(mailbody, arrMailCC)
            End If
        Else
            'Util.AjaxJSAlert(up1, "Session timeout. Please login in MyAdvantech again.")
            Util.JSAlert(Me.Page, "Session timeout. Please login in MyAdvantech again.")
        End If
        btnSave.Enabled = True
    End Sub
    
    Private Sub SendMail(ByVal mailbody As String, ByVal MailCC As ArrayList)
        Try
            Dim body As String
            body = "Dears,<br/><br/>" + _
                   "We have received your catalog and brochure order forecast as shown below.<br/><br/>" + _
                   "If there is any modification, please access <a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "/Admin/Forecast_Catalog_Summary.aspx'>MyAdvantech Catalog Forecast Webpage</a><br/><br/>" + _
                   "Company ID : " + Session("company_id") + "<br/>" + _
                   "Company Name : " + Session("company_name") + "<br/><br/>" + _
                    mailbody + _
                    "<br/><br/>" + _
                    "Please note that you still have to place an official purchase order via your OP.<br/>" + _
                    "Advantech will inform you when all the catalogs are ready to order. Please request your OP to place the order through either the B2B system or in a traditional way, such as fax. No catalogs will be shipped to you without your official purchase order.<br/>" + _
                    "<br/><br/>Best Regards,<br/><a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "'>MyAdvantech</a>"
            Util.SendEmail(Session("user_id"), "myadvantech@advantech.com", "New Forecast Catalog Request", body, True, String.Join(",", MailCC.ToArray()), "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw")
        Catch ex As Exception
            Dim body As String
            body = "Dears,<br/><br/>" + _
                   "We have received your catalog and brochure order forecast as shown below.<br/><br/>" + _
                   "If there is any modification, please access <a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "/Admin/Forecast_Catalog_Summary.aspx'>MyAdvantech Catalog Forecast Webpage</a><br/><br/>" + _
                   "Company ID : " + Session("company_id") + "<br/>" + _
                   "Company Name : " + Session("company_name") + "<br/><br/>" + _
                    mailbody + _
                    "<br/><br/>" + _
                    "Please note that you still have to place an official purchase order via your OP.<br/>" + _
                    "Advantech will inform you when all the catalogs are ready to order. Please request your OP to place the order through either the B2B system or in a traditional way, such as fax. No catalogs will be shipped to you without your official purchase order.<br/>" + _
                    "<br/><br/>Best Regards,<br/><a href='http://" + Request.ServerVariables("HTTP_HOST").ToString + "'>MyAdvantech</a>"
            Util.SendEmail(HttpContext.Current.User.Identity.Name, "myadvantech@advantech.com", "New Forecast Catalog Request", body, True, String.Join(",", MailCC.ToArray()), "rudy.wang@advantech.com.tw,tc.chen@advantech.com.tw")
        End Try
        
    End Sub
    
    Private Function NewId() As String
        Dim tmpRowId As String = ""
        Do While True
            tmpRowId = System.Guid.NewGuid.ToString().Replace("-", "").Substring(0, 10)
            If CInt( _
              dbUtil.dbExecuteScalar("MY", "select count(ROW_ID) as counts from FORECAST_CATALOG_HISTORY_NEW where ROW_ID='" + tmpRowId + "'") _
               ) = 0 Then
                Exit Do
            End If
        Loop
        Return tmpRowId
    End Function
    
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
                    Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + "<strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + up.ToString()
                Else
                    Return HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + up.ToString()
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
                                r.Item("price") = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + "<strike>" + lp.ToString() + "</strike> " + HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + up.ToString()
                            Else
                                r.Item("price") = HttpContext.Current.Session("COMPANY_CURRENCY_SIGN") + up.ToString()
                            End If
                        Else
                            r.Item("price") = "TBD"
                        End If
                    Else
                        r.Item("price") = "TBD"
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

    Protected Sub btnView_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim gr As GridViewRow = CType(CType(sender, LinkButton).NamingContainer, GridViewRow)
        gr.FindControl("tbPacking").Visible = True
        Dim body As Label = CType(gr.FindControl("lblBody"), Label)
        body.Text = "<table><tr><td align='center' colspan='2'><img width='200' src='../Includes/GetThumbnail.ashx?RowId=" + gv1.DataKeys(gr.RowIndex).Values("ROW_ID").ToString + "&Type=Catalog' /></td></tr>" + _
            "<tr><td colspan='2' height='10'></td></tr>" + _
            "<tr><th align='left'>Pages: </th><td>" + gv1.DataKeys(gr.RowIndex).Values("PAGE").ToString + "</td></tr>" + _
            "<tr><th align='left'>Dimensions: </th><td>" + gv1.DataKeys(gr.RowIndex).Values("DIMENSION").ToString + "</td></tr>" + _
            "<tr><th align='left'>Weight: </th><td>" + gv1.DataKeys(gr.RowIndex).Values("WEIGHT").ToString + "</td></tr>" + _
            "<tr><th align='left'>Packing: </th><td>" + gv1.DataKeys(gr.RowIndex).Values("PIECE").ToString + "</td></tr>" + _
            "<tr><th align='left'>Carton (L x W x H): </th><td>" + gv1.DataKeys(gr.RowIndex).Values("CARTON").ToString + "</td></tr>" + _
            "<tr><th align='left'>Special Note: </th><td>" + gv1.DataKeys(gr.RowIndex).Values("NOTE").ToString + "</td></tr>" + _
            "<tr><td colspan='2' height='10'></td></tr></table>"
        CType(gr.FindControl("ModalPopupExtender1"), ModalPopupExtender).Show()
    End Sub
    
    Protected Sub btnClose_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim gr As GridViewRow = CType(CType(sender, LinkButton).NamingContainer, GridViewRow)
        gr.FindControl("tbPacking").Visible = False
        CType(gr.FindControl("ModalPopupExtender1"), ModalPopupExtender).Hide()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
<script src="../Includes/jquery-1.11.1.min.js" type="text/javascript"></script> 
<script type="text/javascript" charset="utf-8">
    $(document).ready(function () {
        var pnlist = "";
        var pelist = "";
        labels = document.getElementsByTagName("a");
        for (var i = 0; i < labels.length; i++) {
            if (labels[i].id.indexOf("lbPrice_") !== -1) {
                var target = document.getElementById(labels[i].id);
                var pn = labels[i].id.replace("lbPrice_", "");
                //target.onclick = GetPrice(pn, document.getElementById(labels[i].id));
                if (pn != "") {
                    pnlist += pn + "|";
                    pelist += labels[i].id + "|";
                }
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
        for (var i = 0; i < pn.length-1; i++) {
            document.getElementById(pn[i]).innerHTML = pe[i];
        }
    }
    function OnGetMultiPriceError(error, userContext, methodName) {
        if (error !== null) {
            //alert(error.get_message()); 
        }
    }
</script>
    <table width="50%" border="0" height="200" align="center" id="Tab1" runat="server"
        visible="false">
        <tr>
            <td>
                Your user account may not have sufficient privileges to access this page,
                <asp:HyperLink ID="HyperLink1" Font-Underline="true" runat="server" ForeColor="Red"
                    Font-Size="Large">Back</asp:HyperLink>.
            </td>
        </tr>
    </table>
    <table width="100%" id="Tab2" runat="server">
        <tr>
            <td height="5">
            </td>
        </tr>
        <tr>
            <td>
                <div class="euPageTitle">
                    Catalog Forecast</div>
            </td>
        </tr>
        <tr>
            <td height="5">
            </td>
        </tr>
        <tr>
            <td>
                <table width="100%" height="380" border="0">
                    <tr>
                        <td width="20%" valign="top">
                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td height="24" class="menu_title">
                                        <asp:Literal ID="LiT3" runat="server">Advantech Catalog</asp:Literal>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0" class="login">
                                            <tr>
                                                <td width="5%" height="10">
                                                </td>
                                                <td>
                                                </td>
                                            </tr>
                                            <tr runat="server" id="trNew">
                                                <td height="25">
                                                </td>
                                                <td>
                                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                            <td width="5%" valign="top">
                                                                <img src="../Images/point_02.gif" alt="" width="7" height="14" />
                                                            </td>
                                                            <td class="menu_title02">
                                                                <asp:HyperLink runat="server" ID="hlNew" NavigateUrl="~/Admin/Forecast_Catalog_Create.aspx"
                                                                    Text="Create New Catalog" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr runat="server" id="tr1">
                                            <td height="25"></td>
                                            <td>
                                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td width="5%" valign="top"><img src="../Images/point_02.gif" alt="" width="7" height="14"/></td>
                                                        <td class="menu_title02">
                                                            <asp:HyperLink runat="server" ID="hlMyList" NavigateUrl="~/Admin/Forecast_Catalog_MyList.aspx" Text="My Forecast List" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                            </tr>
                                            <tr runat="server" id="trSum">
                                                <td height="25">
                                                </td>
                                                <td>
                                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                        <tr>
                                                            <td width="5%" valign="top">
                                                                <img src="../Images/point_02.gif" alt="" width="7" height="14" />
                                                            </td>
                                                            <td class="menu_title02">
                                                                <asp:HyperLink runat="server" ID="hlSum" NavigateUrl="~/Admin/Forecast_Catalog_Summary.aspx"
                                                                    Text="Catalog Forecast Summary" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td width="5%" height="10">
                                                </td>
                                                <td>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top" width="80%">
                            <table width="100%" border="0">
                                <tr>
                                    <td>
                                        <%--<asp:UpdatePanel runat="server" ID="up1">
                                            <ContentTemplate>--%>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowPaging="true"
                                                                PageSize="10" ShowWhenEmpty="true" PagerSettings-Position="TopAndBottom" DataSourceID="sqlCatalogList"
                                                                DataKeyNames="ROW_ID,OWNER_EMAIL,PAGE,DIMENSION,WEIGHT,PIECE,CARTON,NOTE" OnRowDataBoundDataRow="gv1_RowDataBoundDataRow">
                                                                <CaptionTemplate>
                                                                    <table width="100%" style="background-color: #FFFFCC">
                                                                        <tr>
                                                                            <td>
                                                                                Brochure
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </CaptionTemplate>
                                                                <Columns>
                                                                    <asp:CommandField ButtonType="Link" ShowEditButton="true" ShowDeleteButton="true" />
                                                                    <asp:TemplateField HeaderText="Forecast" ItemStyle-Width="30" ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <asp:CheckBox runat="server" ID="chkItem" />
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:CheckBox runat="server" ID="chkEditItem" Enabled="false" />
                                                                        </EditItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:BoundField DataField="part_no" HeaderText="Part NO" ItemStyle-Width="100" ControlStyle-Width="80" />
                                                                    <asp:BoundField DataField="description" HeaderText="Item" ItemStyle-Width="270" ControlStyle-Width="180" />
                                                                    <asp:TemplateField HeaderText="Available Date" ItemStyle-Width="80" ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <asp:Label runat="server" ID="lblRowDate" Text='<%#Eval("available_date") %>' />
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:TextBox runat="server" ID="txtRowEditDate" Text='<%#Eval("available_date") %>'
                                                                                Width="80px" />
                                                                            <ajaxToolkit:CalendarExtender runat="server" ID="ceEditDate" TargetControlID="txtRowEditDate"
                                                                                Format="yyyy/MM/dd" />
                                                                        </EditItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Qty">
                                                                        <ItemTemplate>
                                                                            <asp:TextBox runat="server" ID="txtQty" Text="0" Width="40" />&nbsp;pcs
                                                                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="ftbeQty" TargetControlID="txtQty"
                                                                                FilterMode="ValidChars" FilterType="Numbers" />
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:TextBox runat="server" ID="txtEditQty" Text="0" Width="40" Enabled="false" BackColor="GrayText" />&nbsp;pcs
                                                                        </EditItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Owner">
                                                                        <ItemTemplate>
                                                                            <asp:HyperLink runat="server" ID="hlOwner" NavigateUrl='mailto:<%#Eval("owner_email") %>'
                                                                                Text='<%#Eval("owner") %>' />
                                                                        </ItemTemplate>
                                                                        <EditItemTemplate>
                                                                            <asp:TextBox runat="server" ID="txtOwner" Text='<%#Eval("owner") %>' />
                                                                        </EditItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Price">
                                                                        <ItemTemplate>
                                                                            <asp:HiddenField runat="server" ID="hd_PN" Value='<%#Eval("part_no") %>' />
                                                                            <a href="javascript:GetPrice('<%#Eval("part_no") %>',document.getElementById('lbPrice_<%#Eval("part_no") %>'))" id='lbPrice_<%#Eval("part_no") %>'><img style='border:0px;' alt='loading' src='../images/loading2.gif' /></a>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                    <asp:TemplateField HeaderText="Packing Info." ItemStyle-HorizontalAlign="Center">
                                                                        <ItemTemplate>
                                                                            <asp:UpdatePanel runat="server" ID="upPacking" UpdateMode="Conditional">
                                                                                <ContentTemplate>
                                                                                    <asp:LinkButton runat="server" ID="btnView" Text="View" OnClick="btnView_Click" />
                                                                                    <asp:LinkButton runat="server" ID="link1" />
                                                                                    <ajaxToolkit:ModalPopupExtender runat="server" ID="ModalPopupExtender1" BehaviorID="modalPopup1" PopupControlID="Panel1" 
                                                                                        PopupDragHandleControlID="Panel1" TargetControlID="link1" Y="200" BackgroundCssClass="modalBackground">
                                                                                    </ajaxToolkit:ModalPopupExtender>
                                                                                    <asp:Panel runat="server" ID="Panel1">
                                                                                        <table width="100%" runat="server" id="tbPacking" visible="false" style="background-color:White">
                                                                                            <tr><td align="center"><asp:LinkButton runat="server" ID="btnClose" Text="[Close]" Width="30" OnClick="btnClose_Click" /></td></tr>
                                                                                            <tr><td height="5"></td></tr>
                                                                                            <tr><td><asp:Label runat="server" ID="lblBody" /></td></tr>
                                                                                        </table>
                                                                                    </asp:Panel>
                                                                                </ContentTemplate>
                                                                            </asp:UpdatePanel>
                                                                        </ItemTemplate>
                                                                    </asp:TemplateField>
                                                                </Columns>
                                                            </sgv:SmartGridView>
                                                            <asp:SqlDataSource runat="server" ID="sqlCatalogList" ConnectionString="<%$ connectionStrings:MY %>"
                                                                SelectCommand="SELECT ROW_ID, IsNull(PART_NO,'') as PART_NO, DESCRIPTION, AVAILABLE_DATE, OWNER, OWNER_EMAIL, WWW_ECATALOG, '' AS Qty, isnull(CREATED_BY,'') as CREATED_BY, isnull(page,'') as page, isnull(dimension,'') as dimension, isnull(weight,'') as weight, isnull(piece,'') as piece, isnull(carton,'') as carton, isnull(note,'') as note FROM FORECAST_CATALOG_LIST where is_disabled=0 ORDER BY AVAILABLE_DATE DESC, CREATED_DATE"
                                                                DeleteCommand="update forecast_catalog_list set is_disabled=1 where row_id = @ROW_ID" UpdateCommand="update forecast_catalog_list set part_no=@PART_NO, description=@DESCRIPTION, available_date=@DATE, owner=@OWNER where row_id=@ROW_ID">
                                                                <UpdateParameters>
                                                                    <asp:Parameter Name="DATE" Type="String" />
                                                                    <asp:Parameter Name="OWNER" Type="String" />
                                                                </UpdateParameters>
                                                            </asp:SqlDataSource>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td align="center">
                                                            <asp:Button runat="server" ID="btnSave" Text="Submit" OnClick="btnSave_Click" />
                                                            &nbsp;&nbsp;&nbsp;
                                                            <asp:Button runat="server" ID="btnClear" Text="Reset" OnClick="btnClear_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            <%--</ContentTemplate>
                                        </asp:UpdatePanel>--%>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>
