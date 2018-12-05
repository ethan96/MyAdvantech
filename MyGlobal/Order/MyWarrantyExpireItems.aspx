<%@ Page Language="VB" EnableEventValidation="false" MasterPageFile="~/Includes/MyMaster.master" Title="My Warranty Expired Items Inquiry" %>

<%@ Register Assembly="ExportToExcel" Namespace="KrishLabs.Web.Controls" TagPrefix="RK" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>
<script runat="server">

    Public Function GetSql() As String
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendLine(" select a.item_no as part_no, isnull(a.model_no,'') as model_no, dbo.DateOnly(a.efftive_date) as invoice_date, ")
            .AppendLine(" dbo.DateOnly(a.efftive_date+730) as warranty_end_date, a.order_no as so_no, ")
            .AppendLine(" cast(a.Qty as int) as qty, ")
            .AppendLine(" case when a.tr_curr='EUR' then cast(a.EUR as numeric(18,2)) else cast(a.US_AMT/a.us_ex_rate as numeric(18,2)) end as amount, ")
            ' .AppendLine(" a.tr_curr as currency, a.line_no, ")
            .AppendLine(" a.tr_curr as currency,  ")
            .AppendLine(" a.egroup as product_group, a.edivision as product_division, a.product_line, ")
            '.AppendLine(" a.SalesOffice, a.SalesName, a.CustSegment, a.material_group, a.model_no, a.BillingDoc as invoice_no ")

            'Ryan 20170420 Get material_group from c (SAP_Product)
            .AppendLine("  c.material_group, a.BillingDoc as invoice_no ")

            .AppendLine(" ,b.serial_number,b.PO_NO as PO_number")
            .AppendLine(" from eai_sale_fact a ")
            'Frank 20120611 sap_invoice_sn was broken
            '.AppendLine("inner join  sap_invoice_sn  b on a.item_no = b.part_no and a.billingdoc = b.invoice_no")
            .AppendLine("inner join  sap_invoice_sn_v2  b on a.item_no = b.part_no and a.billingdoc = b.invoice_no")

            'Ryan 20170420 Revise for eai_sale_fact's material_group are all DBNull, join SAP_PRODUCT for this condition
            'If Me.txtTo.Text.Trim <> "" Then
            '    .AppendLine(String.Format(" where a.Qty>0 and a.material_group in ('PRODUCT') and a.customer_id='{0}' and a.efftive_date+730 between '{1}' and '{2}' and a.tran_type='shipment' ", CompanyId, FromDate, ToDate))
            'Else
            '    'Remove inquires the end date
            '    .AppendLine(String.Format(" where a.Qty>0 and a.material_group in ('PRODUCT') and a.customer_id='{0}' and a.efftive_date+730 >= '{1}'  and a.tran_type='shipment' ", CompanyId, FromDate))
            'End If
            .AppendLine(" left join SAP_PRODUCT c on b.part_no = c.PART_NO ")
            If Me.txtTo.Text.Trim <> "" Then
                .AppendLine(String.Format(" where a.Qty>0 and c.MATERIAL_GROUP in ('PRODUCT') and a.customer_id='{0}' and a.efftive_date+730 between '{1}' and '{2}' and a.tran_type='shipment' ", CompanyId, FromDate, ToDate))
            Else
                'Remove inquires the end date
                .AppendLine(String.Format(" where a.Qty>0 and c.MATERIAL_GROUP in ('PRODUCT') and a.customer_id='{0}' and a.efftive_date+730 >= '{1}'  and a.tran_type='shipment' ", CompanyId, FromDate))
            End If
            'End Ryan 20170420



            If txtPartNo.Text.Trim <> "" Then
                .AppendLine(String.Format(" and a.item_no like '{0}%' ", txtPartNo.Text.Trim.Replace("'", "")))
            End If
            '''''
            If txtserialno.Text.Trim <> "" Then
                ' Dim serndt As DataTable = dbUtil.dbGetDataTable("RFM", _
                'String.Format("select top 1 invoice_no,part_no from sap_invoice_sn where serial_number like '%{0}%' and serial_number is not null ", _
                '              txtserialno.Text.Trim))
                ' If Not IsNothing(serndt) And serndt.Rows.Count > 0 Then

                '    .AppendLine(String.Format("and a.item_no like '%{0}%' and a.billingdoc like '%{1}%'", serndt.Rows(0).Item("part_no").ToString.Trim, serndt.Rows(0).Item("invoice_no").ToString.Trim))
                'End If
                .AppendLine(String.Format(" and b.serial_number like '%{0}%'", txtserialno.Text.Trim))

            End If
            If PO_Number.Text.Trim <> "" Then
                .AppendLine(String.Format(" and b.PO_NO like '%{0}%'", PO_Number.Text.Trim))
            End If
            '''''
            .AppendLine(" order by a.efftive_date+730 ")
        End With
        'If Session("user_id") = "ming.zhao@advantech.com.cn" Then
        '    Response.Write(sb.ToString)
        'End If

        Return sb.ToString()
    End Function

    Public Property FromDate() As String
        Get
            If Date.TryParse(Me.txtFrom.Text, Now) Then
                Return CDate(Me.txtFrom.Text).ToString("yyyy/MM/dd")
            Else
                Me.txtFrom.Text = DateAdd(DateInterval.Month, -1, Now).ToString("yyyy/MM/dd")
                Return CDate(Me.txtFrom.Text).ToString("yyyy/MM/dd")
            End If
        End Get
        Set(ByVal value As String)
            If Date.TryParse(value, Now) Then
                Me.txtFrom.Text = CDate(value).ToString("yyyy/MM/dd")
            Else
                Me.txtFrom.Text = DateAdd(DateInterval.Month, -1, Now).ToString("yyyy/MM/dd")
            End If
        End Set
    End Property
    Public Property ToDate() As String
        Get
            If Date.TryParse(Me.txtTo.Text, Now) Then
                Return CDate(Me.txtTo.Text).ToString("yyyy/MM/dd")
            Else
                Me.txtTo.Text = DateAdd(DateInterval.Month, 3, Now).ToString("yyyy/MM/dd")
                Return CDate(Me.txtTo.Text).ToString("yyyy/MM/dd")
            End If
        End Get
        Set(ByVal value As String)
            If Date.TryParse(value, Now) Then
                Me.txtTo.Text = CDate(value).ToString("yyyy/MM/dd")
            Else
                Me.txtTo.Text = DateAdd(DateInterval.Month, 3, Now).ToString("yyyy/MM/dd")
            End If
        End Set
    End Property
    Public ReadOnly Property CompanyId() As String
        Get
            Return Session("company_id")
        End Get
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs)
        If Me.txtFrom.Text.Trim = "" Then Me.txtFrom.Text = FromDate
        'If Me.txtTo.Text.Trim = "" Then Me.txtTo.Text = ToDate
        If Me.txtTo.Text.Trim = "" Then Me.txtTo.Text = ""
    End Sub

    Protected Sub gv1_PageIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewPageEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_Sorting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSortEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub gv1_SelectedIndexChanging(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewSelectEventArgs)
        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub btnXls_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        If GetSql() <> "" Then
            Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", GetSql())
            dt.Columns.Add("Serial_Number")
            Dim arrInvNo As New ArrayList, arrPN As New ArrayList
            For Each r As DataRow In dt.Rows
                If r.Item("material_group").ToString = "PRODUCT" Then
                    If Not arrInvNo.Contains("'" + r.Item("invoice_no").ToString() + "'") Then arrInvNo.Add("'" + r.Item("invoice_no").ToString() + "'")
                    If Not arrPN.Contains("'" + r.Item("part_no").ToString() + "'") Then arrPN.Add("'" + r.Item("part_no").ToString() + "'")
                End If
            Next
            If arrInvNo.Count > 0 And arrPN.Count > 0 Then
                String.Join(",", arrInvNo.ToArray(GetType(String)))
                'Util.SendEmail("tc.chen@advantech.eu", "ebiz.aeu@advantech.eu", "", String.Format("select invoice_no, part_no, serial_number from sap_invoice_sn where serial_number is not null and invoice_no in ({0}) and part_no in ({1})", _
                '              String.Join(",", arrInvNo.ToArray(GetType(String))), String.Join(",", arrPN.ToArray(GetType(String)))), False, "", "")


                'Frank 20100/04/25:snArr.ToArray(GetType(String)) will return string[] not return string with ,
                'Dim sndt As DataTable = dbUtil.dbGetDataTable("RFM", _
                'String.Format("select invoice_no, part_no, serial_number from sap_invoice_sn where serial_number is not null and invoice_no in ({0}) and part_no in ({1})", _
                '              String.Join(",", arrInvNo.ToArray(GetType(String))), String.Join(",", arrPN.ToArray(GetType(String)))))

                'Frank 20120611 sap_invoice_sn was broken
                'Dim _sql As String = String.Format("select invoice_no, part_no, serial_number from sap_invoice_sn where serial_number is not null and invoice_no in ({0}) and part_no in ({1})", _
                '              String.Join(",", arrInvNo.ToArray()), String.Join(",", arrPN.ToArray()))
                Dim _sql As String = String.Format("select invoice_no, part_no, serial_number from sap_invoice_sn_v2 where serial_number is not null and invoice_no in ({0}) and part_no in ({1})", _
                              String.Join(",", arrInvNo.ToArray()), String.Join(",", arrPN.ToArray()))

                Dim sndt As DataTable = dbUtil.dbGetDataTable("RFM", _sql)


                For Each r As DataRow In dt.Rows
                    If r.Item("material_group").ToString = "PRODUCT" Then
                        Dim rs() As DataRow = sndt.Select("invoice_no='" + r.Item("invoice_no").ToString() + "' and part_no='" + r.Item("part_no") + "'")
                        Dim snArr As New ArrayList
                        For Each snr As DataRow In rs
                            snArr.Add(snr.Item("serial_number"))
                        Next
                        If snArr.Count > 0 Then
                            'Frank 20100/04/25:snArr.ToArray(GetType(String)) will return string[] not return string with ,
                            'r.Item("Serial_Number") = String.Join(",", snArr.ToArray(GetType(String)))
                            r.Item("Serial_Number") = String.Join(",", snArr.ToArray())
                        End If
                    End If
                Next
                dt.AcceptChanges()
                If dt.Rows.Count > 0 Then
                    dt.TableName = "WarrantyItems"
                    Util.DataTable2ExcelDownload(dt, "WarrantyExpiredItems.xls")

                End If
            End If
        End If
    End Sub

    Protected Sub btnQuery_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)

        src1.SelectCommand = GetSql()
    End Sub

    Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs)

    End Sub

    Protected Sub src1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 999999
    End Sub

    Protected Sub gv1_DataBound(ByVal sender As Object, ByVal e As System.EventArgs)
        'If gv1.Rows.Count > 0 Then
        '    btnXls.Visible = True
        '    'btnXls.Visible = False
        'Else
        '    btnXls.Visible = False
        'End If





    End Sub

    Function GetPNLink(ByVal modelno As String, ByVal partno As String) As String
        If Session("user_id") Like "*@*advantech*" Then
            Return String.Format("<a target='_blank' href='http://datamining.advantech.eu/Datamining/ProductProfile.aspx?PN={0}'>{0}</a>", partno)
        Else
            If modelno.Trim <> "" Then
                Return String.Format("<a target='_blank' href='/Product/model_detail.aspx?modelno={0}'>{1}</a>", modelno, partno)
            Else
                Return partno
            End If
        End If
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPartNo(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = UCase(Replace(Trim(prefixText), "'", "''"))
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select top 20 part_no from sap_product where part_no like '{0}%' and part_no not like '#%'", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function Getserialno(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = UCase(Replace(Trim(prefixText), "'", "''"))
        'Frank 20120611 sap_invoice_sn was broken
        'Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select DISTINCT top 20 serial_number from sap_invoice_sn where serial_number like '{0}%'", prefixText))
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select DISTINCT top 20 serial_number from sap_invoice_sn_v2 where serial_number like '{0}%'", prefixText))

        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPO_Number(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = UCase(Replace(Trim(prefixText), "'", "''"))
        'Frank 20120611 sap_invoice_sn was broken
        'Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select DISTINCT top 20  PO_NO from sap_invoice_sn where PO_NO like '{0}%'", prefixText))
        Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select DISTINCT top 20  PO_NO from sap_invoice_sn_v2 where PO_NO like '{0}%'", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function
    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim serial_number As String = System.Text.RegularExpressions.Regex.Replace(e.Row.Cells(3).Text, "<[^>]*>", String.Empty)
            If serial_number <> "" Then
                Dim dt As DataTable = dbUtil.dbGetDataTable("RFM", String.Format("select top 1 warranty_date from dbo.RMA_SFIS where barcode_no = '{0}'", serial_number.ToString.Trim))
                If Not IsNothing(dt) AndAlso dt.Rows.Count > 0 Then
                    e.Row.Cells(8).Text = Format(Convert.ToDateTime(dt.Rows(0).Item(0).ToString.Trim), "yyyy/MM/dd")
                End If
            End If
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:Panel ID="Panel_Form" runat="server" DefaultButton="btnQuery">
        <div class="root">
            <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
            >
            <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx"
                Text="Order Tracking" />
            > Warranty Expire
        </div>
        <table width="100%">
            <tr>
                <td valign="top">
                    <div class="left" style="width: 170px;">
                        <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="MyWarrantyExpireItems" />
                    </div>
                </td>
                <td>
                    <div class="right" style="width: 707px;">
                        <table width="100%">
                            <tr>
                                <td colspan="4">
                                    <table width="100%" height="29" border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="12" valign="top">
                                                <img src="../images/point.gif" width="7" height="14" />
                                            </td>
                                            <td align="left" class="h2">Warranty Expire
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="4"></td>
                            </tr>
                            <tr>
                                <!--
                                <td align="left" style="width: 150px" nowrap="nowrap">
                                    Warranty End Date
                                </td>
                            -->
                                <td width="40px">From:
                                </td>
                                <td width="80px">
                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender1" TargetControlID="txtFrom"
                                        Format="yyyy/MM/dd" />
                                    <asp:TextBox runat="server" ID="txtFrom" Width="70px" />
                                </td>
                                <td width="40px">To:
                                </td>
                                <td>
                                    <ajaxToolkit:CalendarExtender runat="server" ID="CalendarExtender2" TargetControlID="txtTo"
                                        Format="yyyy/MM/dd" />
                                    <asp:TextBox runat="server" ID="txtTo" Width="70px" />
                                </td>
                            </tr>
                        </table>
                        <table width="620px">
                            <tr>
                                <th align="left" style="width: 50px">Part No.
                                </th>
                                <td align="left">
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="ac1" TargetControlID="txtPartNo"
                                        CompletionInterval="100" ServiceMethod="GetPartNo" MinimumPrefixLength="1" />
                                    <asp:TextBox runat="server" ID="txtPartNo" Width="120px" />
                                </td>
                                <td align="right" style="width: 100px">
                                    <b>Serial Number. </b>
                                </td>
                                <td align="left">
                                    <asp:TextBox runat="server" ID="txtserialno" Width="120px" />
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="txtserialno"
                                        CompletionInterval="100" ServiceMethod="Getserialno" MinimumPrefixLength="1" />
                                </td>
                                <td align="right" style="width: 95px">
                                    <b>PO Number. </b>
                                </td>
                                <td align="left">
                                    <asp:TextBox runat="server" ID="PO_Number" Width="120px" />
                                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender2" TargetControlID="PO_Number"
                                        CompletionInterval="100" ServiceMethod="GetPO_Number" MinimumPrefixLength="1" />
                                </td>
                            </tr>
                        </table>
                        <table width="340px">
                            <tr>
                                <td align="center">
                                    <asp:ImageButton runat="server" ID="btnQuery" ImageUrl="~/Images/newgo.gif" AlternateText="Query"
                                        OnClick="btnQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <table width="100%">
            <tr>
                <td>
                    <asp:ImageButton Visible="true" runat="server" ID="btnXls" ImageUrl="~/Images/excel.gif"
                        AlternateText="Download Excel" OnClick="btnXls_Click" />
                    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                        <ContentTemplate>
                            <asp:GridView PagerSettings-Position="TopAndBottom" Width="97%" runat="server" ID="gv1"
                                AutoGenerateColumns="false" DataSourceID="src1" OnPageIndexChanging="gv1_PageIndexChanging"
                                OnSorting="gv1_Sorting" OnRowDataBound="gv1_RowDataBound" OnSelectedIndexChanging="gv1_SelectedIndexChanging"
                                AllowPaging="true" AllowSorting="true" PageSize="25" OnDataBound="gv1_DataBound">
                                <Columns>
                                    <asp:BoundField HeaderText="SO No." DataField="so_no" SortExpression="so_no" />
                                    <%-- <asp:BoundField HeaderText="Line No." DataField="line_no" SortExpression="line_no" />--%>
                                    <asp:BoundField HeaderText="Invoice No" DataField="invoice_no" SortExpression="invoice_no"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="serial number" DataField="serial_number" SortExpression="serial_number"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Invoice Qty." DataField="qty" SortExpression="qty" ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Currency" DataField="currency" SortExpression="currency"
                                        ItemStyle-HorizontalAlign="Center" />
                                    <asp:BoundField HeaderText="Amount" DataField="amount" SortExpression="amount" ItemStyle-HorizontalAlign="Right" />
                                    <asp:TemplateField HeaderText="Part No." SortExpression="part_no">
                                        <ItemTemplate>
                                            <%#GetPNLink(Eval("model_no"), Eval("part_no"))%>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField ItemStyle-HorizontalAlign="Center" HeaderText="Warranty End Date"
                                        DataField="warranty_end_date" SortExpression="warranty_end_date" />
                                    <asp:BoundField HeaderText="Material Group" DataField="material_group" SortExpression="material_group"
                                        Visible="false" />
                                    <asp:BoundField HeaderText="PO number" DataField="PO_number" SortExpression="PO_number"
                                        ItemStyle-HorizontalAlign="Center" />
                                </Columns>
                            </asp:GridView>
                            <asp:SqlDataSource runat="server" ID="src1" ConnectionString="<%$ConnectionStrings:RFM %>"
                                OnSelecting="src1_Selecting" />
                        </ContentTemplate>
                        <Triggers>
                            <asp:AsyncPostBackTrigger ControlID="btnQuery" EventName="Click" />
                        </Triggers>
                    </asp:UpdatePanel>
                    <%--<RK:ExportToExcel ID="ExportToExcel1" Visible="false"
                    runat="server" ApplyStyleInExcel ="True"
                    exportfilename="test.xls"
                    includetimestamp="true" PageSize="All"
                    text="Download to EXCEL"  OnPreExport="ExportToExcel1_PreExport" /> --%>
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>
