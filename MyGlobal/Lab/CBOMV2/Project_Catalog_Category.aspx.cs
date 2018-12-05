using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_CBOMV2_CBOM_Project_Category : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.IsAuthenticated == false)
            Response.Redirect(Request.ApplicationPath);

        if (Session["org_id"] == null || !Session["org_id"].ToString().StartsWith("CN") 
            || Session["company_id"] == null || !Session["company_id"].ToString().ToUpper().Equals(Advantech.Myadvantech.DataAccess.AcnProjectCompanyID.C103379.ToString()))
            Response.Redirect(Request.ApplicationPath);

        if (!Page.IsPostBack)
        {
            hfCompanyID.Value = Session["company_id"].ToString();
            //DataTable dt = Advantech.Myadvantech.DataAccess.DataCore.CBOMV2_ConfiguratorDAL.ExpandBOM("SRP-FEC220-AE", "TWH1");
        }
    }
}