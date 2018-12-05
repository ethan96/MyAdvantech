<%@ Page Language="VB" MasterPageFile="~/Includes/MyMaster.master" Title="MyAdvantech -- Serial Number Inquiry" EnableEventValidation="false" %>

<%@ Register TagPrefix="NaviOrderTracking" TagName="Inc" Src="~/Includes/OrderTrackingNavi_Inc.ascx" %>
<%@ Register TagPrefix="OrderTrackingLinks" TagName="Links" Src="~/Includes/BO_Links.ascx" %>
<script runat="server">

    Private Sub page_load(ByVal sender As Object, ByVal e As System.EventArgs)
        If Request("FileId") IsNot Nothing AndAlso Request("DLType") IsNot Nothing AndAlso Request("SONO") IsNot Nothing Then
            Dim DLLink = "" : Dim iFSLink = getIFSURLBySO(Request("SONO"))
            Select Case Request("DLType")
                Case "INS"
                    DLLink = String.Format("http://{0}/api/sheet/download?custCode={1}&fileId={2}", iFSLink, Session("company_id"), Request("FileId"))
                Case "BURN"
                    DLLink = String.Format("http://{0}/api/passmark/dwnloadrslt?custCode={1}&fileId={2}", iFSLink, Session("company_id"), Request("FileId"))
            End Select
            Dim wc = New System.Net.WebClient(), FileName = String.Empty
            Dim File = wc.DownloadData(DLLink)
            Response.Clear()
            If Not String.IsNullOrEmpty(wc.ResponseHeaders("Content-Disposition")) Then
                FileName = wc.ResponseHeaders("Content-Disposition").Substring(wc.ResponseHeaders("Content-Disposition").IndexOf("filename=") + 9).Replace("\", "")
                Response.AddHeader("content-disposition", "attachment;filename='" + FileName + "'")
                Response.BinaryWrite(File)
            Else
                Response.Write("The requested file is not available")
            End If
            Response.End()
        End If
        If Not Page.IsPostBack Then
            If Me.txtInvoice_no.Text.Trim = "" Then
                Me.txtInvoice_no.Text = Request("Invoice_no")
            End If
            If Me.txtso_no.Text.Trim = "" Then
                Me.txtso_no.Text = Request("so_no")
            End If
            If Me.txtpo_no.Text = "" Then
                Me.txtpo_no.Text = Request("po_no")
            End If
            initSearch()

            If Util.IsInternalUser2() Then
                Dim HasCellularRouterOrderHistory As Integer = CInt(dbUtil.dbExecuteScalar("MY",
        " select count(item_no) as items from EAI_SALE_FACT a (nolock) " +
        " where a.edivision='Cellular Router' and a.Tran_Type='Shipment' " +
        " and a.Customer_ID='" + Session("company_id") + "' and a.efftive_date>=getdate()-365"))
                If HasCellularRouterOrderHistory > 0 Then btnToMACIMEI.Visible = True
            End If

            '20180502 TC: Per AEU CTOS's request, let AEU customer download inspection sheet and burn-in result from iCTOS server
            If Session("org_id").ToString() = "EU10" AndAlso Util.IsInternalUser2() Then
                gv1.Columns(gv1.Columns.Count - 1).Visible = True
            End If

        End If
    End Sub
    'Function checkCompany(ByVal company As String) As Boolean
    '    If company.ToUpper = Session("company_id").ToString.ToUpper Then
    '        Return True
    '    End If
    '    Return False
    'End Function
    Private Sub initSearch()
        Dim strCompanyId As String = Session("company_id").ToString().ToUpper()

        Dim l_strSQLCmd As String = "", whereStr As String = ""

        l_strSQLCmd = " select distinct * from ( Select top 1000 a.SO_NO as OrderNo, a.DN_NO as DN, a.OBJECTLINESERIALNO as SEQLINE, a.PART_NO as MaterialNo, a.PO_NO as PONo," +
" b.Customer_ID as SOLDTO, a.INVOICE_NO as InvoiceNo, a.OBJECTLINESERIALNO as ObjectLineSerialNo," +
" a.SERIAL_NUMBER, b.order_date, b.efftive_date" +
" From SAP_INVOICE_SN_V2 a inner join EAI_sale_fact b on a.SO_NO=b.order_no and a.PART_NO=b.item_no and a.INVOICE_NO=b.BillingDoc" +
" Where b.Customer_ID='" & strCompanyId & "'"



        If Me.txtInvoice_no.Text <> "" Then
            whereStr = " AND a.INVOICE_NO like N'%" & Replace(Replace(Me.txtInvoice_no.Text.Trim.ToUpper, "'", "''"), "*", "%") & "%'"
        End If
        If Me.txtso_no.Text <> "" Then
            whereStr = " AND a.SO_NO like N'%" & Replace(Replace(Me.txtso_no.Text.Trim.ToUpper, "'", "''"), "*", "%") & "%'"
        End If
        If Me.txtpo_no.Text <> "" Then
            whereStr = " AND a.PO_NO like N'%" & Replace(Replace(Me.txtpo_no.Text.Trim.ToUpper, "'", "''"), "*", "%") & "%'"
        End If
        If Me.txtPN.Text <> "" Then
            whereStr = " AND a.PART_NO like N'%" & Replace(Replace(Me.txtPN.Text.Trim.ToUpper, "'", "''"), "*", "%") & "%'"
        End If
        l_strSQLCmd &= whereStr
        l_strSQLCmd &= " order by a.SO_NO, a.PART_NO, a.SERIAL_NUMBER ) T  "
        'Response.Write(l_strSQLCmd)
        Dim oDB As DataTable = dbUtil.dbGetDataTable("MY", l_strSQLCmd)

        'Response.Write(oDB.Rows.Count.ToString())
        If oDB.Rows.Count > 0 Then


        End If
        oDB.DefaultView.Sort = "SEQLINE ASC"
        gv1.DataSource = oDB : ViewState("ODB") = oDB : gv1.DataBind()
    End Sub

    Protected Sub submit_Click(ByVal sender As Object, ByVal e As System.Web.UI.ImageClickEventArgs)
        initSearch()
    End Sub

    Protected Sub gv1_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            e.Row.Attributes.Add("onmouseover", "currentcolor=this.style.backgroundColor;this.style.backgroundColor='#FFEEAA'")
            e.Row.Attributes.Add("onmouseout", "this.style.backgroundColor=currentcolor")
            If e.Row.Cells(2).Text <> "" Then
                e.Row.Cells(2).Text = "<a href='BO_ordertracking.aspx?company_id=" & Session("company_id") & "&so_no=" & e.Row.Cells(2).Text & "' target='_blank'>" & e.Row.Cells(2).Text & "</a>"
            Else
                e.Row.Cells(2).Text = "&nbsp;"
            End If
            e.Row.Cells(3).Text = Global_Inc.DeleteZeroOfStr(e.Row.Cells(3).Text)
            e.Row.Cells(5).Text = Global_Inc.DeleteZeroOfStr(e.Row.Cells(5).Text)
        End If
    End Sub

    Protected Sub btnToXls_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim DT As DataTable = CType(ViewState("ODB"), DataTable)
        If DT.Rows.Count > 0 Then
            DT.TableName = " Serial Number"
            Util.DataTable2ExcelDownload(DT, "Serial_Number.xls")
        End If
    End Sub

    Protected Sub SqlDataSource1_Selecting(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.SqlDataSourceSelectingEventArgs)
        e.Command.CommandTimeout = 1200
    End Sub

    Protected Sub btnToMACIMEI_Click(sender As Object, e As EventArgs)
        Dim sqlGetSNMACIMEI =
            " select t.invoice_no, t.so_no, t.po_no, t.dn_no, t.part_no " +
            " , c.SERNR as serial_number, d.MACADR, d.IMEI1ADR, d.IMEI2ADR, d.SS_NO as Manufacture_SN " +
            " from " +
            " ( " +
            " select ltrim(a.vbeln,'0') as invoice_no, ltrim(a.aubel,'0') as so_no, " +
            " (select bstnk from saprdp.vbak where vbak.vbeln=a.aubel and rownum=1 and mandt='168') as po_no, " +
            " a.vgbel as dn_no, a.matnr as part_no, a.VGPOS,a.VGBEL " +
            " from saprdp.vbrp a inner join saprdp.vbrk b on a.vbeln=b.vbeln " +
            " where a.mandt='168' and b.mandt='168' " +
            " and a.erdat>=to_char(sysdate-180,'yyyyMMdd') and b.kunag='" + Session("company_id") + "' " +
            IIf(String.IsNullOrEmpty(txtso_no.Text), "", "and a.aubel = '" + txtso_no.Text + "'") +
            " ) T " +
            " inner join SAPRDP.SER01 b on T.VGBEL=b.LIEF_NR AND T.VGPOS=b.POSNR " +
            " inner join SAPRDP.OBJK c on b.OBKNR=c.OBKNR " +
            " inner join saprdp.ZTSD_137 d on c.SERNR=d.SERNR and T.part_no=d.matnr " +
            " WHERE b.mandt='168' and c.mandt='168' and d.mandt='168' "
        Dim dtSNMACIMEI As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sqlGetSNMACIMEI)
        Util.DataTable2ExcelDownload(dtSNMACIMEI, "SN_MAC_IMEI.xls")
    End Sub

    Public Shared Function getIFSURLBySO(ByVal SONO As String) As String
        Dim iFSURL = "ifs.advantech.eu"
        Dim dtDlvPlant = OraDbUtil.dbGetDataTable("SAP_PRD", String.Format("select VSTEL from saprdp.vbap where vbeln='{0}' and matkl='BTOS'", Global_Inc.SONoBuildSAPFormat(SONO.ToUpper())))
        If (dtDlvPlant.Rows.Count > 0) Then
            Select Case dtDlvPlant.Rows(0).Item("VSTEL").ToString()
                Case "EUH1"
                    iFSURL = "ifs.advantech.eu"
                Case "EUH2"
                    iFSURL = "ifs.advantech.pl"
            End Select
        End If
        Return iFSURL
    End Function

    <Services.WebMethod()>
    <Web.Script.Services.ScriptMethod()>
    Public Shared Function GetInsBurn(ByVal SONO As String) As String
        Dim iFSURL = getIFSURLBySO(SONO), CustCode = HttpContext.Current.Session("company_id")

        'iFSURL = "172.21.34.114"
        'CustCode = "EIITAN02" : SONO = "FU813346"
        Dim wc = New System.Net.WebClient()
        Dim strXml = wc.DownloadString(String.Format("http://{0}/api/sheet/getfiles?custCode={1}&order={2}", iFSURL, CustCode, SONO))
        strXml = strXml.Substring(1) : strXml = strXml.Substring(0, strXml.Length - 1)
        Dim DLLinks As New List(Of InsBurnURL)
        If strXml.Length > 0 Then
            Dim FileIDs = Split(strXml, ",")
            For idx As Integer = 0 To FileIDs.Length - 1
                FileIDs(idx) = FileIDs(idx).Substring(1) : FileIDs(idx) = FileIDs(idx).Substring(0, FileIDs(idx).Length - 1)
            Next

            For idx As Integer = 0 To FileIDs.Length - 1
                DLLinks.Add(New InsBurnURL() With {
                            .DLType = "Inspection Sheet",
                            .DLLink = String.Format(IO.Path.GetFileName(HttpContext.Current.Request.PhysicalPath) + "?DLType=INS&fileId={0}&SONO={1}", FileIDs(idx), SONO),
                            .Name = FileIDs(idx)
                            })
            Next
            For idx As Integer = 0 To FileIDs.Length - 1
                DLLinks.Add(New InsBurnURL() With {
                            .DLType = "Burn-In Result",
                            .DLLink = String.Format(IO.Path.GetFileName(HttpContext.Current.Request.PhysicalPath) + "?DLType=BURN&fileId={0}&SONO={1}", FileIDs(idx), SONO),
                            .Name = FileIDs(idx)
                            })
            Next
        End If
        Dim serializer As New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(DLLinks)

    End Function

    Class InsBurnURL
        Public Property DLType As String : Public Property DLLink As String : Public Property Name As String
    End Class

