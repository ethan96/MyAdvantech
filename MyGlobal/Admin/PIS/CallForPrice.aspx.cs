using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Admin_PIS_CallForPrice : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (MailUtil.IsInRole2("MyAdvantech", Context.User.Identity.Name) == true || MailUtil.IsInRole2("DMKT.ACL", Context.User.Identity.Name) == true)
            {
                ddlMonth.Items.Clear();
                for (int i = 1; i <= 12; i++)
                {
                    ListItem li = new ListItem(i.ToString(), i.ToString());
                    if (DateTime.Now.Month == i)
                        li.Selected = true;
                    else
                        li.Selected = false;
                    ddlMonth.Items.Add(li);
                }
                
                ddlYear.Items.Clear();
                for (int i = DateTime.Now.Year - 1; i <= DateTime.Now.Year + 1; i++)
                {
                    ListItem li = new ListItem(i.ToString(), i.ToString());
                    if (DateTime.Now.Year == i)
                        li.Selected = true;
                    else
                        li.Selected = false;
                    ddlYear.Items.Add(li);
                }
            }
            else
                Response.Redirect(Request.ApplicationPath);
        }
    }
    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            DateTime orderdatestart = new DateTime(int.Parse(ddlYear.SelectedValue), int.Parse(ddlMonth.SelectedValue), 1);
            DateTime activitydatestart = orderdatestart.AddMonths(-1);
            DateTime activitydateend = orderdatestart.AddMonths(1);
            System.Data.DataTable dt = dbUtil.dbGetDataTable("MY", string.Format(@"with eStore_Activity as 
                        ( 
	                        select a.ROW_ID,a.EMAIL_ADDRESS,a.CREATED_DATE,a.SOURCE_TYPE,a.ACTIVITY_TYPE,case when a.ACTIVITY_TYPE='eStore_See_Configured_Systems' then 1 else 0 end as config, a.eng_point,a.ESTORE_SOURCE,a.URL from (
	                        select *,case when a.URL like '%.Iotmart.com.cn%' then 'IoT ACN' when a.URL like '%.Iotmart.com.tw%' then 'IoT ATW' 
	                        when a.URL like '%ushop-iotmart.com.cn%' then 'UShop ACN' when a.URL like '%ushop-iotmart.com.tw%' then 'UShop ATW' 
	                        when a.URL like '%advantech.com.cn%' then 'eStore ACN' when a.URL like '%advantech.com.tw%' then 'eStore ATW' 
	                        when a.URL like '%advantech.eu%' then 'eStore AEU' 
	                        when a.URL like '%advantech.com%' then 'eStore AUS' else '' end as ESTORE_SOURCE
	                        from CurationPool.dbo.V_CURATION_ACTIVITY_ENGPOINT a where a.SOURCE_TYPE='estore' and a.eng_point>0 and a.EMAIL_ADDRESS<>'' 
	                        ) as a where a.CREATED_DATE >='{0}' and a.CREATED_DATE<'{1}'
                        )

                        select *,
                        ISNULL((select top 1 INTERESTED_PRODUCT_DISPLAY_NAME from PIS.dbo.MODELCATEGORY_INTERESTEDPRODUCT_MAPPING p where p.ITEM_ID=t.ModelNo and ITEM_TYPE='Model'),'') as IP,
                        ISNULL((select top 1 PRODUCT_GROUP_DISPLAY_NAME from PIS.dbo.MODELCATEGORY_INTERESTEDPRODUCT_MAPPING p where p.ITEM_ID=t.ModelNo and ITEM_TYPE='Model'),(select top 1 z.product_group from EAI_PRODUCT_HIERARCHY z where z.part_no=t.item_no)) as L1 from (
                        select distinct a.order_no, a.order_date, a.org, a.item_no, a.qty,
                        case a.sector when 'AOnline' then a.product_group else '' end as [sector2],
                        a.Customer_ID, a.[eStore Unica Score 1 Month Before Order], a.COUNTRY_NAME as Country, a.SALESGROUP, a.SALESOFFICE, a.REGION_CODE as State,  
                        (select top 1 z.RBU from SIEBEL_ACCOUNT z where z.ERP_ID=a.Customer_ID order by z.ACCOUNT_STATUS) as RBU,  
                        --(select SUM(z.Us_amt) from EAI_SALE_FACT z where z.order_no=a.order_no) as [US Amount], 
                        --(select SUM(z.EUR) from EAI_SALE_FACT z where z.order_no=a.order_no) as [EU Amount], 
                        a.Us_amt, a.EUR,
                        (select top 1 MODEL_NO from SAP_PRODUCT sp where sp.PART_NO = a.item_no) as ModelNo ,
                        (select top 1 PRODUCT_GROUP from SAP_PRODUCT sp where sp.PART_NO = a.item_no) as ProductGroup,
                        (select top 1 PRODUCT_DIVISION from SAP_PRODUCT sp where sp.PART_NO = a.item_no) as ProductDivision
                        --ROW_NUMBER() over(PARTITION BY a.order_no ORDER BY a.[eStore Unica Score 1 Month Before Order] desc) as row
                        from  
                        (  
                        select distinct a.order_no, a.item_no, a.order_date, a.org,a.Qty, a.sector,h.product_group, a.Customer_ID, a.Us_amt, a.EUR, b.COUNTRY_NAME,b.SALESGROUP,b.SALESOFFICE,b.REGION_CODE,sum(c.eng_point) as [eStore Unica Score 1 Month Before Order],SUM(c.config) as [Has Config]
                        from EAI_SALE_FACT a (nolock) inner join SAP_DIMCOMPANY b (nolock) on a.Customer_ID=b.COMPANY_ID and a.org=b.ORG_ID  
                        left join EAI_PRODUCT_HIERARCHY h on a.item_no = h.part_no
                        inner join ( 
	                        select distinct z1.eng_point, z2.ERPID,z1.ESTORE_SOURCE , z1.CREATED_DATE, z1.ACTIVITY_TYPE, z1.config 
                            from eStore_Activity z1 (nolock) inner join SIEBEL_CONTACT z2 (nolock) on z1.EMAIL_ADDRESS=z2.EMAIL_ADDRESS   
                            where z2.ERPID<>''
                            and z1.EMAIL_ADDRESS not in  
                             (select distinct z.EMAIL_ADDRESS from eStore_Activity z with (nolock) where z.EMAIL_ADDRESS is not null and z.SOURCE_TYPE='estore' and z.ACTIVITY_TYPE in ('Purchase'))
                        ) c on a.Customer_ID=c.ERPID 
                        where a.order_date>='{2}' and a.order_date<'{3}' and (c.CREATED_DATE between DATEADD(month,-1,a.order_date) and a.order_date) 
                        and a.sector like '%AOnline%'
                        --and (a.org in ('US01','EU10','KR01') or (a.org='TW01' and a.fact_zone='Taiwan'))
                        and a.fact_1234 = '1'  and a.bomseq >= 0 and a.itp_find <> 2  and a.itp_find <> 9  
                        and ( a.qty <> 0 or a.us_amt <> 0 or a.cancel_flag = ' ' )and a.BreakDown >= 0
                        group by a.order_no, a.item_no, a.order_date, a.org, a.Qty, a.sector,h.product_group, a.Customer_ID, a.Us_amt, a.EUR, b.COUNTRY_NAME,b.SALESGROUP,b.SALESOFFICE,b.REGION_CODE
                        ) a
                        where a.[eStore Unica Score 1 Month Before Order]>='20' or a.[Has Config]>=3
                        ) as t --where t.row=1
                        order by t.order_date, t.order_no", activitydatestart.ToString("yyyy-MM-dd"), activitydateend.ToString("yyyy-MM-dd"), orderdatestart.ToString("yyyyMMdd"), activitydateend.ToString("yyyyMMdd")));

            if (dt != null && dt.Rows.Count > 0)
            {
                System.IO.MemoryStream ms = Advantech.Myadvantech.DataAccess.ExcelUtil.DataTableToMemoryStream(dt);
                Response.AddHeader("Content-Disposition", string.Format("attachment; filename=CallForPrice_{0}.xlsx", orderdatestart.ToString("yyyy_MM_dd")));
                Response.BinaryWrite(ms.ToArray());
                ms.Close();
                ms.Dispose();
            }
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            Util.JSAlert(this.Page, string.Format("Error: {0}", ex.ToString()));
        }
    }
}