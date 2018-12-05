using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Includes_CBOM_ACN_C_CTOS : System.Web.UI.UserControl
{
    public System.Data.DataTable DataSource
    {
        set
        {
            this.rpCCTOS.DataSource = value;
            this.rpCCTOS.DataBind();
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        //lbMessage.Text = string.Empty;
    }
    //protected void rpCCTOS_ItemCommand(object source, RepeaterCommandEventArgs e)
    //{
    //    if (e.CommandName == "Add")
    //    {
    //        try
    //        {
    //            //GET PN
    //            object pn = dbUtil.dbExecuteScalar("MY", string.Format("SELECT TOP 1 PART_NO FROM PROJECT_CATALOG_CATEGORY WHERE ID = {0}", e.CommandArgument));
    //            if (pn == null || string.IsNullOrEmpty(pn.ToString()))
    //            {
    //                lbMessage.Text = "No project item.";
    //                return;
    //            }
    //            //GET DT
    //            System.Data.DataTable dt = Advantech.Myadvantech.DataAccess.DataCore.CBOMV2_ConfiguratorDAL.ExpandBOM(pn.ToString(), "CNH1");
    //            if (dt == null || dt.Rows.Count == 0)
    //            {
    //                lbMessage.Text = "Cannot expand BOM from SAP";
    //                return;
    //            }
    //            //Send to API
    //            string ERPID = Session["company_id"].ToString().ToUpper();
    //            string cartID = Session["CART_ID"].ToString();
    //            string currency = Session["Company_currency"].ToString();
    //            string orgID = Session["org_id"].ToString();

    //            List<Advantech.Myadvantech.DataAccess.ConfiguredItems> items = new List<Advantech.Myadvantech.DataAccess.ConfiguredItems>();
    //            //Add parent item first
    //            string[] pitem = pn.ToString().Split('-');
    //            if (pitem.Length != 3)
    //            {
    //                lbMessage.Text = string.Format("{0} does not have BTO parent item in SAP", pn);
    //                return;
    //            }
    //            string BTO = string.Format("{0}-{1}-BTO", pitem[0], pitem[1]);
    //            var btoCheck = this.CheckItemOrdereable(BTO, orgID);
    //            if (btoCheck.Item1 == false)
    //            {
    //                lbMessage.Text = string.Format("{0} cannot be added to cart", BTO);
    //                return;
    //            }
    //            else
    //                items.Add(btoCheck.Item2);

    //            //Add child item (耗材客供料請移除)
    //            foreach (System.Data.DataRow dr in dt.Rows)
    //            {
    //                //CheckItemOrdereable
    //                var check = this.CheckItemOrdereable(dr["IDNRK"].ToString().Trim(), orgID);
    //                if (check.Item1 == false)
    //                {
    //                    lbMessage.Text = string.Format("{0} cannot be added to cart", dr["IDNRK"].ToString());
    //                    return;
    //                }
    //                else
    //                    items.Add(check.Item2);
    //            }

    //            Advantech.Myadvantech.DataAccess.UpdateDBResult result = Advantech.Myadvantech.DataAccess.DataCore.CBOMV2_ConfiguratorDAL.Configurator2Cart(Newtonsoft.Json.JsonConvert.SerializeObject(items), ERPID, cartID, currency, orgID);

    //            if (result.IsUpdated == false)
    //            {
    //                lbMessage.Text = result.ServerMessage;
    //                return;
    //            }

    //            List<CartItem> cartlist = MyCartX.GetCartList(cartID);
    //            List<EWPartNo> _EWlist = MyCartX.GetExtendedWarranty();
    //            int EWFlag = 0;
    //            foreach (var c in cartlist)
    //            {
    //                foreach (var _ew in _EWlist)
    //                {
    //                    if (string.Equals(_ew.EW_PartNO, c.Part_No))
    //                        EWFlag = _ew.ID;
    //                }
    //            }
    //            if (EWFlag > 0)
    //            {
    //                CartItem _cartBtosParentitem = MyCartX.GetCartItem(cartID, MyCartX.getBtosParentLineNo(cartID));
    //                _cartBtosParentitem.Ew_Flag = EWFlag;
    //                MyCartX.addExtendedWarrantyV2(_cartBtosParentitem, EWFlag);
    //            }

    //            //Redirect to CartListV2
    //            Response.Redirect(string.Format("{0}Cart_ListV2.aspx", Request.ApplicationPath));
    //        }
    //        catch
    //        { }
    //    }
    //}

    //private Tuple<bool, Advantech.Myadvantech.DataAccess.ConfiguredItems> CheckItemOrdereable(string partNo, string orgID)
    //{
    //    System.Text.StringBuilder sql = new System.Text.StringBuilder();
    //    sql.Append(" SELECT DISTINCT A.PART_NO AS [name], A.PRODUCT_DESC AS [desc] FROM dbo.SAP_PRODUCT A INNER JOIN SAP_PRODUCT_STATUS_ORDERABLE B ON A.PART_NO=B.PART_NO ");
    //    sql.AppendFormat(" WHERE A.PART_NO = '{0}' ", partNo);
    //    sql.AppendFormat(" AND B.PRODUCT_STATUS IN {0} ", System.Configuration.ConfigurationManager.AppSettings["CanOrderProdStatus"]);
    //    if (orgID.StartsWith("CN"))
    //        sql.AppendFormat(" AND B.SALES_ORG in ('CN10','CN30') ");
    //    else
    //        sql.AppendFormat("AND B.SALES_ORG ='{0}'", orgID);
    //    System.Data.DataTable dt = dbUtil.dbGetDataTable("MY", sql.ToString());

    //    if (dt == null || dt.Rows.Count == 0)
    //        return new Tuple<bool, Advantech.Myadvantech.DataAccess.ConfiguredItems>(false, null);
    //    else
    //    {
    //        Advantech.Myadvantech.DataAccess.ConfiguredItems item = new Advantech.Myadvantech.DataAccess.ConfiguredItems();
    //        item.name = dt.Rows[0]["name"].ToString();
    //        item.desc = dt.Rows[0]["desc"].ToString();
    //        item.qty = 1;
    //        return new Tuple<bool, Advantech.Myadvantech.DataAccess.ConfiguredItems>(true, item);
    //    }
    //}
}