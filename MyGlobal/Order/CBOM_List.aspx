<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" ValidateRequest="false" EnableEventValidation="false" Title="MyAdvantech - CBOM List" %>

<%@ Register Src="../Includes/ChangeCompany.ascx" TagName="ChangeCompany" TagPrefix="uc1" %>
<script runat="server">
    Dim T_strselect As String = "", T_strWhere As String = ""
    Dim flg As Boolean = False
    Dim StrCompany As String = ""
    Dim org As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        'Response.Write(Session("account_status"))
        If User.Identity.IsAuthenticated = False Then
            Response.Redirect("~/home.aspx")
        End If
        'If Request("CompanyID") <> "" And Not Page.IsPostBack And UCase(StrCompany) <> UCase(Request("CompanyID")) Then
        '    Me.chgCompany.TargetCompanyId = Request("CompanyID")
        '    Me.chgCompany.ChangeToCompanyId()
        'End If       

        StrCompany = Session("Company_id") : org = Left(Session("Org_id"), 2)

        '20130725 TC: For MX01 show TW CBOM
        'Frank 2012/09/24: If org id starts with JP then display the CBOM list of TW org
        '20150401 TC: AJP wants to see TW's CBOM directly (per Jack.Tsao's request)
        If org.Equals("JP", StringComparison.InvariantCultureIgnoreCase) _
            OrElse org.Equals("MY", StringComparison.InvariantCultureIgnoreCase) _
            OrElse org.Equals("MX", StringComparison.InvariantCultureIgnoreCase) _
            OrElse org.Equals("SG", StringComparison.InvariantCultureIgnoreCase) Then org = "TW"

        Dim strMFGCompanyID = UCase(StrCompany)
        _CatalogType = _CatalogType.Trim
        If _CatalogType <> "CTOS" Then
            If _CatalogType = "Pre-Configuration" Then
                T_strselect = " select distinct '' as SNO,last_updated_by as CATALOG_NAME,a.CATALOG_ID,a.CATALOG_DESC,CATALOG_NAME as IMAGE_ID2,ISNULL((SELECT TOP 1 PARENT_CATEGORY_ID  FROM CBOM_CATALOG_CATEGORY WHERE PARENT_CATEGORY_ID=a.CATALOG_NAME and ORG='" & org.ToString.ToUpper & "' ),a.CATALOG_ID) AS IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                          " from CBOM_CATALOG a " &
                          " where a.Catalog_Org='" & org.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & _CatalogType & "'"
                T_strWhere = ""
            Else
                Dim ac As String = "GA"
                If Not IsNothing(Session("account_status")) Then
                    ac = Session("account_status")
                End If
                If org.ToUpper = "US" And _CatalogType = "Industrial PC (IPC)" And (ac = "GA" Or Session("user_id").ToString.ToLower = "nada.liu@advantech.com.cn") Then
                    Me.rdFilter.Visible = True
                    T_strselect = " select distinct '' as SNO,a.CATALOG_ID,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED, b.seq " & _
                         " from CBOM_CATALOG a inner join CBOM_IPC_TYPE b on a.catalog_id=b.category_id " & _
                         " where a.Catalog_Org='" & org.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & _CatalogType & "' and b.category_type='" & Me.rdFilter.SelectedValue & "' order by b.seq asc"
                    T_strWhere = ""

                Else
                    If _CatalogType = "eStoreBTO" AndAlso Session("org_id") IsNot Nothing AndAlso Session("org_id").ToString.Trim = "US01" Then
                        'If Session("user_id").ToString.Trim  <> "ming.zhao@advantech.com.cn" Then
                        Response.Redirect("./CBOM_eStoreBTO_List1.aspx")
                        'End If
                        T_strselect = " select distinct '' as SNO,a.CATALOG_ID,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                        " from CBOM_CATALOG a " &
                        " where a.Catalog_Org='" & org.ToString.ToUpper & "' and Created_by='EZ'"
                        T_strWhere = ""
                    Else
                        'Ryan 20170210 Only US01 will not need to check BTOS is phased in or not,
                        '              else org will inner join status orderable table to hide non phased in BTOS 
                        If org.ToUpper = "US" Then
                            'Ryan 20180425 US10 special case applied
                            If Session("Org_id").ToString.ToUpper = "US10" Then
                                T_strselect = " select distinct '' as SNO,a.CATALOG_ID,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                                     " from CBOM_CATALOG a " &
                                     " where a.Catalog_Org = '" & org.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & _CatalogType & "'" &
                                     " and a.CATALOG_ID IN ('UNO-2271G-BTO','UNO-2372G-BTO','UNO-2484G-BTO','UNO-1372GH-BTO','UNO-1372G-BTO','UNO-2184G-BTO','UNO-2272G-BTO','UNO-2362-BTO','UNO-3085G-BTO')"
                                T_strWhere = ""
                                T_strselect += " and CATALOG_ID <>'CPU-CARD-BTO' "
                            Else
                                T_strselect = " select distinct '' as SNO, a.CATALOG_ID, a.CATALOG_NAME, a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                                      " from CBOM_CATALOG a " &
                                      " where a.Catalog_Org = '" & org.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & _CatalogType & "'"
                                T_strWhere = ""
                                T_strselect += " and CATALOG_ID <>'CPU-CARD-BTO'"
                            End If
                        Else
                            T_strselect = " select distinct '' as SNO,a.CATALOG_ID,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly, '' as COMPANY_ID , a.CREATED " &
                                  " from CBOM_CATALOG a inner join SAP_PRODUCT_STATUS_ORDERABLE b " &
                                  " on a.CATALOG_ID = b.PART_NO " &
                                  " where a.Catalog_Org='" & org.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & _CatalogType & "' and b.SALES_ORG = '" + Session("Org_id").ToString + "'"
                            T_strWhere = ""
                        End If
                    End If
                End If
            End If

        Else
            T_strselect = " select distinct '' as SNO,a.CATALOG_ID,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly,c.COMPANY_ID , a.CREATED" & _
                          " from CBOM_CATALOG a " & _
                          " inner join PRODUCT_CUSTOMER_DICT c" & _
                          " on a.CATALOG_NAME=c.PART_NO " & _
                          " where a.Catalog_Org='" & org.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & _CatalogType & "' and a.CATALOG_NAME=c.PART_NO"
            T_strWhere = ""

            '' If Session("USER_ID") <> "tam.tran@advantech-nl.nl" Then
            Select Case UCase(strMFGCompanyID)
                Case "UUAAESC", "EFRA008", "EUKADV", "EITW004", "EHLC001"
                    T_strWhere = T_strWhere & " and a.CATALOG_NAME in (select distinct PART_NO from PRODUCT_CUSTOMER_DICT where PRODUCT_TYPE like '%CTOS')"
                Case "EHLA002"
                    T_strWhere = T_strWhere & " and a.CATALOG_NAME in (select distinct PART_NO from PRODUCT_CUSTOMER_DICT where COMPANY_ID = 'EHLA002' and PRODUCT_TYPE like '%CTOS')"
                Case Else

                    T_strWhere = T_strWhere & " and a.CATALOG_NAME in (select distinct PART_NO from PRODUCT_CUSTOMER_DICT where (COMPANY_ID = '" & UCase(StrCompany) & "' or SHIPTO_ID = '" & UCase(StrCompany) & "') and PRODUCT_TYPE like '%CTOS')"

                    T_strWhere &= " and c.COMPANY_ID='" & StrCompany & "'"
            End Select
            'End If
            T_strselect = T_strselect & T_strWhere '& " Order By c.COMPANY_ID asc,a.CATALOG_NAME asc"

            T_strselect &= " union select distinct '' as SNO,a.CATALOG_ID,a.CATALOG_NAME,a.CATALOG_DESC, a.IMAGE_ID,'' as QTY ,'CONFIG' as Assembly,'" & StrCompany & "' as COMPANY_ID, a.CREATED" & _
                          " from CBOM_CATALOG a " & _
                          " where a.Catalog_Org='" & org.ToString.ToUpper & "' and a.CATALOG_TYPE like '%" & _CatalogType & "' and a.CATALOG_NAME like 'C-CTOS-" & StrCompany & "%'"

            T_strselect &= " Order By a.CATALOG_NAME asc"



        End If
        'Response.Write(T_strselect)
        Me.SqlDataSource1.SelectCommand = Me.T_strselect
        If _CatalogType <> "CTOS" Then
            'Me.IMAGE_ID.xVisible = "True"            
            Me.flg = True
        Else
            Me.flg = False

        End If
        If Not Page.IsPostBack Then
            If Session("ORG_ID") = "US01" Then Me.AdxGrid1.Columns(4).Visible = False
            'Me.AdxGrid1.DataBind()
        End If
    End Sub

    Dim _CatalogType As String = ""
    Protected Sub Page_PreInit(ByVal sender As Object, ByVal e As System.EventArgs)
        _CatalogType = Server.UrlDecode(Request("Catalog_Type"))
        If IsNothing(_CatalogType) Then
            Response.Redirect("~/home.aspx")
        End If
        If _CatalogType <> "CTOS" And _CatalogType <> "Pre-Configuration" Then
            'Me.IMAGE_ID.xVisible = True
        Else
            'Me.IMAGE_ID.xVisible = False
        End If
    End Sub

    Protected Sub AdxGrid1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        'Dim oDataGridItem As DataGridItem = e.Item
        'Dim retVal() As String
        'Dim idx As Integer = 0
        'Dim oType As ListItemType = e.Item.ItemType
        If IsNothing(_CatalogType) Then
            Exit Sub
        End If
        If _CatalogType IsNot Nothing AndAlso (_CatalogType.Trim = "CTOS" Or _CatalogType.Trim = "Pre-Configuration") Then
            e.Row.Cells(4).Visible = False
        End If
        e.Row.Cells(5).Visible = False
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Cells(3).HorizontalAlign = HorizontalAlign.Left
            e.Row.Cells(3).Text = Server.HtmlDecode(e.Row.Cells(3).Text)
        End If
        If e.Row.RowType = DataControlRowType.Header Then
            If _CatalogType <> "CTOS" Then
            Else
                Select Case UCase(StrCompany)
                    Case "UUAAESC", "EFRA008", "EUKADV", "EITW004", "EHLC001"
                        'AdxGrid1.VxUserFormat(oDataGridItem, 6, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Change&nbsp;Company&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
                        e.Row.Cells(7).Text = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Change&nbsp;Company&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                    Case Else
                        'AdxGrid1.VxUserFormat(oDataGridItem, 6, "Assemble")
                        e.Row.Cells(7).Text = "Assemble"
                End Select

            End If
        End If
        If (e.Row.RowType <> DataControlRowType.Header And e.Row.RowType <> DataControlRowType.Footer) Then
            'retVal = Me.AdxGrid1.VxGetGridItemValue(oDataGridItem)

            'AdxGrid1.VxUserFormat(oDataGridItem, 2, Replace(retVal(2), Chr(13), "<BR>"))
            e.Row.Cells(3).Text = Replace(e.Row.Cells(3).Text, vbCrLf, "<br/>")


            If _CatalogType IsNot Nothing AndAlso _CatalogType <> "CTOS" Then
                Dim DBITEM As DataRowView = CType(e.Row.DataItem, DataRowView)
                If _CatalogType = "Pre-Configuration" Then
                    'AdxGrid1.VxUserFormat(oDataGridItem, 5, "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' ><input type='Text' style='text-align:right' maxlength='5' size='5' name='qty-" & retVal(3) & "' value ='1' onChange= setQty(this)>")
                    e.Row.Cells(6).Text = "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' ><input type='Text' style='text-align:right' maxlength='5' size='5'  id='qty-" & DBITEM.Item("IMAGE_ID") & "' name='qty-" & e.Row.Cells(4).Text & "' value ='1' onChange= setQty(this)>"
                    'Response.Write(retVal(3))
                    'AdxGrid1.VxUserFormat(oDataGridItem, 6, "<img src=""../images/ebiz.aeu.face/btn_config.gif"" onclick=""Call_Configurator('" & retVal(3) & "')""/>")
                    e.Row.Cells(7).Text = "<img src=""../images/ebiz.aeu.face/btn_config.gif"" style=""cursor:pointer"" onclick=""Call_Configurator('" & DBITEM.Item("IMAGE_ID") & "')""/>"
                Else
                    'AdxGrid1.VxUserFormat(oDataGridItem, 3, "<img src='../images/CBOM/" & retVal(3) & "'" & " width='110' height='100' border=0/>")
                    'e.Row.Cells(4).Text = "<img src='http://" + Request.ServerVariables("HTTP_HOST").ToString + "/images/CBOM/" & e.Row.Cells(4).Text & "'" & " width='110' height='100' border=0/>"
                    If e.Row.Cells(4).Text.ToUpper() <> "" Then
                        e.Row.Cells(4).Text = "<img  src='" + Util.GetRuntimeSiteUrl() + "/Includes/ShowFile.aspx?ROW_ID=" & e.Row.Cells(4).Text & "' width=""100""  height=""100"" border=""0""/>"
                    Else
                        e.Row.Cells(4).Text = ""
                    End If
                    'AdxGrid1.VxUserFormat(oDataGridItem, 5, "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' ><input type='Text' style='text-align:right' maxlength='5' size='5' name='qty-" & retVal(1) & "' value ='1' onChange= setQty(this)>")
                    e.Row.Cells(6).Text = "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' ><input type='Text' style='text-align:right' maxlength='5' size='5' id='qty-" & e.Row.Cells(2).Text & "' name='qty-" & e.Row.Cells(2).Text & "' value ='1' onChange= setQty(this)>"
                    'AdxGrid1.VxUserFormat(oDataGridItem, 6, "<img src=""../images/ebiz.aeu.face/btn_config.gif"" onclick=""Call_Configurator('" & retVal(1) & "')""/>")
                    e.Row.Cells(7).Text = "<img src=""../images/ebiz.aeu.face/btn_config.gif"" style=""cursor:pointer"" onclick=""Call_Configurator('" & e.Row.Cells(2).Text & "')""/>"
                End If

            Else
                Dim xCompany = e.Row.Cells(5).Text, xType As String = "(Company)"

                If xCompany = "" Then
                    xCompany = "N/A" : xType = ""
                End If
                If UCase(xCompany) = UCase(StrCompany) Or UCase(xCompany) = "N/A" Then
                    Select Case UCase(StrCompany)
                        Case "UUAAESC", "EFRA008", "EUKADV", "EITW004", "EHLC001"
                            'AdxGrid1.VxUserFormat(oDataGridItem, 6, "Invalid Customer Code")
                            e.Row.Cells(7).Text = "Invalid Customer Code"
                        Case Else
                            'AdxGrid1.VxUserFormat(oDataGridItem, 5, "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' ><input type='Text' style='text-align:right' maxlength='5' size='5' name='qty-" & retVal(1) & "' value ='1' onChange= setQty(this)>")
                            e.Row.Cells(6).Text = "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' ><input type='Text' style='text-align:right' maxlength='5' size='5' id='qty-" & e.Row.Cells(2).Text & "' name='qty-" & e.Row.Cells(2).Text & "' value ='1' onChange= setQty(this)>"
                            'AdxGrid1.VxUserFormat(oDataGridItem, 6, "<img src=""../images/ebiz.aeu.face/btn_config.gif"" onclick=""Call_Configurator('" & retVal(1) & "')""/>")
                            e.Row.Cells(7).Text = "<img src=""../images/ebiz.aeu.face/btn_config.gif"" style=""cursor:pointer"" onclick=""Call_Configurator('" & e.Row.Cells(2).Text & "')""/>"
                    End Select
                Else
                    'AdxGrid1.VxUserFormat(oDataGridItem, 5, "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' >1")
                    e.Row.Cells(6).Text = "<input type='hidden' maxlength='5' size='5' name='QTY'  value ='1' >1"
                    'AdxGrid1.VxUserFormat(oDataGridItem, 6, "<a href='#' onclick=ChangeCompany('" & xCompany & "')>Change&nbsp;Company&nbsp;to&nbsp;<b>" & xCompany & "</b></a>")
                    'AdxGrid1.VxUserFormat(oDataGridItem, 6, "<input type=""button"" value=""Change&nbsp;Company&nbsp;to&nbsp;" & xCompany & """ onclick=""ChangeCompany('" & xCompany & "')""/>")
                    e.Row.Cells(7).Text = "<input type=""button"" value=""Change&nbsp;Company&nbsp;to&nbsp;" & xCompany & """ onclick=""ChangeCompany('" & xCompany & "')""/>"
                End If

            End If
        End If

        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim pn As String = e.Row.Cells(2).Text
            'Frank 2012/06/04: Stop using Session("org") and replacing by Left(Session("org_id"), 2)
            'If Util.IsHotSelling(pn, HttpContext.Current.Session("Org")) Then
            '    e.Row.Cells(2).Text = e.Row.Cells(2).Text & "<img src='/Images/Hot-Orange.gif' alt='Hot!'/>"
            'End If
            'If Util.IsFastDelivery(pn, HttpContext.Current.Session("Org")) Then
            '    e.Row.Cells(2).Text = e.Row.Cells(2).Text & " <img src='/Images/Fast Delivery.gif' alt='Fast Delivery'/> "
            'End If
            If Util.IsHotSelling(pn, Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2)) Then
                e.Row.Cells(2).Text = e.Row.Cells(2).Text & "<img src='/Images/Hot-Orange.gif' alt='Hot!'/>"
            End If
            If Util.IsFastDelivery(pn, Left(HttpContext.Current.Session("Org_id").ToString.ToUpper, 2)) Then
                e.Row.Cells(2).Text = e.Row.Cells(2).Text & " <img src='/Images/Fast Delivery.gif' alt='Fast Delivery'/> "
            End If



            'If dt5.Rows.Count > 0 Then
            '    e.Row.Cells(1).Text = "<input type=""button"" value=""Close"" style=""color: #FF0000""  onclick=""ChangeStatus('" & e.Row.Cells(2).Text & "')""/>"
            'Else
            '    e.Row.Cells(1).Text = "<input type=""button"" value=""Open""  onclick=""ChangeStatus('" & e.Row.Cells(2).Text & "')""/>"
            'End If
            If _CatalogType.ToString.Trim = "Pre-Configuration" Then
                e.Row.Cells(2).Text = AdxGrid1.DataKeys(e.Row.DataItemIndex).Values(0)
            End If
        End If
        If _CatalogType <> "CTOS" Then
            e.Row.Cells(1).Visible = False
        End If
    End Sub


    Protected Sub btnExport_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim SQL As String = "select Part_No from Tick_Product where Part_No='" & value1.Value & "'"
        Dim dt5 As DataTable = dbUtil.dbGetDataTable("B2B", SQL)
        If dt5.Rows.Count > 0 Then
            SQL = "delete from dbo.Tick_Product where part_no='" & value1.Value & "'"
        Else
            SQL = "insert into dbo.Tick_Product values('" & value1.Value & "')"
        End If

        dbUtil.dbExecuteNoQuery("b2b", SQL)
        'Me.AdxGrid1.DataBind()
    End Sub
    Protected Sub rdFilter_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs)
        AdxGrid1.DataBind()
    End Sub
    Protected Function GetLocalName() As String
        Dim CBOMWS As New MyCBOMDAL
        Return CBOMWS.getCatalogLocalName(_CatalogType, org)
    End Function

</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <script type="text/javascript" src="/includes/jquery-1.11.1.min.js"></script>
    <uc1:ChangeCompany runat="server" ID="chgCompany" Visible="false" />
    <script type="text/javascript">
        function filter(name, q) {
            var regex = new RegExp(q, 'i');

            $('#' + name + ' tr').slice(1).each(function (i, tr) {
                tr = $(tr);
                var str = tr.text();
                if (regex.test(str)) {
                    tr.show();
                } else {
                    tr.hide();
                }
            });
        }

    </script>
    <table width="100%">
        <tr>
            <td>
                <table width="100%" id="Table2">
                    <tr valign="top">
                        <td height="2">&nbsp;
                        </td>
                    </tr>
                    <tr valign="top">
                        <td class="pagetitle">
                            <table width="100%" id="Table1" border="0">
                                <tr>
                                    <td width="230">
                                        <div class="euPageTitle">Configuration List</div>
                                    </td>
                                    <td><font face="Tahoma" size="2" color="Crimson"><b>::: <%=GetLocalName()%></b></font></td>
                                    <td align="right" valign="bottom"><font face="Arial" color="RoyalBlue">
                                        <a href="mailto:e-btos@advantech-nl.nl;emil.hsu@advantech.de">? Feedbacks to Advantech BTOS Contacts</a></font>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="230"></td>
                                    <td></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td height="15"></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Panel runat="server" ID="plSearch" DefaultButton="btndm">
                                <label class="lbStyle">Search:</label>
                                <asp:TextBox ID="txtSearch" runat="server" onkeyup="filter('ctl00__main_AdxGrid1',this.value)"></asp:TextBox>
                                <asp:Button runat="server" ID="btndm" Enabled="false" Style="display: none" />
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:RadioButtonList runat="server" ID="rdFilter" RepeatDirection="Horizontal" RepeatColumns="4" Visible="false" AutoPostBack="true" OnSelectedIndexChanged="rdFilter_SelectedIndexChanged">
                                <asp:ListItem Value="1U (up to 3 Slots)" Selected="True">1U (up to 3 Slots)</asp:ListItem>
                                <asp:ListItem Value="2U (up to 5 Slots)">2U (up to 5 Slots)</asp:ListItem>
                                <asp:ListItem Value="4U BP Rackmount (up to 14-Slots)">4U BP Rackmount (up to 14-Slots)</asp:ListItem>
                                <asp:ListItem Value="4U BP Rackmount (up to 20-Slots)">4U BP Rackmount (up to 20-Slots)</asp:ListItem>
                                <asp:ListItem Value="4U MB Rackmount (up to 7-Slots)">4U MB Rackmount (up to 7-Slots)</asp:ListItem>
                                <asp:ListItem Value="Wallmount (up to 6 Slots)">Wallmount (up to 6 Slots)</asp:ListItem>
                                <asp:ListItem Value="Wallmount (up to 7 Slots)">Wallmount (up to 7 Slots)</asp:ListItem>
                                <asp:ListItem Value="Wallmount (up to 8 Slots)">Wallmount (up to 8 Slots)</asp:ListItem>
                            </asp:RadioButtonList>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td align="center">
                            <table cellpadding="1" width="100%">
                                <tr>
                                    <td style="background-color: #666666">
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" style="vertical-align: middle" id="Table3">
                                            <tr>
                                                <td style="padding-left: 10px; border-bottom: #ffffff 1px solid; height: 20px; background-color: #6699CC"
                                                    align="left" valign="middle" class="text">
                                                    <font color="#ffffff"><b>Configuration Listing</b></font>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:GridView runat="server" ID="AdxGrid1" Width="100%" DataKeyNames="CATALOG_ID" AutoGenerateColumns="false" OnRowDataBound="AdxGrid1_RowDataBound" DataSourceID="SqlDataSource1">
                                                        <Columns>
                                                            <asp:TemplateField ItemStyle-Width="2%" ItemStyle-HorizontalAlign="Center">
                                                                <HeaderTemplate>
                                                                    No.
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <%# Container.DataItemIndex + 1 %>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:BoundField HeaderText="ChangeStatus" />
                                                            <asp:BoundField DataField="CATALOG_NAME" HeaderText="BTO Description" ItemStyle-CssClass="Tnowrap" />
                                                            <asp:BoundField DataField="CATALOG_DESC" HeaderText="Group Description" />
                                                            <asp:BoundField DataField="IMAGE_ID" HeaderText="Image" />
                                                            <asp:BoundField DataField="COMPANY_ID" HeaderText="Change Company" />
                                                            <asp:TemplateField HeaderText="QTY">
                                                                <ItemTemplate>
                                                                    <asp:TextBox runat="server" ID="txtQty" Text="1" Width="30px" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Assemble">
                                                                <ItemTemplate>
                                                                    <asp:ImageButton runat="server" ID="imgBtnAssemble" ImageUrl="" AlternateText="Configure" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                    <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ ConnectionStrings:B2B %>" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td id="tdTotal" align="right" style="background-color: #ffffff" runat="server"></td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr valign="top">
                        <td height="2">&nbsp;</td>
                    </tr>
                </table>
                <asp:Button ID="btnExport" Style="height: 0px; width: 0px" runat="server" OnClick="btnExport_Click" Visible="false"></asp:Button>
                <asp:HiddenField ID="value1" runat="server" />
            </td>
        </tr>
    </table>

    <script type="text/javascript">


        function setQty(obj) {
            // alert (obj.value)
            //Session("QTY") = obj.value
            obj.previousSibling.value = obj.value
        }

        function Call_Configurator(CATALOG_NAME) {
            //alert(CATALOG_NAME);
            //window.event.returnValue = false ;
            // var intQty = window.document.all['qty-' + CATALOG_NAME ].value ;  
            var intQty = document.getElementById('qty-' + CATALOG_NAME).value;
            //var intQty = document.getElementsByTagName['qty-' + CATALOG_NAME ].value ;  
            var quote = 0
            //alert(intQty);
            if ('<%=Request("UID") %>' != '') { quote = 1; }
            document.location.href = 'Configurator.aspx?BTOITEM=' + CATALOG_NAME + '&QTY=' + intQty;
        }

        function ChangeCompany(Company_Name) {
            window.event.returnValue = false;
            document.location.href = "CBOM_List.aspx?Catalog_Type=CTOS&CompanyID=" + Company_Name;
        }
        function ChangeStatus(value) {
            window.document.all["ctl00$_main$value1"].value = value
            document.getElementById("ctl00$_main$btnExport").click();
        }

    </script>
</asp:Content>
