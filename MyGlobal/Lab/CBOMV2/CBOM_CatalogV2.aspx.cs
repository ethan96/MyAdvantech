using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_CBOM_CatalogV2 : System.Web.UI.Page
{
    public static String orgid = String.Empty, rootid = String.Empty, userid = String.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
        if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
            orgid = Session["org_id_cbom"].ToString().ToUpper().Substring(0, 2);
        userid = Session["user_id"].ToString();

        if (!Page.IsPostBack)
        {
            if (Request.IsAuthenticated == false)
                Response.Redirect(string.Format("{0}home.aspx?ReturnUrl=/Lab/CBOMV2/CBOM_Catalog_Create.aspx", Request.ApplicationPath));

            if (!Util.IsAEUIT())
            {
                var obj = dbUtil.dbExecuteScalar("CBOMV2", "select count(*) from CBOM_Admin where USERID = '" + Session["user_id"].ToString() + "' and ORGID = '" + orgid + "'");
                if (obj == null || Convert.ToInt32(obj.ToString()) == 0)
                    Response.Redirect(string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));
            }

            if (Session["org_id"] == null)
            {
                Util.JSAlertRedirect(Page, "ORG_ID is invalid.", string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));
                return;
            }
        }

        h2title.InnerText = "CBOM Catalog Maintenance" + " (ORG: " + orgid + ")";
    }
}