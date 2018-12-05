<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech Product Phase In/Out Inquiry" EnableEventValidation="false" %>

<%@ Import Namespace="System.Globalization" %>

<script runat="server">
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetGroup(ByVal knownCategoryValues As String, ByVal category As String) As CascadingDropDownNameValue()
        Dim CasGrps() As CascadingDropDownNameValue = _
       { _
           New CascadingDropDownNameValue("All", "All"), _
           New CascadingDropDownNameValue("ePlatform", "EAPC"), _
           New CascadingDropDownNameValue("IIoT", "EAUT"), _
           New CascadingDropDownNameValue("Others", "OTHR") _
       }
        Return CasGrps
    End Function
    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function GetDivision(ByVal knownCategoryValues As String, ByVal category As String) As CascadingDropDownNameValue()
        Dim str As String = String.Format("select distinct product_division from PLM_PHASEIN where product_group='{0}' union select distinct product_division from PLM_PHASEOUT where product_group='{0}'", Replace(Replace(knownCategoryValues, "PGROUP:", ""), ";", ""))
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", str)
        If dt.Rows.Count > 0 Then
            Dim CasDivs(dt.Rows.Count - 1) As CascadingDropDownNameValue
            For i As Integer = 0 To dt.Rows.Count - 1
                CasDivs(i) = New CascadingDropDownNameValue(dt.Rows(i).Item(0), dt.Rows(i).Item(0))
            Next
            Return CasDivs
        End If
        Return Nothing
    End Function
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetLine(ByVal knownCategoryValues As String, ByVal category As String) As CascadingDropDownNameValue()
        Dim a() As String = Split(knownCategoryValues, ";")
        If a.Length >= 2 Then
            Dim str As String = String.Format("select distinct product_line from PLM_PHASEIN where product_division='{0}' union select distinct product_line from PLM_PHASEOUT where product_division='{0}'", Replace(a(1), "PDIVISON:", ""))
            Dim dt As DataTable = dbUtil.dbGetDataTable("MY", str)
            If dt.Rows.Count > 0 Then
                Dim CasDivs(dt.Rows.Count - 1) As CascadingDropDownNameValue
                For i As Integer = 0 To dt.Rows.Count - 1
                    CasDivs(i) = New CascadingDropDownNameValue(dt.Rows(i).Item(0), dt.Rows(i).Item(0))
                Next
                Return CasDivs
            End If
        End If

        Return Nothing
    End Function

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Page.IsPostBack OrElse (Request("txtPN") IsNot Nothing And Page.IsPostBack = False) Then
            Dim TableName As String = "PLM_PHASEIN"
            If rbInOut.SelectedIndex = 1 Then TableName = "PLM_PHASEOUT"
            Dim strSql As New System.Text.StringBuilder
            With strSql
                .AppendLine(" SELECT distinct top 500 a.PRODUCT_GROUP, a.PRODUCT_DIVISION, a.PRODUCT_LINE, " + _
                            " a.MODEL_NO, a.ITEM_NUMBER, a.REV_NUMBER, a.RELEASE_DATE, a.CHANGE_DESC, IsNull(b.PRODUCT_DESC,'') as PRODUCT_DESC, ")
                If TableName = "PLM_PHASEOUT" Then
                    'Frank 2012/04/03
                    ' Using PLM_PHASEOUT_FINAL_REPLACEMENT.FINAL_REPLACE_BY instead of PLM_PHASEOUT.REPLACE_BY
                    '.AppendLine(" IsNull(a.REPLACE_BY,'') as REPLACE_BY ")
                    .AppendLine(" Case When c.FINAL_REPLACE_BY<>'' then c.FINAL_REPLACE_BY else a.REPLACE_BY end  as REPLACE_BY, ")
                    Me.gv1.Columns(Me.gv1.Columns.Count - 2).Visible = True
                Else
                    .AppendLine(" '' as REPLACE_BY, ")
                End If
                '.AppendLine(" FROM [" + TableName + "] WHERE 1=1 ")

                'Ryan 20160130 add for showing PLM Notice
                .AppendLine(" d.TXT as PLM_NOTICE ")

                .AppendLine(" FROM [" + TableName + "] a left join SAP_PRODUCT b on a.ITEM_NUMBER=b.part_no ")

                'Frank 2012/04/03
                ' Using PLM_PHASEOUT_FINAL_REPLACEMENT.FINAL_REPLACE_BY instead of PLM_PHASEOUT.REPLACE_BY
                If TableName = "PLM_PHASEOUT" Then
                    .AppendLine(" left join PLM_PHASEOUT_FINAL_REPLACEMENT c on a.ITEM_NUMBER=c.ITEM_NUMBER and a.REPLACE_BY=c.REPLACE_BY ")
                End If

                'Ryan 20160130 left join for showing PLM Notice
                .AppendLine(" left join  SAP_PRODUCT_ORDERNOTE d on a.ITEM_NUMBER = d.PART_NO and d.ORG = '" + Session("org_id") + "'")

                '.AppendLine(" inner join SAP_PRODUCT_STATUS c on  c.PART_NO = a.ITEM_NUMBER  and c.SALES_ORG = b.ORG_ID  ")
                '.AppendLine(" where c.PRODUCT_STATUS IN ('A','N','H') AND b.org_id='" + Session("org_id") + "'")
                .AppendLine(" where 1=1 ")
                .AppendLine("  ")
                If Me.dlPrdGrp.SelectedValue <> "" And Me.dlPrdGrp.SelectedValue <> "All" Then
                    .AppendLine(String.Format(" and a.PRODUCT_GROUP='{0}' ", Me.dlPrdGrp.SelectedValue))
                    If Me.dlPrdDiv.SelectedValue <> "" Then
                        If Me.dlPrdDiv.SelectedValue <> "All" Then
                            .AppendLine(String.Format(" and a.PRODUCT_DIVISION='{0}' ", Me.dlPrdDiv.SelectedValue))
                            If Me.dlPrdLine.SelectedValue <> "" Then
                                If Me.dlPrdLine.SelectedValue <> "All" Then
                                    .AppendLine(String.Format(" and a.PRODUCT_LINE='{0}' ", Me.dlPrdLine.SelectedValue))
                                End If
                            End If

                        End If
                    End If

                End If


                Dim _date1 As Date, _IsDate As Boolean = False, DateString = String.Empty


                'If Me.txtDFrom.Text <> "" And IsDate(Me.txtDFrom.Text) Then
                '    .AppendLine(String.Format(" and a.RELEASE_DATE>='{0}' ", txtDFrom.Text))
                'End If
                'If Me.txtDTo.Text <> "" And IsDate(Me.txtDTo.Text) Then
                '    .AppendLine(String.Format(" and a.RELEASE_DATE<='{0}' ", txtDTo.Text))
                'End If

                If Me.txtDFrom.Text <> "" Then
                    DateString = Me.txtDFrom.Text
                    _IsDate = Date.TryParseExact(DateString, "yyyy/MM/dd", CultureInfo.CurrentCulture, DateTimeStyles.None, _date1)
                    If _IsDate AndAlso DateString > "1990/01/01" Then
                        .AppendLine(String.Format(" and a.RELEASE_DATE>='{0}' ", txtDFrom.Text))
                    End If
                End If
                If Me.txtDTo.Text <> "" Then
                    DateString = Me.txtDTo.Text
                    _IsDate = Date.TryParseExact(DateString, "yyyy/MM/dd", CultureInfo.CurrentCulture, DateTimeStyles.None, _date1)
                    If _IsDate AndAlso DateString > "1990/01/01" Then
                        .AppendLine(String.Format(" and a.RELEASE_DATE<='{0}' ", txtDTo.Text))
                    End If
                End If


                If Trim(Server.HtmlEncode(Me.txtPN.Text.Replace(";", ""))) <> "" Then
                    .AppendLine(String.Format(" and a.ITEM_NUMBER like '%{0}%' ", Trim(Server.HtmlEncode(Me.txtPN.Text.Trim.Replace(";", "").Replace("'", "").Replace("*", "")))))
                End If
            End With
            Me.SqlDataSource1.SelectCommand = strSql.ToString()
            'MailUtil.SendDebugMsg("plm inout by" + User.Identity.Name, Me.SqlDataSource1.SelectCommand, "tc.chen@advantech.com.tw")
            lbSql.Text = Me.SqlDataSource1.SelectCommand
            If Request("txtPN") IsNot Nothing And Page.IsPostBack = False Then
                Me.txtPN.Text = Request("txtPN")
            End If
        End If
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            If Session("user_role") = "Administrator" Or Session("user_role") = "Logistics" Or Session("user_role") = "Sales" Then
                e.Row.Cells(6).Text = "<a href='http://aeu-ebus-dev:7000/Admin/ProductProfile.aspx?PN=" + e.Row.Cells(6).Text + "' target='_blank'>" + e.Row.Cells(6).Text + "</a>"
            End If
            If dbUtil.dbGetDataTable("My", "select * from SIEBEL_CATALOG_CATEGORY where DISPLAY_NAME='" + e.Row.Cells(5).Text + "'").Rows.Count > 0 Then
                e.Row.Cells(5).Text = "<a target='_blank' href='http://my.advantech.eu/Product/Model_Detail.aspx?model_no=" + e.Row.Cells(5).Text + "'>" + e.Row.Cells(5).Text + "</a>"
            End If
        End If

    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        'gv1.Export2Excel("Prd.xls")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", Me.SqlDataSource1.SelectCommand)
        If dt IsNot Nothing Then
            Util.DataTable2ExcelDownload(dt, "Prd.xls")
        End If
    End Sub

    Protected Sub btnAdd2Cart_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Dim part_no As String = ""
        'Dim nonPriceProduct As String = ""
        'Dim xMultiPriceDT As New DataTable
        'PricingUtil.InitMultiPriceDT(xMultiPriceDT)
        'For Each r As GridViewRow In gv1.Rows
        '    If r.RowType = DataControlRowType.DataRow Then
        '        part_no = r.Cells(6).Text
        '        Dim cb As CheckBox = CType(r.FindControl("item"), CheckBox)
        '        If cb IsNot Nothing And cb.Checked Then
        '            If Integer.Parse(dbUtil.dbExecuteScalar("B2B", String.Format("select count(*) from product where part_no='{0}'", part_no))) > 0 Then
        '                Dim r2 As DataRow = xMultiPriceDT.NewRow
        '                With r2
        '                    .Item("part_no") = part_no : .Item("qty") = 1
        '                End With
        '                xMultiPriceDT.Rows.Add(r2)
        '            Else
        '                nonPriceProduct &= "\r\n" & part_no
        '            End If
        '        End If
        '    End If
        'Next
        'If xMultiPriceDT.Rows.Count = 0 Or IsNothing(xMultiPriceDT) Then
        '    Util.JSAlert(Page, "Products can not be added to cart : " & nonPriceProduct)
        '    Exit Sub
        'End If
        'Dim tmpDueDateDt As DataTable = Nothing
        'If xMultiPriceDT.Rows.Count > 0 Then
        '    Dim pu As New PricingUtil(xMultiPriceDT, Session("company_id"), Session("user_id"))
        '    Dim t1 As New Threading.Thread(AddressOf pu.GetPrice)
        '    t1.Start()
        '    t1.Join()
        'End If

        For Each r As GridViewRow In gv1.Rows
            part_no = r.Cells(6).Text
            If r.RowType = DataControlRowType.DataRow Then
                Dim cb As CheckBox = CType(r.FindControl("item"), CheckBox)
                ' Dim intMaxLineNo As Integer = 0, list_price As Decimal, unit_price As Decimal
                If cb IsNot Nothing AndAlso cb.Checked AndAlso OrderUtilities.Add2CartCheck(part_no.Trim, "") Then
                    'Dim dr1 As DataTable = dbUtil.dbGetDataTable("B2B", "select isnull(max(line_no),0) As line_no from cart_detail where cart_id='" & Session("cart_id") & "' and line_no<100")
                    'If dr1.Rows.Count > 0 Then
                    '    intMaxLineNo = CInt(dr1.Rows(0).Item("line_no")) + 1
                    'Else
                    '    intMaxLineNo = 1
                    'End If
                    'Dim rs() As DataRow = xMultiPriceDT.Select(String.Format("part_no='{0}'", part_no))
                    'If rs.Length > 0 Then
                    '    list_price = CType(rs(0).Item("list_price"), Decimal)
                    '    unit_price = CType(rs(0).Item("unit_price"), Decimal)
                    'End If
                    'Dim ITP As Decimal = 0
                    'Dim Curr As String = Session("Company_Currency")
                    'ITP = Util.GetSAPPrice(part_no, "UUAAESC")
                    'If Curr <> "EUR" Then
                    '    ITP = FormatNumber(ITP * CType(OrderUtilities.get_exchangerate("EUR", Curr).ToString, Decimal), 2)
                    'End If
                    'Dim iRet As Integer = OrderUtilities.CartLine_Add(Session("cart_id"), intMaxLineNo, part_no, 1, list_price, unit_price, "EUH1", "0", ITP)                   
                    Dim mycart As New CartList("b2b", "cart_detail")
                    Dim CartId As String = Session("Cart_id")
                    Dim Cate As String = ""
                    Dim otype As Integer = 0
                    If mycart.isBtoOrder(CartId) = 1 Then
                        otype = 1
                        Cate = "OTHERS"
                    End If
                    mycart.ADD2CART(CartId, part_no, 1, 0, otype, Cate, 1, 1)
                End If
            End If
        Next
        'If nonPriceProduct <> "" Then
        '    Util.JSAlertRedirect(Page, "Products can not be added to cart : " & nonPriceProduct, "/order/cart_list.aspx")
        'Else
        Response.Redirect("../order/cart_list.aspx")
        'End If
    End Sub

    'Protected Sub btnAdd2Interest_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
    '    Dim part_no As String = ""
    '    Dim nonPriceProduct As String = ""
    '    Dim iRet As Integer = 0
    '    For Each r As GridViewRow In gv1.Rows
    '        part_no = r.Cells(6).Text
    '        If r.RowType = DataControlRowType.DataRow Then
    '            Dim cb As CheckBox = CType(r.FindControl("item"), CheckBox)
    '            If cb IsNot Nothing And cb.Checked Then
    '                If Integer.Parse(dbUtil.dbExecuteScalar("B2B", String.Format("select count(*) from product where part_no='{0}'", part_no))) > 0 Then
    '                    If Integer.Parse(dbUtil.dbExecuteScalar("My", String.Format("select count(*) from interested_product where userid='{0}' and part_no='{1}'", Session("user_id"), part_no))) = 0 Then
    '                        iRet += dbUtil.dbExecuteNoQuery("My", String.Format("insert into interested_product (userid,part_no,date) values ('{0}','{1}',getdate())", Session("user_id"), part_no))
    '                    End If
    '                Else
    '                    nonPriceProduct &= "\r\n" & part_no
    '                End If
    '            End If
    '        End If
    '    Next
    '    If nonPriceProduct <> "" And iRet > 0 Then
    '        Util.JSAlertRedirect(Page, "Products can not be added to MyInterest : " & nonPriceProduct, "/My/MyInterest.aspx")
    '    ElseIf nonPriceProduct <> "" And iRet = 0 Then
    '        Util.JSAlert(Page, "Products can not be added to MyInterest : " & nonPriceProduct)
    '    Else
    '        Response.Redirect("/My/MyInterest.aspx")
    '    End If
    'End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As EventArgs) Handles gv1.DataBound
        If gv1.Rows.Count > 0 Then
            btnToXls.Visible = True : btnAdd2Cart.Visible = True : btnToXls1.Visible = True : btnAdd2Cart1.Visible = True
        Else
            btnToXls.Visible = False : btnAdd2Cart.Visible = False : btnToXls1.Visible = False : btnAdd2Cart1.Visible = False
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Session("user_id") IsNot Nothing AndAlso Session("user_id") = "ming.zhao@advantech.com.cn" Then lbSql.Visible = True
        If Not Page.IsPostBack Then
            txtDFrom.Text = DateAdd(DateInterval.Month, -6, Now).ToString("yyyy/MM/dd") : txtDTo.Text = DateAdd(DateInterval.Month, 6, Now).ToString("yyyy/MM/dd")
        End If
    End Sub

