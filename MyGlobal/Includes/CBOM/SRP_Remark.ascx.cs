using Advantech.Myadvantech.DataAccess;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class CBOM_SRP_Remark : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    private string remarktext = string.Empty;
    public string RemarkText
    {
        get
        {
            return this.remarktext;
        }
        set
        {
            this.remarktext = value;
        }
    }

    public List<EasyUITreeNode> RemarkData
    {
        set
        {
            this.rpSRP.DataSource = value;
            this.rpSRP.DataBind();
        }
    }
    protected void rpSRP_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        //                        <input type="radio" name="Remark" class="Remark" data-pn='<%#Eval("text") %>' />
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            EasyUITreeNode node = (EasyUITreeNode)e.Item.DataItem;
            Literal lt = e.Item.FindControl("lt") as Literal;

            string check = string.Empty;
            if (node.seq == 1)
                check = "checked = 'checked'";
            lt.Text = string.Format("<input type=\"radio\" name=\"Remark\" class=\"Remark\" data-pn='{0}' {1} />", node.text, check);
        }
    }
}