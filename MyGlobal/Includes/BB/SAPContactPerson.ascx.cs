using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Includes_BB_SAPContactPerson : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    public HiddenField OrderNo
    {
        get
        {
            return this.hfOrderNo;
        }
    }
}