</script>
<asp:Content runat="server" ID="_main" ContentPlaceHolderID="_main">
    <link href="../Includes/js/jquery-ui.css" rel="stylesheet" />
    <script type="text/javascript" src="../EC/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../EC/jquery-ui.js"></script>
    <script type="text/javascript" src="../EC/json2.js"></script>
    <script type="text/javascript">
        $(document).ready(
            function () {
                //ShowInsBurn('FU813346');
            }
        );

        function ShowInsBurn(SONO) {
            var postData = JSON.stringify({ SONO: SONO });
                $.ajax(
                {
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetInsBurn", data: postData,
                    contentType:"application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        $("#tbBTOInsBurn").empty();
                        var dllines = $.parseJSON(retData.d); var dlHtml = "";
                        $.each(dllines,
                                function (idx, item) {
                                    //console.log(item.Name);
                                    dlHtml += "<tr><th>" + item.DLType + "</th><td><a target='_blank' href='"+item.DLLink+"'>"+item.Name+"</a></td></tr>";
                                }                                
                            );
                        $("#tbBTOInsBurn").html(dlHtml);
                        $("#divBTOInsBurn").dialog({
                            modal: true,
                            width: $(window).width()*0.5,
                            height: $(window).height()*0.5,
                            title: 'Inspection Sheet & Burn-In Result',
                            open: function (event, ui) { }
                        });
                    }
                });
        }

    </script>
    <div class="root">
        <asp:HyperLink runat="server" ID="hlHome" NavigateUrl="~/home.aspx" Text="Home" />
        >
        <asp:HyperLink runat="server" ID="hlHere" NavigateUrl="~/Order/BO_OrderTracking.aspx"
            Text="Order Tracking" />
        > Serial Inquiry
    </div>
    <table width="100%">
        <tr>
            <td valign="top">
                <div class="left" style="width: 170px;">
                    <OrderTrackingLinks:Links ID="BOlinks" runat="server" ClickLinkName="BO_SerialInquiry" />
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
                                        <td>Serial Number
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
                                            <asp:Panel runat="server" ID="PanelSearch" DefaultButton="submit">
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td class="h5" height="30">Invoice Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace1" ServiceMethod="GetInvoiceNo"
                                                                TargetControlID="txtInvoice_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                FirstRowSelected="true" CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtInvoice_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                        <td></td>
                                                        <td class="h5">PO Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace3" ServiceMethod="GetPO"
                                                                TargetControlID="txtpo_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                FirstRowSelected="true" CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtpo_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30">SO Number:
                                                        </td>
                                                        <td>
                                                            <ajaxToolkit:AutoCompleteExtender runat="server" ID="ace2" ServiceMethod="GetSO"
                                                                TargetControlID="txtso_no" ServicePath="~/Services/AutoComplete.asmx" MinimumPrefixLength="0"
                                                                FirstRowSelected="true" CompletionInterval="1000" />
                                                            <asp:TextBox ID="txtso_no" runat="server" Width="95px"></asp:TextBox>
                                                        </td>
                                                        <td></td>
                                                        <td class="h5">Part Number:
                                                        </td>
                                                        <td>
                                                            <asp:TextBox runat="server" ID="txtPN" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="h5" height="30"></td>
                                                        <td></td>
                                                        <td></td>
                                                        <td class="h5"></td>
                                                        <td align="right">
                                                            <asp:Label runat="server" ID="Label1" Text="NO" Visible="false"></asp:Label>
                                                            <asp:ImageButton runat="server" ID="submit" ImageUrl="~/Images/search1.gif" OnClick="submit_Click" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </asp:Panel>
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
                                        <td>
                                            <asp:LinkButton runat="server" ID="btnToMACIMEI" Visible="false"
                                                Font-Size="12px" ForeColor="#23316d" Font-Bold="true"
                                                Text="Download Cellular Router's SN/MAC/IMEI" OnClick="btnToMACIMEI_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <sgv:SmartGridView runat="server" ID="gv1" AutoGenerateColumns="False" Width="100%"
                                    ShowWhenEmpty="True" OnRowDataBound="gv1_RowDataBound">
                                    <Columns>
                                        <asp:TemplateField ItemStyle-Width="50px" ItemStyle-HorizontalAlign="Center">
                                            <HeaderTemplate>
                                                No.
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <%# Container.DataItemIndex + 1 %>
                                            </ItemTemplate>
                                            <ItemStyle HorizontalAlign="Center" Width="50px"></ItemStyle>
                                        </asp:TemplateField>
                                        <asp:BoundField HeaderText="PO NO." DataField="PONo" />
                                        <asp:BoundField HeaderText="SO NO" DataField="OrderNo" />
                                        <asp:BoundField HeaderText="Invoice No." DataField="InvoiceNo" />
                                        <asp:BoundField HeaderText="Part No" DataField="MaterialNo" />
                                        <asp:BoundField HeaderText="Serial NO." DataField="SERIAL_NUMBER" />
                                        <asp:TemplateField HeaderText="Inspection Sheet/Burn-In Result" Visible="false" ItemStyle-HorizontalAlign="Center">
                                            <ItemTemplate>
                                                <a href="javascript:void(0);" onclick="ShowInsBurn('<%#Eval("OrderNo") %>')">Go</a>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                    <FooterStyle BackColor="#A4B5BD" ForeColor="White" Font-Bold="True" />
                                    <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                                    <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                                    <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Justify" />
                                    <HeaderStyle BackColor="#A4B5BD" Font-Bold="True" ForeColor="White" />
                                    <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                                    <PagerSettings PageButtonCount="10" Position="TopAndBottom" />
                                </sgv:SmartGridView>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>
    <div id="divBTOInsBurn" style="overflow: auto">
        <table id="tbBTOInsBurn" style="width:95%"></table>
    </div>
</asp:Content>
