<%@ Page Title="MyAdvantech - Minimum Price Inquiry" Language="C#" MasterPageFile="~/Includes/MyMaster.master" %>

<script runat="server">
    public static string[] AllowedUsers = new string[] { "li.jun@advantech.com", "edwin.teo@advantech.com" };
    public static string[] AllowedCompanyIDs = new string[] { "AVNS001", "AVNI001", "AVND001" };

    protected void Page_Load(object sender, EventArgs e)
    {
        AllowedUsers.Contains(User.Identity.Name);
        if (!Page.IsPostBack)
        {
            if (!MailUtil.IsInRole("GBS.ACL") && !MailUtil.IsInRole("MyAdvantech") &&
                !AllowedUsers.Contains(User.Identity.Name.ToLower()))
                Response.Redirect("..home.aspx");
        }

    }


    protected void btnCheck_Click(object sender, EventArgs e)
    {
        if (this.txtPN.Text.Trim().Length <= 5) return;
        tbResult.Visible = true;
        //var companyid = HttpContext.Current.Session["company_id"].ToString();
        string strError = ""; string strRelationType = ""; string strPConvert = ""; string strpintnumassign = "";
        string strPTestRun = ""; string Doc_Number = ""; string refDoc_Number = "";
        var ReturnObj = new BAPI_SALESORDER_SIMULATE.BAPIRETURN(); var retTable = new BAPI_SALESORDER_SIMULATE.BAPIRET2Table();
        var msgTable = new BAPI_SALESORDER_SIMULATE.BAPIRET2Table(); var ScheLine = new BAPI_SALESORDER_SIMULATE.BAPISCHDLTable();
        var OrderHeader = new BAPI_SALESORDER_SIMULATE.BAPISDHEAD();         //var Conditions = new BAPI_SALESORDER_SIMULATE.BAPICONDTable();
        var PayerObj = new BAPI_SALESORDER_SIMULATE.BAPIPAYER(); var ShipToObj = new BAPI_SALESORDER_SIMULATE.BAPISHIPTO();
        var SoldToObj = new BAPI_SALESORDER_SIMULATE.BAPISOLDTO();         //var S_OrderLineDt = new BAPI_SALESORDER_SIMULATE.BAPIITEMINTable();
        var Partners = new BAPI_SALESORDER_SIMULATE.BAPIPARTNRTable(); var S_ScheLineDT = new BAPI_SALESORDER_SIMULATE.BAPISCHDLTable();
        var S_CreditCardDT = new BAPI_SALESORDER_SIMULATE.BAPICCARDTable(); var S_ConditionDT = new BAPI_SALESORDER_SIMULATE.BAPICONDTable();
        var BAPICUINSTable1 = new BAPI_SALESORDER_SIMULATE.BAPICUINSTable(); var BAPIPAREXTable1 = new BAPI_SALESORDER_SIMULATE.BAPIPAREXTable();
        var BAPICCARDTable1 = new BAPI_SALESORDER_SIMULATE.BAPICCARDTable(); var BAPICCARD_EXTable1 = new BAPI_SALESORDER_SIMULATE.BAPICCARD_EXTable();
        var BAPICUBLBTable1 = new BAPI_SALESORDER_SIMULATE.BAPICUBLBTable(); var BAPICUPRTTable1 = new BAPI_SALESORDER_SIMULATE.BAPICUPRTTable();
        var BAPICUCFGTable1 = new BAPI_SALESORDER_SIMULATE.BAPICUCFGTable(); var BAPICUVALTable1 = new BAPI_SALESORDER_SIMULATE.BAPICUVALTable();
        var BAPIADDR1Table1 = new BAPI_SALESORDER_SIMULATE.BAPIADDR1Table(); var BAPIINCOMPTable1 = new BAPI_SALESORDER_SIMULATE.BAPIINCOMPTable();
        var BAPISDHEDUTable1 = new BAPI_SALESORDER_SIMULATE.BAPISDHEDUTable(); var ItemsOut = new BAPI_SALESORDER_SIMULATE.BAPIITEMEXTable();
        OrderHeader.Doc_Type = "ZOR"; OrderHeader.Sales_Org = "TW01"; OrderHeader.Distr_Chan = "10"; OrderHeader.Division = "00";


        var SoldTo = new BAPI_SALESORDER_SIMULATE.BAPIPARTNR(); var ShipTo = new BAPI_SALESORDER_SIMULATE.BAPIPARTNR();
        SoldTo.Partn_Role = "WE"; SoldTo.Partn_Numb = AllowedCompanyIDs[0];
        ShipTo.Partn_Role = "AG"; ShipTo.Partn_Numb = AllowedCompanyIDs[0];
        Partners.Add(SoldTo); Partners.Add(ShipTo);

        var ItemsIn = new BAPI_SALESORDER_SIMULATE.BAPIITEMINTable();
        var Item = new BAPI_SALESORDER_SIMULATE.BAPIITEMIN();
        Item.Material = Global_Inc.Format2SAPItem(this.txtPN.Text.Trim().ToUpper()); Item.Itm_Number = "1";
        Item.Req_Qty = "1";
        ItemsIn.Add(Item);
        var proxy1 = new BAPI_SALESORDER_SIMULATE.BAPI_SALESORDER_SIMULATE(System.Configuration.ConfigurationManager.AppSettings["SAP_PRD"]);
        proxy1.Connection.Open();
        proxy1.Bapi_Salesorder_Simulate("", OrderHeader, out PayerObj, out ReturnObj, out Doc_Number, out ShipToObj,
            out SoldToObj, ref BAPIPAREXTable1, ref retTable, ref S_CreditCardDT, ref BAPICCARD_EXTable1,
            ref BAPICUBLBTable1, ref BAPICUINSTable1, ref BAPICUPRTTable1, ref BAPICUCFGTable1,
            ref BAPICUVALTable1, ref S_ConditionDT, ref BAPIINCOMPTable1, ref ItemsIn,
            ref ItemsOut, ref Partners, ref BAPISDHEDUTable1, ref S_ScheLineDT, ref BAPIADDR1Table1);
        proxy1.Connection.Close();

        var ConditionList = new List<BAPI_SALESORDER_SIMULATE.BAPICOND>();
        foreach (BAPI_SALESORDER_SIMULATE.BAPICOND cond in S_ConditionDT)
            ConditionList.Add(cond);

        var ZMINCond = ConditionList.Where(p => p.Cond_Type == "ZMIP").ToList();
        if (ZMINCond.Count() > 0)
        {
            lbMinITP.Text = string.Format("{0} {1}", ZMINCond[0].Currency, ZMINCond[0].Cond_Value.ToString("0.00"));
            gvReturn.DataSource = null; gvReturn.DataBind();
        }
        else
        {
            lbMinITP.Text = "Cannot get ZMIP, please check detail error message below";
            gvReturn.DataSource = retTable.ToADODataTable(); gvReturn.DataBind();
        }
    }

