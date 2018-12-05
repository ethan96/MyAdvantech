<%@ Page Title="MyAdvantech - Cancel B+B Sales Order" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    public static bool IsTesting = true; static string SAPRFCconnection = "SAP_PRD"; static string SAPDbconnection = "SAP_PRD";

    [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod]
    public static string[] BBSOList(string prefixText, int count) {
        DetectIfIsTesting();
        prefixText = prefixText.Trim().ToUpper().Replace("'", "");
        var vbakDt = OraDbUtil.dbGetDataTable(SAPDbconnection,
            string.Format(
                @"select vbeln from saprdp.vbak 
                    where vkorg='US10' and rownum<=20 
                    and auart like 'ZOR%' and vbeln like '{0}%' order by vbeln ", prefixText));
        var SOList = new List<string>();
        foreach (DataRow drSO in vbakDt.Rows) SOList.Add(Global_Inc.RemoveZeroString(drSO["vbeln"].ToString()));
        return SOList.ToArray();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Util.IsBBCustomerCare()) btnCancelSO.Enabled = false;
        if (!Page.IsPostBack)
        {
            foreach (var name in Enum.GetNames(typeof(WiseOrderUtil.RejectSO_Reason)))
            {
                WiseOrderUtil.RejectSO_Reason eNumValue;
                Enum.TryParse(name.ToString(), out eNumValue);
                //Response.Write(string.Format("{0} -- {1}<br/>", (int) eNumValue, name));
                dlRejectSOReasons.Items.Add(new ListItem(name.ToString(), ((int)eNumValue).ToString()));
            }
        }
    }

    static void DetectIfIsTesting() {
        if (Util.GetRuntimeSiteUrl().ToLower().Contains("my.advantech.com:4002"))
        {
            IsTesting = true;
        }
        else {
            if (Util.GetRuntimeSiteUrl().ToLower().Contains("my.advantech.com") &&
                HttpContext.Current.Request.ServerVariables["SERVER_PORT"].ToString() == "80") {
                IsTesting = false;
            }
        }
        if (IsTesting) SAPRFCconnection = "SAPConnTest"; if (IsTesting) SAPDbconnection = "SAP_Test";
    }

    protected void btnCancelSO_Click(object sender, EventArgs e)
    {
        DetectIfIsTesting();
        lbCancelMsg.Text = "";
        var vbapDt = OraDbUtil.dbGetDataTable(SAPDbconnection, "select posnr from saprdp.vbap where vbeln='" + hdSONO.Value + "'");
        var p1 = new BAPI_SALESORDER_CHANGE.BAPI_SALESORDER_CHANGE();
        p1.Connection = new SAP.Connector.SAPConnection(ConfigurationManager.AppSettings[SAPRFCconnection]);
        BAPI_SALESORDER_CHANGE.BAPISDH1 OrderHeader = new BAPI_SALESORDER_CHANGE.BAPISDH1();
        BAPI_SALESORDER_CHANGE.BAPISDH1X OrderHeaderX = new BAPI_SALESORDER_CHANGE.BAPISDH1X();
        BAPI_SALESORDER_CHANGE.BAPISDITMTable ItemIn = new BAPI_SALESORDER_CHANGE.BAPISDITMTable();
        BAPI_SALESORDER_CHANGE.BAPISDITMXTable ItemInX = new BAPI_SALESORDER_CHANGE.BAPISDITMXTable();
        BAPI_SALESORDER_CHANGE.BAPIPARNRTable PartNr = new BAPI_SALESORDER_CHANGE.BAPIPARNRTable();
        BAPI_SALESORDER_CHANGE.BAPICONDTable Condition = new BAPI_SALESORDER_CHANGE.BAPICONDTable();
        BAPI_SALESORDER_CHANGE.BAPICONDXTable ConditionX = new BAPI_SALESORDER_CHANGE.BAPICONDXTable();
        BAPI_SALESORDER_CHANGE.BAPISCHDLTable ScheLine = new BAPI_SALESORDER_CHANGE.BAPISCHDLTable();
        BAPI_SALESORDER_CHANGE.BAPISCHDLXTable ScheLineX = new BAPI_SALESORDER_CHANGE.BAPISCHDLXTable();
        BAPI_SALESORDER_CHANGE.BAPISDTEXTTable OrderText = new BAPI_SALESORDER_CHANGE.BAPISDTEXTTable();
        BAPI_SALESORDER_CHANGE.BAPISDTEXT sales_note = new BAPI_SALESORDER_CHANGE.BAPISDTEXT();
        BAPI_SALESORDER_CHANGE.BAPISDTEXT ext_note = new BAPI_SALESORDER_CHANGE.BAPISDTEXT();
        BAPI_SALESORDER_CHANGE.BAPISDTEXT op_note = new BAPI_SALESORDER_CHANGE.BAPISDTEXT();
        BAPI_SALESORDER_CHANGE.BAPIRET2Table retTable = new BAPI_SALESORDER_CHANGE.BAPIRET2Table();
        BAPI_SALESORDER_CHANGE.BAPIADDR1Table ADDRTable = new BAPI_SALESORDER_CHANGE.BAPIADDR1Table();
        BAPI_SALESORDER_CHANGE.BAPIPARNRCTable PartnerChangeTable = new BAPI_SALESORDER_CHANGE.BAPIPARNRCTable();
        var BAPISDLS1= new BAPI_SALESORDER_CHANGE.BAPISDLS(); var BAPIPAREXTable1= new BAPI_SALESORDER_CHANGE.BAPIPAREXTable();
        var BAPICUBLBTable1= new BAPI_SALESORDER_CHANGE.BAPICUBLBTable(); var BAPICUINSTable1= new BAPI_SALESORDER_CHANGE.BAPICUINSTable();
        var BAPICUPRTTable1 = new BAPI_SALESORDER_CHANGE.BAPICUPRTTable(); var BAPICUCFGTable1= new BAPI_SALESORDER_CHANGE.BAPICUCFGTable();
        var BAPICUREFTable1= new BAPI_SALESORDER_CHANGE.BAPICUREFTable(); var BAPICUVALTable1=new BAPI_SALESORDER_CHANGE.BAPICUVALTable();
        var BAPICUVKTable1= new BAPI_SALESORDER_CHANGE.BAPICUVKTable(); var BAPISDKEYTable1= new BAPI_SALESORDER_CHANGE.BAPISDKEYTable();
        OrderHeaderX.Updateflag = "U";
        var RejectReason = dlRejectSOReasons.SelectedValue;
        string ReasonCodeStr = ( (int.Parse(RejectReason) < 10) ? ("0" + int.Parse(RejectReason).ToString()) : RejectReason.ToString() );
        foreach (DataRow vbupRow in vbapDt.Rows) {
            BAPI_SALESORDER_CHANGE.BAPISDITMX ItemInRowX = new BAPI_SALESORDER_CHANGE.BAPISDITMX() {
                Itm_Number = vbupRow["posnr"].ToString(),  Updateflag = "U", Reason_Rej = "X"
            };
            BAPI_SALESORDER_CHANGE.BAPISDITM ItemInRow = new BAPI_SALESORDER_CHANGE.BAPISDITM() {
                Itm_Number = vbupRow["posnr"].ToString(), Reason_Rej = ReasonCodeStr
            };

            ItemIn.Add(ItemInRow); ItemInX.Add(ItemInRowX);
        }
        p1.Connection.Open();
        p1.Bapi_Salesorder_Change("", "",  BAPISDLS1, "", OrderHeader, OrderHeaderX, hdSONO.Value, "", ref Condition,
            ref ConditionX, ref BAPIPAREXTable1, ref BAPICUBLBTable1,
            ref BAPICUINSTable1, ref BAPICUPRTTable1, ref BAPICUCFGTable1,
            ref BAPICUREFTable1, ref BAPICUVALTable1, ref BAPICUVKTable1, ref ItemIn,
            ref ItemInX, ref BAPISDKEYTable1, ref OrderText, ref ADDRTable,
            ref PartnerChangeTable, ref PartNr, ref retTable, ref ScheLine, ref ScheLineX);
        p1.CommitWork();
        p1.Connection.Close();

        var sbCanCelErr = new StringBuilder();
        foreach (BAPI_SALESORDER_CHANGE.BAPIRET2 retLine in retTable) {
            if (retLine.Type == "E") { sbCanCelErr.AppendLine(retLine.Message+"."); }
        }
        if (sbCanCelErr.Length > 0) lbCancelMsg.Text = sbCanCelErr.ToString();
        else {
            lbCancelMsg.Text = "SO is canceled.";
            //Get authorize.net's transaction id from SAP, and invoke authorize.net's API to void amount.
            var dtCreditTranId = OraDbUtil.dbGetDataTable(SAPDbconnection,
                string.Format(@"select c.autwr As AUTHORIZED_AMOUNT, c.autra As TRANSACTION_ID, c.aunum As AUTH_CODE
                From saprdp.vbak a inner join saprdp.FPLTC c on a.rplnr = c.fplnr
                where a.vbeln='{0}' and c.autwr>0  and c.autra <> '1111111111'",hdSONO.Value));
            if (dtCreditTranId.Rows.Count > 0) {
                try
                {
                    var tranId = dtCreditTranId.Rows[0]["TRANSACTION_ID"].ToString();
                    var apiLoginId = ConfigurationManager.AppSettings["AuthorizeNet.BB.Sanbox.Login.US"];
                    var apiTransactionKey = ConfigurationManager.AppSettings["AuthorizeNet.BB.Sanbox.TransactionKey.US"];
                    var simulation = true;

                    if (!Util.IsTesting())
                    {
                        apiLoginId = ConfigurationManager.AppSettings["AuthorizeNet.BB.Login.US"];
                        apiTransactionKey = ConfigurationManager.AppSettings["AuthorizeNet.BB.TransactionKey.US"];
                        simulation = false;
                    }
                    var voidResponse = Advantech.Myadvantech.Business.AuthorizeNetSolution.VoidPayment(tranId, "", "", "", simulation);
                }
                catch { }
            }
            btnCancelSO.Enabled = false;

        }
        //gvBAPIChangeReturn.DataSource = retTable.ToADODataTable(); gvBAPIChangeReturn.DataBind();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        DetectIfIsTesting(); hdSONO.Value = ""; lbSOMsg.Text = "";
        if (txtSONO.Text.Trim().Length >= 6) {
            var SAPSONo = Global_Inc.SONoBuildSAPFormat(txtSONO.Text.Trim().Replace("'", ""));
            var dtSOHeader = new DataTable(); var dtSOLines = new DataTable();
            var SAPOracleDbApt = new Oracle.DataAccess.Client.OracleDataAdapter("", ConfigurationManager.ConnectionStrings[SAPDbconnection].ConnectionString);
            var sqlSOHeader = string.Format(@"
            select a.vbeln as so_no, a.erdat, a.netwr, a.waerk, a.vkgrp, a.vkbur
            , a.bstnk as po_no, a.kunnr as soldto_id, b.name1 as soldto_name
            , (select z.kunnr from saprdp.vbpa z where z.vbeln=a.vbeln and z.parvw='WE' and rownum=1 and z.mandt='168') AS shipto_id
            , (select z2.name1 from saprdp.vbpa z inner join saprdp.kna1 z2 on z.kunnr=z2.kunnr where z.vbeln=a.vbeln and z.parvw='WE' and rownum=1 and z.mandt='168') AS shipto_name
            , c.zterm as payterm, d.vtext as payterm_text
            from saprdp.vbak a inner join saprdp.kna1 b on a.kunnr=b.kunnr inner join saprdp.vbkd c on a.vbeln=c.vbeln
            inner join saprdp.tvzbt d on c.zterm=d.zterm
            where a.mandt='168' and b.mandt='168' and c.mandt='168' and a.auart like 'ZOR%' 
            and a.vkorg='US10' and a.vbeln='{0}' and c.posnr='000000'
            and d.mandt='168' and d.spras='E'",Global_Inc.SONoBuildSAPFormat(SAPSONo));
            SAPOracleDbApt.SelectCommand.CommandText = sqlSOHeader;
            SAPOracleDbApt.Fill(dtSOHeader);
            SAPOracleDbApt.SelectCommand.CommandText = string.Format(@"
            select a.posnr as line_no, a.matnr as part_no, a.arktx as prod_desc, a.kwmeng, a.netwr, a.waerk
            , (select count(distinct z.vbeln) from saprdp.lips z where z.vgbel=a.vbeln and z.vgbel=a.vbeln and z.vgpos=a.posnr) as DNCount 
            , case b.lfsta when 'A' then 'Not Delivered' when 'B' then 'Partially Delivered' when 'C' then 'Completely Delivered' else 'n/a' end as dlv_status             
            , (select z.bezei from saprdp.TVAGT z where z.mandt='168' and z.spras='E' and z.abgru=a.abgru) as reject_reason
            from saprdp.vbap a inner join saprdp.vbup b on a.vbeln=b.vbeln and a.posnr=b.posnr
            where a.mandt='168' and b.mandt='168' and a.vbeln='{0}' 
            order by a.posnr ",Global_Inc.SONoBuildSAPFormat(SAPSONo));
            SAPOracleDbApt.Fill(dtSOLines);
            SAPOracleDbApt.SelectCommand.Connection.Close();

            if (dtSOHeader.Rows.Count > 0 && dtSOLines.Rows.Count > 0)
            {
                gvOrderHeader.DataSource = dtSOHeader; gvOrderHeader.DataBind();
                gvSOLines.DataSource = dtSOLines; gvSOLines.DataBind();
                bool CanCanel = true;
                foreach (DataRow drOLine in dtSOLines.Rows) {
                    if (int.Parse(drOLine["DNCount"].ToString()) > 0) {
                        CanCanel = false; lbSOMsg.Text = string.Format("DN has been created, please delete DN first."); break;
                    }
                    if (drOLine["reject_reason"].ToString().Trim().Length>0) {
                        CanCanel = false; lbSOMsg.Text = string.Format("This order had been rejected already."); break;
                    }
                }
                if (!CanCanel)
                {
                    trCanceSOlFunction.Visible = false;
                }
                else {
                    hdSONO.Value = Global_Inc.SONoBuildSAPFormat(SAPSONo).ToString();trCanceSOlFunction.Visible = true;
                }
            }
            else {
                lbSOMsg.Text = "The SO you are querying does not exist.";
                gvOrderHeader.DataSource = null; gvOrderHeader.DataBind();
                gvSOLines.DataSource = null; gvSOLines.DataBind();
                gvOrderHeader.EmptyDataText = "SO not found";
                trCanceSOlFunction.Visible = false;
            }
        }
    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <table width="100%">
        <tr>
            <td><h3>Cancel Sales Order Function</h3></td>
        </tr>
        <tr>
            <td>
                <asp:Panel runat="server" ID="PanelQuery" DefaultButton="btnQuery">
                    <table>
                        <tr>
                            <th align="left">SO No.:</th>
                            <td>
                                <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtenderSO" 
                                        TargetControlID="txtSONO" MinimumPrefixLength="3" 
                                        ServicePath="CancelSO_ABB.aspx" ServiceMethod="BBSOList" />
                                <asp:TextBox runat="server" ID="txtSONO" Width="85px" />
                            </td>
                            <td>
                                <asp:Button runat="server" ID="btnQuery" Text="Query" OnClick="btnQuery_Click" />
                            </td>
                            <td>
                                <asp:Label runat="server" ID="lbSOMsg" ForeColor="Tomato" Font-Bold="true" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="up1">
                    <ContentTemplate>
                        <asp:HiddenField runat="server" ID="hdSONO" />
                        <table style="width:100%">
                            <tr>
                                <td>
                                    <asp:GridView runat="server" ID="gvOrderHeader" 
                                        AutoGenerateColumns="false" ShowHeader="false" Width="100%">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <table>
                                                        <tr>
                                                            <th style="width:10%" align="left">SO No.:</th>
                                                            <td style="width:10%">
                                                                <%#Global_Inc.RemoveZeroString(Eval("so_no").ToString()) %></td>
                                                            <th style="width:15%" align="left">Sold To:</th>
                                                            <td style="width:25%">
                                                                <%#Eval("soldto_id") %><br />(<%#Eval("soldto_name") %>)
                                                            </td>
                                                            <th style="width:15%" align="left">Ship To:</th>
                                                            <td style="width:25%">
                                                                <%#Eval("shipto_id") %><br />(<%#Eval("shipto_name") %>)
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">PO No.:</th>
                                                            <td>
                                                                <%#Eval("po_no") %></td>
                                                            <th align="left">Total Amount:</th>
                                                            <td align="center">
                                                                <%#Util.FormatMoney((double)Eval("netwr"),Eval("waerk").ToString()) %></td>
                                                            <th align="left">Payment Term:</th>
                                                            <td>
                                                                <%#Eval("payterm") %>-<%#Eval("payterm_text") %></td>
                                                        </tr>
                                                        <tr>
                                                            <th align="left">Order Date:</th>
                                                            <td>
                                                                <%# DateTime.ParseExact( Eval("erdat").ToString(),"yyyyMMdd",new System.Globalization.CultureInfo("en-US")).ToString("yyyy/MM/dd") %></td>
                                                            <td colspan="4"></td>
                                                        </tr>
                                                    </table>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:GridView runat="server" ID="gvSOLines" Width="100%" AutoGenerateColumns="false">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Line No." ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("line_no") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Part No." ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("part_no") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Product Desc." ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("prod_desc") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Qty." ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("kwmeng") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Dlv. Status" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("dlv_status") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Subtotal" ItemStyle-HorizontalAlign="Right">
                                                <ItemTemplate>
                                                    <%#Util.FormatMoney((double)Eval("netwr"),Eval("waerk").ToString()) %>
                                                </ItemTemplate>
                                            </asp:TemplateField>  
                                            <asp:TemplateField HeaderText="Canceled Reason" ItemStyle-HorizontalAlign="Center">
                                                <ItemTemplate>
                                                    <%#Eval("reject_reason") %>
                                                </ItemTemplate>
                                            </asp:TemplateField>                                          
                                        </Columns>
                                    </asp:GridView>
                                </td>
                            </tr>
                            <tr id="trCanceSOlFunction" runat="server" visible="false">
                                <td>
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:Button runat="server" ID="btnCancelSO" Text="Cancel SO" OnClick="btnCancelSO_Click" /></td>
                                            <th align="left">Cancel Reason:</th>
                                            <td>
                                                <asp:DropDownList runat="server" ID="dlRejectSOReasons" />
                                            </td>
                                            <td>
                                                <asp:Label runat="server" ID="lbCancelMsg" ForeColor="Tomato" Font-Bold="true" />
                                            </td>
                                        </tr>
                                    </table>
                                    <asp:GridView runat="server" ID="gvBAPIChangeReturn" />
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnQuery" />  
                        <asp:PostBackTrigger ControlID="btnCancelSO" />                      
                    </Triggers>
                </asp:UpdatePanel>
            </td>
        </tr>
    </table>
</asp:Content>
