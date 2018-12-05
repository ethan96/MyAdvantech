using Advantech.Myadvantech.DataAccess;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class CBOM_SRP_PowerCord : System.Web.UI.UserControl
{
    public string GetPowerCordID
    {
        get
        {
            return this.pnSrp.ClientID;
        }
    }

    public List<EasyUITreeNode> PowerCordData
    {
        set
        {
            this.rpSRP.DataSource = value;
            this.rpSRP.DataBind();
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void rpSRP_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            EasyUITreeNode node = (EasyUITreeNode)e.Item.DataItem;
            Literal lt = e.Item.FindControl("lt") as Literal;

            string currencySign = string.Empty;
            decimal listprice = 0m;
            decimal unitprice = 0m;

            CBOMV2_Configurator c = new CBOMV2_Configurator();
            bool result = c.GetCurrencySign(node.text, ref currencySign);
            c.GetSRPListPriceAndUnitPrice(node.text, ref listprice, ref unitprice);

            string priceFormat = "{0:n}";
            if (currencySign.ToUpper() == "NT")
                priceFormat = "{0:n0}";

            string priceAndATP = string.Empty;
            if (result == false)
                priceAndATP = string.Format("data-pn=\"{0}\" data-desc=\"{1}\" data-curr=\"{2}\" data-listprice=\"{3}\" data-unitprice=\"{4}\" ", node.text, node.desc, currencySign, string.Format(priceFormat, listprice), string.Format(priceFormat, unitprice));
            lt.Text = string.Format("<input type=\"radio\" name=\"PowerCord\" {0}/>", priceAndATP);
        }
    }
}