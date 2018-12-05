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

        for (int i = DateTime.Now.Year; i <= DateTime.Now.Year + 15; i++)
        {
            dlCCardExpYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }

    }
}