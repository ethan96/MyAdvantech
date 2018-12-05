<%@ Page Language="C#" Title="MyAdvantech - SAP Account Owner vs. Siebel Account Owner" %>

<!DOCTYPE html>

<script runat="server">
    protected void Page_Load(object sender, EventArgs e) {
        if (!Util.IsBBCustomerCare()) Response.Redirect("../../home.aspx");
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        var dt = dbUtil.dbGetDataTable("MY",
            @"
select a.COMPANY_ID, a.ORG_ID, a.COMPANY_NAME, a.COUNTRY_NAME, a.REGION_CODE as SAP_STATE, a.ZIP_CODE as SAP_ZIPCODE, a.CITY as SAP_CITY, a.ADDRESS as SAP_ADDRESS
, a.SALESOFFICE, a.SALESGROUP, emp.SALES_CODE, idmap.id_chi as EAI_SALESNAME, idmap.id_email as EAI_SALESEMAIL 
, b.ROW_ID as CRM_ACCOUNT_ROW_ID, b.ACCOUNT_NAME as CRM_ACCOUNT_NAME, b.ERP_ID as CRM_ERPID, b.PRIMARY_SALES_EMAIL as CRM_ACCOUNT_PRI_OWNER, b.RBU as CRM_ORGID
, b.ACCOUNT_STATUS, b.COUNTRY as CRM_COUNTRY, b.ZIPCODE as CRM_ZIPCODE, b.CITY as CRM_CITY, b.ADDRESS as CRM_CITY
, 
	case 
		when b.ROW_ID is null then 'No ERPID on Siebel'
		when b.PRIMARY_SALES_EMAIL=idmap.id_email then 'Sales Email Matched'
		when b.PRIMARY_SALES_EMAIL<>idmap.id_email then 'Sales Email Not Matched'
		else 'Unknown' 
	end as 'Match Status'
from SAP_DIMCOMPANY a (nolock) inner join SAP_COMPANY_EMPLOYEE emp (nolock) on a.COMPANY_ID=emp.COMPANY_ID and a.ORG_ID=emp.SALES_ORG 
inner join EAI_IDMAP idmap on emp.SALES_CODE=idmap.id_sap 
left join SIEBEL_ACCOUNT b (nolock) on a.COMPANY_ID=b.ERP_ID 
where a.COMPANY_ID not like 'ADV%' and a.ORG_ID in ('US10','EU10') and a.COMPANY_TYPE='Z001' and emp.PARTNER_FUNCTION='VE' and a.DELETION_FLAG<>'X'
and a.SALESOFFICE in ('2900','3410')
order by a.SALESOFFICE, a.SALESGROUP, a.COUNTRY_NAME, a.REGION_CODE, a.ZIP_CODE 
");
        Util.DataTable2ExcelDownload(dt, "SAP2SiebelOwner.xls");
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <h3>Export B+B SAP account owner to Siebel account owner matching data</h3>
        <asp:Button runat="server" ID="btnExport" Text="Export" OnClick="btnExport_Click" />
    </div>
    </form>
</body>
</html>
