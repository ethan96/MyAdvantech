<%@ Page Title="MyAdvantech - Check Product Status by Sales Org" Language="VB" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            If MailUtil.IsInRole("ITD.ACL") = False AndAlso MailUtil.IsInRole("eStore.IT") = False _
                AndAlso MailUtil.IsInRole("AOnline.Marketing") = False AndAlso MailUtil.IsInRole("MARCOM.ACG.ACL") = False Then
                Response.Redirect("../../home.aspx")
            End If
        End If
    End Sub
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPNDetail(ByVal PartNo As String) As String
        Dim dtSAPStatus As DataTable = OraDbUtil.dbGetDataTable("SAP_PRD", _
           " select a.matnr as PART_NO, a.werks as PLANT, a.maabc as ABC_INDICATOR, a.EISBE as safety_stock,  " + _
           " a.EISLO as min_safety_stock, b.vmsta as status, b.vkorg as org_id " + _
           " from saprdp.marc a inner join saprdp.mvke b on a.matnr=b.matnr and a.werks=b.dwerk " + _
           " where a.mandt='168' and b.mandt='168' and a.matnr='" + Global_Inc.Format2SAPItem(UCase(PartNo)) + "'")
        
        Dim dtEstoreStatus As DataTable = dbUtil.dbGetDataTable("Estore", _
        "SELECT [StoreID], [PublishStatus],[Status] FROM [eStoreProduction].[dbo].[Product] where DisplayPartno='" + Replace(PartNo, "'", "''") + "'")
        
        Dim eup As New Z_SD_EUPRICEINQUERY.Z_SD_EUPRICEINQUERY(ConfigurationManager.AppSettings("SAP_PRD"))
        Dim pin As New Z_SD_EUPRICEINQUERY.ZSSD_01_EUTable, pout As New Z_SD_EUPRICEINQUERY.ZSSD_02_EUTable
        
        Dim PNDetailSet As New List(Of PNDetail)
        Dim dtStore As DataTable = dbUtil.dbGetDataTable("MY", "select a.ERP_ID, a.SALES_ORG, a.STORE_ID from eQuotation.dbo.ESTORE_PRICING_ERPID a order by a.STORE_ID")
        eup.Connection.Open()
        For Each rStore As DataRow In dtStore.Rows
            Dim prec As New Z_SD_EUPRICEINQUERY.ZSSD_01_EU
            With prec
                .Kunnr = rStore.Item("ERP_ID") : .Mandt = "168" : .Matnr = Global_Inc.Format2SAPItem(Trim(UCase(PartNo))) : .Mglme = 1 : .Prsdt = Now.ToString("yyyyMMdd") : .Vkorg = rStore.Item("SALES_ORG")
            End With
            pin.Add(prec)
        Next
        eup.Z_Sd_Eupriceinquery("1", pin, pout)
        eup.Connection.Close()
        Dim dtPrice As DataTable = pout.ToADODataTable()
        
        
        Dim p1 As New GET_MATERIAL_ATP.GET_MATERIAL_ATP
        p1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        p1.Connection.Open()
        
        For Each rStore As DataRow In dtStore.Rows
            Dim PNDetail1 As New PNDetail
            Dim rPrice() As DataRow = dtPrice.Select("Kunnr='" + rStore.Item("ERP_ID") + "' and Vkorg='" + rStore.Item("SALES_ORG") + "'")
            If rPrice.Length > 0 Then
                PNDetail1.ListPrice = Util.FormatMoney(rPrice(0).Item("Kzwi1"), rPrice(0).Item("Waerk"))
            End If
            Dim rStatus() As DataRow = dtSAPStatus.Select("org_id='" + rStore.Item("SALES_ORG") + "'")
            If rStatus.Length > 0 Then
                PNDetail1.ProductStatus = rStatus(0).Item("status") : PNDetail1.ABCDIndicator = rStatus(0).Item("ABC_INDICATOR")
            Else
                PNDetail1.ProductStatus = "N/A" : PNDetail1.ABCDIndicator = "N/A"
            End If
            
            Dim rEstoreStatus() As DataRow = dtEstoreStatus.Select("StoreID='" + rStore.Item("STORE_ID") + "'")
            If rEstoreStatus.Length > 0 Then
                PNDetail1.eStoreFlag = rEstoreStatus(0).Item("Status")
            Else
                PNDetail1.eStoreFlag = "N/A"
            End If
            
            Dim Inventory As Integer = 0
            Dim retTb As New GET_MATERIAL_ATP.BAPIWMDVSTable, atpTb As New GET_MATERIAL_ATP.BAPIWMDVETable, rOfretTb As New GET_MATERIAL_ATP.BAPIWMDVS
            rOfretTb.Req_Qty = 9999 : rOfretTb.Req_Date = Now.ToString("yyyyMMdd") : retTb.Add(rOfretTb)
            p1.Bapi_Material_Availability("", "A", "", New Short, "", "", "", PartNo, UCase(Left(rStore.Item("SALES_ORG"), 2) + "H1"), _
                                          "", "", "", "", "PC", "", Inventory, "", "", New GET_MATERIAL_ATP.BAPIRETURN, atpTb, retTb)
            Dim ATPtable As DataTable = atpTb.ToADODataTable()
            Dim intCulATPQty As Integer = 0
            For Each r As DataRow In ATPtable.Rows
                intCulATPQty += CType(r.Item("com_qty"), Int64)
            Next
            
            With PNDetail1
                .InventoryQty = intCulATPQty : .StoreId = rStore.Item("STORE_ID")
            End With
            PNDetailSet.Add(PNDetail1)
        Next
        
        p1.Connection.Close()
        
        Dim jSlr As New Script.Serialization.JavaScriptSerializer
        Return jSlr.Serialize(PNDetailSet)
    End Function
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetModelNo(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Trim(prefixText), "'", "''")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                              " select distinct top 20 a.MODEL_NAME from PIS.dbo.model a where a.MODEL_NAME like N'%{0}%' and a.MODEL_NAME is not null order by a.MODEL_NAME ", prefixText))
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
    Public Shared Function VerifyModel(ByVal ModelNo As String) As Boolean
        Dim strMNs() As String = GetModelNo(ModelNo, 1)
        If strMNs Is Nothing OrElse strMNs.Length = 0 Then Return False
        Return True
    End Function
    
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function getModelPNList(ByVal ModelNo As String) As String
        Dim apt As New SqlClient.SqlDataAdapter( _
            " select a.part_no, a.seq_num, a.created_date, a.created_by, a.Last_update_by, a.Last_update_date,  " + _
            " b.STATUS, b.PRODUCT_DESC, b.PRODUCT_HIERARCHY, b.MATERIAL_GROUP, b.MODEL_NO, b.GIP_CODE, b.ROHS_FLAG, IsNull(a.STATUS,'') as PIS_STATUS, " + _
            " (select top 1 z.EMAIL_ADDR from SAP_GIP_CONTACT z where z.GIP_CODE=b.GIP_CODE order by z.EMAIL_ADDR) as GIP_EMAIL " + _
            " from PIS.dbo.model_product a inner join SAP_PRODUCT b on a.part_no=b.PART_NO " + _
            " where a.relation='product' and a.model_name=@MN " + _
            " order by a.seq_num, a.part_no  ", _
            ConfigurationManager.ConnectionStrings("MY").ConnectionString)
        apt.SelectCommand.Parameters.AddWithValue("MN", ModelNo)
        Dim dtPNList As New DataTable
        apt.Fill(dtPNList)
        Dim listPN As New List(Of PNProfile)
        For Each rPN As DataRow In dtPNList.Rows
            Dim lPn As New PNProfile
            With lPn
                .PartNo = rPN.Item("part_no") : .Desc = rPN.Item("PRODUCT_DESC") : .PISActive = rPN.Item("PIS_STATUS") : .TWStatus = rPN.Item("STATUS")
            End With
            listPN.Add(lPn)
        Next
        
        apt.SelectCommand.CommandText = _
            " select IsNull(a.MODEL_DESC,'') as MODEL_DESC, IsNull(a.EXTENDED_DESC,'') as EXTENDED_DESC, IsNull(a.DISPLAY_NAME,'') as DISPLAY_NAME, a.CREATED, a.CREATED_BY, a.MODEL_ID,  " + _
            " IsNull(b.Publish_Status,'') as Publish_Status, b.Site_ID, b.Active_FLG  " + _
            " from PIS.dbo.Model a inner join PIS.dbo.Model_Publish b on a.MODEL_NAME=b.Model_name  " + _
            " where a.MODEL_NAME=@MN and b.Site_ID='ACL' "
        If apt.SelectCommand.Connection.State <> ConnectionState.Open Then apt.SelectCommand.Connection.Open()
        Dim dtModelInfo As New DataTable
        apt.Fill(dtModelInfo)
        apt.SelectCommand.Connection.Close()
        Dim PNList1 As New PNList, ModelInfo1 As New ModelInfo
        PNList1.PNProfileList = listPN
        If dtModelInfo.Rows.Count > 0 Then
            With ModelInfo1
                .DisplayName = dtModelInfo.Rows(0).Item("DISPLAY_NAME") : .ModelDesc = dtModelInfo.Rows(0).Item("MODEL_DESC")
                .ModelId = dtModelInfo.Rows(0).Item("MODEL_ID") : .PubStatus = dtModelInfo.Rows(0).Item("Publish_Status")
                .ExtDesc = dtModelInfo.Rows(0).Item("EXTENDED_DESC")
            End With
        End If
        PNList1.ModelDetail = ModelInfo1
        
        Dim jSlr As New Script.Serialization.JavaScriptSerializer
        Return jSlr.Serialize(PNList1)
    End Function
    
    Class PNList
        Private _pnList As List(Of PNProfile)
        Public Property PNProfileList As List(Of PNProfile)
            Get
                Return _pnList
            End Get
            Set(value As List(Of PNProfile))
                _pnList = value
            End Set
        End Property
        Public Property ModelDetail As ModelInfo
    End Class
    
    Class ModelInfo
        Public Property DisplayName As String : Public Property ModelDesc As String : Public Property ExtDesc As String
        Public Property ModelId As String : Public Property PubStatus As String
    End Class
    
    Class PNDetail
        Public Property StoreId As String : Public Property ListPrice As String : Public Property Cost As String : Public Property InventoryQty As Integer
        Public Property eStoreFlag As String : Public Property ProductStatus As String : Public Property ABCDIndicator As String
    End Class
    
    Class PNProfile
        Private _pn As String, _twstatus As String, _desc As String, _pisStatus As String
        Public Property PartNo As String
            Get
                Return _pn
            End Get
            Set(value As String)
                Me._pn = value
            End Set
        End Property
        Public Property TWStatus As String
            Get
                Return _twstatus
            End Get
            Set(value As String)
                Me._twstatus = value
            End Set
        End Property
        Public Property Desc As String
            Get
                Return _desc
            End Get
            Set(value As String)
                Me._desc = value
            End Set
        End Property
        Public Property PISActive As String
            Get
                Return _pisStatus
            End Get
            Set(value As String)
                Me._pisStatus = value
            End Set
        End Property
    End Class
    
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <script type="text/javascript" src="../../EC/jquery-latest.min.js"></script>
    <script type="text/javascript" src="../../EC/jquery-ui.js"></script>
    <script type="text/javascript" src="../../EC/json2.js"></script>    
    <script type="text/javascript">

        $(document).ready(function () {});

        function getPNDetail(pnIdx) {
            busyMode(true);
            var pnTr = $("#pn" + pnIdx.toString());
            if (pnTr.length == 1) {
                var pn = pnTr.attr("partno");
                //$(".AEU", pnTr).text("aa");
                //getPNDetail(pnIdx + 1);
                var postData = JSON.stringify({ PartNo: pn });
                $.ajax({
                    type: "POST",
                    url: "PNStatusBySalesOrg.aspx/GetPNDetail",
                    data: postData,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (retData) {
                        var pnset = $.parseJSON(retData.d);
                        $.each(pnset, function (idx, item) {
                            var pnDetailHtml = "<table width='150px'>";
                            pnDetailHtml += "<tr aligh='left'><th aligh='left' style='width:80px'>ListPrice:</th><td>" + item.ListPrice + "</td></tr>";
                            pnDetailHtml += "<tr aligh='left'><th aligh='left'>ATP:</th><td>" + item.InventoryQty.toString() + "</td></tr>";
                            pnDetailHtml += "<tr aligh='left'><th aligh='left'>Status:</th><td>" + item.ProductStatus + "</td></tr>";
                            pnDetailHtml += "<tr aligh='left'><th aligh='left'>ABCD Indicator:</th><td>" + item.ABCDIndicator + "</td></tr>";
                            pnDetailHtml += "<tr aligh='left'><th aligh='left'>eStore:</th><td>" + item.eStoreFlag + "</td></tr>";
                            pnDetailHtml += "</table>";
                            //InventoryQty
                            $("." + item.StoreId, pnTr).html(pnDetailHtml);
                        }
                        );
                        getPNDetail(pnIdx + 1);
                    },
                    error: function (msg) {
                        //console.log('err calling GetPNDetail ' + msg.d);
                    }
                });
            }
            else {busyMode(false); };            
        }

        function checkModel() {
            $("#tbPNList").empty(); $("#tdAlertMsg").text("");
            var postData = JSON.stringify({ ModelNo: $("#<%=txtMN.ClientId %>").val()});
            $.ajax({
                type: "POST",
                url: "PNStatusBySalesOrg.aspx/VerifyModel",
                data: postData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if (msg.d == true) {
                        getModelPNList();
                    }
                },
                error: function (msg) {
                    //console.log('err calling VerifyModel ' + msg.d);
                }
            });
        }

        function getModelPNList() {
            var postData = JSON.stringify({ ModelNo: $("#<%=txtMN.ClientId %>").val() });
            $.ajax({
                type: "POST",
                url: "PNStatusBySalesOrg.aspx/getModelPNList",
                data: postData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (retData) {
                    //console.log(retData.d);
                    var pnList = $.parseJSON(retData.d);

                    $(".modelDisplayName").html("<a target='_blank' href='http://www.advantech.com/products/ADAM-4520/mod_" + pnList.ModelDetail.ModelId + ".aspx'>" + pnList.ModelDetail.DisplayName + "</a>");
                    $(".modelDesc").text(pnList.ModelDetail.ModelDesc); $(".modelPisPubStatus").text(pnList.ModelDetail.PubStatus);
                    var tbPNList = $("#tbPNList");
                    tbPNList.empty();
                    if (pnList.PNProfileList.length > 0) {
                        $.each(pnList.PNProfileList, function (idx, item) {
                            tbPNList.append("<tr id='pn" + idx + "' partno='" + item.PartNo + "'>" +
                                                "<td class='pntd'>" + item.PartNo + "</td>" +
                                                "<td>" + item.PISActive + "</td>" +
                                                "<td class='AUS'/>" +
                                                "<td class='AEU'/>" +
                                                "<td class='ACN'/>" +
                                                "<td class='ATW'/>" +
                                                "<td class='AJP'/>" +
                                                "<td class='AKR'/>" +
                                                "<td class='AAU'/>" +
                                                "<td class='SAP'/>" +
                                                "<td class='EMT'/>" +
                                                "<td class='ASC'/>" +
                                            "</tr>");
                        });
                        getPNDetail(0);
                    }
                    else {
                        $("#tdAlertMsg").text("No part number maintained for model " + $("#<%=txtMN.ClientId %>").val());
                    }

                },
                error: function (msg) {
                    //console.log('err calling VerifyModel ' + msg.d);
                }
            });
        }

        function busyMode(mode) {
            (mode == true) ? $("#ctl00_UpdateProgress2").css("visibility", "visible") : $("#ctl00_UpdateProgress2").css("visibility", "hidden");                   
        }    
    </script>   
    <br />
    <h2 style="color:Navy">Product Status by Store Id</h2><br />
    <table width="100%">
        <tr>
            <td>
                <div onkeypress="javascript:return WebForm_FireDefaultButton(event, &#39;btnCheckModel&#39;)">
                    <table width="350px">
                        <tr>
                            <th align="left">Model Name:</th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoext1" TargetControlID="txtMN" 
                                    MinimumPrefixLength="1" CompletionInterval="100" ServiceMethod="GetModelNo" />
                                <asp:TextBox runat="server" ID="txtMN" Width="200px" />                            
                            </td>
                            <td>
                                <input type="button" id="btnCheckModel" value="Check" onclick="checkModel();" />
                            </td>
                        </tr>
                        <tr style="height:20px">
                            <td colspan="3" id="tdAlertMsg" style="color:Red; font-weight:bold"></td>
                        </tr>
                    </table>
                </div>
            </td>            
        </tr>
        <tr>
            <td>
                <table>
                    <tr>
                        <th align="left" class="modelDisplayName" style="width:120px"></th>
                        <td class="modelPisPubStatus"></td>
                        <td class="modelDesc"></td>
                    </tr>                    
                </table>
            </td>
        </tr>
        <tr>
            <td align="left">
                <asp:Panel runat="server" ID="panel1" Width="900px" Height="400px" ScrollBars="Auto">
                <table width="100%" id="tbResult">
                    <thead>
                        <tr>
                            <th align='left' style="width: 80px">
                                Part Number
                            </th>
                            <th align='left' style="width: 70px">
                                PIS Status
                            </th>
                            <th>
                                AUS
                            </th>
                            <th>
                                AEU
                            </th>
                            <th>
                                ACN
                            </th>
                            <th>
                                ATW
                            </th> 
                            <th>
                                AJP
                            </th>
                            <th>
                                AKR
                            </th>
                            <th>
                                AAU
                            </th>
                            <th>
                                SAP
                            </th>  
                            <th>
                                EMT
                            </th>                          
                            <th>
                                ASC
                            </th>
                        </tr>
                    </thead>
                    <tbody id="tbPNList" />
                </table>
                </asp:Panel>
            </td>
        </tr>
    </table>
</asp:Content>