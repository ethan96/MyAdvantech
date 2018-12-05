using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;

public partial class CIS_TEMPLATE : System.Web.UI.Page
{
    #region Page Load
    protected void Page_Load(object sender, EventArgs e)
    {
        var rnd = new Random();
        System.Threading.Thread.Sleep(rnd.Next(30000, 300001));
        Response.Redirect(Util.GetRuntimeSiteUrl() + "/home.aspx");
        if (!Page.IsPostBack)
        {
            //Session["user_id"] = "abow.wang@advantech.com.tw";
            //Session["UniCode"] = "3707a54e063f4e909dc6fccf709914b3";
            if (false)
            {
                //Response.Redirect("./check_login.aspx?user_id=" + Session["user_id"]);
            }
            //string strErrMsg = "";
            string strSQL = "SELECT SEQ,ID,FILE_NAME,DESCRIPTION,CREATE_DATE FROM b2bsa.CIS_USER_DEFINE_MAIN WHERE CREATE_BY = '" + Session["user_id"] + "' ORDER BY CREATE_DATE DESC";
            DataTable dt = dbUtil.dbGetDataTable("QS", strSQL);
            if (dt == null || dt.Rows.Count == 0 || dt.Rows[0][0] == DBNull.Value)
            {
                Response.Redirect("./CIS_QUERY.aspx");
            }
            SqlDataSource1.SelectCommand = "SELECT SEQ,ID,FILE_NAME,DESCRIPTION,CREATE_DATE FROM b2bsa.CIS_USER_DEFINE_MAIN WHERE CREATE_BY = '" + Session["user_id"] + "' ORDER BY CREATE_DATE DESC";

            
        }
    }
    #endregion

    #region Message Show
    private void MsgShow(string message)
    {
        lblMsgContext.Text = message;
    }
    #endregion

    #region Footer
    protected void ibtnQuery_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("./CIS_QUERY.aspx");
    }
    protected void ibtnTemplate_Click(object sender, ImageClickEventArgs e)
    {
        Response.Redirect("./CIS_TEMPLATE.aspx");
    }
    #endregion

    #region GridView Action
    protected void gvQueryHistory_RowCommand(object sender, GridViewCommandEventArgs e)
    {

        switch (e.CommandName)
        {
            case "implement":
                Response.Redirect("CIS_QUERY.aspx?UNICODE=" + gvQueryHistory.Rows[Convert.ToInt16((e.CommandArgument))].Cells[1].Text + "");
                break;
            case "query":
                Response.Redirect("DefineQuery.aspx?UNICODE=" + gvQueryHistory.Rows[Convert.ToInt16((e.CommandArgument))].Cells[1].Text + "");
                break;
        }
    }

    protected void gvQueryHistory_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        SqlDataSource1.SelectCommand = "SELECT SEQ,ID,FILE_NAME,DESCRIPTION,CREATE_DATE FROM b2bsa.CIS_USER_DEFINE_MAIN WHERE CREATE_BY = '" + Session["user_id"] + "' ORDER BY CREATE_DATE DESC";
    }
    protected void gvQueryHistory_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        SqlDataSource1.DeleteCommand = "DELETE b2bsa.CIS_USER_DEFINE_MAIN WHERE SEQ = N'" + gvQueryHistory.Rows[e.RowIndex].Cells[0].Text + "'";
        SqlDataSource1.SelectCommand = "SELECT SEQ,ID,FILE_NAME,DESCRIPTION,CREATE_DATE FROM b2bsa.CIS_USER_DEFINE_MAIN WHERE CREATE_BY = '" + Session["user_id"] + "' ORDER BY CREATE_DATE DESC";
    }

    protected void gvQueryHistory_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Width = 150;
            e.Row.Cells[3].Width = 550;
            e.Row.Cells[4].Width = 150;
            e.Row.Cells[5].Width = 50;
            e.Row.Cells[6].Width = 50;
            e.Row.Cells[7].Width = 50;
            try
            {
                if (e.Row.RowType == DataControlRowType.DataRow)
                {
                    //e.Row.Cells[2].Text = "<p id = '" + e.Row.Cells[0].Text + "' onmouseover = 'javascript:getDesc()' onmouseout ='javascript:clearData()'>" + e.Row.Cells[2].Text + "</p>";
                }
            }
            catch
            {
                //donothing
            }
        }
    }

    protected void gvQueryHistory_Sorting(object sender, GridViewSortEventArgs e)
    {
        SqlDataSource1.SelectCommand = "SELECT SEQ,ID,FILE_NAME,DESCRIPTION,CREATE_DATE FROM b2bsa.CIS_USER_DEFINE_MAIN WHERE CREATE_BY = '" + Session["user_id"] + "' ORDER BY CREATE_DATE DESC";
    }
    #endregion
}
