<%@ Page Title="MyAdvantech - Check ACN Price by Customer Condition Group" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function VerifyPN(ByVal PartNo As String) As Boolean
        Dim cmd As New SqlClient.SqlCommand("select count(distinct a.part_no) as c from sap_product_org a where a.part_no=@PN and a.org_id='CN10'", _
                                            New SqlClient.SqlConnection(ConfigurationManager.ConnectionStrings("MY").ConnectionString))
        cmd.Parameters.AddWithValue("PN", Trim(PartNo))
        cmd.Connection.Open()
        Dim retCount As Integer = CInt(cmd.ExecuteScalar())
        cmd.Connection.Close()
        If retCount = 1 Then
            Return True
        Else
            Return False
        End If
    End Function
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPartNo(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                              " select distinct top 20 a.part_no from sap_product_org a where a.part_no like N'{0}%' and a.part_no is not null and a.org_id='CN10' order by a.part_no ", prefixText))
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
    Public Shared Function GetPriceByGrade(ByVal PartNo As String) As String
        Dim listPrices As List(Of PriceRecord) = GetPriceByGradeInternal(PartNo)
        Dim jSlr As New Script.Serialization.JavaScriptSerializer
        Return jSlr.Serialize(listPrices) 
    End Function
    
    Private Shared Function GetPriceByGradeInternal(ByVal PartNo As String) As List(Of PriceRecord)
        Dim strPN As String = Global_Inc.Format2SAPItem(Trim(UCase(PartNo)))
        Dim dtKunnrCond As DataTable = dbUtil.dbGetDataTable("MY", _
        " select REP_KUNNR, KDKG1, KDKG2, KDKG3, KDKG4, KDKG5 from SAP_COMPANY_CONDITION_LIST " + _
        " where REP_KUNNR is not null and VKORG='CN10' and WAERS='CNY' order by KDKG1, KDKG2, KDKG3, KDKG4, KDKG5 ")
        
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
       
        eup.Connection.Open()
        For Each rKunnrCond As DataRow In dtKunnrCond.Rows
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = UCase(rKunnrCond.Item("REP_KUNNR")) : .Mandt = "168" : .Matnr = strPN : .Mglme = 1 : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = "CN10"
            End With
            pin.Add(prec)
        Next
        eup.Z_Sd_Eupriceinquery("1", pin, pout)
        eup.Connection.Close()
        Dim dtPrice As DataTable = pout.ToADODataTable()
        
        Dim listPrices As New List(Of PriceRecord)
        For Each rKunnrCond As DataRow In dtKunnrCond.Rows
            Dim PriceRecord1 As New PriceRecord
            With PriceRecord1
                .Price = -1 : .Kunnr = rKunnrCond.Item("REP_KUNNR") : .Cond1 = rKunnrCond.Item("KDKG1") : .Cond2 = rKunnrCond.Item("KDKG2")
                .Cond3 = rKunnrCond.Item("KDKG3") : .Cond4 = rKunnrCond.Item("KDKG4") : .Cond5 = rKunnrCond.Item("KDKG5")
            End With
            Dim rPrice() As DataRow = dtPrice.Select("Kunnr='" + rKunnrCond.Item("REP_KUNNR") + "'")
            If rPrice.Length > 0 Then
                PriceRecord1.Price = rPrice(0).Item("Netwr")
            End If
            listPrices.Add(PriceRecord1)
        Next
        Return listPrices
    End Function
    
    Class PriceRecord
        Public Property Price As Decimal
        Public Property Kunnr As String
        Public Property Cond1 As String
        Public Property Cond2 As String
        Public Property Cond3 As String
        Public Property Cond4 As String
        Public Property Cond5 As String
    End Class
    
    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If Not Util.IsInternalUser2() Then Response.Redirect("../../home.aspx")
        End If
    End Sub

    Protected Sub imgToXls_Click(sender As Object, e As System.Web.UI.ImageClickEventArgs)
        Dim listPrices As List(Of PriceRecord) = GetPriceByGradeInternal(txtPN.Text)
        Dim dt As New DataTable
        With dt.Columns
            .Add("Price", GetType(Decimal)) : .Add("Cond1") : .Add("Cond2") : .Add("Cond3") : .Add("Cond4") : .Add("Cond5")
        End With
        For Each pr As PriceRecord In listPrices
            Dim r As DataRow = dt.NewRow()
            r.Item("Price") = pr.Price : r.Item("Cond1") = pr.Cond1 : r.Item("Cond2") = pr.Cond2 : r.Item("Cond3") = pr.Cond3 : r.Item("Cond4") = pr.Cond4 : r.Item("Cond5") = pr.Cond5
            dt.Rows.Add(r)
        Next
        Util.DataTable2ExcelDownload(dt, txtPN.Text + "_PriceByConditions.xls")
    End Sub
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript" src="../../EC/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../EC/jquery-ui.js"></script>
    <script type="text/javascript" src="../../EC/json2.js"></script>   
    <script type="text/javascript">
        function verifyPN(btn) {
            $("#tdMsg").text(""); $("#tbResult").empty();
            $("#<%=imgToXls.ClientId %>").css("display", "none");
            var pn = $("#<%=txtPN.ClientId %>").val();
            var postData = JSON.stringify({ PartNo: pn });
            $.ajax({
                type: "POST",
                url: "ACN_PriceByGrade.aspx/VerifyPN",
                data: postData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (retData) {
                    //console.log(retData);
                    if (retData.d == true) {
                        getPrice();
                    }
                    else {
                        $("#tdMsg").text("Part Number is invalid");
                    }
                },
                error: function (msg) {
                    $("#tdMsg").text("Server error:" + msg.d);
                }
            });

        }
        function getPrice() {
            busyMode(true);
            var pn = $("#<%=txtPN.ClientId %>").val();
            var postData = JSON.stringify({ PartNo: pn });
            $.ajax({
                type: "POST",
                url: "ACN_PriceByGrade.aspx/GetPriceByGrade",
                data: postData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (retData) {
                    //console.log(retData);
                    var priceRecords = $.parseJSON(retData.d);
                    var tbResult = $("#tbResult");
                    if (retData.length == 0) { $("#tdMsg").text("No data"); }
                    else {
                        $("#<%=imgToXls.ClientId %>").css("display", "block");
                        $.each(priceRecords, function (idx, item) {
                            var trData = "<tr>";
                            trData += "<td align='right'>" + item.Price + "</td>";
                            trData += "<td align='center'>" + item.Cond1 + "</td>";
                            trData += "<td align='center'>" + item.Cond2 + "</td>";
                            trData += "<td align='center'>" + item.Cond3 + "</td>";
                            trData += "<td align='center'>" + item.Cond4 + "</td>";
                            trData += "<td align='center'>" + item.Cond5 + "</td>";
                            trData += "</tr>";
                            tbResult.append(trData);
                        }
                        );
                    }
                    busyMode(false);
                },
                error: function (msg) {
                    $("#tdMsg").text("Server error:" + msg.d); busyMode(false);
                }
            });
        }

        function busyMode(mode) {
            (mode == true) ? $("#ctl00_UpdateProgress2").css("visibility", "visible") : $("#ctl00_UpdateProgress2").css("visibility", "hidden");
        }
    </script>
    <table width="100%">
        <tr>
            <td>
                <div onkeypress="javascript:return WebForm_FireDefaultButton(event, &#39;btnCheckPN&#39;)">
                    <table>
                        <tr>
                            <th align="left">
                                Part No:
                            </th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoext1" TargetControlID="txtPN"
                                    MinimumPrefixLength="1" CompletionInterval="100" ServiceMethod="GetPartNo" />
                                <asp:TextBox runat="server" ID="txtPN" Width="150px" />
                            </td>
                            <td>
                                <input id="btnCheckPN" type="button" value="Query" onclick="verifyPN(this);" />
                            </td>
                        </tr>
                        <tr style="height: 20px">
                            <td colspan="3" id="tdMsg" style="font-weight: bold; color: Red">
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr valign="top">
            <td>
                <asp:ImageButton runat="server" ID="imgToXls" ImageUrl="~/Images/excel.gif" AlternateText="Download Excel" OnClick="imgToXls_Click" />
                <asp:Panel runat="server" ID="panel1" Width="100%" Height="400px" ScrollBars="Auto">
                    <table width="99%">
                        <thead>
                            <tr>
                                <th align="left" style="width: 10%">
                                    Price (RMB)
                                </th>
                                <th align="left" style="width: 15%">
                                    Condition Grp1
                                </th>
                                <th align="left" style="width: 15%">
                                    Condition Grp2
                                </th>
                                <th align="left" style="width: 15%">
                                    Condition Grp3
                                </th>
                                <th align="left" style="width: 15%">
                                    Condition Grp4
                                </th>
                                <th align="left" style="width: 15%">
                                    Condition Grp5
                                </th>
                            </tr>
                        </thead>
                        <tbody id="tbResult" />
                    </table>
                </asp:Panel>
            </td>
        </tr>
    </table>
</asp:Content>