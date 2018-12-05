using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class My_InterCon_PrjTmpList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter Prj_M_A = new InterConPrjRegTableAdapters.MY_PRJ_REG_MASTERTableAdapter();
            InterConPrjReg.MY_PRJ_REG_MASTERDataTable Prj_M_DT = new InterConPrjReg.MY_PRJ_REG_MASTERDataTable();

            if (MailUtil.IsInRole("MyAdvantech") || MailUtil.IsInRole("ChannelManagement.ACL") || MailUtil.IsInRole("DMKT.ACL"))
                Prj_M_DT = Prj_M_A.GetData();
            else if (Util.IsInternalUser2() && Session["company_id"] != null && !string.IsNullOrEmpty(Session["company_id"].ToString()))
                Prj_M_DT = Prj_M_A.GetDataByERPID(Session["company_id"].ToString());
            else if (Session["company_id"] != null && !string.IsNullOrEmpty(Session["company_id"].ToString()) && Session["company_id"].ToString().Equals("EIITME22", StringComparison.InvariantCultureIgnoreCase))
                Prj_M_DT = Prj_M_A.GetDataByERPID(Session["company_id"].ToString());
            else
                Prj_M_DT = Prj_M_A.GetByCreator(User.Identity.Name);

            DataTable dt = dbUtil.dbGetDataTable("MYLOCAL", "SELECT PRJ_ROW_ID FROM [MY_PRJ_REG_AUDIT] where [STATUS] = -1");
            if (dt != null && dt.Rows.Count > 0)
            {
                List<string> tmpID = new List<string>();
                foreach (DataRow dr in dt.Rows)
                    tmpID.Add(dr[0].ToString());
                List<InterConPrjReg.MY_PRJ_REG_MASTERRow> filter = new List<InterConPrjReg.MY_PRJ_REG_MASTERRow>();
                //for (int i = Prj_M_DT.Rows.Count - 1; i >= 0; i++)
                //{
                //    InterConPrjReg.MY_PRJ_REG_MASTERRow dr = (InterConPrjReg.MY_PRJ_REG_MASTERRow)Prj_M_DT.Rows[i];
                //    if (!tmpID.Contains(dr.ROW_ID))
                //        dr.Delete();
                //}
                foreach (DataRow dr in Prj_M_DT.Rows)
                {
                    InterConPrjReg.MY_PRJ_REG_MASTERRow row = (InterConPrjReg.MY_PRJ_REG_MASTERRow)dr;
                    if (tmpID.Contains(row.ROW_ID))
                        filter.Add(row);
                }
                if (filter.Count > 0)
                {
                    gvTempList.DataSource = filter.CopyToDataTable();
                    gvTempList.DataBind();
                }
                //gvTempList.DataSource = filter.CopyToDataTable();
                //gvTempList.DataBind();
            }
        }
    }
    protected void gvTempList_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            DataRowView row = (DataRowView)e.Row.DataItem;
            if (row["CREATED_BY"].ToString().ToUpper().Equals(Context.User.Identity.Name.ToUpper()) == false)
            {
                HyperLink hl = (HyperLink)e.Row.Cells[0].FindControl("hlUrl");
                hl.CssClass = "NoAccess";
                hl.NavigateUrl = Request.ApplicationPath;
            }
        }
    }
}