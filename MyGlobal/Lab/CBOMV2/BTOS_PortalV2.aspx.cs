using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_CBOMV2_BTOS_PortalV2 : System.Web.UI.Page
{
    public String ERPID = String.Empty, OrgID = String.Empty;
    public bool showCCTOS = false;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.IsAuthenticated == false || Session["company_id"] == null || Session["ORG_ID"] == null)
            Response.Redirect(string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));

        if(AuthUtil.IsADloG() && Util.IsTesting())
            Response.Redirect(string.Format("{0}/Order/BtosPortal_Hub.aspx", Util.GetRuntimeSiteUrl()));

        ERPID = Session["company_id"].ToString().ToUpper();
        OrgID = Session["ORG_ID"].ToString().ToUpper();
        if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
            OrgID = Session["org_id_cbom"].ToString().ToUpper();

        if (!Page.IsPostBack)
        {
            System.Data.DataTable cctosDt = dbUtil.dbGetDataTable("MY", string.Format("SELECT ID, PART_NO FROM PROJECT_CATALOG_CATEGORY WHERE COMPANY_ID='{0}'", ERPID));
            if (cctosDt != null && cctosDt.Rows.Count > 0)
            {
                CCTOS.DataSource = cctosDt;
                this.showCCTOS = true;
            }


            String str = "DECLARE @Child hierarchyid " +
                        " SELECT @Child = HIE_ID FROM CBOM_CATALOG_V2 " +
                        " WHERE ID = '" + OrgID.Substring(0, 2) + "_Root' " +
                        " SELECT ID,CATALOG_NAME FROM CBOM_CATALOG_V2 " +
                        " WHERE HIE_ID.GetAncestor(1) = @Child " +
                        " ORDER BY SEQ_NO";

            rp_BTOS.DataSource = dbUtil.dbGetDataTable("CBOMV2", str);
            rp_BTOS.DataBind();
        }
    }
    protected void rp_BTOS_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            if (this.showCCTOS == true)
                e.Item.Visible = true;
            else
                e.Item.Visible = false;
        }
    }
}