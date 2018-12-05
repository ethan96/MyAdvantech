using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Lab_IoTSummitReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (Request.IsAuthenticated == false)
                Response.Redirect(string.Format("{0}home.aspx?ReturnUrl=/Lab/IoTSummitReport.aspx", Request.ApplicationPath));
            if (this.IsAdmin == false)
                hlDownload.Visible = false;
        }
    }
    
    public bool IsAdmin
    {
        get
        {
            if (Util.IsMyAdvantechIT() == true || MailUtil.IsInRole("DMKT.ACL"))
                return true;
            List<string> admins = new List<string>() { "carolh.huang@advantech.com.tw", "mandy.lin@advantech.com.tw", "shi.jun@advantech.com.cn", "xuejing.dong@advantech.com.cn" };
            return admins.Contains(Context.User.Identity.Name.ToLower());
        }
    }

}