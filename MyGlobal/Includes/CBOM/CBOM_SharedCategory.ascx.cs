using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Includes_CBOM_CBOM_SharedCategory : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        this.ErrorMessage = string.Empty;

        //if (!Page.IsPostBack)
        //    BindSharedCategories();
    }

    public void BindSharedCategories(string key = "")
    {
        string orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
        if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
            orgid = Session["org_id_cbom"].ToString().ToUpper().Substring(0, 2);

        if (!string.IsNullOrEmpty(key))
            key = string.Format(" AND (CATEGORY_ID LIKE '%{0}%' OR CATEGORY_NOTE LIKE '{0}' ) ", key.Trim());
        rpSharedCategory.DataSource = dbUtil.dbGetDataTable("CBOMV2", "DECLARE @Child hierarchyid SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" + orgid + "_Shared' " +
            " SELECT ID, CATEGORY_ID,CATEGORY_NOTE, REQUIRED_FLAG, EXPAND_FLAG, MAX_QTY FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.GetAncestor(1) = @Child AND CATEGORY_TYPE = 1 " + key + " ORDER BY REPLACE(CATEGORY_ID, ' ', '')");
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
                sb.Append(" DELETE FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1;");
                sb.AppendFormat(" DELETE FROM CBOM_CATALOG_CATEGORY_V2 WHERE SHARED_CATEGORY_ID = '{0}' ", args[0]);
                dbUtil.dbExecuteNoQuery("CBOMV2", sb.ToString());
                BindSharedCategories(args[1]);
                ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction(); ShowTree();", true);
            }
            catch (Exception ex)
            {
                rpSharedCategory.DataSource = null;
                rpSharedCategory.DataBind();
                this.ErrorMessage = ex.ToString();
            }
        }
        else if (e.CommandName == "Edit")
        {
            this.SetRepeaterControls(e, true);
            ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction();", true);
        }
        else if (e.CommandName == "Update")
        {
            try
            {
                TextBox txtCategoryID = e.Item.FindControl("txtCategoryID") as TextBox;
                if (string.IsNullOrEmpty(txtCategoryID.Text))
                {
                    txtCategoryID.Focus();
                    ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "jsalert", "alert('Category ID cannot be empty!');", true);
                    return;
                }

                TextBox txtCategoryNote = e.Item.FindControl("txtCategoryNote") as TextBox;
                if (string.IsNullOrEmpty(txtCategoryNote.Text))
                {
                    txtCategoryNote.Focus();
                    ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "jsalert", "alert('Category note cannot be empty!');", true);
                    return;
                }

                string[] args = e.CommandArgument.ToString().Split(',');
                StringBuilder sb = new StringBuilder();
                sb.AppendFormat(" UPDATE CBOM_CATALOG_CATEGORY_V2 SET CATEGORY_ID = N'{0}', CATEGORY_NOTE = N'{1}' WHERE ID = '{2}'; ", txtCategoryID.Text.Trim(), txtCategoryNote.Text.Trim(), args[0]);
                sb.AppendFormat(" UPDATE CBOM_CATALOG_CATEGORY_V2 SET CATEGORY_ID = N'{0}', CATEGORY_NOTE = N'{1}' WHERE SHARED_CATEGORY_ID = '{2}' ", txtCategoryID.Text.Trim(), txtCategoryNote.Text.Trim(), args[0]);
                dbUtil.dbExecuteNoQuery("CBOMV2", sb.ToString());
                BindSharedCategories(args[1]);
                ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction(); ShowTree();", true);
            }
            catch (Exception ex)
            {
                rpSharedCategory.DataSource = null;
                rpSharedCategory.DataBind();
                this.ErrorMessage = ex.ToString();
            }
        }
        else if (e.CommandName == "Cancel")
        {
            this.SetRepeaterControls(e, false);
            ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction();", true);
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        BindSharedCategories(txtCategory.Text);
        ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction();", true);
    }

    private void SetRepeaterControls(RepeaterCommandEventArgs e, bool flag)
    {
        if (flag == true)
        {
            ((TextBox)e.Item.FindControl("txtCategoryID")).Text = ((HyperLink)e.Item.FindControl("hlCategoryID")).Text;
            ((TextBox)e.Item.FindControl("txtCategoryNote")).Text = ((Label)e.Item.FindControl("lbCategoryNote")).Text;
        }

        ((HyperLink)e.Item.FindControl("hlCategoryID")).Visible = !flag;
        ((Label)e.Item.FindControl("lbCategoryNote")).Visible = !flag;
        ((ImageButton)e.Item.FindControl("btnEdit")).Visible = !flag;
        ((ImageButton)e.Item.FindControl("btnDelete")).Visible = !flag;

        ((TextBox)e.Item.FindControl("txtCategoryID")).Visible = flag;
        ((TextBox)e.Item.FindControl("txtCategoryNote")).Visible = flag;
        ((ImageButton)e.Item.FindControl("btnUpdate")).Visible = flag;
        ((ImageButton)e.Item.FindControl("btnCancel")).Visible = flag;
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

    public string ErrorMessage;

    protected void btnInitial_Click(object sender, EventArgs e)
    {
        BindSharedCategories();
        ScriptManager.RegisterStartupScript(upSharedCategory, upSharedCategory.GetType(), "resize", "ResizeFunction();$.fancybox('#SharedCategoryMenu');", true);
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