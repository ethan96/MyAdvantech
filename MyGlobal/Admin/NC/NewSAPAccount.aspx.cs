using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_NewSAPAccount : System.Web.UI.Page
{
    static bool istesting = false;

    public static void getSAPDbAndRFCConn(out string SAPDbconnection, out string SAPRFCconnection) {
        SAPRFCconnection = "SAP_PRD"; if (istesting) SAPRFCconnection = "SAPConnTest";
        SAPDbconnection = "SAP_PRD"; if (istesting) SAPDbconnection = "SAP_Test";
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {        
        if (!Page.IsPostBack) {
            var CurrentUserRole = NewSAPAccountUtil.getCurrentUserRole();
            if (CurrentUserRole != NewSAPAccountUtil.UserRole.MyAdvIT && 
                CurrentUserRole != NewSAPAccountUtil.UserRole.OPLeader && 
                CurrentUserRole != NewSAPAccountUtil.UserRole.CFC) {
                btnCreateSAPAccount.Enabled = false;
            }
            string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
            var dtShipConds = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select vsbed, vtext from saprdp.tvsbt where mandt='168' and spras='E' order by vsbed");
            var dtPayTerms = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select zterm, vtext from saprdp.tvzbt where mandt='168' and spras='E' and vtext<>' ' order by zterm");
            var dtIncoTerms = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select inco1, bezei from SAPRDP.TINCT where mandt='168' and spras='E' order by inco1");
            var dtPriceGrps = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select konda, vtext from SAPRDP.T188T where mandt='168' and spras='E'");
            var dtCountries = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select land1, landx from saprdp.t005t where mandt='168' and spras='E' order by landx");
            var dtMWSTTaxIdList = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select taxkd, vtext from saprdp.tskdt where spras='E' and mandt='168' and tatyp='MWST' order by taxkd");
            var dtUTXJTaxIdList = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select taxkd, vtext from saprdp.tskdt where spras='E' and mandt='168' and tatyp='UTXJ' order by taxkd");
            var dtCustGroup = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select kdgrp, ktext from SAPRDP.T151T where mandt='168' and spras='E' and ktext not like '%MLP' and kdgrp not in ('15','19','22','23','K2') order by kdgrp");
            var dtDistricts = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select bzirk, bztxt from SAPRDP.T171T where mandt='168' and spras='E' and bzirk not in (' ') order by bzirk");
            var dtMktIndustryCodes = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select braco, vtext from saprdp.TBRCT where mandt='168' and spras='E' order by braco");
            var dtKATR1 = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select katr1, vtext from saprdp.TVK1T where mandt='168' and spras='E' order by katr1");
            var dtKATR9 = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select katr9, vtext from saprdp.TVK9T where mandt='168' and spras='E' order by katr9");
            foreach (DataRow shipConDR in dtShipConds.Rows) { dlShipConds.Items.Add(new ListItem(string.Format("{0} ({1})", shipConDR["vtext"].ToString(), shipConDR["vsbed"].ToString()), shipConDR["vsbed"].ToString())); }
            foreach (DataRow payDR in dtPayTerms.Rows) { dlPayTerms.Items.Add(new ListItem(string.Format("{0} ({1})", payDR["vtext"].ToString(), payDR["zterm"].ToString()), payDR["zterm"].ToString())); }
            foreach (DataRow incoDR in dtIncoTerms.Rows) { dlIncoTerms.Items.Add(new ListItem(string.Format("{0} ({1})", incoDR["bezei"].ToString(), incoDR["inco1"].ToString()), incoDR["inco1"].ToString())); }
            foreach (DataRow countryDR in dtCountries.Rows) { dlCountryCode.Items.Add(new ListItem(string.Format("{0} ({1})",countryDR["landx"].ToString(), countryDR["land1"].ToString()),countryDR["land1"].ToString())); }
            dlCountryCode.Items.Insert(0, new ListItem("Select...", ""));
            foreach (DataRow custGrpDR in dtCustGroup.Rows) { dlCustGrp.Items.Add(new ListItem(string.Format("{0} ({1})",custGrpDR["ktext"].ToString(), custGrpDR["kdgrp"].ToString()), custGrpDR["kdgrp"].ToString())); }
            foreach (DataRow taxDR in dtMWSTTaxIdList.Rows) { dlMWSTTaxCode.Items.Add(new ListItem(string.Format("{0} ({1})", taxDR["vtext"].ToString(), taxDR["taxkd"].ToString()), taxDR["taxkd"].ToString())); }
            foreach (DataRow taxDR in dtUTXJTaxIdList.Rows) { dlUTXJTaxCode.Items.Add(new ListItem(string.Format("{0} ({1})", taxDR["vtext"].ToString(), taxDR["taxkd"].ToString()), taxDR["taxkd"].ToString())); }
            foreach (DataRow pgDR in dtPriceGrps.Rows) { dlPriceGrp.Items.Add(new ListItem(string.Format("{0} ({1})",pgDR["vtext"].ToString(), pgDR["konda"].ToString()), pgDR["konda"].ToString())); }
            dlDistrict.Items.Add(new ListItem("no need", ""));
            foreach (DataRow districtDR in dtDistricts.Rows) { dlDistrict.Items.Add(new ListItem(string.Format("{0} ({1})", districtDR["bztxt"].ToString(), districtDR["bzirk"].ToString()), districtDR["bzirk"].ToString())); }
            dlMktIndustryCode1.Items.Add(new ListItem("no need", ""));
            foreach (DataRow indCodeDR in dtMktIndustryCodes.Rows) { dlMktIndustryCode1.Items.Add(new ListItem(string.Format("{0} ({1})", indCodeDR["vtext"].ToString(), indCodeDR["braco"].ToString()), indCodeDR["braco"].ToString())); }
            dlMktIndustryCode2.Items.Add(new ListItem("no need", ""));
            foreach (DataRow indCodeDR in dtMktIndustryCodes.Rows) { dlMktIndustryCode2.Items.Add(new ListItem(string.Format("{0} ({1})", indCodeDR["vtext"].ToString(), indCodeDR["braco"].ToString()), indCodeDR["braco"].ToString())); }
            dlKATR1.Items.Add(new ListItem("no need", "")); dlKATR9.Items.Add(new ListItem("no need", ""));
            foreach (DataRow DR in dtKATR1.Rows) { dlKATR1.Items.Add(new ListItem(string.Format("{0} ({1})", DR["vtext"].ToString(), DR["katr1"].ToString()), DR["katr1"].ToString())); }
            foreach (DataRow DR in dtKATR9.Rows) { dlKATR9.Items.Add(new ListItem(string.Format("{0} ({1})", DR["vtext"].ToString(), DR["katr9"].ToString()), DR["katr9"].ToString())); }
            dlAccountGrp_SelectedIndexChanged(null, null);
            ApplicationId.Value = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 10);
            var currentUserRole = NewSAPAccountUtil.getCurrentUserRole();
            if (currentUserRole == NewSAPAccountUtil.UserRole.NoOne || currentUserRole == NewSAPAccountUtil.UserRole.Sales) btnCreateSAPAccount.Enabled = false;

            if (Request["AppId"] != null)
            {
                btnSaveAsApplication.Visible = false; btnCreateSAPAccount.Visible = false; btnApproval.Enabled = false;
                var dtAppInfo = dbUtil.dbGetDataTable("MY_EC2",
                    @"SELECT ApplicationId, TicketId, CreatedBy, AppliedDate, ApprovalManager, 
                    isnull(ManagerApprovalStatus,0) as ManagerApprovalStatus, isnull(ManagerComment,'') as ManagerComment,
                    ApprovalOP, isnull(OPApprovalStatus,0) as OPApprovalStatus,isnull(OPComment,'') as OPComment, AccountJsonData
                        FROM NEW_SAP_ACCOUNT_APPLICATIONS_HQ
                        where ApplicationId='" + Request["AppId"].ToString() + "'");
                if (dtAppInfo.Rows.Count == 1)
                {
                    this.ApplicationId.Value = Request["AppId"].ToString();
                    DataRow drAppInfo = dtAppInfo.Rows[0];
                    string JsonAccountData = drAppInfo["AccountJsonData"].ToString();
                    var jsr = new System.Web.Script.Serialization.JavaScriptSerializer();
                    NewSAPAccountUtil.NewSAPAccountRequest req = jsr.Deserialize<NewSAPAccountUtil.NewSAPAccountRequest>(JsonAccountData);
                    var AccountReq = NewSAPAccountUtil.getReqDetail(this.ApplicationId.Value);
                    this.dviApproval.Visible = true;
                    lbTicketId.Text = drAppInfo["TicketId"].ToString();
                    lbReqBy.Text = drAppInfo["CreatedBy"].ToString(); lbReqDate.Text = drAppInfo["AppliedDate"].ToString();
                    if (AccountReq.ApprovalManager.Equals(User.Identity.Name, StringComparison.CurrentCultureIgnoreCase) 
                        && AccountReq.ManagerApprovalStatus == NewSAPAccountUtil.NewAccountApprovalStatus.Waiting_For_Approval)
                        btnApproval.Enabled = true;
                    if (NewSAPAccountUtil.getCurrentUserRole() == NewSAPAccountUtil.UserRole.OPLeader) {
                        btnApproval.Enabled = true;
                        //btnCreateSAPAccount.Visible = true;
                    }
                    lbApprovalLog.Text = NewSAPAccountUtil.getApprovalStatus(this.ApplicationId.Value);

                    dlAccountGrp.Items.FindByText(req.AccountGroup).Selected = true;
                    dlAccountGrp_SelectedIndexChanged(null, null);
                    dlSalesOffice.SelectedIndex = -1; dlSalesOffice.Items.FindByText(req.SalesOffice).Selected = true;
                    dlSalesOffice_SelectedIndexChanged(dlSalesOffice, null);
                    dlSalesGroup.SelectedIndex = -1;
                    if(dlSalesGroup.Items.FindByText(req.SalesGroup) != null) dlSalesGroup.Items.FindByText(req.SalesGroup).Selected = true;
                    txtCompanyId.Text = req.KUNNR; txtLinkToCompanyId.Text = req.Link2SoldToId;
                    txtCompanyName.Text = req.CompanyName; txtAddrNotes.Text = req.Comment;
                    txtSearchTerm1.Text = req.SearchTerm1; txtSearchTerm2.Text = req.SearchTerm2;
                    txtAddr1.Text = req.Address1; txtAddr2.Text = req.Address2; txtAddr3.Text = req.Address3;
                    dlCountryCode.SelectedIndex = -1; dlCountryCode.Items.FindByText(req.Country).Selected = true;
                    txtCity.Text = req.City; txtPostCode.Text = req.PostCode;
                    if (dlCountryCode.SelectedIndex >= 0)
                    {
                        dlCountryCode_SelectedIndexChanged(null, null);
                    }
                    if (req.Region != "")
                    {
                        dlRegion.SelectedIndex = -1; if(dlRegion.Items.FindByText(req.Region)!=null) dlRegion.Items.FindByText(req.Region).Selected = true;
                    }

                    dlDistrict.SelectedIndex = -1; dlDistrict.Items.FindByText(req.District).Selected = true;
                    txtTelephone.Text = req.Telephone; txtTelExt.Text = req.TelExt; txtFAX.Text = req.FaxNo;
                    txtContactPersonFName.Text = req.ContactFName; txtContactPersonLName.Text = req.ContactLName;
                    txtContactPersonEmail.Text = req.ContactEmail; txtTaxNum1.Text = req.OfficeRegNo;
                    txtDUNSNo.Text = req.DUNSNo; txtDBPayIdx.Text = req.DBPayIdx; txtVATNo.Text = req.VATNo;
                    txtWebSiteURL.Text = req.WebsiteURL;
                    dlShipConds.SelectedIndex = -1; dlShipConds.Items.FindByText(req.ShipCond).Selected = true;
                    dlPayTerms.SelectedIndex = -1; dlPayTerms.Items.FindByText(req.PayTerm).Selected = true;
                    dlIncoTerms.SelectedIndex = -1; dlIncoTerms.Items.FindByText(req.IncoTerm).Selected = true;
                    txtIncotxt.Text = req.IncoText;
                    dlIndustry.SelectedIndex = -1; dlIndustry.Items.FindByText(req.Industry).Selected = true;
                    dlMktIndustryCode1.SelectedIndex = -1; dlMktIndustryCode1.Items.FindByText(req.IndustryCode1).Selected = true;
                    dlMktIndustryCode2.SelectedIndex = -1; dlMktIndustryCode2.Items.FindByText(req.IndustryCode2).Selected = true;
                    dlCustGrp.SelectedIndex = -1; dlCustGrp.Items.FindByText(req.CustGroup).Selected = true;
                    dlMWSTTaxCode.SelectedIndex = -1; dlMWSTTaxCode.Items.FindByText(req.MWST_TaxCode).Selected = true;
                    dlUTXJTaxCode.SelectedIndex = -1; dlUTXJTaxCode.Items.FindByText(req.UTXJ_TaxCode).Selected = true;
                    dlAccAssignGrp.SelectedIndex = -1; dlAccAssignGrp.Items.FindByText(req.AccountAssignGroup).Selected = true;
                    dlCustClass.SelectedIndex = -1; dlCustClass.Items.FindByText(req.CustClass).Selected = true;
                    dlCondGrp1.SelectedIndex = -1; dlCondGrp1.Items.FindByText(req.PriceGrade1).Selected = true;
                    dlCondGrp2.SelectedIndex = -1; dlCondGrp2.Items.FindByText(req.PriceGrade2).Selected = true;
                    dlCondGrp3.SelectedIndex = -1; dlCondGrp3.Items.FindByText(req.PriceGrade3).Selected = true;
                    dlCondGrp4.SelectedIndex = -1; dlCondGrp4.Items.FindByText(req.PriceGrade4).Selected = true;
                    dlPriceGrp.SelectedIndex = -1; dlPriceGrp.Items.FindByText(req.PriceGroup).Selected = true;
                    dlCurrency.SelectedIndex = -1; dlCurrency.Items.FindByText(req.Currency).Selected = true;
                    dlKATR1.SelectedIndex = -1; dlKATR1.Items.FindByText(req.AdditionalCustAttr1).Selected = true;
                    dlKATR9.SelectedIndex = -1; dlKATR9.Items.FindByText(req.AdditionalCustAttr9).Selected = true;

                    var MyApt = new System.Data.SqlClient.SqlDataAdapter("", System.Configuration.ConfigurationManager.ConnectionStrings["MY"].ConnectionString);
                    MyApt.SelectCommand.CommandText = "select account_name from siebel_account where row_id='" + req.SiebelAccountId + "'";
                    if (req.SiebelAccountId != "")
                    {
                        var dtSiebel = new DataTable();
                        MyApt.Fill(dtSiebel);
                        if (dtSiebel.Rows.Count > 0)
                        {
                            txtSiebelAccountInfo.Text = string.Format("{0} ({1})", dtSiebel.Rows[0]["account_name"].ToString(), req.SiebelAccountId);
                        }
                        hdSiebelAccountRowId.Value = req.SiebelAccountId;
                    }
                    MyApt.SelectCommand.Connection.Close();
                    btnShowUploadedFiles_Click(null, null);
                    TimerLoadSalesIDs.Enabled = true;
                }
            }           

        }
    }

    public void LinkBillShipToWithSoldTo(string LinkToSoldToId, string ShipBillToId, string ShipBillParvw, string ShipBillParza, string OrgId, string DivisionSpart)
    {
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);

        var knvpTable = new ZCUSTOMER_UPDATE_SALES_AREA.FKNVPTable();
        var ShipBillToRow = new ZCUSTOMER_UPDATE_SALES_AREA.FKNVP()
        {
            Defpa = "",
            Knref = "",
            Kunn2 = ShipBillToId,
            Kunnr = LinkToSoldToId,
            Lifnr = "",
            Mandt = "168",
            Parnr = "0000000000",
            Parvw = ShipBillParvw,
            Parza = ShipBillParza,
            Pernr = "00000000",
            Spart = DivisionSpart,
            Vkorg = OrgId,
            Vtweg = "00",
            Kz = "I"
        };
        knvpTable.Add(ShipBillToRow);
        ZCUSTOMER_UPDATE_SALES_AREA.ZCUSTOMER_UPDATE_SALES_AREA p1 = new ZCUSTOMER_UPDATE_SALES_AREA.ZCUSTOMER_UPDATE_SALES_AREA();
        p1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[GlobSAPDbconnection]);        
        var vd1 = new ZCUSTOMER_UPDATE_SALES_AREA.FKNVDTable(); var vv = new ZCUSTOMER_UPDATE_SALES_AREA.KNVVTable();
        var vd2 = new ZCUSTOMER_UPDATE_SALES_AREA.FKNVDTable(); var vp = new ZCUSTOMER_UPDATE_SALES_AREA.FKNVPTable();
        p1.Connection.Open();
        p1.Zcustomer_Update_Sales_Area(ref vd1, ref knvpTable, ref vv, ref vd2, ref vp);
        p1.CommitWork();
        p1.Connection.Close();
    }
   
    protected void dlOrgID_SelectedIndexChanged(object sender, EventArgs e)
    {
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
        var CreditControlArea = SalesOrgToCreditControlArea(dlOrgID.SelectedValue);
        //Get office from SAP testing because B+B's data is not yet on SAP RDP
        var dtOrgOffices = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, @"
            select distinct a.vkbur as officecode, b.bezei as officedesc from saprdp.tvkbz a inner join saprdp.tvkbt b on a.vkbur=b.vkbur 
            where a.mandt='168' and b.mandt='168' 
            and a.vkorg='" + dlOrgID.SelectedValue + "' and b.spras='E' order by a.vkbur");
        dlSalesOffice.Items.Clear();
        foreach (DataRow officeRow in dtOrgOffices.Rows)
        {
            dlSalesOffice.Items.Add(new ListItem(string.Format("{0} ({1})", officeRow["officecode"].ToString(), officeRow["officedesc"].ToString()), officeRow["officecode"].ToString()));
        }
        dlSalesOffice_SelectedIndexChanged(this.dlSalesOffice, new EventArgs());
        //20170921 TC: Per B+B Sylvia's request, force industry code to be 2000
        dlIndustry.Enabled = true; dlCustGrp.Enabled = true; tbPriceGrades.Visible = true;
        switch (dlOrgID.SelectedValue) {            
            case "TW01":
                dlCustGrp.SelectedIndex = -1; dlCustGrp.Items.FindByValue("03").Selected = true;
                dlIndustry.SelectedIndex = -1; dlIndustry.Items.FindByValue("1000").Selected = true;
                break;
        }
        var ReadSAPTable = new Read_Sap_Table.Read_Sap_Table();
        var SAPTableData = new Read_Sap_Table.TAB512Table(); var SAPTableFields = new Read_Sap_Table.RFC_DB_FLDTable();
        var SAPTableQuery = new Read_Sap_Table.RFC_DB_OPTTable();        

        SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() {Fieldname="SBGRP"}); SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() {Fieldname = "STEXT"});
        SAPTableQuery.Add(new Read_Sap_Table.RFC_DB_OPT() { Text="KKBER EQ "+ "'"+ CreditControlArea + "'" });

        ReadSAPTable.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[GlobSAPRFCconnection]);
        ReadSAPTable.Connection.Open();
        ReadSAPTable.Rfc_Read_Table(";", "", "T024B", 0, 0, ref SAPTableData, ref SAPTableFields, ref SAPTableQuery);
        dlCredRepGrp.Items.Clear();
        foreach (Read_Sap_Table.TAB512 SAPTableRec in SAPTableData)
        {
            var SapTableRecFields = SAPTableRec.Wa.Split(new string[] { ";" }, StringSplitOptions.None);
            dlCredRepGrp.Items.Add(new ListItem(SapTableRecFields[1] + " (" + SapTableRecFields[0] + ")", SapTableRecFields[0]));
        }
        if (dlCredRepGrp.Items.Count == 0) dlCredRepGrp.Items.Add(new ListItem("no need", ""));

        SAPTableData = new Read_Sap_Table.TAB512Table(); SAPTableFields = new Read_Sap_Table.RFC_DB_FLDTable(); SAPTableQuery = new Read_Sap_Table.RFC_DB_OPTTable();
        SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() { Fieldname = "CTLPC" }); SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() { Fieldname = "RTEXT" });
        SAPTableQuery.Add(new Read_Sap_Table.RFC_DB_OPT() { Text = "SPRAS EQ 'E' AND KKBER EQ '"+CreditControlArea+"'" });
        ReadSAPTable.Rfc_Read_Table(";", "", "T691T", 0, 0, ref SAPTableData, ref SAPTableFields, ref SAPTableQuery);
        ReadSAPTable.Connection.Close();

        dlCreditAmtRiskCat.Items.Clear();
        foreach (Read_Sap_Table.TAB512 SAPTableRec in SAPTableData) {
            var SapTableRecFields = SAPTableRec.Wa.Split(new string[] { ";" }, StringSplitOptions.None);
            dlCreditAmtRiskCat.Items.Add(new ListItem(SapTableRecFields[1] + " (" + SapTableRecFields[0] + ")", SapTableRecFields[0]));
        }
        if (dlCreditAmtRiskCat.Items.Count == 0) dlCreditAmtRiskCat.Items.Add(new ListItem("no need", ""));
    }

    protected void dlSalesOffice_SelectedIndexChanged(object sender, EventArgs e)
    {
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
        dlSalesGroup.Items.Clear();
        var dtSalesGroup = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, string.Format(@"
        select b.vkgrp, b.bezei
        from saprdp.tvbvk a inner join saprdp.tvgrt b on a.vkgrp=b.vkgrp
        where a.mandt='168' and b.mandt='168' and b.spras='E' and a.vkbur='{0}'
        order by b.vkgrp", dlSalesOffice.SelectedValue));

        foreach (DataRow grpRow in dtSalesGroup.Rows)
        {
            dlSalesGroup.Items.Add(new ListItem(string.Format("{0} ({1})", grpRow["vkgrp"].ToString(), grpRow["bezei"].ToString()), grpRow["vkgrp"].ToString()));
        }

    }
    string SalesOrgToCreditControlArea(string OrgId) {
        var CreditControlArea = "";
        switch (OrgId)
        {
            case "EU10":
                CreditControlArea = "EU01"; break;
            case "US10":
                CreditControlArea = "US10"; break;
            case "TW01":
                CreditControlArea = "TW01"; break;
        }
        return CreditControlArea;
    }

    protected void btnCreateSAPAccount_Click(Object sender, EventArgs e) {
        var senderButton = (Button)sender;
        lbMsg.Text = "";
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
        string DivisionSpart = "00"; //Only when org=US01 then should let user specify 10 eAutomation or 20 ePlatform

        string SoldToId = txtCompanyId.Text.Trim().ToUpper();
        string ShipBillToId = string.Empty;
        string LinkToSoldToId = txtLinkToCompanyId.Text.Trim().ToUpper();
        var ShipBillParvw = string.Empty;//WE or RE
        var ShipBillParza = string.Empty;//Sequence number for WE or RE in KNVP table
        //Check if all required fields are selected or input   
        if (senderButton.ID == "btnCreateSAPAccount") {
            if (dlAccountGrp.SelectedValue == "Z001" && (string.IsNullOrEmpty(SoldToId) || SoldToId.Length <= 4 || SoldToId.Length > 10))
            {
                lbMsg.Text = string.Format("length of company id must be at least 4 charaters and no more than 10 characters"); return;
            }
            else
            {
                var dtDoesIdExist = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select kunnr from saprdp.kna1 where kunnr='" + SoldToId + "'");
                if (dtDoesIdExist.Rows.Count > 0) { lbMsg.Text = string.Format("{0} already exists", SoldToId); return; }
            }
        }       

        if ((dlAccountGrp.SelectedValue == "Z002" || dlAccountGrp.SelectedValue == "Z003") && string.IsNullOrEmpty(LinkToSoldToId))
        {
            //Create ship-to or bill-to, and must link to an existing sold-to id
            lbMsg.Text = string.Format("Link to sold-to id cannot be empty"); return;
        }
        if (dlAccountGrp.SelectedValue == "Z002" || dlAccountGrp.SelectedValue == "Z003")
        {
            var dtDoesIdExist = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, 
                @"select a.kunnr from saprdp.kna1 a inner join saprdp.knvv b on a.kunnr=b.kunnr 
                where a.ktokd='Z001' and a.kunnr='" + LinkToSoldToId + "' and b.vkorg='"+dlOrgID.SelectedValue+"'");
            if (dtDoesIdExist.Rows.Count == 0) {
                lbMsg.Text = string.Format("sold-to id {0} does not exist in org {1}", LinkToSoldToId, dlOrgID.SelectedValue); return;
            }
        }
        
        if (string.IsNullOrEmpty(txtCompanyName.Text.Trim())) { lbMsg.Text = string.Format("Company name cannot be empty"); return; }
        if (dlCountryCode.SelectedIndex == 0) { lbMsg.Text = string.Format("Please select one country"); return; }

        //Determine new id for ship/bill-to based on sold-to id. Ex: Sold-to ID EDDEVI07, then ship/bill-to should be EDDEVI07A, EDDEVI07B...etc., 
        if ((dlAccountGrp.SelectedValue == "Z002" || dlAccountGrp.SelectedValue == "Z003")) {
            ShipBillParvw = dlAccountGrp.SelectedValue == "Z002" ? "WE" : "RE";
            char[] alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray();
            //string ShipBillId = string.Empty;            
            string ShipBillIdPrefix = LinkToSoldToId.Length >= 10 ? LinkToSoldToId.Substring(0, LinkToSoldToId.Length - 1) : LinkToSoldToId;            
            var dtMaxKunnr = OraDbUtil.dbGetDataTable(GlobSAPDbconnection,
                    "select kunn2, parza from saprdp.knvp where mandt='168' and parvw='" + ShipBillParvw + "' and kunnr='" + LinkToSoldToId + "' order by parza desc");
            if (dtMaxKunnr.Rows.Count == 0) ShipBillParza = "000";
            else
            {
                ShipBillParza = (int.Parse(dtMaxKunnr.Rows[0]["parza"].ToString()) + 1).ToString();
                while (ShipBillParza.Length < 3) ShipBillParza = "0" + ShipBillParza;
            }
            var SapOracleDbConn = new Oracle.DataAccess.Client.OracleConnection(System.Configuration.ConfigurationManager.ConnectionStrings[GlobSAPRFCconnection].ConnectionString);
            SapOracleDbConn.Open();
            for (int idx1 = 1; idx1 <= 27; idx1++)
            {
                for (int idx2 = 1; idx2 <= 26; idx2++)
                {
                    if (idx1 <= 1)
                    {
                        ShipBillToId = ShipBillIdPrefix + alpha[idx2 - 1];
                    }
                    else
                    {
                        if (ShipBillIdPrefix.Length == 9) ShipBillIdPrefix = ShipBillIdPrefix.Substring(0, ShipBillIdPrefix.Length - 1);
                        ShipBillToId = ShipBillIdPrefix + alpha[idx1 - 2] + alpha[idx2 - 1];
                    }
                    var chkIdExtCmd = new Oracle.DataAccess.Client.OracleCommand(string.Format(
                        @"select count(kunn2) from saprdp.knvp where mandt='168' and kunn2='{0}'", ShipBillToId), SapOracleDbConn);
                    if (int.Parse(chkIdExtCmd.ExecuteScalar().ToString()) == 0) break;
                    ShipBillToId = string.Empty;                    
                }
                if (!string.IsNullOrEmpty(ShipBillToId)) break;
            }
            SapOracleDbConn.Close();
        }

        string SalesCode = "00000000"; string OPCode = "00000000"; string ISCode = "00000000";
        if (!string.IsNullOrEmpty(txtSalesCode.Text)) SalesCode = txtSalesCode.Text;
        if (!string.IsNullOrEmpty(txtOPCode.Text)) OPCode = txtOPCode.Text;
        if (!string.IsNullOrEmpty(txtInsideSalesCode.Text)) ISCode = txtInsideSalesCode.Text;        

        var p1 = new SAPCustomerRFC.SAPCustomerRFC();
        p1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[GlobSAPRFCconnection]);

        var I_Bapiaddr1 = new SAPCustomerRFC.BAPIADDR1(); var I_Bapiaddr2 = new SAPCustomerRFC.BAPIADDR2();        var I_Kna1 = new SAPCustomerRFC.KNA1();        var I_Knb1 = new SAPCustomerRFC.KNB1();         var I_Knvv = new SAPCustomerRFC.KNVV();
        var O_Kna1 = new SAPCustomerRFC.KNA1();        var T_Upd_Txt = new SAPCustomerRFC.FKUNTXTTable(); var T_Xkn = new SAPCustomerRFC.FKNASTable();        var T_Xknb5 = new SAPCustomerRFC.FKNB5Table(); var T_Xknbk = new SAPCustomerRFC.FKNBKTable();
        var T_Xknex = new SAPCustomerRFC.FKNEXTable(); var T_Xknva = new SAPCustomerRFC.FKNVATable();        var T_Xknvd = new SAPCustomerRFC.FKNVDTable(); var T_Xknvi = new SAPCustomerRFC.FKNVITable();
        var T_Xknvk = new SAPCustomerRFC.FKNVKTable(); var T_Xknvl = new SAPCustomerRFC.FKNVLTable();        var T_Xknvp = new SAPCustomerRFC.FKNVPTable(); var T_Xknza = new SAPCustomerRFC.FKNZATable();
        var T_Ykn = new SAPCustomerRFC.FKNASTable(); var T_Yknb5 = new SAPCustomerRFC.FKNB5Table();        var T_Yknbk = new SAPCustomerRFC.FKNBKTable(); var T_Yknex = new SAPCustomerRFC.FKNEXTable();
        var T_Yknva = new SAPCustomerRFC.FKNVATable(); var T_Yknvd = new SAPCustomerRFC.FKNVDTable();        var T_Yknvi = new SAPCustomerRFC.FKNVITable(); var T_Yknvk = new SAPCustomerRFC.FKNVKTable();
        var T_Yknvl = new SAPCustomerRFC.FKNVLTable(); var T_Yknvp = new SAPCustomerRFC.FKNVPTable();        var T_Yknza = new SAPCustomerRFC.FKNZATable();
        var Pi_Add_On_Data = new SAPCustomerRFC.CUST_ADD_ON_DATA();
        string Pi_Cam_Changed = "";         string Pi_Postflag = "";        string E_Kunnr = ""; string E_Sd_Cust_1321_Done = "";
        string I_Maintain_Address_By_Kna1 = "X";        string I_Knb1_Reference = "";        string I_No_Bank_Master_Update = "";
        string I_Raise_No_Bte = "";        string I_Customer_Is_Consumer = "";        string I_Force_External_Number_Range = "";      
        
        I_Bapiaddr1.Addr_No = "";         I_Bapiaddr1.Adr_Notes = txtAddrNotes.Text;         I_Bapiaddr1.Build_Long = " ";        I_Bapiaddr1.Building = " ";
        I_Bapiaddr1.C_O_Name = txtContactPersonFName.Text + " " +txtContactPersonLName.Text;         I_Bapiaddr1.Chckstatus = " ";         I_Bapiaddr1.City = txtCity.Text;
        I_Bapiaddr1.City_No = "";         I_Bapiaddr1.Comm_Type = "INT";         I_Bapiaddr1.Country = dlCountryCode.SelectedValue;
        I_Bapiaddr1.Countryiso = " ";        I_Bapiaddr1.County = "";         I_Bapiaddr1.County_Code = dlRegion.SelectedValue;
        I_Bapiaddr1.Deli_Serv_Number = " ";        I_Bapiaddr1.Deli_Serv_Type = " ";         I_Bapiaddr1.Deliv_Dis = " ";        I_Bapiaddr1.Distrct_No = " ";
        I_Bapiaddr1.District = "";         I_Bapiaddr1.Dont_Use_P = " ";        I_Bapiaddr1.Dont_Use_S = " ";
        I_Bapiaddr1.E_Mail = txtContactPersonEmail.Text;         I_Bapiaddr1.Fax_Extens = "";
        I_Bapiaddr1.Fax_Number = txtFAX.Text;         I_Bapiaddr1.Floor = "";         I_Bapiaddr1.Formofaddr = " ";
        I_Bapiaddr1.Home_City = txtCity.Text;         I_Bapiaddr1.Homecityno = "";
        I_Bapiaddr1.Homepage = txtWebSiteURL.Text;         I_Bapiaddr1.House_No = " ";        I_Bapiaddr1.House_No2 = " ";        I_Bapiaddr1.House_No3 = " ";
        I_Bapiaddr1.Langu = "E";         I_Bapiaddr1.Langu_Cr = " ";        I_Bapiaddr1.Langu_Iso = " ";        I_Bapiaddr1.Langucriso = " ";        I_Bapiaddr1.Location = " ";
        I_Bapiaddr1.Name = txtCompanyName.Text;         I_Bapiaddr1.Name_2 = "";
        if (txtCompanyName.Text.Length >= 35)
        {
            I_Bapiaddr1.Name = txtCompanyName.Text.Substring(0, 35); I_Bapiaddr1.Name_2 = txtCompanyName.Text.Substring(35);
        }

        I_Bapiaddr1.Name_3 = "";         I_Bapiaddr1.Name_4 = "";
        I_Bapiaddr1.Pboxcit_No = " ";        I_Bapiaddr1.Pcode1_Ext = " ";        I_Bapiaddr1.Pcode2_Ext = " ";        I_Bapiaddr1.Pcode3_Ext = " ";
        I_Bapiaddr1.Po_Box = " ";        I_Bapiaddr1.Po_Box_Cit = " ";        I_Bapiaddr1.Po_Box_Lobby = " ";        I_Bapiaddr1.Po_Box_Reg = " ";
        I_Bapiaddr1.Po_Ctryiso = " ";        I_Bapiaddr1.Po_W_O_No = " ";        I_Bapiaddr1.Pobox_Ctry = " ";
        I_Bapiaddr1.Postl_Cod1 = txtPostCode.Text;
        I_Bapiaddr1.Postl_Cod2 = " ";        I_Bapiaddr1.Postl_Cod3 = " ";        I_Bapiaddr1.Regiogroup = " ";        I_Bapiaddr1.Region = dlRegion.SelectedValue;
        I_Bapiaddr1.Room_No = " ";        I_Bapiaddr1.Sort1 = txtSearchTerm1.Text;        I_Bapiaddr1.Sort2 = txtSearchTerm2.Text;
        I_Bapiaddr1.Str_Abbr = " ";        I_Bapiaddr1.Str_Suppl1 = " ";        I_Bapiaddr1.Str_Suppl2 = " ";
        I_Bapiaddr1.Str_Suppl3 = " ";        I_Bapiaddr1.Street = txtAddr1.Text;        I_Bapiaddr1.Street_Lng = " ";
        I_Bapiaddr1.Street_No = "";
        I_Bapiaddr1.Taxjurcode = I_Bapiaddr1.Region + I_Bapiaddr1.Postl_Cod1; //20170926 TC: For US, tax jur. code should always be region(state) + zipcode
        I_Bapiaddr1.Tel1_Ext = txtTelExt.Text;
        I_Bapiaddr1.Tel1_Numbr = txtTelephone.Text;         I_Bapiaddr1.Time_Zone = dlTimeZone.SelectedValue;
        I_Bapiaddr1.Title = "Company";         I_Bapiaddr1.Township = " ";         I_Bapiaddr1.Township_Code = " ";
        I_Bapiaddr1.Transpzone = dlTransZone.SelectedValue;
        I_Bapiaddr1.Uri_Type = " ";
        
        I_Kna1.Abrvw = " ";
        //  I_Kna1.Adrnr = currKNA1.Adrnr;
        I_Kna1.Alc = " ";
        I_Kna1.Anred = "Company";
        I_Kna1.Aufsd = " ";        I_Kna1.Bahne = " ";        I_Kna1.Bahns = " ";        I_Kna1.Bbbnr = "0000000";        I_Kna1.Bbsnr = "00000";
        I_Kna1.Begru = " ";        I_Kna1.Bran1 = dlMktIndustryCode1.SelectedValue;        I_Kna1.Bran2 = " ";        I_Kna1.Bran3 = " ";        I_Kna1.Bran4 = " ";        I_Kna1.Bran5 = " ";
        I_Kna1.Brsch = dlIndustry.SelectedValue; //Industry
        I_Kna1.Bubkz = "0";        I_Kna1.Cassd = " ";        I_Kna1.Ccc01 = " ";        I_Kna1.Ccc02 = " ";        I_Kna1.Ccc03 = " ";        I_Kna1.Ccc04 = " ";
        I_Kna1.Cfopc = " ";        I_Kna1.Cityc = " ";
        I_Kna1.Civve = "X"; //ID for mainly non-military use
        I_Kna1.Confs = " ";        I_Kna1.Counc = " ";        I_Kna1.Datlt = " ";        I_Kna1.Dear1 = " ";        I_Kna1.Dear2 = " ";
        I_Kna1.Dear3 = " ";        I_Kna1.Dear4 = " ";        I_Kna1.Dear5 = " ";        I_Kna1.Dear6 = " ";        I_Kna1.Dtams = " ";        I_Kna1.Dtaws = " ";
        I_Kna1.Duefl = "X"; //Status of Data Transfer into Subsequent Release
        I_Kna1.Ekont = " ";
        I_Kna1.Erdat = DateTime.Now.ToString("yyyyMMdd");        I_Kna1.Ernam = "B2BAEU";
        I_Kna1.Etikg = " ";        I_Kna1.Exabl = " ";        I_Kna1.Faksd = " ";        I_Kna1.Fiskn = " ";        I_Kna1.Fityp = " ";        I_Kna1.Gform = " ";
        I_Kna1.Hzuor = "00";//Assignment to Hierarchy
        I_Kna1.Inspatdebi = " ";        I_Kna1.Inspbydebi = " ";        I_Kna1.J_1kfrepre = " ";        I_Kna1.J_1kftbus = " ";        I_Kna1.J_1kftind = " ";
        I_Kna1.Jmjah = "0000"; //Year for which the number of employees is given
        I_Kna1.Jmzah = "000000"; //Yearly number of employees
        //Attribute 1~10
        I_Kna1.Katr1 = dlKATR1.SelectedValue;         I_Kna1.Katr2 = string.Empty;        I_Kna1.Katr3 = string.Empty;        I_Kna1.Katr4 = string.Empty;
        I_Kna1.Katr5 = string.Empty;        I_Kna1.Katr6 = string.Empty;        I_Kna1.Katr7 = string.Empty;        I_Kna1.Katr8 = string.Empty;
        I_Kna1.Katr9 = dlKATR9.SelectedValue;        I_Kna1.Katr10 = string.Empty;       
        I_Kna1.Kdkg1 = dlCondGrp1.SelectedValue; I_Kna1.Kdkg2 = dlCondGrp2.SelectedValue; I_Kna1.Kdkg3 = dlCondGrp3.SelectedValue; I_Kna1.Kdkg4 = dlCondGrp4.SelectedValue;
        I_Kna1.Kdkg5 = "R4";
        I_Kna1.Knazk = " ";        I_Kna1.Knrza = " ";
        I_Kna1.Knurl = ""; //Uniform Resource Locator
        I_Kna1.Konzs = " ";
        I_Kna1.Ktocd = " "; //Reference Account Group for One-Time Account (Customer)
        I_Kna1.Ktokd = dlAccountGrp.SelectedValue; //Z001 is sold-to, Z002 ship-to, Z003 bill-to
        I_Kna1.Kukla = dlCustClass.SelectedValue; //Customer classification, 01 AXSC, 02 RBU, 03 External Customer, 04 Joint Venture
        if (dlAccountGrp.SelectedValue == "Z001")
            I_Kna1.Kunnr = SoldToId;
        else I_Kna1.Kunnr = ShipBillToId; 

        I_Kna1.Land1 = dlCountryCode.SelectedValue; //Country Code
        I_Kna1.Lifnr = " "; //Account Number of Vendor or Creditor
        I_Kna1.Lifsd = " ";  //Central delivery block for the customer
        I_Kna1.Locco = " ";
        I_Kna1.Loevm = " ";
        I_Kna1.Lzone = dlTransZone.SelectedValue; //Transport zone, 0000000001 is US
        I_Kna1.Mandt = "168";
        //Mcod1-3 are Search term for matchcode search
        I_Kna1.Mcod1 = txtCompanyName.Text;
        I_Kna1.Mcod2 = "";
        I_Kna1.Mcod3 = string.Format("{0}|{1}|{2}",txtAddr1.Text,txtAddr2.Text, txtAddr3.Text).ToUpper(); //(ShiptoAddr1 + "|" + ShiptoAddr2 + "|" + ShiptoAddr3).Trim().ToUpper();
        I_Kna1.Milve = " ";
        I_Kna1.Name1 = I_Bapiaddr1.Name;        I_Kna1.Name2 = I_Bapiaddr1.Name_2;
        //if (txtCompanyName.Text.Length >= 35) {
        //    I_Kna1.Name1 = txtCompanyName.Text.Substring(0, 35); I_Kna1.Name2 = txtCompanyName.Text.Substring(35);
        //}
        I_Kna1.Name3 = "";        I_Kna1.Name4 = "";        I_Kna1.Niels = " ";        I_Kna1.Nodel = " ";
        I_Kna1.Ort01 = txtCity.Text; //City
        I_Kna1.Ort02 = " ";        I_Kna1.Periv = " ";        I_Kna1.Pfach = " ";        I_Kna1.Pfort = " ";        I_Kna1.Pmt_Office = " ";
        I_Kna1.Psofg = " ";        I_Kna1.Psohs = " ";        I_Kna1.Psois = " ";        I_Kna1.Pson1 = " ";        I_Kna1.Pson2 = " ";
        I_Kna1.Pson3 = " ";        I_Kna1.Psoo1 = " ";        I_Kna1.Psoo2 = " ";        I_Kna1.Psoo3 = " ";        I_Kna1.Psoo4 = " ";
        I_Kna1.Psoo5 = " ";        I_Kna1.Psost = " ";        I_Kna1.Psotl = " ";        I_Kna1.Psovn = " ";        I_Kna1.Pstl2 = " ";        I_Kna1.Pstlz = " ";
        //   I_Kna1.Regio = currKNA1.Regio;
        I_Kna1.Rpmkr = " ";
        I_Kna1.Sortl = txtVATNo.Text;
        I_Kna1.Sperr = " ";        I_Kna1.Sperz = " ";        I_Kna1.Spras = "E"; //language key
        I_Kna1.Stcd1 = txtTaxNum1.Text;        I_Kna1.Stcd2 = " ";        I_Kna1.Stcd3 = " ";        I_Kna1.Stcd4 = " ";        I_Kna1.Stcd5 = " ";        I_Kna1.Stcdt = " ";
        I_Kna1.Stceg = txtVATNo.Text;
        I_Kna1.Stkza = " ";        I_Kna1.Stkzn = " ";        I_Kna1.Stkzu = " ";
        I_Kna1.Stras = ""; //(Addr1 + "|" + Addr2 + "|" + Addr3).Trim().ToUpper();
        I_Kna1.Telbx = " ";
        I_Kna1.Telf1 = txtTelephone.Text;
        I_Kna1.Telf2 = " ";        I_Kna1.Telfx = " ";        I_Kna1.Teltx = " ";        I_Kna1.Telx1 = " ";
        I_Kna1.Txjcd = " ";        I_Kna1.Txlw1 = " ";        I_Kna1.Txlw2 = " ";
        I_Kna1.Umjah = "0000";         I_Kna1.Umsa1 = 0;         I_Kna1.Umsat = 0;         I_Kna1.Updat = "00000000";         I_Kna1.Uptim = "000000";
        I_Kna1.Uwaer = " ";         I_Kna1.Vbund = " ";//Company ID of Trading Partner
        
        I_Kna1.Werks = " ";         I_Kna1.Xcpdk = string.Empty;        I_Kna1.Xicms = string.Empty;        I_Kna1.Xknza = string.Empty;        I_Kna1.Xsubt = string.Empty;
        I_Kna1.Xxipi = string.Empty;        I_Kna1.Xzemp = string.Empty;
        //SA_KNB1 currKNB1 = A2C.SA_KNB1.FirstOrDefault();
        //    I_Knb1.Ad_Hash = currKNB1.Ad_Hash;
        I_Knb1.Akont = "0000121001";  // Reconciliation Account in General Ledger
        //20180425 TC: Per Carolh.Huang's instruction set recon. account based on selected account assign group
        switch (dlAccAssignGrp.SelectedValue) {
            case "01":
                I_Knb1.Akont = "0000121001"; break;
            case "02":
                I_Knb1.Akont = "0000121002"; break;
            case "03":
                I_Knb1.Akont = "0000123100"; break;
        }
        I_Knb1.Altkn = " ";
        //  I_Knb1.Avsnd = currKNB1.Avsnd;
        I_Knb1.Begru = " ";
        I_Knb1.Blnkz = " ";
        I_Knb1.Bukrs = dlOrgID.SelectedValue;
        I_Knb1.Busab = "01";// Accounting clerk
        I_Knb1.Cession_Kz = " ";//Accounts Receivable Pledging Indicator
        I_Knb1.Confs = " ";
        I_Knb1.Datlz = "00000000"; //Date of the last interest calculation run
        I_Knb1.Eikto = " ";
        I_Knb1.Ekvbd = " ";
        I_Knb1.Erdat = DateTime.Today.ToString("yyyyMMdd");
        I_Knb1.Ernam = "B2BAEU";
        I_Knb1.Fdgrv = "A1";//Planning group
        I_Knb1.Frgrp = " ";        I_Knb1.Gmvkzd = " ";        I_Knb1.Gricd = " ";        I_Knb1.Gridt = " ";        I_Knb1.Guzte = " ";
        I_Knb1.Hbkid = " ";        I_Knb1.Intad = " ";        I_Knb1.Knrzb = " ";        I_Knb1.Knrze = " ";
        I_Knb1.Kultg = 0;

        if (dlAccountGrp.SelectedValue == "Z001")
            I_Knb1.Kunnr = SoldToId;
        else I_Knb1.Kunnr = ShipBillToId;
        
        I_Knb1.Kverm = " ";        I_Knb1.Lockb = " ";        I_Knb1.Loevm = " ";        I_Knb1.Mandt = " ";
        I_Knb1.Mgrup = "01";
        I_Knb1.Nodel = " ";        I_Knb1.Perkz = " ";        I_Knb1.Pernr = " ";        //  I_Knb1.Qland = currKNB1.Qland;
        I_Knb1.Remit = " ";        I_Knb1.Sperr = " ";        I_Knb1.Sregl = " ";        I_Knb1.Tlfns = " ";        I_Knb1.Tlfxs = " ";
        I_Knb1.Togru = " ";        I_Knb1.Updat = "00000000";        I_Knb1.Uptim = "000000";        I_Knb1.Urlid = " ";
        I_Knb1.Uzawe = " ";        I_Knb1.Verdt = "00000000";        I_Knb1.Vlibb = 0;        I_Knb1.Vrbkz = " ";        I_Knb1.Vrsdg = " ";
        I_Knb1.Vrsnr = " ";

        //Update Credit Amount if specified
        //decimal outCA = 0;
        //if (!string.IsNullOrEmpty(txtCreditUSDAmt.Text) && decimal.TryParse(txtCreditUSDAmt.Text, out outCA))
        //    I_Knb1.Vrsnr = (outCA * 30).ToString();
        
        I_Knb1.Vrspr = 0;        I_Knb1.Vrszl = 0;        I_Knb1.Vzskz = " ";        I_Knb1.Wakon = " ";
        I_Knb1.Wbrsl = " ";        I_Knb1.Webtr = 0;        I_Knb1.Xausz = " ";        I_Knb1.Xdezv = " ";        I_Knb1.Xedip = " ";
        I_Knb1.Xknzb = " ";        I_Knb1.Xpore = " ";        I_Knb1.Xverr = " ";        I_Knb1.Xzver = "X";        I_Knb1.Zahls = " ";
        I_Knb1.Zamib = " ";        I_Knb1.Zamim = " ";        I_Knb1.Zamio = " ";        I_Knb1.Zamir = " ";        I_Knb1.Zamiv = " ";
        I_Knb1.Zgrup = " ";        I_Knb1.Zindt = "00000000"; //Key date of the last interest calculation
        I_Knb1.Zinrt = "00";//Interest calculation frequency in months
        I_Knb1.Zsabe = " ";        I_Knb1.Zterm = dlPayTerms.SelectedValue;
        I_Knb1.Zuawa = "001";        I_Knb1.Zwels = " ";
        /////
        //SA_KNVV currKNVV = A2C.SA_KNVV.FirstOrDefault();
        I_Knvv.Agrel = " ";        I_Knvv.Antlf = 9;
        I_Knvv.Aufsd = " ";
        I_Knvv.Autlf = " ";
        I_Knvv.Awahr = "100";
        I_Knvv.Begru = " ";        I_Knvv.Bev1_Emlgforts = " ";        I_Knvv.Bev1_Emlgpfand = " ";        I_Knvv.Blind = " ";
        I_Knvv.Boidt = "00000000";        I_Knvv.Bokre = " ";        I_Knvv.Bzirk =dlDistrict.SelectedValue;
        //   I_Knvv.Carrier_Notif = currKNVV.Carrier_Notif;
        I_Knvv.Cassd = " ";        I_Knvv.Chspl = " ";        I_Knvv.Eikto = " ";        I_Knvv.Erdat = DateTime.Today.ToString("yyyyMMdd");
        I_Knvv.Ernam = "B2BAEU";
        I_Knvv.Faksd = " ";// currKNVV.Faksd;
        
        I_Knvv.Inco1 = dlIncoTerms.SelectedValue;        I_Knvv.Inco2 = txtIncotxt.Text;
        I_Knvv.Kabss = " ";
        I_Knvv.Kalks = "1"; //Pricing procedure assigned to this customer
        I_Knvv.Kdgrp = dlCustGrp.SelectedValue;//Customer group
        I_Knvv.Kkber = " ";        I_Knvv.Klabc = " ";        I_Knvv.Konda = dlPriceGrp.SelectedValue;
        I_Knvv.Ktgrd = dlAccAssignGrp.SelectedValue; //Account assignment group for this customer

        if (dlAccountGrp.SelectedValue == "Z001")
            I_Knvv.Kunnr = SoldToId;
        else
            I_Knvv.Kunnr = ShipBillToId;

        I_Knvv.Kurst = " ";        I_Knvv.Kvakz = " ";        I_Knvv.Kvawt = 0;
        //Customer group 1-5
        I_Knvv.Kvgr1 = " ";        I_Knvv.Kvgr2 = " ";        I_Knvv.Kvgr3 = "D0";        I_Knvv.Kvgr4 = " ";        I_Knvv.Kvgr5 = " ";
        I_Knvv.Kzazu = "X";        I_Knvv.Kztlf = " ";        I_Knvv.Lifsd = " ";        I_Knvv.Loevm = " ";        I_Knvv.Lprio = " ";
        I_Knvv.Mandt = "168";        I_Knvv.Megru = " ";        I_Knvv.Mrnkz = " ";        I_Knvv.Perfk = " ";        I_Knvv.Perrl = " ";
        
        
        I_Knvv.Podkz = " ";        I_Knvv.Podtg = 0;        I_Knvv.Prat1 = " ";        I_Knvv.Prat2 = " ";
        I_Knvv.Prat3 = " ";        I_Knvv.Prat4 = " ";        I_Knvv.Prat5 = " ";        I_Knvv.Prat6 = " ";        I_Knvv.Prat7 = " ";
        I_Knvv.Prat8 = " ";        I_Knvv.Prat9 = " ";        I_Knvv.Prata = " ";        I_Knvv.Prfre = " ";        I_Knvv.Pvksm = " ";
        I_Knvv.Rdoff = " ";        I_Knvv.Spart = DivisionSpart;        I_Knvv.Uebtk = " ";        I_Knvv.Uebto = 0;        I_Knvv.Untto = 0;
        I_Knvv.Versg = " ";
        I_Knvv.Vkbur = dlSalesOffice.SelectedValue; I_Knvv.Vkgrp = dlSalesGroup.SelectedValue;
        I_Knvv.Vkorg = dlOrgID.SelectedValue;  I_Knvv.Vsbed = dlShipConds.SelectedValue;//Shipping Conditions
        I_Knvv.Vsort = " ";        I_Knvv.Vtweg = "00"; I_Knvv.Vwerk = "";//Delivery Plant
        I_Knvv.Waers = dlCurrency.SelectedValue;        I_Knvv.Zterm = dlPayTerms.SelectedValue;
        I_Knvv.Pltyp = "00";
        //[Sylvia] Customer Price List (KNVV-PLTYP) 請不要讓 使用者可以修改  請直接給固定的值 ‘01’ 
        if (I_Knvv.Vkorg == "US10") I_Knvv.Pltyp = "01";

        I_Maintain_Address_By_Kna1 = ""; I_No_Bank_Master_Update = ""; I_Raise_No_Bte = "";
        Pi_Cam_Changed = ""; Pi_Postflag = "";

        //Only sold-to Z001 can be specified sales/OP/IS
        if (I_Kna1.Ktokd == "Z001")
        {
            if (string.IsNullOrEmpty(SalesCode) || SalesCode != "00000000")
            {
                var VE = new SAPCustomerRFC.FKNVP();
                VE.Mandt = "168"; VE.Kunnr = SoldToId; VE.Vkorg = dlOrgID.SelectedValue; VE.Vtweg = "00"; VE.Spart = DivisionSpart;
                VE.Parvw = "VE"; VE.Parza = "000"; VE.Kunn2 = ""; VE.Lifnr = ""; VE.Knref = ""; VE.Defpa = "";
                VE.Pernr = SalesCode; VE.Parnr = "0000000000"; T_Xknvp.Add(VE);
            }

            if (string.IsNullOrEmpty(ISCode) || ISCode != "00000000")
            {
                var VE = new SAPCustomerRFC.FKNVP();
                VE.Mandt = "168"; VE.Kunnr = SoldToId; VE.Vkorg = dlOrgID.SelectedValue; VE.Vtweg = "00"; VE.Spart = DivisionSpart;
                VE.Parvw = "Z2"; VE.Parza = "000"; VE.Kunn2 = ""; VE.Lifnr = ""; VE.Knref = ""; VE.Defpa = "";
                VE.Pernr = ISCode; VE.Parnr = "0000000000"; T_Xknvp.Add(VE);
            }

            if (string.IsNullOrEmpty(OPCode) || OPCode != "00000000")
            {
                var ER = new SAPCustomerRFC.FKNVP();
                ER.Mandt = "168"; ER.Kunnr = SoldToId; ER.Vkorg = dlOrgID.SelectedValue; ER.Vtweg = "00"; ER.Spart = DivisionSpart;
                ER.Parvw = "ZM"; ER.Parza = "000"; ER.Kunn2 = ""; ER.Lifnr = ""; ER.Pernr = OPCode; //OP sales code
                ER.Parnr = "00000000"; ER.Knref = ""; ER.Defpa = ""; T_Xknvp.Add(ER);
            }
            if (!string.IsNullOrEmpty(txtSONotifyCode.Text)) {
                var ZV = new SAPCustomerRFC.FKNVP() {
                    Mandt = "168", Kunnr = SoldToId, Vkorg = dlOrgID.SelectedValue, Vtweg = "00", Spart = DivisionSpart,
                    Parvw = "ZV", Parza = "000", Kunn2 = "", Lifnr = "", Knref = "", Defpa = "",
                    Pernr = txtSONotifyCode.Text, Parnr = "0000000000"
                };
                T_Xknvp.Add(ZV);
            }
        }

        //Use t-code OVK1 to find tax definition, and table TVKWZ and T001W
        T_Xknvi.Add(new SAPCustomerRFC.FKNVI() { Mandt = "168", Aland = "TW", Kunnr = SoldToId, Tatyp = "MWST", Taxkd = dlMWSTTaxCode.SelectedValue });
        T_Xknvi.Add(new SAPCustomerRFC.FKNVI() { Mandt = "168", Aland = "US", Kunnr = SoldToId, Tatyp = "UTXJ", Taxkd = dlUTXJTaxCode.SelectedValue });
        if (senderButton.ID == "btnCreateSAPAccount")
        {
            p1.Connection.Open();
            p1.Zsd_Customer_Maintain_All(I_Bapiaddr1, I_Bapiaddr2, I_Customer_Is_Consumer,
                                    I_Force_External_Number_Range, "",
                                    I_Kna1, I_Knb1, I_Knb1_Reference, I_Knvv, I_Maintain_Address_By_Kna1,
                                    I_No_Bank_Master_Update, I_Raise_No_Bte,
                                    Pi_Add_On_Data, Pi_Cam_Changed, Pi_Postflag,
                                out E_Kunnr, out E_Sd_Cust_1321_Done, out O_Kna1, ref T_Upd_Txt,
                                 ref T_Xkn, ref T_Xknb5, ref T_Xknbk, ref T_Xknex, ref T_Xknva, ref T_Xknvd, ref T_Xknvi,
                                   ref T_Xknvk, ref T_Xknvl, ref T_Xknvp, ref T_Xknza, ref T_Ykn, ref T_Yknb5, ref T_Yknbk, ref T_Yknex, ref T_Yknva,
                                   ref T_Yknvd, ref T_Yknvi, ref T_Yknvk, ref T_Yknvl, ref T_Yknvp, ref T_Yknza);
            p1.CommitWork();
            p1.Connection.Close();
            System.Threading.Thread.Sleep(3000);
            if (I_Kna1.Ktokd == "Z002" || I_Kna1.Ktokd == "Z003")
            {
                LinkBillShipToWithSoldTo(LinkToSoldToId, ShipBillToId, ShipBillParvw, ShipBillParza, I_Knvv.Vkorg, I_Knvv.Spart);
            }

            if (I_Kna1.Ktokd == "Z001")
            {
                var chkKNA1Dt = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select kunnr from saprdp.kna1 where kunnr='" + SoldToId + "'");
                if (chkKNA1Dt.Rows.Count > 0)
                {
                    lbMsg.Text = string.Format("Customer Id:{0} has been created in SAP", SoldToId);
                    //update credit limit, credit control area doesn't equal to sales org, and record in knkk hasn't be created yet
                    decimal inputCreditLimit = 0; string errUpdateCreditLimit = string.Empty;
                    if (!string.IsNullOrEmpty(txtCreditUSDAmt.Text) && decimal.TryParse(txtCreditUSDAmt.Text, out inputCreditLimit) && cbCreditLimit.Checked)
                    {
                        var updateCreditErr = string.Empty;
                        bool IsCreditLimitSet = MYSAPDAL.UpdateCustomerCreditLimitV2(SoldToId, SalesOrgToCreditControlArea(dlOrgID.SelectedValue), inputCreditLimit,
                            dlCreditAmtRiskCat.SelectedValue, dlCredRepGrp.SelectedValue, dlCreditAmtCurr.SelectedValue, ref updateCreditErr, !istesting);
                        if (IsCreditLimitSet && string.IsNullOrEmpty(updateCreditErr))
                            lbMsg.Text += ". Credit Limit is updated.";
                        else
                            lbMsg.Text += ". Credit Limit updated failed due to " + updateCreditErr;
                    }

                    var CompanyIDList = new System.Collections.ArrayList(); var SyncCustErr = string.Empty; CompanyIDList.Add(SoldToId);
                    SAPDAL.syncSingleCompany.syncSingleSAPCustomer(CompanyIDList, istesting, ref SyncCustErr);

                    if (!string.IsNullOrEmpty(hdSiebelAccountRowId.Value)) {
                        Advantech.Myadvantech.DataAccess.SiebelDAL.UpdateAccountErpID(hdSiebelAccountRowId.Value, txtCompanyId.Text);
                    }
                    else {
                        Advantech.Myadvantech.DataAccess.SiebelDAL.CreateAccountBySAPSoldToId(SoldToId);
                    }
                }
            }
            else
            {
                var chkKNA1Dt = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select kunnr from saprdp.kna1 where kunnr='" + ShipBillToId + "'");
                if (chkKNA1Dt.Rows.Count > 0)
                {
                    lbMsg.Text = string.Format("Ship/Bill-to Id:{0} has been created and linked to {1} in SAP", ShipBillToId, LinkToSoldToId);
                    var CompanyIDList = new System.Collections.ArrayList(); var SyncCustErr = string.Empty; CompanyIDList.Add(LinkToSoldToId);
                    SAPDAL.syncSingleCompany.syncSingleSAPCustomer(CompanyIDList, istesting, ref SyncCustErr);
                }
            }
            //ScriptManager.RegisterStartupScript(this.upMsg, this.upMsg.GetType(), "UploadFile2SAP", "UploadFile2SAPAccount();", true);
        }
        else {
            var NewSAPAccountRequest1 = new NewSAPAccountUtil.NewSAPAccountRequest()
            {
                ApplicationId = this.ApplicationId.Value,
                CreatedBy = User.Identity.Name,                
                AccountGroup = dlAccountGrp.SelectedItem.Text,
                SalesOrg = dlOrgID.SelectedValue, SalesOffice = dlSalesOffice.SelectedItem.Text, SalesGroup = dlSalesGroup.SelectedItem.Text,
                VECode = txtSalesCode.Text, Z2Code = txtInsideSalesCode.Text, ZVCode = txtSONotifyCode.Text,
                ERCode = txtOPCode.Text, KUNNR = txtCompanyId.Text, Link2SoldToId = txtLinkToCompanyId.Text,
                CompanyName = txtCompanyName.Text, SiebelAccountId = hdSiebelAccountRowId.Value, Comment = txtAddrNotes.Text,
                SearchTerm1 = txtSearchTerm1.Text, SearchTerm2 = txtSearchTerm2.Text, Address1 = txtAddr1.Text,
                Address2 = txtAddr2.Text, Address3 = txtAddr3.Text, Country = dlCountryCode.SelectedItem.Text,
                City = txtCity.Text, PostCode = txtPostCode.Text, Region = dlRegion.SelectedItem.Text,
                District = dlDistrict.SelectedItem.Text, Telephone = txtTelephone.Text, TelExt = txtTelExt.Text,
                FaxNo = txtFAX.Text,
                ContactFName = txtContactPersonFName.Text,
                ContactLName = txtContactPersonLName.Text,
                ContactEmail = txtContactPersonEmail.Text,
                OfficeRegNo = txtTaxNum1.Text,
                DUNSNo = txtDUNSNo.Text,
                DBPayIdx = txtDBPayIdx.Text,
                VATNo = txtVATNo.Text,
                WebsiteURL = txtWebSiteURL.Text,
                ShipCond = dlShipConds.SelectedItem.Text, PayTerm = dlPayTerms.SelectedItem.Text,
                IsSpecCreditLimit = cbCreditLimit.Checked, CreditLimitCurr=dlCreditAmtCurr.SelectedItem.Text,
                //CreditLimitAmt=decimal.Parse(txtCreditUSDAmt.Text),
                CreditLimitRiskCat =dlCreditAmtRiskCat.SelectedItem.Text,
                CreditLimitRepGrp=dlCredRepGrp.SelectedItem.Text, IncoTerm=dlIncoTerms.SelectedItem.Text,
                IncoText = txtIncotxt.Text,
                Industry = dlIndustry.SelectedItem.Text,
                IndustryCode1 = dlMktIndustryCode1.SelectedItem.Text,
                IndustryCode2 = dlMktIndustryCode2.SelectedItem.Text,
                CustGroup = dlCustGrp.SelectedItem.Text,
                MWST_TaxCode = dlMWSTTaxCode.SelectedItem.Text,
                UTXJ_TaxCode = dlUTXJTaxCode.SelectedItem.Text,
                AccountAssignGroup = dlAccAssignGrp.SelectedItem.Text,
                CustClass = dlCustClass.SelectedItem.Text,
                PriceGrade1 = dlCondGrp1.SelectedValue,
                PriceGrade2 = dlCondGrp2.SelectedValue,
                PriceGrade3 = dlCondGrp3.SelectedValue,
                PriceGrade4 = dlCondGrp4.SelectedValue,
                PriceGroup = dlPriceGrp.SelectedItem.Text,
                Currency = dlCurrency.SelectedItem.Text,
                AdditionalCustAttr1 = dlKATR1.SelectedItem.Text,
                AdditionalCustAttr9 = dlKATR9.SelectedItem.Text
            };
            decimal tmpCreditAmount = 0m;
            if (NewSAPAccountRequest1.IsSpecCreditLimit && decimal.TryParse(txtCreditUSDAmt.Text, out tmpCreditAmount)) {
                NewSAPAccountRequest1.CreditLimitAmt = tmpCreditAmount;
            }


            var dtApplicantManager = dbUtil.dbGetDataTable("MY",
               " select b.EMAIL_ADDR as ManagerEmail from EZ_EMPLOYEE a inner join EZ_EMPLOYEE b " +
               " on a.MANAGER=b.EZROWID where a.EMAIL_ADDR='" + HttpContext.Current.User.Identity.Name + "'");
            if (dtApplicantManager.Rows.Count > 0)
            {
                NewSAPAccountRequest1.ApprovalManager = dtApplicantManager.Rows[0]["ManagerEmail"].ToString();
            }
            else
            {
                lbMsg.Text = string.Format("Cannot get manager from EZ"); return;
            }

            var jsr = new System.Web.Script.Serialization.JavaScriptSerializer();
            var MyEC2Conn = new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["MY_EC2"].ConnectionString);
            MyEC2Conn.Open();
            if (senderButton.ID == "btnSaveAsApplication")
            {
                var cmdNewTicketId = new System.Data.SqlClient.SqlCommand("select max(TicketId) from NEW_SAP_ACCOUNT_APPLICATIONS_HQ", MyEC2Conn);
                var TopTicketId = cmdNewTicketId.ExecuteScalar();
                var NewTicketId = string.Empty;
                if (TopTicketId.ToString() == string.Empty) NewTicketId = "NC000001";
                else
                {
                    var topNum = int.Parse(TopTicketId.ToString().Substring(2));
                    topNum++;
                    var AppendZeros = 6 - topNum.ToString().Length;
                    NewTicketId = "NC";
                    for (int ZeroCount = 0; ZeroCount < AppendZeros; ZeroCount++)
                        NewTicketId = NewTicketId + "0";
                    NewTicketId = NewTicketId + topNum.ToString();
                }
                NewSAPAccountRequest1.TicketId = NewTicketId;
                
                var NewAccountJsonData = jsr.Serialize(NewSAPAccountRequest1);
                var cmdInsertRequest = new System.Data.SqlClient.SqlCommand(
                    @"INSERT INTO [dbo].[NEW_SAP_ACCOUNT_APPLICATIONS_HQ]
                ([ApplicationId],[TicketId],[CreatedBy],[AppliedDate],[ApprovalManager],[AccountJsonData])
                VALUES(@APPID,@TICKETID,@UID,getdate(),@MGR,@ACCJSON)", MyEC2Conn);
                cmdInsertRequest.Parameters.AddWithValue("@APPID", NewSAPAccountRequest1.ApplicationId);
                cmdInsertRequest.Parameters.AddWithValue("@TICKETID", NewSAPAccountRequest1.TicketId);
                cmdInsertRequest.Parameters.AddWithValue("@UID", NewSAPAccountRequest1.CreatedBy);
                cmdInsertRequest.Parameters.AddWithValue("@MGR", NewSAPAccountRequest1.ApprovalManager);
                cmdInsertRequest.Parameters.AddWithValue("@ACCJSON", NewAccountJsonData);
                cmdInsertRequest.ExecuteNonQuery();
                
                NewSAPAccountUtil.SendApprovalEmail(ApplicationId.Value, NewSAPAccountUtil.ApprovalTransition.InitRequest,
                    Util.GetRuntimeSiteUrl());

                lbMsg.Text = string.Format("Your request is submitted and sent to {0} for approval.", NewSAPAccountRequest1.ApprovalManager);
            }
            else {
                if (senderButton.ID == "btnApproval") {
                    var OriginalReq = NewSAPAccountUtil.getReqDetail(Request["AppId"].ToString());
                    NewSAPAccountRequest1.ApplicationId = OriginalReq.ApplicationId;
                    NewSAPAccountRequest1.TicketId = OriginalReq.TicketId;
                    NewSAPAccountRequest1.CreatedBy = OriginalReq.CreatedBy;
                    NewSAPAccountRequest1.AppliedDate = OriginalReq.AppliedDate;
                    NewSAPAccountRequest1.ApprovalManager = OriginalReq.ApprovalManager;
                    NewSAPAccountRequest1.ManagerComment = OriginalReq.ManagerComment;
                    NewSAPAccountRequest1.ManagerApprovalStatus = OriginalReq.ManagerApprovalStatus;
                    NewSAPAccountRequest1.ApprovalOP = OriginalReq.ApprovalOP;
                    NewSAPAccountRequest1.OPComment = NewSAPAccountRequest1.OPComment;
                    NewSAPAccountRequest1.OPApprovalStatus = OriginalReq.OPApprovalStatus;
                    NewSAPAccountRequest1.OPApprovalTime = OriginalReq.OPApprovalTime;
                    var NewAccountJsonData = jsr.Serialize(NewSAPAccountRequest1);
                    var cmdUpdateApplication = new System.Data.SqlClient.SqlCommand(
                        "update [dbo].[NEW_SAP_ACCOUNT_APPLICATIONS_HQ] set AccountJsonData=@ACCJSON where ApplicationId=@APPID", MyEC2Conn);
                    cmdUpdateApplication.Parameters.AddWithValue("@APPID", Request["AppId"].ToString());                   
                    cmdUpdateApplication.Parameters.AddWithValue("@ACCJSON", NewAccountJsonData);
                    cmdUpdateApplication.ExecuteNonQuery();
                }
            }
            MyEC2Conn.Close();

        }
        btnReset.Visible = true; btnCreateSAPAccount.Enabled = false; btnSaveAsApplication.Enabled = false;
    }

    //Object for storing create account request   
    

    protected void txtCompanyId_TextChanged(object sender, EventArgs e)
    {
        //RegTokenInput();
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
        lbDubCompanyIdMsg.Text = "";
        string Erpid = txtCompanyId.Text.Trim().ToUpper(); txtCompanyId.Text = Erpid;
        if (string.IsNullOrEmpty(Erpid) || Erpid.Length <= 5) return;
        if (Erpid.Length >= 10) { lbDubCompanyIdMsg.Text = "company id cannot be more than 9 digits."; return; }      
        //string SAPconnection = "SAP_PRD"; if (istesting) SAPconnection = "SAP_Test";
        DataTable dt = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, "select Name1 from  saprdp.kna1  where Kunnr ='" + Erpid.ToUpper() + "'");
        if (dt.Rows.Count > 0) lbDubCompanyIdMsg.Text = string.Format("{0} already exists", Erpid);
        else { lbDubCompanyIdMsg.Text = string.Format("{0} not yet exists", Erpid); }

    }

    [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod()]
    public static bool UploadFileToSAPAccount(string FileName, string FileURL, string SoldToId) {
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
        var RFCClient1 = new ZSGOS_URL.ZSGOS_URL();
        var ObjectKeyType = new ZSGOS_URL.BORIDENT() { Objkey = SoldToId, Objtype = "KNA1" };
        var SOODK1 = new ZSGOS_URL.SOODK(); var EP_URL = "";
        RFCClient1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[GlobSAPRFCconnection]);
        RFCClient1.Connection.Open();
        RFCClient1.Zsgos_Url_Create_Internal(FileName, ObjectKeyType, FileURL, out SOODK1, out EP_URL);
        RFCClient1.Connection.Close();
        return true;
    }

    [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod(ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public static SiebelAccount[] GetSiebelAccount(string AccountName, string SAPOrg) {
        var RBU = "";
        if (SAPOrg == "US10") RBU = "ABB";
        if (SAPOrg == "EU10") RBU = "ADL,AFR,AIT,AEE,AUK,ABN,AIR,ABB";
        if (SAPOrg == "TW01") RBU = "";
        var AccountList = new List<SiebelAccount>();
        var SqlQuerySiebel = CreateSAPCustomerDAL.GET_Siebel_Account_List(AccountName, RBU, "", "", "", "", "", "", "", "", "");
        var dtSiebelAccount = dbUtil.dbGetDataTable("CRMDB75", SqlQuerySiebel);
        foreach (DataRow drAccount in dtSiebelAccount.Rows) {
            var SiebelAccount1 = new SiebelAccount() {
                account_name = drAccount["COMPANYNAME"].ToString(), account_status = drAccount["STATUS"].ToString(),
                addr=drAccount["ADDRESS"].ToString(), country = drAccount["COUNTRY"].ToString(), postcode= drAccount["ZIPCODE"].ToString(),
                primary_sales = drAccount["PRIMARY_SALES_EMAIL"].ToString(), RBU = drAccount["RBU"].ToString(), city= drAccount["CITY"].ToString(),
                row_id = drAccount["ROW_ID"].ToString() };
            AccountList.Add(SiebelAccount1);
        }
        return AccountList.ToArray();
    }

    public class SiebelAccount
    {
        public string row_id { get; set; }         public string account_name { get; set; }
        public string RBU { get; set; }         public string account_status { get; set; }
        public string primary_sales { get; set; }         public string country { get; set; }
        public string postcode { get; set;} public string city { get; set; }
        public string addr { get; set; }
    }

    [System.Web.Services.WebMethod]
    [System.Web.Script.Services.ScriptMethod(ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
    public static SAPCompany[] GetSAPCompanyById(string erpid, string cname)
    {
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
        List<SAPCompany> idlist = new List<SAPCompany>();
        if (!string.IsNullOrEmpty(erpid)) {
            
            erpid = erpid.Trim().ToUpper();
            DataTable dt = OraDbUtil.dbGetDataTable(GlobSAPDbconnection, 
                string.Format(@"select distinct a.kunnr, b.vkorg, a.name1 from saprdp.kna1 a inner join saprdp.knvv b on a.kunnr=b.kunnr 
                where a.mandt='168' and b.mandt='168' and rownum<=20 and a.ktokd='Z001' and a.kunnr like '{0}%' order by a.kunnr", erpid));
            foreach (DataRow custDr in dt.Rows) {
                idlist.Add(new SAPCompany { company_id = custDr["kunnr"].ToString(), org_id = custDr["vkorg"].ToString(), company_name=custDr["name1"].ToString() });
            }
        }
        if (!string.IsNullOrEmpty(cname) && cname.Length >= 2)
        {           
            DataTable dt = OraDbUtil.dbGetDataTable(GlobSAPDbconnection,
                string.Format(@"select distinct a.kunnr as company_id, b.vkorg as org_id, a.name1 || '' || a.name2 as company_name 
                from saprdp.kna1 a inner join saprdp.knvv b on a.kunnr=b.kunnr 
                where a.mandt='168' and b.mandt='168' and rownum<=5 and a.ktokd='Z001' and 
                (a.name1 like '%{0}%' or a.name2 like '%{0}%' or a.sortl like '%{0}%') order by a.kunnr", cname.Trim().ToUpper()));
            //dt.Merge(dt2);
            foreach (DataRow custDr in dt.Rows)
            {
                var ext = from q in idlist where q.company_id == custDr["COMPANY_ID"].ToString() select q;
                if(ext.Count()==0) idlist.Add(new SAPCompany { company_id = custDr["COMPANY_ID"].ToString(), org_id = custDr["ORG_ID"].ToString(), company_name = custDr["COMPANY_NAME"].ToString() });
            }
        }
        return idlist.ToArray();
    }

    public class SAPCompany {
        public string company_id { get; set; } public string org_id { get; set; }        public string company_name { get; set; }
    }

    protected void cbCreditLimit_CheckedChanged(object sender, EventArgs e)
    {
        tbCreditLimit.Visible = cbCreditLimit.Checked;
    }

    protected void dlCountryCode_SelectedIndexChanged(object sender, EventArgs e)
    {
        string GlobSAPDbconnection = ""; string GlobSAPRFCconnection = ""; getSAPDbAndRFCConn(out GlobSAPDbconnection, out GlobSAPRFCconnection);
        dlTransZone.Items.Clear(); dlRegion.Items.Clear();
        if (dlCountryCode.SelectedIndex > 0) {
            var dtTranZones = OraDbUtil.dbGetDataTable(GlobSAPDbconnection,
            "select zone1, vtext from saprdp.tzont where mandt='168' and spras='E' and land1='" + dlCountryCode.SelectedValue + "' order by zone1");
            var dtRegions = OraDbUtil.dbGetDataTable(GlobSAPDbconnection,
                "select bland, bezei from saprdp.T005U where mandt='168' and spras='E' and land1='" + dlCountryCode.SelectedValue + "' order by bezei");
            foreach (DataRow tranzoneDR in dtTranZones.Rows)
            {
                dlTransZone.Items.Add(new ListItem(string.Format("{0} ({1})", tranzoneDR["vtext"].ToString(), tranzoneDR["zone1"].ToString()), tranzoneDR["zone1"].ToString()));
            }
            dlRegion.Items.Add(new ListItem("Select...", ""));
            foreach (DataRow regionDR in dtRegions.Rows)
            {
                dlRegion.Items.Add(new ListItem(string.Format("{0} ({1})", regionDR["bezei"].ToString(), regionDR["bland"].ToString()), regionDR["bland"].ToString()));
            }

            var TimezoneDt = OraDbUtil.dbGetDataTable(GlobSAPDbconnection,
                "select distinct tzone from saprdp.ttz5s where mandt='168' and land1='" + dlCountryCode.SelectedValue + "' order by tzone");
            dlTimeZone.Items.Clear();
            foreach (DataRow timezoneRow in TimezoneDt.Rows) {
                dlTimeZone.Items.Add(new ListItem(timezoneRow["tzone"].ToString(), timezoneRow["tzone"].ToString()));
            }
            if (dlTimeZone.Items.Count == 0) dlTimeZone.Items.Add(new ListItem("UTC+8", "UTC+8"));
        }        
    }

    protected void dlAccountGrp_SelectedIndexChanged(object sender, EventArgs e)
    {
        tbWholeForm.Visible = dlAccountGrp.SelectedIndex >= 0 ? true : false;
        btnCreateSAPAccount.Visible=dlAccountGrp.SelectedIndex >= 0 ? true : false;
        trKUNNR.Visible = dlAccountGrp.SelectedValue == "Z001" ? true : false;
        trLinkToKUNNR.Visible= dlAccountGrp.SelectedValue == "Z001" ? false : true;
        trCreditLimit.Visible= dlAccountGrp.SelectedValue == "Z001" ? true : false;
        dlOrgID_SelectedIndexChanged(null, null);
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        Response.Redirect(Request.RawUrl, false);
    }


    protected void btnSaveAsApplication_Click(object sender, EventArgs e)
    {
        btnCreateSAPAccount_Click(btnSaveAsApplication, null);
    }

    protected void btnShowUploadedFiles_Click(object sender, EventArgs e)
    {
        gvUploadedFiles.DataSource = null; gvUploadedFiles.DataBind();
        var dtUpFiles = dbUtil.dbGetDataTable("MY_EC2", 
            @"select FILE_NAME, FileId from NEW_SAP_ACCOUNT_HQ_FILES 
            where ApplicationId='"+ ApplicationId.Value + "' order by UPLOADED_DATE");
        gvUploadedFiles.DataSource = dtUpFiles; gvUploadedFiles.DataBind();
    }

    protected void lnkRowDelUpFile_Click(object sender, EventArgs e)
    {
        LinkButton lnkRowDelUpFile = (LinkButton)sender;
        string RowFileId = ((HiddenField)lnkRowDelUpFile.NamingContainer.FindControl("hdRowFileId")).Value;        
        dbUtil.dbExecuteNoQuery("MY_EC2", 
            @"delete from NEW_SAP_ACCOUNT_HQ_FILES 
                where ApplicationId='" + this.ApplicationId.Value + "' and FileId='"+ RowFileId + "'");
        btnShowUploadedFiles_Click(null, null);
    }

    protected void TimerLoadSalesIDs_Tick(object sender, EventArgs e)
    {
        TimerLoadSalesIDs.Enabled = false;
        if (Request["AppId"] != null) {
            var dtAppInfo = dbUtil.dbGetDataTable("MY_EC2",
                    @"SELECT AccountJsonData
                        FROM NEW_SAP_ACCOUNT_APPLICATIONS_HQ
                        where ApplicationId='" + Request["AppId"].ToString() + "'");
            if (dtAppInfo.Rows.Count == 1)
            {
                this.ApplicationId.Value = Request["AppId"].ToString();
                DataRow drAppInfo = dtAppInfo.Rows[0];
                string JsonAccountData = drAppInfo["AccountJsonData"].ToString();
                var jsr = new System.Web.Script.Serialization.JavaScriptSerializer();
                NewSAPAccountUtil.NewSAPAccountRequest req = 
                    jsr.Deserialize<NewSAPAccountUtil.NewSAPAccountRequest>(JsonAccountData);               
                var MyApt = new System.Data.SqlClient.SqlDataAdapter("", System.Configuration.ConfigurationManager.ConnectionStrings["MY"].ConnectionString);
                var dtSalesCode = new DataTable();
                if (req.VECode != "")
                {
                    MyApt.SelectCommand.CommandText = "select full_name, pers_area from sap_employee where sales_code='" + req.VECode + "'";
                    MyApt.Fill(dtSalesCode);
                    if (dtSalesCode.Rows.Count == 1)
                        ScriptManager.RegisterClientScriptBlock(this.upLoadSalesIDs, this.upLoadSalesIDs.GetType(), "AddSalesIDs",
                        "AddToken('" + req.VECode + "','" + string.Format("{0} ({1})", dtSalesCode.Rows[0]["full_name"].ToString(), dtSalesCode.Rows[0]["pers_area"].ToString()) + "','" + txtSalesCode.ClientID + "')", true);
                }
                if (req.Z2Code != "") {
                    dtSalesCode = new DataTable();
                    MyApt.SelectCommand.CommandText = "select full_name, pers_area from sap_employee where sales_code='" + req.Z2Code + "'";
                    MyApt.Fill(dtSalesCode);
                    if (dtSalesCode.Rows.Count == 1)
                        ScriptManager.RegisterClientScriptBlock(this.upLoadSalesIDs, this.upLoadSalesIDs.GetType(), "AddSalesIDs2",
                        "AddToken('" + req.Z2Code + "','" + string.Format("{0} ({1})", dtSalesCode.Rows[0]["full_name"].ToString(), dtSalesCode.Rows[0]["pers_area"].ToString()) + "','" + txtInsideSalesCode.ClientID + "')", true);

                }

                if (req.ZVCode != "") {
                    dtSalesCode = new DataTable();
                    MyApt.SelectCommand.CommandText = "select full_name, pers_area from sap_employee where sales_code='" + req.ZVCode + "'";
                    MyApt.Fill(dtSalesCode);
                    if (dtSalesCode.Rows.Count == 1)
                        ScriptManager.RegisterClientScriptBlock(this.upLoadSalesIDs, this.upLoadSalesIDs.GetType(), "AddSalesIDs3",
                        "AddToken('" + req.ZVCode + "','" + string.Format("{0} ({1})", dtSalesCode.Rows[0]["full_name"].ToString(), dtSalesCode.Rows[0]["pers_area"].ToString()) + "','" + txtSONotifyCode.ClientID + "')", true);
                }

                if (req.ERCode != "") {
                    dtSalesCode = new DataTable();
                    MyApt.SelectCommand.CommandText = "select full_name, pers_area from sap_employee where sales_code='" + req.ERCode + "'";
                    MyApt.Fill(dtSalesCode);
                    if (dtSalesCode.Rows.Count == 1)
                        ScriptManager.RegisterClientScriptBlock(this.upLoadSalesIDs, this.upLoadSalesIDs.GetType(), "AddSalesIDs4",
                        "AddToken('" + req.ERCode + "','" + string.Format("{0} ({1})", dtSalesCode.Rows[0]["full_name"].ToString(), dtSalesCode.Rows[0]["pers_area"].ToString()) + "','" + txtOPCode.ClientID + "')", true);
                }                
                MyApt.SelectCommand.Connection.Close();

            }
        }        
    }

    protected void btnApproval_Click(object sender, EventArgs e)
    {
        if (rblApprovalStatus.SelectedIndex >= 0) {
            bool IsCreateAccount = false;
            var AppTranState = NewSAPAccountUtil.ApprovalTransition.InitRequest;
            var sqlUpdateReq = "update NEW_SAP_ACCOUNT_APPLICATIONS_HQ ";
            if (NewSAPAccountUtil.getCurrentUserRole() == NewSAPAccountUtil.UserRole.OPLeader)
            {
                if (rblApprovalStatus.SelectedItem.Text == "Approve")
                {
                    sqlUpdateReq += string.Format(" set OPApprovalStatus={0}, OPApprovalTime=getdate(), OPComment=@COMMENT, ApprovalOP='{1}'", (int)NewSAPAccountUtil.NewAccountApprovalStatus.Approved,User.Identity.Name);                    
                    IsCreateAccount = true;                    
                    AppTranState = NewSAPAccountUtil.ApprovalTransition.OPApprove;
                }
                else {
                    sqlUpdateReq += string.Format(" set OPApprovalStatus={0}, OPApprovalTime=getdate(), OPComment=@COMMENT, ApprovalOP='{1}'", (int)NewSAPAccountUtil.NewAccountApprovalStatus.Rejected,User.Identity.Name);
                    AppTranState = NewSAPAccountUtil.ApprovalTransition.OPReject;
                }
            }
            else {
                if (rblApprovalStatus.SelectedItem.Text == "Approve")
                {
                    sqlUpdateReq += string.Format(" set ManagerApprovalStatus={0}, ManagerApprovalTime=getdate(), ManagerComment=@COMMENT", (int)NewSAPAccountUtil.NewAccountApprovalStatus.Approved);
                    AppTranState = NewSAPAccountUtil.ApprovalTransition.ManagerApprove;
                }
                else
                {
                    sqlUpdateReq += string.Format(" set ManagerApprovalStatus={0}, ManagerApprovalTime=getdate(), ManagerComment=@COMMENT", (int)NewSAPAccountUtil.NewAccountApprovalStatus.Rejected);
                    AppTranState = NewSAPAccountUtil.ApprovalTransition.ManagerReject;
                }
            }
            btnCreateSAPAccount_Click(this.btnApproval, null);
            sqlUpdateReq += " where ApplicationId=@APPID ";
            var cmdUpdate = new System.Data.SqlClient.SqlCommand(sqlUpdateReq,new System.Data.SqlClient.SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["MY_EC2"].ConnectionString));
            cmdUpdate.Parameters.AddWithValue("@COMMENT", txtApprovalComment.Text);
            cmdUpdate.Parameters.AddWithValue("@APPID", ApplicationId.Value);
            cmdUpdate.Connection.Open();
            cmdUpdate.ExecuteNonQuery();
            cmdUpdate.Connection.Close();

            NewSAPAccountUtil.SendApprovalEmail(ApplicationId.Value, AppTranState, Util.GetRuntimeSiteUrl());

            if (!IsCreateAccount)
            {
                lbMsg.Text = "Approval Status has been updated";
            }
            else {
                btnCreateSAPAccount_Click(this.btnCreateSAPAccount, null);
                lbMsg.Text ="Approved and SAP account is created.<br/>"+lbMsg.Text;
            }
        }

    }
}