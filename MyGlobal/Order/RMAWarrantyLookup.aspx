<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech - Query Warranty" EnableEventValidation="false" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>
<script runat="server">

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

        
        Dim _querytype As String = Me.WarrantySearchType.SelectedIndex
        'Enable/Disable PN auto complete function by WarrantySearchType
        Select Case _querytype
            Case 1
                Me.ajacAce_frank.Enabled = True
            Case Else
                Me.ajacAce_frank.Enabled = False
        End Select

    End Sub
    
    Protected Sub btnQueryWarranty_Click(sender As Object, e As System.EventArgs)
        Dim _ram As tw.com.advantech.erma.RMA = New tw.com.advantech.erma.RMA
        'If Me.QueryValue.Value="" then
        Dim _querytype As String = Me.WarrantySearchType.SelectedIndex
        Dim _queryvalue As String = Me.QueryValue.Text.Trim

        Dim _dt As New DataTable("WarrantyInfo")
        Dim _isNoData As Boolean = False
        
        Select Case _querytype
            Case 1
                Dim _ds As DataSet = _ram.getWarrantyByPartNumber(_queryvalue)
                If _ds.Tables.Count = 0 Then
                    _isNoData = True
                Else
                    
                    _dt = _ds.Tables(0)
                    If _dt.Rows.Count = 0 Then
                        _isNoData = True
                    Else
                        _dt.Columns(0).ColumnName = "Product_Name"
                        _dt.Columns(1).ColumnName = "Warranty_Expired"
                        With _dt.Columns
                            .Add("Serial_Number")
                            .Add("HW_Version")
                            .Add("BIOS")
                        End With
                        _dt.AcceptChanges()
                    End If

                End If

                'Modify column display mode of grid view
                gv1.Columns(0).Visible = False
                gv1.Columns(2).HeaderText = "Warranty Period(Months)"
                gv1.Columns(3).Visible = False
                gv1.Columns(4).Visible = False

            Case Else

                Dim _aa(0) As tw.com.advantech.erma.MulitBarcode  ' = New tw.com.advantech.erma.MulitBarcode()
                _aa(0) = New tw.com.advantech.erma.MulitBarcode()
                _aa(0).SN = _queryvalue
                Dim _warrantyinfo() As tw.com.advantech.erma.WarrantyInfo = _ram.getWarrantyByMuiltBarCode(_aa)

                With _dt.Columns
                    .Add("Serial_Number")
                    .Add("Product_Name")
                    .Add("Warranty_Expired")
                    .Add("HW_Version")
                    .Add("BIOS")
                End With
                
                If String.IsNullOrEmpty(_warrantyinfo(0).barcode_no) Then
                    _isNoData = True
                Else
                    Dim _row As DataRow = _dt.NewRow
                    _row.Item("Serial_Number") = _warrantyinfo(0).barcode_no
                    _row.Item("Product_Name") = _warrantyinfo(0).product_name
                    _row.Item("Warranty_Expired") = _warrantyinfo(0).warranty_date
                    _row.Item("HW_Version") = _warrantyinfo(0).hw_version
                    _row.Item("BIOS") = _warrantyinfo(0).bios_version
                    _dt.Rows.Add(_row)
                End If

                _dt.AcceptChanges()
                
                'Modify column display mode of grid view
                gv1.Columns(0).Visible = True
                gv1.Columns(2).HeaderText = "Warranty Expired"
                gv1.Columns(3).Visible = True
                gv1.Columns(4).Visible = True


        End Select
        
        If Not Me.upContent.Visible Then Me.upContent.Visible = True
        If Not Me.infor1.Visible Then Me.infor1.Visible = True

        If _isNoData Then
            Me.gv1.EmptyDataText = "No data found!"
        End If
        
        Me.gv1.DataSource = _dt
        Me.gv1.DataBind()
        Me.upContent.Update()
        '_warrantyinfo(0).barcode_no
    End Sub

