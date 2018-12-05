<%@ Page Title="MyAdvantech - Check Part Number's SAP/PIS/eStore Status" Language="VB"
    MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    <Services.WebMethod()> _
    <Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetPartNo(ByVal prefixText As String, ByVal count As Integer) As String()
        prefixText = Replace(Replace(Trim(prefixText), "'", "''"), "*", "%")
        Dim dt As DataTable = dbUtil.dbGetDataTable("MY", String.Format( _
                              " select top 20 a.part_no from sap_product a where a.part_no like N'{0}%' order by a.part_no ", prefixText))
        If dt.Rows.Count > 0 Then
            Dim str(dt.Rows.Count - 1) As String
            For i As Integer = 0 To dt.Rows.Count - 1
                str(i) = dt.Rows(i).Item(0)
            Next
            Return str
        End If
        Return Nothing
    End Function

    Class PNDetail
        Public Property StoreId As String : Public Property ListPriceCurrency As String : Public Property ListPrice As Decimal
        Public Property CostCurrency As String : Public Property Cost As Decimal : Public Property InventoryQty As Integer
        Public Property eStoreFlag As String : Public Property ProductStatus As String : Public Property ABCDIndicator As String
        Public Property SAPPlant As String : Public Property SAPSalesOrg As String
    End Class

    Public Shared Function GetUSPriceByLevel(PartNo As String) As DataTable
        Dim SAPClient1 As New Z_SD_USPRICELOOKUP.Z_SD_USPRICELOOKUP
        SAPClient1.Connection = New SAP.Connector.SAPConnection(ConfigurationManager.AppSettings("SAP_PRD"))
        SAPClient1.Connection.Open()
        Dim p_error As String = "", p_maktx As String = "", p_head As New Z_SD_USPRICELOOKUP.ZSD_PRICE_HEAD, p_509 As New Z_SD_USPRICELOOKUP.ZSD_PRICE_509Table
        Dim p_513 As New Z_SD_USPRICELOOKUP.ZSD_PRICE_513Table, p_514 As New Z_SD_USPRICELOOKUP.ZSD_PRICE_514Table, p_517 As New Z_SD_USPRICELOOKUP.ZSD_PRICE_517Table
        Dim p_521 As New Z_SD_USPRICELOOKUP.ZSD_PRICE_521Table, it_markup As New Z_SD_USPRICELOOKUP.ZSD_PRICE_MARKUPTable
        SAPClient1.Z_Sd_Uspricelookup("USH1", Now.ToString("yyyyMMdd"), "10", Global_Inc.Format2SAPItem2(PartNo), "US01", "00", p_error, p_maktx, p_head, _
                                      p_509, p_513, p_514, p_517, p_521, it_markup)
        SAPClient1.Connection.Close()
        Return p_521.ToADODataTable()
    End Function

    Public Shared Function GetSAPMaterialChangeLog(PartNo As String) As DataTable
        Return OraDbUtil.dbGetDataTable("SAP_PRD",
            " select a.username, a.udate, a.utime, a.tcode, a.change_ind " +
            " from saprdp.cdhdr a  " +
            " where a.mandant='168' and a.objectclas='MATERIAL' and a.objectid='" + Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(PartNo)).ToUpper() + "' and rownum<=100 " +
            " order by a.udate desc, a.utime desc ")
    End Function
    Public Shared Function GetSAPPNCost(ByVal PartNo As String) As DataTable
        Return OraDbUtil.dbGetDataTable("SAP_PRD", _
                                " select distinct a.matnr as part_no, a.bwkey as plant, b.vkorg as sales_org, c.waers as currency, " + _
                                " a.STPRS as standard_price,  " + _
                                " a.VERPR as moving_price, a.VPRSV as price_control, a.PEINH as price_unit, a.STPRS as external_standard_price, 0 as update_flag  " + _
                                " from saprdp.mbew a inner join saprdp.tvkwz b on a.bwkey=b.werks inner join saprdp.t001 c on b.vkorg=c.bukrs " + _
                                " where a.mandt='168' and b.mandt='168' and c.mandt='168' and a.matnr='" + Util.FormatToSAPPartNo(Util.RemovePrecedingZeros(PartNo)).ToUpper() + "' ")
    End Function

    Protected Sub btnSearch_Click(sender As Object, e As System.EventArgs)
        LoadData()
    End Sub

    Sub LoadData()
        tdErrMsg.Text = "" : gvPNList.DataSource = Nothing : gvPNList.DataBind() : gvEstoreCTOS.DataSource = Nothing : gvEstoreCTOS.DataBind() : gvSpec.DataSource = Nothing : gvSpec.DataBind()
        gvUSPriceLevel.DataSource = Nothing : gvUSPriceLevel.DataBind()
        gvPNList.EmptyDataText = "No data" : gvEstoreCTOS.EmptyDataText = "No data" : gvSpec.EmptyDataText = "No data"
        If String.IsNullOrEmpty(Trim(txtPN.Text)) Then
            tdErrMsg.Text = "Part No. cannot be empty" : Exit Sub
        End If

        tabcon1.Visible = True
        Dim dtPartNoList As DataTable = dbUtil.dbGetDataTable("MY", String.Format(
                            " select top 50 a.part_no, a.product_desc, a.model_no, a.CREATE_DATE " +
                            " from sap_product a (nolock) where a.part_no like N'{0}%' " +
                            " order by a.CREATE_DATE desc, a.part_no ", Trim(txtPN.Text).Replace("'", "''").Replace("*", "%")))
        gvPNList.DataSource = dtPartNoList : gvPNList.DataBind()

        Dim dtUSPriceLevel As New DataTable
        For Each pnRow As DataRow In dtPartNoList.Rows
            dtUSPriceLevel.Merge(GetUSPriceByLevel(pnRow.Item("part_no")))
        Next
        gvUSPriceLevel.DataSource = dtUSPriceLevel : gvUSPriceLevel.DataBind()


        If txtPN.Text.Length >= 5 Then
            gvEstoreCTOS.DataSource = GetEstoreCTOSByPNKey(txtPN.Text) : gvEstoreCTOS.DataBind()
        End If

        gvSpec.DataSource = dbUtil.dbGetDataTable("MY",
        " select ItemType, ProductNo, AttrCatName, AttrName, AttrValueName " +
        " from PIS.dbo.V_Spec_V2 (nolock)  " +
        " where ProductNo like '" + Trim(txtPN.Text).Replace("'", "''").Replace("*", "%") + "%' " +
        " order by ItemType, ProductNo, AttrCatName, AttrName  ")
        gvSpec.DataBind()
    End Sub

    Protected Sub gvPNList_RowDataBound(sender As Object, e As System.Web.UI.WebControls.GridViewRowEventArgs)
        If e.Row.RowType = DataControlRowType.DataRow Then
            Try
                Dim PartNo As String = CType(e.Row.FindControl("hdRowPN"), HiddenField).Value
                Dim gvPNDetail As GridView = CType(e.Row.FindControl("gvPNDetail"), GridView)
                'gvPNDetail.DataSource = GetPNDetail(PartNo) : gvPNDetail.DataBind()
                gvPNDetail.DataSource = MYSAPDAL.GetPNDetail(PartNo, True) : gvPNDetail.DataBind()
                Dim gvPNPISProfile As GridView = e.Row.FindControl("gvPNPISProfile")
                gvPNPISProfile.DataSource = GetPNPISDetail(PartNo) : gvPNPISProfile.DataBind()
            Catch ex As Exception
                tdErrMsg.Text += ex.ToString() + ";"
            End Try
        End If
    End Sub

    Public Shared Function GetPNPISDetail(ByVal PartNo As String) As DataTable
        Return dbUtil.dbGetDataTable("MY",
        " select b.model_name, b.status as PART_NO_ACTIVE_STATUS, b.relation, c.MODEL_ID, c.MODEL_DESC,  " +
        " c.CREATED_BY, c.LAST_UPDATED_BY, d.Publish_Status, d.Active_FLG    " +
        " from SAP_PRODUCT a (nolock) left join PISBackend.dbo.model_product b (nolock) on a.PART_NO=b.part_no  " +
        " left join PISBackend.dbo.model c (nolock) on b.model_name=c.MODEL_NAME  " +
        " left join PISBackend.dbo.Model_Publish d (nolock) on c.MODEL_NAME=d.Model_name  " +
        " where a.PART_NO='" + Replace(PartNo, "'", "''") + "' and d.Site_ID='ACL' " +
        " order by b.model_name ")
    End Function

    Public Shared Function GetEstoreCTOSByPNKey(ByVal PartNoKey As String) As DataTable
        Return dbUtil.dbGetDataTable("Estore",
        " select distinct CTOSComponentDetail.StoreID, CTOSComponentDetail.SProductID as PART_NO, Product.DisplayPartno as ParentCategoryId, Product.SProductID  " +
        " FROM Parts (nolock) INNER JOIN  " +
        " Product (nolock) ON Parts.StoreID = Product.StoreID AND Parts.SProductID = Product.SProductID INNER JOIN  " +
        " Product_Ctos (nolock) ON Product.StoreID = Product_Ctos.StoreID AND Product.SProductID = Product_Ctos.SProductID INNER JOIN  " +
        " CTOSBOM (nolock) ON Product_Ctos.StoreID = CTOSBOM.StoreID AND Product_Ctos.SProductID = CTOSBOM.SProductID INNER JOIN  " +
        " CTOSComponent (nolock) ON CTOSBOM.ComponentID = CTOSComponent.ComponentID and CTOSBOM.StoreID = CTOSComponent.StoreID  " +
        " inner join CTOSComponentDetail (nolock) on CTOSComponent.ComponentID=CTOSComponentDetail.ComponentID and CTOSComponent.StoreID=CTOSComponentDetail.StoreID  " +
        " where CTOSComponentDetail.SProductID like '%" + Replace(Trim(PartNoKey), "'", "''").Replace("*", "%") + "%' " +
        " order by CTOSComponentDetail.SProductID, CTOSComponentDetail.StoreID ")
    End Function

    Public Shared Function FormatCost(ByVal StandardPrice As Decimal, ByVal PriceUnit As Integer, ByVal SalesOrg As String) As Decimal
        Dim cost As Decimal = StandardPrice / PriceUnit
        If SalesOrg = "KR01" Or SalesOrg = "JP01" Then
            cost = cost * 100
        ElseIf SalesOrg = "TW01" Then
            If PriceUnit = 1000 Then
                cost = cost * 100
            End If
        End If
        Return cost
    End Function

    Protected Sub Page_Load(sender As Object, e As System.EventArgs)
        If Not Page.IsPostBack Then
            'ICC 2016/1/13 Change DMS.ACL to DMKT.ACL
            'ICC 2017/7/28 Add Sein
            If MailUtil.IsInRole("MyAdvantech") = False AndAlso MailUtil.IsInRole("eStore.IT") = False _
             AndAlso MailUtil.IsInRole("DMKT.ACL") = False _
                AndAlso Not String.Equals(User.Identity.Name, "ken.ott@advantech.com", StringComparison.CurrentCultureIgnoreCase) _
                AndAlso Not String.Equals(User.Identity.Name, "vera.hsu@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
                 AndAlso Not String.Equals(User.Identity.Name, "alex.tsai@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
                AndAlso Not String.Equals(User.Identity.Name, "Ashley.Wu@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
                AndAlso Not String.Equals(User.Identity.Name, "Eva.Chang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) _
                AndAlso Not String.Equals(User.Identity.Name, "sein.ha@advantech.co.kr", StringComparison.CurrentCultureIgnoreCase) _
                AndAlso Not String.Equals(User.Identity.Name, "stanley139.huang@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) Then
                Response.Redirect("../../home.aspx")
            End If


        End If
    End Sub

    Protected Sub gvPNList_Sorting(sender As Object, e As System.Web.UI.WebControls.GridViewSortEventArgs)
        LoadData()
    End Sub

    Public Shared Function FormatEstoreBTOConfigUrl(ByVal StoreId As String, ByVal BTOProductId As String) As String
        Dim Url As String = "buy.advantech.com"
        Select Case StoreId
            Case "AAU"
                Url = "buy.advantech.net.au"
            Case "ABR"
                Url = "buy.advantech.com.br"
            Case "ACN"
                Url = "buy.advantech.com.cn"
            Case "AEU"
                Url = "buy.advantech.eu"
            Case "AIN"
                Url = "buy.advantech.in"
            Case "AJP"
                Url = "buy.advantech.co.jp"
            Case "AKR"
                Url = "buy.advantech.co.kr"
            Case "ALA"
                Url = "buy.advantech.com.mx"
            Case "ASC"
                Url = "buyasc.advantech.com"
            Case "ATW"
                Url = "buy.advantech.com.tw"
            Case "AUS"
                Url = "buy.advantech.com"
            Case "EMT"
                Url = "intercon.buy.advantech.com"
            Case "SAP"
                Url = "buy.advantech.com.my"
        End Select

        Return String.Format("http://{0}/product/system.aspx?ProductId={1}", Url, BTOProductId)

    End Function

    Protected Sub gvPNList_PageIndexChanging(sender As Object, e As System.Web.UI.WebControls.GridViewPageEventArgs)
        gvPNList.PageIndex = e.NewPageIndex : LoadData()
    End Sub
</script>
<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <script type="text/javascript">
        var prm = Sys.WebForms.PageRequestManager.getInstance();
        if (prm != null) {
            prm.add_endRequest(enableQueryButton);
        }

        function enableQueryButton() {
            document.getElementById('<%=btnSearch.ClientId %>').disabled = false;
        }
    </script>   
    <table width="100%">
        <tr>
            <th align="left" style="font-size: larger">
                eStore Part Number Analysis
            </th>
        </tr>
        <tr>
            <td>
                <asp:Panel runat="server" ID="PanelSearchTable" DefaultButton="btnSearch">
                    <table>
                        <tr>
                            <th align="left">
                                Part No.
                            </th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="autoext1" TargetControlID="txtPN"
                                    MinimumPrefixLength="1" CompletionInterval="100" ServiceMethod="GetPartNo" />
                                <asp:TextBox runat="server" ID="txtPN" Width="150px" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnSearch" Text="Check" OnClick="btnSearch_Click"
                                    UseSubmitBehavior="false" OnClientClick="this.disabled=true;" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                (partial part no is allowed, ex: adam-*)
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr style="height: 20px">
            <td>
                <asp:UpdatePanel runat="server" ID="upErrMsg" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Label runat="server" ID="tdErrMsg" ForeColor="Tomato" Font-Bold="true" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ajaxToolkit:TabContainer runat="server" ID="tabcon1" Visible="false">
                            <ajaxToolkit:TabPanel runat="server" ID="tab1" HeaderText="Component Info.">
                                <ContentTemplate>
                                    <asp:GridView runat="server" ID="gvPNList" Width="100%" AutoGenerateColumns="false"
                                        OnRowDataBound="gvPNList_RowDataBound" OnSorting="gvPNList_Sorting" OnPageIndexChanging="gvPNList_PageIndexChanging">
                                        <Columns>
                                            <asp:BoundField HeaderText="Part No." DataField="part_no" ItemStyle-Width="10%" ItemStyle-VerticalAlign="Top"
                                                SortExpression="part_no" />
                                            <asp:TemplateField ItemStyle-Width="90%" ItemStyle-VerticalAlign="Top" HeaderText="">
                                                <ItemTemplate>
                                                    <asp:HiddenField runat="server" ID="hdRowPN" Value='<%#Eval("part_no") %>' />
                                                    <table width="100%">
                                                        <tr>
                                                            <th align="left">
                                                                SAP & eStore:
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:GridView runat="server" ID="gvPNDetail" AutoGenerateColumns="false" Width="100%">
                                                                    <Columns>
                                                                        <asp:BoundField HeaderText="Store Id" DataField="StoreId" ItemStyle-HorizontalAlign="Center" />
                                                                        <asp:BoundField HeaderText="Sales Org." DataField="SAPSalesOrg" ItemStyle-HorizontalAlign="Center" />
                                                                        <asp:BoundField HeaderText="Plant" DataField="SAPPlant" ItemStyle-HorizontalAlign="Center" />
                                                                        <asp:TemplateField HeaderText="List Price" ItemStyle-HorizontalAlign="Right">
                                                                            <ItemTemplate>
                                                                                <%#Util.FormatMoney(Eval("ListPrice"), Eval("ListPriceCurrency"))%>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:TemplateField HeaderText="Cost" ItemStyle-HorizontalAlign="Right">
                                                                            <ItemTemplate>
                                                                                <%#Util.FormatMoney(Eval("Cost"), Eval("CostCurrency"))%>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:BoundField HeaderText="Inventory Qty." DataField="InventoryQty" ItemStyle-HorizontalAlign="Center" />
                                                                        <asp:BoundField HeaderText="eStore Status" DataField="eStoreFlag" ItemStyle-HorizontalAlign="Center" />
                                                                        <asp:BoundField HeaderText="SAP Product Status" DataField="ProductStatus" ItemStyle-HorizontalAlign="Center" />
                                                                        <asp:BoundField HeaderText="SAP ABCD Indicator" DataField="ABCDIndicator" ItemStyle-HorizontalAlign="Center" />
                                                                    </Columns>
                                                                </asp:GridView>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">
                                                                PIS:
                                                            </th>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:GridView runat="server" ID="gvPNPISProfile" AutoGenerateColumns="false" Width="100%">
                                                                    <Columns>
                                                                        <asp:TemplateField HeaderText="Model Name" ItemStyle-Width="15%">
                                                                            <ItemTemplate>
                                                                                <a target="_blank" href='http://www.advantech.com/products/<%#Eval("model_name") %>/mod_<%#Eval("model_id") %>.aspx'>
                                                                                    <%#Eval("model_name")%></a>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:BoundField HeaderText="Is PN Active?" DataField="PART_NO_ACTIVE_STATUS" ItemStyle-Width="10%" />
                                                                        <asp:TemplateField HeaderText="Model Description" ItemStyle-Width="30%">
                                                                            <ItemTemplate>
                                                                                <%#HttpUtility.HtmlDecode(Eval("MODEL_DESC"))%>
                                                                            </ItemTemplate>
                                                                        </asp:TemplateField>
                                                                        <asp:BoundField HeaderText="Created By" DataField="CREATED_BY" />
                                                                        <asp:BoundField HeaderText="Last Updated By" DataField="LAST_UPDATED_BY" />
                                                                    </Columns>
                                                                </asp:GridView>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </ajaxToolkit:TabPanel>
                            <ajaxToolkit:TabPanel runat="server" ID="tab2" HeaderText="BTOS Info.">
                                <ContentTemplate>
                                    <asp:GridView runat="server" ID="gvEstoreCTOS" Width="100%" AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:BoundField HeaderText="Store Id" DataField="StoreID" ItemStyle-HorizontalAlign="Center" />
                                            <asp:BoundField HeaderText="Component" DataField="PART_NO" />
                                            <asp:TemplateField HeaderText="BTO Item">
                                                <ItemTemplate>
                                                    <a target="_blank" href='<%#FormatEstoreBTOConfigUrl(Eval("StoreID"), Eval("SProductID"))%>'>
                                                        <%#Eval("ParentCategoryId")%></a>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </ajaxToolkit:TabPanel>
                            <ajaxToolkit:TabPanel runat="server" ID="tab3" HeaderText="Spec Info.">
                                <ContentTemplate>
                                    <asp:GridView runat="server" ID="gvSpec" Width="100%" AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:BoundField HeaderText="Type" DataField="ItemType" />
                                            <asp:BoundField HeaderText="Model/Part No." DataField="ProductNo" />
                                            <asp:BoundField HeaderText="Attribute Category Name" DataField="AttrCatName" />
                                            <asp:BoundField HeaderText="Attribute Name" DataField="AttrName" />
                                            <asp:BoundField HeaderText="Value" DataField="AttrValueName" />
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </ajaxToolkit:TabPanel>
                            <ajaxToolkit:TabPanel runat="server" ID="tab4" HeaderText="US L1-L7 Price">
                                <ContentTemplate>
                                    <asp:GridView runat="server" ID="gvUSPriceLevel" Width="100%" AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Part No.">
                                                <ItemTemplate>
                                                    <%# Global_Inc.RemoveZeroString(Eval("Matnr"))%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Level" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("Konda521")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Scale" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#FormatNumber(Eval("Kstbm"), 0)%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                           <%-- <asp:TemplateField HeaderText="Discount (%)" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("Disc")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>--%>
                                            <asp:TemplateField HeaderText="Price" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    $<%#Eval("Sldpr")%>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </ContentTemplate>
                            </ajaxToolkit:TabPanel>
                        </ajaxToolkit:TabContainer>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnSearch" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>
