using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_CsharpTest_TC : System.Web.UI.Page
{
    bool istesting = true;
    protected void Page_Load(object sender, EventArgs e)
    {
        AddCreditCardInfo2SAPSO("OBB020310", "GY788","98765432109", CreditCardTypes.VISA,"************7887", 77.8m);
        Response.Write("Done");
    }

    public enum CreditCardTypes {
        VISA,
        AMEX,
        DISC,
        MC
    }

    void AddCreditCardInfo2SAPSO(string SONO,string AuthCode, string TranId, CreditCardTypes CardType, string CardNum, decimal AuthAmt)
    {
        SONO = Global_Inc.SONoBuildSAPFormat(SONO.Trim().ToUpper()).ToString();
        string SAPRFCconnection = "SAP_PRD"; if (istesting) SAPRFCconnection = "SAPConnTest";
        string SAPDbconnection = "SAP_PRD"; if (istesting) SAPDbconnection = "SAP_Test";
        var dtFPLT = OraDbUtil.dbGetDataTable(SAPDbconnection, string.Format(
            @"
            select b.fplnr, b.fpltr, b.fpttp, b.tetxt, b.fkdat, b.fpfix, b.fareg, b.fproz, b.waers, b.kurfp, b.fakwr
            , b.faksp, b.fkarv, b.fksaf, b.perio, b.fplae, b.mlstn, b.mlbez, b.zterm, b.kunrg,
            b.taxk1, b.taxk2, b.taxk3, b.taxk4, b.taxk5, b.taxk6, b.taxk7, b.taxk8, b.taxk9
            , b.valdt, b.nfdat, b.teman, b.fakca, b.afdat, b.netwr, b.netpr, b.wavwr, 
            b.kzwi1, b.kzwi2, b.kzwi3, b.kzwi4, b.kzwi5, b.kzwi6, b.cmpre, b.skfbp, b.bonba, b.prsok
            , b.typzm, b.cmpre_flt, b.uelnr, b.ueltr, b.kurrf, b.ccact, b.korte, b.ofkdat, b.perop_beg, b.perop_end,
            c.ccins, c.ccnum, c.ccfol, c.datab, c.datbi, c.ccname, c.csour, c.autwr, c.ccwae, c.settl, c.aunum, c.autra
            , c.audat, c.autim, c.merch, c.locid, c.trmid, c.ccbtc, c.cctyp, c.ccard_guid,
            'A' as CCAUA, 'C' as CCALL, 'A' as REACT, c.autwv, c.ccold, c.ccval, c.ccpre
            , c.ueltr_a, c.rcavr, c.rcava, c.rcavz, c.rcrsp, c.rtext
            from saprdp.fpla a inner join saprdp.fplt b on a.fplnr=b.fplnr
            inner join saprdp.fpltc c on b.fplnr=c.fplnr and b.fpltr=c.fpltr
            where a.mandt='168' and b.mandt='168' and c.mandt='168' and a.vbeln='{0}' 
            order by b.fpltr ", SONO));
        if (dtFPLT.Rows.Count > 0)
        {
            System.Data.DataRow drFPLT = dtFPLT.Rows[dtFPLT.Rows.Count-1];            
            var FPLT_NEW = new ZBILLING_SCHEDULE_SAVE.FPLTVB()
            {
                Mandt = "168",
                Fplnr = drFPLT["FPLNR"].ToString(),
                Fpltr = drFPLT["FPLTR"].ToString(),
                Fpttp = drFPLT["FPTTP"].ToString(),
                Tetxt = drFPLT["TETXT"].ToString(),
                Fkdat = drFPLT["FKDAT"].ToString(),
                Fpfix = drFPLT["FPFIX"].ToString(),
                Fareg = drFPLT["FAREG"].ToString(),
                Fproz = decimal.Parse(drFPLT["FPROZ"].ToString()),
                Waers = drFPLT["WAERS"].ToString(),
                Kurfp = decimal.Parse(drFPLT["KURFP"].ToString()),
                Fakwr = decimal.Parse(drFPLT["FAKWR"].ToString()),
                Faksp = drFPLT["FAKSP"].ToString(),
                Fkarv = drFPLT["FKARV"].ToString(),
                Fksaf = drFPLT["FKSAF"].ToString(),
                Perio = drFPLT["PERIO"].ToString(),
                Fplae = drFPLT["FPLAE"].ToString(),
                Mlstn = drFPLT["MLSTN"].ToString(),
                Mlbez = drFPLT["MLBEZ"].ToString(),
                Zterm = drFPLT["ZTERM"].ToString(),
                Kunrg = drFPLT["KUNRG"].ToString(),
                Taxk1 = drFPLT["TAXK1"].ToString(),
                Taxk2 = drFPLT["TAXK2"].ToString(),
                Taxk3 = drFPLT["TAXK3"].ToString(),
                Taxk4 = drFPLT["TAXK4"].ToString(),
                Taxk5 = drFPLT["TAXK5"].ToString(),
                Taxk6 = drFPLT["TAXK6"].ToString(),
                Taxk7 = drFPLT["TAXK7"].ToString(),
                Taxk8 = drFPLT["TAXK8"].ToString(),
                Taxk9 = drFPLT["TAXK9"].ToString(),
                Valdt = drFPLT["VALDT"].ToString(),
                Nfdat = drFPLT["NFDAT"].ToString(),
                Teman = drFPLT["TEMAN"].ToString(),
                Fakca = drFPLT["FAKCA"].ToString(),
                Afdat = drFPLT["AFDAT"].ToString(),
                Netwr = decimal.Parse(drFPLT["NETWR"].ToString()),
                Netpr = decimal.Parse(drFPLT["NETPR"].ToString()),
                Wavwr = decimal.Parse(drFPLT["WAVWR"].ToString()),
                Kzwi1 = decimal.Parse(drFPLT["KZWI1"].ToString()),
                Kzwi2 = decimal.Parse(drFPLT["KZWI2"].ToString()),
                Kzwi3 = decimal.Parse(drFPLT["KZWI3"].ToString()),
                Kzwi4 = decimal.Parse(drFPLT["KZWI4"].ToString()),
                Kzwi5 = decimal.Parse(drFPLT["KZWI5"].ToString()),
                Kzwi6 = decimal.Parse(drFPLT["KZWI6"].ToString()),
                Cmpre = decimal.Parse(drFPLT["CMPRE"].ToString()),
                Skfbp = decimal.Parse(drFPLT["SKFBP"].ToString()),
                Bonba = decimal.Parse(drFPLT["BONBA"].ToString()),
                Prsok = drFPLT["PRSOK"].ToString(),
                Typzm = drFPLT["TYPZM"].ToString(),
                Cmpre_Flt = double.Parse(drFPLT["CMPRE_FLT"].ToString()),
                Uelnr = drFPLT["UELNR"].ToString(),
                Ueltr = drFPLT["UELTR"].ToString(),
                Kurrf = decimal.Parse(drFPLT["KURRF"].ToString()),
                Ccact = drFPLT["CCACT"].ToString(),
                Korte = drFPLT["KORTE"].ToString(),
                Ofkdat = drFPLT["OFKDAT"].ToString(),
                Perop_Beg = drFPLT["PEROP_BEG"].ToString(),
                Perop_End = drFPLT["PEROP_END"].ToString(),
                Ccins = drFPLT["CCINS"].ToString(),
                Ccnum = drFPLT["CCNUM"].ToString(),
                Ccfol = drFPLT["CCFOL"].ToString(),
                Datab = drFPLT["DATAB"].ToString(),
                Datbi = drFPLT["DATBI"].ToString(),
                Ccname = drFPLT["CCNAME"].ToString(),
                Csour = drFPLT["CSOUR"].ToString(),
                Autwr = decimal.Parse(drFPLT["AUTWR"].ToString()),
                Ccwae = drFPLT["CCWAE"].ToString(),
                Settl = drFPLT["SETTL"].ToString(),
                Aunum = drFPLT["AUNUM"].ToString(),
                Autra = drFPLT["AUTRA"].ToString(),
                Audat = drFPLT["AUDAT"].ToString(),
                Autim = drFPLT["AUTIM"].ToString(),
                Merch = drFPLT["MERCH"].ToString(),
                Locid = drFPLT["LOCID"].ToString(),
                Trmid = drFPLT["TRMID"].ToString(),
                Ccbtc = drFPLT["CCBTC"].ToString(),
                Cctyp = drFPLT["CCTYP"].ToString(),
                Ccard_Guid = drFPLT["CCARD_GUID"].ToString(),
                Ccaua = drFPLT["CCAUA"].ToString(),
                Ccall = drFPLT["CCALL"].ToString(),
                React = drFPLT["REACT"].ToString(),
                Autwv = decimal.Parse(drFPLT["AUTWV"].ToString()),
                Ccold = drFPLT["CCOLD"].ToString(),
                Ccval = drFPLT["CCVAL"].ToString(),
                Ccpre = drFPLT["CCPRE"].ToString(),
                Ueltr_A = drFPLT["UELTR_A"].ToString(),
                Rcavr = drFPLT["RCAVR"].ToString(),
                Rcava = drFPLT["RCAVA"].ToString(),
                Rcavz = drFPLT["RCAVZ"].ToString(),
                Rcrsp = drFPLT["RCRSP"].ToString(),
                Rtext = drFPLT["RTEXT"].ToString(),
                Updkz = "I",
                Selkz = ""               
            };
            int Max_Fpltr = int.Parse(FPLT_NEW.Fpltr) + 1;
            FPLT_NEW.Fpltr = Max_Fpltr.ToString();
            //FPLT_NEW.Ccaua = "A"; FPLT_NEW.Ccall = "C"; FPLT_NEW.React = "A";
            FPLT_NEW.Ccins = CardType.ToString();
            FPLT_NEW.Ccnum = CardNum;
            FPLT_NEW.Aunum = AuthCode;
            FPLT_NEW.Autra = TranId;
            FPLT_NEW.Autwr = AuthAmt;
            //20180109 TC: FPLT_NEW.Fksaf is the field to turn yellow light to gree light
            FPLT_NEW.Fksaf = "A";

            var FPLA_NEW_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLAVBTable();
            var FPLA_OLD_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLAVBTable();
            var FPLT_NEW_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLTVBTable();
            var FPLT_OLD_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLTVBTable();
            FPLT_NEW_Table1.Add(FPLT_NEW);
            var RFCClient1 = new ZBILLING_SCHEDULE_SAVE.ZBILLING_SCHEDULE_SAVE();
            RFCClient1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[SAPRFCconnection]);
            RFCClient1.Connection.Open();
            RFCClient1.Zbilling_Schedule_Save(ref FPLA_NEW_Table1, ref FPLA_OLD_Table1, ref FPLT_NEW_Table1, ref FPLT_OLD_Table1);
            RFCClient1.Connection.Close();
        }

    }

    void UnblockSOCreditCard(string SONO) {
        SONO = Global_Inc.SONoBuildSAPFormat(SONO.Trim().ToUpper()).ToString();
        string SAPRFCconnection = "SAP_PRD"; if (istesting) SAPRFCconnection = "SAPConnTest";
        string SAPDbconnection = "SAP_PRD"; if (istesting) SAPDbconnection = "SAP_Test";
        var dtFPLA= OraDbUtil.dbGetDataTable(SAPDbconnection, string.Format("select * from saprdp.fpla where vbeln='{0}'",SONO));
        if (dtFPLA.Rows.Count > 0) {
            System.Data.DataRow drFPLA = dtFPLA.Rows[0]; 
            var FPLA_NEW = new ZBILLING_SCHEDULE_SAVE.FPLAVB() {
                Mandt="168", Fplnr = drFPLA["Fplnr"].ToString(),
                Aust1="B",  Aust5 = "",  Updkz="U", Selkz ="", Dfksaf="", Netwrp= (decimal)0.0
            };

            FPLA_NEW.Fptyp = drFPLA["Fptyp"].ToString();
            FPLA_NEW.Fpart = drFPLA["Fpart"].ToString(); FPLA_NEW.Sortl = drFPLA["Sortl"].ToString();
            FPLA_NEW.Bedat = drFPLA["Bedat"].ToString(); FPLA_NEW.Endat = drFPLA["Endat"].ToString();
            FPLA_NEW.Horiz = drFPLA["Horiz"].ToString(); FPLA_NEW.Vbeln = drFPLA["Vbeln"].ToString();
            FPLA_NEW.Bedar = drFPLA["Bedar"].ToString(); FPLA_NEW.Endar = drFPLA["Endar"].ToString();
            FPLA_NEW.Perio = drFPLA["Perio"].ToString(); FPLA_NEW.Fplae = drFPLA["Fplae"].ToString();
            FPLA_NEW.Rfpln = drFPLA["Rfpln"].ToString(); FPLA_NEW.Lodat = drFPLA["Lodat"].ToString();
            FPLA_NEW.Autte = drFPLA["Autte"].ToString(); FPLA_NEW.Lodar = drFPLA["Lodar"].ToString();
            FPLA_NEW.Peraf = drFPLA["Peraf"].ToString(); FPLA_NEW.Fakca = drFPLA["Fakca"].ToString();
            FPLA_NEW.Tndat = drFPLA["Tndat"].ToString(); FPLA_NEW.Tndar = drFPLA["Tndar"].ToString();
            FPLA_NEW.Aufpl = drFPLA["Aufpl"].ToString(); FPLA_NEW.Aplzl = drFPLA["Aplzl"].ToString();
            FPLA_NEW.Rsnum = drFPLA["Rsnum"].ToString(); FPLA_NEW.Rspos = drFPLA["Rspos"].ToString();
            FPLA_NEW.Ebeln = drFPLA["Ebeln"].ToString(); FPLA_NEW.Fpltu = drFPLA["Fpltu"].ToString();
            FPLA_NEW.Aust2 = drFPLA["Aust2"].ToString(); FPLA_NEW.Aust3 = drFPLA["Aust3"].ToString();
            FPLA_NEW.Aust4 = drFPLA["Aust4"].ToString();
            if (drFPLA["Basiswrt"] != DBNull.Value) FPLA_NEW.Basiswrt = decimal.Parse(drFPLA["Basiswrt"].ToString());
            FPLA_NEW.Pspnr = drFPLA["Pspnr"].ToString();
            FPLA_NEW.Autkor = drFPLA["Autkor"].ToString();

            var FPLA_NEW_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLAVBTable();
            FPLA_NEW_Table1.Add(FPLA_NEW);
            var FPLA_OLD_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLAVBTable(); 
            var FPLT_NEW_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLTVBTable();
            var FPLT_OLD_Table1 = new ZBILLING_SCHEDULE_SAVE.FPLTVBTable();
            var RFCClient1 = new ZBILLING_SCHEDULE_SAVE.ZBILLING_SCHEDULE_SAVE();
            RFCClient1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[SAPRFCconnection]);
            RFCClient1.Connection.Open();
            RFCClient1.Zbilling_Schedule_Save(ref FPLA_NEW_Table1, ref FPLA_OLD_Table1, ref FPLT_NEW_Table1, ref FPLT_OLD_Table1);
            RFCClient1.Connection.Close();
        }
        
    }

    bool CancelABBSO() {
        return true;
    }

    void CreateSAPContact() {
        var RC1 = new CreateSAPContact.CreateSAPContact();
        string SAPRFCconnection = "SAP_PRD"; if (istesting) SAPRFCconnection = "SAPConnTest";
        var SoldToId = "BBTEST019"; var FirstName = "TaChun"; var LastName = "Chen"; var ContactEmail = "tc.chen@advantech.com.tw";
        var Telephone = "0876449"; var TelExt = "7788"; var DepartmentCode = "0005"; var JobTitleCode = "";
        var CreationLogTable = new CreateSAPContact.ZSSD_07_LOGTable();
        RC1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[SAPRFCconnection]);
        RC1.Connection.Open();
        RC1.Z_B2c_Contact_Create(DepartmentCode, SoldToId, ContactEmail, TelExt, FirstName, LastName, JobTitleCode, Telephone, ref CreationLogTable);
        RC1.Connection.Close();
        gv1.DataSource = CreationLogTable.ToADODataTable(); gv1.DataBind();
    }

    class A053Record {
        public string TXJCD { get; set; }
        public string DATBI { get; set; }
        public string DATAB { get; set; }
        public string KNUMH { get; set; }
        public decimal kbetr { get; set; }
    }

    void GetSAPTax() {
        var ReadSAPTable = new Read_Sap_Table.Read_Sap_Table();
        var SAPTableData = new Read_Sap_Table.TAB512Table(); var SAPTableFields = new Read_Sap_Table.RFC_DB_FLDTable();
        var SAPTableQuery = new Read_Sap_Table.RFC_DB_OPTTable();
        string SAPRFCconnection = "SAP_PRD"; if (istesting) SAPRFCconnection = "SAPConnTest";
        string SAPDbconnection = "SAP_PRD"; if (istesting) SAPDbconnection = "SAP_Test";
        SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() { Fieldname = "TXJCD" });
        SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() { Fieldname = "DATBI" });
        SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() { Fieldname = "DATAB" });
        SAPTableFields.Add(new Read_Sap_Table.RFC_DB_FLD() { Fieldname = "KNUMH" });
        SAPTableQuery.Add(new Read_Sap_Table.RFC_DB_OPT() { Text = "MANDT EQ '168' AND KAPPL EQ 'TX' AND ALAND EQ 'US' AND MWSKZ EQ 'S2'" });
        SAPTableQuery.Add(new Read_Sap_Table.RFC_DB_OPT() { Text = "AND KSCHL EQ 'JR2' AND TXJCD LIKE 'IL%' AND DATBI EQ '99991231'" });

        ReadSAPTable.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings[SAPRFCconnection]);
        ReadSAPTable.Connection.Open();
        ReadSAPTable.Rfc_Read_Table(";", "", "A053", 200, 0, ref SAPTableData, ref SAPTableFields, ref SAPTableQuery);
        ReadSAPTable.Connection.Close();

        var A053List = new List<A053Record>();
        foreach (Read_Sap_Table.TAB512 SAPTableRec in SAPTableData)
        {
            var SapTableRecFields = SAPTableRec.Wa.Split(new string[] { ";" }, StringSplitOptions.None);
            var A053Record1 = new A053Record() { TXJCD = SapTableRecFields[0], DATBI= SapTableRecFields[1], DATAB= SapTableRecFields[2], KNUMH= SapTableRecFields[3]};
            A053List.Add(A053Record1);
            var dtTaxRate = OraDbUtil.dbGetDataTable(SAPDbconnection, "select kbetr*0.001 as kbetr from saprdp.konp where knumh='" + A053Record1.KNUMH + "'");
            if (dtTaxRate.Rows.Count > 0)
            {
                A053Record1.kbetr = Convert.ToDecimal(dtTaxRate.Rows[0]["kbetr"]);
            }
            else { A053Record1.kbetr = -1; }
        }        
        gv1.DataSource = A053List; gv1.DataBind();
    }

    void VATValidation() {
        //CZ25044516
        var vatWS = new EUVATWS.checkVatTestService();
        var CountryCode = "CZ"; var VATNumber = "25044516"; bool IsVatValid; var VATName = ""; var VATAddr = "";
        var ValidDate = vatWS.checkVat(ref CountryCode, ref VATNumber, out IsVatValid, out VATName, out VATAddr);
        Response.Write(string.Format("ValidDate:{0},IsVatValid:{1},VATAddr:{2}", ValidDate.ToString("yyyy-MM-dd HH:mm:ss"), IsVatValid, VATAddr));
    }

    void WiseOrder_EnSaaS()
    {
        var wp = new WiseOrderUtil();
        var AssetId = "gy-7788";
        wp.IsToSAPPRD = false;
        
        
        var input = new WiseOrderUtil.WISEPoint2OrderEnSaaSInput()
        {
            AssetId = AssetId,
            WisePointOrderSONO = "2228984"
        };
        input.RedeemItemList.Add(new WiseOrderUtil.RedeemItemPointQty() { Qty = 2, RedeemPartNo = "9806WPENS0", RedeemPoints = 14.8 });
        input.RedeemItemList.Add(new WiseOrderUtil.RedeemItemPointQty() { Qty = 6, RedeemPartNo = "9806WPRM01", RedeemPoints = 2.4 });
        input.RedeemItemList.Add(new WiseOrderUtil.RedeemItemPointQty() { Qty = 1, RedeemPartNo = "9806WAC010", RedeemPoints = 0.67 });

        var output = wp.WISEPoint2OrderEnSaaS(input);
        Response.Write(output.ErrorMessage);
        var listOutput = new List<WiseOrderUtil.ReturnResult>();
        listOutput.Add(output);
        gv1.DataSource = listOutput; gv1.DataBind();
    }

    void WiseOrder() {
        var wp = new WiseOrderUtil();
        wp.IsToSAPPRD = true;
        var input = new WiseOrderUtil.WISEPoint2OrderV2Input()
        {
            AssetId = "1-1IHZJFW",
            MembershipEmail = "",
            RedeemPartNo = "WA-P82-U300E",
            Qty = 1,
            RedeemPoints = 51,
            WisePointOrderSONO = "0001168938"
        };
        var output = wp.WISEPoint2OrderV3(input);
        Response.Write(output.ErrorMessage);
        var listOutput = new List<WiseOrderUtil.ReturnResult>();
        listOutput.Add(output);
        gv1.DataSource = listOutput; gv1.DataBind();
    }

    void UploadURL2SAPKNA1() {  
        var RFCClient1 = new ZSGOS_URL.ZSGOS_URL();
        var FileName = "test_"+DateTime.Now.ToString("yyyyMMddHHmmss")+".htm";
        //Use SAP-toce SWO1 to search object key
        var ObjectKeyType = new ZSGOS_URL.BORIDENT() { Objkey = "BBTEST021", Objtype = "KNA1" };        
        var SOODK1 = new ZSGOS_URL.SOODK(); var EP_URL = "";
        RFCClient1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings["SAPConnTest"]);
        RFCClient1.Connection.Open();
        RFCClient1.Zsgos_Url_Create_Internal(FileName, ObjectKeyType, "http://my.advantech.com", out SOODK1, out EP_URL);        
        RFCClient1.Connection.Close();
        Response.Write(string.Format("EP_URL:{0}", EP_URL));
    }

    void UploadURL2SAPSO()
    {
        var RFCClient1 = new ZSGOS_URL.ZSGOS_URL();
        var FileName = "test.aaa";
        //Use SAP-toce SWO1 to search object key
        var ObjectKeyType = new ZSGOS_URL.BORIDENT() { Objkey = "BB000004", Objtype = "BUS2032" };
        var SOODK1 = new ZSGOS_URL.SOODK(); var EP_URL = "";
        RFCClient1.Connection = new SAP.Connector.SAPConnection(System.Configuration.ConfigurationManager.AppSettings["SAPConnTest"]);
        RFCClient1.Connection.Open();
        RFCClient1.Zsgos_Url_Create_Internal(FileName, ObjectKeyType, "http://my.advantech.com", out SOODK1, out EP_URL);
        RFCClient1.Connection.Close();
    }

}