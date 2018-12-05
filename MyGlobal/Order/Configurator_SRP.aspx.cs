using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Advantech.Myadvantech.DataAccess;
using Advantech.Myadvantech.DataAccess.DataCore;
using System.Text;

public partial class Order_Configurator_SRP : System.Web.UI.Page
{
    public string RealPartNo = string.Empty;
    public string VirtualPartNo = string.Empty;
    public string CurrencySign = string.Empty;
    public string DefaultListPrice;
    public string DefaultUnitPrice;
    public int BTOSQTY = 1;
    public string PowerCordPanelID = string.Empty;
    //private List<CBOM_CATEGORY_RECORD> SRP_MappingList;
    protected void Page_Load(object sender, EventArgs e)
    {
        //TODO卡權限

        if (string.IsNullOrEmpty(Request["RootID"]) || string.IsNullOrEmpty(Request["QTY"]))
            Response.Redirect(Request.ApplicationPath);

        this.Form.DefaultButton = btnDefault.UniqueID;//set default button

        if (!Page.IsPostBack)
        {
            //ICC 2017/3/20 Use TW org to get SRP configurator BOM
            //SRPBTO srp = CBOMV2_ConfiguratorDAL.GetSRPConfigRecord(realID, Session["ORG_ID"].ToString().Substring(0, 2));
            SRPBTO srp = CBOMV2_ConfiguratorDAL.GetSRPConfigRecord(Request["RootID"].ToString(), "TW");
            if (string.IsNullOrEmpty(srp.RealPartNo))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "redirect", "alert('This SRP item does not exist!'); window.location='" + Request.ApplicationPath + "';", true);
                return;
            }

            this.RealPartNo = srp.RealPartNo;
            this.VirtualPartNo = srp.BTOSName;
            int.TryParse(Request["QTY"].ToString(), out this.BTOSQTY);

            decimal lp = 0m;
            decimal up = 0m;
            CBOMV2_Configurator c = new CBOMV2_Configurator();
            c.GetCurrencySign(srp.RealPartNo, ref this.CurrencySign);
            c.GetSRPListPriceAndUnitPrice(srp.RealPartNo, ref lp, ref up);

            string priceFormat = "{0:n}";
            if (this.CurrencySign.ToUpper() == "NT")
                priceFormat = "{0:n0}";

            this.DefaultListPrice = string.Format(priceFormat, lp * this.BTOSQTY);
            this.DefaultUnitPrice = string.Format(priceFormat, up * this.BTOSQTY);

            rpDefaultpackage.DataSource = srp.DefaultPackage.children;
            rpDefaultpackage.DataBind();

            rpOptionLeft.DataSource = srp.OptionPackage.children.Take(3);
            rpOptionLeft.DataBind();

            rpOptionRight.DataSource = srp.OptionPackage.children.Skip(3);
            rpOptionRight.DataBind();
        }
    }
    protected void rpDefaultpackage_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            EasyUITreeNode node = (EasyUITreeNode)e.Item.DataItem;
            Literal component = e.Item.FindControl("ltDefaultComponent") as Literal;
            TextBox txtDefaultQty = e.Item.FindControl("txtDefaultQty") as TextBox;

            StringBuilder text = new StringBuilder();
            text.AppendFormat("<p style=\"font-weight: bold;\">{0}: {1}</p>", node.text, node.desc);
            foreach (var subnode in node.children)
            {
                text.AppendFormat("<p style=\"margin-left: 30px;\">{0}</p>", subnode.desc);
                txtDefaultQty.Attributes.Add("data-qty", subnode.qty.ToString());
                txtDefaultQty.Text = subnode.qty.ToString();
            }

            component.Text = text.ToString();
        }
    }
    protected void rpOption_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            EasyUITreeNode node = (EasyUITreeNode)e.Item.DataItem;
            Repeater rp = e.Item.FindControl("rpOptionChild") as Repeater;
            CBOM_SRP_Remark rm = e.Item.FindControl("rm") as CBOM_SRP_Remark;

            rm.Visible = false;
            int serialNo = node.configurationrule + 1;

            foreach (var child in node.children)
            {
                if (serialNo == 0 & node.children[0] != null)
                {
                    rp.Visible = false;
                    rm.Visible = true;
                    rm.RemarkText = node.children[0].text;
                    rm.RemarkData = node.children[0].children;
                }

                if (serialNo == 401)
                    child.virtualid = "PowerCord";
                else
                    child.virtualid = string.Empty;

                child.configurationrule = serialNo;
                serialNo++;
            }

            rp.DataSource = node.children;
            rp.DataBind();
        }
    }
    protected void rpOptionChild_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            EasyUITreeNode node = (EasyUITreeNode)e.Item.DataItem;

            CBOM_SRP_PowerCord uc = e.Item.FindControl("pcd") as CBOM_SRP_PowerCord;

            if (node.configurationrule == 401)
            {
                //string org = Session["ORG_ID"].ToString().Substring(0, 2);
                string org = "TW";
                List<EasyUITreeNode> pc = CBOMV2_ConfiguratorDAL.GetConfigRecord(string.Format("{0}_Power cord", org), Session["ORG_ID"].ToString(), org, 1);
                if (pc != null && pc.Count > 0)
                {
                    uc.PowerCordData = pc[0].children;
                    this.PowerCordPanelID = uc.GetPowerCordID;
                }
            }
            else
                uc.Visible = false;
        }
    }
}