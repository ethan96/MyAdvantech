using Advantech.Myadvantech.DataAccess;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Order_BBOrder_OrderList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            if (Util.IsBBCustomerCare() == true)
            {
                ddlStatus.Items.Clear();
                ddlStatus.Items.Add(new ListItem("Not limited", ""));
                ddlStatus.Items.Add(new ListItem("Failed to SAP", Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.FailedToSAP.ToString()));
                ddlStatus.Items.Add(new ListItem("Need ERP ID", Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.NeedERPID.ToString()));
                ddlStatus.Items.Add(new ListItem("Ready to SAP", Advantech.Myadvantech.DataAccess.BBeStoreOrderStatus.ReadyToSAP.ToString()));
            }
            else
                Response.Redirect(Request.ApplicationPath);
        }
    }
}