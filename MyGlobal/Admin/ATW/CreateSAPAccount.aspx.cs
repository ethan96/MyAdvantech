using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Advantech.Myadvantech.DataAccess;
using Advantech.Myadvantech.Business;
using System.Web.Services;

public partial class Admin_ATW_CreateSAPAccount : System.Web.UI.Page
{
    public string DUNSNumber = ""; public string DBPaymentIndex = ""; public string PriceGrade = ""; public string LegalForm = "";
    public string txtTel = ""; public string Fax = ""; public string ShippingRemarks = "";
    public bool IsHaveShipTO = false, IsHaveBillTo = false; public string Industrycode1 = ""; public string Industrycode2 = ""; public string CompanyDescription = "";
    public string _Region = ""; public string _Industry = ""; public string CreditAmount = ""; string SearchTerm1 = ""; string SearchTerm2 = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            HidRowid.Value = System.Guid.NewGuid().ToString().Replace("-", "").Substring(0, 30);
            initView();
            if (Request["id"] != null && !string.IsNullOrEmpty(Request["id"].ToString().Trim()))
            {
                SA_APPLICATION currAPP = null;
                int id = int.Parse(Request["id"].ToString());
                HidRowid.Value = Request["id"] ?? "";
                currAPP = MyAdminBusinessLogic.getApplicationByID(id);
                List<SA_Proposal> pls = MyAdminContext.Current.SA_Proposal.Where(p => p.AppID == id).OrderBy(p => p.CreateTime).ToList();
                StringBuilder sb = new StringBuilder();
                int i = 0;
                sb.AppendFormat("<tr><td class='acb'>{0}</td><td class='acb'>{1}</td><td class='acb'>{2}</td><td class='acb'>{3}</td></tr>", ++i, currAPP.REQUEST_BY, currAPP.REQUEST_DATE.ToString("yyyy-MM-dd  HH:mm"), "New Request");

                foreach (SA_Proposal p in pls)
                {
                    sb.AppendFormat("<tr><td class='acb'>{0}</td><td class='acb'>{1}</td><td class='acb'>{2}</td><td class='acb'>{3}</td></tr>", ++i, p.CreateBy, Convert.ToDateTime(p.CreateTime).ToString("yyyy-MM-dd  HH:mm"), p.Comment);
                }

                labTBproposal.Text = sb.ToString();

                SA_APPLICATION2COMPANY a2cSholdTo = currAPP.SA_APPLICATION2COMPANY.Where(p => p.ApplicationID == currAPP.ID && p.CompanyType == 0).FirstOrDefault();
                txtCompanyId2.Text = a2cSholdTo.CompanyID;
                txtCompanyDescription.Text = currAPP.CompanyDescription;
                CompanyDescription = currAPP.CompanyDescription;
                //TBComment.Text = currAPP.COMMENT;
                dlOrgID.SelectedValue = a2cSholdTo.SA_KNB1.FirstOrDefault().Bukrs;
                DUNSNumber = a2cSholdTo.DUNSNumber;
                DBPaymentIndex = a2cSholdTo.DBPaymentIndex;
                txtCompanyName.Text = a2cSholdTo.SA_KNA1.FirstOrDefault().Name1;
                _Industry = dlIndustry.SelectedValue;
                TBsiebelAccountID.Text = a2cSholdTo.AccountRowID;
                dlPaymentTerm.SelectedValue = a2cSholdTo.SA_KNB1.FirstOrDefault().Zterm;
                dlCustomerGroup.SelectedValue = a2cSholdTo.CustomerGroup;
                txtVAT.Text = a2cSholdTo.SA_KNA1.FirstOrDefault().Stceg;
                txtWebsiteUrl.Text = a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Homepage;
                txtAddr1.Text = a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Street;
                txtAddr2.Text = a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Str_Suppl3;
                txtAddr3.Text = a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Location;
                dlIndustry.SelectedValue = a2cSholdTo.SA_KNA1.FirstOrDefault().Brsch;
                dlTAXID.SelectedValue = a2cSholdTo.SA_FKNVI.Where(p=>p.Aland== a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Country).FirstOrDefault().Taxkd;
                txtPostCode.Text = a2cSholdTo.SA_KNA1.FirstOrDefault().Pstlz;
                txtCity.Text = a2cSholdTo.SA_KNA1.FirstOrDefault().Ort01;
                dlCountry.SelectedValue = a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Country;
                txtTel = a2cSholdTo.SA_KNA1.FirstOrDefault().Telf1;
                Fax = a2cSholdTo.SA_KNA1.FirstOrDefault().Telfx;
                Industrycode1 = a2cSholdTo.SA_KNA1.FirstOrDefault().Bran1;
                Industrycode2 = a2cSholdTo.SA_KNA1.FirstOrDefault().Bran2;
                txtContactName.Text = a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().C_O_Name;
                txtContactEmail.Text = a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().E_Mail;
                TBSearchTerm1.Text =a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Sort1 ;
                  TBSearchTerm2.Text =a2cSholdTo.SA_BAPIADDR1.FirstOrDefault().Sort2 ;
                CreditAmount=a2cSholdTo.SA_KNB1.FirstOrDefault().Vrsnr;
                dlCurr.SelectedValue = a2cSholdTo.SA_KNVV.FirstOrDefault().Waers;
                dlShipCond.SelectedValue = a2cSholdTo.SA_KNVV.FirstOrDefault().Vsbed;
                dlInco1.SelectedValue = a2cSholdTo.SA_KNVV.FirstOrDefault().Inco1;
                ShippingRemarks = a2cSholdTo.SA_KNVV.FirstOrDefault().Inco2;
                dlSalesOffice.SelectedValue = a2cSholdTo.SA_KNVV.First().Vkbur;
                //TC: load group options based on selected office first, then select the selected group
                dlSalesOffice_SelectedIndexChanged(this.dlSalesOffice, new EventArgs());
                dlSalesGroup.SelectedValue = a2cSholdTo.SA_KNVV.First().Vkgrp;
                LegalForm = a2cSholdTo.OfficialRegistrationNo;
                PriceGrade = a2cSholdTo.PriceGrade;
                dlSalesCode.SelectedValue = a2cSholdTo.SalesCode;
                //dlISCode.SelectedValue = a2cSholdTo.InsideSalesCode; ICC 2015/3/10 Polar said ATW don't have to fill inside sales ID
                dlOPCode.SelectedValue = a2cSholdTo.OPCode;
                
                dlVM.SelectedValue = a2cSholdTo.VerticalMarketDefinition;
                SA_APPLICATION2COMPANY a2cShipTo = currAPP.SA_APPLICATION2COMPANY.Where(p => p.ApplicationID == currAPP.ID && p.CompanyType == 1).FirstOrDefault();
                if (a2cShipTo != null)
                {
                    IsHaveShipTO = true;
                    txtShiptoCompanyName.Text = a2cShipTo.SA_KNA1.FirstOrDefault().Name1;
                    txtShiptoVATNumber.Text = a2cShipTo.SA_KNA1.FirstOrDefault().Stceg; ;
                    txtShiptoAddress.Text = a2cShipTo.SA_BAPIADDR1.FirstOrDefault().Street;
                    txtShiptoAddress2.Text = a2cShipTo.SA_BAPIADDR1.FirstOrDefault().Str_Suppl3; ;
                    txtShiptoAddress3.Text = a2cShipTo.SA_BAPIADDR1.FirstOrDefault().Location; ;
                    txtShiptoPostcode.Text = a2cShipTo.SA_KNA1.FirstOrDefault().Pstlz;
                    txtShiptoCity.Text = a2cShipTo.SA_KNA1.FirstOrDefault().Ort01;
                    dlShiptoCountry.SelectedValue = a2cShipTo.SA_BAPIADDR1.FirstOrDefault().Country;
                    txtShiptoTel.Text = a2cShipTo.SA_KNA1.FirstOrDefault().Telf1;
                    txtShiptoFax.Text = a2cShipTo.SA_KNA1.FirstOrDefault().Telfx;
                    txtShiptoContactName.Text = a2cShipTo.SA_BAPIADDR1.FirstOrDefault().C_O_Name;
                    txtShiptoContactEmail.Text = a2cShipTo.SA_BAPIADDR1.FirstOrDefault().E_Mail;
                    txtShiptoTel.Text = a2cShipTo.SA_KNA1.FirstOrDefault().Telf1;
                }
                SA_APPLICATION2COMPANY a2cBillTo = currAPP.SA_APPLICATION2COMPANY.Where(p => p.ApplicationID == currAPP.ID && p.CompanyType == 2).FirstOrDefault();
                if (a2cBillTo != null)
                {
                    IsHaveBillTo = true;
                    txtBillingCompanyName.Text = a2cBillTo.SA_KNA1.FirstOrDefault().Name1;
                    txtBillingVATNumber.Text = a2cBillTo.SA_KNA1.FirstOrDefault().Stceg; ; ;
                    txtBillingAddress.Text = a2cBillTo.SA_BAPIADDR1.FirstOrDefault().Street;
                    txtBillingAddress2.Text = a2cBillTo.SA_BAPIADDR1.FirstOrDefault().Str_Suppl3;
                    txtBillingAddress3.Text = a2cBillTo.SA_BAPIADDR1.FirstOrDefault().Location;
                    txtBillingPostcode.Text = a2cBillTo.SA_KNA1.FirstOrDefault().Pstlz;
                    txtBillingCity.Text = a2cBillTo.SA_KNA1.FirstOrDefault().Ort01;
                    dlBillingCountry.SelectedValue = a2cBillTo.SA_BAPIADDR1.FirstOrDefault().Country;
                    txtBillingTel.Text = a2cBillTo.SA_KNA1.FirstOrDefault().Telf1;
                    txtBillingFax.Text = a2cBillTo.SA_KNA1.FirstOrDefault().Telfx;
                    txtBillingContactName.Text = a2cBillTo.SA_BAPIADDR1.FirstOrDefault().C_O_Name;
                    txtBillingContactEmail.Text = a2cBillTo.SA_BAPIADDR1.FirstOrDefault().E_Mail;
                    txtBillingTel.Text = a2cBillTo.SA_KNA1.FirstOrDefault().Telf1;
                }
            }

        }
        if (Request["action"] != null)
        {
            string action = Request["action"];
            switch (action)
            {
                case "save":
                    save();
                    break;
            }

        }

    }
    private void initView()
    {
        DataTable dtcountry = dbUtil.dbGetDataTable("my", "select  distinct COUNTRY, isnull(country_name,'') as  country_name   from SAP_DIMCOMPANY where ORG_ID like 'TW%' ORDER BY COUNTRY");
        foreach (DataRow dr in dtcountry.Rows)
        {
            dlBillingCountry.Items.Add(new ListItem(string.Format("{0} - {1}", dr["COUNTRY"], dr["country_name"]), dr["COUNTRY"].ToString()));
            dlShiptoCountry.Items.Add(new ListItem(string.Format("{0} - {1}", dr["COUNTRY"], dr["country_name"]), dr["COUNTRY"].ToString()));
            dlCountry.Items.Add(new ListItem(string.Format("{0} - {1}", dr["COUNTRY"], dr["country_name"]), dr["COUNTRY"].ToString()));
        }
       
        dlOrgID.Items.Add(new ListItem("TW01", "TW01")); dlOrgID.Items.Add(new ListItem("US10", "US10"));        
        //dlOrgID.Enabled = false;
        DataTable dtcur = dbUtil.dbGetDataTable("my", "select  distinct CURRENCY  from SAP_DIMCOMPANY  ORDER BY CURRENCY");
        dlCurr.DataSource = dtcur;         dlCurr.DataBind(); dlCurr.SelectedValue = "USD";
        DataTable dtShipCondition = dbUtil.dbGetDataTable("my", "select distinct VSBED AS SHIPCONDITION,'' as SHIPCONTXT from SAP_SHIPCONDITION_BY_PLANT where VSBED <> '' order by VSBED");
        foreach (DataRow dr in dtShipCondition.Rows)
        {
            dlShipCond.Items.Add(new ListItem(string.Format("{0} - {1}", dr["SHIPCONDITION"], Glob.shipCode2Txt(dr["SHIPCONDITION"].ToString())), dr["SHIPCONDITION"].ToString()));
        }
        //ICC 2015/3/3 Modify sql rule about payment term from Vanage's request
        DataTable dtInco1 = dbUtil.dbGetDataTable("my", "select distinct isnull(INCO1,'') as INCO1 from SAP_DIMCOMPANY where INCO1 <> '' and INCO1 <> 'AIR' ORDER BY INCO1");//2015/03/10 Polar's request AIR is not an incoterm
        dlInco1.DataSource = dtInco1;
        dlInco1.DataBind();
        //ICC 2015/3/3 Modify sql rule about  sales office from Vanage's request
        //DataTable dtoff = dbUtil.dbGetDataTable("my", "select  distinct  ISNULL(SALESOFFICE,'') AS  officecode, ISNULL(SALESOFFICE,'') +', ' + SALESOFFICENAME AS officedesc from SAP_DIMCOMPANY where SALESOFFICE <> '' and SALESOFFICENAME <>'' ORDER BY officecode ");
        //dlSalesOffice.DataSource = dtoff;
        //dlSalesOffice.DataBind();

        //20170814 TC: Get sales office from SAP testing server based on selected sales org. Why from SAP RDQ is because for B+B.
        dlOrgID_SelectedIndexChanged(this.dlOrgID, new EventArgs());

         DataTable TWsalesCodeDt = dbUtil.dbGetDataTable("MY", "select distinct b.FULL_NAME, b.SALES_CODE from  SAP_EMPLOYEE b left join  SAP_COMPANY_EMPLOYEE a on a.SALES_CODE=b.SALES_CODE where (a.SALES_ORG like 'TW%' and  a.PARTNER_FUNCTION='VE' ) or (b.PERS_AREA like 'TW%' and a.SALES_ORG is null)  order by b.SALES_CODE ");
        foreach (DataRow salesRow in TWsalesCodeDt.Rows)
        {
            dlSalesCode.Items.Add(new ListItem(String.Format("({1}) {0}", salesRow["FULL_NAME"], salesRow["SALES_CODE"]), salesRow["SALES_CODE"].ToString()));
            //dlISCode.Items.Add(new ListItem(String.Format("({1}) {0}", salesRow["FULL_NAME"], salesRow["SALES_CODE"]), salesRow["SALES_CODE"].ToString()));
        }
        dlSalesCode.Items.Insert(0, new ListItem("Select...", ""));
        dlSalesCode.Items[0].Attributes["style"] = "background-color:#fff3f3";

        //dlISCode.Items.Insert(0, new ListItem("Select...", ""));
        //dlISCode.Items[0].Attributes["style"] = "background-color:#fff3f3";
        //ICC 2015/3/3 Modify sql rule about OP list from Vanage's request
        DataTable TWOPCodeDt = dbUtil.dbGetDataTable("MY", "select distinct b.FULL_NAME, b.SALES_CODE from SAP_EMPLOYEE b left join  SAP_COMPANY_EMPLOYEE a on a.SALES_CODE=b.SALES_CODE where (a.SALES_CODE >='16000001' and a.SALES_CODE<='16999999') or (b.SALES_CODE like '171%' and b.PERS_AREA='TW01') order by b.SALES_CODE ");
        foreach (DataRow salesRow in TWOPCodeDt.Rows)
        {
            dlOPCode.Items.Add(new ListItem(String.Format("({1}) {0}", salesRow["FULL_NAME"], salesRow["SALES_CODE"]), salesRow["SALES_CODE"].ToString()));
        }
        dlOPCode.Items.Insert(0, new ListItem("Select...", ""));
        dlOPCode.Items[0].Attributes["style"] = "background-color:#fff3f3";

        dlPaymentTerm.DataSource = dbUtil.dbGetDataTable("MY", String.Format("select distinct PAYMENTTERM as Value, (PAYMENTTERM + ', ' + PAYMENTTERMNAME) as Name from SAP_COMPANY_LOV where ORG_ID='{0}' and PAYMENTTERM<>'' and PAYMENTTERMNAME<>'' order by PAYMENTTERM", "TW01"));
        dlPaymentTerm.DataTextField = "Name";         dlPaymentTerm.DataValueField = "Value";         dlPaymentTerm.DataBind();        
        dlPaymentTerm.Items[0].Attributes["style"] = "background-color:#fff3f3";        

        DataTable TWCustomerGroupDt = dbUtil.dbGetDataTable("MY", "select distinct CUST_GROUP from SAP_COMPANY_SALES_DEF where SALES_ORG='TW01' and CUST_GROUP like 'D%' order by CUST_GROUP ");
        foreach (DataRow salesRow in TWCustomerGroupDt.Rows)
        {
            dlCustomerGroup.Items.Add(new ListItem(salesRow["CUST_GROUP"].ToString(), salesRow["CUST_GROUP"].ToString()));
        }
        //dlCustomerGroup.Items.Insert(0, new ListItem("Select...", ""));
        dlCustomerGroup.Items.Insert(0, new ListItem("03 - ATW RLP", "03"));
        //DataTable TWCustomerTypeDt = dbUtil.dbGetDataTable("MY", "select distinct sd.SALESGROUP, t.BEZEI from SAP_DIMCOMPANY sd inner join SAP_COMPANY_TVGRT t on sd.SALESGROUP = t.VKGRP where sd.ORG_ID = 'TW01' and sd.SALESGROUP <> '' order by sd.SALESGROUP ");
        //foreach (DataRow salesRow in TWCustomerTypeDt.Rows)
        //{
        //    dlCustomerType.Items.Add(new ListItem(string.Format("{0}, {1}", salesRow["SALESGROUP"].ToString(), salesRow["BEZEI"].ToString()), salesRow["SALESGROUP"].ToString()));
        //}
        //dlCustomerType.Items.Insert(0, new ListItem("Select...", ""));

        var dtTaxIdList = OraDbUtil.dbGetDataTable("SAP_PRD", "select taxkd, vtext from saprdp.tskdt where spras='E' and mandt='168' and tatyp='MWST' order by taxkd");
        foreach (DataRow taxIdRow in dtTaxIdList.Rows) {
            dlTAXID.Items.Add(new ListItem(string.Format("{0} ({1})", taxIdRow["taxkd"].ToString(), taxIdRow["vtext"].ToString()), taxIdRow["taxkd"].ToString()));
        }
        foreach (DataRow taxIdRow in dtTaxIdList.Rows)
        {
            dlShipToTaxId.Items.Add(new ListItem(string.Format("{0} ({1})", taxIdRow["taxkd"].ToString(), taxIdRow["vtext"].ToString()), taxIdRow["taxkd"].ToString()));
        }
        foreach (DataRow taxIdRow in dtTaxIdList.Rows)
        {
            dlBillToTaxId.Items.Add(new ListItem(string.Format("{0} ({1})", taxIdRow["taxkd"].ToString(), taxIdRow["vtext"].ToString()), taxIdRow["taxkd"].ToString()));
        }
    }
    protected void BtChecksiebel_Click(object sender, EventArgs e)
    {
        this.UPPickAccount.Update(); this.MPPickAccount.Show();
    }
    public void PickAccountEnd(Object str)
    {

        System.Collections.Specialized.OrderedDictionary ret = str as System.Collections.Specialized.OrderedDictionary;

        TBsiebelAccountID.Text = ret["ROW_ID"].ToString();

        StringBuilder sb = new StringBuilder();
        sb.AppendLine("SELECT TOP 1 a.ROW_ID, ISNULL(b.ATTRIB_05, N'') AS ERP_ID, a.NAME AS ACCOUNT_NAME, ");
        sb.AppendLine("a.CUST_STAT_CD AS ACCOUNT_STATUS, ISNULL(a.MAIN_FAX_PH_NUM, N'') AS FAX_NUM, ");
        sb.AppendLine("ISNULL(a.MAIN_PH_NUM, N'') AS PHONE_NUM, ISNULL(a.OU_TYPE_CD, N'') AS OU_TYPE_CD, ISNULL(a.URL, N'') ");
        sb.AppendLine("AS URL, ISNULL(b.ATTRIB_34, N'') AS BusinessGroup, ISNULL(a.OU_TYPE_CD, N'') AS ACCOUNT_TYPE, ");
        sb.AppendLine("ISNULL(c.NAME, N'') AS RBU, ISNULL((SELECT EMAIL_ADDR FROM S_CONTACT WHERE ");
        sb.AppendLine("(ROW_ID IN (SELECT PR_EMP_ID FROM S_POSTN WHERE (ROW_ID IN (SELECT PR_POSTN_ID FROM S_ORG_EXT WHERE ");
        sb.AppendLine("(ROW_ID = a.ROW_ID)))))), N'') AS PRIMARY_SALES_EMAIL, a.PAR_OU_ID AS PARENT_ROW_ID, ");
        sb.AppendLine("ISNULL(b.ATTRIB_09, N'N') AS MAJORACCOUNT_FLAG, ISNULL(a.CMPT_FLG, N'N') AS COMPETITOR_FLAG, ");
        sb.AppendLine("ISNULL(a.PRTNR_FLG, N'N') AS PARTNER_FLAG, ISNULL(d.COUNTRY, N'') AS COUNTRY, ");
        sb.AppendLine("ISNULL(d.CITY, N'') AS CITY, ISNULL(d.ADDR, N'') AS ADDRESS, ISNULL(d.STATE, N'') AS STATE, ");
        sb.AppendLine("ISNULL(d.ZIPCODE, N'') AS ZIPCODE, ISNULL(d.PROVINCE, N'') AS PROVINCE, ");
        sb.AppendLine("ISNULL((SELECT TOP (1) NAME FROM S_INDUST WHERE (ROW_ID = a.X_ANNIE_PR_INDUST_ID)), N'N/A') AS BAA, ");
        sb.AppendLine("b.CREATED, b.LAST_UPD AS LAST_UPDATED, ISNULL((SELECT TOP (1) e.NAME ");
        sb.AppendLine("FROM S_PARTY AS e INNER JOIN S_POSTN AS f ON e.ROW_ID = f.OU_ID WHERE ");
        sb.AppendLine("(f.ROW_ID IN (SELECT PR_POSTN_ID FROM S_ORG_EXT AS S_ORG_EXT_2 WHERE ");
        sb.AppendLine("(ROW_ID = a.ROW_ID)))), N'') AS PriOwnerDivision, a.PR_POSTN_ID AS PriOwnerRowId, ");
        sb.AppendLine("ISNULL((SELECT TOP (1) NAME FROM S_POSTN AS f WHERE (ROW_ID IN ");
        sb.AppendLine("(SELECT PR_POSTN_ID FROM S_ORG_EXT AS S_ORG_EXT_1 WHERE ");
        sb.AppendLine("(ROW_ID = a.ROW_ID)))), N'') AS PriOwnerPosition, CAST('' AS nvarchar(10)) ");
        sb.AppendLine("AS LOCATION, CAST('' AS nvarchar(10)) AS ACCOUNT_TEAM, ISNULL(d.ADDR_LINE_2, N'') AS ADDRESS2, ");
        sb.AppendLine("ISNULL(b.ATTRIB_36, N'') AS ACCOUNT_CC_GRADE, ISNULL(a.BASE_CURCY_CD, N'') AS CURRENCY, ");
        sb.AppendLine("ISNULL(b.ATTRIB_04, N'') AS VAT_NO FROM S_ORG_EXT AS a LEFT OUTER JOIN ");
        sb.AppendLine("S_ORG_EXT_X AS b ON a.ROW_ID = b.ROW_ID LEFT OUTER JOIN ");
        sb.AppendLine("S_PARTY AS c ON a.BU_ID = c.ROW_ID LEFT OUTER JOIN ");
        sb.AppendLine("S_ADDR_PER AS d ON a.PR_ADDR_ID = d.ROW_ID ");
        sb.AppendLine("WHERE (a.ROW_ID = '{0}') ");
        DataTable dt = dbUtil.dbGetDataTable("CRMDB75", string.Format(sb.ToString(), TBsiebelAccountID.Text.Trim().Replace("'", "''")));
        if (dt.Rows.Count == 1)
        {

            txtCompanyName.Text = dt.Rows[0]["ACCOUNT_NAME"].ToString();
            txtAddr1.Text = dt.Rows[0]["Address"].ToString();
            //     'txtAddr2.Text = Trim(.Item("province").ToString.Trim + " " + .Item("city"))
            //     'txtAddr3.Text = .Item("COUNTRY") + " " + .Item("State") '.Item("location")
            txtPostCode.Text = dt.Rows[0]["ZIPCODE"].ToString();
            txtCity.Text = dt.Rows[0]["city"].ToString();
            txtWebsiteUrl.Text = dt.Rows[0]["URL"].ToString();
            txtVAT.Text = dt.Rows[0]["VAT_NO"].ToString();
            //  'txtContactEmail.Text = .Item("PRIMARY_SALES_EMAIL")
            //    'txtContactName.Text = Util.GetNameVonEmail(.Item("PRIMARY_SALES_EMAIL"))
            //If (dt.Rows[0]["COUNTRY"] != null )
            //    Dim Names() As String = [Enum].GetNames(GetType(EnumCountryCode))
            //    Dim Values() As Integer = [Enum].GetValues(GetType(EnumCountryCode))
            //    Dim dtCountry As DataTable = dbUtil.dbGetDataTable("MY", "select distinct COUNTRY, isnull(country_name,'') as  country_name  from SAP_DIMCOMPANY where country_name='" + .Item("COUNTRY") + "' order by COUNTRY")
            //    If dtCountry.Rows.Count > 0 Then
            //        SetDropDownList(dlCountry, FindEnumValueByName(GetType(EnumCountryCode), "Enum_" + dtCountry.Rows(0).Item("COUNTRY")))
            //    End If
            //End If

        }
        dt = dbUtil.dbGetDataTable("MY", String.Format("SELECT TOP 1 ( isnull(FirstName,'') +' '+ isnull(MiddleName,'') + ' '+isnull(LastName,'') ) AS  NAME , isnull(EMAIL_ADDRESS,'') as Email from dbo.SIEBEL_CONTACT WHERE ACCOUNT_ROW_ID ='{0}'", TBsiebelAccountID.Text.Trim().Replace("'", "''")));
        if (dt.Rows.Count == 1)
        {

            txtContactEmail.Text = dt.Rows[0]["Email"].ToString();
            txtContactName.Text = dt.Rows[0]["NAME"].ToString();

        }
        up1.Update();
        this.MPPickAccount.Hide();
    }
    public bool IsManager()
    {
        if (Util.IsAEUIT() || string.Equals(HttpContext.Current.User.Identity.Name, "Polar.Yu@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase) || string.Equals(HttpContext.Current.User.Identity.Name, "vanage.lin@advantech.com.tw", StringComparison.CurrentCultureIgnoreCase)) return true;
        return false;
    }
    public bool checkSAPErp(string Erpid)
    {
        string SAPconnection = "SAP_PRD";
        if (Util.IsTesting()) SAPconnection = "SAP_Test";
        DataTable dt = OraDbUtil.dbGetDataTable(SAPconnection, "select Name1 from  saprdp.kna1  where Kunnr ='" + Erpid.ToUpper() + "'");
        if (dt.Rows.Count > 0) return true;
        return false;
    }
    private void save()
    {
        SA_APPLICATION application = null;
        string currid = Request["id"] ?? "";
        if (!string.IsNullOrEmpty(currid.ToString().Trim())) //approve request
        {
            Int32 _id = 0;
            Int32.TryParse(currid.ToString().Trim(), out _id);
            application = MyAdminBusinessLogic.getApplicationByID(_id);
            IList<SA_APPLICATION2COMPANY> a2clist = application.SA_APPLICATION2COMPANY.ToList();
            foreach (SA_APPLICATION2COMPANY item in a2clist)
            {
                List<SA_BAPIADDR1> _BAPIADDR1 = item.SA_BAPIADDR1.ToList();
                foreach (SA_BAPIADDR1 adrr1 in _BAPIADDR1) MyAdminContext.Current.SA_BAPIADDR1.Remove(adrr1);
                List<SA_BAPIADDR2> _BAPIADDR2 = item.SA_BAPIADDR2.ToList();
                foreach (SA_BAPIADDR2 adrr2 in _BAPIADDR2) MyAdminContext.Current.SA_BAPIADDR2.Remove(adrr2);
                List<SA_FKNBK> _FKNBK = item.SA_FKNBK.ToList();
                foreach (SA_FKNBK fknbk in _FKNBK) MyAdminContext.Current.SA_FKNBK.Remove(fknbk);
                List<SA_FKNVI> _FKNVI = item.SA_FKNVI.ToList();
                foreach (SA_FKNVI fknvi in _FKNVI) MyAdminContext.Current.SA_FKNVI.Remove(fknvi);
                List<SA_KNA1> _KNA1 = item.SA_KNA1.ToList();
                foreach (SA_KNA1 kna1 in _KNA1) MyAdminContext.Current.SA_KNA1.Remove(kna1);
                List<SA_KNB1> _KNB1 = item.SA_KNB1.ToList();
                foreach (SA_KNB1 knb1 in _KNB1) MyAdminContext.Current.SA_KNB1.Remove(knb1);
                List<SA_KNVV> _KNVV = item.SA_KNVV.ToList();
                foreach (SA_KNVV knvv in _KNVV) MyAdminContext.Current.SA_KNVV.Remove(knvv);
                MyAdminContext.Current.SA_APPLICATION2COMPANY.Remove(item);
            }
        }
        else //create new request
        {
            application = new SA_APPLICATION();
            application.AplicationNO = GetApplicationNO();
            application.REQUEST_BY = User.Identity.Name;
            application.STATUS = (int)AccountWorkFlowStatus.NewRequest;
            application.REQUEST_DATE = DateTime.Now;
            //   application.COMMENT = Request["ctl00$_main$TBComment"] ?? "";
            application.APPROVED_BY = " ";
            application.APPROVED_DATE = DateTime.Now;
            application.REJECTED_BY = " ";
            application.REJECTED_DATE = DateTime.Now;
            application.LAST_UPD_BY = " ";
            application.LAST_UPD_DATE = DateTime.Now;
            application.WFInstanceID = " ";
            application.CompanyDescription = " ";
        }
        //sold to
        CreateSoldTo(application);

        //ship to
        string HasShipto = Request["HasShipto"] ?? "0";
        if (HasShipto == "1")
        {
            CreateShipTo(application);
        }

        //bill to
        string HasBilling = Request["HasBilling"] ?? "0";
        if (HasBilling == "1")
        {
            CreateBillTo(application);
        }

        Hashtable ht = new Hashtable();
        try
        {
            if (!string.IsNullOrEmpty(currid.ToString().Trim()))
            {
                application.Update();
            }
            else
            {
                application.Add();
                NewSAPCustomerFlow.Common.CallFlow(application.ID.ToString());
            }
            string Fappid = Request["ctl00$_main$HidRowid"] ?? "";
            if (!string.IsNullOrEmpty(Fappid))
            {
                MyAdminContext.Current.Database.ExecuteSqlCommand(string.Format("update SA_Files set AppID='{0}' where AppID='{1}'", application.ID, Fappid));
            }
            ht["type"] = 1;
            string AlertStr = "Your new SAP account application is successfully submitted.  Once the application is approved, system will inform you via email.";
            ht["msg"] = AlertStr;
        }
        catch (Exception ex)
        {
            ht["type"] = 0;
            ht["msg"] = "Failed!  " + ex.ToString();
        }

        if (!string.IsNullOrEmpty(currid)) return; //approve request don't return json string
        string strjson = Newtonsoft.Json.JsonConvert.SerializeObject(ht);
        Response.Write(strjson);
        Response.End();
    }
    private bool IsATW()
    {
        string CountryCode = Request["ctl00$_main$dlCountry"] ?? "";
        if(string.Equals(CountryCode,"TW",StringComparison.InvariantCultureIgnoreCase))
        {
            return true;
        }
        return false;
    }
    private void CreateSoldTo(SA_APPLICATION application)
    {
        string SalesOrg = Request["ctl00$_main$SalesOrg"] ?? "";
        string CompanyName = Request["ctl00$_main$txtCompanyName"] ?? "";
        string TBsiebelAccountID = Request["ctl00$_main$TBsiebelAccountID"] ?? "";
        string DUNSNumber = Request["DUNSNumber"] ?? "";
        string DBPaymentIndex = Request["DBPaymentIndex"] ?? "";
        string PriceGrade = Request["PriceGrade"] ?? "";
        string PaymentTerm = Request["PaymentTerm"] ?? "";
        string CustomerGroup = Request["CustomerGroup"] ?? "";
        string LegalForm = Request["LegalForm"] ?? "";
        string VAT = Request["ctl00$_main$txtVAT"] ?? "";
        string WebsiteUrl = Request["ctl00$_main$txtWebsiteUrl"] ?? "";
        string Addr1 = Request["ctl00$_main$txtAddr1"] ?? "";
        string Addr2 = Request["ctl00$_main$txtAddr2"] ?? "";
        string Addr3 = Request["ctl00$_main$txtAddr3"] ?? "";
        string PostCode = Request["ctl00$_main$txtPostCode"] ?? "";
        string City = Request["ctl00$_main$txtCity"] ?? "";
        string _dlCustomerGroup = Request["ctl00$_main$dlCustomerGroup"] ?? "";
        //dropdownlist
        string CountryCode = Request["ctl00$_main$dlCountry"] ?? "";
        string Currency = Request["ctl00$_main$dlCurr"] ?? "";
        string ShippingCondition = Request["ctl00$_main$dlShipCond"] ?? "";
        string Inco1 = Request["ctl00$_main$dlInco1"] ?? "";
        string SalesOffice = Request["ctl00$_main$dlSalesOffice"] ?? "";
        string Sales = Request["ctl00$_main$dlSalesCode"] ?? "";
        //string InsideSales = Request["ctl00$_main$dlISCode"] ?? "";
        string OP = Request["ctl00$_main$dlOPCode"] ?? "";
        //string CustomerType = Request["ctl00$_main$dlCustomerType"] ?? "";//No use
        string VerticalM = Request["ctl00$_main$dlVM"] ?? "";//No use
        string dlPaymentTerm = Request["ctl00$_main$dlPaymentTerm"] ?? "";
        string Tel = Request["ctl00$_main$txtTel"] ?? "";
        string Fax = Request["ctl00$_main$txtFax"] ?? "";

        string ContactName = Request["ctl00$_main$txtContactName"] ?? "";//Ship to & bill to才用的到
        string ContactEmail = Request["ctl00$_main$txtContactEmail"] ?? "";
        string Inco2 = Request["ctl00$_main$txtInco2"] ?? "";

        string dlShipCond = Request["ctl00$_main$dlShipCond"] ?? "";

        string dlSalesCode = Request["ctl00$_main$dlSalesCode"] ?? "";
        //string InsideSalesCode = Request["ctl00$_main$dlISCode"] ?? "";
        string OPCode = Request["ctl00$_main$dlOPCode"] ?? "";
        string SalesGroup = Request["ctl00$_main$dlSalesGroup"] ?? "";
        string VerticalMarketDefinition = Request["ctl00$_main$dlVM"] ?? "";
        string Industrycode1 = Request["Industrycode1"] ?? "";
        string Industrycode2 = Request["Industrycode2"] ?? "";
        string CompanyDescription = Request["CompanyDescription"] ?? "";
        string SearchTerm1 = Request["ctl00$_main$TBSearchTerm1"] ?? "";
        string SearchTerm2 = Request["ctl00$_main$TBSearchTerm2"] ?? "";
        string CreditAmount = Request["CreditAmount"] ?? "";
        application.CompanyDescription = CompanyDescription;

        LegalForm = Request["LegalForm"] ?? "";
      

        SA_APPLICATION2COMPANY a2c = new SA_APPLICATION2COMPANY();
        a2c.CompanyID = string.Empty;
        a2c.CompanyType = (int)companyType.SholdTo;
        a2c.SalesCode = dlSalesCode;
        a2c.CustomerGroup = _dlCustomerGroup;
        //a2c.InsideSalesCode = InsideSalesCode;
        a2c.OPCode = OPCode;
        a2c.CustomerType = "";
        a2c.VerticalMarketDefinition = VerticalMarketDefinition;
        a2c.OfficialRegistrationNo = LegalForm.Trim();
        a2c.PriceGrade = PriceGrade;
        a2c.DUNSNumber = DUNSNumber;
        a2c.DBPaymentIndex = DBPaymentIndex;
        if (string.IsNullOrEmpty(TBsiebelAccountID.Trim()))
        {
            a2c.IsExistSiebel = false;
            a2c.AccountRowID = string.Empty;
        }
        else
        {
            a2c.IsExistSiebel = true;
            a2c.AccountRowID = TBsiebelAccountID.Trim();
        }
        a2c.IsExistSAP = false;

        SA_FKNVI fknvi1 = new SA_FKNVI();
        fknvi1.Tatyp = "UTXJ";         fknvi1.Aland = "US";         fknvi1.Kunnr = string.Empty;         fknvi1.Mandt = "168";         fknvi1.Taxkd = "0";

        SA_FKNVI fknvi2 = new SA_FKNVI();
        fknvi2.Tatyp = "MWST";         fknvi2.Aland = CountryCode;         fknvi2.Kunnr = string.Empty;         fknvi2.Taxkd = dlTAXID.SelectedValue; 


        SA_BAPIADDR1 addr1 = new SA_BAPIADDR1();
        addr1.Langu = "EN";         addr1.Comm_Type = "INT";         addr1.Homepage = WebsiteUrl;         addr1.Fax_Number = Fax;         addr1.Tel1_Numbr = Tel;
        addr1.Transpzone = "0000000001";
        string cn = CompanyName.Trim().ToUpper();

        if (cn.Length <= 40)
        {
            addr1.Name = cn;
        }
        else if (40 < cn.Length && cn.Length <= 80)
        {
            addr1.Name = cn.Substring(0, 40);
            addr1.Name_2 = cn.Substring(40);
        }
        else if (80 < cn.Length && cn.Length <= 120)
        {
            addr1.Name = cn.Substring(0, 40);
            addr1.Name_2 = cn.Substring(40, 80);
            addr1.Name_3 = cn.Substring(80);
        }
        else if (120 < cn.Length)
        {
            addr1.Name = cn.Substring(0, 40);
            addr1.Name_2 = cn.Substring(40, 80);
            addr1.Name_3 = cn.Substring(80, 120);
            addr1.Name_4 = cn.Substring(120);
        }

        addr1.Title = "Company";
        addr1.Country = CountryCode;//
        //string address = (Addr1 + "|" + Addr2 + "|" + Addr3).Trim().ToUpper();
        //string[] p = address.Split('|');
        //addr1.Street = p[0];
        //addr1.Str_Suppl3 = p[1];
        //if (p.Length >= 3)
        //{
        //    addr1.Location = p[2];
        //}
        //if (p.Length >= 4)
        //{
        //    addr1.Str_Suppl1 = p[3];
        //}
        //if (p.Length >= 5)
        //{
        //    addr1.Str_Suppl2 = p[4];
        //}


        addr1.Street = Addr1;
        addr1.Str_Suppl3 = Addr2;
        addr1.Location = Addr3;
        addr1.Postl_Cod1 = PostCode.Trim().ToUpper();
        addr1.Addr_No = string.Empty;
        addr1.City = City.Trim().ToUpper();
        addr1.C_O_Name = ContactName.Trim().ToUpper();
        addr1.E_Mail = ContactEmail.Trim().ToUpper();
        addr1.Region = _Region;
        addr1.Sort1 = SearchTerm1;
        addr1.Sort2= SearchTerm2;
        addr1.Adr_Notes = CompanyDescription;
        SA_BAPIADDR2 addr2 = new SA_BAPIADDR2();
        addr2.Addr_No = string.Empty;
        addr2.Adr_Notes = CompanyDescription;
        SA_KNA1 kna1 = new SA_KNA1();
        kna1.Mandt = "168";
        kna1.Kunnr = string.Empty;
        kna1.Land1 = CountryCode;
        kna1.Name1 = CompanyName.Trim().ToUpper();
        kna1.Name2 = string.Empty;
        kna1.Ort01 = City.Trim().ToUpper();
        kna1.Pstlz = PostCode.Trim().ToUpper();
        kna1.Regio = string.Empty;
        kna1.Sortl = VAT.Trim().ToUpper();
        kna1.Stras = (Addr1 + "|" + Addr2 + "|" + Addr3).Trim().ToUpper();
        kna1.Telf1 = Tel;
        kna1.Telfx = Fax;
        kna1.Xcpdk = string.Empty;
        kna1.Mcod1 = CompanyName.Trim().ToUpper();
        kna1.Mcod2 = string.Empty;
        kna1.Mcod3 = (Addr1 + "|" + Addr2 + "|" + Addr3).Trim().ToUpper();
        kna1.Anred = "Company";
        kna1.Aufsd = " ";
        kna1.Bahne = " ";
        kna1.Bahns = " ";
        kna1.Begru = " ";
        kna1.Bbbnr = "0000000";
        kna1.Bbsnr = "00000";
        kna1.Bubkz = "0";
        kna1.Brsch = _Industry;
        kna1.Datlt = " ";
        kna1.Erdat = DateTime.Now.ToString("yyyyMMdd");
        kna1.Ernam = "B2BAEU";
        kna1.Exabl = " ";
        kna1.Faksd = " ";
        kna1.Fiskn = " ";
        kna1.Knazk = " ";
        kna1.Knrza = " ";
        kna1.Konzs = " ";
        kna1.Ktokd = "Z001";
        kna1.Kukla = "03";
        kna1.Lifnr = " ";
        kna1.Lifsd = " ";
        kna1.Locco = " ";
        kna1.Loevm = " ";
        kna1.Name3 = " ";
        kna1.Name4 = " ";
        kna1.Niels = " ";
        kna1.Ort02 = " ";
        kna1.Pfach = " ";
        kna1.Pstl2 = " ";
        kna1.Counc = " ";
        kna1.Cityc = " ";
        kna1.Rpmkr = " ";
        kna1.Sperr = " ";
        kna1.Spras = "E";
        kna1.Stcd1 = LegalForm.Trim();
        kna1.Stcd2 = " ";
        kna1.Stkza = " ";
        kna1.Stkzu = " ";
        kna1.Telbx = " ";
        kna1.Telf2 = " ";
        kna1.Teltx = " ";
        kna1.Telx1 = " ";
        kna1.Lzone = "0000000001";
        kna1.Xzemp = " ";
        kna1.Stceg = VAT;
        kna1.Dear1 = " ";
        kna1.Dear2 = " ";
        kna1.Dear3 = " ";
        kna1.Dear4 = " ";
        kna1.Dear5 = " ";
        kna1.Gform = " ";
        kna1.Bran1 = Industrycode1;
        kna1.Bran2 = Industrycode2;
        kna1.Bran3 = " ";
        kna1.Bran4 = " ";
        kna1.Bran5 = " ";
        kna1.Ekont = " ";
        kna1.Umsat = "0";
        kna1.Umjah = "0000";
        kna1.Uwaer = " ";
        kna1.Jmzah = "000000";
        kna1.Jmjah = "0000";
        kna1.Katr1 = string.Empty;// Not sure
        kna1.Katr2 = string.Empty;//Not sure
        kna1.Katr3 = string.Empty;
        if (SalesOffice.Trim() == "1100")  
            kna1.Katr2 = "19";
        else kna1.Katr2 = "13";

        kna1.Katr4 = "";//??
        kna1.Katr5 = "";//??
        kna1.Katr6 = "";//??
        kna1.Katr7 = "";//??
        kna1.Katr8 = "";//??
        kna1.Katr9 = "";//??
        kna1.Katr10 = "";
        kna1.Stkzn = " ";
        kna1.Umsa1 = "0";
        kna1.Txjcd = " ";
        kna1.Periv = " ";
        kna1.Abrvw = " ";
        kna1.Inspbydebi = " ";
        kna1.Inspatdebi = " ";
        kna1.Ktocd = " ";
        kna1.Pfort = " ";
        kna1.Werks = " ";
        kna1.Dtams = " ";
        kna1.Dtaws = " ";
        kna1.Duefl = "X";
        kna1.Hzuor = "00";
        kna1.Sperz = " ";
        kna1.Etikg = " ";
        kna1.Civve = "X";
        kna1.Milve = " ";

        if (!string.IsNullOrEmpty(PriceGrade) && PriceGrade.Length ==8)
        {
            kna1.Kdkg1 = PriceGrade.Substring(0,2);
            kna1.Kdkg2 = PriceGrade.Substring(2, 2);
            kna1.Kdkg3 = PriceGrade.Substring(4, 2);
            kna1.Kdkg4 = PriceGrade.Substring(6, 2);
            kna1.Kdkg5 = "R4"; //This one is for RMA and is always a fixed value R4
        }
        else
        {
            kna1.Kdkg1 = "C3"; kna1.Kdkg2 = "C3"; kna1.Kdkg3 = "C3"; kna1.Kdkg4 = "C3"; kna1.Kdkg5 = "R4";
        }

        kna1.Xknza = " "; kna1.Fityp = " "; kna1.Stcdt = " "; kna1.Stcd3 = " "; kna1.Stcd4 = " "; kna1.Xicms = " "; kna1.Xxipi = " ";
        kna1.Xsubt = " "; kna1.Cfopc = " "; kna1.Txlw1 = " "; kna1.Txlw2 = " "; kna1.Ccc01 = " "; kna1.Ccc02 = " ";
        kna1.Ccc03 = " ";      kna1.Ccc04 = " ";        kna1.Cassd = " ";
        kna1.Knurl = WebsiteUrl;
        kna1.J_1kfrepre = " ";        kna1.J_1kftbus = " ";        kna1.J_1kftind = " ";
        kna1.Confs = " ";        kna1.Updat = "00000000";        kna1.Uptim = "000000";
        kna1.Nodel = " ";        kna1.Dear6 = " ";        kna1.Alc = " ";        kna1.Pmt_Office = " ";
        kna1.Psofg = " ";        kna1.Psois = " ";        kna1.Pson1 = " ";        kna1.Pson2 = " ";
        kna1.Pson3 = " ";        kna1.Psovn = " ";        kna1.Psotl = " ";        kna1.Psohs = " ";
        kna1.Psost = " ";        kna1.Psoo1 = " ";        kna1.Psoo2 = " ";        kna1.Psoo3 = " ";
        kna1.Psoo4 = " ";        kna1.Psoo5 = " ";
        SA_KNB1 knb1 = new SA_KNB1();
        knb1.Mandt = "168";
        knb1.Kunnr = string.Empty;
        knb1.Bukrs = dlOrgID.SelectedValue;
        knb1.Pernr = "00000000";
        knb1.Erdat = DateTime.Now.ToString("yyyyMMdd");
        knb1.Ernam = "B2BAEU";
        knb1.Sperr = " ";
        knb1.Loevm = " ";
        knb1.Zuawa = "001";
        knb1.Busab = "EI";//??? 看credit
        //knb1.Akont = "";//??? 看credit
        knb1.Vlibb = "";//??? 看credit
        knb1.Fdgrv = "";//??? 看credit
        knb1.Vrsnr = "";//信用额度
        decimal outCA = 0;
        if (decimal.TryParse(CreditAmount, out outCA))
        {
            knb1.Vrsnr = (outCA*30).ToString();
        }
        knb1.Begru = " ";        knb1.Knrze = " ";        knb1.Knrzb = " ";        knb1.Zamim = " ";        knb1.Zamiv = " ";        knb1.Zamir = " ";
        knb1.Zamib = " ";        knb1.Zamio = " ";        knb1.Zwels = " ";        knb1.Xverr = " ";        knb1.Zahls = " ";
        knb1.Zterm = dlPaymentTerm;
        knb1.Wakon = " ";        knb1.Vzskz = " ";        knb1.Zindt = "00000000";        knb1.Zinrt = "00";
        knb1.Eikto = " ";        knb1.Zsabe = " ";        knb1.Kverm = " ";        knb1.Vrbkz = " ";        knb1.Vrszl = "0";
        knb1.Vrspr = "0";        knb1.Verdt = "00000000";        knb1.Perkz = " ";        knb1.Xdezv = " ";        knb1.Xausz = " ";
        knb1.Webtr = " ";        knb1.Remit = " ";        knb1.Datlz = "00000000";        knb1.Xzver = "X";        knb1.Togru = " ";
        knb1.Kultg = "0";        knb1.Hbkid = " ";        knb1.Xpore = " ";        knb1.Blnkz = " ";        knb1.Altkn = " ";
        knb1.Zgrup = " ";        knb1.Urlid = " ";        knb1.Mgrup = "01";        knb1.Lockb = " ";        knb1.Uzawe = " ";
        knb1.Ekvbd = " ";        knb1.Sregl = " ";        knb1.Xedip = " ";        knb1.Frgrp = " ";        knb1.Vrsdg = " ";
        knb1.Tlfxs = " ";        knb1.Intad = " ";        knb1.Xknzb = " ";        knb1.Guzte = " ";        knb1.Gricd = " ";
        knb1.Gridt = " ";        knb1.Wbrsl = " ";        knb1.Confs = " ";        knb1.Updat = "00000000";        knb1.Uptim = "000000";
        knb1.Nodel = " ";        knb1.Tlfns = " ";        knb1.Cession_Kz = " ";        knb1.Gmvkzd = " ";
        //knb1.Akont = "'0000121001' ";//hard code
        knb1.Fdgrv = "A1";//hard code
        knb1.Akont = "01";

        //KNVV
        SA_KNVV knvv = new SA_KNVV();
        knvv.Mandt = "168";        knvv.Kunnr = string.Empty;        knvv.Vkorg = dlOrgID.SelectedValue;//EU10        knvv.Vtweg = "00";
        knvv.Spart = "00";        knvv.Ernam = "B2BAEU";        knvv.Erdat = DateTime.Now.ToString("yyyyMMdd");
        knvv.Begru = " ";        knvv.Loevm = " ";        knvv.Versg = " ";        knvv.Aufsd = " ";
        knvv.Kalks = "1";
        //
        knvv.Kdgrp = _dlCustomerGroup;//??????????????
        knvv.Bzirk = "";//??????????????
        //
        knvv.Konda = "00";         knvv.Pltyp = "00";        knvv.Awahr = "100";
        knvv.Inco1 = Inco1;//???
        knvv.Inco2 = Inco2.Trim().ToUpper();

        knvv.Lifsd = " ";        knvv.Autlf = "9";        knvv.Chspl = " ";        knvv.Lprio = " ";        knvv.Eikto = " ";
        //knvv.Vsbed = "";//??? Shippingcondition
        knvv.Faksd = " ";        knvv.Mrnkz = " ";        knvv.Perfk = " ";        knvv.Perrl = " ";        knvv.Kvakz = " ";
        knvv.Kvawt = "0";        knvv.Waers = Currency;        knvv.Klabc = " ";        //knvv.Ktgrd = "";//AAG
        //knvv.Zterm = "";//strCreditTerm
        //knvv.Vwerk = "";//strPlant
        //knvv.Vkgrp = "";//SalesGroup
        //knvv.Vkbur = SalesOffice;
        knvv.Vsort = " ";        knvv.Kvgr1 = " ";        knvv.Kvgr2 = " ";        knvv.Kvgr3 = "D0";        knvv.Kvgr4 = " ";
        knvv.Kvgr5 = " ";        knvv.Bokre = " ";        knvv.Boidt = "00000000";        knvv.Kurst = " ";        knvv.Prfre = " ";
        knvv.Prat1 = " ";        knvv.Prat2 = " ";        knvv.Prat3 = " ";        knvv.Prat4 = " ";        knvv.Prat5 = " ";
        knvv.Prat6 = " ";        knvv.Prat7 = " ";        knvv.Prat8 = " ";        knvv.Prat9 = " ";        knvv.Prata = " ";
        knvv.Kabss = " ";        knvv.Kkber = " ";        knvv.Cassd = " ";        knvv.Rdoff = " ";        knvv.Agrel = " ";
        knvv.Megru = " ";        knvv.Uebto = "0";        knvv.Untto = "0";        knvv.Uebtk = " ";        knvv.Pvksm = " ";
        knvv.Podkz = " ";        knvv.Podtg = "0";        knvv.Blind = " ";        knvv.Bev1_Emlgforts = " ";        knvv.Bev1_Emlgpfand = " ";
        knvv.Antlf = "9";        knvv.Kdgrp = _dlCustomerGroup;        knvv.Vsbed = dlShipCond;
        if (IsATW())
        { 
            knvv.Ktgrd = "01"; 
        }
        else
        {
            knvv.Ktgrd = "02";
        }
        knvv.Zterm = dlPaymentTerm;
        //knvv.Vwerk = "TWH1";
        knvv.Vwerk = "";
        knvv.Vkgrp = SalesGroup;        knvv.Vkbur = SalesOffice;
        //  knvv.Vkbur = dlCustomerGroup;
        SA_FKNBK fknbk = new SA_FKNBK();

        //Add sold to data
        a2c.SA_BAPIADDR1.Add(addr1);
        a2c.SA_BAPIADDR2.Add(addr2);
        a2c.SA_FKNBK.Add(fknbk);
        a2c.SA_FKNVI.Add(fknvi1);
        a2c.SA_FKNVI.Add(fknvi2);
        a2c.SA_KNA1.Add(kna1);
        a2c.SA_KNB1.Add(knb1);
        a2c.SA_KNVV.Add(knvv);

        application.SA_APPLICATION2COMPANY.Add(a2c);
    }

    private void CreateShipTo(SA_APPLICATION application)
    {
        string ShiptoCompanyName = Request["ctl00$_main$txtShiptoCompanyName"] ?? "";
        string ShiptoVAT = Request["ctl00$_main$txtShiptoVATNumber"] ?? "";
        string ShiptoAddr1 = Request["ctl00$_main$txtShiptoAddress"] ?? "";
        string ShiptoAddr2 = Request["ctl00$_main$txtShiptoAddress2"] ?? "";
        string ShiptoAddr3 = Request["ctl00$_main$txtShiptoAddress3"] ?? "";
        string ShiptoPostCode = Request["ctl00$_main$txtShiptoPostcode"] ?? "";
        string ShiptoCity = Request["ctl00$_main$txtShiptoCity"] ?? "";
        string ShiptoCountryCode = Request["ctl00$_main$dlShiptoCountry"] ?? "";
        string ShiptoCountryCodeX = string.Empty;
        string ShiptoTel = Request["ctl00$_main$txtShiptoTel"] ?? "";
        string ShiptoFax = Request["ctl00$_main$txtShiptoFax"] ?? "";
        string ShiptoContactName = Request["ctl00$_main$txtShiptoContactName"] ?? "";
        string ShiptoContactEmail = Request["ctl00$_main$txtShiptoContactEmail"] ?? "";
         PriceGrade = Request["PriceGrade"] ?? "";
        string WebsiteUrl = Request["ctl00$_main$txtWebsiteUrl"] ?? "";
        string LegalForm = Request["LegalForm"] ?? "";
        string Tel = Request["ctl00$_main$txtTel"] ?? "";
        string Fax = Request["ctl00$_main$txtFax"] ?? "";
        string SalesOffice = Request["ctl00$_main$dlSalesOffice"] ?? "";
        string SalesGroup= Request["ctl00$_main$dlSalesGroup"] ?? "";
        string Inco2 = Request["ctl00$_main$txtInco2"] ?? "";
        string Currency = Request["ctl00$_main$dlCurr"] ?? "";
        string SalesCode = Request["ctl00$_main$dlSalesCode"] ?? "";
        //string InsideSales = Request["ctl00$_main$dlISCode"] ?? "";
        string Inco1 = Request["ctl00$_main$dlInco1"] ?? "";
        string SearchTerm1 = Request["ctl00$_main$TBSearchTerm1"]??"";
        string SearchTerm2 = Request["ctl00$_main$TBSearchTerm2"] ?? "";
        string _dlCustomerGroup = Request["ctl00$_main$dlCustomerGroup"] ?? "";
        string dlPaymentTerm = Request["ctl00$_main$dlPaymentTerm"] ?? "";

        SA_APPLICATION2COMPANY a2c = new SA_APPLICATION2COMPANY();
        a2c.CompanyID = string.Empty;
        a2c.CompanyType = (int)companyType.ShipTo;

        SA_FKNVI shipFKNVI1 = new SA_FKNVI();
        shipFKNVI1.Tatyp = "MWST";
        shipFKNVI1.Aland = "US";
        shipFKNVI1.Kunnr = string.Empty;
        shipFKNVI1.Mandt = "168";
        shipFKNVI1.Taxkd = "0";

        SA_FKNVI shipFKNVI2 = new SA_FKNVI();
        shipFKNVI2.Tatyp = "MWST";
        shipFKNVI2.Aland = dlShiptoCountry.SelectedValue;
        shipFKNVI2.Kunnr = string.Empty;
        shipFKNVI2.Mandt = "168";
        shipFKNVI2.Taxkd = dlShipToTaxId.SelectedValue;
        //if (ShiptoCountryCode == "TW")
        //{ shipFKNVI2.Taxkd = "3"; }
        //else
        //{ shipFKNVI2.Taxkd = "4"; }

        SA_BAPIADDR1 shipAddr1 = new SA_BAPIADDR1();
        shipAddr1.Langu = "EN";
        shipAddr1.Comm_Type = "INT";
        shipAddr1.Homepage = WebsiteUrl;
        shipAddr1.Fax_Number = ShiptoFax;
        shipAddr1.Tel1_Numbr = ShiptoTel;
        shipAddr1.Transpzone = "0000000001";
        string cn = ShiptoCompanyName.Trim().ToUpper();
        if (!string.IsNullOrEmpty(LegalForm.Trim()))
        {
            cn += " " + LegalForm.Trim();
        }
        if (cn.Length <= 40)
        {
            shipAddr1.Name = cn;
        }
        else if (40 < cn.Length && cn.Length <= 80)
        {
            shipAddr1.Name = cn.Substring(0, 40);
            shipAddr1.Name_2 = cn.Substring(40);
        }
        else if (80 < cn.Length && cn.Length <= 120)
        {
            shipAddr1.Name = cn.Substring(0, 40);
            shipAddr1.Name_2 = cn.Substring(40, 80);
            shipAddr1.Name_3 = cn.Substring(80);
        }
        else if (120 < cn.Length)
        {
            shipAddr1.Name = cn.Substring(0, 40);
            shipAddr1.Name_2 = cn.Substring(40, 80);
            shipAddr1.Name_3 = cn.Substring(80, 120);
            shipAddr1.Name_4 = cn.Substring(120);
        }
        shipAddr1.Title = "Company";
        shipAddr1.Country = ShiptoCountryCode;
        string address = (ShiptoAddr1 + "|" + ShiptoAddr2 + "|" + ShiptoAddr3).Trim().ToUpper();
        string[] sp = address.Split('|');
        shipAddr1.Street = sp[0];
        shipAddr1.Str_Suppl3 = sp[1];
        if (sp.Length >= 3)
        {
            shipAddr1.Location = sp[2];
        }
        if (sp.Length >= 4)
        {
            shipAddr1.Str_Suppl1 = sp[3];
        }
        if (sp.Length >= 5)
        {
            shipAddr1.Str_Suppl2 = sp[4];
        }
        shipAddr1.Postl_Cod1 = ShiptoPostCode.Trim().ToUpper();
        shipAddr1.Addr_No = string.Empty;
        shipAddr1.City = ShiptoCity.Trim().ToUpper();
        shipAddr1.C_O_Name = ShiptoContactName.Trim().ToUpper();
        shipAddr1.E_Mail = ShiptoContactEmail.Trim().ToUpper();
        shipAddr1.Region = _Region;

        SA_BAPIADDR2 shipAddr2 = new SA_BAPIADDR2();
        shipAddr2.Addr_No = string.Empty;

        SA_KNA1 shiptoKNA1 = new SA_KNA1();
        shiptoKNA1.Mandt = "168";
        shiptoKNA1.Kunnr = string.Empty;
        shiptoKNA1.Land1 = ShiptoCountryCode;
        shiptoKNA1.Name1 = ShiptoCompanyName.Trim().ToUpper();
        shiptoKNA1.Name2 = string.Empty;
        shiptoKNA1.Ort01 = ShiptoCity.Trim().ToUpper();
        shiptoKNA1.Pstlz = ShiptoPostCode.Trim().ToUpper();
        shiptoKNA1.Regio = string.Empty;
        shiptoKNA1.Sortl = ShiptoVAT.Trim().ToUpper();
        shiptoKNA1.Stras = (ShiptoAddr1 + "|" + ShiptoAddr2 + "|" + ShiptoAddr3).Trim().ToUpper();
        shiptoKNA1.Telf1 = ShiptoTel;
        shiptoKNA1.Telfx = Fax;
        shiptoKNA1.Xcpdk = string.Empty;
        shiptoKNA1.Mcod1 = ShiptoCompanyName.Trim().ToUpper();
        shiptoKNA1.Mcod2 = string.Empty;
        shiptoKNA1.Mcod3 = (ShiptoAddr1 + "|" + ShiptoAddr2 + "|" + ShiptoAddr3).Trim().ToUpper();
        shiptoKNA1.Anred = "Company";
        shiptoKNA1.Aufsd = " ";
        shiptoKNA1.Bahne = " ";
        shiptoKNA1.Bahns = " ";
        shiptoKNA1.Begru = " ";
        shiptoKNA1.Bbbnr = "0000000";
        shiptoKNA1.Bbsnr = "00000";
        shiptoKNA1.Bubkz = "0";
        shiptoKNA1.Brsch = _Industry;
        shiptoKNA1.Datlt = " ";
        shiptoKNA1.Erdat = DateTime.Now.ToString("yyyyMMdd");
        shiptoKNA1.Ernam = "B2BAEU";
        shiptoKNA1.Exabl = " ";
        shiptoKNA1.Faksd = " ";
        shiptoKNA1.Fiskn = " ";
        shiptoKNA1.Knazk = " ";
        shiptoKNA1.Knrza = " ";
        shiptoKNA1.Konzs = " ";
        shiptoKNA1.Ktokd = "Z001";
        shiptoKNA1.Kukla = "03";
        shiptoKNA1.Lifnr = " ";
        shiptoKNA1.Lifsd = " ";
        shiptoKNA1.Locco = " ";
        shiptoKNA1.Loevm = " ";
        shiptoKNA1.Name3 = " ";
        shiptoKNA1.Name4 = " ";
        shiptoKNA1.Niels = " ";
        shiptoKNA1.Ort02 = " ";
        shiptoKNA1.Pfach = " ";
        shiptoKNA1.Pstl2 = " ";
        shiptoKNA1.Counc = " ";
        shiptoKNA1.Cityc = " ";
        shiptoKNA1.Rpmkr = " ";
        shiptoKNA1.Sperr = " ";
        shiptoKNA1.Spras = "E";
        shiptoKNA1.Stcd1 = " ";
        shiptoKNA1.Stcd2 = " ";
        shiptoKNA1.Stkza = " ";
        shiptoKNA1.Stkzu = " ";
        shiptoKNA1.Telbx = " ";
        shiptoKNA1.Telf2 = " ";
        shiptoKNA1.Teltx = " ";
        shiptoKNA1.Telx1 = " ";
        shiptoKNA1.Lzone = "0000000001";
        shiptoKNA1.Xzemp = " ";
        shiptoKNA1.Stceg = ShiptoVAT;
        shiptoKNA1.Dear1 = " ";
        shiptoKNA1.Dear2 = " ";
        shiptoKNA1.Dear3 = " ";
        shiptoKNA1.Dear4 = " ";
        shiptoKNA1.Dear5 = " ";
        shiptoKNA1.Gform = " ";
        shiptoKNA1.Bran1 = " ";
        shiptoKNA1.Bran2 = " ";
        shiptoKNA1.Bran3 = " ";
        shiptoKNA1.Bran4 = " ";
        shiptoKNA1.Bran5 = " ";
        shiptoKNA1.Ekont = " ";
        shiptoKNA1.Umsat = "0";
        shiptoKNA1.Umjah = "0000";
        shiptoKNA1.Uwaer = " ";
        shiptoKNA1.Jmzah = "000000";
        shiptoKNA1.Jmjah = "0000";
        shiptoKNA1.Katr1 = string.Empty;// Not sure
        shiptoKNA1.Katr2 = string.Empty;//Not sure
        shiptoKNA1.Katr3 = string.Empty;

        if (SalesOffice.Trim() == "1100")
            shiptoKNA1.Katr2 = "19";
        else shiptoKNA1.Katr2 = "13";

        shiptoKNA1.Katr4 = "";//??
        shiptoKNA1.Katr5 = "";//??
        shiptoKNA1.Katr6 = "";//??
        shiptoKNA1.Katr7 = "";//??
        shiptoKNA1.Katr8 = "";//??
        shiptoKNA1.Katr9 = "";//??
        shiptoKNA1.Katr10 = "";
        shiptoKNA1.Stkzn = " ";
        shiptoKNA1.Umsa1 = "0";
        shiptoKNA1.Txjcd = " ";
        shiptoKNA1.Periv = " ";
        shiptoKNA1.Abrvw = " ";
        shiptoKNA1.Inspbydebi = " ";
        shiptoKNA1.Inspatdebi = " ";
        shiptoKNA1.Ktocd = " ";
        shiptoKNA1.Pfort = " ";
        shiptoKNA1.Werks = " ";
        shiptoKNA1.Dtams = " ";
        shiptoKNA1.Dtaws = " ";
        shiptoKNA1.Duefl = "X";
        shiptoKNA1.Hzuor = "00";
        shiptoKNA1.Sperz = " ";
        shiptoKNA1.Etikg = " ";
        shiptoKNA1.Civve = "X";
        shiptoKNA1.Milve = " ";

        if (!string.IsNullOrEmpty(PriceGrade) && PriceGrade.Length == 8)
        {
            shiptoKNA1.Kdkg1 = PriceGrade.Substring(0, 2);
            shiptoKNA1.Kdkg2 = PriceGrade.Substring(2, 2);
            shiptoKNA1.Kdkg3 = PriceGrade.Substring(4, 2);
            shiptoKNA1.Kdkg4 = PriceGrade.Substring(6, 2);
            shiptoKNA1.Kdkg5 = PriceGrade.Substring(0, 2); 
        }
        else {
            shiptoKNA1.Kdkg1 = "L0";
            shiptoKNA1.Kdkg2 = "L0";
            shiptoKNA1.Kdkg3 = "L0";
            shiptoKNA1.Kdkg4 = "L0";
            shiptoKNA1.Kdkg5 = "R4"; 
        }
   
        shiptoKNA1.Xknza = " ";
        shiptoKNA1.Fityp = " ";
        shiptoKNA1.Stcdt = " ";
        shiptoKNA1.Stcd3 = " ";
        shiptoKNA1.Stcd4 = " ";
        shiptoKNA1.Xicms = " ";
        shiptoKNA1.Xxipi = " ";
        shiptoKNA1.Xsubt = " ";
        shiptoKNA1.Cfopc = " ";
        shiptoKNA1.Txlw1 = " ";
        shiptoKNA1.Txlw2 = " ";
        shiptoKNA1.Ccc01 = " ";
        shiptoKNA1.Ccc02 = " ";
        shiptoKNA1.Ccc03 = " ";
        shiptoKNA1.Ccc04 = " ";
        shiptoKNA1.Cassd = " ";
        shiptoKNA1.Knurl = WebsiteUrl;
        shiptoKNA1.J_1kfrepre = " ";
        shiptoKNA1.J_1kftbus = " ";
        shiptoKNA1.J_1kftind = " ";
        shiptoKNA1.Confs = " ";
        shiptoKNA1.Updat = "00000000";
        shiptoKNA1.Uptim = "000000";
        shiptoKNA1.Nodel = " ";
        shiptoKNA1.Dear6 = " ";
        shiptoKNA1.Alc = " ";
        shiptoKNA1.Pmt_Office = " ";
        shiptoKNA1.Psofg = " ";
        shiptoKNA1.Psois = " ";
        shiptoKNA1.Pson1 = " ";
        shiptoKNA1.Pson2 = " ";
        shiptoKNA1.Pson3 = " ";
        shiptoKNA1.Psovn = " ";
        shiptoKNA1.Psotl = " ";
        shiptoKNA1.Psohs = " ";
        shiptoKNA1.Psost = " ";
        shiptoKNA1.Psoo1 = " ";
        shiptoKNA1.Psoo2 = " ";
        shiptoKNA1.Psoo3 = " ";
        shiptoKNA1.Psoo4 = " ";
        shiptoKNA1.Psoo5 = " ";

        SA_KNB1 shiptoKNB1 = new SA_KNB1();
        shiptoKNB1.Mandt = "168";
        shiptoKNB1.Kunnr = string.Empty;
        shiptoKNB1.Bukrs = "TW01";//EU10
        shiptoKNB1.Pernr = "00000000";
        shiptoKNB1.Erdat = DateTime.Now.ToString("yyyyMMdd");
        shiptoKNB1.Ernam = "B2BAEU";
        shiptoKNB1.Sperr = " ";
        shiptoKNB1.Loevm = " ";
        shiptoKNB1.Zuawa = "001";
        shiptoKNB1.Busab = "EI";//??? 看credit
        //shiptoKNB1.Akont = "";//??? 看credit
        shiptoKNB1.Vlibb = "";//??? 看credit
        shiptoKNB1.Fdgrv = "";//??? 看credit
        shiptoKNB1.Vrsnr = "";//??? 看credit
        shiptoKNB1.Begru = " ";
        shiptoKNB1.Knrze = " ";
        shiptoKNB1.Knrzb = " ";
        shiptoKNB1.Zamim = " ";
        shiptoKNB1.Zamiv = " ";
        shiptoKNB1.Zamir = " ";
        shiptoKNB1.Zamib = " ";
        shiptoKNB1.Zamio = " ";
        shiptoKNB1.Zwels = " ";
        shiptoKNB1.Xverr = " ";
        shiptoKNB1.Zahls = " ";
        shiptoKNB1.Zterm = dlPaymentTerm;
        shiptoKNB1.Wakon = " ";
        shiptoKNB1.Vzskz = " ";
        shiptoKNB1.Zindt = "00000000";
        shiptoKNB1.Zinrt = "00";
        shiptoKNB1.Eikto = " ";
        shiptoKNB1.Zsabe = " ";
        shiptoKNB1.Kverm = " ";
        shiptoKNB1.Vrbkz = " ";
        shiptoKNB1.Vrszl = "0";
        shiptoKNB1.Vrspr = "0";
        shiptoKNB1.Verdt = "00000000";
        shiptoKNB1.Perkz = " ";
        shiptoKNB1.Xdezv = " ";
        shiptoKNB1.Xausz = " ";
        shiptoKNB1.Webtr = " ";
        shiptoKNB1.Remit = " ";
        shiptoKNB1.Datlz = "00000000";
        shiptoKNB1.Xzver = "X";
        shiptoKNB1.Togru = " ";
        shiptoKNB1.Kultg = "0";
        shiptoKNB1.Hbkid = " ";
        shiptoKNB1.Xpore = " ";
        shiptoKNB1.Blnkz = " ";
        shiptoKNB1.Altkn = " ";
        shiptoKNB1.Zgrup = " ";
        shiptoKNB1.Urlid = " ";
        shiptoKNB1.Mgrup = "01";
        shiptoKNB1.Lockb = " ";
        shiptoKNB1.Uzawe = " ";
        shiptoKNB1.Ekvbd = " ";
        shiptoKNB1.Sregl = " ";
        shiptoKNB1.Xedip = " ";
        shiptoKNB1.Frgrp = " ";
        shiptoKNB1.Vrsdg = " ";
        shiptoKNB1.Tlfxs = " ";
        shiptoKNB1.Intad = " ";
        shiptoKNB1.Xknzb = " ";
        shiptoKNB1.Guzte = " ";
        shiptoKNB1.Gricd = " ";
        shiptoKNB1.Gridt = " ";
        shiptoKNB1.Wbrsl = " ";
        shiptoKNB1.Confs = " ";
        shiptoKNB1.Updat = "00000000";
        shiptoKNB1.Uptim = "000000";
        shiptoKNB1.Nodel = " ";
        shiptoKNB1.Tlfns = " ";
        shiptoKNB1.Cession_Kz = " ";
        shiptoKNB1.Gmvkzd = " ";
        //knb1.Akont = "'0000121001' ";//hard code
        shiptoKNB1.Fdgrv = "A1";//hard code
        shiptoKNB1.Akont = "01";

        SA_KNVV shiptoKNVV = new SA_KNVV();
        shiptoKNVV.Mandt = "168";
        shiptoKNVV.Kunnr = string.Empty;
        shiptoKNVV.Vkorg = "TW01";//EU10
        shiptoKNVV.Vtweg = "00";
        shiptoKNVV.Spart = "00";
        shiptoKNVV.Ernam = "B2BAEU";
        shiptoKNVV.Erdat = DateTime.Now.ToString("yyyyMMdd");
        shiptoKNVV.Begru = " ";
        shiptoKNVV.Loevm = " ";
        shiptoKNVV.Versg = " ";
        shiptoKNVV.Aufsd = " ";
        shiptoKNVV.Kalks = "1";
        //
        //knvv.Kdgrp = "";//??????????????
        shiptoKNVV.Bzirk = "";//??????????????
        //
        shiptoKNVV.Konda = "00";
        shiptoKNVV.Pltyp = "00";
        shiptoKNVV.Awahr = "100";
        shiptoKNVV.Inco1 = Inco1.Trim().ToUpper();
        shiptoKNVV.Inco2 = Inco2.Trim().ToUpper();

        shiptoKNVV.Lifsd = " ";
        shiptoKNVV.Autlf = "9";//重複
        shiptoKNVV.Kztlf = " ";
        shiptoKNVV.Kzazu = "X";
        shiptoKNVV.Chspl = " ";
        shiptoKNVV.Lprio = " ";
        shiptoKNVV.Eikto = " ";
        //shiptoKNVV.Vsbed = "";//??? Shippingcondition
        shiptoKNVV.Faksd = " ";
        shiptoKNVV.Mrnkz = " ";
        shiptoKNVV.Perfk = " ";
        shiptoKNVV.Perrl = " ";
        shiptoKNVV.Kvakz = " ";
        shiptoKNVV.Kvawt = "0";
        shiptoKNVV.Waers = Currency;
        shiptoKNVV.Klabc = " ";
        //knvv.Ktgrd = "";//AAG
        //knvv.Zterm = "";//strCreditTerm
        //knvv.Vwerk = "";//strPlant
        //knvv.Vkgrp = "";//SalesGroup
        //knvv.Vkbur = SalesOffice;
        shiptoKNVV.Vsort = " ";
        shiptoKNVV.Kvgr1 = " ";
        shiptoKNVV.Kvgr2 = " ";
        shiptoKNVV.Kvgr3 = "D0";
        shiptoKNVV.Kvgr4 = " ";
        shiptoKNVV.Kvgr5 = " ";
        shiptoKNVV.Bokre = " ";
        shiptoKNVV.Boidt = "00000000";
        shiptoKNVV.Kurst = " ";
        shiptoKNVV.Prfre = " ";
        shiptoKNVV.Prat1 = " ";
        shiptoKNVV.Prat2 = " ";
        shiptoKNVV.Prat3 = " ";
        shiptoKNVV.Prat4 = " ";
        shiptoKNVV.Prat5 = " ";
        shiptoKNVV.Prat6 = " ";
        shiptoKNVV.Prat7 = " ";
        shiptoKNVV.Prat8 = " ";
        shiptoKNVV.Prat9 = " ";
        shiptoKNVV.Prata = " ";
        shiptoKNVV.Kabss = " ";
        shiptoKNVV.Kkber = " ";
        shiptoKNVV.Cassd = " ";
        shiptoKNVV.Rdoff = " ";
        shiptoKNVV.Agrel = " ";
        shiptoKNVV.Megru = " ";
        shiptoKNVV.Uebto = "0";
        shiptoKNVV.Untto = "0";
        shiptoKNVV.Uebtk = " ";
        shiptoKNVV.Pvksm = " ";
        shiptoKNVV.Podkz = " ";
        shiptoKNVV.Podtg = "0";
        shiptoKNVV.Blind = " ";
        shiptoKNVV.Bev1_Emlgforts = " ";
        shiptoKNVV.Bev1_Emlgpfand = " ";
        shiptoKNVV.Antlf = "9";
        shiptoKNVV.Kdgrp = _dlCustomerGroup;
        shiptoKNVV.Vsbed = "01";
        if (IsATW())
        {
            shiptoKNVV.Ktgrd = "01";
        }
        else
        {
            shiptoKNVV.Ktgrd = "02";
        }
        shiptoKNVV.Zterm = dlPaymentTerm;
        //shiptoKNVV.Vwerk = "TWH1";
        shiptoKNVV.Vwerk = "";
        shiptoKNVV.Vkgrp = SalesGroup;
        //shiptoKNVV.Vkbur = InsideSales;

        SA_FKNBK shiptoFKNBK = new SA_FKNBK();

        //Add ship to data
        a2c.SA_BAPIADDR1.Add(shipAddr1);
        a2c.SA_BAPIADDR2.Add(shipAddr2);
        a2c.SA_FKNBK.Add(shiptoFKNBK);
        a2c.SA_FKNVI.Add(shipFKNVI1);
        a2c.SA_FKNVI.Add(shipFKNVI2);
        a2c.SA_KNA1.Add(shiptoKNA1);
        a2c.SA_KNB1.Add(shiptoKNB1);
        a2c.SA_KNVV.Add(shiptoKNVV);

        application.SA_APPLICATION2COMPANY.Add(a2c);
    }

    private void CreateBillTo(SA_APPLICATION application)
    {
        string BillingCompanyName = Request["ctl00$_main$txtBillingCompanyName"] ?? "";
        string BillingVAT = Request["ctl00$_main$txtBillingVATNumber"] ?? "";
        string BillingAddr1 = Request["ctl00$_main$txtBillingAddress"] ?? "";
        string BillingAddr2 = Request["ctl00$_main$txtBillingAddress2"] ?? "";
        string BillingAddr3 = Request["ctl00$_main$txtBillingAddress3"] ?? "";
        string BillingPostCode = Request["ctl00$_main$txtBillingPostcode"] ?? "";
        string BillingCity = Request["ctl00$_main$txtBillingCity"] ?? "";
        string BillingCountryCode = Request["ctl00$_main$dlBillingCountry"] ?? "";
        string BillingTel = Request["ctl00$_main$txtBillingTel"] ?? "";
        string BillingFax = Request["ctl00$_main$txtBillingFax"] ?? "";
        string BillingContactName = Request["ctl00$_main$txtBillingContactName"] ?? "";
        string BillingContactEmail = Request["ctl00$_main$txtBillingContactEmail"] ?? "";
         PriceGrade = Request["PriceGrade"] ?? "";
        string WebsiteUrl = Request["ctl00$_main$txtWebsiteUrl"] ?? "";
        string LegalForm = Request["LegalForm"] ?? "";
        string Tel = Request["ctl00$_main$txtTel"] ?? "";
        string Fax = Request["ctl00$_main$txtFax"] ?? "";
        string SalesOffice = Request["ctl00$_main$dlSalesOffice"] ?? "";
        string Inco2 = Request["ctl00$_main$txtInco2"] ?? "";
        string Currency = Request["ctl00$_main$dlCurr"] ?? "";
        string Sales = Request["ctl00$_main$dlSalesCode"] ?? "";
        //string InsideSales = Request["ctl00$_main$dlISCode"] ?? "";
        string Inco1 = Request["ctl00$_main$dlInco1"] ?? "";
        string dlPaymentTerm = Request["ctl00$_main$dlPaymentTerm"] ?? "";
        SA_APPLICATION2COMPANY a2c = new SA_APPLICATION2COMPANY();
        a2c.CompanyID = string.Empty;
        a2c.CompanyType = (int)companyType.BillTo;
        //  a2c.SA_BAPIADDR1.CopyTo
        SA_FKNVI billingFKNV1 = new SA_FKNVI();
        billingFKNV1.Tatyp = "UTXJ";
        billingFKNV1.Aland = "US";
        billingFKNV1.Kunnr = string.Empty;
        billingFKNV1.Mandt = "168";
        billingFKNV1.Taxkd = "0";

        SA_FKNVI billingFKNV2 = new SA_FKNVI();
        billingFKNV2.Tatyp = "MWST";
        billingFKNV2.Aland = dlBillingCountry.SelectedValue;
        billingFKNV2.Kunnr = string.Empty;
        billingFKNV2.Mandt = "168";
        billingFKNV2.Taxkd = dlBillToTaxId.SelectedValue;

        SA_BAPIADDR1 billingAddr1 = new SA_BAPIADDR1();
        billingAddr1.Langu = "EN";
        billingAddr1.Comm_Type = "INT";
        billingAddr1.Homepage = WebsiteUrl;
        billingAddr1.Fax_Number = BillingFax;
        billingAddr1.Tel1_Numbr = BillingTel;
        billingAddr1.Transpzone = "0000000001";
        string cn = BillingCompanyName.Trim().ToUpper();
        if (!string.IsNullOrEmpty(LegalForm.Trim()))
        {
            cn += " " + LegalForm.Trim();
        }
        if (cn.Length <= 40)
        {
            billingAddr1.Name = cn;
        }
        else if (40 < cn.Length && cn.Length <= 80)
        {
            billingAddr1.Name = cn.Substring(0, 40);
            billingAddr1.Name_2 = cn.Substring(40);
        }
        else if (80 < cn.Length && cn.Length <= 120)
        {
            billingAddr1.Name = cn.Substring(0, 40);
            billingAddr1.Name_2 = cn.Substring(40, 80);
            billingAddr1.Name_3 = cn.Substring(80);
        }
        else if (120 < cn.Length)
        {
            billingAddr1.Name = cn.Substring(0, 40);
            billingAddr1.Name_2 = cn.Substring(40, 80);
            billingAddr1.Name_3 = cn.Substring(80, 120);
            billingAddr1.Name_4 = cn.Substring(120);
        }
        billingAddr1.Title = "Company";
        billingAddr1.Country = BillingCountryCode;
        string address = (BillingAddr1 + "|" + BillingAddr2 + "|" + BillingAddr3).Trim().ToUpper();
        string[] bp = address.Split('|');
        billingAddr1.Street = bp[0];
        billingAddr1.Str_Suppl3 = bp[1];
        if (bp.Length >= 3)
        {
            billingAddr1.Location = bp[2];
        }
        if (bp.Length >= 4)
        {
            billingAddr1.Str_Suppl1 = bp[3];
        }
        if (bp.Length >= 5)
        {
            billingAddr1.Str_Suppl2 = bp[4];
        }
        billingAddr1.Postl_Cod1 = BillingPostCode.Trim().ToUpper();
        billingAddr1.Addr_No = string.Empty;
        billingAddr1.City = BillingCity.Trim().ToUpper();
        billingAddr1.C_O_Name = BillingContactName.Trim().ToUpper();
        billingAddr1.E_Mail = BillingContactEmail.Trim().ToUpper();
        billingAddr1.Region = _Region;

        SA_BAPIADDR2 billingAddr2 = new SA_BAPIADDR2();
        billingAddr2.Addr_No = string.Empty;

        SA_KNA1 billingKNA1 = new SA_KNA1();
        billingKNA1.Mandt = "168";
        billingKNA1.Kunnr = string.Empty;
        billingKNA1.Land1 = BillingCountryCode;
        billingKNA1.Name1 = BillingCompanyName.Trim().ToUpper();
        billingKNA1.Name2 = string.Empty;
        billingKNA1.Ort01 = BillingCity.Trim().ToUpper();
        billingKNA1.Pstlz = BillingPostCode.Trim().ToUpper();
        billingKNA1.Regio = string.Empty;
        billingKNA1.Sortl = BillingVAT.Trim().ToUpper();
        billingKNA1.Stras = (BillingAddr1 + "|" + BillingAddr2 + "|" + BillingAddr3).Trim().ToUpper();
        billingKNA1.Telf1 = BillingTel;
        billingKNA1.Telfx = BillingFax;
        billingKNA1.Xcpdk = string.Empty;
        billingKNA1.Mcod1 = BillingCompanyName.Trim().ToUpper();
        billingKNA1.Mcod2 = string.Empty;
        billingKNA1.Mcod3 = (BillingAddr1 + "|" + BillingAddr2 + "|" + BillingAddr3).Trim().ToUpper();
        billingKNA1.Anred = "Company";
        billingKNA1.Aufsd = " ";
        billingKNA1.Bahne = " ";
        billingKNA1.Bahns = " ";
        billingKNA1.Begru = " ";
        billingKNA1.Bbbnr = "0000000";
        billingKNA1.Bbsnr = "00000";
        billingKNA1.Bubkz = "0";
        billingKNA1.Brsch = _Industry;
        billingKNA1.Datlt = " ";
        billingKNA1.Erdat = DateTime.Now.ToString("yyyyMMdd");
        billingKNA1.Ernam = "B2BAEU";
        billingKNA1.Exabl = " ";
        billingKNA1.Faksd = " ";
        billingKNA1.Fiskn = " ";
        billingKNA1.Knazk = " ";
        billingKNA1.Knrza = " ";
        billingKNA1.Konzs = " ";
        billingKNA1.Ktokd = "Z001";
        billingKNA1.Kukla = "03";
        billingKNA1.Lifnr = " ";
        billingKNA1.Lifsd = " ";
        billingKNA1.Locco = " ";
        billingKNA1.Loevm = " ";
        billingKNA1.Name3 = " ";
        billingKNA1.Name4 = " ";
        billingKNA1.Niels = " ";
        billingKNA1.Ort02 = " ";
        billingKNA1.Pfach = " ";
        billingKNA1.Pstl2 = " ";
        billingKNA1.Counc = " ";
        billingKNA1.Cityc = " ";
        billingKNA1.Rpmkr = " ";
        billingKNA1.Sperr = " ";
        billingKNA1.Spras = "E";
        billingKNA1.Stcd1 = " ";
        billingKNA1.Stcd2 = " ";
        billingKNA1.Stkza = " ";
        billingKNA1.Stkzu = " ";
        billingKNA1.Telbx = " ";
        billingKNA1.Telf2 = " ";
        billingKNA1.Teltx = " ";
        billingKNA1.Telx1 = " ";
        billingKNA1.Lzone = "0000000001";
        billingKNA1.Xzemp = " ";
        billingKNA1.Stceg = BillingVAT;
        billingKNA1.Dear1 = " ";
        billingKNA1.Dear2 = " ";
        billingKNA1.Dear3 = " ";
        billingKNA1.Dear4 = " ";
        billingKNA1.Dear5 = " ";
        billingKNA1.Gform = " ";
        billingKNA1.Bran1 = " ";
        billingKNA1.Bran2 = " ";
        billingKNA1.Bran3 = " ";
        billingKNA1.Bran4 = " ";
        billingKNA1.Bran5 = " ";
        billingKNA1.Ekont = " ";
        billingKNA1.Umsat = "0";
        billingKNA1.Umjah = "0000";
        billingKNA1.Uwaer = " ";
        billingKNA1.Jmzah = "000000";
        billingKNA1.Jmjah = "0000";
        billingKNA1.Katr1 = string.Empty;// Not sure
        billingKNA1.Katr2 = string.Empty;//Not sure
        billingKNA1.Katr3 = string.Empty;

        if (SalesOffice.Trim() == "1100")
            billingKNA1.Katr2 = "19";
        else billingKNA1.Katr2 = "13";

        billingKNA1.Katr4 = "";//??
        billingKNA1.Katr5 = "";//??
        billingKNA1.Katr6 = "";//??
        billingKNA1.Katr7 = "";//??
        billingKNA1.Katr8 = "";//??
        billingKNA1.Katr9 = "";//??
        billingKNA1.Katr10 = "";
        billingKNA1.Stkzn = " ";
        billingKNA1.Umsa1 = "0";
        billingKNA1.Txjcd = " ";
        billingKNA1.Periv = " ";
        billingKNA1.Abrvw = " ";
        billingKNA1.Inspbydebi = " ";
        billingKNA1.Inspatdebi = " ";
        billingKNA1.Ktocd = " ";
        billingKNA1.Pfort = " ";
        billingKNA1.Werks = " ";
        billingKNA1.Dtams = " ";
        billingKNA1.Dtaws = " ";
        billingKNA1.Duefl = "X";
        billingKNA1.Hzuor = "00";
        billingKNA1.Sperz = " ";
        billingKNA1.Etikg = " ";
        billingKNA1.Civve = "X";
        billingKNA1.Milve = " ";
        if (!string.IsNullOrEmpty(PriceGrade) && PriceGrade.Length == 8)
        {
            billingKNA1.Kdkg1 = PriceGrade.Substring(0, 2);
            billingKNA1.Kdkg2 = PriceGrade.Substring(2, 2);
            billingKNA1.Kdkg3 = PriceGrade.Substring(4, 2);
            billingKNA1.Kdkg4 = PriceGrade.Substring(6, 2);
            billingKNA1.Kdkg5 = PriceGrade.Substring(0, 2); ;
        }
        else
        {
            billingKNA1.Kdkg1 = "L0";
            billingKNA1.Kdkg2 = "L0";
            billingKNA1.Kdkg3 = "L0";
            billingKNA1.Kdkg4 = "L0";
            billingKNA1.Kdkg5 = "R4";
        }
        billingKNA1.Xknza = " ";
        billingKNA1.Fityp = " ";
        billingKNA1.Stcdt = " ";
        billingKNA1.Stcd3 = " ";
        billingKNA1.Stcd4 = " ";
        billingKNA1.Xicms = " ";
        billingKNA1.Xxipi = " ";
        billingKNA1.Xsubt = " ";
        billingKNA1.Cfopc = " ";
        billingKNA1.Txlw1 = " ";
        billingKNA1.Txlw2 = " ";
        billingKNA1.Ccc01 = " ";
        billingKNA1.Ccc02 = " ";
        billingKNA1.Ccc03 = " ";
        billingKNA1.Ccc04 = " ";
        billingKNA1.Cassd = " ";
        billingKNA1.Knurl = WebsiteUrl;
        billingKNA1.J_1kfrepre = " ";
        billingKNA1.J_1kftbus = " ";
        billingKNA1.J_1kftind = " ";
        billingKNA1.Confs = " ";
        billingKNA1.Updat = "00000000";
        billingKNA1.Uptim = "000000";
        billingKNA1.Nodel = " ";
        billingKNA1.Dear6 = " ";
        billingKNA1.Alc = " ";
        billingKNA1.Pmt_Office = " ";
        billingKNA1.Psofg = " ";
        billingKNA1.Psois = " ";
        billingKNA1.Pson1 = " ";
        billingKNA1.Pson2 = " ";
        billingKNA1.Pson3 = " ";
        billingKNA1.Psovn = " ";
        billingKNA1.Psotl = " ";
        billingKNA1.Psohs = " ";
        billingKNA1.Psost = " ";
        billingKNA1.Psoo1 = " ";
        billingKNA1.Psoo2 = " ";
        billingKNA1.Psoo3 = " ";
        billingKNA1.Psoo4 = " ";
        billingKNA1.Psoo5 = " ";

        SA_KNB1 billingKNB1 = new SA_KNB1();
        billingKNB1.Mandt = "168";
        billingKNB1.Kunnr = string.Empty;
        billingKNB1.Bukrs = "TW01";//EU10
        billingKNB1.Pernr = "00000000";
        billingKNB1.Erdat = DateTime.Now.ToString("yyyyMMdd");
        billingKNB1.Ernam = "B2BAEU";
        billingKNB1.Sperr = " ";
        billingKNB1.Loevm = " ";
        billingKNB1.Zuawa = "001";
        billingKNB1.Busab = "EI";//??? 看credit
        //billingKNB1.Akont = "";//??? 看credit
        billingKNB1.Vlibb = "";//??? 看credit
        billingKNB1.Fdgrv = "";//??? 看credit
        billingKNB1.Vrsnr = "";//??? 看credit
        billingKNB1.Begru = " ";
        billingKNB1.Knrze = " ";
        billingKNB1.Knrzb = " ";
        billingKNB1.Zamim = " ";
        billingKNB1.Zamiv = " ";
        billingKNB1.Zamir = " ";
        billingKNB1.Zamib = " ";
        billingKNB1.Zamio = " ";
        billingKNB1.Zwels = " ";
        billingKNB1.Xverr = " ";
        billingKNB1.Zahls = " ";
        billingKNB1.Zterm = dlPaymentTerm;
        billingKNB1.Wakon = " ";
        billingKNB1.Vzskz = " ";
        billingKNB1.Zindt = "00000000";
        billingKNB1.Zinrt = "00";
        billingKNB1.Eikto = " ";
        billingKNB1.Zsabe = " ";
        billingKNB1.Kverm = " ";
        billingKNB1.Vrbkz = " ";
        billingKNB1.Vrszl = "0";
        billingKNB1.Vrspr = "0";
        billingKNB1.Verdt = "00000000";
        billingKNB1.Perkz = " ";
        billingKNB1.Xdezv = " ";
        billingKNB1.Xausz = " ";
        billingKNB1.Webtr = " ";
        billingKNB1.Remit = " ";
        billingKNB1.Datlz = "00000000";
        billingKNB1.Xzver = "X";
        billingKNB1.Togru = " ";
        billingKNB1.Kultg = "0";
        billingKNB1.Hbkid = " ";
        billingKNB1.Xpore = " ";
        billingKNB1.Blnkz = " ";
        billingKNB1.Altkn = " ";
        billingKNB1.Zgrup = " ";
        billingKNB1.Urlid = " ";
        billingKNB1.Mgrup = "01";
        billingKNB1.Lockb = " ";
        billingKNB1.Uzawe = " ";
        billingKNB1.Ekvbd = " ";
        billingKNB1.Sregl = " ";
        billingKNB1.Xedip = " ";
        billingKNB1.Frgrp = " ";
        billingKNB1.Vrsdg = " ";
        billingKNB1.Tlfxs = " ";
        billingKNB1.Intad = " ";
        billingKNB1.Xknzb = " ";
        billingKNB1.Guzte = " ";
        billingKNB1.Gricd = " ";
        billingKNB1.Gridt = " ";
        billingKNB1.Wbrsl = " ";
        billingKNB1.Confs = " ";
        billingKNB1.Updat = "00000000";
        billingKNB1.Uptim = "000000";
        billingKNB1.Nodel = " ";
        billingKNB1.Tlfns = " ";
        billingKNB1.Cession_Kz = " ";
        billingKNB1.Gmvkzd = " ";
        //knb1.Akont = "'0000121001' ";//hard code
        billingKNB1.Fdgrv = "A1";//hard code
        billingKNB1.Akont = "01";

        SA_KNVV billingKNVV = new SA_KNVV();
        billingKNVV.Mandt = "168";
        billingKNVV.Kunnr = string.Empty;
        billingKNVV.Vkorg = "TW01";//EU10
        billingKNVV.Vtweg = "00";
        billingKNVV.Spart = "00";
        billingKNVV.Ernam = "B2BAEU";
        billingKNVV.Erdat = DateTime.Now.ToString("yyyyMMdd");
        billingKNVV.Begru = " ";
        billingKNVV.Loevm = " ";
        billingKNVV.Versg = " ";
        billingKNVV.Aufsd = " ";
        billingKNVV.Kalks = "1";
        //
        //knvv.Kdgrp = "";//??????????????
        billingKNVV.Bzirk = "";//??????????????
        //
        billingKNVV.Konda = "00";
        billingKNVV.Pltyp = "00";
        billingKNVV.Awahr = "100";
        billingKNVV.Inco1 = Inco1.Trim().ToUpper();
        billingKNVV.Inco2 = Inco2.Trim().ToUpper();

        billingKNVV.Lifsd = " ";
        billingKNVV.Autlf = "9";//重複
        billingKNVV.Kztlf = " ";
        billingKNVV.Kzazu = "X";
        billingKNVV.Chspl = " ";
        billingKNVV.Lprio = "";
        billingKNVV.Eikto = " ";
        //shiptoKNVV.Vsbed = "";//??? Shippingcondition
        billingKNVV.Faksd = " ";
        billingKNVV.Mrnkz = " ";
        billingKNVV.Perfk = " ";
        billingKNVV.Perrl = " ";
        billingKNVV.Kvakz = " ";
        billingKNVV.Kvawt = "0";
        billingKNVV.Waers = Currency;
        billingKNVV.Klabc = " ";
        //knvv.Ktgrd = "";//AAG
        //knvv.Zterm = "";//strCreditTerm
        //knvv.Vwerk = "";//strPlant
        //knvv.Vkgrp = "";//SalesGroup
        //knvv.Vkbur = SalesOffice;
        billingKNVV.Vsort = " ";
        billingKNVV.Kvgr1 = " ";
        billingKNVV.Kvgr2 = " ";
        billingKNVV.Kvgr3 = "D0";
        billingKNVV.Kvgr4 = " ";
        billingKNVV.Kvgr5 = " ";
        billingKNVV.Bokre = " ";
        billingKNVV.Boidt = "00000000";
        billingKNVV.Kurst = " ";
        billingKNVV.Prfre = " ";
        billingKNVV.Prat1 = " ";
        billingKNVV.Prat2 = " ";
        billingKNVV.Prat3 = " ";
        billingKNVV.Prat4 = " ";
        billingKNVV.Prat5 = " ";
        billingKNVV.Prat6 = " ";
        billingKNVV.Prat7 = " ";
        billingKNVV.Prat8 = " ";
        billingKNVV.Prat9 = " ";
        billingKNVV.Prata = " ";
        billingKNVV.Kabss = " ";
        billingKNVV.Kkber = " ";
        billingKNVV.Cassd = " ";
        billingKNVV.Rdoff = " ";
        billingKNVV.Agrel = " ";
        billingKNVV.Megru = " ";
        billingKNVV.Uebto = "0";
        billingKNVV.Untto = "0";
        billingKNVV.Uebtk = " ";
        billingKNVV.Pvksm = " ";
        billingKNVV.Podkz = " ";
        billingKNVV.Podtg = "0";
        billingKNVV.Blind = " ";
        billingKNVV.Bev1_Emlgforts = " ";
        billingKNVV.Bev1_Emlgpfand = " ";
        billingKNVV.Antlf = "9";
        billingKNVV.Kdgrp = "01";
        billingKNVV.Vsbed = "01";
        if (IsATW())
        {
            billingKNVV.Ktgrd = "01";
        }
        else
        {
            billingKNVV.Ktgrd = "02";
        }
        billingKNVV.Zterm = dlPaymentTerm;
        //billingKNVV.Vwerk = "TWH1";
        billingKNVV.Vwerk = "";
        billingKNVV.Vkgrp = Sales;
        //billingKNVV.Vkbur = InsideSales;

        SA_FKNBK billingFKNBK = new SA_FKNBK();

        //Add bill to data
        a2c.SA_BAPIADDR1.Add(billingAddr1);
        a2c.SA_BAPIADDR2.Add(billingAddr2);
        a2c.SA_FKNBK.Add(billingFKNBK);
        a2c.SA_FKNVI.Add(billingFKNV1);
        a2c.SA_FKNVI.Add(billingFKNV2);
        a2c.SA_KNA1.Add(billingKNA1);
        a2c.SA_KNB1.Add(billingKNB1);
        a2c.SA_KNVV.Add(billingKNVV);

        application.SA_APPLICATION2COMPANY.Add(a2c);
    }

    protected void BtApprove_Click(object sender, EventArgs e)
    {
        try
        {
            string proposal = TBComment.Text.Trim();
            if (string.IsNullOrEmpty(proposal))
            {
                Util.AjaxJSAlert(this.up2, "Please enter Comment.");
                return;
            }

            save(); //When approving request, update form first.
            int id = int.Parse(Request["id"].ToString());
            MyAdminContext.Current.Database.ExecuteSqlCommand(string.Format("update SA_APPLICATION set status={1} where id={0}", id, (int)AccountWorkFlowStatus.Approved));
            setCompanyID(AccountWorkFlowStatus.Approved);
            
            SA_Proposal _proposal = new SA_Proposal();
            _proposal.AppID = id;
            _proposal.MailTo = "";
            _proposal.Status = 1;
            _proposal.Comment = proposal;
            _proposal.CreateBy = User.Identity.Name;
            _proposal.CreateTime = DateTime.Now;
            MyAdminContext.Current.SA_Proposal.Add(_proposal);
            MyAdminContext.Current.SaveChanges();

            NewSAPCustomerFlow.Common.CallFlow(id.ToString());
            //Util.AjaxJSAlert(this.up2, "approved successfully");
            Util.AjaxJSAlertRedirect(this.up2, "approved successfully", "SAPAccountList.aspx");
        }
        catch (Exception ex)
        {
            Util.AjaxJSAlert(this.up2, "Failed：" + ex.ToString());
        }

    }
    protected string GetApplicationNO()
    {
        string SQL = String.Format(" select isNull(MAX(ID),0) as APLICATIONNO from SA_APPLICATION", "");
        var NUM = dbUtil.dbExecuteScalar("MYADMIN", SQL);
        if (NUM != null)
        {
            return "TN" + (Int32.Parse(NUM.ToString()) + 1).ToString("00000");
        }

        return "";
    }

    private void GetCustomerAcctAssgmtGroupAndTaxClassification(string countrycode, ref string AAG, ref string TC)
    {
        string strCountrys = "AT,BE,BG,CY,CZ,DE,DK,EE,GR,ES,FI,FR,GB,HR,HU,IE,IT,LT,LU,LV,MT,PL,PT,RO,SE,SI,SK";
        if (strCountrys.Contains(countrycode.ToUpper().Trim()))
        {
            AAG = "02";
            TC = "8";
        }
        else if (string.Equals(countrycode, "NL", StringComparison.CurrentCultureIgnoreCase))
        {
            AAG = "01";
            TC = "7";
        }
        else
        {
            AAG = "02";
            TC = "9";
        }
    }
    protected void BtReject_Click(object sender, EventArgs e)
    {
        if (Request["id"] == null)
        {
            Util.AjaxJSAlert(this.Page, "Error! No ID!");
            return;
        }
        string proposal = TBComment.Text.Trim();
        if (string.IsNullOrEmpty(proposal))
        {
            Util.AjaxJSAlert(this.up2, "Please enter Comment.");
            return;
        }
        int id = int.Parse(Request["id"].ToString());
        try
        {
            MyAdminContext.Current.Database.ExecuteSqlCommand(string.Format("update SA_APPLICATION set status={1} where id={0}", id, (int)AccountWorkFlowStatus.Reject));
            MyAdminDAL _MyAdminDAL = new MyAdminDAL();
            SA_APPLICATION ap = _MyAdminDAL.getApplicationByID(id);
            ap.COMMENT = Request["ctl00$_main$TBComment"] ?? "";
            ap.REJECTED_BY = User.Identity.Name;
            ap.REJECTED_DATE = DateTime.Now;
            ap.STATUS = (Int32)AccountWorkFlowStatus.Reject;
            ap.Update();

            SA_Proposal _proposal = new SA_Proposal();
            _proposal.AppID = id;
            _proposal.MailTo = "";
            _proposal.Status = 1;
            _proposal.Comment = proposal;
            _proposal.CreateBy = User.Identity.Name;
            _proposal.CreateTime = DateTime.Now;
            MyAdminContext.Current.SA_Proposal.Add(_proposal);
            MyAdminContext.Current.SaveChanges();
            NewSAPCustomerFlow.Common.CallFlow(id.ToString());
            Util.JSAlertRedirect(this.Page, "refuse to success", string.Format("CreateSAPAccount.aspx?ID={0}", id));
        }
        catch (Exception ex)
        {
            Util.JSAlertRedirect(this.Page, "Failed" + ex.ToString(), string.Format("CreateSAPAccount.aspx?ID={0}", id));
        }
    }


    protected void fup1_UploadedComplete(object sender, AjaxControlToolkit.AsyncFileUploadEventArgs e)
    {
        lbFupMsg.Text = "";
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "reply", "document.getElementById('" + lbFupMsg.ClientID + "').innerHTML= 'Done!';", true);
        if (fup1.HasFile && (fup1.FileName.EndsWith(".xls", StringComparison.OrdinalIgnoreCase)
                                || fup1.FileName.EndsWith(".xlsx", StringComparison.OrdinalIgnoreCase)
                                || fup1.FileName.EndsWith(".doc", StringComparison.OrdinalIgnoreCase)
                               || fup1.FileName.EndsWith(".docx", StringComparison.OrdinalIgnoreCase)
                                || fup1.FileName.EndsWith(".pptx", StringComparison.OrdinalIgnoreCase)
                                  || fup1.FileName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase)
                                    || fup1.FileName.EndsWith(".jpeg", StringComparison.OrdinalIgnoreCase)
                                      || fup1.FileName.EndsWith(".gif", StringComparison.OrdinalIgnoreCase)
                                        || fup1.FileName.EndsWith(".png", StringComparison.OrdinalIgnoreCase)
                                || fup1.FileName.EndsWith(".ppt", StringComparison.OrdinalIgnoreCase)))
        {
            System.IO.Stream _stream = fup1.FileContent;
            Byte[] fileData = new Byte[_stream.Length];
            _stream.Read(fileData, 0, (int)_stream.Length);
            SA_Files saFile = new SA_Files();

            saFile.AppID = HidRowid.Value;
            saFile.Files = fileData;
            saFile.File_Name = fup1.FileName;
            saFile.File_Ext = fup1.FileName.Substring(fup1.FileName.LastIndexOf(".") + 1, fup1.FileName.Length - fup1.FileName.LastIndexOf(".") - 1);
            saFile.File_CreateBy = User.Identity.Name;
            saFile.File_CreateTime = DateTime.Now;
            MyAdminContext.Current.SA_Files.Add(saFile);
            MyAdminContext.Current.SaveChanges();
        }

    }
    [WebMethod]
    public static string GetFiles(string Appid, string str)
    {
        StringBuilder sb = new StringBuilder();
        List<SA_Files> fs = MyAdminContext.Current.SA_Files.Where(p => p.AppID == Appid).OrderByDescending(p => p.File_CreateBy).ToList();

        sb.AppendLine(String.Format("<table class='mtb2'><tr>"));

        foreach (SA_Files f in fs)
        {
            sb.AppendLine(String.Format("<td><a href='FileShow.ashx?id={0}' target='_blank'>{1}</a> </td></tr>", f.ID, f.File_Name));
        }
        sb.AppendLine(String.Format("</tr></table>"));

        return sb.ToString();
    }

    private void setCompanyID(AccountWorkFlowStatus afs)
    {

        string ShodToErpID = txtCompanyId2.Text.Trim();
        int id = int.Parse(Request["id"].ToString());

        if (CreateSAPCustomerDAL.IsERPIDExist(ShodToErpID))
        {
            Util.AjaxJSAlert(this.up2, string.Format("Company ID {0} already exists in SAP", ShodToErpID));
            return;
        }

        SA_APPLICATION ap = MyAdminBusinessLogic.getApplicationByID(id);
        SA_APPLICATION2COMPANY a2c = ap.SA_APPLICATION2COMPANY.Where(p => p.ApplicationID == ap.ID).FirstOrDefault();
        ap.COMMENT = Request["ctl00$_main$TBComment"] ?? "";
        ap.APPROVED_BY = User.Identity.Name;
        ap.APPROVED_DATE = DateTime.Now;
        ap.LAST_UPD_BY = ap.APPROVED_BY;
        ap.LAST_UPD_DATE = ap.APPROVED_DATE;
        //  ap.AplicationNO = txtCompanyId2.Text.Trim();
        string tempShipToErpID = ""; string tempBillToErpID = "";
        CreateSAPCustomerDAL.NewCompanyId(ShodToErpID, ref tempShipToErpID, ref tempBillToErpID);
        ap.STATUS = (Int32)afs;
        a2c.CompanyID = ShodToErpID;
        a2c.SA_KNA1.FirstOrDefault().Kunnr = ShodToErpID;
        a2c.SA_KNB1.FirstOrDefault().Kunnr = ShodToErpID;
        a2c.SA_KNVV.FirstOrDefault().Kunnr = ShodToErpID;
        foreach (SA_FKNVI fknvi in a2c.SA_FKNVI.ToList())
        {
            fknvi.Kunnr = ShodToErpID;
        }
        if (ap.IsHaveShipToX())
        {
            SA_APPLICATION2COMPANY a2cShipTo = ap.ShipToX();
            a2cShipTo.CompanyID = tempShipToErpID;
            a2cShipTo.SA_KNA1.FirstOrDefault().Kunnr = tempShipToErpID;
            a2cShipTo.SA_KNB1.FirstOrDefault().Kunnr = tempShipToErpID;
            a2cShipTo.SA_KNVV.FirstOrDefault().Kunnr = tempShipToErpID;
            foreach (SA_FKNVI fknvi in a2cShipTo.SA_FKNVI.ToList())
            {
                fknvi.Kunnr = tempShipToErpID;
            }
        }
        if (ap.IsHaveBillToX())
        {
            SA_APPLICATION2COMPANY a2cBillTo = ap.BillToX();
            a2cBillTo.CompanyID = tempBillToErpID;
            a2cBillTo.SA_KNA1.FirstOrDefault().Kunnr = tempBillToErpID;
            a2cBillTo.SA_KNB1.FirstOrDefault().Kunnr = tempBillToErpID;
            a2cBillTo.SA_KNVV.FirstOrDefault().Kunnr = tempBillToErpID;
            foreach (SA_FKNVI fknvi in a2cBillTo.SA_FKNVI.ToList())
            {
                fknvi.Kunnr = tempBillToErpID;
            }
        }
        ap.Update();
        System.Threading.Thread.Sleep(2000);
        MyAdminContext.Current.Database.ExecuteSqlCommand(string.Format("update SA_Proposal set status=1 where AppID={0}", id));
    }
    protected void btproposal_Click(object sender, EventArgs e)
    {

        string mailto = TBmail.Text;
        if (!Util.IsValidEmailFormat(mailto))
        {
            Util.AjaxJSAlert(this.up2, "Email is inValid.");
            return;
        }
        string proposal = TBComment.Text.Trim();
        if (string.IsNullOrEmpty(proposal))
        {
            Util.AjaxJSAlert(this.up2, "Please enter Comment.");
            return;
        }
        SA_Proposal _proposal = new SA_Proposal();
        _proposal.AppID = Int32.Parse(Request["id"]);
        _proposal.MailTo = mailto;
        _proposal.Status = 0;
        _proposal.Comment = proposal;
        _proposal.CreateBy = User.Identity.Name;
        _proposal.CreateTime = DateTime.Now;
        MyAdminContext.Current.SA_Proposal.Add(_proposal);
        string msg = "Message sent successfully";
        try
        {
            MyAdminContext.Current.SaveChanges();
            NewSAPCustomerFlow.Common.CallFlow(Request["id"].ToString());
            if (!string.IsNullOrEmpty(txtCompanyId2.Text.Trim()))
            {
                setCompanyID(AccountWorkFlowStatus.NotifyCM);
            }
        }
        catch (Exception ex)
        {

            msg = ex.Message.ToString();
        }

        Util.AjaxJSAlert(this.up2, msg);
        // Util.JSAlertRedirect(this.Page, "Success", string.Format("CreateSAPAccount.aspx?ID={0}", Request["id"]));
    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        save();
        setCompanyID(AccountWorkFlowStatus.Approved);
            
    }

    protected void dlOrgID_SelectedIndexChanged(object sender, EventArgs e)
    {
        //Get office from SAP testing because B+B's data is not yet on SAP RDP
        var dtOrgOffices = OraDbUtil.dbGetDataTable("SAP_Test", @"
select distinct a.vkbur as officecode, b.bezei as officedesc from saprdp.tvkbz a inner join saprdp.tvkbt b on a.vkbur=b.vkbur 
where a.mandt='168' and b.mandt='168' 
and a.vkorg='"+dlOrgID.SelectedValue+"' and b.spras='E' order by a.vkbur");
        dlSalesOffice.Items.Clear();
        foreach (DataRow officeRow in dtOrgOffices.Rows) {
            dlSalesOffice.Items.Add(new ListItem(string.Format("{0} ({1})", officeRow["officecode"].ToString(), officeRow["officedesc"].ToString()), officeRow["officecode"].ToString()));
        }
        dlSalesOffice_SelectedIndexChanged(this.dlSalesOffice, new EventArgs());
    }

    protected void dlSalesOffice_SelectedIndexChanged(object sender, EventArgs e)
    {
        dlSalesGroup.Items.Clear();        
        var dtSalesGroup = OraDbUtil.dbGetDataTable("SAP_Test", string.Format(@"
select b.vkgrp, b.bezei
from saprdp.tvbvk a inner join saprdp.tvgrt b on a.vkgrp=b.vkgrp
where a.mandt='168' and b.mandt='168' and b.spras='E' and a.vkbur='{0}'
order by b.vkgrp", dlSalesOffice.SelectedValue));

        foreach (DataRow grpRow in dtSalesGroup.Rows)
        {
            dlSalesGroup.Items.Add(new ListItem(string.Format("{0} ({1})", grpRow["vkgrp"].ToString(), grpRow["bezei"].ToString()), grpRow["vkgrp"].ToString()));
        }

    }

    protected void txtCompanyId2_TextChanged(object sender, EventArgs e)
    {
        lbERPIDMsg2.Text = "";
        string strInputCompanyId = txtCompanyId2.Text.Trim().ToUpper();
        if (String.IsNullOrEmpty(strInputCompanyId) || strInputCompanyId.Length <= 5) return;

        if (CreateSAPCustomerDAL.IsERPIDExist(strInputCompanyId))
        {
            lbERPIDMsg2.Text = string.Format("{0} already exists", strInputCompanyId);
        }
        else {
            lbERPIDMsg2.Text = string.Format("{0} doesn't exist yet", strInputCompanyId);
        }
    }
}