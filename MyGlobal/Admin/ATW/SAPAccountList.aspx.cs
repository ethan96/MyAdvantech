using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Advantech.Myadvantech.Business;

public partial class Admin_ATW_SAPAccountList : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            BindGV();
        }
    }

    private void BindGV()
    {
        gv1.DataSource = MyAdminBusinessLogic.getAllApplication2Company();
        gv1.DataBind();
    }

    public string GetSTATUS(object status)
    {
        return MyAdminBusinessLogic.GetSTATUS(status.ToString());
    }

    public string GetUrl(string applicationID)
    {
        return string.Format("CreateSAPAccount.aspx?ID={0}", applicationID);
    }
}