</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <div id="navtext"><a style="color:Black" href="../home.aspx">Home</a> > Product Phase In/Out</div><br />
    <table width="100%">
        <tr>
            <td>
                <asp:Panel runat="server" ID="searchPanel" DefaultButton="btnQuery">
                    <table width="60%">
                        <tr>
                            <th align="left">Phase In/Out</th>
                            <td>
                                <asp:RadioButtonList runat="server" ID="rbInOut" RepeatDirection="Horizontal">
                                    <asp:ListItem Text="Phase In" Value="0" Selected="True" />
                                    <asp:ListItem Text="Phase Out" Value="1" />
                                </asp:RadioButtonList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Product Group</th>
                            <td>
                                <ajaxToolkit:CascadingDropDown runat="server" ID="cdd1" TargetControlID="dlPrdGrp" Category="PGROUP"
                                    ParentControlID="" PromptText="Select Product Group" SelectedValue="" ServiceMethod="GetGroup"/>
                                <asp:DropDownList runat="server" ID="dlPrdGrp" Width="150px">
                                    <asp:ListItem Text="All" Value="All" />
                                    <asp:ListItem Text="ePlatform" Value="EAPC" />
                                    <asp:ListItem Text="IIoT" Value="EAUT" />
                                    <asp:ListItem Text="Others" Value="OTHR" />
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Product Division</th>
                            <td>
                                <ajaxToolkit:CascadingDropDown runat="server" ID="cdd2" TargetControlID="dlPrdDiv" Category="PDIVISON"
                                    ParentControlID="dlPrdGrp" PromptText="Select Product Division" SelectedValue="" ServiceMethod="GetDivision"/>
                                <asp:DropDownList runat="server" ID="dlPrdDiv" Width="150px"/>
                            </td>
                        </tr>
                         <tr>
                            <th align="left">Product Line</th>
                            <td>
                                <ajaxToolkit:CascadingDropDown runat="server" ID="cdd3" TargetControlID="dlPrdLine" Category="PLINE"
                                    ParentControlID="dlPrdDiv" PromptText="Select Product Line" SelectedValue="" ServiceMethod="GetLine"/>
                                <asp:DropDownList runat="server" ID="dlPrdLine" Width="150px"/>
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Part No.</th>
                            <td>
                                <asp:TextBox runat="server" ID="txtPN" Width="200px" />
                            </td>
                        </tr>
                        <tr>
                            <th align="left">Date Range</th>
                            <td>
                                <ajaxToolkit:CalendarExtender runat="server" ID="cal1" TargetControlID="txtDFrom" PopupPosition="TopLeft" Format="yyyy/MM/dd" />
                                <ajaxToolkit:CalendarExtender runat="server" ID="cal2" TargetControlID="txtDTo" PopupPosition="TopLeft" Format="yyyy/MM/dd" />
                                <asp:TextBox runat="server" ID="txtDFrom" Width="80px" />~<asp:TextBox runat="server" ID="txtDTo" Width="80px" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2" align="center">
                                <asp:ImageButton runat="server" ID="btnQuery" ImageUrl="~/Images/btn7.jpg" AlternateText="Search" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <table border=0 cellpadding="0" cellspacing="0">
                    <tr>
                        <td><asp:ImageButton runat="server" ID="btnToXls" ImageUrl="/Images/icon_excel.jpg" AlternateText="Export To Excel" Visible="false" OnClick="btnToXls_Click" /></td>
                        <td width="5"></td>
                        <td><asp:ImageButton runat="server" ID="btnAdd2Cart" ImageUrl="~/Images/btn_add2cart1.gif" AlternateText="Add2Cart" Visible="false" OnClick="btnAdd2Cart_Click" /></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                
                <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="False" Width="95%" AllowSorting="true"
                    DataSourceID="SqlDataSource1" OnRowDataBound="gv1_RowDataBound" HeaderStyle-BackColor="#EBEADB">
                    <Columns>
                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                            <headertemplate>
                                No.
                            </headertemplate>
                            <itemtemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </itemtemplate>
                       </asp:TemplateField>
                       <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                            <headertemplate>
                                <asp:CheckBox ID="all" runat="server" />
                            </headertemplate>
                            <itemtemplate>
                                <asp:CheckBox ID="item" runat="server" />
                            </itemtemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="PRODUCT_GROUP" HeaderText="Product Group" 
                            SortExpression="PRODUCT_GROUP" />
                        <asp:BoundField DataField="PRODUCT_DIVISION" HeaderText="Product Division" 
                            SortExpression="PRODUCT_DIVISION" />
                        <asp:BoundField DataField="PRODUCT_LINE" HeaderText="Product Line" 
                            SortExpression="PRODUCT_LINE" />
                        <asp:BoundField HeaderText="Model No." DataField="MODEL_NO" SortExpression="MODEL_NO" />
                        <asp:BoundField HeaderText="Item Number" DataField="ITEM_NUMBER" SortExpression="ITEM_NUMBER" />
                        <asp:BoundField DataField="REV_NUMBER" HeaderText="Rev Number" 
                            SortExpression="REV_NUMBER" />
                        <asp:BoundField DataField="RELEASE_DATE" HeaderText="Release Date" 
                            SortExpression="RELEASE_DATE" />
                        <asp:BoundField DataField="CHANGE_DESC" HeaderText="Change Desc" 
                            SortExpression="CHANGE_DESC" />
                        <asp:BoundField DataField="REPLACE_BY" HeaderText="Replace By" 
                            SortExpression="REPLACE_BY" Visible="false" />  
                        <asp:BoundField DataField="PLM_NOTICE" HeaderText="PLM Notice" 
                            SortExpression="PLM_NOTICE"/>                          
                    </Columns>
                    <FixRowColumn FixRowType="Header" TableWidth="100%" TableHeight="450px" FixRows="-1" FixColumns="0" />
                    <CascadeCheckboxes>
                        <sgv:CascadeCheckbox ChildCheckboxID="item" ParentCheckboxID="all" />
                    </CascadeCheckboxes>
                </sgv:SmartGridView>
                <asp:SqlDataSource ID="SqlDataSource1" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:MY %>" 
                    SelectCommand="" OnLoad="SqlDataSource1_Load">
                </asp:SqlDataSource>
                <asp:Label runat="server" ID="lbSql" Visible="false" />
            </td>
        </tr>
        <tr>
            <td>
                <table border=0 cellpadding="0" cellspacing="0">
                    <tr>
                        <td><asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="/Images/icon_excel.jpg" AlternateText="Export To Excel" Visible="false" OnClick="btnToXls_Click" />&nbsp;</td>
                        <td width="5"></td>
                        <td><asp:ImageButton runat="server" ID="btnAdd2Cart1" ImageUrl="~/Images/btn_add2cart1.gif" AlternateText="Add2Cart" Visible="false" OnClick="btnAdd2Cart_Click" />&nbsp;</td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</asp:Content>