using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Includes_CBOM_CBOM_SharedComponent : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        this.ErrorMessage = string.Empty;

        //if (!Page.IsPostBack)
        //    BindSharedComponents();
    }

    public void BindSharedComponents(string key = "")
    {
        string orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
        if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
            orgid = Session["org_id_cbom"].ToString().ToUpper().Substring(0, 2);

        if (!string.IsNullOrEmpty(key))
            key = string.Format(" AND (CATEGORY_ID LIKE '%{0}%' OR CATEGORY_NOTE LIKE '{0}' ) ", key.Trim());
        rpSharedCategory.DataSource = dbUtil.dbGetDataTable("CBOMV2", "DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" + orgid + "_Shared' " +
            " SELECT ID, CATEGORY_ID,CATEGORY_NOTE,CONFIGURATION_RULE, DEFAULT_FLAG, REQUIRED_FLAG, EXPAND_FLAG, MAX_QTY FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child AND CATEGORY_TYPE = 2 " + key + " ORDER BY REPLACE(CATEGORY_ID, ' ', '')");
        rpSharedCategory.DataBind();
    }

    protected void rpSharedCategory_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "Delete")
        {
            try
            {
                string[] args = e.CommandArgument.ToString().Split(',');
                StringBuilder sb = new StringBuilder();
                sb.AppendFormat(" DECLARE @ID  hierarchyid SELECT @ID  = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '{0}' ", args[0]);
                sb.Append(" DELETE FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1 ; ");
                sb.AppendFormat(" DELETE FROM CBOM_CATALOG_CATEGORY_V2 where SHARED_CATEGORY_ID = '{0}' ", args[0]);
                dbUtil.dbExecuteNoQuery("CBOMV2", sb.ToString());
                BindSharedComponents(args[1]);
                ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction(); ShowTree();", true);
            }
            catch (Exception ex)
            {
                rpSharedCategory.DataSource = null;
                rpSharedCategory.DataBind();
                this.ErrorMessage = ex.ToString();
            }
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindSharedComponents(txtCategory.Text);
        ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction();", true);
    }

    private bool? admin;
    public bool Admin
    {
        get
        {
            if (this.admin.HasValue == false)
            {
                if (Util.IsMyAdvantechIT())
                {
                    this.admin = true;
                }
                else
                {
                    string orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
                    if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
                        orgid = Session["org_id_cbom"].ToString().ToUpper().Substring(0, 2);

                    var obj = dbUtil.dbExecuteScalar("CBOMV2", "select count(*) from CBOM_Admin where USERID = '" + Session["user_id"].ToString() + "' and ORGID = '" + orgid + "'");
                    if (obj != null && Convert.ToInt32(obj.ToString()) > 0)
                    {
                        this.admin = true;
                    }
                }
            }
            return this.admin.Value;
        }
    }

    private string ErrorMessage;

    protected void btnInitial_Click(object sender, EventArgs e)
    {
        BindSharedComponents();
        ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction();$.fancybox('#SharedComponentMenu');", true);
    }

    public string GetInitialButtonID
    {
        get
        {
            return this.btnInitial.ClientID;
        }
    }

    public string GetSearchTextBoxID
    {
        get
        {
            return this.txtCategory.ClientID;
        }
    }
}