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
        if (Session["org_id"] == null)
        {
            Util.JSAlertRedirect(Page, "ORG_ID is invalid.", string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));
            return;
        }

        orgid = Session["org_id"].ToString().ToUpper().Substring(0, 2);
        if (Session["org_id_cbom"] != null && !string.IsNullOrEmpty(Session["org_id_cbom"].ToString()))
            orgid = Session["org_id_cbom"].ToString().ToUpper().Substring(0, 2);

        if (!Page.IsPostBack)
        {
            if (Request["ID"] == null)               
                Response.Redirect(string.Format("{0}/Lab/CBOMV2/CBOM_Catalog_Create.aspx", Util.GetRuntimeSiteUrl()));

            if (!Util.IsMyAdvantechIT())
            {
                var obj = dbUtil.dbExecuteScalar("CBOMV2", "select count(*) from CBOM_Admin where USERID = '" + Session["user_id"].ToString() + "' and ORGID = '" + orgid + "'");
                if (obj == null || Convert.ToInt32(obj.ToString()) == 0)
                Response.Redirect(string.Format("{0}/home.aspx", Util.GetRuntimeSiteUrl()));
            }
            
            rootid = Request["ID"].ToString();

            if (Session["org_id"].ToString().Equals("EU80", StringComparison.InvariantCultureIgnoreCase))
            {
                AddCBOMVisibilityControl.Visible = true;
            }else
            {
                AddCBOMVisibilityControl.Visible = false;
            }
        }

        h2title.InnerText = "CBOM Catalog Category Maintenance" + " (ORG: " + orgid + ")";


        GetVisibleCompanyID(rootid);
    }


    public void GetVisibleCompanyID(string categoryid)
    {

        //rootid

        String sql = "Select ROW_ID, Company_ID, '' as Company_Name from [ASSIGNED_CTOS] Where CATEGORY_ID='" + categoryid + "'";
        DataTable dt = dbUtil.dbGetDataTable("CBOMV2", sql);
        gv1.DataSource = dt;
        //Lab_CBOMV2_CBOM_Catalog_Category.gv1
        gv1.DataBind();
        this.UPCBOMVisibilityControl.Update();

    }
  

    #region forBUGFixing
    public static void CheckNoFather()
    {
        // 檢查是否有節點沒有father 
        // 20161019 確認清除完畢

        String str = "DECLARE @ID  hierarchyid " +
                     " SELECT @ID  = HIE_ID " +
                     " FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '0' " +
                     " SELECT * FROM CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID.IsDescendantOf(@ID) = 1 ";
        DataTable dt = dbUtil.dbGetDataTable("CBOMV2", str);
        List<String> temp = new List<string>();

        foreach (DataRow d in dt.Rows)
        {
            String str2 = "DECLARE @ID  hierarchyid  SELECT @ID  = HIE_ID  " +
                          " FROM CBOM_CATALOG_CATEGORY_V2 WHERE ID = '" + d["ID"].ToString() + "' " +
                          "select ID from  CBOM_CATALOG_CATEGORY_V2 WHERE HIE_ID = @ID.GetAncestor(1) ";
            var obj = dbUtil.dbExecuteScalar("CBOMV2", str2);
            if (obj == null)
            {
                temp.Add(d["ID"].ToString());
            }
        }
        str = "";
        foreach (String s in temp)
        {
            str += ", '" + s + "'";
        }
    }

    public static void DeleteMultipleSharedIDBug()
    {
        // Shared Component當初造成的bug - 對應到錯的shared guid問題，可用此function刪除有問題的data
        // 20161019 確認清除完畢

        List<String> strlist = new List<string>();

        String str = "DECLARE @Child hierarchyid " +
                    " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                    " WHERE ID = ' ' " +
                    " SELECT ID, CATEGORY_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                    " WHERE HIE_ID.GetAncestor(1) = @Child ";
        DataTable dt = dbUtil.dbGetDataTable("CBOMV2", str);

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow d in dt.Rows)
            {
                String str2 = "select distinct CATEGORY_ID from CBOM_CATALOG_CATEGORY_V2 where SHARED_CATEGORY_ID = '" + d["id"].ToString() + "'";
                DataTable dt2 = dbUtil.dbGetDataTable("CBOMV2", str2);

                if (dt2.Rows.Count > 1)
                {
                    strlist.Add(d["id"].ToString());
                    //SQLProvider.dbExecuteNoQuery("CBOMV2", "delete from CBOM_CATALOG_CATEGORY_V2 where SHARED_CATEGORY_ID = '" + d["id"].ToString() + "'");
                }
            }
        }
    }

    public static void SyncSharedNodeREQUIREDDEFAULTEXPAND()
    {
        String str = "DECLARE @Child hierarchyid " +
                       " SELECT @Child = HIE_ID FROM CBOM_CATALOG_CATEGORY_V2 " +
                       " WHERE ID = 'CN_SHARED' " +
                       " SELECT * FROM CBOM_CATALOG_CATEGORY_V2 " +
                       " WHERE HIE_ID.GetAncestor(1) = @Child ";
        DataTable dt = dbUtil.dbGetDataTable("CBOMV2", str);

        if (dt.Rows.Count > 0)
        {
            foreach (DataRow d in dt.Rows)
            {
                String updatestr = "update CBOM_CATALOG_CATEGORY_V2 " +
                                " set MAX_QTY = " + Convert.ToInt32(d["MAX_QTY"].ToString()) + ", " +
                                " EXPAND_FLAG = " + Convert.ToInt32(d["EXPAND_FLAG"].ToString()) + ", REQUIRED_FLAG = " + Convert.ToInt32(d["REQUIRED_FLAG"].ToString()) + ", DEFAULT_FLAG = " + Convert.ToInt32(d["DEFAULT_FLAG"].ToString()) + " " +
                                " where SHARED_CATEGORY_ID = '" + d["ID"].ToString() + "'";
                dbUtil.dbExecuteNoQuery("CBOMV2", updatestr);                
            }
        }    
    }

    #endregion


    protected void gv1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //DataRowView rowView = (DataRowView)e.Row.DataItem;
            String _CompanyID = ((System.Data.DataRowView)e.Row.DataItem).Row[1].ToString().Replace("'","''");
            String _sql = "select company_name from sap_dimcompany where company_id='" + _CompanyID + "'";
            Object _company_name = dbUtil.dbExecuteScalar("MY", _sql);
            if(_company_name != null)
            {
                e.Row.Cells[2].Text = _company_name.ToString();
            }
        }
    }
}