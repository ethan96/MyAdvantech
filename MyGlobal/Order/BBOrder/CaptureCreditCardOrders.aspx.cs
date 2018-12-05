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
            txtinvdate_from.Text = DateTime.Now.ToString("yyyy/MM/dd");
            txtinvdate_to.Text = DateTime.Now.ToString("yyyy/MM/dd");
        }
    }

    class reList
    {
        public int Row_ID;
        public string Order_Date;
        public string Order_Number;
        public string Email;
        public string Status;
        public string Action;
    }
}