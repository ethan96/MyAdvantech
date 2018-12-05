using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Product_Compatibility : System.Web.UI.Page
{
    private bool? isadmin;
    public bool? IsAdmin
    {
        get
        {
            if (this.isadmin.HasValue == false)
            {
                if (Util.IsMyAdvantechIT() == true)
                    this.isadmin = true;
                else
                {
                    var orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
                    if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
                        orgid = Session["org_id_cbom"].ToString().ToUpper().Substring(0, 2);

                    var obj = dbUtil.dbExecuteScalar("CBOMV2", "select count(*) from CBOM_Admin where USERID = '" + Session["user_id"].ToString() + "' and ORGID = '" + orgid + "'");
                    if (obj != null && Convert.ToInt32(obj.ToString()) > 0)
                        this.isadmin = true;
                    else
                        this.isadmin = false;
                }
            }
            return this.isadmin.Value;
        }
        set
        {
            this.isadmin = value;
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Context.User.Identity.IsAuthenticated == false)
            Response.Redirect(string.Format("{0}home.aspx?ReturnUrl=/Lab/CBOMV2/Product_Compatibility.aspx", Request.ApplicationPath));

        if (this.IsAdmin == false)
            Response.Redirect(Request.ApplicationPath);

        //For TW user temporarily redirect to Product_Compatibility_TW page
        if (Session["org_id"] != null && Session["org_id"].ToString().ToUpper().StartsWith("TW"))
            Response.Redirect(ResolveUrl("~/Lab/CBOMV2/Product_Compatibility_TW.aspx"));

        if (!Page.IsPostBack)
        {
            ddlRelation.Items.Clear();
            foreach (var v in Enum.GetValues(typeof(Advantech.Myadvantech.DataAccess.Compatibility)))
                ddlRelation.Items.Add(new ListItem(v.ToString(), ((int)v).ToString()));

            if(ddlRelation.Items.FindByValue(((int)Advantech.Myadvantech.DataAccess.Compatibility.Incompatible).ToString()) !=null)
                ddlRelation.Items.FindByValue(((int)Advantech.Myadvantech.DataAccess.Compatibility.Incompatible).ToString()).Selected = true;
        }
    }
}