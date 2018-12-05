<%@ Page Title="MyAdvantech - BTOS Order History Inquiry" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server"> 

    Class QueryOrderCriteria
        Public Property PONO As String : Public Property SONO As String : Public Property OrderDateFrom As String : Public Property OrderDateTo As String
        Public Property StartIdx As Integer : Public Property RowCount As Integer
    End Class

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function SearchBTOOrderList(ByVal QueryOrderCriteria1 As QueryOrderCriteria) As String
        Dim cultureUS As New System.Globalization.CultureInfo("en-US")
        Dim sbSql As New System.Text.StringBuilder
        With sbSql
            .AppendLine(" select * ")
            .AppendLine(" from ")
            .AppendLine(" ( ")
            .AppendLine("   select rownum as ridx, a.* ")
            .AppendLine("   from ")
            .AppendLine("   ( ")
            .AppendLine("     select a.VBELN as SO_NO, a.VKORG as SALES_ORG, a.BSTNK as PO_NO,  ")
            .AppendLine("     to_date(a.ERDAT,'yyyy/MM/dd') as ORDER_DATE, b.POSNR as LINE_NO, b.MATNR as PART_NO,b.ARKTX as DESCR ")
            .AppendLine("     FROM SAPRDP.VBAK a INNER JOIN SAPRDP.VBAP b ON a.VBELN = b.VBELN ")
            .AppendLine("     where a.MANDT='168' and b.MANDT='168'  ")
            .AppendLine("     and a.KUNNR='" + HttpContext.Current.Session("company_id").ToString().ToUpper() + "' and a.AUART like 'ZOR%' and b.MATNR like '%BTO' ")
            If QueryOrderCriteria1.OrderDateFrom IsNot Nothing AndAlso
                Date.TryParseExact(QueryOrderCriteria1.OrderDateFrom, "yyyy/MM/dd", cultureUS, System.Globalization.DateTimeStyles.None, Now) Then
                .AppendLine(" and a.ERDAT>='" + Date.ParseExact(QueryOrderCriteria1.OrderDateFrom, "yyyy/MM/dd", cultureUS).ToString("yyyyMMdd") + "' ")
            End If
            If QueryOrderCriteria1.OrderDateTo IsNot Nothing AndAlso
           Date.TryParseExact(QueryOrderCriteria1.OrderDateTo, "yyyy/MM/dd", cultureUS, System.Globalization.DateTimeStyles.None, Now) Then
                .AppendLine(" and a.ERDAT<='" + Date.ParseExact(QueryOrderCriteria1.OrderDateTo, "yyyy/MM/dd", cultureUS).ToString("yyyyMMdd") + "' ")
            End If

            If Not String.IsNullOrEmpty(QueryOrderCriteria1.PONO) Then
                .AppendLine("     and upper(a.BSTNK) like '%" + Trim(QueryOrderCriteria1.PONO).Replace("'", "''").Replace("*", "%").ToUpper() + "%' ")
            End If

            If Not String.IsNullOrEmpty(QueryOrderCriteria1.SONO) Then
                .AppendLine("     and upper(a.VBELN) like '%" + Trim(QueryOrderCriteria1.SONO).Replace("'", "''").Replace("*", "%").ToUpper() + "%' ")
            End If

            .AppendLine("     and rownum<=5000 ")
            .AppendLine("     order by a.ERDAT desc, b.MATNR ")
            .AppendLine("   ) a  ")
            .AppendLine("   order by rownum ")
            .AppendLine(" ) a ")
            .AppendLine(" where a.ridx>=" + QueryOrderCriteria1.StartIdx.ToString() + " and a.ridx<=" + (QueryOrderCriteria1.StartIdx + QueryOrderCriteria1.RowCount - 1).ToString() + " ")
            .AppendLine(" order by a.ridx ")
        End With

        Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "GetSOList sql", sbSql.ToString())
        Dim dtSO As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sbSql.ToString())
        For Each r As DataRow In dtSO.Rows
            r.Item("SO_NO") = Global_Inc.RemoveZeroString(r.Item("SO_NO"))
        Next
        Return Util.DataTableToJSON(dtSO)
    End Function

    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetSODetail(ByVal QueryOrderCriteria1 As QueryOrderCriteria) As String
        If String.IsNullOrEmpty(QueryOrderCriteria1.SONO) OrElse QueryOrderCriteria1.SONO.Length <= 4 Then Return ""
        Dim OrderDetail1 As New OrderDetail
        Dim sbSql As New System.Text.StringBuilder
        With sbSql
            .AppendLine(" select b.matnr as PART_NO, cast(b.POSNR as integer) as LINE_NO,  ")
            .AppendLine(" b.ARKTX as PRODUCT_DESC, b.UEPOS as HIGHER_LEVEL, cast(b.KWMENG as integer) as ORDER_QTY,  ")
            .AppendLine(" b.WAERK as CURRENCY, b.NETPR as UNIT_PRICE, b.NETWR as SUBTOTAL, c.VMSTA as PRODUCT_STATUS ")
            .AppendLine(" FROM SAPRDP.VBAK a INNER JOIN SAPRDP.VBAP b ON a.VBELN = b.VBELN left join saprdp.MVKE c on b.MATNR=c.MATNR and a.VKORG=c.VKORG ")
            .AppendLine(" where a.MANDT='168' and b.MANDT='168'  ")
            .AppendLine(" and a.KUNNR='" + HttpContext.Current.Session("company_id").ToString().ToUpper() +
                        "' and a.AUART like 'ZOR%' and a.VBELN='" + Global_Inc.SONoBuildSAPFormat(QueryOrderCriteria1.SONO) + "' And Trim(b.ABGRU) Is NULL") '20160606 Alex: Remove rejection item(ABGRU)
            .AppendLine(" order by b.POSNR ")
        End With
        Dim sm As New System.Net.Mail.SmtpClient(ConfigurationManager.AppSettings("SMTPServer"))
        'sm.Send("tc.chen@advantech.com.tw", "tc.chen@advantech.com.tw", "GetSODetail sql", sbSql.ToString())
        Dim dtSODetail As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", sbSql.ToString())
        dtSODetail.Columns.Add("SUBTOTAL_VALUE")
        Dim listOfOrderLines As New List(Of OrderLine)
        Dim decTotal As Decimal = 0

        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable

        For Each rSoLine As DataRow In dtSODetail.Rows
            If Not rSoLine.Item("PART_NO").ToString.StartsWith("AGS-EW-", StringComparison.CurrentCultureIgnoreCase) Then
                Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
                With prec
                    .Kunnr = HttpContext.Current.Session("company_id") : .Mandt = "168" : .Matnr = rSoLine.Item("PART_NO")
                    .Mglme = rSoLine.Item("ORDER_QTY") : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = HttpContext.Current.Session("org_id")
                End With
                pin.Add(prec)
            End If
        Next
        eup.Z_Sd_Eupriceinquery("1", pin, pout)
        eup.Connection.Close()
        Dim dtPrice As DataTable = pout.ToADODataTable()
        Dim myconn As New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        For Each r As DataRow In dtSODetail.Rows
            Dim rPrice() As DataRow = dtPrice.Select("Matnr='" + r.Item("PART_NO") + "'")
            If rPrice.Length > 0 Then
                r.Item("SUBTOTAL") = rPrice(0).Item("Netwr") : r.Item("UNIT_PRICE") = rPrice(0).Item("Netwr") / rPrice(0).Item("Mglme")
            End If
            r.Item("SUBTOTAL_VALUE") = Util.FormatMoney(r.Item("SUBTOTAL"), r.Item("CURRENCY"))

            Dim cmd As New SqlClient.SqlCommand( _
                "select top 1 txt from SAP_PRODUCT_ORDERNOTE where PART_NO='" + Global_Inc.RemoveZeroString(r.Item("PART_NO")) + _
                "' and ORG='" + HttpContext.Current.Session("org_id") + "'", myconn)
            If myconn.State <> ConnectionState.Open Then myconn.Open()
            Dim plmTxt As Object = cmd.ExecuteScalar()
            Dim OrderLine1 As New OrderLine
            With OrderLine1
                .PART_NO = r.Item("PART_NO") : .LINE_NO = r.Item("LINE_NO") : .PRODUCT_DESC = r.Item("PRODUCT_DESC") : .HIGHER_LEVEL = r.Item("HIGHER_LEVEL")
                .ORDER_QTY = r.Item("ORDER_QTY") : .CURRENCY = r.Item("CURRENCY") : .UNIT_PRICE = r.Item("UNIT_PRICE") : .SUBTOTAL = r.Item("SUBTOTAL")
                .SUBTOTAL_VALUE = r.Item("SUBTOTAL_VALUE") : .PRODUCT_STATUS = r.Item("PRODUCT_STATUS")
                .PLM_NOTICE = ""
                If plmTxt IsNot Nothing Then .PLM_NOTICE = plmTxt.ToString()
            End With
            decTotal += r.Item("SUBTOTAL")
            listOfOrderLines.Add(OrderLine1)
        Next
        myconn.Close()
        If dtSODetail.Rows.Count > 0 Then
            OrderDetail1.TotalAmount = Util.FormatMoney(decTotal, dtSODetail.Rows(0).Item("CURRENCY"))
            OrderDetail1.SONO = QueryOrderCriteria1.SONO : OrderDetail1.PONO = QueryOrderCriteria1.PONO
        End If

        OrderDetail1.OrderLines = listOfOrderLines
        Dim serializer As New Script.Serialization.JavaScriptSerializer()
        Return serializer.Serialize(OrderDetail1)
    End Function

    Class OrderLine
        Public Property PART_NO As String : Public Property LINE_NO As String : Public Property PRODUCT_DESC As String : Public Property HIGHER_LEVEL As String
        Public Property ORDER_QTY As Integer : Public Property CURRENCY As String : Public Property UNIT_PRICE As Decimal : Public Property SUBTOTAL As Decimal
        Public Property SUBTOTAL_VALUE As String : Public Property PRODUCT_STATUS As String : Public Property PLM_NOTICE As String
    End Class

    Class OrderDetail
        Public Property ShipToId As String : Public Property ShipToName As String : Public Property TotalAmount As String : Public Property OrderLines As List(Of OrderLine)
        Public Property SONO As String : Public Property PONO As String
    End Class

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            'Page.ClientScript.RegisterStartupScript(Me.Page.GetType(), "initDefaultData", "searchSO($('#btnQuery'));", True)
            If Session("account_status") <> "EZ" Then Response.Redirect(Util.GetRuntimeSiteUrl() + "/home.aspx")
        End If
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <link rel="stylesheet" href="../Includes/js/jquery-ui.css" />
    <script type="text/javascript" src="../EC/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../EC/jquery-ui.js"></script>
    <script type="text/javascript" src="../EC/json2.js"></script>
    <script type="text/javascript">
        var startRowIdx = 1; var scrollLoad = false;
        $(window).resize(function () { resizeDivSORoot(); });
        function resizeDivSORoot() {
            $("#divSORoot").width($(window).width()*0.75).height($(window).height() - 250);
        }

        function searchSO(btnObj) {
            scrollLoad = true; busyMode(true); var tbSOList = $("#tbSOListResult");
            if (btnObj) {
                startRowIdx = 1; $("#tdQueryErrMsg").empty(); $(btnObj).prop('disabled', true); tbSOList.empty();startRowIdx = 1;
            }             
            var SearchSOCriteria1 = {
                PONO: $("#<%=txtPONO.ClientId %>").val(), SONO: $("#<%=txtSONO.ClientId %>").val(), OrderDateFrom: $("#<%=txtSO_OrderDateFrom.ClientId %>").val(),
                OrderDateTo: $("#<%=txtSO_OrderDateTo.ClientId %>").val(), StartIdx: startRowIdx, RowCount: 50
            }
            var postData = JSON.stringify({ QueryOrderCriteria1: SearchSOCriteria1 });
            $.ajax(
                {
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/SearchBTOOrderList", data: postData, contentType:
                    "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        var solines = $.parseJSON(retData.d); var soHtml = "";
                        $.each(solines, function (idx, item) {
                            soHtml += "<tr sono='" + item.SO_NO + "' pono='"+item.PO_NO+"'>" +
                                        "<td align='center'>" + item.RIDX + "</td>" +
                                        "<td align='center'>" +
                                            "<a href='javascript:void(0);' onclick='getSODetail(this)'>" +
                                                "<img src='../Images/Dashboard_1.gif' alt='order detail' />" +
                                            "</a>" +
                                        "</td>" +
                                        "<td><a href='javascript:void(0);' onclick='getSODetail(this)'>" + item.PO_NO + "</a></td>" +
                                        "<td>" + item.SO_NO + "</td>" +
                                        "<td>" + new Date(parseInt(item.ORDER_DATE.substr(6))).format("yyyy/MM/dd") + "</td>" +
                                        "<td>" + item.PART_NO + "</td>" +
                                        "<td>" + item.DESCR + "</td>" +
                                      "</tr>";
                        }
                        );
                        //console.log("solines:" + solines.length);
                        if (btnObj) { tbSOList.append(soHtml); }
                        else {
                            var originalHtml = tbSOList.html(); tbSOList.empty(); tbSOList.append(originalHtml + soHtml); 
                        }
                        if (solines.length == 0 && btnObj) { $("#tdQueryErrMsg").text("no data, please refine your search"); }
                        startRowIdx += solines.length; scrollLoad = false; busyMode(false); $(btnObj).prop('disabled', false);
                    },
                    error: function (msg) {
                        //console.log("call SearchBTOOrderList err:" + msg.d);
                        $("#tdQueryErrMsg").text("Server error: " + msg.d);
                        scrollLoad = false; busyMode(false); $(btnObj).prop('disabled', false);
                    }
                });
        }

        function busyMode(mode) {
            (mode == true) ? $("#ctl00_UpdateProgress2").css("visibility", "visible") : $("#ctl00_UpdateProgress2").css("visibility", "hidden");
            (mode == true) ? $("#imgLoading").css("style", "block") : $("#imgLoading").css("style", "none");
        }

        $(document).ready(function () {
            resizeDivSORoot();
            $('#divSORoot').bind('scroll', function () {
                //console.log("scrolled");
                if ($(this).scrollTop() +
                                   $(this).innerHeight()
                                   >= $(this)[0].scrollHeight - 100) {
                    if (scrollLoad == false && startRowIdx > 1) { searchSO(null); }
                    else {
                        //console.log("no scrolled:" + startRowIdx); 
                    }
                }
            })
            $("#tableQuerySO").keypress(function (event) {
                if (event.keyCode == 13) { searchSO($('#btnQuery')); event.preventDefault(); }
            }
            );
        }
        );

        function IsPhasedOut(status) {
            //console.log("status:" + status);
            if (status != "A" && status != "N" && status != "S5") return true;
            return false;
        }

        function getSODetail(anchorObj) {
            busyMode(true); var tbDetail = $("#soDetailList"); tbDetail.empty();
            var pono = $(anchorObj).parent().parent().attr("pono"); var sono = $(anchorObj).parent().parent().attr("sono");
            $("#tdDetailSONO").text(sono); $("#tdDetailPONO").text(pono);
            var SearchSOCriteria1 = {
                PONO: pono, SONO: sono, OrderDateFrom: '', OrderDateTo: '', StartIdx: 1, RowCount: 100
            }
            var postData = JSON.stringify({ QueryOrderCriteria1: SearchSOCriteria1 });
            $.ajax(
                {
                    type: "POST", url: "<%=IO.Path.GetFileName(Request.PhysicalPath) %>/GetSODetail", data: postData, contentType:
                    "application/json; charset=utf-8", dataType: "json",
                    success: function (retData) {
                        var odObj = $.parseJSON(retData.d); var linesHtml = ""; 
                        var orderlines = odObj.OrderLines;
                        $.each(orderlines, function (idx, item) {
                            linesHtml +=
                                "<tr " + ((IsPhasedOut(item.PRODUCT_STATUS) ? ("style='color:red'") : (""))) + ">" +
                                    "<td align='center'>" + item.LINE_NO + "</td>" +
                                    "<td>" + item.PART_NO + "</td>" +
                                    "<td>" + item.PRODUCT_DESC + "</td>" +
                                    "<td align='center'>" + item.PRODUCT_STATUS + "</td>" +
                                    "<td align='left' style='width:30%; height:40px;'><div style='overflow: auto;'>" + item.PLM_NOTICE + "</div></td>" +
                                    "<td align='center'>" + item.ORDER_QTY + "</td>" +
                                    "<td align='right'>" + item.SUBTOTAL_VALUE + "</td>" +
                                "</tr>";
                        }
                        );
                        linesHtml += "<tr><td colspan='5' align='right'><b>Total:</b>" + odObj.TotalAmount + "</td></tr>";
                        tbDetail.append(linesHtml);
                        if (orderlines.length == 0) { }
                        else {
                            $("#divSODetail").dialog({
                                modal: true,
                                width: $(window).width() - 100,
                                height: $(window).height() - 100,
                                open: function (event, ui) { }
                            }
                        );
                        }
                        busyMode(false);
                    },
                    error: function (msg) {
                        //console.log("call GetSODetail err:" + msg.d);
                        busyMode(false);
                    }
                });
            //alert(sono);
        }     

    </script>
    <table>
        <tr style="height:50px" valign="center">
            <th><h2 style="color:Navy">BTOS Order History Inquiry</h2></th>
        </tr>
        <tr>
            <td align="center">
                <table id="tableQuerySO" width="350px">
                    <tr>
                        <th align="left">
                            PO No.
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtPONO" Width="150px" />
                        </td>
                    </tr>
                    <tr>
                        <th align="left">
                            SO No.
                        </th>
                        <td>
                            <asp:TextBox runat="server" ID="txtSONO" Width="150px" />
                        </td>
                    </tr>
                    <tr>
                        <th align="left">
                            Order Date:
                        </th>
                        <td>
                            <table>
                                <tr>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalExt1" TargetControlID="txtSO_OrderDateFrom" Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtSO_OrderDateFrom" Width="80px" />
                                    </td>
                                    <td>
                                        ~
                                    </td>
                                    <td>
                                        <ajaxToolkit:CalendarExtender runat="server" ID="CalExt2" TargetControlID="txtSO_OrderDateTo" Format="yyyy/MM/dd" />
                                        <asp:TextBox runat="server" ID="txtSO_OrderDateTo" Width="80px" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <input type="button" id="btnQuery" value="Search" onclick="searchSO(this)" />
                        </td>
                        <td>
                            <img id="imgLoading" alt="Loading" src="../Images/loading.gif" style="display:none" />
                        </td>
                    </tr>
                    <tr style="height: 20px">
                        <td colspan="2" id="tdQueryErrMsg" style="color: Red; font-weight: bold">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <div id="divSORoot" style="overflow: auto">
                    <table id="tbSOList" width="100%">
                        <thead>
                            <tr>
                                <th>
                                    Index
                                </th>
                                <th>Detail</th>
                                <th>
                                    PO No.
                                </th>
                                <th>
                                    SO No.
                                </th>
                                <th>
                                    Order Date
                                </th>
                                <th>
                                    BTO Part No.
                                </th>
                                <th>
                                    Description.
                                </th>
                            </tr>
                        </thead>
                        <tbody id="tbSOListResult">
                        </tbody>
                    </table>
                </div>
            </td>
        </tr>
    </table>
    <div id="divSODetail" style="display:none; overflow:auto">
        <table width="100%">
            <tr>
                <td align="center">
                    <table>
                        <tr>
                            <th align="left">SO No.</th><td id="tdDetailSONO"></td>
                            <th align="left">PO No.</th><td id="tdDetailPONO"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table width="100%">                        
                        <thead>
                            <tr>
                                <th>Line No.</th>
                                <th>Part No.</th>
                                <th>Product Desc.</th>
                                <th>Product Status</th>
                                <th>Replacement Info</th>
                                <th>Qty.</th>
                                <th>Subtotal</th>
                            </tr>
                        </thead>
                        <tbody id="soDetailList" />
                    </table>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
