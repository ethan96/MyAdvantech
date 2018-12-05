<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- Forwarder Tracking" %>

<%@ Register TagPrefix="NaviOrderTracking" TagName="Inc" Src="~/Includes/OrderTrackingNavi_Inc.ascx" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>
<script runat="server">
    Dim xInvoiceNo As String = ""
    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Me.txtForwarderNo.Text.Trim = "" Then
                Me.txtForwarderNo.Text = Request("FORWARDER_NO")
            End If
            If Me.txtInvoiceNo.Text.Trim = "" Then
                Me.txtInvoiceNo.Text = Request("INVOICE_NO")
            End If
            If Me.txtSONo.Text.Trim = "" Then
                Me.txtSONo.Text = Request("so_no")
            End If
            If Me.txtPONo.Text.Trim = "" Then
                Me.txtPONo.Text = Request("po_no")
            End If

            If AuthUtil.IsBBUS Then
                Me.lb1.Text = "Tracking Number:"
                Me.lb2.Text = "Customer Purchase Order Number:"
            End If
        End If
        Call InitDataBound()
    End Sub

    Protected Sub InitDataBound()
        '--------
        Dim sb As New System.Text.StringBuilder
        With sb
            .AppendFormat(" select distinct b.vbeln as INVOICE_NO, ")
            .AppendFormat("(SELECT VBAK.BSTNK FROM saprdp.vbak WHERE VBAK.VBELN=b.AUBEL AND ROWNUM=1 and VBAK.MANDT='168') as PO_NO, ")
            .AppendFormat(" b.aubel AS SO_NO,")
            '.AppendFormat("b.vgbel as DN_NO, '' as forwarder, '' as forwarder_no,'' as forwarder_info
            .AppendFormat(" (select bolnr from saprdp.likp where vbeln= b.vgbel) as forwarder, '' as forwarder_no,'' as forwarder_info, ")
            '.AppendFormat("a.WAERK as CURRENCY,")
            '.AppendFormat("(SELECT MARA.PRDHA FROM SAPRDP.MARA WHERE MARA.MATNR=b.matnr AND ROWNUM=1 AND MARA.MANDT='168') as P_GROUP, ")
            '.AppendFormat("b.posnr AS LINE_NO, b.matnr AS PART_NO, b.fkimg as INVOICE_QTY, b.kzwi2 As TOTAL_PRICE, a.fkdat AS INVOICE_DATE, '' as UNIT_PRICE ")
            .AppendFormat("  a.fkdat AS ship_date, ltrim(b.vgbel, '0') as outbound_dn ")
            .AppendFormat(" from saprdp.vbrk a inner join saprdp.vbrp b on a.vbeln=b.vbeln ")
            .AppendFormat(" where a.kunag ='{0}' and a.mandt='168' and b.mandt='168'", Session("COMPANY_ID"))
            '.AppendFormat(" and a.fkdat BETWEEN '{0}' AND '{1}'", Replace(Me.txtinvdate_from.Text.Trim, "/", ""), Replace(Me.txtinvdate_to.Text.Trim, "/", ""))

            'Dim inv_no As String = "00" & Me.txtinv_no.Text.Trim
            'If Me.txtinv_no.Text.Trim <> "" Then
            '    .AppendFormat(" and  a.vbeln ='{0}'", inv_no) '00" & Me.txtinv_no.Text.Trim & "' "
            'End If
            'If Me.txtso_no.Text.Trim <> "" Then
            '    .AppendFormat(" and b.aubel ='{0}'", Me.txtso_no.Text.Trim)
            'End If
            'If Me.txtdn_no.Text.Trim <> "" Then
            '    .AppendFormat(" and b.vgbel like '%{0}%'", Me.txtdn_no.Text.Trim)
            'End If
            'If Me.txtpart_no.Text.Trim <> "" Then
            '    .AppendFormat(" and b.matnr like '%{0}%'", Me.txtpart_no.Text.Trim)
            'End If
            '.AppendFormat(" and b.matnr not like '0%'")
            '''''''''''''''''''

            If Me.txtInvoiceNo.Text.Trim <> "" Then
                ' l_strWhere = l_strWhere + " and a.InvoiceNo = '00" & Me.txtInvoiceNo.Text.Trim & "' "
                .AppendFormat(" and b.vbeln like '%" & Me.txtInvoiceNo.Text.Trim.ToUpper & "%'")
            End If

            If Me.txtSONo.Text.Trim <> "" Then
                'l_strWhere = l_strWhere + " and a.OrderNo = '" & Me.txtSONo.Text.Trim & "' "
                .AppendFormat(" and b.aubel like '%" & Me.txtSONo.Text.Trim.ToUpper & "%'")
            End If
            .AppendFormat(" and rownum <= 5000 order by a.fkdat desc")
        End With
        '--------
        'Dim T_strSQL, l_strSQLCmd, l_strWhere As String
        'l_strSQLCmd = "select distinct a.InvoiceNo as INVOICE_NO, " & _
        '              "a.PONo as PO_NO, " & _
        '              "a.OrderNo as SO_NO, " & _
        '              "b.SchdLineDeliveryDate as SHIP_DATE, " & _
        '              "b.DNForwardInfo as FORWARDER, " & _
        '              "b.DNForwardInfo as FORWARDER_NO, " & _
        '              "'' as FORWARDER_INFO " & _
        '              "from factShipment a " & _
        '              "inner join factOrder b " & _
        '              "on a.ReferenceDoc = b.DNNo and a.ReferenceDocLine = b.DNLine "

        'l_strWhere = "where " & _
        '             "a.InvoiceStatus = 'Valid' and a.CustomerID='" & Session("COMPANY_ID") & "' "

        'If Me.txtForwarderNo.Text.Trim <> "" Then
        '    l_strWhere = l_strWhere + " and b.DNForwardInfo Like '%" & Me.txtForwarderNo.Text.Trim & "%' "
        'End If

        'If Me.txtInvoiceNo.Text.Trim <> "" Then
        '    l_strWhere = l_strWhere + " and a.InvoiceNo = '00" & Me.txtInvoiceNo.Text.Trim & "' "
        'End If

        'If Me.txtSONo.Text.Trim <> "" Then
        '    l_strWhere = l_strWhere + " and a.OrderNo = '" & Me.txtSONo.Text.Trim & "' "
        'End If

        'If Me.txtPONo.Text.Trim <> "" Then
        '    l_strWhere = l_strWhere + " and a.PONo = '" & Me.txtPONo.Text.Trim & "' "
        'End If

        'T_strSQL = l_strSQLCmd + l_strWhere + " order by b.SchdLineDeliveryDate desc,a.InvoiceNo "
        '------------

        ' ViewState("SqlCommand") = ""
        'Me.SqlDataSource1.SelectCommand = sb.ToString()
        'ViewState("SqlCommand") = Me.SqlDataSource1.SelectCommand
        '-------------------------------------
        Dim dt As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sb.ToString())
        If Me.txtForwarderNo.Text.Trim <> "" Then
            For Each r As DataRow In dt.Rows
                If IsDBNull(r.Item("forwarder")) OrElse Not r.Item("forwarder").ToString.Contains(Me.txtForwarderNo.Text.Trim.ToUpper) Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()

        End If
        If Me.txtPONo.Text.Trim <> "" Then
            For Each r As DataRow In dt.Rows
                If IsDBNull(r.Item("PO_NO")) OrElse r.Item("PO_NO") <> Me.txtPONo.Text.Trim.ToUpper Then
                    r.Delete()
                End If
            Next
            dt.AcceptChanges()

        End If
        gv1.DataSource = dt
        gv1.DataBind()
        '------------------------------------------

        If Not Page.IsPostBack Or Me.SearchFlag.Text = "YES" Then Me.SearchFlag.Text = "NO"

    End Sub

    Protected Sub submit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        Me.SearchFlag.Text = "YES"
        Me.InitDataBound()
    End Sub

    Protected Sub SqlDataSource1_Load(ByVal sender As Object, ByVal e As System.EventArgs)
        If ViewState("SqlCommand") = "" Then

        Else
            SqlDataSource1.SelectCommand = ViewState("SqlCommand")
        End If
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            Dim lStart As String = "", rEnd As String = ""
            If xInvoiceNo <> e.Row.Cells(1).Text Then
                lStart = "<b>" : rEnd = "</b>" : xInvoiceNo = e.Row.Cells(1).Text
            Else
                lStart = "" : rEnd = "" : xInvoiceNo = e.Row.Cells(1).Text
            End If
            e.Row.Cells(1).Text = lStart & CInt(e.Row.Cells(1).Text) & rEnd
            e.Row.Cells(2).Text = lStart & e.Row.Cells(2).Text & rEnd
            e.Row.Cells(3).Text = lStart & e.Row.Cells(3).Text & rEnd
            e.Row.Cells(4).Text = Global_Inc.FormatDate(e.Row.Cells(4).Text)
            If e.Row.Cells(5).Text <> "" Then
                e.Row.Cells(5).Text = e.Row.Cells(5).Text.Replace(":", "").Trim

                Select Case UCase(Left(e.Row.Cells(5).Text, 3))
                    Case "TNT"
                        e.Row.Cells(7).Text = "<a href=""http://www.tnt.de/servlet/Tracking?openDocument=&cons=" & Mid(e.Row.Cells(5).Text, 4) & "&trackType=CON&genericSiteIdent=&page=1&respLang=de&respCountry=DE&sourceID=1&sourceCountry=ww&plazakey=&refs=" & Mid(e.Row.Cells(5).Text, 4) & "&requestType=GEN&searchType=CON&navigation=0"" target=""_blank""><img src=""../images/lg_tnt_s.jpg"" border=""0""></a>"
                        e.Row.Cells(6).Text = UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 3), "")).Trim
                        e.Row.Cells(5).Text = UCase(Left(e.Row.Cells(5).Text, 3)).Trim
                        'e.Row.Cells(7).Text = "<a href=""http://www.tnt.com/webtracker/tracking.do?respLang=en&respCountry=GENERIC&genericSiteIdent=.&searchType=CON&cons=" & UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 3), "")) & "&respLang=en&respCountry=GENERIC&page=1&sourceID=1&sourceCountry=ww&plazakey=&refs=&requesttype=GEN&navigation=1"" target=""_blank""><img src=""../images/lg_tnt_s.jpg"" border=""0""></a>"

                    Case "UPS"
                        e.Row.Cells(7).Text = "<a href=""http://www.ups.com/WebTracking/track?loc=en_NL&WT.svl=PriNav&trackNums=" & Mid(e.Row.Cells(5).Text, 4) & """ target=""_blank""><img src=""../images/lg_ups_s.gif"" border=""0""></a>"
                        e.Row.Cells(6).Text = UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 3), "")).Trim
                        e.Row.Cells(5).Text = UCase(Left(e.Row.Cells(5).Text, 3)).Trim

                    Case "DHL"
                        e.Row.Cells(7).Text = "<a href=""http://www.dhl.nl/index_e.html"" target=""_blank""><img src=""../images/lg_dhl_s.jpg"" border=""0""></a>"
                        e.Row.Cells(6).Text = UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 3), "")).Trim
                        e.Row.Cells(5).Text = UCase(Left(e.Row.Cells(5).Text, 3)).Trim

                    Case Else
                        'Ryan 20171026 FedEx case here, due to switch case only take first 3 digits...
                        'Alex 20180118 B+B warehouse will enter more freight in SAP, ie CUSTOMER,USMAIL,FREIGHT
                        If UCase(Left(e.Row.Cells(5).Text, 5).Equals("FEDEX")) Then
                            e.Row.Cells(6).Text = UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 5), "")).Trim
                            e.Row.Cells(5).Text = UCase(Left(e.Row.Cells(5).Text, 5)).Trim

                            If AuthUtil.IsBBUS Then
                                e.Row.Cells(7).Text = "<a href=""https://www.fedex.com/apps/fedextrack/?action=track&tracknumbers=" + e.Row.Cells(6).Text.Trim + "&locale=en_US&cntry_code=us "" target=""_blank""><img src=""../images/lg_fedex_s.png"" border=""0""></a>"
                            End If
                        ElseIf UCase(Left(e.Row.Cells(5).Text, 8).Equals("CUSTOMER")) Then
                            e.Row.Cells(6).Text = UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 8), "")).Trim
                            e.Row.Cells(5).Text = UCase(Left(e.Row.Cells(5).Text, 8)).Trim
                            e.Row.Cells(7).Text = ""
                        ElseIf UCase(Left(e.Row.Cells(5).Text, 6).Equals("USMAIL")) Then
                            e.Row.Cells(6).Text = UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 6), "")).Trim
                            e.Row.Cells(5).Text = UCase(Left(e.Row.Cells(5).Text, 6)).Trim
                            e.Row.Cells(7).Text = ""
                        ElseIf UCase(Left(e.Row.Cells(5).Text, 7).Equals("FREIGHT")) Then
                            e.Row.Cells(6).Text = UCase(Replace(e.Row.Cells(5).Text, Left(e.Row.Cells(5).Text, 7), "")).Trim
                            e.Row.Cells(5).Text = UCase(Left(e.Row.Cells(5).Text, 7)).Trim
                            e.Row.Cells(7).Text = ""
                        Else
                            'e.Row.Cells(6).Text = e.Row.Cells(5).Text
                            'e.Row.Cells(5).Text = ""
                            e.Row.Cells(7).Text = ""
                        End If
                End Select
            Else
                e.Row.Cells(5).Text = "" : e.Row.Cells(6).Text = "" : e.Row.Cells(7).Text = ""
            End If
        End If
        If e.Row.RowType = DataControlRowType.Header Or e.Row.RowType = DataControlRowType.DataRow Then
            If AuthUtil.IsBBUS Then
                e.Row.Cells(6).Visible = True
                e.Row.Cells(8).Visible = True
            Else
                e.Row.Cells(6).Visible = False
                e.Row.Cells(8).Visible = False
            End If
        End If
    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        'gv1.AllowPaging = False
        'gv1.DataBind()
        'gv1.Export2Excel("Forwarder.xls")

        Util.DataTable2ExcelDownload(CType(gv1.DataSource, DataTable), "Forwarder.xls")

    End Sub
</script>

<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <asp:Panel ID="Panel_Form" runat="server" DefaultButton="submit">
        <div class="root">
            <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
            >
            <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx"
                Text="Order Tracking" />
            > Forwarder Tracking
        </div>
        <table width="100%">
            <tr>
                <td valign="top">
                    <div class="left" style="width: 170px;">
                        <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="BO_ForwarderTracking" />
                    </div>
                </td>
                <td>
                    <div class="right" style="width: 707px;">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td height="9"></td>
                            </tr>
                            <tr>
                                <td height="24" class="h2">
                                    <table border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td width="12" valign="top">
                                                <img src="../images/point.gif" width="7" height="14" />
                                            </td>
                                            <td>Forwarder Tracking
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="rightcontant3">
                                        <tr>
                                            <td colspan="3">
                                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td height="20" colspan="3"></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3"></td>
                                        </tr>
                                        <tr>
                                            <td width="3%"></td>
                                            <td>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td class="h5" height="30"><asp:Label id="lb1" runat="server" Text="Forwarder Number:"></asp:Label>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txtForwarderNo" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                        <td></td>
                                                        <td class="h5">Invoice Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace3" ServiceMethod="GetInvoiceNo"
                                                                TargetControlID="txtInvoiceNo" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtInvoiceNo" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30">SO Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" ServiceMethod="GetSO"
                                                                TargetControlID="txtSONo" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtSONo" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                        <td></td>
                                                        <td class="h5" height="30"><asp:Label id="lb2" runat="server" Text="PO Number:"></asp:Label>
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace2" ServiceMethod="GetPO"
                                                                TargetControlID="txtPONo" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtPONo" runat="server" Width="95px"></asp:TextBox>
                                                        </td>                                                        
                                                    </tr>
                                                    <tr>
                                                        <td class="h5"></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td class="h5"></td>
                                                        <td align="right">
                                                            <asp:Label runat="server" ID="SearchFlag" Text="NO" Visible="false"></asp:Label>
                                                            <asp:ImageButton runat="server" ID="submit" ImageUrl="~/Images/search1.gif" OnClick="submit_Click" />
                                                        </td>
                                                </table>
                                            </td>
                                            <td width="3%"></td>
                                        </tr>
                                        <tr>
                                            <td height="20" colspan="3"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <table>
            <tr>
                <td>
                    <div>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td height="10" colspan="2">
                                    <img src="../images/line3.gif" width="889" height="1" />
                                </td>
                            </tr>
                            <tr height="30">
                                <td>
                                    <table>
                                        <tr>
                                            <td width="20px">
                                                <asp:ImageButton runat="server" ID="btnToXls1" ImageUrl="~/images/excel.gif" OnClick="btnToXls_Click" />
                                            </td>
                                            <td>
                                                <asp:LinkButton runat="server" ID="btnToXls" Text="Export To Excel" Font-Size="12px"
                                                    ForeColor="#f29702" Font-Bold="true" OnClick="btnToXls_Click" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="false" AllowSorting="false"
                                        PageSize="20" Width="100%" ShowWhenEmpty="true" OnRowDataBound="gv1_RowDataBound"
                                        RowStyle-Height="21">
                                        <Columns>
                                            <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                                <HeaderTemplate>
                                                    No.
                                                </HeaderTemplate>
                                                <ItemTemplate>
                                                    <%# Container.DataItemIndex + 1 %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField HeaderText="Invoice NO." DataField="INVOICE_NO" SortExpression="INVOICE_NO" />
                                            <asp:BoundField HeaderText="PO NO." DataField="PO_NO" SortExpression="PO_NO" />
                                            <asp:BoundField HeaderText="SO NO." DataField="SO_NO" SortExpression="SO_NO" />
                                            <asp:BoundField HeaderText="Ship Date" DataField="SHIP_DATE" SortExpression="SHIP_DATE" />
                                            <asp:BoundField HeaderText="Forwarder" DataField="FORWARDER" SortExpression="FORWARDER" />
                                            <asp:BoundField HeaderText="Forwarder NO." DataField="FORWARDER_NO" SortExpression="FORWARDER_NO" />
                                            <asp:BoundField HeaderText="Link2" DataField="FORWARDER_INFO" />
                                            <asp:BoundField HeaderText="Outbound Delivery Number" DataField="outbound_dn" />
                                        </Columns>
                                        <FixRowColumn FixColumns="-1" FixRows="-1" TableHeight="700px" FixRowType="Header" />
                                        <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                        <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                        <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                        <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify" />
                                        <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                        <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                        <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                    </sgv:SmartGridView>
                                    <asp:SqlDataSource runat="server" ID="SqlDataSource1" ConnectionString="<%$ ConnectionStrings:SAP_PRD %>"
                                        SelectCommand="" OnLoad="SqlDataSource1_Load"></asp:SqlDataSource>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>
