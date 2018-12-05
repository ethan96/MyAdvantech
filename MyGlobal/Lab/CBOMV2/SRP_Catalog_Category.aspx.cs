using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Net;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.SessionState;
using System.Configuration;


public partial class Lab_CBOMV2_CBOM_Catalog_Category : System.Web.UI.Page
{
    public static String orgid = String.Empty, rootid = String.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (Request["ID"] == null)               
                Response.Redirect(string.Format("{0}/Lab/CBOMV2/CBOM_Catalog_Create.aspx", Util.GetRuntimeSiteUrl()));
            else
                rootid = Request["ID"].ToString();
        }

        if (Session["org_id"] == null)
        {
            Util.JSAlertRedirect(Page, "ORG_ID is invalid.", string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));
            return;
        }
        //orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
        orgid = "TW";
        h2title.InnerText = "CBOM Catalog Category Maintenance" + " (ORG: " + orgid + ")";
    }


}