</script>

<asp:Content ID="Content1" ContentPlaceHolderID="_main" runat="Server">
    <asp:Panel runat="server" ID="Panel1" DefaultButton="btnCheck">
        <table style="width: 250px">
            <tr align="left">
                <th>Part Number:</th>
                <td>
                    <ajaxToolkit:AutoCompleteExtender runat="server" ID="AutoCompleteExtender1" TargetControlID="txtPN"
                        MinimumPrefixLength="3" ServicePath="~/Services/AutoComplete.asmx" ServiceMethod="GetPartNo" />
                    <asp:TextBox runat="server" ID="txtPN" Width="120px" />
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:Button runat="server" ID="btnCheck" Text="Check" OnClick="btnCheck_Click" /></td>
            </tr>
        </table>
    </asp:Panel>
    <asp:UpdatePanel runat="server" ID="up1" UpdateMode="Conditional">
        <ContentTemplate>
            <table width="200px" runat="server" id="tbResult" visible="false">
                <tr align="left">
                    <th>Min. ITP:</th>
                    <td>
                        <asp:Label runat="server" ID="lbMinITP" />
                    </td>
                </tr>
                <tr>
                    <td colspan="2">
                        <asp:GridView runat="server" ID="gvReturn" AutoGenerateColumns="false" ShowHeader="false" EnableTheming="false" BorderWidth="0px" BorderStyle="None">
                            <Columns>
                                <asp:BoundField HeaderText="Message" DataField="Message" />
                            </Columns>
                        </asp:GridView>
                    </td>
                </tr>
            </table>
        </ContentTemplate>
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnCheck" EventName="Click" />
        </Triggers>
    </asp:UpdatePanel>
</asp:Content>
