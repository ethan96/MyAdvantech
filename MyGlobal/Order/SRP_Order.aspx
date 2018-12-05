<%@ Page Title="MyAdvantech - SRP Ordering Function" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack) {
            if (MailUtil.IsInRole("MyAdvantech") || MailUtil.IsInRole("iot.sense")) trInternalTr.Visible = true;
            var SRPBTO1 = InitSRPBTO("SRP-SR-100-BTO");
            var OrgSettings = from og in SRPBTO1.OrgSettings
                              where og.SAPOrg == Session["org_id"].ToString() && og.Currency==Session["COMPANY_CURRENCY"].ToString()
                              select og;
            if (OrgSettings.Count() > 0) {
                btnOrder.Enabled = true;
                SRPOrgSetting BTOOrgSetting = OrgSettings.First();
                txtSellingPrice.Text = (BTOOrgSetting.TotalITP * 1.2).ToString();
            }
        }
        lbMsg.Text = string.Empty;
    }

    protected void btnOrder_Click(object sender, EventArgs e)
    {
        var SRPBTO1 = InitSRPBTO("SRP-SR-100-BTO");
        var OrgSettings = from og in SRPBTO1.OrgSettings
                          where og.SAPOrg == Session["org_id"].ToString() && og.Currency == Session["COMPANY_CURRENCY"].ToString()
                          select og;
        if (OrgSettings.Count() > 0)
        {
            SRPOrgSetting BTOOrgSetting = OrgSettings.First();
            List<BTOComponent> CommonAndOrgComponents = new List<BTOComponent>();
            SRPBTO1.CommonBOM.ForEach(p => CommonAndOrgComponents.Add(p));
            BTOOrgSetting.OrgBOM.ForEach(p => CommonAndOrgComponents.Add(p));

            int ConfigQty = int.Parse(txtQty.Text); double TotalSubTotal = double.Parse(txtSellingPrice.Text); var AccumuRealSubTotal = 0.0;

            if (TotalSubTotal < BTOOrgSetting.TotalITP) {
                lbMsg.Text = "GP blocked! Selling Price cannot be lower than ITP.";
                return;
            }

            var dtAdd2Cart = Util.GetConfigOrderCartDt();
            if (!dtAdd2Cart.Columns.Contains("ATP_DATE")) dtAdd2Cart.Columns.Add("ATP_DATE", typeof(DateTime));

            foreach (var Comp in CommonAndOrgComponents) {
                if (Comp.IsFixedPrice) TotalSubTotal -= Comp.FixedPriceValue*Comp.Qty;
            }

            foreach (var Comp in CommonAndOrgComponents)
            {
                DataRow CartRow = dtAdd2Cart.NewRow();
                CartRow["ATP_DATE"] = DateTime.Today;
                CartRow["CATEGORY_ID"] = Comp.ComponentPN;
                CartRow["CATEGORY_NAME"] = Comp.CategoryName;
                CartRow["CATEGORY_TYPE"] = "Component";
                CartRow["PARENT_CATEGORY_ID"] = "";
                CartRow["CATEGORY_QTY"] = ConfigQty * Comp.Qty;
                double compUnitPrice = 0.0;
                if (!Comp.IsFixedPrice)
                {
                    compUnitPrice = Math.Round(TotalSubTotal * Comp.RevSplitPercent * 0.01 / Comp.Qty, 0);
                    AccumuRealSubTotal += compUnitPrice * Comp.Qty;
                }
                else {
                    compUnitPrice = Comp.FixedPriceValue;
                }
                CartRow["CATEGORY_PRICE"] = compUnitPrice;
                dtAdd2Cart.Rows.Add(CartRow);
            }
            dtAdd2Cart.Rows[0]["CATEGORY_PRICE"] = Math.Floor((double)dtAdd2Cart.Rows[0]["CATEGORY_PRICE"] + (TotalSubTotal - AccumuRealSubTotal) / (int)dtAdd2Cart.Rows[0]["CATEGORY_QTY"]);

            gv1.DataSource = dtAdd2Cart; gv1.DataBind();

            var VerifySum = 0.0;
            foreach (DataRow CartRow in dtAdd2Cart.Rows) {
                VerifySum += (double)CartRow["CATEGORY_PRICE"] * (int)CartRow["CATEGORY_QTY"];
            }
            //Response.Write("VerifySum:" + VerifySum.ToString());
            //return;
            var result = Advantech.Myadvantech.Business.OrderBusinessLogic.ConfingSRP2Cart(SRPBTO1.BTOPN, ConfigQty, dtAdd2Cart, Session["COMPANY_ID"].ToString(), Session["ORG_ID"].ToString(), Session["CART_ID"].ToString());
            if (result.IsUpdated == true)
                Response.Redirect("OrderInfoV2.aspx");
            else
                lbMsg.Text = "Add to cart error! Message: " + result.ServerMessage;
        }

    }

    public SRPBTO InitSRPBTO(string BTOName)
    {
        List<SRPBTO> SRPBTOList = new List<SRPBTO>();
        var SRPBTO1 = new SRPBTO() { BTOPN = "SRP-SR-100-BTO" };
        SRPBTOList.Add(SRPBTO1);
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "86'' LCD", ComponentPN = "DSDM-0864K-41NE-V", Qty = 1, RevSplitPercent = 32.4 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "Mount for 86''", ComponentPN = "96OT-WM-80H50V", Qty = 1, RevSplitPercent = 3.1 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "55'' LCD", ComponentPN = "DSDM-155FD-45NE-V", Qty = 2, RevSplitPercent = 14.6 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "Mount for 55''", ComponentPN = "96OT-WM-40H40V", Qty = 2, RevSplitPercent = 2.3 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "DS-980", ComponentPN = "DS-980GF-U4A1E", Qty = 1, RevSplitPercent = 10.0 });
        //SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "DS-980 OS", ComponentPN = "968QW16HLE", Qty = 1, RevSplitPercent = 2.37 });
        //SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "SignageCMS Client", ComponentPN = "968SPUDSC0", Qty = 1, RevSplitPercent = 6.0 });
        //SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "SignageCMS Server", ComponentPN = "968SPUDSS0", Qty = 1, RevSplitPercent = 5.0 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "SignageCMS", ComponentPN = "SIGNAGECMS-SR-C", Qty = 1, RevSplitPercent = 11.59 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "UTC-520", ComponentPN = "UTC-520EP-SRP0E", Qty = 1, RevSplitPercent = 13.9 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "Stand", ComponentPN = "UTC-T01-STANDE", Qty = 1, RevSplitPercent = 1.8 });
        SRPBTO1.CommonBOM.Add(new BTOComponent() { CategoryName = "Consulting Services", ComponentPN = "IOT-SENSE-SECO-IF", Qty = 1, RevSplitPercent = 8.0 });

        var USOrgSetting = new SRPOrgSetting() { SAPOrg = "US01", Currency = "USD", TotalPrice = 13200, TotalITP = 11018 };
        USOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "OS", ComponentPN = "2070015140", Qty = 1, RevSplitPercent = 1.07 });
        USOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 86\" LCD", ComponentPN = "XV-089G402A18N-HL", Qty = 1, RevSplitPercent = 0.05 });
        USOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 55\" LCD", ComponentPN = "XV-089G202A18N-IS", Qty = 2, RevSplitPercent = 0.11 });
        USOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for DS-980", ComponentPN = "1702002600", Qty = 1, RevSplitPercent = 0.05 });
        USOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for UTC-520", ComponentPN = "1702002600", Qty = 1, RevSplitPercent = 0.04 });
        USOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Assembly Fee", ComponentPN = "AGS-CTOS-SYS-B", Qty = 1, RevSplitPercent = 0.2 });
        SRPBTO1.OrgSettings.Add(USOrgSetting);

        var TWOrgSetting = new SRPOrgSetting() { SAPOrg = "TW01", Currency = "TWD", TotalPrice = 396000, TotalITP = 330540 };
        TWOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "OS", ComponentPN = "2070015140", Qty = 1, RevSplitPercent = 1.07 });
        TWOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 86\" LCD", ComponentPN = "XV-089G420A18N-HL", Qty = 1, RevSplitPercent = 0.05 });
        TWOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 55\" LCD", ComponentPN = "XV-389G220A18N0IS", Qty = 2, RevSplitPercent = 0.11 });
        TWOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for DS-980", ComponentPN = "1700001714", Qty = 1, RevSplitPercent = 0.05 });
        TWOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for UTC-520", ComponentPN = "1700001714", Qty = 1, RevSplitPercent = 0.04 });
        TWOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Assembly Fee", ComponentPN = "AGS-CTOS-SYS-B", Qty = 1, RevSplitPercent=0.2 });
        SRPBTO1.OrgSettings.Add(TWOrgSetting);

        var EUOrgSetting = new SRPOrgSetting() { SAPOrg = "EU10", Currency = "EUR", TotalPrice = 8870.97, TotalITP = 8885.49 };
        EUOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "OS", ComponentPN = "2070015140", Qty = 1, RevSplitPercent = 1.07 });
        EUOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 86\" LCD", ComponentPN = "XV-389G404A18NHLGE", Qty = 1, RevSplitPercent = 0.05 });
        EUOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 55\" LCD", ComponentPN = "XV-089G204A18N-ISE", Qty = 2, RevSplitPercent = 0.11 });
        EUOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for DS-980", ComponentPN = "1700018705", Qty = 1, RevSplitPercent = 0.05 });
        EUOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for UTC-520", ComponentPN = "1702002605", Qty = 1, RevSplitPercent = 0.04 });
        EUOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Assembly Fee", ComponentPN = "AGS-CTOS-SYS-B", Qty = 1, RevSplitPercent = 0.2 });
        SRPBTO1.OrgSettings.Add(EUOrgSetting);

        var CNOrgSetting = new SRPOrgSetting() { SAPOrg = "CN10", Currency = "CNY", TotalPrice = 69630, TotalITP = 69743.94 };
        CNOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "OS", ComponentPN = "209CWIN10Y", Qty = 1, RevSplitPercent = 0.57 });
        CNOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "OS", ComponentPN = "968CWIN10Y", Qty = 1, RevSplitPercent = 0.5 });
        CNOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 86\" LCD", ComponentPN = "XV-089G414A18N-HL", Qty = 1, RevSplitPercent = 0.05 });
        CNOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 55\" LCD", ComponentPN = "XV-089G214A18N-IS", Qty = 2, RevSplitPercent = 0.11 });
        CNOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for DS-980", ComponentPN = "1700000596-11", Qty = 1, RevSplitPercent = 0.05 });
        CNOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for UTC-520", ComponentPN = "1700000596-11", Qty = 1, RevSplitPercent = 0.04 });
        CNOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Assembly Fee", ComponentPN = "AGS-CTOS-SYS-B", Qty = 1, RevSplitPercent=0.2 });
        SRPBTO1.OrgSettings.Add(CNOrgSetting);

        var KROrgSetting = new SRPOrgSetting() { SAPOrg = "KR01", Currency = "KRW", TotalPrice = 11693000, TotalITP = 11693000 };
        KROrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "OS", ComponentPN = "2070015140", Qty = 1, RevSplitPercent = 1.07 });
        KROrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 86\" LCD", ComponentPN = "XV-389G215A18N1IS", Qty = 1, RevSplitPercent = 0.05 });
        KROrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 55\" LCD", ComponentPN = "XV-389G404A18NHLGK", Qty = 2, RevSplitPercent = 0.11 });
        KROrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for DS-980", ComponentPN = "1700018705", Qty = 1, RevSplitPercent = 0.05 });
        KROrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for UTC-520", ComponentPN = "1702002605", Qty = 1, RevSplitPercent = 0.04 });
        KROrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Assembly Fee", ComponentPN = "AGS-CTOS-SYS-B", Qty = 1, RevSplitPercent = 0.2 });
        SRPBTO1.OrgSettings.Add(KROrgSetting);

        var JPOrgSetting = new SRPOrgSetting() { SAPOrg = "JP01", Currency = "JPY", TotalPrice = 1171500, TotalITP = 1173417 };
        JPOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "OS", ComponentPN = "2070015140", Qty = 1, RevSplitPercent = 1.07 });
        JPOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 86\" LCD", ComponentPN = "XV-389G401A18NISP", Qty = 1, RevSplitPercent = 0.05 });
        JPOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for 55\" LCD", ComponentPN = "XV-389G201A18N0IS", Qty = 2, RevSplitPercent = 0.11 });
        JPOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for DS-980", ComponentPN = "1700000237", Qty = 1, RevSplitPercent = 0.05 });
        JPOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Power cord for UTC-520", ComponentPN = "1700000237", Qty = 1, RevSplitPercent = 0.04 });
        JPOrgSetting.OrgBOM.Add(new BTOComponent() { CategoryName = "Assembly Fee", ComponentPN = "AGS-CTOS-SYS-A", Qty = 1, RevSplitPercent=0.2 });
        SRPBTO1.OrgSettings.Add(JPOrgSetting);


        var SRPBTO = from q in SRPBTOList where q.BTOPN == BTOName select q;
        return SRPBTO.First();
    }

    public class SRPBTO
    {
        public string BTOPN { get; set; }
        public List<BTOComponent> CommonBOM { get; set; }
        public List<SRPOrgSetting> OrgSettings { get; set; }
        public SRPBTO()
        {
            CommonBOM = new List<BTOComponent>(); OrgSettings = new List<SRPOrgSetting>();
        }
    }

    public class BTOComponent
    {
        public string CategoryName { get; set; }
        public string ComponentPN { get; set; }
        public int Qty { get; set; }
        public double RevSplitPercent { get; set; }
        public bool IsFixedPrice { get; set; }
        public double FixedPriceValue { get; set; }
        public BTOComponent()
        {
            Qty = 1; RevSplitPercent = 0.0; IsFixedPrice = false; FixedPriceValue = 0.0;
        }
    }

    public class SRPOrgSetting
    {
        public string SAPOrg { get; set; }
        public double TotalPrice { get; set; }
        public double TotalITP { get; set; }
        public string Currency { get; set; }
        public List<BTOComponent> OrgBOM { get; set; }
        public SRPOrgSetting()
        {
            OrgBOM = new List<BTOComponent>();
        }

    }
