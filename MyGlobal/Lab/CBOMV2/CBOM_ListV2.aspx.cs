using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_CBOMV2_CBOM_ListV2 : System.Web.UI.Page
{
    public String ERPID = String.Empty, OrgID = String.Empty, RequestID = String.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (Request.IsAuthenticated == false)
                Response.Redirect(string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));

            // length < 7 will be Regional_Root or 0(universal), which will change database structure. CAN'T LET USER EDIT IT.
            if (Request["ID"] != null && Request["ID"].ToString().Length > 7)
                RequestID = Request["ID"].ToString();
            else
                Response.Redirect(string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));

            ERPID = Session["company_id"].ToString().ToUpper();
            OrgID = Session["ORG_ID"].ToString().ToUpper();
            if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
                OrgID = Session["org_id_cbom"].ToString().ToUpper();

            if (Util.IsMyAdvantechIT())
            {
                gvList.Columns[7].Visible = true;
            }
            else
            {
                var obj = dbUtil.dbExecuteScalar("CBOMV2", "select count(*) from CBOM_Admin where USERID = '" + Session["user_id"].ToString() + "' and ORGID = '" + OrgID.Substring(0, 2) + "'");
                if (obj != null && Convert.ToInt32(obj.ToString()) > 0)
                {
                    gvList.Columns[7].Visible = true;
                }
            }

            String str = "DECLARE @Child hierarchyid " +
                        " SELECT @Child = HIE_ID FROM CBOM_CATALOG_V2 " +
                        " WHERE ID = '" + RequestID + "' " +
                        " SELECT a.ID, a.CATALOG_NAME, a.CATALOG_DESC, a.CATEGORY_GUID, b.CATEGORY_ID as CATEGORY_NAME, " +
                        " (select count(*) from ASSIGNED_CTOS where category_id = a.CATEGORY_GUID) as VisibilityCount " +
                        " FROM CBOM_CATALOG_V2 a left join CBOM_CATALOG_CATEGORY_V2 b on a.CATEGORY_GUID = b.ID " +
                        " WHERE a.HIE_ID.GetAncestor(1) = @Child " +
                        " ORDER BY a.SEQ_NO";

            SqlDataSource1.SelectCommand = str;
        }
        ERPID = Session["company_id"].ToString().ToUpper();
        OrgID = Session["ORG_ID"].ToString().ToUpper();
        if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
            OrgID = Session["org_id_cbom"].ToString().ToUpper();
    }

    public String GetLocalName()
    {
        if (Request["ID"] == null)
            return String.Empty;

        var obj = dbUtil.dbExecuteScalar("CBOMV2", "select CATALOG_NAME FROM CBOM_CATALOG_V2 WHERE ID = '" + Request["ID"].ToString() + "'");

        if (obj == null)
            return String.Empty;
        else
            return obj.ToString();

    }

    protected void gvList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            HiddenField hfVisibilityCount = e.Row.FindControl("hfVisibilityCount") as HiddenField;
            HiddenField hf1 = e.Row.FindControl("hfConfig1") as HiddenField;
            String categoryid = hf1.Value;

            // Add line break
            e.Row.Cells[2].Text = e.Row.Cells[2].Text.Replace("\n", "<br />");

            if (AuthUtil.IsADloG())
            {             
                // Check the visibility control table for ADLOG
                if (Int32.Parse(hfVisibilityCount.Value) > 0)
                {
                    int count = Convert.ToInt32(dbUtil.dbExecuteScalar("CBOMV2", String.Format(" select count(*) as count from ASSIGNED_CTOS where category_id = '{0}' and company_id = '{1}' ", categoryid, ERPID)));
                    if (count == 0)
                        e.Row.Visible = false;
                }                
            }

            // Check BTOS parent orderable
            if (!AuthUtil.IsACN())
            {
                var CategoryName = dbUtil.dbExecuteScalar("CBOMV2", String.Format("SELECT TOP 1 CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 where ID = '{0}' ", categoryid));
                if (CategoryName != null && !String.IsNullOrEmpty(CategoryName.ToString()))
                {
                    int count = Convert.ToInt32(dbUtil.dbExecuteScalar("MY", String.Format(" select count(*) as count from sap_product_status_orderable where sales_org = '{0}' and part_no = '{1}'", Session["ORG_ID"].ToString(), CategoryName)));
                    if (count == 0)
                        e.Row.Visible = false;
                }
            }
        }
    }


    protected void imgBtnConfig_Click(object sender, ImageClickEventArgs e)
    {
        ImageButton ibtn = (ImageButton)sender;
        GridViewRow row = (GridViewRow)ibtn.NamingContainer;
        HiddenField hf1 = row.FindControl("hfConfig1") as HiddenField;
        HiddenField hf2 = row.FindControl("hfConfig2") as HiddenField;
        TextBox txtQty = row.FindControl("txtQty") as TextBox;

        int forparse = 1;
        if (!Int32.TryParse(txtQty.Text, out forparse))
        {
            errMsg.Text = "Qty value can only be numbers";
            return;
        }

        Response.Redirect(String.Format("~/Order/Configurator_new.aspx?ID={0}&NAME={1}&QTY={2}", hf1.Value, hf2.Value, txtQty.Text));
    }

    protected void imgBtnEdit_Click(object sender, ImageClickEventArgs e)
    {
        ImageButton ibtn = (ImageButton)sender;
        GridViewRow row = (GridViewRow)ibtn.NamingContainer;
        HiddenField hf1 = row.FindControl("hfConfig1") as HiddenField;
        HiddenField hf2 = row.FindControl("hfConfig2") as HiddenField;

        Response.Redirect(String.Format("~/Lab/CBOMV2/CBOM_Catalog_Category.aspx?ID={0}", hf1.Value));
    }
}