</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:Panel ID="Panel_Form" runat="server" DefaultButton="btQueryWarranty">
        <div class="root">
            <asp:HyperLink runat="server" ID="HyperLink1" NavigateUrl="~/home.aspx" Text="Home" />
            >
            <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx"
            Text="Order Tracking" />
            > Warranty Lookup</div>
        <table width="100%">
            <tr>
                <td valign="top">
                    <div class="left" style="width: 170px;">
                        <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="RMAWarrantyLookup" />
                    </div>
                </td>
                <td>
                    <div class="right" style="width: 707px;">
                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>
                                    <table width="100%" height="29" border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="12" valign="top">
                                                <img src="../images/point.gif" width="7" height="14" />
                                            </td>
                                            <td align="left" class="h2">
                                                Warranty Lookup
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <span class="news_t20_blue">
                                        <img src="../Images/warranty_icon.gif" width="34" height="20" vspace="8" align="absmiddle">Check
                                        Warranty for Your Products</span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="700" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td height="5">
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="center" background="../images/image/inpage_table_2.gif">
                                                <table width="95%" border="0" cellspacing="0" cellpadding="0">
                                                    <tr>
                                                        <td height="10">
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                                <tr>
                                                                    <td align="left">
                                                                        <strong>Warranty Lookup</strong>
                                                                    </td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="left">
                                                                        <table border="0" cellpadding="0" cellspacing="0" class="layer_t12_bk">
                                                                            <tr>
                                                                                <td>
                                                                                    Please enter a serial number or product name :
                                                                                </td>
                                                                                <td>
                                                                                    <asp:DropDownList ID="WarrantySearchType" runat="server" AutoPostBack="true">
                                                                                        <asp:ListItem Value="Barcode">Serial Number</asp:ListItem>
                                                                                        <asp:ListItem Value="Product">Product Name</asp:ListItem>
                                                                                    </asp:DropDownList>
                                                                                    <ajaxToolkit:AutoCompleteExtender ID="ajacAce_frank" Enabled='false' runat="server"
                                                                                        TargetControlID="QueryValue" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetPartNo"
                                                                                        MinimumPrefixLength="1" BehaviorID="ajacAce_autopn" />
                                                                                    <asp:TextBox runat="server" ID="QueryValue" Width="200px" />
                                                                                </td>
                                                                                <td width="50" align="right">
                                                                                    <asp:Button runat="server" ID="btQueryWarranty" Text="GO" OnClientClick="onProgress(1)"
                                                                                        OnClick="btnQueryWarranty_Click" />
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            &nbsp;
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
                </td>
            </tr>
        </table>
        <table>
            <tr>
                <td width="100%">
                    <asp:UpdatePanel runat="server" ID="upContent" UpdateMode="Conditional" ChildrenAsTriggers="false">
                        <ContentTemplate>
                            <asp:GridView runat="server" ID="gv1" Width="100%" AllowPaging="true" AllowSorting="false"
                                PageSize="10" PagerSettings-Position="TopAndBottom" AutoGenerateColumns="false"
                                EmptyDataText="" PagerSettings-PageButtonCount="20">
                                <Columns>
                                    <asp:BoundField HeaderText="Serial Number" DataField="Serial_Number" SortExpression="Serial_Number"
                                        HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Product Name" DataField="Product_Name" SortExpression="Product_Name"
                                        HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Warranty Expired" DataField="Warranty_Expired" SortExpression="Warranty_Expired"
                                        HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="HW Version" DataField="HW_Version" SortExpression="HW_Version"
                                        HeaderStyle-Width="10%" HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="BIOS" DataField="BIOS" SortExpression="BIOS" HeaderStyle-Width="10%"
                                        HeaderStyle-HorizontalAlign="Center" ItemStyle-HorizontalAlign="Center" />
                                </Columns>
                            </asp:GridView>
                            <asp:Table ID="Table1" runat="server" Visible="true" Width="100%">
                                <asp:TableRow>
                                    <asp:TableCell>
                                       <strong>Note:</strong>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow>
                                    <asp:TableCell>
                                       Standard products manufactured by ADVANTECH carry a 2 year global warranty. Excluding
                                       non-Advantech commodity items such as the LCD, hard drive and memory, etc and custom
                                       outsourced products. Warranty on-line information is only available for the product
                                       name as listed on the invoice. No on-line warranty information is available for
                                       the product name sub-components, modules, parts or peripherals. The Advantech global
                                       warranty is subject to change without notice..
                                    </asp:TableCell>
                                </asp:TableRow>
                            </asp:Table>
                            <asp:Table ID="infor1" runat="server" Visible="False" Width="100%">
                                <asp:TableRow>
                                    <asp:TableCell>
                                        The above information is for your reference only.<br />
                                        If you want to know exact Warranty Date.<br />
                                        Please contact RMA Rep. for further information.
                                    </asp:TableCell>
                                    <asp:TableCell></asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow>
                                    <asp:TableCell> </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow>
                                    <asp:TableCell>
                                        AASC Contact information ( for American Customers)<br>
                                        Your Rep: Peter Tang</p>
                                        TEL: +1 408 5193800</p>
                                        E-mail: <a href="mailto:Peter.Tang@advantech.com">Peter.Tang@advantech.com</a>
                                    </asp:TableCell>
                                    <asp:TableCell>
                                        APSC Contact Information (for European Customers)<br>
                                        Your Rep: Michal Sadowski</p>
                                        TEL: +48-22-33-23-730</p>
                                       E-mail: <a href="mailto:Michal.Sadowski@advantech.pl">Michal.Sadowski@advantech.pl</a>
                                    </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow>
                                    <asp:TableCell> </asp:TableCell>
                                </asp:TableRow>
                                <asp:TableRow>
                                    <asp:TableCell>
                                        ACSC Contact Information (for Mainland-China Customers)<br>
                                        Your Rep: Jiang Lin</p>
                                        TEL: +86 10 62984346</p>
                                       E-mail: <a href="mailto:Jiang.Lin@advantech.com.cn">Jiang.Lin@advantech.com.cn</a>
                                    </asp:TableCell>
                                    <asp:TableCell>
                                        ATSC Contact Information (for Asia-Pacific Customers)<br>
                                        Your Rep: Jennifer Lin</p>
                                        TEL: +886 2 27927818 #2472</p>
                                       E-mail: <a href="mailto:Jennifer.Lin@advantech.com.tw">Jennifer.Lin@advantech.com.tw</a>
                                    </asp:TableCell>
                                </asp:TableRow>
                            </asp:Table>
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btQueryWarranty" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>
                </td>
            </tr>
        </table>
        <script type="text/javascript">
            function onProgress(f) {
                if (f == 1) {
                    var obj = document.getElementById("<%=Me.upContent.ClientID %>");
                    obj.innerHTML = '<img src="../../Images/loading2.gif">';
                }
                else {
                    var obj = f.parentNode
                    obj.innerHTML = '<img src="/Images/loading2.gif">';
                }
            }


            function WarrantySearchType_onchange() {
                var e = document.getElementById("<%=Me.WarrantySearchType.ClientID %>");
                var e_selectedvalue = e.options[e.selectedIndex].value;
                var e_selectedtext = e.options[e.selectedIndex].text;

                if (e_selectedvalue == "Product") {
                } else {
                }

            }

            function WarrantySearchType_onclick() {
                var e = document.getElementById("<%=Me.WarrantySearchType.ClientID %>");
                var e_selectedvalue = e.options[e.selectedIndex].value;
                var e_selectedtext = e.options[e.selectedIndex].text;
                //var i = obj.getAttribute;
            }

        </script>
    </asp:Panel>
</asp:Content>