</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" Runat="Server">
    <table width="100%">
        <tr>
            <td>
                <h3 style="color:navy">SRP Ordering Function</h3><br /><br />
            </td>
        </tr>
        <tr>
            <td align="center">
                <table style="width:700px; border: 1px solid black;">
                    <tr>
                        <th>SRP Product No.</th><th>Qty.</th><th>Selling Price</th><th></th>
                    </tr>
                    <tr>
                        <td align="center">
                            SRP-SR-100-BTO
                        </td>
                        <td align="center">
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender1" TargetControlID="txtQty" FilterType="Numbers" />
                            <asp:TextBox runat="server" ID="txtQty" Width="20px" Text="1" />
                        </td>
                        <td align="center">
                            <ajaxToolkit:FilteredTextBoxExtender runat="server" ID="FilteredTextBoxExtender2" TargetControlID="txtSellingPrice" FilterType="Numbers" />
                            <%=Session["COMPANY_CURRENCY_SIGN"].ToString() %><asp:TextBox runat="server" ID="txtSellingPrice" Width="50px" />
                        </td>
                        <td align="center"><asp:Button runat="server" ID="btnOrder" Text="Order" OnClick="btnOrder_Click" Enabled="false" /></td>
                    </tr>
                </table>
                <br /><br />
            </td>
        </tr>
        <tr>
            <td align="center">
                <asp:Label ID="lbMsg" runat="server" ForeColor="Tomato" Font-Size="Large"></asp:Label>
            </td>
        </tr>
        <tr runat="server" id="trInternalTr" visible="false">
            <td align="center">
                Revenue Split List (Internal Only)
                <asp:GridView runat="server" ID="gv1" AutoGenerateColumns="false">
                    <Columns>
                        <asp:BoundField HeaderText="Part No." DataField="CATEGORY_ID" />
                        <asp:BoundField HeaderText="Category Name" DataField="CATEGORY_NAME" />                        
                        <asp:BoundField HeaderText="Unit Price" DataField="CATEGORY_PRICE" />
                        <asp:BoundField HeaderText="Qty." DataField="CATEGORY_QTY" />
                    </Columns>
                </asp:GridView>
                
            </td>
        </tr>
    </table>
</asp:Content>

