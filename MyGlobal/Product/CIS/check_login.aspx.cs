using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

public partial class check_login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string strUser_id = Request["user_id"];
        //strUser_id = "tc.chen@advantech.com.tw";
        if (false)
        {
            //Response.Redirect("http://172.20.1.13:2009/login.aspx?strSrcPage=" + Request.ServerVariables["HTTP_HOST"] + Request.ServerVariables["PATH_INFO"]); 
        }
        else
        {
            Session["user_id"] = strUser_id;
            //string strSQL = "";
            //string strErrMsg= "";
            //strSQL = "INSERT INTO CIS_LOGIN_LOG (EMAIL_ADDR) VALUES ('" + strUser_id + "')";
            dbUtil.dbExecuteNoQuery("QS", "INSERT INTO CMC_LOGIN_LOG (LOGIN_NAME,LOGIN_FUNCTION,LOGIN_DT) VALUES ('" + strUser_id + "','CIS',getdate())");
            Response.Redirect("http://172.20.1.13:2010/CIS/CIS_TEMPLATE.aspx");
        }

    }
}
